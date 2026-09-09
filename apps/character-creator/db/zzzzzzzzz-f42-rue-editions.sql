-- BOOK-INGEST-AUDIT.md F42: six Rifts Ultimate Edition gear rows carry
-- FIRST-EDITION M.D.C. under a RUE citation. Nate settled it 2026-09-09:
-- **RUE wins** - update the values, keep the citations.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzz-f42-rue-editions.sql
--
-- Ten published class references point at these rows - `cyber-knight`,
-- `mind-melter`, `combat-cyborg` and `juicer-wannabe` cite the Wastelander;
-- `cyber-knight` and `mind-melter` also cite the Speedster duplicate; one cites
-- the jet pack. They become correct without any class being touched, which is
-- the whole argument for this direction over re-citing to the older book.
--
-- == FIVE ROWS MOVE. THE SIXTH IS THE CONTROL AND IS ASSERTED UNCHANGED ==
--
--   a-t-v-speedster-hover-cycle    75 -> 85    Speedster Hovercycle
--   the-wastelander-motorcycle     45 -> 60    Wastelander Motorcycle
--   the-big-boss-a-t-v             65 -> 100   Big Boss ATV
--   the-mountaineer-a-t-v         140 -> 210   Mountaineer ATV
--   wilk-s-jet-pack                20 -> 30    Wilk's Jet Pack
--   the-highway-man-motorcycle     75 == 75    unchanged in BOTH editions
--
-- Every RUE figure was read from a 200 dpi render of printed 266-267 and 71-72
-- during the F41 sessions. Every first-edition figure was read from
-- `Rifts Main.pdf` and `Rifts Main-206-230.pdf` as throwaway probes - that book
-- is registered `page_offset: null` and its `books.json` note says not to cache
-- it, and nothing here cached it. The F43 session independently re-confirmed two
-- of them off a render of core-book printed 228: `Wilk's Jet Pack ... Main Body
-- - 20`, and the Mountaineer's `Black Market Cost: 64,000`.
--
-- == THE DESCRIPTIONS MOVE TOO, AND THAT IS WIDER THAN THE PROPOSAL SAID ==
--
-- F42's proposal says *"update the six `mdc` values"*. Three of the rows also
-- carry the figure IN PROSE, as a `M.D.C. by Location:` list, and leaving those
-- saying 65 while the column says 100 would make each row contradict itself -
-- which is a worse state than the one this finding was filed about. So the prose
-- moves with the column, and the TIRE COUNTS move with it, because the errata
-- changed those too:
--
--   the-wastelander-motorcycle   Tires (2) 1 each  -> 2 each
--   the-mountaineer-a-t-v        Super Tires (3)   -> Super Tires (4)
--   the-big-boss-a-t-v           Tires (4) 5 each  -> unchanged, already RUE's
--
-- `a-t-v-speedster-hover-cycle` and `wilk-s-jet-pack` carry no M.D.C. prose at
-- all - the column is the only place the figure lives in those two.
--
-- ASCII AND THE DASHES. `the-big-boss-a-t-v` writes `Main Body - 65` with an
-- ASCII hyphen; the other two write an EM DASH, codepoint 8212 (measured with
-- `unicode()` on production, 2026-09-09). This file is pure ASCII, so the em
-- dash is built with `char(8212)` rather than typed - a literal would fail
-- `d1-apply`'s pre-flight, and getting it wrong would silently match nothing and
-- leave the prose stale while the column moved.
--
-- == WHAT THIS DELIBERATELY DOES NOT DO ==
--
-- **The duplicate pairs are not merged.** After this, `speedster-hovercycle` and
-- `a-t-v-speedster-hover-cycle` both read 85, `big-boss-atv` and
-- `the-big-boss-a-t-v` both read 100, and `mountaineer-atv` and
-- `the-mountaineer-a-t-v` both read 210. They become value-identical, which is
-- what makes them cleanly mergeable - but merging live rows two classes cite is
-- duplicate-review work and needs Nate. F44 made two of the three visible to
-- `findDuplicates` for the first time.
--
-- **No citation changes.** The rows keep `Rifts Ultimate Edition p.266` and
-- `p.267`, which is now true of their values as well as their prose.
--
-- == NINE Z'S ==
--
-- `zzzzzzzz-rue-vessels-p266-267.sql` asserts **"the first-edition figures are
-- still in gear, unaltered"** for four of these five rows. This file rewrites
-- exactly those figures, so it must sort after it. See the ninth-tier row in
-- `docs/operations.md`, added by F43 for the same reason.
--
-- Pure ASCII with LF endings. Every UPDATE is guarded on the OLD value, so the
-- file is inert on a second run and cannot fire against a corrected row.

-- --- the two rows whose figure lives only in the column ---
UPDATE gear SET mdc = 85  WHERE slug = 'a-t-v-speedster-hover-cycle' AND mdc = 75;
UPDATE gear SET mdc = 30  WHERE slug = 'wilk-s-jet-pack'             AND mdc = 20;

