#!/usr/bin/env node
// Which group owns a path or a table - the reader for groups.json.
//
//   node scripts/groups.mjs --check          every path and table has one owner (CI runs this)
//   node scripts/groups.mjs <path>...        print the group that owns each path
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
//   4. every table db/schema.sql creates belongs to exactly one group, and
//      every table a group lists is one the schema creates
//   5. every app in apps/manifest.json sits in the group its tile is shown in
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

  // 4. tables
  const created = schemaTables(readFileSync(join(root, 'db/schema.sql'), 'utf8'));
  const tableOwner = new Map();
  for (const [id, g] of Object.entries(groups)) {
    for (const t of g.tables ?? []) {
      if (tableOwner.has(t)) failures.push(`table ${t} is listed in ${tableOwner.get(t)} and again in ${id}`);
      else tableOwner.set(t, id);
    }
  }
  for (const t of created) if (!tableOwner.has(t)) failures.push(`db/schema.sql creates ${t}, which no group lists in groups.json`);
  for (const [t, id] of tableOwner) if (!created.includes(t)) failures.push(`${id} lists table ${t}, which db/schema.sql does not create`);

  // 5. manifest tiles
  const manifest = JSON.parse(readFileSync(join(root, 'apps/manifest.json'), 'utf8'));
  for (const app of manifest.apps) {
    if (!app.slug) continue;
    const id = ownerOf(`apps/${app.slug}/index.html`, groups);
    const want = groups[id]?.manifest_group;
    if (want !== app.group) failures.push(`apps/manifest.json shows ${app.slug} under "${app.group}", but groups.json gives it to ${id} (manifest group "${want}")`);
  }

  return { failures, files: files.length, entries: seen.size, tables: created.length };
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
  } else if (args.length) {
    const groups = loadGroups();
    for (const p of args) console.log(`${ownerOf(p.replace(/\\/g, '/'), groups) ?? '(none)'}\t${p}`);
  } else {
    console.log('usage: node scripts/groups.mjs --check | <path>...');
    process.exit(2);
  }
}
