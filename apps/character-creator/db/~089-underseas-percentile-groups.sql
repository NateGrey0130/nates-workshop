-- Seven Underseas classes turn a creation-time percentile table from prose into
-- a banded pick-one ability group, so the wizard's Roll d100 button can roll it.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
-- Rifts World Book 7: Underseas was imported before pick-one ability groups
-- carried percentile bands (PR #1602, 2026-10-01). Each class below either said
-- its table "is rolled, not granted" and stored nothing, or - the dolphin, the
-- killer whale and the sperm whale - never mentioned its psionics table at all.
--
--   amphib           Appearance, printed 99: seven rows. Each option carries the
--                    row's S.D.C. bonus; its P.B. dice and swimming speed stay
--                    in the option's description, because an ability can add a
--                    bonus and cannot replace an attribute's dice.
--   sea-titan        Psionics, printed 114: 01-18 major, 19-50 minor, 51-97
--                    none, 98-00 master, with the printed I.S.P. additions.
--   nautyll-soldier  Psionics, printed 149: 01-10 minor, 11-24 major, 25-30
--                    master, 31-50 mystic. The page stops at 50; 51-00 is None,
--                    and the option says so. The class cited printed 148; the
--                    line is at the top of 149.
--   dolphin          Psionics, printed 80: 01-77 none, 78-88 minor, 89-97 major,
--                    98-00 master.
--   killer-whale     Psionics, printed 88: the same bands; the minor row draws
--                    on Physical where the dolphin's draws on Healing.
--   sperm-whale      Psionics, printed 90: four tiers, every one psionic, each
--                    with its own I.S.P. formula and fixed powers.
--   humpback-whale   Psionics, printed 92: 01-90 minor, 91-00 major.
--
-- EVERY FIGURE WAS READ OFF A RENDER. Each draft reads `ready` in
-- class-check --remote with 0 errors and 0 warnings, and abilityRollBands()
-- returns bands for every group. A count the book prints as dice (1D4+1
-- powers) is stored at its maximum with the roll in the pick's note, as
-- demon-and-dead-slaver stores it.
--
-- NOT HERE, on purpose:
--   nautyll-devastator: its own page (printed 150) prints a different
--     breakdown (30% mystics, 20% major, 10% Mind Melter ...) that the racial
--     roll's 50% "none" contradicts. Left as it is.
--   nautyll-koral-shaper: it already stores a real class-level grant, which
--     its own page prints. Two of its sentences say no block is stored and are
--     false today; that is a wording fix for another script.
--   The Pneuma-Biform dolphin and killer whale defer to these tables in prose
--     and still have no roll of their own.
--
-- Each UPDATE replaces the whole markdown and is guarded twice: on a sentence
-- the old text holds (or on the absence of a special_abilities block), and on
-- the old text's exact length. Production held no character on any of the
-- seven on 2026-10-03. THIS SCRIPT CHANGES PRODUCTION: seven class rows. The
-- tilde number is claimed at merge.

-- == amphib ==
UPDATE imported_classes
   SET markdown = '---
id: amphib
name: Amphib
system: rifts
source_book: Rifts World Book 7: Underseas p.98-100
category: rcc
tags: [aquatic]
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "4d6"
  PS: "3d6+12"
  PP: "4d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. x2, +1d6 per level"
sdc_base: "3d6x10"
ppe_base: "3d6"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  combat: { dodge: 2, roll: 1, pull_punch: 1 }
restrictions:
  - "Alignment: any, but most tend to good or selfish alignments."
  - "SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. Printed 100 has the player select either the Sea Wolf or the Tritonian Scientist O.C.C., or any other appropriate O.C.C. at the G.M.''s call including a magic O.C.C., and then REDUCE the number of available O.C.C. skills by three. The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a). Pick a second class by hand and drop three of its O.C.C. skills."
  - "Experience: use the Amphib table or the chosen O.C.C.''s table, whichever is HIGHER."
  - "THE STORED COMBAT BONUSES ARE ALL UNDERWATER-ONLY. Printed 100 gives +2 to dodge and +1 to roll with impact and pull punch underwater, and nothing on land. They are stored unconditionally because an amphib is an aquatic character and the sheet has no conditional slot - but a G.M. running an amphib on dry land should ignore all three."
  - "P.B. AND SWIMMING SPEED ARE ROLLED ON AN APPEARANCE TABLE: roll or pick the Appearance ability, whose seven options are the seven rows. The stored P.B. dice are the first row''s 3D6; a row that prints other dice says so, and P.B. is re-rolled on them by hand. Spd 3D6 is the LAND speed; underwater it is 6D6 plus the row''s swimming bonus, which is on the option and is not totalled by the sheet."
  - "S.D.C. is 3D6x10 plus skill, O.C.C. and appearance bonuses. The appearance bonus alone runs from nothing to 2D4x10."
  - "M.D.C.: by armour or magic only. The amphib is an S.D.C. creature."
  - "Horror Factor: 8, and only for those not used to the more unusual specimens."
  - "P.P.E. is 3D6 unless the character takes a magic O.C.C., whose own P.P.E. then applies (printed 99; yields_to_occupation, BOOK-INGEST-AUDIT F111)."
  - "Average life span: 90 years."
  - "Psionics: normal, the same as a human''s. No psionic block is granted."
  - "Magic: only if a magic O.C.C. is selected."
  - "There are over 100,000 amphibs living in the floating city of Tritonia."
special_abilities:
  - { choose: 1, from: ["Appearance (01-20): Perfect Human", "Appearance (21-40): Webbed Hands and Feet", "Appearance (41-60): Frog Skin", "Appearance (61-70): Fish Face", "Appearance (71-80): Scaly Skin", "Appearance (81-90): Scaly Skin and Fish Face", "Appearance (91-00): Oversized, Fish or Frog-Like"], note: "Appearance table (printed 99): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Appearance (01-20): Perfect Human"
    description: "Printed 99, roll 01-20. Looks entirely human, with no visible aquatic feature. P.B. is rolled on 3D6, which is what the sheet rolls. No underwater speed bonus and no S.D.C. bonus. Holds its breath rather than breathing water."
  - name: "Appearance (21-40): Webbed Hands and Feet"
    description: "Printed 99, roll 21-40. Flat webbed feet and webbing between the fingers; shoes and armoured footwear must be custom-made. Underwater speed +3D6, and +10 more when swimming with little or no clothing. P.B. is 3D4: re-roll it by hand, the sheet rolls 3D6. No S.D.C. bonus. About 40% have gills as well as lungs; the other 60% hold their breath for inhumanly long periods."
  - name: "Appearance (41-60): Frog Skin"
    description: "Printed 99, roll 41-60. Hairless, with unnaturally smooth, slick skin that is usually greenish-grey. Swimming speed +2D6, and +6 more with little or no clothing. P.B. is 2D6: re-roll it by hand, the sheet rolls 3D6. Holds its breath. Applied: +4D6 S.D.C."
    bonuses: { pools: { sdc: "4d6" } }
  - name: "Appearance (61-70): Fish Face"
    description: "Printed 99, roll 61-70. A fish-shaped head with large, round, dark eyes and a wide mouth; the head may be finely scaled while the body keeps ordinary skin. Helmets and headgear must be custom-made. Swimming speed +2D6, and +8 more with little or no clothing. P.B. is 2D4: re-roll it by hand, the sheet rolls 3D6. Breathes air and has gills for water. Applied: +3D6 S.D.C."
    bonuses: { pools: { sdc: "3d6" } }
  - name: "Appearance (71-80): Scaly Skin"
    description: "Printed 99, roll 71-80. Hairless and covered in scales. Swimming speed +2D6, and +8 more with little or no clothing. P.B. is 2D6: re-roll it by hand, the sheet rolls 3D6. Breathes air and has gills for water. Applied: +5D6 S.D.C."
    bonuses: { pools: { sdc: "5d6" } }
  - name: "Appearance (81-90): Scaly Skin and Fish Face"
    description: "Printed 99, roll 81-90. Hairless, fish-scaled, with webbed hands and feet and the head of a fish on an otherwise humanoid body. Swimming speed +4D6, and +10 more with little or no clothing. P.B. is 1D6: re-roll it by hand, the sheet rolls 3D6. Breathes air and has gills for water. Applied: +6D6 S.D.C."
    bonuses: { pools: { sdc: "6d6" } }
  - name: "Appearance (91-00): Oversized, Fish or Frog-Like"
    description: "Printed 99, roll 91-00. More frog or fish than human, and big: 8 feet (2.4 m) plus 4D6 inches tall, and 300 lbs (136 kg) plus 2D6x10 lbs. Swimming speed +4D6, and +20 more with little or no clothing. P.B. is 1D6: re-roll it by hand, the sheet rolls 3D6. The row prints no breathing line. Applied: +2D4x10 S.D.C."
    bonuses: { pools: { sdc: "2d4x10" } }
natural_abilities:
  - name: "Appearance"
    description: "Rolled on a percentile table at creation (printed 99), from 01-20 Perfect Human to 91-00 Oversized. Each of the seven rows sets the P.B. dice, an underwater speed bonus, an S.D.C. bonus and whether the amphib has gills. Roll or pick the row under the Appearance choice; each row''s figures are on its own entry there. Shoes, headgear and armour need custom fitting for most of these, and Tritonia has facilities for exactly that."
  - name: "Breathe Underwater"
    description: "A human-looking or frog-like amphib holds its breath for 5D6x3 minutes and must eventually surface, like a dolphin; using any artificial breathing apparatus it consumes less oxygen, effectively doubling the air and the time. A scaly, fish-like amphib has both lungs and gills and stays under indefinitely."
  - name: "Nightvision"
    description: "Excellent vision, seeing clearly in the near-total absence of light to 200 feet (61 m)."
  - name: "Resistant to Cold"
    description: "Survives indefinitely at freezing or near-freezing temperatures and takes half damage from cold-based attacks."
  - name: "Depth Tolerance"
    description: "Endures pressure at one mile (1.6 km) plus 300 feet (91.5 m) per level of experience without ill effect, and never gets the bends."
  - name: "Acute Underwater Senses"
    description: "Taste, hearing and smell are about four times as acute as a human''s underwater, letting the amphib taste or smell blood, death and decay, and foreign chemicals in the water at roughly 1000 yards/metres plus 100 per level of experience."
  - name: "Natural Combat"
    description: "As a human''s, depending on training. A restrained punch does 1D6 S.D.C. plus P.S. bonus, a full strength punch 3D6 S.D.C. plus P.S. bonus, and a power punch 1D4 M.D. counting as two attacks - the one mega-damage attack an otherwise S.D.C. race has."
extraction_notes: |
  - Underseas, printed 98-100. A race rather than an occupation: the product
    of pre-Rifts genetic experiments crossing humans with frogs and fish, of
    which 90% of the strains were crippling or lethal and the surviving 10%
    bred true.
  - ITS SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. This is the SECOND
    Underseas class to hit BOOK-INGEST-AUDIT.md F23(a), after the Sea
    Inquisitor, and it is the harder of the two: printed 100 does not merely
    borrow a list, it borrows one AND REDUCES IT BY THREE. There is no key for
    "use that class''s list" and none for "minus three from it". Added to
    F23(a)''s affected rows rather than filed as a new finding, per the batch
    rule. A character built from this row alone has no skills at all, which is
    the book''s shape rather than a dropped count.
  - THE STORED COMBAT BONUSES ARE UNDERWATER-ONLY AND ARE STORED ANYWAY. This
    is a deliberate exception to the rule that a conditional bonus is prose.
    Every other conditional in this book - a speed burst, a combat form, a
    bonus against supernatural beings - is a temporary state. Being underwater
    is this race''s normal condition, and a character sheet showing an amphib
    with no bonuses at all would be wrong more often than it was right. The
    condition is stated plainly in the restrictions.
  - THE APPEARANCE TABLE IS A CHOOSE-1 SPECIAL ABILITY WITH SEVEN BANDED
    OPTIONS, one per row of printed 99, each named for its band so the wizard
    can roll it. A row''s S.D.C. bonus is the option''s `bonuses.pools.sdc` and is
    applied. Its P.B. dice and its swimming-speed bonus are in the option''s
    description and are NOT applied: the table sets P.B. on 3D6, 3D4, 2D6, 2D4,
    2D6, 1D6 and 1D6, `attribute_dice` holds the first row''s 3D6, and an
    ability adds to an attribute rather than replacing its dice; swimming speed
    has no attribute of its own. NOT modelled as `variants`: a variant replaces
    a block, and this is a roll rather than a choice.
  - ALL SEVEN APPEARANCE ROWS ARE PRESENT AND ARE TRANSCRIBED. A first draft of
    this class claimed the table skipped 41-70 and called it OCR loss. THAT WAS
    WRONG, and it was wrong because the page was read through too short a
    window rather than because the cache was damaged: rows 41-60 (Frog Skin)
    and 61-70 (Fish Face) sit exactly where they should on printed 99. The same
    short read also conflated row 21-40 with row 61-70, giving the webbed-feet
    result the fish-face numbers. Both were caught by going back to the page
    before shipping. The table covers 01-00 with no gap.
  - SPD IS THE LAND SPEED of 3D6. Underwater it is 6D6 plus the appearance
    bonus, which can be another 4D6+20.
  - IT HAS ONE MEGA-DAMAGE ATTACK AND IS OTHERWISE AN S.D.C. RACE: the power
    punch does 1D4 M.D. `mdc_base` is absent and `sdc_base` is used, per
    printed 99, which says M.D.C. is by armour or magic only.
---

# Amphib

## Lore

The amphib race is the product of illegal genetic experiments dating from before the Coming of the Rifts - humans crossed with frogs and fish by scientists who wanted beings that looked entirely human and could breathe and swim underwater without equipment.

The mutations were unstable. Ninety percent of the strains were crippling or lethal, and hundreds of volunteers died horribly. When the atrocities became public the project was shut down and those responsible were punished for crimes against humanity.

That left the surviving ten percent: highly capable undersea creatures with superior strength, resistance to pressure and the ability to breathe both air and water. Most were humanoid, many were not human-looking, and most could reproduce - which meant mankind had accidentally created a new race. Under public scrutiny the government made them heroes rather than an embarrassment, and assigned them to the Tritonia project to explore and harness the last great wilderness on Earth.

## GM Notes

Over the centuries the amphibs have prospered on Tritonia, where more than a hundred thousand of them live. They get on with most intelligent creatures, have strong ties to Tritonia''s naut''yll community, and have a special relationship with dolphins - who regard them as friends and playmates closer than humans, able to swim alongside them while keeping the best human traits. Some dolphins and amphibs insist they are kindred spirits and children of the sea, and the two are often sent out together on exploration and rescue.

Because most amphibs need no breathing equipment and endure great depths, they take the jobs that require it: deep sea diving, underwater construction and exploration. Many join the Sea Wolves as scouts, others become scientists, marine biologists and researchers, and a few learn water magic from dolphins, whale singers and other aquatic races.
',
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, 'Rolled on a percentile table, and it changes real numbers.') > 0
   AND length(markdown) = 9883;

-- == sea-titan ==
UPDATE imported_classes
   SET markdown = '---
id: sea-titan
name: Sea Titan
system: rifts
source_book: Rifts World Book 7: Underseas p.113-115
category: rcc
tags: [combat, aquatic]
xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6+12"
  PP: "3d6+6"
  PE: "4d6+4"
  PB: "3d6+1"
  Spd: "6d6"
mdc_base: "2d4x10"
ppe_base: "6d6"
bonuses:
  combat: { initiative: 1 }
  saves: { spell_magic: 3, ritual_magic: 3 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 45, per_level: 5, note: "+5%" }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Printed as Demon and Monster Lore (identification only) (+15%). The identification-only limit is not modelled." }
    - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
    - { name: "Robots & Power Armor", base: 56, per_level: 3, note: "Printed as Pilot: Robots and Power Armor, with no bonus." }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Pilot: two of choice (+10%)." }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Printed as Read Sensory Equipment (+10%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Printed as Language & Literacy: American at 98%. This row is the spoken half." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The written half of the same line. This catalog separates speaking a language from reading it, so one printed line is two rows." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One other language of choice (+10%)." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "Printed as W.P. Heavy." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to martial arts, or assassin if evil, for one other skill selection." }
  occ_related_skills:
    count: 8
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }, { level: 18, count: 1 }, { level: 21, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - "Electrical"
      - { name: "Espionage", bonus: 5 }
      - "Mechanical"
      - { name: "Medical", only: ["Paramedic", "First Aid"], bonus: 5 }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "No category is barred. THE SCHEDULE RUNS TO LEVEL 21, further than any other class in this book - Sea Titans do not appear to age and the ladder is written for a character who plays for centuries."
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 4 }, { level: 10, count: 2 }, { level: 13, count: 2 }, { level: 16, count: 2 }, { level: 19, count: 2 }, { level: 21, count: 2 }, { level: 24, count: 2 }]
    note: "Four at first level and four more at level four, then two each at levels 10, 13, 16, 19, 21 and 24."
