# Repository architecture audit — git, GitHub, layout and the merge path, 2026-09-03

> **Since 2026-09-16 the closed findings live in `REPO-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

**Status: work was opened on this menu on 2026-09-22.** Read under a finding's
own heading for its state. The table below is dated 2026-09-03 and describes
only the findings of that pass.

| | |
|---|---|
| **taken** | `G1`–`G8`, `G11`–`G15`, `G17`, `G18` |
| **closed, not taken** | `G9`, `G10` — each already decided by another menu |
| **closed by decision** | `G16` — declined, and the decline written into `SETUP.md`; and `G5` half (b), 2026-09-03, squash and rebase stay enabled |
| **re-scoped before being taken** | `G5`, `G11`, `G15` — their `Adjusted` notes stand above the re-scopes |
| **taken in part** | `G2` via path B. **`G5` half (a) taken, half (b) closed by decision — the finding is closed entire** |

**Read the lines under a finding's own heading for its state, and its PR
number.** This block is a convenience and it is the kind of thing that goes
stale first — it was a run-on sentence carrying twelve PR numbers until it was
rewritten, which is the failure it warns about, arriving in the status line
itself.

**Every finding taken from this menu so far has turned up an error in its own
premises, and one of them was in a finding nobody had touched.** `G8` claimed
the suite "has never been runnable on a bare clone" — a bare clone passes
everything, and the real blocker was one `existsSync` assertion. `G1`'s
suggested verification command counts 117 squash-merged PRs as direct pushes.
And taking `G1` disproved **`G5`**, which still says merge commits are used
"exclusively"; it now carries an `Adjusted` banner.

So: **treat the reasoning in these findings as a lead, not as established
fact**, and distrust first anything cheap to check — a count, a command, or a
claim that something has never happened.

## Every remaining finding was re-verified on 2026-09-03

Prompted by the error rate above, not by a schedule. Each open finding's central
claim was re-measured against the repo and the GitHub API the same day the menu
was written. **Two were materially wrong and now carry `Adjusted` banners:**

| finding | verdict |
|---|---|
| `G11` | **WRONG** — "eight under `apps/`" is nine, and it miscounted the root with the very glob `G9` says is incomplete |
| `G15` | **WRONG** — "produces no signal at all" is false; `deploy-sweep.mjs` already reports the Worker, and most of the proposal exists |
| `G6` | claim TRUE, but it was **unverified when written** — only "enabled" had been checked, never "empty" |
| `G2` `G3` `G4` `G7` `G9` `G12` `G13` `G14` `G16` `G17` | central claim **holds** |
| `G3` `G9` `G10` `G12` | hold, with counts that have since **drifted** — see each note |

**There are two failure shapes, and naming them is the useful part.**

**One: reasoned to rather than run.** `G8`'s bare clone, `G1`'s counting
command, `G5`'s "exclusively", `G11`'s totals, `G15`'s "no signal". Every claim
that came from a command actually executed has held; the menu wrote both kinds
in the same voice, and nothing on the page told a reader which was which.
`G18` proposes the fix.

**Two: proposing something another menu had already decided.** `G9` asked to
rename `SETUP-v2-CHANGES.md`; `HEALTH-AUDIT.md` F4 had settled that on
2026-09-02 in PR #523 and chosen the opposite, with reasons. `G10` proposed
numbering the data scripts; `SKILL-AUDIT.md` F25(b) had closed that on
2026-09-02 in PR #567, and its note ends *"recorded so it is not re-proposed."*
**Re-measuring would never have caught either** — `G9`'s facts were right — and
the check is a grep for the subject across the other menus, thirty seconds,
done for neither.

**Both shapes can occur in one finding.** `G10` re-proposed a settled decision
*and* never ran the one command that would have shown its mechanism backwards:
a `NNN-` prefix sorts **first**, not last.

**And shape two is not only a finding's failure — this menu committed it in its
own scope statement.** *What this menu does NOT cover* called
`portability-audit-prompt.md` "never run" and deferred to a
`PORTABILITY-AUDIT.md` that had been **dropped on 2026-09-02**, said so in four
files, and was never coming. The header that warns about the shape carried an
instance of it from the day it was written. Corrected 2026-09-03; the original
stands beside the correction.

This section was added on 2026-09-03 when `G9` was closed, and widened when
`G10` was; the paragraph above it used to say the failure had *one* shape.

**`G6` is the subtler case and worth reading twice.** It was right, and it was
right by luck: the check performed confirmed the tabs were *enabled*, and the
finding asserted they were *empty*. Verifying it required excluding pull
requests from the issues endpoint, which returns 100 rows for a repo with zero
issues. **A coincidence is not a check** — the same lesson `audit-menu` records
about `INGESTION-AUDIT` F14.

**This menu's own trap, stated first, as the `audit-menu` skill asks.** Every
number in this file is a **GitHub-side or filesystem-side measurement taken on
2026-09-03**, and most of them are settings a single click changes without
touching git. A finding here can therefore become false without any commit,
which is the opposite of how the rest of this repo's menus rot. **Re-measure
before taking one** — the commands are quoted inside each finding, and every one
is read-only.

## Findings are `### G<n> — <severity> — <title>`

