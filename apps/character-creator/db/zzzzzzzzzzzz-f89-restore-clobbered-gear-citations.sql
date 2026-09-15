-- Three gear citations a rebuild loses, and the two halves that ride with them.
--
-- BOOK-INGEST-AUDIT.md F89. One-off data script, run once per environment.
-- NOT a migration - it changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzz-f89-restore-clobbered-gear-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzz-f89-restore-clobbered-gear-citations.sql
--
-- ===================================================================
-- F89 SAID "NOTHING IN THE REPO REPRODUCES IT". EVERY STRING IS IN THE
-- REPO. TWO ARE OVERWRITTEN AND TWO ARE GUARDED OUT.
-- ===================================================================
--
-- The finding described three gear rows whose production `source_book` is
-- richer than the one a clean rebuild produces, and proposed writing the
-- citations into the `zzzz-cite-*` tier. Both halves of that were wrong, and
-- the corrected diagnosis is why this file is named the way it is.
--
-- THE TWO DEAD BOY SUITS. `fix-new-west-black-market-armour-prices.sql` lines
-- 35-45 append `; Rifts World Book 14: New West p.178` to both, and append the
-- matching Black Market sentence to `cost_note`. Two separate faults stop that
-- reaching a rebuilt database:
--
--   1. THE GUARD IS `instr(cost_note, 'NEW WEST') = 0` AND `cost_note` IS NULL
--      AT THAT POINT. `instr(NULL, ...)` is NULL, `NULL = 0` is NULL, and a
--      WHERE that is NULL matches nothing - so both UPDATEs silently no-op. In
--      production they fired because the row already carried a note by the time
--      the file was applied BY HAND, five weeks after the file that fills it.
--      `merge-rifts-armor-duplicates.sql` sorts AFTER `fix-`, so on a rebuild
--      the order is reversed. Use COALESCE in a guard that can meet a NULL.
--
--   2. EVEN IF IT FIRED, `zzzz-restore-gear-values.sql` (lines 153-164) SETS
--      `source_book` ON BOTH ROWS UNCONDITIONALLY, to the bare
--      `Rifts Ultimate Edition p.261-265`, and `zzzz-r...` sorts after
--      `zzzz-c...`. **The tier F89 proposed writing this into is clobbered by a
--      file in the same tier.** A `zzzz-cite-` file would have verified green
--      against production, where it runs last by hand, and been reverted on
--      every rebuild - which is the exact failure `zzzz-cite-rue-rows.sql`'s own
--      header was written about.
--
-- THE MEDITATION CHIP IS NOT A DISAGREEMENT, and F89 said one side had to be
-- wrong. Both are right. The row is a STUB two different class imports create,
-- and the item appears in two classes' Standard Equipment lists:
--
--   * printed 27 ends the Promethean Phase Adept's list, which runs on to
--     printed 28 with "computer chip with audiovisual meditation aids" - so
--     `add-promethean-phase-adept-class.sql` cites p.27-28;
--   * printed 29 carries the Phase Mystic's own list with the same item - so
--     `add-phase-mystic-class.sql` cites p.29.
--
-- Both are `INSERT OR IGNORE` on the same slug, so whichever runs first wins.
-- `add-ph...` sorts before `add-pr...`, so a rebuild keeps p.29; production ran
-- them in the other order and kept p.27-28. Read off the cached pages, which
-- are the printed pages: this book's `page_offset` is 0.
--
-- So the row is cited to BOTH, and neither previous string was an error - each
-- was correct and incomplete.
--
-- ===================================================================
-- TWELVE z's, AND THE REASON IS THE FINDING ITSELF
-- ===================================================================
--
-- Eleven was the maximum in the tree when this was written. The defect being
-- repaired IS a later file overwriting an earlier one's work, so this file
-- sorts after every data script that exists rather than after the ones that are
-- known to clobber these three rows today. The count of z's is a counter and
-- not a category, exactly as `docs/operations.md` says.
--
-- ===================================================================
-- THE TWO HALVES THAT RIDE WITH THE CITATIONS
-- ===================================================================
--
-- F89 scoped itself to "three rows in one column", which left half of the same
-- shipped edits unreproducible. Both are repaired here and neither widens this
-- into a general column sweep:
--
--   * `cost_note` on the two suits - the other half of the SAME statement in
--     `fix-new-west-black-market-armour-prices.sql` that the NULL guard killed.
--     `zzzz-restore-gear-values.sql` does not touch `cost_note`, so this half
--     was only ever lost to fault 1.
--   * `category` on the Meditation Chip - live NULL against the repo's `gear`.
--     Here the REBUILD is the better record and production is the side that is
--     wrong, which is worth saying out loud: this file does not assume
--     production wins.
--
-- Everything here is idempotent, and in production every statement but the two
-- Meditation Chip ones is already a no-op.

