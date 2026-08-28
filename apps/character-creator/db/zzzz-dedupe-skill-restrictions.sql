-- The duplicate skill-restriction entries a rebuild leaves in mystic and
-- burster (REBUILD-AUDIT.md F7, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-dedupe-skill-restrictions.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-dedupe-skill-restrictions.sql
--
-- THE FOURTH CONSEQUENCE OF ONE PAIR OF FILES, and the first found by looking
-- rather than by accident. operations.md's `zz-` row records that
-- fix-class-skill-names-to-rue.sql was applied to production BY HAND, LAST, so
-- it won there, while in a repo build it sorts under `f` and three later
-- scripts wrote the pre-RUE names back. `zz-canonicalise-class-skill-names.sql`
-- was written to sort after all of them and re-apply the rename. It fixed the
-- NAMES. It did not fix this.
--
-- What it left, traced through a rebuild file by file:
--
--   1. add-burster-class.sql / add-mystic-class.sql write
--      except: ["W.P. Heavy", "W.P. Heavy Energy Weapons",
--               "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]
--
--   2. fix-class-skill-names-to-rue.sql (sorts `fix-cl`) renames the first two
--      into the second two, so the list now holds each name TWICE.
--
--   3. fix-dead-skill-restrictions.sql (sorts `fix-de`, i.e. AFTER) exists to
--      collapse that four-name list to two - but its guard matches the
--      PRE-RENAME string, which no longer exists. It matches nothing and the
--      duplicate stands.
--
-- The mystic's Pilot list is the same shape one step longer, and there the
-- corrective script is the culprit: fix-dead-skill-restrictions.sql's statement
-- removing "Warships" also misses its renamed guard, "Warships" survives, and
-- zz-canonicalise-class-skill-names.sql then renames it to
-- "Military: Warships & Patrol Boats" - WHICH IS ALREADY IN THE LIST.
--
-- On production none of this happened: the rename ran last, by hand, so the
-- collapse ran first and was right. This is repo-side repair only, and applying
-- it to --remote changes nothing. It is applied there anyway because
-- drift-check reports a data script with no data_script_runs row as
-- DATA SCRIPT NOT RUN and exits 1 - see F5's outcome note.
--
-- NOT guarded on class_id. A repeated entry in an `except:` list is never
-- intentional, so the guard is the doubled string itself: any class that
-- acquires the same shape later is fixed by the same statement.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after
-- zz-canonicalise-class-skill-names.sql, which creates the Pilot duplicate, and
-- after fix-dead-skill-restrictions.sql, whose job this finishes. `zzzz-d`
-- sorts after `zzzz-c`.

-- -- 1. The two heavy W.P. names, listed twice (mystic and burster) --

UPDATE imported_classes
SET markdown = replace(markdown,
      '["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]',
      '["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]'),
    updated_at = datetime('now')
WHERE deleted_at IS NULL
  AND instr(markdown, '["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]') > 0;

-- -- 2. The mystic's Pilot list, holding Warships & Patrol Boats twice --
-- The SECOND occurrence is the one the book's list ends on, so the FIRST is
-- the one introduced by the rename and the one removed here. The result is
-- production's line exactly.

UPDATE imported_classes
SET markdown = replace(markdown,
      '"Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Robots & Power Armor"',
      '"Military: Tanks & APCs", "Robots & Power Armor"'),
    updated_at = datetime('now')
WHERE deleted_at IS NULL
  AND instr(markdown, '"Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Robots & Power Armor"') > 0;

-- Reads the result back rather than trusting the exit code.
--   wp_lists_still_doubled     0 = no class lists the two heavy W.P. names twice
--   pilot_lists_still_doubled  0 = no class lists Warships & Patrol Boats twice
--   mystic_warships_mentions 1 = the mystic's Pilot list names Warships &
--                              Patrol Boats ONCE. It named it twice, which is
--                              the bug. Counted by length-difference, the plain
--                              idiom, rather than by parsing the line.
SELECT (SELECT count(*) FROM imported_classes
         WHERE deleted_at IS NULL
           AND instr(markdown, '"W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons"') > 0) AS wp_lists_still_doubled,
       (SELECT count(*) FROM imported_classes
         WHERE deleted_at IS NULL
           AND instr(markdown, '"Military: Warships & Patrol Boats", "Robots & Power Armor"') > 0) AS pilot_lists_still_doubled,
       (SELECT (length(markdown) - length(replace(markdown, 'Military: Warships & Patrol Boats', '')))
               / length('Military: Warships & Patrol Boats')
          FROM imported_classes WHERE class_id = 'mystic') AS mystic_warships_mentions;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-dedupe-skill-restrictions.sql');
