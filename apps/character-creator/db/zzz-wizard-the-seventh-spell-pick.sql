-- The wizard's SEVENTH starting spell - the level-one instance of a rule the
-- app grants from level two - and five group notes that should never have been
-- written.
--
-- zzz-wizard-starting-spells.sql moved the wizard's six picks to
-- `spells_starting_groups` and recorded one thing it deliberately left alone:
-- the second half of the same book paragraph. This is that half, taken.
--
-- THE PARAGRAPH. Palladium Fantasy RPG, printed page 106 (pf cache p108),
-- "Wizard O.C.C. Abilities & Bonuses", item 2, "Additional Spells", both
-- sentences:
--
--   "The player may select two spells of choice each level one and two, and one
--    from level three and four. At each new level of experience, starting at
--    level one, it may be assumed that the character has been able to figure
--    out or learn one new spell - select one from any level up to the
--    character's own level of achievement/experience."
--
-- The first sentence is the six. The second is a rule that runs for the life of
-- the character, and it names its first instance: LEVEL ONE. The class holds it
-- as `spells_per_level: 1` with `spells_per_level_levels: up_to_character_level`,
-- and `perLevelGrants` grants from `fromLevel + 1` - by design, so that
-- levelling 3 to 4 does not re-offer level 3. Creation therefore skipped the
-- level-one instance, and the wizard gained fourteen of these across levels 1
-- to 15 where the sentence describes fifteen.
--
-- WHY THIS IS A TRANSCRIPTION AND NOT AN INTERPRETATION. The book uses both
-- forms and distinguishes them. The Mind Mage's additional psionics, printed
-- page 161: "for each additional level of experience, STARTING AT LEVEL TWO" -
-- the phrase zzz-fix-psionic-powers-per-level.sql built that class's schedule
-- from. The wizard's spells, printed page 106: "STARTING AT LEVEL ONE". When
-- this book means level two it says level two.
--
-- ONLY THIS CLASS. Every published class was swept for the phrase against live
-- D1. Nine carry it; in eight it sits on a P.P.E. or I.S.P. pool formula
-- (Druid, Summoner, Diabolist, Chiang-Ku Dragon, Mind Mage, Psi-Healer,
-- Psychic Sensitive) or on I.S.P. specifically (Psi-Mystic, whose spells are a
-- separate rule that does not use it). The wizard is the only class where it
-- lands on a per-level SPELL rule. That sweep reads what each class
-- transcribed, so a class that paraphrased the phrase away would not appear in
-- it; within the Palladium Fantasy cache itself, checked directly, p.106 is the
-- only spell-side instance.
--
-- NO DOUBLE COUNT. The new group is a STARTING pick; `perLevelGrants` still
-- begins at level two. Levels 1 to 15 now yield fifteen of these - one at
-- creation, fourteen on the way up - and 21 picks over a career, which is the
-- paragraph's 6 + 15.
--
-- Its spell level is one, not "any level up to the character's own", because
-- the character's own level at creation IS one. The general cap keeps working
-- for every later instance.
--
-- AND THE NOTES COME OFF. zzz-wizard-starting-spells.sql gave each group a
-- `note` restating its own gate - "Two spells of choice from spell level one"
-- above a picker already captioned "2 spells from levels 1". `note` is not a
-- caption: `startingSpellHtml` renders it as "<note> - the catalog cannot check
-- this one, so it is yours to honour", the posture the Mind Mage's "Mind Wipe,
-- Psi-Sword and Mentally Possess Others cannot be selected until third level"
-- needs. A `spell_levels` gate is precisely what the catalog DOES check, so
-- every one of those five lines told the player the opposite of the truth about
-- the picker underneath it. They are removed rather than reworded; the book's
-- own sentence lives in the extraction notes, where an explanation belongs.
--
-- FILENAME. `zzz-wizard-the-seventh-...`, not `zzz-wizard-starting-spells-
-- seventh.sql`: `-` is 0x2D and `.` is 0x2E, so the obvious name would sort
-- BEFORE the file it amends, and a clean rebuild would find no anchor and
-- silently do nothing. `the` sorts after `starting`, which is what this needs.
--
-- Every statement is guarded, and the guards are written to reach the same end
-- state from BOTH starting points: a database rebuilt from the glob (four
-- noted groups) and the live one (five groups, the fifth carrying the note this
-- script first shipped before the notes were reconsidered).

-- 1. The total.
UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  spells_starting: 6' || char(10) ||
      '  spells_starting_groups:',
      '  spells_starting: 7' || char(10) ||
      '  spells_starting_groups:'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, '  spells_starting: 7') = 0;

