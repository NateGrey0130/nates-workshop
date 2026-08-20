-- Rifts Ultimate Edition, Physical skills (the rows already cite p.302-303).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-rue-physical-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-rue-physical-skills.sql
--
-- These came out of the RUE skill-list import as bare names: base 0, per level
-- 0, no bonuses, no note. That reads like a percentile skill nobody filled in,
-- and an audit of unfilled catalog rows counted them as exactly that.
--
-- THEY ARE NOT UNFILLED. The book prints "Base Skill: NA" for both - they have
-- no percentage at all, the way a W.P. or a Hand to Hand has none. What they
-- grant is bonuses. So base 0 and per_level 0 are CORRECT and are left alone.
--
-- The split between `bonuses` and `note` is the decision worth recording, and
-- it differs between these two entries:
--
--   FLAT and UNCONDITIONAL  -> bonuses. derive.js applies them to every
--                              character holding the skill.
--   dice, pools, or         -> note. Migration 023 refuses dice and pools for
--   CONDITIONAL                skills, and a conditional bonus applied
--                              unconditionally is simply wrong.
--
-- Same rule Boxing, Wrestling and the rest already follow in
-- add-rifts-skill-list-gaps.sql, and the same reason Ice Skating keeps its
-- "+1 to dodge ON ICE" in prose.
--
-- Guarded on bonuses IS NULL / note IS NULL so neither ever overwrites a
-- hand-edited row.


-- ===== Fencing =====
-- Every bonus is conditional on the weapon in hand, so NOTHING goes in
-- `bonuses`. Storing the strike would hand a Fencer +1 to strike with a laser
-- rifle. The damage is doubly ineligible: it is dice as well as conditional.
--
--   +1 strike   with a sword or dagger
--   +1 parry    with a sword or dagger
--   +1D6 damage with a sword
--
-- The note names the condition rather than dropping it, so this row is
-- findable if conditional bonuses ever become expressible.
UPDATE skills
   SET note = 'Base NA, no percentage - what it grants is combat bonuses. '
            || '+1 strike and +1 parry with a sword or dagger, and +1D6 damage with a sword. '
            || 'All three are conditional on the weapon in hand and the damage is dice, so none '
            || 'is stored in bonuses (see migration 023); applying them unconditionally would '
            || 'give a Fencer +1 to strike with a rifle. Prerequisites: W.P. Sword and W.P. Knife. '
            || 'Covers Olympic foil, epee and sabre, kendo and other blades.'
 WHERE name = 'Fencing'
   AND note IS NULL;


-- ===== Kick Boxing =====
-- Unlike Fencing, two of these ARE flat and unconditional, so they go in the
-- column and actually apply. Only the S.D.C. stays in prose, because it is dice
-- AND a pool - both refused for skills by migration 023, since a skill can be
-- taken at any level and there is no moment at which to roll it.
--
--   +1 P.E.        flat        -> bonuses
--   +1 P.S.        flat        -> bonuses
--   +1D10 S.D.C.   dice, pool  -> note
UPDATE skills
   SET bonuses = '{"attributes":{"PE":1,"PS":1}}',
       note = COALESCE(note || ' ', '')
            || 'Base NA, no percentage - what it grants is bonuses. Also +1D10 S.D.C., which is '
            || 'dice and a pool and so is not stored in bonuses (see migration 023). '
            || 'No prerequisites. A self-defence style usually learned in a few months to a year '
            || 'alongside a character''s main Hand to Hand skill.'
 WHERE name = 'Kick Boxing'
   AND bonuses IS NULL;


-- Reports both rows back, so the result is read rather than assumed.
--   base/per_level 0/0 is CORRECT for these - not a gap
--   fencing_bonuses_null 1 = correct, every Fencing bonus is conditional
--   kickboxing_bonuses   the flat attribute bonuses that now apply
--   prereqs_present      2 = both W.P.s Fencing's note cites exist by name
SELECT (SELECT base || '/' || per_level FROM skills WHERE name = 'Fencing') AS fencing_base,
       (SELECT bonuses IS NULL FROM skills WHERE name = 'Fencing') AS fencing_bonuses_null,
       (SELECT length(note) FROM skills WHERE name = 'Fencing') AS fencing_note_len,
       (SELECT base || '/' || per_level FROM skills WHERE name = 'Kick Boxing') AS kickboxing_base,
       (SELECT bonuses FROM skills WHERE name = 'Kick Boxing') AS kickboxing_bonuses,
       (SELECT length(note) FROM skills WHERE name = 'Kick Boxing') AS kickboxing_note_len,
       (SELECT count(*) FROM skills WHERE name IN ('W.P. Sword', 'W.P. Knife')) AS prereqs_present;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-rue-physical-skills.sql');
