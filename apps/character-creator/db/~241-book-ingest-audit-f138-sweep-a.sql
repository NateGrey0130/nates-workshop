-- Take BOOK-INGEST-AUDIT F138: seven classes' printed language, literacy, lore or writing bonus as a scoped category entry
-- 7 classes, each replaced whole: spacer, naruni-repo-bot, yamabushi-mountain-priest, demon-queller, african-witch, fu-yao-da-chia, wai-chia-wu-shih.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~241-book-ingest-audit-f138-sweep-a.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Seven classes print a percentage on part of Technical (language, literacy,
-- lore or writing) that only their notes carried, so categoryBonus paid 0 on
-- those rows (wai-chia-wu-shih 5). Each now carries a second, scoped Technical
-- entry in the shape of ~194 and ~196, each figure read off a render of its
-- cited page on 2026-10-20. Language bonuses follow Nate's 2026-10-14 rulings:
-- every Language: and Literacy: row plus the bare Literacy row, and where a class
-- grants Communications without a bonus, a scoped Communications entry for the
-- Literacy: rows and Language: Dolphin/Whale the catalog files there.
-- - spacer (Phase World printed 39), naruni-repo-bot (printed 48),
--   yamabushi-mountain-priest (Japan printed 64), demon-queller (printed 66):
--   +10 on Language:, Literacy: and Literacy. Spacer and Repo-Bot already pay
--   Communications +10 on the Communications-filed rows, so no entry there.
-- - african-witch (Africa printed 74): +10 on Language:, Literacy:, Lore:,
--   Literacy and Creative Writing, and the scoped Communications entry.
-- - fu-yao-da-chia (China 2 printed 83): +15 on Lore:.
-- - wai-chia-wu-shih (China 2 printed 54): Lore: 5 to 10; the +5 stays.
-- Left unstored, as the row's brief rules: the computer halves (spacer,
-- naruni-repo-bot), Art, Rope Works and Mythology (fu-yao-da-chia), History
-- (wai-chia-wu-shih), and the spacer's +10% on math.

-- == spacer ==
UPDATE imported_classes
   SET markdown = '---
id: spacer
men_of_arms: false
name: Spacer
system: rifts
category: occ
tags: [pilot]
occ_group: optional
source_book: Rifts Dimension Book 2: Phase World p.38-39
starting_money: "4d6x1000"
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "Printed as Basic Math (+10%)." }
    - { name: "Radio: Basic", bonus: 15, note: "Printed as Basic Radio (+15%)." }
    - { name: "Space: Spacecraft Mechanics", bonus: 10, note: "Printed as Spaceship Mechanics (+10%)." }
    - { name: "First Aid", bonus: 10, note: "+10% bonus over base." }
    - { name: "Space: Zero Gravity Movement & Combat", bonus: 15, note: "Printed as Movement: Zero Gravity (+15%). The catalog row has a base of 0 because the book states it as P.P. number x5%; see BOOK-INGEST-AUDIT.md F2." }
    - { name: "Space: Extra-Vehicular Activity", bonus: 10, note: "Printed as EVA (+10%)." }
    - { choose: 2, from: ["Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship", "Space: Contragravity Pak"], bonus: 15, note: "Pilot: two spaceship types (+15%). The four rows offered are the spacecraft this book itself files under Pilot Skills on printed 150-151." }
    - { name: "Sensory Equipment", bonus: 10, note: "Printed as Read Sensory Equipment (+10%)." }
    - { name: "Computer Operation", bonus: 10, note: "+10% bonus over base." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: any two." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Printed as Hand to Hand: Basic (normal). May be changed to Expert at the cost of one other skill, or Martial Arts - Assassin if evil - at the cost of two." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", only: ["Paramedic"] }
      - { name: "Military", only: ["Demolitions"] }
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 4, count: 2 }, { level: 7, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    note: "Select eight other skills, plus TWO more at each of levels four, seven, nine and twelve - a schedule of 4/7/9/12 rather than the 3/6/9/12 most of this book uses, and two picks at every step rather than tapering. Espionage is barred outright and is absent. Science is Any (+10% ON MATH), which is not stored. Technical is Any (+10% ON LANGUAGE AND COMPUTER SKILLS): the language half is a second, scoped Technical entry on every Language: and Literacy: row and the bare Literacy row (BOOK-INGEST-AUDIT F138), and Communications'' own +10% already reaches the Literacy: rows the catalog files there; the computer half is not stored. Pilot is Any (+10% WHERE APPLICABLE), which is stored as a flat +10% because the qualifier names no exception."
  secondary_skills:
    count: 7
    note: "Seven secondary skills from the same list, without the bonuses in parentheses, starting at the base skill level. The any/only/none limits above still apply."
bonuses:
  saves:
    other:
      - { label: "vs explosive decompression and other space dangers", bonus: 2, note: "Printed 38; the spacers'' experience of vacuum. This class''s only mechanical grant." }
equipment_starting:
  - { choose: 1, label: "spacesuit or space-capable M.D.C. armor", qty: 1, from: ["spacer-suit", "spacer-hard-suit", "light-combat-armor", "caf-jumpsuit"] }
  - { item_id: "mini-tool-kit", qty: 1 }
  - { choose: 1, label: "hand weapon of choice, usually pistol size", qty: 1, from: ["hi-30-laser-pistol", "hi-10-heavy-laser-pistol", "ne-4-plasma-cartridge-pistol", "ep-5-energy-pulse-pistol", "gr-10p-pistol", "ph-21-phase-beamer"] }
  - { item_id: "e-clip", qty: 2 }
  - { item_id: "knife", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "communicators-small", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
extraction_notes: |
  - Read from the OCR cache of a scan and verified against a 200 dpi render of
    printed 39, which carries the whole stat block. The lore and the attribute
    line are at the foot of printed 38 and both pages were read to the end.
  - THE ONLY BONUS THIS CLASS HAS IS STORED, in `bonuses.saves.other`. This note
    said it was not, and that `bonuses` was empty because of it, until
    RETRO-AUDIT R1 (2026-09-04). The rest of this bullet is still true and is
    the reason the labelled-save shape exists. The book grants "+2 to any saves against explosive decompression or
    other space dangers". `sheet.js` renders saves from a FIXED list of sixteen
    fields - spell magic, ritual magic, psionics, toxins/poisons, harmful drugs,
    insanity, possession, horror factor, coma/death, pain, illusionary magic,
    mind control, curses, faerie magic, disease, fatigue - and there is no
    environmental or vacuum save among them. A key the list does not name is
    accepted by the parser and then never rendered, so writing
    `space_hazards: 2` would store a number nobody sees.
    `toxins_poisons: 2` WAS WRITTEN FIRST AND WAS WRONG: it is the nearest label
    a GM would reach for, and it would have handed this class a real +2 against
    venom that the book never gave it. Filed as BOOK-INGEST-AUDIT.md F7. The
    bonus is in the GM Notes, where a GM can apply it.
  - TWO PRINTED PERCENTAGES NAME PARTICULAR SKILLS. "Science: Any (+10% on
    math)" and "Technical: Any (+10% on language and computer skills)"
    (printed 39, read off a render). The language half is stored as a second,
    scoped Technical entry on every Language: and Literacy: row and the bare
    Literacy row (BOOK-INGEST-AUDIT F138, 2026-10-20). The math and computer
    halves are not stored; they are in the related-skills note.
  - THE RELATED-SKILL SCHEDULE IS 4/7/9/12 WITH TWO PICKS AT EVERY STEP, where
    most of this book runs 3/6/9/12 and tapers to one. Transcribed as printed
    and flagged here because it reads like a transcription error and is not.
  - "Pilot: two spaceship types" is a choice group over the four spacecraft
    rows this book files under Pilot Skills on printed 150-151. The book does
    not enumerate its own spaceship types anywhere, so the list is a reading.
  - THE MULTITOOL IS IMPORTED AS A MINI TOOL KIT, the catalog''s nearest row.
    "Knife or blackjack" is imported as a knife; the catalog has no blackjack
    and the book gives one no stats. The work jumpsuit is the catalog''s
    generic uniform.
  - Experience table transcribed from a 200 dpi render of printed 183, shared
    with the Colonist.
  - This class has NO S.D.C. or hit point formula of its own, so the core rule
    reaches it at 1D6 via its `men_of_arms: false` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) - `occ_group: optional`, because
    the book describes a professional pilot and crewman, not a soldier: no
    attribute requirements, Hand to Hand: Basic, and a skill list of mechanics,
    first aid and cargo work.
  - Cybernetics: starts with none, but may acquire enhancements. There is no
    field for that and nothing is stored.
---

## Lore

The Three Galaxies cover a lot of space and somebody has to move the cargo.
Spacers are the professional pilots and crew of the thousands of independent
ships hauling it, and they typically disdain the security of a corporate berth -
or something in their past makes a safer job impossible. They work for
independent haulers and transports, often for a share of the profits instead of
pay. A lucky spacer owns his own ship, and most of the rest dream about it.

## A nomad''s trade

Like the sailors of old they go port to port and rarely settle. That suits
people running from something - the authorities, creditors, family, themselves -
and a great many spacers have shady pasts and a fair share of enemies.

Some are outright brigands who dabble in piracy and smuggling, but most leave
that to the career criminals: the runner and the space pirate.

## GM Notes

No attribute requirements, though a decent I.Q., P.S. and P.E. are recommended.

The class''s one bonus is **+2 to save against explosive decompression and other
space dangers**, and it IS on the sheet. The saves list is a fixed sixteen
and none of them is a vacuum, which is exactly why it is carried as a labelled
save in `bonuses.saves.other` and rendered after those sixteen. It is the whole
of what this O.C.C. gets beyond its skills. This paragraph said to apply it by
hand until RETRO-AUDIT R1, 2026-09-04.

Two skill bonuses the book prints are not on the sheet: **+10% on math** among
the science picks, and **+10% on computer skills** among the technical ones.
Add them by hand. Its **+10% on language skills** is on the sheet.

A spacer starts with none, but may acquire cybernetic enhancements later.
',
       updated_at = datetime('now')
 WHERE class_id = 'spacer'
   AND instr(markdown, 'TWO PRINTED BONUSES ARE NOT CATEGORY BONUSES AND ARE NOT STORED') > 0
   AND length(markdown) = 9114;

-- == naruni-repo-bot ==
UPDATE imported_classes
   SET markdown = '---
id: naruni-repo-bot
name: Naruni Repo-Bot
system: rifts
category: occ
tags: [combat, hunter, augmented]
occ_group: men-of-arms
source_book: Rifts Dimension Book 2: Phase World p.46-48
attribute_requirements: { ME: 12 }
mdc_base: "600 for the main body; see the Robot Body ability for the rest"
starting_money: "1d4x1000"
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
race_restrictions:
  only: ["none"]
  note: "A Repo-Bot IS its body. Naruni Enterprises builds the chassis and installs an organic brain in it, so there is no species underneath for a race to describe, and pairing this with an R.C.C. would give the character a second body it does not have."
bonuses:
  combat: { initiative: 2, strike: 8, parry: 8, dodge: 8, pull_punch: 2, roll: 2, attacks: 1 }
  saves: { horror_factor: 10 }
natural_abilities:
  - { name: "Robot Body", description: "A completely mechanical body, with M.D.C. by location: Head 200, each of two Arms 200, each of two Legs 240, Force Field 300, Main Body 600. The force field has to be depleted before any damage reaches the head or the rest of the robot. Destroying the head kills the Repo-Bot, and that takes a called shot at -2 to strike. Only the main body figure is in `mdc_base`; the sheet has one M.D.C. pool and no location table." }
  - { name: "Robot Attributes", description: "The chassis has a P.S. of 50 and a P.P. of 26, and runs at up to 100 mph (160 km) indefinitely without tiring on a nuclear power plant with an energy life of 50 years. NEITHER ATTRIBUTE IS STORED - see the extraction notes." }
  - { name: "Built-in Weapon Systems", description: "A particle beam weapon (1d4x10 M.D. per shot, 2000 feet/610 m, unlimited payload), a plasma flamethrower (5d6 M.D. over a 20 foot/6.1 m area, 200 feet/61 m, unlimited payload) and a finger-laser (4d6 M.D., 2000 feet/610 m, unlimited payload). All three are part of the body rather than equipment. A Repo-Bot can also use any handheld weapon - energy pistol, rifle, rail gun - and can plug an energy weapon into its own power supply for an unlimited payload." }
  - { name: "Robot and Cybernetic Systems", description: "Multi-optic eye, infra/ultra eye, ultra-ear, amplified hearing, polarized filters and a sensor hand, built in. An internal oxygen supply keeps the organic brain alive for 96 hours." }
  - { name: "Impervious", description: "Impervious to disease, toxins, gases and radiation, and needs no air to breathe. IMMUNITY, NOT A BONUS: `bonuses.saves` holds numbers and the sheet''s Toxins/Poisons and Disease rows are d20 saves, so there is no figure to write that means never. Left here as prose rather than invented as a +10." }
  - { name: "Absolute Loyalty", description: "Programmed by Naruni Enterprises and overwhelming. A Repo-Bot cannot be bribed or paid off to do anything against the company. It is intelligent and shows real initiative, and it always looks out for the company''s interests." }
