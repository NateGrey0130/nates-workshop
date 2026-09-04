-- RETRO-AUDIT R4: seven skills stop saying their conditional bonuses cannot be
-- stored, and store them.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r4-conditional-skill-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r4-conditional-skill-bonuses.sql
--
-- WHAT WAS WRONG. Seven catalog skills carried a note explaining that what they
-- grant is conditional AND THEREFORE NOT STORED. Five say it in nearly the same
-- words - "ALL of them apply only while piloting ... so none is stored (they
-- would otherwise follow the pilot on foot)" - and Fencing cites migration 023
-- by number.
--
-- The premise is right and the conclusion is false. A level_bonuses entry may
-- carry applies_when: skillConditionalBonuses() in js/parser.js totals them per
-- condition, bonusesFromSkills() deliberately holds them OUT of the
-- unconditional combat block, and sheet.js renders each as its own row. The
-- comment beside that hold-back names Fencing as the case it was built for.
--
-- It is the dominant shape in that column, not a theory: of the 36 skills with
-- a level_bonuses schedule, 29 already use applies_when (W.P. Sword, W.P.
-- Knife, W.P. Blunt, W.P. Shield and the rest). Measured against production
-- 2026-09-04.
--
-- NOTHING MOVES IN THE COMBAT BLOCK. These bonuses were not in the derived
-- totals before this script and are not after it - bonusesFromSkills() skips
-- every entry carrying applies_when. What changes is that the sheet can now
-- show them, which it could not when the numbers lived only in prose.
--
-- WHAT DELIBERATELY STAYS PROSE, each for a reason on CLASS-AUDIT's "Checked
-- and still true" list or following from it:
--   * Fencing's +1D6 damage with a sword - dice-valued, and a bonus value must
--     be a number.
--   * "Critical strike as the pilot's own hand to hand" - not a numeric bonus.
--   * The dog-fighting roll bonuses on both Fighter Combat skills - there is no
--     dog_fighting key, and inventing one would be a schema change rather than
--     a data fix.
--   * Robot Combat: Basic's list of permitted attacks - a rule, not a number.
--
-- attacks is used rather than attacks_base: these ADD to whatever the pilot
-- already has, where attacks_base SETS a starting number (migration 025).

-- ---- Fencing -------------------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"with a sword or dagger","combat":{"strike":1,"parry":1}},{"level":1,"note":"Fencing: +1D6 damage with a sword. Dice-valued, so it is not stored as a bonus."}]',
  note = 'Base NA, no percentage - what it grants is combat bonuses. +1 strike and +1 parry with a sword or dagger, and +1D6 damage with a sword. All three are conditional on the weapon in hand, so none is in the flat bonuses column (see migration 023): applying them unconditionally would give a Fencer +1 to strike with a rifle. The strike and parry are stored as a level_bonuses entry carrying applies_when, which the sheet lists apart from the combat block; the +1D6 damage stays prose because a bonus value must be a number. RETRO-AUDIT R4. Prerequisites: W.P. Sword and W.P. Knife. Covers Olympic foil, epee and sabre, kendo and other blades.'
WHERE name = 'Fencing' AND level_bonuses IS NULL;

-- ---- Sniper --------------------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"on an aimed shot","combat":{"strike":2}},{"level":1,"note":"Sniper: only single-shot rifles usable."}]',
  note = 'Adds +2 to strike on an aimed shot; only single-shot rifles usable. The strike bonus is stored as a level_bonuses entry carrying applies_when, so it reaches the sheet without reaching the unconditional combat block. RETRO-AUDIT R4.'
WHERE name = 'Sniper' AND level_bonuses IS NULL;

-- ---- Weapon Systems ------------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"with vehicle or robot weapon systems","combat":{"strike":1}}]',
  note = 'Adds +1 to strike with vehicle/robot weapon systems. Stored as a level_bonuses entry carrying applies_when, so it reaches the sheet without reaching the unconditional combat block. RETRO-AUDIT R4.'
WHERE name = 'Weapon Systems' AND level_bonuses IS NULL;

-- ---- Robot Combat: Basic -------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"while piloting a robot or power armour","combat":{"attacks":1,"strike":1,"parry":1,"dodge":1,"roll":1}},{"level":1,"note":"Robot Combat: Basic - critical strike as the pilot''s own hand to hand. Basic allows only a restrained punch, a full strength punch and an ordinary kick: no leap kick, stomp or special attacks."}]',
  note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while piloting a robot or power armour, so none belongs in the flat bonuses column (they would otherwise follow the pilot on foot). They are stored as a level_bonuses entry carrying applies_when, which the sheet lists apart from the combat block. RETRO-AUDIT R4. Requires Pilot: Robots & Power Armor. +1 attack or action per melee on top of the pilot''s, +1 strike and +1 parry in hand to hand, +1 dodge, +1 roll with impact, and critical strike as the pilot''s own hand to hand. Basic allows only a restrained punch, a full strength punch and an ordinary kick - no leap kick, stomp or special attacks. The book calls this Robot Combat: Basic.'
WHERE name = 'Robot Combat: Basic' AND level_bonuses IS NULL;

