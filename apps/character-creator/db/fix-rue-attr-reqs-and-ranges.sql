-- Attribute requirements and page ranges against RUE (class audit F17,
-- 2026-08-26) - smaller than the finding, because five of its seven
-- "absent" claims were false.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-attr-reqs-and-ranges.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-attr-reqs-and-ranges.sql
--
-- The audit listed seven classes with attribute requirements "absent in
-- production". Fresh --remote pulls show cyber-doc (IQ 11/PP 12),
-- glitter-boy (PP 10), rogue-scholar (IQ 10/MA 10), rogue-scientist (IQ 12)
-- and long-bowman (PS 10/PP 12) all carry them, in multi-line blocks their
-- add-*-class.sql scripts have held since before the audit was written -
-- the audit likely grepped the inline { } form and missed the block form
-- (F5 read cyber-knight's block fine, so the shape parses). What is real:
--
--   coalition-samas-pilot  printed 235 (cache p238): "I.Q. 12 or higher,
--     M.E. 12 or higher, P.E. 10." Production carried IQ 10 / PP 10 -
--     wrong values, not absence. Its Human racial restriction is already a
--     race_restrictions block, confirmed.
--   elemental-fusionist x2  printed 104: "M.E. 12, P.E. 12, and an I.Q. and
--     P.S. of 10 or higher are recommended but not required." Truly absent:
--     the import note read the WHOLE line as a recommendation. The trailing
--     clause covers only the I.Q./P.S. 10 - cyber-doc's line has the same
--     required-then-suggested shape - so M.E. 12 / P.E. 12 are hard
--     requirements, and the note is rewritten (the claim-audit rule).
--
-- Page ranges that stop before the class's own stat block (starving
-- --field-sources): cyber-knight 61-66 -> 61-67, operator 91-92 -> 91-93,
-- coalition-grunt 231-232 -> 231-233 (combat-cyborg's was fixed by F1).
-- Two more the finding's list missed, same defect, caught because F16's
-- money additions cite the missing page: city-rat 88-88 -> 88-89 and
-- vagabond 97-97 -> 97-98.
--
-- Filename sort: fix-rue-attr-reqs-and-ranges > fix-pre-rue-class-audit,
-- the last full writer of cyber-knight's markdown (the audit's sketch name,
-- fix-attr-reqs-and-ranges, sorts before it and the range fix would be
-- undone on a rebuild); every other touched line is written by its
-- add-*-class.sql.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- SAMAS pilot: the printed values.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  IQ: 10' || char(10) || '  PP: 10',
      '  IQ: 12' || char(10) || '  ME: 12' || char(10) || '  PE: 10'),
    updated_at = datetime('now')
WHERE class_id = 'coalition-samas-pilot'
  AND instr(markdown, '  IQ: 10' || char(10) || '  PP: 10') > 0;

-- Elemental Fusionists: the requirements join the frontmatter ...
UPDATE imported_classes
SET markdown = replace(markdown,
      'category: occ' || char(10) || 'ppe_base: "2d4x10+20',
      'category: occ' || char(10) || 'attribute_requirements: { ME: 12, PE: 12 }' || char(10) || 'ppe_base: "2d4x10+20'),
    updated_at = datetime('now')
WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
  AND instr(markdown, 'category: occ' || char(10) || 'ppe_base: "2d4x10+20') > 0;

-- ... and the note that read the whole line as a recommendation comes out.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - RUE p.100-104. M.E. 12, P.E. 12, plus I.Q. and P.S. 10 recommended but NOT' || char(10)
        || '    required - so no attribute_requirements are set; the recommendation is' || char(10)
        || '    prose.',
      '  - RUE p.100-104. Attribute Requirements: M.E. 12 and P.E. 12 (the printed' || char(10)
        || '    line''s trailing "recommended but not required" clause covers only the' || char(10)
        || '    I.Q. and P.S. 10 - the cyber-doc line has the same required-then-' || char(10)
        || '    suggested shape; class audit F17). The I.Q./P.S. recommendation stays' || char(10)
        || '    prose.'),
    updated_at = datetime('now')
WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
  AND instr(markdown, 'so no attribute_requirements are set; the recommendation is') > 0;

-- The five short page ranges.
UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.61-66', 'source_book: Rifts Ultimate Edition p.61-67'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.61-66') > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.91-92', 'source_book: Rifts Ultimate Edition p.91-93'),
    updated_at = datetime('now')
WHERE class_id = 'operator' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.91-92') > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.231-232', 'source_book: Rifts Ultimate Edition p.231-233'),
    updated_at = datetime('now')
WHERE class_id = 'coalition-grunt' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.231-232') > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.88-88', 'source_book: Rifts Ultimate Edition p.88-89'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.88-88') > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.97-97', 'source_book: Rifts Ultimate Edition p.97-98'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.97-97') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   reqs_ok      3 = samas carries the printed trio, both fusionists theirs
--   ranges_ok    5 = all five extended ranges present
--   old_left     0 = no wrong samas values, stale note, or short range left
--   cr_free      8 = all eight touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE (class_id = 'coalition-samas-pilot' AND instr(markdown, '  IQ: 12' || char(10) || '  ME: 12' || char(10) || '  PE: 10') > 0)
             OR (class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
                 AND instr(markdown, 'attribute_requirements: { ME: 12, PE: 12 }') > 0)) AS reqs_ok,
       (SELECT count(*) FROM imported_classes
          WHERE (class_id = 'cyber-knight' AND instr(markdown, 'p.61-67') > 0)
             OR (class_id = 'operator' AND instr(markdown, 'p.91-93') > 0)
             OR (class_id = 'coalition-grunt' AND instr(markdown, 'p.231-233') > 0)
             OR (class_id = 'city-rat' AND instr(markdown, 'p.88-89') > 0)
             OR (class_id = 'vagabond' AND instr(markdown, 'p.97-98') > 0)) AS ranges_ok,
       (SELECT count(*) FROM imported_classes
          WHERE (class_id = 'coalition-samas-pilot' AND instr(markdown, '  IQ: 10' || char(10) || '  PP: 10') > 0)
             OR (class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
                 AND instr(markdown, 'so no attribute_requirements are set') > 0)
             OR instr(markdown, 'p.61-66') > 0 AND class_id = 'cyber-knight'
             OR instr(markdown, 'p.91-92') > 0 AND class_id = 'operator'
             OR instr(markdown, 'p.231-232') > 0 AND class_id = 'coalition-grunt'
             OR instr(markdown, 'p.88-88') > 0 AND class_id = 'city-rat'
             OR instr(markdown, 'p.97-97') > 0 AND class_id = 'vagabond') AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('coalition-samas-pilot', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'cyber-knight', 'operator', 'coalition-grunt', 'city-rat', 'vagabond')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-attr-reqs-and-ranges.sql');
