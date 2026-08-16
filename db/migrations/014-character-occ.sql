-- 014 — the O.C.C. a character takes alongside its R.C.C.
--
-- Palladium characters routinely have both: a Chiang-Ku Dragon who studies
-- wizardry is a dragon AND a wizard, and the two contribute different halves.
-- The race sets the body — attribute dice, hit points, M.D.C. The occupation
-- sets what was learned: its own skills, the related and secondary allowances,
-- equipment, and its own bonuses.
--
-- Until now a character had one class_id, so the O.C.C. half had nowhere to
-- live and its related/secondary skills simply did not exist. That read as a
-- missing feature in every racial class in the catalog.
--
-- A second column pair rather than a JSON array of classes: it keeps the
-- question "which one is the race?" explicit, stays queryable, and every
-- existing reader of class_id keeps working. Two classes is what the books
-- describe; a third has no meaning to add.
ALTER TABLE characters ADD COLUMN occ_class_id TEXT;
ALTER TABLE characters ADD COLUMN occ_class_variant TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('014-character-occ.sql');
