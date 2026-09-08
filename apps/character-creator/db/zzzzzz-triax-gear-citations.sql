-- Two cybernetics rows get the page the book actually prints them on: 154.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-triax-gear-citations.sql
--
-- BOOK-INGEST-AUDIT.md F40.
--
-- WHAT WAS WRONG. add-triax-gear-e-cybernetics.sql covers printed 153-154 and
-- assigned its citations by CATEGORY rather than by page: the four entries that
-- do damage got p.154 and the other twenty-one got p.153. Six of the
-- twenty-five are on 154, so the two that are on 154 and do not do damage were
-- filed one page early.
--
-- WHAT THE PAGES SAY, read from .cache/books/triax/txt/ (page_offset 0, so
-- printed 154 is p154.txt, and the folio 154 is printed on the page at
-- p154.txt:76):
--
--   Extendible Hydraulic Hands/Arm ... p154.txt:10-18, closing "Typical Arm
--                                      P.S.: 10 to 20, Cost: 150,000 credits."
--   Psionic Electro-Magnetic Dampers .. p154.txt:78-83, "Bonuses: + 1 to save
--                                      vs all psionic attacks, +2 to save vs
--                                      possession, and +1 to save vs magic
--                                      illusions and mind control."
--
-- THE STORED VALUES AGREE WITH THOSE PAGES, and that agreement is the evidence
-- rather than the name appearing there. The hydraulic arm stores cost 150000
-- against the printed 150,000 credits; the dampers store +1/+2/+1 in the same
-- order the page prints them, and store NO cost, which is why the page had to
-- be read for it at all. The entry directly BELOW the dampers on that page is
-- the RVB-31 Concealed Vibro-Blade, which already cited p.154 correctly - two
-- adjacent entries, one filed on each page.
--
-- WHY THIS IS NOT INGESTION-AUDIT F20. That finding also accused production
-- rows of citing the wrong page, its headline was false, and taking it found
-- that its "fix" would have destroyed a verified citation. The difference is
-- the evidence: F20 had a page number that looked wrong, and these two have a
-- folio that reads 154 on the page carrying the entry, plus a stored value that
-- matches the printed one. The other twenty-three rows in that file were
-- checked the same way and are correct; they are not touched here.
--
-- ONE OF THE TWO WAS ALREADY BEING REPORTED. scripts/source-coverage.mjs
-- --values has flagged the hydraulic arm since it shipped:
--
--   LATE  Extendible Hydraulic Hands/Arm = 150000 - cites triax p153-p153,
--         printed one page later
--
-- The dampers row is invisible to it because its cost is NULL, so there is no
-- value to test against the page. That is the gap, and it is narrower than
-- "the ledger cannot see a wrong citation" - it can, wherever a number exists.
--
-- Sorts after add-triax-gear-e-cybernetics.sql and after
-- fix-triax-cybernetics-category.sql, which sets category on the same rows and
-- does not touch source_book.

UPDATE gear
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.154'
 WHERE slug IN ('extendible-hydraulic-arm', 'psionic-electro-magnetic-dampers')
   AND source_book = 'Rifts World Book 5: Triax and the NGR p.153';

-- Verifies itself. Both rows must read p.154, and the twenty-three that were
-- checked and found correct must not have moved.
SELECT 'the hydraulic arm cites 154' AS assertion,
       source_book AS got, 'Rifts World Book 5: Triax and the NGR p.154' AS want
  FROM gear WHERE slug = 'extendible-hydraulic-arm';

SELECT 'the psionic dampers cite 154' AS assertion,
       source_book AS got, 'Rifts World Book 5: Triax and the NGR p.154' AS want
  FROM gear WHERE slug = 'psionic-electro-magnetic-dampers';

SELECT 'the other nineteen 153 rows are untouched' AS assertion,
       count(*) AS got, 19 AS want
  FROM gear WHERE source_book = 'Rifts World Book 5: Triax and the NGR p.153';

SELECT 'and six rows now cite 154' AS assertion,
       count(*) AS got, 6 AS want
  FROM gear WHERE source_book = 'Rifts World Book 5: Triax and the NGR p.154';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-triax-gear-citations.sql');
