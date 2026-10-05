-- The Sea Titan's own psionics table replaces the standard Random Psionics roll
-- 1 class, each replaced whole: sea-titan.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~164-sea-titan-own-psionics-table.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C5, a fourteenth class: the Sea Titan. The census that
-- found the first thirteen (~163) ran over an incomplete dump of production
-- that stopped before the letter S. Underseas printed 114 prints the race's
-- own Psionic Powers line - to determine psionics, roll percentile dice - with
-- its own No psionic powers band at 51-97, so its table stands in place of the
-- standard Random Psionics roll. Read off a render; all four bands agree.

-- == sea-titan ==
UPDATE imported_classes
   SET markdown = '---
id: sea-titan
name: Sea Titan
system: rifts
source_book: Rifts World Book 7: Underseas p.113-115
category: rcc
psionics_allowed: false
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
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 114 prints the race''s own Psionic Powers line - twice as likely to have psionic powers; to determine psionics, roll percentile dice - with its own No psionic powers band at 51-97 (read off a render).
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
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 13710;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'sea-titan' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('sea-titan') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~164-sea-titan-own-psionics-table.sql');
