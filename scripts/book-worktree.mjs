#!/usr/bin/env node
// One worktree per book, set up so two book sessions cannot touch each other.
//
//   node scripts/book-worktree.mjs <slug>                 make it
//   node scripts/book-worktree.mjs <slug> --branch <name> first branch (default <slug>-work)
//   node scripts/book-worktree.mjs <slug> --copy-d1       copy the main checkout's local D1
//                                                          instead of building one (seconds, not minutes)
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
//                     read the other's unmerged rows. This BUILDS one from the
//                     tree's own files with scripts/build-local-d1.mjs - the
//                     clean build regression.mjs uses - about three minutes
//                     on this machine
//                     (166 s, 2026-09-25). Until 2026-09-25 it copied the main
//                     checkout's .wrangler/state, which carried any --local
//                     applies made there and not yet merged; --copy-d1 still
//                     does that, as real files and never a junction, because a
//                     junction is what a worktree removal deleted through on
//                     2026-09-19.
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
// A dev server started in the tree serves the tree's own .wrangler/state. Use one of .claude/launch.json's -879x hatch ports if another
// checkout has 8788.

import { existsSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import { loadBookRegistry } from './books-lib.mjs';
import { mainCheckout, removeTree, setUpTree } from './worktree-lib.mjs';

// The setup itself is scripts/worktree-lib.mjs, shared with group-worktree.mjs.
// This name stays exported here because the smoke test imports it from here.
export { projectDirName } from './worktree-lib.mjs';

const die = (msg) => { console.error(`book-worktree: ${msg}`); process.exit(1); };

// Only when run, not when smoke imports projectDirName.
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main();
}

function main() {
  const args = process.argv.slice(2);
  const slug = args.find((a, i) => !a.startsWith('--') && args[i - 1] !== '--branch');
  if (!slug) die('usage: node scripts/book-worktree.mjs <slug> [--branch <name>] [--copy-d1] [--remove]');
  if (!loadBookRegistry()[slug]) die(`"${slug}" is not in scripts/books.json - register the book first`);

  const mainTree = mainCheckout();
  const dest = join(dirname(mainTree), 'nates-apps-books', slug);

  if (args.includes('--remove')) return removeTree(dest, die);

  if (existsSync(dest)) die(`${dest} already exists`);
  const bi = args.indexOf('--branch');
  const branch = bi === -1 ? `${slug}-work` : args[bi + 1];
  if (!branch || !branch.startsWith(`${slug}-`)) {
    die(`branch "${branch}" must start with "${slug}-" - a book's branches are found by that prefix`);
  }

  setUpTree({
    mainTree, dest, branch,
    copyD1: args.includes('--copy-d1'),
    env: { WORKSHOP_OCR_CACHE: join(mainTree, '.cache', 'books') },
    die,
    removeHint: `node scripts/book-worktree.mjs ${slug} --remove`,
  });
  console.log(`
Start the ${slug} session with its working directory at ${dest}.`);
}
