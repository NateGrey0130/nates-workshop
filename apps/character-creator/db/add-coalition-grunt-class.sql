-- The Coalition Grunt O.C.C., Rifts Ultimate Edition p.231-232.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-coalition-grunt-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-coalition-grunt-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'coalition-grunt', 'Coalition Grunt', 'rifts', '---
id: coalition-grunt
name: Coalition Grunt
system: rifts
source_book: Rifts Ultimate Edition p.231-232
category: occ
extraction_notes: |
  - Only pages 231-232 were provided. These pages contain the introduction to
    the Coalition Grunt O.C.C. (also known as "Dead Boys") ' || char(8212) || ' background, lore,
    and general Coalition Military viewpoints ' || char(8212) || ' but NOT the actual stat block
    (attribute requirements, skills, equipment, bonuses, etc.), which would
    appear on subsequent pages not included here.
  - No mechanical fields (attribute_requirements, hit_points_base, sdc_base,
    skills, equipment_starting, bonuses, etc.) could be extracted because the
    page content is entirely prose/lore plus an illustration of "Dead Boy"
    armor (old style vs. new style), with no stat tables present.
  - If the remaining pages of this O.C.C. entry become available, this record
    should be revised to add the missing schema fields.
---

## Lore

Even the everyday infantry soldier ' || char(8211) || ' the Grunt, the backbone of the Coalition Army ' || char(8211) || ' is regarded as one of the Coalition Elite and a hero of the people. From the Grunt''s perspective, he is a patriot fighting on behalf of the Coalition States for the benefit and survival of humankind. Most are dedicated men and women willing to lay down their lives for what they believe is a good and noble cause. They are ruthless and merciless combatants when it comes to battling enemies who wield magic, are alien invaders (D-Bees), or monsters bent on tormenting, enslaving or destroying humankind (that''s demons, dragons, and just about everyone who isn''t human).

Generally, the Coalition Grunt comes from humble beginnings, possibly even from the ''Burbs, having joined the army as a way to get himself and his family moved up higher on the list of hopefuls waiting for citizenship and admission into one of the great fortress cities, like Chi-Town. Fewer than 15% can read, write or know mathematics, or have any other significant skills or education. Most are patriots who have joined the army as a way to better themselves, but ultimately, all they end up knowing is combat, and many become career soldiers. In regard to combat, they are rough and ready warriors who greet the jaws of death with a smile.

**Note:** The term "Dead Boys" is the common slang used by most civilians and people outside the Coalition States. The nickname arose from the soldiers'' skull-like helmets, black armor and the common death''s head motif of the Coalition armor. The use of the death symbology is deliberate and meant to intimidate and invoke fear and...

*(Text continues onto a subsequent page not included in this extract.)*

Additional context from the surrounding material (Coalition Military O.C.C.s overview and typical CS viewpoints, printed on the facing page as general framing rather than part of the Grunt''s own stat block):

- Coalition soldiers are indoctrinated to believe all non-human creatures are invaders and threats to humanity; official doctrine calls magic "alien and corrupting" and technology not of Coalition/allied origin "inhuman" and dangerous to use.
- Official viewpoints instilled in soldiers include obedience without question, distrust of magic and alien technology, and acceptance of the brutal necessities of war ("the cruelness of war").
- Not every soldier fits the mold: some are true patriots trying to do right within a flawed system, some quietly question or defy orders, some "go native" and desert to join those the CS considers enemies, and others become criminals, warlords, or outlaws after deserting.

## GM Notes

Page 232 shows only artwork: two versions of Dead Boy body armor labeled "Old Style" and "New Style," with no accompanying stat text. The old style features a more angular, spiked, skull-emblazoned helmet and armor; the new style has a sleeker skull-chest motif and rounded helmet design ' || char(8212) || ' useful as visual reference for GMs and players picturing the O.C.C.''s iconic armor, but no mechanical M.D.C. or cost values are given on this page.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'coalition-grunt');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'coalition-grunt';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-coalition-grunt-class.sql');
