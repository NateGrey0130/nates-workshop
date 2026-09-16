# Book-ingestion batch — deferred code changes, 2026-08-28

> **Status lives under each finding, not in this header.** Every finding here
> carries its own dated outcome note beneath its heading; read to the next
> `###`. **`F3`'s schema half closed 2026-09-03 in PR #616** — the keep-dropping
> option, with the standing limitation written into `docs/known-limitations.md`
> where a reader of `gear` will meet it. It was the only finding on this menu
> ever taken in halves.
>
> **Since 2026-09-16 the closed findings live in `BOOK-INGEST-AUDIT.closed.md`**,
> moved there verbatim with their headings, numbering and notes; this file keeps
> a one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.
>
> **This header still states no overall verdict, and that is deliberate.**
> Several findings here close with a residue rather than a full stop: `F3` names
> the trigger that would reopen it, and `F11` records a `class-check` warning it
> decided against building and still thinks worth having. A one-word status
> would flatten those into *closed* or reopen them wrongly. Read the notes.
>
> **`F12`'s outcome note still says `F3`'s schema half is open, and it is not
> wrong.** It is a measurement dated 2026-08-31 and it stays as one, per this
> repo's rule that an audit file is a record. The same goes for the four class
> notes citing `F3`: *"`gear` has no shape for a vessel"* survived the closure,
> because what closed was a decision to keep dropping vessels rather than a
> change to the schema.
>
> **The one that misreads:** `F14`'s `Taken, 2026-08-31 (PR #434)` note sits
> below an inline `**F10 excluded this on a premise that is false.**` — a bold
> lead that a block-splitting scan mistakes for the start of a new finding,
> hiding the note behind it. It has produced a false "open" once. Read to the
> next `###`, not to the next bold line.
>
> **`F18` here is not `F18` anywhere else.** Six other menus in this repo carry
> one — `CLASS-AUDIT`, `INGESTION-AUDIT`, `REBUILD-AUDIT`, `HEALTH-AUDIT`,
> `SKILL-AUDIT` and `UI-AUDIT` — so cite a finding in this file by filename, and
> expect a tree-wide grep for a bare number to return mostly other menus'
> history. `F18`'s own note records how that was found.
>
> **This header no longer enumerates, and should not again.** Corrected
> 2026-09-03: the closed range it used to carry was wrong twice over — never
> extended when `F18` landed on 2026-09-02, and sweeping up `F3`, which had not
> then been fully taken. It also carried a re-verification date more recent
> than both errors, which is the part worth noticing: a count in a header is
> re-checked by hand or not at all, and the hand is what keeps missing.

Findings menu for the seven-book ingestion batch registered in
`BOOK-INGEST-QUEUE.md`. **This file holds code changes only.** Data — classes,
skills, spells, psionics, gear, `scripts/books.json` entries, class markdown —
ships with its own book, as it always has; nothing waits here for that.

A finding lands here when a book needs a mechanic the app cannot express, or
when the ingestion loop turns up a defect in the tooling rather than in the
data. The rule for the batch is: **import what the schema supports, record what
was dropped in the row's `extraction_notes`, file the gap here, keep going.**
Do not stop to implement.

Protocol is the usual one — see the `audit-menu` skill. Numbered `F1..Fn`,
`###` headings, one PR per finding, taken only when Nate names one, dated
outcome note appended under the finding in the same PR, merged on a separate
word. A finding is **audited when it is taken**: verify its premises against
current code before scoping, and lead with the corrections.

**One menu for the whole batch, not one per book.** The same missing mechanic
will turn up in more than one of these seven; add the new book's rows to the
existing finding rather than opening a second number for it.

## Findings

