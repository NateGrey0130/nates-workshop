// Where the Bash guard hook is registered, and whether that registration works.
//
// `.claude/hooks/guard-bash.sh` refuses six command shapes that have each
// corrupted a commit, a file, a merge or production here. It is the repo's one
// mechanical control on the Bash tool, and until 2026-09-22 nothing anywhere
// asserted that it was wired up at all.
//
// ── what goes wrong, and why it is silent ────────────────────────────────────
//
// Two failures, both real, both invisible to every other check here:
//
//   2026-09-16  registered ONLY in the repo's .claude/settings.json. Project
//               settings govern the directory they sit in and do not compose
//               (CLAUDE.md's four-cell probe), and the work runs from
//               C:\Users\natha\Projects\workshop and Downloads - so for six
//               days the hook guarded nothing that mattered and the one
//               refusal in the corpus was its own self-test.
//                                              (SKILL-AUDIT.md F55, PR #1245)
//   the shape  a wrong path in the registration. `sh <missing path>` exits
//   F55 left   127, and guard-bash.sh:7-8 records that exit 2 is the ONLY code
//              Claude Code treats as a block - any other non-zero is reported
//              and the command runs anyway. So a typo produces a guard that
//              reads as installed and stops nothing.
//                                              (SKILL-AUDIT.md F56, part two)
//
// The second is the one this module exists for. It cannot be caught by reading
// the settings file, because a path that is merely WRONG looks exactly like a
// path that is right.
//
// ── why this cannot be a CI gate, and is not a defect that it is not ─────────
//
// The file is outside the repo and does not exist on a GitHub runner, so a
// required check could only ever skip there. This runs in the local smoke suite
// instead - which ship-pr step 4 puts before every PR, so it fires at the point
// the registration would be edited. Off this machine it asserts nothing and
// says so, exactly as checks/machine-instructions.mjs does for the machine
// instruction file, and for the same reason.
//
// checks/instruction-paths.mjs is the near neighbour and deliberately does NOT
// cover this: its ROOTS are CLAUDE.md, SETUP.md, docs/cloudflare-credentials.md,
// .claude/skills and .claude/agents, read 2026-09-27, and its READABLE extension list is
// md|json|ps1|mjs|js. `.claude/hooks` is not a root, `.sh` is not readable, and
// `.claude/settings.json` is outside ROOTS - so neither the script nor either
// registration is reached by it. checks/environment.mjs does not reach them
// either; its repo-path regex matches only db|scripts|apps|functions|shared.
//
// ── what it asserts, and what it deliberately does not ───────────────────────
//
// It asserts the USER-LEVEL registration only: that it exists, that it runs
// this repo's guard-bash.sh, that its path is absolute, and that the path
// resolves. Absolute is load-bearing rather than stylistic - a registration
// written as "$CLAUDE_PROJECT_DIR/..." expands against the directory the
// SESSION started in, which is what F55 was, and from a foreign root it points
// at a file that does not exist.
//
// WHAT IT CANNOT DO. It does not prove the hook FIRES: hook settings are read
// when a session starts, so the session editing them cannot exercise its own
// registration. That was SKILL-AUDIT F55's "owed" item and it is now
// DISCHARGED - four genuine refusals from sessions started outside the repo,
// project key C--Users-natha-Downloads, 2026-09-22, found by scanning for the
// wrapper `PreToolUse:Bash hook error`. It does not judge whether the six rules
// are right.
//
// It also does not assert the user-level registration is the ONLY one, and
// since SKILL-AUDIT F60 that is a DECISION rather than an open question: both
// registrations are kept deliberately, because each copy of guard-bash.sh
// guards only the tree it lives in, so the repo's registration is what guards a
// git WORKTREE. Asserting "exactly one" here would now be wrong.
//
// AND THE HOLE THIS CHECK STILL HAS, which F60's audit found: if
// ~/.claude/settings.json is absent ENTIRELY, the early return below reports a
// PASS. That is right for CI and wrong for a second machine, where the file has
// never been written and nothing notices. A machine-setup check would have to
// live somewhere that knows it is on this machine. SETUP.md -> *Setting up a
// machine* records the registration since 2026-09-27, but nothing checks that a
// second machine followed it.

