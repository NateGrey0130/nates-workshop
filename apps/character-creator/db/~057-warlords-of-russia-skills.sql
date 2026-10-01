-- Rifts World Book 17: Warlords of Russia, batch 1: the skills.
-- Five new rows, and two 'Rifts Skill List' rows get the page that defines them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~057-warlords-of-russia-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~057-warlords-of-russia-skills.sql
--
-- THE AUTHORITY is the book's own skill list (printed 190-191), which flags
-- each skill it calls new. 58 names were diffed against production with
-- scripts/catalog-diff.mjs --remote on 2026-10-01: 15 came back missing and 10
-- of those are rows the catalog already holds under its own spelling (the
-- survey, apps/character-creator/docs/surveys/warlords-of-russia.md, lists
-- each pair). The catalog's spelling and figures stand for those ten; nothing
-- here touches them.
--
-- THE FIVE, each read off the cache (offset +1, scripts/books.json):
--
--   Lore: History of Russia   cache p199, printed 198. Base Skill 30% +5%.
--                             Technical, where the catalog files Lore skills.
--   Lore: General Law         cache p199, printed 198. Base Skill 25% +5%.
--                             NOT the catalog's Law (RUE, 35/5): this one is
--                             the law and custom of the Russian frontier, at
--                             its own figure, under its own printed name.
--   W.P. Net                  cache p200, printed 199. No percentage.
--   W.P. Siege Weapons        cache p201, printed 200. No percentage.
--                             The Druid and the Priest of Light carry an
--                             except naming 'W.P. Siege' ahead of a row; this
--                             is not that row. It is tagged rifts only and is
--                             named as this book prints it.
--   W.P. Trick Shooting       cache p201, printed 200. No percentage. The book
--                             says it is a modified version of New West's.
--
-- A W.P. legitimately carries base 0 and per_level 0. Its level bonuses are in
-- the note, as the other W.P. rows keep them; nothing derives them.
--
-- THE TWO RE-CITATIONS (REBUILD-AUDIT F16: 'Rifts Skill List' is not a book).
-- Every page of all 31 caches was searched for each name on 2026-10-01 and
-- this book is the only one that defines either:
--
--   Wingrider Flying Wing     cache p197, printed 196: Base Skill 15% +5%.
--                             Stored Pilot 15/5, which is what the page says.
--   Language: Mongolian       cache p199, printed 198: Base Skill 40% +5%.
--                             Stored Technical 40/5. The entry's own note
--                             (partial understanding for Russian, Chinese and
--                             Euro speakers) goes in the row's note. The
--                             Asian/Westerner split printed just above it
--                             belongs to Language: Chinese, not to this skill.
--
-- Each re-citation is guarded on the row's stored figures as well as its old
-- citation, so the page is cited only while the row says what the page says.
-- Trap Construction also cites the Skill List and is in this book, but
-- Coalition War Campaign prints it too and earlier; it is left alone here.
--
-- A `~` sorts after every `z` tier, so this runs after
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql (which would otherwise leave new rows
-- untagged on a clean rebuild) and after every file that wrote
-- 'Rifts Skill List'. Re-running it is a no-op.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: History of Russia', 'Technical', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 17: Warlords of Russia p.198',
        'Myth, legend and distorted history of Russia before and after the Rifts. The percentage is how much the character learned or recalls accurately.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: General Law', 'Technical', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 17: Warlords of Russia p.198',
        'Law, custom and punishment across the Russian frontier: the Warlords, Cossacks and Sovietski, the codes of the War-Knight and Huntsman, villages and major cities.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('W.P. Net', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 17: Warlords of Russia p.199',
        '+1 to strike or entangle at levels 2, 5, 8, 11 and 15. +1 to parry at levels 2, 4, 6, 9 and 12. Trips as a grappling hook does. A natural 18-20 snares and disarms a weapon unless met by an equal natural parry. A thrown net must be dodged (parried only with a spear, pole-arm or staff); a netted victim is -8 to strike, -10 to parry and dodge, cannot run, and needs 1D4+1 melee rounds to cut free. Throwing takes two hands. Used as a whip it does 1D4 damage.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('W.P. Siege Weapons', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 17: Warlords of Russia p.200',
        'Ballista, catapult, onager and trebuchet: tactics, use and mechanics. +1 to strike at levels 2, 5, 9 and 12.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('W.P. Trick Shooting', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 17: Warlords of Russia p.200',
        'Six tricks: (1) fire a two-handed weapon one-handed without penalty; (2) shoot over the shoulder by mirror at half strike bonus (a Cossack keeps full); (3) shoot from a horse or moving vehicle at half strike bonus, no called shot; (4) shoot upside down at full bonus; (5) dodge, roll or somersault and come up shooting on a straight roll; (6) ricochet shot at half strike bonus, 1 point to the first surface. Most Men at Arms pick one, or roll 1D6; the Cossack gets all six; the class entry says when a class gets more. Applies only to a modern or archery W.P. the character has. Not for robots, master psionics, practitioners of magic or supernatural beings. Juicers, Crazies and Borgs get one trick at most. Never a Secondary skill.');

UPDATE skills
   SET source_book = 'Rifts World Book 17: Warlords of Russia p.196'
 WHERE name = 'Wingrider Flying Wing' AND source_book = 'Rifts Skill List'
   AND category = 'Pilot' AND base = 15 AND per_level = 5;

UPDATE skills
   SET source_book = 'Rifts World Book 17: Warlords of Russia p.198',
       note = CASE WHEN coalesce(note, '') = '' THEN 'Russian or Chinese speakers pick out words and phrases at about 35%; Euro speakers at 10%.' ELSE note END
 WHERE name = 'Language: Mongolian' AND source_book = 'Rifts Skill List'
   AND category = 'Technical' AND base = 40 AND per_level = 5;

-- Readbacks: each must return got = want. This script asserts its OWN rows.
SELECT 'the two lore skills are in at the printed figures' AS assertion, count(*) AS got, 2 AS want
  FROM skills
 WHERE category = 'Technical' AND per_level = 5 AND source_book = 'Rifts World Book 17: Warlords of Russia p.198'
   AND ((name = 'Lore: History of Russia' AND base = 30) OR (name = 'Lore: General Law' AND base = 25));

SELECT 'the three W.P.s are in with no percentage' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE name IN ('W.P. Net', 'W.P. Siege Weapons', 'W.P. Trick Shooting')
   AND category = 'Weapon Proficiencies' AND base = 0 AND per_level = 0
   AND source_book LIKE 'Rifts World Book 17: Warlords of Russia p.%';

SELECT 'Wingrider Flying Wing cites printed 196' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Wingrider Flying Wing' AND base = 15 AND per_level = 5
   AND source_book = 'Rifts World Book 17: Warlords of Russia p.196';

SELECT 'Language: Mongolian cites printed 198' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Language: Mongolian' AND base = 40 AND per_level = 5
   AND source_book = 'Rifts World Book 17: Warlords of Russia p.198';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~057-warlords-of-russia-skills.sql');
