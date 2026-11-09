-- BOOK-INGEST-AUDIT F141: the Quick-Flex Alien takes the race-that-takes-an-O.C.C. shape D-Bees of North America prints
-- 1 class, each replaced whole: quick-flex-alien.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~265-book-ingest-audit-f141-quick-flex.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == quick-flex-alien ==
UPDATE imported_classes
   SET markdown = '---
id: quick-flex-alien
men_of_arms: false
name: Quick-Flex Alien
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.168-170
category: rcc
tags: [stealth]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6+6"
  PE: "3d6"
  PB: "2d6"
  Spd: "6d6+25"
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "2d6"
psionics_allowed: false
occ_restrictions:
  except: ["group:magic", "group:psychic", "group:clergy", "combat-cyborg", "cs-cyborg-strike-trooper", "destroyer-borg", "fq-cyborg-soldier", "fq-cyborg-dervish", "fq-cyborg-imprimer", "fq-cyborg-leviathan", "fq-cyborg-slasher", "mining-borg", "ngr-cyborg-soldier", "ojahee-borg", "plains-borg", "republic-cyborg-soldier", "cyborg-shocktrooper", "ninja-borg", "warlord-heavy-machine", "warlord-light-machine", "dragon-borg-wing-blade", "dragon-borg-tsunami", "dragon-borg-imperial-combat", "dragon-borg-flame-cloud", "geofront-demon-eater-geo-borg", "geofront-assault-geo-borg", "geofront-lion-geo-borg", "luftwaffe-cyborg-combat-pilot", "crazy", "ultra-crazy", "ninja-crazy", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "maxi-killer", "mega-juicer", "phaeton-juicer", "titan-juicer", "ninja-juicer"]
  note: "Limited to physically oriented O.C.C.s: Bandit, Bounty Hunter, City Rat, Cyber-Knight, Gunfighter, Gunslinger, Headhunter, Highwayman, Merc Soldier, Soldier (any), Sailor, Pirate, Pecos Raider, Professional Thief, Master Spy, Super Spy, Smuggler, Saddle Tramp/Drifter, Vagabond (any), Wilderness Scout (any), and any adventurer, lawman or soldier type O.C.C. that does not require dramatic bionic conversion (partial and a few implants is okay) or other physiological change (no Juicer or Crazy). Robot Pilot is acceptable but rarely chosen; fast-vehicle specialists are favored. They NEVER study magic."
bonuses:
  pools: { sdc: "3d6" }
  combat: { initiative: 2, attacks: 1, perception: 3, strike: 1, parry: 2, automatic_dodge: 3, roll: 2, pull_punch: 2 }
