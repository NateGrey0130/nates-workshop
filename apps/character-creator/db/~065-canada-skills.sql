-- Rifts World Book 20: Canada, batch 1: the skills.
-- Six new rows, and two 'Rifts Skill List' rows get the page that defines them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~065-canada-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~065-canada-skills.sql
--
-- THE SOURCE is Winter Sports Skills, printed 36 (cache p037, offset +1,
-- scripts/books.json), with one sentence of the last entry running on to the
-- top of printed 37. The book has no master skill list; this half page is
-- the whole of it. The survey is apps/character-creator/docs/surveys/canada.md.
--
-- THE TWO RE-CITATIONS (REBUILD-AUDIT F16: 'Rifts Skill List' is not a book).
-- Every page of every cache under .cache/books was searched for both
-- definitions on 2026-10-02 and this book is the only one that prints either:
--
--   Ice Skating   Base Skill 35% +5%. Stored Physical 35/5, as the page says.
--   Snow Skiing   Base Skill 40% +5%. Stored Physical 40/5, as the page says.
--
-- Each is guarded on the row's stored figures as well as its old citation, so
-- the page is cited only while the row says what the page says. Their notes
-- are left as they are.
--
-- THE SIX SPECIALISATIONS, rows of their own (Nate's decision, 2026-10-01,
-- recorded in the survey). The book calls them Professional Status. Each one
-- needs its base skill, costs one extra O.C.C. Related selection, and cannot
-- be taken as a Secondary Skill; that rule is in every row's note because
-- nothing in a skill row enforces it.
--
--   Ice Skating: Figure Skating      +20% to skating, so 55/5
--   Ice Skating: Pro Hockey Skating  +15% to skating, so 50/5
--   Ice Skating: Speed Skating       +10% to skating, so 45/5
--   Snow Skiing: Downhill Speed Skiing/Slalom   no percentage added, 40/5
--   Snow Skiing: Cross-Country Skiing           no percentage added, 40/5
--   Snow Skiing: Snowboarding & Jump Skiing     no percentage added, 40/5
--
-- base is the base skill's figure plus the specialisation's printed bonus,
-- so the row reads as the proficiency the character rolls. `bonuses` holds
-- only the fixed, unconditional attribute and roll bonuses (migration 023);
-- dice, the S.D.C. pool, and anything that applies only on ice or on the
-- slopes stay in the note.
--
-- The three pilot entries on printed 37 are notes on skills the catalog
-- already holds under their Ultimate Edition names (Hovercycles, Skycycles &
-- Rocket Bikes; Motorcycles & Snowmobiles; Tracked & Construction Vehicles).
-- Nothing here touches them.
--
-- A `~` sorts after every `z` tier, so this runs after
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql and after every file that wrote
-- 'Rifts Skill List'. Re-running it is a no-op.

UPDATE skills
   SET source_book = 'Rifts World Book 20: Canada p.36'
 WHERE name = 'Ice Skating' AND source_book = 'Rifts Skill List'
   AND category = 'Physical' AND base = 35 AND per_level = 5;

