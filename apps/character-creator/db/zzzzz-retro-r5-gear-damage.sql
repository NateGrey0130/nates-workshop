-- RETRO-AUDIT R5: thirteen gear rows stop keeping their damage in free text.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r5-gear-damage.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r5-gear-damage.sql
--
-- WHAT WAS WRONG. Thirteen rows print a damage figure in `description` and hold
-- `damage` NULL. `gear.damage` arrived with the 008 stat block on 2026-08-14
-- and IS read at runtime: functions/api/character-creator/characters/[id].js
-- joins gear.category, gear.damage and gear.payload for play mode's weapon
-- cards. So a character holding a hunting knife had a weapon card with no
-- damage on it, while the number sat two columns over in prose.
--
-- This is the gear.sdc shape (migration 034) in a different column, and it is
-- the one part of the gear stat block that reaches a player - `sdc`, `ar`,
-- `mdc`, `range` and `rate_of_fire` are in NO runtime projection, which is why
-- RETRO-AUDIT R5 is scoped to `damage` alone and R7 records the rest.
--
-- EIGHT OF THE THIRTEEN are cited by a published class's equipment_starting, so
-- a character rolled in one of those classes starts with the weapon. The other
-- five ride along because they cost nothing extra and the finding said they
-- could: knife-large, roman-candle and the three acid rows.
--
-- THE DESCRIPTION IS NOT TOUCHED. It is the row's provenance and the sentence a
-- reader sees in the catalog editor; stripping the figure out of it would trade
-- one gap for another. The value is COPIED, not moved.
--
-- NOT the "1D6 S.D.C." confusion catalog-fields.js warns about: its help text
-- on `sdc` says outright "Not the '1D6 S.D.C.' a knife deals, which is Damage."
-- Every row below is what the item DEALS, so `damage` is the right column and
-- `sdc` stays NULL.
--
-- is_mega_damage is left at its default 0: every one of these is S.D.C.

-- ---- weapons -------------------------------------------------------------
UPDATE gear SET damage = '1D4 S.D.C.' WHERE slug = 'bone-knife'       AND damage IS NULL;
UPDATE gear SET damage = '1D6 S.D.C.' WHERE slug = 'hand-axe-utility' AND damage IS NULL;
UPDATE gear SET damage = '1D6 S.D.C.' WHERE slug = 'hunting-knife'    AND damage IS NULL;
UPDATE gear SET damage = '1D6 S.D.C. thrown' WHERE slug = 'iron-javelin-rod' AND damage IS NULL;
UPDATE gear SET damage = '1D6 S.D.C.' WHERE slug = 'knife-large'      AND damage IS NULL;
UPDATE gear SET damage = '1D4 S.D.C.' WHERE slug = 'knife-small'      AND damage IS NULL;
UPDATE gear SET damage = '2D6 S.D.C.' WHERE slug = 'large-axe'        AND damage IS NULL;
UPDATE gear SET damage = '1D4 S.D.C.' WHERE slug = 'pocket-knife'     AND damage IS NULL;
UPDATE gear SET damage = '1D6 S.D.C.' WHERE slug = 'wooden-spear'     AND damage IS NULL;

-- ---- magic items that deal damage ----------------------------------------
-- Written AS PRINTED, the way the `damage` help text asks ("2D6 M.D. single
-- shot, 6D6 M.D. burst"): these are durations rather than single strikes, and
-- flattening them to a die would lose the rule.
UPDATE gear SET damage = '3D6 per melee round for three minutes'
  WHERE slug = 'acid-cleanser' AND damage IS NULL;
UPDATE gear SET damage = '3D6 per melee round for three minutes to metal; 2D4 per melee round for four melees to organic materials, leather and skin'
  WHERE slug = 'acid-metal-dissolver' AND damage IS NULL;
UPDATE gear SET damage = '2D6 per melee round for four melees'
  WHERE slug = 'acid-organic' AND damage IS NULL;
UPDATE gear SET damage = '2D6' WHERE slug = 'roman-candle' AND damage IS NULL;

-- ---- readbacks -----------------------------------------------------------
SELECT 'all thirteen now carry a damage value' AS assertion,
       count(*) AS got, 13 AS want
  FROM gear
 WHERE slug IN ('bone-knife', 'hand-axe-utility', 'hunting-knife',
                'iron-javelin-rod', 'knife-large', 'knife-small', 'large-axe',
                'pocket-knife', 'wooden-spear', 'acid-cleanser',
                'acid-metal-dissolver', 'acid-organic', 'roman-candle')
   AND damage IS NOT NULL;

-- No row printing a damage figure in prose is left without the column set.
-- This is the detector RETRO-AUDIT R5 was found by, re-run as an assertion.
SELECT 'no gear row still keeps its damage only in prose' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear
 WHERE damage IS NULL AND description GLOB '*Does [0-9]D[0-9]*';

-- Nothing gained an S.D.C. value: what these rows DEAL is damage, and `sdc` is
-- what an object TAKES. Conflating them is the mistake catalog-fields.js warns
-- about by name.
SELECT 'none of the thirteen gained an sdc value' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear
 WHERE slug IN ('bone-knife', 'hand-axe-utility', 'hunting-knife',
                'iron-javelin-rod', 'knife-large', 'knife-small', 'large-axe',
                'pocket-knife', 'wooden-spear', 'acid-cleanser',
                'acid-metal-dissolver', 'acid-organic', 'roman-candle')
   AND sdc IS NOT NULL;

-- The descriptions still carry the figure. The value was copied, not moved.
SELECT 'the descriptions are untouched' AS assertion,
       count(*) AS got, 13 AS want
  FROM gear
 WHERE slug IN ('bone-knife', 'hand-axe-utility', 'hunting-knife',
                'iron-javelin-rod', 'knife-large', 'knife-small', 'large-axe',
                'pocket-knife', 'wooden-spear', 'acid-cleanser',
                'acid-metal-dissolver', 'acid-organic', 'roman-candle')
   AND description GLOB '*Does [0-9]D[0-9]*';

-- Records this run. Every statement guards itself on `damage IS NULL`, so this
-- script is safe to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r5-gear-damage.sql');
