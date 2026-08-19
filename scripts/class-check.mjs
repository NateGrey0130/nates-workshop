#!/usr/bin/env node
// Validate a class before it goes near the database.
//
//   node scripts/class-check.mjs apps/character-creator/db/add-mystic-class.sql
//   node scripts/class-check.mjs draft.md
//   node scripts/class-check.mjs draft.md --remote
//   node scripts/class-check.mjs draft.md --no-catalog
//
// This is the CLI half of what `import/recheck` already does in the browser:
// parse the markdown through the REAL parser, cross-reference it against the
// REAL catalogs, and say what is wrong in one pass. Transcribing a class used
// to mean writing the whole data script, applying it, reading a SQLite error
// and guessing — a loop that re-derived the frontmatter contract every time
// round. The point of this script is that the loop happens here instead, for
// free, before a single row is written.
//
// It imports the shipped modules rather than reimplementing them. A checker
// that agreed with the app most of the time would be worse than no checker:
// you would iterate against it, get a clean run, and still fail on Confirm.
//
// Three kinds of finding, and the difference between them matters:
//
//   ERRORS       the parser rejects the file. Fix before applying.
//   WARNINGS     it parses, and does something you may not have meant.
//   UNMODELLED   a top-level key nothing in the app reads — see the note in
//                class-check-lib.mjs. A decision to make, not a defect.
//
// Exit code is 1 for errors and pre-flight failures only. Warnings and
// unmodelled keys are judgement calls, and a script that exited non-zero on
// them would train you to stop reading the output.
//
// Unlike d1-apply.mjs this DOES default a target (--local). That script refuses
// to guess because an accidental --remote writes to production; every query
// here is a read.

import { readFileSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseClassMarkdown } from '../apps/character-creator/js/parser.js';
import { crossReference, buildStubStatements, restrictionNames } from '../functions/api/character-creator/_lib/catalog.js';
import { extractClassMarkdown, unmodelledKeys, crossCategoryRestrictions } from './class-check-lib.mjs';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const noCatalog = args.includes('--no-catalog');
const files = args.filter((a) => !a.startsWith('--'));

function die(msg) {
  console.error('\nclass-check: ' + msg);
  process.exit(1);
}

if (files.length !== 1) die('give exactly one .md or .sql file');
const file = files[0];
if (!existsSync(file)) die(`${file}: no such file`);

const raw = readFileSync(file);
const isSql = file.toLowerCase().endsWith('.sql');

let markdown;
if (isSql) {
  try {
    markdown = extractClassMarkdown(raw.toString('utf8'));
  } catch (e) {
    die(`${file}: ${e.message}`);
  }
  if (markdown === null) die(`${file}: no INSERT INTO imported_classes found`);
} else {
  markdown = raw.toString('utf8');
}

console.log(`class-check: ${file}`);
if (isSql) console.log('  markdown read from the imported_classes INSERT');

// ── the same pre-flight d1-apply runs, run early ──
// Finding this at apply time means coming back to the file cold. Finding it
// here means fixing it inside the edit you are already making.
const preflight = [];
if (isSql) {
  if (raw.includes(0x0d)) {
    preflight.push('contains CR — a CRLF checkout changes the bytes that reach the '
      + 'database (see .gitattributes and PR #93). Re-checkout the file');
  }
  const bad = raw.findIndex((b) => b > 0x7f);
  if (bad >= 0) {
    preflight.push(`non-ASCII byte at offset ${bad} — wrangler on Windows has turned these `
      + 'into mojibake in production. Splice it in with char(N)');
  }
}

const { ok, data, errors, warnings } = parseClassMarkdown(markdown);

const list = (label, items) => {
  if (!items.length) return;
  console.log(`\n${label} (${items.length})`);
  for (const i of items) console.log(`  - ${i}`);
};

console.log(`\nPARSE            ${ok ? 'ok' : 'FAILED'}`);
if (data) {
  console.log(`  ${data.category ?? '?'} "${data.name ?? '?'}" (${data.id ?? '?'}) — ${data.system ?? '?'}`);
  if (data.source_book) console.log(`  ${data.source_book}`);
}
list('ERRORS', errors);
list('WARNINGS', warnings);
list('SQL PRE-FLIGHT', preflight);

