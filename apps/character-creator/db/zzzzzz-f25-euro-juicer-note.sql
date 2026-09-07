-- BOOK-INGEST-AUDIT.md F25 was taken; the one class note that cites it now
-- describes a state that has changed.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-f25-euro-juicer-note.sql
--
-- `node scripts/audit-citations.mjs --remote F25` returns exactly one class,
-- euro-juicer, and its note said "SO THIS ROW WILL DRIFT FROM THE JUICER AND
-- NOTHING WILL SAY SO... no field records that the two are meant to be
-- identical." A field does now, and a check reads it.
--
-- The half that is still TRUE is kept, deliberately: nothing composes one class
-- from another, so a correction to the Juicer still has to be made twice by
-- hand. What changed is that forgetting is caught rather than silent. A note
-- that overclaims a fix is worse than one that claims nothing.
--
-- The rewrite also states the LIMIT of the new cover - this pair excepts
-- `skills`, so a divergence inside the skills block is not caught for it,
-- which is the very shape the Ley Line Rifter's missing category bonuses took.
-- Recording the gap beside the reassurance is the point.
--
-- Sorts after zzzzzz-f25-copy-of-declarations.sql, which adds the copy_of line
-- this note now refers to. Guarded on the text it replaces and keyed on
-- class_id.

UPDATE imported_classes
   SET markdown = replace(markdown, '  - SO THIS ROW WILL DRIFT FROM THE JUICER AND NOTHING WILL SAY SO. A' || char(10) || '    correction to the Juicer - an edition update, a bonus fix, a renamed gear' || char(10) || '    slug - does not reach this class, and no field records that the two are' || char(10) || '    meant to be identical. Filed as BOOK-INGEST-AUDIT.md F25. Anyone correcting' || char(10) || '    `juicer` should grep for `euro-juicer` in the same pass.', '  - THIS ROW CAN STILL DRIFT FROM THE JUICER, AND SOMETHING NOW SAYS SO. A' || char(10) || '    correction to the Juicer does not reach this class - nothing composes one' || char(10) || '    class from another here - so anyone correcting `juicer` should still make' || char(10) || '    the same change on `euro-juicer`. What changed is that forgetting is now' || char(10) || '    caught rather than silent: this row declares' || char(10) || '    `copy_of: { class: "juicer", except: [...] }`, and test/regression.mjs' || char(10) || '    asserts the two still match outside that list, against a database rebuilt' || char(10) || '    from the repo. BOOK-INGEST-AUDIT.md F25, taken 2026-09-07.' || char(10) || '    THE EXCEPT LIST IS THE LIMIT OF THAT COVER, and it is worth knowing rather' || char(10) || '    than assuming: this pair excepts `skills`, because the two language entries' || char(10) || '    below differ by design, so a divergence INSIDE the skills block is not' || char(10) || '    caught for this class. It also excepts `restrictions` and' || char(10) || '    `race_restrictions` for the same reason. Pools, bonuses, equipment,' || char(10) || '    abilities, money and grouping are compared.')
 WHERE class_id = 'euro-juicer'
   AND instr(markdown, 'AND NOTHING WILL SAY SO') > 0;

-- Read the result back rather than trusting the exit code.
SELECT 'the note records that a check now reads the declaration' AS assertion,
       instr(markdown, 'asserts the two still match outside that list') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'euro-juicer';

SELECT 'and the superseded claim is gone' AS assertion,
       instr(markdown, 'AND NOTHING WILL SAY SO') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'euro-juicer';

SELECT 'the row still declares its copy_of' AS assertion,
       instr(markdown, 'copy_of: { class: "juicer"') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'euro-juicer';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-f25-euro-juicer-note.sql');
