-- The <Class Name> O.C.C., <Source Book> p.NN-NN.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-<id>-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated with scripts/class-check.mjs before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- catalog references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


-- Stub rows for anything the class references that the catalog lacks.
-- Paste the block scripts/class-check.mjs prints; do not hand-write these.
-- The "STUB" marker is load-bearing: it is how the gear importer later
-- recognises a row as still needing stats.
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('<slug>', '<Name>', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', '<Source Book>');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled. The whole file must be pure
-- ASCII with LF line endings.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT '<id>', '<Name>', 'rifts', '---
id: <id>
name: <Name>
system: rifts
source_book: <Source Book> p.NN-NN
category: occ

<... the rest of the frontmatter ...>
---

## Lore

<Who they are, in the book''s voice.>

## GM Notes

<What the GM should know and the player should not.>
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = '<id>');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = '<id>';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('<slug>');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file. One row per run rather than
-- per file, because every statement above guards itself and a script that ran
-- early and correctly did nothing has still run.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('<this-file>.sql');
