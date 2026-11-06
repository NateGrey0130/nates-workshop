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
// The second is the one this module exists for. It is caught two ways here:
// the path in the registration must resolve in this tree, and the registration
// must carry `"onFailure": "block"`, which makes Claude Code (2.1.295 and later)
// treat any exit but 0 as a block - so a guard that cannot start stops the
// command instead of waving it through.
//
// ── where the registrations live, and why that moved ─────────────────────────
//
// Until 2026-11-06 the guard was registered twice (repo and user level, F60)
// and the three budget hooks at user level only, in a file checked in nowhere.
// Nate's N2 test that day showed the repo registration alone refuses in a
// worktree session, so every registration this module reads is now the repo's
// own .claude/settings.json, spelled `"$CLAUDE_PROJECT_DIR/.claude/hooks/..."`.
// The variable is right THERE: a session whose project is this repo, or a
// worktree of it, expands it to a tree that holds the script. F55's foreign-root
// failure was about a user-level registration, which fires from every
// directory; a project registration only fires inside its project. The cost is
// that a session started outside the repo has none of these hooks.
//
// Because the file is checked in, these checks run on a GitHub runner too.
//
// checks/instruction-paths.mjs is the near neighbour and deliberately does NOT
// cover this: its ROOTS are CLAUDE.md, SETUP.md, docs/cloudflare-credentials.md,
// .claude/skills and .claude/agents, read 2026-09-27, and its READABLE extension list is
// md|json|ps1|mjs|js. `.claude/hooks` is not a root, `.sh` is not readable, and
// `.claude/settings.json` is outside ROOTS - so neither the script nor its
// registration is reached by it. checks/environment.mjs does not reach them
// either; its repo-path regex matches only db|scripts|apps|functions|shared.
//
// ── what it asserts, and what it deliberately does not ───────────────────────
//
// The 2026-09-16 entry above is that cost: from 2026-10-04 to 2026-11-03 no
// session was started outside the repo (measured for the plan that moved this).
//
// It asserts the repo's registration: that .claude/settings.json runs
// guard-bash.sh on PreToolUse Bash as `sh "$CLAUDE_PROJECT_DIR/..."`, that the
// script it names exists in this tree, and that the entry carries
// `"onFailure": "block"`.
//
// WHAT IT CANNOT DO. It does not prove the hook FIRES: hook settings are read
// when a session starts, so the session editing them cannot exercise its own
// registration. The repo registration's firing was observed by Nate on
// 2026-11-06 (N2a: a stage-everything `git add` refused in a worktree session
// with the user-level entry removed). It does not judge whether the six rules
// are right, and it does not read ~/.claude/settings.json: a user-level copy
// left there only fires the guard twice.

import { readFileSync, existsSync, writeFileSync, mkdtempSync, mkdirSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { spawnSync } from 'node:child_process';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Session budget hooks', 'Skill gate hook', 'Bash guard hook registration'];

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
//   REGISTRATION  also everywhere: the repo's .claude/settings.json, read
//               like the guard's below. Absent from that file is not
//               installed, and that is a failure here.
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

  const hooks = projectHooks();
  if (hooks === null) return;
  const WANTED = [
    { event: 'UserPromptSubmit', matcher: null, script: 'session-budget.mjs' },
    { event: 'PostToolUse', matcher: 'Bash', script: 'session-budget.mjs' },
    { event: 'PreToolUse', matcher: 'Agent', script: 'agent-slice.mjs' },
    // '*' is every tool: a run is capped on whichever call comes next.
    { event: 'PreToolUse', matcher: '*', script: 'agent-run-cap.mjs' },
  ];
  for (const { event, matcher, script } of WANTED) {
    const on = matcher ? `${event} for ${matcher}` : event;
    const command = hookObjects(hooks, event, matcher)
      .map((h) => h.command)
      .find((c) => c.includes(script));
    check(`.claude/settings.json registers ${script} on ${on}`, command !== undefined,
      `${PROJECT_SETTINGS} - hooks.${event} names no ${script}; it is registered nowhere else, so it does not run (SETUP.md -> Setting up a machine)`);
    if (command === undefined) continue;
    const want = `node "$CLAUDE_PROJECT_DIR/.claude/hooks/${script}"`;
    check(`and ${on} runs it from the project directory, and the script is in this tree`,
      command === want && existsSync(join(HOOK_DIR, script)),
      `${command} - want ${want}; node exits 1 on a missing script, which is reported and blocks nothing`);
  }
}

const PROJECT_SETTINGS = join(repoRoot, '.claude', 'settings.json');