-- ---- Robot Combat Elite: Glitter Boy --------------------------------------
-- The level-gated attacks are what the old note called "the same shape a
-- class's at_level block handles, which a skill has no equivalent of". The
-- equivalent is the schedule's own `level` field, which is what level_bonuses
-- IS - one entry per level that grants something, everything at or below the
-- character's level summed.
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"while piloting the Glitter Boy","combat":{"attacks":2,"initiative":2,"strike":2,"parry":2,"dodge":2,"disarm":1,"pull_punch":4,"roll":3}},{"level":3,"applies_when":"while piloting the Glitter Boy","combat":{"attacks":1}},{"level":7,"applies_when":"while piloting the Glitter Boy","combat":{"attacks":1}},{"level":11,"applies_when":"while piloting the Glitter Boy","combat":{"attacks":1}},{"level":1,"note":"Robot Combat Elite: Glitter Boy - in addition to normal Power Armor Training bonuses."}]',
  note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while piloting the Glitter Boy, so none belongs in the flat bonuses column. They are stored as level_bonuses entries carrying applies_when, one per level that grants something. RETRO-AUDIT R4. In addition to normal Power Armor Training bonuses: +2 attacks per melee, with one further attack at levels 3, 7 and 11; +2 initiative; +2 strike, parry and dodge; +1 disarm; +4 pull punch; +3 roll with punch, fall or impact.'
WHERE name = 'Robot Combat Elite: Glitter Boy' AND level_bonuses IS NULL;

-- ---- Fighter Combat: Basic ------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"while flying a space fighter","combat":{"attacks":1,"strike":2,"dodge":3}},{"level":6,"applies_when":"while flying a space fighter","combat":{"attacks":1}},{"level":11,"applies_when":"while flying a space fighter","combat":{"attacks":1}},{"level":1,"note":"Fighter Combat: Basic - +1 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. Neither is a numeric bonus key."}]',
  note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while flying a space fighter, so none belongs in the flat bonuses column: they would otherwise follow the pilot onto the ground. They are stored as level_bonuses entries carrying applies_when. RETRO-AUDIT R4. One extra attack or action involving the fighter''s weapon systems, +2 to strike on top of other cumulative bonuses, +3 to dodge attacks while flying, +1 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. One further attack at level six and another at level eleven. The dog-fighting bonus stays prose: there is no such bonus key. The book calls this Fighter Pilot: Basic in the CAF Fleet Officer''s skill list (p.58) and Space Fighter Combat "Basic" Training over the bonuses themselves (p.151); the catalog name follows its own Robot Combat: Basic.'
WHERE name = 'Fighter Combat: Basic' AND level_bonuses IS NULL;

-- ---- Fighter Combat: Elite ------------------------------------------------
UPDATE skills SET
  level_bonuses = '[{"level":1,"applies_when":"while flying a space fighter","combat":{"attacks":2,"strike":2,"dodge":5}},{"level":5,"applies_when":"while flying a space fighter","combat":{"attacks":1}},{"level":10,"applies_when":"while flying a space fighter","combat":{"attacks":1}},{"level":1,"note":"Fighter Combat: Elite - +3 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. Neither is a numeric bonus key."}]',
  note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while flying a space fighter, so none belongs in the flat bonuses column. They are stored as level_bonuses entries carrying applies_when. RETRO-AUDIT R4. Two extra attacks or actions involving the fighter''s weapon systems, +2 to strike cumulative with bonuses from Weapon Systems training, +5 to dodge attacks while flying, +3 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. One further attack at level five and another at level ten. The dog-fighting bonus stays prose: there is no such bonus key. The book calls this Fighter Combat "Elite" Combat Training (p.151); the catalog name follows its own Robot Combat Elite.'
WHERE name = 'Fighter Combat: Elite' AND level_bonuses IS NULL;

-- ---- readbacks -----------------------------------------------------------
-- All seven carry a schedule, and every one of them is conditional.
SELECT 'seven skills now carry a conditional schedule' AS assertion,
       count(*) AS got, 7 AS want
  FROM skills
 WHERE name IN ('Fencing', 'Sniper', 'Weapon Systems', 'Robot Combat: Basic',
                'Robot Combat Elite: Glitter Boy', 'Fighter Combat: Basic',
                'Fighter Combat: Elite')
   AND instr(level_bonuses, 'applies_when') > 0;

-- None of the seven gained a FLAT bonus, which is what would have changed a
-- derived combat total. This is the "nothing else moved" assertion.
SELECT 'none of the seven gained a flat bonuses value' AS assertion,
       count(*) AS got, 0 AS want
  FROM skills
 WHERE name IN ('Fencing', 'Sniper', 'Weapon Systems', 'Robot Combat: Basic',
                'Robot Combat Elite: Glitter Boy', 'Fighter Combat: Basic',
                'Fighter Combat: Elite')
   AND bonuses IS NOT NULL;

-- No note still claims the bonuses are not stored.
SELECT 'no note still says none is stored' AS assertion,
       count(*) AS got, 0 AS want
  FROM skills
 WHERE name IN ('Fencing', 'Sniper', 'Weapon Systems', 'Robot Combat: Basic',
                'Robot Combat Elite: Glitter Boy', 'Fighter Combat: Basic',
                'Fighter Combat: Elite')
   AND (instr(note, 'so none is stored') > 0
     OR instr(note, 'none is stored in bonuses') > 0);

-- The 29 W.P. rows that already used applies_when are untouched.
SELECT 'skills using applies_when' AS assertion, count(*) AS got, 36 AS want
  FROM skills WHERE instr(level_bonuses, 'applies_when') > 0;

-- Records this run. Every statement above guards itself on `level_bonuses IS NULL`,
-- so this script is safe to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r4-conditional-skill-bonuses.sql');
