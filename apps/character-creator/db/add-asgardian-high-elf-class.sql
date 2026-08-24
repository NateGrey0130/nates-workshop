-- The Asgardian High Elf, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.167.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-asgardian-high-elf-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- The S.D.C. is a POOL BONUS for the same reason as the Asgardian Dwarf on the
-- page before: "1D6x10+10 S.D.C. plus those gained by O.C.C.'s and physical
-- skills".
--
-- NO occ_restrictions. The page names knight, wilderness scout, scholar and borg
-- and then says "but usually a practitioner of magic", which describes what high
-- elves tend to be rather than closing the list. Reading it as a restriction
-- would bar occupations the book never bars.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source_book)
VALUES ('Language: Old Norse', 'Technical', 50, 5, 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'asgardian-high-elf', 'Asgardian High Elf', 'rifts', '---
id: asgardian-high-elf
name: Asgardian High Elf
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6+2"
  MA: "2d6+3"
  PS: "3d6"
  PP: "4d6"
  PE: "4d6"
  PB: "5d6"
  Spd: "6d6"
mdc_base: "1D4x10 plus 1D6 per level of experience"
hit_points_base: "P.E. + 3D6 plus 1D6 per level of experience"
bonuses:
  pools: { sdc: "1d6x10+10" }
  combat: { strike: 1, dodge: 1, pull_punch: 1 }
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elf at 98%." }
    - { name: "Language: Old Norse", base: 98, per_level: 0, note: "At 98%." }
natural_abilities:
  - { name: "Nightvision", description: "300 ft (91.5 m); can see in total darkness." }
  - { name: "Bio-regeneration", description: "4D6 M.D.C. per hour." }
restrictions:
  - "Alignment: any, but lean towards anarchist."
  - "Horror Factor: none."
  - "Attacks per melee: as per hand to hand training."
  - "Occupations: knight, wilderness scout, scholar, or even a borg, but usually a practitioner of magic. The book states this as a leaning rather than a rule, so no occupation is barred."
  - "The combat bonuses are in addition to skill and attribute bonuses."
side_effects: "These elves are similar to the traditional elves of fantasy worlds, but carry the status and power of demigods. Masters of magic and all the arts, they dislike cities and human endeavours. They live in Alfheim, near Asgard, and will fight beside Odin at Ragnarok. Average life span 1000 years. Six feet plus 2D6 inches tall (1.88 to 2.13 m), 150 to 230 pounds (67.5 to 103.5 kg)."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.167 with
  scripts/read-columns.py. Text layer, offset zero.

  1. THE S.D.C. IS A POOL BONUS, NOT sdc_base, for the same reason as the
     Asgardian Dwarf on the page before: "1D6x10+10 S.D.C. plus those gained by
     O.C.C.''s and physical skills". Written as sdc_base, combineClasses would
     give the race''s pool precedence over the occupation''s and the elf would
     silently lose whatever his O.C.C. earned him.
  2. NO RELATED OR SECONDARY SKILLS. Correct for an R.C.C.: they come from the
     O.C.C. The two languages are granted because the page lists them under
     "Skills of Note".
  3. `Language: Old Norse` is added to the catalog by this import, shared with
     the Asgardian Dwarf, as a Technical row at 50% +5 per level - the shape
     every other named language row in this catalog already has.
  4. NO occ_restrictions. The page names knight, wilderness scout, scholar and
     borg and then says "but usually a practitioner of magic", which is a
     description of what high elves tend to be, not a closed list. Reading it
     as a restriction would bar occupations the book never bars. The Norse
     Giant on p.163 shows what a real restriction looks like in this book -
     percentages and the word "limited to" - and this is not that.
  5. Nothing on the page says anything about psionics, so no block is stated
     and the character rolls normally. That is deliberately different from the
     Asgardian Dwarf, whose entry is equally silent - but the dwarf''s silence
     sits beside an explicit "Psionics: Standard" on the Norse Giant, and the
     honest reading of a book that says it when it means it is that silence
     means the default. Both are left to roll.
---

## Lore

These elves are similar to the traditional elves of fantasy worlds, but they
have the status and power of demigods. The High Elves are masters of magic and
all the arts, but dislike cities and human endeavours. They live in the realm of
Alfheim, near Asgard, and will fight beside Odin during Ragnarok. They love and
care for Yggdrasil and all Millennium Trees, and will fight any enemy that
threatens them.

Occasionally some high elves leave Alfheim and visit other places in the
Megaverse. They refer to normal elves as their children, and hint that they are
the creators of the elven race. Whether that is true is not known. Most "low"
elves dismiss any notion of common kinship and regard these snooty demigods with
suspicion and resentment - though some revere them as gods and welcome their
company.

## GM Notes

The high elf arrives with opinions about everyone. He has made friends among the
Asgardians, particularly the Valkyries and the Warriors of Valhalla, and some
titans have grown to respect these elves as different from the ones in the
Palladium world. He does not get along with the Asgardian Dwarves, and
skirmishes between the two break out. He is a deadly enemy of the giant races.

Played straight, that gives a party an ally with three standing feuds attached,
and a character who will drop everything to defend a Millennium Tree.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'asgardian-high-elf');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'asgardian-high-elf';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-asgardian-high-elf-class.sql');
