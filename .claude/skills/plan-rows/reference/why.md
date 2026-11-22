# Why plan-rows' rules exist

`SKILL.md` states the rules and keeps every ruling of Nate's with its date and
the option he did not take; this holds the measurements and incidents behind
them, moved out so that the record is not loaded every time a driver re-reads
the skill. Each section below is named for the one it came from, and the text
is moved unchanged, except where a sentence was split (the Sonnet yardstick
and row 32a, reworded only to stand alone) and where a dated note under it says
otherwise. Read an
undated claim as true on the day it was written.

## Where a plan is stored: `state.md` is six lines

Measured 2026-10-18: the file had grown to 16KB in five lines, and every
worker and every driver re-read it.

## Before a brief is written, 2, and the five stops: nothing is asked

Nate, 2026-11-21: "Nothing is asked" after his "go", by planner, driver or
worker, and stops happen "only on breaking items", with explicit reasoning
why. The options he did not take: asking only the irreversible choices (the
planner's recommendation that day), and keeping the asked list of
2026-11-10, which sent five kinds of choice to him at plan time and
mid-chain (a production schema change, deleting data, an Access, R2,
permission, hook or settings change, dropping something he asked for, and a
choice with no clear recommendation) and had the driver ask them with
`AskUserQuestion` while the row waited. Until 2026-11-10 every choice was
asked (2026-10-12).

The five stops were taken on the recommendation the same day; the option not
taken was keeping the stop at "the report and the state file disagree".
On the Splynn plan that reading stalled a green pull request 302 minutes
(measured 2026-11-21), behind a `BLOCKED` line that carried no required
content. `plan-tick.mjs` (#2317) now gives a disagreement a verdict, and a
stop line names its mechanism, what was tried and what unblocks it.

## Before a brief is written, 5: the 400 KB reading set

Measured 2026-10-22: 60 of 204 workers hit the cap, and the 48 rows the
outstanding-work plan planned ran as 107 briefs.

## Before a brief is written, 6: a book row is two rows

Every book row's first worker capped in the 2026-10-20 book-imports plan (ten
rows).

## Starting the driver: the scheduled tick, not a session hand-off

Measured 2026-11-21 on the Splynn plan: the app refused
`mcp__ccd_session__start_session` nine times, because it refuses that call in
any session another session started, and the refused hand-offs left the chain
idle 1,097 of its 2,551 minutes. That refusal is an app guard, not a
permission to route around. Against it, one scheduled run on 2026-11-18
(`mif-plan-watchdog`) drove five workers and merged #2272 and #2274 with
nobody at the keyboard. So the scheduled task is the driver, each run one
tick under `plan-tick.mjs`'s lock (#2317), and a driver at its budget line
releases the lock and ends rather than starting a successor.

## Starting the driver: the Sonnet trial's yardstick

The trial is judged against the 0.72M per merge the Opus drivers measured on
2026-10-22: a driver's context is almost all session start, and it reads
reports, never code.

## Driving the chain, step 3: pull before drift-check

Row 32a, 2026-10-14: after a data row, an un-pulled `main` printed
`RUN BUT NO FILE` for the script just merged.

## Driving the chain, step 4: the driver's local D1

Measured 2026-10-19: rows 46a1, 46b and 46c1 applied migrations 091 to 093 to
production and to their own copies only, and five of the next seven workers'
copies failed smoke's *Migration state* and served the creator a 500.

## Driving the chain, steps 5 and 6, and `DONE`: clean-up and the board

Nate, 2026-11-21: clean up sessions and worktrees, archive sessions in a done
state, and "update the plan board artifact after each row is complete". Step
6 reverses the choice of 2026-11-18, when the Plan Board was refreshed on
demand only. Taken on the recommendation the same day: a failed refresh,
removal or archive is reported, not a stop; not taken: stopping the chain on
it. Before step 5 only the closing message's one scan removed worktrees, and
nothing archived a finished driver session.

Not checked on 2026-11-21: whether an unattended scheduled run can call the
Artifact tool, `ArtifactData` or `archive_session` without an approval prompt.
The probe task that would have shown it was refused by the permission
classifier that day, so each step names its line for worked, refused and no
tool, and the closing message is where the answer will first be read.

## Driving the chain, the tick: the verdicts, the owner and `DONE`

Read 2026-11-22 against `origin/main` at `6840b897`: `plan-tick-lib.mjs`
prints `ADVANCE`, `RESUME` and `WAIT`, and turns a fourth consecutive
`UNKNOWN` into `STOP`, and `plan-tick.mjs --claim` prints an owner id that
`--heartbeat` and `--release` take as `--owner`, refusing another. The skill
named none of the three verdicts and no owner, so a driver reading one had
no step for it, and a release without the id worked only through a fallback
kept for one row of the tick-fix plan. A bare `plan-tick.mjs` run by the
driver holding the lock reads that lock as `LIVE`, so "run it again and go
by its verdict" told the driver nothing until it released first.

The skill had a tick that reads `DONE` end in one line, and ran the clean-up
only in the tick that wrote `DONE`. So a plan whose last driver died between
the two stayed armed, printed `DONE` on every tick, and kept its worktrees and
driver sessions (reasoned from the text, not measured). So any tick that reads `DONE` runs it, and
`--disarm` comes first, so a second tick does not run it too. The
`plan-driver` task is disabled between plans, Nate's ruling of 2026-11-21
(not taken: keeping it enabled with a slim prompt, or no change), so it does
not fire every 30 minutes on nothing armed.

## Driving the chain: a capped row with only the CI wait left

Measured 2026-10-19: rows 48a and 48b each stopped at the cap with their work
committed and suites green, and each then cost a split agent (about 87k) and a
resume worker (about 60k) to open a pull request and watch it.

## Driving the chain: the post-merge line below 150k

Below 150k the post-merge line is nothing: it fires from 100k today (PR #1854
raises it to 150k), which a driver reaches before its first row, and five
drivers that obeyed it there each handed off after one merge and the next paid
a fresh start (2026-10-18).

Note, 2026-11-06: #1854 has merged. `.claude/hooks/session-budget.mjs` has
`WARN_AT = 150_000` as the merge boundary, so the line fires from 150k, and the
100k above is history.
