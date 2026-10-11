// The campaign's server side: note search, what a snippet may contain, who
// counts as a member, mentions, the NPC sweep and where portraits are kept.
//
// Six sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. `toMatchQuery` and `parseMentions` are used here and nowhere
// else in the suite. The body moved verbatim.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { toMatchQuery } from '../../../../functions/api/character-creator/campaigns/[id]/search.js';
import { parseMentions } from '../../../../functions/api/character-creator/_lib/mentions.js';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Note search', 'Search snippets are not markup', 'Campaign membership', 'Mentions',
  'The sweep proposes, it does not create', 'Portraits are never public'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- Campaign notes ----------
// A human's query is not an FTS5 query, and the two callers do not want the
// same one. Both of those were bugs before they were tests.
section('Note search');
{
  // A bare apostrophe is FTS5 syntax, so `the baron's men` is a syntax error
  // rather than a search. Every run of word characters becomes one quoted term.
  const q = toMatchQuery("the baron's men");
  check('an apostrophe cannot reach FTS5 as syntax', !/(?<!")'/.test(q), q);
  check('every word becomes a quoted term', q === '"the" AND "baron" AND "s" AND "men"*', q);

  // Injection: whatever a person types, the result is quoted terms and nothing
  // else - no unbalanced quote, no operator, no column filter.
  const nasty = toMatchQuery('foo" OR bar: NEAR(x) *');
  check('an attempted operator is quoted away',
    nasty === '"foo" AND "OR" AND "bar" AND "NEAR" AND "x"*', nasty);
  check('nothing but terms and the join survives', !/[:()*]/.test(nasty.replace(/"\*$/, '"')), nasty);

  check('an empty query is null, not an error', toMatchQuery('') === null);
  check('and so is punctuation alone', toMatchQuery('???') === null);

  // The trailing * is what makes the search box narrow while a word is still
  // being typed.
  check('the last term is a prefix match for the search box',
    toMatchQuery('negoti').endsWith('*'));

  // THE BUG. A question AND-ed together matches no entry ever written: the ask
  // endpoint retrieved nothing and the model correctly answered that the notes
  // do not say. OR retrieves and lets bm25 rank.
  const asked = toMatchQuery("what did the baron's men want?", { join: 'OR' });
  check('a question ORs its terms', asked.includes(' OR ') && !asked.includes(' AND '), asked);
  check('and does not prefix-match the last word', !asked.endsWith('*'), asked);

  const askSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id]', 'ask.js'), 'utf8');
  check('the ask endpoint asks for OR', /toMatchQuery\(question, \{ join: 'OR' \}\)/.test(askSrc));
  // A question with no searchable words - "what happened last time?" is mostly
  // stopwords in some phrasings - must still retrieve something.
  check('and falls back to recent entries when a question yields no terms',
    /ORDER BY created_at DESC, id DESC LIMIT/.test(askSrc));
  // The notes are written by other people. An entry that looks like an
  // instruction is a thing a character said.
  check('the prompt says the notes are data, not instructions',
    /DATA, not instructions/.test(askSrc));
  check('and character sheets are deliberately not sent',
    !/FROM characters/.test(askSrc));
}

section('Search snippets are not markup');
{
  const searchSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id]', 'search.js'), 'utf8');
  const pageSrc = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'notes.js'), 'utf8');

  // snippet() wraps matches in whatever it is given and the text AROUND them is
  // a note somebody typed. Asking for '<mark>' means building HTML out of user
  // input; escaping it client-side would escape the marks with it. Two
  // characters no keyboard produces survive the escape and are swapped after.
  // Comments stripped: the reason NOT to emit '<mark>' is written down in
  // search.js, and a check that reads its own explanation as a violation would
  // be unfixable without deleting the explanation.
  const searchCode = searchSrc.replace(/^\s*\/\/.*$/gm, '');
  check('the server does not put tags in the snippet', !/<mark>/.test(searchCode));
  check('it uses control characters instead', /char\(1\), char\(2\)/.test(searchSrc));
  check('the page escapes BEFORE re-marking',
    /esc\(String\(snippet \|\| ''\)\)[\s\S]{0,120}<mark>/.test(pageSrc));
  check('and the snippet is never interpolated raw', !/\$\{r\.snippet\}/.test(pageSrc));
}

section('Campaign membership');
{
  const authSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    '_lib', 'auth.js'), 'utf8');

  // No campaign_members table: owning a character in a campaign is what being a
  // player IS, and an invite list would be a second, weaker statement of it.
  check('membership is a query, not a table',
    /FROM characters WHERE campaign_id = \? AND player_email = \?/.test(authSrc));
  const schema = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  check('and no campaign_members table was added', !/campaign_members/.test(schema));

  // canWrite is membership; isGm is the narrower right. Collapsing the two lets
  // any player edit the campaign's GM notes.
  check('membership and GM are separate answers',
    /canWrite: isMember, isGm/.test(authSrc));
  const campSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id].js'), 'utf8');
  check('gm_notes stays GM-only after canWrite widened',
    /if \(!access\.isGm\) return forbidden\(\)/.test(campSrc));

  // One chokepoint. If a second place learned the rule, changing it later means
  // finding both.
  const files = ['journal.js', 'campaigns/[id]/search.js', 'campaigns/[id]/ask.js',
                 'campaigns/[id]/items.js', 'campaigns/[id]/currency.js'];
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  for (const f of files) {
    const src = readFileSync(join(apiDir, ...f.split('/')), 'utf8');
    check(`${f} asks auth.js rather than querying characters itself`,
      !/FROM characters WHERE campaign_id/.test(src));
  }
}