-- --- the three that also say it in prose ---
-- Wastelander: main body 45 -> 60, and the tires 1 each -> 2 each.
UPDATE gear
   SET mdc = 60,
       description = replace(
         replace(description,
           'Tires (2) ' || char(8212) || ' 1 each',
           'Tires (2) ' || char(8212) || ' 2 each'),
         'Main Body ' || char(8212) || ' 45',
         'Main Body ' || char(8212) || ' 60')
 WHERE slug = 'the-wastelander-motorcycle' AND mdc = 45;

-- Big Boss: main body 65 -> 100. Its tires already match RUE, and its dash is an
-- ASCII hyphen rather than an em dash.
UPDATE gear
   SET mdc = 100,
       description = replace(description, 'Main Body - 65', 'Main Body - 100')
 WHERE slug = 'the-big-boss-a-t-v' AND mdc = 65;

-- Mountaineer: main body 140 -> 210, and THREE super tires -> four.
UPDATE gear
   SET mdc = 210,
       description = replace(
         replace(description, 'Super Tires (3)', 'Super Tires (4)'),
         'Main Body ' || char(8212) || ' 140',
         'Main Body ' || char(8212) || ' 210')
 WHERE slug = 'the-mountaineer-a-t-v' AND mdc = 140;

-- --- readback ---
-- Every want is the figure read off the RUE render, not read back from a
-- database that has just been written.

SELECT 'the five figures are now RUE''s' AS assertion, count(*) AS got, 5 AS want
  FROM gear
 WHERE (slug = 'a-t-v-speedster-hover-cycle' AND mdc =  85)
    OR (slug = 'the-wastelander-motorcycle'  AND mdc =  60)
    OR (slug = 'the-big-boss-a-t-v'          AND mdc = 100)
    OR (slug = 'the-mountaineer-a-t-v'       AND mdc = 210)
    OR (slug = 'wilk-s-jet-pack'             AND mdc =  30);

-- The control: unchanged in both editions, so it must not have moved.
SELECT 'the Highway-Man is untouched at 75' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'the-highway-man-motorcycle' AND mdc = 75;

-- Not one first-edition figure survives on a RUE-cited row.
SELECT 'no first-edition figure is left behind' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE (slug = 'a-t-v-speedster-hover-cycle' AND mdc =  75)
    OR (slug = 'the-wastelander-motorcycle'  AND mdc =  45)
    OR (slug = 'the-big-boss-a-t-v'          AND mdc =  65)
    OR (slug = 'the-mountaineer-a-t-v'       AND mdc = 140)
    OR (slug = 'wilk-s-jet-pack'             AND mdc =  20);

-- THE PROSE MOVED WITH THE COLUMN. This is the half the proposal did not name,
-- and the half that silently rots if it is forgotten.
SELECT 'the prose agrees with the column' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'the-wastelander-motorcycle' AND instr(description, 'Main Body ' || char(8212) || ' 60') > 0)
    OR (slug = 'the-big-boss-a-t-v'         AND instr(description, 'Main Body - 100') > 0)
    OR (slug = 'the-mountaineer-a-t-v'      AND instr(description, 'Main Body ' || char(8212) || ' 210') > 0);

SELECT 'and no stale figure survives in prose' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE (slug = 'the-wastelander-motorcycle' AND instr(description, 'Main Body ' || char(8212) || ' 45') > 0)
    OR (slug = 'the-big-boss-a-t-v'         AND instr(description, 'Main Body - 65') > 0)
    OR (slug = 'the-mountaineer-a-t-v'      AND instr(description, 'Main Body ' || char(8212) || ' 140') > 0);

SELECT 'the tire counts moved too' AS assertion, count(*) AS got, 2 AS want
  FROM gear
 WHERE (slug = 'the-wastelander-motorcycle' AND instr(description, 'Tires (2) ' || char(8212) || ' 2 each') > 0)
    OR (slug = 'the-mountaineer-a-t-v'      AND instr(description, 'Super Tires (4)') > 0);

-- The duplicate pairs now agree, which is what makes them mergeable later.
SELECT 'each duplicate pair now agrees' AS assertion, count(*) AS got, 3 AS want
  FROM gear a JOIN gear b ON b.mdc = a.mdc
 WHERE (a.slug = 'speedster-hovercycle' AND b.slug = 'a-t-v-speedster-hover-cycle')
    OR (a.slug = 'big-boss-atv'         AND b.slug = 'the-big-boss-a-t-v')
    OR (a.slug = 'mountaineer-atv'      AND b.slug = 'the-mountaineer-a-t-v');

-- Nothing was added, removed or re-cited: this finding moves values only.
SELECT 'twelve RUE vehicle rows, still' AS assertion, count(*) AS got, 12 AS want
  FROM gear WHERE category = 'vehicle' AND source_book LIKE '%Ultimate%';

SELECT count(*) AS gear_rows FROM gear;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f42-rue-editions.sql');
