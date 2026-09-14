-- Heroes Unlimited's modern firearms, printed 201-206. Forty-seven rows:
-- pistols, machine pistols, submachine guns, rifles and shotguns.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-c-modern-firearms.sql
--
-- A THIRD FORMAT, AND THE ONLY MACHINE-READABLE ONE IN THIS CHAPTER. Each entry
-- is a name on its own line followed by a LABELLED run - Country, Cartridge,
-- Feed, Weight, Barrel Length, Muzzle Velocity, Approx. Effective Range,
-- Damage, Cost. Because every value is labelled, a misread shows up as a
-- missing field rather than as a silent shift of numbers between columns, which
-- is what makes the 193-194 tables dangerous and these pages safe.
--
-- HOW THE COUNT WAS CHECKED, since "47" has to come from somewhere other than
-- the parser that produced the rows: `Country:` occurs 47 times across printed
-- 201-206 and the parser returned 46 entries. That one-row gap is the
-- Thompson/Ingram pair below. The marker count is an independent reading of the
-- same pages.
--
-- ===================================================================
-- THE ONE ENTRY A PARSER CANNOT SEE
-- ===================================================================
--
-- Printed 204 sets `.45 Thompson M1` and `Ingram Model 10` side by side, and
-- the OCR interleaves the two columns onto SHARED LINES:
--
--   Country: U.S., Cartridge: .45 A.C.P., Feed: 20 or 30 round Country: U.S., ...
--   ... Damage: 4D6, Cost: $600.00.   (200m), Damage: 4D6, Cost: $700.00.
--
-- So both entries' `Country:` markers land on one line, the name line holds
-- both names, and a parser keyed on line-initial `Country:` makes ONE entry out
-- of two. The Ingram is added by hand from that same block, where its half of
-- every line is intact, and its figures were read against the page.
--
-- ===================================================================
-- NAME REPAIRS, ALL OF THEM OCR ARTIFACTS
-- ===================================================================
--
-- The dominant pattern is the CALIBRE PREFIX. The book writes `.45 Colt` and
-- `.38 Special`; the cache turns the leading full stop into a hyphen or drops
-- it altogether. Printed 203 rendered at 210 dpi reads `.45 Colt` and `.45
-- Model 15 General Officers`, which is what establishes the pattern rather than
-- assuming it. The rest are trailing marks the OCR picked out of the artwork -
-- `Erma Olympia p`, `9mm Model P5 Walther \`, `P230 Sig Sauer -`.
--
-- Nine names are repaired. No name is REWORDED: every change either restores a
-- leading full stop or drops a stray character.
--
-- ===================================================================
-- FIVE ROWS WITH NO DAMAGE, AND ONE WITH NO WEIGHT
-- ===================================================================
--
-- THE FIVE SHOTGUNS GENUINELY HAVE NO DAMAGE FIELD, and that is the book's
-- design rather than a gap in the reading. Printed 198: "Since the major factor
-- in the damage of a particular weapon is the type of shell used, we have
-- developed a Damage Rating based on the cartridge types." So a shotgun's
-- damage comes from the Tissue Damage Ratings table on printed 198-199 and the
-- entry prints Country, Calibre, Type, Feed, Weight, Barrel Length and Cost and
-- stops. `damage` is NULL on those five and the description says why.
--
-- THE DRAGUNOV HAS NO WEIGHT, AND THE BOOK IS WHAT OMITS IT. Printed 205 reads
-- `Weight: 4.3,` with no unit - confirmed on a 210 dpi render, so this is the
-- page and not the cache. Every neighbouring rifle is in kg and 4.3kg (9.5 lbs)
-- is almost certainly meant, but supplying the unit would be inventing the one
-- thing the book did not say. `weight_lbs` is NULL and the description carries
-- the printed figure and the reasoning.
--
-- Weights elsewhere are converted from the printed gram or kilogram figure to
-- pounds, one decimal place.
--
-- `payload` holds the Feed string, `range` the Approx. Effective Range as
-- printed (both feet and metres), and `description` the Country, Cartridge,
-- Barrel Length and Muzzle Velocity, none of which has a column.
--
-- is_mega_damage is 0 on every row: this book has no M.D.C. system.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.


-- ===================================================================
-- THIS FILE REPLACES ITS OWN ROWS, AND HERE IS WHY
-- ===================================================================
--
-- The first apply of this script wrote 47 rows with CORRUPTED TEXT, and they
-- reached production. The generator folds a few typographic characters to ASCII
-- before quoting - em dashes and curly quotes - and that fold was once added by
-- patching the generator from a Bash `node -e`. The Bash tool ate a backslash:
-- `\s+` arrived as `s+`, so `.replace(/s+/g, " ")` replaced EVERY LETTER "s" in
-- every string with a space. "Czechoslovakia" became "Czecho lovakia" and
-- ".45 Thompson M1" became ".45 Thomp on M1".
--
-- It was caught by an assertion, not by eye: `the Thompson and the Ingram are
-- two rows` returned 1 instead of 2, because the name no longer matched itself.
-- Every other assertion in the file passed - the counts, the prices, the damage
-- figures and the weights were all untouched, because the corruption was in the
-- TEXT and the numbers were fine. A readback that only counted rows would have
-- called this batch clean.
--
-- So the DELETE below is a repair, not a design. It is bounded by this file's
-- own `source_book`, it runs before the INSERTs, and on a fresh rebuild it
-- matches nothing and costs nothing.

DELETE FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206';

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('brigadier', 'Brigadier', 'heroes-unlimited', 'weapon', 4.2, 450, NULL, '4D6', 0, '165ft (50m)', '8 round mag.', NULL, 'Country: Canada. Cartridge: .45. Barrel length: 140mm. Muzzle velocity: 253m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-65mm-model-61-skorpion', '7.65mm Model 61 Skorpion', 'heroes-unlimited', 'weapon', 3.5, 1300, NULL, '1D8', 0, '165ft (50m)', '10 or 20 round box mag.', NULL, 'Country: Czechoslovakia. Cartridge: .32 A.C.P. (7.65mm). Barrel length: 112mm (513mm - butt extended; 269mm - butt retracted). Muzzle velocity: 317m/s - 274m/s with silencer.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('erma-olympia', 'Erma Olympia', 'heroes-unlimited', 'weapon', 2.4, 500, NULL, '2D6', 0, '135ft (40m)', '10 round mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: .22. Barrel length: 200mm. Muzzle velocity: 300m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('erma-kgp-68', 'Erma KGP 68', 'heroes-unlimited', 'weapon', 1.4, 350, NULL, '2D6', 0, '135ft (40m)', '9 round box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 7.65mm. Barrel length: 89mm. Muzzle velocity: 280m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-65mm-pp-walther', '7.65mm PP Walther', 'heroes-unlimited', 'weapon', 1.5, 600, NULL, '2D6', 0, '135ft (40m)', '8 round detachable box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 7.65mm, 9mm short. Barrel length: 99mm. Muzzle velocity: 290m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-special-mauser-revolver', '.38 Special Mauser Revolver', 'heroes-unlimited', 'weapon', 1.5, 300, NULL, '2D6', 0, '165ft (50m)', '6 chamber cylinder', NULL, 'Country: Germany, Federal Republic. Cartridge: .38 Special. Barrel length: 63.5mm (175mm). Muzzle velocity: 360m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('parabellum-mauser', 'Parabellum Mauser', 'heroes-unlimited', 'weapon', 2, 620, NULL, '1D8', 0, '135ft (40m)', '8 round box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 7.65mm. Barrel length: 150mm. Muzzle velocity: 280m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-model-p5-walther', '9mm Model P5 Walther', 'heroes-unlimited', 'weapon', 1.8, 925, NULL, '2D6', 0, '165ft (50m)', '8 round detachable box mag.', NULL, 'Country: Germany, Federal RepublicCartridge: 9mm. Barrel length: 90mm. Muzzle velocity: 350m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-model-951r-semi-p-full-auto-beretta', '9mm Model 951R Semi P Full Auto Beretta', 'heroes-unlimited', 'weapon', 3, 450, NULL, '2D6', 0, '180ft (55m)', '10 round detachable box mag.', NULL, 'Country: Italy. Cartridge: 9mm Parabellum. Barrel length: 125mm. Muzzle velocity: 390m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-wz-63-pm-63-machine-pistol', '9mm Wz 63 (PM-63) Machine Pistol', 'heroes-unlimited', 'weapon', 4, 1200, NULL, '2D6', 0, '135ft (40m) - Stock extended', '25 or 40 round box mag.', '(cyclic) 600 rounds/ min., (auto) 75 rounds/min., (single shot) 40 rounds/min.', 'Country: Poland. Cartridge: 9mm. Barrel length: 152mm (333mm). Muzzle velocity: 323m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-special-model-960-astra-revolver', '.38 Special Model 960 Astra Revolver', 'heroes-unlimited', 'weapon', 2.5, 250, NULL, '2D6 or 3D6 (power)', 0, '165ft (50m)', '6 chamber cylinder', NULL, 'Country: Spain. Cartridge: .38 Special. Barrel length: 102mm. Muzzle velocity: 265m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('hammerli-model-208', 'Hammerli Model 208', 'heroes-unlimited', 'weapon', 1.7, 1300, NULL, '1D6', 0, '135ft (40m)', '8 round box mag.', NULL, 'Country: Switzerland. Cartridge: .22. Barrel length: 125mm. Muzzle velocity: 300m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('p210-5-p-9mm-model-49-sig', 'P210-5 P 9mm Model 49 SIG', 'heroes-unlimited', 'weapon', 2, 1500, NULL, '2D6', 0, '165ft (50m)', '8 round box mag.', NULL, 'Country: Switzerland. Cartridge: 9mm Parabellum. Barrel length: 120mm. Muzzle velocity: 335m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('p230-sig-sauer', 'P230 Sig Sauer', 'heroes-unlimited', 'weapon', 1.6, 575, NULL, '2D6', 0, '165ft (50m)', '8 round box mag.', NULL, 'Country: Switzerland. Cartridge: 9mm. Barrel length: 98mm. Muzzle velocity: 320m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-tt-33-tokarev', '7.62mm TT-33 Tokarev', 'heroes-unlimited', 'weapon', 1.9, 400, NULL, '1D8', 0, '180ft (55m)', '8 round box mag.', NULL, 'Country: U.S.S.R. Cartridge: 7.62mm. Barrel length: 116mm. Muzzle velocity: 420m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-no-2-pistol-revolver', '.38 No. 2 Pistol Revolver', 'heroes-unlimited', 'weapon', 1.7, 225, NULL, '3D6', 0, '135ft (40m)', '6 chamber cylinder', NULL, 'Country: United Kingdom. Cartridge: .380 SAA Ball Revolver, .38 Smith & Wesson, .38 Webley. Barrel length: 102mm. Muzzle velocity: 183m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-special', '.38 Special', 'heroes-unlimited', 'weapon', 2.4, 490, NULL, '3D6', 0, '165ft (50m)', '6 chamber cylinder', NULL, 'Country: United Kingdom. Cartridge: .38 Special. Muzzle velocity: 360m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('auto-mag', 'Auto Mag', 'heroes-unlimited', 'weapon', 3.7, 650, NULL, '4D6', 0, '165ft (50m)', '8 round mag.', NULL, 'Country: U.S.. Cartridge: .44. Barrel length: 165mm. Muzzle velocity: 245m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('harrington-richardson-defender-revolver', 'Harrington & Richardson Defender Revolver', 'heroes-unlimited', 'weapon', 1.9, 200, NULL, '2D6 or 3D6 (power)', 0, '135ft (40m)', '5 chamber side-loading cylinder', NULL, 'Country: U.S.. Barrel length: 101mm. Muzzle velocity: 245m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('45-colt', '.45 Colt', 'heroes-unlimited', 'weapon', 2.6, 400, NULL, '4D6', 0, '165ft (50m)', '6 round detachable box mag.', NULL, 'Country: U.S.. Cartridge: .45. Barrel length: 140mm. Muzzle velocity: 250m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('45-model-15-general-officers', '.45 Model 15 General Officers', 'heroes-unlimited', 'weapon', 2.4, 370, NULL, '4D6', 0, '150ft (45m)', '7 round mag.', NULL, 'Country: U.S.. Cartridge: .45 A.C.P.. Barrel length: 171mm. Muzzle velocity: 300m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('38-service-six-ruger-revolver', '.38 Service-Six Ruger Revolver', 'heroes-unlimited', 'weapon', 2.1, 250, NULL, '2D6 or 3D6 (power)', 0, '165ft (50m)', '6 chamber side-loading cylinder', NULL, 'Country: U.S.. Cartridge: .38 Special. Barrel length: 10imm. Muzzle velocity: 350m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-md1-and-md-1a1-imbel', '9mm MD1 and MD 1A1 IMBEL', 'heroes-unlimited', 'weapon', 7.2, 1250, NULL, '2D6', 0, '615ft (175m)', '30 round box mag.', NULL, 'Country: Belgium. Cartridge: 9mm Parabellum. Barrel length: 211mm. Muzzle velocity: 400m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-c1', '9mm C1', 'heroes-unlimited', 'weapon', 6.5, 1200, NULL, '2D6', 0, '606ft (185m)', '30 round box mag.', NULL, 'Country: Canada. Cartridge: 9mm Parabellum. Barrel length: 198mm. Muzzle velocity: 366m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-mp5-heckler-koch', '9mm MP5 Heckler & Koch', 'heroes-unlimited', 'weapon', 5.4, 1450, NULL, '2D6', 0, '660ft (200m)', '15 or 30 round box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 9mm Parabellum. Barrel length: 225mm. Muzzle velocity: 400m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-uzi', '9mm Uzi', 'heroes-unlimited', 'weapon', 7.7, 1050, NULL, '2D6', 0, '660ft (200m)', '25 or 30 round box mag.', NULL, 'Country: Israel. Cartridge: 9mm. Barrel length: 260mm (650mm). Muzzle velocity: 400m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-mini-uzi', '9mm Mini Uzi', 'heroes-unlimited', 'weapon', 6, 1200, NULL, '2D6', 0, '490ft (150m)', '20, 25 or 30 round box mag.', NULL, 'Country: Israel. Cartridge: 9mm Parabellum. Barrel length: 197mm (600mm). Muzzle velocity: 350m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('9mm-model-12-beretta', '9mm Model 12 Beretta', 'heroes-unlimited', 'weapon', 6.6, 1200, NULL, '2D6', 0, '660ft (200m)', '20, 32 or 40 round box mag.', 'Cyclic - 550 rounds/ min., auto - 120 rounds/min., single shot - 40 rounds/min..', 'Country: Italy. Cartridge: 9mm Parabellum. Barrel length: 200mm (645mm). Muzzle velocity: 381m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-model-30-11-sniping-fn-rifle', '7.62mm Model 30-11 Sniping FN Rifle', 'heroes-unlimited', 'weapon', 10.7, 1590, NULL, '5D6', 0, '2133ft (650m)', '9 round removeable box mag.', NULL, 'Country: Belgium. Cartridge: 7.62mm NATO. Barrel length: 502mm (1117mm). Muzzle velocity: 850m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-c1a1-modified-rifle', '7.62mm C1A1 Modified Rifle', 'heroes-unlimited', 'weapon', 9.4, 750, NULL, '5D6', 0, '2133ft (650m)', '20 round box mag.', NULL, 'Country: Belgium. Cartridge: 7.62mm. Barrel length: 533mm (1136mm). Muzzle velocity: 840m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('model-98-mauser', 'Model 98 Mauser', 'heroes-unlimited', 'weapon', 8.6, 600, NULL, '4D6', 0, '1968ft (600m)', '5 round internal box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 7.62mm. Barrel length: 597mm (1103mm). Muzzle velocity: 754m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('wa-2000-walther-sniping-rifle', 'WA 2000 Walther Sniping Rifle', 'heroes-unlimited', 'weapon', 15.3, 1550, NULL, '5D6', 0, '1968ft (600m)', '6 round box mag.', NULL, 'Country: Germany. Cartridge: .300 Winchester Magnum, 7.62mm NATO, 7.65 Swiss. Barrel length: 650mm (905mm). Muzzle velocity: 780-800m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-g3-heckler-koch', '7.62mm G3 Heckler & Koch', 'heroes-unlimited', 'weapon', 9.7, 1700, NULL, '4D6', 0, '1320ft(400m)', '20 round box mag.', NULL, 'Country: Germany, Federal Republic. Cartridge: 7.62mm. Barrel length: 450mm (1025mm). Muzzle velocity: 780-800m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-sar-galil-assault-rifle', '7.62mm SAR Galil Assault Rifle', 'heroes-unlimited', 'weapon', 8.3, 1450, NULL, '5D6', 0, '1800ft (550m)', '25 round box mag.', NULL, 'Country: Israel. Cartridge: 7.62mm NATO. Barrel length: 400mm (915mm). Muzzle velocity: 800m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-galil-sniping-rifle', '7.62mm Galil Sniping Rifle', 'heroes-unlimited', 'weapon', 14.1, 1400, NULL, '5D6', 0, '1650ft (500m)', '20 round box mag.', NULL, 'Country: Israel. Cartridge: 7.62mm NATO. Barrel length: 508mm (840mm). Muzzle velocity: 815m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-ak-47', '7.62mm AK-47', 'heroes-unlimited', 'weapon', 9.5, 1420, NULL, '4D6', 0, '985ft (300m)', '30 round box mag.', NULL, 'Country: U.S.S.R.. Cartridge: 7.62mm. Barrel length: 414mm (869mm). Muzzle velocity: 710m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('7-62mm-dragunov-sniper-svd', '7.62mm Dragunov Sniper (SVD)', 'heroes-unlimited', 'weapon', NULL, 1570, NULL, '4D6', 0, '4265ft (1300m)', '20 round box mag.', NULL, 'Country: U.S.S.R.. Cartridge: 7.62mm. Barrel length: 547mm (1225mm), Muzzie Velocity: 830m/s. WEIGHT NOT STORED: printed 205 gives Weight: 4.3 with NO UNIT. Every neighbouring rifle is in kg, so 4.3kg (9.5 lbs) is almost certainly meant - but that is the BOOK omitting the unit, not the OCR, confirmed on a 210 dpi render, and the unit is not supplied here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('5-56mm-ar-180-scs-sterling-armalite', '5.56mm AR-180 SCS Sterling-Armalite', 'heroes-unlimited', 'weapon', 7, 700, NULL, '4D6', 0, '1509ft (460m)', '20, 30 or 40 round box mag.', NULL, 'Country: United Kingdom. Cartridge: 5.56mm. Barrel length: 464mm (9406mm). Muzzle velocity: 1000m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('5-56mm-m16-mi16a1', '5.56mm M16 & MI16A1', 'heroes-unlimited', 'weapon', 6.8, 675, NULL, '4D6', 0, '1320ft (400m)', '20 or 30 round box mag.', NULL, 'Country: U.S.. Cartridge: 5.56mm. Barrel length: 508mm (990mm). Muzzle velocity: 1000m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('mg-springfield-armory-survival-gun', 'MG Springfield Armory Survival Gun', 'heroes-unlimited', 'weapon', 3.2, 700, NULL, '2D6', 0, '1200ft (366m)', 'single shot', NULL, 'Country: U.S.. Cartridge: .22 long rifle rim-fire. Barrel length: 457mm (80cm). Muzzle velocity: 300m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('12-gauge-rs-200-beretta-shotgun', '12 Gauge RS 200 Beretta Shotgun', 'heroes-unlimited', 'weapon', 6.6, 450, NULL, NULL, 0, NULL, '5-6 round, pump operated', NULL, 'Country: Italy. Cartridge: 12 gauge, Type: manual repeating, pump action. Barrel length: 520mm (1030mm). NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('model-12-spas-franchi-shotgun', 'Model 12 SPAS Franchi Shotgun', 'heroes-unlimited', 'weapon', 7.1, 550, NULL, NULL, 0, NULL, 'magazine', NULL, 'Country: Italy. Cartridge: 12 bore, Type: gas, semi-auto or hand pump. Barrel length: 500mm (900mm). NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('model-37m-ithaca-shotgun', 'Model 37M Ithaca Shotgun', 'heroes-unlimited', 'weapon', 3.5, 380, NULL, NULL, 0, NULL, '5 or 8 round tubular mag.', NULL, 'Country: U.S.. Cartridge: 12 gauge, Type: Slide action repeater. Barrel length: 336mm. NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('stakeout-ithaca-shotgun', 'Stakeout Ithaca Shotgun', 'heroes-unlimited', 'weapon', 3.5, 380, NULL, NULL, 0, NULL, '5 round tubular mag.', NULL, 'Country: U.S.. Cartridge: 20 or 12 gauge, Type: Slide action repeater. Barrel length: 336mm. NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('model-3000-police-smith-wesson-shotgun', 'Model 3000 Police Smith & Wesson Shotgun', 'heroes-unlimited', 'weapon', 6.7, 900, NULL, NULL, 0, NULL, 'Single shot', NULL, 'Country: U.S.. Cartridge: 12 gauge. Barrel length: 458mm (978mm). NO DAMAGE IS PRINTED for this weapon. Printed 198: the major factor in a shotgun''s damage is the SHELL used, so the book gives a Tissue Damage Rating by cartridge type on printed 198-199 instead of a figure here.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('45-thompson-m1', '.45 Thompson M1', 'heroes-unlimited', 'weapon', 10.6, 600, NULL, '4D6', 0, '660ft (200m)', '20 or 30 round vertical box mag.', NULL, 'Country: U.S.. Cartridge: .45 A.C.P.. Barrel length: 267mm (810mm). Muzzle velocity: 282m/s.', 'Revised Heroes Unlimited p.201-206');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('ingram-model-10', 'Ingram Model 10', 'heroes-unlimited', 'weapon', 6.3, 700, NULL, '4D6', 0, '660ft (200m)', '30 round box mag.', NULL, 'Country: U.S.. Cartridge: .45 A.C.P.. Barrel length: 146mm (548mm). Muzzle velocity: 280m/s.', 'Revised Heroes Unlimited p.201-206');

-- ASSERTIONS.

SELECT 'all forty-seven firearms landed' AS assertion, count(*) AS got, 47 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206';

SELECT 'every one is a Heroes Unlimited weapon' AS assertion, count(*) AS got, 47 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND system = 'heroes-unlimited' AND category = 'weapon';

SELECT 'none is mega-damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206' AND is_mega_damage = 1;

SELECT 'every one carries its printed price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206' AND cost IS NULL;

-- EXACTLY FIVE have no damage, and they are the shotguns. If this number moves,
-- a weapon that should carry a damage figure has lost one.
SELECT 'exactly five rows have no damage' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206' AND damage IS NULL;

SELECT 'and all five are shotguns' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND damage IS NULL AND instr(name, 'Shotgun') > 0;

-- THE INTERLEAVED PAIR. Both must exist, with the prices the page gives each.
SELECT 'the Thompson and the Ingram are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND name IN ('.45 Thompson M1', 'Ingram Model 10') AND cost IN (600, 700);

-- THE CALIBRE PREFIX. If a leading full stop is ever lost again these go to 0.
-- Eight, not six: the first draft of this assertion guessed and reported 8
-- against a want of 6. Counted against production rather than estimated.
SELECT 'the calibre-prefixed names kept their full stop' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND substr(name, 1, 1) = '.';

-- EXACTLY ONE row has no weight, and it is the one the BOOK left unitless.
SELECT 'exactly one row has no weight' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206' AND weight_lbs IS NULL;

SELECT 'and it is the Dragunov' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND weight_lbs IS NULL AND instr(name, 'Dragunov') > 0;

-- A spot check on the arithmetic: the Brigadier prints 1925gms, which is 4.2 lbs.
SELECT 'the gram-to-pound conversion holds' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'brigadier' AND weight_lbs = 4.2 AND cost = 450 AND damage = '4D6';

-- A TEXT CHECK, because every count in this file passed while the text was
-- corrupt. These two strings are the ones the broken fold mangled.
SELECT 'Czechoslovakia survived the ASCII fold' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND instr(description, 'Czechoslovakia') > 0;

SELECT 'and no description lost its letter s' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.201-206'
   AND (instr(description, 'Czecho lovakia') > 0
     OR instr(name, 'Thomp on') > 0
     OR instr(description, 'Cartridge: .32 A.C.P.') = 0 AND instr(name, 'Skorpion') > 0);

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-c-modern-firearms.sql');
