#!/usr/bin/env node
// pr-worker-cost.mjs - what pr-worker runs cost, read from their transcripts.
//
//   node .claude/scripts/pr-worker-cost.mjs                     every pr-worker run
//   node .claude/scripts/pr-worker-cost.mjs --since 2026-10-18  runs that started on or after the date (UTC)
//   node .claude/scripts/pr-worker-cost.mjs --json              the same figures as one object
//   node .claude/scripts/pr-worker-cost.mjs --root <dir>        another projects directory
//   node .claude/scripts/pr-worker-cost.mjs --file <jsonl>      one transcript, with its own figures
//
// Report only; it writes nothing. Exit 0 with figures, 2 when the directory
// cannot be read or no run matches.
//
// WHY IT EXISTS. The process retrospective (2026-10-22) measured pr-worker runs
// with scratch scripts that are gone, so a change meant to make a run cheaper
// had no instrument to read a before and an after from. This is that
// instrument, kept where the plan rows that need it can run it.
//
// WHAT A pr-worker RUN IS. A file <root>/<session>/subagents/agent-<id>.jsonl
// whose first line's message content (a string, or its text blocks) begins
// `State file:` - the way the driver starts every worker. A run's date is that
// first line's `timestamp`.
//
// WHAT IS COUNTED, and the two kinds of duplicate (measured 2026-11-05 on
// transcripts written since 2026-10-14):
//   - One API message is logged as SEVERAL assistant lines, one per content
//     block (thinking, text, each tool_use), every one repeating the message's
//     `usage`. So usage is taken once per `message.id`, from the largest figure
//     any of its lines carries (output_tokens grows across them). Counting
//     every line's usage is the ~1.9x inflation the memory warns about.
//   - Deduping whole LINES by message.id would drop the second and later
//     tool_use blocks of a message. So tool calls are counted by the
//     tool_use block's own `id`, and results by `tool_use_id`, each once.
//     Only `assistant` and `user` lines are read: a `api-request-blob` line
//     repeats earlier tool_use blocks, so a bare grep for "type":"tool_use"
//     over a transcript counts nearly twice the calls.
//   Weighted tokens: input 1, cache_creation 1.25, cache_read 0.1, output 5.
//   Tool-result bytes: UTF-8 bytes of a result's text (string content, or the
//   text of its text blocks), split by the tool_use it answers: Bash whose
//   command names smoke.mjs or regression.mjs is test output, and so is a Read
//   of a file such a command redirected its output to (matched by basename);
//   any other Read is file reads; the rest is other.
//   Image blocks are COUNTED, not sized. Their base64 is no measure of what
//   they cost in context, and since 2026-10-18 it was 536 MB of 592 MB
//   (marvel-book page renders), which made every byte share read as file reads.
//   Output tokens are a floor: a message's lines are logged mid-stream, so
//   the last line of some messages still carries a partial output_tokens.
//
// Transcripts are streamed line by line; none is read whole (the largest are
// near 30 MB).
import { createReadStream, readdirSync, statSync } from 'node:fs';
import { createInterface } from 'node:readline';
import { homedir } from 'node:os';
import { join } from 'node:path';

const WEIGHT = { input: 1, cacheCreation: 1.25, cacheRead: 0.1, output: 5 };
const TEST_CMD = /\b(smoke|regression)\.mjs\b/;
const WORKTREE_CWD = /[\\/]\.claude[\\/]worktrees[\\/]/;

function arg(name) {
  const i = process.argv.indexOf(name);
  return i === -1 ? null : process.argv[i + 1] ?? null;
}
const asJson = process.argv.includes('--json');
const root = arg('--root')
  ?? join(homedir(), '.claude', 'projects', 'C--Users-natha-Projects-nates-apps');
const sinceArg = arg('--since');
const since = sinceArg ? Date.parse(sinceArg) : null;
const oneFile = arg('--file');
if (sinceArg && Number.isNaN(since)) {
  console.error(`--since ${sinceArg}: not a date`);
  process.exit(2);
}

function promptText(line) {
  const c = line?.message?.content;
  if (typeof c === 'string') return c;
  if (Array.isArray(c)) return c.filter((b) => b?.type === 'text').map((b) => b.text ?? '').join('');
  return '';
}

