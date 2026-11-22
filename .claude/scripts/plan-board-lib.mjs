// plan-board-lib.mjs - the decisions behind plan-board.mjs, with no file or
// network access, so the smoke suite can drive them with text.
//
// A plan's progress is DERIVED here and stored nowhere. `state.md` is six lines
// and not a history (`plan-rows` -> "Where a plan is stored"), so it gives the
// position only; the briefs give the row list and each row's branch; GitHub
// gives what happened to each branch. Three readings, in that order of trust
// for a row's fate: a pull request on the row's branch, then the position.

const ID = /^(\d+)([a-z]*)$/;

// Run order: the number, then the letters a split added (9, 9a, 9b, 10).
export function compareIds(a, b) {
  const ma = ID.exec(String(a)), mb = ID.exec(String(b));
  if (!ma || !mb) return ma ? -1 : mb ? 1 : String(a).localeCompare(String(b));
  return (Number(ma[1]) - Number(mb[1])) || ma[2].localeCompare(mb[2]);
}

// The first line decides the kind. A NEXT line is looked for on every line,
// because READY sits above one and a BLOCKED or STOPPED file may carry one too.
// STOPPED is a worker's stop (`STOPPED: <cause>`, with an optional
// `Resume: <branch> <commit>` line); BLOCKED is the driver's, and a person's.
export function parseState(text) {
  const lines = String(text ?? '').split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
  const first = lines[0] ?? '';
  const out = { kind: 'UNKNOWN', first, nextId: null, thenId: null, lastRow: null, lastRowId: null, inFlight: null,
    cause: null, resume: null };
  if (/^DONE\b/.test(first)) out.kind = 'DONE';
  else if (/^NEXT:/.test(first)) out.kind = 'NEXT';
  else if (/^READY:/.test(first)) out.kind = 'READY';
  else if (/^BLOCKED:/.test(first)) out.kind = 'BLOCKED';
  else if (/^STOPPED:/.test(first)) {
    out.kind = 'STOPPED';
    out.cause = first.replace(/^STOPPED:\s*/, '');
  }
  for (const line of lines) {
    const resume = /^Resume:\s*(\S+)\s+([0-9a-f]{7,40})\b/i.exec(line);
    if (resume && out.resume === null) out.resume = { branch: resume[1], commit: resume[2] };
    const next = /^NEXT:\s*row\s+(\d+[a-z]*)/i.exec(line);
    if (next && out.nextId === null) {
      out.nextId = next[1];
      out.thenId = /then\s+row\s+(\d+[a-z]*)/i.exec(line)?.[1] ?? null;
    }
    const last = /^Last row:\s*(.*)$/i.exec(line);
    if (last) {
      out.lastRow = last[1];
      out.lastRowId = /^(?:row\s+)?(\d+[a-z]*)\b/i.exec(last[1])?.[1] ?? null;
    }
    const flight = /^In flight:\s*(.*)$/i.exec(line);
    if (flight) out.inFlight = flight[1];
  }
  // A NEXT line that names no row cannot be placed: say so. READY alone can be
  // (a plan's last row has no NEXT under it), and its rows are read off GitHub.
  // A STOPPED with no NEXT line keeps its kind: plan-tick says it names no row.
  if (out.kind === 'NEXT' && out.nextId === null) out.kind = 'UNKNOWN';
  return out;
}

