# `ship-pr` against the workflow it now describes, 2026-09-03

> **Nothing here is taken.** Ten findings, `F1`–`F10`, from the brief at
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

### F1 — step 9's command answers wrong in three ways, and one of them is silence

Step 9 (`SKILL.md:128`) is the per-merge deploy read:

```bash
gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs --jq '.check_runs[] | .name + "  " + .conclusion'
```

**It reads every check-run on the commit, not the Pages one.** `deploy-sweep.mjs`
did the same until 2026-09-03 and was filtered on exactly this ground. Its
comment block records what happened: `deploy-alarm.yml` began posting
`check-recent-deploys` to `main`, its first run was buggy and red, and the sweep
then *"reported `1ce6ea9` as DID NOT DEPLOY while the same line showed
`Cloudflare Pages=success` — a deploy monitor calling a successful deploy a
failure because a different monitor had failed. Two tools feeding each other
false alarms is precisely how a check stops being read."* The sweep was fixed.
Step 9 was not, and it reads the same commits.

**It reads `conclusion` alone, at the one moment `conclusion` is null.** Step 9
runs immediately after step 8. A Pages build here takes 20–35 seconds. `gh`'s jq
is gojq, and gojq treats `null` as the identity for `+`, so an in-flight run
prints the name, two spaces, and nothing:

```
Cloudflare Pages
```

Against the skill's own sentence — *"a `conclusion` of anything but `success` on
the Pages run means the merge did not ship"* — a blank is not `success`.
`deploy-alarm.yml` reads **status and conclusion** and says why in a comment:
*"`conclusion` is null while a run is in flight, so reading it alone cannot tell
'still building' from 'never ran' — and those need opposite answers."* Step 9
cannot tell them apart either, and does not know it.

**A commit with no check-run at all prints nothing and exits 0.** `.check_runs[]`
over an empty array emits no lines. The step then looks like it ran and found
everything fine. `deploy-sweep.mjs`'s header names this state specifically —
*"including one that registered no check-run at all, which looks exactly like a
quiet healthy merge and is not one"* — and the sweep reports it. Step 9 is the
only one of the three deploy reads that cannot.

**Proposal.** Replace the command with one that filters to the Pages run and
prints status and conclusion together, and add one sentence saying that empty
output means **no run**, not a pass:

```bash
gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs \
  --jq '[.check_runs[] | select(.name=="Cloudflare Pages")]
        | if length == 0 then "NO RUN" else (.[0].status + "/" + (.[0].conclusion // "pending")) end'
```

Keep the surrounding prose, including *"`gh pr checks` is not a substitute"*,
which still holds. **Posture: correct one command and add one sentence. No new
gate, no new script, no change to when step 9 runs.** Do not lift the grace
period from `deploy-alarm.yml` into the skill — a person reading `pending` ten
seconds after merging can wait; a hard-coded 1800 seconds in an instruction is a
number that will rot.

**Evidence.** `gh api …/commits/4e4eb128/check-runs` (2026-09-03) returns two
runs, `Cloudflare Pages` and `check-recent-deploys`. `gh api user --jq
'"Cloudflare Pages" + "  " + .no_such_field'` prints `Cloudflare Pages` followed
by two spaces. `gh api user --jq '[] | .[] | .name + "  " + .conclusion'` prints
nothing and exits 0. `scripts/deploy-sweep.mjs`, the comment above its `--jq`
line. All 2026-09-03.

