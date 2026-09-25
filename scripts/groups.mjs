#!/usr/bin/env node
// Which group owns a path or a table - the reader for groups.json.
//
//   node scripts/groups.mjs --check          every path and table has one owner (CI runs this)
//   node scripts/groups.mjs <path>...        print the group that owns each path
//   node scripts/groups.mjs --affected <revs> which groups a diff touches, as
//                                            name=true|false lines for $GITHUB_OUTPUT
//
// WHY. The repo holds three unrelated groups - Palladium/Rifts, Marvel, and the
// tools - and the point of naming them is that two sessions can work on two of
// them at once without colliding, and that a change to one cannot break
// another. CI decides which suites a change needs from this ownership, so an
// owner that is missing or wrong is a suite that silently does not run.
// groups.json says how a path is matched and why an unsure path is shared.
//
// WHAT --check HOLDS, and each is a way this file goes stale without anyone
// noticing:
//
//   1. every file git knows about has an owner - including untracked files that
//      are not ignored, so a new directory fails here before it is committed
//   2. no entry is listed twice, in one group or across two
//   3. every entry still matches a file, so a moved path cannot leave a dead
//      rule behind that looks like it covers something
//   4. every table a schema file creates (db/schema.sql, and each group's
//      db/schema-<group>.sql) belongs to exactly one group, every table a group
//      lists is one a schema file creates, and a group's own schema file
//      creates only that group's tables
//   5. every app in apps/manifest.json sits in the group its tile is shown in
//   6. no file under functions/ names another group's table in SQL, except
//      the pairs groups.json lists in cross_group_tables - and each of those
//      is still used. This is what makes a database per group possible: a
//      group whose code reaches only its own tables can be given only them.
//
// Read-only. Exits 1 on any failure and names each one.

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

function loadGroups(root = repoRoot) {
  return JSON.parse(readFileSync(join(root, 'groups.json'), 'utf8')).groups;
}

// Does one entry cover one repo-relative, forward-slashed path?
function entryMatches(entry, path) {
  if (entry === '*') return !path.includes('/');
  if (entry.endsWith('/')) return path.startsWith(entry);
  return path === entry;
}

// The owning group's id, by the longest matching entry, or null.
export function ownerOf(path, groups) {
  let best = null;
  let bestLen = -1;
  for (const [id, g] of Object.entries(groups)) {
    for (const entry of g.paths) {
      // '*' is the most general entry there is, so it loses to any other match.
      const len = entry === '*' ? 0 : entry.length;
      if (len > bestLen && entryMatches(entry, path)) { best = id; bestLen = len; }
    }
  }
  return best;
}