const unmodelled = unmodelledKeys(data);
if (unmodelled.length) {
  console.log(`\nUNMODELLED (${unmodelled.length})`);
  for (const k of unmodelled) {
    console.log(`  - \`${k}\` is read by nothing. It will be stored and silently ignored.`);
  }
  console.log('  Either model it — parser.js, validate-character.js, the wizard and');
  console.log('  the sheet — or move it into the body as prose so the class can ship');
  console.log('  now. See "When a class needs the app to change" in the class-import');
  console.log('  skill.');
}

// ── catalog cross-reference ──
// Runs the same crossReference() the Confirm endpoint calls, through a shim
// giving it the env.DB shape over `wrangler d1 execute`. Reusing the function
// rather than rewriting its queries is why a clean run here means a clean run
// in the app.
const npxCli = path.join(path.dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
const npxCliFound = existsSync(npxCli);

// Same spawn dance as d1-apply.mjs, and for the same reason: Windows npx is a
// .cmd, Node refuses to spawn one unshelled, and `shell: true` concatenates
// argv instead of escaping it. Calling npm's npx-cli.js with this Node keeps a
// real argv array, which matters here because the SQL argument contains spaces
// and quotes.
function wrangler(cliArgs) {
  const opts = { encoding: 'utf8', cwd: repoRoot, maxBuffer: 64 * 1024 * 1024 };
  const r = npxCliFound
    ? spawnSync(process.execPath, [npxCli, ...cliArgs], opts)
    : spawnSync('npx', cliArgs, { ...opts, shell: true });
  return { code: r.status ?? 1, out: (r.stdout || '') + (r.stderr || '') };
}

// D1 has no CLI parameter binding, so the shim inlines the values itself.
// Only ever reached with names out of parsed class data, and only ever inside a
// SELECT, but quoted properly regardless — an apostrophe in a skill name is
// completely ordinary (Sailor's Knots).
const quote = (v) => (v == null ? 'NULL' : `'${String(v).replace(/'/g, "''")}'`);

function inline(sql, params) {
  let out = '';
  let n = 0;
  let inStr = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inStr) {
      out += c;
      if (c === "'") inStr = false;
      continue;
    }
    if (c === "'") { inStr = true; out += c; continue; }
    out += c === '?' ? quote(params[n++]) : c;
  }
  return out;
}

function query(sql) {
  const r = wrangler(['wrangler', 'd1', 'execute', 'DB', remote ? '--remote' : '--local',
    '--json', '--command', sql.replace(/\s+/g, ' ').trim()]);
  if (r.code !== 0) {
    die(`d1 query failed (${remote ? 'remote' : 'local'}).\n${r.out.trim()}\n\n`
      + 'If the local database has never been built:\n'
      + '  node scripts/d1-apply.mjs --local db/schema.sql');
  }
  // wrangler prints human lines around the JSON payload.
  const start = r.out.indexOf('[');
  const end = r.out.lastIndexOf(']');
  if (start < 0 || end < 0) die('could not find JSON in the d1 output:\n' + r.out.trim());
  try {
    return JSON.parse(r.out.slice(start, end + 1))[0]?.results ?? [];
  } catch (e) {
    die('could not parse the d1 JSON output: ' + e.message);
  }
}

// Enough of the D1 binding for catalog.js: prepare().bind().all(), plus the
// prepare() buildStubStatements uses to describe writes this never runs.
const env = {
  DB: {
    prepare(sql) {
      return {
        _sql: sql,
        _args: [],
        bind(...a) { this._args = a; return this; },
        async all() { return { results: query(inline(this._sql, this._args)) }; },
        toSql() { return inline(this._sql, this._args); },
      };
    },
  },
};

const plural = (n, word) => `${n} ${word}${n === 1 ? '' : 's'}`;

