-- BOOK-INGEST-AUDIT F141: the Vanguard Brawler takes the race-that-takes-an-O.C.C. shape D-Bees of North America prints
-- 1 class, each replaced whole: vanguard-brawler.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~266-book-ingest-audit-f141-vanguard.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == vanguard-brawler ==
UPDATE imported_classes
   SET markdown = '---
id: vanguard-brawler
name: Vanguard Brawler
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.208-210
category: rcc
tags: [combat]
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+4"
  PP: "3d6+4"
  PE: "4d6+4"
  PB: "2d6"
  Spd: "3d6"
mdc_base: "P.E. x2, +1d6 per level"
ppe_base: "1d6"
horror_factor: 11
psionics_allowed: false
occ_restrictions:
  except: ["group:psychic", "group:clergy", "group:magic", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "mega-juicer", "phaeton-juicer", "titan-juicer", "ninja-juicer", "crazy", "ultra-crazy", "ninja-crazy"]
  note: "Drawn to physical rather than intellectual O.C.C.s: Bandit, Gunfighter, Gunslinger, City Rat (any), Headhunter, Highwayman, Pirate, Sailor, Saloon Bum, Bounty Hunter, Master Assassin, Safecracker, Smuggler, Professional Thief, Freelance Spy, Super-Spy, Sheriff, Saddle Tramp, Merc Soldier, Vagabond, Vagabond Fighter/Street Thug, and most any soldier or criminal O.C.C. No interest in magic (Magic: None), nor in scholarly occupations such as Body Fixer, Rogue Scientist or Operator, nor Professional Gambler, Glitter Boy or Robot Pilot. Cannot become a Juicer or Crazy: the alien physiology is incompatible."
bonuses:
  combat: { initiative: 2, attacks: 1, disarm: 1, roll: 2, pull_punch: 2 }
  saves: { disease: 1, toxins_poisons: 1, possession: 1, horror_factor: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Boxing", base: 0, per_level: 0, note: "R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Roadwise", base: 46, per_level: 4, note: "+20%. R.C.C. skill, kept whatever the chosen O.C.C." }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%. R.C.C. skill, kept whatever the chosen O.C.C." }
natural_abilities:
  - { name: "Robotic Strength", description: "P.S. is equivalent to Robot Strength; damage is as per Robot Strength or by weapon." }
  - { name: "Mega-Damage Hide", description: "Tough, scaly M.D.C. skin; a physically powerful mega-damage creature." }
  - { name: "Keen Hearing and Smell", description: "Tracks by scent at 30% +2% per level, +10% to follow a blood scent. A natural climber." }
  - { name: "Infrared Vision", description: "Sees the infrared spectrum of light." }
  - { name: "Back Spines", description: "Two rows of 3-6 hook-like spines; anything leaping onto its back impales or gouges itself. Their shape is unique to each Brawler and identifies individuals." }
  - { name: "Hardy", description: "The high P.E. makes most Brawlers resistant to magic, disease and poison." }
restrictions:
  - "A race that takes an O.C.C.: the experience table, standard equipment and money are those of the chosen O.C.C., and Climbing, Boxing, Roadwise and Streetwise are kept whatever that O.C.C. is."
  - "Hand to Hand: D-Bees prints an upgrade to Expert, Martial Arts or Assassin for the cost of only ONE O.C.C. Related Skill, regardless of what the O.C.C. might allow. In a pairing the app prices Hand to Hand off the chosen O.C.C.''s own list (Nate, 2026-10-12, for every race), so the G.M. applies this price by hand."
  - "Clearly inhuman: disguise is difficult, and the Brawler is a target of human supremacists."
  - "The back spines make it difficult to wear full human body armor or clothing without costly customization."
  - "Cannot become a Juicer or Crazy: the alien physiology is incompatible. Partial bionic reconstruction is fairly common; most who undergo full conversion become incredibly bitter and mean."
  - "90% are completely illiterate."
  - "The aggressive nature can work against them, and a Brawler is bored out of its mind after a day or two of sitting still or routine work."
