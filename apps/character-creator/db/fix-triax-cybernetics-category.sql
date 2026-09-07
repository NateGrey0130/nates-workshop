-- The twenty-five Triax implants move from category 'gear' and 'weapon' to
-- category 'cybernetics'.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-triax-cybernetics-category.sql
--
-- THE CATALOG ALREADY HAD A WORD FOR THESE AND THE IMPORT DID NOT USE IT.
-- db/schema.sql documents gear.category as "weapon | armor | vehicle |
-- cybernetics | gear", and js/catalog-fields.js offers the same six values as
-- the editor's select for that field - 'weapon', 'armor', 'vehicle',
-- 'cybernetics', 'gear', 'magic'. So 'cybernetics' is a supported value with a
-- UI behind it, and it was simply unused: nothing in the catalog carried it
-- before add-triax-gear-e-cybernetics.sql landed, and that script filed its
-- rows as 'gear' and 'weapon' instead.
--
-- That was a real choice at the time - the batch established the first
-- cybernetics in the catalog and there was no precedent to follow - but the
-- precedent existed in the schema comment and the editor config, and neither
-- was consulted. This corrects it rather than leaving the catalog naming a
-- vocabulary it does not use.
--
-- ALL TWENTY-FIVE MOVE, INCLUDING THE FOUR THAT DO DAMAGE. The Laser Beam Eye,
-- the LGL-31 Grapnel, the PL-31 Palm Laser Torch and the RVB-31 Concealed
-- Vibro-Blade went in as 'weapon' because they carry damage. They are still
-- implants: you do not buy a laser eye from a weapons rack, and the damage
-- itself is in the damage column either way. Filing them by what they ARE
-- beats filing them by what they DO, and it keeps the twenty-five together.
--
-- THE SPU-5 IS DELIBERATELY NOT HERE. Printed 152-153 sells it both as a worn
-- belt, collar or necklace at 100 credits and as an implant at 2,000; it is one
-- device, it is one row in add-triax-gear-d-equipment.sql, and it is primarily
-- a worn accessory. It stays category 'gear'.
--
-- Guarded on the current category so re-running is a no-op, and keyed on slug.
-- Sorts after add-triax-gear-e-cybernetics.sql, which creates the rows.
-- zzz-gear-tidy-3-categories.sql sorts later and rewrites categories, but only
-- WHERE category IS NULL, so it cannot undo this - checked, not assumed.

UPDATE gear
   SET category = 'cybernetics'
 WHERE category IN ('gear', 'weapon')
   AND slug IN (
        'macro-eye',
        'macro-eye-laser',
        'multi-system-eye-socket',
        'third-eye-implant',
        'medical-sensor-hand',
        'epidermic-analyzer',
        'pulse-and-pressure-detector',
        'stethoscopic-feature',
        'universal-finger-jack',
        'universal-laser-finger-scalpel',
        'universal-finger-camera',
        'bio-comp-self-monitoring-system',
        'internal-comp-calculator',
        'cyber-clock-calendar',
        'cyber-heat-sensor',
        'cyber-gyro-compass',
        'cyber-motion-detector',
        'cyber-radar-sensor',
        'cyber-radiation-sensor',
        'extendible-hydraulic-arm',
        'psionic-electro-magnetic-dampers',
        'laser-beam-eye',
        'lgl-31-grapnel-launcher',
        'pl-31-palm-laser-torch',
        'rvb-31-concealed-vibro-blade'
       );

-- Read the result back rather than trusting the exit code.
SELECT 'all twenty-five implants are filed as cybernetics' AS assertion,
       count(*) AS got, 25 AS want
  FROM gear WHERE category = 'cybernetics';

SELECT 'and the SPU-5 is not among them' AS assertion,
       (SELECT category FROM gear WHERE slug = 'spu-5-sonic-pulsar-unit') AS got,
       'gear' AS want;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-triax-cybernetics-category.sql');
