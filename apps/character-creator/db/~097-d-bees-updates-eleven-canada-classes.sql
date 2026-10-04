-- Eleven Canada classes follow their D-Bees of North America printing.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~097-d-bees-updates-eleven-canada-classes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~097-d-bees-updates-eleven-canada-classes.sql
--
-- The third of four batches (see ~095 for the ruling and the rule applied
-- where D-Bees is silent): the eleven classes held from Rifts World Book 20:
-- Canada (1999) that Rifts World Book 30: D-Bees of North America (2007)
-- reprints and updates.
--
--   centaur                  D-Bees printed 44-45   (Canada 102-103)
--   cyber-horsemen-of-ixion  D-Bees printed 51-54   (Canada 103-107)
--   true-sasquatch           D-Bees printed 173-176 (Canada 162-166)
--   worldly-sasquatch        D-Bees printed 176-177 (Canada 166)
--   aardan-tek               D-Bees printed 9-11    (Canada 130-132)
--   grackle-tooth            D-Bees printed 97-98   (Canada 133-134)
--   greot-hunter             D-Bees printed 98-100  (Canada 135)
--   mastadonoid              D-Bees printed 134-135 (Canada 137)
--   noli-bushman             D-Bees printed 144-146 (Canada 137-138)
--   yeno                     D-Bees printed 215-217 (Canada 139-140)
--   faerie-bot               D-Bees printed 76-79   (Canada 149-152)
--
-- Each was read against BOTH books off page renders by one reader and
-- checked against renders again by another that did not write it: no wrong
-- figure in eleven classes. None changes shape. Canada's own experience
-- ladders (printed 192) come off the Centaur and the Cyber-Horsemen, which
-- D-Bees sends to the chosen O.C.C.'s table; the two Sasquatch classes take
-- the Merc Soldier's ladder and the Faerie Bot the Techno-Wizard's, each
-- copied from the catalog's own class, as D-Bees directs.
--
-- Readings a page does not settle, each stated in its class's notes:
--   centaur         +4 damage stored unconditionally: D-Bees separates it
--                   from "+2 to dodge when running" with a comma, where
--                   Canada joined the two with "and".
--   true-sasquatch  Land Navigation is printed "(24%)" and "(26%)" with no
--                   plus sign, alone among the skills; stored as bonuses,
--                   since a flat figure would fall below the skill's own
--                   base. Save vs disease is printed +5 and +2 on different
--                   lines, and pull punch +5 and +4; +5 is stored for each.
--   grackle-tooth   D-Bees adds "+1 attack" to the bonus line while keeping
--                   the tail's extra attack; read as the tail restated.
--   yeno            D-Bees gives it Hit Points and S.D.C., and moves Canada's
--                   M.D.C. figure to the force field.
--   noli-bushman    the psionic package D-Bees prints on the race is a
--                   pick-one group, because D-Bees tells a Psi-Druid or
--                   Psi-Slayer to ignore it.
--
-- Each draft reads `ready` in class-check --remote. Two display-only ability
-- names change because D-Bees's text does (cyber-horsemen-of-ixion,
-- faerie-bot); no pick-one option or variant is renamed. Production held no
-- saved character on any of the eleven when this was written.
--
-- Each UPDATE is guarded on the class's old source_book line and on the
-- exact stored length (trailing newline counted). THIS SCRIPT CHANGES
-- PRODUCTION: eleven class rows. The tilde number is claimed at merge.

-- == centaur ==
UPDATE imported_classes
   SET markdown = '---
id: centaur
name: Centaur
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.44-45
category: rcc
tags: [wilderness, combat]
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "2d6"
  MA: "2d6"
  PS: "3d6+6"
  PP: "3d6+6"
  PE: "3d6+12"
  PB: "3d6"
  Spd: "6d6x2"
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "4d6"
horror_factor: 10
occ_restrictions: { except: ["glitter-boy", "robot-pilot"], note: "A Centaur may select any Men at Arms O.C.C. except Glitter Boy, Robot Pilot and similar, or an Adventurer O.C.C." }
bonuses:
  combat: { initiative: 2, perception: 1, strike: 1, damage_bonus: 4, pull_punch: 2, roll: 2 }
  saves: { disease: 2, horror_factor: 2 }
  pools: { sdc: 50 }
