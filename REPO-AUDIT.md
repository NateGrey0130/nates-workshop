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

**Taken, 2026-09-22 (PR #1249). Posture held: one clause, subtractive, no
replacement state.** The ownership half of the sentence stands untouched,
nothing replaced the state that came out, and *D1–D3 taken* was deliberately
not written.

**Three of this finding's premises are false, and `audit-premise-auditor`
caught all three before the branch existed. None of them reaches the
proposal**, which rests on `audit-menu` → *A header MAY NOT carry a per-finding
state* and cites it accurately, including its *wherever the sentence is
written* extension.

- **The line number is wrong, and was wrong on the day this was filed.** The
  body and the `Evidence` line both say `REPO-AUDIT.md:152`. The sentence
  begins at `:153` and the struck words were on `:154`; `:152` is blank.
  Checked against `bbd19e8e`, the commit that filed this finding — off by one
  when written, not drift. Read 2026-09-22.
- <!-- claim-ok: quoting the premise this note corrects --> **"the sentence
  carries no finding number of any kind"** is false about its own subject, and
  it was this finding's whole reason for being filed as an instance. `D1` and
  `D3` are literal substrings of the struck text, so the tree-wide sweep does
  reach this line for two of the three numbers; only `D2` was invisible. The
  real failure is the opposite one: `grep -rnE --include=*.md '\bD1\b'` over
  the repo returns **370** lines because `D1` is also Cloudflare D1, and
  `\bD3\b` returns **53**. Reachable and drowned, not unreachable. Measured
  2026-09-22.
- **The `META-AUDIT` `A17` attribution does not hold, in two directions.**
  `A17` as filed is about prefix ambiguity, not about a missing number; its own
  `Adjusted` note retracts that central inference, records that the per-menu
  grep was never shipped, and closes *"Not to be re-proposed without an exhibit
  that a number grep could actually have caught."* What did ship is narrower —
  a sentence stating another finding's state is unreachable when it is written
  **without a number** (`META-AUDIT.closed.md:1903-1910`). The struck clause
  had numbers in it, so it is not an instance of `A17` as shipped either. The
  argument attributed to `A17` here is `audit-menu`'s own paragraph, which
  cites `A17`; it was imported and applied to a sentence its precondition
  excludes. Read 2026-09-22. `META-AUDIT.md:891` holds only a pointer — the
  full `A17` is in `META-AUDIT.closed.md`.

**One quotation also does not match its source.** The block quoted in this
finding renders the struck words in bold; `:154` carried no bold markers. The
en dash is right in both (U+2013, confirmed with `cat -A`). A taker editing by
literal string match against the quoted form would have found nothing.

**Not the first copy of this phrase, which the subject grep found and this
finding did not.** `META-AUDIT` `A6` struck the same stale state out of
`MEMORY.md` and out of `docs-audit-2-menu.md` — `META-AUDIT.closed.md:531-532`
carries both rows. That sweep was scoped to the memory store and never looked
at this menu. Re-greped 2026-09-22: `audit-menus.md:71` is now a pointer
carrying no per-finding state in all three project keys, so this file held the
last live copy.

**The struck wording survives inside this finding's own quotation of it**, at
`:267`, because `audit-menu` → *Audit files are RECORDS* forbids editing the
finding to tidy that away. A grep for the old phrasing still lands here — on a
record of it having been struck, not on a live claim. That is the accepted cost
of the record rule, and it is worth knowing before anyone greps this phrase and
concludes the sweep missed something.

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
way, with `stdio: 'ignore'`. **Filed as `G21`, 2026-09-22**, per `audit-menu` →
*A deferral is work. Give it a number or say you are dropping it*.

## Opened while closing out the subagent retrospective, 2026-09-22

Filed in one PR, none taken. Each names the deferral or the measurement it came
from.

### G21 — low — `play-flow.mjs` spawns its dev server with `stdio: 'ignore'`, which is the thing `G20` fixed next door

**Opened 2026-09-22**, as the deferral `G20`'s own outcome note names at
`REPO-AUDIT.md:493-494` and does not file.

`apps/character-creator/test/play-flow.mjs:196` spawns `npx wrangler pages dev`
with `{ cwd: repoRoot, shell: true, stdio: 'ignore' }`. `regression.mjs:343`
spawns the same command with `stdio: ['ignore', serverLogFd, serverLogFd]`, and
its comment at `:331` says the change was made when `G20` was taken. Read
2026-09-22.

So the two suites that boot a dev server through `dev-server.mjs` now differ in
exactly the way `G20` argued mattered: when `regression`'s server dies the suite
can say what the server printed, and when `play-flow`'s dies it cannot.

**This is smaller than `G20` was, and the reason is worth stating rather than
discovering.** `play-flow` is **reporting only** — it is not among the three
required status checks on `main`'s ruleset, which are `smoke`, `menus` and
`regression` (`CLAUDE.md`, read 2026-09-22). A `play-flow` death costs a red
square and no merge. `G20` was taken because a *required* check was failing
intermittently and nobody could see why.

**Proposal:** give `play-flow.mjs` the same file-backed stdio `G20` gave
`regression.mjs`, and the same block-on-death reporting if that transfers
without new machinery. **Posture: diagnostics only — no new check, no exit code
moves, and nothing about when the suite fails changes.** If the reporting half
does not transfer cheaply, take the stdio half alone and say so.

**Evidence:** the two reads above, 2026-09-22, and `G20`'s own note. **Not
measured:** whether `play-flow` has ever actually died this way. `G20`'s
re-derivation counted attempts on `regression.yml` only, so the corresponding
number for `play-flow` is unknown and this finding does not claim one.

**Confidence:** high that the asymmetry is real — both lines were read. **Low on
whether it is worth fixing**, and that is the honest state: a reporting-only
suite that has never been observed to die this way may not be costing anything.
What would raise it is the same `run_attempt > 1` query `G20` used, pointed at
`play-flow.yml`.

**Ongoing cost:** none beyond the log file `regression.mjs` already writes.

**A reason to decline it:** the asymmetry may be correct rather than accidental.
`G20` bought visibility into a required check with a real, measured flake;
buying the same for a reporting-only suite with no measured flake is speculative
work, and this finding would rather be declined on that than taken on symmetry
alone.

**DECLINED, 2026-09-22 (PR #1256), on the measurement this finding says it did
not make.** No code changed. **Every one of its six premises held exactly** —
the two spawn lines, the ruleset, and the asymmetry are all as filed. It is
declined because the number it asked for came back zero, not because it was
wrong about anything.

**The number.** `G20`'s own method — `run_attempt > 1` over a workflow's runs —
pointed at `play-flow.yml` and at `regression.yml` for comparison, run
2026-09-22:

| | `play-flow` | `regression` |
|---|---|---|
| total runs | **532** (2026-09-09 → 2026-09-22) | 756 |
| success | 452 | 612 |
| cancelled | 80 | 119 |
| **failure** | **0** | **25** |
| **runs with `run_attempt > 1`** | **0** | **8** |

**`play-flow` has never failed and has never been re-run, in its entire
history.** So the `UND_ERR_SOCKET` signature search has an **empty domain
rather than an inconclusive one**. This finding's `Confidence` line names
exactly this query as the thing that would raise it; it lowers it instead, and
its own *reason to decline* is the paragraph the evidence supports. The 80
cancellations are the workflow's own `cancel-in-progress` group at
`.github/workflows/play-flow.yml:41-43`, sampled at five and matching branches
pushed twice.

**The fallback clause was reached and then declined too, and the reason is worth
keeping.** <!-- claim-ok: quoting this finding's own proposal, in the Proposal
paragraph above --> *"If the reporting half does not transfer cheaply, take the
stdio half alone and say so."* It does not transfer: `reportDeath` is **inline
at `regression.mjs:142-167`**, not in `dev-server.mjs`, and it closes over five
module-level variables declared at `:121-125`. Two of them — `lastRequestAt` and
`lastOkAt`, which produce the idle-gap number that is the entire point — are
written inside `regression.mjs`'s `api()` and `apiAs()` helpers. **`play-flow.mjs`
has no such helpers**: it makes five raw `fetch` calls with no funnel, and has no
`server.on('exit')`. A faithful port needs new imports, an exit listener,
instrumentation at five call sites and two `process.on` handlers.

**And the stdio half ALONE would have been vacuous**, which is why it was not
taken either. `play-flow.mjs:133` runs `removeState()` on exit, and `state` is
where `regression.mjs:338` puts its log — so a server log written there is
deleted before anything could read it after a death. Shipping it would have been
a diagnostic that cannot report, which `test-suite` → *A check that fires on
correct values is worse than no check* is the neighbouring argument against.

**What is true and stays true, so the asymmetry is not re-noticed as new.**
`play-flow.mjs` has **no death path at all** — no `uncaughtException` and no
`unhandledRejection` handler in 640 lines; `waitForOwnServer` covers boot only.
A mid-suite connection death prints a bare uncaught stack. And the exposure is
real: `play-flow.mjs:122-125` runs blocking `wrangler d1 execute` calls while
the server is up, which is the idle pattern `G20` blamed. **Exposure without a
single occurrence in 532 runs is the whole finding**, and if `play-flow` ever
does fail this way, this note is the thing to reopen — the query above is the
test, and it costs one command.

**Not re-proposable on symmetry alone.** Recorded here so the next reader who
notices the two spawn lines differ has the number rather than the observation.

## Filed from the 2026-09-22 session's noticed list, 2026-09-22

Nate named it for filing. It is filed here and not taken in this PR.

### G22 — low — `regression.mjs`'s death block prints an idle band that the deaths since `G20` have already left

**Opened 2026-09-22.** When the suite dies, `G20` has it report the idle gap
before the fatal request. The line it prints, at
`apps/character-creator/test/regression.mjs:153-154` (read 2026-09-22), ends in
a hard-coded parenthetical:

<!-- claim-ok: quoting the printed text this finding is about -->
*"(the six kept failures idled 5.2-6.0s here; the kept pass idled 4.24s)"*

That summarises the six failures kept when `G20` was taken, and later deaths
have fallen outside it. **Every failed attempt of `regression.yml` since `G20`
shipped**, re-derived from the workflow history with
`gh api .../actions/workflows/regression.yml/runs` filtered on
`run_attempt > 1`, then `gh run view <id> --attempt <n> --log-failed` for each
failed attempt, 2026-09-22:

| run | attempt | into the suite | idle | dev server |
|---|---|---|---|---|
| 35790754301 | 1 | 44.25s | 5.65s | STILL RUNNING |
| 35795094181 | 1 | 52.90s | 5.65s | STILL RUNNING |
| 35795094181 | 2 | 57.50s | **7.30s** | STILL RUNNING |
| 35795094181 | 3 | 51.18s | 5.49s | STILL RUNNING |
| 35802343106 | 1 | 52.05s | 5.70s | STILL RUNNING |
| 35803803650 | 1 | 51.72s | **7.25s** | STILL RUNNING |
| 35807354524 | 1 | 50.38s | 5.33s | STILL RUNNING |
| 35807354524 | 2 | 54.60s | **7.58s** | STILL RUNNING |
| 35807354524 | 3 | 50.40s | 5.46s | STILL RUNNING |

All nine are `UND_ERR_SOCKET`, and in every one the dev server was still up.
**Three of the nine idled above 6.0s.** Add the 5.16-5.98s of the six `G20`
kept and the band on record is **5.16-7.58s**. The eight earlier failed
attempts the same query returns predate the instrument; their logs carry `other side closed`
and no idle line.

**Why it matters.** The printed band is there to be compared against. A reader
who gets 7.3s concludes that they are outside the known range and facing
something new, when it is the same flake `G20` described. The instrument is
right and its caption is wrong.

**The elapsed position does not help either.** It reads 44.25s to 57.50s across
the nine, so no fixed point in the suite marks this death.

**Proposal:** stop printing a band. Keep the measured idle gap and point the
reader at `G20` and this finding for the history, with no numbers in the line.
Widening the band to 5.16-7.58 would reset the same trap. `SKILL-AUDIT` `F7`
makes this argument (removing a number beats correcting one), and `META-AUDIT`
`A23` applied it to a header in PR #1267. **Posture: diagnostics text only.**
No check changes, no exit code moves, no retry, and nothing about when the
suite dies or what it asserts. The comment at `regression.mjs:113-121` is a
dated account of the 2026-09-22 failures and is not part of this proposal.

**Evidence:** the table above, run 2026-09-22; the two source lines, read the
same day. `grep -rn 'kept failures'` over the repo, 2026-09-22, finds the
string in `regression.mjs:154` and in `G20`'s own note at `REPO-AUDIT.md:479`,
which is a quoted specimen. No test pins the text.

**Confidence:** high. Every number above was read out of a log. It would only
move if a passing run were found to idle above 7.58s. Passing runs print no
idle line, so that has not been measured.

**Ongoing cost:** none once taken. Left as it is, each further death outside
the band makes the line more misleading.

**Taken, 2026-09-22 (PR #1272). As written: no band is printed.** The idle gap
is still measured and printed. After it, the line now names this finding and
`G20` as where the deaths on record are kept. `regression.mjs:153-154` is the
whole code change, plus a two-line comment above it saying a band used to be
printed there and why it was removed. **Posture, said back: diagnostics text
only.** No check, exit code or retry moved, and nothing about when the suite
dies or what it asserts. The dated comment at `:113-121` is untouched, as the
proposal said.

**The table above is not "every failed attempt", and the correction makes the
case stronger.** <!-- claim-ok: quoting the premise this note corrects -->
It was built from runs with `run_attempt > 1`, so it only saw runs that had been
re-run. A run that failed on its first attempt and was then replaced by a new
push keeps `run_attempt = 1` and falls out of that filter. Querying for
`run_attempt == 1 and conclusion == failure`, 2026-09-22, finds the missing
ones. The `audit-premise-auditor` derived the same list independently, with a
`created=>=` window from `G20`'s merge at 2026-09-22T16:56:16Z. Both counted
these:

| run | attempt | into the suite | idle | dev server |
|---|---|---|---|---|
| 35760469322 | 1 | 51.42s | 5.54s | STILL RUNNING |
| 35803674498 | 1 | 55.23s | **7.88s** | STILL RUNNING |
| 35805258828 | 1 | 51.82s | 5.71s | STILL RUNNING |
| 35811965311 | 1 | 51.32s | 5.70s | STILL RUNNING |

The last row is this finding's own filing PR, #1271, which died once and passed
on a re-run. **So there have been thirteen deaths since `G20`, not nine.** Four
of them idled above 6.0s, not three. The band on record is **5.16-7.88s**, not
5.16-7.58s. The *Confidence* line <!-- claim-ok: quoting the premise this note corrects -->
said the band would only move if a passing run idled above 7.58s. A failing run
had already moved it before this finding was filed. That is the finding's
argument happening to the finding itself, since a range written into prose went
stale while it was being written. Had the band been widened, it would have been
wrong at the ceiling on the day it shipped. All thirteen are `UND_ERR_SOCKET`
with the server still up, at 44.25-57.50s into the suite.

**Every other premise held**, per the auditor. The quoted lines matched word
for word. All nine table rows matched their logs. `G20`'s 5.16-5.98s is at
`REPO-AUDIT.md:449`. **No test pins the text**: that was checked by reading,
not only by grep. The only check that reads `regression.mjs` is `smoke.mjs:528`,
and it parses the `CATALOGS` map only.

**What quotes the old parenthetical without naming this finding:** the memory
note `regression-ci-dev-server-dies.md`, which no repo grep reaches. It was
corrected in this session to the 5.16-7.88 reading and to the removed caption.
`G20`'s note at `:479` quotes the line as a specimen of that day's output and
stays as it is, since an audit file is a record.

**Not proved by making it fail.** The change is one string literal. Tripping
the death path means booting the dev server for a full local run, and a
socket error would have to be injected upstream of it. `node --check` passes,
and CI's `regression` run exercises the file. The next real death will print
the new line.

## Filed from the 2026-09-23 session, 2026-09-23

### G23 — medium — the keep-alive lever `G20` set aside needs no dependency, and it is not a retry

`G20`'s note left the stale-connection hypothesis untested for two reasons. It
said the clean lever, *"configuring undici's dispatcher"*, needs a dependency
this repo does not have (`REPO-AUDIT.md:453-454`), and that reconnecting on
error would be the retry the finding forbids. **The second reason stands. The
first does not.** <!-- claim-ok: quoting the premise this finding corrects -->

**Measured 2026-09-23, node v24.18.0 on this machine, no package installed.**
Node's built-in `fetch` stores its dispatcher on
`globalThis[Symbol.for('undici.globalDispatcher.1')]`, an `Agent` once the first
request has gone out. A new `Agent` made from that object's own constructor,
`new D.constructor({ keepAliveTimeout: 500, keepAliveMaxTimeout: 500 })`, and
assigned back, is what every later `fetch` uses. The test was a local HTTP
server with `keepAliveTimeout = 1000` and two requests 800 ms apart. Counting
the server's `connection` events gave **2**, so the idle socket was not reused
and a second connection was opened. The script is short enough to re-run from
this paragraph. It prints a libuv assertion on Windows at `process.exit`,
because a socket is still closing; that is teardown, not the result.

**The deaths still fit the hypothesis.** Two more on 2026-09-23, on PR #1298's
`regression` run 35881525975: attempt 1 idled **7.47s**, attempt 2 **5.46s**,
both `UND_ERR_SOCKET` with the server `STILL RUNNING`. Attempt 3 passed. Both
idles sit inside `G22`'s recorded band.

**Proposal:** at the top of `apps/character-creator/test/regression.mjs`,
after its first request, replace the global dispatcher with an `Agent` whose
keep-alive timeout is well under the shortest idle a death has shown (about
1 s against 5.16 s). A request after a longer pause then opens a fresh
connection instead of writing to one the server may have closed.
- **If the symbol is absent** (a Node version that renames it), print one line
  saying so and change nothing. The suite must not fail on it.
- **It changes no check and retries nothing.** No request is repeated and no
  error is caught. `G20`'s death block stays exactly as it is, so a death after
  this change reports itself the same way. That is the experiment's control.
- **`play-flow.mjs`** boots its server the same way and could take the same
  block. It is not proposed here: it is reporting-only, and its record per
  `G21` is zero deaths.

**Posture:** an experiment with a stopping rule, not a fix claimed in advance.
Say in the outcome note how many CI `regression` runs will count, and afterwards
say what they showed. **Zero deaths over that many runs supports the
hypothesis. One death with a short idle refutes it, and the block comes out.**
No retry, no change to any verdict.

**Evidence:** the dispatcher probe above, 2026-09-23. The two idle readings are
from `gh run view 35881525975 --attempt 1|2 --log-failed`, 2026-09-23. The
earlier deaths are in `G20` and `G22`. **Not measured:** whether workerd
actually closes idle connections near 5 s. That is inferred from the band, not
read from its configuration.

**Confidence:** high that the lever exists and works without a dependency, since
it was run. **Low that it stops the deaths**, because the hypothesis has never
been tested. That is what taking this measures. It would rise with a stretch of
CI runs with no death, sized against the recorded rate. `G21`'s table
(`REPO-AUDIT.md:559-565`, run 2026-09-22) counts 25 failed `regression` runs
of 756, against `play-flow`'s 0 of 532.

**Ongoing cost:** one block in one test file, relying on an **undocumented
internal symbol**. A Node upgrade could rename it silently, which is why the
absent case prints a line rather than failing. Of not taking this: every PR
keeps paying re-runs of a required check, with the cause still a guess.

**Taken, 2026-09-23 (PR #1303). Posture held: an experiment with a stopping
rule, no retry, no change to any check's verdict.** The block sits in
`regression.mjs` just after the suite proves its own server answers, and it
prints which way it went. `G20`'s death block now also prints
`connection keep-alive:`, so each death says whether the lever was on. **Proved
by making it fail:** with a fetch to a closed port injected right after the
block, `--upto setup` died through `G20`'s handler and printed
`connection keep-alive: 1s (REPO-AUDIT G23)`.

**The stopping rule, stated as the proposal asked:** the next **60** CI
`regression` run attempts after this merges. Zero deaths supports the
hypothesis. One death printing `connection keep-alive: 1s` refutes it, and the
block comes out. At `G21`'s recorded rate (25 failed runs of 756, about 3.3%),
60 clean runs would happen by chance about 13% of the time, so a clean result
is weak support and not proof. Say so when reporting it.

**Corrections found while taking it, by `audit-premise-auditor` and by
measurement.** Nine of eleven premises held. The two that did not hold, and
three more things:

- **The probe in this finding's second paragraph could not fail.** Rerun
  with a control, the stock dispatcher also opened 2 connections there,
  because a node server with `keepAliveTimeout = 1000` sends
  `Keep-Alive: timeout=1`, and undici drops the socket early either way. The
  auditor's controlled rerun was a server advertising 10 s, a separate process,
  and a `spawnSync` block of 5.5 s. There the stock client reused the socket
  (0 new connections) and the lever did not (1). **So the lever works**, on
  that run rather than on this finding's.
- **The hypothesis is weaker than this finding says.** Measured 2026-09-23
  against the local `wrangler pages dev`: workerd sends **no** `Keep-Alive`
  header and closes an idle connection at **5.02 s**. With no header, undici's
  default already drops an idle socket after 4 s. So the stock client should
  not be reusing a socket after the 5.16 s+ idles on record at all. The deaths
  need another cause, or a behaviour on the Linux runner that this machine does
  not show.
- **It does not reproduce locally.** A script that booted its own server and
  ran fetch, a 5.5 s blocking `spawnSync`, then fetch at once, lost 0 of 8
  requests with the stock client and 0 of 8 with the lever (and 0 of 4 at 3 s).
  CI is the only place this experiment can be read.
- **The symbol can be missing before the first fetch.** In one run on node
  v24.18.0 `globalThis[Symbol.for('undici.globalDispatcher.1')]` was
  `undefined` before any request, while the auditor saw it already set. The
  block runs after the suite's first fetch and handles both cases.
- **Still cites this finding outside the repo:** the memory note
  `regression-ci-dev-server-dies.md`, updated in the same session to say it is
  taken.

**Refuted by its own stopping rule, 2026-09-23 — the block came out, replaced
by `G24`.** The rule said one death printing `connection keep-alive: 1s`
refutes the hypothesis. Within three hours of the merge there were **five**, on
three pull requests: run 35919575624 attempt 1, run 35921917883 attempts 1-3
(one commit, three deaths in a row), and run 35926613639 attempt 1. Each died
~50 s in, `UND_ERR_SOCKET`, server `STILL RUNNING`, idle 5.2-5.3 s. Read from
`list_workflow_jobs` with `filter: all` and each job's log, 2026-09-23.

**What was wrong was the lever, not the hypothesis.** A stale pooled socket
*is* the cause, and `G24` shows why a shorter keep-alive cannot reach it:
undici's keep-alive is a timer, and no timer fires while `spawnSync` holds
the event loop.

## Filed and taken at Nate's request, 2026-09-23

### G24 — high — the `G20` deaths are a stale socket that no keep-alive timer can expire, because `spawnSync` blocks the loop; turn connection reuse off

**Filed and taken in one PR, against `## When not to`, on purpose.** Nate
asked for the recurring `regression` failure to be fixed after `G23` was
refuted. A required check was failing about half its attempts, so it was not
filed first and left for a second word. Said here so it does not read as the
rule being missed.

**The mechanism, reproduced on Linux 2026-09-23 (node v22.22.2, wrangler
4.137.0).** `regression.mjs` blocks node's event loop in `spawnSync` wrangler
calls for 5-6 s at a stretch. workerd closes an idle connection at 5.0 s
(`G23`'s measurement). While the loop is blocked the client cannot read that
close, and its keep-alive timer cannot fire either, stock 4 s or `G23`'s 1 s.
So the first `fetch` after the pause is written to the dead pooled socket.
That gives `other side closed`, with the server still up, which is every
death in `G20`, `G22` and `G23`.

**Evidence, all run in this Linux container on 2026-09-23:**

| what ran | died |
|---|---|
| probe: a raw server closing idle sockets at 5.0 s with no `Keep-Alive` header, then client `fetch`, `spawnSync('sleep', 5.5)`, `fetch` — stock dispatcher | **3 / 6**, `UND_ERR_SOCKET other side closed` |
| same probe, `G23`'s `keepAliveTimeout: 1000` | **3 / 6** |
| same probe, `pipelining: 0` | **0 / 6** |
| same probe, stock, 4.5 s pause (under the server's 5.0 s) | 0 / 4 |
| `regression.mjs` at `d094f77`, `G23`'s block in, unflagged | **3 / 3**, idles 5.99 s, 5.98 s, 5.71 s |
| `regression.mjs` with this change, unflagged | **0 / 3**, `REGRESSION PASSED (734 checks)` each time |

`G23`'s note records that its local run lost 0 of 8. That run was on the
Windows development machine. On Linux the suite dies every time, so a local
run can now see this.

**Proposal, and what shipped:** replace `G23`'s block with a dispatcher built
from the same constructor with `pipelining: 0`, undici's documented setting
for keep-alive disabled. Every request opens its own connection, so there is
no pooled socket to go stale. **Posture as `G20` set it: no retry, and no
check's verdict moves.** One thing is deliberately different from `G23`: if
node's undocumented `Symbol.for('undici.globalDispatcher.1')` is missing,
that is now a **failed check**, not a printed line. Running without the fix
would bring the flake back without a sound, and a red check naming the symbol
is the loud version. `G20`'s death block stays as the control and prints
`connection reuse:` where it printed `connection keep-alive:`.

**Confidence:** high on the mechanism. It went 3/3 to 0/3 on the real suite,
and a probe reproduces it without the suite. It would still be good to see CI
agree, and the obvious reading is the same `run_attempt > 1` query `G20`
used. **Any death printing `connection reuse: off` refutes this**, since with
nothing pooled there is no stale socket to write to.

**Ongoing cost:** one block in one test file, still leaning on an
undocumented node symbol, now with a check that says so if it moves. Each
request pays a local TCP connect, which is far below this suite's noise.
**Not changed and worth a later look:** `play-flow.mjs` boots its server the
same way. It drives a browser rather than node's `fetch`, and `G21` records
no deaths.

**Taken, 2026-09-23 (PR #1313).** Still cites `G23` outside the repo: the
memory note `regression-ci-dev-server-dies.md` on the development machine,
which this session cannot reach.
