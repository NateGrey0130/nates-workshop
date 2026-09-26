-- The catalog's Lesser Rune Weapon (`lesser-rune-weapon`) was an estimate:
-- 250,000 credits, source 'Estimate - no published price found'. Rifts World
-- Book 2: Atlantis prices it on printed 128 at four to sixteen million
-- credits, beside the rune weapons add-atlantis-rune-weapons.sql adds. See
-- apps/character-creator/docs/surveys/atlantis.md.
--
-- One-off data script, run once per environment.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~007-atlantis-lesser-rune-weapon-price.sql
--
-- WHY ~007. add-godling-class.sql creates the row, and
-- estimate-mundane-gear-prices.sql and zzz-gear-tidy-2-stub-stats.sql set its
-- estimate after that, so a correction has to sort after all of them; a
-- first draft inside add-atlantis-rune-weapons.sql sorted before them and
-- d1-apply's pre-flight refused it. Keyed on the slug and guarded on the
-- estimate, so a re-run does nothing.

UPDATE gear SET cost = 4000000, cost_note = 'Four to sixteen million credits, sometimes more (printed 128).',
  damage = 'No less than 4D6 M.D. (4D6 S.D.C. on S.D.C. worlds)', is_mega_damage = 1, range = 'melee',
  description = 'A rune weapon with the eight standard abilities and nothing more. Every rune weapon has the eight standard abilities (printed 127-128): an independent personality of average to high I.Q.; limited telepathy with its owner; it is indestructible and never dulls; it is black, dark grey, blue-grey or dark red metal or stone lined with runes; it inflicts no less than 4D6 M.D. (4D6 S.D.C. on S.D.C. worlds) and can parry energy blasts at -6; it links to a wielder after six months of constant contact and senses its owner within 4 miles (6.4 km); +1 to all saving throws; and only a wielder of compatible alignment can use it - anyone else takes 1D8 S.D.C., or 3D6 M.D. if a mega-damage creature, each time he touches it. Rune weapons hold the trapped life essence of a powerful being; only the Splugorth still make them.', source_book = 'Rifts World Book 2: Atlantis p.127-128'
  WHERE slug = 'lesser-rune-weapon' AND source_book = 'Estimate - no published price found';

-- Read the result back.
SELECT 'the Lesser Rune Weapon carries the book price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'lesser-rune-weapon' AND cost = 4000000 AND source_book = 'Rifts World Book 2: Atlantis p.127-128';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~007-atlantis-lesser-rune-weapon-price.sql');