// { bytes, images } of one tool_result: UTF-8 bytes of its text, and how many
// image blocks it carried (their base64 is not counted as bytes).
function resultSize(content) {
  if (typeof content === 'string') return { bytes: Buffer.byteLength(content, 'utf8'), images: 0 };
  if (!Array.isArray(content)) return { bytes: 0, images: 0 };
  let bytes = 0;
  let images = 0;
  for (const b of content) {
    if (b?.type === 'text') bytes += Buffer.byteLength(b.text ?? '', 'utf8');
    else if (b?.type === 'image') images += 1;
  }
  return { bytes, images };
}

// Basenames a test command redirects its output to (`> smoke.txt`, `2>&1 >> "x.log"`).
function redirectTargets(command) {
  const out = [];
  for (const m of command.matchAll(/>{1,2}\s*("?)([^\s"&;|<>]+)\1/g)) {
    const base = m[2].replace(/\\/g, '/').split('/').pop().toLowerCase();
    if (base && !/^\d+$/.test(base)) out.push(base);
  }
  return out;
}
const baseOf = (p) => String(p ?? '').replace(/\\/g, '/').split('/').pop().toLowerCase();

// One transcript: null when it is not a pr-worker run (or is before --since).
async function measure(path, { filter = true } = {}) {
  const rl = createInterface({ input: createReadStream(path, { encoding: 'utf8' }), crlfDelay: Infinity });
  let first = true;
  let run = null;
  const usage = new Map();      // message.id -> max of each field
  const uses = new Map();       // tool_use id -> category
  const answered = new Set();   // tool_use_id already counted
  const skills = new Set();
  const testFiles = new Set();  // basenames test commands wrote their output to
  for await (const raw of rl) {
    if (!raw) continue;
    let j;
    try { j = JSON.parse(raw); } catch { continue; }
    if (first) {
      first = false;
      if (filter && !promptText(j).trimStart().startsWith('State file:')) break;
      const at = Date.parse(j.timestamp);
      if (filter && since !== null && !(at >= since)) break;
      run = {
        path, started: j.timestamp ?? null, worktree: WORKTREE_CWD.test(String(j.cwd ?? '')),
        weighted: 0, toolCalls: 0, bytes: { test: 0, read: 0, other: 0 }, images: 0, skills: [],
      };
    }
    const content = Array.isArray(j.message?.content) ? j.message.content : [];
    if (j.type === 'assistant') {
      const id = j.message?.id;
      const u = j.message?.usage;
      if (id && u) {
        const prev = usage.get(id) ?? { input: 0, cacheCreation: 0, cacheRead: 0, output: 0 };
        usage.set(id, {
          input: Math.max(prev.input, u.input_tokens || 0),
          cacheCreation: Math.max(prev.cacheCreation, u.cache_creation_input_tokens || 0),
          cacheRead: Math.max(prev.cacheRead, u.cache_read_input_tokens || 0),
          output: Math.max(prev.output, u.output_tokens || 0),
        });
      }
      for (const b of content) {
        if (b?.type !== 'tool_use' || !b.id || uses.has(b.id)) continue;
        let cat = 'other';
        const command = String(b.input?.command ?? '');
        if (b.name === 'Read') cat = testFiles.has(baseOf(b.input?.file_path)) ? 'test' : 'read';
        else if (b.name === 'Bash' && TEST_CMD.test(command)) {
          cat = 'test';
          for (const t of redirectTargets(command)) testFiles.add(t);
        }
        uses.set(b.id, cat);
        if (b.name === 'Skill' && b.input?.skill) skills.add(String(b.input.skill));
      }
    } else if (j.type === 'user') {
      for (const b of content) {
        if (b?.type !== 'tool_result' || !b.tool_use_id || answered.has(b.tool_use_id)) continue;
        answered.add(b.tool_use_id);
        const size = resultSize(b.content);
        run.bytes[uses.get(b.tool_use_id) ?? 'other'] += size.bytes;
        run.images += size.images;
      }
    }
  }
  rl.close();
  if (!run) return null;
  for (const u of usage.values()) {
    run.weighted += u.input * WEIGHT.input + u.cacheCreation * WEIGHT.cacheCreation
      + u.cacheRead * WEIGHT.cacheRead + u.output * WEIGHT.output;
  }
  run.weighted = Math.round(run.weighted);
  run.messages = usage.size;
  run.toolCalls = uses.size;
  run.skills = [...skills].sort();
  return run;
}