-- ===== 1. The two Dead Boy suits: the citation =====
-- Set rather than appended. An append would double the New West half on any
-- database where the original file DID fire, and this must be safe to re-run.

UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.261-265; Rifts World Book 14: New West p.178'
 WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor');

-- ===== 2. The two Dead Boy suits: the Black Market note =====
-- COALESCE on BOTH sides. The guard is the one from the original file with the
-- NULL hole closed, and the concatenation needs it too: `NULL || 'text'` is
-- NULL in SQLite, so an unguarded append to an empty note ERASES the row's
-- note rather than filling it.

UPDATE gear
   SET cost_note = COALESCE(cost_note, '')
     || ' NEW WEST, printed 178, prices the Black Market knock-off at 50,000 credits'
     || ' with fair to poor availability, especially in the West - it is popular in the'
     || ' Pecos Empire. Same suit, a different market.'
 WHERE slug = 'ca-1-heavy-dead-boy-armor'
   AND instr(COALESCE(cost_note, ''), 'NEW WEST') = 0;

UPDATE gear
   SET cost_note = COALESCE(cost_note, '')
     || ' NEW WEST, printed 178, prices the Black Market knock-off at 40,000 credits'
     || ' with fair to poor availability, especially in the West - it is popular in the'
     || ' Pecos Empire. Same suit, a different market.'
 WHERE slug = 'ca-2-light-dead-boy-armor'
   AND instr(COALESCE(cost_note, ''), 'NEW WEST') = 0;

-- ===== 3. The Meditation Chip: both pages, and its category =====

UPDATE gear
   SET source_book = 'Rifts Dimension Book 2: Phase World p.27-28, 29'
 WHERE slug = 'meditation-chip';

UPDATE gear
   SET category = 'gear'
 WHERE slug = 'meditation-chip' AND category IS NULL;

-- ASSERTIONS.

SELECT 'both Dead Boy suits cite New West as well as RUE' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND source_book = 'Rifts Ultimate Edition p.261-265; Rifts World Book 14: New West p.178';

-- NOT APPENDED TWICE. The failure mode of fixing this with `||` instead of `=`.
SELECT 'and neither cites it twice' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND instr(substr(source_book, instr(source_book, 'New West') + 8), 'New West') > 0;

SELECT 'both carry the Black Market note the NULL guard lost' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND instr(COALESCE(cost_note, ''), 'NEW WEST, printed 178') > 0;
SELECT 'and the note says a different figure for each suit' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE (slug = 'ca-1-heavy-dead-boy-armor' AND instr(cost_note, '50,000 credits') > 0)
     OR (slug = 'ca-2-light-dead-boy-armor' AND instr(cost_note, '40,000 credits') > 0);
SELECT 'and neither note is doubled' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND instr(substr(cost_note, instr(cost_note, 'NEW WEST') + 8), 'NEW WEST') > 0;

-- THE ROW THAT PROVES THE NULL GUARD WAS THE FAULT. `dog-pack-dpm-riot-armor`
-- takes the same append from the same file and DOES reproduce on a rebuild,
-- because its guard is `cost IS NULL` rather than an instr() over a NULL note.
-- It is untouched here and must stay exactly as it was.
SELECT 'the third row of that edit is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'dog-pack-dpm-riot-armor'
   AND source_book = 'Rifts Ultimate Edition p.261-265; Rifts World Book 14: New West p.178';

SELECT 'the Meditation Chip cites both classes'' pages' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'meditation-chip'
   AND source_book = 'Rifts Dimension Book 2: Phase World p.27-28, 29';
SELECT 'and it is categorised' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'meditation-chip' AND category = 'gear';

-- NOTHING ELSE MOVED. This file names three slugs; the New West citation must
-- reach exactly the three rows that edit was ever about - the two suits and the
-- Dog Pack it did not touch - and no fourth row.
-- COUNTED ON THE COMBINED CITATION, not on `New West p.178` alone. That page is
-- also `branaghan-armor`'s OWN primary source, so a bare match returns four and
-- the fourth is correct - which the first draft of this assertion got wrong.
SELECT 'exactly three rows carry the two-book citation' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE source_book = 'Rifts Ultimate Edition p.261-265; Rifts World Book 14: New West p.178';
SELECT 'and only one row cites Phase World p.27-28' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE instr(COALESCE(source_book, ''), 'Phase World p.27-28') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzz-f89-restore-clobbered-gear-citations.sql');
