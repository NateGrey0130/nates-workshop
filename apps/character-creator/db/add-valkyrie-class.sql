-- The Valkyrie, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.167-168.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-valkyrie-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- sdc_base 100, NOT a pool bonus - the one place in this block where that call
-- goes the other way. The Dwarf and the High Elf both say "plus those gained by
-- O.C.C.'s and physical skills"; the Valkyrie says "100 S.D.C. plus that gained
-- from PHYSICAL SKILLS" and never mentions O.C.C.s. She also grants her own
-- skills and her own related-skill list, so she is the self-contained case.
--
-- Horsemanship is granted at the Pilot bonus, +10%, because the page says
-- "Pilot: Any (+10%)" and this catalog files riding skills under their own
-- category. Same reading the Rifts Priest got.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('enchanted-chain-mail-valkyrie', 'Enchanted Chain Mail (Valkyrie)', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats', 'pantheons-of-the-megaverse');

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('valkyrie-magic-sword', 'Valkyrie Magic Sword', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats', 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'valkyrie', 'Valkyrie', 'rifts', '---
id: valkyrie
name: Valkyrie
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6+2"
  MA: "3d6"
  PS: "4d6+10"
  PP: "4d6"
  PE: "5d6"
  PB: "5d6"
  Spd: "6d6"
mdc_base: "2D6x10+30, plus 2D6 per level of experience"
sdc_base: 100
hit_points_base: "P.E. x 2 plus 1D6 per level of experience"
starting_money: "1d6x1000"
bonuses:
  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1, psionics: 1 }
skills:
  occ_skills:
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Spear", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P., three of choice; any." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0 }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - "Espionage"
      - "Medical"
      - "Military"
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Horsemanship", bonus: 10 }
      - "Pilot Related"
      - { name: "Science", bonus: 5 }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 11, count: 1 }
      - { level: 15, count: 1 }
natural_abilities:
  - { name: "Nightvision", description: "90 ft (27.4 m); can see in total darkness." }
  - { name: "See the Invisible", description: "Always active." }
  - { name: "Flight", description: "Can fly at will without tiring. Flying Spd is 66 (45 mph / 72 km)." }
  - { name: "Turn Invisible", description: "Four times a day, lasting 30 minutes each." }
  - { name: "Turn into Mist", description: "Two times per day." }
  - { name: "Speak All Languages", description: "Magically speaks all languages." }
  - { name: "Bio-regeneration", description: "1D4x10 M.D.C. every hour." }
equipment_starting:
  - { item_id: "enchanted-chain-mail-valkyrie", qty: 1 }
  - { item_id: "valkyrie-magic-sword", qty: 1 }
restrictions:
  - "Alignment: any good or selfish; NEVER evil."
  - "All valkyries are female."
  - "Horror Factor: 14 for those who recognise them as Choosers of the Slain."
  - "Attacks per melee: varies with level and skills."
  - "Speed 6D6 running, or a flat 66 (45 mph / 72 km) flying."
  - "Average level of experience 1D6+1; leaders average 1D6+6. Player characters start at first or second level."
  - "Valkyries are GIVEN their chain mail and sword and must purchase any other equipment. Independent valkyries carry 1D6x1000 credits worth of gold and jewelry; servants of Odin do not need much money."
side_effects: "Mythologically the Valkyries were Odin''s servants, the Choosers of the Slain, hovering invisibly over battlefields and taking the souls of those who died in combat to Valhalla. Odin sends them on special missions and sometimes lets them travel on their own for a century or two, or through the Megaverse to learn new skills such as the use of technological weapons. They are spirits of magic with limited magic powers and supernatural strength. Average life span 800+ years. Five feet six inches plus 2D6 inches (1.73 to 1.98 m), 140 to 170 pounds (63 to 76 kg)."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.167-168 with
  scripts/read-columns.py. Text layer, offset zero. The entry straddles a page
  break: the stat block and R.C.C. skills are on 167, the related-skill
  categories and everything below Bonuses are on 168.

  1. sdc_base 100, NOT a pool bonus - and this is the one place in the Norse
     block where that call goes the other way. The Asgardian Dwarf and High Elf
     both say "plus those gained by O.C.C.''s and physical skills", which is the
     cumulative wording, so both are pool bonuses. The Valkyrie says "100
     S.D.C. plus that gained from PHYSICAL SKILLS" and never mentions O.C.C.s.
     She also grants her own skills and her own related-skill list, so she is
     the self-contained case rather than the race-plus-occupation one. Read as
     a base.
  2. HORSEMANSHIP IS GRANTED AT THE PILOT BONUS, +10%. The page says "Pilot:
     Any (+10%)" and grants Horsemanship outright as an R.C.C. skill; this
     catalog files riding skills under their own Horsemanship category, so
     listing Pilot alone would have withheld them from the related list. Same
     reading the Rifts Priest got.
  3. NO SECONDARY SKILLS. The page grants related skills and stops - there is
     no secondary allowance printed, so none is stored. That is a real absence
     rather than an oversight: the Rifts Priest and the Godling both print one
     and this does not.
  4. Electrical, Mechanical and Rogue are "None" and are therefore simply
     absent from the category list, which is how the format spells none.
  5. The magic chain mail and sword are STUBS with their book stats in the
     name only. The page gives the armour 100 M.D.C. and the sword 4D6 M.D.
     and nothing else - no weight, no cost, no range - so they are created as
     stub rows for the gear importer to fill rather than invented here.
  6. "Spirits of magic with limited magic powers" describes the natural
     abilities above, not a spell list. No magic block is stated, and none is
     invented - the flight, invisibility, mist form and universal speech ARE
     the magic powers the sentence refers to.
---

## Lore

Mythologically the Valkyries were Odin''s servants, "The Choosers of the Slain".
They would hover invisibly over battlefields, taking the souls of those who had
died in combat to Valhalla.

Odin also sends Valkyries on special missions, and sometimes allows them to
travel on their own for a century or two. He may even let some travel through
the Megaverse so they can learn new skills, like the use of technological
weapons - which is how one comes to be adventuring at all.

The creatures presented here are spirits of magic, with limited magic powers and
supernatural strength.

## GM Notes

A Valkyrie is haughty and noble and knows it. There are legends that only women
of royal blood were transformed into Valkyries, and they behave as though every
one of them were a queen. Cold and distant as a rule - except when they fall in
love, in which case they are more passionate than most, and can become terribly
possessive and vengeful if turned down or betrayed.

Their allies are the Warriors of Valhalla, the berserkers, and Odin''s servants.
Some human warriors consider it an honour to fight beside them; others see them
as walking reminders of their own mortality and avoid them entirely. Their
enemies are the undead, Hel and her minions, the Norse giant races, and the
forces of darkness generally.

They have a pale white complexion, hair of white, silver, light blue, blonde or
gold, and wing-like appendages.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'valkyrie');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'valkyrie';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-valkyrie-class.sql');