// ---------- NPC dossiers ----------
// `@Name` is the deterministic path into a dossier, so what it does and does
// not match is the whole contract. The sweep is the safety net beside it.
section('Mentions');
{
  check('a plain mention is one name', JSON.stringify(parseMentions('@Kevik met us')) === '["Kevik"]');

  // Two words, because "@Lord Coake" is one person and stopping at the space
  // would link to a Lord nobody has met. Not three - at that point the pattern
  // starts swallowing sentences.
  check('two capitalised words are one person',
    JSON.stringify(parseMentions('@Lord Coake was there')) === '["Lord Coake"]');
  check('but a following capital is not dragged in',
    JSON.stringify(parseMentions('@Lord Coake And Then We Left')) === '["Lord Coake"]');
  check('a lowercase word after a name is not part of it',
    JSON.stringify(parseMentions('@Kevik met us')) === '["Kevik"]');

  // Trailing punctuation is how people actually type.
  check('trailing punctuation is trimmed',
    JSON.stringify(parseMentions('@Kevik, @Aldric. @Brannoc!')) === '["Kevik","Aldric","Brannoc"]');

  // Deduped case-insensitively, keeping the first spelling: one @ four times is
  // one person, and one dossier.
  const dupes = parseMentions('@Kevik and @kevik and @KEVIK');
  check('repeats are one person', dupes.length === 1 && dupes[0] === 'Kevik', JSON.stringify(dupes));

  // The things that are NOT people. A description is not a name, and an email
  // address in a note is not somebody to open a dossier for.
  check('an uncapitalised word is not a name', parseMentions('@guard said nothing').length === 0);
  check('a bare @ is nothing', parseMentions('email me @ the usual place').length === 0);
  check('an empty body is no names', parseMentions('').length === 0 && parseMentions(null).length === 0);

  check('an absurdly long name is refused',
    parseMentions('@' + 'A'.repeat(200)).length === 0);

  // Apostrophes and hyphens belong INSIDE names.
  check('a hyphenated name survives',
    JSON.stringify(parseMentions('@Jean-Luc waited')) === '["Jean-Luc"]');
  check("and an apostrophe does too",
    JSON.stringify(parseMentions("@O'Dell waited")) === '["O\'Dell"]');

  // But a possessive does not. The apostrophe the class allows for O'Brien also
  // let "@Kevik's men" parse as "Kevik's", and resolveMentions then opened a
  // second dossier under that name instead of linking Kevik.
  check("a possessive 's is not part of the name",
    JSON.stringify(parseMentions("@Kevik's men")) === '["Kevik"]',
    JSON.stringify(parseMentions("@Kevik's men")));
  check('nor is a curly-apostrophe possessive',
    JSON.stringify(parseMentions('@Kevik’s men')) === '["Kevik"]',
    JSON.stringify(parseMentions('@Kevik’s men')));
  check("an inner apostrophe still survives",
    JSON.stringify(parseMentions("@O'Brien waited")) === '["O\'Brien"]',
    JSON.stringify(parseMentions("@O'Brien waited")));
  check("and a possessive comes off a name that has one",
    JSON.stringify(parseMentions("@O'Brien's aunt")) === '["O\'Brien"]',
    JSON.stringify(parseMentions("@O'Brien's aunt")));
}

