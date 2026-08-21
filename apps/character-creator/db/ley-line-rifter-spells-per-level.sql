-- Ley Line Rifter: the spells it learns as it advances. Rifts Ultimate Edition,
-- Ley Line Rifter O.C.C., bullet 11 "Learning New Spells".
--
--   "A new spell from List A and B can be learned by communing with the ley
--    line. This can occur upon reaching a new mystic plateau (new level of
--    experience) ... At the end of the trance he knows one spell (pick one)
--    from each list."
--
-- One from each list, at every level from two upward. Two grants a level, each
-- bounded by its own list - which is why `from_list` takes a NAME here rather
-- than the `true` the Shifter uses: that class has one list, this one has two.
--
-- Both lists are declared once under `spell_lists` and referenced by the
-- schedule, rather than written out at all fourteen levels.
--
-- BULLET 10, the STARTING selection, is deliberately not here. It reads "three
-- spells from level one and three from level two, then four from List A and two
-- from List B" - four separate starting groups, where the format has one
-- `spells_starting` count and one level list. That is a different shape from
-- anything the per-level schedule expresses and it belongs to the wizard's
-- Powers step rather than its Advancement step. `spells_starting: 6` and
-- `spell_levels_allowed: [1, 2]` are left exactly as they are: they describe
-- the first six of the twelve correctly, and nothing here makes them wronger.
--
-- MOST OF LIST A IS NOT IN THE CATALOG. Three of its seventeen resolve today -
-- Dimensional Portal, Ley Line Tendril Bolts and Ley Line Transmission. The
-- Rift & Ley Line Magic chapter has never been imported, and it is the chapter
-- this class is built around. Eight of List B's twenty-one are missing too.
-- The names stay: the picker reports what it cannot find rather than silently
-- shrinking, and importing that chapter lights up this class AND the Shifter's
-- fifteen missing spells at once.
--
-- Guarded with instr(), because `_` is a single-character wildcard in LIKE.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  spell_levels_allowed: [1, 2]',
      '  spell_levels_allowed: [1, 2]' || char(10) ||
      '  spell_lists:' || char(10) ||
      '    A: ["Dimensional Portal", "Ley Line Fade", "Ley Line Ghost", "Ley Line Phantom", "Ley Line Restoration", "Ley Line Resurrection", "Ley Line Shutdown", "Ley Line Storm Defense", "Ley Line Tendril Bolts", "Ley Line Time Capsule", "Ley Line Time Flux", "Ley Line Transmission", "Rift to Limbo", "Rift Teleportation", "Rift Triangular Defense System", "Summon Ley Line Storm", "Swallowing Rift"]' || char(10) ||
      '    B: ["Astral Projection", "Calling", "Call Lightning", "Chameleon", "Close Rift", "Concealment", "Detect Concealment", "Dispel Magic Barriers", "Energy Disruption", "Escape", "Locate", "Mystic Portal", "Negate Magic", "Plane Skip", "Reality Flux", "Second Sight", "Shadow Meld", "Teleport: Lesser", "Teleport: Superior", "Time Hole", "Time Slip"]' || char(10) ||
      '  spells_schedule:' || char(10) ||
      '    - { level: 2, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 2, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 3, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 3, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 4, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 4, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 5, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 5, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 6, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 6, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 7, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 7, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 8, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 8, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 9, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 9, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 10, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 10, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 11, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 11, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 12, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 12, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 13, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 13, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 14, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 14, count: 1, from_list: "B" }' || char(10) ||
      '    - { level: 15, count: 1, from_list: "A" }' || char(10) ||
      '    - { level: 15, count: 1, from_list: "B" }'
    )
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, '  spell_levels_allowed: [1, 2]') > 0
  AND instr(markdown, 'spells_schedule') = 0;

SELECT class_id,
       instr(markdown, 'spells_schedule') > 0 AS has_schedule,
       instr(markdown, 'spell_lists') > 0 AS has_lists,
       instr(markdown, 'level: 15, count: 1, from_list: "B"') > 0 AS has_tail
FROM imported_classes
WHERE class_id = 'ley-line-rifter';

INSERT INTO data_script_runs (filename) VALUES ('ley-line-rifter-spells-per-level.sql');
