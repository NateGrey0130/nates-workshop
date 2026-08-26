-- The Cyber-Knight's combat block, attribute line, requirements and psionics
-- all disagree with RUE (class audit F5, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-cyber-knight-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-cyber-knight-bonuses.sql
--
-- The book, each read from the OCR cache before writing:
--
--   printed 63: "+1D4 to M.A., M.E., P.S., P.P., P.E., and Spd attributes";
--     "Combat Bonuses: +1 attack/action per melee, +3 to initiative, +3 to
--     Perception Rolls, +2 to pull punch, and +2 to disarm. +1 to save vs
--     Horror Factor at levels 2, 5, 8, 12 and 15."
--   printed 64: "41-60% Major Psychic: I.S.P. Base: 6D6 + M.E. attribute
--     number +1D6 I.S.P. per level of experience ... Select a total of six
--     additional psychic powers ... in addition to those three powers known
--     to all Cyber-Knights."
--   printed 66: "Attribute Requirements: Minimum P.E. of 11 ... What is
--     required is a strong will (M.E. 11+)".
--
-- Production, against those lines: initiative 1 (book 3); no pull punch, no
-- disarm, no perception, no Horror Factor schedule; attributes drop P.P.;
-- attribute_requirements carry M.E. 11 only; psionics carry the MASTER tier's
-- base (6d6+10) with the Major's per-level and no M.E. term, and the three
-- universal powers without the Major's six additional picks. The class is
-- written as the Major Psychic result (the 41-60% band); modelling the d100
-- tier table itself is CLASS-AUDIT.md S2, not this script.
--
-- Filename sort: fix-rue-cyber-knight-bonuses > fix-pre-rue-class-audit, the
-- last script that writes this class's whole markdown (fix-cyber-knight and
-- the apply-* scripts all sort before it and are themselves superseded by
-- it). The later cyber-knight-touching scripts (zz-merge-psionic-duplicates,
-- zz-note-native-tongue-figures, zz-rifts-occ-groups) edit catalog redirects,
-- language notes and occ_group, never these regions. The audit sketch named
-- this file fix-cyber-knight-rue-bonuses.sql, which sorts BEFORE
-- fix-cyber-knight.sql ('-' < '.') and would be undone on a clean rebuild -
-- hence the reordered name.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- P.E. 11 joins M.E. 11 (printed 66 states both).
UPDATE imported_classes
SET markdown = replace(markdown,
      'attribute_requirements:' || char(10) || '  ME: 11' || char(10) || 'hit_points_base:',
      'attribute_requirements:' || char(10) || '  ME: 11' || char(10) || '  PE: 11' || char(10) || 'hit_points_base:'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, 'attribute_requirements:' || char(10) || '  ME: 11' || char(10) || 'hit_points_base:') > 0;

-- Initiative 1 -> 3; pull punch, disarm and perception join the block.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 1, attacks: 1 }',
      '  combat: { initiative: 3, attacks: 1, pull_punch: 2, disarm: 2, perception: 3 }'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, '  combat: { initiative: 1, attacks: 1 }') > 0;

-- The dropped P.P. die rejoins the attribute line.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }',
      '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PP: "1d4", PE: "1d4", Spd: "1d4" }'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }') > 0;

-- The Horror Factor schedule, anchored on the corrected attribute line so a
-- second run (at_level already between it and skills:) is a no-op.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PP: "1d4", PE: "1d4", Spd: "1d4" }' || char(10) || 'skills:',
      '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PP: "1d4", PE: "1d4", Spd: "1d4" }' || char(10)
        || '  at_level:' || char(10)
        || '    - { level: 2, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 5, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 8, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 12, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 15, saves: { horror_factor: 1 } }' || char(10)
        || 'skills:'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PP: "1d4", PE: "1d4", Spd: "1d4" }' || char(10) || 'skills:') > 0;

-- Psionics as the Major tier: the Major base with its M.E. term, and the
-- three universal powers plus the six additional picks.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  isp_base: "6d6+10, +1d6 per level"' || char(10) || '  powers_starting: 3',
      '  isp_base: "6d6 plus M.E. attribute number, +1d6 per level"' || char(10) || '  powers_starting: 9'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, '  isp_base: "6d6+10, +1d6 per level"' || char(10) || '  powers_starting: 3') > 0;

-- The extraction note that described three starting powers is now false and
-- comes out in the same script (the claim-audit rule).
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - The three starting psi-powers come from a named list of nine, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered.',
      '  - Stored as the Major Psychic result of the RUE p.64 roll: the three universal powers plus six additional picks, powers_starting: 9. The universal three come from a named list, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered; the d100 tier table itself is still not modelled (CLASS-AUDIT.md S2).'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, '  - The three starting psi-powers come from a named list of nine,') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = every corrected region is present
--   old_left     0 = no trace of any of the six regions' old text
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'cyber-knight'
          AND instr(markdown, '  ME: 11' || char(10) || '  PE: 11') > 0
          AND instr(markdown, '  combat: { initiative: 3, attacks: 1, pull_punch: 2, disarm: 2, perception: 3 }') > 0
          AND instr(markdown, 'PS: "1d4", PP: "1d4", PE: "1d4"') > 0
          AND instr(markdown, '    - { level: 15, saves: { horror_factor: 1 } }' || char(10) || 'skills:') > 0
          AND instr(markdown, '  isp_base: "6d6 plus M.E. attribute number, +1d6 per level"') > 0
          AND instr(markdown, '  powers_starting: 9') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'cyber-knight'
          AND (instr(markdown, '  combat: { initiative: 1, attacks: 1 }') > 0
            OR instr(markdown, 'PS: "1d4", PE: "1d4"') > 0
            OR instr(markdown, '  isp_base: "6d6+10, +1d6 per level"') > 0
            OR instr(markdown, '  powers_starting: 3') > 0
            OR instr(markdown, 'The three starting psi-powers') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'cyber-knight' AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-cyber-knight-bonuses.sql');
