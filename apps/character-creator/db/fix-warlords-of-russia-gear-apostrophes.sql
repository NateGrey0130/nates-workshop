-- Three Warlords of Russia gear rows lost an apostrophe on the way in.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-warlords-of-russia-gear-apostrophes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-warlords-of-russia-gear-apostrophes.sql
--
-- MECHANISM. add-warlords-of-russia-armor.sql and -equipment.sql were emitted
-- by a generator whose row text was written with SQL-style doubled quotes
-- inside Python single-quoted strings. Python reads that as two adjacent
-- strings and joins them, so the apostrophe vanished before the SQL escaper
-- ever saw it: "the animal's attacks" shipped as "the animals attacks" on
-- both bionic horses, and "The thermal suit's heated" as "The thermal suits
-- heated" on the Thermal Jacket. Found when book-reconcile reported the same
-- loss in a name in the bionics batch, before that batch was applied.
--
-- EVERY TABLE THE CAUSE WROTE TO: gear only. All 59 rows of batch 2 were
-- searched for it; the weapons script has no apostrophe in its row text and
-- these three are the only rows affected. No number is involved.
--
-- The two add- scripts are left as applied (class-import: never edit an
-- applied script). This file sorts after both, so a clean rebuild ends in the
-- corrected text. Each statement is guarded on the text it replaces, so a
-- second run changes nothing.

UPDATE gear SET damage = replace(damage, '(two of the animals attacks)', '(two of the animal''s attacks)')
 WHERE slug IN ('type-one-partial-bionic-horse', 'type-two-full-conversion-bionic-horse')
   AND instr(damage, '(two of the animals attacks)') > 0;

UPDATE gear SET description = replace(description, 'The thermal suits heated, waterproof system', 'The thermal suit''s heated, waterproof system')
 WHERE slug = 'thermal-jacket'
   AND instr(description, 'The thermal suits heated, waterproof system') > 0;

-- Readbacks: each must return got = want.
SELECT 'both horses read the animal''s attacks' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('type-one-partial-bionic-horse', 'type-two-full-conversion-bionic-horse')
   AND instr(damage, '(two of the animal''s attacks)') > 0;
SELECT 'the Thermal Jacket reads the thermal suit''s' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'thermal-jacket' AND instr(description, 'The thermal suit''s heated') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-warlords-of-russia-gear-apostrophes.sql');