**Provenance, because it explains why nobody noticed.** `HEALTH-AUDIT` `F2`'s
outcome note (2026-09-02, PR #517) says in terms: *"`ship-pr` gains it as the
end-of-session backstop and **keeps step 9 unchanged**."* That was right on the
day. Two changes the next day — the alarm posting a second check-run, and the
sweep being filtered against it — made it wrong, and the note that recorded the
decision is not a thing anyone re-reads.

**Confidence: high**, on all three parts, each run rather than reasoned. Nothing
would raise it. The one thing not demonstrated on live data is the empty case:
every commit in this repo's history carries at least one check-run, so it was
proven on the jq rather than on a real bare commit.

**Ongoing cost: none.** It is the same one call in the same place, with a
different filter.

**Taken, 2026-09-03 (PR #659).** As proposed, posture included: one command, one
paragraph, one sentence of prose, no new gate and no new script. The grace period
was deliberately not lifted from `deploy-alarm.yml`, as the finding said.

**All three premises reproduced** — `4e4eb128` still carries both check-runs, and
the gojq null test still prints a bare name. Two things the work turned up that
the finding did not say:

- **The proposal's "add one sentence saying empty output means no run" was the
  wrong shape, and the finding's own replacement query already contained the
  right one.** A sentence telling a reader to interpret silence correctly is the
  kind of instruction this menu's `F10` argues against. The query says `NO RUN`
  in words instead, so there is no silence to interpret.
- **The `NO RUN` branch was proven by making it fire**, with
  `select(.name=="NoSuchCheck")` against a real commit. The finding recorded that
  it could not be demonstrated on this repo's history, since every commit here
  carries at least one check-run; that was true and is not a reason to ship an
  untested branch.

---

### F2 — the deploy section's premise is false: a third mechanism exists and the skill has never heard of it

*The deploy is not guaranteed* (`SKILL.md:132–199`) reasons throughout from two
mechanisms — step 9 per-merge, and `deploy-sweep.mjs` at session end — both of
which *"depend on a person remembering, which is the mechanism that already
failed."* Since 2026-09-03 there is a third that does not:
`.github/workflows/deploy-alarm.yml` runs daily on a schedule, walks
`--first-parent` over a 26-hour window with a 1800-second grace period, and
**fails on purpose**, because a failed scheduled run is what GitHub emails
about.

The skill mentions it zero times. Its own header names `ship-pr` step 9 as one
of the two things it backstops, so the reference exists in one direction only.

**This matters beyond tidiness.** The section's argument for the session-end
sweep is *"So end a working session with the backstop"* — an argument built on
there being nothing else. There is now something else, with a different failure
mode: the alarm depends on **GitHub notifications being enabled for this repo**,
which its own comment says outright, and on nobody having muted them. That is a
dependency a person shipping a change should know about, and it is written down
in a file they have no reason to open.

**Proposal.** One paragraph in *The deploy is not guaranteed*, after the sweep:
the alarm exists, it runs daily, it is the only one of the three that does not
depend on remembering, it reaches you as an Actions failure email and therefore
depends on notifications, and **it is not a gate** — it runs on a schedule, never
on a pull request, and cannot block a merge. **Posture: documentation only. Do
not propose making it a required check** — the alarm's own comment says that
would be a different decision needing its own finding, and this repo's rule is
warn, do not block.

**Do not restate the mechanism.** The workflow's header is 40 lines and good. A
pointer plus the three facts a shipper needs — daily, email, not a gate — is the
whole of it.

**Evidence.** `grep -c deploy-alarm .claude/skills/ship-pr/SKILL.md` → `0`;
`grep -c check-recent-deploys` → `0` (2026-09-03). Both files read in full.

**Confidence: high** on the absence and on the workflow's behaviour. **Medium on
one clause** — that the alarm has actually delivered a notification to Nate — and
what would raise it is Nate saying whether the first red run on 2026-09-03
reached him by email. If it did not, this finding is more urgent, not less.

**Ongoing cost:** one paragraph, plus a third mechanism to keep current if the
schedule changes. Real but small.

**Taken, 2026-09-03 (PR #660).** As proposed: documentation only, one paragraph
and a three-item list, and the workflow's own header left as the explanation.

**The medium-confidence clause resolved in the direction that closes it.** The
finding could not confirm that the alarm's email had ever reached anyone, and
said the finding would be *more* urgent if it had not. Nate confirms the first
red run on 2026-09-03 reached him, so the channel is proven end to end and the
paragraph states it as fact with its date rather than hedging.

**One thing added that the finding did not ask for:** the sentence that muting
this repo's Actions notifications silences the alarm without failing it. The
workflow's header says the alarm *depends on* notifications being on; it does
not say what that looks like from the outside, which is nothing at all. A person
needs to have read that once.

---

### F3 — the PR body convention is nowhere in the skill, and a taken finding was built on the claim that it is

Step 6 opens the PR with `--body-file pr-body.tmp` and **never says what goes in
the file.** The skill's only guidance on a PR body is one sentence in the
ordering rule: say which D1 files are already applied.

`REPO-AUDIT` `G7` asserts, as the premise it was taken on: *"PR bodies here
follow a strict, unusually good shape. That shape exists only inside the
`ship-pr` skill."* It does not. `G7` shipped `.github/pull_request_template.md`
(PR #624, 2026-09-03) carrying six headings — the gap, what was measured,
posture, nothing regresses, the decline path, verification — and that template is
now **the only written copy of a convention it says lives somewhere else**.

**The consequence is the reverse of what `G7` intended.** `G7` was careful not to
duplicate the skill, on the stated grounds that a second copy is a second thing
to keep in sync. Because the first copy never existed, the template is not a
second copy — it is the original, sitting in the one file the normal path never
reads, since `--body-file` replaces it and that is how every PR here is opened.

**Proposal.** Add the six headings to `ship-pr` step 6, as a list with one line
each, and have the template point at the skill rather than the other way round.
**Correct `G7`'s note in the same PR**, in `REPO-AUDIT.md`, saying its premise
was false and how — `audit-menu`'s rule is that a finding's own note carries what
contradicts it. **Posture: documentation only, no gate.** Nothing checks that a
PR body has any of these, and nothing should.

**The decline path is real and should be weighed.** Every PR here is opened by an
agent that has read the skill and produces the right shape anyway — 673 first-parent
commits' worth of evidence that the convention transmits without being written
down. If the shape is genuinely carried by the surrounding PRs rather than by any
document, the honest fix is to correct `G7`'s sentence and change nothing else.
**Say which of the two you are taking.**

**Evidence.** `grep -n "body\|template\|posture\|regress\|decline"` over
`SKILL.md` returns seven lines, none of them a convention (2026-09-03).
`.github/pull_request_template.md` read in full. `REPO-AUDIT.md` `G7`, its
proposal and its outcome note.

**Confidence: high** that the skill does not carry it. **Low on which fix is
right** — that is Nate's call between the two paragraphs above, and what would
raise it is his answer.

**Ongoing cost:** six lines that must move when the convention does. The
template already carries that cost; this makes it two places, which is the
argument for the decline path.

**Taken, 2026-09-03 (PR #661).** Nate chose the full version over the decline
path: the six headings into step 6, the template amended to say it follows the
skill, and `REPO-AUDIT` G7's premise corrected under G7 in the same PR.

**The two-places cost is real and was paid deliberately, so it is written into
the tie-break** rather than left for someone to discover: the template's opening
comment now says the skill's list is the copy that gets read and the skill wins
if they disagree. `G7`'s own constraint — *do not grow it into a second copy* —
is why the template keeps its six headings and gains a pointer instead of prose.

**One thing worth naming beyond the finding.** G7's false premise was a claim
about what a *different* file said, and checking it required reading something
other than the file being changed. `audit-menu` already lists that as the class
to distrust first; this is a live instance, and G7's correction says so.

---

### F4 — step 4's browser bullet and the Pick 3 Cut 5 bullet predate the two skills that own them

Step 4's last bullet is nine words: *"changed anything visible: drive it in a
browser."* `verify-ui` is 154 lines on exactly that, including the three ways the
in-app Browser pane lies, how to render real print media, and which production
controls **write** when clicked. It shipped 2026-09-02 (`SKILL-AUDIT` `N1`–`N3`),
after the bullet.

Nine lines above it, the `--remote` bullet tells the Pick 3 Cut 5 Access story in
full — the bypass that covered two paths but not `/shared/styles.css` or
`/shared/js/ui.js`, the unstyled page, `escHtml is not defined`. **`pick3cut5`
tells the same story at `SKILL.md:23–24` and names the same command at `:127`.**
Two copies of one incident.

`ship-pr` names `windows-shell` three times, `schema-change`, `class-import` and
`audit-menu` once each. It names `verify-ui` and `pick3cut5` **zero** times.

**These are not the same case and the proposal treats them differently.**

**Proposal.** For Pick 3 Cut 5: **compress to a pointer.** Keep the command and
the one-line reason it exists — the only check that sees the bypass gap — and
replace the incident with *"`pick3cut5` has the case."* That is `SKILL-AUDIT`
`F1`'s posture, which moved the shell material out of this same skill and left a
pointer, deliberately not a duplicate, and the skill came out shorter.

For the browser: **keep the bullet and add the skill's name.** *"changed anything
visible: `verify-ui`, and drive it in a browser."* Do not move the bullet — it is
a step in a list and it has to stay a step. Do not grow it either.

**Posture: move one passage, add one word to another. Net line count must go
down.** ~9 lines out, ~2 in.

**Evidence.** `grep -c "verify-ui"` → `0`; `grep -c '`pick3cut5`'` → `0`
(2026-09-03). `wc -l`: `ship-pr` 386, `verify-ui` 154, `pick3cut5` 156.
`pick3cut5/SKILL.md:23–24` and `:127` read directly.

**Confidence: high.** The duplication is two files open side by side.

**Ongoing cost: negative.** This is one of the few findings here that makes the
file shorter.

**Taken, 2026-09-03 (PR #662).** Both halves as written and in opposite
directions: the Pick 3 Cut 5 bullet compressed to command, one line of *what
only this check sees*, and a pointer; the browser bullet kept in place with
`verify-ui` named in it. **6 insertions, 9 deletions.**

**The clause that had to survive the compression, and did.** *"fetches the app
**and its assets**"* is the whole reason that check is not
`curl /apps/pick3cut5/`, and it is kept verbatim. What went was the nine-line
retelling of the incident — to a file that already contains it, which is the
test of a move rather than a deletion.

**A caveat on the arithmetic this menu should not hide.** `F4` makes the file
three lines shorter and `F1`–`F3` made it fifty-three lines longer. The skill is
**439 lines against 386 when this menu was filed**. `F8` is the only finding
here that materially reverses that, and it should be read as load-bearing rather
than as tidying.

---

### F5 — the `git add -A` pointer is stale, and configuration closed it three days before the skill that carries it was written

`SKILL.md:343` sends the reader to `windows-shell` for *"the `git add -A` trap
that eats the message file."* `windows-shell:125` still states it live: *"Do not
`git add -A` immediately before `--amend` — it sweeps the message file into the
commit."*

`.gitignore:31` has `*.tmp`, and its comment names the incident: *"commit-msg.tmp
shipped inside PR #404 that way."* `git add -A` does not stage an ignored file.
**The trap is closed by configuration.**

**The dates are the finding.** `*.tmp` landed **2026-08-30 20:12** (`637aff3`).
`windows-shell` was created **2026-09-02 12:38** (`4ea4eaa`) and last edited
**2026-09-03 08:13** (`44284fd`). The skill shipped a rule that configuration had
already retired, twice, and `ship-pr` points at it.

This is the failure `ship-pr`'s own pruning section describes: *"the habit of
writing down what a change was supposed to achieve rather than what was left
standing afterwards."* Here it is the inverse — a hand step retired by
configuration and written down anyway.

**Proposal.** In `windows-shell`, replace the instruction with the outcome:
`*.tmp` is ignored, so the sweep cannot happen, and the reason it is ignored is
PR #404. In `ship-pr:343`, drop *"and the `git add -A` trap that eats the message
file"* — the `-F` and backticks half is still true and still worth the pointer.
**Posture: documentation only, in two files, one PR.** No config change; the
config is already right.

**Check before writing it, because this finding is exactly the shape it
describes:** confirm `git add -A` really cannot stage `commit-msg.tmp` on this
machine, with `git check-ignore -v commit-msg.tmp` and a scratch commit. This
pass reasoned from `*.tmp` being in `.gitignore` and did not run that.

**Evidence.** `.gitignore:20–31`; `git log -1 --format='%ci' 637aff3` →
2026-08-30 20:12:12; `git log --diff-filter=A` and `git log -1` on
`.claude/skills/windows-shell/SKILL.md` (2026-09-03).

**Confidence: high on the dates, medium on the behaviour** — because it was
reasoned, not run, and the check that would raise it is one command, named above.

**Ongoing cost: none.** Two sentences get shorter.

**Taken, 2026-09-03 (PR #663).** Documentation only, two files, no configuration
change. **The medium half was run before anything was written**, as the finding
required: `git check-ignore -v commit-msg.tmp` returns `.gitignore:31:*.tmp`, and
`git add -A` with that file in the tree stages nothing. Confidence closes at
high.

**The replacement is a shape rather than a rule, which is the better outcome and
was not what the finding proposed.** It asked for the instruction to be replaced
with the outcome. What shipped is *name the scratch file `.tmp` and the trap
cannot fire* — a thing that cannot be forgotten at the wrong moment, rather than
a prohibition to remember. `ship-pr` carries that clause inline instead of only
pointing, because it is the half you need while writing the file.

**Two gaps kept rather than dropped**: a scratch file under any other extension
is not covered, and `git ls-tree -r HEAD --name-only` is still the way to confirm
what landed. A narrower true rule loses coverage, and saying where is part of
taking this.

---

### F6 — step 7 names one merge shape; 137 commits on `main` are not that shape

Step 7 is `gh pr merge <n> --merge --delete-branch`, with no mention that squash
and rebase exist. `REPO-AUDIT` `G5(b)` was **closed by decision** on 2026-09-03:
both stay enabled.

Measured on `origin/main`, 2026-09-03: **535 merge commits, 137 single-parent
first-parent commits, 673 total.** Those 137 are squashes and direct pushes.
Both deploy monitors walk `--first-parent` *because* of them — `deploy-sweep.mjs`
inherited a blind spot from walking `--merges` and was corrected on 2026-09-03
(`G5(a)`, which is the very commit that last edited this skill), and
`deploy-alarm.yml` was written with the same comment.

So the skill's own step 9 and its sweep paragraph both silently depend on a fact
the loop above them never states.

**Proposal.** One clause in step 7: `--merge` is the shape this repo uses and
the reason is that history reads as prose; squash and rebase are enabled and
neither is wrong, and **a squash still lands one first-parent commit that is
checked exactly the same way**. Do **not** quote the count — it moves, and the
skill argues against quoting moving numbers at `:79`. **Posture: documentation
only. No change to the merge command, and no proposal to disable anything** —
`G5(b)` decided that and this menu does not reopen it.

**Evidence.** `git log --first-parent --format='%p' origin/main | awk '{print NF}'
| sort | uniq -c` → 1×0, 137×1, 535×2 (2026-09-03). `grep -c squash` on
`SKILL.md` → `0`. `REPO-AUDIT` `G5`, both halves.

**Confidence: high** on the numbers. **Medium on whether it is worth a clause** —
no incident is attached to it, and what would raise it is a merge here actually
being squashed and something downstream mis-reading it. Take it low.

**Ongoing cost:** one clause, and it does not name a number, so it does not rot.

**Taken, 2026-09-03 (PR #664).** One clause, documentation only, merge command
unchanged, `G5(b)` not reopened.

**The finding's own instruction not to quote a count was vindicated inside the
life of this menu.** `G5` counted 117 single-parent first-parent commits; the
re-measure on the taking branch returned **137 against 541 merge commits** —
twenty more in about a day. The clause says *"a large fraction"*, which stays
true without maintenance.

**Confidence was medium on whether this was worth a clause and the work did not
raise it.** No incident is attached and every PR here has used `--merge`. What
justifies it is one level down: step 9 and both deploy monitors already depend on
a squash landing one first-parent commit, so the skill was relying on a fact it
had never written. Taken low, as the finding said.

---

### F7 — nothing about a stacked PR, and step 7 recommends the flag that kills one

Step 7 recommends `--delete-branch` unconditionally, and argues for keeping it
even now that `delete_branch_on_merge` is on, because the local half is still
yours. Both true.

The memory layer holds `stacked-pr-base-deletion`: **`gh pr merge
--delete-branch` on a base branch closes the child PR stacked on it, and the
child cannot be reopened — only replaced.** That is an irreversible outcome
produced by the exact command the skill recommends, and the skill is silent on
it.

Memory fires on relevance and may not be recalled. A skill fires on its
description, and this one's description already says *"merging"*.

**Proposal.** One sentence in step 7: if another open PR is based on this branch,
`--delete-branch` closes it and it cannot be reopened — merge the child first, or
retarget it, before merging the base. **Posture: documentation only, one
sentence. No change to the recommended command.**

**Then delete nothing from memory.** The memory entry carries the incident; the
skill carries the rule. `SKILL-AUDIT`'s cross-layer findings are consistent that
a lesson living in two layers is a cost, but this is the case where the skill
needs the rule at the moment of the command and the memory keeps the case.

**Evidence.** `grep -c "stack\|worktree"` on `SKILL.md` → `0` (2026-09-03). The
memory file `stacked-pr-base-deletion.md`.

**Confidence: medium.** The memory entry is the only record; this pass did not
reproduce the GitHub behaviour, and **what would raise it is finding the closed
child PR in `gh pr list --state closed`** and naming its number in the sentence.
Do that while taking it.

**Ongoing cost:** one sentence.

**Taken, 2026-09-03 (PR #665).** Documentation only, one paragraph in step 7, the
merge command unchanged, and the memory entry deliberately kept.

**Confidence closes at high, by doing what the finding said would raise it.**
Verified on GitHub, not from memory: **#261** is `CLOSED` with `mergedAt` null
and base `category-skill-bonus`; **#260** merged that base at 19:13 on
2026-08-24; **#262** — same title, same head branch, against `main` — merged
ninety seconds later. Both numbers are in the shipped sentence, which is what
makes it checkable by the next reader.

**One thing not re-run, and it is stated in the PR rather than hidden:** the two
error strings (`gh pr reopen` → *"Could not open the pull request"*, and
`gh pr edit --base` refusing on a closed PR) come from the memory entry written
on the day. Reproducing them would mean deliberately closing a live PR.

**The two-layer duplication is intended here**, against this menu's general
preference. The memory entry keeps the case and the errors; the skill takes the
rule and the recovery, because the rule is needed at the moment the command is
typed and memory only fires when it happens to be recalled.

---

### F8 — three passages that should be cut or moved, and a rule about which

386 lines are read in full every time this fires, and everything added to step 4
competes with step 9 for attention at the moment step 9 is skipped. This pass
proposes adding to five sections; it should subtract from three.

- **`A changed secret needs the dev server restarted` (`:360–375`, 15 lines).**
  A dev-server and importer failure — `.dev.vars` read at boot, the 0-second
  failure tell. Nothing in it happens during a PR. **Move to `windows-shell`**,
  which owns the local-shell traps, or delete and let the tell live in memory.
  The one line worth keeping in `ship-pr` is the last: a rotation is **two**
  places, because the second is a Pages secret and that is a shipping fact.
- **`Line endings` (`:350–358`, 9 lines).** Six of those nine restate what
  `windows-shell` says before pointing at it. **Compress to two lines**: `.sql`
  is LF by `.gitattributes` and the smoke test fails a CR; `windows-shell` before
  any in-place edit.
- **`Pruning`'s closing two paragraphs (`:245–250`, 6 lines).** A good lesson —
  writing down what a change was supposed to achieve rather than what was left
  standing — and the **third** meta-paragraph of that kind in the file, after the
  one at `:226–231` in the same section. **Keep the first, cut the second.** The
  measured table above them is the section's value and is not in question.

**Proposal.** One PR, ~30 lines out, with every moved sentence landing somewhere
named in the same PR. **Posture: move and delete only. No new content, and the
PR must show both halves of every move** — a sentence lifted out and not landed
is how the next pass finds a gap instead of a duplicate.

**Evidence.** Line ranges read directly, 2026-09-03. `wc -l` 386.

**Confidence: high** that the file is long for what it does. **Medium on the
third item** — some of the meta-paragraphs are why this skill works, and cutting
the wrong one costs more than the lines save. What would raise it is Nate's read;
this is a taste call and should be taken as one.

**Ongoing cost: negative**, which is the point of the finding.

---

### F9 — the ordering rule writes to production and never names the copy you hold yourself

*The ordering rule* instructs `node scripts/d1-apply.mjs --remote …` **before**
the merge — a write to the live database, deliberately ahead of any review, with
no mention of what happens if it is wrong.

`scripts/d1-backup.mjs` exists (2026-09-02) and its header states the case
plainly: D1 Time Travel is the recovery mechanism, it is a **rolling 30 days held
by Cloudflare in the same account as the data it protects**, and this script is
*"the other half: the copy you hold yourself."* It exists because `wrangler d1
export` fails outright on this database — one fts5 virtual table,
`journal_fts`, makes the whole thing un-exportable and no flag skips it.

The skill names `d1-apply`, `drift-check`, `repo-vs-live` and `deploy-sweep`. It
does not name `d1-backup`.

**Proposal, and it recommends against the obvious version.** Do **not** add a
backup step to the ordering rule. Most applies here are one data script and a
per-apply backup is a ritual that would be skipped within a week — the ongoing
cost exceeds the impact, and `audit-menu` says a proposal in that state should
say so. **Add one sentence** instead: the rule writes to production before
review, recovery is Time Travel plus `d1-backup.mjs`, and `docs/…/operations.md`
→ *Recovery* has it. **Posture: documentation only, one sentence, no new step in
the loop.**

**Evidence.** `scripts/d1-backup.mjs:1–25`; `grep -c "d1-backup"` on `SKILL.md`
→ `0` (2026-09-03).

**Confidence: high** on the absence and on what the script does. **Low that it
matters** — no incident is attached, and what would raise it is a bad `--remote`
apply that needed recovering. **This finding recommends the smallest version of
itself, and declining it outright is a defensible outcome.**

**Ongoing cost:** one sentence.

---

### F10 — no step reads the CI run before merging, and this finding recommends declining

`tests.yml` runs the five suites on every pull request and reports **after** the
PR is opened. The skill says so, correctly, at `:15–21`, and tells you to treat
it as a second pair of eyes rather than a reason to skip step 4. But the loop has
no step between 6 (open the PR) and 7 (merge) that **reads** it.

At the merge rate here — 48 PRs on 2026-09-01 — a red CI run that contradicts a
local pass would go unread. That is structurally the same failure as the Pages
check nobody read for four days.

**Proposal: decline, and record why.** Adding *"read the CI result"* to the loop
creates a fourth thing that depends on a person remembering, which is the
mechanism that has already failed twice on this exact surface. The repo's answer
to that failure was **not** another manual read — it was `deploy-alarm.yml`,
which runs whether or not anyone remembers. The honest options are: leave it, or
propose an equivalent unattended alarm for CI, and **that is a `REPO-AUDIT`
finding about the workflow, not a `ship-pr` finding about the skill.**

Recorded here rather than filed there, because the shape it belongs to is a
menu that is closed, and because the negative result is the useful part: the
next reader who notices this gap should find the reason it was left, not derive
it again.

**If it is taken anyway**, the only version worth taking is one clause in step 7
— *before merging, glance at the PR's checks; a red `tests` run is not a gate and
is worth thirty seconds* — with **posture: documentation only, no gate, and no
claim that it will be remembered.**

**Evidence.** `tests.yml` read in full; `SKILL.md:15–21`; the loop's steps 6 and
7. `HEALTH-AUDIT` `F2` for the merge-rate figures. All 2026-09-03.

**Confidence: high** on the gap, **high on the recommendation to decline**.
Nothing would raise the case for taking it except a red CI run that actually
reached `main`.

**Ongoing cost if taken:** a check to remember, forever, which is the whole
argument against it.
