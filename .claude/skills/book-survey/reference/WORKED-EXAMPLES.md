# Worked examples

The evidence behind four rules in `SKILL.md`. Each rule stays there with a
pointer here; this file holds the case that produced it.

**Read one of these when you doubt the rule it supports, or when you hit
something that looks like the case and want to know how it went.** None of it is
needed to follow the rule.

Every case is one book. That is the point and the limit: these are what happened,
not what always happens.

---

## Palladium Fantasy's text layer — what "damaged" looks like when it is not OCR

Supports `SKILL.md` §0, *a text layer is not perfect, and its damage is different
from OCR's*.

A text layer extracts what the typesetter set. Where the typesetting was wrong,
or where the PDF's character stream disagrees with what the page looks like, the
extraction is confidently wrong in ways no better reader fixes:

| what arrived | what it is |
|---|---|
| `EyesofThoth(S)` | spaces missing entirely, and a mis-set `8` as `S` |
| `Vagabond/Peasant/Farmel` | a mis-set final `r` |
| `14272,881-324,880` | a missing space between the level and the number |
| `per addi- tional magician` | a hyphen kept from the end of a column line |
| `...one foot of metal. Level Eight` | a section heading welded onto the previous description |

The first row is the one that matters twice: it is also the case §4b's second
authority rescued, below.

---

## Reading a column index off a SCAN — four approaches, three wrong

Supports `SKILL.md` §2, *let Tesseract do the layout analysis and group by its
blocks*.

`scripts/read-columns.py` needs a text layer. Rifts Ultimate Edition has none —
`page.get_text()` returns `''` for every page — so the geometry has to come from
Tesseract, and *how you ask* mattered more than any bucketing done afterwards:

| approach | what it produced |
|---|---|
| OCR text, read linearly | headings emitted `One, Three, Two, Four` — columns interleave |
| `--psm 6` + word boxes | one uniform block: `Level Two  Magic Shield (6)  Distant Voice (10)` welded into a single line |
| word boxes into N equal columns | assumes even spacing; that page has 2-column prose above a 3-column index, and no single division fits both |
| **`--psm 3`, group by `block_num`** | **each heading and its entries land in their own block — emitted order stops mattering** |

The third row is the instructive failure: it is the approach that looks most
rigorous, and it is defeated by a single page whose top half and bottom half have
different column counts.

---

## Two authorities, and the two typesetting accidents they turned into data

Supports `SKILL.md` §4b, *a book may ship TWO authorities, and they check each
other*.

The Palladium Fantasy main book prints its spells twice: an alphabetical list
**by level** (printed 187), the only place a level is stated at all, and an
alphabetical list **by page** (printed 188), which repeats every cost. With the
`P.P.E.` line in each spell's own stat block — usually spelled out in words
there, *Twenty-Five* against the index's 25 — that is three independent readings
of every cost.

What it bought:

- **`EyesofThoth(S)`** in the by-level table has no number at all. The by-page
  table says `Eyes of Thoth (8)`. Without the second table, a strict cost pattern
  drops the spell entirely and a lax one stores `S`.
- **The two disagree on exactly two costs out of 182.** Both were already known
  and neither was in the batch — but *finding out* cost nothing, and trusting one
  table silently would have been free too. The value is in knowing the number is
  two rather than assuming it is zero.

The alias list the rule asks for exists because the book spells names differently
**between its own tables**: `Thunderclap` against `Thunder Clap`, `Faeries'
Dance` against `Faerie's Dance`.

---

## The Finger of Lictalon — how a page-versus-index argument was actually settled

Supports `SKILL.md` §4c, *the index wins, and the page is recorded — but go and
find out which is wrong first*.

The Palladium Fantasy spell pages state a level only **six times in 180
entries**. Five are the book's own Spells of Legend, which sit outside the
numbered ladder. The sixth is *The Finger of Lictalon*, headed `Level: Spell of
Legend` while the by-level index files it under Level Eleven.

Three things decided it, and **none of them is "the index is the authority"**:

1. the by-level index says eleven;
2. the Spells of Legend list does not name it;
3. its **150 P.P.E. sits with the level elevens**, where the legends cost 1000
   to 5000.

Two independent readings against one, plus a magnitude argument. It is stored at
eleven with the losing reading in `variant_note` — the same doctrine as *the
later book wins, and the losing number is recorded*, applied to a book
disagreeing with itself.
