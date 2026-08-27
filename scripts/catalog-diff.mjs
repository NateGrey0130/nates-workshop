// What does a book have that the catalog does not, and where do they disagree?
//
//   node scripts/catalog-diff.mjs --table psionic_powers \
//        --entries .cache/books/rue/psionics.json --compare category,isp
//
// `--entries` is JSON: [{ "name": "...", "category": "...", "isp": 6 }, ...]
// straight out of whatever parsed the book. Keys named in `--compare` are
// compared against the catalog columns of the same name.
//
// Four buckets out, and the distinction between them is the whole point:
//
//   DISAGREE  found, a field differs        -> candidate corrections
//   MISSING   not found, nearest shown      -> check for a false gap FIRST
//   MATCHED   found, everything agrees      -> nothing to do
//   EXTRA     catalog has it, book does not -> other books, or a bad citation
//
// Nothing here writes anything. It prints, and a human decides. Every time
// that judgement was skipped during the RUE import, the confident answer was
// wrong: 21 "missing" psionic powers were 16, 23 "wrong categories" were 0,
// and 5 "missing" spells were 0.
import { readFileSync } from 'node:fs';
import { diffCatalog, vocabularyWarnings } from './catalog-match-lib.mjs';
import { d1Query, targetFromArgv } from './d1-query-lib.mjs';

const argv = process.argv.slice(2);
const arg = (name, dflt) => {
  const i = argv.indexOf(`--${name}`);
  return i === -1 ? dflt : argv[i + 1];
};
const table = arg('table');
const entriesPath = arg('entries');
const compare = (arg('compare', '') || '').split(',').filter(Boolean);
// This one defaults to --local: a diff is exploratory and should not need
// the network, where drift-check is asking about production by nature. The
// default is deliberately NOT flipped — an offline diff should work — but a
// --local answer now carries production's row count beside it (see below),
// because the failure this guards against is not a wrong default. It is a
// number quoted without its provenance, into a decision that costs money.
const target = argv.includes('--remote') ? '--remote' : '--local';
const nameKey = arg('name-key', 'name');

if (!table || !entriesPath) {
  console.error('usage: catalog-diff.mjs --table <t> --entries <file.json> '
    + '[--compare a,b] [--name-key name] [--local|--remote]');
  process.exit(2);
}

const d1 = (sql) => d1Query(sql, { target });

const entries = JSON.parse(readFileSync(entriesPath, 'utf8'));
// The whole table. Filtering in SQL by a system/book column once hid 129 rows
// stored with the column NULL and reported 225 missing where 106 were.
const rows = d1(`SELECT * FROM ${table}`);

const fields = Object.fromEntries(compare.map((f) => [f, {
  book: (e) => e[f],
  row: (r) => r[f],
  // Numeric when both sides look numeric, so 6 and "6" do not read as a
  // disagreement; otherwise a trimmed string compare.
  compare: (a, b) => (Number.isFinite(Number(a)) && Number.isFinite(Number(b)))
    ? Number(a) === Number(b)
    : String(a).trim().toLowerCase() === String(b).trim().toLowerCase(),
}]));

const d = diffCatalog({
  entries, rows,
  nameOfEntry: (e) => e[nameKey],
  fields,
});

const pad = (s, n) => String(s ?? '').padEnd(n);
console.log(`${table} (${target}): ${rows.length} rows | book: ${entries.length} entries`);

// A --local answer gets a second opinion, because the number this script
// produces is the number that decides what gets extracted, and phase 4 is the
// only step in the pipeline that costs money.
//
// CLAUDE.md's own three-things-that-fail-late list ends with "--local is not a
// mirror of production. It accumulates." It does: a previous session's local
// held 327 skills where production had 324, and this worktree's held 336
// against production's 333 on the day this was written — three rows a diff
// would have reported as present when they are not.
//
// Advisory in both directions. It never changes the exit code and never blocks:
// an offline diff is a legitimate thing to run, and a network failure here must
// not cost you the diff you already computed.
if (target === '--local') {
  let live = null;
  try {
    live = d1Query(`SELECT count(*) AS n FROM ${table}`, { target: '--remote' })[0]?.n ?? null;
  } catch { /* offline, unauthenticated, or D1 unreachable — say so, do not fail */ }
  if (live === null) {
    console.log('  ?? could not reach production — this row count has no second opinion');
  } else if (Number(live) === rows.length) {
    console.log(`  local agrees with production (${live} rows)`);
  } else {
    const delta = rows.length - Number(live);
    console.log(`  !! production has ${live} — local is ${Math.abs(delta)} row(s) `
      + `${delta > 0 ? 'AHEAD' : 'BEHIND'}, so this diff is not answering about production`);
    console.log('     re-run with --remote before spending the answer on an extraction');
  }
}

console.log(`matched ${d.matched.length}  disagree ${d.disagree.length}  `
  + `missing ${d.missing.length}  extra ${d.extra.length}`);

const warnings = vocabularyWarnings(d);
if (warnings.length) {
  console.log('\n!! VOCABULARY WARNING');
  for (const w of warnings) console.log('   ' + w.message);
}

if (d.disagree.length) {
  console.log(`\n--- DISAGREE (${d.disagree.length}) — candidate corrections ---`);
  for (const x of d.disagree) {
    const diffs = x.diffs.map((y) => `${y.field}: catalog ${y.catalog} -> book ${y.book}`);
    console.log(`  ${pad(x.entry[nameKey], 34)} ${diffs.join('; ')}`);
  }
}

if (d.missing.length) {
  console.log(`\n--- MISSING (${d.missing.length}) — check each against its nearest before adding ---`);
  for (const m of d.missing) {
    const n = m.nearest;
    console.log(`  ${pad(m.entry[nameKey], 34)}`
      + (n ? ` ~ "${n.row[Object.keys(n.row).includes('name') ? 'name' : 0]}" (distance ${n.distance})` : ' (no candidate)'));
  }
  console.log('  A small distance is not permission to merge: Push/Punch is 2 and they');
  console.log('  are different; Animate/Control Dead vs Animate and Control Dead is 4');
  console.log('  and they are the same.');
}

const byVariant = [...d.matched, ...d.disagree].filter((x) => x.how === 'variant');
if (byVariant.length) {
  console.log(`\n--- matched only by an alias (${byVariant.length}) — naming drift ---`);
  for (const x of byVariant) console.log(`  ${pad(x.entry[nameKey], 34)} -> ${x.row.name}`);
}

if (d.extra.length && argv.includes('--show-extra')) {
  console.log(`\n--- EXTRA (${d.extra.length}) — in catalog, not in this book ---`);
  for (const r of d.extra) console.log(`  ${r.name}`);
}
