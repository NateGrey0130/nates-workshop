-- The Noble O.C.C., Palladium Fantasy main book, printed pp.96-97.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-noble-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-noble-class.sql
--
-- Read with scripts/read-columns.py. Needs no new catalog rows.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE ONLY CLASS IN THE BOOK WITH NOTHING IN THE GATE. "Attribute Minimum
-- Requirements: None. O.C.C. Bonuses: None." Both are printed, both say none,
-- so the frontmatter carries neither key rather than an empty one. What a noble
-- brings is money, literacy, standing and a horse - 300 gold, the most of any
-- class in the chapter, and a mount worth 1D6x1000.
--
-- ONE SKILL IS GRANTED AT THE BOOK'S NUMBER, NOT THE CATALOG'S, and this is
-- the interesting call in the file.
--
--   Horsemanship: General  Palladium Fantasy prints 35%/20% +5% (p52)
--                          the catalog row carries 40% +4%, the Rifts numbers
--
-- Skills are deliberately cross-system - see untag-cross-system.sql - so one
-- row serves both games, and where the two books disagree the row can only hold
-- one set. The class entry carries its own base and per_level and is what the
-- character actually reads, so the printed Palladium value goes there and the
-- discrepancy is recorded in the skill note. Writing 40 would have quietly
-- handed every Palladium noble five points the page does not give them.
--
-- This is the first class in the batch to hit that, and it will not be the
-- last: Horsemanship: General is granted or offered by six classes already.
--
-- A COMB IS DROPPED. The starting equipment lists one and the catalog has no
-- row for it, nor does the equipment chapter price one. Rather than stub a row
-- for a comb, it is left out and said so in extraction_notes. The bare "hat"
-- resolves to the plainest of the catalog's three, same as the Merchant.
--
-- The three family skills the book adds on top of the five related skills are
-- not modelled, for the same reason as the Squire: the tables live on the
-- Knight page and nothing in the schema holds a table roll. Count stays 5.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'noble', 'Noble', 'palladium-fantasy', '---
id: noble
name: Noble
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
starting_money: "300"
skills:
  occ_skills:
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Heraldry", base: 40, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 35, per_level: 5, note: "35%/20% riding/combat riding, the Palladium Fantasy numbers. The shared catalog row carries the Rifts ones (40%, +4)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "One language of choice (+20%)" }
    - { name: "Literacy", base: 45, per_level: 5, note: "One language of choice, usually native or elf (+15%)" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 50, per_level: 5, note: "+15%; pick one instrument" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", note: "+5%" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - "Science"
      - { name: "Technical", note: "+5%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Wilderness Survival", "Land Navigation"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { choose: 1, label: "cape or cloak", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "tent-one-man", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 3 }
  - { item_id: "water-skin", qty: 1 }
  - { choose: 1, label: "fine wine or brandy", qty: 1, from: ["wine-good", "brandy"] }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "snuff-box", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
  - { item_id: "chain-mail", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.). A noble can use every type, some preferring ornamented scale or plate and others less conspicuous leather or plate and chain, with the usual penalties."
  - "Every starting weapon is a basic S.D.C. weapon of good quality. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The riding horse is of good quality, with 30+2D6 S.D.C., 6D6 hit points, running speed 33, and a value of 1D6x1000 gold."
  - "Family background and the three family skills are rolled on the Knight tables, and those three skills are in addition to the five related skills above."
  - "1-60% chance of family and holdings in the homeland: 1D4 relatives who will house and feed the character indefinitely, and may provide a new set of clothing, studded leather armour, a sword and 2D6x10 gold."
  - "The two sets of clothing are one travelling and one fine; the catalog has a single generic clothing row."
extraction_notes: "Horsemanship: General is granted at the Palladium Fantasy printed base of 35%/20% +5% rather than the shared catalog row''s 40% +4%, which carries the Rifts numbers. The class entry is what the character reads, so the printed value wins. The book gives a bare hat where the catalog prices three, so the plainest is granted; a comb is listed and has no catalog row at all, so it is dropped rather than stubbed. The three family skills the book adds on top of the related skills are not modelled: the tables live on the Knight page and nothing in the schema holds a table roll. Two weapons of choice enumerate the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category."
---

# Noble

## Lore

The noble is a lord or lady of noble birth, which usually means being born into
a family somewhere between relatively and incredibly wealthy. The character is
taught the rudiments of combat, weapons and horsemanship, and educated in
courtly matters and etiquette. Most nobles end up in politics, business
administration and similar occupations, but some are struck by wanderlust or a
desire for adventure, and others take to the road to make a name for themselves
or to shore up a sagging family fortune.

Some are foppish, pampered, selfish, arrogant snobs. Others are dignified,
proper and honourable, some are friendly and compassionate, and some are as
heroic and generous as the best knights in the land.

## Alignment

Any. Noble birth and education are not indicative of inner spirit, integrity or
compassion.

## GM Notes

One of the book''s Optional O.C.C.s, and the only class in the chapter with no
attribute minimums and no O.C.C. bonuses at all: what a noble brings to a party
is money, literacy, standing and a horse, not a trained edge in a fight.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'noble');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'noble';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 6 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('chain-mail', 'riding-horse', 'tent-one-man', 'purse-satchel',
                'snuff-box', 'hat-short-brim');
-- The horsemanship row the class overrides had better still be there.
SELECT name, base, per_level FROM skills WHERE name = 'Horsemanship: General';

INSERT INTO data_script_runs (filename) VALUES ('add-noble-class.sql');
