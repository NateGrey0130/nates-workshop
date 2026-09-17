-- The Gypsy Thief may buy Hand to Hand: Martial Arts.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzzz-hth-gypsy-thief-martial-arts.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzzz-hth-gypsy-thief-martial-arts.sql
--
-- zzzzzzzzzzzzzz-hand-to-hand-prices.sql stored this class AS PRINTED and said
-- so: Triax and the NGR printed 180 reads "Hand to hand: basic can be changed to
-- expert at the cost of one other skill. Hand to hand: expert (or assassin if
-- evil) can be taken for the cost of two other skill selections." Expert is
-- priced twice and Martial Arts not at all, so under the rule that a style
-- absent from the list is not offered, a Gypsy Thief could never buy it.
--
-- NATE'S CALL, 2026-09-17: read the second "expert" as the misprint it almost
-- certainly is. The book's other two Gypsy classes - the Gypsy Seer, printed
-- 182, and Gypsy - The Gifted, printed 184 - both put "martial arts (or
-- assassin if evil)" in that second position. AT THEIR OWN PRICES, two and
-- three, so only the STYLE is taken from them; the price of two is this
-- class's own printed figure. So: Expert 1, Martial Arts 2, Assassin 2 (evil).
--
-- THE NOTE KEEPS THE BOOK'S WORDS and says what was done with them, because it
-- is what the player reads and it would otherwise contradict the price beside
-- the row.
--
-- NAMED hth-, NOT hand-to-hand-prices-...: "-" sorts before ".", so the obvious
-- name would have run BEFORE the file it corrects and matched nothing on a
-- rebuild. Checked with the sorted glob. Both statements are guarded on the
-- text they replace, so a re-run is a no-op.

UPDATE imported_classes SET markdown = replace(markdown,
    'hand_to_hand: { costs: { expert: 1, assassin: 2 }, conditions: { assassin: "evil alignment" } }',
    'hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'hand_to_hand: { costs: { expert: 1, assassin: 2 }, conditions: { assassin: "evil alignment" } }') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'or Expert/Assassin (if evil) for the cost of two." }',
    'or Expert/Assassin (if evil) for the cost of two. The book prints Expert twice (Triax printed 180); the second is read as Martial Arts, the style the Gypsy Seer and Gypsy - The Gifted print in that position, so Martial Arts or Assassin (if evil) costs two." }'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'or Expert/Assassin (if evil) for the cost of two." }') > 0;

SELECT 'the Gypsy Thief sells Expert for one and Martial Arts or Assassin for two' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }') > 0;
SELECT 'and still carries exactly one block' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'gypsy-thief'
   AND instr(substr(markdown, instr(markdown, 'hand_to_hand:') + 13), char(10) || '  hand_to_hand:') > 0;
SELECT 'the note says how the misprint was read' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'the second is read as Martial Arts') > 0;
SELECT 'no other class was touched: the table still holds its 199' AS assertion, (count(*) >= 199) AS got, 1 AS want
  FROM imported_classes WHERE instr(markdown, char(10) || '  hand_to_hand: { costs: ') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzz-hth-gypsy-thief-martial-arts.sql');
