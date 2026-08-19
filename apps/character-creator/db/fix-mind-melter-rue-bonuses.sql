-- The Mind Melter O.C.C., corrected against Rifts Ultimate Edition p.150-151.
--
-- The stored entry came from the ORIGINAL core book (source_book
-- 'rifts-core'); RUE revised the bonuses, and three of them were wrong for
-- either edition once checked against the page:
--
--   - mind control was +4; the book says +2 to save vs ALL forms of mind
--     control.
--   - 'insanity: 3' appears in no edition's bonus list. The +3 belongs to
--     saves vs MAGIC ILLUSIONS - illusionary_magic, a key derive.js already
--     carries for exactly this shape of bonus.
--   - Horror Factor was flat +1; the book grants it at levels 1, 2, 4, 5, 7,
--     8, 9, 11, 13 and 15.
--
-- And the pick count was double-counted: powers_starting was 16, but the
-- book grants FOUR automatic powers (already in psionics.powers) plus three
-- from each of the four categories - twelve picks, not sixteen.
--
-- Not modeled, stated on the page: +3 on Perception Rolls, and the rule that
-- Mind Wipe, Psi-Sword and Mentally Possess Others cannot be taken from the
-- Super category until third level (a per-power LEVEL gate, which min_tier
-- does not express).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-mind-melter-rue-bonuses.sql
--
-- Guarded on the old-edition marker; re-running does nothing.

UPDATE imported_classes SET
  markdown = replace(replace(replace(markdown,
    'source_book: rifts-core',
    'source_book: Rifts Ultimate Edition p.150-151'),
    '  saves: { possession: 4, mind_control: 4, insanity: 3, horror_factor: 1 }',
    '  saves: { possession: 4, mind_control: 2, illusionary_magic: 3, horror_factor: 1 }' || char(10) ||
    '  at_level:' || char(10) ||
    '    - { level: 2, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 4, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 5, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 7, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 8, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 9, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 11, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 13, saves: { horror_factor: 1 } }' || char(10) ||
    '    - { level: 15, saves: { horror_factor: 1 } }'),
    '  powers_starting: 16',
    '  powers_starting: 12' || char(10) ||
    '  categories_allowed: ["Healing", "Physical", "Sensitive", "Super"]'),
  updated_at = datetime('now')
WHERE class_id = 'mind-melter'
  AND instr(markdown, 'source_book: rifts-core') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'Rifts Ultimate Edition p.150-151') > 0 AS is_rue,
       instr(markdown, 'mind_control: 2') > 0 AS mind_control_fixed,
       instr(markdown, 'insanity: 3') > 0 AS insanity_remains,
       instr(markdown, 'powers_starting: 12') > 0 AS picks_fixed,
       instr(markdown, char(13)) > 0 AS has_cr
FROM imported_classes WHERE class_id = 'mind-melter';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-mind-melter-rue-bonuses.sql');
