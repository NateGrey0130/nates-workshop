-- The Juicer Uprising / RUE Gambling variance is recorded on the wrong skill,
-- and states the wrong number for the skill it is on.
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzz-fix-ju-gambling-notes.sql
--
-- WHAT THE BOOKS ACTUALLY PRINT. Both Gambling skills are defined twice, once
-- in each book, and only ONE of the two pairs disagrees:
--
--                            Juicer Uprising p.66     RUE p.302-303
--   Gambling (Standard)      30% +5%                  30%+5%     identical
--   Gambling (Dirty Tricks)  30% plus 4%              20%+4%     BASE DIFFERS
--
-- The catalog carries RUE's values for both, which is right - RUE is later, and
-- that is the rule add-juicer-uprising-skills.sql set. What is wrong is the
-- note: `Juicer Uprising p.66 lists 30%+4%` sits on Gambling (Standard), where
-- there is no disagreement to record, while Dirty Tricks - the row whose base
-- really does differ, 20 against 30 - carries no note at all.
--
-- HOW IT GOT IN, AND WHY IT IS WORTH SAYING. This is column-weld damage from
-- the ju cache, which was built with a raw page.get_text() until it was rebuilt
-- 2026-08-28 (INGESTION-AUDIT F2). On printed 66 the two Gambling entries run
-- down the left column while Dirty Tricks' own `Base Skill: 30% plus 4% per
-- level of experience.` sits in the RIGHT column, welded two thirds of a page
-- above its own entry beside unrelated Jump Bike text. Read linearly, a stray
-- 30%+4% appears near the Gambling block with nothing to attach it to, and it
-- attached to the wrong one of the two. The rebuilt cache puts the line back
-- under its own heading, which is the only reason this is visible now.
--
-- Neither figure is one a test could have caught: `note` is free text and
-- nothing cross-checks it against the book.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: both statements are guarded on the text they replace.

-- 1. Gambling (Standard) agrees with RUE exactly. There is nothing to note.
UPDATE skills
   SET note = NULL
 WHERE name = 'Gambling (Standard)'
   AND note = 'Juicer Uprising p.66 lists 30%+4%';

-- 2. Gambling (Dirty Tricks) is the row the variance belongs to. RUE's 20% is
--    kept as the value; the book's 30% is recorded so the disagreement stays
--    visible rather than lost.
UPDATE skills
   SET note = COALESCE(note || '; ', '') || 'Juicer Uprising p.66 lists 30%+4%; RUE p.302-303 gives 20%+4% and is kept as the value'
 WHERE name = 'Gambling (Dirty Tricks)'
   AND (note IS NULL OR note NOT LIKE '%Juicer Uprising%');

-- Read the result back rather than trusting the exit code.
SELECT name, base, per_level, COALESCE(note, '(none)') AS note
  FROM skills
 WHERE name IN ('Gambling (Standard)', 'Gambling (Dirty Tricks)')
 ORDER BY name;

-- Records this run. Every statement above guards itself, so this script is safe
-- to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-fix-ju-gambling-notes.sql');
