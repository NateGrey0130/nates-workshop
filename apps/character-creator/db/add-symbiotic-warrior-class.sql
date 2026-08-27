-- The Symbiotic Warrior O.C.C., Rifts Dimension Book 1: Wormwood p.64-65.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-symbiotic-warrior-class.sql
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written. Skill bases are the catalog base plus the printed O.C.C. bonus,
-- already added; a parenthetical WITHOUT a plus sign is an absolute
-- percentage, which is how this book prints its languages, so
-- "Language: American (98%)" is base 98 rather than a bonus of 98.
--
-- THE PAGE RANGE IS 64-65, NOT 64-66. The survey's class table says 64-66;
-- printed 66 is entirely the Holy Terror R.C.C. and belongs to a later slice.
-- A citation has to survive source-coverage's window test, so it names the
-- pages the text is actually on.
--
-- AND p.64 CARRIES TWO "Standard Equipment:" BLOCKS. The one at the top of
-- the page is the WORMSPEAKER's - two hooded cloaks, 50 feet of rope, a
-- silver cross and wooden stakes - and the symbiotic warrior's is on p.65.
-- class-check --field-sources prints both; taking the first match would have
-- issued this class another class's kit.
--
-- occ_group is men-of-arms for all four. class-check does NOT require it and does
-- not report it as unmodelled, so all four read "ready" without it; the
-- regression test does require it, and failed with "4 of 78 ungrouped". The
-- gap between the two checks is real and reference/frontmatter.md documents
-- the key nowhere at all.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- Two Wormwood materials the catalog did not have. These are NOT stubs - the
-- book describes both on printed 42, under Mucus Resin and Angel Hair, so
-- there is nothing left for a later gear pass to fill in. cost stays NULL with
-- cost_note recording why, exactly as the 71 rows in add-wormwood-gear.sql do:
-- the planet grows this stuff and the people barter for it.
-- INSERT OR IGNORE, so whichever of these four scripts runs first wins and the
-- rest are no-ops. Filename order is execution order on a clean rebuild.
INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, description, source_book)
VALUES
  ('angel-hair-rope', 'Angel Hair Rope', 'rifts', 'gear', NULL, NULL, 'No published price. Wormwood runs on barter and this is made from what the living planet grows rather than sold; every O.C.C. in the book states Money: Not applicable.', 'Rope woven from angel hair, the cotton-like substance the living planet creates. It is white, yellow or tan, magically appears in the sky 30 to 100 feet (9 to 30.5 m) up and floats gently to the ground in fine strands 6 to 12 feet (1.8 to 3.7 m) long. It has the look, weight and feel of cotton and is three times stronger; woven into clothes it wears five times longer. The planet seems to know intuitively when its people need the fibers, and it also appears near places of habitation in regular cycles or on demand when a priest or wormspeaker calls for it. Every Wormwood O.C.C. is issued a coil: 50 feet (15 m) for the priest of light and the wormspeaker, 100 feet (30.5 m) for the warriors, the knights and the book''s named heroes. The book gives it no weight, no M.D.C. and no price.', 'Rifts Dimension Book 1: Wormwood p.42');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'symbiotic-warrior', 'Symbiotic Warrior', 'rifts', '---
id: symbiotic-warrior
name: Symbiotic Warrior
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.64-65
category: occ
occ_group: men-of-arms
xp_table: [0, 1901, 3701, 7401, 14801, 22101, 31201, 41301, 54401, 75501, 105601, 140701, 190801, 240901, 292001]
mdc_base: "30, plus 1d6 per level of experience"
ppe_base: "1d4x10, plus 1d6 per level of experience"
bonuses:
  attributes: { ME: -1 }
  combat: { initiative: 1, pull_punch: 1, roll: 1 }
  saves: { horror_factor: 2, possession: 1 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "98%" }
    - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book grants all riding animals in general" }
    - { name: "W.P. Targeting" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert", note: "Hand to Hand: Assassin instead, if the character is of an evil alignment." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", bonus: 5 }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Locate Home Town", "Ride Giant Parasites"]
equipment_starting:
  - { choose: 1, label: "hooded cloak or cape", qty: 1, from: ["hooded-cloak", "cape"] }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack; the catalog has no medium." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet. The book prints (15 m), which is the metric figure for FIFTY feet; its other three warrior O.C.C.s print 100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "Symbiotic Organisms"
    description: "The symbiotic warrior starts with one claw, one crawler, one star and one worm, each of his choice, and adds one more symbiote at levels 2, 4, 6, 8, 10 and 12. He may also acquire and use symbiotic stones and crystals, the spirit of Wormwood, worms of blood, worms of mending, and the potions and ointments made from magic slime."
  - name: "Horror Factor 10"
    description: "The symbiotic warrior has a horror factor of 10 and may frighten humans and monsters alike."
level_progression:
  - { level: 2, grants: ["One additional symbiotic organism"] }
  - { level: 4, grants: ["One additional symbiotic organism"] }
  - { level: 6, grants: ["One additional symbiotic organism"] }
  - { level: 8, grants: ["One additional symbiotic organism"] }
  - { level: 10, grants: ["One additional symbiotic organism"] }
  - { level: 12, grants: ["One additional symbiotic organism"] }
restrictions: ["Cannot select additional communion abilities as he grows in experience", "Not trained in the art of meditation", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Penalties: -1 M.E. and -1D4 Spd. The Spd loss is a die roll and is not applied automatically; roll it and subtract it by hand."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. This is a property of the setting, not a failed extraction. || The Standard Equipment line prints 100 feet of rope (15 m; made from angel hair). 100 feet is 30.5 m, and the other three warrior O.C.C.s in this book print 100 feet (30.5 m); the wormspeaker on p.63-64 prints 50 feet (15 m). The metric figure is the book''s own typo, and the FEET figure is transcribed. This script adds the angel-hair-rope catalog row the four warrior O.C.C.s all needed. || Pilot: the book excludes power armor, robots, tanks and spaceships. Only Pilot-category rows can be excluded from a Pilot pick, so tanks is Military: Tanks & APCs (which the catalog files under Pilot) and spaceships are the three Space craft rows. The robot combat rows and the two power armor suits are excluded on the same reading the Juicer Gladiator already uses for the same book phrase."
---

## Lore

A human or D-bee fighter who has given his body over to Wormwood''s symbiotic
organisms and fights with the powers they lend him. As a rule most of his
attributes are average or below - the symbiotes are what make him formidable,
not the man underneath. He is not a priest and not a mage, knows four prayers
and will never learn a fifth, and has never been trained to meditate.

Native humans of Wormwood have adapted to the energies of the living planet and
are mega-damage creatures in P.P.E. rich environments such as Wormwood and
Rifts Earth. In an environment that is not magic rich, the warrior''s M.D.C. is
S.D.C. instead.

Most are anarchist, unprincipled or scrupulous. The symbiotic warrior sits at
the low end of Wormwood''s social scale, and the horror of what rides on his
body is part of why.

## GM Notes

Dark Symbiotic Warriors are employed by the Forces of Darkness. The only real
difference between them and a player character is their black hearts and evil
alignment - the class is otherwise identical, which makes it a ready-made
antagonist.

The horror factor of 10 cuts both ways: it frightens humans as readily as
monsters, and the knights of the Temple and the priests of light look down on
anyone carrying symbiotes at all.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'symbiotic-warrior');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'symbiotic-warrior';
SELECT count(*) AS wormwood_materials FROM gear WHERE slug IN ('angel-hair-rope');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-symbiotic-warrior-class.sql');
