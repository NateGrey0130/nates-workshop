-- Gear names that were derived from their slug and lost something.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzz-gear-tidy-1-names.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzz-gear-tidy-1-names.sql
--
-- 368 of 893 gear names are exactly what you get by title-casing the slug, and
-- MOST OF THOSE ARE CORRECT: "Canteen", "Compass", "Backpack". Deriving a name
-- is only a defect when the derivation DESTROYED something the printed name
-- carries, and there are three ways that happens:
--
--   a lost lowercase function word   "Vial Of Holy Water"  -> "Vial of Holy Water"
--   an acronym flattened to a word   "Light Mdc Body Armor" -> "Light M.D.C. ..."
--   a lost hyphen                    "E Clip"              -> "E-Clip"
--
-- The obvious fourth test - a bare number in the name - was tried and dropped.
-- It fires on "Water skin, 2 pints" and "Bread, 4 loaves", which are typed
-- correctly off the Palladium price list and are not defects at all.
--
-- Each name below was checked against the cached book text rather than
-- guessed, and one of them came out the opposite way from the guess: the
-- Techno-Wizard abbreviation is TW, not T.W. Rifts Ultimate Edition prints
-- bare TW 154 times and "T.W." not once.
--
-- ONE RENAME COLLIDES ON PURPOSE. sleeping-bag-rifts was displaying as
-- "Sleeping Bag Rifts" - the slug's disambiguator had leaked into the name. It
-- is renamed to "Sleeping Bag", which is also what sleeping-bag is called,
-- because the two rows are the same item at the same price from the same page
-- and the duplicate should be retired rather than hidden behind a wrong name.
-- Both slugs are referenced by classes, so retiring one means editing class
-- markdown, which is a separate change.
--
-- Guarded on the CURRENT wrong name, so a re-run is a no-op and a name
-- somebody has since corrected by hand is left alone.


-- RUE prints E-Clip 104 times and "E Clip" never
UPDATE gear SET name = 'E-Clip' WHERE slug = 'e-clip' AND name <> 'E-Clip';

-- RUE printed 263: "Bio-Comp Monitor"
UPDATE gear SET name = 'Bio-Comp System' WHERE slug = 'bio-comp-system' AND name <> 'Bio-Comp System';

-- RUE printed 263 prints IRMSS unpunctuated
UPDATE gear SET name = 'Portable IRMSS Kit' WHERE slug = 'portable-irmss-kit' AND name <> 'Portable IRMSS Kit';

-- RUE prints M.D.C. 1010 times and bare MDC never
UPDATE gear SET name = 'Light M.D.C. Body Armor' WHERE slug = 'light-mdc-body-armor' AND name <> 'Light M.D.C. Body Armor';

-- same, plus the lost "or"
UPDATE gear SET name = 'Personalized Light or Medium M.D.C. Body Armor' WHERE slug = 'personalized-light-or-medium-mdc-body-armor' AND name <> 'Personalized Light or Medium M.D.C. Body Armor';

-- same, plus the lost "of the"
UPDATE gear SET name = 'Archaic M.D.C. Armor of the Pantheon' WHERE slug = 'archaic-mdc-armor-of-the-pantheon' AND name <> 'Archaic M.D.C. Armor of the Pantheon';

-- RUE prints C-18; the hyphen is the model number
UPDATE gear SET name = 'C-18 Laser Pistol' WHERE slug = 'c-18-laser-pistol' AND name <> 'C-18 Laser Pistol';

-- RUE: "PDD/Pocket Digital Disc player and recorder" - PDD, not P.D.D.
UPDATE gear SET name = 'PDD Pocket Audio Digital Disc Recorder/Player' WHERE slug = 'pdd-pocket-audio-digital-disc-recorder-player' AND name <> 'PDD Pocket Audio Digital Disc Recorder/Player';

-- RUE prints TW 154 times and "T.W." never - the obvious fix was the wrong one
UPDATE gear SET name = 'TW Converted Energy Pistol' WHERE slug = 'tw-converted-energy-pistol' AND name <> 'TW Converted Energy Pistol';

-- same
UPDATE gear SET name = 'TW Converted Energy Rifle' WHERE slug = 'tw-converted-energy-rifle' AND name <> 'TW Converted Energy Rifle';

-- RUE hyphenates it 22 times, never spaced
UPDATE gear SET name = 'Walkie-Talkie' WHERE slug = 'walkie-talkie' AND name <> 'Walkie-Talkie';

-- same
UPDATE gear SET name = 'Walkie-Talkie Radio' WHERE slug = 'walkie-talkie-radio' AND name <> 'Walkie-Talkie Radio';

