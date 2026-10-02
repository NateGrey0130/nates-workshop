-- Rifts World Book 19: Australia, batch 1: the skills. Fourteen new rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~059-australia-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~059-australia-skills.sql
--
-- THE AUTHORITY is the book's own skill list (printed 151-152), which marks
-- each skill it calls new and files it under a category. 54 names (the list's
-- new marks plus the description headings, which add Kayaking) were diffed
-- against production with scripts/catalog-diff.mjs --remote on 2026-10-01: 34
-- matched and 20 came back missing. Each of the 20 was then read against its
-- description (printed 153-162) and against the catalog row nearest to it.
--
-- FIVE OF THE 20 ARE ROWS THE CATALOG ALREADY HOLDS under its own spelling,
-- at the figure this book prints. The catalog's spelling stands and nothing
-- here touches them:
--
--   Kayaking (50/5)                     = Boat: Paddle Types/Canoe/Kayak (50/5)
--   Weapons Armorer (40/5)              = Field Armorer & Munitions Expert (40/5)
--   Find Contraband, Parts & Relics     = Find Contraband (26/4); the book
--     (26/4)                              calls its own entry a variation of it
--   Outback Combat Driving (no %)       = Combat Driving (0/0)
--   W.P. Flamethrower (no %)            = W.P. Military Flamethrowers (0/0)
--
-- ONE MORE IS TWO NAMES FOR ONE SKILL. The list prints the Kwarla and the
-- Aboriginal languages on one line and the description (printed 158) gives
-- them a single percentage, so they are one row, Language: Aboriginal.
--
-- THE FOURTEEN, each read off the cache (offset +1, scripts/books.json):
--
--   Corroboree                          cache p155, printed 154. 30% +4%.
--   Rock Painting & Engraving           cache p155, printed 154. 36% +4%.
--   Play Aboriginal Musical Instrument  cache p155, printed 154. 25% +5%.
--   Road Train                          cache p158, printed 157. 40% +4%.
--   Language: Aboriginal                cache p159, printed 158. 35% +5%.
--   Language: Australian English        cache p159, printed 158. 50% +5%.
--   Language: Mokoloi                   cache p159, printed 158. 40% +5%.
--   Lore: Aborigines                    cache p159, printed 158. 25% +5%.
--   Lore: Cities                        cache p160, printed 159. 20% +5%.
--                                       The description heads it "Lore: The
--                                       Cities"; the list's name is used.
--   Lore: Dreamtime Culture             cache p160, printed 159. 20% +5%.
--   Blend                               cache p160, printed 159. 14% +4%.
--   Outback Survival                    cache p161, printed 160. 58% +2%.
--   Use Songlines                       cache p161-p162, printed 160-161.
--                                       TWO percentages: 30% +4% to perform
--                                       it, 20% +2% to interpret. The first is
--                                       stored, as Brewing and Breed Dogs
--                                       store theirs; the second is in the
--                                       note.
--   W.P. Boomerang                      cache p162, printed 161. No percentage.
--
-- CATEGORIES are the list's, in the catalog's vocabulary: the three Lore
-- skills go under Technical, where the catalog files Lore. The list files
-- Lore: Aborigines under both Cowboy and Technical; its description is under
-- Technical. A W.P. carries base 0 and per_level 0 and keeps its level
-- bonuses in the note.
--
-- systems is '["rifts"]' for eleven rows and NULL for the three languages,
-- which is how every other Language row is stored.
--
-- A `~` sorts after every `z` tier, so this runs after
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql. Re-running it is a no-op.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Corroboree', 'Domestic', 30, 4, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.154',
        'The Aboriginal song and dance, at least 10 minutes on clear ground. Away from a ley line a success counts as Meditation for healing and for recovering P.P.E. and I.S.P. On a Songline it is the first half of Use Songlines.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Rock Painting & Engraving', 'Domestic', 36, 4, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.154',
        'Aboriginal painting on bark, skin and rock. Each work tells a story or myth that only a character with this skill can read.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Play Aboriginal Musical Instrument', 'Domestic', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.154',
        'Didgeridoo, bush whistle and beat sticks. Other instruments are each their own Play Musical Instrument skill.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Road Train', 'Pilot', 40, 4, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.157',
        'Driving a cab that pulls four or five trailers. A character with Truck can try it at -30% and half maximum speed.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Language: Aboriginal', 'Technical', 35, 5, NULL, 'import',
        'Rifts World Book 19: Australia p.158',
        'Covers both the Aboriginal and the Kwarla languages, which are very similar. The G.M. may apply -10% to -20% for a distant dialect, especially more than 500 miles from where the character grew up.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Language: Australian English', 'Technical', 50, 5, NULL, 'import',
        'Rifts World Book 19: Australia p.158',
        'Outback English: the slang, accent and dialect spoken outside the Cities. The base is for D-Bees and outsiders. White Australians speak it at 80% or better, city dwellers at 90-98%. Other English speakers are -1D4x10% to follow it until used to it.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Language: Mokoloi', 'Technical', 40, 5, NULL, 'import',
        'Rifts World Book 19: Australia p.158',
        'The language of the Mokoloi of the Northlands. Most Mokoloi also speak Australian English; most southern people do not know the Mokoloi exist.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: Aborigines', 'Technical', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.158',
        'Recognize Aboriginal tribes, warriors, shamans, totems, fetishes and warnings, and know the most notable customs, beliefs and laws. Lore: Dreamtime Culture covers the gods, spirits and magic.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: Cities', 'Technical', 20, 5, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.159',
        'Laws, procedures, customs, politics and dress of the Tech-Cities, especially their military and police: what is illegal, recognizing soldiers, police and aircraft, estimating sentries and predicting guard responses. Aboriginal characters cannot take it.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: Dreamtime Culture', 'Technical', 20, 5, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.159',
        'Dreamtime myth, spirits, rituals and beliefs, and the gods, spirits and monsters tied to it. All Aboriginal characters get +20%, and for them it also gives Sense Supernatural Evil roughly equal to a Dog Boy or Psi-Stalker.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Blend', 'Wilderness', 14, 4, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.159',
        'Stay motionless and unseen in the bush, even inches from a searcher. Needs camouflage or natural cover; sensors, optics, magic and psionics defeat it. Not usable in combat, but good for an ambush. +4% with Prowl, +4% at night, +10% for Aboriginal characters, -10% when actively sought.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Outback Survival', 'Wilderness', 58, 2, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.160',
        'Wilderness Survival fitted to the Australian Outback: direction, time of day, distances, the seasons, and finding water and bush food. A character from elsewhere with Wilderness Survival is -15% in the Outback.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Use Songlines', 'Wilderness', 30, 4, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.160-161',
        'Two rolls. The stored percentage is performing the Corroboree on a ley line; interpreting what the line returns is a second roll at 20% +2% per level (+20% for Aborigines). Gives six effects: land navigation to one mile either side of the line per level, stories of major past events and warnings up to 24 hours ahead, hiding and finding caches within a mile of the line, finding water, exact distances along the line, and sending a story to listeners anywhere on it. City folk cannot learn it.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('W.P. Boomerang', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 19: Australia p.161',
        '+1 to strike at level 1 and again at levels 3, 5, 7, 10 and 15. +1 to damage at levels 2, 5, 9, 11 and 15. Opponents are -2 to parry and dodge. Returning throw 150 ft, the return taking one melee action. Straight shot 600 ft, +2 damage, target -4 to parry or dodge inside 100 ft. Back shot 250 ft, target -8, thrown with no bonuses and -3 against a hidden target. Bounce shot, target -4, and a strike roll of 16 or higher knocks the target down for two actions unless he rolls with impact. Ricochet off one target into a second with this W.P.''s bonuses only, second target -4. Catching one needs a called parry of 18 or higher and two actions.');

