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
// cover this: its ROOTS are CLAUDE.md, SETUP.md, .claude/skills and
// .claude/agents, read 2026-09-22, and its READABLE extension list is
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
// registration (SKILL-AUDIT F55's "owed", the same shape as F26 for an agent
// file). It does not judge whether the six rules are right, and it does not
// assert that the user-level registration is the ONLY one - the repo's
// .claude/settings.json also registers the hook today, so a repo-rooted session
// runs it twice (SKILL-AUDIT.md:1340-1342). That is a cost, not a defect, and
// pinning it either way would be asserting a decision nobody has made.

import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Bash guard hook registration'];

const USER_SETTINGS = join(homedir(), '.claude', 'settings.json');

// The script every registration here is expected to run. Matched on basename so
// the check does not care which path spelling the registration uses.
const SCRIPT = 'guard-bash.sh';

// Pull the script path out of a hook command. The registrations here are
// `sh "<path>"`, so a quoted token wins; an unquoted command falls back to the
// token carrying the basename. Returns null when neither is found, which the
// caller reports rather than swallowing.
function scriptPathOf(command) {
  const quoted = [...command.matchAll(/(['"])(.*?)\1/g)].map((m) => m[2]);
  const fromQuoted = quoted.find((s) => s.includes(SCRIPT));
  if (fromQuoted) return fromQuoted;
  const bare = command.split(/\s+/).find((t) => t.includes(SCRIPT));
  return bare ? bare.replace(/^["']|["']$/g, '') : null;
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;

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
    // Below this point the path is known to exist. Without the guard, a
    // registration pointing nowhere failed the next check too, with a message
    // saying the script "resolves, but its contents differ" - which is false
    // and sends a reader looking for a diff that does not exist.
    if (!existsSync(path)) continue;

    const ours = join(repoRoot, '.claude', 'hooks', SCRIPT);
    check('and it is this repo\'s copy of the script',
      existsSync(ours) && readFileSync(path, 'utf8') === readFileSync(ours, 'utf8'),
      `${path} - registered and resolves, but its contents differ from ${ours}`);
  }
}
