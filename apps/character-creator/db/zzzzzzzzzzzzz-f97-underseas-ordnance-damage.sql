-- BOOK-INGEST-AUDIT F97: five Underseas ordnance rows carried a mega-damage
-- FLAG and no mega-damage NUMBER. The book is not silent. It prints all three.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzz-f97-underseas-ordnance-damage.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzz-f97-underseas-ordnance-damage.sql
--
-- ===================================================================
-- THE FINDING SAID THE DECIDING PAGE HAD NEVER BEEN OPENED. IT HAS NOW
-- ===================================================================
--
-- F97 recorded "Not measured: what printed 117 says, which is the one thing
-- that decides it", and offered two branches: fill `damage` from the page, or
-- record the book's silence and CLEAR `is_mega_damage`.
--
-- THE SECOND BRANCH IS DEAD. Rifts World Book 7: Underseas printed 117 carries
-- a heading of its own - "Cost & M.D.C. Damage Inflicted by Torpedoes & Depth
-- Charges:" - and under it a damage, a range and a cost for each of the four
-- torpedo grades. A separate "M.D.C. of Torpedoes:" line on the same page gives
-- each grade's M.D.C. and the depth charge's. So `is_mega_damage = 1` is right
-- on all five and three columns were droppable rather than one.
--
-- ===================================================================
-- WHICH CACHE PAGE, BECAUSE THE FINDING POINTS AT THE WRONG ONE
-- ===================================================================
--
-- F97 says "(`underseas` is cached, 216 pages, `page_offset: -1`)". That is the
-- book's top-level offset and it is WRONG FOR THIS PAGE. `scripts/books.json`
-- gives `underseas` a `page_offset_exceptions` entry putting printed 1-130 at
-- offset 0, because printed 131 is missing from the scan. Printed 117 is
-- therefore cache `p117`, not `p116` - and `p116` holds no torpedo text at all,
-- so a taker following the finding literally finds nothing and concludes the
-- book is silent. Which is the exact wrong answer.
--
-- Read it from `scripts/books.json`, which is what
-- `apps/character-creator/docs/surveys/underseas.md` already says to do.
--
-- ===================================================================
-- THE DIGITS WERE CHECKED THREE WAYS, BECAUSE TWO OF THEM PROVE NOTHING
-- ===================================================================
--
-- The five stored COSTS already match the page exactly. That is not evidence:
-- those costs were extracted from this same cache page, so agreement is
-- circular. What was done instead, 2026-09-15:
--
--   1. the cached 300 dpi OCR text (`.cache/books/underseas/txt/p117.txt`);
--   2. a FRESH 500 dpi render and re-OCR of the same page into a scratch cache,
--      which agrees with (1) digit for digit and independently reported
--      "last printed folio 117, offset +0";
--   3. the rendered page IMAGE, read directly for the two blocks below.
--
-- The digit-cipher warning that governs the Nightbane pages does not reach this
-- book: `.cache/books/underseas/manifest.json` says `"text_layer": false`, so
-- this is an OCR'd scan and not a text layer with substituted glyphs.
--
-- ===================================================================
-- WHAT THE PAGE PRINTS
-- ===================================================================
--
--   Mini-torpedo:   1D6x10 M.D. (HE or Plasma).  Range: One mile (1.6 km).
--                   Cost: 3500 credits each.     M.D.C.: 10
--   Light Torpedo:  2D4x10 M.D. (HE) or 1D6x10 M.D. (Plasma).
--                   Range: 5 miles (8 km).       Cost: 8000.    M.D.C.: 15
--   Medium Torpedo: 3D4x10 M.D. (HE) or 2D6x10 M.D. (Plasma).
--                   Range: 10 miles (16 km).     Cost: 10,000.  M.D.C.: 30
--   Heavy Torpedo:  4D6x10 M.D. (HE or Plasma).  Range: 20 miles (32 km).
--                   Cost: 20,000.                M.D.C.: 50
--   Depth Charge:   2D4x10 M.D. to a 100 foot radius and 4D6 M.D. to a further
--                   30 foot radius. Cost: 4500.  M.D.C.: five
--
-- Every cost matches what is already stored, on all five rows.
--
-- THE BOOK CONTRADICTS ITSELF ON ONE NUMBER, and it is recorded here rather
-- than stored because there is no column for it. The "Deep Sea Depth Charges"
-- entry says a depth charge is "-4 to strike its target (even a stationary
-- target) when launched more than a 3000 feet (914 m) above it". The "Maximum
-- Depth" paragraph on the SAME page says depth charges "are -5 to strike a
-- target (even a stationary one) when launched more than 4000 feet (1220 m)
-- away/above". Both readings were confirmed in the rendered image, so this is
-- the book disagreeing with itself and not an OCR fault. Neither figure is
-- written to a row; `gear` has no to-strike column and inventing one for a
-- number the book gives twice differently would be the worse of the two.
--
-- ===================================================================
-- THE SIXTH ROW IS NOT SWEPT IN, AND ITS OWN PAGE SAYS WHY
-- ===================================================================
--
-- F97's query returns SIX rows and its body says do not sweep the sixth in.
-- Its Proposal paragraph then says "fill the six rows' `damage`", which
-- contradicts the body. THE BODY IS RIGHT and the page settles it:
-- `unbreakable-md-plow` is Rifts World Book 18: Mystic Russia printed 125
-- (cache `p126`, that book's offset being +1), and all the page gives it is
-- "P.P.E. Cost: 100" - no damage, no M.D.C. It is a plough made of mega-damage
-- material that neither deals damage nor states an M.D.C., so its flag is a
-- unit and its NULLs are finished. It is untouched here and ASSERTED untouched
-- below, so that a later reader does not "complete" it from nothing.
--
-- ===================================================================
-- WHY THIS TIER, GIVEN IT DOES NOT NEED ONE
-- ===================================================================
--
-- These five rows are created by `add-underseas-gear.sql` and touched by
-- NOTHING else - grepped across `apps/character-creator/db/*.sql` for all five
-- slugs on 2026-09-15, one file matched. So the minimum correct tier is any
-- `zz-` file, and NO NEW TIER IS ADDED: this joins the existing thirteen-z tier
-- beside `zzzzzzzzzzzzz-f95-gear-repo-vs-live-residue.sql`, which the Data
-- scripts table already documents and whose glob already covers this filename.
--
-- Taking the deepest existing tier rather than the shallowest sufficient one is
-- that tier's own stated argument: a corrective file sorting merely after the
-- KNOWN clobberers is correct only until the next one lands. `f95` sorts before
-- `f97`, the two touch disjoint rows, and neither asserts anything about the
-- other's.
--
-- `add-underseas-gear.sql` IS NOT EDITED. It has been applied to every
-- environment, so editing it would move a rebuild and leave production behind.

-- The four torpedo grades and the depth charge. Guarded on the three columns
-- this file fills, so a re-run is a no-op and a half-applied environment
-- completes rather than skipping.

UPDATE gear
   SET damage = '1D6x10 M.D. (HE or Plasma).',
       range  = 'One mile (1.6 km).',
       mdc    = 10
 WHERE slug = 'torpedo-mini'
   AND (damage IS NULL OR range IS NULL OR mdc IS NULL);

UPDATE gear
   SET damage = '2D4x10 M.D. (HE) or 1D6x10 M.D. (Plasma).',
       range  = '5 miles (8 km).',
       mdc    = 15
 WHERE slug = 'torpedo-light'
   AND (damage IS NULL OR range IS NULL OR mdc IS NULL);

UPDATE gear
   SET damage = '3D4x10 M.D. (HE) or 2D6x10 M.D. (Plasma).',
       range  = '10 miles (16 km).',
       mdc    = 30
 WHERE slug = 'torpedo-medium'
   AND (damage IS NULL OR range IS NULL OR mdc IS NULL);

UPDATE gear
   SET damage = '4D6x10 M.D. (HE or Plasma).',
       range  = '20 miles (32 km).',
       mdc    = 50
 WHERE slug = 'torpedo-heavy'
   AND (damage IS NULL OR range IS NULL OR mdc IS NULL);

-- The depth charge's "range" is a DEPTH, which is what the book's own
-- "Maximum range/depth:" line calls it, so it goes in the same column and says
-- which it is.
UPDATE gear
   SET damage = '2D4x10 M.D. to a 100 foot (30.5 m) radius and 4D6 M.D. to an additional 30 foot (9 m) radius beyond that. High explosive/concussion only.',
       range  = 'Maximum range/depth two miles (3.2 km or 10,560 feet/3218 m); it explodes automatically at two miles, or at any set depth between 200 and 10,560 feet (61 to 3218 m).',
       mdc    = 5
 WHERE slug = 'deep-sea-depth-charge'
   AND (damage IS NULL OR range IS NULL OR mdc IS NULL);

-- ASSERTIONS.
--
-- Every `want` below is derived from the PAGE, not from the database that just
-- loaded this file.

SELECT 'the four torpedo grades carry the damage, range and M.D.C. printed 117 gives' AS assertion,
       count(*) AS got, 4 AS want
  FROM gear
 WHERE (slug = 'torpedo-mini'   AND damage = '1D6x10 M.D. (HE or Plasma).'                  AND mdc = 10 AND range = 'One mile (1.6 km).')
    OR (slug = 'torpedo-light'  AND damage = '2D4x10 M.D. (HE) or 1D6x10 M.D. (Plasma).'    AND mdc = 15 AND range = '5 miles (8 km).')
    OR (slug = 'torpedo-medium' AND damage = '3D4x10 M.D. (HE) or 2D6x10 M.D. (Plasma).'    AND mdc = 30 AND range = '10 miles (16 km).')
    OR (slug = 'torpedo-heavy'  AND damage = '4D6x10 M.D. (HE or Plasma).'                  AND mdc = 50 AND range = '20 miles (32 km).');

SELECT 'and the depth charge carries its two radii and its five M.D.C.' AS assertion,
       count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'deep-sea-depth-charge'
   AND mdc = 5
   AND instr(damage, '2D4x10 M.D. to a 100 foot') > 0
   AND instr(damage, '4D6 M.D. to an additional 30 foot') > 0;

-- THE FLAG WAS ALREADY RIGHT. Asserted because the finding's other branch was
-- to CLEAR it, and this file takes the opposite branch on the page's word.
SELECT 'all five keep the mega-damage flag, which the page says is correct' AS assertion,
       count(*) AS got, 5 AS want
  FROM gear
 WHERE slug IN ('deep-sea-depth-charge', 'torpedo-mini', 'torpedo-light', 'torpedo-medium', 'torpedo-heavy')
   AND is_mega_damage = 1;

-- And their costs are untouched, which is how the page was confirmed to be the
-- right one before anything was written.
SELECT 'and their five printed costs are unchanged' AS assertion,
       count(*) AS got, 5 AS want
  FROM gear
 WHERE (slug = 'deep-sea-depth-charge' AND cost = 4500)
    OR (slug = 'torpedo-mini'   AND cost = 3500)
    OR (slug = 'torpedo-light'  AND cost = 8000)
    OR (slug = 'torpedo-medium' AND cost = 10000)
    OR (slug = 'torpedo-heavy'  AND cost = 20000);

-- THE PLOUGH IS UNTOUCHED, and that is a result rather than an omission.
SELECT 'the Mystic Russia plough still states no damage and no M.D.C., as its own page does' AS assertion,
       count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'unbreakable-md-plow'
   AND damage IS NULL AND mdc IS NULL AND is_mega_damage = 1;

-- F97's OWN QUERY, run back. It answered 6 before this file and must answer 1
-- after it - the plough, which is correct as it stands.
--
-- THIS IS NOT THE BLANKET ASSERTION F97 FORBIDS. The posture says "Do NOT add a
-- blanket assertion of the shape that produced this finding - three were tried
-- and all three were wrong." The three that failed asserted ZERO over the whole
-- table. This one asserts the finding's own measured number and expects a
-- non-zero remainder, which is the opposite claim.
SELECT 'and F97''s query is down from six rows to the one that is correct' AS assertion,
       count(*) AS got, 1 AS want
  FROM gear
 WHERE is_mega_damage = 1 AND (damage IS NULL OR trim(damage) = '') AND mdc IS NULL;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-f97-underseas-ordnance-damage.sql');
