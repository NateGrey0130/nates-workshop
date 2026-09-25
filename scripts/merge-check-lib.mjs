// Will the open pull requests merge TOGETHER, and in what order?
//
//   node scripts/book-board.mjs --merge-check            order + trial merge
//   node scripts/book-board.mjs --merge-check --tests    ...and the CI suites on the result
//   node scripts/book-board.mjs --merge-check --remote   ...and production against the result
//
// WHY. Each pull request's CI ran against the `main` it branched from, and the
// ruleset does not require a branch to be up to date, so several book PRs can
// each be green and still break one another. Checking a batch by hand on
// 2026-09-25 found the three things this automates:
//
//   order   two PRs carried their survey PR's commit. Merged in the wrong
//           order - or squashed - they conflict on the survey. A PR whose
//           commits are all inside another PR merges first.
//   merge   every PR merged, in that order, into a throwaway tree at
//           origin/main, the way this repo merges (--no-ff). The tree lives
//           in the OS temp directory and is removed at the end.
//   tests   (--tests) the suites CI would run for the combined change - read
//           off `groups.mjs --affected`, as the workflows do - on that tree.
//           Full output is KEPT in a log directory; a tail is not a record.
//   drift   (--remote) drift-check against production FROM that tree, so a
//           script an open PR adds is not reported as missing. What is left:
//             DATA SCRIPT NOT RUN  a PR's script not yet applied - the
//                                  ordering rule says apply before merging
//             RUN BUT NO FILE      production ran a script no PR carries. It
//                                  is traced to every worktree and unmerged
//                                  branch holding that name. Held nowhere
//                                  means renamed or deleted AFTER it was
//                                  applied, and the old run record lies.
//             CLASS NOT REPRODUCIBLE  the same trace, by a script named for
//                                  the class's slug.
//           Anything traced to a worktree or branch is AHEAD - a session
//           mid-import, expected - and is not a blocker; the rest is.
//
// Read-only as far as the repo and production go: it merges nothing on
// GitHub, applies nothing, and the throwaway tree is detached (no branch).

import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import { mainCheckout } from './worktree-lib.mjs';

// The file name without the sort-order prefix a rename adds or changes -
// `zzzzz-` or `~001-` - so `add-x.sql` and `zzzz-add-x.sql` compare equal.
export function coreName(file) {
  return file.replace(/^(?:z+-|~\d+-)/, '');
}

// Order PRs so that one whose commits are all inside another merges first.
// `prs` is [{ number, commits: [sha] }]. Returns { order, before, partial }:
// before[n] lists PRs that must merge before n; partial lists pairs that share
// SOME commits without one containing the other - no order makes that safe.
export function orderPrs(prs) {
  const before = {};
  const partial = [];
  for (const a of prs) before[a.number] = [];
  for (const a of prs) {
    const setA = new Set(a.commits);
    for (const b of prs) {
      if (a.number >= b.number) continue;
      const shared = b.commits.filter((c) => setA.has(c)).length;
      if (!shared) continue;
      if (shared === a.commits.length && b.commits.length > shared) before[b.number].push(a.number);
      else if (shared === b.commits.length && a.commits.length > shared) before[a.number].push(b.number);
      else partial.push([a.number, b.number]);
    }
  }
  const order = [];
  const done = new Set();
  const left = [...prs].sort((x, y) => x.number - y.number);
  while (left.length) {
    const i = left.findIndex((p) => before[p.number].every((n) => done.has(n)));
    const next = left.splice(i === -1 ? 0 : i, 1)[0];
    order.push(next.number);
    done.add(next.number);
  }
  return { order, before, partial };
}

// Where production's orphaned run records are held. `holders` maps a place
// (a worktree or a branch) to the file names in it. Returns, per name, the
// places holding it exactly and the ones holding it under another prefix.
export function traceNames(names, holders) {
  const out = {};
  for (const name of names) {
    const exact = [];
    const renamed = [];
    for (const [place, files] of Object.entries(holders)) {
      if (files.includes(name)) exact.push(place);
      for (const f of files) if (f !== name && coreName(f) === coreName(name)) renamed.push(`${place}: ${f}`);
    }
    out[name] = { exact, renamed };
  }
  return out;
}

