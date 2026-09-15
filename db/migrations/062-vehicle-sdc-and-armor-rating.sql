-- A vehicle's durability in the unit its own GAME prints, and the Armour Rating
-- that goes with it.
--
-- Migration 060 opened `vehicles.system` to 'heroes-unlimited'. It did not give
-- the table anywhere to put what that game actually prints, and the gap is not
-- cosmetic: every column here assumes Rifts.
--
-- WHAT HEROES UNLIMITED PRINTS. Its 49 conventional and military vehicles carry
-- an A.R. and an S.D.C., never an M.D.C.:
--
--   M-48A3 Patton II (tank)
--   A.R.: 18, S.D.C.: Main body - 1000, main gun - 200, treads - 75 each.
--
-- M.D.C. and S.D.C. are not the same unit and not a matter of labelling. One
-- M.D.C. point absorbs a hundred S.D.C. of damage, which is the central
-- distinction of the Megaverse rules. Writing 1000 S.D.C. into `mdc_main_body`
-- would state that a Patton survives what a Glitter Boy survives; the editor
-- form labels that field "M.D.C. (main body)", so it would say so on screen as
-- well. `gear` settled this question already and has carried `is_mega_damage`
-- since it was built - this is the same flag, on the other catalog.
--
-- `is_mega_damage` GOVERNS `vehicle_locations.mdc` TOO. A location row holds a
-- number and the vehicle it belongs to says what the number means, so the
-- Patton's "treads - 75 each" needs no second flag of its own and no column is
-- added there.
--
-- DEFAULT 1, WHICH IS THE SAFE DIRECTION. All 171 existing rows are `rifts` and
-- all of them are M.D.C. - checked before this was written, not assumed - so
-- the default states what is already true of every row in the table. A default
-- of 0 would silently reclassify all 171.
--
-- WHY `ar` IS A COLUMN AND NOT A NOTE. Armour Rating is a to-hit threshold the
-- rules read - a strike that rolls under it misses the vehicle entirely - not
-- prose about it. `gear.ar` already exists for body armour for the same reason,
-- and this is the same number on a larger object. It stays NULL for every Rifts
-- vessel, which is correct: M.D.C. vehicles do not have one.

ALTER TABLE vehicles ADD COLUMN ar INTEGER;
ALTER TABLE vehicles ADD COLUMN is_mega_damage INTEGER NOT NULL DEFAULT 1;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('062-vehicle-sdc-and-armor-rating.sql');
