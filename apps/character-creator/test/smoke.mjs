// Smoke test: (1) the RCC/OCC markdown files parse correctly, (2) the D1 schema
// migrates cleanly into a local D1 instance, (3) db/schema.sql alone is enough
// to build a current database, and (4) every migration on disk is recorded as
// applied to that database.
//
// (3) and (4) look alike and are not: (4) asks what the local database has had
// done to it, (3) asks what a brand-new environment would get. Only (3) sees a
// migration whose column never made it back into schema.sql.
// Run from anywhere:  node apps/character-creator/test/smoke.mjs
//
// Between edits: `--section <name>` runs only the sections whose names contain
// <name> (case-insensitive; repeatable, or comma-separated) and skips the
// wrangler-backed environment half, which is nearly all of the wall clock.
// The merge gate is the FLAGLESS run — a partial run says PARTIAL in its
// summary line so its output cannot be quoted as the gate's.
//
// ── WHEN THIS FILE NEEDS SPLITTING AGAIN ─────────────────────────────────────
//
// It has been split three times. `checks/environment.mjs` came out when it
// passed 4,000 lines. It grew back to 10,000, and `checks/second-body.mjs`
// took four Nightbane sections out. At 11,000, on 2026-10-10, nine more
// modules took thirty-nine sections and left about 7,200 lines:
// `catalog-editor`, `catalog-duplicates`, `server-plumbing`,
// `campaign-server`, `character-validation`, `talents`,
// `race-and-occupation`, `skill-rules` and `mos-totem`. It will grow again,
// so this records how to cut rather than leaving the next person to
// re-derive it.
//
// THE TEST FOR A GOOD CUT: sections that are ONE SUBJECT, that read nothing
// the rest of this file declares, and that declare nothing the rest reads.
// Bindings used there and nowhere else are a good sign and not a requirement:
// second-body had 26, catalog-editor had none. Adjacent is cheaper, and two
// of the nine modules above were gathered from runs thousands of lines apart,
// which is safe only because no section reads state another one leaves.
//
// DERIVE THE LIST, do not eyeball it, by counting each imported binding and
// each column-0 declaration inside and outside the range. Then READ every
// hit the count calls shared, because most are not. `rel`, `legal`, `bad`,
// `skill`, `allows` and `html` are declared at column 0 somewhere in this
// file and the count finds them in dozens of other sections; every one of
// those is a local of the same name, or the word in a string. That reading
// is what turned the validation pair from a cut that needed a shared fixture
// into one that needed nothing.
//
// WHAT IS REALLY SHARED, as of that date, and is the trap in any cut that
// touches it:
//   `D`              built in `Psychic tiers`, read in nine other sections
//   `derive`, `D2`   built in `Class bonuses`, read in seven
//   `dragon`         `Class bonuses`, read by `Class variants` and
//                    `Class composition`
//   `classTemplate`  `Class template`, read by `Skill bonuses`
//   `Picker`         `Picker filtering`, read by `Wizard markup escapes
//                    what it is handed`
// `D` and `derive` are js/derive.js, a classic script, evaluated against a
// stand-in global rather than imported, once for each name. A module that
// needs it builds its own the same way (`skill-rules.mjs` and
// `second-body.mjs` do). **Do not let `Psychic tiers` or `Class bonuses`
// travel with a split** without hoisting those lines above whatever stays.
//
// THE CANDIDATE TODAY is the sections that read `D` or `derive`: the two
// attribute bonus charts, `Bonus keys`, the two dice-bonus sections, the two
// save sections and `Bonus attribution`. One subject, not adjacent, and the
// first cut that has to settle where that object is built.
//
// A MOVED SECTION CAN CARRY A PATH. A static import is rewritten when the
// import block is; an `import('../js/...')` inside a section body is not, and
// from `checks/` it is one directory deeper. Eleven of them moved on
// 2026-10-10.

function parseFile(name) {
  return parseClassMarkdown(readFileSync(join(appDir, 'test', 'fixtures', name), 'utf8'));
}

// ---------- 1. Parser ----------
section('The browser entry points parse');
{
  // NOTHING imports app.js or sheet.js - the wizard boots on import - so this
  // suite reads them as TEXT, for its source pins. That left a hole, and on
  // 2026-09-11 a missing comma in an import list walked straight through it:
  // `node --check` reads a .js file as a SCRIPT and said nothing, the whole
  // suite and CI were green, and the module would have failed to parse in the
  // browser - which is the wizard not loading at all. Parsed here as what each
  // one actually is: app.js an ES module, sheet.js a classic script.
  const stem = join(process.env.TEMP || process.env.TMPDIR || '/tmp', 'smoke-parse-' + process.pid);
  const parses = (file, ext) => {
    const copy = stem + '-' + file.replace(/\W/g, '-') + '.' + ext;
    writeFileSync(copy, readFileSync(appPath(file), 'utf8'));
    const r = spawnSync(process.execPath, ['--check', copy], { encoding: 'utf8' });
    rmSync(copy, { force: true });
    return { ok: r.status === 0, err: (r.stderr || '').split('\n').find((l) => /Error/.test(l)) || '' };
  };
  const app = parses('app.js', 'mjs');
  check('app.js parses as the ES module the wizard loads', app.ok, app.err);
  const sheet = parses('sheet.js', 'cjs');
  check('and sheet.js parses as the classic script the sheet loads', sheet.ok, sheet.err);
  // codex.js and catalog.js are the other two browser entry points and were
  // NOT covered here, which is the same hole in two more pages: nothing
  // imports them either, so a syntax error ships a blank page with the whole
  // suite green. The extension is what each HTML actually asks for -
  // codex.html loads codex.js bare, catalog.html loads catalog.js as a module.
  // Added while editing both for BOOK-INGEST-AUDIT F73.
  const codex = parses('codex.js', 'cjs');
  check('and codex.js parses as the classic script the codex loads', codex.ok, codex.err);
  const catalog = parses('catalog.js', 'mjs');
  check('and catalog.js parses as the ES module the catalog editor loads', catalog.ok, catalog.err);
}

section('Parser');

// Custom languages: three consumers (wizard, sheet, server validator) share
// these, so the rule is asserted here once rather than trusted three times.
check('familySkillName composes', familySkillName(LANGUAGE_OTHER, 'Spanish') === 'Language: Spanish');
check('familySkillName tolerates typed prefix',
  familySkillName(LANGUAGE_OTHER, 'language:  Orc') === 'Language: Orc');
check('familySkillName rejects blank', familySkillName(LANGUAGE_OTHER, '   ') === null
  && familySkillName(LANGUAGE_OTHER, 'Language:') === null);
check('isFamilyName covers the Language family',
  isFamilyName('Language: Elvish') && isFamilyName(LANGUAGE_OTHER) && !isFamilyName('Sign Language'));

// LITERACY is the second family, and it had no rule at all until now: the same
// row, for reading rather than speaking, treated as one ordinary skill.
check('and the Literacy family', isFamilyName('Literacy: Elven') && isFamilyName(LITERACY_OTHER));
check('but not the bare Literacy row', !isFamilyName('Literacy'));
check('familySkillName composes a written language',
  familySkillName(LITERACY_OTHER, 'Gobblely') === 'Literacy: Gobblely');
check('and tolerates the typed prefix there too',
  familySkillName(LITERACY_OTHER, 'literacy: Elven') === 'Literacy: Elven');
check('the Other rows are repeatable and their members are not',
  isRepeatableRow(LANGUAGE_OTHER) && isRepeatableRow(LITERACY_OTHER)
  && !isRepeatableRow('Language: Elven') && !isRepeatableRow('Literacy: Elven'));
// A member takes its numbers from ITS OWN family's row. Crossing them would
// price a written language off the spoken row, which is a different percentage.
check('each family resolves to its own Other row',
  otherRowFor('Language: Elven') === LANGUAGE_OTHER
  && otherRowFor('Literacy: Elven') === LITERACY_OTHER
  && otherRowFor('Boxing') === null);

// A FOURTH consumer: an occ_skills choice group. Seven classes say "two
// languages of choice" and were written as the whole Technical category,
// because the repeatable-row rule only ever reached the related/secondary
// picker. In a group the same row was a plain checkbox, so ticking it gave the
// character a skill named, literally, "Language: Other" - which two Priests of
// Light in production are carrying.
{
  const group = (line) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'skills:', '  occ_skills:', '    ' + line,
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));

  // The count check has to KNOW the row is repeatable, or "three languages of
  // choice" cannot be written at all.
  check('a group may ask for more languages than the from list is long',
    group('- { choose: 3, from: ["Language: Other"], bonus: 30 }').errors.length === 0);
  check('and the same exemption does not loosen an ordinary from list',
    group('- { choose: 3, from: ["Boxing", "Prowl"] }').errors.length === 1);
  check('a mixed list carrying the repeatable row is exempt too',
    group('- { choose: 3, from: ["Language: Other", "Language: Dragonese"] }').errors.length === 0);

  // Both wizard controls have to apply the rule, and they are separate
  // functions: toggleSkill for related/secondary, toggleGroupPick for a group.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const fn = (name) => {
    const at = appSrc.indexOf(`function ${name}(`);
    return at < 0 ? '' : appSrc.slice(at, appSrc.indexOf('\n}\n', at));
  };
  check('toggleSkill prompts for the language', fn('toggleSkill').includes('isRepeatableRow'));
  check('and toggleGroupPick does too', fn('toggleGroupPick').includes('isRepeatableRow'));
  // The pick is stored under the language's OWN name, which has no catalog row
  // by design - so the resolver has to fall back, or it saves at 0% +0/lvl.
  check('resolveSkill falls back to the Other row for a named language',
    fn('resolveSkill').includes('isFamilyName') && fn('resolveSkill').includes('otherRowFor'));
  // Neither control may hardcode ONE family's row: the same rule covers spoken
  // languages and written ones, and hardcoding is how literacy was left out.
  for (const name of ['toggleSkill', 'toggleGroupPick', 'resolveSkill']) {
    check(`${name} names no single family's row`, !fn(name).includes('LANGUAGE_OTHER'),
      'use isRepeatableRow / otherRowFor');
  }

  // And no class may go back to offering a whole category for languages.
  const dbDir = join(appDir, 'db');
  const offending = readdirSync(dbDir).filter((f) => f.endsWith('.sql'))
    .filter((f) => readFileSync(join(dbDir, f), 'utf8').includes('no individual language rows'))
    .filter((f) => f > 'fix-language-picks.sql');
  check('no data script after the fix reintroduces the category offer',
    offending.length === 0, offending.join(', '));
}

const ck = parseFile('cyber-knight.md');
check('cyber-knight parses', ck.ok, JSON.stringify(ck.errors));
check('cyber-knight core fields', ck.data.id === 'cyber-knight' && ck.data.system === 'rifts' && ck.data.category === 'occ');
check('attribute_requirements map', ck.data.attribute_requirements?.ME === 12 && ck.data.attribute_requirements?.MA === 12);
check('occ_skills inline objects', ck.data.skills?.occ_skills?.length === 7 && ck.data.skills.occ_skills[0].name === 'Radio: Basic' && ck.data.skills.occ_skills[0].base === 40);
check('occ_related_skills count/categories', ck.data.skills?.occ_related_skills?.count === 6 && ck.data.skills.occ_related_skills.categories.includes('Espionage'));
check('equipment_starting', ck.data.equipment_starting?.length === 3 && ck.data.equipment_starting[0].item_id === 'ns-turbo-cyclone');
check('psionics block', ck.data.psionics?.type === 'major' && ck.data.psionics?.isp_base === '1d4x10+20');
check('special_abilities block-form list', ck.data.special_abilities?.length === 2 && ck.data.special_abilities[0].name === 'Psi-Sword');
check('level_progression', ck.data.level_progression?.length === 3 && ck.data.level_progression[2].grants.length === 2);
check('lore + gm_notes sections', !!ck.data.lore?.includes('Cyber-Knights') && !!ck.data.gm_notes?.includes('Code of Chivalry'));

const lb = parseFile('long-bowman.md');
check('long-bowman parses', lb.ok, JSON.stringify(lb.errors));
check('palladium-fantasy system', lb.data.system === 'palladium-fantasy' && lb.data.category === 'occ');
check('secondary_skills count', lb.data.skills?.secondary_skills?.count === 4);

const dh = parseFile('dragon-hatchling.md');
check('dragon-hatchling parses', dh.ok, JSON.stringify(dh.errors));
check('rcc category', dh.data.category === 'rcc');
check('attribute_dice map', dh.data.attribute_dice?.PS === '4d6+12');
check('mdc_base + magic block', dh.data.mdc_base === '1d4x100' && dh.data.magic?.spell_levels_allowed?.length === 2);
check('natural_abilities', dh.data.natural_abilities?.length === 4);
check('restrictions scalar list', dh.data.restrictions?.length === 2);

// Quoted scalars. The two YAML styles escape differently, and stripping the
// outer pair without unescaping left backslashes in the value — reachable from
// book text, which quotes things often enough to matter.
check('a double-quoted string is unescaped', (() => {
  const y = parseYaml('a: "Adult: the \\"big\\" one"\nb: "back\\\\slash"');
  return y.a === 'Adult: the "big" one' && y.b === 'back\\slash';
})());
check('a single-quoted string doubles its quote instead',
  parseYaml("a: 'it''s here'").a === "it's here");
check('an unquoted string is untouched', parseYaml('a: plain value').a === 'plain value');
check('a lone quote character is not treated as quoting', parseYaml('a: "').a === '"');

// Invalid input must be rejected, not silently accepted.
const bad = parseClassMarkdown('---\nname: Nameless\nsystem: gurps\ncategory: occ\n---\nbody');
check('invalid file rejected', !bad.ok && bad.errors.some((e) => e.includes('id')) && bad.errors.some((e) => e.includes('system')));
const noFm = parseClassMarkdown('# just markdown, no frontmatter');
check('missing frontmatter rejected', !noFm.ok);

// ---------- 1a. Every browser script parses ----------
// Cheap, and it would have caught a real one: a prompt string written with real
// newlines inside single quotes shipped a SyntaxError in import.js, which meant
// the whole page — not just that prompt — did nothing. Nothing else here loads
// the page scripts, because they are classic scripts full of DOM calls, so a
// syntax error in one was invisible to the entire suite.
section('Browser scripts parse');
{
  const scripts = [
    ...readdirSync(appDir).filter((f) => f.endsWith('.js')).map((f) => join(appDir, f)),
    ...readdirSync(join(appDir, 'js')).filter((f) => f.endsWith('.js')).map((f) => join(appDir, 'js', f)),
    // The four apps the pages moved to. Without these this check quietly
    // stopped opening sheet.js, codex.js, campaign.js and dashboard.js - four
    // page scripts whose syntax errors nothing else in the suite would catch.
    ...siblingAppDirs.flatMap((d) => readdirSync(d).filter((f) => f.endsWith('.js')).map((f) => join(d, f))),
  ];
  check('found the page scripts', scripts.length >= 10, `only ${scripts.length}`);
  for (const path of scripts) {
    const res = spawnSync(process.execPath, ['--check', path], { encoding: 'utf8' });
    const name = path.slice(join(appDir, '..').length + 1).replace(/\\/g, '/');
    check(`${name} parses`, res.status === 0,
      (res.stderr || '').split('\n').slice(0, 3).join(' ').trim());
  }

  // A script that parses can still fail to LOAD. The Codex's catalog editor
  // imported `./js/catalog-fields.js` from a folder that has no js/ - the file
  // had moved apps and its import had not - and the page showed "Checking
  // access…" for three weeks. So every import a page script states is resolved
  // against the tree: a relative one from the script's own folder, an absolute
  // one from the site root, which is the repo root.
  const siteRoot = join(appDir, '..', '..');
  const broken = [];
  let imports = 0;
  for (const path of scripts) {
    const text = readFileSync(path, 'utf8');
    for (const m of text.matchAll(/^\s*(?:import|export)\s[^'"]*?from\s*['"]([^'"]+)['"]|^\s*import\s*['"]([^'"]+)['"]/gm)) {
      const spec = m[1] || m[2];
      if (!/^[./]/.test(spec)) continue;
      imports += 1;
      const target = spec.startsWith('/') ? join(siteRoot, spec) : join(path, '..', spec);
      if (!existsSync(target)) {
        broken.push(`${path.slice(siteRoot.length + 1).replace(/\\/g, '/')} imports ${spec}`);
      }
    }
  }
  check('the page scripts state imports to resolve', imports > 20, `only ${imports}`);
  check('every import a page script states resolves to a file', broken.length === 0, broken.join(' | '));
}

// ---------- 1a2. Escaping a value into markup ----------
// Two contexts, two escapes, and for a long time one function.
//
// escHtml was textContent -> innerHTML, which does not escape `"`, and 25 call
// sites put its result inside a double-quoted attribute. A gear row named
// "Rolling Thunder" All-Purpose Vehicle rendered its Name input EMPTY; a
// skill's bonuses JSON rendered as value="{" plus the rest of the JSON
// reparsed as attribute names, and saving that row wrote `{` back over the
// bonuses.
//
// The inline handlers had the mirror of it: escHtml(v).replace(/'/g, '&#39;')
// in six places, which is correct for the attribute and wrong for the JS
// inside it - an attribute is entity-decoded BEFORE its contents are parsed as
// JavaScript, so &#39; hands the apostrophe back to the string literal it was
// meant to escape.
//
// These are behavioural rather than textual: the two functions are pure now,
// so the test runs them, decodes the result the way a browser would, and
// requires the value that comes back out to be the value that went in.
// ---------- Composing a row's source_book ----------
// `scripts/source-book-lib.mjs` has one export and its own header says "its
// only reader is the smoke test". THAT WAS NOT TRUE: this file imported
// `composeSourceBook` and never called it, so the module was referenced but
// never exercised, and the import was the only thing keeping the export off
// the 'no export is named nowhere else' check.
//
// Dropping the import instead would have been the tidy-looking move and the
// wrong one. The file is deliberately retained - it was moved out of
// `functions/_lib/` because Pages' esbuild cannot parse the `with { type:
// 'json' }` attribute Node requires, which broke every production deploy for
// two days, and its header ends "Keep it out. A route that needs this again
// should import it from here." Deleting it would throw that away; propping it
// up with an unused import would keep lying about who reads it. So it gets a
// reader.
//
// The cases are the ones its doc comment argues for, which had no test behind
// them until now.
section('Composing a row\'s source_book');
{
  check('no session book at all is null, not an empty string',
    composeSourceBook('', 'p. 12') === null && composeSourceBook(null, null) === null,
    JSON.stringify([composeSourceBook('', 'p. 12'), composeSourceBook(null, null)]));

  // A not_books marker says where a value came from INSTEAD of a book, so
  // composing pages onto it would claim a printing that does not exist.
  const marker = 'Estimate - no published price found';
  check('a not_books marker comes back verbatim, pages and all ignored',
    composeSourceBook(marker, 'p. 88') === marker,
    composeSourceBook(marker, 'p. 88'));

  // Resolved THROUGH books.json rather than taken verbatim: the alias is the
  // point, since a session is labelled by hand.
  const oneRow = composeSourceBook('Rifts Ultimate Edition', 'p. 180');
  check('a registry book resolves to its canonical title with a single page',
    typeof oneRow === 'string' && / p\.180$/.test(oneRow), oneRow);

  const rangeRow = composeSourceBook('Rifts Ultimate Edition', 'p. 180-190');
  check('and a range renders as p.first-last',
    typeof rangeRow === 'string' && / p\.180-190$/.test(rangeRow), rangeRow);

  // THE POINT OF THE FUNCTION, and the one assertion here that had to be
  // rewritten before it meant anything. It first read the canonical title back
  // out of a canonical title, which passes whether or not the registry is ever
  // consulted. An ALIAS cannot: `Wormwood` only becomes `Rifts Dimension Book
  // 1: Wormwood` by going through books.json.
  const viaAlias = composeSourceBook('Wormwood', 'p. 12');
  check('an alias resolves through books.json to the canonical title',
    viaAlias === 'Rifts Dimension Book 1: Wormwood p.12', viaAlias);

  const viaAmpersand = composeSourceBook('Triax & The NGR', 'p. 12');
  check('and an alias the registry spells differently resolves too',
    viaAmpersand === 'Rifts World Book 5: Triax and the NGR p.12', viaAmpersand);

  check('a single page and a range agree on the title they compose onto',
    rangeRow.replace(/ p\..*$/, '') === oneRow.replace(/ p\..*$/, ''),
    `${oneRow} / ${rangeRow}`);

  // One session covers many page ranges, so the ROW's label wins - but a
  // range-less row still lands on the session's own pages rather than losing
  // them.
  check('a row with no pages falls back to the range on the session label',
    / p\.180-190$/.test(composeSourceBook('Rifts Ultimate Edition p.180-190', null)),
    composeSourceBook('Rifts Ultimate Edition p.180-190', null));

  check('and the row\'s own label beats the session\'s',
    / p\.7$/.test(composeSourceBook('Rifts Ultimate Edition p.180-190', 'p. 7')),
    composeSourceBook('Rifts Ultimate Edition p.180-190', 'p. 7'));

  check('a book with no pages anywhere is the bare title',
    !/ p\./.test(composeSourceBook('Rifts Ultimate Edition', null)),
    composeSourceBook('Rifts Ultimate Edition', null));

  // A backwards range is stored the way it reads, not the way it was typed.
  check('a reversed range is normalised rather than echoed',
    / p\.10-20$/.test(composeSourceBook('Rifts Ultimate Edition', 'p. 20-10')),
    composeSourceBook('Rifts Ultimate Edition', 'p. 20-10'));

  // Unknown books keep their own words, minus a page range that would
  // otherwise be written twice.
  const unknown = composeSourceBook('Some Book Nobody Registered p.5', 'p. 5');
  check('an unregistered book keeps its text and its range is not doubled',
    unknown === 'Some Book Nobody Registered p.5', unknown);
}

section('Escaping a value into markup');
{
  const ui = readFileSync(join(repoRoot, 'shared', 'js', 'ui.js'), 'utf8');
  const start = ui.indexOf('function escHtml');
  const jsStart = ui.indexOf('function escJs', start);
  const end = ui.indexOf('\n}', jsStart) + 2;
  check('shared/js/ui.js exports both escapes',
    start !== -1 && jsStart !== -1, 'escHtml or escJs is gone');
  const { escHtml: eh, escJs: ej } =
    new Function(ui.slice(start, end) + '\nreturn { escHtml, escJs };')();

  // How a browser reads an attribute value back.
  const decode = (s) => s.replace(/&quot;/g, '"').replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>').replace(/&amp;/g, '&');

  const cases = [
    ['"Rolling Thunder" All-Purpose Vehicle', 'a gear name that carries quotes'],
    ['{"attributes":{"PS":1},"combat":{"roll":2}}', "a skill's bonuses JSON"],
    ["Dragon's Claw", 'an apostrophe'],
    ['A & B <tag>', 'an ampersand and a tag'],
    ['back\\slash', 'a backslash'],
  ];
  const attrBad = cases.filter(([v]) => decode(eh(v)) !== v).map(([, w]) => w);
  check('a value survives value="..." and comes back out whole', attrBad.length === 0,
    `broken: ${attrBad.join('; ')}`);

  // eslint-disable-next-line no-eval -- this IS the thing being tested: the
  // string the browser hands to the JS parser after decoding the attribute.
  const jsBad = cases.filter(([v]) => {
    try { return eval("'" + decode(ej(v)) + "'") !== v; } catch { return true; }
  }).map(([, w]) => w);
  check('and survives onclick="fn(\'...\')" as a JS string literal', jsBad.length === 0,
    `broken: ${jsBad.join('; ')}`);

  check('escHtml escapes the quote it used to leave alone',
    eh('"') === '&quot;', 'escHtml is back to a text-node-only escape');
  // Coercion is what 200-odd call sites were written against.
  check('and coerces the way the textContent setter did',
    eh(null) === '' && eh(undefined) === 'undefined' && eh(12) === '12',
    'null/undefined/number no longer stringify as they did');

  // The workarounds this replaces. Each was correct about the attribute and
  // wrong about what the attribute contained, and each carried a comment
  // saying escHtml leaves quotes alone - which is now false.
  // Comments stripped first. Both files that lost a workaround now carry a
  // comment SAYING what the workaround was, which reads to a naive search
  // exactly like the workaround - the same trap the landing-page check names.
  // The campaign views that moved to shared/js/campaign/ are read too: the
  // people view is where the O'Brien bug lived.
  const consumers = [...['sheet.js', 'app.js', 'campaign.js', 'catalog.js'].map(appPath),
    ...['notes.js', 'people.js', 'handouts.js', 'ledger.js', 'setting.js']
      .map((f) => join(repoRoot, 'shared', 'js', 'campaign', f))]
    .map((f) => readFileSync(f, 'utf8'))
    .join('\n')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/^\s*\/\/.*$/gm, '');
  check('no call site still patches the apostrophe by hand',
    !/replace\(\/'\/g, ?['"]&#39;['"]\)/.test(consumers),
    "an escHtml(...).replace(/'/g,'&#39;') is back; it breaks the handler it is meant to fix");
  check('and none still patches the double quote by hand',
    !/replace\(\/"\/g, ?'&quot;'\)/.test(consumers),
    'a second escaping pass is back; escHtml does it now');
}

await catalogEditorChecks();

import { buildStubStatements, referencedGear, referencedMosSkills, restrictionNames } from '../../../functions/api/character-creator/_lib/catalog.js';
import { comparePair, descriptionOverlap, mechanicalNumbers }
  from '../../../scripts/same-spell-lib.mjs';
import { buildProposal, perLevelDiceOf, skillGrantsFor, spellGrantsFor, psionicGrantsFor, xpTableFor,
         thresholdFor, spellLevelsForGrant, psionicCategoriesForGrant, spellNamesForGrant, grantNote,
         startingPicksFor, startingGroups, spellTraditionAllowed, spellTraditionsAllowed }
  from '../../../functions/api/character-creator/_lib/leveling.js';
// js/second-form.js and js/morphus.js are imported by checks/second-body.mjs
// now, not here: all twenty-six of their bindings this suite used were used by
// the four sections that moved there and by nothing else.
import { powerGrantsFor, remainingPowerGrants, resolvePowerPicks }
  from '../../../functions/api/character-creator/_lib/power-picks.js';
import { composeSourceBook } from '../../../scripts/source-book-lib.mjs';
import { match, stem, variants } from '../../../scripts/catalog-match-lib.mjs';
import { dice, money } from '../../../scripts/ocr-fields-lib.mjs';
import { dedupeCategories } from '../../../functions/api/character-creator/_lib/skill-picks.js';
import { relatedAllowance, validateCharacter } from '../../../functions/api/character-creator/_lib/validate-character.js';
import { abilityPickEffects } from '../../../functions/api/character-creator/_lib/ability-picks.js';
import { crossCategoryRestrictions, extractClassMarkdown, unmodelledKeys, sheetDrawableKeys,
         undrawnBonusKeys } from '../../../scripts/class-check-lib.mjs';
import { buildUserPrompt, SYSTEM_PROMPT_CACHE } from '../../../scripts/extraction-prompt.mjs';
import { statements } from '../../../scripts/sql-statements.mjs';
import { CATALOGS, coerceField } from '../js/catalog-fields.js';
import { composeClass } from '../js/compose.js';
import { evalDice, rollAttribute, rollPoolFormula, rollQuantity, poolFormulaBounds, diceBonusBounds,
         evalDiceBonus, attributeCeiling, isAttributeExpr, isAbsentAttribute }
  from '../js/dice.js';
import { LANGUAGE_OTHER, LITERACY_OTHER, isFamilyName, isRepeatableRow,
         otherRowFor, familySkillName } from '../js/language-skills.js';
import { ABILITY_GRANTS, POOL_BONUS_KEYS, VARIANT_OVERRIDES, abilityGroupCounts, abilityGroupIndexFor,
         abilityOffersPsionics, abilityRollBands, abilityRollMatches, abilityOccOptions, applyAbilities,
         applyVariant, bonusesFromSkills, categoryAllows, namedByOnly, categoryLabel, combineClasses,
         isDiceBonus, isGearChoice, isSignedDiceBonus, parseClassMarkdown, parseYaml,
         psionicsTableLeftRolling, relatedFloorStatus, relatedMinimums, rollAbilityTable, abilityRollLimit,
         abilityGroupOwed, abilityProgressionAt, abilityTouchesPool as abilityTouchesPoolOf,
         abilityGroupAllowance, abilityGroupLevels, abilityLevelGrants, sumBonusGroups, validateBonuses }
  from '../js/parser.js';
import { PSIONIC_TIER_RULES, psionicShape, psionicTierForRoll, rollPsionics, rollsForPsionics, withRolledPsionics } from '../js/psionics.js';
import { freshState, freshBuild, DRAFT_KEYS, BUILD_KEYS, KEPT_KEYS, DERIVED_KEYS, SESSION_KEYS,
         STARTING_PICK_KINDS, pruneStartingPicks } from '../js/wizard-state.js';
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';
import { appDir, repoRoot, check, section, summary, appPath, siblingAppDirs } from './harness.mjs';
import { run as environmentChecks } from './checks/environment.mjs';
import { run as catalogDataChecks } from './checks/catalog-data.mjs';
import { run as documentedCountsChecks } from './checks/documented-counts.mjs';
import { run as bookRegistryChecks } from './checks/book-registry.mjs';
import { run as renderedUiChecks } from './checks/rendered-ui.mjs';
import { run as classCheckToolChecks } from './checks/class-check-tool.mjs';
import { run as classTagChecks } from './checks/class-tag-vocabulary.mjs';
import { run as catalogMatchingChecks } from './checks/catalog-matching.mjs';
import { run as instructionPathChecks } from './checks/instruction-paths.mjs';
import { run as machineInstructionChecks } from './checks/machine-instructions.mjs';
import { run as hookRegistrationChecks } from './checks/hook-registration.mjs';
import { run as secondBodyChecks } from './checks/second-body.mjs';
import { run as namegenChecks } from './checks/namegen.mjs';
import { run as cityCreatorChecks } from './checks/city-creator.mjs';
import { run as auditMenuChecks } from './checks/audit-menus.mjs';
import { run as sequenceNumberChecks } from './checks/sequence-numbers.mjs';
import { run as sourcebookChecks } from './checks/sourcebooks-list.mjs';
import { run as catalogEditorChecks } from './checks/catalog-editor.mjs';
import { run as catalogDuplicateChecks } from './checks/catalog-duplicates.mjs';
import { run as serverPlumbingChecks } from './checks/server-plumbing.mjs';
import { run as campaignServerChecks } from './checks/campaign-server.mjs';
import { run as characterValidationChecks } from './checks/character-validation.mjs';
import { run as talentChecks } from './checks/talents.mjs';
import { run as raceAndOccupationChecks } from './checks/race-and-occupation.mjs';
import { run as skillRuleChecks } from './checks/skill-rules.mjs';
import { run as mosTotemChecks } from './checks/mos-totem.mjs';
// ---------- 1c2. Level-up skill grants ----------
// occ_related_skills.schedule recorded these for a long time and nothing read
// them. The itemisation matters: a grant knows which level earned it.
section('Level-up skill grants');
const juicerish = {
  skills: {
    occ_related_skills: {
      count: 7,
      categories: ['Physical', 'Rogue'],
      schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }],
    },
  },
};
check('a jump collects every threshold it crosses', (() => {
  const g = skillGrantsFor(juicerish, 2, 7);
  return g.length === 2 && g[0].level === 3 && g[0].count === 2 && g[1].level === 6 && g[1].count === 1;
})());
check('thresholds at or below the starting level are not re-granted',
  skillGrantsFor(juicerish, 6, 7).length === 0);
check('the level reached is included, the level left is not', (() => {
  const g = skillGrantsFor(juicerish, 3, 6);
  return g.length === 1 && g[0].level === 6;
})());
check('grants carry the class categories', (() => {
  const [g] = skillGrantsFor(juicerish, 1, 3);
  return Array.isArray(g.categories) && g.categories.includes('Rogue');
})());
check('a class with no schedule grants nothing',
  skillGrantsFor({ skills: { occ_related_skills: { count: 4 } } }, 1, 12).length === 0
  && skillGrantsFor({}, 1, 12).length === 0);
check('a malformed schedule entry does not break the run', (() => {
  const g = skillGrantsFor({ skills: { occ_related_skills: {
    schedule: [{ level: 'x', count: 2 }, { level: 4 }, { level: 5, count: -3 }] } } }, 1, 9);
  // level 4 defaults to 1 pick; level 5's negative count is floored to 1
  return g.length === 2 && g[0].count === 1 && g[1].count === 1;
})());

characterValidationChecks();


// ---------- 1c4. Psychic tiers ----------
// derive.js is a classic script, so it is loaded by evaluating it against a
// stand-in global rather than imported.
section('Psychic tiers');
const deriveGlobal = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8'))
  .call(deriveGlobal, deriveGlobal);
const D = deriveGlobal.derive;
check('derive exposes the tier helpers', !!D?.meetsTier && Array.isArray(D?.tiers));

check('a higher tier meets a lower requirement',
  D.meetsTier('master', 'major') && D.meetsTier('master', 'minor') && D.meetsTier('major', 'minor'));
check('the same tier meets its own requirement',
  D.meetsTier('minor', 'minor') && D.meetsTier('master', 'master'));
check('a lower tier does not meet a higher requirement',
  !D.meetsTier('minor', 'major') && !D.meetsTier('major', 'master') && !D.meetsTier('minor', 'master'));
// NULL min_tier means "no restriction", never "master only" — the whole
// psionic importer depends on an absent tier gating nothing.
check('no requirement is met by anyone, including a non-psychic',
  D.meetsTier('minor', null) && D.meetsTier(null, null) && D.meetsTier(null, undefined));
check('a non-psychic meets no stated requirement',
  !D.meetsTier(null, 'minor') && !D.meetsTier('', 'master'));
check('tier comparison ignores case', D.meetsTier('Master', 'MAJOR'));
check('an unrecognised requirement gates nothing', D.meetsTier('minor', 'grandmaster'));

// Three targets, not two, and both books agree: 15 / 12 / 10. This check used
// to assert `major and master at 12, everyone else at 15`, which pinned two
// wrong answers - a minor psychic at the non-psychic 15, and a master at the
// major's 12. See the table in derive.js.
check('a master psionic saves vs psionics at 10, minor and major at 12, everyone else at 15', (() => {
  const t = (tier) => D.saves({ ME: 10 }, null, tier).psionics_target;
  return t('master') === 10
      && t('major') === 12 && t('minor') === 12
      && t(null) === 15 && t(undefined) === 15;
})());
check('the tier is matched case-insensitively, as meetsTier already was', (() => {
  const t = (tier) => D.saves({ ME: 10 }, null, tier).psionics_target;
  return t('Master') === 10 && t('MINOR') === 12;
})());
check('an unrecognised tier still falls to the non-psychic target',
  D.saves({ ME: 10 }, null, 'grandmaster').psionics_target === 15);
check('the psionic save BONUS is still purely M.E.', (() => {
  const strong = D.saves({ ME: 18 }, null, 'master');
  const weak = D.saves({ ME: 18 }, null, null);
  // 2, not 3: the M.E. row gains one per TWO points, not one per point.
  return strong.psionics === weak.psionics && strong.psionics === 2;
})());
check('a stored override still wins over the derived target',
  D.saves({ ME: 10 }, { psionics_target: 8 }, 'minor').psionics_target === 8);

await catalogDuplicateChecks();

// ---------- 1c7. Gear choice groups ----------
// Books routinely say "one energy pistol of choice" where equipment_starting
// only held fixed item ids. The workaround was a placeholder catalog row named
// after the category, which no book entry can ever match — so the character
// ended up holding a weapon with no stats.
section('Gear choice groups');

const classWithGear = (yaml) => parseClassMarkdown(
  `---
id: test-class
name: Test Class
system: rifts
source_book: test-book
category: occ
equipment_starting:
${yaml}
---

## Lore

Body.
`);

check('a fixed item and a choice can sit side by side', (() => {
  const p = classWithGear(
    '  - { item_id: "back-pack", qty: 1 }\n'
    + '  - { choose: 1, from: ["ng-33-laser-pistol", "wilks-320-laser-pistol"], label: "energy pistol" }');
  return p.ok && p.data.equipment_starting.length === 2;
})(), 'errors: ' + JSON.stringify(classWithGear('  - { item_id: "back-pack" }').errors));

check('an entry with neither item_id nor choose is rejected',
  !classWithGear('  - { qty: 1 }').ok);
check('a choice asking for more than it offers is rejected',
  !classWithGear('  - { choose: 3, from: ["a-slug", "b-slug"] }').ok);
check('a choice with an empty from list is rejected',
  !classWithGear('  - { choose: 1, from: [] }').ok);
check('a choice with a non-numeric choose is rejected',
  !classWithGear('  - { choose: "one", from: ["a-slug"] }').ok);

// An entry that names an item is a fixed item, whatever else it carries — `qty`
// must not be mistaken for the start of a choice.
check('a fixed entry with a qty is not read as a choice',
  isGearChoice({ item_id: 'back-pack', qty: 2 }) === false);
check('an entry with choose and no item_id is a choice',
  isGearChoice({ choose: 1, from: ['a-slug'] }) === true);

// Every option must exist in the catalog, the same reasoning skill groups use:
// any one of them could be the option actually picked.
check('cross-reference collects fixed items and every option', (() => {
  const slugs = referencedGear({ equipment_starting: [
    { item_id: 'back-pack', qty: 1 },
    { choose: 1, from: ['ng-33-laser-pistol', 'wilks-320-laser-pistol'] },
  ] });
  return slugs.length === 3 && slugs.includes('back-pack') && slugs.includes('wilks-320-laser-pistol');
})());
check('cross-reference on a class with no equipment yields nothing',
  referencedGear({}).length === 0);

// ---------- 1c8. Draft persistence ----------
// The wizard persists the BUILD, never the catalogs it was built against. S
// holds the class, skill, spell and gear catalogs too — large, shared, and
// stale the moment they are written down.
section('Draft persistence');

// The list is js/wizard-state.js's, imported rather than read out of app.js as
// text: it is the same array the wizard saves with.
check('the persisted key list is found', DRAFT_KEYS.length > 0);

// Three hand-kept lists of "what the build is" disagreed until 2026-10-10 - the
// state literal, the draft's keys and resetBuild's assignments - and each gap
// was a bug nothing reported: programs and Talent picks were not saved, Talent
// picks survived into the next character, and `programs` did not exist on a
// resumed draft. These hold the one declaration that replaced them.
{
  const state = freshState();
  const lists = { BUILD_KEYS, KEPT_KEYS, DERIVED_KEYS, SESSION_KEYS };
  const listed = Object.values(lists).flat();
  const unlisted = Object.keys(state).filter((k) => !listed.includes(k));
  check('every key of the wizard\'s state is named in one of the four lists',
    unlisted.length === 0, unlisted.join(', '));
  const twice = listed.filter((k, i) => listed.indexOf(k) !== i);
  check('and in only one', twice.length === 0, twice.join(', '));
  const undeclared = listed.filter((k) => !(k in state));
  check('every listed key is declared with a default', undeclared.length === 0, undeclared.join(', '));

  // The half a module cannot see: app.js creating a key by assigning to it.
  // That is how `programs`, `groupUi` and four catalogs came to exist outside
  // the declaration.
  const appText = readFileSync(join(appDir, 'app.js'), 'utf8');
  // A lower-case first letter, which every key has: `S.D.C.` in a sentence is
  // not one.
  const used = [...new Set([...appText.matchAll(/(?<![\w$.])S\.([a-z_]\w*)/g)].map((m) => m[1]))];
  check('app.js is read for the keys it uses', used.length > 50, `only ${used.length}`);
  const adHoc = used.filter((k) => !(k in state));
  check('app.js uses no state key the declaration lacks', adHoc.length === 0, adHoc.join(', '));

  check('a draft is the kept keys and the build, and nothing else',
    JSON.stringify(DRAFT_KEYS) === JSON.stringify([...KEPT_KEYS, ...BUILD_KEYS]));
  const cleared = Object.keys(freshBuild());
  check('a class change clears the build and what is derived from it',
    JSON.stringify(cleared) === JSON.stringify([...BUILD_KEYS, ...DERIVED_KEYS]));
  check('and nothing a draft keeps across it', KEPT_KEYS.every((k) => !cleared.includes(k)));
  for (const k of ['programs', 'talents', 'talentGroups', 'levelTalents']) {
    check(`\`${k}\` is saved in a draft and cleared with the build`,
      DRAFT_KEYS.includes(k) && cleared.includes(k));
  }
  // Two builds must not share one array: the second character's picks would
  // land in the first's.
  const a = freshBuild(), b = freshBuild();
  a.talents.push('x'); a.rolledBonuses.combat.strike = 1;
  check('each fresh build holds its own lists', b.talents.length === 0
    && b.rolledBonuses.combat.strike === undefined && freshState().talents.length === 0);

  // And the two places that must use it, read as text because app.js is a
  // page script: the reset, and a resume onto a fresh build.
  const reset = appText.match(/function resetBuild\(\) \{[\s\S]*?\n\}/)?.[0] || '';
  check('resetBuild assigns the fresh build and names no key itself',
    /Object\.assign\(S, freshBuild\(\)\)/.test(reset) && !/\bS\.\w+\s*=/.test(reset));
  check('a draft is resumed onto a fresh build', /Object\.assign\(S, freshBuild\(\), d\.state\)/.test(appText));
  check('and saved from the imported list', /for \(const k of DRAFT_KEYS\) state\[k\] = S\[k\]/.test(appText));

  // A sum the player typed is theirs. computePools() runs whenever the pools
  // were cleared and used to re-roll starting money over it every time.
  check('a typed starting sum is part of the build', BUILD_KEYS.includes('moneyTyped') && state.moneyTyped === false);
  check('typing one marks it, and clearing the box hands it back to the dice',
    /function setBio\(key, value\) \{[\s\S]{0,160}if \(key === 'money'\) S\.moneyTyped = !!v;/.test(appText));
  check('re-rolling the pools leaves a typed sum alone, and Review\'s Reroll does not',
    /if \(force\) S\.moneyTyped = false;\s+if \(!S\.moneyTyped\) \{\s+const money = rollPoolFormula\(c\.starting_money, S\.attrs\);/.test(appText));
}

// render() is the one place a draft save is queued, "instead of remembering
// to call this from thirty handlers" - which holds for every handler that
// renders. The typed fields on Details and Review do not, on purpose: a
// render rebuilds the input the cursor is in. So the character's name, its
// campaign and every background line reached the draft only if something else
// was clicked afterwards. Asked of every inline handler, not of the four that
// were wrong, so the next field that skips render() is caught too.
{
  const appText = readFileSync(join(appDir, 'app.js'), 'utf8');
  const handlers = [...appText.matchAll(/\bon(?:change|input|click|blur|keydown|keyup)="([^"]*)"/g)].map((m) => m[1]);
  check('the wizard\'s inline handlers are found', handlers.length > 50, String(handlers.length));
  const reaches = /\b(?:render|queueDraftSave|recompose|goStep|rollBio|saveDraft|startWithClass)\(/;
  const assigning = handlers.filter((h) => /(?<![\w$.])S\.\w+\s*=[^=]/.test(h) && !reaches.test(h));
  check('no inline handler writes to the wizard\'s state without a render or a save behind it',
    assigning.length === 0, assigning.join(' | '));
  const bodyOf = (name) => {
    const at = appText.search(new RegExp('\\n(?:async\\s+)?function\\s+' + name + '\\s*\\('));
    if (at < 0) return null;
    const end = appText.slice(at + 1).search(/\n\}/);
    return appText.slice(at, at + 1 + end);
  };
  const called = new Set(handlers.flatMap((h) => [...h.matchAll(/(?<![\w$.])([A-Za-z_$][\w$]*)\s*\(/g)].map((m) => m[1])));
  const quiet = [...called].filter((name) => {
    const body = bodyOf(name);
    if (body === null) return false;
    const mutates = /\bS\.[\w.[\]'"]+\s*(?:=[^=]|\+=|-=|\+\+|--)|delete S\.|\bS\.\w+\.(?:push|splice|add|delete|set)\(/.test(body);
    if (!mutates || reaches.test(body)) return false;
    // `computePools(true); render()` is fine: the handler renders for it.
    const callers = handlers.filter((h) => new RegExp('(?<![\\w$.])' + name + '\\s*\\(').test(h));
    return callers.some((h) => !reaches.test(h.replace(new RegExp('(?<![\\w$.])' + name + '\\s*\\('), '')));
  });
  check('and every function one calls that changes the build reaches a render or a save',
    quiet.length === 0, quiet.join(', '));
  check('the typed fields queue the save themselves',
    /function setBio\(key, value\) \{[\s\S]{0,220}queueDraftSave\(\);\s+\}/.test(appText)
    && /function setDetail\(key, value\) \{\s+S\[key\] = value;\s+queueDraftSave\(\);\s+\}/.test(appText));
  check('and what they write is in the draft',
    ['charName', 'campaignId', 'newCampaign', 'bio'].every((k) => DRAFT_KEYS.includes(k)));
}

// ---------- The eight attributes and the four games ----------
// Each was typed out wherever it was needed: the attributes in nine files, the
// games in about eighteen places. The modules import one list of each now. The
// three classic scripts that cannot import keep a copy, and the SQL CHECK
// constraints cannot read JavaScript at all, so those are held to the lists
// here instead.
section('One list of attributes and one of games');
{
  const { ATTRIBUTES } = await import('../js/dice.js');
  const { GAME_SYSTEMS } = await import('../js/class-keys.js');
  check('eight attributes, in the order the books list them', ATTRIBUTES.join() === 'IQ,ME,MA,PS,PP,PE,PB,Spd');
  check('four games', GAME_SYSTEMS.join() === 'rifts,palladium-fantasy,nightbane,heroes-unlimited');

  const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    (e.isDirectory() ? walk(join(dir, e.name)) : e.name.endsWith('.js') ? [join(dir, e.name)] : []));
  const files = [join(appDir, 'app.js'), ...walk(join(appDir, 'js')), ...siblingAppDirs.flatMap(walk),
    ...walk(join(repoRoot, 'functions/api/character-creator'))];
  const rel = (f) => f.slice(repoRoot.length + 1).replace(/\\/g, '/');
  const holding = (re) => files.filter((f) => re.test(readFileSync(f, 'utf8'))).map(rel).sort();

  // A classic script is loaded by a <script> tag with no type and cannot import.
  const attrCopies = holding(/\[\s*'IQ',\s*'ME',\s*'MA',\s*'PS',\s*'PP',\s*'PE',\s*'PB',\s*'Spd'\s*\]/);
  check('the attribute list is typed out only where it is stated and in the two classic scripts',
    attrCopies.join() === 'apps/character-creator/js/dice.js,apps/character-creator/js/npc-sheets.js,apps/character-sheet/sheet.js',
    attrCopies.join(', '));
  const gameCopies = holding(/\[\s*'rifts',\s*'palladium-fantasy',\s*'nightbane',\s*'heroes-unlimited'/);
  check('the game list is typed out only where it is stated and in the one classic script',
    gameCopies.join() === 'apps/character-creator/js/class-keys.js,apps/codex/codex.js', gameCopies.join(', '));

  // The copies, held to the lists: a ninth attribute or a fifth game added to
  // the module and not to these fails here.
  const listIn = (file, re) => (readFileSync(file, 'utf8').match(re)?.[1] || '').match(/'([^']+)'/g)?.map((x) => x.slice(1, -1)) || [];
  for (const f of [appPath('sheet.js'), join(appDir, 'js', 'npc-sheets.js')]) {
    check(`${rel(f)} keeps the same eight`, listIn(f, /const ATTRS = \[([^\]]+)\]/).join() === ATTRIBUTES.join());
  }
  check('the Codex keeps the same four',
    listIn(join(appDir, '..', 'codex', 'codex.js'), /S\.system = \[([^\]]+)\]\.includes/).join() === GAME_SYSTEMS.join());

  // The database's half. A game the app offers and a CHECK refuses is a 500 on
  // the first save; `both` is a catalog value, never a class's or a campaign's.
  const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  const checks = [...schema.matchAll(/CHECK\s*\(\s*system IN \(([^)]+)\)\)/g)]
    .map((m) => m[1].match(/'([^']+)'/g).map((x) => x.slice(1, -1)));
  check('the schema states a system CHECK', checks.length > 0, `${checks.length}`);
  const strays = checks.filter((list) => list.some((v) => v !== 'both' && !GAME_SYSTEMS.includes(v)));
  check('no system CHECK accepts a game the list does not name', strays.length === 0, JSON.stringify(strays));
  const narrow = checks.filter((list) => GAME_SYSTEMS.some((g) => !list.includes(g)));
  check('and every one accepts every game on it', narrow.length === 0, `${narrow.length} of ${checks.length} are narrower`);
}

// ---------- The wizard's markup, where a value meets it ----------
// Three small ones found reading app.js end to end on 2026-10-10. None was
// reachable with today's catalog - class ids are slugs - so each is held as a
// shape, not as an exploit.
section('Wizard markup escapes what it is handed');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  // escHtml leaves an apostrophe alone, so a value inside a quoted handler
  // argument needs escJs. A class or variant id is catalog data.
  const dataIds = src.match(/on\w+="pick(?:Class|Variant|OccVariant|Occ)\('\$\{[^}]*\}'/g) || [];
  check('the class and variant pickers are found', dataIds.length >= 2, `${dataIds.length}`);
  check('a class or variant id in a handler goes through escJs',
    dataIds.every((h) => /'\$\{escJs\(/.test(h)), dataIds.filter((h) => !/escJs\(/.test(h)).join(' | '));
  check('no handler argument anywhere is escaped with the markup escaper',
    !/on\w+="[^"]*'\$\{esc\(/.test(src));
  // Review prints the starting sum through poolRow, and that is free text.
  check('a Review pool row escapes its label and its value',
    /function poolRow\(label, v\) \{[\s\S]{0,220}<span>\$\{esc\(label\)\}<\/span><b>\$\{esc\(String\(v\)\)\}<\/b>/.test(src));
  check('a Review section escapes its title', /<h3>\$\{esc\(title\)\} <span class="muted small">/.test(src));
  check('a class-card tag escapes its label', /const tag = \(label, v\) => `<span class="tag">\$\{esc\(label\)\} /.test(src));

  // Ticking a skill program re-rendered the step directly, which skips the
  // re-binding of its filter boxes and the draft save.
  const toggle = src.match(/function toggleProgram\(name\) \{[\s\S]*?\n\}/)?.[0] || '';
  check('toggleProgram is found', toggle.length > 0);
  check('ticking a program goes through render()', /\n  render\(\);\r?\n\}$/.test(toggle) && !/renderSkills\(\)[;,]/.test(toggle));

  // The roster and the campaign list moved to their own apps on 2026-09-19 and
  // seven of their helpers stayed here with no caller for three weeks, one of
  // them still exported to window. A function named once in this file is named
  // only by its own definition: nothing calls it, no handler string does, and
  // the window export does not list it.
  const fns = [...src.matchAll(/^(?:async )?function\s+([A-Za-z_$][\w$]*)\s*\(/gm)].map((m) => m[1]);
  // A property of the same name on something else is not a use; a spread is.
  const named = (n) => (src.match(new RegExp(`(?<![\\w$])(?<![\\w$)\\]]\\.)${n.replace(/\$/g, '\\$')}(?![\\w$])`, 'g')) || []).length;
  // One power row, one tiered block (2026-10-10). The four pickers each carried
  // a copy of the checkbox row and two of them a copy of the whole group block;
  // a fix to one - an unescaped value, a wrong disabled rule - reached a
  // quarter of them.
  check('the power checkbox row is written once',
    (src.match(/data-act="power"/g) || []).length === 1, `${(src.match(/data-act="power"/g) || []).length}`);
  for (const fn of ['spellLevelRows', 'psiGroupRows', 'superGroupRows', 'talentGroupRows']) {
    const body = src.match(new RegExp(`function ${fn}\\([^)]*\\) \\{[\\s\\S]*?\\n\\}`))?.[0] || '';
    check(`${fn} is a statement of what differs, handed to powerRows`,
      /return powerRows\(/.test(body) && !/<label|<input/.test(body), `${body.length} chars`);
  }
  for (const fn of ['startingTalentHtml', 'startingSuperHtml']) {
    const body = src.match(new RegExp(`function ${fn}\\(groups\\) \\{[\\s\\S]*?\\n\\}`))?.[0] || '';
    check(`${fn} is handed to tieredStartHtml`, /return tieredStartHtml\(groups, \{/.test(body) && !/Picker\./.test(body));
  }

  // The Skills step in five parts (2026-10-10). renderSkills was 425 lines with
  // four closures inside it - the MOS, the totem, the class's own skills, the
  // pick lists and the programs each read and wrote the same dozen locals, so
  // none could be changed without reading all of it.
  {
    const body = src.match(/\nfunction renderSkills\(\) \{[\s\S]*?\n\}/)?.[0] || '';
    const lines = body.split(/\r?\n/).length;
    check('renderSkills is found, and lays out parts it does not build', lines > 20 && lines < 160, `${lines} lines`);
    for (const [fn, call] of [['skillsMosHtml', 'skillsMosHtml(sk.mos)'], ['skillsTotemHtml', 'skillsTotemHtml(effective.totem)'],
      ['skillsOccPartFor', '.map(skillsOccPartFor(ctx))'], ['skillPickListFor', 'skillPickListFor(ctx)'],
      ['skillsProgramsHtml', 'skillsProgramsHtml(sk.skill_programs || null)']]) {
      check(`${fn} is its own function, and renderSkills calls it`,
        new RegExp(`\\nfunction ${fn}\\(`).test(src) && body.includes(call));
    }
    check('the step\'s checkbox rows are built in the parts, not in the layout',
      !/data-act="(?:skill|group)"/.test(body) && (src.match(/data-act="skill"/g) || []).length === 1);
  }

  check('the wizard\'s functions are found', fns.length > 150, `${fns.length}`);
  const uncalled = fns.filter((n) => named(n) < 2);
  check('no wizard function is left with no caller', uncalled.length === 0, uncalled.join(', '));
}

// ---------- Starting above level 1 ----------
// The engine is the live level-up's, run before the character exists. What is
// new is the per-level spell and psionic rules - and the honest answer for a
// class whose definition does not state them.
section('Per-level spells and psionics');
{
  const none = spellGrantsFor({}, 1, 6);
  check('a class with no magic is not applicable', none.applicable === false && none.unknown === false);
  check('and grants nothing', none.total === 0);

  // The distinction the whole feature turns on. A caster whose class never
  // recorded a per-level rule must not be shown an empty list, which reads as
  // "this class learns no spells" - it is "nobody wrote it down".
  const silent = spellGrantsFor({ magic: { type: 'innate', spells_starting: 6 } }, 1, 6);
  check('a caster stating no per-level rule is UNKNOWN, not empty',
    silent.applicable === true && silent.unknown === true);
  check('and offers nothing rather than guessing', silent.total === 0);

  const flat = spellGrantsFor({ magic: { spells_starting: 6, spells_per_level: 2 } }, 1, 4);
  check('a flat rule grants once per level gained', flat.grants.length === 3, JSON.stringify(flat.grants));
  check('itemised by the level that earned each',
    JSON.stringify(flat.grants.map((g) => g.level)) === '[2,3,4]');
  check('and totals correctly', flat.total === 6);
  check('level 1 to 1 gains nothing', spellGrantsFor({ magic: { spells_per_level: 2 } }, 1, 1).total === 0);

  const sched = spellGrantsFor({ magic: { spells_schedule: [
    { level: 2, count: 2 }, { level: 3, count: 3 }, { level: 9, count: 4 }] } }, 1, 5);
  check('a schedule counts every threshold crossed and no more',
    JSON.stringify(sched.grants.map((g) => [g.level, g.count])) === '[[2,2],[3,3]]',
    JSON.stringify(sched.grants));
  // Every grant carries a slot, because several can share a level.
  check('and each carries a slot', sched.grants.every((g) => Number.isFinite(g.slot)));
  check('a jump starting above 1 skips what it did not cross',
    spellGrantsFor({ magic: { spells_schedule: [{ level: 2, count: 2 }, { level: 5, count: 1 }] } }, 3, 6)
      .total === 1);

  // Two keys that combine is a rule nobody remembers correctly later.
  const both = spellGrantsFor({ magic: { spells_per_level: 9, spells_schedule: [{ level: 2, count: 1 }] } }, 1, 4);
  check('a schedule is the complete statement and the flat rule is ignored', both.total === 1);

  // Psionics reads the same shape from its own keys.
  // WHICH spell levels a per-level grant may draw from - a different question
  // from how many, and one the Ley Line Walker answers with a cap that tracks
  // the character rather than a fixed list.
  const llw = { magic: { spells_starting: 12, spell_levels_allowed: [1, 2, 3, 4],
                         spells_per_level: 2, spells_per_level_levels: 'up_to_character_level' } };
  check('the cap tracks the level that earned the grant',
    JSON.stringify(spellLevelsForGrant(llw, 2)) === '[1,2]');
  check('and widens as the character advances',
    JSON.stringify(spellLevelsForGrant(llw, 6)) === '[1,2,3,4,5,6]');

  // THE POINT. The per-level cap is STRICTER than the starting list at low
  // levels and they disagree on purpose: a fresh walker picks twelve spells
  // from levels 1-4, and the two it gains at level 2 may only be levels 1-2.
  // Falling back to spell_levels_allowed here would let a level-2 walker take a
  // level-4 spell, which is over-permissive in a way nobody would notice.
  check('the per-level cap is not the starting list',
    JSON.stringify(spellLevelsForGrant(llw, 2)) !== JSON.stringify(llw.magic.spell_levels_allowed));

  // A SPELL'S TRADITION (BOOK-INGEST-AUDIT F57). A level-gated pool used to
  // admit every tradition's leveled spells, so the walker above was offered the
  // warlock and ocean catalogs. Every pool builder asks spellTraditionAllowed.
  const general = { name: 'Blinding Flash', level: 1 };
  const warlockSpell = { name: 'Earth: Dowsing', level: 1, tradition: 'warlock' };
  check('an untagged spell is reachable by any level-gated pick',
    spellTraditionAllowed(general, []) && spellTraditionAllowed(general, ['ocean']));
  check('a tagged spell is NOT reachable when the class allows no traditions',
    spellTraditionAllowed(warlockSpell, []) === false);
  check('and IS when the class names its tradition, whatever the case',
    spellTraditionAllowed(warlockSpell, ['Warlock']) === true);
  check('a pre-055 banked grant (NULL allowance) keeps its old, unrestricted reach',
    spellTraditionAllowed(warlockSpell, null) === true);
  check('a class allowance is read, trimmed and lower-cased',
    JSON.stringify(spellTraditionsAllowed({ magic: { spell_traditions_allowed: [' Ocean', 'ocean', 'Cloud'] } }))
      === '["ocean","cloud"]');
  check('and a class stating none allows none',
    JSON.stringify(spellTraditionsAllowed(llw)) === '[]');
  const oceanStart = startingPicksFor({ magic: { spells_starting: 2, spell_levels_allowed: [1],
    spell_traditions_allowed: ['ocean'] } }, 'spell');
  check('a starting group carries the class allowance to the picker and the validator',
    JSON.stringify(oceanStart.groups[0].traditions) === '["ocean"]');

  // A SCHEDULE ENTRY OVERRIDES THE CLASS-WIDE RULE, because some books vary the
  // cap per level rather than by one rule. The Mystic gains four spells at
  // level 2 from spell levels 1-3 and three at level 3 from 1-4 - the
  // character's level PLUS ONE - then two per level from its own level down.
  const mystic = { magic: { spells_starting: 8, spell_levels_allowed: [1, 2],
                            spells_per_level_levels: 'up_to_character_level',
                            spells_schedule: [
                              { level: 2, count: 4, spell_levels: [1, 2, 3] },
                              { level: 3, count: 3, spell_levels: [1, 2, 3, 4] },
                              { level: 4, count: 2 }, { level: 5, count: 2 },
                              { level: 6, count: 2 }] } };
  check("an entry's own cap wins over the class rule",
    JSON.stringify(spellLevelsForGrant(mystic, 2)) === '[1,2,3]',
    JSON.stringify(spellLevelsForGrant(mystic, 2)));
  check('and it is wider than the character level, which no single rule gives',
    spellLevelsForGrant(mystic, 2).length === 3);
  check('an entry without one falls back to the class rule',
    JSON.stringify(spellLevelsForGrant(mystic, 5)) === '[1,2,3,4,5]');
  // The book's own worked examples: "a sixth level Mystic can select two new
  // spells from any of the levels 1-6".
  check("the book's sixth-level example holds",
    JSON.stringify(spellLevelsForGrant(mystic, 6)) === '[1,2,3,4,5,6]');
  const mysticGrants = spellGrantsFor(mystic, 1, 6);
  check('and the counts are the varying ones, not a flat rule',
    JSON.stringify(mysticGrants.grants.map((g) => g.count)) === '[4,3,2,2,2]',
    JSON.stringify(mysticGrants.grants.map((g) => g.count)));

  // BOOK-INGEST-AUDIT F61: a list-bound entry may ALSO keep a level cap, by
  // saying so. Three Spirit West shamans' books cap their list picks at the
  // character's own level; the Shifter's and the Lyn-Srial's do not, so the cap
  // is opt-in and a list that asks for none stays uncapped.
  {
    const books = ['Spell One', 'Spell Three', 'Spell Five'];
    const shaman = { magic: { spell_lists: { B: books }, spells_schedule: [
      { level: 2, count: 1, from_list: 'B' },
      { level: 3, count: 1, from_list: 'B', spell_levels: 'up_to_character_level' },
      { level: 4, count: 1, from_list: 'B', spell_levels: [1, 2] }] } };
    check('a list entry asking for the character-level cap gets it',
      JSON.stringify(spellLevelsForGrant(shaman, 3)) === '[1,2,3]', JSON.stringify(spellLevelsForGrant(shaman, 3)));
    check('a list entry asking for nothing stays uncapped', spellLevelsForGrant(shaman, 2) === null);
    check('and an explicit array beside a list is its cap too',
      JSON.stringify(spellLevelsForGrant(shaman, 4)) === '[1,2]');
    const listGrants = spellGrantsFor(shaman, 1, 4).grants;
    check('a from_list grant carries its resolved list, so the sheet has one to offer',
      listGrants.length === 3 && listGrants.every((g) => Array.isArray(g.from) && g.from.length === 3),
      JSON.stringify(listGrants.map((g) => g.from)));

    // The create validator: a spell over its list's cap is refused, one inside
    // it is not, and a list that asks for no cap still takes anything on it.
    const capped = { magic: { spell_lists: { B: books }, spells_schedule: [
      { level: 2, count: 1, from_list: 'B', spell_levels: 'up_to_character_level' },
      { level: 3, count: 1, from_list: 'B', spell_levels: 'up_to_character_level' }] } };
    const spellRows = { spell: new Map([['spell one', { name: 'Spell One', level: 1 }],
      ['spell three', { name: 'Spell Three', level: 3 }], ['spell five', { name: 'Spell Five', level: 5 }]]),
      psionic: new Map() };
    const capRule = (cls, level, name) => validateCharacter({ character: { level }, cls, skills: [],
      attributes: {}, powers: [{ type: 'spell', name }], powerCatalog: spellRows })
      .violations.filter((v) => v.rule === 'power_level_cap');
    check('a spell over its list\'s cap is refused', capRule(capped, 3, 'Spell Five').length > 0);
    check('one inside the cap is not', capRule(capped, 3, 'Spell Three').length === 0);
    check('and a list asking for no cap still takes anything on it', capRule(shaman, 2, 'Spell Five').length === 0);

    // The wizard and the sheet cannot share the filter - the sheet is a classic
    // script - so their shapes are pinned: a list AND its cap, both.
    const appText = readFileSync(join(appDir, 'app.js'), 'utf8');
    const sheetText = readFileSync(appPath('sheet.js'), 'utf8');
    check('the wizard\'s level-up picker applies a list and its cap together',
      /named \? \(named\.has\(String\(sp\.name\)\.toLowerCase\(\)\) && \(!levels \|\| levels\.includes\(sp\.level\)\)\)/.test(appText));
    check('so does the sheet\'s live level-up picker',
      /named \? \(named\.has\(String\(x\.name\)\.toLowerCase\(\)\) && \(!levels \|\| levels\.includes\(x\.level\)\)\)/.test(sheetText));
    check('and its banked-pick panel',
      /named \? \(named\.has\(String\(x\.name\)\.toLowerCase\(\)\)\s*&& \(!g\.spell_levels \|\| g\.spell_levels\.includes\(x\.level\)\)\)/.test(sheetText));
    check('and the sheet\'s copy of the cap rule knows the string and from_list',
      /entry\.spell_levels === 'up_to_character_level'/.test(sheetText)
      && /entry\.from_list\)+ return null/.test(sheetText));
  }
  check('totalling what the book adds up to', mysticGrants.total === 13);

  // An explicit list is honoured, and a class stating neither falls back.
  check('an explicit list wins',
    JSON.stringify(spellLevelsForGrant({ magic: { spells_per_level_levels: [1, 2] } }, 9)) === '[1,2]');
  check('with no per-level rule it falls back to the starting list',
    JSON.stringify(spellLevelsForGrant({ magic: { spell_levels_allowed: [1, 2, 3] } }, 9)) === '[1,2,3]');
  check('and a class restricting nothing is unrestricted',
    spellLevelsForGrant({ magic: { spells_per_level: 2 } }, 4) === null);
  check('no magic block is no answer', spellLevelsForGrant({}, 4) === null);

  // The picker holds each grant separately, because the caps differ per grant.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('level spells are held per grant, not as one list',
    /levelSpells\[gk\]/.test(appSrc));
  // Psionics too, once a book stated a per-level category. The old comment
  // claimed no book says which level a power was learned at; the Mystic does.
  check('and so are level psionic powers',
    /levelPsi\[gk\]/.test(appSrc));
  check('each psionic grant asks for its own categories',
    /psionicCategoriesForGrant\(S\.cls, g\.level, g\.slot\)/.test(appSrc));
  check('the batched-psionics claim is gone',
    !/no book states which level a given psionic power/.test(appSrc));
  check('and each grant asks for its own allowed levels',
    /spellLevelsForGrant\(S\.cls, g\.level, g\.slot\)/.test(appSrc));
  // Enforced, not advised: a spell level is a mechanical rule like a psychic
  // tier, not a table judgement like a skill category.
  check('an out-of-cap spell is not in the list at all',
    /\(!levels \|\| levels\.includes\(sp\.level\)\)/.test(appSrc));

  // A PSIONIC grant may name its own categories, and they REPLACE the class's
  // rather than narrowing them. The Mystic (RUE p.119) is the case: it starts
  // with Sensitive and Healing powers and gains a SUPER one at levels 4 and 8 -
  // a category a major psychic cannot otherwise take, because tier is enforced
  // by category here. Intersecting would throw the book's exception away and
  // leave an empty picker.
  const mysticPsi = { psionics: { type: 'major', powers_starting: 5,
                                  categories_allowed: ['Sensitive', 'Healing'],
                                  powers_schedule: [
                                    { level: 4, count: 1, categories: ['Super'] },
                                    { level: 8, count: 1, categories: ['Super'] }] } };
  check('a grant names its own categories',
    JSON.stringify(psionicCategoriesForGrant(mysticPsi, 4)) === '["Super"]');
  check('and they replace the class list rather than intersecting it',
    !psionicCategoriesForGrant(mysticPsi, 4).includes('Sensitive'));
  check('a level with no grant falls back to the class list',
    JSON.stringify(psionicCategoriesForGrant(mysticPsi, 5)) === '["Sensitive","Healing"]');
  check('a class with no psionics has no answer', psionicCategoriesForGrant({}, 4) === null);
  check('and one restricting nothing is unrestricted',
    psionicCategoriesForGrant({ psionics: { type: 'major' } }, 4) === null);
  const mysticPsiGrants = psionicGrantsFor(mysticPsi, 1, 8);
  check('the schedule grants only at the levels it names',
    JSON.stringify(mysticPsiGrants.grants.map((g) => g.level)) === '[4,8]');
  check('two powers across eight levels', mysticPsiGrants.total === 2);

  const psi = psionicGrantsFor({ psionics: { type: 'major', powers_per_level: 1 } }, 1, 5);
  check('psionic powers use their own keys', psi.total === 4 && psi.unknown === false);
  check('a psychic class stating no rule is unknown too',
    psionicGrantsFor({ psionics: { type: 'major', powers_starting: 3 } }, 1, 5).unknown === true);
  check('a class with no psionics is not applicable',
    psionicGrantsFor({}, 1, 5).applicable === false);

  // The proposal carries both, so one engine answers for the wizard and the
  // API. The sheet's live level-up renders named fields and ignores these.
  const cls = { hit_points_base: 'P.E. + 1d6 per level', magic: { spells_per_level: 2 } };
  const prop = buildProposal({ level: 1, hp_max: 20, skills: [] }, cls, 3);
  check('buildProposal reports the spell picks', prop.spell_picks?.total === 4);
  check('and the psionic ones', prop.psionic_picks?.applicable === false);
}

// ---------- What an empty STARTING pick means ----------
// The same distinction one level down, and it was missing. `startingGroups`
// returns [] for four different answers, so the Powers step rendered one thing
// for all four: the heading "Spells - 0/0", a filter box, and 543 checkbox rows,
// every one disabled because the allowance was zero. A picker that cannot be
// used says only that something went wrong.
section('Starting picks');
{
  const start = (magic) => startingPicksFor({ magic }, 'spell');

  check('a class with no magic is not applicable', startingPicksFor({}, 'spell').applicable === false);
  // `type: "none"` is not silence - it is a block saying the class is NOT a
  // caster. The Godling's, whose magic comes from the O.C.C. picked beside it.
  check('and neither is a block that says type none', start({ type: 'none' }).applicable === false);

  const silent = start({ type: 'druid' });
  check('a caster stating no starting count is UNKNOWN, not empty',
    silent.applicable === true && silent.unknown === true);
  check('and offers nothing rather than guessing', silent.groups.length === 0 && silent.total === 0);

  // A STATED ZERO IS AN ANSWER, not a gap: five dragon hatchlings carry
  // `spells_starting: 0` because their books say a hatchling "knows NO spells at
  // first level" and learns them by the usual means from second.
  const zero = start({ type: 'spell', spells_starting: 0 });
  check('a stated zero is known, not unknown', zero.applicable === true && zero.unknown === false);
  check('and still offers nothing', zero.total === 0 && zero.groups.length === 0);

  // Nor is a class whose spells are all GRANTED missing a count. The Shifter's
  // twenty and the Techno-Wizard's twenty-five are the whole answer.
  const granted = start({ type: 'spell', spells: ['Zap', '  ', ' Big Zap'] });
  check('an outright list answers the question too', granted.unknown === false);
  check('and is carried, trimmed, blanks dropped',
    JSON.stringify(granted.granted) === '["Zap","Big Zap"]');

  const real = start({ type: 'spell', spells_starting: 12, spell_levels_allowed: [1, 2] });
  check('a real pick comes through as groups', real.groups.length === 1 && real.total === 12);
  check('and is neither unknown nor granted', real.unknown === false && real.granted.length === 0);
  check('a split pick totals across its groups',
    start({ type: 'spell', spells_starting: 3,
            spells_starting_groups: [{ count: 1 }, { count: 2 }] }).total === 3);

  // PICKS STATED WHERE NOTHING READS THEM. Creation asks perLevelGrants from
  // level 1 and it skips every entry at or below fromLevel by design, and this
  // is creation's own reader - so a level-1 schedule entry fires nowhere at all.
  // The Wizard states six spells that way. Counted and reported rather than
  // honoured: honouring them would make a schedule a second way to say a
  // starting pick, and one way is why the *_starting keys exist.
  const misfiledMagic = { type: 'spell', spells: ['Zap'], spells_schedule: [
    { level: 1, count: 2, spell_levels: [1] }, { level: 1, count: 1, spell_levels: [3] },
    { level: 2, count: 1 }] };
  const misfiled = start(misfiledMagic);
  check('level-1 schedule entries are counted as misfiled', misfiled.misfiled === 3);
  check('and are NOT honoured as a starting pick', misfiled.total === 0);
  check('while the per-level side still reads the later ones',
    spellGrantsFor({ magic: misfiledMagic }, 1, 2).total === 1);
  check('a schedule starting at level 2 misfiles nothing',
    start({ type: 'spell', spells_starting: 1,
            spells_schedule: [{ level: 2, count: 2 }] }).misfiled === 0);

  // Psionics reads the same shape from its own keys, as it does one level up.
  check('psionics answers from powers_starting',
    startingPicksFor({ psionics: { type: 'major', powers_starting: 2 } }, 'psionic').total === 2);
  check('and from its own outright list',
    startingPicksFor({ psionics: { type: 'master', powers: ['Mend'] } }, 'psionic')
      .granted.length === 1);
}

// A level-1 pick outlived the class it was made against. Group picks are
// keyed by the group's index and nothing cleared them when the occupation,
// the variant or the race changed: an Amazon who was a Biomancer for one step
// and then a Cyber-Knight kept three spells, listed them on Review and sent
// them (seen on a local build, 2026-10-10). Run here against the function the
// wizard calls from recompose(), with real starting groups.
{
  const split = { magic: { type: 'spell', spells_starting: 3,
    spells_starting_groups: [{ count: 2, spell_levels: [1, 2] }, { count: 1, spell_levels: [3] }] } };
  const flat = { magic: { type: 'spell', spells_starting: 3, spell_levels_allowed: [1, 2] } };
  const none = {};
  const shapeOf = (cls) => (kind) => startingPicksFor(cls, kind).groups;
  const build = () => ({ ...freshBuild(), spellGroups: { 0: ['A', 'B'], 1: ['C'] }, psi: ['Mend'], talents: ['T'] });

  check('the four kinds of level-1 pick are all named, and each key is part of the build',
    STARTING_PICK_KINDS.length === 4
    && STARTING_PICK_KINDS.every((k) => BUILD_KEYS.includes(k.flat) && BUILD_KEYS.includes(k.groups))
    && BUILD_KEYS.includes('startShape'));

  const s1 = build();
  check('the first look at a build records and drops nothing',
    pruneStartingPicks(s1, shapeOf(split)).length === 0 && s1.spellGroups[0].length === 2 && s1.psi.length === 1);
  check('and nothing is dropped while the class offers the same thing',
    pruneStartingPicks(s1, shapeOf(split)).length === 0 && s1.spellGroups[1][0] === 'C');
  check('a class that offers no spells drops the spells, and says so',
    pruneStartingPicks(s1, shapeOf(none)).join() === 'spell'
    && Object.keys(s1.spellGroups).length === 0 && s1.spells.length === 0);
  check('and leaves the kinds whose offer did not change', s1.psi.length === 1 && s1.talents.length === 1);

  const s2 = build();
  pruneStartingPicks(s2, shapeOf(split));
  check('a different caster drops them too: group 0 there is not group 0 here',
    pruneStartingPicks(s2, shapeOf(flat)).join() === 'spell' && Object.keys(s2.spellGroups).length === 0);
  s2.spells = ['D'];
  check('a flat pick goes the same way when the offer changes back',
    pruneStartingPicks(s2, shapeOf(split)).join() === 'spell' && s2.spells.length === 0);

  // A draft saved before `startShape` existed has picks and no record.
  const old = build(); delete old.startShape;
  check('a draft from before this existed resumes with its picks',
    pruneStartingPicks(old, shapeOf(split)).length === 0 && old.spellGroups[0].length === 2
    && typeof old.startShape.spell === 'string');

  const appText = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('recompose() is where the wizard asks, with the composed class',
    /function recompose\(\) \{[\s\S]*?pruneStartingPicks\(S, \(kind\) => startingPicksFor\(S\.cls, kind\)\.groups\);\s+\}/.test(appText));
}

// ---------- The Attribute Bonus Chart ----------
// Palladium Fantasy printed 16, transcribed column by column. Nothing else in
// the app checks derive.js against the book, and the last time this file was
// wrong it was wrong EVERYWHERE: it applied `v - 15` to every row and called
// that "the standard Palladium tables", which left every parry, dodge, strike
// and save at roughly double the printed value and let M.A. and P.B. climb past
// 100%. A table that is wrong is not a bug anybody reports; it is a character
// sheet that is quietly generous.
//
// The chart runs 16 to 30. Below 16 the book gives nothing, and above 30 the
// app extends each row by its own step, which is a house rule and is checked
// separately below.
section('Attribute Bonus Chart');
{
  //                        16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
  const PRINTED = {
    iq_skills:   [ 2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16],
    me_psionic:  [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    me_insanity: [ 1,  1,  2,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13],
    ma_trust:    [40, 45, 50, 55, 60, 65, 70, 75, 80, 84, 88, 92, 94, 96, 97],
    ps_damage:   [ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15],
    pp_combat:   [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    pe_coma_pct: [ 4,  5,  6,  8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
    pe_magic:    [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    pb_charm:    [30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 83, 86, 90, 92],
  };

  // Read off the source rather than through a public helper: `chart()` is
  // internal, and what needs pinning is the DATA, one column at a time, so a
  // failure names the attribute value that moved.
  const src = readFileSync(join(appDir, 'js', 'derive.js'), 'utf8');
  for (const [name, want] of Object.entries(PRINTED)) {
    const m = new RegExp(`${name}:\\s*row\\(\\[([^\\]]*)\\]`).exec(src);
    const got = m ? m[1].split(',').map((n) => Number(n.trim())) : null;
    check(`${name} has all fifteen columns`, got && got.length === 15,
      got ? `${got.length}` : 'row not found in derive.js');
    if (!got || got.length !== 15) continue;
    const bad = want.map((v, i) => (got[i] === v ? null : `${16 + i}: ${got[i]} not ${v}`))
      .filter(Boolean);
    check(`and every one matches printed 16`, bad.length === 0, `${name} - ${bad.join(', ')}`);
  }

  // The P.P. row drives strike as well as parry and dodge, which the book gives
  // as two rows of identical numbers. One row in the app, and it must stay
  // equal to the printed pair rather than drifting into a second copy.
  check('strike shares the parry and dodge row, as the book prints it',
    JSON.stringify(PRINTED.pp_combat) === JSON.stringify(PRINTED.pe_magic));

  // Below the chart the book gives nothing, and the app must not invent it.
  check('an attribute of 15 earns nothing', D.bio({ IQ: 15 }).iq_skill_bonus_pct === 0);
  check('and 16 earns the first step', D.bio({ IQ: 16 }).iq_skill_bonus_pct === 2);

  // A column read end to end through the real function, not just off the source.
  check('M.A. 24 invokes trust at the printed 80%', D.bio({ MA: 24 }).invoke_trust_pct === 80);
  check('and P.B. 24 charms at 70%', D.bio({ PB: 24 }).charm_impress_pct === 70);

  // Above 30 is a HOUSE RULE and is labelled as one - the book stops, dragons
  // do not. Each row continues by the step it ends on.
  check('above 30 the row continues by its own step',
    D.bio({ IQ: 32 }).iq_skill_bonus_pct === 18, `${D.bio({ IQ: 32 }).iq_skill_bonus_pct}`);

  // The two percentile rows are capped at the same 98% the skills use, or a
  // high-M.A. dragon would talk its way past certainty.
  const big = D.bio({ MA: 60, PB: 60 });
  check('and the percentile rows stop at 98%',
    big.invoke_trust_pct <= 98 && big.charm_impress_pct <= 98, JSON.stringify(big));
}

// ---------- Starting XP ----------
// A level-6 character with 0 XP reads as under-levelled to the XP endpoint, and
// the very next award proposes a level-up it has already had.
section('Starting XP');
{
  const table = xpTableFor({});
  check('the threshold is the level’s own entry', thresholdFor(table, 1) === 0);
  check('and rises with the level', thresholdFor(table, 6) === table[5]);
  check('past the cap is null, not zero', thresholdFor(table, table.length + 1) === null);

  // A class may state its own curve, and the create path must read the same
  // table the level-up path does or the two disagree about what level 6 costs.
  const own = xpTableFor({ xp_table: [0, 100, 200, 300] });
  check('a class curve wins', thresholdFor(own, 3) === 200);
  check('and its length caps the level', thresholdFor(own, 5) === null);

  const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'characters.js'), 'utf8');
  check('the create path clamps the level to the class table', /Math\.min\(/.test(src) && /xpTable\.length/.test(src));
  check('and sets XP from the threshold rather than the client',
    /thresholdFor\(xpTable, level\)/.test(src) && !/b\.xp/.test(src));
  check('and validates at the level being created, not at 1',
    /character: \{ level[,\s]/.test(src));
  check('unspent picks are banked on create', /insertGrantStatements\(env, row\.id, remaining\)/.test(src));
  check('and the allowance is recomputed server-side rather than trusted',
    /skillGrantsFor\(cls, 1, level\)/.test(src));

  // A warning nothing hands the number to is a warning that never fires. The
  // audit is the one caller positioned to notice, so it has to SELECT xp and
  // pass it - which is the shape of failure this repo has been bitten by
  // before, under 'a field the prompt does not mention'.
  const auditSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'admin', 'audit.js'), 'utf8');
  check('the audit selects xp', /characters\.xp/.test(auditSrc));
  check('and passes it to the validator', /level: row\.level, xp: row\.xp/.test(auditSrc));

  // -- an occupation's ATTRIBUTE MINIMUMS have to survive it too -------------
  //
  // Same shape as the xp_table bug and found the same way: `sumBonusGroups`
  // merged attributes, combat, saves, pools and at_level, and dropped
  // attribute_minimums on the floor. An occupation's requirement vanished the
  // moment a race was composed with it, and the Attributes step stopped saying
  // a character did not qualify. Only two classes state any - the Juicer's
  // P.S. 22 and the Crazy's P.S. 19 / P.P. 17 - and both lost them.
  {
    const race = { id: 'r', name: 'R', category: 'rcc', system: 'rifts' };
    const occ = { id: 'o', name: 'O', category: 'occ', system: 'rifts',
      bonuses: { attribute_minimums: { PS: 22 } } };
    const composed = composeClass({ rcc: race, occ, character: {} });
    check('an occupation\u2019s attribute minimums survive composition',
      composed?.bonuses?.attribute_minimums?.PS === 22,
      JSON.stringify(composed?.bonuses?.attribute_minimums));

    // A minimum is not a bonus: two of them do not add up. A class wanting
    // P.S. 22 beside one wanting P.S. 19 wants a character with P.S. 22.
    const strictRace = { ...race, bonuses: { attribute_minimums: { PS: 19, PP: 17 } } };
    const both = composeClass({ rcc: strictRace, occ, character: {} });
    check('and the stricter of two wins rather than the sum',
      both?.bonuses?.attribute_minimums?.PS === 22,
      JSON.stringify(both?.bonuses?.attribute_minimums));
    check('while an attribute only one of them names is kept',
      both?.bonuses?.attribute_minimums?.PP === 17,
      JSON.stringify(both?.bonuses?.attribute_minimums));

    // And a pairing that states none must not invent an empty block.
    const none = composeClass({ rcc: race, occ: { ...occ, bonuses: undefined }, character: {} });
    check('and neither stating one leaves nothing behind',
      none?.bonuses?.attribute_minimums === undefined,
      JSON.stringify(none?.bonuses));
  }

  // -- an OCCUPATION's curve has to survive composition ----------------------
  //
  // Palladium names its experience charts by O.C.C. - "Knight & Noble", "Thief
  // & Merchant" - because experience comes from what you do. `combineClasses`
  // carries a named list of keys forward from the
  // occupation, and `xp_table` was not on it, so since #210 (race primary,
  // occupation second) a Knight's curve was dropped on EVERY Palladium
  // character and the race's absent table won. Measured here rather than read
  // off the source, because the failure was silent: no error, no warning, just
  // the house-rule default quietly standing in.
  const race = { id: 'r', name: 'R', category: 'rcc', system: 'palladium-fantasy' };
  const occ = { id: 'o', name: 'O', category: 'occ', system: 'palladium-fantasy',
    xp_table: [0, 2100, 4200, 8400] };
  const composed = composeClass({ rcc: race, occ, character: {} });
  check('an occupation’s xp_table survives composition',
    JSON.stringify(composed.xp_table) === JSON.stringify(occ.xp_table),
    JSON.stringify(composed.xp_table));
  check('and it is the table the level thresholds come from',
    thresholdFor(xpTableFor(composed), 2) === 2100);

  // A race MAY state its own ladder - Nightbane printed 233 prints one for the
  // Hunter, the Wampyr and the vampires - and it is used when the race is played
  // ALONE. In a pairing the OCCUPATION's ladder wins, because Palladium names
  // its charts by O.C.C. Nate's call, 2026-09-17 (docs/surveys/nightbane-core.md,
  // "Follow-up decisions after the import"). This check read 'a race that
  // states its own curve still wins' until then.
  const ladderRace = { ...race, xp_table: [0, 5001, 10001, 20001] };
  const paired = composeClass({ rcc: ladderRace, occ, character: {} });
  check('when both halves state a ladder, the occupation’s wins',
    JSON.stringify(paired.xp_table) === JSON.stringify(occ.xp_table),
    JSON.stringify(paired.xp_table));
  // UNLESS THE RACE SAYS IT KEEPS ITS OWN (BOOK-INGEST-AUDIT F122): Phase
  // World's Draconid takes an occupation's powers and "in either case" levels
  // on the Draconid's table.
  const keeper = { ...ladderRace, keeps_xp_table: true };
  check('a race that keeps its ladder levels on it beside an occupation that states one',
    JSON.stringify(composeClass({ rcc: keeper, occ, character: {} }).xp_table)
      === JSON.stringify(ladderRace.xp_table));
  check('but not beside an occupation that supersedes the race',
    JSON.stringify(composeClass({ rcc: keeper, occ: { ...occ, supersedes_race: true }, character: {} }).xp_table)
      === JSON.stringify(occ.xp_table));
  check('and the flag on a race with no ladder leaves the occupation\'s standing',
    JSON.stringify(composeClass({ rcc: { ...race, keeps_xp_table: true }, occ, character: {} }).xp_table)
      === JSON.stringify(occ.xp_table));
  {
    const LF = String.fromCharCode(10);
    const mkc = (cat, ...lines) => parseClassMarkdown(
      ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', `category: ${cat}`, 'tags: []',
       ...(cat === 'occ' ? ['occ_group: men-of-arms'] : []), ...lines, '---', '', '## Lore', '', 'x', ''].join(LF));
    const ladder = 'xp_table: [0, 2201, 4401, 8801, 17601, 27701, 37801, 54001, 76001, 101001, 151001, 201001, 251001, 301001, 401001]';
    check('the parser takes the flag on a race with a ladder',
      mkc('rcc', ladder, 'keeps_xp_table: true').ok && mkc('rcc', ladder, 'keeps_xp_table: true').warnings.length === 0);
    check('refuses it on an occupation, and as anything but true',
      !mkc('occ', ladder, 'keeps_xp_table: true').ok && !mkc('rcc', ladder, 'keeps_xp_table: false').ok);
    check('and warns when the race has no ladder to keep',
      mkc('rcc', 'keeps_xp_table: true').warnings.some((w) => w.includes('no ladder to keep')));
  }
  const alone = composeClass({ rcc: ladderRace, character: {} });
  check('a race played alone levels on its own ladder',
    thresholdFor(xpTableFor(alone), 2) === 5001 && thresholdFor(xpTableFor(alone), 4) === 20001,
    JSON.stringify(alone?.xp_table));
  const silentJob = composeClass({ rcc: ladderRace, occ: { ...occ, xp_table: undefined }, character: {} });
  check('and so does a race paired with an occupation that states none',
    thresholdFor(xpTableFor(silentJob), 2) === 5001, JSON.stringify(silentJob?.xp_table));
  const neither = composeClass({ rcc: race, occ: { ...occ, xp_table: undefined }, character: {} });
  check('and neither stating one falls back to the default',
    thresholdFor(xpTableFor(neither), 2) === thresholdFor(xpTableFor({}), 2));

  // The wizard's starting-level picker read the RACE, so it sized itself and
  // priced the level off a table Palladium characters never have.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const picker = appSrc.slice(appSrc.indexOf('function startingLevelPicker()'),
    appSrc.indexOf('function setStartingLevel'));
  check('the starting-level picker prefers the composed class',
    /S\.cls \|\| applyVariant\(S\.rcc/.test(picker));
  check('and no longer reads the race directly for a threshold',
    !/xpTableFor\(applyVariant\(S\.rcc/.test(picker), 'still calls xpTableFor on the race');

  // `xp_table` is a modelled key. Reported UNMODELLED, the instruction attached
  // is to delete it or change the app, and both would break a working field.
  check('xp_table is a known class key',
    !unmodelledKeys({ id: 'x', name: 'X', xp_table: [0, 1] }).includes('xp_table'));
}

// ---------- The wizard's step list ----------
// A draft stores `step` as an INDEX into STEPS, so changing the list silently
// re-points every draft in flight. The list, its version, and the mapping that
// carries an old index forward are pinned together here because they are only
// correct with respect to each other.
section('Wizard steps');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  const steps = src.match(/const STEPS = \[([^\]]*)\]/)?.[1]
    ?.match(/'([^']+)'/g)?.map((x) => x.slice(1, -1)) || [];

  check('STEPS is found in app.js', steps.length > 0);
  check('eleven steps', steps.length === 11, String(steps.length));
  // The whole point of PR 13: the race is chosen, then the dice are rolled,
  // then the occupation is chosen against a stat block that already exists.
  check('Race comes before Attributes',
    steps.indexOf('Race') >= 0 && steps.indexOf('Race') < steps.indexOf('Attributes'));
  check('Occupation comes after Attributes',
    steps.indexOf('Occupation') > steps.indexOf('Attributes'));
  check('Occupation comes before Skills',
    steps.indexOf('Occupation') < steps.indexOf('Skills'));
  // The Morphus (survey D5) reads the COMPOSED class, which an occupation can
  // bring a second form to, and the attributes its preview folds.
  check('Morphus comes right after Occupation',
    steps.indexOf('Morphus') === steps.indexOf('Occupation') + 1);
  check('and before Skills', steps.indexOf('Morphus') < steps.indexOf('Skills'));
  check('the combined Class step is gone', !steps.includes('Class'));

  // Advancement sits after the level-1 character is COMPLETE, because that is
  // the input buildProposal takes. Before Powers it would run against a
  // character whose psionic tier an ability could still change.
  check('Advancement comes after Powers',
    steps.indexOf('Advancement') > steps.indexOf('Powers'));
  check('and before Details',
    steps.indexOf('Advancement') < steps.indexOf('Details'));

  // Steps are addressed by name now. A bare goStep(4) in a nav button is how
  // inserting a step used to break three others silently.
  check('no step transition is a bare index',
    !/goStep\(\s*\d+\s*\)/.test(src.replace(/^\s*\/\/.*$/gm, '')));

  const version = Number(src.match(/const STEPS_VERSION = (\d+);/)?.[1]);
  check('the step list carries a version', version === 4, String(version));

  // Each version is ONE insertion and the migrations chain, so a version-1
  // draft runs through both. Off by one here resumes every in-flight draft
  // onto the wrong screen, which is the whole reason this is pinned.
  const migrations = eval(src.match(/const STEP_MIGRATIONS = (\[[\s\S]*?\n\];)/)?.[1]
    ?.replace(/\/\/[^\n]*/g, '').replace(/;$/, '') || 'null');
  check('the migration chain is found',
    Array.isArray(migrations) && migrations.length === version - 1);

  // Same walk migrateDraft does: start at the draft's version, apply each
  // migration from there.
  const migrate = (i, from) => {
    let step = i;
    for (let v = from; v < version; v++) step = migrations[v - 1](step);
    return step;
  };

  // From version 1 - the original eight-step list.
  check('System stays put', migrate(0, 1) === 0);
  check('the old Class step resumes on Race', migrate(1, 1) === steps.indexOf('Race'));
  check('Attributes does not move', migrate(2, 1) === steps.indexOf('Attributes'));
  check('the old Skills step shifts by one', migrate(3, 1) === steps.indexOf('Skills'));
  check('and the old Review lands on Review', migrate(7, 1) === steps.indexOf('Review'));

  // From version 2 - the nine-step list, before Advancement existed.
  check('a v2 Powers step does not move', migrate(6, 2) === steps.indexOf('Powers'));
  check('a v2 Details step shifts by one', migrate(7, 2) === steps.indexOf('Details'));
  check('a v2 Review step shifts too', migrate(8, 2) === steps.indexOf('Review'));

  // From version 3 - the ten-step list, before the Morphus existed.
  check('a v3 Occupation step does not move', migrate(3, 3) === steps.indexOf('Occupation'));
  check('a v3 Skills step shifts by one', migrate(4, 3) === steps.indexOf('Skills'));
  check('a v3 Review step lands on Review', migrate(9, 3) === steps.indexOf('Review'));
  check('and a v1 Review still lands on Review, through three migrations', migrate(7, 1) === steps.indexOf('Review'));

  // A migrated draft must not land on a step that did not exist when it was
  // saved: there is nothing on it the draft could have filled in, and
  // stepApplies would walk straight off it for most characters.
  //
  // A version-2 draft stopped ON the Occupation step is the exception and stays
  // there, because that step already existed for it. Only Advancement is new.
  const occupation = steps.indexOf('Occupation');
  const advancement = steps.indexOf('Advancement');
  const morphusStep = steps.indexOf('Morphus');
  check('no version-1 index lands on a step version 1 never had',
    ![0, 1, 2, 3, 4, 5, 6, 7].some((i) => [occupation, advancement, morphusStep].includes(migrate(i, 1))));
  check('no version-2 index lands on Advancement or the Morphus',
    ![0, 1, 2, 3, 4, 5, 6, 7, 8].some((i) => [advancement, morphusStep].includes(migrate(i, 2))));
  check('no version-3 index lands on the Morphus',
    ![0, 1, 2, 3, 4, 5, 6, 7, 8, 9].some((i) => migrate(i, 3) === morphusStep));
  check('but a version-2 Occupation step stays where it is',
    migrate(occupation, 2) === occupation);

  // A missed minimum BLOCKS here, since UI-AUDIT F54. It used to warn, which
  // meant the gate a player met depended only on the order they chose their
  // classes in - and the save refuses it either way, so "you may continue" was
  // telling them something untrue.
  //
  // These three checks asserted the OPPOSITE until 2026-09-12. They are inverted
  // rather than deleted, because the thing worth pinning is that the two gates
  // AGREE, and that is exactly what a future tidy would undo.
  const occBlocker = src.match(/function occBlocker\(\)[\s\S]*?\n}/)?.[0] || '';
  check('occBlocker is found', occBlocker.length > 0);
  check('an ability without its occupation blocks the Occupation step', /abilityOccOptions/.test(occBlocker));
  check('and so does a missed class minimum', /minimumShortfalls\(\)/.test(occBlocker));
  // Without an occupation there is no shortfall panel and no re-roll button, so
  // a block there would be a disabled button with nowhere to go.
  check('but only once an occupation is chosen, where the re-roll lives',
    /S\.occ \? minimumShortfalls\(\) : \[\]/.test(occBlocker));
  check('and it says the save would refuse, which is the reason it blocks',
    /the save would be refused/.test(occBlocker));
  // The other half of the pair: the Attributes step has always gated on it.
  check('the Attributes step still gates on the same shortfall',
    // Through attributesBlocker() since 2026-10-10, which the rail reads too;
    // the F125 section runs that function against an unmet minimum.
    /const canNext = !attrWhy;/.test(src) && /why: attrWhy \} = attributesBlocker\(\)/.test(src));

  // One attribute, with its own dice. Not the whole block, and never raised to
  // the minimum without dice - see docs/plans/13-rcc-first-wizard.md.
  const reroll = src.match(/function rerollForMinimum\(attr\)[\s\S]*?\n}/)?.[0] || '';
  check('rerollForMinimum is found', reroll.length > 0);
  check('it re-rolls the one attribute', /setRoll\(attr\)/.test(reroll));
  check('it records the assist', /S\.minRerolls\.push/.test(reroll));
  check('and it never assigns the minimum instead', !/S\.attrs\[attr\]\s*=/.test(reroll));
}
for (const k of ['step', 'attrs', 'attrMethods', 'groupPicks', 'gearPicks', 'equipment', 'bio', 'pools']) {
  check(`draft persists \`${k}\``, DRAFT_KEYS.includes(k));
}
// A draft carrying a copy of the catalogs would be large, and would restore a
// snapshot of content that has since been edited or re-imported.
for (const k of ['items', 'classes', 'skillCatalog', 'spellCatalog', 'psiCatalog', 'campaigns', 'existing', 'itemRedirects']) {
  check(`draft does NOT persist \`${k}\``, !DRAFT_KEYS.includes(k));
}
// The class is stored as an id and re-resolved on restore, so an edited class
// definition takes effect rather than being shadowed by the draft.
check('draft does NOT persist the resolved class object', !DRAFT_KEYS.includes('cls'));
// Derived from the class and catalog on every render; persisting it would
// restore options that no longer match the class.
check('draft does NOT persist derived gear choices', !DRAFT_KEYS.includes('gearChoices'));

// ---------- 1c11. Class bonuses ----------
// What a class GRANTS mechanically. `natural_abilities` and
// `level_progression.grants` are the book's wording and display-only, so a
// Dragon's "+2 to P.S." and "+1 attack at level 5" were prose nothing could act
// on. These are numbers the sheet adds up.
section('Class bonuses');

const withBonuses = (yaml) => parseClassMarkdown(
  `---
id: test-class
name: Test Class
system: rifts
source_book: test-book
category: occ
${yaml}
---

## Lore

Body.
`);

check('a full bonuses block parses', (() => {
  const p = withBonuses(`bonuses:
  attributes: { PS: 2 }
  combat: { attacks: 1, strike: 2 }
  saves: { spell_magic: 2 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }`);
  return p.ok && p.data.bonuses.attributes.PS === 2 && p.data.bonuses.at_level.length === 1;
})(), JSON.stringify(withBonuses('bonuses:\n  attributes: { PS: 2 }').errors));

// A bonus filed under a key nothing reads would silently do nothing, which is
// the whole failure this validation exists to prevent.
check('an unknown attribute is rejected', !withBonuses('bonuses:\n  attributes: { STR: 2 }').ok);
check('a non-numeric bonus is rejected', !withBonuses('bonuses:\n  attributes: { PS: "two" }').ok);
check('an at_level entry without a level is rejected',
  !withBonuses('bonuses:\n  at_level:\n    - { combat: { attacks: 1 } }').ok);
check('a zero bonus warns rather than fails', (() => {
  const p = withBonuses('bonuses:\n  combat: { strike: 0 }');
  return p.ok && p.warnings.some((x) => /will do nothing/.test(x));
})());
check('an unrecognised group warns rather than fails', (() => {
  const p = withBonuses('bonuses:\n  skills: { Climbing: 10 }');
  return p.ok && p.warnings.some((x) => /not a recognised group/.test(x));
})());

// derive.js is a classic script, loaded the way the browser loads it.
const deriveWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(deriveWindow, deriveWindow);
const D2 = deriveWindow.derive;
const derive = D2;

const dragon = { bonuses: { attributes: { PS: 2 }, combat: { attacks: 1 },
                            at_level: [{ level: 5, combat: { attacks: 1 } }] } };

check('at_level bonuses only count once their level is reached',
  D2.classBonuses(dragon, 1).combat.attacks === 1 && D2.classBonuses(dragon, 5).combat.attacks === 2);
check('a class with no bonuses yields empty groups',
  Object.keys(D2.classBonuses({}, 9).combat).length === 0);

// The attribute bonus is NOT stored on the character — it is added on the way
// past, so everything derived has to read through effective().
check('effective() adds the class bonus without touching the input', (() => {
  const raw = { PS: 24 };
  const eff = D2.effective(raw, D2.classBonuses(dragon, 1));
  return eff.PS === 26 && raw.PS === 24;
})());
check('a bonus to an attribute the character lacks is ignored',
  D2.effective({}, { attributes: { PS: 2 } }).PS === undefined);

// P.S. 24 gives a damage bonus of 9; the class's +2 must carry through to 11,
// or the bonus is decorative.
check('an attribute bonus reaches the derived numbers',
  D2.combat({ PS: 24 }, null, D2.classBonuses(dragon, 1)).damage_bonus === 11);
check('a direct combat bonus is added on top',
  D2.combat({ PS: 10 }, null, D2.classBonuses(dragon, 1)).attacks === 3);
check('a human override still wins over both',
  D2.combat({ PS: 10 }, { attacks: 7 }, D2.classBonuses(dragon, 1)).attacks === 7);
// Asserted as an equivalence rather than a literal: the point is that the two
// call shapes agree, and pinning the number here just duplicates [1c17].
check('omitting bonuses behaves exactly as passing none',
  D2.combat({ PP: 18 }).strike === D2.combat({ PP: 18 }, null, null).strike
  && D2.combat({ PP: 18 }).strike === 2);

// The sheet shows one number; the hover has to be able to say why.
check('parts() separates the attribute half from the class half', (() => {
  const p = D2.parts('combat', { PS: 24 }, D2.classBonuses(dragon, 1));
  return p.damage_bonus.attrs === 9 && p.damage_bonus.from_class === 2
      && p.attacks.attrs === 2 && p.attacks.from_class === 1;
})());

// The wizard read these at a literal level 1 in six places, under a comment
// saying it "only ever builds a level 1 character". It has built higher ones
// since the Advancement step. Nothing on screen was wrong: on 2026-10-10 no
// published class and no skill carried a level-gated ATTRIBUTE bonus (199
// classes gate combat and saves, which these screens do not print). The
// first one that does would have shown level-1 numbers beside a sheet that
// shows the real ones.
{
  const later = { bonuses: { attributes: { PS: 1 }, at_level: [{ level: 4, attributes: { PS: 2 } }] } };
  check('a level-gated attribute bonus is read at the level asked for',
    D2.classBonuses(later, 1).attributes.PS === 1 && D2.classBonuses(later, 4).attributes.PS === 3);
  const appText = readFileSync(join(appDir, 'app.js'), 'utf8');
  const calls = [...appText.matchAll(/derive\.classBonuses\(([^,()]+(?:\([^()]*\))?),\s*([^,()]+)/g)];
  check('the wizard\'s class-bonus reads are found', calls.length >= 6, String(calls.length));
  const atOne = calls.filter((m) => m[2].trim() === '1');
  check('exactly one of them is still at level one',
    atOne.length === 1, atOne.map((m) => m[0]).join(' | '));
  check('and it is the I.Q. bonus on the skills held since level one, read with level-one skills',
    /function skillsAtLevelOne\(\) \{[\s\S]{0,900}derive\.classBonuses\(skillBonusClass\(1\), 1, rolledAll\(\)\)\)\.iq_skill_bonus_pct/.test(appText));
  check('the skills\' own schedule is read at the same level as the class\'s',
    /function skillBonusClass\(level = S\.level\) \{[\s\S]{0,900}bonusesFromSkills\(rows, level, S\.cls\)/.test(appText));
}

// ---------- 1c13. Class template ----------
// A starting point for writing a class by hand. The one thing that must hold is
// that it PARSES on arrival — a template that fails validation the moment it is
// created teaches you nothing about which of your own edits broke it.
section('Class template');

const tplWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'class-template.js'), 'utf8')).call(tplWindow, tplWindow);
const classTemplate = tplWindow.classTemplate;

for (const kind of ['occ', 'rcc']) {
  const md = classTemplate(kind, {
    id: 'test-' + kind, name: 'Test Name', system: 'rifts', sourceBook: 'Rifts Ultimate Edition',
  });
  const p = parseClassMarkdown(md);
  check(`the ${kind} template parses clean`, p.ok && !p.warnings.length,
    JSON.stringify([...p.errors, ...p.warnings]));
  check(`the ${kind} template carries the values it was given`,
    p.data.id === 'test-' + kind && p.data.name === 'Test Name'
    && p.data.system === 'rifts' && p.data.source_book === 'Rifts Ultimate Edition');
  check(`the ${kind} template is the right category`, p.data.category === kind);
}

// The two shapes genuinely differ — a race rolls its attributes, a character
// class has minimums — which is why there are two templates rather than one
// with half of it commented out.
const occTpl = classTemplate('occ', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' });
const rccTpl = classTemplate('rcc', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' });
check('the OCC template has requirements and hit points, not racial dice', (() => {
  const d = parseClassMarkdown(occTpl).data;
  return d.attribute_requirements && d.hit_points_base && !d.attribute_dice;
})());
check('the RCC template has racial dice and M.D.C., not hit points', (() => {
  const d = parseClassMarkdown(rccTpl).data;
  return d.attribute_dice?.PS && d.mdc_base && !d.hit_points_base;
})());

// The fiddly blocks are the reason hand-authoring is worth supporting, so the
// template has to show their shape even while commented out.
for (const [what, re] of [['variants', /# variants:/], ['bonuses', /^bonuses:/m],
                          ['a gear choice', /choose: 1, label:/], ['a skill choice-group', /choose: 2, from:/]]) {
  check(`the RCC template shows how to write ${what}`, re.test(rccTpl));
}
check('an unknown kind falls back to the OCC shape',
  parseClassMarkdown(classTemplate('nonsense', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' })).data.category === 'occ');

// ---------- 1c11b. The class prompt covers the schema ----------
// A field the schema supports and the prompt never mentions is a field that
// never gets extracted. `variants` shipped without being added here, so the
// first real two-stage class came back with BOTH stat blocks dropped — the
// numbers the entry exists for.
section('Class prompt covers the schema');
{
  const prompt = readFileSync(
    join(repoRoot, 'scripts', 'extraction-prompt.mjs'), 'utf8');
  for (const key of ['variants', 'bonuses', 'attribute_dice', 'equipment_starting',
                     'level_progression', 'psionics', 'magic', 'special_abilities']) {
    check(`the prompt documents \`${key}\``, prompt.includes(key));
  }
  // The two rules a variant is easy to get wrong on.
  check('the prompt says what a variant may override', /may override ONLY/.test(prompt));
  check('the prompt says shared material stays at the top level', /stays at the top level/.test(prompt));

  // A bonus filed under a key derive.js does not produce is stored and never
  // read. The first real class came back with four of them — roll_with_punch,
  // pull_punch, magic, illusionary_magic — all silently inert.
  const deriveWin = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(deriveWin, deriveWin);
  const realKeys = [
    ...Object.keys(deriveWin.derive.combat({})),
    ...Object.keys(deriveWin.derive.saves({})),
  ];
  for (const key of ['attacks', 'strike', 'parry', 'dodge', 'roll', 'spell_magic', 'ritual_magic', 'horror_factor']) {
    check(`the prompt lists the real bonus key \`${key}\``, prompt.includes(key) && realKeys.includes(key));
  }

  // The pool group, which is the only one taking dice, and the only one whose
  // omission from the prompt would send a "plus 4D6" into ppe_base — where it
  // parses to NULL and the character gets no P.P.E. at all.
  check('the prompt documents the pools bonus group', /pools:\s+hp, sdc, mdc, ppe, isp/.test(prompt));
  check('the prompt tells the model each class states its own power list',
    /copy the options INTO this class/.test(prompt));
  check('the prompt documents a fragment carrying bonuses', /repeatable: true/.test(prompt));
  check('and says a pool grant is a bonus, never a base',
    /never a pool base/.test(prompt));
  check('and warns against putting a pool bonus in at_level',
    /do not put a pool bonus in at_level/i.test(prompt));
  check('the prompt warns that an unknown bonus key does nothing',
    /silently does nothing/.test(prompt));

  // "Use ONLY these keys" was written when derive.js produced nine saves and
  // seven combat numbers, and it went on saying so: a model following it on
  // 2026-10-10 would have dropped `pull_punch`, which 247 shipped classes
  // state. So the two lists are held from both sides - every key a shipped
  // class uses is offered, and nothing is offered that the sheet has no field
  // for - and the variant sentence is held to the parser's own list.
  const listed = (label) => (prompt.match(new RegExp(`\\n {6}${label}:([\\s\\S]*?)\\n {6}(?:saves|pools):`))?.[1] || '')
    .replace(/\([^)]*\)/g, ' ').match(/[a-z][a-z_]+/g) || [];
  const offered = { combat: listed('combat'), saves: listed('saves') };
  check('the prompt\'s combat and save lists are found', offered.combat.length > 5 && offered.saves.length > 5,
    JSON.stringify(offered));
  const sheetText = readFileSync(appPath('sheet.js'), 'utf8');
  const fieldKeys = (name) => [...(sheetText.match(new RegExp(`const ${name} = \\[([\\s\\S]*?)\\n\\s*\\];`))?.[1] || '')
    .matchAll(/\['([a-z_]+)',/g)].map((m) => m[1]);
  // `attacks_base` has no field of its own: derive.js folds it into `attacks`.
  const hasField = { combat: [...fieldKeys('COMBAT_FIELDS'), 'attacks_base'], saves: fieldKeys('SAVE_FIELDS') };
  check('the sheet\'s combat and save fields are found', hasField.combat.length > 10 && hasField.saves.length > 10);
  const used = { combat: new Set(), saves: new Set() };
  const dbDir = join(appDir, 'db');
  for (const f of readdirSync(dbDir).filter((n) => /^add-.*-class[.]sql$/.test(n))) {
    const md = extractClassMarkdown(readFileSync(join(dbDir, f), 'utf8'));
    const b = md ? parseClassMarkdown(md).data?.bonuses : null;
    for (const group of ['combat', 'saves']) {
      for (const k of Object.keys(b?.[group] || {})) if (k !== 'other') used[group].add(k);
    }
  }
  for (const group of ['combat', 'saves']) {
    const missing = [...used[group]].filter((k) => hasField[group].includes(k) && !offered[group].includes(k));
    check(`the prompt offers every ${group} key a shipped class states and the sheet shows`,
      missing.length === 0, missing.join(', '));
    const unread = offered[group].filter((k) => !hasField[group].includes(k));
    check(`and offers no ${group} key the sheet has no field for`, unread.length === 0, unread.join(', '));
  }
  const variantSentence = prompt.match(/A variant may override ONLY([\s\S]*?)anything else in/)?.[1] || '';
  const variantOnly = ['skill_overrides', 'skills_additional', 'related_skills_count'];
  const unnamed = VARIANT_OVERRIDES.filter((k) => !variantOnly.includes(k) && !new RegExp(`\\b${k}\\b`).test(variantSentence));
  check('the prompt names every key a variant may override', unnamed.length === 0, unnamed.join(', '));
  check('and tells the model to leave the three variant-only skill keys to a person',
    variantOnly.every((k) => VARIANT_OVERRIDES.includes(k) && prompt.includes(k)) && /Do not write them/.test(prompt));
}

// ---------- 1c12. Class variants ----------
// Several RCCs come in stages: a Dragon is a hatchling, then an adult, sharing
// lore, skills and abilities while differing in attribute dice, M.D.C. and what
// the class grants. Four unrelated class files means maintaining the shared 90%
// four times.
section('Class variants');

const dragonMd = `---
id: dragon
name: Dragon
system: rifts
source_book: test-book
category: rcc
mdc_base: "1d4x100"
ppe_base: "2d4x10+40"
attribute_dice: { PS: "4d6+12" }
bonuses:
  combat: { attacks: 1 }
variants:
  - id: hatchling
    name: "Dragon Hatchling"
  - id: adult
    name: "Adult Dragon"
    attribute_dice: { PS: "4d6+30" }
    mdc_base: "1d6x1000"
    bonuses:
      attributes: { PS: 4 }
      combat: { attacks: 3 }
---

## Lore

Shared by every stage.
`;
const dragonParsed = parseClassMarkdown(dragonMd);
check('a class with variants parses', dragonParsed.ok, JSON.stringify(dragonParsed.errors));

const asAdult = applyVariant(dragonParsed.data, 'adult');
const asHatchling = applyVariant(dragonParsed.data, 'hatchling');

check('a variant overrides only what it states', (() => (
  asAdult.attribute_dice.PS === '4d6+30' && asAdult.mdc_base === '1d6x1000'
  // Not stated by the adult, so it comes from the class.
  && asAdult.ppe_base === '2d4x10+40'
))());

// attribute_dice and attribute_requirements MERGE per key; everything else
// replaces. A variant naming one attribute says nothing about the other seven,
// and replacing the map wholesale left an adult that overrode only P.S. rolling
// a plain 3d6 for I.Q.
check('attribute_dice merges per attribute rather than replacing', (() => {
  const md = dragonMd.replace('attribute_dice: { PS: "4d6+12" }',
                              'attribute_dice: { PS: "4d6+12", IQ: "3d6+6" }');
  const adult = applyVariant(parseClassMarkdown(md).data, 'adult');
  // The adult states only PS.
  return adult.attribute_dice.PS === '4d6+30' && adult.attribute_dice.IQ === '3d6+6';
})());
check('a scalar override still replaces', asAdult.mdc_base === '1d6x1000');
check('a variant that states nothing inherits everything',
  asHatchling.mdc_base === '1d4x100' && asHatchling.attribute_dice.PS === '4d6+12');
check('the variant name replaces the class name for display',
  asAdult.name === 'Adult Dragon' && asHatchling.name === 'Dragon Hatchling');
check('the shared half is untouched',
  asAdult.id === 'dragon' && asAdult.sections !== undefined);

// Replacement, not merging — the same rule mdc_base follows. A variant's
// bonuses ARE its bonuses, so there is no question of which half won.
check('variant bonuses replace the class’s rather than merging', (() => {
  const b = derive.classBonuses(asAdult, 1);
  return b.combat.attacks === 3 && b.attributes.PS === 4;
})());
check('a variant with no bonuses keeps the class’s',
  derive.classBonuses(asHatchling, 1).combat.attacks === 1);

// Every caller applies this unconditionally, so the no-variant paths matter as
// much as the variant ones.
check('no variant id returns the class unchanged',
  applyVariant(dragonParsed.data, null).name === 'Dragon');
check('an unknown variant id returns the class unchanged',
  applyVariant(dragonParsed.data, 'wyrmling').name === 'Dragon');
check('a class with no variants is unaffected',
  applyVariant({ name: 'Juicer' }, 'adult').name === 'Juicer');

// ── a variant that ADDS skills and moves the related count ──────────────────
// F31. The shape a book uses more often than the staged dragon: one training
// course plus a per-chassis supplement, "In addition to the Basic O.C.C.
// Skills... but other O.C.C. skills are reduced to three (not six)".
{
  const base = {
    name: 'Cyborg', skills: {
      occ_skills: [
        { name: 'Radio: Basic', base: 50 },
        { name: 'Climbing', base: 40 },
        { choose: 2, categories: ['Physical'] },
      ],
      occ_related_skills: { count: 6, categories: ['Technical'] },
    },
    variants: [{
      id: 'dervish', name: 'FX-320C Dervish',
      skills_additional: { occ_skills: [
        { name: 'Acrobatics', base: 60 },
        { name: 'Climbing', base: 70 },      // already granted, at a lower base
      ] },
      related_skills_count: 3,
    }],
  };
  const v = applyVariant(base, 'dervish');
  const names = v.skills.occ_skills.filter((e) => e.name).map((e) => e.name).sort();

  check('a variant ADDS its own skills to the parent\'s',
    names.join(',') === 'Acrobatics,Climbing,Radio: Basic');
  // Union, not replace: the parent's whole list survives, which is what keeps
  // "a variant cannot take a skill away" true by construction.
  check('and the parent\'s skills all survive',
    names.includes('Radio: Basic') && names.includes('Climbing'));
  // combineClasses' policy, reused: higher base wins on a name collision.
  check('a collision keeps the HIGHER base, as combineClasses does',
    v.skills.occ_skills.find((e) => e.name === 'Climbing').base === 70);
  // Choice groups have no identity to match on, so they are never deduped.
  check('and the choice group is carried, not collapsed',
    v.skills.occ_skills.filter((e) => !e.name).length === 1);
  check('related_skills_count moves the related count',
    v.skills.occ_related_skills.count === 3);
  // The categories the count applies to are the parent's - the variant said
  // nothing about them, so it must not have silently replaced them.
  check('and leaves the categories the parent set',
    JSON.stringify(v.skills.occ_related_skills.categories) === '["Technical"]');
  // Neither key may survive onto the composed class: they are instructions,
  // not fields, and `skill_overrides` is deleted for the same reason.
  check('neither key is left on the composed class',
    v.skills_additional === undefined && v.related_skills_count === undefined);
  // The base class must be untouched - applyVariant returns a new object and
  // every caller applies it unconditionally, often more than once.
  check('and the parent class is not mutated',
    base.skills.occ_skills.length === 3 && base.skills.occ_related_skills.count === 6);

  const bad = (frag) => parseClassMarkdown(['---', 'id: c', 'name: C', 'system: rifts',
    'source_book: b', 'category: occ', 'skills:', '  occ_skills:',
    '    - { name: "Radio: Basic", base: 50 }', 'variants:', frag,
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('skills_additional must carry occ_skills',
    !bad('  - { id: a, name: A, skills_additional: { secondary_skills: { count: 2 } } }').ok);
  check('and may not restate the related ALLOWANCE wholesale',
    bad('  - { id: a, name: A, skills_additional: { occ_skills: [], occ_related_skills: { count: 2 } } }')
      .errors.some((e) => /not addable/.test(e)));
  check('related_skills_count must be a whole number',
    !bad('  - { id: a, name: A, related_skills_count: "three" }').ok);
}

const variantErr = (yaml) => parseClassMarkdown(dragonMd.replace(/variants:[\s\S]*?---/, yaml + '\n---'));
check('a variant without an id is rejected',
  !variantErr('variants:\n  - { name: "Nameless" }').ok);
check('two variants with the same id are rejected',
  !variantErr('variants:\n  - { id: a, name: A }\n  - { id: a, name: B }').ok);
// A field a variant cannot override would silently do nothing.
check('a variant overriding something it may not warns', (() => {
  const p = variantErr('variants:\n  - { id: a, name: A, skills: { secondary_skills: { count: 9 } } }');
  return p.ok && p.warnings.some((w) => /cannot override/.test(w));
})());

// ---------- 1c9. Picker filtering ----------
// js/picker.js is a classic script, because the wizard is a module and the
// sheet is a plain script and both need it. So it is loaded the way a browser
// would: evaluated against a stand-in window, then the global it defines is
// taken off that.
section('Picker filtering');

const pickerWindow = {};
new Function('window', readFileSync(join(appDir, 'js', 'picker.js'), 'utf8'))(pickerWindow);
const Picker = pickerWindow.Picker;

const skill = { name: 'Wilderness Survival', category: 'Wilderness', source_book: 'rifts-main' };

check('matches on a name fragment', Picker.match(skill, 'wilder'));
check('matches on category', Picker.match(skill, 'wilderness'));
check('matches on source book', Picker.match(skill, 'rifts'));
check('is case-insensitive', Picker.match(skill, 'WILDERNESS SURVIVAL'));
check('an empty query matches everything', Picker.match(skill, '') && Picker.match(skill, '   '));

// Multi-term is AND, not OR: typing more must narrow. A picker that widened as
// you typed would be worse than no filter at all.
check('every term must match', Picker.match(skill, 'survival rifts'));
check('one non-matching term excludes the row', !Picker.match(skill, 'survival palladium'));
check('term order does not matter', Picker.match(skill, 'rifts survival'));

// Fields the row does not display are deliberately not searched — a hit whose
// reason is invisible reads as a bug.
check('undisplayed fields are not searched',
  !Picker.match({ name: 'Backpack', description: 'holds a laser' }, 'laser'));

check('filter narrows a list', Picker.filter([skill, { name: 'Swimming', category: 'Physical' }], 'wilder').length === 1);
check('filter returns everything for a blank query', Picker.filter([skill, { name: 'Swimming' }], '').length === 2);
check('filter tolerates missing fields and empty input',
  Picker.filter([{ name: 'Nameless' }, {}], 'nameless').length === 1 && Picker.filter(undefined, 'x').length === 0);

// The count is what tells you whether an empty list means "no match" or
// "nothing in the catalog".
const html = Picker.inputHtml({ id: 'x-filter', value: 'a "quoted" value', shown: 3, total: 99 });
check('the input renders its count', html.includes('3 of 99'));
check('the input escapes quotes in its value', html.includes('&quot;quoted&quot;') && !html.includes('"quoted"'));
check('the count is omitted when there is no total', !Picker.inputHtml({ id: 'y' }).includes('pick-count'));

// ---------- 1c15. Pool formulas ----------
// Every one of these is a real formula from a sourcebook. Three of the five
// returned NULL before, which meant a character imported from that class was
// created with no hit points, no P.P.E. and no I.S.P. at all.
section('Mega-damage conversion (BOOK-INGEST-AUDIT F62)');
{
  // Loaded as a namespace so a check fails on its own, rather than the whole
  // run failing at import, when a function is missing - which is exactly what
  // these must do before the fix exists.
  const LV = await import('../js/leveling.js');
  const md = (extra) => parseClassMarkdown(['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b',
    'category: occ', ...extra, '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  const tw = md(['mdc_from_hp_sdc: true', 'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"']);
  check('the flag parses', tw.ok && tw.data.mdc_from_hp_sdc === true, tw.errors.join('; '));
  check('and may only be true', md(['mdc_from_hp_sdc: yes']).errors.some((e) => /mdc_from_hp_sdc/.test(e)));
  const converts = (c) => (typeof LV.convertsToMdc === 'function' ? LV.convertsToMdc(c) : undefined);
  check('a flagged class converts', converts(tw.data) === true);
  check('an unflagged class does not', converts(md([]).data) === false);
  check('and a class stating its own M.D.C. keeps that pool', converts({ ...tw.data, mdc_base: '1d4x100' }) === false);

  const pools = LV.convertedPools?.(tw.data, { hp: 14, sdc: 12, mdc: null, ppe: 5 }, {});
  check('the two rolls become ONE M.D.C. maximum and the pools they came from are emptied',
    pools?.mdc === 26 && pools.hp === null && pools.sdc === null && pools.ppe === 5, JSON.stringify(pools));
  const bonused = LV.convertedPools?.({ ...tw.data, bonuses: { pools: { mdc: 10 } } }, { hp: 14, sdc: 12, mdc: null }, {});
  check('with any M.D.C. bonus added on top', bonused?.mdc === 36, JSON.stringify(bonused));
  check('an unflagged class keeps its pools untouched',
    JSON.stringify(LV.convertedPools?.(md([]).data, { hp: 14, sdc: 12, mdc: null }, {})) === '{"hp":14,"sdc":12,"mdc":null}');

  const race = { id: 'r', name: 'R', system: 'rifts', category: 'rcc' };
  check('an occupation\'s flag survives being composed with a racial class',
    combineClasses(race, tw.data).mdc_from_hp_sdc === true);
  check('but an M.D.C. race keeps its own pool',
    converts(combineClasses({ ...race, mdc_base: '1d4x100' }, tw.data)) === false);

  // P.E. 10: hit points 'P.E. + 1D6 per level' are 11-16 at level one, S.D.C.
  // 3D6 is 3-18, so the M.D.C. maximum is 14-34, +1-6 a level after the first.
  const cls = composeClass({ rcc: tw.data });
  const poolFindings = (mdc, level = 1) => validateCharacter({ character: { level }, cls, skills: [],
    attributes: { PE: 10 }, pools: { hp_max: null, sdc_max: null, mdc_max: mdc }, enforcePools: true })
    .violations.filter((x) => x.rule === 'pool_out_of_range');
  check('the emptied hit point and S.D.C. pools raise nothing, and an M.D.C. in range passes',
    poolFindings(20).length === 0, JSON.stringify(poolFindings(20)));
  check('an M.D.C. past what the two formulas can roll is refused',
    poolFindings(200).some((x) => x.field === 'mdc_max'));
  check('and the range grows by the hit point dice each level',
    poolFindings(40, 1).length > 0 && poolFindings(40, 3).length === 0);

  const prop = buildProposal({ level: 1, hp_max: null, sdc_max: null, mdc_max: 26, ppe_max: null,
    isp_max: null, skills: [] }, cls, 3);
  check('a level-up grows M.D.C. by the hit point dice, and touches no emptied pool',
    prop.pools.mdc_max && prop.pools.mdc_max.to >= 28 && prop.pools.mdc_max.to <= 38
    && !prop.pools.hp_max && !prop.pools.sdc_max, JSON.stringify(prop.pools));
}

section('Mega-damage conversion from a chosen ability (BOOK-INGEST-AUDIT F64)');
{
  // The Spirit Warrior converts only through its Earth or Plant realm, and
  // chooses three of six, so the flag rides on the ABILITY and is folded onto
  // the composed class when that ability is taken - the way F24's
  // related_skills_count is, and outside ABILITY_GRANTS, whose keys are all
  // maps (pinned in 'Chosen abilities').
  const LV = await import('../js/leveling.js');
  const realm = (name, extra) => [`  - name: "${name}"`, '    description: "x"', ...extra];
  const md = (defs) => parseClassMarkdown(['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b',
    'category: occ', 'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"', 'special_abilities:',
    '  - { choose: 2, from: ["Earth", "Plant", "Air"] }', ...defs,
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  const CONVERTS = ['    mdc_from_hp_sdc: true', '    bonuses: { pools: { mdc: "1d4x10" } }'];
  const sw = md([...realm('Earth', CONVERTS), ...realm('Plant', CONVERTS), ...realm('Air', [])]);
  check('a chosen ability may carry the conversion flag', sw.ok, sw.errors.join('; '));
  check('and it may only be true',
    md(realm('Earth', ['    mdc_from_hp_sdc: yes'])).errors.some((e) => /Earth\.mdc_from_hp_sdc/.test(e)));

  const as = (...abilities) => composeClass({ rcc: sw.data, character: { abilities } });
  check('the class alone does not convert', LV.convertsToMdc(composeClass({ rcc: sw.data })) === false);
  check('choosing the Earth realm converts it', LV.convertsToMdc(as('Earth', 'Air')) === true);
  check('choosing neither Earth nor Plant does not', LV.convertsToMdc(as('Air')) === false);
  check('and the fold leaves the class it was given untouched', sw.data.mdc_from_hp_sdc === undefined);

  // P.E. 10: hit points 11-16 and S.D.C. 3-18 make 14-34, and each converting
  // realm adds 1D4x10. Printed 47: taken together the two "do not combine the
  // bonuses to the P.E. attribute, but do combine the M.D.C."
  const one = LV.convertedMdcBounds(as('Earth', 'Air'), { PE: 10 }, 1);
  const two = LV.convertedMdcBounds(as('Earth', 'Plant'), { PE: 10 }, 1);
  check('a converting realm adds its 1D4x10, and two of them combine',
    one?.min === 24 && one?.max === 74 && two?.min === 34 && two?.max === 114, JSON.stringify({ one, two }));

  const outOfRange = (cls, mdc) => validateCharacter({ character: { level: 1 }, cls, skills: [],
    attributes: { PE: 10 }, pools: { hp_max: null, sdc_max: null, mdc_max: mdc }, enforcePools: true })
    .violations.filter((x) => x.rule === 'pool_out_of_range');
  check('the server bounds the converted M.D.C.: in range passes, past it is refused',
    outOfRange(as('Earth', 'Air'), 50).length === 0
    && outOfRange(as('Earth', 'Air'), 200).some((x) => x.field === 'mdc_max'),
    JSON.stringify(outOfRange(as('Earth', 'Air'), 200)));
}

await talentChecks();


section('Ability choice groups count PER GROUP (BOOK-INGEST-AUDIT F98)');
{
  // A pick belongs to the group that OFFERS it. `abilityPicker` used to compare
  // the character's TOTAL pick count against one group's `choose`, so on a
  // class with more than one group the first pick disabled every remaining `+`
  // button - the Heroes Unlimited Alien has four groups of `choose: 1` and a
  // player could take one of the four. Nothing in this suite touched the picker
  // before F98, which is why a live defect on two published classes was found
  // by an audit rather than by a run.
  const cls = parseClassMarkdown(['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b',
    'category: occ', 'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"', 'special_abilities:',
    '  - { choose: 1, from: ["Alpha", "Beta"], note: "Step one." }',
    '  - { choose: 2, from: ["Gamma", "Delta", "Epsilon"] }',
    '  - name: "Alpha"', '    description: "a"',
    '  - name: "Gamma"', '    description: "g"',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;

  check('a pick is attributed to the group that offers it',
    abilityGroupIndexFor(cls, 'Alpha') === 0 && abilityGroupIndexFor(cls, 'Delta') === 1);
  check('and matching ignores case and surrounding space, as every other name lookup here does',
    abilityGroupIndexFor(cls, '  gAmMa  ') === 1);
  check('a name no group offers belongs to none, rather than to the first',
    abilityGroupIndexFor(cls, 'Assigned By The G.M.') === -1);

  check('counts start at zero per group', String(abilityGroupCounts(cls, [])) === '0,0');
  check('and a pick counts against ITS group only',
    String(abilityGroupCounts(cls, ['Alpha'])) === '1,0'
    && String(abilityGroupCounts(cls, ['Alpha', 'Delta'])) === '1,1'
    && String(abilityGroupCounts(cls, ['Gamma', 'Delta'])) === '0,2');
  check('an unoffered pick is counted against no group, so it cannot fill one',
    String(abilityGroupCounts(cls, ['Assigned By The G.M.'])) === '0,0');

  // THE ROLL BUTTON. A pick-one group whose option names carry percentile bands
  // is a table the book rolls on, and the wizard offers the dice for it. The
  // bands are read from the names, so these pin what counts as a table.
  const table = { choose: 1, from: ['Kind (01-50): A', 'Kind (51-70): B', 'Kind (51-70): C',
    'Kind (71-00): D', 'Kind: none (table not used)'] };
  const bands = abilityRollBands(table);
  check('a pick-one group named for bands that cover 1-100 is rollable, and 00 closes at 100',
    Array.isArray(bands) && bands.length === 4 && bands[3].lo === 71 && bands[3].hi === 100);
  check('a roll lands on the option whose band holds it',
    String(abilityRollMatches(bands, 1)) === 'Kind (01-50): A'
    && String(abilityRollMatches(bands, 50)) === 'Kind (01-50): A'
    && String(abilityRollMatches(bands, 100)) === 'Kind (71-00): D');
  check('and on BOTH options where the book prints two for one band, so the player chooses',
    abilityRollMatches(bands, 60).length === 2);
  check('an option with no band is never what a roll lands on',
    [1, 50, 60, 100].every((n) => !abilityRollMatches(bands, n).includes('Kind: none (table not used)')));
  check('a table with a hole in it is not rollable, rather than rollable-sometimes',
    abilityRollBands({ choose: 1, from: ['K (01-50): A', 'K (61-00): B'] }) === null);
  check('nor is a group with no bands, a choose-2 group, or a named ability',
    abilityRollBands(cls.special_abilities[0]) === null
    && abilityRollBands({ choose: 2, from: ['K (01-50): A', 'K (51-00): B'] }) === null
    && abilityRollBands({ name: 'K (01-50): A' }) === null);

  // THE REGRESSION ITSELF, stated as the disagreement rather than as an
  // outcome: with one pick held, the TOTAL has reached group 0's limit while
  // group 1 is still empty. The old code read the total here and closed group 1.
  {
    const held = ['Alpha'];
    const groups = cls.special_abilities.filter((e) => e && e.choose);
    const counts = abilityGroupCounts(cls, held);
    check('with one pick held the TOTAL has reached group 0 limit - which is what misled the picker',
      held.length >= (+groups[0].choose || 1));
    check('but group 1 is still empty and still open, which is the fix',
      (counts[1] || 0) === 0 && (counts[1] || 0) < (+groups[1].choose || 1));
    check('and a second group stays open until ITS OWN limit is reached',
      (abilityGroupCounts(cls, ['Alpha', 'Gamma'])[1] || 0) < 2
      && (abilityGroupCounts(cls, ['Alpha', 'Gamma', 'Delta'])[1] || 0) === 2);
  }

  // Two groups offering one name is not a shape any class in the catalog has,
  // and it has a defined answer rather than an undefined one.
  const dup = parseClassMarkdown(['---', 'id: d', 'name: D', 'system: rifts', 'source_book: b',
    'category: occ', 'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"', 'special_abilities:',
    '  - { choose: 1, from: ["Shared"] }',
    '  - { choose: 1, from: ["Shared"] }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  check('where two groups offer one name the EARLIER group takes the pick',
    abilityGroupIndexFor(dup, 'Shared') === 0 && String(abilityGroupCounts(dup, ['Shared'])) === '1,0');

  // The render path is browser-only, so this half is a text check on app.js -
  // the same compensation `rendered-ui.mjs` makes, and it names its symptom.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const picker = appSrc.slice(appSrc.indexOf("function abilityPicker(side = 'rcc')"),
    appSrc.indexOf('function abilityDef('));
  check('the picker reads a PER-GROUP count rather than the length of every pick',
    /abilityGroupCounts\(/.test(picker) && !/const picked = S\.abilities\.length/.test(picker),
    picker.slice(0, 400));
  check('and it renders the group note, which twelve live groups carry and none could show',
    /g\.note/.test(picker));
  const take = appSrc.slice(appSrc.indexOf('function takeAbility('), appSrc.indexOf('function dropAbility('));
  check('and taking one is bounded by the OWNING group rather than by the sum of every group',
    /abilityGroupIndexFor\(/.test(take) && /abilityGroupCounts\(/.test(take), take);
}

section('Pool formulas');
{
  const attrs = { PE: 10, ME: 20 };
  const r = (f) => rollPoolFormula(f, attrs);
  const between = (v, lo, hi) => typeof v === 'number' && v >= lo && v <= hi;

  check('plain dice', between(r('4D6x100'), 400, 2400));
  check('a plain number is taken as-is', r('20') === 20);
  check('attribute then dice', between(r('P.E. + 1d6 per level'), 11, 16));
  // The order books actually use as often as the other, and the one that used
  // to fall through to null.
  check('dice then attribute', between(r('2D4x100+200 plus P.E. attribute number'), 410, 1010));
  check('dice then a different attribute', between(r('3D4x10 + M.E. attribute number'), 50, 140));
  // Books qualify these heavily; the leading figure is the one they lead with.
  check('dice leading a qualified sentence',
    between(r('3D4x100+1000 when in natural serpent form (only 3D4x100 when in humanoid form)'), 1300, 2200));

  check('no numbers at all stays null', r('varies by GM ruling') === null);
  check('null and undefined stay null', r(null) === null && r(undefined) === null);
  // A number the formula cannot supply must not be invented from a missing
  // attribute — the bonus is skipped, not treated as zero silently.
  check('an attribute the character lacks falls back to the dice alone',
    between(rollPoolFormula('2D4x10 plus P.E. attribute number', {}), 20, 80));

  // An attribute the book MULTIPLIES. Supernatural and mega-damage races state
  // their pools this way as a matter of course, and the Godling R.C.C. is
  // written entirely in it. Both failure modes were live: a formula that is
  // only a multiplied attribute returned null, and one with dice as well
  // silently DROPPED the multiplier — "P.E. x 3 plus 2D6" rolled P.E. + 2D6,
  // a third of the right number and completely plausible-looking.
  check('a multiplied attribute alone', r('P.E. x 10') === 100);
  check('spelled with the word "number"', r('P.E. number x 10') === 100);
  check('spelled with a multiplication sign', r('P.E. × 10') === 100);
  check('a multiplied attribute plus dice', between(r('P.E. x 3 plus 2D6 per level'), 32, 42));
  check('and the multiplier is not dropped', r('P.E. x 3 plus 2D6 per level') > 30);
  check('base and per-level growth together', between(r('P.E. x 10, plus 1D4x10 per level'), 110, 140));

  // The other half of the same rule: an `x N` that belongs to the DICE must not
  // be read as multiplying the attribute. M.E. is 20 here, so mistaking the x10
  // for the attribute's would put these an order of magnitude out.
  check('a dice multiplier stays with the dice',
    between(r('M.E. number plus 1D6x10'), 30, 80));
  check('even when the dice lead', between(r('4D6x10 plus the M.E. number'), 60, 260));
}

await raceAndOccupationChecks();


// ---------- 1c17. The attribute bonus chart ----------
// Transcribed from Palladium Fantasy RPG 2nd Ed. p.16. These assert the PRINTED
// numbers, not a formula — the whole point is that the rows disagree with each
// other, which is what the old single `v - 15` got wrong.
section('Attribute bonus chart');
{
  const combatAt = (attr, v) => D.combat({ [attr]: v }, null);
  const savesAt = (attr, v) => D.saves({ [attr]: v }, null);
  const bioAt = (attr, v) => D.bio({ [attr]: v }, null);

  // Each entry: attribute value -> printed value. Sampled across the row rather
  // than exhaustively, including both ends and the irregular steps in between.
  const rowCheck = (label, read, expected) => {
    const wrong = Object.entries(expected)
      .filter(([v, want]) => read(Number(v)) !== want)
      .map(([v, want]) => `${v}→${read(Number(v))} (book ${want})`);
    check(label, wrong.length === 0, wrong.join(', '));
  };

  rowCheck('P.S. damage matches the book', (v) => combatAt('PS', v).damage_bonus,
    { 15: 0, 16: 1, 18: 3, 24: 9, 30: 15 });
  // The row that was roughly doubled: +1 per TWO points, not per point.
  rowCheck('P.P. strike matches the book', (v) => combatAt('PP', v).strike,
    { 15: 0, 16: 1, 17: 1, 18: 2, 19: 2, 20: 3, 24: 5, 29: 7, 30: 8 });
  rowCheck('P.P. parry matches the book', (v) => combatAt('PP', v).parry,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  rowCheck('P.P. dodge matches the book', (v) => combatAt('PP', v).dodge,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  rowCheck('M.E. save vs psionic attack matches the book', (v) => savesAt('ME', v).psionics,
    { 15: 0, 16: 1, 18: 2, 24: 5, 30: 8 });
  // Insanity is halved only to 19, then gains a point per point — the one row
  // that changes its own step partway along.
  rowCheck('M.E. save vs insanity matches the book', (v) => savesAt('ME', v).insanity,
    { 16: 1, 17: 1, 18: 2, 19: 2, 20: 3, 21: 4, 25: 8, 30: 13 });
  rowCheck('P.E. save vs magic/poison matches the book', (v) => savesAt('PE', v).spell_magic,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  // The old `pe * 2` was right from 18 up and wrong at both 16 and 17.
  rowCheck('P.E. save vs coma/death matches the book', (v) => savesAt('PE', v).coma_death_pct,
    { 15: 0, 16: 4, 17: 5, 18: 6, 19: 8, 24: 18, 30: 30 });
  rowCheck('M.A. trust/intimidate matches the book', (v) => bioAt('MA', v).invoke_trust_pct,
    { 15: 0, 16: 40, 20: 60, 24: 80, 25: 84, 27: 92, 30: 97 });
  rowCheck('P.B. charm/impress matches the book', (v) => bioAt('PB', v).charm_impress_pct,
    { 15: 0, 16: 30, 20: 50, 26: 80, 27: 83, 29: 90, 30: 92 });
  rowCheck('I.Q. skill bonus matches the book', (v) => bioAt('IQ', v).iq_skill_bonus_pct,
    { 15: 0, 16: 2, 18: 4, 24: 10, 30: 16 });

  // Below the chart nothing is granted at all — 15 is not "one less than 16".
  check('an attribute under 16 grants nothing anywhere', (() => {
    const c = D.combat({ PS: 15, PP: 15, Spd: 0 }, null);
    const s = D.saves({ PE: 3, ME: 3 }, null);
    const b = D.bio({ MA: 15, PB: 15, IQ: 15 }, null);
    return c.strike === 0 && c.parry === 0 && c.damage_bonus === 0
      && s.spell_magic === 0 && s.insanity === 0 && s.coma_death_pct === 0
      && b.invoke_trust_pct === 0 && b.charm_impress_pct === 0 && b.iq_skill_bonus_pct === 0;
  })());

  // Above 30 the book stops and dragons do not: each row continues the step it
  // ends on. House rule, asserted so it cannot drift silently.
  check('rows continue past 30 on the step they end on', (() => {
    const pp = (v) => D.combat({ PP: v }, null).parry;
    const pe = (v) => D.saves({ PE: v }, null).coma_death_pct;
    const ps = (v) => D.combat({ PS: v }, null).damage_bonus;
    // +1 per two points, so 31 is still 8 and 32 steps to 9.
    return pp(31) === 8 && pp(32) === 9 && pp(34) === 10
      && pe(31) === 32 && pe(32) === 34
      && ps(31) === 16 && ps(40) === 25;
  })());

  // The bug that made a P.B. 30 character charm literally everyone.
  check('the percentile rows stop at 98%, never 100', (() => {
    const ma = (v) => D.bio({ MA: v }, null).invoke_trust_pct;
    const pb = (v) => D.bio({ PB: v }, null).charm_impress_pct;
    return ma(30) === 97 && ma(31) === 98 && ma(50) === 98
      && pb(30) === 92 && pb(33) === 98 && pb(99) === 98;
  })());

  // The flat rows are bonuses added to a roll, not percentages, so the 98 cap
  // must not reach them — a P.S. 200 dragon keeps scaling.
  check('the flat bonus rows are not capped', D.combat({ PS: 200 }, null).damage_bonus > 98);

  // Class bonuses and stored overrides are layered on top of the chart, not
  // instead of it, and that plumbing is unchanged by the new tables.
  check('a class attribute bonus is read against the chart, not around it', (() => {
    // P.P. 17 alone is +1; the class's +1 makes it 18, which the book puts at +2.
    const bonuses = { attributes: { PP: 1 }, combat: {}, saves: {} };
    return D.combat({ PP: 17 }, null, bonuses).parry === 2;
  })());
  check('a stored value still wins over the chart',
    D.combat({ PP: 30 }, { parry: 1 }).parry === 1);
  check('parts() splits chart and class contributions', (() => {
    const p = D.parts('combat', { PP: 17 }, { attributes: { PP: 1 }, combat: { parry: 3 } });
    return p.parry.attrs === 1 && p.parry.from_class === 4; // +1 via attribute, +3 direct
  })());
}

// ---------- 1c18. Exceptional attribute rolls ----------
// Palladium Fantasy 2nd Ed. p.14. Randomness is stubbed so these assert the
// rule rather than a distribution — an exceptional roll is rare enough that a
// statistical test would be both slow and flaky.
section('Exceptional attribute rolls');
{
  // d(sides) is 1 + floor(random * sides), so (face - 1) / 6 forces `face` on a
  // six-sided die. Every attribute pool here is d6; nothing else is exercised.
  const withFaces = (faces, fn) => {
    const real = Math.random;
    let i = 0;
    Math.random = () => (faces[i++] - 1) / 6 + 1e-9;
    try { return fn(); } finally { Math.random = real; }
  };
  const roll = (expr, faces) => withFaces(faces, () => rollAttribute(expr));

  check('3d6 under 16 earns no extra die', (() => {
    const r = roll('3d6', [5, 5, 5]);
    return r.total === 15 && r.exceptional.length === 0;
  })());
  check('3d6 at exactly 16 earns one extra die', (() => {
    const r = roll('3d6', [5, 5, 6, 3]);
    return r.base === 16 && r.exceptional.join() === '3' && r.total === 19;
  })());
  check('3d6 at 18 earns one extra die', (() => {
    const r = roll('3d6', [6, 6, 6, 2]);
    return r.base === 18 && r.total === 20;
  })());
  // "If a six is rolled ... roll 1D6 again, and add that number also."
  check('a six on the extra die earns one more', (() => {
    const r = roll('3d6', [6, 6, 6, 6, 4]);
    return r.exceptional.join() === '6,4' && r.total === 28;
  })());
  // "However, even if this last roll is a six, the player does not roll again."
  check('the chain stops at two, even on a second six', (() => {
    const r = roll('3d6', [6, 6, 6, 6, 6, 6]);
    return r.exceptional.join() === '6,6' && r.total === 30;
  })());

  check('2d6 earns its extra die only on a 12', (() => {
    const hit = roll('2d6', [6, 6, 2]);
    const miss = roll('2d6', [6, 5]);
    return hit.base === 12 && hit.total === 14 && miss.total === 11 && miss.exceptional.length === 0;
  })());

  // Named exclusion: "Characters that get to roll four, five or even six,
  // six-sided dice for an attribute do not get any additional dice rolls even
  // if the rolls are exceptional."
  check('4d6 and above never earn an extra die', (() => {
    const four = roll('4d6', [6, 6, 6, 6]);
    const six = roll('6d6', [6, 6, 6, 6, 6, 6]);
    return four.total === 24 && four.exceptional.length === 0
      && six.total === 36 && six.exceptional.length === 0;
  })());

  // The threshold reads the dice, not the total: a flat racial bonus must not
  // buy an exceptional roll that the dice did not earn.
  check('a racial modifier does not trigger the threshold', (() => {
    const r = roll('3d6+6', [3, 3, 4]);
    return r.base === 10 && r.modifier === 6 && r.total === 16 && r.exceptional.length === 0;
  })());
  check('a racial modifier still stacks on a genuine exceptional roll', (() => {
    const r = roll('3d6+6', [5, 5, 6, 2]);
    return r.base === 16 && r.modifier === 6 && r.total === 24;
  })());

  // A multiplied pool is a hit-point formula, not an attribute.
  check('a multiplied pool earns nothing', roll('1d6x10', [6]).exceptional.length === 0);

  // The bug this replaced: stating 3d6 explicitly took a branch that skipped
  // the bonus die, so the same dice produced different characters depending on
  // whether the class bothered to write them down.
  check('an explicit 3d6 behaves exactly like the default', (() => {
    const stated = roll('3d6', [6, 6, 6, 4]);
    const implied = roll('', [6, 6, 6, 4]);
    return stated.total === implied.total && implied.total === 22;
  })());
  check('an unparseable expression falls back to 3d6',
    roll('two handfuls', [4, 4, 4]).total === 12);
}

// ---------- 1c19. Skill percentages ----------
// The I.Q. bonus is a ONE-TIME addition to every skill percentage (p.22), and
// secondary skills advance per level even though they get no O.C.C. bonus.
section('Skill percentages');
{
  // skillsPayload() lives inside the wizard module and depends on wizard state,
  // so the rule it applies is restated here against the same derive call the
  // wizard makes. What is pinned is the arithmetic and the cap.
  const CAP = 98;
  const iqOf = (iq) => D.bio({ IQ: iq }, null).iq_skill_bonus_pct || 0;
  const apply = (pct, iq) => (!pct ? { pct, iq_bonus: 0 }
    : { pct: Math.min(CAP, pct + iqOf(iq)), iq_bonus: iqOf(iq) });

  check('an average I.Q. adds nothing', (() => {
    const r = apply(35, 12);
    return r.pct === 35 && r.iq_bonus === 0;
  })());
  check('I.Q. 16 adds its printed 2%', apply(35, 16).pct === 37);
  check('I.Q. 18 adds its printed 4%', apply(35, 18).pct === 39);
  check('I.Q. 30 adds its printed 16%', apply(35, 30).pct === 51);

  // A W.P. or hand to hand has no percentage to modify; inventing one would
  // imply a roll the skill does not have.
  check('a non-percentile skill stays at zero', (() => {
    const r = apply(0, 30);
    return r.pct === 0 && r.iq_bonus === 0;
  })());

  // The cap matters now in a way it did not before: a high base plus a large
  // I.Q. bonus is the first thing at creation that can exceed 98.
  check('the I.Q. bonus cannot push a skill past 98%', (() => {
    const r = apply(90, 30);           // 90 + 16 = 106
    return r.pct === CAP && r.iq_bonus === 16;
  })());
  check('a skill already at the cap stays there', apply(98, 24).pct === CAP);

  // The bonus is recorded, not just folded in, so 39% is distinguishable from a
  // skill whose base genuinely is 39.
  check('the bonus is recorded alongside the total', apply(35, 18).iq_bonus === 4);

  // Secondary skills carry a real per-level step now, so the level-up flow
  // advances them. Previously the wizard wrote 0 and they were frozen for life.
  check('a secondary skill with a per-level step advances', (() => {
    const cls = { skills: {} };
    const character = { level: 1, skills: [
      { name: 'Fishing', type: 'secondary', pct: 29, per_level: 5 },
      { name: 'W.P. Sword', type: 'occ', pct: 0, per_level: 0 },
    ] };
    const p = buildProposal(character, cls, 3);
    const fishing = p.skills.find((s) => s.name === 'Fishing');
    return fishing && fishing.from === 29 && fishing.to === 39   // two levels × +5
      && !p.skills.some((s) => s.name === 'W.P. Sword');
  })());
  check('level-up still respects the 98% cap', (() => {
    const character = { level: 1, skills: [{ name: 'Prowl', type: 'occ', pct: 95, per_level: 5 }] };
    return buildProposal(character, { skills: {} }, 4).skills[0].to === CAP;
  })());
}

// ---------- 1c20. Alignments ----------
// p.23: seven alignments in three groups, and deliberately no neutral.
section('Alignments');
{
  const rulesGlobal = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'rules.js'), 'utf8'))
    .call(rulesGlobal, rulesGlobal);
  const R = rulesGlobal.rules;

  check('rules.js exposes the alignment helpers',
    !!R && Array.isArray(R.ALIGNMENTS) && typeof R.alignmentOptions === 'function');
  check('there are exactly seven alignments', R.ALIGNMENTS.length === 7, R.ALIGNMENTS.join(', '));
  check('all seven are the book\'s', (() => {
    const want = ['Principled', 'Scrupulous', 'Unprincipled', 'Anarchist',
                  'Miscreant', 'Aberrant', 'Diabolic'];
    return want.every((a) => R.ALIGNMENTS.includes(a)) && R.ALIGNMENTS.length === want.length;
  })());
  check('they fall into Good, Selfish and Evil',
    R.ALIGNMENT_GROUPS.map(([g]) => g).join(',') === 'Good,Selfish,Evil');
  check('each alignment reports its group',
    R.alignmentGroup('Principled') === 'Good' && R.alignmentGroup('Anarchist') === 'Selfish'
    && R.alignmentGroup('Diabolic') === 'Evil');

  // The book rules neutral out by name, in a paragraph explaining why. If it
  // ever appears in this list, something has widened it by accident.
  check('there is no neutral', !R.ALIGNMENTS.some((a) => /neutral/i.test(a))
    && !R.isAlignment('Neutral') && R.alignmentGroup('Neutral') === null);

  check('an unknown value is not an alignment',
    !R.isAlignment('') && !R.isAlignment('Lawful Good') && R.alignmentGroup('Lawful Good') === null);

  // Rendering a character that predates the list must not be a way to erase
  // what it had — the old value survives as its own selected option.
  check('a legacy value is preserved as an option', (() => {
    const html = R.alignmentOptions('Chaotic Neutral');
    return html.includes('Chaotic Neutral') && /Chaotic Neutral[^<]*<\/option>/.test(html)
      && html.includes('not a standard alignment');
  })());
  check('a known value is selected without a legacy option', (() => {
    const html = R.alignmentOptions('Aberrant');
    return html.includes('<option value="Aberrant" selected>') && !html.includes('not a standard alignment');
  })());
  check('an empty value selects the placeholder',
    R.alignmentOptions('').includes('<option value="" selected>'));
  check('options are grouped for the picker', (() => {
    const html = R.alignmentOptions('');
    return (html.match(/<optgroup/g) || []).length === 3;
  })());
  // The legacy value goes through an attribute, so it has to be escaped.
  check('a legacy value is escaped', !R.alignmentOptions('"><script>').includes('<script>'));

  // The sheet reads edited fields out of the DOM by selector. Alignment is the
  // first <select> among them, and matching only inputs would drop it silently.
  check('the sheet collects selects, not just inputs', (() => {
    const src = readFileSync(appPath('sheet.js'), 'utf8');
    return /querySelectorAll\('input\[data-sec\], select\[data-sec\]'\)/.test(src);
  })());
  // Both pages must actually load the shared list.
  check('both pages load rules.js', ['index.html', 'sheet.html'].every((f) =>
    readFileSync(appPath(f), 'utf8').includes('js/rules.js')));

  // ── starting money (p.22) ──
  check('currency is named per system',
    R.currencyLabel('palladium-fantasy') === 'Gold' && R.currencyLabel('rifts') === 'Credits');
  // An unknown system must not be guessed into one of the two.
  check('an unknown system gets the neutral word',
    R.currencyLabel('mystic-china') === 'Money' && R.currencyLabel(null) === 'Money'
    && R.currencyLabel(undefined) === 'Money');

  check('starting money rolls from a formula like a pool', (() => {
    const v = rollPoolFormula('2d6x10', {});
    return typeof v === 'number' && v >= 20 && v <= 120;
  })());
  check('a flat starting sum is taken as written', rollPoolFormula(500, {}) === 500);
  // A class that says nothing about money must not conjure a zero purse.
  check('no starting money stays absent',
    rollPoolFormula(null, {}) === null && rollPoolFormula(undefined, {}) === null);

  // The importer only ever returns fields the prompt names — the reason a whole
  // stat block went missing when `variants` shipped undocumented.
  check('the class import prompt documents starting_money', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'scripts', 'extraction-prompt.mjs'), 'utf8');
    return src.includes('starting_money');
  })());
  check('the hand-authoring templates show starting_money', (() => {
    const src = readFileSync(join(appDir, 'js', 'class-template.js'), 'utf8');
    return (src.match(/starting_money/g) || []).length >= 2;   // O.C.C. and R.C.C.
  })());
}

// ---------- 1c21. Starting money through the class layers ----------
// It has to survive both composition steps, or a dual-class or staged character
// silently starts penniless.
section('Starting money');
{
  const mk = (id, cat, extra) => parseClassMarkdown(
    `---\nid: ${id}\nname: ${id}\nsystem: palladium-fantasy\nsource_book: B\ncategory: ${cat}\n${extra}\n---\n\n## Lore\n\nx\n`).data;

  const dragon = mk('dragon', 'rcc', 'mdc_base: "1d4x100"');
  const bowman = mk('bowman', 'occ', 'hit_points_base: "P.E. + 1d6 per level"\nstarting_money: "2d6x10"');
  const richRace = mk('noble', 'rcc', 'starting_money: 900');

  // A race that says nothing about money takes the occupation's, exactly as the
  // pools do — otherwise every R.C.C. character starts with an empty purse.
  check('a race with no money takes the occupation\'s',
    combineClasses(dragon, bowman).starting_money === '2d6x10');
  // Where the race DOES state a sum, it is the race's own creature and wins.
  check('a race that states money keeps its own',
    combineClasses(richRace, bowman).starting_money === 900);
  check('an occupation with no money leaves the race\'s intact',
    combineClasses(richRace, mk('monk', 'occ', 'sdc_base: 20')).starting_money === 900);
  check('neither stating money leaves it absent',
    combineClasses(dragon, mk('monk', 'occ', 'sdc_base: 20')).starting_money === undefined);

  // A stage of a creature may be richer than another — a variant can restate it.
  const staged = mk('wyrm', 'rcc', `starting_money: 100
variants:
  - { id: hatchling, name: "Wyrm Hatchling" }
  - { id: adult, name: "Wyrm Adult", starting_money: 5000 }`);
  check('a variant may override starting money',
    applyVariant(staged, 'adult').starting_money === 5000);
  check('a variant that is silent inherits it',
    applyVariant(staged, 'hatchling').starting_money === 100);
}

// ---------- 1c22. Random psionics ----------
// Step 3, p.20-21. The table, the tiers it can reach, and how a rolled tier is
// folded into the class-shaped object everything downstream reads.
section('Random psionics');
{
  check('the table is the book\'s ranges', (() => {
    const t = (n) => psionicTierForRoll(n);
    return t(1) === 'major' && t(9) === 'major'
      && t(10) === 'minor' && t(25) === 'minor'
      && t(26) === null && t(100) === null;
  })());
  // 26-00 is the bulk of the table; a roll landing there is the ordinary result.
  check('most of the table is no psionics',
    Array.from({ length: 100 }, (_, i) => psionicTierForRoll(i + 1)).filter((x) => x === null).length === 75);
  check('a roll outside 1-100 yields nothing rather than guessing',
    psionicTierForRoll(0) === null && psionicTierForRoll(101) === null
    && psionicTierForRoll('x') === null && psionicTierForRoll(null) === null);
  // "A master psionic ... is available only from one of the psychic character
  // classes." Rolling must never reach it.
  check('rolling can never produce a master psionic',
    !Array.from({ length: 100 }, (_, i) => psionicTierForRoll(i + 1)).includes('master'));
  check('rollPsionics stays inside the table', (() => {
    for (let i = 0; i < 200; i++) {
      const r = rollPsionics();
      if (r.roll < 1 || r.roll > 100) return false;
      if (r.tier !== psionicTierForRoll(r.roll)) return false;
    }
    return true;
  })());

  // The shapes the book offers each tier.
  check('a minor psychic takes 2 powers from one category', (() => {
    const s = psionicShape('minor', 'focused');
    return s.count === 2 && s.categories === 1;
  })());
  check('a major psychic can take 8 from one or 6 from any', (() => {
    const f = psionicShape('major', 'focused'), b = psionicShape('major', 'broad');
    return f.count === 8 && f.categories === 1 && b.count === 6 && b.categories === 3;
  })());
  check('an unknown shape falls back to the tier\'s first',
    psionicShape('major', 'nonsense').id === 'focused' && psionicShape('minor', null).id === 'focused');
  check('a tier that cannot be rolled has no shapes', psionicShape('master', 'focused') === null);

  // I.S.P. formulas, including the per-level clause the level-up flow parses.
  check('minor I.S.P. is M.E. + 2d6, growing 1d6 a level', (() => {
    const f = PSIONIC_TIER_RULES.minor.isp_base;
    return /M\.E\./.test(f) && /2d6/.test(f) && perLevelDiceOf(f) === '1d6';
  })());
  // The +1 is the part that used to be dropped: matching only the dice cost a
  // major psychic a point of I.S.P. at every level, for life.
  check('major I.S.P. is M.E. + 4d6, growing 1d6+1 a level', (() => {
    const f = PSIONIC_TIER_RULES.major.isp_base;
    return /4d6/.test(f) && perLevelDiceOf(f) === '1d6+1';
  })());
  check('a per-level modifier survives into the roll', (() => {
    const v = evalDice('1d6+1');
    return v >= 2 && v <= 7;
  })());

  // Folding a rolled tier into the class object.
  const plain = { id: 'bowman', name: 'Bowman' };
  check('a character with no roll is untouched',
    withRolledPsionics(plain, { psychic_tier: null }) === plain);
  check('a rolled tier becomes a psionics block', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'major', psychic_shape: 'broad' });
    return c.psionics.type === 'major' && c.psionics.powers_starting === 6
      && c.psionics.from_roll === true;
  })());
  check('the focused shape grants its larger count', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'major', psychic_shape: 'focused' });
    return c.psionics.powers_starting === 8;
  })());
  // Rolled psychics draw from three categories; Super is master-only.
  check('a rolled psychic cannot reach Super powers', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'minor' });
    return !c.psionics.categories_allowed.includes('Super')
      && c.psionics.categories_allowed.length === 3;
  })());
  // A psychic O.C.C. has already answered the question and never rolls.
  check('a class that grants psionics is not overwritten', (() => {
    const mage = { id: 'mind-mage', psionics: { type: 'master', isp_base: '3d6' } };
    const c = withRolledPsionics(mage, { psychic_tier: 'minor' });
    return c === mage && c.psionics.type === 'master';
  })());
  check('an unrecognised tier is ignored',
    withRolledPsionics(plain, { psychic_tier: 'master' }) === plain
    && withRolledPsionics(plain, { psychic_tier: 'wizardly' }) === plain);

  // The create endpoint gained two columns. A miscounted placeholder list is a
  // runtime error on the first save and invisible until then.
  check('the character INSERT binds exactly what it declares', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'characters.js'), 'utf8');
    const i = src.indexOf('INSERT INTO characters');
    const end = src.indexOf('RETURNING id', i);
    const seg = src.slice(i, end);
    const cols = seg.slice(seg.indexOf('(') + 1, seg.indexOf(')')).split(',').map((s) => s.trim()).filter(Boolean);
    let v = seg.slice(seg.indexOf('VALUES') + 6);
    v = v.slice(v.indexOf('(') + 1, v.lastIndexOf(')'));
    const slots = v.split(',').map((s) => s.trim()).filter(Boolean);
    const placeholders = slots.filter((s) => s === '?').length;
    // Bind arguments, split at depth zero so nested calls do not miscount.
    const bt = src.slice(src.indexOf('.bind(', end) + 6, src.indexOf('.first()', end));
    let depth = 0, cur = '', args = [];
    for (const ch of bt) {
      if ('([{'.includes(ch)) depth++;
      if (')]}'.includes(ch)) depth--;
      if (ch === ',' && depth === 0) { args.push(cur.trim()); cur = ''; } else cur += ch;
    }
    if (cur.trim()) args.push(cur.trim());
    args = args.filter(Boolean);
    return cols.length === slots.length && placeholders === args.length;
  })());
}

// ---------- 1c23. Keys a class can actually grant ----------
// A bonus written for a key derive does not expose is silently inert: it parses,
// it stores, it renders nowhere. Three real class bonuses sat as prose for
// exactly that reason before these keys existed.
section('Bonus keys');
{
  const combat = D.combat({ PS: 10, PP: 10 }, null);
  const saves = D.saves({ PE: 10, ME: 10 }, null);

  check('pull punch is a combat key', 'pull_punch' in combat);
  check('the illusionary magic and mind control saves exist',
    'illusionary_magic' in saves && 'mind_control' in saves);

  // Pull punch is in the Hand to Hand tables, not on the attribute chart: it is
  // trained, not innate, so no attribute moves it.
  check('pull punch derives nothing from attributes', (() => {
    const low = D.combat({ PS: 3, PP: 3 }, null).pull_punch;
    const high = D.combat({ PS: 30, PP: 30 }, null).pull_punch;
    return low === 0 && high === 0;
  })());
  // The two saves borrow the printed row for their own attribute.
  check('illusionary magic follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).illusionary_magic === 0 && s(18).illusionary_magic === s(18).spell_magic
      && s(30).illusionary_magic === 8;
  })());
  check('mind control follows the M.E. psionic row', (() => {
    const s = (me) => D.saves({ ME: me }, null);
    return s(15).mind_control === 0 && s(18).mind_control === s(18).psionics
      && s(30).mind_control === 8;
  })());

  // The point of the exercise: a class bonus for each now reaches the sheet.
  check('a class can grant all three', (() => {
    const bonuses = { attributes: {}, combat: { pull_punch: 2 },
                      saves: { illusionary_magic: 3, mind_control: 6 } };
    const c = D.combat({ PS: 10 }, null, bonuses);
    const s = D.saves({ PE: 10, ME: 10 }, null, null, bonuses);
    return c.pull_punch === 2 && s.illusionary_magic === 3 && s.mind_control === 6;
  })());

  // The sheet has to list them, or the value is computed and never shown.
  check('the sheet prints all three', (() => {
    const src = readFileSync(appPath('sheet.js'), 'utf8');
    return ['pull_punch', 'illusionary_magic', 'mind_control'].every((k) => src.includes(`'${k}'`));
  })());

  // Guard scripts: `_` is a single-character WILDCARD in a LIKE pattern, so
  // '%mind_control%' also matches the words "mind control". A guard written that
  // way silently matches nothing and the migration does nothing.
  check('no data script guards an underscored key with LIKE', (() => {
    const dir = join(appDir, 'db');
    const bad = [];
    for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql'))) {
      const src = readFileSync(join(dir, f), 'utf8');
      // Any LIKE pattern containing an underscore, including one built by
      // concatenation -- '%item_id: "' || slug || '"%' has the same hazard.
      for (const m of src.matchAll(/LIKE\s+('[^']*_[^']*')/gi)) bad.push(`${f}: ${m[1]}`);
    }
    return bad.length === 0;
  })(), 'use instr() instead: ');
}

// ---------- 1c24. Dice-valued attribute bonuses ----------
// A book states some attribute bonuses as a roll: "add 2D6 to P.S." (Juicer),
// "+1D4 to M.A., M.E., P.S., P.E. and Spd" (Cyber-Knight). The dice belong to
// the class; what they came up belongs to the character, because a roll cannot
// be re-evaluated on every render.
section('Dice attribute bonuses');
{
  const mk = (bonuses) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n${bonuses}\n---\n\n## Lore\n\nx\n`);

  check('a dice attribute bonus is accepted', mk('bonuses:\n  attributes: { PS: "2d6" }').ok);
  check('a multiplied dice bonus is accepted', mk('bonuses:\n  attributes: { Spd: "2d4x10" }').ok);
  check('a flat attribute bonus still works', mk('bonuses:\n  attributes: { PS: 2 }').ok);
  check('nonsense is still rejected', (() => {
    const r = mk('bonuses:\n  attributes: { PS: "a lot" }');
    return !r.ok && r.errors.some((e) => /number or a dice expression/.test(e));
  })());
  // Every group takes dice now. Combat and saves were flat-only on the
  // assumption books always print them that way; the Godling's "+1D4 on
  // initiative" is the counter-example, and it was a hard parse error.
  check('a dice bonus is accepted in combat', mk('bonuses:\n  combat: { initiative: "1d4" }').ok);
  check('and in saves', mk('bonuses:\n  saves: { spell_magic: "1d4" }').ok);
  check('prose is still refused there',
    !mk('bonuses:\n  combat: { strike: "a lot" }').ok);

  // An unrolled dice bonus must contribute nothing rather than guess an average.
  const cls = mk('bonuses:\n  attributes: { PS: "2d6", Spd: "2d4x10" }').data;
  check('an unrolled dice bonus contributes nothing', (() => {
    const b = D.classBonuses(cls, 1);
    return (b.attributes.PS ?? 0) === 0 && (b.attributes.Spd ?? 0) === 0;
  })());
  check('the rolled value is what applies', (() => {
    const b = D.classBonuses(cls, 1, { PS: 7, Spd: 40 });
    const eff = D.effective({ PS: 14, Spd: 12 }, b);
    return b.attributes.PS === 7 && eff.PS === 21 && eff.Spd === 52;
  })());
  check('diceBonuses lists what needs rolling', (() => {
    const d = D.diceBonuses(cls);
    return d.PS === '2d6' && d.Spd === '2d4x10' && Object.keys(d).length === 2;
  })());
  check('a class with no dice bonuses needs no roll',
    Object.keys(D.diceBonuses(mk('bonuses:\n  attributes: { PS: 2 }').data)).length === 0);

  // "Minimum P.S. is 22; if lower, adjust up to P.S. 22."
  const floored = mk('bonuses:\n  attributes: { PS: "2d6" }\n  attribute_minimums: { PS: 22 }').data;
  check('a minimum is accepted and parsed', !!floored.bonuses.attribute_minimums);
  check('the floor lifts a low total', (() => {
    const b = D.classBonuses(floored, 1, { PS: 4 });
    return D.effective({ PS: 11 }, b).PS === 22;   // 11 + 4 = 15, floored to 22
  })());
  check('the floor never lowers a high total', (() => {
    const b = D.classBonuses(floored, 1, { PS: 12 });
    return D.effective({ PS: 18 }, b).PS === 30;   // 18 + 12 = 30, above the floor
  })());
  // A floor must not conjure an attribute the character does not have, any more
  // than a bonus does.
  check('a floor on an absent attribute is ignored', (() => {
    const b = D.classBonuses(floored, 1, { PS: 4 });
    return D.effective({ ME: 10 }, b).PS === undefined;
  })());
  check('a bad minimum is rejected',
    !mk('bonuses:\n  attribute_minimums: { PS: "lots" }').ok
    && !mk('bonuses:\n  attribute_minimums: { Wisdom: 12 }').ok);

  // The sheet has to pass the character's rolled values through, or a Juicer's
  // +2D6 P.S. silently contributes nothing there.
  check('the sheet passes rolled bonuses to classBonuses', (() => {
    const src = readFileSync(appPath('sheet.js'), 'utf8');
    // Grouped now, so a class's DICE combat and save bonuses count on the sheet
    // as well as its attribute ones.
    return /classBonuses\(cls, c\.level, \{/.test(src)
      && /attributes: c\.attribute_bonuses/.test(src)
      && /combat: c\.rolled_bonuses/.test(src)
      && /saves: c\.rolled_bonuses/.test(src);
  })());
}

// ---------- 1c24c. Dice combat and save bonuses ----------
// "+1D4 on initiative" (Godling R.C.C., Rifts Pantheons p.16). Combat and save
// bonuses were flat-only, so this was a hard parse error. They are rolled ONCE
// and stored for the same reason attribute dice are: both are read at render
// time, and a roll re-evaluated per render moves the number under the player.
section('Dice combat and save bonuses');
{
  const mk = (b) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: rcc',
     'bonuses:', b, '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));

  const ok = mk('  combat: { initiative: "1d4", attacks: 1 }');
  check('a dice combat bonus parses beside a flat one',
    ok.errors.length === 0, ok.errors.join('; '));
  check('and keeps both as written',
    ok.data.bonuses.combat.initiative === '1d4' && ok.data.bonuses.combat.attacks === 1);
  check('a dice save bonus parses', mk('  saves: { spell_magic: "1d4" }').errors.length === 0);
  check('prose is still refused',
    mk('  combat: { strike: "a fair bit" }').errors.some((e) => e.includes('must be a number')));

  // Collected per group, so the wizard knows what to roll and store.
  const byGroup = derive.diceBonusesByGroup(ok.data);
  check('the dice are collected under their group', byGroup.combat.initiative === '1d4');
  check('and a FLAT bonus is not collected for rolling',
    byGroup.combat.attacks === undefined);
  check('attributes still come through the same call',
    derive.diceBonusesByGroup(mk('  attributes: { PS: "2d6" }').data).attributes.PS === '2d6');

  // classBonuses counts the ROLLED value, never the expression.
  const rolled = { attributes: {}, combat: { initiative: 3 }, saves: {} };
  check('a rolled dice combat bonus is counted',
    derive.classBonuses(ok.data, 1, rolled).combat.initiative === 3);
  check('and the flat one beside it still counts',
    derive.classBonuses(ok.data, 1, rolled).combat.attacks === 1);
  check('an unrolled dice bonus contributes nothing rather than guessing',
    (derive.classBonuses(ok.data, 1, { attributes: {}, combat: {}, saves: {} }).combat.initiative ?? 0) === 0);

  // The legacy flat shape is what every character saved before this holds.
  const legacy = mk('  attributes: { PS: "2d6" }').data;
  check('a flat attribute map is still understood',
    derive.classBonuses(legacy, 1, { PS: 7 }).attributes.PS === 7);
  check('and a grouped one is told apart from it',
    derive.classBonuses(legacy, 1, { attributes: { PS: 7 }, combat: {}, saves: {} }).attributes.PS === 7);

  // Two classes composing: the same collect-not-drop rule the other groups use.
  const race = mk('  combat: { initiative: "1d4" }').data;
  const occ = parseClassMarkdown(
    ['---', 'id: o', 'name: O', 'system: rifts', 'source_book: b', 'category: occ',
     'bonuses:', '  combat: { initiative: "1d6" }', '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  check('two dice combat bonuses collect rather than one being dropped',
    JSON.stringify(combineClasses(race, occ).bonuses.combat.initiative) === '["1d4","1d6"]',
    JSON.stringify(combineClasses(race, occ).bonuses.combat.initiative));
  check('and both are offered for rolling',
    JSON.stringify(derive.diceBonusesByGroup(combineClasses(race, occ)).combat.initiative) === '["1d4","1d6"]');

  // The wizard stores what it rolled; the sheet reads it back. Pinned as source
  // checks because both are page scripts the test cannot execute.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard rolls the grouped dice bonuses', /diceBonusesByGroup/.test(appSrc));
  // The race's rolls and the occupation's are held apart in state, so what the
  // save sends is the SUM of the two. Sending S.rolledBonuses alone would drop
  // every dice bonus the occupation granted - the same loss combineClasses had
  // to be taught once already.
  check('stores what they came up, both halves',
    /rolled_bonuses: \{ combat: rolled\.combat, saves: rolled\.saves \}/.test(appSrc));
  check('and the attribute bonuses are the summed ones too',
    /attribute_bonuses: rolled\.attributes/.test(appSrc));
  // A third half since BOOK-INGEST-AUDIT F56: the totem animal's dice roll on
  // their own, and a sum that dropped them would lose the Bear's +1D4 P.S.
  check('rolledAll sums the race, the occupation and the totem',
    /attributes: sumRolled\(sumRolled\(S\.attrBonuses, S\.occAttrBonuses\), S\.totemAttrBonuses\)/.test(appSrc));
  check('and keeps them across a draft',
    ['rolledBonuses', 'occRolledBonuses', 'totemRolledBonuses'].every((k) => DRAFT_KEYS.includes(k)));
}

// ---------- 1c25. Per-category skill restrictions ----------
// Every book states what a category allows: "Espionage: Escape Artist only",
// "Physical: any except Acrobatics, Gymnastics and Wrestling". We offered each
// category wholesale, so a Long Bowman could take Pick Pockets as Espionage.
section('Category restrictions');
{
  const cats = ['Domestic',
    { name: 'Espionage', only: ['Escape Artist'] },
    { name: 'Physical', except: ['Acrobatics', 'Gymnastics'] }];
  const allows = (name, category) => categoryAllows(cats, { name, category });

  check('an unrestricted category admits anything in it', allows('Cook', 'Domestic'));
  check('a category not listed at all is refused', !allows('Basic Math', 'Science'));
  check('only-lists admit just what they name',
    allows('Escape Artist', 'Espionage') && !allows('Pick Pockets', 'Espionage'));
  check('except-lists admit everything but what they name',
    allows('Climbing', 'Physical') && !allows('Acrobatics', 'Physical') && !allows('Gymnastics', 'Physical'));
  check('matching ignores case and padding',
    categoryAllows(cats, { name: '  escape artist ', category: 'ESPIONAGE' }));
  // An empty or absent list means "any", which is what most classes state.
  check('no list restricts nothing',
    categoryAllows([], { name: 'X', category: 'Y' }) && categoryAllows(null, { name: 'X', category: 'Y' }));

  // A skill named in an `only` list reaches past the game filter for that grant
  // (the Chiang-Ku Dragon's modern W.P.s). Named is not "in the category": an
  // unrestricted or except-narrowed category names nothing.
  check('namedByOnly is true only for a name an only-list states',
    namedByOnly(cats, { name: ' escape artist', category: 'Espionage' })
    && !namedByOnly(cats, { name: 'Cook', category: 'Domestic' })
    && !namedByOnly(cats, { name: 'Climbing', category: 'Physical' })
    && !namedByOnly(null, { name: 'Escape Artist' }));
  check('the wizard and the NPC generator both let an only-named skill past the game filter', (() => {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const gen = readFileSync(join(appDir, 'js', 'npc-generate.js'), 'utf8');
    return /namedByOnly\(categories, sk\)/.test(app) && /namedByOnly\(categories, r\)/.test(gen);
  })());

  check('a label says what the restriction is', (() => {
    const l = cats.map(categoryLabel);
    return l[0] === 'Domestic' && l[1] === 'Espionage (Escape Artist only)'
      && l[2] === 'Physical (except Acrobatics, Gymnastics)';
  })());

  const mk = (catsYaml) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  occ_related_skills:\n    count: 2\n    categories:\n${catsYaml}\n---\n\n## Lore\n\nx\n`);

  check('plain strings still parse', mk('      - "Wilderness"').ok);
  check('an object entry parses', mk('      - { name: "Espionage", only: ["Escape Artist"] }').ok);
  check('an object without a name is rejected', !mk('      - { only: ["X"] }').ok);
  check('a non-list only is rejected', !mk('      - { name: "Espionage", only: "Escape Artist" }').ok);
  // "only these, except some of them" is just a shorter only-list; guessing
  // which was meant is worse than refusing.
  check('setting both only and except is rejected', (() => {
    const r = mk('      - { name: "Espionage", only: ["A"], except: ["B"] }');
    return !r.ok && r.errors.some((e) => /both only and except/.test(e));
  })());

  // The picker and the server-side validator must not disagree about what is
  // legal, which is why they share one helper rather than each having a copy.
  check('the wizard filters through the shared helper', (() => {
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return /categoryAllows\(categories, sk\)/.test(src);
  })());
  check('the validator uses the same helper', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'validate-character.js'), 'utf8');
    return src.includes('categoryAllows(allowed,');
  })());

  // ---- prefix forms (BOOK-INGEST-AUDIT.md F23(b)) ----
  // A book excluding a FAMILY: "Technical: All, except lore" is 14 rows, and
  // "Pilot: All, except robots & power armor and robot combat" is one exact
  // name plus 13 more. Enumerating either would rot as the catalog grows.
  const pilot = [{ name: 'Pilot', except: ['Robots & Power Armor'], except_prefix: ['Robot Combat'] }];
  check('an except_prefix excludes the whole family',
    !categoryAllows(pilot, { name: 'Robot Combat: Basic', category: 'Pilot' })
    && !categoryAllows(pilot, { name: 'Robot Combat Elite: SAMAS', category: 'Pilot' }));
  check('and leaves everything else in the category alone',
    categoryAllows(pilot, { name: 'Airplane', category: 'Pilot' }));
  // The Pilot line needs BOTH forms at once, and could not be written without
  // it: one exact name and one family.
  check('an exact except and a prefix except work together',
    !categoryAllows(pilot, { name: 'Robots & Power Armor', category: 'Pilot' })
    && !categoryAllows(pilot, { name: 'Robot Combat: Basic', category: 'Pilot' }));
  // Two `Lore:` rows are filed under Cowboy. A prefix that reached across
  // categories would strip them from a Cowboy grant that never mentioned lore.
  check('a prefix is scoped to its own category and does not leak',
    categoryAllows([{ name: 'Cowboy' }], { name: 'Lore: Cattle & Animals', category: 'Cowboy' })
    && !categoryAllows([{ name: 'Technical', except_prefix: ['Lore'] }],
      { name: 'Lore: Magic', category: 'Technical' }));
  check('an only_prefix admits just that family',
    categoryAllows([{ name: 'Pilot', only_prefix: ['Robot Combat'] }],
      { name: 'Robot Combat: Basic', category: 'Pilot' })
    && !categoryAllows([{ name: 'Pilot', only_prefix: ['Robot Combat'] }],
      { name: 'Airplane', category: 'Pilot' }));
  check('a label shows the prefix rather than hiding it',
    categoryLabel(pilot[0]) === 'Pilot (except Robots & Power Armor, Robot Combat...)');
  check('mixing an only form with an except form is still refused',
    !mk('      - { name: "Espionage", only: ["A"], except_prefix: ["B"] }').ok
    && !mk('      - { name: "Espionage", only_prefix: ["A"], except: ["B"] }').ok);
  check('but two EXCLUDING forms together are legal',
    mk('      - { name: "Pilot", except: ["A"], except_prefix: ["B"] }').ok);
  check('a non-list prefix is rejected',
    !mk('      - { name: "Pilot", except_prefix: "Robot Combat" }').ok);
}

// ---------- Inline handlers are reachable ----------
// app.js is a MODULE, so a function it declares is module-scoped and an inline
// `onclick="fn()"` attribute is evaluated in the GLOBAL scope. The bridge is
// one `Object.assign(window, { ... })` near the bottom, and a handler left out
// of it renders perfectly and throws ReferenceError the moment it is clicked.
//
// Found the hard way: `toggleProgram` shipped in F23(b) missing from that list.
// The picker drew thirteen checkboxes and every one of them was dead. Nothing
// caught it because nothing in the suite CLICKS anything - the markup was
// right, the function existed, and the two were never introduced.
section('Inline handlers are reachable');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  const exposed = (src.match(/Object\.assign\(window,\s*\{([\s\S]*?)\}\);/) || [, ''])[1];
  const listed = new Set(exposed.replace(/\/\/[^\n]*/g, '')
    .split(/[,\s]+/).map((s) => s.trim().replace(/:$/, '')).filter(Boolean));

  // Every name called from an inline event attribute in a template literal.
  const called = new Set();
  for (const m of src.matchAll(/\bon[a-z]+="\s*([A-Za-z_$][\w$]*)\s*\(/g)) called.add(m[1]);

  // Browser builtins that need no bridge.
  const BUILTIN = new Set(['alert', 'confirm', 'print', 'open', 'close']);
  const missing = [...called].filter((n) => !listed.has(n) && !BUILTIN.has(n));

  check('some inline handlers were found to check', called.size > 5, `found ${called.size}`);
  check('every inline handler is exposed on window',
    missing.length === 0, missing.join(', '));
}

// ---------- Skill programs ----------
// BOOK-INGEST-AUDIT.md F23(b). Triax printed 170 gives the NGR Robot Soldier up
// to THREE skill CATEGORIES, granting every skill each one allows at a flat 38%
// with no bonuses and no gain per level. `occ_related_skills` picks skills from
// a list of categories; this picks categories and grants their contents, and a
// count large enough to cover them would let the player spend it anywhere.
section('Skill programs');
{
  const prog = (yaml) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  skill_programs:\n${yaml}\n---\n\n## Lore\n\nx\n`);
  const ok3 = '    choose: 3\n    base: 38\n    per_level: 0\n    categories:\n'
    + '      - "Communications"\n      - "Domestic"\n      - "Military"\n';

  check('a well-formed block parses', prog(ok3).ok, JSON.stringify(prog(ok3).errors));
  check('and keeps the flat base and the zero per-level', (() => {
    const p = prog(ok3).data.skills.skill_programs;
    return p.base === 38 && p.per_level === 0 && p.choose === 3;
  })());
  check('a block with no base is rejected',
    !prog('    choose: 1\n    categories:\n      - "Domestic"\n').ok);
  check('choose must be a whole number above zero',
    !prog('    choose: 0\n    base: 38\n    categories:\n      - "Domestic"\n').ok);
  // Offering three picks from two categories is a transcription slip every
  // time, and it fails as a quietly short list rather than as anything visible.
  check('choosing more programs than are offered is rejected',
    !prog('    choose: 3\n    base: 38\n    categories:\n      - "Domestic"\n').ok);
  check('a block with no categories is rejected',
    !prog('    choose: 1\n    base: 38\n').ok);
  // One flat percentage is the whole idea, so a per-category adjustment would
  // be stored and never read - the silent no-op this rejects up front.
  check('a per-category bonus is rejected',
    !prog('    choose: 1\n    base: 38\n    categories:\n      - { name: "Domestic", bonus: 5 }\n').ok);
  check('the category grammar is the shared one, prefixes included',
    prog('    choose: 1\n    base: 38\n    categories:\n'
      + '      - { name: "Technical", except_prefix: ["Lore"] }\n').ok);

  // THE CARRY. combineClasses rebuilds `skills` wholesale from the RACE's
  // block, so without an explicit line an occupation's programs vanish while a
  // race's survive - and the only class that has one is an O.C.C. The block
  // would have done nothing for the class it was built for, silently.
  check('combineClasses carries an occupation\'s programs across the merge', (() => {
    const occ = prog(ok3).data;
    const race = { id: 'r', name: 'R', skills: { occ_skills: [] } };
    const merged = combineClasses(race, { ...occ, id: 'o', name: 'O' });
    return merged.skills.skill_programs?.choose === 3
      && merged.skills.skill_programs?.base === 38;
  })());
  check('and a race\'s programs survive a merge too', (() => {
    const race = { ...prog(ok3).data, id: 'r', name: 'R' };
    const merged = combineClasses(race, { id: 'o', name: 'O', skills: { occ_skills: [] } });
    return merged.skills.skill_programs?.choose === 3;
  })());
  check('a class with no programs gains none from the merge', (() => {
    const merged = combineClasses(
      { id: 'r', name: 'R', skills: { occ_skills: [] } },
      { id: 'o', name: 'O', skills: { occ_skills: [] } });
    return merged.skills.skill_programs === undefined;
  })());

  // The sheet renders skills by an explicit list of types, so a type it does
  // not name is SAVED AND INVISIBLE.
  check('the sheet renders the program type', (() => {
    const src = readFileSync(appPath('sheet.js'), 'utf8');
    return /byType\('program'\)/.test(src);
  })());
  // A program's restriction names have to be checked like any other, and the
  // `only` direction fails CLOSED - a typo grants the player nothing.
  check('class-check walks skill_programs for restriction names', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'scripts', 'class-check-lib.mjs'), 'utf8');
    return src.includes("'skill_programs'");
  })());
  check('and so does the server-side collector', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'catalog.js'), 'utf8');
    return src.includes('skill_programs');
  })());
}

// ---------- Super abilities ----------
// Heroes Unlimited's fifth power kind, and the R.C.C. half of D1's slot mapping:
// a Power Category sits in the race slot and grants super abilities, an
// Educational Level sits in the occupation slot and grants skill programs.
// See apps/character-creator/docs/surveys/heroes-unlimited-core.md G6.
//
// A super ability is a permanent trait with a range, a duration and a damage,
// NO cost and NO level - which is why it needed migration 057's own table
// rather than a spell row, and why every check below that would ask about a
// cost asks about a TIER instead.
section('Super abilities');
{
  const sup = (yaml) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: heroes-unlimited\nsource_book: B\ncategory: rcc\n`
    + `super_abilities:\n${yaml}---\n\n## Lore\n\nx\n`);
  const split = '  abilities_starting: 2\n  abilities_starting_groups:\n'
    + '    - { count: 1, tiers: ["major"] }\n    - { count: 1, tiers: ["minor"] }\n';

  check('a well-formed block parses', sup(split).ok, JSON.stringify(sup(split).errors));
  check('and it is not reported as an unmodelled key',
    unmodelledKeys(sup(split).data).length === 0,
    unmodelledKeys(sup(split).data).join(', '));

  // The tier vocabulary is CLOSED at two, unlike a skill or psionic category.
  // A typo there is a rule nothing can satisfy, so the picker comes back empty
  // rather than merely short.
  check('an unknown tier is rejected',
    !sup('  abilities_starting: 1\n  tiers_allowed: ["mega"]\n').ok);
  check('an empty tiers_allowed is rejected',
    !sup('  abilities_starting: 1\n  tiers_allowed: []\n').ok);
  check('a group with no count is rejected',
    !sup('  abilities_starting_groups:\n    - { tiers: ["minor"] }\n').ok);
  check('a group naming an unknown tier is rejected',
    !sup('  abilities_starting_groups:\n    - { count: 1, tiers: ["huge"] }\n').ok);
  check('abilities must be a list of names',
    !sup('  abilities_starting: 1\n  abilities: 3\n').ok);

  // REFUSED RATHER THAN STORED. `pending_power_picks` has columns for a spell
  // level, a tradition, a category and a name list - none for a tier - so a
  // banked per-level grant would come back ungated and spend against all 364
  // rows. Nothing in either book asks for one.
  check('a per-level grant is refused, not silently stored',
    !sup('  abilities_per_level: 1\n').ok);
  check('and so is a schedule',
    !sup('  abilities_schedule:\n    - { level: 4, count: 1 }\n').ok);

  // The silent-storage shape: parses, stores, grows a heading, offers nothing.
  check('a block that grants nothing warns',
    sup('  tiers_allowed: ["minor"]\n').warnings.some((w) => /grants no super abilities/.test(w)));

  // THE GATE REACHES THE PICKER. startingGroups is what both the wizard and the
  // create validator read, so a tier that does not survive it is a gate that
  // exists in the frontmatter and nowhere else.
  check('startingGroups splits the pick by tier', (() => {
    const g = startingGroups(sup(split).data, 'super');
    return g.length === 2 && g[0].count === 1 && g[0].tiers?.[0] === 'major'
        && g[1].tiers?.[0] === 'minor';
  })());
  check('a named list replaces the tier gate', (() => {
    const g = startingGroups(sup('  abilities_starting: 1\n'
      + '  abilities_from: ["Alter Physical Structure: Stone"]\n').data, 'super');
    return g.length === 1 && g[0].tiers === null && g[0].from?.length === 1;
  })());
  check('a class with no block offers no groups',
    startingGroups({ id: 'x' }, 'super').length === 0);

  // THE CARRY, and the three cases that are actually the explicit line's.
  //
  // A RACE's block needs no line at all: combineClasses opens with
  // `const out = { ...rcc }`, so it survives by the spread. Asserting it was
  // this section's one vacuous check - removing the line left it passing - and
  // it is kept below only as the baseline the other three are measured against.
  const plain = { id: 'o', name: 'O', skills: { occ_skills: [] } };
  check('a Power Category\'s block survives the merge', (() => {
    const merged = combineClasses({ ...sup(split).data, id: 'r', name: 'R' }, plain);
    return merged.super_abilities?.abilities_starting === 2
        && merged.super_abilities?.abilities_starting_groups?.length === 2;
  })());
  // This one is the line. `out` is seeded from the RACE, so an occupation's
  // block has no way into the composed class without it - the mirror of the
  // defect skill_programs shipped with, where the race's was the orphan.
  check('and so does an occupation\'s', (() => {
    const merged = combineClasses({ id: 'r', name: 'R', skills: { occ_skills: [] } },
                                  { ...sup(split).data, id: 'o', name: 'O' });
    return merged.super_abilities?.abilities_starting === 2;
  })());
  check('two blocks ADD rather than one winning', (() => {
    const race = { ...sup('  abilities_starting: 2\n').data, id: 'r', name: 'R' };
    const occ = { ...sup('  abilities_starting: 1\n').data, id: 'o', name: 'O',
                  skills: { occ_skills: [] } };
    return combineClasses(race, occ).super_abilities?.abilities_starting === 3;
  })());
  // A SUPERSEDING OCCUPATION DOES NOT ERASE IT, which is not what was expected
  // and is pinned here because it is what the code does. `out` is seeded from
  // the race and the branch hands back `occ.X || rcc.X`, so a superseding
  // occupation stating no block leaves the race's standing - and `magic` and
  // `psionics` behave identically here. BOOK-INGEST-AUDIT.md F81, taken
  // 2026-09-15 as a correction to the COMMENT above `magic`, which claimed the
  // opposite: the code agreed with both user-facing specs and the comment did
  // not. These checks pinned the behaviour before that was settled and pin it
  // still.
  check('a superseding occupation does NOT erase the race\'s block (F81)', (() => {
    const race = { ...sup(split).data, id: 'r', name: 'R' };
    const merged = combineClasses(race, { ...plain, supersedes_race: true });
    return merged.super_abilities?.abilities_starting === 2;
  })());
  check('and magic and psionics do the same thing today', (() => {
    const race = { id: 'r', name: 'R', skills: { occ_skills: [] },
                   magic: { type: 'spell', spells_starting: 4 },
                   psionics: { type: 'major', powers_starting: 2 } };
    const merged = combineClasses(race, { ...plain, supersedes_race: true });
    return merged.magic?.spells_starting === 4 && merged.psionics?.powers_starting === 2;
  })());

  // THE ASYMMETRY THE THREE BLOCKS DO HAVE, which F81 did not name and nothing
  // pinned: when the superseding occ STATES a block, magic and super_abilities
  // take it OUTRIGHT, while psionics merges - promoting the tier and taking the
  // max of the counts (F10). All three agree about an occ that states nothing;
  // two of three differ about one that states something. No class reaches this
  // case, so it is pinned rather than reconciled - and a future change to any
  // of the three fails here by name instead of silently.
  check('but a superseding occ that STATES a block is where they differ (F81)', (() => {
    const race = { id: 'r', name: 'R', skills: { occ_skills: [] },
                   magic: { type: 'spell', spells_starting: 4 },
                   psionics: { type: 'major', powers_starting: 2 } };
    const merged = combineClasses(race, { ...plain, supersedes_race: true,
                                          magic: { type: 'spell' },
                                          psionics: { type: 'minor' } });
    // magic takes the occ's outright, so the race's count is GONE ...
    const magicTaken = merged.magic?.spells_starting === undefined;
    // ... while psionics merges, keeping the race's count and its higher tier.
    const psiMerged = merged.psionics?.powers_starting === 2
                   && merged.psionics?.type === 'major';
    return magicTaken && psiMerged;
  })());
  check('a class with no block gains none from the merge', (() => {
    const merged = combineClasses({ id: 'r', name: 'R', skills: { occ_skills: [] } }, plain);
    return merged.super_abilities === undefined;
  })());

  // THE PACKAGE CHOICE. Experiments' Table C is six whole outcomes - "one major
  // and three minor" against "four minor" - and an ability choice group whose
  // options each carry a block is the only shape that can offer one. The
  // commonest case is a category granting NOTHING itself, so the option's block
  // has to arrive whole rather than merge into an absent one.
  const pkg = parseClassMarkdown(['---', 'id: t', 'name: T', 'system: heroes-unlimited',
    'source_book: B', 'category: rcc', 'special_abilities:',
    '  - name: "One major and three minor"',
    '    description: "Table C, 01-20."',
    '    super_abilities: { abilities_starting: 4, abilities_starting_groups: [{ count: 1, tiers: ["major"] }, { count: 3, tiers: ["minor"] }] }',
    '  - name: "Four minor"',
    '    description: "Table C, 21-40."',
    '    super_abilities: { abilities_starting: 4, abilities_starting_groups: [{ count: 4, tiers: ["minor"] }] }',
    '  - { choose: 1, from: ["One major and three minor", "Four minor"] }',
    '---', '', '## Lore', '', 'x', ''].join('\n'));
  check('a class offering packages parses', pkg.ok, JSON.stringify(pkg.errors));
  check('the option\'s block arrives whole when the class states none', (() => {
    const out = applyAbilities(pkg.data, ['Four minor']);
    const g = startingGroups(out, 'super');
    return g.length === 1 && g[0].count === 4 && g[0].tiers?.[0] === 'minor';
  })());
  check('and a class that grants none offers none until one is chosen',
    startingGroups(pkg.data, 'super').length === 0);
  check('an option carrying a block is validated like the class\'s own', (() => {
    const bad = parseClassMarkdown(['---', 'id: t', 'name: T', 'system: heroes-unlimited',
      'source_book: B', 'category: rcc', 'special_abilities:',
      '  - name: "X"', '    description: "x"',
      '    super_abilities: { abilities_starting: 1, tiers_allowed: ["mega"] }',
      '---', '', '## Lore', '', 'x', ''].join('\n'));
    return !bad.ok;
  })());

  // THE SERVER REFUSES WHAT THE PICKER WOULD NOT OFFER. One rule, both sides -
  // the same posture the psionic category gate has.
  {
    const cls = { ...sup(split).data, category: 'rcc' };
    const catalog = { spell: new Map(), psionic: new Map(), super: new Map([
      ['growth', { name: 'Growth', tier: 'major', system: 'heroes-unlimited' }],
      ['heightened sense of smell', { name: 'Heightened Sense of Smell', tier: 'minor', system: 'heroes-unlimited' }],
    ]) };
    const base = { cls, level: 1, attributes: {}, skills: [], powerCatalog: catalog,
                   system: 'heroes-unlimited' };
    const legal = validateCharacter({ ...base,
      powers: [{ type: 'super', name: 'Growth' }, { type: 'super', name: 'Heightened Sense of Smell' }] });
    check('one major and one minor is accepted', legal.violations.length === 0,
      JSON.stringify(legal.violations));
    const twoMajor = validateCharacter({ ...base,
      powers: [{ type: 'super', name: 'Growth' }, { type: 'super', name: 'Growth' }] });
    check('the same ability twice is refused',
      twoMajor.violations.some((v) => v.rule === 'duplicate_power'));
    const overCount = validateCharacter({ ...base, cls: { ...cls,
      super_abilities: { abilities_starting: 1, abilities_starting_groups: [{ count: 1, tiers: ['minor'] }] } },
      powers: [{ type: 'super', name: 'Heightened Sense of Smell' }, { type: 'super', name: 'Growth' }] });
    check('more picks than the allowance is refused',
      overCount.violations.some((v) => v.rule === 'power_count' && v.kind === 'super'));
    // The count message pluralises from a MAP: appending an s gives
    // "super abilitys", which is why the third kind needed one.
    check('and the message says "super abilities", not "super abilitys"',
      overCount.violations.some((v) => /super abilities/.test(v.message) && !/abilitys/.test(v.message)));
    const wrongTier = validateCharacter({ ...base, cls: { ...cls,
      super_abilities: { abilities_starting: 1, abilities_starting_groups: [{ count: 1, tiers: ['minor'] }] } },
      powers: [{ type: 'super', name: 'Growth' }] });
    check('a major pick against a minor-only gate is refused',
      wrongTier.violations.some((v) => v.rule === 'power_tier' && v.tier === 'major'));
    const unknown = validateCharacter({ ...base,
      powers: [{ type: 'super', name: 'Not An Ability' }] });
    check('a name the catalog does not hold is refused',
      unknown.violations.some((v) => v.rule === 'power_unknown' && v.kind === 'super'));
    // Granted outright, not chosen - exempt from the count the way a class's
    // own spells and psionic powers are.
    const granted = validateCharacter({ ...base, cls: { ...cls,
      super_abilities: { abilities: ['Growth'], abilities_starting: 0 } },
      powers: [{ type: 'super', name: 'Growth' }] });
    check('an ability the category grants outright is exempt from the count',
      granted.violations.length === 0, JSON.stringify(granted.violations));
  }

  // THE THREE CARRIES a new power block needs, checked as source rather than as
  // behaviour because each one is a place the block could be dropped silently.
  check('the wizard reads the block', (() => {
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return /startingGroups\(cls, 'super'\)/.test(src)
      && /startingSuperHtml/.test(src)
      && /type: 'super'/.test(src);
  })());
  check('the sheet groups super abilities apart from psionics', (() => {
    const src = readFileSync(appPath('sheet.js'), 'utf8');
    return /KIND_ORDER/.test(src) && /Super abilities \u2014/.test(src);
  })());
  check('the boot payload serves the catalog', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'catalogs.js'), 'utf8');
    return /FROM super_abilities/.test(src) && /superAbilities: supers\.results/.test(src);
  })());
  // 994KB of description across 364 rows would be forty times the rest of the
  // payload, on every wizard boot and every sheet load.
  check('and does NOT send the descriptions with it', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'catalogs.js'), 'utf8');
    const stmt = (src.match(/SELECT [^`]*FROM super_abilities/) || [''])[0];
    return stmt.length > 0 && !/description/.test(stmt);
  })());
  check('the sheet gets a description from the right table', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'power-picks.js'), 'utf8');
    return /'superAbilities', 'super_abilities'/.test(src) && /CATALOG_OF/.test(src);
  })());
  check('class-check cross-references the names', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'catalog.js'), 'utf8');
    return /referencedSuperAbilities/.test(src);
  })());
  // A super ability name that matches no row is a TRANSCRIPTION ERROR - both
  // books' lists are imported whole - so nothing stubs one.
  check('and never stubs one', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'catalog.js'), 'utf8');
    const stub = src.slice(src.indexOf('export function buildStubStatements'));
    return !/superAbilities/.test(stub);
  })());
}

await skillRuleChecks();


// ---------- 1c25a3. A spell against the row it retells ----------
// BOOK-INGEST-AUDIT F26. `spells.same_spell_as` links a retelling to the row
// another book already published it as, so the pair can be checked for drift -
// which drift-check cannot do, because both rows cite pages that agree with
// them. These fixtures are the REAL strings out of the catalog, trimmed, and
// they are here because each one broke a simpler version of this comparison.
section('A spell against the row it retells');
{
  // Metric rounding. Both convert 120 feet; one says 36.5 m and the other 36.6.
  check('a parenthetical metric conversion is not a difference',
    mechanicalNumbers('120 foot (36.5 m) radius; up to 500 feet (153 m) away.')
    === mechanicalNumbers('120 foot (36.6 m) radius of effect can be cast up to 500 feet (153 m) away'));
  // A gloss one book carries and the other does not.
  check('nor is a parenthetical gloss',
    mechanicalNumbers('One minute per level of the spell caster.')
    === mechanicalNumbers('One minute (4 melee rounds) per level of the Warlock'));
  check('a number word equals its digits',
    mechanicalNumbers('Ten minutes per level of experience.')
    === mechanicalNumbers('10 minutes per level of experience'));
  // The thing it must still catch.
  check('but a real difference in the numbers IS one',
    mechanicalNumbers('One mile (1.6 km) radius per level of experience.')
    !== mechanicalNumbers('80 foot (24.4 m) radius per level of experience.'));

  check('overlap is scored against the shorter text',
    descriptionOverlap('the caster floats upon the water', 'the caster floats upon the water and more words here') > 0.9);
  check('and unrelated text scores low',
    descriptionOverlap('the caster floats upon the water', 'lightning strikes a distant tower') < 0.2);

  // A pair that really is the same spell told twice.
  const ocean = { range: '120 foot (36.5 m) radius; can be cast up to 500 feet (153 m) away.',
    duration: 'One minute per level of the spell caster.', saving_throw: 'None', area_of_effect: null,
    level: 9, ppe: 50,
    description: 'Creates a whirlpool that drags swimmers and small craft toward its centre, ten feet per melee round.' };
  const water = { range: '120 foot (36.6 m) radius of effect can be cast up to 500 feet (153 m) away',
    duration: 'One minute (4 melee rounds) per level of the Warlock', saving_throw: 'None.', area_of_effect: null,
    level: 5, ppe: 40,
    description: 'The Warlock creates a whirlpool; swimmers and small craft are dragged toward its centre at ten feet per melee round.' };
  check('a genuine retelling reports no problems', comparePair(ocean, water).length === 0,
    comparePair(ocean, water).join('; '));

  // Same spell, same price. This must NOT be reported - F26's title says "two
  // costs" and two of its own nine pairs have one cost.
  const samePrice = { ...ocean, level: 5, ppe: 40 };
  check('a retelling at the SAME level and cost is still fine',
    comparePair(samePrice, water).length === 0, comparePair(samePrice, water).join('; '));

  // The four pairs deliberately left unlinked would fail, which is why.
  const diverged = { ...ocean, range: 'One mile (1.6 km) radius per level of experience.' };
  check('a pair whose mechanics diverge is reported',
    comparePair(diverged, water).some((p) => p.startsWith('range:')),
    comparePair(diverged, water).join('; '));

  // The drift the link exists to catch.
  const gutted = { ...ocean, description: 'TODO' };
  check('a gutted description is reported',
    comparePair(gutted, water).some((p) => p.startsWith('description:')),
    comparePair(gutted, water).join('; '));
  const emptied = { ...ocean, description: '' };
  check('and an emptied one is too',
    comparePair(emptied, water).some((p) => p.startsWith('description:')));
  const swapped = { ...ocean, description: 'A bolt of lightning leaps from the outstretched hand and strikes one target.' };
  check('and a description replaced with another spell text is too',
    comparePair(swapped, water).some((p) => p.startsWith('description:')),
    comparePair(swapped, water).join('; '));
}

// ---------- 1c25a2. Skill names inside an MOS option ----------
// BOOK-INGEST-AUDIT F27. An MOS option's skills were collected by NOTHING, so a
// name no catalog row has read as `skills ok` and shipped. Proved by putting the
// SAME bogus name in an MOS option and in `occ_skills` and watching only the
// second be reported - a check that has only ever passed proves nothing.
//
// Two things are pinned here rather than one. `referencedMosSkills` must find
// the names; `restrictionNames` must reach an `only`/`except` nested one level
// deeper, inside an option's own choice group. The second was NOT assumed to be
// broken when the finding was written - it was measured, and it was.
section('MOS option skill names are collected');
{
  const cls = parseClassMarkdown(`---
id: t
name: T
system: rifts
source_book: b
category: occ
occ_group: men-of-arms
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 45, per_level: 5 }
  mos:
    choose: 1
    options:
      - id: "gunner"
        name: "Gunner"
        skills:
          - { name: "Weapon Systems", base: 50, per_level: 5 }
          - { choose: 1, from: ["Demolitions", "Sniper"], bonus: 10 }
      - id: "scout"
        name: "Scout"
        skills:
          - { choose: 2, categories: [{ name: "Espionage", only: ["Tracking"] }], bonus: 5 }
---

## Lore

x
`).data;

  const mos = referencedMosSkills(cls);
  check('a plain skill inside an option is collected', mos.includes('Weapon Systems'));
  check('and every option of a choice group inside an option is too',
    mos.includes('Demolitions') && mos.includes('Sniper'),
    `got: ${mos.join(', ')}`);
  check('all of them, from every option, and nothing else', mos.length === 3,
    `got ${mos.length}: ${mos.join(', ')}`);
  // The separation that makes the no-stubbing structural. A caller stubs
  // `missing.skills`; if MOS names were folded in there, a typo would become a
  // permanent catalog row spelled the wrong way that the class then resolves
  // against happily.
  check('occ_skills does not swallow them, so they can be reported separately',
    !mos.includes('Radio: Basic'));

  const named = restrictionNames(cls);
  const inMos = named.filter((n) => n.name === 'Tracking');
  check('an only/except inside an MOS option is reached', inMos.length === 1,
    `got ${inMos.length}`);
  check('and it says which option it came from',
    inMos[0]?.category === 'scout/Espionage' && inMos[0]?.kind === 'only',
    `got ${inMos[0]?.category} ${inMos[0]?.kind}`);
}

// ---------- 1c25b. Restrictions that name nothing ----------
// A category restriction names skills by hand, and `categoryAllows` compares
// literal names. So a name no catalog row has does not fail — an `except`
// excludes NOTHING and the class silently offers a skill the book forbids.
// Found importing the Godling R.C.C.: it bars robots, power armor and
// cybernetics, and the catalog spells those "Robots & Power Armor",
// "Robot Combat: Basic" and "M.D. in Cybernetics", so all three did nothing.
// The Godling then outlived the fix. Its import corrected two of the three and
// left "Robots and Power Armor"; the catalog LATER renamed that row to the
// ampersand spelling and kept the old one as a redirect, which restrictions do
// not consult, so the exclusion went on doing nothing for months while every
// catalog check passed. A rename can break a restriction that was right when it
// was written, and only this cross-reference will say so.
section('Unresolved category restrictions');
{
  const cls = parseClassMarkdown(`---
id: t
name: T
system: rifts
source_book: b
category: rcc
skills:
  occ_related_skills:
    count: 8
    categories:
      - "Physical"
      - { name: "Medical", except: ["Cybernetics"] }
      - { name: "Pilot", except: ["Robot Combat", "Power Armor Combat"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Mechanical", only: ["Locksmith"] }
  secondary_skills:
    count: 5
    categories:
      - { name: "Science", only: ["Astrophysics"] }
---

## Lore

x
`).data;

  const named = restrictionNames(cls);
  check('every named skill in every restriction is collected', named.length === 6,
    `got ${named.length}: ${named.map((n) => n.name).join(', ')}`);
  check('a bare category name contributes nothing',
    !named.some((n) => n.category === 'Physical'));
  check('secondary restrictions are collected too',
    named.some((n) => n.category === 'Science' && n.kind === 'only'));
  check('each carries its category and which kind it is',
    named.every((n) => n.category && (n.kind === 'only' || n.kind === 'except') && n.name));

  // The filter the endpoint applies, with a stand-in catalog.
  const catalogHas = new Set(['computer hacking', 'locksmith', 'astrophysics']);
  const unresolved = named.filter((n) => !catalogHas.has(n.name.toLowerCase()));
  check('the three the catalog spells differently are reported',
    unresolved.length === 3
    && unresolved.every((n) => ['Cybernetics', 'Robot Combat', 'Power Armor Combat'].includes(n.name)),
    unresolved.map((n) => n.name).join(', '));
  check('and the ones that do resolve are not',
    !unresolved.some((n) => ['Computer Hacking', 'Locksmith', 'Astrophysics'].includes(n.name)));

  // The point of reporting it: this is what the unmatched `except` actually does.
  check('an unmatched except really does fail open',
    categoryAllows(cls.skills.occ_related_skills.categories,
      { name: 'M.D. in Cybernetics', category: 'Medical' }) === true);
  // While `only` fails closed, which is why the two are labelled differently.
  check('while an unmatched only fails closed',
    categoryAllows(cls.skills.secondary_skills.categories,
      { name: 'Astronomy', category: 'Science' }) === false);

  check('a class with no restrictions collects nothing',
    restrictionNames({ skills: { occ_related_skills: { categories: ['Physical'] } } }).length === 0);
  check('and nothing at all does not throw', restrictionNames(undefined).length === 0);
}

// ---------- 1c24b. Composing dice attribute bonuses ----------
// `sumBonusGroups` copied the second class's values only when they were numbers,
// so a dice-valued bonus arriving from the OCCUPATION was silently dropped: an
// R.C.C. composed with the Cyber-Knight lost all five of its +1D4s and nothing
// said so. Two dice cannot be summed into one expression, so they collect.
section('Composing dice attribute bonuses');
{
  const mk = (cat, b) => parseClassMarkdown(
    `---
id: ${cat}
name: ${cat}
system: rifts
source_book: b
category: ${cat}
bonuses:
${b}
---

## Lore

x
`).data;
  const merged = (a, b, attr) => combineClasses(mk('rcc', a), mk('occ', b)).bonuses.attributes[attr];

  check('a dice bonus from the OCCUPATION survives',
    merged('  combat: { attacks: 1 }', '  attributes: { PS: "1d4" }', 'PS') === '1d4');
  check('a dice bonus from the RACE still survives',
    merged('  attributes: { PS: "1d4" }', '  combat: { attacks: 1 }', 'PS') === '1d4');
  check('two dice for one attribute collect rather than overwrite',
    JSON.stringify(merged('  attributes: { PS: "1d4" }', '  attributes: { PS: "2d6" }', 'PS')) === '["1d4","2d6"]');
  check('two flat bonuses still add',
    merged('  attributes: { PS: 2 }', '  attributes: { PS: 3 }', 'PS') === 5);
  check('a flat and a dice bonus keep both',
    JSON.stringify(merged('  attributes: { PS: 2 }', '  attributes: { PS: "1d4" }', 'PS')) === '[2,"1d4"]');

  // The real case, from published classes: five attributes, all dice, all from
  // the occupation half.
  const ck = mk('occ', '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }');
  const withRace = combineClasses(mk('rcc', '  combat: { initiative: 2 }'), ck);
  check('all five Cyber-Knight-shaped dice bonuses survive composition',
    ['MA', 'ME', 'PS', 'PE', 'Spd'].every((k) => withRace.bonuses.attributes[k] === '1d4'),
    JSON.stringify(withRace.bonuses.attributes));

  // And through the rolling path, which is where a list has to be understood.
  const roll = (cls, attr, N = 20000) => {
    let total = 0;
    for (let i = 0; i < N; i++) {
      const rolled = {};
      for (const [k, d] of Object.entries(derive.diceBonuses(cls))) {
        const rolls = [d].flat().map((x) => (typeof x === 'number' ? x : evalDice(x))).filter((v) => v != null);
        if (rolls.length) rolled[k] = rolls.reduce((a, b) => a + b, 0);
      }
      total += derive.classBonuses(cls, 1, rolled).attributes[attr] || 0;
    }
    return total / N;
  };
  const near = (v, w) => Math.abs(v - w) < 0.35;
  const compose2 = (a, b) => combineClasses(mk('rcc', a), mk('occ', b));

  check('two composed dice both roll',
    near(roll(compose2('  attributes: { PS: "1d4" }', '  attributes: { PS: "2d6" }'), 'PS'), 9.5));
  check('a mixed flat-and-dice list keeps the flat part',
    near(roll(compose2('  attributes: { PS: 2 }', '  attributes: { PS: "1d4" }'), 'PS'), 4.5));
  check('a lone flat bonus is not double counted',
    near(roll(compose2('  attributes: { PS: 2 }', '  combat: { attacks: 1 }'), 'PS'), 2));
  check('a lone dice bonus is not double counted',
    near(roll(compose2('  attributes: { PS: "1d4" }', '  combat: { attacks: 1 }'), 'PS'), 2.5));

  // BOOK-INGEST-AUDIT F60. The checks above roll the COMPOSED class, a path the
  // wizard stopped taking on 2026-08-20: it rolls the race half, the occupation
  // alone and the totem row alone, each on its own, and sums them (rolledAll).
  // A mixed list's flat half is in none of those rolls, so it has to be counted
  // at render - which these ask, the way the wizard actually rolls.
  const rollOf = (cls) => {
    const out = { attributes: {}, combat: {}, saves: {} };
    const byGroup = derive.diceBonusesByGroup(cls);
    for (const g of ['attributes', 'combat', 'saves']) {
      for (const [k, d] of Object.entries(byGroup[g] || {})) {
        const rolls = [d].flat().map((x) => (typeof x === 'number' ? x : evalDice(x))).filter((v) => v != null);
        if (rolls.length) out[g][k] = rolls.reduce((a, b) => a + b, 0);
      }
    }
    return out;
  };
  const sumHalves = (...halves) => {
    const out = { attributes: {}, combat: {}, saves: {} };
    for (const h of halves) for (const g of Object.keys(out)) {
      for (const [k, v] of Object.entries(h[g])) out[g][k] = (out[g][k] || 0) + v;
    }
    return out;
  };
  const splitRoll = (composed, halves, group, key, N = 20000) => {
    let total = 0;
    for (let i = 0; i < N; i++) {
      total += derive.classBonuses(composed, 1, sumHalves(...halves.map(rollOf)))[group][key] || 0;
    }
    return total / N;
  };
  const split2 = (a, b, group, key) => {
    const race = mk('rcc', a);
    const occ = mk('occ', b);
    return splitRoll(combineClasses(race, occ), [race, occ], group, key);
  };
  check('rolled apart, a race\'s flat P.S. beside an occupation\'s dice is kept',
    near(split2('  attributes: { PS: 2 }', '  attributes: { PS: "1d4" }', 'attributes', 'PS'), 4.5));
  check('and a race\'s dice beside an occupation\'s flat, the direction production has',
    near(split2('  attributes: { PS: "1d4" }', '  attributes: { PS: 2 }', 'attributes', 'PS'), 4.5));
  check('and a flat PENALTY beside dice is kept too, not dropped in the character\'s favour',
    near(split2('  attributes: { PS: "1d4" }', '  attributes: { PS: -2 }', 'attributes', 'PS'), 0.5));
  check('a combat key the same way - a Godling\'s 1D4 initiative beside a flat +3',
    near(split2('  combat: { initiative: "1d4" }', '  combat: { initiative: 3 }', 'combat', 'initiative'), 5.5));
  // Hin-Ri's shape: a Juicer's 2D6 P.S. is rolled from the class alone, and a
  // skill's flat +5 arrives through composition (sumBonusGroups) and is never
  // rolled at all - catalog.md said it was, and no code path ever did it.
  const juicer = { bonuses: { attributes: { PS: '2d6' } } };
  const withSkills = { bonuses: sumBonusGroups(juicer.bonuses, { attributes: { PS: 5 } }) };
  check('a class\'s dice beside a skill\'s flat bonus counts both',
    near(splitRoll(withSkills, [juicer], 'attributes', 'PS'), 12));

  // The same collect-not-overwrite rule inside one class: a bonus at level 1 and
  // another at_level for the same attribute both count once the level is reached.
  const twice = mk('rcc', ['  attributes: { PS: "1d4" }',
                          '  at_level:',
                          '    - { level: 5, attributes: { PS: "1d6" } }'].join(String.fromCharCode(10)));
  check('a level-1 and an at_level dice bonus for one attribute both survive',
    JSON.stringify(derive.diceBonuses(twice).PS) === '["1d4","1d6"]',
    JSON.stringify(derive.diceBonuses(twice).PS));
}

// ---------- 1c25c. Pool bonuses ----------
// "P.P.E.: As per the appropriate O.C.C., plus 4D6" (Demigod R.C.C., Rifts
// Pantheons p.17). Fallthrough PLUS a modifier, which had no shape at all:
// stating it as a formula gave NULL P.P.E., and omitting it lost the +4D6. The
// faithful transcription was strictly worse than saying nothing.
section('Pool bonuses');
{
  const mk = (extra) => parseClassMarkdown(`---
id: t
name: T
system: rifts
source_book: b
category: rcc
${extra}
---

## Lore

x
`);

  const ok = mk(`bonuses:
  pools: { ppe: "4d6", isp: 5 }`);
  check('a dice pool bonus and a flat one both parse',
    ok.errors.length === 0 && ok.warnings.length === 0, ok.errors.concat(ok.warnings).join('; '));
  check('and survive parsing',
    ok.data.bonuses.pools.ppe === '4d6' && ok.data.bonuses.pools.isp === 5);

  const bad = mk(`bonuses:
  pools: { ppe: "lots" }`);
  check('prose is refused rather than ignored', bad.errors.length === 1, bad.errors.join('; '));
  const wrongKey = mk(`bonuses:
  pools: { stamina: 4 }`);
  check('a pool that does not exist is refused',
    wrongKey.errors.some((e) => e.includes('is not a pool')), wrongKey.errors.join('; '));
  const zero = mk(`bonuses:
  pools: { ppe: 0 }`);
  check('a zero bonus warns rather than passing silently',
    zero.warnings.some((w) => w.includes('will do nothing')));

  // Nothing applies a level-gated pool bonus, so it must not pass quietly.
  const atLevel = mk(`bonuses:
  at_level:
    - { level: 5, pools: { ppe: 10 } }`);
  check('a pool bonus at_level warns that nothing applies it',
    atLevel.warnings.some((w) => w.includes('is not applied')), atLevel.warnings.join('; '));

  check('the documented pool keys are the five the character has',
    POOL_BONUS_KEYS.join(',') === 'hp,sdc,mdc,ppe,isp');

  // Rolling. Means rather than ranges: hitting both extremes at once is rare
  // enough that a range check would pass on a bonus applied twice.
  const mean = (f, bonus) => { let s = 0; const N = 40000;
    for (let i = 0; i < N; i++) s += rollPoolFormula(f, { PE: 16 }, bonus); return s / N; };
  const near = (v, want, tol = 0.4) => Math.abs(v - want) < tol;

  check('a dice bonus is applied exactly once', near(mean('2d6', '4d6') - mean('2d6', null), 14));
  check('a flat bonus is applied exactly once', near(mean('2d6', 5) - mean('2d6', null), 5));
  check('a list of bonuses is summed', near(mean('2d6', ['4d6', '2d6']) - mean('2d6', null), 21));
  check('no bonus changes nothing', near(mean('2d6', null) - mean('2d6', undefined), 0));

  // The rule that keeps an M.D.C. race from acquiring hit points.
  check('a bonus cannot conjure a pool the class does not have',
    rollPoolFormula(null, { PE: 16 }, '4d6') === null
    && rollPoolFormula(undefined, { PE: 16 }, 10) === null);

  // Composition. The dice-dropping filter used by the other groups would lose
  // the occupation's bonus entirely, which is a live bug for attributes.
  const race = mk(`bonuses:
  pools: { ppe: "4d6" }`).data;
  const occ = parseClassMarkdown(`---
id: o
name: O
system: rifts
source_book: b
category: occ
ppe_base: "2d6"
bonuses:
  pools: { ppe: "2d6", mdc: 5 }
---

## Lore

x
`).data;
  const both = combineClasses(race, occ);
  check('two classes granting the same pool keep both bonuses',
    JSON.stringify(both.bonuses.pools.ppe) === '["4d6","2d6"]',
    JSON.stringify(both.bonuses.pools.ppe));
  check('a bonus only one side states still survives', both.bonuses.pools.mdc === 5);
  check('and a dice bonus from the OCCUPATION is not dropped',
    JSON.stringify(both.bonuses.pools.ppe).includes('2d6'));
  check('two flat bonuses for one pool are summed',
    combineClasses(mk(`bonuses:
  pools: { ppe: 3 }`).data,
                   mk(`bonuses:
  pools: { ppe: 4 }`).data).bonuses.pools.ppe === 7);
}

// ---------- 1c25e. Chosen ability fragments ----------
// A power the player picks, carrying what it grants. Chosen on the CLASS step,
// before attributes and pools are rolled, because the Godling's Super-Tough is
// +1D6 P.E. AND +3D4x10 M.D.C. - choosing later would re-roll what was read.
section('Chosen ability fragments');
{
  const lines = (...a) => a.join(String.fromCharCode(10));
  const src = lines(
    '---', 'id: godling', 'name: Godling', 'system: rifts', 'source_book: b', 'category: rcc',
    'mdc_base: "P.E. x 10"',
    'special_abilities:',
    '  - name: "Super-Tough"',
    '    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."',
    '    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }',
    '  - name: "Super-Psionic Powers"',
    '    description: "Two lesser categories."',
    '    psionics: { type: "master" }',
    '  - name: "Shape Shifter"',
    '    description: "One animal."',
    '    repeatable: true',
    '    on_repeat: "ANY normal animal."',
    '  - name: "Fly"',
    '    description: "Mystic flight."',
    '  - { choose: 3, from: ["Super-Tough", "Super-Psionic Powers", "Shape Shifter", "Fly"] }',
    '---', '', '## Lore', '', 'x', '');
  const parsed = parseClassMarkdown(src);
  check('a class with fragments parses cleanly', parsed.errors.length === 0, parsed.errors.join('; '));
  const cls = parsed.data;

  // FIVE since BOOK-INGEST-AUDIT F76 (migration 063). Pinned as a LIST rather
  // than a count, because the value of this check is that a key cannot be
  // added without someone reading applyAbilities - which is where a grant that
  // parses and is never folded in comes from.
  check('the grant keys are the five an ability may carry',
    ABILITY_GRANTS.join(',') === 'bonuses,psionics,magic,super_abilities,talents',
    ABILITY_GRANTS.join(','));

  // occ_options: an ability that names occupations (the Godling's Magic
  // Powers) turns its pick into a required occupation choice.
  const occCls = { special_abilities: [
    { name: 'Magic Powers', occ_options: ['ley-line-walker', 'mystic'] },
    { name: 'Fly' },
    { choose: 1, from: ['Magic Powers', 'Fly'] },
  ] };
  check('a chosen ability with occ_options demands an occupation',
    abilityOccOptions(occCls, ['Magic Powers'])?.options.join(',') === 'ley-line-walker,mystic');
  check('an unchosen one demands nothing', abilityOccOptions(occCls, ['Fly']) === null);
  check('and the check is case- and shape-tolerant',
    abilityOccOptions(occCls, [{ name: 'magic powers', gm: true }]) !== null);

  check('no picks leaves the class untouched', applyAbilities(cls, []) === cls);
  check('and undefined picks are the same', applyAbilities(cls, undefined) === cls);

  // related_skills_count: an ability that changes HOW MANY related skills the
  // class grants. BOOK-INGEST-AUDIT.md F24 - the Gypsy Gifted rolls one of four
  // psychic profiles, and two of them are master psionics who get NONE where
  // the other two get four.
  //
  // The ZERO is the whole point, so it is pinned specifically: a truthy check
  // would read 0 as "not set" and silently leave the class's four in place,
  // which is the bug rather than the fix.
  const branchCls = {
    skills: { occ_related_skills: { count: 4, categories: ['Rogue'] } },
    special_abilities: [
      { choose: 1, from: ['Major Gift', 'Master Gift'] },
      { name: 'Major Gift' },
      { name: 'Master Gift', related_skills_count: 0 },
    ],
  };
  const majorPick = applyAbilities(branchCls, ['Major Gift']);
  const masterPick = applyAbilities(branchCls, ['Master Gift']);
  check('an ability without related_skills_count leaves the count alone',
    majorPick.skills.occ_related_skills.count === 4);
  check('and one that sets it to ZERO is honoured, not read as unset',
    masterPick.skills.occ_related_skills.count === 0);
  check('the override is copy-on-write, so the class itself is untouched',
    branchCls.skills.occ_related_skills.count === 4);
  check('and it changes only the count, not what the class teaches',
    masterPick.skills.occ_related_skills.categories.join() === 'Rogue');

  const one = applyAbilities(cls, ['Super-Tough']);
  check('a fragment contributes its attribute bonus', one.bonuses?.attributes?.PE === '1d6');
  check('and its pool bonus', one.bonuses?.pools?.mdc === '3d4x10');
  check('the class keeps its own pool formula', one.mdc_base === 'P.E. x 10');
  check('what was taken is recorded for the sheet',
    one.abilities_taken?.length === 1 && one.abilities_taken[0].granted === true);

  // Duplicates are the point: the books give a second take a different meaning.
  const twice = applyAbilities(cls, ['Shape Shifter', 'Shape Shifter']);
  check('a repeated pick is counted, not collapsed',
    (twice.abilities_taken || []).map((a) => a.times).join(',') === '1,2');
  check('on_repeat surfaces only on the second take',
    twice.abilities_taken[0].on_repeat === undefined
    && twice.abilities_taken[1].on_repeat === 'ANY normal animal.');

  const doubled = applyAbilities(cls, ['Super-Tough', 'Super-Tough']);
  check('a repeated fragment applies its bonuses again',
    JSON.stringify(doubled.bonuses?.pools?.mdc) === '["3d4x10","3d4x10"]',
    JSON.stringify(doubled.bonuses?.pools?.mdc));

  // The stronger-tier rule composing a race with an occupation uses, so an
  // ability can never make a psychic weaker.
  check('an ability can raise the psychic tier',
    applyAbilities(cls, ['Super-Psionic Powers']).psionics?.type === 'master');
  const alreadyMaster = { ...cls, psionics: { type: 'master', isp_base: '4d6x10' } };
  check('and does not overwrite a stronger one it already had',
    applyAbilities(alreadyMaster, ['Super-Psionic Powers']).psionics?.isp_base === '4d6x10');

  // Magic takes the same fold. Built on the class above with one more defined
  // ability, so the fold is what is under test and not the parser.
  {
    const gift = { name: 'Magic Gift', magic: { type: 'innate', spells: ['Globe of Daylight'], spells_starting: 5 } };
    const withGift = (magic) => ({ ...cls, magic, special_abilities: [...(cls.special_abilities || []), gift] });
    const taken = (magic) => applyAbilities(withGift(magic), ['Magic Gift']).magic;
    check('an ability\'s magic arrives whole on a class with none',
      taken(undefined)?.type === 'innate' && taken(undefined).spells_starting === 5);
    // The Godling's shape: `none` is a statement, and its magic is the
    // occupation the ability demands.
    check('a class whose magic is `type: none` is left as it states',
      JSON.stringify(taken({ type: 'none' })) === '{"type":"none"}');
    const caster = taken({ type: 'wizardry', spells: ['Blind'], spells_starting: 3 });
    check('a class that casts keeps its own type', caster.type === 'wizardry');
    check('and gains the ability\'s spells and the higher count',
      [...caster.spells].sort().join() === 'Blind,Globe of Daylight' && caster.spells_starting === 5,
      JSON.stringify(caster));
  }

  // Recorded even when nothing defines it, or the sheet would disagree with
  // what the player actually chose.
  const unknown = applyAbilities(cls, ['Something The Book Only Describes']);
  check('an undefined pick is recorded but grants nothing',
    unknown.abilities_taken?.[0]?.granted === false && unknown.bonuses === cls.bonuses);


  // Shape errors that would otherwise be stored and ignored.
  const badGrant = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - name: "X"', '    bonuses: { combat: { strike: "quite a bit" } }',
    '---', '', '## Lore', '', 'x', ''));
  check('a fragment bonus is validated like any other',
    badGrant.errors.some((e) => e.includes('must be a number')), badGrant.errors.join('; '));
  const orphanRepeat = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - name: "X"', '    on_repeat: "twice"',
    '---', '', '## Lore', '', 'x', ''));
  check('on_repeat without repeatable warns that it is unreachable',
    orphanRepeat.warnings.some((w) => w.includes('can never be reached')));
  const undefOption = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - { choose: 1, from: ["Nothing Defines Me"] }',
    '---', '', '## Lore', '', 'x', ''));
  check('an option nothing defines warns rather than failing the class',
    undefOption.errors.length === 0
    && undefOption.warnings.some((w) => w.includes('grants nothing')));
}

// ---------- 1c25f. A race and an occupation, as the normal structure ----------
// A player picks a race and then an occupation. Both halves stay optional in the
// data because the exceptions are real - a human takes an O.C.C. and has no race
// at all, a Godling grants its own skills and stands alone - but the pairing is
// the normal case, and a racial class with nothing to CHOOSE is not a playable
// character by itself.
section("The wizard's split starting picker matches the same gate (BOOK-INGEST-AUDIT F69)");
{
  // app.js boots on import, so this is a source pin - and the entry-point parse
  // check above is what keeps a pin from passing against a file that cannot
  // parse at all.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('startingPsiHtml matches its categories with categoryAllows',
    /categoryAllows\(g\.categories, p\)/.test(appSrc));
  check('and no psionic picker matches a category with a plain includes',
    !/g\.categories\.includes\(p\.category\)/.test(appSrc));
  check('its caption labels the entries rather than joining objects',
    /g\.categories\.map\(categoryLabel\)/.test(appSrc));
}

section("The sheet's psionic pickers match an object category gate (BOOK-INGEST-AUDIT F66)");
{
  // The matcher itself, on the shape that broke the pickers: a category entry
  // that narrows itself with an except list, which a string never equals.
  const GATE = [{ name: 'Physical', except: ['Telekinesis'] }, 'Sensitive'];
  check('the shared matcher admits a power in an object-gated category',
    categoryAllows(GATE, { name: 'Alter Aura', category: 'Physical' }) === true);
  check('and refuses the one the entry excepts',
    categoryAllows(GATE, { name: 'Telekinesis', category: 'Physical' }) === false);
  check('a plain includes matches neither, which is the defect', GATE.includes('Physical') === false);
  check('and the entry has a label rather than printing as an object',
    categoryLabel(GATE[0]).includes('Physical'));

  // sheet.js is a classic script that cannot be imported, so its two pickers
  // are pinned as source - the shape F61 and F65 pinned for the same reason.
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet has one psionic category matcher, reached through the bridge',
    /const psiAdmits = \(cats, power\)/.test(sheetSrc)
    && /globalThis\.skillCats[\s\S]{0,40}categoryAllows\(cats, power\)/.test(sheetSrc));
  check('both psionic pickers use it', (sheetSrc.match(/psiAdmits\(/g) || []).length === 2);
  check('and neither matches a category with a plain includes any more',
    !/cats\.includes\(x\.category\)/.test(sheetSrc)
    && !/g\.categories\.includes\(x\.category\)/.test(sheetSrc));
  check('both captions label the entries rather than joining objects',
    (sheetSrc.match(/psiCatLabel\(/g) || []).length === 2);
  check('and the bridge exports the label helper those captions need',
    /globalThis\.skillCats = \{ categoryAllows, categoryLabel \}/
      .test(readFileSync(appPath('sheet.html'), 'utf8')));
}

section('An ability that changes a pool clears the rolled pools (BOOK-INGEST-AUDIT F67)');
{
  // Loaded as a NAMESPACE so a missing export fails a check rather than the
  // whole run at import - which is what these had to do before the fix existed.
  const P = await import('../js/parser.js');
  const touches = (def) => (typeof P.abilityTouchesPool === 'function' ? P.abilityTouchesPool(def) : undefined);

  check('a pool bonus counts', touches({ name: 'Super-Tough', bonuses: { pools: { mdc: '3d4x10' } } }) === true);
  check('so does the mega-damage conversion flag (F62/F64)',
    touches({ name: 'Powers of the Earth Realm', mdc_from_hp_sdc: true }) === true);
  // computePools rolls I.S.P. off the COMPOSED psionics block, which
  // applyAbilities merges an ability's into - so a Gift carrying its own
  // formula moves a rolled pool exactly as a pool bonus does.
  check('and so does an I.S.P. formula',
    touches({ name: 'The Gift', psionics: { type: 'major', isp_base: '2d6x10 + M.E. attribute' } }) === true);
  check('an ability granting none of the three does not', touches({ name: 'Nightvision', description: 'x' }) === false);
  check('an empty pools map does not', touches({ name: 'x', bonuses: { pools: {} } }) === false);
  check('a bonus to something else does not', touches({ name: 'x', bonuses: { attributes: { PS: '1d6' } } }) === false);
  check('and nothing at all is false rather than a crash', touches(null) === false && touches(undefined) === false);

  // app.js boots on import, so its two call sites are pinned as SOURCE - the
  // shape F61 and F65 pinned for the same reason.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard reads the shared predicate rather than keeping its own copy',
    /abilityTouchesPool\b/.test(appSrc));
  check('taking an ability clears the rolled pools',
    /S\.abilities\.push\(name\);\s*\n\s*poolsMayHaveChanged\(name\);/.test(appSrc));
  check('and both handlers do it', (appSrc.match(/poolsMayHaveChanged\(name\);/g) || []).length === 2);
  check('the definition lookup is case-folded, as applyAbilities keys its own',
    /d\.name\.trim\(\)\.toLowerCase\(\) === key/.test(appSrc));
}

section('A variant or an occupation change re-rolls the pools (BOOK-INGEST-AUDIT F68)');
{
  // app.js boots on import, so these are source pins. They are only worth
  // anything because 'The browser entry points parse' above now proves the file
  // the pins matched can actually load - on 2026-09-11 three pins passed
  // against an app.js that could not parse at all.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const clearsAndRecomposes = (fn) => {
    const body = new RegExp('function ' + fn + '\\(id\\) \\{([\\s\\S]{0,400}?)\\n\\}').exec(appSrc);
    return !!body && /clearRolledPools\(\);/.test(body[1]) && /recompose\(\);/.test(body[1]);
  };
  check('pickVariant clears the rolled pools and recomposes', clearsAndRecomposes('pickVariant'));
  check('pickOccVariant does the same for the occupation stage', clearsAndRecomposes('pickOccVariant'));
  check('the occupation variant select calls it instead of assigning S.occVariant inline',
    /onchange="pickOccVariant\(this\.value\)"/.test(appSrc) && !/S\.occVariant = this\.value/.test(appSrc));
  check('and it is exported to the global scope the inline handler evaluates in',
    /pickVariant, pickOccVariant, pickOcc/.test(appSrc));
  check('pickOcc clears them too, after rolling its own bonuses',
    /rollOccBonuses\(\);[\s\S]{0,400}?clearRolledPools\(\);/.test(appSrc));
  // pickTotem is the pattern all of this cites and was never pinned.
  check('and pickTotem, the handler this pattern came from, still does',
    /function pickTotem\(slug\) \{[\s\S]{0,300}?clearRolledPools\(\);/.test(appSrc));
}

section('An attribute or a psionic tier re-rolls the pools (BOOK-INGEST-AUDIT F70)');
{
  // Source pins again, for the reason the F68 section gives: app.js boots on
  // import. 'The browser entry points parse' above is what makes them mean
  // something.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const body = (fn) => {
    const m = new RegExp('function ' + fn + '\\(([^)]*)\\) \\{([\\s\\S]{0,600}?)\\n\\}').exec(appSrc);
    return m ? m[2] : '';
  };
  const oneLiner = (fn) => (new RegExp('function ' + fn + '\\([^)]*\\) \\{.*').exec(appSrc) || [''])[0];

  check('attrsChanged() is the one place the attribute handlers clear the pools',
    /function attrsChanged\(\) \{ clearRolledPools\(\); \}/.test(appSrc));
  check('setRoll calls it, so every rolled attribute is covered by one line',
    /attrsChanged\(\);/.test(body('setRoll')));
  for (const fn of ['setMethod', 'setAllMethod', 'manualSet']) {
    check(fn + ' calls it too', /attrsChanged\(\);/.test(oneLiner(fn)));
  }
  check('pbAdj calls it after the point-buy budget guard, not before',
    /S\.attrs\[a\] = cur; return; \}\s+attrsChanged\(\);/.test(appSrc));
  check('doPsiRoll clears them, because the rolled TIER is where isp_base comes from',
    /clearRolledPools\(\);/.test(body('doPsiRoll')));
  check('and skipPsiRoll, which moves the same input the other way',
    /clearRolledPools\(\);/.test(body('skipPsiRoll')));
  // The correction F70 itself got wrong, and the one most likely to be
  // "fixed" back: a shape selects powers_starting and categories_allowed and
  // moves no pool formula, so clearing there would re-roll the pools and the
  // starting money for nothing.
  check('setPsiShape deliberately does NOT, and says so in a comment',
    !/clearRolledPools/.test(oneLiner('setPsiShape'))
    && /setPsiShape below is deliberately NOT given this line/.test(appSrc));

  check('clearAttrsWhoseDiceChanged compares the dice by VALUE and only where they moved',
    /const moved = ATTRS\.filter\(\(a\) => method\(a\) === 'roll' && !same\(a\)\);/.test(appSrc));
  check('and drops the minimum-reroll log entries that would name cleared attributes',
    /S\.minRerolls = \(S\.minRerolls \|\| \[\]\)\.filter\(\(r\) => !moved\.includes\(r\.attr\)\);/.test(appSrc));
  for (const fn of ['pickVariant', 'pickOccVariant']) {
    const b = body(fn);
    check(fn + ' reads the dice BEFORE recompose and clears after',
      /const dice = S\.cls\?\.attribute_dice;/.test(b)
      && /clearAttrsWhoseDiceChanged\(dice\);/.test(b)
      && b.indexOf('const dice') < b.indexOf('recompose()'));
  }
}

section('The level pools are cleared with the pools they sit on (BOOK-INGEST-AUDIT F71)');
{
  // Source pins, same standing as F67/F68/F70's: app.js boots on import, and
  // 'The browser entry points parse' above is what makes a text match mean the
  // file can actually load.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('one helper clears both halves of the sheet maximum',
    /function clearRolledPools\(\) \{ S\.pools = null; S\.levelPools = \{\}; \}/.test(appSrc));
  // The count is the point of the finding: nine statements, and a tenth that
  // forgets S.levelPools is exactly what this shape exists to prevent.
  const bare = (appSrc.match(/S\.pools = null/g) || []).length;
  check('and it is the ONLY place S.pools is nulled', bare === 1, 'sites: ' + bare);
  // The tenth is occAbilitiesChanged (F125): a pick from an occupation's group.
  // Nine since 2026-10-10: resetBuild was one of the ten, and it now clears the
  // whole build from js/wizard-state.js's list, which holds both halves.
  check('every clear site calls it - nine of them',
    (appSrc.match(/clearRolledPools\(\);/g) || []).length === 9,
    'calls: ' + (appSrc.match(/clearRolledPools\(\);/g) || []).length);
  check('and a class change clears both halves with the rest of the build',
    freshBuild().pools === null && JSON.stringify(freshBuild().levelPools) === '{}');
  // rerollAdvancement(lvl) reaches computePools() through rollAdvancement's
  // lazy branch, so a clear inside computePools would wipe the other levels.
  const cp = /function computePools\(force = false\) \{([\s\S]*?)\n\}/.exec(appSrc);
  check('computePools does NOT call it, or rolling one level would wipe the rest',
    !!cp && !/clearRolledPools/.test(cp[1]));
  check('and the reason is written where the helper is',
    /Deliberately NOT called from computePools\(\)/.test(appSrc));
  // The level picks are choices, not rolls. F72.
  check('the level spells, psionics and skill picks are left standing, and say why',
    !/clearRolledPools\(\) \{[^}]*levelSpells/.test(appSrc)
    && /what the player CHOSE, not what the dice produced/.test(appSrc));
  check('rollAdvancement still short-circuits on a non-empty S.levelPools',
    /if \(!force && !onlyLevel && Object\.keys\(S\.levelPools\)\.length\) return;/.test(appSrc));
}

section('A border that identifies a control clears 3:1 (UI-AUDIT F55)');
{
  // The first contrast arithmetic in this suite. It exists because F6 shipped a
  // token raise, recorded the measured ratios in a comment, and the comment was
  // the only thing holding them - by 2026-09-12 every figure in F6's own text
  // was stale and the substance still held, which is the worst combination to
  // read. This recomputes from the declared values.
  const sharedCss = readFileSync(join(repoRoot, 'shared', 'styles.css'), 'utf8');
  const appCss = readFileSync(join(appDir, 'styles.css'), 'utf8');
  const noComments = (src) => src.replace(/\/\*[\s\S]*?\*\//g, '');
  const tokenIn = (src, name) =>
    (noComments(src).match(new RegExp('--' + name + ':\\s*(#[0-9a-fA-F]{6});')) || [])[1];

  const lum = (h) => {
    const c = [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255)
      .map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
  };
  // 0 for anything that is not a six-digit hex, so a DELETED token fails these
  // checks instead of throwing and taking the other 1958 down with it. Proven
  // by stashing the stylesheets: the section reports nine failures, not a stack
  // trace.
  const ratio = (a, b) => {
    if (!/^#[0-9a-fA-F]{6}$/.test(a || '') || !/^#[0-9a-fA-F]{6}$/.test(b || '')) return 0;
    const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
    return (hi + 0.05) / (lo + 0.05);
  };

  // TWO PALETTES ARE LIVE SINCE 2026-09-20, so this runs twice. Board & Tissue
  // retoned the five RPG apps through a :root in THIS app's stylesheet, which
  // those five load after shared; FilamentForge, MediaVault and Pick 3 Cut 5
  // load their own file instead and keep shared's Ley Verdigris. Checking only
  // shared would have left the palette the RPG suite actually renders with
  // entirely unmeasured - and it is the one that changed.
  //
  // The override is read on its own rather than merged over shared: it declares
  // every token in this section, so a value that silently stopped being
  // overridden should fail here rather than fall back and pass.
  const palettes = [
    ['the RPG suite', appCss],
    ['the other three apps', sharedCss],
  ];

  for (const [who, css] of palettes) {
    const token = (n) => tokenIn(css, n);
    const grounds = ['bg-primary', 'bg-secondary', 'bg-tertiary'].map((n) => [n, token(n)]);
    check('every ground and both border tokens are declared as hex for ' + who,
      grounds.every(([, v]) => !!v) && !!token('border') && !!token('border-control'),
      JSON.stringify(grounds));

    // The point of the finding: a control edge owes 3:1 on every ground it can
    // be drawn on, and --border cannot carry one.
    for (const [name, bg] of grounds) {
      const r = ratio(token('border-control'), bg);
      check('--border-control clears 3:1 on --' + name + ' for ' + who, r >= 3, r.toFixed(2));
    }
    // And the pair that IS the depth idiom is deliberately still below it, so a
    // later "tidy" that points a control at --border-strong fails here.
    check('--border-strong is still NOT a control colour for ' + who
      + ', which is why F55 added a third token',
      ratio(token('border-strong'), token('bg-tertiary')) < 3,
      ratio(token('border-strong'), token('bg-tertiary')).toFixed(2));
  }

  // The three call sites the finding moved, and the ones it deliberately did not.
  // `.mc-btn` rides on the same rule: the shared campaign views' buttons
  // (shared/js/campaign/) are this button under another name, not a second one.
  check('the shared button takes it', /\.btn, \.mc-btn \{[\s\S]{0,400}?border: 1px solid var\(--border-control\);/.test(sharedCss));
  check('every text-entry control takes it',
    /input\[type=text\], input\[type=number\], select, textarea \{[\s\S]{0,400}?border: 1px solid var\(--border-control\);/.test(appCss));
  check('and the stepper state that N4 left carrying itself',
    /\.st\.na \{ border-bottom-style: dashed; border-bottom-color: var\(--border-control\);/.test(appCss));
  check('plate edges are left on --border, so the lit-edge idiom survives',
    (appCss.match(/var\(--border\)/g) || []).length > 10);
}

section('An O.C.C. is warned about what a race will discard (BOOK-INGEST-AUDIT F11)');
{
  // F11 shipped supersedes_race and left its cheaper alternative unbuilt for
  // twelve days. The warning is what would have caught the Kreeghor
  // Cosmo-Knight on the day it was imported.
  const cc = readFileSync(join(repoRoot, 'scripts', 'class-check.mjs'), 'utf8');
  check('class-check knows the eight keys combineClasses hands to the race',
    // Not a copy of them any more: it asks the registry the merge loops over.
    /const LOST_TO_RACE = keysMergedBy\('race-first'\);/.test(cc));
  check('and warns only for an O.C.C. that has not claimed supersedes_race',
    /data\?\.category === 'occ' && data\?\.supersedes_race !== true/.test(cc));
  check('it is a WARNING, so it cannot fire the exit code on the common case',
    /warnings\.push\(stated\.length/.test(cc));
  // The list is the one the parser actually branches on. If someone adds an
  // ninth key there, this fails rather than the warning going quietly stale.
  const parser = readFileSync(join(appDir, 'js', 'parser.js'), 'utf8');
  // The loop reads CLASS_MERGE's `race-first` keys since 2026-10-10, so the
  // eight are held where they are stated and the loop is held to reading them.
  const { keysMergedBy: mergedBy } = await import('../js/class-keys.js');
  check('and the parser still hands exactly those eight to the race',
    /for \(const key of keysMergedBy\('race-first'\)\) \{/.test(parser)
    && mergedBy('race-first').join() === 'attribute_dice,hit_points_base,sdc_base,mdc_base,ppe_base,starting_money,horror_factor,second_form',
    mergedBy('race-first').join());
  // `xp_table` rode that loop - and this list - until 2026-09-17, when an
  // occupation's ladder started winning a pairing (Nate's decision in
  // docs/surveys/nightbane-core.md). A race discards nothing of it now, so an
  // O.C.C. stating one must not be warned that it will be lost.
  check('xp_table is NOT among them: the occupation’s ladder wins a pairing',
    !/LOST_TO_RACE[\s\S]{0,200}xp_table/.test(cc)
    // "Bar a race that keeps its own": BOOK-INGEST-AUDIT F122's one opt-out.
    && /if \(occ\.xp_table != null && !keepsLadder\) out\.xp_table = occ\.xp_table;/.test(parser));
  // A race's `pairing_skills` (F114) narrows its own list in a pairing; with
  // no key the helper hands back the whole list, so the union is still the
  // default and still nothing an occupation is warned about.
  check('occ_skills is deliberately NOT among them, because the lists union',
    !/LOST_TO_RACE[\s\S]{0,200}occ_skills/.test(cc)
    && /const pastLife = superseded \? \[\] : racePairingSkills\(rcc\);/.test(parser)
    && /const own = rcc\.skills\?\.occ_skills \|\| \[\];\s*\n\s*if \(!Array\.isArray\(rcc\.pairing_skills\)\) return own;/.test(parser));
}

section('A level-up pick is keyed by its grant, not by its position (BOOK-INGEST-AUDIT F72)');
{
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const lvl = readFileSync(join(appDir, 'js', 'leveling.js'), 'utf8');
  const sheet = readFileSync(appPath('sheet.js'), 'utf8');
  const confirm = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
    'characters', '[id]', 'level-confirm.js'), 'utf8');

  check('grantKey is kind:level:slot',
    /export function grantKey\(kind, g\) \{[\s\S]{0,80}?\$\{kind\}:\$\{g\?\.level \?\? 0\}:\$\{g\?\.slot \?\? 0\}/.test(lvl));
  // The whole argument for option A over a key of its own: this string is
  // already what the live level-up path puts on the wire at BOTH ends. If either
  // side is ever re-spelled, this fails rather than the two drifting apart.
  // THIS USED TO PIN THE BUG AS THE SHAPE. It matched level-confirm's own
  // `${p.type === 'psionic' ? 'psionic' : 'spell'}:level:slot` literally - a
  // two-way guess at a three-way kind, which keyed a spent Talent as `spell` and
  // let its grant bank twice. Because it matched that exact expression, it
  // would have FAILED any correct fix, so it was guarding the defect it sat
  // beside. The shape it exists to protect - kind:level:slot, agreeing with
  // grantKey - now lives in ONE place, resolvePowerPicks, which hands the key out
  // rather than letting each route rebuild it. So that is where it is checked.
  const picksLib = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
    '_lib', 'power-picks.js'), 'utf8');
  check('and it is the SAME shape the server keys a consumed grant by',
    /const key = \(kind, level, slot\) => `\$\{kind\}:\$\{level\}:\$\{slot \?\? 0\}`/.test(picksLib));
  check('and level-confirm takes that key rather than building its own',
    /resolved\.spent/.test(confirm) && !/'psionic' : 'spell'\}/.test(confirm.replace(/\/\/.*$/gm, '')));
  check('and the sheet builds its level-up controls off level and slot too',
    /lu-power-\$\{kind\}-\$\{g\.level\}-\$\{slot\}/.test(sheet));

  // Skill grants had no slot before F72; two can share a level.
  check('skillGrantsFor assigns a slot per level, after the sort',
    /const slots = new Map\(\);\s*\n\s*for \(const g of sorted\) \{[\s\S]{0,200}?g\.slot = slot;/.test(lvl));

  // Every site that stores or reads a pick.
  check('the skill picker stores under a grant key', /const gk = grantKey\('skill', g\);/.test(appSrc));
  check('and its inline handler passes that key, not an index',
    /onchange="setLevelPick\('\$\{gk\}', \$\{slot\}, this\.value\)"/.test(appSrc));
  check('the spell and psionic pickers do the same',
    /const gk = grantKey\('spell', g\);/.test(appSrc) && /const gk = grantKey\('psionic', g\);/.test(appSrc));
  check('and the skills payload reads back by key',
    /S\.levelPicks\[grantKey\('skill', g\)\]/.test(appSrc));
  check('no pick map is indexed by a bare loop counter any more',
    !/S\.level(Picks|Spells|Psi)\[gi\] \|\| \[\];/.test(appSrc));

  // A starting GROUP is still positional - it indexes startingGroups, which is
  // not derived from a schedule - so the handler must not coerce a grant key.
  check('the click handler coerces only what is actually a number',
    /\/\^\\d\+\$\/\.test\(el\.dataset\.gi\) \? \+el\.dataset\.gi : el\.dataset\.gi/.test(appSrc));

  // The prune is now the migration: an integer key is no grant's key.
  check('the prune keeps only keys the composed class still derives',
    /const live = new Set\(\(grants \|\| \[\]\)\.map\(\(g\) => grantKey\(kind, g\)\)\);[\s\S]{0,160}?if \(!live\.has\(k\)\) delete map\[k\];/.test(appSrc));
  check('and it covers all three maps',
    /keep\(S\.levelPicks, 'skill'[\s\S]{0,260}?keep\(S\.levelSpells, 'spell'[\s\S]{0,260}?keep\(S\.levelPsi, 'psionic'/.test(appSrc));
  check('recompose is still its only caller',
    (appSrc.match(/pruneOrphanLevelPicks\(\);/g) || []).length === 1);
  check('and it still does nothing at level 1',
    /if \(!S\.cls \|\| S\.level <= 1\) return;/.test(appSrc));
}


// ---------- 1c25g. Server-side ability validation ----------
// The wizard enforces the pick count, the offered list and repeatability; until
// now NOTHING re-checked them, so a direct API call could save a Godling with
// five powers. Same posture as skills: chosen things get a boundary, and what a
// class edit could have caused warns instead of blocking.
// ---------- An ability's bonuses only reach a character who took it ----------
// The Stone Master's Marks of Heritage were written as a plain ability carrying
// +12 P.P.E. and +20 S.D.C. Every Stone Master has them, none of them ever got
// them: applyAbilities folds in bonuses for abilities that were CHOSEN, and
// nothing chooses an ability no choice group offers. It parsed clean, read as
// mechanical, and granted nothing.
// A book that CAPS an attribute rather than requiring one - "a P.B. of 12 or
// lower (they want average looking people)". BOOK-INGEST-AUDIT.md F32.
//
// The key exists because writing that cap into `attribute_requirements` states
// the exact inverse of the book and renders as "PB 12+", so the failure it
// prevents is a silent one. These cases are therefore about the SHAPE being
// checked at all: `attribute_requirements` itself has no validator, which is
// the gap that made a wrong value indistinguishable from a right one.
section('A class attribute maximum');
{
  const mk = (line) => parseClassMarkdown(['---', 'id: c', 'name: C', 'system: rifts',
    'source_book: b', 'category: occ', line]
    .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10)));

  const ok = mk('attribute_maximums: { PB: 12 }');
  check('a cap parses and is carried on the class',
    ok.errors.length === 0 && ok.data.attribute_maximums.PB === 12);
  check('a cap on something that is not an attribute is an error',
    mk('attribute_maximums: { Charm: 12 }').errors.some((e) => /not an attribute/.test(e)));
  check('a non-numeric cap is an error',
    mk('attribute_maximums: { PB: "low" }').errors.some((e) => /must be a number/.test(e)));
  check('a class with no cap at all is untouched',
    mk('attribute_requirements: { IQ: 10 }').data.attribute_maximums === undefined);

  // The two halves come off ONE printed line - "I.Q. 10 and M.A. 10 or higher,
  // and a P.B. of 12 or lower" - so transposing them is the likely mistake, and
  // it produces a class nobody can take rather than anything a reader notices.
  const impossible = parseClassMarkdown(['---', 'id: c', 'name: C', 'system: rifts',
    'source_book: b', 'category: occ',
    'attribute_requirements: { PB: 14 }', 'attribute_maximums: { PB: 12 }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('a cap below its own minimum is refused',
    impossible.errors.some((e) => /no character can satisfy both/.test(e)));
}

section('Bonuses on an ability nobody picks');
{
  const parse = (lines) => parseClassMarkdown(['---', 'id: g', 'name: G', 'system: rifts',
    'source_book: b', 'category: occ', 'special_abilities:'].concat(lines)
    .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10)));

  const inert = parse([
    '  - name: "Marks of Heritage"', '    description: "x"',
    '    bonuses: { pools: { ppe: 12 } }']);
  const warned = (r) => r.warnings.filter((w) => /not offered/.test(w));

  check('a bonus on an ability no choice group offers warns', warned(inert).length === 1);
  check('the warning names the ability', /Marks of Heritage/.test(warned(inert)[0]));
  check('and says where the bonus belongs instead', /class \(or its variant\)/.test(warned(inert)[0]));
  check('it is a warning, not an error - a G.M. can still assign it by name',
    inert.errors.length === 0);

  // The same block on an ability a choice group offers is exactly how the
  // Godling's powers work, and must stay silent.
  check('an ability the class offers as a choice does not warn', warned(parse([
    '  - name: "Marks of Heritage"', '    description: "x"',
    '    bonuses: { pools: { ppe: 12 } }',
    '  - { choose: 1, from: ["Marks of Heritage"] }'])).length === 0);

  // And an ability with no bonuses at all is prose, which is the common case.
  check('a description-only ability does not warn', warned(parse([
    '  - name: "Marks of Heritage"', '    description: "x"'])).length === 0);
}

await serverPlumbingChecks();

renderedUiChecks();

mosTotemChecks();


// The Morphus tables (migration 068, Nightbane survey D5). One row per ENTRY of
// a percentile table, and an entry's name repeats across tables - so the three
// decisions pinned here are the ones a tidy-up would undo: the stored `key` and
// the CHECK that holds it to its parts, bonuses through the class validator,
// and the JSON lists validated rather than stored as whatever text arrived.
section('Morphus tables catalog');
{
  const mo = CATALOGS.morphus;
  check('morphus exists and points at morphus_characteristics',
    !!mo && mo.table === 'morphus_characteristics');
  const f = (n) => (mo ? mo.fields : []).find((x) => x.name === n);
  check('and is keyed and displayed on the stored key, not on a name that repeats',
    !!mo && mo.uniqueField === 'key' && mo.displayField === 'key');
  check('and `kind` is a select that keeps an unrecognised stored value',
    f('kind')?.type === 'select' && f('kind').allowOther === true
    && ['effect', 'route', 'combination', 'intro'].every((k) => f('kind').options.includes(k)));

  // The SAME validateBonuses a class goes through, with dice and pools allowed:
  // an accepted pool dice form and a refused one prove the validator ran.
  check('bonuses go through validateBonuses and accept dice and pools',
    f('bonuses')?.type === 'bonuses'
    && !coerceField(f('bonuses'), '{"attributes":{"PS":"1d6"},"pools":{"sdc":"1d4x10"}}').error);
  check('and refuse what that validator refuses',
    !!coerceField(f('bonuses'), '{"pools":{"sdc":"1d4*10"}}').error);

  const routes = f('routes');
  check('routes accept a list of {table, count}, including a table the book never prints',
    coerceField(routes, '[{"table":"Bear","count":1}]').value === '[{"table":"Bear","count":1}]');
  check('and refuse a count below one',
    !!coerceField(routes, '[{"table":"Canine","count":0}]').error);
  check('and a key no reader knows', !!coerceField(routes, '[{"table":"Canine","count":1,"odds":5}]').error);
  check('and a value that is not a list', !!coerceField(routes, '{"table":"Canine","count":1}').error);
  check('and store NULL for blank or empty, so "has routes" is IS NOT NULL',
    coerceField(routes, '').value === null && coerceField(routes, '[]').value === null);
  // TEXT, because 73 entries add a roll. The same isDiceBonus a bonus value goes
  // through, so the two cannot disagree about what a roll looks like.
  const hf = f('horror_factor');
  check('horror_factor takes dice, stored as written',
    hf?.type === 'dice' && ['1d4', '1d6', '1d4+1', '1d4+2'].every((d) => coerceField(hf, d).value === d));
  check('and a whole number, stored as text', coerceField(hf, 2).value === '2' && coerceField(hf, ' 3 ').value === '3');
  check('and refuses anything else', ['1d', 'd6', 'lots', '1.5'].every((v) => !!coerceField(hf, v).error)
    && !!coerceField(hf, 1.5).error);
  check('while horror_factor_set stays a plain integer', f('horror_factor_set')?.type === 'int');
  check('sub_choices accept strings and refuse anything else',
    coerceField(f('sub_choices'), '["Wolf","Fox"]').value === '["Wolf","Fox"]'
    && !!coerceField(f('sub_choices'), '["Wolf", 3]').error);

  // The key is only as good as the CHECK behind it. Built from schema.sql, as
  // the column check above is, so this is what a FRESH database enforces.
  const mem = new DatabaseSync(':memory:');
  mem.exec(readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8'));
  const ins = mem.prepare('INSERT INTO morphus_characteristics (key, table_name, roll_low, roll_high, name, kind) VALUES (?,?,?,?,?,?)');
  const refuses = (...args) => { try { ins.run(...args); return false; } catch { return true; } };
  check('a row whose key is "<table_name>: <name>" is accepted',
    !refuses('Canine: Were-Canine', 'Canine', 21, 45, 'Were-Canine', 'effect'));
  check('and one whose key disagrees with its parts is refused',
    refuses('Canine: Canine Head', 'Canine', 81, 100, 'Were-Canine', 'effect'));
  check('the same name in ANOTHER table is a different entry',
    !refuses('Feline: Were-Canine', 'Feline', 1, 10, 'Were-Canine', 'effect'));
  check('and a fresh build records migration 068',
    !!mem.prepare("SELECT 1 FROM schema_migrations WHERE filename = '068-morphus-characteristics.sql'").get());
  mem.close();

  // A table CHECK is refused input, not a server fault.
  check('the catalog write path answers a CHECK failure with a 422',
    /CHECK constraint failed[\s\S]*?422/.test(readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'catalogs', 'rows.js'), 'utf8')));
}

section('An occupation beside a race offers its own pick groups (BOOK-INGEST-AUDIT F125)');
{
  // WHAT THE SERVER ALREADY DID, and the wizard did not. A pairing lists the
  // race's abilities and then the occupation's, so the composed class carries
  // both halves' groups and the count allows both - but the picker read the
  // race slot alone, and the occupation's group was never offered.
  const race = { id: 'r', name: 'R', category: 'rcc', special_abilities: [
    { name: 'Claws' }, { name: 'Tail' }, { choose: 1, from: ['Claws', 'Tail'] }] };
  const occ = { id: 'o', name: 'O', category: 'occ', special_abilities: [
    { name: 'Mental Bonus (I.Q.)', bonuses: { attributes: { IQ: '1d4' } } },
    { name: 'Mental Bonus (M.E.)', bonuses: { attributes: { ME: '1d4' } } },
    { name: 'Thick Hide', bonuses: { pools: { sdc: '2d6' } } },
    { choose: 1, from: ['Mental Bonus (I.Q.)', 'Mental Bonus (M.E.)', 'Thick Hide'] }] };
  const paired = combineClasses(race, occ);
  const groups = paired.special_abilities.filter((e) => e.choose);
  check('a pairing carries the race\'s groups and then the occupation\'s',
    groups.length === 2 && groups[0].from[0] === 'Claws' && groups[1].from.length === 3);
  const count = (abilities) => validateCharacter({ character: { level: 1 }, cls: paired, skills: [],
    attributes: {}, abilities, catalog: new Map() }).violations.filter((x) => x.rule === 'ability_count');
  check('and the server allows one pick from each half',
    count(['Claws', 'Mental Bonus (M.E.)']).length === 0 && count(['Claws', 'Tail', 'Mental Bonus (M.E.)']).length === 1);
  // Counted against the OCCUPATION's own class, a race's pick belongs to no
  // group of it - which is what lets each picker count only its own side.
  check('counted against the occupation alone, the race\'s pick is in none of its groups',
    String(abilityGroupCounts(occ, ['Claws', 'Mental Bonus (M.E.)'])) === '1'
    && abilityGroupIndexFor(occ, 'Claws') === -1 && abilityGroupIndexFor(race, 'Mental Bonus (M.E.)') === -1);
  // The occupation's dice are rolled from the occupation alone, with its own
  // picks applied; a race's pick has no definition there and adds nothing.
  const occWithPick = applyAbilities(occ, ['Claws', 'Mental Bonus (M.E.)']);
  check('the occupation\'s roll sees its own pick\'s dice and not the race\'s pick',
    occWithPick.bonuses?.attributes?.ME === '1d4' && occWithPick.bonuses?.attributes?.IQ === undefined
    && derive.diceBonuses(occWithPick).ME === '1d4'
    && occWithPick.abilities_taken.find((a) => a.name === 'Claws')?.granted === false);
  check('and a pick that touches a pool is known to, so the pools are cleared',
    occ.special_abilities.filter((d) => d.name).map((d) => abilityTouchesPoolOf(d)).join() === 'false,false,true');

  // THE WIZARD, pinned by source: every picker handler takes a side and reads
  // its class through one function.
  const appSrc = readFileSync(appPath('app.js'), 'utf8');
  check('the picker reads the class for its side, the occupation with its variant',
    /const abilityClass = \(side\) => \(side === 'occ' \? occAbilityClass\(\) : S\.rcc\);/.test(appSrc)
    && /function occAbilityClass\(\) \{[\s\S]{0,200}applyVariant\(occ, S\.occVariant\)/.test(appSrc)
    && /function abilityPicker\(side = 'rcc'\)/.test(appSrc));
  check('the Occupation step draws the occupation\'s picker, and only once one is chosen',
    /\$\{occPicker\(\)\}\s+\$\{S\.occ \? abilityPicker\('occ'\) : ''\}/.test(appSrc));
  check('its buttons name their side, so they count the occupation\'s groups',
    /onclick="takeAbility\('\$\{escJs\(name\)\}'\$\{sideArg\}\)"/.test(appSrc)
    && /onclick="dropAbility\('\$\{escJs\(name\)\}'\$\{sideArg\}\)"/.test(appSrc)
    && (appSrc.match(/onclick="rollAbilityGroup\(\$\{gi\}\$\{sideArg\}\)"/g) || []).length === 2);
  check('take, drop and roll all read that side\'s class',
    /function takeAbility\(name, side = 'rcc'\) \{\s+const cls = abilityClass\(side\);/.test(appSrc)
    && /function dropAbility\(name, side = 'rcc'\)/.test(appSrc)
    && /function rollAbilityGroup\(gi, side = 'rcc'\) \{\s+const cls = abilityClass\(side\);/.test(appSrc));
  check('no picker handler still counts against the race slot by name',
    !/abilityGroupIndexFor\(S\.rcc, n\) === gi/.test(appSrc)
    && !/const gi = abilityGroupIndexFor\(S\.rcc, name\);/.test(appSrc));
  // This step comes AFTER the attributes are rolled and nothing recomposes
  // between it and Skills, so a pick here rebuilds the class and clears what
  // it moved.
  check('a pick from the occupation recomposes, re-rolls its dice, and clears pools and moved attributes',
    /function occAbilitiesChanged\(\) \{\s+const dice = S\.cls\?\.attribute_dice;\s+recompose\(\);\s+rollOccBonuses\(\);\s+clearRolledPools\(\);\s+clearAttrsWhoseDiceChanged\(dice\);/.test(appSrc)
    && (appSrc.match(/if \(side === 'occ'\) occAbilitiesChanged\(\);/g) || []).length === 4);
  check('the occupation\'s dice roll with its picks applied',
    /rollDiceBonusesOf\(applyAbilities\(applyVariant\(occ, S\.occVariant\), S\.abilities\)\)/.test(appSrc));
  check('changing the occupation drops the picks that were the old one\'s, unless the race offers the name',
    /function dropOccAbilityPicks\(\) \{[\s\S]{0,420}return !old\.has\(key\) \|\| race\.has\(key\);/.test(appSrc));
  check('and the step does not let the player on while one of its groups is owed a pick',
    /const occCls = occAbilityClass\(\);[\s\S]{0,360}abilityGroupOwed\(g\) - \(held\[gi\] \|\| 0\)[\s\S]{0,200}for \$\{occCls\.name\} to continue/.test(appSrc));
  check('the rail\'s forward jump asks the same gate as the step\'s Next button',
    /if \(i === ST\.OCCUPATION\) return occBlocker\(\);/.test(appSrc));

  // The Attributes and Morphus steps the same way. The rail's copy of the
  // Attributes rule read `S.cls.requirements.attributes`, a key no class has,
  // and ignored an overspent point-buy pool; the Morphus step had no case.
  {
    const rail = appSrc.match(/function stepBlocker\(i\) \{[\s\S]*?\n\}/)?.[0] || '';
    check('the rail asks the Attributes step\'s own gate',
      /if \(i === ST\.ATTRIBUTES\) return attributesBlocker\(\)\.why;/.test(rail));
    check('and the Morphus step\'s', /if \(i === ST\.MORPHUS\) return morphusBlocker\(\) \|\| '';/.test(rail));
    check('the rail restates no attribute rule of its own', !/S\.attrs/.test(rail));
    check('the Attributes step reads the same gate for its Next button',
      /const \{ missing, unmet, over, why: attrWhy \} = attributesBlocker\(\);\s+const usesPB[^\n]*\s+const canNext = !attrWhy;/.test(appSrc));

    // The gate itself, run rather than read: lifted out of app.js with the four
    // names it closes over supplied.
    const gateSrc = appSrc.match(/function attributesBlocker\(\) \{[\s\S]*?\n\}/)?.[0] || '';
    check('attributesBlocker is found', gateSrc.length > 0);
    const gate = (S, spent = 0, absent = []) => new Function('S', 'ATTRS', 'attrAbsent', 'pbSpent', 'PB_POOL',
      `${gateSrc}; return attributesBlocker();`)(S, ['IQ', 'PS', 'PE'], (a) => absent.includes(a), () => spent, 40);
    const cls = { attribute_requirements: { PS: 12 } };
    check('a missed class minimum blocks, and says which',
      gate({ cls, attrs: { IQ: 9, PS: 11, PE: 9 } }).why === 'Class minimum not met: PS 12+.');
    check('an attribute still to roll blocks first',
      gate({ cls, attrs: { IQ: 9, PS: 14 } }).why === 'Still to roll or enter: PE.');
    check('an overspent point-buy pool blocks', /overspent/.test(gate({ cls, attrs: { IQ: 9, PS: 14, PE: 9 } }, 41).why));
    check('an attribute the class does not have is not waited for',
      gate({ cls, attrs: { IQ: 9, PS: 14 } }, 0, ['PE']).why === '');
    check('and a met build passes', gate({ cls, attrs: { IQ: 9, PS: 12, PE: 9 } }).why === '');
  }
  const dropFn = appSrc.slice(appSrc.indexOf('function dropOccAbilityPicks()'), appSrc.indexOf('function pickOcc(id)'));
  check('an occupation released by a dropped ability loses its picks too, before the slot is cleared',
    /dropOccAbilityPicks\(\);\s+S\.occ = null; S\.occVariant = null;/.test(appSrc)
    && /if \(\(id \|\| null\) !== S\.occ\) dropOccAbilityPicks\(\);\s+S\.occ = id \|\| null;/.test(appSrc)
    && /occAbilityClass\(\)/.test(dropFn));
  check('and a change of stage re-rolls the occupation\'s dice, as a change of occupation does',
    /S\.occVariant = id \|\| null;\s+recompose\(\);\s+rollOccBonuses\(\);/.test(appSrc));
  check('the Race step\'s picker and gate still read the race slot',
    /const held = abilityGroupCounts\(S\.rcc, S\.abilities\);\s+const short = abilityGroups\(S\.rcc\)/.test(appSrc));
}

section('A class ability picked at set levels (BOOK-INGEST-AUDIT F116)');
{
  const LF = String.fromCharCode(10);
  const mk = (...lines) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ', 'occ_group: men-of-arms',
     'tags: []', 'men_of_arms: true', ...lines, '---', '', '## Lore', '', 'x', ''].join(LF));
  const DEFS = ['  - { name: "Stone Ox", description: "x", bonuses: { pools: { sdc: "4d4x10" } } }',
    '  - { name: "Wrist Hardening", description: "x", bonuses: { attributes: { PS: "1d6" } } }',
    '  - { name: "Dam Sum Sing", description: "x", bonuses: { pools: { sdc: 20 } } }',
    '  - { name: "Iron Hand", description: "x" }',
    '  - { name: "Vanish", description: "x" }', '  - { name: "Fade", description: "x" }'];
  const EX = '["Stone Ox", "Wrist Hardening", "Dam Sum Sing", "Iron Hand"]';
  // The Sohei's shape: an exercise at 1, 5 and 9; and the Bishamon's: an art at 3, none at creation.
  const cls = mk('special_abilities:', ...DEFS,
    `  - { choose: 1, at_levels: [1, 5, 9], from: ${EX}, note: "A body hardening exercise." }`,
    '  - { choose: 1, at_levels: [3], from: ["Vanish", "Fade"] }');
  check('a choice group may state the levels it is picked at', cls.ok && cls.warnings.length === 0,
    [...cls.errors, ...cls.warnings].join('; '));
  const [exercises, arts] = cls.data.special_abilities.filter((e) => e.choose);
  check('the levels are read back in order, and a group without them has none',
    String(abilityGroupLevels(exercises)) === '1,5,9' && abilityGroupLevels({ choose: 2, from: ['a'] }) === null);

  // THE LIMIT DEPENDS ON THE LEVEL. Everything that measured picks against
  // `choose` asks this instead.
  check('a levelled group allows one round of choose for each of its levels reached',
    abilityGroupAllowance(exercises, 1) === 1 && abilityGroupAllowance(exercises, 4) === 1
    && abilityGroupAllowance(exercises, 5) === 2 && abilityGroupAllowance(exercises, 15) === 3);
  check('a group with no level-1 pick allows nothing at creation, and owes nothing there',
    abilityGroupAllowance(arts, 1) === 0 && abilityGroupOwed(arts) === 0
    && abilityGroupAllowance(arts, 3) === 1);
  check('a plain choose group is what it always was, at any level',
    abilityGroupAllowance({ choose: 2, from: ['a', 'b'] }, 1) === 2
    && abilityGroupAllowance({ choose: 2, from: ['a', 'b'] }, 9) === 2
    && abilityGroupOwed({ choose: 2, from: ['a', 'b'] }) === 2 && abilityGroupOwed(exercises) === 1);
  check('at_levels must be rising whole levels, with choose, and never beside rolls',
    !mk('special_abilities:', ...DEFS, `  - { choose: 1, at_levels: [3, 3], from: ${EX} }`).ok
    && !mk('special_abilities:', ...DEFS, `  - { choose: 1, at_levels: [5, 3], from: ${EX} }`).ok
    && !mk('special_abilities:', ...DEFS, `  - { choose: 1, at_levels: [0, 3], from: ${EX} }`).ok
    && !mk('special_abilities:', ...DEFS, `  - { choose: 1, at_levels: [], from: ${EX} }`).ok
    && !mk('special_abilities:', ...DEFS, `  - { at_levels: [3], from: ${EX} }`).ok
    && !mk('special_abilities:', '  - { name: "K (01-50): A" }', '  - { name: "K (51-00): B" }',
      '  - { rolls: 2, at_levels: [3], from: ["K (01-50): A", "K (51-00): B"] }').ok);

  // THE GRANTS, itemised by the level that earned each, level 1 never among them.
  const grants = abilityLevelGrants(cls.data, 1, 9);
  check('levels above the starting one are granted, each with its list, its slot and its note',
    grants.map((g) => `${g.level}:${g.slot}:${g.count}`).join() === '3:1:1,5:0:1,9:0:1'
    && grants[1].from.length === 4 && grants[1].note === 'A body hardening exercise.' && grants[0].note === undefined);
  check('a span collects only what lies inside it',
    abilityLevelGrants(cls.data, 5, 9).map((g) => g.level).join() === '9'
    && abilityLevelGrants(cls.data, 9, 15).length === 0 && abilityLevelGrants({}, 1, 15).length === 0);
  const banked = powerGrantsFor(cls.data, 1, 9).filter((g) => g.kind === 'ability');
  check('powerGrantsFor banks them as their own kind, the list in from and every other restriction null',
    banked.length === 3 && banked.every((g) => g.spell_levels === null && g.categories === null && Array.isArray(g.from)));
  check('and a class with no levelled group banks none',
    powerGrantsFor({ special_abilities: [{ name: 'A' }, { choose: 1, from: ['A'] }] }, 1, 15)
      .filter((g) => g.kind === 'ability').length === 0);

  // SPENDING. No catalog row: the grant's own list is the restriction.
  const env = { DB: { prepare: () => {
    const q = { all: async () => ({ results: [] }), first: async () => null };
    return { ...q, bind: () => q };
  }, batch: async (st) => Promise.all(st.map((x) => x.all())) } };
  const spend = (names, existingAbilities = ['Iron Hand']) => resolvePowerPicks(env, {
    picks: names.map((name) => ({ kind: 'ability', name, granted_at_level: 5, slot: 0 })),
    grants: banked, existingPowers: [], existingAbilities, system: 'rifts' });
  const good = await spend(['stone ox']);
  check('a pick on the grant\'s list resolves into abilities, not powers, in the list\'s own spelling',
    good.errors.length === 0 && good.powers.length === 0 && good.abilities?.[0]?.name === 'Stone Ox'
    && good.spent.get('ability:5:0') === 1, good.errors.join('; '));
  check('a name off the list is refused',
    (await spend(['Vanish'])).errors.some((e) => e.includes('not on the list')));
  check('an ability already held is refused',
    (await spend(['Iron Hand'])).errors.some((e) => e.includes('already held')));
  check('two picks against a grant of one are refused',
    (await spend(['Stone Ox', 'Dam Sum Sing'])).errors.some((e) => e.includes('already full')));
  check('a pick for a level nothing granted is refused',
    (await resolvePowerPicks(env, { picks: [{ kind: 'ability', name: 'Stone Ox', granted_at_level: 7, slot: 0 }],
      grants: banked, existingPowers: [], existingAbilities: [], system: 'rifts' })).errors
      .some((e) => e.includes('no ability grant from level 7')));

  // WHAT SPENDING ROLLS. Flat attribute, combat and save bonuses fold at render;
  // dice and pool bonuses are stored at creation and nowhere else, so a pick
  // made later would add nothing unless the spend path writes them.
  const fixed = (d) => ({ '4d4x10': 70, '1d6': 4 }[d]);
  const before = { sdc_max: 40, sdc_current: 35, hp_max: 20, hp_current: 20, mdc_max: null,
    attribute_bonuses: { PS: 2 }, rolled_bonuses: { combat: { initiative: 1 }, saves: {} } };
  const fx = abilityPickEffects(cls.data, ['Stone Ox', 'Wrist Hardening', 'Dam Sum Sing', 'Iron Hand'], before, fixed);
  check('a dice pool bonus is rolled into the maximum and the current pool',
    fx.pools.sdc_max === 40 + 70 + 20 && fx.pools.sdc_current === 35 + 70 + 20);
  check('a dice attribute bonus is added to what the character already rolled',
    fx.attribute_bonuses.PS === 6);
  check('untouched stores are left alone, so the write names only what moved',
    fx.rolled_bonuses === null && !('hp_max' in fx.pools) && !('mdc_max' in fx.pools));
  check('each roll is reported, with the ability it came from',
    fx.rolled.some((r) => r.ability === 'Stone Ox' && r.dice === '4d4x10' && r.value === 70)
    && fx.rolled.some((r) => r.ability === 'Dam Sum Sing' && r.dice === null && r.value === 20));
  check('a pool the character does not have is not conjured',
    abilityPickEffects(cls.data, ['Stone Ox'], { sdc_max: null, sdc_current: null }, fixed).pools.sdc_max === undefined);
  check('an ability with nothing to roll changes nothing',
    JSON.stringify(abilityPickEffects(cls.data, ['Iron Hand'], before, fixed))
      === '{"attribute_bonuses":null,"rolled_bonuses":null,"pools":{},"rolled":[]}');
  check('the character passed in is not mutated', before.sdc_max === 40 && before.attribute_bonuses.PS === 2);

  // THE SERVER'S COUNT is by level, in both directions.
  const v = (level, abilities) => validateCharacter({ character: { level }, cls: cls.data, skills: [],
    attributes: {}, abilities, catalog: new Map() }).violations.filter((x) => x.rule === 'ability_count');
  check('at level 1 one exercise is allowed and a second is not',
    v(1, ['Stone Ox']).length === 0 && v(1, ['Stone Ox', 'Iron Hand']).length === 1);
  check('at level 5 the second exercise and the level-3 art are allowed, which used to be refused',
    v(5, ['Stone Ox', 'Iron Hand', 'Vanish']).length === 0);
  check('and a fourth pick at level 5 is still one too many',
    v(5, ['Stone Ox', 'Iron Hand', 'Vanish', 'Dam Sum Sing']).length === 1);

  // The wizard, the sheet, the endpoints and the schema, pinned by source.
  const appSrc = readFileSync(appPath('app.js'), 'utf8');
  check('the wizard offers a levelled group for its level-1 pick only',
    /const limit = abilityGroupAllowance\(g, 1\);/.test(appSrc)
    && /const limit = abilityGroupAllowance\(groups\[gi\], 1\);/.test(appSrc));
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet offers a banked class ability from its own list, not from a catalog',
    /if \(g\.kind === 'ability'\) return abilityPickRows\(g\);/.test(sheetSrc)
    && /function abilityPickRows\(g\)[\s\S]{0,900}data-kind="ability"/.test(sheetSrc));
  const fnDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const spendSrc = readFileSync(join(fnDir, 'characters', '[id]', 'power-picks.js'), 'utf8');
  check('the banked-picks endpoint stores an ability in abilities, with what it rolled, after validating it',
    /existingAbilities: character\.abilities/.test(spendSrc) && /abilityPickEffects\(cls,/.test(spendSrc)
    && /const sets = \['abilities = \?'\];/.test(spendSrc) && /validateCharacter\(\{/.test(spendSrc));
  check('and an ability-only spend no longer answers "Nothing to spend"',
    /if \(!resolved\.powers\.length && !gainedAbilities\.length\)/.test(spendSrc));
  const confirmSrc = readFileSync(join(fnDir, 'characters', '[id]', 'level-confirm.js'), 'utf8');
  check('level-confirm banks an ability grant and refuses to spend one itself',
    /p\?\.kind === 'ability'/.test(confirmSrc) && /chosen from the banked picks/.test(confirmSrc));
  const createSrc = readFileSync(join(fnDir, 'characters.js'), 'utf8');
  check('creation above level one banks the levels skipped, once',
    /level > 1 && !bankPowers\.some\(\(g\) => g\?\.kind === 'ability'\)/.test(createSrc));
  const npcSrc = readFileSync(join(appDir, 'js', 'npc-generate.js'), 'utf8');
  check('the NPC generator picks only what a group allows at creation',
    /const want = abilityGroupAllowance\(g, 1\);/.test(npcSrc));
  const schemaSrc = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  check('schema.sql admits the kind a fresh database needs',
    /kind TEXT NOT NULL CHECK \(kind IN \('spell', 'psionic', 'talent', 'talent_purchase', 'ability'\)\)/.test(schemaSrc));
}

section('An ability may carry its later levels as text (BOOK-INGEST-AUDIT F117)');
{
  const LF = String.fromCharCode(10);
  const mk = (...lines) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: rcc', 'tags: []',
     ...lines, '---', '', '## Lore', '', 'x', ''].join(LF));
  // DISPLAY ONLY. A Mystic Martial Art Power is a table from level 1 to 15;
  // level 1 is the description and the rest are lines the sheet shows as the
  // character reaches them. Nothing adds what a line says.
  const inline = mk('special_abilities:',
    '  - { name: "Art", description: "Level 1: a blade.", progression: [{ level: 5, text: "Five, with a comma." }, { level: 2, text: "Two." }], bonuses: { combat: { strike: 1 } } }',
    '  - { name: "Plain", description: "x" }',
    '  - { choose: 1, from: ["Art", "Plain"] }');
  const block = mk('special_abilities:', '  - name: "Art"', '    description: "Level 1: a blade."',
    '    progression:', '      - { level: 2, text: "Two." }', '      - { level: 5, text: "Five." }',
    '  - { choose: 1, from: ["Art"] }');
  check('an ability may state a level table, written inline or as a block',
    inline.ok && block.ok && inline.warnings.length === 0, [...inline.errors, ...block.errors, ...inline.warnings].join('; '));
  check('both spellings read the same lines',
    block.data.special_abilities[0].progression.length === 2
    && inline.data.special_abilities[0].progression[0].text === 'Five, with a comma.');
  const held = applyAbilities(inline.data, ['Art']).abilities_taken[0];
  check('a held ability carries its table to the sheet', Array.isArray(held?.progression) && held.progression.length === 2);
  check('an ability without one carries none',
    !('progression' in applyAbilities(inline.data, ['Plain']).abilities_taken[0]));
  check('the table adds no number: the bonuses are the ability\'s own and nothing else',
    JSON.stringify(applyAbilities(inline.data, ['Art']).bonuses.combat) === '{"strike":1}');
  check('at level 1 nothing is reached and the next line is the lowest, whatever order it was written in',
    abilityProgressionAt(held, 1).reached.length === 0 && abilityProgressionAt(held, 1).next?.level === 2);
  check('at level 3 the level-2 line is reached and level 5 is next',
    abilityProgressionAt(held, 3).reached.map((l) => l.level).join() === '2' && abilityProgressionAt(held, 3).next?.level === 5);
  check('at level 5 and beyond every line is reached, in order, and nothing is next',
    abilityProgressionAt(held, 5).reached.map((l) => l.level).join() === '2,5' && abilityProgressionAt(held, 9).next === null);
  check('an ability with no table reaches nothing, rather than crashing',
    abilityProgressionAt({ name: 'x' }, 9).reached.length === 0 && abilityProgressionAt(null, 9).next === null);
  const bad = (prog) => mk('special_abilities:', `  - { name: "Art", description: "x", progression: ${prog} }`,
    '  - { choose: 1, from: ["Art"] }');
  check('a line with no level, no text, or a level below 1 is an error',
    !bad('[{ text: "No level." }]').ok && !bad('[{ level: 2 }]').ok && !bad('[{ level: 0, text: "x" }]').ok
    && !bad('[{ level: "two", text: "x" }]').ok);
  check('an empty table, or one that is not a list, is an error',
    !bad('[]').ok && !bad('"lots"').ok);
  check('the same level stated twice is an error, so one entry holds what that level gives',
    !bad('[{ level: 2, text: "a" }, { level: 2, text: "b" }]').ok);

  // The sheet, pinned by source: it lists the reached lines and the next one
  // under the held ability, and the next one stays off paper.
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet lists a held ability\'s table under it',
    /\$\{abilityProgressionHtml\(a\)\}/.test(sheetSrc) && /function abilityProgressionHtml\(a\)/.test(sheetSrc));
  check('by the character\'s level, with the next line muted and not printed',
    /const lvl = Number\(C\.data\?\.level\) \|\| 1;[\s\S]{0,520}l\.level <= lvl[\s\S]{0,400}muted small noprint/.test(sheetSrc));
}

section('The row generators refuse what they cannot write (BOOK-INGEST-AUDIT F124)');
{
  // Three generators beside scripts/bestiary-sql.mjs, each carrying its own
  // --self-test: the refusals, and the shape of the script it writes. Run as
  // the scripts a person runs, so a broken import or a schema the column
  // reader can no longer parse fails here and not in the middle of a book.
  const scriptsDir = join(appDir, '..', '..', 'scripts');
  for (const name of ['vessel-sql', 'rows-sql', 'class-fix-sql']) {
    const file = join(scriptsDir, `${name}.mjs`);
    const r = spawnSync(process.execPath, [file, '--self-test'], { encoding: 'utf8' });
    check(`${name} passes its self-test`,
      r.status === 0 && r.stdout.includes(`${name} self-test passed`) && !/FAIL/.test(r.stdout),
      (r.stdout + r.stderr).split('\n').filter((l) => /FAIL|Error/.test(l)).slice(0, 3).join(' | '));
    // An existing file is never overwritten: a data script that was applied
    // once is a record. A real one stands in, and is the same bytes afterwards.
    const existing = join(appDir, 'db', 'seed-dev.sql');
    const before = readFileSync(existing, 'utf8');
    const over = spawnSync(process.execPath, [file, scriptsDir, existing], { encoding: 'utf8' });
    check(`${name} never overwrites a data script that exists`,
      over.status === 2 && /never overwrites a data script/.test(over.stderr)
      && readFileSync(existing, 'utf8') === before, over.stderr.slice(0, 160));
    const named = spawnSync(process.execPath, [file, scriptsDir, file], { encoding: 'utf8' });
    check(`${name} refuses an output name that is not a data script's`,
      named.status === 2 && /not a data-script name/.test(named.stderr), named.stderr.slice(0, 160));
    const none = spawnSync(process.execPath, [file], { encoding: 'utf8' });
    check(`${name} with no arguments prints its usage and exits 2`,
      none.status === 2 && /usage: node scripts\//.test(none.stderr));
  }
  // The library reads columns out of db/schema.sql, so a table it cannot find
  // is an error at once rather than an empty column list.
  const lib = await import('../../../scripts/sql-gen-lib.mjs');
  check('the column reader finds every table the generators write',
    ['vehicles', 'vehicle_locations', 'vehicle_weapons', 'spells', 'gear', 'skills', 'psionic_powers', 'enchantments']
      .every((t) => lib.loadColumns([t])[t].length > 3));
  check('and refuses a table that is not in the schema', (() => {
    try { lib.loadColumns(['no_such_table']); return false; } catch (e) { return /no CREATE TABLE found/.test(e.message); }
  })());
  // THE COLUMN READER REFUSES WHAT IT CANNOT READ, rather than writing wrong
  // rows: an expression DEFAULT would land in every row as its own text, and a
  // constraint continued onto a second line would be read as a column. None of
  // the eight tables has either today, and the names it reads are the names
  // the table has - checked against the CREATE itself.
  {
    const { mkdtempSync, mkdirSync } = await import('node:fs');
    const { tmpdir } = await import('node:os');
    const fake = (body) => {
      const root = mkdtempSync(join(tmpdir(), 'sqlgen-'));
      mkdirSync(join(root, 'db'));
      writeFileSync(join(root, 'db', 'schema.sql'), `CREATE TABLE IF NOT EXISTS t (\n${body}\n);\n`);
      try { return { cols: lib.loadColumns(['t'], root).t }; } catch (e) { return { error: e.message }; }
      finally { rmSync(root, { recursive: true, force: true }); }
    };
    const ok = fake("  id INTEGER PRIMARY KEY AUTOINCREMENT,\n  name TEXT NOT NULL,  -- a comment, with a comma\n"
      + "  source TEXT NOT NULL DEFAULT 'seed',\n  kind TEXT CHECK (kind IN ('a', 'b')),\n  n INTEGER NOT NULL DEFAULT 0");
    check('a table of the shapes the catalog uses is read whole, defaults and CHECK lists included',
      ok.cols?.map((c) => c.name).join(',') === 'id,name,source,kind,n'
      && ok.cols[2].default === "'seed'" && String(ok.cols[3].allowed) === 'a,b' && ok.cols[4].default === '0',
      ok.error || JSON.stringify(ok.cols));
    check('an expression DEFAULT is refused, not written into every row as text',
      /DEFAULT is an expression/.test(fake("  name TEXT,\n  created_at TEXT NOT NULL DEFAULT (datetime('now'))").error || ''));
    check('a constraint continued onto a second line is refused, not read as a column',
      /cannot read the column line|cannot parse/.test(
        fake("  name TEXT,\n  kind TEXT CHECK (kind IN ('a',\n    'b'))").error || ''));
    const schemaSql = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8').replace(/\r\n/g, '\n');
    const declared = (t) => new RegExp(`CREATE TABLE IF NOT EXISTS ${t} \\(([\\s\\S]*?)\\n\\);`).exec(schemaSql)[1]
      .split('\n').map((l) => l.replace(/--.*$/, '').trim()).filter((l) => /^[a-z_]+\s+(TEXT|INTEGER|REAL)\b/.test(l)).length;
    check('and for each real table it reads exactly as many columns as the CREATE declares',
      ['vehicles', 'vehicle_locations', 'vehicle_weapons', 'spells', 'gear', 'skills', 'psionic_powers', 'enchantments']
        .every((t) => lib.loadColumns([t])[t].length === declared(t)));
  }
  check('a script whose read-backs outrun d1-apply\'s one-command budget is a problem the generators refuse',
    /over d1-apply's 7900 budget/.test(lib.readbackProblem(
      Array.from({ length: 60 }, (_, i) => `SELECT 'part ${i}' AS assertion, count(*) AS got, 40 AS want FROM gear WHERE slug IN (${
        Array.from({ length: 10 }, (_, j) => `'a-long-enough-slug-${i}-${j}'`).join(', ')});`).join('\n')) || '')
    && lib.readbackProblem("SELECT 'one' AS assertion, count(*) AS got, 1 AS want FROM gear WHERE slug IN ('a');") === null);
  check('a literal doubles an apostrophe and writes NULL for nothing',
    lib.sqlLiteral("Death's Head") === "'Death''s Head'" && lib.sqlLiteral(null) === 'NULL' && lib.sqlLiteral(7) === '7');
}

section('A held spell is headed by its tradition, and ward symbols are one (BOOK-INGEST-AUDIT F123)');
{
  // js/traditions.js is a classic script that hangs one global on `window`.
  const tw = {};
  new Function('window', readFileSync(join(appDir, 'js', 'traditions.js'), 'utf8'))(tw);
  const T = tw.SpellTraditions;
  check('the tradition module exposes the held-spell heading and its order',
    typeof T?.heldGroup === 'function' && typeof T?.heldOrder === 'function');
  check('ward symbols have a label of their own', T.label('ward') === 'Ward Symbols');

  // General invocations keep the heading they always had, level 0 included.
  check('a general spell is still headed "Spells", by level',
    T.heldGroup(3, '') === 'Spells — Level 3' && T.heldGroup(0, '') === 'Spells — Level 0'
    && T.heldGroup(null, '') === 'Spells — Unleveled' && T.heldGroup(undefined, null) === 'Spells — Unleveled');
  // A tradition's rows are stored at level 0 when it has no levels (wards,
  // tattoos, circles), which read "Spells - Level 0" before this.
  check('a tradition spell is headed by its tradition, with the level only where it has one',
    T.heldGroup(0, 'ward') === 'Ward Symbols' && T.heldGroup(null, 'ward') === 'Ward Symbols'
    && T.heldGroup(0, 'tattoo') === 'Magic Tattoos'
    && T.heldGroup(3, 'warlock') === 'Warlock Elemental — Level 3'
    && T.heldGroup(2, 'TEMPORAL') === 'Temporal — Level 2');
  check('general spells sort first, then each tradition by its label',
    T.heldOrder('', 'ward') < 0 && T.heldOrder('ward', '') > 0 && T.heldOrder('', '') === 0
    && T.heldOrder('ward', 'ward') === 0 && T.heldOrder('bone', 'ward') < 0
    && T.heldOrder('ward', 'warlock') < 0);
  // The order and the heading together: every heading's rows are contiguous,
  // which is what lets the sheet print a heading once.
  const held = [
    { name: 'Globe of Daylight', level: 1, t: '' }, { name: 'Alarm: Silent', level: 0, t: 'ward' },
    { name: 'Air: Thunderclap', level: 1, t: 'warlock' }, { name: 'Condition: Agony', level: 0, t: 'ward' },
    { name: 'Carpet of Adhesion', level: 4, t: '' }, { name: 'Air: Cloud of Slumber', level: 1, t: 'warlock' },
  ].sort((a, b) => T.heldOrder(a.t, b.t) || (a.level - b.level) || a.name.localeCompare(b.name));
  const heads = held.map((x) => T.heldGroup(x.level, x.t));
  const runs = heads.filter((h, i) => i === 0 || h !== heads[i - 1]);
  check('sorted that way, no heading appears twice',
    new Set(runs).size === runs.length && runs.length === 4,
    runs.join(' | '));
  check('and they read general first, then Ward Symbols, then Warlock Elemental',
    runs.join('|') === 'Spells — Level 1|Spells — Level 4|Ward Symbols|Warlock Elemental — Level 1');

  // THE SHEET, pinned by source: it loads the module, reads a held spell's
  // tradition off the catalog it already holds, sorts by it and heads by it.
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  const sheetHtml = readFileSync(join(appDir, '..', 'character-sheet', 'index.html'), 'utf8');
  check('the sheet page loads the tradition module before its own script',
    sheetHtml.indexOf('/apps/character-creator/js/traditions.js') > 0
    && sheetHtml.indexOf('/apps/character-creator/js/traditions.js') < sheetHtml.indexOf('src="sheet.js"'));
  check('the sheet reads the tradition off its spell catalog, by name',
    /function spellTradition\(name\)[\s\S]{0,260}C\.spellCatalog[\s\S]{0,200}row\?\.tradition/.test(sheetSrc));
  check('and heads and orders a held spell through the module',
    /SpellTraditions\.heldGroup\(p\.level, tradOf\(p\)\)/.test(sheetSrc)
    && /SpellTraditions\.heldOrder\(tradOf\(A\), tradOf\(B\)\)/.test(sheetSrc));
  check('the old hard-coded spell heading is gone from the sheet',
    !/Spells — Level \$\{p\.level\}/.test(sheetSrc));
}

section('A table rolled more than once, and a row that sets attribute dice (BOOK-INGEST-AUDIT F120)');
{
  const LF = String.fromCharCode(10);
  const mk = (...lines) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: rcc', 'tags: []',
     ...lines, '---', '', '## Lore', '', 'x', ''].join(LF));
  const ROWS = ['  - { name: "Odd (01-40): Extra Eyes", description: "x", bonuses: { attributes: { PB: "-1d4" } } }',
    '  - { name: "Odd (41-70): Bronze Skin", description: "x", attribute_dice: { PB: "2d4" } }',
    '  - { name: "Odd (71-90): Horns", description: "x" }',
    '  - { name: "Odd (91-00): Tail", description: "x" }',
    '  - { name: "Odd (91-00): Wings", description: "x" }'];
  const FROM = '["Odd (01-40): Extra Eyes", "Odd (41-70): Bronze Skin", "Odd (71-90): Horns", "Odd (91-00): Tail", "Odd (91-00): Wings"]';
  const table = (rolls) => mk('attribute_dice: { PB: "3d6", Spd: "4d6" }', 'special_abilities:', ...ROWS,
    `  - { rolls: ${rolls}, from: ${FROM} }`);

  // `rolls` STANDS WHERE `choose` WOULD, and the parser fills `choose` in with
  // the most the group can hold, so every reader of a group's limit is right
  // without knowing the key exists.
  const two = table('2');
  const dice = table('"1d4"');
  const group = (c) => c.data.special_abilities.find((e) => e.rolls !== undefined);
  check('a group may state how many times its table is rolled, as a number or as dice',
    two.ok && dice.ok, [...two.errors, ...dice.errors].join('; '));
  check('the parser fills choose with the most the group can hold: the number, or the dice ceiling',
    group(two).choose === 2 && group(dice).choose === 4
    && abilityRollLimit(2) === 2 && abilityRollLimit('1d4') === 4 && abilityRollLimit('2d4+1') === 9);
  check('so the per-group count and the offered list see an ordinary group',
    String(abilityGroupCounts(dice.data, ['Odd (71-90): Horns', 'Odd (91-00): Tail'])) === '2'
    && abilityGroupIndexFor(dice.data, 'Odd (71-90): Horns') === 0);
  check('rolls and choose that disagree are an error; that agree, fine',
    !mk('special_abilities:', ...ROWS, `  - { rolls: 2, choose: 3, from: ${FROM} }`).ok
    && mk('special_abilities:', ...ROWS, `  - { rolls: 2, choose: 2, from: ${FROM} }`).ok);
  check('rolls must be a whole number of 1 or more, or unsigned dice',
    [0, -1, '"lots"', '"-1d4"', 1.5].every((r) => !table(String(r)).ok));
  check('a rolls group needs band-named options covering 01-00, since a table with a hole cannot be rolled',
    !mk('special_abilities:', '  - { name: "A", description: "x" }', '  - { name: "B", description: "x" }',
      '  - { rolls: 2, from: ["A", "B"] }').ok
    && !mk('special_abilities:', '  - { name: "K (01-50): A", description: "x" }',
      '  - { name: "K (61-00): B", description: "x" }',
      '  - { rolls: 2, from: ["K (01-50): A", "K (61-00): B"] }').ok);
  check('a count that can outrun the table is warned about, not refused',
    mk('special_abilities:', '  - { name: "K (01-50): A", description: "x" }',
      '  - { name: "K (51-00): B", description: "x" }',
      '  - { rolls: "1d4", from: ["K (01-50): A", "K (51-00): B"] }').warnings
      .some((w) => w.includes('more results than the table has rows')));

  // WHAT THE RACE STEP WAITS FOR. The rolled count is not stored, so a dice
  // table owes only the least its dice can come up; holding a player who
  // rolled 2 on 1D4 until four rows were held is what the filled-in choose did.
  check('a dice table owes its dice minimum, a counted table its count, a choose group its choose',
    abilityGroupOwed(group(dice)) === 1 && abilityGroupOwed(group(two)) === 2
    && abilityGroupOwed({ choose: 3, from: ['A', 'B', 'C'] }) === 3
    && abilityGroupOwed(table('"2d4"').data.special_abilities.find((e) => e.rolls)) === 2);
  check('every row of a rolls table needs a definition, or the server could not refuse a repeat',
    !mk('special_abilities:', '  - { name: "K (01-50): A", description: "x" }',
      '  - { rolls: 2, from: ["K (01-50): A", "K (51-00): B"] }').ok);

  // THE ROLL. The dice are passed in, so the walk is pinned exactly.
  check('a rolls group is a table the wizard may roll, whatever its count',
    Array.isArray(abilityRollBands(group(two))) && Array.isArray(abilityRollBands(group(dice))));
  check('and a plain choose-2 group is still not one',
    abilityRollBands({ choose: 2, from: ['K (01-50): A', 'K (51-00): B'] }) === null);
  const seq = (...n) => { let i = 0; return () => n[i++]; };
  const r1 = rollAbilityTable(group(dice), 3, seq(10, 20, 55, 80));
  check('each roll takes the row it lands on',
    String(r1.picks) === 'Odd (01-40): Extra Eyes,Odd (41-70): Bronze Skin,Odd (71-90): Horns');
  check('a roll that lands on a row already held is rolled again, and the log says so',
    r1.log.length === 4 && r1.log[1].roll === 20 && r1.log[1].taken === null);
  check('no row is ever taken twice', Array.from({ length: 200 }, () =>
    rollAbilityTable(group(dice), 4, () => 1 + Math.floor(Math.random() * 100)).picks)
    .every((picks) => new Set(picks).size === picks.length && picks.length >= 3));
  const full = rollAbilityTable(group(dice), 4, seq(1, 1, 50, 75, 1, 50, 95));
  check('and a band that prints two results is left to the player, not ruled on',
    String(full.picks) === 'Odd (01-40): Extra Eyes,Odd (41-70): Bronze Skin,Odd (71-90): Horns'
    && full.log[full.log.length - 1].taken === undefined
    && full.log[full.log.length - 1].names.length === 2);
  check('a count larger than the table stops when every band has been landed on',
    rollAbilityTable(group(dice), 99, () => 1 + Math.floor(Math.random() * 100)).log
      .filter((l) => l.taken !== null).length === 4);
  const twice = rollAbilityTable(group(dice), 4, seq(95, 95, 10, 50, 75));
  check('landing again on a band left to the player is a repeat, not a second result',
    twice.log[1].taken === null && twice.picks.length === 3);
  check('a count of zero, or a group that is not a table, rolls nothing',
    rollAbilityTable(group(dice), 0, seq(1)).picks.length === 0
    && rollAbilityTable({ choose: 2, from: ['A', 'B'] }, 2, seq(1, 2)).picks.length === 0);

  // THE SERVER holds the group to its ceiling and a row to one take; both are
  // the rules a choose group already had.
  const v = (abilities) => validateCharacter({ character: { level: 1 }, cls: dice.data, skills: [],
    attributes: {}, abilities, catalog: new Map() });
  const all = ['Odd (01-40): Extra Eyes', 'Odd (41-70): Bronze Skin', 'Odd (71-90): Horns', 'Odd (91-00): Tail'];
  check('the server allows up to the dice ceiling',
    !v(all).violations.some((x) => x.rule === 'ability_count'));
  check('and refuses one more',
    v([...all, 'Odd (91-00): Wings']).violations.some((x) => x.rule === 'ability_count'));
  check('and refuses a row taken twice',
    v(['Odd (71-90): Horns', 'Odd (71-90): Horns']).violations.some((x) => x.rule === 'ability_repeat'));

  // A ROW THAT PRINTS AN ATTRIBUTE'S DICE.
  check('an option may restate the dice an attribute is rolled on',
    applyAbilities(dice.data, ['Odd (41-70): Bronze Skin']).attribute_dice.PB === '2d4');
  check('only for the attributes it names',
    applyAbilities(dice.data, ['Odd (41-70): Bronze Skin']).attribute_dice.Spd === '4d6');
  check('and not when another row is held, nor on the class itself',
    applyAbilities(dice.data, ['Odd (71-90): Horns']).attribute_dice.PB === '3d6'
    && dice.data.attribute_dice.PB === '3d6');
  check('a class with no dice of its own takes the row\'s',
    applyAbilities({ special_abilities: dice.data.special_abilities }, ['Odd (41-70): Bronze Skin'])
      .attribute_dice?.PB === '2d4');
  check('the same table carries a reduction beside it, which is F119',
    applyAbilities(dice.data, ['Odd (01-40): Extra Eyes']).bonuses.attributes.PB === '-1d4');
  check('the dice must be the class\'s own grammar, on a real attribute',
    !mk('special_abilities:', '  - { name: "K (01-50): A", attribute_dice: { PB: "lots" } }',
      '  - { name: "K (51-00): B" }', '  - { choose: 1, from: ["K (01-50): A", "K (51-00): B"] }').ok
    && !mk('special_abilities:', '  - { name: "K (01-50): A", attribute_dice: { Luck: "3d6" } }',
      '  - { name: "K (51-00): B" }', '  - { choose: 1, from: ["K (01-50): A", "K (51-00): B"] }').ok
    && mk('special_abilities:', '  - { name: "K (01-50): A", attribute_dice: { PB: "N/A", PS: "30" } }',
      '  - { name: "K (51-00): B" }', '  - { choose: 1, from: ["K (01-50): A", "K (51-00): B"] }').ok);
  check('attribute_dice on an ability nobody is offered is warned about',
    mk('special_abilities:', '  - { name: "Loose", attribute_dice: { PB: "2d4" } }').warnings
      .some((w) => w.includes('states attribute_dice but is not offered')));
  // The server's attribute ceiling reads the composed class, so a row's dice
  // are what a stored attribute is held to.
  const withRow = applyAbilities(dice.data, ['Odd (41-70): Bronze Skin']);
  const ceil = (cls, PB) => validateCharacter({ character: { level: 1 }, cls, skills: [],
    attributes: { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 10, PB, Spd: 10 },
    abilities: ['Odd (41-70): Bronze Skin'], catalog: new Map() });
  const flagged = (res) => [...res.violations, ...res.warnings]
    .some((x) => /attribute/.test(x.rule || '') && (x.attribute === 'PB' || x.attr === 'PB' || /P\.?B/.test(x.message || '')));
  check('the server holds the attribute to the row\'s dice, not the class\'s',
    flagged(ceil(withRow, 14)) && !flagged(ceil(withRow, 8)) && !flagged(ceil(dice.data, 14)));

  // The wizard and the NPC generator are pinned by source: both roll through
  // the one walk, and a changed pick clears an attribute whose dice it moved.
  const appSrc = readFileSync(appPath('app.js'), 'utf8');
  check('the wizard rolls a rolls group through rollAbilityTable',
    /if \(group\.rolls !== undefined\) \{[\s\S]{0,400}rollAbilityTable\(group, count/.test(appSrc));
  check('and clears an attribute whose dice a pick restated, on confirming the race',
    /function confirmRace\(\) \{[\s\S]{0,700}const dice = S\.cls\?\.attribute_dice;\s+recompose\(\);\s+clearAttrsWhoseDiceChanged\(dice\);/.test(appSrc));
  const npcSrc = readFileSync(join(appDir, 'js', 'npc-generate.js'), 'utf8');
  check('the NPC generator rolls such a table rather than shuffling it',
    /if \(g\.rolls !== undefined\) \{[\s\S]{0,300}rollAbilityTable\(g, count/.test(npcSrc));
}

section('Reductions on dice, and a Horror Factor from a chosen ability (BOOK-INGEST-AUDIT F119)');
{
  const LF = String.fromCharCode(10);
  const mk = (...lines) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: rcc', 'tags: []',
     ...lines, '---', '', '## Lore', '', 'x', ''].join(LF));

  // A REDUCTION IS A BONUS WITH A MINUS. "Reduce M.E. by 1D6" was prose,
  // because a dice bonus had to start with a digit.
  const red = mk('bonuses:', '  attributes: { ME: "-1d6", PS: "2d6" }',
    '  combat: { initiative: "-1d4" }', '  pools: { sdc: "-2d4x10" }');
  check('a dice bonus may carry a leading minus, in attributes, combat and pools',
    red.ok && red.errors.length === 0, red.errors.join('; '));
  check('a leading plus is still refused, as it always was',
    !mk('bonuses:', '  attributes: { ME: "+1d6" }').ok);
  check('the unsigned predicate is untouched, so a quantity and a catalog dice field stay amounts',
    isDiceBonus('-1d6') === false && isSignedDiceBonus('-1d6') === true && isSignedDiceBonus('1d6') === true
    && !mk('equipment_starting:', '  - { item_id: "x", qty: "-1d6" }').ok);
  check('nor does the sign reach attribute dice: nothing is rolled on -3d6',
    isAttributeExpr('-3d6') === false);

  // Rolled and bounded the right way round. Pinning every die to its floor
  // gives a negative term its CEILING, which is what the bounds used to do.
  const rolls = Array.from({ length: 200 }, () => evalDiceBonus('-1d6'));
  check('a reduction rolls negative, inside its dice',
    rolls.every((v) => Number.isInteger(v) && v <= -1 && v >= -6) && rolls.some((v) => v < -1));
  check('and an ordinary bonus rolls as it did',
    Array.from({ length: 50 }, () => evalDiceBonus('2d6')).every((v) => v >= 2 && v <= 12));
  check('its bounds run from the most it can take to the least',
    JSON.stringify(diceBonusBounds('-1d6')) === '{"min":-6,"max":-1}'
    && JSON.stringify(diceBonusBounds('-2d4x10')) === '{"min":-80,"max":-20}'
    && JSON.stringify(diceBonusBounds('2d6')) === '{"min":2,"max":12}');
  check('a pool with a reduction is bounded the same way, alone and in a composed list',
    JSON.stringify(poolFormulaBounds(20, {}, '-1d6')) === '{"min":14,"max":19}'
    && JSON.stringify(poolFormulaBounds(20, {}, ['1d4', '-1d6', 3])) === '{"min":18,"max":26}');
  check('and rolls inside those bounds',
    Array.from({ length: 200 }, () => rollPoolFormula(20, {}, '-1d6')).every((v) => v >= 14 && v <= 19));
  // The wizard collects the dice by group and stores what they rolled; the
  // fold then counts the stored number, whatever its sign.
  check('the reduction is collected for rolling like any dice bonus',
    derive.diceBonuses(red.data).ME === '-1d6'
    && derive.diceBonusesByGroup(red.data).combat.initiative === '-1d4');
  check('and its stored roll lowers the attribute',
    derive.classBonuses(red.data, 1, { attributes: { ME: -4, PS: 7 }, combat: { initiative: -2 }, saves: {} })
      .attributes.ME === -4
    && derive.effective({ ME: 12 }, { attributes: { ME: -4 } }).ME === 8);

  // THE HORROR FACTOR A CHOSEN ABILITY CARRIES. Display-only, like the class's.
  const hf = mk('horror_factor: 9', 'special_abilities:',
    '  - { name: "Jaguar", description: "x" }',
    '  - { name: "Lion", description: "x", horror_factor: 10, bonuses: { attributes: { IQ: "-1d4" } } }',
    '  - { name: "Boar Head", description: "x", horror_factor_bonus: 2 }',
    '  - { name: "Rotting Skull", description: "x", horror_factor_bonus: 4 }',
    '  - { choose: 1, from: ["Jaguar", "Lion"] }',
    '  - { choose: 1, from: ["Boar Head", "Rotting Skull"] }');
  check('an option may restate the Horror Factor or add to it', hf.ok && hf.warnings.length === 0,
    [...hf.errors, ...hf.warnings].join('; '));
  check('unpicked, or on an option that states none, the class keeps its own',
    applyAbilities(hf.data, []).horror_factor === 9
    && applyAbilities(hf.data, ['Jaguar']).horror_factor === 9);
  check('a held option that restates it replaces it',
    applyAbilities(hf.data, ['Lion']).horror_factor === 10);
  check('a held option that adds to it is added, and two are summed',
    applyAbilities(hf.data, ['Boar Head']).horror_factor === 11
    && applyAbilities(hf.data, ['Boar Head', 'Rotting Skull']).horror_factor === 15);
  check('the bonus lands on the restated figure, in either pick order',
    applyAbilities(hf.data, ['Lion', 'Boar Head']).horror_factor === 12
    && applyAbilities(hf.data, ['Boar Head', 'Lion']).horror_factor === 12);
  check('onto a phrase it is appended as written rather than guessed at',
    applyAbilities({ ...hf.data, horror_factor: '10+1D4' }, ['Boar Head']).horror_factor === '10+1D4 +2');
  check('with no factor on the class the bonus is the factor',
    applyAbilities({ ...hf.data, horror_factor: undefined }, ['Boar Head']).horror_factor === 2);
  check('the class object is not mutated', hf.data.horror_factor === 9);
  check('the same pick carries its reduction, so one option holds both halves of F119',
    applyAbilities(hf.data, ['Lion']).bonuses.attributes.IQ === '-1d4');
  check('a bonus of zero, or one that is not a whole number, is an error',
    !mk('special_abilities:', '  - { name: "A", horror_factor_bonus: 0 }', '  - { choose: 1, from: ["A"] }').ok
    && !mk('special_abilities:', '  - { name: "A", horror_factor_bonus: "lots" }', '  - { choose: 1, from: ["A"] }').ok);
  check('a Horror Factor on an ability nobody is offered is warned about, since nothing applies it',
    mk('special_abilities:', '  - { name: "Loose", horror_factor: 12 }').warnings
      .some((w) => w.includes('states a Horror Factor but is not offered')));
  // The sheet reads cls.horror_factor off the composed class, and the picker
  // prints a tag per option; both are pinned by their source, not a render.
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet still reads the composed class for the card',
    sheetSrc.includes('C.cls?.horror_factor'));
  const appSrc = readFileSync(appPath('app.js'), 'utf8');
  check('and the picker shows what an option does to it',
    appSrc.includes('def?.horror_factor != null') && appSrc.includes('def?.horror_factor_bonus'));
  check('the wizard rolls a bonus through the signed evaluator',
    /typeof d === 'number' \? d : evalDiceBonus\(d\)/.test(appSrc));
}

section('Ability validation');
{
  const cls = parseClassMarkdown([
    '---', 'id: g', 'name: G', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:',
    '  - name: "Fly"', '    description: "x"',
    '  - name: "Shape Shifter"', '    description: "x"', '    repeatable: true',
    '  - name: "Super-Tough"', '    description: "x"',
    '    bonuses: { pools: { mdc: "3d4x10" } }',
    '  - { choose: 2, from: ["Fly", "Shape Shifter", "Super-Tough"] }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  const v = (abilities) => validateCharacter({
    character: { level: 1 }, cls, skills: [], attributes: {}, abilities, catalog: new Map() });
  // The fixture race grants nothing, so 1c25f's no_occupation warning fires on
  // every call - by design. Scope these assertions to the ability rules, and
  // pin that the only other emission really is that one.
  const rules = (r) => r.violations.map((x) => x.rule).concat(r.warnings.map((x) => '~' + x.rule))
    .filter((x) => x.includes('ability'));
  check('the only non-ability emission is the expected no_occupation warning', (() => {
    const r = validateCharacter({ character: { level: 1 }, cls, skills: [], attributes: {}, abilities: [], catalog: new Map() });
    const rest = r.violations.map((x) => x.rule).concat(r.warnings.map((x) => x.rule))
      .filter((x) => !x.includes('ability'));
    return rest.join(',') === 'no_occupation';
  })());

  check('the allowed count is enforced',
    rules(v(['Fly', 'Super-Tough', 'Shape Shifter'])).includes('ability_count'));
  check('and the message says both numbers',
    /3 chosen powers, but this class allows 2/.test(
      v(['Fly', 'Super-Tough', 'Shape Shifter']).violations[0].message));
  check('an exact pick is clean', rules(v(['Fly', 'Super-Tough'])).length === 0);
  check('no abilities at all is clean (every pre-#81 character)',
    rules(v(undefined)).length === 0 && rules(v([])).length === 0);

  check('a non-repeatable power taken twice is refused',
    rules(v(['Fly', 'Fly'])).includes('ability_repeat'));
  check('a repeatable one taken twice is fine',
    rules(v(['Shape Shifter', 'Shape Shifter'])).length === 0);
  check('a repeatable one taken a third time warns rather than blocks', (() => {
    const r = v(['Shape Shifter', 'Shape Shifter', 'Shape Shifter']);
    return r.violations.some((x) => x.rule === 'ability_count')   // 3 > 2, separately
      && !r.violations.some((x) => x.rule === 'ability_repeat')
      && r.warnings.some((x) => x.rule === 'ability_repeat');
  })());

  check('a power the class does not offer warns, never blocks', (() => {
    const r = v(['Fly', 'Parental Gift']);
    return r.violations.length === 0 && r.warnings.some((x) => x.rule === 'ability_unknown');
  })());

  // A { name, gm: true } entry is a ruling, not a pick - the Demigod's "most
  // have ONE extra power, similar to the godly parent's" is assigned by hand.
  check('a G.M.-assigned power does not spend the allowance',
    rules(v(['Fly', 'Super-Tough', { name: 'Shape Shifter', gm: true }])).length === 0);
  check('nor is it checked against the offered list',
    rules(v([{ name: 'Wrath of the Father', gm: true }])).length === 0);
  check('but holding a non-repeatable power twice is twice, whoever granted it',
    rules(v(['Fly', { name: 'Fly', gm: true }])).includes('ability_repeat'));

  // And the composer honours the ruling: a G.M.-assigned power still grants.
  const granted = applyAbilities(cls, [{ name: 'Super-Tough', gm: true }]);
  check('a G.M.-assigned power still grants its bonuses',
    granted.bonuses?.pools?.mdc === '3d4x10');
  check('and the sheet can see whose it was',
    granted.abilities_taken[0].gm === true && granted.abilities_taken[0].granted === true);
  check('a plain pick carries no gm flag',
    applyAbilities(cls, ['Super-Tough']).abilities_taken[0].gm === undefined);
}

// ---------- 1c25i. Dice-valued equipment quantities ----------
// The Priest of Light starts with 1D6 vials of holy water. qty used to flow to
// the sheet untouched, so a dice string rendered as "x1d6" and broke the
// sheet's number input; the class shipped with a fixed 3 as a workaround.
// Now a fixed entry's qty may be a dice expression, rolled ONCE at creation
// behind the wizard's equipInit guard. A choice's qty stays a plain number -
// it is re-derived every render, so a die there would re-roll each paint.
section('Dice-valued equipment quantities');
{
  check('a plain number passes through', rollQuantity(4) === 4);
  check('a missing qty is one item, not zero', rollQuantity(undefined) === 1);
  const rolls = new Set();
  for (let i = 0; i < 200; i++) rolls.add(rollQuantity('1d6'));
  check('a dice qty rolls in range', [...rolls].every((n) => n >= 1 && n <= 6));
  check('and actually varies', rolls.size > 1);
  check('an unreadable string is one item', rollQuantity('a few') === 1);
  check('zero and negatives clamp to one', rollQuantity(0) === 1 && rollQuantity(-2) === 1);

  const mkq = (lines) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'equipment_starting:'].concat(lines)
    .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10)));

  check('a dice qty on a fixed entry parses clean',
    mkq(['  - { item_id: "vial", qty: "1d6" }']).errors.length === 0);
  check('garbage qty on a fixed entry is refused',
    mkq(['  - { item_id: "vial", qty: "lots" }']).errors
      .some((e) => e.includes('qty must be a number')));
  check('a dice qty on a CHOICE is refused - it would re-roll every render',
    mkq(['  - { choose: 1, qty: "1d6", from: ["a", "b"] }']).errors
      .some((e) => e.includes('choice qty must be a plain number')));
  check('a numeric choice qty is fine',
    mkq(['  - { choose: 1, qty: 2, from: ["a", "b"] }']).errors.length === 0);

  // The wizard rolls inside the equipInit-guarded block, so the number is
  // stored (and draft-persisted) rather than re-rolled. Source pin, same
  // idiom as 1c25h.
  const appSrcQ = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard rolls the quantity once at init',
    appSrcQ.includes('rollQuantity(eq.qty'));
}

// ---------- 1c25h. Natural abilities reach the player ----------
// What a class simply HAS, as opposed to what is chosen. Four classes carry
// these (Demigod, Ley Line Walker, Glitter Boy, Priest of Light) and until
// now they appeared nowhere - not on the sheet, not in the wizard's class
// detail. Composition already concatenated both halves; only display was
// missing.
section('Natural abilities rendering');
{
  const mk = (extra) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b']
    .concat(extra)
    .concat(['---', '', '## Lore', '', 'x', '']).join('\n')).data;

  const race = mk(['category: rcc', 'natural_abilities:',
    '  - { name: "Regeneration", description: "Heals fast." }']);
  const occ = mk(['category: occ', 'natural_abilities:',
    '  - { name: "Sense Ley Line", description: "Feels the line." }']);

  const both = combineClasses(race, occ);
  check('composition concatenates natural abilities from both halves',
    both.natural_abilities?.length === 2
      && both.natural_abilities[0].name === 'Regeneration'
      && both.natural_abilities[1].name === 'Sense Ley Line');
  check('a half with none contributes none',
    combineClasses(mk(['category: rcc']), occ).natural_abilities?.length === 1);

  // The sheet lists them beside the chosen powers, and the wizard's class
  // detail shows them to a player still deciding. Source pins, same idiom as
  // 1c25f: the render path is browser-only, so the test reads the source.
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet renders natural abilities',
    /function naturalAbilities\(cls\)/.test(sheetSrc)
      && /\$\{naturalAbilities\(cls\)\}/.test(sheetSrc));
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard class detail renders them too',
    /function naturalAbilityList\(list\)/.test(appSrc)
      && /naturalAbilityList\(c\.natural_abilities\)/.test(appSrc));
  check('both tolerate a bare-string entry',
    /typeof a === 'string' \? a : a\?\.name/.test(sheetSrc)
      && /typeof a === 'string' \? a : a\?\.name/.test(appSrc));
}

// ---------- 1c25j. Level-scheduled save bonuses, and the curses key ----------
// bonuses.at_level had parser validation and derive support already; what the
// Ley Line Walker's "+3 vs curses at levels 3, 9, 11 and 14" lacked was a
// `curses` save key for the number to land on. It borrows the P.E. magic row,
// because a curse is magic - the same reasoning that gave illusionary magic
// its key.
section('Level-scheduled save bonuses, and the curses key');
{
  const cursed = parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'bonuses:',
    '  saves: { mind_control: 2 }',
    '  at_level:',
    '    - { level: 3, saves: { curses: 3 } }',
    '    - { level: 9, saves: { curses: 3 } }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('an at_level curses entry parses clean', cursed.errors.length === 0,
    cursed.errors.join('; '));

  const cb = (lvl) => D.classBonuses(cursed.data, lvl, null);
  check('below the first step there is nothing', (cb(1).saves.curses || 0) === 0);
  check('each reached step accumulates',
    cb(3).saves.curses === 3 && cb(9).saves.curses === 6);
  check('the flat mind_control half rides along at every level',
    cb(1).saves.mind_control === 2 && cb(9).saves.mind_control === 2);

  // The key exists all the way to the rendered save: derive's table carries a
  // curses row (P.E. magic chart), and the class bonus folds onto it.
  const merged = D.saves({ PE: 16, ME: 10 }, {}, null, cb(9));
  check('the sheet-level save has a curses row and folds the bonus in',
    merged.curses === 7);  // +1 from P.E. 16 on the magic chart, +6 from class
  const plain = D.saves({ PE: 10, ME: 10 }, {}, null, { saves: {} });
  check('a class granting nothing still shows the row, at the table value',
    plain.curses === 0);

  const sheetSrcJ = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet lists vs Curses', sheetSrcJ.includes("['curses', 'vs Curses']"));
}

// ---------- 1c25j2. One list of saves, and the two the races needed ----------
// The sheet and play mode each held their own copy of the save label list, and
// they had drifted: the sheet printed thirteen rows and play mode offered eight
// buttons, so the Juicer's +6 vs mind control and the Ley Line Walker's +3 vs
// curses were visible on the sheet and unrollable at the table. There is now one
// list and play mode filters the percentile row out of it.
//
// Faerie magic and disease were added because four Palladium Fantasy player
// races grant bonuses to them; fatigue is the newest, for the Operator's
// "+2 to save vs fatigue and disease" (RUE printed 92).
section('The save list');
{
  const src = readFileSync(appPath('sheet.js'), 'utf8');
  const saves = D.saves({ PE: 10, ME: 10 }, null);

  // Every save derive produces has a label, or it is computed and never shown.
  const listed = [...src.matchAll(/\['([a-z_]+)', 'vs [^']+'\]/g)].map((m) => m[1]);
  const missing = Object.keys(saves)
    .filter((k) => k !== 'psionics_target' && !listed.includes(k));
  check('every save derive produces is listed on the sheet', missing.length === 0,
    'not printed anywhere: ' + missing.join(', '));

  // And the reverse: a label for a key derive does not produce prints nothing.
  const dead = listed.filter((k) => !(k in saves));
  check('and every listed save is one derive produces', dead.length === 0,
    dead.join(', '));

  // One declaration. A second array literal of save labels is the drift.
  check('the save labels are declared exactly once',
    (src.match(/'vs Spell Magic'/g) || []).length === 1,
    'sheet.js declares the save list more than once');
  check('play mode rolls the list rather than restating it',
    /SAVE_ROLLS\s*=\s*SAVE_FIELDS\.filter/.test(src));
  check('and drops the percentile row, which is not a d20 save',
    !src.includes("SAVE_ROLLS") || /_pct/.test(src.match(/SAVE_ROLLS[^;]*/)[0]));

  // The two new keys borrow the P.E. rows, like the magic and poison saves.
  check('faerie magic follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).faerie_magic === 0 && s(18).faerie_magic === s(18).spell_magic
      && s(30).faerie_magic === 8;
  })());
  check('disease follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).disease === 0 && s(18).disease === s(18).toxins_poisons
      && s(30).disease === 8;
  })());
  check('fatigue follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).fatigue === 0 && s(18).fatigue === s(18).toxins_poisons
      && s(30).fatigue === 8;
  })());
  check('a race can grant both', (() => {
    const b = { attributes: {}, combat: {}, saves: { faerie_magic: 1, disease: 2 } };
    const s = D.saves({ PE: 10, ME: 10 }, null, null, b);
    return s.faerie_magic === 1 && s.disease === 2;
  })());
}

// ---------- 1c25k. Variable psionic costs (isp_note) ----------
// The isp column is live - the sheet's use button deducts it - so a power
// whose cost is not one number (Mind Bolt costs more for more damage) could
// only be stored wrong: a flat number spends the wrong amount, a zero reads
// as free and matches the stub heuristic. Migration 020's isp_note carries
// the schedule; isp keeps the minimum, which is what the use button deducts.
section('Variable psionic costs');
{
  const psiFields = CATALOGS.psionics.fields.map((f) => f.name);
  check('the catalog editor offers the note field', psiFields.includes('isp_note'));
  check('placed beside the cost it qualifies',
    psiFields.indexOf('isp_note') === psiFields.indexOf('isp') + 1);

  // The import spec that used to be pinned here went with the in-app
  // importer. The FIELD is what matters to the app and it is still pinned
  // above and rendered below; nothing writes a psionic power through an
  // extraction any more.

  // The two render sites: the wizard's picker marks the minimum with a plus
  // and shows the note; the sheet carries it through the character's stored
  // power row (cost_note) beside the use button. Source pins, same idiom as
  // 1c25h.
  const appSrcK = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the picker shows the note and marks the minimum',
    appSrcK.includes("p.isp_note && p.isp > 0 ? '+' : ''") && appSrcK.includes('esc(p.isp_note)'));
  check('the wizard stores cost_note on the character',
    appSrcK.includes('cost_note: p.isp_note'));
  const sheetSrcK = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet shows the note beside the use button',
    sheetSrcK.includes('escHtml(p.cost_note)') && sheetSrcK.includes("p.cost_note && cost > 0 ? '+' : ''"));
}

// ---------- Variable spell costs (ppe_note) ----------
// Migration 021 mirrors 020 for spells: ppe is live (the use button deducts
// it), so Manipulate Objects - priced by a schedule, imported as 0 - could
// only read as free while matching the stub heuristic. Same convention, same
// surfaces: ppe keeps the minimum, ppe_note says the schedule.
//
// This section was the first of the hand-numbered ones converted to section(),
// and the comment here then claimed it had been the last bare console.log
// left. It was not: the four sections above it - dice-valued quantities, the
// curses key, the save list and the psionic costs - stayed bare until
// 2026-09-17, printing into every --section run regardless of the filter,
// with their checks counted against whichever section had announced itself
// last. Measured before the conversion: a run filtered to "Natural abilities
// rendering" reported 26 checks in 1 section, and 21 of those were the three
// bare sections' after it (7, 9 and 5); its own are 5. A bare log sits at
// column 0 where every check() is indented, so `grep -n '^console.log'` on
// this file is how to know whether any remain, and as of that date it finds
// none.
section('Variable spell costs');
{
  const spFields = CATALOGS.spells.fields.map((f) => f.name);
  check('the catalog editor offers the note field', spFields.includes('ppe_note'));
  check('placed beside the cost it qualifies',
    spFields.indexOf('ppe_note') === spFields.indexOf('ppe') + 1);

  // Same as the psionic section above: the import spec pinned here left with
  // the importer, and the field it qualified did not.

  // The spell picker and payload, pinned like the psionic ones above. The
  // sheet needs no pin of its own: powerRows reads cost_note for spells and
  // psionics through the same path.
  const appSrcL = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the picker shows the note and marks the minimum',
    appSrcL.includes("sp.ppe_note && sp.ppe > 0 ? '+' : ''") && appSrcL.includes('esc(sp.ppe_note)'));
  check('the wizard stores cost_note on the character',
    appSrcL.includes('cost_note: sp.ppe_note'));
}

// ---------- 1c26. Secondary schedules and group bonuses ----------
section('Draft apostrophe escaping');
{
  // BOOK-INGEST-AUDIT.md F13. Ten Phase World classes shipped with doubled
  // apostrophes in their STORED markdown, because the drafts had been escaped
  // for SQL before `--emit-script` escaped them again. It renders to the reader
  // exactly as stored, so a class detail page showed two where one was written.
  //
  // The generator was never the cause, and this pins that: `literal()` doubles
  // each apostrophe exactly ONCE. All 157 add-*-class.sql files went through it
  // and exactly ten came out over-escaped, which is the arithmetic that
  // acquitted it - a broken generator would have done it to all 157.
  const cc = readFileSync(join(repoRoot, 'scripts', 'class-check.mjs'), 'utf8');
  const doublings = [...cc.matchAll(/replace\(\/'\/g, ?"''"\)/g)];
  check('class-check doubles an apostrophe in exactly two places',
    doublings.length === 2,
    `${doublings.length} - one for column values, one for spliced markdown`);

  // The advisory that catches the next pre-escaped draft. A WARNING, because a
  // doubled apostrophe is legal prose if the author meant it, and F13's posture
  // is explicit that a gate on it would be wrong.
  check('and warns when a draft arrives already escaped',
    cc.includes('doubled apostrophe(s) in the draft'));
  check('and that warning moves no exit code', (() => {
    const at = cc.indexOf('doubled apostrophe(s) in the draft');
    const block = cc.slice(cc.lastIndexOf('const doubled', at), at + 200);
    return block.includes('warnings.push') && !block.includes('errors.push');
  })());

  // The sweep is scoped to the ten ids rather than the whole table, so a class
  // that legitimately wants a doubled apostrophe later is untouched.
  const sweep = readFileSync(join(repoRoot, 'apps', 'character-creator', 'db',
    'fix-doubled-apostrophes.sql'), 'utf8');
  check('the sweep is scoped to named classes, not the whole table',
    sweep.includes('WHERE class_id IN ('));
  check('and it names every class it touches in its header',
    (sweep.match(/^--   [a-z-]+ +\d+$/gm) || []).length === 10);
}

section('Audit citation sweep');
{
  // BOOK-INGEST-AUDIT.md F12. A class's extraction note records both what the
  // BOOK prints - permanent - and what the APP could do that day - perishable -
  // in the same paragraph, and nothing swept the citers when a finding was
  // taken. `scripts/audit-citations.mjs` turns "who mentions F8" into a command.
  //
  // WHAT IS PINNED HERE IS ITS POSTURE, not its output: the output depends on a
  // live database and belongs to the person taking a finding.
  const cites = readFileSync(join(repoRoot, 'scripts', 'audit-citations.mjs'), 'utf8');

  // Executable lines only. The file EXPLAINS in prose why it does not read an
  // outcome note, quoting the words those notes use - so a check that scanned
  // the whole file would fail on the comment that exists to prevent the thing
  // it is checking for. That is not hypothetical: INGESTION-AUDIT F14, the
  // finding that DESCRIBES the outcome-note format, carries the note's own
  // shape inside backticks and every grep reports it taken when it is open.
  const code = cites.split('\n')
    .filter((l) => !/^\s*(\/\/|\*|\/\*)/.test(l))
    .join('\n');

  check('the citation sweep reads no outcome note', (() => {
    // The words an outcome note is written in. Any of them in EXECUTABLE code
    // would mean it had started deciding whether a finding was taken.
    return !/\b(Taken|Adjusted|Moot|Closed without)\b/.test(code);
  })(), 'it must answer who cites what, never whether the finding still stands');

  check('and sets no exit code of its own',
    !/process\.exit|process\.exitCode|exitCode\s*=/.test(code),
    'a gate here fires on every class citing a still-open finding');

  // It has to know EVERY shape the corpus uses, and there are three. The
  // Galactic Tracer writes "Filed as F6 in the Empire batch"; most notes write
  // the path, "BOOK-INGEST-AUDIT.md F3"; and the notes F53, F56 and F61-F63
  // wrote cite the bare menu, "BOOK-INGEST-AUDIT F61". On 2026-09-11 the script
  // answered "0 of 267" for F61 and F63 while production held their citers.
  //
  // So these run the script's OWN patterns, lifted out of its source. The check
  // they replace asked only that the file CONTAIN "BOOK-INGEST-AUDIT", and it
  // passed the whole time the bare form was invisible.
  const patterns = eval(cites.match(/const PATTERNS = (\[[\s\S]*?\n\];)/)?.[1]
    ?.replace(/\/\/[^\n]*/g, '').replace(/;$/, '') || 'null');
  const found = (text) => JSON.stringify(Array.isArray(patterns)
    ? patterns.flatMap((rx) => [...text.matchAll(rx)].map((m) => m[1].toUpperCase()))
    : null);
  check('the citation patterns are found',
    Array.isArray(patterns) && patterns.length > 0 && patterns.every((rx) => rx instanceof RegExp));
  check('and they match the bare-menu form the Spirit West notes use',
    found('capped at level 3 (BOOK-INGEST-AUDIT F61). Paradox') === '["F61"]',
    found('capped at level 3 (BOOK-INGEST-AUDIT F61). Paradox'));
  // ONCE: a class's Set dedupes a finding, but the LIMIT passages are collected
  // per match, so two patterns reading the same text would list it twice.
  check('and the path form, ONCE - no second pattern reads the same citation',
    found('The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a).') === '["F23"]',
    found('The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a).'));
  check('and the "Filed as" form',
    found('Filed as F6 in the Empire batch') === '["F6"]',
    found('Filed as F6 in the Empire batch'));
  // The script answers for BOOK-INGEST alone, and eleven menus number with F.
  check('and no other menu\'s F-number',
    found('see INGESTION-AUDIT F8 and SKILL-AUDIT F30') === '[]',
    found('see INGESTION-AUDIT F8 and SKILL-AUDIT F30'));

  // The protocol half. Taking a finding already required an outcome note in the
  // same PR; the step that was skipped is correcting the classes that cite it.
  const menu = readFileSync(join(repoRoot, '.claude', 'skills', 'audit-menu', 'SKILL.md'), 'utf8');
  check('the audit-menu skill requires citing classes to be corrected',
    /Correct every class note that cites the finding/.test(menu));
  check('and points at the command that lists them',
    /audit-citations\.mjs/.test(menu));

  // The convention half - where a note should draw the line in the first place.
  const importSkill = readFileSync(join(repoRoot, '.claude', 'skills', 'class-import', 'SKILL.md'), 'utf8');
  check('the class-import skill separates the permanent half from the perishable',
    /extraction_notes/.test(importSkill) && /perishable/i.test(importSkill));

  // The denominator. A retired class stays in imported_classes with deleted_at
  // set and status still 'published' - the generic warlock since 2026-09-04,
  // elemental-shaman since F63 split it on 2026-09-11 - so the unfiltered query
  // printed "of 267 published classes" when 265 could be picked, and would list
  // a retired class beside the live citers. Status alone is not the test;
  // drift-check, retro-check and source-coverage all ask both columns.
  //
  // So this runs the script's OWN live-row test, lifted out of its source,
  // rather than asking that the file mention deleted_at - a comment would.
  const liveSrc = code.match(/const isLive = ([^\n]+);/)?.[1];
  const isLive = liveSrc ? new Function(`return ${liveSrc}`)() : null;
  check('the citation sweep has a live-class test',
    typeof isLive === 'function', 'expected `const isLive = (r) => ...;` on one executable line');
  check('and it refuses a retired class that kept status published',
    typeof isLive === 'function'
      && isLive({ status: 'published', deleted_at: null }) === true
      && isLive({ status: 'published', deleted_at: '2026-09-11 00:00:00' }) === false
      && isLive({ status: 'draft', deleted_at: null }) === false);
  // A column the SELECT never asked for reads undefined, and a test written as
  // `== null` would then call every retired row live.
  check('and a row without the column is not live by default',
    typeof isLive === 'function' && isLive({ status: 'published' }) === false);
  const select = code.match(/d1Query\(\s*'(SELECT [^']*)'/)?.[1] ?? '';
  check('and the query selects both columns that test reads',
    /\bstatus\b/.test(select) && /\bdeleted_at\b/.test(select), select || 'no d1Query SELECT found');
  // The retired rows are FETCHED and set aside, never filtered in SQL: a
  // retired class's note is still a note, and hiding it silently is the
  // failure this script exists to prevent. It lists them after the live ones.
  check('and it keeps retired rows so it can list them, not drop them',
    select !== '' && !/\bWHERE\b/i.test(select), select);
}


// The four Nightbane second-body sections used to be written out here. They
// live in checks/second-body.mjs now and are CALLED here rather than at the
// bottom with the other modules, so the suite still announces its 164 sections
// in the order it always did - which is what makes "2737 checks in 164
// sections" before and after a comparison of the same thing rather than of two
// differently-ordered runs.
secondBodyChecks();

section('Psionic category narrowing');
{
  // BOOK-INGEST-AUDIT.md F16. A skill category has taken `only` / `except`
  // since the beginning; a psionic category could not. The Crazy's book allows
  // two categories "excluding Astral Projection, Ectoplasm, Object Read and
  // Telekinesis", and the only way to say that was `powers_from`, which
  // REPLACES the category gate rather than narrowing it - so it would have
  // meant enumerating the other forty-seven and re-enumerating them whenever a
  // Sensitive power was added.
  const mk = (block) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\npsionics:\n${block}\n---\n\n## Lore\n\nx\n`);

  const narrowed = mk(`  type: "minor"
  powers_starting: 3
  categories_allowed:
    - { name: "Sensitive", except: ["Object Read (Psychometry)"] }
    - "Physical"`);
  check('a psionic category takes an except', narrowed.ok, JSON.stringify(narrowed.errors));

  // The SAME function the skill pickers use, so the two cannot disagree about
  // what a category entry means.
  const cats = narrowed.data.psionics.categories_allowed;
  check('and the excluded power is refused',
    !categoryAllows(cats, { name: 'Object Read (Psychometry)', category: 'Sensitive' }));
  check('while the rest of its category is allowed',
    categoryAllows(cats, { name: 'Sixth Sense', category: 'Sensitive' }));
  check('and an unnarrowed category is untouched',
    categoryAllows(cats, { name: 'Levitation', category: 'Physical' }));
  check('and a category the class never named is still refused',
    !categoryAllows(cats, { name: 'Bio-Regeneration', category: 'Healing' }));

  check('an only list narrows the other way', (() => {
    const only = mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", only: ["Levitation"] }');
    const c = only.data.psionics.categories_allowed;
    return categoryAllows(c, { name: 'Levitation', category: 'Physical' })
      && !categoryAllows(c, { name: 'Ectoplasm', category: 'Physical' });
  })());

  // A plain string still means the whole category - every other class in the
  // catalog writes one, and none of them may change meaning.
  check('a plain string still opens the whole category', (() => {
    const plain = mk('  type: "minor"\n  categories_allowed: ["Physical"]');
    return categoryAllows(plain.data.psionics.categories_allowed,
      { name: 'Ectoplasm', category: 'Physical' });
  })());

  // A percentage is a SKILL idea: a psionic power has an I.S.P. cost and no
  // percentage to raise, so a bonus here would be stored and never read.
  check('a bonus on a psionic category is a parse error',
    !mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", bonus: 10 }').ok);
  check('and both narrowings at once is still an error',
    !mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", only: ["Levitation"], except: ["Ectoplasm"] }').ok);

  // An ability that GRANTS psionics carries the same block and reaches the same
  // gate, so it is validated too.
  check('an ability\'s psionics block is validated as well', (() => {
    const bad = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n'
      + 'special_abilities:\n  - name: "Awakening"\n    description: "d"\n    psionics: { type: master, categories_allowed: [{ name: "Super", bonus: 5 }] }\n'
      + '---\n\n## Lore\n\nx\n');
    return !bad.ok;
  })());

  // The server refuses what the picker will not offer - one function, three
  // call sites, the wizard twice and the grant checker once.
  const picks = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
    '_lib', 'power-picks.js'), 'utf8');
  check('the server gates psionic grants through the same function',
    picks.includes('categoryAllows(cats, row)'));
  const appSrc = readFileSync(join(repoRoot, 'apps', 'character-creator', 'app.js'), 'utf8');
  check('and neither wizard picker still tests membership by hand',
    !/allowed\.includes\(\w+\.category\)/.test(appSrc));

  // ---- and no psionic caption renders a category by string coercion (F96) ----
  // The level-up picker's caption used `cats.join(', ')` where every other
  // psionic caption uses categoryLabel, so an object category - live on
  // healing-shaman and totem-warrior - printed "[object Object]". The Totem
  // Warrior states one category and it is an object, so its WHOLE caption was
  // "[object Object]". Found by F92's premise pass, not by any check.
  //
  // A source check rather than a behavioural one because this is a page script:
  // the caption is a template literal inside a map, with no seam to call.
  check('no psionic caption joins raw category entries',
    !/\bcats\.join\(/.test(appSrc), 'use cats.map(categoryLabel).join instead');

  // And the function that makes it right must actually be reached from there.
  check('the level-up psionic caption goes through categoryLabel',
    /cats\.map\(categoryLabel\)\.join\(/.test(appSrc));

  // The defect itself, pinned as the shape rather than the line: a category
  // object must never stringify into a caption. This is what a reader sees.
  check('and an object category has a label that is not [object Object]', (() => {
    const label = categoryLabel({ name: 'Super', only: ['Bio-Manipulation'] });
    return label.includes('Super') && !label.includes('[object');
  })());

  // ---- and the two keys that WIN over categories_allowed (F91) ----
  // BOOK-INGEST-AUDIT.md F91, the same hole F88 closed one key over. A schedule
  // entry's own `categories` and a starting group's both REPLACE
  // categories_allowed at pick time, and neither was ever handed to
  // validateCategories - so the branch that wins was the branch nothing
  // checked, while the IDENTICAL entry on categories_allowed errored.
  const sched = (cats) => parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\n'
    + 'source_book: B\ncategory: occ\npsionics:\n  type: "minor"\n  powers_per_level: 1\n'
    + `  powers_schedule:\n    - { level: 3, count: 1, categories: ${cats} }\n`
    + '---\n\n## Lore\n\nx\n');
  const group = (cats) => parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\n'
    + 'source_book: B\ncategory: occ\npsionics:\n  type: "minor"\n  powers_starting: 4\n'
    + `  powers_starting_groups:\n    - { count: 4, categories: ${cats} }\n`
    + '---\n\n## Lore\n\nx\n');

  check('a schedule entry category setting both only and except is refused',
    !sched('[{ name: "Physical", only: ["Levitation"], except: ["Ectoplasm"] }]').ok);
  check('a schedule entry category with no name is refused',
    !sched('[{ only: ["Levitation"] }]').ok);
  check('and a prefix list on one written as a bare string',
    !sched('[{ name: "Physical", only_prefix: "Bio-" }]').ok);
  check('a starting group category entry is refused the same way',
    !group('[{ name: "Physical", only: ["Levitation"], except: ["Ectoplasm"] }]').ok);

  // THE OTHER DIRECTION, which is what stops this becoming a rule nobody can
  // satisfy. Both forms below are live in production - 446 schedule and 41
  // starting-group category entries across 318 classes, --remote 2026-09-15,
  // zero of them offenders - so either failing here would make classes vanish
  // from every picker rather than merely erroring.
  check('while a narrowed schedule entry still parses clean',
    sched('[{ name: "Sensitive", except: ["Object Read (Psychometry)"] }]').ok);
  check('and a bare string category is still accepted on both',
    sched('["Super"]').ok && group('["Physical", "Sensitive"]').ok);

  // The message names the key. Four callers now push into one errors array and
  // a bare "categories entries need a name" would not say which one.
  check('and the message names which key was wrong',
    (sched('[{ only: ["Levitation"] }]').errors || [])
      .some((m) => m.includes('psionics.powers_schedule.categories')));

  // ---- and a bonus is refused on all THREE lists, not one (F92) ----
  // `categories_allowed` has refused a bonus since F16. F91 then added two more
  // lists that reach the same gate and neither refused one, so
  // `{ name: "Super", bonus: 10 }` parsed clean on a schedule entry while the
  // identical entry one key over errored. A bonus is not inert either: F92's
  // premise pass found `categoryLabel` renders it, so the picker printed
  // "Super (+10%)" on a power that has no percentage to raise.
  const bonusErrs = (r) => (r.errors || []).filter((m) => m.includes('sets a bonus'));

  check('a bonus on a schedule entry category is refused',
    bonusErrs(sched('[{ name: "Super", bonus: 10 }]')).length === 1);
  check('and on a starting group category',
    bonusErrs(group('[{ name: "Physical", bonus: 10 }]')).length === 1);
  check('and categories_allowed still refuses one',
    bonusErrs(parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\n'
      + 'category: occ\npsionics:\n  type: "minor"\n  categories_allowed:\n'
      + '    - { name: "Physical", bonus: 10 }\n---\n\n## Lore\n\nx\n')).length === 1);

  // THE ABILITY-GRANTED SURFACES, which F92's own table does not name. The
  // refusal sits inside the psionicBlocks fold, so a class's own psionics and
  // any an ability grants are covered by one call rather than two - and a patch
  // written against `data.psionics` alone would have left these open.
  const ability = (block) => parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\n'
    + 'source_book: B\ncategory: occ\nspecial_abilities:\n  - name: "Awakening"\n'
    + `    description: "d"\n    psionics: { type: master, ${block} }\n`
    + '---\n\n## Lore\n\nx\n');

  check('an ability-granted schedule entry refuses a bonus too',
    bonusErrs(ability('powers_schedule: [{ level: 3, count: 1, '
      + 'categories: [{ name: "Super", bonus: 10 }] }]')).length === 1);
  check('and an ability-granted starting group',
    bonusErrs(ability('powers_starting_groups: [{ count: 2, '
      + 'categories: [{ name: "Super", bonus: 10 }] }]')).length === 1);

  // THE OTHER DIRECTION. A bonus of zero is still a bonus key and still refused;
  // a category with no bonus at all must stay clean on every list.
  check('while a schedule entry with no bonus stays clean',
    sched('[{ name: "Sensitive", except: ["Object Read (Psychometry)"] }]').ok === true
      && group('["Physical"]').ok === true);

  // One rule, one message. Three lists that disagreed about the same key is what
  // F92 was filed on, so the wording must not fork.
  check('and all three lists give the SAME message',
    new Set([
      bonusErrs(sched('[{ name: "Super", bonus: 10 }]'))[0],
      bonusErrs(group('[{ name: "Super", bonus: 10 }]'))[0],
    ].map((m) => m.replace(/^.*\.Super sets/, 'X sets'))).size === 1);
}

section('Magic composition');
{
  // BOOK-INGEST-AUDIT.md F14. F10 excluded magic saying no race/O.C.C. pair
  // states both. Thirteen races and eighteen occupations do - 234 pairs - and
  // the line was worse than the psionics bug beside it: psionics at least gave
  // the RACE the tie, magic handed the occupation the win with no comparison.
  const mk = (cat, magic) => parseClassMarkdown(
    `---\nid: t-${cat}\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\nmagic:\n${magic}\n---\n\n## Lore\n\nx\n`).data;

  const race = mk('rcc', `  type: "spell"
  spells: ["Globe of Daylight", "Cloud of Smoke"]
  spells_starting: 10
  spell_levels_allowed: [1, 2, 3, 4]`);
  const occ = mk('occ', `  type: "elemental"
  spells: ["Cloud of Smoke", "Fire Bolt"]
  spells_starting: 3
  spell_levels_allowed: [1]`);
  const both = combineClasses(race, occ).magic;

  check('a race and an occupation both stating magic keep both', (both.spells || []).length === 3);
  check('and a spell both grant is held once',
    both.spells.filter((n) => n === 'Cloud of Smoke').length === 1);

  // THE TYPE IS A KIND, NOT A DEGREE - the one real difference from psionics.
  // `spell`, `elemental`, `druid`, `intuitive` are how a character casts, so
  // there is no stronger to compute and the occupation's statement wins.
  check('the type is the occupation\'s, because it is a kind and not a degree',
    both.type === 'elemental');

  // A count takes the higher, the reading F10 arrived at: taking the
  // occupation's is LOWER in 35 of the 108 live pairs that state both.
  check('a count takes the higher of the two', both.spells_starting === 10);

  // The level set is WIDENED. Taking the occupation's drops a level the race
  // allows in 19 of the 28 pairs stating both - an entrancer who becomes a
  // Warlock would lose levels 2, 3 and 4 from its own page.
  check('the allowed spell levels are unioned and sorted',
    JSON.stringify(both.spell_levels_allowed) === JSON.stringify([1, 2, 3, 4]));

  // So are the TRADITIONS a level-gated pick may reach (BOOK-INGEST-AUDIT F57),
  // for the same reason: an ocean-magic race must not lose its allowance to an
  // occupation that states its own.
  const oceanRace = mk('rcc', `  type: "spell"
  spells_starting: 2
  spell_levels_allowed: [1]
  spell_traditions_allowed: ["ocean"]`);
  const cloudOcc = mk('occ', `  type: "spell"
  spells_starting: 1
  spell_levels_allowed: [1]
  spell_traditions_allowed: ["Cloud", "ocean"]`);
  check('the allowed spell traditions are unioned, deduplicated and lower-cased',
    JSON.stringify(combineClasses(oceanRace, cloudOcc).magic.spell_traditions_allowed)
      === JSON.stringify(['ocean', 'cloud']));

  check('one side alone is untouched', (() => {
    const bare = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(race, bare).magic.spells_starting === 10
      && combineClasses(parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\n---\n\n## Lore\n\nx\n').data, occ).magic.spells_starting === 3;
  })());

  check('an unenumerated key survives the merge', (() => {
    const withLists = mk('occ', '  type: "spell"\n  spell_lists: ["Ley Line"]');
    return combineClasses(race, withLists).magic.spell_lists[0] === 'Ley Line';
  })());

  // A superseding class does not inherit the race's magic either - the same
  // exception it makes everywhere else (F11). Unexercised today, because the
  // only class carrying the flag states no magic, and coherent for when one does.
  check('a superseding class takes its own magic outright', (() => {
    const reborn = parseClassMarkdown(
      '---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nsupersedes_race: true\nmagic:\n  type: "druid"\n  spells_starting: 2\n---\n\n## Lore\n\nx\n').data;
    const c = combineClasses(race, reborn).magic;
    return c.type === 'druid' && c.spells_starting === 2 && !c.spells;
  })());

  // Both merges share one union helper, because they ask the same question of
  // different columns and the pair written twice is the pair that drifts.
  const src = readFileSync(join(repoRoot, 'apps', 'character-creator', 'js', 'parser.js'), 'utf8');
  check('the psionics and magic merges share one union helper',
    (src.match(/unionByName\(/g) || []).length >= 4 && (src.match(/function unionByName/g) || []).length === 1);
}

section('Psionics composition');
{
  // BOOK-INGEST-AUDIT.md F10. `combineClasses` used to CHOOSE between a race's
  // psionics block and an occupation's, and the comparison was strictly
  // greater, so a TIE handed the whole thing to the race and the occupation's
  // powers, picks, schedule, categories and I.S.P. formula were all discarded.
  //
  // A race says what a member of that race is born with; an occupation says
  // what training adds. They are two sentences, not rival answers to one
  // question.
  const mk = (cat, psi) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\npsionics:\n${psi}\n---\n\n## Lore\n\nx\n`).data;

  const race = mk('rcc', `  type: major
  isp_base: "1d4x10"
  powers: ["Sixth Sense", "Mind Block"]
  powers_starting: 8
  categories_allowed: ["Healing", "Physical", "Sensitive"]
  powers_schedule:
    - { level: 3, count: 1 }`);
  const occ = mk('occ', `  type: major
  isp_base: "3d6x10"
  powers: ["Mind Block", "Telekinesis"]
  powers_starting: 2
  categories_allowed: ["Sensitive", "Super"]
  powers_schedule:
    - { level: 2, count: 1 }
    - { level: 4, count: 2 }`);
  const both = combineClasses(race, occ).psionics;

  // THE TIE IS THE WHOLE BUG. Before F10 this returned the race's block entire.
  check('a tie no longer discards the occupation', both.powers_schedule.length === 2);

  // Inventories add up.
  check('granted powers are unioned', both.powers.length === 3
    && ['Sixth Sense', 'Mind Block', 'Telekinesis'].every((n) => both.powers.includes(n)));
  check('and a power both sides grant is held once',
    both.powers.filter((n) => n === 'Mind Block').length === 1);
  check('allowed categories are unioned', both.categories_allowed.length === 4
    && both.categories_allowed.includes('Super') && both.categories_allowed.includes('Healing'));

  // Counts take the HIGHER, which is not what F10 asked for: preferring the
  // occupation's figure is LOWER in 89 of the 165 live pairs that state both,
  // so a psychic dragon hatchling would have dropped from eight starting
  // powers to one for studying as a Dog Boy - the exact loss F10 exists to stop.
  check('a count takes the higher of the two', both.powers_starting === 8);

  // A ladder is not a count and cannot be maxed. Running both would fire both
  // sets of grants at every threshold.
  check('a schedule takes the occupation\'s', both.powers_schedule[0].level === 2);
  check('and falls back to the race\'s when the occupation states none', (() => {
    const plain = mk('occ', '  type: major\n  isp_base: "2d6"');
    return combineClasses(race, plain).psionics.powers_schedule[0].level === 3;
  })());

  // The tier is the one thing the old code was right about, and the I.S.P.
  // formula travels with it. A tie goes to the occupation.
  check('the tier is the stronger of the two', (() => {
    const minor = mk('occ', '  type: minor\n  isp_base: "2d6"');
    return combineClasses(race, minor).psionics.type === 'major';
  })());
  check('and a stronger occupation raises it', (() => {
    const master = mk('occ', '  type: master\n  isp_base: "2d6"');
    return combineClasses(race, master).psionics.type === 'master';
  })());
  check('the I.S.P. formula follows the tier', (() => {
    const minor = mk('occ', '  type: minor\n  isp_base: "2d6"');
    return combineClasses(race, minor).psionics.isp_base === '1d4x10';
  })());
  check('and a tie gives it to the occupation', both.isp_base === '3d6x10');
  check('a winner stating no formula falls back rather than blanking it', (() => {
    const master = mk('occ', '  type: master');
    return combineClasses(race, master).psionics.isp_base === '1d4x10';
  })());

  // One side only is unchanged behaviour, and must stay that way.
  check('a race alone keeps its block', (() => {
    const plain = mk('occ', '  type: minor').psionics;
    void plain;
    const noPsi = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(race, noPsi).psionics.powers_starting === 8;
  })());
  check('an occupation alone keeps its block', (() => {
    const noPsi = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(noPsi, occ).psionics.powers_starting === 2;
  })());

  // A key neither F10 nor this function knows about must survive rather than be
  // silently dropped. `powers_from` is in the corpus exactly once, which is the
  // argument for spreading rather than enumerating.
  check('an unenumerated key survives the merge', (() => {
    const withFrom = mk('occ', '  type: major\n  isp_base: "2d6"\n  powers_from: ["Bio-Manipulation"]');
    return combineClasses(race, withFrom).psionics.powers_from[0] === 'Bio-Manipulation';
  })());

  // The SECOND site, which F10 does not mention. `applyAbilities` folded an
  // ability's psionics block with the same strict-greater rule, and its comment
  // claims it is the same rule composition uses - which F10 would have made
  // false. The Godling is the live case: a minor psychic whose "Super-Psionic
  // Powers" ability grants `{ type: master }` and nothing else, so choosing the
  // ability's block outright replaced its I.S.P. formula with none at all.
  check('an ability raises the tier without erasing the class block', (() => {
    const cls = parseClassMarkdown(`---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\npsionics:\n  type: minor\n  isp_base: "M.E. number plus 1D6x10"\nspecial_abilities:\n  - name: "Super-Psionic Powers"\n    description: "d"\n    psionics: { type: master }\n---\n\n## Lore\n\nx\n`).data;
    const after = applyAbilities(cls, [{ name: 'Super-Psionic Powers' }]).psionics;
    return after.type === 'master' && after.isp_base === 'M.E. number plus 1D6x10';
  })());
}

section('Related-skill floors');
{
  // BOOK-INGEST-AUDIT.md F6. `occ_related_skills` says how many picks and which
  // categories are legal, and narrows a category with only/except. All three
  // are ceilings. `minimums` is the floor: "select 8 other skills, but at least
  // two must be selected from espionage and two from rogue skills".
  const mk = (rel) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  occ_related_skills:\n${rel}\n---\n\n## Lore\n\nx\n`);

  const two = mk(`    count: 8
    categories: ["Espionage", "Rogue", "Physical"]
    minimums:
      - { count: 2, category: "Espionage" }
      - { count: 2, category: "Rogue" }`);
  check('a per-category floor parses', two.ok, JSON.stringify(two.errors));
  check('and normalises to a list of categories',
    JSON.stringify(relatedMinimums(two.data))
      === JSON.stringify([{ count: 2, categories: ['Espionage'] },
                          { count: 2, categories: ['Rogue'] }]));

  // The City Rat's floor is a UNION - "at least three must be selected from
  // Physical or Rogue skills" - satisfied by three of either or any mix.
  const union = mk(`    count: 10
    categories: ["Physical", "Rogue"]
    minimums:
      - { count: 3, categories: ["Physical", "Rogue"] }`);
  check('a union floor parses', union.ok, JSON.stringify(union.errors));
  check('and keeps both categories in one floor',
    relatedMinimums(union.data).length === 1
      && relatedMinimums(union.data)[0].categories.length === 2);
  check('a class with no floors reports none', relatedMinimums(mk('    count: 4').data).length === 0);

  // Every one of these is an ERROR rather than a warning: a floor is enforced
  // server-side the moment it parses, so a floor that is wrong refuses every
  // character of its class, and one silently dropped puts the class back where
  // F6 found it.
  check('a floor outside the granted categories is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2, category: "Espionage" }').ok);
  check('a floor bigger than the whole allowance is rejected',
    !mk('    count: 3\n    categories: ["Physical"]\n    minimums:\n      - { count: 4, category: "Physical" }').ok);
  check('floors summing past the allowance are rejected',
    !mk('    count: 3\n    categories: ["Physical", "Rogue"]\n    minimums:\n      - { count: 2, category: "Physical" }\n      - { count: 2, category: "Rogue" }').ok);
  check('a floor with no category is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2 }').ok);
  check('a floor of zero is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 0, category: "Physical" }').ok);
  check('a floor setting both spellings is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2, category: "Physical", categories: ["Physical"] }').ok);
  check('minimums that is not a list is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums: 2').ok);

  // A FLOOR IS NOT A CEILING. The count and category rules are broken the
  // instant they are broken; a floor merely unmet may still be met by picks not
  // yet spent, so only an UNREACHABLE one is a violation. Without this every
  // half-built character would be refused a save.
  const cls = two.data;
  const st = (cats, allow = 8) => relatedFloorStatus(cls, cats, allow);
  check('no picks yet is not a violation', st([]).unreachable === false);
  check('floors met is not a violation',
    st(['Espionage', 'Espionage', 'Rogue', 'Rogue']).unreachable === false);
  check('spent out with no floor met is a violation',
    st(['Physical', 'Physical', 'Physical', 'Physical',
        'Physical', 'Physical', 'Physical', 'Physical']).unreachable === true);

  // The shortfalls are summed rather than tested one at a time. Six of eight
  // spent holding one espionage and no rogue leaves each floor individually
  // reachable and the two together needing three picks where two remain.
  check('shortfalls are summed against what is left',
    st(['Espionage', 'Physical', 'Physical', 'Physical', 'Physical', 'Physical']).unreachable === true);
  check('and are not tested one at a time',
    st(['Espionage', 'Rogue', 'Physical', 'Physical', 'Physical']).unreachable === false);

  // A union floor counts a pick from EITHER category and does not demand both.
  const uSt = (cats) => relatedFloorStatus(union.data, cats, 10);
  check('a union floor takes either category',
    uSt(['Physical', 'Physical', 'Physical']).floors[0].met === true);
  check('and a mix across the two',
    uSt(['Rogue', 'Physical', 'Rogue']).floors[0].met === true);

  // The allowance grows on a schedule, and the floor rides along with it: the
  // book says "at least two of the EIGHT", but a stored skill row records no
  // level, so the first eight cannot be told from the two granted at level
  // three. Counting over every related pick is the weaker reading, and the
  // weaker reading never refuses a character the book allows.
  check('a bigger allowance leaves more room, never less',
    st(['Physical', 'Physical', 'Physical', 'Physical', 'Physical', 'Physical'], 12).unreachable === false);

  // ── the wizard and the server must not disagree — RETRO-AUDIT R18 ──
  //
  // `relatedFloorStatus` takes an allowance and a list of the categories held,
  // and the wizard and the validator have to pass the SAME pair. They did not:
  // the wizard passed `occ_related_skills.count` and only the level-one picks,
  // while the server passes `relatedAllowance(cls, level)` and every
  // related-typed row, level-granted ones included.
  //
  // NOTHING EXERCISES THE WIZARD ITSELF - `app.js` is read here as source text
  // and never executed - so this pins the arithmetic the wizard is now supposed
  // to do, and the case that made a half-fix worse than the bug.
  const lvlCls = parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n`
    + `  occ_related_skills:\n    count: 7\n`
    + `    minimums:\n      - { count: 2, category: "Science" }\n`
    + `    categories: ["Science", "Physical"]\n`
    + `    schedule: [{ level: 3, count: 2 }]\n---\n\n## Lore\n\nx\n`).data;

  check('the allowance a level-3 character gets is the count plus the grant',
    relatedAllowance(lvlCls, 1) === 7 && relatedAllowance(lvlCls, 3) === 9);

  // Seven off-floor picks at level 1: no room left, so the floor is out of
  // reach and the save is refused. Both sides agree, and always did.
  const seven = Array.from({ length: 7 }, () => 'Physical');
  check('spent out at level one is unreachable',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 1)).unreachable === true);

  // THE CASE THE OLD WIZARD GOT RIGHT BY ACCIDENT. At level 3 the same seven
  // picks leave two banked, so the floor is still reachable and the server
  // accepts. Passing `count` here says unreachable - a false alarm.
  check('and reachable at level three, because the schedule banked two',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 3)).unreachable === false);
  check('where the old count-only allowance would have cried wolf',
    relatedFloorStatus(lvlCls, seven,
      lvlCls.skills.occ_related_skills.count).unreachable === true);

  // THE CASE A HALF-FIX WOULD HAVE MISSED, which is the one that matters. Spend
  // the two banked picks off-floor as well and the character really is illegal.
  // The server counts all nine because level-granted picks are stored
  // `type: 'related'`; a wizard that raised the allowance to 9 but still counted
  // only the first seven would compute two picks remaining and say NOTHING.
  const nine = Array.from({ length: 9 }, () => 'Physical');
  check('nine off-floor picks at level three are unreachable',
    relatedFloorStatus(lvlCls, nine, relatedAllowance(lvlCls, 3)).unreachable === true);
  check('and counting only the level-one picks would have gone silent on it',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 3)).unreachable === false);
}

section('Secondary schedules & group bonuses');
{
  const mk = (skills) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n${skills}\n---\n\n## Lore\n\nx\n`);

  // ── secondary_skills.schedule ──
  const sched = mk(`  occ_related_skills:
    count: 8
    categories: ["Wilderness"]
    schedule:
      - { level: 3, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 1 }
      - { level: 7, count: 1 }`);
  check('a secondary schedule parses', sched.ok, JSON.stringify(sched.errors));
  check('a malformed secondary schedule is rejected',
    !mk('  secondary_skills:\n    count: 4\n    schedule:\n      - { level: "four", count: 1 }').ok);

  check('both kinds of grant are returned, tagged', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    const rel = g.filter((x) => x.kind === 'related');
    const sec = g.filter((x) => x.kind === 'secondary');
    return rel.length === 1 && rel[0].count === 2 && sec.length === 2;
  })());
  // Related picks carry the class's categories; secondary picks are unbounded,
  // which is why they cannot share one list.
  check('only related grants carry categories', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    return g.filter((x) => x.kind === 'related').every((x) => Array.isArray(x.categories))
      && g.filter((x) => x.kind === 'secondary').every((x) => x.categories === null);
  })());
  check('a class with no secondary schedule grants none', (() => {
    const g = skillGrantsFor(mk('  secondary_skills:\n    count: 4').data, 1, 15);
    return g.every((x) => x.kind !== 'secondary');
  })());

  // Merging the two would let an unrestricted secondary grant unrestrict the
  // related picks with it, which is the bug this separation exists to prevent.
  check('a secondary grant does not unrestrict related picks', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    const related = g.filter((x) => x.kind !== 'secondary');
    return related.length > 0 && related.every((x) => x.categories !== null);
  })());

  // ── dedupeCategories ──
  check('object categories dedupe by value, not identity', (() => {
    const a = { name: 'Espionage', only: ['Escape Artist'] };
    const b = { name: 'Espionage', only: ['Escape Artist'] };
    return dedupeCategories([a, b, 'Wilderness', 'wilderness']).length === 2;
  })());

  // ── `bonus` on a choice group ──
  check('a group bonus parses', mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], bonus: 30 }').ok);
  check('base and bonus together are rejected', (() => {
    const r = mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], base: 80, bonus: 30 }');
    return !r.ok && r.errors.some((e) => /both base and bonus/.test(e));
  })());
  check('a non-numeric bonus is rejected',
    !mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], bonus: "lots" }').ok);

  // The arithmetic the wizard performs. A flat base gave every pick in a group
  // the same percentage regardless of what the skill itself starts at.
  const resolve = (catBase, explicit) => {
    const base = explicit.base ?? (explicit.bonus && catBase ? catBase + explicit.bonus : catBase);
    return base;
  };
  check('a bonus adds to each skill\'s own base', (() => (
    resolve(50, { bonus: 30 }) === 80 && resolve(30, { bonus: 30 }) === 60
  ))());
  check('a flat base still overrides everything', resolve(50, { base: 80 }) === 80);
  // A W.P. has no percentage for a percentage bonus to modify.
  check('a bonus leaves a non-percentile skill at zero', resolve(0, { bonus: 30 }) === 0);
  check('no base and no bonus falls back to the catalog', resolve(45, {}) === 45);
}

// ---------- 1c27. Variant skill overrides & the major-psionic penalty ----------
section('Variant skills & psionic penalty');
{
  const mk = (variantBody) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: palladium-fantasy\nsource_book: B\ncategory: rcc\nskills:\n  occ_skills:\n    - { name: "Basic Math", base: 96, per_level: 0 }\n    - { name: "Advanced Math", base: 96, per_level: 0 }\n  occ_related_skills:\n    count: 8\n    categories: ["Wilderness"]\n  secondary_skills:\n    count: 4\nvariants:\n  - id: hatchling\n    name: "T Hatchling"\n${variantBody}\n  - id: adult\n    name: "T Adult"\n---\n\n## Lore\n\nx\n`);

  const ok = mk('    skill_overrides:\n      - { name: "Advanced Math", base: 45, per_level: 5 }');
  check('a skill override parses', ok.ok, JSON.stringify(ok.errors));
  check('the override applies to its own stage only', (() => {
    const get = (c, n) => c.skills.occ_skills.find((s) => s.name === n)?.base;
    return get(applyVariant(ok.data, 'hatchling'), 'Advanced Math') === 45
      && get(applyVariant(ok.data, 'adult'), 'Advanced Math') === 96;
  })());
  check('skills the override does not name are untouched', (() => {
    const c = applyVariant(ok.data, 'hatchling');
    return c.skills.occ_skills.find((s) => s.name === 'Basic Math').base === 96;
  })());
  check('per_level can be overridden too', (() => {
    const c = applyVariant(ok.data, 'hatchling');
    return c.skills.occ_skills.find((s) => s.name === 'Advanced Math').per_level === 5;
  })());
  // The base class must not be mutated: applyVariant is called repeatedly on
  // the same parsed object, and a stage bleeding into the next would be silent.
  check('applying a variant does not mutate the class', (() => {
    applyVariant(ok.data, 'hatchling');
    return ok.data.skills.occ_skills.find((s) => s.name === 'Advanced Math').base === 96;
  })());
  check('skill_overrides does not leak onto the resolved class',
    !('skill_overrides' in applyVariant(ok.data, 'hatchling')));

  // An override restates a number; it is not a way to add a skill.
  check('naming a skill the class does not grant is an error', (() => {
    const r = mk('    skill_overrides:\n      - { name: "Prowl", base: 30 }');
    return !r.ok && r.errors.some((e) => /does not grant/.test(e));
  })());
  check('an override that changes nothing is an error',
    !mk('    skill_overrides:\n      - { name: "Basic Math" }').ok);
  check('a non-numeric override is an error',
    !mk('    skill_overrides:\n      - { name: "Basic Math", base: "lots" }').ok);
  check('skill_overrides must be a list',
    !mk('    skill_overrides: "Basic Math"').ok);

  // ── the major psionic's price (p.21) ──
  const cls = mk('').data;
  const rolled = (tier) => withRolledPsionics(cls, { psychic_tier: tier, psychic_shape: 'broad' });

  check('a rolled major halves the related-skill count',
    rolled('major').skills.occ_related_skills.count === 4);
  check('a rolled minor pays nothing',
    rolled('minor').skills.occ_related_skills.count === 8);
  check('halving rounds down', (() => {
    const odd = mk('').data;
    odd.skills.occ_related_skills = { ...odd.skills.occ_related_skills, count: 7 };
    return withRolledPsionics(odd, { psychic_tier: 'major' }).skills.occ_related_skills.count === 3;
  })());
  // "Secondary skills are not affected."
  check('secondary skills are untouched',
    rolled('major').skills.secondary_skills.count === 4);
  check('the class is not mutated by the penalty',
    cls.skills.occ_related_skills.count === 8);
  // A psychic O.C.C. never rolls, so it never pays this price.
  check('a class-granted major psionic pays nothing', (() => {
    const mage = { skills: { occ_related_skills: { count: 8 } }, psionics: { type: 'major' } };
    return withRolledPsionics(mage, { psychic_tier: 'major' }).skills.occ_related_skills.count === 8;
  })());

  // ── races with no psychic potential (p.21: troll, orc) ──
  check('a class may declare no psionics at all', (() => (
    rollsForPsionics({ psionics_allowed: false }) === false
  ))());
  check('an ordinary class still rolls', rollsForPsionics({}) === true);
  check('a class with its own psionics does not roll',
    rollsForPsionics({ psionics: { type: 'major' } }) === false);

  // ── a race that rolls on its OWN psionics table (BOOK-INGEST-AUDIT F118) ──
  // The table is a pick group whose options carry the psionics; the class
  // states psionics_allowed: false so the standard roll is never offered,
  // whatever is picked, and the options' blocks still apply.
  const ownTable = (flag) => ({
    id: 'own-table', name: 'Own Table', category: 'rcc',
    ...(flag ? { psionics_allowed: false } : {}),
    special_abilities: [
      { name: 'Psionics (01-77): None', description: 'No psionics.' },
      { name: 'Psionics (78-00): Minor', description: 'Two powers.',
        psionics: { type: 'minor', isp_base: '2d6', powers_starting: 2 } },
      { choose: 1, from: ['Psionics (01-77): None', 'Psionics (78-00): Minor'] },
    ],
  });
  check('without the flag, landing on None still sends the race to the standard roll',
    rollsForPsionics(applyAbilities(ownTable(false), ['Psionics (01-77): None'])) === true);
  check('with it the race never rolls: unpicked, on None, or on a psionic result',
    rollsForPsionics(ownTable(true)) === false
    && rollsForPsionics(applyAbilities(ownTable(true), ['Psionics (01-77): None'])) === false
    && rollsForPsionics(applyAbilities(ownTable(true), ['Psionics (78-00): Minor'])) === false);
  check('and the picked option still grants its psionics through the flag',
    applyAbilities(ownTable(true), ['Psionics (78-00): Minor']).psionics?.type === 'minor');
  check('a rolled tier is refused on a class that may not roll, so the server cannot be handed one',
    withRolledPsionics(applyAbilities(ownTable(true), ['Psionics (01-77): None']),
      { psychic_tier: 'major' }).psionics === undefined
    && withRolledPsionics({ psionics_allowed: false }, { psychic_tier: 'minor' }).psionics === undefined);
  check('while an ordinary class is still handed its rolled tier',
    withRolledPsionics({ skills: {} }, { psychic_tier: 'minor' }).psionics?.from_roll === true);
  // The flag was dropped from a class in the OCCUPATION slot: the race's rides
  // combineClasses' spread and the occupation's did not.
  const plainRace = { id: 'plain', name: 'Plain', category: 'rcc' };
  const flaggedOcc = { ...ownTable(true), id: 'own-occ', category: 'occ' };
  check('the flag survives a pairing from the occupation as well as from the race',
    rollsForPsionics(combineClasses(plainRace, flaggedOcc)) === false
    && rollsForPsionics(combineClasses(ownTable(true), { id: 'o', name: 'O', category: 'occ' })) === false);
  check('and a pairing where neither half states it still rolls',
    rollsForPsionics(combineClasses(plainRace, { id: 'o', name: 'O', category: 'occ' })) === true);
  check('the briefing can tell an own-table race from one with no psychic potential',
    abilityOffersPsionics(ownTable(true)) === true
    && abilityOffersPsionics({ psionics_allowed: false }) === false
    && abilityOffersPsionics({ special_abilities: [{ name: 'Loose', psionics: { type: 'minor' } }] }) === false);
  check('class-check is told about a table left rolling, by its None option',
    String(psionicsTableLeftRolling(ownTable(false))) === 'Psionics (01-77): None');
  check('and is told nothing once the flag is there, or when the class has psionics of its own',
    psionicsTableLeftRolling(ownTable(true)).length === 0
    && psionicsTableLeftRolling({ ...ownTable(false), psionics: { type: 'minor' } }).length === 0);
  check('nor about a group with no None option, or a None beside no psionic option',
    psionicsTableLeftRolling({ special_abilities: [
      { name: 'A', psionics: { type: 'minor' } }, { name: 'B' }, { choose: 1, from: ['A', 'B'] }] }).length === 0
    && psionicsTableLeftRolling({ special_abilities: [
      { name: 'Kind: none' }, { name: 'B' }, { choose: 1, from: ['Kind: none', 'B'] }] }).length === 0);
}

// ---------- 1c28. Character background tables ----------
// p.32-33. Nine percentile tables, all optional, nothing derived from them.
section('Background tables');
{
  // rules.js is a classic script, loaded by evaluating it against a stand-in
  // global — the same way [1c20] does, since that one is block-scoped.
  const bgGlobal = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'rules.js'), 'utf8'))
    .call(bgGlobal, bgGlobal);
  const R = bgGlobal.rules;
  const keys = Object.keys(R.BACKGROUND_TABLES);
  check('all nine tables are present', keys.length === 9, keys.join(', '));

  // A gap or an overlap means some roll silently returns nothing, or two
  // entries claim the same number. Both are transcription errors.
  check('every table covers 01-00 exactly', (() => {
    const bad = [];
    for (const k of keys) {
      const rows = R.BACKGROUND_TABLES[k].rows;
      if (rows[rows.length - 1][0] !== 100) bad.push(`${k} ends at ${rows[rows.length - 1][0]}`);
      if (!rows.every((r, i) => i === 0 || r[0] > rows[i - 1][0])) bad.push(`${k} not ascending`);
      for (let n = 1; n <= 100; n++) if (R.backgroundResult(k, n) == null) { bad.push(`${k} has no entry for ${n}`); break; }
    }
    return bad.length === 0;
  })());

  // Spot-checks against the printed ranges.
  check('birth order reads as printed',
    R.backgroundResult('birth_order', 1) === 'First Born'
    && R.backgroundResult('birth_order', 25) === 'First Born'
    && R.backgroundResult('birth_order', 26) === 'Second Born'
    && R.backgroundResult('birth_order', 100) === 'Illegitimate');
  check('weight reads as printed',
    R.backgroundResult('weight', 31) === 'Average' && R.backgroundResult('weight', 90) === 'Obese; very overweight');
  check('height reads as printed',
    R.backgroundResult('height', 30) === 'Short' && R.backgroundResult('height', 71) === 'Tall');
  check('land of origin reads as printed',
    R.backgroundResult('land_of_origin', 43) === 'Old Kingdom (mountains or lowlands)'
    && R.backgroundResult('land_of_origin', 100) === 'Other world, dimension or time');
  // The book's own oddity: Fourth Born is followed by Sixth Born.
  check('the birth order table keeps the book\'s missing fifth',
    R.backgroundResult('birth_order', 60) === 'Sixth Born');

  check('a roll outside 01-00 returns nothing', (() => (
    R.backgroundResult('age', 0) === null && R.backgroundResult('age', 101) === null
    && R.backgroundResult('age', 'x') === null
  ))());
  check('an unknown table returns nothing',
    R.backgroundResult('favourite_colour', 50) === null && R.rollBackground('favourite_colour') === null);

  // Age is the only numeric table, and the only one the ×2 note touches.
  check('age carries its unit', /years old$/.test(R.rollBackground('age').text));
  check('the long-lived multiplier doubles the years', (() => {
    const real = Math.random;
    Math.random = () => 0.495;            // -> roll 50 -> the 46-60 band -> 24
    try {
      return R.rollBackground('age').text === '24 years old'
        && R.rollBackground('age', { double: true }).text === '48 years old';
    } finally { Math.random = real; }
  })());
  // Doubling a text table would be meaningless, so it must not apply.
  check('the multiplier does nothing to a text table', (() => {
    const real = Math.random;
    Math.random = () => 0.495;
    try {
      return R.rollBackground('disposition', { double: true }).text
        === R.rollBackground('disposition').text;
    } finally { Math.random = real; }
  })());

  check('a roll always lands inside its own table', (() => {
    for (let i = 0; i < 200; i++) {
      for (const k of keys) {
        const r = R.rollBackground(k);
        if (r.roll < 1 || r.roll > 100 || r.text == null) return false;
      }
    }
    return true;
  })());

  // Both pages must offer the four fields the tables added, or a rolled
  // disposition has nowhere to show.
  check('the wizard and the sheet both carry the new fields', (() => {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    return ['birth_order', 'land_of_origin', 'disposition', 'racial_bias']
      .every((k) => app.includes(`'${k}'`) && sheet.includes(`'${k}'`));
  })());
  // The identity block is split into two columns; a fixed split point left one
  // side longer every time the list grew.
  check('the bio columns split evenly on both pages', (() => {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const sheet = readFileSync(appPath('sheet.js'), 'utf8');
    return /BIO_FIELDS\.length \/ 2/.test(app) && /BIO_FIELDS\.length \/ 2/.test(sheet);
  })());
}

// ---------- 1c29. One place composes a class ----------
// Three steps in a fixed order: variant, then race+occupation, then any rolled
// psionics. Six sites used to do this by hand and agreed only by luck; adding
// the psionics step missed one, and the sheet showed a rolled major psychic the
// wrong save target while level-up had it right.
section('Class composition');
{
  const mk = (id, cat, extra) => parseClassMarkdown(
    `---\nid: ${id}\nname: ${id}\nsystem: palladium-fantasy\nsource_book: B\ncategory: ${cat}\n${extra}\n---\n\n## Lore\n\nx\n`).data;

  const dragon = mk('dragon', 'rcc', `mdc_base: "1d4x100"
skills:
  occ_related_skills:
    count: 8
    categories: ["Wilderness"]
variants:
  - { id: hatchling, name: "Dragon Hatchling", mdc_base: "1d4x10" }`);
  const bowman = mk('bowman', 'occ', 'hit_points_base: "P.E. + 1d6 per level"');

  check('nothing in, nothing out', composeClass() === null && composeClass({}) === null);
  check('a race alone composes to itself', (() => {
    const c = composeClass({ rcc: dragon });
    return c.id === 'dragon' && !c.occ_id;
  })());
  check('an occupation alone still resolves',
    composeClass({ occ: bowman })?.id === 'bowman');

  check('the variant is applied', (() => {
    const c = composeClass({ rcc: dragon, character: { class_variant: 'hatchling' } });
    return c.mdc_base === '1d4x10' && c.name === 'Dragon Hatchling';
  })());
  check('race and occupation compose', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman });
    return c.occ_id === 'bowman' && /dragon/i.test(c.name) && /bowman/i.test(c.name);
  })());

  // The step that was missed when it was added.
  check('a rolled psychic tier is folded in', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman, character: { psychic_tier: 'minor' } });
    return c.psionics?.type === 'minor' && c.psionics.from_roll === true;
  })());
  check('no roll leaves psionics alone',
    composeClass({ rcc: dragon, occ: bowman }).psionics === undefined);

  // Order matters: the variant must land before the composition, or a
  // hatchling's M.D.C. would be overwritten by the base class's.
  check('the variant is applied before composing', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman, character: { class_variant: 'hatchling' } });
    return c.mdc_base === '1d4x10';
  })());
  // And the psionics fold must come last, after the O.C.C. has contributed its
  // related-skill count, or a major psychic's halving would hit the wrong number.
  check('psionics fold after composition', (() => {
    const withOcc = mk('scholar', 'occ', 'skills:\n  occ_related_skills:\n    count: 6\n    categories: ["Science"]');
    const c = composeClass({ rcc: dragon, occ: withOcc, character: { psychic_tier: 'major' } });
    // The OCCUPATION supplies related allowances, so composing gives its 6, and
    // the major psionic halves that to 3. Folding psionics first would have
    // halved the dragon's 8 instead and landed on 4.
    return c.skills.occ_related_skills.count === 3;
  })());

  // The whole point: no caller re-implements the sequence. Every page script and
  // every function is in scope — a page that does not compose a class today is
  // exactly the one that will grow the need tomorrow. Only the two files the
  // sequence is BUILT from are exempt: parser.js declares combineClasses and
  // compose.js is the one legitimate caller.
  check('no source file composes a class by hand', (() => {
    const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
      e.isDirectory() ? walk(join(dir, e.name)) : (e.name.endsWith('.js') ? [join(dir, e.name)] : []));
    const exempt = new Set([join(appDir, 'js', 'parser.js'), join(appDir, 'js', 'compose.js')]);
    const files = [
      ...readdirSync(appDir, { withFileTypes: true })
        .filter((e) => e.isFile() && e.name.endsWith('.js'))
        .map((e) => join(appDir, e.name)),
      ...walk(join(appDir, 'js')),
      ...siblingAppDirs.flatMap(walk),
      ...walk(join(appDir, '..', '..', 'functions', 'api', 'character-creator')),
    ].filter((f) => !exempt.has(f));
    const bad = files.filter((f) => readFileSync(f, 'utf8').includes('combineClasses('));
    if (bad.length) console.log('    composing by hand:', bad.join(', '));
    return bad.length === 0;
  })(), 'use composeClass() instead');
}

// ---------- 1c30. The README's counted claims ----------
// Counts written into prose rot silently: nothing breaks, the sentence just
// stops being true. Both of these had already drifted — the JSON-column count
// missed `attribute_bonuses` from migration 016, and a set of page-script line
// counts was out by 20%. Pin the ones that are cheap to pin.
campaignServerChecks();

// ---------- The live level-up grants powers ----------
// buildProposal reported spell and psionic grants and only the wizard acted on
// them. The sheet applies them now, which means banking, a cap that belongs to
// the granting level, and server-side enforcement of both.
section('Several grants at one level');
{
  // The Shifter gains THREE spells a level from two different places, so the
  // level alone stops identifying a grant. Modelled as two entries: two from
  // its named list, one of any kind capped at its own level.
  const shifter = { magic: {
    spells_per_level_from: ['Banishment', 'Charm', 'Teleport: Lesser'],
    spells_per_level_levels: 'up_to_character_level',
    spells_schedule: [
      { level: 2, count: 2, from_list: true, note: 'One must be Protection or Summoning' },
      { level: 2, count: 1, note: 'Not dimension-related or control-based' },
      { level: 3, count: 2, from_list: true },
      { level: 3, count: 1 },
    ] } };

  const g = spellGrantsFor(shifter, 1, 3);
  check('entries sharing a level become separate grants', g.grants.length === 4);
  check('and are told apart by slot',
    JSON.stringify(g.grants.map((x) => [x.level, x.slot])) === '[[2,0],[2,1],[3,0],[3,1]]',
    JSON.stringify(g.grants.map((x) => [x.level, x.slot])));
  check('three spells a level', g.total === 6);

  // `from_list` points at the class list, declared once. Repeating a
  // thirty-four name list on every entry would make one correction fourteen
  // edits.
  check('a from_list slot draws on the class list',
    JSON.stringify(spellNamesForGrant(shifter, 2, 0)) === '["Banishment","Charm","Teleport: Lesser"]');
  check('a slot without it draws on no list', spellNamesForGrant(shifter, 2, 1) === null);

  // A class can have SEVERAL lists. The Ley Line Rifter learns one spell from
  // List A and one from List B at every level, so `from_list` names which.
  const rifter = { magic: { spell_lists: {
      A: ['Dimensional Portal', 'Ley Line Transmission'],
      B: ['Calling', 'Time Slip', 'Locate'] },
    spells_schedule: [
      { level: 2, count: 1, from_list: 'A' },
      { level: 2, count: 1, from_list: 'B' },
    ] } };
  check('a named list is resolved by name',
    JSON.stringify(spellNamesForGrant(rifter, 2, 0)) === '["Dimensional Portal","Ley Line Transmission"]');
  check('and its sibling draws on the other one',
    JSON.stringify(spellNamesForGrant(rifter, 2, 1)) === '["Calling","Time Slip","Locate"]');
  check('a name matching no list restricts nothing rather than everything',
    spellNamesForGrant({ magic: { spell_lists: { A: ['x'] },
      spells_schedule: [{ level: 2, count: 1, from_list: 'Z' }] } }, 2, 0) === null);
  // Both forms coexist: `true` for a class with one list, a name for several.
  check('the single-list form still works',
    JSON.stringify(spellNamesForGrant(shifter, 3, 0)) === '["Banishment","Charm","Teleport: Lesser"]');
  check('a list-bounded slot is not also level-capped',
    spellLevelsForGrant(rifter, 2, 0) === null);

  // A slot bounded by a NAMED LIST is not also bounded by a spell level - the
  // list is the restriction. Only the free slot is capped.
  check('a list slot has no level cap', spellLevelsForGrant(shifter, 2, 0) === null);
  check('the free slot is capped at the character level',
    JSON.stringify(spellLevelsForGrant(shifter, 2, 1)) === '[1,2]');
  check('and the cap widens with the level',
    JSON.stringify(spellLevelsForGrant(shifter, 3, 1)) === '[1,2,3]');

  // A restriction nothing can check is STATED rather than dropped or guessed
  // at. Spells carry no tag, so "Protection or Summoning" has nothing to
  // filter on.
  check('a note rides with the slot that needs it',
    grantNote(shifter, 'spell', 2, 0) === 'One must be Protection or Summoning');
  check('and the other slot has its own',
    grantNote(shifter, 'spell', 2, 1) === 'Not dimension-related or control-based');
  check('a slot with nothing to say says nothing', grantNote(shifter, 'spell', 3, 0) === null);

  // The named list is enforced server-side; the note is not, and cannot be.
  const lib = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    '_lib', 'power-picks.js'), 'utf8');
  check('the server refuses a spell off the list',
    /is not on the list the level \$\{level\} grant draws from/.test(lib));
  check('and keys every grant by slot as well as level',
    /\$\{kind\}:\$\{level\}:\$\{slot \?\? 0\}/.test(lib));
}

section('Power grants');
{
  const llw = { magic: { spells_starting: 12, spell_levels_allowed: [1, 2, 3, 4],
                         spells_per_level: 2, spells_per_level_levels: 'up_to_character_level' } };

  // THE POINT of carrying the cap on the grant. Crossing two levels at once
  // caps each pair by ITS level, not by where the character ended up.
  const twoLevels = powerGrantsFor(llw, 3, 5);
  check('a multi-level jump yields one grant per level', twoLevels.length === 2);
  check('and each carries the cap of the level that earned it',
    JSON.stringify(twoLevels.map((g) => g.spell_levels)) === '[[1,2,3,4],[1,2,3,4,5]]',
    JSON.stringify(twoLevels.map((g) => g.spell_levels)));
  check('every grant says which kind it is', twoLevels.every((g) => g.kind === 'spell'));

  // A class that records no per-level rule grants nothing rather than an
  // unrestricted everything.
  check('an unknown per-level rule grants nothing',
    powerGrantsFor({ magic: { spells_starting: 6 } }, 1, 5).length === 0);
  check('and no magic at all likewise', powerGrantsFor({}, 1, 5).length === 0);

  const psi = powerGrantsFor({ psionics: { type: 'major', powers_per_level: 1 } }, 1, 3);
  check('psionic grants carry no spell cap',
    psi.length === 2 && psi.every((g) => g.kind === 'psionic' && g.spell_levels === null));

  // A level-up psionic grant drawn from a NAMED LIST (BOOK-INGEST-AUDIT F65).
  // perLevelGrants carried the list; powerGrantsFor wrote `from: null` over
  // it, so the claim check, the validator and both sheet pickers saw only the
  // category gate - which refuses every listed Super power the Healing Shaman
  // and Fetish Shaman are granted by name. The list now rides, and replaces
  // the grant's categories, as a starting group's does in startingGroups.
  const listed = powerGrantsFor({ psionics: { type: 'major', categories_allowed: ['Sensitive'],
    powers_schedule: [{ level: 3, count: 1, from: ['Crush'] }, { level: 4, count: 1, categories: ['Healing'] }] } }, 1, 4);
  check('a psionic grant from a named list carries the list',
    JSON.stringify(listed[0]?.from) === '["Crush"]', JSON.stringify(listed));
  check('and drops the category gate the list replaces', listed.length === 2 && listed[0].categories === null);
  check('while a grant with no list keeps its own categories and no list',
    listed[1]?.from == null && JSON.stringify(listed[1]?.categories) === '["Healing"]', JSON.stringify(listed[1]));

  // The two readers that cannot import the grant builder read `from` off the
  // grant: the wizard's Advancement pool and the sheet's two pickers.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  check('the wizard hands a psionic grant\'s list to its pool', /advPsiPool\(cats, g\.from\)/.test(appSrc));
  check('and the pool offers only the list when there is one',
    /function advPsiPool\(cats = null, from = null\)/.test(appSrc));
  // Counted INSIDE each picker. This counted the whole file, and a third reader
  // of `g.from` - talentPoolFor, shared by both pickers for a Talent grant - made
  // the count three while both pickers were still right.
  const between = (a, b) => sheetSrc.slice(sheetSrc.indexOf(a), sheetSrc.indexOf(b, sheetSrc.indexOf(a)));
  const readsList = (body) => /const named = Array\.isArray\(g\.from\) && g\.from\.length/.test(body);
  check('both sheet pickers read a list for psionic grants as well as spells',
    readsList(between('function powerKindBlock(', 'function psiCategoryCap('))
    && readsList(between('function pendingPowersPanel(', 'async function claimPowers(')));

  // Banking consumes per grant, not from one pool. Spending both level-4 spells
  // must not leave the level-5 grant looking half spent.
  const grants = [
    { level: 4, slot: 0, count: 2, kind: 'spell', spell_levels: [1, 2, 3, 4] },
    { level: 5, slot: 0, count: 2, kind: 'spell', spell_levels: [1, 2, 3, 4, 5] },
  ];
  // Keyed by kind, level AND slot — several grants can share a level.
  const left = remainingPowerGrants(grants, new Map([['spell:4:0', 2]]));
  check('a fully spent grant is gone and the other is untouched',
    left.length === 1 && left[0].level === 5 && left[0].count === 2, JSON.stringify(left));
  const partly = remainingPowerGrants(grants, new Map([['spell:4:0', 1], ['spell:5:0', 2]]));
  check('a partly spent grant keeps its remainder',
    partly.length === 1 && partly[0].level === 4 && partly[0].count === 1, JSON.stringify(partly));
  check('and the remainder keeps its cap',
    JSON.stringify(partly[0].spell_levels) === '[1,2,3,4]');
  check('spending nothing banks everything',
    remainingPowerGrants(grants, new Map()).length === 2);
}

section('Power picks are enforced server-side');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const lib = readFileSync(join(apiDir, '_lib', 'power-picks.js'), 'utf8');

  // The picker filters, but a request does not have to come from the picker.
  // Every one of these is a rejection a client could otherwise walk past.
  for (const [what, pattern] of [
    ['a grant that does not exist', /has no \$\{what\} grant from level/],
    ['a grant with no room', /is already full/],
    ['a power already known', /already known/],
    ['a name not in the catalog', /is not in the \$\{isTalent \? 'talent' : kind\} catalog/],
    ['a spell above the grant cap', /is a level \$\{row\.level\} spell/],
    ['a power outside the grant categories', /power; the level \$\{level\} grant allows/],
  ]) {
    check(`the server refuses ${what}`, pattern.test(lib), what);
  }

  // The cap comes from the GRANT, not from recomputing against the class: a
  // re-import between banking and spending must not change what a character was
  // granted at level 4.
  const claim = readFileSync(join(apiDir, 'characters', '[id]', 'power-picks.js'), 'utf8');
  check('the claim path spends against the banked grants',
    /spell_levels: g\.spell_levels/.test(claim));
  check('including the banked categories',
    /categories: g\.categories/.test(claim));
  check('and does not recompute them from the class',
    !/spellLevelsForGrant/.test(claim));
  check('the power write and the grant consume are one batch',
    /DB\.batch\(statements\)/.test(claim));

  // loadCharacter does not join campaigns. Reading character.campaign_system
  // yields undefined, the system filter becomes a no-op, and a Rifts caster can
  // learn a Palladium-only spell.
  const confirm = readFileSync(join(apiDir, 'characters', '[id]', 'level-confirm.js'), 'utf8');
  check('the level-up fetches the campaign system rather than assuming the character carries it',
    /SELECT system FROM campaigns WHERE id = \?/.test(confirm));
  check('and no path reads a campaign_system that loadCharacter never selected',
    !/character\.campaign_system/.test(confirm));

  // An empty list is what a swallowed error looks like.
  check('listPendingPowers does not swallow query failures',
    !/\.all\(\)\.catch\(/.test(lib));

  const sheet = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet sends the power picks with the level-up', /power_picks,/.test(sheet));
  check('and offers the banked ones afterwards', /claimPowers/.test(sheet));
}

documentedCountsChecks();

classCheckToolChecks();
classTagChecks();

bookRegistryChecks();

// ---------- 1e-ter. The backend class extractor ----------
//
// scripts/extract-class.mjs replaces the in-app importer's extraction half.
// These pin the things about it that are load-bearing and would break
// silently: the art-page threshold, the cached-text prompt, the metering, and
// the fact that it drafts rather than publishes.
section('Backend class extractor');
{
  const src = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');

  // THE THRESHOLD IS THE WHOLE POINT OF THE GUARD. Wormwood p056 is 14 bytes
  // trimmed and p058 is 8; the smallest page in that book that is REAL text is
  // p074 at 744, the Hospitaller's code of chivalry set in one sparse column. A
  // threshold at or above 744 refuses a real page; one at or below 14 waves the
  // art through, which is how the Apok loses a third of itself.
  const m = src.match(/const ART_PAGE_BYTES = (\d+);/);
  check('the extractor states an art-page threshold', !!m);
  const artBytes = m ? Number(m[1]) : null;
  check('and it sits between the largest art page and the smallest real one',
    artBytes !== null && artBytes > 14 && artBytes < 744, String(artBytes));

  // The guard has to REFUSE by default. A version that warned and carried on
  // would read the same in a diff and catch nothing.
  check('a short page stops the run rather than warning',
    src.includes('REFUSING') && src.includes('process.exit(1)'));
  check('and there is an explicit escape hatch for the rare real case',
    src.includes('--allow-short'));

  // execFileSync with shell:true does not quote the arguments it joins - the
  // SQL loses its spaces and wrangler reports twenty unknown arguments. This
  // script hit that on its first run; d1Query is the one that gets it right.
  // Checked on the IMPORT rather than the word, because the header explains
  // the trap by name and a substring test would match the explanation.
  check('the extractor queries D1 through the repo helper, not its own spawn',
    src.includes('d1Query') && !/from 'node:child_process'/.test(src));

  // A truncated reply that parses is worse than an error, because it gets
  // reviewed as though it were a whole class.
  check('a max_tokens stop is treated as a failure, not a result',
    src.includes('max_tokens') && src.includes('only partly read'));

  // F7 shipped metering so the cost of a book is a query rather than an
  // estimate. Moving extraction off the metered route would quietly undo it.
  check('the extractor meters its call to claude_usage',
    src.includes('claude_usage') && src.includes('cc-extract-class'));

  // It drafts. It must not be able to publish.
  check('the extractor writes no catalog row and no class row',
    !/INSERT\s+(OR\s+\w+\s+)?INTO\s+(imported_classes|gear|skills|spells|psionic_powers)/i.test(src));

  // The cached-text prompt must not tell the model to un-splice columns that
  // read-columns.py already resolved, and must not claim a PDF is attached.
  // There is ONE prompt now. The PDF one went with the routes that sent PDFs,
  // and the "no export is named nowhere else" check is what noticed.
  const cachePrompt = buildUserPrompt([{ name: 'X', text: 'md' }], null);
  check('the prompt does not claim an attached PDF',
    !cachePrompt.includes('attached PDF'));
  check('the cached-text system prompt says the columns are already resolved',
    SYSTEM_PROMPT_CACHE.includes('already extracted')
    && SYSTEM_PROMPT_CACHE.includes('DO NOT try to re-order'));
  check('and warns that a stat block continues across a page break',
    SYSTEM_PROMPT_CACHE.includes('CONTINUES at the top of the next'));
}

// ---------- 1f. Skill bonuses ----------
// A skill is not only a percentage: Boxing is +1 attack per melee and +2 P.S.
// The column stores them in a class's `bonuses:` shape and shares its
// validator, so a skill cannot express a bonus a class could not.
section('Skill bonuses');

const boxing = { name: 'Boxing', bonuses: { attributes: { PS: 2 }, combat: { attacks: 1, parry: 2, dodge: 2, roll: 1 } } };
const bodyBuilding = { name: 'Body Building', bonuses: { attributes: { PS: 2 } } };

check('a skill with no bonuses contributes nothing',
  bonusesFromSkills([{ name: 'Prowl' }, { name: 'Climbing', bonuses: null }]) === undefined);

check('bonuses arrive as stored JSON or as an object', (() => {
  const a = bonusesFromSkills([boxing]);
  const b = bonusesFromSkills([{ name: 'Boxing', bonuses: JSON.stringify(boxing.bonuses) }]);
  return a.attributes.PS === 2 && b.attributes.PS === 2 && b.combat.attacks === 1;
})());

// Two skills granting the same attribute add up. They used to be unable to
// grant anything at all, so "one silently wins" would be a new bug, not a
// preserved one.
check('two skills granting the same attribute add up',
  bonusesFromSkills([boxing, bodyBuilding]).attributes.PS === 4);

check('unparseable stored JSON is skipped, not thrown',
  bonusesFromSkills([{ name: 'Boxing', bonuses: '{not json' }, bodyBuilding]).attributes.PS === 2);

// `combat` is an open set by design, so `roll` needs no schema change.
check('an open-set combat key survives the round trip',
  bonusesFromSkills([boxing]).combat.roll === 1);

// --- validation: a skill goes through the class validator, in flat-only mode
const vErr = (b, opts) => { const e = []; validateBonuses(b, e, [], opts); return e; };

check('a flat skill bonus validates',
  vErr({ attributes: { PS: 2 }, combat: { attacks: 1 } }, { flatOnly: true }).length === 0);

// A class may roll dice for a bonus because it rolls once at creation and
// stores the result. A skill has no such moment, so accepting dice would store
// Boxing's +3D6 S.D.C. and never apply it.
check('a dice bonus is refused for a skill but allowed for a class',
  vErr({ attributes: { PS: '2d6' } }, { flatOnly: true }).length === 1
  && vErr({ attributes: { PS: '2d6' } }, {}).length === 0);

check('pools are refused for a skill',
  vErr({ pools: { sdc: 10 } }, { flatOnly: true }).length === 1);

check('at_level is refused for a skill', vErr({ at_level: [{ level: 2 }] }, { flatOnly: true }).length === 1);

check('a skill still cannot invent an attribute',
  vErr({ attributes: { LUCK: 2 } }, { flatOnly: true }).some((e) => e.includes('is not an attribute')));

// --- the catalog field coerces through that same validator
const coerceBonus = (raw) => coerceField(
  CATALOGS.skills.fields.find((f) => f.name === 'bonuses'), raw);

check('the catalog field stores valid bonuses as JSON',
  coerceBonus({ attributes: { PS: 2 } }).value === '{"attributes":{"PS":2}}');
check('the catalog field rejects a dice bonus',
  !!coerceBonus({ attributes: { PS: '2d6' } }).error);
check('blank bonuses store NULL, not an empty object',
  coerceBonus('').value === null && coerceBonus(null).value === null);
check('malformed JSON is an error, not a silent null',
  !!coerceBonus('{nope').error);

// --- composeClass folds them in, and only when told about them
const plainOcc = parseClassMarkdown(classTemplate('occ',
  { id: 'boxer', name: 'Boxer', system: 'rifts', sourceBook: 'B' })).data;

check('null skillRows leaves the composed class untouched', (() => {
  const c = composeClass({ rcc: plainOcc });
  return c.bonuses === undefined || c.bonuses?.attributes?.PS === undefined;
})());

check('skill bonuses reach the composed class', (() => {
  const c = composeClass({ rcc: plainOcc, skillRows: [boxing] });
  return c.bonuses.attributes.PS === 2 && c.bonuses.combat.attacks === 1;
})());

// The reason to merge with sumBonusGroups rather than assign: a class and a
// skill both granting +2 P.S. is +4.
check('a class bonus and a skill bonus add rather than replace', (() => {
  const withPs = { ...plainOcc, bonuses: { attributes: { PS: 2 } } };
  return composeClass({ rcc: withPs, skillRows: [boxing] }).bonuses.attributes.PS === 4;
})());

// derive.js needs no new cases: the folded block is an ordinary class bonuses
// block, so classBonuses() reads it exactly as it reads a class's own.
check('derive reads a skill bonus as an ordinary class bonus', (() => {
  const c = composeClass({ rcc: plainOcc, skillRows: [boxing] });
  const b = D.classBonuses(c, 1, null);
  return b.attributes.PS === 2 && b.combat.attacks === 1 && b.combat.roll === 1;
})());

// ---------- 1g. Cross-category restrictions ----------
// The catalog files a skill under exactly one category; the books file it under
// whichever category a class spends its pick from. "Espionage: Wilderness
// Survival only" is an ordinary book line about a Wilderness skill, and
// filtering by the catalog's category first made that name match nothing.
section('Cross-category restrictions');

const ccCats = [
  { name: 'Espionage', only: ['Detect Ambush', 'Wilderness Survival'] },
  { name: 'Physical', except: ['Acrobatics'] },
  { name: 'Communications', except: ['Read Sensory Equipment'] },
  // Wilderness is granted but RESTRICTED, and its own list does not carry
  // Wilderness Survival. So the cross-category rule is what admits the skill,
  // not this entry - which is the Elemental Fusionist's exact shape.
  { name: 'Wilderness', only: ['Hunting'] },
  'Technical',
];
const allows = (name, category) => categoryAllows(ccCats, { name, category });

// The whole point: named in an `only` list, filed elsewhere by the catalog.
check('an only-list grants a skill from another category',
  allows('Wilderness Survival', 'Wilderness'));

// Everything that worked before must still work exactly as it did.
check('an only-list still grants a skill from its own category',
  allows('Detect Ambush', 'Espionage'));
check('an only-list still refuses a skill it does not name',
  !allows('Tracking', 'Espionage'));
check('an except-list still refuses what it excludes',
  !allows('Acrobatics', 'Physical'));
check('an except-list still admits what it does not exclude',
  allows('Prowl', 'Physical'));
check('a bare category string still admits everything in it',
  allows('Art', 'Technical'));
check('a category the class does not grant is still refused',
  !allows('Brewing', 'Medical'));

// An `except` naming a skill from another category stays a no-op. There is
// nothing to exclude: the skill was never offered in that category. Making it
// grant would be the opposite of what an except list is for.
check('an except-list does NOT grant a skill from another category',
  !allows('Read Sensory Equipment', 'Pilot Related'));

// An empty or absent list restricts nothing, unchanged.
check('no categories at all still allows anything',
  categoryAllows([], { name: 'X', category: 'Y' }) && categoryAllows(null, { name: 'X', category: 'Y' }));

// The bound: the class must also LIST the skill's real category. Without it an
// only-list would reach a skill from a category the class never granted, which
// is wider than any book says.
check('a cross-category grant needs the real category to be listed too',
  !categoryAllows([{ name: 'Espionage', only: ['Wilderness Survival'] }],
    { name: 'Wilderness Survival', category: 'Wilderness' }));

// "Lists it" is NOT "that category's own restriction admits it". Both Elemental
// Fusionists grant Technical with an only-list that does not carry Writing, and
// name Writing under Communications instead; requiring both would refuse the
// very skill this exists to reach.
check('the real category may itself be restricted', categoryAllows(
  [{ name: 'Communications', only: ['Writing'] }, { name: 'Technical', only: ['Art'] }],
  { name: 'Writing', category: 'Technical' }));

// --- the reporting half, which is what makes this visible in class-check
// It walks the class data itself so the bound is checked against the SAME
// skill group the restriction came from.
const ccMap = new Map([
  ['wilderness survival', 'Wilderness'],
  ['detect ambush', 'Espionage'],
  ['read sensory equipment', 'Pilot Related'],
  ['writing', 'Technical'],
]);
const ccData = (categories) => ({ skills: { occ_related_skills: { categories } } });

// Granted: the class lists Wilderness too, so categoryAllows admits it.
const ccGranted = crossCategoryRestrictions(ccData([
  { name: 'Espionage', only: ['Wilderness Survival', 'Detect Ambush'] },
  { name: 'Wilderness', only: ['Hunting'] },
]), ccMap);
check('a cross-category only whose real category is listed reports as granted',
  ccGranted.granted.length === 1 && ccGranted.granted[0].name === 'Wilderness Survival'
  && ccGranted.unreachable.length === 0);
check('a name in its own category is not reported',
  !ccGranted.granted.some((g) => g.name === 'Detect Ambush'));

// The defect the checker used to call a success: the class grants a skill
// nobody can take, because categoryAllows is bounded by the real category.
const ccLost = crossCategoryRestrictions(ccData([
  { name: 'Espionage', only: ['Wilderness Survival'] },
]), ccMap);
check('a cross-category only with no real category reports as unreachable',
  ccLost.unreachable.length === 1 && ccLost.granted.length === 0);

// The bound is per skill group: a category granted only to secondary skills
// does not make an occ_related_skills restriction reachable.
check('the bound is checked within the same skill group', crossCategoryRestrictions({
  skills: {
    occ_related_skills: { categories: [{ name: 'Espionage', only: ['Wilderness Survival'] }] },
    secondary_skills: { categories: ['Wilderness'] },
  },
}, ccMap).unreachable.length === 1);

check('a cross-category except is reported as a no-op', crossCategoryRestrictions(ccData([
  { name: 'Communications', except: ['Read Sensory Equipment'] },
]), ccMap).noop.length === 1);

// A name with no row at all belongs to the missing-row check, not this one.
check('a name with no catalog row is left to the missing-row check',
  (() => {
    const r = crossCategoryRestrictions(ccData([{ name: 'Rogue', except: ['Nothing At All'] }]), ccMap);
    return r.granted.length === 0 && r.unreachable.length === 0 && r.noop.length === 0;
  })());

// ---------- 1h. Bonus attribution ----------
// Once skills fold into the same bonuses block, "+1 attack from the class" is
// wrong whenever the attack is Boxing's. derive.parts splits the two so the
// sheet can name the real source.
section('Bonus attribution');

const baStats = { IQ: 12, ME: 12, MA: 12, PS: 12, PP: 12, PE: 12, PB: 12, Spd: 12 };
const baClass = { attributes: {}, combat: { attacks: 1 }, saves: {} };
const baBoth  = { attributes: {}, combat: { attacks: 3 }, saves: {} };

// Omitting the class-only block keeps the old behaviour exactly: every caller
// before skills could grant anything passed four arguments.
check('without a class-only block everything is from_class', (() => {
  const p = D.parts('combat', baStats, baBoth);
  return p.attacks.from_class === 3 && p.attacks.from_skills === 0;
})());

check('with one, the class and skill halves are separated', (() => {
  const p = D.parts('combat', baStats, baBoth, undefined, baClass);
  return p.attacks.from_class === 1 && p.attacks.from_skills === 2;
})());

check('a bonus entirely from skills reports no class half', (() => {
  const p = D.parts('combat', baStats, baBoth, undefined,
    { attributes: {}, combat: {}, saves: {} });
  return p.attacks.from_class === 0 && p.attacks.from_skills === 3;
})());

// An attribute bonus reaches combat through the tables, not directly, so the
// split has to survive that route too.
check('an attribute-driven bonus is attributed correctly', (() => {
  const cls = { attributes: { PP: 6 }, combat: {}, saves: {} };
  const both = { attributes: { PP: 12 }, combat: {}, saves: {} };
  const p = D.parts('combat', baStats, both, undefined, cls);
  return p.parry.from_class > 0 && p.parry.from_skills > 0
    && p.parry.from_class + p.parry.from_skills
       === D.parts('combat', baStats, both).parry.from_class;
})());

check('saves split the same way', (() => {
  const p = D.parts('saves', baStats,
    { attributes: {}, combat: {}, saves: { spell_magic: 4 } }, null,
    { attributes: {}, combat: {}, saves: { spell_magic: 1 } });
  return p.spell_magic.from_class === 1 && p.spell_magic.from_skills === 3;
})());


// ---------- The Race briefing names every bonus group ----------
// The briefing exists so a player sees what a class grants BEFORE committing to
// it, and it listed attributes, combat and saves but not POOLS. A pool bonus
// does not show in the briefing's `Pools` line either, because that line prints
// the FORMULA and a class that adds to another's roll states no formula - so
// the Troll's +40 S.D.C., its single most distinctive number, appeared nowhere.
// Fifteen classes published before the races grant one, so it was never only a
// race problem.
section('Race briefing');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  const fn = src.slice(src.indexOf('function raceBriefing()'));
  const body = fn.slice(0, fn.indexOf('\n}\n'));
  for (const group of ['attributes', 'pools', 'combat', 'saves']) {
    check(`the briefing reads bonuses.${group}`,
      new RegExp(`b\\.${group} \\|\\| \\{\\}`).test(body),
      `bonuses.${group} is granted by real classes and the briefing never prints it`);
  }
  // Every group derive.js can act on, so adding one to the parser without
  // adding it here fails rather than showing the player nothing.
  check('and that is every group a class bonus can name',
    /BONUS_GROUPS/.test(readFileSync(join(appDir, 'js', 'parser.js'), 'utf8')));
  check('pool keys are labelled, not printed raw',
    /POOL_LABELS_SHORT/.test(body), 'a bonus would read "sdc +40" rather than "S.D.C. +40"');
}


catalogMatchingChecks();

// The environment half lives in its own file; it runs last because it is the
section('A class cannot write a bonus the sheet will not draw');
{
  // `bonuses.combat` and `bonuses.saves` are open at the VALIDATOR - group
  // names are checked, the keys inside them are not, and derive.js's addBonus
  // adds any finite number under any key. They are CLOSED at the sheet, which
  // draws SAVE_FIELDS and COMBAT_FIELDS as literal lists. So an invented or
  // misspelled key parses, validates, composes, and renders NOWHERE.
  //
  // The two checks above start from derive*() output, so neither can see a key
  // a CLASS writes - a class-authored key is never in the derived set.
  // vacuum-wasp's own extraction_notes is the only place this was written
  // down: "combat: { dogfighting: 2 } would parse, validate and render
  // NOWHERE". SKILL-AUDIT F23.
  //
  // Parsed through the REAL parser, not a regex over the SQL. A naive inline
  // `{ }` match reads that very note's prose as data and reports a key that
  // is not there - which is what happened while F1 was being taken, and is
  // CLASS-AUDIT F17's shape.
  //
  // The lists and the walk are scripts/class-check-lib.mjs's since 2026-10-10,
  // shared with class-check, which now warns about the same key before the
  // script is written. Until then this suite was the first to say so.
  const drawable = sheetDrawableKeys(readFileSync(appPath('sheet.js'), 'utf8'));
  check('the sheet\'s two field lists are found',
    drawable.combat.size > 5 && drawable.saves.size > 10,
    `${drawable.combat.size} combat, ${drawable.saves.size} saves`);

  // The predicate on its own, against a class that gets every place wrong.
  const wrong = undrawnBonusKeys({
    bonuses: { combat: { strike: 1, dogfighting: 2 }, saves: { spell_magic: 1, other: [] },
      at_level: [{ level: 3, saves: { horor_factor: 1 } }] },
    variants: [{ id: 'adult', bonuses: { combat: { parry: 1, parrry: 1 } } }],
    second_form: { bonuses: { saves: { poisen: 2 } } },
  }, drawable);
  check('a key the sheet does not draw is named by its path, wherever it was written',
    wrong.join() === ['bonuses.combat.dogfighting', 'bonuses.at_level[0].saves.horor_factor',
      'variants.adult.bonuses.combat.parrry', 'second_form.bonuses.saves.poisen'].join(),
    wrong.join(', '));
  check('and a class with none, or with no bonuses at all, names nothing',
    undrawnBonusKeys({ bonuses: { combat: { strike: 1, attacks_base: 4 }, saves: { psionics_target: 10 } } }, drawable).length === 0
    && undrawnBonusKeys({}, drawable).length === 0 && undrawnBonusKeys(null, drawable).length === 0);

  // EVERY script a whole class can be read out of, not only the ones named
  // add-*-class.sql. On 2026-10-10 that filter read 760 of 761: it missed
  // `~120-coalition-military-specialist-class.sql`, and would miss any class
  // restated by a script under another name.
  const offenders = [];
  let parsed = 0;
  let outsideTheOldFilter = 0;
  for (const f of readdirSync(join(appDir, 'db')).filter((n) => n.endsWith('.sql'))) {
    let md = null;
    try { md = extractClassMarkdown(readFileSync(join(appDir, 'db', f), 'utf8')); } catch { md = null; }
    if (!md) continue;
    const res = parseClassMarkdown(md);
    if (!res?.ok || !res.data) continue;
    parsed++;
    if (!/^add-.*-class\.sql$/.test(f)) outsideTheOldFilter++;
    for (const path of undrawnBonusKeys(res.data, drawable)) offenders.push(`${f}: ${path}`);
  }

  check('every script that writes a class was parsed', parsed > 100, `only ${parsed}`);
  check('including the ones not named add-*-class.sql', outsideTheOldFilter > 0, String(outsideTheOldFilter));
  check('no class writes a combat or save key the sheet cannot draw',
    offenders.length === 0,
    `${offenders.join('; ')} - add it to COMBAT_FIELDS/SAVE_FIELDS in sheet.js, or use saves.other / a special_ability`);

  // And class-check says it at authoring time, as a warning that moves no
  // exit code - run for real, on a draft with one misspelled save.
  {
    const draft = join(process.env.TEMP || process.env.TMPDIR || '/tmp', `smoke-undrawn-${process.pid}.md`);
    writeFileSync(draft, ['---', 'id: undrawn-probe', 'name: Undrawn Probe', 'system: rifts',
      'source_book: "Probe"', 'category: occ', 'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"',
      'bonuses:', '  saves: { horor_factor: 2 }', '---', '', '## Lore', '', 'x', ''].join('\n'));
    const run = spawnSync(process.execPath, [join(repoRoot, 'scripts', 'class-check.mjs'), draft, '--no-catalog'],
      { encoding: 'utf8', cwd: repoRoot });
    rmSync(draft, { force: true });
    const out = `${run.stdout || ''}${run.stderr || ''}`;
    check('class-check warns about an undrawn key, by path',
      /bonus key\(s\) the sheet has no field for - bonuses\.saves\.horor_factor/.test(out),
      out.slice(0, 300));
    check('and does not fail the run for it', run.status === 0, `exit ${run.status}`);
  }
}

// ---------- The checks modules declare the sections they run ----------
// Each module under test/checks/ opens run() with
// `if (!SECTIONS.some(wantSection)) return;` so a --section run can skip the
// whole module without reading it (harness.mjs; EFFICIENCY-AUDIT F2). That
// list is typed by hand, and a section() call the list does not carry is
// unreachable by name: the gate returns before the section is announced, and
// the run ends in "no section matched", which reads as a typo in the filter.
// rendered-ui.mjs carried two such names on 2026-09-17 - 'The codex' and 'The
// sheet reads only item fields its endpoint sends' - and the only way to run
// either was to pair it with a declared one. The flagless run never consults
// the gate, so nothing failed. Both directions are read out of each file's
// own text here: a call the list lacks, and a listed name no call announces.
// A call whose name is not a plain string literal fails too, because it is
// one this reader cannot see and the next drift would hide behind it.
section('The checks modules declare the sections they run');
{
  const checksDir = join(appDir, 'test', 'checks');
  const modules = readdirSync(checksDir).filter((f) => f.endsWith('.mjs')).sort();
  check('there are checks modules to read', modules.length > 0);
  const literal = /(['"])((?:(?!\1)[^\\]|\\.)*)\1/g;
  for (const f of modules) {
    const src = readFileSync(join(checksDir, f), 'utf8');
    const called = [...src.matchAll(/^[ \t]*section\(\s*(['"])((?:(?!\1)[^\\]|\\.)*)\1\s*\)/gm)].map((m) => m[2]);
    // ANCHORED TO STATEMENT POSITION, both sides, and that is the whole fix.
    // `every` used to be a bare `\bsection\(` over the file, which counts the
    // words in a COMMENT too: a comment in checks/second-body.mjs describing
    // how announcements are declared read as a fifth call that no literal
    // could be parsed out of, and failed the suite (#1217). A comment line
    // begins with `//`, so it cannot match `^[ \t]*section\(` - no comment
    // stripper needed, and writing one is how the other three attempts at
    // this class of problem went wrong.
    //
    // What it gives up: a call that is not the first thing on its line, such
    // as `if (x) section('y');`. There are none, the shape is worth
    // discouraging anyway, and one that appeared would be reported as a
    // DECLARED name nothing announces by the two checks below - so it fails
    // loudly rather than slipping past.
    const every = (src.match(/^[ \t]*section\(/gm) || []).length;
    check(`${f}: every section() call names its section with a string literal`,
      called.length === every, `${every} calls, ${called.length} readable`);
    if (every === 0) continue;
    check(`${f} gates run() on its declared list`, src.includes('SECTIONS.some(wantSection)'));
    const decl = src.match(/const SECTIONS = \[([\s\S]*?)\];/);
    check(`${f} declares SECTIONS`, !!decl);
    if (!decl) continue;
    const declared = [...decl[1].matchAll(literal)].map((m) => m[2]);
    const missing = called.filter((c) => !declared.includes(c));
    const stale = declared.filter((d) => !called.includes(d));
    check(`${f}: every section it announces is in its declared list`,
      missing.length === 0, missing.map((s) => `'${s}'`).join(', '));
    check(`${f}: every declared name is announced by a section() call`,
      stale.length === 0, stale.map((s) => `'${s}'`).join(', '));
    check(`${f} declares no name twice`, new Set(declared).size === declared.length);
  }
}

instructionPathChecks();
machineInstructionChecks();
hookRegistrationChecks();
namegenChecks();
cityCreatorChecks();
auditMenuChecks();
sequenceNumberChecks();
sourcebookChecks();

// slow one - it shells out to wrangler.
environmentChecks();
catalogDataChecks();

process.exit(summary() === 0 ? 0 : 1);
