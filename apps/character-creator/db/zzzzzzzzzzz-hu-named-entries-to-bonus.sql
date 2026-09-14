-- The seventeen named skill entries that still carry the CATALOG's arithmetic,
-- rewritten as the bonus the book actually prints.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzz-hu-named-entries-to-bonus.sql
--
-- BOOK-INGEST-AUDIT F83, the leftover - AND ITS SCOPE WAS WRONG. F83's note
-- says "the thirty live Heroes Unlimited classes state absolute base: values
-- computed as catalog base plus printed bonus ... So the NAMED half of every
-- one of them carries the catalog's arithmetic until it is backfilled."
-- Measured against production 2026-09-14, through the real parseClassMarkdown
-- and over all three places an entry lives, `variants[]` included:
--
--   * ELEVEN of the thirty have no named skill entry at all.
--   * The THIRTEEN education classes with named entries already state THIS
--     BOOK's base. For each, `stored - book base` is a constant equal to that
--     class's educational bonus while `stored - catalog base` is scattered, and
--     the eleven hu-edu-* bodies say so in their own prose. Rewriting them from
--     the catalog's arithmetic would have made 323 correct entries WRONG.
--   * `hu-hardware` is the ONLY class that ever asserted the convention, in its
--     own extraction_notes, and the finding generalised from it.
--   * TEN further candidates are printed ABSOLUTES, not catalog-plus-bonus:
--     printed 157 and 161 give the Special Training classes figures like
--     `Mathematics: Basic - 98%` and `Computer Operation - 98%` outright. The
--     derivation would have pushed those to 106-133%.
--
-- So the real leftover is SEVENTEEN entries in two classes, and this file is it.
--
-- ===================================================================
-- WHY `bonus:` AND NOT A RECOMPUTED `base:`
-- ===================================================================
--
-- Both would be correct today. `bonus:` cannot go stale.
--
-- `app.js` resolveSkill reads `explicit.base ?? (explicit.bonus && catBase ?
-- catBase + explicit.bonus : catBase)`, where catBase is the row AFTER
-- skill_system_bases has been substituted into it. So `bonus: 30` on a named
-- entry means "the book's own figure, plus the thirty this class prints" and
-- keeps meaning that when an override row is corrected. A recomputed absolute
-- means it only until the next time somebody reads the page.
--
-- `per_level` IS DROPPED FROM EVERY ENTRY, and that is the second half of the
-- same argument: `resolveSkill` takes `explicit.per_level ?? cat.per_level ??
-- 0`, so removing it lets the substituted row supply the gain. That silently
-- corrects three entries whose stored 5 disagrees with the book - Mathematics:
-- Advanced is +4, Weapon Systems +2, Basic Mechanics +4 - without this file
-- having to state a single per-level figure.
--
-- ===================================================================
-- EVERY BONUS BELOW IS READ OFF THE PAGE, NOT DERIVED
-- ===================================================================
--
-- The book prints these as BONUSES, which is what makes the conversion exact
-- rather than a reconstruction. Cache p073, p075, p076 and p155:
--
--   printed 73, Hardware: Electrical
--     Electrical Engineer +30   Read Sensory Instruments +20
--     Mathematics: Advanced +20  Computer Operation +30
--     Computer Programming +30   Basic Mechanics +10   Surveillance +30
--   printed 75, Hardware: Mechanical
--     Mechanical Skills (plus Mechanical engineering) +30
--     Read Sensory Instruments +25   Weapon Systems +20
--     Mathematics: Advanced +24      Basic Electronics +30 (conditional)
--   printed 76, Hardware: Weapons
--     Basic Electronics +10   Basic Mechanics +20
--   printed 155, Hunter/Vigilante
--     Wilderness Survival +30   Land Navigation +30   Tracking +35
--
-- `Read Sensory Instruments` is the catalog's `Sensory Equipment`, and
-- `Tracking` is `Tracking (people)`.
--
-- WHAT IS DELIBERATELY NOT TOUCHED, so nobody reads it as a gap:
--
--   * `Hot Wiring` 92%, `Building Super Vehicles` 94%, `Computer Hacking` 82%,
--     `Recognize Vehicle Quality` 50% and their siblings - the book prints
--     these as absolutes for the character, not as bonuses.
--   * `Demolitions` and `Demolitions Disposal` at +24% in the weapons variant -
--     the book's base for both AGREES with the catalog (60%/+3), so there is no
--     override row and the stored figure is already right.
--   * Every entry in the sixteen education classes, for the reason at the top.
--   * `hu-alien-edu-combat-specialist`'s `First Aid` at 65. Printed 56 gives
--     that package "+15% when applicable" and the book's First Aid is 50, so 65
--     is already book-plus-bonus. It reads as ambiguous only because the
--     catalog's 45 plus a hypothetical 20 lands on the same number.
--
-- Guarded per entry on an exact string, so re-running is a no-op.

