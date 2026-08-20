-- The five Hand to Hand tables, Rifts Ultimate Edition p.347-349.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires migration 025.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-hand-to-hand-level-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-hand-to-hand-level-bonuses.sql
--
-- These five rows were in the catalog with base 0, per_level 0, no bonuses and
-- no note - indistinguishable from a percentile skill nobody filled in. Base 0
-- is CORRECT (they have no percentage, the way a W.P. has none), but everything
-- they DO grant was missing, so picking a fighting style changed nothing about
-- how the character fought.
--
-- p.347 states the two rules that shape this data:
--
--   "ALL bonuses are accumulative"  - a 5th level Expert has levels 1-5, so
--                                     everything at or below the character's
--                                     level is summed.
--   "each type of Hand to Hand      - hence attacks_base, which SETS the number
--    indicates the number of          rather than adding to the derived base.
--    attacks the character
--    starts with, typically four"
--
-- What is not a number lives in `note`: "Karate Kick (2D6 damage)", "Death blow
-- on a Natural 20", and the strike bonuses that apply only to guns or thrown
-- weapons. A conditional bonus in `combat` would apply unconditionally, which
-- is the same reason Fencing carries its bonuses as a note.
--
-- Every UPDATE is guarded by name, so this is safe to re-run and safe to run
-- before the rows exist.


-- Hand to Hand: Basic - starts with 4 attacks per melee round.
UPDATE skills SET level_bonuses = '[{"level":1,"combat":{"attacks_base":4,"pull_punch":2,"roll":2}},{"level":2,"combat":{"parry":2,"dodge":2}},{"level":3,"note":"Kick attack does 1D8 points of damage."},{"level":4,"combat":{"attacks":1}},{"level":5,"combat":{"strike":1,"disarm":1}},{"level":6,"note":"Critical Strike on an unmodified roll of 19 or 20."},{"level":7,"combat":{"damage_bonus":2}},{"level":8,"note":"Judo-style body flip/throw; does 1D6 damage, and victim loses initiative and one attack."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"pull_punch":2,"roll":2}},{"level":11,"combat":{"parry":1,"dodge":1}},{"level":12,"combat":{"strike":1}},{"level":13,"note":"Critical Strike or knockout from behind."},{"level":14,"combat":{"damage_bonus":2}},{"level":15,"combat":{"attacks":1}}]'
  WHERE name = 'Hand to Hand: Basic';

-- Hand to Hand: Expert - starts with 4 attacks per melee round.
UPDATE skills SET level_bonuses = '[{"level":1,"combat":{"attacks_base":4,"pull_punch":2,"roll":2},"note":"Kick attack does 1D8 damage."},{"level":2,"combat":{"parry":3,"dodge":3,"pull_punch":1}},{"level":3,"combat":{"strike":2,"disarm":2},"note":"Can perform a Karate Punch."},{"level":4,"combat":{"attacks":1}},{"level":5,"note":"Can perform a Karate Kick; does 2D6 damage."},{"level":6,"note":"Critical Strike on an unmodified roll of 18, 19 or 20."},{"level":7,"note":"W.P. Paired Weapons and backhand strike (average, does 1D4 damage)."},{"level":8,"note":"Body flip/throw; does 1D6 damage, and victim loses initiative and one attack."},{"level":9,"combat":{"attacks":1,"disarm":1}},{"level":10,"combat":{"damage_bonus":3}},{"level":11,"note":"Knockout/stun on an unmodified roll of 18, 19 or 20."},{"level":12,"combat":{"parry":2,"dodge":2}},{"level":13,"note":"Critical Strike or knockout from behind (triple damage)."},{"level":14,"combat":{"attacks":1}},{"level":15,"note":"Death blow on a roll of Natural 20."}]'
  WHERE name = 'Hand to Hand: Expert';

-- Hand to Hand: Martial Arts - starts with 4 attacks per melee round.
UPDATE skills SET level_bonuses = '[{"level":1,"combat":{"attacks_base":4,"pull_punch":3,"roll":3},"note":"Body flip/throw; does 1D6 damage, victim loses initiative and one attack."},{"level":2,"combat":{"parry":3,"dodge":3,"strike":2},"note":"May perform Karate and any hand strike/punch."},{"level":3,"combat":{"initiative":1},"note":"May perform a Karate-style kick (does 2D6 damage) and any foot strike except Leap Kick."},{"level":4,"combat":{"attacks":1}},{"level":5,"combat":{"entangle":2},"note":"Leap Kick (3D8 damage, but counts as two melee attacks)."},{"level":6,"note":"Critical Strike on an unmodified roll of 18, 19 or 20."},{"level":7,"combat":{"disarm":2},"note":"W.P. Paired Weapons, can perform Holds."},{"level":8,"note":"Back flip and back flip escape."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"disarm":2},"note":"Back flip attack."},{"level":11,"combat":{"damage_bonus":4,"initiative":1}},{"level":12,"combat":{"parry":2,"dodge":2}},{"level":13,"note":"Knockout/stun on an unmodified roll of 18, 19 or 20."},{"level":14,"combat":{"attacks":1}},{"level":15,"note":"Death blow on a roll of a Natural 20."}]'
  WHERE name = 'Hand to Hand: Martial Arts';

