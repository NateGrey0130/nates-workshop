-- Four classes are missing printed starting money, and the Vagabond's save
-- line lost its psionics half (class audit F16 + F20, 2026-08-26; F20's own
-- sketch says it could ride F16's script, so it does).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-missing-starting-money.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-missing-starting-money.sql
--
-- Each line re-read from the OCR cache before writing:
--
--   city-rat        printed 89: "Starts with 6D6x100 credits and a Black
--                   Market item of some kind worth 3D4x1000 credits."
--   vagabond        printed 98: "Money: 2D6x100 in credits and 2D6x100 in
--                   Black Market saleable [goods]."
--   coalition-grunt printed 233: "Monthly salary is 1700 credits. Starts off
--                   with one month's pay." - the samas-pilot's
--                   "N credits monthly salary" convention.
--   coalition-technical-officer  printed 236: "A monthly salary of 2200
--                   credits. Starts off with one month's pay."
--   (combat-cyborg's money was F1; cyber-doc's omission is documented and
--   deliberate.)
--
--   F20, vagabond   printed 97: "+1 to save vs possession and psionic
--                   attacks" - production carried possession: 1 only. The
--                   note that called the psionics half ambiguous is
--                   rewritten in the same statement family.
--
-- Black-market halves stay prose per the coin-only rule; each class gets an
-- extraction-note bullet saying so. The page-range extensions these money
-- lines sit on (city-rat 88-89, vagabond 97-98, grunt 231-233) are
-- fix-rue-attr-reqs-and-ranges.sql's (F17), which sorts after this file and
-- touches different lines.
--
-- Filename sort: fix-missing-starting-money > every add-*-class.sql writer
-- of these regions; fix-broken-pick-options and fix-perception-bonuses edit
-- other city-rat/vagabond regions, and order does not matter between them.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- City Rat: the coin figure, the note that said no money appears trimmed to
-- stay true, and a bullet documenting the black-market half.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  IQ: 10' || char(10) || 'bonuses:',
      '  IQ: 10' || char(10) || 'starting_money: "6d6x100"' || char(10) || 'bonuses:'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat'
  AND instr(markdown, '  IQ: 10' || char(10) || 'bonuses:') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - No equipment list, starting money, or alignment restriction list beyond',
      '  - No equipment list or alignment restriction list beyond'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat'
  AND instr(markdown, '  - No equipment list, starting money, or alignment restriction list beyond') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    it is recorded in Lore/GM Notes rather than as a restrictions entry).',
      '    it is recorded in Lore/GM Notes rather than as a restrictions entry).' || char(10)
        || '  - Money (printed 89): "Starts with 6D6x100 credits and a Black Market item' || char(10)
        || '    of some kind worth 3D4x1000 credits." starting_money holds the coin; the' || char(10)
        || '    Black Market item stays prose per the coin-only rule (class audit F16).'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat'
  AND instr(markdown, 'Black Market item stays prose per the coin-only rule') = 0;

-- Vagabond: the coin figure, the psionics save (F20), the note rewrite, and
-- the black-market bullet.
UPDATE imported_classes
SET markdown = replace(markdown,
      'category: occ' || char(10) || 'bonuses:',
      'category: occ' || char(10) || 'starting_money: "2d6x100"' || char(10) || 'bonuses:'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond'
  AND instr(markdown, 'category: occ' || char(10) || 'bonuses:') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  saves: { possession: 1, horror_factor: 2 }',
      '  saves: { possession: 1, psionics: 1, horror_factor: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond'
  AND instr(markdown, '  saves: { possession: 1, horror_factor: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'The "+1 to save vs psionic attacks"' || char(10)
        || '    portion was not filed under saves.psionics because it is ambiguous whether' || char(10)
        || '    it''s meant as a separate save category from possession; recorded here for' || char(10)
        || '    visibility - consider it +1 to saves.psionics if the app needs a value.',
      'The psionic-attack half is' || char(10)
        || '    filed as saves.psionics: 1 (class audit F20 - RUE prints both halves).'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond'
  AND instr(markdown, 'portion was not filed under saves.psionics because it is ambiguous whether') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - Occ_skills list is cut off mid-page',
      '  - Money (printed 98): "2D6x100 in credits and 2D6x100 in Black Market' || char(10)
        || '    saleable goods." starting_money holds the coin; the goods stay prose per' || char(10)
        || '    the coin-only rule (class audit F16).' || char(10)
        || '  - Occ_skills list is cut off mid-page'),
    updated_at = datetime('now')
WHERE class_id = 'vagabond'
  AND instr(markdown, 'the coin-only rule (class audit F16)') = 0;

-- Coalition Grunt: the salary figure and a bullet naming its page, since the
-- class's own notes say no mechanical fields could be extracted from 231-232.
UPDATE imported_classes
SET markdown = replace(markdown,
      'category: occ' || char(10) || 'extraction_notes:',
      'category: occ' || char(10) || 'starting_money: "1700 credits monthly salary"' || char(10) || 'extraction_notes:'),
    updated_at = datetime('now')
WHERE class_id = 'coalition-grunt'
  AND instr(markdown, 'category: occ' || char(10) || 'extraction_notes:') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    armor (old style vs. new style), with no stat tables present.',
      '    armor (old style vs. new style), with no stat tables present.' || char(10)
        || '  - starting_money was added later from printed 233 ("Monthly salary is 1700' || char(10)
        || '    credits. Starts off with one month''s pay"), the samas-pilot salary' || char(10)
        || '    convention (class audit F16; F17 extended the page range to match).'),
    updated_at = datetime('now')
WHERE class_id = 'coalition-grunt'
  AND instr(markdown, 'the samas-pilot salary') = 0;

-- Coalition Technical Officer: the salary figure (no note claims money is
-- absent, so nothing to rewrite).
UPDATE imported_classes
SET markdown = replace(markdown,
      'attribute_requirements: { IQ: 9 }' || char(10) || 'skills:',
      'attribute_requirements: { IQ: 9 }' || char(10) || 'starting_money: "2200 credits monthly salary"' || char(10) || 'skills:'),
    updated_at = datetime('now')
WHERE class_id = 'coalition-technical-officer'
  AND instr(markdown, 'attribute_requirements: { IQ: 9 }' || char(10) || 'skills:') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   money_ok     4 = all four classes carry their money line
--   psi_ok       1 = the vagabond save line carries the psionics half
--   old_left     0 = no stale note text or pre-fix save line left
--   cr_free      4 = all four touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE (class_id = 'city-rat' AND instr(markdown, 'starting_money: "6d6x100"') > 0)
             OR (class_id = 'vagabond' AND instr(markdown, 'starting_money: "2d6x100"') > 0)
             OR (class_id = 'coalition-grunt' AND instr(markdown, 'starting_money: "1700 credits monthly salary"') > 0)
             OR (class_id = 'coalition-technical-officer' AND instr(markdown, 'starting_money: "2200 credits monthly salary"') > 0)) AS money_ok,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'vagabond'
          AND instr(markdown, '  saves: { possession: 1, psionics: 1, horror_factor: 2 }') > 0) AS psi_ok,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('city-rat', 'vagabond', 'coalition-grunt', 'coalition-technical-officer')
            AND (instr(markdown, 'No equipment list, starting money,') > 0
              OR instr(markdown, 'portion was not filed under saves.psionics') > 0
              OR instr(markdown, '  saves: { possession: 1, horror_factor: 2 }') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('city-rat', 'vagabond', 'coalition-grunt', 'coalition-technical-officer')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-missing-starting-money.sql');