import { readFileSync, existsSync, writeFileSync, mkdtempSync, mkdirSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { homedir, tmpdir } from 'node:os';
import { spawnSync } from 'node:child_process';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Session budget hooks', 'Bash guard hook registration'];

// ── the session-budget hooks ─────────────────────────────────────────────────
//
// .claude/hooks/session-budget.mjs warns, .claude/hooks/agent-slice.mjs
// refuses, and .claude/hooks/agent-run-cap.mjs warns a subagent run and then
// refuses it; each file's header says why. Two halves here, and they differ in
// where they can run:
//
//   BEHAVIOUR   runs everywhere, CI included. Each script is spawned as the
//               harness spawns it - an envelope on stdin, the exit code and the
//               two streams read back - against a transcript written for the
//               purpose. The warn hook must exit 0 on EVERY path, including the
//               ones it cannot read, because its posture is "never blocks".
//   REGISTRATION  local only, like the guard's below, and for the same reason.
//               These are registered at user level ONLY, so unlike the
//               guard there is no checked-in registration behind them: absent
//               from that file is not installed, and that is a failure here.
const HOOK_DIR = join(repoRoot, '.claude', 'hooks');
const BUDGET = join(HOOK_DIR, 'session-budget.mjs');
const SLICE = join(HOOK_DIR, 'agent-slice.mjs');
const RUN_CAP = join(HOOK_DIR, 'agent-run-cap.mjs');

function runHook(script, envelope) {
  const r = spawnSync(process.execPath, [script], {
    input: typeof envelope === 'string' ? envelope : JSON.stringify(envelope),
    encoding: 'utf8',
  });
  return { code: r.status, out: r.stdout ?? '', err: r.stderr ?? '' };
}

// One main-thread assistant line, shaped as Claude Code writes it.
function assistantLine(ctx, at, extra = {}) {
  return JSON.stringify({
    type: 'assistant', isSidechain: false, timestamp: new Date(at).toISOString(),
    message: { usage: { input_tokens: 2, cache_read_input_tokens: ctx - 2, cache_creation_input_tokens: 0 } },
    ...extra,
  });
}

function sessionBudgetChecks() {
  section('Session budget hooks');

  const dir = mkdtempSync(join(tmpdir(), 'session-hooks-'));
  try {
    const now = Date.now();
    const transcript = (name, lines) => {
      const p = join(dir, name);
      writeFileSync(p, lines.join('\n') + '\n');
      return p;
    };
    const prompt = (path) => runHook(BUDGET, { hook_event_name: 'UserPromptSubmit', transcript_path: path });
    const said = (r) => { try { return JSON.parse(r.out).hookSpecificOutput.additionalContext; } catch { return ''; } };

    const small = prompt(transcript('small.jsonl', [assistantLine(90_000, now)]));
    check('a 90k session draws no warning', small.code === 0 && small.out === '', JSON.stringify(small));

    const near = prompt(transcript('near.jsonl', [assistantLine(160_000, now)]));
    check('a 160k session is told it is approaching 200k',
      near.code === 0 && /context is 160k, approaching 200k/.test(said(near)), JSON.stringify(near));

    const over = prompt(transcript('over.jsonl', [assistantLine(240_000, now)]));
    check('a 240k session is told it is past 200k, and Nate sees the same line',
      over.code === 0 && /context is 240k, past 200k/.test(said(over))
        && JSON.parse(over.out || '{}').systemMessage === said(over), JSON.stringify(over));

    // The subagent line is LAST in the file. Read it and the session looks huge.
    const side = prompt(transcript('side.jsonl', [
      assistantLine(90_000, now), assistantLine(400_000, now, { isSidechain: true })]));
    check('a subagent line is not read as the session\'s context',
      side.code === 0 && side.out === '', JSON.stringify(side));

    const cold = prompt(transcript('cold.jsonl', [assistantLine(120_000, now - 70 * 60_000)]));
    check('a 120k session resumed after 70 minutes is told the cache expired',
      cold.code === 0 && /70 minutes ago/.test(said(cold)) && /cache has expired/.test(said(cold)), JSON.stringify(cold));

    const coldSmall = prompt(transcript('cold-small.jsonl', [assistantLine(60_000, now - 70 * 60_000)]));
    check('a 60k session resumed after 70 minutes is not', coldSmall.code === 0 && coldSmall.out === '', JSON.stringify(coldSmall));

    const big = transcript('big.jsonl', [assistantLine(240_000, now)]);
    const merge = runHook(BUDGET, { hook_event_name: 'PostToolUse', transcript_path: big, tool_input: { command: 'gh pr merge 12 --merge --delete-branch' } });
    check('a merge in a large session names the PR boundary',
      merge.code === 0 && /a PR just merged/.test(said(merge)), JSON.stringify(merge));
    const other = runHook(BUDGET, { hook_event_name: 'PostToolUse', transcript_path: big, tool_input: { command: 'git status' } });
    check('any other Bash call in the same session says nothing', other.code === 0 && other.out === '', JSON.stringify(other));
    // A plan-driver session starts near 95k, so a boundary at 100k ended every
    // driver after one merge (measured 2026-10-18). The boundary is 150k.
    const driver = transcript('driver.jsonl', [assistantLine(120_000, now)]);
    const earlyMerge = runHook(BUDGET, { hook_event_name: 'PostToolUse', transcript_path: driver, tool_input: { command: 'gh pr merge 12 --merge --delete-branch' } });
    check('a merge in a 120k session names no boundary', earlyMerge.code === 0 && earlyMerge.out === '', JSON.stringify(earlyMerge));

    const unreadable = [
      runHook(BUDGET, 'not json'),
      prompt(join(dir, 'no-such-file.jsonl')),
      prompt(transcript('empty.jsonl', ['{"type":"user"}'])),
    ];
    check('the warn hook exits 0 and prints nothing on input it cannot read',
      unreadable.every((r) => r.code === 0 && r.out === ''), JSON.stringify(unreadable));

    const spawn = (subagent_type, text) => runHook(SLICE, { hook_event_name: 'PreToolUse', tool_name: 'Agent', tool_input: { subagent_type, prompt: text } });
    const noSlice = spawn('book-reconcile', 'Check the 32 proposed spell rows against the book.');
    check('a book-reconcile brief with no Slice line is refused, exit 2',
      noSlice.code === 2 && /agent-slice: .*must declare a bounded slice/.test(noSlice.err), JSON.stringify(noSlice));
    const wide = spawn('book-reconcile', 'Check these rows.\nSlice: 40-47, 112-120\n');
    check('a 17-page slice is refused and the reason gives the count',
      wide.code === 2 && /slice is 17 pages and the cap is 15/.test(wide.err), JSON.stringify(wide));
    const fits = spawn('book-reconcile', 'Check these rows.\n**Slice:** 40-47, 112-115, 201\n');
    check('a 13-page slice is let through', fits.code === 0 && fits.err === '', JSON.stringify(fits));
    const reversed = spawn('book-reconcile', 'Slice: 47-40');
    check('a reversed range is refused rather than counted as negative', reversed.code === 2, JSON.stringify(reversed));
    const unbounded = spawn('general-purpose', 'Read the whole book.');
    check('an agent that is not slice-bound is let through', unbounded.code === 0, JSON.stringify(unbounded));
    const garbled = runHook(SLICE, 'not json');
    check('the slice hook fails closed on input it cannot parse', garbled.code === 2, JSON.stringify(garbled));

    // A subagent's envelope names the MAIN transcript and its own agent_id; its
    // own file sits beside the main one, under <session>/subagents/.
    const session = (name, mainCtx, runs) => {
      const main = transcript(`${name}.jsonl`, [assistantLine(mainCtx, now)]);
      mkdirSync(join(dir, name, 'subagents'), { recursive: true });
      for (const [id, ctx] of Object.entries(runs)) {
        writeFileSync(join(dir, name, 'subagents', `agent-${id}.jsonl`),
          [assistantLine(60_000, now, { isSidechain: true, agentId: id }),
            assistantLine(ctx, now, { isSidechain: true, agentId: id })].join('\n') + '\n');
      }
      return main;
    };
    const call = (main, agent_id, tool_name = 'Read') => runHook(RUN_CAP, {
      hook_event_name: 'PreToolUse', transcript_path: main, tool_name, tool_input: {},
      ...(agent_id ? { agent_id, agent_type: 'book-reconcile' } : {}),
    });

    // The main thread is at 400k and a sibling run at 300k. Neither is this run.
    const calm = session('calm', 400_000, { a1: 150_000, b2: 300_000 });
    const under = call(calm, 'a1');
    check('a 150k subagent run is left alone, whatever the session and its siblings hold',
      under.code === 0 && under.out === '' && under.err === '', JSON.stringify(under));
    const mainThread = call(calm, null);
    check('a main-thread call is never capped', mainThread.code === 0 && mainThread.out === '', JSON.stringify(mainThread));

    const grown = session('grown', 90_000, { a1: 210_000 });
    const warned = call(grown, 'a1');
    check('a 210k run is told to return what it has, and the call still runs',
      warned.code === 0 && /holds 210k of context, past 200k/.test(said(warned))
        && /name exactly what is left/.test(said(warned)), JSON.stringify(warned));
    // pr-worker.md tells a worker whose work is committed and green to push, open
    // the PR and run its one CI watch past this warning. The warning says so too,
    // so the two cannot contradict each other again; it still says stop first.
    check('and the warning names its one exception: committed and green, only the PR and its CI watch left',
      /Stop here: /.test(said(warned))
        && /One exception: if your work is committed and every suite is green locally, and only a pull request and its CI watch are left, finish those\./.test(said(warned)),
      JSON.stringify(warned));

    const runaway = session('runaway', 90_000, { a1: 260_000 });
    const refused = call(runaway, 'a1');
    check('a 260k run has its tool call refused, exit 2',
      refused.code === 2 && /agent-run-cap: this run holds 260k of context and the cap is 250k/.test(refused.err), JSON.stringify(refused));
    check('and the refusal carries no exception: from the cap there is nothing left to finish',
      !/exception/i.test(refused.err), JSON.stringify(refused));
    const handback = call(runaway, 'a1', 'SubagentHandback');
    check('and its hand-back is let through, or the run could never end',
      handback.code === 0 && handback.out === '' && handback.err === '', JSON.stringify(handback));

    const capUnreadable = [
      runHook(RUN_CAP, 'not json'),
      call(runaway, 'no-such-run'),
      call(runaway, '../runaway/subagents/agent-a1'),
      call(join(dir, 'no-such-session.jsonl'), 'a1'),
    ];
    check('the run cap exits 0 and prints nothing on input it cannot read',
      capUnreadable.every((r) => r.code === 0 && r.out === '' && r.err === ''), JSON.stringify(capUnreadable));
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }

  if (!existsSync(USER_SETTINGS)) {
    check('the user-level settings file is not on this host', true,
      `${USER_SETTINGS} absent - the registration half is local-only and asserts nothing here`);
    return;
  }
  let hooks;
  try {
    hooks = JSON.parse(readFileSync(USER_SETTINGS, 'utf8'))?.hooks ?? {};
  } catch (e) {
    check('the user-level settings file parses as JSON', false, `${USER_SETTINGS} - ${e.message}`);
    return;
  }
  const WANTED = [
    { event: 'UserPromptSubmit', matcher: null, script: 'session-budget.mjs' },
    { event: 'PostToolUse', matcher: 'Bash', script: 'session-budget.mjs' },
    { event: 'PreToolUse', matcher: 'Agent', script: 'agent-slice.mjs' },
    // '*' is every tool: a run is capped on whichever call comes next.
    { event: 'PreToolUse', matcher: '*', script: 'agent-run-cap.mjs' },
  ];
  for (const { event, matcher, script } of WANTED) {
    const on = matcher ? `${event} for ${matcher}` : event;
    const command = (hooks[event] ?? [])
      .filter((entry) => matcher === null
        || (matcher === '*' ? [undefined, '', '*'].includes(entry?.matcher)
          : typeof entry?.matcher === 'string' && new RegExp(`\\b${matcher}\\b`).test(entry.matcher)))
      .flatMap((entry) => entry.hooks ?? [])
      .filter((h) => h?.type === 'command' && typeof h.command === 'string')
      .map((h) => h.command)
      .find((c) => c.includes(script));
    check(`the user-level settings register ${script} on ${on}`, command !== undefined,
      `${USER_SETTINGS} - hooks.${event} names no ${script}; it is registered nowhere else, so it does not run (SETUP.md -> Setting up a machine)`);
    if (command === undefined) continue;
    const path = scriptPathOf(command, script);
    check(`and ${on} spells the path absolutely and it resolves`,
      path !== null && !/\$|%\w+%/.test(path) && existsSync(path),
      `${command} - node exits 1 on a missing script, which is reported and blocks nothing`);
    // No byte comparison against this checkout's copy: the registration names
    // the main checkout's file, so from there it compared a file to itself, and
    // from a worktree it compared two branches, which is a fact about the branch.
  }
}

const USER_SETTINGS = join(homedir(), '.claude', 'settings.json');

// The script every registration here is expected to run. Matched on basename so
// the check does not care which path spelling the registration uses.
const SCRIPT = 'guard-bash.sh';

// Pull the script path out of a hook command. The registrations here are
// `sh "<path>"`, so a quoted token wins; an unquoted command falls back to the
// token carrying the basename. Returns null when neither is found, which the
// caller reports rather than swallowing.
function scriptPathOf(command, script = SCRIPT) {
  const quoted = [...command.matchAll(/(['"])(.*?)\1/g)].map((m) => m[2]);
  const fromQuoted = quoted.find((s) => s.includes(script));
  if (fromQuoted) return fromQuoted;
  const bare = command.split(/\s+/).find((t) => t.includes(script));
  return bare ? bare.replace(/^["']|["']$/g, '') : null;
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  if (wantSection('Session budget hooks')) sessionBudgetChecks();
  if (!wantSection('Bash guard hook registration')) return;

  section('Bash guard hook registration');

  if (!existsSync(USER_SETTINGS)) {
    check('the user-level settings file is not on this host', true,
      `${USER_SETTINGS} absent - this section is local-only and asserts nothing here`);
    return;
  }

  let settings;
  try {
    settings = JSON.parse(readFileSync(USER_SETTINGS, 'utf8'));
  } catch (e) {
    check('the user-level settings file parses as JSON', false,
      `${USER_SETTINGS} - ${e.message}`);
    return;
  }

  const preToolUse = settings?.hooks?.PreToolUse ?? [];
  const commands = preToolUse
    .filter((entry) => typeof entry?.matcher === 'string' && /\bBash\b/.test(entry.matcher))
    .flatMap((entry) => entry.hooks ?? [])
    .filter((h) => h?.type === 'command' && typeof h.command === 'string')
    .map((h) => h.command);

  check('the user-level settings register a PreToolUse command hook on Bash',
    commands.length > 0,
    `${USER_SETTINGS} - hooks.PreToolUse carries no Bash command hook; the guard is not installed machine-wide (SKILL-AUDIT F55)`);
  if (commands.length === 0) return;

  const guards = commands.filter((c) => c.includes(SCRIPT));
  check(`and one of them runs ${SCRIPT}`,
    guards.length > 0,
    `${commands.join(' | ')} - no registration names ${SCRIPT}`);
  if (guards.length === 0) return;

  for (const command of guards) {
    const path = scriptPathOf(command);
    check('the registered command names a script path',
      path !== null, command);
    if (path === null) continue;

    // An unexpanded shell variable is the F55 shape: it resolves against the
    // session's own directory rather than against this repo.
    check('and spells it absolutely, with no unexpanded variable',
      !/\$|%\w+%/.test(path),
      `${path} - expands against the session's working directory, not this repo (SKILL-AUDIT F55)`);

    check('and that path resolves on this machine',
      existsSync(path),
      `${path} - sh exits 127 on a missing script, and 127 is reported rather than blocking, so the guard would read as installed and stop nothing`);
    // The contents are not compared with this checkout's copy. The registered
    // path is the main checkout's file: from the main checkout the comparison
    // was a file against itself, and from a worktree it compared this branch's
    // copy with main's, failing any branch that edits the hook (2026-10-22).
  }
}
