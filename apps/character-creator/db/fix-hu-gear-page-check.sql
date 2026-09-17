-- Heroes Unlimited gear rows checked against the HU book's own pages, after the
-- Nightbane equipment import (PR #1132) diffed against them. Five rows are
-- added and ten are corrected.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-hu-gear-page-check.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-hu-gear-page-check.sql
--
-- Nightbane's page was the lead, never the source. Every value below was read
-- off Revised Heroes Unlimited itself: the OCR cache first
-- (.cache/books/heroes-unlimited-core, page_offset 0, so printed N is pNNN),
-- then the PDF page rendered with PyMuPDF and read by eye, 2026-09-16. The cache
-- is OCR of a scan, so a figure in it is a lead too, and one of them (the
-- S.C.U.B.A. below) was wrong.
--
-- ===================================================================
-- CHECKED AND LEFT ALONE - the HU row is what the HU page prints
-- ===================================================================
--
--   Heavy Machinegun (.50 and 14.5mm)  printed 207 reads "Cost: $5000 and up".
--                                      Nightbane prints $6000. The books differ;
--                                      the HU row is right for HU.
--   90mm Recoilless Rifle              printed 207 reads "Damage: 1D10 x 100".
--                                      Nightbane prints 2D4x100; HU is right.
--   Guisarme (guisarme-hu)             printed 193, rendered: the row's "$550"
--                                      sits in the Damage column and the Cost
--                                      column is empty. No damage is printed,
--                                      as add-hu-gear-a already says.
--
-- ===================================================================
-- FOUR HANDGUNS THE FIREARMS IMPORT NEVER SAW
-- ===================================================================
--
-- add-hu-gear-c-modern-firearms.sql covers "printed 201-206", and the
-- automatic-pistol list does not start on 201. The heading REVOLVERS /
-- AUTOMATIC PISTOLS and its first three entries - Browning GP 35, 7.65mm 140
-- Double-Action FN, Barracuda FN Revolver - are the right-hand column of
-- printed 200, under the Metric Conversion Chart. Brigadier, the first row that
-- file holds, is the top of 201.
--
-- The fourth is the last entry on printed 201, .38 Trident Super 4 Renato Gamba
-- Revolver, and it is the only firearm in the chapter that prints no
-- `Country:` field. That file counted its entries by `Country:` markers, so the
-- one entry without a marker was invisible to the count that was meant to
-- catch a missed row.
--
-- Each takes the conventions of add-hu-gear-c: weight converted from the
-- printed grams or kilograms to pounds at one decimal place, `payload` the Feed
-- string, `range` the Approx. Effective Range as printed, and Country,
-- Cartridge, Barrel Length and Muzzle Velocity in the description. The slugs
-- are the bare names, which production holds nowhere - Nightbane's copies are
-- `-nb` - and which no catalog_redirects row has retired (checked --remote,
-- 2026-09-16). `source_book` names the page each is printed on rather than
-- joining add-hu-gear-c's "p.201-206", which is the string that file's own
-- count assertions key on.
--
-- ===================================================================
-- THE SHOTGUNS DO PRINT A DAMAGE AND A RANGE
-- ===================================================================
--
-- add-hu-gear-c says the five shotguns "GENUINELY HAVE NO DAMAGE FIELD". They
-- have no damage field in their own entries, but printed 206 sets a note
-- directly under the SHOTGUNS heading, above the first of them:
--
--   Note: The following stats apply to all shotguns:
--   Approx. Effective Range: 100ft (30m)
--   Damage: 4D6 for Buckshot (scatter)
--           5D6 for solid slug
--
-- So all five get that damage, in the words it is printed in, and that range.
-- The sentence in each description that said no damage is printed is replaced
-- with one that says where the figures come from.
--
-- ===================================================================
-- THE OTHER FIVE CORRECTIONS
-- ===================================================================
--
--   Low-Frequency Converter  printed 214 gives it its own line at $500. The
--                            $190 and the "boosts others" text belong to the
--                            NEXT line, "Frequency Equalizer (controls cutoff of
--                            certain frequencies and boosts others). Cost:
--                            $190." Two entries had become one row: the
--                            converter goes to $500 and the equalizer is added.
--   7.62mm G3 Heckler & Koch printed 204 prints "Rate of Fire: Cyclic - 500-600
--                            rounds/min., auto - 100 rounds/min." The cache runs
--                            the label together as `RateofFire:`, which is how
--                            it was missed; the row had NULL.
--   Compact S.C.U.B.A.       printed 216, rendered, reads "Overall length: 17
--                            inches x 2 1/2 inches wide" - a fraction the OCR
--                            read as `24`. The row said "17 by 24 inches".
--   Black Jack (modern)      printed 211 gives "2 to 4 pounds" and the row held
--                            3. add-hu-gear-d's own header stores the LOW end
--                            when the book prints a weight range, so 2.
--   .38 Special Mauser       printed 201 gives "approx. 600-660gms" and the row
--     Revolver               held 1.5, which is 660gms - the high end. The same
--                            rule gives 600gms, 1.3, and the Ithaca shotguns in
--                            add-hu-gear-c already store the lighter of their
--                            two printed weights. The printed range goes into
--                            the description, which did not mention it.
--
-- Every UPDATE is keyed by slug and guarded on the value it replaces, so
-- re-running is a no-op and a row someone has since corrected by hand is left
-- alone. The INSERTs are OR IGNORE on the UNIQUE slug.
--
-- IT SORTS AFTER THE FILES IT CORRECTS: `fix-` follows `add-hu-gear-c`, `-d`
-- and `-f`, so a rebuilt database gets the same rows production does. Nothing
-- that sorts later touches these slugs.

