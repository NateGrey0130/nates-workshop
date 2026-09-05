-- RETRO-AUDIT R11 (ley-line-rifter row): the six starting picks the book prints
-- from named lists, and the 3/3 split it prints for the other six.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r11-ley-line-rifter.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r11-ley-line-rifter.sql
--
-- THE BOOK. Rifts Ultimate Edition printed 117 (rue cache p120, the registry's
-- +3 offset), Ley Line Rifter item 10:
--
--   "Initial Spell Knowledge (Rifter). Select three spells from (Invocation)
--    spell level one and three from level two. Then select four from List A and
--    two from List B, below."
--
-- FOUR groups, twelve spells. The class carried `spells_starting: 6` with
-- `spell_levels_allowed: [1, 2]`, which is wrong twice:
--   * the four-from-A and two-from-B were not granted at all - they sat in the
--     natural_abilities prose under a note saying the picker could not restrict
--     to a named list;
--   * and the six that WERE granted came as one pool of six over levels 1-2,
--     so a Rifter could take six level-two spells where the book gives three
--     and three.
--
-- The second half is not what R11 described - it says "six starting spell picks
-- sit in prose". Fixed here anyway, because it is the same six lines of YAML and
-- leaving a known-loose grant while editing that exact block would be choosing
-- to ship it. ley-line-rifter-spells-per-level.sql had already flagged "four
-- separate starting groups" and deferred it.
--
-- `spells_starting` is the TOTAL and must move with the groups (js/leveling.js),
-- so 6 becomes 12.
--
-- `from_list` RESOLVES IN A STARTING GROUP ONLY SINCE THIS CHANGE. It was
-- silently ignored before: the group kept `spell_levels_allowed` instead, so
-- `{ count: 4, from_list: "A" }` would have rendered a picker of level-1 and
-- level-2 spells containing NONE of List A, whose lowest entry is spell level 4.
-- The app change ships in the same PR. Applying this script against an older
-- deploy would produce exactly that silent wrong picker, which is the ordering
-- rule's whole point.
--
-- All 38 names in the two lists resolve against the catalog, re-counted
-- --remote on 2026-09-04: List A 17, List B 21, 38 of 38 present. That was NOT
-- true when the original note was written - ley-line-rifter-spells-per-level.sql
-- records only 3 of 17 and 13 of 21 resolving then, and
-- add-book-of-magic-rift-spells.sql filled the gap and sorts before it.

UPDATE imported_classes
   SET markdown = replace(markdown,
'  spells_starting: 6
  spell_levels_allowed: [1, 2]',
'  spells_starting: 12
  spell_levels_allowed: [1, 2]
  # RUE printed 117 item 10: three from spell level one, three from level two,
  # four from List A and two from List B. Four groups, not one pool of six -
  # `spells_starting` is the total. RETRO-AUDIT R11.
  spells_starting_groups:
    - { count: 3, spell_levels: [1], note: "Three Invocations of spell level one." }
    - { count: 3, spell_levels: [2], note: "Three Invocations of spell level two." }
    - { count: 4, from_list: "A", note: "Four from List A. Rifters cast these at half the usual P.P.E. cost." }
    - { count: 2, from_list: "B", note: "Two from List B. Rifters cast these at half the usual P.P.E. cost." }')
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, 'spells_starting: 6') > 0;

-- The natural_abilities note said the lists live there BECAUSE the picker could
-- not restrict to one. The lists stay - they carry the halved P.P.E. costs the
-- catalog has nowhere to put - but the reason was false and is corrected.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'the named lists are recorded in natural_abilities because the picker cannot restrict to a named list, and several List A spells are not yet in the spell catalog',
       'the four from List A and two from List B are granted as starting groups bounded by those named lists (RETRO-AUDIT R11, 2026-09-04). This note said the picker could not restrict to a named list and that several List A spells were missing from the catalog; the first was false, and the second stopped being true when add-book-of-magic-rift-spells.sql landed - all 38 names resolve. The lists remain in natural_abilities because they carry the HALVED P.P.E. costs the book prints in parentheses, which no catalog column holds')
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, 'because the picker cannot restrict to a named list') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the rifter starts with twelve spells in four groups' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, 'spells_starting: 12') > 0
   AND instr(markdown, 'count: 4, from_list: "A"') > 0
   AND instr(markdown, 'count: 2, from_list: "B"') > 0
   AND instr(markdown, 'count: 3, spell_levels: [1]') > 0
   AND instr(markdown, 'count: 3, spell_levels: [2]') > 0;

-- Matched on the OLD wording, which the replacement does not reproduce - the
-- readback-quotes-its-own-phrase trap, which fired three times in this menu.
SELECT 'the false picker claim is gone' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, 'because the picker cannot restrict to a named list') > 0;

-- The two lists and the per-level schedule are untouched: this ADDS starting
-- groups and changes one integer.
SELECT 'the lists and the level-up schedule are unchanged' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, '"Ley Line Transmission", "Rift to Limbo"') > 0
   AND instr(markdown, '- { level: 2, count: 1, from_list: "A" }') > 0
   AND instr(markdown, '- { level: 2, count: 1, from_list: "B" }') > 0;

-- THERE IS ONE LIVE CHARACTER ON THIS CLASS, and the premise audit said there
-- were none - it queried `class_id` only, and a Ley Line Rifter is an O.C.C., so
-- it sits in `occ_class_id`. Character 9917 is an Asgardian High Elf / Ley Line
-- Rifter holding six spells, all of spell level one.
--
-- The change cannot refuse them, and that was PROVED rather than reasoned:
-- functions/api/character-creator/_lib/validate-character.js was run against
-- that character's real `powers` with the class before and after - zero spell
-- violations both times. The reason it is safe is structural: `allowance` rises
-- 6 -> 12 and the check is `chosen > allowance`; `capPools` still gate on spell
-- levels [1] and [2], which is the same {1,2} as before; and the 38 names in
-- Lists A and B are ADDED to what passes. Strictly more permissive.
--
-- So the assertion is the safety property, not a headcount: no character on this
-- class holds a spell the new pool would reject. A spell qualifies if it is
-- spell level 1 or 2, or named in either list.
SELECT 'no character on this class holds a spell the new pool rejects' AS assertion,
       count(*) AS got, 0 AS want
  FROM characters c
  JOIN json_each(c.powers) p
  LEFT JOIN spells s ON s.name = json_extract(p.value, '$.name')
 WHERE (c.occ_class_id = 'ley-line-rifter' OR c.class_id = 'ley-line-rifter')
   AND json_extract(p.value, '$.type') = 'spell'
   AND COALESCE(s.level, 99) > 2
   AND instr((SELECT markdown FROM imported_classes WHERE class_id = 'ley-line-rifter'),
             '"' || json_extract(p.value, '$.name') || '"') = 0;

-- Records this run. Both statements guard themselves, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r11-ley-line-rifter.sql');
