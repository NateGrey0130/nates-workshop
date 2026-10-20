-- The Blind Warrior Women's attacks take D-Bees of North America's figures,
-- and the Demon-Dragonmage class cites the page its entry ends on.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~238-d-bees-of-north-america-bww-and-pages.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~238-d-bees-of-north-america-bww-and-pages.sql
--
-- 1. blind-warrior-women. ~233 moved the creature row to Rifts World Book 30:
-- D-Bees of North America printed 15-18 and left its three stat_attacks rows
-- on Rifts World Book 2: Atlantis printed 50-51 (karate punch 1D6, kick 1D8,
-- leap kick 2D8), with D-Bees' figures written into bonuses_note instead. By
-- Nate's ruling of 2026-10-19 the attacks move to D-Bees. Printed 17 (cache
-- p018, read off a 300 dpi render) lists the combat moves as Body Flip 2D4
-- S.D.C., Karate kick 2D6 S.D.C., Karate leap kick 3D8 S.D.C., Power Kick
-- and Karate punch 2D4 S.D.C., in that order, and says to apply the P.S.
-- damage bonus to each. The Power Kick prints no dice of its own, only that
-- it does double damage and counts as two attacks, so its damage is NULL and
-- that is its note. The three held rows are UPDATED in place, guarded on
-- Atlantis' figure; the two the page adds are INSERT OR IGNORE. sort follows
-- the page's order. bonuses_note loses the dice it carried in their place,
-- and description says the attacks followed Atlantis until this script; its
-- record of what Atlantis printed is unchanged.
--
-- 2. demon-dragonmage. The class cited printed 58-60 and its creature row
-- 58-61. Printed 61 (cache p062, read off a render) opens with the entry's
-- own Habitat, Slave Market Value, Alliances and Allies, Rivals and Enemies
-- and Note lines before the Deer Horn Tribesmen begin, so the class widens to
-- 58-61, and the one extraction note that said 58-60 says so too. The class's
-- markdown is replaced whole by scripts/class-fix-sql.mjs (below).
--
-- NOT changed: lyn-srial stays at printed 127-129 against its creature row's
-- 127-130. Printed 130 (cache p131) holds only the Sky-Knight's R.C.C. skills,
-- related and secondary skills, experience level, equipment and a note on
-- New West, then the Lyvorrk; nothing of the Lyn-Srial R.C.C.'s own section
-- is on it. darkhound (54-58) and psi-goblin (164-166) already match.
--
-- THIS SCRIPT CHANGES PRODUCTION: five stat_attacks rows (three updated, two
-- added), one creatures row and one class. The tilde number is claimed at
-- merge.

UPDATE stat_attacks SET damage = '2D6 SDC', sort = 1
 WHERE owner_kind = 'creature' AND owner_slug = 'blind-warrior-women'
   AND name = 'Karate kick' AND damage = '1D8 SDC';

UPDATE stat_attacks SET damage = '3D8 SDC', sort = 2
 WHERE owner_kind = 'creature' AND owner_slug = 'blind-warrior-women'
   AND name = 'Karate leap kick' AND damage = '2D8 SDC';

UPDATE stat_attacks SET damage = '2D4 SDC', sort = 4
 WHERE owner_kind = 'creature' AND owner_slug = 'blind-warrior-women'
   AND name = 'Karate punch' AND damage = '1D6 SDC';

INSERT OR IGNORE INTO stat_attacks (owner_kind, owner_slug, name, damage, is_mega_damage, range, note, sort) VALUES
('creature', 'blind-warrior-women', 'Body Flip', '2D4 SDC', 0, 'melee', NULL, 0),
('creature', 'blind-warrior-women', 'Power Kick', NULL, 0, 'melee', 'double damage; counts as two attacks', 3);

UPDATE creatures
   SET bonuses_note = replace(bonuses_note,
         'Combat moves: body flip 2D4, karate kick 2D6, karate leap kick 3D8 and karate punch 2D4, all S.D.C. plus the P.S. damage bonus; a power kick does double damage but counts as two attacks.',
         'Every combat move in her attacks adds the P.S. damage bonus.')
 WHERE slug = 'blind-warrior-women'
   AND instr(bonuses_note, 'Combat moves: body flip 2D4, karate kick 2D6, karate leap kick 3D8 and karate punch 2D4') > 0;

