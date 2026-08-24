-- The Asgardian Dwarf, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.166.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-asgardian-dwarf-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- THE 60 S.D.C. IS A POOL BONUS, NOT sdc_base. The page says "60 S.D.C., plus
-- those gained from O.C.C.s and physical skills", which is the wording the class
-- format treats as cumulative. Written as sdc_base it is SILENTLY wrong:
-- combineClasses gives a race's pool precedence over the occupation's, so the
-- dwarf would carry 60 flat instead of 60 plus what his O.C.C. earned him, and
-- nothing on the sheet would look unusual.
--
-- The Rune Smith is NOT modelled as a class. Three quarters of the race are rune
-- smiths and the book gives them a heading, but it prints no attributes, no skill
-- list, no equipment and no experience table - it is a paragraph of what they can
-- do. Recorded under restrictions in full so nothing is lost.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source_book)
VALUES ('Language: Dwarven', 'Technical', 50, 5, 'pantheons-of-the-megaverse');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source_book)
VALUES ('Language: Old Norse', 'Technical', 50, 5, 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'asgardian-dwarf', 'Asgardian Dwarf', 'rifts', '---
id: asgardian-dwarf
name: Asgardian Dwarf
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+2"
  PP: "3d6"
  PE: "4d6"
  PB: "2d6"
  Spd: "2d6"
mdc_base: "2D4x10, plus 1D6 per level of experience"
hit_points_base: "P.E. + 2D6 plus 1D6 per level of experience"
psionics_allowed: false
bonuses:
  pools: { sdc: 60 }
  saves: { horror_factor: 6 }
skills:
  occ_skills:
    - { name: "Language: Dwarven", base: 98, per_level: 0, note: "Knows the Dwarven languages at 98%." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elven at 98%." }
    - { name: "Language: Old Norse", base: 98, per_level: 0, note: "At 98%." }
natural_abilities:
  - { name: "Nightvision", description: "90 ft (27.4 m); can see in total darkness." }
  - { name: "Impervious to Cold", description: "Cold does no damage." }
  - { name: "Aptitude for Making Things", description: "A natural aptitude for weapon design, mechanics and manufacturing: +10% to ALL mechanical, military, electrical and computer skills." }
restrictions:
  - "Alignment: any, but lean toward selfish."
  - "Horror Factor: none normally, 10 if their supernatural nature is revealed."
  - "Attacks per melee: two without combat training, or those gained from hand to hand combat and/or boxing."
  - "The +10% natural aptitude covers every mechanical, military, electrical and computer skill the character holds, wherever it came from. It is applied by hand rather than by the class, because the format bonuses a category only on RELATED picks and this reaches a skill from any source."
  - "Occupations: 25% are warriors, knights or scout types - any except modern, Coalition or NGR military - as well as mechanics and operators. They avoid invasive modifications: less than 10% have bio-wizard augmentation and less than 5% are spell casters. They generally refuse cybernetics, bionics, Juicer and Crazy conversions."
  - "RUNE SMITH: 75% of Asgardian Dwarves are masters of rune magic and can, with help, create rune weapons and devices. Creating one takes months or years, exotic components, incredible amounts of P.P.E., and the sacrifice of a living essence - usually a powerful hero, demon, elemental, creature of magic, godling or god. All rune smiths must be anarchist or evil and own one lesser and one greater rune weapon. They are not usually spell casters of any kind; ley line walkers and shifters assist them in that grim work."
  - "As an adventurer the rune smith''s craft is of little practical use, but he can identify authentic rune weapons, tell the level of a weapon''s power (lesser, greater, greatest) and its alignment, and read runes and magic symbols. He also understands bio-wizardry and the dangers and uses of symbiotic organisms."
side_effects: "The Dwarves of Asgard were the great artificers and weapon smiths of the gods, and every great magical weapon of Odin and the other gods was forged by them. Powerful in their own right but no match for the gods, they were forced into service. They may be the ancestors of all Dwarven races throughout the Megaverse, or normal dwarves who somehow gained superhuman powers. Average life span 600+ years. Three feet plus 3D4+2 inches tall (1.04 to 1.27 m), 175 to 250 pounds (79 to 113 kg). Only a few dozen have ever visited Rifts Earth, and there are only a few thousand of them to begin with."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.166 with
  scripts/read-columns.py. Text layer, offset zero.

  1. THE 60 S.D.C. IS A POOL BONUS, NOT sdc_base. The page says "60 S.D.C.,
     plus those gained from O.C.C.s and physical skills", which is the exact
     wording the class format treats as cumulative. Written as sdc_base it
     would be SILENTLY wrong: combineClasses gives a race''s pool precedence
     over the occupation''s, so the dwarf would carry 60 flat instead of 60 plus
     what his O.C.C. earned him, and nothing on the sheet would look unusual.
  2. NO RELATED OR SECONDARY SKILLS, which is correct for an R.C.C. - they come
     from the O.C.C. The three languages ARE granted, because the page lists
     them under "Skills of Note ... in addition to O.C.C. skills".
  3. `Language: Dwarven` and `Language: Old Norse` get REAL CATALOG ROWS rather
     than riding the family fallback. The fallback would have worked - both
     resolve through `Language: Other`, checked - and the 98% here is explicit
     either way. But the catalog already holds book-named languages as rows
     (`Language: Mongolian`, `Language: Trade Six`), so a language a book names
     belongs in the catalog where every other class can reach it too.

     They are filed the way those rows are filed: category Technical, base 50,
     +5 per level. NOT the shape class-check''s generated stub suggests, which
     is Communications at 0/0 - that generator is generic and knows nothing
     about the Language family, and 0/0 would have made two unusable rows.
  4. The +10% to mechanical, military, electrical and computer skills is a
     NATURAL ABILITY, not a category bonus, and the difference matters. A
     category `bonus` reaches related picks only; this reaches every skill of
     those categories the character holds, including ones his O.C.C. granted.
     There is no way to express that today, so it is recorded as prose in both
     the ability and a restriction rather than half-applied.
  5. `psionics_allowed: false` - the page gives the dwarf no psionics and no
     "Standard" line, unlike the Norse Giant on p.163 which says Standard
     outright. The contrast within one book is the evidence.

  THE RUNE SMITH IS NOT MODELLED AS A CLASS. Three quarters of the race are
  rune smiths and the book gives them a heading of their own, but it prints no
  attributes, no skill list, no equipment and no experience table for them - it
  is a paragraph of what they can do, not an O.C.C. It is recorded under
  restrictions in full. If it should become a real O.C.C. later, everything the
  book says about it is preserved here.
---

## Lore

The Dwarves of Asgard were the great artificers and weapon smiths of the gods.
All the great magical weapons of Odin and the other gods were forged by them.
These enchanters were powerful creatures in their own right, but were no match
for the gods, and were forced to become their servants.

They may be the ancestors of all the Dwarven races throughout the Megaverse, or
they may have been normal dwarves who somehow gained superhuman powers. Either
way they still practice rune magic - they may have been the original teachers of
that art - and normal dwarves are in awe of these greater versions of
themselves, even as the rune magic makes many dwarves of the Palladium world
fear or hate their "cousins".

Odin may allow small groups or single Dwarves to visit Rifts Earth to learn the
new techniques of high technology and techno-wizardry. Some young Dwarves might
be studying those new sciences and putting them to use on travels and quests.

## GM Notes

The dwarf is a target, and that is the hook. Splugorth raiders kidnap Asgardian
Dwarves to force them to work and teach in their rune factories, because the
dwarves are one of the few other races who know how to manufacture rune weapons
- a secret the Splugorth would rather keep to themselves. The minions of Lord
Splynncryth seek them out to capture or destroy whenever they are found away
from Asgard.

As servants of Odin they enjoy the protection of the Asgardian gods, and Thor is
particularly fond of them for the gift of Mjolnir. The Asgardian High Elves and
the dwarves dislike each other intensely, and skirmishes do break out.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'asgardian-dwarf');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'asgardian-dwarf';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-asgardian-dwarf-class.sql');
