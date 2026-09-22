# `ship-pr` against the workflow it now describes, 2026-09-03

> **Since 2026-09-16 the closed findings live in `SHIP-PR-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **Work was opened on this menu on 2026-09-22**, under its own `##` heading at
> the end of the file. **Read each finding's own note for its state — this header
> is a summary and summaries here go stale.** The original pass was filed and
> closed 2026-09-03/04, PRs #658–#673. `F11`–`F14` were opened *while taking* the
> first ten and sit under their own heading after `F10`, in numeric order.
>
> **Two declines, and neither means "not a problem."** `F10`'s gap is real and
> open — nothing reads the CI result before a merge — and it was declined because
> the fix would be a fourth thing to remember. `F11`'s number is real and got
> worse — this pass grew `ship-pr` by 63 lines — and it was declined because a
> split is the wrong remedy and nobody has read the file cold. Each note says what
> would reopen it.
>
> **The paragraph directly above is `F15`'s subject and is left standing on
> purpose**, filed 2026-09-22 and not taken: its `F10` clause is a per-finding
> state, and the gap it describes closed on 2026-09-16 when CI became a required
> check. Correcting it here would be taking a finding in the PR that files it.
>
> **`F13` was taken before it was filed**, which inverts the protocol on purpose:
> it is the finding that describes why this file's own PR could not go green, so
> its fix had to land first. Its note is here rather than in #670.
>
> **Filed 2026-09-03 with nothing taken.** Ten findings, `F1`–`F10`, from the
> brief at
> `docs/prompts/ship-pr-audit-prompt.md`. `###`, em dash, **no severity word** —
> the shape `SKILL-AUDIT.md` uses, said here so the next reader does not infer
> it. Each finding carries a `**Proposal:**` with a stated posture, evidence
> with its command and its day, confidence and what would raise it, and ongoing
> cost. Status for any finding will live under its own heading; this header will
> not track it.
>
> **This is a sixteenth findings menu, and every other one is closed.** That
> cost is stated rather than hidden: `META-AUDIT` `A1` declined an index of them
> on the grounds that a list of menus is a second thing to keep in sync. The
> brief said to file into the owning menu instead if the pass turned up fewer
> than four findings worth taking. It turned up ten, six of which are about the
> skill's own sentences rather than about the repo, and `REPO-AUDIT` — the
> nearest owner — is closed with *"nothing is open"* in its status line. A menu
> it is.
>
> **The trap this file sets for its own reader.** Five of the ten are **absence
> claims** — *the skill never says X*. Each was measured with `grep -c` on one
> spelling, named in its evidence line. `audit-menu` is explicit that an absence
> claim is proven by reading, not by grepping one of the two shapes it might
> take. **The skill was also read end to end, twice**, and the greps are quoted
> because they are checkable, not because they are the proof. A taker who
> re-runs only the grep has re-run the weaker half.
>
> **The second trap, and it is worse.** `ship-pr` fires on *"ship this"*. Taking
> any finding here means opening a PR, which loads the skill being corrected —
> so the taker follows the file they are rewriting, including the steps this
> menu says are wrong. **Run `F1`'s replacement command by hand on your own
> merge commit** rather than the one in the file, or the first PR that fixes
> step 9 will have been shipped without it.
>
> **`F1` and `F2` are one section and two different PRs.** Both live in *The
> deploy is not guaranteed*. `F1` rewrites a command; `F2` rewrites the premise
> three paragraphs above it. Taking `F2` first and assuming the command came
> with it is the likeliest misread of this file.
>
> **The subagent question was closed before the pass ran.** The brief asked for
> a `ship-verify` subagent to be proposed and ranked. Nate declined it on
> 2026-09-03, before this pass, agreeing with the brief's own recommendation and
> with `SKILL-AUDIT` `N4`, which declined the skill-shaped version on
> 2026-09-02: *"the only honest trigger is 'you just merged', which is exactly
> when `ship-pr` is already loaded."* **No `N` section exists here.** Recorded so
> the negative result is not derived a third time; do not re-propose without a
> new failure.

Read-only. Nothing outside this file and the archived brief was changed: no
skill, no workflow, no script, no memory file, and no finding was taken.

## What was audited, and against what

