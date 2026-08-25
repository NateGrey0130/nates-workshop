-- The Greater Cyclops, an optional R.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.92-93.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-greater-cyclops-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. Text layer, so
-- nothing was OCR'd or inferred from a page image, and the printed-to-PDF
-- offset is zero (read-columns takes 1-based pages, so printed 92 is
-- argument 93). Validated with scripts/class-check.mjs --remote against the
-- PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Greek section, Minions of Olympia. Normal Palladium-world cyclops raised to the
-- level of godlings by Zeus and taught rune magic by Hephaestus.
--
-- LITERACY IS DELIBERATELY NOT GRANTED. The page says "SIXTY PERCENT will also be
-- literate" - a proportion of the race, not a racial ability. Granting it would
-- make every cyclops literate; it is recorded as a restriction instead.
--
-- RUNE MAGIC IS BACKGROUND, NOT A MECHANIC. The lore calls them rune masters and
-- the stat block grants no rune-magic ability, no spell list and no P.P.E. cost
-- for one. Inventing the mechanic would be exactly the plausible wrong answer
-- this repo keeps getting bitten by, so it stays prose.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- A language the book names that the catalog does not hold. Filed the way
-- every other named language row here is filed - Technical, 50%, +5 per level -
-- NOT the Communications/0/0 shape class-check's generic stub suggests.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source_book)
VALUES ('Language: Troll/Giant', 'Technical', 50, 5, 'pantheons-of-the-megaverse');

-- A language the book names that the catalog does not hold. Filed the way
-- every other named language row here is filed - Technical, 50%, +5 per level -
-- NOT the Communications/0/0 shape class-check's generic stub suggests.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source_book)
VALUES ('Language: Ancient Greek', 'Technical', 50, 5, 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'greater-cyclops', 'Greater Cyclops', 'rifts', '---
id: greater-cyclops
name: Greater Cyclops
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6+3"
  ME: "3d6"
  MA: "4d6"
  PS: "5d6+10"
  PP: "4d6"
  PE: "4d6"
  PB: "2d6"
  Spd: "2d6"
mdc_base: "3d6x100"
ppe_base: "1d6x50"
skills:
  occ_skills:
    - { name: "Language: Troll/Giant", base: 98, per_level: 0, note: "At 98%." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elf at 98%." }
    - { name: "Language: Ancient Greek", base: 98, per_level: 0, note: "At 98%." }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "All are excellent archers." }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "All are excellent javelin throwers." }
natural_abilities:
  - { name: "Nightvision", description: "60 feet (18.3 m); can see in total darkness." }
  - { name: "Impervious to Lightning and Electricity", description: "No damage at all." }
  - { name: "Resistant to Energy", description: "Other forms of energy do half damage." }
  - { name: "Bio-regeneration", description: "1D6x10 M.D.C. per 24 hours." }
restrictions:
  - "Alignment: any, but they lean towards unprincipled and anarchist."
  - "Horror Factor: 11."
  - "Only 60% are LITERATE, in Greek and Dragonese/Elf. Literacy is therefore not granted here; take it as a related or secondary skill if the character is one of them."
  - "RUNE MAGIC: Hephaestus taught them the secrets of rune magic, and the Splugorth who kidnap them do not know they are rune masters. The book grants no rune-magic mechanics with the race, so this is background rather than an ability."
  - "Average experience level of an established Greater Cyclops is 1D4+4. A player character still starts at level one."
side_effects: "Olive-skinned giants with one large eye in the centre of the head, usually long-haired with no facial hair. Fourteen feet tall (4.2 m), 600 to 1000 lbs (270 to 450 kg). They were normal cyclops of the Palladium world until Zeus raised them to the level of godlings; their unmodified brethren came to Earth and gave rise to the tales of one-eyed monsters. Most are found in Olympia, though a selected few are allowed into the Megaverse to further their education or to adventure."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.92-93 with
  scripts/read-columns.py. Text layer, offset zero.

  1. NO SKILL LIST BEYOND "Skills of Note", and no related or secondary
     allowance, which is correct for an R.C.C. - those come from the O.C.C.
     The three languages and two W.P.s ARE granted, because the page lists
     them.
  2. LITERACY IS DELIBERATELY NOT GRANTED. The page says "SIXTY PERCENT will
     also be literate in Greek and Dragonese/Elf" - a proportion of the race,
     not a racial ability. Granting it would make every cyclops literate;
     recording it as a restriction keeps the book''s odds visible without
     inventing certainty.
  3. `Language: Troll/Giant` and `Language: Ancient Greek` get real catalog
     rows, filed the way every named language row here is filed - Technical,
     50%, +5 per level. Same decision as the Norse block''s Dwarven and Old
     Norse.
  4. NO S.D.C. OR HIT POINT LINE, and none is needed: the class states
     mdc_base, so the core-rules default deliberately skips it and no
     CORE_SDC_BY_CLASS entry is required.
  5. NO occ_restrictions. The page names no occupation limits at all - unlike
     the Scorpion People two chapters earlier, which does. Silence is not a
     restriction.
  6. RUNE MAGIC IS BACKGROUND, NOT A MECHANIC. The lore says Hephaestus taught
     them rune magic and that they are rune masters, but the stat block grants
     no rune-magic ability, no spell list and no P.P.E. cost for one. Inventing
     a mechanic the page does not print is exactly the kind of plausible wrong
     answer this repo has been bitten by, so it stays prose.
---

## Lore

These were normal cyclops from the Palladium world, given superhuman powers by
Zeus. Some of their unmodified brethren came to Earth and gave rise to the tales
of one-eyed monsters; the ones Zeus recruited were raised to the level of
godlings, and taught the secrets of rune magic by Hephaestus.

They are usually found in Olympia, although a selected few have been allowed to
visit certain areas of the Megaverse to further their education or to take part
in adventures.

## GM Notes

A handful have been kidnapped and sold into slavery by the Splugorth - **who do
not know that these beings are rune masters**. That single sentence is the whole
adventure hook, and it works in either direction: a captive cyclops is a
sleeping weapon in a Splugorth market, and a freed one is a debt owed to
whoever worked it out first.

Note the split between what the page grants and what the lore claims. The cyclops
is a rune master in the fiction and has no rune-magic mechanics in its stat
block. If that matters at your table, it is a decision to make rather than a gap
to fill.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'greater-cyclops');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'greater-cyclops';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-greater-cyclops-class.sql');