restrictions:
  - "THE SUPERHUMAN ABILITIES DO NOT APPEAR UNTIL THE CHARACTER''S TEENS - age 13+1D6. Before that a Sea Titan child is an ordinary human in perfect health, immune to disease and most toxins, with S.D.C. equal to their P.E. plus 1D4x10 and any physical skill bonuses. They must breathe, eat, learn, play and grow like any other child, and they become mega-damage beings with supernatural strength at the end of puberty, usually between 16 and 18 and occasionally as early as 14 or as late as 20. The stored attributes and M.D.C. are the ADULT figures."
  - "ALL PHYSICAL ATTRIBUTES ARE SUPERNATURAL, once they manifest."
  - "Size: as a normal human. Sea Titan is a name and a position in the New Navy - these characters have no kinship with the mythical Titans."
  - "M.D.C. gains 2D6 per level of experience on top of the stored base. Once a mega-damage being, hit points and S.D.C. no longer apply."
  - "Horror Factor: 9, and only for people who did not expect a human-looking character to have supernatural powers."
  - "Average life span: UNKNOWN. Sea Titans have not aged noticeably in almost 300 years. Nobody, themselves included, knows how long they may live; the book suggests a godling''s span of up to 100,000 years is more likely than true immortality. They can still be injured, slain or driven insane."
  - "Speed 6D6 is the LAND speed; underwater it is half that."
  - "PSIONICS ARE TWICE AS LIKELY as for a human and are rolled rather than granted: 01-18 major psionic, 19-50 minor, 51-97 none, 98-00 master. Add 1D4x10 to base I.S.P. for a minor or major psionic, or 1D4x10+10 for a master. Roll or pick the Psionics ability, which carries the tier; no class-level psionics block is stored, because 47% have none."
  - "Magic: none. Only the occasional older Sea Titan who has left to explore the world studies it."
  - "VULNERABILITIES: magic and psionics do FULL damage, and some rune weapons do DOUBLE. In general any magic weapon that does double damage to supernatural beings does the same here. Their presence can also be sensed by any spell, psionic power or ability that detects supernatural beings."
  - "CYBERNETICS ARE IMPOSSIBLE, not merely avoided: their regeneration expels every implant."
  - "Experience: use the same tables as the young and ancient dragon."
  - "A Sea Titan over 250 years old may take a SECOND O.C.C. All previous skills then stop advancing, no secondary skills come with the new class, and every new O.C.C. and related skill needs double the usual experience - so the second O.C.C. rarely passes 5th level. Not modelled; see BOOK-INGEST-AUDIT.md F23(a)."
  - "Average experience level: a Sea Titan of 200 years or more is typically 1D6+7th level; 50 to 190 years averages 1D6+4; under 50 is 1D4+1."
  - "Money: 4D6x100 in credits to start, plus a salary of 2000 credits a month, doubled for officers."
