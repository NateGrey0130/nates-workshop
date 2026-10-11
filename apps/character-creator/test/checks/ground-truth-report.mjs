// scripts/ground-truth.mjs reports what is true in git and GitHub so a session
// can check a memory or a handoff against it. A report like that is only worth
// having if it cannot say "clean" when it did not look, so what is held here
// is mostly the ways it could:
//
//   an empty CI rollup read as green        a PR nothing reported on
//   a squash-merged branch read as work     the weakness of the script this
//   - or unsaved work read as merged        was ported from, and its mirror
//   a failed fetch, gh or process list      read as "none"
//
// The verdict, the branch state and the dev-server grouping are pure functions
// and are driven directly. The probes are driven against a throwaway repo with
// a bare origin beside it, through report()'s injectable `exec`: git is real,
// and `gh` and the process list are answered by the test, because CI has no
// GitHub credentials and no Windows process table. The dev-server rows are the
// ones a live `wrangler pages dev` printed here on 2026-10-11, shortened.

import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { check, section, wantSection } from '../harness.mjs';
import {
  ciVerdict, classifyBranch, devServers, ghRepoFromUrl, parseWorktrees, report, run as runProbe,
} from '../../../../scripts/ground-truth.mjs';

const SECTIONS = [
  'ground-truth.mjs: a CI verdict is green only when something said so',
  'ground-truth.mjs: a branch on no remote is checked against merged PRs',
  'ground-truth.mjs: one dev server is one line',
  'ground-truth.mjs: a probe that fails is UNKNOWN, never clean',
];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('ground-truth.mjs: a CI verdict is green only when something said so');
  {
    const done = (conclusion) => ({ status: 'COMPLETED', conclusion });
    check('an empty rollup is "no CI"', ciVerdict([]) === 'no CI', ciVerdict([]));
    check('and so is a missing one', ciVerdict(undefined) === 'no CI' && ciVerdict(null) === 'no CI');
    check('every check passed is green', ciVerdict([done('SUCCESS'), done('SKIPPED'), done('NEUTRAL')]) === 'CI green');
    for (const bad of ['FAILURE', 'CANCELLED', 'TIMED_OUT', 'ACTION_REQUIRED', 'STARTUP_FAILURE']) {
      check(`one ${bad} among passes is red`, ciVerdict([done('SUCCESS'), done(bad)]) === 'CI RED');
    }
    check('a commit status in ERROR is red', ciVerdict([{ state: 'ERROR' }]) === 'CI RED');
    check('a commit status in SUCCESS is green', ciVerdict([{ state: 'SUCCESS' }]) === 'CI green');
    check('a check still running is running', ciVerdict([done('SUCCESS'), { status: 'IN_PROGRESS', conclusion: '' }]) === 'CI running');
    check('a queued check is running', ciVerdict([{ status: 'QUEUED' }]) === 'CI running');
    check('a pending commit status is running', ciVerdict([{ state: 'PENDING' }]) === 'CI running');
    check('red beats running', ciVerdict([{ status: 'IN_PROGRESS' }, done('FAILURE')]) === 'CI RED');
    check('a conclusion this does not know is named, not green',
      ciVerdict([done('SUCCESS'), done('STALE')]) === 'CI unrecognised (STALE)', ciVerdict([done('STALE')]));

    check('an https remote gives owner/repo',
      ghRepoFromUrl('https://github.com/NateGrey0130/nates-workshop.git') === 'NateGrey0130/nates-workshop');
    check('an ssh remote gives owner/repo', ghRepoFromUrl('git@github.com:a/b') === 'a/b');
    check('a remote that is not GitHub gives none', ghRepoFromUrl('C:/tmp/origin.git') === null);
  }

  section('ground-truth.mjs: a branch on no remote is checked against merged PRs');
  {
    const base = 'origin/main';
    const loose = (extra) => ({ head: 'a1', branch: 'x', base, inBase: false, otherRemote: null, ...extra });
    const text = (f) => classifyBranch(f).text;
    check('no commit yet', text({ head: null, base }) === 'no commit yet');
    check('main level with origin', text({ head: 'a1', branch: 'main', base, isDefault: true, vsBase: [0, 0] }) === '= origin/main');
    check('main ahead of origin',
      text({ head: 'a1', branch: 'main', base, isDefault: true, vsBase: [2, 1] }) === 'ahead 2 / behind 1 of origin/main');
    check('a pushed branch, level', text({ head: 'a1', branch: 'x', base, pushed: true, vsPushed: [0, 0] }) === '= pushed');
    check('a pushed branch with an unpushed commit is kind "unpushed"',
      classifyBranch({ head: 'a1', branch: 'x', base, pushed: true, vsPushed: [1, 0] }).kind === 'unpushed');
    check('a merge-commit merge is read from git alone',
      text({ head: 'a1', branch: 'x', base, inBase: true }) === 'merged into origin/main');
    check('no merged PR: LOCAL ONLY', text(loose({ mergedPr: null })) === 'LOCAL ONLY: on no remote at all');
    check('a merged PR at this very tip: safe to delete',
      text(loose({ mergedPr: { number: 12, extra: 0 } })) === 'merged as #12 (squash or rebase), safe to delete');
    const grew = classifyBranch(loose({ mergedPr: { number: 12, extra: 2 } }));
    check('a merged PR, then two more commits: still LOCAL ONLY',
      grew.kind === 'local-only' && /^LOCAL ONLY/.test(grew.text) && /2 commit\(s\) since/.test(grew.text)
        && !/safe to delete/.test(grew.text), grew.text);
    const moved = classifyBranch(loose({ mergedPr: { number: 12, extra: null } }));
    check('a merged PR whose head this clone does not hold: not called safe',
      moved.kind === 'local-only' && !/safe to delete/.test(moved.text), moved.text);
    const blind = classifyBranch(loose({ mergedPr: { unknown: 'gh is not installed' } }));
    check('the merged-PR lookup failing is UNKNOWN, and still says LOCAL ONLY',
      blind.unknown === true && /LOCAL ONLY/.test(blind.text) && /UNKNOWN/.test(blind.text), blind.text);
    check('a commit only another remote holds says which',
      text(loose({ otherRemote: 'fork/x', mergedPr: null })) === 'not on origin, only on fork/x');

    const trees = parseWorktrees('worktree C:/r\nHEAD abc123\nbranch refs/heads/main\n\n'
      + 'worktree C:/r/wt\nHEAD def456\ndetached\n\nworktree C:/r/new\nHEAD 0000000000000000000000000000000000000000\nbranch refs/heads/n\n');
    check('porcelain: three trees, the main checkout first', trees.length === 3 && trees[0].path === 'C:/r' && trees[0].branch === 'main');
    check('porcelain: a detached tree has a head and no branch', trees[1].head === 'def456' && trees[1].branch === null);
    check('porcelain: an all-zero HEAD is no commit', trees[2].head === null);
  }

  section('ground-truth.mjs: one dev server is one line');
  {
    const npm = 'C:\\Users\\x\\AppData\\Roaming\\npm';
    const live = [
      { ProcessId: 59916, ParentProcessId: 14824, Name: 'node.exe', CommandLine: `"node.exe" ${npm}/node_modules/npm/bin/npx-cli.js wrangler pages dev --port 8793` },
      { ProcessId: 2680, ParentProcessId: 59916, Name: 'cmd.exe', CommandLine: 'cmd.exe /d /s /c wrangler pages dev --port 8793' },
      { ProcessId: 55364, ParentProcessId: 2680, Name: 'node.exe', CommandLine: `"node" "${npm}\\node_modules\\wrangler\\bin\\wrangler.js" pages dev --port 8793` },
      { ProcessId: 60904, ParentProcessId: 55364, Name: 'node.exe', CommandLine: `"node.exe" --no-warnings ${npm}\\node_modules\\wrangler\\wrangler-dist\\cli.js pages dev --port 8793` },
      { ProcessId: 34772, ParentProcessId: 60904, Name: 'workerd.exe', CommandLine: 'workerd.exe serve --binary --socket-addr=entry=127.0.0.1:8793 --control-fd=3 -' },
      { ProcessId: 37772, ParentProcessId: 60904, Name: 'workerd.exe', CommandLine: 'workerd.exe serve --binary --socket-addr=entry=127.0.0.1:0 --control-fd=3 -' },
      { ProcessId: 111, ParentProcessId: 1, Name: 'node.exe', CommandLine: 'node scripts/ground-truth.mjs' },
    ];
    const one = devServers(live, ['C:\\repo']);
    check('six processes are one server', one.servers.length === 1, JSON.stringify(one.servers));
    check('its port is read off --port', one.servers[0]?.port === '8793');
    check('its three node processes and two workerd are counted',
      one.servers[0]?.pids.join() === '55364,59916,60904' && one.servers[0]?.workerd === 2, JSON.stringify(one.servers[0]));
    check('a hand-started server names no tree', one.servers[0]?.tree === null);
    check('an unrelated node process is not a server', one.orphans.length === 0);

    const suite = devServers([
      { ProcessId: 1, ParentProcessId: 0, Name: 'node.exe', CommandLine: 'node wrangler.js pages dev --port 51000 --persist-to C:/Repo/.claude/worktrees/a/.wrangler/scratch' },
    ], ['C:\\repo', 'C:\\repo\\.claude\\worktrees\\a']);
    check('--persist-to attributes a server to the LONGEST tree path it names, whatever the slashes or case',
      suite.servers[0]?.tree === 'C:\\repo\\.claude\\worktrees\\a', JSON.stringify(suite.servers));

    const orphan = devServers(live.filter((r) => r.Name === 'workerd.exe'), []);
    check('workerd with no wrangler parent is an orphan, with its port',
      orphan.servers.length === 0 && orphan.orphans.length === 2 && orphan.orphans[0].port === '8793', JSON.stringify(orphan));
    const noPort = devServers(live.filter((r) => r.ProcessId !== 59916 && r.ProcessId !== 2680)
      .map((r) => ({ ...r, CommandLine: r.CommandLine.replace(' --port 8793', '') })), []);
    check('with no --port, the port is the address workerd serves', noPort.servers[0]?.port === '8793', JSON.stringify(noPort.servers));
  }

  section('ground-truth.mjs: a probe that fails is UNKNOWN, never clean');
  {
    const dir = mkdtempSync(join(tmpdir(), 'ground-truth-'));
    try {
      const origin = join(dir, 'origin.git');
      const repo = join(dir, 'repo');
      const wt = join(dir, 'wt');
      const g = (cwd, ...args) => execFileSync('git', ['-c', 'user.name=t', '-c', 'user.email=t@t.invalid',
        '-c', 'commit.gpgsign=false', '-c', 'core.autocrlf=false', ...args], { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
      const commit = (cwd, name) => { writeFileSync(join(cwd, name), name); g(cwd, 'add', name); g(cwd, 'commit', '-q', '-m', name); };
      mkdirSync(repo);
      g(dir, 'init', '-q', '--bare', '-b', 'main', origin);
      g(repo, 'init', '-q', '-b', 'main');
      g(repo, 'remote', 'add', 'origin', origin);
      commit(repo, 'one');
      g(repo, 'push', '-q', 'origin', 'main');
      // spike: on no remote, no PR. squashed: on no remote, a PR merged its tip.
      // grew: a PR merged its first commit, and it has one more since.
      for (const b of ['spike', 'squashed', 'grew']) { g(repo, 'checkout', '-q', '-b', b, 'main'); commit(repo, b); }
      const squashedTip = g(repo, 'rev-parse', 'squashed');
      const grewMerged = g(repo, 'rev-parse', 'grew');
      commit(repo, 'grew-more');
      // feat: its own worktree, pushed, then one commit and one stray file.
      g(repo, 'checkout', '-q', 'main');
      g(repo, 'worktree', 'add', '-q', wt, '-b', 'feat', 'main');
      commit(wt, 'feat');
      g(wt, 'push', '-q', 'origin', 'feat');
      commit(wt, 'feat-more');
      writeFileSync(join(wt, 'stray'), 'x');
      commit(repo, 'two');

      const merged = { squashed: [{ number: 7, headRefOid: squashedTip, mergedAt: '2026-01-02' }],
        grew: [{ number: 8, headRefOid: grewMerged, mergedAt: '2026-01-03' }] };
      const open = [{ number: 9, title: 'Nothing reported', headRefName: 'feat', isDraft: false, statusCheckRollup: [] },
        { number: 10, title: 'Red', headRefName: 'r', isDraft: true, statusCheckRollup: [{ status: 'COMPLETED', conclusion: 'FAILURE' }] }];
      const ok = (out) => ({ ok: true, status: 0, out });
      const fail = (why) => ({ ok: false, status: 1, out: '', why });
      // Real git, except the remote URL, so the repo reads as a GitHub one.
      const world = (over = {}) => (cmd, args, opts) => {
        if (cmd === 'git' && args[0] === 'remote') return ok('https://github.com/test/repo.git');
        if (cmd === 'git' && args[0] === 'fetch' && over.fetch) return over.fetch;
        if (cmd === 'powershell') return over.ps ?? ok('[]');
        if (cmd === 'gh') {
          if (over.gh) return over.gh;
          const head = args[args.indexOf('--head') + 1];
          return ok(JSON.stringify(args.includes('merged') ? merged[head] ?? [] : open));
        }
        return runProbe(cmd, args, opts);
      };
      const go = (over) => {
        const r = report({ root: repo, exec: world(over), platform: 'win32', home: dir });
        return { ...r, text: r.lines.join('\n') };
      };
      const has = (r, s) => r.text.includes(s);

      const good = go();
      check('every probe answering exits 0', good.failed === 0 && has(good, 'GROUND TRUTH: complete'), good.text);
      check('main with an unpushed commit', has(good, '    . [main]: ahead 1 / behind 0 of origin/main'), good.text);
      check('a worktree: pushed branch, one commit since, one stray file',
        /\n {4}\S*wt \[feat\]: ahead 1 \/ behind 0 of the pushed branch, 1 uncommitted\n/.test(good.text), good.text);
      check('a branch on no remote with no PR is LOCAL ONLY', has(good, '    spike: LOCAL ONLY: on no remote at all\n'), good.text);
      check('a squash-merged branch is safe to delete', has(good, '    squashed: merged as #7 (squash or rebase), safe to delete'), good.text);
      check('a branch that grew after its PR merged is LOCAL ONLY',
        /\n {4}grew: LOCAL ONLY: on no remote at all \(#8 merged an earlier tip; 1 commit\(s\) since/.test(good.text), good.text);
      check('an open PR with an empty rollup is "no CI"', has(good, '    #9 [feat] no CI: Nothing reported'), good.text);
      check('a draft PR with a failure is red', has(good, '    #10 [r] draft CI RED: Red'), good.text);
      check('no server running says so', has(good, '    none running'), good.text);
      check('the linked worktree is scanned for junctions', /\n {4}\S*wt: none\n/.test(good.text), good.text);

      const noFetch = go({ fetch: fail('could not resolve host') });
      check('a failed fetch is UNKNOWN', has(noFetch, 'UNKNOWN: git fetch origin failed (could not resolve host)'), noFetch.text);
      check('and the run is INCOMPLETE', noFetch.failed === 1 && has(noFetch, 'GROUND TRUTH: INCOMPLETE - 1 probe(s) failed'), noFetch.text);

      const noGh = go({ gh: { ok: false, status: null, out: '', why: 'gh is not installed' } });
      check('gh missing: open PRs are UNKNOWN, not "none"',
        has(noGh, 'UNKNOWN: gh pr list -R test/repo failed (gh is not installed)') && !/open PRs[^\n]*\n {4}none/.test(noGh.text), noGh.text);
      check('gh missing: a branch on no remote is not called merged or clean',
        /\n {4}squashed: LOCAL ONLY: on no remote at all - UNKNOWN whether a merged PR carried it/.test(noGh.text), noGh.text);
      check('gh missing: every probe that needed it counts', noGh.failed === 4, `failed = ${noGh.failed}`);

      const badJson = go({ gh: ok('<html>rate limited</html>') });
      check('gh printing something unparsable is UNKNOWN', badJson.failed === 4 && has(badJson, 'not a JSON list'), badJson.text);
      const noPs = go({ ps: fail('Access denied') });
      check('a failed process list is UNKNOWN, not "none running"',
        noPs.failed === 1 && has(noPs, 'UNKNOWN: the process list failed (Access denied)') && !has(noPs, 'none running'), noPs.text);

      const hung = runProbe(process.execPath, ['-e', 'setTimeout(() => {}, 20000)'], { timeout: 400 });
      check('a hung command is stopped by its timeout', hung.ok === false && /timed out/.test(hung.why), JSON.stringify(hung));
      const absent = runProbe('no-such-command-ground-truth', []);
      check('a missing command is a failed probe, not a throw', absent.ok === false && /not installed/.test(absent.why), JSON.stringify(absent));
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  }
}
