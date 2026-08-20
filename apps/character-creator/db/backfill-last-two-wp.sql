-- The last two Weapon Proficiencies.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires migration 025.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-last-two-wp.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-last-two-wp.sql
--
-- W.P. Heavy and W.P. Bolt Action Rifle each carried a note describing what the
-- weapon is but no bonuses at all. Both were deliberately left alone earlier:
-- their notes ("Machineguns, bazookas, LAWS, and mortars" and "Hunting and
-- sniping rifles") match RUE entries closely enough to tempt an assumption, and
-- after the Revolver - which looked like a duplicate of W.P. Handguns and was
-- not, because its aimed shot is +4 where the others give +3 - assuming
-- equivalence from a matching description was the mistake not to make twice.
--
-- These numbers are NOT from Rifts Ultimate Edition. They come from the same
-- older-edition W.P. tables the other aimed/burst proficiencies in this catalog
-- come from - the ones that give +3 on an aimed shot, +1 on a burst, and +1 at
-- levels 4, 7, 10 and 13. RUE's own modern W.P.s are flat strike ladders on
-- different levels entirely (Handguns at 2/4/6/8/10/12/14, Rifles at
-- 1/3/5/7/9/11/13), transcribed separately from p.326-329.
--
-- THE BOLT ACTION RIFLE HAS NO BURST BONUS, and that is not an omission: a
-- bolt-action rifle is worked by hand between shots and cannot fire one. It is
-- the same kind of real difference as the Revolver's +4, and the same kind of
-- thing that gets normalised away by accident.
--
-- Every UPDATE is guarded on the row still having no schedule, so re-running is
-- safe and nothing entered later is overwritten.


UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"Hunting and sniping rifles. NO burst bonus - a bolt-action rifle is worked by hand between shots and cannot fire a burst, which is what separates it from the automatic rifle proficiency. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":7,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":10,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":13,"applies_when":"with a bolt action rifle","combat":{"strike":1}}]'
  WHERE name = 'W.P. Bolt Action Rifle' AND level_bonuses IS NULL;

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"Machineguns, bazookas, LAWS and mortars. The burst bonus applies only to the weapons that can actually fire a burst. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":7,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":13,"applies_when":"with a heavy weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Heavy' AND level_bonuses IS NULL;

-- Reports the result back, so it is read rather than assumed.
--   filled                2 = both landed
--   heavy_burst           1 = W.P. Heavy has a burst bonus
--   bolt_burst            0 = the bolt action rifle does NOT, which is the point
--   wp_without_bonuses    0 = no W.P. is left with nothing at all
--   unconditional_bonus   0 = still nothing that applies with bare hands
SELECT (SELECT count(*) FROM skills
          WHERE name IN ('W.P. Heavy', 'W.P. Bolt Action Rifle')
            AND level_bonuses IS NOT NULL) AS filled,
       (SELECT count(*) FROM skills, json_each(skills.level_bonuses)
          WHERE skills.name = 'W.P. Heavy'
            AND json_extract(json_each.value, '$.applies_when') = 'firing a burst') AS heavy_burst,
       (SELECT count(*) FROM skills, json_each(skills.level_bonuses)
          WHERE skills.name = 'W.P. Bolt Action Rifle'
            AND json_extract(json_each.value, '$.applies_when') = 'firing a burst') AS bolt_burst,
       (SELECT count(*) FROM skills
          WHERE name LIKE 'W.P.%' AND level_bonuses IS NULL
            AND bonuses IS NULL) AS wp_without_bonuses,
       (SELECT count(*) FROM skills, json_each(skills.level_bonuses)
          WHERE skills.name LIKE 'W.P.%'
            AND json_extract(json_each.value, '$.combat') IS NOT NULL
            AND json_extract(json_each.value, '$.applies_when') IS NULL) AS unconditional_bonus;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-last-two-wp.sql');
