-- The two catalog rows the Thief and the Assassin need, and two more mundane
-- rows a Palladium character could not see.
--
-- One-off data script, run once per environment. NOT a migration - it adds and
-- changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-pf-rogue-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-pf-rogue-gear.sql
--
-- Prerequisite for add-thief-class.sql and add-assassin-class.sql. Every
-- statement guards itself, so this is safe to run twice and safe to run before
-- or after the class scripts.

-- ---- 1. Soft leather, off the printed table -------------------------------
-- Printed p270, the same five-column armour table that priced studded leather:
--
--   Soft Leather (full)  75 gold  A.R. 10  20 S.D.C.  8 lbs
--
-- The Thief starts in it. Not to be confused with the existing `leather-armor`
-- row, which is the unstatted generic the Long Bowman cites and which is left
-- alone here - the book distinguishes soft leather from hard leather (A.R. 11,
-- 30 S.D.C., 150 gold), and there is no way to tell which one an unstatted
-- "Leather Armor" was meant to be.
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, ar, weight_lbs, description, source_book)
VALUES ('soft-leather', 'Soft Leather', 'palladium-fantasy', 'armor', 75, 10, 8,
        'Full suit of soft leather. A.R. 10, 20 S.D.C. A half suit has A.R. 6 and 10 S.D.C. Soft leather, hard leather and padded armour carry no prowl or climb penalty.',
        'palladium-fantasy-core');

-- ---- 2. Lock picking tools, which the book names and never prices ---------
-- Both the Thief and the Assassin start with "a set of lock picking tools" -
-- the Thief with skeleton keys as well - and the equipment chapter prices
-- nothing of the sort. Neither does any other Palladium Fantasy list.
--
-- So `cost` stays NULL and `cost_note` says why, rather than the row arriving
-- as "STUB - created by class import, needs stats" the way class-check offers.
-- The difference matters: a stub is a row nobody has looked at, and this is a
-- row somebody looked at and found the book silent. NULL cost is already how
-- `leather-armor` sits, so nothing downstream is surprised by it.
--
-- source_book is left NULL for the same reason. Naming a page would claim the
-- numbers came from one.
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, description)
VALUES ('lock-picking-tools', 'Lock Picking Tools', 'palladium-fantasy', 'gear', NULL,
        'The main book prices no set; buy at the GM rate.',
        'A set of picks and tension tools, and for a thief a ring of skeleton keys with them. Required to use the Pick Locks skill on anything beyond the crudest latch.');

-- ---- 3. Two more mundane rows tagged rifts-only ---------------------------
-- Same reasoning as fix-pf-armor-and-cross-system-gear.sql, and the same
-- trigger: a Palladium class grants the row outright, which is a concrete claim
-- that both worlds have the thing. A grappling hook and a small hammer are not
-- technology.
--
-- Only `grappling-hook` moves. `grappling-hook-and-line-100-feet-30-m` is a
-- Rifts kit with 100 feet of line at a Rifts price, and no class here grants
-- it.
UPDATE gear SET system = 'both'
 WHERE system = 'rifts' AND slug IN ('grappling-hook', 'small-hammer');

-- ---- read the result back rather than trusting the exit code --------------
SELECT slug, name, system, category, cost, ar, weight_lbs FROM gear
 WHERE slug IN ('soft-leather', 'lock-picking-tools', 'grappling-hook', 'small-hammer')
 ORDER BY slug;
-- Expect 0: neither new row arrived as a stub.
SELECT count(*) AS new_stubs FROM gear
 WHERE slug IN ('soft-leather', 'lock-picking-tools') AND description LIKE 'STUB%';
-- Expect 2.
SELECT count(*) AS now_cross_system FROM gear
 WHERE system = 'both' AND slug IN ('grappling-hook', 'small-hammer');

INSERT INTO data_script_runs (filename) VALUES ('add-pf-rogue-gear.sql');
