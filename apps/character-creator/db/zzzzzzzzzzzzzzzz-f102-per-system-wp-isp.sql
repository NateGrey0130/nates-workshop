-- Two W.P. schedules and three psionic prices that another game prints its own
-- way. BOOK-INGEST-AUDIT F102, option A - the rows for migrations 075 and 076.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzzz-f102-per-system-wp-isp.sql
--
-- Every figure below was read off the book's page on 2026-09-19, from caches
-- rebuilt that morning (heroes-unlimited-core offset 0, nightbane-core offset 1,
-- both per scripts/books.json):
--
--   W.P. Targeting       Heroes Unlimited printed 36   +1 strike at 2, 4, 7, 10, 13;
--                                                      thrown weapons, slings AND bows
--   W.P. Archery         Nightbane printed 58          "W.P. Archery and Targeting":
--                                                      +1 parry at 1, +1 strike at 2, 4,
--                                                      6, 8, 11, 14; thrown and bows
--   Hypnotic Suggestion  Heroes Unlimited printed 133  2 I.S.P. per suggestion
--                        Nightbane printed 77 / 84     2 as Sensitive, 4 as Healer
--   Death Trance         Nightbane printed 72 / 78     2 as Sensitive, 1 as Physical
--
-- A SCHEDULE REPLACES THE ROW'S, it is not merged into it (applySystemBases,
-- js/skill-base.js), so each one below is the book's WHOLE progression - the
-- level 1 note included - and none of the catalog row's entries survive into it.
--
-- DEATH TRANCE STATES ONLY A NOTE. The catalog's 1 I.S.P. is the Physical
-- price, which Nightbane agrees with; the Sensitive entry charges 2. `isp` is
-- the minimum (migration 020), so it stays the catalog's and the note carries
-- the other price. Hypnotic Suggestion in Nightbane is the same shape the other
-- way round: 2 is the minimum and the Healer's 4 is the note.
--
-- NOT WRITTEN: which CATEGORY a power sits in per game. Hypnotic Suggestion is
-- Super in the catalog and Sensitive/Healer in Nightbane; the survey's D7 left
-- the category alone on purpose, and this finding is about price only.
--
-- SORTS AFTER F83's zzzzzzzz- scripts, which assert exactly 59 heroes-unlimited
-- rows in skill_system_bases; this file adds a sixtieth. The existing fifteen-z
-- tier is late enough, and nothing in it touches these tables.
--
-- Guarded on the primary key, so re-running is a no-op, and on the catalog row
-- existing, so a rename that has not reached this environment adds nothing
-- rather than failing the foreign key.

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, level_bonuses, note, source_book)
SELECT 'W.P. Targeting', 'heroes-unlimited',
       '[{"level":1,"note":"Thrown knives, throwing axes, thrown spears and forks, slings, and short, long and cross bows - bows included, where the catalog row excludes them. The strike bonus counts only for those weapons thrown or fired. Effective range +20 ft per level of experience (+10 ft for knives, darts and throwing axes)."},{"level":2,"applies_when":"with a thrown weapon, sling or bow","combat":{"strike":1}},{"level":4,"applies_when":"with a thrown weapon, sling or bow","combat":{"strike":1}},{"level":7,"applies_when":"with a thrown weapon, sling or bow","combat":{"strike":1}},{"level":10,"applies_when":"with a thrown weapon, sling or bow","combat":{"strike":1}},{"level":13,"applies_when":"with a thrown weapon, sling or bow","combat":{"strike":1}}]',
       'Heroes Unlimited prints its own W.P. Targeting: bows included, no strike bonus at level 1. Granted by fourteen Heroes Unlimited classes.',
       'Revised Heroes Unlimited p.36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Targeting');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, level_bonuses, note, source_book)
