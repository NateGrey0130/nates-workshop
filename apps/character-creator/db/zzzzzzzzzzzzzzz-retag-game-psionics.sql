-- Put back the game tags two untag scripts strip from 29 psionic powers on
-- every clean rebuild. IN PRODUCTION THIS IS A NO-OP, by construction.
--
-- untag-cross-system.sql and zzzz-untag-escaped-psionics.sql both end in
--
--   UPDATE psionic_powers SET system = NULL WHERE system IS NOT NULL;
--
-- which was right on the day each ran: Rifts and Palladium Fantasy share a
-- multiverse, and a psychic is a psychic in either. Neither statement names a
-- row, so on a REBUILD - one sorted glob, filename order as execution order -
-- they also clear every tag an `add-*` script set before them, including tags
-- that were set on purpose AFTER the untag decision:
--
--   13  heroes-unlimited  add-pu1-psionic-powers.sql, add-hu-core-psionics.sql
--                         ("these are powers of a specific game, and NULL means
--                         unrestricted in this catalog" - BOOK-INGEST-AUDIT F73)
--    1  nightbane         add-nb-0-psionic-super-hypnotic-suggestion.sql
--                         (zzzzzzzzzzzzz-nb-psionics.sql sorts after the untags,
--                         so its three rows keep theirs)
--   15  rifts             add-phase-world-phase-powers.sql, which writes the
--                         tag as a column literal on all fifteen
--
-- Production ran these files in the order they were written, so it carries all
-- 32 tags and a rebuild carries 3. Found 2026-09-18 by `repo-vs-live.mjs
-- --table psionic_powers --offenders`: 29 `system` fields, repo NULL, live set.
-- The fixes-that-sort-early shape again (fix-long-bowman-armor.sql,
-- zzzzzzzzzzz-fix-nature-glimpse-name-on-a-rebuild.sql), pointing the other way:
-- here the EARLY file is the one that is right.
--
-- THE PHASE POWERS KEEP `rifts`, which is what production holds. Only a class
-- naming the Phase category reaches them (psiConfig fails closed, per the add
-- script's header), every such class is a Rifts class, so the tag changes
-- nothing for Palladium Fantasy - it keeps the fifteen out of the Heroes
-- Unlimited and Nightbane pickers, which is the point of a game tag.
--
-- KEYED ON THE BOOK, not on a name list: in production EVERY row citing these
-- books carries exactly this tag (32 of 32, read --remote 2026-09-18), so the
-- rule and the list are the same set today, and the rule also covers a row a
-- later import adds from the same book. Guarded on `system IS NULL`, so a row
-- somebody has deliberately re-tagged since is left alone.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzz-retag-game-psionics.sql

UPDATE psionic_powers SET system = 'heroes-unlimited'
 WHERE system IS NULL
   AND (source_book LIKE 'Powers Unlimited %' OR source_book LIKE 'Revised Heroes Unlimited%');

UPDATE psionic_powers SET system = 'nightbane'
 WHERE system IS NULL AND source_book LIKE 'Nightbane RPG%';

UPDATE psionic_powers SET system = 'rifts'
 WHERE system IS NULL AND source_book LIKE 'Rifts Dimension Book 2: Phase World%';

-- ASSERTIONS.

SELECT 'every Heroes Unlimited psionic power carries its game' AS assertion, count(*) AS got, 13 AS want
  FROM psionic_powers
 WHERE system = 'heroes-unlimited'
   AND (source_book LIKE 'Powers Unlimited %' OR source_book LIKE 'Revised Heroes Unlimited%');

SELECT 'every Nightbane psionic power carries its game' AS assertion, count(*) AS got, 4 AS want
  FROM psionic_powers WHERE system = 'nightbane' AND source_book LIKE 'Nightbane RPG%';

SELECT 'every Phase power is tagged rifts' AS assertion, count(*) AS got, 15 AS want
  FROM psionic_powers WHERE system = 'rifts' AND category = 'Phase';

SELECT 'and no row from those books is left untagged' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE system IS NULL
   AND (source_book LIKE 'Powers Unlimited %' OR source_book LIKE 'Revised Heroes Unlimited%'
     OR source_book LIKE 'Nightbane RPG%' OR source_book LIKE 'Rifts Dimension Book 2: Phase World%');

-- The untag decision still holds for everything else: the Rifts and Palladium
-- psionics chapters stay open to every system.
SELECT 'nothing else is tagged' AS assertion, count(*) AS got, 32 AS want
  FROM psionic_powers WHERE system IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzz-retag-game-psionics.sql');
