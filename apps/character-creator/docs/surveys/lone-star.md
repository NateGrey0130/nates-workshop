# Rifts World Book 13: Lone Star — survey

**Status:** `importing` — gear, vehicles, the Dog Boy tables and all fifteen classes shipped; the Xiticix Killer and the notable NPCs to come. (2026-10-01)

**Rows citing this book:** classes 15, gear 14, vehicles 7

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
| C-27 Light Plasma Cannon | C-27 Heavy Plasma Cannon (Coalition War Campaign p.93) | false gap: printed 47 says the same weapon was moved from the heavy class to the light one |

**Twelve rows are new**: five Vibro-Blade Vambrace variants (printed 48-49),
ES-10 Electro-Stun Hand Prod and ES-20 Electro-Stun Spear (49-50), Rope Pole
(50-51), CN-1 Net Gun (51), Mutant Animal Restraining Harness (51-52), and the
DPM D1 and D2 modified Dead Boy armors (52-53). Psyscape's *Electro-Stunner*
(p.69) is a different item.

Two held rows disagree with this book and were left as they are, because
Rifts Ultimate Edition is the later printing:

- **Dog Pack DPM Riot Armor** — held at main body 30 M.D.C. and 8 lbs; printed
  52 here gives the light riot armor 50 M.D.C. and 10 lbs.
- **Neural Mace** — held with no price; printed 49 here prices it at 8,000
  credits and gives it 100 M.D.C. and a payload of 100 stun attacks.

### vehicles: 8 entries, 0 matched, 1 false gap

| the book prints | the catalog holds | verdict |
|---|---|---|
| NG-300 Speedster | Speedster Hovercycle (Rifts Ultimate Edition p.266) | same vehicle; the held row is left. It carries main body 85 where printed 55 here gives 75 |
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

1. **Gear** — 12 rows from printed 48-53. **Shipped.**
2. **Vehicles** — 7 rows from printed 55-64 with 57 location rows and 33
   weapon rows. **Shipped.**
3. **Dog Pack classes** — Sea Dog, K-9 Sniffer, Kill Hound (printed 40-45).
   **Shipped**, each a self-contained R.C.C. restating what its entry takes
   from the Dog Boy's.
4. **GED mutant classes** — Ursa-Warrior, Battle Cat, Kill Cat, Monkey Boy
   Soldier, Monkey Boy Tech, Mutant Rat, Mutant Bat, Mini Monkey Spy
   (printed 72-89), and the Psi-X Alien (98-100). **Shipped**, with two gear
   rows for the Mini Monkey Spy's custom armor (printed 83).
5. **Pecos classes** — Tokanii, Simvan Monster Rider, Brodkil (printed
   154-164). **Shipped.**
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

**What shipped** (`pal/data/lone-star-dog-breeds`), with no code change:

| material | where it went |
|---|---|
| Type/Breed of Dog, 20 bands | a pick-one `special_abilities` group on `mutant-dog`, plus an "other or mixed" option. Band 66-70 prints two breeds with different S.D.C. and is two options |
| Mutation Abnormality, 15 bands | a second pick-one group on `mutant-dog`, plus a "none" option. The two "more psionics" bands raise the race's one Sensitive pick to two and four; band 96-00 is text only |
| Dog Boy's Height, 7 bands | in the text of the breed group's last option |
| Feral Dog Boy (printed 38-39) | a line on the `dog-boy` occupation's restrictions: same class, and what an adventurer's kit replaces the soldier's with. Not applied automatically |
| Free Born (printed 39) | a line on `mutant-dog`'s restrictions: the typical occupations, the book's secondary-skill count for the pairing, its money and equipment. The race already pairs with any occupation that does not restrict race, so a Free Born is `mutant-dog` plus that occupation. Not applied automatically |

**Which printing.** Rifts Ultimate Edition printed 148-149 reprints both tables,
and it is the later book and the one the Dog Boy cites. It adds a Perception
bonus to 17 breeds and one abnormality, gives the Coonhound +5% to track by
smell where printed 37 here gives +2%, the Wolf a 5D6 full bite where this book
gives 4D6, and band 86-90 a +2 save vs possession. **RUE's figures are stored.**
`book-reconcile` read both printings off 170 dpi renders and found no
disagreement with either, so the differences above are the books', not a
misreading.

