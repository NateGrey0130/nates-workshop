-- The Freelancer O.C.C., Rifts Dimension Book 1: Wormwood p.68-70.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-freelancer-class.sql
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written.
--
-- THE Money PARAGRAPH RUNS ACROSS THE p.69/p.70 BREAK. Both halves were read.
-- It names no figure on either page - Wormwood runs on barter and the line
-- reads "Not applicable" - so no starting_money is stored. Both of this
-- repo's shipped starting_money errors were paragraphs read across a page
-- break (PR #280), and this is the same shape of paragraph in the same place.
--
-- This class states NO P.P.E. at all, unlike the two knight orders in the
-- same section, so no ppe_base is stored. That is the book's silence, not a
-- missed line.
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
SELECT 'freelancer', 'Freelancer', 'rifts', '---
id: freelancer
name: Freelancer
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.68-70
category: occ
occ_group: men-of-arms
xp_table: [0, 1901, 3701, 7401, 14801, 22101, 31201, 41301, 54401, 75501, 105601, 140701, 190801, 240901, 292001]
mdc_base: "1d4x10+20"
bonuses:
  saves: { horror_factor: 1 }
skills:
  occ_skills:
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book calls it the general animal riding skill" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%; the book prints Math: Basic" }
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints this as Language: American (90%)." }
    - { name: "Language: Demongogian", base: 80, per_level: 5, note: "80%" }
    - { name: "Language: Other", base: 65, per_level: 5, note: "+15%; the book grants one language of choice" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Select three of choice." }
    - { name: "Hand to Hand: Basic", note: "May be raised to Hand to Hand: Expert for one O.C.C. related skill, or to Hand to Hand: Martial Arts or Hand to Hand: Assassin for two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics"], bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"], bonus: 5 }
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "Travelling clothes." }
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
  - choose: 1
    from: ["Off-World Technological Weapon", "Magic Weapon or Item of Medium Power", "Extraordinary Physical Strength and Endurance", "Extraordinary Physical Prowess and Speed", "Symbiotic Organisms"]
  - name: "Off-World Technological Weapon"
    description: "01-20 on the book''s Special Freelancer''s Weapons or Abilities chart. A technological weapon or gun from another dimension - Kittani plasma weapons, energy pistols and rifles, rail guns, automatic firearms, a pair of vibro-blades. Power armor, cybernetics and bio-wizardry only if the G.M. allows it, and he has absolute say as to what these items are. The weapon''s power source has most likely been modified by Wormwood techno-wizardry to make it rechargeable or self-generating."
  - name: "Magic Weapon or Item of Medium Power"
    description: "21-40 on the chart. Game Master''s choice. 60% chance it was created on Wormwood, 40% chance it is a magic item from another dimension - any of the Rifts or Palladium RPG magic weapons or items."
  - name: "Extraordinary Physical Strength and Endurance"
    description: "41-60 on the chart. +6 to P.S. and +1D4 to P.E., plus an M.D.C. bonus of 1D4x10."
    bonuses: { attributes: { PS: 6 } }
  - name: "Extraordinary Physical Prowess and Speed"
    description: "61-80 on the chart. +1D4 to P.P. and +4D6 to Spd, plus +1 on initiative and +2 to roll with impact."
    bonuses: { combat: { initiative: 1, roll: 2 } }
  - name: "Symbiotic Organisms"
    description: "81-00 on the chart. Symbiotic organisms are the root of this character''s powers: select one star, one worm, and one other symbiote from the claw or crawler category. A freelancer may carry as many as four symbiotic organisms in all."
restrictions: ["Cybernetics and bionics are virtually non-existent"]
side_effects: "Freelancers may carry up to four symbiotic organisms, but are looked down on as low-brow and less noble for it, especially by the knights of the Temple and the priests of light."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. The Money paragraph runs across the p.69/p.70 break and both halves were read; it names no figure on either page. || The class states no P.P.E. at all, unlike the two knight orders in the same section, so no ppe_base is stored. || The Special Freelancer''s Weapons or Abilities chart is the book''s d100 table, kept in printed order with each entry''s roll range in its description, offered as a choose-one so a player who wants to roll still can. The two attribute entries carry only their FLAT bonuses; the dice halves (+1D4 P.E., +1D4 P.P., +4D6 Spd, 1D4x10 M.D.C.) are rolled by hand and stay in the description. || Weapons and armor are described rather than issued: the book gives ranges (four to seven different weapons; padded through full plate at 20 to 100 M.D.C.) rather than a list. || The Optional Background Table on p.69 is flavour with no mechanics and is kept as prose."
---

## Lore

The classic freelancer is a man at arms - a fighter dedicated to fighting evil
and winning back freedom for others, officially allied to the Cathedral or
another force of good. In the broadest sense the word covers any good-intentioned
mercenary or adventurer, wizard, cyborg from another world, even a dragon or
supernatural being, but the classic is a human from the lower, if not the lowest,
class of society.

Few can read or write and none has noble heritage, but most have the heart of a
lion. Human freelancers native to Wormwood might be thought of as a peasant army
dedicated to destroying the Unholy and bringing freedom to their people. Most
learned to fight from other freelancers and from friendly knights, particularly
Hospitallers and monks.

Many look to the knights of the Temple and the Hospital as their ideals and try
to be like them; some adopt a knight''s code of ethics and live up to its lofty
goals. In some cases these lowly freelancers are more true to the code of
chivalry and honor than the true knights. Just as many are lone wolves roaming
the world in search of evil, operating by their own codes and beliefs.

## GM Notes

The typical player character starts at level one or two. The average non-player
freelancer is 1D4+2 level; about 30% are 7th to 10th level and 5% are 11th to
15th.

The Optional Background Table on p.69 rolls up where the character came from:
the illegitimate child of a knight, nobleman, priest or famous hero (01-10); the
child of an apok, and regarded as a bad seed for it (11-20); a labourer''s child
who craves adventure (21-30); the child of a career freelancer (31-40); the child
of a vagabond family (41-50); a lowly D-bee trying to rise above the disdain of
being non-human (51-60); a character of high or low social class whose family was
destroyed by supernatural monsters and who wants revenge above all (61-80); a
D-bee who sees freelancing as the only way to make a good living and dislikes the
Knights of the Temple, who dislike him back (81-90); or a devout follower of the
Cathedral supporting the church with a sword (91-00).

Good characters not affiliated with any arm of the Cathedral are simply
adventurers or mercenaries and can be any O.C.C. or R.C.C.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'freelancer');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'freelancer';
SELECT count(*) AS wormwood_materials FROM gear WHERE slug IN ('angel-hair-rope', 'resin-spike');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-freelancer-class.sql');
