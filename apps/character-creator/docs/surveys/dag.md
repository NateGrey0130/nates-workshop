# Palladium Fantasy Dragons and Gods — survey

**Status:** `backfilled` — written after the fact; gods and creatures came in with the NPC and bestiary plan, and no full inventory has been taken. (2026-09-24)

**Rows citing this book:** classes 1, gear 23, notable_npcs 73, creatures 38

Slug `dag`. Cached from `PFRPG - Dragons and Gods (1).pdf`, 240 PDF pages,
**text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28**, when one row traced to this book. It was
cached and registered but never surveyed. The NPC and bestiary plan has since
brought its gods and dragons in, and the magic weapons chapter followed on
2026-09-26 - see the ledger.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1.
`printed_pages: 232`, `cached_range` `p001-p240`, all 240 cached.

**240 PDF pages, 232 numbered** — the same appended Palladium catalogue `cb1`
carries. `printed_pages` says 232.

## The book's authority tables

**Not found — the book has not been surveyed.** A book of gods and dragons is
the kind that prints a master list; finding it is step 4.

## Inventory

**Not counted.** One hand-cut slice from this import era survives in `Downloads`
— `PFRPG - Dragons and Gods-23-24.pdf` — with no record of which printed pages
it holds or which import used it. Debris, not a record.

## Classes

One class: `chiang-ku-dragon`, with a hatchling variant.

**The other hatchlings are playable by the book, and not imported.** Read
2026-09-26. Printed 50, *Hatchling Dragon as an optional Player Character*, is
a generic rule, not a stat block: a player may take a hatchling of "most of the
dragons described", excluding the **Hydra, Cockatrice and Wooly Dragon** as too
monstrous. Each species entry (printed 22-48) prints its own hatchling numbers
beside the adult's - attributes, natural A.R., hit points, S.D.C., P.P.E.,
horror factor, R.C.C. skills, bonuses and attacks - with a Rifts conversion
block; experience uses the shared dragon table (printed 17). Thirteen species
carry an `Attributes (hatchling)` line; minus the three excluded, **ten are
playable, one of them (Chiang-Ku) already a class - nine would be new R.C.C.s**:
Fire, Great Horned, Ice, Kukulcan, Lo-Dox, Night Stalker, Serpent of the Wind,
Thunder Lizard and Ultucan. The Great Horned's Rifts hatchling
(`dragon-hatchling`, Rifts Ultimate Edition) is a different system's class and
does not cover it.

## Catalog diff

**Not run.**

## Extraction plan

None agreed.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | cached, 240 pages |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `dag` registered in `books.json`, with the `dragons-and-gods` alias |
| 2026-08-28 | — | this file, backfilled offline |
| 2026-09-26 | #TBD | **Magic weapons, printed 228-232: 23 `gear` rows** (`add-dag-magic-weapons.sql`), the book's first gear. Castlerake and Frostfoil (Swords of Legend), the dragon bone weapons, spear, arrows and eight spell-charged arrows, the arrow with angel feathers, the Dragon Eye Medallion, Dragon Claw Gloves, Sorcerer's Dragon Helm, Mantle of Dragon Endurance, the Feathered Dragon's Wings, the generic Dragon Slayer Weapon, the Black Sword of Styphon and the Dragon Slayer Rune Armor and Axe. Shape copied from `add-pf-magic-items.sql` and the Atlantis rune weapons: `palladium-fantasy`, `magic` for generic items, `weapon` for named ones, `armor` for the suit; unpriced items store NULL. **Not imported:** the standard Dragon Helm (the Dragon's Skull, 800,000-1.5 million gold), because `dragon-helm` already exists citing the main book at 200,000 - left for a decision; the optional rune weapon powers (printed 232), which are not items. book-reconcile: 23/23 clean. Applied `--remote` before the merge. |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-09-26, before the
magic weapons were applied (a `--local` run with them reads 135 / 0):

```
  dag                112 / 0
```

**112 traceable, nothing untraceable.** That is a statement about what has been
asked for, not about what the book holds. Still open: the nine playable
hatchling R.C.C.s (see *Classes*), the Dragon Helm name collision, and the book
has never had a full inventory.
