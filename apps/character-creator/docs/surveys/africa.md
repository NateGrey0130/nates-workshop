# Rifts World Book 4: Africa — survey

**Status:** `importing` — all 53 spells are in; gear and vehicles next. Mind Bleeder powers and class are Psyscape's, Erin Tarn and Thorpe Coalition War Campaign's. (2026-09-25)

**Rows citing this book:** spells 53

Slug `africa`. Cached 2026-09-25 from
`604225358-Rifts-World-Book-04-Africa.pdf`, 162 PDF pages, **text layer** (no
OCR). `--probe` median 4,968 chars/page, 35.1% stop words, so this is a real
text layer and not the glyph-dropped kind (`BOOK-INGEST-AUDIT` F73).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on six pages, and again by all four slice
inventories, which compared the folio on every page they read:

| cache page | folio printed on it | offset |
|---|---|---|
| `p010` | 9 | +1 |
| `p030` | 29 | +1 |
| `p060` | 59 | +1 |
| `p090` | 89 | +1 |
| `p150` | 149 | +1 |
| `p161` | 160 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 160**;
`ocr-book.py` wrote 158 into the manifest, because cache p160 and p161 set
their folios split across a space (`1 59`, `1 60`). Cache `p162` is the back
cover.

## Cache health

| key | pages | where it matters |
|---|---|---|
| `welded_pages` | 5, 6 | front matter (credits, Contents). Nothing to extract |
| `corrupt_pages` | 68, 71, 81, 96, 118, 121, 123 | one or two hits each. The slice readers found clean game text on all of them; p081 (printed 80) is an artist credit. Still read numbers off a render per §0 |
| `substituted_digits` | 19 pages, most at one hit | every instance seen is `lD6`/`lD4` for 1D6/1D4. p028 (printed 27, Pestilence) carries five |
| **not flagged, still wrong** | printed 140-141 | the Phoenix weapon blocks print `306+6`, `406`, `506`, `606`, `104` for 3D6+6, 4D6, 5D6, 6D6, 1D4 — a D-for-0 fault the detector does not count. **Render these pages** before transcribing |
| **not flagged, scrambled** | printed 29 (War), printed 160 (XP tables) | column reflow detaches labels from numbers. Printed 160 was rendered at survey time, see below |
| blank / art-only | printed 10, 13, 14, 21, 25, 31, 39, 91, 103, 142 | printed 39 is garbage glyphs rather than empty; it is an illustration inside Set's entry |
| suspect ink | printed 102 | the Necromancer's animated human-sized corpse S.D.C. reads `SO`. Render it |

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** (cache p005-p006) | *Contents* | page of every section, class, spell list and NPC. Welded, but the entries survive |
| **78** | *Alphabetical List of Bad Medicine* | the African Witch's twelve own spells, with P.P.E. |
| **78** | *Available Common Spell Magic* (Witch) | 39 existing invocations by level 1-13, at **double** their normal P.P.E. for a witch |
| **108** | *Necro-Magic alphabetical list* | level and P.P.E. of all eighteen necromancy spells. **The level authority**: the descriptions at 105-107 print no level |
| **108** | *Available Common Spell Magic* (Necromancer) | existing invocations levels 1-15, double P.P.E. |
| **108-109** | *The Cost of Specific Components* | necromancy body-part prices by creature type |
| **160** | *O.C.C. & R.C.C. Experience Levels* | nine ladders, below |

### The XP ladders (printed 160)

**Read from a 150 dpi render**, because the text layer interleaves the
column headers. Nine ladders in three rows of three:

| ladder | classes |
|---|---|
| Tree People, Pygmy Hunter & Tautons | three R.C.C.s |
| Pygmy Shaman & Ramen | two R.C.C.s |
| Agogwe & Crocodillians | two R.C.C.s |
| African Priest | O.C.C. |
| African Medicine Man | O.C.C. |
| African Rain Maker | O.C.C. |
| African Witch | O.C.C. |
| Necromancer & Phoenixi | O.C.C. and R.C.C. |
| Mind Bleeder | R.C.C. |

