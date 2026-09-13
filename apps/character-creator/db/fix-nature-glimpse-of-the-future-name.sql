-- One Nature Magic spell was imported under its SUBTITLE instead of its name.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-nature-glimpse-of-the-future-name.sql
--
-- Printed 132 sets the spell like this:
--
--     Level Five
--     Glimpse of the Future          <- the name
--     A Wood & Water Divination      <- a subtitle
--     Range: On behalf of another person, family or a community.
--
-- The batch 1d reader finds a spell by walking BACK from `Range:` to the
-- nearest line that is not a field, and that line is the SUBTITLE. So the row
-- shipped as `Nature: A Wood & Water Divination`.
--
-- THE BOOK'S OWN SPELL INDEX, printed 6-7, is the authority and settles it:
-- `Glimpse of the Future (15) . . . 132`. The imported row already carries 15
-- P.P.E. and cites printed 132, so this is a NAME correction and nothing else -
-- the mechanics were right.
--
-- HOW IT WAS FOUND, which is the part worth keeping: the Gypsy Fortune Teller
-- grants this spell by name, and the name did not resolve. A class that cites a
-- spell is a check on the spell import, which is exactly why the survey orders
-- spells before classes.
--
-- The index also exposes four Nature spells this batch never had, and they need
-- NO rows: `Speed of the Snail`, `Summon Fog`, `Calm Storms` and `Summon Rain`
-- are one-line cross-references - "Identical to the spell found on page 186 of
-- Rifts" - with no stat block, which is why a reader keyed on `Range:` cannot
-- see them. Three already exist in this catalog at exactly the level and cost
-- the book states, and the fourth belongs to the Rifts RPG rather than to this
-- book. They are common invocations, so a Nature caster reaches them through an
-- ordinary level-gated pick already.

UPDATE spells
   SET name = 'Nature: Glimpse of the Future',
       description = 'Also titled "A Wood & Water Divination". ' || description
 WHERE name = 'Nature: A Wood & Water Divination';

-- Read the result back.
SELECT 'the spell carries its printed name' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Nature: Glimpse of the Future';

SELECT 'and the subtitle is no longer the name' AS assertion, count(*) AS got, 0 AS want
  FROM spells WHERE name = 'Nature: A Wood & Water Divination';

SELECT 'its mechanics are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Nature: Glimpse of the Future' AND ppe = 15 AND level = 5;

SELECT 'the Nature tradition still holds thirty rows' AS assertion, count(*) AS got, 30 AS want
  FROM spells WHERE tradition = 'nature';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-nature-glimpse-of-the-future-name.sql');