equipment_starting:
  - { item_id: "marine-combat-armor", qty: 1 }
  - { item_id: "m-2011-pistol", qty: 1 }
  - { item_id: "m-160-assault-rifle", qty: 1 }
  - { item_id: "fragmentation-grenade", qty: 4 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
starting_money: "4d6x100"
special_abilities:
  - { choose: 1, from: ["Psionics (01-18): Major Psionic", "Psionics (19-50): Minor Psionic", "Psionics (51-97): None", "Psionics (98-00): Master Psionic"], note: "Psionic Powers (printed 114): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-18): Major Psionic"
    description: "Roll 01-18. A major psionic. Printed 114 prints no powers and no base I.S.P. formula for the tier, so record both by hand from the psionics rules in use. Add 1D4x10 to that base I.S.P.; the addition is stored as an I.S.P. pool bonus and only reaches the sheet once a base is recorded."
    psionics: { type: "major" }
    bonuses: { pools: { isp: "1d4x10" } }
  - name: "Psionics (19-50): Minor Psionic"
    description: "Roll 19-50. A minor psionic. Printed 114 prints no powers and no base I.S.P. formula for the tier, so record both by hand from the psionics rules in use. Add 1D4x10 to that base I.S.P.; the addition is stored as an I.S.P. pool bonus and only reaches the sheet once a base is recorded."
    psionics: { type: "minor" }
    bonuses: { pools: { isp: "1d4x10" } }
  - name: "Psionics (51-97): None"
    description: "Roll 51-97. No psionic powers and no I.S.P."
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. The rare master psionic. Printed 114 prints no powers and no base I.S.P. formula for the tier, so record both by hand from the psionics rules in use. Add 1D4x10+10 to that base I.S.P.; the addition is stored as an I.S.P. pool bonus and only reaches the sheet once a base is recorded."
    psionics: { type: "master" }
    bonuses: { pools: { isp: "1d4x10+10" } }
natural_abilities:
  - name: "Mega-Damage Being"
    description: "P.E. plus 2D4x10 M.D.C., gaining 2D6 per level. Becomes mega-damage at some point in the teens, at age 13+1D6."
  - name: "Needs No Air, Food or Water"
    description: "Does not need to breathe, drink or eat to survive, which is what lets a Sea Titan work and fight underwater without difficulty."
  - name: "Immune to Poison"
    description: "Immune to all normal, non-supernatural poisons and toxins."
  - name: "Supernatural Strength and Endurance"
    description: "All physical attributes are supernatural; bare hands inflict mega-damage. See Rifts Conversion Book One page 22."
  - name: "Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per minute - four melee rounds - and regrows lost limbs and organs in 4D6 hours. It is also why cybernetics are impossible: the body expels them."
  - name: "Depth Tolerance"
    description: "Survives ocean depths to 4000 feet (1220 m) with no armour or equipment."
  - name: "Apparent Immortality"
    description: "The original 22 crew members have not aged noticeably in over 250 years, and every Sea Titan passes the full set of abilities and the apparent immortality to their children - even when the other parent is an ordinary human."
extraction_notes: |
  - Underseas, printed 113-115. The original Sea Titans were the 22 crew
    members transformed by transdimensional energies; their descendants inherit
    the whole package, which has made them very popular spouses and the elite of
    the New Navy.
  - THE STORED NUMBERS ARE THE ADULT ONES, and the class is unusual in having a
    childhood the book gives real statistics for. Before age 13+1D6 a Sea Titan
    is an ordinary human with S.D.C. rather than M.D.C. `mdc_base` holds the
    adult figure and the childhood is a restriction line. NOT modelled as
    `variants`: it is an age gate rather than a choice, and the same reasoning
    that kept the Pneuma-Biform Whale''s species M.D.C. out of variants applies.
  - "LANGUAGE & LITERACY: AMERICAN AT 98%" IS TWO CATALOG ROWS, as on the
    Tritonian Scientist. Storing only the language would drop the literacy the
    book grants in the same breath.
  - ITS SCHEDULES RUN FURTHER THAN ANY OTHER CLASS IN THIS BOOK - related
    skills to level 21 and secondary skills to level 24. That is deliberate on
    the book''s part rather than a misprint: these characters do not age, and the
    entry names the dragon''s tables - two of them, young and ancient. Printed 214 also heads a column "Sea Titan, Whale Singer", and since 2026-09-26 xp_table carries that column (~014-underseas-xp-ladders.sql), the table that names this class.
  - THE SECOND-O.C.C. RULE IS F23(a) AGAIN, and this is its third appearance in
    this book after the Sea Inquisitor and the Amphib. A Sea Titan over 250 may
    take a whole second O.C.C. with its own frozen-progression rules. Added to
    F23(a)''s affected rows rather than filed separately.
  - NO CLASS-LEVEL PSIONICS BLOCK. Printed 114 rolls the tier - 47% have none -
    so the roll is a choose-1 special ability with four options named for their
    bands, and the tier travels with the option taken. The page prints no
    powers and no base I.S.P. for any tier, only the addition to it (1D4x10, or
    1D4x10+10 for a master), so each psychic option carries a bare tier and that
    addition as an I.S.P. pool bonus - the Momano Headhunter precedent.
  - "IDENTIFICATION ONLY" ON THE LORE SKILL is not modelled, as on the Marine.
---

# Sea Titan

## Lore

The original Sea Titans were twenty-two crew members transformed into mega-damage superhumans by strange transdimensional energies. The descendants of those sailors have inherited their parents'' powers and their apparent immortality - the surviving twenty-two have not visibly aged in over 250 years.

Every Sea Titan is a mega-damage being who seems to be immortal, has supernatural strength and endurance, resists poison and disease, does mega-damage bare-handed, and can survive four thousand feet down without armour or equipment. They can also live without breathing or eating, which is what lets them work and fight underwater indefinitely.

Strangest of all, they always pass the whole package to their offspring, even when the other parent is an ordinary human - and the children inherit all of it, with remarkable consistency. It has made Sea Titans very popular spouses.

## GM Notes

Children of Sea Titans look completely normal. The only differences are perfect health, immunity to disease and most toxins, and the S.D.C. of an athletic adult. They are not mega-damage beings as children; they must breathe, eat, learn, play and grow like anyone else, and they become superhuman only toward the end of puberty - usually between sixteen and eighteen, occasionally as early as fourteen or as late as twenty.

That late blooming matters. A Sea Titan who grew up ordinary understands ordinary humans and forms normal friendships and romances with them. One born superhuman might have regarded them as weak or alien.

Nobody knows how long they live. If truly immortal they could last millions of years, though a godling''s hundred thousand is more likely. They can still be injured, slain or driven insane - and magic and psionics do full damage to them, with some rune weapons doing double.
',
       updated_at = datetime('now')
 WHERE class_id = 'sea-titan'
   AND instr(markdown, 'No psionics block is stored, because 47% have none.') > 0
   AND length(markdown) = 11718;

-- == nautyll-soldier ==
UPDATE imported_classes
   SET markdown = '---
id: nautyll-soldier
name: Naut''Yll Soldier
system: rifts
source_book: Rifts World Book 7: Underseas p.148-150
category: rcc
tags: [combat, pilot, aquatic]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "4d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6+8"
  PP: "3d6"
  PE: "3d6+4"
  PB: "2d6"
  Spd: "3d4"
mdc_base: "1d4x10"
bonuses:
  combat: { attacks: 1, initiative: 2, strike: 1, parry: 1, dodge: 2, roll: 2, pull_punch: 2 }
  pools: { mdc: "1d4x10" }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Printed as Basic Math (+10%)." }
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Boat: Submersibles", base: 50, per_level: 4, note: "Printed as Pilot: Submersible (+10%)." }
    - { name: "Robots & Power Armor", base: 56, per_level: 3, note: "Printed as Pilot Robots and Power Armor, with no bonus." }
    - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Printed as Power Armor Combat: Elite, naming no model." }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. knife or sword, pick one." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two additional W.P.s of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to martial arts or assassin for one other skill selection." }
  occ_related_skills:
    count: 10
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["Paramedic"], bonus: 5 }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
    note: "Electrical, Mechanical and Wilderness are barred entirely."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 4 }, { level: 6, count: 2 }, { level: 12, count: 2 }]
    note: "NONE at first level: four arrive at level two, then two each at levels six and twelve."
