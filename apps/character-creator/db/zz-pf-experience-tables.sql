-- Every Palladium O.C.C. levels on its own chart now, not the house rule.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. There is no schema here at all: `xpTableFor()` has honoured
-- a frontmatter `xp_table` since leveling.js was written, and #222 made an
-- occupation's table survive composition so a Palladium character can actually
-- receive one.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-pf-experience-tables.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-pf-experience-tables.sql
--
--   Assassin & Diabolist       assassin, diabolist                            L2  2181  L15 336301
--   Mercenary Warrior          mercenary-fighter                              L2  1901  L15 300001
--   Monk & Summoner            warrior-monk, summoner                         L2  2301  L15 349001
--   Thief & Merchant           thief, merchant                                L2  1851  L15 326901
--   Soldier & Scholar          soldier, scholar                               L2  2001  L15 320001
--   Knight & Noble             knight, noble                                  L2  2201  L15 335501
--   Palladin                   palladin                                       L2  2401  L15 350001
--   Long Bowman & Squire       long-bowman, squire                            L2  2101  L15 323401
--   Priest (Light & Dark)      priest-of-light, priest-of-darkness            L2  1971  L15 346401
--   Psi-Mystic & Warlock       psi-mystic                                     L2  2101  L15 350401
--   Witch                      witch                                          L2  1871  L15 370201
--   Ranger, Psi-Healer         ranger, psi-healer, psychic-sensitive          L2  2061  L15 325901
--   Druid & Cobbler            druid                                          L2  1861  L15 324881
--   Vagabond/Peasant/Farmel    vagabond-peasant                               L2  1801  L15 290001
--   Mind Mage & Wizard         mind-mage, wizard                              L2  2241  L15 335921
--   Psi-Mystic & Warlock       warlock (as a DELTA, not frontmatter)          L2  2101  L15 350401
--
-- 15 TABLES, 15 LEVELS EACH, 225 NUMBERS, off Palladium Fantasy printed 336.
-- All 25 Palladium O.C.C.s in the catalog are covered with nothing left over.
-- The two names on the page with no row here are the Monk, which is
-- `warrior-monk`, and the Goblin Cobbler, which is not imported.
--
-- THE FOURTEEN R.C.C.s GET NOTHING, and that is correct rather than missing: a
-- race has no experience table, because experience comes from what you do. That
-- is exactly why the composition fix had to land first - a Knight's chart was
-- being dropped on every Palladium character in favour of the race's absence.
--
-- `xp_table` STORES THE LOWER BOUND of each level's band, which is what
-- `levelForXp` compares against: the printed "0,000-2,180" for level 1 becomes
-- 0, and "2,181-4,360" for level 2 becomes 2181.
--
-- READ OFF THE TEXT LAYER and checked three ways before being written: every
-- table has exactly 15 levels, every one starts at 0, and every level's low is
-- the PREVIOUS level's high plus one. That last check is the one with teeth -
-- the two numbers are printed separately, so they only agree if both were read
-- correctly. All 225 passed. Three cosmetic OCR artefacts were navigated rather
-- than corrected: "Vagabond/Peasant/Farmel" (a mis-set final r), "14272,881"
-- (a missing space before the Druid's level 14), and a stray "t" between two
-- tables.
--
-- THIS IS FIDELITY, NOT A BUG FIX. The house-rule default sits INSIDE the
-- book's range at every level checked - at 15 the book spans 290,001 to 370,201
-- and the default is 300,000 - so nobody was levelling at the wrong speed, they
-- were levelling at the average speed instead of their own class's. The spread
-- is real though: a Vagabond reaches 15 at 290,001 and a Witch at 370,201, a
-- 28% difference between the two classes that most deserve to differ.
--
-- THE WARLOCK IS THE ONE JUDGEMENT CALL. The catalog's `warlock` is the Rifts
-- Book of Magic printing and carries system: rifts, so giving it a Palladium
-- chart in its frontmatter would apply a Palladium number to a Rifts row. It
-- gets the figures as a DELTA instead, in the same "## Palladium Fantasy"
-- section that already records its money and its armour.
--
-- NAMED zz- ON PURPOSE. This rewrites class frontmatter, so it has to sort
-- after every script that writes those same rows - and
-- zz-canonicalise-class-skill-names.sql does. An add- prefix would have been
-- appended and then overwritten by three later scripts on a clean rebuild,
-- which is the trap that cost fix-long-bowman-armor its whole effect.
--
-- Guarded on the class having no xp_table yet, so re-running is a no-op.

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: assassin' || char(10), '---' || char(10) || 'id: assassin' || char(10) || 'xp_table: [0, 2181, 4361, 8721, 17101, 26201, 36301, 51401, 74501, 98601, 137701, 184801, 233001, 284201, 336301]' || char(10))
 WHERE class_id = 'assassin'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: diabolist' || char(10), '---' || char(10) || 'id: diabolist' || char(10) || 'xp_table: [0, 2181, 4361, 8721, 17101, 26201, 36301, 51401, 74501, 98601, 137701, 184801, 233001, 284201, 336301]' || char(10))
 WHERE class_id = 'diabolist'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mercenary-fighter' || char(10), '---' || char(10) || 'id: mercenary-fighter' || char(10) || 'xp_table: [0, 1901, 3801, 7601, 12001, 20001, 30001, 45001, 55001, 75001, 110001, 140001, 180001, 240001, 300001]' || char(10))
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: warrior-monk' || char(10), '---' || char(10) || 'id: warrior-monk' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 17001, 28001, 36001, 51001, 73001, 98001, 139001, 189001, 239001, 289001, 349001]' || char(10))
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: summoner' || char(10), '---' || char(10) || 'id: summoner' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 17001, 28001, 36001, 51001, 73001, 98001, 139001, 189001, 239001, 289001, 349001]' || char(10))
 WHERE class_id = 'summoner'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: thief' || char(10), '---' || char(10) || 'id: thief' || char(10) || 'xp_table: [0, 1851, 3701, 7401, 13001, 22001, 33001, 47001, 66001, 91401, 131501, 171601, 221701, 272801, 326901]' || char(10))
 WHERE class_id = 'thief'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: merchant' || char(10), '---' || char(10) || 'id: merchant' || char(10) || 'xp_table: [0, 1851, 3701, 7401, 13001, 22001, 33001, 47001, 66001, 91401, 131501, 171601, 221701, 272801, 326901]' || char(10))
 WHERE class_id = 'merchant'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: soldier' || char(10), '---' || char(10) || 'id: soldier' || char(10) || 'xp_table: [0, 2001, 4001, 8001, 14001, 22001, 32001, 47001, 67001, 92001, 120001, 150001, 200001, 265001, 320001]' || char(10))
 WHERE class_id = 'soldier'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: scholar' || char(10), '---' || char(10) || 'id: scholar' || char(10) || 'xp_table: [0, 2001, 4001, 8001, 14001, 22001, 32001, 47001, 67001, 92001, 120001, 150001, 200001, 265001, 320001]' || char(10))
 WHERE class_id = 'scholar'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: knight' || char(10), '---' || char(10) || 'id: knight' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 16501, 25001, 35001, 50001, 71001, 96501, 135501, 180501, 230501, 280501, 335501]' || char(10))
 WHERE class_id = 'knight'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: noble' || char(10), '---' || char(10) || 'id: noble' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 16501, 25001, 35001, 50001, 71001, 96501, 135501, 180501, 230501, 280501, 335501]' || char(10))
 WHERE class_id = 'noble'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: palladin' || char(10), '---' || char(10) || 'id: palladin' || char(10) || 'xp_table: [0, 2401, 4801, 9601, 17001, 28001, 38001, 53001, 75001, 100001, 140001, 190001, 240001, 290001, 350001]' || char(10))
 WHERE class_id = 'palladin'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: long-bowman' || char(10), '---' || char(10) || 'id: long-bowman' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 15401, 23401, 33401, 48401, 68401, 93401, 133401, 173401, 223401, 273401, 323401]' || char(10))
 WHERE class_id = 'long-bowman'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: squire' || char(10), '---' || char(10) || 'id: squire' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 15401, 23401, 33401, 48401, 68401, 93401, 133401, 173401, 223401, 273401, 323401]' || char(10))
 WHERE class_id = 'squire'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: priest-of-light' || char(10), '---' || char(10) || 'id: priest-of-light' || char(10) || 'xp_table: [0, 1971, 3841, 7641, 15841, 25401, 35801, 51201, 72401, 96601, 132201, 184601, 234801, 284201, 346401]' || char(10))
 WHERE class_id = 'priest-of-light'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: priest-of-darkness' || char(10), '---' || char(10) || 'id: priest-of-darkness' || char(10) || 'xp_table: [0, 1971, 3841, 7641, 15841, 25401, 35801, 51201, 72401, 96601, 132201, 184601, 234801, 284201, 346401]' || char(10))
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-mystic' || char(10), '---' || char(10) || 'id: psi-mystic' || char(10) || 'xp_table: [0, 2101, 4201, 8441, 17481, 25501, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 290201, 350401]' || char(10))
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: witch' || char(10), '---' || char(10) || 'id: witch' || char(10) || 'xp_table: [0, 1871, 3741, 8481, 16901, 24901, 36801, 54701, 75601, 100501, 140401, 190301, 250201, 300101, 370201]' || char(10))
 WHERE class_id = 'witch'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: ranger' || char(10), '---' || char(10) || 'id: ranger' || char(10) || 'xp_table: [0, 2061, 4121, 8241, 15101, 23101, 33101, 48201, 68301, 93401, 133501, 175601, 223701, 273801, 325901]' || char(10))
 WHERE class_id = 'ranger'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-healer' || char(10), '---' || char(10) || 'id: psi-healer' || char(10) || 'xp_table: [0, 2061, 4121, 8241, 15101, 23101, 33101, 48201, 68301, 93401, 133501, 175601, 223701, 273801, 325901]' || char(10))
 WHERE class_id = 'psi-healer'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psychic-sensitive' || char(10), '---' || char(10) || 'id: psychic-sensitive' || char(10) || 'xp_table: [0, 2061, 4121, 8241, 15101, 23101, 33101, 48201, 68301, 93401, 133501, 175601, 223701, 273801, 325901]' || char(10))
 WHERE class_id = 'psychic-sensitive'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: druid' || char(10), '---' || char(10) || 'id: druid' || char(10) || 'xp_table: [0, 1861, 3721, 7441, 14881, 23881, 34881, 48881, 68881, 92881, 124881, 166881, 212881, 272881, 324881]' || char(10))
 WHERE class_id = 'druid'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: vagabond-peasant' || char(10), '---' || char(10) || 'id: vagabond-peasant' || char(10) || 'xp_table: [0, 1801, 3601, 7201, 11001, 19001, 29001, 44001, 54001, 74001, 108001, 138001, 175001, 235001, 290001]' || char(10))
 WHERE class_id = 'vagabond-peasant'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mind-mage' || char(10), '---' || char(10) || 'id: mind-mage' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10))
 WHERE class_id = 'mind-mage'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: wizard' || char(10), '---' || char(10) || 'id: wizard' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10))
 WHERE class_id = 'wizard'
   AND instr(markdown, 'xp_table:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- **Money is 150 gold**, not 2D6x1000 credits.', '- **Money is 150 gold**, not 2D6x1000 credits.' || char(10) || '- **Experience** is the Psi-Mystic & Warlock table (printed 336): 2,101 for level 2, 350,401 for level 15. Recorded here rather than as `xp_table` because the class above is the Rifts printing.')
 WHERE class_id = 'warlock'
   AND instr(markdown, 'Psi-Mystic & Warlock table') = 0;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS classes_with_an_xp_table FROM imported_classes
 WHERE status = 'published' AND instr(markdown, char(10) || 'xp_table: [0, ') > 0;
SELECT count(*) AS rccs_that_wrongly_got_one FROM imported_classes
 WHERE instr(markdown, 'category: rcc') > 0 AND instr(markdown, 'xp_table:') > 0;
SELECT count(*) AS warlock_delta_recorded FROM imported_classes
 WHERE class_id = 'warlock'
   AND instr(markdown, 'Psi-Mystic & Warlock table') > 0
   AND instr(markdown, char(10) || 'xp_table:') = 0;
SELECT count(*) AS knight_and_noble_agree FROM imported_classes
 WHERE class_id IN ('knight', 'noble')
   AND instr(markdown, 'xp_table: [0, 2201, ') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE class_id IN ('assassin', 'diabolist', 'mercenary-fighter', 'warrior-monk', 'summoner', 'thief', 'merchant', 'soldier', 'scholar', 'knight', 'noble', 'palladin', 'long-bowman', 'squire', 'priest-of-light', 'priest-of-darkness', 'psi-mystic', 'witch', 'ranger', 'psi-healer', 'psychic-sensitive', 'druid', 'vagabond-peasant', 'mind-mage', 'wizard', 'warlock')
   AND instr(markdown, char(13)) > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-pf-experience-tables.sql');
