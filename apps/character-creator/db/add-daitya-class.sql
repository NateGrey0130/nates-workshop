-- The Daitya, an optional R.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.142-143.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-daitya-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. Text layer, so
-- nothing was OCR'd or inferred from a page image, and the printed-to-PDF
-- offset is zero (read-columns takes 1-based pages, so printed 142 is
-- argument 143). Validated with scripts/class-check.mjs --remote against the
-- PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Indian section. THE ROYAL DAITYA IS A VARIANT, not a second class: the page prints
-- one entry with two sets of numbers differing only in attribute dice, M.D.C.,
-- S.D.C. and P.P.E., every one of which is in VARIANT_OVERRIDES. Nothing about the
-- skills differs, which is just as well - `variants` cannot override the skills
-- block.
--
-- Both sdc_base and mdc_base are BASES here, not pool bonuses: the page gives flat
-- figures with no "plus those gained from" clause, unlike the Naga on the page
-- before. The contrast within two pages is the evidence.
--
-- The +2 dodge and +20% prowl are NOT in `bonuses:` - both are conditional on
-- being underwater, and `bonuses:` applies unconditionally. Speed is the
-- UNDERWATER figure (6D6+10) with the land figure (1D6) recorded as prose, the
-- format holding one Spd and the creature living in the water.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('daitya-magical-bracelets', 'Magical Bracelets (Daitya)', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats', 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'daitya', 'Daitya', 'rifts', '---
id: daitya
name: Daitya
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "2d6+2"
  ME: "3d6"
  MA: "3d6"
  PS: "4d6"
  PP: "3d6"
  PE: "4d6"
  PB: "2d6+3"
  Spd: "6d6+10"
mdc_base: "3d6x10"
sdc_base: "3d6x10"
hit_points_base: "2d6x10"
ppe_base: "1d6x10"
variants:
  - id: average
    name: "Daitya"
    attribute_dice: { IQ: "2d6+2", ME: "3d6", PS: "4d6", PB: "2d6+3", Spd: "6d6+10" }
    mdc_base: "3d6x10"
    sdc_base: "3d6x10"
    ppe_base: "1d6x10"
  - id: royal
    name: "Royal Daitya"
    attribute_dice: { IQ: "3d6+4", ME: "3d6+3", PS: "4d6+6", PB: "2d6+4", Spd: "6d6+20" }
    mdc_base: "2d4x100"
    sdc_base: "2d4x100"
    ppe_base: "1d6x20"
occ_restrictions:
  except: ["coalition-grunt", "coalition-samas-pilot", "coalition-technical-officer"]
  note: "Any O.C.C. except Coalition or NGR military. Typically underwater wilderness scouts, warriors, vagabonds, warlocks, shifters and ley line walkers."
psionics:
  type: "minor"
  isp_base: "4d6 plus the M.E. attribute number, +1D6 per level of experience"
  powers_starting: 3
  categories_allowed: ["Healing", "Physical", "Sensitive"]
  powers_schedule:
    - { level: 2, count: 1 }
    - { level: 4, count: 1 }
    - { level: 6, count: 1 }
    - { level: 8, count: 1 }
    - { level: 10, count: 1 }
    - { level: 12, count: 1 }
bonuses:
  combat: { initiative: 2, parry: 1 }
  saves: { horror_factor: 3 }
natural_abilities:
  - { name: "Nightvision", description: "500 feet (152 m); can see in total darkness and murky water." }
  - { name: "Powerful Swimmer", description: "Spd 6D6+10 underwater against 1D6 on land." }
  - { name: "Sense Motion Underwater", description: "Senses and locates invisible foes in the water." }
  - { name: "Resistant to Cold and Poison", description: "Takes half damage." }
  - { name: "Withstand Pressure", description: "Survives great depths underwater." }
  - { name: "Bite", description: "1D6 M.D., on top of supernatural P.S. damage." }
  - { name: "Skin Abrasions", description: "Like a shark, the skin is covered in small barbs. A Daitya swimming and sliding across someone inflicts 4D6 S.D.C. - no damage to M.D. structures, armour or creatures." }
equipment_starting:
  - { item_id: "daitya-magical-bracelets", qty: 1 }
restrictions:
  - "Alignment: any, but they lean toward anarchist or evil."
  - "Horror Factor: 14."
  - "+2 to dodge and +20% to prowl apply ONLY while underwater, so neither is applied automatically."
  - "Speed is 6D6+10 underwater but 1D6 on land - the attribute stored is the underwater figure, which is where a Daitya lives."
  - "MAGICAL BRACELETS are issued to elite warriors and to ALL Royal Daityas, not to every Daitya. They allow the wearer to levitate up to 30 feet (9 m) and float above the ground on dry land, magically swimming through the air at their normal underwater speed."
  - "The race disdains technology, relying on magic, psionics and its own powers."
side_effects: "Humanoids resembling mermaids and mermen - half human, half fish, twelve to fifteen feet long (3.6 to 4.6 m) and 400 to 1000 lbs (180 to 450 kg), the Royals at the upper end. Creatures of magic rather than demons, though they associate with them freely. They live in Hiranyapura, an underwater city whose superstructure can teleport and dimensionally teleport wherever its rulers wish, which is how they have plundered several dimensions and escaped when the going got tough. The Hindu gods expelled them from Earth over two thousand years ago."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.142-143 with
  scripts/read-columns.py. Text layer, offset zero.

  1. THE ROYAL DAITYA IS A VARIANT, not a second class. The page prints one
     entry with two sets of numbers - "Attributes (Average Daitya) ... Royal
     Daityas: ..." - differing only in attribute dice, M.D.C., S.D.C. and
     P.P.E. Every one of those is in VARIANT_OVERRIDES, so the variant
     mechanism holds it exactly. Nothing about the skills differs, which is
     just as well: `variants` cannot override the skills block.

     BOTH FORMS ARE LISTED, including the ordinary one, and that is not
     redundancy. A class carrying any variants is unusable until one is
     CHOSEN - the wizard blocks with "Choose which Daitya to continue" - so
     declaring only the Royal made every Daitya royal, with no way to be the
     average kind the page treats as the default. Caught by driving the
     wizard, not by reading the file; the frontmatter parsed perfectly either
     way. The base values duplicate the `average` variant deliberately, which
     is the same shape the Warlock uses for its one-force and two-forces.
  2. sdc_base AND mdc_base ARE BOTH STATED, and both are bases rather than pool
     bonuses - the page gives flat figures with no "plus those gained from"
     clause, unlike the Naga on the page before. The contrast within two pages
     is the evidence.
  3. THE +2 DODGE AND +20% PROWL ARE NOT IN `bonuses:`. Both are conditional on
     being underwater, and `bonuses:` is applied unconditionally. They are
     recorded as a restriction instead, per the rule that a conditional bonus
     is prose.
  4. SPEED IS THE UNDERWATER FIGURE. The page gives 6D6+10 underwater and 1D6
     on land, and the format holds one Spd. The underwater number is stored
     because that is where the creature lives, and the land figure is recorded
     under restrictions so nothing is lost.
  5. THE BRACELETS ARE STARTING EQUIPMENT WITH A CAVEAT. They go to elite
     warriors and all Royals, not to every Daitya - so the item is granted and
     the qualification is recorded, rather than being withheld from a class
     whose Royal variant always has them.
  6. occ_restrictions uses `except` on the three Coalition classes. The book
     bars "Coalition or NGR military"; this catalog holds no NGR O.C.C. at all,
     so there is nothing to name for that half and the sentence is recorded in
     the note. Written as `group:men-of-arms` it would have barred far more
     than the book does.
---

## Lore

The Daityas are monstrous creatures of magic who prefer the sea, the oceans and
deep lakes. They are sworn enemies of the gods and associate freely with demons
and other enemies of deities, though they are not themselves a demonic race -
they are closer to gargoyles in that respect: often associated with demons, and
really something else with great powers of its own.

They live in Hiranyapura, an underwater city whose superstructure can teleport
and dimensionally teleport whenever and wherever its rulers wish. That is how
they have travelled to several dimensions, destroying and plundering at will,
and escaping elsewhere when the going got tough.

A subspecies with almost godlike powers, the Royal Daityas, rules the city and
has challenged the gods themselves.

## GM Notes

Hiranyapura is the campaign, not the Daitya. The Hindu gods expelled them from
Earth over two thousand years ago, but a city that can dimensionally teleport can
come back on any day the G.M. chooses - and the book says outright that if it
appears on Rifts Earth it will immediately open diplomatic relations with Lord
Splynncryth. The Daityas already trade with the Splugorth and capture slaves for
those markets.

So a Daitya player character is either an emissary of something enormous that is
about to arrive, or a defector from it.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'daitya');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'daitya';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-daitya-class.sql');
