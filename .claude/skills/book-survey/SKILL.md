---
name: book-survey
description: Survey a whole sourcebook PDF before importing any of it, so the import is driven by what the book actually contains rather than by the pages someone happened to open. Use when handed a full book — "here is the PDF", "what's in this book", "pull everything relevant out of it", "import the whole thing" — and before any large spell, skill, gear or class import. Covers slicing, finding the book's own authority tables, diffing against the catalog first, and the reconciliation pass that catches rows which look fine and are wrong.
---

# Surveying a book before importing it

A 360-page sourcebook does not fit in one model call and should not be fed to
one. **Read the book's structure offline first, decide what is worth importing,
then extract only that.** Every step below exists because skipping it produced a
plausible-looking wrong answer.

Offline structural work is free — `pymupdf` and a script. Only extraction costs
money, and it is the step to spend the least on.

## The loop

| phase | question | costs |
|---|---|---|
| 1. inventory | what kinds of content, and where? | free |
| 2. authority | what does the book state its own facts in? | free |
| 3. diff | what is actually missing from the catalog? | free |
| 4. extract | pull only the gap, batched by section | **money** |
| 5. reconcile | does every row agree with the authority? | free |
| 6. ship | data script, rebuild, verify | free |

Phases 1-3 routinely cut phase 4 by more than half. The Book of Magic has ~1038
stat blocks; the invocation import needed 108 of them.

## 0. Does it have a text layer? Ask before you OCR

**One command, before anything else:**

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --probe
```

It samples twenty pages spread through the book, prints the character count of
each, and says TEXT LAYER or SCAN. It writes nothing. Use it rather than a bare
`python -c` — that is deliberately outside the allowlist and prompts every
single time, and this is the first command aimed at every new book.

Zeros mean a scan. Thousands mean a text layer, and a text layer changes
everything downstream: **no OCR, no model call, no confidence problem, and no
cost.** The Palladium Fantasy main book has one — median ~5,700 characters a
page — and every extraction from it, twenty-five classes and fifty-seven spells
and two authority tables, was read with `scripts/read-columns.py` and nothing
else. Rifts Ultimate Edition has none, and needs everything below. The gap is
not delicate: every text layer measured here medians 4,000–6,100 characters a
page and every scan medians zero.

This step is first because the version of this skill that did not have it led
with "OCR it once, properly", and OCRing a book that did not need it would have
spent hours reproducing text that was already there, worse.

A text layer is not perfect, and its damage is different from OCR's — it is
typesetting, not misreading. What the Palladium book's actually did:

| what arrived | what it is |
|---|---|
| `EyesofThoth(S)` | spaces missing entirely, and a mis-set `8` as `S` |
| `Vagabond/Peasant/Farmel` | a mis-set final `r` |
| `14272,881-324,880` | a missing space between the level and the number |
| `per addi- tional magician` | a hyphen kept from the end of a column line |
| `...one foot of metal. Level Eight` | a section heading welded onto the previous description |

None of those is fixed by a better reader. They are fixed by knowing what the
value should look like: a one-character parenthetical where a cost belongs is a
mis-set digit, and the OTHER authority table has the real one.

## 0b. Cache it — the SAME command either way

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue
```

**Do this whichever answer step 0 gave**, and do it before anything else. The
page-addressed cache under `.cache/books/<slug>/txt/` is what `class-check
--field-sources` and `drift-check`'s citation check both read; without it a row
cannot be traced back to the page it came from at all.

One command, no flags required, because the failure this prevents is a session
writing its own caching loop. Seven of the first eight caches were built that
way — six by throwaway code that is in no commit — and they do not agree with
each other. `ju`'s is raw `page.get_text()`, columns welded across the gutter,
which is exactly the corrupting read `read-columns.py` exists to prevent.

**If it has a TEXT LAYER** the script takes the cheap path by itself:
`read-columns.read` into the same `txt/pNNN.txt` layout, no images, no
Tesseract, no cost, and a manifest recording `"text_layer": true`. Seconds for a
whole book.

