# Rifts World Book 23: Xiticix Invasion — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-01)

**Rows citing this book:** none

Slug `xiticix-invasion`. Cached 2026-10-01 from
`Rifts- World Book 23 Xiticix Invasion.pdf`, 162 PDF pages, **text layer**
(no OCR). `--probe` median 3,436 chars/page, 36.8% stop words, 0.0%
private-use glyphs, so the words survive (not the `BOOK-INGEST-AUDIT` F73
glyph-dropped kind).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## The PDF is missing one printed page

**Printed 136 is not in the file.** Cache `p137` and `p138` hold byte-identical
text, and a render of each shows the folio 137: printed 137 was scanned twice
and the first copy sits where 136 belongs. The copy handed over on 2026-10-01
and the one in the books directory have the same SHA-1, so there is no second
source on this machine.

What printed 136 holds, by the Contents and the Quick Find: the start of
*CS Strike Force Durango* and the stat block of **Lieutenant Thomas Kent**.
Printed 137 opens mid-block with the end of his combat lines, his weapons and
his armor. His name, attributes, class, level and skills are on the lost page.

**Copeland** (a Free Thinker) is cut the other way: his block starts on
printed 135 and runs through his combat lines, and whatever follows them
(weapons, armor, equipment) is on the lost page.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p012` | 11 | +1 |
| `p050` | 49 | +1 |
| `p100` | 99 | +1 |
| `p136` | 135 | +1 |
| `p137` | 137 | the duplicate; **not** printed 136 |
| `p138` | 137 | +1 |
| `p139` | 138 | +1 |
| `p150` | 149 | +1 |
| `p161` | 160 | +1 |

One region, no `page_offset_exceptions`: the rule lands printed 137 on `p138`,
which is right, and printed 136 on `p137`, which holds the wrong page.
**`printed_pages` is 160.** Cache `p162` is blank. Cache `p001`-`p004` are
cover, warning, credits and title; `p005` is the Contents (printed 4) and
`p006` the Quick Find and the Maps list (printed 5). Cache `p084`, `p085` and
`p094` are full-page art with no text.

## Cache health

| key | cache pages | printed | where it matters |
|---|---|---|---|
| `welded_pages` | 3, 36, 108 | 2, 35, 107 | **107 is the end of Quiwan Li's block and the notes on Deathbringer Necromancers in general**: read it from a render. 2 is the credits, 35 a territory map |
| `corrupt_pages` | 74 (1), 109 (1), 117 (1), 129 (1), 152 (2) | 73, 108, 116, 128, 151 | **108 is Brok Magnil's stat block**: render it and read its numbers off the image. 73 is full-page art inside the Super-Warrior entry (the cache holds two stray characters and nothing else); 116 and 128 are adventure text, 151 a fort floor plan |
| `substituted_digits` | 46 pages | throughout | worst: cache p150 (10, a fort key), p35 and p140 (9 each), p141 (8), p59 (7), p34 (6), p19 and p67 (5 each). **p59 and p67 are the Leaper and the Elder Queen; p140-p141 are the Coalition quick stats.** Read the token as the dice it must be; a render does not help |
| duplicate page | 137 = 138 | 137 | see *The PDF is missing one printed page* |

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005** | 4 | *Content* | the printed page of every section |
| **p006** | 5 | *Quick Find* and *Maps* | a second reading of the page of every stat block, named NPC and map, with 15 maps listed |
| **p046** | 45 | hierarchy, colony breakdown and the *Alphabetical Listing* | which Xiticix forms exist: two larval and nine adult, and their share of a colony |

**Read p005 and p006 from a render.** The text layer delivers the names and
the page numbers as separate runs and drops some of the numbers, so they
cannot be paired by position. Both were read off 130 dpi renders for this
survey.

The two lists agree wherever they name the same thing, with two differences
that are the book's: the Contents puts the Xiticix Killer at 88 and its stat
block starts on printed 90; the Contents spells the fort *Barron* and one
Quick Find line spells it *Barren*.

**The book prints no Experience Tables.** Every Xiticix entry gives an average
level instead, and the two Psi-Stalker entries are reprints of a class that
has its ladder elsewhere.

## Inventory

Counted by structure (stat-block markers and Contents headings) over all 162
cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Overview, the Devouring Horde, Challenges | 7-11 | lore |
| Hive Cities, defenses, instincts and tactics | 12-19 | lore; a tower's M.D.C. on 14; squad and swarm sizes on 18-19 |
| Growth and life cycle, the homeworld | 20-24 | lore |
| The Xiticix Hives | 25-35 | six hive write-ups with their maps, a tower cutaway and a tunnel floor plan; two percentile tables of tunnel contents on 31 and 33 |
| Special Powers and Abilities | 36-43 | the shared natural abilities every adult form points back to: antennae, chemical abilities, sludge, regeneration, adhesion, flight |
| Larva Stage Xiticix | 43-45 | **2 stat blocks** (Nit, Grub) |
| Adult Xiticix R.C.C.s | 45-76 | **9 stat blocks**: Digger, Hunter, Leaper, Nanny, Young Queen, Elder Queen, Warrior, Super-Warrior, Worker |
| Xiticix Weapons | 77-82 | **15 weapon entries** (see *Catalog diff*); 83 and 84 are art |
| Prelude to War, the Coalition States | 85-91 | lore, the three Coalition plans, and the **Xiticix Killer** stat block from 90 |
| Lazlo's War | 92-99 | lore and possible allies; no stat blocks |
| Psi-Stalkers, a Private War | 100-108 | the Spider, Pony-Tail and Deathbringer tribes, **3 tribe bonus blocks** (103, 104, 105); **2 named NPCs** (Quiwan Li 105-107, Brok Magnil 107-108) |
| Psi-Stalker R.C.C. | 108-113 | the Coalition or civilized and the wild Psi-Stalker; the heading says it is reprinted from Lone Star with new material. Northern Tribes on 112 with a range map |
| Adventures, Lazlo vs the Xiticix | 114-126 | troop breakdown, plan of attack, adventure hooks; no stat blocks |
| A Hiveland Adventure | 127-140 | an adventure; **5 named NPCs** (the Free Thinkers, 133-135); Strike Force Durango 136-140: **1 named NPC on the missing page**, **2 typical-soldier blocks** on 137, and **4 Coalition units as quick stats** on 138-140 |
| CS Operations, Fort Barron, Fort Perrion | 141-152 | lore, a troop breakdown and a consignment list (143), **2 named NPCs** (Major Samuel Haim 144-145, Orion Greenfeld 145-146), two fort floor plans with keys |
| Heroes and Hardcases | 153-160 | **11 named NPCs**: the Wild Pack (4), Manitoba and Company (4), the Lazlo Triad (3) |

### Spells: zero

The `P.P.E.:` marker hits on 22 pages and every hit is a creature or NPC stat
line or a weapon's recharge cost. The book prints no spell description.
Quiwan Li's and Brok Magnil's spell lists name existing spells and point at
Mystic Russia for the Necromancer's powers.

### Psionic powers: zero

The `I.S.P.:` marker hits on 12 pages and every hit is a creature or NPC pool.
The Xiticix antennae and chemical abilities (printed 36-43) are natural
abilities with their own ranges and percentages, not catalog powers.

### Skills: zero

`Base Skill` appears on three pages (printed 38, 49, 109), each time inside a
natural ability. There is no new-skill list.

### Playable classes: zero new

No Xiticix entry carries a player-character line; each prints an average
level, a disposition and a colony role, and the hive-mind material on printed
17-19 and 36-43 describes them as opponents. They are `creatures` rows. The
only class entries with attribute requirements, skills and starting equipment
are the two Psi-Stalkers, and both are held.

## Classes

| entry | printed | tag | catalog today |
|---|---|---|---|
| Psi-Stalker, Coalition and civilized | 108-111 | reprint from Lone Star with new material | **held**: `psi-stalker` and the `mutant-psi-stalker` race, citing Rifts Ultimate Edition |
| Psi-Stalker, wild | 111-113 | same | **held**: `wild-psi-stalker` |

The Lone Star survey left both for the same reason (Rifts Ultimate Edition is
the later printing). What this book adds that neither printing holds is the
three tribe blocks:

| tribe | printed | what the block gives |
|---|---|---|
| Spider Tribe | 103 | attribute, initiative, strike and save bonuses, and a tracking bonus against the supernatural and the Xiticix |
| Pony-Tail Tribe | 104 | attribute, S.D.C. and initiative bonuses; level, alignment and weapon breakdowns |
| Deathbringer cult (wild Psi-Stalkers) | 105 | save, initiative, S.D.C. and hit point bonuses; a hand to hand split; Xiticix-exoskeleton armor with a rolled M.D.C. |

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01 with
`scripts/catalog-diff.mjs`. No row in any table cited this book.

### creatures: 12 entries, 1 matched, 11 missing, 0 false gaps

The match is the **Xiticix Killer**, held from Lone Star p.91-93; the block
here (from printed 90) is a reprint of it and is left. The other eleven are new,
and the nearest name to each is the Killer or the Cibola Pincer Warrior, which
are different creatures: Nit, Grub, Digger, Hunter, Leaper, Nanny, Young
Queen, Elder Queen, Warrior, Super-Warrior, Worker. No row in production has
*Xiticix* in its name besides the Killer.

### gear: 15 entries, 0 matched, 15 missing, 0 false gaps

Bayonet and hand-held knives, Double-Dagger, Hooked Short Sword, Mace or
Morning Star, Long Sword, Spear, Spike Whip, Beheading Axe, Sickle Axe (all
printed 77-80); Resin Claws, Resin Shoulder Spikes, Resin Spike Gun, Shooting
Shoulder Spikes (81-82); Resin Spitter and TK-Rifle (82).

The one near name, **Resin Spike**, is Wormwood's (p.42) and is a different
item. Eleven entries print a market price range; four are marked as available
only to Xiticix and have no price. The Resin Spike Gun's price range is
printed with a digit missing from its upper figure (printed 82).

Printed 81-82 set two entries side by side, and the text layer interleaves
the Resin Spike Gun's fields with the Shooting Shoulder Spikes': **read both
from a render.** The TK-Rifle's rate-of-fire line repeats the Spike Gun's
wording about spike bursts; store it as printed and say so.

### notable_npcs: 23 entries, 0 matched, 0 false gaps

No near match is closer than a shared word. Twenty-one are named characters
and two are typical-soldier blocks:

| group | printed | entries |
|---|---|---|
| Deathbringer necromancers | 105-108 | Quiwan Li, Brok Magnil |
| Free Thinkers | 133-135 | Raskin, Illyana, Cristobal, Summers, Copeland (**the tail of his block is on the missing page**) |
| Strike Force Durango | 136-137 | Lieutenant Thomas Kent (**head of the block is on the missing page**); Typical Dead Boy Commandos; Typical CS Elite RPA Pilots |
| Fort Barron | 144-146 | Major Samuel Haim, Orion Greenfeld |
| The Wild Pack | 153-155 | Commander Jess Helgeland, Sgt. Samuel, Corp. Chase, Corp. Chesterfield |
| Manitoba and Company | 155-158 | The Mighty Cassandra, Hidechek Gezenske, Manitoba Saskatchewan, Dekker Trons'stedaal |
| The Lazlo Triad | 159-160 | Serian Skeld, Sir Jericho Camlann, Omicron |

### vehicles: 4 entries, 4 held

| the book prints (138-140) | the catalog holds |
|---|---|
| Glitter Boy Killer | PA-300 Glitter Boy Killer Power Armor (Coalition War Campaign p.110-112) |
| Special Forces "Striker" SAMAS | PA-08A Special Forces "Striker" SAMAS (Coalition War Campaign p.119-122) |
| CR-004 Spider-Skull Walker | CR-004 Scout Spider-Skull Walker (Coalition War Campaign p.146-147) |
| CR-005 Scorpion-Skull Walker | CR-005 Scorpion-Skull Walker (Coalition War Campaign p.148-150) |

The diff matched one by name and reported three missing; all three are the
same units under a shorter heading. The book itself calls these quick stats
and sends the reader to Coalition War Campaign for the full entries.

## Extraction plan

Gear ships before creatures and NPCs, because their stat blocks name this
book's weapons (the Madhaven lesson).

1. **Gear** — 15 rows from printed 77-82. Printed 81-82 from a render.
2. **Creatures** — 11 rows from printed 43-76, through
   `scripts/bestiary-sql.mjs`. Each adult block leans on the shared abilities
   of printed 36-43; a row restates what it takes from there so it stands
   alone.
3. **Notable NPCs** — 20 named rows from printed 105-108, 133-135, 144-146
   and 153-160. Printed 107 and 108 from renders. Copeland's row carries what
   printed 135 gives and says that the rest is on a page this PDF lacks.

Each batch is extracted off renders by `book-extract-worker` where a page is
flagged above, and checked by `book-reconcile` before its script is written.

**For Nate to decide** before the batch they belong to:

- **Printed 136.** Lieutenant Thomas Kent cannot be imported from this PDF,
  and Copeland only in part. A scan of that one page would settle both;
  without one Kent is left out and the gap is recorded here.
- **The two typical-soldier blocks** (printed 137). They are generic, not
  named characters. Import as two `notable_npcs` rows, or leave.
- **The three tribe blocks** (printed 103-105). They could become a pick-one
  ability group on `wild-psi-stalker`, the way Lone Star's breed table landed
  on `mutant-dog`. That edits a held class and was not asked for; it waits for
  a yes.

What is deliberately left, with the reason for each:

- **The Xiticix Killer** (printed 90-91) — held from Lone Star in full.
- **The two Psi-Stalkers** (printed 108-113) — held from Rifts Ultimate
  Edition, the later printing; the entry says it is a reprint.
- **The four Coalition units** (printed 138-140) — held from Coalition War
  Campaign in full; these are quick stats.
- **The Deathbringer exoskeleton armor** (printed 105) — one line inside the
  tribe block with a rolled M.D.C. and no price or weight. It travels with
  the tribe-block decision.
- **Hive towers, tunnels, forts and their keys** (printed 12-16, 25-35,
  147-152) — places, not catalog rows.
- **The tunnel-contents tables** (printed 31, 33), the troop breakdowns and
  the consignment list (118, 143) — G.M. material.
- **Lore, plans, adventures and hooks.**

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/xiticix-invasion-survey` | cache built (162 pp), `xiticix-invasion` registered in `books.json`, this survey written, offset +1 verified, the missing printed 136 recorded. No data. |

### What remains

Everything in the plan. Nothing from this book has been imported.
