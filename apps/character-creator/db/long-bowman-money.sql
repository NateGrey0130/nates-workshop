-- Long Bowman O.C.C. starting money, Palladium Fantasy RPG 2nd Ed. p.85:
-- "Money: The character starts with 170 in gold."
--
-- Guarded on the field being absent, so re-running it cannot append a second
-- line, and so it does nothing to a class that has already been re-imported
-- with the value in place.
UPDATE imported_classes
   SET markdown = replace(markdown, 'ppe_base: "2d6"',
                          'ppe_base: "2d6"' || char(13) || char(10) || 'starting_money: 170'),
       updated_at = datetime('now')
 WHERE class_id = 'long-bowman'
   AND instr(markdown, 'ppe_base: "2d6"') > 0
   AND instr(markdown, 'starting_money') = 0;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('long-bowman-money.sql');
