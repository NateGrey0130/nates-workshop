-- Attack Disease and Transfer I.S.P.: where they are printed, and why the
-- Healing Shaman does not get them.
--
-- The Healing Shaman (Spirit West printed 60-62) gains "all the remaining
-- Healing powers" at level 2. Its import stored the ten Healing rows that cite
-- Rifts Ultimate Edition and left these two out because their catalog rows
-- carry NO source - "rather than granted on a guess". That was the right call
-- for the wrong recorded reason.
--
-- Read from the cache 2026-09-11: both are Palladium Fantasy Healing powers.
-- The Palladium Fantasy RPG Main Book lists them on printed 162 and describes
-- Attack Disease on printed 163 (cache p165) and Transfer I.S.P. on printed 164
-- (cache p166), at that book's +2 offset. Neither appears in Rifts Ultimate
-- Edition's Healing list, so a Rifts book's "remaining Healing powers" does
-- not include them and the class's grant is unchanged. The rows get their
-- citation, and the class note says why they are absent.
--
-- `system` stays NULL: psionic powers are deliberately cross-system (see
-- docs/catalog.md, "Which system a catalog row belongs to").

UPDATE psionic_powers SET source_book = 'Palladium Fantasy RPG Main Book p.163'
 WHERE name = 'Attack Disease' AND source_book IS NULL;
UPDATE psionic_powers SET source_book = 'Palladium Fantasy RPG Main Book p.164'
 WHERE name = 'Transfer I.S.P.' AND source_book IS NULL;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Attack Disease and Transfer I.S.P. carry no source in the catalog and are left out rather than granted on a guess.',
         'Attack Disease and Transfer I.S.P. are left out because they are Palladium Fantasy Healing powers (Palladium Fantasy RPG Main Book printed 163-164), not in the Rifts list this book grants.'),
       updated_at = datetime('now')
 WHERE class_id = 'healing-shaman' AND instr(markdown, 'carry no source in the catalog and are left out') > 0;

SELECT 'both powers cite their Palladium Fantasy page' AS assertion, count(*) AS got, 2 AS want
  FROM psionic_powers WHERE name IN ('Attack Disease', 'Transfer I.S.P.')
   AND source_book IN ('Palladium Fantasy RPG Main Book p.163', 'Palladium Fantasy RPG Main Book p.164');
SELECT 'no Healing power is left without a source' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers WHERE category = 'Healing' AND source_book IS NULL;
SELECT 'the Healing Shaman no longer calls them unsourced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'healing-shaman'
   AND instr(markdown, 'carry no source in the catalog') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-sw-healing-powers-source.sql');
