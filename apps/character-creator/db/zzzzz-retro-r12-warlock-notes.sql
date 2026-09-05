-- RETRO-AUDIT R12: the ten per-Force Warlocks stop describing the class they
-- replaced.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r12-warlock-notes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r12-warlock-notes.sql
--
-- WHAT WAS WRONG, AND IT WAS THIS MENU'S OWN DOING. RETRO-AUDIT R3 (PR #723)
-- generated the ten per-Force Warlocks from the generic one and copied its
-- extraction_notes and restrictions verbatim. Three passages were true of the
-- class being replaced and false of all ten replacing it, from the moment they
-- shipped:
--
--   1. "The ELEMENT choice itself is per-character and has no schema shape: a
--      class is static" - the element IS the class now. There are ten of them.
--   2. "a first-level Warlock is offered all 50 level-1 spells in the catalog
--      ... magic.spells_from could narrow that to the 37 level-1 ELEMENTAL
--      spells, but not to the 9 a Fire Warlock should see, because no field
--      records which Force was chosen" - every one of these classes carries
--      exactly its own sphere's list, which is the whole point of them.
--   3. "the variant records HOW MANY, not which ... the variants are one-force
--      and two-forces, so a Fire Warlock and an Air Warlock are the same class
--      and variant here" - the variants block was REMOVED when these were
--      generated; the one-Force and two-Force cases are separate classes.
--
-- This is the shape R1 and R10 were about - a record telling the next reader
-- not to try - committed on ten classes at once, hours after filing R1.
--
-- retro-check.mjs did NOT catch it. Its magic.spells_from pair looks for
-- "record picks by hand" and "not yet in the spell catalog"; none of the three
-- passages uses that wording. That is the hand-maintained-list cost R8 named as
-- its own ongoing risk, arriving on schedule.
--
-- ALL TEN CARRY THESE PASSAGES BYTE-IDENTICALLY - they were generated from one
-- source - so each replacement is written once and matched on class_id LIKE
-- 'warlock-%'. Verified identical before writing.
--
-- The replacements have to be true of BOTH shapes, because one statement covers
-- a one-Force class and a two-Force one. They say "this class's Force or pair"
-- rather than naming a sphere.

-- ---- 1 + 2: the two extraction_notes bullets ------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  - The ELEMENT choice itself is per-character and has no schema shape: a
    class is static, and the wizard''s spell picker filters by level, not by
    sphere. Because the catalog names elemental spells with their sphere
    ("Fire: Fire Bolt"), typing the sphere into the picker''s filter box
    narrows it correctly - that is the intended workflow and it is stated
    here rather than left to be discovered.
  - WHAT THE PICKER DOES NOT STOP, recorded by RETRO-AUDIT R3 (2026-09-04):
    the summary says "A warlock cannot learn spell magic of any other kind",
    and nothing enforces it. spell_levels_allowed [1] gates by LEVEL only, so
    a first-level Warlock is offered all 50 level-1 spells in the catalog,
    including wizard magic the class may never learn. magic.spells_from could
    narrow that to the 37 level-1 ELEMENTAL spells, but not to the 9 a Fire
    Warlock should see, because no field records which Force was chosen. The
    route that works is per-Force classes, the way the Elemental Fusionists
    are split into two - an import decision, not a transcription.',
'  - THE ELEMENT IS THIS CLASS. There are ten Warlock classes, one per Elemental
    Force and one per pair, and which one a character takes IS the choice the
    book makes permanent. Until RETRO-AUDIT R12 (2026-09-04) these ten carried
    the generic class''s note saying the element "is per-character and has no
    schema shape" - true of the single class they replaced, false of them from
    the moment they shipped.
  - THE PICKER IS BOUNDED BY THE SPHERE. magic.spells_from carries this class''s
    own Force (or one list per Force in a pair), so "A warlock cannot learn
    spell magic of any other kind" is enforced rather than merely stated. The
    note here used to say a first-level Warlock is offered all 50 level-1
    spells in the catalog; that was the generic class, and it is why these ten
    exist. The lists are bounded by SPELL LEVEL as well as by sphere, one
    cumulative list per level, because a named list replaces the level cap
    rather than combining with it.')
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'The ELEMENT choice itself is per-character') > 0;

-- ---- 3: the restriction that describes a variants block that is gone ------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'Choose ONE or TWO Elemental Forces at creation (Air, Earth, Fire or Water) - the variant records HOW MANY, not which, and the choice is permanent. There is no field for the Force itself: the variants are one-force and two-forces, so a Fire Warlock and an Air Warlock are the same class and variant here, and the element lives on the player''s own record. RETRO-AUDIT R3, 2026-09-04.',
       'The Force is chosen at creation (Air, Earth, Fire or Water, one or two of them) and the choice is permanent - and THIS CLASS IS THAT CHOICE. Until RETRO-AUDIT R12 (2026-09-04) this sentence said the variant recorded how many and not which, and that a Fire Warlock and an Air Warlock were the same class; that described the generic Warlock these ten replaced, which no longer exists. There is no variants block here.')
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'the variant records HOW MANY') > 0;

-- ---- 4: the extraction note about carrying the split as VARIANTS ----------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  - The one-Force / two-Force split is carried as VARIANTS because the only
    differences the schema can hold are attribute_requirements and ppe_base,
    both of which VARIANT_OVERRIDES allows.',
'  - The one-Force / two-Force split is carried as SEPARATE CLASSES since
    RETRO-AUDIT R3, not as variants. It was variants while there was one
    Warlock, because attribute_requirements and ppe_base were the only
    differences VARIANT_OVERRIDES allows - and the spells-per-level difference
    is not a variant key, which is why the split had to become classes.')
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'The one-Force / two-Force split is carried as VARIANTS') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'all ten now say the element IS the class' AS assertion,
       count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'THE ELEMENT IS THIS CLASS') > 0
   AND instr(markdown, 'THE PICKER IS BOUNDED BY THE SPHERE') > 0;

SELECT 'no Warlock still describes the class it replaced' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND (instr(markdown, 'The ELEMENT choice itself is per-character') > 0
     OR instr(markdown, 'the variant records HOW MANY') > 0
     OR instr(markdown, 'The one-Force / two-Force split is carried as VARIANTS') > 0
     OR instr(markdown, 'offered all 50 level-1 spells') > 0);

-- The MECHANICS are untouched: this is prose only. Each class still carries its
-- own sphere list, its own starting count and its own requirements.
SELECT 'the four one-Force classes still start with three' AS assertion,
       count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('warlock-air', 'warlock-earth', 'warlock-fire', 'warlock-water')
   AND deleted_at IS NULL
   AND instr(markdown, 'spells_starting: 3') > 0
   AND instr(markdown, 'attribute_requirements: { IQ: 6, ME: 10 }') > 0;

SELECT 'the six two-Force classes still start with two' AS assertion,
       count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE class_id LIKE 'warlock-%-%' AND deleted_at IS NULL
   AND instr(markdown, 'spells_starting: 2') > 0
   AND instr(markdown, 'attribute_requirements: { IQ: 12, ME: 14 }') > 0;

SELECT 'every Warlock still carries its sphere lists and its floor' AS assertion,
       count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'spell_lists:') > 0
   AND instr(markdown, 'minimums:') > 0;

-- Records this run. Every statement guards itself, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r12-warlock-notes.sql');