-- printed 73 - Hardware: Electrical
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Electrical Engineer", base: 60, per_level: 5 }',
  '- { name: "Electrical Engineer", bonus: 30 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Sensory Equipment", base: 50, per_level: 5 }',
  '- { name: "Sensory Equipment", bonus: 20, note: "Printed 73 as Read Sensory Instruments." }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Mathematics: Advanced", base: 65, per_level: 5 }',
  '- { name: "Mathematics: Advanced", bonus: 20 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Computer Operation", base: 70, per_level: 5 }',
  '- { name: "Computer Operation", bonus: 30 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Computer Programming", base: 60, per_level: 5 }',
  '- { name: "Computer Programming", bonus: 30 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Basic Mechanics", base: 40, per_level: 5 }',
  '- { name: "Basic Mechanics", bonus: 10 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Surveillance", base: 60, per_level: 5 }',
  '- { name: "Surveillance", bonus: 30, note: "Printed 73 as Surveillance." }')
 WHERE class_id = 'hu-hardware';

-- printed 75 - Hardware: Mechanical
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Mechanical Engineer", base: 55, per_level: 5 }',
  '- { name: "Mechanical Engineer", bonus: 30 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Sensory Equipment", base: 55, per_level: 5 }',
  '- { name: "Sensory Equipment", bonus: 25, note: "Printed 75 as Read Sensory Instruments, at +25% here against +20% in the electrical area." }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Weapon Systems", base: 60, per_level: 5 }',
  '- { name: "Weapon Systems", bonus: 20, note: "Printed 75. The per-level gain is the book''s 2%, supplied by skill_system_bases rather than restated here." }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Mathematics: Advanced", base: 69, per_level: 5 }',
  '- { name: "Mathematics: Advanced", bonus: 24 }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Basic Electronics", base: 60, per_level: 5, note: "Conditional: granted only if Electrical Engineer was NOT taken as a scholastic skill. The catalog cannot check that, so it is granted and the condition is stated." }',
  '- { name: "Basic Electronics", bonus: 30, note: "Conditional: granted only if Electrical Engineer was NOT taken as a scholastic skill. The catalog cannot check that, so it is granted and the condition is stated." }')
 WHERE class_id = 'hu-hardware';

-- printed 76 - Hardware: Weapons
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Basic Electronics", base: 40, per_level: 5, note: "Conditional: granted only if no form of electronics skill was taken. The catalog cannot check that, so it is granted and the condition is stated." }',
  '- { name: "Basic Electronics", bonus: 10, note: "Conditional: granted only if no form of electronics skill was taken. The catalog cannot check that, so it is granted and the condition is stated." }')
 WHERE class_id = 'hu-hardware';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Basic Mechanics", base: 50, per_level: 5, note: "Conditional: granted only if no form of mechanics skill was taken." }',
  '- { name: "Basic Mechanics", bonus: 20, note: "Conditional: granted only if no form of mechanics skill was taken." }')
 WHERE class_id = 'hu-hardware';

-- printed 155 - Hunter/Vigilante
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Wilderness Survival", base: 60 }',
  '- { name: "Wilderness Survival", bonus: 30 }')
 WHERE class_id = 'hu-hunter';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Land Navigation", base: 66 }',
  '- { name: "Land Navigation", bonus: 30 }')
 WHERE class_id = 'hu-hunter';
UPDATE imported_classes SET markdown = replace(markdown,
  '- { name: "Tracking (people)", base: 60 }',
  '- { name: "Tracking (people)", bonus: 35, note: "Printed 155 as Tracking." }')
 WHERE class_id = 'hu-hunter';

-- And the sentence in hu-hardware's extraction_notes that asserts the old
-- convention. It is the MECHANISM half of a class note, which is the half that
-- rots - `audit-menu` -> "A class note that cites a finding goes stale when the
-- finding is taken". It was true when written and is false now.
UPDATE imported_classes SET markdown = replace(markdown,
  '`base` ON EVERY ENTRY IS THE CATALOG BASE PLUS THE PRINTED BONUS, already added, which is the frontmatter rule: Electrical Engineer is 30 in the catalog and +30% here, so 60.',
  'EVERY NAMED ENTRY STATES THE BONUS THE BOOK PRINTS and no absolute at all: Electrical Engineer is `bonus: 30` because printed 73 says +30%, and the base it adds to comes from `skill_system_bases`, which holds this book''s own 45% rather than the catalog''s 30%. `per_level` is omitted for the same reason - the substituted row carries the book''s gain, which is how Mathematics: Advanced gets +4% and Weapon Systems +2% without this class restating either. This entry used to say the base was the CATALOG base plus the bonus, already added, which was true when it was written and was corrected with the rest of BOOK-INGEST-AUDIT F83''s leftover.')
 WHERE class_id = 'hu-hardware';

