#!/usr/bin/env node
// plan-board.mjs - where every plan stands, at a glance.
//
//   node .claude/scripts/plan-board.mjs                 every plan that is not DONE
//   node .claude/scripts/plan-board.mjs <plan>          one plan (a folder name, or part of one)
//   node .claude/scripts/plan-board.mjs --all           finished plans too
//   node .claude/scripts/plan-board.mjs --json          the same reading as one object
//   node .claude/scripts/plan-board.mjs --no-gh         state.md and the briefs only
//   node .claude/scripts/plan-board.mjs --limit 800     how many recent pull requests to read (default 400)
//   node .claude/scripts/plan-board.mjs --root <dir>    another plans directory
//   node .claude/scripts/plan-board.mjs --export <dir>  also write reading.json, plans.json and rows.json there
//
// --export is what the Plan Board page is refreshed from: every plan's
// headline, and the rows of each plan that is not DONE. It is the only thing
// this script writes, and only into the directory named.
//
// Otherwise it READS and writes nothing: `state.md` for the position, `rows\*.md` for the
// row list and each row's branch, and one `gh pr list` for what became of each
// branch. The decisions are in plan-board-lib.mjs beside this file.
//
// Exit 0 is a complete reading. Exit 2 is "could not read": a plan whose
// state.md could not be placed, or GitHub unread without --no-gh. The board is
// still printed, with the gap named. A pull request older than --limit is not
// found, so a long-finished plan's rows read `done`, not `merged`.
//
// "moved" is the newest write to state.md or any brief. A plan that is not
// DONE or BLOCKED and has not moved for hours probably has no driver:
// `/go resume <plan>` reads why before it starts one.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { age, deriveRows, indexPulls, parseBrief, parseState } from './plan-board-lib.mjs';

const REPO = 'NateGrey0130/nates-workshop';
const DEFAULT_ROOT = join(homedir(), '.claude', 'projects', 'C--Users-natha-Projects-nates-apps', 'memory', 'plans');

const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const valueOf = (name) => { const i = args.indexOf(name); return i === -1 ? null : args[i + 1]; };
const valued = new Set(['--root', '--limit', '--export']);
const wanted = args.filter((a, i) => !a.startsWith('--') && !valued.has(args[i - 1]));
const root = valueOf('--root') ?? DEFAULT_ROOT;
const limit = Number(valueOf('--limit') ?? 400);
const exportDir = valueOf('--export');

if (flag('--help') || !Number.isInteger(limit) || limit < 1) {
  console.error('usage: node .claude/scripts/plan-board.mjs [plan] [--all] [--json] [--no-gh] [--limit N] [--root <dir>] [--export <dir>]');
  process.exit(2);
}
if (!existsSync(root)) {
  console.error(`plan-board: no plans directory at ${root}`);
  process.exit(2);
}

let incomplete = false;

function readPlan(name) {
  const dir = join(root, name);
  const statePath = join(dir, 'state.md');
  const rowsDir = join(dir, 'rows');
  if (!existsSync(statePath)) return null;
  const state = parseState(readFileSync(statePath, 'utf8'));
  let moved = statSync(statePath).mtimeMs;
  const briefs = [];
  if (existsSync(rowsDir)) {
    for (const file of readdirSync(rowsDir)) {
      if (!file.endsWith('.md')) continue;
      const path = join(rowsDir, file);
      moved = Math.max(moved, statSync(path).mtimeMs);
      briefs.push(parseBrief(file.slice(0, -3), readFileSync(path, 'utf8')));
    }
  }
  return { name, state, briefs, moved };
}

const folders = readdirSync(root, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => d.name).sort();
const plans = folders.map(readPlan);
const noState = folders.filter((_, i) => plans[i] === null);
let shown = plans.filter(Boolean);
const finished = shown.filter((p) => p.state.kind === 'DONE').length;
if (wanted.length) {
  shown = shown.filter((p) => wanted.some((w) => p.name === w || p.name.includes(w)));
  if (!shown.length) {
    console.error(`plan-board: no plan with a state.md matches ${wanted.join(', ')}`);
    process.exit(2);
  }
} else if (!flag('--all') && !exportDir) {
  shown = shown.filter((p) => p.state.kind !== 'DONE');
}

let pulls = null;
let githubNote = null;
if (flag('--no-gh')) {
  githubNote = 'GitHub not read (--no-gh): statuses are from state.md and the briefs alone';
} else if (shown.some((p) => p.briefs.length)) {
  try {
    pulls = indexPulls(JSON.parse(execFileSync('gh',
      ['pr', 'list', '--repo', REPO, '--state', 'all', '--limit', String(limit),
        '--json', 'number,state,headRefName,mergedAt,url'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], maxBuffer: 64 * 1024 * 1024 })));
  } catch (err) {
    incomplete = true;
    githubNote = `GitHub UNREAD (${String(err.message).split('\n')[0]}): statuses are from state.md and the briefs alone`;
  }
}

