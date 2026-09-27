-- The NGR Police's two pairs of handcuffs, the one issued item
-- ~033-ngr-police-and-core-sdc-notes.sql left ungranted with a row to hand.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~034-ngr-police-handcuffs.sql
--
-- Printed 174 issues "two pairs of handcuffs". Triax gives handcuffs no stats
-- of its own - the word appears only in issued-equipment lists (printed 174,
-- 181, 182) - so the row is `handcuffs-regular` (Revised Heroes Unlimited
-- p.218, S.D.C. 60), the one other Rifts police classes already grant: the ISS
-- Peacekeeper, Specter and Intel Specter, both NTSET classes and the Psi-Net
-- Agent, checked --remote on 2026-09-27. Regular rather than heavy because the
-- book says only "handcuffs", as those classes read it.
--
-- Every UPDATE is keyed on class_id and guarded on the text it replaces, so a
-- re-run is a no-op.

UPDATE imported_classes SET markdown = replace(markdown,
  '  - { item_id: "triax-tear-gas-grenade", qty: 2 }' || char(10),
  '  - { item_id: "triax-tear-gas-grenade", qty: 2 }' || char(10) || '  - { item_id: "handcuffs-regular", qty: 2 }' || char(10))
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '  - { item_id: "triax-tear-gas-grenade", qty: 2 }' || char(10)) > 0
    AND instr(markdown, '{ item_id: "handcuffs-regular"') = 0;

UPDATE imported_classes SET markdown = replace(markdown,
  '    holster, each of choice. The billy club/riot club (1D6 S.D.C.) has no row,' || char(10) || '    and the two pairs of handcuffs are not granted. All are in the body.' || char(10),
  '    holster, each of choice. The billy club/riot club (1D6 S.D.C.) has no row.' || char(10) || '    All are in the body.' || char(10) ||
  '  - THE TWO PAIRS OF HANDCUFFS ARE IN equipment_starting since 2026-09-27' || char(10) ||
  '    (~034-ngr-police-handcuffs.sql), as two of `handcuffs-regular`. Triax gives' || char(10) ||
  '    handcuffs no stats of its own, and that row (Revised Heroes Unlimited' || char(10) ||
  '    printed 218) is the one the ISS, NTSET and Psi-Net police classes grant.' || char(10) ||
  '    Printed 174 says only "two pairs of handcuffs", so regular rather than' || char(10) ||
  '    heavy. Until then this note said they were not granted.' || char(10))
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '    and the two pairs of handcuffs are not granted. All are in the body.') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
  'a gun holster of choice, two pairs of handcuffs, and a billy club or riot club doing 1D6 S.D.C.',
  'a gun holster of choice and a billy club or riot club doing 1D6 S.D.C.')
  WHERE class_id = 'ngr-police'
    AND instr(markdown, 'a gun holster of choice, two pairs of handcuffs, and a billy club or riot club doing 1D6 S.D.C.') > 0;

SELECT 'ngr-police grants two pairs of regular handcuffs and says so' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '  - { item_id: "handcuffs-regular", qty: 2 }') > 0
    AND instr(markdown, 'THE TWO PAIRS OF HANDCUFFS ARE IN') > 0
    AND instr(markdown, 'handcuffs are not granted') = 0
    AND instr(markdown, 'two pairs of handcuffs, and a billy club') = 0;

SELECT 'the handcuffs row it names exists' AS assertion, count(*) AS got, 1 AS want
  FROM gear
  WHERE slug = 'handcuffs-regular';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~034-ngr-police-handcuffs.sql');
