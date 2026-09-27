// Sequence numbers: each migration number and each `~NNN` data-script number
// is used once.
//
// Both are "the next number", taken by whichever session gets there first, and
// parallel sessions each take the same one. Nothing read them for a collision:
// `git log --grep Renumber` shows `~NNN` scripts renumbered by hand after the
// fact at least five times (#1420 among them), and a data script's filename
// order is its execution order, so a collision is not cosmetic.
//
// Migrations are ONE sequence across `db/migrations/` and every group folder
// under it (`marvel/`, `tools/`): the numbers were assigned before the split
// into per-group databases and the split kept them. Measured 2026-09-27: 85
// migrations, 36 `~NNN` scripts, no number used twice.
//
// This fails AFTER a collision reaches a branch, not before: the ruleset does
// not require a branch to be up to date, so two PRs that each add `086` both
// pass alone. The second one's CI goes red only if it runs after the first
// merges. CLAUDE.md's freshness step before merging is what catches it in time.

import { readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Sequence numbers are used once'];

export const MIGRATION_NUMBER = /^(\d+)-.*\.sql$/;
export const LATE_TIER_NUMBER = /^~(\d+)-.*\.sql$/;

// [ 'NNN: a, b', ... ] for every number more than one name carries.
export function collisions(names, pattern) {
  const seen = {};
  for (const name of names) {
    const m = pattern.exec(name.split('/').pop());
    if (m) (seen[Number(m[1])] ??= []).push(name);
  }
  return Object.entries(seen)
    .filter(([, v]) => v.length > 1)
    .map(([n, v]) => `${n}: ${v.join(', ')}`);
}

// Every migration file, with its folder, across the root and each group folder.
function migrationFiles() {
  const root = join(repoRoot, 'db', 'migrations');
  const out = [];
  for (const entry of readdirSync(root)) {
    if (statSync(join(root, entry)).isDirectory()) {
      for (const f of readdirSync(join(root, entry))) out.push(`${entry}/${f}`);
    } else {
      out.push(entry);
    }
  }
  return out;
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Sequence numbers are used once');

  // The parser first, against a fixture, so a pattern that matched nothing
  // cannot pass the real checks below by finding no collisions.
  {
    const fixture = ['084-a.sql', 'marvel/085-b.sql', 'tools/085-c.sql', '086-d.sql', 'README.md'];
    const got = collisions(fixture, MIGRATION_NUMBER);
    check('the migration parser reads group folders and finds a collision across them',
      JSON.stringify(got) === JSON.stringify(['85: marvel/085-b.sql, tools/085-c.sql']), JSON.stringify(got));
    const late = collisions(['~007-a.sql', '~7-b.sql', '~008-c.sql', 'z-d.sql'], LATE_TIER_NUMBER);
    check('the ~NNN parser compares numbers, not spellings',
      JSON.stringify(late) === JSON.stringify(['7: ~007-a.sql, ~7-b.sql']), JSON.stringify(late));
  }

  const migrations = migrationFiles().filter((f) => MIGRATION_NUMBER.test(f.split('/').pop()));
  check('there are migrations to read', migrations.length > 0, `${migrations.length} migrations`);
  const migrationDups = collisions(migrations, MIGRATION_NUMBER);
  check('no two migrations share a number, across every group folder (renumber the one your branch added)',
    migrationDups.length === 0, migrationDups.join('; '));

  const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
  const late = readdirSync(dataDir).filter((f) => LATE_TIER_NUMBER.test(f));
  check('there are ~NNN data scripts to read', late.length > 0, `${late.length} scripts`);
  const lateDups = collisions(late, LATE_TIER_NUMBER);
  check('no two ~NNN data scripts share a number (renumber the one your branch added)',
    lateDups.length === 0, lateDups.join('; '));
}
