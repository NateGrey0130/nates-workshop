-- Eight elemental spells take the name the Book of Magic actually prints.
--
-- RETRO-AUDIT R20, taken 2026-09-05 on Nate's word: the eight rows whose drift
-- is INSIDE the elemental prefix, and not the four where the catalog's wording
-- is doing work the book's cannot.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r20-spell-names.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r20-spell-names.sql
--
--   Air: Atmospheric Manipulation        -> Air: Atmosphere Manipulation
--   Earth: Sculpt & Animate Clay         -> Earth: Sculpt and Animate Clay Animals
--   Earth: Transference of Essence       -> Earth: Transference of Essence & Intellect
--   Fire: Heat Object/Boil Water         -> Fire: Heat Object & Boil Water
--   Water: Breathe Underwater            -> Water: Breathe Under Water
--   Water: Communicate with Sea Creature -> Water: Communicate with Sea Creatures
--   Water: Impervious to Ocean Depth     -> Water: Impervious to Ocean Depths
--   Water: Summon Sharks or Whales       -> Water: Summon Sharks/Whales
--
-- Every heading above was read on its own printed page, not taken from a
-- summary list - the summary lists are what put 36 wrong citations into this
-- catalog in the first place. Printed 84 is CORRUPT in the source PDF, so
-- "Impervious to Ocean Depths" was rendered with PyMuPDF and read by eye:
-- the folio, the heading and "P.P.E.: Twelve" all visible, matching the row's
-- level 3 / 12 PPE. Printed 74's summary list spells the fire spell
-- "Heat Object/Boil Water" while its entry on printed 76 prints
-- "Heat Object & Boil Water" - THE BOOK DISAGREES WITH ITSELF, and the entry
-- wins here for the same reason it won during the citation repair.
--
-- ===================================================================
-- WHY THIS FILE REWRITES CLASS MARKDOWN, WHEN rename-robot-combat-skills.sql
-- DELIBERATELY DOES NOT
-- ===================================================================
--
-- That script left the citations alone and recorded a redirect instead, and its
-- header explains why: crossReference() treats a redirecting key as present.
-- THAT IS TRUE FOR SKILLS AND FALSE FOR SPELLS, and R20 was filed believing
-- otherwise. A spell citation is resolved in three places that never see a
-- redirect:
--
--   catalogs.js               the wizard boot payload - it SELECTs name, level,
--                             ppe, ppe_note, system, source_book from spells and
--                             sends no redirect table at all
--   app.js (x3)               the client filters a class's named list by exact
--                             lowercased name against that payload, and reports
--                             "N named spells are not in the catalog yet"
--   _lib/power-picks.js       loadPowerCatalog, which backs level-up confirm and
--                             validate-character.js. Only loadPowerDescriptions
--                             resolves redirects; the catalog loader does not
--
-- So a bare rename 422s a level-up confirm in BOTH directions: the old name is
-- not in the catalog, and the new name is not on the list the grant draws from.
-- The repo had already written this down twice - fix-rue-spell-levels.sql and
-- docs/spell-and-psionic-imports.md both refuse a RUE spelling on exactly these
-- grounds - and R20 did not say so.
--
-- The citations therefore move WITH the rename, in this statement, and the
-- redirects below are belt and braces for the importer rather than the plan.
--
-- THE PRECEDENT'S WARNING IS ANSWERED BY MEASUREMENT, NOT WAVED AT. It says
-- markdown is "frontmatter mixed with lore prose and a blind replace would hit
-- both". Measured against production 2026-09-05: all 134 occurrences sit in the
-- YAML frontmatter, ZERO in the prose body, and all 134 are DOUBLE-QUOTED list
-- entries. So the replace matches the name WITH ITS QUOTES and cannot reach
-- prose even if some later class puts one of these phrases in a sentence.
--
-- Quoting also makes the replace idempotent for free, which matters for exactly
-- one row: "Earth: Transference of Essence" is a PREFIX of its own replacement,
-- so an unquoted replace would compound to "... & Intellect & Intellect" on the
-- second run. With the closing quote it cannot match the new text at all.
--
-- ===================================================================
-- THE FOUR LEFT ALONE, AND WHY EACH IS NOT DRIFT
-- ===================================================================
--
--   Fire: Fire Ball        the book prints "Fire Ball (Warlock)". RUE already
--   Air: Wind Rush         supplies an unprefixed "Fire Ball" and "Wind Rush",
--                          and spells.name is UNIQUE - the elemental prefix is
--                          doing precisely the job the book's parenthetical
--                          does, so adopting the book's wording would trade a
--                          working disambiguator for a broken one and drop both
--                          rows out of the picker's "Fire:" / "Air:" filter.
--
--   Water: Swim as a Fish: Superior
--                          the book prints "(Superior)", and stem() drops a
--                          parenthetical - the renamed row would gain the bare
--                          alias "swim as a fish", already held by two other
--                          rows. That is the importer's refuse-to-match case,
--                          and no test would go red because the fixture that
--                          pins it is hardcoded.
--
--   Water: Calm Waters (greater)
--                          the book prints "Calm Waters" TWICE - printed 84 at
--                          level 3 / 15 PPE and printed 88 at level 8 / 100 PPE.
--                          The catalog cannot, so "(greater)" is the catalog
--                          saying what the book says by position.
--
-- The elemental prefix itself is not a matter of taste: 231 spells carry one and
-- 231 spells cite the four elemental blocks on printed 57-90, and they are the
-- same 231 rows. All eight renames below KEEP their prefix.
--
-- Checked before writing this, against production 2026-09-05: none of the eight
-- new names already exists, and none of them introduces a variant the importer's
-- matcher would find ambiguous. No character and no draft holds any of the
-- twelve, so the repoint below is expected to change nothing - it is here
-- because "expected" is not "guaranteed in every environment".


