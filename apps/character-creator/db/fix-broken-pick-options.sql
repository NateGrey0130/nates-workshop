-- Four choice options resolve to no catalog row, so the pick fails (class
-- audit F11, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-broken-pick-options.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-broken-pick-options.sql
--
-- Pick resolution is case-insensitive but otherwise exact (no redirects); a
-- name with no row errors with 'No skill called "X" in the catalog'. Catalog
-- spellings confirmed over --remote:
--
--   body-fixer     "Athletics (General)" -> "Athletics (general)" (case-only;
--                  works at runtime, but D1's case-sensitive Confirm creates
--                  a duplicate stub on re-import) and "Body Building" ->
--                  "Body Building & Weight Lifting" (real miss).
--   vagabond       "General Repair" -> "General Repair & Maintenance". The
--                  choice's note keeps the book's "+10% / +5%" phrasing -
--                  the entry does not apply the split bonuses, and the note
--                  says so; not this finding's to change.
--   rogue-scholar  "Pilot: Hover Vehicle" -> "Hover Craft (ground)" (a
--                  redirect exists but picks do not consult redirects);
--                  "Automobile" is a real row and stays. Same class: the
--                  related-skill entry named a SKILL as its category
--                  ("Horsemanship: General"), matching nothing, so the class
--                  offered no horsemanship at all.
--
-- Filename sort: fix-broken-pick-options > the add-*-class.sql scripts that
-- wrote all four lines; nothing later rewrites them.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["Athletics (General)", "Body Building"]',
      'from: ["Athletics (general)", "Body Building & Weight Lifting"]'),
    updated_at = datetime('now')
WHERE class_id = 'body-fixer'
  AND instr(markdown, 'from: ["Athletics (General)", "Body Building"]') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["General Repair", "Horsemanship: General"]',
      'from: ["General Repair & Maintenance", "Horsemanship: General"]'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond'
  AND instr(markdown, 'from: ["General Repair", "Horsemanship: General"]') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["Automobile", "Pilot: Hover Vehicle"]',
      'from: ["Automobile", "Hover Craft (ground)"]'),
    updated_at = datetime('now')
WHERE class_id = 'rogue-scholar'
  AND instr(markdown, 'from: ["Automobile", "Pilot: Hover Vehicle"]') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '- { name: "Horsemanship: General", only: ["Horsemanship: General"] }',
      '- { name: "Horsemanship", only: ["Horsemanship: General"] }'),
    updated_at = datetime('now')
WHERE class_id = 'rogue-scholar'
  AND instr(markdown, '- { name: "Horsemanship: General", only: ["Horsemanship: General"] }') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        3 = each class carries its corrected option(s)
--   old_left     0 = no unresolvable name left in a from: list
--   cr_free      3 = all three touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'vagabond', 'rogue-scholar')
            AND (instr(markdown, 'from: ["Athletics (general)", "Body Building & Weight Lifting"]') > 0
              OR instr(markdown, 'from: ["General Repair & Maintenance", "Horsemanship: General"]') > 0
              OR instr(markdown, 'from: ["Automobile", "Hover Craft (ground)"]') > 0)) AS fixed,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'vagabond', 'rogue-scholar')
            AND (instr(markdown, '"Body Building"]') > 0
              OR instr(markdown, '"General Repair",') > 0
              OR instr(markdown, '"Pilot: Hover Vehicle"') > 0
              OR instr(markdown, '"Horsemanship: General", only:') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'vagabond', 'rogue-scholar')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-broken-pick-options.sql');
