-- Juicer Scout, one of the five Juicer-Related O.C.C.s Rifts World
-- Book Ten: Juicer Uprising defines, printed p.57-58.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-juicer-scout-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Woodcraft and guerrilla warfare laid over Juicer physiology. Only normal, Mega and Dragon Juicers can learn it, and it starts with 2D6x10 credits - pocket change against the Gladiator's 1D4x1000.
--
-- THIRD AND LAST BATCH. See add-hyperion-juicer-class.sql for why this book's
-- fifteen classes are fifteen rows rather than one with `variants`.
--
-- THIS SECTION HAS A SHAPE OF ITS OWN. The book introduces it by saying Juicers
-- can pursue other areas of training "but always as a Man of Arms", that each
-- entry "requires the character to be a Juicer", and that "all Juicer bonuses
-- and penalties remain the same, only the training/skill programs and some
-- bonuses vary". So the Gladiator, the Assassin and the Scout print SKILLS AND
-- NOTHING ELSE - no attribute dice, no pools, no saving throws.
--
-- The app models ONE OCCUPATION PER CHARACTER and cannot compose a Juicer with
-- a training programme laid over it. Rather than ship three classes that
-- produce an incomplete sheet, each carries the STANDARD Juicer's numbers,
-- which is the default the book itself names two sentences later: "Use the
-- experience table for the 'standard' Juicer O.C.C. unless one of the new
-- Juicer variants." A Gladiator who is a Hyperion substitutes the Hyperion's
-- numbers and keeps the skill programme, and every one of the three says so in
-- its special_abilities and its extraction_notes.
--
-- AND TWO OF THE FIVE ARE NOT JUICERS AT ALL. The book is explicit: "The
-- Gambler and Juicer Wannabe are not Juicers, but characters who are often
-- associated with them." Those two get no Juicer bonuses, no pools of their
-- own, occ_group `optional` rather than men-of-arms, and a CORE_SDC_BY_CLASS
-- entry at 1D6 - because a class stating neither an sdc_base nor an mdc_base
-- needs one, and neither of them is a man of arms.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'juicer-scout', 'Juicer Scout', 'rifts', '---
id: juicer-scout
name: Juicer Scout
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.57-58
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "A Juicer Scout is a Juicer first, so it carries the standard Juicer''s racial line as widened by Juicer Uprising p.16-17: Dwarves, Elves and Ogres alongside the human case. This programme is narrower than the other two in a different way - only normal Juicers, Mega-Juicers and Dragon Juicers can learn it - and all three of those admit Dwarves, so the list is unchanged."
hit_points_base: "P.E. + 1d4x10, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "2d6x10"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", Spd: "2d4x10" }
  attribute_minimums: { PS: 22 }
  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }
  saves: { psionics: 4, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language of choice (+10%)." }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed as Track Humanoids (+10%)." }
    - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "Printed as Track Animals (+15%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Espionage narrows to Intelligence and Escape Artist here, where the Juicer Assassin gets the whole category - the difference between a scout and a spy, in one line."
  secondary_skills:
    count: 5
special_abilities:
  - name: "Standard Juicer Abilities"
    description: "Everything the Juicer O.C.C. has: super endurance, strength, speed and reflexes, the automatic parry or dodge against attacks from behind and by surprise, enhanced healing, and virtual imperviousness to pain. The numbers in the bonuses block are the STANDARD Juicer''s, per the book''s own instruction; a Scout who is a Mega-Juicer or a Dragon Juicer substitutes that variant''s numbers and keeps this skill programme."
side_effects: "Standard Juicer, 5 years plus 4D6 months, with the usual insomnia, restlessness and impatience - or the variant''s, if the character is one."
restrictions: ["Requires the character to be a Juicer of some variety - this is a training programme, not a conversion.", "ONLY normal Juicers, Mega-Juicers and Dragon Juicers can learn this skill programme. A Hyperion, Titan, Phaeton, Delphi, Coalition Juicer, Psycho-Stalker or Maxi-Killer cannot be a Juicer Scout."]
extraction_notes: "THE NUMBERS IN bonuses ARE THE STANDARD JUICER''S, deliberately. The book prints only \"Standard Juicer abilities, skills as below\" and gives no figures of its own. The restriction to three variants is prose in `restrictions` because the app models one occupation per character and has no way to check which Juicer conversion a Juicer Scout came from. Money Bonus of 2D6x10 credits is stored as starting_money - by far the smallest in the book, and it is what the book prints."
---

## Lore

Not all Juicers are trained solely in combat. Some are taught the secrets of
hunting, woodcraft, guerrilla warfare, camouflage and ambush. The Juicer Scout
takes some of what a Wilderness Scout knows and lays it over Juicer physiology.

They work as special-operations soldiers, as messengers, and in the other jobs
that take a person out of the cities of Rifts Earth and into the dangerous
wastelands around them.

## GM Notes

**Only three conversions can learn this.** Normal Juicers, Mega-Juicers and
Dragon Juicers - and it is worth noticing that all three of those are the ones
that are hardest to kill and least dependent on being fast. A Hyperion cannot be
a Scout; nor can a Phaeton, a Delphi, a Titan or a Coalition Juicer.

**2D6x10 credits.** The Gladiator starts with 1D4x1000 and the Assassin with
1D6x1000. The Scout starts with pocket change, which tells you where he has been
and who he works for.

**Espionage narrows to Intelligence and Escape Artist**, where the Assassin gets
the whole category. That single line is the difference between a scout and a
spy, and it is the right place to look when a player asks which of the two to
take.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'juicer-scout');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'juicer-scout';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-juicer-scout-class.sql');
