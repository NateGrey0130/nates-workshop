-- Experience ladders a class's own book prints and the catalog did not store:
-- nine Wormwood and eleven Phase World races whose notes recorded them, and the
-- Coalition Juicer and the Euro-Juicer.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~009-own-book-xp-ladders.sql
--
-- THE DECISIONS. An R.C.C. may carry the ladder its book prints for it (Nate,
-- 2026-09-17, docs/surveys/nightbane-core.md), and an O.C.C.'s ladder wins a
-- pairing. And a class whose book says "use X's experience table" copies X's
-- ladder (Nate, 2026-09-26): Atlantis's practice, which replaces the own-book-only
-- rule the Coalition War Campaign import followed. ~009-own-book-xp-ladders.sql
-- and ~010-borrowed-xp-ladders.sql are one change in two files, split only so
-- each file's read-backs stay short: d1-apply re-runs them as ONE command line,
-- and Windows refused the single file's 5,900 characters of SELECTs.
--
-- OWN BOOK. Each figure is the LOWER bound of each band.
--
-- Recorded only in the class's notes (20 classes):
--   Wormwood printed 157 (ww cache p157, page_offset 0), nine races. The cache
--   loses the goblin column's last two levels; a 400 dpi render reads level 15
--   as 290,881-335,000, where the four goblin-group notes had recorded 289,881.
--   The morphworm, monk & entrancer and shade columns agree with the cache.
--     Demon Goblin, Demon Hound Rider, Ram-Rat & Sky Rider: 0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881
--     Morphworm, Rumbler & Holy Terror: 0, 2901, 4801, 9601, 19201, 29201, 49001, 79001, 119001, 169001, 230001, 300001, 380001, 470001, 600001
--     Monk & Entrancer: 0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501
--     Shade: 0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001
--   Phase World printed 183 (cache p183, page_offset 0), read off a 170 dpi
--   render; every value agrees with the class's own note. The Noro and the
--   Space Wolfen are NOT here: the columns naming them name their O.C.C.s.
--     Seljuk, Noro Mystic Warrior, Kreeghor & Catyr: 0, 2201, 4401, 8901, 18001, 26001, 36001, 52001, 76001, 100001, 150001, 200001, 275001, 350001, 425001
--     Machine People & Phantom / Vacuum Wasps: 0, 2301, 4501, 10001, 20001, 30001, 42001, 65001, 85001, 110001, 160001, 210001, 285001, 370001, 450001
--     Silhouette, Draconid & Repo-Bots: 0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001
--     Pleasurer & Termite Engineers: 0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001
--     Noro Psychic / Promethean (First Stage): 0, 2601, 5001, 10001, 20001, 30001, 39001, 52001, 70001, 100001, 140001, 190001, 240001, 290001, 350001
--   The shared columns match the O.C.C.s already carrying them (noro-mystic-warrior,
--   noro-psychic).
--
-- Printed in the class's own book and recorded nowhere (2 classes):
--   coalition-juicer: Coalition War Campaign printed 224 (cache p225), the
--   column headed "CS Juicer, CS Commando, CS Strike Cyborg", read off a 300
--   dpi render: 0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001.
--   Juicer Uprising printed 156 also names a "Coalition Juicer", in its
--   Psycho-Stalker / Juicer Assassin column, with a different ladder; CWC is the
--   later book and the one this row cites (it re-cited the class from JU), so
--   CWC's ladder is the one stored.
--   euro-juicer: Triax and the NGR printed 224 (page_offset 0), the column headed
--   "Euro-Juicer", read off a 300 dpi render: 0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301, 231401, 281501, 341601.
--   It is NOT the Juicer's ladder reprinted: level 10 starts at 96,001 where
--   RUE's Juicer starts at 96,101. #1439 put xp_table on its copy_of except list.
--
-- MECHANICS. One xp_table line straight after each class's single "category:"
-- line, guarded on no xp_table LINE yet, so a second run changes nothing.
-- Every note that said the ladder is not stored is rewritten as a past-tense
-- decision in the same run, each replace guarded on the text it replaces.
-- The ~ tier sorts after every z- tier, so nothing rewrites these rows later.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'demon-hound-rider'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ram-rat'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sky-rider'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2901, 4801, 9601, 19201, 29201, 49001, 79001, 119001, 169001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'morphworm'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2901, 4801, 9601, 19201, 29201, 49001, 79001, 119001, 169001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rumbler'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2901, 4801, 9601, 19201, 29201, 49001, 79001, 119001, 169001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'holy-terror'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'entrancer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'shade'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 8901, 18001, 26001, 36001, 52001, 76001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'seljuk'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 8901, 18001, 26001, 36001, 52001, 76001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'kreeghor'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 8901, 18001, 26001, 36001, 52001, 76001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'catyr'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2301, 4501, 10001, 20001, 30001, 42001, 65001, 85001, 110001, 160001, 210001, 285001, 370001, 450001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'machine-people'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2301, 4501, 10001, 20001, 30001, 42001, 65001, 85001, 110001, 160001, 210001, 285001, 370001, 450001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'phantom'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2301, 4501, 10001, 20001, 30001, 42001, 65001, 85001, 110001, 160001, 210001, 285001, 370001, 450001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'vacuum-wasp'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'silhouette'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'draconid'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'pleasurer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'termite-engineer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2601, 5001, 10001, 20001, 30001, 39001, 52001, 70001, 100001, 140001, 190001, 240001, 290001, 350001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'first-stage-promethean'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'euro-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- The notes.

