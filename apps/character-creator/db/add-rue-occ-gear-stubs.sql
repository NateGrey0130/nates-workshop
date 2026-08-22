-- Gear rows the RUE O.C.C. imports cite and the catalog did not have.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-rue-occ-gear-stubs.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-rue-occ-gear-stubs.sql
--
-- WHY THIS IS SEPARATE, AND LATE. Every add-<class>-class.sql in the RUE import
-- should have carried its own stub block above the class INSERT. None of them
-- did: the command that lifted the stub SQL out of class-check's output used a
-- sed range ending at the first blank line, and class-check prints a blank line
-- between its "STUB SQL" heading and the statements. The range therefore
-- captured the heading and nothing else, silently, for all thirteen classes.
--
-- The result was eleven classes shipped citing gear rows production did not
-- have. Nothing failed - a missing item is not a parse error - so it surfaced
-- only when the same bug produced an empty stub file for the Operator and the
-- count was checked against the classes already merged.
--
-- The "STUB" marker is load-bearing: it is how the gear importer later
-- recognises a row as still needing stats.
--
-- 58 rows, deduplicated across all thirteen classes.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('air-filter-and-gas-mask', 'Air Filter And Gas Mask', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('ammo-belt', 'Ammo Belt', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('black-clothing-covert', 'Black Clothing Covert', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('blank-disc', 'Blank Disc', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('coalition-dead-boy-body-armor', 'Coalition Dead Boy Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('conventional-tape-measure', 'Conventional Tape Measure', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('cord', 'Cord', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('digital-camera', 'Digital Camera', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('disposable-surgical-gloves', 'Disposable Surgical Gloves', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('dress-clothing', 'Dress Clothing', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('emergency-food-rations', 'Emergency Food Rations', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('fishing-line-and-hooks', 'Fishing Line And Hooks', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('fragmentation-grenade', 'Fragmentation Grenade', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('gas-mask-and-air-filter', 'Gas Mask And Air Filter', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('geiger-counter', 'Geiger Counter', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('goggles', 'Goggles', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('hammer-and-mallet', 'Hammer And Mallet', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('hand-axe-utility', 'Hand Axe Utility', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('helmet', 'Helmet', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('hovercycle', 'Hovercycle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('infrared-binoculars-digital-distancing-readout', 'Infrared Binoculars Digital Distancing Readout', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('iron-spike', 'Iron Spike', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('jeep', 'Jeep', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('large-tool-kit', 'Large Tool Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.91-92');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('laser-scalpel', 'Laser Scalpel', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('laser-torch', 'Laser Torch', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.91-92');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('light-mdc-body-armor', 'Light Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('light-mdc-body-armor', 'Light Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('light-mdc-body-armor', 'Light Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('lightweight-rope', 'Lightweight Rope', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('marker', 'Marker', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('mechanical-pencil', 'Mechanical Pencil', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('medical-kit', 'Medical Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('microscope-slide', 'Microscope Slide', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('pdd-pocket-audio-digital-disc-recorder-player', 'Pdd Pocket Audio Digital Disc Recorder Player', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('pen-flashlight', 'Pen Flashlight', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('personalized-light-or-medium-mdc-body-armor', 'Personalized Light Or Medium Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('pin', 'Pin', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('portable-hand-held-computer', 'Portable Hand Held Computer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('portable-microscope', 'Portable Microscope', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('portable-tool-kit', 'Portable Tool Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.91-92');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('reusable-surgical-gloves', 'Reusable Surgical Gloves', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('sack', 'Sack', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.98-99');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('saddlebags', 'Saddlebags', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('samas-power-armor', 'Samas Power Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('scalpel', 'Scalpel', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('soldering-iron', 'Soldering Iron', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.91-92');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('specimen-case', 'Specimen Case', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('specimen-dish', 'Specimen Dish', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('specimen-jar', 'Specimen Jar', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('surgical-gown', 'Surgical Gown', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('surgical-kit', 'Surgical Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.86-87');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('tent', 'Tent', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.53-57');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('test-tube', 'Test Tube', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('tool-kit', 'Tool Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('tweezers', 'Tweezers', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('video-disc', 'Video Disc', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('walkie-talkie-radio', 'Walkie Talkie Radio', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.95-96');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS rue_occ_stubs FROM gear
 WHERE description LIKE 'STUB%' AND source_book LIKE 'Rifts Ultimate Edition%';

INSERT INTO data_script_runs (filename) VALUES ('add-rue-occ-gear-stubs.sql');
