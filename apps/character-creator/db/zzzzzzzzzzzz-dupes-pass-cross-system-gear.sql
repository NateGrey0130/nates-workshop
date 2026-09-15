-- The duplicate-suggestion pass over `gear`, and the first use of
-- `catalog_pair_dismissals` in this database.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql
--
-- ===================================================================
-- WHY THIS IS A DATA SCRIPT AND NOT A SESSION WITH THE PANEL
-- ===================================================================
--
-- The duplicates panel writes its answers straight to D1, and so leaves NOTHING
-- IN GIT - the same shape `restore-*.sql` exists to recover from, and one this
-- table has never been protected against because **it has never been used**:
-- `SELECT count(*) FROM catalog_pair_dismissals` was 0 in production before this
-- file, and no data script wrote a row. So every reader has re-judged every pair
-- from scratch since migration 050 landed, which is precisely the state
-- `BOOK-INGEST-AUDIT` F33 added the table to end.
--
-- Judged with the tool rather than around it: `findDuplicates` was imported and
-- run against production over a D1 shim, so the scoring, the tiering and the
-- bucketing are the endpoint's own and not a second implementation of them.
-- `dismissed_by` is this FILENAME rather than a person's address, because no
-- person clicked; a reader deserves to see that the judgement came from a
-- scripted pass.
--
-- ===================================================================
-- WHAT THE PASS FOUND: 1,720 SUGGESTIONS, 2 WORTH ACTING ON
-- ===================================================================
--
--   certain      1
--   likely       1
--   contains 1,718   -- the tier the endpoint's own comment rates at about 40%
--
-- Of the 1,720, **1,003 involve a Heroes Unlimited row**, which is this import's
-- doing: the catalog suggested 591 pairs before it. Broken down by shape:
--
--   138  SAME name, DIFFERENT system   <- dismissed here
--     0  SAME name, SAME system        <- there were none, which is the good news
--   1582 different names, fuzzy match  <- NOT touched; see below
--
-- ===================================================================
-- THE 138: ONE ROW PER BOOK, WHICH IS THE ESTABLISHED SHAPE
-- ===================================================================
--
--   heroes-unlimited vs palladium-fantasy   102
--   heroes-unlimited vs rifts                33
--   palladium-fantasy vs rifts                3
--
-- A catalog row is scoped by `system`, so two rows of the same name in two
-- systems NEVER appear together in front of anybody - merging them would delete
-- one book's figures to keep another's. The three that predate this import say
-- it plainly: Large Sack is 2 in Rifts and 3 in Palladium Fantasy, Small Sack 2
-- and 1, Sleeping Bag 110 and 30.
--
-- WHERE THE NUMBERS MATCH, THE UNITS DO NOT. Compass is 50 in both, Gas Mask 50,
-- Pocket Night Viewer 800 - and `js/rules.js` prices Rifts in CREDITS and Heroes
-- Unlimited in DOLLARS, so an identical integer is two different prices. That
-- coincidence is the reason these read as duplicates and the reason they are
-- not.
--
-- Each row carries its own note naming both books, rather than one blanket
-- reason, so a reader re-opening any single pair sees why THAT pair was kept.
--
-- ===================================================================
-- THE 1,582 FUZZY PAIRS ARE DELIBERATELY LEFT ALONE
-- ===================================================================
--
-- They have not been judged. Dismissing an unjudged pair is worse than leaving
-- it suggested: it removes the question without answering it, and the table
-- cannot tell a considered NO from a bulk one. They stay in the panel.
--
-- ===================================================================
-- ONE REAL DUPLICATE, MERGED
-- ===================================================================
--
-- `Flashlight, large` and `Large Flashlight` are the SAME system, the SAME book
-- and the same cost of 12 - the only `likely`-tier pair in the catalog, and the
-- shape the tool was built to find: one item under two naming conventions.
--
--   large-flashlight  Large Flashlight   12  0.5 lbs  "A large flashlight, 12 to 20 credits."  RUE p.261-265
--   flashlight-large  Flashlight, large  12  no wt    "20 cr."                                 RUE p.261-270
--
-- KEEPER IS `large-flashlight`, on the `merge-backpack-duplicate.sql` tiebreak:
-- age is only a proxy for which name existing references use, and here **five
-- published classes cite the keeper against one for the loser**, with no
-- inventory row on either. It is also the richer row - the loser's whole
-- description is the price. Nothing is lost: the keeper already prints "12 to
-- 20 credits", which is the loser's "20 cr." and more.
--
-- The one class citing the retired spelling is repointed by an EXACT structured
-- match on the whole inventory entry, never a loose name replace - class
-- markdown is frontmatter plus prose and a loose replace would hit lore text.
-- A redirect is filed so anything else holding the old slug still resolves.
--
-- ===================================================================
-- ONE CERTAIN-TIER SUGGESTION THAT IS A FALSE POSITIVE
-- ===================================================================
--
-- `Robe (Heavy)` [palladium-fantasy, 30] and `Robe` [both, 30] score 1.00,
-- because `normaliseName` strips every bracketed qualifier - the failure mode
-- the function's own comment predicts ("right for Tracking (people) and wrong
-- for the psionics chapter"). Palladium Fantasy printed 272 lists THREE robes at
-- three prices - Light 20, Heavy 30, Hooded 35 - and `Robe` is a separate
-- generic row whose source_book is an estimate. Dismissed.
--
-- Gear 2163 -> 2162, and the pinned figure moves with it.

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', '2-handed-espandon', 'espandon', 'One row per book. 2-handed Espandon is heroes-unlimited (Revised Heroes Unlimited p.193-194); 2-Handed Espandon is palladium-fantasy (Palladium RPG Main Book p.271). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'acoustic-noise-generator', 'acoustic-noise-generator-hu', 'One row per book. Acoustic Noise Generator is rifts (Rifts Ultimate Edition p.261-270); Acoustic Noise Generator is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'arab-mace', 'arab-mace-hu', 'One row per book. Arab Mace is palladium-fantasy (Palladium RPG Main Book p.271); Arab Mace is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'arrows-long-bow', 'arrows-standard', 'One row per book. Arrows (long bow) is heroes-unlimited (Revised Heroes Unlimited p.193-194); Arrows (long bow) is palladium-fantasy (Palladium RPG Main Book p.271). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'arrows-short-bow', 'arrows-short-bow-hu', 'One row per book. Arrows (short bow) is palladium-fantasy (Palladium RPG Main Book p.271); Arrows (short bow) is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'awl-pike', 'awl-pike-hu', 'One row per book. Awl Pike is palladium-fantasy (Palladium RPG Main Book p.270); Awl Pike is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'axe-battle', 'axe-battle-hu', 'One row per book. Axe, Battle is palladium-fantasy (Palladium RPG Main Book p.270); Axe, Battle is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'axe-bipennis', 'axe-bipennis-2-head', 'One row per book. Axe, Bipennis (2-head) is palladium-fantasy (Palladium RPG Main Book p.270); Axe, Bipennis (2-head) is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'axe-stone', 'axe-stone-hu', 'One row per book. Axe, Stone is palladium-fantasy (Palladium RPG Main Book p.270); Axe, Stone is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'axe-throwing', 'axe-throwing-hu', 'One row per book. Axe, Throwing is palladium-fantasy (Palladium RPG Main Book p.270); Axe, Throwing is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'back-pack-hu', 'back-pack-pf', 'One row per book. Back Pack is heroes-unlimited (Revised Heroes Unlimited p.218); Back pack is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'ball-and-chain', 'ball-and-chain-hu', 'One row per book. Ball and Chain is palladium-fantasy (Palladium RPG Main Book p.271); Ball and Chain is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'bastard', 'bastard-sword', 'One row per book. Bastard is heroes-unlimited (Revised Heroes Unlimited p.193-194); Bastard is palladium-fantasy (Palladium RPG Main Book p.271). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'beaked-axe', 'beaked-axe-hu', 'One row per book. Beaked Axe is palladium-fantasy (Palladium RPG Main Book p.270); Beaked Axe is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'berdiche', 'berdiche-hu', 'One row per book. Berdiche is palladium-fantasy (Palladium RPG Main Book p.270); Berdiche is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'black-jack', 'black-jack-hu', 'One row per book. Black Jack is palladium-fantasy (Palladium RPG Main Book p.271); Black Jack is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'blanket-heavy', 'blanket-heavy-hu', 'One row per book. Blanket (Heavy) is palladium-fantasy (Palladium RPG Main Book p.273); Blanket - Heavy is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'blanket-light', 'blanket-light-hu', 'One row per book. Blanket (Light) is palladium-fantasy (Palladium RPG Main Book p.273); Blanket - Light is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'bo-staff', 'bo-staff-hu', 'One row per book. Bo Staff is palladium-fantasy (Palladium RPG Main Book p.271); Bo Staff is heroes-unlimited (Revised Heroes Unlimited p.194-195). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'broadsword', 'broadsword-hu', 'One row per book. Broadsword is palladium-fantasy (Palladium RPG Main Book p.271); Broadsword is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'bull-whip', 'bull-whip-hu', 'One row per book. Bull Whip is palladium-fantasy (Palladium RPG Main Book p.271); Bull Whip is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'canteen-aluminum', 'canteen-aluminum-hu', 'One row per book. Canteen: Aluminum is rifts (Rifts Ultimate Edition p.261-270); Canteen: Aluminum is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'canteen-plastic', 'canteen-plastic-hu', 'One row per book. Canteen: Plastic is rifts (Rifts Ultimate Edition p.261-270); Canteen: Plastic is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cape-long', 'cape-long-hu', 'One row per book. Cape (Long) is palladium-fantasy (Palladium RPG Main Book p.272); Cape - Long is heroes-unlimited (Revised Heroes Unlimited p.221). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cape-short', 'cape-short-hu', 'One row per book. Cape (Short) is palladium-fantasy (Palladium RPG Main Book p.272); Cape - Short is heroes-unlimited (Revised Heroes Unlimited p.221). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cat-o-nine-tails', 'cat-o-nine-tails-hu', 'One row per book. Cat-o-Nine Tails is palladium-fantasy (Palladium RPG Main Book p.271); Cat-o-Nine Tails is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'chain-mail', 'chain-mail-hu', 'One row per book. Chain Mail is palladium-fantasy (Palladium Fantasy RPG Main Book p.270); Chain Mail is heroes-unlimited (Revised Heroes Unlimited p.212). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'claymore', 'claymore-hu', 'One row per book. Claymore is palladium-fantasy (Palladium RPG Main Book p.271); Claymore is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cloth-handle-bag', 'cloth-handle-bag-hu', 'One row per book. Cloth handle bag is palladium-fantasy (Palladium RPG Main Book p.273); Cloth Handle Bag is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'club-stick-pipe', 'club-stick-pipe-hu', 'One row per book. Club / Stick / Pipe is palladium-fantasy (Palladium RPG Main Book p.271); Club/Stick/Pipe is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'compass', 'compass-hu', 'One row per book. Compass is rifts (Rifts Ultimate Edition p.261-265); Compass is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'contact-microphone', 'contact-microphone-hu', 'One row per book. Contact Microphone is rifts (Rifts Ultimate Edition p.261-270); Contact Microphone is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cross-bow', 'cross-bow-hu', 'One row per book. Cross Bow is palladium-fantasy (Palladium RPG Main Book p.271); Cross Bow is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cudgel', 'cudgel-hu', 'One row per book. Cudgel is palladium-fantasy (Palladium RPG Main Book p.271); Cudgel is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'cutlass', 'cutlass-hu', 'One row per book. Cutlass is palladium-fantasy (Palladium RPG Main Book p.271); Cutlass is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'daggers-and-knives', 'daggers-and-knives-hu', 'One row per book. Daggers and Knives is palladium-fantasy (Palladium RPG Main Book p.270); Daggers and Knives is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'dart', 'dart-hu', 'One row per book. Dart is palladium-fantasy (Palladium RPG Main Book p.271); Dart is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'explosive-grenade', 'explosive-grenade-hu', 'One row per book. Explosive Grenade is rifts (Estimate - no published price found); Explosive Grenade is heroes-unlimited (Revised Heroes Unlimited p.210). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'falchion', 'falchion-hu', 'One row per book. Falchion is palladium-fantasy (Palladium RPG Main Book p.271); Falchion is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'field-radio', 'field-radio-hu', 'One row per book. Field Radio is rifts (Rifts Ultimate Edition p.261-270); Field Radio is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'flail', 'flail-hu', 'One row per book. Flail is palladium-fantasy (Palladium RPG Main Book p.271); Flail is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'flamberge', 'flamberge-hu', 'One row per book. Flamberge is palladium-fantasy (Palladium RPG Main Book p.271); Flamberge is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'flashlight', 'flashlight-hu', 'One row per book. Flashlight is rifts (Rifts Ultimate Edition p.261-265); Flashlight is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'flashlight-large-hu', 'large-flashlight', 'One row per book. Flashlight - Large is heroes-unlimited (Revised Heroes Unlimited p.218); Flashlight, large is rifts (Rifts Ultimate Edition p.261-270). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'frying-pan', 'frying-pan-hu', 'One row per book. Frying Pan is palladium-fantasy (Palladium RPG Main Book p.271); Frying Pan is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'gas-mask', 'gas-mask-hu', 'One row per book. Gas Mask is rifts (Rifts Ultimate Edition p.261-270); Gas Mask is heroes-unlimited (Revised Heroes Unlimited p.219). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'glaive', 'glaive-hu', 'One row per book. Glaive is palladium-fantasy (Palladium RPG Main Book p.270); Glaive is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'goupillon-flail', 'goupillon-flail-hu', 'One row per book. Goupillon Flail is palladium-fantasy (Palladium RPG Main Book p.271); Goupillon Flail is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'guisarme', 'guisarme-hu', 'One row per book. Guisarme is palladium-fantasy (Palladium RPG Main Book p.270); Guisarme is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'halberd', 'halberd-hu', 'One row per book. Halberd is palladium-fantasy (Palladium RPG Main Book p.270); Halberd is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hammer-tool', 'hammer-tool-hu', 'One row per book. Hammer (tool) is palladium-fantasy (Palladium RPG Main Book p.271); Hammer (tool) is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hand-pick', 'hand-pick-hu', 'One row per book. Hand Pick is palladium-fantasy (Palladium RPG Main Book p.271); Hand Pick is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hat-large-brim', 'hat-large-brim-hu', 'One row per book. Hat (Large brim) is palladium-fantasy (Palladium RPG Main Book p.272); Hat - Large Brim is heroes-unlimited (Revised Heroes Unlimited p.220). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hat-short-brim', 'hat-short-brim-hu', 'One row per book. Hat (Short brim) is palladium-fantasy (Palladium RPG Main Book p.272); Hat - Short Brim is heroes-unlimited (Revised Heroes Unlimited p.220). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'heat-sensor', 'heat-sensor-hu', 'One row per book. Heat Sensor is rifts (Rifts Ultimate Edition p.261-270); Heat Sensor is heroes-unlimited (Revised Heroes Unlimited p.215). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hercules-club', 'hercules-club-hu', 'One row per book. Hercules Club is palladium-fantasy (Palladium RPG Main Book p.271); Hercules Club is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'hippe', 'hippe-hu', 'One row per book. Hippe is palladium-fantasy (Palladium RPG Main Book p.270); Hippe is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'horseman-hammer', 'horseman-hammer-hu', 'One row per book. Horseman Hammer is palladium-fantasy (Palladium RPG Main Book p.271); Horseman Hammer is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'infrared-distancing-binoculars', 'infrared-distancing-binoculars-hu', 'One row per book. Infrared Distancing Binoculars is rifts (Web reference (not book-verified)); Infrared Distancing Binoculars is heroes-unlimited (Revised Heroes Unlimited p.213). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'iron-staff', 'iron-staff-hu', 'One row per book. Iron Staff is palladium-fantasy (Palladium RPG Main Book p.271); Iron Staff is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'jar-2-pints', 'jar-2-pints-hu', 'One row per book. Jar, 2 pints is palladium-fantasy (Palladium RPG Main Book p.273); Jar - 2 pints is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'jar-4-pints', 'jar-4-pints-hu', 'One row per book. Jar, 4 pints is palladium-fantasy (Palladium RPG Main Book p.273); Jar - 4 pints is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'jar-glass-1-pint', 'jar-glass-1-pint-hu', 'One row per book. Jar (Glass) 1 pint is palladium-fantasy (Palladium RPG Main Book p.273); Jar, Glass - 1 pint is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'javelin', 'javelin-hu', 'One row per book. Javelin is palladium-fantasy (Palladium RPG Main Book p.270); Javelin is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'jug-1-gallon', 'jug-1-gallon-hu', 'One row per book. Jug, 1 gallon is palladium-fantasy (Palladium RPG Main Book p.273); Jug - 1 gallon is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'jug-5-gallons', 'jug-5-gallons-hu', 'One row per book. Jug, 5 gallons is palladium-fantasy (Palladium RPG Main Book p.273); Jug - 5 gallons is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'keyhole-or-tube-microphones', 'keyhole-or-tube-microphones-hu', 'One row per book. Keyhole or Tube Microphones is rifts (Rifts Ultimate Edition p.261-270); Keyhole or Tube Microphones is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'knapsack', 'knapsack-hu', 'One row per book. Knapsack is rifts (Rifts Ultimate Edition p.261-265); Knapsack is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'knife-large', 'knife-large-hu', 'One row per book. Knife, Large is rifts (Rifts Ultimate Edition p.261-270); Knife: Large is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'knife-small', 'knife-small-hu', 'One row per book. Knife, Small is rifts (Rifts Ultimate Edition p.261-270); Knife: Small is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'lance', 'lance-hu', 'One row per book. Lance is palladium-fantasy (Palladium RPG Main Book p.270); Lance is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'large-pick-mattock', 'large-pick-mattock-hu', 'One row per book. Large Pick/Mattock is palladium-fantasy (Palladium RPG Main Book p.271); Large Pick/Mattock is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'large-sack', 'large-sack-hu', 'One row per book. Large Sack is rifts (Web reference (not book-verified)); Large Sack is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'large-sack', 'large-sack-pf', 'One row per book. Large Sack is rifts (Web reference (not book-verified)); Large sack is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'large-sack-hu', 'large-sack-pf', 'One row per book. Large Sack is heroes-unlimited (Revised Heroes Unlimited p.218); Large sack is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'long-bow', 'long-bow-hu', 'One row per book. Long Bow is palladium-fantasy (Palladium RPG Main Book p.271); Long Bow is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'long-spear', 'long-spear-hu', 'One row per book. Long Spear is palladium-fantasy (Palladium RPG Main Book p.270); Long Spear is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'long-sword', 'long-sword-hu', 'One row per book. Long Sword is palladium-fantasy (Palladium RPG Main Book p.271); Long Sword is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'lucerne-hammer', 'lucerne-hammer-hu', 'One row per book. Lucerne Hammer is palladium-fantasy (Palladium RPG Main Book p.270); Lucerne Hammer is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'mace', 'mace-hu', 'One row per book. Mace is palladium-fantasy (Palladium RPG Main Book p.271); Mace is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'mace-and-chain', 'mace-and-chain-hu', 'One row per book. Mace and Chain is palladium-fantasy (Palladium RPG Main Book p.271); Mace and Chain is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'maul', 'maul-hu', 'One row per book. Maul is palladium-fantasy (Palladium RPG Main Book p.271); Maul is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'meat-cleaver', 'meat-cleaver-hu', 'One row per book. Meat Cleaver is palladium-fantasy (Palladium RPG Main Book p.271); Meat Cleaver is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'medical-bag', 'medical-bag-hu', 'One row per book. Medical Bag is rifts (Rifts Ultimate Edition p.88); Medical Bag is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'microwave-fence', 'microwave-fence-hu', 'One row per book. Microwave Fence is rifts (Rifts Ultimate Edition p.261-270); Microwave Fence is heroes-unlimited (Revised Heroes Unlimited p.215). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'military-fork', 'military-fork-hu', 'One row per book. Military Fork is palladium-fantasy (Palladium RPG Main Book p.270); Military Fork is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'modern-crossbow', 'modern-crossbow-hu', 'One row per book. Modern Crossbow is rifts (Rifts World Book 15: Spirit West p.203); Modern Crossbow is heroes-unlimited (Revised Heroes Unlimited p.211). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'morning-star', 'morning-star-hu', 'One row per book. Morning Star is palladium-fantasy (Palladium RPG Main Book p.271); Morning Star is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'multi-optics-helmet-m-o-h', 'multi-optics-helmet-m-o-h-hu', 'One row per book. Multi-Optics Helmet (M.O.H.) is rifts (Rifts Ultimate Edition p.261-270); Multi-Optics Helmet (M.O.H.) is heroes-unlimited (Revised Heroes Unlimited p.213). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'nunchaku', 'nunchaku-hu', 'One row per book. Nunchaku is palladium-fantasy (Palladium RPG Main Book p.271); Nunchaku is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'oil-lantern-6-hours-1-pint', 'oil-lantern-6-hours-1-pint-hu', 'One row per book. Oil lantern (6 hours/1 pint) is palladium-fantasy (Palladium RPG Main Book p.273); Oil Lantern - 6 hours/1 pint is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'oncin-pick', 'oncin-pick-hu', 'One row per book. Oncin Pick is palladium-fantasy (Palladium RPG Main Book p.270); Oncin Pick is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'optics-band', 'optics-band-hu', 'One row per book. Optics Band is rifts (Rifts Ultimate Edition p.261-270); Optics Band is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'padded-armor', 'padded-or-quilt-armor', 'One row per book. Padded or Quilt Armor is palladium-fantasy (Palladium Fantasy RPG p.270); Padded or Quilt Armor is heroes-unlimited (Revised Heroes Unlimited p.212). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'pike', 'pike-hu', 'One row per book. Pike is palladium-fantasy (Palladium RPG Main Book p.270); Pike is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'plate-armor', 'plate-armor-hu', 'One row per book. Plate Armor is palladium-fantasy (Palladium Fantasy RPG p.270); Plate Armor is heroes-unlimited (Revised Heroes Unlimited p.212). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'pocket-night-viewer', 'pocket-night-viewer-hu', 'One row per book. Pocket Night Viewer is rifts (Rifts Ultimate Edition p.261-270); Pocket Night Viewer is heroes-unlimited (Revised Heroes Unlimited p.213). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'pocket-scrambler', 'pocket-scrambler-hu', 'One row per book. Pocket Scrambler is rifts (Rifts Ultimate Edition p.261-270); Pocket Scrambler is heroes-unlimited (Revised Heroes Unlimited p.215). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'portable-laboratory', 'portable-laboratory-hu', 'One row per book. Portable Laboratory is rifts (Rifts Ultimate Edition p.261-270); Portable Laboratory is heroes-unlimited (Revised Heroes Unlimited p.216). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'quarterstaff', 'quarterstaff-hu', 'One row per book. Quarterstaff is palladium-fantasy (Palladium RPG Main Book p.271); Quarterstaff is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'robe-heavy', 'robe-heavy-hu', 'One row per book. Robe (Heavy) is palladium-fantasy (Palladium RPG Main Book p.272); Robe - Heavy is heroes-unlimited (Revised Heroes Unlimited p.221). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'robe-hooded', 'robe-hooded-hu', 'One row per book. Robe (Hooded) is palladium-fantasy (Palladium RPG Main Book p.272); Robe - Hooded is heroes-unlimited (Revised Heroes Unlimited p.221). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'robe-light', 'robe-light-hu', 'One row per book. Robe (Light) is palladium-fantasy (Palladium RPG Main Book p.272); Robe - Light is heroes-unlimited (Revised Heroes Unlimited p.221). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'runka', 'runka-hu', 'One row per book. Runka is palladium-fantasy (Palladium RPG Main Book p.270); Runka is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sabre', 'sabre-hu', 'One row per book. Sabre is palladium-fantasy (Palladium RPG Main Book p.271); Sabre is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sabre-halberd', 'sabre-halberd-hu', 'One row per book. Sabre Halberd is palladium-fantasy (Palladium RPG Main Book p.270); Sabre Halberd is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'scale-mail', 'scale-mail-hu', 'One row per book. Scale Mail is palladium-fantasy (Palladium Fantasy RPG Main Book p.270); Scale Mail is heroes-unlimited (Revised Heroes Unlimited p.212). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'scimitar', 'scimitar-hu', 'One row per book. Scimitar is palladium-fantasy (Palladium RPG Main Book p.271); Scimitar is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'scythe', 'scythe-hu', 'One row per book. Scythe is palladium-fantasy (Palladium RPG Main Book p.270); Scythe is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'short-bow', 'short-bow-hu', 'One row per book. Short Bow is palladium-fantasy (Palladium RPG Main Book p.271); Short Bow is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'short-spear', 'short-spear-hu', 'One row per book. Short Spear is palladium-fantasy (Palladium RPG Main Book p.270); Short Spear is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'short-sword', 'short-sword-hu', 'One row per book. Short Sword is palladium-fantasy (Palladium RPG Main Book p.271); Short Sword is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'shoulder-purse-large', 'shoulder-purse-large-hu', 'One row per book. Shoulder purse, large is palladium-fantasy (Palladium RPG Main Book p.273); Shoulder Purse - Large is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'shoulder-purse-small', 'shoulder-purse-small-hu', 'One row per book. Shoulder purse, small is palladium-fantasy (Palladium RPG Main Book p.273); Shoulder Purse - Small is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'shovel', 'shovel-hu', 'One row per book. Shovel is palladium-fantasy (Palladium RPG Main Book p.271); Shovel is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sleeping-bag', 'sleeping-bag-hu', 'One row per book. Sleeping Bag is rifts (Rifts Ultimate Edition p.261-265); Sleeping Bag is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sleeping-bag', 'sleeping-bag-pf', 'One row per book. Sleeping Bag is rifts (Rifts Ultimate Edition p.261-265); Sleeping bag is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sleeping-bag-hu', 'sleeping-bag-pf', 'One row per book. Sleeping Bag is heroes-unlimited (Revised Heroes Unlimited p.217); Sleeping bag is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'sling', 'sling-hu', 'One row per book. Sling is palladium-fantasy (Palladium RPG Main Book p.271); Sling is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'small-pocket-purse', 'small-pocket-purse-hu', 'One row per book. Small pocket purse is palladium-fantasy (Palladium RPG Main Book p.273); Small Pocket Purse is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'small-sack', 'small-sack-hu', 'One row per book. Small Sack is rifts (Web reference (not book-verified)); Small Sack is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'small-sack', 'small-sack-pf', 'One row per book. Small Sack is rifts (Web reference (not book-verified)); Small sack is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'small-sack-hu', 'small-sack-pf', 'One row per book. Small Sack is heroes-unlimited (Revised Heroes Unlimited p.218); Small sack is palladium-fantasy (Palladium RPG Main Book p.273). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'smoke-grenade', 'smoke-grenade-hu', 'One row per book. Smoke Grenade is rifts (Web reference (not book-verified)); Smoke Grenade is heroes-unlimited (Revised Heroes Unlimited p.210). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'tent-one-man', 'tent-one-man-hu', 'One row per book. Tent (One man) is palladium-fantasy (Palladium RPG Main Book p.273); Tent - One Man is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'tent-two-man', 'tent-two-man-hu', 'One row per book. Tent (Two man) is palladium-fantasy (Palladium RPG Main Book p.273); Tent - Two Man is heroes-unlimited (Revised Heroes Unlimited p.217). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'tobacco-pouch', 'tobacco-pouch-hu', 'One row per book. Tobacco pouch is palladium-fantasy (Palladium RPG Main Book p.273); Tobacco Pouch is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'tracer-bug', 'tracer-bug-hu', 'One row per book. Tracer Bug is rifts (Rifts Ultimate Edition p.261-270); Tracer Bug is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'trident', 'trident-hu', 'One row per book. Trident is palladium-fantasy (Palladium RPG Main Book p.270); Trident is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'ultraviolet-signaler', 'ultraviolet-signaler-hu', 'One row per book. Ultraviolet Signaler is rifts (Rifts Ultimate Edition p.261-270); Ultraviolet Signaler is heroes-unlimited (Revised Heroes Unlimited p.215). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'vial-glass-2-ounce', 'vial-glass-2-ounce-hu', 'One row per book. Vial (Glass, 2 ounce) is palladium-fantasy (Palladium RPG Main Book p.273); Vial, Glass - 2 ounce is heroes-unlimited (Revised Heroes Unlimited p.218). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'video-wall-mount', 'video-wall-mount-hu', 'One row per book. Video Wall Mount is rifts (Rifts Ultimate Edition p.261-270); Video Wall Mount is heroes-unlimited (Revised Heroes Unlimited p.215). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'voulge', 'voulge-hu', 'One row per book. Voulge is palladium-fantasy (Palladium RPG Main Book p.270); Voulge is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'war-club', 'war-club-wood', 'One row per book. War Club (wood) is palladium-fantasy (Palladium RPG Main Book p.271); War Club (wood) is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'war-hammer', 'war-hammer-hu', 'One row per book. War Hammer is palladium-fantasy (Palladium RPG Main Book p.271); War Hammer is heroes-unlimited (Revised Heroes Unlimited p.193-194). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'wireless-microphone', 'wireless-microphone-hu', 'One row per book. Wireless Microphone is rifts (Rifts Ultimate Edition p.261-270); Wireless Microphone is heroes-unlimited (Revised Heroes Unlimited p.214). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'work-overalls', 'work-overalls-hu', 'One row per book. Work Overalls is rifts (Estimate - no published price found); Work Overalls is heroes-unlimited (Revised Heroes Unlimited p.219). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'work-pants', 'work-pants-hu', 'One row per book. Work pants is palladium-fantasy (Palladium RPG Main Book p.272); Work Pants is heroes-unlimited (Revised Heroes Unlimited p.220). Each system''s catalog is scoped to its own rows, so these never appear together.', 'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');

