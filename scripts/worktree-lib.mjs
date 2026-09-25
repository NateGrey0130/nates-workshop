// Setting up and taking down a worktree that a separate session can work in
// without touching any other tree's files, database or branch. Shared by
// scripts/book-worktree.mjs (one per book) and scripts/group-worktree.mjs (one
// per group of apps, groups.json), which differ only in where the tree goes,
// what its branch is called, and which variables its session needs.
//
// A bare `git worktree add` gives a tree missing three things, each of which
// has cost a session here; book-worktree.mjs's header has the history.
//
//   a local D1     of its OWN, built from the tree's files by
//                  scripts/build-local-d1.mjs (about three minutes), or copied
//                  from the main checkout with copyD1 - real files, never a
//                  junction, because a junction is what a worktree removal
//                  deleted through on 2026-09-19
//   the env        written to the tree's .claude/settings.local.json
//                  (gitignored), so a session STARTED there has it
//   memory         keyed to the working directory; the tree's project
//                  directory is linked to the store the main checkout's
//                  memory already resolves to
//
// Removal refuses on uncommitted changes and on any junction or symlink
// inside the tree (the `worktree` skill's reparse-point scan).

import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, lstatSync, mkdirSync, readdirSync, readlinkSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

// Claude Code's project directory name for a working directory: every
// character that is not a letter or a digit becomes '-'. Read off the
// directories on this machine, 2026-09-24: `C:\Users\natha\Projects\nates-apps`
// is `C--Users-natha-Projects-nates-apps`, and a worktree under its
// `.claude\worktrees\` is `...-nates-apps--claude-worktrees-<name>`.
export function projectDirName(path) {
  return path.replace(/[^A-Za-z0-9]/g, '-');
}

export const git = (args, opts = {}) => (execFileSync('git', args, { encoding: 'utf8', ...opts }) ?? '').trim();

// The MAIN checkout, even when this runs inside another worktree.
export function mainCheckout() {
  return dirname(git(['rev-parse', '--path-format=absolute', '--git-common-dir']));
}

// Make the tree at `dest` on a new `branch` off origin/main, give it a local
// D1 and `env`, and link its memory. `die(msg)` reports a failure and exits;
// `removeHint` is the command that takes a half-made tree down.
export function setUpTree({ mainTree, dest, branch, copyD1, env, die, removeHint }) {
  git(['fetch', '--quiet', 'origin', 'main'], { cwd: mainTree, stdio: ['ignore', 'ignore', 'inherit'] });
  mkdirSync(dirname(dest), { recursive: true });
  git(['worktree', 'add', '--quiet', dest, '-b', branch, 'origin/main'], { cwd: mainTree, stdio: ['ignore', 'ignore', 'inherit'] });

  const d1From = join(mainTree, '.wrangler', 'state');
  const d1To = join(dest, '.wrangler', 'state');
  let d1Note;
  if (copyD1 && existsSync(d1From)) {
    cpSync(d1From, d1To, { recursive: true, dereference: true });
    d1Note = `copied from ${d1From} (it carries any unmerged --local applies made there)`;
  } else {
    console.log('building the local D1 from the tree\'s files - a few minutes...');
    const builder = join(dirname(fileURLToPath(import.meta.url)), 'build-local-d1.mjs');
    try {
      execFileSync(process.execPath, [builder, d1To, '--repo', dest], { stdio: ['ignore', 'inherit', 'inherit'] });
    } catch {
      die(`the tree exists at ${dest} but its local D1 did not build (the error is above).\n`
        + `  Take it down with: ${removeHint}, then fix the build or re-run with --copy-d1`);
    }
    d1Note = `built from the repo at ${d1To}`;
  }

  const settings = { env: { ...env, WORKSHOP_LOCAL_D1: d1To } };
  writeFileSync(join(dest, '.claude', 'settings.local.json'), JSON.stringify(settings, null, 2) + '\n');

  const projects = join(homedir(), '.claude', 'projects');
  const mainMemory = join(projects, projectDirName(mainTree), 'memory');
  let memoryNote = 'not linked: the main checkout has no memory directory';
  if (existsSync(mainMemory)) {
    const store = lstatSync(mainMemory).isSymbolicLink() ? readlinkSync(mainMemory) : mainMemory;
    const link = join(projects, projectDirName(dest), 'memory');
    if (existsSync(link)) memoryNote = `already present at ${link}`;
    else {
      mkdirSync(dirname(link), { recursive: true });
      execFileSync('cmd', ['/c', 'mklink', '/J', link, store], { stdio: 'ignore' });
      memoryNote = `linked ${link} -> ${store}`;
    }
  }

  console.log(`worktree   ${dest}`);
  console.log(`branch     ${branch} (off origin/main)`);
  console.log(`local D1   ${d1Note}`);
  console.log(`env        ${Object.keys(settings.env).join(', ')} in .claude/settings.local.json`);
  console.log(`memory     ${memoryNote}`);
}

export function removeTree(dest, die) {
  if (!existsSync(dest)) die(`${dest} does not exist`);
  const dirty = git(['status', '--porcelain'], { cwd: dest });
  if (dirty) die(`${dest} has uncommitted changes:\n${dirty}`);
  const links = [];
  (function walk(dir) {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const p = join(dir, e.name);
      if (lstatSync(p).isSymbolicLink()) links.push(p);
      else if (e.isDirectory()) walk(p);
    }
  })(dest);
  if (links.length) {
    die(`refusing: ${links.length} junction(s) or symlink(s) inside the tree, which a removal can delete through:\n  `
      + links.join('\n  ') + '\n  remove each with `cmd /c rmdir <path>` (removes the link, not its target), then re-run');
  }
  // --force: the tree's own .wrangler/state and settings.local.json are
  // ignored files, and plain `worktree remove` refuses on them.
  git(['worktree', 'remove', '--force', dest], { stdio: ['ignore', 'ignore', 'inherit'] });
  console.log(`removed ${dest}`);
}
