-- The duplicate-suggestion pass over the catalogs `zzzzzzzzzzzz-dupes-pass-
-- cross-system-gear.sql` did not reach.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql
--
-- ===================================================================
-- THERE ARE EIGHT CATALOGS, NOT FOUR
-- ===================================================================
--
-- The brief for this pass named three catalogs left to do - skills, psionics
-- and spells. `CATALOG_KEYS` in `apps/character-creator/js/catalog-fields.js`
-- holds EIGHT, read 2026-09-15, and `findDuplicates` serves every one of them:
-- skills, spells, psionics, superAbilities, enchantments, gear, vehicles,
-- totems. So seven had never been passed rather than three, and the two nobody
-- had named - `superAbilities` and `enchantments` - are the two carrying
-- suggestions in the CONFIDENT tiers.
--
-- Judged with the tool rather than around it, exactly as the gear pass was:
-- `findDuplicates` was imported and run against production over a D1 shim, so
-- the scoring, the tiering and the bucketing are the endpoint's own and not a
-- second implementation of them. `dismissed_by` is this FILENAME rather than a
-- person's address, because no person clicked.
--
-- ===================================================================
-- WHAT THE PASS FOUND, --remote, 2026-09-15
-- ===================================================================
--
--   catalog          suggestions   certain   likely   contains
--   skills                    68         0        0         68
--   spells                   730         0        3        727
--   psionics                  10         0        0         10
--   superAbilities           521         1        0        520
--   enchantments              10         5        1          4
--   vehicles                  29         0        0         29
--   totems                     0         0        0          0
--   ---------------------------------------------------------
--   gear                   1,575         0        0      1,575   <- done in #1060
--
-- TEN PAIRS ABOVE `contains`, AND ALL TEN ARE FALSE POSITIVES. Every one was
-- checked against the printed page rather than against the other row, and each
-- dismissal below carries the two page citations it was checked on.
--
-- THE `contains` TIER IS NOT TOUCHED, deliberately, and the gear pass's
-- reasoning is unchanged: the endpoint's own comment rates that tier at about
-- 40%, these 1,358 pairs have not been judged, and dismissing an unjudged pair
-- is worse than leaving it suggested - it removes the question without
-- answering it.
--
-- ===================================================================
-- SKILLS AND PSIONICS: NOTHING TO JUDGE, WHICH IS THE RESULT
-- ===================================================================
--
-- 68 and 10 suggestions, every one in `contains`. No row is written for either
-- catalog and that is not an omission: there was no confident suggestion to
-- answer. The psionics catalog's confident tier was emptied once already, by
-- the `category` demotion `INGESTION-AUDIT` F27 added after `Telekinesis` and
-- `Telekinesis (Super)` scored a perfect 1 - and it is empty again today.
--
-- ===================================================================
-- SPELLS: THREE PAIRS, AND ALL THREE ARE WORD ORDER
-- ===================================================================
--
-- `similarity` scores 0.95 when every token of the shorter name appears in the
-- longer one and the two are the same length - which is true of a pair whose
-- words are simply reversed, and true of `Fire Ball` against `Ballistic Fire`
-- because `tokenPairs` matches `ball` as a prefix of `ballistic`. The scorer is
-- not wrong; the names really are near-anagrams. The spells are not.
--
-- Each was read in the book's own text, not inferred from the stored row:
--
--   Fire Ball                  RUE printed 210: 90 feet, 1D4 M.D. per level,
--                              P.P.E. Ten. One ball, hurled.
--   Ballistic Fire             RUE printed 211: 1,000 feet, 1D6 M.D. PER FIERY
--                              MISSILE, P.P.E. Twenty-Five. One missile per
--                              level, fired at several targets at once, and the
--                              book calls it "an anti-infantry spell".
--
-- The Living Fire pair is the Mystic Russia tradition's versions of those same
-- two distinct spells (printed 115 and 116) and separates the same way - and
-- further, because the tradition re-prices them: 6 P.P.E. for Fire Sorcerers
-- against the core's 10.
--
--   Nature: Swords to Snakes   Mystic Russia printed 134: 60 feet, turns
--                              knives and swords INTO snakes, disarming a foe.
--   Nature: Snakes to Swords   Mystic Russia printed 135: touch, turns a snake
--                              into a weapon, damage varies with snake type,
--                              and its P.P.E. runs 25 to 140 by species.
--
-- Two spells that undo each other are the clearest case there is of two rows
-- that must both exist.
--
-- ===================================================================
-- ENCHANTMENTS: SIX PAIRS, AND THE DISTINGUISHING COLUMN IS `applies_to`
-- ===================================================================
--
-- This is the `Telekinesis (Super)` shape one column over, and it is the reason
-- this catalog carries FIVE of the six `certain` suggestions in the whole
-- database - all 62 of its rows are palladium-fantasy, counted --remote
-- 2026-09-15. `findDuplicates` demotes a pair whose `category` differs and a pair
-- whose `system` differs. The enchantments table has NO `category` column at
-- all - see its schema - and every row in it is palladium-fantasy, so neither
-- demotion can fire. What separates its rows is `applies_to`, which is `weapon`
-- | `armor` | `charm`, and nothing in the scorer reads it.
--
-- Palladium Fantasy prints three separate enchantment lists and repeats names
-- across them at different prices. Printed 249-250 carries the armour list and
-- the weapon list; printed 253 carries the charms:
--
--   Color                 armor 600      weapon 500
--   Continual Glow        armor 1,200    weapon 1,200
--   Impervious to Fire    armor 12,000   weapon 8,000    charm 30,000
--   Fire Resistant        armor 1,500
--   Resist Fire                                          charm 4,000
--
-- `Continual Glow` is the pair worth naming, because it is the one where the
-- numbers agree: 1,200 on both, so `same_numbers` is true and the suggestion
-- looks its most convincing. The book still prints it twice, once under
-- ENCHANTED ARMOR and once under ENCHANTED WEAPONS, and an armour glow is not
-- a weapon glow - a character may buy both.
--
-- `Fire Resistant` against `Resist Fire` is the same shape with different
-- names: printed 249-250 gives armour "Fire resistant: Normal fire does half
-- damage" at 1,500, and printed 253 gives a charm "Resist Fire: Two hours;
-- three times daily" at 4,000. A duration-limited charm and a permanent armour
-- property are not one row.
--
-- A FINDING RATHER THAN A FIX: the scorer should demote on `applies_to` the way
-- it demotes on `category`, which would empty this catalog's confident tier
-- without anybody judging it. That is a code change and this is a data script,
-- so it is filed as `BOOK-INGEST-AUDIT` F93 and NOT done here.
--
-- ===================================================================
-- SUPER ABILITIES: ONE PAIR, AND THE SECOND ROW SAYS IT IS AN ADDITION
-- ===================================================================
--
-- `Animal Abilities` (Revised Heroes Unlimited printed 174) against `Animal
-- Abilities (New Types)` (Powers Unlimited Three printed 49). The second row's
-- own description opens "These are a selection of new animal abilities TO ADD
-- TO the ones found on page 251 of the HU2 rule book" - so the book states the
-- relationship outright, and it is an extension rather than a reprint. Two
-- books, two printed entries, both major tier.
--
-- Scored a perfect 1 because `normaliseName` strips the bracketed qualifier,
-- the failure its own comment predicts.

