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

## 0. OCR it once, properly

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue --tables 167,200-202 --dpi-tables 500
```

Emits normalised `txt/`, raw `txt/*.raw.txt`, and `tsv/` word geometry, using
`--psm 3` and a Palladium wordlist. **Do this before anything else** -- the
alternative is discovering mid-task that you need geometry you did not save, or
that `I.S.P.` reads as `LS.P.` on most pages. The cache is gitignored; it is a
commercial book.

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

See `reference/read-columns.py`. Bucket lines by x, sort by y, walk column by
column.

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

## What "surveyed" means

- an inventory table of the book, by chapter, with counts
- the authority table parsed, and probed against facts known independently
- a diff against the catalog, hand-checked for false gaps
- a stated plan of what will be extracted and what will be left, with reasons

Get agreement on that before spending anything.
