-- Store New West Bounty Hunter's printed O.C.C. bonuses and attribute requirements
-- 1 class, each replaced whole: bounty-hunter.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~217-new-west-bounty-hunter-bonuses.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- New West printed 89 (PDF page 90) prints the Bounty Hunter's O.C.C. bonuses and
-- attribute requirements, and production stored none of them (found by row 37d4's
-- stopped run, 2026-10-16). This stores every one an existing key carries:
-- attribute_requirements I.Q. 7, P.S. 12, P.E. 12; +1D4 to P.E.; +2D6+12 S.D.C.;
-- +2 on initiative; +3 to pull punch; +1 to roll with punch, fall or impact; and
-- +1 to save vs horror factor at levels 2, 4, 6, 10 and 14 (five at_level rows).
-- The rest of the markdown is production's copy, unchanged.

-- == bounty-hunter ==
UPDATE imported_classes
   SET markdown = '---
id: bounty-hunter
men_of_arms: true
name: Bounty Hunter
system: rifts
source_book: Rifts World Book 14: New West p.87-90
category: occ
tags: [combat, wilderness, hunter]
xp_table: [0, 2111, 4221, 8441, 16881, 24881, 34881, 49881, 69881, 94881, 129881, 179881, 229881, 279881, 329881]
occ_group: men-of-arms
attribute_requirements: { IQ: 7, PS: 12, PE: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "5d6x100 credits worth of tradeable items, 3d4x100 in gold or silver, and 3d4x100 in universal credits"
bonuses:
  attributes: { PE: "1d4" }
  combat: { initiative: 2, pull_punch: 3, roll: 1 }
  pools: { sdc: "2d6+12" }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Speak one other language of choice (+20%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Surveillance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "+15%" }
    - { name: "Find Contraband", base: 36, per_level: 4, note: "+10%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Intelligence", base: 47, per_level: 4, note: "+15%" }
    - { choose: 1, from: ["Interrogation", "Seduction"], bonus: 10, note: "Interrogation (+10%) or Seduction (+10%)." }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Climbing", base: 40, per_level: 5 }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be traded up to Martial Arts for one other skill, or to Assassin if of an evil alignment." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    minimums:
      - { count: 2, category: "Pilot" }
      - { count: 2, categories: ["Espionage", "Military"] }
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["Paramedic"] }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", note: "Any Rogue skill may be taken; the bonus is on the next line." }
      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a bonus, at +8%." }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Chemistry"], bonus: 10 }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["tinted-goggles", "sunglasses"] }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "tracer-bug", qty: "1d4+1" }
  - { item_id: "pocket-scrambler", qty: 1 }
  - { item_id: "handcuffs-2-mdc", qty: 2 }
  - { item_id: "cord", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "sack", qty: "1d4" }
  - { choose: 1, label: "Vibro-Blade, Neuro-Mace or Electro-Stunner", qty: 1, from: ["vibro-knife", "vibro-saber", "vibro-sword", "neural-mace", "electro-stunner"] }
  - { choose: 1, label: "conventional six-shooter", qty: 1, from: ["1863-remington-45-revolver", "model-1860-colt-44-revolver", "1873-colt-38-40-revolver", "1878-colt-45-caliber-revolver", "1899-smith-wesson-38-revolver"] }
  - { item_id: "silver-bullet-medium-large-caliber", qty: "1d49+95" }
  - { item_id: "hand-grenade", qty: "1d6" }
  - { item_id: "passive-nightvision", qty: 1 }
  - { choose: 1, label: "vehicle", qty: 1, from: ["hovercycle", "road-boss-motorcycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle", "riding-horse"] }
  - { choose: 1, label: "special equipment, package 4: robot horse", qty: 1, from: ["rh-1001a-appaloosa-light-robot-horse", "rh-1002b-mustang-medium-robot-horse", "rh-1003c-arabian-robot-horse", "rh-1004d-war-horse-heavy-robot-horse"] }
restrictions:
  - "Cowboy and Electrical skills are closed to this class."
  - "May start with up to 1D4 cybernetic implants of the player''s choice."
