-- Rifts, Physical and Pilot skills that arrived from the RUE skill-list import
-- as bare names, plus the two the catalog was missing entirely.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-rue-physical-pilot-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-rue-physical-pilot-skills.sql
--
-- PROVENANCE, and it matters here more than usual. The printings disagree on
-- these entries, so the numbers below are the maintainer''s reconciliation
-- rather than a transcription of one page. Where a later reading of a specific
-- printing contradicts this, that reading wins - the rows are guarded on the
-- column being NULL, so correcting one is an UPDATE, not a fight with this file.
--
-- All but one are "Base Skill: NA": no percentage at all, the way a W.P. or a
-- Hand to Hand has none. Base 0 and per_level 0 are CORRECT for those and are
-- left alone. Pilot: Robots & Power Armor is the exception and is percentile.
--
-- THE SPLIT between `bonuses` and `note`, which is the decision worth recording:
--
--   FLAT and UNCONDITIONAL -> bonuses. derive.js applies these to every
--                             character holding the skill, always.
--   dice or a pool         -> note. Migration 023 refuses both for skills.
--   CONDITIONAL            -> note. A bonus that only applies while driving,
--                             or while piloting a robot, would otherwise be
--                             granted while walking around on foot.
--   no key in derive.js    -> note. disarm, kick damage, crash survival and
--                             skill-percentage modifiers have nowhere to go.
--
-- derive.js knows exactly these combat keys: attacks, initiative, strike,
-- parry, dodge, roll, pull_punch, damage_bonus. Anything else is prose.


-- ===== 1. Two skills the catalog did not have =====
-- Sense of Balance is granted BY Aerobic Athletics, and had no row of its own.
-- Pilot: Robots & Power Armor is the prerequisite Robot Combat: Basic names.
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note) VALUES
  ('Sense of Balance', 'Physical', 30, 5, NULL, 'manual', 'Rifts Ultimate Edition',
   'Granted by Aerobic Athletics at 30% +5% per level. Numbers reconciled across printings.'),
  ('Pilot: Robots & Power Armor', 'Pilot', 56, 3, NULL, 'manual', 'Rifts Ultimate Edition',
   'Prerequisite for Robot Combat: Basic and the Elite robot-combat skills. Numbers reconciled across printings.');


-- ===== 2. Physical skills: the flat parts stored, the rest recorded =====

-- +2 P.E. is flat. The Spd and S.D.C. are dice, and the endurance multiplier is
-- a rule rather than a number.
UPDATE skills
   SET bonuses = '{"attributes":{"PE":2}}',
       note = 'Base NA, no percentage - what it grants is bonuses. Also +1D4 Spd and +2D6 S.D.C., '
            || 'which are dice and so are not stored in bonuses (see migration 023). Maintains '
            || 'forced marches and sustained travel at five times the normal physical endurance rate.'
 WHERE name = 'Forced March' AND note IS NULL;

-- No attribute bonuses at all. Only the pull punch is both flat and
-- unconditional; disarm and kicking damage have no key, and the granted skill
-- is a skill, not a bonus.
UPDATE skills
   SET bonuses = '{"combat":{"pull_punch":1}}',
       note = 'Base NA, no percentage - what it grants is bonuses. No attribute bonuses. '
            || 'Also +2D4 S.D.C. (dice, see migration 023), +1 disarm and +2 kicking damage '
            || '(derive.js has no key for either), and it grants Sense of Balance at 30% +5% per level, '
            || 'which is a skill rather than a bonus. Only the +1 pull punch is stored.'
 WHERE name = 'Aerobic Athletics' AND note IS NULL;

-- The +5% modifiers apply to four other skills. There is no shape for a
-- skill-modifies-skill bonus, so they are recorded by name - and the names are
-- the catalog''s spellings, checked, not the book''s.
UPDATE skills
   SET bonuses = '{"attributes":{"PE":1}}',
       note = 'Base NA, no percentage - what it grants is bonuses. Also +2D6 S.D.C. (dice). '
            || 'Adds +5% to Dowsing, Fasting, Identify Plants & Fruits and Wilderness Survival; '
            || 'a skill-modifies-skill bonus has no shape in this schema, so it is recorded here. '
            || 'Requires Wilderness Survival as a prerequisite.'
 WHERE name = 'Outdoorsmanship' AND note IS NULL;

