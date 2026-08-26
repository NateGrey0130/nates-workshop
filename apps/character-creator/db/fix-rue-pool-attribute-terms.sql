-- Eight mage classes' P.P.E. and six psychics' I.S.P. drop the attribute
-- term the book prints (class audit F6, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-pool-attribute-terms.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-pool-attribute-terms.sql
--
-- The early RUE imports wrote pool bases without the "+ P.E./M.E. attribute
-- number" clause; the later PF imports all carry it, and dice.js parses the
-- phrase explicitly ("2D4x100+200 plus P.E. attribute number" is a documented
-- case). Each cite below re-read from the OCR cache before writing:
--
--   P.P.E. missing "plus P.E. attribute number":
--     ley-line-walker / ley-line-rifter  printed 116/117: "3D6x10+20 added
--       to the character's P.E. attribute number"
--     mystic          printed 119: "1D6x10+20 plus P.E. attribute number"
--     shifter         printed 124: "2D6x10+10 plus P.E. attribute number"
--     techno-wizard   printed 128: "3D4x10, in addition to the P.E.
--                     attribute number"
--     elemental-fusionist x2  printed 101: "2D4x10+20 added to the
--                     character's P.E. attribute number"
--     warlock (base + both variants)  stat block lives in Federation of
--                     Magic (not on this machine); the term is taken from
--                     the class's own prose and the PF main book, per the
--                     audit's Blocked-need-book note.
--
--   I.S.P. missing "plus M.E. attribute number":
--     burster         printed 141: "3D4x10 plus the character's M.E.
--                     attribute number"
--     psi-stalker / wild-psi-stalker  printed 154: "M.E. attribute number
--                     +1D6x10"
--     dog-boy         printed 146: "1D6x10 + M.E. attribute number"
--     mystic          printed 119: "1D4x10+10 plus the character's M.E.
--                     number ... another 1D6+1 I.S.P. per each additional
--                     level" - the per-level clause was missing too
--     techno-wizard   printed 128: "4D6 plus the character's M.E. number
--                     ... another 1D4+1 I.S.P. per each additional level" -
--                     production was bare "4d6", both clauses missing
--
--   (cyber-knight's I.S.P. is class audit F5, fixed in
--   fix-rue-cyber-knight-bonuses.sql.)
--
-- Filename sort: fix-rue-pool-attribute-terms > fix-pre-rue-class-audit,
-- which rewrites ley-line-walker's whole markdown and is the last writer of
-- its ppe_base line; every other target line is written only by its
-- add-*-class.sql, all of which sort before fix-. The zz- scripts touch
-- catalog redirects, language notes and occ_group, never these lines.
--
-- Warlock note: the base class and its first variant carry byte-identical
-- ppe_base strings on purpose - replace() rewrites both occurrences in one
-- pass, and both need the term.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

UPDATE imported_classes
SET markdown = replace(markdown,
      'ppe_base: "3d6x10+20, +3d6 per additional level starting at level two"',
      'ppe_base: "3d6x10+20 plus P.E. attribute number, +3d6 per additional level starting at level two"'),
    updated_at = datetime('now')
WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
  AND instr(markdown, 'ppe_base: "3d6x10+20, +3d6 per additional level starting at level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'ppe_base: "1d6x10+20, +2d6 per additional level starting at level two"',
      'ppe_base: "1d6x10+20 plus P.E. attribute number, +2d6 per additional level starting at level two"'),
    updated_at = datetime('now')
WHERE class_id = 'mystic'
  AND instr(markdown, 'ppe_base: "1d6x10+20, +2d6 per additional level starting at level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  isp_base: "1d4x10+10"',
      '  isp_base: "1d4x10+10 plus M.E. attribute number, +1d6+1 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id = 'mystic'
  AND instr(markdown, '  isp_base: "1d4x10+10"' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'ppe_base: "2d6x10+10, +2d6 per additional level starting at level two"',
      'ppe_base: "2d6x10+10 plus P.E. attribute number, +2d6 per additional level starting at level two"'),
    updated_at = datetime('now')
WHERE class_id = 'shifter'
  AND instr(markdown, 'ppe_base: "2d6x10+10, +2d6 per additional level starting at level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'ppe_base: "3d4x10, +2d6 per additional level starting at level two"',
      'ppe_base: "3d4x10 plus P.E. attribute number, +2d6 per additional level starting at level two"'),
    updated_at = datetime('now')
WHERE class_id = 'techno-wizard'
  AND instr(markdown, 'ppe_base: "3d4x10, +2d6 per additional level starting at level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  isp_base: "4d6"',
      '  isp_base: "4d6 plus M.E. attribute number, +1d4+1 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id = 'techno-wizard'
  AND instr(markdown, '  isp_base: "4d6"' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'ppe_base: "2d4x10+20, +1d4+4 per additional level starting at level two"',
      'ppe_base: "2d4x10+20 plus P.E. attribute number, +1d4+4 per additional level starting at level two"'),
    updated_at = datetime('now')
WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
  AND instr(markdown, 'ppe_base: "2d4x10+20, +1d4+4 per additional level starting at level two"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '"2d4x10+20, +2d6 per additional level of experience"',
      '"2d4x10+20 plus P.E. attribute number, +2d6 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, '"2d4x10+20, +2d6 per additional level of experience"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '"2d4x10+40, +2d6 per additional level of experience"',
      '"2d4x10+40 plus P.E. attribute number, +2d6 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, '"2d4x10+40, +2d6 per additional level of experience"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  isp_base: "3d4x10, +10 per additional level of experience"',
      '  isp_base: "3d4x10 plus M.E. attribute number, +10 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id = 'burster'
  AND instr(markdown, '  isp_base: "3d4x10, +10 per additional level of experience"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  isp_base: "1d6x10, +10 per additional level of experience"',
      '  isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience"'),
    updated_at = datetime('now')
WHERE class_id IN ('psi-stalker', 'wild-psi-stalker', 'dog-boy')
  AND instr(markdown, '  isp_base: "1d6x10, +10 per additional level of experience"') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   pe_fixed     8 = the eight mage classes carry the P.E. term
--   me_fixed     6 = the six psychic pools carry the M.E. term
--   old_left     0 = no trace of any pre-fix formula string
--   cr_free     12 = all twelve touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('ley-line-walker', 'ley-line-rifter', 'mystic', 'shifter', 'techno-wizard', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'warlock')
            AND (instr(markdown, '"3d6x10+20 plus P.E. attribute number, +3d6') > 0
              OR instr(markdown, 'ppe_base: "1d6x10+20 plus P.E. attribute number, +2d6') > 0
              OR instr(markdown, 'ppe_base: "2d6x10+10 plus P.E. attribute number, +2d6') > 0
              OR instr(markdown, 'ppe_base: "3d4x10 plus P.E. attribute number, +2d6') > 0
              OR instr(markdown, '"2d4x10+20 plus P.E. attribute number, +1d4+4') > 0
              OR instr(markdown, '"2d4x10+20 plus P.E. attribute number, +2d6') > 0)) AS pe_fixed,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('burster', 'psi-stalker', 'wild-psi-stalker', 'dog-boy', 'mystic', 'techno-wizard')
            AND (instr(markdown, 'isp_base: "3d4x10 plus M.E. attribute number, +10') > 0
              OR instr(markdown, 'isp_base: "1d6x10 plus M.E. attribute number, +10') > 0
              OR instr(markdown, 'isp_base: "1d4x10+10 plus M.E. attribute number, +1d6+1') > 0
              OR instr(markdown, 'isp_base: "4d6 plus M.E. attribute number, +1d4+1') > 0)) AS me_fixed,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('ley-line-walker', 'ley-line-rifter', 'mystic', 'shifter', 'techno-wizard', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'warlock', 'burster', 'psi-stalker', 'wild-psi-stalker', 'dog-boy')
            AND (instr(markdown, '"3d6x10+20, +3d6') > 0
              OR instr(markdown, '"1d6x10+20, +2d6') > 0
              OR instr(markdown, '  isp_base: "1d4x10+10"' || char(10)) > 0
              OR instr(markdown, '"2d6x10+10, +2d6') > 0
              OR instr(markdown, '"3d4x10, +2d6') > 0
              OR instr(markdown, '  isp_base: "4d6"' || char(10)) > 0
              OR instr(markdown, '"2d4x10+20, +1d4+4') > 0
              OR instr(markdown, '"2d4x10+20, +2d6') > 0
              OR instr(markdown, '"2d4x10+40, +2d6') > 0
              OR instr(markdown, '"3d4x10, +10 per') > 0
              OR instr(markdown, '"1d6x10, +10 per') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('ley-line-walker', 'ley-line-rifter', 'mystic', 'shifter', 'techno-wizard', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'warlock', 'burster', 'psi-stalker', 'wild-psi-stalker', 'dog-boy')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-pool-attribute-terms.sql');