restrictions:
  - "Alignment: any, but the naut''yll lean toward aberrant evil - about 50%."
  - "Size: 6 to 7 feet (1.8 to 2.1 m). Weight 150 to 300 lbs (67.5 to 135 kg). Average life span 120 Earth years."
  - "SUPERNATURAL STRENGTH AND ENDURANCE. A restrained punch does 3D6 S.D.C., a full strength punch 1D6 M.D., a power punch 2D6 M.D."
  - "M.D.C. gains 1D6 per level of experience on top of the stored base. The naut''yll became minor supernatural creatures on a P.P.E.-rich world and turn mega-damage on any planet with a high magical background."
  - "Horror Factor: 8, and 11 for naut''yll mages and mind melters."
  - "SPD IS THE LAND SPEED of 3D4, which is barely a walk. Underwater it is 6D6+10."
  - "THE COMBAT BONUSES ARE UNDERWATER-ONLY: +2 on initiative, +1 to strike and parry, +2 to dodge and to roll or pull a punch. Stored unconditionally, as on the Amphib, because the water is this race''s normal condition - a G.M. running a naut''yll on dry land should ignore them."
  - "WATER DEPENDENCY. A naut''yll survives out of water only while kept wet. After 12 hours out of it, even with drinking water, speed and skill performance drop 10%; after another 12, a further 20% with one attack per melee lost and all combat bonuses halved; each day after that costs 2D6 M.D.C. Double the damage and penalties in desert or savanna conditions. It dies of dehydration after about a week, or of thirst in 24 hours with no water at all. One or two hours'' bathing per 12 prevents the damage, and a water-filled suit keeps it well for weeks with no penalty."
  - "VULNERABLE TO MAGIC AS A SUPERNATURAL BEING: double damage from most rune and Millennium Tree weapons, from magical heat and fire, and from mega-damage plasma and fire. Cold-based magic does half damage. Psychic sensitives detect it easily."
  - "Depth tolerance is two miles (3.2 km), or 2.5 miles (4 km) in Korallyte armour. Every 200 feet beyond costs 1D6x10 M.D., again for every five minutes at that depth, and halves skills, speed, combat bonuses and attacks - the pain is terrible."
  - "Psionics are rolled, not granted (printed 149): 01-10 minor, 11-24 major, 25-30 master (a natural mind melter) and 31-50 mystics with both psionics and magic. The page prints nothing for 51-00, which is read as none. Roll or pick the Psionics ability, which carries the tier; no class-level psionics block is stored, because half of all naut''yll have none."
  - "Cybernetics: none. The naut''yll do not use them; their regeneration is why."
  - "Attribute requirements: P.S. and P.E. 12 or higher are strongly suggested but NOT an absolute requirement - any naut''yll with a fighting spirit can join the military. Stored as no minimum, because the book explicitly declines to make it one."
  - "O.C.C. ABILITIES: +1D4x10 M.D.C. on top of the racial base, and ONE ADDITIONAL ATTACK per melee round."
  - "Money: 1D6x1000 Naut''Yll credits, which are WORTHLESS to anyone else. An NPC officer may hold 3D6x1000 universal credits'' worth of human artifacts, gemstones or precious metal. No `starting_money` is stored, because the currency does not convert."