A note under the table says the **Children of Amon can be any O.C.C.** (the
cache reads `D.C.C.`). **Anomaly:** the *Necromancer & Phoenixi* ladder's
level 15 prints a lower bound of 350,921 against a level 14 upper bound of
350,700. Transcribe what is printed and note it; do not correct it.

Every class the book defines has a ladder here, so none needs a borrowed one.

## Inventory

Counted by structure over all 162 cached pages, by four slice readers
(printed 1-45, 46-92, 93-125, 126-160), then hand-checked where a count
mattered.

| section | printed | what is there |
|---|---|---|
| Erin Tarn's letters | 7-10 | lore |
| The Four Horsemen | 11-35 | **Death** (12-18), **Famine** (19-22), **Pestilence** (23-27), **War** (30-33), the **Armageddon Creature** (34-35, the four merged); each Horseman's netherbeast mount (**Bones, Cyno, Raid, Carnage**), plus **Devil Skulls**, **Nightmare Zombies** and **Magic Beetles**; one greatest rune weapon each (Staff of Death, Staff of Decay, Staff of Destruction, Rune Ball & Chain); three rules tables at 24-27 (Trauma Insanity, Bites & Stings, Types of Diseases) |
| Gods of Darkness | 38-48 | **Set** (38-40), **Anubis** (40-42), **Apepi** (42-43), **Amon** (43-45), **Anhur** (45-46), **Ammit** (46-47), **Bes** (47-49), with nine named weapons (Black Rod of the Four Winds, the Impaler, Sword of Anubis, Blood Fellow, the Enslaver, Anhur's five, Mee and Fea) |
| Gods of Light | 48-59 | **Osiris** (48-50) and his fourteen body-part artifacts, **Ra** (49-52), **Thoth** (52-55), **Isis** (54-56), **Horus** (56-58), **Bennu** (57-59), **Apis** (58-60), with seven named weapons |
| Minions of the Gods | 59-71 | **Phoenixi** (60-62), **Ramen** (61-64), **Tautons** (63-65) and **Crocodillian** (67-70) R.C.C.s, all optional player characters; **Children of Amon** (65-66, a slave population, any O.C.C.) with three bio-wizard organisms (**Transfortifiers, Chest Amalgamate, Zombitron**); **Jinn** (69-71), NPC-only by the book's own statement. Two racial psionic powers: *Psionic Empathy with Animals* (Ramen, 62-63) and *with Reptiles* (Crocodillian, 69) |
| The Mystic World | 70-92 | **African Witch** O.C.C. (72-74, NPC villain, not recommended for players) and her **12 spells** (74-78); **Medicine Man** O.C.C. (79-82) with **charms and amulets** (79-82); **Rain Maker** O.C.C. (83-85); **Priest** O.C.C. (85-87); **Ceremonial Magic** (86-92): 11 drum messages, **7 chants**, **8 dances**, **7 rain maker dances**, plus the Medicine Man's two protection rituals and witch lure (82) |
| Mind Bleeder | 93-99 | **Mind Bleeder** R.C.C. (93-95) and **15 new psionic powers** (96-98) |
| Necromancer | 99-109 | **Necromancer** O.C.C. (99-104, optional, evil or selfish only), Union with the Dead and Augmentation tables (26 entries, 100-102), the Necromancer Insanity Table (104), **18 necro-magic spells** (105-108), the **Magot** as summoned (106, a pointer to Conversion Book One), component prices (108-109) |
| Rifts Africa geography | 109-125 | **Pygmy Hunter** (114-115) and **Pygmy Shaman** (115-116) R.C.C.s; **21 talismans and 11 charms** (116); **Agogwe** (117-119) and **Tree People** (118-120) R.C.C.s. Named hauntings and leaders with no stat blocks |
| Wildlife and Monsters | 126-131 | **5 animals** (Wildebeest, Cape Buffalo, African Lion, Leopard, Typical Crocodile); **4 monsters** (Erythrosuchus/Mokele-mbembe, Massospondylus, Buti-fas, Demonic Cannibals). Kongamato is legend with no stats |
| The Phoenix Empire | 131-144 | Punishments table (133); **11 troop templates** (135-136); **Phoenix power armor, Sand Skimmer, Sand Crawler, Robot Spy Wing** (136-140); **7 weapons and a shield** (140-141); **Pharaoh Rama-Set** (141-144) |
| The Gathering of Heroes | 145-156 | **Katrina Sun** (Isis in disguise, 145-147), **Erin Tarn** (147-148), **Sir Winslow Thorpe** (148-150), **Victor Lazlo** (150-152), **Lo Fung** (152-154), **Fang-Lo** and **Abkii** (154, quick stats), **Sebek** (154-156); seven NPC-carried items |
| Encounters | 156-158 | a raid-purpose table and Nightmare Zombies again |
| Experience tables | 160 | above |

### Things this book has zero of, checked rather than assumed

- **Skills: none defined.** No skill block anywhere in the stat-block scan.
- **Common invocations: none defined.** The Witch and Necromancer lists at 78
  and 108 name existing spells only; so do the Medicine Man's and Rain Maker's
  starting spells.

## Classes

### Playable O.C.C.s (5)

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| Medicine Man | 79-82 | African Medicine Man | `medicine-man` | innate sensitive psionics, fixed starting spells, charm-making |
| Rain Maker | 83-85 | African Rain Maker | `rain-maker` | mega-damage lightning as an ability; the rain maker dances |
| Priest | 85-87 | African Priest | `african-priest` | chants and dances. `priest` alone is too generic an id for the catalog |
| Necromancer | 99-104 | Necromancer & Phoenixi | `necromancer` | **optional**, alignment-restricted. `necromancer-russian` (Mystic Russia) exists beside it; this is the original. Union with the Dead and Augmentation are tables of P.P.E.-priced options: prose plus a pool, not 26 abilities |
| African Witch | 72-74 | African Witch | `african-witch` | the book marks it an NPC villain and not recommended for players. **Imported anyway (Nate, 2026-09-25)**, flagged in the class note, on the Hidden Witch precedent (Mystic Russia imported that NPC-villain O.C.C.), because the NPC generator rolls from published classes. Witch Insanity Table is prose |

### Playable R.C.C.s (8)

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| Pygmy Hunter | 114-115 | Tree People, Pygmy Hunter & Tautons | `pygmy-hunter` | |
| Pygmy Shaman | 115-116 | Pygmy Shaman & Ramen | `pygmy-shaman` | no spellcasting; makes talismans and charms (below) |
| Agogwe | 117-119 | Agogwe & Crocodillians | `agogwe` | three psionic tiers by percentile (60/37/3). Expect three variants |
| Tree People | 118-120 | Tree People, Pygmy Hunter & Tautons | `tree-people` | |
| Phoenixi | 60-62 | Necromancer & Phoenixi | `phoenixi` | the creature row `phoenixi` (Dragons and Gods) is a different table; no collision |
| Ramen | 61-64 | Pygmy Shaman & Ramen | `ramen` | carries Psionic Empathy with Animals |
| Tautons | 63-65 | Tree People, Pygmy Hunter & Tautons | `tauton` | |
| Crocodillian | 67-70 | Agogwe & Crocodillians | `crocodillian` | carries Psionic Empathy with Reptiles |

**None of the thirteen ids exists in production** (checked 2026-09-25).

**The Mind Bleeder R.C.C. (printed 93-95) is NOT this book's to import.**
Psyscape reprints it (its printed 52-55) and plans `mind-bleeder` in its own
class PR; the later book wins. Its ladder here (printed 160) can be compared
then, and a difference goes in that class's note.

### Not a class

- **Children of Amon** (65-66): a slave population that takes any O.C.C.,
  with no racial stat block of its own. Left as setting; its three bio-wizard
  organisms become creatures.
- **Jinn** (69-71): R.C.C.-shaped, stated not a player character. A
  **creature**.

## Spells

**Corrected 2026-09-25, at the first spell import.** This section first said
all four groups were new and stored unprefixed. Both were wrong:

- **The eighteen necro-magic spells are REPRINTED in Mystic Russia's Bone
  Magic** and were already in production as `Bone:` rows. The survey's diff
  compared bare names and missed every one, which is the namespace trap the
  catalog's half-prefixed spell table sets. They were imported as their own
  `Necromancy:` rows anyway, seventeen carrying `same_spell_as` to the `Bone:`
  row (checked by `scripts/same-spell-lib.mjs`), because the tradition gates
  the picker and Bone Magic holds 59 spells this book's Necromancer does not
  know. **Maggots stays unlinked**: Mystic Russia prints it at level 4 and "2
  days" against this book's level 5 and "days".
- **Names ARE prefixed**, by the convention every World Book tradition in the
  catalog follows: `Necromancy:` and `Bad Medicine:` (the book's own name for
  the witch's list, printed 78). `Bad Medicine: Poison Touch` is a different
  spell from `Bone: Poison Touch` and is on regression's `mustNotLink`.

| group | printed | rows | level | tradition |
|---|---|---|---|---|
| African Witch's bad medicine | 74-78 | 12 | **0** — the book states no level for them; `ppe` from the page 78 list | `african-witch` |
| Necro-magic | 105-108 | 18 | from the 108 list | `necromancy` |
| Chants and the Drums of Protection | 86-88 | 8 | 0 | `african-ceremonial`, prefix `Ceremony:` |
| Dances, and the rain maker's seven | 88-93 | 15 | 0 | `african-ceremonial`, prefix `Ceremony:` |

**Imported 2026-09-25: 23 rites**, not the "about 24" first counted. The
Medicine Man's two rituals (printed 81-82: the area version of his protection
charm, and Witch Lure) are prose paragraphs inside his charm list with no
stat block, so they ride with those items in the gear import. `Ceremony:` is
Nate's choice of prefix. No rite matched production prefixed or bare; the near
names (`Water: Rain Dance`, `Water: Part Waters`, `Air: Calm Storms`, `Clouds
of Survival: Calm Storms`) are different spells by `same-spell-lib`. `Taboo`
is a witch spell the Medicine Man also starts with, and is one row.

**Variable costs:** several chants and dances print two costs by caster or
by weather (Water Doubling 30/50, Rain Dance 300/950, Ride the Lightning
100/200, Part Waters 200/600, Control Ley Line Storms 70/110, Divining 90 +90).
Store the lower in `ppe` and the schedule in `ppe_note`. `Consume Power &
Knowledge` is 20 per item and `Divining: Tombs & Graves` 10 or 35; same
treatment.

**Drum messages are not spells** — eleven coded signals with no cost. Prose.

## Psionic powers

**Refreshed 2026-09-25 after other sessions merged.** Psyscape (World Book 12,
the later book) reprints the Mind Bleeder powers and shipped all fifteen in
#1382, in the `Mind Bleeder` category this survey also proposed. Every I.S.P.
there equals this book's printing, so nothing is left for a `variant_note`.
The fifteenth power this survey could not pin is **Brain Scan** (printed 97).
Only the two empathy powers remain for this book; they ride with the R.C.C.
PR that needs them.

| group | printed | rows | category |
|---|---|---|---|
| Mind Bleeder powers | 96-98 | 15 | `Mind Bleeder` — **shipped by Psyscape (#1382)**, identical costs; none from this book |
| Psionic Empathy with Animals / with Reptiles | 62-63, 69 | 2 | the book files them under their races; `Sensitive` |

The fifteen, in book order: Bleed Aura, Bleed P.E. Energy, Bleed Memory,
Bleed Skills, Bleed Truth, Brain Bleed, Day Dream, Healing Leech, Impervious to
Bio-Manipulation, Mental Block, Mental Block Removal, Mind Trip, Neuro-Touch,
Neural Strike, and one more on printed 97 whose heading the survey did not pin —
**count the I.S.P. lines again at extraction** (fifteen I.S.P. lines, fourteen
Range lines). Neuro-Touch prints a sub-table of effects with their own I.S.P.
costs; those are prose.

## Gear

| group | printed | rows | note |
|---|---|---|---|
| Phoenix Empire weapons | 140-141 | 7 + a shield | K-4, K-30, KEP-Special, K-E4, K-500, Kittani Plasma Axe, Kittani Plasma Sword, Kittani Class Two Combat Shield. **Render 140-141.** **`Kittani Plasma Sword` exists** (Triax p.214): compare numbers; if they agree, this book adds nothing, and if they differ it lands as `Kittani Plasma Sword (Africa)` with the difference in `variant_note` |
| Medicine Man items | 79-82 | 8 | medicine stick, medicine horn, kifaalu taboo horn, mayembe horns of divining, magic wings, three protection charms. Priced in P.P.E. to make |
| Named rune weapons and artifacts | 17-156 | about 30 | the Horsemen's four, the gods' weapons, Osiris's body-part artifacts (**one row for the set**, the fourteen parts in its description), the heroes' seven. **These ride with their owners' NPC rows** rather than the gear catalog, as South America did with the Cat's Gauntlet |

**Pygmy talismans and charms are a SYSTEM, not 32 items**: a talisman holds
one of 21 named spells at the spell's P.P.E. plus 40 (single use) or 200
(twice a day), a charm one of 11 at plus 100. Recorded on the Pygmy Shaman
class, not as gear rows.

## Vehicles (the `vehicles` table)

Phoenix Power Armor (136-137), Phoenix Sand Skimmer (138), Phoenix Sand
Crawler (138-139), Robot Spy Wing (139-140). **4 rows**, none in production.

## Creatures and notable NPCs

**Creatures (about 22):** Bones, Cyno, Raid, Carnage (the netherbeasts), Devil
Skulls, Nightmare Zombies, Magic Beetles; Jinn (`jinn-africa`, beside the
Palladium Fantasy `jinn`); Transfortifier, Chest Amalgamate, Zombitron; the
five animals; the four monsters. **The Magot is not a new row**: printed 106
summarises it and points to Conversion Book One, and `magots` exists.

**Notable NPCs (about 31):** the four Horsemen and the Armageddon Creature;
the fifteen gods (Set, Anubis, Apepi, Amon, Anhur, Ammit, Bes, Osiris, Ra,
Thoth, Isis, Horus, Bennu, Apis, Sebek) plus Katrina Sun as her own row; Pharaoh
Rama-Set; Victor Lazlo, Lo Fung, Fang-Lo, Abkii. **Erin Tarn and Sir Winslow
Thorpe belong to Coalition War Campaign** (World Book 11, the later book,
printed 15 and 17 there), whose survey plans them; this book's versions are
compared at that import, not landed beside it.

**All fifteen gods already exist** as `set`, `ra`, `sebek` and so on — from
*Palladium Fantasy Dragons and Gods*, `system` `palladium-fantasy`, in S.D.C.
This book restates them for Rifts in M.D.C. with different levels and gear.
They land as **`<slug>-africa`**, `system` `rifts`, on the `hel` /
`hel-norse` precedent. The same goes for the four minion races, whose
`creatures` rows (`phoenixi`, `ramen`, `tautons`, `crocodillians`) are the
Dragons and Gods versions — here they become classes instead, so nothing is
duplicated in `creatures`.

Named with no stat block, and left out: Lyphan the White Sphinx (57, M.D.C.
only), Iulus Nemen (125), the Hounds of Tassili n'Ajjer and the other hauntings
(111-112), Taunak's leaders (124-125).

Troop templates (135-136) are squad compositions, not stat blocks. Prose.

## Catalog diff

Run against **production** on 2026-09-25, by name across every table:

| table | result |
|---|---|
| `imported_classes` | **0 of 14** by id or name. Four witches and `necromancer-russian` exist; none is this book's |
| `spells` | **WRONG AS FIRST WRITTEN** — see *Spells*. The eighteen necro-magic spells exist as Mystic Russia `Bone:` rows; the witch's twelve and the ceremonial rites were genuinely new |
| `psionic_powers` | **0 of 17** |
| `gear` | **1 overlap**: `Kittani Plasma Sword` (Triax). `Kittani Double Blade Plasma Axe` (Triax) is a different weapon from this book's Plasma Axe; compare at extraction |
| `vehicles` | **0 of 4** |
| `notable_npcs` | the fifteen gods, as Dragons and Gods rows (above). No Horseman, hero or Rama-Set |
| `creatures` | `magots` (Palladium Fantasy) and the four minion races (Dragons and Gods), `jinn` (Palladium Fantasy main book). No netherbeast, animal or monster from this book |

**Re-run `catalog-diff --remote` right before each data script** (§8): other
book sessions are running today.

## Extraction plan

**Nate's answers, 2026-09-25:** I apply each PR `--remote` and open it, he
merges. The rites take `Ceremony:`. Katrina Sun gets her own notable row
(`katrina-sun`, real name Isis). The African Witch is imported as a class,
flagged NPC villain.

One PR each, applied `--remote` before the PR, in this order:

1. **Survey and registry** — this PR.
2. **Spells: necro-magic and the witch** — 30 rows, `necromancy` and
   `african-witch`.
3. **Spells: ceremonial** — 23 rites, `Ceremony:` / `african-ceremonial`.
   Shipped.
4. ~~Psionics~~ — **dropped 2026-09-25**: Psyscape shipped the fifteen
   Mind Bleeder powers (#1382); the two empathy powers move to step 7.
5. **Gear and vehicles** — 8 Phoenix weapons (render 140-141), 8 Medicine Man
   items, 4 vehicles.
6. **O.C.C.s** — Medicine Man, Rain Maker, Priest, Necromancer, African Witch.
7. **R.C.C.s** — Pygmy Hunter, Pygmy Shaman, Agogwe, Tree People, Phoenixi,
   Ramen, Tauton, Crocodillian; with Psionic Empathy with Animals and with
   Reptiles, which Ramen and Crocodillian carry. The Mind Bleeder is
   Psyscape's.
8. **Creatures** — about 22.
9. **Notable NPCs** — about 29, with their named weapons; Erin Tarn and Thorpe are Coalition War Campaign's.

What is deliberately left, with the reason for each:

- Drum messages, troop templates, the Punishments and raid tables — no stats.
- The insanity, disease and bites tables — rules prose; they stay on the page.
- Pygmy talismans and charms as items — a system, recorded on the class.
- Union with the Dead and Augmentation as abilities — P.P.E.-priced option
  tables, recorded on the Necromancer as prose.
- The Magot — `magots` exists and the book defers to Conversion Book One.
- Named beings with no stat block — listed above.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-25 | [#1376](https://github.com/NateGrey0130/nates-workshop/pull/1376) | cache built (162 pp, text layer), registered in `books.json`, offset +1 verified at six folios, survey written |
| 2026-09-25 | [#1383](https://github.com/NateGrey0130/nates-workshop/pull/1383) | 30 spells: 18 `Necromancy:` (17 linked to their Mystic Russia `Bone:` reprint) and 12 `Bad Medicine:`; production spells 998 -> 1028. Applied `--remote` before the PR, all 8 read-backs held |
| 2026-09-25 | [#1412](https://github.com/NateGrey0130/nates-workshop/pull/1412) | 23 `Ceremony:` rites (chants, dances, rain maker dances), level 0; production spells 1063 -> 1086. Applied `--remote` before the PR |
