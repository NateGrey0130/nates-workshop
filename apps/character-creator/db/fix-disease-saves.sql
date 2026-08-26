-- Disease saves dropped or misattributed in six classes (class audit F9,
-- 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-disease-saves.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-disease-saves.sql
--
-- The books print "save vs poison AND disease" as separate figures; `disease`
-- is a modeled save key (rogue-scientist and warrior-monk carry it). Each
-- line re-read from the OCR cache before writing:
--
--   body-fixer     RUE printed 87: "+2 to save vs poison and drugs, +3 to
--                  save vs disease and insanity, +2 to save vs Horror
--                  Factor" - production had poison and drugs a point high
--                  (3) and no disease at all; the block is rewritten to the
--                  book's numbers.
--   cyber-doc      RUE printed 90: "+1 to save vs poison, drugs and
--                  disease" - all three were absent.
--   druid          PF (the class opens printed 75; the line prints two
--                  pages in): "+4 to save vs horror factor, +2 to save vs
--                  disease" - disease absent.
--   psi-healer     PF printed 158: "+4 to save vs poisons and disease" -
--                  toxins_poisons: 4 only.
--   dog-boy        RUE printed 146, "6. Physical Bonuses": "+2 to disarm
--                  or pull punch, and +2 to save vs disease" - disease AND
--                  the +2 disarm both absent (the finding records both, so
--                  both land here; pull punch was already carried).
--   elemental-fusionist x2  RUE printed 101: "+2 to save vs disease and
--                  poison" - toxins_poisons: 2 only.
--
-- The note rewrites for dog-boy's now-false "no bonus key" sentences live in
-- fix-perception-bonuses.sql, which also edits dog-boy and sorts after this
-- file - one rewrite from original text to final text, rather than two
-- chained half-rewrites.
--
-- Filename sort: fix-disease-saves > every add-*-class.sql (the only writers
-- of these lines) and > fix-dead-skill-restrictions ('dea' < 'dis'), which
-- touches except: lists, not saves. The later fix-* and zz- scripts touch
-- other regions (fix-psychic-save-target-notes rewrites psi-healer's
-- save-TARGET prose, never its saves line).
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- Body Fixer: poison and drugs down to the printed 2, disease 3 joins.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { toxins_poisons: 3, harmful_drugs: 3, insanity: 3, horror_factor: 2 }',
      '  saves: { toxins_poisons: 2, harmful_drugs: 2, disease: 3, insanity: 3, horror_factor: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'body-fixer'
  AND instr(markdown, '  saves: { toxins_poisons: 3, harmful_drugs: 3, insanity: 3, horror_factor: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { horror_factor: 4, pain: 2 }',
      '  saves: { horror_factor: 4, pain: 2, toxins_poisons: 1, harmful_drugs: 1, disease: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-doc'
  AND instr(markdown, '  saves: { horror_factor: 4, pain: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { horror_factor: 4 }',
      '  saves: { horror_factor: 4, disease: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'druid'
  AND instr(markdown, '  saves: { horror_factor: 4 }' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { mind_control: 4, toxins_poisons: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }',
      '  saves: { mind_control: 4, toxins_poisons: 4, disease: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }'),
    updated_at = datetime('now')
WHERE class_id = 'psi-healer'
  AND instr(markdown, '  saves: { mind_control: 4, toxins_poisons: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { psionics: 2, mind_control: 2, illusionary_magic: 2, possession: 2, curses: 2 }',
      '  saves: { psionics: 2, mind_control: 2, illusionary_magic: 2, possession: 2, curses: 2, disease: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'dog-boy'
  AND instr(markdown, '  saves: { psionics: 2, mind_control: 2, illusionary_magic: 2, possession: 2, curses: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2 }',
      '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2, disarm: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'dog-boy'
  AND instr(markdown, '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { toxins_poisons: 2, coma_death_pct: 10 }',
      '  saves: { toxins_poisons: 2, disease: 2, coma_death_pct: 10 }'),
    updated_at = datetime('now')
WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
  AND instr(markdown, '  saves: { toxins_poisons: 2, coma_death_pct: 10 }') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        7 = each of the seven classes carries its corrected line
--   disarm_ok    1 = dog-boy's combat line carries the disarm too
--   old_left     0 = no trace of any pre-fix saves line
--   cr_free      7 = all seven touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'cyber-doc', 'druid', 'psi-healer', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
            AND (instr(markdown, '  saves: { toxins_poisons: 2, harmful_drugs: 2, disease: 3, insanity: 3, horror_factor: 2 }') > 0
              OR instr(markdown, '  saves: { horror_factor: 4, pain: 2, toxins_poisons: 1, harmful_drugs: 1, disease: 1 }') > 0
              OR instr(markdown, '  saves: { horror_factor: 4, disease: 2 }') > 0
              OR instr(markdown, '  saves: { mind_control: 4, toxins_poisons: 4, disease: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }') > 0
              OR instr(markdown, '  saves: { psionics: 2, mind_control: 2, illusionary_magic: 2, possession: 2, curses: 2, disease: 2 }') > 0
              OR instr(markdown, '  saves: { toxins_poisons: 2, disease: 2, coma_death_pct: 10 }') > 0)) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'dog-boy'
          AND instr(markdown, 'dodge: 1, pull_punch: 2, disarm: 2') > 0) AS disarm_ok,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'cyber-doc', 'druid', 'psi-healer', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
            AND (instr(markdown, '  saves: { toxins_poisons: 3, harmful_drugs: 3,') > 0
              OR instr(markdown, '  saves: { horror_factor: 4, pain: 2 }') > 0
              OR instr(markdown, '  saves: { horror_factor: 4 }' || char(10)) > 0
              OR instr(markdown, 'toxins_poisons: 4, possession: 7,') > 0
              OR instr(markdown, 'possession: 2, curses: 2 }') > 0
              OR instr(markdown, 'dodge: 1, pull_punch: 2 }') > 0
              OR instr(markdown, '  saves: { toxins_poisons: 2, coma_death_pct: 10 }') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'cyber-doc', 'druid', 'psi-healer', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-disease-saves.sql');