UPDATE creatures
   SET description = replace(description,
         'which this row followed until ~233, gave:',
         'which this row followed until ~233 and its attacks until ~238, gave:')
 WHERE slug = 'blind-warrior-women'
   AND instr(description, 'which this row followed until ~233, gave:') > 0;

-- Read the Blind Warrior Women back. A guard that matched nothing must fail
-- here, not pass.

SELECT 'the Blind Warrior Women hold the five attacks printed 17 lists' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'blind-warrior-women'
   AND is_mega_damage = 0 AND range = 'melee'
   AND ((name = 'Body Flip' AND damage = '2D4 SDC' AND note IS NULL AND sort = 0)
     OR (name = 'Karate kick' AND damage = '2D6 SDC' AND note IS NULL AND sort = 1)
     OR (name = 'Karate leap kick' AND damage = '3D8 SDC' AND note IS NULL AND sort = 2)
     OR (name = 'Power Kick' AND damage IS NULL AND note = 'double damage; counts as two attacks' AND sort = 3)
     OR (name = 'Karate punch' AND damage = '2D4 SDC' AND note IS NULL AND sort = 4));

SELECT 'and no other attack, Atlantis'' or any' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'blind-warrior-women';

SELECT 'the creature row no longer carries the attacks in prose, and says when they moved' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'blind-warrior-women'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.15-18'
   AND instr(bonuses_note, 'Combat moves:') = 0
   AND instr(bonuses_note, 'Every combat move in her attacks adds the P.S. damage bonus.') > 0
   AND instr(bonuses_note, 'Eight attacks per melee') = 1
   AND instr(description, 'its attacks until ~238, gave:') > 0
   AND instr(description, 'karate kick 1D8, karate leap kick 2D8 and karate punch 1D6') > 0;

SELECT 'the Horune Pirate''s three attacks are untouched' AS assertion, count(*) AS got, 3 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'horune-pirate';

-- == demon-dragonmage (written by scripts/class-fix-sql.mjs) ==
UPDATE imported_classes
   SET markdown = '---
id: demon-dragonmage
name: Demon-Dragonmage (Young)
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.58-61
category: rcc
tags: [supernatural, high-power]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
men_of_arms: false
attribute_dice:
  IQ: "2d6+8"
  ME: "2d6+10"
  MA: "2d6+12"
  PS: "2d6+16"
  PP: "2d6+10"
  PE: "2d6+10"
  PB: "2d6+3"
  Spd: "2d6+16"
mdc_base: "P.E. attribute x10, +3d6 per level of experience"
ppe_base: "1d4x100 + P.E. attribute number, +3d6 per level of experience"
starting_money: "1d6x1000"
horror_factor: 10
bonuses:
  at_level:
    - { level: 2, combat: { roll: 2 } }
    - { level: 5, combat: { attacks: 1, initiative: 1, pull_punch: 2 }, saves: { horror_factor: 3 } }
    - { level: 8, saves: { possession: 6 } }
    - { level: 12, combat: { perception: 2 } }