-- Readbacks: each must return got = want. This script asserts its OWN rows.
SELECT 'the three Domestic skills are in at the printed figures' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE category = 'Domestic' AND source_book = 'Rifts World Book 19: Australia p.154'
   AND ((name = 'Corroboree' AND base = 30 AND per_level = 4)
     OR (name = 'Rock Painting & Engraving' AND base = 36 AND per_level = 4)
     OR (name = 'Play Aboriginal Musical Instrument' AND base = 25 AND per_level = 5));

SELECT 'the three languages are in, untagged like every other language' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE category = 'Technical' AND per_level = 5 AND systems IS NULL
   AND source_book = 'Rifts World Book 19: Australia p.158'
   AND ((name = 'Language: Aboriginal' AND base = 35)
     OR (name = 'Language: Australian English' AND base = 50)
     OR (name = 'Language: Mokoloi' AND base = 40));

SELECT 'the three lore skills are in under Technical' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE category = 'Technical' AND per_level = 5 AND systems = '["rifts"]'
   AND ((name = 'Lore: Aborigines' AND base = 25 AND source_book = 'Rifts World Book 19: Australia p.158')
     OR (name = 'Lore: Cities' AND base = 20 AND source_book = 'Rifts World Book 19: Australia p.159')
     OR (name = 'Lore: Dreamtime Culture' AND base = 20 AND source_book = 'Rifts World Book 19: Australia p.159'));

SELECT 'Road Train and the three Wilderness skills are in at the printed figures' AS assertion, count(*) AS got, 4 AS want
  FROM skills
 WHERE source_book LIKE 'Rifts World Book 19: Australia p.%'
   AND ((name = 'Road Train' AND category = 'Pilot' AND base = 40 AND per_level = 4)
     OR (name = 'Blend' AND category = 'Wilderness' AND base = 14 AND per_level = 4)
     OR (name = 'Outback Survival' AND category = 'Wilderness' AND base = 58 AND per_level = 2)
     OR (name = 'Use Songlines' AND category = 'Wilderness' AND base = 30 AND per_level = 4));

SELECT 'W.P. Boomerang is in with no percentage' AS assertion, count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'W.P. Boomerang' AND category = 'Weapon Proficiencies' AND base = 0 AND per_level = 0
   AND source_book = 'Rifts World Book 19: Australia p.161';

SELECT 'fourteen skills cite this book' AS assertion, count(*) AS got, 14 AS want
  FROM skills WHERE source_book LIKE 'Rifts World Book 19: Australia p.%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~059-australia-skills.sql');
