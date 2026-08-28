// Replay a rebuild and print every file that changes one row.
//
//   node scripts/trace-row.mjs psionic_powers name "Healing Touch"
//   node scripts/trace-row.mjs gear slug boom-gun-glitter-boy-rail-gun
//   node scripts/trace-row.mjs imported_classes class_id burster --grep "Weapon Proficiencies"
//
// A DEVELOPMENT TOOL, the companion to rebuild-local.mjs and subject to the
// same caveats - read that file's header first. Nothing depends on this and
// nothing should.
//
// WHY IT EXISTS. Filename order is execution order here, and the failure that
// keeps recurring is a script whose guard names a string an EARLIER script has
// already renamed: it matches nothing, does nothing, and looks exactly like a
// script that had nothing to do. A concatenated bootstrap cannot tell you which
// file did that, because it is one wrangler invocation. This can.
//
// It found two of the audit's findings that way. `burster`'s duplicated W.P.
// list turned out to be created by `fix-class-skill-names-to-rue.sql` renaming
// the two names a four-name list already held, three files before the script
// written to collapse it (REBUILD-AUDIT.md F7). And `Healing Touch` turned out
// to be created bare by `seed-catalogs.sql` and never touched again by any of
// the other 294 files (F6, F13).
//
// --grep is for the wide columns. A class's markdown is tens of kilobytes and
// printing it on every change is unreadable; with --grep only the lines
// containing that substring are shown, which is how the W.P. trace above is
// legible at all.
import { DatabaseSync } from 'node:sqlite';
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { statements } from './sql-statements.mjs';

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');

const args = process.argv.slice(2);
const positional = args.filter((a, i) => !a.startsWith('--') && args[i - 1] !== '--grep');
const [table, keyCol, keyVal] = positional;
const grep = (() => {
  const i = args.indexOf('--grep');
  return i === -1 ? null : args[i + 1];
})();

if (!table || !keyCol || keyVal === undefined) {
  console.error('usage: node scripts/trace-row.mjs <table> <key-column> <key-value> [--grep <substring>]');
  process.exit(1);
}

// Identical to rebuild-local.mjs's, and identical on purpose: a trace that
// applied the files differently from the rebuild would be tracing something
// else. See that file for why a trigger body has to be re-joined.
function splitSql(sql) {
  const parts = [];
  let pending = null;
  for (const stmt of statements(sql)) {
    pending = pending === null ? stmt : pending + ';\n' + stmt;
    if (!/\bcreate\s+trigger\b/i.test(pending) || /\bend\s*$/i.test(pending)) {
      parts.push(pending);
      pending = null;
    }
  }
  if (pending !== null) parts.push(pending);
  return parts;
}

const plan = [join(repoRoot, 'db', 'schema.sql'), join(repoRoot, 'db', 'seed-catalogs.sql')];
for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
  if (/^--\s*local-only\b/m.test(readFileSync(join(dataDir, f), 'utf8'))) continue;
  plan.push(join(dataDir, f));
}

const db = new DatabaseSync(':memory:');

const look = () => {
  try {
    const row = db.prepare(`SELECT * FROM ${table} WHERE ${keyCol} = ?`).get(keyVal);
    if (!row) return null;
    delete row.id;
    if (!grep) return row;
    // Only the matching lines of any wide column, so a markdown blob is one
    // readable line rather than forty screens.
    const kept = {};
    for (const [k, v] of Object.entries(row)) {
      const text = String(v ?? '');
      if (!text.includes('\n')) { kept[k] = v; continue; }
      const lines = text.split('\n').filter((l) => l.includes(grep));
      if (lines.length) kept[k] = lines.join('\n');
    }
    return kept;
  } catch {
    return null;                       // the table does not exist yet
  }
};

let prev = null;
let changes = 0;
for (const path of plan) {
  const name = path.slice(Math.max(path.lastIndexOf('/'), path.lastIndexOf('\\')) + 1);
  try {
    for (const s of splitSql(readFileSync(path, 'utf8'))) db.exec(s);
  } catch (e) {
    console.log(`  (${name} failed: ${e.message})`);
  }
  const now = look();
  if (JSON.stringify(prev) === JSON.stringify(now)) continue;
  changes++;
  console.log(`\n-- after ${name}`);
  if (now === null) {
    console.log('   (no such row yet)');
  } else {
    for (const [k, v] of Object.entries(now)) {
      const was = prev ? prev[k] : undefined;
      const mark = prev && String(was) !== String(v) ? ' *' : '  ';
      const text = v === null || v === undefined ? 'NULL' : String(v);
      if (text.includes('\n')) {
        for (const line of text.split('\n')) console.log(`  ${mark}${k}: ${line.trim()}`);
      } else {
        console.log(`  ${mark}${k.padEnd(14)} ${text.slice(0, 100)}`);
      }
    }
  }
  prev = now;
}

console.log(`\n${changes} file(s) changed ${table}.${keyCol}=${keyVal}`
  + (grep ? ` (lines matching ${JSON.stringify(grep)})` : ''));
process.exit(0);
