-- The Godling's extraction note still says the skill-category bonuses cannot be
-- expressed. They have been expressed since fix-godling-demigod-accuracy.sql.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-godling-skill-category-bonuses-note.sql
--
-- CLASS-AUDIT.md S4. That earlier script's F3 put all five bonuses into the
-- data - Domestic +10, Medical +10, Technical +10, Wilderness +5 and
-- Horsemanship +15 - after a preceding PR taught a related-skill category to
-- carry a `bonus` at all. What it did not do was rewrite the paragraph in
-- `extraction_notes` explaining why those five bonuses were dropped. So the
-- class now carries the bonuses AND a note swearing it does not, which is worse
-- than either alone: the data is right and the only prose about it is wrong, so
-- the next person to read the class detail page is told a limitation exists and
-- has no reason to check.
--
-- This is the shape the claim-audit rule exists to prevent - a note about a
-- limitation outliving the limitation - and the reason the audit files a note
-- rewrite as its own item rather than trusting it to ride along with the fix.
--
-- ONE STATEMENT, NO DATA CHANGE. The five bonuses are already correct and are
-- not touched. Only the paragraph moves.
--
-- Guarded on the old text, so re-running is a no-op once it is gone. The
-- paragraph is matched in two halves because the old text wraps mid-phrase
-- ("have nowhere to" / newline / "go in the format"), which is exactly what
-- made it survive a grep for its own sentence.

UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  Two smaller notes: the book prints ' || char(34) || '(+15% for Horsemanship)' || char(34) || ' inside the Pilot' || char(10) ||
         '  category line, but Horsemanship is its own skill category here, so it is' || char(10) ||
         '  offered as a category without the bonus. And per-category percentage bonuses' || char(10) ||
         '  (Domestic +10%, Medical +10%, Technical +10%, Wilderness +5%) have nowhere to' || char(10) ||
         '  go in the format and are not applied.',
         '  One smaller note, about where the book puts a bonus rather than about' || char(10) ||
         '  what the format can hold: p.17 prints ' || char(34) || '(+15% for Horsemanship)' || char(34) || ' inside the' || char(10) ||
         '  Pilot category line, but this catalog files Horsemanship skills under their' || char(10) ||
         '  own category, which this class also grants. The +15% is carried on that' || char(10) ||
         '  category and Pilot itself keeps none - reading it as a Pilot bonus would' || char(10) ||
         '  hand fifteen points to every aircraft and hovercycle skill the book never' || char(10) ||
         '  mentions. All five category percentages (Domestic +10%, Medical +10%,' || char(10) ||
         '  Technical +10%, Wilderness +5%, Horsemanship +15%) are applied as category' || char(10) ||
         '  bonuses.')
 WHERE class_id = 'godling'
   AND instr(markdown, 'go in the format and are not applied.') > 0;

-- Readback. The first must be 0 and the second 1; the third proves this script
-- changed no data, since all five bonuses were already there and stay there.
SELECT instr(markdown, 'have nowhere to')                                          AS stale_note_gone,
       (instr(markdown, 'are applied as category' || char(10) || '  bonuses.') > 0) AS new_note_present,
       (instr(markdown, char(34) || 'Domestic' || char(34) || ', bonus: 10') > 0)
     + (instr(markdown, 'M.D. in Cybernetics' || char(34) || '], bonus: 10') > 0)
     + (instr(markdown, char(34) || 'Technical' || char(34) || ', bonus: 10') > 0)
     + (instr(markdown, char(34) || 'Horsemanship' || char(34) || ', bonus: 15') > 0)
     + (instr(markdown, char(34) || 'Wilderness' || char(34) || ', bonus: 5') > 0)  AS bonuses_still_five
  FROM imported_classes WHERE class_id = 'godling';

-- Records this run. The statement above guards itself, so this is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-godling-skill-category-bonuses-note.sql');
