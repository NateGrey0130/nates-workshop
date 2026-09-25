#!/usr/bin/env node
// Build a local D1 from the repo, from nothing, into a directory.
//
//   node scripts/build-local-d1.mjs <persist-dir>                   schema + seed + every data script
//   node scripts/build-local-d1.mjs <persist-dir> --repo <checkout>  build another tree's files
//
// What "a clean build" means here: db/schema.sql, db/seed-catalogs.sql, then
// every apps/character-creator/db/*.sql in sorted order (filename order is
// execution order), concatenated into ONE bootstrap file and handed to
// wrangler ONCE. One wrangler per file was hours on this machine, which is
// why test/regression.mjs has always built this way. It now imports this
// builder, so the two cannot drift: what regression calls a clean build is
// what a book worktree starts from (scripts/book-worktree.mjs). 166 s here,
// measured 2026-09-25.
//
// Files marked `-- local-only` (seed-dev.sql: a test campaign and character)
// are skipped, as regression always has: their inserts are unguarded, and
// seed-dev's collide with a data script's gear slug in a full build
// ("UNIQUE constraint failed: gear.slug", measured 2026-09-25). There is
// deliberately no flag to include them.
//
// The result is wrangler's own state layout under <persist-dir>, the same
// thing `--persist-to <persist-dir>` reads, so every script that honours
// WORKSHOP_LOCAL_D1 reads it as-is. rebuild-local.mjs is the other builder
// and is NOT this: it replays into node's own SQLite in-process, which is
// faster and legible per file but is not the engine D1 runs (it accepts a
// fifteen-term compound SELECT that D1 refuses).

import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

// Reused by regression.mjs, which adds its own run marker to `extra`.
export function bootstrapSql(repoRoot, { extra = [] } = {}) {
  const parts = [
    readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
    readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
  ];
  const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
  for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
    const sql = readFileSync(join(dataDir, f), 'utf8');
    if (/^--\s*local-only\b/m.test(sql)) continue;
    parts.push(sql);
  }
  parts.push(...extra);
  return parts.join('\n;\n');
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const args = process.argv.slice(2);
  const dir = args.find((a, i) => !a.startsWith('--') && args[i - 1] !== '--repo');
  if (!dir) { console.error('usage: node scripts/build-local-d1.mjs <persist-dir> [--repo <checkout>]'); process.exit(1); }
  const ri = args.indexOf('--repo');
  const repoRoot = ri === -1 ? join(dirname(fileURLToPath(import.meta.url)), '..') : resolve(args[ri + 1]);
  mkdirSync(dir, { recursive: true });
  const file = join(dir, 'bootstrap.sql');
  writeFileSync(file, bootstrapSql(repoRoot), 'utf8');
  const started = Date.now();
  const r = spawnSync('npx', ['wrangler', 'd1', 'execute', 'DB', '--local', '--persist-to', dir, '--file', file],
    { cwd: repoRoot, shell: true, encoding: 'utf8', maxBuffer: 1e9 });
  const secs = Math.round((Date.now() - started) / 1000);
  if (r.status !== 0) {
    console.error(`build failed after ${secs}s:\n${((r.stderr || '') + (r.stdout || '')).slice(-1500)}`);
    process.exit(1);
  }
  console.log(`built ${dir} from the repo in ${secs}s`);
}
