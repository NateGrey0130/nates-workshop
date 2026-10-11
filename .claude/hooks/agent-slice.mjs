// agent-slice.mjs - PreToolUse hook on the Agent tool.
//
// Refuses (exit 2) a `book-reconcile` spawn whose brief does not declare a
// bounded slice of the book. Every other agent passes untouched.
//
// Why it exists. One week's usage, read 2026-10-11: long subagent runs
// re-cached their whole context every few calls - 63 times a run's cache read
// fell back to its system prompt and about 212k tokens were written again at
// the 1.25x rate. ONE run of more than 100 calls cost 35M weighted tokens;
// every other run averaged 0.7M. The run that grows is the one handed a whole
// chapter's rows at once, so the control is on the brief: many short runs, each
// ending before its context is large, instead of one long one.
//
// The shape it asks for is one line in the prompt:
//
//     Slice: 40-47, 112-115
//
// PRINTED folios, ranges or single pages, at most MAX_PAGES in total (15 -
// Nate's starting figure, 2026-10-11, to be re-measured against a real run).
// The agent's own definition tells it to stop at the slice.
//
// POSTURE: block. A refusal is not a permission denial - it tells the caller to
// split the work and spawn again, and the reason says how. Like guard-bash.sh
// it FAILS CLOSED on an envelope it cannot parse, so the gap is noticed on the
// first spawn rather than never.
//
// Registered at USER level only (C:\Users\natha\.claude\settings.json), with an
// absolute path. checks/hook-registration.mjs holds the registration and the
// behaviour.

export const MAX_PAGES = 15;
export const BOUNDED = ['book-reconcile'];

// Pages named on the brief's `Slice:` line, or null when there is no such line
// or it names nothing countable. A reversed range (47-40) is unreadable.
export function slicePages(prompt) {
  const m = /^[ \t>*-]*Slice:[ \t]*(.+)$/im.exec(String(prompt ?? ''));
  if (!m) return null;
  let total = 0, any = false;
  for (const part of m[1].split(',')) {
    const r = /(\d+)\s*(?:-|\u2013|to)\s*(\d+)/.exec(part);
    if (r) {
      const a = Number(r[1]), b = Number(r[2]);
      if (b < a) return null;
      total += b - a + 1; any = true;
      continue;
    }
    if (/\d+/.test(part)) { total += 1; any = true; }
  }
  return any ? total : null;
}

// The refusal for one envelope, or null to let the spawn through.
export function refusalFor(envelope) {
  const ti = envelope?.tool_input;
  if (!ti || !BOUNDED.includes(ti.subagent_type)) return null;
  const pages = slicePages(ti.prompt);
  const how = `put one line in the brief - "Slice: 40-47, 112-115" (printed folios, at most ${MAX_PAGES} pages in total) - and spawn one run per slice`;
  if (pages === null) {
    return `a ${ti.subagent_type} brief must declare a bounded slice: one run of 100+ calls cost 35M tokens; ${how}`;
  }
  if (pages > MAX_PAGES) {
    return `this ${ti.subagent_type} slice is ${pages} pages and the cap is ${MAX_PAGES}; split it - ${how}`;
  }
  return null;
}

function main() {
  let s = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (d) => { s += d; });
  process.stdin.on('end', () => {
    let envelope;
    try { envelope = JSON.parse(s); } catch {
      process.stderr.write('agent-slice: could not parse the hook input; refusing rather than spawning unbounded\n');
      process.exit(2);
    }
    const reason = refusalFor(envelope);
    if (reason) {
      process.stderr.write(`agent-slice: ${reason}\n`);
      process.exit(2);
    }
    process.exit(0);
  });
}

if (process.argv[1] && import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) main();