const now = Date.now();
const clip = (s, n) => (s.length > n ? `${s.slice(0, Math.max(0, n - 1))}…` : s);
const board = shown.map((p) => {
  const derived = deriveRows(p.state, p.briefs, pulls);
  if (p.state.kind === 'UNKNOWN') incomplete = true;
  return {
    name: p.name,
    state: p.state,
    movedAt: new Date(p.moved).toISOString(),
    movedAgo: age(now - p.moved),
    total: derived.total,
    done: derived.done,
    // Read, not repaired: `/go resume` owns what to do about a state.md like this.
    stale: p.state.kind !== 'DONE' && derived.total > 0 && derived.rows.every((r) => r.status === 'merged' || r.status === 'split')
      ? 'every row has merged, and state.md does not say DONE' : null,
    rows: derived.rows,
  };
});

const headline = (s) => {
  if (s.kind === 'DONE') return 'DONE';
  if (s.kind === 'UNKNOWN') return `UNKNOWN (state.md begins: ${clip(s.first, 50) || 'nothing'})`;
  const next = s.nextId ? `next row ${s.nextId}` : 'no next row named';
  return s.kind === 'NEXT' ? next : `${s.kind}, ${next}`;
};

if (exportDir) {
  mkdirSync(exportDir, { recursive: true });
  const put = (name, rows) => writeFileSync(join(exportDir, name), JSON.stringify(rows, null, 1), 'utf8');
  put('reading.json', [{
    generated_at: new Date(now).toISOString(),
    complete: !incomplete,
    github_note: githubNote ?? '',
    plans_in_progress: board.filter((p) => p.state.kind !== 'DONE').length,
    plans_finished: board.filter((p) => p.state.kind === 'DONE').length,
  }]);
  put('plans.json', board.map((p) => ({
    plan: p.name,
    kind: p.state.kind,
    headline: headline(p.state),
    first_line: p.state.first,
    next_row: p.state.nextId ?? '',
    last_row: p.state.lastRow ?? '',
    in_flight: p.state.inFlight ?? '',
    rows_done: p.done,
    rows_total: p.total,
    moved_at: p.movedAt,
    note: p.stale ?? '',
  })));
  put('rows.json', board.filter((p) => p.state.kind !== 'DONE').flatMap((p) => p.rows.map((r, i) => ({
    plan: p.name,
    row: r.id,
    order: i + 1,
    status: r.status,
    what: r.title,
    branch: r.branch ?? '',
    pr: r.pr?.number ?? '',
    pr_url: r.pr?.url ?? '',
  }))));
  console.log(`plan-board: wrote reading.json, plans.json and rows.json to ${exportDir}`);
  if (!flag('--all')) board.splice(0, board.length, ...board.filter((p) => p.state.kind !== 'DONE'));
}

if (flag('--json')) {
  console.log(JSON.stringify({
    generatedAt: new Date(now).toISOString(),
    complete: !incomplete,
    githubNote,
    finishedPlans: finished,
    foldersWithoutState: noState,
    plans: board,
  }, null, 2));
  process.exit(incomplete ? 2 : 0);
}

const width = Math.max(60, Math.min(process.stdout.columns || 110, 160));
const label = (r) => {
  if (r.status === 'merged') return `merged #${r.pr.number}`;
  if (r.status === 'open') return `open #${r.pr.number}`;
  if (r.status === 'next') return '> NEXT';
  return r.status;
};

console.log(`PLAN BOARD - ${new Date(now).toLocaleString('sv-SE').slice(0, 16)}`);
if (!board.length) console.log('  no plan is in progress');
for (const p of board) {
  console.log('');
  const bar = p.total ? `${p.done}/${p.total} rows done` : 'no briefs';
  console.log(`${p.name}   ${bar}   ${headline(p.state)}   moved ${p.movedAgo} ago`);
  if (p.state.kind === 'BLOCKED' || p.state.kind === 'READY') console.log(`  ${clip(p.state.first, width - 2)}`);
  if (p.stale) console.log(`  ${p.stale}`);
  if (p.state.lastRow) console.log(`  last row: ${clip(p.state.lastRow, width - 12)}`);
  if (p.state.inFlight && !/^nothing\.?$/i.test(p.state.inFlight)) console.log(`  in flight: ${clip(p.state.inFlight, width - 13)}`);
  const idWidth = Math.max(...p.rows.map((r) => r.id.length), 2);
  const labelWidth = Math.max(...p.rows.map((r) => label(r).length), 7);
  for (const r of p.rows) {
    const lead = `  ${r.id.padStart(idWidth)}  ${label(r).padEnd(labelWidth)}  `;
    console.log(lead + clip(r.title, width - lead.length));
  }
}
console.log('');
console.log(`${finished} finished plan${finished === 1 ? '' : 's'} not shown above unless --all or named.`
  + (noState.length ? ` ${noState.length} folder${noState.length === 1 ? '' : 's'} with no state.md.` : ''));
if (githubNote) console.log(githubNote);
console.log(incomplete ? 'PLAN BOARD: INCOMPLETE' : 'PLAN BOARD: complete');
process.exit(incomplete ? 2 : 0);