UPDATE skills
   SET source_book = 'Rifts World Book 20: Canada p.36'
 WHERE name = 'Snow Skiing' AND source_book = 'Rifts Skill List'
   AND category = 'Physical' AND base = 40 AND per_level = 5;

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Ice Skating: Figure Skating', 'Physical', 55, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36',
        'Professional Status for Ice Skating: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Quick stops, hops, running, leaps and spins on ice. Also +1D4 S.D.C., +5% to Dance, +1 to damage with kick and leap attacks and +2 to maintain balance. Skating speed is three times running speed.',
        '{"attributes":{"PP":1,"PE":1,"Spd":2},"combat":{"roll":1}}');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Ice Skating: Pro Hockey Skating', 'Physical', 50, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36',
        'Professional Status for Ice Skating: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Quick stops and combat on ice without losing balance: punches, knee jabs (no kicks or leaps), disarm, entangle, grapple, body block, body flip, and any Ancient W.P. but bow or sling. Also +1D4 Spd, +2D6 S.D.C., +1 to damage in hand to hand, +2 to maintain balance, gets W.P. Staff/Hockey Stick, and +1 to strike on ice with a body block or stick. Skating speed is four times running speed.',
        '{"attributes":{"PS":1,"PE":1},"combat":{"roll":2}}');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Ice Skating: Speed Skating', 'Physical', 45, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36',
        'Professional Status for Ice Skating: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Speed and endurance on skates, and quick stops. Also +1D6 Spd, +1D6 S.D.C., +2 to damage with kick attacks, +5 to dodge on ice and +2 to maintain balance. Skating speed is six times running speed.',
        '{"attributes":{"PS":1,"PE":1},"combat":{"roll":1}}');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Snow Skiing: Downhill Speed Skiing/Slalom', 'Physical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36',
        'Professional Status for Snow Skiing: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Also +2 to maintain balance. Downhill up to 70 mph (112.6 km); cross-country at normal running speed.',
        '{"attributes":{"PP":1,"PE":1},"combat":{"initiative":1,"roll":2}}');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Snow Skiing: Cross-Country Skiing', 'Physical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36',
        'Professional Status for Snow Skiing: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Also +1D4 Spd, +1D6 S.D.C. and +1 to maintain balance. Cross-country is 20% faster than running speed. Downhill is unfamiliar: safe to 20 mph (32 km), -30% when faster and a further -10% per 10 mph over 50.',
        '{"attributes":{"PS":1,"PE":2},"combat":{"roll":1}}');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses)
VALUES ('Snow Skiing: Snowboarding & Jump Skiing', 'Physical', 40, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.36-37',
        'Professional Status for Snow Skiing: needs that skill, costs one extra O.C.C. Related selection, and cannot be a Secondary Skill. Also +1D6 S.D.C.; on the slopes +3 on initiative and +3 to maintain balance. Quick stops, hops, leaps, aerial somersaults and ricochets on a snowboard or skateboard at -10%. Snowboard downhill to 60 mph (96.5 km), skis to 70 mph (112.6 km); a ski jump carries up to 300 feet (91.5 m). Cross-country is 20% slower than running speed.',
        '{"attributes":{"PP":1},"combat":{"roll":3}}');

-- Readbacks: each must return got = want. This script asserts its OWN rows.
SELECT 'Ice Skating and Snow Skiing cite printed 36' AS assertion, count(*) AS got, 2 AS want
  FROM skills
 WHERE source_book = 'Rifts World Book 20: Canada p.36' AND category = 'Physical' AND per_level = 5
   AND ((name = 'Ice Skating' AND base = 35) OR (name = 'Snow Skiing' AND base = 40));

SELECT 'the three skating specialisations are in at base plus bonus' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE category = 'Physical' AND per_level = 5 AND source_book = 'Rifts World Book 20: Canada p.36'
   AND ((name = 'Ice Skating: Figure Skating' AND base = 55)
     OR (name = 'Ice Skating: Pro Hockey Skating' AND base = 50)
     OR (name = 'Ice Skating: Speed Skating' AND base = 45));

SELECT 'the three skiing specialisations are in at the base figure' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE category = 'Physical' AND base = 40 AND per_level = 5
   AND source_book LIKE 'Rifts World Book 20: Canada p.36%'
   AND name IN ('Snow Skiing: Downhill Speed Skiing/Slalom', 'Snow Skiing: Cross-Country Skiing', 'Snow Skiing: Snowboarding & Jump Skiing');

SELECT 'no skill still cites the Skill List for a skill this book defines' AS assertion, count(*) AS got, 0 AS want
  FROM skills WHERE source_book = 'Rifts Skill List' AND name IN ('Ice Skating', 'Snow Skiing');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~065-canada-skills.sql');
