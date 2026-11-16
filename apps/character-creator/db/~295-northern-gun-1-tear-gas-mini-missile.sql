-- The NG smoke/tear gas mini-missile's printed effect, from the Rifts World
-- Book 33: Northern Gun One import.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~295-northern-gun-1-tear-gas-mini-missile.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~295-northern-gun-1-tear-gas-mini-missile.sql
--
-- ~283 stored ng-smoke-tear-gas-mini-missile from the price summary on
-- printed 215 and said "The book prints its price only". That is true of the
-- summary and not of the book: the police rocket bike's standard mix of
-- mini-missiles prints both loads' effects. Each figure was re-read from the
-- book (PDF offset +1) on 2026-11-15 before this was written, and the row
-- read from production.
--
--   printed 85  smoke: a 40 foot (12.2 m) radius cloud that obscures vision;
--               one mile range.
--   printed 86  riot pacification/tear gas: a 30 foot (9.1 m) radius cloud;
--               -3 initiative and -5 to strike, parry and dodge for 1D4+4
--               melee rounds to those without eye covering and gas mask, half
--               that in a strong wind; environmental armor and air-tight
--               vehicles are safe; half mile range.
--
-- Only the description changes. damage, cost and cost_note are kept, and so
-- is range ("By launcher"): the one mile and half mile are printed for the
-- rocket bike's launchers, so they go in the description with their page.
-- Printed 126 names smoke in a standard mix and printed 137 as an alternate
-- payload; neither states an effect, so neither is cited.
--
-- The UPDATE is guarded on the text it replaces, so a re-run is a no-op. No
-- row is inserted or removed. THIS SCRIPT CHANGES PRODUCTION. The tilde
-- number is claimed at merge; it follows ~294 (PR #2222).

UPDATE gear
   SET description = 'Northern Gun''s smoke or tear gas mini-missile; neither load does damage. Tear gas, the riot pacification load of the police rocket bike on printed 86: a 30 foot (9.1 m) radius cloud. Anyone without protective eye covering and a gas mask is -3 on initiative and -5 to strike, parry and dodge for 1D4+4 melee rounds, half that in a strong wind; environmental body armor or an air-tight vehicle protects fully. Half mile range from that launcher. Smoke, on printed 85: a 40 foot (12.2 m) radius cloud that obscures vision, one mile range. The price summary on printed 215 gives the price alone.'
 WHERE slug = 'ng-smoke-tear-gas-mini-missile'
   AND description = 'Northern Gun''s smoke or tear gas mini-missile. The book prints its price only.';

-- Read-backs ---------------------------------------------------------------

SELECT 'the smoke/tear gas mini-missile carries the tear gas effect from printed 86' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'ng-smoke-tear-gas-mini-missile'
   AND instr(description, 'printed 86: a 30 foot (9.1 m) radius cloud') > 0
   AND instr(description, '-3 on initiative and -5 to strike, parry and dodge for 1D4+4 melee rounds') > 0
   AND instr(description, 'Half mile range') > 0;

SELECT 'it carries the smoke effect from printed 85' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'ng-smoke-tear-gas-mini-missile'
   AND instr(description, 'printed 85: a 40 foot (12.2 m) radius cloud') > 0;

SELECT 'it no longer says the book prints its price only' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE slug = 'ng-smoke-tear-gas-mini-missile'
   AND instr(description, 'prints its price only') > 0;

SELECT 'damage, range, price and source are as they were' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'ng-smoke-tear-gas-mini-missile'
   AND damage = 'None; smoke or tear gas' AND range = 'By launcher'
   AND is_mega_damage = 0 AND cost = 800 AND cost_note = '800 credits each'
   AND source_book = 'Rifts World Book 33: Northern Gun One p.215';

INSERT INTO data_script_runs (filename) VALUES ('~295-northern-gun-1-tear-gas-mini-missile.sql');
