-- Convert the Kremin Cyborg to the race that takes an O.C.C. (BOOK-INGEST-AUDIT F141).
-- 1 class, each replaced whole: kremin-cyborg.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~267-book-ingest-audit-f141-kremin.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F141, conversion 4 of 5 (Nate, 2026-11-09: convert every
-- shape-changed class with no saved character). D-Bees of North America printed
-- 113 has the Kremin take an O.C.C. and use its experience table; the R.C.C.
-- skills are in addition to the O.C.C.'s. The class loses its xp_table, the CS
-- Technical Officer program, its MOS and its related and secondary skills, and
-- gains occ_restrictions from the page's Available O.C.C.s line. It keeps its
-- own equipment and its 1D4x1000 credits, which D-Bees prints for the Kremin
-- (not as per O.C.C., as it prints for the Krak on 111). The Coalition War
-- Campaign program and ladder are in the class's extraction_notes.
-- Guard: a sentence only the old markdown holds (the MOS note), so a re-run is
-- a no-op and a row edited since is left alone.

-- == kremin-cyborg ==
UPDATE imported_classes
   SET markdown = '---
id: kremin-cyborg
name: Kremin Cyborg
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.111-114
category: rcc
tags: [combat, augmented]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+4"
  MA: "3d6+2"
  PS: "2d6+24"
  PP: "1d4+22"
  PE: "N/A"
  PB: "1d6+6"
  Spd: "4d6+108"
mdc_base: "280"
ppe_base: "1d4"
horror_factor: 9
psionics_allowed: false
starting_money: "1d4x1000"
occ_restrictions:
  except: ["group:magic", "group:psychic", "group:clergy"]
  note: "Just about any Adventurer or Scholar O.C.C. or basic soldier or law enforcement O.C.C., including Body Fixer (patients other than their own kind). Common: Cyber-Doc, Operator, Rogue Scholar, Rogue Scientist, Vagabond and Wilderness Scout (any). Combat Cyborg, Headhunter and military O.C.C.s are rare, though there are law enforcement officers. Magic and psionics are out of the question."
bonuses:
  combat: { attacks: 1, disarm: 2, entangle: 1, pull_punch: 3 }
  saves: { psionics: 2, possession: 6, other: [ { label: "vs illusions and hypnosis", bonus: 3 } ] }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Kremin. R.C.C. skill, kept whatever the chosen O.C.C. The built-in translator speaks every Earth language at 96% (see natural abilities)." }
    - { name: "Literacy: Native Language", base: 96, per_level: 0, note: "Literate in the Kremin language at 96%. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Philosophy", base: 45, per_level: 5, note: "+15%. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "By tradition every Kremin is trained in the sword and self-defense. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert for explorers and lawmen, the line stored here. Civilian Kremin have Hand to Hand: Basic instead." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "clothing", qty: "1d6" }
  - { item_id: "vibro-katana", qty: 1 }
  - { choose: 1, label: "an Earth energy weapon of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle"] }
