-- Three corrections from an audit of the Rifts class tags against each class's
-- own text in production, after ~048 to ~051 applied them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~052-class-tags-audit-corrections.sql
--
-- 1. JUICER ASSASSIN loses `evil`. The tag rested on the class's own note that
--    starting at Hand to Hand: Assassin "means an evil alignment by the usual
--    reading". That is an inference written here, not an alignment restriction
--    the book prints, and `evil` is for a class its book restricts.
--
-- 2. ACHILLES NEO-HUMAN loses `flyer`, its only tag. Its flight is the psionic
--    power Telekinetic Flight, and `flyer` means flight without a power or
--    equipment. The Earth/Air Fusionist lost the tag for spell flight on the
--    same reading.
--
-- 3. THE GREAT HORNED DRAGON HATCHLING gets the `magic` block its nine sibling
--    hatchlings carry, with a stated zero. fix-dragon-hatchling.sql removed the
--    block because it granted four spells of levels 1-2, where the book says
--    the hatchling knows none and learns them from third level. Since then a
--    stated `spells_starting: 0` has become the modelled way to say exactly
--    that (js/leveling.js, "A STATED ZERO IS AN ANSWER"), and without the block
--    this was the one hatchling the Magic tag could not find. It still knows
--    no spells. The extraction note that described the removal is rewritten.
--
-- A tilde script, after the four it corrects. Each statement is guarded on the
-- text it replaces, so a re-run is a no-op. The tilde number is claimed at merge.

UPDATE imported_classes
   SET markdown = replace(markdown, 'tags: [ranged, stealth, augmented, evil]', 'tags: [ranged, stealth, augmented]'),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-assassin'
   AND instr(markdown, 'tags: [ranged, stealth, augmented, evil]') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, replace('~~tags: [flyer]~~', '~~', char(10)), char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'neo-human'
   AND instr(markdown, replace('~~tags: [flyer]~~', '~~', char(10))) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         replace('~~psionics:~~', '~~', char(10)),
         replace('~~magic:~~  type: "spell"~~  spells_starting: 0~~psionics:~~', '~~', char(10))),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling'
   AND instr(markdown, replace('~~magic:~~', '~~', char(10))) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         replace('  - The hatchling knows NO spells. The class previously granted four spells of levels~~    1-2 through a `magic` block, which the book contradicts directly: spells can first~~    be learned at third level, two per level thereafter.', '~~', char(10)),
         replace('  - The hatchling knows NO spells, and the `magic` block says so with a stated~~    spells_starting of 0, as its sibling hatchlings do. An earlier correction removed~~    the block outright because it had granted four spells of levels 1-2; spells can~~    first be learned at third level, two per level thereafter.', '~~', char(10))),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling'
   AND instr(markdown, 'which the book contradicts directly') > 0;

-- Read the result back.
SELECT 'the Juicer Assassin carries its three tags and no evil' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'juicer-assassin'
   AND instr(markdown, replace('~~tags: [ranged, stealth, augmented]~~', '~~', char(10))) > 0;

SELECT 'the Neo-Human has no tags line' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'neo-human'
   AND instr(markdown, replace('~~tags:', '~~', char(10))) = 0;

SELECT 'the Great Horned hatchling states a magic block with zero spells' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling'
   AND instr(markdown, replace('~~magic:~~  type: "spell"~~  spells_starting: 0~~psionics:~~', '~~', char(10))) > 0;

SELECT 'its note no longer says the block is gone' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling'
   AND instr(markdown, 'which the book contradicts directly') = 0
   AND instr(markdown, 'a stated') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~052-class-tags-audit-corrections.sql');
