-- The nine Nightbane race ladders move out of their notes and into xp_table.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-nb-race-xp-ladders.sql
--
-- Nightbane RPG printed 233 prints experience ladders for nine races as well as
-- for the O.C.C.s. #1129-#1141 recorded each race's ladder in extraction_notes
-- and stored no xp_table, because the rule then was that no R.C.C. carries one:
-- composition let the race's table win a pairing, so a race carrying one would
-- have dropped its occupation's chart.
--
-- Nate's decision, 2026-09-17 (docs/surveys/nightbane-core.md, "Follow-up
-- decisions after the import"): an R.C.C. may carry xp_table when its book
-- prints a ladder for the race; it applies when the race is played alone, and
-- an O.C.C.'s ladder still wins a pairing. combineClasses changed in the same
-- PR, so this data is safe to carry.
--
-- Each value is the LOWER bound of each band, as the class's own note states it.
-- Where the note records a misprinted lower bound that repeats the previous
-- band's upper bound (Dopplegangar 14,600; Hound & Hunter 10,000, 20,000 and
-- 350,000; Nemtar 2,000, 4,000 and 228,100; Nightprince & Vampire 400,000;
-- Ashmedai 225,920), the stored figure is that number plus one - the convention
-- nb-psychic and nb-sorcerer already follow for the Ashmedai ladder. Three
-- ladders are shared with a shipped O.C.C. and match it exactly: Ashmedai with
-- nb-psychic and nb-sorcerer, Snakebird with nb-mystic, Guardian with
-- nb-package-basic. The notes themselves are left as they are: they record what
-- the book prints.
--
-- The line goes straight after the frontmatter's category line, which occurs
-- once in each of the nine. Guarded on no xp_table LINE yet - a newline before
-- the key, because three of the notes mention "xp_table:" in their prose - so a
-- second run changes nothing. nb-nightbane is deliberately untouched: its
-- package O.C.C.s carry the Nightbane & Guardian ladder.

-- nb-doppleganger: Dopplegangar
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14601, 21001, 30001, 40001, 55001, 75001, 105001, 140001, 190001, 245001, 300001]' || char(10))
 WHERE class_id = 'nb-doppleganger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-hunter: Hound & Hunter
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 35001, 55001, 85001, 130001, 180001, 235001, 285001, 350001, 425001, 550001]' || char(10))
 WHERE class_id = 'nb-hunter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-ashmedai: Ashmedai, Psychic & Sorceror
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10))
 WHERE class_id = 'nb-ashmedai'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-namtar: Nemtar/Hollow Men
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2001, 4001, 8501, 17001, 24501, 35601, 49701, 69801, 94901, 130001, 180001, 228101, 279201, 339301]' || char(10))
 WHERE class_id = 'nb-namtar'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-snake-bird: Snakebird & Mystic
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10))
 WHERE class_id = 'nb-snake-bird'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-secondary-vampire: Nightprince & Vampire
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 5001, 10001, 20001, 40001, 80001, 120001, 160001, 200001, 250001, 300001, 400001, 500001, 600001, 1000001]' || char(10))
 WHERE class_id = 'nb-secondary-vampire'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-wild-vampire: Nightprince & Vampire
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 5001, 10001, 20001, 40001, 80001, 120001, 160001, 200001, 250001, 300001, 400001, 500001, 600001, 1000001]' || char(10))
 WHERE class_id = 'nb-wild-vampire'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-wampyr: Wampyr
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2701, 5401, 10801, 21601, 31601, 42801, 62001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10))
 WHERE class_id = 'nb-wampyr'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- nb-guardian: Nightbane & Guardian
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2401, 4601, 9201, 18401, 28301, 48001, 78001, 110001, 150001, 200001, 250001, 310001, 380001, 470001]' || char(10))
 WHERE class_id = 'nb-guardian'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;


-- THE NOTES. Each of the nine recorded its ladder as "not stored in xp_table" because
-- no R.C.C. could carry one; that is no longer true, so the sentence says where it is
-- now. Namtar's note also said its printed lower bounds were recorded as they stand;
-- the note still records them, and now says the ladder stores the overlaps plus one.
-- The Nightbane R.C.C.'s own note gave the old reason for stating none (the race's
-- would win); it still states none - the O.C.C.s carry the ladder - for the new one.

