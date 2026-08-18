-- A cost schedule for psionic powers whose I.S.P. is not one number.
--
-- Mind Bolt costs more for more damage; Mind Wipe costs more for a longer
-- span. The `isp` column is live, not decorative - the sheet's "use" button
-- deducts it from the character's current I.S.P. - so a flat number spends
-- the wrong amount and a zero spends nothing while reading as free (and
-- matching the import stub heuristic, source = 'import' AND isp = 0).
--
-- The convention after this migration: `isp` holds the MINIMUM cost, and a
-- non-null `isp_note` carries the schedule in a few words. The use button
-- keeps deducting the minimum, which is the right table behaviour - the G.M.
-- adjusts the pool by hand for bigger spends, exactly as at a real table.
ALTER TABLE psionic_powers ADD COLUMN isp_note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('020-psionic-isp-note.sql');