-- ===== The false positive on the certain tier =====

INSERT OR IGNORE INTO catalog_pair_dismissals (catalog, key_a, key_b, note, dismissed_by)
VALUES ('gear', 'robe', 'robe-heavy',
        'Not the same row. Palladium Fantasy printed 272 lists three robes - Light 20, Heavy 30, Hooded 35 - and `robe` is a separate generic row priced by estimate, system `both`. They score 1.00 only because normaliseName strips the bracketed qualifier, which is the failure its own comment predicts.',
        'zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');

-- ===== The one real duplicate =====
-- Order matters: repoint the class first, then file the redirect, then delete.
-- A redirect filed after the delete could not resolve its target by slug.

-- The one class citing the retired spelling. An EXACT structured match on the
-- whole inventory entry, never a loose name replace: class markdown is
-- frontmatter plus prose and a loose replace would hit lore text as readily.
-- Checked first that this class does NOT already carry the keeper - repointing
-- onto a slug already in the list is how a merge creates a duplicate ENTRY,
-- which is what zz-canonicalise-class-skill-names.sql did to the Mystic.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '- { item_id: "flashlight-large", qty: 1 }',
         '- { item_id: "large-flashlight", qty: 1 }')
 WHERE class_id = 'salvage-expert'
   AND instr(markdown, '- { item_id: "flashlight-large", qty: 1 }') > 0
   AND instr(markdown, '"large-flashlight"') = 0;