equipment_starting:
  - { item_id: "plasma-hand-cannon", qty: 1 }
  - { choose: 2, label: "energy weapon of choice", qty: 1, from: ["hi-10-heavy-laser-pistol", "hi-30-laser-pistol", "hi-50-laser-rifle", "hi-80-combat-laser-rifle", "ne-4-plasma-cartridge-pistol", "ne-10-plasma-cartridge-rifle", "ne-50-particle-beam-rifle", "ep-5-energy-pulse-pistol", "epr-8-energy-pulse-rifle", "ph-21-phase-beamer"] }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Radio: Basic", bonus: 15, note: "Printed as Basic Radio (+15%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two Languages of Choice (+15%). The catalog''s repeatable Language: Other row is what an any-language pick resolves through." }
    - { name: "Computer Operation", bonus: 10, note: "Printed as Computer Operations (+10%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 15, note: "Pilot: Pick two (+15%)." }
    - { name: "Weapon Systems", bonus: 15, note: "+15% bonus over base." }
    - { name: "Tracking (people)", bonus: 10, note: "Printed as Tracking (+10%). A Repo-Bot tracks debtors, so the catalog''s Tracking (people) is the row rather than Track & Trap Animals." }
    - { name: "Land Navigation", bonus: 15, note: "+15% bonus over base." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Martial Arts or Assassin at the cost of one other skill." }
  occ_related_skills:
    count: 10
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Military", bonus: 10 }
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Select 10 other skills, plus two at level three, two at level six, and one each at levels nine and twelve. FIVE CATEGORIES ARE PRINTED AS None AND ARE OMITTED RATHER THAN LISTED WITHOUT A BONUS - Electrical, Mechanical, Medical, Physical and Science are all barred outright. Listing them without a bonus would offer skills the book bars. This book does it in at least a dozen entries and five is the most any of them bars, which is the book''s point about how narrow a Repo-Bot is. Technical is printed as Any (+10% on computers and languages): the language half is a second, scoped Technical entry on every Language: and Literacy: row and the bare Literacy row (BOOK-INGEST-AUDIT F138), and Communications'' own +10% already reaches the Literacy: rows the catalog files there; the computer half is not stored."
  secondary_skills:
    count: 4
    note: "Four secondary skills from the same list, without the bonuses in parentheses. All secondary skills start at the base skill level."
extraction_notes: |
  - Read from the OCR cache of a scan and verified against 200 dpi renders of
    printed 46 and 48, which between them carry the whole entry. PRINTED 47 IS A
    FULL-PAGE ILLUSTRATION of two Repo-Bots and carries no text; it was rendered
    and checked rather than assumed, because the entry''s numbered abilities run
    1-3 on printed 46 and resume at 4 on printed 48. The entry ends on printed
    48 at its own Note, with the True Naruni R.C.C. heading in the next column,
    and `--field-sources` was read for the money and equipment lines.
  - IT IS HEADED R.C.C. AND IT IS AN O.C.C. IN EVERY FIELD, AND THE FIELDS WIN.
    Three of the book''s lists title this entry a race - the section heading on
    printed 46 reads "Naruni Repo-Bot R.C.C.", the Contents says "The Naruni
    Repo-Bot R.C.C." and the Quick Find says "Repo-Bots R.C.C." - while the
    stat block itself prints Attribute Requirements, O.C.C. Abilities and
    Bonuses, O.C.C. Skills, O.C.C. Related Skills, Standard Equipment, Money and
    Cybernetics, and the book''s own character record sheet on printed 187-208
    titles it "Naruni Repo-Bot O.C.C.". Decisively, IT PRINTS NO Attributes LINE
    AT ALL: every R.C.C. in this book rolls eight attributes and this entry
    rolls none, because it is not a species. The three that say R.C.C. are
    titles; the ones that say O.C.C. are the mechanics. Imported as `occ`, which
    is also the category that behaves: `category: rcc` makes app.js offer an
    occupation step whose related and secondary allowances REPLACE the class''s
    own, and this class''s ten-plus-six schedule is the whole of what it grants.
    The survey''s rule was to settle the label from the stat block''s own heading;
    that rule points the other way here and is wrong for this entry, which is
    recorded in the survey. `occ_group: men-of-arms` follows from that choice
    and is REQUIRED: `regression.mjs` fails an O.C.C. carrying no group, and it
    is the only check that catches it - smoke.mjs passed this class ungrouped.
    Men-of-arms is the honest group for an enforcer with Hand to Hand: Expert,
    two W.P.s, three built-in weapon systems and Military among its related
    categories, and it matches the six O.C.C.s already imported from this book.
  - THE ROBOT''S P.S. 50 AND P.P. 26 ARE NOT STORED, AND WRITING THEM WOULD HAVE
    BEEN SILENTLY WORSE THAN LEAVING THEM OUT WHEN THIS CLASS WAS IMPORTED, AND
    THAT IS NO LONGER TRUE. At import, `attribute_dice` values went through
    `rollAttribute` in js/dice.js, which read only NdM forms, fell back to 3d6
    on anything else, and rewrote the notation to match - so a fixed attribute
    stored as a number that read correct in the data and rendered as an ordinary
    human. BOOK-INGEST-AUDIT.md F8 was filed for it and has since been taken:
    a bare integer is now a fixed value, returned unchanged, reporting its own
    notation, and it is its own ceiling for the server-side attribute gate. The
    one published class already carrying one, the Holy Terror''s `PS: "50"` from
    Wormwood, was corrected by that change alone and needed no edit.
    THE P.S. 50 IS STILL NOT STORED HERE, and that is now a choice rather than a
    limit: adding it would change every character made from this class, which is
    a decision to take on its own rather than a side effect of fixing the
    mechanism. Both figures remain in the Robot Attributes ability.
  - THE P.P. WOULD HAVE DOUBLE-COUNTED EVEN IF IT COULD BE STORED. The book heads
    the bonus line "Bonuses (Includes P.P. bonuses)", so the printed +8 to
    strike, parry and dodge ALREADY CONTAINS the chassis'' P.P. 26. js/derive.js
    adds a P.P.-derived combat bonus of its own from the `pp_combat` row, so a
    stored P.P. of 26 would have added roughly six more on top of a figure that
    was inclusive. Both attributes are in the Robot Attributes natural ability
    instead.
  - `race_restrictions: { only: ["none"] }` because a Repo-Bot is its body. The
    key is modelled - `raceAllowedForOcc` in js/parser.js reads it and thirteen
    Juicer classes already use it - and it is not in `frontmatter.md`, which is
    a tour rather than a schema. Grepped before writing, not assumed.
  - IMMUNITY HAS NO FIELD. "Impervious to disease, toxins, gases, and radiation,
    don''t need air to breathe" covers two rows the sheet does have - Disease and
    Toxins/Poisons - and `bonuses.saves` holds a number, not a never. Any figure
    written there would be invented, and gases and radiation have no row at all.
    All four are prose in the Impervious ability. This is F7''s shape read the
    other way round: the near-miss here would be a large number rather than a
    wrong key.
  - THE THREE BUILT-IN WEAPONS ARE NOT GEAR ROWS. The particle beam, plasma
    flamethrower and finger-laser are part of the chassis, not items a character
    carries, and `equipment_starting` would let a player drop them. They are in
    the Built-in Weapon Systems ability with their full stats.
  - THE PLASMA HAND CANNON IS A STUB. It appears exactly once in this book - in
    this equipment line, with its damage of 2d6x10 M.D. and nothing else - and
    is stat-blocked nowhere; a grep of all 209 cached pages returns that one
    line. The stub carries the marker the gear importer looks for.
  - THE SPACE SHUTTLE IS NOT IN equipment_starting. "They may also be given a
    space shuttle with an FTL drive for travel and pursuit" is conditional and
    names no model. This book''s vessels are `vehicles` rows since #1445 and
    none is a Naruni shuttle, so there is nothing to point at. Until
    2026-09-27 (~029-class-vessel-notes.sql) this note called them out of scope under
    BOOK-INGEST-AUDIT.md F3. The receipts and unpaid bills are props, not gear,
    and are in the lore rather than stubbed.
  - CYBERNETICS ARE NOT MODELLED. "Can select an additional 1D4 cybernetic
    implants" has no field; the catalog has no cybernetics table and this batch
    does not add one. Stated here.
  - THE BOOK CALLS IT A BETTER NPC AND STILL MAKES IT PLAYABLE. Its closing Note
    reads "The Repo-bot makes a better NPC villain than a player character.
    Player characters will be loyal agents of Naruni Enterprises unless there is
    a super-rare glitch in their memory or programming" - advice about how the
    character will play, not the NPC label the Royal Kreeghor carries. Printed
    183 gives it a ladder, which is this book''s own statement that a class is
    meant to be played, so it is imported. Compare the Royal Kreeghor, whose
    heading says NPC Villains and which has no ladder and was NOT imported.
  - Experience table transcribed from a 250 dpi render of printed 183. The column
    is headed "Silhouette, Draconid & Repo-Bots" and all three share it; the two
    R.C.C.s record it in their notes instead, because a race carrying an
    `xp_table` wins over the occupation''s and silently drops it.
  - `mdc_base` carries the main body only, so there is no S.D.C. and no
    `men_of_arms` line.
---

## Lore

Almost every sentient in the Three Galaxies is deathly afraid of missing a
payment to Naruni Enterprises. When the terms of an agreement are not met - and
there are a great many terms, in the finest of print - NE sends one or more of
its enforcers to collect what is owed. They will collect it, any way they can.

A Repo-Bot arrives carrying the receipts for the property to be repossessed, or
the unpaid bills, and it does not leave without one or the other satisfied.

## Robots with organic brains

Nobody knows whether the brains inside them belonged to willing people or to
victims of enslavement. Whatever they were, the personality is submerged under
an overwhelming programmed loyalty to Naruni Enterprises. A Repo-Bot is
intelligent and shows genuine initiative, and it always looks out for the best
interests of the company.

They can be shrewd negotiators, skillful diplomats, ingenious strategists and
merciless killers, in whatever order the job requires. It is believed their
mental programming is based on the mind-pattern of a top-notch secret agent and
soldier, long dead - or perhaps on the minds, memories and skills of several
dozen such beings, with the best traits of each one combined.

## The best technology Naruni keeps

The Repo-Bots are clear proof that Naruni Enterprises reserves its best work for
itself. These super-cyborgs outperform any bionic organism in the Three
Galaxies, with the possible exception of the Wolfen Quatoria warriors and the
ancient machine people. Each one is as tough as a squad of power armor troopers
and operates in any environment, space included.

They work in squads of four, platoons of sixteen, companies of sixty-four and
battalions of two hundred and fifty-six. On very rare occasions thousands of
them have been gathered and sent against a single target.

## Playing one

Most Repo-Bots are aberrant, and the loyalty is absolute: one cannot be bribed
or paid off to do anything against the company. The book is blunt that this
makes a better villain than a hero, and that a player character will be a loyal
agent of Naruni Enterprises unless something very rare has gone wrong in its
memory or its programming.

That is a warning about the role, not a bar. The book gives the Repo-Bot its own
experience table alongside the Silhouette and the Draconid, which is its way of
saying the class is meant to be played.
',
       updated_at = datetime('now')
 WHERE class_id = 'naruni-repo-bot'
   AND instr(markdown, 'a bonus on two skills rather than on the category, so no category bonus is stored') > 0
   AND length(markdown) = 15326;

-- == yamabushi-mountain-priest ==
UPDATE imported_classes
   SET markdown = '---
id: yamabushi-mountain-priest
men_of_arms: false
occ_group: clergy
name: Yamabushi Mountain Priest
system: rifts
source_book: Rifts World Book 8: Japan p.60-64
category: occ
tags: [wilderness, divine, magic]
ppe_base: "P.E. x3, plus 1d6 per level of experience"
xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]
psionics_allowed: false
bonuses:
  attributes: { PE: 1 }
  combat: { roll: 2 }
  saves: { horror_factor: 1, possession: 4, other: [ { label: "vs elemental magic", bonus: 2 } ] }
  pools: { sdc: "3d6", hp: "1d6" }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { teng_jutsu: 3 } }
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Sewing", base: 45, per_level: 5, note: "Printed as Sew (+5%)." }
    - { name: "Swimming", base: 60, per_level: 5, note: "Printed as Swim (+10%)." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "Printed as Identify Plants & Fruits (+15%)." }
    - { name: "Japanese Mythology", base: 35, per_level: 5, note: "+5%" }
    - { name: "Lore: Magic", base: 35, per_level: 5, note: "Printed as Magic Lore (+10%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Japanese at 98%." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Literacy: Japanese at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two languages of choice (+15% each). Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Fasting", base: 56, per_level: 3, note: "Temple skill (ability 14): the book prints 56% +3% per level. Two weeks without food is easy with water; after that roll under the skill to avoid becoming weak or sick." }
    - { name: "W.P. Staff", base: 0, per_level: 0, note: "No jodo abilities." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Basic Martial Arts/Judo", base: 0, per_level: 0, note: "Can be changed to Teng-jutsu at the cost of three other skill selections; no other combat alternatives are allowed." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 10 }
      - { name: "Physical", except: ["Wrestling", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise", "Concealment"], note: "Streetwise +8%, Concealment +6%; the two bonuses differ, so no category bonus is stored." }
      - { name: "Science", bonus: 5 }
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Cross Bow", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Trident", "W.P. Whip"], note: "Any ancient types, including sword." }
      - { name: "Wilderness", bonus: 5 }
    note: "Four other skills, plus one at levels 2, 4, 8 and 12. Communications, Electrical, Espionage, Mechanical, Military, Pilot (not even horsemanship; priests walk or ride in a cart) and Pilot Related: none."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    categories:
      - "Domestic"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Wrestling", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise", "Concealment"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Cross Bow", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Trident", "W.P. Whip"] }
      - "Wilderness"
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
    note: "Two secondary skills at levels one, four, eight and twelve, from the related list with its limits, without the bonuses in parentheses, at base skill level."
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "hooded cape or cloak", qty: 1, from: ["cape-long-hooded", "hooded-cloak"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "sandals", qty: 1 }
  - { item_id: "climbing-rope-per-foot", qty: 42, note: "A 12 foot (3.6 m) and a 30 foot (9 m) length of rope/cord." }
  - { item_id: "small-sack", qty: 1, note: "The small pouch filled with 20 to 30 small stones (see The Power of Stone)." }
  - { item_id: "sack", qty: 2, note: "Two medium sacks." }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "water-skin-1-gallon", qty: 1, note: "A large water skin." }
  - { item_id: "food-rations", qty: 1, note: "2D4 days of rations." }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "knife-large", qty: 1, note: "Butcher knife." }
  - { item_id: "knife-small", qty: 1, note: "Small combat knife." }
  - { item_id: "frying-pan", qty: 1 }
  - { item_id: "grappling-hook", qty: 1, note: "Grappling hook and cord for climbing." }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "spikes-wooden-stakes-6-wood", qty: 1, note: "Six wood or iron stakes, for climbing." }
  - { item_id: "hand-axe", qty: 1, note: "Small hand axe, for chopping wood and climbing." }
  - { choose: 1, label: "wood or iron staff", qty: 1, from: ["quarterstaff", "iron-staff"] }
