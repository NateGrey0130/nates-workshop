# Instruction-layer audit — the skills, the agent, CLAUDE.md, memory and settings, 2026-09-02

> **`F41` AND `F42` ARE OPEN**, filed 2026-09-04 under the existing
> **`## Opened while closing out 2026-09-04`**. **`F42` partly reverses `F40`**
> and says so — `F40` fixed a false arrangement sentence and recorded that
> *deleting* it was the better fix it was not scoped to make. `F40` taken 2026-09-04 (PR #698) — `audit-menu`'s shape
> table row for this file described an arrangement it no longer has, and now
> carries no count of sections, deliberately. It sits under the existing
> **`## Opened while closing out 2026-09-04`**, not an eighth placement, since
> `F39` was closed on the argument that the existing ones stand.
> `F38` taken 2026-09-04 (PR #695) — every `###` heading in
> this file is now a finding, which is more than `F38` asked for. **`F39` closed
> without being taken** (PR #696), agreeing with its own recommendation and
> recorded so it is not re-proposed. `F37` is **filed WITH its outcome**, all
> 2026-09-04
> under **`## Opened while closing out 2026-09-04`**, a seventh placement. `F37`
> carries its outcome because the file it corrects is **outside this repo** and
> no pull request could take it. **`F39` recommends declining itself** and exists
> so the idea is not re-derived. **`F35` was taken 2026-09-04 (PR #693)** — subtractive, one
> clause, and **four of its own premises were wrong**; read its note before
> citing it. **`F36` was taken 2026-09-04 (PR #692)** — it removed the path
> filter `F32` had added hours earlier, because the number justifying that filter
> was measured on the wrong machine. Both were filed 2026-09-04 under
> **`## Opened while taking F33`** and **`## Opened by F32's own CI run`** — a
> **fifth and sixth** placement on this page, which is past the point where the
> arrangement helps anyone and is worth a finding of its own. **`F33` and `F34` were taken 2026-09-04**
> (PRs #689, #688). `F33`'s note records four other places carrying the same
> falsehood, left unfixed because its posture was one sentence in one skill;
> `F35` is the one that matters, and it is **subtractive** — read its note before
> proposing anything additive there. Filed 2026-09-04 under
> **`## Opened while taking F29 to F32`** — a **fourth** placement on this page,
> after the `N` block, `## Opened while building the verifier agents` and
> `## Opened by taking F28`. **`F29`–`F32` were all taken 2026-09-04** (PRs
> #682, #684, #685, #686). `F30` was scoped **wider than filed** and its own
> proposal was wrong about the mechanism; `F32` added a **path-filtered** CI job, where a
> green pull request outside those paths means the suite was never asked. Read
> both notes rather than this line. Filed
> 2026-09-04 under **`## Opened by taking F28`**,
> which is a third placement on this page — after the `N` block and after
> `## Opened while building the verifier agents`. They are the four things
> `F28`'s runs turned up, which its own posture forbade it from fixing.
> `F26`–`F28` are all taken. `F26` taken (PR #679) after its
> mechanism test ran first and moved it to high confidence; `F27` taken (PR
> #680), scoped to one agent, and **verified 2026-09-04 (PR #683)** — the
> verification was owed a day because a swapped agent cannot be spawned in the
> session that changed it, which is `F26` catching the work that followed it.
> **`F28` was taken 2026-09-04 (PR #678)** — all four
> agents run, all four kept, and its note carries four separate things the runs
> turned up that are **not** fixed there and need their own findings. Filed
> 2026-09-04. Everything from the original pass
> is closed: 25 `F` findings and all 8 `N` proposals, 2026-09-02, PRs
> #540–#569. The three new ones sit under **`## Opened while building the
> verifier agents`**, after the `N` block and before `# Counts` — *not* under
> `## Opened while taking a finding`, because no finding was being taken; they
> came out of PR #676. **Read each finding's own note; this header is a summary
> and summaries here go stale.**
>
> | | |
> |---|---|
> | `F1`–`F8`, `F10`–`F25` | taken |
> | `F9` | **closed without being taken** — measured, and its own instruction said to close rather than weaken |
> | `F12` | documentation taken, the prune **completed** (#571), and the named test **RUN 2026-09-03** (#656) — each directory is governed by its own project settings, which do not compose |
> | `F25` | part (a) taken; part (b) **closed by decision** — the `z`-tiers stay |
> | `N1`–`N3` | written: `verify-ui`, `windows-shell`, `pick3cut5` |
> | `N4`–`N8` | **declined**, each on its own stated condition |
>
> `F22`–`F23` were opened by taking `F1`, `F24` by a stalled deploy while taking
> `F2`, and `F25` by taking `F4`. `F` numbers are findings about instructions
> that exist; `N` numbers are new-skill proposals. `###`, em dash, no severity
> word.
>
> **The one that misreads:** `F22`–`F25` sit under their own
> `## Opened while taking a finding` heading **between `F21` and the `N`
> section**, not in numeric order after `F21`. A reader walking the file top to
> bottom meets them after the cross-layer pair and may take them for proposals.
> `F24` there is a different finding from `HEALTH-AUDIT.md`'s `F24`, filed the
> same hour about the same incident — this one is about what the instruction
> layer says can reach Pages, that one about the stalled build itself.
>
> **The trap this file sets for its own reader:** filing it makes a **fifteenth**
> findings menu, which falsifies `F7` — the finding that corrects `audit-menu`'s
> file table — the moment this file is committed. Take `F7` as written and the
> table is wrong again, about this file, on the day it ships. `F7`'s proposal
> says so and names the row; read it before implementing the correction it asks
> for.
>
> **The second half.** Not one finding here is about code. Every one is about a
> sentence, and sentences are the fastest-moving thing in this repo: four of the
> six skills were edited on **2026-09-02**, the date at the top of this file, and
> `ship-pr` was edited at 08:58 against a brief written at 09:25. The
> `audit-menu` rule *taking a finding is also auditing the finding* is therefore
> not a formality here — it costs one grep and it is never optional. Six of the
> twenty-one below were found by disbelieving a sentence that had been true when
> it was written.

Read-only. Nothing outside this file was changed; no skill, memory file,
`CLAUDE.md`, `settings.json` or `launch.json` was edited, and no PR was opened.

## Scope, and the layer the prompt did not list

The brief named five layers. There are **six**. `docs/prompts/` — fifteen briefs
and a README, added 2026-09-02 as `HEALTH-AUDIT.md` F3 (PR #527) — is a standing
instruction surface by every property except that nobody calls it one: at least
one of its files (`BOOK-INGEST-PROMPT.md`, which is *not* in it, see `F18`) is a
reusable per-book template that a session is meant to run verbatim, and it
overlaps `book-survey` directly. It is treated as a layer throughout.

| # | layer | what it is | measured 2026-09-02 |
|---|---|---|---|
| 1 | `.claude/skills/` | six skills, four reference files | 2,475 lines, 122KB |
| 2 | `.claude/agents/` | `book-reconcile` | 98 lines |
| 3 | `CLAUDE.md` | repo root; **there is no nested one** — `find . -name CLAUDE.md` returns exactly one | 186 lines |
| 4 | memory | 60 files + `MEMORY.md` | 60 index lines, 60 files, no orphans either way |
| 5 | `.claude/settings.json`, `.claude/launch.json` | 39 allow entries; 3 launch configs | — |
| 6 | `docs/prompts/` | 15 briefs + README | not in the brief's scope |

## Evidence, and which finding came from which

Four sources, as the brief asked. Every finding names its own.

- **Live repo state** — a `claim-audit` pass run against the skills themselves:
  every path, filename, command and count in a `SKILL.md` checked against the
  tree at `main` @ `3c4bcc5`. Produced `F1`–`F9`, `F12`, `F13`, `F20`, `F21`.
- **Git history and the closed menus** — all fourteen, including
  `SETUP-v2-CHANGES.md`; outcome notes read under their headings, never grepped.
  Produced `F7`, `F10`, `F11`, `F19`.
- **The memory files** — all 60 read or skimmed, cross-checked against the repo
  and against `MEMORY.md`. Produced `F14`–`F17`, and half of `F1` and `F6`.
- **Session transcripts** — 81 `.jsonl` files, 573MB, parsed by script to the
  **1,041 messages a human actually typed** (`type: "user"`, string content, not
  meta, under 3,000 chars — which excludes compaction summaries, skill
  injections and tool results, all of which are logged as `user` and swamp a
  naive grep 4:1). Produced `F11`, and corroborated `F16`.

## What contradicts the premises of the prompt

**1. `~/.claude/skills/` is not a copy. It cannot diverge.**

The brief says it "holds a byte-identical copy of all six skills, and nothing
keeps the two in sync", and asks whether they have ever diverged. They are not
copies. `dir /AL C:\Users\natha\.claude\skills` reports all six as `<JUNCTION>`
pointing into `C:\Users\natha\Projects\nates-apps\.claude\skills\<name>`, dated
2026-08-25 for five of them and 2026-08-28 for `audit-menu`. `~/.claude/agents`
is a single `<JUNCTION>` on the whole directory. There is one set of bytes on
disk; `diff -rq` across all six reports no differences because there is nothing
to differ. `CLAUDE.md` describes this correctly and the brief's note does not.
**No finding.** The gap the brief expected to find here is real, but it is
`F11` — a *different* file, in the other direction.

**2. "Five layers" is six.** See *Scope* above, and `F18`.

**3. The uncovered ground is not evenly uncovered.** The brief lists
media-vault, filament-forge and pick3cut5 together as three apps with no skill.
The evidence does not treat them alike: pick3cut5 has produced a recurring,
production-visible trap with its own memory and two findings across two menus
(`REDESIGN-AUDIT` N6, `HEALTH-AUDIT` F15), while media-vault and filament-forge
have been quiet since their standardizations closed on 2026-08-26. `N4` ranks
them accordingly rather than proposing three skills.

---

# Findings

## Layer 1 — the six skills and their reference files

### F1 — `frontmatter.md` says it is exhaustive, it is not, and the correction lives only in memory — where it asserts a disclaimer the file does not carry

`.claude/skills/class-import/reference/frontmatter.md:3` opens:

> Every top-level key the app reads. Anything else parses and is then ignored by
> everything — `class-check` reports it as `UNMODELLED`.

Measured against the tree on 2026-09-02, five keys the app reads are absent from
that file entirely — `spells_per_level`, `spells_per_level_levels`,
`spells_schedule`, `powers_per_level`, `spells_starting_groups` — each of them
read by `apps/character-creator/js/leveling.js`, three also by `js/parser.js`.
Two more (`powers_starting_groups`, `powers_schedule`) appear exactly once each,
inside a paragraph about race/occupation merging, and never in the `## Powers`
YAML block a transcriber copies from. That block shows five `psionics` keys and
four `magic` keys.

The `bonuses` block is the same shape. `frontmatter.md:261-262` shows
`combat: { attacks, strike, parry, dodge, initiative }` and
`saves: { spell_magic, psionics, horror_factor }` as closed inline maps.
`js/derive.js` also reads `mind_control`, `possession`, `coma_death`,
`pull_punch`, `perception` and `ritual_magic`, among others. The parent
`SKILL.md:313` **already knows this** — *"`combat` and `saves` are open sets, so
a new key there costs nothing"* — so the two files of one skill disagree, and the
one a session opens while writing a class is the one that is wrong.

**This has shipped bugs twice.** The memory
`saves-and-combat-are-open-sets.md` (2026-08-31) records both Phase World noro
O.C.C.s going live without the mind-control save their book prints, then two
batches later a psionic schedule that denied the psychic its Super power at every
level, stopped both schedules at level 3 where the book says *"third level and
beyond"*, and let the mystic warrior take eight Super powers where the book
grants two. Fixed by `fix-noro-mind-control-saves.sql` (PR #410) and
`fix-noro-psionic-schedules.sql` (PR #411). Every one of those was preceded by an
`extraction_notes` line asserting the app could not express it. Nothing failed:
the classes parsed, validated, composed and passed 210 regression checks.

**And the memory's own first line is wrong in the way that matters.** It says
*"`frontmatter.md` is a **tour, not a schema**. It says so."* It does not say so.
`grep -iE "tour|not a schema|leveling|exhaustive|not the whole|open set"` over
that file returns nothing. The lesson was written down in the layer that fires by
relevance, asserting that the fix had already landed in the layer that fires by
name — and it never landed.

**Proposal.** Rewrite `frontmatter.md`'s opening two sentences to say what the
file is: the keys worth documenting, with `js/parser.js`, `js/derive.js` and
above all `js/leveling.js` named as the contract. Add the six-plus missing
level/schedule keys to `## Powers` with their real shapes — a `powers_schedule`
entry carrying its own `categories` / `spell_levels` / `note`, and the fact that
those **override** the class-wide gate rather than narrowing it. Add one line
under `## Bonuses` saying `combat` and `saves` are open sets and where to read
the current members. Then delete the false sentence from
`saves-and-combat-are-open-sets.md` and leave the memory as the record of the two
PRs, per `F16`'s pattern.

**Posture:** rewrite the reference; **no new gate.** A check that
`frontmatter.md` names every key `leveling.js` reads is the obvious next step and
is deliberately not proposed — the file is a teaching document, not a schema
dump, and pinning it would force every new key into prose whether it earns a
paragraph or not.

**Evidence.** Live repo state (grep of `js/` and `functions/` against the
reference, 2026-09-02) plus the memory layer.

**Taken, 2026-09-02 (PR #541).** Posture as proposed: the reference rewritten,
**no new gate.** Four corrections to the finding's own premises, and the third
inverts a line the proposal asked for.

1. **`powers_per_level` is not absent.** It sits at `frontmatter.md:239`, in the
   race/occupation merge paragraph. Three keys live only in that paragraph and
   never in the `## Powers` block a transcriber copies from:
   `powers_per_level`, `powers_starting_groups`, `powers_schedule`.
2. **Three keys the finding did not list are missing** — `spells_from`,
   `spells_per_level_from` and `spell_lists`. Asked of production rather than
   counted off the file: 160 published classes use **nine** `psionics` keys and
   **eleven** `magic` keys, exactly what `mergePsionics` and `mergeMagic` state
   in their own comments. The reference showed five and four.
3. **"`combat` and `saves` are open sets" is true of the validator and FALSE of
   the sheet — so the proposal's "add one line saying they are open sets" would
   have shipped the bug it was written to prevent.** `validateBonuses` checks
   group names, not the keys inside them, and `addBonus` adds any finite number
   under any key; but `sheet.js` draws `SAVE_FIELDS` (sixteen) and
   `COMBAT_FIELDS` (nineteen) as literal lists, so an invented key parses,
   validates, composes and renders **nowhere**. `vacuum-wasp`'s own
   `extraction_notes` says this correctly and was the only place in the repo
   that did. `class-import/SKILL.md`'s *"so a new key there costs nothing"* was
   corrected in the same PR: it is one skill's two files disagreeing, which is
   this finding's subject, but the proposal did not name that line.
4. **The spelling is `coma_death_pct`, not `coma_death`.** The finding and the
   memory both had it wrong. The suffix is load-bearing — it is what makes the
   sheet render a percentage and what excludes the row from `SAVE_ROLLS`.

**One alarm raised and killed.** A first pass reported `dogfighting` as a combat
key used in production that nothing reads — a live silent defect. It is not: it
sits inside a quoted `extraction_notes` string in `vacuum-wasp` explaining why
that bonus is **not** stored, and an inline-`{ }` regex read it as data. That is
`CLASS-AUDIT` F17's shape exactly, committed in the same week the protocol warns
about it. Re-checked with a strict frontmatter parse: every save key in
production is one of `SAVE_FIELDS`' sixteen and every combat key one of
`COMBAT_FIELDS`' nineteen, except `attacks_base`, which is deliberately
special-cased in `parser.js` and stripped in `derive.js`. **Nothing in the live
catalog is silently dropped.**

Shipped: `frontmatter.md`'s opening rewritten to name `parser.js`, `derive.js`
and `leveling.js` as the contract and to state the rule in both directions; a
`## Powers` subsection carrying the two blocks' symmetric key table and the
schedule entry's own shape — `level`, `count`, `from` / `from_list`,
`spell_levels` / `categories`, `note` — including that an entry OVERRIDES rather
than narrows and that a level-1 entry does not fire at creation; a `## Bonuses`
subsection on the validator/sheet split, `saves.other`, `attribute_minimums` and
`attacks_base`; the `SKILL.md` line corrected; and the false sentence removed
from `saves-and-combat-are-open-sets.md`.

**Two further findings opened by taking this one:** `F22` and `F23`.

---

### F2 — `claim-audit`'s find-them command was written the day before the README split, and now misses 60% of what it hunts

`claim-audit/SKILL.md:56-58` gives one command for finding stale prose:

```bash
grep -rn "currently\|does not\|cannot\|has no\|is not modelled\|not modeled" \
  apps/character-creator/README.md apps/character-creator/js/ | head -60
```

Run verbatim on 2026-09-02 it returns **137** hits. The same pattern over
`apps/character-creator/docs/*.md` — thirteen files, 5,633 lines, which the
command does not look at — returns **205**. Over `functions/`, also not looked
at, another **104**. The skill's own search sees 137 of 446.

The cause is dated. `claim-audit` was last edited **2026-08-25** (`38a88aa`).
The README was split into a spine plus topic files under `docs/` on
**2026-08-26** (PR #309, `EFFICIENCY-AUDIT` F4). The skill has not been touched
since the day before the thing it searches moved.

The sharpest instance: `apps/character-creator/docs/known-limitations.md`, 414
lines, 18 hits — a file whose *name* is the exact shape `claim-audit` exists to
audit (*"the app cannot do X", true on the day, and nobody goes back when X is
built*) — is invisible to the skill that hunts them.

**Proposal.** Extend the command to `apps/character-creator/README.md
apps/character-creator/docs/ apps/character-creator/js/ functions/`, and add one
sentence to the *Where the claims live* table naming `docs/` as thirteen files
holding more limitation prose than the README does. Do **not** quote the 137 /
205 / 104 split in the skill — write "most of it now lives under `docs/`" and let
the command answer, per this skill's own rule against counts in prose.

**Posture:** rewrite one command and one table row. **Documentation only.**

**Evidence.** Live repo state, 2026-09-02, plus `git log -1` on the skill.

**Taken, 2026-09-02 (PR #542).** Posture as proposed: one command, one table row,
**documentation only**, and no count quoted in the skill. Every premise re-checked
and every one held — 137 in scope, 205 in `docs/`, 104 in `functions/`;
`known-limitations.md` 414 lines and 18 hits; `claim-audit` last edited
2026-08-25 (`38a88aa`) and PR #309 merged 2026-08-26T14:41Z.

**One correction, in the finding's favour.** The proposal says *"naming `docs/`
as thirteen files"*. Thirteen is right today; the split created **eleven**, and
two arrived later. Both numbers are in the skill's own no-quoted-counts scope, so
the shipped row names neither — it says *"more limitation prose than the
README"*, which is the fact that does not move. The dated sentence below it cites
eleven at the split and thirteen now, as a measurement rather than a claim about
the present.

**One thing added that the proposal did not ask for**, because writing the
command without it would have been writing a new false sentence: the paragraph on
`readme-section.mjs` now says it indexes `docs/` as well as the README. That was
verified by running it against a `docs/`-only heading rather than assumed —
`node scripts/readme-section.mjs "Retired keys keep resolving"` returns
`apps/character-creator/docs/catalog.md lines 369-411`, exit 0.

Shipped: the grep takes all four paths with a line saying dropping one is not a
narrower search but a search that misses most of the corpus; a `docs/*.md` row in
*Where the claims live*; `functions/` added to the code-comments row; and the
README row relabelled from *"the largest doc by far"* — which stopped being true
at the split — to *"the spine"*.

---

### F3 — `claim-audit` opens by calling the README 4,600 lines; it is 973

`claim-audit/SKILL.md:8` — *"This repo explains itself unusually well, and that
is the hazard. A 4,600-line README..."*. `wc -l apps/character-creator/README.md`
on 2026-09-02: **973**.

The skill already fixed this once and fixed the wrong copy. Lines 27-30 say the
*table* used to say "~4,600 lines" and "~190 sentences over 76 classes", that the
README "passed 5,600 lines", and that "a skill about stale claims that carries
stale claims is the worst possible advertisement" — so the number was pulled from
the table and left standing in the opening paragraph three lines above. Both
figures then went stale together at the split. The correction paragraph is now
also stale: it says the README passed 5,600 lines, which describes a file that no
longer exists in that form, and `EFFICIENCY-AUDIT.md` carries a dated banner
saying exactly that about its own measurements.

Line 159 has a third: *"Most of those 190 sentences are correct"*.

**Proposal.** Delete the number from line 8 — *"a README that explains itself,
comments that argue their case"* carries the whole argument. Update the
correction paragraph to a dated note that the file was split (PR #309,
2026-08-26) rather than to a new line count, and drop "190" from line 159.
Three edits, no new numbers introduced.

**Posture:** delete three counts. **Documentation only.**

**Evidence.** Live repo state, 2026-09-02.

**Taken, 2026-09-02 (PR #545).** Posture as proposed, and **one premise of the
finding was wrong in the skill's favour.**

The finding says *"The correction paragraph is now also stale: it says the README
passed 5,600 lines, which describes a file that no longer exists in that form."*
**It is not stale.** *"The README passed 5,600 lines"* is past tense — a
threshold that was crossed, and it was. That is a **measurement**, which is
exactly the category `F21` argues survives; only present-tense claims rot. The
same goes for *"the catalog passed 88 classes"*, which is true and now sits
beside a live figure of 160. So two of the finding's three targets were one
target, and the third — line 173's *"those 190 sentences"* — was correctly
identified. The paragraph gained a date rather than an edit.

**What the file actually shows is better than the finding claimed.** The numbers
were removed from the table *and left standing three lines above it and again at
the bottom* — the fix was applied where the number had been noticed rather than
to the file. That is the transferable lesson and it is now written down, along
with the instruction to grep the whole file for a number being deleted.

**One thing caught while writing it.** The first draft of that new paragraph
quoted both stale strings verbatim to explain them — which is precisely
`audit-menu`'s *"never quote the stale phrase you replace: a note repeating the
old wording defeats a grep for it."* It would have made the file unsearchable for
the next copy while claiming to teach the opposite. Rewritten to describe the
numbers rather than restate them. Each stale string now appears **once** in the
file, inside the dated historical sentence that records what was removed.

Shipped: the opening sentence now says *"a README and thirteen topic files under
`docs/`"*; the measurement paragraph is dated to 2026-08-25 and gains the lesson
paragraph; *When not to* loses its count.

---

### F4 — `class-import` quotes two counts that have moved by 5.5× and 2×

Both are in passages whose argument does not depend on the number, which is why
neither has been noticed.

| line | says | measured 2026-09-02 | ratio |
|---|---|---|---|
| `SKILL.md:230` | *"Fifteen `fix-*.sql` / `apply-*.sql` scripts follow this shape"* | 77 `fix-` + 6 `apply-` = **83** | 5.5× |
| `SKILL.md:14` | *"It is 1100+ lines"* (`js/parser.js`) | **2,223** | 2× |

`1100+` is not false — but it is offered as the reason not to read the file, and
a reader who checks finds the reason twice as strong as stated, which is the
direction that erodes trust in the sentence. The `zz-` claim in the same section
is **correct**: 13 `zz-*.sql` files exist.

**Proposal.** Replace "Fifteen" with "Most corrections in
`apps/character-creator/db/` follow this shape" — the count does no work in that
sentence. Replace "1100+ lines" with "the largest file in the app". Neither
replacement can go stale.

**Posture:** delete two counts. **Documentation only.**

**Evidence.** Live repo state, 2026-09-02 (`ls | wc -l`, `wc -l`).

**Taken, 2026-09-02 (PR #546).** Posture as proposed. Both premises held —
`fix-` 77 plus `apply-` 6 against the stated fifteen, and `parser.js` at 2,223
lines against "1100+".

**Two of my own replacement sentences were false, and both were caught by
measuring instead of shipping.** This is worth recording because the finding's
whole subject is unverified counts, and writing the fix produced two more:

1. The first replacement read *"Most of the corrections … it is by far the
   commonest kind of file in that directory."* The prefix census says `add-` is
   **197** against `fix-`'s 77, so `fix-` is not the commonest by a factor of
   2.5 in the other direction.
2. The second read *"`backfill-`, `merge-`, `rename-` and `retire-` … follow the
   same guarded, idempotent rule."* Sampled six `backfill-` scripts and five
   carry no guard of that shape at all.

The shipped sentence asserts no population and no behaviour: it names the shape,
says `fix-` and `apply-` are the usual prefixes, and says the other four name
more specific jobs. *Describe the shape, not the value*, applied to the
replacement rather than only to the thing replaced.

Shipped: `parser.js` is now *"the largest file in the app"* with a clause
pointing at `F1`'s correction — read the parser rather than the reference when
modelling something new; and the correction-script sentence loses its count.

**One finding opened by taking this one:** `F25`. The prefix census that
falsified my own sentence also falsified one of the skill's, three paragraphs
below the one I was editing.

---

### F5 — `book-survey` says `pf` is the only book with a page-offset exception; `underseas` has one too

`book-survey/SKILL.md:194` — *"`pf` is the only book that has one."*

`scripts/books.json` on 2026-09-02 registers **two**:

```
pf         page_offset 2, exceptions [{ printed_through: 16, offset: 1 }]
underseas  page_offset -1, exceptions [{ printed_through: 130, offset: 0 }]
```

`BOOK-INGEST-QUEUE.md`'s own table has said `underseas … +0 / -1 split` since the
seven-book batch was cached on **2026-08-28** — the same day `book-survey` was
last edited (`2c95d54`). The claim was falsified by a book registered in the same
window, and the skill and the queue have disagreed ever since.

This is the shape `audit-menu` warns about under *An absence claim needs a fresh
read*: "X is the only one" is the same family as "X appears nowhere", and wrong
in the direction that makes the rule look simpler than it is. A session that
believes it will not look for an exception on `underseas`, whose split sits at
printed 130 — the middle of the book.

**Proposal.** Replace the sentence with *"Two books have one — `pf` and
`underseas`; ask `scripts/books.json`, not this file."* Keep the `pf` worked
example, which is what teaches the shape. Do not list `underseas`'s values; the
registry is the authority and this skill already says so eleven lines earlier.

**Posture:** rewrite one sentence. **Documentation only. No new gate** — the
smoke test already fails on a cache whose detected offset regions the registry
cannot resolve, which is the mechanical half.

**Evidence.** Live repo state (`scripts/books.json`, 2026-09-02) against the
skill and `BOOK-INGEST-QUEUE.md`.

**Adjusted 2026-09-02 (PR #564).** The same claim was still standing in
`reference/SURVEY.md`, the survey template, and was found four hours later by
`F9`'s prototype rather than by hand. This finding corrected the file it was
looking at and missed the other one in the same skill. Fixed there too.

**Taken, 2026-09-02 (PR #547).** Posture as proposed: one sentence, documentation
only, **no new gate** — the smoke test already fails on a cache whose detected
offset regions the registry cannot resolve, and that stays the mechanical half.

Premises held exactly. `scripts/books.json` registers two books with
`page_offset_exceptions`, `pf` and `underseas`; `book-survey` was last edited
`2c95d54` on 2026-08-28; and `BOOK-INGEST-QUEUE.md` has said `+0 / -1 split`
since the same day.

**One thing the finding understated.** It says the queue's table recorded the
split. The queue is more explicit than that — line 299 reads *"`underseas` is the
second split-offset book in the catalog, after `pf`"*, in prose, written on the
day the skill's sentence was last touched. The two files did not drift apart:
they **disagreed from the moment both were written**, which is a worse shape than
rot and is now what the skill's replacement sentence says.

**One deviation, corrected before shipping.** The first draft named the printed
page `underseas` splits at. The proposal says explicitly *"Do not list
`underseas`'s values; the registry is the authority"* — so the shipped sentence
says the split falls **in the middle of the book**, which is the part that
changes how you hunt for one, and sends the reader to the registry for the
number. The actionable contrast survives without the value.

---

### F6 — the zero-offset worked example names the one book that is not registered at zero, and states its number in a base the registry does not use

`book-survey/SKILL.md:212-215`:

> **A zero offset is the worst case, not the easiest.** Pantheons of the
> Megaverse has one — printed N is `d[N]` — so there is no real offset to hunt…

`scripts/books.json` registers `potm` at `page_offset: 1`, and
`.cache/books/potm/manifest.json` records the same. The survey at
`docs/surveys/potm.md:15` states it a third way and is the only one of the three
that names its base: *"`page_offset: 1` from `scripts/books.json` — cache file
page = printed folio + 1."* The memory `pantheons-of-the-megaverse-survey.md`
states it a fourth way: *"The printed-to-PDF offset is **ZERO**: printed page N
is pymupdf index N."*

**All four describe the same physical fact.** `d[N]` in 0-based pymupdf and
`p(N+1)` in the 1-based cache are the same page. Nothing here is a wrong number.
That is what makes it worth filing: this is the exact collision the section
**four paragraphs above it** exists to prevent —

> **And the two tools you verify it with disagree about what "page" means.**
> `read-columns.py` takes the number a PDF VIEWER shows — 1-based … while
> `pymupdf` in a probe script is 0-based.

— and the skill's own worked example is stated in the base the registry does not
use, in a section whose instruction is *read the offset from the registry*. A
reader who does what the skill says opens `books.json`, sees `1` where the skill
says `0`, and has no way to tell which is wrong without deriving it.

Meanwhile **three books are registered at zero** — `ww`, `triax`, `phase-world` —
and none is named. The memory `book-ingest-batch-protocol.md` already carries the
consequence (*"zero offset is now common"*); the skill still frames zero as the
exotic case.

**Proposal.** Rewrite the paragraph to name a book that is registered at zero
(`phase-world` is the best: it is imported, surveyed and its offset survived a
full 34-class extraction), state the value in the registry's base with the base
named — *"`page_offset: 0`, so the cache page IS the printed folio"* — and keep
the argument, which is right and is the reason the section exists. Then correct
`pantheons-of-the-megaverse-survey.md` to quote `page_offset: 1` and name its
base, per `F15`.

**Posture:** rewrite one paragraph, plus one memory correction. **Documentation
only.**

**Evidence.** Live repo state (`books.json`, the `potm` manifest, the survey)
against the skill and the memory layer, 2026-09-02.

**Taken, 2026-09-02 (PR #553).** Posture as proposed: rewrite the paragraph plus
one memory correction, **documentation only**. Premises held.

**The finding stopped one paragraph short.** It says the *prose* names a book in
the wrong base. The **table three lines below it did the same thing**, and that
was not noticed until the values were checked: its first row was labelled
*"zero-offset book"* and gave `d[16]`, which is the `potm` row — a book the
registry records at **1**. Every value in that table was right in a base the
registry does not use, so checking any of them against `books.json` produced a
contradiction with no way to resolve it. Fixing the prose and leaving the table
would have left the collision intact one line away.

**Verified empirically rather than reasoned about**, by reading the folio printed
on the cached page across three books:

| book | registry | cache page | folio on it |
|---|---|---|---|
| `phase-world` | `0` | `p016` | **16** |
| `potm` | `1` | `p017` | **16** |
| `pf` | `2` (past its exception) | `p018` | **17** |

That gives one rule covering every case — `cache page = printed folio +
page_offset`, and `cache pNNN = pymupdf d[NNN-1]` — which is now in the skill
above a table restated in the registry's base with the book slugs named.
`read-columns.py` takes the cache page number directly.

**The memory contradicted itself, four lines apart.**
`pantheons-of-the-megaverse-survey.md` said *"the printed-to-PDF offset is
ZERO"* and, four lines later, *"cache file = 1-based reader page = printed+1"*.
Both true, in two bases, in one file. Corrected to the registry's base with a
note saying which base to use and why — it is the one `class-check
--field-sources` and `drift-check` read, so it is the one that settles arguments.
The `MEMORY.md` line said "page offset zero" with no base at all and now cites
`books.json`.

**Zero is no longer the exotic case**, which was the finding's other half:
`ww`, `triax` and `phase-world` are all registered at 0, and the skill now names
them.

---

### F7 — `audit-menu`'s file table is wrong about `DOCS-AUDIT.md`, and filing THIS file makes it wrong again

The table under *The headings are not uniform, and that is the argument* is
correct on thirteen of fourteen rows, verified heading-by-heading on 2026-09-02.
The exception:

| | table says | `DOCS-AUDIT.md` actually has |
|---|---|---|
| shape | `### D1 — …` | `### D1 — low — …` |

Every one of the five carries a word in that slot: `low`, `low`, `low`, `info`,
and — `D5` — **`WITHDRAWN`**. That last is not a severity at all but a *status*,
occupying the position where four other files put a severity, and it is the one
cell in the whole table that would change a scan's answer: `D5` is the finding
`pick3cut5/AUDIT.md`'s own header cites as *"already produced one withdrawn
finding"*. The table's neighbouring row for `apps/character-creator/AUDIT.md`
records the severity word correctly, so this is an omission in one cell rather
than a rule the table does not know.

The skill says this table "has been wrong twice" — missing two files on
2026-08-31, four on 2026-09-02. This is a third error, of a kind it has not had
before: a wrong cell rather than a missing row.

**And the row this file needs does not exist yet.** `SKILL-AUDIT.md` uses `F`
and `N` at `###` with an em dash and no severity word — the same shape as
`EFFICIENCY-AUDIT.md`, and the fifteenth menu.

**Proposal.** One PR correcting the `DOCS-AUDIT.md` cell to
`severity or status word: ### D1 — low — …, and ### D5 — WITHDRAWN — …`, and
adding a row for `SKILL-AUDIT.md`. The count in the prose above the table
(*"the fourteenth: `SETUP-v2-CHANGES.md`"*) needs re-reading in the same pass —
that sentence is about which file the glob misses, not about how many exist, and
`audit-menu`'s *A correction inherits the scope of the sentence it corrects*
applies to it directly. Do not add a count of menus anywhere.

**Posture:** correct one cell, add one row. **Documentation only. No new gate** —
the skill argues at length that any regex over this table will be wrong about at
least one file, and that argument is the reason not to pin it.

**Evidence.** Git history and the closed menus — every menu's headings read
directly, 2026-09-02.

**Taken, 2026-09-02 (PR #548).** Posture as proposed: correct one cell, add one
row, **documentation only, no new gate** — the skill's argument that any regex
over this table will be wrong about at least one file is the reason not to pin
it, and it stands.

Premises held. All five `D` findings carry a word in the severity slot, and `D5`
carries `WITHDRAWN` there — a *status* where four other files put a severity.
The table's neighbouring row for `apps/character-creator/AUDIT.md` records the
severity word correctly, so this was one wrong cell rather than a rule the table
did not know.

**The finding predicted its own falsification and was right.** Filing
`SKILL-AUDIT.md` made a fifteenth menu, so the table needed the row as well as
the correction — both in this PR, as the proposal said.

**One thing done beyond the proposal, and it is the durable half.** The paragraph
above the table ended *"remember the fourteenth: `SETUP-v2-CHANGES.md`"* — an
**ordinal**, in the paragraph whose subject is that counts of these files are
never right. It was already wrong: the tree holds fifteen. Rather than change
fourteen to fifteen and leave the same trap armed, the sentence no longer states
a number at all — *get the list from the tree, then add the one it cannot find*.
The `SETUP-v2-CHANGES.md` point is what that sentence was for; the ordinal was
never load-bearing and had been wrong at every reading.

The snapshot caveat below the table was updated in the same spirit: it said the
table *"has been wrong twice"*, which is now three times and a fourth shape —
missing rows, then more missing rows, then a wrong cell. It now says it has been
wrong every time it has been checked, and names this reading's error, without
keeping a tally. `audit-menu` argues at length against tallies of its own
recurring failures; a count of how often the table was wrong is one more thing to
keep current.

---

### F8 — `book-survey` is 585 lines read in full on every fire, and about a third of it is worked example

At 585 lines / 4,999 words / 30KB it is 60% larger than the next skill and
larger than `CLAUDE.md`, `claim-audit` and `schema-change` combined. It fires on
"here is the PDF", which is the first message of a book session — so it is paid
for at the point in a session where `EFFICIENCY-AUDIT` F1 measured the carry cost
compounding worst.

What earns its place is the judgement: *a text layer does not give you tables*,
*the index is the authority and page position is not*, *a small edit distance is
not permission to merge*, *diff before you extract*. What is arguable is the
book-specific worked material sitting inline at full length — the Palladium
Fantasy typesetting-damage table (§0, six rows), the two-authority reconciliation
of the PF spell indexes (§4b, 20 lines), the Finger of Lictalon adjudication
(§4c, 22 lines), the four-row Tesseract approach comparison (§2). All four are
one book's evidence for a rule stated in one line beside them.

The skill already knows the pattern and applied it once, in the other direction:
`reference/read-columns.py` was **deleted** because a reference that forks
working code reads as authoritative and is not. The mirror case — evidence that
should be behind a pointer — has not been applied.

**Proposal.** Move the four worked passages to
`.claude/skills/book-survey/reference/WORKED-EXAMPLES.md`, leaving each rule in
place in `SKILL.md` with a one-line pointer. Target ~380 lines. Move nothing that
states a rule; move only the evidence for one. Explicitly **keep** §0 (text-layer
probe), §0d (the offset registry) and §5 (reconcile) at full length — all three
are the failure, not the illustration.

**Posture:** split. **No content deleted, no rule moved.** If the split cannot be
done without moving a rule, do not do it: this is the least urgent finding here
and a worse `book-survey` is a much worse outcome than a long one.

**Evidence.** Live repo state (`wc`) plus `EFFICIENCY-AUDIT.md` F1, 2026-08-25.

**Taken, 2026-09-02 (PR #563). Posture held — no rule moved — and the finding's
own arithmetic was wrong.**

The four named passages moved to `reference/WORKED-EXAMPLES.md` (107 lines).
`SKILL.md` went **672 → 650**. The proposal targeted **~380**.

**That target was never reachable by this change, and the finding should have
seen it.** The four passages are roughly sixty lines between them, and each is
rule-and-evidence interleaved rather than a liftable block — every one needed its
rule left behind and a pointer added, so the net is about twenty lines. Reaching
380 would mean removing nearly 300, which is not four passages; it is most of the
file. The finding named the right passages and then quoted a number it had not
derived from them — `F21`'s shape, in a proposal written the same morning.

**Verified after the split:** all six load-bearing rules still in `SKILL.md`,
each exactly once — *none of it is fixed by a better reader*, *let Tesseract do
the layout analysis*, *reconcile them by NAME*, *keep a tiny explicit alias
list*, *the index wins and the page is recorded*, *telling you something by the
exception*. Four pointers added. §0, §0d and §5 untouched, as required.

**Two rules came out stronger for losing their example**, which is the argument
for the split beyond length. §4b's was stated as a fact about the Palladium
Fantasy main book; it now says *look for a second authority before parsing the
first* — a rule about any book. §4c's was a Finger-of-Lictalon adjudication; it
now says *settle it with independent readings and a magnitude argument, not with
the rule*, and the count-the-exceptions line no longer hangs off one book's "six
times in 180".

**What this does NOT solve is the length.** A 650-line skill still loads in full
on "here is the PDF". Getting it materially shorter is a different decision —
which sections stop being in the skill at all — and this posture explicitly
forbids taking that unilaterally: *a worse `book-survey` is a much worse outcome
than a long one*. **Raised with Nate 2026-09-02 and CLOSED: leave it long.** The
skill fires once per book rather than once per message, and a lossy one costs
more than a long one. Not to be re-proposed.

---

### F9 — the machinery to pin a skill's claims exists and pins exactly one sentence pattern

`HEALTH-AUDIT` F5 (PR #517) added a smoke check after `schema-change` shipped a
table count seven tables stale. `apps/character-creator/test/smoke.mjs:6320-6329`
walks the **whole** `.claude/skills` tree — the expensive part, already built —
and then matches one regex:

```js
/([\w-]+) tables in one shared D1 database/g
```

So a skill may quote the shared-database table count and nothing else. `F3`,
`F4` and `F5` above are three counts in three skills that this walker passes over
while reading the very files they are in.

**This is not an argument for pinning them.** Every skill here says the opposite:
*"The cheaper habit is not to quote one"* (`schema-change:53`), *"a skill naming a
moving number is wrong more often than right"* (`ship-pr:63`), *"Sizes and class
counts are deliberately not given here"* (`claim-audit:27`). Three skills state
the rule; `F3`, `F4` and `F5` are the same three skills breaking it. The rule is
right and unenforced, and the enforcement that exists covers one sentence.

**Proposal, and it is the smaller one.** Add a check in the same walker that
fails on a **cardinal number word or numeral immediately preceding a countable
noun the repo can answer** — the four shapes actually observed: `<N> lines`,
`<Word> <kebab>-*.sql scripts`, `<N>-line`, `the only book`. Report the file and
line and say *"describe the shape, not the count"*. Posture: **fails the build**,
same as the existing count check, because a skill is checked-in text and the
failure is deterministic.

**The alternative posture is worth arguing for and I am not proposing it.** A
warn-only check here would be read as advisory and quoted numbers would keep
landing; that is the F5 outcome that produced the existing check. But this
regex will produce false positives on legitimate historical measurements
(*"13 spells came back exactly one level too high"* is a record, not a claim
about now) and there is no mechanical way to tell those apart. **If the false
positives cannot be held under about one per skill, close this rather than
weakening it** — an allowlist of permitted numbers is one more thing to keep
current, which is the failure mode `audit-menu` exists to name.

**Posture:** new check, **fails the build**, or closed. Not warn-only.

**Evidence.** Live repo state — the check read in `smoke.mjs`, 2026-09-02 — plus
`HEALTH-AUDIT.md` F5.

**CLOSED WITHOUT BEING TAKEN, 2026-09-02 (PR #564) — on the finding's own
instruction**, which said to close it rather than weaken it if false positives
could not be held near one per skill. They could not. **No check was added.**

**Measured, not estimated.** A prototype of the four shapes the proposal named,
run against the six skills and four reference files on a tree where all three
known breaches were already fixed:

| version | hits | real |
|---|---|---|
| the four shapes as proposed | **74** | 0 |
| tightened to present-tense assertion + repo-countable noun | **8** | **1** |

Twelve per skill, then 1.3. And the survivors cannot be tightened away, because
they are the same shapes used correctly: *"this is the only check that can catch
the bug"* is a rule, and *"`pf` is the only book that has one"* was a claim — one
regex, both sentences. *"52 skills SHORT: 293 against 345"* is a dated
measurement `F18` shipped deliberately. Worst of all, `claim-audit`'s new
`F21` table **must** contain the shapes in order to teach them, so any version of
this check fires on the skill that documents it.

Getting past that needs an allowlist, and the proposal ruled it out in advance:
*one more thing to keep current, which is the failure mode `audit-menu` exists to
name.* The distinction is tense and intent — measurement versus claim — and no
regex reaches it. **`F21` is the version of this that works, and it is prose.**

**The prototype earned its keep anyway, and this is the part worth carrying.** At
the tightened setting it found **one real breach that hand-checking had missed**:
`book-survey/reference/SURVEY.md` still read *"`pf` is the only book with one
today"* — the exact claim `F5` corrected in `SKILL.md` **four hours earlier**.
`F5` fixed the file it was looking at and not the skill. That is `F3`'s *grep the
whole file, not the paragraph* recurring at the level of a directory, inside a
batch where it had already been named twice.

It is fixed in this PR, and `F5` carries an `Adjusted` note.

**So: no gate, but the probe is worth re-running by hand after a batch like this
one** — as an audit aid whose 7 known false positives a person reads past in
under a minute, not as a build step that fires on them forever.

---

## Layer 2 — the subagent

### F10 — `book-reconcile` is the oldest instruction in the surface, and its one required output is a page number it is never told how to compute

`.claude/agents/book-reconcile.md` was last edited **2026-08-22** (`8fe6f67`),
eleven days before every other file in this audit and before the entire
page-offset doctrine existed. `scripts/books.json`, `page_offset_exceptions`,
`class-check --field-sources` and `book-survey` §0d all postdate it.

Its output contract (`:83`) requires, for every disagreement:

> **where in the book you read it** — page and which reading (stat block, index)

Its input section (`:29`) hands it `.cache/books/<slug>/txt/*.txt`. Nothing in
between tells it that a cache page is not a printed page. It is asked to report
printed pages, given cache pages, and never told the two differ — across a corpus
where the offsets registered on 2026-09-02 run `-1`, `0`, `1`, `2`, `3`, and two
books change offset mid-book.

The failure this produces is the one `book-survey` §0d names outright: *"Hunting
the Attribute Bonus Chart at printed 16 with the late-book offset lands on the
wrong page and finds nothing, which reads exactly like 'the chart is not in this
book'."* From inside the reconciler that surfaces as its own most severe verdict
— *"Anything the book's index does not list at all… needs a human"* — with the
row reported wrong and the book quoted correctly off the wrong page.

The agent is otherwise in good shape: its OCR-mangling list (`I.S.P.`→`LS.P.`,
`S.D.C.`→`$.D.C.`, `feet`→`fect`, `lbs`→`Ibs`) still matches
`scripts/ocr-fields-lib.mjs`, and its four opening failure cases are all still
live lessons.

**Proposal.** Add one section, ~10 lines, before *How to check*: the cache is
addressed by cache page; `scripts/books.json` holds `page_offset` and any
`page_offset_exceptions` per slug; cache page = printed folio + offset; the folio
printed on the page is the free check and should be read every time; and a book
may change offset mid-book, so a lookup that lands on plainly the wrong content
is an offset question before it is a missing-row finding. The agent already has
`Read` and `Bash`, so it can read the registry itself — no tool change.

**Posture:** add a section. **No change to the agent's scope, tools or
report-only mandate.**

**Evidence.** Git history (`git log -1` on `.claude/agents/`) against
`scripts/books.json` and `book-survey` §0d, 2026-09-02.

**Taken, 2026-09-02 (PR #554).** Posture as proposed: add a section, **no change
to the agent's scope, tools or report-only mandate**, and no tool added — it
already has `Read` and `Bash`, so it can open `books.json` itself.

Premises held. `.claude/agents/` was last touched **2026-08-22** (`8fe6f67`),
eleven days before everything else in this surface and before the offset registry
existed. The file contained **zero** occurrences of `offset`, `books.json`,
`folio` or `printed`, while its output contract asks for *"where in the book you
read it — page and which reading"*.

**Written with the rule `F6` had just established** rather than a fresh
derivation: `cache page = printed folio + page_offset`, verified an hour earlier
against three caches by reading the folio on the page. Taking `F6` first made
this section a citation instead of an investigation.

**One thing added the proposal did not list**, and it is the half that matters
for a reconciler: **cite the printed folio, not the cache page.** The agent's
whole output is *"here is where I read it"*, consumed by someone holding the
book — so the conversion has to run in the reporting direction too, not only when
looking a page up. The proposal covered the lookup and stopped there.

Also stated: the folio printed on the page is the free check and a disagreement
with the registry is **a finding to report**, not something to work around
quietly. That matches the agent's existing posture — it reports and never fixes.

Junction verified after the edit: `~/.claude/agents/book-reconcile.md` is
byte-identical, as the whole-directory junction guarantees.

---

## Layers 3 and 5 — reach: which file is loaded where the work happens

The three findings below are one mechanism seen three times. They are filed
separately because they have different fixes and different postures, and taking
one does not take the others.

### F11 — the skills reach every directory and `CLAUDE.md` does not, and a note shipped this morning says the opposite in writing

`CLAUDE.md` explains, correctly and at length, why the skills are junction-linked
into `~/.claude/skills`: *"a session started anywhere else — in `Downloads`, say,
with the PDF — would not see them, and one session ran an entire class import by
hand for exactly that reason."*

`CLAUDE.md` itself got no such link. There is **no `~/.claude/CLAUDE.md`**
(checked 2026-09-02). So a session started in `Downloads` — which `CLAUDE.md`
calls *"the one place the book work runs"* — loads all six skills, the subagent,
and none of the file that says which skill to use, that `--local` is not a
mirror, that filename order is execution order, that the README's counts are
pinned, or what the Cloudflare token can and cannot do.

The transcripts show the workaround. Of the 1,041 messages Nate typed, **16
sessions** carry the repo path in a human message because the session had to be
told where the repo is, and the boilerplate has hardened into a fixed opening:

> Repo is `C:\Users\natha\Projects\nates-apps` — read its `CLAUDE.md` first, it
> does not auto-load from Downloads.

`BOOK-INGEST-PROMPT.md` prints that sentence as the first line of its reusable
prompt A. `SKILLAUDITPROMPT.md`, the brief that produced this file, prints it
too. It is a hand-carried instruction pointing at an instruction file, in a
system whose entire design principle is that the instruction should fire by
itself.

**And a correction that shipped at 07:33 today states the reverse.**
`HEALTH-AUDIT.md` F6's Taken note (PR #518) explains why the allowlist rationale
went into `CLAUDE.md` rather than a `settings.json` comment:

> The explanation is in `CLAUDE.md` instead, which is the better home anyway: it
> is **the one file loaded in every session regardless of working directory.**

It is the one file loaded in *no* session outside the repo. The conclusion (put
it in `CLAUDE.md`) is still right — there is nowhere better — but the reason
given is false, and it is now the standing justification for putting things
there.

**Proposal.** Two parts, one PR.

1. Create `~/.claude/CLAUDE.md` as a **short pointer, not a copy** — five or six
   lines: the repo is at `C:\Users\natha\Projects\nates-apps`; read its
   `CLAUDE.md` before touching D1, the merge loop or a book; the six skills load
   from anywhere and the repo's `CLAUDE.md` says which to use when. A copy would
   be a second surface to keep in sync and would reintroduce exactly the
   divergence this audit went looking for and did not find. Document the file and
   its one-line contents in the junction block in `SETUP.md`, beside the two
   junctions it sits with, so a machine rebuild recreates it.
2. Append an `**Adjusted 2026-09-02**` note under `HEALTH-AUDIT.md` F6 correcting
   the reason while keeping the decision, per *Audit files are RECORDS*.

**Posture:** add one file plus one `SETUP.md` block; **append**, do not edit,
the F6 note. **No new gate.**

**Evidence.** Live repo state (`ls ~/.claude`, 2026-09-02), git history
(`HEALTH-AUDIT.md` F6, PR #518), and session transcripts (16 sessions).

**Taken, 2026-09-02 (PR #543).** Both parts as proposed, posture included: a
pointer rather than a copy, documented in `SETUP.md`, and F6 **appended** rather
than edited. Every premise held — no `~/.claude/CLAUDE.md` existed, both junction
sets resolve into the repo, F6's sentence is verbatim as quoted, and
`BOOK-INGEST-PROMPT.md` opens with the hand-typed pointer.

**One correction to the proposal's own wording.** It says *"Document the file and
its one-line contents in the junction block"*. One line is too short to be
useful and six paragraphs is too long to quote, so `SETUP.md` describes the
file's job rather than reproducing it — the same *describe the shape, not the
value* rule `F21` is about, applied to the thing being written rather than to a
count.

**One thing the finding did not anticipate, and it constrains the file.**
`~/.claude/CLAUDE.md` loads in **every** session on this machine, not only
nates-apps ones — the transcripts carry MediaVault work, a Robinhood MCP setup
and interview prep in the same directory. So it is scoped to pointing: where the
repo is, read its `CLAUDE.md` when the work touches it, and a note that the
skills *do* load by name. `SETUP.md` says to keep it that way, because the
obvious next edit is to start moving repo content into it, and that would
recreate the divergence the junctions exist to prevent.

The reason for the pointer shape is also now written down where someone would
reach for a junction and find they cannot: the file has to sit *at*
`~/.claude/CLAUDE.md` rather than in a directory of its own, and a Windows
junction only works on a directory — the same constraint that forced the agents
link to cover the whole directory.

---

### F12 — the deliberate gaps in the repo allowlist are granted by wildcard in the directory the book work runs from

`CLAUDE.md`'s closing section is one of the most carefully argued things in the
repo:

> **What is deliberately absent, so nobody reads it as an oversight and "fixes"
> it:** `scripts/d1-apply.mjs` … plus `gh pr merge`, `gh pr create`, `git push`,
> `git commit`, `git checkout`, and every `wrangler d1 execute`. Those are the
> actions worth stopping for… both should cost a deliberate keystroke.
>
> The `gh api` entry is pinned to this repo's `commits/` path rather than written
> as `gh api *`, because a prefix wildcard cannot exclude a `-X DELETE`…
> **Do not widen it.**

That file is `.claude/settings.json`, 39 allow entries, project-scoped to
`C:\Users\natha\Projects\nates-apps`.

`C:\Users\natha\Downloads\.claude\settings.local.json` is 77,627 bytes and holds
**273 allow entries** (109 `Bash`, 145 `PowerShell`, the rest `Read`/MCP),
accumulated by approval since 2026-08-28. Twenty-five are wildcards. They include,
verbatim:

```
Bash(npx wrangler *)     Bash(gh pr *)        Bash(gh api *)
Bash(git push *)         Bash(git commit *)   Bash(git add *)
Bash(git reset *)        Bash(git checkout *)
```

Every single item on `CLAUDE.md`'s deliberately-absent list is granted there by
wildcard, including `gh api *` under the exact phrasing the file says not to
write, and `npx wrangler *`, which covers every `d1 execute --remote` — the
writes the ordering rule exists to make deliberate. A further 45 entries are
full literal command strings pinned to session-scratchpad paths that no longer
exist, and are dead; the wildcards are not.

I have **not** established that this changes behaviour today — whether a project
allowlist and a `settings.local.json` in a different project directory compose,
and in which precedence, is a harness question I cannot settle from here, and the
honest statement is that the repo's reasoning describes a posture that this file
does not share, in the directory `CLAUDE.md` itself calls the one place the book
work runs.

**Proposal.** Not a settings edit — the decision is Nate's and it is about how he
wants to work, not about a defect. One PR that:

1. adds a section to `CLAUDE.md` recording that a **second** allowlist exists at
   `C:\Users\natha\Downloads\.claude\settings.local.json`, that it is untracked
   and accumulates by approval, that it currently holds wildcards for the eight
   commands the repo list withholds, and that the repo list therefore describes a
   posture rather than enforcing one;
2. states which of the two governs a Downloads session, **established by testing
   rather than reasoned about** — the same doctrine `CLAUDE.md`'s own wrangler
   section already applies to the token.

Then, separately and on Nate's word, either prune the wildcards from the
Downloads file or delete it and let it re-accumulate.

**Posture:** documentation first; **no settings edit in the same PR.** Pruning a
live allowlist is a working-habits change and belongs behind its own decision.

**Evidence.** Live repo state — both files parsed, 2026-09-02.

**Taken in part, 2026-09-02 (PR #555): the documentation half only, as the
finding proposed. No settings file was edited in that PR.**

**Completed 2026-09-02 (PR #571): the prune, on Nate's word.** Fifteen
write-capable wildcards removed from `Downloads\.claude\settings.local.json`
(273 → 258 entries), the file backed up beside itself first. Gone: the eight
`CLAUDE.md` names as deliberately absent — `npx wrangler *`, `gh pr *`,
`gh api *`, `git push *`, `git commit *`, `git add *`, `git reset *`,
`git checkout *` — plus `git config *`, `git pull *`, `git stash *`,
`gh auth *`, `claude mcp *`, and `python -c ' *` / `node -e ' *` for arbitrary
code execution.

**Kept, because the criterion is the repo's own — *everything on it either
reports or asks a question*:** `git fetch`, `git ls-remote`, `git check-ignore`
and seven `Read()` path globs. Read-only, and removing them would buy friction
rather than safety.

**The ~45 dead entries were left alone.** They are literal command strings
pinned to session scratchpad directories that no longer exist — unreachable
rather than dangerous, and deleting them is tidying beyond what was asked.

**What this does and does not settle.** The two lists now withhold the same
actions, so the posture holds wherever a session starts — which was the point.
It does **not** answer which file governs; that is still untested and
`CLAUDE.md` still says so and still names the test. And the file will begin
accumulating again at the next approval, so this is a reset rather than a fix.

*(The middle clause stopped being true on 2026-09-03: the test was run, each
directory is governed by its own project settings, and `CLAUDE.md` now records
that instead of the caution. The first and last clauses stand — the prune was a
reset, not a fix. See the note under the probe pair below.)*

Premises held — 273 entries, 25 wildcards, 45 pinned to dead scratchpad paths,
and the eight withheld commands all granted.

**One correction, and it lowers the temperature.** The finding says the file
"accumulates by approval". It **stopped accumulating on 2026-08-28**: measured
across this whole working session it was unchanged — same mtime, same 77,627
bytes, same 273 entries, and not one entry naming any branch created today. It
is a frozen artifact rather than a growing one, which makes it less urgent than
the finding implies, though the 25 wildcards remain whatever the file's growth
rate is.

**Part 2 was attempted and could not be completed, which is recorded rather than
papered over.** The proposal required stating which allowlist governs a
`Downloads` session **"established by testing rather than reasoned about"**. The
test available from inside a session — watch whether the file grows when a
withheld command runs — returned *no change*, which is consistent both with "that
file does not govern" and with "it governs and nothing prompted". It does not
discriminate. So `CLAUDE.md` now says plainly that the question is **not
established**, names the deliberate test that would settle it (one command
allowlisted here and absent there, and one of the reverse, from each directory),
and says not to assume either way.

That is the honest version of the doctrine this file already applies to the
Cloudflare token: *ask for the specific thing you need, and let the tool tell
you which credential answered.* Writing a confident answer here would have been
the reasoning the section itself warns against.

**Attempted and abandoned, 2026-09-02; left untested by decision.** The real
test needs an interactive Claude Code session in each directory, because the
allowlist governs commands *Claude* runs — a command typed straight into
PowerShell never touches it. Two runs failed before that was established: the
first pasted the probes into a raw shell, where no prompt was ever possible; the
second could not launch `claude` at all.

**The probe pair, if anyone runs it later.**
`node scripts/drift-check.mjs --remote` is on the repo list only and
`git --version` on the Downloads list only; the two lists share exactly **one**
entry, the repo has no `settings.local.json`, and the user level has no
`permissions` block — so the four cells are unambiguous. Default permission
mode, and decline every prompt: the answer is whether it **asks**.

**RUN, 2026-09-03 (PR #656). Each directory is governed by its OWN project
settings. They do not compose, in either direction.**

| cwd | probe | on repo list | on workshop list | result |
|---|---|---|---|---|
| `nates-apps` | `node --check <file>` | **yes** | no | **ALLOWED** — ran |
| `nates-apps` | `git --version` | no | **yes** | **DENIED** — *"This command requires approval"* |
| `workshop` | `node --check <file>` | **yes** | no | **DENIED** — *"This command requires approval"* |
| `workshop` | `git --version` | no | **yes** | **ALLOWED** — `git version 2.53.0.windows.3` |

**The answer is the reassuring one, and it was worth not assuming.** The repo's
deliberate gaps are not silently widened by the 258-entry list when work happens
in the repo, and the repo's entries do not reach a session in the working
directory. `F12`'s documentation half — which described the two lists as separate
postures rather than one composed set — was right.

**Why this ran when the 2026-09-02 attempt could not.** That attempt concluded
the test *"needs an interactive Claude Code session in each directory"* and
stopped. **It does not.** `claude -p` consults the same allowlist; the only
difference is what happens on a miss — a print-mode session cannot prompt, so it
**denies**, and that denial is the same observable the prompt would have been.
With `--output-format stream-json` the `tool_use` and its `tool_result` are both
visible, so nothing rests on reading prose.

The other two obstacles were real and are recorded correctly: the first attempt
pasted probes into a raw shell, where the allowlist is never consulted at all —
this run went through Claude's own `Bash` tool — and the second could not launch
`claude`. It launches from Git Bash via the npm shim.

**One improvement on the probe pair above.** `node --check <file>` replaced
`drift-check.mjs --remote` on the repo side: identical allowlist status, but
instant and read-only rather than a four-minute production query. The four cells
are unchanged by the substitution — re-verified 2026-09-03 that the two lists
still share exactly **one** entry
(`Bash(node apps/character-creator/test/smoke.mjs)`, neither probe), the repo
still has no `settings.local.json`, and `~/.claude/settings.json` still has no
`permissions` block.

**Scope of the answer, stated so it is not over-read.** This tested two
*different* project directories, in print mode, with the settings as they stood
on 2026-09-03. It says nothing about a subdirectory inheriting its parent's
settings, and nothing about `--add-dir`.

---

### F13 — `book-survey`'s first command is justified by a permission fact that is not true where the skill runs

`book-survey/SKILL.md:39-41`, on why to run `scripts/ocr-book.py --probe`:

> Use it rather than a bare `python -c` — that is **deliberately outside the
> allowlist and prompts every single time**, and this is the first command aimed
> at every new book.

`.claude/settings.json` has no `python -c` entry, so that is true in the repo.
`C:\Users\natha\Downloads\.claude\settings.local.json` holds
**`Bash(python -c ' *)`** and **`Bash(node -e ' *)`**, and `book-survey` fires on
"here is the PDF", which arrives in `Downloads`.

The instruction is still right — `ocr-book.py` writes a manifest, records
`page_offset`, resumes, and refuses a destructive re-cache, none of which a
`python -c` does, and §0b spends a paragraph on the seven hand-rolled caches that
do not agree with each other. But its *stated* reason is a friction argument, and
the friction is not there. A reader who checks finds the reason false and has no
way to know the real reason survives it.

This also cuts the other way in the same skill: §0c tells you to render a page
with a bare `pymupdf` snippet, which is a `python -c` by another name, four
sections after saying such a thing prompts every time.

**Proposal.** Replace the parenthetical with the durable reason: `ocr-book.py`
writes the page-addressed cache `class-check --field-sources` and `drift-check`
both read, records the offset in the manifest, resumes correctly and refuses to
overwrite a text-layer cache with OCR — *"seven of the first eight caches were
hand-rolled and they do not agree with each other"* is already in §0b two
paragraphs later and is the argument. Delete the allowlist claim. In §0c, say
plainly that the render snippet is a one-off probe and is expected to prompt.

**Posture:** rewrite one parenthetical and add one clause. **Documentation
only.** Independent of `F12` — this is worth doing whatever is decided there,
because the permission fact should not have been load-bearing in a skill in the
first place.

**Evidence.** Live repo state — both settings files against the skill,
2026-09-02.

**Taken, 2026-09-02 (PR #549).** Posture as proposed: rewrite the parenthetical,
add one clause to §0c, **documentation only**, and independent of `F12` as the
finding said.

Premises held, and the Downloads side is worse than the finding stated. That
allowlist grants `python -c` **nine** ways: `Bash(python -c ' *)` by wildcard,
plus eight literal entries, plus `Bash(node -e ' *)` alongside. The friction the
skill claimed does not exist in the directory the skill fires in.

**The replacement does not argue about permissions at all**, which is the point
of taking this: a rationale that rests on a settings file is a rationale that can
be falsified by a settings file. `ocr-book.py` earns its place because it writes
the page-addressed cache `class-check --field-sources` and `drift-check` read,
records `page_offset` in the manifest, resumes, and refuses to overwrite a
text-layer cache with OCR — and §0b's *seven of the first eight caches were
hand-rolled and do not agree with each other* is the evidence, already in the
file two paragraphs down. That reason holds regardless of where the session
started or what anyone allowlists later.

**§0c resolved rather than excused.** The finding noted the tension — §0c tells
you to render a page with a bare `pymupdf` snippet four sections after saying
such a thing prompts every time. With the friction claim gone the tension goes
too, but the distinction is worth stating, so §0c now says outright that its
snippet **is** a throwaway probe: it writes a PNG you look at once and nothing
depends on afterwards, which is exactly what separates it from §0b's cache. The
rule is not "never write a script", it is "never hand-roll the artifact other
tools read".

The old claim is described rather than restated, per `audit-menu` — the
paragraph says the friction argument was false, without reprinting the sentence
that made it.

---

### F14 — `launch.json`'s 8788 warning shipped into the file a Downloads session does not load

`HEALTH-AUDIT` F7 (PR #526, 2026-09-02) put seven comment lines into
`.claude/launch.json` because *"three separate audits found it occupied by
something else"*:

> 8788 is a convention, not a reservation. A SECOND CHECKOUT MAKES IT A TRAP …
> The page loads, looks like your app, and is not.

`C:\Users\natha\Downloads\.claude\launch.json` is a **second, untracked launch
config with six entries**, carrying no comments at all. Three of its six default
to 8788 (`workshop-attach`, `nates-apps`, `nates-apps-pick3cut5`); the other
three are the escape hatches (`nates-apps-8791`, `nates-apps-8793`,
`pick3cut5-room`). `UI-AUDIT.md`'s header cites `nates-apps-8791` — *"the
`nates-apps-8791` launch config — **not** 8788, which belongs to another
worktree"* — and that configuration **exists only in the Downloads file**. It is
not in the repo's `launch.json`.

So the audit that hit the trap used a config the repo does not have, and the fix
for the trap went into a file that session would not have loaded. The memory
`dev-server-8788-is-another-worktree.md` carries the workaround
(*"verify on your own port via Downloads launch.json"*), which is the third
recording of the same fact in a third layer.

**Proposal.** One PR adding `nates-apps-8791` and `nates-apps-8793` to the repo's
`.claude/launch.json`, carrying the same `"//"` comment block, so the escape
hatches exist in the tracked file and the warning travels with them. Then, in the
same PR, add one line to the existing comment block naming the Downloads copy as
a second config that a session outside the repo loads instead — the `F12`
disclosure, applied to the file where it is cheapest.

**Posture:** add two configurations and one comment line. **No behaviour
change** — nothing that runs today changes; the repo simply gains the two
configs the audits actually used.

**Evidence.** Live repo state (both `launch.json` files, 2026-09-02) against
`UI-AUDIT.md`'s header and `HEALTH-AUDIT.md` F7.

**Taken, 2026-09-02 (PR #556).** Posture as proposed: add two configurations and
a comment block, **no behaviour change** — nothing that runs today runs
differently; the repo simply gains the two configs the audits actually used.

Premises held. The repo's `launch.json` had three configurations and neither
escape hatch; the Downloads copy has six and carries no comments at all;
`UI-AUDIT.md`'s header cites `nates-apps-8791`, a config that existed **only**
in the untracked file.

**The finding under-read one memory, and the correction matters beyond this
finding.** `dev-server-8788-is-another-worktree` does not merely record the
workaround — it states outright that *"the repo's `.claude/launch.json` is NOT
what `preview_start` reads from a Downloads session"*, observed 2026-08-25. So
for `launch.json` the resolution question `F12` leaves open **has** an answer
from experience: the Downloads copy wins in a Downloads session.

**That does not settle `F12` and the memory now says so.** `launch.json`
resolving to the Downloads copy is not evidence that `settings.json` does; they
are different files read by different machinery. Both notes now cross-reference,
and `F12`'s "not established, here is the test" stands.

A consequence worth stating: the two hatches are now in **both** files, so the
config exists whichever way a session starts — which is the actual fix, rather
than moving them from one file to the other.

The memory was rewritten to describe both files and which is read when, instead
of instructing the reader to add a temporary entry to the untracked one.

---

## Layer 4 — memory

### F15 — a memory reports four findings as open that had merged hours before it was written

`redesign-audit-menu.md`, last modified **2026-09-01T11:03Z**:

> **N1, N3, N4 and N6 remain open** and are the next menu

Read under their headings in `apps/character-creator/REDESIGN-AUDIT.md` on
2026-09-02, all four carry notes:

| item | note |
|---|---|
| `N1` | `**Taken, 2026-09-01 (PR #470).**` |
| `N3` | `**Taken, 2026-09-01 (PR #473).**` |
| `N4` | `**Taken, 2026-09-01 (PR #472).**` |
| `N6` | `**Taken, 2026-09-01 (PR #469).**` |

All fifteen items (`R1`–`R7`, `N1`–`N8`) are closed. The memory also says *"Six
findings were opened while taking them"*; there are eight, `N7` and `N8` having
been added and taken the same day (PRs #474, #475).

This is not carelessness — it is the property of the layer. A memory is written
once and read by relevance; nothing revisits it when the world moves, and here
the world moved inside the same afternoon. `MEMORY.md`'s pointer for the same
memory is stale a **third**, different way: it reads *"N1-N4 and N6 still open"*,
which includes `N2`, while the memory file's own `description:` says `N2` was
taken. Index, body and repo give three different answers.

**Proposal.** Rewrite the status paragraph and the `description:` to *"All 15
items closed 2026-09-01 (PRs #462–#475); R3 closed unadopted, R6 taken in
part"*, and rewrite the `MEMORY.md` line to match. Keep everything else in the
file — the six wrong prompt claims, the measured contrast ratios, the
`repeat(7, 1fr)`-for-a-ten-step-wizard lesson — which is the durable half and is
still correct.

**Posture:** rewrite two lines in one memory and one index line. **Correct the
current claim; do not quote the phrase being replaced**, per `audit-menu`.

**Evidence.** Memory layer against the repo, 2026-09-02.

**Taken, 2026-09-02 (PR #550).** Posture as proposed: rewrite the status
paragraph, the `description:` and the index line; keep everything else. Premises
held — `N1` #470, `N3` #473, `N4` #472 and `N6` #469 all merged 2026-09-01, and
the memory was last written 2026-09-01T11:03Z.

**One correction to the finding, and it makes the case worse rather than
better.** The finding says four closed items were reported open. Read against
every heading in `REDESIGN-AUDIT.md`, the memory was wrong about **seven of
fifteen**: those four, plus *"six findings were opened"* where there are eight
(`N7` and `N8` were opened and taken the same day, #474 and #475), plus `R7`,
which it credits to #468 when #468 was the **held** implementation and the work
shipped as #477. Every error points the same way — it recorded the state of one
afternoon and nothing revisited it.

**The rewrite makes the memory stop competing with the file.** Rather than
restating a status that will rot again, the paragraph now points at
`REDESIGN-AUDIT.md`'s own header, which is measured, dated and maintained by the
protocol — and keeps only what the file does not carry: `R3` unadopted, `R6`
partial and why, `R7` held-then-shipped, and the `N2` twist where its escape
hatch was later deleted by the Rust & Ash redesign's phase 4. The `description:`
says the same, because that is the line recall matches on.

The correction names the current state without reprinting the sentence it
replaces, per `audit-menu`.

---

### F16 — `MEMORY.md` quotes moving counts, in the index that sits beside the memory telling it not to

`MEMORY.md` is 60 lines for 60 files with no orphans and no dangling links in
either direction — the index is structurally sound. Its *content* carries the
rot the memory two lines above it names.

| index line | measured 2026-09-02 |
|---|---|
| *"Health audit menu — HEALTH-AUDIT.md **F1-F22 ALL CLOSED** (PRs #516-#537)"* | `F23` filed and taken, PRs #538/#539, merged **08:59:54** |
| *"Audit outcome notes vary — … **all 200 findings** are closed"* | 201; and the body says *"across the **twelve**"* menus where the tree holds fourteen |
| *"Redesign audit menu — … N1-N4 and N6 still open"* | closed; see `F15` |

The `health-audit-menu.md` case is the cleanest specimen in this audit. The file
was last written at **08:42:18** and F23 merged at **08:59:54** — the line was
true for seventeen minutes. The file contains zero occurrences of `F23`.

Two lines above it in the same index sits *"Docs quote moving numbers — the
recurring doc rot; only test-pinned counts survive"*. Nothing in memory is
test-pinned. The rule is stated in the layer where it can never be enforced.

**Proposal.** One pass over `MEMORY.md` replacing every quoted finding count and
range with a shape — *"HEALTH-AUDIT.md, the repo-wide process+platform audit;
read its header for status"*, *"the outcome notes vary in wording; never grep
them"* — and one line added to
`audit-outcome-notes-vary-in-wording.md` recording that a memory index line about
a menu's status went stale in seventeen minutes, which is the argument for the
shape rather than the count. Fix the three lines above in the same pass.

**Posture:** rewrite index lines; **delete counts, add none.** Explicitly **no
new gate** — a check that memory agrees with the repo is the mechanical reader of
outcome notes that `audit-menu` spends a section arguing against, pointed at a
layer where it would be even less reliable.

**Evidence.** Memory layer against git history, 2026-09-02.

**Taken, 2026-09-02 (PR #551).** Posture as proposed: rewrite index lines, delete
counts, add none, and **explicitly no new gate** — a check that memory agrees
with the repo is the mechanical reader of outcome notes pointed at a layer where
it would be even less reliable.

Premises held. `health-audit-menu.md` was last written **08:42:18** and
`HEALTH-AUDIT` F23 merged at **08:59:54** — true for seventeen minutes, with no
occurrence of `F23` anywhere in the file. That menu then gained an `F24` two
hours later, so the line was wrong twice over by the time it was read.

**Six index lines rewritten, not three.** The finding named three; a sweep for
menu-status claims found six — `audit-outcome-notes-vary`, `efficiency-audit`,
`ingestion-audit`, `class-audit`, `health-audit` and `ui-audit` — each quoting a
finding range, a PR range or "all closed". Each now says what its menu is *about*
and sends the reader to the menu's own header. `redesign-audit-menu`, corrected
under `F15` an hour earlier, was brought into the same shape for consistency:
its line had still asserted a status, just an accurate one.

**Two files corrected beyond the index**, because the `description:` is the line
recall actually matches on and both carried the same claim: `health-audit-menu`'s
description dropped its finding range, and `audit-outcome-notes-vary`'s "all 200
findings across the twelve menus" is now marked as a **measurement of 2026-09-02
whose numbers moved within hours**, left standing as one rather than updated.
That is the measurement-versus-claim distinction from `F21`, applied inside
memory.

The new section in `audit-outcome-notes-vary-in-wording.md` records the
seventeen-minute case and draws the general rule: **a memory cannot hold a
status**, because nothing revisits a memory when the world moves — the layer is
written-once, read-by-relevance, and a menu's dated header is maintained by the
protocol. It also notes that `docs-quote-moving-numbers` sits two lines above in
the same index saying *only test-pinned counts survive*, and that nothing in
memory is test-pinned: the rule was being stated in the one layer where it can
never be enforced.

Index integrity re-checked after the pass: **60 lines, 60 files, no orphan and no
dangling link.**

---

### F17 — the book-ingestion batch protocol is a real, repeated workflow that exists in memory, an untracked prompt and a queue file, and in no skill

Running a book from PDF to merged is governed by four things. One is a skill.

| where | what it holds |
|---|---|
| `book-survey` (skill) | probe, cache, offsets, authority tables, diff, extract, reconcile, survey |
| `BOOK-INGEST-QUEUE.md` (repo) | the cross-session state: *"one session per book from here, each reading this file first and updating it last"*, and the `cached → surveyed → imported` ladder |
| `book-ingest-batch-protocol.md` (memory) | one session per book; data ships per book and only CODE waits; zero offset is now common |
| `BOOK-INGEST-PROMPT.md` (`Downloads`, untracked) | prompts A/B/C — the actual per-book session opener, run seven times |

`book-survey` mentions none of the other three. It ends at *"§7 Persist the
survey — it is the next session's boot file"*, which is right and incomplete: the
survey is per-book, and the queue is what tells a session which book, what state
it is in, and that deferred code goes to `BOOK-INGEST-AUDIT.md` rather than
blocking the import. A session that fires `book-survey` from its description —
which is the design — learns none of that.

The evidence that this is load-bearing is that it was written down anyway, three
times, in the three layers that were reachable at the moment each lesson landed.

**Proposal.** Add one section to `book-survey`, ~15 lines, after §7: name
`BOOK-INGEST-QUEUE.md` as the cross-session state file, state the
`cached → surveyed → imported` ladder and that a session updates it last, state
the batch rule (*import what the schema supports, record what was dropped in
`extraction_notes`, file the gap in `BOOK-INGEST-AUDIT.md`, keep going*), and
state that data ships with its book while only code waits. Then archive
`BOOK-INGEST-PROMPT.md` per `F18` and trim
`book-ingest-batch-protocol.md` to the parts the skill does not carry.

**Posture:** add a section to an existing skill. **Not a new skill** — this is
`book-survey`'s subject, and a second book skill would split the trigger surface
between two descriptions that both match "here is the PDF", which is the failure
`N3` is deliberately not proposing.

**Evidence.** Memory layer, live repo state, and session transcripts (the
prompt-A boilerplate recurring across the seven-book batch).

**Taken, 2026-09-02 (PR #557).** Posture as proposed: a section in an existing
skill, **not a new skill** — a second book skill would split the trigger surface
between two descriptions that both match "here is the PDF".

Premise verified precisely: before this, `book-survey`'s only occurrence of
`BOOK-INGEST` was a sentence added under `F5` an hour earlier. The queue, the
ladder and the batch rule appeared nowhere in it.

**One claim caught before shipping.** The draft said `BOOK-INGEST-AUDIT.md` *"is
a menu that stays open by design"* — present tense, and false: its header records
all 17 findings closed. Rewritten to say it **accumulates** open findings while a
batch runs, which is the durable rule, and to send the reader to its own header
for where it stands. Exactly the shape `F3` and `F21` are about, caught in a
sentence written to fix a different finding.

**The memory carried `F6`'s error too.** `book-ingest-batch-protocol.md` listed
*four* zero-offset books including `potm`, which the registry records at `1` —
the same base collision, in a third file, after the skill and
`pantheons-of-the-megaverse-survey.md`. Corrected to the three actually
registered at 0, with a pointer to the rule. **That is `F20`'s instruction
working the first time it was needed:** grep the whole tree, memory included,
when correcting something.

The memory was trimmed rather than deleted — it now opens by pointing at the
skill for the protocol and keeps only what the skill does not carry: that this
was Nathan's decision, the seven-book roster, and `underseas`'s negative split
being caused by **printed page 131 missing from its PDF**, a source defect no
re-run fixes and which nothing can cite.

`book-survey` is now **672 lines**, up from 585 when this audit measured it —
four findings have added to it today. `F8`'s split is more pressing than when it
was filed.

---

### F18 — a memory-only trap contradicts a step `class-import` prints as a command

`class-import` step 5:

```bash
node scripts/d1-apply.mjs --local apps/character-creator/db/add-<id>-class.sql
```

and step 3 prints `node scripts/class-check.mjs draft.md` with no flag.
`class-check` defaults to `--local`.

`local-d1-can-be-behind-too.md` (2026-08-31) records what that costs when local
is behind rather than ahead:

> On 2026-08-30 the local D1 held **293** skills against production's **345**…
> a missing row makes `class-check` report the skill as absent and print stub
> `INSERT OR IGNORE` SQL for it. `--emit-script` then writes those stubs into the
> `add-<class>-class.sql`, where they sort **before** the file that creates the
> row properly — so on a clean rebuild the stub wins and the real row is ignored.
> **Always pass `--remote` to `class-check` here.**

Three things make this worth a finding rather than a note. It **compounds two
traps the repo already documents separately** — local drift, and filename order
being execution order — into a third that neither section predicts. It is
**silent**: the stub parses, validates and ships. And the direction is new: every
other statement in the instruction surface describes local as *accumulating*
(`ship-pr:218`, *"Mine carried 327 skills where the repo and production both have
324"*; `CLAUDE.md`, *"It accumulates"*), which is the harmless direction.

The memory adds that `rebuild-local.mjs` does not fix it — it builds a separate
sqlite file, not the wrangler `--local` D1 `class-check` reads — and that
`--remote` is slow enough to time out a two-minute Bash call on four classes.

**Proposal.** Add `--remote` to the `class-check` invocations in `class-import`
steps 3 and 4, with three lines under *Rules that are easy to get wrong*: local
can be behind as well as ahead; behind is the dangerous direction because a
missing row becomes a stub that sorts before the real one; `rebuild-local.mjs`
does not fix it. Add one clause to `ship-pr`'s *`--local` is not a mirror*
section saying the drift runs both ways. Then trim the memory to the
2026-08-30 measurement and the `rebuild-local.mjs` fact.

**Posture:** rewrite two commands, add three lines and one clause. **No new
gate** — `--remote` as a default for `class-check` is a tooling change with its
own latency cost, and is not what this proposes.

**Evidence.** Memory layer against `class-import` and `ship-pr`, 2026-09-02.

**Taken, 2026-09-02 (PR #558).** Posture as proposed: two commands, three lines
and one clause. **No new gate** — making `--remote` the *default* for
`class-check` is a tooling change with its own latency cost and was not proposed.

Premises held: both `class-check` invocations in the loop were flagless,
`class-check` defaults to `--local`, and `ship-pr` described the drift in one
direction only.

**One thing worth stating that the finding left implicit.** The reason this is a
skill change rather than a tooling change is that the two directions are not
symmetrical and **neither is visible from inside the local database**. Extra rows
produce a false report you can dismiss; missing rows produce a *confident
instruction to create a bad row*, which `--emit-script` then writes into a file
that ships and which sorts before the file that would have created it properly.
That is `class-import`'s filename-order trap and `local` drift compounding into
a third failure neither section predicts on its own — which is why the new
paragraph sits in *Rules that are easy to get wrong* beside the sort rule, rather
than in a footnote about databases.

The latency cost is stated where the command is, not hidden: `--remote` is slow
enough to time out a two-minute call on four classes, so run them a couple at a
time. A session that hits that timeout and quietly drops back to `--local` is the
obvious way this fix fails, and saying so is cheaper than discovering it.

The memory is trimmed to what the skills do not carry — the timeout, and that
`rebuild-local.mjs` builds a *separate* sqlite file rather than the wrangler
`--local` D1 the app and `class-check` actually read.

---

## Layer 6 — the prompts

### F19 — the archive that fixed "the method is not in the repo" was already two briefs short on the day it merged, and one of them is a reusable template

`docs/prompts/` shipped 2026-09-02 at 07:33 (`a1bc5ee`, `HEALTH-AUDIT` F3) with
fifteen briefs, copied rather than moved, bytes preserved — verified: the blob
for `class-audit-prompt.md` is 5,069 bytes, byte-identical to the Downloads
original.

Two briefs that existed at that moment were not copied:

| file in `Downloads` | dated | produced |
|---|---|---|
| `CHANGE-PLAN.md` | 2026-09-01 13:16 | the whole Rust & Ash redesign — nine phases, PRs #484–#500, plus the module extraction and landing page |
| `BOOK-INGEST-PROMPT.md` | 2026-08-28 16:53 | prompts A/B/C for the seven-book batch; PRs across `phase-world`'s seventeen |

A third, `SKILLAUDITPROMPT.md`, produced this file and is likewise untracked.

`CHANGE-PLAN.md` is the larger omission by output: 23KB, seventeen PRs, and
`redesign-audit-menu.md` already records that three of its specifics were wrong in
the same way — *"a plan written against the app as imagined rather than as
built"* — which is exactly the divergence between-asked-and-built that the
archive's README says is the interesting part.

`BOOK-INGEST-PROMPT.md` is the more interesting one, because it is **not a
record**. Prompt B is a template run once per book, seven times, and it opens
with the `CLAUDE.md` pointer from `F11`. An instruction meant to be re-run,
living untracked in `Downloads`, is the precise condition F3 was filed about, and
it survived F3.

**Proposal.** One PR copying `CHANGE-PLAN.md`, `BOOK-INGEST-PROMPT.md` and
`SKILLAUDITPROMPT.md` into `docs/prompts/` with rows in its README table, bytes
preserved and originals left in place, as F3 did. In the same PR, add a line to
the README distinguishing the two kinds of file it now holds — **records** (a
brief that ran once; do not edit) and **templates** (a brief meant to be re-run;
`BOOK-INGEST-PROMPT.md` is the only one) — because the README's *"These are
records, not documents. Do not edit them"* rule is right for fifteen files and
wrong for that one. Then, per `F17`, fold prompt B's durable content into
`book-survey` so the template stops being the only home for it.

**Posture:** copy three files, add one README paragraph. **Documentation only.**
Do not add a check that `Downloads/*.md` is archived — the directory holds
mock-interview notes, statblocks and PDFs, and the judgement of what is a brief
is the whole content of the README's table.

**Evidence.** Live repo state (`cmp` of every `Downloads/*.md` against
`docs/prompts/`, 2026-09-02) and git history (`a1bc5ee`).

**Taken, 2026-09-02 (PR #559).** Posture as proposed: copy three files, add one
README paragraph, **documentation only**, originals left in place, and **no check
added** — the directory holds mock-interview notes and statblocks, and deciding
what counts as a brief is the whole content of the README's table.

Bytes verified rather than assumed: 23,152 / 11,235 / 6,513 in `Downloads`, and
the same in `docs/prompts/`. The originals are untouched, as F3 did.

**The records/templates split turned out to matter more than the finding argued,
because the template is already wrong.** `BOOK-INGEST-PROMPT.md` opens by telling
the reader to read the repo's `CLAUDE.md` *"it does not auto-load from
Downloads"* — a workaround `F11` removed this morning by adding
`~/.claude/CLAUDE.md`. So the one file here written to be **re-run** carries an
instruction that is now obsolete, and the README's *"do not edit them"* rule
would have preserved that obsolescence indefinitely. The README now says which
file the rule does not apply to, and why, and points at `book-survey` §8 — where
`F17` put its durable content an hour earlier.

**One thing the README gained that the proposal did not ask for**, because it is
the transferable lesson rather than this finding's particulars: *an archive
assembled by hand is missing something the day it lands*. This one was missing
three briefs within hours of being created, and the largest of them drove
seventeen PRs. That is worth a reader knowing before trusting the list to be
complete — which the closing *"Nothing requires a future prompt to land here"*
section, correctly, still declines to solve with a process.

---

## Cross-layer

### F20 — a menu header says a skill is wrong; the skill was fixed eleven minutes later and nothing corrected the header

`apps/character-creator/INGESTION-AUDIT.md`, header banner, added
**2026-09-02 07:55:48** (`db92adc`, `HEALTH-AUDIT` F8):

> **It also IS taken**, in PR #364, which is what produced
> `.claude/skills/audit-menu/SKILL.md`. **That skill still says F14 is open**; it
> was written while F14 was, and the sentence outlived it.

`.claude/skills/audit-menu/SKILL.md` was corrected at **2026-09-02 08:06:43**
(`9991425`, `HEALTH-AUDIT` F22, PR #534). It now reads *"**And it IS taken** — in
PR #364, which is the PR that produced this file"* and carries its own
parenthetical recording that the old sentence stood for five days.

The banner was true for eleven minutes. It now reads as a current statement about
a live file and is false, and it is the *first* thing a reader of that menu sees.

The protocol has a step for this and it was not applied across the layer
boundary: `audit-menu` step 5 requires correcting every **class note** that cites
a taken finding, in the same PR, because *"taking a finding falsifies the second
half wherever it was written down"*. The identical hazard for *another audit file
citing a skill* is not covered — `scripts/audit-citations.mjs` answers who cites
`F8` among classes and has no view of menu headers.

**Proposal.** Two parts, one PR.

1. Append `**Adjusted 2026-09-02**` under the INGESTION-AUDIT banner recording
   that the skill was corrected the same morning (PR #534), naming the current
   claim without quoting the replaced sentence — `audit-menu`'s *"Correct the
   current claim; never quote the stale phrase you replace"* applies literally
   here, and the banner is precisely a place where quoting it would defeat a
   later grep.
2. Add one sentence to `audit-menu` step 5 generalising the rule: **anything that
   cites a finding goes stale when the finding is taken** — a class note, a menu
   header, a memory file, a skill — and `audit-citations.mjs` sees only the first
   of the four.

**Posture:** **append**, do not edit, the banner; add one sentence to the skill.
**No new gate**, and specifically not a script that scans menus for citations of
other menus — that is the mechanical reader of outcome notes wearing a different
hat, and it is the thing `audit-menu` exists to argue against.

**Evidence.** Git history — commit timestamps on `db92adc` and `9991425`,
2026-09-02.

**Taken, 2026-09-02 (PR #552).** Posture as proposed: **append** the banner
rather than edit it, add the general rule to the skill, and **no new gate** —
specifically not a script scanning menus for citations of other menus.

Premises held to the minute: the banner landed at **07:55:48** and the skill was
corrected at **08:06:43**. True for eleven minutes.

**The general half turned out to be bigger than the finding described, and the
evidence for it was produced by this audit.** The finding proposed one sentence
generalising step 5 from class notes to "anything that cites a finding". Writing
it, the four kinds of citing file are worth a table, because
`audit-citations.mjs` covers exactly one of them — and **all three uncovered
kinds have gone stale in practice**, two of them within the hour:

- this banner, eleven minutes (`F20`);
- `MEMORY.md`'s health-audit line, seventeen minutes (`F16`, taken an hour
  before this);
- the `audit-menu` skill itself, five days (`HEALTH-AUDIT` F22).

So the section now says: grep the **whole tree** for a taken finding's number,
and check `~/.claude/.../memory/` as well, which no grep of the repo reaches.
That last clause is the one a session would otherwise never think of, and it is
where `F16`'s failure lived.

**No script, and the reason is already in the paragraph above it in that same
skill.** A mechanical reader would fire on every citation of a still-open
finding — correct, and useless. The grep is the tool; noticing is the work.

---

### F21 — three skills state the "do not quote a moving number" rule and three skills break it

Not a new defect; the pattern under `F3`, `F4` and `F5`, named once so it can be
decided once.

| skill | states the rule | breaks it |
|---|---|---|
| `claim-audit:27` | *"Sizes and class counts are deliberately not given here."* | `:8` 4,600-line README (`F3`) |
| `ship-pr:62` | *"a skill naming a moving number is wrong more often than right"* | — |
| `schema-change:53` | *"The cheaper habit is not to quote one."* | — |
| `class-import` | — | `:230` Fifteen scripts, `:14` 1100+ lines (`F4`) |
| `book-survey` | — | `:194` the only book (`F5`) |

The three that state the rule learned it the expensive way — `schema-change`'s
line is the outcome note of `HEALTH-AUDIT` F5, `claim-audit`'s of `DOCS-AUDIT`
D-work, `ship-pr`'s of a count that went stale on the next import. Each fixed its
own file and none generalised. `class-import` and `book-survey`, the two skills
that never had the failure, are the two carrying it now.

Worth naming separately because the fix is not three edits. **A quoted number
is not always wrong**: `book-survey`'s *"13 spells came back exactly one level too
high"* and `class-import`'s *"nine unmatched names on 2026-08-25"* are dated
measurements of things that happened, and are the strongest sentences in either
file. The distinction is between **a measurement** (past tense, dated, a record)
and **a description of the present** (*is*, *are*, *the only*), and only the
second kind rots.

**Proposal.** Add one short section to `claim-audit` — the skill that owns this
subject — stating the distinction in those terms, with one example of each drawn
from the skills themselves, and noting that the skills are inside `claim-audit`'s
own scope. That last clause is the load-bearing part: `claim-audit`'s *Where the
claims live* table lists the README, code comments, class markdown and
`docs/plans/`, and **does not list `.claude/`**, which is why five of this
audit's findings are in files a `claim-audit` pass would not have opened.

**Posture:** add a section and one table row. **Documentation only.** Distinct
from `F9`, which proposes the mechanical half; either can be taken without the
other, and if `F9` is closed for false positives this one still stands.

**Evidence.** Live repo state, 2026-09-02, and the outcome notes of
`HEALTH-AUDIT` F5 and F10.

**Taken, 2026-09-02 (PR #560).** Posture as proposed: add a section and one table
row to `claim-audit`, **documentation only**, and distinct from `F9`'s mechanical
half, which stands or falls separately.

**The finding's own table is already stale, and that is the right outcome.** All
three breaches it lists were closed earlier today — `F3` (#545), `F4` (#546),
`F5` (#547) — and re-checked before writing this: zero occurrences of any of the
three in the skills. So the section shipped here is not a fix for those; it is
the generalisation, which is what the finding actually argued for.

**The distinction is the content.** A dated past-tense **measurement** keeps
forever and is usually the strongest sentence in the file, because it is the
evidence for a rule. An undated present-tense **claim** rots. Stripping numbers
indiscriminately would have deleted the good half — and `F3` nearly did exactly
that, calling a correctly-past-tense sentence stale.

Two rules fall out of it, both learned in this batch rather than theorised:

- **Grep the whole file, not the paragraph.** `claim-audit` had deleted its own
  counts from one table and left the same figure three lines above and again at
  the bottom.
- **Do not restate the wording you replace.** Caught in this PR's own draft: the
  new table first quoted the three deleted claims verbatim as examples, which
  would have made the file findable for exactly the strings it teaches you to
  hunt. Paraphrased, with a parenthetical saying why — each stale string now
  appears **once** across all six skills, inside its dated record.

**`.claude/` is now in the *Where the claims live* table**, which is the half
that changes what a future pass looks at: five of this audit's findings were
sentences inside skills that a `claim-audit` run would never have opened, and
memory is worse still — no grep of the repo reaches it.

The closing note is the one worth keeping: **the three skills that state this
rule are the three that broke it.** Each had fixed its own file after being
burned and none had looked at the others'. Authoring a rule is not evidence of
following it.

---

## Opened while taking a finding

### F22 — the sheet-list drift check guards the list that never drifted, and not the one that did

Taking `F1` turned up a check in `smoke.mjs` — *"every derived combat row has a
labelled field on the sheet"* — that runs `derive.combat()` and asserts every key
it produces appears in `COMBAT_FIELDS`. Its comment names the bug it was written
for: *"That is exactly how Perception went missing."*

**There is no equivalent for saves.** `SAVE_FIELDS` is referenced exactly once in
the whole suite, at `smoke.mjs:4834`, and only to assert that `SAVE_ROLLS` is
derived from it by `.filter` rather than written out twice.

The asymmetry runs the wrong way. `sheet.js:14-15` records that the **saves**
list is the copy that has actually drifted:

> was not a shorter view chosen on purpose — it was the first list before three
> keys were added to `derive.js` and only one copy was updated.

So the side with a documented drift incident is unchecked, and the side that got
the check is the one whose incident the comment attributes to the other list.
Verified 2026-09-02: all sixteen keys `deriveSaves()` produces are currently in
`SAVE_FIELDS`, so nothing is broken now — this is the guard, not a defect.

**Proposal.** Add a check beside the combat one, in the same section, running
`deriveSaves()` and asserting every key it produces has a labelled row in
`SAVE_FIELDS` — excluding `psionics_target`, which the sheet renders separately
above the sixteen, and `other`, which is a list rather than a keyed number and is
skipped by the derived path on purpose. Same shape, same section, same failure
message.

**Posture:** new check, **fails the build**, matching its combat twin exactly. A
warn-only twin beside a build-failing original would be the posture mismatch
`audit-menu` warns about.

**Evidence.** Live repo state, found while taking `F1`, 2026-09-02.

**Taken, 2026-09-02 (PR #561).** Posture as proposed: a check beside the combat
one, in the same section, **failing the build** like its twin. Smoke 1,646 →
**1,647**.

Premises held. `derive.saves()` produces **17** keys; `SAVE_FIELDS` holds
**16**; the single difference is `psionics_target`, which the sheet renders
deliberately above the sixteen as its own `editField` — the number you roll
against rather than a bonus. It is excluded with that reason in a comment, as the
proposal specified.

**Proved by making it fail**, per `prove-a-check-by-making-it-fail`: removing the
`curses` row from `SAVE_FIELDS` produced

```
FAIL every derived save row has a labelled field on the sheet
     — curses - add it to SAVE_FIELDS in sheet.js, or the bonus lands in
       the data and never reaches the player
```

and restoring it returned the section to green. `sheet.js` was restored from a
byte copy and `git diff` confirms it untouched. A check that has only ever passed
proves nothing, and this one was written against a tree where nothing was broken.

**Nothing was found broken** — all sixteen derived keys are present today. This
is the guard, not a repair.

---

### F23 — no check asks whether the keys published CLASSES write can be rendered at all

`F22`'s check and its combat twin both start from `derive*()` — the rows the app
computes from attributes. A class-authored key is never in that set, so neither
check can see one. `bonuses.combat: { dogfighting: 2 }` passes `validateBonuses`,
is added by `addBonus`, appears in no `derive.combat()` output, and renders
nowhere. Both checks pass.

The hazard is documented in exactly one place in the repo, and it is the wrong
kind of place: `vacuum-wasp`'s `extraction_notes`, which is per-class data doing
an instruction's job. `F1` moved the doctrine into `frontmatter.md`; this is the
mechanical half.

Measured 2026-09-02 against production, 160 published classes, with a strict
frontmatter parse: **every** save key used is one of `SAVE_FIELDS`' sixteen, and
every combat key one of `COMBAT_FIELDS`' nineteen except `attacks_base`, which is
special-cased in `parser.js` and stripped in `derive.js`. **Nothing is broken
today**, which is the moment to add the check rather than the moment after.

**Proposal.** A check that parses every `bonuses.combat` / `bonuses.saves` map
out of the data scripts in `apps/character-creator/db/*.sql` — the repo's own
copy, so the check runs offline and needs no `--remote` — and fails on a key that
is in neither `COMBAT_FIELDS` / `SAVE_FIELDS` nor the special-cased set
(`attacks_base`, `saves.other`, `psionics_target`). The failure message should
name the class, the key and the two lists, and say that `saves.other` is the
escape hatch for a save the sixteen do not name.

**Prove it by making it fail** before shipping it: add `dogfighting: 2` to a
scratch copy, watch the check name it, then remove it. A check that has only ever
passed proves nothing, and this one is being written while the tree is clean, so
its passing run carries no information at all.

**Posture:** new check, **fails the build.** The parse must be strict about
quoted strings — a naive inline-`{ }` regex reads `vacuum-wasp`'s
`extraction_notes` prose as data and reports a key that is not there, which is
what happened while `F1` was being taken.

**Effort.** S. **Ongoing cost:** none; it reads two literal lists and the data
scripts.

**Evidence.** Live repo state and production, found while taking `F1`,
2026-09-02.

**Taken, 2026-09-02 (PR #562).** Posture as proposed: a check over the repo's own
data scripts, **failing the build**, offline, no `--remote`. Smoke 1,647 →
**1,649** in 112 sections.

**One deviation, and it is the whole reason this works.** The proposal said to
*parse the maps out of the SQL* and warned that the parse "must be strict about
quoted strings". Strictness is not the answer — the answer is not to regex at
all. The check runs `extractClassMarkdown` (already in `class-check-lib.mjs`) to
unwrap the SQL literal, then `parseClassMarkdown` — the **real parser** — and
reads `bonuses.combat` / `bonuses.saves` as structure. Prose cannot reach a
parsed object, so the vacuum-wasp trap is closed by construction rather than by a
better pattern.

It also covers two shapes a flat read would miss: `bonuses.at_level[]` entries
and `variants[].bonuses`, both of which carry their own `combat`/`saves` maps.

**Proved by making it fail, twice, in opposite directions:**

1. Injected `dogfighting: 2` into `vacuum-wasp`'s real `combat` map →
   `FAIL … bonuses.combat.dogfighting - add it to COMBAT_FIELDS/SAVE_FIELDS in
   sheet.js, or use saves.other / a special_ability`.
2. Restored the file — leaving the word `dogfighting` present **three times as
   prose** in that same file's `extraction_notes` — and the check passes.

That second half is the one that matters: it is the exact discrimination the
regex in `F1`'s first pass got wrong, and it now demonstrably holds.

A companion check asserts more than 100 scripts were actually parsed, so the
check cannot pass vacuously by extracting nothing — which is how a check like
this fails silently. 157 of 157 `add-*-class.sql` files yield markdown today.

**Nothing was found broken**, consistent with the strict re-measurement in
`F1`'s note. This is the guard.

---

### F24 — `CLAUDE.md` says Pages is dashboard-or-Chrome work; the Cloudflare MCP plugin reads and writes it directly

`CLAUDE.md` says, and the memory layer repeats:

> `pages project list` fails the same way and for the same reason, **which is why
> every Pages and Access change is dashboard work through Nate's Chrome.**

The **premise still holds** and is in this audit's healthy list:
`CLOUDFLARE_API_TOKEN` has no Pages scope and `npx wrangler pages project list`
exits 1, re-tested today. **The conclusion drawn from it does not.** On
2026-09-02, diagnosing `HEALTH-AUDIT` F24, the `cloudflare-api` MCP plugin —
which authenticates separately from the environment token and is enabled in
`~/.claude/settings.json` under `enabledPlugins` — served:

- `GET /accounts/{id}/pages/projects/nates-workshop` — the project, its
  `canonical_deployment` and `latest_deployment`;
- `GET .../deployments` — every deployment with `environment`, `latest_stage`,
  `stages[]` and trigger metadata, which is what identified the wedge;
- `GET .../deployments/{id}/history/logs` — build logs;
- `DELETE .../deployments/{id}` — **a write**, which is what cleared it.

So a Pages question is answerable, and at least one Pages action takeable,
without the dashboard. That matters beyond convenience: the stall was diagnosed
in one call where the documented answer was a hand-off to Chrome. It also gives
the *"let `whoami` tell you which credential answered"* doctrine in that same
section a **second credential** to be explicit about — `whoami` describes the
environment token and says nothing about the plugin.

**Unverified, deliberately: Access.** The sentence couples *"Pages and Access"*
and only the Pages half was exercised. Do not assume the plugin reaches Access
policies; this finding claims Pages and nothing more.

**Proposal.** Rewrite the coupled sentences in `CLAUDE.md` — the R2/Pages section
and the health-check section — to separate premise from conclusion: the
environment token has no Pages or R2 scope, unchanged; the `cloudflare-api` MCP
plugin is a second credential that does reach Pages, read and write; Access is
untested and stays dashboard work until someone tests it. Add one line on which
to reach for — `wrangler` for D1, the plugin for a Pages question, Chrome for
Access. Then correct `nates-workshop-production-url.md`, which carries the same
coupling.

**Posture:** rewrite two sentences plus one memory. **Documentation only, and it
widens nothing** — the plugin's reach already exists and the instruction layer is
simply wrong about it. Explicitly **not** proposed: adding the plugin's Pages
verbs to any allowlist, or using it to deploy. Deleting that deployment was
warranted and confirmed first, and `CLAUDE.md`'s own reasoning about actions that
should cost a deliberate keystroke applies to it exactly as it does to
`d1-apply.mjs`.

**Evidence.** Live incident, 2026-09-02 — four Pages API calls including one
write, against the claim in `CLAUDE.md` and `nates-workshop-production-url.md`.

**Taken, 2026-09-02 (PR #565).** Posture as proposed: rewrite the coupled
sentences plus one memory, **documentation only, widens nothing**. The token was
re-tested the same day and still cannot reach Pages — the premise is intact and
now dated where it sits.

**A three-row table replaced the "which to reach for" line the proposal asked
for**, because two credentials had been conflated into one sentence for weeks and
a sentence would invite the same collapse: `npx wrangler` for D1, the
`cloudflare-api` plugin for a Pages question or deployment, Chrome for Access.

**Access stays untested and the note says so twice** — in `CLAUDE.md` and in the
memory. The original sentence coupled *"Pages and Access"*, only the Pages half
was exercised, and the cheap error here would be replacing one over-broad claim
with another.

**One consequence added that the proposal did not name.** `CLAUDE.md`'s
health-check section teaches *let `whoami` tell you which credential answered* —
and `whoami` describes the environment token and is silent about the plugin. The
doctrine is right and now has a second credential it does not cover, which is
worth stating where the doctrine is. Also stated: a Pages **deploy** through the
plugin would still be the deliberate keystroke the allowlist section argues for,
exactly as `d1-apply.mjs` is. Reading Pages is now cheap; that is not a licence
to deploy from a script.

The memory's `description:` and its `MEMORY.md` line both carried the coupling
and both were corrected — those are the lines recall matches on, and `F16`
established that leaving them is how a correction fails to arrive.

---

### F25 — `zz-` no longer sorts after everything, and the sentence saying it does sits in the section about exactly that failure

`class-import`'s *Correcting a class that already shipped* spends a paragraph on
the sharpest silent failure in the repo — a clean rebuild applies
`apps/character-creator/db/*.sql` as one sorted glob, so **filename order is
execution order**, and a correction sorting before the file it corrects is
undone on every rebuild with no error. `fix-long-bowman-armor.sql` sorting before
`fix-long-bowman.sql` is the worked example, and only `repo-vs-live.mjs` caught
it. The paragraph ends:

> `zz-` exists as a prefix for exactly this: a file that must sort after
> everything.

**That is now false.** Prefix census of the 359 scripts, 2026-09-02:

| prefix | files |
|---|---|
| `zz-` | 13 |
| `zzz-` | 9 |
| `zzzz-` | 14 |
| `zzzzz-` | 2 |

The escalation has happened **three times** since `zz-` was adopted, and nothing
recorded it. Measured directly: a new `zz-my-new-fix.sql` sorts **before 35
existing files**. A session that follows the sentence gets a file it believes
runs last and which 35 files run after — which is the precise failure the
surrounding paragraph exists to prevent, produced by the paragraph's own advice.

Nothing is known to be broken by it today; this is the instruction being wrong,
not a diagnosed defect. Whether any of the 35 actually conflicts with a `zz-`
file's intent has not been checked, and checking it is part of taking this.

**Proposal.** Two parts.

- **(a)** Replace the sentence with the method rather than a prefix: the `sort`
  one-liner already printed three lines above it **is** the answer, and it is the
  only thing here that cannot go stale. Say that a `z`-prefix buys position
  against what exists today and nothing more, and that the tier has escalated
  three times.
- **(b)** Decide whether the escalation is a convention worth keeping or a smell.
  A fifth tier is the obvious next step and is not obviously right; a
  `zzzz-`-and-done rule, or numbering by intended run order, or making the
  rebuild order explicit rather than lexical, are the alternatives. **This half
  is a design decision, not a documentation fix, and should not be taken as
  one.**

**Posture:** (a) rewrite one sentence, documentation only. (b) **open question,
no change proposed.** Explicitly not proposed: a check that files sort correctly
— "correctly" depends on what each file intends to override, which is not
mechanically knowable.

**Evidence.** Live repo state, found while taking `F4` — the prefix census run to
check one of my own replacement sentences falsified one of the skill's, three
paragraphs below the line being edited.

**Taken in part, 2026-09-02 (PR #567): part (a) only. Part (b) CLOSED by
decision, not deferred** — Nate chose documentation only, leaving the four tiers
as they are. Recorded so it is not re-proposed: the escalation is untidy and has
never actually broken anything, and every alternative is a migration of applied
one-shot scripts, which is the category `repo-vs-live.mjs` exists to catch.

Shipped: the sentence claiming `zz-` sorts after everything is gone. In its place
— **a `z`-prefix buys position against what is in the directory today and nothing
more**, the tier has escalated three times, and a new `zz-` file now sorts
**before three dozen** others. Nothing announced that and nothing will announce
the next one.

**The replacement points at the command instead of a prefix**, which is the
durable half: the `sort` one-liner already sits three lines above the sentence,
costs nothing, and is right on the day it is run whatever anyone added since. The
instruction is now *run it, read where your name lands, pick a prefix that puts
you after what must not undo you* — and explicitly **do not reason from the
convention**.

No count is quoted in the skill. "Three dozen" is the shape; the census is here.

---

# New skills

Ranked by evidence, most-supported first. `N1`–`N3` are backed by recurring,
documented pain. `N4`–`N8` are speculative and labelled so; two of them I would
argue against.

### N1 — a `verify-ui` skill: how to prove a change in the browser on this machine

**The gap.** All six skills are D1-, book- and process-shaped. `ship-pr` step 4's
entire coverage of the visual layer is four words: *"changed anything visible:
drive it in a browser."* Nothing says which browser, which port, what the browser
pane cannot do, or how to render print media.

**The evidence is the densest of any proposal here — six memories, none of which
has a home in a skill:**

| memory | what it holds |
|---|---|
| `screenshot-before-declaring-ui-done` | metrics said the tabs worked; the screenshot showed them 1,300px below the fold |
| `browser-pane-input-limits` | it focuses but cannot activate, blanks when SCROLLED, `read_page` prints values not names |
| `print-render-headless-chrome` | `--print-to-pdf` renders real print media; it falsified `UI-AUDIT` F17 outright |
| `fixed-table-layout-clips-controls` | measure a control against the CELL, not the page |
| `play-mode-rolls-write-to-production` | a roll POSTs a `play_events` row; verify prod by reading, not clicking |
| `dev-server-8788-is-another-worktree` | the port trap, and snapshot the server-side wizard draft before walking |

Plus two whole menus produced by looking at screens (`UI-AUDIT.md`, 29 findings;
`REDESIGN-AUDIT.md`, 15) whose headers both record method problems a skill would
have prevented: REDESIGN's *"produced by READING CODE, not by looking at
screens… No dev server, no screenshot"*, and UI-AUDIT's F17 closing as moot
because a real print render showed the defect was not there.

**Cost.** ~130 lines, one file, no reference. Fires on "does this look right",
"check the sheet", "screenshot it", a UI audit, and any CSS or template change.
Ongoing: it will need touching whenever the browser tooling changes, which on
this evidence is a few times a season.

**Rank: 1.** More independent recorded failures than any other proposal, and
`ship-pr` is currently silent on all of them.

**WRITTEN, 2026-09-02 (PR #568).** `.claude/skills/verify-ui/`, junctioned,
and a row in `CLAUDE.md`. All six memories are represented and none was
copied wholesale — each contributes the rule and the incident that produced it.

**Two things emerged from writing it that the proposal did not list.** The
`verify-ui` sections fall naturally into *before* (which port, and confirm the
page is yours), *during* (the pane's three lies, the fold, the right box to
measure against) and *after* (print, and what writes on production) — so the
skill is ordered by when you need each rather than by which memory it came from.
And the **production-writes** rule turned out to be the one with real
consequences: a single roll click to prove a fix put a `play_events` row in
Nate's real character log with no DELETE route, and it had to come out of
production D1 by hand. That is the section a session is most likely to skip and
least able to undo.

---

### N2 — a `windows-shell` skill: the traps that have corrupted commands and commits here

**The gap.** `ship-pr` has the best of them — backticks in `git commit -m`
evaluated by the shell, `git add -A` before `--amend` sweeping the message file
in, `\"` not escaping in PowerShell, `--file` returning a summary instead of
rows, reading results from a file. They are correct and they are scattered
through a skill about pull requests, so they only arrive if you are shipping one.

**Four more live only in memory**, and every one is a silent corruption:

| memory | what it holds |
|---|---|
| `sed-i-strips-crlf` | flips whole files to LF; **the obvious grep check reports clean anyway** |
| `latin1-truncates-new-nonascii` | safe for existing bytes, silently mangles em-dashes you add |
| `bash-tool-collapses-double-backslash` | inline heredocs mangle Windows paths; use the Write tool |
| `kill-wrangler-parents-not-listeners` | `taskkill` on the port PID kills `workerd` children that respawn; 15 dev servers accumulated |
| `interactive-shell-lacks-npm-path` | my tools see `%APPDATA%\npm`, his PowerShell does not |

The first two are the strongest argument for the skill: both defeat the check you
would naturally run to detect them, on a repo where `.gitattributes` pins `.sql`
to LF *because a CRLF checkout once changed the bytes that reached production*.

**Cost.** ~90 lines. Fires on any file rewrite, any shell loop, any commit.
Ongoing: near zero — these are properties of the machine, not the repo.

**WRITTEN, 2026-09-02 (PR #568), with the move the proposal insisted on.**
`ship-pr` **lost** its shell material rather than gaining a duplicate: the
commit-message backticks, the `git add -A` amend trap, the three PowerShell
query traps and the line-ending rule are now one-line pointers into
`windows-shell`. That was the finding's condition — *do not duplicate it, which
is this audit's `F1` in miniature* — and it is why `ship-pr` came out shorter.

**Rank: 2.** Five recorded incidents; two of them silent. The counter-argument is
real: `ship-pr` already carries the commit-message traps and splitting them
across two skills means a session shipping a PR may load only one. **If taken,
move the shell material out of `ship-pr` and leave a pointer** — do not duplicate
it, which is this audit's `F1` in miniature.

---

### N3 — `pick3cut5`: the Access wall, the Worker, and the deploy a merge does not do

**The gap.** Three apps have no skill. They are not equally uncovered.

`pick3cut5` has produced a recurring, production-visible trap with findings in
two separate menus and a memory of its own:

- the app shipped bypassed on its own two paths but not `/shared/styles.css` or
  `/shared/js/ui.js`, so every friend with a room code got an unstyled page and
  `escHtml is not defined` at the first flip — while `curl /apps/pick3cut5/`
  returned 200 the whole time (`ship-pr:44-52`);
- the path derivation reads HTML only and cannot see CSS-referenced assets
  (`REDESIGN-AUDIT` N6, memory `access-bypass-is-blind-to-css-assets`);
- the bypass prefix served the gated landing page to anyone (`HEALTH-AUDIT` F15);
- `workers/pick3cut5-room` **produces no check-run at all — a merge does not
  deploy it** (`HEALTH-AUDIT` F23, `ship-pr:139-149`), and it holds the key, the
  money path and the rate limiters with 2.5% test coverage (`HEALTH-AUDIT` F16).

`media-vault` and `filament-forge` have been quiet since their standardizations
closed on 2026-08-26, and both are pinned by their own smoke tests.

**Cost.** ~110 lines, one file. Fires on any change to `apps/pick3cut5/`,
`workers/pick3cut5-room/`, `shared/`, or any Access policy.

**WRITTEN, 2026-09-02 (PR #568).** One skill, not three — `media-vault` and
`filament-forge` still have no recorded pain to teach from, and a skill written
from nothing is the procedure-only kind this brief warns about.

**Rank: 3.** Four documented incidents, three of them reaching production. **I am
proposing one skill, not three** — media-vault and filament-forge have no
recorded pain to teach from, and a skill written from nothing is the
procedure-only kind `SKILLAUDITPROMPT` warns about: a session would follow it
correctly and get burned anyway.

---

### N4 — `deploy-verify`: the sweep, the check-runs, and the two deploy paths

**Speculative, and I would argue against it.** The material exists —
`ship-pr`'s *The deploy is not guaranteed* is 45 lines and correct, `deploy-sweep.mjs`
is built and allowlisted, `HEALTH-AUDIT` F2 and F23 are both taken. The case for
lifting it out is that it fires only when someone is thinking about a PR, and the
four-day outage happened because *nobody read a signal that was never ambiguous* —
65 consecutive `Cloudflare Pages=failure` — at a merge rate that has twice passed
45 a day.

The case against is stronger: a separate skill would have to be triggered by
something, and the only honest trigger is "you just merged", which is exactly when
`ship-pr` is already loaded. Splitting it moves the step further from the moment.

**Cost if taken:** ~70 lines, mostly moved. **Rank: 4, recommend closing rather
than taking.** Recorded so the negative result is not re-derived — the shape
`REBUILD-AUDIT` F16 uses.

**DECLINED, 2026-09-02.** Nate's call, and it matches the recommendation. The
negative result stands as the record: the material is right and its only honest
trigger is *"you just merged"*, which is exactly when `ship-pr` is already
loaded. Splitting it would move the step further from the moment. Do not
re-propose without a new failure.

---

### N5 — `catalog-import`: skills, spells, psionics and gear, as distinct from classes

**Speculative, moderately supported.** `class-import`'s description claims this
ground — *"and when importing skills, spells or gear from a book"* — and its body
is almost entirely about a class: the frontmatter contract, `class-check`,
`CORE_SDC_BY_CLASS`, `add-<id>-class.sql`. Catalog-row guidance is split between
`reference/catalog.md` (126 lines, last edited **2026-08-24**, the oldest
reference file bar the SQL skeleton) and `book-survey` §3.

The evidence that this is real: `phase-world` alone shipped 9 skills, 47 gear
rows, 15 psionic powers and 8 re-citations across eleven data PRs, and the
`STUB — created by class import, needs stats` marker exists precisely because
gear arrives through the class path and has to be recognised later as unfilled.

The evidence that it is not: no recorded failure attributable to the split. The
catalog traps that *have* bitten — the `Robots & Power Armor` rename breaking
seven restrictions, the stub-shadowing in `F18` — are already in `class-import`
or belong there.

**Cost:** ~120 lines plus moving `reference/catalog.md`. **Rank: 5, take only if
a catalog-only import goes wrong first.**

**DECLINED, 2026-09-02**, on its own condition: no catalog-only import has gone
wrong. The ground is real — `class-import`'s description claims it and its body
is almost entirely about a class — but every catalog trap that has actually
bitten is already in `class-import` or belongs there. **Revisit if a
catalog-only import produces a defect**, which is the trigger this proposal
named for itself.

---

### N6 — `write-a-memory`: what belongs in memory rather than a skill

**Speculative.** `F1`, `F15`, `F16` and `F17` are four instances of one thing:
durable, general lessons landing in the layer that fires by relevance, sometimes
asserting the fix already landed in the layer that fires by name. The rule is
simple enough to state — *if it will be true next month and applies to work you
will do again, it belongs in a skill; memory is for what is true about this
machine, this account, this book* — and there is no obvious trigger for a skill
whose subject is writing memories.

The strongest version of this is not a skill at all: it is one paragraph appended
to `claim-audit`, which already owns "sentences that stop being true", extended
to say the memory directory is in scope. `F21` proposes adding `.claude/` to that
skill's table for the same reason.

**Cost:** ~50 lines, or ~8 folded into `claim-audit`. **Rank: 6, prefer the
paragraph.**

**DECLINED as a skill, 2026-09-02 — and its substance already shipped.** `F21`
put the measurement-versus-claim distinction into `claim-audit` and added
`.claude/` and the memory directory to *Where the claims live*, and `F20`
added *grep the whole tree, memory included, when a finding is taken*. That is
the paragraph this proposal preferred to a skill, arrived at from two other
directions. Nothing further is outstanding.

---

### N7 — `new-app`: standing up a fourth app in this monorepo

**Speculative, weakly supported.** Two standardizations (`filament-forge`,
`media-vault`) followed a shape nobody wrote down: D1 with a table prefix, a
smoke test that pins the app's own README, an Access policy, a launch config, a
row in the root `index.html`. Both are closed and neither recorded a
generalisable procedure.

Against: no third instance is planned, and a skill written from two examples with
no failure to teach from is the procedure-only kind. **Cost:** ~80 lines.
**Rank: 7, do not take without a third app.**

**DECLINED, 2026-09-02**, on its own condition: there is no third app planned.
Two standardizations are not a pattern, and a skill written from two examples
with no failure to teach from is the procedure-only kind this brief warns
about — a session would follow it correctly and get burned anyway.

---

### N8 — `cloudflare-access`: the wall, the bypasses, and what the token cannot reach

**Speculative.** The material is real and scattered across `CLAUDE.md` (the
token cannot do R2 or Pages, re-verified below), `SETUP.md` (destinations, and
`REDESIGN-AUDIT` N7/N8 both about that file being wrong on the count), memory
(`nates-workshop-production-url` — production and the dashboard go through real
Chrome; previews sit behind their own policy), and `ship-pr` (the bypass check).

Against: every Access change is dashboard work through Nate's Chrome, so a skill
would be advising on a surface it cannot touch, and `N3` would carry the half
that matters for the one app with public paths. **Cost:** ~70 lines.
**Rank: 8, fold what is worth keeping into `N3`.**

**DECLINED, 2026-09-02, and the fold happened.** `N3`'s `pick3cut5` skill
carries the Access material that has actually cost something: the bypass being a
list of paths rather than pages, the five-destination limit, the prefix-match
that answers 200 with the landing page, and verifying with no Access session. The
remainder is dashboard work through Nate's Chrome, which a skill cannot perform —
and `SKILL-AUDIT` F24 has since established that Pages, though not Access, is
reachable without it.

---

# What was checked and found healthy

Recorded so it is not re-derived. Every item below was verified on 2026-09-02.

- **`schema-change` is clean.** All nine "places", both file paths and all six
  named smoke-check strings exist verbatim in
  `apps/character-creator/test/checks/`. The one count it used to quote was
  removed by `HEALTH-AUDIT` F5 and the replacement sentence is correct.
- **`ship-pr` is clean on mechanics.** `git config remote.origin.prune` is
  `true`; `--section` and `PARTIAL SMOKE PASSED` both exist
  (`test/harness.mjs:84`); every test path it names exists; the
  `gh api …/commits/*` command matches the allowlist entry.
- **Every path any skill names exists.** 34 checked — every script, every `js/`
  and `functions/` file, every test, every reference.
- **`CLAUDE.md`'s Cloudflare section holds, re-tested rather than reasoned
  about.** `npx wrangler whoami` exits **0**, prints the account name and ID and
  states *"The API Token is read from the CLOUDFLARE_API_TOKEN environment
  variable"*. `npx wrangler r2 bucket list` and `npx wrangler pages project list`
  both exit **1** with the membership-roles fallback the file describes. All
  three claims were last verified 2026-08-25 and all three still stand.
- **The junctions are intact.** Six skill junctions plus one agents junction, all
  resolving into the repo; no divergence is possible. See *What contradicts the
  premises*.
- **`MEMORY.md` is structurally sound** — 60 lines, 60 files, no orphan file and
  no dangling link. Only its *content* is stale (`F15`, `F16`).
- **`audit-menu`'s file table is right about thirteen of fourteen rows**,
  including both not-a-heading families (`CLASS-AUDIT`'s nine `S` bullets and
  `pick3cut5/AUDIT`'s eleven `T` bold leads), verified against each file's own
  headings. Only the `DOCS-AUDIT.md` cell is wrong (`F7`).
- **The survey template is followed.** `reference/SURVEY.md`'s heading structure
  matches the ten surveys in `docs/surveys/`; the six cached books with no survey
  are cache-only **by design**, as `BOOK-INGEST-QUEUE.md` states.
- **All fourteen existing menus are closed.** Read under the headings, not
  grepped. `HEALTH-AUDIT.md` gained and closed `F23` on 2026-09-02.

---

## Opened while building the verifier agents

Filed 2026-09-04, out of PR #676, which added four read-only subagents and wired
them into three skills. Not opened by taking a finding — nothing on this menu was
being taken — so they sit here rather than in the section above.

**No new subagent is proposed by any of these.** Nate declined a `ship-verify`
subagent on 2026-09-03 (`SHIP-PR-AUDIT.md` header, *"do not re-propose without a
new failure"*), agreeing with `N4` below, and that decision stands untouched:
these three are about agents that already exist and about two sentences
describing them.

### F26 — `SETUP.md` and `CLAUDE.md` say a new agent works "the moment its file lands"; the junction is instant and the harness is not

Both sentences are about the directory junction and both are true about it.
`SETUP.md`, *Setting up a machine*: **"A new agent needs nothing: the directory
junction covers it the moment the file lands."** `CLAUDE.md` line 42: **"So a new
agent is covered the moment its file lands."**

Read as *"so you can use it"* — which is how a session writing an agent will read
them — they are wrong. An agent file written during a session is **not spawnable
in that session**. The file is on disk, it is visible through the junction, and
the harness still answers `Agent type '<name>' not found`.

This cost a measurable thing rather than a hypothetical one: an eval intended to
run against a purpose-built blind agent had to be re-done with `general-purpose`
and the method pasted into the prompt, because the agent written for it never
became available.

**Proposal:** add one sentence to each of the two passages — the junction covers
a new agent file immediately, but the harness registers agent files at a turn
boundary, so an agent written mid-session cannot be spawned until the next turn.
Put it beside the existing sentence in each file rather than in a new section.
**Posture: documentation only. No new gate, no check, no script.**

**Evidence.** Measured 2026-09-04 in the session that filed this: three spawn
attempts across two agent files (`zz-eval-blind`, `zz-skill-tool-test`), each
returning `Agent type '<name>' not found` while `ls ~/.claude/agents` listed the
file. Both later registered, announced by a system notice, at the next turn.

**Confidence: high that the behaviour is real** — three observations, two files,
and both eventually registered. **Medium on the mechanism.** "Turn boundary" is
what was observed, not a documented contract; a periodic sync that happened to
align with the turns would look identical. What would raise it: write an agent
file, then run several tool calls without a user turn, and see whether it appears
without one.

**Ongoing cost:** two sentences to keep true if the harness changes, sitting
beside sentences already being maintained. Low.

**Taken, 2026-09-04 (PR #679). Posture held: documentation only — two sentences,
no gate, no check, no script.** Taken as written, in **both** files, rather than
the one-file version I would have preferred: `audit-menu` says as written, scope
and posture both.

**The confidence-raising test named in the finding was run first, and it moved
the answer.** `F26` filed at *medium on the mechanism* — "turn boundary" was
observed, and a periodic sync that happened to align would have looked identical.
The test it asked for was: write an agent file, then run several tool calls
without a user turn.

| attempt | elapsed since write | intervening work | result |
|---|---|---|---|
| 1 | ~0s | none | `not found` |
| 2 | ~52s | character-creator smoke, 1665 checks | `not found` |
| 3 | ~82s | four more suites and `deploy-sweep`, 10+ tool calls | `not found` |

Written 12:00:52 UTC, probe removed 12:02:43. `ls ~/.claude/agents/` listed the
file at T0, so the junction half really is instant. **It is not elapsed time and
not tool-call count**, and four separate agent files have become available at a
turn boundary and none before one. Confidence on the mechanism is now high, and
both sentences carry the measurement rather than the claim.

**One thing the test could not separate**, said in the sentences: *a turn* is
what correlates. Anything else that happens at a turn boundary would look the
same. The actionable half — write it in one pass, use it in the next — does not
depend on which.

**A hazard found while doing it, worth more than the finding.** The probe file is
`.claude/agents/zz-registration-probe.md`, and **a stray `.md` there is not
gitignored** the way `*.tmp` is. A `git add -A` between writing a probe and
deleting it would commit it into the live instruction surface, where the agents
junction publishes it to every session on the machine. Nothing catches that.

### F27 — a subagent CAN load a project skill by name, and all five agent files are written as though it cannot

Every file in `.claude/agents/` inlines its guidance and points at a `SKILL.md`
by path for the detail. That shape was chosen because whether a subagent could
hold the `Skill` tool was untested on this machine. It is now tested, in both
forms that matter, and the answer is yes.

**Evidence.** Two probes, 2026-09-04, each with a deliberate control:

| probe | tools | result | control `no-such-skill-xyzzy` |
|---|---|---|---|
| `general-purpose`, cwd `C:\Users\natha\Downloads` | `*` | listed all nine project skills; loaded `claim-audit` and `windows-shell`, returning body text | `Unknown skill: no-such-skill-xyzzy` |
| purpose-built probe | `Read, Skill` | loaded `claim-audit`, returning body text | `Unknown skill: no-such-skill-xyzzy` |

Both resolved from `C:\Users\natha\.claude\skills\…` — the junctioned copies,
from a directory that is not the repo. The restricted-list probe answers the
narrower question: `Skill` is accepted as a **named entry**, not only under `*`.

Relevant measurement already on record: `EFFICIENCY-AUDIT.md` `F1`(3) found that
across the book sessions the Skill tool invoked a repo skill **4 times total**
while `SKILL.md` files were `cat`-ed into context **73 times (283K chars, ~71K
tokens)**.

**Proposal:** decide **per agent** whether to drop inlined guidance and add
`Skill` to its tools list instead. Not a blanket change, and the arithmetic cuts
both ways: `audit-menu` is 676 lines and `book-survey` 656 (`wc -l`, 2026-09-04),
and a loaded skill is paid on **every** invocation, so for a high-volume verifier
the ~40 inlined lines may still be cheaper than loading a 250-line skill per
slice. **Posture: opt-in, per agent, frontmatter and documentation only. No new
gate.**

**Confidence: high that skills load** — two probes, two tool shapes, controls in
both. **Low that swapping is net-positive for any particular agent.** What would
raise it: run one agent both ways against `.claude/skills/claim-audit/reference/negatives.md`
and compare tokens as well as verdicts.

**Ongoing cost:** none if declined. If adopted for an agent, that agent's
guidance lives in one place instead of two, which is a reduction rather than a
cost — offset by the per-invocation size above.

**Taken, 2026-09-04 (PR #680). Posture held: opt-in and per agent — frontmatter
and documentation only, one agent changed, no gate, no script, no code.**

**Scope: `audit-premise-auditor` only**, on Nate's word and on the arithmetic
this finding asked for. It fires **once per finding**, so paying `audit-menu`'s
676 lines per invocation costs almost nothing, and that skill is precisely the
procedure the agent was duplicating. The other three are deliberately untouched:
both claim verifiers run per-slice at volume, where loading a 271-line
`claim-audit` on every call is the wrong trade, and `book-extract-worker`
deliberately does **not** map to catalog vocabulary, so it never needed
`class-import` at all.

`tools:` gained `Skill`; the agent now invokes `audit-menu` before reading the
finding, and the file says outright that **the skill is the authority and the
agent does not restate it** — so the two cannot drift into disagreeing, which was
the standing cost. The file went **110 lines to 80**, and what left was exactly
the duplicated half: outcome notes never being grepped, the not-a-heading menus,
the bare-number ambiguity, the posture definition, and which script covers which
part of the citation sweep. What stayed is what the skill does not own — that it
is a second reader with no write tools, the order to work in, and the return
contract.

**Not verified in the PR that made it, and this is `F26` biting the session that
had just documented it.** A tools change to an existing agent is a change to an
agent file, and an agent file is not re-read until a turn boundary, so the
swapped agent could not be spawned in the session that wrote it. **The first real
invocation is the verification, and it is owed.** What would settle it: run it on
a finding whose answer is known and confirm from its own report that `audit-menu`
loaded — the same shape as the probes in `F27`'s evidence, which quote a heading
back as proof rather than reporting success.

**Verified 2026-09-04 (PR #683). The debt above is paid and the swap works.**
The agent was run on `F30` — real work rather than a rehearsal — and reported
back, unprompted by anything but its own contract: first heading
`# The audit-menu protocol`, and the sentence *"Grepping for `Taken` has produced
false findings here repeatedly, and in both directions — work reported open that
had shipped, and work reported closed that had not."* It then re-read four
sections straight off `~/.claude/skills/audit-menu/SKILL.md` with `sed -n` and
confirmed the injected text matched the file, which is a better check than the
one asked for: it proves the skill arrived intact rather than merely arrived.

**Three things this settles beyond the swap.** `Skill` works in a restricted
`tools:` list under real load, not only in a probe. The skill resolves for a
subagent whose working directory is not the repo. And an agent that loads a
skill can be held to it — this one quoted the authority back at its own
frontmatter, which is the next paragraph.

**The verification found a defect in the agent it was verifying, which is the
argument for `F27` in one line.** Its frontmatter says *"the record is unanimous:
every finding taken so far has turned up an error in its own premises."*
`audit-menu` says the opposite by name — *"Plenty of notes here record premises
that held exactly"* — and lists twelve. The agent noticed the contradiction
**because it had just loaded the skill**, and noted that its own file contradicts
itself two paragraphs later. Inlined, it would have had nothing to check that
sentence against. Filed as `F34`.

### F28 — all four agents added in #676 shipped without ever being invoked

Three of them have never run at all, and the fourth has never run **as itself**.
The eval that scored the capability method used a *blind copy* of that method
inlined into `general-purpose`, because the shipped agent's own body told it to
read the answer key. So `reference/negatives.md`'s 9/9 result describes the
method, not the agent file.

That is not an argument that they are broken. It is a record of what has and has
not been exercised, filed because the menu is the only place it would otherwise
be written down.

**Proposal:** run each once on a real, low-stakes task and record the outcome —
`claim-count-verifier` on one README section, `claim-capability-verifier` on the
fixture as itself now that the answer-key pointer is gone,
`audit-premise-auditor` on a closed finding whose answer is already known, and
`book-extract-worker` on one chapter of a cached book. **Posture: verification
only. No code change, no new gate.** A reasoned decision to delete an agent that
does not earn its place is an acceptable outcome of this, and
`book-extract-worker` is the likeliest candidate — it was filed as
lower-confidence in its own brief.

**Evidence.** PR #676, merged 2026-09-04 as `6a8463c`, Pages `completed/success`.
The eval method and its three limits are recorded in
`.claude/skills/claim-audit/reference/negatives.md` under *The run of
2026-09-04*. Not measured: anything about how the four behave when invoked,
because none has been.

**Confidence: high.** It is a record of what was run, not an inference. Nothing
would raise it; running them closes it.

**Ongoing cost:** none. One-time, and it ends either in four exercised agents or
in fewer agents.

**Taken, 2026-09-04 (PR #678). Posture held: verification only — all four were
run, nothing was fixed, no code changed and no gate was added.** All four earn
their place, and none is proposed for deletion. **Every one of them found
something on its first run**, which is the result that was not guaranteed.

| agent | task | outcome |
|---|---|---|
| `claim-count-verifier` | every count in README `## The scripts at the repo root` | **1 stale claim** out of ~12 checked, 0 unsettled |
| `claim-capability-verifier` | the six fixture records, as itself | 6 HOLD, 0 stale, 0 unsettled — **and it met the trap** |
| `audit-premise-auditor` | `REPO-AUDIT` `G8` | killed the task as posed, then **4 disagreements** |
| `book-extract-worker` | `ww` printed 44–45 | 0 rows, **and it refused to invent any** |

**The premise about the answer-key pointer held.** `claim-capability-verifier`
ran as itself and reported *"I did not open `reference/negatives.md`; it surfaced
as a path in one grep hit list and was not read."*

**The near-match requirement added after the blind eval did the job it was added
for.** The eval's recorded limit was that neither model looked in `gear`, so a
clean score never exercised the discrimination. Run as itself, the agent found
and rejected **two** near-matches — the eight `gear` rows matching `%poison%`,
and `gear` id **10485 `Large Axe`**, an exact-name hit nobody had noticed in any
prior pass. It also checked `catalog_redirects` for aliases. The limit recorded
in `negatives.md` is now closed by measurement rather than by argument.

**`book-extract-worker` did the thing it was written to do**, which was not to
find rows: printed 44–45 of `ww` is narrative prose, it returned **zero** rows,
said so, and named the decision rather than padding. It read `page_offset` from
**both** `books.json` and the cache manifest, caught that cache `p044` carries
**no folio digit at all** in the OCR footer band and flagged that as a gap rather
than assuming, and reported both boundary-straddling items — the governing
heading sitting on printed 43, and *Dimensional Doorways* continuing onto 46.

#### What the runs turned up that is NOT this finding

Recorded here because the exercise produced them; **none is fixed in this PR**,
which would have broken the posture. Each needs its own finding and its own word.

- **Four live-instruction files say `main` has no ruleset, and one of them
  contradicts itself.** `CLAUDE.md:9`, `SETUP.md:6`,
  `.claude/skills/ship-pr/SKILL.md:18` and `.github/workflows/tests.yml:4` all
  say *"no ruleset"*; `tests.yml:113` says *"`main`'s ruleset requires a pull
  request"*. Verified independently of the agent, 2026-09-04:
  `gh api repos/NateGrey0130/nates-workshop/rulesets` returns **`22209348`,
  "main: require a pull request", active, created 2026-09-03T12:46:10-04:00** —
  five minutes after `G8` merged. **The substance of `G8`'s posture still
  holds**: the ruleset carries one `pull_request` rule and **zero**
  `required_status_checks`, so nothing gates a merge on a red run. It is the
  clause that is false, not the posture. **This is the most consequential of the
  four** — it is what a session reads today.
- **`scripts/audit-citations.mjs` silently ignores a non-`F` finding argument.**
  It matches `/BOOK-INGEST-AUDIT\.md\s+(F\d+)/gi` and filters on `/^F\d+$/i`, so
  `--remote G8` discarded the argument and printed BOOK-INGEST `F`-numbers
  instead. Wrong output, no error, and `audit-menu` step 5 tells a taker to run
  it with whatever number they were given.
- **README `## The scripts at the repo root` says `extraction-prompt.mjs` has
  "Two system prompts".** There is one — `SYSTEM_PROMPT_CACHE`; the file's own
  header records that the second went when the in-app importer was retired. Not
  pinned: `documented-counts.mjs` diffs filenames, never the prose beside them.
- **`REPO-AUDIT` `G8`'s deferred follow-up was never filed.** Its note says
  `regression.mjs` should be added to CI *"as its own finding, once this workflow
  has a track record"*. `gh run list --workflow=tests.yml` shows eight runs on
  2026-09-04, seven green, so the condition is met and no finding exists.

**One thing the exercise found about an agent rather than about the repo.**
`book-extract-worker`'s contract assumes a slice contains stat-block-shaped rows.
Read 2026-09-04: `.claude/agents/book-extract-worker.md:81` opens its return
contract *"For each row: the name as printed, the fields the book gives…"*, and
`:57` and `:66` both reason about stat blocks, while
`grep -n 'prose' .claude/agents/book-extract-worker.md` returns nothing — so the
prose case is covered nowhere in it. The agent handled it correctly anyway and
reported the gap itself, but the file should carry it, and that is a change to an
agent rather than verification, so it is not made here.

---

## Opened by taking F28

Filed 2026-09-04. `F28`'s posture was verification only, so the four things its
runs turned up were recorded in its note and repaired nowhere. They are findings
here so each gets its own word. **Every premise below was re-verified by hand
after the agent that found it reported it** — an agent's finding is still a claim
about another file.

### F29 — four live-instruction files say `main` has no ruleset, and one of them contradicts itself

`CLAUDE.md:9`, `SETUP.md:6`, `.claude/skills/ship-pr/SKILL.md:18` and
`.github/workflows/tests.yml:4` all say the CI workflow is reporting-only and
that **`main` has no ruleset**. `tests.yml:113`, in the same file, says
*"`main`'s ruleset requires a pull request and no status checks."*

A ruleset exists. **The substance of `REPO-AUDIT` `G8`'s posture still holds** —
it carries one `pull_request` rule and **zero** `required_status_checks`, so
nothing gates a merge on a red run. It is the clause that is false, not the
posture, and that distinction is the whole finding: a reader who checks and finds
a ruleset has no way to tell which half was wrong.

**This is the most consequential of the four**, because `ship-pr` and `CLAUDE.md`
are read by a session about to merge.

**Proposal:** correct the clause in all four files to say what is true — a
ruleset requiring a pull request, with no required status checks, so a red run
still does not stop a merge — and remove the self-contradiction in `tests.yml` by
making line 4 agree with line 113. **Posture: documentation only. Change no
setting, add no required check, and do not touch the ruleset itself.**

**Evidence.** `gh api repos/NateGrey0130/nates-workshop/rulesets`, 2026-09-04 →
`22209348`, *"main: require a pull request"*, `active`, created
`2026-09-03T12:46:10-04:00` — five minutes after `G8` merged at 12:41. Rule types
from `.../rulesets/22209348`: `pull_request`, and a filter for
`required_status_checks` returns `0`. Line numbers from
`grep -n 'ruleset' <each file>`, same day.

**Confidence: high.** Measured directly against the GitHub API, and the four
sentences were read in place. Nothing would raise it.

**Ongoing cost:** four sentences that must change again if the ruleset does.
`G8`'s note went stale within five minutes of merging, so this is a real cost
rather than a notional one — which is an argument for saying *what the ruleset
does* rather than *that there is not one*.

**Taken, 2026-09-04 (PR #682). Posture held: documentation only — four passages
corrected, no setting changed, no required check added, the ruleset itself
untouched.**

All four now say what the ruleset **does** rather than denying it exists, which
is the ongoing-cost argument above applied to the fix: `CLAUDE.md:10-15`,
`SETUP.md:6-11`, `.claude/skills/ship-pr/SKILL.md:22-27`, and
`.github/workflows/tests.yml:3-15`. Each carries the id, the rule type, the zero
required status checks, the date, and the command — so the next reader asks
GitHub instead of believing a sentence.

**The self-contradiction in `tests.yml` is gone.** Its header comment and its
menu-check job comment now agree, and the header says outright that the two
disagreed for a day, because one file arguing with itself is the tell that
neither half was checked.

**`audit-menu` caught one of my own edits while I made it.** All four
corrections initially **quoted the stale phrase** they replaced, which that skill
forbids in as many words — *"a note repeating the old wording defeats a grep for
it."* A sweep for the false sentence would have found four fresh copies of it in
the very PR that removed it. Rewritten to describe the error without reproducing
it. **The rule was in force and being read, and the edit broke it anyway**, which
is this menu's own closing observation happening again.

**Two records were deliberately left alone**, per *Audit files are RECORDS*:
`REPO-AUDIT.md:203` and `:821` state the position as measured on 2026-09-03 and
are true as of that date. They are not corrected and should not be.

### F30 — `audit-citations.mjs` silently ignores a finding number that is not an `F`

`scripts/audit-citations.mjs:47` selects its argument with
`process.argv.slice(2).find((a) => /^F\d+$/i.test(a))`. A `G8`, `M4`, `D1`, `A9`,
`B2`, `R1`, `S1` or `T1` never matches, `only` falls through to `null`, and the
script prints its **whole unfiltered** output as though no argument had been
given. Its patterns at `:36`–`:37` only ever match
`BOOK-INGEST-AUDIT.md F<n>` and `Filed as F<n>` anyway.

`audit-menu` step 5 tells a taker to run this script with the number they were
given, and `audit-menu` separately establishes that **`F` is one of eight
prefixes in use across the menus**. So the documented workflow hands it an
argument it discards, with no error, and the taker reads the result as *"these
classes cite my finding."*

**Proposal:** accept any `<letter><digits>` argument, and where the script cannot
answer for that prefix, **say so and exit rather than printing an unfiltered
list**. **Posture: no new gate and no exit code for the citation question itself
— the script keeps having no opinion about whether a citation is stale.** This is
about refusing to answer a question it was not asked.

**Evidence.** Read 2026-09-04:
`grep -n 'argv\|F\\d' scripts/audit-citations.mjs` → the regex at `:47` and the
patterns at `:36`–`:37`. Observed live: `audit-premise-auditor` ran
`--remote G8` while auditing `REPO-AUDIT` `G8` and got BOOK-INGEST `F`-numbers
back.

**Confidence: high** on the behaviour, read from the source. **Medium on the
remedy** — whether the right answer is a wider regex or a hard error depends on
whether the script is ever meant to serve non-BOOK-INGEST menus at all, which
nothing states. What would raise it: a decision on that scope.

**Ongoing cost:** none beyond the edit; it removes a failure mode rather than
adding a surface.

**Taken, 2026-09-04 (PR #684). Posture held: no gate, no exit code, read-only.**
Scoped **wider than proposed**, on Nate's word — the refusal covers any finding
this script cannot answer for, not only a non-`F` prefix.

**Its premises were audited first by `audit-premise-auditor`, and three things
came back.** Recorded here because the finding was wrong about two of them.

**1. The proposal's own remedy would have broken a pinned check, and its own
posture.** It said *"say so and **exit** rather than printing an unfiltered
list."* `apps/character-creator/test/smoke.mjs:4116-4118` asserts this file sets
no exit code, testing **comment-stripped** source, so `process.exit`,
`process.exitCode` and `exitCode =` all fail it — **including `process.exit(0)`**,
because the regex matches the call and not the status. The file is top-level ESM,
so a bare `return` is illegal too. Implemented instead as an `if`/`else` around
the query: it **prints a refusal and falls through**, with no exit anywhere. The
word "exit" in the proposal read as permission the repo does not give, and the
finding's own stated posture — *no new gate and no exit code* — is what the
implementation actually honours.

**2. "`F` is one of eight prefixes" understates its own source.** `audit-menu`'s
census table lists eight and then disclaims itself in the next paragraph: `S`,
`T` and `P` are excluded because they are not headings, and `A` (`META-AUDIT`) is
missing from the census while appearing in the shape table below it. **At least
eleven.** The finding quoted a number from another file without the sentence that
qualifies it, which is the shape this menu exists to catch — and it made the
finding *weaker* than the truth, not stronger.

**3. "The documented workflow hands it an argument it discards" is not accurate.**
All three documented invocations use an `F`: `audit-menu` step 5 (`--remote F10`),
`class-import` (`--remote F8`), and `docs-audit-2-prompt.md` (`--remote <F>`, a
placeholder literally named `F`). **No instruction file tells anyone to pass a
`G8`**, and none tells them not to. The defect is real; it fires when a reader
generalises from `F10`, which is exactly how it was found. The framing is
narrowed, the substance stands.

**And the audit found the case the finding never reached, which is why the scope
widened.** `--remote F30` returned *"0 of 160 (filtered to F30)"* — true of
BOOK-INGEST `F30` and read as *"no class cites `SKILL-AUDIT` F30"*, a different
finding this script cannot see. Every prefix here is shared across menus, so an
`F` is as ambiguous as a `G`. A zero now names the question it answered, and an
explicit menu argument (`BOOK-INGEST-AUDIT F10`) disambiguates.

**Verified by running all four paths, 2026-09-04, `--remote`:** `G8` refuses;
`SKILL-AUDIT F30` refuses on the menu; `F30` returns zero *and says which zero*;
`F10` still answers `2 of 160 — first-stage-promethean, promethean-phase-adept`.
The pinned assertion was replicated directly against the new source and passes.

**Not done, and deliberately.** `apps/character-creator/README.md:602-605`
describes this script and is **still true** — it parses no outcome notes and sets
no exit code. It under-describes the BOOK-INGEST-only scope, but editing the file
map was not in this finding and the row is not false.

### F31 — the README says `extraction-prompt.mjs` has "Two system prompts"; there is one

`apps/character-creator/README.md:705`, in the file map:
*"…documents. Two system prompts: one for a PDF page image, one for cached text…"*

`scripts/extraction-prompt.mjs` exports exactly one — `SYSTEM_PROMPT_CACHE`, at
`:38`. The file's own header records that the second went when the in-app
importer that used it was retired.

**Not pinned, and that is the interesting half.** `documented-counts.mjs` checks
that every script on disk is named in the file map and every name is a real
script — it diffs **filenames**, never the prose beside them. So the map's
descriptions are free to drift while the check that guards the map passes.

**Proposal:** correct the sentence to describe the one prompt that exists.
**Posture: documentation only. Do not extend `documented-counts.mjs` to parse
descriptions** — that is a much larger check and this finding does not carry the
evidence for it.

**Evidence.** `grep -n 'SYSTEM_PROMPT' scripts/extraction-prompt.mjs` → one line,
`:38`. `grep -n 'system prompts' apps/character-creator/README.md` → `:705`. Both
2026-09-04.

**Confidence: high.** Both files read directly.

**Ongoing cost:** none. One sentence, and it becomes true rather than needing
maintenance.

**Taken, 2026-09-04 (PR #685). Posture held: documentation only —
`documented-counts.mjs` is untouched, exactly as the proposal required.**

`apps/character-creator/README.md:704-708` now says **one** system prompt, names
what it is for, and says the second went with the in-app importer rather than
silently dropping the fact. The retirement is already recorded in
`scripts/extraction-prompt.mjs:10-13` — *"There used to be a second prompt here
for sending the PDF page itself … it went when the in-app importer that used it
was retired"* — so the README now agrees with the file it describes instead of
preserving its pre-retirement state.

**Premises held exactly**, which is worth recording because this menu's own
material warns against assuming otherwise: one `SYSTEM_PROMPT_CACHE` export at
`:38`, one README sentence at `:705`, both read directly.

**The box-drawing alignment was checked rather than assumed.** The row grew from
three continuation lines to four, and the file map's column is load-bearing;
verified with an `awk` slice of the prefix across lines 700–710 that the new
lines match their neighbours.

**Why the guard did not catch this, restated because it is the reusable half.**
`documented-counts.mjs` diffs **filenames** — every script on disk is named in
the map, every name is a real script — and never reads the prose beside them. So
the map's descriptions drift freely while the check guarding the map passes.
Extending it to parse descriptions is a much larger check and this finding
deliberately did not carry the evidence for one.

### F32 — `REPO-AUDIT` `G8` deferred a follow-up to "its own finding" and none was ever filed

`REPO-AUDIT.md:885` says `regression.mjs` should be added to CI *"as its own
finding, once this workflow has a track record."* The condition is met and no
such finding exists on any menu.

The gap it names is real: `.github/workflows/tests.yml` runs the five smoke
suites and **not** `regression.mjs`, which is the only check that builds a
database from nothing and drives the real routes — the one thing that catches a
fresh environment being broken.

**Proposal:** decide whether `regression.mjs` joins the workflow, and record the
decision either way. **Posture, if it is added: reporting only, matching
`G8` — no required status check, no ruleset rule, a red run does not stop a
merge.** A decision not to add it is a complete answer and should be written
down so `G8`'s deferral stops looking outstanding.

**Evidence.** `REPO-AUDIT.md:885`, read 2026-09-04. Track record measured the
same day: `gh run list --workflow=tests.yml --limit 10` → **8 `success`, 1
`failure`, 1 still running**. A repo-wide grep for `regression.mjs` in `*.md`
returns skills and docs describing how to run it locally, and no menu proposing
it for CI.

**Confidence: high that no finding exists**, from the grep plus reading the
menus' own headings. **Low on which way it should go** — this finding proposes a
decision, not an outcome, and `audit-menu` is explicit that re-measuring cannot
reach an already-settled question. What would raise it: knowing why
`regression.mjs` was left out of `G8`'s scope in the first place, which its note
does not say.

**Ongoing cost, if added:** one more CI job per pull request, and a suite that
builds a database from scratch is the slowest thing here. That cost is the main
argument against, and it belongs in the decision rather than in this line.

**Taken, 2026-09-04 (PR #686). Posture held: reporting only, matching `G8` — not
a required status check, and a red run does not stop a merge.** The decision Nate
made: **add it, path-filtered.** `REPO-AUDIT` `G8`'s deferral is closed.

`.github/workflows/regression.yml` — **a separate file, because
`on: pull_request: paths:` filters a whole workflow rather than one job**, and
`tests.yml` must keep running on every pull request. One file per concern, as
`deploy-alarm.yml` already does.

**The filter was derived by reading what the suite opens, not by guessing at
what looks related:** `db/schema.sql` and the data scripts it applies
(`regression.mjs:86,99`), `../js/parser.js` (`:25`),
`functions/api/character-creator/_lib/catalog.js` (`:26`), the README's
clean-run counts (`:589,635`) and `docs/operations.md`, which is where that
table moved in the README split (`:220`). Plus the suite itself and the workflow
file, so a change to the filter is covered by the filter.

**The measurement that made "filtered" the answer rather than "always":** 170
seconds, timed on the development machine 2026-09-04, exit 0, 237 checks. It
boots wrangler and builds a D1 under a scratch `--persist-to`; its header states
*"Nothing here talks to production"*, so it needs no credentials, which is why
CI can run it at all.

**The known defect in this shape, stated in the workflow's own header rather than
discovered later.** A path list is correct on the day it is written and silently
wrong the moment something `regression.mjs` reads moves outside it — and the
failure is invisible: the suite does not run, and **green means "not asked"
rather than "passed"**. This repo has argued against rules with an expiry date
before. It is accepted here deliberately, against paying three minutes on the
documentation-only pull requests that are most of them lately.

**A sentence this falsified, corrected in the same PR.**
`.claude/skills/ship-pr/SKILL.md` stated the suite was absent from CI — read at
line 29 on 2026-09-04, before this PR replaced the passage. It now describes the
new workflow **and** the path filter, because a green pull request outside those
paths means the suite was never asked and step 4 still owns it.

*(The old wording is described rather than quoted, deliberately. `audit-menu`
says a note repeating a stale phrase defeats a grep for it — and `menu-check`
flagged the quoted draft of this paragraph, which is its documented false
positive. The fix was to stop quoting, not to mark it exempt.)*

**And a defect of my own, found while editing that passage.** PR #682's `F29`
edit had spliced the ruleset paragraph into the middle of a sentence, leaving
*"…rulesets`. Treat it as a second pair of eyes…"* running two sentences
together. Repaired here because this PR rewrites the same block; recorded because
it is `F29`'s taking introducing a defect that nothing checked.

---

## Opened while taking F29 to F32

Filed 2026-09-04, a **fourth** placement on this page — the header says so
because out-of-order sections are this file's own named trap. Both came out of
doing the work rather than out of auditing a finding: one from an error the
instruction layer led me into, one from an agent reading its own file against
the skill it had just loaded.

### F33 — `windows-shell` states the line-ending rule as one exception; `.gitattributes` has four

`.claude/skills/windows-shell/SKILL.md:12` opens the whole skill with: *"The repo
is CRLF everywhere except `*.sql`, which `.gitattributes` pins to LF."*

`.gitattributes` carries **four** non-comment rules, read 2026-09-04:

| rule | line | effect |
|---|---|---|
| `*.sql text eol=lf` | 7 | LF — the one the skill names |
| `apps/filament-forge/vendor/* -text` | 12 | **no normalisation at all** |
| `shared/fonts/*.woff2 -text` | 18 | no normalisation at all |
| `.github/workflows/*.yml text eol=lf` | 34 | **LF — the one that bites** |

So the sentence is wrong twice: it misses a second LF pin, and *"CRLF
everywhere"* is not true of the two `-text` paths either.

**It has a demonstrated cost, which is why this is filed rather than shrugged
at.** Taking `F29` (PR #682) I normalised `.github/workflows/tests.yml` to CRLF
because this sentence says to. Git's own warning caught it — *"CRLF will be
replaced by LF the next time Git touches it"* — and the committed blob was fine,
but only because git normalised behind me. Writing `regression.yml` for `F32` an
hour later I had to remember the exception by hand, because the skill still says
there is one.

**Proposal:** correct the sentence to name both LF pins and both `-text` paths,
and point at `.gitattributes` as the list rather than restating it — a count in
that sentence rots the next time a rule lands. **Posture: documentation only.
One sentence in one skill. No check, no gate**; a check that reconciled the skill
against `.gitattributes` is a bigger idea and this finding does not carry the
evidence for one.

**Evidence.** `grep -n 'CRLF everywhere' .claude/skills/windows-shell/SKILL.md`
→ `:12`. `grep -vn '^#' .gitattributes` → the four rules above. The failure is
recorded in `F29`'s and `F32`'s notes, both 2026-09-04.

**Confidence: high.** Both files read directly, and the error was made rather
than predicted.

**Ongoing cost:** none if the sentence points at `.gitattributes` instead of
enumerating it. If it enumerates, it is a list to maintain — which is the trap
the proposal is written to avoid.

**Taken, 2026-09-04 (PR #689). Posture held: documentation only — one skill, one
passage. `.gitattributes` untouched, no check, no gate.**

`windows-shell/SKILL.md:12` now names both LF pins with the reason for each, names
the two `-text` paths, and — the half the proposal cared about — says
`.gitattributes` **is** the list while the paragraph is only a summary of it,
with the instruction to read the file before writing anything that rewrites line
endings. The `*.sql` clause about bytes reaching the database is kept; it is the
reason that rule exists.

**Its premises were audited first, and F33 was wrong about its own evidence.**

**1. The Evidence line was false.** It said *"The failure is recorded in `F29`'s
and `F32`'s notes."* Neither note mentions line endings, CRLF, `eol` or
`.gitattributes` — checked by reading both sections. The two textual premises
stand on their own, but **the corroboration does not exist**, and the CRLF
episode leaves no artifact either: git stores LF for a workflow file whichever
way the working tree is written, so nothing in history records it. This note is
the only place that account will ever live, which is the honest status of it.

**2. The quoted sentence was truncated.** F33 quoted it ending at *"pins to
LF."* It actually runs on into an italic clause giving the `*.sql` rule its
reason. The proposal was silent on whether that clause survives; it does.

**3. A minor overstatement.** `grep -vn '^#' .gitattributes` returns **seven**
lines, not the four rules — two blanks and a comment-continuation line come with
them. The four rules and their line numbers are exactly right.

**And one thing that verified stronger than filed.** All 712 tracked text files
were scanned for bare LF: the complete set of non-CRLF files is `*.sql`,
`.github/workflows/*.yml` and `apps/filament-forge/vendor/jszip.min.js`, with no
mixed files. So *"point at `.gitattributes`"* is not merely cheaper — that file
**is** the exhaustive list of exceptions today.

**A pinned collision, avoided rather than hit.** `apps/filament-forge/test/smoke.mjs:180-181`
asserts `.gitattributes` contains the literal string
`apps/filament-forge/vendor/* -text`; reordering or rewording that line fails
the FilamentForge suite. `F33` does not propose editing `.gitattributes` and
this take did not.

#### The same falsehood is in four other places, and this finding does not reach them

Found by the premise audit, recorded here, **not fixed** — `F33`'s posture is
one sentence in one skill, and widening a taken finding is not the taker's call.

| where | layer |
|---|---|
| `.claude/skills/ship-pr/SKILL.md:444-445` | a skill — and **the one open during a shipping session**, which is exactly when this bites |
| `~/.claude/projects/<project>/memory/sed-i-strips-crlf.md:11` | memory, indexed from `MEMORY.md`; no grep of this repo reaches it |
| `docs/prompts/gm-grants-prompt.md:180` and the workshop copy of the same file | a brief, in two content-identical places (`MACHINE-AUDIT` `M13`) |
| `docs/prompts/n-findings-prompt.md:58` | narrowly false — `jszip.min.js` is a pure-LF `.js` |

**`ship-pr` is the one that matters** and it is a separate finding, not a
widening of this one.

**Correct statements already exist and can be cited rather than re-derived:**
`META-AUDIT.md:1520-1521` names both LF pins, and `REPO-AUDIT.md:864-874`
explains the workflow pin. Both are dated records and stay as they are.

### F34 — `audit-premise-auditor` tells itself every finding has had a bad premise; its own authority says otherwise

`.claude/agents/audit-premise-auditor.md:14-15`: *"the record is unanimous:
**every finding taken so far has turned up an error in its own premises**."*

`audit-menu` — which that agent now loads, and which its own file names as the
authority — says the opposite at `SKILL.md:134-137`: *"Plenty of notes here
record premises that held exactly"*, listing **twelve** by name across
`HEALTH-AUDIT`, `MACHINE-AUDIT` and `SKILL-AUDIT`. `F31` on this page, taken
2026-09-04, is a thirteenth.

**The agent's own file contradicts itself two paragraphs later**, in its return
contract: *"A finding whose premises are all sound is a real and common
result."*

**This is not cosmetic.** The sentence tells the agent an error is always there
to be found, which is precisely the pressure toward inventing an objection that
the same file warns against. **I wrote it**, in PR #676, from a real but much
narrower observation about a handful of findings.

**Proposal:** replace the unanimity claim with what is actually true — checking a
finding before scoping it turns something up nearly every time, and it is usually
**not** the premises — which is `audit-menu`'s own formulation and keeps the
argument for the agent intact. **Posture: documentation only, one agent file, no
frontmatter or tools change.**

**Evidence.** Read 2026-09-04:
`grep -n 'unanimous' .claude/agents/audit-premise-auditor.md` → `:14`;
`grep -n 'held exactly' .claude/skills/audit-menu/SKILL.md` → `:134`. **Found by
the agent itself**, during `F27`'s verification run (PR #683) — it noticed
because it had loaded the skill, which is the case for `F27` in one observation.

**Confidence: high.** Both texts read directly, and the two disagree in words.

**Ongoing cost:** none. One sentence becomes true.

**Taken, 2026-09-04 (PR #688). Posture held: documentation only — one agent
file, no frontmatter change, no tools change, no code.**

The unanimity claim is replaced with `audit-menu`'s own formulation: *checking a
finding before scoping it turns something up nearly every time, and it is usually
**not** the premises.* The expensive case is kept and named as the expensive
case — a wrong premise is what a taker implements from, and one would have
shipped a silent bug — so the argument for the agent survives intact without the
false half carrying it.

**One line added that the finding did not ask for, and it is the behavioural
half:** *"You are not here to find fault; you are here to say which of these two
happened."* The defect was never really the arithmetic — twelve versus all — it
was that a sentence promising an error is always present pushes an agent to
produce one. The correction is only worth making if it removes that push.

**Premises held.** Both texts were re-read before editing and say what `F33`/`F34`
recorded them saying.

**The agent that found this was the agent it is about**, during `F27`'s
verification (PR #683). It could check its own file only because `F27` had given
it the skill to check it against — so `F27` earned its place by catching a defect
in the change that `F27` itself was.

---

## Opened while taking F33

Filed 2026-09-04. A **fifth** placement on this page; the header says so. `F33`'s
note listed four other copies of the line-ending falsehood and left them, its
posture being one sentence in one skill. This is the one that matters.

### F35 — `ship-pr` carries the same false line-ending clause, and the clause was never part of what it was told to say

`.claude/skills/ship-pr/SKILL.md:444-445`, read 2026-09-04: *"`.sql` is pinned to
LF by `.gitattributes` and the smoke test fails a `.sql` carrying a CR;
**everything else here is CRLF**."*

The last clause is false in the two ways `F33` established: `.github/workflows/*.yml`
is pinned to LF as well, and the two `-text` paths are normalised in neither
direction. **This is the skill a session has open while shipping a change to a
workflow file**, which is precisely when the sentence misleads — and it did,
during `F29` (PR #682).

**Two settled decisions bear on this and neither is being reversed.** Naming
them because a proposal that fails to say a decision exists is the shape
`audit-menu` warns about:

- **`SHIP-PR-AUDIT` `F8`, taken 2026-09-03 (PR #666)** compressed this very
  section from nine lines to two, and prescribed the content: *"`.sql` is LF by
  `.gitattributes` and the smoke test fails a CR; `windows-shell` before any
  in-place edit."* **The false clause is not in that prescription.** It arrived
  with the compression and nothing asked for it. This finding restores `F8`'s
  intent rather than undoing it.
- **`SKILL-AUDIT` `N2`, written 2026-09-02 (PR #568)** made *"do not duplicate
  it"* its explicit condition — `ship-pr` keeps one-line pointers into
  `windows-shell` rather than copies, which is why `ship-pr` came out shorter.
  **So the fix here is emphatically NOT to name all four rules**, which is what
  `F33` did for `windows-shell` and what would re-create the duplicate `N2`
  forbade.

**Proposal:** delete the clause *"everything else here is CRLF"* and add nothing
in its place. What remains is exactly `F8`'s two lines — the `.sql` pin, the
smoke test's CR failure, and the pointer to `windows-shell`, which now owns the
complete list. **Posture: documentation only, and SUBTRACTIVE — one clause out,
no new content, no check, no gate.** A taker who finds themselves adding a
sentence has misread this.

**Evidence.** `.claude/skills/ship-pr/SKILL.md:444-445` read in place 2026-09-04.
`F8`'s prescription read at `SHIP-PR-AUDIT.md:574-577`; `N2`'s condition at
`SKILL-AUDIT.md:2230-2235`. The falsity of the clause is `F33`'s evidence,
re-verified there against `.gitattributes` the same day.

**Confidence: high.** Every input is a passage read directly, and the remedy is a
deletion, which cannot introduce a new claim.

**Ongoing cost: negative.** One fewer copy of a fact that has now been wrong in
five places at once, and one less line in a skill that `SHIP-PR-AUDIT` `F8`
already judged too long for what it does.

**Three copies remain after this, and they are not proposed here** — the memory
file `sed-i-strips-crlf.md`, `docs/prompts/gm-grants-prompt.md:180` with its
workshop twin, and `docs/prompts/n-findings-prompt.md:58`. The briefs are
archived records of what was said at the time. The memory file is outside this
repo and no grep of it reaches; it is the one worth a separate decision.

**Taken, 2026-09-04 (PR #693). Posture held: documentation only and subtractive
— one clause out of one skill, nothing added, no check, no gate.**
`ship-pr`'s *Line endings* section now reads: the `.sql` pin, the smoke test's CR
failure, and the pointer to `windows-shell`. **`grep -n 'CRLF'` on that file now
returns nothing** — the deleted clause was its only mention.

**Four of this finding's own premises were wrong, and one materially.**

**1. The history claim was false.** `F35` said the clause *"arrived with the
compression and nothing asked for it."* It did not. Verified against
`git show fb4e081^1:.claude/skills/ship-pr/SKILL.md`, the state before PR #666:
the section already read *"Everything else in the repo is CRLF."* **PR #666
reworded the clause; it did not introduce it.** What is true — and all the
finding needed — is that `F8`'s prescription omits it, so the compression
preserved something it was not asked to keep. The stronger claim was mine and it
was wrong.

**2. The line citation was off by two.** `F35` cited `:444-445` three times;
`:444` is the heading and `:445` is blank. The sentence was at `:446-447` and the
paragraph ran to `:449`.

**3. "What remains is exactly `F8`'s two lines" overstated it — four lines
remain.** The trailing sentence about tools not preserving what a file had is
**not** in `F8`'s prescription either. That phrasing was the one way a
subtractive taker could overshoot: read as licence, it would have cut a true and
useful sentence. **It was not cut.** The posture was one clause, and one clause
is what came out.

**4. The `N2` citation pointed at the wrong lines** — `:2230-2235` is the memory
argument and the Cost paragraph. The condition is at `:2246-2247`. The *reading*
of `N2` was right: non-duplication was its explicit condition, and naming all four
rules here would have violated it.

**And one thing that cannot be settled either way.** `F35` said the clause misled
during `F29`. Both `ship-pr` and `windows-shell` carried the same falsehood that
day, `F33`'s note attributes it to `windows-shell:12`, and the episode leaves no
artifact in git. **Which file misled is not testable**, and the finding's textual
grounds never needed it. That is the same corroboration-shaped error `F33`'s
audit caught, made again one finding later.

**Nothing pinned the passage.** Checked for an `F30`-shaped collision and there
is none: `environment.mjs:488-509` reads this file's **`bash` fences** only, and
its two corpus-wide scans match backticked repo paths and smoke-check names,
neither of which this paragraph contains. No test pins `ship-pr`'s line count.

---

## Opened by F32's own CI run

Filed 2026-09-04. A **sixth** placement on this page. Six is past the point where
the arrangement helps anybody; consolidating them is worth its own finding and is
not attempted here.

### F36 — `F32`'s path filter was justified with a number measured on the wrong machine

`F32` added `.github/workflows/regression.yml` and filtered it by path, on the
stated ground that the suite costs **170 seconds** and that paying that on the
documentation-only pull requests that are most of them lately buys nothing.

**That 170s was measured on this Windows machine. In CI the same suite takes 56
seconds** — and the two were never compared, because the local figure was taken
first and the CI figure did not exist until the workflow ran.

**The cost is also not additive, which is the part that settles it.**
`tests.yml` and `regression.yml` are separate workflows with distinct
concurrency groups, so they run **concurrently**. Measured on PR #686: both runs
were created at `2026-09-04T13:12:22Z` — the same second — and finished at
`13:12:51` (29s) and `13:13:18` (56s). Unfiltered, a pull request's CI wall clock
goes from about 30 seconds to about 56. **It does not add three minutes, and it
does not add 56 seconds.**

**The filter's failure mode is silent, which is this repo's worst category.** A
path list is correct the day it is written and wrong the moment something
`regression.mjs` reads moves outside it — and then the suite simply does not run,
so **green means "not asked" rather than "passed."** That is the shape of the
`grep -c` that reported 272/272 clean on a pure-LF file, and of the 65
consecutive Pages failures nobody read.

**The argument against the filter is already in the filter's own header** — *a
rule with an expiry date and nobody will notice it expire*. It was accepted
anyway, and the only thing buying it was the 170s.

**Proposal:** delete the `paths:` block from `.github/workflows/regression.yml`
so the suite runs on every pull request, and rewrite the header paragraphs that
justify filtering. **Posture: unchanged from `F32` — reporting only, not a
required status check, a red run does not stop a merge.** This changes *when the
job runs* and nothing else, and it is **subtractive**: a block comes out and no
new mechanism goes in.

**This revisits a decision made deliberately hours earlier, and says so.**
`F32` chose filtering **on Nate's explicit answer**, from options that quoted the
170s figure — so the call was sound on the evidence available and is being
revisited because the evidence changed. `F32`'s note and `regression.yml`'s
header both stand as the record of what was believed then; neither is rewritten.

**Evidence.** `gh run list --workflow=regression.yml` and
`--workflow=tests.yml`, 2026-09-04: one regression run,
`13:12:22Z → 13:13:18Z`, success; the five most recent `tests.yml` runs at 29s,
33s, 25s, 34s and 29s. Concurrency groups read at `tests.yml:49` and
`regression.yml:49`. The 170s is `F32`'s own figure, timed locally the same day.

**Confidence: high on the mechanism** — concurrency and the silent failure are
structural, not statistical. **Medium on the number, because `n = 1`.** One CI
run, and a runner's speed varies. What would raise it: two or three more runs,
cheaply obtained — the current filter includes `regression.yml` itself, so **the
pull request that removes the filter exercises it one last time.**

**Ongoing cost: negative.** It deletes a path list that must be revisited every
time something the suite reads moves, and removes a way for the check to stop
covering things without saying so.

**One cosmetic defect found while measuring, in scope for the taker.**
`regression.yml` has no `name:` key, so `gh run list` and the PR check list show
it as `.github/workflows/regression.yml` where every other workflow shows a
word. One line, in the file the proposal already edits.

**Taken, 2026-09-04 (PR #692). Posture held: reporting only, unchanged from
`F32` — not a required status check, a red run still does not stop a merge. Only
*when* the job runs changed.** Subtractive as proposed: the `paths:` block is
gone and no new mechanism replaced it. The `name: regression` key was added, the
one line the finding put in scope.

**The header now argues the opposite of what it argued this morning, and says
so.** It records that the filter existed, that 170s justified it, that CI does
the same work in 56s, and that the deciding argument was never the seconds — a
path list that goes stale makes the check answer *"not asked"* while showing
green. Both burns are named beside it so the reasoning survives the next person
who wants to re-add a filter.

**The split from `tests.yml` is kept, and the reason changed.** It was split off
*in order to be filtered*, and that reason is gone — but the two workflows run
concurrently with distinct concurrency groups, so a pull request waits for the
slower rather than for both. Folded back into `tests.yml` as another step, this
suite would extend that job instead of running beside it. The header states that,
so the split does not look vestigial.

**A sentence this falsified, corrected in the same PR.**
`.claude/skills/ship-pr/SKILL.md:23-29` described the filter and told a reader
that a green check outside those paths meant the suite was never asked. It now
says the suite runs on every pull request, concurrently — **and that a green
regression check therefore means the suite ran**, which is the thing a filtered
one could not promise.

**The `n = 1` caveat is closed by this PR itself.** `F36` noted that the filter
included `regression.yml`, so the PR removing it would exercise the filter one
last time and produce a second timing. It did: **56 seconds again**, identical to
the first, with `smoke` at 22s on the same pull request — so wall clock was the
slower of the two, as the concurrency argument predicted. `gh pr checks 692`,
2026-09-04. The `name:` key is confirmed working in the same output: the check
reads `regression` rather than a file path.

#### F36 is the shape this menu keeps producing, and it is worth naming

Three of the last four findings here were **defects introduced by taking the
finding before them** — `F34` by `F27`, the spliced sentence by `F29`, and now a
filter by `F32`. None was caught by a check; each was caught by the next pass
reading what the last one wrote.

That is the loop working, and it is also the argument for keeping these passes
short and separate. **A bigger batch would have buried all three.**

---

## Opened while closing out 2026-09-04

Filed 2026-09-04. A **seventh** placement, and `F39` below is about exactly that.

### F37 — the memory copy of the line-ending rule, corrected outside the repo

`F33` and `F35` each listed the copies of the false line-ending claim they did
not reach, and both named the same one as *"worth a separate decision"*:
`~/.claude/projects/C--Users-natha-Projects-workshop/memory/sed-i-strips-crlf.md`.
It said every file in this repo except `*.sql` is CRLF. It is indexed from
`MEMORY.md:39` and loads in every session started from the working directory,
and **no grep of this repo reaches it**, which is why it outlived four findings
about the same sentence.

**Corrected 2026-09-04**, and this finding is filed *with* its outcome because
**there was no pull request in which to take it** — the file is outside the repo
and a PR cannot touch it. `SHIP-PR-AUDIT`'s header records the same shape and
the same remedy: *"One finding was taken before it was filed … Both PRs say
so."* This one says so.

**What changed.** It now says most files are CRLF, that `.gitattributes` is the
list of exceptions, that `*.sql` **and** `.github/workflows/*.yml` are pinned to
LF with two more paths `-text`, and to read that file before writing anything
that rewrites line endings.

**A second staleness found while editing, not in `F33`'s list.** The same memory
told a reader to use `latin1` for in-place edits, with no caveat.
`windows-shell` establishes that `latin1` **silently truncates any character
above U+00FF that you supply** — an inserted em-dash becomes an invisible control
byte — and that `utf8` round-trips CRLF just as well. The memory now carries
that, and a note that for an LF-pinned file the restore recipe stops at the first
replace.

**Posture: documentation only, outside the repo. No check, no gate**, and none is
possible: nothing in this repo can see that file.

**Evidence.** File read and rewritten 2026-09-04; LF endings preserved (0 CRLF
before and after, verified with node). `find` across all three
`~/.claude/projects/*/memory/` directories returns exactly one copy.

**Confidence: high** — the file was read, edited and re-read. **Ongoing cost:
none, and that is the problem.** Nothing will notice when it goes stale again.

### F38 — a commentary heading is indistinguishable from a finding, and a scan of this file now counts 37 findings where there are 36

**`grep -cE '^### F[0-9]+' SKILL-AUDIT.md` returns exactly one more than the
number of `F` findings.** Measured on `main` at `f9461e8`: **37 against 36**. The
figures move every time a finding lands — this very PR makes it 40 against 39 —
so **the invariant is the +1, not either number.**

The extra is the heading `### F36 is the shape this menu keeps producing, and it
is worth naming`, a commentary heading added by me in PR #692 that a finding scan
reads as a second `F36`.

Two more `###` headings sit under findings and are not findings: `:2698` *What
the runs turned up that is NOT this finding* (under `F28`) and `:3131` *The same
falsehood is in four other places* (under `F33`). Those two do not collide with
`F\d+`, but a bare `^### ` scan reads all three as findings.

**This is the failure this menu's own material predicts**, one level in: its
heading table warns that a `###` walk misses `CLASS-AUDIT`'s bullet `S` items and
`pick3cut5/AUDIT`'s bold `T` leads. This is the same class of error in the
opposite direction — a scan that finds **more** than exists.

**Proposal:** demote the three to `####`, so `^### ` on this file yields findings
and nothing else. **The third is the one that matters** and is worth doing alone
if the other two are contentious: a heading beginning `F36` that is not `F36` is
a trap, not a formatting preference. **Posture: formatting only. No content
moves, no finding text changes, no check** — and explicitly **not** a proposal to
make headings uniform across menus, which `audit-menu` argues against at length
and which this does not touch.

**Evidence.** `grep -cE '^### F[0-9]+' SKILL-AUDIT.md` → 37 on `main` at
`f9461e8`, 2026-09-04, against `F1`–`F36`; the full listing was read to identify
the extra rather than inferred from the count. **Re-run it against the current
finding count, not against 37** — both numbers move, the `+1` does not, and this
finding would otherwise be one more count in prose on the menu that keeps
catching them.

**Confidence: high** on the collision, which is reproducible in one command.
**Ongoing cost: none** — three characters, and it removes a way for a census to
be wrong.

**Taken, 2026-09-04 (PR #695). Posture held: formatting only — three heading
levels, no content moved, no finding text changed, no check added.** All three
demoted, not just the colliding one.

**Measured before and after, which is the whole of it:**

| | headings matching `^### F[0-9]+` | highest finding | difference |
|---|---|---|---|
| before | 39 | `F39` | **+1** |
| after | 39 | `F39` | **0** |

And the stronger check, which the finding did not ask for:
`grep -nE '^### ' SKILL-AUDIT.md` filtered for anything that is not
`### [FN]<n> —` now returns **nothing**. **Every `###` heading in this file is a
finding**, which is more than the `+1` this was filed about.

**Premises held exactly.** The three headings were at the lines stated, and the
`+1` reproduced on the branch before the edit.

**Nothing depended on them, checked rather than assumed.** No file outside this
menu cites any of the three section titles; neither `menu-check.mjs` nor
`audit-citations.mjs` parses `###` at all; and no tool bounds a section of this
file by heading depth.

**Demoted, not renamed.** The colliding heading still begins with the characters
`F36`, and an *unanchored* regex would still match it — but an unanchored regex
matches paragraph prose too, so it was never the realistic scan. The proposal
said demote; demoting is what happened, and renaming stays available if anyone
wants belt and braces.

**One thing observed and deliberately not fixed.** `audit-menu`'s shape table at
`.claude/skills/audit-menu/SKILL.md:461` describes this file as having findings
under **one** `##` section; there are seven. That row's *shape* cell is still
right — findings are `###`, no severity word, and this change makes that cleaner
— so nothing here falsified it; it was already understated before this PR. It is
out of scope and belongs in its own finding. `audit-menu` says of that very table
that *"the row that is missing has twice been the reader's own."*

### F39 — the seven section placements on this page, and the case for leaving them

This file now carries **seven** `##` sections holding findings, four of them
filed on 2026-09-04, plus the `N` block. The header names all of them, which is
the only reason a reader finds `F35` at `:3212` and `F36` at `:3319`.

**This finding recommends DECLINING itself**, and is filed so the idea is
recorded rather than re-proposed by the next person who scrolls this file.

**Why consolidation looks right.** Seven headings for what is one day's work
reads as sprawl, and the header has grown a paragraph of navigation to
compensate.

**Why it is wrong anyway, in order of weight:**

- **The findings are already in strict numeric order.** `F26`–`F28`, `F29`–`F32`,
  `F33`–`F34`, `F35`, `F36` — ascending, top to bottom, no exceptions. The
  arrangement a reader actually needs is intact; only the headings are many.
- **Consolidation means moving finding bodies in a record file**, which is a
  large diff over `Audit files are RECORDS` territory for a cosmetic gain, and
  every moved line re-enters `menu-check` as an added line.
- **The section names carry provenance that would be lost** — *opened by taking
  `F28`*, *opened by `F32`'s own CI run*. That is the causal chain between the
  findings, and this menu's most-repeated observation is that taking a finding
  produces the next one.
- **`F38` fixes the part that is actually broken.** Once a `###` scan yields
  exactly the findings, the number of `##` sections above them costs a reader
  nothing.

**Proposal:** close as declined, and record it here so it is not re-derived.
**Posture: no change to any file.** If it is ever taken instead, the shape to
prefer is merging the four 2026-09-04 sections **without moving any finding**,
which is not obviously possible and is why this recommends against.

**Evidence.** Section and finding line numbers from `grep -n '^##\+ '
SKILL-AUDIT.md`, read 2026-09-04. The ordering claim was checked against that
listing rather than assumed.

**Confidence: medium, and it is a taste call** — the kind `SHIP-PR-AUDIT` `F8`
says should be taken as one. What would raise it: Nate reading the file top to
bottom and saying whether the sections help or hinder.

**Ongoing cost of declining: one paragraph in the header** that has to keep
naming the placements as they accumulate. That is the real cost and it is
recorded rather than hidden.

**Closed without being taken, 2026-09-04 (PR #696), on Nate's word** — and
agreeing with the finding's own recommendation, which is the shape `audit-menu`
provides for when a proposal's cost exceeds its impact.

**Recorded so it is not re-proposed**, which is the whole reason this was filed
rather than simply not done. The next reader to scroll seven `##` sections will
have the same idea; the reasons it was declined are above, and the strongest is
that **the findings were already in strict numeric order**, so the arrangement a
reader needs was never broken.

**What changed underneath it, between filing and closing.** `F38` shipped in PR
#695, and every `###` heading in this file is now a finding — so a scan of the
page yields exactly the findings regardless of how many `##` sections sit above
them. **That removes the only mechanical harm** the placements could do, and
leaves this as purely a question of how the page reads. It is why declining got
easier rather than harder.

**If it is ever re-opened, the bar to clear** is the one this note leaves
standing: a shape that merges the 2026-09-04 sections **without moving a finding
body**, since moving them is a large diff across a record file and every moved
line re-enters `menu-check` as an added line. Nobody has proposed one.

### F40 — `audit-menu`'s shape table describes this file's arrangement, and that cell is now wrong

`.claude/skills/audit-menu/SKILL.md:461`, the row for this file, ends:

> *`F22` onward sit under `## Opened while taking a finding`, **out of numeric
> order, after `F21` and before the `N` block***

**`F22`–`F25` are still exactly there.** `F26`–`F39` are not: they sit in **six
further `##` sections, all of them AFTER the `N` block** — an arrangement the
row does not describe and, read literally, contradicts.

That row was added by `F7` on 2026-09-02, when the description was true.
**`F7` is also the finding that distinguished this kind of error from the other
one** — *"a wrong cell rather than a missing row"* — and the skill's own
commentary says the cells have been the reliable half. The other cell to go
wrong is the `DOCS-AUDIT.md` one `F7` itself corrected.

**And the row is mine.** `audit-menu` observes that *"the row that is missing has
twice been the reader's own"*; here the row that is **wrong** is the reader's
own, made wrong by fourteen findings I filed into this file over one day without
once re-reading the sentence describing it.

**One thing to fix in the same cell while it is open, and it is good news.** As
of PR #695 (`F38`) **every `###` heading in this file is a finding** — no
commentary heading impersonates one. That is precisely what the table exists to
record: *"which files … keep a whole family of items somewhere a `###` scan will
never see."* This file is now the clean case and the row should say so.

**Proposal:** rewrite the trailing clause of that one cell to say findings sit
under **several** `##` sections, some before and some after the `N` block, with
the file's own header naming them — and add that every `###` heading here is a
finding. **Posture: documentation only. One cell in one skill.**

**Do NOT write a number of sections.** That is the whole discipline of this
section of `audit-menu`: it removed the ordinal from its own "read N times"
paragraph rather than incrementing it, on the grounds that incrementing *"leaves
the same trap armed"*, and `F7`'s proposal ends *"Do not add a count of menus
anywhere."* A count here would be wrong the next time a section lands, which on
this file's recent record is days.

**And do not tally the table's errors.** Naming them — `F7`'s `DOCS-AUDIT.md`
cell, this one — is the convention; a running count is the thing `audit-menu`
explicitly refuses to keep, *"one more thing to keep current."*

**Evidence.** Row read at `:461`, 2026-09-04. Arrangement verified with
`grep -nE '^## |^### N1|^### N8|^### F22 |^### F26 ' SKILL-AUDIT.md` the same
day: `## Opened while taking a finding` at `:1861` holding `F22`–`F25`, `N1`–`N8`
at `:2171`–`:2400`, then six `##` sections at `:2460`, `:2749`, `:3048`, `:3220`,
`:3327` and `:3443` holding `F26`–`F39`. The `###`-are-all-findings claim is
`F38`'s outcome, re-verified on `main` after PR #695.

**Confidence: high.** Both texts read directly and the arrangement was listed
rather than assumed. What would change the shape of the fix, not its need: if
`F39` is ever re-opened and the sections merge, this cell wants rewriting again —
which is an argument for the countless phrasing above, not against the finding.

**Ongoing cost: none, if the rewrite carries no count.** If it carries one, the
cost is a re-read every time a section lands here — which is the trap this table
keeps falling into, and the reason its own paragraphs have been stripped of
ordinals rather than corrected.

**Taken, 2026-09-04 (PR #698). Posture held: documentation only — one table cell
in one skill, and both prohibitions observed.** No number of sections was
written, and the table's errors are named rather than tallied.

The cell now says findings are **split across many `##` sections with the `N`
block sitting in the middle of the `F` run**, that there is no one contiguous
list, that the file's own header names the sections — and, in the same breath,
**why no count appears there: because they accrue.** It also records `F38`'s
result, that every `###` in that file is a finding, which is the thing the table
exists to capture.

**A dependency the finding did not mention, found before editing.** The row
immediately below — `SHIP-PR-AUDIT.md` at `:462` — ends *"deliberately not the
row above's arrangement."* It contrasts itself against this cell, so a rewrite
could have left it pointing at nothing. The replacement keeps a contrast worth
pointing at: `SHIP-PR-AUDIT` is one appended block in order, this file is many
sections interrupted by the `N` block. **`:462` is untouched and still reads
correctly.**

**Premises held**, and the arrangement was re-listed rather than trusted from the
filing an hour earlier.

**Nothing pins the table**, checked rather than assumed: no script reads
`audit-menu`'s shape section, and the only `audit-menu` mention in the test tree
is a comment in `documented-counts.mjs:175` quoting its argument against
mechanical readers. Table integrity was verified after the edit — every row in
the block carries the same pipe count — and the new text adds no backticked repo
path, so the corpus-wide *every repo path a skill names exists* check has nothing
new to resolve.

**What this does not fix, and the decline path said so.** The cell will go wrong
again the next time the arrangement changes. Refusing to carry a count narrows
the failure to one sentence rather than a number, but the honest remedy — cutting
arrangement prose from a table whose stated job is *shape* — is a change to the
table's design and was not proposed.

### F41 — `book-extract-worker` conflates a page break with a slice boundary, and worked it out unaided

`.claude/agents/book-extract-worker.md:70-72`: *"Read one page beyond each end of
your range to find the boundary, and report any row that crosses **it** as
**incomplete**, naming which side is missing."*

**"It" is ambiguous.** The preceding sentence talks about *"a stat block
straddling the first or last page of your slice"* — the slice edge — but "the
boundary" reads equally as any page break, and the contract never says the two
are different. **They are:** a row spanning pages 84–85 inside an 84–86 slice is
**complete**; only a row crossing the slice edge loses a half.

**Found by running it, not by reading it.** Given `ww` printed 84–86 the agent
returned 15 rows, correctly flagged exactly one as incomplete — *Locate Places of
Evil*, cut mid-word at the foot of p.86 and continuing on p.87 — and reported
that it had to make the distinction itself: two other rows straddled internal
page breaks and it declined to flag them, *"to avoid over-flagging complete rows
as incomplete."*

**It got it right, which is the argument for fixing it rather than against.** The
next reader of that contract may not, and over-flagging is the direction that
wastes a reconcile pass; under-flagging is the direction that ships a truncated
row.

**Proposal:** say in that paragraph that a row straddling a page break **inside**
the range is complete and reported as such, and only a row crossing the **slice**
boundary is incomplete. Two sentences at most. **Posture: documentation only, one
agent file, no frontmatter or tools change, no check.**

**Evidence.** Contract read at `:70-72`, 2026-09-04. Behaviour observed in a live
run the same day over `ww` 84–86, whose report named the ambiguity in its own
words when asked what did not match its instructions.

**Confidence: high** — the text is ambiguous on reading and the agent said so
independently. **Ongoing cost: none**; it removes a way for a slice to be
mis-reported.

**One more thing that run turned up, not proposed here.** The agent noted the
contract's tone on offset checks *"primes you to expect friction"* and said it
did not manufacture a disagreement to satisfy that. It behaved correctly, so
there is nothing to fix today — but a prompt that leans toward finding a problem
is the same defect `F34` corrected in `audit-premise-auditor`, and it is worth
knowing it may exist here too.

### F42 — the shape table narrates arrangement in two rows, and arrangement is not what it is for

The table under *The headings are not uniform* states its own job:
*"the rows exist to record what no command can tell you — which files put a
severity word in the heading, which put a **status** there, and which keep a whole
family of items somewhere a `###` scan will never see."*

**All three are shape. Arrangement is not among them**, and it is derivable from
one `grep -n '^## '` on the file in question.

**Two rows carry arrangement prose and no other row does**, read 2026-09-04:

- `:461` `SKILL-AUDIT.md` — *"split across many `##` sections, with the `N` block
  sitting in the middle of the `F` run…"*
- `:462` `SHIP-PR-AUDIT.md` — *"`F11`–`F14` sit under `## Opened while taking a
  finding` after `F10`, in numeric order, deliberately not the row above's
  arrangement"*

**The rows that look similar are not.** `:452` `CLASS-AUDIT.md`, `:459`
`pick3cut5/AUDIT.md` and `:463` `SETUP-v2-CHANGES.md` each name a `##` section
too — but they do it to say **where a family of items hides from a `###` scan**,
which is the table's third stated job verbatim. Those stay.

**This is the part of the table that rots.** `F7` corrected a cell here; `F40`
corrected a cell here; both cells were arrangement or status prose rather than
heading shape. `F40`'s own note named this as the honest remedy and deferred it:
*"cutting arrangement prose from a table whose stated job is shape — is a change
to the table's design and was not proposed."* This proposes it.

**Proposal:** delete the arrangement clauses from `:461` and `:462`, leaving each
row's shape half intact — `:461` keeps *"`### F1 — …`, no severity word, and every
`###` is a finding"*, `:462` keeps *"`### F1 — …`, no severity word."* **Posture:
documentation only, and SUBTRACTIVE — two clauses out of one table, nothing
added, no check.**

**`:462`'s cross-reference goes with it, and that is deliberate.** It exists only
to contrast against `:461`'s arrangement; with both arrangements gone there is
nothing to contrast, and leaving a dangling *"not the row above's arrangement"*
would be worse than cutting it.

**This partly reverses `F40`, taken hours earlier, and says so.** `F40` rewrote
`:461`'s arrangement prose to be true; `F42` removes it. That is not churn for
its own sake — `F40` fixed a false sentence and explicitly recorded that deleting
the sentence was the better fix it was not scoped to make.

**Where arrangement belongs instead:** a menu's own dated header, which is where
`audit-menu` already puts status for the same reason — *"a memory cannot hold a
status and neither can an index; a menu's own dated header is the only place one
belongs."* `SKILL-AUDIT`'s header already names its sections.

**Evidence.** Table read row by row at `:444`–`:463`, 2026-09-04; the job
statement at `:425-429`. `F7` and `F40` read for the pattern.

**Confidence: high on the principle** — the table says what it is for and two
rows exceed it. **Medium on the second row**: `:462`'s contrast was written
deliberately and cutting it loses an intentional cross-reference. What would
settle it: whether that contrast was ever load-bearing for a reader, which
nothing records.

**Ongoing cost: negative.** It removes the two cells that have needed correcting
and leaves nothing in their place to go stale.

---

# Counts

**Filed 21 findings and 8 proposals.** By layer, counting the layer a finding's
*fix* lands in — the count as filed, before `F22` and `F23`:

| layer | findings |
|---|---|
| 1 — the six skills and their references | 9 (`F1`–`F9`) |
| 2 — the `book-reconcile` subagent | 1 (`F10`) |
| 3 — `CLAUDE.md` | 1 (`F11`) |
| 4 — memory | 4 (`F15`–`F18`) |
| 5 — `settings.json` / `launch.json` | 3 (`F12`, `F13`, `F14`) |
| 6 — `docs/prompts/` | 1 (`F19`) |
| cross-layer | 2 (`F20`, `F21`) |

Eight findings are single-file edits of under ten lines (`F3`, `F4`, `F5`, `F7`,
`F13`, `F15`, `F16`, `F20`). Two propose no edit to any instruction file at all
(`F12` documents, `F9` may close). One is a new file (`F11`), one a new section
in a skill (`F17`), one a split (`F8`).

**Added 2026-09-02:** `F22` and `F23`, both in the test suite rather than in any
instruction layer, both opened by taking `F1`. The table above is the census as
filed and is left standing as one; it does not include them.

**Added 2026-09-04:** `F26`–`F28`, out of PR #676 rather than out of taking
anything on this menu. By the same rule they are not in the table either: `F26`
would land in layers 3 and 5, `F27` in layer 2, `F28` in neither — it proposes
running things rather than editing a file.

**Added later the same day:** `F29`–`F32`, opened by taking `F28`. Also not in
the table. Three of the four land outside this audit's six layers entirely —
`F29` reaches a GitHub setting and a workflow file, `F30` and `F31` are scripts
and a README. That is a fact about where the agents looked, not a defect in the
census.

**And `F33`–`F34`, opened while taking `F29` to `F32`.** These two land back
inside the original layers — `F33` in layer 1 (a skill) and `F34` in layer 2 (the
agents) — which is the first time since `F25` that a finding here is about the
surface this audit was scoped to. Still not added to the table above; it is the
census as filed.

Nothing else is taken until Nate names it.

---

## A closing observation, about this audit rather than its findings

**Instructions this session wrote were violated by their author, the same day,
four times.** Not the old ones — the new ones.

| what I did | the rule, written hours earlier |
|---|---|
| an inline PowerShell command whose backslashes collapsed | `windows-shell` → *the Bash tool unescapes before bash sees it* |
| committed a 4,603-line phantom CRLF flip in this file | `windows-shell` → *editing a file in place* |
| handed over a bare `claude` | `windows-shell` → *call binaries by absolute path in anything you hand him to run* |
| then handed over the `npm\claude.cmd` shim | `interactive-shell-lacks-npm-path`, which records **that exact path as already having failed** and names the one that works |

> **Adjusted 2026-09-02 — `MACHINE-AUDIT` `M2`.** The rule in row three no
> longer exists. `windows-shell` was measured against the machine rather than
> read, the diagnosis beneath that prescription did not survive it, and the
> prescription was retired with it. So row three now records a violation of an
> instruction that should never have been written — which leaves the observation
> below untouched and sharpens the closing paragraph: the defence named there,
> *measure the thing rather than trusting the sentence about it*, is also what
> retired the rule. The table is left standing as filed.

I caught the first two. Nate caught the third. **The fourth is the one worth
keeping:** the memory holding the right answer also named my wrong answer as
wrong, it was in this session's context throughout, and I reached for a
directory listing instead of reading it.

So the audit's subject was demonstrated on the audit. `F1` is a lesson written
to memory that asserted a fix had already landed in a skill. `F20` is citations
nothing revisits. `F16` is a status a memory cannot hold. This is the same
thing again: **writing an instruction down is not the same as it firing.**

The instruction layer is not a guarantee — it is a prompt to a reader who may
not read it. The only defence observed working here was *measure the thing
rather than trusting the sentence about it*, which is what caught `F1`'s
inverted premise, `F4`'s two false replacements, `F8`'s impossible arithmetic
and `F9`'s 74 false positives.

Recorded here rather than filed as a finding, because there is nothing to
implement. It is the result.
