-- The Sovietski Soldier gains a restriction line naming the Sovietski cyborg
-- bodies, now that they are vessel rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-sovietski-soldier-cyborg-bodies.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-sovietski-soldier-cyborg-bodies.sql
--
-- WHY. Rifts World Book 17: Warlords of Russia prints five Sovietski military
-- cyborgs (printed 214-224). Two of them say whose skills they use: the Light
-- Machine entry (printed 214) points to the Sovietski Soldier and to the Light
-- Machine O.C.C., and the Heavy Machine entry (printed 215) says to see the
-- Sovietski Soldier for skills and training. So a Sovietski Soldier is the
-- class, and the body is a vessel row, the way ngr-cyborg-soldier names its
-- chassis (~029-class-vessel-notes.sql): a restriction line, no gear pointer,
-- because the body is the character and not something issued to it.
--
-- The other three (Thunderhammer, Thunderstrike, Thunderstorm) print no
-- O.C.C., no skill list and no pointer to one. They are vessel rows and the
-- line says so; it does not claim them for this class.
--
-- The rows are created by add-warlords-of-russia-cyborgs.sql, in the same PR.
-- add-sovietski-soldier-class.sql was applied in #1612 and is left as it is;
-- this file sorts after it. The statement is guarded on the line not being
-- there yet, so a second run changes nothing.

UPDATE imported_classes
   SET markdown = replace(markdown,
         char(10) || 'restrictions:' || char(10),
         char(10) || 'restrictions:' || char(10) || '  - "CYBORG BODIES ARE VESSEL ROWS. A soldier who is a full conversion cyborg uses these skills with one of two bodies: sovietski-light-machine-cyborg (printed 214, which points here and to the Light Machine O.C.C.) or sovietski-heavy-machine-cyborg (printed 215, which says to see the Sovietski Soldier for skills and training). The three Sovietski Shocktrooper-class bodies, thunderhammer-cyborg-shocktrooper, thunderstrike-cyborg-shocktrooper and thunderstorm-artillery-cyborg, are vessel rows as well; their entries print no O.C.C. or skill list."' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sovietski-soldier'
   AND instr(markdown, 'sovietski-heavy-machine-cyborg') = 0
   AND instr(markdown, char(10) || 'restrictions:' || char(10)) > 0;

-- Readbacks: each must return got = want.
SELECT 'the soldier names its two cyborg bodies' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'sovietski-soldier'
   AND instr(markdown, 'sovietski-light-machine-cyborg') > 0 AND instr(markdown, 'sovietski-heavy-machine-cyborg') > 0;
SELECT 'and the line was added once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'sovietski-soldier'
   AND length(markdown) - length(replace(markdown, 'CYBORG BODIES ARE VESSEL ROWS', '')) = length('CYBORG BODIES ARE VESSEL ROWS');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-sovietski-soldier-cyborg-bodies.sql');