`G` for git. It collides with nothing: `F` is in use by **eleven** menus, and
`D`, `M`, `R`, `S`, `B`, `C`, `T`, `N` and `P` are each taken. Severity is
lowercase — `high`, `medium`, `low` — in the `UI-AUDIT.md` and
`apps/character-creator/AUDIT.md` shape rather than `HEALTH-AUDIT.md`'s
capitalised one.

## What this menu does NOT cover

**CORRECTED 2026-09-03. `PORTABILITY-AUDIT.md` will never exist, and that was
settled the day before this menu was written.** Everything in the two paragraphs
below defers to a menu that was never coming.

`docs/prompts/portability-audit-prompt.md` was *"written and dropped on the same
day — 2026-09-02 — before any of it was investigated"*
(`docs/prompts/README.md`, under *One of them produced nothing, and that is why
it is kept*). The question underneath it turned out to be about where things sit
on **this** machine, and became `workstation-consolidation-prompt.md` and
`MACHINE-AUDIT.md` instead — which opens by stating that portability was
investigated and dropped. `MACHINE-AUDIT` M13 archived the brief **deliberately
un-annotated**: a dropped direction is a record worth keeping, and the drop
belongs in the index rather than inside the record. That still holds — the brief
is not to be edited.

**So this menu called a dropped direction "never run" and handed it territory it
could never take up.** That is failure shape two from the section above —
asserting what another document had already settled — committed by the menu that
closed `G9` and `G10` for precisely it. **Four files said so and none was read:**
`docs/prompts/README.md` twice, `workstation-consolidation-prompt.md`, and
`MACHINE-AUDIT.md`.

**Nothing is handed back, because there is nobody to hand it to.** Portability
is not deferred to another menu's ownership; it is **not being pursued**, by a
decision predating this file. `G8`'s single point of contact needed no successor
and has none. Anything portability-shaped that matters later belongs in
`MACHINE-AUDIT.md`, which is where that ground actually went.

**The original two paragraphs stand below as the record of what was believed.**

**Portability is not here.** `docs/prompts/portability-audit-prompt.md` — added
2026-09-02 in `c7fe004`, and **never run** — asks for `PORTABILITY-AUDIT.md`
with findings `P1, P2, …` covering the nine junctions, the untracked permissions
file, the OCR cache, the PDFs, the two secrets files and the two environment
variables. That brief owns the question *"what would it take to work from
another machine."*

This menu touches that boundary at exactly one point — **G8**, where the test
suite's inability to run on a bare clone is what forecloses continuous
integration — and hands the general problem back. **Do not file portability
findings here.** If `PORTABILITY-AUDIT.md` is ever produced, G8's outcome note
should cite its number rather than restate it.

Also out of scope by prior ownership: the instruction layer (`SKILL-AUDIT.md`),
documentation content (`DOCS-AUDIT-2.md`), the machine itself
(`MACHINE-AUDIT.md`), and the book-ingestion loop (`BOOK-INGEST-AUDIT.md`).

## The scope Nate set, 2026-09-03

Reproduced because four findings only make sense in its light:

1. **All four layers are in scope** — git/GitHub, repo layout on disk, the
   authoring workflow, and release/deploy mechanics.
2. **Non-blocking checks only.** A check may report; it may not gate the merge
   button. G1 is written to respect this and says so explicitly, and G14 records
   the blocking alternative as *declined in advance* rather than pretending it
   does not exist.
3. **Visibility is genuinely undecided.** G2 is written with both paths costed
   and no recommendation.

---

## Found healthy — do not file against these

Checked and correct on 2026-09-03. Listed so a later pass does not spend a
finding on them.

- **Branch pruning works.** `git ls-remote --heads origin` returns **one** ref,
  `main`, against **616 pull requests**. The hand step in `ship-pr` is being
  done. G4 is about the guarantee, not about a mess.
- **`.gitattributes` is doing real work and its comments say why.** `*.sql text
  eol=lf` exists because three classes reached production with literal `\r`
  inside stored markdown in PR #92. The vendored-library and `woff2` rules are
  both justified in-file.
- **`.gitignore` is ahead of its failures.** It excludes `.cache/`, `.dev.vars*`
  with a re-included `.example`, `.claude/settings.local.json`, and `*.tmp` —
  the last carrying the story of `commit-msg.tmp` shipping inside PR #404.
- **No secret has ever been committed.** `git log --all --diff-filter=A` over
  `*.pdf`, `.cache/*` and `*.epub` returns nothing: the OCR cache and the
  sourcebook PDFs have never entered history, so no rewrite is needed for them.
  The values that *are* public — `ACCESS_AUD`, the D1 `database_id`, the team
  domain — are addressed in G2 and are not secrets in the credential sense.
- **The PR body convention is exceptional and consistent.** PR #615 carries a
  gap statement, a before/after table measured against production, an explicit
  "nothing regresses — checked, not assumed" section, a posture line, an
  acceptance test, a recorded decline path, the five suites' pass lines, and the
  diff stat. G7 is about that convention being invisible to GitHub, not about
  its quality.
- **The permission allowlist's gaps are deliberate and documented.**
  `.claude/settings.json` withholds `d1-apply.mjs`, `gh pr merge`, `git push`
  and every `wrangler d1 execute`, and `CLAUDE.md` explains why in a section
  that exists because `settings.json` rejects comments. G1's posture was chosen
  to agree with this.
- **`git config remote.origin.prune=true`** is set locally, so stale
  remote-tracking refs clean themselves.

---