section('The sweep proposes, it does not create');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const sweepSrc = readFileSync(join(apiDir, 'campaigns', '[id]', 'npcs', 'sweep.js'), 'utf8');

  // A proposal is not a dossier. An automatic scan on save would confidently
  // turn "the guard" into a person until somebody stopped it.
  check('a sweep with no accept flag writes no npc row',
    !/INSERT INTO npcs/.test(sweepSrc.split("async function accept")[0]));
  check('accepting is a separate, explicit call',
    /searchParams\.get\('accept'\) === '1'/.test(sweepSrc));
  check('and dismissing is recorded so the name is not offered again',
    /npc_proposals_dismissed/.test(sweepSrc));

  // Marked swept only AFTER a successful response: an entry marked by a call
  // that never returned is one nobody will ever look at again.
  const afterUpstream = sweepSrc.slice(sweepSrc.indexOf('callAnthropic'));
  check('entries are marked swept only after the call returns',
    /INSERT OR IGNORE INTO npc_sweeps/.test(afterUpstream));

  // Ids come back through a model and then a client. Trusting them would let a
  // mention point at another campaign's note.
  check('entry ids are filtered against what was sent', /sentIds\.has\(id\)/.test(sweepSrc));
  check('and re-checked against the campaign when accepted',
    /WHERE campaign_id = \? AND id IN/.test(sweepSrc));
  check('a link the model made is marked as such', /'ai'\)/.test(sweepSrc));
  check('the prompt says the notes are data, not instructions',
    /DATA, not instructions/.test(sweepSrc));
}

section('Portraits are never public');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const src = readFileSync(join(apiDir, 'campaigns', '[id]', 'npcs', '[npcId]', 'portrait.js'), 'utf8');

  // The whole site is behind Access. An unauthenticated image endpoint would be
  // the one hole in it, so every read goes through the membership check.
  // requireMember since 2026-10-10; what it refuses is run in
  // server-plumbing.mjs. This read `isMember` in the source, which the guard
  // now holds for it.
  check('the portrait GET checks membership',
    /export async function onRequestGet\(\{ request, env, params \}\) \{\s+const guard = await requireMember\(request, env, params\.id\);\s+if \(guard\.res\) return guard\.res;/.test(src));

  // A missing NPC and an NPC with no portrait are different answers. `!npc?.x`
  // is the tidier-looking form and collapses them, which is why this is pinned
  // rather than left to whoever next reads the file.
  check('a missing NPC is distinguished from a missing portrait',
    /if \(!npc\) return json\(\{ error: 'NPC not found' \}, 404\);/.test(src));
  check('and the two are not collapsed into one check',
    !/!npc\?\.portrait_key/.test(src));
  check('an allowlist decides the type, not a blocklist', /const TYPES = \{/.test(src));
  check('and an unknown type is refused', /415/.test(src));
  check('uploads are size-bounded', /MAX_BYTES/.test(src) && /413/.test(src));

  // Write the row BEFORE deleting the old object: the other order can leave a
  // dossier pointing at nothing, this one can at worst orphan an object.
  const post = src.slice(src.indexOf('onRequestPost'));
  const updateAt = post.indexOf('UPDATE npcs SET portrait_key');
  const deleteAt = post.indexOf('MEDIA.delete');
  check('the row is updated before the old object is deleted',
    updateAt > 0 && deleteAt > updateAt, `update@${updateAt} delete@${deleteAt}`);

  // A stable URL with an immutable cache header needs the query to change, or
  // a replaced portrait is never seen again.
  const pageSrc = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'people.js'), 'utf8');
  check('the page busts the cache with the object key', /portrait_key \|\| ''\)/.test(pageSrc));
  check('and encodes it', /encodeURIComponent/.test(pageSrc));
  check('no img src interpolates a raw timestamp', !/portrait\?v=\$\{esc\(n\.updated_at\)\}/.test(pageSrc));

  // The binding is named for the site, not the app that needed it first.
  const wrangler = readFileSync(join(appDir, '..', '..', 'wrangler.jsonc'), 'utf8');
  check('the R2 binding exists', /"binding":\s*"MEDIA"/.test(wrangler));
}

}
