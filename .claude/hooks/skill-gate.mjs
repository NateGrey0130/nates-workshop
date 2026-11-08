// skill-gate.mjs - PreToolUse hook on the Bash tool.
//
// Refuses three command shapes until the skill that owns them has been loaded
// in this session:
//
//   gh pr create                                  needs ship-pr
//   node scripts/d1-apply.mjs ... --remote        needs ship-pr or schema-change
//   git worktree add, git worktree remove,
//   node scripts/group-worktree.mjs,
//   node scripts/book-worktree.mjs                needs worktree
//
// Why it exists. The setup retrospective of 2026-11-03 measured main-thread
// sessions loading ship-pr before `gh pr create` 62% of the time, ship-pr or
// schema-change before `d1-apply.mjs --remote` 82%, and worktree before a
// worktree command 57%. CLAUDE.md's skill table says when each loads, and
// prose does not fire by itself. This does.
//
// What counts as loaded: an assistant line ANYWHERE in the session transcript
// carrying a `tool_use` block named `Skill` whose `input.skill` is the skill,
// or a user line carrying `<command-name>` for it (a skill Nate typed as a
// slash command). The whole file is read, not a tail as session-budget.mjs's
// lastCall reads, because the Skill call is near the start of a long session.
//
// POSTURE: refuse (exit 2) with the skill's name on stderr. Rulings, Nate,
// 2026-11-03 (plan setup-top5, row 6, approved as written):
//   - a subagent run is exempt. Its envelope carries `agent_id`, and a skill
//     preloaded into an agent leaves no Skill call, so it could never pass.
//     The option not taken was gating subagents too.
//   - it FAILS CLOSED, like guard-bash.sh and unlike agent-run-cap.mjs: an
//     envelope that does not parse, or a gated command whose transcript cannot
//     be read, is refused. It fires on three command shapes only, so a format
//     change refuses three commands rather than every call. Every other
//     command exits 0 before the transcript is opened.
//
// `gh pr merge` is deliberately not gated: it is a plan driver's call, owned by
// plan-rows.
//
// Registered in the repo's .claude/settings.json beside guard-bash.sh.
// checks/hook-registration.mjs holds the registration and the behaviour.

import { readFileSync } from 'node:fs';

// A command position: start of the text or of a line, or after ; & | ( or `.
// Leading VAR=value assignments are allowed. Anchoring here keeps a commit
// message or an echo that merely mentions a command from being read as one.
const AT = String.raw`(?:^|[\n;&|(\x60])\s*(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)*`;
const SCRIPT = (name) => new RegExp(`${AT}node\\s+(?:\\S*[\\\\/])?scripts[\\\\/]${name}\\.mjs\\b([^\\n;&|]*)`, 'g');

export const GATES = [
  {
    what: 'gh pr create',
    skills: ['ship-pr'],
    test: (c) => new RegExp(`${AT}gh\\s+pr\\s+create\\b`).test(c),
  },
  {
    what: 'd1-apply.mjs --remote',
    skills: ['ship-pr', 'schema-change'],
    test: (c) => [...c.matchAll(SCRIPT('d1-apply'))].some((m) => /(?:^|\s)--remote\b/.test(m[1])),
  },
  {
    what: 'a worktree command',
    skills: ['worktree'],
    // `remove` since 2026-11-08 (#2138 gated `add` only, by its brief): the
    // removal is what emptied the main checkout's .cache/books on 2026-09-19.
    // `git worktree list` stays ungated.
    test: (c) => new RegExp(`${AT}git\\s+(?:-C\\s+\\S+\\s+)?worktree\\s+(?:add|remove)\\b`).test(c)
      || SCRIPT('group-worktree').test(c) || SCRIPT('book-worktree').test(c),
  },
];

export function gateFor(command) {
  // SCRIPT() regexes are global, so each test builds fresh ones: no lastIndex carries over.
  return GATES.find((g) => g.test(command)) ?? null;
}

// Every skill loaded in the transcript at `path`. Throws when it cannot be read.
export function loadedSkills(path) {
  const text = readFileSync(path, 'utf8');
  const seen = new Set();
  for (const line of text.split('\n')) {
    const tool = line.includes('"Skill"');
    const typed = line.includes('<command-name>');
    if (!tool && !typed) continue;
    let o;
    try { o = JSON.parse(line); } catch { continue; }
    const content = o?.message?.content;
    if (tool && o.type === 'assistant' && Array.isArray(content)) {
      for (const b of content) {
        if (b?.type === 'tool_use' && b.name === 'Skill' && typeof b.input?.skill === 'string') seen.add(b.input.skill);
      }
    }
    if (typed && o.type === 'user') {
      const s = typeof content === 'string' ? content : JSON.stringify(content ?? '');
      for (const m of s.matchAll(/<command-name>\/?([\w:-]+)<\/command-name>/g)) seen.add(m[1]);
    }
  }
  return seen;
}

// { code, text } for one raw stdin string.
export function verdict(raw) {
  let envelope;
  try { envelope = JSON.parse(raw); } catch {
    return { code: 2, text: 'skill-gate: could not parse the hook envelope; refusing (this hook fails closed).' };
  }
  const command = envelope?.tool_input?.command;
  if (typeof command !== 'string') {
    return { code: 2, text: 'skill-gate: the hook envelope carries no tool_input.command; refusing (this hook fails closed).' };
  }
  const gate = gateFor(command);
  if (!gate) return { code: 0 };
  if (envelope.agent_id !== undefined) return { code: 0 };   // subagents are exempt (Nate, 2026-11-03)

  const need = gate.skills.join(' or ');
  let seen;
  try {
    if (typeof envelope.transcript_path !== 'string') throw new Error('no transcript_path');
    seen = loadedSkills(envelope.transcript_path);
  } catch (e) {
    return { code: 2, text: `skill-gate: ${gate.what} needs the ${need} skill loaded first, and this session's transcript could not be read to tell (${e.message}); refusing (this hook fails closed).` };
  }
  if (gate.skills.some((s) => seen.has(s))) return { code: 0 };
  return {
    code: 2,
    text: `skill-gate: ${gate.what} needs the ${need} skill loaded first in this session. `
      + `Load it with the Skill tool (skill: ${gate.skills[0]}), read it, then run the command again.`,
  };
}

function main() {
  let s = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (d) => { s += d; });
  process.stdin.on('end', () => {
    const v = verdict(s);
    if (v.text) process.stderr.write(`${v.text}\n`);
    process.exit(v.code);
  });
}

if (process.argv[1] && import.meta.url.endsWith(process.argv[1].replace(/\\/g, '/').split('/').pop())) main();
