-- The five spells missing their Palladium Fantasy P.P.E. variant
-- (REBUILD-AUDIT.md F20, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-spell-variant-notes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-spell-variant-notes.sql
--
-- WHAT HAPPENED. The same gap operations.md describes under "What a data script
-- cannot recover": these five rows exist in the repo, so no `restore-*.sql`
-- brings them back - `INSERT OR IGNORE` recovers a row that was ABSENT, never
-- one that was present and got ENRICHED. The variant was typed into the catalog
-- editor, which writes straight to D1 and leaves nothing in git, so a database
-- built from this repo serves each of these five with no Palladium Fantasy
-- P.P.E. cost at all.
--
-- Rifts and Palladium Fantasy share a multiverse and a spell list; the same
-- spell is often printed at a different P.P.E. cost in each. `variant_note` is
-- where the second figure lives - see migration 033.
--
-- The five, and the whole of the difference: production holds the note and a
-- rebuild holds NULL. Nothing here runs the other way, no citation is in
-- dispute, and no book had to be opened - which is what made this the smallest
-- finding in the audit and the only fully mechanical one left.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after retag-pf-spells-both.sql,
-- which moves 57 spells between systems, and after the zzzz-cite-* files, which
-- rewrite `source_book` on spell rows. `zzzz-restore-sp` sorts after
-- `zzzz-restore-sk`.
--
-- Every statement targets one name and sets an absolute value, so it is safe to
-- re-run and safe to run early: on production every value below is already the
-- value in the row, which is why applying it there changes nothing.

UPDATE spells SET variant_note = 'Palladium Fantasy: 6 P.P.E.'
  WHERE name = 'Impervious to Fire';

UPDATE spells SET variant_note = 'Palladium Fantasy: 3 P.P.E.'
  WHERE name = 'Resist Fire';

UPDATE spells SET variant_note = 'Palladium Fantasy: 8 P.P.E.'
  WHERE name = 'Blind';

UPDATE spells SET variant_note = 'Palladium Fantasy: 10 P.P.E.'
  WHERE name = 'Fire Bolt';

UPDATE spells SET variant_note = 'Palladium Fantasy: 15 P.P.E.'
  WHERE name = 'Energy Disruption';

-- Reads the result back rather than trusting the exit code.
--   spells_with_a_pf_variant  14 = production's own figure. A rebuild had 9,
--                              and these five are the whole of the difference.
--   the_five                   5 = all five now carry a note, counted by name
--                              rather than inferred from the total, so a
--                              coincidence elsewhere in the table cannot make
--                              this read right while one of them is still NULL.
SELECT (SELECT count(*) FROM spells WHERE instr(variant_note, 'Palladium Fantasy:') > 0) AS spells_with_a_pf_variant,
       (SELECT count(*) FROM spells
         WHERE name IN ('Impervious to Fire', 'Resist Fire', 'Blind', 'Fire Bolt', 'Energy Disruption')
           AND instr(variant_note, 'Palladium Fantasy:') > 0) AS the_five;

-- Records this run. One row per run rather than per file: the statements above
-- set absolute values, so this script is safe to re-run, and a run that
-- correctly changed nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-spell-variant-notes.sql');