**Applied as numbers:** attribute dice, S.D.C., hit points, I.S.P.,
initiative, Perception, strike, attacks and saves. **In the option's text:**
swim percentages, track-by-smell changes, bite damage, size, skill bonuses,
the Greyhound's dice-valued initiative bonus and the Bulldog's Spd penalty.

**The Dog Boy entry itself** (printed 32-36) against the held rows, which cite
Rifts Ultimate Edition and are left as they are: this book gives Dragonese at
90% beside American, Weapon Systems +10%, Hand to Hand: Martial Arts, one W.P.
of choice, eight secondary skills (two more at levels 2, 4, 8 and 12), Pilot
Related: Any, and heavy riot armor at 50 M.D.C. as the standard issue.

**Still open, and not done:** a roll button on a pick-one group whose options
carry percentile bands. It is a wizard change, it would also serve the Gypsy
Gifted and Africa's percentile splits, and nothing above needs it. The three
Dog Pack specialists of step 3 (Sea Dog, K-9 Sniffer, Kill Hound) print their
own complete stat blocks and are self-contained classes, so they do not take
the breed group; the Sea Dog and K-9 Sniffer entries say the size and breed
tables are not rolled for them.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/lone-star-survey` | cache built (178 pp), `lone-star` registered in `books.json`, this survey written, offset +1 verified. No data. |
| 2026-10-01 | `pal/data/lone-star-gear` | 12 gear rows (`add-lone-star-gear.sql`), reconciled 12 of 12 against 170 dpi renders by `book-reconcile`. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/lone-star-vehicles` | 7 vehicles, 57 M.D.C. locations, 33 weapon entries (`add-lone-star-vehicles.sql`): six hovercycles and the CS Death Wing. Extracted off 170 dpi renders by `book-extract-worker`; `book-reconcile` checked 7 of 7 and its one disagreement (a word in the Death Wing's description) was corrected. Three figures are stored as printed and say so in their rows. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/lone-star-dog-breeds` | `~055-dog-boy-breeds-and-mutations.sql`: the Type/Breed and Mutation Abnormality tables as two pick-one groups on `mutant-dog` (RUE's printing), a Free Born line on the race and a Feral Dog Boy line on `dog-boy`. Edits two held classes; adds no row citing this book. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/lone-star-dog-pack-classes` | 3 classes: `sea-dog`, `k-9-sniffer`, `kill-hound`. Drafted one agent per class from a shared brief, numbers read off 170 dpi renders; `book-reconcile` checked all three against printed 32-36 and 40-45 and the Experience Tables, and its six equipment-row findings were harmonised. No gear stubs. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/lone-star-pecos-classes` | 3 classes: `tokanii`, `simvan-monster-rider`, `brodkil`. `book-reconcile` read all three against renders of printed 154-156 and 162-164 and the Experience Tables: no disagreements. No gear stubs. The Simvan's two sexes differ in P.P.E., psionics and skills and are two variants plus a matching pick-one psionics ability; the Brodkil's five attacks are stored as printed, and the page does not say whether they include its listed hand to hand. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/lone-star-mutant-classes` | 9 classes: `ursa-warrior`, `battle-cat`, `kill-cat`, `mini-monkey-spy`, `monkey-boy-soldier`, `monkey-boy-tech`, `mutant-rat`, `mutant-bat`, `psi-x-alien`; 2 gear rows (`add-lone-star-mini-monkey-armor.sql`). Three `book-reconcile` passes against renders; their findings (the Kill Cat's S.D.C. field, money and I.S.P. wording, one page range, one citation, one garbled sentence) were applied by one harmoniser. Species are variants on the bear, the Battle Cat and the Monkey Boy Soldier, and a pick-one ability on the Kill Cat. No gear stubs; a printed comb is not stored. Applied `--remote` before the PR. |

### What remains

Nothing has shipped, so `source-coverage.mjs` has no line for this book yet.
Paste its output here with the first data PR.
