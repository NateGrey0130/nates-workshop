# Importing from PDFs

The five importers, what the OCR does to a page, and the gear-price problems that
no amount of tuning fixes.

Part of the [character creator](../README.md) documentation.

---

## The PDF importers

They all live on `import.html`, admin only, behind five tabs: **Classes**,
**Skills**, **Spells**, **Psionics** and **Gear**. The last three are built from
`SESSION_CATALOGS` in `import.js`, so adding a sixth is a config entry rather
than a new tab.

The **catalog** importers — skills, spells, psionics and gear — share
one pipeline in `_lib/import-engine.js` — extract, normalise, classify against
the catalog, batch-confirm — with the per-catalog differences in `IMPORT_SPECS`
and the columns coming from the field config. A fix there is a fix for all of
them rather than the same fix four times. The **class** importer is a different
shape (one class, markdown out) and stays on its own path.

Both send the PDF to Claude as a **document attachment**, never as extracted text:
layout-preserving text extraction splices neighbouring columns together mid-line
on two-column sourcebook pages, destroying the column boundary before extraction
starts. Do not add a text pre-pass.

Server-side callers use `_lib/claude-client.js` **directly**. Never reach the
proxy by fetching the site's own `/api/claude` URL: in production Access
intercepts the subrequest and returns the login page as HTML, which surfaces as
a confusing empty-response error.

### Class importer

1. **Upload** a page range covering exactly one class.
2. **Extract** — returns the whole class as markdown.
3. **Autosave** — stored as a `draft` the instant it parses, so a closed tab
   never loses an extraction.
4. **Review** — the markdown in one editable block, `extraction_notes` in a
   banner, missing catalog references listed. `recheck` re-validates edits with
   no further API spend.
5. **Confirm** — publishes the class (live immediately) and creates stub rows
   for anything it references.

#### Retiring a class

Deleting a **published** class retires it: `deleted_at` is stamped, and it
vanishes from the creation wizard, the extraction prompt's examples, and the
saved-imports list. It does **not** vanish from anything that resolves a class a
character already has — `getStored()` and therefore the sheet, the GM dashboard's
roster labels, and the XP and level-up endpoints all deliberately ignore
`deleted_at`. The sheet shows a "Retired class" advisory so the state is visible
rather than mysterious.

Retired classes live behind a **Retired (n)** toggle in the saved-imports panel,
where a Restore button undoes it. There is no permanent delete for a retired
class, by design.

Deleting a **draft** is still a real delete — a draft is an in-progress
extraction, usually one being cleared on purpose, and keeping every discarded
attempt would turn the retired list into noise.

#### Writing a class by hand

Not every class is best got out of a PDF. An RCC with several age stages is
quicker to write than to extract and correct, and until recently there was no
way into the markdown editor without running an extraction first.

**+ Write one by hand** in the saved-imports panel asks for a name, whether it
is an O.C.C. or an R.C.C., a system and a source book, then opens the editor on
an annotated skeleton. The **Re-check** button re-parses and re-runs the catalog
cross-reference for free, so you can iterate against the validator without
spending an API call; **Confirm** publishes exactly as it does for an extraction.

Two things make the template worth having over an empty file:

- **It parses on arrival**, with no errors and no warnings. A template that
  failed validation the moment it was created would teach you nothing about
  which of your own edits broke it — which is why all five fields the parser
  requires are asked for up front rather than left blank.
- **The awkward blocks are shown commented**: `variants`, `bonuses`, skill
  choice-groups and gear choices. Those are the shapes nobody remembers, and
  they are the reason writing a class by hand is worth supporting at all.

#### Structured editors for the two awkward blocks

`bonuses` and `variants` get real UI above the markdown; nothing else does. They
are the shapes nobody remembers, and everything else in the frontmatter is
either obvious or prose.

The markdown stays visible and stays the source of truth. Editing a block
rewrites **only that block**, in place, so you can watch exactly what changed:

