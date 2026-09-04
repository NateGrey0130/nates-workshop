-- RETRO-AUDIT R3: two races point their occ_restrictions at the retired
-- generic Warlock. Repoint them at the ten per-Force classes.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r3-warlock-references.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r3-warlock-references.sql
--
-- WHY THIS EXISTS. retire-warlock-generic.sql soft-deletes `warlock`, and
-- `occ_restrictions.only` is a list of CLASS IDS. Two races name it:
--   norse-giant     - "The other 20% study magic, limited to witch, warlock,
--                      necromancer or ley line walker"
--   scorpion-person - "Also priests of any Babylonian god, ley line walkers,
--                      shifters, warlocks and diabolists"
-- Left alone, both would offer a Warlock that no longer exists, which is a
-- reference that fails OPEN - the pairing simply disappears from the picker with
-- no error. The regression suite caught it: "every occupation they name is a
-- real O.C.C." went red the moment the generic class was retired.
--
-- ALL TEN, not a subset. Neither book restricts which Elemental Force its race
-- may bond with; the restriction is on being a Warlock at all, so narrowing to
-- (say) the four one-Force classes would invent a rule neither page prints.
--
-- This sorts after both add-*-class.sql files and after every add-warlock-*,
-- so a clean rebuild has all eleven classes in hand before it rewrites either
-- list.

UPDATE imported_classes
   SET markdown = replace(markdown,
       '"witch", "warlock", "ley-line-walker"',
       '"witch", "warlock-air", "warlock-earth", "warlock-fire", "warlock-water", "warlock-air-earth", "warlock-air-fire", "warlock-air-water", "warlock-earth-fire", "warlock-earth-water", "warlock-fire-water", "ley-line-walker"')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, '"witch", "warlock", "ley-line-walker"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '"shifter", "warlock", "diabolist"',
       '"shifter", "warlock-air", "warlock-earth", "warlock-fire", "warlock-water", "warlock-air-earth", "warlock-air-fire", "warlock-air-water", "warlock-earth-fire", "warlock-earth-water", "warlock-fire-water", "diabolist"')
 WHERE class_id = 'scorpion-person'
   AND instr(markdown, '"shifter", "warlock", "diabolist"') > 0;

-- The prose beside each list says "warlock" in the singular, which is still
-- true of the book and now under-describes the data. Say which.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'limited to witch, warlock, necromancer or ley line walker; this catalog has no Necromancer O.C.C. yet.',
       'limited to witch, warlock, necromancer or ley line walker; this catalog has no Necromancer O.C.C. yet. The Warlock is ten classes here, one per Elemental Force and one per pair (RETRO-AUDIT R3, 2026-09-04), and all ten are open to a norse giant because the book restricts being a Warlock rather than which Force.')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, 'The Warlock is ten classes here') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'shifters, warlocks and diabolists. Techno-wizards are extremely rare.',
       'shifters, warlocks and diabolists. Techno-wizards are extremely rare. The Warlock is ten classes here, one per Elemental Force and one per pair (RETRO-AUDIT R3, 2026-09-04), and all ten are open because the book restricts being a Warlock rather than which Force.')
 WHERE class_id = 'scorpion-person'
   AND instr(markdown, 'The Warlock is ten classes here') = 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'neither race still names the retired generic warlock' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('norse-giant', 'scorpion-person')
   AND (instr(markdown, '"witch", "warlock",') > 0
     OR instr(markdown, '"shifter", "warlock",') > 0);

SELECT 'both races now name all ten per-Force warlocks' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('norse-giant', 'scorpion-person')
   AND instr(markdown, '"warlock-air", "warlock-earth", "warlock-fire", "warlock-water", "warlock-air-earth", "warlock-air-fire", "warlock-air-water", "warlock-earth-fire", "warlock-earth-water", "warlock-fire-water"') > 0;

-- The rest of each list is untouched: this replaces one id with ten and drops
-- nothing. Checked on the ids that bracket the replacement in each class.
SELECT 'the surrounding occupations are unchanged' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'norse-giant' AND instr(markdown, '"witch", "warlock-air"') > 0
        AND instr(markdown, '"warlock-fire-water", "ley-line-walker"') > 0)
    OR (class_id = 'scorpion-person' AND instr(markdown, '"shifter", "warlock-air"') > 0
        AND instr(markdown, '"warlock-fire-water", "diabolist"') > 0);

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r3-warlock-references.sql');
