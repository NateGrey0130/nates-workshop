-- The wizard's six starting spells, moved to where creation reads them.
--
-- The class was published with its six extra picks written as four
-- `spells_schedule` entries at `level: 1`. Nothing has ever granted them.
-- `perLevelGrants` skips every entry at or below the level it starts from - by
-- design, so that levelling from 3 to 4 does not re-offer level 3 - and
-- character creation does not read the schedule at all: it reads the
-- `*_starting` keys. So the six were printed in the class, described in the
-- extraction notes, visible on the class detail page, and reached no character.
--
-- PR #332 made the loss visible rather than silent: the Powers step now prints
-- a note counting spells stated in a schedule at level 1 instead of dropping
-- them. This is the other half - the data fix that makes the note unnecessary.
--
-- THE PAGE. Palladium Fantasy RPG, printed page 106 (pf cache p108; this
-- book's printed folio runs two behind its PDF page), "Wizard O.C.C. Abilities
-- & Bonuses", item 2, "Additional Spells":
--
--   "The player may select two spells of choice each level one and two, and one
--    from level three and four."
--
-- Two, two, one, one - six, banded by spell level, which is what the schedule
-- entries said and what the groups below say.
--
-- WHY IT COULD NOT BE WRITTEN THIS WAY BEFORE, AND CAN NOW. The extraction
-- notes gave the reason as "spells_starting cannot band picks by spell level",
-- which was true when the wizard was imported: `spells_starting` was one open
-- count against one gate. CLASS-AUDIT S1 added `*_starting_groups`, and a group
-- carries its own `spell_levels` exactly as a schedule entry does. The false
-- reason is rewritten below rather than left standing - a note explaining a
-- limitation that has been lifted is worse than no note, because it stops the
-- next reader from looking.
--
-- `spells_starting` is stated as well as the groups, at 6. It is the TOTAL and
-- keeps that meaning; the groups split it. Anything reading the total still
-- reads one number.
--
-- WHAT THIS DOES NOT FIX, DELIBERATELY. The same book paragraph continues: at
-- each new level of experience, starting at level one, the character learns one
-- more spell of any level up to their own. The class holds that as
-- `spells_per_level: 1` with `spells_per_level_levels: up_to_character_level`,
-- and `perLevelGrants` grants it from level two onward - so the level-ONE
-- instance of that rule, a seventh starting pick, is not modelled. Whether the
-- book means a seventh pick at creation is a reading of the page, not a bug in
-- the app, so it is recorded in the extraction notes and left for a decision
-- rather than quietly granted here.
--
-- FILENAME. `zzz-` because a clean rebuild applies db/*.sql as one sorted glob
-- and this must land after every other writer of the wizard's markdown -
-- zz-pf-experience-tables.sql and zz-race-occ-restrictions.sql among them.
--
-- Guarded on `spells_starting_groups` being absent, so a second run is a no-op.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  spells_schedule:' || char(10) ||
      '    - { level: 1, count: 2, spell_levels: [1], note: "Two spells of choice from level one" }' || char(10) ||
      '    - { level: 1, count: 2, spell_levels: [2], note: "Two spells of choice from level two" }' || char(10) ||
      '    - { level: 1, count: 1, spell_levels: [3], note: "One spell of choice from level three" }' || char(10) ||
      '    - { level: 1, count: 1, spell_levels: [4], note: "One spell of choice from level four" }',
      '  spells_starting: 6' || char(10) ||
      '  spells_starting_groups:' || char(10) ||
      '    - { count: 2, spell_levels: [1], note: "Two spells of choice from spell level one" }' || char(10) ||
      '    - { count: 2, spell_levels: [2], note: "Two spells of choice from spell level two" }' || char(10) ||
      '    - { count: 1, spell_levels: [3], note: "One spell of choice from spell level three" }' || char(10) ||
      '    - { count: 1, spell_levels: [4], note: "One spell of choice from spell level four" }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, '  spells_starting_groups:') = 0;


-- The extraction note, which gave a limitation that no longer exists as the
-- reason for a shape that granted nothing.
UPDATE imported_classes
SET markdown = replace(
      markdown,
      'The four extra picks - two from level one, two from two, one from three, one from four - are modelled as four level-1 schedule entries rather than spells_starting, because spells_starting cannot band picks by spell level.',
      'The six extra picks - two from spell level one, two from two, one from three, one from four - are stated as spells_starting_groups, with spells_starting as their total. They were four level-1 spells_schedule entries until this fix, and in that shape they granted NOTHING: perLevelGrants skips every entry at or below the level it starts from, and creation reads the *_starting keys, so the six were printed here and reached no character. The note that stood in this place said spells_starting cannot band picks by spell level - true when the wizard was imported, false since class audit S1 gave the starting pick groups. STILL PROSE, and a reading rather than a bug: the same book paragraph grants one more spell at each new level of experience beginning at level one, which the class holds as spells_per_level and the app grants from level two onward, so the level-one instance of it - a seventh starting pick, if the sentence is meant literally - is not modelled.'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'because spells_starting cannot band picks by spell level.') > 0;


SELECT class_id,
       instr(markdown, '  spells_starting: 6') > 0 AS has_total,
       instr(markdown, '  spells_starting_groups:') > 0 AS has_groups,
       instr(markdown, 'count: 2, spell_levels: [1]') > 0 AS has_first_group,
       instr(markdown, 'count: 1, spell_levels: [4]') > 0 AS has_last_group,
       instr(markdown, 'spells_schedule:') = 0 AS schedule_gone,
       -- NOT `instr(markdown, 'cannot band picks by spell level') = 0`. The
       -- replacement note QUOTES the old reason in order to say it is no longer
       -- true, so that assertion reads 0 whether the update fired or not - a
       -- readback that cannot pass. Assert on the sentence openings instead,
       -- which the two versions do not share.
       instr(markdown, 'The four extra picks') = 0 AS old_note_gone,
       instr(markdown, 'The six extra picks') > 0 AS new_note_written
FROM imported_classes
WHERE class_id = 'wizard';

INSERT INTO data_script_runs (filename) VALUES ('zzz-wizard-starting-spells.sql');
