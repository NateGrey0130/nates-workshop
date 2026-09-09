-- BOOK-INGEST-AUDIT.md F46: the web-marked rows that carry combat numbers.
-- Three of the four are in Rifts Ultimate Edition after all, so they are
-- re-cited to it. The fourth stays marked, and this file says why.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzz-f46-web-rows-recited.sql
--
-- == THE RULE THIS FINDING IS ABOUT ==
--
-- The README's estimate tier forbids a row marked `Estimate - no published price
-- found` from carrying M.D.C., damage or an A.R. at all. `Web reference (not
-- book-verified)` carries no equivalent rule, and four rows held combat numbers
-- under it. Found while closing `F41`, where a readback asserted there were none
-- and was wrong.
--
-- **SEARCHING THE BOOKS CLOSED THREE OF THE FOUR**, which is the argument for
-- searching rather than stripping. Every figure below was read from the cached
-- OCR and then confirmed against a render, because `rue` is a scan with no text
-- layer:
--
--   c-18-laser-pistol   printed 257   Mega-Damage: 2D4 M.D.        stat block
--   cyber-armor         printed  65   A.R. 16, main body 50 M.D.C. stat block
--   hatchet             printed  56   1D6 S.D.C.                   NOT a stat block
--
-- **THE C-18 MATCHES ON EVERY FIELD, not just the one this finding is about.**
-- The book prints weight 4 lbs, range 800 feet (244 m), payload 10 shots and
-- 12,000 credits; the row already held 4, `800 feet (244 m)`, 10 and 12000. It
-- was a complete and accurate transcription of a page nobody credited - the same
-- shape as the Glitter Boy in `F41`'s last session.
--
-- **THE HATCHET IS THE WEAK ONE AND IS LABELLED AS SUCH.** Its 1D6 S.D.C. is a
-- parenthetical inside the Crazy O.C.C.'s `Standard Equipment` line on printed
-- 56 - `hatchet for cutting wood (1D6 S.D.C. damage)` - not a weapon stat block.
-- The figure is printed, on a page, and confirmed by render, so the citation is
-- real; it is simply weaker evidence than the other two and the note records
-- that rather than flattening the difference.
--
-- == `hand-axe` STAYS MARKED, AND IS A DUPLICATE NOBODY HAS MERGED ==
--
-- Searched for across all sixteen caches under both `hand axe` and `hatchet`:
-- every hit is a class equipment list naming `a small hand axe` with NO damage
-- figure. No book on this machine states a Hand Axe's damage.
--
-- **It is also, on the evidence, the same item as `hatchet`**: identical
-- `damage` (1D6), identical `weight_lbs` (3), identical `cost` (40), identical
-- `category`. `F44`'s acronym fix cannot see this pair - the names share no
-- token at all - so `findDuplicates` will not report it either. **Not merged
-- here**: merging two live catalog rows is duplicate-review work and needs Nate,
-- and this file's business is the marker.
--
-- So after this, exactly ONE row carries the web marker and a combat number, and
-- it is the one that genuinely has no book behind it. That is the honest end
-- state rather than a zero.
--
-- == NINE Z'S ==
--
-- `zzzzzzzz-web-glitter-boy-p071-072.sql` asserts **"four web-sourced rows still
-- carry a combat number"** and **"the web marker survives on the other rows"** at
-- 27. This file changes both, so it must sort after it.
--
-- Pure ASCII with LF endings. Every UPDATE is guarded on the marker.

UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.257'
 WHERE slug = 'c-18-laser-pistol'
   AND source_book = 'Web reference (not book-verified)';

UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.65'
 WHERE slug = 'cyber-armor'
   AND source_book = 'Web reference (not book-verified)';

UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.56'
 WHERE slug = 'hatchet'
   AND source_book = 'Web reference (not book-verified)';

-- --- readback ---

SELECT 'the three now cite a book and a page' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'c-18-laser-pistol' AND source_book = 'Rifts Ultimate Edition p.257')
    OR (slug = 'cyber-armor'       AND source_book = 'Rifts Ultimate Edition p.65')
    OR (slug = 'hatchet'           AND source_book = 'Rifts Ultimate Edition p.56');

-- Their figures are untouched: this finding moved citations, not values.
SELECT 'and their figures are unchanged' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'c-18-laser-pistol' AND damage = '2D4' AND is_mega_damage = 1)
    OR (slug = 'cyber-armor'       AND mdc = 50 AND ar = 16)
    OR (slug = 'hatchet'           AND damage = '1D6' AND is_mega_damage = 0);

-- Exactly one web-marked row still carries a combat number, and it is the one
-- with no book behind it.
SELECT 'one web-marked row still carries a combat number' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE source_book = 'Web reference (not book-verified)'
   AND (mdc IS NOT NULL OR damage IS NOT NULL OR ar IS NOT NULL);

SELECT 'and it is the hand axe' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'hand-axe'
   AND source_book = 'Web reference (not book-verified)'
   AND damage = '1D6';

-- The duplicate is recorded, not merged: both rows still exist and still agree.
SELECT 'the hand axe and the hatchet still agree, unmerged' AS assertion, count(*) AS got, 1 AS want
  FROM gear a JOIN gear b ON a.damage = b.damage AND a.cost = b.cost AND a.weight_lbs = b.weight_lbs
 WHERE a.slug = 'hand-axe' AND b.slug = 'hatchet';

SELECT 'the marker survives on the rest' AS assertion, count(*) AS got, 24 AS want
  FROM gear WHERE source_book = 'Web reference (not book-verified)';

SELECT count(*) AS web_marked FROM gear WHERE source_book = 'Web reference (not book-verified)';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f46-web-rows-recited.sql');
