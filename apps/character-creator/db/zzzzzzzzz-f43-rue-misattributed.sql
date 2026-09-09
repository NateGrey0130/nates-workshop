-- BOOK-INGEST-AUDIT.md F43: two gear rows cite Rifts Ultimate Edition for
-- machines it does not print. One is re-cited to the book that does print it;
-- the other is retired, because it is not a machine at all.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzz-f43-rue-misattributed.sql
--
-- Taken on Nate's call, 2026-09-09: re-cite the Sky King, redirect the ATV.
--
-- == 1. `northern-gun-sky-king` IS REAL, AND RUE IS THE WRONG BOOK ==
--
-- The original Rifts core book prints the whole entry on printed **228**:
-- `Model Type: NG-A70`, `Class: All-Purpose Air Combat Vehicle`, `*Main Body -
-- 130`, and `Black Market Cost: 1.5 million credits, and up`. The gear row
-- stores `mdc = 130` and `cost = 1500000`, so it is a faithful transcription -
-- of a book it does not name. In RUE the only occurrence across all 382 cached
-- pages is a passing aside inside a skill description on cache p321.
--
-- **The page was verified twice and the first reading was wrong.** A premise
-- audit reported the stat block at pymupdf index 218; searching the whole PDF
-- puts it at index 228, and a 200 dpi render carries the folio 228 at the foot
-- of the page. Ten pages out. The number that mattered - 130 - was right in both
-- readings, which is exactly how a wrong page citation survives.
--
-- CITED AS `Rifts RPG (original core book) p.228`, which is the `title` string
-- `scripts/books.json` registers for `rifts-core`, so `resolveBookSlug` resolves
-- it. That registry entry says the book is kept *"so the spelling stays known
-- vocabulary if it reappears"* - this is the reappearance it was kept for. It
-- also says the book is NOT to be cached, and nothing here caches it: the page
-- was read with a throwaway `get_text()` probe and a render.
--
-- The row keeps its `category = 'vehicle'` and gains NO `vehicle_slug`. F41
-- imported vessels for the books it read; the original core book was never one
-- of its five sessions, and importing this vessel is not this finding's job.
--
-- == 2. `wilk-s-atv-transport-vehicle` IS NOT A MACHINE ==
--
-- It is the Mountaineer ATV's stat block under a name assembled across a page
-- break. RUE printed 266 ends with the Mountaineer's heading and opening
-- sentence; printed 267 opens with its continuation, `Vehicle Type: Three
-- wheeled armored ATV transport vehicle.`, and the next heading below that is
-- `Wilk's Jet Pack`. The row's `mdc = 210` and `cost = 76000` are the
-- Mountaineer's figures digit for digit. Grepping all sixteen cached books for
-- `ATV Transport` returns one hit: that continuation line.
--
-- So it is retired into `mountaineer-atv`, the row that names what the book
-- prints, on the `zzzzzz-ingestion-f28-law-canonical.sql` pattern - a
-- `catalog_redirects` row first, so the slug keeps resolving, then a guarded
-- DELETE.
--
-- **ITS FIGURES ARE CARRIED ACROSS FIRST, and that is the point of a merge
-- rather than a delete.** `mountaineer-atv` is a stub: `mdc` and `cost` are both
-- NULL. The retiring row holds the RUE figures for the same machine, so they
-- move before it goes. Nothing is lost and the surviving row stops being a stub.
--
-- NOTHING OWNS EITHER ROW. `character_items` has no row with either
-- `gear_slug`, no class markdown cites either at any status, and
-- `catalog_redirects` held no entry for either (`--remote`, 2026-09-09).
--
-- == NINE Z'S, AND THE REASON IS A READBACK ==
--
-- `zzzzzzzz-rue-vessels-p266-267.sql` asserts **"the two disputed rows are
-- untouched"** - that both of these rows exist and carry no pointer. Deleting
-- one makes that 1 against a want of 2, so this file must sort AFTER it, and
-- after `zzzzzzzz-web-glitter-boy-p071-072.sql` which is already last at eight.
-- A ninth `z` is the only thing that gets there without a contrived name.
--
-- Pure ASCII with LF endings.