special_abilities:
  - name: "The Healing Earth"
    description: "On a mountain, or touching a boulder at least twice a man''s size, the priest channels earth energy from the stone through his body into a patient: stops internal bleeding and bleeding from even the deepest wounds, restores 2D4 hit points or S.D.C., and the patient then heals normally. Others only, never himself; one additional patient at once per two levels of experience. P.P.E.: 10. Ritual time: two minutes of meditation."
  - name: "Cleansing Earth"
    description: "In a pool of clear fresh or ocean water, cleanses a sick or injured person of disease, poison, drugs, alcohol, magic potions and similar impurities: further damage, penalties and duration are negated (damage already taken remains), and victims of poison or disease are +10% to save vs coma/death. While performing it in or near the water the priest is invulnerable to possession and +10% to perform an exorcism. Others only; one additional person at once per two levels. P.P.E.: 10. Ritual time: six minutes."
  - name: "Fire Earth"
    description: "Standing in lava or atop a volcano, absorbs its power: impervious to all heat and fire, including M.D. plasma and magic fire, and can cast Ignite Fire, Fuel Flame and Fire Ball as a 5th level wizard. Can also speak to the mountain to quiet an active volcano, turn a lava flow or make a dormant one rumble (never erupt). Lasts 8 hours plus one per level. Himself only. P.P.E.: 10 +1 per hour of duration. Ritual time: one minute of meditation and chant."
  - name: "Good Earth Above"
    description: "Hanging naked and upside down over the edge of a mountain top, peak, giant boulder or waterfall, or treetop, the priest regenerates per hour: 20 hit points and 20 S.D.C. (mountain top), 12 (peak), 7 (boulder or waterfall), 4 (treetop), purging poison, drugs and disease within 1, 2, 1D4+2 or 1D4+4 hours; bones mend in 1D4, 1D4+3, 2D4+2 or 2D4+6 days; +60%, +30%, +15% or +10% to save vs coma. No food or water throughout. Interrupted, the restored points halve and he suffers -2 initiative, -1 attack per melee and loses his roll and breakfall bonuses until he finishes. While in the ritual he is invulnerable to possession, mind control, illusion and the elements. Himself only. P.P.E.: 0 mountain top, 1 peak, 2 boulder, 3 treetop. A Millennium Tree''s top counts as a mountain top."
  - name: "Spirit Earth"
    description: "The same ritual focused on mind and spirit, for 24 hours of insight per level. He may temporarily learn one spell or skill per two levels. Spells are limited to Calm Storms, Summon Storms, Summon Fog, Circle of Protection: Superior, Close Rift, Mystic Portal, Water to Wine, Wind Rush, Spoil (Food and Water), Purification (Food and Water), Stone to Flesh, Repel Animals, Breathe Without Air, Globe of Daylight and any earth elemental (warlock) spell, cast at 8th level (mountain top), 6th (peak), 4th (boulder or waterfall) or 2nd (treetop). A skill (not martial arts or physical) is 50% +40%, +20%, +10% or +5% by the same places. He may also commune with spirits within an 80 mile (128 km) diameter: 40% +40%, +20%, +10% or +5%, -40% for a specific spirit. Once every 30 days, except at the solstices. Himself only. P.P.E.: half his current P.P.E., minimum 20. Ritual time: 2D4 hours, half on a mountain top or Millennium Tree."
  - name: "Iwa-Kami (Holy Rock)"
    description: "Eight days of uninterrupted fasting meditation atop a rock at least twice his size, on a ley line, coaxes its kami to reveal itself: 42% +1% per level. The rock becomes a healing stone (as The Healing Earth, for children, pregnant women and people of good alignment or intent, eight times a week; four times that at the solstices, ten times when four or more planets align), or makes crops within 10 miles (16 km) 50% more bountiful, or the local game plentiful. The same rock may be tried once every eight years. P.P.E.: permanently loses 2 P.P.E. and spends 50, which recovers normally."
  - name: "The Power of Stone"
    description: "By swallowing stones the priest becomes a mega-damage being: 6 M.D.C. per stone, up to two stones per level, on top of hit points, S.D.C. and other M.D.C. While empowered: impervious to normal heat, cold, fire and ice; M.D., magic fire and cold (including plasma and fusion) do half damage; withstands winds to 70 mph (impervious to Wind Rush); lifts and carries 100 times normal; punches do +1D6 damage (not M.D. unless an M.D. attack). Penalties: Spd reduced by a third, one fewer attack per melee; skin turns pale grey. Himself only. Duration: five minutes per stone. P.P.E.: 10."
  - name: "Earth''s Energy (Feng Shui/Geomancy)"
    description: "An innate ability, not a skill: senses the P.P.E. in an area, whether good or evil forces control it, and whether its flow is natural or being tapped; along a ley line senses the direction of a nexus, its strength, coming ley line storms, a connected Rift (and whether it opens on a world ruled by demons or alien intelligences), travelling elementals, and boulders, waterfalls or mountains on the line. Base skill: 40% +5% per level. Constant and automatic; no P.P.E."
  - name: "Hojo-e"
    description: "A three minute chant to kami with pushing hand motions; at its end caged or netted birds and fish are freed without harming cage or net. Range: 100 feet (30.5 m) +10 feet (3 m) per level. Area: 10 foot (3 m) radius per level. P.P.E.: 10."
  - name: "Chi M.D. Death Blow"
    description: "As the samurai (printed 47): against oni, demons, dragons, elementals and other supernatural beings and creatures of magic, a punch, kick, staff or other hand weapon strike does double normal damage plus P.S. bonus as mega-damage, and the victim cannot bio-regenerate it for 1D4 hours. Must be pure of spirit and intent (never in anger, fear or revenge); counts as two melee attacks; useless against bots, borgs, power armor, ordinary humans and S.D.C. creatures, and with guns or bows. Draws on inner P.P.E. and counts as a magical attack."
  - name: "Kangeiko & Shochu Geiko"
    description: "Mystic martial arts power: can endure severe weather unprotected for a full day without ill effect. +3D6 S.D.C., +1D6 hit points and +1 P.E. (in the class bonuses); invulnerable to stun and paralysis attacks; fire and cold attacks do half damage, including magic and plasma; impervious to the withering flesh atemi power."
  - name: "Yamabushi Meditation"
    description: "Temple skill: body motionless without fatigue or pain, mind clear and rested; recovers I.S.P., P.P.E. and other internal resources three times as fast; aware of the surroundings and can leave the position instantly with no combat penalty. Not a substitute for sleep. Base skill: 30% +5% per level. Can meditate for 24 hours at first level plus 24 hours per level."
  - name: "Elemental Sight"
    description: "Can see and speak to all elemental beings."
level_progression:
  - { level: 1, grants: ["+1 to save vs horror factor"] }
  - { level: 2, grants: ["+1 to save vs horror factor"] }
  - { level: 4, grants: ["+1 to save vs horror factor"] }
  - { level: 7, grants: ["+1 to save vs horror factor"] }
  - { level: 9, grants: ["+1 to save vs horror factor"] }
  - { level: 11, grants: ["+1 to save vs horror factor"] }
  - { level: 13, grants: ["+1 to save vs horror factor"] }
  - { level: 15, grants: ["+1 to save vs horror factor"] }
restrictions:
  - "Cannot possess psionic powers."
  - "Cybernetics: none, ever; they interfere with magic and are not natural. About 15% might consider bio-systems."
  - "The earth powers are diminished in truly lifeless wastelands."
extraction_notes: |
  - Rifts World Book 8: Japan printed 60-64 (cache p061-p065). The class
    text starts at the foot of printed 60; the stat block runs from printed
    63 into printed 64, whose left column ends with the equipment list and
    whose right column continues with the weapons, money and cybernetics;
    printed 64 checked against a render.
  - Section: the book''s contents list on printed 43 files the class under
    "Warrior & Monk Occupational Character Classes" as "Yamabushi (priest)
    O.C.C.". JUDGEMENT: stored men_of_arms false and occ_group clergy,
    because the book calls it a priest and says it is not an especially
    skilled martial artist; the heading itself lumps warriors and monks.
  - xp_table from the "Yamabushi, Demon Queller" column of the Experience
    Point Tables (folio 216, cache p217), read off a render: lower bounds
    stored; level 15 prints 440,001-510,000.
  - Magic: the book grants no spell list and no spell picks. The priest''s
    magic is the eight earth rituals, each a special ability with its own
    P.P.E. cost. Fire Earth lets him cast Ignite Fire, Fuel Flame and Fire
    Ball only while it lasts, and Spirit Earth teaches a spell from a fixed
    list temporarily; both are conditional, so no magic block is stored
    and the spells are prose in those abilities.
  - Psionics: "Yamabushi cannot possess psionic powers" (ability 13):
    psionics_allowed false.
  - Mystic martial arts: Kangeiko & Shochu Geiko is granted outright (ability
    11), not picked; its +3D6 S.D.C., +1D6 hit points and +1 P.E. are in
    bonuses, the rest in the ability. The class picks no body hardening
    exercise or zenjoriki power.
  - P.P.E. "P.E. x3 plus 1D6 per level of experience" (ability 12).
  - Bonuses (ability 13): +1 vs horror factor at levels 1, 2, 4, 7, 9, 11,
    13 and 15; +2 roll with punch/fall/impact; +4 vs possession; +2 vs
    elemental magic as saves.other.
  - No S.D.C. or hit point base is printed beyond the Kangeiko bonus.
  - Money: none printed; the book says only that the yamabushi has little
    need for money and rarely acquires a fortune. No starting_money stored.
  - Skills: Sew -> Sewing, Swim -> Swimming, Identify Plants & Fruits ->
    Identify Plants & Fruit, Magic Lore -> Lore: Magic (catalog spellings).
    Japanese language and literacy stored as Language: Native Tongue and
    Literacy: Native Language at 98%. Fasting is ability 14''s temple skill;
    the book prints its own 56% +3%, so base 56 over the catalog''s 40.
    Yamabushi Meditation has no catalog row and is an ability.
  - Related: Rogue prints Streetwise +8% and Concealment +6%, so no category
    bonus; Technical''s +10% to language skills (printed 64, read off a
    render) is a second, scoped Technical entry on every Language: and
    Literacy: row and the bare Literacy row (BOOK-INGEST-AUDIT F138). The
    Weapon Proficiencies line "any ancient types, including sword" is an
    only list of the catalog''s pre-gunpowder W.P.s (JUDGEMENT on W.P.
    Targeting, Rope, Shield, Lance, Paired Weapons; Harpoon & Spear Gun,
    Grappling Hook, Deadball, Tomahawk and Quick Draw left out).
  - Hand to Hand: Basic Martial Arts/Judo may be changed to Teng-jutsu for
    three other skill picks; nothing else offered.
  - Equipment: a 12 ft and a 30 ft rope stored as 42 ft of climbing rope;
    the pouch of 20-30 stones as a small sack; medium sacks as sack; large
    water skin as the one gallon skin; 2D4 days of rations as one
    food-rations (about a week); six wood or iron stakes as the six-stake
    row. A weapon of choice reflecting the W.P. is not stored. Typically no
    armor to start.
---

## Lore

The yamabushi ("to lie down in the mountains") are priests of the Shugendo religion, which holds mountains, stone formations, great trees and places of natural beauty sacred as the homes of kami. By climbing peaks and performing secret ceremonies - fasting, sutra recitation, meditation, fire rites, hanging from cliffs to confess sins - they draw physical and mystical strength from the living earth. They are not demon hunters or great martial artists; they are spiritual wanderers, close to nature much as western druids are.

They keep no monasteries or temples: the mountains are their temples and all of Japan their domain. They mark holy rocks and trees with knotted ritual rope, travel alone to the lowlands to heal, counsel, teach and defend farmers and laborers, and sometimes join adventurers on a quest the mountain spirits whisper to them. They accept D-bees into their ranks (about 35% of them), respect the eta and nonhumans, and talk and bargain with tengu, faeries, dragons, elementals, ghosts and even oni to keep the peace - though no yamabushi has ever made a pact with a force of darkness. Lesser demons fear them; greater ones respect them.

They look like vagabonds: patched, grass-stained clothes, a frayed hooded cape, long hair full of seeds and burrs. Armor is rare and, when worn, is of Millennium Tree. They favor peasant weapons, a wand or staff, a kusari-gama or a sickle.

Alignment: any, typically 35% scrupulous, 25% unprincipled and 40% other. No attribute or racial requirements; a high P.E., M.E. and M.A. help. Male or female, no difference.

## Earth Powers

The priest draws his magic from the earth rather than his own reserve, which is why his powers weaken in truly lifeless wastelands. Every ritual except Earth''s Energy costs P.P.E. and most need a place: a mountain, a giant boulder, a waterfall, a pool of clear water, a volcano, or a treetop. The higher the place, the stronger the effect.

## Starting Wealth

None to speak of. Wilderness folk welcome a mountain priest with food and a bed; the larger towns and cities see only a vagabond.
',
       updated_at = datetime('now')
 WHERE class_id = 'yamabushi-mountain-priest'
   AND instr(markdown, '{ name: "Technical", note: "Any; +10% to language skills only, so no category bonus is stored." }') > 0
   AND length(markdown) = 19915;

-- == demon-queller ==
UPDATE imported_classes
   SET markdown = '---
id: demon-queller
men_of_arms: true
occ_group: men-of-arms
name: Demon Queller
system: rifts
source_book: Rifts World Book 8: Japan p.64-66
category: occ
tags: [combat, hunter]
attribute_requirements: { ME: 14, PS: 12 }
ppe_base: "P.E. x2 + 1d4x10, +2d6 per level of experience"
starting_money: "2d6x1000"
xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]
magic:
  type: "spell"
  spells:
    - "Globe of Daylight"
    - "See the Invisible"
    - "Sense Evil"
    - "Turn Dead"
    - "Breathe Without Air"
    - "Impervious to Fire"
    - "Circle of Flame"
    - "Fire Ball"
    - "Call Lightning"
    - "Charismatic Aura"
    - "Magic Net"
    - "Tongues"
    - "Words of Truth"
    - "Exorcism"
    - "Banishment"
    - "Protection Circle: Simple"
  spells_schedule:
    - { level: 4, count: 1, note: "One (at most two) new spells every three levels, only ones that help fight demons and the supernatural." }
    - { level: 7, count: 1, note: "One (at most two) new spells every three levels, only ones that help fight demons and the supernatural." }
    - { level: 10, count: 1, note: "One (at most two) new spells every three levels, only ones that help fight demons and the supernatural." }
    - { level: 13, count: 1, note: "One (at most two) new spells every three levels, only ones that help fight demons and the supernatural." }
bonuses:
  attributes: { PS: 2, PE: 2, Spd: "3d6" }
  pools: { sdc: "4d4x10+90", hp: "2d6" }
  combat: { attacks: 1, strike: 1 }
  saves: { horror_factor: 1, mind_control: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { jujitsu: 1, karate: 1 } }
  occ_skills:
    - { name: "Climbing", bonus: 5, note: "+5%" }
    - { name: "Swimming", base: 50, per_level: 5, note: "No bonus printed; catalog base." }
    - { name: "Dance", bonus: 15, note: "+15%" }
    - { name: "Sing", bonus: 10, note: "+10%" }
    - { name: "Wilderness Survival", bonus: 10, note: "+10%" }
    - { name: "Land Navigation", bonus: 10, note: "+10%" }
    - { name: "Tracking (people)", bonus: 15, note: "Printed as Tracking (+15%; humans and demons)." }
    - { name: "Japanese Mythology", bonus: 15, note: "+15%" }
    - { name: "Lore: Demons & Monsters", bonus: 20, note: "Printed as Demon Lore (+20%)." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Literacy: Japanese or Chinese at 98% - pick one." }
    - { name: "Language: Chinese", base: 98, per_level: 0, note: "98%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Japanese at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One language of choice (+15%), beside Japanese and Chinese." }
    - { name: "Mathematics: Basic", bonus: 10, note: "+10%" }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. three of choice." }
    - { name: "Hand to Hand: Kendo", base: 0, per_level: 0, note: "Can be changed to Jujitsu or Karate at the cost of one other (related) skill selection; no other combat alternatives are allowed." }
  occ_related_skills:
    count: 3
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "Printed as Pilot: Horsemanship only (+10%)." }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - { name: "Weapon Proficiencies", note: "Any, including modern energy weapons." }
      - "Wilderness"
    note: "Three other skills, plus one at levels 2, 4, 8 and 12. Communications, Electrical, Mechanical, Military, Pilot Related and Science: none. All new skills start at level one proficiency."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 13, count: 1 }
    note: "Three at level one and one more at levels 3, 7 and 13, from the related list and its limits, without the bonuses in parentheses, starting at the base skill level."
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "Several sets of clothing." }
  - { item_id: "robe", qty: 1, note: "Silk robe." }
  - { item_id: "boots", qty: 1, note: "Black boots." }
  - { item_id: "gloves", qty: 1, note: "Black gloves." }
  - { item_id: "rope-per-20-feet-6-m", qty: 2, note: "A 30 foot (9 m) length of rope." }
  - { item_id: "large-sack", qty: "1d6" }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1, note: "Sleeping roll." }
  - { item_id: "canteen", qty: 2, note: "Two canteens or a large water skin." }
  - { item_id: "food-rations", qty: 2, note: "4D4 days of rations; each catalog row is about a week." }
  - { choose: 1, label: "high quality large sword", qty: 1, from: ["no-dachi-rifts", "katana-rifts"] }
  - { item_id: "knife", qty: 1 }