side_effects: "The trade is looked down on by knights, lawmen and law-abiding citizens, and even bandits regard bounty hunters as vermin, because they are loyal to nothing but the fee. A player character with a code of honour will still be met with disdain, fear and suspicion."
extraction_notes: "TWO NOTES ON WHAT IS STORED. (1) Special Equipment - printed 89-90 offers a choice of one of four packages: excellent armour plus a jet pack and 2D6x1000 credits; a suit of light or medium power armour with the Pilot Robots and Power Armor skill granted automatically; Techno-Wizard or magic armour plus a magic weapon, or a bio-wizard parasite with 1D4 microbes and a minor magic weapon; or a souped-up vehicle with double M.D.C., two M.D. weapons, radar and long-range radio, or a robot horse. The fourth package''s robot horse is stored, by Nate''s ruling of 2026-10-16, as a choice of the four RH-1001A to RH-1004D robot horse rows. The souped-up vehicle is not stored (no row carries its doubled M.D.C., weapons, radar and radio), the second package grants a skill, which equipment_starting cannot do, and the first three packages are recorded here only: a character who takes one of them sets the robot horse aside by hand. (2) The related-skill line reads ''select two piloting skills and five other skills'' - stored as count 7 with a floor of 2 Pilot, which is what it means. Standard Equipment grants every printed item a Rifts catalog row holds (BOOK-INGEST-AUDIT.md F140, 2026-10-16): the conventional six-shooter is a choice of New West''s five conventional revolvers (printed 211-212), its 96-144 silver bullets are the medium to large caliber row, rolled as 1d49+95, and the infrared distancing binoculars replace the plain binoculars granted before. Not granted, each having no Rifts row or being an open choice: personalised M.D.C. body armour of any kind, a spare suit of light M.D. armour, an NG-S2 Basic Survival Pack, 2D4 sets of handcuffs or manacles of 80 S.D.C. (those rows are Palladium Fantasy, Heroes Unlimited and Nightbane), an energy handgun and rifle of choice, three more weapons of choice, a passive telescopic nightsight scope for the rifle (the one passive nightvision row granted stands for the goggles; the scope rows are telescopic, infrared or thermo-imager), and a land rover (left out of the vehicle choice)."
---

# Bounty Hunter

**Alignments.** Any, but they tend to anarchist and evil. Those alignments will
not trouble themselves over bystanders too slow or stupid to get out of the
way, and some bounty hunters are as evil as the villains they hunt. Good
characters are far more discriminating about who they hunt, whether their prey
will get a fair trial, and who else is standing nearby.

The Bounty Hunter is part city rat, part spy and part wilderness scout,
specialising in running down wanted criminals and fugitives - dead or alive.
They are often cold, unmerciful people with military or combat experience
behind them. Most work alone or in pairs, on the reasonable grounds that a
reward split eight ways is not much of a reward, though even the lone wolves
ride with other adventurers from time to time and keep half a dozen favourite
watering holes where they feel safe.

The next most common arrangement is a small team of four to eight, of whom two
to four are professionals and the rest are whatever the work attracts -
psychics, practitioners of magic, ''Borgs, Juicers, Dog Boys, dragons, demons,
anyone who enjoys hunting intelligent prey.

## The work

The New West holds some of the toughest criminals in the Americas, and most
western towns are not equipped to hunt them. For the right price these men and
women will track down, capture or kill dangerous outlaws and monsters, using
disguises and pretending to be sheriffs, gunslingers, bandits, preachers or
mercenaries - whatever the job takes.

Some think of themselves as lawmen and work within the law. Most see themselves
as bending it, and some as being above it. That last position is easiest to
occupy where the law wants an outlaw brought in for trial and the hunter only
wants the head, because the head is what the bounty pays for.

## Bounties

A bounty is usually posted by a wealthy businessman, rancher, politician or an
aggrieved family - which means it is often about revenge rather than justice,
and that a price on a head is not proof of guilt. Most bounty hunters of
selfish or evil alignment do not care either way.

Animals and small predators fetch fifty to two hundred credits a head. Xiticix,
mutant animals, vampires, Brodkil and similar medium threats run three hundred
to fifteen hundred. Petty crooks rarely have a price at all, and when they do
it is two hundred to a thousand. The flamboyant and genuinely dangerous
attract ten to fifty thousand, and gang leaders and powerful beings twenty to
fifty thousand; a bounty seldom exceeds a hundred thousand credits.

**Collecting is a problem about a third of the time.** The two usual reasons
are identification and money. No positive identification means no payment, and
video can be faked, so a manhunter who is careless may risk his life for
nothing - and some clients use the doubt as an excuse to pay half. The other
reason is that the town or person who posted the bounty may simply not have it,
and pays what it can in instalments or in goods.

## Lore

Bounty hunters make excellent non-player characters and villains, and the book
says so directly.
',
       updated_at = datetime('now')
 WHERE class_id = 'bounty-hunter'
   AND instr(markdown, 'attribute_requirements:') = 0
   AND length(markdown) = 10497;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'bounty-hunter' AND instr(markdown, 'combat: { initiative: 2, pull_punch: 3, roll: 1 }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('bounty-hunter') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~217-new-west-bounty-hunter-bonuses.sql');
