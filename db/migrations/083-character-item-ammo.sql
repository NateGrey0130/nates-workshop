-- 083: character_items.ammo_current - how many rounds a carried weapon has
-- left, as a number of its own.
--
-- Play mode kept the count in the row's NOTES as "ammo 7/10": no schema change,
-- visible, editable by hand. It cost two things. A shot was a rewrite of the
-- whole notes string, so a shot fired offline and replayed later overwrote
-- anything typed into that row's notes in between; and the count could not be
-- guarded on replay the way a pool is, because a string has no "from" to
-- compare that means anything.
--
-- NULL means FULL - the magazine size is the gear row's payload, which is
-- catalog data and stays there. A weapon nobody has fired has nothing stored.
--
-- Production held no "ammo N/M" note on any inventory row when this was
-- written (2026-09-24, --remote: 0 of 44 rows, and 0 'ammo' play events), so
-- there is nothing to backfill and no data script goes with it.
ALTER TABLE character_items ADD COLUMN ammo_current INTEGER;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('083-character-item-ammo.sql');