skills:
  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "anarchist or evil alignment" }, creation_only: true }
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 0 }
    - { name: "Language: Dragonese", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 15, per_level: 5, note: "Two languages of choice (+15%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 15, per_level: 5, note: "Literacy: one of choice (+15%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Seduction", base: 33, per_level: 3, note: "+13%" }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Lore: Astral", "Lore: D-Bee", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Geomancy or Lines of Power", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { choose: 2, categories: ["Pilot", "Horsemanship"], note: "Pilot or Horsemanship: two of choice." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: one Ancient of choice." }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Handguns", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"], note: "W.P.: one Modern of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert, or Assassin if Anarchist or evil. The Hand to Hand skill cannot be changed once it is selected." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - "Horsemanship"
      - "Pilot Related"
      - { name: "Rogue", bonus: 10 }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 2 }
    note: "Cowboy, Electrical, Mechanical, Medical and Wilderness: none. All new skills start at level one proficiency. The book also grants two more at each of levels 16, 18, 20, 24, 26, 28 and 30."
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
psionics:
  type: "master"
  isp_base: "2d4x10 + M.E. attribute number, +10 per level of experience"
  powers: ["Pyrokinesis", "Bio-Manipulation (the evil eye)", "Telepathy", "Mind Block"]
  powers_starting: 0
  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Super"] }
    - { level: 2, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 3, count: 1, categories: ["Super"] }
    - { level: 3, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 4, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 5, count: 1, categories: ["Super"] }
    - { level: 5, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 6, count: 1, categories: ["Super"] }
    - { level: 6, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 7, count: 1, categories: ["Super"] }
    - { level: 7, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 8, count: 1, categories: ["Super"] }
    - { level: 8, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 9, count: 1, categories: ["Super"] }
    - { level: 9, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 10, count: 1, categories: ["Super"] }
    - { level: 10, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 11, count: 1, categories: ["Super"] }
    - { level: 11, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 12, count: 1, categories: ["Super"] }
    - { level: 12, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 13, count: 1, categories: ["Super"] }
    - { level: 13, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 14, count: 1, categories: ["Super"] }
    - { level: 14, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 15, count: 1, categories: ["Super"] }
    - { level: 15, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
magic:
  type: "spell"
  spells: ["Blinding Flash", "Ignite Fire", "Fuel Flame", "Fire Bolt", "Fire Ball"]
  spells_starting: 20
  spell_levels_allowed: [1, 2, 3, 4, 5, 6]
  spells_starting_groups:
    - { count: 20, spell_levels: [1, 2, 3, 4, 5, 6], note: "Roll 3D4+8 and pick that many spells from levels 1-6. 20 is the most the roll can give; the picker cannot enforce the roll, so take only what you rolled." }
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
natural_abilities:
  - { name: "Supernatural being", description: "A mega-damage being. P.S. is Robotic as a Young-Dragonmage and becomes Supernatural as a mature Demon-Dragonmage. Seemingly immortal unless slain, although a Young-Dragonmage that does not reach maturity by 2100 years of age dies. Perfect vision, senses on par with a human''s." }
  - { name: "Creature of Fire", description: "Impervious to all normal heat and fire, including M.D. plasma. Magic fire and magical flaming weapons inflict half damage." }
  - { name: "Nightvision", description: "1000 feet (305 m) (1st level)." }
  - { name: "See the Invisible", description: "1st level." }
  - { name: "Rapid Healing", description: "Heals three times faster than humans (1st level)." }
  - { name: "Impervious to Disease", description: "1st level." }
  - { name: "Leap", description: "10 feet (3 m) high or across (2nd level)." }
  - { name: "Invisibility at Will", description: "Turns invisible at will at no I.S.P. or P.P.E. cost (3rd level)." }
  - { name: "Bio-Regeneration", description: "Regenerates 1D6 M.D.C. per melee round (4th level). At 25th level, 1D6x10 M.D.C. per melee round. At 30th level, regenerates the entire body within 48 hours provided the dragon''s head is not destroyed and at least 20% of the body remains intact." }
  - { name: "Understands All Languages", description: "Magically understands and can speak all languages (6th level)." }
  - { name: "Sense Ley Lines", description: "Same as the Ley Line Walker (7th level)." }
  - { name: "Teleport", description: "Self and up to 300 lbs (135 kg), at will, up to five miles (8 km) away, at no P.P.E. cost (9th level)." }
  - { name: "Greater Demon / Dimensional Teleport", description: "At 10th level it is considered a Greater Demon and gains Dimensional Teleport at 30%, +2% per each subsequent level of experience." }
  - { name: "Later Manifestations (15th level and beyond)", description: "15th level: +2D6x10 M.D.C. and flying speed increases by 50%. 18th level: double the range of fire attacks. 20th level: +2 attacks per melee round. The 25th and 30th level entries are under Bio-Regeneration." }
  - { name: "No flight", description: "Cannot fly under its own power until it becomes a full Demon-Dragonmage." }
special_abilities:
  - name: "Ley Line Walker Spell Casting"
    description: "Has the same fundamental spell casting abilities as a Ley Line Walker, without the Walker''s O.C.C. abilities, and can learn additional magic the same as the Ley Line Walker via a tutor. Many of its early spells are fire based."
  - name: "Temporal Magic (10th level)"
    description: "Experienced characters (10th level and up) may choose to make their spell selections from Temporal Magic instead (see Rifts England or Rifts Book of Magic)."
level_progression:
  - { level: 2, grants: ["Leap 10 ft high or across", "+2 to roll with impact", "1 Super psionic power + 3 from Healing, Sensitive and/or Physical (every level from 2)"] }
  - { level: 3, grants: ["Turn invisible at will"] }
  - { level: 4, grants: ["Bio-Regenerate 1D6 M.D.C. per melee round"] }
  - { level: 5, grants: ["+1 attack per melee", "+1 initiative", "+2 pull punch", "+3 save vs Horror Factor"] }
  - { level: 6, grants: ["Magically understands and speaks all languages"] }
  - { level: 7, grants: ["Sense ley lines"] }
  - { level: 8, grants: ["+6 save vs possession"] }
  - { level: 9, grants: ["Teleport self and up to 300 lbs, five miles, at will"] }
  - { level: 10, grants: ["Considered a Greater Demon", "Dimensional Teleport 30% +2% per later level", "May select Temporal Magic spells"] }
  - { level: 12, grants: ["+2 to Perception Rolls"] }
  - { level: 15, grants: ["+2D6x10 M.D.C.", "Flying speed +50%"] }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "sack", qty: "1d4" }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 3 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Playable only with G.M. permission: the stat block is headed ''Dragonmage - NPC Villain and Optional Player Character'' and the Player Note says the character is best reserved as an NPC or villain played by the Game Master, with only the Young-Dragonmage available as a Player Character, provided the G.M. allows it."
  - "A player character is a Young-Dragonmage. The mature Demon-Dragonmage is an NPC stage and is not playable here."
  - "Available O.C.C.s: None. The character is a Dragonmage by nature and cannot change even if one tries."
  - "No cybernetics or bionics: none, impossible."
  - "Hand to Hand cannot be changed once it is selected."
  - "Starts with one weapon for each W.P.; loves magic weapons and devices of all kinds but starts with none. May or may not use body armor."
  - "Money: besides the 1D6x1000 credits, starts with an equal amount in tradeable valuables."
