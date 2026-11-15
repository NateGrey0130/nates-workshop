-- Four readings from the Rifts World Book 33: Northern Gun One import, as
-- Nate confirmed them on 2026-11-15.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~294-northern-gun-1-confirmed-readings.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~294-northern-gun-1-confirmed-readings.sql
--
-- Fifteen judgement readings from the import were put to Nate on 2026-11-15
-- and he took every recommendation. Eleven keep what is stored. These four
-- change it. Each figure was re-read from the book (PDF offset +1) on
-- 2026-11-15 before this was written, and each row read from production.
--
-- 1. bush-pilot (add-bush-pilot-class.sql): an adventurer, not men of arms.
--    men_of_arms false and occ_group optional, as production's operator and
--    wilderness-scout are. The book prints no grouping (printed 76).
-- 2. ng-sales-rep (add-ng-sales-rep-class.sql): gains Language: Native Tongue
--    at the catalog's 98%. The book lists none for this O.C.C. (printed 89);
--    Nate ruled that an omission.
-- 3. ng-fragmentation-mini-missile and ng-high-explosive-mini-missile
--    (~283): damage 5D6 M.D. The price summary on printed 215 gives a price
--    only, but the book prints fragmentation at 5D6 M.D. on printed 107, 124,
--    149 and 153 and high explosive at 5D6 M.D. on printed 86. Printed 126
--    gives high explosive 1D4x10 M.D.; that goes in the description. Prices
--    and the other mini-missile rows are not touched.
-- 4. ng-hcb-ad2-hovertrain-weapon-car, Heavy, Large Weapon Turret (~292):
--    220 M.D.C. is kept. The note already recorded the other figure; it now
--    says where: the turret note on the same printed page, 97, prints 200.
--
-- Every UPDATE is guarded on the text it replaces, so a re-run is a no-op.
-- No row is inserted or removed. THIS SCRIPT CHANGES PRODUCTION. The tilde
-- number is claimed at merge.

-- 1. bush-pilot ------------------------------------------------------------

