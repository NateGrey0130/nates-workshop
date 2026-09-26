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

- **F26** — one spell, two traditions, two costs, and one row — Taken, 2026-09-08 (PR pending), as the smaller option - `spells.same_spell_as` — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F26` heading.

- **F27** — `class-check` does not validate skill names inside an MOS option, and they fail silently — Taken, 2026-09-08 (PR pending). Both of the questions this finding left — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F27` heading.

- **F28** — the coverage ledger checks five catalogs and there are six, so no vessel's citation is verified — Taken, 2026-09-08 (PR pending) - filed and taken in one change, on the — full text in `BOOK-INGEST-AUDIT.closed.md` under its own `### F28` heading.

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
