-- Two decisions taken by hand: W.P. provenance, and where Literacy lives.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-wp-source-and-literacy.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-wp-source-and-literacy.sql
--
-- 1. EIGHT W.P.s HAD NO source_book AT ALL. Six others claim Rifts Ultimate
--    Edition while carrying the older aimed-shot/burst pattern, which is not
--    what the RUE pages print - they were flagged rather than changed, because
--    picking an edition label is a judgement about which books this table is
--    for, not a transcription.
--
--    That judgement has been made: treat RUE as the source throughout. So the
--    eight blanks are filled in to match, and the six already labelled stay as
--    they are. Every W.P. now says where it came from, and they all say the
--    same thing.
--
--    Recorded plainly because it IS an assumption: the aimed/burst numbers on
--    some of these rows come from an older edition's tables, and the label now
--    says RUE anyway. If that ever matters, this comment is the thread to pull.
UPDATE skills
SET source_book = 'Rifts Ultimate Edition'
WHERE name LIKE 'W.P.%' AND source_book IS NULL;

-- 2. Literacy: Dragonese/Elven moves from Communications to Technical.
--
--    Left alone when its percentages were filled in, because category is not
--    cosmetic here: a class picks skills BY CATEGORY, so moving a skill changes
--    which characters can reach it. That made it a rules decision rather than a
--    transcription, and it has now been made.
UPDATE skills
SET category = 'Technical'
WHERE name = 'Literacy: Dragonese/Elven' AND category = 'Communications';

-- Reports the result back, so it is read rather than assumed.
--   wp_without_source   0 = every W.P. now says where it came from
--   wp_total            every W.P. row, for scale
--   wp_rue              and how many now name RUE
--   literacy_category   'Technical'
--   literacy_pct        '30/5', unchanged by the move
SELECT (SELECT count(*) FROM skills
          WHERE name LIKE 'W.P.%' AND source_book IS NULL) AS wp_without_source,
       (SELECT count(*) FROM skills WHERE name LIKE 'W.P.%') AS wp_total,
       (SELECT count(*) FROM skills
          WHERE name LIKE 'W.P.%' AND source_book LIKE 'Rifts Ultimate Edition%') AS wp_rue,
       (SELECT category FROM skills WHERE name = 'Literacy: Dragonese/Elven') AS literacy_category,
       (SELECT base || '/' || per_level FROM skills
          WHERE name = 'Literacy: Dragonese/Elven') AS literacy_pct;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-wp-source-and-literacy.sql');
