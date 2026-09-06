# Meta-audit — the menus as a reference, and the discipline that fills them, 2026-09-03

> **There is open work on this menu.** Read each finding's own heading for its
> state and its PR number. Two later passes have added sections after the
> original one, each under its own dated `##` heading at the end of the file:
> **`## Opened by the protocol retrospective, 2026-09-04`**, then
> **`## Opened by the audit retrospective, 2026-09-06`**. The original pass was
> filed 2026-09-03 against `main` @ `3332349` (the merge of #641), the protocol
> retrospective against `2eed604` (the merge of #699), and the audit
> retrospective against `c54a794` (the merge of #750). Findings are
> `### A<n> — <severity> — <title>`, severity lowercase, and they run in each
> pass's own order rather than in severity order across the file.
>
> **`A18` is an information item that proposes nothing**, which is worth knowing
> before reading it as outstanding — it is a dated snapshot and says so.
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

### A1 — medium — an index of the menus is the artifact `G9` declined, and the one place it exists has a 0-for-4 record

Nate has asked for the index-only option. **This finding recommends declining
it**, and does so against `G9` rather than around it.

`G9`'s stated reason — *"the skill argues at length against a maintained count…
an `AUDITS.md` would be exactly the artefact it warns about"* — attacks a
**count**, and an index need carry none. On that reading the artifacts differ
and `G9` misses. **The deciding evidence is not in `G9`.**

**The index already exists and it is the `audit-menu` skill's shape table.** It
lists every menu's path, prefix, heading level and shape — everything an index
would carry except status. Its record, from its own text plus one fresh reading:

| read | result |
|---|---|
| 2026-08-31 | missing two files, wrong on three cells |
| 2026-09-02 | missing four files |
| 2026-09-02, later (`SKILL-AUDIT` `F7`, PR #548) | 13 of 14 rows right, one cell wrong — **and `F7` predicted its own falsification in the same paragraph** |
| **2026-09-03** | **15 rows against 18 menus. Missing `MACHINE-AUDIT.md`, `DOCS-AUDIT-2.md`, `REPO-AUDIT.md`.** |

A second copy of an artifact with that record is a second thing to be wrong.
And the status field specifically has a worse record than the file list: three
sources describe `MACHINE-AUDIT`'s status today and **all three disagree**, two
of them while carrying an explicit *do not trust this line* guard.

**Proposal: do not build `AUDITS.md`.** Record the decision — in this finding's
outcome note and, if `A2` is also taken, in one sentence of the skill beside the
`find` command — so it is not re-proposed a third time. State both halves: the
file list is derivable and rots; the status field is not derivable and rots
faster.

**Posture: a decision, and one sentence of documentation. No new file.**

**Evidence:** shape-table row count and the tree comparison run 2026-09-03
(`grep -o '^| \`[^\`]*\`'` on `SKILL.md` against `find`); the three earlier
readings are **reported by** `.claude/skills/audit-menu/SKILL.md` and
`SKILL-AUDIT.md` `F7`; the three-way status disagreement measured 2026-09-03
against `MEMORY.md`, `machine-audit-menu.md` and `MACHINE-AUDIT.md`.

**Decline path, and it is real.** Nate asked for this and a person who wants a
list is entitled to one. The honest counter is that he would be getting a
fifth partial index rather than a first complete one, and the four that exist
are each wrong about a different field today. If he wants it anyway, **build the
one in `A2` instead** — it is the same information with the rotting half
deleted.

**DECLINED, 2026-09-03 (PR #652), on Nate's word and on this finding's own
recommendation. No `AUDITS.md` exists and none is to be built.**

**This is the outcome the finding argued for against the person who asked for
it**, which is the whole reason it was written that way: Nate asked for the
index-only option, and a finding that tells him his stated preference was already
decided the other way — with reasons — is worth more than one that builds what
was asked for. He read the argument and made the call.

**The decline is recorded in the skill, beside the `find` command**, which is
where a reader reaches for a list and where the next person will propose one. It
states both halves, because they fail differently:

- **the file list is derivable**, so an index is a second place to be wrong
  rather than a first place to be right — and the shape table *was* that index,
  wrong on all five readings;
- **a status column is not derivable and rots faster** — three sources described
  one menu's status on 2026-09-03 and all three disagreed, two of them while
  carrying an explicit *do not trust this line* guard.

**It also records that this is the second decline, not the first.** `REPO-AUDIT`
`G9` said *"Explicitly NOT proposed: an index file listing the menus"* earlier the
same day. `A11`'s grep found it, and the skill now names both — so a third
proposal meets two dated refusals rather than none, which is the entire mechanism
`A11` exists to create.

**What replaced it is already shipped and is the honest answer to the request.**
`A2` kept the shape table's useful half and deleted its claim to completeness;
`A7` made the `find` command's two blind spots explicit; `A6` made the memory
store point rather than restate. **A reader today gets the list from the tree in
one command and the status from each menu's own header** — which is what an index
was wanted for, without a file that has to be maintained to stay true.

**Nothing was built, and nothing was removed.** The four partial indexes that
exist — the skill's shape table, `docs/prompts/README.md`, the memory store, each
menu's own header — stay exactly as they are.

---

### A2 — medium — the skill's shape table carries a file list nothing can keep right; the two commands that produce it are already on the page

`A1` establishes the table is wrong for the fourth time. This is the narrow fix,
and it is not "correct the table again" — that has been done three times and
falsified three times, most recently by the PR that did it.

**The table does two jobs.** One is a **file list**, which a command produces
exactly and which goes stale the day a menu lands. The other is **per-file shape**
— that `pick3cut5/AUDIT`'s `T` items are bold paragraph leads, that
`CLASS-AUDIT`'s `S` items are bullets, that `DOCS-AUDIT`'s `D5` carries
`WITHDRAWN` in the severity slot — **which no command produces** and which is the
whole reason the table earns its place.

**Proposal.** Keep the shape rows; stop the table claiming to be the list. The
two commands that produce the complete set are already three paragraphs below it:

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

plus `SETUP-v2-CHANGES.md`, which it cannot find. Add the second correction the
current text does not make: **the glob also returns a non-menu** —
`docs/prompts/SKILLAUDITPROMPT.md` — so it is wrong in both directions, which
strengthens the skill's own argument rather than weakening it. Then say the table
below is a **shape reference for the files it names**, not a census, and that a
menu missing from it is missing rather than absent.

**Do not add the three missing rows and stop there.** That is the fix that has
already failed three times.

**Posture: documentation only. One table's caption and one sentence. No check —**
a regex over this table would be wrong about at least one file, which is the
argument the table itself makes.

**Evidence:** row count 15 vs 18 menus, and the glob's non-menu return, both
measured 2026-09-03. The three prior readings are **reported by** the skill's own
text.

**One thing found while measuring this, worth carrying:** the instrument used to
census the not-a-heading families — a grep for `^- \*\*[A-Z]{1,2}[0-9]+` —
reported a phantom `R` prefix in `HEALTH-AUDIT.md`. The match is
`HEALTH-AUDIT.md:1514`, a bullet about the Cloudflare **R2 bucket**. Any pattern
loose enough to find the bullets and bold leads is loose enough to invent
findings, which is the same argument one level down.

**Taken, 2026-09-03 (PR #647), with `A7` folded in as `A7` itself directs.
Posture held: documentation only, no check, and no regex over the table.**

**The count moved between filing and taking, and it moved because of this
menu.** `A2` said 15 rows against 18 menus, missing three. Re-measured at
take-time: **15 rows against 19 menus, missing four** — the fourth being
`META-AUDIT.md`, which did not exist when the finding was written. The artifact
falsified itself again, in the four hours between proposing the fix and applying
it, which is the finding's entire argument arriving unprompted.

**`A11`'s grep returned `SKILL-AUDIT` `F7`, and it is a warrant rather than an
obstacle.** `F7` corrected this table on 2026-09-02, predicted its own
falsification in the same paragraph, and was right within the hour. Its outcome
note contains the move this finding extends:

> Rather than change fourteen to fifteen and leave the same trap armed, the
> sentence no longer states a number at all.

`F7` did that to the **ordinal in the prose above the table**. `A2` is the same
operation on **the row list itself**, which is that trap one level down. So this
does not reverse `F7`; it finishes it. `F7`'s other decision — *no regex, no
gate, because any pattern will be wrong about at least one file* — is untouched
and restated.

**What shipped, and one part is beyond `A2`'s letter.**

1. **The caption change, which is the fix.** The table now says outright that it
   is a shape reference for the files it names, **not** the list of menus, and
   that a file missing from it is missing rather than absent. Once it stops
   claiming completeness, being incomplete stops being a defect.
2. **The four missing rows were added anyway** — `DOCS-AUDIT-2`, `MACHINE-AUDIT`,
   `META-AUDIT`, `REPO-AUDIT`, each shape read from the file's own first heading
   rather than assumed. `A2` said *"do not add the missing rows **and stop
   there**"*, and the emphasis is on stopping: adding rows without the caption is
   the fix that failed four times. With the caption, they are useful reference
   data that cannot go stale into an error. **Declared because it is a judgement
   call**, and because the honest test of the caption is whether it makes the
   rows safe — if it does not, the caption is wrong and the rows should come out.
3. **The snapshot paragraph now names what has actually been failing.** Across
   five readings the **cells have been reliable and the roll-call has not**. That
   is the sentence the four corrections were missing, and it is why the split in
   (1) is the right one rather than an arbitrary one.

**Verified after the edit rather than assumed:** 19 rows against 19 menus, zero
missing, zero rows naming something that is not a menu. That equality is a
by-product and **not a claim the table makes** — the caption is what matters, and
the next menu will make it 19-of-20 without anything being wrong.

Diff **+51 / −17** on one skill, CRLF preserved, 0 control characters.

---

### A3 — medium — `BOOK-INGEST-AUDIT`'s status header says `F3` is open; it closed four minutes before the file's next commit

The header reads:

> **They are not all closed** — `F3` is *partly* taken, its character-completeness
> half shipped in PR #431 and its schema question still open, which `F12`'s
> outcome note independently records.

**`F3` is fully closed.** Its own note, appended in PR #616: *"The schema half is
now CLOSED, 2026-09-03 (PR #616), as the third option: keep dropping, and say so
where a reader will find it… `F3` is fully closed."*

**The timing is the finding.** `fe4cfae` closed `F3` at **08:40:47**; the file
was committed again at **08:45:40** (`1b606ec`, taking `F21`) **without the
header being touched.** Five minutes, one commit, same file, same session.

**This is the one header a reader today would be misled by**, and it is misled in
the direction that costs most: it advertises open work that is done, which is
the failure `audit-menu` records `INGESTION-AUDIT` `F12`/`F16`/`F19` producing
in the other direction.

**Two things are *not* wrong and should not be swept up.** `F12`'s outcome note
also says *"F3's schema half is still open"* — that is a **record of a
measurement taken 2026-08-31** and the skill's rule is explicit that a record is
not rewritten. And the four class notes citing `F3` still read *"`gear` has no
shape for a vessel"* — **still true**, because the closure decided to keep
dropping vessels. `scripts/audit-citations.mjs --remote F3` lists five citers and
four limitation passages, and all four survive the closure. Checked 2026-09-03.

**Proposal:** correct the header's status claim only. It should say every finding
carries its own note, that `F3` closed 2026-09-03 in PR #616 as the
keep-dropping option, and — per the skill — **not quote the phrase it replaces**.
Leave `F12`'s note, the class notes, and the rest of the header alone.

**Posture: one paragraph in one header. Nothing else in the file, no class note,
no check.**

**Evidence:** `git log --format='%h %ci %s' -- BOOK-INGEST-AUDIT.md` and the two
commit timestamps, run 2026-09-03; `F3`'s note read to the next `###`;
`scripts/audit-citations.mjs --remote F3` run 2026-09-03 (read-only).

**Taken, 2026-09-03 (PR #643). Posture held: the header only — no finding, no
class note, no check, and nothing else in the file.**

**`A11`'s rule was run on this finding and it changed the implementation.** The
grep for the subject — *how this header should read* — returned
`MACHINE-AUDIT` `M19`, whose note cites this very header as its precedent:

> The nearest thing to a check is the shape this file already uses… what
> replaces enumeration is a sentence that **cannot go stale**: a description plus
> an instruction to look. The same move `BOOK-INGEST-AUDIT.md`'s header made
> earlier the same day, for the same reason, and it is the third record in two
> days to conclude that a list in prose that nothing checks is a liability rather
> than a service.

**So a settled decision governs this header**, made hours before the finding was
filed, and `A3`'s proposal as written would have walked into it: saying *"`F3`
closed, everything is now closed"* is an enumerated present-tense verdict, which
is the shape both `M19` and this header's own last paragraph rule out. **The
header now records the dated fact and refuses the verdict**, and says why. The
rule shipped in PR #642 caught this on its first real use, which is the strongest
thing that can be said for it.

**Three findings had to be established by reading before a word was written**,
because a status claim cannot be made from a scan of this file — the header's own
second paragraph says so:

- **`F3` is fully closed** (PR #616, the keep-dropping option) and was **the only
  finding on this menu ever taken in halves** — confirmed by grepping for
  *partly taken* / *in part* / *half only* and reading each hit, not by trusting
  the count.
- **`F11` is closed, not open**, though its last paragraph records a
  `class-check` warning it decided against building and still thinks worth
  having. That is a residue like `HEALTH-AUDIT` `F20`'s *"honestly not solved"*,
  not open work, and it carries no number.
- **`F2` was reopened as `F18`**, which is taken (PR #590).

**A second stale sentence was found in the same header and fixed.** Its closing
paragraph said `F3` *"has never been fully taken"* — present-perfect, and false
since 08:41 that morning. Changed to *"had not then been fully taken"*, which
preserves the record of why the enumeration was removed while removing the false
tense. **Beyond `A3`'s letter, which said the status claim only** — flagged
rather than folded in silently, and it is the same defect in the same header, two
paragraphs down.

**One thing deliberately not done.** `F12`'s note and the four class notes citing
`F3` still say a vessel has no shape in `gear`. **They are correct** — the
closure decided to keep dropping vessels, so the limitation survived it — and
`F12`'s is a dated measurement besides. The new header says this outright, so the
next reader does not sweep them up as rot. `scripts/audit-citations.mjs --remote
F3` re-run: five citers, four limitation passages, all four still true.

**And my own census instrument was wrong about this file, in the way the corpus
already records.** The script used to extract outcome notes across the corpus
split blocks on bold leads as well as headings, and printed `F17`'s note under
`F3`'s heading. That is the same class of fault the
`audit-outcome-notes-vary-in-wording` memory records — a scan splitting on an
inline `**F10 …**` and hiding a `Taken` note. Every claim above was re-derived by
reading `### F\d+` blocks only. **The header this finding fixes was wrong for one
reason and my reading of it was nearly wrong for another.**

Diff: **+19 / −5** on one file, CRLF preserved (2,508 CRLF, 0 bare LF, 0 control
characters), and the replaced phrase is **not quoted back** anywhere, per the
skill's rule against defeating a future grep for it.

---

### A4 — low — `HEALTH-AUDIT` is the only menu with no status header, and the reason exists only in a commit message

`HEALTH-AUDIT.md` filed `F8` — *"no menu states its own status, so establishing
that there is no open work costs an audit"* — and taking it (PR #531) gave every
other menu a status line. **`HEALTH-AUDIT.md` did not get one.**

**That was deliberate**, and the reason is good. From `3a8f0ca`'s commit message:

> `HEALTH-AUDIT.md` deliberately gets no status line. It is the live menu and a
> count in its header would be the moving number F4, F5 and F10 are about.

**A decision this defensible should not live where only `git log` reaches it.**
A reader comparing eighteen menus finds seventeen with a status header and one
without, and has no way to tell a deliberate abstention from an oversight — and
the natural repair, adding one, is the thing the decision refused.

**This finding was checked against `G9`'s shape before being written.** Grepped
the tree for `HEALTH-AUDIT` + status: no menu, no skill and no memory file
records the abstention. It exists in exactly one place and that place is not a
document.

**Proposal:** one sentence at the top of `HEALTH-AUDIT.md` saying it carries no
status header **on purpose**, that status lives under each finding, and why — a
count in the header of the live menu is the moving number `F4`, `F5` and `F10`
are about. Do **not** add a status header; that is the thing being declined.

**Posture: one sentence. Explicitly not a status line, and no count.**

**Evidence:** `git show 3a8f0ca` (the F8 take), read 2026-09-03; absence of a
status header confirmed by reading `HEALTH-AUDIT.md:1–60` and by
`grep -nE '^> |Status|nothing is open'`; the absence-of-a-record claim proved by
a fresh grep across the tree and the memory store rather than by a pattern
match — per the skill's rule on absence claims.

**Taken, 2026-09-03 (PR #645). Posture held exactly: one paragraph recording the
abstention, and NO status header added** — adding one is the thing the decision
refused, and this finding would have been implemented wrong if it had.

**Half the recorded reason had expired, which the finding did not anticipate.**
PR #531's commit message gives two grounds. *"It is the live menu"* was true on
2026-09-02 and is not now — `REPO-AUDIT` and this file both came after, and
`HEALTH-AUDIT`'s findings all carry outcome notes. Repeating it as a live reason
would have shipped a stale claim inside a note about stale claims.

**So the paragraph carries the durable half and dates the expired one.** The
surviving ground is that a count in this header would be the moving number `F4`,
`F5` and `F10` are about — three findings in that same file about documents
quoting figures that cannot stay right.

**And the case is stronger now than when it was made**, which is worth more than
the original reasoning. Two things measured for this menu since: `BOOK-INGEST`'s
status header went stale **within five minutes** of `F3` closing, and three
sources describing `MACHINE-AUDIT`'s status disagree three ways while two of them
carry an explicit *do not trust this line* guard. The paragraph says so, because
a decision defended only by its original author's reasoning is weaker than one
with evidence behind it.

**`A11`'s grep confirmed the finding's absence claim** — no menu, skill or memory
file records the abstention; it existed only in `3a8f0ca`. Re-run 2026-09-03 and
still true, which is why this paragraph had somewhere to be.

**Deliberately not done:** no status line, no count, no re-verification date, and
nothing about the file's own findings. The paragraph says where status lives —
under each heading — and stops.

---

### A5 — medium — `SETUP-v2-CHANGES` records a live defect as "filed for a separate PR"; it was never filed and never fixed

The header says *"All eight taken, 2026-09-02 (PR #502)"*, which is true. Three
paragraphs down, under decisions made alongside them:

> **Open question 1 answered, not acted on.** The `fonts.googleapis.com`
> allowance in `apps/pick3cut5/test/smoke.mjs` is dead — the fonts are
> self-hosted, the list is always empty, and the check passes vacuously. A test
> finding rather than a documentation one; **filed for a separate PR.**

**Re-measured 2026-09-03. All of it still holds, and nothing was filed.**

| | |
|---|---|
| `apps/pick3cut5/test/smoke.mjs:87–89` | the check stands, unchanged |
| external refs in `apps/pick3cut5/index.html` | **0** — `external.every(...)` on an empty array is `true` |
| self-hosted fonts | `shared/fonts/` holds `saira-variable.woff2` and `ibm-plex-sans-variable.woff2` |
| a numbered finding for it, anywhere | **none** — grepped all 18 menus |

**This is the failure mode the status headers cannot cover**, and it is worth
more than the defect. The item is not a finding, so it has no heading, no number
and no outcome note; it is a sentence in a decisions paragraph under a header
that correctly says everything **numbered** is taken. **A reader doing everything
right — reading the header, then reading under the headings — never reaches it.**
It has been open since 2026-09-02 and nothing in the corpus reports it.

**Proposal, two parts, and the second is the point.**

1. File it as a numbered finding on the menu that owns the code —
   `apps/pick3cut5/AUDIT.md`, next free `F`. The fix is a sentence of judgement,
   not code: either assert the list is empty (the actual invariant, and it would
   have caught `REDESIGN-AUDIT` `N6`'s CSS-fetched font) or delete the check.
   **Do not implement it in the same PR as the filing**, per the skill.
2. Add one line to `SETUP-v2-CHANGES.md`'s decisions paragraph pointing at that
   number, so the sentence stops being the only record.

**Posture: file, do not fix. One finding, one cross-reference. The test change is
a separate decision.**

**Evidence:** `apps/pick3cut5/test/smoke.mjs` lines 87–89 read 2026-09-03; the
external-ref count measured the same day by running the file's own regex over
`index.html` (`0 external of 5 refs`); `ls shared/fonts`; and a grep for the
subject across all eighteen menus returning nothing.

**Taken, 2026-09-03 (PR #644). Posture held: file, do not fix — no test was
changed, no Access destination touched, nothing about what is public moved.**

`apps/pick3cut5/AUDIT.md` gains **`F11`**, the vacuous check, in that file's own
`### F11.` shape. `SETUP-v2-CHANGES.md`'s decisions paragraph gains the pointer,
and that menu's header now names the two open findings instead of saying
everything is closed.

**`A11`'s grep found the decision, and it authorises this rather than blocking
it.** The subject search returned
`docs/prompts/setup-v2-rewrite-prompt.md`'s *Out of scope — note, do not fix*
section: *"Real, but a test finding rather than a documentation one. Flag it for
a separate PR."* So the deferral was deliberate and this PR is the separate one
it asked for. Recorded because the check is worth as much when it confirms a
proposal as when it kills one.

**Two findings were filed, not one, and that is a departure from `A5` as
written.** `F12` was opened while filing `F11`, by checking a claim `A5` made in
passing — and it is the more valuable of the two.

**`A5`'s parenthetical is wrong.** It said asserting the list is empty *"would
have caught `REDESIGN-AUDIT` `N6`'s CSS-fetched font."* It would not.
`external` is derived from the **HTML** scan; `N6`'s gap was a font fetched from
inside a **stylesheet**, and what closed that was §1b of the same test. The two
halves guard different doors and `A5` collapsed them.

**Checking that turned up the real gap, proved by running the regex rather than
reading it:**

| in a stylesheet | §1b |
|---|---|
| `url(/shared/fonts/saira-variable.woff2)` | matched |
| `url(https://fonts.gstatic.com/s/saira/v1/x.woff2)` | **not seen** — the regex requires a leading `/` |
| `url(//fonts.gstatic.com/x.woff2)` | **matched, as a same-origin path** |

So an external font request from CSS is invisible to the HTML scan (no tag) and
to the CSS scan (no leading `/`) — the exact regression `F11`'s dead check was
written to prevent, arriving through the door `R7`/`N6` opened. **And the
protocol-relative row is a wrong answer rather than a missing one**: it would be
folded into the derived public list as a directory named `//fonts.gstatic.com`,
in an app whose five Access destinations are spent. That is `F12`, and this menu
would rather Nate saw it than that the count stayed at one.

**Nothing is broken today, said plainly so the filing is not read as an alarm.**
The stylesheets the page loads reference `shared/fonts/` only, `requiredPublic`
derives correctly, and both `smoke.mjs` and `smoke.mjs --remote` pass. `F11` and
`F12` are blind spots, not live faults.

**The second half of `A5`'s proposal — the test change — is untouched by
design.** `F11` states two options and picks neither; `F12` names the shape a
combined fix would take. That is the separate decision `A5`'s posture reserved.

---

### A6 — low — the memory store indexes 12 of 18 menus, and two of the four open items are in the six it misses

The memory store is already the most complete menu index a reader has: eleven
files covering twelve menus, each carrying the menu's trap and its status, and
each reachable from any working directory — which no file in this repo is.

**It is partial in the wrong place.** Measured 2026-09-03 against the store's 66
files:

| | |
|---|---|
| menus with a dedicated memory | 12 |
| menus without | 6 — `BOOK-INGEST-AUDIT`, `DOCS-AUDIT`, `REBUILD-AUDIT`, `cc/AUDIT`, `pick3cut5/AUDIT`, `SETUP-v2-CHANGES` |
| **open items living in those six** | **2 of 4** — `SETUP-v2-CHANGES`'s question 1 (`A5`), and `BOOK-INGEST` `F3` until 08:41 today |

And two existing lines are stale, in different directions and about the same
menu — the three-way `MACHINE-AUDIT` disagreement set out in Part 1.
`repo-audit-menu.md` says PRs #619–#640; #641 merged the same day.

**What this is *not*.** It is not an argument for a memory file per menu. Six of
the twelve that exist were written because the menu taught something durable;
`REBUILD-AUDIT` and `cc/AUDIT` are closed records that taught nothing a later
session needs. **The gap that matters is the two open items, not the six files.**

**Proposal:** correct the two stale lines — `MEMORY.md`'s `MACHINE-AUDIT` line
and `machine-audit-menu.md`'s body, both to point at the file rather than restate
it — and, separately, decide whether the four open items are worth one memory of
their own. **Recommended: no.** A memory listing open work is the status field
`A1` argues against, one layer further from anything that could contradict it.
The two corrections stand on their own.

**Posture: two corrections to existing memories. No new memory file, no index.**

**Evidence:** `grep -l` for menu filenames across the 66 memory files, and a
`comm` of `MEMORY.md`'s 66 index links against the 66 files (they agree exactly
— 0 orphans in either direction), both 2026-09-03; the three-way disagreement
read from all three sources the same day.

*(Instrument note, because it nearly became a finding: the first run of that
`comm` reported all 66 links broken. The cause was a `sed 's/^.//'` in my own
pipeline eating the first character of every filename. Re-run correctly, the
index is perfect. **A tree-wide disagreement is more likely to be your parser
than the tree** — the same lesson `G8` recorded twice about a faked
`process.platform` and a broken `grep -c $'\r$'`.)*

**Taken, 2026-09-03 (PR #650). Posture held: corrections to existing memories,
and NO memory listing open work** — that was the finding's own recommendation
against itself and it stands.

**`A11`'s grep found the governing rule, and I was already inside it.**
`audit-outcome-notes-vary-in-wording` records a `MEMORY.md` line that went stale
in **seventeen minutes** on 2026-09-02, and the decision it produced:

> the index lines here no longer quote finding ranges or "all closed" for any
> menu: they say what the menu is *about* and send the reader to its header.

So the fix was settled a day before this finding was written, and applied to six
lines. **What this PR found is that the rule was applied to `MEMORY.md`'s index
lines and stopped there** — the memories' own bodies and `description:` fields
kept the defect, and a `description:` is loaded exactly the same way. That is the
finding underneath `A6`, and it was not visible until the rule was found.

**`A6` named two stale lines. Reading found four, plus two more of the same shape
in a layer it did not consider.**

| | said | true |
|---|---|---|
| `MEMORY.md`'s `MACHINE-AUDIT` line | `M19`/`M20` filed OPEN | `M19`/`M21` taken, `M20` superseded by `M22` |
| `machine-audit-menu.md` body + `description` | `M1`–`M18` closed, nothing open | silent on `M19`–`M22` entirely |
| **`MEMORY.md`'s `DOCS-AUDIT-2` line** | `D1`-`D3` open | **all three taken 2026-09-03** |
| **`docs-audit-2-menu.md` body + `description`** | `D1`-`D3` open, nothing taken | as above |
| `repo-audit-menu.md` | PRs `#619-#640` | short by one before the day ended (`#641`) |
| **`class-audit-menu.md` `description`** | *"S1-S9 remain"* | **all nine done 2026-08-26, PR #330** |

**Every one is now a pointer rather than a restatement**, which is the shape the
rule prescribes and the only shape that cannot rot. The two `MACHINE-AUDIT`
sources also record *why* the guard failed: both already carried *read its header,
never this line*, and **a line that says do not trust me is still the line that
gets read.** Removing the restatement is what the guard could not do.

**One thing added beyond the proposal, and it is the gap `A6` measured.**
`META-AUDIT.md` had no memory at all, so nothing in the store pointed at the menu
carrying the open work — the exact failure `A6` names, arriving about itself.
`meta-audit-menu.md` now exists. **It states no status**, per the rule: it carries
what the menu is *about*, its own severity-order trap, the declined index, the
subject grep, and a pointer to its header.

**Still not done, and still recommended against:** a memory listing the open
items. It would be a status field one layer further from anything that could
contradict it, which is `A1`'s argument and this finding's own.

**Verified after the edits:** 67 index links against 67 files, zero orphans in
either direction, and no memory now states a menu status that its header
contradicts.

---

### A7 — low — the glob returns a brief, and it is worth one clause rather than a fix

The brief for this audit said `docs/rules-audit.md` is not a menu and the glob
returns it. **That file does not exist.** What the glob actually returns that is
not a menu is `docs/prompts/SKILLAUDITPROMPT.md` — the brief that produced
`SKILL-AUDIT.md`, archived under `HEALTH-AUDIT` `F3`.

**Does it matter? Barely, and the direction is what is interesting.** The skill's
argument for reading rather than globbing rests entirely on the glob **missing**
`SETUP-v2-CHANGES.md`. It also **over-returns**, and nothing says so. A reader
running the command today gets 18 paths, 17 of which are menus, and the skill
prepares them for exactly one of the two errors.

The fix is not a better glob — `-not -path './docs/*'` would work today and
break the moment a menu lands under `docs/`, which is a rule with an
implementation date in it. The fix is one clause.

**Proposal:** fold into `A2`. The sentence below the `find` command already says
the command misses one file and that this is not a bug; add that it also returns
one brief. Two blind spots, one paragraph.

**Posture: documentation only, and it should ship inside `A2` rather than as its
own PR** — which is a deliberate exception to *one PR per finding*, stated so it
is a decision rather than a slip. If that reads wrong, take `A7` alone and leave
`A2`'s caption edit to `A2`.

**Evidence:** `ls docs/rules-audit.md` → *No such file or directory*, and the
full 18-path glob output, both 2026-09-03.

**Taken, 2026-09-03 (PR #647), inside `A2` exactly as this finding directed.**
That is a deliberate exception to *one PR per finding*, argued in the proposal
above and taken on its terms: both findings edit the same paragraph, and two PRs
touching one caption is churn rather than rigour.

The `find` command's paragraph now states **both** blind spots — it misses
`SETUP-v2-CHANGES.md` and it returns `docs/prompts/SKILLAUDITPROMPT.md`, a brief
— and says the answer is *the glob's output, minus the briefs, plus the one it
cannot see*.

**The proposal's refusal to fix it with a better pattern is in the skill
verbatim**, because it is the durable half: `-not -path './docs/*'` is correct
today and wrong the moment a menu lands under `docs/`, which is a rule with an
expiry date nobody will notice.

**One line added beyond the proposal**, and it is why the finding is worth more
than it looks: `REPO-AUDIT` `G11` **miscounted the root with this exact command
and was re-scoped for it**. The paragraph had prepared a reader for one of the
two errors and `G11` walked into the other. Naming the casualty is what turns a
tidy-up into an explanation.

---

### A8 — high — `G18` shipped a rule that two menus had been following at 100% coverage the day before, and calls it "a convention that starts today"

`G18` is the durable output of `REPO-AUDIT` and it is a good rule. **Its own
premise about its novelty is wrong, and the way it is wrong is `G9`'s shape,
committed by the finding that fixed `G18`'s shape.**

Measured 2026-09-03, counting `^**Evidence` lines against findings:

| menu | findings | evidence lines | confidence lines |
|---|---|---|---|
| `HEALTH-AUDIT.md` (2026-09-02) | 24 | **24** | **23** |
| `SKILL-AUDIT.md` (2026-09-02) | 25 `F` | **25** | 0 |
| `REPO-AUDIT.md` (2026-09-03) | 18 | **0** | 0 |

`G18`'s outcome note reads: *"the seventeen findings above it are left exactly as
written — several of them without evidence lines, which is the honest state of a
convention that starts today."* **The convention started 2026-09-02**, in the two
menus filed immediately before this one, at full coverage, from
`workshop\briefs\health-audit-prompt.md`'s finding template. `G18` names none of
them.

**Nothing about the rule needs changing.** It is correctly scoped, correctly
bound to the `Proposal` paragraph, and it belongs in the skill. What is wrong is
one sentence of provenance — and the consequence is not cosmetic: **a reader who
believes the convention is untried has no evidence about whether it works**,
when two menus of evidence exist and one of them (`HEALTH-AUDIT` `F18`) records
the marker catching the thing it was added for.

**And the same passage contains a second, separable error.** The skill's
sentence *"Every finding taken so far has turned up an error in its own
premises"* is false — twelve outcome notes across three menus say the premises
held, quoted in full in Part 2 above. The two live in adjacent sections of the
same skill.

**Proposal, two edits to `.claude/skills/audit-menu/SKILL.md`, one PR:**

1. Under *And a `Proposal` says whether its central claim was measured or
   reasoned to*: add that the convention was **in use in `HEALTH-AUDIT` and
   `SKILL-AUDIT` from 2026-09-02**, name the brief it came from, and note that
   `HEALTH-AUDIT` also carried a **Confidence** line whose one low mark is the
   half that later moved. Do not add a count of anything.
2. Under *Taking a finding is also AUDITING the finding*: replace *"Every finding
   taken so far has turned up an error in its own premises"* with the true and
   more useful version — **checking a finding before scoping it has turned
   something up nearly every time, and it is usually not the premises.** Say what
   the two failures are and that they need different remedies: a wrong premise
   is caught by re-measuring; a wrong *replacement sentence* is caught only by
   measuring the fix, which is what `SKILL-AUDIT` `F4` did to itself twice.
   **Per the skill's own rule, do not quote the sentence being replaced.**

**Posture: documentation only, two paragraphs in one skill. No check, no
retrofit of any menu, and no count.**

**Evidence:** the evidence/confidence line counts run 2026-09-03
(`grep -cE '^\*\*Evidence[.:]'` etc. across eight menus); the twelve
premises-held quotations read from their own blocks the same day, from a
100-finding extraction across five menus; `health-audit-prompt.md` lines 100–116
read 2026-09-03.

**Taken, 2026-09-03 (PR #648), both edits. Posture held: documentation only, two
passages in one skill, no check, no retrofit of any menu, and no count.**

**Half of edit (1) had already shipped — inside `A11`'s PR, four hours earlier,
by me.** `A11`'s new subsection names `G18`'s *"convention that starts today"* as
one of its four instances. That is the right place for it as an example of the
already-decided shape, and **the wrong place for a reader of the evidence rule**,
who never gets there. So edit (1) went where `G18`'s rule actually lives, and
carries what `A11`'s one-line mention could not: the census table, the brief the
convention came from, and the `Confidence` evidence.

**`A11`'s grep found two more sites of the doctrine sentence, and both stay.**
`apps/character-creator/INGESTION-AUDIT.md:103` carries it inside *"This audit's
own premises were wrong in nine places"* — scoped to that audit, dated
2026-08-26, a record. `docs/prompts/surveycommittableprompt.md:130` is a brief,
and briefs here are records by the archive's own first rule. **Only the skill
states it as a live, unscoped claim**, and only the skill was edited.

**The replacement says something the original could not.** The old sentence
collapsed two failures; the new passage splits them and gives each its remedy —
wrong premises are caught by **re-measuring the finding**, while a wrong
*replacement sentence* is caught only by **measuring what you are about to
write**, which is what `SKILL-AUDIT` `F4` did to itself twice. It also names the
twelve findings whose notes record premises holding exactly, so the rule is
justified by what checking finds rather than by the documents being untrustworthy.

**The `Confidence` finding is stated and explicitly not adopted.**
`HEALTH-AUDIT` `F18`'s low-confidence half is the one that moved when it was
taken. That is one instance, it is real, and whether to adopt the marker is
`A9`'s question and Nate's decision — the skill now records the evidence without
making the call.

**Two bugs in my own verification instrument, found by running it.** Checking
that all twelve cited notes really say what the skill now claims, two came back
`NOT FOUND`:

- **`MACHINE-AUDIT` `M16`** says *"Every premise **re-measured** and every one
  holds"* — my pattern listed *re-checked*, *held*, *hold*, *confirmed*,
  *intact*, and not *re-measured*.
- **`SKILL-AUDIT` `F15`** says *"Premises held"* **wrapped across a line break**,
  so a line-based grep cannot see it. That is exactly the trap `DOCS-AUDIT`'s own
  header records about `D4`, whose closure phrase *"No action proposed."* wraps
  the same way — **a live second instance of it, found by accident.**

Both citations are correct; both failures were the instrument. Verified by
reading the two blocks directly. **Three separate scans in this session have now
produced a false negative about these files**, which is the argument the skill
makes about mechanical readers, arriving three more times.

Diff **+50 / −3** on one skill, read off `git diff --numstat` rather than
estimated. The replaced sentence is **not quoted back**.

---

### A9 — high — the research discipline is re-derived in every brief, in five wordings, and the skill owns none of it

`A8` is one instance. This is the mechanism behind it.

Five briefs in `C:\Users\natha\Projects\workshop\briefs\`, diffed 2026-09-03,
each state the same rule in their own words — table in Part 2 above.
`health-audit-prompt.md` states it **twice**, once per half, because the two
halves were separate sessions. Not one of the five cites the skill, and the
skill contained no version of the rule for claims until `G18` shipped
**yesterday's date at the time of writing**.

**The consequence is measurable rather than theoretical.** A menu inherits the
discipline of its brief, and `REPO-AUDIT` had no brief — see `A12`. It produced
five wrong claims in eighteen findings. The two menus whose briefs carried the
template produced findings with 100% evidence coverage and, on the counting
method stated in Part 2, a lower error rate. **That comparison is suggestive and
uncontrolled** — different subjects, n of 18 and 24 — and it is offered as a
reason to move the rule, not as proof that the rule caused the difference.

**What is not suggestive:** the rule is currently transmitted by whoever writes
the next brief remembering to write it. That is the definition of a control that
depends on memory, and this repo's whole instruction layer exists because that
kind fails.

**Proposal.** Move the finding template into `.claude/skills/audit-menu/SKILL.md`
as the shape a finding takes, stated once, so a brief can say *"findings follow
the `audit-menu` shape"* instead of re-deriving it. The fields, from
`health-audit-prompt.md`'s template, minus the two that rot:

- **Severity** — already the convention.
- **Evidence** — already shipped as `G18`; this places it in the template rather
  than in a subsection about numbers.
- **Proposal** and **Posture** — already the convention.
- **Confidence**, high/medium/low **and what would raise it** — `A11` argues this
  one separately, since it is the only genuinely new field.
- **Ongoing cost** — what the proposal costs *forever*, and `HEALTH-AUDIT`'s
  template adds the clause worth keeping: *a proposal whose ongoing cost exceeds
  its impact should say so and recommend declining itself.*
- **Not adopted: Effort (S/M/L) and Impact.** Effort has been wrong in both
  directions here — `G8` shipped "much smaller than proposed" and `G5` grew a
  second defect — and Impact duplicates what a severity word plus a proposal
  already say.

**Cost, stated plainly because it is a real trade.** Four required fields on
every finding, at roughly two to four extra lines each. On an 18-finding menu
that is 50–70 lines and perhaps fifteen minutes. **It buys nothing on a
suspicion and it is not applied to one** — `G18`'s boundary holds and this
template binds at the same place, the `Proposal`. The honest counter-argument is
`G18`'s own decline path: findings are meant to be cheap to file, and every
required field is friction on the part of the loop that should stay
frictionless.

**Posture: documentation only, one skill section. No check, no retrofit, and
briefs are not edited** — they are records, and their re-derivations stay as the
evidence for this finding.

**Evidence:** the five briefs read and diffed 2026-09-03; the evidence-line
census in `A8`; the error counts in Part 2, counted by reading every outcome note
across five menus by the method stated there.

**Taken, 2026-09-03 (PR #649), as written. Posture held: documentation only, one
skill section, no check, no retrofit of any menu, and no brief edited** — the
briefs are records and their re-derivations stay as this finding's evidence.

`.claude/skills/audit-menu/SKILL.md` gains *The shape a finding takes, so a brief
does not have to say*, placed after *Posture is half of what is being agreed to*
— posture is one of its fields, so the section can lean on it rather than restate
it.

**This finding cited a finding that does not exist, and taking it is what found
that.** Its `Confidence` bullet reads *"`A11` argues this one separately."*
`A11` is the *has-this-been-decided* grep and argues nothing about confidence
markers. A separate confidence finding was drafted while this menu was being
assembled and **folded away during consolidation**; the cross-reference was never
updated. So `A9` deferred a decision to nobody.

**Combined with `A8`, that left `Confidence` genuinely unowned.** `A8` shipped
the evidence for it — `HEALTH-AUDIT` `F18`'s low-confidence half is the one that
moved — and explicitly declined to adopt it, saying *"that is `A9`'s question."*
`A9` then pointed at `A11`. **This PR resolves it: `Confidence` is adopted**, on
`A9`'s own field list, and the section makes the *"and what would raise it"*
clause the load-bearing half — *"medium until someone runs X"* tells a taker
where to start; a bare *medium* tells them nothing.

**One measurement moved in the finding's favour.** `A9` says five briefs state
the rule in five wordings. Re-checked at take-time, each quotation resolves and
**"Verify before asserting" appears in three briefs**, not one —
`portability-audit-prompt.md`, `setup-v2-rewrite-prompt.md` and
`workstation-consolidation-prompt.md`. Seven statements of one rule across the
archive, and the skill owned none of it.

**`A11`'s grep found no prior decision for or against a template**, which is the
answer that authorises this one. The template existed in exactly one brief and
was practised in two menus; nothing had ever declined it.

**What is deliberately absent.** No check enforces the fields, nothing is
retrofitted, `Effort` and `Impact` are named as rejected rather than omitted, and
the section carries **no count of fields** — it lists them and stops, because a
tally is the one thing this file argues against everywhere else.

**And the cost is stated in the skill rather than in this note**, where a reader
deciding whether to follow it will actually meet it: tens of lines and about a
quarter of an hour per menu, buying nothing on a suspicion, bound to the
`Proposal` exactly as `G18` is.

---

### A10 — medium — the self-check pass already exists, it caught two findings before Nate read them, and nothing asks for it

The brief offers *a self-check pass before the menu is handed over* as a
candidate. **`REPO-AUDIT` ran one**, under the heading *Every remaining finding
was re-verified on 2026-09-03* — *"Prompted by the error rate above, not by a
schedule."*

**It worked, and its record is precise about what it can and cannot do:**

| finding | caught by the self-check? |
|---|---|
| `G11` — "eight under `apps/`" is nine | **yes**, before Nate read it |
| `G15` — "no signal at all" is false | **yes**, before Nate read it |
| `G6` — claim true, but **unverified when written** | **yes** — flagged as right-by-luck |
| `G8` — the bare clone | **no**. Caught while taking it (PR #620) |
| `G1` — the counting command | **no**. Caught while taking it (PR #621) |
| `G5` — "exclusively" | **no**. Disproved by accident, by taking `G1` |
| `G9`, `G10` — already decided elsewhere | **no**, and it could not have been. Their facts were right. |

**So: three of five wrong claims caught before hand-over, two after, and neither
of the two already-decided findings was reachable by it at all.** That is a
clean, measured account of a control's coverage, and it is the strongest
evidence in this file for anything.

**The pass cost one session's worth of re-running the commands already quoted
inside each finding** — every one read-only, every one printed in the finding it
belongs to. The findings it missed are the ones whose central claim had **no
command to re-run**, which is the same asymmetry `G18` names.

**Proposal:** add the pass to the skill, beside *Taking a finding is also
auditing the finding*, as the mirror of it — **before a menu is handed over, the
author re-runs every command their own findings quote and reports what moved**,
in the menu, as `REPO-AUDIT` did. Two clauses that are the whole value:

- **Report the pass even when nothing moves.** `REPO-AUDIT`'s table names the ten
  findings whose central claim held, and that is what makes the two `WRONG` rows
  legible.
- **Say what the pass cannot see.** A finding with no command to re-run is not
  verified by it, and a finding proposing a decision is not touched by it at all
  — which is `A11`.

**Posture: a convention for a new menu, documentation only. Not a required
phase, not a checkable artifact, and no check.** A separate evidence-log artifact
is **argued against below**.

**On the brief's other candidate — a research phase producing a filed evidence
log.** Recommended against, on this evidence. The pass above extracts the same
value from documents that already exist: the commands are already quoted inside
the findings, which is where a taker needs them. A separate log is a second
document to keep in sync with the first, and the failure this whole menu
documents is documents disagreeing with each other. `HEALTH-AUDIT` and
`SKILL-AUDIT` got the same benefit from a one-line `**Evidence.**` field with no
second file at all.

**Evidence:** `REPO-AUDIT.md`'s re-verification table and the outcome notes of
`G1`, `G5`, `G8`, `G9`, `G10`, `G11`, `G15`, each read to the next heading,
2026-09-03. The coverage table above is derived from those notes and from
nothing else.

**Taken, 2026-09-03 (PR #651), as written. Posture held: a convention for a new
menu, documentation only — not a required phase, not a checkable artifact, and no
check.** The separate evidence-log artifact stays argued against, on this
finding's own reasoning.

**This finding's central number was wrong, and taking it is what found that.**
`A10` says the pass caught *"three of five wrong claims before hand-over"* and
tabulates `G8`, `G1` and `G5` as ones it **missed**. It did not miss them — **it
never saw them.** `REPO-AUDIT`'s pass covers *"every **remaining** finding"*, and
those three had already been taken when it ran:

| | |
|---|---|
| `G8` taken | PR #620, merged 16:41 UTC |
| `G1` taken | PR #621, merged 16:55 UTC |
| `G5` half (a) taken | PR #636, merged 18:43 UTC |
| the pass's own table | lists thirteen findings, and none of those three |

And the direction is the opposite of what `A10` implies: the pass was **prompted
by** those three failures — its own opening line says *"prompted by the error
rate above, not by a schedule"* — so implementing had already exposed them before
the pass existed.

**The corrected record is smaller and it argues harder.** Of the **thirteen**
findings the pass examined, it found **two materially wrong** (`G11`, `G15`) and
flagged **one right by luck** (`G6` — verified *enabled* while asserting
*empty*). Ten held. That is what went into the skill, with the clause `A10` could
not have written: **run it earlier than `REPO-AUDIT` did and it is strictly
better than that record**, because `REPO-AUDIT`'s ran late and still caught two.

**`A11`'s grep found no prior decision either way.** What it found was the
practice happening unnamed — `CLASS-AUDIT`, `apps/character-creator/AUDIT` and
`INGESTION-AUDIT` all say *"re-verified on <date>"* in their headers. Those are
re-verifications of **closed** findings, a different act from `REPO-AUDIT`'s
pre-hand-over pass over **open** ones, and the skill now names only the second.

**Two clauses carried across because they are the value, not the mechanism.**
Report the findings that **held** as well as the ones that moved — the rows that
held are what make the wrong ones legible. And **state what the pass cannot
see**, in the menu, so its silence is not read as coverage: a finding with no
command to re-run is not verified by it, and a finding proposing a *decision* is
untouched by it entirely. That second one is `A11`'s grep, and the skill says so
rather than letting a reader assume one pass covers both.

---

### A11 — medium — "has this been decided?" is not in the skill, it is a thirty-second grep, and it is the only check that reaches the errors re-measurement cannot

`REPO-AUDIT`'s header names two failure shapes. `G18` fixed one. **The second is
not in the skill**, and the skill is where it would have to live, because the
shape is about the *corpus* rather than about any one finding.

Its record, all 2026-09-03 unless dated:

| instance | what was re-proposed | already settled |
|---|---|---|
| `G9` | rename `SETUP-v2-CHANGES.md` to fit the glob | `HEALTH-AUDIT` `F4`, PR #523, **one day earlier**, the other way |
| `G10` | number the data scripts | `SKILL-AUDIT` `F25(b)`, PR #567, whose note ends *"recorded so it is not re-proposed"* |
| `REPO-AUDIT`'s own scope statement | deferred territory to a `PORTABILITY-AUDIT.md` | dropped 2026-09-02, said so in **four files** |
| `G18` | the evidence line as a new convention | in force in two menus since 2026-09-02 (`A8`) |
| **this menu, `A4`** | *would have* proposed a status header for `HEALTH-AUDIT` | declined deliberately in `3a8f0ca` — found by running the grep |

**Five instances, four of them errors, and the fifth is this menu avoiding one by
doing the thing being proposed.** That is the argument: it is not a hypothetical
check, it has already paid for itself once in the document proposing it.

**Re-measurement cannot reach any of them.** `G9` had verified its facts twice.
`G10`'s design question was closed by a decision, not by a measurement. What
would have caught all four is a grep for the **subject** across the other menus
and the memory store, before the proposal is written.

**Proposal.** One paragraph in the skill, beside *Taking a finding is also
auditing the finding*, which already owns "check before you scope":

> **Before writing a `Proposal`, grep the other menus and the memory store for
> its subject.** Not for a finding number — for the thing being proposed: the
> filename, the mechanism, the setting. A decision made and recorded is not
> reopened by a fresh measurement, and four proposals here have reversed one
> without noticing. `~/.claude/.../memory/` is part of the grep and no repo grep
> reaches it.

Two clauses earn their place beside it:

- **This is not the mechanical reader the skill rules out.** It greps for a
  *subject*, produces paragraphs for a person to read, and has no verdict — the
  same posture as `scripts/audit-citations.mjs`.
- **A finding may still re-propose a settled decision** — circumstances change.
  What it may not do is fail to say that one exists. `G10`'s note is the model:
  it names `F25(b)`, quotes it, and then kills itself on a second, independent
  ground.

**Cost: one grep per proposal, thirty seconds.** On an eighteen-finding menu,
under ten minutes. That is the smallest cost of anything proposed in this file
and it addresses the failure that `G18` explicitly says it cannot reach —
`G18`'s own note: *"an evidence line would have caught neither."*

**Posture: documentation only, one paragraph. No check, no script, no retrofit.**

**Evidence:** `G9`'s and `G10`'s outcome notes and `REPO-AUDIT`'s corrected scope
statement, read 2026-09-03; the `G18` instance measured in `A8`; the `A4`
instance is this session's own grep, run before that finding was written.

**Taken, 2026-09-03 (PR #642), as written. Posture held: documentation only, one
subsection in one skill, no check, no script, no retrofit of any menu.**

`.claude/skills/audit-menu/SKILL.md` gains *And before WRITING a proposal, grep
the other menus for its subject*, as a subsection of *Taking a finding is also
AUDITING the finding* — the placement this finding named, because that section
already owns *check before you scope* and this is the same instruction one step
earlier in the loop.

**Every premise re-verified before scoping, and all four instances hold**, each
read to the next heading rather than grepped: `G9`'s note (*"the check is a grep
for the filename across the other menus, which takes thirty seconds and was not
done"*), `G10`'s note and the `F25(b)` note it re-proposed against,
`REPO-AUDIT`'s corrected scope statement, and the `G18` measurement from `A8`.
`G18`'s own note still reads *"an evidence line would have caught neither"*,
which is this finding's whole warrant. `scripts/audit-citations.mjs` confirmed to
carry no `process.exit` and no `exitCode`, so the posture comparison in the
proposal is accurate.

**Three deviations from the proposal as written, all declared rather than made
quietly.**

1. **The tally was dropped.** The proposed paragraph contained *"four proposals
   here have reversed one without noticing."* That is exactly the maintained
   count this skill forbids, and the section it now sits above is the one that
   records what such a tally has cost here. **The instances are named instead**,
   which is what the skill does everywhere else and what `A1` and `A2` argue for
   in this same file. Writing the count into the skill would have made the
   finding contradict its own menu on the page opposite.
2. **One sentence was added distinguishing this grep from the existing one.**
   `A11` says the rule is "not in the skill", which is true — but the skill
   already asks for a memory-store grep, under *ANYTHING that cites a finding
   goes stale*, and that one runs **after** a finding is taken and searches for
   its **number**. Two memory greps a page apart with different timing and
   different targets would collapse into one in a reader's head. The new
   subsection now says which is which.
3. **A short "what a hit looks like" paragraph was added.** Found while doing
   the work: grepping the corpus for prior proposals of this rule turned up no
   proposals and **four defences** — `SKILL-AUDIT` `F8` (*"Not to be
   re-proposed"*), `F25(b)`, and `REDESIGN-AUDIT`'s `## Not carried forward, and
   why` section. Those sentences exist for this grep and nothing makes them fire.
   A rule that says *grep for the subject* without saying what a hit reads like
   is harder to follow than it needs to be.

**And this finding's own check was run on itself, which is how deviation 1 was
caught.** Grepping the corpus for the subject — *a rule requiring a check against
prior decisions* — returned no menu proposing one, so `A11` is not itself an
instance of the shape it describes. It also returned the four defences above.
The grep took under a minute, which is the cost the finding claims.

**Filing and taking were collapsed into one PR, and that is a departure from the
protocol.** `META-AUDIT.md` was untracked when Nate said *take A11*, so the menu
and its first outcome note land together. Declared here rather than done
silently, on the `MACHINE-AUDIT` `M22` precedent. **The decision itself was
separate** — twelve findings were filed, read and one named — which is what the
rule protects; what is collapsed is only the commit boundary. The remaining
eleven findings are untouched and open.

**Nothing else changed.** No menu was edited, no count anywhere was updated, no
memory file was written, and the eleven other findings in this file stand exactly
as filed. Diff: **+51 lines to one skill, 0 deletions**, CRLF preserved, no
control characters — checked with `node`, not with `grep -c $'\r$'`, per
`windows-shell`. *(This read +53 until the figure was taken off
`git diff --numstat` instead of estimated. Corrected before the commit, and
recorded rather than silently fixed: a menu about unmeasured claims should not
ship one in its own first outcome note.)*

**One more thing this PR had to fix about itself.** `META-AUDIT.md` was written
as pure LF; every other `.md` in this working tree is CRLF, and only `*.sql` and
`.github/workflows/*.yml` are pinned to LF by `.gitattributes`. Normalised with a
`latin1` byte round-trip — no new text supplied, so nothing could be truncated —
and verified afterwards: 1,299 CRLF, 0 bare LF, 0 control characters, and the 184
em-dashes and the one emoji all intact.

**Note on `G18`'s boundary, which the brief asks about directly.** It held. Two
of the five wrong claims — `G5`'s *"exclusively"* and `G15`'s *"no signal at
all"* — sit in the finding's **body and heading**, not in its `Proposal`, and
`G18` would not have bound them. It is still the right boundary: a suspicion must
stay cheap to file, and both of those were caught anyway, by the pass in `A10`
and by taking `G1`. **`G9`'s wrong claim was in a heading**, and no version of
`G18` at any scope would have caught it, because it was not a claim about a fact.
That is this finding, not a wider `G18`.

---

### A12 — low — the brief archive is two short again, and the menu with the worst error rate has no brief anywhere

`HEALTH-AUDIT` `F3` — *"the method that produced this repo is not in this
repo"* — shipped `docs/prompts/` on 2026-09-02. `SKILL-AUDIT` `F19` found it
**already two briefs short the same day** and added three. Its own README says
so: *"An archive assembled by hand is missing something the day it lands."*

**Measured 2026-09-03, and it has happened again:**

| brief | in `workshop\briefs\` | in `docs/prompts/` |
|---|---|---|
| `docs-audit-2-prompt.md` → `DOCS-AUDIT-2.md` | yes | **no** |
| `meta-audit-prompt.md` → this file | yes | **no** |
| **a brief for `REPO-AUDIT.md`** | **does not exist** | **no** |

The third is the one that matters. A grep for `REPO-AUDIT` across all of
`C:\Users\natha\Downloads\` and `C:\Users\natha\Projects\workshop\` returns
**only this meta-audit's own brief**. The menu that produced the ruleset on
`main`, CI on every PR, and `G18` itself **has no recorded brief**, and `A9`
argues the brief is where the research discipline came from — so the one menu
that inherited none is the one with five wrong claims in eighteen findings.
That is a correlation, not a cause, and it is the only one available.

**And two byte-identical duplicate pairs exist today**, the same shape
`DOCS-AUDIT-2` `D3` deleted two of **this morning** (PR #611):

```
30611f74…  Downloads\metaauditprompt.md        = briefs\meta-audit-prompt.md
6f4ed9b2…  Downloads\openitems20260902prompt.md = briefs\open-items-2026-09-02-prompt.md
```

`D3` deleted the unhyphenated twin of two other pairs and the directory went 28
files → 26. **The naming pattern that produces them is unchanged**, so the
count went back up the same day. That is not a criticism of `D3`, which did
exactly what it proposed; it is evidence that the pair is a symptom of how a
brief is written and copied, and that deleting pairs does not reach it.

**Proposal, and it should be small.** Copy the two missing briefs into
`docs/prompts/` with their README rows, and add one row for `REPO-AUDIT.md`
recording that **its brief was not kept** — an absence stated is worth more than
a gap. Do **not** propose a rule requiring future briefs to land there; the
README's last line already says *"Nothing requires a future prompt to land here.
This is an archive, not a process."* and that decision stands.

**Explicitly not proposed: anything about the duplicate pairs.** They are outside
the repo, `D3` is closed, and the shape is recorded here so the next reader knows
deleting them is not a fix.

**Posture: two files copied, three README rows. No new process, no check, and the
existing decline of one is left standing.**

**Evidence:** `ls` of both directories and `md5sum` on the two pairs, 2026-09-03;
`grep -rl "REPO-AUDIT"` across `Downloads\` and `workshop\` returning one file;
`docs/prompts/README.md` read in full the same day.

**Taken, 2026-09-03 (PR #646), as proposed. Posture held: two files copied,
three README rows, and NO rule requiring a future brief to land here** — that
decision stands and the finding said not to touch it.

`docs/prompts/` gains `docs-audit-2-prompt.md` and `meta-audit-prompt.md`, plus a
row recording that `REPO-AUDIT.md`'s brief was never saved.

**The records were copied, not edited, and that was proved rather than
asserted.** The README's own first rule is *"These are records, not documents. Do
not edit them to match what happened."* Both files were written CRLF to match
every other file in this working tree, and then the **staged blob was compared
byte-for-byte against the source**: identical for both. Git stores LF for `.md`
here — `core.autocrlf` is `true` and `.gitattributes` pins only `*.sql` and the
workflow YAML — so the working-tree conversion is invisible in the commit and the
archived record is the brief exactly as it was written.

**`A11`'s grep found the governing decision, and it is a boundary rather than a
block.** `docs/prompts/README.md` ends *"Nothing requires a future prompt to land
here. This is an archive, not a process."* `A12` anticipated that and proposed
nothing against it; this PR copies two files and states an absence, and adds no
rule, no check and no obligation.

**The `REPO-AUDIT` row says more than `A12` asked for, and the addition is
argued.** `A12` proposed recording that the brief was not kept. The row also
carries what that costs, because `A9` establishes the discipline travels by
brief — and it is labelled **a correlation and not a demonstrated cause**, which
is the whole point of the menu it sits in. Stating the absence without stating
why it matters would have been a tidier row and a less useful one.

**Deliberately not done: the duplicate pairs.** Two byte-identical brief pairs
still exist across `Downloads\` and `workshop\briefs\`, the same shape
`DOCS-AUDIT-2` `D3` deleted two of this morning. They are outside the repo, `D3`
is closed, and this finding said explicitly not to propose anything about them.
The shape stays recorded here so the next reader knows deleting pairs does not
reach the naming habit that produces them.

---

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

### A13 — medium — nothing bounds what a status header may carry, and the menu that audited the headers now has a stale one

**What is already decided, and this finding does not reopen any of it.**
`HEALTH-AUDIT` `F8` created the convention and PR #531 gave every other menu a
status line. `A3` corrected `BOOK-INGEST-AUDIT`'s. `A4` recorded
`HEALTH-AUDIT`'s abstention. **`## The status headers, checked against their own
findings`, above in this file, read all eighteen on 2026-09-03** and found twelve
accurate, one stale, one absent by decision, one silent about a live item.

**That was a correctness pass, and correctness is not the constraint that binds.**
Nothing in `audit-menu` says what a header may contain — verified 2026-09-04 by
reading all eleven `## ` sections of `.claude/skills/audit-menu/SKILL.md`
(`grep -nE '^## '`, which returns *The loop*, *Posture…*, *The shape a finding
takes*, *Taking a finding is also AUDITING the finding*, *A class note that
cites a finding…*, *Never grep for the outcome note*, *The headings are not
uniform*, *Audit files are RECORDS*, *Every number carries its date*, *Where a
new menu goes*, *When not to*). The status material in it governs **where**
status lives, never **how much** of it a header may restate.

**So the headers grow with the churn of the menu beneath them.** Measured
2026-09-04 **at `2eed604`, the merge of #699 — before this PR's own edits**, by
taking each file from line 1 to its first `## ` and counting distinct
`` `X<n>` `` finding IDs named:

```bash
git show 2eed604:META-AUDIT.md | awk 'NR>1 && /^## / {exit} {print}' > /tmp/h
wc -l < /tmp/h ; grep -oE '`[A-Z][0-9]+`' /tmp/h | sort -u | wc -l
```

| menu | header lines | finding IDs named | findings in file |
|---|---|---|---|
| `SKILL-AUDIT.md` | **98** | **33** | 42 |
| `SHIP-PR-AUDIT.md` | 69 | 10 | 14 |
| `BOOK-INGEST-AUDIT.md` | 62 | 5 | 21 |
| `META-AUDIT.md` | 39 | 13 | 12 |
| `MACHINE-AUDIT.md` | 39 | 9 | 22 |
| `EFFICIENCY-AUDIT.md` | **19** | **2** | 7 |
| `apps/media-vault/ISBN-AUDIT.md` | 17 | 5 | 10 |

**The pin matters and is not decoration.** Filing this finding moved
`META-AUDIT`'s own row from 39 lines and 13 IDs to 50 and 16 — the act of
recording a status grew the header being measured, inside the PR that measures
it. That is the finding restated as an accident, and it is why every figure here
names the commit it was read at rather than only the day.

**`SKILL-AUDIT`'s header is 98 lines — 29 longer than the next widest and five
times `EFFICIENCY-AUDIT`'s**, and it narrates findings that reverse each other
inside a morning — `F42` partly reverses `F40`, taken hours earlier, and the
header says so. Its own text says the fifth and sixth `##` placements are *"past
the point where the arrangement helps anyone."* <!-- claim-ok: quoting SKILL-AUDIT's own header, read 2026-09-04 -->

**The failure this produces is in this file.** `META-AUDIT`'s header says:

> **Two findings this menu FILED are open elsewhere** — `apps/pick3cut5/AUDIT.md` `F11` and `F12`.
<!-- claim-ok: quoting the stale sentence this finding corrects -->

**Both were taken on 2026-09-03.** Read under their own headings in
`apps/pick3cut5/AUDIT.md` on 2026-09-04: `F11` carries *"Taken, 2026-09-03 (PR
#653) as option (a)"* and `F12` carries *"Taken, 2026-09-03 (PR #654), as
proposed and as ONE assertion over both doors"*. That menu's own header opens
*"Nothing is open."* This menu was filed against `main` @ `3332349`, the merge of
#641; #653 and #654 merged after it. **The header of the menu that audited the
headers went stale the same day it was written, in the direction `A3` named as
costing most — advertising open work that is done.**

**Two headers carry an explicit disclaimer and then do the thing anyway.**
Counted 2026-09-04 over the same header blocks: `META-AUDIT` says *"this line
does not count them"* and *"this line does not carry them"* while naming
thirteen finding IDs with their states; `MACHINE-AUDIT` says *"this line
deliberately does not count them"* while naming nine.
<!-- claim-ok: quoting both headers, read 2026-09-04 --> `INGESTION-AUDIT`
carries the same formula and names five. **The sentence from `A4` and `A6` was
adopted as a disclaimer rather than as a behaviour**, which is the same shape
`A6` already found in the memory store — *"a line that says do not trust me is
still the line that gets read."*

**What is NOT wrong here, and must not be swept up.** The *"one that misreads"*
and *"this menu's own trap"* paragraphs — ten menus carry one, `MACHINE-AUDIT`
five and `REPO-AUDIT` four. **Not one of them has gone stale.** They describe a
file's *shape*: that `CLASS-AUDIT`'s `S` items are bullets, that
`INGESTION-AUDIT` `F14` quotes its own note format so every grep reports it
taken, that `pick3cut5/AUDIT`'s `T` items are bold paragraph leads. Shape does
not change when a finding closes, which is exactly why those have survived and
the status narrations have not. **They are the durable half of a header and this
proposal keeps every one of them.**

**Proposal:** one section in `.claude/skills/audit-menu/SKILL.md`, beside the
existing status material, bounding what a header may carry — **whether anything
is open, and how to read the file.** A per-finding state does not go in a
header; where one needs saying the header says *read under the heading* and
stops. The section must say explicitly that the shape/trap paragraphs are **not**
what it restricts, or taking it will delete the half that works.

**Posture: documentation only. One section in one skill. NO retrofit of any
existing header, no check, no script, no count of menus in the rule.** The bound
governs the next header written and the next line added to an existing one.

**The stale sentence in this file's own header is corrected in the PR that files
this finding, and that is deliberate rather than a scope violation** — a header
being edited to announce new findings must not keep carrying a claim the same PR
proves false. It follows `A3`'s precedent exactly: the status claim only, and
the replaced phrase is not quoted in the header. **That correction is not part
of this finding's proposal and taking `A13` does not depend on it.**

**Evidence:** header blocks extracted with
`awk 'NR>1 && /^## / {exit} {print}'` over all 20 menus and finding IDs counted
with `grep -oE '\`[A-Z][0-9]+\`' | sort -u`, 2026-09-04; `A3`/`A4` and
`## The status headers, checked against their own findings` read in this file,
2026-09-04; `apps/pick3cut5/AUDIT.md` `F11` and `F12` read under their own
headings, not grepped, 2026-09-04; `git log --format='%h %ci %s' -- SHIP-PR-AUDIT.md`
and the merge order of #641/#653/#654, 2026-09-04; all eleven `## ` sections of
`audit-menu/SKILL.md` read, 2026-09-04.

**Confidence: high on the measurements and on the stale sentence** — both were
run rather than reasoned to. **Medium on the remedy.** A bound is one instrument;
the other is accepting that a live menu's header grows and that this is the cost
of the only place a status legitimately lives. **What would raise it:** whether a
long header has ever actually misled a reader, as distinct from being long.
Nothing on this machine records one, and this finding does not claim it has.

**Ongoing cost: one more clause in a 688-line skill, and a judgement to make
each time a header is edited.** That is a real cost and it is the honest
argument against this finding: the rule it adds is a rule someone has to
remember, which is the objection `SHIP-PR-AUDIT` `F10` was declined on.

**Taken, 2026-09-04 (PR #703). Posture held: documentation only, one section in
one skill, NO retrofit of any header, no check, no script, no count of menus in
the rule. The section says explicitly that the trap paragraphs are not what it
restricts**, which the proposal named as the way this could be implemented
wrong.

**The premise audit found six things. Two changed the implementation.** Led
with, per the skill.

**1. This finding never engaged `SKILL-AUDIT` `F42`, and its own brief said it
must.** `F42` is open and argues arrangement prose belongs *"a menu's own dated
header, which is where `audit-menu` already puts status for the same reason"* —
pushing **more** into headers while this finding asks whether they already carry
too much. The brief called that *"the live tension and the pass must engage it
directly."* This finding mentions `F42` once, only as an example of a header
narrating self-reversing findings, and never states which side of its own line
arrangement falls on.

**The shipped section resolves it rather than ducking it**, and the resolution
is the useful part: **the line is not length, it is whether a sentence can go
stale on its own.** Arrangement is *how to read the file* and stays true as
findings close, so it is permitted and `F42` may be taken without reopening
this. What a header still may not do is give each of those findings its state on
the way past. **Had this finding been implemented as written, `F42` and `A13`
would have contradicted each other in the same file.**

**2. The proposal's placement instruction named a location that does not
exist.** It said *"beside the existing status material"* <!-- claim-ok: quoting the placement this note corrects -->
— but there is no status section in `audit-menu`; the only such material is two
lines inside the index-decline bullet list under *The headings are not uniform*.
**That is the `SHIP-PR-AUDIT` `F14` shape**, the one this repo has a rule and a
CI check about: a claim about another file that named a place with nothing in
it. The section went in as its own `## `, immediately before *The headings are
not uniform*, next to the material about where status lives.

**3. `MACHINE-AUDIT` five and `REPO-AUDIT` four does not reproduce. Both have
one.** <!-- claim-ok: quoting the figures this note corrects --> Measured
2026-09-04 by counting the paragraphs rather than the word: `MACHINE-AUDIT.md`
carries one such paragraph, at `:25`; `REPO-AUDIT.md` one, at `:84`. **The "ten
menus" holds** and reconciles exactly — the union of both phrases is eleven
files, of which `HEALTH-AUDIT`'s two hits are body prose and it has no status
header at all by `A4`. **The 5/4 came from the brief unverified**, restated here
as a measurement with no command printed beside it, in a finding whose header
table does print one. Same failure as `A15`'s inherited off-by-one, in the same
pass.

**And `REPO-AUDIT`'s trap paragraph is not in its header block at all** — read
2026-09-04, it opens at `REPO-AUDIT.md:84` while that file's first `## ` is at
`:31`, and `awk 'NR>1 && /^## / {exit} {print}' REPO-AUDIT.md | grep -c "own
trap\|one that misreads"` returns **0**. So a rule bounding header content never
reaches it, and the finding's own example was outside its own scope.
`MACHINE-AUDIT`'s single paragraph, by the same commands, is at `:25` against a
first `## ` at `:40` — inside its header, and in scope.

**4. "All eleven `## ` sections" is twelve**, and it was `A15` — taken an hour
earlier from this same menu — that added the twelfth. **The absence claim
survives**: re-read 2026-09-04, none of the twelve bounds header content, and
`A15`'s new section governs where a closed menu goes. The skill is **742 lines,
not the 688** this finding costs against; `A14` and `A15` took it there. Two
other places inherit the stale count — `A15`'s body and the hand-over table row
reading *"`audit-menu` has eleven `## ` sections … held"*, which is now false in
both halves and stays as the record of what the pass reported.

**5. This finding quotes four of five verdicts from the section it cites.**
`## The status headers, checked against their own findings` also found *"one is
accurate but reads as more final than it is"* — `REPO-AUDIT`, `G5` half (b).
Neither list totals eighteen; that section's own arithmetic is 16 of 18.

**6. Two of the ten trap paragraphs contain instructions naming taken
findings.** `MACHINE-AUDIT`'s *"Take `M7` against the list"* and `SKILL-AUDIT`'s
pointer to `F7`. **Not stale**, on the reading this menu already applied to
`SKILL-AUDIT`'s header — a dated instruction about how to implement is not a
claim about what is open — but close enough to the line that the shipped section
names both and says why they sit at its edge rather than outside it.

**What held, and one of them is worth more than the corrections.** The header
measurement table reproduces **exactly, row for row**, at `2eed604`. And
`META-AUDIT`'s own row is 50 lines / 16 IDs at HEAD — **precisely the figure
this finding predicted** — while `A14` and `A15`, taken since, did **not** move
it again: both wrote their outcome notes under their own headings instead of
into the header. **That is the protocol working, measured, in the window this
finding is about.**

### A14 — low — the prefix census says eleven menus use `F`; twelve do, and the count is the part that rots

`audit-menu` → *Which is why a finding reference names its menu* carries a
census table whose `F` row reads **eleven**.
<!-- claim-ok: quoting the cell this finding corrects; read 2026-09-04 -->

**Twelve menus use `F` as a heading prefix.** Measured 2026-09-04 with
`grep -cE '^#{2,3} \`?F[0-9]+'` over every menu: `SKILL-AUDIT` (42),
`UI-AUDIT` (30), `INGESTION-AUDIT` (25), `HEALTH-AUDIT` (24),
`BOOK-INGEST-AUDIT` (21), `REBUILD-AUDIT` (20), `CLASS-AUDIT` (20),
`SHIP-PR-AUDIT` (14), `pick3cut5/AUDIT` (12), `ISBN-AUDIT` (10),
`EFFICIENCY-AUDIT` (7), `apps/character-creator/AUDIT` (6).

**It was right when it was written and went wrong in seven hours.** The census
landed in `07cf1ec`, 2026-09-03 13:50, taking `REPO-AUDIT` `G12`/`G13`.
`SHIP-PR-AUDIT.md` was created in `9e9a219` at 20:48 the same day carrying ten
`### F<n>` headings — `git show 9e9a219:SHIP-PR-AUDIT.md | grep -cE '^### F[0-9]+'`
returns 10, run 2026-09-04. Nothing re-counted the table.

**The convention the table justifies is holding, and that is the more useful
half of this finding.** Measured 2026-09-04 across the nine skills, the five
agent files and `CLAUDE.md`: of 36 citations carrying an ambiguous prefix
(`F`, `D`, `N`), **28 name their menu within the preceding clause.** Of the eight
that do not, six are rows of the shape table whose own first cell is the
filename, and one is the deliberate `git log --grep='F18'` illustration in the
section that teaches the rule. **The genuine violation is one:**
`.claude/skills/ship-pr/SKILL.md` writes *"It was path-filtered for part of that
day and is not now (`F36`)"* for `SKILL-AUDIT` `F36`. Bare citations otherwise
cluster on `G` and `M`, which one menu each uses, where nothing is ambiguous.

**So this is not a compliance finding and should not be taken as one.** The rule
works. What rots is the number defending it — and the skill's own doctrine, from
`SKILL-AUDIT` `F7`, is that removing an ordinal beats incrementing it because
*"incrementing leaves the same trap armed."*

**Proposal:** SUBTRACTIVE. Replace the numeric column in that census table with
the fact that carries the argument — `F` is used by many menus, `D` and `N` by
more than one, the rest by one each — so the table states what makes a bare
number ambiguous without stating a figure that has to be re-counted every time a
menu lands. **Do not change eleven to twelve.**

**Posture: documentation only, subtractive, one table in one skill. No check, no
retrofit of existing citations, and `git log` history is not rewritten** — the
same posture `G12`/`G13` set. Fixing `ship-pr`'s one bare `F36` is **not** in
this posture; it is a one-word edit for whoever next opens that file.

**Evidence:** the census table read at
`.claude/skills/audit-menu/SKILL.md`, 2026-09-04; the twelve-menu count by the
`grep -cE` above, 2026-09-04; `git log -S` for the census text and
`git log --diff-filter=A -- SHIP-PR-AUDIT.md`, both 2026-09-04; the 36-citation
compliance count by script over `.claude/skills/*/SKILL.md`,
`.claude/agents/*.md` and `CLAUDE.md`, 2026-09-04.

**Confidence: high.** Every claim here came from a command. **What would lower
it:** nothing measured — the only judgement is whether a census table with no
numbers still makes its argument, and the paragraph above it already states the
argument in words.

**Ongoing cost: negative.** It removes the cell that has to be re-counted every
time a menu is filed, and adds nothing that can go stale.

**Taken, 2026-09-04 (PR #701). Posture held: documentation only, subtractive,
one table in one skill. No check, no retrofit of citations, no history
rewritten, and `ship-pr`'s bare `F36` deliberately left alone.**

**The premise audit found four things, and one would have shipped a wrong row.**
Led with, per the skill.

**1. The bottom row was missing a letter, which is worse than the count this
finding is named for.** It read `` `B` `C` `G` `M` `R` `` — one each. But
`META-AUDIT.md` was created at 16:20 on 2026-09-03, two and a half hours *after*
the census landed at 13:50, and its `A` was never added. **Implementing this
finding's own words — "the rest by one each" — would have re-shipped that row
still wrong.** It now reads `` `A` `B` `C` `G` `M` `R` ``. Re-walked 2026-09-04
with the command now printed under the table: `F` 12 menus, `D` 3, `N` 2, the
rest one each. **This is not a scope substitution** — the proposal says keep the
letters and drop the numbers, and a missing letter is that proposal implemented
incorrectly rather than a second finding.

**2. The compliance figure in this finding is wrong and does not reproduce.** It
says *"of 36 citations … 28 name their menu"*. <!-- claim-ok: quoting the figure this note corrects -->
Re-derived 2026-09-04 with a stated command over
`.claude/skills/*/SKILL.md`, `.claude/agents/*.md` and `CLAUDE.md`
(`grep -noHE` for a backticked `[FDN][0-9]+` token, piped to `wc -l`), the total
is **39, not 36**, and they sit in four files only — `audit-menu` on 24 lines,
`ship-pr` 3, `claim-audit` 1, `CLAUDE.md` 2. **All five agent files and six of
the nine skills carry none.** The breakdown was wrong too: **seven** shape-table
rows rather than six, and two further rows counted as table rows belong to the
false-premise table under *A claim about ANOTHER FILE*, whose first cell is a
sentence and not a filename. **The finding's stated confidence — "high, every
claim here came from a command" — was false of this one figure**: no script for
it was committed, so it was the single number a reader could not re-run. The
conclusion it supports is unchanged, and now rests on a command instead.

**3. A second genuine bare citation exists, in the section that teaches the
rule.** `.claude/skills/audit-menu/SKILL.md` writes *"written by someone who had
just read `F7`"* immediately after naming `SHIP-PR-AUDIT` — which has an `F7` of
its own, while the one meant is `SKILL-AUDIT`'s. **Left unfixed, matching the
posture that left `ship-pr`'s `F36` alone**, and recorded so *"the genuine
violation is one"* is not restated from this page. Both are one-word edits for
whoever next opens those files.

**4. Sharper evidence than the finding used.** Commit `37e4acc` (2026-09-03
22:47, taking `SHIP-PR-AUDIT` `F12`) **added the `SHIP-PR-AUDIT.md` row to the
shape table about 110 lines below this census, and left `eleven` untouched.** So
"nothing re-counted the table" is not that nobody looked: somebody edited the
same file, in the same session, for the same reason, and the count was not near
enough to be noticed.

**What the edit preserved on purpose.** The heading
`### Which is why a finding reference names its menu` is cited by three files —
`.claude/skills/ship-pr/SKILL.md`, `REPO-AUDIT.md` and
`docs/prompts/protocol-retrospective-prompt.md`, checked 2026-09-04 — so it
survives verbatim. The `D`/`N` row now says *includes* rather than naming a
closed set, so a fourth `D` menu cannot falsify it.

**`SKILL-AUDIT` `F42` is open and edits the same file**, deleting the two
arrangement cells from the shape table. Not touched here. Whichever ships second
should re-read the file rather than either menu's quotation of it.

### A15 — low — nothing says where a closed menu goes, and seventeen of nineteen are closed

`audit-menu` has `## Where a new menu goes` and `## When not to`. **There is no
section on what becomes of a finished one** — established 2026-09-04 by reading
the output of `grep -nE '^## ' .claude/skills/audit-menu/SKILL.md`, which returns
eleven sections, listed in full in `A13`'s evidence above. Read, not inferred
from a pattern.

**The scale.** 19 menus, **27,952 lines**, measured 2026-09-04 **at `2eed604`,
the merge of #699** (`wc -l` over the glob plus `SETUP-v2-CHANGES.md`). Two carry
open work — `SKILL-AUDIT` (`F41`, `F42`) and, until this file lands, none
elsewhere. The other seventeen are finished records sitting in every glob and
every grep beside the documents describing how the repo works today.

**Filing this finding took the corpus to 28,454 lines**, which is stated because
a reader re-running the `wc -l` today gets the larger number and should not read
the difference as an error.

**Already decided, and this finding reopens none of it.** An index: declined
twice, `REPO-AUDIT` `G9` and `A1` in this file. Moving a menu: refused for
`BOOK-INGEST-AUDIT.md` in `## Where a new menu goes`, on the ground that its
paths are cited from other menus, from skills and from the memory store, and
*"a move breaks citations no grep of this repo reaches."* **That reason
generalises to all seventeen**, so a proposal to archive or relocate starts from
behind. This one does not make it.

**The cost of them staying, measured rather than asserted**, 2026-09-04 **at
`2eed604`** — re-running them after this PR returns 29/11 and 9/7, because this
finding's own text contains both search terms:

| a real lookup | `.md` files hit | of which menus |
|---|---|---|
| `grep -rl "schema-change" --include="*.md"` | 28 | 10 |
| `grep -rl "line ending" --include="*.md"` | 8 | 6 |

**And the second row does not mean what it looks like.** Three of those six
menu hits are `SKILL-AUDIT` `F33`, `F35` and `F37`, filed and taken on
2026-09-04 — live, not residue. **The noise is real and it is smaller than the
raw ratio suggests**, which is stated here because the tempting version of this
number would justify a bigger proposal than the evidence supports.

**So the likely correct answer is that closed menus stay exactly where they are,
permanently. The finding is that nothing says so.** An absent decision and a
deliberate one are indistinguishable in the tree — which is precisely the
argument `A4` made about `HEALTH-AUDIT`'s missing status header, and it was
worth a paragraph there.

**Proposal:** one short section in `.claude/skills/audit-menu/SKILL.md` beside
*Where a new menu goes*, recording where a closed menu goes — **nowhere; it
stays** — and why: the citation surface above, plus the fact that a closed menu
is still the only record of what was decided and why. Name the two things
already declined so they are not re-derived.

**Posture: documentation only, one section, and it decides in favour of the
status quo. NO file moved, no `archive/` directory, no index, no count of menus
in the rule.**

**Evidence:** the eleven `## ` sections of `audit-menu/SKILL.md` read in full,
2026-09-04; `wc -l` over the menu glob plus `SETUP-v2-CHANGES.md`, 2026-09-04;
the two `grep -rl` lookups above with their hits classified by hand,
2026-09-04; `G9` and `A1` read in this file and `## Where a new menu goes` read
in the skill, 2026-09-04.

**Confidence: high that the gap exists** — it was established by reading the
section list, not by grepping for a phrase. **Low on whether recording it earns
a section.** **What would raise it:** one instance of a reader treating a closed
menu as live guidance. Nothing on this machine records one, and this finding
does not claim otherwise.

**Ongoing cost: zero once written**, since the decision it records is *do
nothing*. **And this finding recommends weighing a decline seriously.** Its
impact is one paragraph preventing a re-derivation that has not yet happened;
`audit-menu` is already 688 lines, and `SHIP-PR-AUDIT` `F11` was declined on the
ground that the file nobody has read cold should not grow. If it is declined,
the decline itself answers the question and should be recorded here.

**Taken, 2026-09-04 (PR #702), on Nate's instruction to take all three. Posture
held: documentation only, one section, status quo, no file moved, no `archive/`
directory, no index, and NO count of menus in the rule.**

**The premise audit recommended DECLINING this finding, and that recommendation
was overridden rather than answered.** Recorded plainly because reversing it
costs one PR and the case is on this page. What the audit found:

**1. The decision is not absent, which is the finding's central claim.**
`docs/prompts/meta-audit-prompt.md` → *Posture, fixed by Nate*, 2026-09-03:
*"Move nothing, merge nothing, rename nothing. Do not propose archiving closed
menus into `docs/audits/`."* One `grep -rn "closed menu" docs/prompts/` reaches
it. So *"an absent decision and a deliberate one are indistinguishable in the
tree"* is **false as written** — the decision existed, in a brief.

**This changed the implementation and improved it.** The section now *records
Nate's decision and cites it* rather than inventing a rule, which makes it the
same shape as `A4`: a defensible decision that lived only where a reader of the
skill would never meet it. **That is a better finding than the one filed**, and
it is the reason the override is defensible at all.

**2. The `line ending` evidence inverts the conclusion it was used for.** This
finding says *"Three of those six menu hits are `SKILL-AUDIT` `F33`, `F35` and
`F37` … live, not residue"* and concludes *"the noise is real and it is smaller
than the raw ratio suggests"*. <!-- claim-ok: quoting the sentences this note corrects -->
`grep -n "line ending" SKILL-AUDIT.md`, run 2026-09-04, returns **two lines in
one file** — `:3120` inside `F33` and `:3474` inside `F37`. `F35` is **not a hit
at all**; only its heading carries the hyphenated *line-ending*, which the search
string does not match. Three findings in one file are **one** of the six menu
hits, not three. **Five of six are residue and one is live, so the noise is
larger than stated, not smaller.** The finding's only quantitative support for
its own conservatism cut the other way.

**3. Every scale figure is wrong, and the evidence line describes a method that
does not produce the number.** *"19 menus, 27,952 lines … (`wc -l` over the glob
plus `SETUP-v2-CHANGES.md`)"* <!-- claim-ok: quoting the figures this note corrects -->
— 27,952 is the glob **without** `SETUP-v2-CHANGES.md`, the one menu the glob
cannot see and which this file's own `## Baseline` names. Correct at `2eed604`:
**20 menus, 28,178 lines, 18 of 20 closed.** At HEAD today: 28,588. The
before/after pair was measured over two different file sets, inflating the stated
growth by 226 lines. **The title of this finding is wrong by one and stays as
written**, per the rule that a record is not rewritten.

**4. The central claims are the brief's, restated as this session's own
measurements.** `docs/prompts/protocol-retrospective-prompt.md` → *Question 3*
already carried the absence claim, the 27,952, the *"17 of 19"*, both prior
declines, the `BOOK-INGEST-AUDIT` quotation, the `A4` parallel and the remedy.
The skill offers **reported by `<file>`** for exactly this and the evidence line
did not use it. **The off-by-one in (3) was inherited**: the brief's baseline
reads *"19 (+ `SETUP-v2-CHANGES.md`, a menu by every property but its
filename)"* and this finding kept the 19 and dropped the parenthetical.

**5. A third already-decided item was dropped from the brief and is now in the
section.** The brief said *"Retirement sections within a menu are already a
documented trap … Do not propose more of those."* This finding did not carry it
forward; the shipped section names it alongside the index and Nate's posture.

**6. `audit-menu` is 705 lines, not 688** — `A14` took it there hours earlier.
The decline argument was understated in its own favour.

**Why it was taken anyway.** Nate named all three findings on this menu in one
instruction. The override is his and is recorded as his. **The honest state is
that the strongest reason to take it survived the audit** — a decision reachable
only from a brief is invisible to a reader of the skill — while the supporting
evidence around it did not.

**No count went into the section**, which is the posture holding and also the
thing that keeps the off-by-one in (3) out of the skill, next to a rule that
already says *"No count belongs in this rule, and that is deliberate."*

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

### A16 — medium — a finding may hand work to "a separate finding" without filing one, and three such deferrals are still standing

A finding that scopes part of its subject out often names the remainder as *"a
separate finding"*, *"its own finding"* or *"a separate PR"* — and then nothing
files one. The work is real, measured and written down, and it is invisible to
every reader afterwards, because the menu's status lives under numbered findings
and this work has no number.

**This shape has been caught twice already, each time as a single instance, and
neither pass proposed a general remedy.**

- `META-AUDIT` `A5` — `SETUP-v2-CHANGES` recorded a live defect as *"filed for a
  separate PR"*; it was never filed. It got a number a day later as
  `pick3cut5/AUDIT` `F11`, and filing it immediately opened `F12`, a worse gap
  neither `A5` nor `F11` had seen.
- `SKILL-AUDIT` `F32` — `REPO-AUDIT` `G8` deferred `regression.mjs` in CI to
  *"its own finding, once this workflow has a track record"*; the condition was
  met and no such finding existed. Taken as #686.

**Three more are standing today, and all three are still true.** Measured
2026-09-06 at `c54a794`:

| where | the deferred work | still true? |
|---|---|---|
| `UI-AUDIT` `F24` | *"Fixing the `h2`→`h4` jumps inside `app.js`/`catalog.js` is a **separate** finding"*, and its outcome note adds *"That is the separate finding this one names, and it is still open."* | **yes** — `grep -co '<h2' sheet.js` = **0** with 11 `<h3>`, so the sheet runs `H1→H3`; `catalog.js` is `h2:0 h3:0 h4:4`, so the catalog runs `H1→H4`. Exactly the two the note names. |
| `UI-AUDIT` `F16` | *"`prefers-reduced-motion` was **not** taken — it is a separate item and stays open."* | **yes** — `grep -rn "prefers-reduced-motion" apps/character-creator shared` returns **0**. `apps/pick3cut5/styles.css` has it, which is the comparison `F16`'s own heading draws. |
| `INGESTION-AUDIT` `F6`/`F18` | *"Its 105 page-less rows need their own finding"*, restated as *"are a different finding"*, and again in the retirement table as *"still in the catalog and still page-less"*. | **yes** — production carries **108** skills whose `source_book` holds no `p.` citation (`node scripts/q.mjs --remote`, 2026-09-06). See the note on this number below. |

**The number 108 is corroboration, not a re-measurement.** `INGESTION-AUDIT`'s
figure is **105, split 93/5/4/3 across four books**, on a predicate this pass did
not reproduce; 108 comes from my own `NOT LIKE '%p.%'` test. The two are not the
same question and the difference is not evidence of drift. What the query
establishes is only that the rows are still there in quantity.

**Nothing anywhere names any of the three.** A tree-wide search of every `.md`
outside `docs/prompts/` for `prefers-reduced-motion` or *heading order* returns
`UI-AUDIT.md` and `pick3cut5/AUDIT.md` and nothing else — and `pick3cut5`'s
mentions are about its own app, which **has** the rule. `page-less` returns only
`INGESTION-AUDIT` and one unrelated `CLASS-AUDIT` line.

**All three sit on menus whose headers are correct.** `UI-AUDIT` says *"Nothing
is open"*; `INGESTION-AUDIT` says *"Nothing is open on this menu."* Both are
true, and that is the point: **unnumbered work cannot be open, because open is a
property of findings.** The header rule `A13` shipped is working exactly as
designed and cannot reach this.

**Proposal.** One short section in `.claude/skills/audit-menu/SKILL.md`, beside
*When not to*: **when a finding scopes work out to a future finding, file that
finding in the same PR and cite it by number, or say in so many words that the
work is being dropped.** A number costs a heading and a paragraph; it does not
oblige anyone to take it, which is the whole reason the numbering exists. The
alternative wording — *"do not write 'a separate finding' without a number"* —
is the same rule stated as a prohibition and is worse, because the useful half
is the filing, not the abstention.

**Posture: documentation only, one section in one skill. No check, no script, no
retrofit of the two closed instances, and no index of deferrals.** A check is
ruled out for the reason the whole skill gives; an index is declined three times
over. **And this proposal does not file the three standing items** — each is a
finding on its own menu and belongs to Nate's word, not to this pass.

**Decline it** if the judgement is that a deferral without a number is a healthy
way to record a suspicion cheaply, which is a real argument the skill makes about
filing elsewhere. The cost of declining is stated above: three pieces of measured
work are currently reachable only by reading the interior of a closed finding.

**Evidence.** The three rows measured 2026-09-06 with the commands quoted in
them, at `c54a794`; the two prior instances read in `META-AUDIT` `A5` and
`SKILL-AUDIT` `F32` the same day; the negative search for an existing rule run
over `.claude/`, `CLAUDE.md`, every menu, `SETUP.md` and
`~/.claude/projects/C--Users-natha-Downloads/memory/` — **nothing proposes
numbering a deferral.**

**Confidence: high** that the three are unfiled and still true — each is a
filesystem or database fact re-measured today, and the negative search was run
over the whole corpus rather than the menus alone. **Medium** on whether a rule
changes behaviour: `A5` and `F32` were both caught by later passes without one,
so the existing machinery does eventually find these. What would raise it: a
count of how long each stood before being caught. `G8`'s stood from 2026-09-03
to 2026-09-04; `SETUP-v2`'s stood a day; `UI-AUDIT` `F16`'s has stood since
2026-08-31 — **six days and counting**, which is the only one of the five that
suggests the catch is not reliable.

**Ongoing cost:** one heading and one paragraph per deferral, forever, on the
findings that defer. Most findings defer nothing.

### A17 — medium — the sweep that catches a stale cross-finding claim is defeated by the prefix ambiguity this repo has already measured, and three claims are stale behind it

`audit-menu` → *It is not only class notes. ANYTHING that cites a finding goes
stale* names four kinds of citer and says a script covers exactly one. Its
remedy for the other three is explicit: **when a finding is taken, grep the whole
tree for its number.** `## Which is why a finding reference names its menu`
records why that is hard — `F` is used by twelve menus and 75% of findings live
under an ambiguous ID — and mitigates it by asking that a citation name its menu.

**The two sections are each correct and together they do not work, because a
finding's own body cites its neighbours by bare number and is right to.** The
skill says so: *"Inside its own file a bare number is right and should stay."*
So the citations most likely to go stale are precisely the ones the naming
convention exempts, and the grep that is supposed to catch them cannot tell them
from twelve menus' history.

**Measured 2026-09-06 across the 21 menus:**

| a taker greps the tree for | hits | menus |
|---|---|---|
| `F15` | **46** | 8 |
| `F12` | **90** | 11 |
| `F3` | **126** | 15 |

A taker of `REBUILD-AUDIT` `F15` who follows the rule reads 46 lines to find the
one that matters. **They did not**, and here is what is behind it.

**Three stale claims, in three different structural positions:**

- **An outcome note.** `REBUILD-AUDIT` `F13` ends *"That is F15 and it is not
  taken."* `F15` was taken the **same day** — `F13` shipped as #381, `F15` as
  #391, both 2026-08-28.
- **An outcome note, where the file's own header was corrected and the note was
  not.** `BOOK-INGEST-AUDIT` `F12`'s note says four passages describe limits that
  are still real *"whose `gear` has no shape for a vessel remains true because
  F3's schema half is still open."* `F3`'s schema half **closed 2026-09-03 in PR
  #616**, and this file's header says so in its second sentence. `META-AUDIT`
  `A3` is the finding that corrected that header; it did not reach the note.
  **The header and a finding in the same file now disagree about `F3`.**
- **A section lead.** `SHIP-PR-AUDIT:739`, opening *Opened while taking a
  finding*: *"**None of these is taken.** Nothing below has been decided."*
  `F12`, `F13` and `F14` below it carry Taken notes — #672, #670, #671, all
  2026-09-04 — and `F11` is declined. Four findings, none of them undecided.

**`A13` cannot reach any of the three, and that is the finding.** It governs what
a **status header** may carry and says so; an outcome note and a `##` section
lead are neither. The three positions above are the header rule's blind side, and
the tree-wide grep is the only thing pointed at them.

**Proposal.** Extend the existing sentence rather than adding a mechanism: in
`audit-menu` → *It is not only class notes*, say that **the grep is run per menu,
not per tree** — `grep -n 'F15' apps/character-creator/REBUILD-AUDIT.md` is one
file and a handful of lines, and it is where a bare number is unambiguous by the
skill's own rule. The tree-wide sweep stays for the qualified citations it was
written for.

**Posture: documentation only, one clause in one existing section. No check, no
script, no retrofit.** The three stale sentences above are **records** and stay
exactly as they are — `audit-menu` is explicit that a measurement is not
rewritten, and two of the three are useful precisely because they show the
failure. A correction, if Nate wants one, is a dated line appended under each
finding, and it is a separate decision on each of three menus.

**Decline it** if one grep per menu reads as re-stating what a careful person
already does. The counter-argument is the measurement: three claims stale, in
three different positions, in a corpus that has audited its own headers twice.

**Evidence.** Hit counts from `grep -c` over the 21-menu list, 2026-09-06. The
three stale claims read under their own headings the same day and each checked
against the merge that falsified it — `#391` (`gh pr view`), `#616` (named in
`BOOK-INGEST-AUDIT`'s own header), `#670`–`#672` (`grep -nE '^\*\*(Taken|Declined)'`
over `SHIP-PR-AUDIT.md`, four notes below the sentence). The skill's two sections
read at `:290` and `:395` on 2026-09-06.

**Confidence: high** on all three being stale — each is a two-command check.
**Medium** on the remedy, because a per-menu grep is a discipline and this page
is full of disciplines that do not fire. What would raise it: whether any of the
three cost a wrong action rather than a slow read. **None did**, as far as this
pass can tell, and that is stated rather than left implied.

**Ongoing cost:** none. It replaces one grep with a narrower one.

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
