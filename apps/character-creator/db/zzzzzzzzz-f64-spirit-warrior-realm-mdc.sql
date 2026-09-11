-- BOOK-INGEST-AUDIT F64: the Spirit Warrior's Earth Realm "will convert the
-- character's hit points and S.D.C. to M.D.C., plus an additional 1D4x10
-- M.D.C." (Spirit West printed 44, cache p045), and the Plant Realm's is
-- "Identical ... do not combine the bonuses to the P.E. attribute, but do
-- combine the M.D.C." (printed 47, cache p048). Three of six realms are chosen,
-- so a character holding neither - four of the twenty combinations - keeps its
-- S.D.C. and hit points.
--
-- F62's `mdc_from_hp_sdc` could only be set on a CLASS, which would convert all
-- twenty. F64 lets a chosen ability carry it: applyAbilities folds it onto the
-- composed class when the realm is taken. Each of the two realms gains the flag
-- and a `pools.mdc: "1d4x10"` bonus, so two converting realms add two 1D4x10s,
-- and the notes stop saying no field expresses the conversion. The +1D6 P.E.
-- stays unstored, for the reason the note already gives.
--
-- Sorts after zzzzzzzzz-f62-totem-warrior-mdc.sql, whose readback counts live
-- classes carrying 'mdc_from_hp_sdc: true' and must still see only one when it
-- runs. Production holds no Spirit Warrior character (queried 2026-09-11).

UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         'Only the P.S. dice are stored; see extraction_notes."' || char(10) || '    bonuses: { attributes: { PS: "2d6" } }',
         'The P.S. dice, the conversion and its 1D4x10 M.D.C. are stored; the P.E. dice are not - see extraction_notes."' || char(10) || '    mdc_from_hp_sdc: true' || char(10) || '    bonuses: { attributes: { PS: "2d6" }, pools: { mdc: "1d4x10" } }'),
         'The P.E. dice are not stored; see extraction_notes."',
         'The conversion and its 1D4x10 M.D.C. are stored; the P.E. dice are not - see extraction_notes."' || char(10) || '    mdc_from_hp_sdc: true' || char(10) || '    bonuses: { pools: { mdc: "1d4x10" } }'),
         'and every conversion of S.D.C. and hit points into M.D.C., which no field expresses.',
         'The conversion of S.D.C. and hit points into M.D.C. is stored on those two realms instead, as mdc_from_hp_sdc: true with a pools.mdc bonus of 1D4x10 each, and applies only to a character who takes one; taken together the two combine their M.D.C., as printed 47 says (BOOK-INGEST-AUDIT F64).'),
       updated_at = datetime('now')
 WHERE class_id = 'spirit-warrior' AND instr(markdown, 'mdc_from_hp_sdc') = 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'two Spirit Warrior realms carry the conversion flag' AS assertion,
       (length(markdown) - length(replace(markdown, '    mdc_from_hp_sdc: true', ''))) / length('    mdc_from_hp_sdc: true') AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'spirit-warrior' AND deleted_at IS NULL;
SELECT 'and two 1D4x10 M.D.C. bonuses' AS assertion,
       (length(markdown) - length(replace(markdown, 'pools: { mdc: "1d4x10" }', ''))) / length('pools: { mdc: "1d4x10" }') AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'spirit-warrior' AND deleted_at IS NULL;
SELECT 'the class itself carries no class-wide flag' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'spirit-warrior'
   AND instr(markdown, char(10) || 'mdc_from_hp_sdc: true' || char(10)) > 0;
SELECT 'its note no longer says no field expresses the conversion' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'spirit-warrior' AND instr(markdown, 'which no field expresses') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f64-spirit-warrior-realm-mdc.sql');