- **F1** — A numeric column is never checked against the page it cites — Taken, 2026-08-31 (PR #420). Posture held: advisory, log-only, exit code — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F1` heading.

### F2 — `skills.base` cannot hold a percentage derived from an attribute

`phase-world` printed 150 defines **Zero Gravity Movement & Combat** with a base
of *P.P. number x5%*, plus 4% per level. The per-level half fits; the base does
not. `skills.base` is `INTEGER NOT NULL DEFAULT 0` and every consumer treats it
as a fixed starting percentage, so there is nowhere to put a formula and no
runtime that would evaluate one.

This is the FIRST skill in the catalog whose base is attribute-derived, so
nothing here is a regression — the shape has simply never come up. Worth stating
because a `0` in that column already means something else: the schema comment
says *0 = non-percentile (W.P.s, hand to hand)*, and 336 rows rely on that
reading. Storing this skill at 0 makes it indistinguishable from a W.P.

**What the import did instead:** the row is imported with `base` 0 and the
formula written into `note`, and the class entries that grant it carry the same
sentence in `extraction_notes`. That is visible on the skill's own detail and
invisible everywhere a number is expected — the character sheet will show a
starting 0% for a skill the book starts at 40-50% for a typical P.P.

**Proposal, and it is deliberately the smaller of the two available.** Add a
`base_formula TEXT` column beside `base`, holding an attribute token and a
multiplier (`PP*5`), read by whatever derives a skill percentage. `base` keeps
its meaning for every existing row and stays the fallback when `base_formula`
is NULL. The alternative — making `base` a TEXT expression — touches every
consumer of a column 336 rows use and is not worth it for one row.

Two things to settle when this is taken, not before:

- **Where the evaluation lives.** `derive.js` turns class bonuses into numbers
  and already has the character's attributes; a skill's base is currently
  resolved in the catalog layer, which does not. Those are different places and
  the cheaper one may be the wrong one.
- **Whether one row justifies a column.** It is one row today. Palladium prints
  attribute-derived skills elsewhere (`Mutants in Orbit` is named on printed 151
  as the source of more space skills), so the honest answer is *probably more
  later*, not *definitely*. A second occurrence is a better trigger than this
  finding is.

**Taken, 2026-08-31 (PR #427), as proposed.** `skills.base_formula` holds an
attribute token and a multiplier - `PP*5` - consulted only when set, so `base`
keeps its meaning and stays the fallback for all 344 rows without one.

**The two questions this finding left open, settled.**

*Where the evaluation lives:* in the wizard, and it turns out there is only one
place it COULD live. The server never validates a skill percentage and
`leveling.js` advances from the STORED `pct`, so a skill's base is resolved
exactly once - at character creation, in `app.js`, where the attributes already
are. The pure half is `js/skill-base.js` so the smoke test can drive it off a
fixture; nothing server-side needed changing at all.

*Whether one row justifies a column:* on the evidence, yes, and for a reason
sharper than under-storage. Storing it at 0 was not merely lossy, it was
AMBIGUOUS - the schema comment defines `base` 0 as *non-percentile (W.P.s, hand
to hand)*, so a skill the book starts near 50% was indistinguishable from a
weapon proficiency. That is a wrong statement, not a missing one.

**One premise drifted:** the finding says *336 rows rely on that reading*. The
catalog is 345 skills now and **64** of them sit at base 0; every one of those
was checked and is a genuine non-percentile skill or is marked `Special`. This
is still the only attribute-derived base in the catalog.

**THE PICKER WAS A SECOND DISPLAY SITE AND THE TESTS COULD NOT SEE IT.** With
`resolveSkill` fixed, the class-skills row rendered correctly and the
related/secondary picker still read the raw `base`, so it showed an em dash -
telling a player that a skill they may take, and which the sheet then scores at
60%, has no percentage at all. Found in the browser, not by 1373 checks.

Verified end to end on a Cosmo-Knight, which grants this skill: at P.P. 12 the
class row reads 70% (60 derived, plus the class's printed +10%) and both picker
rows read 60%; at P.P. 18 it is 100%, at P.P. 3 it is 25%.

The grammar is one shape - `ATTR*N` - which is what was proposed and all one row
needs. A formula that does NOT parse falls back to `base` silently, which is
F8's shape, so the smoke test sweeps every `base_formula` any data script writes
and fails if one would not parse.

Five places per the `schema-change` skill: migration 042, the `CREATE`, a
guarded seed line, the `docs/operations.md` row, and the README data model. Plus
the catalogs `SELECT`, without which the column exists and never reaches the
app. Migration applied `--remote` and confirmed by asking
`schema_migrations`, then the data script.

Smoke 1364 -> 1373, regression 212 unchanged.

**Closed.**

**Reopened as a new finding, 2026-09-01. See F18.** The settled answer to *where
the evaluation lives* holds for the two DISPLAY sites this note found and misses
a third site that WRITES the number: `resolvePicks` in
`_lib/skill-picks.js` sets a spent pick's `pct` from the stored `base` alone, so
a skill gained after creation is stored at 0 and stays there. Nothing about the
column, the grammar, the fallback or the five places is affected - F18 is one
`SELECT` and one call, on a path this note did not look at.

**F18 was taken 2026-09-02 and that write path now resolves through
`skillBase()`**, so the paragraph above describes what was true between
2026-09-01 and then. This note's own measurements stand: the column, the grammar,
the fallback and the five places were never affected.

- **F3** — `gear` has no shape for a vessel, and this batch has 25 of them — Reopened and taken, 2026-09-07 (PR #787) - as the FIRST option, which the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — The language-pick invariant matches on prose, and missed one of three — Taken, 2026-08-31 (PR #421) - as the ALTERNATIVE, because the primary — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — `attribute_dice` cannot say an attribute does not exist, and the app fills one in — Taken, 2026-08-31 (PR #423), as proposed. `attribute_dice` accepts the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — `occ_related_skills` cannot express a per-category MINIMUM — Taken, 2026-08-31 (PR #428). Implemented as proposed - `occ_related_skills. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — the save list is sixteen fixed fields, and a book bonus outside them vanishes — Taken, 2026-08-31 (PR #426), as proposed. `bonuses.saves.other` is a list of — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — a FIXED attribute value in `attribute_dice` is silently replaced by 3d6 — Taken, 2026-08-31 (PR #422), both halves. A bare integer in — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — a cross-category `only` pick silently loses the percentage printed beside it — Taken, 2026-08-31 (PR #424), the main proposal - with ONE GUARD THE PROPOSAL — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — an R.C.C. and an O.C.C. that are BOTH psychic keep only one block, and the race wins every tie — Taken, 2026-08-31 (PR #429). `mergePsionics` replaces the choice. Powers and — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — a class whose book says it REPLACES the race cannot say so, and `combineClasses` gives the race precedence in four places at once — Taken, 2026-08-31 (PR #430). Implemented as the finding's PRIMARY proposal: — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — a class note that records the app's limits ages badly, and nothing sweeps the citers — Taken, 2026-08-31 (PR #432), all three parts, postures as written. Part 1 — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — ten published classes carry a doubled apostrophe in their stored markdown — Taken, 2026-08-31 (PR #433), posture as written - diagnosed first, then a — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — a race and an occupation that BOTH state magic keep only one block, and the occupation wins every time — Taken, 2026-08-31 (PR #434). `mergeMagic`, on F10's rules, sharing its union — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — the Crazy allows two psionic categories that do not exist, so its three starting picks have no legal pool — Taken, 2026-08-31 (PR #435), as proposed - one class, one data script, no — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F15` heading.

- **F16** — a psionic grant cannot exclude a power, and one class's book does — Taken, 2026-08-31 (PR #436), the PRIMARY proposal, posture as written - no new — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F16` heading.

- **F17** — the Crazy's I.S.P. formula is short of both its book and its own note — Taken, 2026-08-31 (PR #437), as a sweep first and then a one-class fix. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — a skill's base percentage is resolved on the SERVER too, and that path never reads `base_formula` — Taken, 2026-09-02 (PR #590). Posture kept: the write path only, no new gate, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — the citation check searches the catalog's category prefix as part of the name, and 213 of its 216 warnings are its own — Adjusted 2026-09-03 — both were read, and only one of them is a data — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F19` heading.

- **F20** — two name matchers, one of them shared and tested, and `drift-check` uses the other — Taken, 2026-09-03 (PR #614). Posture held: advisory only, exit code untouched, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F20` heading.

- **F21** — `catalog-diff` cannot match a prefixed catalog row from the name its book prints — Taken, 2026-09-03 (PR #617), as proposed, both halves. The de-prefixed — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F21` heading.

- **F22** — a spell or psionic power with no description is a stub nothing counts, and the codex is the page it shows up on — Taken, 2026-09-06 (PR #774). Leading with the corrections, because the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F22` heading.

- **F23** — an O.C.C. whose skills are ANOTHER O.C.C.'s, and a skill grant that picks CATEGORIES rather than skills — Taken, 2026-09-07 (PR #794), posture as written - a new grant block and a — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F23` heading.

### Premise audit of F30-F36, 2026-09-08 - read this before taking any of them

**All six of F30-F35 went through `audit-premise-auditor` BEFORE any was
implemented**, which is what `book-survey` §8 asks for when the session that
wrote a proposal is the session about to build it. **Seven claims did not
survive**, and the corrections are already made in place above rather than only
recorded here - a wrong sentence should not stand in the file at all. This
section holds what the corrections do not: the scope changes, and the two
proposals that are now different work than they said.

The auditor checked **41 premises and could not settle 2**: F33's claim that
three detectors were written and run this session, whose code is in no commit,
and F35's claim about "the three classes the original sentence says it cost",
which is a historical statement inside `class-import` and unverifiable from the
current tree. Both stand as unverified rather than as facts.

**F30 - the premises hold and the code block does not.** The algorithm claim is
right, both pages are right - re-derived without using the finding's own page
numbers - and the de-welded `Money:` line checks out. But the detector snippet
as written flags **82 of 194 pages**, because it collects lines from every block
inside the clip rather than the block's own. Restricted to a block's own lines
it flags 14; restricted further to blocks **at least 0.75 of the page width**,
which is `read-columns.py`'s own `wide` test, it flags exactly **2 - p043 and
p059**. **The wide filter is not optional**, and without it the finding's own
"an empty list on a clean book is the point" is false on the first book it runs
against. Two smaller corrections: the cache files are **still welded today** -
the de-welding happened in the reading, not in the cache - and they are not
"normal-length files", being 30 and 10 lines against a 96-line median.

**F31 - half of what it asks for already exists, built by this same menu.**
`related_skills_count` is implemented on an **ability grant** in
`js/parser.js`, with a comment naming `BOOK-INGEST-AUDIT.md F24`, and F24's
outcome note records the server change and production composing it. So "change
the related-skill count" is already expressible; what is not expressible is
doing it *in a variant*. **The proposal's `related_skill_count` is one character
from the existing `related_skills_count` and means the same thing** - that
collision is a decision to take deliberately, not to discover afterwards.
Verified by hand rather than taken from the audit report:
`grep -n related_skills_count apps/character-creator/js/parser.js` returns
lines 1619, 1624, 2309, 2310 and 2311 - the ability grant that applies it and
the validator that type-checks it, read 2026-09-08.

Two files the proposal names need no edit at all. **`sheet.js` has nothing to
touch**: its own comment says the class "comes with the character now, already
resolved to this character's variant", and it references neither `applyVariant`
nor the skills blocks. **`compose.js` needs no edit either**, because it already
runs `applyVariant` before `combineClasses`, so a union performed inside
`applyVariant` is upstream of it. And `class-check-lib.mjs`'s `KNOWN_KEYS` is a
set of **top-level class keys**; variant sub-keys are validated in `parser.js`
and adding them there does nothing. Everything else in F31 verifies, including
both `docs/leveling.md` quotes and the book quote.

**F32 - the premises hold.** Only line numbers drift, and one distinction is
worth carrying into the work: the `app.js` code the finding cites is the
**warning** panel, which lets a player carry on; the actual gate is
`validate-character.js`, which the proposal already names. No ceiling mechanism
exists anywhere - `attribute_maximums` and `maximums` return nothing across
`apps/`, `scripts/`, `.claude/` and `db/`.

**F34's data half shrinks from fifteen to nine, and six become a decision.** See
the corrected text above. The check half is unaffected and still goes red the
moment it is added, so the two halves must still ship together.

**F33 gained its sizing for free**, which the finding called step one of taking
it. Published classes citing each slug, `--remote`:

| slug | citers | | slug | citers |
|---|---|---|---|---|
| `huntsman-armor` | 4 | | `huntsman-plate-padded-armor-non-environmental` | **0** |
| `portable-language-translator` | 10 | | `language-translator-portable` | 1 |
| `large-flashlight` | 5 | | `flashlight-large` | 1 |
| `bio-comp-system` | 8 | | `bio-comp-monitor` | 1 |

Three of the four pairs have an obvious loser, and one - the huntsman pair - has
a zero-citer row, which is the cheapest possible merge. **A warning for whoever
runs that sweep**: `new RegExp('\\b' + slug + '\\b')` written through the Bash
tool collapses its double backslash and reports 0 citers for everything. Use
`String.includes`.

**What cites these findings**, because `scripts/audit-citations.mjs` sees class
`extraction_notes` **only** and will under-report: F30 is cited by
`fq-gb-reloader`, F32 by `fq-deep-intel-agent` and `fq-glitter-girl-pilot`. By
hand, the rest are cited in `docs/surveys/free-quebec.md`, in
`BOOK-INGEST-QUEUE.md`, and in six data scripts under
`apps/character-creator/db/`. **`BOOK-INGEST-QUEUE.md` also carries a per-finding
STATE outside this menu** - it says F30 and F31 are pre-authorized for
implementation - which is the shape `audit-menu` warns about, a finding's status
living somewhere the finding does not.

**And a note on citing these by bare number**: a tree-wide grep for F30 through
F35 returns mostly `UI-AUDIT` F30 and `INGESTION-AUDIT` F32, F33 and F34. This
menu's own header already says to cite by filename, at line 31; here is the
case for it. <!-- claim-ok: this file's own header, not another file -->

## Filed while taking F32, 2026-09-08

- **F37** — migration 049 never records itself, so `drift-check --remote` reports a false drift forever — Taken, 2026-09-08 (PR #826). `drift-check --remote` now reports NO — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F37` heading.

- **F38** — one real duplicate scores 0.667 against a 0.7 threshold, and the names cannot settle it — CLOSED WITHOUT BEING TAKEN, 2026-09-08 (PR #829). The measurement this — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F38` heading.

## Filed while reviewing the OCR pipeline, 2026-09-08

- **F39** — §0b's DPI paragraph and §0c's framing together read as "a render only helps a text layer", and the case that disproves it is a SCAN — Taken, 2026-09-08 (PR #836). Posture held: documentation only - two prose — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F39` heading.

- **F40** — a Triax cybernetics row cites printed 153 and the book prints it on 154 — Taken, 2026-09-08 (PR #837). Posture held: a data fix, no schema change and — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F40` heading.

### F41 - the 24 gear rows that are really vessels span FIVE books, so the backfill is a book job and not a data script

**This is `F3`'s deferral, finally given a number.** That finding's 2026-09-07
note (line 430 of this file) says the 24 prose rows are *"the backfill a future
`vehicles` table would start from"* and that *"backfilling them is its own job
with its own decisions, chiefly what happens to the class equipment lists that
reference those gear slugs."* It named work and filed nothing, which is the shape
`audit-menu` now calls out. The decisions are settled below; the work is not
started.

**Filed while building the gear-and-vessels sequence** (PRs #848-#854), which put
readers on both catalogs and made the split visible: the codex now shows some
vessels in its Gear tab and some in its Vessels tab, and
`docs/plans/21-gear-and-vessels.md` says so under *What is NOT verified* rather
than hiding it.

**The measurement that re-scoped this.** All figures `--remote`, 2026-09-09:

| | |
|---|---|
| `gear` rows with `category = 'vehicle'` | **69** |
| of those, carrying `Main Body` in the description | **24** |
| the rest - stubs, mounts, worn kit | **45** |
| the 24 with a mechanically parseable `M.D.C. by location:` list | **7** |
| the 24 with M.D.C. buried in narrative prose | **17** |
| **distinct source books across the 24** | **5** |
| of the 24, carrying `Web reference (not book-verified)` | **1** |

```
node scripts/q.mjs --remote "SELECT source_book, count(*) AS n FROM gear WHERE category = 'vehicle' AND description LIKE '%Main Body%' GROUP BY source_book ORDER BY n DESC"
```

Wormwood 9, Juicer Uprising 7, Rifts Ultimate Edition 6, Phase World 1, and one
row with no book behind it at all.

**Why that changes the shape of the work.** The estimate this started from was
"a data script over 24 rows". It is not one, for two reasons and the second is
the serious one:

- **The prose is not uniform.** `glitter-boy-power-armor` reads *"M.D.C. by
  location: main body 770, head 290, arms 270 each, legs 450 each, hands 100
  each, rail gun 175, reinforced pilot compartment 150"* - transcribable.
  `battle-saint`, `battler-parasite` and `beetle-parasite` bury their numbers in
  narrative. Only 7 of 24 are mechanical.
- **The source would be a paraphrase, not a book.** Those descriptions were
  written by earlier import sessions reading the books. Deriving structured
  combat numbers from them is the thing this repo's ingestion discipline exists
  to prevent, and `book-survey` §8's batch protocol is one session per book.
  Twenty-four rows across five books is **five book sessions**.

**Proposal:** take this as **five book sessions, one per book**, not as one data
script - Wormwood, Juicer Uprising, Rifts Ultimate Edition, Phase World, and a
sixth decision for the web-sourced row. Each session re-reads its own book for
the vessels among these 24, writes `vehicles` + `vehicle_locations` +
`vehicle_weapons` rows the way the Triax and Free Quebec vessel imports already
do, and points the surviving gear row at the new vessel. **Posture: no schema
change from a book session** - see the decided half below, which is the one
schema change and belongs in its own PR ahead of them.

**The 45 are NOT part of this and should not be re-proposed.** They are not thin
vessels, they are **not vessels**: `riding-horse` is *"A trained riding horse."*,
`hovercycle` is *"the unspecified one a class list names"*, and
`wilk-s-jet-pack` and `tw-wing-board` are worn kit. A stub in `gear` reads as a
stub; a stub in `vehicles` reads as a vessel somebody failed to finish. Several
also carry `Estimate - no published price found`, and the README's estimate rule
(under *A third tier, for what nothing publishes*) forbids an estimated row
carrying M.D.C., damage or an A.R. at all - `samas-power-armor` is one of those,
so it could not be given a stat block even if somebody wanted to.

### The citation decision, which Nate settled on 2026-09-09

**Decided, so no book session re-litigates it: the gear row SURVIVES as the
citation target and points at the vessel.** Recorded here so it is not
re-proposed.

The problem it answers: `catalog_redirects` cannot express a cross-catalog move.
`db/schema.sql` comments its `to_id` column as *"row in that catalog's table"*,
and five query sites resolve a gear slug through it - `items.js`,
`characters/[id].js`, `characters/[id]/items/[itemId].js`,
`campaigns/[id]/items.js` and `campaigns/[id]/ask.js` - every one hard-coding
`catalog = 'gear'`:

```
grep -rn "catalog_redirects" functions/api/character-creator/ --include=*.js
```

So a row that simply LEFT `gear` would leave its class equipment citations
resolving to nothing, silently, in the wizard. Of the 13 slugs cited by class
markdown, 5 are among the 24 movers and carry 14 references; the heavy citations
- `hovercycle` at 21 classes, `riding-horse` at 12 - are all on rows that are
not moving.

The alternative, teaching the class format a vessel reference, was weighed and
declined: it touches the format and the wizard's resolution to buy honesty about
a row that the pointer already records.

**That needs one column - `gear.vehicle_slug`, a nullable pointer - and it is a
schema change, so it is NOT part of any book session.** It should land in its own
PR **before** the first of them, or the sessions have nothing to point at.

**Do not build that column before there is a vessel to point at**, either. A
pointer nothing uses is the silent-storage failure `F3`'s own closure declined
when it rejected the JSON option. The order that works is: the column and its
rendering in one PR, immediately followed by the first book session.

**Evidence:** the counts above are `scripts/q.mjs --remote`, run 2026-09-09, and
the command for the book split is quoted in full. The five-query-site claim is
the grep quoted directly above it, run the same day. The `to_id` wording is
quoted from `db/schema.sql`, which was read rather than recalled.
`docs/plans/21-gear-and-vessels.md` was written in PR #854 the same day and
carries the same figures.

**Confidence: high on the numbers, medium on the estimate of five sessions.**
The row counts, the book split and the query sites were all measured. What is not
measured is how much of each book still needs reading: Juicer Uprising, Phase
World and Rifts Ultimate Edition all have OCR caches present (`drift-check
--local`, 2026-09-09, reports 16 of 18 registered books cached), so a session
may find the pages quickly. **What would raise it:** open one book - Juicer
Uprising has the largest single share at 7 - and see how many of its rows have a
printed location block the cache can be read from.

**Ongoing cost: none once done, and that is the argument for doing it.** This is
a one-time correction that ends with 24 fewer rows in the wrong table and the
codex no longer splitting vessels across two tabs. The pointer column is one
nullable column with one reader. **The cost of NOT doing it is also small and
should be stated honestly**: the split is cosmetic, the data is present and
correct where it sits, and every one of those 24 rows renders its full prose in
the codex's Gear tab today. This finding is not urgent and says so.

**Taken for JUICER UPRISING, 2026-09-09 — one of the five book sessions this
finding proposes, not the whole of it.** Four books remain: Wormwood 9 rows,
Rifts Ultimate Edition 6, Phase World 1, and the one row with no book behind it.
Read under this heading rather than anywhere else for where it stands.

**The posture held.** The gear rows stayed, all seven of them, keeping their
slug, price, category and prose; each gained a `vehicle_slug` pointer. No schema
change came out of the book session — `gear.vehicle_slug` is migration 053 and
landed in its own PR ahead of it, which is what this finding asked for and what
`book-survey` section 8 requires of a book session.

**The premise audit did not happen the way `audit-menu` prescribes, and saying
so is the point.** The `audit-premise-auditor` subagent was launched first and
**stalled** — ten minutes in it had loaded its protocol and done nothing else —
so it was stopped and the premises were checked by the same session that then
implemented them. That is precisely the conflict the subagent exists to break,
and it was not broken. The corrections below are therefore worth less than they
would be from a cold reader.

**Two premises did not survive, both in the direction of less work:**

<!-- claim-ok: quoting the premises this note corrects -->

- This finding says **"only 7 of the 24 have a mechanically parseable `M.D.C. by
  location:` list"**. That was measured against the PARAPHRASE in the gear
  descriptions, repo-wide, and it understates this book badly: read from the
  book itself with `scripts/read-columns.py "<pdf>" 78 89` on 2026-09-09, **all
  seven** Juicer Uprising vessels carry a printed `M.D.C. by Location:` block.
  Nothing here had to be inferred. The figure may still hold for the other four
  books; it was not re-measured for them.
- This finding says the citation problem covers **"5 [of the 24] ... carrying 14
  references"**. For this book it is **one row**: `road-boss-motorcycle`, cited
  by two published classes. The other six are cited by nothing
  (`node scripts/q.mjs --remote`, joining `imported_classes.markdown`,
  2026-09-09). The decision to keep the gear row was still the right one — that
  one row would have broken silently — but the risk here was narrower than this
  finding implies.

**Premises that held:** 7 gear rows carrying `category = 'vehicle'` and this
book's `source_book`; `page_offset: 1`, confirmed the free way `book-survey`
section 0d prescribes, by reading the folio printed on the page — cache p84
carries printed 83; and **zero** Juicer Uprising vessels already in `vehicles`,
so this was a clean import rather than a merge.

**What shipped** (`zzzzzzz-ju-vessels-p077-088.sql`): 7 vessels, 43 M.D.C.
locations, 21 weapon systems, and 7 gear rows pointed at them. Seven z's because
`zzzzzz-vehicle-class-vocabulary.sql` asserts a vessel count of 127 and would be
falsified by these rows landing before it.

**The strongest evidence in the import is a coincidence nobody arranged.** Every
price was read off the book before the catalog was consulted, and all seven match
the `gear.cost` an earlier session stored — including `road-boss-motorcycle` at
**90,000**, which is the stripped price rather than the 200,000 armed one, so
that session applied the same low-end-of-a-range convention `gear.cost`
documents. Seven independent confirmations that the transcription is right,
which is what `book-survey` section 0c means by using the rows you already have
as a check on the reading.

**`ju`'s OCR cache was not used, and that is now recorded where a reader will
find it.** `book-survey` section 0b names it by slug as one of the caches built
by throwaway code, and reading it confirms the description: raw
`page.get_text()`, columns welded across the gutter, prose from both columns
interleaved line by line. Its manifest carries no `welded_pages` or
`corrupt_pages` key, which is the tell. `read-columns.py` reads the same pages
cleanly off the PDF. **The cache was left as it is** — rebuilding it is not this
finding's business and would have been a change made from a book session.

**One disagreement found in passing and not acted on:** the `ju` cache manifest
records `printed_pages: 160` where `scripts/books.json` records **159**. Neither
was used for anything here — the offset came from the folio — and it is filed
nowhere yet.

**The NG-JK1 is one row, not two.** The book prints one entry describing two
models with the heavier JK1B's figures in parentheses throughout. Nate settled
the shape on 2026-09-09: one vessel for the JK1A, the B figures in each
location's `mdc_note` and its price in `cost_note`. A second row would have
duplicated nine locations and five weapon systems to change nine numbers.

**Taken for WORMWOOD, 2026-09-09 — the second of the five book sessions, and it
shipped TWO vessels where this finding counts nine.** Three books remain: Rifts
Ultimate Edition 6 rows, Phase World 1, and the one row with no book behind it.

**The scope changed, and the book changed it.** This finding's Wormwood share
was measured with `category = 'vehicle' AND description LIKE '%Main Body%'`, and
that filter is wrong in BOTH directions here:

<!-- claim-ok: quoting the premises this note corrects -->

- **It includes eight rows that are living monsters.** The shock parasites —
  `battler-parasite`, `tick-parasite`, `beetle-parasite`,
  `monster-worm-parasite`, `tangle-worm-parasite`, `krikton-flailer`,
  `krikton-leaper`, `krikton-battle-wagon` — each print their own `Class:` line
  in the book, and all eight read `Class: Wormwood organism: <name> Parasite.`
  The two machines read `Class: Magic symbiotic war machine.` That is the same
  field `vehicles.vehicle_class` exists to hold, and the book fills it in
  differently for the two groups. Measured by grepping `^Class:` across cached
  printed 101-108 on 2026-09-09: eight hits, eight organisms, no exception.
- **It excludes `battle-saint-orb`, which IS one of these machines.** Its gear
  description says "M.D.C. is the pilot's own hit points or M.D.C. times 10"
  where the battle saint's says "main body", so the `LIKE` missed it. The book
  prints `M.D.C. by Location: Main Body` for the orb on printed 94, under the
  same `Class:` line as the saint. **So one of the two rows shipped here is not
  among this finding's 24**, and the count of movers is 23 + 1 rather than 24.

**This finding says `battle-saint`, `battler-parasite` and `beetle-parasite`
"bury their numbers in narrative".** Two of those three are counterexamples: both
parasites carry a full comma-separated per-location list in the gear description,
differing from the seven this finding counted only in the header phrase —
`M.D.C.:` rather than `M.D.C. by location:`. Across all 24 rows that shape holds
for **8 more**, and every one of the 8 is Wormwood, so `"17 with M.D.C. buried in
narrative prose"` is overstated by eight. **`battle-saint` is the real
exception, and for a reason this finding does not anticipate** — see the M.D.C.
paragraph below. (`node scripts/q.mjs --remote`, 2026-09-09.)

**The premise audit happened the way `audit-menu` prescribes this time**, which
the Juicer Uprising note above records it did not. `audit-premise-auditor` ran to
completion before any file was written, checked seven claims plus the posture,
and found three disagreements — the paraphrase-side count above, the closed
`vehicle_class` vocabulary, and that `scripts/read-columns.py` cannot read this
book. It reached the parasite problem from the gear rows alone and correctly
refused to open the PDF. **The decisive evidence is the book's own `Class:`
field, which only the implementing session could see**, so the two passes found
the same boundary from opposite sides — which is the point of running both.

**The eight parasites stay in `gear`, and that was already Nate's call.** The
`ww` survey's ledger records it under 2026-08-27: *"The 8 parasites ARE gear —
overriding this survey's first recommendation ... on the grounds that Ride Giant
Parasites and Summon and Command Parasites make them player-reachable."* Moving
them would reverse a settled decision, which is the failure `audit-menu`'s
subject grep exists to catch. The mechanical reason is stronger than the
taxonomic one: `vehicles` has nowhere to put a Horror Factor, an I.Q., attacks
per melee, save-vs-magic bonuses, prowl and climb percentages, or
bio-regeneration, and every parasite entry carries most of those. Importing one
would DROP them, which is worse than the cosmetic split this finding set out to
fix.

**The posture held.** Both gear rows kept their slug, prose and NULL price and
gained a pointer; no schema change came out of this session. It cost nothing
here, unlike the Juicer Uprising import: **no Wormwood gear slug is cited by any
class markdown at any status**, so nothing would have broken either way. The 45
were not touched or re-proposed.

**NO M.D.C. FIGURE EXISTS FOR EITHER VESSEL, and that is the book's answer
rather than a failed extraction.** A battle saint's main body is "equal to the
pilot's hit points/M.D.C. x 20" and every other location is a percentage of it;
the orb is x 10. So `mdc_main_body` is NULL on both rows and all six
`vehicle_locations.mdc` are NULL with the formula in `mdc_note`. **Nothing had
to be widened**: `vehicle_locations.mdc` comments itself *"NULL where a book
prints a formula"*, so migration 048 anticipated this three weeks before anyone
needed it. A reader who wants a number gets the book's own worked examples from
the notes — a pilot with 32 hit points instills 640 in a saint and 320 in an orb.

**What shipped** (`zzzzzzz-ww-vessels-p093-095.sql`): 2 vessels, 6 M.D.C.
locations, 4 weapon entries, 2 gear pointers. Seven z's to sort after
`zzzzzzz-ju-vessels-p077-088.sql`, whose readback asserts a global pointer count
of 7 and would be falsified by these two landing first.

**Every figure was read from the book and then confirmed against a RENDER.**
`ww` is a scan, so `scripts/read-columns.py` is unavailable — it needs a text
layer. The cached OCR of printed 93-95 was read first, then all three pages were
rendered at 200 dpi and read again; **they agree character for character on
every number in both entries**, which is a better result than this book's cache
had any right to give, since its manifest carries no `welded_pages` or
`corrupt_pages` key. The offset was confirmed the free way `book-survey`
section 0d prescribes and got three confirmations rather than one: the renders of
93, 94 and 95 each carry that folio at the foot of the page, so `page_offset: 0`
as `scripts/books.json` records. **The `ju` manifest disagreement does not recur
here** — `.cache/books/ww/manifest.json` and `scripts/books.json` agree on both
`page_offset: 0` and `printed_pages: 159`.

**There was no price cross-check to be had.** The Juicer Uprising import's
strongest evidence was seven printed prices matching seven stored ones. Wormwood
prices nothing — it runs on barter, and the Priest of Light O.C.C. prints
*"Money: Not applicable"* — so `cost` is NULL on every row on both sides and
there is nothing to agree. The confirmation here is the render instead.

**A spell list went into `vehicle_weapons`, and it is the one judgement call
worth flagging.** Neither machine has a weapon system; each has a melee list and
a `Magic Powers of Note:` list it casts a fixed number of times a day. Both are
`vehicle_weapons` rows with a `note` saying what they are — the convention the
Free Quebec import set for `Hand to Hand Combat` and `Combat Bonuses`. The spell
list is the only ranged offense either vessel has, and the alternative was
leaving it in description prose, which is the shape this finding exists to get
structured numbers out of. **The ordinals are this file's, not the book's**,
which is a departure from every other vessel script here and is said so in the
file.

**One correction filed in passing, in the same PR:** `docs/surveys/ww.md` cited
the Priest of Light's `Money:` line as printed 52. It is printed **54** — cached
`p054.txt` line 70, read 2026-09-09. The gear rows had it right all along.


**Taken for RIFTS ULTIMATE EDITION, 2026-09-09 — the third of the five book
sessions. It shipped FIVE vessels where this finding counts six, and it filed
three findings on the way.** Two books remain: Phase World 1 row, and the one row
with no book behind it.

**The count was wrong again, in both directions again.** This finding's RUE share
comes from `category = 'vehicle' AND description LIKE '%Main Body%'`, which
returns six. The book's `Common Vehicles` section on printed 266-267 is **five
machines and a jet pack**, and the filter:

<!-- claim-ok: quoting the premises this note corrects -->

- **includes `wilk-s-atv-transport-vehicle`, which is not a machine.** It is the
  Mountaineer ATV's stat block under a name assembled across a page break. `F43`.
- **includes `northern-gun-sky-king`, which this book does not print.** It is in
  the ORIGINAL core book, at the row's own stored 130. `F43`.
- **misses seven rows**, four of them the same five machines stored under a
  second slug: `speedster-hovercycle`, `big-boss-atv`, `mountaineer-atv`,
  `a-t-v-speedster-hover-cycle`. The `LIKE` selected the prose-rich copy of each
  machine rather than the book-correct one — the same asymmetry the Wormwood
  note records.

**The measurement to carry forward: `LIKE '%Main Body%'` has now been wrong for
all three books it has been tested against.** It counted 7 for Juicer Uprising
and understated the mechanical share; 9 for Wormwood where 2 were vessels; 6 here
where 5 are. It is a prose-shape filter, not a vessel test.

**Three findings came out of reading the book, and none of them was fixed here.**
`F41` is about moving vessels; rewriting catalog values from a book session is
not something this finding asked for:

- **`F42`** — six rows carry FIRST-EDITION M.D.C. under a RUE citation, and ten
  published class references point at them. Every divergence lands exactly on
  the older printing.
- **`F43`** — the two rows above, citing RUE for machines it does not carry.
- **`F44`** — `findDuplicates` scores two of the three duplicate pairs at 0.500
  and 0.333 against a 0.7 threshold, because `normaliseName` splits `A.T.V.`
  into three tokens.

**Filing three findings inside a take is this finding's own precedent** — `F41`
was itself filed while building the gear-and-vessels sequence, in the PRs that
shipped it. They ride in this PR rather than a separate one because a stacked PR
dies here when its base is deleted.

**THE PRICE CROSS-CHECK PASSED AND WAS WRONG, which is the most useful thing this
session learned.** The Juicer Uprising note above calls seven matching prices
*"the strongest evidence in this file"*, and `book-survey` section 0c prescribes
exactly that check. Here all six prices matched RUE and **six of six rows were
still wrong**, because RUE's errata moved the M.D.C. and left the prices alone.
A price agreeing across two editions says nothing about a combat number. `F42`
carries the table.

**The posture held.** All eight pointed gear rows kept their slug, prose and
values — including the four wrong ones, deliberately, so `F42` stays visible
rather than being quietly resolved by a session that had no mandate to. No
schema change came out of this session.

**Every gear row naming a machine points at that machine's vessel — eight rows,
five vessels.** A departure from the two earlier imports, where each vessel had
exactly one gear row, and it is what makes the duplication legible rather than
hidden. `wilk-s-atv-transport-vehicle` gets no pointer even though its figures
are the Mountaineer's, because its NAME is what `F43` disputes.

**What shipped** (`zzzzzzzz-rue-vessels-p266-267.sql`): 5 vessels, 11 M.D.C.
locations, 7 weapon entries, 8 gear pointers. Eight z's to sort after
`zzzzzzz-ju-vessels-p077-088.sql`, whose readback asserts a **global** pointer
count and would be falsified by these landing first.

**Read twice, because this one is a scan.** `rue` is `text_layer: false`, so
`scripts/read-columns.py` is unavailable exactly as it was for Wormwood. Every
figure was read from the cached OCR of printed 266-267 and confirmed against a
200 dpi render of both pages, with 500-600 dpi crops for the three numbers `F42`
turns on. The offset was confirmed the free way `book-survey` section 0d
prescribes — both renders carry their folio — so `page_offset: 3` as the
registry records, and the cache manifest agrees with it on `printed_pages` too.

**One printed value is missing from the book and is stored as missing.** The
Highway-Man's line reads `M.D.C. by Location: Main Body: 75, Tires (2)` and
stops; the motorcycle illustration overlaps where the number belongs, a 600 dpi
crop shows no digit under the art, and the OCR renders the same truncation. Its
`mdc` is NULL with the reason in `mdc_note`. Every other vehicle in the section
prints its tire figure.

**One readback was wrong on first apply** — `their weapon entries` asserted 8
against a file containing 7. Re-derived by counting the `VALUES` rows in the
file, which is the distinction the Juicer Uprising session got wrong three times.

**The premise audit ran to completion and found the edition mismatch from the
gear rows alone**, before the book was opened for it — it noticed that every
non-M.D.C. field matched RUE and inferred a different printing. Confirming that
against the original core book, and finding the Sky King's stat block there, was
this session's work. The two passes met in the middle, which is the shape the
Wormwood note describes.

**Taken for PHASE WORLD, 2026-09-09 — the fourth of the five book sessions, and
the first where this finding's count was RIGHT.** One row remains: the
web-sourced `glitter-boy-power-armor`, which is a decision rather than a book
session.

**One row, one vessel, and no correction to make.** `psionic-power-armor` is the
only `category = 'vehicle'` gear row citing this book — checked without the
`LIKE '%Main Body%'` filter as well, since that filter missed rows in two of the
three books before this one, and the wider query returns the same single row
(`--remote`, 2026-09-09). Saying so plainly matters: three consecutive
corrections would otherwise leave the next reader assuming a fourth.

**It is a machine by the test the Wormwood session established.** The book's own
`Class:` line reads `Psionic Assault Exoskeleton`, and the entry carries a crew,
a power system, a market cost and six numbered weapon systems. Nothing in it has
a Horror Factor or an I.Q., so nothing `vehicles` cannot hold would be dropped.

**THE STORED FIGURES WERE RIGHT ON THE FIRST READING — the first time in this
sequence.** The gear row holds `mdc = 210` and `cost = 4000000`; the book prints
`** Main Body - 210` and `Market Cost: Mark V: Four million credits. Mark X:
Eight million credits.` Both were read off the book before the catalog was
consulted, and the 4,000,000 is the low end of the two-model range, which is the
convention `gear.cost` documents.

**And this is not the evidence `F42` discredited.** That finding showed six RUE
rows whose PRICES matched RUE exactly while every M.D.C. came from an earlier
printing, because the errata moved combat numbers and left prices alone. Here
the M.D.C. matches as well, which is the check that actually bears weight, and
Phase World has had no second edition for a figure to drift between.

**Two models, one row**, on the shape Nate settled for the NG-JK1 in the Juicer
Uprising session. `Model Type: NF Model V or X (identical except for the
contragravity flight system)`, and the book prints ONE M.D.C. table for both:
the models differ in flight, weight, power system and price only. So the X's
figures ride in `speed_air`, `weight_tons` and `cost_note`. It applies more
cleanly here than it did there — the JK1B changed nine location values and still
got one row, where the Model X changes none.

**The ordinals are the book's, for the first time in this sequence.** Phase World
prints `Weapon Systems` numbered 1 through 6, so they are transcribed rather than
invented — unlike the Wormwood and RUE scripts, which had to number their own
because those books print prose. Entries 5 and 6 are not guns and say so in their
`note`, on the Free Quebec convention.

**THE CACHE WELDS PRINTED 129, AND THE RENDER IS WHY THAT DID NOT MATTER.** On
that page `Speed:` and `Running: 100 mph` from the left column interleave line by
line with `Flying:`, `Range:` and `Statistical Data:` from the right:

<!-- claim-ok: quoting the cache's own welded output -->

```
Speed: Statistical Data:
Running: 100 mph (160 km) maximum; the act of running Height: 9 feet (2.7 m)
```

That is the corrupting read `book-survey` section 0b names, in the same page that
carries the M.D.C. block. The figures happened to be separable by eye and would
not be in general. A 200 dpi render of all three pages separates the columns and
confirms every value. **The `phase-world` manifest carries no `welded_pages`
key**, so nothing warned about this — the same tell the `ju` and `ww` caches
gave, and the reason a render is not optional on a book cached before that
detector existed.

The offset was confirmed the free way section 0d prescribes and got three
confirmations: the renders of printed 128, 129 and 130 each carry that folio, so
`page_offset: 0` as `scripts/books.json` records. Zero is the awkward case
section 0d names, because there is no offset left to explain a wrong page with.

**The page citation was checked rather than copied.** The gear row cites
`p.128-130`, and it is right: the heading `Psionic Power Armor` sits at the foot
of printed 128 and the stat block ends on 130. Both earlier sessions found a
citation off by one or wider than the entry, so this one was verified.

**A weapon the prose names and the stat block omits.** Printed 129 says *the most
fearsome weapon of the armor is a two-handed energy blade, an artificial version
of a psi-sword*, and the numbered `Weapon Systems` list never mentions it, gives
it no damage and never returns to it. It is recorded in the vessel's description
as prose rather than as a seventh `vehicle_weapons` row, because numbering a
system the book does not number would put a weapon in the list that no reader can
find in the book.

**What shipped** (`zzzzzzzz-pw-vessels-p128-130.sql`): 1 vessel, 6 M.D.C.
locations, 6 weapon systems, 1 gear pointer. All ten readbacks passed on the
first apply. Eight z's, sorting after the Juicer Uprising and Wormwood files and
BEFORE the RUE one — the `ju` script asserts a **global** pointer count so every
later book must sort after it, while the `rue` script's readbacks are all
book-scoped, so `pw` sorting ahead of it alphabetically breaks nothing and a
ninth `z` would have bought a new tier row in `docs/operations.md` for nothing.

**The posture held.** The gear row kept its slug, prose and both values and
gained only a pointer. No schema change. `noro-mystic-warrior` is the one
published class citing it, which is fitting — the noro built the armour.

**What this session did NOT do, and it is a large thing.** This book stats
**eleven more vessels** in `Robots & Powered Armor` (printed 130-142) and
`Tanks & Infantry Fighting Vehicles` (143-149), plus every starship of 157-173.
`docs/surveys/phase-world.md` inventories all of them. **None is in scope**:
`F41` covers the gear rows that were already vessels in disguise, and importing
this book's vessel sections whole is a different job that nobody has asked for.
The survey's claim that *"There is no table for a vessel"* was true when written
on 2026-08-31 and is corrected in place, in this PR, with the date — migration
048 built one on 2026-09-03.

**THE PREMISE AUDIT RAN CONCURRENTLY WITH THE IMPLEMENTATION, NOT AHEAD OF IT,
and that is the same failure the Juicer Uprising note above records.** The
`audit-premise-auditor` subagent was launched first and then not waited for: the
book was read, the script written, applied to `--local` and committed while it
was still running. It can date the overlap itself — two of its own greps returned
different answers on a re-run, because this session edited the files between
them.

**So its findings are a post-hoc check of shipped work rather than an input to
scoping.** Everything it measured independently held — the single row, the
machine test, no duplicate, one citing class, a clean import, the registry and
the manifest agreeing — but the conflict the subagent exists to break was not
broken, for the second time in four sessions. **Launching it is not the same as
using it**, and the Juicer Uprising note's lesson was about a subagent that
stalled, where this one worked perfectly and was simply overtaken.

**It caught three defects anyway, two of them written by this session:**

- The survey ledger row said **`Applied --remote before the PR`** before the
  apply had happened, copying a form of words the other ledger rows had earned.
  Production still read 141 vessels when it checked. Reworded to say what is
  true: the apply is the merge gate, and the row was written first.
- `scripts/books.json` ended this book's note with *"Nothing in production cites
  this book yet"*, false since 2026-08-30 — measured `--remote` on 2026-09-09 it
  is **50 gear rows and 35 published classes**. It sits three lines from the
  `page_offset: 0` a book session relies on. Corrected, and **four other book
  notes in that file carry the same sentence**, at least one of them also stale.
  That sweep is NOT done here and is worth its own finding.
- `docs/operations.md`'s eighth-z row, written by the RUE session two PRs ago,
  overstated the ordering rule and got `rue` wrong. The only global readback
  among the vessel scripts is the Juicer Uprising one, so the whole constraint is
  *sort after `ju`*; the row claimed the book sessions are ordered by z-count
  from here on, which would cost a later reader a ninth `z` to buy nothing.
  Corrected in this PR.


**Taken for THE WEB-SOURCED ROW, 2026-09-09 — the last item, and F41 IS NOW
COMPLETE.** Five sessions, PRs #856-#857, #858, #859, #860 and this one.

**This was not the decision this finding expected, because its premise was
false.** F41 sets the row aside as *"a sixth decision for the web-sourced row"* —
a judgement about whether to trust an unverifiable figure — and all four earlier
notes repeat *"the one row with no book behind it"*.

<!-- claim-ok: quoting the premise this note corrects -->

**Three books on this machine stat the Glitter Boy, and one of them is a book
this very sequence had already opened.** Rifts Ultimate Edition printed 71-72
carries the entry under the row's own model designation, `USA-G10`, and prints
every one of the seven M.D.C. figures the row stored:

| the gear row, from the web | RUE printed 71 |
|---|---|
| main body 770, head 290, arms 270 each, legs 450 each, hands 100 each, rail gun 175, reinforced pilot compartment 150 | identical, all seven |
| "10 feet 5 inches, 1.2 tons loaded" | Height 10 ft 5 in (3.1 m); Weight 1.2 tons fully loaded |
| "60 mph; leaps 12 feet, or 22 with a running start" | Running 60 mph (96 km); leap 12 ft (3.6 m), plus 10 ft (3 m) running |
| "Laser weapons do HALF damage to it" | *"Laser weapons do half damage to the Glitter Boy!"* |

The original core book and Free Quebec printed 82 carry it too. **The RUE
session read only `Common Vehicles` on printed 266-267; this stat block sits 195
pages earlier in the O.C.C. chapter and was never in that session's filter.**

**ONE FIGURE WAS WRONG, and it is the kind the marker exists to catch.** The row
said `nuclear power (20 year charge)`; RUE printed 72 and the original core book
both print **25 years**, and Free Quebec prints 20 — so it was a blended reading
across editions. Corrected here.

**Correcting a gear value here is not what `F42` declined, and the difference is
the point.** `F42` left six RUE rows alone because *which edition the catalog
states* is a real decision with two coherent answers. This row stated no edition
and claimed no book at all; leaving a figure that contradicts the book it is now
cited to would have MANUFACTURED an `F42`. The repo already had the pattern —
`backfill-rue-equipment.sql` re-cites eleven web-sourced rows to RUE pages and
corrects what the book contradicts, each `UPDATE` guarded on the marker.

**A Glitter Boy was already in `vehicles`, and Nate chose not to point at it.**
The Free Quebec sequence imported `classic-glitter-boy-qgb-100` carrying all
seven figures **plus an eighth** — the Rimouski Left Forearm Weapon Package at
110, which the USA-G10 does not have, alongside a different Boom Gun model, a
20-year power system and Quebec's own price. Settled 2026-09-09: **import RUE's
USA-G10 as its own vessel** rather than send a RUE-cited row to Quebec's
production model. They are two machines, the books print them as separate
entries, and the catalog already holds five other Quebec variants beside the
classic. **The price was filled in on the same call** — RUE's 25 million for a
new complete machine, the 15-20 million band being a rebuilt or gunless suit
rather than the low end of one range.

**What shipped** (`zzzzzzzz-web-glitter-boy-p071-072.sql`): 1 vessel, 7 M.D.C.
locations, 3 weapon systems with the book's own ordinals, and one gear row
re-cited, priced, corrected and pointed.

**THE FILENAME IS THE ORDERING TRAP, HIT FOR REAL.** This file re-cites a ninth
gear row into `source_book LIKE '%Ultimate%'` and points it — and
`zzzzzzzz-rue-vessels-p266-267.sql` asserts that count is **8**. Named `gb-` it
would have sorted before that script and falsified its readback on a clean
rebuild; `web-` sorts after it at the same tier. Caught by reading the earlier
script's readbacks before choosing a name, which is the only thing that catches
it.

**One readback was wrong on first apply, and the error is worth recording.** It
asserted that no web-sourced row carries a combat number, on the strength of a
report rather than a measurement. **Four do** — `c-18-laser-pistol` (2D4),
`cyber-armor` (mdc 50, ar 16), `hand-axe` and `hatchet` (1D6 each). The true
claim is narrower: the Glitter Boy was the only web-sourced row with a
per-location M.D.C. stat block. The assertion now says four.

**And that turns up something this finding does not cover.** The README's
estimate tier forbids an ESTIMATED row from carrying M.D.C., damage or an A.R.
at all; the web marker carries no equivalent rule, and those four rows hold
combat numbers no book has been shown to back. Named here rather than filed.

**The README's own worked example is this row**, and it has been updated: it
argued the marker exists *"so a book correction knows what it is overwriting"*,
and on 2026-09-09 that is exactly what happened. Its count also said *Forty*,
measured 28, and is 27 now.

---

## F41 is closed, 2026-09-09

Twenty-four rows, five sessions, **fifteen vessels** imported and **nineteen gear
pointers** set. What the five sessions actually established, none of which this
finding predicted:

- **`LIKE '%Main Body%'` is a prose-shape filter, not a vessel test.** It was
  wrong for four of the five books — understating Juicer Uprising, counting 9
  Wormwood rows where 2 were vessels, 6 RUE rows where 5 are, and calling this
  row unverifiable. Only Phase World's count held.
- **The book's own `Class:` line settles what a thing is** — `Wormwood organism`
  against `Magic symbiotic war machine`, `Psionic Assault Exoskeleton`, `Laser
  Resistant Infantry Personnel Assault Unit`.
- **A matching price is not evidence the combat numbers are right.** `F42` is
  the case: six RUE rows whose prices matched exactly and whose every M.D.C.
  came from an earlier printing.
- **Three findings came out of the work** — `F42`, `F43`, `F44` — none of which
  this finding anticipated, all from reading books it assumed had been read.
- **F42** — high - six Rifts Ultimate Edition gear rows carry FIRST-EDITION figures under a RUE citation, and ten published class references point at them — Taken, 2026-09-09 (PR #864). Nate chose RUE, so the values move and the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F42` heading.

- **F43** — two gear rows cite Rifts Ultimate Edition for machines it does not print — Taken, 2026-09-09 (PR #863). Posture held: a merge and a re-citation, no — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F43` heading.

- **F44** — `findDuplicates` cannot see an acronym written two ways, so two of three real duplicate pairs are invisible — Taken, 2026-09-09 (PR #862). Posture held: `normaliseName` only. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F44` heading.

- **F45** — six book notes in the registry made a standing claim about live data, and four of the six were false — Taken, 2026-09-09 (PR #865). Posture: correct the notes, and make the shape — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F45` heading.

- **F46** — the web marker has no rule against combat numbers, and four rows held them — Taken, 2026-09-09 (PR #866). Posture held: re-cite what the books support, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F46` heading.

- **F47** — three of the five duplicate pairs were duplicates; the other two were the book naming two things — Taken on Nate's word, 2026-09-09 (PR #867). Five candidate pairs came out of — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F47` heading.

- **F48** — a literal NUL byte in `catalog-merge.js` made the whole file unreviewable — Taken 2026-08-31 in PR #869, and this note is added 2026-09-15 because it — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F48` heading.

- **F49** — one skill taken THREE TIMES for three different weapons, and a class may grant it once — Taken, 2026-09-10 (PR #909). Posture held: a display and composition change, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F49` heading.

### F50 - `equipment_starting` cannot grant a SKILL, and one book's gear choice does

**Filed 2026-09-09**, during the `new-west` class import, batch 1.

New West's Bounty Hunter (printed 89-90) ends with **Special Equipment: Pick
one**, and offers four packages. The second reads: a suit of light to medium
power armour, and *"Automatically gets the basic pilot robots and Power Armor
skill."*

`equipment_starting` takes gear slugs and quantities. It has no way to say that
choosing an option also grants a skill, and `occ_skills` has no way to say that
a skill is granted only if a particular equipment option was taken. The two
blocks do not see each other.

**Two of the four options have no catalog shape either** - a Techno-Wizard or
magic armour plus a magic weapon, or a bio-wizard parasite with 1D4 microbes -
so this is not a case where three of four could be modelled and one noted.

**Stored as:** the whole four-way choice is in `extraction_notes` on
`bounty-hunter`, and nothing from it is in `equipment_starting`. That is
deliberate: half-modelling it would put armour on the sheet and silently drop
the skill that comes with it, which reads as complete and is not.

**Affected rows.** `bounty-hunter` today. A grant of gear-and-a-skill together
is a common Palladium shape and this is unlikely to be the only one; **the count
here is one because one book has been read for it, not because a sweep found
one.** No sweep has been run.

**Proposed change, NOT implemented.** Either a `grants_skill` key on an
`equipment_starting` choice option, or the inverse - an `occ_skills` entry
conditional on an equipment pick. The first is smaller and keeps the condition
where the choice is made. **Check before scoping:** whether `equipment_starting`
choice options are resolved at creation or re-derived per render, because the
reference says a choice's `qty` is re-derived and a granted skill must not be.

**HELD, 2026-09-10 (PR #910). The premises are corrected and the capability is
NOT built, because neither class that wants it could use it.** Posture:
documentation only. No key added, no schema, no data change.

**THE CHECK-BEFORE-SCOPING QUESTION IS ANSWERED, AND THE ANSWER IS THE ONE THAT
CONSTRAINS A TAKER.** `equipment_starting` choice options ARE re-derived on
every render: `initEquipment` (`app.js:2545-2573`) rebuilds `S.gearChoices` each
time and is deliberately NOT guarded by `equipInit`, with the comment *"A
restored draft brings back which options were TICKED but not what the options
were."* **Only the tick is persisted.** So a granted skill must be resolved FROM
the persisted tick and never re-derived beside the options. The finding was
right to ask. (It attributes the `qty` claim to `docs/wizard-and-sheet.md`; the
sentence actually lives at `js/parser.js:2386-2392`. The claim is true, the
citation is not.)

**The ORDERING works, which the finding does not raise and a taker would
worry about.** Equipment is step 6 and skills are step 5, so an
equipment-granted skill arrives after the skills step - but `skillsAtLevelOne()`
is called from `characterAtLevelOne()` (`app.js:1798-1805`), which builds the
SAVE payload. By then the tick exists.

**WHY IT IS HELD: BOTH CLASSES THAT WANT IT STAY UNMODELLABLE ANYWAY.** The
skill is one of several things their choice needs, and it is not the only
missing one:

| Bounty Hunter / Justice Ranger option | what it needs | available? |
|---|---|---|
| armour or TW weapon **plus 2D6x1000 credits** | a sum of money in `equipment_starting` | **no** |
| light or medium power armour, **granting Pilot Robots and Power Armor** | the skill grant | **no - this finding** |
| TW or magic armour and a magic weapon, or a bio-wizard parasite | catalog rows that do not exist | **no** |
| a souped-up vehicle, or a robot horse | a gear row pointing at a vessel | **yes, see below** |

So `grants_skill` would ship as a key **no live class could use**, because
adding it still leaves three of the four options unexpressible and both classes
recorded the whole choice in `extraction_notes` rather than half-modelling it.
That is the trade `F55` was filed to name, and it applies here for the same
reason.

**A CLAIM I NEARLY MADE AND CHECKED FIRST: `equipment_starting` CAN reference a
vehicle.** It resolves slugs against the gear catalog through `findItem`
(`app.js:2533-2539`), which reads only `S.items` - so the obvious conclusion is
that power armour and robot horses are out of reach. **They are not.**
`gear.vehicle_slug` exists from migration 053 and **16 live gear rows point at a
vessel**, `glitter-boy-power-armor` among them (`--remote`, 2026-09-10). F41
built that bridge. An absence claim about a capability is the shape most likely
to be wrong, and this one was.

**Two more corrections to the finding's own text:**

- **"Affected rows: `bounty-hunter` today" points at the wrong row.**
  `node scripts/audit-citations.mjs --remote F50` returns **`justice-ranger`**
  only - and `bounty-hunter`, the class this finding is *about*, does not cite
  F50 at all. A taker following the script finds the second class and not the
  first.
- **"Two of the four options have no catalog shape either" miscounts the
  options.** Those two are the two BRANCHES of option 3 (printed 91: *"Magic
  Armor: One Techno-Wizard or other type of magic armor and one magic weapon...
  Or one major bio-wizard parasite, plus 1D4 microbes"*). The `bounty-hunter`
  row itself says it correctly - *"Only the third and fourth have no catalog
  shape at all"*.

**One thing a taker needs that the finding does not say:** neither validator
rejects unknown keys, so a `grants_skill` written today **parses clean, stores,
and is silently ignored** - the exact shape `F52` was filed about and the reason
this must not be half-shipped. The obvious alternative route is closed on
purpose: `ABILITY_GRANTS = ['bonuses', 'psionics', 'magic']`
(`js/parser.js:1644`), and `js/parser.js:1751-1757` records that an ability
carrying a skills block was rejected as *"the same power by another name"*.

**What would change this.** A way to express the other three options - money in
starting equipment, and catalog rows for the TW and magic items - or a decision
that a PARTIAL model is better than none, which both classes' notes currently
reject. Either makes `grants_skill` worth the key it costs. **Reopen on either.**

**Nate's decision, 2026-09-10 (PR #933): leave it held.** Not open - reopen only on the trigger named above.

- **F51** — `race_restrictions` matches a race by ID, and a book bars races by KIND — CLOSED UNDONE, 2026-09-10 (PR #907), which is the outcome this proposal — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F51` heading.

- **F52** — high - a DICE STRING in `bonuses` parses clean, stores, and is silently dropped, and 34 published classes carry one — CLOSED AS FALSIFIED, 2026-09-10 (PR #905). NOT IMPLEMENTED, and that is a — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F52` heading.

- **F53** — high - `corrupt_pages` detects glyphs that FAIL to map, and the commoner fault maps to a VALID character — Taken, 2026-09-10 (PR #904). Posture held: warn, do not block. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F53` heading.

- **F54** — low - a gear row may not carry both an S.D.C. and a damage die, and a grenade legitimately does — Shipped in PR #897 with `sdc` NULL and the 20 in the `description`, because — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F54` heading.

### F55 - low - `gear` has nowhere to record a CREATION cost, and RECOMMENDS BEING DECLINED for now

**Found while importing `new-west` Techno-Wizard weapons, PR #898, 2026-09-10.**

All twelve TW weapons state four things a Techno-Wizard character needs and the
`gear` table has no column for any of them: an **initial P.P.E. cost** (40 to
195), the **spells needed** with their own P.P.E. costs, a **physical
requirement** including a gem of stated value (300 to 10,000 credits), and the
**hours of work** (3D4 hours to 120). The Ironhorse's is 9,540 P.P.E. and 3700
to 4000 hours.

**Evidence:** `gear`'s schema read `--remote` on 2026-09-10 via
`node scripts/q.mjs --remote "SELECT sql FROM sqlite_master WHERE name='gear'"`
- eighteen columns: `id, slug, name, system, category, weight_lbs, cost,
cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc,
description, source_book, vehicle_slug`. None of the four fits any of them.
All twelve rows put the whole block in `description` instead, prefixed
`CREATION:`.

**Proposal, and it recommends declining itself for now.** The mechanical answer
is four columns or a `gear_creation` child table. The honest answer is that
**nothing in the app reads any of it**, and neither does anything read the
`vehicles` tables that have carried richer structure since migration 048. Adding
columns means a migration, a backfill across every book that prints TW or
alchemical creation stats, and a permanent obligation on every future gear
import to fill them - for data with no consumer.

So: **file it, store the prose, and hold.** What would change the recommendation
is a consumer - a Techno-Wizard creation view, or a search that wants "items I
can build with 60 P.P.E." If one is ever built, this is the finding to take
first, and the twelve rows are already consistent enough to parse.

**Posture: documentation of the gap only. No schema change, no migration, no
new gate.** This finding exists so the next importer knows the prose is a
decision rather than laziness, and so the gap is reachable by number.

**Confidence: high on the absence** - the schema is quoted above from the live
database. **The judgement that it should be held is a judgement, not a
measurement**, and what would raise it is somebody wanting the data.

**Ongoing cost of taking it:** four columns, one migration, a backfill across at
least Triax, Free Quebec and New West, and a field every future gear import must
consider. **Ongoing cost of declining it:** the prose stays unparseable, and a
future consumer pays to extract it.

**Subject grep, 2026-09-10:** `creation`, `P.P.E. cost` and `gear` schema
questions across every menu plus the memory store. `F41`'s Wormwood outcome note
is the nearest precedent and it points the other way - it declined to widen
`vehicles` for parasite entries carrying Horror Factor, I.Q. and attacks per
melee, on the grounds that importing one *"would DROP them, which is worse than
the cosmetic split this finding set out to fix."* That decision is named here
rather than re-litigated, per the rule about re-proposing settled questions.

**HELD, 2026-09-10 (PR #910), which is what this finding recommended for
itself.** Posture: documentation only. No columns, no migration, no data change.

**Nothing has changed the argument.** The twelve Techno-Wizard rows still carry
their creation stats as prose, nothing in the app reads them, and no consumer
has appeared. The schema was re-read `--remote` on 2026-09-10 while closing
`F50` and `gear` is unchanged at eighteen columns.

**It is now one of a PAIR and they should be decided together.** `F50` was held
the same day for the same reason: a small, correct frontmatter key with no live
class able to use it. If the answer to one is *"build it anyway, the cost is
low"*, it is probably the answer to both.

**Nate's decision, 2026-09-10 (PR #933): leave it held**, as the finding itself recommended.

- **F56** — medium - a TOTEM is a 48-entry choice table nine classes share, and it grants SKILLS, which no choice a class can offer is able to carry — Taken, 2026-09-10 (PR #944). As written: a `totems` catalog (migration — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F56` heading.

- **F57** — low - a spell pool stated as a LEVEL RANGE admits every tradition's leveled spells, and the Ley Line Walker is offered 167 warlock and ocean spells today — Taken, 2026-09-10 (PR #943) - built fully on Nate's word, which is wider than — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F57` heading.

- **F58** — medium - `regression.mjs` kills the bootstrap build at 180 seconds, the build now takes longer, and the failure reads as "cannot build a database" with no reason — Taken, 2026-09-10 (PR #942) - part (b) as written; part (a) declined on — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F58` heading.

- **F59** — low - `spells_per_level_from: true` is read by nothing, and two class notes say a list carries a pick that it does not — Taken, 2026-09-11 (PR #945). As written, both branches of the proposal, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F59` heading.

- **F60** — low - a race's FLAT attribute bonus is lost when an occupation grants DICE to the same attribute, because the wizard rolls the two halves apart — Taken, 2026-09-11 (PR #946). As written - `classBonuses` counts a list's — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F60` heading.

- **F61** — low - a spell pick drawn from a NAMED LIST loses the class's LEVEL CAP, and three Spirit West shamans' books state both — Taken, 2026-09-11 (PR #951). Option A: `spell_levels: — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F61` heading.

- **F62** — low - a supernatural P.E. that turns S.D.C. and hit points into M.D.C. has no field, so three classes carry it as prose — Taken, 2026-09-11 (PR #950). Option A as written - an opt-in class flag, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F62` heading.

- **F63** — low - an ELEMENT choice cannot steer the Elemental Shaman's spells or grant its skill, so the class offers all four elements' spells with a note — Taken, 2026-09-11 (PR #952). Option A, with one departure from its posture: — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F63` heading.

- **F64** — low - the Spirit Warrior's mega-damage conversion rides on two of its six realms, and a chosen ability cannot carry F62's flag — Taken, 2026-09-11 (PR #954). Option A, in the shape Nate chose after the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F64` heading.

- **F65** — medium - a psionic level-up grant drawn from a NAMED LIST loses the list, so ten classes' named psionic picks are not enforced — Taken, 2026-09-11 (PR #955). Option A, code only as the posture says, with — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F65` heading.

- **F66** — low - the sheet's psionic level-up pickers match a category with a plain `includes`, so an object gate entry offers nothing — Taken, 2026-09-11 (PR #958). Option A, code only as the posture says, plus — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F66` heading.

- **F67** — low - changing a chosen ability after the pools are rolled leaves them stale, and a character who now converts saves with S.D.C. and hit points — Taken, 2026-09-11 (PR #960). Option A, code only as the posture says, with — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F67` heading.

- **F68** — low - changing a VARIANT or an occupation after the pools are rolled leaves them stale, the same way an ability did — Taken, 2026-09-12 (PR #963). Option A, code only as the posture says - on — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F68` heading.

- **F69** — medium - an object category gate is refused outright by the create validator, so three classes cannot be saved with their own starting psionics — Taken, 2026-09-11 (PR #962). Option A, code only as the posture says, plus — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F69` heading.

- **F70** — low - re-rolling an attribute, or the psionic tier, leaves the pools stale; and a variant that restates attribute_dice leaves the attributes stale — Taken, 2026-09-12 (PR #964). Option A, both halves, code only as the posture — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F70` heading.

- **F71** — medium - thirteen handlers clear `S.pools` and none clears `S.levelPools`, so a character above level 1 keeps growth rolled off pools that are gone — Taken, 2026-09-12 (PR #966). Option A as written - one helper - and the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F71` heading.

- **F72** — low - the level SPELLS, PSIONICS and SKILL PICKS are keyed by grant index, and nothing re-keys them when the class changes — Adjusted 2026-09-12 (PR #967), before being taken, from — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F72` heading.

## Nightbane, 2026-09-12 — F73-F78

Six gaps from surveying the Nightbane core book, filed per `book-survey` §8. The
survey is `apps/character-creator/docs/surveys/nightbane-core.md` and carries the
measurements each of these quotes. **Status lives under each finding; read to the
next `###`.**

**Corrected 2026-09-12, the same day it was written.** This lead claimed F73
blocked the other five, on the ground that
<!-- claim-ok: quoting the overstated lead this paragraph replaces -->
*"until a third system exists, no Nightbane row can be written at all"*. That is
wrong, and F73's own outcome note carries the measurement: `source_book` is bare
TEXT in every table that holds it, so a Nightbane spell, skill or psionic row
could always have been written with `system` NULL — production holds
`Lore: Nightbane` that way already. What F73 really gated was system-TAGGING a
row, creating a Nightbane campaign, and passing a class through the parser.

**It was also a claim about other findings' state carrying no finding number**,
which `audit-menu` names as invisible to every sweep here: a taker of F74
grepping for `F74` never meets the line that is wrong about it.

- **F73** — high - `system` is a two-value enum in three CHECK constraints and in the parser, so a book from a THIRD Palladium game cannot be cited by any catalog row — Taken, 2026-09-12 (PR #996) — and NOT as Option A. Nate chose the route he — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F73` heading.

- **F84** — high - a restriction written on the choice GROUP instead of on the category is stored, never read, and reported `ready` — TAKEN, 2026-09-14 (PR #1045) - OPTION A, THE PARSER HALF, AS WRITTEN. The — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F84` heading.

- **F83** — high - a choice group cannot state a book's own skill percentage, and Heroes Unlimited prints its own for every skill — TAKEN 2026-09-14, AS OPTION C. `skill_system_bases (skill_name, system, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F83` heading.

- **F82** — high - `skills.mos.choose` is validated and never honoured, and `skill_programs` cannot express a single Heroes Unlimited skill program — TAKEN 2026-09-14, AS OPTION A. `skills.mos.choose` is honoured end to end. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F82` heading.

- **F74** — medium - a class states one attribute block, one `sdc_base` and one `hit_points_base`, so a character with two bodies can only describe the second in prose — Taken, 2026-09-15 (PR #1080), at the posture it asked for: RECORD AND STOP. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F74` heading.

- **F75** — low - a Horror Factor a character PROJECTS has no field; the only `horror_factor` here is the save against someone else's — Taken, 2026-09-15 (PR #1081), on Nate's word, and the premise pass overturned — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F75` heading.

- **F76** — low - a power that costs P.P.E. permanently to ACQUIRE and again to USE fits neither `spells` nor `psionic_powers` — Taken, 2026-09-15. Option B, in four PRs. 1 of 4 is PR #1084 - storage; the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F76` heading.

- **F77** — low - `VALID_CATEGORIES` is `['rcc', 'occ']`, and the one P.C.C. in the catalog says so in a `restrictions:` line — Taken, 2026-09-15 (PR #1079). DECLINED, which is what it proposed for — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F77` heading.

- **F78** — low - a creation-time roll table that permanently modifies the character has no home, and Nightbane ships nineteen of them — Taken, 2026-09-16 (PR #1088). DECLINED, on Nate's word, and the finding — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F78` heading.

- **F79** — high - `--probe` classifies a book by character COUNT alone, so a text layer whose glyphs are dropped reads as clean and caches as garbage — Taken, 2026-09-15 (PR #1064) - as C, plus a BETTER A than the one proposed. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F79` heading.

- **F80** — medium - `per_level` is READ on a skill entry and validated on neither branch, and this settles the question F25 left open — Taken, 2026-09-13 (PR #1020), as proposed, in one PR with this filing. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F80` heading.

### F81 - medium - `supersedes_race` does not erase the race's `magic` or `psionics`, and the comment above `magic` says it does

**Found 2026-09-13** while adding the `super_abilities` grant block for Heroes
Unlimited, by writing a smoke check that asserted the comment and watching it
fail.

**What the comment claims.** `js/parser.js`, above the magic branch of
`combineClasses`:

> A superseding class is the exception, as it is everywhere else: a character
> the book says was remade does not keep its old race's magic either.

**What the code does.** `combineClasses` opens `const out = { ...rcc }`, so the
race's whole frontmatter is already in `out` before any block is considered. The
branch then runs:

```js
if (occ.magic || rcc.magic) {
  out.magic = superseded ? (occ.magic || rcc.magic) : mergeMagic(rcc.magic, occ.magic);
}
```

With a superseding occupation that states no magic, `occ.magic` is undefined and
`occ.magic || rcc.magic` hands the RACE's block straight back. Psionics never
had an erase at all - its line is `if (rcc.psionics || occ.psionics) out.psionics
= mergePsionics(...)`, with no `superseded` term.

**Measured, not inferred:**

```
race { magic: { type: 'spell', spells_starting: 4 },
       psionics: { type: 'major', powers_starting: 2 } }
occ  { supersedes_race: true }

merged.magic     -> {"type":"spell","spells_starting":4}
merged.psionics  -> {"type":"major","powers_starting":2}
```

**Why the gap is invisible.** `supersedes_race` marks a TRANSFORMATION - the
class whose book says the character stops being what it was - and such a class
is never itself a caster, so `occ.magic` is undefined in every case that exists.
The only branch that would ever erase anything is the one that never fires.
F11's own smoke coverage checks the SKILLS half, which does work: `pastLife` is
`[]` when superseded and 37 races' named skills really are dropped.

**Severity.** Medium rather than high because nothing in the live catalog is
wrong today: `supersedes_race` is opt-in, and the classes carrying it do not
compose with a race that states magic or psionics in a way anyone has built.
It is a rule that is written down, believed, and not enforced - which is the
shape that becomes wrong the first time the combination is made.

**The new block matches them deliberately.** `super_abilities` was written with
the identical `superseded ? (occ.X || rcc.X) : merge(...)` shape rather than
with the erase its author first wrote, so a fix is ONE change across three
blocks rather than a fourth behaviour to reconcile. The smoke section
`Super abilities` pins the current behaviour by name -
`a superseding occupation does NOT erase the race's block (F81)` - and pins
`magic` and `psionics` doing the same thing beside it, so taking this finding
turns three checks red at once and each one says what it expected.

**What taking it would cost.** Three lines and a decision about existing
characters: the erase is a composition rule, so a character already saved
against a superseding occupation would recompose without its race's spells. The
decision is whether that is a correction or a migration.

**THE RULES QUESTION IS ANSWERED, 2026-09-15 (PR #1071): NO. A superseding
class does NOT strip the race's magic or psionics.** Nate's call, asked rather
than assumed. **Nothing changes in the code** - the behaviour measured above is
the intended behaviour, the three smoke checks that pin it stay green, and the
comment `F81` corrected in PR #1063 was the whole defect.

**The book is the argument, and it was read before the question was put.** Rifts
Dimension Book 2: Phase World printed 102 (cache `p102.txt:68-69`, offset 0,
read 2026-09-15) enumerates exactly one loss:

> O.C.C. Skills: When the character is transformed, the skills of his past life
> are lost and the character is reborn.

<!-- claim-ok: quoting the book passage this decision rests on -->
**Skills, named; magic and psionics, not named.** Printed 100 explicitly KEEPS
the better half of what the race had - *"use these die rolls, or the attributes
of the character's original race, whichever are HIGHER"* - so the book is
willing to say when something survives the transformation as well as when it
does not. And the Fallen Cosmo-Knight, on that same printed 102, is described as
*"often endowed with magical or psionic powers"*, which reads as the lineage
carrying them rather than shedding them.

**So the erase branch that never fires is correct to never fire**, and the
sentence in `docs/race-and-occupation.md` - *"everything else | unchanged"* - is
right rather than an omission. A line naming the book has been added there so
the next reader meets the reason and not only the rule.

**The exposure, measured through the real parser rather than with `instr`,
`--remote` 2026-09-15** - because this is the number that made the question
worth asking rather than deferring:

| | |
|---|---|
| published classes carrying `supersedes_race` | **1** - `cosmo-knight` |
| published R.C.C.s | 107 |
| ...stating a magic or psionics block that is not `none` | **49** |
| ...of those, carrying no `occ_restrictions` at all | **47** |

So 47 race/occupation pairings reach this branch today. It was never
theoretical; it was only never noticed.

**A METHOD NOTE, because the first pass at that table was wrong in every cell.**
Counted with `instr(markdown, 'supersedes_race') > 0` it reported **two** classes
carrying the flag - the Fallen Cosmo-Knight's only occurrence of the word is in
its own `extraction_notes` prose, explaining that the key exists - and 108
R.C.C.s, 57 with magic and 50 with psionics, because `magic:` and `psionics:`
also match prose and match a block whose `type` is `none`. **A doc correction
saying "two classes carry it" was one keystroke from being written.** Read the
key through `parseClassMarkdown`; `instr` over a markdown column matches the
commentary as readily as the field.
- **F85** — medium - the coverage ledger checks five catalogs and there are eight, so 466 cited rows are verified by nothing; and its second table list checks four, which prints a phantom -171 — Taken, 2026-09-15 (PR #1075), as proposed and at the posture it asked for - — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F85` heading.

- **F86** — medium - `repo-vs-live` says "all catalogs" and compares five of eight, and `drift-check`'s citation check reads three — Taken, 2026-09-15 (PR #1076), and its central premise was dead before anybody — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F86` heading.

- **F87** — high - `unmodelledKeys` reads TOP-LEVEL keys only, so a wrong key one level down is invisible and `class-check` answers `ready` — Taken, 2026-09-15 (PR #1062), at the posture proposed - a report in — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F87` heading.

- **F88** — medium - a choice group's own `categories` array is never handed to `validateCategories`, so the entries F84 now insists on are themselves unchecked — Taken, 2026-09-15 (PR #1061), as proposed, at ERRORS. `validateCategories` — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F88` heading.

- **F89** — medium - three gear rows carry a citation in production that a clean rebuild does not produce, and the only check that compares the two counts rows — Taken, 2026-09-14 (PR #1058) - and SIX of its premises were wrong. The three — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F89` heading.

- **F90** — medium - nothing refuses a new catalog row on a RETIRED slug, and the check that would have noticed reports a total rather than a row — Taken, 2026-09-14 (PR #1059). Part 1 as proposed; Part 2 adjusted, because its — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F90` heading.

- **F91** — medium - a psionic power schedule's `categories` is read into `categoryAllows` and handed to `validateCategories` by nothing — Taken, 2026-09-15 (PR #1066). Shipped as proposed - two — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F91` heading.

- **F92** — low - a `bonus` on a psionic schedule category is stored and never read, and only `categories_allowed` refuses one — Taken, 2026-09-15 (PR #1073), as written and at ERRORS. The premise pass — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F92` heading.

- **F96** — medium - the level-up psionic picker prints `[object Object]` for an object category, and two published classes hit it — Taken, 2026-09-15 (PR #1077), as proposed and display-only. One expression: — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F96` heading.

- **F93** — medium - the duplicate scorer demotes on `category` and `system`, and `enchantments` is distinguished by neither — Taken, 2026-09-15 (PR #1074). The demotion shipped as proposed - drop to — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F93` heading.

- **F94** — high - `source-coverage.mjs` walks five tables of eight, and reported two fully-imported books as untouched — WITHDRAWN 2026-09-15 (PR #1070), THE SAME DAY IT WAS FILED. F94 IS A — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F94` heading.

- **F95** — medium - the last fifteen gear values where the repo and production disagree, and they do NOT all fall the same way — Taken, 2026-09-15 (PR #1078), both halves, each to the side this finding — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F95` heading.
