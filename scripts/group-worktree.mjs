#!/usr/bin/env node
// One worktree per group of apps, so sessions on different groups run at once
// without touching each other's files, branch or local database.
//
//   node scripts/group-worktree.mjs <group>                  make it
//   node scripts/group-worktree.mjs <group> --name <n>        a second tree for the same group
//   node scripts/group-worktree.mjs <group> --branch <name>   first branch (default <group>-work)
//   node scripts/group-worktree.mjs <group> --copy-d1         copy the main checkout's local D1
//   node scripts/group-worktree.mjs <group> --remove [--name <n>]
//
// <group> is one of groups.json's app groups: palladium, marvel, tools.
//
// WHY. The repo is three unrelated groups (groups.json), and the point of
// naming them is concurrent work. A session per group needs a tree per group:
// two sessions in one tree share the branch and the working files, and neither
// can see the other editing (one-session-per-tree). This is the same setup as a
// book's worktree - scripts/worktree-lib.mjs does both - with the tree at
// <parent of the main checkout>/nates-apps-groups/<group>[-<name>].
//
// A Palladium tree also gets WORKSHOP_OCR_CACHE, pointing at the main
// checkout's book caches, since book work is Palladium's. A book session still
// wants scripts/book-worktree.mjs, whose branch names the board reads.
//
// The local D1 is the whole database either way: there is one D1 today, and
// every group's tables are in it.

import { existsSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import { mainCheckout, removeTree, setUpTree } from './worktree-lib.mjs';

const GROUPS = ['palladium', 'marvel', 'tools'];
const die = (msg) => { console.error(`group-worktree: ${msg}`); process.exit(1); };

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main();
}

function main() {
  const args = process.argv.slice(2);
  const valueOf = (flag) => { const i = args.indexOf(flag); return i === -1 ? undefined : args[i + 1]; };
  const group = args.find((a, i) => !a.startsWith('--') && !['--branch', '--name'].includes(args[i - 1]));
  if (!GROUPS.includes(group)) {
    die(`usage: node scripts/group-worktree.mjs <${GROUPS.join('|')}> [--name <n>] [--branch <name>] [--copy-d1] [--remove]`);
  }
  const name = valueOf('--name');
  if (name !== undefined && !/^[a-z0-9-]+$/.test(name)) die(`--name "${name}" must be lowercase letters, digits and hyphens`);

  const mainTree = mainCheckout();
  const dest = join(dirname(mainTree), 'nates-apps-groups', name ? `${group}-${name}` : group);
  const self = `node scripts/group-worktree.mjs ${group}${name ? ` --name ${name}` : ''}`;

  if (args.includes('--remove')) return removeTree(dest, die);

  if (existsSync(dest)) die(`${dest} already exists - take it down with ${self} --remove, or pass --name for a second tree`);
  const branch = valueOf('--branch') ?? `${group}-${name ?? 'work'}`;
  if (!/^[A-Za-z0-9._/-]+$/.test(branch)) die(`branch "${branch}" is not a plain branch name`);

  setUpTree({
    mainTree, dest, branch,
    copyD1: args.includes('--copy-d1'),
    env: group === 'palladium' ? { WORKSHOP_OCR_CACHE: join(mainTree, '.cache', 'books') } : {},
    die,
    removeHint: `${self} --remove`,
  });
  console.log(`\nStart the ${group} session with its working directory at ${dest}.`);
}
