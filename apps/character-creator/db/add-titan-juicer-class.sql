-- Titan Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.32-35.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-titan-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs before this file
-- was generated: 0 errors, 0 warnings.
--
-- Metal fused into bone, 60-80% larger, supernatural strength and 4-22 M.D.C. Also the slowest Juicer, and often too big for the vehicle.
--
-- FIFTEEN CLASSES, NOT ONE WITH VARIANTS. The obvious reading of a book called
-- "New Juicer Variants" is that `variants` is the mechanism. It is not. Each of
-- these prints its OWN O.C.C. Skills, its own O.C.C. Related Skills - the
-- Hyperion gets six where the standard Juicer gets eight, the Mega five, the
-- Titan and Phaeton and Delphi seven - its own Secondary Skills, its own
-- Standard Equipment, its own Money line, and its own numbered list of O.C.C.
-- Abilities and Bonuses. VARIANT_OVERRIDES reaches attribute dice, attribute
-- requirements, the pool bases and `bonuses`, and nothing else. It cannot touch
-- the skills block or special_abilities, and that is where these differ. Same
-- call as the RUE dragons, for the same reason.
--
-- RACE RESTRICTIONS DIFFER BETWEEN THEM, which is the other reason they cannot
-- be variants. Juicer Uprising p.17 lets a Dwarf take the standard, Titan, Mega
-- and Dragon Blood conversions and bars him from the Phaeton and the Hyperion
-- by name - their reflex enhancements burn out the Dwarven nervous system. The
-- Delphi is not on the permitted list, so Dwarves are left off it too: an
-- `only` list fails CLOSED, which is the conservative reading where the book is
-- silent. See zz-race-juicer-non-human.sql for the standard Juicer's own
-- widening and why RUE does not overrule this book.
--
-- CONDITIONAL BONUSES ARE PROSE. `bonuses:` is applied unconditionally, so the
-- Phaeton's in-vehicle figures and the Delphi's without-the-helmet halving are
-- described rather than stored. The stored numbers are the ordinary case.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'titan-juicer', 'Titan Juicer', 'rifts', '---
id: titan-juicer
name: Titan Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.32-35
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "Juicer Uprising p.17 names the Titan as one of the three variants a Dwarf may take, along with Mega and Dragon Blood, and the standard conversion - though a Dwarven Titan stands only six to seven feet. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet."
hit_points_base: "P.E. + 1d4x100, +1d6 per level"
sdc_base: "3d6x100"
starting_money: "4d6x100"
bonuses:
  attributes: { PS: "2d6+8", PE: "3d4", PP: "1d4", Spd: "2d6" }
  attribute_minimums: { PS: 30, PP: 17 }
  combat: { initiative: 1, roll: 1, attacks: 1 }
  saves: { psionics: 5, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, horror_factor: 4, coma_death_pct: 25 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Piloting: two of choice (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"], note: "The book prints this as W.P. Heavy OR W.P. Heavy Energy Weapons; this catalog files those as Heavy Military Weapons and Heavy M.D. Weapons." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Medical is None for a Titan and is therefore absent from this list rather than restricted. Physical is any EXCEPT Acrobatics - a Titan is too big for it. Prowl carries a printed -5% penalty, listed by the book under both Physical and Rogue; a category bonus is one number and cannot be negative for one skill, so a Titan taking Prowl should read it at -5%. Pilot Related is open, but the book warns the Titan may simply be too large for most conventional vehicles."
  secondary_skills:
    count: 6
special_abilities:
  - name: "Reinforced Skeleton"
    description: "Eight weeks of treatment mix metal particles into bone tissue, leaving bones as strong as tempered steel. Titans end up 60% to 80% larger and three to four times heavier than they were - 600 to 700 lbs (270 to 315 kg) is average. The smallest Titan dead-lifts 3,000 lbs (1,350 kg); over two tons is the common limit."
  - name: "Minor Mega-Damage Being"
    description: "The S.D.C. and hit point totals together run 400 to 2,200, which the book counts as 4 to 22 M.D.C. Ordinary S.D.C. attacks still hurt and can still kill, but it takes a great deal of S.D.C. damage - and at only 22 M.D.C. a few well-placed blasts will do it, which is why most Titans wear armour anyway."
  - name: "Supernatural Strength"
    description: "The Titan''s P.S. is SUPERNATURAL: carry 50 times P.S. in pounds and lift 100 times P.S. Damage follows the supernatural strength table reprinted from Rifts Conversion Book One - at P.S. 30 that is 5D6 S.D.C. restrained, 3D6 M.D. full strength, 6D6 M.D. on a power punch counting as two attacks. Punching a mega-damage structure bare-handed costs the Titan one S.D.C. point per M.D. point inflicted; with M.D. gloves or gauntlets he punches with impunity."
  - name: "Super Speed"
    description: "Titans are the SLOWEST of the Juicers, but supernatural strength still carries them: leap 20 feet (6.1 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Barely better than normal for a Juicer, but gets an automatic parry or dodge against ALL attacks, including from behind and from surprise. The combat numbers are in the bonuses block."
  - name: "Enhanced Healing"
    description: "Heals one hit point or S.D.C. per point of P.E. EVERY HOUR - a Titan with P.E. 24 heals 24 an hour. Virtually impervious to pain, as per the normal Juicer. The +25% to save versus coma and death is in the bonuses block."
side_effects: "Low Life Span. Titans burn out faster than common Juicers: the average life span is 5 years and 2D6 months. All the normal Juicer penalties apply on top - insomnia, restlessness, impatience."
restrictions: ["Starts with no cybernetics and rarely acquires any."]
extraction_notes: "The 4-22 M.D.C. is a reading of the S.D.C./hit point total, not a separate pool, so it is prose rather than mdc_base - setting mdc_base would replace the S.D.C. the book actually grants. Augmentation cost is 100,000-150,000 credits, sometimes more, and is prose rather than starting_money, which is coin only. Standard equipment names Titan Plate Armor at 180 M.D.C., which has no gear row yet."
---

## Lore

The Titan conversion was developed in the kingdom of Los Alamo, near the ruins
of pre-Rifts Austin, Texas, by researchers trying to build a Juicer who could
fight a supernatural monster or a robot vehicle and win.

Hormone treatments got the strength there and then killed the subjects: past a
certain point they carried so much muscle that their own bones were crushed
under it. What the project needed was a way to make bone stronger than anything
an Earth animal grows. The answer was a chemical solution laced with metal
particles - in quantities that would be poisonous under most circumstances -
dissolved in a binding agent that sought out bone tissue and fused with it,
mixing metal and bone into a single whole.

Then growth hormones triggered a spurt like a human''s first sixteen years,
compressed into a matter of weeks. Eight weeks of Titan treatment leave a Juicer
60% to 80% larger and three to four times heavier, strong enough to punch
through power armour plating.

## GM Notes

**Demographics.** Titans are 5% of all Juicers in North America.

**The trade is speed for mass.** A Titan is the slowest Juicer and the only one
who is genuinely hard to kill - and the only one who has to think about whether
he fits. Pilot Related is open to him and the book still warns that most
conventional vehicles are not built for a seven-foot, 650-pound passenger.

**The supernatural strength table is the reason to look up P.S.** Everything
about a Titan''s damage output moves when P.S. crosses 30, 35 and 40, so the
rolled number matters more here than in any other Juicer variant.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'titan-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'titan-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-titan-juicer-class.sql');
