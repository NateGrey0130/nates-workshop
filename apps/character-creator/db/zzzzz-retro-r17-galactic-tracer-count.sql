-- RETRO-AUDIT R17: the seventh site, and the only one that is live data.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r17-galactic-tracer-count.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r17-galactic-tracer-count.sql
--
-- R17 listed six places saying how many classes hold a related-skill floor, all
-- of them in the repo. The seventh is in PRODUCTION, in a class's own
-- extraction_notes, and R17's sweep missed it because it states a different
-- wrong number - eleven, not eight - so a grep for the six did not reach it.
--
-- galactic-tracer's note reads:
--
--   "THE TWO-FROM-ESPIONAGE FLOOR IS ENFORCED, in `minimums`. The book requires
--    at least two of the seven related picks from Espionage. Filed as F6 in the
--    Empire batch; taken across all eleven classes in three books that print a
--    floor like this."
--
-- Stale twice over: THIRTY classes across FIVE books hold a floor as of
-- 2026-09-05, derived by PARSING every published class rather than by matching
-- on `minimums:`, which also matches `attribute_minimums:` on fifteen of them.
--
-- WHY THE SENTENCE LOSES ITS NUMBERS RATHER THAN GAINING RIGHT ONES. This is
-- the surface `audit-menu` step 5 exists for: a class note does two jobs, and
-- "what the book prints" is permanent while "how many classes the app had done
-- this to on the day of the import" is not. The first half of the note is the
-- book and stays; the tally is dropped, on SKILL-AUDIT F7's grounds that
-- correcting an ordinal leaves the same trap armed. Nate chose that over
-- updating the figure.
--
-- The floor itself is untouched and a readback asserts it.
--
-- fix-related-skill-minimums.sql:213 WROTE THIS SENTENCE and line 1 of that
-- file carries the same tally in a `--` comment. A one-shot script is not
-- edited and a comment is not data, so this file is the correction of record
-- and sorts after it.

-- THE STORED TEXT IS WRAPPED. It sits in a YAML bullet with four-space
-- continuation indents, so the match and the replacement both carry real
-- newlines; a single-line match finds nothing and silently does nothing, which
-- is what the first version of this script did.
UPDATE imported_classes
   SET markdown = replace(markdown,
'Filed as F6 in the
    Empire batch; taken across all eleven classes in three books that print a
    floor like this.',
'Filed as F6 in the
    Empire batch, and taken across every class whose book prints a floor like
    this. NO TALLY IS GIVEN HERE ON PURPOSE: this note carried one, it was
    wrong within days, and nothing pins it. Derive it if you need it - parse
    each class and count a non-empty occ_related_skills.minimums, never by
    matching the text minimums: which also matches attribute_minimums:.
    RETRO-AUDIT R17, 2026-09-05.')
 WHERE class_id = 'galactic-tracer' AND deleted_at IS NULL;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the galactic-tracer tally is gone' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND instr(markdown, 'eleven classes in three books') > 0;

SELECT 'and the replacement landed on the class it was meant for' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'galactic-tracer' AND deleted_at IS NULL
   AND instr(markdown, 'NO TALLY IS GIVEN HERE ON PURPOSE') > 0;

-- THE FLOOR ITSELF IS UNTOUCHED. This is prose only.
SELECT 'the galactic-tracer still holds its Espionage floor' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'galactic-tracer' AND deleted_at IS NULL
   AND instr(markdown, 'count: 2, category: "Espionage"') > 0;

-- AND NO OTHER CLASS CARRIES A TALLY OF ITS OWN. Swept for the other shapes a
-- count takes in this prose before this script was written; this asserts the
-- sweep stays true. `%` is not used - instr() only, because LIKE treats _ as a
-- single-character wildcard and the smoke test refuses the pattern.
SELECT 'no class prose still counts the floor-holding classes' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (instr(markdown, 'eleven classes') > 0
     OR instr(markdown, 'eight classes') > 0
     OR instr(markdown, 'across four books') > 0
     OR instr(markdown, 'across three books') > 0);

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r17-galactic-tracer-count.sql');
