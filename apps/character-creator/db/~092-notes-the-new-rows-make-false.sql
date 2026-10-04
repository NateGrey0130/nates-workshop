-- Four class notes that ~085 and ~091 make false, corrected in the same PR.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~092-notes-the-new-rows-make-false.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~092-notes-the-new-rows-make-false.sql
--
-- ~085-iron-juggernauts-and-cyborg-bodies.sql adds the four Dragon 'Borg bodies
-- as `borg` vessel rows. Three of the four classes say in their extraction
-- notes that no vehicles row holds the body. ~091-temporal-magic-and-circles.sql
-- adds the Summoner's 51 circles as spell rows in tradition `circle`; the
-- Summoner's note says there is no circle catalog.
--
-- A note about a limit that has been lifted tells the next reader not to try,
-- and nothing fails when it goes stale. Each sentence now names the row and
-- says what is still true: the classes are NOT rewired, so the body is still
-- described in the class and the Summoner still carries no magic block.
--
-- MUST SORT AFTER ~085 and ~091: it names their rows, and its guards check
-- they exist. THIS SCRIPT CHANGES PRODUCTION: four class rows. The tilde
-- number is claimed at merge.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The body has no vehicles row; the chassis is in special_abilities, side_effects and the body.',
         'The body is the vehicles row at-c8000-wing-blade-cyborg (since ~085); the class is not wired to it, and the chassis is still in special_abilities, side_effects and the body.'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-wing-blade'
   AND instr(markdown, 'The body has no vehicles row;') > 0
   AND (SELECT count(*) FROM vehicles WHERE slug = 'at-c8000-wing-blade-cyborg') = 1;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'no vehicles row exists for the dragon ''borgs, so the body''s locations, weapons, movement and features are special_abilities here.',
         'the dragon ''borg bodies are vehicles rows too since ~085 (this one is at-c9000-tsunami-cyborg), but the class is not wired to its row, so the body''s locations, weapons, movement and features are still special_abilities here.'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-tsunami'
   AND instr(markdown, 'no vehicles row exists for the dragon ''borgs') > 0
   AND (SELECT count(*) FROM vehicles WHERE slug = 'at-c9000-tsunami-cyborg') = 1;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'are the body ability (no vehicles row holds this body).',
         'are the body ability (the vehicles row at-c10000-imperial-dragon-cyborg holds this body since ~085; the class is not wired to it).'),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-borg-imperial-combat'
   AND instr(markdown, '(no vehicles row holds this body)') > 0
   AND (SELECT count(*) FROM vehicles WHERE slug = 'at-c10000-imperial-dragon-cyborg') = 1;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Circles are the whole of this class''s magic and there is no circle catalog, so the three families are recorded',
         'Circles are the whole of this class''s magic. The 51 circles are spell rows in tradition circle since ~091, but nothing grants that tradition yet, so the three families are still recorded'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'there is no circle catalog') > 0
   AND (SELECT count(*) FROM spells WHERE tradition = 'circle' AND system = 'palladium-fantasy') = 51;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'none of the four still denies the row' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('dragon-borg-wing-blade', 'dragon-borg-tsunami', 'dragon-borg-imperial-combat', 'summoner')
   AND instr(markdown, 'has no vehicles row') + instr(markdown, 'no vehicles row exists') + instr(markdown, 'no vehicles row holds') + instr(markdown, 'there is no circle catalog') > 0;

SELECT 'all four name the row instead' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'dragon-borg-wing-blade' AND instr(markdown, 'at-c8000-wing-blade-cyborg') > 0)
    OR (class_id = 'dragon-borg-tsunami' AND instr(markdown, 'at-c9000-tsunami-cyborg') > 0)
    OR (class_id = 'dragon-borg-imperial-combat' AND instr(markdown, 'at-c10000-imperial-dragon-cyborg') > 0)
    OR (class_id = 'summoner' AND instr(markdown, 'spell rows in tradition circle since ~091') > 0);

INSERT INTO data_script_runs (filename) VALUES ('~092-notes-the-new-rows-make-false.sql');
