-- BOOK-INGEST-AUDIT F62: the Totem Warrior's supernatural P.E. "turns the
-- warrior into a mega-damage creature. Simply change his combined S.D.C. and
-- hit points into an M.D.C. total. This is a constant state of being, even when
-- in human form" (Spirit West printed 42, cache p043). The class prints no hit
-- point or S.D.C. formula, so compose.js supplies the core ones; with
-- `mdc_from_hp_sdc: true` the wizard rolls both and stores their sum as the
-- M.D.C. maximum, and a level-up adds the hit point formula's per-level dice to
-- it. The note's "which no field expresses" goes, because one now does.
--
-- The Totem Warrior only. The premise audit found the other two classes F62
-- named are different: the Psycho-Stalker's conversion is TEMPORARY, bought
-- with I.S.P., and its note already says so; the Spirit Warrior converts only
-- through its Earth or Plant realm, which a class-wide flag cannot say - filed
-- as F64. Production holds no character of any of the three.

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         char(10) || 'ppe_base: ',
         char(10) || 'mdc_from_hp_sdc: true' || char(10) || 'ppe_base: '),
         'the book then converts the combined S.D.C. and hit points into M.D.C., which no field expresses, so that is a special ability rather than an mdc_base.',
         'the book then converts the combined S.D.C. and hit points into M.D.C., which mdc_from_hp_sdc: true does: both are rolled as usual and stored as one M.D.C. maximum (BOOK-INGEST-AUDIT F62).'),
       updated_at = datetime('now')
 WHERE class_id = 'totem-warrior' AND instr(markdown, 'mdc_from_hp_sdc') = 0;

SELECT 'the Totem Warrior converts S.D.C. and hit points into M.D.C.' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'totem-warrior' AND deleted_at IS NULL
   AND instr(markdown, char(10) || 'mdc_from_hp_sdc: true' || char(10)) > 0;
SELECT 'and no other live class does' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE deleted_at IS NULL AND instr(markdown, 'mdc_from_hp_sdc: true') > 0;
SELECT 'its note no longer says no field expresses it' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'totem-warrior'
   AND instr(markdown, 'which no field expresses, so that is a special ability rather than an mdc_base') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f62-totem-warrior-mdc.sql');
