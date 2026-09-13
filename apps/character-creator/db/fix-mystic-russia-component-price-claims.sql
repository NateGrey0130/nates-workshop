-- Two wrong claims in add-mystic-russia-necromancy-components.sql, corrected.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-mystic-russia-component-price-claims.sql
--
-- Both were caught by that script's OWN readback assertions on the --remote
-- apply, which is what those assertions are for. NEITHER is a wrong price: all
-- 41 rows carry the figures printed on page 107. Both are wrong SENTENCES
-- about the data, in cost_note.
--
-- 1. `brain-dragon` claims 750,000 is "the highest single price on the page".
--    It is not. `wings-dragon-adult` starts at 850,000 and runs to 1D6 million,
--    and its own note already says so. 750,000 is the highest price among the
--    seven BRAINS, which is what the sentence should have said.
--
-- 2. `horn-unicorn` names the Palladium Fantasy row as "Unicorn horn whole".
--    The row is "Unicorn horn, whole", WITH A COMMA.
--
--    That comma is worth the paragraph. The name was read out of production
--    before the script was written - and read through a display pipeline that
--    ended `sed 's/[",]//g'`, which strips commas. The reading was then
--    asserted against the same catalog it came from, so the error survived
--    every check but the one that ran against the real row. A readback that
--    names a row exactly is the only thing that catches a name mangled on the
--    way in. Related: the "self-check reruns your own error" shape - a
--    verification that reuses the method being verified confirms nothing.
--
-- THE ADD SCRIPT IS NOT EDITED, except for the two readback `want` constants it
-- got wrong, which write nothing and would otherwise print a false mismatch on
-- every future rebuild. Its INSERT is byte-identical to what production ran, so
-- a rebuild still produces the rows production holds, and this file is what
-- brings both of them to the corrected text. That is the standard shape here:
-- one-shot scripts are not rewritten, corrections sort after them.
--
-- `fix-mystic-russia-component-price-claims.sql` sorts after every `add-` file
-- and before the two existing `fix-mystic-russia-` scripts, neither of which
-- touches gear (checked 2026-09-13).

-- Guarded on the text being replaced, so a second run is a no-op.
UPDATE gear
   SET cost_note = replace(cost_note,
         'the printed figure is a floor, and the highest single price on the page.',
         'the printed figure is a floor, and the highest of the seven brains. It is NOT the highest price on the page - a Wings: Dragon Adult starts at 850,000.')
 WHERE slug = 'brain-dragon'
   AND instr(cost_note, 'the highest single price on the page') > 0;

UPDATE gear
   SET cost_note = replace(cost_note, '"Unicorn horn whole"', '"Unicorn horn, whole"')
 WHERE slug = 'horn-unicorn'
   AND instr(cost_note, '"Unicorn horn whole"') > 0;

-- Read the result back. The wants here are the corrected facts, each checked
-- against the real row rather than against the sentence that was wrong.
SELECT 'the dragon brain no longer claims the top price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'brain-dragon' AND instr(cost_note, 'the highest single price on the page') > 0;

SELECT 'and says what it really is' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'brain-dragon' AND instr(cost_note, 'the highest of the seven brains') > 0;

SELECT 'the dearest component on the page is the adult dragon wings' AS assertion, max(cost) AS got, 850000 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

SELECT 'the unicorn horn names the Palladium row with its comma' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'horn-unicorn' AND instr(cost_note, '"Unicorn horn, whole"') > 0;

-- The claim the add script got wrong, re-asserted against the real names.
SELECT 'the four Palladium Fantasy components are untouched' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE name IN ('Dragon claws', 'Dragon eye', 'Dragon tongue', 'Unicorn horn, whole')
   AND source_book = 'Palladium Fantasy RPG p.249-267';

-- Nothing above changed a price.
SELECT 'and no price moved' AS assertion, sum(cost) AS got, 6060000 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-mystic-russia-component-price-claims.sql');
