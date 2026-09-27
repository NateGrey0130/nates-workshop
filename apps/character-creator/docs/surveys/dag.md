# Palladium Fantasy Dragons and Gods — survey

**Status:** `backfilled` — written after the fact; gods and creatures came in with the NPC and bestiary plan, and no full inventory has been taken. (2026-09-24)

**Rows citing this book:** classes 10, gear 23, notable_npcs 73, creatures 38

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

`chiang-ku-dragon`, with a hatchling variant, was the book's only class until
2026-09-27; the hatchling R.C.C.s below followed it.

**The other hatchlings are playable by the book.** Read
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

**Nate decided on 2026-09-27 to import them**, three species per branch. Kukulcan,
Lo-Dox and Night Stalker are in as `kukulcan-dragon`, `lo-dox-dragon` and
`night-stalker-dragon` (see the ledger). Each copies the `chiang-ku-dragon`
shape - a hatchling and an adult variant - carries the printed-17 dragon
experience table as `xp_table`, and starts with no money or gear.

**Serpent of the Wind, Thunder Lizard and Ultucan are imported** (2026-09-27,
Nate's decision to import the playable hatchlings): `serpent-of-the-wind-dragon`,
`thunder-lizard-dragon` and `ultucan-dragon`, each in the Chiang-Ku's shape - a
hatchling and an adult variant, the printed 17 ladder as `xp_table`, magic and
psionics the hatchling's. See the ledger.

**Fire, Great Horned and Ice** followed the same day as `fire-dragon`,
`great-horned-dragon` and `ice-dragon`, in the same shape. The adult's attacks
per melee are `attacks_base` on its variant, no Hand to Hand is granted or sold
(the related picks exclude the styles, `costs: {}`), and each species' hatchling
skill rule is on the page (Fire and Ice: language and basic math 96%; Great
Horned: language and both maths 98%). The language and literacy picks carry the
printed percentage as a `bonus` over the `Other` rows rather than a `base`,
because regression refuses a language pick frozen by `base`;
`~027-dag-hatchling-language-picks.sql` moves the Kukulcan, Lo-Dox and Night
Stalker, which #1460 stored with a flat `base`, to the same form. The Great Horned's
"1D4+2 spells from levels 1-2" is dice, so no starting count is stored - prose,
with `spell_levels_allowed: [1, 2]` - as the Kukulcan's are.

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
| 2026-09-18 | #1166 | **notable NPCs - the gods** (NPC and bestiary plan, Phase 2b): `add-notable-npcs-dragons-and-gods.sql`, 73 `notable_npcs` rows citing this book. Row added 2026-09-27; the PR did not write one. |
| 2026-09-18 | #1171 | **creatures** (Phase 3): `add-creatures-dragons-and-gods.sql`, 38 `creatures` rows, attacks in `stat_attacks`. Row added 2026-09-27. |
| 2026-09-26 | #1442 | **Magic weapons, printed 228-232: 23 `gear` rows** (`add-dag-magic-weapons.sql`), the book's first gear. Castlerake and Frostfoil (Swords of Legend), the dragon bone weapons, spear, arrows and eight spell-charged arrows, the arrow with angel feathers, the Dragon Eye Medallion, Dragon Claw Gloves, Sorcerer's Dragon Helm, Mantle of Dragon Endurance, the Feathered Dragon's Wings, the generic Dragon Slayer Weapon, the Black Sword of Styphon and the Dragon Slayer Rune Armor and Axe. Shape copied from `add-pf-magic-items.sql` and the Atlantis rune weapons: `palladium-fantasy`, `magic` for generic items, `weapon` for named ones, `armor` for the suit; unpriced items store NULL. **Not imported:** the standard Dragon Helm (the Dragon's Skull, 800,000-1.5 million gold), because `dragon-helm` already exists citing the main book at 200,000 - left for a decision; the optional rune weapon powers (printed 232), which are not items. book-reconcile: 23/23 clean. Applied `--remote` before the merge. |
| 2026-09-27 | #1459 | **The Dragon Helm, settled.** Nate's decision: no second row. `~024-dragon-helm-and-annihilate.sql` writes printed 231's price for the standard Dragon Helm, the Dragon's Skull (800,000 to 1.5 million gold, read off a 300 dpi render), into the existing `dragon-helm` row's `cost_note`, keyed on slug; the row keeps its 200,000 and its Palladium Fantasy RPG citation, so no row cites this book for it. No row count moves. `--remote` is applied before the merge. |
| 2026-09-27 | #1460 | **Hatchling R.C.C.s: Kukulcan, Lo-Dox, Night Stalker** (printed 34-40), `add-kukulcan-dragon-class.sql`, `add-lo-dox-dragon-class.sql`, `add-night-stalker-dragon-class.sql`: classes 1 -> 4. Shape copied from `chiang-ku-dragon` (hatchling + adult variants for dice, pools, horror factor and bonuses); top-level skills, magic and psionics are the hatchling's because printed 50 makes the hatchling the player character. `xp_table` from the Dragon Exp. Table, printed 17; `starting_money: 0` and no equipment, printed 50. Dice-valued spell counts stay in `special_abilities`; the magic block states only the level gate. Every number read off a render. book-reconcile: 3 classes, 6 variants, no disagreements. Applied `--remote` before the merge. |
| 2026-09-27 | #1461 | **Three hatchling R.C.C.s, printed 40-47**: `add-serpent-of-the-wind-dragon-class.sql`, `add-thunder-lizard-dragon-class.sql`, `add-ultucan-dragon-class.sql` - classes 4 to 7. Shape copied from `chiang-ku-dragon`: hatchling and adult variants (dice, pools, horror factor, bonuses, `attacks_base`), `xp_table` the Dragon Exp. Table levels 1-15 (printed 17, render-read), no starting possessions (printed 50). Magic and psionics are the hatchling's, since a variant cannot override either; the adult's are prose. Judgements, each in its class's `extraction_notes`: the Serpent's "all warlock magic from levels one and two" read as the Air warlock rows; the 1D4 spells per later level are prose, a schedule count being a number; "+N on all other saving throws" spread across the sheet's d20 saves; literate-N plus M more spoken as N+M `Language: Other` picks. The Ultucan's voice abilities are granted as Ventriloquism, Imitate Voices & Sounds and Impersonation. Also `~026-chiang-ku-dragon-xp-ladder.sql`: the Chiang-Ku gains the same printed 17 ladder, which printed 50 gives every hatchling and the class never stored. The Ultucan's recognize and use poison has no catalog row and is prose. Every number read off renders of printed 17, 40-42, 44, 45 and 47; book-reconcile: 3/3 clean. Applied `--remote` before the merge. |
| 2026-09-27 | #1462 | **Hatchling R.C.C.s: Fire, Great Horned, Ice** (printed 25-27, 27-30, 33-34; printed 17 for the ladder, 50 for the player-character rule), `add-fire-dragon-class.sql`, `add-great-horned-dragon-class.sql`, `add-ice-dragon-class.sql`: classes 7 -> 10. The Kukulcan batch's shape and conventions (hatchling + adult variants; top-level skills, magic and psionics the hatchling's; adult psionics and magic as special abilities; dice spell counts as prose; `starting_money: 0`, `equipment_starting: []`). Language and literacy picks state a `bonus` over the `Other` rows, not a `base`. Every number read off a render; book-reconcile clean twice (hatchling pass 3/3, with one consistency note taken - the Great Horned's 4-hours-per-level metamorphosis against printed 15's two - and an adult-variant pass 3/3). Also `~027-dag-hatchling-language-picks.sql`: the Kukulcan, Lo-Dox and Night Stalker (#1460) stored their language and literacy picks with a flat `base` (96, 96, 98), which regression's frozen-pick rule missed only because their notes say "additional ones"; moved to the same bonus form, guarded, with read-backs. Checked `--remote` first; the #1461 three already use the bonus form. To be applied `--remote` before the merge, the three classes first and ~027 last. |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-09-26, before the
magic weapons were applied (a `--local` run with them reads 135 / 0):

```
  dag                112 / 0
```

**Re-measured 2026-09-27**, after #1442 was applied `--remote`:
`dag                135 / 0`, matching the `--local` figure above.

**112 traceable, nothing untraceable.** That is a statement about what has been
asked for, not about what the book holds. Still open: the playable
hatchling R.C.C.s not yet imported (see *Classes*), and the book has never had
a full inventory. The Dragon Helm name collision was settled on 2026-09-27 (ledger).
