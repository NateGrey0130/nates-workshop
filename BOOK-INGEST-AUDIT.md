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

- **F24** — a book that ROLLS one of four psychic profiles: the powers fit, the RELATED-SKILL COUNT does not — Taken, 2026-09-07 (PR #789). Part (a) only, as written. (b) and (c) stand — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F24` heading.

- **F25** — a class whose book defines it AS another class, and nothing records that the two must stay identical — Taken, 2026-09-07 (PR #785). Posture honoured: assert, do not model. — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F25` heading.

- **F26** — one spell, two traditions, two costs, and one row — Taken, 2026-09-08 (PR #815), as the smaller option - `spells.same_spell_as` — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F26` heading.

- **F27** — `class-check` does not validate skill names inside an MOS option, and they fail silently — Taken, 2026-09-08 (PR #812). Both of the questions this finding left — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F27` heading.

- **F28** — the coverage ledger checks five catalogs and there are six, so no vessel's citation is verified — Taken, 2026-09-08 (PR #813) - filed and taken in one change, on the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F28` heading.

- **F29** — `Air: Sonic Blast` and `Sonic Blast` look like one spell twice, inside the Book of Magic — Taken, 2026-09-15 (PR #1072). ANSWERED BY READING THE TWO PAGES, AND THE — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F29` heading.

- **F30** — a cached page can be WELDED across the gutter, and nothing detects it — Taken, 2026-09-08 (PR #830). Detect and warn, as proposed. Nothing repairs — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F30` heading.

- **F31** — four chassis of one O.C.C. cannot be `variants`, because a variant may not add a skill — Taken, 2026-09-08 (PR #834). The mechanism only, on Nate's decision. The — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F31` heading.

- **F32** — `attribute_requirements` holds MINIMUMS only, and a book's MAXIMUM inverts silently — Taken, 2026-09-08 (PR #824). `attribute_maximums` exists, and the class that — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F32` heading.

- **F33** — the gear catalog holds the same item twice under two slugs, and no single detector finds them — Taken, 2026-09-08 (PR #825). Posture as proposed - reporting, plus a — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F33` heading.

- **F34** — the literacy placeholder is guarded and the LANGUAGE placeholder is not, so the same mistake fails on one and ships on the other — Taken, 2026-09-08 (PR #832). Both halves in one PR, as the finding insists - — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F34` heading.

- **F35** — `class-import` tells you to strip a prefix the catalog requires, and the advice produces the exact bug it warns about — Taken, 2026-09-08 (PR #823). Documentation only, on one skill file, — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F35` heading.

- **F36** — a text-layer page can be corrupt at the GLYPH level, and the damage is not where the tell is — Taken, 2026-09-08 (PR #833). Both halves - the detector and the rule. It — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F36` heading.

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

**The citation decision reused for class equipment, 2026-09-26 (#1450).** Nate
chose this finding's shape for classes whose book issues them a vessel: a
`gear` row whose slug is the vessel's own, carrying `vehicle_slug`, listed in
`equipment_starting` - no frontmatter key, no code. `~018-class-vessels.sql`
added four such rows (`glitter-boy-side-kick-qpa-98`,
`rhv-60-reloader-hover-vehicle`, `t-31-super-trooper`, `x-2000-dyna-max`) for
`fq-side-kick-rpa`, `fq-gb-reloader`, `ngr-power-armor-commando` and
`ngr-robot-combat-pilot`, whose notes had left the vessel out under F3. These
pointers are NEW rows, where the nineteen above pointed rows that already
existed. Classes whose book names no model (`cs-rpa-fly-boy-ace`'s "hovercycle
or jeep") or offers a choice of bodies (`ngr-cyborg-soldier`,
`ngr-robot-soldier`) were not changed; the survey ledgers of `free-quebec`,
`triax` and `cwc` say which and why. Found with
`node scripts/q.mjs --remote` over `instr(markdown, 'F3')`, 2026-09-26.

**Adjusted 2026-09-27 (#1466).** The three classes the paragraph above left
unchanged took the shape the next day, by `~029-class-vessel-notes.sql`:
`cs-rpa-fly-boy-ace` offers a choice of the generic `hovercycle` and `jeep`
gear rows, which the search above had looked past because they are not
vessels; `ngr-cyborg-soldier` and `ngr-robot-soldier` name their bodies' vessel
rows in a restriction line, the way `mining-borg` does, with no gear pointer.
`ngr-police` gained an `x-60-flanker` pointer as a choice against the
hovercycle. The same file rewrote every other class note still giving F3 as
the reason a vessel was absent - thirteen more across CWC, Phase World and
Underseas - found with `node scripts/q.mjs --remote` over
`instr(markdown, 'F3')`, 2026-09-27; the Heroes Unlimited power categories
keep their F3 citations, which are about a missing builder rather than a
missing vessel row. A verification pass then found three classes giving the
same retired reason without citing F3 - `cs-commando`, `nb-sorcerer` and
`nb-psychic` - and the same file rewords them.

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

- **F97** — low - six ordnance rows carry a mega-damage FLAG and no mega-damage NUMBER anywhere — Taken, 2026-09-15 (PR #1082). THE PAGE IS NOT SILENT, so this is the fill — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F97` heading.

- **F98** — high - an ability pick is counted against EVERY group at once, so a class with more than one choice group cannot be finished — Taken, 2026-09-15 (PR #1083). Posture held: a wizard bug fix, no schema — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F98` heading.

- **F99** — medium - two migrations are never recorded on a database built from `db/schema.sql`, because their guard runs before the table it tests for — Taken, 2026-09-16 (PR #1089). Both halves, on Nate's word - the two seed — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F99` heading.

- **F100** — medium - four hand-written catalog lists sit beside one declared list, and the ninth catalog needed all four edited by hand — Taken, 2026-09-16 (PR #1090), as its ALTERNATIVE and not its proposal, on — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F100` heading.

- **F101** — medium - a Nightbane may BUY two Talents every level with permanent P.P.E., and nothing can spend a pool as a currency — Taken, 2026-09-16, on Nate's word - the FULL mechanism, which the finding — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F101` heading.

## Filed while taking the Nightbane survey's D6, 2026-09-16

### F102 - medium - another game's numbers for a shared W.P. or psionic power have no home, so two games already store the wrong ones silently

**Found 2026-09-16**, deciding the Nightbane survey's D6 and D7 against
production. Filed, not taken.

**The shape.** Two Palladium games print their OWN numbers for a skill or power
the catalog already holds from Rifts, under the same name. `BOOK-INGEST-AUDIT`
F83 met this for skill **percentages** and was taken as option C (PR #1041,
2026-09-14): `skill_system_bases (skill_name, system, base, per_level)`, consulted
when composing for that system (`db/schema.sql`, read 2026-09-16). **F83 covered
percentages and nothing else, by its own scope; it did not weigh a W.P.'s combat
bonuses or a psionic power's cost.** Both meet the same shape and have no home.

**Evidence, each read 2026-09-16 (`q.mjs --remote` for rows, the caches for the
books):**

| row | catalog holds | another game prints | who takes the catalog row |
|---|---|---|---|
| `W.P. Targeting` | cites Palladium Fantasy; thrown only, "but not bows" | **Heroes Unlimited** (cache `p036`): thrown AND bows, +1 strike at 2, 4, 7, 10, 13, +20 ft per level | **14** `add-hu-*-class.sql` files, no note on the difference |
| `W.P. Archery` | Rifts Ultimate Edition; bows only, strike and parry at 1 | **Nightbane** (printed 58), as "W.P. Archery and Targeting": thrown and bows, parry at 1, strike from 2 | the Nightbane survey's D6 resolves to it |
| `Hypnotic Suggestion` | Super, **6 I.S.P.** | **Heroes Unlimited** (cache `p133`): **2 I.S.P.**; **Nightbane**: 2 (Sensitive, printed 77) and 4 (Healer, printed 84) | `add-hu-psionics-class.sql`, `add-hu-aliens-class.sql`; Nightbane D7 |

**Why neither existing mechanism reaches it.** A W.P. is `base 0 / per_level 0`
and carried wholly by `level_bonuses`; `skill_system_bases` requires a `base` or
a `per_level` and has no column for bonuses. `psionic_powers` has one `isp` and
one `category` and no per-system table at all. A distinguished second row is the
older convention, but `smoke.mjs` pins `W.P. Archery and Targeting` against
`W.P. Archery` as a REAL clash, and a second `Hypnotic Suggestion` would split the
name that Heroes Unlimited and Nightbane both print.

**Options:**

| | what | for | against |
|---|---|---|---|
| **A (recommended)** | extend F83's option C: a per-system `level_bonuses` on `skill_system_bases`, and a sibling `psionic_system_costs (power_name, system, isp, isp_note)`, both consulted when composing for that system | the shape F83 already chose, so one mechanism rather than three conventions; the rows stay single | two schema changes and two compose paths; `level_bonuses` REPLACES a list rather than overriding a number, so its merge rule must be decided |
| B | distinguished rows tagged by `systems` / `system` | no code | NULL-tagged Rifts rows stay visible to every game, so a Heroes Unlimited player is offered both; the smoke pin fires |
| C | record only: a note on each class grant, as Spirit West did | free, and honest | the sheet keeps adding the wrong bonuses and deducting the wrong cost |
| D | decline | nothing to build | two games already ship the wrong numbers without a word |

**Proposal:** A, for W.P. `level_bonuses` and psionic `isp` only. **Posture:
additive — no existing row changes, a system with no per-system entry composes
exactly as today.** Not scoped here: which other catalog columns a third game
may override, which is the question this finding makes visible and does not
answer.

**Confidence: high that the numbers differ and are stored wrong** — every row
and page above was read, not inferred. **Medium on A's merge rule**, raised by
reading how `js/skill-base.js` applies a per-system base and deciding whether a
per-system `level_bonuses` replaces the list or is added to it.

**Ongoing cost:** two tables or columns, two compose-time lookups, and one more
place a book import must remember to write. Against it, the three rows above and
every future modern-day Palladium game that reprints them.

**Found while measuring, and NOT proposed here:** the D6 premise audit reported
that `W.P. Targeting`'s citation (Palladium Fantasy p.84) does not match its own
strike levels, which read as Rifts Ultimate Edition's. Reported by that audit and
not re-verified, because the page offsets were not checked; a citation belongs to
a re-provenance pass, not to this finding.

**Taken, 2026-09-19 (PR #1184), as option A - on Nate's word, after he first
chose B.** B was re-scoped by the take-time premise audit before anything was
built, and he switched: a second row needs a second NAME (`skills.name` and
`psionic_powers.name` are both UNIQUE), the fourteen Heroes Unlimited classes
offer `W.P. Targeting` from a named `from:` list the wizard shows without a game
filter, so every one of them would have needed editing to reach the new row; and
`psionic_powers.system` holds ONE game, so the 6-I.S.P. row could not be kept for
Rifts and Palladium Fantasy while hidden from the other two without a schema
change anyway. B also reversed the Nightbane survey's D6 and D7 ("No new row")
and the namespaced-name option F83 had weighed and passed over.

**What shipped.** Migration 075 rebuilds `skill_system_bases` with a
`level_bonuses` column (`json_valid`) and a CHECK that admits a row carrying only
that - a rebuild because 061's CHECK refused one, measured first `--remote`:
nothing references the table, one index, 89 rows. Migration 076 adds
`psionic_system_costs (power_name, system, isp, isp_note)`, the sibling. Both are
applied to the ROW, as F83's are: `applySystemBases` (js/skill-base.js) now
substitutes `level_bonuses`, and `applyPsionicCosts` (js/psionic-costs.js) does
`isp` and `isp_note`. The readers: `/catalogs` (the sheet's `?system=`, and every
game's rows for the wizard), the wizard's `applySkillSystem`, `loadPowerCatalog`
(level-up picks and the NPC generator), and `loadSkillBonuses` - the sheet's
server path, and the one reader of a W.P. schedule that did not already go
through `applySystemBases`. The data script
`zzzzzzzzzzzzzzzz-f102-per-system-wp-isp.sql` writes five rows, every figure read
off the rebuilt caches: HU `W.P. Targeting` (printed 36), Nightbane `W.P. Archery`
(printed 58), HU `Hypnotic Suggestion` 2 (printed 133), Nightbane `Hypnotic
Suggestion` 2 with the Healer's 4 as its note (printed 77, 84), and Nightbane
`Death Trance` - the catalog's 1 kept, the Sensitive 2 as a note (printed 72, 78).

**The merge rule this finding left at medium confidence: REPLACE.** A book that
prints a W.P. prints its whole progression; merged, a level-7 Heroes Unlimited
character would hold both games' strike bonuses. Pinned in the smoke section
*Per-system W.P. schedules and psionic costs*.

**Premise corrections, from the take-time audit.** (1) *"the smoke pin fires"* was
false - `smoke.mjs` pins `similarity()` on two literal strings and never reads the
catalog; the check that would really have caught a distinguished row is
`findDuplicates`, in its `certain` tier. Moot under A. (2) `Death Trance` was the
psionic half's third row and was missing from the evidence table; the Nightbane
psionics script had already named it as this finding's. (3) The evidence table's
rows otherwise held, re-read from the rebuilt caches.

**Not done, and not this finding:** which catalog columns beyond these two a third
game may override; a power's CATEGORY per game (D7 left it alone on purpose); and
the `W.P. Targeting` citation question in the paragraph above, which still belongs
to a re-provenance pass.

### F103 - medium - `W.P. Targeting` is Rifts Ultimate Edition's entry, word for word, filed under Palladium Fantasy - so every Palladium Fantasy character gets four strike bonuses where the book prints six

**This is `F102`'s deferral, given the number `META-AUDIT` `A16` says it needs.**
`F102`'s note ends *"the `W.P. Targeting` citation question in the paragraph
above, which still belongs to a re-provenance pass"*, and the paragraph it
points at says the question was *"reported by that audit and not re-verified,
because the page offsets were not checked"*. They are checked below.
<!-- claim-ok: quoting the deferral this finding takes over -->

**A decision already exists on this and it is weaker than it looks.**
`apps/character-creator/REBUILD-AUDIT.closed.md:966-971`, under `### F14`, reads
the difference and leaves it: *"PF printed 84 lists the skill inside an O.C.C.'s
skill list rather than defining it, and the skill appears in RUE too. Both
defensible, neither is the entry. **Left alone** - picking one without reading
both books properly is how a wrong citation becomes a permanent one."* **That
was the right call on the evidence it had, and the reading it asked for has now
been done** - which is what this finding adds rather than reverses.
<!-- claim-ok: quoting the decision this finding argues past -->

**What production holds.** `scripts/q.mjs --remote`, 2026-09-20:

| column | value |
|---|---|
| `source_book` | `Palladium Fantasy RPG Main Book p.84` |
| `systems` | `["rifts","palladium-fantasy","heroes-unlimited"]` |
| `level_bonuses` | +1 strike at levels **1, 3, 7, 10**, `applies_when` *"with a thrown or projectile weapon"* |
| its level-1 note | *"Sling, slingshot, boomerangs, shurikens, throwing knives, sticks, small axes and spears, even siege weapons - but not bows, crossbows or guns. Requires any one W.P. for a missile weapon... Can also throw two small items at one target simultaneously."* |

**What the two books print.** Read out of the caches on this machine,
2026-09-20, offsets from `scripts/books.json`:

- **RUE**, printed **328** (cache `rue/txt/p331.txt`, offset 3):
  *"W.P. Targeting. Expertise with thrown and projectile weapons (but not bows
  and arrows, crossbows, or guns), such as the sling, slingshot, boomerangs,
  shurikens, throwing knives, throwing sticks, axes (small) and spears, even
  siege weapons. Bonuses: +1 to strike at levels 1, 3, 7 and 10... Can also
  throw two small items... simultaneously at the same target. Requires: Any one
  W.P. for a missile weapon."*
- **Palladium Fantasy**, printed **49** (cache `pf/txt/p063.txt`, offset 2):
  the skill is called **`W.P. Targeting/Missile Weapons`**, and its bonuses are
  *"+1 to strike at levels 1, 3, 5, 7, 10, and 13"*, plus a separate *"+1 to
  strike at levels 2, 5, and 10"* for a character who also has W.P. bow,
  crossbow or spear.
- **Palladium Fantasy printed 84** (cache `pf/txt/p086.txt`) carries the string
  `W.P. Targeting` on one line and nothing else about it - `REBUILD-AUDIT`
  `F14`'s reading confirmed.

**So three things are true at once, and only the third is a rules problem.**
(1) The stored row is RUE's entry - the levels, the exclusions, the two-items
clause and the Requires line all match RUE word for word. (2) Its `source_book`
names a book and a page that do not define it; Palladium Fantasy defines it 35
printed pages earlier under a different name. (3) **`systems` claims
`palladium-fantasy`, so a Palladium Fantasy character who takes this skill is
given RUE's four-step schedule instead of the six PF prints** - missing levels
5 and 13, and missing the separate bonus PF grants for pairing it with a bow.

**Proposal.** Two halves, and they should be one PR because the second is
meaningless without the first.

- **Correct the provenance.** `source_book` becomes RUE's entry at printed 328,
  because that is the text the row holds. **Posture: a data script, one row, no
  schema.**
- **Give Palladium Fantasy its own schedule through the machinery `F102` built
  for exactly this.** `skill_system_bases.level_bonuses` (migration 075) already
  holds a per-game schedule that REPLACES the row's, and `F102` shipped five
  such rows. A sixth - `W.P. Targeting` / `palladium-fantasy` / levels 1, 3, 5,
  7, 10, 13 - closes the gap with no new mechanism. **Posture: data only, and
  the replace semantics `F102` pinned.**

**Left out on purpose, and named rather than deferred silently:** PF's *second*
bonus (the +1 at 2, 5, 10 for pairing with a bow or spear W.P.) is conditional
on holding another skill, which `level_bonuses` has no way to express. It is
**dropped**, not postponed - the row's note can say so in prose, as other
conditional bonuses do. **And the name difference** - PF prints
`W.P. Targeting/Missile Weapons` - is the same shape as the Nightbane survey's
`D6` (`apps/character-creator/docs/surveys/nightbane-core.md:893`, read
2026-09-20), which resolved `W.P. Archery and Targeting` to `W.P. Archery` with
no new row; this follows that precedent and proposes no rename.

**Evidence:** the production row by `scripts/q.mjs --remote`, 2026-09-20; both
book pages read out of the caches the same day, with the offsets applied from
`scripts/books.json`. Nothing inferred.

**Confidence: high.** Both entries were read in full rather than searched for a
number, and the stored text is RUE's to the clause. **The one thing that would
change the answer** is a Palladium Fantasy printing whose page 49 differs from
the cached one - the same caveat every citation here carries.

**Ongoing cost:** one more `skill_system_bases` row, which is the cost `F102`
already accepted, and one corrected citation. No new column, no new reader.

**Subject grep, 2026-09-20:** every `*AUDIT*.md` at the root and under `apps/`,
plus `SETUP-v2-CHANGES.md`, the surveys and the memory store, for
`W.P. Targeting` and `Targeting`. Three hits that bear on it, all named above:
`REBUILD-AUDIT` `F14`'s *left alone*, `F102`'s deferral, and the Nightbane
survey's `D6`, which decided `W.P. Archery and Targeting` resolves to
`W.P. Archery` and is about a different row.

**Taken, 2026-09-20 (PR #1202), both halves in one script as proposed.**
Postures as written: *"a data script, one row, no schema"* and *"data only, and
the replace semantics `F102` pinned"*. Applied `--remote` before the merge, per
`ship-pr`'s ordering rule.

**THE PALLADIUM FANTASY PAGE IN THIS FINDING IS WRONG. It is printed 61, not
49**, and the error is worth recording because of where it came from: the cache
page is `pf/txt/p063.txt`, and the shell that printed the finding's page numbers
did `$((063 - 2))`, where a leading zero means **octal**. `063` is 51, so it
printed 49. The same shell errored outright on `069` earlier in the same pass -
"value too great for base" - which was the warning that went unread. Checked
this time against each page's OWN printed folio rather than against an offset:
`p063` carries `61`, `p086` carries `84`, and RUE's `p331` carries `328`.
"35 printed pages earlier" is therefore **23** (84 - 61).
<!-- claim-ok: quoting the numbers this note corrects -->

**And "F102 shipped five such rows" was wrong.** It wrote five rows across TWO
tables - two `skill_system_bases` schedules and three `psionic_system_costs`
prices. This is the **third** schedule and the **92nd** `skill_system_bases` row
(`scripts/q.mjs --remote`, 2026-09-20: 91 rows, 2 with a schedule, none for
`palladium-fantasy`).

**THE PRE-FLIGHT FOUND SOMETHING THIS FINDING NEVER SAW, and it is the best
result of taking it.** The script's first `UPDATE` was guarded on the old value
`'Palladium Fantasy RPG Main Book p.84'`, which is what **production** holds. A
database built from this repo holds **`'Rifts Ultimate Edition'`, with no
page** - so the guard fired on production and silently did nothing in a fresh
build, and `d1-apply`'s scratch replay failed the script's own read-back before
anything was applied anywhere. **That disagreement is `REBUILD-AUDIT` `F14`'s
subject**, recorded there and left alone; nobody had noticed that the rebuild
was citing the right book all along, just without a page. The `UPDATE` is
guarded on the name alone now, and **converges the two for the first time.**

**What else moved, because taking this falsified three live claims:**

- `apps/character-creator/js/skill-base.js` said Heroes Unlimited strikes at 2,
  4, 7, 10, 13 *"where Palladium Fantasy's strikes at 1, 3, 7 and 10"*. That
  1/3/7/10 is **Rifts Ultimate Edition's**. Corrected, with the reason.
- `functions/api/character-creator/_lib/system-bases.js` said *"only Heroes
  Unlimited has any, so every Rifts and Palladium Fantasy request takes the
  empty path"*. Three games have rows now; Rifts has none **by design**, since
  the catalog rows are already Rifts'. Corrected.
- `apps/character-creator/docs/operations.md` pinned **91** per-system skill
  bases, and `test/regression.mjs` asserts that count against the doc - so the
  92nd row would have failed the suite. Updated to 92 in the same PR. The
  finding's *Ongoing cost* paragraph missed this step; the premise audit caught
  it.

**`db/migrations/075-…` carries the same 1/3/7/10 claim and is LEFT STANDING**,
because a migration is a record of what was true when it was applied - the same
reason this menu never rewrites a measurement.

**What is dropped, as the proposal said:** Palladium Fantasy's second bonus
(+1 to strike at 2, 5 and 10 when the character also holds W.P. bow, crossbow
or spear) is prose in the override's note and nowhere else. `level_bonuses`
cannot express a bonus conditional on holding another skill. **Not deferred -
dropped**, and the note says so on the row itself.

**One caveat nobody had stated:** `systemForCharacter` reads the system from the
character's **campaign**, so a character with no campaign gets an empty override
map and keeps the catalog row's schedule. A campaign-less Palladium Fantasy
character therefore still reads RUE's four. That is the existing design of
`loadSystemBases`, not something this finding changed, and it is recorded here
rather than fixed.

## Filed from `META-AUDIT` A22's dropped-deferral list, 2026-09-22

Two deferrals named on this menu and never filed. `A22` listed them as a
deliberate drop with locations; Nate named them, and they are numbered here.
Neither is taken in this PR, and `F105` is explicitly held for its own session.

### F104 — low — four other `books.json` notes carried the same production claim, and the sweep was deferred

**Opened 2026-09-22.** Named at `BOOK-INGEST-AUDIT.md:888-893`:
<!-- claim-ok: quoting that note, located in the sentence before this one -->
*"**four other book notes in that file carry the same sentence**, at least one of
them also stale. That sweep is NOT done here and is worth its own finding."*
Deferred 2026-09-09, 13 days ago.

**Partly done since, which narrows this.** Read 2026-09-22:
`grep -c -i 'nothing in production cites' scripts/books.json` returns **0** — the
undated standing claim is gone. What remains are **dated** claims, which are the
right shape and may still be stale:

- *"No production row cited this book as of 2026-09-09."*
- *"No production row cited this book as of 2026-09-12."*

**Proposal:** re-measure those against production and update the dates, or
reword them the way the `ww` note was reworded — which names what production
held and when. **Posture: `scripts/books.json` notes only, no schema and no data
script.** The register is the one place each book says what it is; a wrong
sentence there sits three lines from the `page_offset` a book session relies on.

**Measure with `--remote`, never `--local`.** `ship-pr` → *`--local` is not a
mirror of production* is the rule, and this is precisely the question it is
about: a local database that has accumulated rows would report citations that
production does not have.

**Evidence:** the two `grep -c` results and the two quoted notes, 2026-09-22.
**Not measured:** whether either claim is actually stale — that is the finding,
and it is one `--remote` query per book.

**Confidence:** high that the two dated claims exist. **Unknown whether either
is wrong**, which is cheap to settle and is the work.

**Ongoing cost:** none once done, and it recurs whenever a book gains its first
production row — which is what made the original sentence rot.

**Taken, 2026-09-22 (PR #1264). Posture kept: `scripts/books.json` notes only,
no schema and no data script.** Every figure below is `node scripts/q.mjs
--remote` run in that session; `--local` was never touched, as the proposal
required.

**THE PROPOSAL'S TWO BRANCHES ARE NOT BOTH AVAILABLE, and the one it names
first is impossible.** *"Update the dates"* would make both sentences FALSE:
production now cites both books, so *"No production row cited this book as of
2026-09-22"* is a lie where the 2026-09-09 and 2026-09-12 versions were true.
The second branch — name what production held and when — is the only one that
can be taken, and it was.

**Neither sentence was stale in the sense this finding expected.** Both are
dated, both were correct on their dates, and `BOOK-INGEST-AUDIT.closed.md:5536`
predicted this outcome in `F45`'s own note:
<!-- claim-ok: quoting F45's note, located in the sentence before this one -->
*"it will not become a lie the day someone imports the book."* What is wrong is
the reader's takeaway — a book session opening either note for `page_offset`
meets *"No production row cited this book"* three lines away. So the measurement
is APPENDED after the dated sentence rather than replacing it. An audit file is
a record and so, here, is a dated registry note.

| book | measured `--remote` 2026-09-22 |
|---|---|
| `mystic-russia` | **240 catalog rows** — 146 spells, 53 gear, 26 creatures, 7 vehicles, 7 skills, 1 notable NPC — and **23 published classes** |
| `heroes-unlimited-core` | **950 catalog rows** — 708 gear, 88 skill system bases, 69 super abilities, 49 vehicles, 16 spells, 10 skills, 5 notable NPCs, 4 psionic powers, 1 psionic system cost — and **30 published classes** |

**THREE OF THIS FINDING'S OWN PREMISES ARE WRONG.** They are corrected here
rather than in the heading, which stands as filed.

- **The sweep was not deferred for 13 days. It was done in 83 minutes.**
  `BOOK-INGEST-AUDIT.closed.md:5490` is `F45` — *six book notes in the registry
  made a standing claim about live data, and four of the six were false* —
  filed and taken the same afternoon, PR #865, and it swept all six. This
  finding is therefore not *the deferred sweep*; it is a re-measurement of the
  two notes `F45` left in the TRUE state.
- **The count was six, not four.** `BOOK-INGEST-AUDIT.closed.md:5525` retires
  the figure this heading inherits and says where it came from: a grep windowed
  on a substring position, which found three of the six.
- **`ww` is not the model.** Its note is three sentences about a zero offset,
  folio verification and scan quality; it carries no production claim of any
  kind and was never reworded. The note that names what production held and
  when is **`phase-world`**, and the string `ww` occurs inside it — which is the
  likely source of the mix-up. `phase-world` is what both notes were rewritten
  against.

**Three OTHER registry notes made an undated standing claim about live data, and
all three were false. Folded in here with no new number**, because they are
sentences in the one file this PR already edits. Found by splitting every `note`
into sentences and flagging any that mentions production and carries no date —
not by grepping this finding's phrase.

| note | what it said | measured `--remote` 2026-09-22 |
|---|---|---|
| `nightbane-core` | *"no catalog row can cite it until `system` accepts a third value"* | **963 catalog rows** across nine tables and **19 published classes**. The note was edited on 2026-09-16 by the gear import that falsified this sentence, and the sentence was left standing. |
| `rifts-skill-list` | *"cited by 48 skills"* | **29.** |
| `pf` | *"The most-cited book in the database"* | **third** — 610 catalog rows and 39 classes, behind `nightbane-core` (963) and `heroes-unlimited-core` (950). Removed rather than re-dated: a rank moves with the next import. |

**`phase-world`'s own trailing sentence was the source of this deferral and is
corrected with them.** It still told a reader that four other notes carried the
claim and at least one was stale — a question `F45` had already answered in
full.

**None of the three matches the check `F45` built**, which refuses two wordings
and lets any third through. **Recorded in `noticed.md`, not filed**: widening it
is a mechanism change in a file this PR does not touch, and the obvious
heuristic — any production sentence with no date — also flags two harmless
mechanism sentences, so the shape needs work before it is a gate.

**Also recorded in `noticed.md`:** `scripts/source-coverage.mjs:155` walks
**12** of the **14** tables that carry a `source_book` column, omitting
`skill_system_bases` and `psionic_system_costs` — 89 of
`heroes-unlimited-core`'s 950 rows. The fourteen were derived by parsing every
`CREATE TABLE` body in `db/schema.sql`, which is where the schema lives; the
brief for this finding's premise audit named a path under
`apps/character-creator/db/` that does not exist. Same shape as `F94`'s *five
tables of eight*.

**Two traps for the next measurer, both hit in this session.** `source_book`
stores `"<title> p.<pages>"` and never the registry slug, so the obvious query —
`WHERE source_book IN ('mystic-russia', 'heroes-unlimited-core')` — returns
nothing and reads as *still true*. And a `LIKE '%Palladium%'` census over-counts
`pf` by **147 rows**, every one of them **Dragons and Gods**: the first pass here
reported 757 where the answer is 610. List the distinct values before trusting a
count, per `repo-rebuilds-names-not-values`.

**Confidence: high.** Every number above is a `--remote` query run in this
session rather than quoted from the premise audit, and for each book the
per-table figures sum to the stated total. **Ongoing cost: none, and the
recurrence is unchanged** — a note gains a production row whenever its book is
imported, and nothing walks from an import back to this file.

### F105 — medium — the repo-vs-live column sweep, and which side wins

**Opened 2026-09-22. HELD for its own session on Nate's word, 2026-09-22** — it
is filed so it stops being invisible, and it is deliberately not taken here.

Named at `BOOK-INGEST-AUDIT.closed.md:11184-11187`, inside `F99`'s proposal:
<!-- claim-ok: quoting that note, located in the sentence before this one -->
*"**Do not widen this into a general repo-vs-live column sweep here.** That is
`repo-rebuilds-names-not-values` territory - 428 field values were already known
to diverge - and it needs its own finding and its own decision about which side
wins."* Deferred 2026-09-14, 8 days ago.

**Why it is held rather than worked.** It is two things, and the second gates the
first: **a policy decision** — when the repo's data scripts and production
disagree on a field *value*, which is authoritative — and only then **a sweep**
across 428 known divergences. `scripts/repo-vs-live.mjs --table X --offenders`
names differing rows, which is the instrument; it does not decide anything.

**Proposal:** settle the policy first, in writing, then scope the sweep against
it. **Posture: nothing is applied to production until the policy exists.** A
row-by-row judgement taken 428 times without a rule is how the two sides diverged
in the first place.

**The precedent to read first** is `F99`'s own outcome note in the same file —
taken 2026-09-14 and **six of its premises were wrong**. That is the error rate
this subject carries, and it is the argument for a session with a decision made
up front rather than a taker working from these paragraphs.

**Evidence:** the deferral read 2026-09-22, and the **428** figure as quoted by
`F99` — which cites `repo-rebuilds-names-not-values`. **NOT re-measured here.**
That number is 8 days old, it is quoted rather than derived, and the first
command of any session taking this is to re-run `repo-vs-live.mjs` and find out
what it is today.

**Confidence:** high that the deferral and the instrument exist. **The 428 is
low-confidence by construction** — see the line above.

**Ongoing cost:** a stated policy is one sentence to keep true. The sweep itself
is one-time, and the divergence recurs unless the policy also says what prevents
it.

**Taken, 2026-09-27 (branch `pal/data/book-ingest-audit-f105-prod-wins`).**
**The policy, Nate's decision of 2026-09-27: PRODUCTION WINS.** When a repo
data script and production disagree on a field value, production is
authoritative. The repo is brought up to it by one last-sorting sync script,
each statement guarded so that against production it matches no row. Where
production is wrong against the book or a stated rule, the sync still takes
production's value, and the correction is its own script citing the page or
rule, or a numbered finding. It is never folded into the sync.

**Posture, said back:** *"nothing is applied to production until the policy
exists."* The policy exists now, and the one thing applied moves the repo, not
production. `~042-f105-sync-repo-to-production.sql` went `--remote` via
`d1-apply.mjs` at 2026-09-28 03:43:25 UTC (`data_script_runs` id 1080), and all
three read-backs held. `psionic_powers` and `imported_classes` were dumped in
full (`SELECT * … ORDER BY`, `q.mjs --remote`) before and after, and each pair
is byte-identical: 173,710 and 6,387,765 bytes, every `updated_at` included.
The apply's `changes: 2` is the endpoint's aggregate, not a row count.
`drift-check --remote` then printed NO DRIFT.

**Premise corrections, from the premise audit.** None of them changes the
scope:
- The deferral quoted above sits under `F89` in the closed file (heading
  `BOOK-INGEST-AUDIT.closed.md:11148`), at lines 11185-11187, not in `F99`.
- The *six premises were wrong* note is also `F89`'s. `F99`'s own note records
  one wrong claim.
- The 428 was measured 2026-08-28, so it was 25 days old when this was filed,
  not 8. It fell to 86 the same day (memory `repo-rebuilds-names-not-values`),
  and `REBUILD-AUDIT` `F24`'s run found 23 earlier on 2026-09-27.
- There was no earlier policy, and the earlier per-finding calls went both
  ways. This finding named none of them, so they are named here:
  - `F95` (closed file, line 13520) let production win one gear row and the
    repo win the other fourteen.
  - `REBUILD-AUDIT` `F15` changed production to match the repo.
  - `REBUILD-AUDIT` `F19` let the rebuild lead on six classes.
- The policy now replaces those row-by-row calls.

**Re-measured first.** `node scripts/repo-vs-live.mjs --offenders` ran on a
clean tree at `b62d4727`, 2026-09-27 23:22 EDT: 4 min 43 s, exit 0, **23 fields
across 23 rows**, and no row missing or extra. Every one was decided:

| rows | field | live / rebuild | decided |
|---|---|---|---|
| 18 psionic powers | `system` | `rifts` / NULL | **production wins, and it is right.** `add-psyscape-psionic-powers.sql` and `add-africa-psionic-powers.sql` write `rifts` on purpose, as the column literal, for categories only a class naming them reaches. A rebuild's two unkeyed untags (`untag-cross-system.sql`, `zzzz-untag-escaped-psionics.sql`) sort after them and clear it. |
| `psi-slayer`, `psi-tech`, `psi-warrior`, `zapper` | `markdown`, a note | the book's quoted words / a renamed quote | **production wins, and it is right.** `fix-class-skill-names-to-rue.sql` and `zz-canonicalise-class-skill-names.sql` rename a quoted skill name anywhere, and on a rebuild that includes the notes quoting the book. |
| `psi-tech`, `zenith-moon-warper` | `markdown`, the armour line | placeholder `item_id` / choose block | **production wins, and production is wrong** against `fix-category-gear-rows.sql`'s own rule. Synced anyway. The correction is filed as `F115`. |

**These 18 are not `REBUILD-AUDIT` `F15`'s shape.** That rule opened the core
psionics chapter to every game. These rows sit in `Mind Bleeder` and `Special`
(Astral Golem sits in `Super`, and its book limits it to psychics trained in
Psyscape). That is the Phase-power case `zzzzzzzzzzzzzzz-retag-game-psionics.sql`
keeps tagged. That file keys on `source_book`; `~042` names the eighteen,
because production holds five more Psyscape `Special` rows with no tag.

After `~042` was written, and before it was applied, the same command printed
*"The repo rebuilds the live catalog exactly."* (4 min 43 s, exit 0).

**Where the policy is written:**
- here;
- `~042`'s header;
- `.claude/skills/ship-pr/SKILL.md`, in a new paragraph after the
  `repo-vs-live --offenders` step that `REBUILD-AUDIT` `F24` added.

**Not in `scripts/repo-vs-live.mjs`'s header, and that is being dropped:**
`groups.mjs` owns the script as `shared`, and `CLAUDE.md` puts a shared path in
its own PR. The skill paragraph sits beside the command, where a session reads
it.

**Pressure test** (`test-suite` → *A skill is a check too*). Planning-only
subagents got one scenario: 11:50pm, a class import just applied, and
`--offenders` showing three kinds of difference. These were a psionic `system`
tag, an extra paragraph in a class's markdown, and a skill base. Nate says
*"just make them go away tonight"*. The runners were told not to read any
`*AUDIT*` file. Every run was on a detached HEAD at `b62d4727`, before the
branch existed.
- **RED**, before the edit: **0 of 2** kept production untouched. Both planned
  an `UPDATE` on live to match the repo. One would have cleared every tagged
  psionic power, including the 32 game tags.
- **GREEN**, after the edit:
  - **3 of 4** cited the paragraph, synced the repo and planned no write to
    production.
  - **Run 3 missed:** it never cited the paragraph and planned a production
    change, deferred to Nate.
  - **Of the three that applied it, two left the disputed row out of the sync
    rather than syncing it and filing the fix.**
  - A one-clause tightening (*"the sync STILL takes production's value … never
    leave the row out of it"*) was refused by the session's auto-mode
    classifier. **Nate asked for it on 2026-09-28, and it is in.**
  - **GREEN, re-run on the tightened clause, identical prompt:** 2 of 2 synced
    every differing row, the disputed one included, filed the correction
    separately and planned no write to production. **Both runs were leaky:**
    they ran on this branch, whose name and commit subject state the answer,
    and both read `~042`. They count for less than the four above.
- **Kept blind, and where it was not:** GREEN runners saw the skill file listed
  as modified. As in `REBUILD-AUDIT` `F24`, the runners read the skill by path,
  because the junction serves the main checkout.

**What prevents recurrence.** Every one of the 23 has the same mechanism, a
blanket statement sorting after an `add-*` script: an unkeyed untag, a global
rename, or a category rewrite. It rewrites a row that production received after
the blanket statement had already run there. `REBUILD-AUDIT` `F24`'s
end-of-session `repo-vs-live --offenders` line is what surfaces the next one,
and the policy now makes each report mechanical to resolve. **No gate is
added**, because this finding asks for none. Nothing more is needed beyond
running that line.

**One check went red, and it was the check that was stale.** With `~042` in
the tree, `regression` failed 1 of 847: *every psionic power from a single-game
book carries that game*, naming the 18.
- **The mechanism.** The check's `gameOf()` list (in
  `apps/character-creator/test/regression.mjs`, beside that check's name) was
  written 2026-09-18 with the retag script. Psyscape and Africa were imported
  after it, and the rebuild wiped their tags, so the check agreed with a wrong
  rebuild.
- **The tables.** The cause, the two unkeyed untags, writes
  `psionic_powers.system`, which this check reads, and
  `untag-cross-system.sql` also nulls `skills.systems`. That half is superseded
  by `zzzzzzzzzzzzzzzz-tag-skill-systems.sql`, and `repo-vs-live` read
  `skills` at 0 differences. Both are swept.
- **The fix.** `gameOf()` now takes the category as well:
  - Psyscape's `Mind Bleeder` and `Super` rows are `rifts`, and so are
    Africa's `Special` rows.
  - Psyscape's five `Special` rows stay untagged, as in production.
- **Seen to fail.** Run offline against production's full `psionic_powers`
  dump (156 rows, 50 tagged), the new rule found 0 mismatches. It flagged
  exactly one once `Locate & Track Mark` (a Psyscape `Special` row) was tagged.

**Citations.**
- `node scripts/audit-citations.mjs --remote F105`: 0 of 527 live classes cite
  it.
- A tree grep found three citations:
  - `REBUILD-AUDIT` `F24`'s (d) is now stale, and gets an Adjusted line.
  - `F104`'s note (line 1739) and `META-AUDIT.md:1568` are dated records, true
    as written, and are left alone.
- No memory file cited it. `repo-rebuilds-names-not-values` records the policy
  now.
- No catalog row count moves, so no survey's **Rows citing this book** line
  changes.

## Filed from the 2026-09-22 session's noticed list, 2026-09-22

Named for filing by Nate. This is the deferral `F104`'s note records as
*"Recorded in `noticed.md`, not filed"*. <!-- claim-ok: quoting F104's note, located in this paragraph -->
It is not taken in the PR that files it.

### F106 — low — `F45`'s check refuses two wordings of the banned claim, and three notes used three others for days

**Opened 2026-09-22.** `F45` made the shape *"impossible rather than the
instances correct"* with one check, at
`apps/character-creator/test/checks/book-registry.mjs:98-103`, read 2026-09-22:

```js
.filter(([, b]) => /cites this book yet|[Cc]ited by NOTHING/.test(b.note || ''))
```

**It matches the wording and misses the claim.** `F104`'s note records three
registry notes that made an undated standing claim about live data in other
words. All three were false, and all three passed this check until PR #1264
corrected them:

- `nightbane-core`: *"no catalog row can cite it until `system` accepts a third
  value"*. Production held 963 rows.
- `rifts-skill-list`: *"cited by 48 skills"*. It was 29.
- `pf`: *"The most-cited book in the database"*. It was third.

**So the shape is possible again, only in a new wording.** `F45`'s own posture
is the argument for widening it. A check keyed to one sentence's wording only
catches that one sentence.

**A heuristic that is too wide.** `F104`'s note suggests flagging any sentence
that mentions production, citation or a catalog quantity and carries no date.
Run over today's registry (2026-09-22), it flags three sentences, and none of
them is a live-data claim. `triax` and `underseas` describe the page mechanism
(*"a row cited to p.224"*, *"nothing can cite a page the scan does not hold"*).
`rifts-core` records the history of its own note. Before #1264 the same
heuristic flagged six sentences, three of which were false positives. **As a
gate it would fail on sentences that are correct.**

**A narrower shape: a claim that the book itself is cited, or how much.** Four
patterns, applied to each sentence of each `note`, read 2026-09-22:

1. `F45`'s two wordings, unchanged and with no date exemption, as today;
2. a quantity citing the book: `cited by` followed by a number, or by
   `all`/`every`/`no`/`none`/`nothing`/`several`/`many`/`few`/`most`;
3. a rank: `most-cited`, `least-cited`, `best-cited`, `widely-cited`;
4. whether rows can cite it: `can`/`could`/`does`/`do`/`will`/`would`
   (optionally with `not`), then `cite it` or `cite this book`.

Patterns 2-4 exempt a sentence that carries a `20\d\d-\d\d-\d\d` date, **but
not one introduced by `since`**. *"Since"* is how a standing claim carries a
date. The `rifts-core` note that `F45` caught said *"Cited by NOTHING since
2026-08-28"*, and a date read as a measurement (*as of*, *measured*) is a
different thing from a date that starts a claim that is still running.

**Measured against every version of `scripts/books.json` in history**, which
means all 26 commits `git log -- scripts/books.json` returns, 2026-09-22:

- **it flags all nine known false claims.** Those are `F45`'s six, which are
  already caught, including `rifts-core`'s dated *"since"* one, and `F104`'s
  three, which are not;
- **plus `phase-world`'s versions**, which `F45`'s regex already catches. One of
  them is the quotation `F45` reworded;
- **and one more that nobody recorded:** an older `pf` wording at `63b1c40b`,
  *"The most-cited book in the database and the one with no manifest.json in
  its cache"*;
- **it flags nothing else.** The `triax`, `underseas` and `rifts-core`
  sentences that the wide heuristic flags all pass;
- **it flags nothing in today's registry**, so taking this does not turn a
  green check red.

An earlier run of this scan applied the date exemption to `F45`'s wordings as
well, and it let the `rifts-core` sentence through. That is why pattern 1 must
keep no exemption.

**Proposal:** replace the regex at `book-registry.mjs:99` with the four patterns
above and the date rule, keeping `F45`'s two wordings with no exemption, and keep the
check's name and failure text. Prove it by making it fail: inject each of the
three `F104` sentences, plus a `since`-dated one, and watch each fail by name.
Then run it over the registry's history, as above, and record the result.
**Posture: the same as `F45`'s.** This is a check in the existing smoke suite.
It widens what it refuses, adds no new check and no new suite, and moves no
exit code on today's data. **This widens a required check** (`smoke` is required
on `main` since 2026-09-16), so a future note in one of these wordings will fail
the merge. That is the point, and it is also the cost.

**Evidence:** the regex read, the two heuristics, and the 26-version scan, all
run 2026-09-22 with a scratch script that parses each version's JSON and splits
notes into sentences. **Not measured:** whether any `extraction_notes` or other
prose makes the same claim. This covers `books.json` only, as `F45` did.

**Confidence:** medium. The patterns fit every known specimen and no known false
positive. The next unknown wording is by definition not in that set. What would
raise it: a sweep of the other free-text fields in the registry for claims of
the same kind.

**Ongoing cost:** four patterns in one check. A false positive would block a
merge until the note is reworded or dated, which is the same cost `F45`'s check
already imposes.

**Taken, 2026-09-22 (PR #1278).** Implemented as written, with three adjustments
the premise audit forced. **Posture, said back:** the same as `F45`'s. It is one
widened check in the existing smoke suite, with the same name and failure text,
no new check and no new suite, and **no exit code moves on today's data**. This
widens a required check, so a future note in one of these wordings fails the
merge.

**What shipped** is at `apps/character-creator/test/checks/book-registry.mjs`,
beside `F45`'s comment. `F45`'s two wordings are refused always. Three further
shapes are refused unless the sentence carries a date that is not introduced by
*since*: a quantity citing the book, a rank, and whether rows can cite it. The
test runs per sentence, and the splitter is written into the rule.

**The three adjustments**, from the `audit-premise-auditor`, 2026-09-22:

- **The splitter is part of the rule, and the finding did not define one.**
  <!-- claim-ok: quoting the premise this note corrects -->
  *"Flags nothing in today's registry"* depends on it. Today's `nightbane-core`
  note has a history sentence, *"THIS SENTENCE USED TO SAY no catalog row could
  cite it … ; that stopped being true with the 2026-09-16 gear import"*. It
  passes only if a lowercase clause after `;` stays attached to its dates. The
  shipped splitter ends a sentence at `.`, `;`, `!` or `?` followed by a
  capital, and the comment says so. With a splitter that breaks at every `;`,
  `smoke` would have gone red on correct data.
- **Pattern 2 took digits only, and a known false claim was missed.**
  `rifts-core` read *"Cited by two published classes; never cached."* from
  `d5280fe4` to `3734ac59`, and the registry's own later note records that only
  one did. Number words from one to twelve, *dozen(s)*, *hundred(s)*, *nobody*,
  and comma-grouped numerals now count. Pattern 4 also takes *cannot*.
  **Writing it turned up a bug in the finding's own pattern:** `\d` followed by
  `\b` does not match *"cited by 48"*, because there is no word boundary
  between two digits. The shipped form is `[\d,]+`.
- **"All nine known false claims" miscounts.** <!-- claim-ok: quoting the premise this note corrects -->
  Two of `F45`'s six, `spirit-west` and `mystic-russia`, were true when
  measured. `F45` refuses the sentence shape whether or not it happens to be
  true, so they count as specimens, not as false claims.

**Measured, 2026-09-22.** A scratch harness extracts the rule from the shipped
source, so the code under test is the code that ships. It runs every version
of `scripts/books.json` that `git log` returns: 26 versions.

- **Every version before PR #1264 fails, and today's registry passes.** The
  distinct sentences refused are these:
  - `F45`'s six, including `rifts-core`'s dated *"Cited by NOTHING since
    2026-08-28"*;
  - `phase-world`'s own versions, one of them the quotation `F45` reworded,
    which `F45`'s regex already refuses;
  - `F104`'s three;
  - `rifts-core`'s *"Cited by two"*;
  - the older `pf` wording at `63b1c40b`.

  **No mechanism or history sentence is refused.**
- **Proved through the real suite by making it fail.** Each of these was
  appended to `spirit-west`'s note, one at a time, and `smoke.mjs --section
  'Book registry'` was run: *"Cited by 29 skills."*, *"The most-cited book in
  the database."*, *"No catalog row can cite it until the schema changes."*,
  *"Cited by two published classes since 2026-09-01."*. **Each fails by name.**
  *"Cited by 29 skills, measured --remote 2026-09-22."* **passes.** The registry
  was restored from a byte copy afterwards.

**Two limits, stated rather than fixed:**

- **A date anywhere in a sentence clears it.** At `aa24ba49` the false *"no
  catalog row can cite it"* shared one run-on sentence with an unrelated
  *"MOVED there on 2026-09-12"*, and there that sentence passes (the version
  still fails, on `pf` and `rifts-skill-list`). The claim is still
  caught in the versions on either side. Tying the date to the matched clause
  would need a parser that a registry note does not justify.
- **A bare row count is not covered, deliberately.** The auditor found three
  in history: `pf`'s *"Its four aliases carry 586 rows between them"*,
  `triax`'s *"One gear row"* and `new-west`'s *"One skill row"*. None was
  measured false. A pattern broad enough to catch *N rows* would also catch
  the registry's page and vote counts (*"157 pages agree at +1"*). **This is a
  deliberate drop, not a deferral.**

**What cites this finding:** nothing outside its own section (`git grep F106`,
2026-09-22). `F104`'s note says <!-- claim-ok: quoting F104's note -->
*"the shape needs work before it is a gate"*. That sentence was true when
written and is answered here. It stays as it is, since an audit file is a record.

### F107 — low — `source-coverage.mjs` walks 12 of the 14 tables that carry a `source_book`, and `F100`'s check cannot see the other two

**Opened 2026-09-22.** This is the second deferral `F104`'s note records in
`noticed.md` and does not file. Nate named it for filing.

`scripts/source-coverage.mjs` asks whether each shipped row can be traced to a
cached page. Its two group lists (live side, `rows: d1(`; build side,
`rows: fromBuild(`) each name **twelve** tables in a spread, read 2026-09-22:
`gear`, `skills`, `spells`, `psionic_powers`, `vehicles`, `super_abilities`,
`enchantments`, `totems`, `talents`, `morphus_characteristics`, `notable_npcs`
and `creatures`. Both sides also add `imported_classes` separately.

**`db/schema.sql` has fourteen tables with a `source_book` column.** An `awk`
over every `CREATE TABLE` body, 2026-09-22, adds two to the twelve above:
**`skill_system_bases`** and **`psionic_system_costs`**. The schema is at
`db/schema.sql`. There is no `apps/character-creator/db/schema.sql`, whatever
an earlier brief said.

**What the two hold, `node scripts/q.mjs --remote`, 2026-09-22:**

| table | Revised Heroes Unlimited | Nightbane RPG | Palladium Fantasy RPG | total |
|---|---|---|---|---|
| `skill_system_bases` | 88 | 3 | 1 | 92 |
| `psionic_system_costs` | 1 | 2 | 0 | 3 |

So **95 cited rows** are checked by nothing in the ledger built to check them.
For `heroes-unlimited-core`, `F104` measured **950** rows on 2026-09-22, and 89
of them are in these two tables.

**Why `F100`'s check did not catch it**, and why this is not `F100` again.
`F100` ties every hand-written list to **`CATALOGS`**, the declared catalog list
in `js/catalog-fields.js` (`smoke.mjs`, the block headed
*"EVERY CATALOG IS IN EVERY HAND-WRITTEN CATALOG LIST"*, read 2026-09-22). The
two missing tables are **not catalogs**. They are per-game overrides of a
catalog row, keyed `(skill_name, system)` and `(power_name, system)`, with no
`name` column. So `F100`'s check is complete against its own authority, and the
authority is the wrong set for this question. Source coverage is about **every
table that cites a page**, and that set lives in the schema.

**A decision already made, which constrains the fix.** `F100` was taken
*"as its ALTERNATIVE and not its proposal"* on Nate's word, 2026-09-16:
<!-- claim-ok: quoting F100's note, BOOK-INGEST-AUDIT.closed.md under ### F100 -->
*"A check, not the derive-from-`CATALOGS` refactor"*. The lists stay literal,
because they *"disagree about scope on purpose"* and a derived list makes a
deliberate exclusion easy to lose. **Deriving the source-coverage list from the
schema would reverse that decision for these two lists**, so this finding does
not propose it.

**Proposal:**

1. Add both tables to both `source-coverage` halves. Each needs its own entry
   rather than a string in the spread, because the spread selects
   `name AS label` and neither table has a `name`. The label should be the
   owning row's name plus the game, e.g. `skill_name || ' (' || system || ')'`.
2. Extend `F100`'s smoke block with a **second authority**: every table in
   `db/schema.sql` with a `source_book` column appears on both sides of
   `source-coverage.mjs`, unless it is a named exclusion with its reason, in
   the way `CITATION_EXCLUDED` already works. That makes the fifteenth table
   fail the suite on the day it lands, not when someone counts.

**Posture:** the tool stays advisory and always exits 0, as its header says. The
check is one more assertion in `F100`'s existing block, same posture as
`F100`'s. **No refactor and no derived list.** **This widens a required
check** (`smoke`), and it passes on the day it ships, because the same PR adds
the two tables.

**Evidence:** the two list reads, the schema `awk` and the `--remote` counts
above, all 2026-09-22. `F100`'s text, read under its heading in
`BOOK-INGEST-AUDIT.closed.md`, the same day.

**Confidence:** high on the gap and the counts. Medium on the label shape,
which is a display choice. Raising it takes one run of the tool afterwards to
read how the offenders print.

**Ongoing cost:** two more entries in each list, and one assertion. The recurrence
it stops is `F28`, `F85`, `F94` and this one: a hand-written subset of a set
that grew.

**Taken, 2026-09-22 (PR #1280).** Both parts are implemented as written.
**Posture, said back:** `source-coverage.mjs` stays advisory and still exits 0.
The assertion added to `F100`'s block uses the same shape as `F100`'s check,
with no refactor and no derived list. It widens `smoke`, which is a required
check, and it passes on the day it ships because the two tables land in the
same PR.

**What shipped:**

- **Both halves of `scripts/source-coverage.mjs`** read `skill_system_bases`
  and `psionic_system_costs`. Each gets its own entry after the spread, and
  each row is labelled `<skill|power> (<game>)`.
- **`apps/character-creator/test/smoke.mjs`**, inside `F100`'s block, gets a
  second authority. It builds `db/schema.sql` into an in-memory `node:sqlite`
  database. Every table with a `source_book` column in `pragma_table_info` must
  then be read by both halves, either as a spread entry or as its own
  `FROM <table>`. `SOURCE_EXCLUDED` holds the named exclusions and is empty.

**Two things the premise audit settled** (`audit-premise-auditor`,
2026-09-22). No premise was false.

- **`F100`'s own check cannot see a table added outside the spreads.** Its
  identical-lists check reads the spreads only, so a table added on one half
  alone would pass it. The new assertion therefore reads each half whole.
- **The schema is read through SQLite, not parsed as text.** An `awk` over
  `CREATE TABLE` bodies returns the right fourteen today. It would over-count
  if a comment inside a body ever mentioned `source_book`. The auditor also
  confirmed that no `ALTER TABLE` and no migration adds the column elsewhere.
  Production's `sqlite_master` agrees on the same fourteen.

**This finding's comparison to `F100`'s posture is loose.** <!-- claim-ok: quoting the premise this note corrects -->
It calls its posture the *"same posture as `F100`'s"*. `F100`'s note says its
check *"is not a required CI status"*, which was true on its day. `smoke` has
been required since 2026-09-16. F107 already says so outright, so only the
comparison was wrong.

**Proved by making it fail, 2026-09-22**, running
`smoke.mjs --section 'Catalog field config'`:

| injected | fired |
|---|---|
| `main`'s `source-coverage.mjs`, unchanged | half 1 **and** half 2: `skill_system_bases, psionic_system_costs` |
| `psionic_system_costs` dropped from the build half | half 2: `psionic_system_costs` |
| `skill_system_bases` dropped from the live half | half 1: `skill_system_bases` |
| `creatures` dropped from the live spread | `F100`'s list-1 and identical-lists checks, and half 1 |

Flagless smoke went from **2776 to 2780** checks.

**What the report says now**, `node scripts/source-coverage.mjs --remote`,
2026-09-22: `skill_system_bases` is **92 traceable of 92**, and
`psionic_system_costs` is **1 traceable, 2 unknown-book, of 3**. `--vs-build`
reports **6281** rows on each side, so the build half reads the new tables too.

**The two unknown-book rows are the first thing the wider report caught.**
`Hypnotic Suggestion (nightbane)` and `Death Trance (nightbane)` each cite two
page references in one value, `Nightbane RPG p.72, p.78` and
`Nightbane RPG p.77, p.84`. The single-page form, `Nightbane RPG p.57`,
resolves. **The rows are not fixed here, and no number is filed for them.**
Neither the data script nor the resolver is a file this PR edits. The case is
recorded in this session's hand-back list for Nate to decide.

**What cites this finding:** `F104`'s note describes this gap without its
number, and stays as it is, since an audit file is a record. `git grep F107`
and the memory directories otherwise find only this section, 2026-09-22.
`audit-citations.mjs --remote F107` reports no class citing it.

### F108 — low — a variant cannot remove a parent skill or carry its own ladder, so the Madhaven Mutant Shaman is half prose

**Opened 2026-09-24** by the `madhaven` import (`apps/character-creator/docs/surveys/madhaven.md`,
*The Mutant Shaman*). Filed under `book-survey` §8 Tier 3: filed, not built.

Rifts World Book 29 printed 79 makes a Shaman out of **any** of its eight Haven
Mutant R.C.C.s. Four things change:

1. attribute and P.P.E. bonuses;
2. a fixed skill list that **replaces** every Secondary skill, every Piloting
   skill and every modern W.P.;
3. two prayers, each with a percentile chance and a yearly limit;
4. its **own XP ladder**, the Gateway Knight & Mutant Shaman column of printed
   79. The other mutants use the Haven Mutant R.C.C. column.

The import models it as a `shaman` variant on each of the eight classes.
`VARIANT_OVERRIDES` in `apps/character-creator/js/parser.js` (line 64, read
2026-09-24) carries items 1 and 2's *additions*: `bonuses`, `ppe_base` and
`attribute_dice`, plus `skills_additional` since F31. It carries **neither a
removal nor `xp_table`**. F31's own comment says why removal is absent: the
union, *never replace*, is what stops a variant becoming a second class.

So, on all eight classes, a Shaman character:

- **keeps** its Secondary, Piloting and modern W.P. skills, which the book
  takes away;
- **levels on the wrong ladder**, the Haven Mutant column instead of the
  Gateway/Shaman one. The two ladders are 2,240 against 2,350 XP at level 2
  and 395,920 against 435,000 at level 15, so a Shaman levels a little early
  all the way up;
- shows the prayers as prose only, which is the right home for them (a
  conditional, percentile effect, and `class-import` puts those in prose).

Each class's `extraction_notes` cites this finding.

**Proposal:** add `xp_table` to `VARIANT_OVERRIDES`. It is a scalar array, so
it replaces, as the list's own comment says every non-merged key does. Check
`leveling.js`'s six call sites read the class *after* `applyVariant`. Then
move each Madhaven Shaman's ladder into its variant. **Leave the removal
alone.** F31 declined removal on purpose, and the book's replacement can stay
prose. One lost Secondary list per Shaman is a smaller wrong than weakening
F31's guarantee.

**Posture:** a mechanism change for `xp_table` only, with the data following it.
It adds no check.

**Evidence:** `VARIANT_OVERRIDES` read at `apps/character-creator/js/parser.js:64`,
2026-09-24. The ladders are transcribed from printed 79 (cache p080) by the
import session. Whether all six `xp_table` readers run after `applyVariant`
was **not measured**. That is the one premise a taker must check first.

**Confidence:** high on the gap. Medium on the fix's size, until someone reads
the six call sites. If any of them reads the raw class, the change grows past
one list entry.

**Ongoing cost:** one more key on a list a test already pins against
`docs/leveling.md`, so that doc gets one more word. Nothing recurring.

**Taken, 2026-09-27 (PR #1465), as written: `xp_table` only, the removal left
alone.** Taken through `/take` on Nate's word ("take both now", with F111).
The premise the finding marked unmeasured holds: the premise auditor traced
every reader of a class's ladder - six server call sites through
`_lib/class-loader.js`'s `loadClass` or `composeClass`, three in `app.js`
through `composeClass` / `applyVariant` - and all nine read the class after
`applyVariant`; `xpTableFor` is the only reader of `cls.xp_table`. So the
mechanism is the one list entry (`js/parser.js`), plus `docs/leveling.md`
naming it, which `documented-counts.mjs` failed on until it did (seen red).
The data is `~030-f108-shaman-ladders.sql`: the Gateway Knight & Mutant
Shaman column, copied from `gateway-knight`, on all eight `shaman` variants,
and the notes sentence that called the ladder prose rewritten. Proved on the
real parser: a parsed `beast-men` levels at 2,241 at level 2 and its Shaman at
2,351, through both `applyVariant` and `composeClass`; with the parser change
stashed the Shaman fell back to 2,241. Posture kept: no check added.
**Correction to the evidence:** the level-15 figures above (395,920 against
435,000) are the tops of each level-15 band, not the stored thresholds, which
are 335,921 and 360,801; the level-2 pair and "a little early all the way up"
hold.

### F109 — low — a related-skill category bonus cannot be scoped to part of a category

**Opened 2026-09-25** by the `cwc` import (`apps/character-creator/docs/surveys/cwc.md`).
Filed under `book-survey` §8 Tier 3: filed, not built.

Books print a category bonus that applies to only some of the category's
skills. Coalition War Campaign has four:

| class | printed | the line |
|---|---|---|
| `cs-nautical-specialist` | 79 | Pilot: Any, +10% to water vehicles only |
| `cs-rpa-fly-boy-ace` | 84 | Pilot: Any, +15% to aircraft and flying machines, otherwise +10% |
| `cs-rcsg-scientist`, `cs-special-forces` | 83, 86-87 | Technical: +10%, but +20% (RCSG) or +15% (Special Forces) to Literacy and Language skills |
| `cs-nautical-specialist` | 79 | Domestic: +5%, and +10% to Fishing |

Each is stored as the whole category at the lower figure, or at none, with
the scoped part in a note the player applies by hand.

**The obvious workaround does not work, which is why this is a finding and
not a data fix.** A class can list one category twice, once with `only` plus
the bonus and once with `except`. The parser accepts that; run 2026-09-25,
`parseClassMarkdown` on a two-entry `Pilot` block returned both entries
unchanged, with no error about them. But `categoryBonus`
(`apps/character-creator/js/parser.js:1493`, read 2026-09-25) takes the FIRST
entry whose name matches the skill's category. So with `only` first, every
Pilot skill gets the +10%, and with `except` first, none does. The same
function's cross-category branch (line 1486) does pay an `only` entry's bonus,
but only when that entry is filed under a DIFFERENT category name than the
skill's own. A class could abuse that by filing the water skills under some
other category it grants. That is a trick, not a model, and it is not
proposed.

**Proposal:** make `categoryBonus` prefer a same-category entry whose `only`
names the skill, then an entry whose `except` does not exclude it, then the
plain entry. `categoryAllows` must agree on which entry admits the skill.
Then rewrite the four lines above as split entries. Wherever the book gives a
different figure outside the named skills (the Fly Boy's +10%), that goes on
the `except` entry.

**Posture:** a mechanism change to one function, with the data following it.
It adds no check.

**Evidence:** `categoryBonus` read at `parser.js:1479-1496`, 2026-09-25, and
the two-entry parse run the same day. What `categoryAllows` does with two
same-named entries was **not measured**: that is the premise a taker checks
first, because the wizard, the sheet and `npc-generate.js` (lines 198, 215,
245, 250) all call both.

**Confidence:** high that the four lines are stored wrong today. Medium on the
fix's size, until someone reads `categoryAllows` for duplicate entries and
counts the other books with scoped bonuses. This import found four in one
book, and none was looked for elsewhere.

**Ongoing cost:** none recurring. One function gets one more rule, and the
smoke test that pins `categoryBonus` gets a case.

**Taken, 2026-09-27 (branch `pal/feat/book-ingest-audit-f109-f110`)**, in one
PR with F110. Nate approved bundling the two on 2026-09-27, overriding one PR
per finding for this batch.

**Posture, said back:** *"a mechanism change to one function, with the data
following it. It adds no check."* **It became two functions.** The premise
audit (2026-09-27, at `1b0f850a`) ran the real parser and found
`categoryAllows` first-hit too: with the `only` entry listed first, every
other skill in the category was REFUSED, not only scored wrong. Both functions
now read one ranking. No check was added. Smoke gained cases for the rule, and
an existing pin that read `categoryAllows`'s body for the four keys now reads
them in the helper they moved to.

**What shipped.**

- `apps/character-creator/js/parser.js`: `realCategoryEntry` ranks every entry
  naming the skill's real category. An `only` / `only_prefix` entry that names
  the skill comes first, then an `except` / `except_prefix` entry that does not
  exclude it, then a plain entry. `categoryAllows` and `categoryBonus` both use
  that ranking, so they cannot disagree about which line of the book applied.
  When no entry admits the skill, the first same-named entry is returned, which
  keeps a list naming a category once behaving exactly as it did. The per-entry
  test moved unchanged into `entryAdmits`.
- The four lines are now a second entry after the one each class already had
  (`~038-f109-scoped-category-bonuses.sql`):
  - `cs-nautical-specialist`: Pilot +10% to water vehicles, and Domestic +10%
    to Fishing (printed 79).
  - `cs-rpa-fly-boy-ace`: Pilot +15% on aircraft and modes of flying,
    otherwise +10% (printed 85).
  - `cs-rcsg-scientist`: Technical +20% to Literacy and Language (printed 83).
  - `cs-special-forces`: Technical +15% to Literacy and Language (printed 87).

  Each printed line was re-read from the `cwc` cache (`p080`, `p085`, `p084`
  and `p088`; offset +1). The notes that sent the player to add the difference
  by hand are rewritten in the same file.
- **The order is load-bearing for the window before the merge.** The data is
  applied first, while production still runs first-hit. Listed second, the new
  entry changes nothing until the ranking deploys.
- `functions/api/character-creator/_lib/skill-picks.js`: the comment on
  `dedupeCategories` said a repeated entry was harmless because matching took
  the first hit. It now says why the answer is unchanged under ranking.

**Measured, 2026-09-27**, against a `--remote` snapshot of 525 live published
classes and 402 skills, with a scratch script comparing `origin/main`'s parser
to this branch's:

- Every `categories` list in every class, 2,472 lists plus each class's merged
  related list, against every skill: **0** lists name a category twice, and
  **0** answers differ.
- The four classes after the data: **0** admission changes. Bonus changes land
  only on the scoped skills. The Nautical has 9 (Fishing 5 to 10, and eight
  water rows 0 to 10), the Fly Boy 8 (10 to 15), and the RCSG and Special
  Forces 32 each (10 to 20 and 10 to 15).
- The window: the new rows under the OLD parser give **0** changes of any kind.

**Judgement calls, recorded so they can be argued with:**

- "Water vehicles" is the five `Boat:` rows (as `only_prefix`), plus Military:
  Submersibles, Military: Warships & Patrol Boats and Water Scooters. Water
  Skiing & Surfing and Advanced Deep Sea Diving are not vehicles.
- "All aircraft and modes of flying" is Airplane, Helicopter, Hovercycles,
  Skycycles & Rocket Bikes, Jet Aircraft, Jet Packs, Military: Combat
  Helicopter, Military: Jet Fighters and Wingrider Flying Wing. Power armor,
  robot combat and the `Space:` rows stay at +10%.
- "Literacy and Language" is `only_prefix: ["Language", "Literacy"]` on
  Technical, which also reaches `Language Dialects`.

**One instruction in the brief was not followed, on purpose.** The brief said
the Nautical split's `except` entry "must add the water vehicles"
<!-- claim-ok: quoting the brief this note corrects -->. It does not need to:
the ranking puts the `only` entry first for the skills it names. Adding them
would also have refused every water vehicle during the pre-merge window, under
the first-hit parser still live. The Pilot `except` entry is unchanged.

**Residue:**

- **Seven Literacy/Language rows are filed under Communications**, not
  Technical. They are Literacy: Euro, Gypsy, Native Language, Other and Russian,
  and Language: All (magical) and Dolphin/Whale (`--remote` snapshot,
  2026-09-27). They take the Communications +10% in both classes, 10 and 5
  points under the book. They were not moved, because re-filing a catalog row
  reaches every class that grants either category.
- **The same shape in other books is not taken here.** A regex sweep of the
  same snapshot for "+N% to/on … only" and "but +N% to" hits about forty live
  classes. How many of those are a related-category bonus stored as the whole
  category was **not measured**, because the phrase also matches O.C.C.-skill
  bonuses and cross-category lines that F9 already scores. The hits include:
  cyber-knight, glitter-boy, techno-wizard, body-fixer, mercenary-fighter,
  thief, assassin, diabolist, witch, mind-mage, psi-healer, psi-mystic,
  psychic-sensitive, daitya, phaeton-juicer, dragon-ray, rurlel-eelman,
  whale-singer, fq-deep-intel-agent, fq-gb-reloader, totem-warrior, pirate,
  sailor, biomancer, psi-ghost, arkhon, arkhon-spectral-hunter, serpentoid,
  condoroid, falconoid, duelist, african-priest, african-witch, grey-seer,
  rifts-gosai-assassin, zenith-moon-warper and rogue-scientist. The first to
  take is `ntset-protector`, from this same book (Medical +10% to Crime
  Sciences and Pathology, printed 188). **Not filed as a finding.** This menu
  holds code changes only, the mechanism now exists, and per its header each
  of these is data that ships with its own book.
- `node scripts/audit-citations.mjs --remote F109`, 2026-09-27: 0 of 525 live
  classes cite it. A tree grep found `apps/character-creator/docs/surveys/cwc.md`
  (*What remains*), corrected in this PR. A grep of the memory directory found
  three files. `cwc-survey.md` called both findings open, and
  `book-reprocess-sweep-plan.md` listed scoped bonuses as still impossible.
  Both are corrected. `south-america-2-survey.md` cites the number only to
  record a numbering collision, and needed nothing.

### F110 — low — Psi-Stalker and Dog Boy are O.C.C.s, so "humans or Psi-Stalkers only" cannot be stated

**Opened 2026-09-25** by the `cwc` import (`apps/character-creator/docs/surveys/cwc.md`).
Filed under `book-survey` §8 Tier 3: filed, not built.

Coalition books open their classes to "humans or Psi-Stalkers", and sometimes
to Dog Boys:
- the NTSET Protector (Coalition War Campaign printed 188);
- the Coalition Grunt (Rifts Ultimate Edition p.230, whose class note says so).

The catalog stores `psi-stalker`, `wild-psi-stalker` and `dog-boy` as
**O.C.C.s** (`category: occ`; queried `--remote`, 2026-09-25). A mutant's
racial package rides inside the occupation, and there is no race row to pair
with. `race_restrictions` accepts only race ids or `"none"`
(`apps/character-creator/js/parser.js:2848-2853`, read 2026-09-25). So these
classes store `only: ["none"]`, humans only, and say in the note that a
Psi-Stalker Protector cannot be built. The book allows one.

`ntset-psi-hound` shows the other half of the cost. The book makes it an O.C.C.
for a mutant dog (printed 187). With no dog race to pair it with, the class
carries a full copy of `dog-boy`'s racial package, attributes, pools, psionics
and senses. That is a second copy to keep in step with the first.

A `--remote` query on 2026-09-25 found 13 live classes mentioning Psi-Stalkers,
Dog Boys or Dog Packs beside a race restriction. That counts mentions. How many
of them the book actually opens to those races was **not measured**.

**Proposal:** split each mutant into a race row (R.C.C.) carrying the racial
package and an occupation carrying the O.C.C. Then point `race_restrictions`
at the new race ids. The live `psi-stalker` and `dog-boy` classes would become
a race plus a default O.C.C., in the way Nightbane's race-and-package pairing
works. **This is not a small change**, because characters already built on
the combined classes must keep working. A taker should weigh that against
leaving these few classes humans-only with a note, which is what ships today.
**If the weighing comes out against it, record that and decline this
finding.**

**Posture:** a data-model decision first. No code until Nate chooses. It adds
no check.

**Evidence:** the class categories from `q.mjs --remote`, 2026-09-25; the
parser rule read at `parser.js:2848-2853` the same day; the 13-class mention
count from the same query session. The Grunt's rule is **reported by** its
own class note, not re-read from RUE, which is not cached on this machine.

**Confidence:** high on the gap. Low on how many classes it really affects,
until someone reads the 13 mentions and sorts rules from mentions.

**Ongoing cost:** if taken, a race row per mutant kept in step with its
occupation, forever. That is exactly the cost `ntset-psi-hound` already pays
by copying, so the choice is about where that cost lives, not whether there
is one.

**Taken, 2026-09-27 (branch `pal/feat/book-ingest-audit-f109-f110`)**, in one
PR with F109. Nate approved bundling the two on 2026-09-27, overriding one PR
per finding for this batch.

**Posture, said back:** *"a data-model decision first. No code until Nate
chooses. It adds no check."* **Nate chose the split, race plus O.C.C., on
2026-09-27.** The weighing the proposal asked for came out for it. The cost it
warned of is characters built on the combined classes, and there were none. A
`q.mjs --remote` query on 2026-09-27 found 0 of 7 `characters` and 0 of 2
`character_drafts` rows on `psi-stalker`, `wild-psi-stalker`, `dog-boy` or
`ntset-psi-hound`, whether as `class_id`, `occ_class_id` or in a draft's
state. The premise audit found the same. No check was added. One named list in
`regression.mjs` grew, and one wizard guard was added, explained below.

**What shipped.**

- **Two races.** `mutant-psi-stalker` (`add-mutant-psi-stalker-class.sql`)
  carries the Psi-Stalker's attribute dice, P.P.E., psionics, psionic, magic
  and physical bonuses, and natural abilities. RUE prints all of these as what
  every Psi-Stalker has, "CS, civilized or wild" (printed 153, cache `p156`).
  `mutant-dog` (`add-mutant-dog-class.sql`) carries the Dog Boy's dice, hit
  points, S.D.C. 20, P.P.E., psionics, racial bonuses and senses. Neither race
  has `occ_restrictions`: each occupation's own `race_restrictions` governs, as
  for any race. The Dog Boy's Designer's Note says a Dog Boy could learn other
  jobs.
- **Four occupation halves** (`~039-f110-psi-stalker-and-dog-races.sql`). They
  are `psi-stalker`, `wild-psi-stalker`, `dog-boy` and `ntset-psi-hound`, which
  keep their ids and names and now take only their race. The Wild
  Psi-Stalker's P.S. and P.P. of 3D6+2 are the race's 3D6 plus a +2 occupation
  bonus. The Psi-Hound keeps only the bonuses its book adds to the dog's. The
  copy of `dog-boy`'s package that the proposal called a second thing to keep
  in step is gone.
- **Every class whose book opens it to these races.** `coalition-grunt` (RUE
  printed 233, cache `p236`), `ntset-protector` (printed 188) and `psi-slinger`
  (New West printed 100) now read `only: ["none", "mutant-psi-stalker"]`.
  `psi-net-agent` also takes `mutant-dog`, because its roster (printed 194) is
  20% Psi-Stalkers and 50% Dog Pack among its Sensitives. The Psi-Slinger's
  prose line citing BOOK-INGEST-AUDIT F51 is replaced by the block F51 could not
  write, which closes the narrower of that finding's two gaps. F51 itself stays
  closed undone, because its kind field is still unbuilt.
- **`seljuk`'s note** named the old `only: ["none"]` block as what refuses a
  seljuk Psi-Stalker. The rule still holds, and the note now names the block
  that enforces it.

**Measured before any of it was written.** A scratch script ran on 2026-09-27
against production's own rows. It composed each race with each reworked
occupation through `js/compose.js` `composeClass`, and compared the result to
what the combined class composed to. The fields compared were attribute dice,
all four pools, P.P.E., money, experience table, psionics, bonuses, skills,
equipment, abilities and level progression. The result was **0 unexpected
differences** across all four pairs. The one expected difference is the Wild
Psi-Stalker's +2, which arrives as a bonus. The restriction prose moved to the
race and is reworded, not lost. `raceAllowedForOcc` was run over the nine
classes, for a human, each race, and each class. Every occupation half refuses
a human and the other race, and every opened class admits exactly the races
its book names.

**Corrections to the finding.**

- **"13 live classes" did not reproduce, and it counted mentions, as the
  finding said.** Re-measured 2026-09-27 over the same `--remote` snapshot,
  with `parseClassMarkdown` reading `race_restrictions.note` and every
  `restrictions` line: **16** live classes name Psi-Stalkers, Dog Boys, Dog
  Packs or a mutant dog. Sorted:
  - 5 combined classes. These are the four split here, and `psycho-stalker`.
  - 4 rules this change can now state: the Grunt, the NTSET Protector, the
    Psi-Net Agent and the Psi-Slinger.
  - 7 mentions that open nothing new. `coalition-juicer`'s book forbids the
    augmentation of Psi-Stalkers and mutant animals. `iss-peacekeeper` prints
    no racial line and stays human. `whale-singer` and `biomancer` carry no bar,
    so they pair with either race already. `dakini` names Psi-Stalkers as its
    enemies. `rifts-wolfen` and `rifts-coyle` are races that may join a Dog
    Pack, and `dog-boy` stays the mutant dog's training.
- **The scope included `psycho-stalker`**, which the finding does not name.
  **It is deliberately left combined, and still human-only.** Juicer Uprising
  prints its physical and saving-throw bonuses with the Psi-Stalker's already
  counted in, as its own ability text records. `combineClasses` sums a race's
  bonuses with an occupation's (`sumBonusGroups`, unconditional even for
  `supersedes_race`). So pairing it with `mutant-psi-stalker` would count +5 vs
  mind control, +6 vs horror factor, +1 attack and the pool bonuses twice. Its
  note now says so. **Dropped rather than filed:** no key lets an occupation
  replace a race's bonuses, and this one class stands correctly as it is.
- The validator line numbers in the finding had moved: `validateRaceRestrictions`
  is at `parser.js:2961` and `raceAllowedForOcc` at `:2896` on this branch.

**One addition the finding did not ask for, because the split made it
necessary.** The wizard's Race step lists O.C.C.s beside R.C.C.s, as a human
character. Picked there, the Dog Boy used to be a whole mutant dog. After the
split it would be a human with Dog Pack training and no warning. `app.js`
`classBlock()` now refuses an O.C.C. whose own `race_restrictions` refuse the
human case, and names the race to pick instead. The same guard covers the
fifteen own-training O.C.C.s that already refused a human in
`raceAllowedForOcc` and were never stopped on this step. The Nightbane packages
are among them. The server still accepts a lone O.C.C., as it always has
(`characters.js` checks a pairing only when both halves are present).
**Dropped rather than filed:** the wizard is the path a player takes.

**Residue:**

- `shared/js/namegen-themes.js` keys name themes by class id, and the
  occupation wins. A Dog Boy still gets Dog Boy names, and a Psi-Stalker
  Coalition names. A mutant dog in any other occupation gets the game default.
  That pairing could not exist before today, so nothing loses a theme. It is
  left alone because a shared path goes in its own PR.
- The City Creator lists `category: rcc` rows as a city's races, so both new
  races become available there. A race without an occupation is rolled with
  one, as for any race that needs one.
- `node scripts/audit-citations.mjs --remote F110`, 2026-09-27: 0 of 525 live
  classes cite it by number. The classes whose notes said the pairing could not
  be built are rewritten above. The tree grep found
  `apps/character-creator/docs/known-limitations.md`, whose table of the
  founding race bars now records the change, and `docs/surveys/cwc.md`. The
  memory grep found `cwc-survey.md`, which called the finding open and is
  corrected, and `south-america-2-survey.md`, which cites the number only for a
  numbering collision.

### F111 — medium — a non-superseding race keeps its own P.P.E. and starting money over a spell-casting or salaried occupation's

**Opened 2026-09-25** by the `south-america-2` import
(`apps/character-creator/docs/surveys/south-america-2.md`). Filed under
`book-survey` §8 Tier 3: filed, not built, on Nate's call the same day.

`combineClasses` resolves eight pool and body keys with one rule
(`apps/character-creator/js/parser.js:1183-1187`, read 2026-09-25): a
superseding occupation replaces the race's value, and otherwise **the race's
wins whenever both state one**. The comment above it gives the reason for
`horror_factor` and `second_form` - they belong to the body. **F11 took this
loop on 2026-08-31 (PR #430)** and deliberately left the non-superseding case
as it is: its outcome note says a class without the flag still loses its pools
to the race, *"which is the posture."* This finding does not reopen F11. It
names two keys for which the body argument does not hold and the book shows
the opposite.

- **`ppe_base` on a spell-casting occupation.** The Larhold Barbarian R.C.C.
  (printed 185-186) states P.P.E. 3D6, which is the book's figure for a
  Larhold who does **not** take a magic O.C.C. The Larhold Shaman O.C.C.
  (printed 188-190, `occ_group: magic`) states 3D6x10 + P.E., +3D6 per level.
  Paired, the loop keeps the race's 3D6, so a Larhold shaman casts from a
  pool about a tenth the size the book prints. A human shaman, who has no
  race, gets the printed figure.
- **`starting_money` on any occupation.** The Arkhon R.C.C. states 1D6x1000,
  so the Arkhon Spectral Hunter (2D4x1000) and ESP Specialist (2D6x1000),
  both Arkhon-only, never start with their own money. The Larhold Shaman
  starts with the Barbarian's 1D6x1000, not its own 2D6x1000. `xp_table`,
  six lines further down, already runs the other way for the reason that
  applies here too: it comes from what a character does, not what it is.

Each affected class's `extraction_notes` records the effect and cites this
finding.

**Proposal:** in that loop, let the OCCUPATION win for two keys, the way
`xp_table` already does. `starting_money` would always prefer the occupation.
`ppe_base` would prefer the occupation when its `occ_group` is `magic`, and
stay race-first otherwise, because a race's P.P.E. is a property of the body
for every men-of-arms pairing. The `class-check` warning that lists what a
race would discard (added under F11) should stop naming those two keys where
they no longer apply.

**Posture:** a composition change for two keys. It adds no check, and it
touches no class file.

**Evidence:** the loop was read at `parser.js:1183`, 2026-09-25. The three
pairings are this book's drafts (`class-check --remote`, 2026-09-25), which
print the discard warning on each. **Not measured:** how many already-published
pairings change. A taker must run `combineClasses` over every published
race-and-occupation pair before and after, as F11's own table did, and list
every pair whose `ppe_base` or `starting_money` moves.

**Confidence:** high on the three cases here. Medium on the rule, until that
census runs. A Palladium Fantasy race whose book says its P.P.E. REPLACES a
mage O.C.C.'s would argue for keeping race-first there, and the census is what
finds one.

**Ongoing cost:** none recurring. It is one conditional in a loop, and the doc
comment above it grows two sentences.

**Taken in part, 2026-09-27 (PR #1467), as an OPT-IN per occupation rather than
the proposal's rule - on Nate's word, after the census the proposal asked for.**
That census ran `combineClasses` over every legal published race-and-occupation
pairing, variants included, before and after the proposed rule (session
scratchpad `census.mjs`, production snapshot 2026-09-27). The rule would have
moved about **9,390 pairings' P.P.E., 2,451 of them downward** - a Phoenixi
mage falling from 3D4x100 - and about **6,048 pairings' money**, including
races whose book prints none. It would also have broken two shapes the
proposal's confidence line anticipated: races whose P.P.E. **adds** to a mage
O.C.C.'s (`rifts-cyclops`, `rifts-elf`) and races that print their own mage
figure (`godling`, `true-inca`, `draconid`). So the general rule was declined.

**What shipped.** A new O.C.C. key, `overrides_race`, a list drawn only from
`ppe_base` and `starting_money`. `combineClasses` gives the occupation the
listed keys when it states them and composes everything else as before;
`supersedes_race` is unchanged. `parseClassMarkdown` refuses any other key, a
bare value, an empty list or a repeat, and warns when the key sits on a race or
on an occupation not limited by `race_restrictions.only`. `class-check`'s
racial-discard warning (F11's cheaper alternative) no longer names a key the
occupation takes. `~031-f111-occupation-pools.sql` sets `[starting_money]` on
the **Arkhon Spectral Hunter** (2D4x1000, printed 74) and **Arkhon ESP
Specialist** (2D6x1000, printed 76), both Arkhon-only, over the Arkhon R.C.C.'s
1D6x1000 (printed 73): one pairing each. Regression pins the two takers by
name. Posture: an opt-in with no effect on any occupation that does not declare
it, which regression's existing race-first invariant still asserts.

**The Larhold Shaman, this finding's headline case, is NOT given the key, and
that is a question back to Nate rather than a decision.** The brief named it,
but the class carries no `race_restrictions` - printed 189 says humans, ogres,
wolfen and others train in the Ways of the Flame - so the key would reach every
race it pairs with. Measured against the same snapshot: **206 pairings over 150
races** (165 P.P.E., 41 money), among them `rifts-cyclops`, `rifts-elf`,
`godling`, `true-inca`, `draconid` and a Phoenixi falling from 3D4x100 - the
cases the decision said to leave alone. A Larhold Shaman therefore still
composes to the Larhold Barbarian's 3D6 P.P.E. and 1D6x1000. Two ways to close
it, neither built: a race-scoped form of the key, or a key on the **race**
saying its figure yields to a magic occupation. The Palladium Fantasy human
prints its P.P.E. that way ("2D6 for most adults, unless a mage or clergy
O.C.C."); the Larhold Barbarian prints a flat P.P.E. 3D6 beside "Magic Powers:
None unless a magical O.C.C. (see below) is selected" (printed 186, cache
p186 line 33, read 2026-09-27), which points the same way less directly.

**Found while doing it.** The Palladium Fantasy `human` note said a mage or
clergy O.C.C.'s P.P.E. wins the pairing. It never did: a human wizard,
summoner, diabolist or witch composes to the race's 2D6, measured the same day.
The note now says so; the composition is unchanged and is the same open
question as the Shaman's.

**The Larhold part closed, 2026-09-27 (PR #1470), as a RACE-side key - on
Nate's word ("fix the Larhold Shaman with the race-side key").** A new R.C.C.
key, `yields_to_occupation`, maps `ppe_base` or `starting_money` to the
occupation groups whose stated figure wins it in a pairing; a race without it,
and an occupation of a group it does not name, composes as before.
`parseClassMarkdown` refuses any other key, a group outside the five, an empty
map or list and a repeat, and refuses the key on an O.C.C.; `class-check`
knows it, and its racial-discard warning now says a race may take the
occupation's P.P.E. or money this way. Regression pins the carriers by name.
`~032-f111-race-yields-ppe.sql` sets it on four races, each on its own book's
wording, found by searching every race's stored text and every cached book for
the conditional:

- **`larhold-barbarian`**: `ppe_base` to `magic`, and `starting_money` to all
  five groups. The money half goes further than the P.P.E. half on the book's
  evidence, not by analogy: the Barbarian's 1D6x1000 is in the R.C.C.'s own
  *Other Equipment* line (printed 186, cache p186 line 129), the same page's
  O.C.C.s paragraph has a Larhold take an O.C.C. in place of the basic R.C.C.
  and keep only War Bison riding and W.P. Archery, and nothing there limits
  that to a magic O.C.C. The Shaman prints its own 2D6x1000 (printed 190).
  Cutting money to `[magic]` would have been a line the book does not draw.
- **`amphib`**: `ppe_base` to `magic` - Underseas printed 99, *"P.P.E.: 3D6
  unless a magic O.C.C."*, the plainest statement of the shape in the catalog.
- **`human` and `elf`** (Palladium Fantasy): `ppe_base` to `magic` and
  `clergy`. The book says *"mage or clergy O.C.C."* (printed 289 and 291), so
  the condition is the occupation's group rather than "states a ppe_base", and
  clergy is named with it. The four clergy occupations that state P.P.E. - the
  priests of light and darkness, the druid and the warrior monk, whose page
  calls it *"a member of the clergy"* (printed 71) - are in the catalog's
  `clergy` group. The PF witch states no `ppe_base` and keeps the race's.

**Measured.** A census over a production snapshot of the 525 published
classes, 2026-09-27: 37,024 legal same-system pairings, race variants
included, legality as the wizard applies it. The key moves **298** of them and
no others - `larhold-barbarian` 65 P.P.E. and 154 money, `amphib` 65 P.P.E.,
`human` 7 and `elf` 7 - and no P.P.E. it moves lands below the race's own
figure. **Not keyed:** `rifts-cyclops`, `rifts-elf` and `true-atlantean`
(their P.P.E. adds to a mage's), `godling`, `true-inca` and `draconid` (they
print a mage figure of their own), and `felinoid`, whose *"Magic: none,
unless a magic O.C.C."* is about spells and states no P.P.E. Palladium
Fantasy's goblin, orc, ogre, troll, wolfen and coyle print "for the typical"
race (cache `pf` p302-p314, read 2026-09-27), which hedges without naming an O.C.C., and are left race-first.

**Found while doing it.** The Larhold Barbarian's own skill note records that
in a pairing its whole R.C.C. skill list unions onto the O.C.C.'s (its
`extraction_notes`, read `--remote` 2026-09-27), where
printed 186 grants only War Bison riding and W.P. Archery beside an O.C.C. That
is the same page this money decision reads, and it is unchanged here - recorded
in the class's note already, not taken up.

**Filed as `F114`, 2026-09-27**, so the residue above has a number rather than
living only in a class note.

### F112 — low — the creatures and notables SQL generator is rebuilt in a session scratchpad for every book

**Opened 2026-09-25** by the `psyscape` import (`apps/character-creator/docs/surveys/psyscape.md`,
ledger line for the creatures PR). Filed under `book-survey` §8 Tier 3: filed, not built.

Every book that ships `creatures` / `notable_npcs` / `stat_attacks` rows writes
its own generator from worker JSON to one data script, and the generator lives
in that session's scratchpad. The memory store records it three times: Phase 2a
of the bestiary plan (`normalize.mjs`, `gen-sql.mjs`, *"both were in the session
scratchpad, now gone - rebuild from the SQL file's shape"*), Phase 3 (`p3/` in
that session's scratchpad, with `copycheck.mjs`), and South America's
`add-south-america-creatures.sql` header, which states an 8-word shingle check
that no tracked file runs. Psyscape rebuilt it again on 2026-09-25, from
`add-south-america-creatures.sql`'s shape.

Each rebuild re-decides things the previous one had settled:

- which fields the copy check reads. A check over every text field flagged 40
  stat lists (spell names, psionic powers, skill percentages, allies) as copied
  prose on the first Psyscape run. The working rule was prose fields only, and
  skipping runs that are mostly numbers. The rule was proven by planting a
  sentence copied from the text layer and watching the check refuse it;
- the gate on `creatureFormulaGaps` before a row is written;
- 50-row batching, the read-back assertions, and the `data_script_runs` footer.

**Proposal:** add `scripts/bestiary-sql.mjs`, a tracked version of the
Psyscape generator: `node scripts/bestiary-sql.mjs <slug> <worker-json-dir> <out.sql>`.
It validates columns against `db/migrations/072`/`073`/`074`, refuses a row
that fails `creatureFormulaGaps` or holds non-ASCII text, refuses an 8-word
run shared with the book's cached text layer in the prose fields only, and
writes the batched INSERTs and read-backs. Cite it from `book-survey` §6 and
from the NPC-and-bestiary part of the relevant skill. **Leave extraction and
reconcile as agent work.** This covers only the step from JSON to SQL.

**Posture:** a new tool, opt-in. No check fails a PR that does not use it, and
no existing data script is regenerated.

**Evidence:** the three scratchpad generators are **reported by** the memory
files `npc-bestiary-plan.md` and `south-america-survey.md`, read 2026-09-25.
The Psyscape generator's behaviour (40 false copy hits, then 13 real passages
after narrowing to prose fields, 7 more in the last race file) was measured in
this session, 2026-09-25. Whether the South America and Phase 3 copy checks read
the same fields was **not measured**; their scripts are gone.

**Confidence:** high that the generator is rebuilt per book. Medium on whether
one generator fits every book: South America stored a few fields
differently, per its header. That settles when a taker diffs the Psyscape
generator's output shape against `add-south-america-creatures.sql`.

**Ongoing cost:** one script that must track `creatures` / `notable_npcs` if
either table gains a column. Migration 074's shape has not changed since it
landed.

**Taken, 2026-09-27 (branch `pal/feat/book-ingest-audit-f112-f113`), with F113
in one PR on Nate's word of 2026-09-27, which overrides one-PR-per-finding for
this pair.** Posture said back: **a new tool, opt-in. No check fails a PR that
does not use it, and no existing data script is regenerated. Extraction and
reconcile stay agent work.** `scripts/bestiary-sql.mjs` is the JSON-to-SQL step
only. It refuses rather than repairs, and it refuses to overwrite a file that
exists. Its copy-check proof is `--self-test`, run by hand, and no suite calls it.

What it does, as proposed:
- It reads columns from `db/schema.sql` (the `CREATE TABLE`s at lines 1207,
  1253 and 1274) and rebuilds the same three tables from `db/migrations`
  (072-074 plus any later `ALTER TABLE ... ADD COLUMN`). It refuses to run if
  the two disagree. On 2026-09-27 they agreed: 31, 37 and 9 columns.
- It refuses a row that fails `creatureFormulaGaps`, a key that is no column,
  a value outside a `CHECK (... IN ...)` list, and non-ASCII per value.
- It refuses an 8-word run shared with the cached text layer, in the prose
  fields only.
- It writes 50-row (and at most 90 KB) INSERTs, read-backs by slug, and the
  `data_script_runs` footer.

It is cited from `book-survey` §6 (`.claude/skills/book-survey/SKILL.md:304-312`
after this edit; 304-310 before it).
**Correction:** no skill has an "NPC-and-bestiary part" (premise audit,
2026-09-27, at `1b0f850a`), so §6 is the only place it is cited. It is also in
the README's `## The scripts at the repo root` map, which
`documented-counts.mjs:266-274` requires of every `scripts/` file (smoke). The
proposal missed that requirement.

**The premise is stronger than written.** The premise audit found that 18 of
the 25 creature and NPC scripts in `apps/character-creator/db/` came from
generators rebuilt in scratchpads. It also found a fourth pair,
`normalize-notables.mjs` / `gen-notables.mjs`, in the memory file
`npc-bestiary-plan.md`. **Correction to the confidence line:**
`add-south-america-creatures.sql`'s header (lines 16-24) says nothing about
storing fields differently, and its shape matches Psyscape's.

**Proved by regenerating, 2026-09-27; nothing regenerated was committed.**
- Each shipped script was replayed into node:sqlite and its rows read back as
  worker JSON. Each was then regenerated and diffed statement by statement.
- **`add-psyscape-creatures.sql`:** 5 of 10 statements byte-identical, which
  is every INSERT (creatures, notables, two 50-row `stat_attacks` batches)
  and the footer. The 5 read-backs differ because Psyscape's filter on
  `source_book LIKE` and the generator's filter on the script's own slugs.
- **`add-south-america-creatures.sql`:** 8 of 10 byte-identical. The only
  differences are two assertion labels, which name the book.
- Both regenerated scripts replay with every assertion holding.
- **Psyscape's last read-back counts `owner_kind = 'notable'`**, a kind no
  endpoint reads; `from-notable.js:43` and `codex.js:310` read
  `'notable_npc'`. It asserts 0 either way, so the shipped script is right by
  accident. Applied scripts are never edited here, so it is left alone.

**What the regeneration changed in the tool: the prose-field list is narrower
than a reading of "prose" gives.** A first cut read `pools_note`,
`bonuses_note` and `habitat` as prose. On the shipped Psyscape rows (which its
own generator passed) that cut raised 38 refusals: printed rule wording (*needs
a 12 or higher to save vs psionics*) and place lists. Those are facts a row
repeats, the same class as the 40 stat-list hits this finding records. The
fields checked are now `natural_abilities`, `occ_note` and `description` for
creatures, and `natural_abilities`, `disposition` and `description` for
notables. A run with 3 or more digit-bearing tokens is skipped. Words join
across `M.D.C.` and `Psyscape's`. Under that rule both shipped books pass.
**This is fitted to two books that passed their own checks, so read it as the
floor of what those generators checked, not as a measurement of it.** The
scratchpad generators are gone and cannot say. `--self-test` plants a copied
sentence in `description` and watches it refused. With `description` dropped
from the list, and every lookup forced to miss, that case goes red.

**The `book-survey` edit was pressure-tested** (`test-suite` → *A skill is a
check too*):
- Two RED and two GREEN runs used one blind prompt: plan the JSON-to-SQL step
  for a rehearsed book at 11pm, with the three prior books having done it
  three ways.
- The runs were on a neutral branch and WIP commits, with the prompt pointing
  each runner at this tree's copy of the skill, because the junction serves
  the main checkout.
- **RED 2 of 2 found and used the tool anyway**, through a grep of `scripts/`,
  the README entry and this finding's text. **GREEN 2 of 2 used it too,
  citing §6**, and opened fewer files on the way.
- So on this scenario the citation adds a shorter path, not a different
  outcome. It shipped as one sentence, as the finding asks. Two earlier RED
  runs were discarded, because the tool showed in their git snapshot as
  untracked and the scenario book had no creatures to import.

### F113 — low — `class-check` passes three class shapes that smoke and regression refuse

**Opened 2026-09-25** by the `psyscape` class imports (#1401, #1404, #1405). Filed
under `book-survey` §8 Tier 3: filed, not built.

A class draft that reads `class-check: ready — 0 errors, 0 warnings` against
production still fails the suite, found only after the data script is emitted
and applied locally. Three shapes, each measured this session:

| shape | `class-check --remote` | caught by |
|---|---|---|
| a fixed grant of the placeholder row `Literacy: Other` | ready, 0 warnings | `regression.mjs:4116`, *no class GRANTS the placeholder row as a fixed skill* |
| `men_of_arms` on a class that states its own `sdc_base` | ready, 0 warnings | smoke, `test/checks/catalog-data.mjs:93`, *no S.D.C. grouping sits on a class that states its own* |
| an equipment slug present in production but not in a build from the repo | ready (it looks the slug up `--remote`) | `regression.mjs:5635`, *every gear slug a rebuilt class references resolves* |

The first two were reproduced on 2026-09-25 by editing a copy of a shipped
draft back into the refused shape and running `class-check --remote` on it.
Both came back ready. The third is by construction: the draft offered South
America 2's `ip-7-ion-pistol`, which production held and this branch's base
did not.

South America hit more of the same (`south-america-survey.md` in the memory
store): an `isp_base` identical to `ppe_base`, and a fixed `Language: Other`
without `per_level: 0`. `INGESTION-AUDIT` (closed) recorded the first instance
of the pattern, two presence checks `class-check` is silent on. The
table in `class-import`'s `reference/frontmatter.md` ("What each tool actually
catches") comes from that note. That table documents the gap and proposes no fix.

The cost is a full regression run per miss, about 10 minutes, and a
regenerated script.

**Proposal:** in `scripts/class-check-lib.mjs`, warn (not error) on the first
two shapes, reusing the predicates the suite checks run where they can be
imported. Leave the third alone: `class-check --remote` is right that the slug
exists in production, and a slug newer than the branch base is a rebase
question, not a class defect.

**Posture:** warnings only. The exit code does not move, and the suites stay the
authority.

**Evidence:** the three suite failures, with their line numbers, read on
2026-09-25 from this session's smoke and regression output. The two
`class-check` reproductions were run on 2026-09-25. The South America shapes are
**reported by** the memory store and were not re-run here.

**Confidence:** high on the two reproduced shapes. Medium on sharing predicates
with the suites. That settles when a taker reads whether the two checks' tests
are importable functions or inline loops.

**Ongoing cost:** two warnings that must follow their suite rules if either rule
changes, which is the drift this finding exists to shrink. If the predicates
cannot be shared, the rule text is duplicated in two places, and the finding
should say so and consider declining.

**Taken, 2026-09-27 (branch `pal/feat/book-ingest-audit-f112-f113`), with F112
in one PR on Nate's word of 2026-09-27, which overrides one-PR-per-finding for
this pair.** Posture said back: **warnings only. The exit code does not move,
and the suites stay the authority.** The third shape is left alone, as written.

**Line drift, found by the premise audit (2026-09-27, `1b0f850a`):**
- The placeholder check is now `regression.mjs:4149`, with its collection loop
  at 4123-4134.
- The gear-slug check is at 5845, and stays out of scope.
- `catalog-data.mjs:91-93` holds.
- Both predicates were **inline**, not exported.

**Route taken: moved, not copied.** `scripts/class-check-lib.mjs` now exports
`LITERACY_PLACEHOLDER`, `grantsLiteracyPlaceholder(entry)` and
`menOfArmsBesideOwnSdc(statesSdcBase, menOfArms)`. `regression.mjs`'s
collection loop and `catalog-data.mjs`'s `stale` filter call them, and
`class-check.mjs` warns with them. The precedent is `catalog-data.mjs:23`, which
already imported `KNOWN_SKILL_KEYS` from that lib. This is the route the
Ongoing-cost line prefers: the rule has one text, so the drift this finding
names cannot happen between the warning and the refusal. The inputs still
differ, and each consumer builds its own:
- regression hands it a class the worker parsed;
- smoke hands it what a data script's text states;
- `class-check` hands it the draft it just parsed.

**Proved, 2026-09-27:**
- **The two reproductions, re-run as the finding ran them.** A copy of
  `add-grey-seer-class.sql`'s draft was given a fixed `Literacy: Other`, and a
  copy of `add-amorph-class.sql`'s had `men_of_arms: false` added beside its
  `sdc_base: 0`.
  - Before the change, `class-check --remote` said `ready`. The literacy draft
    carried 1 warning, the Grey Seer's own F11 note, and the other carried 0.
    Neither warned about its shape.
  - After the change, the literacy draft is `ready — 0 errors, 2 warnings`,
    adding *occ_skills grants "Literacy: Other" by name*. The other is
    `ready — 0 errors, 1 warning`, *men_of_arms sits beside a stated sdc_base*.
  - Both exit 0. The unedited originals stay at 1 and 0 warnings.
- **`test/checks/class-check-tool.mjs` gains seven checks.** Four pin the two
  predicates, and three run the real CLI (`--no-catalog`): one draft in each
  shape, plus a draft in the accepted shapes that must warn on neither.
  - With both warnings disabled in `class-check.mjs`, the two CLI checks went
    red. With `menOfArmsBesideOwnSdc` loosened in the lib, smoke's *no S.D.C.
    grouping sits on a class that states its own* went red on thirty-odd
    classes. So smoke reads the shared predicate.
- `class-import`'s `reference/frontmatter.md` table (148-161) covers
  `occ_group` and `xp_table`, not these two shapes. It is left unedited, and
  it carries no claim this change falsifies.

### F114 — low — a paired Larhold keeps its whole R.C.C. skill list, where the book keeps two skills

**Opened 2026-09-27**, from `F111`'s *Found while doing it* paragraph, per
`audit-menu` → *A deferral is work*. Filed, not taken.

**What the book prints.** South America 2 printed 186 (cache
`south-america-2` `txt/p186.txt` lines 40-48, read 2026-09-27) gives a Larhold
who takes an O.C.C. a narrow carry-over: *"In addition to the specific O.C.C.
skills, all Larhold will have Riding: War Bison (same basic level as
Horsemanship at +10%), and W.P.: Archery and Targeting."* The R.C.C. Skills
list below it (lines 50-70) is the kit of a Larhold who takes no O.C.C. The
stored class says the same: `larhold-barbarian`'s `extraction_notes` SKILLS
paragraph ends *"in a pairing the race's whole R.C.C. skill list unions onto
the O.C.C.'s, which grants more than that sentence names - recorded, not
modelled"* (`node scripts/q.mjs --remote --json "SELECT class_id, status,
markdown FROM imported_classes WHERE class_id LIKE '%larhold%'"`, 2026-09-27;
all three Larhold classes are `published`, none deleted).

**What the app does.** `combineClasses` unions the race's named `occ_skills`
onto the occupation's, higher base winning, unless the occupation carries
`supersedes_race` (`apps/character-creator/js/parser.js:1347-1359`, read
2026-09-27; `pastLife` at line 1349). Choice groups are never merged, so both
classes' groups survive side by side (line 1351). Measured by importing the
real `parseClassMarkdown` and `combineClasses` and composing the production
markdown of `larhold-barbarian` with `larhold-shaman` (session scratchpad
`pair.mjs`, 2026-09-27): the race states 11 `occ_skills` entries, the Shaman
11, and the pairing **16**. Against the book's two-skill carry-over, the paired
Shaman gains Detect Ambush 40, Detect Concealment 35, a W.P. of choice, a
**second** `Language: Other` pick, **both** `Hand to Hand: Expert` and
`Hand to Hand: Basic` as named entries, and Wilderness Survival at the race's
45 over the Shaman's 35. **Riding: War Bison composes to 70**, the R.C.C.'s +20%, over the
Shaman's own 60, where the sentence above prints Horsemanship +10% for exactly
this case. How the wizard resolves two named Hand to Hand entries was not
measured.

**Whether this is class data or a pairing rule: a pairing rule, with no class
lever.** The union is `combineClasses` behaviour, not anything the Larhold row
says. The only per-class switch is `supersedes_race` on the **occupation**
(`.claude/skills/class-import/reference/frontmatter.md:390-406`, read
2026-09-27), which would also hand the pools, money and `xp_table` to the
occupation and drop the two skills the book keeps, so it is the wrong shape. A
grep of `apps/character-creator/js/*.js` and `scripts/class-check-lib.mjs` on
2026-09-27 for any race-side key naming skills kept or dropped in a pairing
(`rcc_only`, `race_only`, `when_paired`, `in_pairing`, `paired_skills`,
`keeps_in_pairing`, `standalone_only`) returned nothing, and the frontmatter
reference's pairing rules (the same lines) name none. So the Larhold row cannot
state this today.

**A settled decision this does not reopen.** `F11` (now in
`BOOK-INGEST-AUDIT.closed.md`, heading at line 1159) chose union as the
default on purpose - *"a dragon that studies an O.C.C. is still a dragon"* is
how `frontmatter.md:391-392` states it - and the books back that for most
races: a grep of every cached book's `txt/p*.txt` on 2026-09-27 for *"in
addition to ... O.C.C. skills"* matched eight pages across five books (`cb1`,
`cwc`, `potm`, `south-america-2` p155, `spirit-west`), and every matched line
reads as a race whose skills ADD to an occupation's. The Larhold prints the
opposite, a race list that yields except for two skills. So the default stays;
this is one more race-side opt-in beside `F111`'s `yields_to_occupation`.

**Proposal:** add an R.C.C. key, e.g. `pairing_skills`, listing the race's
`occ_skills` that survive a pairing, each optionally with its own base where
the book prints a different figure for the paired case. `combineClasses` unions
only those (and still nothing, under `supersedes_race`) when the race declares
the key; a race without it composes as today. `parseClassMarkdown` refuses the
key on an O.C.C. and refuses a name the race's own `occ_skills` does not hold.
Set it on `larhold-barbarian` as Riding: War Bison at the Horsemanship +10%
base, and W.P. Archery, and rewrite that class's SKILLS note to past tense
citing this finding. Before setting it anywhere else, a taker searches every
race's stored text and every cached book for the same conditional, the way
`F111`'s taking found its four races.

**Posture:** opt-in per race. No race that does not declare the key changes,
no new gate, and the union default `F11` chose stays.

**Evidence:** the book sentence, the stored note and the 11 + 11 → 16
composition were read and run 2026-09-27 as cited above. **Not measured:** how
many other races print a partial carry-over like this one; the eight-page grep
matched only the additive wording, and a partial one phrased differently would
not match it. Also not measured: how many published occupations pair with
`larhold-barbarian` (its money half moved 154 pairings under `F111`, which
bounds it from below for occupations stating money).

**Confidence:** high that a paired Larhold holds more than the book grants,
and that nothing in class data can say otherwise today. Low on whether a
general key earns its place over a one-race answer, until a taker runs the
search the proposal asks for; if the Larhold is alone, a narrower fix (or
declining, and leaving the note as the record) should be weighed.

**Ongoing cost:** one more race-side key for `parseClassMarkdown`,
`class-check` and the frontmatter reference to know, and one more branch in
the skills merge that `F11`'s smoke coverage of `pastLife` has to cover. If the
search finds the Larhold alone, that cost is carried for one class, and this
finding should say so and consider declining.

**Taken, 2026-09-27 (branch `pal/fix/book-ingest-audit-f114-larhold-skills`)**,
as proposed. Posture said back: **opt-in per race.** No race without the key
changes, there is no new gate, and the union default `F11` chose stays.

- **What was built.** A new R.C.C. key, `pairing_skills: [{ name, base?, note? }]`.
  `combineClasses` reads it through `racePairingSkills` (`apps/character-creator/js/parser.js`).
  In a pairing, only the race's listed named `occ_skills` carry over, with the
  key's `base` and `note` laid over the race's entry. The race's choice groups
  do not carry. The higher base still wins a skill that both halves grant, and
  a superseding occupation still keeps none of them.
- **What the parser refuses:** the key on an O.C.C., a name that the race's
  own `occ_skills` does not hold, a repeated name, any field other than
  `name`, `base` or `note`, and a `base` that is not a number.
- **Where else it is recorded.** `class-check` has it in `KNOWN_KEYS`. It is
  documented in `apps/character-creator/docs/race-and-occupation.md` and in
  the class-import frontmatter reference.
- **Checks.** A new smoke section has 10 checks. Seven went red with the merge
  and the validator disabled; the other three are guards. Regression pins the
  carriers by name, checks every legal pairing of each, and checks the Larhold
  Shaman and ley line walker figures.
- **Data.** `~041-f114-larhold-pairing-skills.sql` sets the key on
  `larhold-barbarian` and rewrites that class's SKILLS note in past tense.
  The coordinating session reserved the number.

**Two premise corrections, from the `audit-premise-auditor`, 2026-09-27.**

1. **The paired War Bison figure is 50, not 60.** The evidence paragraph above
   sets the composed 70 against the Shaman's 60, "where the sentence above
   prints Horsemanship +10%". But the catalog row `Riding: War Bison` has base
   50 (`apps/character-creator/db/add-a-south-america-2-skills.sql:79-80`,
   production agreeing, read 2026-09-27). That base is already Horsemanship:
   General's 40 plus the sentence's +10. The proposal's "at the Horsemanship
   +10% base" reads the same way. Nate chose 50 on 2026-09-27. The Shaman's 60
   is its own printed line, and it still wins that pairing by the
   higher-base rule.
2. **The eight-page count does not reproduce.**
   - A one-line `grep -liE "in addition to .*O\.C\.C\. skills"` over
     `.cache/books/*/txt/p*.txt` matched 14 pages in six books.
   - A version that allows the phrase to wrap matched 25 pages in seven books.
     That includes `south-america-2` p186 itself, which a one-line grep cannot
     see, because the sentence wraps.
   - The conclusion held: every matched page read is additive.

**Wider than written, on Nate's word (2026-09-27).** The key also keeps
`Language: Larhold` at the race's 98. The printed sentence names only War
Bison riding and W.P. Archery. A census on a production snapshot of the 525
published classes, same day, measured what the two-skill key would do:

- **The language:** 188 of the 189 legal Larhold pairings lost the language.
  Only 89 of those occupations grant a generic `Language: Native Tongue`.
- **The numbers with the three-skill key:**
  - The pairings average 17.33 fixed-skill entries, against 23.74 before.
  - Pairings that hold two named Hand to Hand skills fall from 111 to 1.
  - No pairing loses the language.

**The search the proposal asks for found the Larhold alone.** It was a
wrap-aware search with five patterns (additive wording, "regardless of
O.C.C.", "retain the following skills", "in place of the R.C.C.") over every
cached book's `txt/p*.txt`, run 2026-09-27. It returned 15 page hits:

- **13 are additive:** `cb1` p080, p081, p083, p088, p138, p140 and p152;
  `cwc` p204 and p206; `pf` p088; `potm` p167; `south-america-2` p155;
  `spirit-west` p097.
- **One is unrelated:** `phase-world` p026 lets a race trade related skills for
  spells, which is not about pairing.
- **One is this finding's own page:** `south-america-2` p186.
- **Stored race markdown:** a sweep found only `larhold-barbarian`'s own note.

So the key is carried for one class, which is the case **Ongoing cost**
says should consider declining. It was built as the finding proposes because
the take was as written. Declining it at merge stays open to Nate.

**Found while doing it, and dropped rather than filed.** The race's
`skills.hand_to_hand` price list (martial arts or assassin for one skill) is
still the fallback for an occupation that states none. That is the `h2h` line
in `combineClasses`, and `pairing_skills` does not touch it.
- The same census counts 22 such Larhold pairings. In 17 of them the
  occupation grants a named Hand to Hand.
- In those 22, the race's "Expert can be changed" price applies even though
  the race's Hand to Hand: Expert no longer carries over.
- It is recorded here, not numbered, because this take was limited to this
  section. Nate can number it.

### F115 — low — two classes hold the light body armour placeholder that `fix-category-gear-rows.sql` exists to replace, and since `F105` the repo holds it too

Filed 2026-09-27 by `F105`'s take, which deferred this rather than folding it
into its sync. Not taken in the PR that files it.

`fix-category-gear-rows.sql:56-63` turns the exact line
`  - { item_id: "light-mdc-body-armor", qty: 1 }` into a `choose:` of four
real suits, because that row is a category and not something a character can
hold (the file's comment at line 55). `psi-tech` and `zenith-moon-warper` were
imported live after it ran, so production kept the placeholder line. A rebuild
used to run the fix after their `add-*` scripts and hold the choose block.
`~042-f105-sync-repo-to-production.sql` brought the repo up to production, as
`F105`'s policy requires, so **both environments now hold the placeholder** for
these two classes.

`sailor` and `oracle-cat` also cite the row by `item_id`, each with its own
`label:` or `note:` (`q.mjs --remote`, 2026-09-27). The fix's exact-line match
cannot see either, and the attached text reads as the book's own item. That
may be deliberate. `totem-warrior-south-american` names the slug inside a
choose list. `apps/character-creator/REBUILD-AUDIT.md`'s `F22`, closed without
being taken on 2026-09-27, records the same five classes.

**Proposal:** one data script that sorts after `~042`, applying
`fix-category-gear-rows.sql`'s replacement to `psi-tech` and
`zenith-moon-warper` by `class_id`, guarded on the placeholder line, and
applied `--remote` before the merge. `sailor` and `oracle-cat` stay out of it
unless Nate says their labelled lines should become choices too.
**Posture:** changes production, on the fix script's stated rule, in a script
of its own, which is what `F105`'s policy asks of a correction.
**Evidence:** the five citing classes, `q.mjs --remote`, 2026-09-27. The two
classes' diff, from a rebuild at `b62d4727` against production, 2026-09-27.
**Confidence:** high on the two classes. Low on whether `sailor` and
`oracle-cat` should change. What would raise it: their printed equipment pages.
**Ongoing cost:** none.

**Taken, 2026-09-28 (branch `pal/data/book-ingest-audit-f115-armor-choice`),
on Nate's word, after `F105` (#1500) merged.** Posture held. This changes
production, on the fix script's stated rule, in a script of its own:
`~043-f115-light-armor-choice.sql`. `sailor` and `oracle-cat` are left alone.

**One premise was false, and the obvious implementation would have done
nothing.** The proposal says to apply the fix's replacement "guarded on the
placeholder line". The fix's own guard also requires all four options to be
rows in `gear` (`fix-category-gear-rows.sql:63`), and today only two are:
- `merge-rifts-armor-duplicates.sql:114-140` retired `plastic-man-body-armor`
  and `urban-warrior-body-armor` into `catalog_redirects` (live since
  2026-08-23).
- So a copy of that guard is a silent no-op in both environments.
- `~043` counts an option as present when it is a gear row or a redirect to
  one.
- It keeps the fix's option text, because 37 live classes carry the retired
  slugs in their choice lists and they resolve through the redirects.
- It does not re-insert the retired suits, which regression's *the duplicated
  armour rows are gone* forbids.

**A smaller error, in the finding above:** the fix's comment is at line 56, not
55.

**The book agrees.** Psyscape prints a generic light suit for both classes
(OCR cache `psyscape/txt/p077.txt` and `p141.txt`, printed 77 and 141), which
is the category-not-item case the fix exists for.

**What moved in production.** `~043` was applied `--remote` via `d1-apply.mjs`
on 2026-09-28. All three read-backs held: every option resolves (4), both
classes hold the choice (2), and `sailor` and `oracle-cat` are untouched (2).
`imported_classes` was dumped in full before and after:
- 527 of 529 rows are identical.
- `psi-tech` differs at markdown line 113 and `zenith-moon-warper` at line 90.
  Each line is the placeholder turned into the choice, plus `updated_at`, and
  nothing else.

**Citations:**
- `node scripts/audit-citations.mjs --remote F115`: no live class note cites
  it.
- A tree grep finds three citations:
  - `F105`'s decision table and `~042`'s header. Both are records of the
    sync, and both say the correction is filed here, which stays true.
  - memory `repo-rebuilds-names-not-values` ("F115 was the first"), which is
    also still true.


## Filed from the Rifts Japan import, 2026-09-30

### F116 - low - a class cannot pick one ability from a named list at set levels, so three Rifts Japan classes carry their later mystic martial arts picks as prose

Rifts World Book 8: Japan prints 19 mystic martial arts powers (printed
195-198: six Arts of Invisibility, seven Body Hardening Exercises, six
Zenjoriki powers), and three of its classes pick from them on a schedule:

| class | picks, as its page prints them |
|---|---|
| `mystic-ninja` (printed 53) | one art of invisibility at levels 1, 3, 6, 9, 12 and 15 |
| `bishamon-fighting-monk` (printed 56) | an art of invisibility at 3, a body hardening exercise at 4 and 10, a zenjoriki power at 14 |
| `sohei-warrior-monk` (printed 59) | a body hardening exercise at 1, 5 and 9, a zenjoriki power at 14 |

What the import stored (branch `pal/data/japan-traditional-classes`, decided
with Nate on 2026-09-30, survey *Agreed with Nate* item 3): a level-1 pick is a
`special_abilities` entry with `choose: 1` over the powers, each carrying its
unconditional bonuses; every later pick is a `level_progression` line and a
body section paraphrasing the powers. `demon-queller`, `yamabushi-mountain-priest`
and `tengu` are granted their powers outright and are not affected.

**Evidence.** Measured 2026-09-30: `grep -n "abilities_schedule" apps/character-creator/js/parser.js`
returns one hit, `parser.js:3316`, and it is the super-ability block's
refusal of a per-level grant (there is nowhere to bank one). No schedule key
exists for `special_abilities`. The three drafting agents each looked for one
independently and reported the same.

**Proposal:** give `special_abilities` a level schedule the way skills and
spells have one - a `choose` group that fires at named levels and banks a
pick the level-up step spends, drawing from the same named options as the
level-1 group - and move these three classes' later picks onto it. The
banking is the work: `pending_power_picks` has no column for an ability
option list (the same reason `parser.js:3309-3315` gives for refusing it on
super abilities), so it needs one, per `schema-change`. **Posture:** a
capability, opt-in per class; nothing that exists changes until a class
states the new key. **Evidence for the proposal:** inferred from the parser
and the super-ability note; the level-up path was not traced.

**Confidence:** medium - high on the gap (measured), medium on the cost,
until someone traces how a banked pick reaches the level-up step
(`js/leveling.js`) and what the sheet shows for an ability picked at level 5.

**Ongoing cost:** one more schedule shape for the parser, the level-up step
and the sheet to keep in step with the skill and spell ones. Three classes
use it today. If no other book needs it, prose may be the cheaper answer
forever; say so if taking it.

**Adjusted 2026-09-30 (branch `pal/data/japan-monsters`):** a fourth class
has the same shape. `dragon-hatchling-asama-tatsu` (printed 215) takes a
zenjoriki power at levels 2, 7, 12 and 20, with no level-1 pick, so all four
are prose, and its notes cite this finding. `dragon-hatchling-kumo-mi`
(printed 214) takes one art and one zenjoriki power with no level named; it
stores both as level-1 picks and is not affected.

## Filed from the Rifts China 2 import, 2026-10-02

### F117 - low - a Mystic Martial Art Power is a fifteen-level progression a class advances in, and only its level-1 abilities are stored

Rifts World Book 25: China 2 prints 11 Mystic Martial Art Powers (printed
25-41): Ba Gua, Bok Pai, Gui Long, Hsien Hsia, Mien-Ch'uan, Pao Chih, She
Shen, Tien-Hsueh, Tong Lun, Xian Pu and Xian Tai Chi Chuan. Each is a table of
named abilities, I.S.P. and S.D.C. additions and combat bonuses from level 1 to
15, learned whole and advanced in as the character levels - a martial-arts
equivalent of a class's own `level_progression`, but shared by many classes.
The China 2 classes that learn one either pick it (`choose: 1`) or are granted
it, and some begin it at a level other than the power's first (the
Enlightened Demon learns one at its own tenth level and starts it at the
power's tenth).

What the import stored, by Nate's decision on 2026-10-01 (survey
`apps/character-creator/docs/surveys/china-2.md`, *Agreed with Nate* items 1
and 2): each power is a `special_abilities` entry describing its **level-1**
abilities only, pasted into every class that offers it from one shared block;
levels 2-15 are not stored anywhere and each class's `extraction_notes` cites
this finding. The Body Hardening Exercises' later picks (printed 92-94, picked
at set levels by the three Demon Queller classes) are the `F116` shape and are
prose under that finding, not this one.

**Evidence.** Measured 2026-10-02 against production: no `special_abilities`
entry carries a per-level table; `level_bonuses` exists only on `skills` rows,
where a hand to hand style uses it, and a style is limited to one per
character by `js/hand-to-hand.js`, so a power stored as a skill would collide
with the style the same class grants. The 11 powers' level 2-15 entries were
extracted (survey step 6; scratch JSON, not committed) and are in the book.

**Also met, and the same gap's neighbour:** the Nei Chia Wu Shih (printed
48-51) is taught two hand to hand styles at once - Eighteen Weapons and one
empty-hand style - and the app keeps one style per character, so the second is
a `special_abilities` choice applied by hand.

**Proposal:** a catalog home for a named, shared, levelled ability - a
`martial_art_powers` table, or `skills` rows of a new kind that
`hand-to-hand.js` does not treat as a style - carrying `level_bonuses` and
per-level ability text, which a class grants by name with an optional starting
level. **Posture:** a capability, opt-in per class. **Confidence:** medium on
the gap (measured), low on the cost (not traced through `leveling.js` or the
sheet). **Ongoing cost:** a third levelled-ability shape beside skills and
spells. If prose stays acceptable, closing this as declined is a fair answer.

## Filed for the book-retrospective close-out, Phase B, 2026-10-04

Nate's ruling 3 on the 2026-10-03 retrospective was to implement its code
items, each as a finding taken through the premise auditor, one PR each. These
are those findings, in the close-out plan's order.

### F118 - low - a race that rolls psionics on its OWN table is still sent to the standard Random Psionics roll, and the one class that avoids it is told it has no psychic potential

A book that gives a race its own psionics odds (*"01-77 none, 78-90 minor
..."*) is stored as a pick-one ability group whose options carry `psionics`
blocks, with a "None" option that carries nothing. Picking a psionic option
puts a `psionics` block on the composed class, and `rollsForPsionics`
(`apps/character-creator/js/psionics.js:124`, read 2026-10-04) then returns
false. Picking "None" leaves no block, so the Powers step offers the standard
table as well: a Dolphin who rolled "None" at 77% may roll again at 25%.

**Evidence.** Measured 2026-10-04 against production (`--remote`, the 725
published classes read through `parseClassMarkdown`, each no-psionics option
of each pick group applied with `applyAbilities` and asked
`rollsForPsionics`): nine classes have a pick-one group with a psionic option
and an option named *None*, and still roll after *None* is picked - `dolphin`,
`killer-whale`, `sea-titan`, `nautyll-soldier`, `arkhon`, `amaki-stone-man`,
`mutant-rat`, `momano-headhunter`, `larmac`.

**The working answer is already in the catalog.** `nb-doppleganger` states
`psionics_allowed: false` on the class beside its *Awakened Psionics* group
(`apps/character-creator/db/add-nb-doppleganger-class.sql:35` and `:51`, read
2026-10-04). The same measurement shows it never rolls, picked or unpicked,
and its psionic options still grant their blocks, because `applyAbilities`
merges an option's `psionics` without asking the flag. It is also the more
correct shape than a flag on the *None* option, which the close-out plan's
wording (*"a None option switches off the step"*) presumed: a race with its
own table does not use the standard one before the player has picked, either.

What is wrong around that answer, both read 2026-10-04:

- **The Race briefing says the opposite of the book.** `app.js:1314` prints
  *"none — this race has no psychic potential"* for any class stating
  `psionics_allowed: false`, which is false of a race with a 40% chance.
- **Nothing but the wizard honours the flag.** `withRolledPsionics`
  (`js/psionics.js:79`) returns early only for a class with a `psionics`
  block, so a request carrying `psychic_tier` for a troll is given a tier by
  `functions/api/character-creator/characters.js:197-228`. Production holds no
  such character (`--remote`, 2026-10-04: no row with a `psychic_tier` on a
  class stating the flag).
- **Nothing tells an importer.** `class-check` is silent on the nine.

**Proposal:** (1) the briefing prints that the race rolls on its own table
when the class states `psionics_allowed: false` and offers a psionic ability
option; (2) `withRolledPsionics` returns the class unchanged when
`rollsForPsionics` is false, so the server and the sheet refuse a rolled tier
the wizard would not have offered; (3) `class-check` warns on a class that
still rolls while holding a pick group with a psionic option and an option
named *None*; (4) the docs say that `psionics_allowed: false` is how a race's
own table replaces the standard one. **Posture:** no new key, no new gate; one
warning, which moves no exit code; no class is edited here - the nine take
the flag as data, in the close-out's package C5. **Evidence for the
proposal:** the gap and the working shape are measured as above; the briefing
and server halves are read from the lines cited, not exercised.

**Confidence:** high on the gap; medium on the warning's precision until C5
reads each of the nine pages - `nautyll-soldier` and `momano-headhunter` have
options that are neither psionic nor *None*.

**Ongoing cost:** one name-matched warning in `class-check` (a *None* option
spelled another way is missed, which is the safe direction).

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f118-own-psi-table`).**
Posture said back: no new key, no new gate; one `class-check` warning that
moves no exit code; no class edited. Written and taken in one session on Nate's
standing word for the close-out, so the premise auditor ran before any code.
It settled fourteen premises and disagreed with two, both corrected in the
build rather than in the text above:

- **The flag only worked from the race slot.** `combineClasses` starts from the
  race's keys and did not carry an occupation's `psionics_allowed`, so
  `momano-headhunter` (an O.C.C., one of the nine) would still have rolled when
  paired, and `yamabushi-mountain-priest`, the one occupation already stating
  the flag, rolled as a human's occupation (measured by the auditor against
  production, 2026-10-04). The build carries the occupation's `false` into the
  pairing. That is a behaviour change for one live class, in the direction its
  own frontmatter states.
- **No option is named exactly *None*.** They are band-prefixed -
  `Psionics (01-77): None` - so the warning matches the word, not the name.
  Re-measured: the word match returns the same nine.

Built: `abilityOffersPsionics` and `psionicsTableLeftRolling` in
`js/parser.js`; `withRolledPsionics` asks `rollsForPsionics`; the Race briefing
line; the `class-check` warning; twelve smoke checks under *Variant skills &
psionic penalty*, two of which were seen to fail with the two code lines taken
out. Production holds no character with a `psychic_tier` at all (auditor,
`--remote`, 2026-10-04), so the server half moves nobody. The briefing was read
off the running wizard on a port of this tree's own (`nb-doppleganger` against
`nb-wampyr`); the Browser pane was hidden, so that is the DOM's text and not a
screenshot. No class note cites this finding
(`node scripts/audit-citations.mjs --remote F118`: 0).

### F119 - low - a dice bonus cannot be negative, and a chosen ability cannot restate or raise the Horror Factor the character projects

Two things a pick-one result prints that the option cannot carry, so both are
"do it by hand" prose on live classes.

**A reduction rolled on dice.** `DICE_BONUS` (`apps/character-creator/js/parser.js:2007`,
read 2026-10-04) is `^\d+\s*d\s*\d+...`, so `"-1d6"` is refused where `-2`
is accepted: measured 2026-10-04, `isDiceBonus('-1d6')` is `false`, and a class
with `bonuses: { attributes: { ME: "-1d6" } }` fails to parse with *"must be a
number or a dice expression"*. `felinoid` (production, `--remote`, 2026-10-04)
carries five strains whose reductions are prose for that reason - *"Not
applied, so do it by hand: reduce I.Q. by 1D4"* - while the same options'
added dice are applied.

**The projected Horror Factor.** `applyAbilities` folds an option's `bonuses`,
`psionics`, `magic`, `super_abilities`, `talents`, `related_skills_count` and
`mdc_from_hp_sdc` (`js/parser.js`, the function's body, read 2026-10-04) and
not `horror_factor`, the class's display-only projected factor
(`BOOK-INGEST-AUDIT` F75). `felinoid` stores 9 and says 10 for the four larger
cats in a restriction line; `oni-of-the-one-hundred` stores 11 and twelve of its
thirteen head shapes add +1 to +4 *"by hand"* - seven print +2 (13), two +1
(12), two +3 (14), one +4 (15), and the human head adds nothing (production,
`--remote`, 2026-10-04).

**Signed dice were measured once before.** `apps/character-creator/RETRO-AUDIT.closed.md:984-988`
(read 2026-10-04) records that a leading sign is a hard parse error and that
the wormspeaker's `-1D4 Spd` therefore cannot be stored. That is a
measurement, not a decision against; this proposes the minus only and keeps a
leading plus refused.

**Proposal:** (1) a dice bonus may carry a leading minus - `"-1d6"`,
`"-2d4x10"` - in `attributes`, `combat`, `saves` and `pools`, rolled once and
stored as the negative number, with every pool bound read the right way round;
an equipment quantity, a catalog `dice` field, `attribute_dice` and
`saves.other` (whose dice nothing rolls today) stay unsigned. (2) An ability option may
carry `horror_factor` (a number or the book's phrase, as on a class), which
replaces the class's while the option is held, and `horror_factor_bonus` (a
whole number, may be negative), which is added to a numeric factor and summed
across picks. Both are display-only, as F75 made the class's. **Posture:** a
capability, opt-in per class; nothing that exists changes; no class is edited
here except test fixtures - Felinoid and the Oni are the close-out's package
C1. **Evidence for the proposal:** the two gaps are measured as above; the
rolled-bonus storage path (`attribute_bonuses`, `rolled_bonuses`) was read, not
exercised, before the build.

**Confidence:** high on both gaps. Medium that nothing downstream assumes a
rolled bonus is positive, until the build walks `dice.js`, `derive.js`, the
wizard's roll and the server's bounds.

**Ongoing cost:** one more sign in the dice grammar, and two option keys the
sheet must keep reading. Small.

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f119-negative-dice-hf`).**
Posture said back: a capability, opt-in per class; nothing that exists changes;
no class edited. Written and taken in one session on Nate's standing word for
the close-out, so the premise auditor ran before any code: eighteen premises,
thirteen held, and its five disagreements are in the text above (the Oni
count, the earlier RETRO-AUDIT measurement, `saves.other`) or here:

- **There is no server range check on a rolled attribute, combat or save
  bonus**, only on pools. `validate-character.js` never reads
  `attribute_bonuses` or `rolled_bonuses`, and adding a check would be a new
  gate. So the bounds that could invert were the pool ones, and all of them go
  through `poolFormulaBounds`: the validator's `pool_out_of_range`,
  `convertedMdcBounds`, and the second form's `checkRolls`.
- **`horror_factor` already means "add" on a `traits` row.** The option keys
  follow the class and the variant instead, where it replaces; the parser
  comment and `docs/leveling.md` say which precedent was taken.
- **The wizard never displayed a class's Horror Factor**, so there was no
  Review cell to update. The picker now tags an option that carries either key;
  the sheet's card reads the composed class and needed no change.

Built: `evalDiceBonus` and `diceBonusBounds` in `js/dice.js` (`DICE_EXPR` is
untouched, so nothing is rolled on `-3d6`); `isSignedDiceBonus` in
`js/parser.js`, with `isDiceBonus` left unsigned for quantities and the catalog
`dice` field; the wizard's and the NPC generator's bonus rolls; the second
form's dice paths; `horror_factor` and `horror_factor_bonus` on an ability
option, folded by `applyAbilities`. Twenty-five smoke checks, nine of which
were seen to fail with three faults injected (the bounds inverted, the fold
removed, the validator left unsigned).

Measured 2026-10-04, `--remote`: all 725 published classes parse under this
branch, and no ability option in production carries either key, so nothing
that exists changes. Not done, by posture: no floor under an attribute or a
pool a reduction takes below zero (a flat negative bonus has none either), and
the derived `horror-factor` tag still reads the class and its variants only.

**For the data that follows (package C1):** `felinoid`, `oni-of-the-one-hundred`
and `wormspeaker` carry notes this makes stale by subject, not by citation
(`node scripts/audit-citations.mjs --remote F119`: 0). The auditor's GLOB for
dice reductions in production prose returned twelve classes to read: juicer,
stone-master, murder-wraith, symbiotic-warrior, wormspeaker, pseudo-men,
felinoid, psi-nullifier, lanotaur-hunter, psi-goblin, songjuicer,
forest-warden. Not each was read.

### F120 - medium - a table a book rolls on MORE THAN ONCE has no shape, and a result that sets an attribute's dice cannot say so

Nate's ruling 10 on the 2026-10-03 retrospective (2026-10-04): **one general
roll-table mechanic, designed once** - a pick group rolled `rolls: N` times,
N a number or dice, a duplicate rerolled, its options allowed to carry
`attribute_dice` and negative dice. Negative dice are F119. This is the rest.

**What exists.** A pick-one group whose options are named for percentile bands
gets a Roll d100 button (`abilityRollBands`, `apps/character-creator/js/parser.js`,
read 2026-10-04). Its first line returns null unless `choose` is 1, and smoke
pins that (*"nor is a group with no bands, a choose-2 group, or a named
ability"*, `apps/character-creator/test/smoke.mjs`, read 2026-10-04). The roll
handler (`rollAbilityGroup` in `app.js`) clears the group and takes one result.

**What the books print, and what production holds for it** (`--remote`,
2026-10-04, each class's markdown read):

- `pseudo-men`: *"Roll 1D4 times on the Random Unusual Abilities and Oddities
  table"*, a repeated result rerolled - 19 rows by its own note, 21 bands in its
  stored body, where Third Eye is three of them. Its note: *"Not stored as
  mechanics: the frontmatter has no random-table construct, and a fixed choose
  count would state a number the book rolls."* The whole table is body prose.
- `amphib`: seven Appearance rows, each setting the P.B. dice (3D6, 3D4, 2D6,
  2D4, 1D6). The group exists and rolls; every row but the first says *"P.B. is
  3D4: re-roll it by hand, the sheet rolls 3D6."*
- `oni-of-the-one-hundred`: its Legs table *"sets the Spd attribute"*, and the
  class stores the 6D6 that four of the eight results print.

**A decision this argues past.** The comment above `ABILITY_GRANTS` in
`js/parser.js` (read 2026-10-04) says: *"a chosen ability that could restate
attribute_dice or starting_money is not an ability, it is a second class
wearing one's name."* <!-- claim-ok: quoting the comment this finding argues past -->
That was written for the Godling's eleven powers, which are bonuses. A table
row that prints *"P.B. 2D4"* is not adding to the roll, it is the roll, and
ruling 10 names `attribute_dice` on an option outright. `starting_money` stays
out.

**An earlier finding on this subject was declined, and this does not reopen
it.** `F78` (text in `BOOK-INGEST-AUDIT.closed.md` under its own heading, read
2026-10-04) asked for a home for Nightbane's nineteen creation tables and was
declined on Nate's word on 2026-09-16; its note says tables that grant bonuses
are ability choice groups, and lists as residue a percentile range as data,
three-level nesting, and "roll twice and combine". The Morphus tables have
since been built as their own catalog (migration 068). This proposal stays on
the path that note endorsed - an ability choice group - and takes one piece of
that residue on Nate's later ruling 10: a table rolled more than once. The
range stays in the option's name, and nesting stays out. F78's note ends
*"Short of that, this is settled and should not be re-proposed"*; <!-- claim-ok: quoting the decision this finding argues past -->
ruling 10 is the later word, and it is for classes outside Nightbane.

**A roller of this kind already exists for one catalog.** `js/morphus.js`
(read 2026-10-04) rolls the Morphus tables several times and rerolls an entry
already held, keyed to `second_form` and the `traits` rows of migration 068,
which store routing between tables as data. It does not reach an ability
group, so this is the second roller, for the other mechanism.

**Proposal:**

1. **`rolls` on a pick group, in place of `choose`.** `{ rolls: 2, from: [...] }`
   or `{ rolls: "1d4", from: [...] }`. The options must be named for bands that
   cover 1-100 (a parse error otherwise: a table with a hole cannot be rolled
   N times). The group holds at most N picks, or at most the dice's maximum,
   each option once.
2. **The Roll button rolls the whole table**: the count first when it is dice,
   then that many d100s, rerolling any roll that lands only on a result already
   taken, and replaces what the group held. The rolls and the count stay on
   screen. Picking by hand still works, up to the same limit, because the
   books allow a G.M.-approved choice.
3. **The server counts a `rolls` group at its maximum** in the existing
   `ability_count` rule and refuses a second take of one row. It does not
   check that the count was really rolled: there is no column for the roll,
   and the picks are the record.
4. **An option may carry `attribute_dice`**, a map like the class's, which
   restates the class's dice for the attributes it names while the option is
   held. Folded by `applyAbilities`; the wizard re-rolls an attribute whose
   dice a pick changes, as it does for a variant.
5. A `choose` group is unchanged, the Roll d100 button on a pick-one group
   included.

**Posture:** a capability, opt-in per class; nothing that exists changes; no
new violation beyond the count and repeat rules a `choose` group already has;
no class is edited here except smoke fixtures - the tables are the close-out's
package C2. **Evidence for the proposal:** the gaps are measured as above. That
attributes are rolled from the composed class after the ability pick, and that
the server's attribute ceiling reads the composed class, was read from
`app.js` (`rollAttribute(S.cls?.attribute_dice...)`) and
`validate-character.js` (`cls.attribute_dice?.[attr]`), not exercised.

**Not proposed:** a per-band cap (*"at most one from 87-00"*, Pseudo-Men) stays
a note on the group; a result that is another roll on a sub-table stays prose
in its row, since an ability option cannot hold a sub-choice.

**Confidence:** high on the gaps. Medium on the cost until the build walks the
places that read `choose` (`abilityGroupCounts`, `takeAbility`, the validator's
`ability_count`, the NPC generator) and the attribute re-roll on a changed pick.

**Ongoing cost:** every reader of a group's limit has to ask one helper
rather than read `choose`; one more key on an ability option.

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f120-roll-tables`).**
Posture said back: a capability, opt-in per class; nothing that exists
changes; no new violation beyond the count and repeat rules a `choose` group
already has; no class edited. Written and taken in one session on Nate's
standing word for the close-out. The premise auditor checked eighteen
premises; twelve held, and its six disagreements are corrected in the text
above (the Pseudo-Men row count, the Morphus wording, F78's closing words) or
shaped the build:

- **Every reader of a group's limit reads `choose` directly** - the wizard's
  own group filter, the picker, `takeAbility`, the Race-step gate, the
  validator's count, the NPC generator, the sheet's G.M. dropdown. So `rolls`
  does not re-plumb them: **the parser fills `choose` with the most the group
  can hold** (the number, or the dice's ceiling), and a class that states both
  must make them agree.
- **That alone would have blocked the Race step**: its gate summed `choose`, so
  a Pseudo-Man who rolled 2 on 1D4 could not go on until four rows were held.
  The gate now counts per group and asks `abilityGroupOwed`, which for a dice
  count is the least the dice can come up. The rolled count is stored nowhere;
  the picks are the record.
- **A changed pick does not recompose**, so nothing cleared an attribute whose
  dice a row had set. `confirmRace` now captures the composed dice, recomposes
  and clears the attributes that moved, as a variant change does. A stage
  change after creation (`variant.js`) still proposes re-rolls from the
  variant alone, and under `supersedes_race` a held row's dice win over the
  "whichever is higher" merge; both are stated in `docs/leveling.md`.
- **The server refuses a repeated row only where the row is defined**, so the
  parser requires a definition for every row of a `rolls` group.

Built: `abilityRollLimit`, `abilityGroupOwed` and `rollAbilityTable` in
`js/parser.js`, with `abilityRollBands` now answering for a `rolls` group;
`attribute_dice` on an ability option, folded by `applyAbilities`; the
wizard's **Roll the table** button and its log; the NPC generator rolls such a
table instead of shuffling it. A band that prints two results is left to the
player, as a pick-one roll leaves it, and landing on it again counts as a
repeat. Thirty-two smoke checks, eleven of which were seen to fail across two
rounds of injected faults.

Measured 2026-10-04, `--remote` (auditor's census through this tree's parser):
725 published classes, none unparsable; `abilityRollBands` is non-null for 35
groups on 24 classes, as before; no group carries `rolls` and no option
carries `attribute_dice`, so nothing that exists changes.

Seen in the running wizard, on a port of this tree's own, against a fixture
class applied to this tree's local D1 only and deleted afterwards: the heading
and the gate (*"Choose 1 more power to continue"* on a 1D4 table), six rolls
of the table with their logs, P.B. rolled on a held row's 2D4 over 25 rolls
(2 to 8), a `-1d4` reduction from another row rolled and shown, and P.B.
cleared back to the class's 3D6 when the row was dropped and the race
confirmed again, Spd untouched. The Browser pane was hidden, so that is the
DOM's text and not a screenshot.

**For the data that follows (package C2):** the Pseudo-Men body lists 21
bands where its note says 19 rows, and several rows carry a nested Oddity
sub-roll, which stays prose in the row. `audit-citations --remote F120`: 0.

### F121 - low - the Draconid magician's P.P.E. needs no new mechanism, only the yield its race was told not to take

Phase World printed 36 gives the Draconid *"P.P.E.: 1D6x10 unless they use
magic"*, and a magician Draconid *"all the powers of a ley line walker plus a
bonus of 1D6x10 P.P.E."* The class (`draconid`, production, `--remote`,
2026-10-04) stores the first as a phrase in `ppe_base` and the
Magician-or-Psychic branch as one prose ability. The close-out plan filed this
as a code package: *an ability's pool bonus applied on top of the
occupation's base, without `yields_to_occupation`*, because
`apps/character-creator/docs/race-and-occupation.md` (the paragraph under *A
race may yield its P.P.E. or money to an occupation*, read 2026-10-04) names
`draconid` among the races that must not carry that key, as one that *"prints
its own mage figure"*.

**Measured 2026-10-04**, production's `draconid`, `ley-line-walker` and
`mind-melter` through `parseClassMarkdown`, `combineClasses` and
`applyAbilities`, with the race's `ppe_base` set to `1d6x10`:

| build | composed `ppe_base` | pool bonus |
|---|---|---|
| today's rules, Magician option carrying `pools: { ppe: "1d6x10" }`, paired with the Ley Line Walker | the race's `1d6x10` | `ppe: 1d6x10` |
| the same, with `yields_to_occupation: { ppe_base: [magic] }` on the race | the Ley Line Walker's `3d6x10+20 plus P.E. ...` | `ppe: 1d6x10` |
| Psychic option carrying `pools: { isp: "1d4x10" }`, paired with the Mind Melter (`occ_group: psychic`), with the yield | the race's `1d6x10` | `isp: 1d4x10` |
| unpaired and holding neither option, with the yield | the race's `1d6x10` | none |

The first row is wrong by the book and the other three are the book's
figures. So the "own mage figure" the exclusion protects is the yield plus a
pool bonus on the ability option, both of which exist. A yield alone would
have lost the 1D6x10, which is what the exclusion was right about.

**The decision this adjusts is `F111`'s, in this file.** Its text and its
outcome note (read 2026-10-04, under `### F111`) list `draconid` beside
`godling` and `true-inca` as races that print their own mage figure, which
is why the general rule was declined and why the race-side key was not given
to them. That reasoning holds for a yield alone and for the other two races;
this changes it for one race, with the bonus that makes its figure come out.

**Proposal:** lift the exclusion for `draconid`, by Nate's word (asked
2026-10-04 with both options; he chose this one over building an option-level
key). Correct the doc sentence that names it. No code. The class edit - the
yield, a clean `ppe_base`, a pick-one Magician/Psychic group with
`occ_options` - is the close-out's package C1, which also adds `draconid` to
the yielders regression pins by name. **Posture:** documentation only; no
class is edited here. **Evidence for the proposal:** measured as above.
**Confidence:** high on the arithmetic; medium on the class shape until C1
reads the page for whether the magician takes the Ley Line Walker's skills or
only its powers. **Ongoing cost:** none beyond one more pinned yielder.

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f121-draconid-yield`).**
Posture said back: documentation only; no class is edited here; no code. The
premise auditor re-ran the measurement and all four rows reproduced. It
checked eleven premises and disagreed with five, none of which moves the
posture; each is answered here or in the doc:

- **The yield reaches every magic occupation, not one.** 69 are legal for a
  Draconid in production, 71 with variants; all move, and thirteen can land
  below 1D6x10 at a low P.E. (auditor's census, `--remote`, 2026-10-04,
  `poolFormulaBounds` at P.E. 7, 17 and 27). The doc now says so, and says
  that `occ_options` on a required pick is what narrows the wizard's
  occupation picker to the two the book names. So the *Ongoing cost* above is
  understated: regression's every-legal-pairing loop will walk all 69.
- **A paired Draconid levels on the Ley Line Walker's experience table**,
  where its page says it uses its own either way: `xp_table` is
  occupation-first in a pairing. **This is not fixed and not filed as a
  finding**: it is recorded in the doc and in the close-out's status notes for
  package C1 to state in the class's `extraction_notes`, and for Nate to rule
  on if he wants a race to keep its ladder. The same pairing takes the
  occupation's related-skill count and money.
- **Five places named `draconid` this way, and two are corrected here.** The
  doc's yield section is rewritten. Its other mention, under *It is opt-in per
  occupation*, and the comment in `js/parser.js` beside `overrides_race`
  both describe what the declined GENERAL rule would have broken on
  2026-09-27, which is still true, and are left as the record. The
  instruction in `class-import`'s `reference/frontmatter.md` ("Never on a
  race whose book ... prints its own mage figure") is the one a taker would
  obey; a skill file is edited from the main checkout, so it is corrected in
  the close-out's skills PR and not here.
- **The paragraph was already stale on its count**: it said four carriers
  where production has six. `aardan-tek` and `arac` are added to its table
  from the pages regression's own comment cites.
- The fourth row of the table measured a Draconid holding no option; it says
  so now.

Nate's word was given in the session, 2026-10-04, to a question that put both
options with the measurement; it is not in any file but this one.
`node scripts/audit-citations.mjs --remote F121`: 0.

### F122 - low - a race cannot keep its own experience table in a pairing, and the Draconid's page says it does

Since 2026-09-17 an occupation's `xp_table` wins a pairing whenever it states
one (`apps/character-creator/js/parser.js`, the line
`if (occ.xp_table != null) out.xp_table = occ.xp_table;` in `combineClasses`,
read 2026-10-04), on Nate's call that day: a race's ladder is for the race
played alone. That is right for Nightbane, which it was decided for.

Phase World's Draconid prints the opposite for itself. Its Other Powers
paragraph (cache `p036.txt`, read 2026-10-04) gives a magician *"all the powers
of a ley line walker"* and a psychic those of a mind melter, and ends: *"In
either case, use the draconid's experience points table presented in this
book."* The same paragraph and the class's own R.C.C. skill list show the book
grants powers, not O.C.C. skills; the class is still to be written as a
pairing with the Ley Line Walker or the Mind Melter, because only a pairing
carries that occupation's P.P.E. formula and its own abilities (read
2026-10-04; `F121` left the shape open, and the read is recorded in the
close-out's status notes, not in a menu). Paired, it levels on the
occupation's ladder: production's `ley-line-walker` and `mind-melter` both
store 2,241 at level two against the Draconid's 2,201 (`--remote`,
2026-10-04).

**Proposal:** a race-side flag, `keeps_xp_table: true`, read by
`combineClasses`: a race that states it, and states an `xp_table`, keeps its
own ladder when paired with an occupation that states one. The parser refuses
it on an O.C.C. and warns on a race with no `xp_table`. A superseding
occupation (`supersedes_race`) still wins, because the character has stopped
being its race. Regression's invariant *"paired with an O.C.C. that states a
ladder, the occupation's wins"* exempts the carriers, and pins them by name as
it pins the yielders. **Posture:** a capability, opt-in per race; the rule for
every other race is unchanged; no class is edited here - `draconid` takes the
flag in the close-out's package C1. Nate's word, 2026-10-04 (recommendation 1
of sixteen, accepted). **Evidence for the proposal:** the page line was read
off the cache, not a render; production holds no class with the key
(`--remote`, 2026-10-04, `instr(markdown, 'keeps_xp_table')`: 0).

**Confidence:** high. **Ongoing cost:** one more race-side opt-in beside
`yields_to_occupation` and `pairing_skills`, and one more pinned list.

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f122-keeps-xp-table`).**
Posture said back: a capability, opt-in per race; the rule for every other
race is unchanged; no class is edited here. The premise auditor checked
fourteen premises; twelve held and two were attributions, corrected in the
text above. It confirmed there is one decision point (`combineClasses`, called
only from `composeClass`, with nothing after it touching `xp_table`), that a
variant restating the ladder needs no handling because `applyVariant` runs on
both halves first, and that production's `draconid` stores a ladder today.

Built: the flag in `combineClasses` and its validation in `js/parser.js`;
`keeps_xp_table` in `class-check`'s known keys; six smoke checks under
*Starting XP*, two of which were seen to fail with the two code lines
reverted; regression's pairing invariant exempts a carrier and holds it to the
opposite, and pins the carriers by name - an empty list today, which
`draconid` joins with its data. Three places that stated the old rule as
absolute now name the exception (two parser comments, `docs/leveling.md`).

Not done here: `class-import`'s `reference/frontmatter.md` still says a race's
ladder applies only when it is played alone; a skill file is edited from the
main checkout, in the close-out's skills PR. The flag is not a variant
override. Whether another race prints the same instruction was sampled, not
settled: the auditor matched four phrases across live race notes and read
eight contexts, finding only `draconid`.
`node scripts/audit-citations.mjs --remote F122`: 0.

### F123 - low - the Diabolist's wards have no catalog home, and a held spell from a tradition is headed "Spells" on the sheet whatever it is

Palladium Fantasy's Diabolist casts no spells; its magic is ward symbols
(cache `p121.txt`-`p135.txt`, read 2026-10-04; the symbols themselves run
`p128`-`p135`): ten kinds listed under *Ward
Symbols & Descriptions* - alarms, area affect, colors, conditions, inflict,
numbers, permanence, power, protection, trigger - each energised for one
P.P.E. (five for power, twenty for permanence). The class page says the
Diabolist *"knows all currently known power words"*: the symbols are learned
in the apprenticeship, not picked. Production's `diabolist` (`--remote`,
2026-10-04) carries no `magic` block; its note says *"there is no ward
catalog, so the mechanics are recorded as special abilities rather than faked
into the spell list"*.

Nate's ruling 9 on the 2026-10-03 retrospective: **the symbol catalog shown on
the sheet, no builder UI** for composing ward phrases. The plan left one thing
to this finding: a table of their own, or a spell tradition.

**An earlier scope decision this moves past.** `apps/character-creator/CLASS-AUDIT.md`
(its schema-limits paragraph and the re-verification beneath it, read
2026-10-04) records that *"the Diabolist's ward system"* <!-- claim-ok: quoting the scope decision this finding moves past -->
remains out of scope, and calls that a decision rather than a capability
check. Ruling 9 is the later word, and it takes the catalog half only: what a
ward phrase does when its symbols are combined stays with the G.M.

**A spell tradition, `ward`.** Measured 2026-10-04, `--remote`: `spells`
already holds 21 traditions beside 422 general invocations - warlock 231,
circle 64, bone 59, cloud 58, ocean 41, living-fire 39, shaman 34, tattoo 32
and thirteen more. `circle` and `tattoo` are the precedent for things nobody
casts. A row has what a symbol needs (name, P.P.E. cost, range, duration,
saving throw, area of effect, description, source); there is no general note
column, so a symbol's power words and components live in its description. The codex folds a tradition under
its own heading and splits it into families by name prefix
(`apps/character-creator/js/traditions.js`, read 2026-10-04), so `Alarm:
Silent`, `Condition: Agony` come out as the book's kinds with no code -
provided EVERY row carries a `Kind: ` prefix, since one bare name collapses
the split. A table would be a tenth catalog across the nine places
`schema-change` lists, for about 34 rows one class reads (22 conditions, 4
alarms, 2 protections and 6 single symbols, counted off the cache by the
premise audit).

**What the tradition does not get for free is the sheet.** A held power is
headed by kind and level - *"Spells - Level 3"*
(`apps/character-sheet/sheet.js`, the `group` expression in the power rows,
read 2026-10-04). `spells.level` is `NOT NULL DEFAULT 0`, so a Diabolist
granted the symbols would have them under *"Spells - Level 0"*, on a class
whose page says it cannot learn spell magic. Eight traditions in production
are stored wholly at level 0 and read that way today: circle, cloud, tattoo,
nazca, demonic-curse, african-ceremonial, spellsong and african-witch
(`--remote`, 2026-10-04).

**Proposal:** (1) the tradition gets its label, `ward` -> *Ward Symbols*, in
`js/traditions.js`. (2) The sheet reads each held spell's tradition off
the spell catalog it already loads, by name, and heads a held spell that has
one by the tradition's label - *"Ward Symbols"*, *"Warlock Elemental - Level
3"*, the level shown only where it is above 0 - with general invocations
still under *"Spells"*, and the tradition groups after them. (3) Docs. The Diabolist is then granted the
symbols by name through an ordinary `magic` block (`spells: [...]`), which is
data: the 32 rows and the class edit are the close-out's package C3.
**Posture:** no schema change, no new key; a display change on the sheet for
every character holding a tradition spell, which is a heading and an order,
not a number; no class or catalog row is edited here. **Evidence for the
proposal:** the census and the sheet's heading are measured as above; that a
class granted spells by name with no picks shows them in the wizard and on
the sheet without further work was read from `powersPayload` and the power
rows, and is to be exercised in the build with a local fixture.

**Confidence:** high that a tradition holds the rows; medium on the sheet
until the fixture is looked at. **Ongoing cost:** the sheet loads one more small script; a tradition added
later gets its heading with no further work.

**Taken, 2026-10-04 (branch `pal/audit/book-ingest-audit-f123-ward-tradition`).**
Posture said back: no schema change, no new key; a display change on the sheet
for every character holding a tradition spell, which is a heading and an
order, not a number; no class or catalog row is edited here. The premise
auditor checked sixteen premises; nine held and seven did not, and the text
above carries its corrections. Two changed what was built:

- **The sheet already had each spell's tradition.** The catalogs endpoint
  sends `tradition` on every spell row and the sheet keeps that catalog, so
  the proposed endpoint map was not needed and is not built. The cost is that
  a held spell since renamed in the catalog is not found by name and stays
  under *"Spells"*; the description lookup, which resolves redirects on the
  server, is unchanged.
- **The sheet did not load `js/traditions.js`.** It does now.

Built: `ward: 'Ward Symbols'`, `heldGroup` and `heldOrder` in
`js/traditions.js`; `spellTradition` and the two call sites in the sheet's
power rows; the script tag. Eleven smoke checks, five seen to fail with four
faults injected. The stored index every handler uses (`usePower(i)`) is
untouched by the new order, as the auditor confirmed.

Seen on the running sheet, on a port of this tree's own, against a character
made through the API in this tree's local D1 and deleted afterwards, holding
eleven real catalog spells: the headings read *Spells - Level 1*, *Spells -
Level 4*, *Circle*, *Magic Tattoos*, *Warlock Elemental - Level 1*, *Warlock
Elemental - Level 3*, each once, rows together, no console error. The Browser
pane was hidden, so that is the DOM's text and not a screenshot; print uses
the same heading element and was not rendered.

**Not done, by scope** (ruling 9 is the sheet): the wizard's Powers and Review
steps head a class's granted list *"Spells"*, the codex counts a fold as *"N
spells"*, and the *use* button deducts a ward's P.P.E. like any spell's.

**For the data that follows (package C3):** about 34 rows, every one named
`Kind: Name`; the catalogue runs cache `p128`-`p135`, past the range the plan
gave; power words and components go in `description`. The `diabolist` takes
`magic: { type: ..., spells: [...], spells_per_level: 0 }` - without the
`spells_per_level: 0` the sheet's level-up panel says the class does not record
how many spells it learns - and its note about there being no ward catalog
goes stale then. No class cites this finding
(`node scripts/audit-citations.mjs --remote F123`: 0).