-- 2. The fifth group, on a database that has never had it.
UPDATE imported_classes
SET markdown = replace(
      markdown,
      '    - { count: 1, spell_levels: [4], note: "One spell of choice from spell level four" }',
      '    - { count: 1, spell_levels: [4], note: "One spell of choice from spell level four" }' || char(10) ||
      '    - { count: 1, spell_levels: [1] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, '    - { count: 1, spell_levels: [1] }') = 0
  AND instr(markdown, 'and this is that rule at level one.') = 0;

-- 3. The fifth group, on the live database, which already has it WITH a note.
UPDATE imported_classes
SET markdown = replace(
      markdown,
      '    - { count: 1, spell_levels: [1], note: "One more spell of choice from spell level one - the book gives a wizard one new spell at each level of experience starting at level one, and this is that rule at level one." }',
      '    - { count: 1, spell_levels: [1] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'and this is that rule at level one.') > 0;

-- 4-7. The four restated notes.
UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { count: 2, spell_levels: [1], note: "Two spells of choice from spell level one" }',
      '    - { count: 2, spell_levels: [1] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'note: "Two spells of choice from spell level one"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { count: 2, spell_levels: [2], note: "Two spells of choice from spell level two" }',
      '    - { count: 2, spell_levels: [2] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'note: "Two spells of choice from spell level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { count: 1, spell_levels: [3], note: "One spell of choice from spell level three" }',
      '    - { count: 1, spell_levels: [3] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'note: "One spell of choice from spell level three"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { count: 1, spell_levels: [4], note: "One spell of choice from spell level four" }',
      '    - { count: 1, spell_levels: [4] }'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'note: "One spell of choice from spell level four"') > 0;


-- 8. The extraction note, which recorded the seventh pick as a reading left
-- undecided.
UPDATE imported_classes
SET markdown = replace(
      markdown,
      'STILL PROSE, and a reading rather than a bug: the same book paragraph grants one more spell at each new level of experience beginning at level one, which the class holds as spells_per_level and the app grants from level two onward, so the level-one instance of it - a seventh starting pick, if the sentence is meant literally - is not modelled.',
      'The seventh pick is the second half of that same book paragraph: one new spell at each level of experience, starting at level one. The class holds the ongoing rule as spells_per_level and perLevelGrants begins at level two, so the level-one instance is stated as a fifth starting group - one spell from spell level one - and spells_starting is 7. Taken as transcription rather than interpretation: this book distinguishes starting at level one from starting at level two, and the Mind Mage says level two for exactly this shape of rule. Levels 1 to 15 now yield fifteen of these and not fourteen, with no double count, because the per-level grant still begins at two - 21 picks over a career, which is the paragraph''s 6 + 15. The groups carry no note fields: a group note renders as a restriction the catalog cannot check, and a spell_levels gate is exactly what it can.'),
    updated_at = datetime('now')
WHERE class_id = 'wizard'
  AND instr(markdown, 'STILL PROSE, and a reading rather than a bug') > 0;


-- Readbacks. Note what these do NOT assert: both the old note and the new one
-- contain "a seventh starting pick" and "starting at level one", so an instr on
-- either proves nothing. Assert on text the two versions do not share, and on
-- the shape of the block itself.
SELECT class_id,
       instr(markdown, '  spells_starting: 7') > 0 AS total_is_seven,
       instr(markdown, '  spells_starting: 6') = 0 AS old_total_gone,
       instr(markdown, '    - { count: 1, spell_levels: [1] }') > 0 AS fifth_group_present,
       instr(markdown, 'spell_levels: [1], note:') = 0 AS no_note_on_a_level_one_group,
       instr(markdown, 'spell_levels: [2], note:') = 0 AS no_note_on_the_level_two_group,
       instr(markdown, 'spell_levels: [3], note:') = 0 AS no_note_on_the_level_three_group,
       instr(markdown, 'spell_levels: [4], note:') = 0 AS no_note_on_the_level_four_group,
       instr(markdown, 'STILL PROSE') = 0 AS note_no_longer_undecided,
       instr(markdown, 'The seventh pick is the second half') > 0 AS note_rewritten,
       instr(markdown, 'spells_schedule:') = 0 AS no_schedule_came_back
FROM imported_classes
WHERE class_id = 'wizard';

INSERT INTO data_script_runs (filename) VALUES ('zzz-wizard-the-seventh-spell-pick.sql');
