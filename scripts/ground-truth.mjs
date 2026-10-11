#!/usr/bin/env node
// What is TRUE right now, read from git, GitHub and this machine. Read-only.
//
//   node scripts/ground-truth.mjs              fetch, then report
//   node scripts/ground-truth.mjs --no-fetch   report against origin as last fetched
//
// WHY. A memory, a PR body and a handoff are CLAIMS a past session wrote. A
// session that starts from them inherits whatever was wrong in them, and the
// questions they answer - what is pushed, what merged, which tree is dirty,
// what CI said - are ones git and GitHub answer exactly. This prints those
// answers in one place, so a session checks the claim against the fact.
//
//   origin/main   its tip
//   worktrees     each tree's branch, where it stands against origin, how many
//                 files are uncommitted; MISSING when the directory is gone
//   branches      local branches no worktree holds that origin does not have
//                 in full
//   open PRs      each with one CI verdict. An empty rollup is "no CI": a PR
//                 nothing has reported on is not a green one
//   dev servers   every running `wrangler ... dev`, by port, with the tree its
//                 command line names. A server left running keeps a tree's
//                 .wrangler/state open, and `--remove` then dies halfway
//   junctions     every junction or symlink inside a linked worktree, and the
//                 tree's memory link under ~/.claude/projects. A removal can
//                 delete THROUGH a junction (the `worktree` skill), so these
//                 are unlinked first
//
// A BRANCH ON NO REMOTE IS NOT ALWAYS UNSAVED WORK. `gh pr merge --merge` puts
// the branch's own commits on main, so its tip is an ancestor of origin/main
// and git alone can say "merged". A squash or a rebase merge writes NEW
// commits, the remote branch is deleted, and the local tip is then on no
// remote at all - exactly what unpushed work looks like. So before a branch
// is called LOCAL ONLY this asks GitHub for a merged PR from that branch, and
// calls it safe to delete only when the PR merged the very tip the branch
// still has. A commit added after the merge is still LOCAL ONLY, and says so.
//
// A PROBE THAT FAILS IS NEVER "CLEAN". A failed fetch, a missing or failing
// `gh`, output that will not parse: the section says UNKNOWN and why, and the
// run exits 2. Exit 0 means every probe answered. Every external command has
// a timeout, so this cannot hang the session that runs it.
//
// WHAT IT CANNOT SEE. A dev server started by hand names no tree on its
// command line, and Windows gives no cheap way to read another process's
// working directory, so such a server is listed by port with its tree unnamed.
// One started by a test suite carries --persist-to and is attributed.
// Ports are a convention here (.claude/launch.json), not an assignment: no
// tree owns one, so the list is of servers, not of ports.
//
// The first five sections are a port of ground-truth.sh from
// https://github.com/truongfelix/workflow (MIT, (c) its authors), at
// template/.claude/skills/session-start/. Left out: its systemd section, its
// multi-repo config and its keep-local list. Added: the merged-PR cross-check
// above, the dev servers and the junctions.