- **Bonuses are a flat table** of *(level, group, key, value)*. A bonuses block
  really is a list of those tuples — `at_level` is the same thing with a level
  attached — so one small table covers both, instead of a nested editor per
  group and another inside every `at_level` entry. Leave the level blank for a
  bonus the class has from the start.
- **Variants show id and name.** Their overrides (`attribute_dice`, the pool
  bases, per-variant `bonuses`) are edited in the markdown, and **survive a
  save**, because each block is rebuilt from its *parsed* value rather than from
  what the form displays.
- **A commented-out example is replaced, not duplicated.** The template ships
  `# variants:` as a worked example; appending a real block beside it would make
  the file appear to define the same key twice.

Comments *inside* an edited block do not survive — it is rebuilt from structure.
That is the right way round: the blocks worth a form are structure, and the
blocks worth comments are the ones this never touches. Regenerating the whole
frontmatter instead would have been simpler and would have destroyed every
comment in the file, which is most of what makes a hand-written class
approachable.

`import/recheck` returns the parsed frontmatter as `data`, so the editors can
read `bonuses` and `variants` without a YAML parser of their own — `import.js`
is a classic script and `parser.js` is a module it cannot import.

There are two templates rather than one, because an R.C.C. and an O.C.C. are
genuinely different shapes — a race rolls its attributes from racial dice and
usually has M.D.C., a character class has attribute *minimums* and hit points.
One template covering both would be half wrong whichever you were writing.

It is saved as a draft immediately, like an extraction, so a closed tab cannot
lose it. `PUT import/stored` is deliberately more permissive than confirm: a
draft only has to **parse**, not validate, because half-written is a draft's
normal state and refusing to save one until it is correct would lose exactly the
work most worth keeping. It will not overwrite a **published** class — that is
what Confirm is for, and Confirm runs the cross-reference and full validation
this skips.

### Skill importer

1. **Upload** a page range from a skill chapter, with an optional source-book
   label and category.
2. **Extract** — returns many skills as JSON, each classified as new or a
   duplicate, with the catalog's current numbers shown alongside the book's.
3. **Review** — duplicates offer **update** / **keep both** / **ignore**.
   A duplicate that is an empty stub defaults to *update*; any other duplicate
   defaults to *ignore*, so curated numbers are never silently overwritten.
   "Keep both" needs a distinguishing name, defaulting to `<name> (<book>)`.
4. **Confirm** — applied as one batch. Names claimed twice in a single import
   are reported as conflicts rather than failing the whole run.

A reply that hits the output ceiling is **rejected, not staged**. Half a page
saved as though it were the whole page is worse than a failure, because you
would confirm it without knowing the tail was missing. Narrow the page range.

In the Rifts core book the skill chapter is roughly **pp. 26–34**, about one or
two categories a page. Two pages yielded 33 skills in ~28 seconds.

### Spell importer

A spell chapter is hundreds of entries across many pages and does not fit one
sitting, so spell imports run inside a **session**:

1. **Start an import**, naming it and optionally labelling the source book.
2. **Feed it a page range at a time.** Each extraction is staged in the database
   the moment it parses, so a closed tab costs nothing — the model call is the
   expensive part and it is what gets saved.
3. **Review the pending list**, which accumulates across ranges. Duplicates
   default the same way skills do: a bare stub to *update*, anything curated to
   *ignore*.
4. **Import the batch.** The session stays open for the next range.

Four behaviours worth knowing:

- **A row that collides stays pending.** If an insert clashes with a name
  already in the catalog, it is reported and left in the list so you can give it
  a distinguishing name and retry, rather than being silently dropped.
- **An update whose target has vanished is reported, not swallowed.** A
  duplicate is staged with the catalog row it matched; if that row is renamed
  before you confirm, the `UPDATE` would match nothing and succeed silently. The
  engine checks first and reports it as a conflict, so the row stays pending and
  can be retried as an insert instead of disappearing with a success message.
