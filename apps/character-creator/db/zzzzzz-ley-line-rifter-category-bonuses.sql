-- The Ley Line Rifter's seven O.C.C. Related Skill category bonuses, which it
-- should have had all along and does not.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-ley-line-rifter-category-bonuses.sql
--
-- WHAT THE BOOK SAYS, read from the rue cache at the registry's +3 offset:
--   * cache p119 line 49 heads a block "Ley Line Walker O.C.C. Stats", and that
--     block - printed 116 - prints Domestic (+10%), Espionage: Intelligence
--     only (+5%), Medical: First Aid or Paramedic (+5%), Pilot: Any (+2%),
--     Pilot Related: Any (+2%), Science: Any (+10%), Technical: Any (+5%).
--   * cache p119 line 162 begins "Ley Line Rifter O.C.C.".
--   * cache p120 line 83 - printed 118 - says, in full:
--     "Ley Line Rifter Stats. Same as the Ley Line Walker."
-- So the Rifter's related-skill bonuses ARE the Walker's, by the book's own
-- sentence rather than by inference from a note.
--
-- WHAT THE ROW SAYS. The Rifter's own note already enumerates all seven with
-- the correct figures - "Category bonuses: Domestic +10%, Espionage +5%..." -
-- and its categories carry NONE of them. The values were transcribed and never
-- applied.
--
-- HOW IT HAPPENED, and it is the reason BOOK-INGEST-AUDIT.md F25 exists. When
-- the category "bonus" key landed, fix-pre-rue-class-audit.sql applied the seven
-- Walker; that script names cyber-knight, dragon-hatchling, glitter-boy and
-- ley-line-walker, and not the Rifter. The Rifter DID track the Walker through
-- the RETRO-AUDIT R15 minimums work - both rows carry the same two floors - so
-- this is one correction reaching one half of a declared copy pair, silently.
-- Nothing in the repo compares the two rows.
--
-- EFFECT ON PLAY: a Ley Line Rifter's related-skill picks have been short by up
-- to ten percentage points. Both rows carry count 7 and the same thirteen
-- categories, so nothing else about the block changes.
--
-- SORTS AFTER EVERY WRITER OF THIS REGION, checked against the directory rather
-- than assumed. Fifteen scripts touch ley-line-rifter; the latest-sorting are
-- zzzzz-retro-r11-ley-line-rifter.sql, zzzzz-retro-r14-related-floors.sql and
-- zzzzz-retro-r15-ley-line-floors.sql, all in the zzzzz- tier. This file is
-- zzzzzz-.
--
-- Every write is guarded on the text it replaces, so re-running is a no-op, and
-- is keyed on class_id, which is a slug and stable.

UPDATE imported_classes SET markdown = replace(markdown, '      - "Domestic"', '      - { name: "Domestic", bonus: 10 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - "Domestic"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - { name: "Espionage", only: ["Intelligence"] }', '      - { name: "Espionage", only: ["Intelligence"], bonus: 5 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence"] }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - { name: "Medical", only: ["First Aid", "Paramedic"] }', '      - { name: "Medical", only: ["First Aid", "Paramedic"], bonus: 5 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - { name: "Medical", only: ["First Aid", "Paramedic"] }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - "Pilot"', '      - { name: "Pilot", bonus: 2 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - "Pilot"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - "Pilot Related"', '      - { name: "Pilot Related", bonus: 2 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - "Pilot Related"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - "Science"', '      - { name: "Science", bonus: 10 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - "Science"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - "Technical"', '      - { name: "Technical", bonus: 5 }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '      - "Technical"') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Category bonuses: Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5%.', 'The category bonuses - Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5% - are now APPLIED rather than recorded here, the same as on the Walker.')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, 'Category bonuses: Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5%.') > 0;

-- Read the result back rather than trusting the exit code. Separate statements
-- rather than a compound SELECT: D1 caps a compound SELECT below six terms.
SELECT 'all seven category bonuses are applied' AS assertion,
       (instr(markdown, '{ name: "Domestic", bonus: 10 }') > 0)
     + (instr(markdown, '"Espionage", only: ["Intelligence"], bonus: 5') > 0)
     + (instr(markdown, '"Paramedic"], bonus: 5') > 0)
     + (instr(markdown, '{ name: "Pilot", bonus: 2 }') > 0)
     + (instr(markdown, '{ name: "Pilot Related", bonus: 2 }') > 0)
     + (instr(markdown, '{ name: "Science", bonus: 10 }') > 0)
     + (instr(markdown, '{ name: "Technical", bonus: 5 }') > 0) AS got,
       7 AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

SELECT 'no bare category string is left behind' AS assertion,
       instr(markdown, char(10) || '      - "Science"' || char(10)) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

SELECT 'the note no longer describes them as unapplied' AS assertion,
       instr(markdown, 'Category bonuses: Domestic') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ley-line-rifter-category-bonuses.sql');