special_abilities:
  - name: "Mystic Body Hardening Exercises"
    description: "Brutal martial training has given four of the mystic body hardening powers (Mystic Martial Arts Powers, printed 196-197), all cumulative: Stone Ox, Chi-Gung, Iron Hand (Kanshu) and Kick Practice (Chagi). Their attribute, pool, strike and speed bonuses are stored on the class. For 1 P.P.E. (thanks to Chi-Gung) the queller can turn both the S.D.C. and hit points of his body into M.D.C. for two minutes (8 melee rounds); the change is instant, an act of will."
  - name: "Stone Ox"
    description: "The ultimate body hardening exercise. +2 P.S., +1 P.E. and +4D4x10 S.D.C. (stored as bonuses). Fatigues at half the normal rate and can lift and carry 50 times the normal weight capacity."
  - name: "Chi-Gung (M.D.C. Skin)"
    description: "Skin that blades cannot cut nor arrows pierce: natural A.R. 18 and at least 100 S.D.C. +1 P.E., +2D6 hit points and +90 S.D.C. (stored as bonuses). The S.D.C. and hit points of the skin become mega-damage whenever the chi-gung focus is used, at 1 P.P.E. per two minutes (8 melee rounds)."
  - name: "Iron Hand (Kanshu)"
    description: "Toughened hands take no damage striking hard objects and can handle burning coals, boiling oil, lava or fire without harm; magic fire and plasma do half damage to the hands. Damage: normal punch 2D6 S.D.C., karate punch 4D6 S.D.C., knife hand or palm strike 1D6 M.D., power punch 2D6 M.D. (counts as two melee actions; double if the character already inflicts M.D.). Can pull a punch to do S.D.C. +4 to damage on all hand strikes."
  - name: "Kick Practice (Chagi)"
    description: "Kicks at all heights, the splits, overhead jump kicks. Damage: normal kick 4D6 S.D.C., karate and wheel kick 6D6 S.D.C., snap kick 2D6 S.D.C., jump kick 3D6 M.D., roundhouse kick 6D6 M.D., power kick 5D6 M.D. (counts as two melee actions; double if the character already inflicts M.D.). Can pull a kick to do S.D.C. Leaps 10 feet (3 m) high +2 feet (0.6 m) per level from a standing position; add 10 feet to lengthwise leaps with a running start. +1 to strike and +3D6 Spd (stored as bonuses)."
  - name: "Chi M.D. Death Blow"
    description: "As the samurai (printed 47): against oni, demons, dragons, elementals and other supernatural beings and creatures of magic, a punch, kick, staff, spear or other hand-held weapon strike does double normal damage plus P.S. bonus as mega-damage, and the creature cannot bio-regenerate that injury for 1D4 hours. Counts as two melee attacks. Requires purity of spirit and intent: never in anger, fear or for revenge. No effect on M.D.C. bots, borgs, power armor, ordinary humans or S.D.C./hit point creatures, and not usable with guns or bows. Draws on the character''s P.P.E. and counts as a magical attack."
  - name: "Meditation"
    description: "Body motionless without fatigue or pain, mind clear and rested; recovers I.S.P., P.P.E. and other internal resources three times as fast as normal. Not a substitute for sleep. Remains subconsciously aware of the surroundings and can leave meditation instantly with no combat penalties. Base skill 20% +6% per level of experience; can meditate one hour at first level, plus one hour per level of experience."
  - name: "Demon Slayer''s Resistances"
    description: "Impervious to possession, and impervious to the bite and mind control of vampires. +1 to save vs mind control and +1 to save vs horror factor at levels 1, 2, 4, 6, 7, 9, 11, 13 and 15 (stored as bonuses)."
  - name: "Horror Factor to Demons"
    description: "Has a horror factor of 15 to lesser demons and 10 to greater demons."
restrictions:
  - "Seldom wears armor (does not need it), but may use any traditional, magic or modern mega-damage body armor."
  - "Weapons also include a possible second large sword and three weapons of choice (usually reflecting W.P. skills); a horse if he can ride."
trackable_resources: []
extraction_notes: |
  - Printed 64-66 (cache p065-p067); printed 65 checked against a render.
    The class is listed under the book''s Warrior & Monk O.C.C.s heading
    (printed 43 list, cache p044), and no S.D.C. formula is printed:
    men_of_arms true, occ_group men-of-arms.
  - xp_table from the Yamabushi, Demon Queller ladder, p217 (folio 216),
    column three, second block, read off a render; lower bounds stored.
    Level 15 prints 440,001-510,000.
  - Mystic body hardening: the class is GRANTED four exercises outright
    (Stone Ox, Chi-Gung, Iron Hand, Kick Practice/Chagi, printed 64, with
    their descriptions on printed 196-197). It picks none and prints no later
    picks, so the level-gated pick finding (to be filed for Rifts Japan mystic
    martial arts powers in BOOK-INGEST-AUDIT.md) does not apply to it. Their
    unconditional bonuses are summed on the class: P.S. +2 (Stone Ox), P.E.
    +2 (Stone Ox and Chi-Gung, one each), Spd +3D6 (Chagi), strike +1
    (Chagi), S.D.C. +4D4x10 (Stone Ox) +90 (Chi-Gung), hit points +2D6
    (Chi-Gung). Conditional numbers (Iron Hand +4 damage on hand strikes, the
    damage tables, leaping, A.R. 18, the 100 S.D.C. floor) are prose.
  - The class''s own M.D.C. transformation (1 P.P.E., S.D.C. AND hit points,
    two minutes) replaces the general 5 P.P.E., S.D.C.-only, one-minute rule
    of printed 196; the class text says so and is followed. Not a stored
    conversion (mdc_from_hp_sdc is permanent); prose.
  - Spells: the 16 initial spells are granted by name. "At best one or two
    spells every three levels" is stored as one pick at levels 4, 7, 10 and
    13, with the demon-fighting restriction and the possible second spell in
    the pick''s note. JUDGEMENT: which levels "every three levels" means.
  - P.P.E. prints "P.E x2 plus 1D4x10 and 2D6 per level of experience".
  - Bonuses: +1 attack per melee; +1 save vs mind control; +1 vs horror
    factor at levels 1, 2, 4, 6, 7, 9, 11, 13 and 15. Impervious to
    possession and to vampire bite and mind control, and the horror factor
    of 15/10 to lesser/greater demons, are abilities (no field).
  - Skills: Demon Lore -> Lore: Demons & Monsters, Tracking -> Tracking
    (people). Literacy: Japanese or Chinese (pick one) -> Literacy: Native
    Language at 98. Languages Japanese and Chinese at 98: the catalog holds
    Language: Chinese but no Japanese row, so Japanese is stored at 98 as
    Language: Native Tongue, as the other Japan classes store it; the
    language of choice (+15%) is a Language: Other pick.
  - Hand to Hand: Kendo may become Jujitsu or Karate for one "other"
    skill; no other alternative, so costs lists those two only.
  - Related: three, plus one at levels 2, 4, 8 and 12. Medical: First Aid
    or Holistic Medicine only. Pilot: horsemanship only (+10%) is the
    Horsemanship category limited to Horsemanship: General. Technical''s +10%
    to language skills (printed 66, read off a render) is a second, scoped
    Technical entry on every Language: and Literacy: row and the bare Literacy
    row (BOOK-INGEST-AUDIT F138).
  - Secondary: three at level one, plus one at levels 3, 7 and 13.
  - Equipment: several sets of clothing -> clothing, silk robe -> robe,
    black boots -> boots, black gloves -> gloves, 30 ft of rope -> two 20 ft
    rows, sleeping roll -> bedroll, two canteens (or a large water skin) ->
    canteen x2, 4D4 days of rations -> two food-rations rows (about a week
    each), large sword -> a choice of no-dachi-rifts or katana-rifts. The
    possible second sword, three weapons of choice and the horse are in
    restrictions.
  - Chi M.D. Death Blow: "same as the samurai"; its terms are the True
    Samurai''s, printed 47 (cache p048).
---

## Lore

The demon queller is a warrior trained in a monastery (most of them in China) in martial arts, body hardening and demon lore, yet he is neither monk nor priest. He casts spells only as tools against demons, serves no lord and no nation, and lives for one purpose: to rid the world of demons and supernatural evil. Against the oni he is relentless and merciless, but he will let a foe escape before he risks an innocent life, and the oni know it: they take hostages and bait traps with the helpless. Many quellers have a weakness for beautiful women and a good party, which the demons also exploit.

Quellers usually travel alone or with other heroes, rarely more than two or three together. Nobody knows how many there are; rumor ranges from a few hundred to tens of thousands across China, India, Korea and Japan. The order began in China, where most still come from (about 65%); only about 5% are Japanese, and D-bees have made up about a fifth of the ranks over the last two centuries. Women may in theory become quellers, but none has been seen in Japan.

Most are big, muscular, loud and gregarious men with a moustache and a wild bushy beard, silk robes, a scholar''s cap or other hat and large black boots. Their hardened bodies let them fight without armor. Between hunts they drink, eat, dance, sing and spend lavishly, and they are welcome guests of lords and emperors, though samurai and other men of arms often resent them. Favorite weapons are large swords, axes and polearms, and they love magic weapons, vibro-blades and heavy modern blasters.

Alignment: any, but typically 40% scrupulous, 20% unprincipled, 20% anarchist and 20% other. A high I.Q. and P.P. help but are not required. Racial requirements: none, though most are human males.
',
       updated_at = datetime('now')
 WHERE class_id = 'demon-queller'
   AND instr(markdown, '{ name: "Technical", note: "Any; +10% to language skills only, so no category bonus is stored." }') > 0
   AND length(markdown) = 15352;

-- == african-witch ==
UPDATE imported_classes
   SET markdown = '---