natural_abilities:
  - { name: "Full Conversion Alien Cyborg", description: "No hit points or S.D.C.; a mega-damage cyborg of alien alloys. P.S., P.P. and Spd are bionic; P.E. does not apply. Spd 4D6+108 is 76 to 90 mph (121.6 to 144 km). The figures stored are those of explorers, law enforcement officers and combat based Kremin, with some males in construction, heavy labor or mining (about 20% of the people)." }
  - { name: "Civilian Kremin", description: "Civilian males, females and children roll P.S. 1D6+20, P.P. 1D6+16, P.B. 1D6+8 and Spd 2D6+77 (53 to 60 mph, 85 to 96 km) instead, with P.E. not applicable. Reduce the M.D.C. of civilian males by 20%, civilian females by 30% and teenagers and children by 50%. Level of conversion, roll or pick: 01-55% both arms and legs bionic with a reinforced spine; 56-85% full conversion except the head, a reinforced skull likely; 86-00% full conversion including the head, made to look natural and alive. Common features: built-in radio/receiver, clock calendar, fingerjack, gyro-compass and one of choice. The head and natural senses are not usually augmented: 20/20 color vision, hearing twice as keen as a human''s. Civilians also have the psionic dampers, nano restorers and energy fist. Males average 8 feet and 600 to 800 pounds, females 7 feet and 400 to 500 pounds; the +1 attack per melee is for adults only." }
  - { name: "M.D.C. by Location", description: "Head 110, hands 30 each, arms 95 each, feet 50 each, legs 130 each, Multi-Weapon Blade and sheath 60, main body 280." }
  - { name: "Psionic Dampers and Blockers", description: "Implants in the living brain stop psychics reading surface thoughts, emotions or aura, sensing good or evil, or making a full telepathic probe: in effect a permanent mind block." }
  - { name: "Retro-Mechanic Nano Restorers", description: "Rechargeable internal nano-machines repair internal and external damage. Severe damage needs raw materials (M.D.C. plating, circuitry, even whole bionic limbs from Earth), which the nanites integrate into the more advanced Kremin body until it is as good as new. The traditional vest and cowl is a soft M.D. metal with the look of thin vinyl (25 M.D.) and is repaired the same way, even when ripped to shreds." }
  - { name: "Energy Fist", description: "Studs behind each hand''s knuckles generate a field: a 4D6 M.D. punch, or a short blast of 2D6, 3D6 or 4D6 M.D. as desired to 500 feet (152 m); limited to four punches or two blasts per melee round, however many attacks the character has, while the field recharges." }
  - { name: "Multi-Weapon Blade", description: "Every Kremin carries one by tradition; it strongly resembles a Japanese short sword: cuts like a vibro-blade for 2D6 M.D., stuns by touch (5D6 S.D.C., victim knocked down, loses two melee attacks and initiative), or fires a 6D6 M.D. blast to 1200 feet (366 m), 12 blasts before recharging in its special sheath." }
  - { name: "Bionic Systems of Note", description: "Finger jack and headjack, amplified hearing, built-in language translator (speaks every Earth language at 96%), full optics, molecular analyzer, voice amplification, built-in radio receiver and transmitter, laser finger tool, climb cord, 1D4 secret compartments and three more features of choice (any, including weapons). A Kremin may acquire any cybernetics or bionics available in North America." }
restrictions:
  - "A race that takes an O.C.C.: the experience table and skill program are those of the chosen O.C.C., and the R.C.C. skills are kept in addition to it. The Kremin''s own standard equipment joins the O.C.C.''s, and a player character starts with the Kremin''s 1D4x1000 credits of tradeable goods."
  - "Clearly a cyborg; disguise is impossible."
  - "Magic: none. Psionics: none. Magic and psionic O.C.C.s are out of the question."
  - "The Coalition States have a standing order to destroy every Kremin on sight; thanks to the CS, Kremin are widely believed to be hostile alien invaders on the run."
  - "Also starts with a satchel, some personal items and the Multi-Weapon Blade (a natural ability here); the vibro-katana stands for the one long, Japanese-style Vibro-Sword (3D6 M.D.) the book lists."
