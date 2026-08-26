-- The Valkyrie's racial S.D.C. is an sdc_base, so an occupation's S.D.C. is
-- silently lost (class audit F12, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-valkyrie-sdc-pool.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-valkyrie-sdc-pool.sql
--
-- The book (Pantheons of the Megaverse p.167, per the audit's verified
-- quote - the Pantheons PDF is not in the OCR cache on this machine today):
-- "S.D.C./Hit Points (for non-M.D.C. worlds): 100 S.D.C. plus that gained
-- from physical skills." Production had sdc_base: 100, and combineClasses
-- gives a race's sdc_base precedence over an occupation's (the Troll Knight
-- case), so a Valkyrie + O.C.C. character carried exactly 100 instead of
-- 100 plus the occupation's roll - and nothing looked unusual.
--
-- The import note argued sdc_base deliberately (the phrasing never mentions
-- O.C.C.s, the class grants its own skills). The repo's settled rule reads
-- the other way: a racial S.D.C. is a POOL BONUS, never sdc_base - Palladium
-- prints "All S.D.C. points/bonuses are cumulative" outright, and the
-- Asgardian Dwarf and High Elf beside her are pools. The note is rewritten
-- below rather than left contradicting the data (the claim-audit rule).
-- The class keeps its mdc_base, so no CORE_SDC_BY_CLASS entry is needed.
--
-- Filename sort: fix-valkyrie-sdc-pool > add-valkyrie-class.sql, the only
-- writer of these regions.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

UPDATE imported_classes
SET markdown = replace(markdown, 'sdc_base: 100' || char(10), ''),
    updated_at = datetime('now')
WHERE class_id = 'valkyrie'
  AND instr(markdown, 'sdc_base: 100' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'bonuses:' || char(10) || '  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1, psionics: 1 }',
      'bonuses:' || char(10) || '  pools: { sdc: 100 }' || char(10) || '  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1, psionics: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'valkyrie'
  AND instr(markdown, 'bonuses:' || char(10) || '  saves: { horror_factor: 6') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  1. sdc_base 100, NOT a pool bonus - and this is the one place in the Norse' || char(10)
        || '     block where that call goes the other way. The Asgardian Dwarf and High Elf' || char(10)
        || '     both say "plus those gained by O.C.C.''s and physical skills", which is the' || char(10)
        || '     cumulative wording, so both are pool bonuses. The Valkyrie says "100' || char(10)
        || '     S.D.C. plus that gained from PHYSICAL SKILLS" and never mentions O.C.C.s.' || char(10)
        || '     She also grants her own skills and her own related-skill list, so she is' || char(10)
        || '     the self-contained case rather than the race-plus-occupation one. Read as' || char(10)
        || '     a base.',
      '  1. sdc: 100 IS a pool bonus (class audit F12), like the Asgardian Dwarf''s' || char(10)
        || '     and High Elf''s. An earlier note read "100 S.D.C. plus that gained from' || char(10)
        || '     physical skills" as a self-contained base because the line never mentions' || char(10)
        || '     O.C.C.s - but sdc_base takes precedence over an occupation''s in' || char(10)
        || '     combineClasses, so a Valkyrie played WITH an occupation silently lost the' || char(10)
        || '     occupation''s roll. Palladium prints the general rule outright: all S.D.C.' || char(10)
        || '     points/bonuses are cumulative.'),
    updated_at = datetime('now')
WHERE class_id = 'valkyrie'
  AND instr(markdown, '  1. sdc_base 100, NOT a pool bonus') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the pool bonus and rewritten note are present
--   old_left     0 = no sdc_base line, no trace of the overturned note
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'valkyrie'
          AND instr(markdown, '  pools: { sdc: 100 }') > 0
          AND instr(markdown, '  1. sdc: 100 IS a pool bonus (class audit F12)') > 0
          AND instr(markdown, 'mdc_base:') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'valkyrie'
          AND (instr(markdown, 'sdc_base: 100') > 0
            OR instr(markdown, 'sdc_base 100, NOT a pool bonus') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'valkyrie'
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-valkyrie-sdc-pool.sql');
