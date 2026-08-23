-- The Psychic Sensitive P.C.C., Palladium Fantasy main book, printed pp.156-157.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-psychic-sensitive-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-psychic-sensitive-class.sql
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
-- WHAT THE PSIONICS BLOCK COULD NOT SAY. Six Sensitive powers at first level
-- fits fine. The per-level alternative does not: instead of the usual Sensitive
-- power, at levels 3, 6, 9, 12 and 15 the character may take a Physical power
-- or one of seven named Super psionics - Empathic Transmission, Group Mind
-- Block, Hypnotic Suggestion, Mind Block Auto-Defense, Mind Bolt, Mind Bond,
-- Telemechanics. There is no schedule field in the psionics block, so it is
-- recorded in natural_abilities where the sheet shows it.
--
-- THE TWO SENSING ABILITIES ARE NOT PSIONIC POWERS. Sense Magic and Psionic
-- Energy, and Sense Supernatural Beings, are percentile abilities with no
-- catalog row and no I.S.P. cost - automatic and constant. They are natural
-- abilities, not psionics entries, and both carry their own ley line
-- interference rules, which are the interesting part: within two miles of a
-- line the sense halves, within four miles of a nexus it is gone.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'psychic-sensitive', 'Psychic Sensitive', 'palladium-fantasy', '---
id: psychic-sensitive
name: Psychic Sensitive
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "2d6"
starting_money: "200"
bonuses:
  saves: { mind_control: 3, possession: 5, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"
  powers: ["See Aura", "Sense Evil", "Presence Sense", "Meditation"]
  powers_starting: 6
  categories_allowed: ["Sensitive"]
skills:
  occ_skills:
    - { name: "Dowsing", base: 35, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 26, per_level: 4, note: "+6%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { choose: 2, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 10, note: "Two lores of choice (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
  occ_related_skills:
    count: 9
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two, Martial Arts or Assassin (if evil) three. The class grants no fighting style of its own." }
      - "Rogue"
      - { name: "Science", note: "+10% on Mathematics skills only" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
natural_abilities:
  - name: "Sense Magic and Psionic Energy"
    description: "Senses magic and psionic energy being expended. When the energy is continually expended - a series of attacks or a long-duration effect - the source can be pinpointed to within 20 feet (6 m). Base skill 30% +5% per level, rolled once per melee round; -10% where other P.P.E. sources confuse the sensation. Range 200 feet (61 m) +50 feet (15.2 m) per level. Automatic and constant, no I.S.P. Proximity to a ley line within two miles (3.2 km) halves it and a nexus within four miles (6.4 km) obliterates it - but the psychic can sense ley lines and nexus points themselves up to two miles off."
  - name: "Sense Supernatural Beings"
    description: "Like a bloodhound on a familiar scent. Detects gods, godlings, greater elementals, greater demons and deevils, dragons, and practitioners of magic of 10th level or higher. Base skill 30% +5% per level, +10% face to face even if the creature is disguised; identifying the nature of the being by scent alone, and tracking by psychic scent, both work at HALF the current skill. Range 50 feet (15 m) per level for a being not using its powers, and 1000 feet (305 m) +100 feet (30.5 m) per level for magic or psionics actually being expended. Ley lines and nexus points interfere exactly as above."
  - name: "Additional Psionic Abilities"
    description: "One further Sensitive power at each level of experience from level two. Alternatively, at levels 3, 6, 9, 12 and 15 the character may take one Physical power or one Super psionic instead - and the Super list is limited to Empathic Transmission, Group Mind Block, Hypnotic Suggestion, Mind Block Auto-Defense, Mind Bolt, Mind Bond and Telemechanics."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements beyond having psionic powers, though a high I.Q. and M.E. are strongly recommended."
  - "The character starts with NO hand to hand skill. Basic costs one related skill, Expert two, Martial Arts or Assassin (if evil) three."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Starting weapons are basic S.D.C. weapons of fair to good quality."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus. The app currently derives 12 for every major-or-better psychic; see extraction_notes."
  - "The starting dagger is silver-coated and the cross is a small silver one; the catalog prices neither, so the ordinary Daggers and Knives row and the large silver cross stand in."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s - Mind Melter, Burster, Psi-Stalker - are already stored. The P.C.C. distinction is recorded in restrictions instead. MASTER PSIONIC SAVE TARGET: the book says a master psionic saves on 10 or higher, and derive.js returns 12 for anything major or better (PSIONIC_SAVE_STRONG). That is an app-level gap affecting every existing master psionic in Rifts as well, not something this class import changes. The two sensing abilities are percentile powers with no catalog row and no I.S.P. cost, so they are natural_abilities. The per-level alternative - a Super psionic from a list of seven instead of a Sensitive power, at levels 3, 6, 9, 12 and 15 - has no shape in the psionics block and is recorded in the same place."
---

# Psychic Sensitive

## Lore

The Psychic Sensitive feels magic happening. Energy being spent - a spell woven,
a psionic attack pressed - registers the way a sound does, and with enough of it
the sensitive can point at where it is coming from. The same sense picks out
gods, godlings, greater elementals, greater demons and deevils, dragons and
high-level practitioners of magic, by something the book describes as scent.

Both abilities are automatic, constant and free. They also fail near ley lines:
within two miles the sense is halved, and within four miles of a nexus it is
gone entirely. What the sensitive can do near a ley line is feel the line
itself.

## Alignment

Any.

## GM Notes

This is the psychic who notices. A party with a Psychic Sensitive gets warning
that something supernatural is nearby, that a spell is being cast somewhere out
of sight, and roughly where. A party near a nexus gets none of it, which is a
usable piece of adventure design: the closer they get to the place where the
magic is strongest, the less their early-warning system tells them.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'psychic-sensitive');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'psychic-sensitive';
-- Expect 0. The four automatic powers must all resolve.
SELECT 4 - count(*) AS missing_powers FROM psionic_powers
 WHERE name IN ('See Aura', 'Sense Evil', 'Presence Sense', 'Meditation');
-- Expect 7. The Super psionics its per-level alternative names.
SELECT count(*) AS super_alternatives FROM psionic_powers
 WHERE name IN ('Empathic Transmission', 'Group Mind Block', 'Hypnotic Suggestion',
                'Mind Block Auto-Defense', 'Mind Bolt', 'Mind Bond', 'Telemechanics');

INSERT INTO data_script_runs (filename) VALUES ('add-psychic-sensitive-class.sql');
