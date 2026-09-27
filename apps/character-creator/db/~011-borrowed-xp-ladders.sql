-- Experience ladders a class's book BORROWS from another class ("use the
-- dragon experience table"), copied from the class that stores that ladder.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~011-borrowed-xp-ladders.sql
--
-- THE DECISIONS. An R.C.C. may carry the ladder its book prints for it (Nate,
-- 2026-09-17, docs/surveys/nightbane-core.md), and an O.C.C.'s ladder wins a
-- pairing. And a class whose book says "use X's experience table" copies X's
-- ladder (Nate, 2026-09-26): Atlantis's practice, which replaces the own-book-only
-- rule the Coalition War Campaign import followed. ~010-own-book-xp-ladders.sql
-- and ~011-borrowed-xp-ladders.sql are one change in two files, split only so
-- each file's read-backs stay short: d1-apply re-runs them as ONE command line,
-- and Windows refused the single file's 5,900 characters of SELECTs.
--
-- BORROWED (10 classes), copied from the row that stores the named ladder today:
--   dragon-hatchling (RUE printed 295, Dragon Hatchling & Adult Dragon):
--     demon-dragonmage  Psyscape printed 123 "Use the dragon experience table",
--                       and printed 157 "the same experience table as the Dragon R.C.C."
--     zaayr-crystal-dragon  Psyscape printed 157, the same sentence
--     norse-giant       Pantheons printed 163 "Use same table as the Dragon R.C.C."
--     man-wolf          Mystic Russia printed 71 "the same experience table as the Dragon Hatchling"
--     gargoyle-lord     Triax printed 199 "the same experience table as the dragon"
--     gargoyle-mage     Triax printed 201, the same sentence
--   psi-stalker (RUE printed 295, Burster, Psi-Stalker & Mystic):
--     gargoyle, gurgoyle  Triax printed 198, one "Gargoyle and Gurgoyle R.C.C." entry
--   combat-cyborg (RUE printed 295, Combat Cyborg, Headhunter & Robot Pilot -
--   the 'Borg ladder, the same one splugorth-conservator and hawrk-ka carry):
--     kremin-cyborg     CWC printed 210 "Use the 'Borg experience table"
--   dog-boy (RUE printed 295, CS Grunt & Dog Boys):
--     gargoylite        Triax printed 202 "the same experience table as the Dog Pack";
--                       the Dog Pack is the Dog Boy, settled in #782
--   The values are literals rather than a sub-select, so a rebuild does not
--   depend on the source row's file sorting first; the read-back below holds
--   each copy equal to its source row.
--   Domovoi's note is corrected too: it leaned on the Man-Wolf's pointer.
--
-- NOT stored, and why: sea-titan (Underseas, "the young and ancient
-- dragon" - two tables); maxi-man (Atlantis, names none); nmbyr-gorilla-man and
-- tirrvol-sword-fist (CWC printed 224's "D-Bee Vagabond" column names neither
-- race, their entries name no table, and both always take an O.C.C.).
--
-- MECHANICS. One xp_table line straight after each class's single "category:"
-- line, guarded on no xp_table LINE yet, so a second run changes nothing.
-- Every note that said the ladder is not stored is rewritten as a past-tense
-- decision in the same run, each replace guarded on the text it replaces.
-- The ~ tier sorts after every z- tier, so nothing rewrites these rows later.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'demon-dragonmage'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'zaayr-crystal-dragon'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'man-wolf'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gargoyle-lord'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gargoyle-mage'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gargoyle'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gurgoyle'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'kremin-cyborg'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gargoylite'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- The notes.

UPDATE imported_classes
   SET markdown = replace(markdown, 'Nothing is stored either way: a Rifts class carries no `xp_table` here, so', 'The import stored nothing because a Rifts class then carried no xp_table, so'), updated_at = datetime('now')
 WHERE class_id IN ('gargoylite') AND instr(markdown, 'Nothing is stored either way: a Rifts class carries no `xp_table` here, so') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'can be.', 'can be. Since 2026-09-26 xp_table carries dog-boy''s ladder (RUE printed 295), copied; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('gargoylite') AND instr(markdown, 'can be.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'xp_table: NONE. Printed 123', 'xp_table: THE DRAGON''S, copied 2026-09-26. Printed 123'), updated_at = datetime('now')
 WHERE class_id IN ('demon-dragonmage') AND instr(markdown, 'xp_table: NONE. Printed 123') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Production''s dragon-hatchling stores no xp_table, so none is', 'Printed 157 says the same. The import stored none because dragon-hatchling then stored none;'), updated_at = datetime('now')
 WHERE class_id IN ('demon-dragonmage') AND instr(markdown, 'Production''s dragon-hatchling stores no xp_table, so none is') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'written here either.', 'it has carried RUE''s dragon ladder since #1415, and that ladder is copied here (Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder).'), updated_at = datetime('now')
 WHERE class_id IN ('demon-dragonmage') AND instr(markdown, 'written here either.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'xp_table: none written. Printed 157 says the Zaayr uses the Dragon R.C.C.''s table, and', 'xp_table: THE DRAGON''S, copied 2026-09-26. Printed 157 says the Zaayr uses the Dragon R.C.C.''s table. The import'), updated_at = datetime('now')
 WHERE class_id IN ('zaayr-crystal-dragon') AND instr(markdown, 'xp_table: none written. Printed 157 says the Zaayr uses the Dragon R.C.C.''s table, and') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'production''s dragon-hatchling stores no xp_table.', 'stored none because dragon-hatchling then stored none; it has carried RUE''s dragon ladder since #1415, and that ladder is copied here (Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder).'), updated_at = datetime('now')
 WHERE class_id IN ('zaayr-crystal-dragon') AND instr(markdown, 'production''s dragon-hatchling stores no xp_table.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '"Experience: Use same table as the Dragon R.C.C." No xp_table is stored,', '"Experience: Use same table as the Dragon R.C.C." The dragon ladder is stored,'), updated_at = datetime('now')
 WHERE class_id IN ('norse-giant') AND instr(markdown, '"Experience: Use same table as the Dragon R.C.C." No xp_table is stored,') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'and that IS the delegation rather than a gap: this catalog''s', 'copied 2026-09-26 from dragon-hatchling, which has carried RUE''s since #1415.'), updated_at = datetime('now')
 WHERE class_id IN ('norse-giant') AND instr(markdown, 'and that IS the delegation rather than a gap: this catalog''s') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'dragon-hatchling stores no xp_table either, so both fall through to', 'The import stored none, because that row then stored none and both fell'), updated_at = datetime('now')
 WHERE class_id IN ('norse-giant') AND instr(markdown, 'dragon-hatchling stores no xp_table either, so both fall through to') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'DEFAULT_XP_TABLE in js/leveling.js and the two genuinely share one table.', 'through to DEFAULT_XP_TABLE in js/leveling.js; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('norse-giant') AND instr(markdown, 'DEFAULT_XP_TABLE in js/leveling.js and the two genuinely share one table.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Writing a table out here would be the thing that broke the promise.', 'A correction to the dragon ladder has to be copied here by hand.'), updated_at = datetime('now')
 WHERE class_id IN ('norse-giant') AND instr(markdown, 'Writing a table out here would be the thing that broke the promise.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'THE BOOK GIVES THIS ENTRY AN EXPERIENCE LADDER AND IT IS NOT STORED.', 'THE BOOK GIVES THIS ENTRY AN EXPERIENCE LADDER AND IT IS STORED.'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'THE BOOK GIVES THIS ENTRY AN EXPERIENCE LADDER AND IT IS NOT STORED.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'See extraction_notes: that pointer resolves in this catalog to the house default, which is what omitting xp_table produces.', 'Since 2026-09-26 xp_table carries the dragon-hatchling ladder (RUE printed 295), copied; see extraction_notes.'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'See extraction_notes: that pointer resolves in this catalog to the house default, which is what omitting xp_table produces.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'NO xp_table, per D3, and THIS IS THE ONLY ONE OF THE SIX THE BOOK GIVES A LADDER FOR:', 'THE DRAGON HATCHLING LADDER IS STORED, and THIS IS THE ONLY ONE OF THE SIX THE BOOK GIVES A LADDER FOR:'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'NO xp_table, per D3, and THIS IS THE ONLY ONE OF THE SIX THE BOOK GIVES A LADDER FOR:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'xp_table is a literal array rather than a named reference, all seven Dragon Hatchling classes in this catalog omit it and take DEFAULT_XP_TABLE from xpTableFor() in js/leveling.js, so the book''s own pointer resolves HERE to the default - which is exactly what omitting the key produces. regression.mjs also refuses any R.C.C. that carries one.', 'Imported with no xp_table under D3, when all seven Dragon Hatchling classes used DEFAULT_XP_TABLE and regression refused an R.C.C. carrying one. Both changed: R.C.C. ladders were allowed 2026-09-17, and #1415 gave the hatchlings RUE''s dragon ladder. On 2026-09-26 that ladder was copied here as xp_table (Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder).'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'xp_table is a literal array rather than a named reference, all seven Dragon Hatchling classes in this catalog omit it and take DEFAULT_XP_TABLE from xpTableFor() in js/leveling.js, so the book''s own pointer resolves HERE to the default - which is exactly what omitting the key produces. regression.mjs also refuses any R.C.C. that carries one.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'experience ladder, which resolves here to the same house default the other five', 'experience ladder - the Dragon Hatchling''s, which it carries - while the other five'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'experience ladder, which resolves here to the same house default the other five') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'take anyway.', 'take the house default.'), updated_at = datetime('now')
 WHERE class_id IN ('man-wolf') AND instr(markdown, 'take anyway.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'NO xp_table, per D3: xpTableFor() in js/leveling.js falls back to DEFAULT_XP_TABLE, which is where the book''s own Man-Wolf pointer resolves in this catalog, and regression refuses an R.C.C. that carries one.', 'NO xp_table, per D3: the book prints no ladder for it, so xpTableFor() in js/leveling.js falls back to DEFAULT_XP_TABLE. D3 also leaned on the Man-Wolf''s dragon pointer resolving to that default and on regression refusing an R.C.C. ladder; neither holds since 2026-09-26, when the Man-Wolf took the dragon ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('domovoi') AND instr(markdown, 'NO xp_table, per D3: xpTableFor() in js/leveling.js falls back to DEFAULT_XP_TABLE, which is where the book''s own Man-Wolf pointer resolves in this catalog, and regression refuses an R.C.C. that carries one.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'gargoyle R.C.C.s carries one, and each states outright that player', 'gargoyle R.C.C.s has one there, and each states outright that player'), updated_at = datetime('now')
 WHERE class_id IN ('gargoyle') AND instr(markdown, 'gargoyle R.C.C.s carries one, and each states outright that player') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '197 calls them optional player characters. Nothing is stored: a Rifts class', '197 calls them optional player characters. The psi-stalker ladder is stored,'), updated_at = datetime('now')
 WHERE class_id IN ('gargoyle') AND instr(markdown, '197 calls them optional player characters. Nothing is stored: a Rifts class') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'carries no `xp_table` here.', 'copied 2026-09-26 from psi-stalker (RUE printed 295); Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('gargoyle') AND instr(markdown, 'carries no `xp_table` here.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Nothing is stored - a Rifts class carries no `xp_table` here.', 'That ladder is stored, copied 2026-09-26 from dragon-hatchling (RUE printed 295); Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('gargoyle-lord', 'gargoyle-mage') AND instr(markdown, 'Nothing is stored - a Rifts class carries no `xp_table` here.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'catalog. Nothing is stored - a Rifts class carries no `xp_table` here.', 'catalog. It is stored, copied 2026-09-26 from psi-stalker (RUE printed 295); Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.'), updated_at = datetime('now')
 WHERE class_id IN ('gurgoyle') AND instr(markdown, 'catalog. Nothing is stored - a Rifts class carries no `xp_table` here.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Under the reference rule (a race carries a ladder only when its own book prints one for it) no xp_table is stored; the ''Borg ladder applies at the table.', 'The import stored none under the rule then (a race carries a ladder only when its own book prints one for it). Since 2026-09-26 xp_table carries the ''Borg ladder, copied from combat-cyborg (RUE printed 295, the Combat Cyborg, Headhunter and Robot Pilot column), the ladder splugorth-conservator and hawrk-ka also carry; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder, and that rule replaced the own-book-only one.'), updated_at = datetime('now')
 WHERE class_id IN ('kremin-cyborg') AND instr(markdown, 'Under the reference rule (a race carries a ladder only when its own book prints one for it) no xp_table is stored; the ''Borg ladder applies at the table.') > 0;

-- Read the result back.
SELECT 'each dragon copy equals what dragon-hatchling stores' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes c, imported_classes s
 WHERE s.class_id = 'dragon-hatchling' AND c.class_id IN ('demon-dragonmage', 'zaayr-crystal-dragon', 'norse-giant', 'man-wolf', 'gargoyle-lord', 'gargoyle-mage')
   AND instr(s.markdown, char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)) > 0
   AND instr(c.markdown, char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)) > 0;

SELECT 'each psistalker copy equals what psi-stalker stores' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes c, imported_classes s
 WHERE s.class_id = 'psi-stalker' AND c.class_id IN ('gargoyle', 'gurgoyle')
   AND instr(s.markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)) > 0
   AND instr(c.markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)) > 0;

SELECT 'each borg copy equals what combat-cyborg stores' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes c, imported_classes s
 WHERE s.class_id = 'combat-cyborg' AND c.class_id IN ('kremin-cyborg')
   AND instr(s.markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)) > 0
   AND instr(c.markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)) > 0;

SELECT 'each dogboy copy equals what dog-boy stores' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes c, imported_classes s
 WHERE s.class_id = 'dog-boy' AND c.class_id IN ('gargoylite')
   AND instr(s.markdown, char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)) > 0
   AND instr(c.markdown, char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)) > 0;

SELECT 'no class anywhere states xp_table twice as a line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > length(char(10) || 'xp_table:');

SELECT 'no note still says one of these ladders is not stored' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id NOT IN ('noro', 'space-wolfen', 'erta')
   AND (instr(markdown, 'carries no `xp_table` here') > 0
        OR instr(markdown, 'stores no xp_table') > 0
        OR instr(markdown, 'no xp_table is stored') > 0
        OR instr(markdown, 'resolves in this catalog to the house default') > 0
        OR instr(markdown, 'Man-Wolf pointer resolves') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~011-borrowed-xp-ladders.sql');