-- -- SPELLS --

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('spells', 'Ballistic Fire', 'Fire Ball', 'Word order, not a duplicate. Fire Ball is 6th level, 90 feet, 1D4 M.D. per level, 10 P.P.E. (Rifts Ultimate Edition printed 210); Ballistic Fire is 7th level, 1,000 feet, 1D6 M.D. per fiery missile, 25 P.P.E., one missile per level fired at several targets at once (printed 211). They score 0.95 only because tokenPairs matches "ball" as a prefix of "ballistic".', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('spells', 'Living Fire: Ballistic Fire', 'Living Fire: Fire Ball', 'Word order, not a duplicate. The Living Fire tradition prints both of the two distinct spells above: Fire Ball at 5th level and 6 P.P.E. for Fire Sorcerers (Rifts World Book 18: Mystic Russia printed 115), Ballistic Fire at 7th level and 25 P.P.E. (printed 116). Same separation as the core pair, and the tradition re-prices them besides.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('spells', 'Nature: Snakes to Swords', 'Nature: Swords to Snakes', 'Two spells that undo each other. Swords to Snakes is 8th level, 60 feet, and turns knives and swords into snakes to disarm a foe (Rifts World Book 18: Mystic Russia printed 134); Snakes to Swords is 10th level, touch, turns a snake into a weapon, damage varies with snake type and P.P.E. runs 25 to 140 by species (printed 135).', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

-- -- ENCHANTMENTS --

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'armor-color', 'weapon-color', 'Different applies_to, which this catalog has no demotion for. Palladium Fantasy printed 249-250 prints Color twice - under ENCHANTED ARMOR at 600 gold and under ENCHANTED WEAPONS at 500 gold. See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'armor-continual-glow', 'weapon-continual-glow', 'Different applies_to, and the pair where the NUMBERS agree - 1,200 gold on both sides, so same_numbers is true and the suggestion looks its most convincing. Palladium Fantasy printed 249-250 still prints it twice, once under ENCHANTED ARMOR and once under ENCHANTED WEAPONS; a character may buy both. See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'armor-impervious-to-fire', 'weapon-impervious-to-fire', 'Different applies_to. Palladium Fantasy printed 249-250 prints Impervious to fire under ENCHANTED ARMOR at 12,000 gold and Impervious to Fire under ENCHANTED WEAPONS at 8,000 gold - the armour stops fire damage, the weapon simply cannot be melted. See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'armor-impervious-to-fire', 'charm-impervious-to-fire', 'Different applies_to. The armour property is permanent at 12,000 gold (Palladium Fantasy printed 249-250); the charm is "60 minutes; twice daily" at 30,000 gold (printed 253). A duration-limited charm and a permanent armour property are not one row. See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'charm-impervious-to-fire', 'weapon-impervious-to-fire', 'Different applies_to. The charm is "60 minutes; twice daily" at 30,000 gold (Palladium Fantasy printed 253); the weapon enchantment is permanent at 8,000 gold and means the blade cannot be melted (printed 249-250). See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('enchantments', 'armor-fire-resistant', 'charm-resist-fire', 'Different applies_to and different names. Palladium Fantasy printed 249-250 gives armour "Fire resistant: Normal fire does half damage (magic fire full damage)" at 1,500 gold; printed 253 gives a charm "Resist Fire: Two hours; three times daily" at 4,000 gold. See BOOK-INGEST-AUDIT F93.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

-- -- SUPER ABILITIES --

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('superAbilities', 'Animal Abilities', 'Animal Abilities (New Types)', 'An extension, and the book says so. Animal Abilities is Revised Heroes Unlimited printed 174; Animal Abilities (New Types) is Powers Unlimited Three printed 49, and its own description opens "These are a selection of new animal abilities to add to the ones found on page 251 of the HU2 rule book". Scored 1.00 only because normaliseName strips the bracketed qualifier.', 'zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');

-- ASSERTIONS.
--
-- Every count below is scoped to the catalogs THIS file writes. The gear pass's
-- own assertions are scoped to 'gear' and are untouched by these rows, and no
-- assertion here states a total across the table - a later pass over any of the
-- five catalogs still unjudged would falsify one that did.

SELECT 'ten pairs are judged across the three catalogs' AS assertion, count(*) AS got, 10 AS want
  FROM catalog_pair_dismissals
 WHERE catalog IN ('spells', 'enchantments', 'superAbilities');
SELECT 'three of them are spells' AS assertion, count(*) AS got, 3 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'spells';
SELECT 'six of them are enchantments' AS assertion, count(*) AS got, 6 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'enchantments';
SELECT 'one of them is a super ability' AS assertion, count(*) AS got, 1 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'superAbilities';

-- EVERY DISMISSAL CITES A PRINTED PAGE. A judgement with no page behind it is
-- the thing this pass exists to stop being repeated.
SELECT 'every dismissal names a printed page' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals
 WHERE catalog IN ('spells', 'enchantments', 'superAbilities')
   AND (note IS NULL OR instr(note, 'printed') = 0);

-- KEYS ARE CANONICAL: sorted, case-folded, and never a row paired with itself.
-- The UNIQUE constraint only de-duplicates if the sort happened on the way in.
SELECT 'every pair is stored in sorted order' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals
 WHERE catalog IN ('spells', 'enchantments', 'superAbilities')
   AND lower(key_a) >= lower(key_b);

-- AND EVERY KEY NAMES A LIVE ROW IN ITS OWN CATALOG, on that catalog's own
-- unique field: `name` for spells and super abilities, `slug` for enchantments.
-- A dismissal naming a row that does not exist silences a question about
-- nothing, and would survive a rebuild looking like an answer.
SELECT 'every dismissed spell key names a live spell' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals d
 WHERE d.catalog = 'spells'
   AND (NOT EXISTS (SELECT 1 FROM spells s WHERE s.name = d.key_a)
     OR NOT EXISTS (SELECT 1 FROM spells s WHERE s.name = d.key_b));
SELECT 'every dismissed enchantment key names a live enchantment' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals d
 WHERE d.catalog = 'enchantments'
   AND (NOT EXISTS (SELECT 1 FROM enchantments e WHERE e.slug = d.key_a)
     OR NOT EXISTS (SELECT 1 FROM enchantments e WHERE e.slug = d.key_b));
SELECT 'every dismissed super ability key names a live super ability' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals d
 WHERE d.catalog = 'superAbilities'
   AND (NOT EXISTS (SELECT 1 FROM super_abilities a WHERE a.name = d.key_a)
     OR NOT EXISTS (SELECT 1 FROM super_abilities a WHERE a.name = d.key_b));

-- THE PAIRS ARE REALLY DISTINCT, checked on the numbers the book prints rather
-- than on the fact that somebody dismissed them. Each of these would fail if a
-- later import quietly merged one side into the other.
SELECT 'the two fire spells still differ in level and cost' AS assertion, count(*) AS got, 1 AS want
  FROM spells a JOIN spells b ON a.name = 'Fire Ball' AND b.name = 'Ballistic Fire'
 WHERE a.level <> b.level AND a.ppe <> b.ppe;
SELECT 'and so do the Living Fire pair' AS assertion, count(*) AS got, 1 AS want
  FROM spells a JOIN spells b
    ON a.name = 'Living Fire: Fire Ball' AND b.name = 'Living Fire: Ballistic Fire'
 WHERE a.level <> b.level AND a.ppe <> b.ppe;
SELECT 'and the two snake spells' AS assertion, count(*) AS got, 1 AS want
  FROM spells a JOIN spells b
    ON a.name = 'Nature: Swords to Snakes' AND b.name = 'Nature: Snakes to Swords'
 WHERE a.level <> b.level;
SELECT 'every dismissed enchantment pair differs in applies_to' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals d
  JOIN enchantments a ON a.slug = d.key_a
  JOIN enchantments b ON b.slug = d.key_b
 WHERE d.catalog = 'enchantments' AND a.applies_to = b.applies_to;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzz-dupes-pass-remaining-catalogs.sql');