UPDATE skills
   SET bonuses = '{"attributes":{"PS":2,"PE":1}}',
       note = 'Base NA, no percentage - what it grants is bonuses. Also +2D8 S.D.C., which is dice '
            || 'and a pool and so is not stored in bonuses (see migration 023).'
 WHERE name = 'Physical Labor' AND note IS NULL;


-- ===== 3. Pilot skills: everything here is conditional =====

-- Every bonus applies only while driving a ground vehicle, so NOTHING is
-- stored. A +2 dodge in `bonuses` would follow the character on foot.
UPDATE skills
   SET note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them are conditional '
            || 'on driving a ground vehicle, so none is stored (storing the dodge would apply it on foot). '
            || 'Ground vehicles only. Penalties for tricks, vehicular attacks (ram, sideswipe) and evasive '
            || 'manoeuvres are halved. +2 dodge while driving, +2 to survive a crash or impact, only -2 to '
            || 'fire a weapon from a moving vehicle, aimed and called shots possible at -2 to strike, and no '
            || 'penalty to talk or act while driving. Penalties drop a further 1 point per experience level, '
            || 'which is a per-level scaler this schema cannot express for a skill.'
 WHERE name = 'Combat Driving' AND note IS NULL;

-- Conditional on being in the machine, so none of it is stored. Named in the
-- catalog as "Pilot Robot Combat Basic (general)"; the book calls it
-- "Robot Combat: Basic".
UPDATE skills
   SET note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while '
            || 'piloting a robot or power armour, so none is stored (they would otherwise follow the pilot '
            || 'on foot). Requires Pilot: Robots & Power Armor. +1 attack or action per melee on top of the '
            || 'pilot''s, +1 strike and +1 parry in hand to hand, +1 dodge, +1 roll with impact, and critical '
            || 'strike as the pilot''s own hand to hand. Basic allows only a restrained punch, a full strength '
            || 'punch and an ordinary kick - no leap kick, stomp or special attacks. '
            || 'The book calls this Robot Combat: Basic.'
 WHERE name = 'Pilot Robot Combat Basic (general)' AND note IS NULL;

-- Same conditionality, plus level-gated attacks. at_level exists for a CLASS''s
-- bonuses; a skill has no equivalent, which is a second reason this stays prose.
UPDATE skills
   SET note = 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while '
            || 'piloting the Glitter Boy, so none is stored. In addition to normal Power Armor Training '
            || 'bonuses: +2 attacks per melee, with one further attack at levels 3, 7 and 11; +2 initiative; '
            || '+2 strike, parry and dodge; +1 disarm; +4 pull punch; +3 roll with punch, fall or impact. '
            || 'The level-gated attacks are the same shape a class''s at_level block handles, which a skill '
            || 'has no equivalent of.'
 WHERE name = 'Pilot Robot Combat Elite: Glitter Boy' AND note IS NULL;


-- Reports the result back, so it is read rather than assumed.
--   filled            7 = every row this file targets now carries a note
--   with_bonuses      4 = the rows that had something flat and unconditional
--   new_rows          2 = Sense of Balance and Pilot: Robots & Power Armor
--   cited_present     4 = the skills Outdoorsmanship's note names, by catalog spelling
SELECT (SELECT count(*) FROM skills WHERE note IS NOT NULL AND name IN
          ('Forced March','Aerobic Athletics','Outdoorsmanship','Physical Labor','Combat Driving',
           'Pilot Robot Combat Basic (general)','Pilot Robot Combat Elite: Glitter Boy')) AS filled,
       (SELECT count(*) FROM skills WHERE bonuses IS NOT NULL AND name IN
          ('Forced March','Aerobic Athletics','Outdoorsmanship','Physical Labor')) AS with_bonuses,
       (SELECT count(*) FROM skills WHERE name IN
          ('Sense of Balance','Pilot: Robots & Power Armor')) AS new_rows,
       (SELECT count(*) FROM skills WHERE name IN
          ('Dowsing','Fasting','Identify Plants & Fruits','Wilderness Survival')) AS cited_present;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-rue-physical-pilot-skills.sql');
