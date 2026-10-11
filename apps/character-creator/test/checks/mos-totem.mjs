// A package a class adds on top of what every member already has: the
// Military Occupational Specialty, choosing more than one of them, and the
// totem animal, which is the same shape under another name.
//
// Three sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. `validateMos`, `validateTotem`, `mosList`,
// `CHARACTER_JSON_COLUMNS`, `expressionDepth` and `D1_MAX_EXPR_DEPTH` are
// used here and nowhere else in the suite.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { CHARACTER_JSON_COLUMNS } from '../../../../functions/api/character-creator/_lib/character-json.js';
import { validateCharacter } from '../../../../functions/api/character-creator/_lib/validate-character.js';
import { statements, expressionDepth, D1_MAX_EXPR_DEPTH } from '../../../../scripts/sql-statements.mjs';
import { CATALOGS, coerceField } from '../../js/catalog-fields.js';
import { composeClass } from '../../js/compose.js';
import { validateMos, validateTotem, mosList, categoryLabel, parseClassMarkdown } from '../../js/parser.js';
import { freshState, freshBuild } from '../../js/wizard-state.js';
import { appDir, repoRoot, check, section, appPath, wantSection } from '../harness.mjs';

const SECTIONS = ['MOS', 'MOS: choose more than one', 'Totem animals (BOOK-INGEST-AUDIT F56)'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- Military Occupational Specialty ----------
// RUE gives several classes an MOS: "select one area of specialty, gain all
// skills under that MOS" (Coalition Technical Officer p236, Robot Pilot p84).
//
// It is NOT a variant, and that is the whole reason it needed modelling. A
// variant REPLACES what the class says, and VARIANT_OVERRIDES excludes the
// skills block on purpose - `skill_overrides` restating a number is a much
// smaller power than swapping a skill list. An MOS ADDS a package on top of the
// O.C.C. skills every member of the class already has: the book says "plus the
// MOS skills chosen previously".
section('MOS');
{
  const mk = (extra = '') => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'skills:',
    '  occ_skills:',
    '    - { name: "Basic Math", base: 60, per_level: 5 }',
    '  mos:',
    '    choose: 1',
    '    options:',
    '      - id: "comms"',
    '        name: "Communications MOS"',
    '        skills:',
    '          - { name: "Radio: Basic", base: 70, per_level: 5 }',
    '      - id: "medic"',
    '        name: "Medic MOS"',
    '        skills:',
    '          - { name: "Paramedic", base: 55, per_level: 5 }',
    extra,
    '---', '', '## Lore', '', 'x', ''].filter((l) => l !== '').join(String.fromCharCode(10)));

  const parsed = mk();
  check('a class can declare an MOS', parsed.errors.length === 0, parsed.errors.join('; '));
  check('and its options parse', parsed.data.skills.mos.options.length === 2);

  // Which classes have one, and how many packages each offers. Pinned because
  // BOTH written records of it were wrong at once: parser.js said the Technical
  // Officer offered five where it offers seven, and the README said the Robot
  // Pilot offered two where it had none at all - it carried its packages as GM
  // prose and a note claiming the schema could not hold them, which it could.
  // A count in a comment is exactly the kind of claim that goes stale silently.
  {
    const dbDir = join(appDir, 'db');
    const files = readdirSync(dbDir).filter((f) => f.endsWith('.sql')).sort();
    const read = (f) => readFileSync(join(dbDir, f), 'utf8');

    // Three classes have an MOS, and the two newest got theirs by correction
    // rather than at import. That some script gives each one an MOS is all a
    // FILE can honestly answer; how many packages each ends up with is a
    // question about the composed class, and lives in regression.mjs, which
    // has a database to ask.
    for (const id of ['coalition-technical-officer', 'merc-soldier', 'robot-pilot']) {
      const owning = files.filter((f) => read(f).includes(`'${id}'`) && / {2}mos:/.test(read(f)));
      check(`${id} gets its MOS from a data script`, owning.length > 0, id);
    }

    // The stale notes are STILL in add-merc-soldier-class.sql and
    // add-robot-pilot-class.sql, and must be: an applied one-shot script is
    // never edited. What has to be true is that a LATER-sorting script removes
    // them, which is the same shape every other correction here takes.
    for (const stale of ['schema cannot express (see', 'not modeled; add them by hand']) {
      const carriers = files.filter((f) => read(f).includes(stale) && !read(f).includes(`replace(markdown,`));
      const fixers = files.filter((f) => read(f).includes(stale) && read(f).includes('replace(markdown,'));
      check(`the note "${stale.slice(0, 24)}..." is undone by a later script`,
        fixers.length > 0 && carriers.every((c) => fixers.some((f) => f > c)),
        `carried by ${carriers.join(', ')}; fixed by ${fixers.join(', ') || 'NOTHING'}`);
    }

    const srcParser = readFileSync(join(appDir, 'js', 'parser.js'), 'utf8');
    // The MOS chapter moved to docs/race-and-occupation.md with the README split.
    const mosDoc = readFileSync(join(appDir, 'docs', 'race-and-occupation.md'), 'utf8');
    check('docs/race-and-occupation.md states who has an MOS and how many packages',
      /Technical Officer\s+offers seven, the Merc Soldier seven and the\s+Robot Pilot two/
        .test(mosDoc.replace(/\r/g, '')));
    check('and parser.js agrees with it',
      /Technical Officer offers seven, the Merc Soldier seven and the/.test(srcParser.replace(/\r/g, '')));

    // ── NO DATA SCRIPT MAY KEY ON A LITERAL CATALOG id ──
    //
    // Catalog ids are `INTEGER PRIMARY KEY AUTOINCREMENT`, so they are
    // INSERTION ORDER, and insertion order differs between environments.
    // Measured against a database rebuilt from this repo on 2026-09-05:
    //
    //   gear             0 of 1025 ids matched production
    //   skills           1 of 345
    //   spells          56 of 607
    //   psionic_powers  20 of 116
    //
    // So `WHERE id = 283` picks Fire: Fire Gout in production and Earth: Track
    // in a local or rebuilt database. A script written that way puts the right
    // data on the wrong rows ANYWHERE but the database it was generated
    // against, and it does it silently - there is no error, just wrong rows.
    // That happened here while writing the Book of Magic backfill; the readback
    // caught it only because it counted the whole corpus rather than the rows
    // the script itself had touched.
    //
    // THE NATURAL KEY ALREADY EXISTS AND IS ALREADY UNIQUE - `name` on skills,
    // spells and psionic_powers, `slug` on gear - so keying on it costs
    // nothing.
    //
    // A JOIN ON AN id IS FINE and must stay fine: a join between two id columns
    // is a relation inside one database and says nothing about which database.
    // Only a literal NUMBER is refused.
    //
    // Eight data scripts used to join `gear.id = character_items.item_id`. None
    // does now - migration 046 dropped that column and the ten scripts touching
    // it were rewritten onto the slug - so the negative case below is a string
    // literal rather than anything the corpus still contains. That is why it is
    // written out here: the guard must keep permitting the shape even once
    // nothing in the tree uses it, or the next legitimate id join goes red.
    //
    // Asserted over the WHOLE corpus rather than over the lines a branch adds,
    // because the corpus is at zero and an invariant that is already true is
    // the cheap kind to keep.
    const CATALOG = 'spells|skills|psionic_powers|gear|enchantments';
    const LITERAL_ID = new RegExp(
      `(?:UPDATE|DELETE\\s+FROM)\\s+(?:${CATALOG})\\b[\\s\\S]{0,400}?`
      + `WHERE[\\s\\S]{0,120}?\\bid\\s*(?:=|IN\\s*\\()\\s*\\d`, 'i');
    const idKeyed = files.filter((f) => LITERAL_ID.test(read(f)));
    check('no data script keys a catalog write on a literal id',
      idKeyed.length === 0,
      `${idKeyed.join(', ')} - ids are insertion order and differ per environment; `
      + 'key on name (or slug, for gear)');

    // And the check is not vacuous: the pattern it looks for really does match
    // the shape it forbids. Without this, a regex that never matched anything
    // would pass forever and prove nothing - the failure R16 was filed for.
    check('and the guard matches the shape it forbids',
      LITERAL_ID.test("UPDATE spells SET description = 'x' WHERE id = 283;")
      && LITERAL_ID.test('DELETE FROM gear WHERE id IN (1, 2);'));
    check('while leaving an id JOIN alone',
      !LITERAL_ID.test('UPDATE character_items SET custom_name = '
        + '(SELECT name FROM gear WHERE gear.id = character_items.item_id);'));

    // D1 refuses an expression tree deeper than 100, and only when a statement
    // reaches it. BOOK-INGEST-AUDIT F59's first script wrote a 70-line block as
    // 'a' || char(10) || 'b' || ... and failed at apply time. d1-apply's
    // pre-flight now refuses such a file first; this keeps the corpus clean and
    // pins the estimate to what D1 was measured to do.
    const deepest = files.flatMap((f) => statements(read(f)).map((s) => [expressionDepth(s), f]))
      .sort((a, b) => b[0] - a[0])[0] || [0, ''];
    check(`no data script nests an expression past D1's limit (deepest ${deepest[0]}, ${deepest[1]})`,
      deepest[0] <= D1_MAX_EXPR_DEPTH);
    const chainOf = (n) => 'SELECT length(' + Array.from({ length: n + 1 }, () => "'a'").join(' || ') + ')';
    check('and the estimate matches D1 as measured 2026-09-11 - 98 links in a call ran, 99 did not',
      expressionDepth(chainOf(98)) === 99 && expressionDepth(chainOf(99)) === 100,
      `${expressionDepth(chainOf(98))} / ${expressionDepth(chainOf(99))}`);
    const lines = Array.from({ length: 70 }, (_, i) => `line ${i}`);
    const asChain = "UPDATE t SET m = replace(m, 'x', " + lines.map((l) => `'${l}'`).join(' || char(10) || ') + ');';
    const asOne = "UPDATE t SET m = replace(m, 'x', replace('" + lines.join('~~') + "', '~~', char(10)));";
    check('F59\'s first shape is refused', expressionDepth(asChain) > D1_MAX_EXPR_DEPTH);
    check('while the same text as one literal and one replace() is nothing',
      expressionDepth(asOne) <= 3, String(expressionDepth(asOne)));

    // d1Query must not hand its SQL to a shell: an odd number of double quotes
    // in the SQL closed the shell's quoting, and a trailing `> 0` became a
    // redirect into a file named 0 (reproduced 2026-09-11).
    const queryLib = readFileSync(join(appDir, '..', '..', 'scripts', 'd1-query-lib.mjs'), 'utf8');
    // Asked of the CODE, not the prose: the file's own comment quotes the old
    // `--command "${sql}"` string to explain the bug, so a text match on it
    // would fail on the explanation. execSync was only ever the shelled form.
    check('d1Query runs wrangler without a shell string',
      !/\bexecSync\s*\(/.test(queryLib) && /d1Query[\s\S]{0,400}?runWrangler\(\[/.test(queryLib));
  }

  const names = (c) => (c.skills.occ_skills || []).map((x) => x.name).filter(Boolean);
  const cls = parsed.data;

  check('with none chosen the class grants only its own skills',
    names(composeClass({ rcc: cls, character: {} })).join() === 'Basic Math');

  // A BARE STRING, which is what every character and draft written before
  // BOOK-INGEST-AUDIT.md F82 holds. It has to keep composing exactly as it did.
  const comms = composeClass({ rcc: cls, character: { mos: 'comms' } });
  check('choosing one ADDS its skills rather than replacing',
    names(comms).join() === 'Basic Math,Radio: Basic', names(comms).join());
  check('and the choice is recorded for the sheet',
    Array.isArray(comms.mos_chosen) && comms.mos_chosen.length === 1
      && comms.mos_chosen[0].name === 'Communications MOS');

  const medic = composeClass({ rcc: cls, character: { mos: 'medic' } });
  check('a different specialty grants different skills',
    names(medic).join() === 'Basic Math,Paramedic');

  // A character who picked an option a later edit removed is still a character.
  const gone = composeClass({ rcc: cls, character: { mos: 'no-such-mos' } });
  check('an unknown id leaves the class untouched rather than throwing',
    names(gone).join() === 'Basic Math' && !gone.mos_chosen);

  // The class may sit in EITHER slot: a character with no racial class carries
  // their O.C.C. in the rcc slot, which is where the first version only worked.
  const asOcc = composeClass({
    rcc: { id: 'r', name: 'R', system: 'rifts', category: 'rcc' },
    occ: cls, character: { mos: 'comms' } });
  check('an MOS survives being merged with a racial class',
    names(asOcc).includes('Radio: Basic'), names(asOcc).join());

  // Shape errors, each of which would otherwise fail silently.
  const noOpts = parseClassMarkdown(['---', 'id: t', 'name: T', 'system: rifts',
    'source_book: b', 'category: occ', 'skills:', '  mos:', '    choose: 1',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('an MOS with no options is rejected',
    noOpts.errors.some((e) => /needs a non-empty options list/.test(e)));

  const over = mk().data;
  over.skills.mos.choose = 5;
  const errs = [];
  validateMos(over.skills.mos, errs, []);
  check('asking for more specialties than exist is rejected',
    errs.some((e) => /asks for 5 of only 2/.test(e)), errs.join('; '));

  const dupe = { choose: 1, options: [
    { id: 'a', name: 'A', skills: [{ name: 'X', base: 1 }] },
    { id: 'a', name: 'A again', skills: [{ name: 'Y', base: 1 }] }] };
  const dErrs = [];
  validateMos(dupe, dErrs, []);
  check('two options with the same id are rejected',
    dErrs.some((e) => /two options called/.test(e)), dErrs.join('; '));

  // ------------------------------------------------------------------
  // `skills.mos.choose` is HONOURED (BOOK-INGEST-AUDIT.md F82).
  //
  // It was validated here and read by nothing for the whole of the key's life:
  // a class asking for three granted one and reported nothing wrong. Every
  // check below would have passed vacuously before F82 except the counting
  // ones, which is why they are the point of this section.
  section('MOS: choose more than one');

  check('mosList reads a bare id - every pre-F82 character and draft',
    mosList('comms').join() === 'comms');
  check('mosList reads a list',
    mosList(['comms', 'medic']).join() === 'comms,medic');
  check('mosList reads a JSON list as TEXT - what characters.mos now holds',
    mosList('["comms","medic"]').join() === 'comms,medic');
  check('mosList treats an unparsable bracketed string as ONE id, not as empty',
    mosList('[not json').join() === '[not json');
  check('mosList drops blanks and null', mosList([null, '', ' ', 'x']).join() === 'x');
  check('mosList is empty for null and for an empty string',
    !mosList(null).length && !mosList('').length && !mosList(undefined).length);
  // The book's rule is that a program is taken once (Heroes Unlimited printed
  // 27, restriction 8). Granting one twice would DOUBLE its skills silently.
  check('mosList de-duplicates case-insensitively',
    mosList(['Comms', 'comms', 'medic']).join() === 'Comms,medic');

  const both = composeClass({ rcc: cls, character: { mos: ['comms', 'medic'] } });
  check('two specialties grant BOTH skill lists',
    names(both).join() === 'Basic Math,Radio: Basic,Paramedic', names(both).join());
  check('and both are recorded for the sheet',
    both.mos_chosen.map((m) => m.id).join() === 'comms,medic');
  check('a JSON list as text composes the same way',
    names(composeClass({ rcc: cls, character: { mos: '["comms","medic"]' } })).join()
      === 'Basic Math,Radio: Basic,Paramedic');
  // One dangling id must not cost the character the specialty that is real.
  const half = composeClass({ rcc: cls, character: { mos: ['no-such-mos', 'medic'] } });
  check('an unknown id among several still grants the rest',
    names(half).join() === 'Basic Math,Paramedic', names(half).join());

  const twoCfg = { choose: 2, options: [
    { id: 'a', name: 'A', skills: [{ name: 'X', base: 1 }] },
    { id: 'b', name: 'B', skills: [{ name: 'Y', base: 1 }] }] };
  const twoErrs = [];
  validateMos(twoCfg, twoErrs, []);
  check('choose: 2 against two options is legal', !twoErrs.length, twoErrs.join('; '));

  // The validator's counting half. A short build is a WARNING and never a
  // violation - the posture docs/race-and-occupation.md states, and the create
  // endpoint must not start refusing characters it accepted yesterday.
  const mosClass = { id: 'm', name: 'M', skills: { occ_skills: [], mos: twoCfg } };
  const vOne = validateCharacter({ character: { mos: ['a'] }, cls: mosClass, skills: [] });
  check('holding one of two is warned, not refused',
    !vOne.violations.length
      && vOne.warnings.some((w) => w.rule === 'mos_unchosen' && w.chosen === 1 && w.want === 2));
  const vBoth = validateCharacter({ character: { mos: ['a', 'b'] }, cls: mosClass, skills: [] });
  check('holding both is clean',
    !vBoth.warnings.some((w) => w.rule === 'mos_unchosen'));
  const vGone = validateCharacter({ character: { mos: ['a', 'zzz'] }, cls: mosClass, skills: [] });
  check('a dangling id is named, and separately from the count',
    vGone.warnings.filter((w) => w.rule === 'mos_unknown').map((w) => w.mos).join() === 'zzz'
      && vGone.warnings.some((w) => w.rule === 'mos_unchosen'));
  // A one-pick class is every class that carried this key before F82, and its
  // message must not have changed.
  const oneCfg = { choose: 1, options: twoCfg.options };
  const vNone = validateCharacter({
    character: {}, cls: { id: 'o', name: 'O', skills: { occ_skills: [], mos: oneCfg } }, skills: [] });
  check('a one-pick class still says "none is chosen"',
    vNone.warnings.some((w) => w.rule === 'mos_unchosen' && /none is chosen/.test(w.message)));

  // The wizard and the endpoint, read off their source. The create path took
  // `typeof b.mos === 'string'` until F82 and would have stored NULL for the
  // array the wizard now sends - silently, which is the whole hazard.
  {
    const fnDir = join(repoRoot, 'functions', 'api', 'character-creator');
    const charactersSrc = readFileSync(join(fnDir, 'characters.js'), 'utf8');
    const charJsonSrc = readFileSync(join(fnDir, '_lib', 'character-json.js'), 'utf8');
    const mosAppSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
    const mosSheetSrc = readFileSync(appPath('sheet.js'), 'utf8');

    check('the create endpoint reads mos through mosList',
      /const mosPicked = mosList\(b\.mos\)/.test(charactersSrc), 'characters.js');
    check('and stores a list as JSON text rather than dropping it',
      /Array\.isArray\(b\.mos\) \? JSON\.stringify\(mosPicked\)/.test(charactersSrc));
    // Declaring `mos` a JSON column would decode a pre-F82 bare id to `[]` -
    // LOSING it, because a bare id is not JSON and that list falls back to
    // empty. The tolerant reader exists so this never has to happen.
    check('mos is NOT declared a decoded JSON column',
      !/CHARACTER_JSON_COLUMNS\s*=\s*\[[^\]]*'mos'/.test(charJsonSrc)
        && !/ARRAY_COLUMNS\s*=\s*new Set\(\[[^\]]*'mos'/.test(charJsonSrc));
    check('the wizard holds S.mos as a list',
      Array.isArray(freshState().mos) && Array.isArray(freshBuild().mos));
    check('and sends it only when something is chosen',
      /mos: S\.mos\?\.length \? S\.mos : undefined/.test(mosAppSrc));
    check('resuming a draft normalises a pre-F82 string',
      /S\.mos = mosList\(S\.mos\);/.test(mosAppSrc));
    check('the picker tests membership rather than equality',
      /const on = \(S\.mos \|\| \[\]\)\.some\(/.test(mosAppSrc));
    check('the sheet renders every specialty, not the first',
      /cls\.mos_chosen\.map\(\(m\) => m\.name\)\.join/.test(mosSheetSrc), 'sheet.js');

    // ── BOTH OF THESE WERE FOUND BY LOOKING AT THE PAGE ──────────────────
    //
    // Not by a check, and not by reading the source. Every check above passed
    // while the picker was drawing four chosen programs indistinguishable from
    // the ten unchosen ones, and labelling one of them "[object Object]".
    //
    // `styles.css` has exactly ONE rule for a chosen .pick and it is
    // `.pick.sel`. This picker emitted `.pick.on`, so a chosen specialty
    // computed to the same border and background as an unchosen one - it had
    // never been visible, for any of the six MOS classes. It mattered little
    // while one could be chosen (the skill list below changed, and that was the
    // feedback) and a great deal at four of fourteen.
    //
    // Pinned against the CSS rather than against the string `sel`, so renaming
    // the class in one file fails here instead of going quiet again.
    {
      const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
      const rules = css.match(/\.pick\.[a-z-]+\s*\{/g) || [];
      const chosen = /\.pick\.([a-z-]+)\s*\{/.exec(css);
      check('styles.css defines exactly one chosen-.pick class',
        rules.length === 1, rules.join(' ') || 'none');
      const emitted = [...mosAppSrc.matchAll(/class="pick\$\{[^}]*\? ' ([a-z-]+)' : ''\}"/g)]
        .map((m) => m[1]);
      check('and every .pick the wizard marks as chosen uses it',
        emitted.length > 0 && chosen && emitted.every((c) => c === chosen[1]),
        `css .pick.${chosen?.[1]}, emitted ${[...new Set(emitted)].join('/') || 'none'}`);
    }
    // A category MAY BE AN OBJECT - `{ name, only_prefix, ... }` - and joining
    // the raw list rendered "3 from [object Object], [object Object]". Every
    // other picker in app.js already goes through categoryLabel; this was the
    // one that did not.
    check('the MOS summary labels categories instead of joining objects',
      /x\.categories\.map\(categoryLabel\)/.test(mosAppSrc)
        && !/\(x\.categories \|\| x\.from \|\| \[\]\)\.join/.test(mosAppSrc));
  }

  const empty = { choose: 1, options: [{ id: 'a', name: 'A', skills: [] }] };
  const eErrs = [];
  validateMos(empty, eErrs, []);
  check('an option granting no skills is rejected',
    eErrs.some((e) => /grants no skills/.test(e)), eErrs.join('; '));

  // The shared validator is the point: an MOS option's entries are the same
  // shape as occ_skills, so a bad choice group has to fail the same way.
  const badGroup = { choose: 1, options: [{ id: 'a', name: 'A',
    skills: [{ choose: 3, from: ['One', 'Two'] }] }] };
  const gErrs = [];
  validateMos(badGroup, gErrs, []);
  check('an over-asking choice group inside an MOS fails like one in occ_skills',
    gErrs.some((e) => /asks for 3 of only 2/.test(e)), gErrs.join('; '));
}

section('Totem animals (BOOK-INGEST-AUDIT F56)');
{
  const md = (extra) => ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    ...extra, 'skills:', '  occ_skills:', '    - { name: "Swimming", base: 50, per_level: 5 }',
    '    - { name: "Math: Basic", bonus: 10 }', '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10));
  const plain = parseClassMarkdown(md(['totem: { from: "animal" }']));
  check('the totem key parses', plain.ok && plain.data.totem?.from === 'animal', plain.errors.join('; '));
  const tw = parseClassMarkdown(md(['totem: { from: "animal", powers: true }']));
  check('and so does its powers flag', tw.ok && tw.data.totem?.powers === true, tw.errors.join('; '));

  // A row as the catalog stores it: skills and bonuses are JSON TEXT.
  const row = { slug: 'otter', name: 'Otter',
    skills: JSON.stringify([{ name: 'Swimming', bonus: 15 }, { name: 'Prowl', bonus: 5 }]),
    bonuses: JSON.stringify({ attributes: { IQ: 1, PS: '1d4' }, pools: { sdc: 10 } }),
    bonus_note: 'An excellent diver.', powers: 'Holds its breath.' };
  const entries = (c) => c.skills.occ_skills || [];
  const find = (c, n) => entries(c).filter((s) => s.name === n);
  const got = composeClass({ rcc: plain.data, character: { totem: 'otter' }, totem: row });
  check('a skill the class lacks is appended with the totem\'s bonus',
    find(got, 'Prowl').length === 1 && find(got, 'Prowl')[0].bonus === 5, JSON.stringify(entries(got)));
  // Printed 96: "If they are included in O.C.C. skills, the player gets a
  // special bonus of +10%" - held once, raised ten, and the totem's own +15 is
  // not stacked on top.
  check('a skill the O.C.C. already has is held once and raised +10%',
    find(got, 'Swimming').length === 1 && find(got, 'Swimming')[0].base === 60,
    JSON.stringify(find(got, 'Swimming')));
  const onBonus = composeClass({ rcc: plain.data, character: { totem: 'otter' },
    totem: { ...row, skills: JSON.stringify([{ name: 'Math: Basic', bonus: 5 }]) } });
  check('and an entry stated as a bonus gains the ten on its bonus',
    find(onBonus, 'Math: Basic')[0]?.bonus === 20, JSON.stringify(find(onBonus, 'Math: Basic')));
  check('its bonuses are summed in, dice and pools included',
    got.bonuses?.attributes?.IQ === 1 && got.bonuses?.attributes?.PS === '1d4' && got.bonuses?.pools?.sdc === 10,
    JSON.stringify(got.bonuses));
  check('the choice is recorded for the sheet',
    got.totem_chosen?.name === 'Otter' && got.totem_chosen.bonus_note === 'An excellent diver.');
  check('and the powers stay hidden from a class without powers: true', got.totem_chosen?.powers === null);
  const twGot = composeClass({ rcc: tw.data, character: { totem: 'otter' }, totem: row });
  check('while the Totem Warrior sees them', twGot.totem_chosen?.powers === 'Holds its breath.');

  const noKey = parseClassMarkdown(md([])).data;
  const untouched = composeClass({ rcc: noKey, character: { totem: 'otter' }, totem: row });
  check('a class without the key ignores the row entirely',
    !untouched.totem_chosen && !find(untouched, 'Prowl').length && !untouched.bonuses?.pools);
  check('a row for some other slug is ignored',
    !composeClass({ rcc: plain.data, character: { totem: 'bear' }, totem: row }).totem_chosen);
  check('and no row at all leaves the class as it was',
    !composeClass({ rcc: plain.data, character: { totem: 'otter' } }).totem_chosen);
  // combineClasses rebuilds from the race spread, so the O.C.C.'s key has to be
  // carried or a D-Bee Tribal Warrior silently loses the pick.
  const asOcc = composeClass({ rcc: { id: 'r', name: 'R', system: 'rifts', category: 'rcc' },
    occ: plain.data, character: { totem: 'otter' }, totem: row });
  check('the key survives being merged with a racial class', asOcc.totem_chosen?.slug === 'otter');

  const warn = (character, totem) => validateCharacter({ character, cls: composeClass({
    rcc: plain.data, character, totem }), skills: [], attributes: {} });
  const unchosen = warn({ level: 1 }, null);
  check('none chosen is a warning, never a violation',
    unchosen.warnings.some((w) => w.rule === 'totem_unchosen')
    && !unchosen.violations.some((v) => /totem/.test(v.rule)));
  check('a slug the catalog no longer has is named',
    warn({ level: 1, totem: 'dodo' }, null).warnings.some((w) => w.rule === 'totem_unknown' && w.totem === 'dodo'));
  check('and a resolved one says nothing',
    !warn({ level: 1, totem: 'otter' }, row).warnings.some((w) => /^totem_/.test(w.rule)));

  const e1 = [];
  validateTotem({ from: 'element' }, e1, []);
  check('from must say animal', e1.some((e) => /totem\.from must be "animal"/.test(e)), e1.join('; '));
  const e2 = [];
  validateTotem({ from: 'animal', powers: 'yes' }, e2, []);
  check('powers is a flag', e2.some((e) => /powers is a flag/.test(e)), e2.join('; '));

  const tf = (n) => CATALOGS.totems.fields.find((f) => f.name === n);
  check('the totems catalog accepts dice and pools in its bonuses',
    !coerceField(tf('bonuses'), '{"attributes":{"PS":"1d4"},"pools":{"sdc":15}}').error);
  check('and refuses a skill list that is not a list', !!coerceField(tf('skills'), '{"name":"X"}').error);
  check('or one composition would misread',
    !!coerceField(tf('skills'), '[{"name":"X","base":5,"bonus":5}]').error);
  check('while a skill\'s own bonuses stay flat-only',
    !!coerceField(CATALOGS.skills.fields.find((f) => f.name === 'bonuses'), '{"attributes":{"PS":"1d4"}}').error);
}

}
