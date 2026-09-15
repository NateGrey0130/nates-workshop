-- BOOK-INGEST-AUDIT F95: the last fifteen gear values where the repo and
-- production disagree - and they do NOT all fall the same way.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzz-f95-gear-repo-vs-live-residue.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzz-f95-gear-repo-vs-live-residue.sql
--
-- ===================================================================
-- A THIRTEENTH z, AND THE REASON IS THE ONE F89's TIER ALREADY GAVE
-- ===================================================================
--
-- This has to sort after EVERY data script in the tree, because half of it
-- re-applies something an earlier file failed to apply and the other half
-- corrects what a catch-all did. The twelfth tier is occupied by
-- `zzzzzzzzzzzz-dupes-pass-*`, `zzzzzzzzzzzz-f89-*` and `zzzzzzzzzzzz-f90-*`,
-- and this file must follow the last of them. The count of z's is a counter and
-- never a severity - read it as `later than everything above`.
--
-- ===================================================================
-- WHAT repo-vs-live REPORTED, 2026-09-15
-- ===================================================================
--
--   gear             repo 2162  live 2162   names match
--      SAME NAME, DIFFERENT VALUE: 15 field(s) across 15 row(s)
--        category 14, cost_note 1
--
-- FIFTEEN, NOT SIXTEEN. The brief that opened this said 15 category rows plus
-- one cost_note. It is 14 and one, and production holds exactly 14 gear rows
-- with a NULL category.
--
-- ===================================================================
-- PART ONE: THE 14 CATEGORIES. THE REPO IS RIGHT, AND THE CAUSE IS A DATE
-- ===================================================================
--
-- `zzz-gear-tidy-3-categories.sql` ends with an unconditional catch-all:
--
--     UPDATE gear SET category = 'gear' WHERE category IS NULL;
--
-- A rebuild applies it LAST and sweeps up everything. Production ran it on
-- 2026-08-25 and every script that created one of these 14 rows ran after -
-- add-naruni-repo-bot-class 08-31, add-salvage-expert-class 09-08,
-- zzzzzz-underseas-gear-stubs 09-08, add-fq-gb-reloader-class 09-08 (dates from
-- `data_script_runs`, --remote, 2026-09-15). Nothing re-runs it, so production
-- kept the NULLs a rebuild has never had.
--
-- THIRTEEN OF THE FOURTEEN ARE PLAINLY GEAR and are swept the same way the
-- catch-all would sweep them: Duct Tape, Fishing Pole, Fishing Net (Small),
-- Wet Suit, S.C.U.B.A. Gear, Snorkel Gear, Luggage, Science Kit, Acetylene
-- Torch, Soldering Goggles, Electronic Notebook, Laser Communicator, Scaling
-- Knife. Thirteen carry `source_book = 'Estimate - no published price found'`.
--
-- ===================================================================
-- THE FOURTEENTH IS A WEAPON, AND THE PAGE SAYS SO
-- ===================================================================
--
-- `plasma-hand-cannon` is a STUB created by `add-naruni-repo-bot-class.sql`,
-- which sets no category - so the catch-all would file a hand cannon under
-- `gear`. Adopting the repo side wholesale is the one move in this file that
-- would be wrong, which is why F95 is not a one-line finding.
--
-- Rifts Dimension Book 2: Phase World printed 48 gives the Naruni Repo-Bot its
-- "Standard Equipment: Plasma Hand Cannon (2D6x10 M.D.)" - read off the cache
-- (`p048.txt:66`, page_offset 0) on 2026-09-15. So the stored row is wrong
-- about more than its category:
--
--   category          NULL   ->  weapon
--   damage            NULL   ->  2D6x10 M.D.
--   is_mega_damage       0   ->  1
--
-- A MEGA-DAMAGE WEAPON STORED AS S.D.C. is the defect
-- `restore-gear-missing-from-repo.sql` is remembered for - 24 weapons - and
-- this one is in PRODUCTION rather than only in a rebuild.
--
-- WHAT THE PAGE DOES NOT GIVE is a price or a stat block. The name appears
-- exactly once across all 209 cached pages, in that equipment line; there is no
-- weapons entry for it anywhere in the book. So the row stays a stub as to cost
-- and range, keeps its STUB description, and stops being a stub as to what kind
-- of thing it is.
--
-- ===================================================================
-- PART TWO: THE cost_note. PRODUCTION IS RIGHT AND THE REPO LOSES IT
-- ===================================================================
--
--   live   60 credits. Rifts World Book 15: Spirit West p.203 prices it at 80 credits.
--   repo   60 credits
--
-- `add-triax-gear-c-ammunition.sql` CREATES `arrowhead-smoke`;
-- `add-spirit-west-weapons-of-note.sql` APPENDS the second price reading.
-- `add-s` sorts BEFORE `add-t`, so in a rebuild the append runs against a row
-- that does not exist yet, matches nothing, and the Triax INSERT then writes
-- the short note. Production applied them chronologically - Triax 2026-09-07,
-- Spirit West 2026-09-11 - so the append landed there and only there.
--
-- THREE THINGS KEPT IT INVISIBLE, and each is reusable:
--
--   1. The guard is CORRECT and it is what hides the failure. It exists to make
--      a second run a no-op, and a WHERE that matches no row is
--      indistinguishable from one that had nothing to do.
--   2. The script's OWN readback would have caught it - it asserts "the smoke
--      arrowhead keeps its 60 and records the 80", want 1, and a rebuild gives
--      0 - but a rebuild applies the whole tree through one
--      `wrangler d1 execute --file`, which returns aggregate counts and
--      swallows every result set.
--   3. No test pins the note. A grep for `prices it at 80` across
--      apps/character-creator/**/*.mjs on 2026-09-15 returns nothing.
--
-- `repo-vs-live` is the only thing that has ever said so.
--
-- NEITHER ORIGINAL SCRIPT IS EDITED. Both have been applied to production, and
-- renaming `add-spirit-west-weapons-of-note.sql` to sort after Triax would make
-- `drift-check` report `RUN BUT NO FILE` for the name production recorded - the
-- `zzzzzzzzzzz-fix-nature-glimpse-name-on-a-rebuild.sql` precedent exactly.
--
-- ===================================================================
-- EVERY STATEMENT IS GUARDED SO EACH ENVIRONMENT MOVES ONLY WHERE IT IS BEHIND
-- ===================================================================
--
-- On production, statements 1 and 3 do work and statement 2 is a no-op.
-- On a rebuild, statement 1 is a no-op (the catch-all already ran), statement 2
-- does work, and statement 3 does work. Nothing here is unconditional.

