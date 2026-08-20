-- Weapon Proficiencies, Rifts Ultimate Edition p.326-329.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires migration 025.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-wp-level-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-wp-level-bonuses.sql
--
-- Every W.P. sat in the catalog with base 0, per_level 0, no bonuses and no
-- note. Base 0 is CORRECT - a W.P. has no percentage - but its whole payload is
-- a list of levels at which it grants a combat bonus, and none of it was here.
--
-- EVERY NUMERIC W.P. BONUS IS CONDITIONAL. p.326: the result is "hand to hand
-- combat bonuses to strike and parry whenever that particular type of weapon is
-- used". Written into `combat` the way a Hand to Hand schedule is, a character
-- with five W.P.s would swing their FISTS at +5. So each entry carries the
-- condition it applies under in `applies_when`, bonusesFromSkills() skips those
-- entries entirely, and skillConditionalBonuses() totals them for the sheet to
-- show separately.
--
-- One skill can carry several conditions: a sword swung and a sword thrown are
-- different bonuses and the book lists them apart.
--
-- Every UPDATE is guarded by name, so this is safe to re-run and safe to run
-- before the rows exist.


UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a bow","combat":{"strike":1,"parry":1}},{"level":1,"note":"Rate of fire: two shots per melee round at level one, and an extra shot at levels 2, 4, 5, 8, 10, 12 and 14. A trained archer may try a shot at 50% greater distance, but without any bonus to strike or disarm. All bonuses are lost and the rate of fire halved when running, flying, riding or shooting from a moving vehicle."},{"level":2,"applies_when":"with a bow","combat":{"strike":1,"disarm":1}},{"level":4,"applies_when":"with a bow","combat":{"strike":1}},{"level":5,"applies_when":"with a bow","combat":{"disarm":1}},{"level":6,"applies_when":"with a bow","combat":{"strike":1}},{"level":8,"applies_when":"with a bow","combat":{"strike":1}},{"level":10,"applies_when":"with a bow","combat":{"strike":1,"disarm":1}},{"level":12,"applies_when":"with a bow","combat":{"strike":1}},{"level":14,"applies_when":"with a bow","combat":{"strike":1}},{"level":15,"applies_when":"with a bow","combat":{"disarm":1}}]'
  WHERE name = 'W.P. Archery';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Damage 2D6 or 2D8 depending on size and style; small axes and hatchets do 1D6. Axes are not designed for throwing."},{"level":2,"applies_when":"with an axe","combat":{"strike":1,"parry":1}},{"level":5,"applies_when":"throwing an axe","combat":{"strike":1}},{"level":5,"applies_when":"with an axe","combat":{"strike":1,"parry":1}},{"level":8,"applies_when":"throwing an axe","combat":{"strike":1}},{"level":8,"applies_when":"with an axe","combat":{"strike":1,"parry":1}},{"level":12,"applies_when":"throwing an axe","combat":{"strike":1}},{"level":12,"applies_when":"with an axe","combat":{"strike":1,"parry":1}},{"level":15,"applies_when":"with an axe","combat":{"strike":1,"parry":1}}]'
  WHERE name = 'W.P. Axe';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a blunt weapon","combat":{"strike":1,"parry":1}},{"level":1,"note":"Maces, hammers, cudgels, pipes, staves and clubs. Typically 1D6 or 2D4 damage, with only the largest and spiked weapons doing 2D6. Not designed for throwing."},{"level":3,"applies_when":"with a blunt weapon","combat":{"strike":1,"parry":1}},{"level":5,"applies_when":"throwing a blunt weapon","combat":{"strike":1}},{"level":6,"applies_when":"with a blunt weapon","combat":{"strike":1,"parry":1}},{"level":9,"applies_when":"with a blunt weapon","combat":{"strike":1,"parry":1}},{"level":10,"applies_when":"throwing a blunt weapon","combat":{"strike":1}},{"level":12,"applies_when":"with a blunt weapon","combat":{"strike":1,"parry":1}},{"level":15,"applies_when":"throwing a blunt weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Blunt';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":1,"note":"Parrying is only possible while the weapon is wielded in two hands. This weapon cannot be used to entangle and cannot be thrown with any accuracy: -3 to strike when thrown."},{"level":3,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":4,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":7,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":8,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":10,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":12,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":13,"applies_when":"with a chain weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Chain';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1,"parry":1}},{"level":1,"note":"Sai, tiger fork, pitchfork, military fork and trident. Wielded two-handed, or one in each hand with W.P. Paired Weapons, it is possible to catch enemy swords with a successful entangle. Not really designed for throwing."},{"level":3,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1,"parry":1}},{"level":4,"applies_when":"throwing a forked weapon","combat":{"strike":1}},{"level":5,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1}},{"level":6,"applies_when":"with a forked weapon","combat":{"parry":1}},{"level":8,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1}},{"level":10,"applies_when":"throwing a forked weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a forked weapon","combat":{"parry":1}},{"level":11,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1}},{"level":13,"applies_when":"with a forked weapon","combat":{"strike":1,"entangle":1,"parry":1}},{"level":15,"applies_when":"throwing a forked weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Forked';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Adds +5% to Climbing when a grappling hook is used. Knocking an opponent down costs them their initiative and one melee attack. This weapon CANNOT be used to parry."},{"level":3,"applies_when":"throwing or swinging a grappling hook","combat":{"strike":1,"entangle":1}},{"level":6,"applies_when":"throwing or swinging a grappling hook","combat":{"strike":1,"entangle":1}},{"level":9,"applies_when":"throwing or swinging a grappling hook","combat":{"strike":1,"entangle":1}},{"level":12,"applies_when":"throwing or swinging a grappling hook","combat":{"strike":1,"entangle":1}}]'
  WHERE name = 'W.P. Grappling Hook';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Revolvers and automatic pistols. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":2,"applies_when":"with a handgun","combat":{"strike":1}},{"level":4,"applies_when":"with a handgun","combat":{"strike":1}},{"level":6,"applies_when":"with a handgun","combat":{"strike":1}},{"level":8,"applies_when":"with a handgun","combat":{"strike":1}},{"level":10,"applies_when":"with a handgun","combat":{"strike":1}},{"level":12,"applies_when":"with a handgun","combat":{"strike":1}},{"level":14,"applies_when":"with a handgun","combat":{"strike":1}}]'
  WHERE name = 'W.P. Handguns';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Plain pointed end 2D6 S.D.C., or an explosive head 4D6 M.D. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":2,"applies_when":"with a harpoon or spear gun","combat":{"strike":1}},{"level":4,"applies_when":"with a harpoon or spear gun","combat":{"strike":1}},{"level":7,"applies_when":"with a harpoon or spear gun","combat":{"strike":1}},{"level":10,"applies_when":"with a harpoon or spear gun","combat":{"strike":1}},{"level":15,"applies_when":"with a harpoon or spear gun","combat":{"strike":1}}]'
  WHERE name = 'W.P. Harpoon & Spear Gun';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":1,"applies_when":"with a knife","combat":{"parry":1}},{"level":1,"note":"All types of daggers and knives. Very small 1D4 damage, typical 1D6."},{"level":2,"applies_when":"with a knife","combat":{"strike":1}},{"level":3,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":3,"applies_when":"with a knife","combat":{"parry":1}},{"level":4,"applies_when":"with a knife","combat":{"strike":1}},{"level":6,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":6,"applies_when":"with a knife","combat":{"parry":1}},{"level":7,"applies_when":"with a knife","combat":{"strike":1}},{"level":8,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":9,"applies_when":"with a knife","combat":{"parry":1}},{"level":10,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":10,"applies_when":"with a knife","combat":{"strike":1}},{"level":12,"applies_when":"with a knife","combat":{"parry":1}},{"level":13,"applies_when":"throwing a knife","combat":{"strike":1}},{"level":13,"applies_when":"with a knife","combat":{"strike":1}}]'
  WHERE name = 'W.P. Knife';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"5D6 S.D.C. per burst of flame, counting as one melee attack, with a 01-75% chance of anything flammable catching fire. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":2,"applies_when":"with a flamethrower","combat":{"strike":1}},{"level":5,"applies_when":"with a flamethrower","combat":{"strike":1}},{"level":10,"applies_when":"with a flamethrower","combat":{"strike":1}},{"level":15,"applies_when":"with a flamethrower","combat":{"strike":1}}]'
  WHERE name = 'W.P. Military Flamethrowers';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Exclusive to Men at Arms O.C.C.s. A one-handed weapon in each hand, used in any combination of combat moves simultaneously: strike and parry at once, twin simultaneous strikes on one target, strike two different targets, or parry two attackers. Only weapons the character has a W.P. in can be used. Not for guns - shooting two at once is -2 to strike with the regular hand and -6 with the off-hand. Taking the skill twice grants nothing extra."}]'
  WHERE name = 'W.P. Paired Weapons';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a pole arm","combat":{"strike":1,"parry":1}},{"level":1,"note":"Glaive, saber halberd, runka, scythe and voulge. Typically 2D8, the largest 3D6, and the voulge 4D6. Not designed for throwing."},{"level":2,"applies_when":"with a pole arm","combat":{"damage_bonus":2}},{"level":3,"applies_when":"throwing a pole arm","combat":{"strike":1}},{"level":3,"applies_when":"with a pole arm","combat":{"strike":1,"parry":1}},{"level":6,"applies_when":"with a pole arm","combat":{"strike":1,"parry":1}},{"level":8,"applies_when":"throwing a pole arm","combat":{"strike":1}},{"level":8,"applies_when":"with a pole arm","combat":{"damage_bonus":2}},{"level":9,"applies_when":"with a pole arm","combat":{"strike":1,"parry":1}},{"level":12,"applies_when":"throwing a pole arm","combat":{"strike":1}},{"level":12,"applies_when":"with a pole arm","combat":{"strike":1,"parry":1}}]'
  WHERE name = 'W.P. Pole Arm';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"An initiative bonus to draw and fire or throw at the first sign of danger, scaled by P.P. rather than by level: +1 with a P.P. of 17 or less, +2 at 18 to 23, +3 at 24 to 30, and +4 at 31 or above. Not applied automatically - it depends on the attribute, not the level."}]'
  WHERE name = 'W.P. Quick Draw';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a rifle","combat":{"strike":1}},{"level":1,"note":"Bolt-action and sniping rifles, and automatic and semi-automatic assault rifles. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":3,"applies_when":"with a rifle","combat":{"strike":1}},{"level":5,"applies_when":"with a rifle","combat":{"strike":1}},{"level":7,"applies_when":"with a rifle","combat":{"strike":1}},{"level":9,"applies_when":"with a rifle","combat":{"strike":1}},{"level":11,"applies_when":"with a rifle","combat":{"strike":1}},{"level":13,"applies_when":"with a rifle","combat":{"strike":1}}]'
  WHERE name = 'W.P. Rifles';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a shield","combat":{"parry":1}},{"level":1,"note":"A shield does 1D6 as a blunt weapon, or 1D4 when used to strike. No bonus to strike when thrown. A shield cannot easily block bullets or energy blasts: any such attempt is a straight die roll at -8 to parry. Blocking thrown knives, spears or arrows is -3 to parry on an unmodified roll."},{"level":3,"applies_when":"with a shield","combat":{"parry":1}},{"level":4,"applies_when":"striking with a shield","combat":{"strike":1}},{"level":7,"applies_when":"with a shield","combat":{"parry":1}},{"level":8,"applies_when":"striking with a shield","combat":{"strike":1}},{"level":10,"applies_when":"with a shield","combat":{"parry":1}},{"level":12,"applies_when":"striking with a shield","combat":{"strike":1}},{"level":13,"applies_when":"with a shield","combat":{"parry":1}}]'
  WHERE name = 'W.P. Shield';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a shotgun","combat":{"strike":1}},{"level":1,"note":"Double-barrel, police and military shotguns. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":3,"applies_when":"with a shotgun","combat":{"strike":1}},{"level":6,"applies_when":"with a shotgun","combat":{"strike":1}},{"level":10,"applies_when":"with a shotgun","combat":{"strike":1}},{"level":14,"applies_when":"with a shotgun","combat":{"strike":1}}]'
  WHERE name = 'W.P. Shotgun';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a spear","combat":{"strike":1,"parry":1}},{"level":1,"note":"Large and small spears and javelins; a rifle with a bayonet also falls in this category. Short spear or javelin 1D6, long spear 2D6. Maximum throwing range 150 feet."},{"level":3,"applies_when":"throwing a spear","combat":{"strike":1}},{"level":3,"applies_when":"with a spear","combat":{"strike":1,"parry":1}},{"level":6,"applies_when":"throwing a spear","combat":{"strike":1}},{"level":6,"applies_when":"with a spear","combat":{"strike":1,"parry":1}},{"level":9,"applies_when":"with a spear","combat":{"strike":1,"parry":1}},{"level":10,"applies_when":"throwing a spear","combat":{"strike":1}},{"level":12,"applies_when":"with a spear","combat":{"strike":1,"parry":1}},{"level":14,"applies_when":"throwing a spear","combat":{"strike":1}}]'
  WHERE name = 'W.P. Spear';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a staff","combat":{"strike":1}},{"level":1,"note":"Short staff 1D6, long staff 2D4, bo or quarter staff 2D6. Not designed for throwing."},{"level":2,"applies_when":"with a staff","combat":{"parry":1}},{"level":3,"applies_when":"with a staff","combat":{"strike":1}},{"level":5,"applies_when":"throwing a staff","combat":{"strike":1}},{"level":5,"applies_when":"with a staff","combat":{"parry":1}},{"level":7,"applies_when":"with a staff","combat":{"strike":1}},{"level":8,"applies_when":"with a staff","combat":{"parry":1}},{"level":10,"applies_when":"throwing a staff","combat":{"strike":1}},{"level":10,"applies_when":"with a staff","combat":{"strike":1}},{"level":11,"applies_when":"with a staff","combat":{"parry":1}},{"level":13,"applies_when":"with a staff","combat":{"strike":1}},{"level":14,"applies_when":"with a staff","combat":{"parry":1}},{"level":15,"applies_when":"throwing a staff","combat":{"strike":1}}]'
  WHERE name = 'W.P. Staff';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":1,"note":"Small arms automatic weapons like the Uzi; can only fire in bursts. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":3,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":6,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":9,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":12,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":15,"applies_when":"with a sub-machinegun","combat":{"strike":1}}]'
  WHERE name = 'W.P. Sub-Machinegun';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a sword","combat":{"strike":1}},{"level":1,"note":"Includes fencing-type training. Short sword or saber 2D4, falchion or scimitar 2D6, broadsword 1D8+1, long and other large swords 2D6, claymore and flamberge 3D6. Swords are not designed for being thrown."},{"level":2,"applies_when":"with a sword","combat":{"parry":1}},{"level":3,"applies_when":"with a sword","combat":{"strike":1}},{"level":4,"applies_when":"throwing a sword","combat":{"strike":1}},{"level":4,"applies_when":"with a sword","combat":{"parry":1}},{"level":6,"applies_when":"with a sword","combat":{"strike":1}},{"level":7,"applies_when":"with a sword","combat":{"parry":1}},{"level":8,"applies_when":"throwing a sword","combat":{"strike":1}},{"level":9,"applies_when":"with a sword","combat":{"strike":1}},{"level":10,"applies_when":"with a sword","combat":{"parry":1}},{"level":12,"applies_when":"throwing a sword","combat":{"strike":1}},{"level":12,"applies_when":"with a sword","combat":{"strike":1}},{"level":13,"applies_when":"with a sword","combat":{"parry":1}},{"level":15,"applies_when":"with a sword","combat":{"strike":1}}]'
  WHERE name = 'W.P. Sword';

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":1,"note":"Sling, slingshot, boomerangs, shurikens, throwing knives, sticks, small axes and spears, even siege weapons - but not bows, crossbows or guns. Requires any one W.P. for a missile weapon. Stacks with that W.P. Can throw two small items at one target simultaneously. All bonuses lost and rate of fire halved when running, flying, riding or shooting from a moving vehicle."},{"level":3,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":7,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Targeting';