-- --- 1. the Sky King: same data, the right book ---------------------------
-- Guarded on the wrong citation, so this cannot fire twice or overwrite a
-- correction somebody else has since made.
UPDATE gear
   SET source_book = 'Rifts RPG (original core book) p.228'
 WHERE slug = 'northern-gun-sky-king'
   AND source_book = 'Rifts Ultimate Edition';

-- --- 2. the ATV: carry its figures over, then retire it -------------------
-- The stub inherits the machine's real numbers. Guarded so it only fills NULLs
-- and only from the row about to be deleted.
UPDATE gear
   SET mdc = (SELECT mdc FROM gear WHERE slug = 'wilk-s-atv-transport-vehicle'),
       cost = (SELECT cost FROM gear WHERE slug = 'wilk-s-atv-transport-vehicle'),
       cost_note = 'Black market 76,000 credits for the basic vehicle with a gasoline engine, 70,000 for electric, or 500,000 for nuclear with a twenty year life. Additional armour costs 10,000 credits per 30 M.D.C. Carried over from the retired wilk-s-atv-transport-vehicle row, which held this machine''s figures under a name the book does not print - BOOK-INGEST-AUDIT F43.'
 WHERE slug = 'mountaineer-atv'
   AND mdc IS NULL
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'wilk-s-atv-transport-vehicle');

-- The redirect goes in BEFORE the delete, so the retired slug never stops
-- resolving. ON CONFLICT keeps the file re-runnable.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'wilk-s-atv-transport-vehicle', id, 'merge'
  FROM gear
 WHERE slug = 'mountaineer-atv'
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- Guarded on the figures, so this cannot fire against a row someone has since
-- corrected into something else.
DELETE FROM gear
 WHERE slug = 'wilk-s-atv-transport-vehicle'
   AND mdc = 210
   AND cost = 76000;

-- --- readback ---

SELECT 'the Sky King cites the book that prints it' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'northern-gun-sky-king'
   AND source_book = 'Rifts RPG (original core book) p.228';

-- Its data is untouched: this finding moved a citation, not a figure.
SELECT 'and its figures are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'northern-gun-sky-king' AND mdc = 130 AND cost = 1500000;

SELECT 'the fabricated row is gone' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'wilk-s-atv-transport-vehicle';

SELECT 'its slug still resolves, to the Mountaineer' AS assertion, count(*) AS got, 1 AS want
  FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
 WHERE r.catalog = 'gear' AND r.from_key = 'wilk-s-atv-transport-vehicle'
   AND g.slug = 'mountaineer-atv';

-- The figures survived the retirement rather than dying with the row.
SELECT 'the Mountaineer is no longer a stub' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'mountaineer-atv' AND mdc = 210 AND cost = 76000;

-- And it still points at its vessel, which F41 set.
SELECT 'and still points at its vessel' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'mountaineer-atv' AND vehicle_slug = 'mountaineer-atv';

-- Nothing else lost a row. RUE had 13 vehicle-category gear rows; one is gone.
SELECT 'twelve RUE vehicle rows remain' AS assertion, count(*) AS got, 12 AS want
  FROM gear WHERE category = 'vehicle' AND source_book LIKE '%Ultimate%';

-- No inventory pointed at the retired row, checked before the delete as well.
SELECT 'no inventory referenced the retired row' AS assertion, count(*) AS got, 0 AS want
  FROM character_items WHERE gear_slug = 'wilk-s-atv-transport-vehicle';

SELECT 'every pointer in the catalog still resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
 WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

SELECT count(*) AS gear_rows FROM gear;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f43-rue-misattributed.sql');
