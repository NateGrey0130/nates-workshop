-- The Knight of the Order of the Temple O.C.C., Rifts Dimension Book 1:
-- Wormwood p.70-73.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-knight-of-the-order-of-the-temple-class.sql
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written.
--
-- The Templars and the Hospitallers SHARE printed page 73: the Templar's
-- Transportation, Money, Cybernetics and Symbiotes lines are in the left
-- column and "The Knights of the Order of the Hospital" opens the right. Both
-- were read whole rather than to the foot of a column.
--
-- "knight" already exists in the catalog and is a different class; neither
-- Wormwood order uses that id.
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
  ('angel-hair-rope', 'Angel Hair Rope', 'rifts', 'gear', NULL, NULL, 'No published price. Wormwood runs on barter and this is made from what the living planet grows rather than sold; every O.C.C. in the book states Money: Not applicable.', 'Rope woven from angel hair, the cotton-like substance the living planet creates. It is white, yellow or tan, magically appears in the sky 30 to 100 feet (9 to 30.5 m) up and floats gently to the ground in fine strands 6 to 12 feet (1.8 to 3.7 m) long. It has the look, weight and feel of cotton and is three times stronger; woven into clothes it wears five times longer. The planet seems to know intuitively when its people need the fibers, and it also appears near places of habitation in regular cycles or on demand when a priest or wormspeaker calls for it. Every Wormwood O.C.C. is issued a coil: 50 feet (15 m) for the priest of light and the wormspeaker, 100 feet (30.5 m) for the warriors, the knights and the book''s named heroes. The book gives it no weight, no M.D.C. and no price.', 'Rifts Dimension Book 1: Wormwood p.42'),
  ('resin-spike', 'Resin Spike', 'rifts', 'gear', NULL, NULL, 'No published price. Wormwood runs on barter and this is made from what the living planet grows rather than sold; every O.C.C. in the book states Money: Not applicable.', 'A spike cut or moulded from Wormwood mucus resin, carried alongside rope and a grappling hook as climbing and anchoring kit. Liquified resin flows quietly from openings in the planet''s surface as a thick, warm, sticky glop with the consistency of liquified plastic; poured into molds and left to harden it becomes as strong as steel and as light as plastic, and the hardened rock can be chiseled, powdered or cut into slabs and made into everything from arrowheads and belt buckles to weapons and armor. The freelancer and both knight orders are issued 2D4 of them (p.69, p.72, p.76); the book''s named non-player heroes carry four (p.78) and six (p.82). No stats, no weight and no price are printed for the spike itself.', 'Rifts Dimension Book 1: Wormwood p.42');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'knight-of-the-order-of-the-temple', 'Knight of the Order of the Temple', 'rifts', '---
id: knight-of-the-order-of-the-temple
name: Knight of the Order of the Temple
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.70-73
category: occ
occ_group: men-of-arms
xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]
attribute_requirements: { PS: 14, PE: 14 }
mdc_base: "1d4x10+40"
ppe_base: "6d6+6"
bonuses:
  combat: { attacks: 1, initiative: 1 }
  saves: { horror_factor: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%; the book calls it the general animal riding skill" }
    - { name: "Motorcycles & Snowmobiles", base: 75, per_level: 4, note: "+15%; the book prints Pilot Motorcycle" }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%; the book prints Math: Basic" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 90, per_level: 5, note: "90%" }
    - { name: "Language: Other", base: 65, per_level: 5, note: "+15%; the book grants one language of choice" }
    - { name: "Literacy: Native Language", base: 90, per_level: 5, note: "The book prints this as Literacy: American (90%)." }
    - { name: "W.P. Targeting" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 4, categories: ["Weapon Proficiencies"], note: "The book says select two ancient and two modern. The catalog does not divide W.P.s that way, so this is four of choice." }
    - { name: "Hand to Hand: Expert", note: "May be raised to Hand to Hand: Martial Arts, or Hand to Hand: Assassin if of an evil alignment, for one O.C.C. related skill." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics"], bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"], bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 20 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "Travelling clothes." }
  - { item_id: "dress-clothing", qty: 1, note: "Or dress body armor." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "resin-spike", qty: "2d4" }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "Meditation"
    description: "Meditation helps the knight to focus, and he heals twice as fast as normal."
  - name: "Cathedral Standing"
    description: "Most knights of the Temple are highly respected and honored within the human society of Wormwood. They are given access to most buildings and homes, provided with a place to sleep, given food and drink, and treated to a great deal of attention and comfort."