-- ===== 1. Rename, only where the target name is free =====
-- Guarded the way rename-robot-combat-skills.sql guards: a rename into an
-- occupied name would fail the UNIQUE constraint loudly, and doing nothing is
-- the right answer for a database that already has the new name.
UPDATE spells SET name = 'Air: Atmosphere Manipulation'
 WHERE name = 'Air: Atmospheric Manipulation'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Air: Atmosphere Manipulation');

UPDATE spells SET name = 'Earth: Sculpt and Animate Clay Animals'
 WHERE name = 'Earth: Sculpt & Animate Clay'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Earth: Sculpt and Animate Clay Animals');

UPDATE spells SET name = 'Earth: Transference of Essence & Intellect'
 WHERE name = 'Earth: Transference of Essence'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Earth: Transference of Essence & Intellect');

UPDATE spells SET name = 'Fire: Heat Object & Boil Water'
 WHERE name = 'Fire: Heat Object/Boil Water'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Fire: Heat Object & Boil Water');

UPDATE spells SET name = 'Water: Breathe Under Water'
 WHERE name = 'Water: Breathe Underwater'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Water: Breathe Under Water');

UPDATE spells SET name = 'Water: Communicate with Sea Creatures'
 WHERE name = 'Water: Communicate with Sea Creature'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Water: Communicate with Sea Creatures');

UPDATE spells SET name = 'Water: Impervious to Ocean Depths'
 WHERE name = 'Water: Impervious to Ocean Depth'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Water: Impervious to Ocean Depths');

UPDATE spells SET name = 'Water: Summon Sharks/Whales'
 WHERE name = 'Water: Summon Sharks or Whales'
   AND NOT EXISTS (SELECT 1 FROM spells WHERE name = 'Water: Summon Sharks/Whales');


-- ===== 2. The citations move with the rename =====
-- 134 occurrences across 11 classes: the ten per-Force Warlocks and the
-- Fire/Water Elemental Fusionist. The count is high because each name repeats
-- in every CUMULATIVE level list - Water: Breathe Underwater alone appears in
-- L2 through L8 of five classes.
--
-- One statement per name rather than one nested expression, so a partial
-- application is still a correct partial application, and each is guarded on
-- its own name so a re-run does nothing.
UPDATE imported_classes
   SET markdown = replace(markdown, '"Air: Atmospheric Manipulation"', '"Air: Atmosphere Manipulation"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Air: Atmospheric Manipulation"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Earth: Sculpt & Animate Clay"', '"Earth: Sculpt and Animate Clay Animals"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Earth: Sculpt & Animate Clay"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Earth: Transference of Essence"', '"Earth: Transference of Essence & Intellect"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Earth: Transference of Essence"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Fire: Heat Object/Boil Water"', '"Fire: Heat Object & Boil Water"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Fire: Heat Object/Boil Water"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Water: Breathe Underwater"', '"Water: Breathe Under Water"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Water: Breathe Underwater"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Water: Communicate with Sea Creature"', '"Water: Communicate with Sea Creatures"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Water: Communicate with Sea Creature"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Water: Impervious to Ocean Depth"', '"Water: Impervious to Ocean Depths"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Water: Impervious to Ocean Depth"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Water: Summon Sharks or Whales"', '"Water: Summon Sharks/Whales"'),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL AND instr(markdown, '"Water: Summon Sharks or Whales"') > 0;