special_abilities:
  - { choose: 1, from: ["Psionics (01-10): Minor Psionic", "Psionics (11-24): Major Psionic", "Psionics (25-30): Master Psionic", "Psionics (31-50): Mystic", "Psionics (51-00): None"], note: "Naut''Yll Psionic Powers (printed 149): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-10): Minor Psionic"
    description: "Roll 01-10. A minor psionic. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "minor" }
  - name: "Psionics (11-24): Major Psionic"
    description: "Roll 11-24. A major psionic. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "major" }
  - name: "Psionics (25-30): Master Psionic"
    description: "Roll 25-30. A master psionic, which the page calls a natural mind melter. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "master" }
  - name: "Psionics (31-50): Mystic"
    description: "Roll 31-50. A mystic, with both psionic and magic abilities as the standard Mystic class gives them. Nothing is granted here: the page names no tier, no powers and no spells of its own, so take them from the Mystic class by hand. Magic is otherwise open to a naut''yll only through a magical class or this result."
  - name: "Psionics (51-00): None"
    description: "Roll 51-00. No psionic powers. The page prints bands only up to 50 and says nothing of the rest, which is read as none."
natural_abilities:
  - name: "Amphibious"
    description: "Breathes underwater and on dry land indefinitely, with no apparatus. Lungs and gills both, adapting equally to salt or fresh water."
  - name: "Nightvision"
    description: "Sees 300 feet (91.5 m) in near-total darkness."
  - name: "Excellent Hearing"
    description: "Equivalent to bionic hearing."
  - name: "Bio-Regeneration"
    description: "Regains 1D6 M.D.C. per six hours of rest or meditation. Regrows fingers, toes, webbing and nose tentacles in 1D6 weeks, and restores damaged internal organs in the same time. A hand or foot takes 2D4 months; an arm, leg or eye takes 4D4."
  - name: "Resistant to Cold"
    description: "Cold-based attacks do half damage and the naut''yll withstands freezing temperatures without difficulty."
  - name: "Taste and Smell Tentacles"
    description: "Three tentacle-like trunks where a human nose would be, each ending in three tiny tentacles carrying taste and smell receptors far more acute than a human''s. A naut''yll leans over its plate and lets the nine tentacles taste food before it eats."
  - name: "Buoyancy Bladders"
    description: "Internal air and water bladders control buoyancy, letting the naut''yll float to the surface or sink to the bottom at will. It swims in an undulating, snake-like fashion."
extraction_notes: |
  - THE NAUT''YLL RACIAL STAT BLOCK IS PRINTED 148 AND IS FOLDED INTO EACH OF
    THE THREE CLASSES rather than shipped as a fourth row. The Experience
    Tables on printed 214 name the Soldier, the Devastator and the Koral
    Shaper separately and give the bare race no ladder; printed 148 is a
    shared preamble - attributes, M.D.C., depth tolerance, water dependency,
    the amphibious abilities - that all three build on. Every one of them
    carries the same racial restrictions and natural abilities, deliberately,
    so a reader of one class never has to go and find the other page.
  - ITS COMBAT BONUSES ARE UNDERWATER-ONLY AND ARE STORED ANYWAY, the same
    exception made for the Amphib and for the same reason: the water is this
    race''s normal condition rather than a temporary state, and a sheet showing
    no bonuses at all would be wrong more often than right.
  - NO CLASS-LEVEL PSIONICS BLOCK. The racial block runs from printed 148 on
    to 149, and its Psionic Powers line - on 149 - rolls the tier and leaves
    half of all naut''yll with nothing. The roll is a choose-1 special ability
    with five options named for their bands. The page prints four bands, 01-10
    to 31-50, and stops; 51-00 is stored as None so the table has no hole. It
    prints no powers and no I.S.P. for any tier, so the three psychic options
    carry a bare tier (the Momano Headhunter precedent) and the Mystic option
    carries nothing.
  - SPD IS THE LAND SPEED, which for this race is 3D4 - barely a walk. The
    underwater speed of 6D6+10 is in the restrictions.
  - ITS ATTRIBUTE REQUIREMENT IS STORED AS NONE, deliberately. Printed 149
    says P.S. and P.E. of 12 or higher are strongly suggested but not an
    absolute requirement, and that any naut''yll with a fighting spirit can
    join. `attribute_minimums` would enforce what the book declines to.
  - ITS MONEY DOES NOT CONVERT. Printed 149 gives 1D6x1000 Naut''Yll credits
    and says outright they are worthless to anyone else, so `starting_money` -
    which the sheet treats as spendable credits - is left unset and the figure
    is a restriction line. The same is true of the Devastator and the Koral
    Shaper.
  - THE +1D4x10 M.D.C. FROM THE OCCUPATION is a `pools` bonus on top of the
    racial `mdc_base`, which is the shape a race-plus-occupation grant takes.
    The extra attack per melee is `attacks: 1`, a bonus on top of the hand to
    hand skill''s own count. It was stored as a starting number until
    2026-09-25, which worked only because a class''s was then added to the
    skill''s.
---

# Naut''Yll Soldier

## Lore

The naut''yll are taught from birth to feel contempt and hatred for every other intelligent life form. Their word for outsider or foreigner is *H''Keezh*, which also means enemy and evil. Every other species is considered inferior or fearsome, and meant to be used and conquered.

That is what the typical naut''yll grunt carries into the field. Raised in a warrior society, most are inspired by tales of heroism, honour and obedience - to great causes and to one''s leaders, even at the cost of one''s life. They value bravery and loyalty above everything and thrive on danger and the acquisition of military power, and it shows in a genuine love of military weapons, armour, vehicles, tactics and fighting skills. These troopers regard a favourite gun roughly the way a human regards a puppy or a sports car.

## GM Notes

A soldier''s duty is to defend the race against the H''Keezh and to build the naut''yll people''s power and reputation. They feel they are doing it when they raid a helpless human settlement or enslave or exterminate a band of kreel-lok or D-bee nomads: anything taken from the H''Keezh makes the empire stronger, and a dead or enslaved enemy is no longer a threat.

Small operations use squads of eight called warbands, which handle exploration, reconnaissance, intelligence, patrols, seek-and-destroy, sabotage, defence and special forces work. A war-tribe is 80 troops, a war-legion 800, a war-front 2400, a war-troop 4800, and a full corps 32,000.

They fight undersea with precision and structure, and are almost as good on dry land - except that a surface campaign needs water-filled environmental suits or ready access to water, exactly as a surface dweller needs air tanks and diving gear to come down.
',
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier'
   AND instr(markdown, '01-10% minor, 11-24% major') > 0
   AND length(markdown) = 10991;

-- == dolphin ==
UPDATE imported_classes
   SET markdown = '---
id: dolphin
name: Dolphin
system: rifts
source_book: Rifts World Book 7: Underseas p.77-80
category: rcc
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+45"
hit_points_base: "P.E. + 6d6, +1d6 per level"
sdc_base: "2d4x10"
ppe_base: "P.E. + 2d4x10, +1d6 per level"
bonuses:
  combat: { attacks_base: 2, initiative: 3, strike: 2, dodge: 2, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 4, disease: 1, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    dolphin:
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
  spells_starting_groups:
    - { count: 2, from_list: "dolphin" }
  spells_schedule:
    - { level: 2, count: 1, from_list: "dolphin" }
    - { level: 4, count: 1, from_list: "dolphin" }
    - { level: 6, count: 1, from_list: "dolphin" }
    - { level: 8, count: 1, from_list: "dolphin" }
    - { level: 10, count: 1, from_list: "dolphin" }
    - { level: 12, count: 1, from_list: "dolphin" }
    - { level: 14, count: 1, from_list: "dolphin" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 25, per_level: 5, note: "Printed as Undersea Survival, with no bonus - the one cetacean entry that prints none." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One human language of choice (+20%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 11, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence", "Pick Pockets"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant dolphins are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one - unlike almost everything else imported from this book. It becomes mega-damage only while ley line charged."
  - "Horror Factor: NONE. The dolphin is the one cetacean in this chapter with no horror factor at all."
  - "Size: 5 to 7 feet (1.5 to 2.1 m) for most; 6 to 8 feet (1.8 to 2.4 m) for the bottle-nosed dolphin and pygmy killer whale; 8 to 20 feet (2.4 to 6.1 m) for most other toothed whales in the dolphin family. Weight 150 to 300 lbs (67.5 to 135 kg), plus 100 lbs for the bottle-nose and pygmy killer whale, which also gets +10 S.D.C."
  - "Average life span: 50 to 100 years. Dolphins are found world wide."
  - "Speed 2D6+45 is the SPRINT, roughly 32 to 38 mph. A cruising dolphin holds 25 to 30 mph for an hour or two, covering 150 to 250 miles a day - up to 350 if pushed to exhaustion, which then halves speed and range for following days until it rests a day or two."
  - "Spell strength - the number others must save against - is +1 at levels three, seven and eleven. The dolphin is also +2 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "A DOLPHIN THAT DECLINES FURTHER MAGIC IS PAID FOR IT. Printed 80 lets a dolphin learn two ocean magic spells or one whale spellsong at levels three, six, nine and eleven; one that chooses not to - and many do not - instead gains +1D4x10 S.D.C., +1 on initiative, +1 to strike and dodge, +1 to pull punch and roll with impact, and +1D6 to Spd. Neither branch is stored; the dolphin-magic ladder is."
  - "Porpoises are not dolphins here: they start with two attacks, get half the sonic-stun range, and cannot cast dolphin magic at all."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none, though some humans and D-bees experiment on dolphins with implants and bionics."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Dolphin Psionics (printed 80): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Healing or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Healing", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Automatic Dodge"
    description: "Dodges without using up a melee action - the only cetacean in this chapter that can."
  - name: "Sonic Stun"
    description: "An S.D.C. sonic attack doing 2D6 S.D.C. underwater or 1D4 in air, with a 1-60% chance of knocking the victim out for 1D4 melee rounds. A victim who stays conscious but fails to save has a splitting headache and is disoriented: -6 on initiative, -6 to strike, parry and dodge, speed, attacks and skill performance halved, and no sense of direction, depth or which way is up, for 1D4 melee rounds. The saving throw scales with the target: small fish need 19 or better, man-sized fish and sharks 10, humans and most intelligent life 3. Other cetaceans are impervious, as are dragons, giants, creatures of magic, supernatural beings and most mega-damage creatures. It does not damage or penetrate mega-damage armour, vehicles or structures. Only dolphins and porpoises have it."
  - name: "Dolphin Combat"
    description: "Two attacks per melee round at level one, and one more at levels two, four, six, ten and fourteen. A warning nip does 1 S.D.C. and a full bite 1D4; a nose jab 1D4; a head or nose strike 1D4 restrained or 2D4 at full strength; a power strike 3D6 with a 70% chance of costing the victim initiative and one action, counting as two attacks; a tail slap 1D6. Parries with nose or tail."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 500 feet (152 m) plus 100 feet (30.5 m) per level."
  - name: "Mid-Air Leap and Precision Leaping"
    description: "Leaps six feet (1.8 m) plus one foot (0.3 m) per level out of the water, to show off or to grab or knock an item from a hand at +2 to strike. The precision leap counts as three melee actions. Also somersaults, breaches, swims backwards and does backward flips."
  - name: "Quick Turns & Stops"
    description: "Rolled as an automatic dodge or parry; 14 or higher succeeds. A failed roll means it could not stop in time and takes 2D6 impact damage."
  - name: "Speed Burst"
    description: "Double speed for one minute, six times an hour. Used for a quick dodge at +2, a quick strike at +1, or to close or break away. Conditional, so not in the stored bonuses."
  - name: "Tight Circle & Turn"
    description: "Turns within an area as small as 12 feet (3.65 m) across."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 77-80. The first of four cetacean R.C.C.s in this
    chapter, and the only one of the four that is not a whale.
  - IT IS AN S.D.C. CREATURE. Every other class imported from this book so far
    is mega-damage; this one has hit points and S.D.C. and becomes
    mega-damage only while ley line charged. `hit_points_base` and `sdc_base`
    are both used, and `mdc_base` is deliberately absent.
  - THE BOOK SPELLS ONE OF ITS OWN SPELLS THREE WAYS. Printed 70''s
    alphabetical list says Electromagnetic Pulse, the description heading on
    the same page says Electro-Magnetic Pulse, and this class''s own list on
    printed 80 says Electromagnetic BLAST. The spell chapter''s alphabetical
    list is the authority for membership, so the catalog row is
    `Dolphin: Electromagnetic Pulse` and all three readings are recorded -
    here and on the spell row''s `variant_note`.
  - THREE RELATED-SKILL LINES REACH ACROSS THE CATALOG''S FILING, and each
    needed checking rather than transcribing:
      * The book grants SING under Domestic; the catalog files Sing under
        Communications. It is named in the Communications entry so it is
        actually takeable - an `only` naming a skill whose real category the
        class does not grant is unreachable.
      * The Technical line is language, lores and underwater skills only,
        which is a PREFIX restriction rather than a name list.
        `only_prefix: [Language, Lore]` covers 21 language rows and the lore
        family without enumerating either, and `only` adds the two underwater
        Technical rows this book itself created.
      * The -10% the book prints on the Communications line applies to Radio:
        Basic alone. It is NOT stored as a category bonus, because a category
        bonus would apply it to Sing as well.
  - THE ROGUE `except` DROPS ONE OF THE BOOK''S TWO NAMES. Printed 77 bars
    computer hacking and pick locks; the catalog files Pick Locks under
    Espionage, whose `only` list here does not include it, so it is already
    unreachable and an `except` naming it would exclude nothing. Only
    Computer Hacking is stored.
  - THE ''DECLINE MAGIC FOR BONUSES'' BRANCH IS NOT MODELLED. Printed 80 offers
    a dolphin extra S.D.C., speed and five combat bonuses in exchange for
    never learning ocean magic or spellsongs. That is a character-creation
    either/or across two unrelated blocks, and nothing here can express it.
    The magic ladder is stored and the alternative is a restriction line.
  - PSIONICS ARE A PERCENTILE ROLL, printed 80, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
---

# Dolphin

## Lore

Playing a dolphin can be a blast. There is something magical about a creature so alien and so familiar at once, and the character is at its best when the player plays it in character - a different view of life, thinking in pictures rather than words, high morals, innocence, and broken speech.

Dolphins are natural ley line walkers with some abilities a ley line walker does not have. They can charge themselves on a line until they glow blue and turn temporarily mega-damage, fire mystic bolts, and hop between neighbouring lines through a Rift of their own making.

They are also the only cetaceans besides porpoises with the sonic stun - a blast that scales its effect to the size of what it hits, and that other cetaceans are entirely immune to.

## GM Notes

Do not forget that through advanced technology and magic, dolphins and other sea creatures can travel and survive on dry land for short periods, and for long ones where water and the right magic are constantly available.

A dolphin out of water is helpless - it can only flop and squirm - and it is on a clock: about fifteen minutes before the skin dries and it weakens, dead in half an hour or so unless it is sprinkled or immersed.

Many dolphins decline to learn any magic beyond their own. The book pays them for it in raw physical bonuses, which is worth knowing before a player picks.
',
       updated_at = datetime('now')
 WHERE class_id = 'dolphin'
   AND instr(markdown, 'special_abilities:') = 0
   AND length(markdown) = 16839;

-- == killer-whale ==
UPDATE imported_classes
   SET markdown = '---
id: killer-whale
name: Killer Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.85-88
category: rcc
tags: [aquatic]
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+14"
hit_points_base: "P.E. + 1d4x10, +10 per level"
sdc_base: "2d6x10"
ppe_base: "P.E. + 1d6x10, +2d6 per level"
bonuses:
  combat: { attacks_base: 3, initiative: 2, strike: 3, dodge: 1, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 6, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    any_magic:
      - "Ocean: Abilities of a Snail"
      - "Ocean: Air Swim"
      - "Ocean: Armor of Neptune"
      - "Ocean: Black Water"
      - "Ocean: Breathe Air"
      - "Ocean: Calm Waters"
      - "Ocean: Change Current"
      - "Ocean: Communicate with Sea Creature"
      - "Ocean: Coral Armor"
      - "Ocean: Float Underwater"
      - "Ocean: Float on Water"
      - "Ocean: Flying Fish"
      - "Ocean: Grow Tentacles"
      - "Ocean: Healing Waters"
      - "Ocean: Impervious to Cold"
      - "Ocean: Impervious to Electricity"
      - "Ocean: Impervious to Ocean Depths"
      - "Ocean: Metamorphosis Crustacean"
      - "Ocean: Metamorphosis Fish"
      - "Ocean: Metamorphosis Shark"
      - "Ocean: Mystic Sea Horse"
      - "Ocean: Ride the Waves"
      - "Ocean: Sense Direction Underwater"
      - "Ocean: Senses of the Shark"
      - "Ocean: Sonar Hearing"
      - "Ocean: Sound Sponge"
      - "Ocean: Speak Underwater"
      - "Ocean: Strength of the Whale"
      - "Ocean: Summon Sea Friend"
      - "Ocean: Transmute Water"
      - "Ocean: Travel Above Water"
      - "Ocean: Walk Like a Humanoid"
      - "Ocean: Water Envelope"
      - "Ocean: Water Nourishment"
      - "Ocean: Water Pulse"
      - "Ocean: Water Rush"
      - "Ocean: Water Seal"
      - "Ocean: Water Spout"
      - "Ocean: Water Wall"
      - "Ocean: Weed Snare"
      - "Ocean: Whirlpool"
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 2, from_list: "any_magic", note: "Ocean magic, dolphin magic or whale spellsongs in any combination - the book offers all three from one pool." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "any_magic" }
    - { level: 4, count: 1, from_list: "any_magic" }
    - { level: 6, count: 1, from_list: "any_magic" }
    - { level: 8, count: 1, from_list: "any_magic" }
    - { level: 10, count: 1, from_list: "any_magic" }
    - { level: 12, count: 1, from_list: "any_magic" }
    - { level: 14, count: 1, from_list: "any_magic" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One human language of choice (+15%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 7, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant orca are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D4+3."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. plus 1D4x10 for females and young, and P.E. plus 4D4x10 for a full-grown male, +10 per level either way. S.D.C. is 2D6x10 for females and young, 4D6x10 for a full-grown male. A full-grown male character should use the larger of each."
  - "Horror Factor: 14 when angry or attacking. The stored save bonus is +6; the horror factor itself is a number others save against."
  - "Size: males average 25 to 33 feet (7.6 to 10 m), females 14 to 21 feet (4.2 to 6.4 m). The upright angular fin is 5 to 7 feet (1.5 to 2.1 m) tall, larger than any other whale''s. Weight 2 to 5 tons; the male is about twice the size of the female."
  - "Average life span: 60 to 100 years, maturity at 8 to 12. There are an estimated 11 million on Rifts Earth."
  - "Spell strength is +1 at levels four, eight and twelve. The orca is +3 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE, unlike the dolphin."
  - "The killer whale is the ONLY cetacean that preys on warm-blooded animals. It hunts dolphins, porpoises, seals, sea lions, penguins and sea birds as well as fish and squid, and a hunting pair or pod occasionally takes baleen, beluga, narwhal and grey whales. It never feeds on other orca."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Killer Whale Psionics (printed 88): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Orca Combat"
    description: "Three attacks per melee round at level one, and one more at levels two, five, seven, ten and thirteen. Parries with nose or tail. NO automatic dodge."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 800 feet (182 m) plus 100 feet (30.5 m) per level, at +2 to strike on a diving attack."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 85-88. An S.D.C. creature like the dolphin, and the
    largest species in the dolphin family - the book files it as its own
    R.C.C. rather than as a dolphin variant.
  - ITS MAGIC IS THE WIDEST OF THE FOUR CETACEANS and is stored as a single
    merged pool. Printed 88 lets the orca learn ocean magic, dolphin magic or
    whale spellsongs IN ANY COMBINATION, which is one pool of 72 rather than
    three lists with separate counts - so `any_magic` is the union, and that
    is the honest reading of the sentence rather than a convenience.
  - HIT POINTS AND S.D.C. EACH HAVE A FEMALE/YOUNG FIGURE AND A FULL-GROWN
    MALE FIGURE, and the smaller is stored, consistently across all three
    whales in this batch. Both are in the restrictions. A single column
    cannot hold a sex-and-age branch, and storing the larger would over-roll
    every young or female character.
  - SEE THE DOLPHIN''S NOTES for the three related-skill lines that reach
    across the catalog''s filing - Sing, the Technical prefix restriction, and
    why the -10% is not a category bonus. All four cetaceans share them.
  - ITS ESPIONAGE LIST IS SHORTER THAN THE DOLPHIN''S: no escape artist and no
    pick pockets. Transcribed as printed.
  - PSIONICS ARE A PERCENTILE ROLL, printed 88, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
---

# Killer Whale

## Lore

With hundreds of years and no commercial whaling behind it, the killer whale has regained its place as a power in the oceans of Rifts Earth. It does not prey on humans, but it is aloof and suspicious of them - until it befriends one, at which point it gives that person the same loyalty, playfulness and affection it gives its own kind, and its pod is likely to follow suit.

It extends the same friendship to D-bees and mutants that are very human-like: sea titans, True Atlanteans, psi-stalkers, kittani, changelings, ogres, elves, dwarves, dog boys, wolfen, simvan and Lemurians.

Aquatic humanoids are another matter. Orcas view amphibs and most aquatic D-bees with suspicion and animosity, and while no killer whale has ever slain a human, they regularly bite and kill aquatic humanoids, D-bees, aliens and mutants. Naut''yll, horune, gene-splicers and their mutants, sea monsters, minions of the Lord of the Deep and demons are treated as natural prey and attacked without provocation.

## GM Notes

Among their own kind orcas are intelligent, compassionate and gentle, much like their smaller dolphin cousins - protecting the young and sick, working in groups, showing affection, and seldom fighting each other.

A typical pod runs 50 to 300 members and usually stays together for life. A pod that outgrows that splits into two or three groups of 8 to 50, which grow into pods themselves. Family ties survive the split and pass down the generations: an orca can recognise immediate family, its own pod, other pods, rogues and even relatives it has never met, from the accent of a pod''s language and from physical marks.

The killer whale is the only cetacean that preys on warm-blooded animals. A settled orca''s hunting range spans 200 to 600 miles.
',
       updated_at = datetime('now')
 WHERE class_id = 'killer-whale'
   AND instr(markdown, 'special_abilities:') = 0
   AND length(markdown) = 15990;

-- == sperm-whale ==
UPDATE imported_classes
   SET markdown = '---
id: sperm-whale
name: Sperm Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.88-90
category: rcc
tags: [aquatic]
xp_table: [0, 2051, 4101, 8251, 18501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+10"
  MA: "2d6+6"
  PS: "4d6+34"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "2d6"
  Spd: "2d6+16"
hit_points_base: "P.E. x10, +20 per level"
sdc_base: "3d6x10"
ppe_base: "P.E. + 4d4x10, +10 per level"
bonuses:
  combat: { attacks_base: 1, initiative: 1, strike: 3, dodge: 1, pull_punch: 1, roll: 3 }
  saves: { horror_factor: 8, toxins_poisons: 4, disease: 4, mind_control: 1 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 3, from_list: "spellsongs" }
  spells_schedule:
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 45, per_level: 5, note: "+10%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Undersea & Sea Survival", base: 45, per_level: 5, note: "Printed as Undersea Survival (+20%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "One human language of choice (+5%), probably American/English." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Physical", only: ["Prowl"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", only: ["Streetwise"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour. Its Rogue line is Streetwise and Prowl only; Prowl is a Physical row in this catalog and is granted through a Physical entry so it is actually takeable."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 7, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 35% scrupulous, 10% principled, 20% unprincipled, 25% anarchist and 10% other. This is the most anarchist of the four cetaceans by some way."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 2D4+6 - the toughest hide of the four."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. x10 for females and young and P.E. x20 for a full-grown male, +20 per level either way. S.D.C. is 3D6x10 for females and young, 6D6x10 for a full-grown male."
  - "Horror Factor: 13 when angry or attacking."
  - "Size: males average 60 to 70 feet (18.3 to 21.3 m), females 38 to 45 feet (11.5 to 13.7 m). Weight 50 to 70 tons for a full-sized adult, 15 to 30 for a female. The head is a third of the body and is always scarred from fighting squid."
  - "Average life span: 50 to 80 years, maturity at 11 to 16. There are an estimated 650,000 on Rifts Earth, not counting the pygmy and dwarf sperm whales."
  - "IT DIVES DEEPER THAN ANY OTHER CETACEAN - two miles (3.2 km) and deeper still on a dive, at five times its normal speed going down."
  - "Spell strength is +1 at levels four, eight and twelve. It is +4 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "IMPERVIOUS TO COLD - it takes no damage at all, where the dolphin, orca and humpback take half."
  - "NO AUTOMATIC DODGE. It parries with nose or tail at +1."
  - "Its diet is 80% squid, including giant squid, the rest octopus, fish, shrimp and crab."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-60): Minor Psionic", "Psionics (61-80): Major Psionic, Physical or Sensitive", "Psionics (81-90): Major Psionic, Healing, Physical or Sensitive", "Psionics (91-00): Master Psionic"], note: "Sperm Whale Psionics (printed 90): every Sperm whale has some psionic power. Roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-60): Minor Psionic"
    description: "Roll 01-60. A minor psionic limited to four powers: See Aura, See the Invisible, Sense Magic and Mind Block. Base I.S.P. is M.E. x2, plus 1D6 per level."
    psionics:
      type: "minor"
      isp_base: "M.E. x2, +1d6 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
  - name: "Psionics (61-80): Major Psionic, Physical or Sensitive"
    description: "Roll 61-80. A major psionic with See Aura, See the Invisible, Sense Magic and Mind Block, plus 1D4+1 powers of choice from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. Base I.S.P. is M.E. x3, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x3, +1d6+2 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (81-90): Major Psionic, Healing, Physical or Sensitive"
    description: "Roll 81-90. A major psionic with See Aura, See the Invisible, Sense Magic and Mind Block, plus 1D4+2 powers of choice from the Healing, Physical or Sensitive categories: roll the die and take that many of the six picks offered. Base I.S.P. is M.E. x4, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x4, +1d6+2 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
      powers_starting: 6
      powers_starting_groups:
        - { count: 6, categories: ["Healing", "Physical", "Sensitive"], note: "Roll 1D4+2 and take that many (up to six)." }
  - name: "Psionics (91-00): Master Psionic"
    description: "Roll 91-00. A master psionic: twelve powers from any of the three lesser categories at level one, and one more from any category, Super included, at each level after. Base I.S.P. is M.E. x8, plus 2D6 per level."
    psionics:
      type: "master"
      isp_base: "M.E. x8, +2d6 per level"
      powers_starting: 12
      powers_starting_groups:
        - { count: 12, categories: ["Healing", "Physical", "Sensitive"] }
      powers_schedule:
        - { level: 2, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 3, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 4, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 5, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 6, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 7, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 8, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 9, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 10, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 11, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 12, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 13, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 14, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 15, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
natural_abilities:
  - name: "Sperm Whale Combat"
    description: "ONE attack per melee round at level one - the fewest of any class in this book - and one more at levels two, four, seven, ten and thirteen. Parries with nose or tail at +1. No automatic dodge."
  - name: "Deep Diving"
    description: "Swims two miles (3.2 km) deep and dives deeper, at five times normal speed on the way down. Of all the cetaceans only the sperm whale reaches the ocean floor."
  - name: "Impervious to Cold"
    description: "Cold does NO damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 88-90. The deepest diver of the four and the only one
    that is impervious to cold rather than merely resistant.
  - ITS ROGUE LINE NAMES A SKILL THIS CATALOG FILES ELSEWHERE, and unlike the
    dolphin''s Pick Locks this one had to be rescued rather than dropped.
    Printed 89 gives Rogue: streetwise and prowl only. Streetwise is a Rogue
    row here; PROWL IS A PHYSICAL ROW, and this class''s Physical line is
    None - so naming Prowl in the Rogue `only` would leave it granted and
    unreachable. A Physical entry with `only: [Prowl]` is added so the book''s
    grant actually works. That is a deliberate departure from the printed
    Physical: None, and it is the smaller error: the alternative silently
    drops a skill the book gives.
  - ONE ATTACK PER MELEE AT LEVEL ONE is correct and is the lowest in this
    book. Checked against printed 89 rather than assumed to be an OCR drop.
  - HIT POINTS AND S.D.C. STORE THE FEMALE/YOUNG FIGURE, as on the other two
    whales. Both are in the restrictions.
  - ITS SPELLSONG LADDER IS IRREGULAR: three at level one, then one each at
    levels three, five, SIX, seven, eight, ten, twelve and fourteen. Note the
    five-six-seven-eight run in the middle, which is not a pattern - it is
    transcribed exactly as printed 90 gives it.
  - EVERY SPERM WHALE IS PSIONIC, AND THE DEGREE IS A PERCENTILE ROLL, printed
    90; it was not stored at all until 2026-10. The roll is a choose-1 special
    ability with four options named for their bands, each carrying the tier,
    I.S.P. formula and powers its row prints, so there is no class-level block.
    TWO ROWS ARE MAJOR PSIONICS and differ in I.S.P. (M.E. x3 against M.E. x4),
    in the count of chosen powers (1D4+1 against 1D4+2) and in whether Healing
    is open. Counts printed as dice are stored at the maximum with the roll in
    the pick''s note, the Demon and Dead Slaver precedent.
---

# Sperm Whale

## Lore

The king of mammals in the deep ocean. Over sixty feet long, able to swim two miles down and dive deeper, and feeding on giant squid - this is the nightmarish monstrosity of Moby Dick and Pinocchio. Its head accounts for a third of its body and is permanently scarred from battles with squid, octopus and other denizens of the deep.

Aggressive and powerful as it is, a sperm whale has never attacked a human or humanoid unprovoked - unless it is a Whale Singer on a mission of destruction. Attacked by whalers, or by pirates like the horune who hunt them for sport and profit, it rams ships and power armour, shatters lifeboats, bites its attackers, and drags surface attackers underwater to hold them until they drown or carry them to depths they cannot survive.

Sperm whales speak in clicking patterns called codas. Their other sounds are low roars and the creaking of rusty hinges.

## GM Notes

Adult males, particularly those over fifty, are often solitary hunters who meet others only in mating season or by chance. A school is either a harem - one older bull and 4D4 females - or a family clan of 1D4x10. Even sperm whale Whale Singers keep to themselves and prefer small groups or solo missions.

Like their smaller cousins they show teamwork, resourcefulness and compassion, especially toward each other. Females are fiercely protective of their young, and a bull defends every member of his group with equal vigour. When one is injured the whole group surrounds it in a tight circle, heads inward and tails out - whalers call it the marguerite flower formation, and anyone who comes within range is battered by their tails.
',
       updated_at = datetime('now')
 WHERE class_id = 'sperm-whale'
   AND instr(markdown, 'special_abilities:') = 0
   AND length(markdown) = 14456;

-- == humpback-whale ==
UPDATE imported_classes
   SET markdown = '---
id: humpback-whale
name: Humpback Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.90-92
category: rcc
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6+10"
  MA: "2d6+10"
  PS: "3d6+30"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "2d6"
  Spd: "2d6+14"
hit_points_base: "P.E. x8, +10 per level"
sdc_base: "3d6x10"
ppe_base: "P.E. + 4d4x10, +20 per level"
bonuses:
  combat: { attacks_base: 1, strike: 1, dodge: 1, pull_punch: 1, roll: 2 }
  saves: { horror_factor: 5, toxins_poisons: 2, disease: 2, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 11, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 4, from_list: "spellsongs" }
  spells_schedule:
    - { level: 2, count: 2, from_list: "spellsongs" }
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 4, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 9, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 11, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 13, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
    - { level: 15, count: 1, from_list: "spellsongs" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 40, per_level: 5, note: "+5%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "One human language of choice (+5%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour. Medical is barred entirely here, unlike the dolphin, orca and sperm whale, which all get Sea Holistic Medicine."
  secondary_skills:
    count: 0
    schedule: [{ level: 3, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 50% scrupulous, 15% principled, 15% unprincipled, 10% anarchist and 10% other. The most reliably good-aligned of the four."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D6+5."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. x8 for females and young and P.E. x10 for a full-grown male, +10 per level either way. S.D.C. is 3D6x10 for females and young, 5D6x10 for a full-grown male."
  - "Horror Factor: 10 when angry or attacking."
  - "Size: males average 60 to 70 feet (18.3 to 21.3 m), females 40 to 48 feet (12.2 to 14.6 m). Weight 60 to 70 tons for a full-sized adult, 30 to 40 for a female."
  - "Average life span: 70 to 100 years, maturity at 11 to 13."
  - "ALL HUMPBACKS HAVE SOME PSIONIC POWER. Printed 92 rolls the degree on a table rather than granting one set: 01-90 minor, 91-00 major. Roll or pick the Psionics ability, which carries the tier, I.S.P. and powers - unlike the dolphin and the orca, where most have none, here every character has something."
  - "Spellsong strength is +1 at levels two, five, eight and twelve. It is +6 to save against whale spellsongs specifically - the highest in the book - on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE. It parries with nose or tail at +1."
  - "It is a filter feeder, straining krill and shrimp through baleen plates."
  - "The humpback gets +20% to Sing where other classes get +10%, and DOUBLE range on any spellsong that lists a doubled range for humpbacks."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-90): Minor Psionic", "Psionics (91-00): Major Psionic"], note: "Humpback Whale Psionics (printed 92): every humpback has some psionic power. Roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-90): Minor Psionic"
    description: "Roll 01-90. A minor psionic limited to See Aura, Sense Magic and Mind Block, plus one power of choice from the Sensitive category. Base I.S.P. is M.E. x2, plus 1D6 per level."
    psionics:
      type: "minor"
      isp_base: "M.E. x2, +1d6 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 1
      categories_allowed: ["Sensitive"]
  - name: "Psionics (91-00): Major Psionic"
    description: "Roll 91-00. A major psionic limited to See Aura, Sense Magic and Mind Block, plus two powers of choice from the Healing or Sensitive categories. Base I.S.P. is M.E. x3, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x3, +1d6+2 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 2
      categories_allowed: ["Healing", "Sensitive"]
natural_abilities:
  - name: "Master of Spellsongs"
    description: "Other than the pneuma-biforms, the humpback is the most powerful of the Whale Singers. It selects four spellsongs at level one, two at level two, and one more every level after."
  - name: "True Song"
    description: "No other whale has the same variety or complexity of sound. A humpback''s songs are true songs - an ordered sequence of themes, motifs and phrases like a bird''s - which can be repeated exactly and taught to others. Clicks, chirps, yups, cries, moans and roars, mostly between 40Hz and 5kHz. One song lasts 6 to 40 minutes and can carry up to 116 miles (185 km), though most sounds reach 50 to 60 miles."
  - name: "Humpback Combat"
    description: "ONE attack per melee round at level one, and one more at levels two, five, eight, eleven and fourteen. Parries with nose or tail at +1. No automatic dodge."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 90-92. The master of spellsongs: other than the
    pneuma-biforms, the most powerful of the Whale Singers, and the only
    cetacean here whose magic is spellsongs alone.
  - ITS SPELLSONG LADDER IS THE FULLEST IN THE BOOK - four at level one, two
    at level two, and one every level after - which is the same shape the
    Whale Singer O.C.C. uses. That is not a coincidence and it is why this
    class is worth having.
  - EVERY HUMPBACK IS PSIONIC TO SOME DEGREE, which is different from the
    dolphin and orca, where printed 80 and 88 leave 77% with nothing. No
    class-level psionics block is stored either way, because printed 92 still
    rolls the degree rather than granting one set: the roll is a choose-1
    special ability with two options named for their bands, 01-90 minor and
    91-00 major, each carrying its own tier, I.S.P. formula and powers.
  - MEDICAL IS BARRED ENTIRELY, where the other three cetaceans all get Sea
    Holistic Medicine. Transcribed as printed 91 gives it.
  - ITS SING BONUS AND ITS SPELLSONG RANGES ARE BOTH DOUBLED relative to the
    other cetaceans, and several spellsong rows name the humpback explicitly
    in their range lines. Neither is stored on this class: the Sing bonus
    belongs to whichever class grants the skill, and the doubled range lives
    on the spell rows.
  - HIT POINTS AND S.D.C. STORE THE FEMALE/YOUNG FIGURE, as on the other two
    whales.
---

# Humpback Whale

## Lore

There has always been something magical about the humpback whale and its haunting songs. No other whale has the same variety or complexity of sound, and the humpback''s are true songs - an ordered sequence of themes, motifs and phrases like a bird''s, which can be repeated exactly and taught to others.

A single song lasts between six and forty minutes and can be heard up to a hundred and sixteen miles away.

Since the development of Whale Singer spellsongs, the humpback has become one of their masters. Other than the pneuma-biforms, it is the most powerful of the Whale Singers.

## GM Notes

Humpbacks, like all baleen whales, are filter feeders. The whale opens its mouth wide to engulf water full of krill and shrimp, and the baleen plates growing down from the roof of its mouth strain them out as the water passes through.

Every humpback has some degree of psionic power - which is not true of dolphins or killer whales, where most have none at all.

Several spellsongs name the humpback explicitly in their range lines, doubling or in one case multiplying by ten what any other singer gets. A humpback in a party changes what the spellsong list is worth.
',
       updated_at = datetime('now')
 WHERE class_id = 'humpback-whale'
   AND instr(markdown, 'which is why no psionics block is stored') > 0
   AND length(markdown) = 14555;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'amphib' AND instr(markdown, 'Appearance (01-20): Perfect Human') > 0)
    OR (class_id = 'sea-titan' AND instr(markdown, 'Psionics (01-18): Major Psionic') > 0)
    OR (class_id = 'nautyll-soldier' AND instr(markdown, 'Psionics (31-50): Mystic') > 0)
    OR (class_id = 'dolphin' AND instr(markdown, 'Psionics (01-77): None') > 0)
    OR (class_id = 'killer-whale' AND instr(markdown, 'Psionics (01-77): None') > 0)
    OR (class_id = 'sperm-whale' AND instr(markdown, 'Psionics (81-90): Major Psionic') > 0)
    OR (class_id = 'humpback-whale' AND instr(markdown, 'Psionics (01-90): Minor Psionic') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'amphib' AND instr(markdown, 'Rolled on a percentile table, and it changes real numbers.') > 0)
    OR (class_id = 'sea-titan' AND instr(markdown, 'No psionics block is stored, because 47% have none.') > 0)
    OR (class_id = 'nautyll-soldier' AND instr(markdown, '01-10% minor, 11-24% major') > 0)
    OR (class_id = 'humpback-whale' AND instr(markdown, 'which is why no psionics block is stored') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('amphib', 'sea-titan', 'nautyll-soldier', 'dolphin', 'killer-whale', 'sperm-whale', 'humpback-whale') AND instr(markdown, char(13)) > 0;

INSERT INTO data_script_runs (filename) VALUES ('~089-underseas-percentile-groups.sql');
