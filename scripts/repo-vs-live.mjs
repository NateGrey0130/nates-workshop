// Can the repo rebuild the live catalog, row for row?
//
//   node scripts/repo-vs-live.mjs                 # all catalogs
//   node scripts/repo-vs-live.mjs --table gear    # just one
//
// drift-check asks whether the repo and the live database agree about
// BOOKKEEPING - which migrations and data scripts have run - and every script
// can be recorded in both places while the rows differ. It also demands that
// every published CLASS be creatable from the repo, and nothing made the same
// demand of catalog rows.
//
// That gap has now cost twice:
//
//   * 2 classes and 169 catalog rows once existed only in production, because
//     the catalog editor and the importer's confirm step write straight to D1.
//     The `restore-*.sql` scripts came out of finding that by hand.
//
//   * Six psionic merges done through the editor left the repo creating both
//     halves of every pair, so a rebuilt database came up with six duplicates
//     and four gear rows missing. Found only because a README count was pinned
//     and happened to disagree.
//
// This asks the question directly: build from the repo into a scratch database,
// then diff the NAMES against live. Counts are not enough - gear was off by one
// row and that one row hid seven disagreements going both ways.
//
// Slow (it builds a database), read-only, and it never touches production
// beyond SELECTs.
import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, readdirSync, mkdtempSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { repoRoot, d1Query } from './d1-query-lib.mjs';

const only = (() => {
  const i = process.argv.indexOf('--table');
  return i === -1 ? null : process.argv[i + 1];
})();

const TABLES = [
  ['skills', 'name'],
  ['spells', 'name'],
  ['psionic_powers', 'name'],
  ['gear', 'name'],
];

const appDir = join(repoRoot, 'apps', 'character-creator');
const state = mkdtempSync(join(tmpdir(), 'repo-vs-live-'));
const wrangler = (args) => spawnSync('npx', ['wrangler', ...args],
  { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 300000, maxBuffer: 1e9 });

try {
  // Built exactly the way test/regression.mjs builds it: schema, seed, then
  // every data script in sorted order, skipping the local-only ones. One
  // concatenated file rather than 120 CLI invocations.
  const parts = [
    readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
    readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
  ];
  for (const f of readdirSync(join(appDir, 'db')).filter((x) => x.endsWith('.sql')).sort()) {
    const sql = readFileSync(join(appDir, 'db', f), 'utf8');
    if (/^--\s*local-only\b/m.test(sql)) continue;
    parts.push(sql);
  }
  const bootstrap = join(state, 'bootstrap.sql');
  writeFileSync(bootstrap, parts.join('\n;\n'), 'utf8');

  process.stdout.write('building a database from the repo... ');
  const applied = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state,
    '--file', bootstrap]);
  if (applied.status !== 0) {
    console.log('FAILED');
    console.error((applied.stderr || applied.stdout || '').slice(-800));
    process.exit(1);
  }
  console.log('ok\n');

  const fromBuild = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state,
      '--json', '--command', `"${sql}"`]);
    const out = r.stdout || '';
    return JSON.parse(out.slice(out.indexOf('['))).flatMap((b) => b.results || []);
  };

  let problems = 0;
  for (const [table, col] of TABLES.filter(([t]) => !only || t === only)) {
    const repo = fromBuild(`SELECT ${col} FROM ${table}`).map((r) => r[col]);
    const live = d1Query(`SELECT ${col} FROM ${table}`).map((r) => r[col]);
    const liveSet = new Set(live), repoSet = new Set(repo);
    const onlyRepo = [...new Set(repo.filter((n) => !liveSet.has(n)))];
    const onlyLive = [...new Set(live.filter((n) => !repoSet.has(n)))];
    problems += onlyRepo.length + onlyLive.length;

    const verdict = onlyRepo.length + onlyLive.length ? 'DIFFERS' : 'matches';
    console.log(`${table.padEnd(16)} repo ${String(repo.length).padStart(4)}  `
      + `live ${String(live.length).padStart(4)}   ${verdict}`);
    for (const n of onlyLive) {
      console.log(`   ONLY LIVE  ${n}`);
    }
    for (const n of onlyRepo) {
      console.log(`   ONLY REPO  ${n}`);
    }
  }

  console.log('');
  if (!problems) {
    console.log('The repo rebuilds the live catalog exactly.');
  } else {
    console.log(`${problems} row(s) differ.`);
    console.log('  ONLY LIVE  = added through the app and never written back.');
    console.log('               Export it into a data script, as restore-*.sql did.');
    console.log('  ONLY REPO  = merged or renamed away in the app, and the repo');
    console.log('               still creates the old row. See');
    console.log('               zz-merge-psionic-duplicates.sql for the shape:');
    console.log('               move redirects, add a forwarding one, then delete.');
  }
  process.exit(problems ? 1 : 0);
} finally {
  rmSync(state, { recursive: true, force: true });
}