-- RUE hyphenates hand-held 44 times
UPDATE gear SET name = 'Hand-Held Computer' WHERE slug = 'hand-held-computer' AND name <> 'Hand-Held Computer';

-- same
UPDATE gear SET name = 'Portable Hand-Held Computer' WHERE slug = 'portable-hand-held-computer' AND name <> 'Portable Hand-Held Computer';

-- RUE prints DPM
UPDATE gear SET name = 'Dog Pack DPM Riot Armor' WHERE slug = 'dog-pack-dpm-riot-armor' AND name <> 'Dog Pack DPM Riot Armor';

-- RUE prints Multi-Optics hyphenated
UPDATE gear SET name = 'Multi-Optics Band' WHERE slug = 'multi-optics-band' AND name <> 'Multi-Optics Band';

-- RUE printed 263: "First-Aid Kit (Standard)"
UPDATE gear SET name = 'First-Aid Kit' WHERE slug = 'first-aid-kit' AND name <> 'First-Aid Kit';

-- lost lowercase "of"
UPDATE gear SET name = 'Vial of Holy Water' WHERE slug = 'vial-of-holy-water' AND name <> 'Vial of Holy Water';

-- lost lowercase "and"
UPDATE gear SET name = 'Air Filter and Gas Mask' WHERE slug = 'air-filter-and-gas-mask' AND name <> 'Air Filter and Gas Mask';

-- lost lowercase "and"
UPDATE gear SET name = 'Gas Mask and Air Filter' WHERE slug = 'gas-mask-and-air-filter' AND name <> 'Gas Mask and Air Filter';

-- lost lowercase "with"
UPDATE gear SET name = 'Boots with Knife Holster' WHERE slug = 'boots-with-knife-holster' AND name <> 'Boots with Knife Holster';

-- lost lowercase "of"
UPDATE gear SET name = 'Energy Weapon of Choice' WHERE slug = 'energy-weapon-of-choice' AND name <> 'Energy Weapon of Choice';

-- lost lowercase "and"
UPDATE gear SET name = 'Fishing Line and Hooks' WHERE slug = 'fishing-line-and-hooks' AND name <> 'Fishing Line and Hooks';

-- lost lowercase "and"
UPDATE gear SET name = 'Hammer and Mallet' WHERE slug = 'hammer-and-mallet' AND name <> 'Hammer and Mallet';

-- the slug tail is a qualifier, not a word
UPDATE gear SET name = 'Hand Axe (Utility)' WHERE slug = 'hand-axe-utility' AND name <> 'Hand Axe (Utility)';

-- the slug dropped a preposition
UPDATE gear SET name = 'Infrared Binoculars with Digital Distancing Readout' WHERE slug = 'infrared-binoculars-digital-distancing-readout' AND name <> 'Infrared Binoculars with Digital Distancing Readout';

-- compound adjective
UPDATE gear SET name = 'Velcro-Strapped Boots' WHERE slug = 'velcro-strapped-boots' AND name <> 'Velcro-Strapped Boots';

-- the slug disambiguator had leaked into the name
UPDATE gear SET name = 'Sleeping Bag' WHERE slug = 'sleeping-bag-rifts' AND name <> 'Sleeping Bag';

-- Readback. Counts, not exit codes.
--
-- The first one does NOT enumerate the slugs above. It re-runs the DETECTION
-- over the whole catalog, so it fails if a row this script missed is still
-- carrying a capitalised function word or a flattened acronym - which is the
-- thing worth knowing, and something a list of what was already fixed cannot
-- tell you.
--
-- GLOB, NOT LIKE. Every defect here is a CASE defect, and SQLite's LIKE is
-- case-insensitive over ASCII: '% Of %' matches the correctly lowercased "of"
-- in "Vial of Holy Water" just as happily as the wrong one. Written with LIKE
-- this returned 78 and meant nothing. GLOB is case-sensitive and returns 0.
SELECT count(*) AS names_still_damaged FROM gear
 WHERE name GLOB '* Of *' OR name GLOB '* And *' OR name GLOB '* The *'
    OR name GLOB '* Or *' OR name GLOB '* With *'
    OR name GLOB '*Mdc*' OR name GLOB 'Tw *' OR name GLOB '*Irmss*'
    OR name GLOB 'Pdd *' OR name = 'E Clip';
SELECT count(*) AS sleeping_bags_sharing_a_name FROM gear WHERE name = 'Sleeping Bag';
SELECT slug, name FROM gear
 WHERE slug LIKE '%mdc%' OR slug LIKE 'tw-%' OR slug = 'e-clip'
    OR slug LIKE 'walkie%' OR slug LIKE '%hand-held%'
 ORDER BY slug;


-- Records this run. REQUIRED: the smoke test fails a data script
-- that has no footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zzz-gear-tidy-1-names.sql');