// The repo's hooks object, or null after reporting a file that does not parse.
function projectHooks() {
  try {
    return JSON.parse(readFileSync(PROJECT_SETTINGS, 'utf8'))?.hooks ?? {};
  } catch (e) {
    check('.claude/settings.json parses as JSON', false, `${PROJECT_SETTINGS} - ${e.message}`);
    return null;
  }
}

// The command hook objects registered on one event for one matcher. A null
// matcher takes every entry; '*' takes the catch-all spellings; any other name
// takes an entry whose matcher names it as a word.
function hookObjects(hooks, event, matcher) {
  return (hooks?.[event] ?? [])
    .filter((entry) => matcher === null
      || (matcher === '*' ? [undefined, '', '*'].includes(entry?.matcher)
        : typeof entry?.matcher === 'string' && new RegExp(`\\b${matcher}\\b`).test(entry.matcher)))
    .flatMap((entry) => entry.hooks ?? [])
    .filter((h) => h?.type === 'command' && typeof h.command === 'string');
}

// ── the skill gate ───────────────────────────────────────────────────────────
//
// .claude/hooks/skill-gate.mjs refuses `gh pr create`, `d1-apply.mjs --remote`
// and the worktree commands until the skill owning each was loaded in the
// session; its header says why and records Nate's two rulings. Behaviour runs
// everywhere, CI included, against transcripts written for the purpose. The
// registration is the repo's own .claude/settings.json, which CI has, so that
// half runs everywhere too. Hook settings are read at session start, so the
// session that adds the registration cannot see it fire: these checks are the
// proof that it would.
const GATE = join(HOOK_DIR, 'skill-gate.mjs');

