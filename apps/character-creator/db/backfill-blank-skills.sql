-- The skills that were left blank, from stats supplied by hand.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires migration 025.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-blank-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-blank-skills.sql
--
-- THESE ARE NOT DUPLICATES. W.P. Automatic Pistol, W.P. Revolver and W.P.
-- Automatic and Semi-automatic Rifles were about to be merged into W.P.
-- Handguns and W.P. Rifles as older-edition names for the same thing. They are
-- not: each has its own bonuses, and the REVOLVER'S AIMED SHOT IS +4 WHERE
-- EVERY OTHER MODERN HANDGUN PROFICIENCY GIVES +3. Merging would have quietly
-- deleted that point of difference from every character who took the skill.
--
-- Same shape as the energy weapons: the aimed and burst bonuses are
-- level-INDEPENDENT and stack on top of the level ladder, so they are held as
-- separate conditions. All of it is conditional - see add-wp-level-bonuses.sql
-- for why a W.P. bonus must never reach the unconditional combat block.
--
-- Every UPDATE is guarded by name, so this is safe to re-run and safe to run
-- before the rows exist.


UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"All modern military automatic pistols. The trigger must be pulled for each shot, but the pistol automatically ejects the cartridge and loads a new one from the magazine into the chamber. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":7,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":10,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":13,"applies_when":"with an automatic pistol","combat":{"strike":1}}]'
  WHERE name = 'W.P. Automatic Pistol';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"All assault rifles, such as the M-16 and AK-47. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":7,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":10,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":13,"applies_when":"with an assault rifle","combat":{"strike":1}}]'
  WHERE name = 'W.P. Automatic and Semi-automatic Rifles';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":4}},{"level":1,"note":"All cylinder-style handguns; not automatic, and does not jam. The aimed-shot bonus is +4 rather than the +3 the other modern handgun proficiencies give. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a revolver","combat":{"strike":1}},{"level":7,"applies_when":"with a revolver","combat":{"strike":1}},{"level":10,"applies_when":"with a revolver","combat":{"strike":1}},{"level":13,"applies_when":"with a revolver","combat":{"strike":1}}]'
  WHERE name = 'W.P. Revolver';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a rope","combat":{"strike":1,"entangle":1,"disarm":1}},{"level":1,"note":"Lasso and lariat use. The entangle and disarm bonuses are flat rather than scaling with level."},{"level":4,"applies_when":"with a rope","combat":{"strike":1}},{"level":8,"applies_when":"with a rope","combat":{"strike":1}},{"level":12,"applies_when":"with a rope","combat":{"strike":1}},{"level":15,"applies_when":"with a rope","combat":{"strike":1}}]',
  source_book = 'Rifts New West'
  WHERE name = 'W.P. Rope';

-- Literacy is a percentile skill, so it gets a base and a per-level step rather
-- than a bonus schedule. Category left alone: the catalog files it under
-- Communications and moving it would change which class picks can reach it,
-- which is a rules decision rather than a transcription.
UPDATE skills
SET base = 30, per_level = 5,
    note = 'Read and write Dragonese/Elven, the tongue of dragons and elves - common in Tolkeen, Lazlo and the Federation of Magic, and outlawed in Coalition territory. Each language counts as a separate skill selection, and Literacy in a language does NOT grant the spoken Language skill (or the reverse). RUE splits generic literacy into Literacy: Native at 40% +5% and Literacy: Other at 30% +5%.'
WHERE name = 'Literacy: Dragonese/Elven' AND base = 0;

-- Not a purchasable skill at all. It is a class or racial ability line - the
-- Splugorth entry is the classic example, listing a few real languages and then
-- noting that magic covers everyone else. Kept in the catalog because classes
-- and characters already reference it by name, but written down as what it is.
UPDATE skills
SET base = 98, per_level = 0,
    note = 'NOT a purchasable skill: a class or racial ability line granting comprehension and speech of any language through innate magic, conventionally written at 98%. It does not confer literacy. base 0 and per_level 0 read as an unfilled row, so the conventional 98% is recorded here instead.'
WHERE name = 'Language: All (magical)' AND base = 0;

-- Reports the result back, so it is read rather than assumed.
--   wp_filled            4 = the three modern handgun/rifle W.P.s, plus Rope
--   revolver_aimed       4 = the outlier survived, which is the whole point
--   pistol_aimed         3 = and the others still differ from it
--   unconditional_bonus  0 = still nothing that applies with bare hands
--   literacy             '30/5'
--   magic_language       '98/0'
--   rope_book            'Rifts New West', not the RUE page the import stamped
--   still_blank          what is left with nothing at all
SELECT (SELECT count(*) FROM skills
          WHERE name IN ('W.P. Automatic Pistol', 'W.P. Revolver',
                         'W.P. Automatic and Semi-automatic Rifles', 'W.P. Rope')
            AND level_bonuses IS NOT NULL) AS wp_filled,
       -- By condition, not by array position: entries are ordered by condition
       -- name, so [0] is the burst and reading it reported +1 for the outlier.
       (SELECT json_extract(json_each.value, '$.combat.strike')
          FROM skills, json_each(skills.level_bonuses)
         WHERE skills.name = 'W.P. Revolver'
           AND json_extract(json_each.value, '$.applies_when') = 'taking an aimed shot') AS revolver_aimed,
       (SELECT json_extract(json_each.value, '$.combat.strike')
          FROM skills, json_each(skills.level_bonuses)
         WHERE skills.name = 'W.P. Automatic Pistol'
           AND json_extract(json_each.value, '$.applies_when') = 'taking an aimed shot') AS pistol_aimed,
       (SELECT count(*) FROM skills, json_each(skills.level_bonuses)
          WHERE skills.name LIKE 'W.P.%'
            AND json_extract(json_each.value, '$.combat') IS NOT NULL
            AND json_extract(json_each.value, '$.applies_when') IS NULL) AS unconditional_bonus,
       (SELECT base || '/' || per_level FROM skills
          WHERE name = 'Literacy: Dragonese/Elven') AS literacy,
       (SELECT base || '/' || per_level FROM skills
          WHERE name = 'Language: All (magical)') AS magic_language,
       (SELECT source_book FROM skills WHERE name = 'W.P. Rope') AS rope_book,
       (SELECT group_concat(name, ', ') FROM (
          SELECT name FROM skills
           WHERE base = 0 AND per_level = 0 AND note IS NULL
             AND bonuses IS NULL AND level_bonuses IS NULL ORDER BY name)) AS still_blank;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-blank-skills.sql');
