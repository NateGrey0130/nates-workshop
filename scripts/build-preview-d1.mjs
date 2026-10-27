#!/usr/bin/env node
// Rebuild the three PREVIEW D1 databases from the repo, from nothing.
//
//   node scripts/build-preview-d1.mjs                  all three groups
//   node scripts/build-preview-d1.mjs --db tools       one group (palladium|marvel|tools)
//   node scripts/build-preview-d1.mjs --name <db>      the database for --db, by name
//
// WHAT THEY ARE FOR: pull-request previews, which wrangler.jsonc's env.preview
// binds to them. Production has the real databases; until these existed a
// preview deployment could only read and write production's.
//
// WHAT GOES IN: the same clean build scripts/build-local-d1.mjs makes, against
// --remote on the preview names instead of --local --persist-to.
//   palladium   db/schema.sql + db/seed-catalogs.sql + every
//               apps/character-creator/db/*.sql not marked `-- local-only`,
//               as ONE file (bootstrapSql()). The full catalog, no players.
//   marvel      db/schema-marvel.sql only. Its catalog (msh_power_text,
//               msh_book_text) is never in the repo, so it starts EMPTY.
//   tools       db/schema-tools.sql only. ff_brands and ff_filaments start
//               EMPTY: scripts/ofd-refresh.mjs fills them, and it targets the
//               DB_TOOLS binding of wrangler.jsonc (production) and cannot be
//               pointed at a database by name, so this script does NOT run it.
// NO PLAYER DATA, and no production row of any kind: nothing here reads
// production. seed-dev.sql is `-- local-only` and is skipped as it is locally.
//
// "FROM NOTHING" means every table, view and trigger already in the target is
// dropped first (D1's own _cf_* tables excepted), so a rebuild after a catalog
// change lands the repo's state, not the sum of every build.
//
// THE GUARD: a target whose name does not end in `-preview`, or that matches
// any database_name wrangler.jsonc binds at its top level (production's; its
// env.preview binds these three), is REFUSED before wrangler is started.
// And wrangler never sees wrangler.jsonc: every call runs with `-c` on a
// scratch config naming the preview databases alone, so a production
// database is not reachable from this script by any argument.
//
// The ids below are the ones `wrangler d1 create` printed on 2026-10-26; they
// are recorded in SETUP.md too, for the binding.

import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { bootstrapSql } from './build-local-d1.mjs';
import { groupDatabases, repoRoot, runWrangler } from './d1-query-lib.mjs';
import { readWranglerConfig } from './groups.mjs';
import { statementsKeepingTriggers } from './sql-statements.mjs';

const PREVIEW_DATABASES = {
  palladium: { binding: 'DB', name: 'nates-workshop-media-preview', id: '1c5f3ddb-ae56-4be3-b13e-f34eae720405' },
  marvel: { binding: 'DB_MARVEL', name: 'nates-workshop-marvel-preview', id: '750a8ae5-eb89-4625-996f-8d84a86165a0' },
  tools: { binding: 'DB_TOOLS', name: 'nates-workshop-tools-preview', id: '329ff05e-e217-4128-8817-33c274696430' },
};

/** Why `name` may not be built, or null when it may. */
function refusal(name, wranglerConfig) {
  if (!/-preview$/.test(name || '')) return `${name || '(none)'} does not end in -preview`;
  // The top level only: env.preview binds these very databases, on purpose.
  const production = (wranglerConfig.d1_databases ?? []).map((d) => d.database_name);
  if (production.includes(name)) return `${name} is a database wrangler.jsonc binds for production`;
  return null;
}

function fail(msg) { console.error(msg); process.exit(1); }

const args = process.argv.slice(2);
const dbi = args.indexOf('--db');
const ni = args.indexOf('--name');
const only = dbi === -1 ? null : args[dbi + 1];
if (only && !PREVIEW_DATABASES[only]) fail(`--db takes one of: ${Object.keys(PREVIEW_DATABASES).join(', ')} (got ${only})`);
if (ni !== -1 && !only) fail('--name needs --db, to say which group\'s schema goes in it');

const targets = Object.entries(PREVIEW_DATABASES)
  .filter(([g]) => !only || g === only)
  .map(([group, d]) => ({ group, ...d, ...(ni !== -1 ? { name: args[ni + 1], id: null } : {}) }));

const wranglerConfig = readWranglerConfig(repoRoot);
for (const t of targets) {
  const why = refusal(t.name, wranglerConfig);
  if (why) fail(`REFUSED: ${why}. This script builds preview databases only.`);
}
const schemas = Object.fromEntries(groupDatabases(repoRoot).map((g) => [g.group, g.schema]));
for (const t of targets) if (!schemas[t.group]) fail(`${t.group}: no schema file in the repo`);

// The scratch config: the preview databases under the production bindings'
// names, and nothing else. A --name target with no recorded id is resolved by
// wrangler from its name.
const scratch = mkdtempSync(join(tmpdir(), 'preview-d1-'));
const config = join(scratch, 'wrangler.jsonc');
writeFileSync(config, JSON.stringify({
  name: 'nates-workshop-preview-d1-build',
  compatibility_date: '2026-04-19',
  d1_databases: targets.map((t) => ({ binding: t.binding, database_name: t.name, ...(t.id ? { database_id: t.id } : {}) })),
}, null, 2));

