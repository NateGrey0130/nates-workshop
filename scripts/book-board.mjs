#!/usr/bin/env node
// Where every book stands, and who is working on it. Read-only.
//
//   node scripts/book-board.mjs             status, rows, worktree, branches, open PRs
//   node scripts/book-board.mjs --remote    also production's rows against the survey's
//   node scripts/book-board.mjs --merge-check [--tests] [--remote]
//                                           will the open PRs merge together, and in
//                                           what order - scripts/merge-check-lib.mjs
//
// WHY. Several book sessions at once is only safe if each can see the others,
// and none could: a session sees its own branch and nothing else. One place
// shows each book's state, drawn from the things that already hold it:
//
//   status     the survey's `**Status:**` line (docs/surveys/README.md)
//   rows       the survey's `**Rows citing this book:**` line, summed
//   worktree   a git worktree at ../nates-apps-books/<slug>
//              (scripts/book-worktree.mjs), or any worktree on a <slug>- branch
//   branches   local and remote branches named <slug>-...
//   PRs        open pull requests from a <slug>- branch (gh; skipped if gh fails)
//   --remote   rows citing the book in PRODUCTION, beside the survey's count.
//              A difference means data is applied and its PR has not merged,
//              or the survey line is stale. The data apply goes BEFORE the
//              merge here, so a difference during an import is expected, and
//              one that outlives the PR is not.
//
// A branch belongs to the book with the LONGEST slug it starts with, so
// `powers-unlimited-1-gear` cannot be read as `powers-unlimited-...` of a
// shorter slug. Nothing here writes anything.

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { loadBookRegistry, loadNotBooks } from './books-lib.mjs';
import { bookRowsSql, citingTables, countRowsPerBook, parseRowsLine } from './book-rows-lib.mjs';
import { d1Query, repoRoot } from './d1-query-lib.mjs';
import { runMergeCheck } from './merge-check-lib.mjs';

const remote = process.argv.includes('--remote');
if (process.argv.includes('--merge-check')) {
  process.exit(runMergeCheck({ repoRoot, tests: process.argv.includes('--tests'), remote }));
}
const run = (cmd, args) => {
  try { return execFileSync(cmd, args, { cwd: repoRoot, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }); }
  catch { return null; }
};

const registry = loadBookRegistry();
const surveyDir = join(repoRoot, 'apps', 'character-creator', 'docs', 'surveys');
const books = readdirSync(surveyDir).filter((f) => f.endsWith('.md') && f !== 'README.md')
  .map((f) => f.replace(/\.md$/, '')).sort();

const survey = {};
for (const slug of books) {
  const text = readFileSync(join(surveyDir, `${slug}.md`), 'utf8');
  const rows = parseRowsLine(text);
  survey[slug] = {
    status: /^\*\*Status:\*\* `([a-z-]+)`/m.exec(text)?.[1] ?? '?',
    rows,
    total: rows ? Object.values(rows).reduce((a, b) => a + b, 0) : null,
  };
}

// The book a branch or path belongs to: the longest slug it starts with.
const bySlugLength = [...books].sort((a, b) => b.length - a.length);
const ownerOf = (name) => bySlugLength.find((s) => name === s || name.startsWith(`${s}-`)) ?? null;

// Worktrees.
const trees = {};
const porcelain = run('git', ['worktree', 'list', '--porcelain']) ?? '';
for (const block of porcelain.split(/\r?\n\r?\n/)) {
  const path = /^worktree (.+)$/m.exec(block)?.[1];
  const branch = /^branch refs\/heads\/(.+)$/m.exec(block)?.[1];
  if (!path) continue;
  const inBooksDir = basename(dirname(path)) === 'nates-apps-books' ? basename(path) : null;
  const slug = (inBooksDir && books.includes(inBooksDir) ? inBooksDir : null) ?? (branch ? ownerOf(branch) : null);
  if (slug) (trees[slug] ??= []).push(branch ? `${path} [${branch}]` : path);
}

// Branches, local and remote.
const branches = {};
const refs = run('git', ['for-each-ref', '--format=%(refname:short)', 'refs/heads', 'refs/remotes/origin']) ?? '';
for (const ref of refs.split(/\r?\n/).filter(Boolean)) {
  const name = ref.replace(/^origin\//, '');
  const slug = ownerOf(name);
  if (slug) (branches[slug] ??= new Set()).add(ref);
}

// Open PRs.
const prs = {};
const prJson = run('gh', ['pr', 'list', '--state', 'open', '--limit', '100', '--json', 'number,headRefName,title']);
if (prJson) {
  for (const pr of JSON.parse(prJson)) {
    const slug = ownerOf(pr.headRefName);
    if (slug) (prs[slug] ??= []).push(`#${pr.number} ${pr.headRefName}`);
  }
}

// Production's rows, per book.
let prod = null;
if (remote) {
  const rows = d1Query(bookRowsSql(citingTables(repoRoot)), { target: '--remote' });
  const { perBook } = countRowsPerBook(rows, { registry, notBooks: loadNotBooks(), surveyed: books });
  prod = Object.fromEntries(books.map((s) => [s, Object.values(perBook[s] ?? {}).reduce((a, b) => a + b, 0)]));
}

const pad = (s, n) => String(s).padEnd(n);
const w = Math.max(...books.map((s) => s.length)) + 2;
console.log(pad('book', w) + pad('status', 12) + pad('rows', 7) + (remote ? pad('prod', 7) : '') + 'activity');
for (const slug of books) {
  const s = survey[slug];
  const activity = [
    ...(trees[slug] ?? []).map((t) => `worktree ${t}`),
    ...[...(branches[slug] ?? [])].map((b) => `branch ${b}`),
    ...(prs[slug] ?? []).map((p) => `PR ${p}`),
  ];
  let prodCell = '';
  if (remote) prodCell = pad(prod[slug] === s.total ? prod[slug] : `${prod[slug]}*`, 7);
  console.log(pad(slug, w) + pad(s.status, 12) + pad(s.total ?? '?', 7) + prodCell
    + (activity.length ? activity.join('; ') : '-'));
}
const unsurveyed = Object.keys(registry).filter((s) => !books.includes(s));
if (unsurveyed.length) console.log(`\nregistered with no survey: ${unsurveyed.join(', ')}`);
if (!prJson) console.log('\nopen PRs not shown: `gh pr list` failed');
if (remote) console.log('\n* production differs from the survey line: data applied ahead of its merge, or a stale line');
