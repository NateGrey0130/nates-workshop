# Meta-audit — the menus as a reference, and the discipline that fills them, 2026-09-03

> **Since 2026-09-16 the closed findings live in `META-AUDIT.closed.md`**,
> moved there verbatim with their headings, numbering and notes; this file
> keeps a one-line pointer per moved finding where its heading was, and holds
> in full every finding whose own section records no outcome. The closed file
> is a record like this one, and the `*AUDIT*.md` glob reaches both.

> **Work was opened on this menu on 2026-09-22.** Read each finding's own
> heading for its state and its PR number; this line does not give it. Later
> passes have added sections after the original one, each under its own dated
> `##` heading at the end of the file:
> **`## Opened by the protocol retrospective, 2026-09-04`**, then
> **`## Opened by the audit retrospective, 2026-09-06`**, then
> **`## Opened by the A13 revisit, 2026-09-21`**. The original pass was filed
> 2026-09-03 against `main` @ `3332349` (the merge of #641), the protocol
> retrospective against `2eed604` (the merge of #699), the audit retrospective
> against `c54a794` (the merge of #750), and the A13 revisit against `55235b3`
> (the merge of #1208). Findings are
> `### A<n> — <severity> — <title>`, severity lowercase, and they run in each
> pass's own order rather than in severity order across the file.
>
> **`A18` is an information item that proposes nothing**, which is worth knowing
> before reading it as outstanding — it is a dated snapshot and says so.
>
> **This line read "There is open work on this menu" from 2026-09-06 until
> 2026-09-21**, when `A19` was declined and the last item that could be called
> open stopped being one. It was true on every one of those days. **It names no
> finding number**, so the tree-wide grep for `A19` that went with that decline
> could not reach it, and did not — it was caught by reading the header. `A17`
> is the finding about precisely that shape, and this is an instance of it on
> the menu `A17` was filed on.
>
> **This header does not comply with the rule `A13` shipped, and is deliberately
> not retrofitted to.** `A13` added *What a status header may carry, and what it
> may not* to `audit-menu` on 2026-09-04, and its posture was **no retrofit of
> any existing header** — records stay as they are, and the rule governs the
> next line written. The sentence above is that next line, and it carries a
> verdict and a reading instruction and no per-finding state. **The paragraph
> below it does not**, and stays: it enumerates the original pass, which is what
> the rule now says a header may not do. Left standing on purpose, as the
> nearest thing to a worked example of the difference.
>
> Everything from the original pass is settled: `A2`–`A12` taken, `A1` DECLINED
> — no index was built, and the skill records why beside the `find` command.
> Status for any finding lives under its own heading; this line does not count
> them.
>
> **A sentence about `apps/pick3cut5/AUDIT.md` `F11` and `F12` was corrected out
> of this header on 2026-09-04.** It described them as open work this menu had
> filed elsewhere; both were taken on 2026-09-03, in PRs #653 and #654, hours
> after this file was written against #641. That menu's own header says nothing
> is open there. The correction follows `A3` — the status claim only, and the
> replaced wording is not reproduced here. **`A13` is the finding about why it
> was there**, and it treats this header as its evidence rather than as an
> incidental repair.
>
> **`A` because it collides with nothing.** Censused 2026-09-03 by walking every
> menu's own item markers — `###`/`##` headings, the `- **S1 —**` bullets in
> `CLASS-AUDIT` and the `**T1.**` bold leads in `pick3cut5/AUDIT` — the letters
> in use are `B C D F G M N R S T`. No menu carries an `A<digit>` item. `P` is
> also free (it was reserved for a `PORTABILITY-AUDIT.md` that will never
> exist) and is deliberately not used, because a `P1` would read as that menu's.
>
> **This menu's own trap, which is about its layout. THE FINDINGS ARE NOT IN
> SEVERITY ORDER.** `UI-AUDIT`, `REDESIGN-AUDIT` and `apps/character-creator/AUDIT`
> are all numbered most-severe-first, so a reader who knows this repo will open at
> `A1` expecting the worst of it. `A1` is `medium`. **The two `high` findings are
> `A8` and `A9`**, two thirds of the way down.
>
> The order here is the **brief's** instead: `A1`–`A7` are Part 1, the menus as a
> reference; `A8`–`A12` are Part 2, why the findings are wrong. That is a real
> grouping and it is worth having, but it is not the convention, and nothing but
> this line says which one is in force.
>
> **The second half of the trap is worse and is not about layout.** Most findings
> here quote `.claude/skills/audit-menu/SKILL.md` as their evidence. **Taking any
> one of them edits that skill**, which turns every other quotation of it in this
> file into a record of what the skill used to say — with nothing marking which.
> `A3`, `A5`, `A8` and `A11` all quote it. If one has shipped, re-read the skill
> before implementing another from the text reproduced here.

---

## Baseline, established before anything else was read

**The menu list, from the tree.** `find . -name '*AUDIT*.md' -not -path
'./.cache/*' -not -path './node_modules/*'` returns **18 paths**, run
2026-09-03. Seventeen are menus. The eighteenth,
`docs/prompts/SKILLAUDITPROMPT.md`, is a **brief** — the prompt that produced
`SKILL-AUDIT.md` — and is not a menu.

**Plus the one the glob cannot find:** `SETUP-v2-CHANGES.md`, eight numbered
changes under `## Changes` with dated outcome notes. The skill names it three
times and says outright that the command does not return it and **that this is
not a bug in the command** — a glob is the wrong shape for a convention nothing
enforces. So the real figure is **eighteen menus**, reached by two different
routes that each miss one file in opposite directions.

**Total lines: 23,461** across those eighteen (`wc -l`, 2026-09-03), 212,159
words. The status headers — the first 30 lines of each — are **540 lines and
4,896 words**, or **2.3% of the corpus.**

| menu | lines |
|---|---|
| `apps/character-creator/INGESTION-AUDIT.md` | 3,017 |
| `BOOK-INGEST-AUDIT.md` | 2,494 |
| `SKILL-AUDIT.md` | 2,435 |
| `HEALTH-AUDIT.md` | 2,058 |
| `apps/character-creator/UI-AUDIT.md` | 2,033 |
| `MACHINE-AUDIT.md` | 1,969 |
| `REPO-AUDIT.md` | 1,693 |
| `apps/character-creator/REBUILD-AUDIT.md` | 1,685 |
| `apps/character-creator/CLASS-AUDIT.md` | 1,135 |
| `apps/character-creator/REDESIGN-AUDIT.md` | 1,117 |
| `apps/media-vault/BULK-AUDIT.md` | 885 |
| `apps/media-vault/ISBN-AUDIT.md` | 829 |
| `EFFICIENCY-AUDIT.md` | 448 |
| `apps/pick3cut5/AUDIT.md` | 436 |
| `apps/character-creator/AUDIT.md` | 420 |
| `DOCS-AUDIT-2.md` | 374 |
| `SETUP-v2-CHANGES.md` | 219 |
| `DOCS-AUDIT.md` | 214 |

**`main` @ `3332349`**, 2026-09-03 15:21 EDT. **Last merged PR: #641** —
*"Correct REPO-AUDIT's portability boundary: that menu was never coming."*

### What is actually open, established by reading under the headings

Not by a grep, and not by trusting a header. Every item below was read to the
next heading.

| open | where | evidence |
|---|---|---|
| **`UI-AUDIT` `F30`** | `apps/character-creator/UI-AUDIT.md:1839` | **Re-verified live today** — see *Retrofit* below. Confirmed in the running app, both halves. |
| **`REPO-AUDIT` `G5` half (b)** | `REPO-AUDIT.md:473` | Its own note: *"Half (b) is NOT taken: squash and rebase remain enabled… still available as a narrowing."* The header calls it *taken in part*, not open. |
| **`SETUP-v2-CHANGES` open question 1** | `SETUP-v2-CHANGES.md:24` | *"A test finding rather than a documentation one; **filed for a separate PR**."* It was never filed and never fixed — measured today, see `A5`. |
| **`SKILL-AUDIT` `F12`'s named test** | `SKILL-AUDIT.md:969` | Which allowlist governs a session started in the working directory is **still untested**. `CLAUDE.md` says so in its own words: *"NOT established, and do not assume either way."* |

**And one thing every header would have told you is open, and is not.**
`BOOK-INGEST-AUDIT.md`'s header says `F3`'s schema question is still open. It
closed at **08:41 today** in PR #616. See `A3`.

> **Adjusted 2026-09-03, later the same day. The table above is the baseline as
> measured and stands as one; ALL FOUR of its rows have since closed.**
> `SETUP-v2-CHANGES` open question 1 became `apps/pick3cut5/AUDIT.md` `F11`
> (`A5`), which was taken in PR #653 along with the `F12` it opened.
> **`REPO-AUDIT` `G5` half (b) was closed by decision in PR #655** — squash and
> rebase stay enabled, and that finding is now closed entire. **`SKILL-AUDIT`
> `F12`'s named test was RUN in PR #656**: each directory is governed by its own
> project settings, and they do not compose. **`UI-AUDIT` `F30` was taken in PR
> #657**, and taking it turned up a second defect the finding never mentions —
> the picker matched categories with a plain `includes`, which drops ten of one
> live grant's thirteen. Nothing this menu found or filed is open.

So: **four open items, in four different menus, and only one of them is a
finding whose own heading a reader would find by scanning.** Two are halves of
findings the headers describe as taken, and one is a sentence in a decisions
paragraph carrying no number at all.

### This audit was read-only

Every remote call was a `SELECT` — `scripts/audit-citations.mjs --remote F3` and
nothing else. **One local write is declared:** verifying `UI-AUDIT` `F30`
required two rows in **local** D1's `pending_skill_picks` and one skill added to
local character 1. Both were reverted and the revert verified (`pending = 0`,
`has_climbing = 0`). No production write, no deploy, no setting changed.

---

## Three premises of this menu's own brief were wrong

Recorded rather than quietly fixed, because two of them are instances of the
thing this audit is about.

1. **"`docs/rules-audit.md` is not a menu and the glob returns it."** That file
   **does not exist** (`ls docs/rules-audit.md` → *No such file or directory*,
   2026-09-03). The glob's one non-menu return is
   `docs/prompts/SKILLAUDITPROMPT.md`. The brief was right that the glob returns
   a non-menu and wrong about which; the substance survives, and `A7` answers the
   question it meant to ask.
2. **"seventeen audit menus."** Seventeen is the count of `*AUDIT*.md` files
   **including** the brief and **excluding** `SETUP-v2-CHANGES.md` — that is,
   the glob's own answer with both of its errors left in, which is precisely what
   `REPO-AUDIT` `G11` did and was re-scoped for. The count is **eighteen**.
3. **"Only `UI-AUDIT` `F30` appears open, so this is small."** Four items are
   open (table above), and the brief's instruction to *establish the real open
   set first* is what found the other three. The instruction did its job; the
   estimate beside it did not.

**None of these is a slur on the brief.** They are the same failure the brief
asks about, arriving in the document that asks — which is the strongest available
evidence that the failure is structural rather than a matter of care. `A9`
argues that is exactly where the fix belongs.

---

# Part 1 — the menus as a reference

## First: what `G9` actually says about an index

`REPO-AUDIT` `G9` did not merely decline to propose one in passing. It has a
paragraph headed **"Explicitly NOT proposed: an index file listing the menus"**,
and its reason is one sentence:

> The skill argues at length against a maintained count of them and has been
> wrong every time it tried; an `AUDITS.md` would be exactly the artefact it
> warns about.

`G9` was then **closed without being taken** (PR #625) for a different reason
again — `HEALTH-AUDIT` `F4` had settled the adjacent rename question one day
earlier, the other way.

**So: is the index Nate wants the same artifact `G9` declined?**

`G9`'s stated reason attacks a **maintained count**, and an index of *paths,
scope, status and traps* need not carry one. On that reading they are different
artifacts and `G9`'s argument misses. **But `G9`'s heading is broader than its
reason**, and the deciding evidence is not in `G9` at all.

**The index already exists. It is the `audit-menu` skill's shape table, and it
has never once been right.** Its own text records three readings — 2026-08-31
(missing two files, three wrong cells), 2026-09-02 (missing four), later
2026-09-02 (thirteen of fourteen rows correct, one wrong cell). `SKILL-AUDIT`
`F7` fixed it on 2026-09-02 **and predicted its own falsification in the same
paragraph**, because filing `SKILL-AUDIT.md` made a new menu.

Read a fourth time, **2026-09-03**: the table carries **15 rows** against
**18 menus** in the tree. Missing: `MACHINE-AUDIT.md`, `DOCS-AUDIT-2.md`,
`REPO-AUDIT.md`.

That is a **0-for-4 record** on the artifact being proposed, in the one place it
has actually been tried. It is not an argument about doctrine; it is a
measurement. `A1` proposes declining the index on that basis and `A2` proposes
the narrower thing that would have made all four readings correct.

## What the reference question costs today — measured, not estimated

`HEALTH-AUDIT` `F8` measured the old cost as *"establishing that there is no
open work costs an audit."* `F8` was taken (PR #531) and every menu but one now
opens with a status header. So the question is what it costs **now**.

**Question asked, from a cold start: "is anything open?"** Method and cost,
measured in this session, 2026-09-03:

| pass | cost | answer it gives |
|---|---|---|
| glob + `wc` + read all 18 status headers | **3 tool calls, 540 lines, 4,896 words** — under a minute | `BOOK-INGEST` `F3` open; `UI-AUDIT` `F30` open |
| read under the headings, per the skill's own rule | **11 further tool calls**, a heading census of ~250 items across 18 files, outcome-note extraction across 100 findings, 7 findings read in full — roughly 4,000 lines | four open items, **and `F3` is not one of them** |

**`F8` paid the cost down by roughly 30×, and did not make the answer
reliable.** Of the two open-claims the header layer makes today, **one is wrong**
— `BOOK-INGEST` `F3`, closed at 08:41 today. It also misses three of the four
real open items, all of which sit inside findings the headers describe as taken.

That is n=2, and it is stated as n=2 rather than as "50%" on purpose. The useful
form of the number is not a rate: **the header layer is fast, it is the only
affordable pass, and it is wrong in both directions today** — one false open, three
missed opens.

**"Which menu covers the wizard?"** costs one `grep -l` and is answered
correctly: `UI-AUDIT`, `REDESIGN-AUDIT` and `INGESTION-AUDIT` all name it and
each header states its scope in its first paragraph. **This question is not the
problem** and an index would not improve it.

**"Has this been decided before?"** is the expensive one and the one that has
actually cost money. `G9` and `G10` were both closed for failing it, and the
check is a grep the skill does not ask for. See `A11`.

## The status headers, checked against their own findings

Each header read against the findings beneath it, 2026-09-03.

| menu | header claim | verdict |
|---|---|---|
| `BOOK-INGEST-AUDIT.md` | *"They are not all closed — `F3` … schema question still open"* | **STALE.** `F3` fully closed 08:41 today, PR #616. `A3`. |
| `HEALTH-AUDIT.md` | *(no status header at all)* | **Deliberate**, and the decision is recorded only in a commit message. `A4`. |
| `SETUP-v2-CHANGES.md` | *"All eight taken"* | True of the eight; **silent on a live item** in the decisions paragraph below it. `A5`. |
| `REPO-AUDIT.md` | *"nothing is open"* + *"taken in part: `G5` half (a) only"* | Internally consistent, and a reader who stops at *nothing is open* misses that (b) is a standing proposal. |
| `MACHINE-AUDIT.md` | *"nothing is open"*, `M19`/`M21` taken, `M20` superseded, `M22` same-day | **Accurate.** |
| `SKILL-AUDIT.md` | all 25 `F` closed, all 8 `N` decided | **Accurate.** Its *"filing this makes a fifteenth menu"* line is a dated historical statement, not a status claim. |
| `DOCS-AUDIT.md`, `DOCS-AUDIT-2.md`, `EFFICIENCY-AUDIT.md`, `CLASS-AUDIT.md`, `INGESTION-AUDIT.md`, `REBUILD-AUDIT.md`, `REDESIGN-AUDIT.md`, `UI-AUDIT.md`, `BULK-AUDIT.md`, `ISBN-AUDIT.md`, `pick3cut5/AUDIT.md`, `cc/AUDIT.md` | various | **Accurate**, each against its own findings. |

**Twelve of eighteen headers are accurate, one is stale, one is absent by
decision, one is silent about a live item, and one is accurate but reads as more
final than it is.** That is a better record than the corpus deserves and it is
not good enough to answer the question from alone.

### The disagreement with the memory store, which no repo grep reaches

`MACHINE-AUDIT` is described in **three places** and they disagree three ways:

| source | says |
|---|---|
| `MEMORY.md`'s index line | *"M1-M18 all shipped 2026-09-02, then **M19-M20 were filed OPEN** the same evening"* |
| `machine-audit-menu.md`, the memory body | *"As of 2026-09-02: `M1`–`M18` all taken and closed, **nothing open**"* — silent on `M19`–`M22` |
| `MACHINE-AUDIT.md`'s own header | nothing open; `M19`/`M21` **taken 2026-09-03**, `M20` closed superseded by `M22`, `M22` filed and taken |

**The file is right.** Both memory layers are stale, in different directions, and
**both carry the guard that should have prevented it** — *"Read its header for
status, never this line."* The guard fired and the staleness persisted anyway,
because a line that says *do not trust me* is still the line that gets read.
That is the sharpest thing in this section and it is an argument against `A1`:
a status field in an index inherits exactly this, guard and all.

`repo-audit-menu.md` says PRs **#619–#640**; #641 merged the same day. Minor, and
the same shape.

**Twelve of eighteen menus have a dedicated memory file** (measured 2026-09-03,
`grep -l` across the store's 66 files). The six without are
`BOOK-INGEST-AUDIT.md`, `DOCS-AUDIT.md`, `REBUILD-AUDIT.md`,
`apps/character-creator/AUDIT.md`, `apps/pick3cut5/AUDIT.md` and
`SETUP-v2-CHANGES.md` — and **two of the four open items live in those six.**
The memory store is already a partial index of the menus, and it is partial in
precisely the wrong place.

## What already does the index's job, before proposing an eighteenth place to look

Established by reading each, 2026-09-03:

| surface | what it already gives | what it rots about |
|---|---|---|
| `.claude/skills/audit-menu` shape table | path, prefix, heading level, shape, and the two not-a-heading families | **the file list itself** — wrong on all four readings; missing three menus today |
| `docs/prompts/README.md` | brief → menu, for 10 of the audit menus, plus which shipped under a different name and which produced nothing | **two briefs short again** — no `docs-audit-2-prompt.md`, and no brief for `REPO-AUDIT.md` exists anywhere on this machine (`A12`) |
| the memory store | 12 of 18 menus, each with its trap and its status | status, as above |
| `CLAUDE.md` | the nine skills and when to reach for each; **no menu list** | — |
| `SETUP.md` | machine setup and junctions; **no menu list** | — |
| each menu's own status header | status, scope, and the one thing that misreads | one stale, one absent, one silent (table above) |

**A reader today has four partial indexes and no complete one**, and each of the
four rots on the field an index would exist to carry.

## What an index would go stale about, and how fast

Named specifically, because "it would go stale" is not an argument:

- **status** — one PR. `BOOK-INGEST` `F3` closed at 08:41 and the file's own
  header was stale by 08:45, when the next commit touched it without updating it.
- **the file list** — one PR. Four readings, four wrong lists.
- **any count** — the skill's doctrine, and `G11` is the worked example.
- **"which menu covers X"** — slowest, measured in weeks; scope statements have
  held.
- **the trap line** — slowest of all, and the only field with a good record.

**What an index would have to omit to be worth having: the file list, every
status, and every count** — which is everything a reader would open it for.
What survives is scope and traps, and those already sit in each menu's first
fifteen lines, where they cannot disagree with the file they describe.

---

# Part 2 — why the findings are wrong

## The five wrong claims, re-derived one at a time

| # | asserted, in its own words | actually true | cheapest check that would have caught it | caught |
|---|---|---|---|---|
| `G8` | *"The suite **has never been runnable on a bare clone**"* | A bare clone passes **1,662 checks**. The blocker was one `existsSync` on eleven `C:\` paths in `instruction-paths.mjs`. | `git clone` to a scratch dir and run the suite — **~90s** | **After** Nate read it — while taking it (PR #620) |
| `G1` | Suggested `git log --first-parent --no-merges main` as the way to count direct pushes | It reports **138**; **117** are squash-merged PRs carrying `(#N)`. Real direct pushes: **21**, all 2026-04-18→26. | Run the command the proposal names — **~5s** | **After** — while taking it (PR #621) |
| `G5` | *"the merge-commit path, **exclusively**"* | 501 merge commits **and 117 squash merges**. | `git log --first-parent --no-merges main \| grep -c '(#[0-9]'` — **~5s** | **After**, and by accident: disproved by taking `G1` |
| `G11` | *"Seven menus at the root; eight under `apps/`"* | **Nine and nine.** The root figure was taken with the `*AUDIT*.md` glob **that `G9`, two findings above, exists to warn about**. | `find apps -name '*AUDIT*.md' \| wc -l` — **~2s** | **Before**, in the menu's own 2026-09-03 re-verification pass |
| `G15` | *"produces **no signal at all**"* | `deploy-sweep.mjs` already shells out to `wrangler deployments list` and compares timestamps. The true gap is narrower: no signal saying **which build** is live. | Read `deploy-sweep.mjs`'s Worker half — **~30s**, and **the finding's own last line told a taker to do it** | **Before**, same re-verification pass |

**Every one is an inference.** None contains a figure that would have looked
wrong; `G8`'s sentence contains no number at all and was the most expensive of
the five. And the asymmetry `G18` names holds up under this re-derivation: the
two caught **before** Nate read them were caught by a systematic re-measurement
pass, and the three caught **after** were caught by someone implementing them —
the expensive place.

**The cheapest check for all five totals under three minutes.**

## The three re-scopes are a different failure, and the difference matters

`G5`, `G11` and `G15` carry `RE-SCOPED` banners as well as `Adjusted` ones. A
re-scope is not a wrong claim corrected; it is **a finding that turned out to be
about something else**, and the causes differ:

- **`G5`** re-scoped from *tidiness* to *a live blind spot*: both deploy monitors
  walk `git log --merges` and are blind to 117 commits. The wrong claim
  ("exclusively") made the finding look **smaller** than it was. Half (a)
  shipped (#636); **(b) is the open item in the baseline table**.
- **`G11`** re-scoped because the arithmetic was the problem: a placement rule
  stated as *"nine and nine"* needs re-counting every time a menu lands, with the
  tool already proven wrong. The re-scope's whole content is **"the rule must be
  countless."**
- **`G15`** re-scoped because most of the proposal already existed, and then the
  **mechanism changed again at take-time** — the re-scope's own note ("the route
  must be reachable without an Access session") killed the route, and it shipped
  as a `--var GIT_SHA` binding read through the Cloudflare API instead.

**So the three re-scopes have three different causes and only one shares the
five's.** Folding them into "the same problem" would be wrong: `G11`'s cause is
*a rule that carries a number*, `G15`'s is *proposing before reading the tool*,
and only `G5`'s is *an inference stated as a measurement*. What they share is
**when** they were caught — all three in the same 2026-09-03 re-verification
pass, which is the evidence for `A10`.

## The doctrine sentence is false, and twelve outcome notes say so

The `audit-menu` skill states, under its highest-value rule:

> **Every finding taken so far has turned up an error in its own premises** — not
> a slur on the audits, just what happens when a document sits still while the
> tree moves.

**Tested against the notes, 2026-09-03.** Method: for every finding in
`HEALTH-AUDIT`, `MACHINE-AUDIT`, `SKILL-AUDIT`, `DOCS-AUDIT-2` and `REPO-AUDIT`
— 100 items — the block was extracted from its heading to the next and its
outcome note read. **Twelve notes state in their own words that the premises
held:**

| finding | its own note |
|---|---|
| `HEALTH-AUDIT` `F5` | *"Every premise held on re-check (skill Twenty-six, README Thirty-three, `schema.sql` 33)."* |
| `HEALTH-AUDIT` `F7` | *"Every premise held on re-check."* |
| `HEALTH-AUDIT` `F9` | *"Re-audited first and the premise held exactly."* |
| `HEALTH-AUDIT` `F19` | *"Verified before asserting it: the URL returns 200…"* |
| `HEALTH-AUDIT` `F23` | *"Premises re-checked first and all held, including the 14-minute staleness."* |
| `MACHINE-AUDIT` `M4` | *"Every premise re-checked: all four profile paths still absent…"* |
| `MACHINE-AUDIT` `M6` | *"Every premise re-checked and confirmed, including the absence claim."* |
| `MACHINE-AUDIT` `M15` | *"Both claims re-measured rather than re-read, and both hold exactly."* |
| `MACHINE-AUDIT` `M16` | *"Every premise re-measured and every one holds."* |
| `SKILL-AUDIT` `F2` | *"Every premise re-checked and every one held — 137 in scope, 205 in `docs/`…"* |
| `SKILL-AUDIT` `F4` | *"Both premises held."* |
| `SKILL-AUDIT` `F11` | *"Every premise held."* |

**And the sentence is not merely false — it is false in a way that hides the
useful distinction.** `HEALTH-AUDIT` `F7` says *every premise held* and then
records that the placement the finding named does not exist and that its heading
miscounts "three places". `SKILL-AUDIT` `F4` says *both premises held* and then
records that **two of its own replacement sentences were false**, caught by
measuring instead of shipping.

So there are two different things happening and the skill's sentence conflates
them:

- **the finding's premises were wrong** — rarer, and the expensive one, because
  a taker implements from them;
- **something was found wrong while doing the work** — near-universal, and mostly
  *healthy*: it is what auditing the finding is for.

Stated as *"every finding turns up an error in its premises"* the rule reads as
a claim about the documents. Stated truthfully it is a claim about the **method**
— that checking always finds something, which is a better reason to check. `A8`
proposes the correction.

## Did the evidence discipline work where it was used? Suggestive, and not controlled

**`G18`'s rule was already in force in two menus written the day before it was
filed.** Measured 2026-09-03 by counting `^**Evidence` lines against findings:

| menu | findings | `**Evidence**` lines | `**Confidence**` lines |
|---|---|---|---|
| `HEALTH-AUDIT.md` | 24 | **24** | **23** |
| `SKILL-AUDIT.md` | 25 `F` + 8 `N` | **25** | 0 |
| `REPO-AUDIT.md` | 18 | **0** | 0 |
| `MACHINE-AUDIT.md` | 22 | **0** | 0 |
| `BOOK-INGEST`, `UI-AUDIT`, `REDESIGN-AUDIT`, `DOCS-AUDIT-2` | 21/30/15/3 | **0** | 0 |

The convention came from `workshop\briefs\health-audit-prompt.md`, which
prescribes a six-field finding template: **Severity, Evidence, Impact, Proposal,
Effort, Ongoing cost, Confidence**. `HEALTH-AUDIT` used all of it.
`SKILL-AUDIT`'s brief asked for evidence differently and it used that half.
**`REPO-AUDIT`'s brief does not exist** (`A12`), and `REPO-AUDIT` used none of it.

**Error rates, counted by reading every outcome note, method stated:**

| menu | findings | notes recording an error in the finding's own premises |
|---|---|---|
| `REPO-AUDIT` (no evidence lines) | 18 | **5** — `G8` `G1` `G5` `G11` `G15`, by its own header |
| `HEALTH-AUDIT` (24/24 evidence, 23/24 confidence) | 24 | **3** — `F6` (the *reason* for a correct decision was wrong), `F7` (placement + a miscount), `F20` (closed as already-solved) |

**This is suggestive and it is not a controlled comparison, and it must not be
quoted as one.** The subjects differ: `REPO-AUDIT` audits GitHub settings and
git history, where a claim is cheap to check and easy to reason to wrongly;
`HEALTH-AUDIT` audits documents, where the evidence is the document. n is 18 and
24. **What is not soft** is the direction of the confidence marker: `HEALTH-AUDIT`
`F18`'s outcome note reads *"The low-confidence half is now high"* — the marker
flagged the half that needed checking, and that half is the one that moved. The
marker did the job it was added for, once, visibly.

## Where the rule should live — the briefs are reinventing it

Diffed three briefs plus two more, 2026-09-03, in
`C:\Users\natha\Projects\workshop\briefs\`:

| brief | its wording of the same rule |
|---|---|
| `health-audit-prompt.md` | *"**Verify, don't infer.** Every finding cites a file:line, a command you ran…"* — **stated twice**, once per half (lines 27 and 136) |
| `ui-audit-prompt.md` | *"A DOM measurement is not evidence… If a finding has no screenshot behind it, say so."* and *"Do not quote a count you did not verify against the tree in front of you."* |
| `class-audit-prompt.md` | *"quote counts only if you verified them against `--remote`"* |
| `workstation-consolidation-prompt.md` | *"**Verify before asserting.** Every observation in this brief was gathered in a…"* |
| `docs-audit-2-prompt.md` | *"Some of this is already pinned — **check before filing**"* |

**Five briefs, five wordings, one rule, and the skill owns none of it.** The
skill's `Every number carries its date and its source` covers numbers only;
`G18` extended it to claims **on 2026-09-03**, sixteen days after
`class-audit-prompt.md` said the same thing about counts and one day after
`health-audit-prompt.md` said it about everything.

**That is `G9`'s shape, committed by the finding that fixed `G18`'s shape.**
`G18`'s outcome note says the rule is *"a convention that starts today"*. It
started 2026-09-02, in two menus, at 100% coverage, and `G18` never mentions
them. Its facts were all correct; it re-proposed something already in practice
because nobody grepped. `A8`.

---

# Findings

- **A1** — medium — an index of the menus is the artifact `G9` declined, and the one place it exists has a 0-for-4 record — DECLINED, 2026-09-03 (PR #652), on Nate's word and on this finding's own — full text in `META-AUDIT.closed.md` under its own `### A1` heading.

- **A2** — medium — the skill's shape table carries a file list nothing can keep right; the two commands that produce it are already on the page — Taken, 2026-09-03 (PR #647), with `A7` folded in as `A7` itself directs. — full text in `META-AUDIT.closed.md` under its own `### A2` heading.

- **A3** — medium — `BOOK-INGEST-AUDIT`'s status header says `F3` is open; it closed four minutes before the file's next commit — Taken, 2026-09-03 (PR #643). Posture held: the header only — no finding, no — full text in `META-AUDIT.closed.md` under its own `### A3` heading.

- **A4** — low — `HEALTH-AUDIT` is the only menu with no status header, and the reason exists only in a commit message — Taken, 2026-09-03 (PR #645). Posture held exactly: one paragraph recording the — full text in `META-AUDIT.closed.md` under its own `### A4` heading.

- **A5** — medium — `SETUP-v2-CHANGES` records a live defect as "filed for a separate PR"; it was never filed and never fixed — Taken, 2026-09-03 (PR #644). Posture held: file, do not fix — no test was — full text in `META-AUDIT.closed.md` under its own `### A5` heading.

- **A6** — low — the memory store indexes 12 of 18 menus, and two of the four open items are in the six it misses — Taken, 2026-09-03 (PR #650). Posture held: corrections to existing memories, — full text in `META-AUDIT.closed.md` under its own `### A6` heading.

- **A7** — low — the glob returns a brief, and it is worth one clause rather than a fix — Taken, 2026-09-03 (PR #647), inside `A2` exactly as this finding directed. — full text in `META-AUDIT.closed.md` under its own `### A7` heading.

- **A8** — high — `G18` shipped a rule that two menus had been following at 100% coverage the day before, and calls it "a convention that starts today" — Taken, 2026-09-03 (PR #648), both edits. Posture held: documentation only, two — full text in `META-AUDIT.closed.md` under its own `### A8` heading.

- **A9** — high — the research discipline is re-derived in every brief, in five wordings, and the skill owns none of it — Taken, 2026-09-03 (PR #649), as written. Posture held: documentation only, one — full text in `META-AUDIT.closed.md` under its own `### A9` heading.

- **A10** — medium — the self-check pass already exists, it caught two findings before Nate read them, and nothing asks for it — Taken, 2026-09-03 (PR #651), as written. Posture held: a convention for a new — full text in `META-AUDIT.closed.md` under its own `### A10` heading.

- **A11** — medium — "has this been decided?" is not in the skill, it is a thirty-second grep, and it is the only check that reaches the errors re-measurement cannot — Taken, 2026-09-03 (PR #642), as written. Posture held: documentation only, one — full text in `META-AUDIT.closed.md` under its own `### A11` heading.

- **A12** — low — the brief archive is two short again, and the menu with the worst error rate has no brief anywhere — Taken, 2026-09-03 (PR #646), as proposed. Posture held: two files copied, — full text in `META-AUDIT.closed.md` under its own `### A12` heading.

## Retrofit — the open findings, labelled and re-verified

Per the brief: for each open finding, propose labelling its central claim
**measured** or **reasoned**, re-verifying as it goes, and report which did not
survive. Closed findings are **not** retrofitted — they are records.

### `UI-AUDIT` `F30` — **measured**, and it survives, verified against the running app

Verified 2026-09-03 on **port 8791** (the `nates-apps-8791` escape hatch, not
8788), served from this checkout, against **local** D1 — not production, because
`F30`'s controls write.

**Setup, declared:** two rows inserted into local `pending_skill_picks` for
character 1 reproducing `F30`'s production shape — one `related` grant with
categories, one `secondary` grant with `categories: NULL`. Both reverted
afterwards and the revert verified.

**All three of `F30`'s claims hold in the live app:**

| claim | measured |
|---|---|
| the picker offers every skill for every slot | **330 of 330** offered in all three slots, across **17 distinct categories**, while the related grant restricts to two (Espionage, Medical) |
| the *"show all skills"* checkbox never renders | **absent** — `hiddenCount` is 0 because `allowed` is null |
| neither panel names the kind | *"🎓 3 unspent skill picks — earned at level 3, level 4"* and *"2 from level 3, 1 from level 4"* |

**And the server half, proved by making it fail** rather than by reading it:

| request | result |
|---|---|
| two out-of-category picks | **HTTP 422** — *"Hand to Hand: Basic is Physical, which this grant does not cover"* |
| one out-of-category pick | **HTTP 200**, applied |

Exactly `F30`'s text: the picker offers the whole catalog for all three slots and
the server accepts exactly one. **Label: measured** — DOM and API, 2026-09-03,
local server.

**One correction to `F30`'s own text, found by rendering it.** `F30` quotes the
panel as *"🎓 3 unspent skill picks — earned at level 3, 4, 6"*. The template is
`C.pendingPicks.map((g) => 'level ' + g.granted_at_level).join(', ')`, which
renders *"level 3, level 4, level 6"*. The quotation is a transcription, not a
render. **It changes nothing about the finding** — the point is that the kind is
absent, and it is — but `UI-AUDIT`'s own header warns that seven of its proposals
were wrong rather than stale, and a quoted string is exactly the kind of thing a
taker would match on.

### `REPO-AUDIT` `G5` half (b) — **measured**, and it survives

*"Squash and rebase remain enabled."* Verified 2026-09-03: 117 squash-merged PRs
on `main` (the figure `G5`'s re-scope measured) and both `deploy-sweep.mjs` and
`deploy-alarm.yml` now walk `--first-parent`, so **half (a) removed the reason
to take (b)**. Its own note says so: *"it fixes nothing on its own."*
**Label: measured.** Recommendation: close it by decision rather than leave it
standing, and record why — the unnumbered one-line recommendation at the end of
*The plan*. It is deliberately not a finding here, because `G5` is
`REPO-AUDIT`'s and closing it is Nate's call on that menu.

**Recommendation acted on: `G5` half (b) was CLOSED BY DECISION 2026-09-03 (PR
#655).** Squash and rebase stay enabled, no repository setting changed, and `G5`
is closed entire. Every premise was re-measured first and all held — the three
merge buttons still `true` via the GitHub API, 117 squash merges unchanged, both
monitors confirmed on `--first-parent`, and `deploy-sweep --last 250` reaching
all 250 first-parent commits. **The retrofit label above needs no revision:** it
said *measured*, the measurement survived re-measurement, and the finding closed
on the strength of it rather than in spite of it.

### `SETUP-v2-CHANGES` open question 1 — **measured**, and it survives

See `A5`. Re-measured today: the check stands, `external` is empty, the fonts are
self-hosted. **Label: measured.**

### `SKILL-AUDIT` `F12`'s named test — **not measured**, and it is the honest state

*Whether a session started in the working directory is governed by that file, by
this repo's, or by both composed.* Still untested. `CLAUDE.md` says so outright:
*"NOT established, and do not assume either way… It has not been run."*
**Label: not measured**, and correctly so — the finding names the test and the
test has not been run. It is less load-bearing than it was, because the prune
(#571) made both lists withhold the same actions, which is the difference between
a posture and a guarantee.

**The label was right and is now spent: the test was RUN on 2026-09-03 (PR
#656).** Each directory is governed by its own project settings and they do not
compose — four cells, all four as that answer predicts. **`not measured` was the
honest label for exactly one day**, which is the best case for the convention
`G18` and `A9` argue about: it named the gap precisely enough that closing it was
a morning's work rather than a research project.

**Why it had gone unrun is the part worth carrying.** The 2026-09-02 attempt
concluded the test *"needs an interactive Claude Code session in each
directory"* and stopped. **It does not** — `claude -p` consults the same
allowlist and *refuses* on a miss because it cannot prompt, which is the same
observable. A finding can be blocked by a wrong premise about the **method** as
easily as by one about the subject, and **nothing in this menu's machinery would
have caught it**: not the evidence line, not the self-check pass, not the subject
grep. Only trying it did.

**Nothing in the open set failed re-verification.** All four survive. The one
claim that did not survive was `BOOK-INGEST-AUDIT`'s **header**, which said `F3`
was open — and that is `A3`, filed rather than retrofitted, because a header is
not a finding.

---

## The plan — sequencing, not a schedule

**If only one thing is taken, take `A11`.** It costs one grep per proposal, it
addresses the failure `G18` states outright it cannot reach, and it has already
paid for itself once inside this document.

**Cheap and independent — any order, none blocks another:**

| finding | cost | why now |
|---|---|---|
| `A3` | one paragraph | the only header a reader is actively misled by today |
| `A11` | one paragraph | the highest value per line in this file |
| `A5` | file one finding + one cross-reference | an open defect nothing in the corpus reports |
| `A4` | one sentence | a good decision currently reachable only through `git log` |
| `A12` | copy two files, three rows | closes a gap `F3` and `F19` have each closed once |

**Mutually exclusive — one of these, not both:**

- **`A1` and an `AUDITS.md` index.** `A1` recommends declining. If Nate takes the
  index anyway, `A1` is moot and should be closed as such rather than implemented
  against; **do not take both**, and if the index is built, `A2` becomes more
  urgent rather than less, because the skill's table would then be the *second*
  wrong list rather than the only one.

  **RESOLVED 2026-09-03: `A1` was declined and no index was built** (PR #652).
  The paragraph above stands as what the choice looked like beforehand.

**Ordering that matters:**

- **`A7` ships inside `A2`.** Both edit the same paragraph. Taking them
  separately means two PRs touching one caption.
- **`A8` before `A9`.** `A8` corrects the record about where the evidence
  convention came from; `A9` moves the template there. Taking `A9` first makes
  `A8`'s correction land in a section `A9` has already rewritten.
- **`A10` after `A9`, if both.** The self-check pass is the last field of the
  same template. It stands alone if `A9` is declined.

**Wasted if another is taken:**

- **`A6`'s memory corrections are wasted work if `A1`'s index is built** — the
  index would carry the same status field, and there would then be two stale
  copies to correct instead of one. Take `A6` only if `A1` is taken as written.
- **`A2` is partly wasted if the shape table is simply re-corrected** by hand a
  fifth time. That is the option `A2` exists to argue against.

**One recommendation, deliberately unnumbered:** `REPO-AUDIT` `G5` half (b)
should be **closed by decision**, not left standing. Half (a) shipped and removed
its only argument; leaving it open means the next reader of that menu's *"nothing
is open"* header meets a live proposal three hundred lines down. This is
deliberately not numbered as a proposal against another menu's finding — it is
Nate's call on `G5`, and the note belongs under `G5`.

**DONE 2026-09-03 (PR #655): closed by decision, and the note went under `G5`
where this paragraph said it belonged.** Squash and rebase stay enabled.

---

## What could not be verified from this session

Stated plainly, per the brief.

- **The error-rate comparison in Part 2 is not controlled.** `REPO-AUDIT` at 5/18
  against `HEALTH-AUDIT` at 3/24 compares different subject matter with small n.
  It is offered as a reason to move a rule, never as proof the rule caused the
  difference. **Do not quote those figures as a rate.**
- **The "3 of 5 wrong claims caught before hand-over" figure in `A10` is derived
  from outcome notes**, which are the account written by the person who made the
  error. Nothing independent confirms when each was caught. It is the best
  evidence available and it is a self-report.
- **Whether the header layer's accuracy is representative.** Two open-claims
  across eighteen headers today, one wrong. n=2. A different day gives a
  different answer and this one should not be generalised.
- **`SKILL-AUDIT` `F12`'s question was not settled** — which allowlist governs a
  session started in the working directory. Settling it means running one
  allowlisted-here / absent-there command from each directory and watching which
  prompts. **It would have changed nothing in this audit** and is left to that
  finding.
- **No menu was read end to end.** Eighteen files, 23,461 lines. The method was:
  every status header in full; every finding block in `REPO-AUDIT`,
  `HEALTH-AUDIT`, `MACHINE-AUDIT`, `SKILL-AUDIT` and `DOCS-AUDIT-2` extracted to
  its outcome note and read; the four open items and eleven cited findings read
  in full; the rest sampled by their outcome regions. **A claim in this file about
  a menu not named in that list is weaker than the ones about the menus that
  are.**
- **The nine older menus' outcome notes were sampled, not read exhaustively.** If
  the true premise-error rate matters more than falsifying "every finding", that
  is a further pass and it is a large one.
- **`UI-AUDIT` `F30` was verified locally, not on production.** Production
  character `1212` — the one `F30` measured — was not re-read, because reading it
  is safe but the picker controls that would demonstrate the defect are the ones
  `verify-ui` says write. The local reproduction used the same grant shape and
  produced the same behaviour on both client and server.

---

## How to take one

Per the `audit-menu` skill: Nate names one — *"take META-AUDIT A11"*, naming the
menu, per `G12` — it becomes one PR on its own branch, the outcome note is
appended **under that finding's heading in the same PR**, and the merge waits for
a separate word.

**Taking a finding means auditing it first**, and this menu has a specific reason
to insist: **every measurement above is a 2026-09-03 reading of a file, and most
of the files are ones a finding here proposes editing.** Re-run the command in
the finding. And re-read the trap in this file's own header before implementing
the second finding taken from it — the first one will have moved the skill this
one quotes.

---

## Opened by the protocol retrospective, 2026-09-04

Three findings, `A13`–`A15`, from the brief at
`docs/prompts/protocol-retrospective-prompt.md`. They sit here rather than in a
twentieth menu because `audit-menu` → *When not to* says a single finding about
the apparatus belongs on whichever existing menu owns that surface, and this one
owns the protocol. Nate asked for the pass by name on 2026-09-04, which is the
condition that section states.

**The question this pass asked is not the question the rest of this menu asked.**
Everything above — and the eight menus whose subject is the way of working —
asks *is this sentence still true.* This pass asked *was this the right shape,
and is it still worth what it costs.* A convention can be accurate everywhere and
still be the wrong shape, and nothing here had asked that.

**One question closed with the convention vindicated.** `A14` is not a compliance
failure; the citation rule is being followed, with two known bare citations in
the whole instruction layer. Recorded so the opposite is not inferred from a
finding existing.

**Adjusted 2026-09-04**, when `A14` was taken: this sentence carried the
fraction *28 of 36* and both figures were wrong. The count does not reproduce,
`A14`'s own outcome note re-derives it with a command, and the fraction is gone
from here rather than corrected, because the claim that matters is *the rule
holds* and a ratio in a preamble is the moving number this pass is about.

- **A13** — medium — nothing bounds what a status header may carry, and the menu that audited the headers now has a stale one — Taken, 2026-09-04 (PR #703). Posture held: documentation only, one section in — full text in `META-AUDIT.closed.md` under its own `### A13` heading.

- **A14** — low — the prefix census says eleven menus use `F`; twelve do, and the count is the part that rots — Taken, 2026-09-04 (PR #701). Posture held: documentation only, subtractive, — full text in `META-AUDIT.closed.md` under its own `### A14` heading.

- **A15** — low — nothing says where a closed menu goes, and seventeen of nineteen are closed — Taken, 2026-09-04 (PR #702), on Nate's instruction to take all three. Posture — full text in `META-AUDIT.closed.md` under its own `### A15` heading.

### The hand-over pass on these three, per `A10`

Every command quoted in `A13`–`A15` was re-run on 2026-09-04 before this file
was handed over. **Reporting what held as well as what moved**, because a pass
that lists only its catches says nothing about coverage.

| claim | re-run result |
|---|---|
| twelve menus use the `F` prefix | **held** |
| `SHIP-PR-AUDIT` carried ten `### F<n>` at creation (`9e9a219`) | **held** |
| the census landed at `07cf1ec`, 2026-09-03 13:50 | **held** |
| `audit-menu` has eleven `## ` sections, none about a closed menu | **held** |
| `pick3cut5` `F11`/`F12` taken in #653/#654 | **held** |
| 28 of 36 ambiguous-prefix citations name their menu | **held** |
| header line counts | **MOVED — off by one throughout**, `echo "$h" \| wc -l` against `wc -l < file`. Table corrected to the file-based method and the command is now printed above it |
| `META-AUDIT`'s own header row | **MOVED — 39/13 to 50/16, by this PR** |
| corpus at 27,952 lines | **MOVED — 28,454 after this PR** |
| the two `grep -rl` lookups | **MOVED — 28/10 and 8/6 became 29/11 and 9/7**, because `A15`'s own text contains both search terms |

**Four of the ten moved, and three moved because of this PR.** That is not a
defect in the measurements; it is `A13` and `A15` happening to their own
evidence inside the commit that files them. Every figure is now pinned to
`2eed604` and the post-PR value is stated beside it.

**What this pass cannot see**, stated so its silence is not read as coverage:
`A13`'s remedy — whether a *bound* is the right instrument, or whether a live
menu's header should simply be allowed to grow — rests on no command and nothing
re-runs it. That is the asymmetry `G18` names, and it is why `A13`'s confidence
is medium on the remedy while high on the measurements.

**The row reading `28 of 36 … held` is WRONG, and the row stays as it is.**
Established 2026-09-04 by the premise audit run before `A14` was taken: the
total is 39, the breakdown behind it was wrong, and no command for it was ever
committed. It is left standing because this table is a record of what the pass
reported, and **the interesting part is why the pass reported it.**

**A10's hand-over pass re-runs the commands a menu quotes. This figure quoted
no command** — its evidence line said *"by script"* and named no script, and
none was committed. So "re-running" it meant running the same ad-hoc pipeline
from the same head that wrote it, which reproduced the original error exactly
and returned **held**. A pass that re-runs the author's own unstated method is
not an independent check of it. That is a real hole in `A10` and it is not the
hole `A10` already names: `G18`'s asymmetry is about a claim with *nothing* to
re-run, and this one looked like it had something.

**What caught it was the premise auditor**, which had no access to the method
and derived its own — the difference `audit-menu` describes when it says the
check exists because the same session that verifies a premise has already
decided it wants it to hold.

**Two more rows in this table are wrong, found the same way when `A15` was
taken, and they also stay.** *"corpus at 27,952 lines — MOVED — 28,454 after
this PR"* compares two different file sets: the before figure excludes
`SETUP-v2-CHANGES.md` and the after figure includes it, so the stated growth is
inflated by 226 lines. And *"the two `grep -rl` lookups"* undercounts menus by
one for the same reason. **Both errors are the same error** — the glob does not
see `SETUP-v2-CHANGES.md`, which is the trap this repo has documented since
`REPO-AUDIT` `G11` miscounted the root with it. The hand-over pass re-ran the
globs and reproduced the omission, because re-running a command cannot see what
the command was always blind to. `A15`'s note has the corrected figures.

---

## Opened by the audit retrospective, 2026-09-06

Three findings, `A16`–`A18`, from the brief at
`docs/prompts/audit-retrospective-prompt.md`. They sit here rather than in a
twenty-second menu for the reason `A13`–`A15` did: `audit-menu` → *When not to*
says a single finding about the apparatus belongs on whichever existing menu
owns that surface. Nate asked for the pass by name on 2026-09-06 and named its
three questions — do the menus conflict or block each other; do the closures with
no pull request behind them hold up; and what is actually open.

**Read against `main` @ `c54a794`** (the merge of #750), all 21 menus read under
the headings rather than grepped. **31,736 lines**, up from 27,952 at the
protocol retrospective two days earlier and up 56 lines during the writing of
the brief itself.

**The first question closed with the frame corrected rather than confirmed.**
Nate's worry was *conflicting menus*. Across 634 cross-menu citations this pass
found **no two menus asserting opposite facts**. What it found instead is the
opposite shape: menus that hand work to each other correctly and visibly —
`ISBN-AUDIT` `F7` and `BULK-AUDIT` `B6` declare their dependency by number in
both directions and were taken in that order; `DOCS-AUDIT-2` routed two findings
to `MACHINE-AUDIT` as `M19`/`M20` rather than duplicating them, citing the rule
by name; `EFFICIENCY-AUDIT` `F1` and `F7` and `cc/AUDIT` `F3` each carry a
supersession by another menu under the finding. **The cross-menu machinery
works.** `A16` is about the one place it has nothing to work with.

**The second question closed with the method already in the tree.** The
non-taken closures — `moot`, `declined`, `withdrawn`, `blocked`, `closed not
taken` — were re-read, and the pattern is that the corpus already re-audits
them. `CLASS-AUDIT`'s *"Checked and still true"* capability list, the
highest-risk surface in the corpus, was re-swept on 2026-09-04 by `RETRO-AUDIT`
`R11`/`R13`: **one of eight entries partly stale, seven re-checked and holding,
one annotated, and two that were never verifiable "against the current code" as
the list's own lead-in claimed.** `CLASS-AUDIT`'s *"Blocked: need book"* item
was closed out on 2026-08-26 with **both of its book claims wrong** — the book
it said was not on this machine already was. `A17` is not about a missing
method; it is about a remedy that exists and is defeated by something else this
repo has measured.

**A result of "the board reads better than the worry suggests" is most of what
this pass found, and it is stated plainly rather than padded with marginal
findings.** Three findings follow, and two of them name work that is genuinely
lost rather than merely untidy.

- **A16** — medium — a finding may hand work to "a separate finding" without filing one, and three such deferrals are still standing — Taken, 2026-09-06. Posture held: documentation only, one new section in — full text in `META-AUDIT.closed.md` under its own `### A16` heading.

- **A17** — medium — the sweep that catches a stale cross-finding claim is defeated by the prefix ambiguity this repo has already measured, and three claims are stale behind it — Adjusted 2026-09-06, and RE-SCOPED before being taken. The central inference — full text in `META-AUDIT.closed.md` under its own `### A17` heading.

### A18 — low — the open set, measured once, and the one bit a durable header still gets wrong

Nate's third question was what is actually open, because answering it today means
reading 31,736 lines. **This finding answers it once, as a dated measurement, and
deliberately does not create anything that must be kept right.** An index has
been declined three times (`REPO-AUDIT` `G9`, `META-AUDIT` `A1`, and the skill
carries the decline) and `A13` forbids a per-finding roll-call in a header. This
is a record of a reading, in the same sense as every other measurement in this
corpus, and it **begins going stale the moment it is written** — `RETRO-AUDIT`'s
own header says its equivalent list *"was true when written and false within the
day, twice over."*

**Measured 2026-09-06 at `c54a794`, reading under every heading in all 21
menus:**

**One numbered finding is open in the entire corpus** — `SKILL-AUDIT` `F44`,
filed 2026-09-04, the three ways a worker cannot learn a book's page offset. Its
own last line reads *"Nothing else is taken until Nate names it."*

Everything else numbered is closed. That includes the two menus a reader cannot
learn this from: `HEALTH-AUDIT`, which carries no status header by decision
(`A4`), has all 24 findings closed; and `RETRO-AUDIT`, whose header refuses to
name findings, has all 21 closed.

**`RETRO-AUDIT`'s header is wrong, and it is wrong in the direction nobody
watches for.** It opens *"Work is open on this menu, and this line will not say
which findings."* Every one of `R1`–`R21` carries a Taken note; there is no
*stays open*, *still open* or *not taken* anywhere in the file outside the
`FILED, NOT TAKEN.` marker each finding gets when filed, and every one of those
is followed by its Taken note. The last open work was `R21`, closed by **#750 at
05:47 today** — whose own title is *"the last thing the finding left standing."*
The header has been wrong for a few hours.

**That is worth a paragraph because the header is written in the shape `A13`
recommends.** It refuses to name findings, it instructs the reader to read under
the heading, and it still went stale — because the one thing it does assert,
*whether anything is open*, is itself a claim with a lifetime. `A13` reduced what
a header may carry to the smallest set that survives; this is the measurement
that the smallest set is not zero. **No proposal follows from that**, and
deliberately: the alternative is a header that says nothing at all, which is
`HEALTH-AUDIT`'s shape and was already argued for and against in `A4`. It is
recorded so the next person to find a stale header knows the reduced form rots
too, and does not re-derive `A13` from it.

**Not open, and not nothing — three categories a bare open/closed reading loses:**

- **Work deferred to a finding that was never filed.** Three items, `A16`.
- **Residues under taken findings**, each recorded under its own heading and
  none of them open: `BOOK-INGEST` `F3` (vessels, with a named reopen trigger)
  and `F11`; `RETRO-AUDIT` `R20` (four of twelve spell names left alone by
  decision) and `R21` (`NOT NULL` shipped, `CHECK (slug <> '')` named as a
  further decision and a fourth table rebuild); `REDESIGN-AUDIT` `R6` (two of
  four lines); `BULK-AUDIT` `B6` (**TMDB never verified against the real API** —
  every video path proven against a stub, because the local key is the burned
  one); `pick3cut5/AUDIT` `F4` (dissolves with `F6`) and `F6` (on hold, trigger
  named: *"the day a second app wants a Durable Object"*).
- **Verification gaps inside items recorded as passed.** `pick3cut5/AUDIT`'s
  `T7` (the 30-round cap still untested), `T9` (the room code read across an
  actual room), and `T10` — whose reason is a **method** claim: *"the browser
  pane does not deliver those keys to the page"*, so Tab traversal and
  Enter/Space were never driven and no screen reader was run. `audit-menu`'s
  lesson from `SKILL-AUDIT` `F12` is that a finding blocked by a wrong premise
  about the method looks identical to one blocked by its subject, and this repo
  has since established that CDP can be driven here without a dependency. **Not
  a finding, and not re-tested by this read-only pass** — recorded because it is
  the one closure in the corpus whose stated obstacle is a tool limit rather
  than a fact about the app.

**Proposal: none. This is an information item.** Nothing is asked for and nothing
should be built from it. **No action proposed.**

**Evidence.** All 21 menus read under their headings 2026-09-06 at `c54a794`; the
`RETRO-AUDIT` result cross-checked by `grep -nE "stays open|remain(s)? open|still
open|not taken"` over that file, which returns nothing outside the filing
markers, and by `gh pr view 750`. The corpus figures — 21 menus, 31,736 lines —
reproduced with the file list in the brief, which is hand-built and should be
re-derived rather than trusted.

**Confidence: high** on `F44` being the only open numbered finding, from reading
rather than grepping. **Medium on completeness**, and the reason is worth
stating: this pass's own extractor missed outcome notes worded `WRITTEN` and
`DECLINED`, and reported `SKILL-AUDIT` `N2`/`N3` and five others as having no
outcome until they were read by hand. **The notes vary in wording by design and a
mechanical reader got it wrong again**, exactly as the skill says it will. Every
flag it raised was resolved by reading; what cannot be ruled out is a note it did
not flag and nobody read.

**One error this pass made and corrected, recorded because it is this menu's own
subject.** Reading `RETRO-AUDIT` `R11`, a `grep` piped through `head -8` returned
*"`ley-line-rifter` taken (PR #725). The other six rows stay open"* and the
conclusion drawn was that six rows were open. **`R11` is closed** — PR #726 took
the remaining six and appended *"The remaining six rows taken… R11 is closed"*
further down the same region, past the cut. `DOCS-AUDIT-2` records the identical
failure in its own process note: *a truncated grep looks exactly like a complete
one.* It was caught by checking the PR rather than by re-reading, which is the
only reason it is here as a correction and not as a finding.

**Ongoing cost:** none. Nothing here is maintained.

## Opened by the A13 revisit, 2026-09-21

Nate asked for `A13` to be revisited after two menu headers were corrected on
2026-09-21 (PR #1206). **Half of what prompted it turned out not to be evidence
about `A13`**, which is recorded here rather than quietly dropped, because the
finding below rests on what is left.

### A19 — low — `A13` ruled a check out for a reason the narrow one does not meet, and one post-`A13` header has since rotted

`A13` shipped *What a status header may carry, and what it may not* on
2026-09-04 (`61c29fb`) and closed with *"No retrofit, no check, and no count in
this rule"*, ruling a check out because *"the notes vary in wording by design and
a mechanical reader keeps getting this wrong."*
<!-- claim-ok: quoting A13's own closing paragraph, re-read in the skill 2026-09-21 -->

**That reason is about reading an outcome note in order to decide a state.** The
check proposed here reads no outcome note and decides no state. It asks one
question of a line a pull request **adds** to a menu's leading blockquote: does
it name a finding-number token. Whether the claim around that token is true stays
a judgement, exactly as `A13` says it must.

**What prompted the revisit, dated, because one of the two does not count.**
Both corrected headers were dated with `git log -S` on 2026-09-21:

| header | written | against `A13` |
|---|---|---|
| `BULK-AUDIT`'s *"Every finding here is now closed"* | 2026-08-26, `109c9ca` | **nine days before** `A13` |
| `UI-AUDIT`'s *"Three remarks were left open inside closed findings"* | 2026-09-10, `95fc9be` | six days **after** `A13` |

`A13` does not retrofit, and says so, so a pre-`A13` header being found wrong is
the rule working rather than failing. **The evidence is therefore one instance,
not two** — and the one that counts is the shape `A13` predicts: `UI-AUDIT`'s
clause gave three findings their state in a header, `F17`'s remainder was
numbered `F56` on 2026-09-12, and the clause stayed wrong for nine days until a
person read it.

**Measured 2026-09-21, with a throwaway probe over `git show --unified=0` across
`HEAD~250..HEAD` (573 commits); the two dating commands above are the
reproducible half.**

- **A retrofit is out.** `A13`’s own closing paragraph rules it out at
  `.claude/skills/audit-menu/SKILL.md:560`, read 2026-09-21 — *"Existing
  headers are records and stay as they are."* Across every menu the tree
  glob returns plus `SETUP-v2-CHANGES.md`, the leading blockquotes hold 589
  lines, and 18 files' headers name a finding number — 227 tokens. This menu's
  own header is one of them and already says so.
- **Added lines are a different corpus.** Of those 573 commits, **33** add any
  blockquote line to a menu and **6** would be flagged. Two of the six are the
  same `SKILL-AUDIT` `F44` header line being written and then rewritten —
  per-finding state in a header, the shape `A13` forbids. The other four are a
  dated `**Adjusted**` statement, which `A13` permits outright, and blockquotes
  sitting inside finding bodies rather than headers, which a header-scoped
  extractor would not look at. **The probe used "any blockquote line" as its
  proxy and therefore overstates the false-positive rate.**

**Proposal:** add one rule to `scripts/menu-check.mjs` rather than a new script.
That file already diffs the lines a branch adds against `origin/main`, already
scopes itself to menus with `MENU_GLOBS`, and already carries
`<!-- claim-ok: why -->` as its escape hatch — all three read at
`scripts/menu-check.mjs` lines 95, 98 and 146 on 2026-09-21. The rule: a line
added inside a menu's leading blockquote that names a finding-number token is
flagged, with `A13`'s permitted list quoted back — a dated historical statement,
an instruction to a taker, or arrangement — and `claim-ok` silences it.

**Posture: the same gate `menu-check` already is, escapable.** Stated plainly
because it is the half most likely to be misread: `menus` is a required check,
so this **blocks a merge** until the line is changed or marked. The alternative
posture is report-only, which costs nothing and fires into a log nobody reads —
the trade `A13`'s own *"rules that are read do not fire; a job that runs does"*
argument already weighed for a different rule.

**Evidence:** the two `git log -S` commands above, run 2026-09-21; the corpus
and added-line counts from the probe described above, same day. The probe is not
committed. **Nothing here was inferred.**

**Confidence: medium.** What would raise it: a **second** post-`A13` instance,
or building the header-scoped extractor and re-running it over the same 573
commits to replace the proxy's false-positive rate with a real one. Neither was
done here, deliberately — building the extractor is most of taking the finding.

**Ongoing cost:** one more rule inside a check that already runs, and the
`claim-ok` habit extended from claims-about-files to headers. On the proxy
measurement that is roughly one spurious flag per 190 commits, and fewer once
the extractor is header-scoped.

**And the case for declining, which is real.** One instance in seventeen days is
thin, and `A13` was a considered decision rather than an oversight. The check
also cannot reach the worse half of the problem: `A17` records that
`SHIP-PR-AUDIT`'s *"None of these is taken"* carries **no finding number at
all**, so a numberless claim about numbered work stays invisible to this rule
exactly as it is invisible to every other sweep here. A check that covers the
detectable half may make the undetectable half easier to forget. **If that is
the reading, decline it and record the measurement above** — the corpus counts
are worth keeping either way.

**DECLINED 2026-09-21, on Nate's word, the day it was filed. The measurement
stays; the check does not.**

**The distinction this finding rested on does not survive the corpus.** It
argued that `A13` ruled out a mechanical reader of STATE, and that asking
whether a header line names a finding number needs no such reader. Both halves
are true and the conclusion still fails, because the two classes are not
separable by the presence of a number:

- `SKILL-AUDIT.md:9`, read 2026-09-21, carries *"`F44` was taken 2026-09-11
  (PR #957)"*. It is dated, and a taken finding stays taken, so it cannot rot.
  `A13` permits it outright as *"a dated historical statement, marked as one."*
- `UI-AUDIT`'s carried *"Three remarks were left open … and none was ever given
  a number"* — undated, present tense, and it rotted.
<!-- claim-ok: quoting the two header lines this note contrasts, both read 2026-09-21 -->

Both name finding numbers. What separates them is **tense and dating**, which is
wording analysis — the thing `A13` ruled out, and ruled out correctly. A
detector that flags the first in order to catch the second taxes exactly the
writing `A13` tells a header to carry more of.

**And the escape hatch was measured, on the case that prompted this finding.**
PR #1206 (commit `1100731`, 2026-09-21) added the replacement clause to
`UI-AUDIT`'s header. `menu-check`'s existing claims-about-another-file rule
fired on it, and the line was silenced in the same commit with
`<!-- claim-ok: quoting the two notes this line summarises… -->`. **The claim
was still false** — `F54` and `F55` had numbered those two remarks on
2026-09-12. A second rule sharing that same hatch would have been silenced by
the same marker in the same commit: a flag, not a defence.

**What the evidence points at instead.** `audit-menu` already requires that when
a finding is taken, the whole tree is grepped for its number
(`.claude/skills/audit-menu/SKILL.md:382`, read 2026-09-21). `UI-AUDIT`'s clause
went stale because `F54`, `F55` and `F56` numbered three remarks on 2026-09-12
and nothing came back to the header saying they had none. **That rule was in
force and did not fire.** Making it fire is a different proposal from this one,
and it is deliberately not made here — filing it in this note would repeat the
thing this finding got wrong once already.

**Kept:** the corpus and added-line counts under *Measured*. They are a dated
record, they cost nothing standing, and re-deriving them would cost the same
afternoon twice.

## Opened by the subagent retrospective, 2026-09-22

Filed while closing out the retrospective recorded on `SKILL-AUDIT.md` under
its own `##` heading of that date. Every claim below was re-derived by hand
before filing: two of them were first surfaced by an agent, and a third
agent's count in the same batch turned out to be a count of mentions rather
than of events, which is the reason for the rule rather than an aside.
### A20 — medium — the closed-file split left three kinds of damage, and one finding's record is gone

**Opened 2026-09-22**, from the first run of the `open-findings-scout` agent and
verified by hand afterwards. One cause — the 2026-09-16 move of closed findings
into `<MENU>.closed.md` — and three symptoms that a reader meets as three
unrelated confusions.

**One: a record is gone, not merely hard to find.** `INGESTION-AUDIT` `F32` was
filed in `117c0d61` as `### F32 — low — Sleeping Bag exists twice under rifts…`.
Its heading was **deleted by `e74505f6`**, whose subject is *Take
INGESTION-AUDIT F31* — so the heading went before `F32` itself was taken, in
`0744c8a3`, *Take INGESTION-AUDIT F32: one Sleeping Bag row, class-import stub
retired*. **The outcome note had nowhere to be written.** Today
`grep -n '^### F32\|^- \*\*F32\*\*'` over `INGESTION-AUDIT.md` and
`INGESTION-AUDIT.closed.md` returns nothing; the only surviving traces are two
bare citations at `INGESTION-AUDIT.md:943` and `:953` and the commit subjects.

**Two: eighteen findings moved without the pointer the header promises.**
`BOOK-INGEST-AUDIT.md`'s header says the live file *"keeps a one-line pointer
per moved finding where its heading was."* Sampled 2026-09-22: `F24`, `F30`,
`F36`, `F97` and `F101` each have a full heading in
`BOOK-INGEST-AUDIT.closed.md` and **no pointer of any kind** in the live file.
`F30`–`F36` are discussed by number in the live file at `:216-309`, where the
numbers now resolve to nothing.

**Three: `RETRO-AUDIT.md` is forty-one `###` headings and not one of them is a
finding.** Counted 2026-09-22: `grep -c '^### '` returns **41**;
`grep -c '^### R[0-9]'` returns **0**. All 21 `R` findings are one-line pointers,
and the `###` sub-sections of their outcome notes — *The scope was wrong by two,
and the finding's own query is why*, and forty like it — stayed behind when
their parents moved. A heading scan of that file returns forty-one results and
zero findings, which is the **inverse** of the trap `audit-menu` warns about for
`CLASS-AUDIT` and `pick3cut5/AUDIT`.

**Proposal:** three repairs, each small and each independently declinable.
Reconstruct `F32` as a heading plus a dated note in `INGESTION-AUDIT.closed.md`
from the two commits, marked as a reconstruction rather than a record. Add the
missing pointer lines to `BOOK-INGEST-AUDIT.md`, which is mechanical — the
closed file has every heading. And for `RETRO-AUDIT`, **one sentence in that
menu's own header saying its `###` headings are not findings** — Nate's word,
2026-09-22.

**The alternative is declined and recorded so it is not re-proposed:** demoting
the forty-one orphaned sub-headings to bold leads is a large diff inside a
record, and what a reader needs is the same kind of fact `audit-menu`’s shape
table already carries at `.claude/skills/audit-menu/SKILL.md:596` and `:606`,
read 2026-09-22 — `CLASS-AUDIT`'s `S` items as BULLETS, `pick3cut5/AUDIT`'s
`T` items as BOLD PARAGRAPH LEADS. **That is shape, not status** — the half of a header that has stayed true
everywhere it was written, while the status narrations rotted.

**Posture: records, not rewrites** — no finding text is altered, nothing moves
back, and the `F32` reconstruction is labelled as one.

**Evidence:** the greps and `git log` reads above, all 2026-09-22; `F32`'s two
commits read with `git show`. The three were surfaced by the scout's first run
and every one was re-derived by hand before filing, after a different agent's
count of hook refusals turned out to be a count of mentions.

**Confidence:** high on all three — each is a count or a grep that reproduces.
What would raise the second part from a sample to a total is listing every
heading in `BOOK-INGEST-AUDIT.closed.md` and diffing it against the pointers in
the live file, which is a one-line script and was not run.

**Ongoing cost:** none for parts one and two once done. **Part three costs one
header sentence to keep true**, which is the trade being accepted: a sentence
about shape rather than about state, on the argument that shape does not move
when a finding closes. If `RETRO-AUDIT` ever regains a real `###` finding, that
sentence becomes the thing to correct.

**Taken, 2026-09-22 (PR #1251), all three parts. Posture held: records, not
rewrites — no finding text was altered and nothing moved back.** The third
clause of that posture no longer applies, and that is the headline: it says
<!-- claim-ok: quoting the premise this note corrects --> *"the `F32`
reconstruction is labelled as one"*, and **there was no reconstruction to
label.** Nate chose the repair over the labelled duplicate.

**Parts one and two were both wrong about the KIND of damage, and both in the
same direction — the work had been done and misplaced, not left undone.** That
is worth more than either correction, because it is what the repairs turned out
to have in common.

- **Part one. The record was never lost.** <!-- claim-ok: quoting the premise
  this note corrects --> *"a record is gone, not merely hard to find"* and
  *"the outcome note had nowhere to be written"* are both false. `F32`'s entire
  finding — body, table, `Proposal`, `Posture`, `Evidence`, `Confidence`,
  `Ongoing cost` and its full dated outcome note — was in
  `apps/character-creator/INGESTION-AUDIT.closed.md` the whole time, stranded
  under `F31`'s heading. `e74505f6` was a bad in-place edit: it deleted the
  heading line and welded the heading's tail onto `F31`'s closing sentence, so
  one line read `Smoke 1698 → **1701.** under \`rifts\`, and one of the rows
  says so in its own description`. Read with `git show e74505f6`, 2026-09-22.
  **Implemented as written this would have appended a second copy of text
  already present a few lines above**, and called a record a reconstruction.
  Repaired instead by restoring the heading verbatim from `117c0d61` and
  closing `F31`'s note — and by adding the live-file pointer the restored
  heading then needs.
- **Part one, also false:** <!-- claim-ok: quoting the premise this note
  corrects --> *"the only surviving traces are two bare citations."* `F32` is
  discussed by number at `INGESTION-AUDIT.closed.md:2817`, `:2926`, `:3049` and
  `:3070` as well.
- **Part two. The eighteen pointer lines had been written into the wrong
  file.** <!-- claim-ok: quoting the premise this note corrects --> The proposal
  calls the repair *"mechanical — the closed file has every heading."* The
  closed file had more than the headings: the eighteen finished pointer lines,
  in pointer shape, sat at its end. **Moved rather than composed**, because
  composing from headings would discard the outcome-note excerpt each pointer
  carries, which is the half that makes a pointer block worth reading.
  Positions taken from `1decb9d2~1`, the pre-split file, rather than guessed.

**The unrun total is now run, and this finding's headline was exactly right.**
Its `Confidence` line says raising part two from a sample to a total *"is a
one-line script and was not run"*. Run 2026-09-22 across every menu with a
closed file: **`BOOK-INGEST-AUDIT` is the only affected menu and the count is
exactly eighteen** — `F24`–`F36` and `F97`–`F101`. All seventeen other menus:
zero missing. The five sampled findings were representative of the whole.

**Part three held, with one correction.** `grep -c '^### '` on
`apps/character-creator/RETRO-AUDIT.md` returns 41 and `grep -c '^### R[0-9]'`
returns 0, both re-run 2026-09-22. But <!-- claim-ok: quoting the premise this
note corrects --> *"forty like it"* overstates by two: `RETRO-AUDIT.md:146` and
`:161` sit under `## Method, and what each detector was worth` and were never
children of a finding. Thirty-nine are orphans. The header sentence is
unaffected — if anything it is more right, since two of the headings it warns
about never had a parent to lose.

**Corrected outside this repo, in the same sweep.** The memory note
`audit-menus.md` said every menu but two has a closed file; **five do not** —
`DOCS-AUDIT`, `DOCS-AUDIT-2`, `apps/pick3cut5/AUDIT`,
`apps/character-creator/AUDIT` and `SETUP-v2-CHANGES`. The same paragraph
asserted the pointer-per-finding property that part two exists because
`BOOK-INGEST-AUDIT` did not have. Both corrected.

**What this does not close.** `apps/character-creator/AUDIT.md` was never split
and records its outcomes as `**Fix**:` bullets under a *Fixed in this PR*
section — a fourth outcome shape, and outside every part of this finding.
Recorded rather than filed. **Filed as `A21`, 2026-09-22.**

### A21 — low — five menus were never split, and one of them records outcomes in a shape no other menu uses

**Opened 2026-09-22**, from `A20`'s premise audit, which listed the menus with
no `<MENU>.closed.md` while checking something else.

**Five menus have no closed file** — `DOCS-AUDIT.md`, `DOCS-AUDIT-2.md`,
`apps/pick3cut5/AUDIT.md`, `apps/character-creator/AUDIT.md` and
`SETUP-v2-CHANGES.md`. Derived 2026-09-22 by walking the `*AUDIT*.md` glob plus
`SETUP-v2-CHANGES.md` and testing for `${base}.closed.md`. **Four of the five are
unremarkable**: they are small, or closed, or — in `pick3cut5/AUDIT`'s case —
still carrying open work.

**The fifth is the finding.** `apps/character-creator/AUDIT.md` records its
fourteen outcomes as `**Fix**:` bullets under a *Fixed in this PR* section rather
than as notes under each finding, which is **a fourth outcome shape** beside the
three `audit-menu` already warns about. Its own header says two scans have
already misread it as open. Read 2026-09-22.

**Proposal:** one sentence in that menu's own header naming its outcome shape —
where the outcomes live and that they are not under the findings — and a row for
it in `audit-menu`'s shape table if the table does not already describe it
correctly. **Posture: documentation only. No split, no move, no restructure, and
no check.** The same posture `A20` part three shipped for `RETRO-AUDIT` on
2026-09-22 (PR #1251), and for the same reason: shape does not move when a
finding closes.

**Splitting it is explicitly NOT proposed**, and the argument is `A20`'s: the
split is what produced `A20`'s three symptoms in the first place, and this menu
has been readable without one since it was written. **The five unsplit menus are
not a gap to close.**

**Evidence:** the five-menu derivation and the `AUDIT.md` read, both 2026-09-22,
both from `A20`'s premise audit. **Not measured:** whether `audit-menu`'s shape
table row for `apps/character-creator/AUDIT.md` is already right — this finding
did not open the table, which is the claim-about-another-file shape that fails
most often here, so a taker should read `.claude/skills/audit-menu/SKILL.md`
before assuming the row needs changing.

**Confidence:** high that the five are five and that the shape is a fourth one.
**Low on whether the header sentence is worth writing**, given the menu already
warns that it has been misread — which may mean the warning is the thing that
needs sharpening rather than a new sentence added beside it.

**Ongoing cost:** one header sentence to keep true, the same trade `A20` part
three accepted.

### A22 — medium — the deferral rule shipped as documentation, and five unnumbered deferrals were written on one day by sessions that had just applied it

**Opened 2026-09-22**, from the sweep that filed this batch. **This re-proposes
something `A16` decided, and says so** — per `audit-menu` → *A finding may still
re-propose a settled decision*, what a finding may not do is fail to say that a
decision exists.

**`A16` is the decision.** Taken 2026-09-06, it shipped `audit-menu` → *A
deferral is work. Give it a number or say you are dropping it*, with the posture
<!-- claim-ok: quoting A16's posture, located at META-AUDIT.closed.md:1699-1703 -->
*"documentation only, one section in one skill. No check, no script, no retrofit
of the two closed instances, and no index of deferrals."* It measured **four
standing deferrals**, the oldest ten days old. `META-AUDIT.closed.md:1644` is the
heading; the posture is at `:1699-1703`. Read 2026-09-22.

**What is new is the rate.** On 2026-09-22 alone, **five** unnumbered deferrals
were written into outcome notes, every one by a session working inside this
apparatus with the rule in its own context:

| where | the sentence |
|---|---|
| `SKILL-AUDIT.md:1336` (`F54`'s note) | *"Two things found while taking this, and neither is filed here"* — two items |
| `SKILL-AUDIT.md` `F57`'s note | *"`xargs sed -i` is a live hole in rule 2, independent of this finding"* |
| `SKILL-AUDIT.md` `F57`'s note | *"That is not closed here and should not be read as closed"* |
| `REPO-AUDIT.md:493-494` (`G20`'s note) | *"Out of scope and still true"* |

All five are filed by the PR that files this finding, so the backlog is not the
problem. **The rate is.** `A16`'s four accumulated over roughly ten days before
the rule existed; these five landed in one day after it did.

**Proposal, and it is a question rather than a mechanism.** Ask whether
documentation-only is the right posture for this rule, given the above — and
**if the answer is that it is**, record that here so it is not re-proposed a
third time. **Posture if anything is built: it may not be a check on menu text.**
`A16` ruled that out and `audit-menu` rules it out repeatedly on the grounds that
outcome notes vary in wording by design and every mechanical reader of them here
has been wrong in both directions. The only shape not yet considered is a
**prompt-time** one — the `take` skill already runs a subject grep and a premise
audit before a branch; whether it could also ask, at hand-back, "did this note
name work it did not file" is the open question.

**This finding recommends its own decline if the answer is no**, and says so
because `audit-menu` asks a proposal whose ongoing cost exceeds its impact to do
exactly that. The counter-argument is strong and should be read first: **every
one of the five was caught**, by a subject grep run at taking time, within hours
of being written. A rule that leaks and a sweep that catches the leaks may be
the working system rather than a broken one, and `A16`'s posture would then be
right for the second time.

**Evidence:** the four table rows read 2026-09-22, `A16`'s posture read the same
day, and this PR's own filings. **Not measured:** the rate before 2026-09-22.
`A16` counted a standing backlog, not a per-day rate, so *"five in one day"* has
nothing to compare against and **this finding does not claim the rate is rising**
— only that it is higher than a documentation-only rule was assumed to produce.

**Confidence:** high that the five exist — each is quoted with a location.
**Low on the conclusion**, for the counter-argument above. What would raise it is
a count of deferrals per day across the whole corpus, which nobody has run and
which this finding does not ask a taker to run before deciding.

**Ongoing cost:** nothing if declined. If a prompt-time question is added to
`take`, it is one more thing in a skill whose whole argument is that it adds no
rules — which is itself a reason to decline.
