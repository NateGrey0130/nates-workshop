// What this repo says about itself, checked against what it is.
//
// Counts in prose, the scripts file map, the data-script and migration tables,
// the skill list in CLAUDE.md, the file-size table in docs/known-limitations.md
// and the paragraph under it. Every one of these was prose once, and every one
// went stale - which is why they are assertions now rather than sentences.
//
// Split out of smoke.mjs unchanged. Node loads this natively, so a check file
// costs nothing at runtime: the no-build-step rule that keeps the PAGE scripts
// whole does not reach a script only Node ever runs.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';
import { CHARACTER_JSON_COLUMNS } from '../../../../functions/api/character-creator/_lib/character-json.js';
import { VARIANT_OVERRIDES, parseClassMarkdown } from '../../js/parser.js';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Documented counts'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Documented counts');
  {
    const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
    // Four chapters these checks read moved to docs/ when the README was split.
    // Each names the FILE it moved to rather than reading README plus docs/ as
    // one corpus: a corpus read keeps passing when the section it was written for
    // disappears, because some other page still happens to contain the word.
    // Naming the file is what keeps the check failing for the right reason.
    const doc = (name) => readFileSync(join(appDir, 'docs', name), 'utf8');
    const WORDS = { one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8,
      nine: 9, ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15,
      sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19, twenty: 20, thirty: 30,
      forty: 40, fifty: 50 };
    // Hyphenated compounds sum their parts, so 'twenty-one' does not have to be
    // listed and neither does the count after it. Before this, the capture group
    // stopped at the hyphen and 'Twenty-one tables' read as one table - which the
    // check then reported as a documentation drift rather than as its own bug.
    const num = (word) => {
      const parts = String(word).toLowerCase().split('-');
      if (parts.every((p) => p in WORDS)) return parts.reduce((n, p) => n + WORDS[p], 0);
      return Number(word);
    };

    const cols = readme.match(/`characters` stores (\w+) JSON columns/);
    check('README states the character JSON column count',
      !!cols, 'the sentence itself has changed shape');
    check('and it matches CHARACTER_JSON_COLUMNS',
      cols && num(cols[1]) === CHARACTER_JSON_COLUMNS.length,
      cols ? `README says ${cols[1]} (${num(cols[1])}), code has ${CHARACTER_JSON_COLUMNS.length}` : '');

    // Every JSON column needs a row in the data-model table, or a reader learns
    // the count is 8 and then finds 7 described.
    const missing = CHARACTER_JSON_COLUMNS.filter((c) => !readme.includes('| `' + c + '` |'));
    check('every JSON column has a row in the data-model table',
      missing.length === 0, missing.join(', '));

    // The variant override list is a closed set the README spells out. It had
    // already gained `starting_money` and `skill_overrides` without the prose
    // noticing, so the README claimed a variant could do less than it can.
    // All nine keys are enumerated in one passage under `Classes that come in
    // stages`, so the file that chapter moved to is the exact place to ask —
    // `hit_points_base` and `ppe_base` appear nowhere else in the docs.
    const leveling = doc('leveling.md');
    const unlisted = VARIANT_OVERRIDES.filter((k) => !leveling.includes('`' + k + '`'));
    check('docs/leveling.md names every VARIANT_OVERRIDES key',
      unlisted.length === 0, unlisted.join(', '));

    // The migration table had listed 001-009 while 017 was on disk — and the same
    // page discussed 011 and 012 further down, so it was provably stale in place.
    const migDir = join(appDir, '..', '..', 'db', 'migrations');
    const operations = doc('operations.md');
    const undocumented = readdirSync(migDir)
      .filter((f) => f.endsWith('.sql'))
      .filter((f) => !operations.includes('`' + f + '`'));
    check('every migration has a row in the docs/operations.md table',
      undocumented.length === 0, undocumented.join(', '));

    // Every endpoint must appear in the API surface table, or it is undiscoverable
    // to anyone reading the docs rather than the routing tree.
    const walkFns = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
      e.isDirectory() ? (e.name === '_lib' ? [] : walkFns(join(dir, e.name))) : (e.name.endsWith('.js') ? [join(dir, e.name)] : []));
    const fnRoot = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
    const surface = readme.slice(readme.indexOf('## API surface'));
    const surfaceTable = surface.slice(0, surface.indexOf('\n## ', 10));
    const unlistedRoutes = walkFns(fnRoot)
      .map((f) => f.slice(fnRoot.length + 1).replace(/\\/g, '/').replace(/\.js$/, ''))
      .filter((r) => !surfaceTable.includes('`' + r + '`'));
    check('every endpoint appears in the API surface table',
      unlistedRoutes.length === 0, unlistedRoutes.join(', '));

    // Documented and routed is not the same as reachable. `admin/audit` shipped
    // complete and had no caller in any page script for as long as it existed —
    // curl-only by accident rather than by decision, and so exercised by nothing.
    // The routes built dynamically (`import/${mode}/extract`) are why this names
    // one endpoint rather than sweeping them all.
    const pageScripts = readdirSync(appDir)
      .filter((f) => f.endsWith('.js'))
      .map((f) => readFileSync(join(appDir, f), 'utf8'))
      .join('\n');
    check('the character audit is reachable from the UI',
      pageScripts.includes("'admin/audit'"),
      'no page script calls it — it is an endpoint nobody can run');

    // The class-format example is the reference anyone writing a class by hand
    // copies from. If it stops parsing, the docs teach a shape the parser rejects.
    const lf = readme.replace(/\r\n/g, '\n');
    const example = lf.match(/```yaml\n(---\nid: cyber-knight[\s\S]*?)```/);
    check('the README class-format example is still there', !!example);
    if (example) {
      const parsed = parseClassMarkdown(example[1]);
      check('and it parses with no errors',
        (parsed.errors || []).length === 0, (parsed.errors || []).join('; '));
      // Keys the example must actually demonstrate, because each was documented
      // only in prose until it was added here.
      check('and it demonstrates the newer class keys', !!(
        parsed.data?.starting_money
        && parsed.data?.bonuses?.attribute_minimums
        && parsed.data?.skills?.secondary_skills?.schedule
        && (parsed.data?.skills?.occ_related_skills?.categories || []).some((c) => c && typeof c === 'object')
      ));
    }

    // The set of modules both runtimes load grew twice without the sentence
    // noticing ("three" survived compose.js and psionics.js joining). Recompute it
    // from the actual imports - direct from functions/**, plus one transitive hop
    // through those modules' own relative imports - and require each to be named.
    const fnFiles = walkFns(fnRoot).concat(walkFns(join(fnRoot, '..', '_lib')));
    const directShared = new Set();
    for (const f of fnFiles) {
      for (const m of readFileSync(f, 'utf8').matchAll(/apps\/character-creator\/js\/([a-z-]+\.js)/g)) {
        directShared.add(m[1]);
      }
    }
    for (const mod of [...directShared]) {
      const src = readFileSync(join(appDir, 'js', mod), 'utf8');
      for (const m of src.matchAll(/from '\.\/([a-z-]+\.js)'/g)) directShared.add(m[1]);
    }
    const bothSentence = readme.slice(readme.indexOf('modules are imported by both'), readme.indexOf('modules are imported by both') + 400);
    const unnamed = [...directShared].filter((m) => !bothSentence.includes('`js/' + m + '`'));
    check('every module both runtimes load is named in the README',
      unnamed.length === 0, 'not in the sentence: ' + unnamed.join(', '));

    // The composition sequence is written down twice - the README's numbered list
    // and compose.js's header comment - and the README's copy sat at three steps
    // after the code grew a fourth. They must agree.
    const compSection = readme.slice(readme.indexOf('## One place composes a class'));
    const readmeSteps = [...compSection.slice(0, compSection.indexOf('Six places'))
      .matchAll(/^\d+\. \*\*/gm)].length;
    const composeSrc = readFileSync(join(appDir, 'js', 'compose.js'), 'utf8');
    const codeSteps = [...composeSrc.matchAll(/^\/\/ {3}\d+\. /gm)].length;
    check('the README and compose.js agree on the number of composition steps',
      readmeSteps === codeSteps && readmeSteps >= 4,
      `README lists ${readmeSteps}, compose.js lists ${codeSteps}`);

    const schema = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
    const tables = (schema.match(/CREATE TABLE IF NOT EXISTS/g) || []).length;
    const stated = readme.match(/([\w-]+) tables in one shared D1 database/);
    check('README states the table count', !!stated);
    check('and it matches schema.sql',
      stated && num(stated[1]) === tables,
      stated ? `README says ${stated[1]} (${num(stated[1])}), schema has ${tables}` : '');

    // The same sentence, quoted inside a SKILL, where nothing parses it.
    // schema-change/SKILL.md illustrated step 9 with "Twenty-six tables in one
    // shared D1 database" while the README said thirty-three and schema.sql had
    // 33 — seven tables stale, in the file that tells you to update the README.
    // The README survived because the check above reads it back out of the prose.
    // Skill bodies are the largest body of live instruction with nothing doing
    // that for them, which is where the rot moved rather than stopped.
    //
    // Narrow on purpose: this pins ONE sentence shape, not skill prose in
    // general. The audit-menu skill's argument against mechanical readers of
    // these files is correct and this does not overturn it. A skill may quote
    // the value — it just cannot quote a WRONG one, which is what happened.
    const skillFiles = [];
    const walkSkills = (dir) => {
      for (const e of readdirSync(dir, { withFileTypes: true })) {
        const full = join(dir, e.name);
        if (e.isDirectory()) walkSkills(full);
        else if (e.name.endsWith('.md')) skillFiles.push(full);
      }
    };
    walkSkills(join(appDir, '..', '..', '.claude', 'skills'));
    const staleQuotes = [];
    for (const f of skillFiles) {
      for (const m of readFileSync(f, 'utf8').matchAll(/([\w-]+) tables in one shared D1 database/g)) {
        if (num(m[1]) !== tables) staleQuotes.push(`${f.replace(/\\/g, '/').split('/.claude/')[1]} says ${m[1]}`);
      }
    }
    check('and no skill quotes a table count that disagrees with it',
      staleQuotes.length === 0,
      `${staleQuotes.join('; ')} — schema has ${tables}. Describe the row, not its value`);

    // A correct count over an incomplete description is the worse failure of the
    // two, because the number reassures you the list is whole. The README said
    // seventeen and described fifteen — `import_sessions` and `import_staged` had
    // a migration row and an API section but no data-model row anywhere.
    const named = new Set([...readme.matchAll(/^\| `([a-z_]+)` \|/gm)].map((m) => m[1]));
    // The three the section explicitly disclaims: not this app's tables.
    // claude_usage belongs to the /api/claude proxy (the audit's F3 spend log),
    // the same site-level standing media_items has.
    const notOurs = ['media_items', 'schema_migrations', 'claude_usage'];
    // FilamentForge's tables are all prefixed ff_ — the prefix is the collision
    // boundary in the shared database, and that app documents its own data
    // model rather than borrowing a table here.
    const undescribed = [...schema.matchAll(/CREATE TABLE IF NOT EXISTS ([a-z_]+)/g)]
      .map((m) => m[1])
      .filter((t) => !named.has(t) && !notOurs.includes(t) && !t.startsWith('ff_'));
    check('every table has a row in a data-model table',
      undescribed.length === 0, undescribed.join(', '));
    check('and the two it disclaims are still disclaimed',
      notOurs.every((t) => readme.includes('`' + t + '`')));
    check('and the ff_ prefix is disclaimed', readme.includes('`ff_`'));

    // The data scripts grow with the audit — five landed in two days — and nothing
    // else records that one exists. A script nobody knows to run is a correction
    // that silently did not happen.
    const dataScripts = readdirSync(join(appDir, 'db')).filter((f) => f.endsWith('.sql'));
    // Bounded by the next heading of ANY depth, which is the rule
    // scripts/readme-section.mjs exists to enforce. This used to stop only at the
    // next `## ` and got the right answer by luck twice over: Data scripts was
    // the last subsection of its chapter, and after the split it is the last
    // thing in operations.md, so `indexOf` returned -1 and `slice(0, -1)` quietly
    // meant "to the end". Neither is a boundary; both look like one.
    const dsStart = operations.indexOf('### Data scripts');
    const dsRest = operations.slice(dsStart);
    const dsEnd = dsRest.slice(1).search(/\r?\n#{1,6} /);
    const dsSection = dsEnd === -1 ? dsRest : dsRest.slice(0, dsEnd + 1);
    const patterns = [...dsSection.matchAll(/`([a-z0-9*-]+\.sql)`/g)].map((m) =>
      new RegExp('^' + m[1].replace(/[.]/g, '\\.').replace(/\*/g, '.*') + '$'));
    const uncovered = dataScripts.filter((f) => !patterns.some((p) => p.test(f)));
    check('every data script is covered by the Data scripts table',
      uncovered.length === 0, uncovered.join(', '));

    // The same failure, one directory up. `read-columns.py` and
    // `ocr-fields-lib.mjs` both sat in scripts/ undocumented for several PRs -
    // and the first is now the whole basis of every Palladium Fantasy
    // extraction. A file map that quietly stops being a map is worse than none,
    // because the count of entries reassures you the list is whole.
    const scriptsDir = join(repoRoot, 'scripts');
    // .json is in the list because scripts/books.json is DATA that three
    // mechanisms read as a contract, not a config file - the map covering
    // every executable but not the registry they all consult would be the same
    // map quietly stopping being one.
    const onDisk = readdirSync(scriptsDir)
      .filter((f) => /\.(mjs|py|txt|json)$/.test(f));
    const sc = readme.slice(readme.indexOf('## The scripts at the repo root'));
    const scSection = sc.slice(0, sc.indexOf('\n## ', 10));
    const listed = new Set([...scSection.matchAll(/^\S*\s*([\w.-]+\.(?:mjs|py|txt|json))\s/gm)]
      .map((m) => m[1]));
    const unmapped = onDisk.filter((f) => !listed.has(f));
    check('every script in scripts/ is named in the file map',
      unmapped.length === 0, unmapped.join(', ') + ' - add it or delete it');
    const ghosts = [...listed].filter((f) => !onDisk.includes(f));
    check('and every name in the map is a script that exists',
      ghosts.length === 0, ghosts.join(', '));

    // The skills are DIRECTORY-SCOPED by nature: a session started outside the
    // repo root would not see them, and one ran an entire class import by hand
    // for exactly that reason. They are junction-linked into ~/.claude/skills so
    // they DO load from anywhere on this machine (SETUP.md), but the junctions are
    // per-machine and a new skill needs its own. CLAUDE.md is loaded either way,
    // so it carries the list - and a list is only useful while it is complete.
    const skillsDir = join(repoRoot, '.claude', 'skills');
    const skills = readdirSync(skillsDir, { withFileTypes: true })
      .filter((e) => e.isDirectory()).map((e) => e.name).sort();
    const claudeMd = readFileSync(join(repoRoot, 'CLAUDE.md'), 'utf8');
    const skillsUnnamed = skills.filter((s) => !claudeMd.includes('`' + s + '`'));
    check('every skill is named in CLAUDE.md', skillsUnnamed.length === 0,
      skillsUnnamed.join(', ') + ' - a session outside the repo root sees only CLAUDE.md');
    const claimed = [...claudeMd.matchAll(/^\| `([a-z0-9-]+)` \| /gm)].map((m) => m[1]).sort();
    check('and CLAUDE.md names no skill that does not exist',
      claimed.every((c) => skills.includes(c)),
      claimed.filter((c) => !skills.includes(c)).join(', '));
    check('and says how many there are', new RegExp(`\\b${
      ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
        'eleven', 'twelve'][skills.length - 1] ?? '<no word for this many>'
    } skills\\b`, 'i').test(claudeMd), `there are ${skills.length}`);

    // And CLAUDE.md must not go back to saying they DO NOT load. It said so for
    // two days after the junctions landed, on the one file that is loaded into
    // every session regardless of working directory - a live instruction
    // describing a solved problem as unsolved, inviting the exact cost the
    // junctions were bought to remove. The junctions themselves are per-machine
    // and cannot be tested from here; the sentence about them can.
    check('CLAUDE.md says the skills load from anywhere, not only from the repo root',
      /skills[^\n]*load from anywhere/i.test(claudeMd)
      && !/only load from the repo root/i.test(claudeMd));
    check('and points at the junction block that makes that true',
      /junction/i.test(claudeMd) && claudeMd.includes('SETUP.md'));
    const setup = readFileSync(join(repoRoot, 'SETUP.md'), 'utf8');
    check('which SETUP.md still carries',
      /New-Item -ItemType Junction/.test(setup));
    // The loop in SETUP.md is the thing a fresh machine runs, so it has to name
    // every skill - the same completeness problem as the CLAUDE.md table.
    const linked = [...setup.matchAll(/'([a-z0-9-]+)'/g)].map((m) => m[1]);
    const unlinked = skills.filter((s) => !linked.includes(s));
    check('and its junction loop names every skill',
      unlinked.length === 0,
      unlinked.join(', ') + ' - a skill with no link does not exist outside the repo');


    // A skill's reference/ must not FORK repo code. book-survey shipped its own
    // copy of read-columns.py and the two diverged completely - the copy was an
    // older implementation the repo does not have, while every extraction ran the
    // one in scripts/. A reference that is a fork reads as authoritative and is not.
    const forks = [];
    for (const s of skills) {
      const ref = join(skillsDir, s, 'reference');
      let entries = [];
      try { entries = readdirSync(ref); } catch { continue; }
      for (const f of entries) if (onDisk.includes(f)) forks.push(`${s}/reference/${f}`);
    }
    check('no skill reference forks a file in scripts/', forks.length === 0,
      forks.join(', ') + ' - point at the real one instead');

    // An export nothing imports. Four were found by an audit: applyMos, which
    // invited callers past composeClass; looseCounts and stemCounts, written
    // beside aliasCounts and never called by anything; and a READERS map whose
    // own comment claimed a consumer it did not have. All four are gone, and this
    // keeps the count at zero rather than letting the next one accumulate quietly.
    const codeFiles = [];
    const walkCode = (dir) => {
      for (const e of readdirSync(dir, { withFileTypes: true })) {
        if (e.name === 'node_modules' || e.name.startsWith('.')) continue;
        const p = join(dir, e.name);
        if (e.isDirectory()) walkCode(p);
        else if (/\.(js|mjs)$/.test(e.name)) codeFiles.push(p);
      }
    };
    for (const d of ['apps', 'functions', 'scripts', 'shared']) walkCode(join(repoRoot, d));
    const bodies = new Map(codeFiles.map((f) => [f, readFileSync(f, 'utf8')]));
    // A name in an HTML file counts as used: the wizard binds inline handlers.
    const htmlFiles = [];
    const walkHtml = (dir) => {
      for (const e of readdirSync(dir, { withFileTypes: true })) {
        if (e.name === 'node_modules' || e.name.startsWith('.')) continue;
        const p = join(dir, e.name);
        if (e.isDirectory()) walkHtml(p);
        else if (e.name.endsWith('.html')) htmlFiles.push(readFileSync(p, 'utf8'));
      }
    };
    walkHtml(repoRoot);
    const markup = htmlFiles.join('\n');

    const orphanExports = [];
    for (const [f, text] of bodies) {
      if (/[\\/]test[\\/]/.test(f)) continue;
      const names = new Set();
      for (const m of text.matchAll(/^export\s+(?:async\s+)?function\s+([A-Za-z_$][\w$]*)/gm)) names.add(m[1]);
      for (const m of text.matchAll(/^export\s+(?:const|let|class)\s+([A-Za-z_$][\w$]*)/gm)) names.add(m[1]);
      for (const n of names) {
        // A Pages Function exports onRequest* as its HTTP contract.
        if (/^onRequest/.test(n)) continue;
        const elsewhere = [...bodies.entries()].some(([g, t]) => g !== f && new RegExp(`\\b${n}\\b`).test(t));
        if (!elsewhere && !new RegExp(`\\b${n}\\b`).test(markup)) {
          orphanExports.push(`${f.slice(repoRoot.length + 1).replace(/\\/g, '/')}: ${n}`);
        }
      }
    }
    check('no export is named nowhere else', orphanExports.length === 0,
      orphanExports.join(', ') + ' - import it, un-export it, or delete it');

    // The README's file-size table. Two successive sets of these figures went
    // stale the same way - one drifted 80% on sheet.js while claiming a 20%
    // tolerance, the next said app.js was "roughly 1,900" at 2,950 and called
    // parser.js the second-largest file when sheet.js sits between them. Prose
    // saying "treat these as orders of magnitude" is not a tolerance; this is.
    {
      const TOLERANCE = 0.25;
      const rows = [...doc('known-limitations.md').replace(/\r/g, '')
        .matchAll(/^\| `((?:js\/)?[a-z-]+\.js)` \| ~([\d,]+) \|/gm)];
      check('the docs/known-limitations.md file-size table is readable',
        rows.length >= 5, `${rows.length} rows`);
      const off = [];
      for (const [, file, claimed] of rows) {
        const want = Number(claimed.replace(/,/g, ''));
        const actual = readFileSync(join(appDir, file), 'utf8').split('\n').length;
        if (Math.abs(actual - want) / actual > TOLERANCE) {
          off.push(`${file}: README ~${want}, actually ${actual}`);
        }
      }
      check(`and every figure in it is within ${TOLERANCE * 100}%`, off.length === 0,
        off.join('; '));

      // The ordering claim is the one that was flatly wrong, and it is cheap to
      // hold: the table is printed largest first.
      const sizes = rows.map(([, f]) => readFileSync(join(appDir, f), 'utf8').split('\n').length);
      check('and the table is still in descending order of size',
        sizes.every((n, i) => i === 0 || sizes[i - 1] >= n),
        rows.map(([, f], i) => `${f}=${sizes[i]}`).join(' '));

      // The PARAGRAPH under the table, not the figures. It argues the cost of
      // splitting in script tags and load order - a cost that is real for a
      // classic script and not for a module. app.js stopped being a classic
      // script, and the paragraph went on recommending a file that had been
      // deleted weeks earlier (`import.js`, retired with the in-app importer)
      // because prose is what was holding the claim. Whichever way either half
      // moves next, one of these fails and the paragraph gets reread.
      const moduleTag = (html, src) =>
        new RegExp(`<script[^>]*\\btype="module"[^>]*\\bsrc="${src}"|<script[^>]*\\bsrc="${src}"[^>]*\\btype="module"`)
          .test(readFileSync(join(appDir, html), 'utf8'));
      check('app.js is still a module, as known-limitations.md says it is',
        moduleTag('index.html', 'app\\.js'),
        'index.html no longer loads app.js as type="module" - the split-cost paragraph now overstates the cost');
      check('and sheet.js is still a classic script, as the same paragraph says',
        !moduleTag('sheet.html', 'sheet\\.js'),
        'sheet.html loads sheet.js as a module - the split-cost paragraph now overstates the cost for it too');
    }
  }
}