function wrangler(argv) {
  const r = runWrangler([...argv, '-c', config], { input: '' });
  return { ok: r.status === 0, out: (r.stdout || '') + (r.stderr || '') };
}
function query(binding, sql) {
  const r = wrangler(['d1', 'execute', binding, '--remote', '--json', '--command', sql]);
  if (!r.ok) fail(`query on ${binding} failed:\n${r.out.slice(-1500)}`);
  return JSON.parse(r.out.slice(r.out.indexOf('[')));
}
const sq = (s) => `'${s.replace(/'/g, "''")}'`;

const started = Date.now();
for (const t of targets) {
  const t0 = Date.now();
  console.log(`\n== ${t.group}: ${t.name} (${t.binding})`);

  // 1. Empty it. Triggers first: dropping a table DELETEs its rows, and a
  //    delete trigger that writes an FTS table already dropped fails the
  //    whole file (measured on msh_journal_entries, 2026-10-26). Then views,
  //    then virtual tables (an FTS table takes its shadow tables with it, and
  //    dropping a shadow table directly is refused), then the rest.
  const all = query(t.binding, "SELECT type, name, sql LIKE 'CREATE VIRTUAL%' AS virt FROM sqlite_master WHERE type IN ('trigger','table','view') AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf_%' ORDER BY name")[0].results;
  const virtuals = all.filter((o) => o.virt).map((o) => o.name);
  const rank = (o) => ({ trigger: 0, view: 1 }[o.type] ?? (o.virt ? 2 : 3));
  // A table goes before every table its foreign keys name: dropping a child
  // whose parent is already gone fails with `no such table: main.<parent>`
  // even under defer_foreign_keys (msh_campaigns, 2026-10-26).
  const fks = query(t.binding, "SELECT m.name AS child, f.\"table\" AS parent FROM sqlite_master m, pragma_foreign_key_list(m.name) f WHERE m.type = 'table' AND m.name NOT LIKE '_cf_%' AND m.name NOT LIKE 'sqlite_%'")[0].results;
  const depth = new Map();
  const depthOf = (n, seen = new Set()) => {
    if (depth.has(n)) return depth.get(n);
    if (seen.has(n)) return 0;
    seen.add(n);
    const d = Math.max(0, ...fks.filter((f) => f.parent === n && f.child !== n).map((f) => depthOf(f.child, seen) + 1));
    depth.set(n, d);
    return d;
  };
  const objs = all.filter((o) => o.type !== 'table' || o.virt || !virtuals.some((v) => o.name.startsWith(`${v}_`)))
    .sort((a, b) => rank(a) - rank(b) || (a.type === 'table' ? depthOf(a.name) - depthOf(b.name) : 0));
  if (objs.length) {
    const drops = ['PRAGMA defer_foreign_keys = on;',
      ...objs.map((o) => `DROP ${o.type.toUpperCase()} IF EXISTS "${o.name}";`)];
    // --command, not --file: D1's import endpoint answered this list with
    // `{"D1_RESET_DO":true}` and applied none of it (2026-10-26).
    query(t.binding, drops.join(' '));
    const left = query(t.binding, "SELECT count(*) AS n FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf_%'")[0].results[0].n;
    if (left !== 0) fail(`${t.name}: ${left} objects survived the drop`);
    console.log(`dropped ${objs.length} triggers, views and tables`);
  } else {
    console.log('already empty');
  }

  // 2. Build it. Palladium's bootstrap is re-split into statements and
  //    re-joined: bootstrapSql() joins its files with `\n;\n`, which leaves an
  //    empty statement between every two files, and D1's import endpoint
  //    refuses one (`SQL code did not contain a statement.`, or
  //    `{"D1_RESET_DO":true}`), where --local runs it. Two files that import
  //    alone failed together until this (2026-10-26).
  const file = join(scratch, `${t.group}-bootstrap.sql`);
  writeFileSync(file, t.group === 'palladium'
    ? statementsKeepingTriggers(bootstrapSql(repoRoot)).map((s) => `${s};\n`).join('')
    : readFileSync(join(repoRoot, schemas[t.group]), 'utf8'), 'utf8');
  const r = wrangler(['d1', 'execute', t.binding, '--remote', '--yes', '--file', file]);
  if (!r.ok) fail(`build of ${t.name} failed:\n${r.out.slice(-1500)}`);

  // 3. Read it back: every table and its row count.
  const tables = query(t.binding, "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf_%' ORDER BY name")[0].results.map((x) => x.name);
  const counts = query(t.binding, tables.map((n) => `SELECT ${sq(n)} AS t, count(*) AS n FROM "${n}";`).join(' '))
    .map((b) => b.results[0]);
  for (const c of counts) console.log(`  ${String(c.n).padStart(7)}  ${c.t}`);
  console.log(`${t.name}: ${tables.length} tables, ${counts.reduce((a, c) => a + c.n, 0)} rows, ${Math.round((Date.now() - t0) / 1000)}s`);
}
console.log(`\nbuilt ${targets.length} preview database(s) from the repo in ${Math.round((Date.now() - started) / 1000)}s`);