import { spawnSync } from 'node:child_process';
import { existsSync, lstatSync, realpathSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, relative, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { linksInside, projectDirName } from './worktree-lib.mjs';

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const REMOTE = 'origin';

// ---------- pure: no git, no network, so the suite can drive every branch ----------

const RED = new Set(['FAILURE', 'CANCELLED', 'TIMED_OUT', 'ERROR', 'ACTION_REQUIRED', 'STARTUP_FAILURE']);
const RUNNING = new Set(['PENDING', 'EXPECTED', 'QUEUED', 'IN_PROGRESS', 'WAITING', 'REQUESTED', '']);
const PASSED = new Set(['SUCCESS', 'NEUTRAL', 'SKIPPED']);

// One verdict for a PR's statusCheckRollup. A check run carries status and
// conclusion; a commit status carries only state. Red beats running beats
// green, and green is every entry in PASSED - a state this does not know is
// named, not waved through.
export function ciVerdict(rollup) {
  if (!Array.isArray(rollup) || rollup.length === 0) return 'no CI';
  const states = rollup.map((c) => ((c.status ?? 'COMPLETED') !== 'COMPLETED'
    ? 'PENDING' : String(c.conclusion || c.state || 'PENDING').toUpperCase()));
  if (states.some((s) => RED.has(s))) return 'CI RED';
  if (states.some((s) => RUNNING.has(s))) return 'CI running';
  const odd = states.filter((s) => !PASSED.has(s));
  if (odd.length) return `CI unrecognised (${[...new Set(odd)].join(', ')})`;
  return 'CI green';
}

// `owner/repo` from a GitHub remote URL, or null for any other remote.
export function ghRepoFromUrl(url) {
  const m = /^(?:git@|ssh:\/\/git@|https:\/\/)github\.com[:/]([^/\s]+\/[^/\s]+?)(?:\.git)?\/?$/.exec(String(url).trim());
  return m ? m[1] : null;
}

// `git worktree list --porcelain`, as one record per tree. The first is the
// main checkout.
export function parseWorktrees(porcelain) {
  const trees = [];
  for (const block of String(porcelain).split(/\r?\n\r?\n/)) {
    const path = /^worktree (.+)$/m.exec(block)?.[1];
    if (!path) continue;
    const head = /^HEAD ([0-9a-f]+)$/m.exec(block)?.[1] ?? null;
    trees.push({
      path,
      head: head && !/^0+$/.test(head) ? head : null,
      branch: /^branch refs\/heads\/(.+)$/m.exec(block)?.[1] ?? null,
    });
  }
  return trees;
}

const aheadBehind = ([ahead, behind], same, suffix) => (ahead === 0 && behind === 0
  ? same : `ahead ${ahead} / behind ${behind} ${suffix}`);

// Where one branch or detached head stands, from facts already gathered:
//   head, branch, base ('origin/main' or null), isDefault, vsBase [ahead, behind],
//   pushed, vsPushed [ahead, behind], inBase, onRemoteBranch, otherRemote,
//   mergedPr: null | { number, extra } | { unknown: why }
// `extra` is how many commits the local tip has that the merged PR's head did
// not: 0 is the safe case, null is "the merged head is not in this clone".
// Returns { kind, text }, plus unknown: true when a probe behind it failed.
export function classifyBranch(f) {
  if (!f.head) return { kind: 'empty', text: 'no commit yet' };
  if (!f.base) return { kind: 'no-remote', text: 'nothing pushed (no remote branch to compare with)' };
  if (f.isDefault) {
    return { kind: f.vsBase[0] ? 'unpushed' : 'pushed', text: aheadBehind(f.vsBase, `= ${f.base}`, `of ${f.base}`) };
  }
  if (f.pushed) {
    return { kind: f.vsPushed[0] ? 'unpushed' : 'pushed', text: aheadBehind(f.vsPushed, '= pushed', 'of the pushed branch') };
  }
  if (f.inBase) return { kind: 'merged', text: `merged into ${f.base}` };
  if (f.onRemoteBranch) return { kind: 'pushed', text: `on a ${REMOTE} branch` };
  const where = f.otherRemote ? `not on ${REMOTE}, only on ${f.otherRemote}` : 'LOCAL ONLY: on no remote at all';
  const pr = f.mergedPr;
  if (pr?.unknown) {
    return { kind: 'unknown', unknown: true, text: `${where} - UNKNOWN whether a merged PR carried it: ${pr.unknown}` };
  }
  if (pr && pr.extra === 0) {
    return { kind: 'squash-merged', text: `merged as #${pr.number} (squash or rebase), safe to delete` };
  }
  if (pr) {
    const since = pr.extra === null ? 'its tip is not the one that PR merged' : `${pr.extra} commit(s) since are in no PR`;
    return { kind: 'local-only', text: `${where} (#${pr.number} merged an earlier tip; ${since})` };
  }
  return { kind: 'local-only', text: where };
}

// Running dev servers out of a process list ({ ProcessId, ParentProcessId,
// Name, CommandLine } rows). One `wrangler pages dev` is several processes,
// read off a live one 2026-10-11: npx's node, a cmd.exe shim, wrangler's node
// twice, workerd twice. Rows are gathered under the topmost wrangler ancestor
// and reported as one server, so the rows must include cmd.exe or the chain
// breaks at the shim and one server reads as two. `trees` are worktree
// paths; a server is attributed to the longest one its command lines name.
// The port is --port, or failing that the address workerd was told to serve.
export function devServers(rows, trees = []) {
  const byPid = new Map(rows.map((r) => [r.ProcessId, r]));
  const isNode = (r) => /^node(\.exe)?$/i.test(r.Name ?? '');
  const entryPort = (text) => /--socket-addr=entry=[^\s:]+:([1-9]\d*)/.exec(text ?? '')?.[1] ?? null;
  const isWrangler = (r) => isNode(r)
    && /wrangler/i.test(r.CommandLine ?? '') && /\s(pages\s+)?dev(\s|$)/.test(r.CommandLine ?? '');
  const rootOf = (row) => {
    let top = null;
    const seen = new Set();
    for (let r = row; r && !seen.has(r.ProcessId); r = byPid.get(r.ParentProcessId)) {
      seen.add(r.ProcessId);
      if (isWrangler(r)) top = r;
    }
    return top;
  };
  const norm = (s) => String(s).replace(/\\/g, '/').toLowerCase();
  const byLength = [...trees].sort((a, b) => b.length - a.length);
  const servers = new Map();
  const orphans = [];
  for (const r of rows) {
    const root = rootOf(r);
    const workerd = /^workerd(\.exe)?$/i.test(r.Name ?? '');
    if (!root) { if (workerd) orphans.push({ pid: r.ProcessId, port: entryPort(r.CommandLine) }); continue; }
    const s = servers.get(root.ProcessId) ?? { pids: [], workerd: 0, port: null, tree: null, text: '' };
    servers.set(root.ProcessId, s);
    if (workerd) s.workerd++; else if (isNode(r)) s.pids.push(r.ProcessId);
    s.text += ` ${r.CommandLine ?? ''}`;
  }
  for (const s of servers.values()) {
    s.port = /--port[= ]+(\d+)/.exec(s.text)?.[1] ?? entryPort(s.text);
    s.tree = byLength.find((t) => norm(s.text).includes(norm(t))) ?? null;
    s.pids.sort((a, b) => a - b);
    delete s.text;
  }
  return { servers: [...servers.values()], orphans };
}

// ---------- the probes ----------

// One external command with a timeout. Never throws: { ok, status, out, why }.
export function run(cmd, args, { cwd, timeout = 30_000 } = {}) {
  const r = spawnSync(cmd, args, { cwd, encoding: 'utf8', timeout, windowsHide: true, maxBuffer: 64 * 1024 * 1024 });
  if (r.error) {
    const why = r.error.code === 'ETIMEDOUT' ? `timed out after ${timeout / 1000}s`
      : r.error.code === 'ENOENT' ? `${cmd} is not installed` : r.error.message;
    return { ok: false, status: null, out: '', why };
  }
  const out = (r.stdout ?? '').trim();
  if (r.status !== 0) {
    return { ok: false, status: r.status, out, why: (r.stderr ?? '').trim().split(/\r?\n/)[0] || `exit ${r.status}` };
  }
  return { ok: true, status: 0, out };
}

class ProbeError extends Error {}

// Paths are compared as resolved directories, never as strings: git prints
// C:/..., node C:\..., and a junction gives one directory two spellings.
const real = (p) => { try { return realpathSync.native(p); } catch { return resolve(p); } };
const fold = (p) => (process.platform === 'win32' ? real(p).toLowerCase() : real(p));
const sameDir = (a, b) => fold(a) === fold(b);

// Returns { lines, failed }. `exec` is injectable so the suite can make a
// probe fail without breaking the machine it runs on.
export function report({ root = repoRoot, fetch = true, exec = run, platform = process.platform, home = homedir() } = {}) {
  const lines = [];
  let failed = 0;
  const say = (s) => lines.push(s);
  const unknown = (why) => { failed++; say(`    UNKNOWN: ${why}`); };
  const git = (args, opts) => exec('git', args, { cwd: root, ...opts });
  const must = (args, what) => {
    const r = git(args);
    if (!r.ok) throw new ProbeError(`${what ?? `git ${args.join(' ')}`} failed: ${r.why}`);
    return r.out;
  };

  const stamp = new Date().toLocaleString('sv-SE', { dateStyle: 'short', timeStyle: 'short' });
  say(`GROUND TRUTH - ${stamp}`);
  const finish = () => {
    say('');
    say(failed ? `GROUND TRUTH: INCOMPLETE - ${failed} probe(s) failed, read their sections as UNKNOWN` : 'GROUND TRUTH: complete');
    return { lines, failed };
  };

  if (!git(['rev-parse', '--git-dir']).ok) {
    unknown(`${root} is not a git checkout`);
    return finish();
  }

  // The remote, and its default branch. No remote is a finding, not a failure.
  let base = null;
  let def = null;
  let ghRepo = null;
  const url = git(['remote', 'get-url', REMOTE]);
  if (!url.ok) {
    say(`  no remote '${REMOTE}': nothing in this repo is pushed anywhere`);
  } else {
    ghRepo = ghRepoFromUrl(url.out);
    if (fetch) {
      const f = git(['fetch', '--quiet', '--prune', REMOTE], { timeout: 60_000 });
      if (!f.ok) {
        say(`  ${REMOTE}:`);
        unknown(`git fetch ${REMOTE} failed (${f.why}): everything below compares against a STALE ${REMOTE}`);
      }
    }
    const head = git(['symbolic-ref', '-q', '--short', `refs/remotes/${REMOTE}/HEAD`]);
    const named = head.ok ? head.out.replace(`${REMOTE}/`, '') : null;
    def = [named, 'main', 'master'].find((d) => d && git(['rev-parse', '-q', '--verify', `refs/remotes/${REMOTE}/${d}`]).ok) ?? null;
    if (def) {
      base = `${REMOTE}/${def}`;
      const tip = git(['log', '-1', '--format=%h %cd %s', '--date=format:%Y-%m-%d %H:%M', base]);
      if (tip.ok) say(`  ${base}: ${tip.out}`);
      else { say(`  ${base}:`); unknown(`git log ${base} failed: ${tip.why}`); }
    } else {
      say(`  '${REMOTE}' has no default branch yet: nothing is pushed`);
    }
  }

  const refs = new Map();
  let trees;
  try {
    for (const line of must(['for-each-ref', '--format=%(refname) %(objectname)', 'refs/heads', 'refs/remotes']).split(/\r?\n/)) {
      const [name, oid] = line.split(' ');
      if (oid) refs.set(name, oid);
    }
    trees = parseWorktrees(must(['worktree', 'list', '--porcelain']));
    if (trees.length === 0) throw new ProbeError('git worktree list printed no worktree');
  } catch (e) {
    say('  worktrees:');
    unknown(e.message);
    return finish();
  }
  const mainTree = trees[0].path;
  const rel = (p) => {
    const r = relative(real(mainTree), real(p));
    if (r === '') return '.';
    return r.startsWith('..') || isAbsolute(r) ? resolve(p).replace(/\\/g, '/') : r.replace(/\\/g, '/');
  };

  const count = (a, b) => {
    const m = /^(\d+)\s+(\d+)$/.exec(must(['rev-list', '--left-right', '--count', `${a}...${b}`]));
    if (!m) throw new ProbeError(`git rev-list --count ${a}...${b} printed something unreadable`);
    return [Number(m[1]), Number(m[2])];
  };
  const isAncestor = (a, b) => {
    const r = git(['merge-base', '--is-ancestor', a, b]);
    if (r.status !== 0 && r.status !== 1) throw new ProbeError(`git merge-base --is-ancestor failed: ${r.why}`);
    return r.status === 0;
  };
  const containing = (oid, pattern) => must(['for-each-ref', '--contains', oid, '--format=%(refname:short)', pattern])
    .split(/\r?\n/).filter(Boolean);

  // A merged PR from this branch, and whether it merged the tip the branch
  // still has. Asked only for a branch git alone would call LOCAL ONLY.
  const mergedPrFor = (branch, head) => {
    if (!ghRepo) return null;
    const r = exec('gh', ['pr', 'list', '-R', ghRepo, '--state', 'merged', '--head', branch, '--limit', '20',
      '--json', 'number,headRefOid,mergedAt'], { cwd: root, timeout: 30_000 });
    if (!r.ok) return { unknown: `gh pr list --state merged --head ${branch} failed (${r.why})` };
    let prs;
    try { prs = JSON.parse(r.out); } catch { return { unknown: `gh pr list --head ${branch} printed something that is not JSON` }; }
    if (!Array.isArray(prs)) return { unknown: `gh pr list --head ${branch} printed something that is not a list` };
    if (prs.length === 0) return null;
    const pr = [...prs].sort((a, b) => String(b.mergedAt).localeCompare(String(a.mergedAt)))[0];
    if (pr.headRefOid === head) return { number: pr.number, extra: 0 };
    if (!git(['cat-file', '-e', `${pr.headRefOid}^{commit}`]).ok) return { number: pr.number, extra: null };
    return { number: pr.number, extra: Number(must(['rev-list', '--count', `${pr.headRefOid}..${head}`])) };
  };

  const factsFor = (head, branch) => {
    const f = { head, branch, base, isDefault: !!branch && branch === def };
    if (!head || !base) return f;
    if (f.isDefault) { f.vsBase = count(head, base); return f; }
    const pushedOid = branch && refs.get(`refs/remotes/${REMOTE}/${branch}`);
    if (pushedOid) { f.pushed = true; f.vsPushed = count(head, pushedOid); return f; }
    f.inBase = isAncestor(head, base);
    if (f.inBase) return f;
    if (!branch) {
      f.onRemoteBranch = containing(head, `refs/remotes/${REMOTE}`).length > 0;
      if (f.onRemoteBranch) return f;
    }
    f.otherRemote = containing(head, 'refs/remotes')[0] ?? null;
    if (branch) f.mergedPr = mergedPrFor(branch, head);
    return f;
  };

  // Every worktree.
  say('  worktrees:');
  for (const t of trees) {
    const label = `${rel(t.path)} ${t.branch ? `[${t.branch}]` : t.head ? `detached ${t.head.slice(0, 9)}` : '[no branch]'}`;
    if (!existsSync(t.path)) { say(`    ${rel(t.path)}: MISSING (git worktree prune?)`); continue; }
    try {
      const state = classifyBranch(factsFor(t.head, t.branch));
      if (state.unknown) failed++;
      const status = exec('git', ['status', '--porcelain'], { cwd: t.path });
      if (!status.ok) throw new ProbeError(`git status failed: ${status.why}`);
      const dirty = status.out.split(/\r?\n/).filter(Boolean).length;
      say(`    ${label}: ${state.text}${dirty ? `, ${dirty} uncommitted` : ''}`);
    } catch (e) {
      if (!(e instanceof ProbeError)) throw e;
      failed++;
      say(`    ${label}: UNKNOWN: ${e.message}`);
    }
  }

  // Branches no worktree has checked out: the work that is easiest to forget.
  const held = new Set(trees.map((t) => t.branch).filter(Boolean));
  const loose = [];
  let merged = 0;
  for (const [ref, oid] of refs) {
    if (!ref.startsWith('refs/heads/')) continue;
    const name = ref.slice('refs/heads/'.length);
    if (held.has(name)) continue;
    try {
      const state = classifyBranch(factsFor(oid, name));
      if (state.unknown) failed++;
      if (state.kind === 'merged') merged++;
      else if (state.kind !== 'pushed') loose.push(`    ${name}: ${state.kind === 'unpushed' ? state.text.replace(/^ahead (\d+) \/ behind 0 of.*$/, '$1 commit(s) not pushed') : state.text}`);
    } catch (e) {
      if (!(e instanceof ProbeError)) throw e;
      failed++;
      loose.push(`    ${name}: UNKNOWN: ${e.message}`);
    }
  }
  say(`  branches no worktree holds, not in full on ${base ?? 'a remote'}:`);
  say(loose.length ? loose.join('\n') : '    none');
  if (merged) say(`    (${merged} more are merged into ${base}, and hold nothing it lacks)`);

  // Open PRs.
  if (!ghRepo) {
    say(`  open PRs: '${REMOTE}' is not a GitHub repo`);
  } else {
    say(`  open PRs (${ghRepo}):`);
    const r = exec('gh', ['pr', 'list', '-R', ghRepo, '--state', 'open', '--limit', '100',
      '--json', 'number,title,headRefName,isDraft,statusCheckRollup'], { cwd: root, timeout: 60_000 });
    let prs = null;
    if (!r.ok) unknown(`gh pr list -R ${ghRepo} failed (${r.why}): open PRs and CI not checked`);
    else {
      try { prs = JSON.parse(r.out); } catch { /* reported below */ }
      if (!Array.isArray(prs)) { prs = null; unknown('gh pr list printed something that is not a JSON list'); }
    }
    if (prs && prs.length === 0) say('    none');
    for (const pr of prs ?? []) {
      say(`    #${pr.number} [${pr.headRefName}]${pr.isDraft ? ' draft' : ''} ${ciVerdict(pr.statusCheckRollup)}: ${pr.title}`);
    }
  }

  // Dev servers. Windows only: this is the process table the `windows-shell`
  // skill reads by hand, and CI has no server to leave behind.
  say('  dev servers:');
  if (platform !== 'win32') {
    say(`    not checked: this probe reads the Windows process table, and this is ${platform}`);
  } else {
    const ps = 'ConvertTo-Json -Compress -InputObject @(Get-CimInstance Win32_Process -Filter '
      + '"Name=\'node.exe\' OR Name=\'workerd.exe\' OR Name=\'cmd.exe\'" | Select-Object ProcessId, ParentProcessId, Name, CommandLine)';
    const r = exec('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps], { cwd: root, timeout: 30_000 });
    let rows = null;
    if (!r.ok) unknown(`the process list failed (${r.why})`);
    else {
      try { rows = JSON.parse(r.out); } catch { /* reported below */ }
      if (!Array.isArray(rows)) { rows = null; unknown('the process list printed something that is not a JSON list'); }
    }
    if (rows) {
      const { servers, orphans } = devServers(rows, trees.map((t) => resolve(t.path)));
      if (servers.length === 0 && orphans.length === 0) say('    none running');
      for (const s of servers) {
        say(`    ${s.port ? `port ${s.port}` : 'no --port on its command line'}: node pid ${s.pids.join(', ')} + ${s.workerd} workerd, `
          + (s.tree ? `serving ${rel(s.tree)}` : 'tree not named on its command line (started by hand)'));
      }
      for (const o of orphans) say(`    workerd pid ${o.pid}${o.port ? ` on port ${o.port}` : ''}: no wrangler parent left; it can still hold a port and a tree's .wrangler/state`);
      if (servers.length || orphans.length) {
        say('    stop one by its command line, not by the listening PID (windows-shell, Killing a dev server)');
      }
    }
  }

  // Junctions inside linked worktrees. The main checkout is not listed: it is
  // never removed, and its links are the stores the others point at.
  say('  junctions in linked worktrees (unlink each with `cmd /c rmdir` before `git worktree remove`):');
  const linked = trees.slice(1).filter((t) => existsSync(t.path));
  if (linked.length === 0) say('    no linked worktree');
  for (const t of linked) {
    try {
      const inside = linksInside(resolve(t.path)).map((p) => relative(resolve(t.path), p).replace(/\\/g, '/'));
      const memory = join(home, '.claude', 'projects', projectDirName(resolve(t.path)), 'memory');
      const memoryLinked = lstatSync(memory, { throwIfNoEntry: false })?.isSymbolicLink() ?? false;
      const found = [
        ...(inside.length ? [`${inside.length} inside (${inside.join(', ')})`] : []),
        ...(memoryLinked ? [`its memory link at ${memory.replace(/\\/g, '/')}, which --remove leaves`] : []),
      ];
      say(`    ${rel(t.path)}: ${found.length ? found.join('; ') : 'none'}`);
    } catch (e) {
      failed++;
      say(`    ${rel(t.path)}: UNKNOWN: could not walk the tree (${e.message})`);
    }
  }

  return finish();
}

// Only when run, not when the suite imports the pure half.
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const { lines, failed } = report({ fetch: !process.argv.includes('--no-fetch') });
  console.log(lines.join('\n'));
  process.exit(failed ? 2 : 0);
}