UPDATE imported_classes
   SET markdown = replace(markdown, 'NOT stored in xp_table, per the class-import rule that no R.C.C. carries one; recorded here for the lead.', 'Stored as xp_table (Nate, 2026-09-17: an R.C.C. may carry the ladder its book prints; an O.C.C.''s ladder still wins a pairing), each overlapping lower bound stored plus one.')
 WHERE class_id IN ('nb-doppleganger', 'nb-hunter', 'nb-secondary-vampire', 'nb-wild-vampire') AND instr(markdown, 'NOT stored in xp_table, per the class-import rule that no R.C.C. carries one; recorded here for the lead.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Not stored as xp_table: an R.C.C. carries none (class-import frontmatter reference and the regression invariant ''no R.C.C. carries one'').', 'Stored as xp_table (Nate, 2026-09-17: an R.C.C. may carry the ladder its book prints; an O.C.C.''s ladder still wins a pairing), each overlapping lower bound stored plus one.')
 WHERE class_id IN ('nb-ashmedai', 'nb-namtar') AND instr(markdown, 'Not stored as xp_table: an R.C.C. carries none (class-import frontmatter reference and the regression invariant ''no R.C.C. carries one'').') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Not stored as xp_table: an R.C.C. carries none (class-import frontmatter reference, and the regression invariant ''no R.C.C. carries one'').', 'Stored as xp_table (Nate, 2026-09-17: an R.C.C. may carry the ladder its book prints; an O.C.C.''s ladder still wins a pairing), each overlapping lower bound stored plus one.')
 WHERE class_id IN ('nb-snake-bird') AND instr(markdown, 'Not stored as xp_table: an R.C.C. carries none (class-import frontmatter reference, and the regression invariant ''no R.C.C. carries one'').') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'NOT stored in xp_table, per the class-import rule and the regression invariant that no R.C.C. carries one; recorded here for the lead.', 'Stored as xp_table (Nate, 2026-09-17: an R.C.C. may carry the ladder its book prints; an O.C.C.''s ladder still wins a pairing), each overlapping lower bound stored plus one.')
 WHERE class_id IN ('nb-wampyr', 'nb-guardian') AND instr(markdown, 'NOT stored in xp_table, per the class-import rule and the regression invariant that no R.C.C. carries one; recorded here for the lead.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'the printed lower bounds are recorded as they stand.', 'the printed lower bounds are recorded here as they stand, and xp_table stores each overlap plus one.')
 WHERE class_id = 'nb-namtar' AND instr(markdown, 'the printed lower bounds are recorded as they stand.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'because the race''s value would win over the occupation''s;', 'because an O.C.C.''s ladder wins a pairing and each package carries its own;')
 WHERE class_id = 'nb-nightbane' AND instr(markdown, 'because the race''s value would win over the occupation''s;') > 0;

-- Read the result back.
SELECT 'all nine Nightbane races carry their ladder right after the category line' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE (class_id = 'nb-doppleganger' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14601, 21001, 30001, 40001, 55001, 75001, 105001, 140001, 190001, 245001, 300001]' || char(10)) > 0)
    OR (class_id = 'nb-hunter' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 35001, 55001, 85001, 130001, 180001, 235001, 285001, 350001, 425001, 550001]' || char(10)) > 0)
    OR (class_id = 'nb-ashmedai' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)) > 0)
    OR (class_id = 'nb-namtar' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2001, 4001, 8501, 17001, 24501, 35601, 49701, 69801, 94901, 130001, 180001, 228101, 279201, 339301]' || char(10)) > 0)
    OR (class_id = 'nb-snake-bird' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)) > 0)
    OR (class_id = 'nb-secondary-vampire' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 5001, 10001, 20001, 40001, 80001, 120001, 160001, 200001, 250001, 300001, 400001, 500001, 600001, 1000001]' || char(10)) > 0)
    OR (class_id = 'nb-wild-vampire' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 5001, 10001, 20001, 40001, 80001, 120001, 160001, 200001, 250001, 300001, 400001, 500001, 600001, 1000001]' || char(10)) > 0)
    OR (class_id = 'nb-wampyr' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2701, 5401, 10801, 21601, 31601, 42801, 62001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10)) > 0)
    OR (class_id = 'nb-guardian' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2401, 4601, 9201, 18401, 28301, 48001, 78001, 110001, 150001, 200001, 250001, 310001, 380001, 470001]' || char(10)) > 0);

SELECT 'and each of the nine states xp_table exactly once as a line' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE class_id IN ('nb-doppleganger', 'nb-hunter', 'nb-ashmedai', 'nb-namtar', 'nb-snake-bird', 'nb-secondary-vampire', 'nb-wild-vampire', 'nb-wampyr', 'nb-guardian')
   AND length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) = length(char(10) || 'xp_table:');

SELECT 'the Nightbane R.C.C. itself still states no xp_table' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'nb-nightbane' AND instr(markdown, char(10) || 'xp_table:') = 0;

SELECT 'no Nightbane race note still says its ladder is not stored' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('nb-doppleganger', 'nb-hunter', 'nb-ashmedai', 'nb-namtar', 'nb-snake-bird',
                    'nb-secondary-vampire', 'nb-wild-vampire', 'nb-wampyr', 'nb-guardian', 'nb-nightbane')
   AND (instr(markdown, 'carries one') > 0 OR instr(markdown, 'value would win over the occupation') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-nb-race-xp-ladders.sql');