id: african-witch
name: African Witch
system: rifts
source_book: Rifts World Book 4: Africa p.72-78
category: occ
tags: [shapeshifter, evil]
occ_group: magic
men_of_arms: false
xp_table: [0, 1951, 3901, 7801, 15601, 30201, 45401, 60601, 85801, 110201, 150401, 210601, 265801, 325201, 375401]
attribute_requirements: { IQ: 10, ME: 10, PE: 12 }
ppe_base: "P.E. x3, plus 2d6 per level of experience"
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { basic: 1, expert: 1, martial_arts: 2, assassin: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", bonus: 20, note: "Speaks and is literate in native tongue (+20%)." }
    - { name: "Literacy: Native Language", bonus: 20, note: "Speaks and is literate in native tongue (+20%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "One language of choice with literacy, plus one additional language (+20%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literate in the language of choice above (+20%)." }
    - { name: "Lore: Demons & Monsters", bonus: 10, note: "The book prints ''Lore: Monsters & Demons (+10%)''; the catalog row is Lore: Demons & Monsters." }
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored." }
    - { name: "Wilderness Survival", bonus: 5, note: "Wilderness Survival (+5%)" }
    - { name: "Carpentry", bonus: 10, note: "Carpentry (+10%)" }
    - { name: "Skin & Prepare Animal Hides", bonus: 10, note: "The book prints ''Skin and Prepare Animal Hides (+10%)''." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], bonus: 5, note: "Disguise, forgery and intelligence only (+5%)." }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5, note: "First aid or holistic medicine only (+5%)." }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", note: "Any; horsemanship +5%." }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - { name: "Technical", note: "Any; +10% on lore, literacy, language or writing (printed 74). The next entry carries it, and the scoped Communications entry carries it to the Literacy: rows the catalog files there (BOOK-INGEST-AUDIT F138)." }
      - { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Electrical, Mechanical and Military: none. All new skills start at level one proficiency. Hand to Hand is not free: Basic costs one of these picks, Expert one, Martial Arts or Assassin two."
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 3, count: 4 }, { level: 9, count: 4 }]
    note: "From the related list, excluding the categories marked None, without the bonuses in parentheses; all start at the base skill level."
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { choose: 1, label: "war club or staff", qty: 1, from: ["war-club", "quarterstaff"] }
  - { item_id: "african-throwing-knives", qty: "1d6" }
  - { choose: 1, label: "energy pistol or rifle", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"], note: "The book says an energy pistol or rifle without naming one; this is the catalog''s common set." }
magic:
  type: "spell"
  spells_starting: 3
  spells_starting_groups:
    - { count: 1, from_list: "bad", note: "One witch spell (Bad Medicine) at level one." }
    - { count: 2, from: ["Death Trance", "Globe of Daylight", "See Aura", "Sense Magic", "Thunderclap"], note: "Two common spells, level one spells only, from the witch''s Available Common Spell Magic list. She casts them at DOUBLE the listed P.P.E." }
  spell_lists:
    bad:
      - "Bad Medicine: Charge Object with Evil"
      - "Bad Medicine: Delirium"
      - "Bad Medicine: Evil Eye"
      - "Bad Medicine: Magic Drums"
      - "Bad Medicine: Money Doubling"
      - "Bad Medicine: Pestilence Touch"
      - "Bad Medicine: Poison Touch"
      - "Bad Medicine: Summon & Control Biting Insect Swarm"
      - "Bad Medicine: Summon & Control Locust Swarm"
      - "Bad Medicine: Summon & Control Drought"
      - "Bad Medicine: Summon & Control Heat Wave"
      - "Bad Medicine: Taboo"
    common:
      - "Death Trance"
      - "Globe of Daylight"
      - "See Aura"
      - "Sense Magic"
      - "Thunderclap"
      - "Befuddle"
      - "Concealment"
      - "Detect Concealment"
      - "Fear"
      - "Turn Dead"
      - "Armor of Ithan"
      - "Breathe Without Air"
      - "Fingers of the Wind"
      - "Fuel Flame"
      - "Ignite Fire"
      - "Negate Poison/Toxin"
      - "Ley Line Transmission"
      - "Fool''s Gold"
      - "Repel Animals"
      - "Trance"
      - "Calling"
      - "Circle of Flame"
      - "Escape"
      - "Fly"
      - "Horrific Illusion"
      - "Compulsion"
      - "Magic Pigeon"
      - "Tongues"
      - "Agony"
      - "Animate and Control Dead"
      - "Constrain Being"
      - "Invisibility (Superior)"
      - "Life Drain"
      - "Wind Rush"
      - "Commune with Spirits"
      - "Exorcism"
      - "Locate"
      - "Luck Curse"
      - "Minor Curse"
      - "Oracle"
      - "Sickness"
      - "Spoil"
      - "Curse: Phobia"
      - "Protection Circle: Simple"
      - "Summon and Control Canines"
      - "Banishment"
      - "Control & Enslave Entity"
      - "Summon Shadow Beast"
      - "Summon and Control Rodents"
      - "Summon and Control Animals"
      - "Summon Fog"
      - "Summon and Control Entity"
      - "Summon Lesser Being"
      - "Talisman"
  spells_schedule:
    - { level: 2, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 3, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 3, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 4, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 5, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 5, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 6, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 7, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 7, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 8, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 9, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 9, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 10, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 11, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 11, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 12, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 13, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 13, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 14, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list. Cast at double P.P.E." }
    - { level: 15, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list. Cast at double P.P.E." }
bonuses:
  attributes: { ME: 1, PE: 2, PS: 2 }
  pools: { sdc: 25 }
  saves: { spell_magic: 1, ritual_magic: 1, horror_factor: 4 }
special_abilities:
  - name: "Creature of the night"
    description: "Nightvision 200 feet (61 m), and she can see the invisible. Witches shun daylight and are most active at night. A natural ability; no P.P.E. is spent."
  - name: "Lycanthropy"
    description: "At night only, she can turn into a large snake, dog, panther, ram or goat. In animal form she keeps her mental attributes, hit points and powers, and can still speak and cast magic; she gains +10 to Spd and a base 50% Prowl, and her S.D.C. becomes M.D.C. (only at night and only in animal form). Conditional, so it is prose rather than a bonus line."
  - name: "Create magic snakes"
    description: "She can create up to seven magic snakes whose only purpose is to kill a chosen victim (or that person''s animals). Each drains her of 10 hit points or S.D.C. while it exists, and she cannot go below 10 hit points; the points return when the snake is killed or comes back. Each snake is about 3 feet (0.9 m) long: 10 hit points, two attacks per melee, +1 initiative, +4 to strike, parry and dodge, Prowl 63%, Spd 44 (30 mph/48 km). Its bite is magic venom: save 15 or higher (13 for M.D.C. creatures) or take 6D6 damage, S.D.C./hit points or M.D. by the victim''s nature, and -1 initiative and -1 Spd per bite for 2D4 minutes. The bite leaves no mark or trace of poison, so deaths look natural; only a true Medicine Man can see the bites."
  - name: "Spit kills snakes"
    description: "Her ordinary spit kills a snake instantly by splitting it open. She is impervious to all snake venom, but not to other poisons and drugs."
  - name: "Eat away at the life of her enemies"
    description: "Nocturnal, in human or animal form. While the victim sleeps she breathes in 4D6 S.D.C./hit points of life essence once per night (no effect on mega-damage creatures) and adds the stolen S.D.C. to her own; each visit also lowers the victim''s combat and saving throw bonuses by one. The loss does not heal, even by magic, and the victim tires twice as fast and looks pale and sickly. At 30% of normal hit points the victim is in her power: she senses his location within 500 miles (804 km), can mentally call him, and he cannot raise a hand against her. No saving throw, except a Medicine Man''s charm or protection magic keeping her away. The victim is saved by being taken far away (losing what was taken for good), by persuading her to return it, or by slaying her."
  - name: "Double-cost common magic"
    description: "Her common (non-Bad Medicine) spells cost TWICE the normal P.P.E. - Armor of Ithan, normally 10, costs her 20. The app stores catalog costs, so the doubling is recorded here."
  - name: "Extra P.P.E."
    description: "She can draw additional P.P.E. from ritual magic and blood sacrifices, the same as most practitioners of magic."
  - name: "Insanity"
    description: "The witch is often mentally unbalanced: one roll on the Witch Insanity Table (printed 74) at each of levels 3, 7, 9 and 13, or simply a pick at that time. The table is the Insanity pick group that follows, one banked roll or pick per listed level."
  - { choose: 1, at_levels: [3, 7, 9, 13], from: ["Insanity (01-20): No Insanity", "Insanity (21-25): Phobia - Medicine Men", "Insanity (26-30): Obsession - Tormenting Medicine Men", "Insanity (31-40): Obsession - Torture and Killing", "Insanity (41-45): Obsession - Wealth", "Insanity (46-50): Obsession - Danger", "Insanity (51-55): Phobia - Gods of Light", "Insanity (56-60): Obsession - Hates the Light of Day", "Insanity (61-65): Obsession - Dead Things", "Insanity (66-70): Phobia - Millennium Trees", "Insanity (71-75): Obsession - Hates Good Priests", "Insanity (76-80): Phobia - Spirits of Light", "Insanity (81-85): Phobia - Psychic Healing", "Insanity (86-90): Random Affective Disorder", "Insanity (91-95): Random Insanity", "Insanity (96-00): Psychosis"], note: "Witch Insanity Table (printed 74): roll once, or pick, at each of levels 3, 7, 9 and 13. Rows 86-00 send the player to another table." }
  - name: "Insanity (01-20): No Insanity"
    description: "Roll 01-20 or choose. No insanity this time. (Printed 74.)"
  - name: "Insanity (21-25): Phobia - Medicine Men"
    description: "Roll 21-25 or choose. Phobia: medicine men. (Printed 74.)"
  - name: "Insanity (26-30): Obsession - Tormenting Medicine Men"
    description: "Roll 26-30 or choose. Obsession: she likes to hurt and torture medicine men and to make them look foolish, incompetent or untrustworthy. (Printed 74.)"
  - name: "Insanity (31-40): Obsession - Torture and Killing"
    description: "Roll 31-40 or choose. Obsession: she likes to torture, hurt and kill others. (Printed 74.)"
  - name: "Insanity (41-45): Obsession - Wealth"
    description: "Roll 41-45 or choose. Obsession: she loves wealth and craves riches. (Printed 74.)"
  - name: "Insanity (46-50): Obsession - Danger"
    description: "Roll 46-50 or choose. Obsession: she loves danger and takes needless risks. (Printed 74.)"
  - name: "Insanity (51-55): Phobia - Gods of Light"
    description: "Roll 51-55 or choose. Phobia: Gods of Light. (Printed 74.)"
  - name: "Insanity (56-60): Obsession - Hates the Light of Day"
    description: "Roll 56-60 or choose. Obsession: she hates the light of day and tries to avoid it. (Printed 74.)"
  - name: "Insanity (61-65): Obsession - Dead Things"
    description: "Roll 61-65 or choose. Obsession: she loves dead things and surrounds herself with skeletons, mummies, zombies and the like. (Printed 74.)"
  - name: "Insanity (66-70): Phobia - Millennium Trees"
    description: "Roll 66-70 or choose. Phobia: Millennium Trees, which she avoids at all costs. (Printed 74.)"
  - name: "Insanity (71-75): Obsession - Hates Good Priests"
    description: "Roll 71-75 or choose. Obsession: she hates good priests of all kinds. (Printed 74.)"
  - name: "Insanity (76-80): Phobia - Spirits of Light"
    description: "Roll 76-80 or choose. Phobia: spirits of light/angels. (Printed 74.)"
  - name: "Insanity (81-85): Phobia - Psychic Healing"
    description: "Roll 81-85 or choose. Phobia: psychic healing. (Printed 74.)"
  - name: "Insanity (86-90): Random Affective Disorder"
    description: "Roll 86-90 or choose. The row sends the player to roll for a random affective disorder; that second roll is made by hand and its result is not stored here. (Printed 74.)"
  - name: "Insanity (91-95): Random Insanity"
    description: "Roll 91-95 or choose. The row sends the player to the random insanity table of the Rifts RPG; that second roll is made by hand and its result is not stored here. (Printed 74.)"
  - name: "Insanity (96-00): Psychosis"
    description: "Roll 96-00 or choose. The row sends the player to roll for a psychosis; that second roll is made by hand and its result is not stored here. (Printed 74.)"
trackable_resources: []
restrictions:
  - "The book presents this O.C.C. as a Non-Player Character villain and says it is ideal as an N.P.C. but NOT recommended as a player character. It is imported so a Game Master can build her; player use is at the Game Master''s discretion."
  - "Always evil. The African witch is an agent of evil by definition, and is feared, hunted and destroyed without mercy wherever witchcraft is recognized."
  - "Cybernetics: starts with none and avoids them because they interfere with magic. Only cybernetic bio-systems for health reasons will be considered."
  - "Vehicle is limited to non-military transportation: a hover vehicle, motorcycle or riding animal."
  - "The character also starts with 6D6x1000 credits'' worth of precious stones, gems, gold and other items, over and above the coin in starting_money. That field is coin only, so the valuables are recorded here."
  - "Bad Medicine spells are available only to the African Witch; they are a tradition of their own in the catalog. Her common spells are limited to the Available Common Spell Magic list."
extraction_notes: "Rifts World Book 4: Africa pp.72-74 (the class) and 78 (the alphabetical Bad Medicine list and the Available Common Spell Magic list); the Bad Medicine spell descriptions on 74-78 were imported separately as the african-witch tradition. The book heads her ''African Witch - Non-Player Character Villain'' and advises against player use; she is imported as an ordinary published class at the user''s decision, with the warning carried as a restriction and in GM Notes, the way add-night-witch-class.sql carries its N.P.C. villain line. men_of_arms is false: she sits under the book''s African Magic O.C.C. heading on printed 72, with the Medicine Man, Rain Maker and Priest. The book states no S.D.C. formula, only a +25 S.D.C. bonus, stored as a pool bonus. XP ladder read off the rendered printed 160, African Witch column; the book prints upper bounds and each is stored plus one. Spells: one witch spell at levels 1, 3, 5, 7, 9, 11 and 13; two common spells at level one (level one only) and two more each level, capped at her own level, all from the page-78 list. The level-one picks are starting groups and every later pick is a schedule entry drawing on a named list, because a flat spells_per_level cannot be bound to a list. Page-78 names mapped to catalog rows: ''Tum Dead'' (text layer) is Turn Dead; Fingers of Wind is Fingers of the Wind; Negate Poison is Negate Poison/Toxin; Animate & Control Dead is Animate and Control Dead; Invisibility: Superior is Invisibility (Superior); Summon & Control Canine is Summon and Control Canines; Control/Enslave Entity is Control & Enslave Entity; Summon & Control Rodents and Animals are the ''and'' spellings; Summon Entity (250, level 12) is Summon and Control Entity. Every one of the 54 sits at the catalog level the book lists it under. The book''s base costs differ from the catalog on four: Befuddle 3 (catalog 6), Ignite Fire 5 (catalog 6), Exorcism 25 (catalog 30), Summon Lesser Being 420 (catalog 425); not corrected here. The doubled P.P.E. cost of her common spells is prose. Hand to Hand is not granted: the book sells Basic or Expert for one related pick and Martial Arts or Assassin for two, carried as hand_to_hand costs. JUDGEMENT: the secondary skills line reads ''select four secondary skills at levels three and nine''; stored as four at EACH of levels 3 and 9 and none at level one, the reading used across this book''s O.C.C. drafts (the Agogwe entry on printed 118 states the same rule per level). The wooden knife, torture picks and pins and the beaded jewellery have no fitting catalog row; scalpels (a scalpel row exists) are unquantified; the book offers 1D6 throwing sticks OR throwing knives and only the knives are stored, because a choice cannot carry a rolled quantity. The 50% chance of one or two magic weapons is not stored. 2026-10-05: the Witch Insanity Table (printed 74, read off the rendered page) is a pick-one group at levels 3, 7, 9 and 13, the levels the page prints (three, seven, nine and thirteen), by BOOK-INGEST-AUDIT.md F116. Its sixteen rows are band-named options, 01-20 through 96-00, covering 01-00 with no gap or overlap as printed, each its own special ability. No row prints a number, so none carries bonuses. The three rows that send the player to another table (86-90 random affective disorder, 91-95 the Rifts RPG random insanity table, 96-00 psychosis) stay as that row''s prose. The Insanity ability is kept as a pointer to the group."
---

# African Witch

## Lore

In the tribal societies of Rifts Africa, the witch is the most despised and
feared creature there is. She creates "bad medicine" to hurt others, to take
revenge, to profit at others'' expense or to upset the harmony of nature, and she
keeps company with evil spirits - demons, devils and other evil forces. Calling
a medicine man or priest a "witch doctor" is the worst insult there is.

Most African witches (75%) are female. Her special powers are natural abilities
rather than spells: she is a creature of the night, a shapechanger, a maker of
killing snakes and an eater of life. Her spells are not studied the way a
wizard''s are - they are taught to her by a demon, or simply come to her as she
gains experience.

Where a witch rules a tribe, its people are either enslaved to her or are her
willing, evil minions; the rightful king, medicine man and priest are usually
dead or made ill. Medicine men and priests hunt witches wherever witchcraft is
recognized, and slay them without mercy.

## Alignment

Always evil.

## GM Notes

The book marks this O.C.C. as a Non-Player Character villain: ideal as an
N.P.C., and not recommended as a player character. She is available here so a
Game Master can build one.

Witches are extremely self-serving, manipulative and dangerous, have little
regard for the living, and seek wealth and power. They work alone or in groups
of 2D4. The book also counts evil practitioners of other magic - necromancers,
blood druids, shifters, stone masters, mind melters, mind bleeders - as
"witches" in the eyes of the tribes.
',
       updated_at = datetime('now')
 WHERE class_id = 'african-witch'
   AND instr(markdown, '{ name: "Technical", note: "+10% on lore, literacy, language or writing skills only." }') > 0
   AND length(markdown) = 22789;

-- == fu-yao-da-chia ==
UPDATE imported_classes
   SET markdown = '---
id: fu-yao-da-chia
name: "Fu Yao Da Chia (Great Demon Catching Hero)"
system: rifts
source_book: Rifts World Book 25: China 2 p.77-83
category: occ
tags: [hunter, combat, wilderness]
occ_group: men-of-arms
attribute_requirements: { ME: 12, PE: 12 }
sdc_base: "1d6x10 + P.E."
starting_money: "6d6x100"
xp_table: [0, 2161, 4321, 8641, 17201, 27301, 37401, 55501, 76001, 102001, 146001, 192001, 248001, 298801, 356901]
psionics:
  isp_base: "M.E. + 2d6, +2 per level of experience"
bonuses:
  attributes: { PS: 2, PE: 2, PP: 2 }
  combat: { pull_punch: 2, entangle: 2 }
  saves: { spell_magic: 1, horror_factor: 3, possession: 1, curses: 1 }
  at_level:
    - { level: 3, saves: { possession: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 5, saves: { possession: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 9, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 15, saves: { possession: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 20, note: "Printed as Basic Math (+20%)." }
    - { name: "Calligraphy", bonus: 5, note: "+5%" }
    - { name: "Demon Wrestling", base: 30, per_level: 5, note: "No bonus printed; catalog base." }
    - { name: "Fasting", bonus: 5, note: "+5%" }
    - { name: "Tiao Qi/Chinese Checkers", bonus: 15, note: "Printed as Games: Tiao Qi (+15%). Knows how to cheat or throw a game, at -10% to the skill." }
    - { name: "Imperial Bureaucracy & Administration", bonus: 5, note: "+5%" }
    - { name: "Land Navigation", bonus: 20, note: "+20%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Native Chinese speaker, 95%." }
    - { name: "Language: Demongogian", base: 80, per_level: 0, note: "The native language of demonkind, 80%." }
    - { name: "Literacy: Chinese", base: 85, per_level: 0, note: "Chinese characters/ideograms, 85%." }
    - { choose: 1, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters"], bonus: 20, note: "Lore: one of Literacy: Ancient & Classical Chinese, Taoist Chinese Mythology or Demons & Monsters (+20%)." }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { choose: 2, from: ["Field Armorer & Munitions Expert", "Camouflage", "Demolitions", "Military Etiquette", "Military Fortification", "Recognize Weapon Quality", "Trap Construction", "Trap/Mine Detection"], bonus: 15, note: "Military: any two (+15% each). The book offers Armorer/Field Armorer for traditional Chinese weapons or for modern weapons; both are the catalog''s Field Armorer & Munitions Expert." }
    - { name: "Radio: Basic", bonus: 10, note: "+10%" }
    - { name: "Tracking (people)", bonus: 15, note: "Printed as Tracking (humanoids and all forms of demons; +15%)." }
    - { name: "Wilderness Survival", bonus: 15, note: "+15%" }
    - { choose: 3, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming"], note: "Physical: any three; Aerobic Athletics or General Athletics, not both." }
    - { choose: 2, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.: any two. Battle Axe is W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.: any two." }
    - { choose: 1, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.: any one. Spear (Throwing) is W.P. Spear." }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.: any one." }
    - { name: "W.P. Gien Bian (Steel Whip)", base: 0, per_level: 0, note: "Automatic; the chi-trained character can make it a mega-damage weapon." }
    - { choose: 1, from: ["Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Select one as the basis of the character''s combat skills. No other style is offered." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", except: ["Juicer Technology", "M.D. in Cybernetics", "Pathology"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Cardsharp", "Concealment", "Dickering", "Find Contraband", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Pick Locks", "Prowl", "Streetwise"] }
      - "Science"
      - { name: "Technical", note: "Any; +15% to Art, Rope Works, Mythology and Lore skills. The next entry carries it on Lore; on Art, Rope Works and Mythology it is not stored." }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 15 }
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "Five at level one, plus one at levels 4, 8 and 12. Pilot Related: none. All new skills start at level one proficiency."
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", except: ["Juicer Technology", "M.D. in Cybernetics", "Pathology"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Cardsharp", "Concealment", "Dickering", "Find Contraband", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Pick Locks", "Prowl", "Streetwise"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
    note: "Three at level one, plus one at levels 3, 7, 9 and 13, from the related list and its limits, at the base skill level."
equipment_starting:
  - { item_id: "china-book-of-ten-thousand-demons-wan-gui-yao", qty: 1, note: "The Wan Gui Yao, Essentials of the 10,000 Infernals." }
  - { choose: 1, label: "Demon Hunter Sword", qty: 1, from: ["china-sword-of-demon-hunting-the-hunter-blade", "china-sword-of-demon-hunting-the-hunter-slayer-blade", "china-sword-of-demon-hunting-the-demon-hunter-defender", "china-sword-of-demon-hunting-the-demon-hunters-vengeance"] }
  - { item_id: "china-binding-demon-catching-mirror", qty: 1, note: "The eight-sided Demon Catching Mirror." }
  - { item_id: "china-binding-demon-snare", qty: 2, note: "Two demon snares." }
  - { item_id: "china-bone-swords-and-weapons", qty: 1, note: "One S.D.C. weapon of bone: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "knife-silver-plated", qty: 1, note: "One S.D.C. weapon of silver: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "e-clip", qty: 2, note: "For the energy weapon of choice." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged cotton, wool and leather traveling clothes, with hat." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "Heavy winter/mountain over-garments." }
  - { item_id: "clothing", qty: 1, note: "Embroidered silk indoor suit: slippers, pants, shirt, long jacket, scarf and hat." }
  - { item_id: "robe", qty: 1, note: "Silk robe." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book of 3D6x10 pages." }
  - { item_id: "pencil", qty: "1d4" }
  - { item_id: "paper-dz-9x12-inch-sheets", qty: 1, note: "4D6 sheets of blank paper." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "Fire starter kit or cigarette lighter." }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4", note: "Scented candles." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "Small meat cleaver." }
  - { item_id: "backpack", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "multi-purpose-pouch", qty: 2, note: "A belt pouch and a small neck pouch." }
  - { item_id: "rope-per-foot", qty: 30, note: "30 feet (9.1 m) of rope." }
  - { item_id: "leg-manacles", qty: 2, note: "Two sets of leg irons for binding demons, each with four feet (1.2 m) of chain." }
  - { item_id: "chain-per-foot-rifts", qty: 8, note: "The leg irons'' chain, four feet a set." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - { choose: 1, at_levels: [{ level: 1, count: 4 }, 3, 6, 9, 12, 15], from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Vital Breath", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: four to start, then one more at each of levels 3, 6, 9, 12 and 15, from this same list (printed 79)." }
  - name: "Body Hardening: Control Revulsion"
    description: "Trained by exposure to gore and filth: +3 to save vs Horror Factor and vs the vomit and gag response to terrible smells, slime, blood and gore. (printed 92.)"
    bonuses: { saves: { horror_factor: 3 } }
  - name: "Body Hardening: Demon Digestion"
    description: "Can eat nearly anything, belch, retch or rumble at will (a gross-out Horror Factor 13 at worst), senses poison in the system and expels it in 10 minutes to 2 hours. +1 P.E.; damage, penalties and duration of poisons and drugs are halved. (printed 92.)"
    bonuses: { attributes: { PE: 1 } }
  - name: "Body Hardening: Dislocation Training"
    description: "Joints deliberately dislocated in training: +2 to save vs pain, +1 P.E., +1 to roll with impact, +5% to Escape Artist if the character has it, and +2D6+12 S.D.C. (rolled by the player, not applied). (printed 92.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 2 }, combat: { roll: 1 } }
  - name: "Body Hardening: Feign Death"
    description: "Plays dead convincingly: +2 to save vs pain, +10 S.D.C., +5% vs coma/death, +1 vs Horror Factor; holds breath five minutes, +1 minute at levels 3, 6, 9 and 12. Feign death or coma 40% +4% per level (+10% against a simple examination). (printed 93.)"
    bonuses: { saves: { pain: 2, horror_factor: 1, coma_death_pct: 5 }, pools: { sdc: 10 } }
    progression:
      - { level: 3, text: "Holds breath for six minutes." }
      - { level: 6, text: "Holds breath for seven minutes." }
      - { level: 9, text: "Holds breath for eight minutes." }
      - { level: 12, text: "Holds breath for nine minutes." }
  - name: "Body Hardening: Hardened Internal Organs"
    description: "Moves vital organs out of a blade''s path: a successful roll (40% +4% per level) holds the hit point damage of a piercing wound it can anticipate to 1 point (S.D.C. damage is taken normally). +1 P.E., +1 to save vs pain, and recovers hit points and S.D.C. twice as fast. (printed 93.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 1 } }
  - name: "Body Hardening: Heal Internal Organs and Injury"
    description: "Healing meditation: restores 1D6 hit points an hour, up to a third of the total (25% of M.D.C. for a mega-damage being), stops bleeding in 2D4 melee rounds; +10% vs coma/death. (printed 93.)"
    bonuses: { saves: { coma_death_pct: 10 } }
  - name: "Body Hardening: Laugh at Pain"
    description: "The Lau Re maneuver: +2 to save vs pain, +1 M.E., M.A. and P.E., +5% vs coma/death, and +8% (+2% per level) to intimidate when showing off pain resistance; the skill is 50% +4% per level and scares ordinary people as Horror Factor 13. (printed 93.)"
    bonuses: { attributes: { ME: 1, MA: 1, PE: 1 }, saves: { pain: 2, coma_death_pct: 5 } }
  - name: "Body Hardening: Life Stone"
    description: "A stone fused beside the heart makes the character a minor mega-damage being with 1D6+6 M.D.C. that is always there and is lost before S.D.C. (attacks direct to hit points bypass it); +1 to roll with impact, +5% vs coma/death and +4D6 S.D.C. (both dice rolled by the player, not applied). (printed 93.)"
    bonuses: { saves: { coma_death_pct: 5 }, combat: { roll: 1 } }
  - name: "Body Hardening: Resist Psychic Drain"
    description: "Fatigues at half the normal rate; +2 to save vs possession and psychic drain, +1 vs Demonic Curses, magic vapors and breath attacks, and magic illness. (printed 93.)"
    bonuses: { saves: { possession: 2, curses: 1 } }
  - name: "Body Hardening: Vital Breath"
    description: "Senses foul air and holds breath at once: +2 to save vs breath attacks, gases, poisoned air and sudden loss of pressure, +2 initiative to hold breath in time, three extra minutes of held breath, and can share air. (printed 93.)"
    bonuses: { saves: { other: [ { label: "vs breath attacks, gases and poisoned air", bonus: 2 } ] } }
  - name: "Body Hardening: Yung Chin (Eternal Clarity)"
    description: "Resists alcohol at +20% (+4% per level) and suffers half the penalties of drunkenness (-2 initiative, -1 strike, parry and dodge, Spd down one quarter, skills down 6%). (printed 94.)"
  - { choose: 1, from: ["Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)", "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"], note: "Mystic Martial Art Power: one of these four (printed 79). The chosen power''s later levels are shown on the sheet as text (display only; nothing a later level says is added to the character''s numbers)." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"
    description: "Requires the Acupuncture skill. Level 1: Healing Tien-Hsueh for 6 I.S.P. a healing, each one melee action - 4D6 hit points, 2D6+10 S.D.C. or 3D8 M.D.C. restored, or a 40% +4% per level chance to cure illness, infection, fever or coma at once, or to repair, install or remove a cybernetic device, engine or machine. Tien-Hsueh Reversal for 5 I.S.P. - undoes any Tien-Hsueh effect, or a knockout, stun, dizziness, blindness, paralysis or other temporary shock, in one melee round; against the work of a higher-level master it takes 2D6 melee rounds per level of difference. One Finger Touch - no damage, +4 to strike, the delivery for every Tien-Hsueh attack. Tien-Hsueh Powers, one chosen at each of levels 3, 6, 8, 11 and 13: Blindness (2D6 hours blind at -10 to strike, parry, dodge and other combat rolls, 2D6 melee rounds if the victim rolls with the blow, nothing if parried or dodged; 8 I.S.P.), Blood Flow (2D8 direct to hit points past S.D.C. or S.D.C. armor, 1D8 past M.D.C. armor, or 1D8 M.D. or 2D8 P.P.E. dispelled against a supernatural creature; 10 I.S.P.), Electronic (start or stop any machine, device or vehicle by touch; 10 I.S.P.), Enlightenment Strike (frees a victim within 30 ft and in line of sight from possession, Chi control or mind control, taking a full melee round; 20 I.S.P.), Neural (paralyzes a declared limb for 3D6 minutes with no roll with impact, needing an 8 or better to strike, though the victim may still parry or dodge, the defender winning ties, and an arm or foot used to parry is itself paralyzed; 8 I.S.P.), Puppet-Dance (a grip on the back of the neck and a strike roll of 10 or higher makes the victim a living puppet with two attacks a melee and no bonuses, while the master''s own bonuses are halved and his skills are -20%; 15 I.S.P. on a natural being, 20 on a lesser supernatural being, 30 on a Fox or Monkey Spirit or a dragon hatchling, 50 on most Greater Demons, Immortals, Ghosts and Entities; it does not work on adult dragons, Elementals, Demon Lords, Demigods, Godlings or deities, the victim cannot be made to speak, and while he holds the puppet the master can perform no other Tien-Hsueh and nothing that spends I.S.P. or P.P.E.), Demon Strike (leaves a supernatural M.D.C. being or lesser creature of magic with only 1D4x10% of its M.D.C.; 32 I.S.P.) or Withering Flesh (removes all natural S.D.C., or only 1D6 S.D.C. if the victim rolls with impact, never touching hit points; 12 I.S.P.). (printed 35-37.)"
    progression:
      - { level: 2, text: "Internal Practice Advancement #1: +2 to M.E. and +1 to I.Q." }
      - { level: 3, text: "Select one Tien-Hsueh Power from the list." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Penetrating Tien-Hsueh: for 12 I.S.P. the character''s Tien-Hsueh powers reach through an M.D.C. body or M.D.C. armor, which no longer acts as a barrier." }
      - { level: 6, text: "Select one more Tien-Hsueh Power." }
      - { level: 7, text: "Internal Practice Advancement #2: +2 to P.P. and +1 to M.A." }
      - { level: 8, text: "Select one more Tien-Hsueh Power." }
      - { level: 9, text: "Long-Distance Tien-Hsueh: for 24 I.S.P. any Tien-Hsueh can be projected up to 400 ft (122 m) per level at a victim the character can see (binoculars, a scope or a monitor count) or is speaking with over a phone or radio; through contact with a detached spirit or animus it reaches that being''s body at any distance." }
      - { level: 10, text: "Add 5D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Select one more Tien-Hsueh Power." }
      - { level: 12, text: "Internal Practice Advancement #3: +2 to I.Q. and +1 to M.E." }
      - { level: 13, text: "Select one more Tien-Hsueh Power." }
      - { level: 14, text: "Knockout or stun on a Natural 17 or better." }
      - { level: 15, text: "Add 1D6x10+24 to the character''s Permanent I.S.P. Base." }
  - name: "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)"
    description: "Level 1: Mantis Armor for 5 I.S.P. - chitin plates with M.D.C. equal to the character''s S.D.C. +20 per level (hit points stay hit points), every attack able to do mega-damage, +4 parry, +2 disarm, +3 entangle. Mantis Hook Attack - 3D6 M.D. or 5D6 S.D.C. Spectral Praying Mantis for 20 I.S.P. - a human-sized (6 ft) animus evoked in three melee rounds of full concentration, burning 1 I.S.P. an hour and costing its maker 1 I.S.P. for each M.D.C. point of damage it takes. As a separate animus it has two attacks a melee, +4 strike, 2D6 M.D. or 4D6 S.D.C., +2 to save vs dispel, M.D.C. equal to its maker''s S.D.C. (20% of the M.D.C. of a mega-damage character) and may go no more than 1000 ft away; worn as power armor it gives +1 initiative, +1 disarm, +1 entangle, +2D6 damage and M.D.C. equal to the maker''s S.D.C. +20 (25% of the M.D.C. of a mega-damage character). Giant Mantis: it can be doubled in size up to three times (12, 24, 48 ft), each doubling giving +5 Supernatural P.S., +40 M.D.C. and +1D6 damage at -10% Spd and -1 dodge; the book prices each doubling at both 15 and 10 I.S.P. (printed 37-39.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Spectral Praying Mantis Advancement #1: the separate animus has four attacks a melee in all, +10 M.D.C., +2 to damage and +1 to Spd." }
      - { level: 4, text: "Tong Lun Body Hardening #1: +2 to P.P., +1 to M.E. and +14 S.D.C." }
      - { level: 5, text: "Evoke the Spectral Praying Mantis in two melee rounds." }
      - { level: 6, text: "Spectral Praying Mantis Advancement #2: the separate animus moves as fast as its maker with the same attacks per melee and may go up to 10 miles (16 km) away. Worn as power armor it gives +1 attack per melee, +20 M.D.C. to the armor, +6 to damage, +2 to Spd, +1 initiative, +1 disarm and +1 entangle." }
      - { level: 7, text: "Tong Lun Body Hardening #2: +16 S.D.C., +2 to Spd and +1 to P.P." }
      - { level: 8, text: "The combat moves of the Wrestling skill (pin, incapacitate, crush and bear hug) and +3D6 S.D.C., without Wrestling''s other bonuses." }
      - { level: 9, text: "Evoke the Spectral Praying Mantis in one melee round." }
      - { level: 10, text: "Add 4D6+20 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Spectral Praying Mantis Advancement #3: the animus no longer needs dispelling and stays around all the time, with its maker''s physical attributes, attacks and combat bonuses plus +30 M.D.C., +10 to damage and +4 to Spd. It remains even at zero I.S.P. (its attacks, Spd, M.D.C. and combat bonuses halved) and may go up to 50 miles (80 km) away. Worn as power armor it adds two extra melee attacks and +40 M.D.C." }
      - { level: 12, text: "Tong Lun Body Hardening #3: +14 S.D.C., +1 to M.E. and +1 to Spd." }
      - { level: 13, text: "Add 5D6+30 to the character''s Permanent I.S.P. Base." }
      - { level: 14, text: "Evoke the Spectral Praying Mantis instantly." }
      - { level: 15, text: "Spectral Praying Mantis Advancement #4: the mantis is now solid, cannot return to spectral form or be worn as power armor, and must eat and drink daily. Its usual size is about 24 ft (doubled twice) and it can be doubled four times (96 ft). Separate animus: +80 M.D.C., +10 to damage, +2 attacks per melee, +3 strike, +2 automatic dodge, +2 disarm, +2 entangle; at zero I.S.P. it stays, with attacks and combat bonuses halved. It may be up to 200 miles (320 km) from its maker." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
  - name: "Pest Exterminator for the Celestial Court"
    description: "The Celestials regard demon hunters as their royal rat catchers. The character hunts, captures, reforms or permanently binds demons, exterminating them only when nothing else serves; helps those who would depose the Yama Kings; and ranks his targets by the harm they do to the helpless and innocent."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Can gather and direct chi, even in very weak P.P.E. environments, to give otherwise ordinary weapons mega-damage. Comes with W.P. Gien Bian (Steel Whip), a favoured weapon for entrapping demons."
  - name: "Powers of Meditation"
    description: "The character''s inner strength is given over to meditation and sensing chi, so he never gains psionic powers beyond those of his Mystic Martial Art; I.S.P. is M.E. +2D6, +2 per level. Skilled in Meditation and resistant to Demonic Curses: curses with a time limit last half as long for him."
  - name: "W.P. Demon Snare"
    description: "A special proficiency used only to entrap: a snare catches an opponent''s neck, wrist or ankle, cannot parry and does no damage on impact, but pinches and gouges as it tightens, hurting susceptible demons. Includes braiding snares from string, rope, cloth or leather."
  - name: "Affliction: Demonic Curses"
    description: "Starts with none, but many demon catchers carry 1-4 Demonic Curses at any time, handed out by their adversaries (Rifts China One, pages 54-60). Most are temporary or removable, and the catcher knows the means."
  - name: "Demonic Entourage"
    description: "Usually has, or soon acquires, one captive demon (typically a Lesser Demon, Goblin or Nature Spirit) in rehabilitation, kept in chains and set to hard labour; Greater Demons come after three or four levels, and seldom more than 4-6 are kept. Roll 1D6 for a captive''s outlook: 1-2 Belligerent Captive, 3 Plays the Game, 4 Frightened Hater, 5 Searching for the Path to Enlightenment, 6 an Enlightened Demon. The G.M. plays captives as N.P.C.s and most catchers start with none."
  - name: "Other Demon Queller Equipment"
    description: "May buy useful magic items worth up to 5,000 credits in all from the Green Scarf list, acquired from elder catchers or other Taoist artisans rather than the Green Scarf Sect, which the character despises. Also starts with four other traditional Chinese weapons (3D6 rounds of ammunition for each projectile weapon), one S.D.C. gun with 100 rounds (half may be silver coated), one energy weapon of choice, identification documents and a Yama Kingdom passport, 2D6+2 pieces of incense and a small incense burner, herbs, a tea bottle, two sets of chopsticks and 30 cups of uncooked rice."
restrictions:
  - "Cybernetics: none."
  - "Never gains psionic powers beyond the abilities of the chosen Mystic Martial Art."
trackable_resources: []
extraction_notes: |
  - Printed 77-83 (cache p078-p084; p079 is a full-page illustration, printed
    78). Every number read off a 200 dpi render. The section heading is Demon
    Quellers (printed 77), Rifts China Demon Queller O.C.C.s; the brief files
    the Demon Quellers as men-of-arms (occ_group). S.D.C. is printed
    (1D6x10 + P.E.), so no men_of_arms line. No hit point formula is printed.
  - Name: the book''s header is Fu Yao Da Chia O.C.C., also known as Great Demon
    Catching Hero, Demon Hunter, Demon Queller and Champion Demon Catcher. Not
    named plain Demon Queller (Japan''s class holds that id).
  - xp_table: the Demon Catching Hero / Soothsayer / Shadow Warrior column,
    printed 160 (cache p161), read off a render; lower bounds stored.
  - attribute_requirements: "M.E. should be above 11, with a P.E. of 12 or
    better" stored as minimums of 12 and 12 (JUDGEMENT: "should" read as a
    requirement).
  - I.S.P.: M.E. +2D6, +2 per level. No psionic tier is printed and the class
    never gains powers beyond its Mystic Martial Art, so psionics states only
    isp_base.
  - Bonuses: +2 P.S., P.E., P.P.; +2 pull punch, +2 entangle; +1 save vs magic
    (spell_magic only, as the Anti-Monster''s plain save vs magic was stored);
    +3 vs Horror Factor; +1 initiative at 4, 8 and 12; +1 vs possession at
    1, 3, 5, 7, 9, 13 and 15 (the book skips 11); +1 vs Demonic Curses (the
    curses save) at 1, 4, 8 and 12. Curses with a time limit lasting half as
    long is prose.
  - Mystic Body Hardening Exercises (printed 92-94): four to start, then one at
    levels 3, 6, 9, 12 and 15 (printed 79). One group over the shared block
    states the whole schedule, four at level 1 and one at each later level
    (BOOK-INGEST-AUDIT.md F127). Mystic Martial Art Power: one of Cotton Fist, Touch
    Mastery, Praying Mantis or Drunken Style, a choose 1. Touch Mastery
    requires Acupuncture, which this class can reach only as a Medical related
    pick.
  - 2026-10-05, re-read off renders of printed 79 and 92-94. Printed 79, item 2:
    select four Demon Queller Body Hardening Exercises to start, then one
    additional at levels 3, 6, 9, 12 and 15. Item 4: select either Mien-Ch''uan
    (Cotton Fist), Tien-Hsueh (Touch Mastery), Tong Lun (Praying Mantis Style)
    or Xian Pu (Drunken Style) Kung Fu for the character''s Martial Art Powers;
    one power, chosen once, and the page gives no later pick of a second.
    Stored: the choose 1 over the four powers, unchanged, and the choose 4 over
    the eleven exercises, unchanged that day. On 2026-10-13 the exercise group
    took the five later picks as well, each level stating its own count
    (BOOK-INGEST-AUDIT.md F127; the schedule re-read on printed 79, cache
    p080). The chosen power''s later levels are shown on the sheet as text
    since 2026-10-05 (BOOK-INGEST-AUDIT.md F117; display only, nothing a later
    level says is added to the character''s numbers).
    The section''s own lead-in (printed 92, Mystic Body Hardening Notes) sets no
    schedule of its own: it says only that the bonuses work with any martial art
    and that trainers are sadistic when a Demon Queller adds a new exercise, so
    the count and the levels are each class''s. No exercise prints a level table;
    the only thing tied to named levels is Feign Death''s held breath (+1 minute
    at levels 3, 6, 9 and 12, printed 93), and four exercises carry a per-level
    percentage (Feign Death, Hardened Internal Organs, Laugh at Pain, Yung Chin).
  - Hand to Hand: one of Dog Boxing, Eighteen Weapons or Shao-Lin Kung Fu is a
    choose 1 in occ_skills. The page prints no exchange price and offers no other
    style, so hand_to_hand costs is empty (no style sold).
  - Skills: Basic Math -> Mathematics: Basic; Games: Tiao Qi -> Tiao Qi/Chinese
    Checkers; Tracking (humanoids and demons) -> Tracking (people); Lore: Taoist
    Chinese Mythology -> Lore: Chinese Mythology: Taoist. Language: Native
    Chinese 95%, Demongogian 80% and Literacy: Chinese 85% are stored flat at the
    printed figure (JUDGEMENT, as the Adarok stored its printed language figures).
    Calligraphy and Fasting are the RUE rows plus the printed bonus. The military
    choice''s two Armorer lines (traditional Chinese weapons, modern weapons) both
    map to Field Armorer & Munitions Expert, so the list holds it once.
    W.P.s: Battle Axe -> W.P. Axe; Large Sword and Small Sword -> W.P. Sword;
    Spear (Throwing) -> W.P. Spear; Crossbow -> W.P. Cross Bow; Bolt-Action ->
    W.P. Bolt Action Rifle. The catalog holds none of the book''s finer W.P.s.
  - W.P. Demon Snare (Special!) has no catalog row and is not stubbed; it is a
    special ability (JUDGEMENT: no stubs in this batch, and a W.P. carries no
    percentage).
  - Related: five, plus one at 4, 8 and 12. Rogue''s only-list: Card Shark is the
    catalog''s Cardsharp; Find Contraband, Weapons & Cybernetics is Find
    Contraband (filed Military); Gambling is both catalog Gambling rows; Begging
    (Technical), Pick Locks (Espionage) and Prowl (Physical) are cross-category
    and reachable because those categories are granted. Technical''s +15% to Art,
    Rope Works, Mythology and Lore (printed 83, read off a render) reaches
    every Lore: row through a second, scoped Technical entry
    (BOOK-INGEST-AUDIT F138); on Art, Rope Works and Mythology it is not
    stored. Pilot: any except
    military vehicles, robots and power armor, as the precedent except-list.
    Pilot Related: none, omitted.
  - Secondary: three, plus one at 3, 7, 9 and 13, the same limits without
    bonuses.
  - Equipment: Book of Ten Thousand Demons, one of the four Swords of Demon
    Hunting (choose), the Demon Catching Mirror. "Two demon snares" -> two
    china-binding-demon-snare rows (JUDGEMENT; the brief names that row, though
    the class can also braid ordinary snares). Bone and silver S.D.C. weapons ->
    china-bone-swords-and-weapons and knife-silver-plated. Leg irons ->
    leg-manacles x2 and 8 ft of chain. 30 ft rope -> rope-per-foot x30.
    Shoulder bag -> backpack; belt and neck pouch -> multi-purpose-pouch x2.
    The weapons of choice, S.D.C. gun, papers, incense and burner, herbs, tea
    bottle, chopsticks and rice have no row or no fixed choice and are prose in
    Other Demon Queller Equipment. The 5,000 credits of magic items is a
    purchase allowance, not coin, so it is prose and not in starting_money.
  - Secrets and Tricks of the Trade (printed 94-95) are play advice; one
    sentence of the lore paraphrases them.
  - Demonic Entourage''s 1D6 table and the G.M. note are prose.
---

## Lore

The Fu Yao Da Chia, the Great Demon Catching Hero, carries a tradition older than the Coming of the Rifts: a demon hunter''s craft passed from one poor teacher to one or two pupils across thousands of years, kept alive long after the world stopped believing in demons. In Rifts China, with the Yama Kings'' hordes everywhere, the old profession has finally found its moment, and its practitioners are cheered as heroes rather than dismissed as cranks.

What sets the Demon Catcher apart is his goal. Killing a demon is the last resort; the best outcome is a demon bound, humbled and, ideally, rehabilitated. He takes captives into a kind of harsh tutelage, hard labour, discipline, long lectures and, above all, fairness, teaching them trust and a sense of wonder until a few turn toward enlightenment. He has no illusions about how dangerous demons are, and when he is surrounded he fights without mercy.

He knows the enemy better than anyone: their weaknesses, their vanity, their greed and how to bluff, bribe or bully them, the sort of lore that Demon Quellers pass on as secrets and tricks of the trade. His tools are the Wan Gui Yao, a book naming ten thousand demons, a Demon Hunter Sword suited to his own nature, and a Demon Catching Mirror that traps any demon who looks into it, backed by years of brutal body hardening.
',
       updated_at = datetime('now')
 WHERE class_id = 'fu-yao-da-chia'
   AND instr(markdown, 'Mythology and Lore skills only, so no category bonus is stored.') > 0
   AND length(markdown) = 41043;

-- == wai-chia-wu-shih ==
UPDATE imported_classes
   SET markdown = '---
id: wai-chia-wu-shih
name: Wai Chia Wu Shih
system: rifts
source_book: Rifts World Book 25: China 2 p.52-54
category: occ
tags: [combat, healer]
occ_group: psychic
xp_table: [0, 2241, 4481, 9101, 18301, 30601, 42901, 62301, 85601, 105901, 155001, 210001, 285001, 370001, 440001]
race_restrictions: { only: ["none"], note: "Human, or a race so close to human in appearance that even an elder Wai Chia Wu Shih cannot tell the difference (GM''s call). Very few women are drawn to the order (under 2%)." }
attribute_requirements: { ME: 12 }
sdc_base: "4d6+38"
starting_money: "1d6x100"
bonuses:
  attributes: { ME: 4, MA: 2, PP: 2 }
  combat: { attacks_base: 4, strike: 1, dodge: 2, roll: 3, pull_punch: 4 }
  saves: { spell_magic: 3, horror_factor: 4, possession: 1, curses: 1 }
  at_level:
    - { level: 2, combat: { parry: 2, dodge: 2 } }
    - { level: 3, combat: { strike: 2, roll: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 4, combat: { parry: 1, dodge: 1, initiative: 1 }, saves: { possession: 1, curses: 1 } }
    - { level: 5, combat: { attacks: 1 }, saves: { possession: 1, curses: 1 } }
    - { level: 6, combat: { roll: 2, parry: 1, dodge: 1, disarm: 1 } }
    - { level: 7, combat: { strike: 1, damage_bonus: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 8, combat: { attacks: 1, initiative: 1 } }
    - { level: 9, saves: { possession: 1, curses: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 11, combat: { strike: 1, damage_bonus: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 12, combat: { roll: 1, parry: 1, dodge: 1, initiative: 1 } }
    - { level: 13, combat: { disarm: 2, entangle: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 14, combat: { attacks: 1 } }
    - { level: 15, combat: { strike: 2, damage_bonus: 4 }, saves: { possession: 1, curses: 1 } }
psionics:
  type: "minor"
  isp_base: "M.E. attribute number plus 6d6, +6 per level of experience"
  powers: ["Levitation"]
  powers_starting: 6
  categories_allowed: ["Healing", "Physical"]
  powers_starting_groups:
    - { count: 3, categories: ["Healing"], note: "Three psionic Healing abilities of choice." }
    - { count: 3, categories: ["Physical"], note: "Three psionic Physical abilities of choice." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%" }
    - { name: "Fasting", base: 45, per_level: 3, note: "+5%" }
    - { name: "Identify Plants & Fruit", base: 30, per_level: 5, note: "+5%. They live off the land, adding weeds, roots and mushrooms to their dinner; about 80% are strict vegetarians." }
    - { name: "Imperial Bureaucracy & Administration", base: 20, per_level: 5, note: "+10%; the book prints Imperial Bureaucracy & Administrative." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker (95%)." }
    - { name: "Literacy: Chinese", base: 90, per_level: 5, note: "The book prints Literacy: Chinese characters/ideograms (90%)." }
    - { choose: 3, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters", "Lore: Feng Shui/Geomancy"], bonus: 10, note: "Lore: any three of Literacy: Ancient & Classical Chinese, Chinese Classical Studies, Chinese Mythology - Taoist, Demons & Monsters, or Feng Shui/Geomancy (+10% each)." }
    - { name: "Meditation", base: 0, per_level: 0, note: "The character is highly skilled in Meditation." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical Skills: any two of Acrobatics, Aerobic or General Athletics, Body Building & Weight Lifting, Boxing, Climbing, Gymnastics, Running, Swimming or Wrestling." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Pick Locks"] }
      - "Horsemanship"
      - { name: "Medical", only: ["Acupuncture", "Chinese Herbal Medicine"], bonus: 10 }
      - { name: "Medical", except: ["Acupuncture", "Chinese Herbal Medicine"] }
      - { name: "Physical", except: ["Boxing"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 10 }
      - "Wilderness"
    note: "Communications, Electrical, Espionage, Mechanical, Military, Pilot Related and W.P.: none. Medical: any (+10% to Acupuncture and Chinese Herbal Medicine). Pilot: sail and row boats, bicycle and other very basic vehicles only; they prefer Horsemanship. Rogue: Begging, Calligraphic Forgery, Concealment, Dickering, Gambling, Palming, Pick Locks and Streetwise only. Technical: any (+5%; +10% to Lore and History skills). All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Domestic"
      - { name: "Espionage", only: ["Pick Locks"] }
      - "Horsemanship"
      - "Medical"
      - { name: "Physical", except: ["Boxing"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - "Technical"
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at the base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1, note: "Simple but sturdy traveling clothes of cotton, wool and leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "dress-clothing", qty: 1, note: "A complete suit of lightweight embroidered silk indoor clothing: slippers, pants, shirt, long jacket and robe." }
  - { item_id: "scarf", qty: 1, note: "Goes with the silk indoor clothing, with a hat." }
  - { item_id: "paper-dz-9x12-inch-sheets", qty: 1, note: "2D4x10 blank sheets of paper." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block (just add water)." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "bottle-pint", qty: 1, note: "A traveler''s tea bottle." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "A cooking knife." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "A large traveler''s shoulder bag." }
  - { item_id: "belt-purse", qty: 1, note: "A belt pouch." }
  - { item_id: "pocket-mirror", qty: 1, note: "A small mirror." }
  - { item_id: "climbing-rope-per-foot", qty: 30, note: "30 feet (9.1 m) of climbing rope." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - name: "Preacher of the Way of Chi"
    description: "The Yama Kings will only be driven off when enough people come to hate evil itself, not just its demons. The Wai Chia preaches to that end: to dispel the Mist that hides Rifts China from the Jade Emperor''s Celestial Court, to show that the way of the empty hand can prevail even against the demons of the Ten Hells, and to stand with the innocent, the helpless, children and the elderly against any oppressor, human or demon."
  - name: "Hand to Hand: Xian Tai Chi Chuan (Immortal and Eternal, Mind and Body)"
    description: "The order''s single combined study of physical martial arts, mystic martial arts and chi manipulation, taken in place of Hand to Hand: Basic Tai Chi. Level 1: four attacks per melee round, +3 to roll with punch, fall or impact, +2 to dodge; Grab & Throw (1D4 damage; the victim loses initiative and its next melee attack/action); Open Hand Push (1D4 damage; the victim loses initiative and its next two melee attacks/actions). Level 4: Critical Strike on a natural 19 or 20. Level 9: Knockout/Stun on a natural 19 or 20. Level 13: Critical Strike on a natural 17 or better. Every numeric bonus of the table (levels 1-15) is in the class bonuses."
  - { choose: 1, from: ["Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"], note: "Granted outright (printed 52); the pick only puts its level table on the sheet." }
  - name: "Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"
    description: "Level 1: Chi Ball. Four full melee rounds (one minute) to evoke, then each melee round of gathering adds 1D4 I.S.P. to it, with no maximum but too hard to control past the character''s base I.S.P.; the amount gathered is held as long as the kata continues. Held in the hand and used to strike, it is harmless to mortals, living creatures, devices, machines and robots, but against demons, disembodied entities and other creatures of supernatural evil it does 1D6 M.D. per 10 I.S.P. stored (1D6x10 M.D. at 100). (printed 40-41.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Chi Ball Lens: for 3 I.S.P., looking through the Ball shows all I.S.P., Chi-bearing creatures, dragon lines and supernatural or spiritual entities within about 60 ft (18.3 m), for as long as the character keeps looking through an intact Ball." }
      - { level: 4, text: "Meditation Advancement #1: +2 to I.Q., M.E. and M.A." }
      - { level: 5, text: "Chi Ball Defense: for 4 I.S.P. the Ball is a shield against psychic, magical, spiritual and demonic energies, with M.D.C. equal to the I.S.P. stored in it; useless against physical weapons, bullets, lasers and non-magical energy blasts." }
      - { level: 6, text: "Evoke the Chi Ball in one melee round." }
      - { level: 7, text: "Chi Ball Calm: for 2 I.S.P., +5 to save vs Horror Factor and other fear while holding the Ball." }
      - { level: 8, text: "Add 5D6+30 to the character''s Permanent I.S.P. Base." }
      - { level: 9, text: "Meditation Advancement #2: +1 to M.A. and +2 to save vs Horror Factor." }
      - { level: 10, text: "Second Chi Ball Formation: two Chi Balls can be created at once." }
      - { level: 11, text: "Chi Ball Levitation: for 10 I.S.P. the character rises with the Ball, holding it or standing on it, to a maximum height of 500 ft (152 m) per level." }
      - { level: 12, text: "Add 4D6+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Throwing the Chi Ball: for 10 I.S.P. a throw, the Ball arcs through a target and returns; against demons and creatures of supernatural evil it does 2D8 M.D. on a glancing blow and 5D10 M.D. on a solid hit, and is harmless to anything else. +2 to strike; range 100 ft (30.5 m) per level." }
      - { level: 14, text: "Meditation Advancement #3: +1 to M.E. and M.A., +2 to save vs disease and +2 to save vs Horror Factor." }
      - { level: 15, text: "Impervious to mental illusions while holding the Chi Ball, and +5 to save vs magical illusions." }
  - name: "Chi Healing"
    description: "Using internal energy alone or the Chi Ball. Laying on hands without the Chi Ball heals 2D6 S.D.C./hit points, or 1D6 M.D.C. on a superhuman creature, for 6 I.S.P. per healing per individual. Passing the Chi Ball over or through the injured or ill heals 4D6 S.D.C./hit points, or 2D6 M.D.C. (living flesh only), for 3 I.S.P. per healing per individual. Illness, infection and chronic disease: lay hands on the patient for at least 12 melee rounds (3 minutes); once the problem is identified (usually by the patient''s aura coloring) the chance of a cure is 22% +2% per level, for 30 I.S.P. per attempt per individual."
  - name: "Powers of Meditation"
    description: "From an early age the character has focused all inner strength into meditation, contemplation and sensitivity to the stirring of chi, which gives the Xian Tai Chi Chuan mystic martial arts abilities and a handful of psychic abilities. Highly skilled in Meditation."
level_progression:
  - { level: 2, grants: ["+2 to parry and dodge"] }
  - { level: 3, grants: ["+2 to strike, +2 to roll with punch/fall/impact", "+1 to save vs possession and Demonic Curses"] }
  - { level: 4, grants: ["+1 to parry and dodge, Critical Strike on a natural 19 or 20", "+1 on initiative", "+1 to save vs possession and Demonic Curses"] }
  - { level: 5, grants: ["+1 attack/action per melee round", "+1 to save vs possession and Demonic Curses"] }
  - { level: 6, grants: ["+2 to roll with punch/fall/impact, +1 to parry and dodge, +1 to disarm"] }
  - { level: 7, grants: ["+1 to strike and +2 to damage", "+1 to save vs possession and Demonic Curses"] }
  - { level: 8, grants: ["+1 attack/action per melee round", "+1 on initiative"] }
  - { level: 9, grants: ["Knockout/Stun on a natural 19 or 20", "+1 to save vs possession and Demonic Curses"] }
  - { level: 10, grants: ["+1 attack/action per melee round"] }
  - { level: 11, grants: ["+1 to strike and +2 to damage", "+1 to save vs possession and Demonic Curses"] }
  - { level: 12, grants: ["+1 to roll with punch/fall/impact, +1 to parry and dodge", "+1 on initiative"] }
  - { level: 13, grants: ["+2 to disarm, +2 to entangle, Critical Strike on a natural 17 or better", "+1 to save vs possession and Demonic Curses"] }
  - { level: 14, grants: ["+1 attack/action per melee round"] }
  - { level: 15, grants: ["+2 to strike and +4 to damage", "+1 to save vs possession and Demonic Curses"] }
restrictions:
  - "Never learns any Weapon Proficiency, nor any martial art that promotes the use of weapons."
  - "Carries no weapons, and no mechanical or electronic devices of any kind."
  - "Cybernetics: none, and will never accept any for any reason. 01-55% chance to refuse even Bio-Systems."
trackable_resources: []
extraction_notes: "Rifts World Book 25: China 2 printed 52-54 (cache p053-p055, scan, page_offset +1), read off 200 dpi renders. The section heading is Mystic Monks (printed 52), so occ_group is psychic per the China 2 brief; the class states its own S.D.C. (4D6+38), so no men_of_arms line. The book subtitles it Open Hand Martial Artist, also known as Monk of the Elder Path. XP ladder: printed 160 (cache p161), the block headed Monk: Wai Chia Wu Shih / Warrior: Chun Tzu, read off a render. Hand to hand: the class takes the combined Hand to Hand: Xian Tai Chi Chuan in place of Hand to Hand: Basic Tai Chi (printed 53). The catalog holds no row for it, so it is stored as the class''s own: its four starting attacks as combat attacks_base, every numeric bonus of its table in bonuses and at_level, and its moves and critical/knockout ranges in a special ability and level_progression. No style is granted and none is sold (hand_to_hand costs {}), because the book allows no other martial art. Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation) is granted at level 1; its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Psionics: the book does not name a tier; printed 55 says most martial arts masters are Minor Psychics unless stated otherwise, so minor. Levitation is granted; three Healing and three Physical are picked. The book prints no new powers at later levels. O.C.C. bonuses (printed 53): +4 M.E., +2 M.A., +2 P.P., +1 strike, +4 pull punch, +3 save vs magic (stored as spell_magic only), +4 vs Horror Factor, +1 initiative at levels 4, 8 and 12, +1 save vs possession and Demonic Curses (curses) at levels 1, 3, 4, 5, 7, 9, 11, 13 and 15. Skills: Language: Native Chinese Speaker (95%) is Language: Native Tongue at 95 with no per-level gain; Literacy: Chinese characters (90%) is Literacy: Chinese at 90 keeping the catalog''s +5 per level; the book''s Litercy: Ancient & Classical Chinese in the Lore list is the Literacy row; Aerobic Athletics or General Athletics are both offered, General as Athletics (general). Related: Medical is two entries so the +10% reaches only Acupuncture and Chinese Herbal Medicine; Technical''s +5% is stored, and its +10% (printed 54, read off a render) reaches every Lore: row through a second, scoped Technical entry (BOOK-INGEST-AUDIT F138), the History half not stored; Rogue names Pick Locks, an Espionage skill, so Espionage carries only Pick Locks; Gambling is both catalog Gambling rows; Pilot''s other very basic vehicles have no row. The secondary list repeats the related limits without bonuses. Equipment: herbs (tea, flavoring, emergency medicine), two sets of chopsticks, 20 cups of uncooked rice and a small neck pouch have no catalog row and are in the Lore. The silk suit is dress-clothing with its parts in the note. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 52 (cache p053), read off a render. Ability 2 (Combined Hand to Hand Martial Art, Martial Art Power, and Sense and Manipulate Chi) says the combined study gives the character the Mystic Martial Art Power Xian Tai Chi Chuan (Chi Manipulation) and, in place of Hand to Hand: Basic Tai Chi, the class''s own Hand to Hand: Xian Tai Chi Chuan table; there is no choice and no later pick. The power was a plain definition, which the sheet does not show; it now sits in a one-option choose-1 group so that it is held and its level table appears."
---

## Lore

The Wai Chia Wu Shih believe that picking up any weapon, for any reason, is weakness and a surrender to the barbarism the unjust Yama Kings brought into the world. When a fight cannot be avoided, the human body is the only weapon a civilized person should need, so these monks never learn a weapon proficiency and never study a fighting art built around arms.

They are deeply suspicious of anything new. The great innovations, rice, writing and silk, have proved themselves over thousands of years; the endless stream of gadgets that followed is, in their view, what ruined the world long before the Rifts. China fell, they say, when its temples and monasteries were destroyed and its Taoists and mystics scorned; had it stayed righteous there would be no Mist and no opening for the Yama Kings.

So the Wai Chia grumbles. Rifts China is full of new weapons from the outside world, from the Geofront and from mad Yama Kings, and the monk looks back on centuries of golden ages with little hope that the Celestial Court will ever restore them. Yet he keeps at it, determined to show by example that a single human being with nothing but bare hands can right wrongs, defeat evil and change the world.

To the Wai Chia the separation of physical martial arts, mystic martial arts and chi manipulation is blindness. The order fuses all three into one study, Immortal and Eternal, Mind and Body, and its monks are healers as much as fighters, laying hands on the sick or passing a ball of gathered chi through the wounded.

Standard equipment: sturdy traveling clothes with boots, hat and gloves and heavy winter over-garments; a suit of embroidered silk indoor clothing with slippers, robe, scarf and hat; 2D4x10 sheets of paper, solid ink and an ink block, bamboo brushes; several packages of tea and a collection of herbs for tea, cooking and emergency medicine; a tea bottle, a kettle, two sets of chopsticks (one rough, one delicate), a cooking knife and 20 cups of uncooked rice; a large shoulder bag, a belt pouch, a small neck pouch, a small mirror, 30 feet of climbing rope and two bamboo canteens of water. Never weapons, and never anything mechanical or electronic.
',
       updated_at = datetime('now')
 WHERE class_id = 'wai-chia-wu-shih'
   AND instr(markdown, 'Technical''s +10% to Lore and History skills is in the note') > 0
   AND length(markdown) = 20126;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'spacer' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'naruni-repo-bot' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'yamabushi-mountain-priest' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'demon-queller' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'african-witch' AND instr(markdown, '- { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'fu-yao-da-chia' AND instr(markdown, '- { name: "Technical", only_prefix: ["Lore:"], bonus: 15 }') > 0)
    OR (class_id = 'wai-chia-wu-shih' AND instr(markdown, '- { name: "Technical", only_prefix: ["Lore:"], bonus: 10 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'spacer' AND instr(markdown, 'TWO PRINTED BONUSES ARE NOT CATEGORY BONUSES AND ARE NOT STORED') > 0)
    OR (class_id = 'naruni-repo-bot' AND instr(markdown, 'a bonus on two skills rather than on the category, so no category bonus is stored') > 0)
    OR (class_id = 'yamabushi-mountain-priest' AND instr(markdown, '{ name: "Technical", note: "Any; +10% to language skills only, so no category bonus is stored." }') > 0)
    OR (class_id = 'demon-queller' AND instr(markdown, '{ name: "Technical", note: "Any; +10% to language skills only, so no category bonus is stored." }') > 0)
    OR (class_id = 'african-witch' AND instr(markdown, '{ name: "Technical", note: "+10% on lore, literacy, language or writing skills only." }') > 0)
    OR (class_id = 'fu-yao-da-chia' AND instr(markdown, 'Mythology and Lore skills only, so no category bonus is stored.') > 0)
    OR (class_id = 'wai-chia-wu-shih' AND instr(markdown, 'Technical''s +10% to Lore and History skills is in the note') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('spacer', 'naruni-repo-bot', 'yamabushi-mountain-priest', 'demon-queller', 'african-witch', 'fu-yao-da-chia', 'wai-chia-wu-shih') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~241-book-ingest-audit-f138-sweep-a.sql');
