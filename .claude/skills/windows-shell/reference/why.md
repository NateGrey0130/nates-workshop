# Why each windows-shell rule exists

`SKILL.md` states the rules; this holds the incident behind each, for when a
rule looks wrong. Read an undated claim as true on the day it was written.

## The hook

- **It became a hook on 2026-09-16**; the six shapes were prose rules here and
  in `ship-pr` until then. The `find` rule was added 2026-09-22 (`SKILL-AUDIT`
  `F54`) after eighteen whole-disk searches outlived the agents that started
  them. It matches at a command position only, because its trigger words are its
  own subject and a looser matcher would refuse writing about it.
- **Counting refusals.** A scan anchored on a leading `guard-bash:` returned
  zero by construction, which is how `F55` reported that the hook had never
  refused anything. A scan matching the bare string anywhere counted results
  that merely quote it, which is how `F54` reported 42 refusals.
- **User-level registration.** Until 2026-09-22 it was registered only in the
  repo's settings, and project settings govern only their own directory (the
  `CLAUDE.md` four-cell probe), so for six days it guarded nothing where the
  book work ran. `F55` added the user-level registration.
- **Why both stay.** `repo_posix` is derived from the script's own location.
  Measured 2026-09-22 by running each copy against each tree: a target resolves
  as in-repo only for the copy living in that tree. `F60` proposed removing the
  repo registration and was declined on that measurement, and because the repo
  block is the only half that is checked in.
- **LF on the hook.** A CR on the shebang fails as `/bin/sh^M: bad
  interpreter`, a hook that silently stops guarding.
- **`.gitattributes` is the list.** The line-endings paragraph named only
  `*.sql` until 2026-09-04, and a normaliser written from it put a workflow file
  back to CRLF that day; only git's own warning caught it. `*.sql` is LF because
  a CRLF checkout once changed the bytes that reached the database; workflows
  because a runner's bash fails on `$'\r': command not found`.

## Editing

- `grep -c $'\r$'` reported a pure-LF file as 272/272 CRLF.
- A `sed -i` on `app.js` failed four unrelated byte-for-byte checks, which
  looked exactly like the break being tested for.
- The `latin1` truncation put a DC4 byte inside an audit header.

## The pipe

- PR #668 merged with `smoke` at `failure` on 2026-09-04, with `fail` on
  screen, through `gh pr checks | tail && gh pr merge`. Nine PRs in the same
  batch used the identical line and were green, so nothing showed the guard did
  not work.

## Dev servers

- **The blanket kill.** This skill's recipe used to be the blanket form only.
  On 2026-09-20 it killed a running `regression.mjs` mid-suite, which died on
  `UND_ERR_HEADERS_TIMEOUT` with zero FAIL lines and read as a crash in the code
  under test. It was recorded in session memory, and not here, until 2026-09-27.
- Fifteen dev servers accumulated in one session before the port began
  returning `HTTP 000` and a test run failed for reasons unrelated to the code.
- The importer reported `credit balance is too low` against an account that had
  just been topped up, while the same key answered `200 OK` directly. Every
  failure returned in 0s; real API calls take seconds.

## Commit messages

- A `-m` message once ran `wrangler d1 execute` and pasted its help output into
  the commit.
- `commit-msg.tmp` shipped inside PR #404 via `git add -A`. `.gitignore` has
  carried `*.tmp` since 2026-08-30; measured 2026-09-03, `git add -A` with the
  file present stages nothing. This skill went on forbidding the command for
  three days after configuration had closed the trap.

## Nate's shell

- The PATH comparison and the sixteen PowerShell aliases were measured on
  2026-09-02, in a shell whose PATH was rebuilt from the persisted values.
- **Two things believed on 2026-09-01 did not survive a check:**
  - *An inherited environment goes stale.* A fresh value written to
    `HKCU\Environment` with no `WM_SETTINGCHANGE` broadcast was seen at once by a
    process launched from a six-day-old `explorer.exe`.
  - *PATH was what failed.* That session's own record shows an absolute path to
    the npm shim failing too, which PATH cannot cause; `%APPDATA%\npm` is on his
    PATH and `wrangler` resolves there.
- `pdftotext` stayed off his PATH for as long as it did because every agent
  session ran it through Git Bash's prepended toolchain without noticing.

## `--remote` from the agent's shell

- Hand-off briefs carried a caution that these commands hang past 500s from
  the agent's Bash. Re-measured 2026-09-03: `drift-check` five times at ~4 min
  each, `deploy-sweep` in 17s, `q.mjs` in 8s, plus six other `--remote` calls,
  with `deploy-sweep`'s output byte-identical to Nate's run. One clean day does
  not disprove an intermittent fault; `MACHINE-AUDIT.md` `M21` holds the
  measurements.