// Line 1 is the title; the branch is the first backticked name after the word.
// `Next row: 5.` gives nextRow '5'; a `Next row:` naming no row (`none`, `DONE`,
// the plan's last row) gives 'DONE'; no `Next row:` at all gives null.
export function parseBrief(id, text) {
  const lines = String(text ?? '').split(/\r?\n/);
  const head = (lines.find((l) => l.trim()) ?? '').trim();
  const title = (/^#\s*Row\s+\S+?:\s*(.*)$/i.exec(head)?.[1] ?? head.replace(/^#\s*/, '')).trim();
  const top = lines.slice(0, 12).join('\n');
  const next = /\bNext row:\s*(?:row\s+)?([^\s.,;]*)/i.exec(top);
  return {
    id: String(id),
    title,
    branch: /\bbranch\s+`([^`\s]+)`/i.exec(top)?.[1] ?? null,
    nextRow: !next ? null : (/^\d+[a-z]*$/.test(next[1]) ? next[1] : 'DONE'),
  };
}

// One pull request per branch: a merged one wins, then an open one, then the
// newest closed one.
export function indexPulls(pulls) {
  const rank = { MERGED: 3, OPEN: 2, CLOSED: 1 };
  const byBranch = new Map();
  for (const pr of pulls ?? []) {
    const held = byBranch.get(pr.headRefName);
    const better = !held || (rank[pr.state] ?? 0) > (rank[held.state] ?? 0)
      || ((rank[pr.state] ?? 0) === (rank[held.state] ?? 0) && pr.number > held.number);
    if (better) byBranch.set(pr.headRefName, pr);
  }
  return byBranch;
}

export const DONE_STATUSES = ['merged', 'pushed', 'done'];

// state: parseState's answer. briefs: parseBrief's, any order. pulls: a Map
// from indexPulls, or null when GitHub was not read.
//
// A row's status is one of:
//   merged   a pull request on its branch merged
//   open     its branch's pull request is open, and this row is the one that ships it
//   pushed   an extraction row: its branch is pushed and a later row ships it
//   done     behind the position, with no pull request found on its branch
//   next     the row state.md names: queued or being worked right now
//   pending  after the position
//   split    replaced by lettered rows (9 -> 9a, 9b); not counted
//   unknown  state.md gives no position and GitHub gives no answer
export function deriveRows(state, briefs, pulls) {
  const rows = [...briefs].sort((a, b) => compareIds(a.id, b.id));
  const number = (id) => ID.exec(id)?.[1];
  const hasLetters = (id) => Boolean(ID.exec(id)?.[2]);
  const shipper = new Map(); // branch -> the last row in run order that carries it
  for (const row of rows) if (row.branch) shipper.set(row.branch, row.id);

  const position = (id) => {
    if (state.kind === 'DONE') return 'before';
    if (state.nextId !== null) {
      const c = compareIds(id, state.nextId);
      return c < 0 ? 'before' : c === 0 ? 'at' : 'after';
    }
    if (state.lastRowId !== null) return compareIds(id, state.lastRowId) <= 0 ? 'before' : 'after';
    return null;
  };

  const out = rows.map((row) => {
    const pr = (row.branch && pulls?.get(row.branch)) || null;
    const ships = !row.branch || shipper.get(row.branch) === row.id;
    const where = position(row.id);
    let status;
    if (!hasLetters(row.id) && rows.some((r) => r.id !== row.id && hasLetters(r.id) && number(r.id) === number(row.id))) {
      status = 'split';
    } else if (pr?.state === 'MERGED') status = 'merged';
    else if (pr?.state === 'OPEN') status = ships ? 'open' : 'pushed';
    else if (where === 'before') status = ships ? 'done' : 'pushed';
    else if (where === 'at') status = 'next';
    else if (where === 'after') status = 'pending';
    else status = 'unknown';
    return {
      ...row,
      status,
      pr: pr ? { number: pr.number, state: pr.state, url: pr.url ?? null, mergedAt: pr.mergedAt ?? null } : null,
    };
  });

  const counted = out.filter((r) => r.status !== 'split');
  return {
    rows: out,
    total: counted.length,
    done: counted.filter((r) => DONE_STATUSES.includes(r.status)).length,
  };
}

export function age(ms) {
  if (!Number.isFinite(ms) || ms < 0) return '?';
  const minutes = Math.floor(ms / 60000);
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  if (hours < 48) return `${hours}h ${minutes % 60}m`;
  return `${Math.floor(hours / 24)}d`;
}