-- Hand to Hand: Assassin - starts with 3 attacks per melee round.
UPDATE skills SET level_bonuses = '[{"level":1,"combat":{"attacks_base":3,"strike":2},"note":"W.P. Paired Weapons."},{"level":2,"combat":{"initiative":1,"attacks":2}},{"level":3,"combat":{"pull_punch":3,"roll":2},"note":"Karate Punch (2D4 damage)."},{"level":4,"combat":{"damage_bonus":4,"initiative":1},"note":"Karate Kick (2D6 damage). The damage bonus applies to all physical attacks."},{"level":5,"combat":{"attacks":1},"note":"Plus 1 to strike with a thrown weapon."},{"level":6,"combat":{"parry":3,"dodge":3,"entangle":2},"note":"Backhand strike (martial arts 1D6)."},{"level":7,"note":"Knockout/stun on an unmodified roll of 17-20, and leap kick (3D8 damage, but counts as two melee attacks)."},{"level":8,"combat":{"attacks":1,"initiative":1},"note":"Plus 1 to strike with guns."},{"level":9,"combat":{"initiative":1},"note":"Can perform back flip."},{"level":10,"note":"Critical Strike on an unmodified roll of 19 or 20."},{"level":11,"combat":{"strike":2},"note":"Plus 1 to strike with a thrown weapon and with guns; can perform back flip attack."},{"level":12,"combat":{"pull_punch":2},"note":"Death blow on a roll of a Natural 19 or 20."},{"level":13,"combat":{"attacks":1}},{"level":14,"combat":{"damage_bonus":2},"note":"Can perform Holds."},{"level":15,"combat":{"strike":2},"note":"Plus 1 to strike with guns."}]'
  WHERE name = 'Hand to Hand: Assassin';

-- Hand to Hand: Commando - starts with 4 attacks per melee round.
UPDATE skills SET level_bonuses = '[{"level":1,"combat":{"attacks_base":4},"saves":{"horror_factor":2},"note":"W.P. Paired Weapons, body flip/throw, and body block/tackle."},{"level":2,"combat":{"initiative":1,"strike":1,"parry":2,"dodge":2,"roll":3,"pull_punch":3},"note":"Backward sweep kick, used only against opponents coming up behind the character. Does no damage; it is purely a knockdown attack (same penalties as body flip) but cannot be parried (an opponent can try to dodge it but is -2 to do so)."},{"level":3,"combat":{"initiative":1,"disarm":1},"note":"Karate punch/strike (does 2D4 damage)."},{"level":4,"combat":{"attacks":1},"note":"Karate kick (does 2D6 damage)."},{"level":5,"combat":{"automatic_dodge":2},"note":"Plus 2 to all foot strikes."},{"level":6,"combat":{"initiative":2,"strike":1,"parry":1,"dodge":1,"body_flip":1}},{"level":7,"combat":{"damage_bonus":2,"disarm":1,"automatic_dodge":1,"pull_punch":2},"saves":{"horror_factor":1}},{"level":8,"combat":{"attacks":1,"body_flip":2,"roll":1},"note":"Jump kick."},{"level":9,"combat":{"pull_punch":2},"note":"Death blow on a Natural 18-20."},{"level":10,"combat":{"initiative":1,"strike":1},"saves":{"horror_factor":2}},{"level":11,"combat":{"disarm":1,"pull_punch":1,"body_flip":2}},{"level":12,"combat":{"damage_bonus":2,"parry":1,"dodge":1,"automatic_dodge":2}},{"level":13,"combat":{"attacks":1}},{"level":14,"combat":{"initiative":1},"note":"Can perform holds."},{"level":15,"note":"Critical Strike on a Natural 17-20."}]'
  WHERE name = 'Hand to Hand: Commando';

-- Reports the result back, so it is read rather than assumed.
--   filled            5 = every Hand to Hand table landed
--   still_bare        0 = no Hand to Hand row is left with nothing at all
--   attacks_at_one    the starting attacks each one grants: 3 for the Assassin,
--                     4 for the other four, exactly as the book prints them
SELECT (SELECT count(*) FROM skills
          WHERE name LIKE 'Hand to Hand:%' AND level_bonuses IS NOT NULL) AS filled,
       (SELECT count(*) FROM skills
          WHERE name LIKE 'Hand to Hand:%'
            AND level_bonuses IS NULL AND bonuses IS NULL AND note IS NULL) AS still_bare,
       (SELECT group_concat(name || '=' || json_extract(level_bonuses, '$[0].combat.attacks_base'), ', ')
          FROM (SELECT name, level_bonuses FROM skills
                 WHERE name LIKE 'Hand to Hand:%' AND level_bonuses IS NOT NULL
                 ORDER BY name)) AS attacks_at_one;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-hand-to-hand-level-bonuses.sql');