extraction_notes: "Until an earlier update the class followed Rifts World Book 11: Coalition War Campaign printed 209-211; it now follows Rifts World Book 30: D-Bees of North America printed 111-114 (stat block on 113-114), the newer printing, by the ruling of 2026-10-04. Both entries were read off page renders; D-Bees printed 113-114 was read again, off the book''s OCR text cache, for the shape change. What follows this first part is the Coalition War Campaign record, corrected below where D-Bees prints another figure. || Shape: D-Bees printed 113 heads the entry Optional Player Character or NPC, lists Available O.C.C.s, says to use the experience table of the chosen O.C.C., and prints the R.C.C. skills as in addition to any skills acquired via an O.C.C. The class now takes that shape (BOOK-INGEST-AUDIT.md F141; no saved character was on the class): no xp_table, no MOS and no related or secondary skills, so a character levels on its occupation''s ladder and takes its occupation''s skill program. Unlike the Krak beside it (printed 111: Standard Equipment and Money as per O.C.C.), D-Bees printed 113 prints the Kremin''s own Standard Equipment, in addition to its bionic systems, and 1D4x1000 credits of tradeable goods for player characters, so equipment_starting and starting_money stay: in a pairing the race''s gear joins the occupation''s and the race''s money is the one the character starts with. No yields_to_occupation, pairing_skills or pairing_counts: the page prints no cut. || Available O.C.C.s, D-Bees printed 113: just about any Adventurer or Scholar O.C.C. or basic soldier or law enforcement O.C.C., Combat Cyborg, Headhunter and military O.C.C.s rare, magic and psionics out of the question. Stored as except the magic and psychic groups, with the clergy group beside them as the quick-flex-alien and vanguard-brawler conversions store a race printed with no magic; the rare ones are allowed and named in the note. || D-Bees revisions taken: M.A. 3D6+2 (Coalition War Campaign printed 209 gave 3D6). The stored physical line is the one D-Bees prints for explorers, law enforcement officers and combat based Kremin: P.S. 2D6+24 (Coalition War Campaign printed 209 gave 22+1D6), Spd 4D6+108 (Coalition War Campaign printed 209 gave a fixed 132), P.P. 1D4+22 and P.B. 1D6+6 unchanged. D-Bees also prints a civilian line (P.S. 1D6+20, P.P. 1D6+16, P.B. 1D6+8, Spd 2D6+77), the civilian M.D.C. reductions and a level-of-conversion table; these are prose in the Civilian Kremin natural ability. I.Q., M.E., the M.D.C. by location, Horror Factor 9 and P.P.E. 1D4 are the same in both books. || Bonuses: D-Bees printed 113 adds +1 melee attack (adults only), +2 to disarm, +1 to entangle and +3 to pull punch, none of which Coalition War Campaign prints; all four are stored in bonuses.combat, the attack on the reading that a played Kremin is an adult. The Horror Factor ladder and the psionic blocker saves are the same in both books. || R.C.C. skills, D-Bees printed 113: native language 98%, literate in it at 96% flat, Math: Basic +25% (stored 70), Philosophy +15% (stored 45), W.P. Sword, and Hand to Hand Basic for civilians and Expert for explorers and lawmen, Expert kept (Coalition War Campaign printed 210: Hand to hand: expert). Skills are catalog base plus printed bonus. || Not stored since the F141 conversion, Coalition War Campaign''s skill program and ladder: printed 210 says the Kremin''s skills are fundamentally the same as the CS Technical Officer of the Rifts RPG, and the class carried that row''s program (Rifts Ultimate Edition p.236-237): Military Etiquette 55, Computer Operation 55, Pilot Hover Craft 60, Radio: Basic 55, Running, W.P. Energy Pistol and W.P. Energy Rifle; one MOS of seven (Communications, Electrician, Mechanic, Robotics, Technician, Medic, Weapons), each a fixed skill list plus a pick from its categories; three related skills from Communications (any, +5%), Domestic, Medical, Military, Physical, Pilot, Pilot Related, Rogue, Science, Technical and W.P., plus one at levels 3, 6, 8, 10, 12 and 15; and three secondary skills plus one at levels 4, 8 and 12. The page says to use the ''Borg experience table, which is in the Rifts RPG; since 2026-09-26 the class had carried it, copied from combat-cyborg (RUE printed 295): 0, 2,101, 4,201, 8,401, 17,201, 25,401, 35,801, 51,001, 71,201, 96,401, 131,601, 181,801, 232,001, 282,201, 342,401. D-Bees restates neither. || Bionics: the Energy Fist blast is 2D6, 3D6 or 4D6 M.D. as desired (Coalition War Campaign printed 210 gave 4D6 only); D-Bees prints 1D4 secret compartments and three features of choice (Coalition War Campaign printed 210 gave various secret compartments), a 25 M.D. vest and cowl, and any additional cybernetics. The bionics are the race''s own and stay with the class in every pairing. The translator''s 96% in every Earth language and the lines Hit Points not applicable and S.D.C. a mega-damage cyborg are Coalition War Campaign only; D-Bees does not restate them and calls Kremin partial (55%) or full conversion (45%) cyborgs. || Equipment, D-Bees printed 113: 1D6 sets of clothing, a canteen and one long Japanese-style Vibro-Sword (3D6 M.D.) are added to the Coalition War Campaign list; the sword is stored as the Vibro-Katana row (Rifts World Book 8: Japan printed 117, 3D6 M.D.), the catalog row matching the printed description and damage. The satchel and personal items stay prose. Money: both books print 1D4x1000; D-Bees words it as credits worth of tradeable goods. || Other D-Bees lines, not stored as fields: alignments any, with Principled 25%, Scrupulous 35%, Unprincipled 15% and Anarchist 15% common (Coalition War Campaign printed 209 gave unknown, most anarchist and unprincipled); life span 5D6+70 years; males 8 feet and 600-800 pounds, females 7 feet and 400-500 pounds (Coalition War Campaign gave 8 feet, 600 pounds); slave market value 2D4x10,000; NPC experience level 2D4; 20,000-30,000 Kremin refugees are loose in North America after 109 P.A., where Coalition War Campaign knew three dozen explorers. The Lore and GM Notes below are still the Coalition War Campaign account. || COALITION WAR CAMPAIGN RECORD: Read from printed 209-211 (cache p210-p212); the stat block on printed 209, the M.D.C. locations, bionics and bonuses on printed 210 and the 1D4x1000 credits on printed 211 were checked against 200 dpi renders. || Attributes: P.S. 22+1D6 and P.P. 22+1D4 are stored as rolled dice; P.E. is printed not applicable (N/A); Spd is a fixed 132. || M.D.C.: by location; mdc_base holds the main body''s 280 and the other locations are listed as a natural ability. No hit points, no S.D.C., so no men_of_arms line. || Bonuses: the psionic blockers give +2 vs psionic attack, +3 vs illusions and hypnosis (saves.other) and +6 vs possession, unconditional. The page heads the horror-factor line R.C.C. Skills but it is a save bonus: +1 at levels 2, 4, 6, 8, 10, 12, 14. || Equipment: the utility belt, backpack (the satchel printed beside it is not stored), tool kit, flashlight and an Earth energy weapon of choice; the Multi-Weapon Blade and energy fists are built in and are natural abilities, not gear. Psionics none: psionics_allowed false."
---