skills:
  occ_skills:
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elven at 98%. Half of all Centaurs are also literate in it; that is the G.M.''s call and is not granted." }
    - { name: "Language: Other", base: 60, per_level: 0, note: "Faerie Speak (+10%), a named tongue the catalog has no row for, stored the way the catalog stores every named tongue: a fixed percentage. The book says all the R.C.C. skills increase with experience; add 5% per level by hand." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One language of choice, typically American (+15%)." }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "Printed as W.P. Bow and Arrow." }
    - { name: "Prowl", base: 60, per_level: 1, note: "Natural ability: 60% +1% per level of experience." }
    - { name: "Swimming", base: 50, per_level: 0, note: "Natural ability: swim 50%." }
equipment_starting:
  - { choose: 1, label: "bow", qty: 1, from: ["long-bow-rifts", "modern-composite-bow"] }
  - { item_id: "arrows-standard", qty: 1, note: "Printed as one bow and arrows; no count is given. The row is a dozen." }
  - { choose: 1, label: "Vibro-Blade (often built into a spear)", qty: 1, from: ["vibro-spear", "vibro-knife", "vibro-sword"] }
  - { item_id: "hunting-knife", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two water skins or canteens." }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
natural_abilities:
  - name: "Speed and leaping"
    description: "Spd is 6D6x2 and doubles for brief spurts lasting 2D4 minutes, used for charging attacks, rescues and quick retreats. 25 to 30 mph (40 to 48 km) is the average speed of a Centaur and 50 mph (80 km) the fastest. Great speed and endurance: a Centaur can travel at half its maximum Spd or do heavy labor for four hours before needing to rest for 3D6+20 minutes. Leaps 10 feet (3 m) high and 15 feet (4.6 m) across; a running start doubles the length and adds 50% to the height."
  - name: "Track by sight"
    description: "77% +1% per level of experience."
  - name: "Hoof attacks"
    description: "A kick with the front legs does 2D6 S.D.C. plus the P.S. damage bonus (if any); a kick with the rear legs does 4D6 S.D.C. plus the P.S. damage bonus. A power kick with the rear legs does 1D4x10 S.D.C. plus the P.S. damage bonus, but counts as two melee attacks. Use the Horsemanship: Knight skill for damage bonuses with a weapon from a charge attack. Otherwise as per P.S. or weapon."
  - name: "Bonuses when running"
    description: "+2 to dodge when running, which is conditional and so is not in the bonuses block. No penalties for shooting guns or bow and arrow while running."
  - name: "Man at Arms attack"
    description: "Attacks per melee are as per the Hand to Hand Combat skill and bonuses. Any Centaur who is a Man-at-Arms O.C.C. gets +1 attack per melee; it is conditional on the O.C.C. and so is not in the bonuses block."
  - name: "No natural armor"
    description: "M.D.C. only through M.D.C. body armor or barding, typically captured from humanoids or made from the skins, bones and plating of M.D.C. creatures such as Fury Beetles and dinosaurs. No natural A.R. Few wear full barding; most wear partial M.D.C. armor."
side_effects: "Cannot live in captivity. Even a few weeks in chains or a cage may kill a Centaur or push it into desperate escape attempts."
trackable_resources: []
restrictions:
  - "Alignment: any, but Principled (25%), Scrupulous (30%), Unprincipled (15%) and Anarchist (15%) are most typical."
  - "The book heads the race an optional player character or NPC."
  - "Magic: by O.C.C. only, and rare. Psionics: the same chance as humans."
  - "Cybernetics and bionics: most try to avoid them."
  - "With any O.C.C., halve the number of O.C.C. Related Skill and Secondary Skill selections. The R.C.C. skills are kept. Not enforced by the picker."
  - "Available O.C.C.: the most typical are Wilderness Scout, Trapper-Woodsman, Highwayman, Bounty Hunter, Cowboy, Justice Ranger, Tundra Ranger and Saddle Tramp, or the equivalent of an Indian Tribal Warrior, Spirit Warrior, Mystic Warrior (Spirit West) or Shaman (Canada). A Centaur may select any Men at Arms O.C.C. (except Glitter Boy, Robot Pilot and similar) or an Adventurer O.C.C. Only Glitter Boy and Robot Pilot themselves are refused by the picker."
  - "They tend to avoid the study of magic and any O.C.C. that needs long hours of study or staying in one place. A Centaur mage is rare, and is typically a Mystic, Druid or Elemental Fusionist. Not enforced by the picker."
  - "Experience: use the experience table of the chosen O.C.C. to determine level advancement. Equipment and money are as per the O.C.C., plus the R.C.C. equipment."
extraction_notes: "This class followed Rifts World Book 20: Canada printed 102-103 until this update; by the ruling of 2026-10-04 the newest printing that states a figure wins, so it now follows Rifts World Book 30: D-Bees of North America printed 44-45 (cache p045-p046, cache page = printed folio + 1). Both entries, and the Canada Experience Tables on printed 192, were read off page renders. The D-Bees entry starts under the heading Centaur R.C.C. in the first column of printed 44, after the Cactus People experience table, and ends at the foot of printed 45 with a note that the Centaur also appears in World Book 20: Canada and Conversion Book One. || HEADING: D-Bees heads the block Centaur - Optional Player Character or NPC; Canada printed 102 gave Optional Player Character, Villain & NPC. || ALIGNMENT: D-Bees prints any, but Principled (25%), Scrupulous (30%), Unprincipled (15%) and Anarchist (15%) are most typical; Canada printed 102 gave any, but mostly principled or other good alignments. || XP: D-Bees prints Use the experience table of the chosen O.C.C. to determine level advancement, so no xp_table is stored. Canada printed 192 gave the race its own column, Centaur R.C.C. & True Sasquatch R.C.C., with lower bounds 0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501 (level 15 ends at 326,500), and the class stored that ladder until this update. || ATTRIBUTES: identical in both books. D-Bees adds the average speed (25-30 mph, 50 mph the fastest); the doubling for spurts of 2D4 minutes is natural ability text. || POOLS: identical in both books. Hit Points P.E. attribute number +1D6 per level; S.D.C. 50 plus those from Physical skills, stored as a pool bonus of 50, not sdc_base; M.D.C. only through body armor or barding; P.P.E. 4D6; Horror Factor 10. Canada printed 102 also prints Natural A.R.: None, requires body armor or bionics; D-Bees does not restate that line and it is kept as natural ability text. men_of_arms false as a race. || BONUSES: D-Bees prints +2 on initiative, +1 to Perception Rolls, +1 to strike, +2 to dodge when running, +4 to damage, +2 to pull punch, +2 to roll with impact, +2 to save vs disease and +2 to save vs Horror Factor; no penalties for shooting guns or bow and arrow while running; and any Centaur who is a Man-at-Arms O.C.C. gets +1 attack per melee. Stored: initiative 2, perception 1, strike 1, damage_bonus 4, pull_punch 2, roll 2, disease 2, horror_factor 2. Canada printed 103 gave no Perception bonus. Canada printed 103 gave +4 to damage and +2 to dodge when running, which was read as one conditional phrase and neither figure was stored; D-Bees reorders the line so that when running follows the dodge alone and the +4 to damage stands by itself, so the damage is now stored and the dodge stays natural ability text. ATTACKS: D-Bees prints As per Hand to Hand Combat skill and bonuses, and gives the extra attack to a Man-at-Arms O.C.C. only; Canada printed 103 gave Those gained from Hand to Hand Combat training plus one as natural warriors, for every Centaur, which was stored as attacks 1. The attack is now natural ability text because it depends on the occupation. || DAMAGE: front kick 2D6 S.D.C. and rear kick 4D6 S.D.C. plus the P.S. damage bonus, as in Canada. D-Bees adds a Power Kick with the rear legs, 1D4x10 S.D.C. plus the P.S. damage bonus, counting as two melee attacks, and says to use the Horsemanship: Knight skill for damage bonuses with a weapon from a charge attack. The line points at the Horsemanship: Knight skill for its charge figures and does not grant the skill, so the sentence is natural ability text and no skill is added. || NATURAL ABILITIES: Prowl 60% +1% per level, track by sight 77% +1% per level, swim 50% and the leap figures are identical in both books; D-Bees adds travel at half maximum Spd or heavy labor for four hours before a rest of 3D6+20 minutes, where Canada printed 102 gave good to excellent natural speed, great physical endurance. Prowl and swim are stored as Prowl 60/1 and Swimming 50/0; track by sight is natural ability text because the catalog splits tracking into people and animals and the book says neither. || SKILLS: the R.C.C. skill line is the same list in both books: Hunting, Land Navigation +20% and Wilderness Survival +15% over the catalog base, W.P. Bow and Arrow (W.P. Archery), Dragonese/Elven 98% (Language: Dragonese at 98; 50% literate is note text, not granted), Faerie Speak +10% (Language: Other at 60 because the catalog has no Faerie Speak row) and one language of choice, typically American at +15% (a choice from Language: Other with +15). Both books print all increase with experience; the Faerie Speak entry is stored with no per-level gain all the same, because a named tongue with no catalog row is a fixed Language: Other throughout the catalog; its note says to add the gain by hand. || EQUIPMENT: the equipment line is the same in both books: as per O.C.C. plus one bow and arrows, Vibro-Blade (often built into a spear), hunting knife, two water skins or canteens (stored as two canteens), saddlebag, backpack, bandoleer, utility belt, headband, one large sack, two small. The bow is a choice of long bow or modern composite bow, the two kinds Canada printed 103 names in its skill line (All traditionalists are excellent archers and favor the long bow, or modern composite bow); D-Bees does not restate that sentence and names no kind of bow. The arrows row is arrows-standard, count unprinted. Headband has no catalog row and is not granted. Money: D-Bees prints As per O.C.C.; Canada prints no money line; none is stored. || AVAILABLE O.C.C.: D-Bees prints the most typical occupations, then However, a Centaur may select any Men at Arms (except Glitter Boy, Robot Pilot and similar) or Adventurer O.C.C., and that a mage is rare and typically a Mystic, Druid or Elemental Fusionist. Stored as occ_restrictions except glitter-boy and robot-pilot, the two the line names; and similar names no class and is restriction prose. No only list is stored, because the line still allows the rare mage. Canada printed 103 gave no exception: Most are Wilderness Scouts, Trapper-Woodsmen or the equivalent of Indian Tribal Warrior, Spirit Warrior, Mystic Warrior and Shaman; Druid and Mystic the most likely mages; and those who forsake tribal life (about 20% of the population) can become virtually any man at arms, favoring Ranger, Wilderness Scout, Highwayman, Bounty Hunter, Justice Ranger, Tundra Ranger (ideally Cavalry) and Saddle Tramp, as well as Rogue Scholar, wandering Vagabond/Peasant and Cowboy, Cowboy and Scout among the most common. D-Bees restates the line without the 20% sentence. The halving of O.C.C. Related and Secondary selections is in both books and is restriction prose. || MAGIC AND PSIONICS: D-Bees prints By O.C.C. only; rare, and Same chance of as humans; Canada printed 102 gave By O.C.C. only, and Standard; same as humans. D-Bees adds Cybernetics and Bionics: Most try to avoid them. || NOT STORED: size 6 to 7 feet at the horse shoulders, about 10 feet head to hoof, and weight 800 to 1100 pounds (identical in both books); average life span 4D6+66 years (Canada printed 102 gave 90 years, although some have lived to 130); NPC experience level 1D8; slave market value 2D4x10,000 credits; the population of as many as 260,000 (Canada printed 102 gave over 200,000 in Alberta, Saskatchewan, Idaho and Montana and less than 60,000 elsewhere); disposition, allies, enemies, habitat. They are in GM Notes."
---

## Lore

Centaurs are the horse-bodied people of old Earth legend: a human head,
arms and torso rising from the shoulders of a large, powerful horse. Where
they first came from nobody remembers. On other worlds they are known as
feared warriors of the open plains who live in tribal clans and never stay
anywhere much longer than a season. They are capable craftsmen, but a life
on the move seldom leaves them a forge or a proper set of tools.

On Rifts Earth they live much like the plains tribes of the past. Most are
found in Alberta, Saskatchewan, Montana and Idaho, with smaller numbers in
British Columbia, Washington and Oregon. A clan may be a few dozen strong or
several hundred, guided by one or two shamans at most. Grassland is the
country they love best, though demons, predators and hostile humanoids have
pushed many clans into the western forests, where they have made friends of
the Ixion and trade with the Simvan. To stay alive they have taken up
Mega-Damage weapons: Vibro-Blades, modern bows, energy rifles and
Techno-Wizard devices.

Hard experience has taught them to treat two-legged folk as a likely
threat, and many clans keep their distance. Yet a Centaur is a born
wanderer who loves adventure and a close fight. Young ones out to prove
themselves, and rogues weary of clan life, will ride with small bands of
adventurers, mercenaries or raiders, or with the Tundra Rangers.

## GM Notes

The book heads the race an optional player character or NPC, and notes
that the Centaur also appears in Rifts World Book 20: Canada and Rifts
Conversion Book One. Centaurs are also known as the Pony Men and the Horse
People. As many as 260,000 are believed to roam the plains of Alberta,
Saskatchewan, British Columbia, Washington, Oregon, Montana and Idaho.

Conditional bonuses the sheet does not add: +2 to dodge when running, and
+1 attack per melee for a Centaur who is a Man-at-Arms O.C.C. There are no
penalties for shooting guns or bow and arrow while running.

With any O.C.C., halve the O.C.C. Related and Secondary skill selections;
the R.C.C. skills are kept in full. Half of all Centaurs are also literate
in Dragonese/Elven. A headband is part of the printed equipment and has no
catalog row. Level advancement uses the experience table of the chosen
O.C.C. NPCs are experience level 1D8 or as set by the Game Master; player
characters should start at first level.

Size 6 to 7 feet (1.8 to 2.1 m) at the horse shoulders and about 10 feet
(3 m) from head to hoof. Weight 800 to 1100 pounds (360 to 495 kg). Average
life span 4D6+66 years; physical maturity comes by the age of 12.

Disposition: inquisitive, adventurous, compassionate and caring, with a
wanderlust and a need to explore.

Rivals and enemies: they dislike Psi-Stalkers and Bruutasaurs, generally
fear and distrust humans and all two-legged people, and hate Worm Wraiths,
demons and monsters. Allies: faerie folk are very fond of them (few are
believed to live in western Canada outside British Columbia), and they get
on well with the Simvan, Cyber-Horsemen, traditional Native Americans,
Sasquatch, Cyber-Knights (some Centaurs are Cyber-Knights), Justice Rangers
and Tundra Rangers. Habitat is the plains and light forests of southwestern
Canada and the American Northwest; they avoid the North in the cold and
snowy months and love the tundra in summer, and a Centaur may travel
anywhere on the continent. Slave market value 2D4x10,000 credits: they are
valued as warriors, scouts and cargo transporters, and many have tried to
enslave them for labor or the arena, but a Centaur cannot survive
captivity.
',
       updated_at = datetime('now')
 WHERE class_id = 'centaur'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.102-103') > 0
   AND length(markdown) = 10212;

-- == cyber-horsemen-of-ixion ==
UPDATE imported_classes
   SET markdown = '---
id: cyber-horsemen-of-ixion
name: Cyber-Horsemen of Ixion
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.51-54
category: rcc
tags: [augmented, combat]
men_of_arms: false
attribute_dice:
  IQ: "2d6+8"
  ME: "1d6+8"
  MA: "1d6+12"
  PS: "3d6+8"
  PP: "3d6+8"
  PE: "2d6+12"
  PB: "1d6+8"
  Spd: "7d6x2"
hit_points_base: "P.E. x2 + 1d6 per level"
ppe_base: "3d6"
horror_factor: 12
psionics_allowed: false
occ_restrictions:
  except: ["group:magic", "group:psychic", "group:clergy", "glitter-boy", "robot-pilot"]
  note: "Most (75%) are Combat Cyborgs or Headhunters (any), but an Ixion can be any Men at Arms O.C.C. except Glitter Boy or Robot Pilot, and may also choose any Adventurer and Scholar O.C.C. Theoretically an Ixion could even become a Juicer, but none have ever done so. A few have become Cyber-Knights and Wilderness Scouts. No magic and no psionics."
bonuses:
  combat: { attacks: 1, initiative: 3, parry: 1, disarm: 1, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 3 }
  pools: { sdc: 40 }
skills:
  occ_skills:
    - { name: "Dowsing", base: 40, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Ixion at 98%. The book adds 95% Literacy in this language too; that is the G.M.''s call and is not granted." }
    - { name: "W.P. Pole Arm", base: 0, per_level: 0, note: "+1 to strike with spear and pole arm, in addition to W.P. bonuses." }
    - { name: "Prowl", base: 50, per_level: 2, note: "Natural ability: 50% +2% per level of experience, -30% if bionic. Impossible in bionic barding." }
equipment_starting:
  - { item_id: "ixion-energy-weapon-rod", qty: 1, note: "As per O.C.C. plus one energy rod, spear or pole arm." }
natural_abilities:
  - name: "Upper and lower body"
    description: "Hit Points are the P.E. attribute number x2, +1D6 per level, and S.D.C. is 40 plus those from Physical skills. The rolled P.S. of 3D6+8 is the body with no bionics; the P.S. of a bionic upper body is 2D6+20 and the P.S. of the bionic lower horse body is 2D6+28. Great speed and endurance; otherwise on par with humans."
  - name: "M.D.C. by location"
    description: "Bionic hands (2) 18 each*; bionic arms (2) 45 each*; bionic front legs (2) 110 each*; bionic rear legs (2) 160 each; main body (bionic horse) 250; barding (armor for the horse section) 125 additional M.D.C. to the main body; upper bionic body (when applicable) 100; upper body bionic armor 90 additional M.D.C.; head/helmet 70* (double that amount for a bionic head). An asterisk marks a small, difficult target: -4 to strike for the attacker. Bionic barding increases overall weight by 50%, reduces running speed by 25% and makes prowl impossible."
  - name: "Speed and leaping"
    description: "Natural Spd is 7D6x2, doubled for brief spurts of 2D4 minutes. Bionic Spd: males 220 (150 mph/240 km), females 88 (60 mph/96 km), but females may have the same speed as males if they are warriors or scouts. Without bionics the leap is 10 feet (3 m) high and 15 feet (4.6 m) across; a bionic leap is 30 feet (9 m) high and 50 feet (15.2 m) across by the natural abilities line (the bionic combat augmentation line prints 30 feet high or 70 feet across). A running start doubles the length and adds 50% to the height."
  - name: "Bionic reconstruction"
    description: "Among young females the lower body of the horse is reinforced with bionic legs and joint supports, including the hip and thigh areas; they may also get bionic arms and any number of implants and enhancements. Only one third get full lower body conversion before the age of 60, and none before 40. Most males have the upper body augmented by age 17 and the entire or the majority of the horse body replaced with a bionic one between the ages of 25 and 35; it houses the internal organs and answers to the slightest thought as naturally as flesh. Bionic weapons: at least one weapon for each bionic arm, weapon rods being particularly common."
  - name: "Bionic combat augmentation"
    description: "+1 on initiative and +1 to strike with a kick. Printed in the bionics section, so it applies to a bionic body; the sheet does not add it."
  - name: "Damage from bionic limbs"
    description: "As per bionic P.S., +1D6 M.D. from rear kicks. Otherwise by weapon."
  - name: "Standard bionic body features"
    description: "A hip holster on either or both hips (pistol or Mini-Energy Weapon Rod); attachments for snap-on body armor; one medium to large concealed compartment on the front hip or behind the back; a language translator built into the head and one or more optic and sensory implants; a bionic lung."
  - name: "Additional bionics"
    description: "The player picks three cybernetic implants and two bionic features. The horse body has room for as many as four concealed weapons and six large secret compartments on the upper legs and body trunk. Retractable blades can go in the hooves or lower legs, and in the arms of a full conversion Cyber-Horseman. More can be bought during the character''s life. The picker does not offer these; choose them with the G.M."
  - name: "Bonus when running"
    description: "+3 to dodge when running. Conditional, so the sheet does not add it."
  - name: "Bonus with spear and pole arm"
    description: "+1 to strike with spear and pole arm, in addition to W.P. bonuses. Conditional, so the sheet does not add it."
trackable_resources: []
restrictions:
  - "Alignment: any, but they lean toward Principled (10%), Scrupulous (40%), Unprincipled (10%) and Anarchist (25%)."
  - "The book heads the race an optional player character or NPC."
  - "Magic: none, other than the acquisition of magic items and Lore skills; no Ixion has tried to learn magic because bionics interfere with and block it. Psionics: none."
  - "Available O.C.C.s: most (75%) are Combat Cyborgs or Headhunters (any), but an Ixion can be any Men at Arms O.C.C. except Glitter Boy or Robot Pilot, and may also choose any Adventurer and Scholar O.C.C."
  - "Experience: use the experience table of the chosen O.C.C. to determine level advancement. Money is as per O.C.C."
  - "Vulnerabilities: stealth and disguise are pretty much impossible."
  - "The Ixion do not sell or trade their weapon rods, and no Cyber-Horseman can be made to reveal the city''s location, population or defenses."
extraction_notes: "Until this update the class followed Rifts World Book 20: Canada printed 103-107; it now follows Rifts World Book 30: D-Bees of North America printed 51-54, the newer printing, by the ruling of 2026-10-04 (the newest printing that states a figure wins, and the older figure is kept here). D-Bees closes its entry by noting the Ixion first appeared in Rifts Conversion Book One and later in Rifts World Book 20: Canada. Both entries were read off page renders: D-Bees cache p052-p055 (cache page = printed folio + 1), Canada cache p104 and p106-p108, and the Canada experience tables on cache p193. In D-Bees the heading Cyber-Horsemen is on printed 51, the stat block headed Cyber-Horsemen - Optional Player Character or NPC starts on printed 52 and ends on printed 54 above the Darkhound. || UNCHANGED between the two printings: I.Q. 2D6+8, M.E. 1D6+8, M.A. 1D6+12, P.S. 3D6+8 for the flesh upper body (D-Bees words it no bionics), P.P. 3D6+8, P.E. 2D6+12, P.B. 1D6+8, natural Spd 7D6x2 doubled for 2D4 minutes, bionic Spd 220 and 88, S.D.C. 40 plus Physical skills (a pool bonus of 40; men_of_arms false as a race), P.P.E. 3D6, Horror/Awe Factor 12, rear legs 160 M.D.C. each, main body 250, size, weight, natural Prowl 50% +2% per level (-30% if bionic), the 10 by 15 foot leap without bionics, the 30 by 50 foot bionic leap, Land Navigation +15%, Wilderness Survival +10%, Ixion at 98%, the bonuses +3 initiative, +1 parry, +1 disarm, +3 pull punch, +1 roll with impact, +3 vs Horror Factor and +3 to dodge when running, one attack beyond Hand to Hand, the bionic combat augmentation, the five standard body features, the additional bionics, and the three weapons. || HIT POINTS: D-Bees printed 52 gives P.E. attribute number x2, +1D6 per level; Canada printed 105 gave P.E. attribute number +1D6 per level. || BIONIC P.S.: D-Bees printed 52 gives a bionic upper body P.S. of 2D6+20 and a bionic lower horse body P.S. of 2D6+28. Canada printed 105 gave 3D6+22 for the lower bionic horse-body and no bionic upper body figure, and its bionics section (printed 106) gave a male''s bionic body a P.S. equivalent of 40 and Spd of 220; D-Bees restates that paragraph without the P.S. equivalent. The stored P.S. die is the 3D6+8 of the body without bionics, as before; the bionic figures are natural ability text. D-Bees adds that females may have the same bionic speed as males if they are warriors or scouts, and says Males where Canada said Most males. || M.D.C. BY LOCATION: D-Bees printed 53 gives bionic hands 18 each, bionic arms 45 each, front legs 110 each, rear legs 160 each, main body (bionic horse) 250, barding 125 additional M.D.C. to the main body, upper bionic body (when applicable) 100, upper body bionic armor 90 additional M.D.C., head/helmet 70 (double for a bionic head), with hands, arms, front legs and head asterisked as small targets at -4 to strike. Canada printed 105 headed the list M.D.C. of Lower Body by Location and gave front legs 100 each, rear legs 160 each, main body (horse) 250 and upper body (body armor) 130, with bionic barding raising those numbers and overall weight by 50%; D-Bees keeps the 50% weight, the 25% speed loss and prowl impossible, and gives barding the flat 125. The figures belong to the bionic body and armor, not the being, so no mdc_base is stored; they are natural ability text. || NATURAL ABILITIES: D-Bees restates the line without Canada''s females with augmentation can leap 40% higher and farther (printed 105), so it is removed, and adds great speed and endurance and otherwise on par with humans. THE BOOK STILL CONTRADICTS ITSELF: the natural abilities line prints a bionic leap of 30 feet high and 50 feet across (printed 53) and the bionic combat augmentation line prints 30 feet high or 70 feet across (printed 54), as Canada did on printed 105 and 106. Both are in the natural ability text. || DAMAGE: D-Bees prints Damage as per bionic P.S. or weapons, and Damage from Bionic Limbs as per Bionic P.S. +1D6 M.D. from rear kicks. Canada printed 107 gave, for a female, front kick 4D6+25 S.D.C., rear kick 6D6+25 S.D.C. and a rear power kick 1D4 M.D. counting as two attacks; for a male, front kick 1D6 M.D. plus P.S. damage bonus, rear kick 2D6 M.D. plus P.S. damage bonus, double damage from a power kick counting as two melee attacks, and body block, ram or swipe 1D4 M.D. D-Bees restates the line without them. || BONUSES: D-Bees printed 53 adds +1 to strike with spear and pole arm (in addition to W.P. bonuses), which Canada does not print; it is conditional and is natural ability text and the W.P. Pole Arm note. D-Bees lists +1 attack per melee among the bonuses and prints Attacks per Melee as per Hand to Hand Combat skill and bonuses; Canada printed Hand to Hand plus one as natural warriors. Stored as attacks 1 either way. D-Bees adds a Vulnerabilities line (stealth and disguise are pretty much impossible), stored as a restriction. || PSIONICS AND MAGIC: D-Bees prints Psionics: None and Magic: None, other than the acquisition of magic items and Lore skills. Canada printed 105 gave Psionics: Standard; same as humans and Magic: By O.C.C. only. Stored as psionics_allowed false and the magic exclusion below. || R.C.C. SKILLS: D-Bees printed 53 gives, in addition to those of a chosen O.C.C., Dowsing (+20%, catalog 20, stored 40), Land Navigation (+15%, catalog 36, stored 51), Language: Native Tongue: Ixion 98% (95% Literacy in this language too), Wilderness Survival (+10%, catalog 30, stored 40) and W.P. Pole Arm. Dowsing is new in D-Bees. Canada printed 105 also gave two languages of choice (typically American as +20%), which was stored as a choice of two from Language: Other at +20, and W.P. Pole Arm/Spear, which was stored as both W.P. Pole Arm and W.P. Spear; D-Bees restates the line without the two languages and with W.P. Pole Arm alone, so the language choice and W.P. Spear are removed. Natural Prowl is stored as Prowl 50/2 with the bionic penalty in its note. || AVAILABLE O.C.C.s: D-Bees printed 53-54 gives most (75%) as Combat Cyborg or Headhunters (any), but any Men at Arms except Glitter Boy or Robot Pilot; theoretically a Juicer, though none have ever done so; a few have become Cyber-Knights and Wilderness Scouts; and any Adventurer and Scholar O.C.C. Stored as occ_restrictions except the magic, psychic and clergy groups plus glitter-boy and robot-pilot by id; a race states only or except and not both, so the two allowed groups are written as the three excluded ones. Canada printed 105 gave warriors as effectively the Cyborg O.C.C. but any modern O.C.C., leaning toward the Scholar and Adventurer O.C.C.s, and was stored as prose with no occ_restrictions. || EXPERIENCE: D-Bees prints use the experience table of the chosen O.C.C. to determine level advancement, so no xp_table is stored. Canada''s Experience Tables (printed 192) print a ladder in the column headed Anti-Robot Headhunter, Tundra Ranger Cavalry, Ixion Cyber-Horsemen, which the class carried until this update: lower bounds 0, 2,151, 4,301, 8,601, 18,601, 26,601, 36,601, 54,601, 75,601, 99,601, 135,601, 185,601, 240,601, 290,601, 343,601. || EQUIPMENT AND MONEY: D-Bees prints Standard Equipment as per O.C.C. plus one energy rod, spear or pole arm, stored as one ixion-energy-weapon-rod. Canada printed 105 gave as per O.C.C. plus one energy rod spear or pole arm and energy pistol, and said the Ixion make no human style guns other than one type of pistol-rod; the pistol was stored as ixion-mini-energy-weapon-rod. D-Bees restates the line without the pistol and without the pistol-rod clause, so that grant is removed. The Mini-Energy Weapon Rod and the Sensory Deprivation Web (ixion-sensory-deprivation-web) are described in both books and are not standard equipment. The weapon figures are the same in both books (rod 15 M.D.C., 1D6 or 2D6 M.D. blade, 3D6 M.D. blast, 1600 feet, 10 blasts; mini rod 2D6 M.D., 600 feet; web 3 M.D.C.); Canada''s line that the Bionic Centaurs generally avoid heavy weapons and rail guns is not restated. D-Bees prints Money: As per O.C.C.; Canada printed no money line, and none is stored. The standard bionic body features and the pick of three cybernetic implants and two bionic features are natural ability text, not gear; D-Bees adds one or more optic and sensory implants to the head feature. || CYBERNETICS AND BIONICS: D-Bees prints that young females may also get bionic arms and implants, that only one third get full lower body conversion before the age of 60 and none before 40, that most males have the upper body augmented by 17 and the horse body replaced between 25 and 35, and at least one weapon for each bionic arm with weapon rods particularly common. Its description gives 90% of males partial bionic conversion of the upper extremities at adolescence (age 14-18), most males the lower horse-body before 35, and 10-15% full conversion. Canada printed 103-106 gave 90% of males the lower horse-body replaced at adolescence, only 10% full conversion with at least one weapon in each bionic arm and enhanced optics, and only 25% of females the same extensive modification. No male/female variants are stored: the sexes differ in bionic Spd and age of conversion, which are prose. || NOT STORED AS FIELDS, D-Bees: alignment percentages (Canada printed most lean toward selfish and good alignments); average life span 6D6+140 years (Canada: 150 years, although some have lived to 220); maturity at 14, a foal every two or three years to the age of 70; experience level 1D10 or as set by the Game Master for NPCs, player characters start at first level; slave market value 4D4x10,000 credits; allies add other Centaurs and Psi-Ponies; enemies add concern about the Xiticix and the Vampire Kingdoms of Mexico; the city arrived about 120-140 years ago (Canada: 110-140). Canada headed the block R.C.C. and Optional Player Character, Villain and NPC; D-Bees heads it Optional Player Character or NPC. The class stays category rcc, a race that takes an O.C.C., in both printings."
---

## Lore

The Cyber-Horsemen are Centaurs who rebuild themselves with machinery. Most
people simply call them the Ixion (said eye-zon), after the city they are
rumored to have raised somewhere in the wilds of British Columbia. Their
own account is that Ixion stood on a world at the far side of the universe
until a ley line storm of terrible size dragged the whole city, people and
all, through a dimensional vortex to Rifts Earth, perhaps a century or more
ago. Hunters and trappers told stories of them for decades before a
Coalition patrol out of Iron Heart filmed a group near the Alberta Rockies
and proved the tales true.

Their technology trails the Coalition''s, but they are masters of
cybernetics and Mega-Damage alloys. Nine males in ten take bionic arms and
hands on reaching adolescence, and most trade the horse half of the body
for a powerful bionic one before the age of 35, keeping the head, torso and
organs as flesh under bionic armor. Most females choose lighter
reinforcement and sensory implants so that they can still bear children.
Full conversion is rare and mostly chosen by elders.

In mind and temper they are much like humans. They prize nobility, honor,
order and understanding, and believe fate carried their city here so that
they might unravel the secrets of the cosmos. Kind treatment by the Inuit
and the Cyber-Knights, and a later pact with the Tundra Rangers, left them
well disposed toward humans; D-Bees they trust far less. A friend once made
is a friend for life. Demons are their sworn enemy. Magic is new to them
and fascinates them, though none has tried to learn it.

## GM Notes

The book heads the race an optional player character or NPC, and notes
that the Ixion first appeared in Rifts Conversion Book One and later in
Rifts World Book 20: Canada. They are also called Cyber-Centaurs, Ixion or
Horsemen of Ixion.

The sheet rolls the upper body: P.S. 3D6+8, Hit Points and 40 S.D.C. The
bionic horse-body, its M.D.C. by location, its P.S. and its Spd (220 for
males, 88 for females) are listed under the natural abilities and are
not added. Nor are +3 to dodge when running, +1 to strike with spear and
pole arm, or the bionic combat augmentation (+1 initiative, +1 to strike
with a kick).

Each character also selects three cybernetic implants and two bionic
features with the G.M.

Gear in the catalog: the Ixion Energy Weapon Rod (granted), the Mini-Energy
Weapon Rod (ixion-mini-energy-weapon-rod, not granted) and the Sensory
Deprivation Web (ixion-sensory-deprivation-web, not granted). They also
like Vibro-Blades, Neural Maces and magic items, and can use human guns.

Conversion rates: 90% of males take partial bionic conversion of the upper
body at 14-18 and most have the lower body rebuilt before 35; 10-15% take
full conversion. Only a third of females take full lower body conversion
before the age of 60, and none before 40. 95% are literate in Ixion.

Size 7 to 8 feet (2.1 to 2.4 m) at the horse shoulders, 11-12 feet (3.3 to
3.6 m) head to hoof. Weight 1800 to 2400 pounds (810 to 1080 kg). Life span
6D6+140 years. NPCs are experience level 1D10. Slave market value
4D4x10,000 credits.

Enemies: demons first of all; they will join the forces of humanity
against the Calgary demons. They also dislike Psi-Stalkers, Greot Hunters,
Yeno, Worm Wraiths and other cruel beings, and the Simvan hate them as
rivals. Allies: Tundra Rangers, Cyber-Knights, Justice Rangers and humans
of the southwest and northwest. Never seen in the midwest or east. Unlike
ordinary Centaurs, they do not sicken in captivity.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyber-horsemen-of-ixion'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.103-107') > 0
   AND length(markdown) = 12643;

-- == true-sasquatch ==
UPDATE imported_classes
   SET markdown = '---
id: true-sasquatch
name: True Sasquatch
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.173-176
category: rcc
tags: [wilderness, stealth]
xp_table: [0, 1931, 3861, 7721, 15201, 21301, 31301, 41601, 53301, 73601, 103301, 140001, 190001, 240001, 290001]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+4"
  MA: "3d6+4"
  PS: "3d6+10"
  PP: "3d6+2"
  PE: "3d6+4"
  PB: "2d6+4"
  Spd: "3d6+8"
mdc_base: "P.E. x2, +1d6 per level"
ppe_base: "P.E. + 4d6, +6 per level"
horror_factor: 9
occ_restrictions: { only: ["worldly-sasquatch"], note: "The book prints Available O.C.C.s: None, unless a Worldly Sasquatch. The one occupation written for the race is the Worldly Sasquatch O.C.C. that follows it." }
bonuses:
  combat: { attacks_base: 2, initiative: 3, perception: 2, disarm: 3, pull_punch: 5, parry: 1, roll: 2, automatic_dodge: 1 }
  saves: { disease: 5, toxins_poisons: 2, possession: 2, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1, automatic_dodge: 1 } }
    - { level: 4, combat: { attacks: 1, automatic_dodge: 1 } }
    - { level: 6, combat: { automatic_dodge: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 8, combat: { automatic_dodge: 1 } }
    - { level: 10, combat: { attacks: 1, automatic_dodge: 1 } }
    - { level: 12, combat: { automatic_dodge: 1 } }
    - { level: 13, combat: { attacks: 1 } }
    - { level: 14, combat: { automatic_dodge: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 60, per_level: 5, note: "+20% for both sexes." }
    - { name: "Lore: Cattle & Animals", base: 50, per_level: 5, note: "+20% for both sexes." }
    - { name: "Tracking (people)", base: 45, per_level: 5, note: "+20% for both sexes, mainly to recognize tracks and avoid dangerous creatures and trouble with humanoids." }
    - { name: "Wilderness Survival", base: 70, per_level: 5, note: "+40% for both sexes." }
variants:
  - id: male
    name: "Male Sasquatch"
    bonuses:
      combat: { attacks_base: 4, initiative: 3, perception: 2, disarm: 3, pull_punch: 5, parry: 1, roll: 2, automatic_dodge: 1 }
      saves: { disease: 5, toxins_poisons: 2, possession: 2, mind_control: 2 }
      at_level:
        - { level: 2, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 4, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 6, combat: { automatic_dodge: 1 } }
        - { level: 7, combat: { attacks: 1 } }
        - { level: 8, combat: { automatic_dodge: 1 } }
        - { level: 10, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 12, combat: { automatic_dodge: 1 } }
        - { level: 13, combat: { attacks: 1 } }
        - { level: 14, combat: { automatic_dodge: 1 } }
    skills_additional:
      occ_skills:
        - { name: "Camouflage", base: 60, per_level: 5, note: "+40%." }
        - { name: "Land Navigation", base: 60, per_level: 4, note: "Printed (24%), with no plus sign; stored as a +24% bonus." }
        - { name: "Identify Plants & Fruit", base: 55, per_level: 5, note: "+30%." }
        - { name: "Prowl", base: 55, per_level: 5, note: "+30%." }
        - { name: "Swimming", base: 60, per_level: 5, note: "+10%." }
        - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Track Animals +20%." }
        - { choose: 1, from: ["W.P. Blunt", "W.P. Staff"], base: 0, per_level: 0, note: "W.P. Blunt or W.P. Staff." }
  - id: female
    name: "Female Sasquatch"
    bonuses:
      combat: { attacks_base: 3, initiative: 3, perception: 2, disarm: 3, pull_punch: 5, parry: 1, roll: 2, automatic_dodge: 1 }
      saves: { disease: 5, toxins_poisons: 2, possession: 2, mind_control: 2 }
      at_level:
        - { level: 2, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 4, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 6, combat: { automatic_dodge: 1 } }
        - { level: 7, combat: { attacks: 1 } }
        - { level: 8, combat: { automatic_dodge: 1 } }
        - { level: 10, combat: { attacks: 1, automatic_dodge: 1 } }
        - { level: 12, combat: { automatic_dodge: 1 } }
        - { level: 13, combat: { attacks: 1 } }
        - { level: 14, combat: { automatic_dodge: 1 } }
    skills_additional:
      occ_skills:
        - { name: "Camouflage", base: 70, per_level: 5, note: "+50%." }
        - { name: "Dance", base: 45, per_level: 5, note: "+15%." }
        - { name: "Dowsing", base: 40, per_level: 5, note: "+20%." }
        - { name: "Fishing", base: 60, per_level: 5, note: "+20%." }
        - { name: "Identify Plants & Fruit", base: 70, per_level: 5, note: "+45%." }
        - { name: "Land Navigation", base: 62, per_level: 4, note: "Printed (26%), with no plus sign; stored as a +26% bonus." }
        - { name: "Prowl", base: 45, per_level: 5, note: "+20%." }
        - { name: "Swimming", base: 70, per_level: 5, note: "+20%." }
        - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "Track Animals +10%." }
psionics:
  type: "master"
  powers: ["Empathy", "See The Invisible", "Sense Evil"]
  powers_starting: 0
special_abilities:
  - { choose: 1, from: ["Psionics of the Male Sasquatch", "Psionics of the Female Sasquatch"] }
  - name: "Psionics of the Male Sasquatch"
    description: "Take this with the Male Sasquatch variant. A low-end Master Psychic. Besides Empathy, See the Invisible and Sense Evil, every male has Empathic Transmission (limited to Confusion, Fear and Love/Peacefulness), Psionic Invisibility, Alter Aura and Deaden Senses, used mostly to hide or in self-defense. He develops Radiate Horror Factor at level 2, Intuitive Combat at level 4 and Psychic Omni-Sight at level 8. I.S.P.: M.E. attribute number x2, +1D8 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. attribute number x2, +1d8 per level of experience"
      powers: ["Empathic Transmission", "Psionic Invisibility", "Alter Aura", "Deaden Senses"]
      powers_starting: 0
      powers_schedule:
        - { level: 2, count: 1, from: ["Radiate Horror Factor"], note: "The Super power Radiate Horror Factor." }
        - { level: 4, count: 1, from: ["Intuitive Combat"], note: "Intuitive Combat." }
        - { level: 8, count: 1, from: ["Psychic Omni-Sight"], note: "Psychic Omni-Sight." }
  - name: "Psionics of the Female Sasquatch"
    description: "Take this with the Female Sasquatch variant. A low-end Master Psychic. Besides Empathy, See the Invisible and Sense Evil, every female has Sense Dimensional Anomaly (to avoid it), Sense Time, See Aura, Psychic Diagnosis, Psychic Purification and Psychic Surgery, plus two Healing powers of choice. She selects one more Healing power at levels 3, 6, 9 and 12, gains the Super power Bio-Regeneration (self) at level 5 and one Sensitive power of choice at level 8. I.S.P.: M.E. attribute number x2, +1D6+4 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. attribute number x2, +1d6+4 per level of experience"
      powers: ["Sense Dimensional Anomaly", "Sense Time", "See Aura", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery"]
      powers_starting: 2
      categories_allowed: ["Healing"]
      powers_starting_groups:
        - { count: 2, categories: ["Healing"], note: "Two Healing powers of choice." }
      powers_schedule:
        - { level: 3, count: 1, categories: ["Healing"], note: "One additional Healing power." }
        - { level: 5, count: 1, from: ["Bio-Regeneration (Super)"], note: "The Super power Bio-Regeneration (self)." }
        - { level: 6, count: 1, categories: ["Healing"], note: "One additional Healing power." }
        - { level: 8, count: 1, categories: ["Sensitive"], note: "One Sensitive power of choice." }
        - { level: 9, count: 1, categories: ["Healing"], note: "One additional Healing power." }
        - { level: 12, count: 1, categories: ["Healing"], note: "One additional Healing power." }
natural_abilities:
  - name: "Minor Mega-Damage creature"
    description: "Once an S.D.C. being, changed by the return of magic. M.D.C. is the P.E. attribute number x2 plus 1D6 per level of experience. Physical strength and endurance are supernatural, and damage is as per Supernatural Strength. On an S.D.C. world: Hit Points of P.E. +1D6 per level, 1D4x10+30 S.D.C. and a natural A.R. of 7."
  - name: "Senses"
    description: "Nightvision 300 feet (91.5 m), keen eyesight and hearing, and a heightened sense of smell: track by smell alone 40% +2% per level, recognize a scent 30% +4% per level."
  - name: "Hardy"
    description: "Cold does half damage, and wounds heal twice as fast as a human''s. The +5 to save vs disease, +2 to save vs poison and toxins and +2 to save vs possession and mind control are applied on the sheet."
  - name: "Special Telepathy"
    description: "Males and females alike speak mind to mind, but only with other Sasquatch. Range 600 feet (183 m), indefinite duration, no I.S.P. cost; it is as natural to them as talking. No more than three individuals can be called or spoken to at once."
  - name: "Automatic Dodge"
    description: "Dodging does not use up a melee action. +1 to automatic dodge at levels 1, 2, 4, 6, 8, 10, 12 and 14, applied on the sheet."
  - name: "Exceptional attributes"
    description: "When an attribute''s dice come up at their maximum (12 on two dice, 18 on three) roll one extra die, then add the printed bonus. Not rolled by the sheet."
side_effects: "Spooked by machines and city life, and avoids them. A wild Sasquatch held in a city or large town turns tense and irritable and then sinks into depression (attacks, bonuses and skills halved unless escaping) or becomes obsessed with getting away. The Worldly Sasquatch breaks after 26 hours +1 hour per M.E. point, doubled in a quiet town or a tranquil park; the ordinary woodland Sasquatch breaks in half that time."
trackable_resources: []
restrictions:
  - "Alignment: any, but typically Principled (45%), Scrupulous (35%), Unprincipled (15%), Anarchist (3%) or evil (any, 2%)."
  - "The book heads the race an optional player character and NPC."
  - "Choose the male or female variant AND the psionics of the same sex; the two picks must match. With neither variant the class carries the two attacks of a youngster of 16 or younger."
  - "Available O.C.C.s: none, unless a Worldly Sasquatch."
  - "No other skills are applicable, unless a Worldly Sasquatch."
  - "Magic: none."
  - "Cybernetics: none, of any kind, for any reason."
  - "Uses no tools, weapons, armor or clothing, and has no money and no need of it."
  - "Language: most do not speak and the race has no native tongue. They communicate by whistles, grunts, sign and body language, empathy and telepathy, but can learn other languages, typically American."
extraction_notes: "This class followed Rifts World Book 20: Canada printed 162-166 until it was brought up to the 2007 printing in Rifts World Book 30: D-Bees of North America printed 173-176 (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here). D-Bees cache p174-p177 (cache page = printed folio + 1) and Canada cache p165-p166 were read off page renders. The D-Bees entry is headed Sasquatch - Optional Player Character and NPC, also known as True Sasquatch; lore fills printed 173-174, the stat block printed 175 and the top of 176, and The Worldly Sasquatch O.C.C. that starts on printed 176 is its own class (worldly-sasquatch). || XP: D-Bees says to use the same Experience Table as the Merc Soldier; the ladder is copied from the stored merc-soldier class (Rifts Ultimate Edition). Canada printed 192 gave the Centaur R.C.C. & True Sasquatch R.C.C. ladder 0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501. || ATTRIBUTES, M.D.C., P.P.E., HORROR FACTOR: the same in both books. The S.D.C.-world figures and the roll-an-extra-die-on-a-maximum rule are natural ability text. Damage as per Supernatural Strength is D-Bees''s own line. || ATTACKS: D-Bees prints males start with four actions, females with three and youngsters (16 or younger) with two, +1 at levels 2, 4, 7, 10 and 13. Stored as attacks_base 4 on the male variant, 3 on the female variant and 2 on the class itself. Canada printed 165 gave two at first level for all. || BONUSES: D-Bees''s line is +3 initiative, +2 Perception Rolls, +3 disarm, +5 pull punch, +1 parry, +4 to pull punch, +2 roll with impact, +1 automatic dodge at levels 1, 2, 4, 6, 8, 10, 12 and 14, +2 save vs poison and +5 save vs disease. Pull punch is printed twice in that line, +5 and +4; +5 is stored (it is also Canada''s figure). The +2 Perception and the level 1 automatic dodge are new; Canada printed 165 gave no Perception bonus and automatic dodge from level 2. Each variant restates the whole bonus block beside its own attacks. || SAVE VS DISEASE: D-Bees prints it twice. The Bonuses line says +5 to save vs disease; the Natural Abilities line, carried over word for word from Canada, says +2 to save vs disease and toxins. +5 is stored; the other printed figure is +2, which is also what Canada printed 165 gave. Toxins and poison +2, possession and mind control +2 are the same in both. || SKILLS: D-Bees prints the R.C.C. skills as bonuses, and each base stored is the catalog base plus that bonus with the catalog per-level step. Male: Camouflage +40, Climb +20, Land Navigation (24%), Identify Plants and Fruits +30, Lore: Cattle & Animals +20, Prowl +30, Swimming +10, Track Animals +20, Track people +20, Wilderness Survival +40, and W.P. Blunt or W.P. Staff. Female: Camouflage +50, Climb +20, Dance +15, Dowsing +20, Fishing +20, Identify Plants and Fruits +45, Land Navigation (26%), Lore: Cattle & Animals +20, Prowl +20, Swimming +20, Track Animals +10, Track people +20, Wilderness Survival +40. Land Navigation is the one figure printed without a plus sign for either sex; it is stored as a bonus like the rest (36+24 = 60 male, 36+26 = 62 female). The four skills both sexes print at the same bonus (Climb, Lore: Cattle & Animals, Track people, Wilderness Survival) are the class''s own and the rest are on the variants. Track Animals is the catalog''s Track & Trap Animals; Track people is Tracking (people); Identify Plants and Fruits is Identify Plants & Fruit. Canada printed 165 gave flat figures: both sexes land navigation 90, wilderness survival 90, identify plants and fruits 90, swim 65; male climb 80/50, lore animal/cattle, camouflage and prowl 74 +2 per level, track animals 55 and track humanoids 45 improving only if selected again; female fishing 80, climb 70/40 +2 per level, and holistic medicine, first aid, lore animal/cattle, camouflage and prowl 60 +2 per level. D-Bees''s female line drops Holistic Medicine and First Aid and they are removed; it adds Dance, Dowsing, Track Animals and Track people, and the male line adds the W.P. || PSIONICS: D-Bees prints All Sasquatch are considered low-end Master Psychics, stored as type master, and an I.S.P. for each sex: males M.E. attribute number x2 +1D8 per level, females M.E. attribute number x2 +1D6+4 per level. Canada printed 165 gave no tier and no I.S.P. The powers and the levels they arrive at are the same in both books; D-Bees adds each power''s I.S.P. cost in parentheses. The three powers both sexes print are the class''s own block and each sex''s remainder, with its I.S.P., is one option of a pick-one special ability. Bio-Regeneration (Self) at level 5 is the catalog''s Bio-Regeneration (Super). || O.C.C.s: D-Bees prints Available O.C.C.s: None, unless a Worldly Sasquatch, below; Canada printed None. || MAGIC: D-Bees prints None. Canada printed 165 gave None, and never willing to learn it, although Worldly Sasquatch may use TW and other magic items. || LANGUAGE: D-Bees says typically American and a foundling probably American +15%; Canada said English in both places. || ALIGNMENT: D-Bees opens the line with Any, but typically; Canada gave typically, with Anarchist and evil rare. The percentages are the same. || NOT STORED: the Human or D-Bee Foundling rules are GM Notes; a foundling is another race and not this class. D-Bees adds Horsemanship: General and 1D6 Secondary Skills at the next level to what a worldly foundling selects. Size 7-8 feet, weight 250-400 lb, average NPC level 1D4+3, slave market value 2D6x1,000 credits (new in D-Bees), allies, enemies and habitat are GM Notes. Average life span is 2D6+40 years in D-Bees; Canada printed 165 gave 50 years. Family units are two to twelve with 2D6 children in D-Bees; Canada printed 164 gave two to ten with 2-6 children. Standard Equipment is nothing but a feather and perhaps a small sack or pouch, and Money is none, the same in both books; no equipment or money is stored. The Spirit Sasquatch (Canada printed 160-162) is NPC only and is not imported."
---

## Lore

Sasquatch, Big Foot, the Mammoth, the Old Man of the Woods: the names all
belong to one shy, fur-covered giant that most people take for a D-Bee or
a forest spirit. It is neither. The Sasquatch are distant Stone Age
cousins of humanity who walked out of Asia over the Bering land bridge
long ago and settled the forests of the Rocky Mountains. They outlasted
modern man by staying hidden, and the Cataclysm barely touched their
remote ranges. The return of magic did change them: once ordinary flesh,
they are now minor Mega-Damage beings, and their numbers have grown from
a thousand or two to more than ten thousand.

They live as nomads in single families of two to twelve, without tribes,
fire, shelter, tools, weapons or clothes. They eat roots, bark, berries,
mushrooms and fruit, take fish and crayfish by hand, and love honey and
maple syrup. They do not hunt. A Sasquatch answers a threat by avoiding
it, hiding from it or walking away, and insults mean nothing to one. When
forced to fight it does only enough to end the danger and escape.

For all their shyness they are curious and kind. They watch travelers from
the trees, steer children away from danger, lead the lost back to camp and
have been known to adopt an orphan. Among themselves they speak with
whistles, grunts, gestures and a private telepathy, and every one of them
is psychic: the males in ways that help them vanish, the females as
healers.

## GM Notes

The book heads the race an optional player character and NPC.

Pick the male or female variant, then the psionics ability of the same
sex. All Sasquatch are low-end Master Psychics: a male has I.S.P. of M.E.
x2 +1D8 per level, a female M.E. x2 +1D6+4 per level.

A Sasquatch family mates for life and a mated adult will not leave its
family, so an adventuring Sasquatch is an unattached youngster of 15-25 or
a widowed elder. See the Worldly Sasquatch O.C.C.

Human or D-Bee foundling: a child raised by Sasquatch has the same skills
and basic knowledge, plus 1D4+1 skills from Wilderness and/or Physical,
speaks little or no language (about 30%), and is unfamiliar with weapons,
tools and armor, though it probably wears skins or a poncho. It has its
own race''s natural abilities and not the Sasquatch''s Supernatural
Strength, natural abilities or psionics. A foundling who later becomes
worldly can add one language of choice (probably American at +15%), two
piloting skills, Horsemanship: General, two W.P.s and 1D4 skills from
Domestic and/or Technical, and 1D6 Secondary Skills on reaching the next
level of experience.

Size 7-8 feet (2.1 to 2.4 m). Weight 250 to 400 pounds (112.5 to 180 kg).
Average life span 2D6+40 years. NPCs average level 1D4+3, or as set by the
G.M.; player characters start at level one. Slave market value 2D6x1,000
credits, mainly as an oddity and labor.

Equipment: nothing but a feather worn in the hair and perhaps a small sack
or pouch for food and odds and ends. They like combs, pocket mirrors,
honey, jam, candy, sacks, purses and pouches, and leave food or water in
trade for what they take. Money: none.

Allies: other Sasquatch and the Spirit Sasquatch; now and then an Indian
Shaman, a Druid, a psychic or a kind adventurer. Enemies: none as such,
but every stranger is a possible one, and they fear and avoid supernatural
beings. Habitat: the forests of the Canadian Rockies in British Columbia
and Alberta and the deep woods of Washington, Oregon and Montana; fewer in
the Yukon, Idaho, Wyoming, Northern California and Colorado.
',
       updated_at = datetime('now')
 WHERE class_id = 'true-sasquatch'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.162-166') > 0
   AND length(markdown) = 16095;

-- == worldly-sasquatch ==
UPDATE imported_classes
   SET markdown = '---
id: worldly-sasquatch
name: Worldly Sasquatch
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.176-177
category: occ
tags: [wilderness]
occ_group: optional
men_of_arms: false
race_restrictions: { only: ["true-sasquatch"], note: "An occupation for a True Sasquatch who has entered the world of humans." }
xp_table: [0, 1931, 3861, 7721, 15201, 21301, 31301, 41601, 53301, 73601, 103301, 140001, 190001, 240001, 290001]
skills:
  occ_skills:
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: Other: American at +15%. This pick is the American one." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One more Language: Other of choice, at +10%." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P. skills, any." }
    - { choose: 2, categories: [{ name: "Communications", bonus: 5 }, { name: "Domestic", bonus: 5 }, "Medical", "Technical", { name: "Wilderness", bonus: 10 }], note: "1D4+1 skills from Communications (+5%), Domestic (+5%), Medical, Technical and Wilderness (+10%). Two are offered here, the lowest roll; roll 1D4+1 and add the rest by hand." }
    - { choose: 2, categories: [{ name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }, "Pilot"], note: "Horsemanship: General and Horsemanship: Exotic Animals, or two Piloting skills of choice. Take the two Horsemanship skills or two Pilot skills, not one of each." }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P." }
  - { item_id: "e-clip", qty: "1d4+1", note: "1D4+1 extra E-Clips." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { choose: 1, label: "waterskin or canteen", qty: 1, from: ["waterskin-half-gallon", "canteen"] }
  - { item_id: "utility-belt", qty: 1, note: "With many pouches; may have a bandoleer too." }
  - { item_id: "small-sack", qty: 1, note: "A few small sacks; the book gives no number." }
  - { item_id: "large-sack", qty: 1 }
trackable_resources: []
side_effects: "Even a Worldly Sasquatch is a woodland creature. Towns are confining; a city is noisy, ugly and dangerous, and an hour there is plenty. Forced to stay in a city or large town, the character grows tense and irritable and is likely to fall into deep depression (all attacks, bonuses and skills halved unless escaping the place) or to become obsessed with getting out, deserting friends and allies to do it. The breaking point comes after 26 hours +1 hour per M.E. point, doubled in a quiet town or a tranquil part of a city such as a park."
restrictions:
  - "True Sasquatch only. Usually an unattached youngster of 15-25 or an elder whose mate has died and whose children are grown; about 75% are male, and all are single."
  - "Skills: all the usual skills of the standard Sasquatch, but at -5%. The sheet does not take the 5% off; subtract it by hand."
  - "Will only keep company with groups of predominantly good alignment, and will not put up with Anarchist or evil associates for long."
  - "Armor: about two-thirds wear partial M.D.C. armor, with no helmet or shoes. Never full environmental armor."
  - "No vehicle or riding animal to start. Never keeps a beast of burden or a pet. Will ride in, or better on top of, a vehicle for short periods."
  - "About half learn to use a gun, most preferring a laser rifle. Seldom kills, for sport or in anger, and avoids taking even a villain''s life."
  - "Cybernetics: none. A few might accept a bio-system to stay alive or avoid being crippled; never implants, M.O.M. conversion, Juicer augmentation or any other unnatural procedure."
  - "Money: no figure is printed. Has little need for money and tends to spend it helping others, children above all."
extraction_notes: "This class followed Rifts World Book 20: Canada printed 166 (experience ladder printed 192) until this update; under the ruling of 2026-10-04 it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 176-177 (cache p177-p178, cache page = printed folio + 1). Every figure was read off page renders of both books. || D-BEES ENTRY: headed The Worldly Sasquatch O.C.C., it follows the Sasquatch entry (printed 173-176) and opens its stat block with Note: All stats are the same as above, except for the following - then R.C.C. Skills of the Worldly Sasquatch, Other Skills, Equipment, Money, Cybernetics, Allies, Enemies, and a closing note that it originally appeared in World Book 20: Canada. It prints no attribute requirements, no bonuses, no O.C.C. Related or Secondary skills, no skills gained by level and no Hand to Hand. || RACE: race_restrictions only true-sasquatch; the entry is an occupation for a Sasquatch who has left the wild, and the D-Bees Sasquatch entry (printed 175) says Available O.C.C.s: None, unless a Worldly Sasquatch. || GROUP: occ_group optional - the entry sits under no O.C.C. group heading in either book (in Canada it is in the Monsters of the North chapter under the True Sasquatch; in D-Bees it is inside the alphabetical Sasquatch entry); it states no sdc_base or mdc_base, so men_of_arms false, read off that same placement. The race supplies the M.D.C. || XP: D-Bees prints no ladder under the Worldly Sasquatch''s own name. Its Sasquatch entry (printed 175) says Use the same Experience Table as the Merc Soldier, and the Worldly entry takes all stats from that entry except the ones it lists, so xp_table is copied from the merc-soldier class as stored on 2026-10-04. Canada printed 192 gave a ladder of its own under the heading Worldly Sasquatch & Tundra Ranger Scout: 0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001. || SKILLS: both books print All the usual skills of the Sasquatch but at -5%; the race''s skills carry into the pairing at the race''s own figures and the -5% is NOT stored; it is a restriction line. D-Bees Other Skills line: Language: Other: American (+15%), +1 Language: Other of choice (+10%), Horsemanship: General and Exotic or two Piloting skills of choice, three W.P. skills (any), and 1D4+1 skills from Communications (+5%), Domestic (+5%), Medical, Technical and Wilderness (+10%). Stored as: two single picks of Language: Other at +15 and +10; a pick of three from Weapon Proficiencies; a pick of two (the minimum of 1D4+1; the note tells the player to roll) across the five categories with the three printed bonuses on their category entries; and a pick of two across Horsemanship (General and Exotic Animals only) and Pilot, whose note carries the either-or. Canada printed 166 gave: Two languages of choice (one is English at +15%) with no bonus on the second; three W.P. skills (any, but blunt or knife is typically one of them); 1D4+2 additional skills from Domestic, Communications, Medical, Technical and Wilderness with no category bonuses; and no Horsemanship or Piloting skills at all - its lore said the Sasquatch never ride an animal, a phrase D-Bees leaves out. || EQUIPMENT: the D-Bees list is the same as Canada''s item for item. One weapon for each W.P. is the catalog''s weapons-matching-w-p-skills row; 1D4+1 extra E-Clips; survival knife; pocket mirror; waterskin or canteen is a pick of two; utility belt; a few small sacks stored as one small-sack with the wording in its note (no number is printed); one large sack. NOT stored, no catalog row: comb and/or brush, loincloth or shorts, partial body armor with no helmet or shoes (neither book names a make of armor). The other-possible-items list (wristwatch or pocket watch, hand-held communicator, language translator, backpack or satchel, candy, jelly and jams) is optional and is in GM Notes. D-Bees closes the list with No vehicle or riding animal to start; Canada printed 166 gave No vehicle or riding animal, nor any large equipment. || MONEY: neither book prints dice, so no starting_money is stored and the race''s is none. D-Bees says only that the Worldly Sasquatch has little need for money and tends to use it to help others, especially children. Canada printed 166 added that a Big Foot adventurer will rarely have more than 1-2 thousand credits; D-Bees restates the Money line without that figure, so it is no longer in the restrictions. || Cybernetics and the city breaking point (26 hours +1 hour per M.E. point, doubled in a quiet place; the numeral 26 is printed in both books) are restriction and side-effect text, the same in both books. || D-Bees adds Allies and Enemies lines that Canada does not print for this occupation; they are in GM Notes."
---

## Lore

Now and then a Sasquatch walks out of the forest and into the world of
humans. Such a one is curious and adventuresome, and always unattached: a
youngster who has not yet found a mate, or an elder whose mate has died
and whose children have families of their own. Three in four are male.

A Worldly Sasquatch is most at ease among Native Americans, Shamans,
Druids, Cyber-Knights and anyone else who lives close to the land, but
will travel with any company so long as most of it is good at heart.
Selfish and evil companions are not tolerated for long.

The adventurer picks up a little of the modern world. Simple tools and
melee weapons come first, Vibro-Blades and Neuro-Maces especially. Most
put on partial armor, and about half learn to shoot, favoring the laser
rifle for being quiet, accurate and long-ranged. None of it changes the
gentle nature underneath: a Worldly Sasquatch still will not kill in
anger or for sport, keeps no pets or beasts of burden (though dogs tend
to adopt one anyway), and cannot bear a city for more than a day or so.

## GM Notes

Otherwise the same as the True Sasquatch R.C.C.: its attributes, M.D.C.,
natural abilities, psionics and combat bonuses all apply.

Skills: the usual Sasquatch skills are at -5% for a Worldly Sasquatch;
the sheet shows the race''s figures, so subtract 5% by hand. Roll 1D4+1
for the additional skills from Communications (+5%), Domestic (+5%),
Medical, Technical and Wilderness (+10%); the sheet offers two. The last
pick is Horsemanship: General and Horsemanship: Exotic Animals together,
or two Piloting skills, never one of each.

Starting kit beyond what the sheet lists: a comb and/or brush, probably a
loincloth or shorts, and partial body armor with no helmet or shoes
(two-thirds wear it; never full environmental armor). Other possible
items: a wristwatch or pocket watch, a hand-held communicator, a language
translator, a backpack or satchel, and candy, jelly and jams of every
kind, since the Sasquatch has a sweet tooth. No vehicle or riding animal
to start.

Money: no dice are printed. These adventurers learn what money and trade
goods are for but have little need of either, and tend to spend what they
have on helping others, children above all, human and D-Bee alike.

City breaking point: 26 hours +1 hour per M.E. point, doubled somewhere
quiet. Past it the character is depressed (attacks, bonuses and skills
halved) or fixed on escape. An ordinary woodland Sasquatch reaches it in
half the time.

Allies: like-minded people, heroes, and anyone who shows compassion.
Enemies: hates demons and anyone who uses, mistreats or enslaves others;
dislikes soldiers and does not trust practitioners or creatures of magic.
',
       updated_at = datetime('now')
 WHERE class_id = 'worldly-sasquatch'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.166') > 0
   AND length(markdown) = 8707;

-- == aardan-tek ==
UPDATE imported_classes
   SET markdown = '---
id: aardan-tek
name: Aardan Tek
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.9-11
category: rcc
tags: [scholar]
men_of_arms: false
attribute_dice:
  IQ: "2d6+8"
  ME: "2d6+8"
  MA: "2d6+4"
  PS: "3d6"
  PP: "2d6+8"
  PE: "3d6"
  PB: "1d6"
  Spd: "4d6"
hit_points_base: "P.E. + 5d6, +1d6 per level"
ppe_base: "5d6"
yields_to_occupation: { ppe_base: [magic] }
horror_factor: 10
bonuses:
  pools: { sdc: "6d6" }
  combat: { attacks_base: 2, initiative: 3, perception: 2, parry: 2, dodge: 2, roll: 1 }
  saves: { horror_factor: 2 }
natural_abilities:
  - name: "Senses and agility"
    description: "Sharp vision with 200 degrees of peripheral vision, good speed and dexterity. Leaps six feet (1.8 m) high and eight feet (2.4 m) across; half again as far with a running start. Excellent balance from the wide, finger-like feet: +5% to the Acrobatics and Gymnastics skills, and +5% to Climb and Prowl."
  - name: "Prehensile nose and keen sense of smell"
    description: "A prehensile, trunk-like proboscis that hangs from the center of the face, with the mouth beneath it. It can be turned to face any direction, detects odors on par with a canine, and can pick up, hold and manipulate small, light objects. It can identify and follow the scent of one individual from sweat alone, judging which traces are freshest and which way they lead. Perception Rolls involving scents are at +4 in place of the usual +2."
  - name: "Recognize common and strong scents"
    description: "Recognizes and accurately identifies general, common or known smells: most airborne scents, food, animals, the path used by a group of humans, mutant animals, D-Bees or monsters, and other strong or distinctive smells. Base skill 70% +3% per level of experience. Range 100 feet (30.5 m) per level of experience."
  - name: "Identify specific odors"
    description: "The scent of a specific individual, poison or drugs mixed into food or drink, and unique and unusual scents. The character must be familiar with the subject or have a reference such as clothing, hair or blood. Base skill 58% +2% per level of experience. Range 25 feet (7.6 m) per level of experience."
  - name: "Track by smell alone"
    description: "Follows a scent with no visible trail, even through total darkness, and takes only half the usual penalties to strike, parry and dodge when blinded or in total darkness. Base skill 34% +4% per level of experience. Roll once per 1000 feet (305 m), or per 500 feet if the scent is light or the trail is under light rain or snow. A failed roll loses the trail for the moment: two successes in three further tries find it again, two failures lose it. The trail cannot be more than 24 hours old."
side_effects: "Vulnerabilities: (1) much more susceptible to strong smells, double the penalties from noxious fumes and stench attacks; (2) poor swimmers, -10% on all swimming skills; (3) an alien and, by human standards, ugly appearance makes them stand out, often the target of D-Bee haters and slavers; (4) inexperience as trans-dimensional explorers and an insatiable curiosity get them into trouble, and some are overconfident. An S.D.C. being: M.D.C. by magic or M.D.C. body armor only."
trackable_resources: []
restrictions:
  - "Alignment: any, but typically Scrupulous, Unprincipled or Anarchist."
  - "Psionics: the same range of possibilities as a human."
  - "Magic: as per O.C.C. Culturally, 55% practice some form of magic; of those who come to Rifts Earth, 75% are magic practitioners or are seeking to learn a new type of magic."
  - "Available O.C.C.s: any. The vast majority gravitate toward practitioners of magic (any) and Adventurer O.C.C.s, particularly the Body Fixer, Rogue Scientist, Rogue Scholar and Vagabond. They typically avoid invasive physical augmentation."
  - "Standard equipment as per O.C.C. Player characters start with no magic items or magic weapons."
extraction_notes: "Followed Rifts World Book 20: Canada printed 130-132 until this update; brought up to the Rifts World Book 30: D-Bees of North America printing, printed 9-11, under the ruling of 2026-10-04 (the newest printing that states a figure wins). Both books read off page renders: D-Bees cache p010-p012 and Canada cache p131-p133, cache page = printed folio + 1 in each. The D-Bees entry ends on printed 11 with the note Originally appeared in Rifts World Book 20: Canada. D-Bees spells the name Aardan Tek in its title, its tag line and its text, as Canada does. || CATEGORY: a D-Bee race that takes an O.C.C. in both books. D-Bees prints Use the experience table of the chosen O.C.C.; Canada printed no ladder; no xp_table. || ATTRIBUTES: the eight dice are the same in both books. || POOLS: D-Bees prints Hit Points 5D6 +P.E. attribute number, plus 1D6 per level of experience, starting at level one. Canada printed 131 gave plus 1D6 M.D. per level, which the earlier import read as a slip for Hit Points; D-Bees drops the M.D. hit_points_base stores P.E. + 5d6, +1d6 per level. S.D.C. 6D6 in both books is a racial S.D.C. and is stored as a pool bonus, never sdc_base. M.D.C. by magic or M.D.C. body armor only. men_of_arms false, as for every race. || P.P.E.: 5D6 or per magic O.C.C. in both books, stored as ppe_base 5d6 with yields_to_occupation ppe_base to the magic group. || HORROR FACTOR: D-Bees prints Horror Factor 10, stored as horror_factor 10. Canada printed 130-132 gave no Horror Factor. || PSIONICS: D-Bees prints Same range of possibilities as a human, so no psionics block is stored and the character rolls as a human does. Canada printed 131 gave All Aardan Tek are Minor Psychics with the standard range of abilities, only Mystics have a greater range of powers; the row held a minor psychic block (I.S.P. M.E. + 2D6, +1D6 per level, two powers from Healing, Physical or Sensitive) until this update. || COMBAT: attacks from Hand to Hand Combat training, minimum of two without a combat skill, in both books, is attacks_base 2. D-Bees bonuses: +3 initiative, +2 Perception Rolls (+4 when involving scents), +2 parry and dodge, +1 roll with impact, +2 save vs Horror Factor. Perception +2 is stored in bonuses; the further +2 with scents is conditional and is in the Prehensile nose ability text. Canada printed 131 gave no Perception bonus; its other four bonuses were the same. || NATURAL ABILITIES: D-Bees adds excellent balance from the wide, finger-like feet, +5% to Acrobatics and Gymnastics and +5% to Climb and Prowl, kept as ability text because the race grants none of those skills itself; and a nose that can pick up, hold and manipulate small, light objects. Canada printed 131 gave neither. D-Bees lists most airborne scents where Canada listed gases among the common scents. The three scent skills print the same percentages and ranges in both books: 70% +3%, 100 feet per level; 58% +2%, 25 feet per level; 34% +4%. || VULNERABILITIES: D-Bees prints four: double the penalties from noxious fumes and stench attacks; poor swimmers, -10% on all swimming skills; an alien and ugly appearance that makes them a target of D-Bee haters and slavers; inexperience, curiosity and overconfidence. Canada printed 131 gave only the swimming penalty. || AVAILABLE O.C.C.s: D-Bees prints Any, with the vast majority gravitating toward practitioners of magic (any) and Adventurer O.C.C.s, particularly the Body Fixer, Rogue Scientist, Rogue Scholar and Vagabond, and typically avoiding invasive physical augmentation. No occ_restrictions block is stored; the preference is a restrictions line. Canada printed 131-132 gave any Practitioner of Magic O.C.C. (tending to avoid Witchcraft and Necromancy, fascinated with Temporal Magic and Techno-Wizardry) plus most Scholar and Adventurer O.C.C.s with Operator, Scholar and Scientist the most likely, and no Juicers, Crazies or full conversion cyborgs; the row held only group:magic and group:optional until this update. D-Bees restates the line without the prohibition and without the Witchcraft and Necromancy tendency. || MAGIC: D-Bees prints As per O.C.C.; culturally 55% practice some form of magic, and of those who come to Rifts Earth 75% are magic practitioners or are seeking to learn a new type of magic. Canada printed 132 gave 20% Mystics, 20% Ley Line Walkers and 15% some other type of practitioner, which D-Bees does not restate. || ALIGNMENT: D-Bees prints Any, but typically Scrupulous (20%), Unprincipled (25%) and Anarchist (20%). Canada printed 130 gave Any. || EQUIPMENT: D-Bees prints Standard Equipment as per O.C.C., and that player characters start with no magic items or magic weapons; no equipment_starting is stored. Canada printed 132 gave a suit of custom-made light (30 M.D.C.) to medium (50 M.D.C.) body armor (may or may not be full environmental armor), tinted goggles, PDD pocket audio recorder, pocket laser distancer, flashlight, pocket mirror, cigarette lighter, portable language translator, two modern weapons of choice and four additional E-clips for each, plus knapsack, backpack, utility belt, gas mask or air filter and canteen; the row held thirteen of those entries until this update. Neither book prints money. || NOT STORED, in GM Notes: size 6-7 feet and weight 160-230 pounds (both books); average life span 4D6+78 years, physical maturity by age 17, one or two live young after a nine month pregnancy (Canada printed 130 gave a life span of 80-100 years); experience level 2D4 or as set by the Game Master for NPCs, player characters start at first level; the alignment percentages; allies, enemies and habitat. Disposition (confident, inquisitive, studious and positive) is not stored. Also known as the Long Nose D-Bees in D-Bees; Canada printed 130 gave the Long Nose Aliens."
---

## Lore

The Aardan Tek, said "Air dan tek" and nicknamed the Long Nose D-Bees, come
from a world where magic and machines grew up side by side. Unlike nearly
every other D-Bee people, they chose to come here: Rifts Earth was their
first deliberate step into dimensional travel, picked because its magic and
its dimensional disturbances were like nothing they had seen. They came to
study it.

What they found surprised them. They had not expected a planet crowded with
intelligent life, or dozens of other peoples crossing dimensions, or so many
different schools of magic. Their home knew only Mystics and Ley Line
Walkers and perhaps a dozen kinds of demon, the Brodkil, Black Faeries, Imps
and Gremlins among them. The Splugorth, dragons and the other creatures of
magic were all new, and their picture of the Megaverse grew enormously on
arrival.

An Aardan Tek is tall and quick, with a short flexible trunk above the
mouth that can smell as keenly as a hound. They are clever, curious and
drawn to art, theology, machinery and above all magic. Temporal Magic and
Techno-Wizardry fascinate them, and they love magic items, though none
begin with any.

## GM Notes

Size 6-7 feet (1.8 to 2.1 m). Weight 160 to 230 pounds (72 to 103.5 kg).
Average life span 4D6+78 years; physical maturity by age 17. Females give
birth to one or two live young after a nine month pregnancy.

Alignment: any, but typically Scrupulous (20%), Unprincipled (25%) and
Anarchist (20%), though dark magic and dealings with the supernatural may
change that. NPC experience level 2D4 or as set by the Game Master; player
characters start at first level.

Psionics: the same range of possibilities as a human.

Standard equipment is as per the chosen O.C.C.

Poor swimmers: -10% on all swimming skills. Strong smells hit them hard:
double the penalties from noxious fumes and stench attacks.

Allies: none as such, but they drift toward artists, musicians,
philosophers, scholars, scientists and other practitioners of magic, and
are fascinated by dragons and Faerie Folk. A number live and study at
Lazlo, New Lazlo and the Federation of Magic. Enemies: the Coalition
States, human supremacists and anyone opposed to magic and D-Bees; they
also regard demons and other supernatural beings as dangerous by nature.

Habitat: anywhere in North America, most numerous in Ontario, Michigan and
the Ohio Valley. Small groups travel to places of magic such as the Calgary
Rift and the Wyoming Medicine Wheel. They stay clear of Atlantis for fear
the Splugorth would enslave them.
',
       updated_at = datetime('now')
 WHERE class_id = 'aardan-tek'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.130-132') > 0
   AND length(markdown) = 9043;

-- == grackle-tooth ==
UPDATE imported_classes
   SET markdown = '---
id: grackle-tooth
name: Grackle Tooth
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.97-98
category: rcc
tags: [combat]
attribute_dice:
  IQ: "1d6+8"
  ME: "1d6+9"
  MA: "2d6+14"
  PS: "2d6+22"
  PP: "2d6+10"
  PE: "2d6+10"
  PB: "1d6+6"
  Spd: "2d6+10"
mdc_base: "P.E. + 2d4x10, +3d6 per level"
ppe_base: "3d6"
horror_factor: 12
psionics_allowed: false
occ_restrictions:
  only: ["merc-soldier", "tundra-ranger", "tundra-ranger-scout", "tundra-ranger-cavalry", "wilderness-scout", "vagabond", "operator", "bounty-hunter", "cowboy", "bandit", "highwayman", "gunfighter", "gunslinger", "justice-ranger", "saddle-tramp", "sheriff-lawman", "sheriffs-deputy"]
  note: "Any Men at Arms O.C.C. except Combat Cyborg, Crazy and Juicer. They lean toward Military/Grunt/Soldier, Merc Soldier, Wilderness Scout, Vagabond, Operator, Bounty Hunter, Bandit, Cowboy, and any of the New West Men at Arms O.C.C.s except the Psi-Slinger, Wired Gunslinger or CyberSlinger Cyborg; that leaning is the list offered here. M.O.M. and Juicer augmentation does not work on a Grackle Tooth."
bonuses:
  combat: { attacks_base: 2, attacks: 1, initiative: 2, perception: 2, strike: 1, parry: 2, pull_punch: 3, roll: 2 }
  saves: { horror_factor: 5, toxins_poisons: 2, disease: 6, psionics: 1, illusionary_magic: 1, other: [ { label: "vs mind controlling drugs", bonus: 1 } ] }
skills:
  occ_skills:
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "Mechanical aptitude: +10%." }
    - { name: "Basic Mechanics", base: 40, per_level: 5, note: "Mechanical aptitude: +10%." }
    - { choose: 1, from: ["W.P. Handguns", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun", "W.P. Automatic Pistol", "W.P. Revolver", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Grenade Launcher", "W.P. Harpoon & Spear Gun"], note: "Mechanical aptitude: one extra Modern W.P." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "A medium-level Mega-Damage being on Rifts Earth with Supernatural P.S. and P.E. M.D.C. is 2D4x10 plus the P.E. attribute number, plus 3D6 per level of experience, starting at level one. Physical M.D.C. recovers at 2D6 per 12 hours. On an S.D.C. world: Hit Points of 1D6x10 plus the P.E. attribute number, +1D6 per level of experience, 1D6x10 S.D.C. and a natural A.R. of 9."
  - name: "Senses and hardiness"
    description: "Sharp vision, incredible strength, excellent reflexes and quick wit. +2 to save vs poison and toxins and +6 to save vs disease. Impervious to carcinogens and heat, but finds the cold uncomfortable (see the vulnerability under restrictions)."
  - name: "Prehensile tail"
    description: "A long, tapering tail of 12-15 feet (3.6 to 4.6 m). It adds one extra attack per melee round and can wield hand-held melee weapons such as Vibro-Blades and clubs, and even handguns, though it is -3 to strike with a gun, aimed shots included. A damaged or lost tail grows back one foot (0.3 m) per month to its full length."
  - name: "Natural weapons"
    description: "Bite does 2D6 M.D. A tail strike does the same damage as a Supernatural P.S. punch. Otherwise damage is by Supernatural P.S. or by weapon."
  - name: "Mechanical aptitude"
    description: "Besides the granted skills, every mechanical and repair or building skill taken under an O.C.C. gets an extra +5% on top of any O.C.C. bonus. The sheet does not add it."
side_effects: "Psionics: none. Magic: none. P.P.E. is too low, and there is no I.S.P., to power Techno-Wizard weapons."
trackable_resources: []
restrictions:
  - "Alignment: any, but they lean toward Principled (20%), Scrupulous (30%), Unprincipled (10%), Anarchist (25%) or Aberrant (10%)."
  - "Vulnerability: finds the cold uncomfortable. Skill performance is -5% and combat bonuses are -1 when forced out in temperatures below 35 degrees Fahrenheit; freezing temperatures feel like below zero to a Grackle Tooth. Their large size and reputation as warriors make them prime targets in an attack."
  - "Available O.C.C.s as printed: any Men at Arms O.C.C. except Combat Cyborg, Crazy and Juicer. Experience: the experience table of the chosen O.C.C."
  - "M.O.M. and Juicer augmentation does not work on these aliens, and they tend to avoid bionic augmentation."
  - "Combat: attacks from Hand to Hand training plus one from the tail; a minimum of three without combat training."
  - "Standard equipment: as per O.C.C. plus one extra heavy weapon. Few wear any armor; some will consider partial M.D.C. armor."
extraction_notes: "This class followed Rifts World Book 20: Canada printed 133-134 until it was brought up to Rifts World Book 30: D-Bees of North America printed 97-98 (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here). Every figure below was read off page renders of both books; D-Bees printed 96 is an illustration and the entry starts on printed 97. || NAME: both books print Grackle Tooth on the heading and the stat block, also known as the Mighty Grackle Tooth or the Deadly Grackle. The text layer of the Canada file reads Crackle in places where its render of printed 133 reads Grackle. || CATEGORY: a D-Bee race that takes an O.C.C. in both books. D-Bees prints Experience Level 2D4 or as set by the Game Master for NPCs, player characters start at level one, and to use the experience table of the chosen O.C.C.; Canada printed no experience line. No xp_table is stored. || ATTRIBUTES: the same eight dice in both books. Canada printed 133 closed the line with supernatural physical attributes; D-Bees marks only P.S. and P.E. as Supernatural, and the natural ability text now says so. || M.D.C.: 2D4x10 + P.E. attribute number plus 3D6 per level of experience starting at level one, stored as mdc_base, the same in both books. The S.D.C.-world figures (1D6x10 + P.E. Hit Points, 1D6x10 S.D.C., +1D6 H.P. per level, natural A.R. 9) are natural ability text, the same in both. || HORROR FACTOR: D-Bees prints Horror/Awe Factor 12, stored as horror_factor 12; Canada printed 133-134 gave none. || P.P.E. 3D6 in both. Psionics none is psionics_allowed false; magic none. || BONUSES: D-Bees gathers them on one line: +1 attack per melee round, +2 initiative, +2 on Perception Rolls, +1 strike, +2 parry (includes use of the tail), +3 pull punch, +2 roll with impact, +2 vs poison and toxins, +6 vs disease, impervious to carcinogens and heat, +1 to save against psionic attacks and mind controlling drugs and magical illusions, +5 vs Horror Factor. The +2 on Perception Rolls is new and stored as perception 2; Canada printed 134 gave no Perception bonus. Canada printed the poison and disease saves under Natural Abilities and the +1 saves on its Psionics line, with the same figures. The saves are stored as toxins_poisons 2, disease 6, horror_factor 5, psionics 1, illusionary_magic 1 and an other row for mind controlling drugs. || ATTACKS: both books print those gained from Hand to Hand Combat training plus one from the tail, minimum of three without combat training, stored as attacks 1 for the tail and attacks_base 2 (the printed minimum of three less the tail). The +1 attack per melee round on the D-Bees bonus line is read as that same tail attack, which the tail paragraph and the Attacks per Melee line both restate, and is not stored a second time; the Canada bonus line printed no attack. The -3 to strike with a gun held in the tail is natural ability text. || VULNERABILITIES: D-Bees adds figures to the cold: skill performance -5% and combat bonuses -1 below 35 degrees Fahrenheit. Canada printed only finds the cold uncomfortable. Conditional, so it is a restrictions line. || SKILLS: Basic Electronics and Basic Mechanics both at +10% over the catalog base of 30, and one extra Modern W.P. as a choice of one from the catalog modern weapon proficiencies, the same in both books. The +5% on mechanical and repair or building skills taken under an O.C.C. is conditional on what the O.C.C. grants and is natural ability text. || AVAILABLE O.C.C.s: D-Bees printed 98 prints any Men at Arms O.C.C. except Combat Cyborg, Crazy and Juicer, then lean toward Military/Grunt/Soldier, Merc Soldier, Wilderness Scout, Vagabond, Operator, Bounty Hunter, Bandit, Cowboy, and any of the New West Men at Arms O.C.C.s except the Psi-Slinger, Wired Gunslinger or CyberSlinger Cyborg. Canada printed 134 gave a closed list: any Military/Soldier O.C.C., Wilderness Scout, Vagabond, Operator, Bounty Hunter, Cowboy, and any New West Men at Arms O.C.C. except those three. The stored only list is unchanged from the Canada import and is the D-Bees leaning: Wilderness Scout, Vagabond, Operator, Bounty Hunter and Cowboy by id; the New West contents list Men at Arms entries less the three excepted (bandit, highwayman, bounty-hunter, gunfighter, gunslinger, justice-ranger, saddle-tramp, sheriff-lawman, sheriffs-deputy); and merc-soldier with the three Tundra Ranger O.C.C.s of the Canada book for Military/Soldier. coalition-grunt is left out because it is barred to non-humans. The wider D-Bees rule, a whole group less named classes, is printed in the note and in restrictions and is not what the only list holds. || ALIGNMENT: D-Bees prints Any, but lean toward Principled (20%), Scrupulous (30%), Unprincipled (10%), Anarchist (25%) or Aberrant (10%); Canada printed 133 gave Any, but lean toward good, Anarchist or Aberrant. || EQUIPMENT: as per O.C.C. plus one extra heavy weapon in both books, which names no item, so nothing is stored; no money is printed. || NOT STORED: size 8-10 feet and weight 600 to 800 pounds (both books); Average Life Span 2D4x10 +120 years, physical maturity at 17, two or three young after a 12 month pregnancy (D-Bees; Canada printed 133 gave 200-300 years); population fewer than 4,000 in 102 P.A. risen to 6,200, an estimated 423 dead fighting for Tolkeen (D-Bees; Canada printed 134 gave less than 4,000 with a few hundred drawn to Minnesota and Canada); allies, enemies and habitat are in GM Notes."
---

## Lore

The Grackle Tooth, also called the Mighty Grackle Tooth or the Deadly
Grackle, is a huge, barrel-chested alien with a long head that recalls a
dragon or a dinosaur. Its hide is smooth and tough as rawhide, tan to gold
to rusty orange, with bony fins along the neck, spine, shoulders and
elbows, and a long tail it uses like a third arm.

For all that, most are cheerful, polite and easy to like. They get on well
with humans, Dog Boys and plenty of others, grin around a cigar, and joke
in a deep voice about how their grandparents must have taken a wrong turn
into a Rift. If the race ever knew how it arrived, nobody remembers, and
nobody much minds: Earth is the only home they have known.

They enjoy roughhousing, exploring, working cattle and a good fight. They
have a knack for weapons and make fair mechanics when they can be kept
still long enough to learn. Most value life and fair play. There are
Grackle Tooth rogues, gamblers, thugs and mercenaries too, and even these
usually keep some code of honor. A truly evil one kills with a smile and a
wisecrack.

## GM Notes

D-Bees of North America prints the name as Grackle Tooth throughout. The
race was first described in Rifts World Book 20: Canada.

Size 8-10 feet (2.4 to 3 m). Weight 600 to 800 pounds (270 to 360 kg).
Average life span 2D4x10 +120 years; physical maturity at 17.

Attacks per melee: those from Hand to Hand training plus one from the tail,
with a minimum of three for a character with no combat training. The tail
is -3 to strike with a gun. Bite 2D6 M.D.; a tail strike does Supernatural
P.S. punch damage.

Not applied by the sheet: the extra +5% on every mechanical and repair or
building skill taken through the O.C.C.

Equipment is the O.C.C.''s plus one extra heavy weapon. They favor plasma
and particle weapons, rail guns and other heavy types, and like magic
weapons but cannot power Techno-Wizard ones. Few wear armor.

Allies: humans, Psi-Stalkers, Dog Boys, Tirrvol Sword Fists, Quick-Flex
Aliens and most warrior types. Enemies: none in particular beyond whoever
wants a fight, though they distrust Coalition humans after several run-ins
and expect no better of Free Quebec.

Habitat: warm, dry country. Fewer than 4,000 were thought to be on Earth
in 102 P.A.; the number has since risen to 6,200. Half are in Lone Star
and most of the rest in the New West. An estimated 423 died fighting for
Tolkeen.
',
       updated_at = datetime('now')
 WHERE class_id = 'grackle-tooth'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.133-134') > 0
   AND length(markdown) = 9102;

-- == greot-hunter ==
UPDATE imported_classes
   SET markdown = '---
id: greot-hunter
name: Greot Hunter
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.98-100
category: rcc
tags: [combat, hunter]
attribute_dice:
  IQ: "1d4+5"
  ME: "1d6+3"
  MA: "1d6+3"
  PS: "3d6+20"
  PP: "2d6+8"
  PE: "2d6+11"
  PB: "1d6"
  Spd: "2d6+7"
mdc_base: "P.E. + 1d6x10, +4d6 per level"
ppe_base: "1d6"
horror_factor: 10
occ_restrictions:
  only: ["merc-soldier", "headhunter-techno-warrior", "headhunter-assassin", "headhunter-anti-robot-specialist", "headhunter-techno-hound", "momano-headhunter", "cyber-knight", "wilderness-scout", "vagabond", "bounty-hunter", "bandit", "pirate", "highwayman", "gunfighter", "gunslinger", "justice-ranger", "psi-slinger", "saddle-tramp", "sheriff-lawman", "sheriffs-deputy", "wired-gunslinger"]
  note: "Limited to combat oriented O.C.C.s: Grunt/Soldier, Military Specialist, Merc Soldier, Headhunter, Cyber-Knight, Wilderness Scout, Vagabond, Bounty Hunter, Smuggler, Bandit, Pirate, and any New West Men at Arms O.C.C. M.O.M. and Juicer augmentation does not work on a Greot."
bonuses:
  combat: { attacks: 1, initiative: 2, strike: 2, parry: 1, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 6, toxins_poisons: 3, disease: 5, spell_magic: 1, possession: 1 }
skills:
  occ_skills:
    - { name: "Swimming", base: 60, per_level: 5, note: "Instinctive swimmers: 60% +5% per level of experience." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "A Mega-Damage being with Supernatural P.S. and P.E. M.D.C. is 1D6x10 plus the P.E. attribute number, plus 4D6 per level of experience, starting at level one. Fast healers: physical M.D.C. recovers at 3D6 every 12 hours. They also wear M.D.C. body armor and may get partial bionics. On an S.D.C. world: Hit Points of 1D6x10 plus the P.E. attribute number, +2D6 per level of experience, 1D4x10 S.D.C. and a natural A.R. of 12."
  - name: "Senses and hardiness"
    description: "Sharp vision, incredible strength and good reflexes. +3 to save vs poison and toxins and +5 to save vs disease. Resistant to cold, thanks to a layer of blubber under the thick, tough, lumpy skin: even Mega-Damage cold attacks do half damage. Impervious to UV rays, nuclear radiation and carcinogens. The tail is not prehensile."
  - name: "Instinctive swimmer"
    description: "Swims at 60% +5% per level of experience, at triple Spd, can hold breath for one minute per P.E. point, and tolerates depths of up to 600 feet (183 m)."
  - name: "Natural weapons"
    description: "Bite does 1D6 M.D. A claw attack adds 2D6 M.D. to Supernatural P.S. punch damage. Otherwise damage is by Supernatural P.S. or by weapon."
  - name: "Aggressive nature"
    description: "One attack per melee round on top of those gained from Hand to Hand training."
trackable_resources: []
restrictions:
  - "Alignment: any, but they lean toward Anarchist and evil."
  - "Psionics: standard (the same likelihood as humans)."
  - "Magic: none. They do not like, understand or trust magic."
  - "M.O.M. and Juicer augmentation does not work on their alien physiology. They see full bionic conversion as being for weaklings, and they are stronger without it; partial bionics and implants are acceptable."
  - "Standard equipment and money: as per O.C.C."
  - "Horror Factor 10 for Greots in general; as high as 15 for an individual underworld Greot, merc or bounty hunter with a nasty reputation, at the G.M.''s discretion."
extraction_notes: "Followed Rifts World Book 20: Canada printed 135 until this update; brought up to the Rifts World Book 30: D-Bees of North America printing, printed 98-100, under the ruling of 2026-10-04 (the newest printing that states a figure wins). Both books read off page renders: D-Bees cache p099-p101 and Canada cache p136, cache page = printed folio + 1 in each. The D-Bees entry starts with lore at the foot of printed 98, the stat block heading Greot Hunter - Optional Player Character & NPC is on printed 99, and the entry ends on printed 100. || CATEGORY: a D-Bee race that takes an O.C.C. in both books. D-Bees printed 100 says to use the experience table of the chosen O.C.C.; Canada printed 135 prints no experience line; no xp_table is stored. || ATTRIBUTES: identical in both books, I.Q. 1D4+5 included. D-Bees marks P.S. and P.E. as Supernatural where Canada printed 135 said supernatural physical attributes. Spd 2D6+7 is tripled when swimming, which is natural ability text. || M.D.C.: 1D6x10 +P.E. attribute number, plus 4D6 M.D. per level of experience starting at level one, the same in both books, stored as mdc_base. The S.D.C.-world figures (1D6x10 +P.E. Hit Points, 1D4x10 S.D.C., +2D6 H.P. per level, natural A.R. 12) are the same in both and are natural ability text. D-Bees adds that they also wear M.D.C. body armor and may get partial bionics. || HORROR FACTOR: D-Bees printed 99 gives 10 for Greots in general, as high as 15 for individuals with a nasty reputation (G.M. discretion); stored as horror_factor 10 with the 15 in restrictions. Canada printed 135 printed no Horror Factor. || P.P.E. 1D6 in both. Psionics: D-Bees prints Same likelihood as humans, Canada printed Standard; no psionics block and the standard roll applies. || SAVES: D-Bees printed 100 puts them all on one Bonuses line: +3 vs poison and toxins, +5 vs disease, +1 to save vs magic and possession (spell_magic 1 and possession 1), +6 vs Horror Factor. Canada printed 135 gave the same figures across Natural Abilities, the Magic line and R.C.C. Bonuses. || COMBAT: +1 attack per melee, +2 initiative, +2 strike, +1 parry, +2 pull punch, +2 roll with impact on the D-Bees Bonuses line. Canada printed 135 gave the same bonuses and worded the attack as those from Hand to Hand training plus one from their aggressive nature; D-Bees prints Attacks per Melee as per Hand to Hand Combat skill and carries the extra attack on the Bonuses line. attacks 1 is unchanged and the Aggressive nature entry keeps its name. || NATURAL ABILITIES new in D-Bees: can hold breath for one minute per P.E. point; resistant to cold, even M.D. cold attacks do half damage; impervious to UV rays and nuclear radiation as well as carcinogens; tail is not prehensile. Canada printed 135 gave impervious to carcinogens and equipped to handle the cold only. These are conditional or descriptive and are natural ability text. || SKILLS: Swimming skill at 60% +5% per level in both books, stored as Swimming 60 with per_level 5, the printed figure and not the catalog base plus a bonus. || DAMAGE: bite 1D6 M.D. and claws add 2D6 M.D. to Supernatural P.S. punch damage, the same in both. || AVAILABLE O.C.C.s (D-Bees printed 100): Grunt/Soldier, Military Specialist, Merc Soldier, Headhunter, Cyber-Knight, Wilderness Scout, Vagabond, Bounty Hunter, Smuggler, Bandit, Pirate, and any New West Men at Arms O.C.C. Canada printed 135 gave Grunt, Military Specialist, Headhunter, Wilderness Scout, Vagabond, Bounty Hunter, Bandit, and any New West Men at Arms O.C.C.; Merc Soldier, Cyber-Knight, Smuggler and Pirate are new in D-Bees. Stored: Grunt/Soldier and Merc Soldier as merc-soldier, because the core book''s coalition-grunt is barred to non-humans; Headhunter as headhunter-techno-warrior and Canada''s four other Headhunter O.C.C.s; Cyber-Knight as cyber-knight; Pirate as pirate, the Rifts World Book 6: South America O.C.C., the only Rifts Pirate O.C.C. held; Wilderness Scout, Vagabond, Bounty Hunter and Bandit by id. Military Specialist and Smuggler have no matching Rifts class in the catalog and are not stored. Any New West Men at Arms O.C.C. is stored as the New West contents list Men at Arms entries that exist: bandit, highwayman, bounty-hunter, gunfighter, gunslinger, justice-ranger, psi-slinger, saddle-tramp, sheriff-lawman, sheriffs-deputy, wired-gunslinger; the CyberSlinger Cyborg has no class. || BIONICS: D-Bees printed 100 says they see full bionics conversion as being for weaklings and are stronger without it, but partial bionics and implants are acceptable. Canada printed 135 said they like bionics but are stronger without them, and one who opts for bionics usually goes only for partial augmentation, typically weapon systems. || EQUIPMENT AND MONEY: as per O.C.C. in D-Bees; Canada printed 135 gave equipment as per O.C.C. and no money line. Nothing stored. || NPC FIGURES, not stored in a field: experience level 1D8 or as set by the Game Master for NPCs (D-Bees printed 100; Canada printed none); average life span 3D6+40 years, females 4D6+43 years (D-Bees printed 99), where Canada printed 135 gave 50 years, although some live to 70. Size, weight, life span, allies, enemies and habitat are in GM Notes."
---

## Lore

The Greot, said "gree oat", are hunters and warriors by nature: big,
hulking brutes that look part reptile and part amphibian, with thick lumpy
skin over a layer of blubber and long black claws. They are strong enough
to make good laborers, but too aggressive to work easily beside anyone
else.

On their own world the Greot rule. Landing on a planet full of rival
peoples has left them tense and resentful, which sharpens an already gruff
and intolerant temper. They anger quickly, relish a fight and show no
mercy in one, and they enjoy pushing around anyone weaker. That makes them
popular hires for criminal outfits, the Black Market included, as
enforcers, debt collectors, bodyguards and interrogators.

They love heavy guns and Vibro-Blades, want nothing to do with magic, and
in a fight prefer to kill the spell casters and creatures of magic first.

## GM Notes

Size 7-8 feet (2.1 to 2.4 m). Weight 500 to 600 pounds (225 to 270 kg).
Average life span 3D6+40 years; females live 4D6+43 years. Greots reach
physical maturity by age 13, and females lay 1D4+1 eggs that take seven
months to hatch.

NPC experience level: 1D8, or as set by the Game Master. Horror Factor 10,
as high as 15 for an individual with a nasty reputation.

Spd is tripled when swimming. Bite 1D6 M.D.; claws add 2D6 M.D. to
Supernatural P.S. damage.

The book''s occupation list also names the Military Specialist and the
Smuggler, which have no matching Rifts class in the catalog.

Allies: their only true allegiance is to their own kind. They ally with
other powerful, warlike beings and use subservient henchmen, but only as
a means to an end. Enemies: humans in general, the Coalition States
and Free Quebec in particular, and anyone who stands against them. They
hate Xiticix, Psi-Stalkers, Simvan, Vanguard Brawlers, N''mbyr Gorilla Men
and Quick-Flex Aliens, and respect the Grackle Tooth, Mastadonoids,
Blucies, Sunaj, Loaks and Vintex as dangerous rivals because they are so
closely matched. Greot slavers trade with Horune Pirates and the Minions
of Splugorth.

Habitat: it was believed they came from the Calgary Rift, but the Greots
insist they came from a Rift in the ruins of Chi-Town. They are most
numerous in Manitoba, Ontario and the American Midwest, including the
Coalition States of Iron Heart and Chi-Town. An estimated 6,800 died at
Tolkeen.
',
       updated_at = datetime('now')
 WHERE class_id = 'greot-hunter'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.135') > 0
   AND length(markdown) = 6802;

-- == mastadonoid ==
UPDATE imported_classes
   SET markdown = '---
id: mastadonoid
name: Mastadonoid
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.134-135
category: rcc
tags: [wilderness, hunter]
attribute_dice:
  IQ: "1d6+6"
  ME: "2d6+6"
  MA: "2d6+3"
  PS: "3d6+26"
  PP: "2d6+6"
  PE: "2d6+6"
  PB: "1d6+1"
  Spd: "2d6+6"
mdc_base: "P.E. + 2d4x10, +3d6 per level"
ppe_base: "6d6+12"
psionics_allowed: false
occ_restrictions:
  only: ["elemental-fusionist-fire-water", "elemental-fusionist-earth-air", "inuit-shaman", "animal-shaman", "healing-shaman", "tribal-warrior", "mystic-warrior", "mystic", "wilderness-scout", "vagabond", "bounty-hunter", "bandit"]
  note: "Limited to Elemental Fusionist, Mystic, Wilderness Scout, Vagabond, Bounty Hunter, Bandit (rare), Inuit Shaman, Animal Shaman, Healing Shaman, Tribal Warrior or Mystic Warrior (Spirit West for the last four). Not a candidate for M.O.M. or Juicer augmentation, and avoids bionics."
skills:
  occ_skills:
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be upgraded via O.C.C." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%" }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
magic:
  type: "spell"
  spells: ["See the Invisible", "Sense Evil", "Sense Magic", "Armor of Ithan", "Throwing Stones", "Frostblade"]
  spells_schedule:
    - { level: 2, count: 1, spell_levels: [1, 2, 3], note: "One spell of choice from spell levels 1-3." }
    - { level: 5, count: 1, spell_levels: [1, 2, 3], note: "One spell of choice from spell levels 1-3." }
    - { level: 9, count: 1, spell_levels: [1, 2, 3], note: "One spell of choice from spell levels 1-3." }
    - { level: 12, count: 1, spell_levels: [1, 2, 3], note: "One spell of choice from spell levels 1-3." }
bonuses:
  combat: { initiative: 2, strike: 1, pull_punch: 4, roll: 2 }
  saves: { spell_magic: 1, horror_factor: 5, toxins_poisons: 3, disease: 5, mind_control: 4 }
natural_abilities:
  - name: "Mega-Damage being"
    description: "M.D.C. is 2D4x10 plus the P.E. attribute number, plus 3D6 per level of experience starting at level one. P.S. and P.E. are Supernatural. Heals fast: 3D6 M.D.C. recovered per 12 hours. On an S.D.C. world: Hit Points of 1D6x10 plus the P.E. attribute number, +1D6 per level, 1D6x10 S.D.C. and a natural A.R. of 10."
  - name: "Senses and resistances"
    description: "Sharp vision, incredible strength and good reflexes. +3 to save vs poison and toxins, +5 vs disease, +4 vs mind control. Impervious to demonic possession. Impervious to natural cold; magic cold does half damage."
  - name: "Snorkel trunk"
    description: "The trunk is the mouth and works as a snorkel underwater. Tolerates depths of up to 400 feet (122 m) without special equipment."
  - name: "Natural weapons"
    description: "Damage as per Supernatural P.S. or by weapon or magic (if applicable). Bite 1D4 M.D.; goring with a tusk 2D6 M.D.; the long ivory claws add 3D6 M.D. to the Supernatural P.S. damage of a claw strike."
  - name: "Natural spell casting"
    description: "A Mastadonoid who is not a practitioner of magic casts See the Invisible, Sense Evil, Sense Magic, Armor of Ithan, Throwing Stones and Frost Blade, and picks one more spell from levels 1-3 at levels 2, 5, 9 and 12."
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Psionics: none other than among the Mystics or Shamans."
  - "P.P.E.: 6D6+12. A Mastadonoid who takes a magic or Shaman O.C.C. adds only 6D6 to that occupation''s P.P.E., and the natural spell list is printed for those who are not practitioners of magic."
  - "Not a candidate for M.O.M. or Juicer augmentation; avoids bionics, modern weapons and machines."
  - "Vulnerability, heat: uncomfortable in environments warmer than 80 degrees; reduce Spd by 30% and -1 attack per melee, and fatigues as fast as humans, twice as fast if the temperature is 90 or greater."
  - "Vulnerability, civilization: does not understand the laws and customs of civilized people, dislikes most technology and hates being cooped up in a town or city; there, reduce all combat bonuses by half and -15% on skill performance."
  - "Experience: uses the Experience Table of the chosen O.C.C. Standard equipment: as per O.C.C."
extraction_notes: "UPDATED to Rifts World Book 30: D-Bees of North America printed 134-135 (cache p135-p136), read off page renders. The class was first imported from Rifts World Book 20: Canada printed 137 and followed that book until this update (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept in a note). D-Bees itself notes: Original appearance, Rifts World Book 20: Canada. || REVISIONS: M.A. is 2D6+3 (Canada printed 137 gave 2D6). R.C.C. SKILLS are new in D-Bees, in addition to the chosen O.C.C.: Hand to Hand: Basic (may be upgraded via O.C.C.; no price is printed, so no hand_to_hand block), Land Navigation +20% (catalog 36, stored 56), Skin & Prepare Animal Hides +10% (30, stored 40), Track & Trap Animals +20% (20, stored 40), Wilderness Survival +20% (30, stored 50); Canada printed 137 gave no skills. ATTACKS: D-Bees prints As per Hand to Hand Combat skill and nothing else, so no attacks_base is stored; Canada printed 137 gave Those gained from Hand to Hand Combat training, or one via spell magic and two physical, which was stored as attacks_base 2. AVAILABLE O.C.C.s: D-Bees adds Elemental Fusionist, stored as both catalog rows (elemental-fusionist-fire-water, elemental-fusionist-earth-air), and marks Bandit (rare); Canada printed 137 listed the other ten only. VULNERABILITIES are new in D-Bees (heat above 80 degrees: Spd -30%, -1 attack, fatigue; towns and cities: combat bonuses halved, -15% skills); both are conditional and stored as restriction lines. PSIONICS: D-Bees prints None other than among the Mystics or Shamans (Canada printed 137 gave None); psionics_allowed stays false, which is the race having no psionics of its own. LIFE SPAN: males 4D6+50, females 6D6+65 years (Canada printed 137 gave 80-110 years). DAMAGE: adds or magic (if applicable). || SAME IN BOTH: every other attribute die, size, weight, M.D.C., S.D.C.-world figures, P.P.E., the six spells and the schedule at levels 2, 5, 9 and 12, and every bonus figure; D-Bees moves +3 vs poison and toxins, +5 vs disease, impervious to demonic possession and +4 vs mind control from Natural Abilities into the Bonuses line, and prints P.P.E. costs beside the spells (4, 2, 4, 10, 5, 15). D-Bees marks P.S. and P.E. Supernatural where Canada said supernatural physical attributes. || D-BEES ADDS, NOT STORED AS FIELDS: alignment tendencies, NPC experience level 1D6+1, Experience Table of the chosen O.C.C. (no ladder was or is stored), Standard Equipment as per O.C.C. (none was or is stored), disposition, alliances; they are in GM Notes or restrictions. || THE REST OF THIS NOTE IS THE CANADA IMPORT RECORD, kept as written where the lines above do not supersede it: WB20 Canada printed 137 (cache p138; cache p137 is a full-page illustration), read off the text layer; no render was needed. Heading Mastadonoid, Optional Player Character & NPC, in D-Bees of Canada. || CATEGORY: a race that takes an occupation; no skills, equipment or money are printed and none are stored. No xp_table: the book prints no ladder for the race. || M.D.C.: printed 2D4xlO +P.E. attribute number plus 3D6 M.D. per level starting at level one, read as 2D4x10 and stored as mdc_base. The S.D.C.-world figures (printed !D6xlO, read 1D6x10) are in the natural ability text. || P.P.E.: 6D6+12 stored. The book says only 6D6 is a bonus to a magic or Shaman O.C.C.; that is an ADDITION to a mage''s figure, so no yields_to_occupation line is written and the sentence is a restriction line. || MAGIC: six named spells for those who are not practitioners of magic, plus one of choice from levels 1-3 at levels 2, 5, 9 and 12, stored as a magic block with a schedule. The book''s Frost Blade is the catalog row Frostblade (level 6, Book of Magic p.112); Throwing Stones is level 2. The block is not conditional in storage, so a pairing with a magic occupation unions the six spells. || BONUSES: +2 initiative, +1 strike, +4 pull punch, +2 roll, +1 save vs magic, +5 vs Horror Factor from the R.C.C. Bonuses line; +3 vs poison and toxins, +5 vs disease, +4 vs mind control from Natural Abilities. Impervious to demonic possession and to natural cold are ability text. || COMBAT: those gained from Hand to Hand training, or one via spell magic and two physical; stored as attacks_base 2 (the two physical), the spell attack is ability text. || PSIONICS: None, stored as psionics_allowed false. || OCCUPATIONS: the Available O.C.C. line is stored as occ_restrictions.only. Inuit Shaman is this book''s own O.C.C., inuit-shaman, imported in the same batch. Vagabond is the Rifts row vagabond; Mystic is the Rifts row mystic. || NOT STORED: size 10-12 feet, weight 600 to 1000 pounds, life span 80-110 years, the Inuit name Bear Claw People, enemies, habitat and the population estimate; they are in GM Notes."
---

## Lore

Mastadonoids are shaggy giants of the tundra, named by humans for their
bulk and their elephant-like heads. Brown to gray fur covers pale gray or
tan skin, a pair of small tusks frames what looks like a trunk, and each
hand carries black claws as long as short swords. The trunk is really the
mouth; the nostrils are two small holes near the eyes. Their ancestors used
it to feed from inside a kill, and most still prefer raw meat and treat
eating the organs of a worthy foe or animal as an honor.

For all their strength they are neither cruel nor murderous. They live
much as the traditional Inuit do, hunting and living off the land, and the
two peoples regard each other as kin: they trade news and food, come to
each other''s aid, and sometimes join each other''s tribes. The Inuit call
them the Bear Claw People. They have a natural gift for magic, and even
those who never study it can work a handful of spells.

## GM Notes

The book heads the race an optional player character and NPC.

Size 10-12 feet (3 to 3.6 m). Weight 600 to 1000 pounds (270 to 450 kg).
Average life span: males 4D6+50 years, females 6D6+65 years; physical
maturity by age 15.

Also known as Elephant Men. Alignment: any, but they tend to be Principled
(25%), Scrupulous (30%), Unprincipled (20%) and Anarchist (10%). NPC
experience level: 1D6+1 or as set by the Game Master; player characters
start at level one and use the Experience Table of the chosen O.C.C.

Inuit Shaman is one of the occupations the book allows this race.

A Mastadonoid who takes a magic or Shaman O.C.C. adds only 6D6 P.P.E. to
the occupation''s own, and the natural spell list is written for those who
are not practitioners of magic. The G.M. decides whether a shaman keeps it.

Enemies: evil supernatural beings, the Windigo most of all, and the
Xiticix. They dislike cruel and violent races such as the Loup Garou, and
distrust cyborgs, Crazies, Juicers, power armor pilots and most technology,
though few have met the Coalition or Free Quebec first hand.

Habitat: the Arctic and the northern wilderness from Alaska to Greenland.
They avoid cities and large towns. Perhaps 10,000 to 20,000 exist.

The block prints five R.C.C. skills, standard equipment as per O.C.C.,
and no money.
',
       updated_at = datetime('now')
 WHERE class_id = 'mastadonoid'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.137') > 0
   AND length(markdown) = 7348;

-- == noli-bushman ==
UPDATE imported_classes
   SET markdown = '---
id: noli-bushman
name: Noli Bushman
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.144-146
category: rcc
tags: [wilderness]
men_of_arms: false
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+6"
  MA: "3d6"
  PS: "3d6+4"
  PP: "3d6+2"
  PE: "3d6+4"
  PB: "2d6"
  Spd: "6d6"
hit_points_base: "P.E. + 2d6, +1d6 per level"
ppe_base: "3d6"
occ_restrictions:
  only: ["psi-druid", "psi-slayer", "cowboy", "wilderness-scout", "vagabond", "cyber-knight"]
  note: "Limited to Psi-Druid, Psi-Slayer (the only two psychic O.C.C.s available), Cowboy, Wilderness Scout or Vagabond, and, rarely, Cyber-Knight. Not a candidate for M.O.M. or Juicer augmentation, and avoids bionics."
psionics:
  type: "master"
bonuses:
  pools: { sdc: "1d4x10" }
  combat: { initiative: 1, strike: 1, pull_punch: 4, roll: 2 }
  saves: { possession: 2, horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Climbing", base: 60, per_level: 5, note: "R.C.C. instinct, +20%." }
    - { name: "Dowsing", base: 35, per_level: 5, note: "R.C.C. skill, +15%." }
    - { name: "Prowl", base: 35, per_level: 5, note: "R.C.C. instinct, +10%." }
    - { name: "Swimming", base: 60, per_level: 5, note: "R.C.C. skill, +10%." }
natural_abilities:
  - name: "Senses"
    description: "Sharp vision and nightvision to 300 feet (91.5 m). A thin second eyelid slides down as a natural polarizing lens, shielding the eye from bright light like a pair of polarized sunglasses."
  - name: "Master Psychic"
    description: "Every Noli is a Master Psychic and needs a 10 or higher to save vs psionic attack and mind control. A psionic attack counts as one melee action. A Psi-Druid or Psi-Slayer has the psionics and I.S.P. of that O.C.C.; every other Noli has the race''s own abilities and I.S.P."
  - name: "An S.D.C. being"
    description: "Hit Points are 2D6 plus the P.E. attribute number, plus 1D6 per level of experience starting at level one. S.D.C. is 1D4x10 plus any from physical skills. Needs magic or M.D.C. body armor against Mega-Damage weapons, just as a human does."
special_abilities:
  - { choose: 1, from: ["Psionics: Noli Master Psychic", "Psionics: Psi-Druid or Psi-Slayer", "Psionics: Noli Cyber-Knight"], note: "Psionics (printed 145-146): pick the line that matches the occupation. A Cowboy, Wilderness Scout or Vagabond has the race''s own abilities; a Psi-Druid or Psi-Slayer uses that O.C.C.''s; a Cyber-Knight is the rarity described under Available O.C.C.s." }
  - name: "Psionics: Noli Master Psychic"
    description: "For a Noli Cowboy, Wilderness Scout or Vagabond. Bio-Regeneration (self), Empathy, Mind Block, Psionic Invisibility and Telepathy, plus two Physical and two Sensitive powers of choice. One additional power from the Physical or Sensitive category at each new level of experience, and one Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword. I.S.P.: M.E. attribute number x2 plus 1D6+1 per level of experience."
    occ_options: ["cowboy", "wilderness-scout", "vagabond"]
    psionics: { type: "master", isp_base: "M.E. x2 + 1d6+1 per level", powers: ["Bio-Regeneration", "Empathy", "Mind Block", "Psionic Invisibility", "Telepathy"], powers_starting: 4, powers_starting_groups: [{ count: 2, categories: ["Physical"], note: "Two Physical powers of choice." }, { count: 2, categories: ["Sensitive"], note: "Two Sensitive powers of choice." }], categories_allowed: ["Physical", "Sensitive"], powers_schedule: [{ level: 2, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 3, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 4, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 4, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 5, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 6, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 7, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 8, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 8, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 9, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 10, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 11, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 12, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 12, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 13, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 14, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 15, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }] }
  - name: "Psionics: Psi-Druid or Psi-Slayer"
    description: "For a Noli Psi-Druid or Psi-Slayer, the only two psychic O.C.C.s available to the race. Ignore the race''s psionic abilities and I.S.P. and use the psionics, I.S.P., skills and abilities of that O.C.C."
    occ_options: ["psi-druid", "psi-slayer"]
  - name: "Psionics: Noli Cyber-Knight"
    description: "For a Noli Cyber-Knight, a rarity (only two are known) because the occupation limits the race''s natural range of psionic powers. Psi-Sword at 1st level and a total of six psionic powers selected from the Sensitive and/or Physical categories, in addition to those normally available to Cyber-Knights; the six are recorded by hand. I.S.P.: M.E. attribute number x2 plus 1D6+1 per level of experience."
    occ_options: ["cyber-knight"]
    psionics: { type: "master", isp_base: "M.E. x2 + 1d6+1 per level" }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Cowboy, Wilderness Scout (any) or Vagabond: in the case of the latter two, the number of O.C.C. Related and Secondary Skill selections is reduced to three each. Recorded by hand."
  - "A Noli Psi-Druid or Psi-Slayer ignores the race''s psionic abilities and I.S.P. and uses the psionics, I.S.P., skills and abilities of that O.C.C."
  - "Noli Cyber-Knight (only two are known): gets Psi-Sword at 1st level and a total of six powers chosen from the Sensitive and/or Physical categories, besides those a Cyber-Knight normally has. Recorded by hand."
  - "Not a candidate for M.O.M. or Juicer augmentation; avoids bionics, and cybernetics except for medical purposes."
extraction_notes: "Followed Rifts World Book 20: Canada printed 137-138 until this update to the D-Bees of North America printing (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept in a note). D-Bees of North America printed 144-146 (cache p145-p147) and Canada printed 137-138 (cache p138-p139) were both read off page renders. D-Bees closes the entry with Note: Original appearance, Rifts World Book 20: Canada. The lore is headed Noli Bushman and the stat block Noli - Optional Player Character and NPC; the class is named for the lore heading. || CATEGORY: a race that takes an occupation in both books; Standard Equipment is As per O.C.C. (D-Bees adds a preference for spears and staves as weapons) and Money is As per O.C.C. (Canada printed 138 has no money line). No xp_table: D-Bees says to use the Experience Table of the chosen O.C.C., and Canada prints no ladder for the race. || UNCHANGED BETWEEN THE BOOKS: the eight attribute dice, size, weight, P.P.E. 3D6, the Hit Points line, the S.D.C. figure, the natural abilities line and the bonus line read the same in both (D-Bees drops the S.D.C. line''s clause about needing magic or M.D.C. armor, and prints an M.D.C. line saying by body armor or other external protection). || HIT POINTS: both books print 2D6 +P.E. attribute number, plus 1D6 M.D. per level of experience starting at level one. The M.D. is a misprint on a Hit Points line of an S.D.C. being, repeated in D-Bees, and is read as 1D6 Hit Points per level; stored as hit_points_base. || S.D.C.: 1D4x10 plus those gained from Physical skills; stored as a pool bonus, never sdc_base, with men_of_arms false. D-Bees adds M.D.C.: By M.D.C. body armor or other external protection, and Horror Factor: Not applicable. || SKILLS: D-Bees R.C.C. Skills are Climbing (+20%), Dowsing (+15%), Prowl (+10%) and Swimming (+10%), in addition to the skills of any chosen O.C.C. Canada printed 138 gave R.C.C. Skills/Instincts: Climb +20% and Prowl +10% only, so Dowsing and Swimming are new with D-Bees. Climbing +20% over the catalog 40 is 60; Dowsing +15% over 20 is 35; Prowl +10% over 25 is 35; Swimming +10% over 50 is 60. || PSIONICS: D-Bees printed 145-146 prints the power list and an I.S.P. figure on the race itself: All Noli are Master Psychics with Bio-Regeneration (self, 6), Empathy (4), Mind Block (printed 40, read as the catalog Mind Block), Psionic Invisibility (10), Telepathy (4), two Physical and two Sensitive powers of choice, one more Physical or Sensitive power at each new level, one Super power of choice at levels 4, 8 and 12 excluding Psi-Sword, and I.S.P. of M.E. attribute number x2 plus 1D6+1 per level of experience; a Psi-Druid or Psi-Slayer ignores all of that and uses the psionics, I.S.P., skills and abilities of that O.C.C. Canada printed 138 gave Psionics: All Noli are effectively Master Psychics, although none are Mind Melters; see O.C.C.s, printed the same power list for the Noli Cowboy and Noli Scout only, and printed no I.S.P. figure at all. Stored as the class-level psionics type master, which holds for every Noli, plus a pick-one group of three options, because the package depends on the occupation: Psionics: Noli Master Psychic carries the package and the I.S.P. line for a Cowboy, Wilderness Scout or Vagabond; Psionics: Psi-Druid or Psi-Slayer carries no block; Psionics: Noli Cyber-Knight carries the tier and the I.S.P. line. Each option names its occupations. Bio-Regeneration is the Healing-category self power at 6 I.S.P., not the Super one. The Psi-Sword exclusion on the Super picks is in the note of those grants. || CYBER-KNIGHT: both books give a Noli Cyber-Knight Psi-Sword at 1st level and a total of six powers from the Sensitive and/or Physical categories in addition to those normally available to Cyber-Knights, because the occupation limits their natural range of psionic powers. Read as replacing the race package. The six additional powers are prose. Neither book prints an I.S.P. figure for the Noli Cyber-Knight by name; the D-Bees race line (M.E. x2 plus 1D6+1 per level) excepts only the Psi-Druid and Psi-Slayer, so it is stored on that option. || BONUSES: +1 initiative, +1 strike, +4 pull punch, +2 roll, +2 vs possession, +3 vs Horror Factor stored; the same line in both books. Needs 10 or higher to save vs psionic attacks and mind control is ability text. || OCCUPATIONS: D-Bees Available O.C.C.s are Psi-Druid, Psi-Slayer (the only two psychic O.C.C.s available to them), Cowboy, Wilderness Scout (any) or Vagabond (with leanings toward working with animals, farming and nature), and Cyber-Knight; stored as occ_restrictions.only. Canada printed 138 gave Psi-Druid, Psi-Slayer, Noli Cowboy or Noli Scout, and Cyber-Knight, with no Vagabond; it called the Noli Cowboy and Noli Scout effectively the Cowboy/Cow Puncher and Wilderness Scout O.C.C.s, and D-Bees no longer uses those two names. SKILL CUT: D-Bees says that in the case of the latter two the O.C.C. Related and Secondary Skill selections are reduced to three each, where the two named last are Wilderness Scout and Vagabond; Canada applied the same cut to the Noli Cowboy and Noli Scout. Stored as a restriction line, as printed. || CYBERNETICS: D-Bees adds Cybernetics and Bionics: Avoid them except for medical purposes, beside the sentence both books print (not candidates for M.O.M. and Juicer augmentation, and avoid bionics). || NPC AND BACKGROUND FIGURES, in GM Notes: alignment leanings (Principled 30%, Scrupulous 30%, Unprincipled 10%; Canada printed Any), NPC experience level 1D8, average life span 5D6+60 years with females living 2D6 years longer (Canada printed 138 gave 70-90 years, although a few claim to be older than 120), slave market value 2D4x1,000 credits, and the Lazlo, New Lazlo and Tolkeen numbers (Canada gave nearly one thousand at Lazlo, a few hundred at New Lazlo and three hundred joined to the crusade at Tolkeen). D-Bees also adds the nickname Green Scouts, the Inuit People and Mastadonoids among those the Noli get along with, Greots, Horune, Minions of Splugorth and slavers among those they have no love for, and Minnesota, New York, Vermont, New Hampshire, Massachusetts and Maine to the places they are found in small numbers; D-Bees does not restate supernatural evil among the enemies or the United States forests as a main habitat, and the GM Notes keep Canada there. || NOT STORED: size 5 ft 6 in to 6 ft, weight 120 to 160 pounds, the nicknames, allies, enemies and habitat. GM Notes still gives the allies, enemies and habitat as Canada printed them; the D-Bees additions are recorded in this note only."
---

## Lore

The Noli (say "no lee") are forest people of eastern Canada and the
United States, with some now settling in Ontario and Lower Michigan. They
are built much like humans but have green skin, tufts of dark green or
brown fur like dreadlocks or soft quills, a long thin neck and a large
melon-shaped head. The eyes are big and dark green, the nose and ears are
little more than holes, and the wide mouth is full of flat teeth for
grinding bark, roots, grass, fruit and nuts.

They are born woodsmen, yet they have nothing against machines. Many wear
light or partial armor, carry Mega-Damage weapons and love small fast
vehicles such as hovercycles, as well as horses, Fury Beetles and other
mounts. Towns do not trouble them, though they like small ones and open
country best. That mix makes them fine scouts, ranch hands, animal handlers
and explorers, and every one of them is a powerful psychic. Outsiders call
them Greenbeans or Greenies.

## GM Notes

The book heads the race an optional player character and NPC.

Every Noli who is not a Psi-Druid or Psi-Slayer has this psionic package:
Bio-Regeneration (self), Empathy, Mind Block, Psionic Invisibility,
Telepathy, two Physical and two Sensitive powers of choice, one more from
either category at each new level, and one Super power (never Psi-Sword)
at levels 4, 8 and 12. I.S.P. is the M.E. attribute number x2 plus 1D6+1
per level of experience. A Psi-Druid or Psi-Slayer ignores all of that and
uses the psionics, I.S.P., skills and abilities of that O.C.C. The book
lists Cowboy, Wilderness Scout (any) or Vagabond and cuts the O.C.C.
Related and Secondary Skill selections of the latter two to three each;
the G.M. and player apply the cut.

Alignment: any, leaning toward Principled (30%), Scrupulous (30%) and
Unprincipled (10%). NPCs are experience level 1D8 or as set by the Game
Master; player characters start at level one and use the Experience Table
of the chosen O.C.C. Standard equipment and money are as per O.C.C., with
a preference for spears and staves as weapons. Slave market value:
2D4x1,000 credits as fighters, scouts and slave labor.

A Noli Cyber-Knight is a rarity: Psi-Sword at 1st level and six powers in
all from the Sensitive and/or Physical categories, on top of the Knight''s
usual ones.

Size 5 feet 6 inches to 6 feet (1.7 to 1.8 m). Weight 120 to 160 pounds
(54 to 72 kg). Average life span 5D6+60 years; females live 2D6 years longer
than males. Physical maturity comes by age 17.

Allies: nothing formal. They get on with Native Americans, Psi-Stalkers,
Simvan, rogue Dog Boys and tolerant humans and D-Bees. Nearly one thousand
live in Lazlo and 400 at New Lazlo. A thousand perished in the
Coalition-Tolkeen War.

Enemies: the Coalition and the Quebec military, at whose hands they have
suffered, and the Xiticix, Yeno, Loup Garou, vampires and supernatural
evil. They are wary of other strong psychics, think Mind Melters and Mind
Bleeders dangerous, and stay away from Psyscape.

Habitat: mostly Ontario, Quebec and the eastern forests of Canada and the
U.S., with small numbers in Manitoba, Michigan, Illinois and Wisconsin.
',
       updated_at = datetime('now')
 WHERE class_id = 'noli-bushman'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.137-138') > 0
   AND length(markdown) = 7153;

-- == yeno ==
UPDATE imported_classes
   SET markdown = '---
id: yeno
men_of_arms: false
name: Yeno
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.215-217
category: rcc
tags: [ranged, combat]
attribute_dice:
  IQ: "3d6"
  ME: "2d6"
  MA: "2d6"
  PS: "3d6"
  PP: "3d6+5"
  PE: "3d6"
  PB: "1d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "2d6"
horror_factor: 11
psionics_allowed: false
occ_restrictions:
  except: ["group:magic", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "maxi-killer", "mega-juicer", "phaeton-juicer", "titan-juicer", "ninja-juicer", "crazy", "ultra-crazy", "ninja-crazy"]
  note: "Nearly any, but the belligerent D-Bees lean toward Assassin, Spy, Bandit, Bounty Hunter, Gunfighter, Gunslinger, Commando, Special Forces, Merc Soldier, and other Men at Arms, military or criminal O.C.C.s, seldom any other professions. Never magic. Their alien physiology makes Juicer and Crazy conversions impossible."
bonuses:
  pools: { sdc: "5d6+30" }
  combat: { initiative: 2, perception: 2, disarm: 1, pull_punch: 1, roll: 2 }
  saves: { horror_factor: 4 }
natural_abilities:
  - name: "Senses and energy resistance"
    description: "Sharp, hawk-like vision, and sees in all spectrums of light, including infrared and ultraviolet. Cannot be blinded by bright light or glare. Resistant to all energy attacks (half damage), but takes full damage from kinetic attacks, such as M.D. punches, kicks, claw strikes, rail guns and explosives."
  - name: "Fire Energy Bolts"
    description: "Energy blasts that inflict S.D.C. or M.D. Damage is the character''s choice each shot: 4D6 S.D.C., 2D4x10 S.D.C., 1D6 M.D., 2D6 M.D. or 4D6 M.D.; each blast counts as one melee attack. Range 1000 feet (305 m) +30 feet (9.1 m) per level of experience. When using energy blasts only, the Yeno gets an extra two attacks per melee; not applicable to hand to hand combat or guns. +3 to strike with natural energy blasts, +1 more at levels 3, 5, 7, 10 and 13."
  - name: "Blinding Flash"
    description: "Can emit a beam at a specific target, or an area effect flash of blinding light around the body. Effects are the same as the spell Blinding Flash."
  - name: "Generate Light"
    description: "Can make the hands glow to give light equal to a low intensity lantern, but can only see about six feet (1.8 m) ahead by it, which does not put a Yeno at ease if trapped in total darkness."
  - name: "Force Field"
    description: "Raised at the speed of thought: 2D4x10 M.D.C. plus the P.E. attribute number, plus 3D6 M.D.C. per level of experience starting at level one. To determine whether the field was raised in time to block an attack, roll for initiative; the Yeno gets a bonus of +2 at levels 1, 3, 4, 6, 8, 10, 12 and 14 that applies ONLY to raising the force field. It can be maintained indefinitely while the Yeno is conscious and regenerates lost M.D.C. at 12 points per hour, double while sleeping or meditating. If the field is depleted the Yeno cannot raise it again for at least one hour, and it then starts with only 12 M.D.C., increasing with each passing hour. On an S.D.C. world: Hit Points of 1D6x10 plus the P.E. attribute number, +1D6 per level, 1D6x10 S.D.C., a natural A.R. of 10, and the force field is S.D.C. point for point with an A.R. of 19."
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Anarchist, Miscreant or Diabolic."
  - "Psionics: none, other than the art of Meditation at no I.S.P. cost. Magic: none."
  - "M.D.C.: only via body armor or the natural M.D.C. force field; the body is Hit Points and S.D.C."
  - "Never a magic O.C.C. Alien physiology makes Juicer and Crazy conversions impossible."
  - "Cybernetics and Bionics: tend to avoid them. Getting more than half the body replaced with bionics reduces the energy powers by half (half damage, range, etc.)."
  - "Experience table, Standard Equipment and Money: as per the chosen O.C.C."
side_effects: "Vulnerabilities: alien physical appearance makes disguise difficult. Phobia: Darkness. Tends to panic when blinded or trapped in darkness, and suffers greater penalties, applied on top of the normal ones for being blind: -3 to all combat maneuvers (i.e. -13 for being blind), the number of melee attacks and Spd are reduced by half, and skill performance is -30%. Also dislikes small, cramped places and being in, on or over water; does not like boating."
extraction_notes: "Originally Rifts World Book 20: Canada printed 139-140; the class followed that printing until this update to Rifts World Book 30: D-Bees of North America printed 215-217 (ruling of 2026-10-04: the newest printing that states a figure wins, and the older figure is kept in a note). Both books were read off page renders (D-Bees cache p216-p218, Canada cache p140-p141). Heading in both: Yeno, Optional Player Character and NPC. D-Bees closes with Note: Original appearance, Rifts World Book 20: Canada. || CATEGORY: a race that takes an occupation in both printings; Standard Equipment is As per O.C.C. in both, D-Bees adds Money: As per O.C.C. and Use the experience table of the chosen O.C.C. No skills are printed and no xp_table is stored. men_of_arms false: a race. || BODY: D-Bees prints Hit Points: 1D6 +P.E. attribute number, +1D6 M.D. per level of experience, starting at level one (the M.D. is as printed; stored as hit points, hit_points_base P.E. plus 1D6 per level), S.D.C.: 5D6+30 plus those gained from Physical skills (stored as a pool bonus), and M.D.C.: Via body armor or natural M.D.C. force field. Canada printed 139 gave Mega-Damage: Minor M.D.C. creature, 2D4x10 +P.E. attribute number plus 3D6 M.D. per level of experience starting at level one, which the class stored as mdc_base until this update; mdc_base is removed. || FORCE FIELD: D-Bees gives the field 2D4x10 M.D.C. +P.E. attribute number and an additional 3D6 M.D.C. per level starting at level one, the figure Canada gave the body. Canada printed 139 gave the field 30 M.D.C. +10 points per level (30 S.D.C. +10 per level on an S.D.C. world) and said it was raised around himself (only). The +2 at levels 1, 3, 4, 6, 8, 10, 12 and 14 to initiative for raising the field is new in D-Bees, conditional, and is ability text. The S.D.C.-world figures (1D6x10 +P.E. Hit Points, 1D6x10 S.D.C., +1D6 H.P. per level, Natural A.R. 10) are the same in both books; D-Bees adds that the field is S.D.C. point for point with an A.R. of 19. Regeneration 12 points an hour, double asleep or meditating, and the one hour and 12 M.D.C. after depletion are the same in both. || HORROR FACTOR: 11 in D-Bees; Canada printed none. || NATURAL ABILITIES: D-Bees adds hawk-like, including infrared and ultraviolet, and Cannot be blinded by bright light or glare, and adds Blinding Flash (special) and Generate Light (special); Canada printed neither. Canada''s Natural Abilities line ended Ornery and quick to attack, which D-Bees moves to a Disposition paragraph. Energy bolt damage steps and range are the same in both (Canada 9 m, D-Bees 9.1). || BONUSES: D-Bees prints +2 on initiative, +2 on Perception Rolls, +3 to strike with natural energy blasts (+1 at levels 3, 5, 7, 10 and 13), +1 to disarm, +1 to pull punch, +2 to roll with impact, and +4 to save vs Horror Factor. Canada printed 139 gave +2 on initiative, +3 to strike with natural energy blasts, +2 to roll with punch, fall or impact, and +4 to save vs Horror Factor: perception, disarm, pull punch and the strike increments are new. The strike bonus is conditional and is ability text. || COMBAT: attacks as per Hand to Hand Combat skill and bonuses, plus an extra two per melee when using energy blasts only, not applicable to hand to hand combat or guns; the same rule as Canada printed 139-140. Conditional, so ability text. || VULNERABILITIES and CYBERNETICS AND BIONICS are new paragraphs in D-Bees; Canada printed neither. || PSIONICS: None, other than the art of Meditation at no I.S.P. cost (Canada: None, other than the art of meditation), stored as psionics_allowed false; Meditation is not granted as a power. || ALIGNMENT: Any, but most are Anarchist (30%), Miscreant (30%) or Diabolic (30%); the percentages are new in D-Bees. That is not a restriction, so no evil tag. || OCCUPATIONS: D-Bees prints Nearly any, but the belligerent D-Bees lean toward Assassin, Spy, Bandit, Bounty Hunter, Gunfighter, Gunslinger, Commando, Special Forces, Merc Soldier, and other Men at Arms, military or criminal O.C.C.s, seldom any other professions. Never magic. Their alien physiology make Juicer and Crazy conversions impossible and they avoid bionic reconstruction. Stored as occ_restrictions.except: the magic group, the fourteen Juicer conversions (juicer, coalition-juicer, delphi-juicer, dragon-juicer, euro-juicer, hyperion-juicer, juicer-assassin, juicer-gladiator, juicer-scout, maxi-killer, mega-juicer, phaeton-juicer, titan-juicer, ninja-juicer) and the three Crazies (crazy, ultra-crazy, ninja-crazy). Juicer Wannabe is not a conversion and is not excepted; Songjuicer is in the magic group. Bionic occupations are avoided, not barred, and are not excepted. Canada printed 140 gave A Yeno can be the equivalent of an Assassin, Commando, Special Forces, Spy/Espionage agent, Grunt, Bandit, Bounty Hunter or Gunslinger, which the class stored as occ_restrictions.only bandit, bounty-hunter, gunslinger and merc-soldier until this update. || NOT STORED, in GM Notes: size 6 feet and weight 140 to 180 pounds (same in both); average life span 6D6+170 years and physical maturity at 19 (Canada: Uncertain, at least 200 years, quite possibly longer); NPC experience level 2D4; slave market value 1D6x10,000 credits; the alignment percentages; allies, enemies and habitat. D-Bees says fewer than 2,000 were originally believed to exist in North America and that the number has since been adjusted to three times as many; Canada printed 140 gave Fewer than 2000."
---

## Lore

The Yeno are rare, strange D-Bees met now and then in central and eastern
Canada and the American Midwest: tall, thin humanoids with scaly skin of
yellow, red and orange, a melon-shaped head, burning yellow eyes and three
fingers on each hand. Nearly all of them seem to be in a foul temper every
waking hour and take offense at almost anything. Nobody knows why, and
frontier sayings about their mood are common.

People also call them Energy Weavers or Energy Men, because they soak up
and shape energy. A Yeno throws Mega-Damage bolts from its hands and eyes
and can wrap itself in a faint field of force as quickly as it can think,
which makes one very hard to kill unless it is caught asleep. They are
notorious as assassins, hired killers, bounty hunters, bandits and
gunslingers, and a Yeno gunslinger may carry a handgun beside its own
blasts.

## GM Notes

The book heads the race an optional player character and NPC.

Not added by the sheet: +3 to strike with natural energy blasts (+1 more
at levels 3, 5, 7, 10 and 13), and two extra attacks per melee round when
the Yeno attacks only with energy blasts. The force field has 2D4x10
M.D.C. plus the P.E. attribute number, +3D6 per level, and the Yeno gets
+2 on initiative to raise it at levels 1, 3, 4, 6, 8, 10, 12 and 14.

The book lets a Yeno take nearly any O.C.C. except a magic one, a Juicer
or a Crazy; they lean toward Assassin, Spy, Bandit, Bounty Hunter,
Gunfighter, Gunslinger, Commando, Special Forces, Merc Soldier and other
Men at Arms, military or criminal occupations.

Size 6 feet (1.8 m). Weight 140 to 180 pounds (63 to 81 kg). Average life
span 6D6+170 years; physical maturity by the age of 19. Females give birth
to a single young after a 10 month pregnancy. Yeno like powerful, accurate
energy weapons.

Alignment: any, but most are Anarchist (30%), Miscreant (30%) or Diabolic
(30%). NPC experience level 2D4 or as set by the Game Master; player
characters start at first level. Slave market value 1D6x10,000 credits.

Allies: other killers, bandits and cutthroats. Though they do not show it
and would never admit it, they rather like humans and Grackle Tooth. They
hate Kraks, Fingertooth and other nice or friendly people. Enemies: anyone
who gets in their way, causes them trouble or gets on their nerves. They
strongly dislike the Coalition, Cyber-Knights, lawmen, Psi-Stalkers and
Quick-Flex aliens, hold life cheap, see most other races as inferiors or
rivals, and hate the undead.

Habitat: found anywhere, but most common in Manitoba, Ontario, Quebec,
Wisconsin, Minnesota, the Dakotas and the New West. More than usual,
around a dozen, are said to have turned up at Tolkeen and in the New West.
Fewer than 2000 were originally thought to exist in North America; that
number has since been adjusted to three times as many.
',
       updated_at = datetime('now')
 WHERE class_id = 'yeno'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.139-140') > 0
   AND length(markdown) = 6815;

-- == faerie-bot ==
UPDATE imported_classes
   SET markdown = '---
id: faerie-bot
name: Faerie Bot
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.76-79
category: rcc
tags: [supernatural, tech]
xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 71801, 96901, 137001, 188001, 229201, 279301, 340401]
attribute_dice:
  IQ: "1d4+10"
  ME: "1d4+10"
  MA: "1d6+10"
  PS: "1d6+2"
  PP: "1d6+8"
  PE: "1d6+10"
  PB: "1d6+2"
  Spd: "2d6"
hit_points_base: "P.E. + 2d6, +1d6 per level"
sdc_base: "1d4x10"
ppe_base: "3d4x10, +10 per level"
psionics:
  type: "master"
  isp_base: "M.E. x10, +5 per level"
  powers: ["Empathy", "Object Read (Psychometry)", "Mind Bolt", "Telemechanics", "Telemechanic Mental Operation", "Telemechanic Paralysis"]
  powers_starting: 0
magic:
  type: "spell"
  spells: ["Globe of Daylight", "Ignite Fire", "Fuel Flame", "Fire Bolt", "Call Lightning", "Energy Bolt", "Energy Field", "Impervious to Energy", "Manipulate Objects"]
  spells_starting: 2
  spells_per_level: 2
  spell_levels_allowed: [1, 2, 3, 4]
bonuses:
  combat: { initiative: 1, strike: 1, pull_punch: 4, roll: 2 }
  saves: { possession: 2, horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Basic Electronics", base: 50, per_level: 5, note: "+20%" }
    - { name: "Basic Mechanics", base: 60, per_level: 5, note: "+30%" }
    - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Computer Repair", base: 40, per_level: 5, note: "+15%" }
    - { name: "Cybernetics: Basic", base: 35, per_level: 5, note: "+10%" }
    - { name: "Field Armorer & Munitions Expert", base: 60, per_level: 5, note: "The book prints Field Armorer (+20%)." }
    - { name: "General Repair & Maintenance", base: 65, per_level: 5, note: "+30%" }
    - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Language and Literacy: Native Tongue at 98%; an alien language." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Language and Literacy: Native Tongue at 98%; an alien language." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other, one of choice (+10%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic and Advanced (+20%)." }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "Math: Basic and Advanced (+20%)." }
    - { name: "Navigation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20%" }
    - { name: "Prowl", base: 50, per_level: 0, note: "Natural ability: tiny size gives an automatic Prowl of 50%. The sphere itself prowls at 60% flying or hovering, 75% when trying to be unseen, 90% hiding motionless." }
  occ_related_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Mechanical", bonus: 10 }
      - "Science"
      - "Technical"
    note: "Select two at levels 1, 4, 8 and 12, from these categories only. Mechanical: any (+10%). Technical: any, with +10% to Research and any Lore skill only. All new skills start at first level experience."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 0
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
      - { level: 14, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "work-overalls", qty: 2 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "work-gloves-rifts", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: "2d6" }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "portable-hand-held-computer", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "pencil", qty: "1d4" }
  - { choose: 1, label: "pen or marker", qty: 1, from: ["pen", "marker"] }
natural_abilities:
  - name: "Senses"
    description: "Sharp vision, nightvision 300 feet (91.5 m), and a natural polarizing lens: a thin second eyelid that slides over the eye against bright light and works like polarized sunglasses."
  - name: "Natural Mechanics"
    description: "On top of the psionic machine powers, can soup up most machines to run, move or fly 10-20% faster, works out how to use and operate most machines including Techno-Wizard devices, and strips, repairs and reassembles machines three times faster than a human. Artificial intelligences and computers baffle it: -35% when working on them, and it cannot hack computers."
  - name: "Tiny size"
    description: "Stands 1D4+8 inches tall. The tiny size gives an automatic Prowl of 50%."
  - name: "Techno-Wizard powers"
    description: "An alien version of a Techno-Wizard in miniature: has all the basic Techno-Wizard O.C.C. Magic Powers and TW Construction abilities (Rifts Ultimate Edition, Techno-Wizard O.C.C.). All spells should be suitable for Techno-Wizard application and carry the same limitations as the Techno-Wizard O.C.C."
  - name: "Half-strength magic and little sleep"
    description: "Casts its spells at half the normal strength, range and duration. Needs only three hours of sleep per 24 hours."
  - name: "Faerie Bot Vehicle"
    description: "Every Faerie Bot flies a sphere the size of a basketball, which its people call an All-Environment Exploration Biosphere, or Eeb. Two or three primary arms (at least one a utility arm and hand; equivalent P.S. 1D6+12); 1 or 2 secondary appendages such as a tentacle or sensor antenna (equivalent P.S. 1D4+5); 2-4 retractable tool appendages, half with interchangeable heads and half specialized (laser cutter, plasma torch, electro-magnetic adhesive pad and the like); 1 or 2 light weapons, typically a laser, range 2,000 feet (610 m), 2D6 to 3D6 M.D.; tow line with hook and grapple, 30 feet (9 m), 500 lb (225 kg) test, and anything above 300 lb (135 kg) slows the sphere by 25%; universal language translator at 93%, speaking back by loudspeaker or radio; directional narrow and wide band radio, 100 mile (160 km) range, and the vehicle can be hailed and controlled by radio and psionics; multi-optics; proximity alarm at 10 feet (3 m); unlimited unknown power supply and unknown hover and propulsion system. Flight: hovers, lands and flies to 150 mph (240 km), cruising at 10-30 mph (16 to 48 km), maximum altitude 60,000 feet (18,288 m), and it can survive and navigate in outer space. Propulsion is completely silent: Prowl 60% when flying or hovering, 75% when trying to be unseen, 90% if hiding, concealed and motionless. Underwater: 60 mph (96 km) on or under the surface, depth one mile (1.6 km). M.D.C.: legs (2) 12 each, main arms (2-3) 20 each, secondary limbs and tool appendages (1-4) 10 each, main body 120, and it is -3 to strike even with a called shot. Self-repairs about 40 M.D.C. unaided; more needs the pilot, time and parts, and a destroyed sphere takes 1D4+6 months to rebuild. A failsafe makes it self-destruct when its designated pilot is killed: the internal systems burn out, any P.P.E. reserve is released and it crumbles to junk, wires and dust."
trackable_resources: []
restrictions:
  - "The book heads it an optional player character or NPC. Player characters should start at first or second level. Canada''s Player Note, which D-Bees of North America does not restate, leaves allowing one entirely to the G.M.''s discretion."
  - "Alignment: any, but most are Anarchist."
  - "Available O.C.C.s: none. All are effectively a Techno-Wizard/Scientist or TW Explorer/Operator through the R.C.C.: these skills only, plus the Magic Powers and TW Construction abilities of the Techno-Wizard O.C.C."
  - "R.C.C. Related Skills, Technical: the +10% applies to Research and Lore skills only. Secondary skills get no bonus other than a high I.Q. bonus."
  - "Psionics: effectively a Master Psychic, but limited to the six listed powers. Needs a 10 or higher to save vs psionic attack and mind control."
  - "Magic: the nine listed spells plus two of choice per level of experience from spell levels 1-4, all cast at half the normal strength, range and duration. All spells should be suitable for Techno-Wizard application and have the same limitations as the Techno-Wizard O.C.C."
  - "M.D.C.: only through the Faerie Bot vehicle, magic or body armor. Needs magic or M.D.C. body armor for protection against M.D. weapons, just like a human."
  - "Combat: attacks per melee round are as per the Hand to Hand Combat skill, if any; a psionic attack counts as one melee action. Damage is as per P.S., psionics, magic or weapon."
  - "Standard equipment is all at tiny size, made for the doll-sized D-Bee. Also carried, beyond the listed items: comfortable boots, a suit of environmental body armor (1D6+22 M.D.C.), a box of 50 plastic gloves, a portable radio and language translator (10 mile/16 km range), a protective helmet with built-in language translator, radio and loudspeaker, a comb and some personal items, and the Faerie Bot Vehicle."
  - "Cybernetics and Bionics: admires machines but avoids getting bionics itself."
side_effects: "Cannot resist messing with machinery, especially something it has never seen before or that is broken, including other people''s property; it needs only three hours of sleep and wanders off to explore or tinker when bored, so its curiosity gets it and its friends into trouble. Vulnerability: its tiny size leaves it open to attack even from small predatory animals such as cats and dogs, as well as birds of prey and larger animals. Fears the Minions of Splugorth, Horune Pirates, Faerie Folk, dragons and other creatures of magic, and is wary of practitioners of magic other than Techno-Wizards."
extraction_notes: "ORIGINAL: this class followed Rifts World Book 20: Canada printed 149-152 until this update; under the ruling of 2026-10-04 the newest printing that states a figure wins, so it now follows Rifts World Book 30: D-Bees of North America printed 76-79 (cache p077-p080, cache page = printed folio + 1), whose entry is headed Faerie Bot D-Bee and ends with the note Originally appeared in Rifts World Book 20: Canada. Every figure was read off page renders of both books (Canada printed 149 and 151; printed 150 is a full-page illustration). || HEADING: optional player character or NPC; imported as a playable R.C.C. on the repo owner''s decision for Canada''s optional player creatures. Canada printed 149 carried a Player Note leaving it to the G.M.''s discretion; D-Bees does not restate it and it is kept as a restriction line. || NATURE: D-Bees says the Faerie Bot is a tiny mortal humanoid D-Bee and that reports of an innate magical nature are wrong; Canada printed 149 called them creatures of magic. The natural ability named Creature of magic became Half-strength magic and little sleep; the authored tags are left as they were. || XP: D-Bees printed 78 says Use the same Experience Table the Techno-Wizard; the ladder is copied from the stored xp_table of the catalog class techno-wizard (Rifts Ultimate Edition). Canada printed 192 sent the Faerie Bot to the Dragon table, and the row held the ladder of dragon-hatchling: 0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001. || ATTRIBUTES: identical in both books. || HIT POINTS: both books print Hit Points: 2D6 +P.E. attribute number. Plus 1D6 M.D. per level of experience, starting at level one, and then S.D.C.: 1D4x10 plus those gained from Physical skills; need magic or M.D.C. body armor for protection against M.D. weapons, just like humans. D-Bees adds M.D.C.: Via Faerie Bot vehicle, magic or body armor. It is stored as an S.D.C./hit point being: hit_points_base P.E. + 2D6 with the per-level 1D6 read as hit points, and sdc_base 1D4x10; no mdc_base. || P.P.E. 3D4x10 +10 per level and I.S.P. M.E. x10 +5 per level are the same in both books. || PSIONICS: All are effectively Master Psychics, limited to six powers, granted by name with no picks; the same six in both books. The book prints Object Read; the catalog row is Object Read (Psychometry). D-Bees adds the I.S.P. costs: Empathy 4, Object Read 6, Mind Bolt varies, Telemechanics 10, Telemechanic Mental Operation 12, Telemechanic Paralysis 20. || MAGIC: nine named spells granted, plus two of choice per level of experience from spell levels 1-4, stored as spells_starting 2 and spells_per_level 2 with levels 1-4. D-Bees printed 79 lists the ninth spell as Manipulate Objects (2+); Canada printed 151 gave Telekinesis, which is no longer granted. Call Lightning and Impervious to Energy are level 6 in the catalog and granted by name. Half strength, range and duration is a restriction line. D-Bees adds that all spells should suit Techno-Wizard application with the Techno-Wizard O.C.C.''s limitations, and that the class has all the basic Techno-Wizard O.C.C. Magic Powers and TW Construction abilities; those are stored as natural ability and restriction text that points at the Techno-Wizard O.C.C., whose own pages were not re-read for this update. || BONUSES: +1 initiative, +1 strike, +4 pull punch, +2 roll, +2 vs possession, +3 vs Horror Factor, the same in both books. The master psychic save of 10 comes from the psionic tier. || SKILLS: D-Bees printed 78 restates the R.C.C. Skills line as bonuses over a longer list, stored at catalog base plus the printed bonus with the catalog''s per-level: Anthropology +15%, Basic Electronics +20%, Basic Mechanics +30%, Computer Operation +20%, Computer Repair +15%, Cybernetics: Basic +10%, Field Armorer +20% (catalog row Field Armorer & Munitions Expert), General Repair & Maintenance +30%, Jury-Rig +20%, Land Navigation +15%, Language and Literacy: Native Tongue at 98% (stored on both Language: Native Tongue and Literacy: Native Language), Language: Other one of choice +10%, Math: Basic and Advanced +20%, Navigation +20%, Radio: Basic +20%, Sensory Equipment +20%. Canada printed 151 gave basic and advanced math, basic electronics, basic mechanics, general repair/maintenance and field armorer all at a flat 95%, prowl (while in their sphere) and find contraband at 60%, and land navigation 70% +2% per level as a natural ability. Find Contraband is not in the D-Bees line and was removed. Prowl: D-Bees prints an automatic Prowl 50% from tiny size under Natural Abilities, stored as the skill at a flat 50, and gives the 60% to the vehicle (75% unseen, 90% hiding motionless). || RELATED AND SECONDARY SKILLS: new in D-Bees printed 78. Related: two at levels 1, 4, 8 and 12 from Communications, Domestic, Mechanical (+10%), Science and Technical; the Technical bonus is +10% to Research and any Lore skill only, which is a note and a restriction line, not a category bonus. Secondary: two at levels 3, 5, 8, 11 and 14 and none at level one, stored as count 0 with a schedule. Canada printed neither. || O.C.C.: D-Bees prints Available O.C.C.s: All are effectively a Techno-Wizard/Scientist or TW Explorer/Operator, see R.C.C. above; the class takes no O.C.C. and that is a restriction line. Hand to Hand: attacks are As per Hand to Hand Combat skill, if any; the R.C.C. grants no Hand to Hand skill and its related categories do not include Physical. || EQUIPMENT: D-Bees printed 79 adds a personal equipment list, all at tiny size, where Canada''s Standard Equipment was the Faerie Bot Vehicle alone. Items with a catalog row are in equipment_starting (the catalog rows are the ordinary human-sized items); comfortable boots, the environmental body armor of 1D6+22 M.D.C., the box of 50 plastic gloves, the portable radio and language translator, the protective helmet, the comb and personal items have no matching row and are a restriction line. The Faerie Bot Vehicle has no catalog row (suggested slug faerie-bot-vehicle); its full statistics are natural ability text. || VEHICLE: D-Bees adds Legs (2) 12 M.D.C. each, main arms 2-3 where Canada printed 2, a 100 mile radio range, control by radio and psionics, the name All-Environment Exploration Biosphere or Eeb, the vehicle''s Prowl figures, and a maximum altitude of 60,000 feet with outer space survival where Canada printed Unknown, at least 30,000 feet (9144 m) and may be outer space capable. The crumbling of the sphere at its pilot''s death is now a deliberate failsafe. The attribute line gives Spd 2D6 running; the sphere''s 150 mph flight is not a class number. || NOT STORED, in GM Notes: size 1D4+8 inches (Canada 8-12 inches); weight 2-5 lb and sphere 60-70 lb (Canada 1-2 lb and 40-70 lb); average life span 4D6+50 years (Canada: Unknown. Immortal?); average NPC level 1D4+4; Horror Factor not applicable; disposition, habitat, allies and enemies. Neither book prints money."
---

## Lore

Faerie Bots came to Rifts Earth on purpose, through a Rift in the ruins
of Detroit some thirty years ago, and for a long time were seen only
around the industrial centers of southern Canada, Michigan and
Chi-Town. They are not kin to the true Faerie Folk of Earth and are not
creatures of magic at all: they are tiny mortal D-Bees about a foot
tall, with a wide shield-shaped head, big round coal-black eyes, a small
nose and a large mouth. What sets them apart is the machine. Each one
rides inside a floating sphere the size of a basketball, bristling with
little arms, tools and antennae, and so seldom steps out that scholars
once took the pilot and the sphere for a single robot. The name stuck.

They are tinkerers to the bone. Robots, power armor, cyborgs and vehicles
fascinate them, and they understand almost any machine at a glance; only
computers and artificial minds leave them stumped. Their own spheres
run on a science very like Techno-Wizardry that nobody else has
managed to study, because a sphere falls to scrap and dust the moment
its pilot dies.

Small groups of three to a dozen live together, and singles or pairs
roam for years. They are shy, curious and playful, fond of humans and
Sasquatch, and now and then one attaches itself to a band of
adventurers. It means well and tries to help. It also sleeps three hours
a night and cannot leave a machine alone, including machines that belong
to somebody else, so its friends spend a good deal of time apologizing.

## GM Notes

The book heads the Faerie Bot an optional player character or NPC; a
player character starts at first or second level. It levels on the
Techno-Wizard experience table. Also called Techno-Faeries and Bubble
Faeries; the race''s real name is Fraanids.

They came to study Rifts Earth, coming and going through the Detroit
Rift for 25 years until a shift in its harmonic frequencies shut the
door in the spring of 104 P.A. Those on Earth are trapped. Some keep
hidden base camps and go on studying; others have made contact with
Lazlo and New Lazlo, at least a hundred are exploring the Magic Zone,
and some join adventurers in the hope of finding a way home.

Hit points and M.D.: the book adds "1D6 M.D. per level" to the Hit
Points line, then says under S.D.C. that the creature needs magic or
M.D.C. armor against M.D. weapons, as a human does. The sheet treats it
as a hit point and S.D.C. being, with the 1D6 per level as hit points.
The sphere is the M.D.C. part: 120 main body.

The Faerie Bot Vehicle is the creature''s standard equipment and is
described in full under the natural abilities. The gear catalog has no
row for it. Out of the sphere the creature speaks only its own squeaky
language, which is not Earth''s Faerie tongue; the sphere''s translator
handles every language at 93%.

Spells are cast at half strength, range and duration.

Size 1D4+8 inches (23 to 30.5 cm); weight 2-5 pounds (0.9 to 2.25 kg),
the sphere 60-70 lb (27 to 31.5 kg). Average life span 4D6+50 years,
mature at 16. NPCs average level 1D4+4. Horror Factor: not applicable.

Habitat: anywhere in North America, but mainly the Domain of Man, where
technology is thickest: southern Canada, Lazlo, Michigan, the Coalition
States of Iron Heart and Chi-Town, and Free Quebec. Very rare, perhaps
as many as 500 on Earth. Allies: their own kind, Lazlo and New Lazlo;
they especially like humans, Dog Boys, Quick-Flex Aliens, Grackle
Tooth, Kraks, Fingertooth Carpetbaggers, A''rac, Adna Nomads and
Dewtani, and feel a kinship with Operators, Rogue Scholars, Rogue
Scientists, Techno-Wizards and Psi-Techs. Enemies: none as such, though
they know demons for evil and hate slavers, tyrants and oppressors.

The block prints no money.
',
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.149-152') > 0
   AND length(markdown) = 11401;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'all 11 classes cite D-Bees of North America' AS assertion, count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE (class_id = 'centaur' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.44-45') > 0)
    OR (class_id = 'cyber-horsemen-of-ixion' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.51-54') > 0)
    OR (class_id = 'true-sasquatch' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.173-176') > 0)
    OR (class_id = 'worldly-sasquatch' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.176-177') > 0)
    OR (class_id = 'aardan-tek' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.9-11') > 0)
    OR (class_id = 'grackle-tooth' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.97-98') > 0)
    OR (class_id = 'greot-hunter' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.98-100') > 0)
    OR (class_id = 'mastadonoid' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.134-135') > 0)
    OR (class_id = 'noli-bushman' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.144-146') > 0)
    OR (class_id = 'yeno' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.215-217') > 0)
    OR (class_id = 'faerie-bot' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.76-79') > 0);

SELECT 'none still carries its old source line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'centaur' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.102-103') > 0)
    OR (class_id = 'cyber-horsemen-of-ixion' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.103-107') > 0)
    OR (class_id = 'true-sasquatch' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.162-166') > 0)
    OR (class_id = 'worldly-sasquatch' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.166') > 0)
    OR (class_id = 'aardan-tek' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.130-132') > 0)
    OR (class_id = 'grackle-tooth' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.133-134') > 0)
    OR (class_id = 'greot-hunter' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.135') > 0)
    OR (class_id = 'mastadonoid' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.137') > 0)
    OR (class_id = 'noli-bushman' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.137-138') > 0)
    OR (class_id = 'yeno' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.139-140') > 0)
    OR (class_id = 'faerie-bot' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.149-152') > 0);

SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('centaur', 'cyber-horsemen-of-ixion', 'true-sasquatch', 'worldly-sasquatch', 'aardan-tek', 'grackle-tooth', 'greot-hunter', 'mastadonoid', 'noli-bushman', 'yeno', 'faerie-bot') AND instr(markdown, char(13)) > 0;

SELECT 'all 11 are still live and published' AS assertion, count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE class_id IN ('centaur', 'cyber-horsemen-of-ixion', 'true-sasquatch', 'worldly-sasquatch', 'aardan-tek', 'grackle-tooth', 'greot-hunter', 'mastadonoid', 'noli-bushman', 'yeno', 'faerie-bot') AND deleted_at IS NULL AND status = 'published';

INSERT INTO data_script_runs (filename) VALUES ('~097-d-bees-updates-eleven-canada-classes.sql');