SELECT 'W.P. Archery', 'nightbane',
       '[{"level":1,"applies_when":"with a thrown or bow weapon","combat":{"parry":1}},{"level":1,"note":"Nightbane prints this as W.P. Archery and Targeting: thrown spears and forks, slings, and short, long, cross and modern bows. Effective range +20 ft (6.1 m) per level. Rate of fire two at level one, two more at level three, and one more at levels 5, 7, 9 and 12. All bonuses are lost and the rate of fire halved when riding a horse or a moving vehicle."},{"level":2,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}},{"level":4,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}},{"level":6,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}},{"level":8,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}},{"level":11,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}},{"level":14,"applies_when":"with a thrown or bow weapon","combat":{"strike":1}}]',
       'Nightbane''s W.P. Archery and Targeting, which the survey''s D6 resolved to this row. No strike bonus at level 1, where the Rifts row has one.',
       'Nightbane RPG p.58'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Archery');

INSERT OR IGNORE INTO psionic_system_costs (power_name, system, isp, isp_note, note, source_book)
SELECT 'Hypnotic Suggestion', 'heroes-unlimited', 2, NULL,
       'Charged per suggestion. Heroes Unlimited has no Super category; its classes name the power in a list.',
       'Revised Heroes Unlimited p.133'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Hypnotic Suggestion');

INSERT OR IGNORE INTO psionic_system_costs (power_name, system, isp, isp_note, note, source_book)
SELECT 'Hypnotic Suggestion', 'nightbane', 2, '4 as a Healer power',
       'Nightbane prints it twice as Suggestion (Hypnosis): 2 per idea as a Sensitive power, 4 as a Healer one after a melee round of meditation.',
       'Nightbane RPG p.77, p.84'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Hypnotic Suggestion');

INSERT OR IGNORE INTO psionic_system_costs (power_name, system, isp, isp_note, note, source_book)
SELECT 'Death Trance', 'nightbane', NULL, '2 as a Sensitive power',
       'Nightbane prints it twice: 1 as a Physical power, which is the catalog''s own price, and 2 as a Sensitive one.',
       'Nightbane RPG p.72, p.78'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Death Trance');

-- Read the result back. This batch asserts its OWN rows and nothing else.

SELECT 'two W.P. schedules written' AS assertion, count(*) AS got, 2 AS want
  FROM skill_system_bases WHERE level_bonuses IS NOT NULL
   AND ((skill_name = 'W.P. Targeting' AND system = 'heroes-unlimited')
     OR (skill_name = 'W.P. Archery' AND system = 'nightbane'));

SELECT 'each schedule parses, with its strike levels' AS assertion, count(*) AS got, 2 AS want
  FROM skill_system_bases
 WHERE (skill_name = 'W.P. Targeting' AND system = 'heroes-unlimited'
        AND (SELECT group_concat(json_extract(value, '$.level'), ',') FROM json_each(level_bonuses)
              WHERE json_extract(value, '$.combat.strike') = 1) = '2,4,7,10,13')
    OR (skill_name = 'W.P. Archery' AND system = 'nightbane'
        AND (SELECT group_concat(json_extract(value, '$.level'), ',') FROM json_each(level_bonuses)
              WHERE json_extract(value, '$.combat.strike') = 1) = '2,4,6,8,11,14');

SELECT 'three psionic prices written' AS assertion, count(*) AS got, 3 AS want
  FROM psionic_system_costs
 WHERE (power_name = 'Hypnotic Suggestion' AND system = 'heroes-unlimited' AND isp = 2 AND isp_note IS NULL)
    OR (power_name = 'Hypnotic Suggestion' AND system = 'nightbane' AND isp = 2 AND isp_note IS NOT NULL)
    OR (power_name = 'Death Trance' AND system = 'nightbane' AND isp IS NULL AND isp_note IS NOT NULL);

SELECT 'the catalog rows themselves are untouched' AS assertion, count(*) AS got, 2 AS want
  FROM psionic_powers
 WHERE (name = 'Hypnotic Suggestion' AND isp = 6) OR (name = 'Death Trance' AND isp = 1);

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzz-f102-per-system-wp-isp.sql');
