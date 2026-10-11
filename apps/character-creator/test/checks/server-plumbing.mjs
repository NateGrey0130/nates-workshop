// What every endpoint stands on and none of them is about: D1's hundred-bind
// ceiling, the Access token check and the Claude spend log behind it, and
// paging.
//
// Four sections lifted out of smoke.mjs whole on 2026-10-10. They were two
// runs there, not one - the bind sections sat some 3,000 lines above the
// other two - and they are together here because they are one subject. They
// now run at the position the bind sections held. No section reads state
// another one leaves, so the order between them and their old neighbours was
// never load-bearing.
//
// `paging` and the three bindings of `_lib/sql-chunk.js` are used here and
// nowhere else in the suite. The body moved verbatim, apart from the two
// `import()` paths, which are one directory deeper from here.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { paging } from '../../../../functions/api/character-creator/_lib/paging.js';
import { chunks, D1_MAX_BINDS, BIND_CHUNK } from '../../../../functions/api/character-creator/_lib/sql-chunk.js';
import { jsonWithEtag } from '../../../../functions/api/character-creator/_lib/etag.js';
import { requireMember } from '../../../../functions/api/character-creator/_lib/auth.js';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['SQL bind chunking', 'No query binds an unbounded list', 'Access JWT verification', 'Paging',
  'One revalidating answer, one member guard'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- D1 binds 100 parameters per statement, and no more ----------
// Measured against the real binding, not assumed:
//   binds 100 -> ok, binds 101 -> D1_ERROR: too many SQL variables
//
// So any query building `IN (?,?,...)` from a list that grows with user data
// has to chunk. Four files already did, privately; the ones that did not are
// where it broke - `markConfirmed` runs AFTER the catalog write, so exceeding
// the limit there left 108 spells inserted, none marked confirmed, and a 500
// that read as though nothing had happened.
section('SQL bind chunking');
{
  const big = Array.from({ length: 313 }, (_, i) => i);

  check('the ceiling is recorded as the measured 100', D1_MAX_BINDS === 100);
  check('and the chunk size leaves room for a query\'s own binds',
    BIND_CHUNK < D1_MAX_BINDS);

  const parts = chunks(big);
  check('a long list is split', parts.length === Math.ceil(313 / BIND_CHUNK));
  check('no chunk can exceed the ceiling',
    parts.every((p) => p.length <= D1_MAX_BINDS));
  check('nothing is lost or duplicated',
    parts.flat().length === 313 && new Set(parts.flat()).size === 313);
  check('and order is preserved', parts.flat().every((v, i) => v === i));

  check('an empty list yields no chunks at all', chunks([]).length === 0);
  check('a short list yields exactly one', chunks([1, 2, 3]).length === 1);
  // A caller passing something silly must not produce a chunk over the ceiling.
  check('an oversized chunk size is clamped to the ceiling',
    chunks(big, 5000).every((p) => p.length <= D1_MAX_BINDS));
  check('a zero chunk size still makes progress rather than looping forever',
    chunks([1, 2, 3], 0).flat().length === 3);
}

// Every place that builds placeholders from a list must chunk. A new one added
// without chunking is the same bug again, and it only shows up once someone's
// data gets big - a level-fifteen caster, a long session note, a full import.
section('No query binds an unbounded list');
{
  const files = [
    '_lib/power-picks.js', '_lib/skill-picks.js',
    '_lib/mentions.js', '_lib/skill-bonuses.js', 'campaigns/[id]/npcs/sweep.js',
  ];
  for (const f of files) {
    const src = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', f), 'utf8');
    const usesHelper = /sql-chunk\.js/.test(src);
    check(f + ' imports the chunking helper', usesHelper);
    // The giveaway shape: placeholders built straight from the caller's list
    // rather than from a chunk of it.
    const unbounded = /(?:names|ids)\.map\(\(\) => '\?'\)/.test(src);
    check(f + ' builds no placeholder list from an unchunked array', !unbounded,
      unbounded ? 'found names.map / ids.map building placeholders' : '');
  }
}

// ---------- 1c5. Access JWT verification and Claude spend logging ----------
// The audit's F4 and F3. The verifier is a pure function of (token, keys,
// options), which is what lets this section sign real tokens with WebCrypto
// and prove every refusal path — no network, no Access team. The wiring is
// pinned as source, because the load-bearing properties (pass-through when
// unconfigured; metering that cannot break the call it measures) are exactly
// the kind that vanish silently in a refactor.
section('Access JWT verification');
{
  const { verifyAccessJwt } = await import('../../../../functions/api/_lib/access-jwt.js');
  const b64u = (buf) => Buffer.from(buf).toString('base64url');
  const enc = (obj) => b64u(JSON.stringify(obj));
  const { publicKey, privateKey } = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256', modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]) },
    true, ['sign', 'verify']);
  const jwk = { ...(await crypto.subtle.exportKey('jwk', publicKey)), kid: 'test-key', use: 'sig' };
  const now = Math.floor(Date.now() / 1000);
  const sign = async (payload, header = { alg: 'RS256', kid: 'test-key' }) => {
    const input = enc(header) + '.' + enc(payload);
    const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', privateKey,
      new TextEncoder().encode(input));
    return input + '.' + b64u(sig);
  };
  const claims = { aud: ['site-aud'], email: 'nate@example.com', exp: now + 300, iat: now };
  const good = await sign(claims);

  const ok = await verifyAccessJwt(good, [jwk], { aud: 'site-aud' });
  check('a valid token verifies and yields its email',
    ok.ok === true && ok.email === 'nate@example.com', JSON.stringify(ok));
  check('an expired token is refused',
    !(await verifyAccessJwt(await sign({ ...claims, exp: now - 3600 }), [jwk], { aud: 'site-aud' })).ok);
  check('the wrong audience is refused',
    !(await verifyAccessJwt(good, [jwk], { aud: 'some-other-app' })).ok);
  check('a tampered payload fails the signature, not the parse', (await verifyAccessJwt(
    good.replace(/\.[^.]+\./, '.' + enc({ ...claims, email: 'gm@example.com' }) + '.'),
    [jwk], { aud: 'site-aud' })).reason === 'signature does not verify');
  check('alg none dies before any key is consulted', (await verifyAccessJwt(
    enc({ alg: 'none', kid: 'test-key' }) + '.' + enc(claims) + '.',
    [jwk], { aud: 'site-aud' })).reason.startsWith('unsupported algorithm'));
  check('a token signed by a rotated-away key is refused',
    !(await verifyAccessJwt(await sign(claims, { alg: 'RS256', kid: 'rotated-away' }), [jwk], { aud: 'site-aud' })).ok);
  check('a token with no email claim is refused',
    (await verifyAccessJwt(await sign({ ...claims, email: undefined }), [jwk], { aud: 'site-aud' })).reason === 'no email claim');
  check('every refusal carries a readable reason', await (async () => {
    const bad = [
      await verifyAccessJwt('not-a-jwt', [jwk], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [jwk], { aud: 'other' }),
    ];
    return bad.every((r) => r.ok === false && typeof r.reason === 'string' && r.reason.trim());
  })());

  const fnDir = join(appDir, '..', '..', 'functions', 'api');
  const mw = readFileSync(join(fnDir, '_middleware.js'), 'utf8');
  check('the middleware passes through when unconfigured — the original posture',
    /if \(!domain \|\| !aud\) return next\(\)/.test(mw));
  check('and requires the token identity to match the header everything reads',
    /Cf-Access-Authenticated-User-Email/.test(mw));
  // The arming vars live in wrangler.jsonc, so pages dev reads them too — and
  // local dev has no Access to mint a token. Without the exemption, arming
  // production bricks every local run, including this suite's sibling.
  check('and exempts localhost, where no Access exists to mint a token',
    /localhost/.test(mw) && /127\.0\.0\.1/.test(mw));
  // Armed is a statement the repo makes, so pin it: both vars present in
  // wrangler.jsonc, or the middleware silently returns to header-trust and
  // nothing says so.
  const wranglerCfg = readFileSync(join(appDir, '..', '..', 'wrangler.jsonc'), 'utf8');
  check('wrangler.jsonc arms the middleware with both variables',
    /"ACCESS_TEAM_DOMAIN":\s*"[^"]+\.cloudflareaccess\.com"/.test(wranglerCfg)
    && /"ACCESS_AUD":\s*"[0-9a-f]{64}"/.test(wranglerCfg));

  const client = readFileSync(join(fnDir, '_lib', 'claude-client.js'), 'utf8');
  check('usage recording is fail-open, so metering cannot break the call',
    /export async function recordUsage/.test(client)
    && /never the caller's problem/.test(client));
  const proxy = readFileSync(join(fnDir, 'claude.js'), 'utf8');
  check('the proxy records who spent the key',
    /recordUsage\(/.test(proxy) && /getAccessEmail\(request\)/.test(proxy));
  const askSrc = readFileSync(join(fnDir, 'character-creator', 'campaigns', '[id]', 'ask.js'), 'utf8');
  check('and so does the campaign Ask', /recordUsage\(/.test(askSrc));

  // What a call COST, not only its tokens (INGESTION-AUDIT F35, migration 077).
  // Run against a fake D1 rather than read as text: the row is the contract.
  {
    const { recordUsage } = await import('../../../../functions/api/_lib/claude-client.js');
    const rows = [];
    const env = { DB: { prepare: (sql) => ({ bind: (...args) => ({ run: async () => rows.push({ sql, args }) }) }) } };
    const reply = (usage) => ({ status: 200, text: JSON.stringify({ model: 'm', usage }) });
    await recordUsage(env, { email: 'a@b', endpoint: 'proxy', model: 'm',
      upstream: reply({ input_tokens: 100, output_tokens: 7, cache_creation_input_tokens: 900, cache_read_input_tokens: 4000 }) });
    await recordUsage(env, { email: 'a@b', endpoint: 'proxy', model: 'm',
      upstream: reply({ input_tokens: 100, output_tokens: 7 }) });
    const [cached, plain] = rows.map((r) => r.args);
    check('a cached call records its total input and the split beside it',
      /cache_write_tokens, cache_read_tokens/.test(rows[0]?.sql || '')
        && cached?.[3] === 5000 && cached?.[6] === 900 && cached?.[7] === 4000);
    check('and a call with no cache records NULL for both, not zero',
      plain?.[3] === 100 && plain?.[6] === null && plain?.[7] === null);
    const extractor = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');
    check('the extractor writes the same two columns',
      /cache_write_tokens, cache_read_tokens\) `/.test(extractor));
  }

  // Every remaining Claude call. Extraction sends a whole PDF page and is the
  // most expensive call in the repo; it was also the only one with no number
  // attached, which made "what did this book cost" unanswerable while the
  // table to answer it had existed since migration 038.
  //
  // Pinned by counting callAnthropic against recordUsage across functions/,
  // rather than by naming today's files: a new endpoint that calls the model
  // and forgets to meter it is exactly the regression this is for, and a list
  // of filenames would not see it.
  const claudeCalls = [];
  const walkFns = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) { walkFns(full); continue; }
      if (!e.name.endsWith('.js')) continue;
      const src = readFileSync(full, 'utf8');
      if (/\bawait callAnthropic\(/.test(src)) {
        claudeCalls.push({ file: full.slice(fnDir.length + 1), metered: /\brecordUsage\(/.test(src) });
      }
    }
  };
  walkFns(fnDir);
  // The floor was five while the importer contributed its own routes. Those
  // are gone and extraction runs from scripts/ now, so functions/ holds three
  // callers: the proxy, campaign-ask and the NPC sweep. The floor is a guard
  // against the sweep silently matching NOTHING, not a target - if it ever
  // reads zero the check has stopped checking.
  check('every file in functions/ that calls the model also meters it',
    claudeCalls.length >= 3 && claudeCalls.every((c) => c.metered),
    claudeCalls.filter((c) => !c.metered).map((c) => c.file).join(', ') || `${claudeCalls.length} found`);

  // The labels are the whole point of the table - an endpoint column full of
  // `import` tells you nothing about what the tokens went to.
  //
  // EXTRACTION LEFT functions/ WITH THE IN-APP IMPORTER. It runs from
  // scripts/extract-class.mjs now, so these checks FOLLOW it rather than
  // being deleted with the routes: what F7 shipped is that extraction is
  // metered and says what it extracted, and that is still worth pinning.
  const extractor = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');
  check('the class extractor labels its spend',
    /'cc-extract-class'/.test(extractor));

  // Metered BEFORE the reply is parsed. A truncated or refused extraction has
  // already spent the input tokens for a whole page, and a run that cost money
  // and produced nothing is the run most worth having a number for.
  const meterBeforeParse = (src) => {
    const at = src.indexOf('recordUsage(');
    const parseAt = src.indexOf('JSON.parse(upstream.text)');
    return at !== -1 && parseAt !== -1 && at < parseAt;
  };
  check('a failed extraction is still recorded, because the tokens were still spent',
    extractor.indexOf('claude_usage') < extractor.indexOf('if (!payload) die('));

  // Both places used to say the admin importers were deliberately unlogged,
  // and both now explain that they no longer are. So this pins the CURRENT
  // claim rather than the absence of the old one — a check that greps for the
  // stale phrase fails on the correction that quotes it, which is a trap this
  // repo has walked into before.
  const setupSrc = readFileSync(join(appDir, '..', '..', 'SETUP.md'), 'utf8');
  check('SETUP.md states that every Claude call in functions/ is metered',
    /Every Claude call in `functions\/` writes one row to\s*\r?\n?`claude_usage`/.test(setupSrc));
  check('and names the endpoints it can be read by',
    /cc-extract-class/.test(setupSrc) && /cc-npc-sweep/.test(setupSrc));
}

// ---------- 1d. Paging ----------
// A stray query string must not turn a list endpoint into a 400, so anything
// nonsensical falls back to the default rather than erroring.
section('Paging');
const pageOf = (qs) => paging(new Request('https://x/list' + qs));
check('defaults with no parameters', (() => {
  const p = pageOf('');
  return p.limit === 200 && p.offset === 0;
})());
check('honours a sensible limit and offset', (() => {
  const p = pageOf('?limit=50&offset=100');
  return p.limit === 50 && p.offset === 100;
})());
check('clamps an oversized limit to the maximum', pageOf('?limit=99999').limit === 500);
check('a negative or zero limit falls back to the default',
  pageOf('?limit=-1').limit === 200 && pageOf('?limit=0').limit === 200);
check('a non-numeric limit falls back to the default', pageOf('?limit=abc').limit === 200);
check('a negative offset floors at zero', pageOf('?offset=-5').offset === 0);

// ---------- One revalidating answer, one member guard ----------
// Three things every route did for itself until 2026-10-10. Four catalog
// routes ended in the same eight lines of body-hash ETag; seven member-only
// GETs each re-tested membership and re-typed the refusal; two character
// routes re-typed requireCharacter. Run here, then held as source so the next
// route reaches for the helper.
section('One revalidating answer, one member guard');
{
  const ask = (tag) => new Request('https://x/catalogs', tag ? { headers: { 'If-None-Match': tag } } : {});
  const first = await jsonWithEtag(ask(), '{"gear":[]}', 'catalogs');
  const tag = first.headers.get('ETag');
  check('a first answer carries the body, a weak tag and store-but-ask',
    first.status === 200 && await first.clone().text() === '{"gear":[]}'
    && /^W\/"catalogs-[0-9a-f]{16}"$/.test(tag) && first.headers.get('Cache-Control') === 'private, no-cache'
    && first.headers.get('Content-Type') === 'application/json', tag);
  // The tag is the one these routes produced before the helper, byte for byte,
  // so a browser holding one from last week still revalidates against it.
  const old = await (async (body) => {
    const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
    return `W/"catalogs-${[...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('')}"`;
  })('{"gear":[]}');
  check('and the tag is the one the routes wrote out by hand', tag === old, `${tag} vs ${old}`);
  const again = await jsonWithEtag(ask(tag), '{"gear":[]}', 'catalogs');
  check('the same body asked for again is an empty 304 with the same tag',
    again.status === 304 && await again.text() === '' && again.headers.get('ETag') === tag);
  const changed = await jsonWithEtag(ask(tag), '{"gear":[1]}', 'catalogs');
  check('a changed body is sent whole', changed.status === 200 && changed.headers.get('ETag') !== tag);
  const other = await jsonWithEtag(ask(tag), '{"gear":[]}', 'codex-gear');
  check('and the same bytes under another label do not 304 into each other',
    other.status === 200 && other.headers.get('ETag') !== tag);

  // requireMember against a stand-in database: who is asking decides.
  const db = (gm, members) => ({ prepare: (sql) => ({ bind: (...b) => ({ first: async () => (
    /FROM campaigns/.test(sql) ? (b[0] === 7 ? { id: 7, gm_email: gm } : null)
      : (members.includes(b[1]) ? { n: 1 } : null)) }) }) });
  const as = (email) => new Request('https://x/', email
    ? { headers: { 'Cf-Access-Authenticated-User-Email': email } } : {});
  const env = { DB: db('gm@x', ['player@x']) };
  const who = async (email, id = 7) => {
    const g = await requireMember(as(email), env, id);
    return g.res ? g.res.status : 'in';
  };
  check('the G.M. and a player with a character are let in',
    await who('gm@x') === 'in' && await who('player@x') === 'in');
  check('a stranger is refused, a missing campaign is not found, and nobody is unauthorised',
    await who('stranger@x') === 403 && await who('gm@x', 8) === 404 && await who(null) === 401,
    JSON.stringify([await who('stranger@x'), await who('gm@x', 8), await who(null)]));
  const refusal = await (await requireMember(as('stranger@x'), env, 7)).res.json();
  check('with the sentence the seven handlers each used to type',
    refusal.error === 'Only the GM or a player with a character in this campaign can do that', refusal.error);

  const fnRoot = join(repoRoot, 'functions', 'api', 'character-creator');
  const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    (e.isDirectory() ? walk(join(dir, e.name)) : e.name.endsWith('.js') ? [join(dir, e.name)] : []));
  const routes = walk(fnRoot).map((f) => ({ f: f.slice(fnRoot.length + 1).replace(/\\/g, '/'), src: readFileSync(f, 'utf8') }));
  check('the routes are found', routes.length > 60, String(routes.length));
  const ownHash = routes.filter((r) => r.f !== '_lib/etag.js' && /crypto\.subtle\.digest/.test(r.src) && /ETag/.test(r.src));
  check('no route hashes its own body into an ETag', ownHash.length === 0, ownHash.map((r) => r.f).join(', '));
  const usesHelper = routes.filter((r) => r.f !== '_lib/etag.js' && /jsonWithEtag\(request, body, /.test(r.src))
    .map((r) => r.f).sort();
  check('four routes answer through the helper',
    usesHelper.join() === 'catalogs.js,catalogs/traits.js,codex.js,items.js', usesHelper.join());
  const retyped = routes.filter((r) => r.f !== '_lib/auth.js'
    && (r.src.match(/Only the GM or a player with a character in this campaign can do that/g) || []).length
    && /write: false \}\);\s+if \(guard\.res\) return guard\.res;\s+(?:\/\/[^\n]*\s+)*if \(!guard\.access\.isMember\)/.test(r.src));
  check('no read re-tests membership after asking for a read guard', retyped.length === 0, retyped.map((r) => r.f).join(', '));
  const ownGuard = routes.filter((r) => r.f.startsWith('characters/[id]/') && /characterAccess\(/.test(r.src)).map((r) => r.f);
  // stash.js reads the character row itself and calls isHiddenNpc, which
  // _lib/auth.js names as one of three deliberate exceptions.
  check('and the item and vessel routes go through requireCharacter',
    ownGuard.join() === 'characters/[id]/items/[itemId]/stash.js', ownGuard.join());
}

}