UPDATE skills SET level_bonuses = '[{"level":1,"note":"Light whip 1D6; heavy whip, bull whip or cat-o-nine-tails 2D6. This weapon cannot be used to parry and cannot be thrown."},{"level":2,"applies_when":"with a whip","combat":{"strike":1,"disarm":1,"entangle":1,"damage_bonus":1}},{"level":4,"applies_when":"with a whip","combat":{"strike":1,"disarm":1,"entangle":1,"damage_bonus":1}},{"level":7,"applies_when":"with a whip","combat":{"strike":1,"disarm":1,"entangle":1}},{"level":8,"applies_when":"with a whip","combat":{"damage_bonus":1}},{"level":10,"applies_when":"with a whip","combat":{"strike":1,"disarm":1,"entangle":1}},{"level":12,"applies_when":"with a whip","combat":{"damage_bonus":1}},{"level":13,"applies_when":"with a whip","combat":{"strike":1,"disarm":1,"entangle":1}}]'
  WHERE name = 'W.P. Whip';

-- Reports the result back, so it is read rather than assumed.
--   filled              22 = every W.P. this script covers landed
--   unconditional_bonus  0 = no W.P. grants a bonus that applies with bare hands.
--                            This is the one that matters: a single entry
--                            missing its `applies_when` silently hands the
--                            character a permanent bonus it never earned.
--   still_bare          the W.P.s left with nothing at all. See the note below.
SELECT (SELECT count(*) FROM skills
          WHERE name LIKE 'W.P.%' AND level_bonuses IS NOT NULL) AS filled,
       (SELECT count(*) FROM skills, json_each(skills.level_bonuses)
          WHERE skills.name LIKE 'W.P.%'
            AND json_extract(json_each.value, '$.combat') IS NOT NULL
            AND json_extract(json_each.value, '$.applies_when') IS NULL) AS unconditional_bonus,
       (SELECT group_concat(name, ', ') FROM (
          SELECT name FROM skills
           WHERE name LIKE 'W.P.%' AND level_bonuses IS NULL
             AND bonuses IS NULL AND note IS NULL ORDER BY name)) AS still_bare;

-- Deliberately NOT filled, because p.326-329 does not state bonuses for them:
--
--   W.P. Energy Pistol, W.P. Energy Rifle, W.P. Heavy Energy Weapons
--       The book lists these under Modern Weapons with a description and
--       "Mega-Damage varies", and prints no W.P. Bonuses line at all.
--   W.P. Rope
--       "Usually exclusive to the Cowboy O.C.C.; see Cowboy skills."
--   W.P. Automatic Pistol, W.P. Revolver, W.P. Bolt Action Rifle,
--   W.P. Automatic and Semi-automatic Rifles, W.P. Heavy
--       Older-edition names for what RUE folds into W.P. Handguns and W.P.
--       Rifles. Filling them from the RUE entries would be a guess about which
--       row means what, and merging them is a catalog decision rather than a
--       transcription - catalog_redirects exists for exactly that.

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-wp-level-bonuses.sql');