UPDATE imported_classes
   SET markdown = replace(markdown, 'NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, ', 'THE LADDER IS STORED AS xp_table SINCE 2026-09-26. The import stored none because regression then pinned that no R.C.C. carries one; that rule was lifted 2026-09-17 (docs/surveys/nightbane-core.md: a race carries the ladder its book prints, and an O.C.C.''s ladder wins a pairing). p.157 prints a ladder for this race, '), updated_at = datetime('now')
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'entrancer', 'holy-terror', 'morphworm', 'ram-rat', 'rumbler', 'shade', 'sky-rider') AND instr(markdown, 'NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, ') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'so the numbers are recorded here rather than lost:', 'and the stored figures are the lower bounds of its bands:'), updated_at = datetime('now')
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'entrancer', 'holy-terror', 'morphworm', 'ram-rat', 'rumbler', 'sky-rider') AND instr(markdown, 'so the numbers are recorded here rather than lost:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone', 'Paired with an O.C.C. a character levels on the O.C.C.''s table; played as a race alone, on this one'), updated_at = datetime('now')
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'entrancer', 'holy-terror', 'morphworm', 'ram-rat', 'rumbler', 'shade', 'sky-rider') AND instr(markdown, 'A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, ' - the same delegation the Norse Giant records.', '.'), updated_at = datetime('now')
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'entrancer', 'holy-terror', 'morphworm') AND instr(markdown, ' - the same delegation the Norse Giant records.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '239,661 / 289,881.', '239,661 / 290,881. The import recorded level 15 as 289,881; a 400 dpi render of p.157 reads 290,881-335,000, and 290,881 is what is stored.'), updated_at = datetime('now')
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'ram-rat', 'sky-rider') AND instr(markdown, '239,661 / 289,881.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'A RACE CARRIES NO xp_table.', 'THE LADDER IS STORED AS xp_table SINCE 2026-09-26.'), updated_at = datetime('now')
 WHERE class_id IN ('catyr', 'kreeghor', 'machine-people', 'silhouette', 'draconid', 'phantom', 'pleasurer', 'vacuum-wasp', 'termite-engineer') AND instr(markdown, 'A RACE CARRIES NO xp_table.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'composition is race-primary, so a table here would', 'the import stored none because composition was then race-primary; an O.C.C.''s ladder has won a pairing since 2026-09-17, so a table here no longer would'), updated_at = datetime('now')
 WHERE class_id IN ('catyr', 'kreeghor', 'machine-people', 'silhouette', 'draconid', 'phantom', 'pleasurer', 'vacuum-wasp', 'termite-engineer') AND instr(markdown, 'composition is race-primary, so a table here would') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AND IT IS NOT IN', 'AND SINCE 2026-09-26 IT IS IN'), updated_at = datetime('now')
 WHERE class_id IN ('seljuk') AND instr(markdown, 'AND IT IS NOT IN') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'composition is race-primary and a table here would win over the occupation''s', 'composition was then race-primary and a table here would have won over the occupation''s'), updated_at = datetime('now')
 WHERE class_id IN ('seljuk') AND instr(markdown, 'composition is race-primary and a table here would win over the occupation''s') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'and silently drop it. The book''s own rule', 'and silently dropped it, which is why the import stored none; an O.C.C.''s ladder has won a pairing since 2026-09-17. The book''s own rule'), updated_at = datetime('now')
 WHERE class_id IN ('seljuk') AND instr(markdown, 'and silently drop it. The book''s own rule') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The app cannot compare them, so the race carries no table', 'The app cannot compare them: the race carries its own table,'), updated_at = datetime('now')
 WHERE class_id IN ('seljuk') AND instr(markdown, 'The app cannot compare them, so the race carries no table') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'and the O.C.C.''s applies; the seljuk ladder is written out in the extraction', 'used when it is played alone, and in a pairing the O.C.C.''s applies; the ladder is also written out in the extraction'), updated_at = datetime('now')
 WHERE class_id IN ('seljuk') AND instr(markdown, 'and the O.C.C.''s applies; the seljuk ladder is written out in the extraction') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'THE LADDER IS RECORDED HERE BECAUSE A RACE CARRIES NO xp_table.', 'THE LADDER IS STORED AS xp_table SINCE 2026-09-26.'), updated_at = datetime('now')
 WHERE class_id IN ('first-stage-promethean') AND instr(markdown, 'THE LADDER IS RECORDED HERE BECAUSE A RACE CARRIES NO xp_table.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '(First Stage)" and it is the', '(First Stage)", naming this race, and it is the one it shares with the Noro Psychic'), updated_at = datetime('now')
 WHERE class_id IN ('first-stage-promethean') AND instr(markdown, '(First Stage)" and it is the') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'O.C.C.''s table: 0 / 2,601', 'O.C.C.: 0 / 2,601'), updated_at = datetime('now')
 WHERE class_id IN ('first-stage-promethean') AND instr(markdown, 'O.C.C.''s table: 0 / 2,601') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'frontmatter.md is explicit that a race', 'The import stored none because a race'), updated_at = datetime('now')
 WHERE class_id IN ('first-stage-promethean') AND instr(markdown, 'frontmatter.md is explicit that a race') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'carrying its own table wins over the occupation''s and silently drops it.', 'carrying its own table then won over the occupation''s; an O.C.C.''s ladder has won a pairing since 2026-09-17.'), updated_at = datetime('now')
 WHERE class_id IN ('first-stage-promethean') AND instr(markdown, 'carrying its own table wins over the occupation''s and silently drops it.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'and is prose because no player pays it."', 'and is prose because no player pays it. XP: stored 2026-09-26 as xp_table, this book''s own printed-224 ladder, the column headed CS Juicer, CS Commando, CS Strike Cyborg, read off a render. Juicer Uprising printed 156 names a Coalition Juicer in a different column (Psycho-Stalker, Juicer Assassin, Coalition Juicer: 0, 2,201, 4,401 ...); this book is the later one and the one this row cites, so its ladder is the one stored."'), updated_at = datetime('now')
 WHERE class_id IN ('coalition-juicer') AND instr(markdown, 'and is prose because no player pays it."') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - AND ITS EXPERIENCE LADDER ON PRINTED 224 IS THE JUICER''S TOO, which is the', '  - ITS EXPERIENCE LADDER ON PRINTED 224 WAS READ AS THE JUICER''S TOO, and that is'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, '  - AND ITS EXPERIENCE LADDER ON PRINTED 224 IS THE JUICER''S TOO, which is the') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'check that the sentence above means what it says rather than being a', 'almost right: a 300 dpi render on 2026-09-26 reads level 10 as 96,001, where'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'check that the sentence above means what it says rather than being a') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'shorthand for something narrower. The Euro-Juicer ladder reads 0-2,140 /', 'the juicer row''s xp_table (RUE) starts it at 96,101. The Euro-Juicer ladder reads 0-2,140 /'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'shorthand for something narrower. The Euro-Juicer ladder reads 0-2,140 /') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'own table, reprinted under a European name. Read off a 190 dpi render of', 'table with that one band moved. First read off a 190 dpi render of'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'own table, reprinted under a European name. Read off a 190 dpi render of') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Nothing is stored from it: a Rifts O.C.C. carries no `xp_table` here.', 'Stored as xp_table since 2026-09-26, which is why xp_table is on copy_of''s except list.'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'Nothing is stored from it: a Rifts O.C.C. carries no `xp_table` here.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'its experience table on printed 224 is the Juicer''s own, reprinted.', 'its experience table on printed 224 is the Juicer''s, reprinted with level 10 starting at 96,001 rather than 96,101, and that printed ladder is the one this class carries.'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'its experience table on printed 224 is the Juicer''s own, reprinted.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Every mechanical block on this class is a copy of the Juicer', 'Every mechanical block on this class but its experience ladder is a copy of the Juicer'), updated_at = datetime('now')
 WHERE class_id IN ('euro-juicer') AND instr(markdown, 'Every mechanical block on this class is a copy of the Juicer') > 0;

-- Read the result back.
SELECT 'the goblin ladder on its 4' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('demon-goblin', 'demon-hound-rider', 'ram-rat', 'sky-rider')
   AND instr(markdown, char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)) > 0;

