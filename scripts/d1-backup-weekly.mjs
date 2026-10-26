// The scheduled half of d1-backup.mjs: all three databases, one dated folder,
// a rotation, and a record of how it went.
//
//   node scripts/d1-backup-weekly.mjs                     back up, to the default root
//   node scripts/d1-backup-weekly.mjs D:\elsewhere        back up, to another root
//   node scripts/d1-backup-weekly.mjs --check [<root>]    how old is the newest good one
//
// Each run writes <root>\<YYYY-MM-DD>\<palladium|marvel|tools>\<table>.json by
// running d1-backup.mjs once per database, --remote unless --local is passed.
// The root defaults to C:\Users\natha\Backups\nates-workshop and must be
// OUTSIDE the repo: the repo is public, and a backup is everyone's campaign
// notes. The script refuses a root inside it.
//
// A run that backed up every table of every database writes COMPLETE.json in
// its dated folder, and only then deletes dated folders past the newest KEEP.
// A run with any failure deletes nothing, so a broken week never rotates a
// good one away. Either way it writes <root>\last-run.json: the date, each
// database's exit status, table count and row count, and the run's own exit.
// Each database's console output is kept beside its folder as <db>.log,
// because a scheduled task's console goes nowhere.
//
// WHY --check EXISTS. d1-backup.mjs used to say "manual on purpose: a scheduled
// export that quietly stops is worse than a documented one somebody runs,
// because the first kind is believed." That objection is real, and this is the
// answer to it rather than a dismissal of it: --check reads the newest
// COMPLETE.json, prints its age, and exits 1 when it is older than MAX_AGE_DAYS
// or there is none. A schedule that stopped, a PC that was off all week, a
// token that expired - each shows up as an age, not as silence. SETUP.md ->
// "The weekly D1 backup" says where to run it.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { join, relative, resolve, isAbsolute } from 'node:path';
import { repoRoot } from './d1-query-lib.mjs';

export const DEFAULT_ROOT = 'C:\\Users\\natha\\Backups\\nates-workshop';
export const GROUPS = ['palladium', 'marvel', 'tools'];
export const KEEP = 8;
export const MAX_AGE_DAYS = 8;
const DATED = /^\d{4}-\d{2}-\d{2}$/;

const args = process.argv.slice(2);
const check = args.includes('--check');
const target = args.includes('--local') ? '--local' : '--remote';
const root = resolve(args.find((a) => !a.startsWith('--')) ?? DEFAULT_ROOT);

const rel = relative(resolve(repoRoot), root);
if (!rel || (!rel.startsWith('..') && !isAbsolute(rel))) {
  console.error(`refusing ${root}: it is inside the repo, and the repo is public. Back up outside it.`);
  process.exit(2);
}

/** Dated folders under root, newest first. */
function datedFolders() {
  if (!existsSync(root)) return [];
  return readdirSync(root, { withFileTypes: true })
    .filter((d) => d.isDirectory() && DATED.test(d.name))
    .map((d) => d.name)
    .sort()
    .reverse();
}

if (check) {
  const newest = datedFolders().find((d) => existsSync(join(root, d, 'COMPLETE.json')));
  if (existsSync(join(root, 'last-run.json'))) {
    const last = JSON.parse(readFileSync(join(root, 'last-run.json'), 'utf8'));
    console.log(`last run: ${last.date} (${last.target}), exit ${last.exit}`);
  } else {
    console.log('last run: none recorded');
  }
  if (!newest) {
    console.log(`NO COMPLETE BACKUP under ${root}.`);
    process.exit(1);
  }
  const done = JSON.parse(readFileSync(join(root, newest, 'COMPLETE.json'), 'utf8'));
  const days = (Date.now() - Date.parse(done.finishedAt)) / 86_400_000;
  const line = `newest complete backup: ${newest}, ${days.toFixed(1)} days old`;
  if (days > MAX_AGE_DAYS) {
    console.log(`${line}. STALE: older than ${MAX_AGE_DAYS} days, so the weekly run has stopped.`);
    process.exit(1);
  }
  console.log(`${line}. OK.`);
  process.exit(0);
}

// The local date, not UTC: the folder name is what Nate looks for on disk.
const now = new Date();
const date = [now.getFullYear(), now.getMonth() + 1, now.getDate()]
  .map((n) => String(n).padStart(2, '0')).join('-');
const dayDir = join(root, date);
// The run writes into <date>.partial, which no rotation or --check counts, and
// it becomes <date> only when every database succeeded. So a second run on
// the same day that fails leaves the first one's good folder alone, and a
// table dropped since the first run cannot survive as a stale file.
const workDir = join(root, `${date}.partial`);
rmSync(workDir, { recursive: true, force: true });
mkdirSync(workDir, { recursive: true });

const results = {};
for (const group of GROUPS) {
  const dir = join(workDir, group);
  const r = spawnSync(process.execPath,
    [join(repoRoot, 'scripts', 'd1-backup.mjs'), dir, target, '--db', group],
    { cwd: repoRoot, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  const out = (r.stdout || '') + (r.stderr || '');
  process.stdout.write(out);
  writeFileSync(join(workDir, `${group}.log`), out, 'utf8');
  let tables = 0;
  let rows = 0;
  if (existsSync(dir)) {
    for (const f of readdirSync(dir).filter((n) => n.endsWith('.json'))) {
      tables += 1;
      rows += JSON.parse(readFileSync(join(dir, f), 'utf8')).length;
    }
  }
  results[group] = { exit: r.status ?? 1, tables, rows };
}

const ok = GROUPS.every((g) => results[g].exit === 0);
const record = { date, finishedAt: new Date().toISOString(), target, root, exit: ok ? 0 : 1, databases: results };

const deleted = [];
if (ok) {
  rmSync(dayDir, { recursive: true, force: true });
  renameSync(workDir, dayDir);
  writeFileSync(join(dayDir, 'COMPLETE.json'), JSON.stringify(record, null, 2), 'utf8');
  const partials = readdirSync(root).filter((n) => /^\d{4}-\d{2}-\d{2}\.partial$/.test(n));
  for (const old of [...datedFolders().slice(KEEP), ...partials]) {
    rmSync(join(root, old), { recursive: true, force: true });
    deleted.push(old);
  }
}
record.deleted = deleted;
writeFileSync(join(root, 'last-run.json'), JSON.stringify(record, null, 2), 'utf8');

console.log(`\nweekly backup ${date} -> ${ok ? dayDir : workDir}`);
for (const g of GROUPS) {
  const r = results[g];
  console.log(`  ${g.padEnd(10)} exit ${r.exit}  ${String(r.tables).padStart(3)} tables  ${String(r.rows).padStart(7)} rows`);
}
if (ok) {
  console.log(`  Complete. Kept the newest ${KEEP}; deleted ${deleted.length ? deleted.join(', ') : 'nothing'}.\n`);
} else {
  console.log(`  INCOMPLETE. Nothing rotated or replaced. Its <db>.log files are in ${date}.partial.\n`);
}
process.exit(ok ? 0 : 1);
