-- The six Ocean spells that are a Water Warlock invocation retold.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Migration 049 adds the column this writes.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-underseas-same-spell-links.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-underseas-same-spell-links.sql
--
-- BOOK-INGEST-AUDIT.md F26, taken as its smaller option. The reasoning for the
-- column and for the direction of the link is in migration 049; this file is
-- about WHICH pairs get one, which is where the finding turned out to be wrong.
--
-- F26 LISTED NINE PAIRS AND SAID THEY WERE THE SAME SPELL. Ten rows actually
-- share a name across the prefixes, and reading all ten - rather than the one
-- the finding sampled - splits them in half:
--
--   THE SIX BELOW agree on every number in range, duration, saving throw and
--   area of effect, once metric conversions and parenthetical glosses are set
--   aside. They are one spell published twice - at two prices for four of the
--   six, and at the SAME price for the other two, which the finding's title
--   does not allow for and its own table shows.
--
--   FOUR DO NOT, and are deliberately NOT linked:
--     Ocean: Calm Waters      one mile radius per level, one hour per level
--     Water: Calm Waters      80 foot radius per level, 30 minutes per level
--     Ocean: Ride the Waves   self and two others, up to 40 mph
--     Water: Ride the Waves   self
--     Ocean: Float on Water   two others, cast up to 30 feet, 30 minutes/level
--     Water: Float on Water   others, cast up to 90 feet, 20 minutes/level
--     Ocean: Water Seal       touch or three feet, tripled for a sea druid
--     Water: Water Seal       touch or six feet
--   A mile against eighty feet is not a transcription difference. These are
--   different spells that share a name, they keep the `variant_note` they were
--   imported with, and linking them would have made the checker assert
--   something false on its first run.
--
-- THE FINDING WAS WRONG ABOUT SONIC BLAST TOO, and that one would have created
-- a bad link rather than a failing check. F26 says Sonic Blast is "a bare Book
-- of Magic row at level 7 for 25 P.P.E. and a dolphin spell for 15". The
-- catalog holds THREE rows: `Sonic Blast` (Book of Magic p.119, 20 foot radius,
-- 4D6 M.D.), `Air: Sonic Blast` (Book of Magic p.63, the same radius and the
-- same damage), and `Dolphin: Sonic Blast` (Underseas p.71), which does 1D6
-- M.D. per level at 100 feet per level and passes a third of its damage through
-- light armour to the pilot. The dolphin spell is not a retelling of either; it
-- is a different spell wearing the same name, and it gets no link.
--
-- ONE PAIR ONLY MATCHES BECAUSE THE NAMES WERE READ RATHER THAN MATCHED.
-- `Ocean: Communicate with Sea Creature` retells
-- `Water: Communicate with Sea CreatureS` - singular against plural. A query
-- joining on the name after the prefix misses it, which is how the finding came
-- to list it while a name-match sweep did not.
--
-- Guarded on BOTH rows existing and on the link not already being set, so this
-- is safe to re-run and cannot overwrite a link somebody set by hand. Pure
-- ASCII, LF endings.


UPDATE spells
   SET same_spell_as = 'Water: Change Current'
 WHERE name = 'Ocean: Change Current'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Change Current');

UPDATE spells
   SET same_spell_as = 'Water: Communicate with Sea Creatures'
 WHERE name = 'Ocean: Communicate with Sea Creature'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Communicate with Sea Creatures');

UPDATE spells
   SET same_spell_as = 'Water: Impervious to Ocean Depths'
 WHERE name = 'Ocean: Impervious to Ocean Depths'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Impervious to Ocean Depths');

UPDATE spells
   SET same_spell_as = 'Water: Sense Direction Underwater'
 WHERE name = 'Ocean: Sense Direction Underwater'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Sense Direction Underwater');

UPDATE spells
   SET same_spell_as = 'Water: Speak Underwater'
 WHERE name = 'Ocean: Speak Underwater'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Speak Underwater');

UPDATE spells
   SET same_spell_as = 'Water: Whirlpool'
 WHERE name = 'Ocean: Whirlpool'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Water: Whirlpool');

-- Read the result back rather than trusting the exit code. A guarded UPDATE
-- that matched nothing is a SILENT no-op, which is exactly how this fails.
-- One statement each: D1 rejects a compound SELECT past five terms.
SELECT 'the six retellings are linked' AS assertion,
       count(*) AS got, 6 AS want
  FROM spells WHERE name IN ('Ocean: Change Current', 'Ocean: Communicate with Sea Creature', 'Ocean: Impervious to Ocean Depths', 'Ocean: Sense Direction Underwater', 'Ocean: Speak Underwater', 'Ocean: Whirlpool') AND same_spell_as IS NOT NULL;

SELECT 'and nothing else in the catalog is' AS assertion,
       count(*) AS got, 6 AS want
  FROM spells WHERE same_spell_as IS NOT NULL;

SELECT 'every link resolves to a row that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells s
 WHERE s.same_spell_as IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM spells t WHERE t.name = s.same_spell_as);

SELECT 'no row is its own retelling' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE same_spell_as = name;

SELECT 'no link points at another retelling' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells s
  JOIN spells t ON t.name = s.same_spell_as
 WHERE s.same_spell_as IS NOT NULL AND t.same_spell_as IS NOT NULL;

-- REPORTED, NOT ASSERTED, and the difference matters. F26 is titled "one
-- spell, two traditions, TWO COSTS" and this started life as an assertion that
-- all six differ on price. Two of them do not: Sense Direction Underwater is
-- level 1 for 4 P.P.E. in both books and Speak Underwater is level 4 for 10 in
-- both. The finding's own table shows those two matching, and its title
-- generalises from the other four. A link asserts THE SAME SPELL; a price
-- difference is the common case and not the requirement.
SELECT 'linked pairs that differ on level or cost (4 of 6, and that is correct)' AS assertion,
       count(*) AS got, 4 AS want
  FROM spells s
  JOIN spells t ON t.name = s.same_spell_as
 WHERE s.same_spell_as IS NOT NULL
   AND (s.level <> t.level OR s.ppe <> t.ppe);

-- The four that share a name and are NOT the same spell stay unlinked.
SELECT 'the four divergent pairs are left alone' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells
 WHERE name IN ('Ocean: Calm Waters', 'Ocean: Ride the Waves',
                'Ocean: Float on Water', 'Ocean: Water Seal',
                'Dolphin: Sonic Blast')
   AND same_spell_as IS NOT NULL;

SELECT s.name AS retelling, s.level AS lvl, s.ppe AS ppe,
       t.name AS established, t.level AS t_lvl, t.ppe AS t_ppe
  FROM spells s JOIN spells t ON t.name = s.same_spell_as
 WHERE s.same_spell_as IS NOT NULL ORDER BY s.name;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-same-spell-links.sql');