-- Resolved by NATURAL KEY at apply time, never by a written-down id: an id is
-- insertion order and differs per environment.
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'flashlight-large', id, 'merge' FROM gear WHERE slug = 'large-flashlight';

DELETE FROM gear
 WHERE slug = 'flashlight-large'
   AND NOT EXISTS (SELECT 1 FROM character_items WHERE gear_slug = 'flashlight-large');

-- ASSERTIONS.

SELECT 'one hundred and thirty-nine pairs are now judged' AS assertion, count(*) AS got, 139 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'gear';
SELECT 'one hundred and thirty-eight of them are the cross-system class' AS assertion,
       count(*) AS got, 138 AS want
  FROM catalog_pair_dismissals
 WHERE catalog = 'gear' AND instr(note, 'One row per book') > 0;
SELECT 'every dismissal names both books' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'gear' AND (note IS NULL OR length(note) < 40);

-- KEYS ARE CANONICAL: sorted, case-folded, and never a row paired with itself.
-- The UNIQUE constraint only de-duplicates if the sort happened on the way in.
SELECT 'every pair is stored in sorted order' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals WHERE catalog = 'gear' AND lower(key_a) >= lower(key_b);

-- AND EVERY KEY IS A REAL GEAR SLUG - except the one this file retires, which
-- is the point of checking rather than assuming.
SELECT 'every dismissed key still names a live row' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_pair_dismissals d
 WHERE d.catalog = 'gear'
   AND (NOT EXISTS (SELECT 1 FROM gear g WHERE g.slug = d.key_a)
     OR NOT EXISTS (SELECT 1 FROM gear g WHERE g.slug = d.key_b));

-- THE MERGE.
SELECT 'the retired flashlight row is gone' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'flashlight-large';
SELECT 'the keeper is still here with its weight' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'large-flashlight' AND cost = 12 AND weight_lbs = 0.5;
SELECT 'the retired key resolves to the keeper' AS assertion, count(*) AS got, 1 AS want
  FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
 WHERE r.catalog = 'gear' AND r.from_key = 'flashlight-large' AND g.slug = 'large-flashlight';
SELECT 'the one class that cited it now cites the keeper' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'salvage-expert'
   AND instr(markdown, '"large-flashlight"') > 0;
SELECT 'and no class cites the retired spelling' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE instr(markdown, '"flashlight-large"') > 0;
SELECT 'and it did not gain the item twice' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'salvage-expert'
   AND instr(substr(markdown, instr(markdown, '"large-flashlight"') + 18), '"large-flashlight"') = 0;

-- F90's RULE STILL HOLDS after retiring a key here.
SELECT 'no live gear row sits on a key a redirect retired' AS assertion, count(*) AS got, 0 AS want
  FROM gear g JOIN catalog_redirects r ON r.catalog = 'gear' AND r.from_key = g.slug
              JOIN gear t ON t.id = r.to_id;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql');