- **G1** — high — `main` has no protection of any kind, and a merge here IS a deploy — Taken, 2026-09-03 (PR #621). Posture held: the bypass is gone and nothing is — full text in `REPO-AUDIT.closed.md` under its own `### G1` heading.

- **G2** — high — the repo is public, and no file in it records that as a decision — Taken via path B, 2026-09-03 (PR #633). The repo stays public, deliberately, — full text in `REPO-AUDIT.closed.md` under its own `### G2` heading.

- **G3** — medium — a public repo with 693 files and no root `README.md` — Taken, 2026-09-03 (PR #623). Posture held: documentation only, one screen, and — full text in `REPO-AUDIT.closed.md` under its own `### G3` heading.

- **G4** — low — branch deletion on merge is discipline, not a setting — Taken, 2026-09-03 (PR #628). `delete_branch_on_merge` is now `true`. — full text in `REPO-AUDIT.closed.md` under its own `### G4` heading.

- **G5** — low — three merge methods are enabled and only one is used — Adjusted 2026-09-03, while taking G1 — this finding's premise is wrong. — full text in `REPO-AUDIT.closed.md` under its own `### G5` heading.

- **G6** — medium — Issues, Projects and Wiki are all enabled and all empty — Taken, 2026-09-03 (PR #629). All three disabled — `has_issues`, — full text in `REPO-AUDIT.closed.md` under its own `### G6` heading.

- **G7** — medium — the PR convention is excellent, and invisible to GitHub — Taken, 2026-09-03 (PR #624). Posture held: a prompt, no gate, nothing checks — full text in `REPO-AUDIT.closed.md` under its own `### G7` heading.

- **G8** — high — nothing but a person ever runs the tests, and CI is foreclosed by something upstream of CI — Taken, 2026-09-03 (PR #620). Posture held: reporting only, no required — full text in `REPO-AUDIT.closed.md` under its own `### G8` heading.

- **G9** — medium — eleven markdown files at the root, and the canonical way to list them misses one — Closed without being taken, 2026-09-03 (PR #625). This had already been — full text in `REPO-AUDIT.closed.md` under its own `### G9` heading.

- **G10** — medium — 359 run-once scripts in one flat directory, ordered by filename, escalated five `z` deep — Closed without being taken, 2026-09-03 (PR #626). Two independent reasons, — full text in `REPO-AUDIT.closed.md` under its own `### G10` heading.

- **G11** — low — audit menus sit at the root or in an app directory by no stated rule — Adjusted 2026-09-03 — both counts in the first sentence are wrong, and the — full text in `REPO-AUDIT.closed.md` under its own `### G11` heading.

- **G12** — medium — `F18` names eleven different things, and the branch names inherit the ambiguity — Taken with `G13`, 2026-09-03 (PR #627). Posture held: convention, — full text in `REPO-AUDIT.closed.md` under its own `### G12` heading.

- **G13** — low — branch names come in at least three shapes — Taken with `G12`, 2026-09-03 (PR #627), exactly as this finding asked — folded — full text in `REPO-AUDIT.closed.md` under its own `### G13` heading.

- **G14** — high — the Pages check went red for 65 consecutive merges and nobody saw it — Taken, 2026-09-03 (PR #630). `.github/workflows/deploy-alarm.yml` — a daily — full text in `REPO-AUDIT.closed.md` under its own `### G14` heading.

- **G15** — medium — one of the two deploy paths produces no signal at all — Adjusted 2026-09-03 — the heading is false, and this finding predicted its own — full text in `REPO-AUDIT.closed.md` under its own `### G15` heading.

- **G16** — low — 1,267 commits, 616 PRs, zero tags — Closed by decision, 2026-09-03 (PR #632) — declined, and recorded. The — full text in `REPO-AUDIT.closed.md` under its own `### G16` heading.

- **G17** — low — a public repo with no `LICENSE` — Taken, 2026-09-03 (PR #634), unblocked by `G2` choosing to stay public. — full text in `REPO-AUDIT.closed.md` under its own `### G17` heading.

- **G18** — medium — a finding does not say whether its central claim was measured or reasoned to — Taken, 2026-09-03 (PR #640), in the narrower form this finding recommended to — full text in `REPO-AUDIT.closed.md` under its own `### G18` heading.

## How to take one

Per the `audit-menu` skill: Nate names one — *"take G6"* — it becomes one PR on
its own branch, the outcome note is appended **under that finding's heading in
the same PR**, and the merge waits for a separate word. Taking a finding means
auditing it first: **every measurement above is a 2026-09-03 GitHub-side or
filesystem reading, and several are one click from being false.** Re-run the
command in the finding and lead the report with whatever it contradicts.

## Opened by the subagent retrospective, 2026-09-22

Filed while closing out the retrospective recorded on `SKILL-AUDIT.md` under
its own `##` heading of that date. Every claim below was re-derived by hand
before filing: two of them were first surfaced by an agent, and a third
agent's count in the same batch turned out to be a count of mentions rather
than of events, which is the reason for the rule rather than an aside.
### G19 — low — this menu's scope statement calls three findings open that were taken on 2026-09-03

**Opened 2026-09-22**, from the first run of the `open-findings-scout` agent and
verified by hand.

`REPO-AUDIT.md:152` reads, inside the scope statement: *"Also out of scope by
prior ownership: the instruction layer (`SKILL-AUDIT.md`), documentation content
(`DOCS-AUDIT-2.md`, **D1–D3 open**), the machine itself…"*.

All three were taken the day after this menu was filed — `DOCS-AUDIT-2.md`
carries `**Taken, 2026-09-03 (PR #609), as the PRIMARY proposal**` under `D1`,
`**Taken, 2026-09-03 (PR #610).**` under `D2`, and
`**Taken, 2026-09-03 (PR #611), as proposed.**` under `D3`. Read 2026-09-22.

**It is the shape `META-AUDIT` `A17` was filed about**, and it is worth filing
as an instance because `A17`'s own argument predicts that nothing would ever
find it: the sentence carries **no finding number of any kind**, so a taker of
`D1`, `D2` or `D3` grepping the tree for their numbers does not see it, the
tree-wide sweep in `audit-menu` cannot reach it, and `scripts/audit-citations.mjs`
answers only for `BOOK-INGEST-AUDIT`. It was found by a reader looking at
something else.

**Proposal:** strike the three-finding state from the clause and leave the
ownership statement, which is what the sentence is for — *documentation content
(`DOCS-AUDIT-2.md`)* — per `audit-menu` → *A header MAY NOT carry a per-finding
state*, which governs wherever the sentence is written and not only in a header.
**Posture: one clause, subtractive, no replacement state.** Do not write *D1–D3
taken*: that is the same trap with today's answer in it.

**Evidence:** the read of `REPO-AUDIT.md:152` and of the three outcome notes in
`DOCS-AUDIT-2.md`, 2026-09-22.

**Confidence:** high; both halves were read rather than inferred.

**Ongoing cost:** none. Removing a state is what makes it stop rotting.

### G20 — high — the `regression` required check fails intermittently in CI, about fifty seconds in, and a re-run clears it

**Opened 2026-09-22**, after it blocked six merges in one afternoon.

`regression` is one of the three required status checks on `main`, so a red run
stops the merge button. On 2026-09-22 it failed **six times across five pull
requests** — #1238 twice, #1239, #1240, #1242, #1243 — and **every failure
cleared on a re-run of the identical commit**. The same suite passed locally on
the same content every time it was run there.

**The signature is the same every time and it is not a failed check:**

```
[TypeError: fetch failed] { [cause]: SocketError: other side closed }
code: 'UND_ERR_SOCKET'
```

an **uncaught exception** that kills the suite process, followed at job teardown
by `Terminate orphan process: pid (NNNN) (workerd)`. The dev server goes away
and the next request crashes the run.

**It is the clock, not the check.** The four measured precisely died **48, 51,
48 and 57 seconds** into the suite step, at whatever request was in flight —
after the vessel-name check twice, after the spell-burn fixture twice, after the
psionic game-tagging once; the other two failed at comparable job durations,
1m22s and 1m27s against a 30-second setup. Passing runs take **112 to 150
seconds** and walk through all of those. So the check a failure lands on carries no information, and there is
nothing to debug in it.

**Proposal: diagnose before changing anything.** The two candidates are the
runner killing `workerd` under memory pressure and the dev server exiting on its
own; the cheapest discriminator is to capture the server's own stderr and the
runner's memory at the moment of death, which the job does not keep today.
**Posture: no change to the suite and no retry** until a run reproduces it under
that instrumentation. **A retry would be the worst available fix** — it converts
a required gate into one that passes eventually, which is what a gate is for
stopping.

**A second, separable half worth deciding with it:** make the crash legible.
Wrapping the suite's request helper so a socket error prints *the dev server
went away after N seconds* instead of an uncaught stack does not retry, hide or
weaken anything, and turns a twenty-minute diagnosis into one line. It is a
change to the suite, which is why it is named here rather than assumed.

**Evidence:** the six failing runs, their logs kept; `gh run list --workflow=regression.yml`
for the outcomes; the timings taken from the first and last timestamps of each
job's suite step, all 2026-09-22.

**Confidence:** high that the pattern is real — six failures, one signature, one
time band, five different pull requests whose only common content is `main`.
**Low on the cause**, which is the reason this proposes instrumentation rather
than a repair.

**Ongoing cost:** of the proposal itself, one job step that captures more on
failure. Of **not** taking it: every pull request pays a re-run, and the habit of
re-running a red required check until it is green is the one this repo can least
afford to learn.

**Taken, 2026-09-22 (PR #1248). Posture held, in the only reading that is
coherent: no retry, and no change to what any check asserts.** Items (a)-(c)
below *are* changes to the suite, so the proposal's *"no change to the suite"*
clause cannot be read literally against its own second half; it governs retries
and verdicts, and this note says that back rather than papering over it.

**The cause is still not fixed, and this does not pretend to fix it.** What
shipped makes the next occurrence say what happened, in one run, instead of
costing an afternoon.

**Three claims in this finding are wrong, and `audit-premise-auditor` found all
three in the logs the finding itself cites:**

- <!-- claim-ok: quoting the premise this note corrects --> *"at whatever
  request was in flight … the check a failure lands on carries no information"*.
  **Five of the six die on the identical request** — `regression.mjs`'s first
  `POST /characters` — and the sixth on the first `GET` after a similar gap.
  **No failure landed after a vessel-name check at all**; those pass some twenty
  seconds earlier in every one of the six logs. That sentence was my own
  measurement error: I read the failure point out of a `grep` for `FAIL\|Error`,
  and the check named *"comes back with no vessel name rather than **failing**
  the section"* matched it. A grep for a word inside a check's own name is not a
  reading of where a run died.
- <!-- claim-ok: quoting the premise this note corrects --> *"The dev server
  goes away"*, with the `Terminate orphan process: … (workerd)` line as its
  evidence. **The passing run prints the same seven-process orphan list**,
  workerds included. The server was alive; only the connection closed. So
  **liveness is the answer, not the exit code** — the instrumentation records
  `STILL RUNNING` as a first-class result rather than as a failed instrument.
- <!-- claim-ok: quoting the premise this note corrects --> *"It is the clock,
  not the check."* They are the same observation. The two death sites are at
  fixed points that a passing run reaches at 42.7s and 52.1s — which is the
  48-57s band — and #1240, which got *past* the first site, died **later**, the
  opposite of what a wall-clock effect predicts.

**What the logs do show, and it is the one quantity nobody was recording.** Both
death sites are **the first HTTP call after a run of blocking `spawnSync`
wrangler calls**, and the idle gap before the fatal request was **5.16-5.98s in
all six failures against 4.24s in the kept passing run**. That is now printed on
every death. **The hypothesis it exists to settle: a pooled keep-alive
connection going stale across that idle.** It is not acted on here, because the
clean lever — configuring undici's dispatcher — needs a dependency this repo
does not have, and a reconnect-on-error would be the retry this finding forbids.

**Two implementation choices that are not obvious and were not in the
proposal:**

- **A file descriptor, not a pipe.** This suite sits inside `spawnSync` for
  1.4-2.0s at a stretch, dozens of times, during which nothing drains a pipe; a
  full pipe blocks the child's write, which would *lengthen the idle window the
  instrument is measuring*. A ref'd pipe can also hold node's loop open at exit,
  and the kept logs prove the wrangler tree routinely outlives `cleanup()` — so
  a piped suite could hang a **green** run to the workflow timeout. A regular
  file has neither failure mode.
- **An `uncaughtException` handler, not a wrapper on `api`.** There are
  seventeen places a fetch can throw here — `api`, `apiAs`, and fifteen bare
  `await fetch(…)` calls, none inside a `try`. Wrapping one helper would have
  covered the eight observed failures and left fifteen sites bare.

**Proved by making it fail**, with a copy of the suite that throws the real
error shape at the real site:

```
--- the run died, and this is what was around it (REPO-AUDIT G20) ---
  UND_ERR_SOCKET
  169.09s into the suite
  last request sent 0.00s ago, last response 5.40s ago
  IDLE BEFORE THIS REQUEST: 5.40s   (the six kept failures idled 5.2-6.0s here; the kept pass idled 4.24s)
  the dev server: STILL RUNNING - so it did not go away, and only the connection did
  its output, last 2000 of 2507 bytes: …
```

**Two corrections to this finding's own evidence, recorded rather than
repaired.** `gh run list --workflow=regression.yml` returns **zero failures**
today — a re-run replaces the run's conclusion, so the failures survive only per
attempt, and the API path is
`actions/workflows/regression.yml/runs` filtered on `run_attempt > 1`. By that
reading it is **eight failed attempts across six runs**, all 2026-09-22. And
*"every failure cleared on a re-run"* is too kind: **twice it took two
re-runs**, which strengthens this finding's argument against a retry.

**Out of scope and still true:** `play-flow.mjs` spawns its dev server the same
way, with `stdio: 'ignore'`.
