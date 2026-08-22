-- The Soldier O.C.C., Palladium Fantasy main book, printed p83.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-soldier-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-soldier-class.sql
--
-- Read with scripts/read-columns.py, the same geometric reader the Knight
-- needed. Apply fix-pf-armor-and-cross-system-gear.sql first or alongside: it
-- prices studded leather against the printed table and makes the uniform,
-- clothing, gloves and rations rows visible to a Palladium campaign.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- TWO THINGS THE PAGE SAYS THAT THE SHAPE DOES NOT.
--
-- 1. "Select two additional skills from the category of Military or Espionage,
--    and seven other skills of choice" is nine related skills with a
--    constraint spanning two categories. `occ_related_skills` has one count and
--    per-category limits, and no way to say "two of the nine from this pair",
--    so the count is 9 and the constraint is stated in the note on both
--    categories - the same place the Knight puts its Communications pair.
--
-- 2. The armour choice is chain mail or studded leather. Studded leather had no
--    catalog row at all; the companion script adds it at the printed 200 gold,
--    A.R. 13, 38 S.D.C. rather than letting class-check stub it.
--
-- The two weapons of choice enumerate the whole Palladium Fantasy weapon
-- catalog minus the lance. Equipment choices take item slugs and there is
-- deliberately no `categories` flavour, so a free pick has to be spelled out;
-- the lance comes off because the book restricts it to the Knight and Palladin.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'soldier', 'Soldier', 'palladium-fantasy', '---
id: soldier
name: Soldier
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { PS: 10, PE: 8 }
starting_money: "180"
bonuses:
  combat: { pull_punch: 1 }
  saves: { horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 45, per_level: 5, note: "Climb/Scale Walls (+5%); rappelling is a second percentile, 35% +5%." }
    - { name: "Forced March", base: 0, per_level: 0 }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "One language of choice (+10%)" }
    - { name: "Military Etiquette", base: 55, per_level: 5, note: "+20%" }
    - { name: "W.P. Shield", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 9
    categories:
      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
      - "Domestic"
      - { name: "Espionage", note: "+5%; two of the nine must come from Military or Espionage" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
      - { name: "Medical", only: ["First Aid"], note: "+5%" }
      - { name: "Military", note: "+10%; two of the nine must come from Military or Espionage" }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", note: "+5%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Carpentry", "Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "uniform", qty: 1 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: 2 }
  - { item_id: "tinder-box", qty: 1 }
  - { choose: 1, label: "armour", qty: 1, from: ["chain-mail", "studded-leather"] }
  - { item_id: "small-shield", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.) or studded leather (A.R. 13, 38 S.D.C.), player choice."
  - "Every starting weapon is a basic S.D.C. weapon of good quality. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "Officers additionally carry one superior weapon (+2 to parry and +4 to damage, or a minor holy weapon), one more weapon of choice, splint or plate armour, and a horse with barding."
  - "Soldiers lean toward heavy armour: -15% to prowl and -20% to climb or scale walls in full splint or plate, -10% to prowl or climb in chain or scale mail, -5% in studded leather."
  - "Enlistment is two years minimum, often four to six. Pay is 100-150 gold a month for a typical soldier, 160-200 on the border, 300-600 extra per special assignment, and 100-300 a month more for a low-ranking officer."
  - "Military issue may be traded back to the supply officer for privately bought arms with permission. Subcontracted smiths and armourers sell to soldiers at a 25% discount; mercenaries usually do not get it."
extraction_notes: "The two weapons of choice are enumerated as the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category. Hand to Hand upgrades are priced in other skills, which the model has no way to charge, so they are stated in the note."
---

# Soldier

## Lore

Soldiers are professional fighters, part of a large military force and trained
as its instrument. Most of their skills go to weapon proficiencies, hand to hand
combat, scaling walls, laying siege to fortified strongholds, military procedure
and operating as part of a combat group. Hand to hand training is for inflicting
lethal damage as quickly and accurately as possible: attacks are aimed where
they do the most harm, because one does not have to kill every opponent to win a
battle. Soldiers are taught to fight toward an objective, usually a position of
strategic importance or the chance to eliminate an enemy commander. Capturing or
killing an enemy leader will usually confuse the troops, break ranks, and drain
their will to fight.

Military life is restrictive, repetitive and petty. The soldier accounts for his
actions, obeys orders, and shows respect to his superiors. He rarely picks or
declines an assignment, his posting, his commanding officer or his teammates. He
is told what to do, how to do it, and where to go, and disobedience is punished
by reduction in rank, the worst and most dangerous posts, imprisonment,
execution or dishonourable discharge.

The soldier serves a particular king, kingdom, country or organisation to which
he has sworn loyalty. Most are patriots who gladly defend their homeland. Under
the best circumstances the master is just and noble and cares about his troops.
Too often the soldier is a pawn, and the ruler who commissioned the army decides
what it is for: defence of borders, people and holdings, or a campaign of
conquest and expansion.

The assignments that afford the most freedom are reconnaissance patrols,
espionage, law enforcement, and duty at border towns in the wilderness. Remote
outposts can be weeks or months of travel from high command, so communication is
minimal and troops are expected to be self-sufficient. That distance cuts both
ways: a strong commander produces a disciplined garrison with extra personal
freedoms, while weak or corrupt leadership produces petty tyrants who exploit
the people they were sent to protect, sometimes for years before anyone notices.

## GM Notes

Non-military player characters can join a military campaign as freelance
scouts, mercenaries, advisors, assistants and labourers, including cooks, repair
men, healers and translators. They get small but reasonable pay, food, water and
a place to sleep.

Mercenary fighters bolster a garrison under the same rules, laws and authority
as enlisted troops, with room and board provided, 150-200 gold a month, bonuses
for special assignments, and often 10% to 20% of the booty. Mercenary
enlistment runs job to job or three to six months, and mercs supply their own
equipment.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'soldier');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'soldier';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('studded-leather', 'uniform', 'clothing', 'food-rations', 'gloves');
-- ... and none of them may be a stub.
SELECT count(*) AS stub_gear FROM gear
 WHERE slug IN ('studded-leather', 'uniform', 'clothing', 'food-rations', 'gloves')
   AND description LIKE 'STUB%';

INSERT INTO data_script_runs (filename) VALUES ('add-soldier-class.sql');
