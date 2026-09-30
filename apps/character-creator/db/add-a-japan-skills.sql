-- The 19 skills Rifts World Book 8: Japan adds that the catalog does not already hold
-- under any name: four Domestic skills, Japanese Mythology, six W.P.s and eight
-- Hand to Hand styles.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-japan-skills.sql
--
-- TEXT LAYER, page_offset +1 (scripts/books.json): printed F is cache p<F+1>.
-- Extracted by two book-extract-workers and checked row by row by
-- book-reconcile against the cache. The survey is
-- apps/character-creator/docs/surveys/japan.md.
--
-- NAMES come from the printed 187 list, which names every new skill, not from
-- the entry headings: Poetry (Haiku), Floral Arrangement (Ikebana), W.P. Mouth
-- Weapons (Blow Guns), W.P. Cross Bow, Hand to Hand: Basic Martial Arts/Judo
-- and Hand to Hand: Ninjitsu are what the list and the book's class skill lists
-- print. A class names a skill by its exact name.
--
-- 36 ON THE LIST, 19 HERE. The other 17 are already in the catalog: 11 under
-- the same name, W.P. Forked/Trident as W.P. Forked, and four under RUE's
-- names - Armorer (Field Armorer & Munitions Expert), NBC (NBC Warfare), Find
-- Contraband, Weapons & Cybernetics (Find Contraband) and Imitate
-- Voices/Impersonation (split by RUE into two). Gardening (34% here, 36% in
-- RUE) and Horsemanship: Exotic Animals (+4% here, +5% in RUE) disagree with
-- the RUE rows they match; the RUE rows stand.
--
-- W.P. BOW AND W.P. CROSS BOW are their own rows rather than W.P. Archery,
-- by Nate's decision on 2026-09-30 (survey, *Agreed with Nate*).
--
-- A STYLE'S ATTRIBUTE BONUSES go in `bonuses.attributes`; a dice-valued bonus
-- (+2D4 S.D.C., +1D4 M.E.) cannot be stored there - a skill can be taken at
-- any level, so there is no moment to roll it - and is stated in the note,
-- as Boxing's +3D6 S.D.C. is. A conditional parry ("with a sword or staff")
-- is an `applies_when` entry, so it never reaches the unarmed combat block.
--
-- It SORTS FIRST among this book's scripts (add-a-), before the class scripts
-- that will grant these rows by name. systems is written here as ["rifts"];
-- a clean build then clears every skill's systems in
-- fix-pf-armor-and-cross-system-gear.sql, and the tilde script beside this one
-- re-tags these 19 after that. Production keeps the tag written here.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Bonsai', 'Domestic', 50, 4, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.187',
        'Tending, trimming and growing miniature bonsai trees; an expert can tell young trees from truly ancient ones and estimate a tree''s value and quality. A common pastime of the New Empire''s noble castes.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Floral Arrangement (Ikebana)', 'Domestic', 30, 3, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.187',
        'The artful arrangement of flowers, prized throughout the orient and years in the mastering; a poor arrangement is scorned even from a hero. Appreciated in both modern and traditional Japan.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Go', 'Domestic', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.187',
        'The strategy game the eastern world holds as its most enlightening, as chess is in the west. Skill at Go is often valued above fighting ability.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Poetry (Haiku)', 'Domestic', 35, 5, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.187',
        'Composing good, sometimes inspirational, poetry - chiefly haiku, Japan''s short three-line national form. Poetry marks important events in society.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Japanese Mythology', 'Technical', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.189',
        'Broad knowledge of Japanese myth: ghosts, spirits, oni, goblins, faerie folk, monsters, dragons, immortals, undead, elemental forces, supernatural animals and the Buddhist and Shinto gods. Chinese Buddhist gods and demons at -10%; Hindu and Brahmin gods at -20%.',
        NULL,
        NULL);

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Bow', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        'Rifts Japan''s own bow proficiency, kept as its own row rather than folded into RUE''s W.P. Archery (agreed 2026-09-30).',
        NULL,
        '[{"level":1,"applies_when":"with a bow","combat":{"strike":1}},{"level":1,"note":"Short, long, samurai, Mongol and ninja bows and modern compound bows. Two shots per melee round at first level, plus one more at levels 2, 4, 5, 8, 10, 12 and 14; shots are independent of the character''s hand to hand attacks."},{"level":2,"applies_when":"with a bow","combat":{"strike":1}},{"level":4,"applies_when":"with a bow","combat":{"strike":1}},{"level":7,"applies_when":"with a bow","combat":{"strike":1}},{"level":10,"applies_when":"with a bow","combat":{"strike":1}},{"level":13,"applies_when":"with a bow","combat":{"strike":1}},{"level":15,"applies_when":"with a bow","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Cross Bow', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        'Rifts Japan''s own crossbow proficiency (the entry heading prints W.P. Crossbow; the printed 187 list, which names the skills, prints Cross Bow). Kept as its own row (agreed 2026-09-30).',
        NULL,
        '[{"level":1,"note":"Heavy and light crossbows. One shot per melee round at first level, plus one more at levels 2, 5, 7, 9, 11, 13 and 15."},{"level":2,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":4,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":6,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":8,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":10,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":12,"applies_when":"with a crossbow","combat":{"strike":1}},{"level":14,"applies_when":"with a crossbow","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Mouth Weapons (Blow Guns)', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        NULL,
        NULL,
        '[{"level":1,"applies_when":"with a blow gun or mouth dart","combat":{"strike":1}},{"level":1,"note":"Blowpipes, mouth darts and similar weapons fired by the user''s breath. An extra shot per melee round at levels 3, 7 and 11."},{"level":4,"applies_when":"with a blow gun or mouth dart","combat":{"strike":1}},{"level":8,"applies_when":"with a blow gun or mouth dart","combat":{"strike":1}},{"level":12,"applies_when":"with a blow gun or mouth dart","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Slingshot', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        NULL,
        NULL,
        '[{"level":1,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":1,"note":"Ancient slings and modern slingshots. Two shots per melee round at first level, plus one more at each level that adds a strike bonus (2, 4, 6, 8, 10, 12 and 15)."},{"level":2,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":4,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":6,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":8,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":10,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":12,"applies_when":"with a sling or slingshot","combat":{"strike":1}},{"level":15,"applies_when":"with a sling or slingshot","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Small Thrown Weapons', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        NULL,
        NULL,
        '[{"level":1,"note":"Shuriken, throwing spikes and similar small thrown weapons. Three throws per melee round at first level, plus one more at levels 2, 3, 5, 6, 8, 9, 11, 12, 14 and 15."},{"level":4,"applies_when":"throwing a small weapon","combat":{"strike":1}},{"level":7,"applies_when":"throwing a small weapon","combat":{"strike":1}},{"level":10,"applies_when":"throwing a small weapon","combat":{"strike":1}},{"level":13,"applies_when":"throwing a small weapon","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('W.P. Grenade Launcher', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.190',
        NULL,
        NULL,
        '[{"level":1,"note":"Any device that fires grenades, including rifle-mounted launchers and pump weapons."},{"level":3,"applies_when":"with a grenade launcher","combat":{"strike":1}},{"level":7,"applies_when":"with a grenade launcher","combat":{"strike":1}},{"level":11,"applies_when":"with a grenade launcher","combat":{"strike":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Zanji Shinjinken-Ryo', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.47',
        'Exclusive to the True Samurai O.C.C.: an ancient samurai sword school built to kill rather than wound, the sword treated as an extension of the swordsman. Taught only to true samurai; the O.C.C. requires it of male samurai with no alternative (printed 48). Also gives +3D6 S.D.C.',
        '{"attributes":{"ME":2,"PP":2,"PE":1}}',
        '[{"level":1,"combat":{"attacks_base":2,"initiative":2,"roll":2,"dodge":3,"damage_bonus":2,"pull_punch":2},"note":"Knife hand (2D4), paired weapons."},{"level":1,"applies_when":"parrying with a sword or staff","combat":{"parry":2}},{"level":2,"combat":{"attacks":1,"disarm":1},"note":"+1 to maintain balance."},{"level":3,"combat":{"initiative":1,"strike":1,"parry":1},"note":"Critical strike from behind; death blow on a natural 20."},{"level":4,"combat":{"attacks":1,"damage_bonus":2}},{"level":5,"note":"Critical strike on a natural 18-20; +1 to maintain balance."},{"level":6,"combat":{"roll":1,"dodge":1},"note":"+1 to maintain balance."},{"level":7,"note":"Power punch or stab (hand or sword), jump kick, backward sweep kick."},{"level":8,"combat":{"attacks":1,"dodge":1}},{"level":9,"note":"Death blow."},{"level":10,"combat":{"initiative":1,"horror_factor":1},"note":"+1 to maintain balance."},{"level":11,"combat":{"attacks":1}},{"level":12,"combat":{"damage_bonus":2,"horror_factor":1},"note":"The knowledge and skill to make a true samurai sword."},{"level":13,"combat":{"attacks":1}},{"level":14,"combat":{"disarm":1},"note":"Double existing P.P.E. (inner spirit)."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Ninjitsu', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.53',
        'Exclusive to the Mystic Ninja O.C.C. (printed as Ninjutsu/Tai-Jutsu): the ninja assassin''s art of acrobatics, paired weapons and death blows. Taught only within a clan.',
        '{"attributes":{"MA":2,"PS":1,"PE":1,"PP":1,"Spd":4}}',
        '[{"level":1,"combat":{"attacks_base":2,"roll":2,"initiative":2,"parry":1,"dodge":2,"pull_punch":2},"note":"Snap kick (1D6), knife hand (2D4), paired weapons."},{"level":2,"combat":{"strike":1},"note":"Cartwheel attack; back flip escape, defensive and attack."},{"level":3,"combat":{"attacks":1},"note":"Palm strike (2D4)."},{"level":4,"note":"Leap attack, axe kick; +2 to strike when performing any back flip or cartwheel."},{"level":5,"combat":{"damage_bonus":2},"note":"Tripping/leg hook and backward sweep kicks."},{"level":6,"combat":{"attacks":1},"note":"Roundhouse kick (3D6)."},{"level":7,"note":"Critical strike on a natural 18-20 or from behind; death blow on a natural 20."},{"level":8,"combat":{"initiative":1,"strike":1,"parry":1,"roll":1},"note":"+2 to maintain balance."},{"level":9,"note":"Death blow."},{"level":10,"combat":{"attacks":1,"pull_punch":2}},{"level":11,"note":"Double existing P.P.E. (inner spirit)."},{"level":12,"combat":{"initiative":1,"roll":2}},{"level":13,"combat":{"damage_bonus":2,"disarm":1}},{"level":14,"combat":{"damage_bonus":2},"note":"Jump kick; +2 to back flip and cartwheel."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Teng-jutsu', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.69',
        'The tengu''s own fighting art, heavy on kicks, back flips and a leap that serves as a dodge. Rare among mortals: learned only from a tengu or a 12th-level master, and a human gets weaker versions of its powers (printed 69-70).',
        NULL,
        '[{"level":1,"combat":{"attacks_base":2,"dodge":2,"pull_punch":2,"disarm":1,"roll":1},"note":"+3 to maintain balance, +1 to break fall. Karate kick, jump kick, leap kick/attack and all other kicks, and all the style''s special powers."},{"level":2,"combat":{"initiative":1},"note":"Drop kick; +2 on all back flips."},{"level":3,"combat":{"strike":1,"disarm":1},"note":"+1 to leap dodge."},{"level":4,"combat":{"attacks":1}},{"level":5,"note":"Critical strike (double damage) from all kicks, jump kicks and leap attacks."},{"level":6,"combat":{"roll":1,"pull_punch":2},"note":"+1 to leap dodge."},{"level":7,"combat":{"initiative":1},"note":"Tripping/leg hook and backward sweep kicks."},{"level":8,"combat":{"attacks":1}},{"level":9,"combat":{"disarm":2},"note":"+1 on all back flips and on cartwheel attack."},{"level":10,"combat":{"initiative":1,"parry":1},"note":"Axe kick."},{"level":11,"combat":{"attacks":1}},{"level":12,"combat":{"disarm":1},"note":"+1 to leap dodge."},{"level":13,"note":"Snap kick and wheel kick."},{"level":14,"combat":{"pull_punch":1},"note":"+1 to leap dodge."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Basic Martial Arts/Judo', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.193',
        'The modern, judo-equivalent style of the Republic''s military and police: throws and disarms, with a karate kick from level 4. Also gives +2D4 S.D.C.',
        '{"attributes":{"ME":1,"PP":1}}',
        '[{"level":1,"combat":{"attacks_base":2,"roll":3,"pull_punch":3},"note":"Body block/tackle, body flip/throw, break fall, disarm."},{"level":2,"combat":{"parry":2,"dodge":2,"strike":1}},{"level":3,"combat":{"body_flip":1,"disarm":1},"note":"+1 to body tackle."},{"level":4,"combat":{"attacks":1},"note":"Karate-style kick (2D6)."},{"level":5,"note":"Critical body flip/throw on a natural 19 or 20 (double damage)."},{"level":6,"combat":{"strike":1,"parry":1,"dodge":1,"body_flip":1}},{"level":7,"combat":{"damage_bonus":2},"note":"Paired weapons."},{"level":8,"combat":{"roll":1},"note":"Jump kick."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"initiative":2,"parry":1,"dodge":1}},{"level":11,"combat":{"disarm":1},"note":"+1 to break fall."},{"level":12,"note":"Critical strike on a natural 18-20."},{"level":13,"combat":{"damage_bonus":2},"note":"Knockout/stun on a natural 19 or 20."},{"level":14,"combat":{"attacks":1}},{"level":15,"note":"Automatic body flip/throw."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Aikido', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.193',
        'An entirely defensive style of seizing an attacker''s wrist or ankle to throw or lock him. Also gives +2D6 S.D.C. and +1D4 M.E.',
        '{"attributes":{"PP":1,"PE":1}}',
        '[{"level":1,"combat":{"attacks_base":2,"roll":2,"body_flip":2,"pull_punch":2},"note":"+3 to break fall. Holds, disarm, body block/tackle, body flip/throw."},{"level":2,"combat":{"initiative":1,"parry":2,"dodge":2}},{"level":3,"combat":{"disarm":1},"note":"Automatic dodge."},{"level":4,"combat":{"attacks":1,"body_flip":1}},{"level":5,"note":"Critical body flip/throw on a natural 18-20 (double damage)."},{"level":6,"combat":{"parry":1,"dodge":1,"body_flip":1}},{"level":7,"combat":{"pull_punch":2},"note":"Automatic flip/throw."},{"level":8,"combat":{"attacks":1}},{"level":9,"combat":{"initiative":1,"strike":1,"parry":1,"dodge":1}},{"level":10,"combat":{"disarm":1},"note":"Double existing P.P.E. (inner spirit)."},{"level":11,"combat":{"parry":1,"dodge":2,"body_flip":1}},{"level":12,"combat":{"attacks":1}},{"level":13,"combat":{"initiative":1},"note":"+2 to body block/tackle."},{"level":14,"note":"Critical strike on a natural 18-20."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Jujitsu', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.193-194',
        'A pragmatic whatever-works style of vital-point strikes, joint locks and throws. The book bars characters of principled or aberrant alignment from it. Also gives +3D6 S.D.C.',
        '{"attributes":{"PS":2,"PP":1}}',
        '[{"level":1,"combat":{"attacks_base":2,"roll":3,"parry":2,"dodge":2,"pull_punch":2},"note":"Snap kick (1D6), knife hand (2D4)."},{"level":2,"combat":{"strike":1},"note":"Tripping/leg hook and backward sweep kicks."},{"level":3,"combat":{"initiative":1},"note":"Critical strike from behind."},{"level":4,"combat":{"attacks":1,"damage_bonus":2}},{"level":5,"note":"Palm strike (2D4) and drop kick."},{"level":6,"note":"Critical strike on a natural 18-20."},{"level":7,"combat":{"strike":1,"body_flip":1,"disarm":1}},{"level":8,"combat":{"attacks":1},"note":"+1 to maintain balance."},{"level":9,"note":"Critical body flip/throw on a natural 17-20."},{"level":10,"note":"Jump kick and leap attacks."},{"level":11,"combat":{"attacks":1,"pull_punch":2}},{"level":12,"combat":{"initiative":1,"parry":1,"dodge":1,"strike":1}},{"level":13,"combat":{"damage_bonus":2,"pull_punch":2},"note":"+2 to break fall."},{"level":14,"combat":{"attacks":1}},{"level":15,"note":"Death blow."}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Karate', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.194',
        'An aggressive, fast variant of Kyokushinkai karate built on striking power and breaking objects. Also gives +3D6 S.D.C. and +1D4 P.S.',
        '{"attributes":{"PE":2,"Spd":2}}',
        '[{"level":1,"combat":{"attacks_base":2,"initiative":1,"roll":2,"parry":2,"dodge":1,"pull_punch":2},"note":"+1 to break fall. Snap kick (1D6), knife hand (2D4)."},{"level":2,"combat":{"strike":1},"note":"Tripping/leg hook and backward sweep kicks."},{"level":3,"combat":{"attacks":1,"damage_bonus":2}},{"level":4,"combat":{"initiative":1,"disarm":1},"note":"Roundhouse kick (3D6)."},{"level":5,"note":"Power punch; palm strike (2D4)."},{"level":6,"combat":{"attacks":1,"pull_punch":2}},{"level":7,"combat":{"strike":1,"parry":1},"note":"+1 to break fall. Power kick, wheel kick."},{"level":8,"note":"Critical strike on a natural 18-20 or from behind; death blow on a natural 20."},{"level":9,"combat":{"attacks":1,"damage_bonus":2}},{"level":10,"note":"Jump kick and leap attacks."},{"level":11,"combat":{"initiative":1,"parry":1,"dodge":1,"strike":1}},{"level":12,"combat":{"attacks":1,"pull_punch":2}},{"level":13,"note":"Death blow."},{"level":14,"combat":{"damage_bonus":2,"pull_punch":2},"note":"+2 to break fall."},{"level":15,"combat":{"attacks":1}}]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES ('Hand to Hand: Kendo', 'Physical', 0, 0, '["rifts"]', 'import',
        'Rifts World Book 8: Japan p.194',
        'A martial art built around swordsmanship: balance, striking and parrying. Also gives +2D4 S.D.C.',
        '{"attributes":{"PS":1,"PP":1,"Spd":2}}',
        '[{"level":1,"combat":{"attacks_base":2,"initiative":1,"roll":2,"disarm":1,"dodge":1,"pull_punch":2},"note":"+1 to break fall. Knife hand (2D4)."},{"level":1,"applies_when":"parrying with a sword or staff","combat":{"parry":2}},{"level":1,"applies_when":"parrying punches","combat":{"parry":1}},{"level":2,"combat":{"strike":1},"note":"Paired weapons."},{"level":3,"combat":{"attacks":1,"damage_bonus":2}},{"level":4,"combat":{"initiative":1,"disarm":1,"parry":1}},{"level":5,"note":"Tripping/leg hook and backward sweep kicks."},{"level":6,"note":"Power punch; palm strike (2D4)."},{"level":7,"combat":{"attacks":1,"pull_punch":2}},{"level":8,"note":"Critical strike on a natural 18-20 or from behind; death blow on a natural 19-20."},{"level":9,"combat":{"attacks":1,"damage_bonus":4}},{"level":10,"note":"Automatic dodge."},{"level":11,"combat":{"initiative":1,"strike":1},"note":"+2 to break fall."},{"level":12,"combat":{"attacks":1,"pull_punch":2}},{"level":13,"note":"Jump kick and leap attacks."},{"level":14,"note":"Death blow."},{"level":15,"combat":{"attacks":1}}]');

