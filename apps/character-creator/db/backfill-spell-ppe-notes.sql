-- Cost schedule for the one spell the RUE chapter import left at ppe 0,
-- using the ppe_note column migration 021 added.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires 021-spell-ppe-note.sql first.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/backfill-spell-ppe-notes.sql
--
-- Same convention as the psionic backfill: `ppe` holds the MINIMUM (the
-- sheet's use button deducts it) and `ppe_note` says the schedule in a few
-- words; the full wording stays in the description. The minimum and schedule
-- were read from the spell's own entry on the imported pages.
--
-- Guarded on the state it expects, so a hand-corrected row is never
-- overwritten and re-running is harmless.
UPDATE spells SET ppe = 2, ppe_note = '2 per 5 lbs'
 WHERE name = 'Manipulate Objects' AND ppe = 0 AND ppe_note IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT name, ppe, ppe_note FROM spells WHERE ppe_note IS NOT NULL ORDER BY name;
SELECT count(*) AS costless_spells FROM spells WHERE ppe = 0 AND ppe_note IS NULL;
