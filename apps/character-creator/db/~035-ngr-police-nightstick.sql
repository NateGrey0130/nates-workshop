-- The NGR Police's billy club/riot club, the last issued item with no
-- catalog row after ~034-ngr-police-handcuffs.sql.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~035-ngr-police-nightstick.sql
--
-- Printed 174 issues a "billy club/riot club (1D6 S.D.C.)". No Rifts gear row
-- is a police club: the Rifts clubs are mega-damage or tribal weapons. The
-- nightstick rows are Revised Heroes Unlimited's (printed 211), the family the
-- ISS and NTSET police classes already draw on, and of the two the
-- steel-rod-encased-nightstick does 1D6 S.D.C. - the book's figure - where the
-- fiberglass one those classes carry does 1D4. Checked --remote 2026-09-27.
--
-- Every UPDATE is keyed on class_id and guarded on the text it replaces, so a
-- re-run is a no-op.

UPDATE imported_classes SET markdown = replace(markdown,
  '  - { item_id: "handcuffs-regular", qty: 2 }' || char(10) || '',
  '  - { item_id: "handcuffs-regular", qty: 2 }' || char(10) || '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - { item_id: "handcuffs-regular", qty: 2 }' || char(10) || '') > 0
    AND instr(markdown, '  - { item_id: "handcuffs-regular", qty: 2 }' || char(10) || '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown,
  '    holster, each of choice. The billy club/riot club (1D6 S.D.C.) has no row.' || char(10) || '    All are in the body.' || char(10) || '',
  '    holster, each of choice. All are in the body.' || char(10) || '  - THE BILLY CLUB/RIOT CLUB IS IN equipment_starting since 2026-09-27' || char(10) || '    (~035-ngr-police-nightstick.sql), as `steel-rod-encased-nightstick`.' || char(10) || '    Printed 174 gives it 1D6 S.D.C. No Rifts row is a police club, and of the' || char(10) || '    Revised Heroes Unlimited nightsticks (printed 211) the steel rod encased' || char(10) || '    one does 1D6, where the fiberglass one the ISS and NTSET classes carry' || char(10) || '    does 1D4. Until then this note said it had no row.' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '    holster, each of choice. The billy club/riot club (1D6 S.D.C.) has no row.' || char(10) || '    All are in the body.' || char(10) || '') > 0
    AND instr(markdown, '    holster, each of choice. All are in the body.' || char(10) || '  - THE BILLY CLUB/RIOT CLUB IS IN equipment_starting since 2026-09-27' || char(10) || '    (~035-ngr-police-nightstick.sql), as `steel-rod-encased-nightstick`.' || char(10) || '    Printed 174 gives it 1D6 S.D.C. No Rifts row is a police club, and of the' || char(10) || '    Revised Heroes Unlimited nightsticks (printed 211) the steel rod encased' || char(10) || '    one does 1D6, where the fiberglass one the ISS and NTSET classes carry' || char(10) || '    does 1D4. Until then this note said it had no row.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown,
  'pump rifle - a gun holster of choice and a billy club or riot club doing 1D6 S.D.C. Also',
  'pump rifle - and a gun holster of choice. The billy club or riot club, 1D6 S.D.C., is stored as a steel rod encased nightstick. Also')
  WHERE class_id = 'ngr-police' AND instr(markdown, 'pump rifle - a gun holster of choice and a billy club or riot club doing 1D6 S.D.C. Also') > 0
    AND instr(markdown, 'pump rifle - and a gun holster of choice. The billy club or riot club, 1D6 S.D.C., is stored as a steel rod encased nightstick. Also') = 0;

SELECT 'ngr-police grants the nightstick and says why' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }') > 0
    AND instr(markdown, 'THE BILLY CLUB/RIOT CLUB IS IN') > 0
    AND instr(markdown, 'is stored as a steel rod encased nightstick') > 0
    AND instr(markdown, '(1D6 S.D.C.) has no row') = 0;

SELECT 'the nightstick row it names exists, and does 1D6 S.D.C.' AS assertion, count(*) AS got, 1 AS want
  FROM gear
  WHERE slug = 'steel-rod-encased-nightstick' AND damage = '1D6' AND is_mega_damage = 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~035-ngr-police-nightstick.sql');