side_effects: "Vulnerabilities: magical cold and ice based attacks inflict double damage, as do holy weapons; most types of magic, psionics and energy weapons inflict full damage. Hated and targeted regardless of alignment and good deeds by dragons (even hatchlings), Darkhounds, Temporal Raiders and True Atlanteans (especially Undead Slayers and the Sunaj); creatures of light, angels and spirits are wary of it and of anyone with it. Those in the know usually see a Young-Dragonmage as a potential rival, enemy or monster and the people with him as fools or henchmen, which could bring trouble for the group. Demon & Monster Lore may recognize a Young-Dragonmage at -10%."
extraction_notes: |
  - PRINTING. This class followed Rifts World Book 12: Psyscape printed 120-123 until this
    update; it now follows the newer printing, Rifts World Book 30: D-Bees of North America
    printed 58-61 (printed 61 holds the entry''s habitat, allies and enemies), which says the race
    originally appeared in Psyscape (ruling of 2026-10-04: the newest printing that states a
    figure wins and the older figure is kept here). Both entries were read off page renders
    (D-Bees cache p059-p062, Psyscape cache p121-p124).
  - UNCHANGED BETWEEN THE PRINTINGS: the eight attribute dice, M.D.C. P.E. x10 +3D6 per
    level, Horror Factor 10 (15 mature), P.P.E. 1D4x100 + P.E. +3D6 per level, size and
    weight, the Creature of Fire ability, the level 1 to 10 abilities (but for the
    teleport''s metric figure), the whole R.C.C. Skills list and its percentages, the four
    first-level psionic powers and the one Super plus three others per later level, I.S.P.
    2D4x10 + M.E. +10 per level, the five named spells plus 3D4+8 from levels 1-6, the
    equipment items, 1D6x1000 credits, and the dragon experience table.
  - NPC-HEADED, G.M. DISCRETION. D-Bees printed 59 heads the stat block "Dragonmage - NPC
    Villain and Optional Player Character"; its Player Note says the character is best
    reserved as an NPC or villain played by the Game Master and only the Young-Dragonmage
    is available as a Player Character, provided the G.M. allows it. Psyscape printed 121
    said it can be a difficult character to play and is not advised; G.M. discretion.
    Imported as the Young stage only. D-Bees printed 60 adds that Player Characters should
    start at first or second level.
  - NO VARIANTS. The book stages the race (Young / mature Demon-Dragonmage) but only the
    Young is playable. The mature stage takes hundreds or thousands of years and a
    slain hatchling or young adult dragon, and differs mostly in what a variant cannot
    override: natural abilities (immune to magic fire, fire breath and fire balls 300 ft
    6D6 M.D., flight), and doubled P.P.E. that a pool override could only approximate. So
    the adult is GM Notes prose, not a variant. Recorded adult figures: mental attributes,
    P.P. and P.E. +30%, P.S. becomes Supernatural, P.S. and Spd doubled, +1,200 M.D.C.,
    P.P.E. doubled, size doubled, weight tripled, Horror Factor 15, gains the slain
    dragon''s mystic knowledge. NPC level: D-Bees printed 60 gives the mature
    Demon-Dragonmage 2D6+15 or as set by the Game Master up to 30th level; Psyscape printed
    123 gave 15-25th level, sometimes higher. Young NPCs 1D4+4 in both.
  - P.S.: D-Bees printed 59 marks the Young''s P.S. 2D6+16 as (Robotic) and says P.S. becomes
    Supernatural in the adult; its Damage line reads "As per Robot or Supernatural P.S.".
    Psyscape printed 121 gave the same dice with no strength class, and the class had been
    stored as supernatural P.S. Stored in the Supernatural being natural ability.
  - LIFE SPAN: D-Bees prints seemingly immortal unless slain, although a Young that does not
    reach maturity by 2100 years of age dies. Psyscape printed 123 gave "Immortal unless
    slain". Psyscape''s "Hit Points: Mega-damage creature" line is not restated by D-Bees.
  - xp_table: THE DRAGON''S, copied 2026-09-26. D-Bees printed 60 says "Use the Dragon
    Experience Table", as Psyscape printed 123 and 157 did. The ladder is the one
    dragon-hatchling carries (Nate, 2026-09-26: a class whose book says to use another
    class''s experience table copies that class''s ladder).
  - LEVELS PAST 15. D-Bees prints ability, related-skill and secondary-skill ladders that
    run to level 30, where Psyscape stopped at 10, 12 and 15. Levels 1 to 15 are stored;
    every figure past 15 is prose and is listed here: abilities at 18 (double the range of
    fire attacks), 20 (+2 attacks per melee round), 25 (Bio-Regenerates 1D6x10 M.D.C. per
    melee round) and 30 (regenerates the entire body within 48 hours provided the dragon''s
    head is not destroyed and at least 20% of the body remains intact); two related skills
    at each of 16, 18, 20, 24, 26, 28 and 30; two secondary skills at each of 18, 21, 25
    and 30.
  - LEVEL ABILITIES: the numeric ones are bonuses.at_level (2: +2 roll; 5: +1 attack, +1
    initiative, +2 pull punch, +3 vs Horror Factor; 8: +6 vs possession; 12: +2 to
    Perception Rolls, new in D-Bees). The 15th level "+2D6x10 M.D.C. and increase flying
    speed by 50%" (new in D-Bees) is a rolled pool gain at a level and is prose in
    natural_abilities and level_progression, not a bonus. The rest are natural_abilities
    and level_progression (display). 2nd level reads "+2 to roll with impact" in D-Bees
    and "+2 to roll with impact or fall" in Psyscape. Teleport: D-Bees prints 300 lbs
    (135 kg); Psyscape printed 121 gave 300 lbs (122 kg).
  - RELATED SKILLS. D-Bees printed 60 prints Communications: Any (+5%), Cowboy: None,
    Domestic: Any, Electrical: None, with five to start, one more at levels 4, 8 and 12 and
    two at levels 14, 16, 18, 20, 24, 26, 28 and 30. Psyscape printed 123 scrambled the
    first three category names in the book itself ("Commuestic: Any", "Elecnications: Any
    (+5%)", "Domtrical: None") and gave one more at levels 4, 8 and 12 only; the class had
    stored that by line position as Communications Any and Domestic Any (+5%), the reverse
    of what D-Bees prints. Psyscape printed no Cowboy line. The other categories and
    percentages are the same in both. Horsemanship is granted because Pilot is Any and the
    catalog files riding under its own category (the Amazon precedent).
  - SECONDARY SKILLS. D-Bees prints two from the Secondary Skill List on page 300 of Rifts
    Ultimate Edition at levels 1, 3, 5, 8, 11, 15, 18, 21, 25 and 30, with no bonuses other
    than a possible high I.Q. bonus. Psyscape printed 123 gave two "from the previous
    list" (the related-skill categories, limited as that list is) at levels 1, 3, 5, 8, 11
    and 15, and the class had stored those categories on secondary_skills. D-Bees no longer
    ties the picks to the related list, so the category limit is removed.
  - SKILLS: Basic Math is Mathematics: Basic 45+20; Seduction 20+13; Dance 30+20; Sing
    35+10; Climb is Climbing 40+10; Land Navigation 36+10; Lore: Demons & Monsters
    25+20. Demongogian and Dragonese at 98% are their own catalog rows. "Pilot or
    Horsemanship: two of choice" is a choose 2 across Pilot and Horsemanship. The
    catalog does not split W.P.s into Ancient and Modern, so each is a named list.
  - HAND TO HAND: Expert, or Assassin if Anarchist or evil; D-Bees says the skill "cannot be
    changed once it is selected", Psyscape "can not be changed or upgraded". Stored as
    Expert granted plus a hand_to_hand block pricing Assassin at 0 with the alignment
    condition and creation_only, so the only change on offer is the creation-time swap the
    book allows. Attacks per Melee: as per Hand to Hand Combat skill (D-Bees); Psyscape
    printed "Combat: As per skill and training".
  - AVAILABLE O.C.C.s: D-Bees printed 60 prints "None. The character is a Dragonmage by
    nature and cannot change even if one tries. See R.C.C. Skills above." Psyscape printed
    no such line. An occ_restrictions only list may not be empty, so this is a
    restrictions line.
  - PSIONICS: Master Psychic (D-Bees; Psyscape said master psionic). The four first-level
    powers are granted by name; Bio-Manipulation is the catalog row "Bio-Manipulation (the
    evil eye)". Each level from 2 grants one Super power and three from Healing, Sensitive
    and/or Physical, stored as two schedule entries per level through 15. I.S.P. 2D4x10 +
    M.E., +10 per level.
  - MAGIC: the five named fire spells are granted. The book''s "plus 3D4+8 spells from
    levels 1-6" is a rolled count; a starting count must be a number, so the group is
    capped at 20 (the roll''s maximum) with a note telling the player to take only what
    was rolled. JUDGEMENT CALL - the cap is not enforced below 20. D-Bees prints "can learn
    additional magic the same as the Ley Line Walker via a tutor"; Psyscape printed 123
    said "the same as the Line Walker" without the tutor. Stored as the ley-line-walker''s
    per-level rule (spells_per_level 2, up_to_character_level), as before. Temporal Magic:
    D-Bees prints that characters of 10th level and up may choose to make selections from
    Temporal Magic instead (see Rifts England or Rifts Book of Magic); Psyscape printed
    that the experienced character can also learn Temporal Magic (see Rifts England) and
    pointed to Federation of Magic for the spell list. Stored as a special ability in
    prose; no spell_traditions_allowed, because the gate is by character level.
  - VULNERABILITIES: D-Bees adds holy weapons to the double-damage line; Psyscape printed
    121 gave magical cold and ice only. D-Bees adds Darkhounds to those who hate and target
    the character, and its Rivals and Enemies line (printed 61) adds Pogtal Dragon Slayers,
    Psi-Hounds, Lyn-Srial, Cyber-Knights and most heroes and champions of light.
  - POOLS: mega-damage creature, no hit points; mdc_base is stated so men_of_arms false
    is only the race default. Horror Factor 10 (Young) is stored in horror_factor.
  - EQUIPMENT: clothing (cloaks and leather), backpack, bedroll, 1D4 medium sacks (the
    generic sack row), utility belt, lighter, compass, 50 ft of rope as three 20 ft
    lengths, portable language translator, survival knife, canteen - the same items in
    both printings. D-Bees ends the line "and one weapon for each W.P. They love magic
    weapons and devices of all kinds, but start with none"; Psyscape printed 123 gave
    "Weapons: Two reflecting the character''s W.P.s" and a separate "Vehicle: Starts with
    none", which D-Bees does not restate. Body armor "may or may not" and the weapons are
    a restrictions line.
  - MONEY: D-Bees prints 1D6x1000 in credits and an equal amount in tradeable valuables;
    Psyscape printed 123 gave 1D6x1000 in credits only. starting_money holds the credits;
    the valuables are a restrictions line, there being no catalog row for them.
  - ALIGNMENT: D-Bees prints Young can be any, but usually Unprincipled (20%), Anarchist
    (40%) or any evil (20%); adults Miscreant (30%), Diabolic (34%) or Aberrant (15%), with
    a small percentage Anarchist (15%) or good (6%). Psyscape printed 121 gave Young
    usually anarchist (40%) or evil (40%), adults predominantly evil with 6% good. Size
    6-7 ft, weight 200-250 lbs.
  - NOT STORED, D-Bees only: Slave Market Value, Young 2D6x10,000 credits, adult 4D6
    million; habitat anywhere in the Megaverse, with at least a hundred operating from the
    Magic Zone; the female gives birth to 1D4 young after a 9 year pregnancy.
