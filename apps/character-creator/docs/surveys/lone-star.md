# Rifts World Book 13: Lone Star — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-01)

**Rows citing this book:** none

Slug `lone-star`. Cached 2026-10-01 from `Rifts-WorldBook13-LoneStar.pdf`,
178 PDF pages, **text layer** (no OCR). `--probe` median 6,460 chars/page,
34.5% stop words, 0.0% private-use glyphs, so the words survive (not the
`BOOK-INGEST-AUDIT` F73 glyph-dropped kind).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on four pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p100` | 99 | +1 |
| `p150` | 149 | +1 |
| `p174` | 173 | +1 |
| `p175` | 174 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 174.** Cache
`p176` is the second page of the Experience Tables and prints no folio (it
belongs to the book and matters: see *Authority*); `p177` is an advertisement
and `p178` is blank. Cache `p001`-`p004` are cover, credits and front matter;
`p005`-`p006` are the Contents and the Quick Find.

## Cache health

| key | cache pages | printed | where it matters |
|---|---|---|---|
| `welded_pages` | 101, 127, 177 | 100, 126, — | **100 is the Psi-X Alien R.C.C.'s skill block**: read it from a render. 126 is Pecos Empire lore, 177 an advertisement |
| `corrupt_pages` | 15 (1), 61 (1), 125 (2) | 14, 60, 124 | **60 is the NG-400 Stinger and NG-480 Turbo hovercycles** and **124 the two doctors' stat blocks**: render both and read their numbers off the image. 14 is the state map |
| `substituted_digits` | 35 pages | throughout | worst: cache p75 and p134 (6 hits each), p136 (5), p164 (4), p51, p53, p54, p65 (3 each). The gear chapter prints one vambrace price as letters. **Read the token as the dice or figure it must be**; a render does not help |

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005** | 4 | *Contents* | the printed page of every section |
| **p006** | 5 | *Quick Find*, with its own *O.C.C.s & R.C.C.s* list | a second reading of every class page: 24 lines naming 23 entries (the Pecos Raider is listed twice, under B and under P). The text layer delivers the names and the page numbers as two separate runs in the same order, so pair them by position |
| **p175-p176** | 174 and unnumbered | *Experience Tables* | a third list of class pages (20 lines), then 13 ladders covering 19 classes plus the Xiticix Killer — see *Classes* |
| each class entry | — | its own tag line and its *Player Character Note* | playability. Per the New West lesson, **an XP ladder is not evidence of playability**; the entry's own line is |

The three lists agree on every page number. They disagree on what counts as
a class: the Quick Find lists a *Wolf Division* entry on printed 107 and a
*Feral* Dog Boy on printed 38, and the Experience Tables list neither. The
pages themselves settle it (see *Classes*).

## Inventory

Counted by structure (stat-block markers and Contents headings) over all 178
cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Lone Star, the Complex, Sector 357 | 9-21 | lore and one map; no stat blocks |
| The Dog Pack | 22-45 | lore, breeding and training, canine psychology; **4 R.C.C.s** (Dog Boy, Sea Dog, K-9 Sniffer, Kill Hound), the Feral and Free Born notes, 2 optional random tables |
| Dog Boy Equipment | 46-53 | **29 gear entries** by name, 12 of them already in the catalog |
| Hovercycles | 54-61 | **7 hovercycles**, each with an *M.D.C. by Location* block and priced weapon options |
| CS Death Wing | 62-64 | **1 power armor** with a location block and a weapon-systems list |
| GED Mutant Experiments | 64-95 | genetics lore, 1 optional mutation table; **8 R.C.C.s** (Ursa-Warrior, Battle Cat, Kill Cat, Mini Monkey Spy, Monkey Boy Soldier, Monkey Boy Tech, Mutant Rat, Mutant Bat); the Xiticix Killer (NPC); runaway mutants and the underground (lore) |
| Other Areas of GED Research | 96-99 | M.O.M. lore, 1 random table of human special abilities, **1 R.C.C.** (Psi-X Alien) |
| Notable CS Characters | 100-125 | **9 named NPCs** with stat blocks, plus a named Dog Boy squad on printed 119 (7 short blocks on one page) |
| Pecos Empire | 126-137 | lore: bandit life, organizations, settlements |
| Characters of Note | 138-152 | **9 named NPCs** with stat blocks; the Sabre Warriors breakdown on printed 149 is a roster in prose, not a stat block |
| Pecos Bandits | 153-164 | **1 O.C.C.** (Pecos Raider) and **5 R.C.C.s** (Tokanii, Psi-Stalker civilized, Psi-Stalker wild, Simvan Monster Rider, Brodkil); Ostrosaurus quick stats on printed 163 |
| Geographic overview | 165-174 | lore and maps |
| Experience Tables | 174 and after | 13 ladders |

### Spells: zero

The `P.P.E.:` marker hits 28 times and every hit is a class or NPC stat line.
The book prints no spell description.

### Psionic powers: zero

The `I.S.P.:` marker hits on 14 pages and every hit is a class or NPC pool.
The Dog Boy's special sensing abilities (printed 33-34) are class abilities
with their own percentages, not catalog powers.

### Skills: zero

No new-skill list and no skill description with a *Base Skill* line outside a
class's own ability block. Every skill the classes name is an existing one.

## Classes

### What the three lists name, and what the pages hold

| entry | printed | tag | ladder on the XP pages | catalog today |
|---|---|---|---|---|
| Dog Boy Soldier R.C.C. | 32-36 | player character, with a note | Dog Boy (CS Soldier), Sea Dog | **held**: `dog-boy` and the `mutant-dog` race, both citing Rifts Ultimate Edition |
| Sea Dog R.C.C. | 40-41 | same note as the Dog Boy | shares the Dog Boy's | missing |
| K-9 Sniffer R.C.C. | 41-43 | same note | Dog Boy: K-9 Sniffer | missing |
| Kill Hound R.C.C. | 43-45 | same note | Kill Hound, Kill Cat | missing |
| Ursa-Warrior (Mutant Bear) R.C.C. | 72-75 | player character, with a note | Ursa-Warrior (Bear) | missing |
| Battle Cat R.C.C. | 76-78 | player character, with a note | Monkey Boy Soldier, Battle Cat | missing |
| Kill Cat R.C.C. | 79-80 | player character, with a note | Kill Hound, Kill Cat | missing |
| Mini Monkey Spy R.C.C. | 81-83 | playable at the G.M.'s option; the entry itself steers it to NPC use | Monkey Mini Spy and most intelligent mutant animals | missing |
| Monkey Boy Soldier R.C.C. | 83-85 | player character, with a note | Monkey Boy Soldier, Battle Cat | missing |
| Monkey Boy Tech R.C.C. | 85 | modifications to the Soldier | Monkey Boy Tech, Simvan | missing |
| Mutant Rat R.C.C. | 85-88 | player character, with a note | Mutant Bat, Mutant Rat | missing |
| Mutant Bat R.C.C. | 88-90 | player character, with a note | Mutant Bat, Mutant Rat | missing |
| Psi-X Alien R.C.C. | 98-100 | optional player character | Psi-X Alien, Xiticix Killer | missing |
| Pecos Raider O.C.C. | 153-154 | player character, with a note | Pecos Raider a.k.a. Bandit | **held**: Nate ruled on 2026-10-01 that it is New West's `bandit` (p.83-85) under another name |
| Tokanii R.C.C. | 154-156 | optional player character | Tokanii | missing |
| Psi-Stalker, CS and Civilized | 156-159 | reprinted in part from the main book, with new material | Wild or Civilized Psi-Stalker | **held**: `psi-stalker` and the `mutant-psi-stalker` race, citing Rifts Ultimate Edition |
| Psi-Stalker, Wild | 160-161 | same | same | **held**: `wild-psi-stalker` |
| Simvan Monster Rider R.C.C. | 162-163 | optional player character | Monkey Boy Tech, Simvan | missing |
| Brodkil R.C.C. | 164 | NPC villain and optional player character | Brodkil (sub-demon) | no class; a `creatures` row cites Triax p.220-221 |

**Fifteen classes are missing.** The Pecos Raider is not one of them (see
its row).

### Listed, and not a class

- **Wolf Division** (Quick Find, printed 107) is a description of a military
  unit inside General Kashbrook's entry. It has no attributes, no skill block
  and no ladder.
- **Feral Dog Boy** (Quick Find, printed 38-40) is a set of changes to the Dog
  Boy for runaways, and the Free Born paragraph tells the player to pick an
  existing O.C.C. It has no skill block of its own. The Experience Tables
  note sends both to the table the character was created under.
- **Xiticix Killer** (printed 91-93) has a ladder and no player-character line.
  It is an NPC: a `creatures` row.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01. No row in any table
cited this book. Fourteen classes mention it in prose only.

### gear: 29 entries, 12 matched, 17 reported missing, 4 of those false gaps

`node scripts/catalog-diff.mjs --remote --table gear --entries gear.json`
returns **matched 12, missing 17** (one match by alias: Dog Pack Spikes).

| the book prints | the catalog holds | verdict |
|---|---|---|
| Fusion Block | Fusion Block (Light) | false gap, to confirm against the page |
| Hand-held Flare | Handheld Flare | false gap |
| CS Hand Grenades | Fragmentation, Explosive and Smoke Grenade rows citing Coalition War Campaign p.98 | false gap: a heading over rows already held |
| Dog Pack DPM Light Riot Armor | Dog Pack DPM Riot Armor (Rifts Ultimate Edition) | same armor; compare the M.D.C. at extraction and keep the later book's row |
| C-27 Light Plasma Cannon | C-27 Heavy Plasma Cannon (Coalition War Campaign p.93) | **open**: read both pages before deciding |

**Thirteen rows are new**: five Vibro-Blade Vambrace variants (printed 48-49),
ES-10 Electro-Stun Hand Prod and ES-20 Electro-Stun Spear (49-50), Rope Pole
(50-51), CN-1 Net Gun (51), Mutant Animal Restraining Harness (51-52), the
DPM D1 and D2 modified Dead Boy armors (52-53), and the C-27 if it proves
distinct. Psyscape's *Electro-Stunner* (p.69) is a different item.

### vehicles: 8 entries, 0 matched, 1 false gap

| the book prints | the catalog holds | verdict |
|---|---|---|
| NG-300 Speedster | Speedster Hovercycle (Rifts Ultimate Edition p.266) | same vehicle; leave the held row |
| NG-230 Prowler | VX-635 Prowler (Triax) | different vehicles |

**Seven rows are new**: MI-3000 Firefly, MI-1010 Desert Fox, NG-220 Rocket,
NG-230 Prowler, NG-400 Stinger, NG-480 Turbo, and the CS Death Wing armor.

### notable_npcs: 18 entries, 0 matched, 0 false gaps

All 18 named characters are missing, and no near match is closer than a
shared title word.

### creatures

The Xiticix Killer is missing. Ostrosaurus is held (New West p.153-155) and
the book prints only quick stats for it. Brodkil is held (Triax).

## Extraction plan

Gear ships before classes, because the classes name this book's items
(the Madhaven lesson).

1. **Gear** — 13 rows from printed 46-53, numbers read off a render for the
   vambrace prices (digit cipher) and the armor blocks.
2. **Vehicles** — 7 rows from printed 54-64 with their location blocks.
   Printed 60 is a corrupt page: both hovercycles on it come off a render.
3. **Dog Pack classes** — Sea Dog, K-9 Sniffer, Kill Hound (printed 40-45).
4. **GED mutant classes** — Ursa-Warrior, Battle Cat, Kill Cat, Monkey Boy
   Soldier, Monkey Boy Tech, Mutant Rat, Mutant Bat, Mini Monkey Spy
   (printed 72-90), and the Psi-X Alien (98-100; printed 100 from a render).
5. **Pecos classes** — Tokanii, Simvan Monster Rider, Brodkil (printed
   154-164).
6. **Creatures and notable NPCs** — the Xiticix Killer, the 18 named
   characters, and the seven Quiet Hunters of printed 119 as rows of their
   own (Nate, 2026-10-01), through `scripts/bestiary-sql.mjs`. Printed 124
   from a render.
7. **The Dog Boy material** — see *The Dog Boy, in full* below.

What is deliberately left, with the reason for each:

- **The two Psi-Stalkers** — held from Rifts Ultimate Edition, the later
  printing. The entry says of itself that it is a partial reprint.
- **The Pecos Raider** — held as New West's `bandit`.
- **Wolf Division** — a unit description, not a class. Its members are
  reachable as the Wolf breed (step 7).
- **Mutations Gone Wrong** (printed 71) and **Human Special Abilities**
  (printed 97) — the first is written for NPC mutants; the second is not Dog
  Boy material. Not asked for; raise again if wanted.
- **Ostrosaurus quick stats** (printed 163) — held from New West in full.
- **Weapon options priced inside each hovercycle** — recorded in the vehicle
  row's description; nothing reads the vehicle weapon table for a sheet.
- **Weapons reprinted in the gear chapter** (C-14, C-18, CP-40, grenades,
  vibro-blades, Neural Mace, Dog Pack Spikes) — held, citing the books that
  print them in full.
- **Lore, maps, settlements and bandit organizations.**

## The Dog Boy, in full

Nate asked on 2026-10-01 for the Dog Boy material the first plan left out,
and said changes to the creator are in scope for it (`book-survey` §8,
tier 2). Each proposal below goes through `audit-premise-auditor` before
it is scoped.

The catalog already splits the Dog Boy into the `mutant-dog` race and the
`dog-boy` occupation (`BOOK-INGEST-AUDIT` F110). Most of this lands on the
race, where every Dog Pack occupation inherits it.

| printed | material | where it goes | needs code? |
|---|---|---|---|
| 37 | Type/Breed of Dog, 20 bands | a pick-one `special_abilities` group on `mutant-dog`, one ability per band, each carrying its attribute, S.D.C. and initiative bonuses; swim percentages, track-by-smell changes and bite damage in the ability's text | no. Checked 2026-10-01: an R.C.C. carries pick-one ability groups today, and an ability grants `bonuses` and `psionics` |
| 38 | Mutation Abnormality, 13 bands | a second pick-one group on `mutant-dog`, with a "none" option because the table is optional. The three psionic bands carry a `psionics` block | no, if one class may hold two pick-one groups; confirm at the premise audit |
| 37 | Dog Boy's Height, 7 bands | not a mechanic; named in the race's description | no |
| 38-39 | Feral Dog Boy (a runaway) | the `dog-boy` occupation with the adventurer's equipment and money in place of the soldier's | to decide: a variant can replace money, not equipment |
| 39 | Free Born | `mutant-dog` paired with an ordinary occupation. The book's own list of typical occupations and its secondary-skill count for such a pairing go on the race | to check: which occupations refuse the race today, and whether a race can state a pairing's secondary-skill count |
| 32-36 | the Dog Boy entry itself | compared field by field against the held Rifts Ultimate Edition rows; differences recorded here, the later book wins | no |
| 40 | Sea Dog's Newfoundland requirement | a breed the table on printed 37 does not list; added to the breed group, citing printed 40 | no |
| — | rolling the two tables instead of picking | a roll button on a pick-one group whose options carry percentile bands | **yes**, a wizard change. Useful beyond this book: the Gypsy Gifted and Africa's percentile splits are the same shape |

Two things an ability cannot do today, both recorded in the text of the
ability rather than applied: grant or re-base a skill (the breed table's
swimming percentages), and change a natural ability's percentage (track by
smell).

The Dog Pack occupations of step 3 take `mutant-dog` as their only race, so
they ship after the breed group exists.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/lone-star-survey` | cache built (178 pp), `lone-star` registered in `books.json`, this survey written, offset +1 verified. No data. |

### What remains

Nothing has shipped, so `source-coverage.mjs` has no line for this book yet.
Paste its output here with the first data PR.