// Table names a schema file creates, virtual tables included.
export function schemaTables(sql) {
  const re = /^\s*CREATE\s+(?:VIRTUAL\s+)?TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?["`]?(\w+)/gim;
  return [...sql.matchAll(re)].map((m) => m[1]);
}

function repoFiles(root = repoRoot) {
  const out = execFileSync('git', ['ls-files', '--cached', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' });
  return [...new Set(out.split('\n').filter(Boolean))];
}

export function check(root = repoRoot) {
  const groups = loadGroups(root);
  const files = repoFiles(root);
  const failures = [];

  // 2. duplicates
  const seen = new Map();
  for (const [id, g] of Object.entries(groups)) {
    for (const entry of g.paths) {
      if (seen.has(entry)) failures.push(`path entry "${entry}" is listed in ${seen.get(entry)} and again in ${id}`);
      else seen.set(entry, id);
    }
  }

  // 1. unowned files
  const unowned = files.filter((f) => ownerOf(f, groups) === null);
  for (const f of unowned) failures.push(`no group owns ${f} - add it, or its directory, to groups.json`);

  // 3. dead entries
  for (const [entry, id] of seen) {
    if (!files.some((f) => entryMatches(entry, f))) failures.push(`${id} lists "${entry}", which matches no file`);
  }

  // 4. tables, from db/schema.sql and every group's own db/schema-<group>.sql
  const schemaFiles = ['db/schema.sql', ...files.filter((f) => /^db\/schema-[a-z]+\.sql$/.test(f))];
  const createdIn = new Map();
  for (const sf of schemaFiles) {
    for (const t of schemaTables(readFileSync(join(root, sf), 'utf8'))) {
      createdIn.set(t, [...(createdIn.get(t) ?? []), sf]);
    }
  }
  const created = [...createdIn.keys()];
  const tableOwner = new Map();
  for (const [id, g] of Object.entries(groups)) {
    for (const t of g.tables ?? []) {
      if (tableOwner.has(t)) failures.push(`table ${t} is listed in ${tableOwner.get(t)} and again in ${id}`);
      else tableOwner.set(t, id);
    }
  }
  for (const t of created) if (!tableOwner.has(t)) failures.push(`${createdIn.get(t).join(', ')} creates ${t}, which no group lists in groups.json`);
  for (const [t, id] of tableOwner) if (!created.includes(t)) failures.push(`${id} lists table ${t}, which no schema file creates`);
  // A group's own schema file builds that group's database, so it may create
  // only that group's tables - and schema_migrations, which every database has.
  for (const [t, sfs] of createdIn) {
    for (const sf of sfs) {
      const g = sf.match(/^db\/schema-([a-z]+)\.sql$/)?.[1];
      if (g && t !== 'schema_migrations' && tableOwner.get(t) !== g) {
        failures.push(`${sf} creates ${t}, which is ${tableOwner.get(t) ?? 'no group'}'s - it builds the ${g} database`);
      }
    }
    if (sfs.length > 1 && t !== 'schema_migrations') failures.push(`${t} is created in ${sfs.join(' and ')} - one database per table`);
  }

  // 5. manifest tiles
  const manifest = JSON.parse(readFileSync(join(root, 'apps/manifest.json'), 'utf8'));
  for (const app of manifest.apps) {
    if (!app.slug) continue;
    const id = ownerOf(`apps/${app.slug}/index.html`, groups);
    const want = groups[id]?.manifest_group;
    if (want !== app.group) failures.push(`apps/manifest.json shows ${app.slug} under "${app.group}", but groups.json gives it to ${id} (manifest group "${want}")`);
  }

  // 6. server code stays in its group's tables
  const allowed = JSON.parse(readFileSync(join(root, 'groups.json'), 'utf8')).cross_group_tables ?? {};
  for (const f of files.filter((p) => p.startsWith('functions/') && p.endsWith('.js'))) {
    const id = ownerOf(f, groups);
    for (const t of tablesNamed(readFileSync(join(root, f), 'utf8'), tableOwner)) {
      if (tableOwner.get(t) === id || tableOwner.get(t) === 'shared') continue;
      if ((allowed[f] ?? []).includes(t)) continue;
      failures.push(`${f} (${id}) names ${tableOwner.get(t)}'s table ${t} - move the code, or list it in groups.json cross_group_tables with the reason`);
    }
  }
  for (const [f, ts] of Object.entries(allowed)) {
    if (f === '//') continue;
    if (!files.includes(f)) { failures.push(`cross_group_tables names ${f}, which does not exist`); continue; }
    const named = tablesNamed(readFileSync(join(root, f), 'utf8'), tableOwner);
    for (const t of ts) if (!named.has(t)) failures.push(`cross_group_tables lets ${f} use ${t}, and it no longer does - remove the exception`);
  }

  return { failures, files: files.length, entries: seen.size, tables: created.length };
}

// Known tables a source file names where SQL would: after FROM, JOIN, INTO,
// UPDATE or TABLE. Comments count too, deliberately - a stray reference in a
// comment is cheap to reword, and stripping comments from JS reliably is not.
function tablesNamed(src, tableOwner) {
  const named = new Set();
  const re = /\b(?:FROM|JOIN|INTO|UPDATE|TABLE(?:\s+IF\s+NOT\s+EXISTS)?)\s+[`"]?([A-Za-z_]\w*)/g;
  for (const m of src.matchAll(re)) if (tableOwner.has(m[1])) named.add(m[1]);
  return named;
}

// Which groups' suites a change needs. `revs` go to `git diff` as they are:
// CI passes `HEAD^1 HEAD`, the pull request's merge commit against the base it
// merges into; a person on a branch passes `origin/main...HEAD`.
//
// A group is affected when a file it owns changed, and EVERY group is affected
// when a shared file changed - shared/, the middleware, the schema, the
// workflows - because that is how one group's change reaches another's. A
// process file turns nothing on (groups.json says why). A diff of nothing but
// process files runs only what every pull request runs regardless.
// Anything that stops the diff being read turns every group on: a filter that
// fails closed skips the suite that would have said what broke.
function affected(revs, root = repoRoot) {
  const all = (why) => ({ groups: { palladium: true, marvel: true, tools: true }, why: [why] });
  let out;
  try {
    out = execFileSync('git', ['diff', '--name-only', '--no-renames', ...revs], { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    return all(`could not diff ${revs.join(' ') || '(no revs)'} - running every group: ${String(e.stderr || e.message).trim().split('\n')[0]}`);
  }
  const files = out.split('\n').filter(Boolean);
  if (files.length === 0) return all('the diff is empty - running every group rather than none');
  const groups = loadGroups(root);
  const result = { palladium: false, marvel: false, tools: false };
  const why = [];
  for (const f of files) {
    const id = ownerOf(f, groups);
    if (id === null || id === 'shared') {
      why.push(`${f}: ${id ?? 'no owner'} - every group`);
      for (const g of Object.keys(result)) result[g] = true;
    } else if (id === 'process') {
      why.push(`${f}: process - no group; the checks every pull request runs read it`);
    } else {
      why.push(`${f}: ${id}`);
      result[id] = true;
    }
  }
  return { groups: result, why };
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const args = process.argv.slice(2);
  if (args[0] === '--check') {
    const { failures, files, entries, tables } = check();
    for (const f of failures) console.log(`FAIL  ${f}`);
    if (failures.length) {
      console.log(`\ngroups.json: ${failures.length} problem(s)`);
      process.exit(1);
    }
    console.log(`groups.json: ${files} files and ${tables} tables, each with one owner, from ${entries} entries`);
  } else if (args[0] === '--affected') {
    const { groups, why } = affected(args.slice(1));
    for (const line of why) console.error(line);
    for (const [id, on] of Object.entries(groups)) console.log(`${id}=${on}`);
  } else if (args.length) {
    const groups = loadGroups();
    for (const p of args) console.log(`${ownerOf(p.replace(/\\/g, '/'), groups) ?? '(none)'}\t${p}`);
  } else {
    console.log('usage: node scripts/groups.mjs --check | --affected <git diff revs> | <path>...');
    process.exit(2);
  }
}