function transcripts(dir) {
  const out = [];
  for (const session of readdirSync(dir)) {
    const sub = join(dir, session, 'subagents');
    let names;
    try { names = readdirSync(sub); } catch { continue; }
    for (const n of names) if (/^agent-[\w-]+\.jsonl$/.test(n)) out.push(join(sub, n));
  }
  return out;
}

// Nearest-rank percentile of a numeric array.
function pct(values, p) {
  if (values.length === 0) return 0;
  const s = [...values].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.max(0, Math.ceil((p / 100) * s.length) - 1))];
}

const mb = (n) => (n / 1e6).toFixed(1);
const share = (n, of) => (of ? Math.round((100 * n) / of) : 0);

async function main() {
  if (oneFile) {
    const run = await measure(oneFile, { filter: false });
    if (!run) { console.error(`${oneFile}: no lines`); process.exit(2); }
    console.log(asJson ? JSON.stringify(run) : [
      `file: ${oneFile}`,
      `started: ${run.started}  worktree cwd: ${run.worktree ? 'yes' : 'no'}`,
      `api messages: ${run.messages}  tool calls: ${run.toolCalls}  weighted tokens: ${run.weighted}`,
      `tool-result bytes: test ${run.bytes.test}, read ${run.bytes.read}, other ${run.bytes.other}; image results ${run.images}`,
      `skills: ${run.skills.join(', ') || 'none'}`,
    ].join('\n'));
    return;
  }

  let files;
  try { files = transcripts(root); } catch (err) {
    console.error(`${root}: unreadable - ${err.message}`);
    process.exit(2);
  }
  const runs = [];
  for (const f of files) {
    const r = await measure(f);
    if (r) runs.push(r);
  }
  if (runs.length === 0) {
    console.error(`no pr-worker runs under ${root}${sinceArg ? ` since ${sinceArg}` : ''} (${files.length} subagent transcripts read)`);
    process.exit(2);
  }

  const weighted = runs.map((r) => r.weighted);
  const calls = runs.map((r) => r.toolCalls);
  const bytes = { test: 0, read: 0, other: 0 };
  let images = 0;
  const skillRuns = new Map();
  for (const r of runs) {
    images += r.images;
    for (const k of Object.keys(bytes)) bytes[k] += r.bytes[k];
    for (const s of r.skills) skillRuns.set(s, (skillRuns.get(s) ?? 0) + 1);
  }
  const total = bytes.test + bytes.read + bytes.other;
  const skills = [...skillRuns.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .map(([name, n]) => ({ name, runs: n, pct: share(n, runs.length) }));
  const worktree = runs.filter((r) => r.worktree).length;
  const summary = {
    root, since: sinceArg, transcriptsRead: files.length, runs: runs.length,
    weightedTokens: { median: pct(weighted, 50), p95: pct(weighted, 95), total: weighted.reduce((a, b) => a + b, 0) },
    toolCalls: { p50: pct(calls, 50), p95: pct(calls, 95) },
    toolResultBytes: { ...bytes, total, testPct: share(bytes.test, total), readPct: share(bytes.read, total), otherPct: share(bytes.other, total) },
    imageResults: images,
    skills,
    worktreeCwd: { runs: worktree, pct: share(worktree, runs.length) },
  };

  if (asJson) { console.log(JSON.stringify(summary)); return; }
  const t = summary.toolResultBytes;
  console.log([
    `pr-worker runs${sinceArg ? ` since ${sinceArg}` : ''}: ${runs.length} (of ${files.length} subagent transcripts under ${root})`,
    `weighted tokens per run: median ${summary.weightedTokens.median}, p95 ${summary.weightedTokens.p95} (input 1, cache_creation 1.25, cache_read 0.1, output 5)`,
    `tool calls per run: p50 ${summary.toolCalls.p50}, p95 ${summary.toolCalls.p95}`,
    `tool-result bytes: ${mb(total)} MB - test output ${mb(t.test)} MB (${t.testPct}%), file reads ${mb(t.read)} MB (${t.readPct}%), other ${mb(t.other)} MB (${t.otherPct}%); plus ${images} image results, not counted as bytes`,
    `skill loads (share of runs): ${skills.map((s) => `${s.name} ${s.pct}% (${s.runs})`).join(', ') || 'none'}`,
    `cwd under .claude\\worktrees: ${worktree} of ${runs.length} runs (${summary.worktreeCwd.pct}%)`,
  ].join('\n'));
}

main();
