#!/usr/bin/env node
// One worktree per book, set up so two book sessions cannot touch each other.
//
//   node scripts/book-worktree.mjs <slug>                 make it
//   node scripts/book-worktree.mjs <slug> --branch <name> first branch (default <slug>-work)
//   node scripts/book-worktree.mjs <slug> --remove        take it down, safely
//
// WHY. Book sessions run one book each, and two at once need two trees
// (`worktree` skill; one-session-per-tree). A bare `git worktree add` gives a
// tree that is missing four things, and each one has cost a session here:
//
//   the OCR cache     lives under the MAIN checkout's .cache/books. Without
//                     WORKSHOP_OCR_CACHE a survey sees no cached book and would
//                     re-OCR one (SETUP.md -> Worktrees, and the two stores).
//   a local D1        of its OWN. The book work's usual env points
//                     WORKSHOP_LOCAL_D1 at the main checkout's, so two book
//                     sessions would apply --local into one database and each
//                     read the other's unmerged rows. This copies the main
//                     checkout's .wrangler/state into the tree as real files -
//                     not a junction, because a junction is what a worktree
//                     removal deleted through on 2026-09-19.
//   the env itself    written to the tree's own .claude/settings.local.json
//                     (gitignored), so a session STARTED in the tree gets both
//                     variables without anyone typing them.
//   memory            is keyed to the working directory, and a worktree gets an
//                     empty project directory. This links the tree's memory
//                     directory to the store the repo's own already points at,
//                     the way the repo and Downloads are linked.
//
// WHERE. <parent of the main checkout>/nates-apps-books/<slug>, outside the
// main checkout, so a grep or a sweep of the main tree does not wander into
// every book's copy of it.
//
// --remove refuses on uncommitted changes and on any junction or symlink
// inside the tree (the `worktree` skill's reparse-point scan), then runs
// `git worktree remove`. The memory link sits under ~/.claude, outside the
// tree, and is left: it is a pointer, and a later worktree for the same book
// reuses it.
//
// A dev server started in the tree serves the tree's own .wrangler/state, which
// is the copy. Use one of .claude/launch.json's -879x hatch ports if another
// checkout has 8788.

import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, lstatSync, mkdirSync, readdirSync, readlinkSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { pathToFileURL } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import { loadBookRegistry } from './books-lib.mjs';

// Claude Code's project directory name for a working directory: every
// character that is not a letter or a digit becomes '-'. Read off the
// directories on this machine, 2026-09-24: `C:\Users\natha\Projects\nates-apps`
// is `C--Users-natha-Projects-nates-apps`, and a worktree under its
// `.claude\worktrees\` is `...-nates-apps--claude-worktrees-<name>`.
export function projectDirName(path) {
  return path.replace(/[^A-Za-z0-9]/g, '-');
}

const die = (msg) => { console.error(`book-worktree: ${msg}`); process.exit(1); };
const git = (args, opts = {}) => (execFileSync('git', args, { encoding: 'utf8', ...opts }) ?? '').trim();

// Only when run, not when smoke imports projectDirName.
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main();
}

function main() {
  const args = process.argv.slice(2);
  const slug = args.find((a, i) => !a.startsWith('--') && args[i - 1] !== '--branch');
  if (!slug) die('usage: node scripts/book-worktree.mjs <slug> [--branch <name>] [--remove]');
  if (!loadBookRegistry()[slug]) die(`"${slug}" is not in scripts/books.json - register the book first`);

  // The MAIN checkout, even when this runs inside another worktree.
  const mainTree = dirname(git(['rev-parse', '--path-format=absolute', '--git-common-dir']));
  const dest = join(dirname(mainTree), 'nates-apps-books', slug);

  if (args.includes('--remove')) return remove(dest);

  if (existsSync(dest)) die(`${dest} already exists`);
  const bi = args.indexOf('--branch');
  const branch = bi === -1 ? `${slug}-work` : args[bi + 1];
  if (!branch || !branch.startsWith(`${slug}-`)) {
    die(`branch "${branch}" must start with "${slug}-" - a book's branches are found by that prefix`);
  }

  git(['fetch', '--quiet', 'origin', 'main'], { cwd: mainTree, stdio: ['ignore', 'ignore', 'inherit'] });
  mkdirSync(dirname(dest), { recursive: true });
  git(['worktree', 'add', '--quiet', dest, '-b', branch, 'origin/main'], { cwd: mainTree, stdio: ['ignore', 'ignore', 'inherit'] });

  // Its own local D1, copied as files.
  const d1From = join(mainTree, '.wrangler', 'state');
  const d1To = join(dest, '.wrangler', 'state');
  if (existsSync(d1From)) cpSync(d1From, d1To, { recursive: true, dereference: true });
  else mkdirSync(d1To, { recursive: true });

  // The two variables, for a session started in the tree.
  const settings = {
    env: {
      WORKSHOP_OCR_CACHE: join(mainTree, '.cache', 'books'),
      WORKSHOP_LOCAL_D1: d1To,
    },
  };
  writeFileSync(join(dest, '.claude', 'settings.local.json'), JSON.stringify(settings, null, 2) + '\n');

  // Memory: point the tree's project directory at the store the main
  // checkout's memory already resolves to.
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
  console.log(`local D1   ${existsSync(d1From) ? 'copied from' : 'EMPTY - the main checkout has none at'} ${d1From}`);
  console.log(`env        WORKSHOP_OCR_CACHE, WORKSHOP_LOCAL_D1 in .claude/settings.local.json`);
  console.log(`memory     ${memoryNote}`);
  console.log(`\nStart the ${slug} session with its working directory at ${dest}.`);
}

function remove(dest) {
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
