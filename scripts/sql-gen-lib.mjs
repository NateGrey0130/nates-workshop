// What the row generators share: reading a table's columns out of the schema,
// turning a JSON value into a SQL literal or a refusal, and closing a script
// the way every data script here closes.
//
// BOOK-INGEST-AUDIT F124. scripts/bestiary-sql.mjs (F112) tracked the
// creatures and notables generator; the retrospective of 2026-10-03 rebuilt
// three more in a session scratchpad - vehicles with their locations and
// weapons, flat spell and gear rows, whole-markdown class fixes - and each
// re-decided the same things. scripts/vessel-sql.mjs, scripts/rows-sql.mjs and
// scripts/class-fix-sql.mjs are those three, tracked; this is what they hold in
// common. bestiary-sql.mjs keeps its own copies of the first two functions: it
// predates this file and is not touched by it.
//
// Nothing here writes a database. Each generator covers ONLY the step from
// reconciled JSON (or a finished markdown file) to one data script.

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { trailingSelects } from './sql-statements.mjs';

export const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const BATCH_ROWS = 40;
// D1 refuses a statement over 100 KB. A batch closes at whichever comes first.
const BATCH_BYTES = 90_000;
// How many identities one read-back names, so a failing part names forty rows
// to look at rather than three hundred.
const READBACK_ROWS = 40;
// THE LIMIT THAT ACTUALLY BITES is not a statement's size. scripts/d1-apply.mjs
// sends every trailing SELECT of a file as ONE --command, which on Windows goes
// through cmd.exe: past this many characters once escaped, the apply lands and
// the read-back then dies unevaluated. The figure and the escaping are that
// file's own (READBACK_BUDGET, cmdLineLength), copied because it runs on
// import; a generator REFUSES here where d1-apply can only warn afterwards.
const READBACK_BUDGET = 7900;
const cmdLineLength = (s) => {
  const quoted = /[ \t\n\v"]/.test(s) ? '"' + s.replace(/"/g, '\\"') + '"' : s;
  return quoted.length + 3 * (quoted.match(/[ !%^&()<>|"]/g) || []).length;
};

// ── columns ──────────────────────────────────────────────────────────────────

// One column per line, which is how schema.sql and the migrations are written.
// A table constraint (UNIQUE (...), PRIMARY KEY (...)) is skipped.
function createTableColumns(sql, table) {
  const m = new RegExp(`CREATE TABLE (?:IF NOT EXISTS )?${table}\\s*\\(([\\s\\S]*?)\\n\\);`).exec(sql);
  if (!m) return null;
  const cols = [];
  for (const raw of m[1].split('\n')) {
    const line = raw.replace(/--.*$/, '').trim().replace(/,$/, '');
    if (!line || /^(UNIQUE|PRIMARY KEY|CHECK|FOREIGN KEY|CONSTRAINT)\b/i.test(line)) continue;
    cols.push(columnFrom(line, table));
  }
  return cols;
}

// A column line this cannot read is an ERROR, not a guess. A DEFAULT that is
// an expression - (datetime('now')) - would be written into every row as that
// text, and a CHECK continued onto a second line would be read as a column.
// None of the tables the generators write has either today; the day one does,
// this stops rather than writing wrong rows.
function columnFrom(line, table) {
  const [name, type = ''] = line.split(/\s+/);
  if (!/^[a-z_][a-z0-9_]*$/.test(name) || !/^[A-Za-z]+$/.test(type)) {
    throw new Error(`${table}: cannot read the column line "${line.slice(0, 70)}" - a constraint `
      + 'continued across lines? Teach scripts/sql-gen-lib.mjs to read it first');
  }
  const check = /CHECK \(\s*\w+ IN \(([^)]*)\)\s*\)/i.exec(line);
  if (/CHECK\b/i.test(line) && !check) {
    throw new Error(`${table}.${name}: a CHECK this reader cannot parse - teach scripts/sql-gen-lib.mjs first`);
  }
  const def = /DEFAULT\s+('(?:[^']|'')*'|\S+)/i.exec(line);
  if (def && def[1].startsWith('(')) {
    throw new Error(`${table}.${name}: its DEFAULT is an expression, which this would write as text - `
      + 'teach scripts/sql-gen-lib.mjs to leave the column out first');
  }
  return {
    name,
    type: type.toUpperCase(),
    notNull: /NOT NULL/i.test(line),
    primary: /PRIMARY KEY/i.test(line),
    default: def ? def[1] : null,
    allowed: check ? check[1].split(',').map((s) => s.trim().replace(/^'|'$/g, '')) : null,
  };
}

// The columns of each named table, from db/schema.sql - the authority for a
// fresh build, and since every migrated column must also be in a schema.sql
// CREATE (smoke pins that), the authority for an existing one too.
export function loadColumns(tables, root = repoRoot) {
  const schema = readFileSync(path.join(root, 'db', 'schema.sql'), 'utf8').replace(/\r\n/g, '\n');
  const out = {};
  for (const table of tables) {
    const cols = createTableColumns(schema, table);
    if (!cols) throw new Error(`${table}: no CREATE TABLE found in db/schema.sql`);
    out[table] = cols;
  }
  return out;
}

// ── values ───────────────────────────────────────────────────────────────────

const PRINTABLE = /^[\x20-\x7e]*$/;
const KEBAB = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

export function sqlLiteral(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'number') return String(v);
  return `'${String(v).replace(/'/g, "''")}'`;
}

// Where a value stops being printable ASCII, for a refusal a person can act on.
export function asciiProblem(s) {
  if (PRINTABLE.test(s)) return null;
  const at = [...s].findIndex((ch) => !PRINTABLE.test(ch));
  const cp = [...s][at].codePointAt(0).toString(16).toUpperCase().padStart(4, '0');
  return `U+${cp} near ${JSON.stringify([...s].slice(Math.max(0, at - 20), at + 5).join(''))}`;
}

// A row's value for one column, or a refusal. `where` names the row.
export function columnValue(col, v, where, refusals) {
  if (v === undefined || v === null) {
    if (col.notNull && col.default === null) refusals.push(`${where}: ${col.name} is required`);
    if (col.default !== null) {
      const d = col.default.replace(/^'|'$/g, '');
      return Number.isNaN(Number(d)) ? d : Number(d);
    }
    return null;
  }
  if (col.type === 'INTEGER' || col.type === 'REAL') {
    if (typeof v === 'boolean') return v ? 1 : 0;
    const ok = col.type === 'INTEGER' ? Number.isInteger(v) : (typeof v === 'number' && Number.isFinite(v));
    if (!ok) { refusals.push(`${where}: ${col.name} is ${JSON.stringify(v)}, not ${col.type === 'INTEGER' ? 'an integer' : 'a number'}`); return null; }
    return v;
  }
  let s;
  if (typeof v === 'string') s = v;
  else if (typeof v === 'number') s = String(v);
  else if (typeof v === 'object') s = JSON.stringify(v);
  else { refusals.push(`${where}: ${col.name} is a ${typeof v}`); return null; }
  const bad = asciiProblem(s);
  if (bad) refusals.push(`${where}: ${col.name} holds a character outside printable ASCII (${bad})`);
  if (col.allowed && !col.allowed.includes(s)) {
    refusals.push(`${where}: ${col.name} "${s}" is not one of ${col.allowed.join(', ')}`);
  }
  return s;
}

// One input object against one table's columns: the row to write (every
// non-primary column, by name), with every refusal collected rather than
// thrown, so one pass reports them all. `skip` names input keys that are not
// columns on purpose (a vehicle's `locations` and `weapons`).
export function tableRow(table, cols, input, where, refusals, skip = []) {
  const names = new Set(cols.map((c) => c.name));
  for (const k of Object.keys(input)) {
    if (skip.includes(k)) continue;
    if (!names.has(k)) refusals.push(`${where}: "${k}" is not a column of ${table}`);
    else if (cols.find((c) => c.name === k).primary) refusals.push(`${where}: "${k}" is the row id and is never written`);
  }
  const row = {};
  for (const col of cols) {
    if (col.primary) continue;
    row[col.name] = columnValue(col, input[col.name], where, refusals);
  }
  return row;
}

export function kebabProblem(slug) {
  return typeof slug === 'string' && KEBAB.test(slug) ? null : `"${slug}" is not a kebab-case slug`;
}

// ── statements ───────────────────────────────────────────────────────────────

// Multi-row INSERT OR IGNOREs, closed at BATCH_ROWS rows or BATCH_BYTES bytes.
// OR IGNORE because a data script is re-runnable: a row that is already there
// is left alone, and the read-backs say whether every row is in.
export function batchedInserts(table, colNames, rows) {
  const out = [];
  const head = `INSERT OR IGNORE INTO ${table} (${colNames.join(', ')}) VALUES\n`;
  let batch = [];
  let bytes = head.length;
  const flush = () => { if (batch.length) out.push(head + batch.join(',\n') + ';'); batch = []; bytes = head.length; };
  for (const r of rows) {
    const line = `  (${colNames.map((c) => sqlLiteral(r[c])).join(', ')})`;
    if (batch.length && (batch.length >= BATCH_ROWS || bytes + line.length + 2 > BATCH_BYTES)) flush();
    batch.push(line);
    bytes += line.length + 2;
  }
  flush();
  return out;
}

export const inList = (values) => `(${values.map(sqlLiteral).join(', ')})`;

// "all N <what> are in", by identity, split into parts of READBACK_ROWS.
export function countReadbacks(table, column, values, what, extra = '') {
  const out = [];
  const parts = [];
  for (let i = 0; i < values.length; i += READBACK_ROWS) parts.push(values.slice(i, i + READBACK_ROWS));
  parts.forEach((part, i) => {
    const label = parts.length > 1 ? `${what}, part ${i + 1}: ${part.length} are in` : `all ${part.length} ${what} are in`;
    out.push(`SELECT ${sqlLiteral(label)} AS assertion, count(*) AS got, ${part.length} AS want`);
    out.push(`  FROM ${table} WHERE ${column} IN ${inList(part)}${extra};`);
  });
  return out;
}

// Whether d1-apply could still evaluate this script's read-backs, or the
// reason it could not.
export function readbackProblem(sql) {
  const n = cmdLineLength(trailingSelects(sql).join(' '));
  return n > READBACK_BUDGET
    ? `its read-backs are ${n} characters once cmd.exe has escaped them, over d1-apply's ${READBACK_BUDGET} budget - `
      + 'the apply would land and the read-back would then fail unevaluated. Split the input across two scripts'
    : null;
}

export function footer(fileName) {
  return ['-- Records this run. See db/migrations/024-data-script-runs.sql.',
    `INSERT INTO data_script_runs (filename) VALUES (${sqlLiteral(fileName)});`];
}

// ── input and output ─────────────────────────────────────────────────────────

// Every `*.json` in a directory, in filename order, parsed.
export function readJsonDir(dir) {
  if (!existsSync(dir)) throw new Error(`${dir} does not exist`);
  const files = readdirSync(dir).filter((f) => f.endsWith('.json')).sort();
  if (!files.length) throw new Error(`${dir} holds no .json file`);
  return files.map((f) => {
    try { return { file: f, doc: JSON.parse(readFileSync(path.join(dir, f), 'utf8')) }; }
    catch (e) { throw new Error(`${f}: not JSON (${e.message})`); }
  });
}

// The lines of an optional --notes file, as comment lines for the header.
export function noteLines(file) {
  if (!file) return [];
  return readFileSync(file, 'utf8').replace(/\r\n/g, '\n').replace(/\s+$/, '').split('\n')
    .map((l) => {
      const bad = asciiProblem(l);
      if (bad) throw new Error(`--notes: a line holds a character outside printable ASCII (${bad})`);
      return l ? `-- ${l}` : '--';
    });
}

// A data script's name sorts into the rebuild's one glob, so it is checked
// rather than trusted: `~NNN-kebab.sql`, or any name already in db/.
export function outNameProblem(fileName) {
  return /^[~a-z0-9][a-z0-9~-]*\.sql$/.test(fileName) ? null
    : `"${fileName}" is not a data-script name (lower-case, digits, hyphens, an optional leading ~, .sql)`;
}

// The whole script must be ASCII and LF, comments included (class-import).
export function scriptProblem(text) {
  if (text.includes('\r')) return 'the script holds a CR';
  const bad = text.split('\n').map((l, i) => [i + 1, asciiProblem(l)]).find(([, p]) => p);
  if (bad) return `line ${bad[0]} holds a character outside printable ASCII (${bad[1]})`;
  return readbackProblem(text);
}

// A title is one comment line. A newline in it would put text outside the comment.
export function titleProblem(title) {
  if (title === undefined) return null;
  if (typeof title !== 'string' || /[\r\n]/.test(title)) return '--title must be one line';
  const bad = asciiProblem(title);
  return bad ? `--title holds a character outside printable ASCII (${bad})` : null;
}

export function parseArgs(argv, valued = []) {
  const flags = {};
  const rest = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      if (valued.includes(a)) flags[a] = argv[++i];
      else flags[a] = true;
    } else rest.push(a);
  }
  return { flags, rest };
}
