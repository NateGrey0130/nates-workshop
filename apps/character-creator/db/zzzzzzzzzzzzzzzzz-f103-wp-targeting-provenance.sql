-- BOOK-INGEST-AUDIT F103. The catalog's `W.P. Targeting` is Rifts Ultimate
-- Edition's entry, word for word, filed under Palladium Fantasy - so a
-- Palladium Fantasy character has been getting RUE's four strike bonuses where
-- that book prints six.
--
-- TWO HALVES, ONE SCRIPT, because the second is meaningless without the first.
-- The citation is corrected to the book the stored text actually came from,
-- and Palladium Fantasy gets its own schedule through the per-system override
-- F102 built for exactly this.
--
-- WHAT THE BOOKS PRINT, read from the caches on this machine and checked
-- against each page's OWN printed folio rather than against an offset:
--
--   RUE printed 328 (cache rue p331, folio "328" on the page):
--     "+1 to strike at levels 1, 3, 7 and 10", thrown and projectile but not
--     bows, crossbows or guns; two small items at one target; requires any one
--     missile-weapon W.P. -- which is the stored row, clause for clause.
--
--   Palladium Fantasy printed 61 (cache pf p063, folio "61" on the page),
--   where the skill is called "W.P. Targeting/Missile Weapons":
--     "+1 to strike at levels 1, 3, 5, 7, 10, and 13."
--
-- PRINTED 61, NOT 49. The finding said 49 and that number came from a shell
-- doing base-8 arithmetic on a zero-padded page number - `063` is octal 51.
-- Palladium Fantasy printed 84, which the row cited, carries the bare string
-- `W.P. Targeting` inside an O.C.C.'s skill list and defines nothing, which is
-- what REBUILD-AUDIT F14 saw and declined to choose between without reading
-- both books. The reading is done; this is the result.
--
-- WHAT IS DROPPED, deliberately and named rather than postponed: Palladium
-- Fantasy also grants +1 to strike at levels 2, 5 and 10 to a character who
-- ALSO holds W.P. bow, crossbow or spear. `level_bonuses` cannot express a
-- bonus conditional on holding another skill, so it is carried as prose in the
-- note and nowhere else.
--
-- NO RENAME. Palladium Fantasy's name for it is `W.P. Targeting/Missile
-- Weapons`; the Nightbane survey's D6 set the precedent that a book's own
-- spelling resolves to the existing row rather than creating a second one.

-- -- 1. The citation says which book the text is from ----------------------
--
-- `skills.source_book` is read by drift-check.mjs and source-coverage.mjs,
-- which BUCKET a row by the book it cites and then search that whole book's
-- cached text - not the cited page - so this row moves from the `pf` bucket to
-- the `rue` bucket and is found in both. It also rides in /catalogs for the
-- pickers' filter, so a player filtering skills by "Palladium" stops matching
-- this row: correct, because the row is RUE's.

-- NOT GUARDED ON THE OLD VALUE, because there are two old values and the
-- pre-flight is what found the second one. PRODUCTION holds 'Palladium Fantasy
-- RPG Main Book p.84'; a database built from this repo holds 'Rifts Ultimate
-- Edition', with no page. That is the disagreement REBUILD-AUDIT F14 recorded
-- and deliberately left alone - and the rebuild has been citing the RIGHT BOOK
-- all along, just without the page.
--
-- A guard on p.84 therefore fired on production and silently did nothing in a
-- fresh build, which is how this script failed its own read-back in the
-- scratch replay before it went anywhere near production. Guarding on the NAME
-- alone converges the two for the first time.

UPDATE skills
   SET source_book = 'Rifts Ultimate Edition p.328'
 WHERE name = 'W.P. Targeting';

-- -- 2. Palladium Fantasy's own schedule -----------------------------------
--
-- Guarded on the primary key so re-running is a no-op, and on the catalog row
-- existing, so an environment that has not seen the skill adds nothing rather
-- than failing. Same shape as F102's two rows.
--
-- REPLACE, NOT MERGE: js/skill-base.js substitutes `level_bonuses` wholesale
-- when an override carries one, which is what F102 pinned. A merge would give
-- a level-13 Palladium Fantasy character both books' bonuses.

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, level_bonuses, note, source_book)
SELECT 'W.P. Targeting', 'palladium-fantasy',
       '[{"level":1,"applies_when":"when thrown or slung","combat":{"strike":1}},{"level":1,"note":"Palladium Fantasy prints this as W.P. Targeting/Missile Weapons: sling, sling-shot, bolas, boomerangs, throwing sticks, small throwing axes, throwing knives, shurikens, javelin and spear. The bow is a separate skill - see W.P. Archery. A character who also holds W.P. bow, crossbow or spear gets that W.P.''s usual bonuses PLUS +1 to strike at levels 2, 5 and 10 from this one; that pairing is not stored, because a bonus conditional on holding another skill cannot be expressed here. Rate of fire equals the character''s hand to hand attacks. All bonuses are lost and the rate of fire halved on horseback or in a moving vehicle."},{"level":3,"applies_when":"when thrown or slung","combat":{"strike":1}},{"level":5,"applies_when":"when thrown or slung","combat":{"strike":1}},{"level":7,"applies_when":"when thrown or slung","combat":{"strike":1}},{"level":10,"applies_when":"when thrown or slung","combat":{"strike":1}},{"level":13,"applies_when":"when thrown or slung","combat":{"strike":1}}]',
       'Palladium Fantasy prints six strike bonuses where the catalog row - which is Rifts Ultimate Edition''s entry - prints four. The catalog row keeps RUE''s, and this override carries Palladium Fantasy''s.',
       'Palladium Fantasy RPG Main Book p.61'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Targeting');

-- Read the result back. This batch asserts its OWN rows and nothing else.

SELECT 'the citation names the book the text came from' AS assertion, count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'W.P. Targeting' AND source_book = 'Rifts Ultimate Edition p.328';

SELECT 'Palladium Fantasy has its own schedule' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases
 WHERE skill_name = 'W.P. Targeting' AND system = 'palladium-fantasy'
   AND level_bonuses IS NOT NULL AND json_valid(level_bonuses);

SELECT 'and it prints six strike bonuses' AS assertion, count(*) AS got, 6 AS want
  FROM skill_system_bases, json_each(skill_system_bases.level_bonuses)
 WHERE skill_name = 'W.P. Targeting' AND system = 'palladium-fantasy'
   AND json_extract(json_each.value, '$.combat.strike') = 1;

SELECT 'the catalog row keeps RUE''s four' AS assertion, count(*) AS got, 4 AS want
  FROM skills, json_each(skills.level_bonuses)
 WHERE skills.name = 'W.P. Targeting'
   AND json_extract(json_each.value, '$.combat.strike') = 1;

SELECT 'and Heroes Unlimited is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases
 WHERE skill_name = 'W.P. Targeting' AND system = 'heroes-unlimited';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzz-f103-wp-targeting-provenance.sql');