restrictions: ["May not use symbiotic organisms", "May not use slime magic", "Cybernetics and bionics are virtually non-existent"]
side_effects: "A true knight of the Temple is NOT allowed to ally himself with or depend on anything not human. He may still pilot the battle saint and the battle saint orb and link with the spirit of Wormwood - all of which are considered great honors - and may use blood stones, magic crystals, techno-wizard items and rune weapons."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. || Attribute requirements: the book also requires noble or upper class heritage, which is not an attribute. Most are the children of Knights of the Order of the Temple (70%), relatives of priests of light (20%) or of heroes of renown (8%); only 2% come from another social class. That is recorded here rather than enforced. || W.P.: two ancient and two modern is a division the catalog does not make, so it is stored as four of choice and the book''s wording kept in the note. || Weapons and armor are described rather than issued: six to eight weapons including a knife, a sword and one magic weapon, and light plate through full plate at 60 to 100 M.D.C. with prowl penalties of -10% to -20%."
---

## Lore

The Knights of the Order of the Temple are also known as the Templars and the
Knights of the Cathedral. The vast majority are aristocratic knights who can
trace their family heritage back hundreds of years, most from a long line of
Templar Knights, others back to the old ruling powers or the priests of the
Cathedral.

They march gladly and sometimes harshly into battle, swords shining silver,
banners flying, trumpets trumpeting, energy lances crackling, robot or monster
steeds arching against the wind and firelight. Many wield ancient and powerful
weapons of magic passed from generation to generation.

They are the Cathedral''s most favored and trusted order. Most stay close to the
gilt-hemmed robes of the church''s most powerful priests and obey their every
command without question. The rule of thumb is that if a high priest commands
it, it must be right, true and good. If it seems wrong, the knight assumes he
must be mistaken and that the priest is privy to some secret information or
divine insight.

The worst of them hold themselves above others to the point of indifference and
cruelty, wearing the commands of the Cathedral like armor so that no matter how
ruthless they behave they can point to the church and say they were only
following orders.

## GM Notes

The typical player character starts at level one or two. The average non-player
Templar is 1D4+4 level; about 30% are 9th to 14th level.

In many regards these knights are reminiscent of Earth''s Japanese samurai. To
question a priest, especially a high priest, is to lose one''s honor. To disobey
an order is treason: severe punishment, demotion, and shame to the noble family.
To openly defy the Cathedral or a high priest without concrete proof of
wrongdoing is grounds for immediate dishonorable discharge - the knight and his
whole family drop from upper class to low class and are subjected to ridicule,
and he may be branded a traitor or heretic and excommunicated.

The Code of the Temple Knights is loosely similar to that of the cyber-knights
and the knights of Camelot, in seven parts: To Live, Fair Play, Nobility, Valor,
Honor, Courtesy and Loyalty. The laws of fair play, honor and nobility are
explicitly bent when dealing with non-humans, the lower classes and anyone the
Templars do not respect - which the book names as the apok, monks, holy terrors
and mercenaries. Fair Play and Nobility carry the note "not applicable to the
apok, D-bees, monsters, lower class and Forces of Darkness"; Valor, Honor and
Courtesy are ardently applied only to high priests, fellow Templars, recognized
authorities and the upper class, and the treatment of everyone else is
conditional.

Transportation: 40% ride motorcycles or hovercycles from Rifts Earth, 20% ride
horses, robot horses, pegasus, unicorns, gryphons or other noble creatures
(-10% on the horsemanship skill for these exotic animals). The rest walk.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'knight-of-the-order-of-the-temple');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'knight-of-the-order-of-the-temple';
SELECT count(*) AS wormwood_materials FROM gear WHERE slug IN ('angel-hair-rope', 'resin-spike');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-knight-of-the-order-of-the-temple-class.sql');
