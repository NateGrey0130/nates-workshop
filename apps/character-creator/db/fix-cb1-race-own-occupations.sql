-- Rifts Conversion Book One, batch 4: open the three cb1 races to their own
-- occupations. The Quorian and the Quillback carry an `only` list of the
-- O.C.C.s their Rifts line names, so rifts-quorian-oneiromancer and
-- rifts-quillback-scavenger - each limited to its race by race_restrictions -
-- could not be paired with the race they exist for until they are on it. The
-- Gosai's list is an `except` list and already allows rifts-gosai-assassin.
-- Each race's restriction line pointing at "a separate class" now names it.
--
-- Sorts after add-rifts-quorian-class.sql, add-rifts-quillback-class.sql and
-- add-rifts-gosai-class.sql, which create the rows it edits. Each UPDATE is
-- guarded on the text it replaces still being there and the new text not, so
-- a re-run is a no-op. Pure ASCII, LF.

UPDATE imported_classes SET markdown = replace(markdown, '"ley-line-walker"]', '"ley-line-walker", "rifts-quorian-oneiromancer"]'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quorian' AND instr(markdown, '"ley-line-walker"]') > 0 AND instr(markdown, '"ley-line-walker", "rifts-quorian-oneiromancer"]') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The catalog holds no Temporal Magic O.C.C."', 'The catalog holds no Temporal Magic O.C.C. rifts-quorian-oneiromancer is the Quorian''s own occupation, the Oneiromancer of printed 107."'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quorian' AND instr(markdown, 'The catalog holds no Temporal Magic O.C.C."') > 0 AND instr(markdown, 'The catalog holds no Temporal Magic O.C.C. rifts-quorian-oneiromancer is the Quorian''s own occupation, the Oneiromancer of printed 107."') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '"The Quorian Oneiromancer and the Chant of Dreaming are a separate class."', '"The Quorian Oneiromancer is a separate occupation, rifts-quorian-oneiromancer, which grants the Chant of Dreaming."'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quorian' AND instr(markdown, '"The Quorian Oneiromancer and the Chant of Dreaming are a separate class."') > 0 AND instr(markdown, '"The Quorian Oneiromancer is a separate occupation, rifts-quorian-oneiromancer, which grants the Chant of Dreaming."') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '"sheriffs-deputy"]', '"sheriffs-deputy", "rifts-quillback-scavenger"]'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quillback' AND instr(markdown, '"sheriffs-deputy"]') > 0 AND instr(markdown, '"sheriffs-deputy", "rifts-quillback-scavenger"]') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'are not evidently what is meant."', 'are not evidently what is meant. rifts-quillback-scavenger is the Quillback''s own occupation, the Scavenger of printed 105."'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quillback' AND instr(markdown, 'are not evidently what is meant."') > 0 AND instr(markdown, 'are not evidently what is meant. rifts-quillback-scavenger is the Quillback''s own occupation, the Scavenger of printed 105."') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '"The Quillback Scavenger R.C.C. is a separate class."', '"The Quillback Scavenger R.C.C. is a separate occupation, rifts-quillback-scavenger."'), updated_at = datetime('now')
  WHERE class_id = 'rifts-quillback' AND instr(markdown, '"The Quillback Scavenger R.C.C. is a separate class."') > 0 AND instr(markdown, '"The Quillback Scavenger R.C.C. is a separate occupation, rifts-quillback-scavenger."') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '"The Gosai Assassin R.C.C. and Hand to Hand: Skudasa, which only that R.C.C. may take, are a separate class."', '"The Gosai Assassin R.C.C. is a separate occupation, rifts-gosai-assassin, and Hand to Hand: Skudasa, which only it may take, is a skill row."'), updated_at = datetime('now')
  WHERE class_id = 'rifts-gosai' AND instr(markdown, '"The Gosai Assassin R.C.C. and Hand to Hand: Skudasa, which only that R.C.C. may take, are a separate class."') > 0 AND instr(markdown, '"The Gosai Assassin R.C.C. is a separate occupation, rifts-gosai-assassin, and Hand to Hand: Skudasa, which only it may take, is a skill row."') = 0;

-- Read back: each race names its occupation, and the old wording is gone.
SELECT 'quorian allows the oneiromancer' AS assertion,
       (SELECT instr(markdown, '"rifts-quorian-oneiromancer"]') > 0 FROM imported_classes WHERE class_id = 'rifts-quorian') AS got, 1 AS want;
SELECT 'quillback allows the scavenger' AS assertion,
       (SELECT instr(markdown, '"rifts-quillback-scavenger"]') > 0 FROM imported_classes WHERE class_id = 'rifts-quillback') AS got, 1 AS want;
SELECT 'no race still says a separate class' AS assertion,
       (SELECT count(*) FROM imported_classes WHERE class_id IN ('rifts-quorian', 'rifts-quillback', 'rifts-gosai') AND instr(markdown, 'separate class') > 0) AS got, 0 AS want;

INSERT INTO data_script_runs (filename) VALUES ('fix-cb1-race-own-occupations.sql');