if (noCatalog) {
  console.log('\nCATALOG          skipped (--no-catalog)');
} else if (!data) {
  console.log('\nCATALOG          skipped (nothing parsed)');
} else {
  const missing = await crossReference(env, null, data);
  const counts = ['items', 'skills', 'spells', 'psionics'].map((k) => [k, missing[k].length]);
  const total = counts.reduce((s, [, n]) => s + n, 0);

  console.log(`\nCATALOG (${remote ? 'REMOTE' : 'local'})`);
  for (const [k, n] of counts) {
    console.log(`  ${k.padEnd(14)} ${n === 0 ? 'ok' : `${plural(n, 'row')} missing`}`);
    for (const name of missing[k]) console.log(`      ${name}`);
  }

  // The quiet one. `categoryAllows` compares literal names, so a restriction
  // naming a skill the catalog spells differently makes an `except` exclude
  // NOTHING — it fails open, offering skills the book forbids, and says so
  // nowhere.
  const restrictions = missing.restrictions;
  if (restrictions.length) {
    console.log(`  ${'restrictions'.padEnd(14)} ${plural(restrictions.length, 'name')}`
      + ` match${restrictions.length === 1 ? 'es' : ''} no skill row`);
    for (const r of restrictions) console.log(`      ${r.category} ${r.kind}: "${r.name}"`);
    console.log('      These do nothing as written. An unmatched `except` excludes');
    console.log('      NOTHING, so the class offers skills the book forbids.');
  } else {
    console.log(`  ${'restrictions'.padEnd(14)} ok`);
  }

  // Restriction names that DO resolve, but to a row in another category. The
  // missing-row check above cannot see these - the name matches a skill, so it
  // stays quiet - yet they are the same kind of silent failure.
  const wanted = restrictionNames(data);
  if (wanted.length) {
    const names = [...new Set(wanted.map((w) => w.name))];
    const rows = query('SELECT name, category FROM skills WHERE name IN ('
      + names.map((n) => quote(n)).join(',') + ')');
    const categoryOf = new Map(rows.map((r) => [String(r.name).trim().toLowerCase(), r.category]));
    const { granted, noop } = crossCategoryRestrictions(wanted, categoryOf);

    if (granted.length) {
      console.log(`
  ${'cross-category'.padEnd(14)} ${plural(granted.length, 'name')} granted from another category`);
      for (const g of granted) {
        console.log(`      ${g.category} only: "${g.name}" - the catalog files it under ${g.actual ?? 'no category'}`);
      }
      console.log('      These WORK: an `only` entry matches by name whatever the');
      console.log('      catalog category is, which is what the book means.');
    }
    if (noop.length) {
      console.log(`
  ${'no-op except'.padEnd(14)} ${plural(noop.length, 'name')} excluded from the wrong category`);
      for (const n of noop) {
        console.log(`      ${n.category} except: "${n.name}" - the catalog files it under ${n.actual ?? 'no category'}`);
      }
      console.log('      These exclude NOTHING - the skill was never offered in that');
      console.log('      category. Harmless, but the category is probably wrong.');
    }
  }

  // The stub rows the class needs, as SQL to paste into the data script. The
  // app creates these itself on Confirm; a data script has to carry its own,
  // and writing them by hand is where the STUB marker and the char(8212) splice
  // get forgotten.
  if (total) {
    const { statements } = buildStubStatements(env, missing, {
      system: data.system,
      sourceBook: data.source_book ?? null,
    });
    console.log('\nSTUB SQL — paste above the imported_classes INSERT');
    console.log('(em-dash spliced with char(8212), per the ASCII-only rule)\n');
    for (const s of statements) {
      console.log('  ' + s.toSql().replace(/\s+/g, ' ').trim()
        .replace(/'STUB — /, "'STUB ' || char(8212) || ' ") + ';');
    }
  }
}

const blocking = errors.length + preflight.length;
console.log(`\nclass-check: ${blocking ? 'NOT ready' : 'ready'} — `
  + `${plural(errors.length, 'error')}, ${plural(warnings.length, 'warning')}`
  + (preflight.length ? `, ${plural(preflight.length, 'pre-flight failure')}` : '')
  + (unmodelled.length ? `, ${plural(unmodelled.length, 'unmodelled key')}` : ''));
process.exit(blocking ? 1 : 0);