function skillGateChecks() {
  section('Skill gate hook');

  const dir = mkdtempSync(join(tmpdir(), 'skill-gate-'));
  try {
    const transcript = (name, lines) => {
      const p = join(dir, name);
      writeFileSync(p, lines.join('\n') + '\n');
      return p;
    };
    const skillLine = (skill) => assistantLine(30_000, Date.now(), {
      message: { content: [{ type: 'tool_use', id: 'toolu_x', name: 'Skill', input: { skill } }],
        usage: { input_tokens: 2, cache_read_input_tokens: 29_998, cache_creation_input_tokens: 0 } },
    });
    const filler = Array.from({ length: 50 }, (_, i) => assistantLine(40_000 + i, Date.now()));
    const bare = transcript('bare.jsonl', filler);
    const withSkill = (skill) => transcript(`with-${skill}.jsonl`, [skillLine(skill), ...filler]);
    const gate = (command, transcript_path, extra = {}) => runHook(GATE, {
      hook_event_name: 'PreToolUse', tool_name: 'Bash', tool_input: { command }, transcript_path, ...extra,
    });
    const refusedFor = (r, skill) => r.code === 2 && r.err.includes(skill);

    const create = 'gh pr create --base main --head x --title "[proc/feat] X" --body-file b.tmp';
    const noShip = gate(create, bare);
    check('gh pr create with no Skill call for ship-pr is refused, exit 2, and the reason names ship-pr',
      refusedFor(noShip, 'ship-pr'), JSON.stringify(noShip));
    const shipped = gate(create, withSkill('ship-pr'));
    check('the same command with ship-pr loaded early in the session passes',
      shipped.code === 0 && shipped.err === '', JSON.stringify(shipped));
    const wrongSkill = gate(create, withSkill('worktree'));
    check('and another skill does not stand in for ship-pr', refusedFor(wrongSkill, 'ship-pr'), JSON.stringify(wrongSkill));
    const typed = gate(create, transcript('typed.jsonl', [
      JSON.stringify({ type: 'user', message: { role: 'user', content: '<command-message>ship-pr</command-message>\n<command-name>/ship-pr</command-name>' } }),
      ...filler]));
    check('a skill Nate typed as a slash command counts as loaded', typed.code === 0, JSON.stringify(typed));

    const apply = 'node scripts/d1-apply.mjs --remote db/migrations/094-x.sql';
    const noApply = gate(apply, bare);
    check('d1-apply.mjs --remote with neither skill loaded is refused and names both',
      refusedFor(noApply, 'ship-pr') && noApply.err.includes('schema-change'), JSON.stringify(noApply));
    const schema = gate(apply, withSkill('schema-change'));
    const shipApply = gate(apply, withSkill('ship-pr'));
    check('and either ship-pr or schema-change lets it through',
      schema.code === 0 && shipApply.code === 0, JSON.stringify([schema, shipApply]));
    const local = gate('node scripts/d1-apply.mjs --local db/migrations/094-x.sql', bare);
    check('d1-apply.mjs --local is not gated', local.code === 0, JSON.stringify(local));

    const trees = ['git worktree add ../t -b x origin/main', 'node scripts/group-worktree.mjs marvel',
      'cd /c/x && node scripts/book-worktree.mjs canada'];
    const noTree = trees.map((c) => gate(c, bare));
    check('git worktree add, group-worktree.mjs and book-worktree.mjs each need worktree',
      noTree.every((r) => refusedFor(r, 'worktree')), JSON.stringify(noTree));
    const treeOk = trees.map((c) => gate(c, withSkill('worktree')));
    check('and pass once it is loaded', treeOk.every((r) => r.code === 0), JSON.stringify(treeOk));

    const agent = gate(create, join(dir, 'no-such-file.jsonl'), { agent_id: 'a1', agent_type: 'pr-worker' });
    check('a subagent envelope passes whatever the transcript holds (preloaded skills leave no Skill call)',
      agent.code === 0 && agent.err === '', JSON.stringify(agent));

    const garbled = runHook(GATE, 'not json');
    const unreadable = gate(create, join(dir, 'no-such-file.jsonl'));
    check('an unparsable envelope is refused, exit 2', garbled.code === 2, JSON.stringify(garbled));
    check('and so is a gated command whose transcript cannot be read', unreadable.code === 2, JSON.stringify(unreadable));

    // Every other command passes before the transcript is opened: a missing
    // transcript would be refused if it were opened.
    const others = ['git status', 'gh pr merge 12 --merge --delete-branch', 'gh pr view 12',
      'git worktree list', 'echo "then gh pr create"', 'git commit -F msg.tmp'];
    const passed = others.map((c) => gate(c, join(dir, 'no-such-file.jsonl')));
    check('any other command exits 0 without the transcript being opened, gh pr merge included',
      passed.every((r) => r.code === 0 && r.err === ''), JSON.stringify(passed));
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }

  const projectSettings = join(repoRoot, '.claude', 'settings.json');
  let hooks = {};
  try { hooks = JSON.parse(readFileSync(projectSettings, 'utf8'))?.hooks ?? {}; } catch (e) {
    check('.claude/settings.json parses as JSON', false, e.message);
    return;
  }
  const bashHooks = (hooks.PreToolUse ?? [])
    .filter((entry) => typeof entry?.matcher === 'string' && /\bBash\b/.test(entry.matcher))
    .flatMap((entry) => entry.hooks ?? [])
    .filter((h) => h?.type === 'command' && typeof h.command === 'string')
    .map((h) => h.command);
  check('.claude/settings.json registers skill-gate.mjs on PreToolUse Bash beside the guard',
    bashHooks.includes('node "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-gate.mjs"')
      && bashHooks.some((c) => c.includes('guard-bash.sh')),
    JSON.stringify(bashHooks));
}

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
  if (wantSection('Skill gate hook')) skillGateChecks();
  if (!wantSection('Bash guard hook registration')) return;

  section('Bash guard hook registration');

  const hooks = projectHooks();
  if (hooks === null) return;

  const bash = hookObjects(hooks, 'PreToolUse', 'Bash');
  check('.claude/settings.json registers a PreToolUse command hook on Bash',
    bash.length > 0,
    `${PROJECT_SETTINGS} - hooks.PreToolUse carries no Bash command hook; the guard is not installed (SKILL-AUDIT F55)`);
  if (bash.length === 0) return;

  const guards = bash.filter((h) => h.command.includes(SCRIPT));
  check(`and one of them runs ${SCRIPT}`,
    guards.length > 0,
    `${bash.map((h) => h.command).join(' | ')} - no registration names ${SCRIPT}`);
  if (guards.length === 0) return;

  const want = `sh "$CLAUDE_PROJECT_DIR/.claude/hooks/${SCRIPT}"`;
  for (const guard of guards) {
    check('and it runs the guard from the project directory, and the script is in this tree',
      guard.command === want && scriptPathOf(guard.command) !== null && existsSync(join(HOOK_DIR, SCRIPT)),
      `${guard.command} - want ${want}`);

    // Exit 2 is the only code a plain hook treats as a block; sh exits 127 on a
    // missing script and the command would run (guard-bash.sh:7-8, F56). With
    // onFailure "block" every exit but 0 blocks, so a guard that cannot start
    // stops the command it was meant to judge.
    check('and the guard\'s entry carries "onFailure": "block"',
      guard.onFailure === 'block',
      `${JSON.stringify(guard)} - without it a guard that cannot start is reported and the command runs anyway`);
  }
}