- **Staging a page range is one batch**, so it is all-or-nothing like confirming
  one. A range yielding more than 300 rows is refused as too wide to have been
  read reliably.
- **Re-submitting a range you already did is harmless.** Names already staged in
  that session are skipped rather than duplicated.

Keep page ranges small. Spell entries carry a stat block plus prose, so they are
much longer than skill entries, and a reply that overruns the output ceiling is
rejected rather than half-saved.

#### D1 binds 100 parameters per statement

Measured against the real binding rather than assumed:

```
binds  100  ok
binds  101  FAIL: D1_ERROR: too many SQL variables at offset 221
```

Any query building `IN (?,?,...)` from a list that grows with user data has a
hard ceiling. Four files already carried a private `LOOKUP_BATCH = 50` for this
reason; the ones that did not are where it broke.
[`_lib/sql-chunk.js`](../../../functions/api/character-creator/_lib/sql-chunk.js)
now holds the constant and the helper in one place, and the smoke test fails any
of those six files that stops using it.

**The worst instance ran after the write, not before it.** `markConfirmed`
builds `WHERE id IN (?,?,...)` from every pending row in a session, and it runs
*after* `applyDecisions` has already committed the catalog inserts. Confirming
108 spells therefore:

1. inserted all 108 — the write itself was fine, each `INSERT` binds about 14
2. threw on the bookkeeping statement, 313 ids in one `IN`
3. returned a **500 that read as total failure**
4. left every row still pending, so the next confirm tried to insert all 108
   again and reported them as `A row with that name already exists`

The write and the bookkeeping disagreed, and the bookkeeping is what the next
run reads. `applyDecisions` says *"All-or-nothing: nothing was written"* in its
error path — true of the batch it guards, and not true of the endpoint the
caller is actually talking to.

It was found only because the half-written rows carried a `NULL system` that the
data script being generated alongside them never produces. Had both paths agreed
on that column, the partial write would have been invisible.

The regression test seeds 150 staged rows and confirms them through the real
endpoint. Under the unchunked code, the telling check is the one that **passes**
— `the catalog really grew by 150` — beside four that fail.

### Psionic importer

The same session flow as spells — `_lib/session-import.js` is shared, and the
two endpoint files are three lines each. Psionic powers take the **same field
names as spells** (`range`, `duration`, `saving_throw`, `description`) so the
sheet can render both through one code path.

Two things are specific to psionics:

