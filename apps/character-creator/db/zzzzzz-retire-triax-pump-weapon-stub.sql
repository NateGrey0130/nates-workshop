-- Retire the Triax Pump Weapon stub, and give the eleven Warlocks the real guns.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-retire-triax-pump-weapon-stub.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-retire-triax-pump-weapon-stub.sql
--
-- THE LAST OUTSTANDING ITEM CARRYING THIS BOOK'S NAME. The triax survey's own
-- "What remains" section named it on 2026-09-06 and said it "should move in
-- this book's first data PR". It did not move, and two later paragraphs - the
-- gear-pass entry in that survey, and a claim made in conversation - then said
-- none of the remaining gear stubs belonged to this book. One did: this row is
-- cited to Rifts World Book 5 printed 143-144.
--
-- IT IS NOT A DUPLICATE MERGE, which is what most of the merge- scripts here
-- are. It is a GENERIC stub standing in for a choice between two real guns,
-- and the gear pass imported both of them properly without noticing the stub
-- was still being offered in its place:
--
--   tx-5-triax-pump-pistol   4D6 M.D., 800 ft, 5 rounds, 10,000 cr  (printed 143)
--   tx-16-pump-rifle         4D6 M.D., 30,000 cr                    (printed 144)
--
-- THE STUB NAME IS THE BOOK'S OWN WORDS AND NOT A TRANSCRIPTION SLIP. Rifts
-- Conversion Book One printed 72 gives the Warlock "a survival knife, automatic
-- pistol or Triax pump weapon" - generically, naming neither model. So the
-- eleven Warlock classes are given BOTH real rows in the same sidearm choice
-- rather than one being picked for them; the book offers a pump weapon, and now
-- the player chooses which.
--
-- The eleven are all one class family (warlock, the four single elements and
-- the six pairs) and every one of them carries the identical line - checked
-- --remote before this was written, 11 classes, 1 distinct line - so a single
-- structured replace covers them exactly.
--
-- THE REDIRECT TARGETS THE PISTOL, because the entry is a SIDEARM and offers
-- the pump weapon as the alternative to an automatic pistol. Nothing points at
-- the stub once the eleven are repointed, so the redirect is a safety net for
-- anything citing the old slug later rather than a live forwarding address.
--
-- No saved character holds it: character_items has zero rows for this slug,
-- checked --remote. The delete is guarded on that anyway.
--
-- Every statement resolves names rather than hard-coding ids - environments
-- assign different ones - and re-running does nothing.

-- 1. The eleven Warlocks get both real guns in place of the stub. An exact
-- structured match on the whole entry, not a blind name replace: class markdown
-- is frontmatter plus prose, and a loose replace would hit lore text too.
-- Guarded on the RESULT being absent as well as the old text being present,
-- because a guard on text the replacement keeps is not a guard.
UPDATE imported_classes
SET markdown = replace(markdown,
      '"c-18-laser-pistol", "triax-pump-weapon"]',
      '"c-18-laser-pistol", "tx-5-triax-pump-pistol", "tx-16-pump-rifle"]'),
    updated_at = datetime('now')
WHERE instr(markdown, '"c-18-laser-pistol", "triax-pump-weapon"]') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tx-5-triax-pump-pistol')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tx-16-pump-rifle');

-- 2. Any redirect already aimed at the row about to disappear moves onto the
-- keeper, so nothing is left dangling.
UPDATE catalog_redirects
SET to_id = (SELECT id FROM gear WHERE slug = 'tx-5-triax-pump-pistol')
WHERE catalog = 'gear'
  AND to_id = (SELECT id FROM gear WHERE slug = 'triax-pump-weapon')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tx-5-triax-pump-pistol');

-- 3. Forwarding address for the retired slug, so anything citing it resolves
-- instead of being stubbed back into existence by the next import.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'triax-pump-weapon',
       (SELECT id FROM gear WHERE slug = 'tx-5-triax-pump-pistol'), 'merge'
WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'tx-5-triax-pump-pistol')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- 4. The stub goes, once nothing points at it any more.
DELETE FROM gear
WHERE slug = 'triax-pump-weapon'
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tx-5-triax-pump-pistol')
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL
                    AND instr(c.markdown, 'triax-pump-weapon') > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- Read the result back rather than trusting the exit code.
SELECT 'the stub is gone' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'triax-pump-weapon';

SELECT 'no class still names it' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'triax-pump-weapon') > 0;

-- TEN LIVE, ELEVEN ROWS. The eleventh carrying this line is the RETIRED generic
-- `warlock`, which keeps status 'published' and is retired through `deleted_at`
-- - so a count that filters on deleted_at gets 10 and a count that does not
-- gets 11. Both are stated, because the first version of this readback wanted
-- 11 from a query that excluded the retired row and reported a correct result
-- as a failure.
SELECT 'all ten LIVE Warlocks now offer both real guns' AS assertion,
       count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND instr(markdown, '"tx-5-triax-pump-pistol", "tx-16-pump-rifle"]') > 0;

SELECT 'and the retired generic warlock was repointed too, not left behind' AS assertion,
       count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE instr(markdown, '"tx-5-triax-pump-pistol", "tx-16-pump-rifle"]') > 0;

SELECT 'both real guns are intact, with their damage' AS assertion,
       count(*) AS got, 2 AS want
  FROM gear
 WHERE slug IN ('tx-5-triax-pump-pistol', 'tx-16-pump-rifle')
   AND damage IS NOT NULL;

SELECT 'the retired slug still resolves through a redirect' AS assertion,
       count(*) AS got, 1 AS want
  FROM catalog_redirects
 WHERE catalog = 'gear' AND from_key = 'triax-pump-weapon';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-retire-triax-pump-weapon-stub.sql');
