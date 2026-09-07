-- Triax optics, medical equipment and miscellaneous gear, printed 151-152.
-- Nine rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-d-equipment.sql
--
-- TWELVE OF THIS SECTION'S ITEMS ARE ALREADY IN THE CATALOG AND ARE NOT
-- DUPLICATED: Telescopic Scope, Cross-Hair Sight, Laser Targeting, Light
-- Filters, Passive Nightvision, Hypodermic Gun, Suture Gun, Suture Tape, Micro
-- Scale, Portable Language Translator and the PC-3000 (held as Hand-Held
-- Computer), and the Palm Bio-Unit. Every candidate name in this book was
-- checked against all 1,025 gear rows before this file was written, not
-- assumed - and several of those
-- rows carry the SAME figures Triax prints, because Triax is reprinting RUE's
-- general equipment list. Where the numbers differ the catalog wins and the
-- difference is not recorded, per the catalog conventions.
--
-- THE SPU-5 IS ONE ITEM SOLD TWO WAYS - 100 credits worn on a belt, collar or
-- necklace, or 2,000 credits implanted. It is ONE row with both prices in the
-- cost_note rather than two rows, because it is one device.
--
-- THE LHP-1000 COMES IN TWO CASES with different weights and M.D.C. - a 5 lb
-- courier at 12 M.D.C. and a 10 lb briefcase at 25. The courier is stored and
-- the description carries both, the same way the catalog handles other rows
-- whose stats vary by model.
--
-- Sorts after add-triax-gear-c-ammunition.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('infrared-vision-scope', 'Infrared Vision (Scope Feature)', 'rifts', 'gear', NULL, 1000, '1,000 credits', NULL, 0, 'Maximum 2000 feet (610 m); viewing area about 7 feet (2.1 m) across', NULL, NULL, NULL, NULL, NULL, 'A scope feature that emits a narrow infrared beam invisible to the naked eye. The catch is real: anybody who also has infrared vision can see the beam and trace it straight back to whoever is using it.', 'Rifts World Book 5: Triax and the NGR p.151'),
('thermo-imager-scope', 'Thermo-Imager (Scope Feature)', 'rifts', 'gear', NULL, 12000, '12,000 credits', NULL, 0, '2000 feet (610 m)', NULL, NULL, NULL, NULL, NULL, 'A scope feature converting infrared radiation into a visible image in heat colours. Can be combined with a telescopic scope by adding that item''s cost. Up to four optics can be combined in one scope; the total is the sum of the items plus 20%.', 'Rifts World Book 5: Triax and the NGR p.151'),
('irou-breather', 'IROU "Breather"', 'rifts', 'gear', NULL, 50000, '50,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A caterpillar-shaped medical nanobot that enters through the mouth or a tracheotomy to inspect the lungs and throat, extract fluid and supply oxygen. It can deploy about six IRMSS units for minor repair work.', 'Rifts World Book 5: Triax and the NGR p.151-152'),
('irvt-seekers', 'IRVT "Seekers"', 'rifts', 'gear', NULL, 80000, '80,000 credits per unit', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A pinhead-sized medical nanobot injected into a vein and tracked by a homing device, used to locate blocked or damaged blood vessels. Effectively disposable: fewer than a third are ever retrieved, and they disintegrate after about 72 hours.', 'Rifts World Book 5: Triax and the NGR p.152'),
('rau-cleaners', 'RAU "Cleaners"', 'rifts', 'gear', NULL, 50000, '50,000 credits per pair; sold and dispatched in pairs', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A beetle-like medical robot about 3 inches (76 mm) long and 1 inch (25 mm) across, which cleans a wound, removes infection and dead flesh, and applies antiseptic.', 'Rifts World Book 5: Triax and the NGR p.152'),
('rsu-sleepers', 'RSU "Sleepers"', 'rifts', 'gear', NULL, 100000, '100,000 credits per set of four', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A set of four pinhead-sized brain-stimulating nanobots that induce calm and drowsiness, returning to their housing when the job is done.', 'Rifts World Book 5: Triax and the NGR p.152'),
('triax-lhp-1000-computer', 'Triax LHP-1000 Laser Holographic Portable Computer', 'rifts', 'gear', 5, 20000, '20,000 credits; good availability', NULL, 0, NULL, NULL, NULL, NULL, NULL, 12, 'A knock-off of the Wilk''s PC-2020, with a holographic projector and a plasma-screen backup. Four gigabyte hard drive, 64 MB of RAM, one-inch disks. Its identifier program recognises 6,000 vehicles and robots, 21,000 animal species, 40,000 insects and 50,000 plants - 1-72% from a typed description, 94% from a visual image. Two styles: the courier at 5 lbs (2.3 kg) and 12 M.D.C., and the "Adventurer" briefcase at 10 lbs (4.5 kg) and 25 M.D.C. The stored weight and M.D.C. are the courier.', 'Rifts World Book 5: Triax and the NGR p.152'),
('portable-short-range-radar', 'Portable Short-Range Radar System', 'rifts', 'gear', 15, 4000, '4,000 credits', NULL, 0, '5 miles (8 km)', NULL, NULL, NULL, NULL, NULL, 'A backpack-style radar scanner tracking up to twenty targets at once, with a 65% proficiency at reading speed, trajectory and direction.', 'Rifts World Book 5: Triax and the NGR p.152'),
('spu-5-sonic-pulsar-unit', 'SPU-5 Sonic Pulsar Unit', 'rifts', 'gear', NULL, 100, '100 credits as a belt, collar or necklace, or 2,000 credits as a cybernetic implant. Wide availability in all styles. The micro-battery lasts a year and costs 10 credits to replace', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A four-ounce device emitting a sound inaudible to humans, dogs and cats that repels fleas, ticks, lice and biting insects. Sold both as a worn accessory and as an implant; the stored cost is the worn version.', 'Rifts World Book 5: Triax and the NGR p.152-153');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 'ir%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-d-equipment.sql');
