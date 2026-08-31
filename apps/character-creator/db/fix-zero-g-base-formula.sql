-- Give the one attribute-derived skill its formula.
--
-- BOOK-INGEST-AUDIT.md F2, taken in PR #427. Migration 042 adds
-- `skills.base_formula`; this fills it for the row that filed the finding.
--
-- Phase World printed 150 states Zero Gravity Movement & Combat as the
-- character's P.P. attribute number x5%, plus 4% per level. `per_level` already
-- holds the 4. `base` held 0, which the schema comment defines as
-- "non-percentile (W.P.s, hand to hand)" - so a skill the book starts near 50%
-- for a typical P.P. was stored as though it had no percentage at all.
--
-- `base` IS LEFT AT 0 DELIBERATELY. It is the fallback for a character whose
-- P.P. cannot be read, and leaving it there keeps the change to one column.
-- Writing a representative number into it would be a second, quieter claim
-- about the same skill.
--
-- The note is rewritten: it carried the formula as prose precisely because
-- nothing could read it, and that sentence is now false. It keeps the sentence
-- a player needs - what the skill does and what a character without it suffers.
--
-- This is the only skill in the catalog with an attribute-derived base, checked
-- rather than assumed: 64 rows sit at base 0 and every other one is a genuine
-- non-percentile skill or is marked "Special".

UPDATE skills
SET base_formula = 'PP*5',
    note = 'Printed as Zero Gravity Movement & Combat, under Physical Skills; '
        || 'stored with the catalog''s Space: prefix. The base is the character''s '
        || 'P.P. attribute number x5%, held in base_formula as PP*5, plus 4% per '
        || 'level. Moving in zero gravity without penalty except speed, which is '
        || 'reduced by 20%. A character WITHOUT this skill is at -15% on skill '
        || 'performance, -1 attack per melee, -2 on initiative, half combat '
        || 'bonuses and half speed.'
WHERE name = 'Space: Zero Gravity Movement & Combat'
  AND base_formula IS NULL;

-- Readback: the formula is set, the fallback base is untouched, the per-level
-- step is untouched, and the stale sentence about the app being unable to hold
-- a formula is gone.
SELECT name, base, base_formula, per_level,
       instr(note, 'cannot hold a formula') AS stale_claim_gone,
       instr(note, 'base_formula as PP*5') > 0 AS formula_documented
FROM skills
WHERE name = 'Space: Zero Gravity Movement & Combat';

INSERT INTO data_script_runs (filename) VALUES ('fix-zero-g-base-formula.sql');
