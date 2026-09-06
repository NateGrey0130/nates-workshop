# Importing from PDFs

How a sourcebook becomes catalog rows, and the things about these books that
no amount of tooling fixes.

Part of the [character creator](../README.md) documentation.

---

## The route a book takes now

**There is no in-app importer.** `import.html` and its thirteen routes were
retired: they had never run once against production. `import_sessions` and
`import_staged` were empty, and of the rows in `claude_usage` not one was an
import. Every catalog row this app holds was written by a data script.

What replaced it is five steps, four of which cost nothing:

1. **Cache the book.** `python scripts/ocr-book.py <pdf>` - one front door for
   either kind of book. A text layer is read geometrically through
   `read-columns.py` for free; a scan is rendered and OCR'd. `--probe` says
   which it is and writes nothing.
2. **Survey it before importing any of it.** The `book-survey` skill: find the
   book's own authority tables, inventory by structure rather than by reading,
   and diff against the catalog first. Wormwood's survey is the worked example,
   and it is what caught that 37 prayers were new and zero psionics were.
3. **Get a draft.** Either
   `node scripts/extract-class.mjs --book <slug> --pages <N-M>`, which sends the
   CACHED TEXT for a printed page range and writes a draft markdown file, or
   `node scripts/new-class.mjs occ` and transcribe by hand. All seventeen
   Wormwood classes were done the second way.
4. **Check it.** `node scripts/class-check.mjs draft.md --remote`, then again
   with `--field-sources`. This is not optional and the reason is in the next
   section.
5. **Write the data script.** One `add-<id>-class.sql` per class, applied
   `--remote` BEFORE the PR that carries it. See the `class-import` and
   `ship-pr` skills.

### The extractor sends text, not the page

The retired importer sent the PDF page as a document attachment, on the grounds
that layout-preserving text extraction splices neighbouring columns together
mid-line and destroys the column boundary before the model sees it.

**That was true of `pdftotext` and it is not true of the cache.** `ocr-book.py`
and `read-columns.py` find the columns by GAP and resolve them geometrically
before a byte is written, so the cached text is already in reading order. The
prompt therefore tells the model the opposite of what the old one did: do not
re-order this, and do not read a mid-paragraph topic change as a column
boundary to repair.

The consequences are all in the same direction - no PDF slicing by hand, no
image tokens, and the model reads the same bytes a human reviewer reads.

### It refuses pages that are pictures

A cached page of a few bytes is a full-page illustration, not a failed OCR run,
and the difference matters more than it sounds. Wormwood's Apok is cited
**pp.55-58**. Printed 56 and 58 are art - 14 and 8 bytes of noise - and the rest
of that class is on printed **59**: half its skill categories, its whole
equipment line, and Money, Armor, Transportation, Cybernetics and Symbiotes.

Run the extractor on the cited range and it stops and names them. That is the
guard: a class that quietly loses a third of itself still parses, still reads as
complete, and nothing downstream ever asks.

### `class-check --remote` is a required step, not a review

The first real extraction came back structurally sound - right id, right name,
right page citation, spells and psionics clean - and named **four skills by the
book's spelling rather than the catalog's**: `Lore: Monsters & Demons`,
`Language: American`, `Literacy: American`, `Math: Basic`. Every one is a known
rename. It also invented five gear slugs by issuing the Weapons line as
equipment.

**The format examples did not prevent that and cannot.** That run was given a
shipped class as an example, so the correct catalog names were in the prompt -
and so were notes saying in words that the book prints the other spelling. It
used the book's name anyway, every time.

Examples teach shape. They do not teach naming, and feeding the whole catalog
into the prompt is not the answer either. Checking against the live catalog
afterwards is.

### What has no automated path at all

Skills, spells, psionic powers and gear. The retired importer had a tab for each
and `extract-class.mjs` covers only classes. In practice this changes nothing:
Wormwood's 3 skills, 37 prayers and 71 gear rows were all hand-written data
scripts, because that is how every other catalog row got here too.

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

## Page-less skill rows, and which of them will stay that way

A skill row whose `source_book` names a book but carries no `p.N-M` cannot be
checked against a page. That is the state 105 rows were in when the skill
importer was taught to collect a page range (`INGESTION-AUDIT` `F18`, PR #351,
2026-08-27), and the rows already written were deliberately left alone.

**They have fallen since, as `F18` predicted, and the remainder splits in two.**
Asked of production 2026-09-06 with the same predicate `F18` used — a book, no
page:

| | 2026-08-27 | 2026-09-06 |
|---|---|---|
| a book, no page | **105** of 333 | **55** of 344 |

*(It read `56 of 345` for about an hour on 2026-09-06. `INGESTION-AUDIT` `F28`
then gave the `Law` row RUE's page citation and retired its duplicate, taking one
row out of this backlog and one out of the catalog. The figure moved because the
backlog shrank, which is the direction this table exists to show.)*

Of the 55, **43 name `Rifts Skill List`**, which is **not a book**. It has no
scan, no cache entry and no printed pages, so those rows cannot be given a
citation by reading a PDF and **will stay page-less permanently**. Caching it
would make the ledger claim a source that does not exist. The other **12** name
real, cached books — Rifts Ultimate Edition (5), Pantheons of the Megaverse (4),
and one each from Palladium Fantasy core, Rifts New West and Palladium Fantasy
RPG 2nd Ed. — and those are backfillable by reading pages.

**A third category exists and is outside all of the above: 52 skills carry no
`source_book` at all.** `F18`'s count never included them, so *"105"* and *"it
can only fall"* were never statements about these. Nothing has examined them.

Read a page-less row as *"this row was written before the importer collected
pages, or it comes from a list with no book"* — never as a defect in the
importer, which has collected a range on every skill it has confirmed since
2026-08-27. `INGESTION-AUDIT` `F26`.
