-- Palladium Fantasy armour, priced off the printed table, plus the mundane
-- rows a medieval character cannot currently see.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-pf-armor-and-cross-system-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-pf-armor-and-cross-system-gear.sql
--
-- Prerequisite for the Soldier, Squire, Palladin and Ranger, and a correction
-- to what the Knight left behind. Every statement guards itself, so this is
-- safe to run twice and safe to run before or after the four class scripts.
--
-- Everything here comes off ONE page: the armour table printed on p270, read
-- with scripts/read-columns.py. It is a five-column table - type, cost, A.R.,
-- S.D.C., weight - and the columns are stored as five separate blocks, which is
-- why it has to be read geometrically to line up at all.
--
--   Studded Leather (full)  200 gold   A.R. 13   38 S.D.C.   20 lbs
--   Chain Mail (full)       280 gold   A.R. 14   44 S.D.C.   40 lbs
--   Scale (full)            650 gold   A.R. 15   75 S.D.C.   45 lbs
--
-- FOUR THINGS, IN ORDER OF HOW MUCH THEY MATTER.

-- ---- 1. Studded leather did not exist ---------------------------------------
-- The Soldier's armour choice is chain mail OR studded leather and the Ranger
-- starts in it, so without this row both classes would have imported a stub -
-- "STUB, created by class import, needs stats" - for a suit the book prices,
-- rates and weighs on the same line as the chain mail already in the catalog.
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, ar, weight_lbs, description, source_book)
VALUES ('studded-leather', 'Studded Leather', 'palladium-fantasy', 'armor', 200, 13, 20,
        'Full suit of studded leather. A.R. 13, 38 S.D.C. A half suit has A.R. 9 and 20 S.D.C. Studded leather costs -5% to prowl, swim or climb.',
        'palladium-fantasy-core');

-- ---- 2. Chain mail and scale mail were priced from nowhere ------------------
-- add-knight-class.sql created both rows with the A.R. and S.D.C. the Knight's
-- own entry states - those are right - and with costs of 400 and 500, which the
-- book does not print anywhere. The armour table says 280 and 650. Scale mail
-- is the more expensive of the two, not the cheaper, so the error also inverted
-- the choice a player is making.
--
-- Guarded on the wrong value rather than the slug, so this cannot overwrite a
-- price someone has since corrected by hand.
UPDATE gear SET cost = 280, weight_lbs = COALESCE(weight_lbs, 40)
 WHERE slug = 'chain-mail' AND cost = 400;
UPDATE gear SET cost = 650, weight_lbs = COALESCE(weight_lbs, 45)
 WHERE slug = 'scale-mail' AND cost = 500;

-- The same three rows were filed under category 'Armor'. Nineteen armour rows
-- use 'armor' and the catalog editor offers only the lower-case vocabulary
-- (js/catalog-fields.js), so the capitalised ones are unreachable from the
-- edit UI and sort as a separate group.
UPDATE gear SET category = 'armor' WHERE category = 'Armor';

-- ---- 3. Two skills tagged to one system -------------------------------------
-- untag-cross-system.sql set every skills.systems to NULL on purpose: Rifts and
-- Palladium Fantasy share a multiverse and a skill is not bound to the book it
-- was printed in. add-knight-class.sql then inserted Horsemanship: Knight and
-- W.P. Lance tagged '["palladium-fantasy"]', which made them the only two
-- tagged rows in a catalog of 324 - the exact inconsistency that script exists
-- to remove. Practically it is what stops a Rifts Cyber-Knight taking W.P.
-- Lance, which the pickers would otherwise allow.
--
-- Horsemanship: Palladin is inserted untagged by add-palladin-class.sql, so
-- this leaves the whole family consistent.
UPDATE skills SET systems = NULL WHERE systems IS NOT NULL;

-- ---- 4. Seven mundane rows a Palladium character cannot see -----------------
-- Gear stays system-tagged on purpose - a laser rifle arriving in a medieval
-- realm is an event in play. These seven are not that. They are clothing,
-- gloves, a uniform, field rations, a riding horse, a hatchet and a skinning
-- knife: things a Palladium character plainly owns, which exist in the catalog
-- only because a Rifts book was imported first.
--
-- It is already a live bug, not a hypothetical. The sheet loads its catalog as
-- `items?system=palladium-fantasy`, which returns NULL, the campaign's system,
-- or 'both'. add-knight-class.sql grants clothing, gloves and a riding horse,
-- so a Knight's sheet holds three items whose names it cannot resolve. The four
-- classes in this batch add the uniform, rations, hand axe and skinning knife
-- to that list.
--
-- 'both' rather than NULL because the row IS classified - it belongs to both -
-- where NULL means nobody said. The distinction is the README's, and ten rows
-- already sit at 'both' for the same reason.
--
-- CAVEAT, recorded rather than fixed: gear.cost is credits in Rifts and gold in
-- Palladium Fantasy, and a 'both' row has one cost column. The hand axe at 40
-- and the skinning knife at 80 are Rifts credit prices; the main book prices
-- neither, so there is no gold figure to prefer. The ten existing 'both' rows
-- have the same wrinkle.
UPDATE gear SET system = 'both'
 WHERE system = 'rifts'
   AND slug IN ('clothing', 'gloves', 'uniform', 'food-rations', 'riding-horse',
                'hand-axe', 'knife-skinning');

-- ---- read the result back rather than trusting the exit code ----------------
SELECT slug, name, system, category, cost, ar, weight_lbs FROM gear
 WHERE slug IN ('studded-leather', 'chain-mail', 'scale-mail') ORDER BY slug;
-- Expect 0: no armour row left under the capitalised category.
SELECT count(*) AS capitalised_armor FROM gear WHERE category = 'Armor';
-- Expect 0: no skill tagged to a single system.
SELECT count(*) AS tagged_skills FROM skills WHERE systems IS NOT NULL;
-- Expect 7.
SELECT count(*) AS cross_system_mundane FROM gear
 WHERE system = 'both'
   AND slug IN ('clothing', 'gloves', 'uniform', 'food-rations', 'riding-horse',
                'hand-axe', 'knife-skinning');
-- Expect 0: nothing the four new classes grant outright is still invisible to a
-- Palladium campaign.
SELECT count(*) AS still_rifts_only FROM gear
 WHERE system = 'rifts'
   AND slug IN ('clothing', 'gloves', 'uniform', 'food-rations', 'riding-horse',
                'hand-axe', 'knife-skinning', 'studded-leather');

INSERT INTO data_script_runs (filename) VALUES ('fix-pf-armor-and-cross-system-gear.sql');