---

## Lore

The Demon-Dragonmage is a hairless, white-skinned, thick-skulled demon, probably from another dimension, and a sworn enemy of all dragons. In its youth it looks like an ordinary D-bee and spends a thousand years or more wandering the Megaverse as an adventurer, bandit, ruler or cult leader, gathering fire-based magic and psionic power. To reach maturity it must kill a hatchling or young adult dragon and magically bind the dragon''s head to its own chest, gaining wings, flaming eyes, vast M.D.C. and the dead dragon''s mystic knowledge. Most young start out unprincipled, anarchist or aberrant, but age tends to corrupt them, and the adults set out to rule kingdoms and be worshipped as gods.

**Alignments.** Young can be any, usually Unprincipled (20%), Anarchist (40%) or any evil (20%). Adults are Miscreant (30%), Diabolic (34%) or Aberrant (15%), with only a small percentage Anarchist (15%) or good (6%).

## GM Notes

Playable only with G.M. permission. The book heads the stat block "Dragonmage - NPC Villain and Optional Player Character" and says the character is best reserved as an NPC or villain; a player character is always a Young-Dragonmage and should start at first or second level.

Dragons, even hatchlings, hate the race on sight, as do Darkhounds, Temporal Raiders, True Atlanteans (Undead Slayers and the Sunaj above all) and the Splugorth, and good-aligned young are hunted along with the rest. Expect exposure to cost the whole party.

The mature Demon-Dragonmage is an NPC stage and is not modelled. On transformation: +1,200 M.D.C., P.P.E. doubled, mental attributes, P.P. and P.E. raised 30%, P.S. becomes Supernatural, P.S. and Spd doubled, twice the size and three times the weight, wings and flight, Horror Factor 15, impervious even to magic fire, fire breath and fire balls (300 ft, 6D6 M.D. each), and the slain dragon''s mystic knowledge. NPC adults run 2D6+15 or as set by the Game Master, up to 30th level, and use the dragon experience table.
',
       updated_at = datetime('now')
 WHERE class_id = 'demon-dragonmage'
   AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.58-60') > 0
   AND length(markdown) = 25526;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'demon-dragonmage' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.58-61') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'demon-dragonmage' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.58-60') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('demon-dragonmage') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~238-d-bees-of-north-america-bww-and-pages.sql');
