// session-budget.mjs - a WARNING hook on two events. It never blocks.
//
//   UserPromptSubmit      before each prompt: how large the context already is,
//                         and whether the prompt cache has gone cold.
//   PostToolUse on Bash   after a `gh pr merge`: a PR boundary is the cheap
//                         place to end a session, so say so there.
//
// Why it exists. One week's usage, read 2026-10-11: 1,268 of 1,489 main-thread
// calls ran with more than 200k tokens already in context (24.2% of the week,
// largest context 824k), and 11 resumes after the one-hour cache had expired
// re-wrote the whole conversation at the 2x rate, about 0.8M weighted tokens
// each (7.7%). "Start a new session at each PR boundary" was already the
// advice. Prose does not fire by itself; this does.
//
// POSTURE: warn, never refuse (Nate, 2026-10-11). It exits 0 on every path,
// including every path it cannot read - a missing transcript, an envelope that
// does not parse, a transcript with no usage line yet. That is the opposite of
// guard-bash.sh, which fails closed, and deliberately so: a warning that cannot
// be computed is a missing warning, not an unguarded command.
//
// What it reads. Claude Code hands every hook a JSON envelope on stdin carrying
// `transcript_path`. Each assistant line of that JSONL carries the API's own
// `message.usage`; input + cache_read + cache_creation of the LAST main-thread
// line is the context the next call will re-read. Sidechain lines (subagents)
// are skipped - their context is their own. Only the tail of the file is read,
// because a long session's transcript runs to tens of megabytes.
//
// Registered at USER level only (C:\Users\natha\.claude\settings.json), with an
// absolute path, so it fires from every directory the work is started in. It is
// not in the repo's .claude/settings.json: unlike guard-bash.sh it guards no
// tree, so a second registration would only print each warning twice.
// checks/hook-registration.mjs holds the registration and the behaviour.

import { openSync, readSync, fstatSync, closeSync } from 'node:fs';

export const WARN_AT = 150_000;      // approaching the line the dashboard counts from
export const OVER_AT = 200_000;      // the line itself
export const IDLE_MS = 55 * 60_000;  // the cache lives one hour; warn inside it
export const IDLE_CTX = 100_000;     // below this a cold resume is not worth a line
const TAIL_BYTES = 4 * 1024 * 1024;

// The last main-thread assistant line that carries usage: { ctx, at } or null.
// `sidechain: true` reads a subagent's own file instead, where every line is a
// sidechain line (agent-run-cap.mjs).
export function lastCall(transcriptPath, { sidechain = false } = {}) {
  let fd;
  try {
    fd = openSync(transcriptPath, 'r');
    const size = fstatSync(fd).size;
    const start = Math.max(0, size - TAIL_BYTES);
    const buf = Buffer.alloc(size - start);
    readSync(fd, buf, 0, buf.length, start);
    const lines = buf.toString('utf8').split('\n');
    if (start > 0) lines.shift();   // the first line of a tail is a fragment
    for (let i = lines.length - 1; i >= 0; i--) {
      if (!lines[i].includes('"usage"')) continue;
      let j;
      try { j = JSON.parse(lines[i]); } catch { continue; }
      if (j.type !== 'assistant' || Boolean(j.isSidechain) !== sidechain) continue;
      const u = j.message?.usage;
      if (!u) continue;
      const ctx = (u.input_tokens || 0) + (u.cache_read_input_tokens || 0) + (u.cache_creation_input_tokens || 0);
      const at = Date.parse(j.timestamp);
      return { ctx, at: Number.isNaN(at) ? null : at };
    }
    return null;
  } catch {
    return null;
  } finally {
    if (fd !== undefined) try { closeSync(fd); } catch { /* nothing to do */ }
  }
}

const k = (n) => `${Math.round(n / 1000)}k`;

// The warning for one envelope, or null when there is nothing to say.
export function warningFor(envelope, now = Date.now()) {
  const event = envelope?.hook_event_name;
  const isMerge = event === 'PostToolUse'
    && /\bgh\s+pr\s+merge\b/.test(String(envelope?.tool_input?.command ?? ''));
  if (event !== 'UserPromptSubmit' && !isMerge) return null;

  const call = lastCall(envelope?.transcript_path ?? '');
  if (!call) return null;
  const { ctx, at } = call;

  if (isMerge) {
    if (ctx < IDLE_CTX) return null;
    return `session-budget: a PR just merged and this session holds ${k(ctx)} of context. `
      + 'This is the boundary to stop at: finish the post-merge checks, then tell Nate '
      + 'the next piece of work belongs in a fresh session.';
  }

  const parts = [];
  if (at !== null && now - at > IDLE_MS && ctx >= IDLE_CTX) {
    const mins = Math.round((now - at) / 60_000);
    parts.push(`the last call was ${mins} minutes ago, so the one-hour cache has expired and `
      + `this prompt re-writes all ${k(ctx)} at the 2x rate`);
  }
  if (ctx >= OVER_AT) {
    parts.push(`context is ${k(ctx)}, past ${k(OVER_AT)}; every further call re-reads it`);
  } else if (ctx >= WARN_AT) {
    parts.push(`context is ${k(ctx)}, approaching ${k(OVER_AT)}`);
  }
  if (parts.length === 0) return null;
  return `session-budget: ${parts.join('; ')}. `
    + 'Finish the unit in hand and say in the reply that the next one should start in a new session.';
}

function main() {
  let s = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (d) => { s += d; });
  process.stdin.on('end', () => {
    let envelope;
    try { envelope = JSON.parse(s); } catch { process.exit(0); }
    const text = warningFor(envelope);
    if (text) {
      // systemMessage is what Nate sees; additionalContext is what the model reads.
      process.stdout.write(JSON.stringify({
        systemMessage: text,
        hookSpecificOutput: { hookEventName: envelope.hook_event_name, additionalContext: text },
      }));
    }
    process.exit(0);
  });
}

if (process.argv[1] && import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) main();