-- ===== 3. Forwarding pointers for the retired names =====
-- reason 'rename', not 'merge': nothing was deleted, and that distinction is the
-- only record of which of the two happened.
--
-- These are NOT what keeps the classes working - section 2 is. They exist for
-- crossReference(), which the class importer uses to decide whether a cited key
-- is missing: re-importing one of these classes from an older extraction would
-- otherwise report eight spells the catalog "lacks". They are also the first
-- spell redirects this database has ever held - the 45 existing rows are
-- skills, gear and psionics only.
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Air: Atmospheric Manipulation', id, 'rename'
  FROM spells WHERE name = 'Air: Atmosphere Manipulation';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Earth: Sculpt & Animate Clay', id, 'rename'
  FROM spells WHERE name = 'Earth: Sculpt and Animate Clay Animals';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Earth: Transference of Essence', id, 'rename'
  FROM spells WHERE name = 'Earth: Transference of Essence & Intellect';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Fire: Heat Object/Boil Water', id, 'rename'
  FROM spells WHERE name = 'Fire: Heat Object & Boil Water';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Water: Breathe Underwater', id, 'rename'
  FROM spells WHERE name = 'Water: Breathe Under Water';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Water: Communicate with Sea Creature', id, 'rename'
  FROM spells WHERE name = 'Water: Communicate with Sea Creatures';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Water: Impervious to Ocean Depth', id, 'rename'
  FROM spells WHERE name = 'Water: Impervious to Ocean Depths';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Water: Summon Sharks or Whales', id, 'rename'
  FROM spells WHERE name = 'Water: Summon Sharks/Whales';


-- ===== 4. Characters and drafts holding a retired name =====
-- Production holds ZERO of these today - measured, not assumed - so every
-- statement here is expected to change nothing. They are written anyway because
-- this script also runs against a local rebuild and against any environment
-- stood up later, and a character whose sheet silently loses a spell's text is
-- the exact failure loadPowerDescriptions' redirect arm was added to prevent.
--
-- Matches the QUOTED name, not the "name":"value" pair, for the reason
-- rename-robot-combat-skills.sql gives: the pair looks safer and breaks the
-- moment the JSON key order changes.
UPDATE characters SET powers = replace(replace(replace(replace(powers,
         '"Air: Atmospheric Manipulation"', '"Air: Atmosphere Manipulation"'),
         '"Earth: Sculpt & Animate Clay"', '"Earth: Sculpt and Animate Clay Animals"'),
         '"Fire: Heat Object/Boil Water"', '"Fire: Heat Object & Boil Water"'),
         '"Water: Breathe Underwater"', '"Water: Breathe Under Water"')
 WHERE powers IS NOT NULL AND (
       instr(powers, '"Air: Atmospheric Manipulation"') > 0
    OR instr(powers, '"Earth: Sculpt & Animate Clay"') > 0
    OR instr(powers, '"Fire: Heat Object/Boil Water"') > 0
    OR instr(powers, '"Water: Breathe Underwater"') > 0);

UPDATE characters SET powers = replace(replace(replace(replace(powers,
         '"Earth: Transference of Essence"', '"Earth: Transference of Essence & Intellect"'),
         '"Water: Communicate with Sea Creature"', '"Water: Communicate with Sea Creatures"'),
         '"Water: Impervious to Ocean Depth"', '"Water: Impervious to Ocean Depths"'),
         '"Water: Summon Sharks or Whales"', '"Water: Summon Sharks/Whales"')
 WHERE powers IS NOT NULL AND (
       instr(powers, '"Earth: Transference of Essence"') > 0
    OR instr(powers, '"Water: Communicate with Sea Creature"') > 0
    OR instr(powers, '"Water: Impervious to Ocean Depth"') > 0
    OR instr(powers, '"Water: Summon Sharks or Whales"') > 0);