-- -- The four handguns ---------------------------------------------

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('browning-gp-35', 'Browning GP 35', 'heroes-unlimited', 'weapon', 2.2, 590, NULL, '2D6', 0, '135ft (40m)', '13 round mag.', NULL, 'Country: Belgium. Cartridge: 9mm. Barrel length: 118mm. Muzzle velocity: 350m/s.', 'Revised Heroes Unlimited p.200');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-65mm-140-double-action-fn', '7.65mm 140 Double-Action FN', 'heroes-unlimited', 'weapon', 1.4, 370, NULL, '2D6', 0, '165ft (50m)', '(9mm short) 13 round box mag.', NULL, 'Country: Belgium. Cartridge: 9mm short or 7.65mm. Barrel length: 173mm. Muzzle velocity: (9mm) 280m/s, (7.65mm) 295m/s.', 'Revised Heroes Unlimited p.200');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('barracuda-fn-revolver', 'Barracuda FN Revolver', 'heroes-unlimited', 'weapon', 2.3, 490, NULL, '4D6', 0, '165ft (50m)', '6 round cylinder', NULL, 'Country: Belgium. Cartridge: .357 Magnum, .38 Special. Barrel length: 76.2mm. Muzzle velocity: 360m/s.', 'Revised Heroes Unlimited p.200');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-trident-super-4-renato-gamba-revolver', '.38 Trident Super 4 Renato Gamba Revolver', 'heroes-unlimited', 'weapon', 1.6, 250, NULL, '2D6 or 3D6 (power)', 0, '150ft (45m)', '6 chamber cylinder', NULL, 'Cartridge: .38 Special. Barrel length: 101mm. Muzzle velocity: 360m/s. The book prints no Country for this entry.', 'Revised Heroes Unlimited p.201');

-- -- The shotgun note on printed 206 -------------------------------

UPDATE gear
   SET damage = '4D6 for Buckshot (scatter), 5D6 for solid slug',
       range = '100ft (30m)',
       description = replace(description,
         'NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.',
         'Damage and range are not in this entry: a note printed 206 under the SHOTGUNS heading applies them to all shotguns.')
 WHERE system = 'heroes-unlimited'
   AND slug IN ('12-gauge-rs-200-beretta-shotgun', 'model-12-spas-franchi-shotgun', 'model-37m-ithaca-shotgun', 'stakeout-ithaca-shotgun', 'model-3000-police-smith-wesson-shotgun')
   AND damage IS NULL AND range IS NULL;

-- -- The converter and the equalizer, printed 214 ------------------

UPDATE gear
   SET cost = 500, description = 'Printed 214.'
 WHERE slug = 'low-frequency-converter' AND system = 'heroes-unlimited' AND cost = 190;

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, range, is_mega_damage, description, source_book)
VALUES ('frequency-equalizer', 'Frequency Equalizer', 'heroes-unlimited', 'gear', NULL, 190, NULL, NULL, 0, 'Controls cutoff of certain frequencies and boosts others.', 'Revised Heroes Unlimited p.214');

-- -- The G3's rate of fire, printed 204 ----------------------------

UPDATE gear
   SET rate_of_fire = 'Cyclic - 500-600 rounds/min., auto - 100 rounds/min.'
 WHERE slug = '7-62mm-g3-heckler-koch' AND system = 'heroes-unlimited' AND rate_of_fire IS NULL;

-- -- The Compact S.C.U.B.A.'s size, printed 216 --------------------

UPDATE gear
   SET description = replace(description, '17 by 24 inches', '17 inches long by 2 1/2 inches wide')
 WHERE slug = 'compact-s-c-u-b-a' AND system = 'heroes-unlimited'
   AND instr(description, '17 by 24 inches') > 0;

-- -- Two weight ranges, stored at the low end ----------------------