`.claude/skills/ship-pr/SKILL.md` — **386 lines, last edited 2026-09-03 14:43**
(`89af6f7`, taking `REPO-AUDIT` `G5(a)`) — read end to end against the four
surfaces that did not exist when its loop was written: `.github/workflows/tests.yml`,
`.github/workflows/deploy-alarm.yml`, `.github/pull_request_template.md`, and the
`main` ruleset. Plus the scripts it names, the skills it points at, and the
memory layer.

Every number below was measured on **2026-09-03** against `origin/main` at
`c6beaad`, from `C:\Users\natha\Projects\nates-apps`.

**The skill is in good shape on mechanics, and that is worth saying first.** The
prune table reproduces; `remote.origin.prune` and `fetch.prune` are both `true`;
step 8's `gh pr view` command returns `MERGED  c6beaad…` exactly as written;
`.gitattributes` pins `*.sql` to LF with the outage that caused it in the
comment; `PARTIAL SMOKE PASSED` is real (`test/harness.mjs:84`); `NO DRIFT` and
`DATA SCRIPT NOT RUN` are real strings in `drift-check.mjs`; the five suites it
names are the five that exist; production answers `200` on
`/apps/pick3cut5/` and `302` at the root, as it says. **The failures below are
almost all about sentences that were true when written and were overtaken** —
which is the same shape the skill's own pruning section already warns about.

### What contradicted the brief

- **The brief reasoned about jq and said so.** It is now measured, and the
  answer is worse than it guessed: see `F1`. The brief did not name the
  empty-output case at all.
- **One number moved.** `REPO-AUDIT` `G5` counted **117** squash-or-direct
  commits on `main`; there are **137** today. Neither is wrong; the number moves,
  which is why `F6` does not quote one in the sentence it proposes.
- **Nothing else in the brief's seven starting points failed to reproduce.**

---