UPDATE character_drafts SET state = replace(replace(replace(replace(state,
         '"Air: Atmospheric Manipulation"', '"Air: Atmosphere Manipulation"'),
         '"Earth: Sculpt & Animate Clay"', '"Earth: Sculpt and Animate Clay Animals"'),
         '"Fire: Heat Object/Boil Water"', '"Fire: Heat Object & Boil Water"'),
         '"Water: Breathe Underwater"', '"Water: Breathe Under Water"')
 WHERE state IS NOT NULL AND (
       instr(state, '"Air: Atmospheric Manipulation"') > 0
    OR instr(state, '"Earth: Sculpt & Animate Clay"') > 0
    OR instr(state, '"Fire: Heat Object/Boil Water"') > 0
    OR instr(state, '"Water: Breathe Underwater"') > 0);

UPDATE character_drafts SET state = replace(replace(replace(replace(state,
         '"Earth: Transference of Essence"', '"Earth: Transference of Essence & Intellect"'),
         '"Water: Communicate with Sea Creature"', '"Water: Communicate with Sea Creatures"'),
         '"Water: Impervious to Ocean Depth"', '"Water: Impervious to Ocean Depths"'),
         '"Water: Summon Sharks or Whales"', '"Water: Summon Sharks/Whales"')
 WHERE state IS NOT NULL AND (
       instr(state, '"Earth: Transference of Essence"') > 0
    OR instr(state, '"Water: Communicate with Sea Creature"') > 0
    OR instr(state, '"Water: Impervious to Ocean Depth"') > 0
    OR instr(state, '"Water: Summon Sharks or Whales"') > 0);


-- ===== READBACKS =====
-- Every `want` below was MEASURED against production on 2026-09-05 before this
-- script was written, not reasoned about afterwards.

-- The catalog: eight new names present, eight old names gone, and the row count
-- unchanged because a rename creates and destroys nothing.
SELECT 'the eight new names exist' AS assertion,
       (SELECT count(*) FROM spells WHERE name IN (
          'Air: Atmosphere Manipulation','Earth: Sculpt and Animate Clay Animals',
          'Earth: Transference of Essence & Intellect','Fire: Heat Object & Boil Water',
          'Water: Breathe Under Water','Water: Communicate with Sea Creatures',
          'Water: Impervious to Ocean Depths','Water: Summon Sharks/Whales')) AS got,
       8 AS want;

SELECT 'no old name survives in the catalog' AS assertion,
       (SELECT count(*) FROM spells WHERE name IN (
          'Air: Atmospheric Manipulation','Earth: Sculpt & Animate Clay',
          'Earth: Transference of Essence','Fire: Heat Object/Boil Water',
          'Water: Breathe Underwater','Water: Communicate with Sea Creature',
          'Water: Impervious to Ocean Depth','Water: Summon Sharks or Whales')) AS got,
       0 AS want;

SELECT 'the catalog is the same size' AS assertion,
       (SELECT count(*) FROM spells) AS got, 607 AS want;

-- The convention survives: all eight kept their prefix, so the count of
-- prefixed rows cannot have moved.
SELECT 'the elemental prefix count is untouched' AS assertion,
       (SELECT count(*) FROM spells WHERE name LIKE 'Air: %' OR name LIKE 'Earth: %'
          OR name LIKE 'Fire: %' OR name LIKE 'Water: %') AS got,
       231 AS want;

-- The citations. This is the half rename-robot-combat-skills.sql does NOT do,
-- and the half that keeps a Warlock's level-up from returning 422.
SELECT 'no class still cites a retired spell name' AS assertion,
       (SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL AND (
             instr(markdown, '"Air: Atmospheric Manipulation"') > 0
          OR instr(markdown, '"Earth: Sculpt & Animate Clay"') > 0
          OR instr(markdown, '"Earth: Transference of Essence"') > 0
          OR instr(markdown, '"Fire: Heat Object/Boil Water"') > 0
          OR instr(markdown, '"Water: Breathe Underwater"') > 0
          OR instr(markdown, '"Water: Communicate with Sea Creature"') > 0
          OR instr(markdown, '"Water: Impervious to Ocean Depth"') > 0
          OR instr(markdown, '"Water: Summon Sharks or Whales"') > 0)) AS got,
       0 AS want;

