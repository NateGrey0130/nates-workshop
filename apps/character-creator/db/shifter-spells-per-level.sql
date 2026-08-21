-- Shifter: the spells it learns as it advances. Rifts Ultimate Edition,
-- Shifter O.C.C., "starting at level two".
--
-- The book gives THREE spells a level, each from a different place:
--
--   "Starting at level two, the Shifter can choose one spell from the following
--    list plus one Protection or Summoning spell also in this list: [34 named
--    spells] ... and any Summoning spell that may be desired, excluding weather
--    summoning.
--    In addition, the Shifter can select one non-dimension related or control
--    based spell, but they are limited to spells equal to or less than the
--    Shifter's current level of experience."
--
-- Modelled as two grants a level rather than three, because the difference
-- between the first two is a restriction NOTHING CAN CHECK:
--
--   count 2, from the named list  - the list is enforced; "one of the two must
--                                   be Protection or Summoning" is a note,
--                                   because spells carry no such tag
--   count 1, own level or lower   - the level cap is enforced; "non-dimension
--                                   related or control based" is a note, for
--                                   the same reason
--
-- Spells have a name, a level and a cost and nothing else. Classifying three
-- hundred of them by reading their names would be exactly the guessing the
-- import rules forbid, so the rule is shown where the choice is made.
--
-- THREE NAMES USE THE CATALOG'S SPELLING rather than the book's, checked
-- against the spells table before this was written:
--   "Control and Enslave Entity" -> "Control & Enslave Entity"
--   "Dessicate the Supernatural" -> "Desiccate the Supernatural"  (the page
--                                   misspells it; the catalog does not)
--   "Phantom Mount"              -> "Air: Phantom Mount"
--
-- FIFTEEN OF THE THIRTY-FOUR ARE NOT IN THE CATALOG AT ALL - Close Rift, D-Step,
-- Dimensional Teleport, Energy Sphere, Influence the Beast, Mystic Portal, Plane
-- Skip, Power Bolt, Protection Circle: Superior, Reality Flux, Rift to Limbo,
-- Rift Teleportation, Tame Beast, Teleport: Superior and Time Hole. They are the
-- dimensional spells the class is built around, and the chapter holding them has
-- not been imported. They stay in the list on purpose: the picker reports names
-- it cannot find rather than silently shrinking, and they light up the day those
-- spells are imported.
--
-- Guarded with instr(), because `_` is a single-character wildcard in LIKE.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  type: "spell"',
      '  type: "spell"' || char(10) ||
      '  spells_per_level_from: ["Banishment", "Charm", "Close Rift", "Commune with Spirits", "Compulsion", "Control & Enslave Entity", "D-Step", "Desiccate the Supernatural", "Dimensional Teleport", "Dispel Magic Barriers", "Distant Voice", "Domination", "Energy Disruption", "Energy Sphere", "Expel Demons", "Forcebonds", "Influence the Beast", "Ley Line Transmission", "Locate", "Magic Pigeon", "Mystic Portal", "Air: Phantom Mount", "Plane Skip", "Power Bolt", "Protection Circle: Simple", "Protection Circle: Superior", "Reality Flux", "Rift to Limbo", "Rift Teleportation", "Sheltering Force", "Tame Beast", "Teleport: Lesser", "Teleport: Superior", "Time Hole"]' || char(10) ||
      '  spells_per_level_levels: up_to_character_level' || char(10) ||
      '  spells_schedule:' || char(10) ||
      '    - { level: 2, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 2, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 3, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 3, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 4, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 4, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 5, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 5, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 6, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 6, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 7, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 7, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 8, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 8, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 9, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 9, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 10, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 10, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 11, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 11, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 12, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 12, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 13, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 13, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 14, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 14, count: 1, note: "Not dimension-related or control-based" }' || char(10) ||
      '    - { level: 15, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }' || char(10) ||
      '    - { level: 15, count: 1, note: "Not dimension-related or control-based" }'
    )
WHERE class_id = 'shifter'
  AND instr(markdown, '  type: "spell"') > 0
  AND instr(markdown, 'spells_schedule') = 0;

SELECT class_id,
       instr(markdown, 'spells_schedule') > 0 AS has_schedule,
       instr(markdown, 'spells_per_level_from') > 0 AS has_list,
       instr(markdown, 'level: 15, count: 1') > 0 AS has_tail
FROM imported_classes
WHERE class_id = 'shifter';

INSERT INTO data_script_runs (filename) VALUES ('shifter-spells-per-level.sql');