- **F1** — step 9's command answers wrong in three ways, and one of them is silence — Taken, 2026-09-03 (PR #659). As proposed, posture included: one command, one — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — the deploy section's premise is false: a third mechanism exists and the skill has never heard of it — Taken, 2026-09-03 (PR #660). As proposed: documentation only, one paragraph — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — the PR body convention is nowhere in the skill, and a taken finding was built on the claim that it is — Taken, 2026-09-03 (PR #661). Nate chose the full version over the decline — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — step 4's browser bullet and the Pick 3 Cut 5 bullet predate the two skills that own them — Taken, 2026-09-03 (PR #662). Both halves as written and in opposite — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — the `git add -A` pointer is stale, and configuration closed it three days before the skill that carries it was written — Taken, 2026-09-03 (PR #663). Documentation only, two files, no configuration — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — step 7 names one merge shape; 137 commits on `main` are not that shape — Taken, 2026-09-03 (PR #664). One clause, documentation only, merge command — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — nothing about a stacked PR, and step 7 recommends the flag that kills one — Taken, 2026-09-03 (PR #665). Documentation only, one paragraph in step 7, the — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — three passages that should be cut or moved, and a rule about which — Taken, 2026-09-03 (PR #666). All three items, the third on Nate's explicit — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — the ordering rule writes to production and never names the copy you hold yourself — Taken, 2026-09-03 (PR #667). In the smallest version, which is the version — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — no step reads the CI run before merging, and this finding recommends declining — DECLINED, 2026-09-03. Nate's call, and it matches the finding's own — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F10` heading.

## Opened while taking a finding

**Four findings that did not exist when this menu was filed.** They are numbered
in sequence with the rest and sit under their own heading, after `F10` and in
numeric order — deliberately *not* the arrangement `SKILL-AUDIT` used, whose own
header calls that placement the thing that misreads it.

**None of these is taken.** Nothing below has been decided.

**Corrected 2026-09-06: the sentence above is a record of 2026-09-03 and has
been false since the next day.** `F12`, `F13` and `F14` below it were all taken
2026-09-04 — PRs #672, #670 and #671 — and `F11` was declined. **Read each
finding's own note**; this line is left standing rather than edited, because
this file is a record and because how it went wrong is worth more than a tidy
paragraph.

**It is the exhibit `META-AUDIT` `A17` was re-scoped onto, and the reason is
that nothing could have caught it.** The sentence names **no finding number**,
so a taker of `F12` grepping this very file for `F12` gets thirteen lines and
this is not one of them; the tree-wide sweep in `audit-menu` →
*ANYTHING that cites a finding goes stale* cannot see it either, and neither can
`scripts/audit-citations.mjs`. `A13` forbids a per-finding state in a **status
header** and this is a `##` section lead, which that rule did not reach until
`A17` extended it. **A numberless claim about numbered work is invisible to
every sweep here**, which is why not writing one is the only defence.

- **F11** — the pass grew the file it audits by roughly 13% — DECLINED, 2026-09-04. Nate's call, and it matches what this finding proposed — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — filing this menu falsified `audit-menu`'s file table, and this menu's own header did not notice — Taken, 2026-09-04 (PR #672). Documentation only, one file. — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — the CI smoke job downloads wrangler inside a 120-second timeout, and went red on a documentation-only PR — Taken, 2026-09-04 (PR #670), on the second proposal. One step — — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — a red CI run was merged because the command that read it was piped into `tail` — Taken, 2026-09-04 (PR #671). Documentation only, no gate, and `ship-pr` was — full text in `SHIP-PR-AUDIT.closed.md` under its own `### F14` heading.

## Opened by the subagent retrospective, 2026-09-22

### F15 — low — this menu's header states a DECLINED finding's gap as open, and the gap has since closed by other means

**Opened 2026-09-22**, while sweeping the menus for open work. Surfaced by the
`open-findings-scout` agent and read by hand afterwards.

`SHIP-PR-AUDIT.md:15-16` reads, inside the header:

<!-- claim-ok: quoting this file's own header, line cited in the sentence above -->
> **Two declines, and neither means "not a problem."** `F10`'s gap is real and
> open — nothing reads the CI result before a merge — and it was declined
> because the fix would be a fourth thing to remember.

**Two things are wrong with that sentence, and the second is the interesting
one.**

**One: it is a per-finding state in a header.** `audit-menu` → *What a status
header may carry* forbids exactly this, and says so in a clause that governs
*"wherever the sentence is written"* rather than only in headers. The same shape
was taken as `REPO-AUDIT` `G19` on 2026-09-22 (PR #1249), one file over.

**Two: the gap it describes has closed, and not by anything this menu did.**
Since 2026-09-16 `main`'s ruleset `22209348` makes `smoke`, `menus` and
`regression` **required status checks**: `gh pr merge` is refused until all three
report success (`CLAUDE.md`, read 2026-09-22, which gives
`gh api repos/NateGrey0130/nates-workshop/rulesets/22209348` as the way to ask
rather than trust the prose). Observed on this session's own PRs the same day —
`mergeStateStatus` read `BLOCKED` while a required check was pending and `CLEAN`
once all three passed.

So <!-- claim-ok: quoting the premise this finding corrects --> *"nothing reads
the CI result before a merge"* is false. The merge is now gated on CI
mechanically, which is a stronger answer than the step `F10` declined to add —
and `F10`'s decline reasoning, that the fix would be *"a fourth thing to
remember"*, was vindicated: what closed it was a server-side rule that nobody has
to remember at all.

**Proposal:** strike the per-finding state from the header clause and leave the
point it is making — that a decline is not the same as "not a problem" — which
is what the sentence is for. **Posture: subtractive, no replacement state.** Do
not write *"`F10`'s gap is now closed by the ruleset"*: that is the same trap
with today's answer in it, and `G19`'s note records the identical reasoning.
Where the closure deserves recording, it belongs under `F10` in
`SHIP-PR-AUDIT.closed.md` as a dated `**Adjusted**` line, which is what
`audit-menu` → *Audit files are RECORDS* prescribes for a world that moved under
a finding.

**Evidence:** the header read at `:15-16`, the `F10` pointer at `:134`, and the
ruleset's behaviour observed on PRs #1250 and #1251, all 2026-09-22. **Not
measured:** whether any other sentence in this header has also gone stale — this
finding read the two decline sentences and stopped, per `audit-menu` → *Do not
audit prose you are not changing*.

**Confidence:** high on both halves. The header line was read, and the gate was
watched refusing and then permitting a merge.

**Ongoing cost:** none. Removing a state is what makes it stop rotting.

**The `F11` sentence beside it is NOT part of this**, and is left alone
deliberately: <!-- claim-ok: quoting this file's header, cited at :17-19 above -->
*"`F11`'s number is real and got worse"* is a measurement with a date-shaped
claim rather than another finding's open/closed state, and this finding has not
re-measured it.