extraction_notes: "Followed Rifts World Book 11: Coalition War Campaign printed 206-208 until this update; brought to the Rifts World Book 30: D-Bees of North America printing, printed 208-210 (cache p209-p211), under the ruling of 2026-10-04 that the newest printing stating a figure wins. Both entries were read off 170 dpi renders; D-Bees printed 209 was read again, off the book''s OCR text cache, for the shape change. || Shape: D-Bees prints no Thug R.C.C.: the entry is headed Optional Player Character and NPC, an O.C.C. is chosen, four R.C.C. skills are kept regardless of it, and Standard Equipment, Money and the experience table are as per the chosen O.C.C. The class now takes that shape (BOOK-INGEST-AUDIT.md F141; no saved character was on the class): no xp_table, no starting_money, no equipment_starting and no related or secondary skills, so a character levels on its occupation''s ladder and takes its occupation''s equipment, money and skill program. No yields_to_occupation, pairing_skills or pairing_counts: D-Bees prints the four R.C.C. skills as kept regardless of the O.C.C. and prints no cut. || R.C.C. skills, D-Bees printed 209: Climbing (+20%), Boxing, Roadwise (+20%), Streetwise (+20%), and the Hand to Hand upgrade to Expert, Martial Arts or Assassin for ONE O.C.C. Related Skill, regardless of what the O.C.C. might allow, stored as the hand_to_hand price list. D-Bees gives Boxing outright, so the Thug list''s Boxing or Wrestling pick is gone with the rest of the Thug program. Skills are catalog base plus printed bonus. || Not stored, Coalition War Campaign''s Vanguard Brawler Thug R.C.C. (printed 206-208, ladder printed 224): Native Tongue 98%, American and one language of choice (+20%), Basic Math +20%, Land Navigation +15%, Find Contraband +15%, Intelligence +16%, Streetwise +16%, Track (humanoids) +10%, Pilot Hover Vehicle +10%, W.P. Energy Rifle, one W.P. of choice, Prowl +10%, Body Building, Boxing or Wrestling, Gymnastics or Acrobatics, Climbing as a natural 68/56% +2% per level, and Hand to Hand: Expert, changed to Martial Arts or Assassin (if evil) for one R.C.C. Related skill; five related skills from Communications +5%, Domestic, Electrical, Espionage, Mechanical (Basic only) +5%, Medical (First Aid only), Military +10%, Physical, Pilot, Rogue +6%, Science (Math only), Technical +10%, W.P. and Wilderness, Pilot Related none, plus two at levels 2, 5, 8 and 12; five secondary skills plus one at levels 3, 6, 9 and 12; light body armor (stored as the Urban Warrior), utility belt, backpack or satchel, flashlight, language translator, knife and a pair of energy pistols of choice; 1D4x1000 credits; and the Thug R.C.C. ladder, headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist (lower bounds 0, 2,051, 4,101, 8,401, 16,801, 24,561 printed, 35,801, 50,401, 70,801, 95,401, 130,801, 180,401, 230,801, 280,401, 331,401 printed; the class stored levels 6 and 15 as 25,561 and 331,801 so the bands did not overlap). The class carried all of it until the F141 conversion; the Coalition War Campaign Note''s American +20% and one other +10% was the O.C.C. path. || Revisions taken from D-Bees: Streetwise +20%; Climbing +20%, stored 60 and 5; +1 to disarm; P.S. equivalent to Robot Strength, damage as per Robot Strength (Coalition War Campaign printed 206 gave plain P.S. 4D6+4); 90% completely illiterate (Coalition War Campaign printed 208 gave 70%); disguise difficult (Coalition War Campaign printed 206 gave impossible); Magic None (Coalition War Campaign printed 206 gave by O.C.C. only), so the magic group joins the O.C.C. exceptions; alignments Anarchist 33%, Aberrant 20%, Miscreant 26%, Diabolic 15% (Coalition War Campaign printed 206 gave 33% anarchist and 66% evil); 500,000 to 800,000 in North America (Coalition War Campaign printed 206 gave less than half a million). Roadwise is new in D-Bees. || M.D.C.: P.E. x2 plus 1D6 per level in both books, a mega-damage creature, so mdc_base and no men_of_arms line. || Bonuses: +2 initiative, +1 attack, +1 disarm, +2 roll, +2 pull punch, +1 save vs disease and poison (disease and toxins_poisons), +1 vs possession; horror factor +1 at levels 1, 2, 3, 4, 5, 6, 8, 10, 12, 14. || Available O.C.C.s: D-Bees names physical O.C.C.s and most any soldier or criminal O.C.C., and prints the rest as dislikes (magic, scholarly occupations, Professional Gambler, Glitter Boy, Robot Pilot) except Juicer and Crazy, which it prints as cannot. Stored as except psychic (psionics none), clergy and magic (Magic: None) plus every Juicer and Crazy conversion O.C.C. by id; the dislikes are in the note. The F141 conversion looked every id up on production and added the three it lacked (Ninja Juicer, Ultra-Crazy, Ninja Crazy). The Maxi-Killer, built for bodies the human process kills, is left allowed, and so is the Juicer Wannabe, who is not yet augmented. Full conversion is avoided, not forbidden, so no cyborg O.C.C. is excluded. Coalition War Campaign printed 207 gave most any Men of Arms, scholar or adventurer O.C.C. || XP: D-Bees printed 209 says to use the experience table of the chosen O.C.C. NPC experience level 2D4 (D-Bees). Psionics none in both books: psionics_allowed false. || Not stored, D-Bees printed 209-210: average life span 3D6+48 years, slave market value 1D6x10,000 credits."
---

## Lore

Vanguard Brawlers are notorious street-gang bosses who hire out as bounty
hunters, slavers, hit men, enforcers, bouncers, bodyguards and mercenaries,
and gather in family clans and gangs of their own kind. They are tough,
streetwise thugs who win with fists, violence and intimidation, yet they are
also cunning strategists and capable leaders in a kingpin way. Their scaly
blue-green hide is mega-damage, though only good for a few blasts, and two
rows of hooked spines run down the back. As many as 500,000 to 800,000 live
in North America, most in the American Midwest and the Domain of Man.

Every Brawler takes an occupation, nearly always a physical one: bandit,
gunfighter, city rat, bounty hunter, assassin, smuggler, thief, spy, sheriff,
mercenary or street thug, and most any soldier or criminal trade.

## GM Notes

Alignment any, but Anarchist (33%), Aberrant (20%), Miscreant (26%) and
Diabolic (15%) are the norm. Six to seven
feet, 220 to 320 lbs. They like rail guns, plasma and other heavy weapons,
vibro-blades and magic weapons. Poorly paid for labor, they do well as
mercenaries and thugs.

Experience table, standard equipment and money are those of the chosen
O.C.C. NPCs are level 2D4 or as set by the Game Master; player characters
start at level one.
',
       updated_at = datetime('now')
 WHERE class_id = 'vanguard-brawler'
   AND instr(markdown, 'The category stays rcc and the Thug R.C.C. package stays stored') > 0
   AND length(markdown) = 12838;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'vanguard-brawler' AND instr(markdown, 'The class now takes that shape (BOOK-INGEST-AUDIT.md F141') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'vanguard-brawler' AND instr(markdown, 'The category stays rcc and the Thug R.C.C. package stays stored') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('vanguard-brawler') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~266-book-ingest-audit-f141-vanguard.sql');
