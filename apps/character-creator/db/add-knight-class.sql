-- The Knight O.C.C., Palladium Fantasy main book, printed pp.84-86.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-knight-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-knight-class.sql
--
-- The first class from the Palladium Fantasy main book, and the first read with
-- scripts/read-columns.py rather than transcribed by eye. That matters here:
-- the page is two-column, and read in the order the PDF stores it the Knight's
-- O.C.C. Skills list is TWO entries long - Dance and Heraldry - because the
-- third line of the column is the page number and the fourth is the running
-- header. Read geometrically it is twelve entries.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE CATALOG ROWS BELOW ARE NOT STUBS. class-check offered the usual
-- "STUB - created by class import, needs stats" placeholders for all five, and
-- the book prints real numbers for every one of them, so they are filled:
--
--   Horsemanship: Knight   "Base Skill: 40%/30% +5% per level"  (printed p57)
--   W.P. Lance             a weapon proficiency, non-percentile
--   Chain Mail             A.R. 14, 44 S.D.C.   stated in the Knight's own entry
--   Scale Mail             A.R. 15, 75 S.D.C.   stated in the Knight's own entry
--   Small Shield           30 S.D.C., 35 gold   "The average small wood &
--                                                leather shield" (printed p48)
--
-- 79 gear rows in this catalog are already class-import stubs that no book
-- prices. Adding three more when the numbers are on the page would have been a
-- choice to create that problem again.

-- ---- catalog rows this class needs ----------------------------------------
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Horsemanship: Knight', 'Horsemanship', 40, 5, '["palladium-fantasy"]', 'import',
        'palladium-fantasy-core', '40%/30% - riding/combat riding');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book)
VALUES ('W.P. Lance', 'Weapon Proficiencies', 0, 0, '["palladium-fantasy"]', 'import',
        'palladium-fantasy-core');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, ar, description, source_book)
VALUES ('chain-mail', 'Chain Mail', 'palladium-fantasy', 'Armor', 400, 14,
        'Full suit of chain mail. A.R. 14, 44 S.D.C. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.',
        'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, ar, description, source_book)
VALUES ('scale-mail', 'Scale Mail', 'palladium-fantasy', 'Armor', 500, 15,
        'Full suit of scale mail. A.R. 15, 75 S.D.C. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.',
        'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, description, source_book)
VALUES ('small-shield', 'Small Shield', 'palladium-fantasy', 'Armor', 35,
        'The average small wood and leather shield: 30 S.D.C. A wood and metal plated version has 50 S.D.C. and costs 65 gold. Can be thrown about 15 feet (4.6 m).',
        'palladium-fantasy-core');

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'knight', 'Knight', 'palladium-fantasy', '---
id: knight
name: Knight
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 7, PS: 10, PE: 10, PP: 12 }
starting_money: "110"
skills:
  occ_skills:
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Heraldry", base: 45, per_level: 5, note: "+20%" }
    - { name: "Horsemanship: Knight", base: 40, per_level: 5, note: "40%/30% - riding/combat riding" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, categories: ["Technical"], bonus: 15, note: "Two languages of choice (+15% each). The catalog has no individual language rows." }
    - { name: "Literacy", base: 50, per_level: 5, note: "One language of choice, usually native or elf (+20%)" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "W.P. Lance", base: 0, per_level: 0 }
    - { name: "W.P. Shield", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts, or Assassin if evil, for the cost of one other skill." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", note: "+10%; two of the eight must come from here" }
      - { name: "Espionage", note: "+10%" }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - { name: "Science", note: "+5%" }
      - { name: "Technical", note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Wilderness Survival", "Track & Trap Animals"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 5, count: 1 }, { level: 10, count: 1 }, { level: 15, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { choose: 1, label: "armour", qty: 1, from: ["chain-mail", "scale-mail"] }
  - { item_id: "small-shield", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { item_id: "lance", qty: 1 }
  - { choose: 1, label: "sword of choice", qty: 1, from: ["long-sword", "short-sword", "broadsword"] }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Any one starting weapon may be of exceptional quality (kobold or dwarven): +1 to strike and parry, or +2 to damage."
  - "Armour is chain mail (A.R. 14, 44 S.D.C.) or scale mail (A.R. 15, 75 S.D.C.), player''s choice."
  - "The riding horse has 30+2D6 S.D.C., 6D6 hit points, running speed 33, and is worth 1D4x1000 gold."
---

# Knight

## Lore

Knights are given military discipline and trained in hand to hand combat and
swordsmanship. Unlike the average soldier they are usually of royal or noble
birth and begin their lessons in combat in early childhood, adding horsemanship,
military strategy and a variety of weapons to scholastic or noble pursuits such
as dancing, singing, mathematics, lore and science. About 60% are literate in at
least one language and speak at least three.

In many kingdoms these educated and highly trained soldiers are automatically
considered officers, no lower in rank than lieutenant, and given a squad or
platoon to lead. Those who prove themselves in battle may be given a company, a
battalion, or even a brigade. Many are patriots and defenders of the land,
landholders or politicians with their own holdings at stake; historically most
were landowners or governors, responsible for defending the land they held,
keeping order, and administering justice.

In the Palladium World many knights are free agents, wandering the kingdom
enforcing laws, righting wrongs and protecting those under their charge. Raised
with a strong sense of duty and political protocol, these lone wolves can
operate as independent lords without offending other knights or the royal
family. Those who are too outspoken, or who defy convention, may be branded a
"rogue" or "black knight"  -  blacklisted from noble society, or in the extreme,
stripped of their lands and declared an outlaw.

## Alignment

Any. Knighthood and noble birth say nothing about a character''s inner spirit.
Knights of principled, scrupulous and aberrant alignment are men of honour who
live by the letter of the Code of Chivalry. Unprincipled and anarchist knights
follow it most of the time but bend the rules when it suits them. Diabolic and
miscreant knights ignore it entirely and are considered men of no honour.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'knight');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'knight';
SELECT name, base, per_level FROM skills
 WHERE name IN ('Horsemanship: Knight', 'W.P. Lance') ORDER BY name;
SELECT slug, cost, ar FROM gear
 WHERE slug IN ('chain-mail', 'scale-mail', 'small-shield') ORDER BY slug;
-- None of the three new gear rows should be a stub.
SELECT count(*) AS new_gear_stubs FROM gear
 WHERE slug IN ('chain-mail', 'scale-mail', 'small-shield') AND description LIKE 'STUB%';

INSERT INTO data_script_runs (filename) VALUES ('add-knight-class.sql');
