-- The Warrior of Valhalla, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.170.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-warrior-of-valhalla-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- A TEMPLATE, NOT A RACE, STORED AS ONE BECAUSE THERE IS NO THIRD SLOT. The page
-- prints no attributes, no skills, no money and no experience table - it prints a
-- bonus package and says the chosen "can be mortals, demigods, or godlings of any
-- warrior/fighting O.C.C." That is something laid OVER a race and an occupation,
-- and a character here holds one class_id for each with nothing left over. The
-- loss is recorded in extraction_notes: a Warrior of Valhalla who was a godling
-- cannot also be a Godling.
--
-- THE M.D.C. IS A POOL BONUS, NOT mdc_base. The page says "M.D.C. BONUS:
-- Mega-damage creatures RECEIVE 1D4x100 bonus M.D.C." - it adds. Written as
-- mdc_base it would REPLACE, and a chosen Glitter Boy would come out weaker than
-- an unchosen one.
--
-- occ_restrictions uses except: ["group:magic"], which is the sentence the book
-- writes and which now resolves - all nine Rifts magic O.C.C.s are refused.
-- Before zz-rifts-occ-groups.sql it would have refused NOTHING, silently. This
-- class and the Norse Giant are what found that.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('odins-magic-armor', 'Odin''s Magic Armor', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats', 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'warrior-of-valhalla', 'Warrior of Valhalla', 'rifts', '---
id: warrior-of-valhalla
name: Warrior of Valhalla
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
occ_restrictions:
  except: ["group:magic"]
  note: "Odin chooses warriors, knights and paladins of any warrior or fighting O.C.C., including modern CS and NGR military, but NO practitioners of magic."
bonuses:
  pools: { mdc: "1d4x100", sdc: "2d6x10" }
  attributes: { Spd: "1d6" }
  combat: { initiative: 1 }
  saves: { horror_factor: 2, toxins_poisons: 3, disease: 3 }
natural_abilities:
  - { name: "Resistant to Cold", description: "Half damage." }
  - { name: "Resistant to Fatigue", description: "Tires half as fast." }
  - { name: "Odin''s Armor", description: "A suit of magic armour with 150 M.D.C. A character who is not a mega-damage creature is given magic chain mail with 150 M.D.C. instead." }
equipment_starting:
  - { item_id: "odins-magic-armor", qty: 1 }
restrictions:
  - "Alignment: any good or selfish alignment."
  - "Horror Factor: 12 when recognised as one of Odin''s chosen."
  - "The chosen may be mortals, demigods or godlings of any warrior or fighting O.C.C., including modern Coalition and NGR military O.C.C.s, but never a practitioner of magic."
  - "A MEGA-DAMAGE character receives the 1D4x100 bonus M.D.C. as printed. A character with Hit Points and S.D.C. instead sees these numbers DOUBLE - 2D6x10 S.D.C. is the doubled figure - and is given magic chain mail rather than the plate."
  - "Rolls no attributes of its own. A Warrior of Valhalla is whatever he already was; Odin''s choosing adds to him rather than replacing him."
side_effects: "These are noble warriors, knights and paladins chosen by Odin as part of his elite army. Most remain in Odin''s dimension; only a few are sent away on some special mission for their god, and that mission can be open-ended enough to leave one adventuring."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.170 with
  scripts/read-columns.py. Text layer, offset zero.

  THIS ENTRY IS A TEMPLATE, NOT A RACE, AND THE APP HAS NO SLOT FOR ONE. The
  page prints no attributes, no skills, no money and no experience table. What
  it prints is a bonus package and the sentence "these chosen can be mortals,
  demigods, or godlings of any warrior/fighting O.C.C." - that is, something
  laid OVER an existing race and an existing occupation. A character here holds
  one class_id for a race and one for an occupation, and there is no third.

  Stored as a thin R.C.C. by decision, which is the closest the two slots get:

  1. NO attribute_dice, deliberately. The book gives none, and inventing them
     would overwrite the very thing the entry says stays as it was. A character
     taking this race rolls standard attributes, which is the correct outcome
     for "a mortal chosen by Odin" and merely an approximation for a godling.
     THIS IS THE LOSS: a Warrior of Valhalla who was a godling cannot also be a
     Godling here, because that is the second slot already spent.
  2. THE M.D.C. IS A POOL BONUS, NOT mdc_base. The page says "M.D.C. BONUS:
     Mega-damage creatures RECEIVE 1D4x100 bonus M.D.C." - it adds to what the
     character already had. Written as mdc_base it would REPLACE it, and a
     chosen Glitter Boy would come out weaker than an unchosen one.
  3. The doubling rule for non-M.D.C. characters is prose. "Characters with hit
     points/S.D.C. see these numbers double" is conditional on the campaign, and
     `bonuses:` is unconditional; 2D6x10 is stored as the S.D.C. figure the
     page prints and the doubling is recorded under restrictions.
  4. occ_restrictions uses `except: ["group:magic"]`, which is exactly the
     sentence the book writes and now resolves correctly - all nine Rifts magic
     O.C.C.s are refused. Before zz-rifts-occ-groups.sql it would have refused
     NOTHING, silently, which is the failure that script exists to remove. This
     class is one of the two that found it.
  5. The armour is one gear STUB. The page gives it 150 M.D.C. and nothing else
     - no weight, no cost, no A.R. - and the plate/chain distinction is a
     campaign-setting difference rather than two items, so it is one row with
     both readings in the class prose.
---

## Lore

These are noble warriors, knights and paladins chosen by Odin as part of his
elite army. The chosen can be mortals, demigods or godlings, drawn from any
warrior or fighting occupation - including the modern Coalition and NGR military
- but never from the practitioners of magic.

Most Warriors of Valhalla remain in Odin''s dimension. Only a few are ever sent
away, on some special mission for their god.

## GM Notes

The mission is the hook, and the book says so outright: it "could be open-ended,
allowing for a player character". A Warrior of Valhalla in a party is on an
errand for Odin, and the G.M. decides how long a leash that is.

Worth knowing what this entry is NOT. It is not a race in the sense the other
Norse entries are - the character was something before Odin chose him, and the
page never takes that away. Stored here as a race because a character has two
slots and both were already spoken for, so a Warrior of Valhalla who ought to
also be a godling has to pick one. If a template layer ever exists, this is the
first thing that should move to it.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'warrior-of-valhalla');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'warrior-of-valhalla';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-warrior-of-valhalla-class.sql');