- **`min_tier`** records the psychic tier a book says a power requires. It is
  filled in **only when the entry itself states one**. Books state tier access
  at the *category* level far more often than per power ("Super Psionics are
  Master only"), so most rows legitimately have none, and the prompt is written
  to make saying nothing the easy answer. **NULL means no restriction beyond the
  power's category.** The column *is* enforced: the picker filters through
  `derive.meetsTier()` and will not offer a power above the character's tier —
  see [Psychic tiers](leveling.md#psychic-tiers).
- **Unknown categories and tiers are flagged, never rejected.** A supplement
  that adds a category the core four do not cover must still be importable, so
  an unrecognised value imports with a ⚠ against it rather than failing. The
  same applies to a tier outside minor/major/master.

### Gear importer

Same session flow again. Two things are specific to gear.

**It is the only catalog matched on two fields.** Gear is unique on `slug`, and
every existing row is a stub created by a class import, keyed on the `item_id`
that class markdown referenced. The importer derives a slug from the book's item
name and matches on that first, then falls back to the display name — because a
stub stored as `ns-turbo-cyclone` will not match the slug that "NG-Turbo
Cyclone" produces, and **a missed match means a second row while characters keep
pointing at the empty one**. A fallback match is flagged in review so it is
visible rather than assumed.

**Gear has no `source` column**, so a stub is recognised by the marker the class
importer writes — `STUB — created by class import, needs stats`. A row edited by
hand no longer carries it and correctly stops counting as a stub.

Filling in a stub is an `UPDATE` in place, so `gear.id` never changes and
inventory rows keep resolving.

An equipment chapter is the hardest extraction of the four: weapon tables,
armour tables and prose gear descriptions share a page with entirely different
shapes. Most fields apply to only some kinds, and the prompt leans on omitting
rather than guessing — a backpack legitimately has nothing but weight, cost and
a description.

---

## Twenty gear prices, and why the first fix missed them

`fix-rue-gear-prices.sql` corrects **sixteen costs**, records **three** ranges
that were right but undocumented, and prices one item that had none.

**Thirteen rows held the HIGH end of a printed range** - the same bug migration
032 exists for. They survived the first fix because
`backfill-gear-cost-notes.sql` was deliberately guarded on the stored cost
*already being the low end*: every row that had the high end was skipped **by
design**, and so stayed wrong. A guard that narrow protects the rows it
understands and quietly abandons the ones it does not.

| | catalog | book |
|---|---|---|
| `Sunglasses (fancy or light adjusting)` | 300 | **100**-300 |
| `Cross/Crucifix (silver; 8-12 inches)` | 400 | **200**-400 |
| `Gas Mask (larger than human)` | 120 | **80**-120 |
| `Machete with canvas sheath` | 100 | **40**-100 |
| … nine more | | |

**Two were simply wrong.** `Blanket (Heavy)` at 6 against the book's 20, and
`Blanket (Light)` at 4 against 10. No range, no note - transposed somewhere.

**One is a page-break error, and the worst kind.** `NG-101 Rail Gun` carried
**70,000**, which is the **NG-202's** price on the following line: the NG-101's
block starts on printed p270 and its `Black Market Cost` falls on p271. A row
straddling a page break usually loses a value; this one gained the neighbour's.

**Four price lines were invisible to the parser** because OCR read `cr.` as
`er.` - `Knapsack`, `Knife, Large`, `Machete`, `Mallet (small)`,
`Mechanical Pencil` and `Sunglasses or Goggles (cheap)`. Three of those were
wrong and three merely undocumented. Any pattern reading prices out of this
book has to accept `er` for `cr`.

### Three rows deliberately left alone

- `Hammer (tool)` carries 7 against the book's *"Hammer (average, metal):
  10-20 cr."* The catalog also holds `Small Hammer` at 10 and `Small Mallet` at
  2, and a price alone cannot say which row the book's entry is.
- `Canteen` carries 20, which looked wrong until the page showed **three**
  canteens priced separately - Aluminum 30, Plastic 20, 2 M.D.C. 2200. The
  catalog holds the plastic one and is right.
- `Spike` carries 3 against *"Spikes (6, iron): 6 cr."* - a pack of six, not one
  spike. Different granularity, not a different price.

## The OCR is confidently wrong, which is why tuning it does not help

The obvious response to bad OCR is a better scan. Measured over four pages whose
errors are known, it barely moves:

| setting | price-unit misreads | l/I confusions |
|---|---|---|
| 300 dpi (current) | 7 | 15 |
| 500 dpi | 6 | 12 |
| 600 dpi | 5 | 14 |
| `--oem 1` (LSTM only) | **no change at all** | |
| greyscale + unsharp mask | 7 | 12 |

The reason is in the confidence column. Tesseract reads **`Ibs` at 91-94** and
**`18.000` at 93-97**. It is not hesitating, and it has no reason to: `Ibs` and
`18.000` are perfectly plausible strings. Nothing tells an OCR engine that
Palladium does not price things in thousandths of a credit.

Only **1.3%** of words in the book score under 70, and **none of the known
misreads are among them** - so filtering on confidence finds nothing either.

**So the leverage is not in the scan. It is in knowing what a field is allowed
to be.** Two places now do:

`scripts/ocr-book.py` repairs the systematic confusions **once, at ingest**, and
only where context makes them unambiguous:

- `20-100 er.` is a price. All 14 occurrences follow a digit and no real word
  does - a bare `er`->`cr` would wreck "her" and "player".
- `18.000` is eighteen thousand. Guarded to **exactly three digits**, because
  this book writes measurements as `1.8 m` and `0.9 m` and never to three
  places - and prints `130.101 - 180,200` as one range using both separators.

Re-running it took **zero** occurrences of both, and left all 30 instances of
`0.9 m` intact.

`--renormalise` re-applies the table to the cached `.raw.txt` **without running
Tesseract again**: seconds instead of 25 minutes, so improving a rule is cheap.

`scripts/ocr-fields-lib.mjs` holds the typed readers - `money`, `weightLbs`,
`dice`, `isMegaDamage` - for what context cannot settle in bulk. They **refuse
rather than guess**: `dice('Varies with missile type')` is `null`, not zero,
because a damage field that cannot be read is a note. Twenty-two cases are
pinned in the smoke test, every string taken verbatim off a page.

## RUE cannot fill the gear stubs, and that is the answer

78 gear rows are class-import stubs. The obvious next step is to fill them from
the equipment chapter, and it does not work - not because the matching is hard,
but because **the names describe different things**.

RUE's general-equipment price list holds **48** real entries. Matched against
the stubs with the catalog matcher, **zero** pair up. (That measurement was taken
over 79; one has been retired since, and
[Known limitations](known-limitations.md#known-limitations-and-refactor-candidates) has said 78 for
a while — this paragraph was the half that did not get updated.) The near misses show
why:

| stub | nearest priced entry |
|---|---|
| `Air Filter And Gas Mask` | `Air Filter (12, disposable)` **and** `Gas Mask (human-size)` - two entries |
| `Fishing Line And Hooks` | `Fishing Line, per 50 feet (15 m)` - hooks are not priced |
| `Medical Kit` | the book has a *Medical Equipment* section, not a kit |
| `Sack`, `Tweezers`, `Cord` | not priced anywhere in the book |

The stub names were invented by the class importer out of an O.C.C.'s equipment
prose - "a sack", "tweezers", "an air filter and gas mask". They are
descriptions of things a character carries, not entries in the book's
catalogue, and the book never prices most of them.

**So filling them is a judgement call per item, not an import.** Deciding that
`Air Filter And Gas Mask` costs 55 because two separate entries cost 5 and 50 is
a reasonable house rule and it is *not* what the book says. That distinction is
the whole reason `source_book` exists.

A search of the whole book for each stub name is in the session notes: 22 appear
somewhere in the equipment chapter, 42 appear only in O.C.C. equipment lists
elsewhere - **a mention, not a definition** - and the rest not at all.

## A gear price is often a range, not a number

RUE prices much of its common gear as a range, and the loss is not cosmetic:

```
Belt, Utility (military style):   3-5 cr.
Knife, Large (does 1D6 S.D.C.): 20-100 cr.
Knife, Small (does 1D4 S.D.C.): 15-75 cr.
```

`cost` held one integer and the rest was dropped at import. **The equipment
import then stored the HIGH end of every range it met** — 8 times out of 8 —
while every pre-existing catalog row sat at the LOW end. Because nothing
recorded that a choice had been made, the inconsistency was invisible: `Knife,
Small` came out dearer than `Knife, Large`, and three rows were nearly
"corrected" to prices RUE already agreed with at the other end of the range.

So `cost` holds the **low end** — the number the sheet does arithmetic with,
exactly as `spells.ppe` holds a variable cost's minimum and `ppe_note` carries
the schedule — and `cost_note` carries the range or qualifier verbatim.

The extraction prompt asks for both halves. It used to say *"if a cost is a
range or varies, omit cost and put the wording in description"*, and the model
did neither reliably; there was nowhere for a range to go, so it guessed a
number instead.

**A stored 75 that came from 15-75 is indistinguishable from a flat 75.** That
is the whole reason the column exists.