-- Read the result back rather than trusting the exit code.
SELECT 'the 19 skills exist, citing this book' AS assertion,
       count(*) AS got,
       19 AS want
  FROM skills
 WHERE name IN ('Bonsai',
                'Floral Arrangement (Ikebana)',
                'Go',
                'Poetry (Haiku)',
                'Japanese Mythology',
                'W.P. Bow',
                'W.P. Cross Bow',
                'W.P. Mouth Weapons (Blow Guns)',
                'W.P. Slingshot',
                'W.P. Small Thrown Weapons',
                'W.P. Grenade Launcher',
                'Hand to Hand: Zanji Shinjinken-Ryo',
                'Hand to Hand: Ninjitsu',
                'Hand to Hand: Teng-jutsu',
                'Hand to Hand: Basic Martial Arts/Judo',
                'Hand to Hand: Aikido',
                'Hand to Hand: Jujitsu',
                'Hand to Hand: Karate',
                'Hand to Hand: Kendo')
   AND source_book LIKE 'Rifts World Book 8: Japan p.%';

SELECT 'the eight styles each start with two attacks' AS assertion,
       count(*) AS got,
       8 AS want
  FROM skills
 WHERE name LIKE 'Hand to Hand:%' AND source_book LIKE 'Rifts World Book 8: Japan p.%'
   AND json_extract(level_bonuses, '$[0].combat.attacks_base') = 2;

SELECT 'every W.P. bonus here is conditional' AS assertion,
       count(*) AS got,
       0 AS want
  FROM skills, json_each(skills.level_bonuses)
 WHERE skills.name LIKE 'W.P.%' AND skills.source_book LIKE 'Rifts World Book 8: Japan p.%'
   AND json_extract(json_each.value, '$.combat') IS NOT NULL
   AND json_extract(json_each.value, '$.applies_when') IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-japan-skills.sql');