UPDATE imported_classes
   SET markdown = replace(markdown,
'
men_of_arms: true
occ_group: men-of-arms
',
'
men_of_arms: false
occ_group: optional
'),
       updated_at = datetime('now')
 WHERE class_id = 'bush-pilot'
   AND instr(markdown, '
men_of_arms: true
occ_group: men-of-arms
') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'heading on printed 76 is "Northern Gun O.C.C.s". Read as men of arms, the
    group Rifts Ultimate Edition files its pilot O.C.C.s under (robot-pilot),
    and for the entry''s "part gun toting Merc Soldier". The other reading, an
    adventurer like the Operator and Wilderness Scout it also names, would be
    occ_group optional and men_of_arms false.
',
'heading on printed 76 is "Northern Gun O.C.C.s". Stored as an adventurer
    (occ_group optional, men_of_arms false), as production''s Operator and
    Wilderness Scout are, both of which the entry names: Nate''s ruling of
    2026-11-15. The other reading was men of arms, the group Rifts Ultimate
    Edition files its pilot O.C.C.s under (robot-pilot), and for the entry''s
    "part gun toting Merc Soldier"; the class was stored that way until then.
'),
       updated_at = datetime('now')
 WHERE class_id = 'bush-pilot'
   AND instr(markdown, 'Read as men of arms, the
    group Rifts Ultimate Edition') > 0;

-- 2. ng-sales-rep ----------------------------------------------------------

UPDATE imported_classes
   SET markdown = replace(markdown,
'    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: one of choice (+10%)." }
',
'    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book lists no native language for this O.C.C.; Nate ruled that an omission on 2026-11-15." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: one of choice (+10%)." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ng-sales-rep'
   AND instr(markdown, '"Language: Native Tongue"') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'The
    book lists no Language: Native Language for this O.C.C. and none is stored.
',
'The
    book lists no Language: Native Language for this O.C.C.; Nate ruled that
    an omission on 2026-11-15, and Language: Native Tongue is stored at the
    catalog base of 98%.
'),
       updated_at = datetime('now')
 WHERE class_id = 'ng-sales-rep'
   AND instr(markdown, 'for this O.C.C. and none is stored.') > 0;

-- 3. the two mini-missiles -------------------------------------------------

UPDATE gear
   SET damage = '5D6 M.D.',
       description = 'Northern Gun''s fragmentation mini-missile, an anti-personnel missile. The price summary on printed 215 gives its price only; the damage is the 5D6 M.D. the book prints for fragmentation mini-missiles on printed 107, 124, 149 and 153.'
 WHERE slug = 'ng-fragmentation-mini-missile'
   AND damage = 'Not printed in this book''s price summary';

UPDATE gear
   SET damage = '5D6 M.D.',
       description = 'Northern Gun''s high-explosive mini-missile. The price summary on printed 215 gives its price only; the damage is the 5D6 M.D. printed for the police rocket bike''s high explosive mini-missiles on printed 86. A standard-issue mix on printed 126 prints 1D4x10 M.D. for high explosive instead.'
 WHERE slug = 'ng-high-explosive-mini-missile'
   AND damage = 'Not printed in this book''s price summary';

-- 4. the hovertrain weapon car's heavy turret ------------------------------

UPDATE vehicle_locations
   SET mdc_note = 'Per turret fitted. The Turret Note under Weapon Systems on the same printed page (97) gives a heavy turret 200 M.D.C.; the location table''s 220 is kept.'
 WHERE vehicle_slug = 'ng-hcb-ad2-hovertrain-weapon-car'
   AND location = 'Heavy, Large Weapon Turret'
   AND mdc_note = 'Per turret fitted. The Turret Note under Weapon Systems prints 200 for a heavy turret; the location table''s 220 is kept.';

-- Read-backs ---------------------------------------------------------------

SELECT 'bush-pilot is an adventurer' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'bush-pilot'
   AND instr(markdown, char(10) || 'men_of_arms: false' || char(10) || 'occ_group: optional' || char(10)) > 0
   AND instr(markdown, 'men_of_arms: true') = 0
   AND instr(markdown, 'occ_group: men-of-arms') = 0
   AND instr(markdown, 'Nate''s ruling of' || char(10) || '    2026-11-15') > 0;

SELECT 'ng-sales-rep has one Language: Native Tongue line, at 98' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'ng-sales-rep'
   AND instr(markdown, '    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: ') > 0
   AND length(markdown) - length(replace(markdown, '"Language: Native Tongue"', '')) = length('"Language: Native Tongue"')
   AND instr(markdown, 'and none is stored') = 0
   AND instr(markdown, 'catalog base of 98%') > 0;

SELECT 'both classes are still published and live' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('bush-pilot', 'ng-sales-rep')
   AND status = 'published' AND deleted_at IS NULL;

SELECT 'both mini-missiles do 5D6 M.D. at their old price' AS assertion, count(*) AS got, 2 AS want
  FROM gear
 WHERE slug IN ('ng-fragmentation-mini-missile', 'ng-high-explosive-mini-missile')
   AND damage = '5D6 M.D.' AND is_mega_damage = 1 AND cost = 1200
   AND instr(description, 'prints its price only') = 0;

SELECT 'the high-explosive row records the 1D4x10 reading' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'ng-high-explosive-mini-missile'
   AND instr(description, 'printed 126 prints 1D4x10 M.D.') > 0;

SELECT 'the other three mini-missiles are untouched' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'ng-armor-piercing-mini-missile' AND damage = '1D4x10 M.D.')
    OR (slug = 'ng-plasma-napalm-mini-missile' AND damage = 'Plasma 1D6x10 M.D.')
    OR (slug = 'ng-smoke-tear-gas-mini-missile' AND damage = 'None; smoke or tear gas');

SELECT 'the heavy turret keeps 220 and cites printed 97' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_locations
 WHERE vehicle_slug = 'ng-hcb-ad2-hovertrain-weapon-car'
   AND location = 'Heavy, Large Weapon Turret'
   AND mdc = 220
   AND instr(mdc_note, 'same printed page (97) gives a heavy turret 200 M.D.C.') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~294-northern-gun-1-confirmed-readings.sql');