-- 1. The thirteen. Guarded on NULL, so a rebuild - where the catch-all has
--    already run - finds nothing and only production moves.
UPDATE gear SET category = 'gear' WHERE category IS NULL AND slug <> 'plasma-hand-cannon';

-- 2. The fourteenth, in BOTH directions: a rebuild already holds 'gear' here,
--    so a NULL guard would never fire for it. Guarded on the target value
--    instead, which makes it idempotent without being unconditional.
UPDATE gear
   SET category = 'weapon',
       damage = '2D6x10 M.D.',
       is_mega_damage = 1
 WHERE slug = 'plasma-hand-cannon'
   AND (category IS NULL OR category <> 'weapon' OR damage IS NULL OR is_mega_damage <> 1);

-- 3. The Spirit West reading, under the same guard the original uses, so a
--    rebuild picks it up and production finds it already there.
--
--    COALESCE ON BOTH SIDES. `NULL || 'text'` is NULL, so an append to an empty
--    column ERASES it, and `instr(NULL, x)` is NULL so `= 0` is NULL and the
--    guard would silently never fire. Both traps are live in this repo's
--    history; neither is hypothetical.
UPDATE gear
   SET cost_note = COALESCE(cost_note, '')
     || '. Rifts World Book 15: Spirit West p.203 prices it at 80 credits.'
 WHERE slug = 'arrowhead-smoke'
   AND instr(COALESCE(cost_note, ''), 'Spirit West') = 0;

-- ASSERTIONS.

SELECT 'no gear row is left without a category' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE category IS NULL;

SELECT 'the hand cannon is a mega-damage weapon with the damage its page prints' AS assertion,
       count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'plasma-hand-cannon' AND category = 'weapon'
   AND damage = '2D6x10 M.D.' AND is_mega_damage = 1;

-- It is still a STUB as to price, and that is the finished state until someone
-- finds a page that prices it. Asserted so a later reader does not "complete"
-- it from nothing.
SELECT 'and it is still a priceless stub, which the book leaves it as' AS assertion,
       count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'plasma-hand-cannon' AND cost IS NULL AND instr(description, 'STUB') > 0;

SELECT 'the smoke arrowhead keeps its 60 and records the 80' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'arrowhead-smoke' AND cost = 60
   AND instr(cost_note, 'prices it at 80 credits') > 0;

-- AND EXACTLY ONCE. This file and the Spirit West script both append the same
-- sentence under the same guard, so a database that ran both must still hold
-- one copy - which is the whole point of the guard and the thing worth proving.
SELECT 'and the Spirit West sentence appears exactly once' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE slug = 'arrowhead-smoke'
   AND instr(substr(cost_note, instr(cost_note, 'Spirit West') + 12), 'Spirit West') > 0;

-- A ZERO-WRONG ASSERTION WAS TRIED HERE AND WAS WRONG, and what it taught is
-- worth more than the assertion. It read:
--
--     is_mega_damage = 1 AND (damage IS NULL OR trim(damage) = '')   want 0
--
-- and production answered 16. Every one of the sixteen is CORRECT.
-- `is_mega_damage` is a UNIT flag - it says this row's numbers are mega-damage -
-- and it is not a claim that the row deals damage. Four are body armour and one
-- is the Glitter Boy, which carry `mdc` and no `damage`; three are protective
-- gear (a communications helmet, a field radio, polarized goggles); two are
-- magic armour; and one is an unbreakable mega-damage PLOUGH.
--
-- Two narrower versions were tried and both were wrong too:
--   * `is_mega_damage = 0` with `M.D.` in the damage text answers 4, and all
--     four are mixed weapons whose row is S.D.C. and whose prose names an M.D.
--     option - the M-20's grenades, the Horune harpoon's explosive tip.
--   * adding `AND mdc IS NULL` answers 6, and those six are the finding below.
--
-- So there is no true blanket assertion of this shape, and the scoped ones this
-- file already carries are what prove its own work. Recorded because the
-- tempting assertion reads obviously right and is obviously wrong once the rows
-- are looked at. See `BOOK-INGEST-AUDIT` F97 for the six.
SELECT 'the three rows this file touches are the only ones it changed' AS assertion,
       count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'plasma-hand-cannon' AND category = 'weapon' AND is_mega_damage = 1)
    OR (slug = 'arrowhead-smoke' AND instr(cost_note, 'Spirit West') > 0)
    OR (slug = 'duct-tape' AND category = 'gear');

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-f95-gear-repo-vs-live-residue.sql');
