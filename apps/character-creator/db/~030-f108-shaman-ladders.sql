-- BOOK-INGEST-AUDIT F108: the Madhaven Mutant Shaman levels on its own chart.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~030-f108-shaman-ladders.sql
--
-- Rifts World Book 29 printed 79 gives the Mutant Shaman the "Gateway Knight &
-- Mutant Shaman" column, while every other Haven Mutant takes the "Haven
-- Mutant R.C.C." column. The Shaman is a `shaman` variant on each of the eight
-- Haven Mutants, and until F108 put `xp_table` on VARIANT_OVERRIDES
-- (js/parser.js) a variant could not carry a ladder, so a Shaman levelled on
-- the Haven Mutant chart. This writes the shared column into each variant,
-- copied from `gateway-knight`'s stored ladder, which is that same column.
--
-- The removal half of F108 stays prose on purpose: a variant still cannot take
-- a skill away (F31's union guarantee), so the Shaman's lost Secondary,
-- Piloting and modern W.P. skills and its prayers remain in the notes.
--
-- MECHANICS. Each class has exactly one `  - id: shaman` line (checked
-- --remote 2026-09-27); the ladder is inserted as the variant's next line,
-- guarded on no variant-indented xp_table line existing, so a re-run changes
-- nothing. The notes sentence that called the ladder prose is rewritten,
-- guarded on the old sentence. Keyed on class_id.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || '  - id: shaman' || char(10),
         char(10) || '  - id: shaman' || char(10) || '    xp_table: [0, 2351, 4701, 9401, 18801, 28001, 38001, 53001, 77001, 102001, 143001, 195201, 240401, 310601, 360801]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id IN ('beast-men', 'dyno-men', 'leopard-men', 'mantis-men', 'metal-morph', 'pseudo-men', 'quill-men', 'savage-lummox')
   AND deleted_at IS NULL
   AND instr(markdown, char(10) || '    xp_table:') = 0
   AND instr(markdown, char(10) || '  - id: shaman' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the removal of Secondary, Piloting and modern W.P. skills, the prayers and the Shaman XP ladder are prose only; see BOOK-INGEST-AUDIT.md F108.',
         'the removal of Secondary, Piloting and modern W.P. skills and the prayers are prose only (a variant cannot take a skill away). The Shaman XP ladder, the Gateway Knight & Mutant Shaman column of printed 79, was prose until BOOK-INGEST-AUDIT.md F108 made xp_table a variant key; ~030-f108-shaman-ladders.sql put it on the variant.'),
       updated_at = datetime('now')
 WHERE class_id IN ('beast-men', 'dyno-men', 'leopard-men', 'mantis-men', 'metal-morph', 'pseudo-men', 'quill-men', 'savage-lummox')
   AND deleted_at IS NULL
   AND instr(markdown, 'the prayers and the Shaman XP ladder are prose only; see BOOK-INGEST-AUDIT.md F108.') > 0;

SELECT 'shaman ladder on all eight' AS assertion, count(*) AS got, 8 AS want FROM imported_classes
 WHERE class_id IN ('beast-men', 'dyno-men', 'leopard-men', 'mantis-men', 'metal-morph', 'pseudo-men', 'quill-men', 'savage-lummox')
   AND deleted_at IS NULL
   AND instr(markdown, char(10) || '  - id: shaman' || char(10) || '    xp_table: [0, 2351, 4701, 9401, ') > 0
   AND instr(markdown, ', 360801]' || char(10)) > 0;
SELECT 'the base ladder is unchanged on all eight' AS assertion, count(*) AS got, 8 AS want FROM imported_classes
 WHERE class_id IN ('beast-men', 'dyno-men', 'leopard-men', 'mantis-men', 'metal-morph', 'pseudo-men', 'quill-men', 'savage-lummox')
   AND deleted_at IS NULL
   AND instr(markdown, char(10) || 'xp_table: [0, 2241, ') > 0;
SELECT 'no note still calls the ladder prose' AS assertion, count(*) AS got, 0 AS want FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'the prayers and the Shaman XP ladder are prose only') > 0;
SELECT 'the rewritten note is on all eight' AS assertion, count(*) AS got, 8 AS want FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'was prose until BOOK-INGEST-AUDIT.md F108 made xp_table a variant key') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~030-f108-shaman-ladders.sql');