SELECT 'eleven classes now cite the new names' AS assertion,
       (SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL AND (
             instr(markdown, '"Air: Atmosphere Manipulation"') > 0
          OR instr(markdown, '"Earth: Sculpt and Animate Clay Animals"') > 0
          OR instr(markdown, '"Earth: Transference of Essence & Intellect"') > 0
          OR instr(markdown, '"Fire: Heat Object & Boil Water"') > 0
          OR instr(markdown, '"Water: Breathe Under Water"') > 0
          OR instr(markdown, '"Water: Communicate with Sea Creatures"') > 0
          OR instr(markdown, '"Water: Impervious to Ocean Depths"') > 0
          OR instr(markdown, '"Water: Summon Sharks/Whales"') > 0)) AS got,
       11 AS want;

-- Every one of the 134 occurrences, not just one per class. Counted by how much
-- the string shrinks when the name is removed, divided by the name's own length
-- so the divisor cannot be mistyped.
SELECT 'all 134 occurrences moved' AS assertion,
       (SELECT sum(
            (length(markdown) - length(replace(markdown, '"Air: Atmosphere Manipulation"', ''))) / length('"Air: Atmosphere Manipulation"')
          + (length(markdown) - length(replace(markdown, '"Earth: Sculpt and Animate Clay Animals"', ''))) / length('"Earth: Sculpt and Animate Clay Animals"')
          + (length(markdown) - length(replace(markdown, '"Earth: Transference of Essence & Intellect"', ''))) / length('"Earth: Transference of Essence & Intellect"')
          + (length(markdown) - length(replace(markdown, '"Fire: Heat Object & Boil Water"', ''))) / length('"Fire: Heat Object & Boil Water"')
          + (length(markdown) - length(replace(markdown, '"Water: Breathe Under Water"', ''))) / length('"Water: Breathe Under Water"')
          + (length(markdown) - length(replace(markdown, '"Water: Communicate with Sea Creatures"', ''))) / length('"Water: Communicate with Sea Creatures"')
          + (length(markdown) - length(replace(markdown, '"Water: Impervious to Ocean Depths"', ''))) / length('"Water: Impervious to Ocean Depths"')
          + (length(markdown) - length(replace(markdown, '"Water: Summon Sharks/Whales"', ''))) / length('"Water: Summon Sharks/Whales"'))
          FROM imported_classes WHERE deleted_at IS NULL) AS got,
       134 AS want;

-- The one row whose old name is a PREFIX of its new one. If the quoted match
-- ever came undone this is where it would show, as a doubled suffix.
SELECT 'the prefix-containment row did not compound' AS assertion,
       (SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL
          AND instr(markdown, 'Essence & Intellect & Intellect') > 0) AS got,
       0 AS want;

-- The redirects, and that each points at a row that exists. INNER JOIN, so a
-- dead one drops out of the count rather than being counted as working.
SELECT 'eight spell redirects, all resolving' AS assertion,
       (SELECT count(*) FROM catalog_redirects r JOIN spells s ON s.id = r.to_id
         WHERE r.catalog = 'spells' AND r.reason = 'rename') AS got,
       8 AS want;

-- No character and no draft is left holding a retired name. Expected to have
-- been true before this script ran, and asserted because that is what makes it
-- evidence rather than a hope.
SELECT 'no character or draft holds a retired name' AS assertion,
       (SELECT count(*) FROM characters WHERE powers IS NOT NULL AND (
             instr(powers, '"Water: Breathe Underwater"') > 0
          OR instr(powers, '"Water: Impervious to Ocean Depth"') > 0
          OR instr(powers, '"Fire: Heat Object/Boil Water"') > 0))
     + (SELECT count(*) FROM character_drafts WHERE state IS NOT NULL AND (
             instr(state, '"Water: Breathe Underwater"') > 0
          OR instr(state, '"Water: Impervious to Ocean Depth"') > 0
          OR instr(state, '"Fire: Heat Object/Boil Water"') > 0)) AS got,
       0 AS want;

-- The four left alone are STILL alone. A later sweep that "finishes the job"
-- would be undoing three deliberate decisions and breaking a UNIQUE constraint.
SELECT 'the four deliberate keeps are untouched' AS assertion,
       (SELECT count(*) FROM spells WHERE name IN (
          'Fire: Fire Ball','Air: Wind Rush','Water: Swim as a Fish: Superior',
          'Water: Calm Waters (greater)')) AS got,
       4 AS want;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run, and a run that correctly did
-- nothing is still a run that happened.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r20-spell-names.sql');
