// agent-run-cap.mjs - PreToolUse hook on every tool, acting only on a subagent's calls.
//
// Caps how large ONE subagent run may grow. At WARN_AT of context the run is
// told to return what it has and name what is left, and the call still runs.
// At REFUSE_AT every further tool call is refused (exit 2) except the hand-back.
// A main-thread call passes untouched: session-budget.mjs speaks for that.
//
// Why it exists. One week's usage, read 2026-10-11: long subagent runs
// re-cached their whole context every few calls, and ONE run of more than 100
// calls cost 35M weighted tokens while every other run averaged 0.7M.
// agent-slice.mjs bounds the brief. Nothing stopped a run that grew anyway.
// Measured the same day over 14 days of transcripts, 709 runs: 127 peaked past
// 200k, and the four largest were book-reconcile runs of 546 to 1,647 calls
// peaking at 364k to 960k. Five of the ten runs past 100 calls were
// general-purpose, which is why this is not limited to the book agents.
//
// What it reads, each measured 2026-10-11 with a logging hook and one small run:
//   - a subagent's PreToolUse envelope carries `agent_id` and `agent_type`; a
//     main-thread envelope carries neither.
//   - `transcript_path` is the MAIN session's file even then. The run's own
//     file is beside it: <transcript minus .jsonl>/subagents/agent-<id>.jsonl.
//     Every line there is a sidechain line, and the last assistant line's
//     usage is the context the next call re-reads.
//   - a subagent hands its report back with a `SubagentHandback` tool call,
//     which passes through this hook. Refuse that and the run can never end.
//   - PreToolUse `additionalContext` does reach the subagent.
//
// POSTURE: warn, then refuse (Nate, 2026-10-11: 200k, every agent type). It
// FAILS OPEN on everything it cannot read - an envelope that does not parse, a
// run with no transcript or no usage line yet. agent-slice.mjs fails closed
// and this does not, because this fires on every tool call of every session:
// failing closed on a format change would refuse every call on the machine.
//
// It holds no state. The same run is measured afresh on each call, so there is
// no counter to leak, reset or key wrongly.
//
// Registered at USER level only (C:\Users\natha\.claude\settings.json), with an
// absolute path and matcher `*`. checks/hook-registration.mjs holds the
// registration and the behaviour.

import { lastCall } from './session-budget.mjs';

export const WARN_AT = 200_000;     // tell the run to wrap up
export const REFUSE_AT = 250_000;   // stop it
export const HANDBACK = ['SubagentHandback'];

// The run's own transcript, or null when the envelope is not a subagent's.
export function runTranscript(envelope) {
  const id = envelope?.agent_id;
  const main = envelope?.transcript_path;
  if (typeof id !== 'string' || !/^[\w-]+$/.test(id)) return null;
  if (typeof main !== 'string' || !/\.jsonl$/i.test(main)) return null;
  return `${main.replace(/\.jsonl$/i, '')}/subagents/agent-${id}.jsonl`;
}

const k = (n) => `${Math.round(n / 1000)}k`;

// { refuse, text } for one envelope, or null when there is nothing to say.
export function verdictFor(envelope) {
  if (envelope?.hook_event_name !== 'PreToolUse') return null;
  const path = runTranscript(envelope);
  if (!path) return null;
  if (HANDBACK.includes(envelope.tool_name)) return null;   // the way out is never in the way
  const call = lastCall(path, { sidechain: true });
  if (!call || call.ctx < WARN_AT) return null;
  const { ctx } = call;
  const what = 'report what you have found and name exactly what is left, so the caller can spawn a fresh run for the remainder';

  if (ctx >= REFUSE_AT) {
    return {
      refuse: true,
      text: `agent-run-cap: this run holds ${k(ctx)} of context and the cap is ${k(REFUSE_AT)}. `
        + `This call is refused and so is every further one. Return now: ${what}.`,
    };
  }
  return {
    refuse: false,
    text: `agent-run-cap: this run holds ${k(ctx)} of context, past ${k(WARN_AT)}, and every further call re-reads it. `
      + `Stop here: ${what}. Tool calls are refused from ${k(REFUSE_AT)}.`,
  };
}

function main() {
  let s = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (d) => { s += d; });
  process.stdin.on('end', () => {
    let envelope;
    try { envelope = JSON.parse(s); } catch { process.exit(0); }
    const v = verdictFor(envelope);
    if (v?.refuse) {
      process.stderr.write(`${v.text}\n`);
      process.exit(2);
    }
    if (v) {
      process.stdout.write(JSON.stringify({
        hookSpecificOutput: { hookEventName: 'PreToolUse', additionalContext: v.text },
      }));
    }
    process.exit(0);
  });
}

if (process.argv[1] && import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) main();
