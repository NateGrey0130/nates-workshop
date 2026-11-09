-- BOOK-INGEST-AUDIT F140 residue: the War-Knight's printed psionics percentages (12% Minor, 4% Major, 2% Master) as a banded pick group with psionics_allowed: false; Warlords of Russia printed 92.
-- 1 class, each replaced whole: war-knight.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~270-book-ingest-audit-f140-war-knight-psi.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == war-knight ==
UPDATE imported_classes
   SET markdown = '---
id: war-knight
name: War-Knight
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.91-94
category: occ
tags: [combat, leader]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 52521, 74001, 100001, 135201, 190301, 240401, 290501, 350601]
attribute_requirements: { IQ: 9, PS: 12, PP: 12 }
race_restrictions: { only: ["none"], note: "Exclusively human." }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d4x1000"
psionics_allowed: false
bonuses:
  combat: { initiative: 1, roll: 1, pull_punch: 1 }
  saves: { horror_factor: 1, possession: 2 }
  at_level:
    - { level: 2, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 3, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 4, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 5, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 6, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 7, combat: { pull_punch: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 9, combat: { pull_punch: 1 } }
    - { level: 10, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 11, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, combat: { initiative: 1, disarm: 1 }, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, categories: [{ name: "Technical", only_prefix: ["Lore:"] }, { name: "Cowboy", only_prefix: ["Lore:"] }], note: "Lore: one of choice." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: Knight", base: 40, per_level: 5 }
    - { name: "Horsemanship: Exotic Animals", base: 45, per_level: 5, note: "+15%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking (+10%)." }
    - { name: "Military Etiquette", base: 55, per_level: 5, note: "+20%" }
    - { name: "Military Fortification", base: 40, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Streetwise", base: 26, per_level: 4, note: "+6%, as printed." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Including Vibro-Swords." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book prints W.P. Energy Heavy." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P. of choice (any)." }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Hand to Hand: Martial Arts (or Assassin if evil)." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", except: ["Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Helicopter", "Jet Aircraft", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing", "Robot Combat: Basic", "Robot Combat Elite", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Choose four other skills at level one. Communications: any (+5%). Domestic: any. Electrical: Basic only. Espionage: any. Mechanical: none. Medical: First Aid only (+10%). Military: any (+10%). Physical: any. Pilot: any, except robots, ships and aircraft (+10% to all horsemanship/riding skills). Pilot Related: any. Rogue: none, other than Streetwise above. Science: Astronomy and Math only. Technical: any (+10%). W.P.: any. Wilderness: any."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Helicopter", "Jet Aircraft", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing", "Robot Combat: Basic", "Robot Combat Elite", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Three secondary skills from the list at level one and one more at levels 3, 5, 7, 10 and 13, without the bonuses in parentheses."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { choose: 1, label: "large Vibro-Sword or Vibro-Axe (3D6 M.D.)", qty: 1, from: ["vibro-sword", "vibro-axe"] }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "knife-silver-plated", qty: 1, note: "The book says a silver survival knife." }
  - { item_id: "wooden-cross", qty: 1, note: "Hand-held." }
  - { item_id: "war-knight-combat-shield", qty: 1, note: "Small to medium Mega-Damage shield, 30 M.D.C., for parrying and blocking, particularly when charging." }
  - { item_id: "light-mdc-body-armor", qty: 1, note: "A suit of light body armor for quiet moments in a large War Camp." }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a cape or cloak." }
  - { item_id: "gloves", qty: 1, note: "A pair of gloves." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 2, note: "Two saddlebags." }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "canteen", qty: 3, note: "Three canteens or water skins." }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "marker", qty: "2d4", note: "2D4 markers and pens." }
  - { item_id: "winter-survival-kit", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1, note: "50 feet (15.2 m) of thin nylon cord, 600 lb./270 kg test strength." }
special_abilities:
  - name: "Custom War-Knight Power Armor"
    description: "Starts with a suit of full environmental light power armor with strength and speed augmentation but no flight. Typical M.D.C. by location: retractable Vibro-Blades (1-2) 80 each, forearm weapon 50, head/helmet 60-80, arms 80-120 each, legs 100-150 each, main body 2D6x10+110. The blades, forearm weapon, helmet and arms are small targets, hit only by an aimed shot at -3 to strike; destroying the main body destroys the armor and its augmentation. Only while the armor is worn: Robot P.S. 26-30; running speed is the wearer''s Spd x10 at 10% of the normal fatigue rate; leaps 10 feet high and 15 feet across, double with a running start; +1 attack per melee at levels 2, 6 and 12; +1 on initiative; +1 to strike and parry. Damage: restrained punch 1D4 M.D., punch 1D6 M.D., power punch 2D6 M.D. (counts as two attacks), kick 2D4 M.D., leap kick 2D6 M.D., body flip/throw or tackle 1D4 M.D. Most suits are provided by the Warlord; on the Black Market they run 1.6 to 2.5 million credits."
  - name: "Mega-Steed"
    description: "Starts with a mount, rolled on percentile: 01-15 a robot horse or other vehicle; 16-20 a partial bionic horse with M.D.C. barding; 21-45 a full bionic horse; 46-85 a Mega-Steed, a large and powerful mega-damage riding animal from another world; 86-95 a True Megahorse; 96-00 some other powerful alien or magical creature (Centaur, Pegasus, Kilin, Seeker, Eurotorpid, Tri-Wolf and the like)."
  - name: "Bearer of Magic Weapons"
    description: "Apart from the Warlord and his most trusted generals and advisors, the War-Knight is the only member of a War Camp permitted to wield magic weapons and enchanted items. They are given as rewards for distinguished service and heroism, and the Warlord lets a knight keep any won in combat or given by the people."
  - { choose: 1, from: ["Psionics (01-82): None", "Psionics (83-94): Minor", "Psionics (95-98): Major", "Psionics (99-00): Master"], note: "Roll percentile at creation: 12% Minor, 4% Major, 2% Master (Rifts World Book 17: Warlords of Russia p.92). The book prints the percentages, not the bands; the bands are their order." }
  - name: "Psionics (01-82): None"
    description: "No psychic powers. Psionic abilities are not a requirement for a War-Knight."
  - name: "Psionics (83-94): Minor"
    description: "A Minor psychic (12% of War-Knights): two powers, both from ONE of the Healing, Physical or Sensitive categories, with the standard Minor psychic''s I.S.P. The one-category rule is the player''s to honour."
    psionics:
      type: "minor"
      isp_base: "M.E. + 2d6, +1d6 per level"
      powers_starting: 2
      categories_allowed: ["Healing", "Physical", "Sensitive"]
  - name: "Psionics (95-98): Major"
    description: "A Major psychic (4% of War-Knights): six powers from any of the Healing, Physical and Sensitive categories (the standard Major psychic''s other shape is eight from one category), with the standard Major psychic''s I.S.P."
    psionics:
      type: "major"
      isp_base: "M.E. + 4d6, +1d6+1 per level"
      powers_starting: 6
      categories_allowed: ["Healing", "Physical", "Sensitive"]
  - name: "Psionics (99-00): Master"
    description: "A Master psychic (2% of War-Knights) with all the psionic abilities of the Mind Melter, minus 10% of the usual I.S.P. and half the super-psionic abilities. Automatically knows Alter Aura, Mind Block, See Aura and Sixth Sense, plus three powers each from Healing, Physical and Sensitive and one Super Psionic power (half the Mind Melter''s three, rounded down). The Mind Melter''s I.S.P. (3D6x10 plus M.E., +10 per level) is stored as 3D6x9 plus M.E., +9 per level: a tenth off the dice and the per-level gain, the M.E. term left whole. Keeps the War-Knight O.C.C. Skills and selects none of the O.C.C. Related Skills at level one; the book gives a Master none at all, so the two more the class offers at levels 3, 6, 9 and 12 are to be skipped by hand. The Mind Melter''s level 2 and later psionic selections, with their Super Psionic picks halved, are the player''s to take by hand."
    related_skills_count: 0
    psionics:
      type: "master"
      isp_base: "3d6x9 + M.E. attribute number, +9 I.S.P. for each additional level of experience"
      powers: ["Alter Aura", "Mind Block", "See Aura", "Sixth Sense"]
      powers_starting: 10
      categories_allowed: ["Healing", "Physical", "Sensitive", "Super"]
      powers_starting_groups:
        - { count: 3, categories: ["Healing"] }
        - { count: 3, categories: ["Physical"] }
        - { count: 3, categories: ["Sensitive"] }
        - { count: 1, categories: ["Super"] }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Scrupulous (25%), Unprincipled (20%) or Aberrant (17%)."
  - "Attribute requirements also call for a high sense of responsibility and dedication to serve and protect; a high M.A., M.E. and P.E. are helpful but not required."
  - "Psionics are not a requirement: 12% possess Minor psionics, 4% Major and 2% Master. A Master psionic War-Knight has all the psionic abilities of the Mind Melter, minus 10% of the usual I.S.P. and with half the super-psionic abilities, keeps the War-Knight O.C.C. Skills and gets none of the O.C.C. Related Skills. Rolled on the Psionics pick under special abilities, in place of the standard Random Psionics roll."
  - "Cybernetics: about 3% are full cyborgs, 6% partial cyborgs, 21% have one bionic limb with two weapon features plus 1D4 implants, and 20% have 1D4+2 implants and/or internal organs but no artificial limbs. More may be acquired over time, but most War-Knights try to avoid becoming even partial ''Borgs."
extraction_notes: "WB17 Warlords of Russia printed 91-94 (cache p092-p095, cache page = printed folio + 1), read off the text layer; printed 92 was also read off a render for the bonus lines and the Streetwise figure. The entry starts at the heading on cache p092 line 59; the stat block The War-Knight O.C.C. starts on cache p093 line 16; the Typical War-Knight Power Armor block runs from cache p094 line 100 to cache p095 line 20. || HEADING: War-Knight O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the War-Knight ladder on the Experience Tables, printed 6, read off a render and taken from the brief. || BONUSES: +1 roll and +2 save vs possession stored flat; +1 initiative at levels 1, 3, 5, 8, 11 and 14, +1 pull punch at 1, 3, 5, 7, 9 and 11, +1 disarm at 2, 4, 6, 10 and 14, +1 save vs Horror Factor at 1, 2, 4, 6, 8, 10, 12 and 14; the level-1 steps are in bonuses and the rest in at_level. || SKILLS: Streetwise prints (+6%), confirmed on the render, stored as 20+6. Speaks Russian at 98% is stored as Language: Russian base 98 with per_level 0, a flat printed percentage. Tracking is the catalog''s Tracking (people). W.P. Energy Heavy is read as W.P. Heavy M.D. Weapons; the other candidate is W.P. Heavy Military Weapons. Body Building is Body Building & Weight Lifting. Lore: One of choice is one pick across the Lore: rows of Technical and Cowboy, the Ectohunter''s shape (BOOK-INGEST-AUDIT.md F140, 2026-10-15; until then a list naming seventeen rows). Hand to Hand: Martial Arts (or Assassin if evil) prints no price, stored as assassin at cost 0 with the alignment condition. || RELATED: the Pilot line reads Any, except robots, ships and aircraft (+10% to all horsemanship/riding skills). The catalog files riding under its own Horsemanship category, so that category is granted at +10 and Pilot carries no bonus. Ships are Boat: Ships and Military: Warships & Patrol Boats; aircraft are Airplane, Helicopter, Jet Aircraft, Military: Combat Helicopter, Military: Jet Fighters and Wingrider Flying Wing; spacecraft are Space: Space Fighter, Space: Small Spacecraft and Space: Starship; robots are Robot Combat: Basic and Robot Combat Elite. NOT excepted, for a reviewer to decide: Robots & Power Armor and the model-specific Robot Combat Elite rows (the knight wears power armor and each row covers power armor as well as robots), Jet Packs, Air Assault Armor, Combat Pod, Space: Antigrav Suit, Space: Contragravity Pak and the submersible rows. Mechanical: None and Rogue: None are left out. Science Math only is the two Mathematics rows. || PSIONICS: printed 92 gives 12% Minor, 4% Major and 2% Master (Mind Melter abilities, 10% less I.S.P., half the super-psionics, the O.C.C. Skills kept and no O.C.C. Related Skills), read off a 200 dpi render. Stored as a banded pick group with psionics_allowed: false, the roane-piper shape (BOOK-INGEST-AUDIT F138, F140): 01-82 None, 83-94 Minor, 95-98 Major, 99-00 Master; the book prints no bands, so the bands are the percentages in the book''s order. Minor and Major carry the standard tiers'' I.S.P. and power counts (Major as six from the three categories). Master carries the production mind-melter block (the four automatic powers, three each from Healing, Physical and Sensitive) with one Super pick for the Mind Melter''s three, halved and rounded down, its I.S.P. stored as 3d6x9 plus M.E., +9 per level (a tenth off the dice and the gain; the M.E. term is not reduced), and related_skills_count: 0, the gifted-one-russian key for the same sentence. The related picks at levels 3, 6, 9 and 12 and the Mind Melter''s level 2 and later selections are stated in the option''s description, not enforced. || POWER ARMOR: Custom War-Knight Power Armor is the first line of Standard Equipment. It is a vehicle row now (war-knight-power-armor, Warlords of Russia p.93-94) and still has no gear pointer row, so it is NOT in equipment_starting; its M.D.C. by Location, augmentation, bonuses, damage and cost are in a special_abilities entry and GM Notes. Its own bonuses (+1 attack at levels 2, 6 and 12, +1 initiative, +1 strike and parry) apply only when worn and are not in bonuses. Main body prints 2D6xlO +110 in the text layer, read as 2D6x10+110. || MOUNT: the percentile Mega-Steed table is a special_abilities entry and GM Notes; the steeds are described elsewhere in the book and are not rows here. || MONEY: 1D4x1000 credits stored (the text layer prints !D4xlOOO); the 2000 credit monthly salary (double for officers above lieutenant, triple for Field Marshalls) is in GM Notes. || EQUIPMENT readings: large Vibro-Sword or Axe is a choice of the generic vibro-sword and vibro-axe rows; silver survival knife is knife-silver-plated; three canteens or water skins is three canteens; notepad is note-pad; markers and pens are the marker row; 50 feet of thin nylon cord is lightweight-cord (a 50 foot bundle); two saddlebags is qty 2 of a row described as paired bags, which may double it; cape or cloak is cape-or-cloak-long and pair of gloves is gloves, granted under BOOK-INGEST-AUDIT.md F140 on 2026-10-20. || EQUIPMENT not stored as rows: the power armor; an energy rifle or heavy M.D. weapon of choice; one other weapon of choice; casual clothing; belt and scabbard and other belts; a handful of personal items; the steed."
---

## Lore

War-Knights are the Warlords'' knights of the realm: the most honored
fighters in a War Camp and the nearest thing Russia has to a chivalric
order. Most serve as officers and elite troops, leading anything from a
strike team to a whole division, and more than half of all Field Marshalls
come from their ranks. The rest ride in all-knight cavalry companies, lead
mixed elite units, or travel the land alone or in small groups as the
Warlord''s representatives.

On the road a War-Knight is lawman, judge, tax collector and protector at
once, and the people turn to one with little hesitation. Some are savage or
outright evil, but most answer that trust by living up to it, and are
gracious and patient with ordinary Russians.

They look the part. The typical knight wears ornate, old-fashioned plate
that is in fact a suit of light power armor with hidden blades and a
forearm gun, carries a Vibro-Sword or a magic weapon at the belt, and rides
a bionic horse or one of the huge alien mounts called Mega-Steeds.

## GM Notes

Power armor. Every War-Knight starts with a custom suit of light,
full-environmental power armor (no flight). It is not on the equipment list;
it is listed among the vehicles. Typical figures: retractable Vibro-Blades
(1-2) 80 M.D.C. each, forearm weapon 50, head/helmet 60-80, arms 80-120
each, legs 100-150 each, main body 2D6x10+110. Everything but the legs and
main body needs an aimed shot at -3 to hit. Worn, it gives Robot P.S.
26-30, running speed of Spd x10 at one tenth the fatigue, 10 foot high and
15 foot long leaps (double with a run), +1 attack per melee at levels 2, 6
and 12, +1 initiative and +1 to strike and parry. Punch 1D6 M.D.
(restrained 1D4, power punch 2D6 for two attacks), kick 2D4, leap kick 2D6,
body flip or tackle 1D4. Black Market price 1.6 to 2.5 million credits.
None of the armor''s bonuses are in the class''s own numbers.

Mount, roll percentile: 01-15 robot horse or other vehicle; 16-20 partial
bionic horse with M.D.C. barding; 21-45 full bionic horse; 46-85 a
Mega-Steed (alien mega-damage riding animal); 86-95 a True Megahorse; 96-00
another powerful alien or magical creature such as a Centaur, Pegasus,
Kilin, Seeker, Eurotorpid or Tri-Wolf.

Starting kit beyond what the sheet lists: an energy rifle or heavy M.D.
weapon of choice, one other weapon of choice, casual clothing, belt and
scabbard, other belts and a handful of personal items. The Vibro-Sword or
Axe does 3D6 M.D.

Money is 1D4x1000 credits. Salary is 2000 credits a month, double for
officers above lieutenant and triple for Field Marshalls, with all needs,
military equipment and steeds provided. Magic weapons and special items
come as rewards, and gifts from grateful villagers may be kept. Knights
under 4th level, and those known for cruelty, get a cooler welcome.

On assignment the Warlord may furnish almost anything, magic items
included. No secret resources as such.

Psionics: 12% Minor, 4% Major, 2% Master. A Master psionic War-Knight has
the Mind Melter''s psionic abilities with 10% less I.S.P. and half the
super-psionics, keeps the War-Knight O.C.C. Skills and gets no O.C.C.
Related Skills. The wizard rolls this on the Psionics pick instead of the
standard Random Psionics roll; a Master still skips the related picks at
levels 3, 6, 9 and 12 and takes the Mind Melter''s later psionic picks by
hand.
',
       updated_at = datetime('now')
 WHERE class_id = 'war-knight'
   AND instr(markdown, 'The class file grants no psionics; build this by hand.') > 0
   AND length(markdown) = 18031;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'war-knight' AND instr(markdown, 'Psionics (99-00): Master') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'war-knight' AND instr(markdown, 'The class file grants no psionics; build this by hand.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('war-knight') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~270-book-ingest-audit-f140-war-knight-psi.sql');