SELECT 'the worm ladder on its 3' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('morphworm', 'rumbler', 'holy-terror')
   AND instr(markdown, char(10) || 'xp_table: [0, 2901, 4801, 9601, 19201, 29201, 49001, 79001, 119001, 169001, 230001, 300001, 380001, 470001, 600001]' || char(10)) > 0;

SELECT 'the monk ladder on its 1' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id IN ('entrancer')
   AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501]' || char(10)) > 0;

SELECT 'the shade ladder on its 1' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id IN ('shade')
   AND instr(markdown, char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001]' || char(10)) > 0;

SELECT 'the seljuk ladder on its 3' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('seljuk', 'kreeghor', 'catyr')
   AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 8901, 18001, 26001, 36001, 52001, 76001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)) > 0;

SELECT 'the machine ladder on its 3' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('machine-people', 'phantom', 'vacuum-wasp')
   AND instr(markdown, char(10) || 'xp_table: [0, 2301, 4501, 10001, 20001, 30001, 42001, 65001, 85001, 110001, 160001, 210001, 285001, 370001, 450001]' || char(10)) > 0;

SELECT 'the silhouette ladder on its 2' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('silhouette', 'draconid')
   AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)) > 0;

SELECT 'the pleasurer ladder on its 2' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('pleasurer', 'termite-engineer')
   AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)) > 0;

SELECT 'the promethean ladder on its 1' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id IN ('first-stage-promethean')
   AND instr(markdown, char(10) || 'xp_table: [0, 2601, 5001, 10001, 20001, 30001, 39001, 52001, 70001, 100001, 140001, 190001, 240001, 290001, 350001]' || char(10)) > 0;

SELECT 'the csjuicer ladder on its 1' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id IN ('coalition-juicer')
   AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]' || char(10)) > 0;

SELECT 'the euro ladder on its 1' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id IN ('euro-juicer')
   AND instr(markdown, char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301, 231401, 281501, 341601]' || char(10)) > 0;

SELECT 'no class anywhere states xp_table twice as a line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > length(char(10) || 'xp_table:');

SELECT 'no note still says one of these ladders is not stored' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id NOT IN ('noro', 'space-wolfen', 'erta')
   AND (instr(markdown, 'REPO INVARIANT RATHER THAN A GAP') > 0
        OR instr(markdown, 'A RACE CARRIES NO xp_table') > 0
        OR instr(markdown, '289,881.') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~009-own-book-xp-ladders.sql');