**If it is a SCAN**, add the table pages you already know about:

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue --tables 167,200-202 --dpi-tables 500
```

Emits normalised `txt/`, raw `txt/*.raw.txt`, and `tsv/` word geometry, using
`--psm 3` and a Palladium wordlist.

**Re-running is safe and resumes.** A page is already done when its `txt`
exists (text layer) or its `txt` and `tsv` both do (OCR) — keyed on both
regardless, as it once was, a plain re-run against a text-layer cache resumed
NOTHING and overwrote every page with Tesseract output. Switching a cache from
one kind to the other now needs `--force` and says what it would destroy, which
is why `bom` — a book that has a text layer and was OCR'd anyway — refuses.

**Do not reach for a higher DPI when the text is wrong.** Measured: 300 -> 600
dpi took one error class from 7 to 5, `--oem 1` changed nothing, preprocessing
changed nothing worth having. The OCR is CONFIDENT about its mistakes - `Ibs`
scores 91-94 and `18.000` scores 93-97, and only 1.3% of words score under 70
with none of the known misreads among them. A confidence filter finds nothing.

Fix it where the meaning is, not where the pixels are: contextual repairs at
ingest, and the typed readers in `scripts/ocr-fields-lib.mjs` for the rest.
`--renormalise` re-applies the substitution table to cached raw text without
running Tesseract, so improving a rule costs seconds rather than a re-scan.

Cache the WHOLE book, not the pages you think you need: the alternative is
discovering mid-task that you need geometry you did not save, or that
`I.S.P.` reads as `LS.P.` on most pages. The cache is gitignored; it is a
commercial book.

## 0c. A text layer does not give you TABLES. Render the page and look

This is the trap that costs the most time, because step 0 says "text layer" and
you believe it. A text layer extracts *prose* faithfully and **loses the
geometry of a chart**: the columns arrive as disconnected runs, the header row
lands somewhere else, and nothing tells you it happened.

Every authority table in this repo that mattered had to be read as an image:

| table | what the text layer gave |
|---|---|
| Attribute Bonus Chart (PF 16) | nothing findable — greps for the row values returned no page at all |
| Types of Armor (PF 270) | column fragments on the page *after* it, headers detached from values |
| Coalition SAMAS Pilot's skills (RUE 233) | merged with the Coalition Grunt's column beside it, six wrong numbers |

**Render it and read it:**

```python
import pymupdf
doc = pymupdf.open(pdf)
doc[printed_page_to_pdf_index].get_pixmap(dpi=200).save('page.png')
```

then read `page.png`. 200 dpi is enough for a stat block and cheap; the images
above were all legible at it.

**Use the rows you already have as a check on the reading.** When the catalog
holds five of a table's sixteen rows, those five are five independent
confirmations that the transcription is right — and a generator that refuses to
run when one has drifted turns that into a guarantee rather than a spot-check.

## 0d. Read the offset from the registry. Derive it only if there is none

`scripts/books.json` records `page_offset` per book, and `ocr-book.py` writes
the same number into the cache manifest at build time. **Look there first** —
it is a per-book constant that is free to record once and costs a wrong page
read every time it is guessed. `class-check --field-sources` already prefers it,
in this order:

```
--offset            you override everything
scripts/books.json  the durable, hand-checked copy, PER PRINTED PAGE
the manifest        what ocr-book.py measured when it built this cache
live detection      majority vote over the folios, for an unregistered book
0                   and it SAYS so, rather than quietly using it
```

It prints which of those it used, on the FIELD SOURCES line. It also prints an
advisory when the pages disagree with what is recorded — that is the signature
of a re-cached book, a duplicated page, or the split below. Advisory only: it
never changes the exit code, because the recorded value can be right while the
cache is newly partial.

**The offset is not always constant, and a majority vote cannot see that.**
`pf` is the live case and the reason this section exists. An extra page sits at
cache `p018`/`p019` — `p019` holds `p018`'s text plus a *Throwing Objects*
table — so the offset is **+1 for printed 1-16 and +2 for printed 18-336**.
Measured over the whole cache the vote is **287 to 11** for +2, so a single
number sends every lookup in the first sixteen pages one page early. Hunting the
Attribute Bonus Chart at printed 16 with the late-book offset lands on the wrong
page and finds nothing, which reads exactly like "the chart is not in this book".

That is what `page_offset_exceptions` is for:

```json
"page_offset": 2,
"page_offset_exceptions": [ { "printed_through": 16, "offset": 1 } ]
```

First match wins; everything past the last exception falls through to
`page_offset`. `pf` is the only book that has one. If you cache a new book,
`class-check --field-sources` will tell you when it needs one — it reports every
offset region it detects and says so when the registry does not describe them,
and the smoke test fails if any cache on this machine shows a region
`scripts/books.json` cannot resolve.

**When there IS no recorded offset**, derive it next to the page you actually
want — render a candidate and read the folio printed on it — not once for the
whole book. Then record it, so the next session does not repeat this.

**And the two tools you verify it with disagree about what "page" means.**
`scripts/read-columns.py` takes the number a PDF VIEWER shows — 1-based, it
calls `doc[n - 1]` — while `pymupdf` in a probe script is 0-based. Derive the
offset with one and read with the other and you land one page early: a whole
page of the wrong class, which reads as the book not saying what you expected
rather than as an off-by-one.

**A zero offset is the worst case, not the easiest.** Pantheons of the
Megaverse has one — printed N is `d[N]` — so there is no real offset to hunt,
and this is then the ONLY discrepancy left to explain. It cost a wrong page read
on the first attempt at the Godling.

| you want | pymupdf probe | read-columns.py |
|---|---|---|
| printed p.16, zero-offset book | `d[16]` | `... 17 17` |
| printed p.16, offset +2 | `d[18]` | `... 19 19` |

The folio at the end of read-columns' output is the check, and it is free. Read
it every time. Note that a SINGLE-page call prints no `===== pN =====` header at
all — only a range does — so passing the page twice is the cheaper habit.

## 0e. Extracting priced entries out of prose

Item lists are paragraphs with a price somewhere inside, not tables. An
extractor finds the boundaries; it does not find the answers. Three failures
recur, and all three put a plausible wrong number in a numeric column:

- **A price wrapped across a line.** `20,000-\n30,000` becomes the single number
  **2,000,030,000** if the de-hyphenation that rejoins a broken *word* is let
  near it. A hyphen BETWEEN DIGITS is a range and must survive.
- **A long entry labels its own parts** — `Duration:`, `A.R.:`, `Cost:` — each
  of which looks exactly like the start of a new item. The Cape of Dimensions'
  700,000 gold was filed under an item called *"Use Limits"*.
- **The first price in an entry is not its price.** That same Cape mentions
  25,000 gold to repair a tear long before its own cost line.

Two more worth knowing: a book may print four items under one name
(`Contact poison: Numbstrike:`), and a section may price by **band** rather than
per row — the faerie foods say so in their own preamble and give no individual
figures at all.

**Check the extraction against itself.** The experience tables were checked by
asserting each level's low equals the previous level's high plus one: the two
numbers are printed separately, so they only agree if both were read correctly.
All 225 passed, and that check is worth more than re-reading the page.

## 1. Inventory: what is in here?

Count structure, not prose. A spell has a stat block, a class has attribute
requirements — so count those markers per page range rather than trying to read
the book.

```python
PPE   = re.compile(r'^\s*P\.?\s?P\.?\s?E\.?\s*(Cost)?\s*:', re.M | re.I)   # a spell/power
CLASS = ['Attribute Requirement', 'O.C.C. Skills', 'R.C.C. Skills', 'Standard Equipment']
```

**A mention is not a definition.** Search for the stat block, never the name. The
Book of Magic names a dozen R.C.C.s in a cross-reference list and *defines* one
class in 360 pages — page 224, the only page in the book carrying two or more
class markers.

Report the inventory as a table before extracting anything. It is the thing worth
agreeing on.

## 2. The authority table

**Find where the book states the fact you cannot get from a description.** For
spells that is the level: a description prints its stat block and never its
level, because the book states it once, in the section heading. Import
descriptions alone and 69 of 84 rows come back level 0.

Most books have a master index that states level *and* cost in one place. It is
the single most valuable page in the book and it is worth three passes to parse
correctly.

**Read it geometrically.** An index set in columns does not come out of
`get_text()` in reading order. Read linearly, the Book of Magic's index puts
`Blinding Flash` — a level one spell — under level three, and returns levels one
and two **empty**.

Use **`scripts/read-columns.py`**, in the repo. It buckets blocks by their left
edge, splits columns on the GAP rather than an assumed count, emits full-width
blocks first as page headings, and takes a page range:

```bash
python scripts/read-columns.py "book.pdf" 189 191
```

This skill used to ship its own copy of that file under `reference/`, and the
two had forked completely — the copy was an older line-based implementation with
a `probe()` helper that the repo does not have, while every Palladium Fantasy
extraction actually ran the block-based one in `scripts/`. A reference that is a
FORK of working code is worse than a pointer to it: it reads as authoritative
and is not. The copy is gone.

**That script assumes the PDF has a text layer. A scan has none** —
`page.get_text()` returns `''` for every page of Rifts Ultimate Edition, so the
geometry has to come from Tesseract, and *how you ask it* matters more than the
bucketing:

| approach | what it produced |
|---|---|
| OCR text, read linearly | headings emitted `One, Three, Two, Four` — columns interleave |
| `--psm 6` + word boxes | one uniform block: `Level Two  Magic Shield (6)  Distant Voice (10)` welded into a single line |
| word boxes into N equal columns | assumes even spacing; that page has 2-column prose above a 3-column index, and no single division fits both |
| **`--psm 3`, group by `block_num`** | **each heading and its entries land in their own block — emitted order stops mattering** |

Let Tesseract do the layout analysis and group by its blocks. Reconstructing
columns from raw x coordinates is the thing that looks rigorous and keeps being
wrong.

```
tesseract page.png out --psm 3 tsv     # then group rows by block_num
```


**Then check the parse against something you already know.** Probe three or four
spells whose level you can verify independently. A column reader that is subtly
wrong looks exactly like one that works.

**Be generous about what an entry looks like.** Two passes were quietly wrong
here for the opposite reason — too strict:

| pattern | silently dropped |
|---|---|
| names of letters only | every `Summon & Control ...`, and `Doppleganger (Superior) (1,000)` |
| costs that must be numeric | `(l)` (an OCR'd 1), `(400 to 1000+)`, `(1,600 or Special)` |

A cost is anything carrying a digit, or the words Special/Varies. A name is
whatever precedes the **last** parenthetical on the line.

## 3. Diff before you extract

**Use `scripts/catalog-diff.mjs`. Do not write another matcher.** Every import
that hand-rolled one produced a confidently wrong answer:

| import | hand-rolled answer | truth |
|---|---|---|
| psionics missing | 21 | 16 |
| psionics wrong category | 23 | 0 |
| spells missing | 5 | 0 |

```bash
node scripts/catalog-diff.mjs --table psionic_powers \
     --entries book-entries.json --compare category,isp
```

It prints four buckets and a vocabulary warning. The rules it encodes -- exact
first, relaxed only when unambiguous on both sides, nearest-candidate advisory
only -- are in `scripts/catalog-match-lib.mjs` and pinned in the smoke test.

Two things it will tell you that are easy to get backwards:

- **A dominant single substitution is a vocabulary difference, not N
  corrections.** 29 of 30 category "errors" were the book writing
  "Super-Psionics" where the catalog says "Super". Applying them would have
  broken every picker that filters on category.
- **A small edit distance is not permission to merge.** `Telekinetic Push` and
  `Telekinetic Punch` are 2 apart and different; `Animate/Control Dead` and
  `Animate and Control Dead` are 4 apart and the same.


Get the catalog and subtract it. Extracting 300 spells to add 108 wastes money
and puts 200 needless rows through review.

**Normalise both sides** — lowercase, `&`→`and`, strip punctuation — or the diff
manufactures gaps. And **spot-check the "missing" list by hand**: OCR produces
`Tum Dead`, `Barrier ofThoth`, `ControllEnslave Entity`, and the catalog has all
three under their real spellings. Roughly one in twenty was a false gap.

The catalog may also tag rows inconsistently. `WHERE system = 'rifts'` missed 129
spells stored with `system IS NULL` and reported 225 missing where 106 were.
Query the whole table and filter in the diff.

## 4. Extract, batched by what the book states

**One batch per section the authority names**, carrying that section's fact
explicitly:

```
level: 7,
hints: 'Every spell in these pages is a level 7 invocation.
        Do NOT infer a level from the text; use the level given.'
```

Necessary. **Not sufficient — see phase 5.**

Keep batches small. Spell entries are long, and a reply that overruns the output
ceiling is rejected rather than half-saved.

## 4b. A book may ship TWO authorities, and they check each other

The Palladium Fantasy main book prints its spells twice: an alphabetical list
**by level** (printed 187), which is the only place a level is stated at all,
and an alphabetical list **by page** (printed 188), which repeats every cost.
Parse both and reconcile them and you get three independent readings of every
cost — the two indexes and the `P.P.E.` line in the spell's own stat block,
usually spelled out in words there, *Twenty-Five* against the index's 25.

That is not belt and braces. It is what turned two typesetting accidents into
data:

- `EyesofThoth(S)` in the by-level table has no number at all. The by-page table
  says `Eyes of Thoth (8)`. Without the second table, a strict cost pattern
  drops the spell entirely and a lax one stores `S`.
- The two disagree on exactly **two costs out of 182**. Both were already known
  and neither was in the batch — but the point is that *finding out* cost
  nothing, where trusting one table silently would have been free too.

Reconcile them by NAME with the same normalisation the catalog diff uses, and
keep a tiny explicit alias list for the names the book spells differently
BETWEEN ITS OWN TABLES — `Thunderclap` against `Thunder Clap`, `Faeries' Dance`
against `Faerie's Dance`. That is the book disagreeing with the book, not a
match to guess at, so list them rather than lowering the edit-distance bar.

## 4c. When a description page argues with the index

**The index wins, and the page is recorded.** But go and find out which is
wrong before deciding, because the answer is not always the index.

The Palladium Fantasy spell pages state a level only six times in 180 entries.
Five are the book's own Spells of Legend, which sit outside the numbered ladder.
The sixth is *The Finger of Lictalon*, headed `Level: Spell of Legend` while the
by-level index files it under Level Eleven.

Three things decided it, and none of them is "the index is the authority":

1. the by-level index says eleven;
2. the Spells of Legend list does not name it;
3. its **150 P.P.E. sits with the level elevens**, where the legends cost 1000
   to 5000.

Two independent readings against one, and a magnitude argument. It is stored at
eleven with the losing reading in `variant_note` — which is the same doctrine as
"the later book wins, and the losing number is recorded", applied to a book
disagreeing with itself.

**A page that states a fact only six times in 180 entries is telling you
something by the exception.** Count how often the field appears before deciding
what its presence means.

## 5. Reconcile — the step that is easiest to skip

**Hand this to the `book-reconcile` subagent.** It has no write tools and did
not write the parse, which is the point: the failures worth catching all look
ordinary from inside it.

**Check every extracted row against the authority, not a sample.** Supplying the
level per batch still produced 13 rows exactly one level too high, because
section headings sit **partway down a page**: the first page of each batch
carries the tail of the previous section, and those rows get stamped with the new
batch's level. Every one of them looked completely ordinary.

So: **the index is the authority and the page position is not.** Override.

Three more checks worth running every time:

- **A failed probe is a question, not a verdict.** Four RUE spells parsed to a
  level that contradicted what I expected. Every one of them was checked against
  its description section, and the book agreed with itself both times - the
  expectations came from a different edition. Probe to find disagreement, then
  go and find out who is wrong.
- **Two independent readings of every number.** The stat block's own cost and the
  cost the index prints. 108 of 108 agreed here; where a class page disagreed on
  an earlier import, the other two agreed with each other and the class page was
  the outlier.
- **A row straddling a page break loses whatever fell on the far side.**
  `Rift Teleportation` starts on p143 and its `P.P.E.:` line is on p144, so the
  next batch produced a second row — conflated name, wrong level, **no cost**.
  Look for cost 0 with no note.
- **Anything the authority does not list at all.** Either the name is mangled or
  the book never defines it. Both need eyes, neither is a guess.

## 6. Ship it

A data script, per the `class-import` skill — production sits behind Access, so
the import UI cannot reach it. Then prove the artifact rather than the session:

**Delete the rows and re-apply the script from scratch.** A local database
carries whatever the review left behind; the script is what ships. This caught
rows written by a failed confirm that the script then skipped with
`INSERT OR IGNORE`, leaving eight rows with a stale note and a NULL `system`.

Then `node scripts/drift-check.mjs --remote` and drive one real user path in the
browser — a picker that offers the new rows is the only proof they are reachable.

## 7. Persist the survey — it is the next session's boot file

Write the survey to **`.cache/books/<slug>/SURVEY.md`**, next to the OCR cache
and gitignored with it — it quotes a commercial book, so it stays local. It
holds what the session learned that the repo does not: the inventory table, the
authority pages and the *verified* printed-to-PDF offset, the catalog diff with
its hand-checked false gaps, the agreed extraction plan, and a progress ledger —
one line per shipped PR, appended when it merges, saying what went in and what
remains.

Then let the session go. The 2026-08-25 efficiency audit measured the same
import PR costing 2–7× more tokens late in a long session than early, because
every call re-carries the whole conversation — and when a mid-book context
reset dropped that carry from ~790K to ~235K tokens per call, the imports
continued without losing a thing, because everything they needed was in the
repo, the skills, the OCR cache, and this file. **Start a fresh session every
2–4 PRs**, booted from `SURVEY.md` plus `git log --oneline -15`, not from the
memory of a conversation.

## What "surveyed" means

- an inventory table of the book, by chapter, with counts
- the authority table parsed, and probed against facts known independently
- a diff against the catalog, hand-checked for false gaps
- a stated plan of what will be extracted and what will be left, with reasons
- all of it in `.cache/books/<slug>/SURVEY.md`, not just said in chat

Get agreement on that before spending anything.
