-- A spell that burns P.P.E. out of the CASTER'S BASE, as a dice expression.
--
-- BOOK-INGEST-AUDIT F101 (3 of 3). Migration 065 gave a character somewhere to
-- record P.P.E. spent permanently (`characters.ppe_base_spent`), and 066 let a
-- Nightbane buy Talents with it. Seven catalog spells in three other books also
-- take P.P.E. out of the caster's base, and until now the number lived only in
-- their prose: Close Rift, Ley Line Resurrection, Ley Line Restoration and
-- Enchant Weapon (Minor) in the Book of Magic; Bone: Return from the Grave and
-- Nature: Sacred Oath in Mystic Russia; Summon & Use Stones & Crystals in
-- Wormwood.
--
-- NATE'S ANSWER (2026-09-16) SETS THE DEPTH: automate the P.P.E. NUMBER, and
-- leave the conditions, hit points, recurrence and any other target as prose.
-- So this is ONE dice expression - "2", "2D6", "6D6" - rolled when the player
-- says the spell's condition has been met, and nothing about WHEN:
--
--   Close Rift             every attempt, success or failure
--   Ley Line Resurrection  only when it succeeds; double for a creature of magic
--   Ley Line Restoration   double for a supernatural caster; the RECIPIENT also
--                          loses 4D6% of theirs, which is another character
--   Enchant Weapon (Minor) only if the enchantment is made permanent
--   Return from the Grave  each full moon, alongside two hit points
--   Sacred Oath            only when repenting a broken oath, with 2D6 H.P.
--
-- Every one of those conditions stays in the spell's description.
--
-- TEXT, not INTEGER, because five of the six are dice. Validated where it is
-- rolled, by js/dice.js - the same grammar that rolls pools and quantities.
--
-- NULL means the spell burns nothing, which is every spell but these.

ALTER TABLE spells ADD COLUMN ppe_permanent TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('067-spell-ppe-permanent.sql');