-- ASSERTIONS.

SELECT 'no converted entry still carries an absolute base' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-hardware', 'hu-hunter')
   AND (instr(markdown, '"Electrical Engineer", base:') > 0
     OR instr(markdown, '"Mechanical Engineer", base:') > 0
     OR instr(markdown, '"Sensory Equipment", base:') > 0
     OR instr(markdown, '"Computer Operation", base:') > 0
     OR instr(markdown, '"Computer Programming", base:') > 0
     OR instr(markdown, '"Basic Mechanics", base:') > 0
     OR instr(markdown, '"Basic Electronics", base:') > 0
     OR instr(markdown, '"Surveillance", base:') > 0
     OR instr(markdown, '"Weapon Systems", base:') > 0
     OR instr(markdown, '"Mathematics: Advanced", base:') > 0
     OR instr(markdown, '"Wilderness Survival", base:') > 0
     OR instr(markdown, '"Land Navigation", base:') > 0
     OR instr(markdown, '"Tracking (people)", base:') > 0);

-- The seventeen bonuses, spelled out, so a silent re-extraction cannot change
-- one. Each is the figure printed on the page named in the comments above.
--
-- WRITTEN AS A SUM OF CASES, NOT AS `UNION ALL`. The first draft used seven
-- UNION ALL terms per assertion and D1 refused the whole file with
-- `too many terms in compound SELECT: SQLITE_ERROR` - the cap is FIVE. Nothing
-- was applied, wrangler rolling the statement back, and production was verified
-- untouched before this was rewritten.
SELECT 'the seven electrical bonuses landed' AS assertion,
       (CASE WHEN instr(markdown, '"Electrical Engineer", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Sensory Equipment", bonus: 20') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Mathematics: Advanced", bonus: 20') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Computer Operation", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Computer Programming", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Basic Mechanics", bonus: 10') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Surveillance", bonus: 30') > 0 THEN 1 ELSE 0 END) AS got,
       7 AS want
  FROM imported_classes WHERE class_id = 'hu-hardware';

SELECT 'the mechanical and weapons bonuses landed' AS assertion,
       (CASE WHEN instr(markdown, '"Mechanical Engineer", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Sensory Equipment", bonus: 25') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Weapon Systems", bonus: 20') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Mathematics: Advanced", bonus: 24') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Basic Electronics", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Basic Electronics", bonus: 10') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Basic Mechanics", bonus: 20') > 0 THEN 1 ELSE 0 END) AS got,
       7 AS want
  FROM imported_classes WHERE class_id = 'hu-hardware';

SELECT 'the three Hunter bonuses landed' AS assertion,
       (CASE WHEN instr(markdown, '"Wilderness Survival", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Land Navigation", bonus: 30') > 0 THEN 1 ELSE 0 END)
     + (CASE WHEN instr(markdown, '"Tracking (people)", bonus: 35') > 0 THEN 1 ELSE 0 END) AS got,
       3 AS want
  FROM imported_classes WHERE class_id = 'hu-hunter';

-- The PRINTED ABSOLUTES must survive untouched. These are the ten the
-- derivation would have pushed to 106-133%, and they are the reason this file
-- is seventeen entries rather than twenty-seven.
-- SCOPED TO THIS BOOK, and the first draft was not. Written without the
-- `class_id LIKE 'hu-%'` clause it counted every class in the catalog carrying
-- that string and reported 14 against a want of 5 - the five are the Special
-- Training classes, and nine Rifts and Palladium Fantasy classes print
-- `Mathematics: Basic` at 98% as well. The DATA was right and the expectation
-- was wrong, which is the failure this file is otherwise about.
--
-- `d1-apply` prints a failed readback assertion and applies anyway, so that
-- mismatch did not stop the run; it was checked by hand against production
-- afterwards and only the assertion changed. The UPDATE statements above are
-- byte-identical to the ones that were applied.
SELECT 'the printed absolutes are untouched' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id LIKE 'hu-%'
   AND instr(markdown, '"Mathematics: Basic", base: 98') > 0;

SELECT 'and the Hunter keeps its own' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-hunter' AND instr(markdown, '"Mathematics: Basic", base: 98') > 0;

-- The education classes are NOT in this sweep and must not have moved. One of
-- them, spelled out: the book's Computer Operation is 60 and Trade School's
-- educational bonus is +20.
SELECT 'the education classes are untouched' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-edu-trade-school'
   AND instr(markdown, '"Computer Operation", base: 80, per_level: 5') > 0;

-- And the stale convention sentence is gone.
SELECT 'hu-hardware no longer asserts the catalog convention' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'hu-hardware' AND instr(markdown, 'CATALOG BASE PLUS THE PRINTED BONUS') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzz-hu-named-entries-to-bonus.sql');