export function runMergeCheck({ repoRoot, tests, remote }) {
  const sh = (cmd, args, opts = {}) => execFileSync(cmd, args, { cwd: repoRoot, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], ...opts });
  const git = (args, opts) => sh('git', args, opts).trim();
  const blockers = [];

  git(['fetch', '--quiet', 'origin']);
  const all = JSON.parse(sh('gh', ['pr', 'list', '--state', 'open', '--limit', '100', '--json', 'number,headRefName,baseRefName,title,isDraft']));
  const drafts = all.filter((p) => p.isDraft);
  const prs = all.filter((p) => !p.isDraft).map((p) => {
    const ref = `origin/${p.headRefName}`;
    const commits = git(['rev-list', `origin/main..${ref}`]).split(/\r?\n/).filter(Boolean);
    const files = git(['diff', '--name-only', `origin/main...${ref}`]).split(/\r?\n/).filter(Boolean);
    return { ...p, ref, commits, files };
  });
  const byNumber = Object.fromEntries(prs.map((p) => [p.number, p]));

  console.log(`origin/main ${git(['rev-parse', '--short', 'origin/main'])}; ${prs.length} open PR(s)`
    + (drafts.length ? `, ${drafts.length} draft(s) left out: ${drafts.map((p) => `#${p.number}`).join(' ')}` : ''));

  // ---- order ----
  const { order, before, partial } = orderPrs(prs);
  console.log('\nmerge order');
  if (!order.length) console.log('  (no open PRs)');
  order.forEach((n, i) => {
    const p = byNumber[n];
    const notes = [];
    if (before[n].length) notes.push(`after ${before[n].map((m) => `#${m}`).join(', ')}, whose commits it carries`);
    if (p.baseRefName !== 'main') notes.push(`BASE IS ${p.baseRefName}: merge that without --delete-branch, then retarget this one (ship-pr step 7)`);
    console.log(`  ${i + 1}. #${n} ${p.headRefName}${notes.length ? `  - ${notes.join('; ')}` : ''}`);
  });
  for (const [a, b] of partial) {
    blockers.push(`#${a} and #${b} share some commits and neither contains the other`);
  }
  if (order.some((n) => before[n].length)) {
    console.log('  merge with --merge, not squash: a squashed PR leaves the one that carries its commit to conflict');
  }

  // ---- trial merge ----
  const tree = mkdtempSync(join(tmpdir(), 'merge-check-'));
  git(['worktree', 'add', '--quiet', '--detach', tree, 'origin/main']);
  let exit = 0;
  try {
    console.log(`\ntrial merge in ${tree}`);
    const merged = [];
    for (const n of order) {
      const p = byNumber[n];
      const r = spawnSync('git', ['-c', 'user.name=merge-check', '-c', 'user.email=merge-check@localhost',
        'merge', '--no-ff', '--no-edit', '-m', `merge-check #${n}`, p.ref], { cwd: tree, encoding: 'utf8' });
      if (r.status === 0) { merged.push(n); console.log(`  ok        #${n}`); continue; }
      const conflicted = spawnSync('git', ['diff', '--name-only', '--diff-filter=U'], { cwd: tree, encoding: 'utf8' }).stdout.trim();
      spawnSync('git', ['merge', '--abort'], { cwd: tree });
      console.log(`  CONFLICT  #${n}: ${conflicted.split(/\r?\n/).join(', ') || (r.stderr || r.stdout).trim()}`);
      blockers.push(`#${n} does not merge on top of the PRs before it`);
    }

    // ---- tests ----
    if (tests) {
      const logDir = join(tmpdir(), `merge-check-logs-${new Date().toISOString().replace(/[:.]/g, '-')}`);
      mkdirSync(logDir, { recursive: true });
      // The tree gets a local D1 of its own, built from its files, because
      // smoke applies the schema to whatever WORKSHOP_LOCAL_D1 names and the
      // main checkout's database is not this check's to change. The OCR cache
      // is only read, so the main checkout's serves.
      const d1 = join(tree, '.wrangler', 'state');
      console.log('\nbuilding the merged tree its own local D1 (about three minutes)');
      const built = spawnSync('node', ['scripts/build-local-d1.mjs', d1], { cwd: tree, encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });
      writeFileSync(join(logDir, 'build-local-d1.txt'), (built.stdout ?? '') + (built.stderr ?? ''));
      if (built.status !== 0) blockers.push(`the merged tree's files do not build a local D1 - ${join(logDir, 'build-local-d1.txt')}`);
      const env = {
        ...process.env,
        WORKSHOP_LOCAL_D1: d1,
        WORKSHOP_OCR_CACHE: process.env.WORKSHOP_OCR_CACHE ?? join(mainCheckout(), '.cache', 'books'),
      };
      const affected = spawnSync('node', ['scripts/groups.mjs', '--affected', 'origin/main', 'HEAD'], { cwd: tree, encoding: 'utf8' }).stdout;
      const group = (g) => new RegExp(`^${g}=true`, 'm').test(affected);
      const suites = [
        ['groups', ['scripts/groups.mjs', '--check'], true],
        ['smoke', ['apps/character-creator/test/smoke.mjs'], true],
        ['regression', ['apps/character-creator/test/regression.mjs'], group('palladium')],
        ['filament-forge', ['apps/filament-forge/test/smoke.mjs'], group('tools')],
        ['pick3cut5', ['apps/pick3cut5/test/smoke.mjs'], group('tools')],
        ['pick3cut5-game', ['apps/pick3cut5/test/game.mjs'], group('tools')],
        ['media-vault', ['apps/media-vault/test/smoke.mjs'], group('tools')],
        ['marvel-heroes', ['apps/marvel-heroes/test/smoke.mjs'], group('marvel')],
      ];
      console.log(`\ntests on the merged tree (full output kept in ${logDir})`);
      for (const [name, args, wanted] of suites) {
        if (!wanted) { console.log(`  skipped   ${name}: CI would not run it for this change (groups.mjs --affected)`); continue; }
        const r = spawnSync('node', args, { cwd: tree, env, encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });
        const out = (r.stdout ?? '') + (r.stderr ?? '');
        const log = join(logDir, `${name}.txt`);
        writeFileSync(log, out);
        // The suite's own verdict line, not the last line: stderr is appended
        // after stdout, and a Node deprecation warning there ended one run.
        const outLines = out.trim().split(/\r?\n/).filter(Boolean);
        const last = outLines.filter((l) => /\b(PASSED|FAILED)\b|each with one owner/.test(l)).pop() ?? outLines.pop() ?? '';
        console.log(`  ${r.status === 0 ? 'ok      ' : 'FAILED  '}  ${name}: ${last}`);
        if (r.status !== 0) {
          for (const line of out.split(/\r?\n/).filter((l) => /^\s*FAIL\b/.test(l)).slice(0, 15)) console.log(`      ${line.trim()}`);
          blockers.push(`${name} fails on the merged tree - ${log}`);
        }
      }
    }

    // ---- drift ----
    if (remote) {
      const r = spawnSync('node', ['scripts/drift-check.mjs', '--remote'], { cwd: tree, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
      const out = (r.stdout ?? '') + (r.stderr ?? '');
      const lines = out.split(/\r?\n/).filter((l) => /^ {2}[A-Z][A-Z -]+: /.test(l) && !/moved with its group/.test(l));
      const notRun = lines.map((l) => /DATA SCRIPT NOT RUN: (\S+)/.exec(l)?.[1]).filter(Boolean);
      const orphans = lines.map((l) => /RUN BUT NO FILE: (\S+)/.exec(l)?.[1]).filter(Boolean);
      const other = lines.filter((l) => !/DATA SCRIPT NOT RUN|RUN BUT NO FILE/.test(l));
      console.log('\nproduction against the merged tree');
      if (/NO DRIFT/.test(out) && !lines.length) console.log('  NO DRIFT');
      if (!/NO DRIFT|DRIFT FOUND/.test(out)) {
        console.log(`  drift-check did not finish:\n${out.trim().split(/\r?\n/).slice(-5).map((l) => `    ${l}`).join('\n')}`);
        blockers.push('drift-check --remote did not run');
      }
      for (const f of notRun) {
        const owner = prs.filter((p) => p.files.some((x) => basename(x) === f)).map((p) => `#${p.number}`);
        console.log(`  NOT APPLIED  ${f}${owner.length ? ` (${owner.join(', ')})` : ''} - apply --remote before merging`);
        blockers.push(`${f} is not applied to production`);
      }
      // A class published in production with no data script on main is the
      // same shape as an orphaned run record: a session mid-import applies its
      // class script before the PR exists. Traced by a .sql file named for the
      // slug (add-<slug>-class.sql is the convention), which is a heuristic -
      // a class script named otherwise stays a blocker, the safe direction.
      const classes = other.map((l) => /CLASS NOT REPRODUCIBLE: (\S+)/.exec(l)?.[1]).filter(Boolean);
      const rest = other.filter((l) => !/CLASS NOT REPRODUCIBLE/.test(l));
      if (orphans.length || classes.length) {
        const holders = {};
        const porcelain = git(['worktree', 'list', '--porcelain']);
        for (const block of porcelain.split(/\r?\n\r?\n/)) {
          const path = /^worktree (.+)$/m.exec(block)?.[1];
          if (!path || path.replace(/\\/g, '/') === tree.replace(/\\/g, '/') || !existsSync(path)) continue;
          const branch = /^branch refs\/heads\/(.+)$/m.exec(block)?.[1] ?? 'detached';
          const files = spawnSync('git', ['ls-files', '--cached', '--others', '--exclude-standard'], { cwd: path, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 }).stdout;
          holders[`worktree ${path} [${branch}]`] = files.split(/\r?\n/).filter(Boolean).map((f) => basename(f));
        }
        for (const ref of git(['branch', '-r', '--no-merged', 'origin/main', '--format=%(refname:short)']).split(/\r?\n/).filter(Boolean)) {
          holders[`branch ${ref}`] = git(['ls-tree', '-r', '--name-only', ref]).split(/\r?\n/).map((f) => basename(f));
        }
        const traced = traceNames(orphans, holders);
        for (const f of orphans) {
          const { exact, renamed } = traced[f];
          if (exact.length) {
            console.log(`  AHEAD        ${f} - applied, and its PR is not open yet: ${exact.join('; ')}`);
          } else {
            console.log(`  ORPHAN       ${f} - held by no worktree and no unmerged branch`
              + (renamed.length ? `; renamed after it was applied? ${renamed.join('; ')}` : '; renamed or deleted after it was applied?'));
            blockers.push(`production's run record ${f} names a file nothing holds`);
          }
        }
        for (const slug of classes) {
          const named = Object.entries(holders)
            .filter(([, files]) => files.some((f) => f.endsWith('.sql') && f.includes(slug)))
            .map(([place]) => place);
          if (named.length) {
            console.log(`  AHEAD        class ${slug} - published, and its script is not on main yet: ${named.join('; ')}`);
          } else {
            console.log(`  UNHELD CLASS ${slug} - published, and no worktree or unmerged branch has a script named for it`);
            blockers.push(`class ${slug} is published and nothing can recreate it`);
          }
        }
      }
      for (const l of rest) {
        console.log(`  ${l.trim()}`);
        blockers.push(l.trim());
      }
    }
  } finally {
    // --force because the suites leave ignored files (.wrangler) behind. The
    // junction hazard in the worktree skill does not arise: this tree is a
    // plain `git worktree add` and nothing here links anything into it.
    const rm = spawnSync('git', ['worktree', 'remove', '--force', tree], { cwd: repoRoot, encoding: 'utf8' });
    if (rm.status !== 0) console.log(`\ncould not remove ${tree}: ${rm.stderr.trim()} - remove it by hand`);
  }

  console.log('');
  if (blockers.length) {
    console.log(`NOT SAFE TO MERGE AS A BATCH (${blockers.length}):`);
    for (const b of blockers) console.log(`  - ${b}`);
    exit = 1;
  } else {
    const ran = [tests && 'tests', remote && 'production'].filter(Boolean);
    console.log(`MERGE CHECK PASSED: merge in the order above${ran.length ? '' : ' (order and trial merge only - add --tests --remote for the rest)'}`);
  }
  return exit;
}