## Lore

The Kremin are alien cyborg explorers who came through a Rift, drawn by
Earth''s magic and its many life forms. Minutes after they arrived their
homeworld reported that the dimensional portal was tearing itself apart, so
the explorers are stranded until it can be repaired. Confident of rescue, they
carry on their mission to observe strange new worlds. They say they are
peaceful ambassadors, fight mostly in self-defence and keep their distance
from humans and D-bees alike, but nobody really knows what they want. Their
bionics are a little more advanced than Triax''s.

Every Kremin is a partial or full conversion cyborg, so a Kremin can be just
about any adventurer, scholar, basic soldier or lawman: Cyber-Doc, Operator,
Rogue Scholar, Rogue Scientist, Vagabond and Wilderness Scout are common.

## GM Notes

Alignment unknown; most seem anarchist or unprincipled, and their brain
implants block any reading of their thoughts. Eight feet, 600 lbs. Only
about three dozen came through; the CS has destroyed and dissected nine and
orders the rest shot on sight, so they have fled to the western wilderness,
Texas, Minnesota, Free Quebec and Michigan. Perhaps 30, at most 100, roam
the Americas. They favor heavy weapons, variable lasers and vibro-blades.

Experience table and skill program are those of the chosen O.C.C. NPCs are
level 2D4 or as set by the Game Master; player characters start at level one.
',
       updated_at = datetime('now')
 WHERE class_id = 'kremin-cyborg'
   AND instr(markdown, 'Select one area of specialty, as the CS Technical Officer does.') > 0
   AND length(markdown) = 18311;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'kremin-cyborg' AND instr(markdown, 'no xp_table, no MOS and no related or secondary skills') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'kremin-cyborg' AND instr(markdown, 'Select one area of specialty, as the CS Technical Officer does.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('kremin-cyborg') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~267-book-ingest-audit-f141-kremin.sql');
