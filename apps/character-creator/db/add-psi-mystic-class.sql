-- The Psi-Mystic P.C.C., Palladium Fantasy main book, printed pp.159-160.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-psi-mystic-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-psi-mystic-class.sql
--
-- Read with scripts/read-columns.py. One of the book's four psychic classes,
-- alongside add-psychic-sensitive-class.sql, add-psi-healer-class.sql,
-- add-psi-mystic-class.sql and add-mind-mage-class.sql.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- A P.C.C., NOT AN O.C.C. The schema's `category` takes only rcc and occ, and
-- the Rifts P.C.C.s already in the catalog - Mind Melter, Burster, Psi-Stalker
-- - are all stored as occ. This follows, and the distinction is recorded in
-- restrictions where a reader sees it, along with the book's "Multiple O.C.C.s
-- are not possible".
--
-- THE MASTER PSIONIC SAVE TARGET IS WRONG IN THE APP, and it is not this
-- batch's to fix. This class is a master psionic, and the Palladium Fantasy
-- main book (printed p48) says a master psionic saves against psionic attack on
-- a 10 or higher. Rifts Ultimate Edition agrees, printed p142. js/derive.js has
-- PSIONIC_SAVE_BASE 15 and PSIONIC_SAVE_STRONG 12, and psionicSaveTarget()
-- returns STRONG for anything major or better - so major and master collapse to
-- 12 and no character has ever been given the master's 10. Correcting it
-- touches every existing master psionic in Rifts too and changes a number on
-- sheets that already exist, so it is recorded in restrictions on all four of
-- these classes rather than changed inside a class import.
--
-- THE ONLY PSYCHIC CLASS HERE WITH REAL MAGIC, and it is a genuine selection,
-- so it gets a `magic` block: six spells from levels 1-2 at first level, then
-- two per level from any level up to the character's own.
--
-- What makes it unusual will not fit in that block. A Psi-Mystic cannot be
-- taught a spell, cannot buy one, and cannot read one off a scroll. The six
-- arrive after a six-day meditative trance and are permanent; every pair after
-- that arrives the same way, at what the book calls a new metaphysical plateau.
-- That rule lives in natural_abilities beside the block.
--
-- "THREE SENSITIVE PLUS TWO PHYSICAL-OR-HEALING" is one count against one
-- category list, which the psionics block cannot split - so powers_starting is
-- 5 and categories_allowed names all three categories.
--
-- CANNOT WEAR FULL PLATE, and the reason is psychological rather than
-- encumbrance: too confining, and too reliant on technology. Recorded in
-- restrictions, since nothing in the model gates armour by class.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'psi-mystic', 'Psi-Mystic', 'palladium-fantasy', '---
id: psi-mystic
name: Psi-Mystic
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "1d6x10 plus the P.E. attribute number, +2d6 per level of experience"
starting_money: "120"
bonuses:
  saves: { mind_control: 2, possession: 4, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"
  powers: ["Exorcism", "Sense Evil", "Sixth Sense", "Meditation", "Mind Block"]
  powers_starting: 5
  categories_allowed: ["Sensitive", "Physical", "Healing"]
magic:
  type: "intuitive"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
skills:
  occ_skills:
    - { name: "Dowsing", base: 25, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic (+20%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be improved to Expert for the cost of two other skills, or Martial Arts or Assassin (if evil) for three." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - { name: "Science", note: "+5%" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
natural_abilities:
  - name: "Intuitive Magic"
    description: "The Psi-Mystic does not study magic and cannot be taught it. Before setting out to explore the world the character enters a meditative trance lasting six days and comes out of it intuitively knowing six spells, whose nature typically reflects his alignment and view of life. They are permanent and cannot be changed. At each new level of experience - a new metaphysical plateau, which the character simply senses - he finds time to meditate and comes away with two more spells from any level up to his own. A Psi-Mystic can never learn a spell any other way."
  - name: "Additional Psionic Abilities"
    description: "One further power from the Sensitive or Physical categories at levels 3, 5, 7, 9, 11, 13 and 15."
  - name: "Drawing on Ambient P.P.E."
    description: "Like a wizard, the Psi-Mystic can draw on the ambient P.P.E. of ley lines and on blood sacrifices."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cloak or cape", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements, though a high I.Q. and M.A. of 10 or higher are strongly suggested."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Most prefer light or magic armour and CANNOT wear a full suit of plate - too psychologically confining and too reliant on technology."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus. The app currently derives 12 for every major-or-better psychic; see extraction_notes."
  - "Most Psi-Mystics disregard formal education, believing that too much of it walls off the natural psychic emanations. They avoid cities, gizmos and accumulating possessions, other than things that uplift the spirit - art, musical instruments, books."
  - "The starting dagger is silver-coated; the catalog has no silver Palladium weapon, so the ordinary Daggers and Knives row stands in. A hair comb is in the kit and has no catalog row."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: the book says 10 or higher and derive.js returns 12 for anything major or better - an app-level gap affecting every existing master psionic in Rifts too, not something this import changes. The five automatic powers resolve exactly; powers_starting is 5 for the three Sensitive plus two Physical-or-Healing the book grants at first level, and categories_allowed lists all three because the block cannot say three from one and two from the other two. The intuitive magic IS a real selection and gets a magic block - six spells from levels 1-2 at first level, two per level thereafter from any level up to the character''s own - with the meditation flavour and the never-learns-any-other-way rule in a natural ability beside it."
---

# Psi-Mystic

## Lore

The Psi-Mystic senses things on a psychic, magic and metaphysical level, and
has learned to trust the feeling. They are acclaimed advisors and prophets who
can glimpse the future, and their whole method is to accept suddenly knowing
something rather than working it out.

That shapes how they live. Most disregard formal education on the grounds that
too much of it builds walls that block the natural psychic emanations and
deaden a person to the real world. The same suspicion extends to technology and
to owning things: a mystic avoids cities and gadgets and accumulates nothing
except what uplifts the spirit - art, instruments, books.

Magic comes the same way. A Psi-Mystic sits down for a six-day trance and gets
up knowing six spells. He cannot be taught one, cannot buy one, and cannot
learn one from a scroll. Every new spell arrives at a new plateau in life, by
meditating on it.

## Alignment

Any.

## GM Notes

Someone will eventually try to hand a Psi-Mystic a spell book. It does not
work, and it is not a rules technicality - the character''s entire relationship
with magic is that it arrives unbidden. The same goes for plate armour, which
the book rules out on grounds of psychology rather than encumbrance.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'psi-mystic');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'psi-mystic';
-- Expect 0. The five automatic powers must all resolve.
SELECT 5 - count(*) AS missing_powers FROM psionic_powers
 WHERE name IN ('Exorcism', 'Sense Evil', 'Sixth Sense', 'Meditation', 'Mind Block');
-- Expect 1. The magic block is present, which is what separates this class
-- from the other three.
SELECT count(*) AS has_magic FROM imported_classes
 WHERE class_id = 'psi-mystic' AND instr(markdown, 'spells_starting: 6') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-psi-mystic-class.sql');
