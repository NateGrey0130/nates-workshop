# Rifts World Book 8: Japan — survey

**Status:** `imported` — all eight steps of the plan shipped (PR branches in the Ledger); what was left out on purpose is under Extraction plan. (2026-09-30)

**Rows citing this book:** classes 30, gear 241, vehicles 25, skills 19, creatures 14

Slug `japan`. Cached 2026-09-30 from `rifts-world-book-8-japan_compress.pdf`,
218 PDF pages, **text layer** (no OCR). `--probe` median 3,986 chars/page,
34.4% stop words, 0.0% private-use glyphs, so the words survive (not the
`BOOK-INGEST-AUDIT` F73 glyph-dropped kind).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on five pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p050` | 49 | +1 |
| `p100` | 99 | +1 |
| `p150` | 149 | +1 |
| `p200` | 199 | +1 |
| `p216` | 215 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 215.** Cache
`p217` is the Experience Point Tables page (its folio prints 216) (it belongs to the book
and matters: see *Authority*); `p218` is the back cover. Cache `p001`-`p004`
are cover, credits and front matter; `p005`-`p008` are the Contents and the
Quick Find.

## Cache health

| key | cache pages | printed | where it matters |
|---|---|---|---|
| `welded_pages` | 71, 110, 142, 200 | 70, 109, 141, 199 | 70 is Republic history (lore). **109** is the cybernetic implants list, **141** the Hawkeye Glitter Boy, **199** the Oni introduction. Read the three that feed rows from a render |
| `corrupt_pages` | 9 (1), 17 (3), 81 (1), 196 (3) | 8, 16, 80, 195 | **80 is the Cyber-Samurai O.C.C.** and **195 the Arts of Invisibility powers**; render both and read their numbers off the image. 8 and 16 are lore |
| `substituted_digits` | 88 pages | throughout | worst: cache p130 (16 hits, printed 129 explosives), p143, p168, p173, p174 (9 each, power armor and robots), p161, p181 (8). Classes carry `3D4xlOOO`-style money. **Read the token as the dice it must be**; a render does not help |

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p008** | 4-7 | *Contents* and *Quick Find* | the printed page of every class, gear item, power armor, robot, skill and monster. The Quick Find repeats the armor, enchanted-item and hand-to-hand entries — a second reading of those pages |
| **p188** | 187 | *Alphabetical List of New Skills by Category* | the 36 skills this book adds, each under its category. Descriptions with Base Skill figures run printed 187-190 |
| **p217** | (unnumbered) | *Experience Point Tables* | 16 ladders covering 25 classes — see *Classes* |
| **p204, p209, p211, p213-p216** | 203, 208, 210, 212-215 | each monster's tag line | which monsters are playable. Per the New West lesson, **an XP ladder is not evidence of playability**; the tag line is |

The XP page names ladders for classes the book elsewhere calls NPC-only
(Oni Master, Goblin Spider). Their tag lines win.

## Inventory

Counted by structure (stat-block markers and Contents headings) over all 218
cached pages.

| section | printed | what is there |
|---|---|---|
| Setting: New Empire, Takamatsu, Ichto, Otomo Shogunate, surrounding lands | 8-27 | lore and maps. No stat blocks |
| Millennium Tree and its powers | 28-33 | the tree's own powers (printed 32-33) are an NPC's, not a character's. But printed 32-33 also prices **4 gifts a character owns** - bark body armor, bark shield (3 sizes), leaf body armor, leaf blanket of healing - which the first inventory missed and step 2 imported |
| Millennium Tree wands and staves | 33-37 | **8 wands, 8 staves**, plus corrupted wands and staves (one entry) and 2 weapons of wood (printed 35: javelin, throwing stick) |
| Enchanted items | 37-40 | **9**: Elemental Shuriken, TW Power Shuriken, TW Fire-Breathing Arquebus, Magic Powder Grenades, Singing Arrows, Tanto of Hellish Poison, Ten Thousand Strength Nunchakus, Whirlwind Naginata, Zen Master's Bows; plus **3 rune swords** (Daisho of the Relentless Warrior, Daisho of the Storm, Ghostly Katana of Soul Slaying) |
| Magical items | 40-43 | **10**: Bottomless Purse, Fan of the Forest Wind, Hat of Invisibility, Heavenly Speaking Flute, Holy Incense Burner, Lantern of Protection, Living Kani Statues, Mirror of True-Seeing, Powder of the Heavenly Winds, Tattoos of Strength |
| New Empire & traditional O.C.C.s | 43-69 | **8 classes** (True Samurai, Ronin, Mystic Ninja, Bishamon Fighting Monk, Sohei Warrior Monk, Yamabushi Mountain Priest, Demon Queller, Tengu R.C.C.); the Living Samurai Sword (44); **3 hand-to-hand styles** (Zanji Shinjinken-Ryo 47, Ninjitsu/Tai-Jutsu 53, Teng-jutsu 69); ninja equipment and gimmick clothing (54, **~12 items**) |
| Republic of Japan | 70-77 | lore, laws, augmentation rules |
| Republic O.C.C.s | 78-95 | **12 classes** (Cyberoid, Cyber-Samurai, Tech-Ninja, Ninja Juicer, Ninja Crazy, Ninja 'Borg, Ninja Techno-Wizard, SAMAS Samurai Pilot, Infantryman, Robot Pilot, Glitter Force Trooper, Police Officer); *Other O.C.C.s* (95) says which core classes exist here — no stat blocks |
| Cyborgs of Japan | 96-108 | **Republic Cyborg Soldier O.C.C.** (97) and **4 Dragon 'Borg** bodies (Wing Blade, Tsunami, Imperial Combat, Flame Cloud, 101-108) |
| Cybernetics & bionics | 109-113 | **~20** implants and bionic weapons |
| High-tech weapons and gear | 114-131 | **~30**: ArmaTech and H-Brand pistols, rifles, rail guns, ARC-2, plasma thrower, neural stick, grenades, launcher, satchel charge, 3 mines, bomb detector, SNARLS, backpack, energy clips, vibro-blades; bows and arrow types (118); **traditional S.D.C. weapons** (118-120, ~20, several already in the catalog) |
| Power armor | 132-157 | **12**: Japanese SAMAS, Samurai-class SAMAS, Point and Hawkeye Glitter Boys, optional GB weapons (142), ATPA-85, H-Brand Ninjabot, IPA-40, -45, -50, -60, -62, -70. The Glitter Boy on 135 is the core book's |
| Robots | 158-180 | **9**: AT-1053, AT-1063, IR-2015, -2020, -2040, -2050, -2060, -2070, IR-4000 |
| Body armor | 181-186 | **8 armor entries** (two cover a pair of models each) plus the KM-200 jet pack |
| Japanese skills | 187-190 | **36 skills** (see *Catalog diff*) |
| Hand to hand | 190-194 | **5 styles**: Basic Martial Arts/Judo, Aikido, Jujitsu, Karate, Kendo; *Other Forms of Modern Combat* (194) |
| Mystic martial arts powers | 195-198 | **19 powers** in three groups: Arts of Invisibility (6), Body Hardening Exercises (7), Zenjoriki powers (6) |
| Monsters of Japan | 199-215 | Oni R.C.C. and oni creation tables (200-202), Oni Master, Oni Mystic, Sura-Kappa, Goblin (a Conversion Book One reprint), Goblin Spider, Japanese Imp, Hannya Demon, 3 dragons (Shikome Kido-Mi, Kumo-Mi, Asama-Tatsu) |

### Things this book has zero of, checked rather than assumed

- **Spells.** No `P.P.E.:` spell blocks outside monsters and items; the
  Ninja Techno-Wizard and Yamabushi use existing magic.
- **Psionic powers.** No `I.S.P.:` power blocks; classes grant existing ones.
- **Named NPCs with full stat blocks.** None found; the Millennium Tree is
  described but has no playable block.

## Classes

### Playable (30; the Japanese Imp below turned out NPC-only)

| class | printed | XP ladder (p217) |
|---|---|---|
| True Samurai O.C.C. | 43-49 | Ronin, True Samurai |
| Ronin O.C.C. | 49-51 | Ronin, True Samurai |
| Mystic Ninja O.C.C. | 51-55 | Tech-Ninja, Mystic Ninja |
| Bishamon Fighting Monk O.C.C. | 55-57 | Bishamon, Sohei |
| Sohei Warrior Monk O.C.C. | 58-60 | Bishamon, Sohei |
| Yamabushi Mountain Priest O.C.C. | 60-64 | Yamabushi, Demon Queller |
| Demon Queller O.C.C. | 64-66 | Yamabushi, Demon Queller |
| Tengu R.C.C. | 66-69 | Oni Master, Tengu |
| Cyberoid O.C.C. | 78-80 | Cyberoid, Republic Infantrymen |
| Cyber-Samurai O.C.C. | 80-82 | own |
| Tech-Ninja O.C.C. | 82-84 | Tech-Ninja, Mystic Ninja |
| Ninja Juicer O.C.C. | 84-86 | Ninja Borg, Crazy, Juicer |
| Ninja Crazy O.C.C. | 86-88 | Ninja Borg, Crazy, Juicer |
| Ninja 'Borg O.C.C. | 88-89 | Ninja Borg, Crazy, Juicer |
| Ninja Techno-Wizard O.C.C. | 89-91 | Japanese Imp, Ninja Techno-Wizard |
| SAMAS Samurai Pilot O.C.C. | 91-92 | own |
| Republic Infantryman O.C.C. | 92 | Cyberoid, Republic Infantrymen |
| Robot Pilot O.C.C. | 92-93 | Robot Pilot, Police Officer |
| Glitter Force Trooper O.C.C. | 93-94 | own |
| Police Officer O.C.C. | 94-95 | Robot Pilot, Police Officer |
| Republic Cyborg Soldier O.C.C. | 97-100 | Dragon Borg, Japanese Borg |
| Dragon 'Borg (four bodies) | 101-108 | Dragon Borg, Japanese Borg — four classes, as the Free Quebec cyborgs were (`fq-cyborg-*`) |
| Oni of the One Hundred R.C.C. | 202-203 | Sura-Kappa, Oni of the One Hundred. Tag line: G.M.'s discretion |
| Sura-Kappa R.C.C. | 205-206 | Sura-Kappa, Oni of the One Hundred. No NPC-only note |
| Japanese Imp | 209-210 | **NPC-only** - its tag line (printed 209) says NPC villains with no player option, so it is a creature (step 7), despite its XP ladder |
| 3 dragon hatchlings | 212-215 | none on p217; each tag line allows a hatchling PC by the core book's hatchling rules, as `dragon-hatchling-*` already do |

**Collisions to avoid**: `ronin`, `police-officer`, `robot-pilot`,
`infantryman`, `cyber-samurai` and `goblin` must be checked against
`imported_classes` at import; RUE and Conversion Book One hold generic
classes under short ids. Use a `japan-` or `-japan` form where one is taken.

### NPC-only, excluded by their own tag lines

- **Oni Master** (printed 203): strictly NPC villains. Creature row.
- **Goblin Spider** (printed 207-208): strictly NPC villains. Creature row.
- **Hannya Demon** (printed 210): strictly NPC villains. Creature row.
- **Oni Mystic** (printed 204-205): NPC by its average-level line; confirm the
  tag line at import. Creature row.

### Already in the catalog

- **Goblin** (printed 206-207) is adapted from Conversion Book One; `rifts-goblin`
  holds it. Not re-imported.
- **Glitter Boy** (printed 135) is the core book's; `Glitter Boy Power Armor`
  is in `gear`. Not re-imported.

## Catalog diff

Run against **production** (`--remote`) on 2026-09-30.

**No production row cites this book.** A name sweep for Samurai, Ninja, Tengu,
Oni, Kappa, Queller, Yamabushi and Ronin in `imported_classes` found none of
this book's classes. `gear` holds four generic Japanese weapons (Daisho,
Katana, Naginata/Yari, Shuriken, each twice) from other books.

### skills: 36 entries, 23 reported missing, 4 of them false gaps

`node scripts/catalog-diff.mjs --remote --table skills --entries <36 entries> --compare base,per_level`
returns **matched 11, disagree 2, missing 23** (402 catalog rows), plus
`W.P. Forked/Trident` matched by alias to `W.P. Forked`.

Hand-checked false gaps (the catalog holds them under RUE's names):

| book prints | catalog holds | action |
|---|---|---|
| Armorer | Field Armorer & Munitions Expert | none |
| Nuclear, Biological, & Chemical Warfare | NBC Warfare | none |
| Find Contraband, Weapons & Cybernetics | Find Contraband | none |
| Imitate Voices/Impersonation | Imitate Voices & Sounds, Impersonation (RUE split it) | none |
| W.P. Bow | W.P. Archery | **new row** (agreed 2026-09-30) |
| W.P. Cross Bow | (none) | **new row** (agreed 2026-09-30) |
| Japanese Mythology | Mythology (general) | **new row** — a separate, Japan-specific skill |
| Hand to Hand: Basic Martial Arts/Judo | Hand to Hand: Martial Arts | **new row** — a different style |

**Genuinely new: 19 skills.** Bonsai, Floral Arrangement (Ikebana), Go,
Poetry (Haiku), Japanese Mythology, W.P. Bow, W.P. Cross Bow, W.P. Mouth
Weapons, W.P. Slingshot, W.P. Small Thrown Weapons, W.P. Grenade Launcher,
and **8 hand-to-hand
styles** (Aikido, Basic Martial Arts/Judo, Jujitsu, Karate, Kendo, Ninjitsu,
Teng-jutsu, Zanji Shinjinken-Ryo). A style is a `skills` row with
`level_bonuses`, as `Hand to Hand: Skudasa` is — no code needed.

The two disagreements (Gardening base 34 vs 36; Horsemanship: Exotic Animals
per level 4 vs 5) are this book's reprint differing from RUE, which the rows
cite. **Not corrections**; RUE stays.

### gear, vehicles, creatures, classes

Not diffed row by row: nothing here cites this book, and a name sweep of each
found no overlap beyond the rows named above. **Re-run `catalog-diff --remote`
per batch before each data script** (§4), as always.

## Extraction plan

Phase 4 costs money; everything above was free. Shipped in this order,
because classes name the book's gear (the Madhaven lesson: gear before
classes, no stubs):

1. **Skills** — 19 new rows from printed 187-194, the 8 hand-to-hand styles
   with their per-level tables. One PR.
2. **Magic gear** — 16 wands and staves, 9 enchanted items and 3 rune swords,
   10 magical items, printed 33-43. One PR.
3. **Traditional gear** — ninja equipment and clothing (54), traditional
   S.D.C. weapons and bows (118-120), minus the four already held. One PR.
4. **Tech gear** — cybernetics (109-113), weapons and explosives (114-131),
   body armor and jet pack (181-186). One or two PRs.
5. **Traditional classes** — 8 classes, printed 43-69. The mystic martial
   arts powers (195-198) go into these classes' abilities (see below).
6. **Republic classes** — 12 classes plus the Cyborg Soldier and 4 Dragon
   'Borgs, printed 78-108. Fanned out to `book-extract-worker`s, then
   `book-reconcile`.
7. **Monster R.C.C.s and creatures** — Oni of the 100, Sura-Kappa, Japanese
   Imp, 3 dragon hatchlings as classes; Oni Master, Oni Mystic, Goblin Spider,
   Hannya and the 3 dragons as creatures, through `bestiary-sql.mjs`.
8. **Power armor and robots** — 21 vehicles, printed 132-180, in the
   `vehicles` tables as Atlantis's were.

What is deliberately left, with the reason for each:

- **Setting lore** (8-32, 70-77) — no rows.
- **The Millennium Tree's own powers** (32-33) — the tree's, not a character's: camouflage, ley line and weather control, teleportation, healing, purification, resurrection, sixth sense, visions. The four gifts on the same pages are items and are in step 2.
- **Holy Incense Burner powder packages and an Elemental Shuriken set** (printed 37, 41-42) — priced, but only as refills and a bundle; both prices are in the parent rows' `cost_note`.
- **Oni creation tables** (200-202) — random appearance tables; cosmetic.
- **Goblin, Glitter Boy** — reprints already held (above).
- **Other O.C.C.s** (95) — a list of core classes, not new ones.

**The one likely gap:** Bishamon, Sohei and Demon Queller pick mystic martial
arts powers at set levels (for example one body hardening exercise at levels
1, 5 and 9 and a zenjoriki power at 14, printed 56 and 59). A level-gated
choice from a named list may not be expressible as a class ability. Check at
step 5; if it cannot be stated, import the level-1 pick, put the later ones
in prose, and file it in `BOOK-INGEST-AUDIT.md` (`book-survey` §8).

### Agreed with Nate, 2026-09-30

1. **Monsters as proposed.** Oni of the One Hundred, Sura-Kappa and Japanese
   Imp are R.C.C.s. The three dragons are hatchling classes, like
   `dragon-hatchling-*`. Oni Master, Oni Mystic, Goblin Spider and Hannya are
   creatures only.
2. **W.P. Bow and W.P. Cross Bow are new rows**, citing this book, not
   aliases of `W.P. Archery`. Step 1 is therefore **19 skills**, not 17.
3. **Martial-arts powers as proposed.** Import what the class format can
   state. Put a level-gated pick it cannot state in prose, and file it as a
   finding. Do not build it.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-09-30 | `pal/data/japan-survey` | cache built (218 pp, text layer), offset +1 verified at five folios, `japan` registered in `books.json`, this survey. No rows. |
| 2026-09-30 | `pal/data/japan-skills` | step 1: 19 skills (`add-a-japan-skills.sql`, tagged by `~044-japan-skill-systems.sql`): Bonsai, Floral Arrangement (Ikebana), Go, Poetry (Haiku), Japanese Mythology, 6 W.P.s and 8 Hand to Hand styles with their level tables and attribute bonuses. Two extraction workers and one reconcile pass; reconcile caught the Zanji and Ninjitsu attribute lines the extraction had dropped. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-magic-gear` | step 2: 63 gear rows (`add-a-japan-magic-gear.sql`), printed 32-43: the Millennium Tree's ownable gifts (bark and leaf armor, the bark shield in three sizes, the leaf blanket of healing), 8 wands, 8 staves, the corrupted wand or staff, 2 weapons of wood, the enchanted weapons one row per priced variant, the 3 Greater Daisho, and the magical items (purse in 3 kinds, kami statue in 4 sizes). Reconcile confirmed every number and corrected 11 descriptions. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-traditional-gear` | step 3: 49 gear rows (`add-a-japan-traditional-gear.sql`): the Mystic Ninja's equipment and gimmick clothing (printed 54-55), six bows, two gas arrowheads and magic arrows (118), and the traditional S.D.C. weapons (118-120). Heroes Unlimited and Palladium Fantasy hold most of these under the plain slug, so the Rifts copies are suffixed `-rifts`. Eight arrowheads, the crossbow pistol and the modern crossbow were already in the catalog from Triax and Spirit West at this book's prices, and are not duplicated. Reconcile corrected two restrictions. `shikomi-zue-rifts` carries both damage (1D8) and its own S.D.C. 50, so it joins regression's named `SELF_SDC` exceptions (BOOK-INGEST-AUDIT F54). Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-tech-gear` | step 4: 115 gear rows (`add-a-japan-tech-gear.sql`): 31 cybernetics and bionics (printed 109-113), 71 high-tech weapons, vibro-blades, packs, E-clips, explosives and mines (114-131), and 13 body armors and packs (181-186). Ten items were already in the catalog from Triax and Underseas at this book's figures and are not duplicated (the Underseas mini torpedo's damage disagrees with this book's; Underseas stands). M.D.C. is stored only where an item prints one. `at-d52-bullet-anti-personnel-mine` joins regression's `SELF_SDC` exceptions. Three extraction workers, two reconcile passes; reconcile removed invented payloads, defaulted M.D.C. and knock-off damage, and wrong penalty text. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-traditional-classes` | step 5: 8 classes - `true-samurai` (male/female variants), `ronin`, `mystic-ninja`, `bishamon-fighting-monk`, `sohei-warrior-monk` (monk/nun variants), `yamabushi-mountain-priest`, `demon-queller`, `tengu` - and 2 gear rows the samurai and ronin carry (`samurai-armor`, `silver-tipped-arrows`, `add-a-japan-samurai-gear.sql`; the book prints no price, and no damage for the arrows). One drafting agent per class from a shared brief; every class reads `ready` against production with 0 stubs. Level-gated mystic martial arts picks after level 1 are prose (agreed 2026-09-30); the finding is filed in BOOK-INGEST-AUDIT.md. Temple skills store each class's printed base. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-republic-classes` | step 6: 17 classes - `cyberoid`, `cyber-samurai`, `tech-ninja`, `ninja-juicer`, `ninja-crazy`, `ninja-borg`, `ninja-techno-wizard`, `samas-samurai-pilot`, `republic-infantryman`, `robot-pilot-japan` (`robot-pilot` is another book's), `glitter-force-trooper`, `police-officer-japan`, `republic-cyborg-soldier` and the four Dragon 'Borg bodies (`dragon-borg-wing-blade`, `-tsunami`, `-imperial-combat`, `-flame-cloud`, one class per body as the Free Quebec cyborgs are) - and 8 gear rows the classes carry (`add-a-japan-republic-class-gear.sql`: micro-film camera, small crowbar, universal headjack, cyber-samurai armor, and the four cyborg body armor plates of printed 97; none is priced). The five cyborg classes restate one skill list and were harmonised to it. Every class reads `ready` against production with 0 stubs. Issued power armor and robots are prose in the classes; the machines are step 8. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-monsters` | step 7: 5 race classes - `oni-of-the-one-hundred` (NPC by default, player at the G.M.'s discretion per its tag line), `sura-kappa` (no tag line; playable by its XP ladder) and three hatchlings in the `dragon-hatchling-*` shape (`-shikome-kido-mi`, `-kumo-mi`, `-asama-tatsu`) - and 8 creatures through `bestiary-sql.mjs` (`add-japan-creatures.sql`: Oni Master, Oni Mystic, Goblin Spider, Japanese Imp, Hannya Demon and the three dragons as adults). The Japanese Imp's tag line (printed 209) makes it NPC-only, so it is a creature, not the class this survey first planned. Creatures reconciled row by row; the Imp's printed dodge reads 44 and is stored +4 with a note. Applied `--remote` before the PR. |
| 2026-09-30 | `pal/data/japan-vehicles` | step 8: 21 vehicles (`add-japan-vehicles.sql`) with 221 M.D.C. locations and 126 weapon entries: 11 power armors (Samurai-class SAMAS, Point and Hawkeye Glitter Boys, ATPA-85, Ninjabot, six Ichto IPAs) and 10 robots (nine, plus the IR-2050 Apocalypse's drone as its own row). Four extraction workers, two reconcile passes; reconcile moved the ATPA-85's three missing weapons and hand to hand back from the Ninjabot, split out the drone, and corrected four descriptions. The core Glitter Boy (printed 136-137) is already `glitter-boy-power-armor`. The classes that are issued these machines describe them in prose; there is no gear row pointing at a vehicle, as Atlantis's weren't either. Applied `--remote` before the PR. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **The four Dragon 'Borg bodies as `borg` vessels** (`~085`), the shape Warlords of Russia used the day after this book shipped; the classes are not rewired, and three notes that said no vehicles row existed are corrected (`~092`). **The Oni of the One Hundred's power sets gain their bands and five appearance tables become pick-one groups** (`~090`): the plan called those tables cosmetic, and five of the nine carry Horror Factor, damage, attacks, Spd or M.D.C. Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a2-reprints-compared` | **The reprints compared with their held rows** (`~094`). Skills: the four false gaps and thirteen name matches all stand on Rifts Ultimate Edition (2005), which is newer; `Lore: Magic` now carries the sub-abilities RUE printed 325 prints. `rifts-goblin` stands on Conversion Book One revised (2002). **The Glitter Boy reprint is on printed 136-137**, not 135, and is the original core book's text: RUE's row stands, and its ammo drum (250 M.D.C.) and stabilizing thrusters (50 each) locations are NOT added, because RUE restates the location list without them. **One held-row error found through it:** the gear row `boom-gun-glitter-boy-rail-gun` cited RUE and carried this older text's 100 rounds and 40-round drum; it now carries RUE printed 72's 1000 and 400. Off renders; the RUE figures checked again by `book-reconcile`. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a4-race-creatures` | **The six playable races as creatures** (`~100`), `playable = 1`, by Nate's ruling of 2026-10-04: `tengu`, `oni-of-the-one-hundred`, `sura-kappa` and the three hatchlings `dragon-hatchling-shikome-kido-mi`, `dragon-hatchling-kumo-mi`, `dragon-hatchling-asama-tatsu`, with 31 attacks. Built from renders and checked again by `book-reconcile`: no wrong figure. **What a hatchling row holds:** the book prints M.D.C., P.P.E. and attacks per melee for a hatchling and everything else once for the species, so the attribute dice and damage are the species', and each row says so. The adult dragon rows (`japan-*-dragon`) are separate and unchanged. The Tengu's combat figures are Teng-jutsu at level one (printed 69), which every Tengu knows; the R.C.C.'s own bonuses on printed 68 are saves only. The Oni's Spd has no printed formula (it comes from the Oni Legs table); the commonest result is stored and the table is in the note. Its nine appearance tables and the powers table are summarised with their pages, not expanded. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a7-wire-classes` | **The four Dragon 'Borg classes are wired to their bodies** (`~113`): four `gear` pointer rows whose slug is the vessel's own and which carry `vehicle_slug` (`at-c8000-wing-blade-cyborg`, `at-c9000-tsunami-cyborg`, `at-c10000-imperial-dragon-cyborg`, `at-c12000-flame-cloud-cyborg`), each first in its class's `equipment_starting`, the shape `BOOK-INGEST-AUDIT` F41 settled for a class's vessel (`~018`). Cost and main body M.D.C. are the vessel row's. The three notes `~092` wrote saying the class was not wired are rewritten; each class still describes its body in `special_abilities`. Applied `--remote` before the merge. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-09-30, after step 8 was applied:

```
  japan              315 / 0
```

Every row citing this book traces to a cached page. Its `BACKLOG` block is the
same as before the import started, so no step left a stub behind:

```
  gear stubs            14   description still says STUB — created by class import
  skill stubs            5   created by an import and never given a base %, a bonus or a note
  spell stubs           19   level 0 and 0 P.P.E.
  psionic stubs          1   0 I.S.P.
  spell text missing     0   nothing for the codex to show
  psionic text missing   0   nothing for the codex to show
```

`node scripts/drift-check.mjs --remote` reports NO DRIFT the same day.

**Open finding from this book:** BOOK-INGEST-AUDIT F116 (level-gated mystic
martial arts picks, stored as prose in four classes).
