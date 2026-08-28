-- The Ram-Rat R.C.C., Rifts Dimension Book 1: Wormwood p.131-132.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-ram-rat-class.sql
--
-- The ram-rat starts partway down printed 131, under the tail of the
-- MORPHWORM, and ends on 132 above the RUMBLER. Both neighbours are in this
-- import - the morphworm in #356 and the rumbler in this PR - so all three
-- windows were checked against each other rather than against the survey.
--
-- W.P. axe: the book writes "two W.P. axe (same as blunt)" and that
-- parenthetical is the book telling you the mapping. It resolves to the one
-- W.P. Blunt row the catalog holds, not to a new row.
--
-- It is the only race in this slice with NO vulnerability at all: the book's
-- Vulnerabilities/Penalties line reads "None to speak of", which is unusual
-- enough in this section to be worth noticing rather than reading as an
-- extraction that missed something.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was written.
--
-- Follows the pattern #356 set for the R.C.C.s, which is worth stating because
-- three of the four rules were learned by a test failing rather than by reading
-- a reference:
--
--   * NO xp_table. regression.mjs pins that no R.C.C. carries one - experience
--     comes from what you do rather than from what you are, and the composition
--     fix in #222 depends on it. p.157 DOES print a ladder for every race in
--     this book, and it is what made them importable at all, so each one's
--     numbers are recorded in extraction_notes rather than dropped.
--   * NO related or secondary skills. They come from the O.C.C. Zero is
--     correct rather than missing, and all four of these grant zero.
--   * attacks are combat.attacks_base, which REPLACES the default of two - a
--     creature states a total where a class states a bonus.
--   * no sdc_base anywhere: all four are mega-damage creatures carrying
--     mdc_base, so none needs a CORE_SDC_BY_CLASS entry. A racial S.D.C. would
--     be a POOL BONUS and never sdc_base.
--
-- Money: no starting_money anywhere. Every class in this book prints
-- "Money: Not applicable" - Wormwood barters.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'ram-rat', 'Ram-Rat', 'rifts', '---
id: ram-rat
name: Ram-Rat
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.131-132
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6+6"
  PP: "3d6+6"
  PE: "3d6+3"
  PB: "2d4"
  Spd: "2d4x10"
mdc_base: "4d6x10"
ppe_base: "3d4x10"
bonuses:
  combat: { attacks_base: 4, initiative: 2, strike: 2, parry: 3, dodge: 3, roll: 2, pull_punch: 2 }
  saves: { spell_magic: 2, toxins_poisons: 2, harmful_drugs: 2, horror_factor: 4 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Dragonese", base: 98, per_level: 5, note: "98%" }
    - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints basic math" }
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt", note: "The book prints two W.P. axe and says outright that axe is the same as blunt." }
    - { name: "W.P. Sword" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice, including modern weapons." }
    - { choose: 2, categories: ["Pilot"], note: "Two piloting skills." }
    - { choose: 2, categories: ["Rogue"], bonus: 10, note: "Two rogue skills of choice (+10%)." }
    - { choose: 2, categories: ["Wilderness"], bonus: 10, note: "Two wilderness skills of choice (+10%)." }
natural_abilities:
  - { name: "Turn Invisible at Will", description: "And it sees the invisible. Together with its keen hearing, alert senses and speed this is what makes ram-rats excellent spies, assassins and thieves." }
  - { name: "Dimensional Teleport", description: "45%, twice per 24 hours, back to its homeworld or another familiar place." }
  - { name: "Nightvision", description: "400 feet (122 m)." }
  - { name: "Bio-Regeneration", description: "1D4x10 M.D.C. once per hour." }
  - { name: "Powerful Legs", description: "Leap 15 feet (4.6 m) high or lengthwise from a standing start, plus 10 feet (3 m) from a running start. Excellent balance 80%." }
  - { name: "Body Armor", description: "Typical ram-rat armor has 75 M.D.C. and a -5% prowl penalty, but they can wear anything a human can." }
restrictions: ["No psionic powers", "No magic knowledge beyond the natural abilities"]
side_effects: "Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 4D6x100. Damage: bite 1D6 M.D.; punches and kicks come off the supernatural P.S. The book lists no vulnerabilities at all - Vulnerabilities/Penalties reads None to speak of, which is unusual in this section and worth noticing at the table."
extraction_notes: "Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, shared with the demon goblin, the demon hound rider and the sky rider, and it is what made the race importable at all, so the numbers are recorded here rather than lost: 0 / 1,971 / 3,941 / 7,881 / 14,881 / 21,881 / 31,881 / 41,221 / 54,441 / 74,661 / 104,881 / 139,221 / 189,441 / 239,661 / 289,881. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone. || W.P. axe: the book writes two W.P. axe (same as blunt), so it resolves to the one W.P. Blunt row the catalog holds. The parenthetical is the book telling you the mapping, not a second proficiency. || Money: no starting_money; Special vehicle is None to start. Body armor is described rather than issued - the catalog has no 75 M.D.C. Wormwood plate row and the book gives it no price. || Attacks are stored as combat.attacks_base, which REPLACES the default of two, because a creature states a total where a class states a bonus."
---

## Lore

The ram-rat is a supernatural humanoid with the head of a rodent and the horns
of a goat. The body is muscular and covered with brown or grey fur. The ram
enjoys fighting, killing, torturing and abusing others, and is generally a
bully. They can be very sneaky and cunning, and will spare an opponent only to
keep him as a slave or to sell him into slavery. Several ram-rats typically
accompany any dimensional raiding party dispatched by the Host.

Beyond their keen hearing, alert senses, speed and fighting ability, they can
turn invisible and see the invisible - which makes them excellent spies,
assassins and thieves.

## GM Notes

The average ram-rat is a despicably evil fiend who preys on other intelligent
life forms, but there are anarchist ram-rats and the occasional good one. A
player character must be a renegade or a free agent. Unusually for this section
of the book, he has **little to fear from the Forces of Darkness** unless he
associates with the forces of good - in which case he is simply an enemy. Start
at first or second level.

Allegiances run 80% sworn to the Unholy, 5% allied to the Champions of Light,
and 15% mercenaries and freebooters. All are considered warriors: 50% equal to
third level, 30% sixth, 10% eighth, and 10% are warlords of tenth level ability.
They live about 1000 years.

Axes and swords are favorites, along with paired weapons, and they like magic and
energy weapons - especially vibro-blades, plasma swords, plasma axes and energy
rifles.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'ram-rat');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'ram-rat';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-ram-rat-class.sql');