UPDATE gear
   SET weight_lbs = 2,
       description = description || ' Printed weight is a RANGE, 2 to 4 pounds; the low end is stored.'
 WHERE slug = 'black-jack-modern' AND system = 'heroes-unlimited' AND weight_lbs = 3;

UPDATE gear
   SET weight_lbs = 1.3,
       description = description || ' Printed weight is a RANGE, approx. 600-660gms; the low end is stored.'
 WHERE slug = '38-special-mauser-revolver' AND system = 'heroes-unlimited' AND weight_lbs = 1.5;

-- ASSERTIONS. Every `want` is read off the page named above it, not off the
-- database this file just wrote.

SELECT 'the four handguns landed as Heroes Unlimited weapons' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND category = 'weapon' AND is_mega_damage = 0
   AND slug IN ('browning-gp-35', '7-65mm-140-double-action-fn', 'barracuda-fn-revolver', '38-trident-super-4-renato-gamba-revolver');

-- printed 200: $590 2D6, $370 2D6, $490 4D6. printed 201: $250 "2D6 or 3D6 (power)".
SELECT 'each handgun carries its printed price and damage' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE (slug = 'browning-gp-35' AND cost = 590 AND damage = '2D6' AND weight_lbs = 2.2 AND range = '135ft (40m)')
    OR (slug = '7-65mm-140-double-action-fn' AND cost = 370 AND damage = '2D6' AND weight_lbs = 1.4 AND range = '165ft (50m)')
    OR (slug = 'barracuda-fn-revolver' AND cost = 490 AND damage = '4D6' AND weight_lbs = 2.3 AND range = '165ft (50m)')
    OR (slug = '38-trident-super-4-renato-gamba-revolver' AND cost = 250 AND damage = '2D6 or 3D6 (power)' AND weight_lbs = 1.6 AND range = '150ft (45m)');

SELECT 'the handguns cite the page each is printed on' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE (slug IN ('browning-gp-35', '7-65mm-140-double-action-fn', 'barracuda-fn-revolver') AND source_book = 'Revised Heroes Unlimited p.200')
    OR (slug = '38-trident-super-4-renato-gamba-revolver' AND source_book = 'Revised Heroes Unlimited p.201');

-- add-hu-gear-c's own readbacks key on its source_book; this file must not move them.
SELECT 'add-hu-gear-c still holds exactly its forty-seven' AS assertion, count(*) AS got, 47 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206';

SELECT 'all five shotguns carry the printed 206 damage and range' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND instr(name, 'Shotgun') > 0
   AND source_book = 'Revised Heroes Unlimited p.201-206'
   AND damage = '4D6 for Buckshot (scatter), 5D6 for solid slug' AND range = '100ft (30m)';

SELECT 'no shotgun description still says no damage is printed' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND instr(description, 'NO DAMAGE IS PRINTED') > 0
   AND instr(name, 'Shotgun') > 0;

SELECT 'and all five say where the figures come from' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND instr(name, 'Shotgun') > 0
   AND instr(description, 'a note printed 206 under the SHOTGUNS heading') > 0;

SELECT 'the firearms file now has no row without damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206' AND damage IS NULL;

SELECT 'the converter is $500 and no longer carries the equalizer text' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'low-frequency-converter' AND cost = 500 AND instr(description, 'frequencies') = 0;

SELECT 'the equalizer is its own row at $190' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'frequency-equalizer' AND system = 'heroes-unlimited' AND cost = 190
   AND source_book = 'Revised Heroes Unlimited p.214';

SELECT 'the G3 carries its printed rate of fire' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = '7-62mm-g3-heckler-koch' AND instr(rate_of_fire, '500-600 rounds/min.') > 0
   AND instr(rate_of_fire, '100 rounds/min.') > 0;

SELECT 'the Compact S.C.U.B.A. is 2 1/2 inches wide, not 24' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'compact-s-c-u-b-a' AND instr(description, '2 1/2 inches wide') > 0
   AND instr(description, '24') = 0;

SELECT 'the modern Black Jack stores 2 pounds' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'black-jack-modern' AND weight_lbs = 2 AND cost = 20 AND damage = '1D6';

SELECT 'the Mauser revolver stores 600gms as 1.3 pounds' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = '38-special-mauser-revolver' AND weight_lbs = 1.3
   AND instr(description, '600-660gms') > 0;

-- printed 207 and 193: the three rows the Nightbane diff raised that HU's page confirms.
SELECT 'the rows the HU page confirms are unchanged' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE (slug = 'heavy-machinegun-50-and-14-5mm' AND cost = 5000)
    OR (slug = '90mm-recoilless-rifle' AND damage = '1D10x100')
    OR (slug = 'guisarme-hu' AND cost = 550 AND damage IS NULL);

INSERT INTO data_script_runs (filename) VALUES ('fix-hu-gear-page-check.sql');