skills:
  occ_skills:
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American (+20%); the catalog has no American row." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One language of choice (+10%)." }
    - { name: "Combat Driving", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%. R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "W.P. Quick Draw", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
natural_abilities:
  - { name: "Hyperactive Reflexes and Speed", description: "Higher metabolism, enhanced reflexes and great running speed, roughly equal to a Juicer or Crazy. Ambidextrous: uses both hands with equal skill, precision and agility." }
  - { name: "Double-Jointed", description: "Can pop joints, which aids in slipping out of confinement, rope and the like." }
  - { name: "Leaping", description: "Leaps eight feet (2.4 m) high or across from a standstill, four feet (1.2 m) more with a running start." }
  - { name: "Automatic Dodge", description: "+3 to automatic dodge: roll to dodge as usual, but the act of dodging does not use up a melee attack." }
special_abilities:
  - name: "Gunman''s Eye"
    description: "+1 to strike using modern weapons and guns or any type of bow and arrow, even if the character does not have a W.P. in that weapon. This is on top of the +1 to strike that always applies."
restrictions:
  - "A race that takes an O.C.C.: the experience table, standard equipment and money are those of the chosen O.C.C., and the R.C.C. skills are in addition to the O.C.C.''s."
  - "Short attention span, skill penalty: -10% on all skills (regardless of O.C.C. bonuses) except those in the categories of Espionage, Physical, Pilot, Rogue and W.P."
  - "Magic: none. The attention deficit makes the study of magic too demanding; they NEVER study magic."
  - "Bionics: avoided, because they slow the D-bee down."
  - "Most Quick-Flex are illiterate (Coalition War Campaign: 90%)."
side_effects: "Thrill-seekers who enjoy a fast pace and taking risks. A bit jumpy and hyper; cannot sit still for more than 1D4 hours; easily bored."
extraction_notes: "Originally Rifts World Book 11: Coalition War Campaign printed 205-206; the class followed that printing until the update to Rifts World Book 30: D-Bees of North America printed 168-170 (ruling of 2026-10-04: the newest printing that states a figure wins, and the older figure is kept in a note). Both books were read off page renders (D-Bees cache p169-p171, Coalition War Campaign cache p206-p207); D-Bees printed 169 was read off a render again for the shape change. || Shape: D-Bees prints the race with an O.C.C. always - R.C.C. skills in addition to those of the chosen O.C.C., Use the experience table of the chosen O.C.C., Standard Equipment as per O.C.C., Money as per O.C.C. - and does not restate the Quick-Flex Rogue R.C.C. that Coalition War Campaign printed as the alternative to an optional O.C.C. The class now takes that shape (BOOK-INGEST-AUDIT.md F141; no saved character was on the class): no xp_table, no starting_money, no equipment_starting, no related or secondary skills and no hand to hand block, so a character levels on its occupation''s ladder and takes its occupation''s equipment, money, hand to hand and skill program. No yields_to_occupation, pairing_skills or pairing_counts: D-Bees prints the R.C.C. skills as in addition to the O.C.C.''s and prints no cut. || Not stored, Coalition War Campaign''s Quick-Flex Rogue R.C.C. (printed 205-206, ladder printed 224): the nine Rogue skills (Land Navigation +10%, Find Contraband +10%, Prowl +10%, a Physical skill of choice, Streetwise +14%, Pick Locks +20%, Pick Pockets +15%, W.P. Energy Pistol, W.P. Automatic Pistol or Sub-machinegun); Hand to Hand: Basic, changed to Expert for one R.C.C. Related skill or to Martial Arts (or Assassin if evil) for two; six related skills from Communications, Domestic +5%, Electrical (Basic only) +5%, Espionage (Sniper and Wilderness Survival only), Mechanical (Basic only) +5%, Medical (First Aid only), Military (Etiquette and Recognize Weapon Quality only) +10%, Physical, Pilot, Rogue +6%, Science (Math only), Technical +5%, W.P. and Wilderness, Pilot Related none, plus one at levels 3, 6, 10 and 14; six secondary skills plus one at levels 3, 7 and 10; light body armor, utility belt, backpack or satchel, flashlight, language translator, knife and a pair of energy pistols of choice; 1D6x100 credits; and the Quick Flex Rogue R.C.C. ladder (lower bounds 0, 2,301, 4,601, 9,201, 18,401, 26,501, 36,601, 51,701, 74,801, 100,901, 140,001, 193,101, 235,201, 290,401, 350,601). The class carried all of it until the F141 conversion. Coalition War Campaign also exempted the Rogue R.C.C.''s own skills and related skills from the skill penalty. || Unchanged between the two printings: the eight attribute dice, hit points P.E. plus 1D6 per level, S.D.C. 3D6 plus physical skills and O.C.C. (a pool bonus, men_of_arms false, a race), P.P.E. 2D6, psionics none, magic none, the eight-foot leap plus four feet from a run, weight 100-150 pounds. || Bonuses, D-Bees printed 169: +1 attack, +2 initiative, +3 Perception Rolls, +1 to strike, +2 to parry, +3 to automatic dodge, +2 roll with impact, +2 pull punch are stored; +1 to strike with modern weapons/guns or any bow even without the W.P. is conditional and is the Gunman''s Eye special ability. Coalition War Campaign printed 205 gave +2 initiative, +1 attack, +1 strike with modern weapons/guns or bow and arrow, +2 roll, +2 pull punch, paired weapons and automatic dodge (same as the Commando hand to hand ability) with no figure; it printed no Perception, no general strike and no parry bonus. || R.C.C. skills, D-Bees printed 169: Combat Driving, Escape Artist (+20%), W.P. Paired Weapons, W.P. Quick Draw and W.P. Targeting, plus American (+20%) and one language of choice (+10%), both through Language: Other. Combat Driving, W.P. Quick Draw and W.P. Targeting are new in D-Bees; Coalition War Campaign printed paired weapons among the bonuses and Escape Artist (+20%) in the Rogue list. Languages: the Coalition War Campaign Rogue list printed American and one language of choice (+20%); its closing Note printed American (+20%) and one of choice (+10%), the figures D-Bees prints. || Available O.C.C.s: D-Bees names a list of physically oriented O.C.C.s plus any adventurer, lawman or soldier type that needs no dramatic bionic conversion or other physiological change (no Juicer or Crazy), and says they never study magic. Stored as except the magic, psychic and clergy groups plus every published Juicer, Crazy and full-conversion cyborg O.C.C. by id; the named list is in the note. The F141 conversion looked every id up on production and added the eight full-conversion cyborg O.C.C.s it lacked (the four Dragon-Borgs, the three Geo-Borgs and the Luftwaffe Cyborg Combat Pilot); the Songjuicer is already closed by its magic group, and the Juicer Wannabe is a gang member who is not yet augmented and stays open. Coalition War Campaign printed 206 gave any Men of Arms, scholar or adventurer O.C.C. and said Juicer and Crazy conversions will work with life expectancy 25% less than usual. || Skill penalty: D-Bees gives -10% on all skills except the Espionage, Physical, Pilot, Rogue and W.P. categories; Coalition War Campaign printed 205 gave -10% except physical and rogue skills. D-Bees adds that the character cannot sit still for more than 1D4 hours. || Natural abilities: D-Bees adds double-jointed and spells out ambidextrous; Coalition War Campaign named ambidextrous in the description only. || Size: D-Bees 5 feet 4 inches to 5 feet 10 inches (1.6 to 1.75 m); Coalition War Campaign 5 to 5 feet 6 inches (1.5 to 1.65 m). Alignments: D-Bees any, leaning Scrupulous 20%, Unprincipled 30%, Anarchist 30%; Coalition War Campaign any. Literacy: D-Bees says most are illiterate; Coalition War Campaign said 90%. NPC experience level 2D4+1 (D-Bees). The lore and GM notes carry the D-Bees size, alignment and armor preference (light or medium body armor or Naruni force fields; Coalition War Campaign said light body armor or a Naruni force field). Psionics none: psionics_allowed false."
---

## Lore

The Quick-Flex Alien is the classic D-bee: at a glance it passes for human,
until you notice the large eyes, long face and pinhole nose. A racing
metabolism keeps them small, rarely over five feet ten, and makes them
alert, agile and startlingly fast, with reflexes to match a Juicer and both
hands equally good. That makes them superb gunmen, snipers, thieves, pilots
and acrobats. They love adventure, fast vehicles and tattoos. About a
million live across North America, mostly in the Midwest.

Every Quick-Flex Alien takes an occupation, nearly always a physical one:
gunfighter, bandit, bounty hunter, spy, smuggler, scout, soldier or
vagabond, and best of all the one who drives something fast.

## GM Notes

Any alignment, leaning scrupulous (20%), unprincipled (30%) and
anarchist (30%). Five feet four to five feet ten, 100 to 150 lbs. Most have
forgotten their native tongue; nine in ten are illiterate scavengers,
vagabonds, thieves, mercenaries or adventurers. Burbs wages are pitiful.
They favor pistols and vibro-knives, and light or medium armor or a Naruni
force field over anything that slows them.

Experience table, standard equipment and money are those of the chosen
O.C.C. NPCs are level 2D4+1 or as set by the Game Master; player
characters start at level one.
',
       updated_at = datetime('now')
 WHERE class_id = 'quick-flex-alien'
   AND instr(markdown, 'The category stays rcc and the Rogue R.C.C. material is kept as Coalition War Campaign printed it') > 0
   AND length(markdown) = 13398;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'quick-flex-alien' AND instr(markdown, 'The class now takes that shape (BOOK-INGEST-AUDIT.md F141') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'quick-flex-alien' AND instr(markdown, 'The category stays rcc and the Rogue R.C.C. material is kept as Coalition War Campaign printed it') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('quick-flex-alien') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~265-book-ingest-audit-f141-quick-flex.sql');
