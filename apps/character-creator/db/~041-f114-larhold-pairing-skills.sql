-- BOOK-INGEST-AUDIT F114: a paired Larhold kept its whole R.C.C. skill list,
-- where the book keeps a few. Taken 2026-09-27 as the race-side opt-in the
-- finding proposes; F11's union default is unchanged for every other race.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~041-f114-larhold-pairing-skills.sql
--
-- The number ~041 was reserved for this script by the coordinating session
-- on 2026-09-27 (another session holds ~040), because D1 is applied before
-- the merge and data_script_runs records the filename.
--
-- WHAT. js/parser.js combineClasses now reads a race's
-- pairing_skills: [{ name, base?, note? }] and, in a pairing, carries only
-- those of the race's named occ_skills (with the key's base and note laid
-- over the race's entry) instead of the whole list; the race's choice groups
-- do not carry. Set on larhold-barbarian:
--   Riding: War Bison  base 50
--       South America 2 printed 186: "In addition to the specific O.C.C.
--       skills, all Larhold will have Riding: War Bison (same basic level as
--       Horsemanship at +10%), and W.P.: Archery and Targeting." 50 is the
--       catalog row's own base, which #1385 set from this sentence
--       (Horsemanship: General 40 + 10); the R.C.C.'s +20 (70) is the
--       no-O.C.C. figure. An occupation granting it higher still wins (the
--       Larhold Shaman's 60).
--   W.P. Archery
--       The same sentence; stored under the catalog name, as the race's entry is.
--   Language: Larhold  (the race's 98)
--       NOT named by the sentence. Kept on Nate's word, 2026-09-27: a census
--       of the 189 legal Larhold pairings on a production snapshot found 188
--       would otherwise lose the native tongue, and only 89 of those
--       occupations grant a generic Language: Native Tongue.
--
-- CENSUS, same snapshot and day: the 189 pairings average 23.74 fixed-skill
-- entries today and 17.33 with this three-skill key; 111 of them held two
-- named Hand to Hand skills and 1 does with it; none loses Language: Larhold.
--
-- NOTE. The Barbarian's SKILLS note is rewritten past tense.
--
-- MECHANICS. Each statement is a replace() guarded on its old text being
-- present, the key insert also on no pairing_skills line yet, so a second run
-- changes nothing. updated_at is stamped so the /classes ETag moves.

-- larhold-barbarian key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms, clergy, psychic, optional] }' || char(10), char(10) || 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms, clergy, psychic, optional] }' || char(10) || 'pairing_skills: [{ name: "Riding: War Bison", base: 50, note: "Beside an O.C.C.: the Horsemanship +10% base every Larhold keeps (printed 186), without the R.C.C. +20%." }, { name: "W.P. Archery" }, { name: "Language: Larhold" }]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-barbarian'
   AND instr(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms, clergy, psychic, optional] }' || char(10)) > 0
   AND instr(markdown, char(10) || 'pairing_skills:') = 0;

-- larhold-barbarian skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'every Larhold has Riding: War Bison and W.P. Archery; in a pairing the race''s whole R.C.C. skill list unions onto the O.C.C.''s, which grants more than that sentence names - recorded, not modelled.', 'every Larhold has Riding: War Bison and W.P. Archery. pairing_skills keeps those two in a pairing - War Bison at 50, the catalog base that sentence defines (Horsemanship +10), without the R.C.C. +20 - and Language: Larhold 98, a native tongue the sentence does not name, kept on Nate''s word; the rest of the R.C.C. list, its choice groups included, is the kit of a Larhold who takes no O.C.C. (BOOK-INGEST-AUDIT F114, taken 2026-09-27). Until then the whole list unioned onto the O.C.C.''s.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-barbarian'
   AND instr(markdown, 'every Larhold has Riding: War Bison and W.P. Archery; in a pairing the race''s whole R.C.C. skill list unions onto the O.C.C.''s, which grants more than that sentence names - recorded, not modelled.') > 0;

-- Readbacks: each must return got = want.
SELECT 'larhold key' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'larhold-barbarian' AND instr(markdown, char(10) || 'pairing_skills: [{ name: "Riding: War Bison", base: 50,') > 0 AND instr(markdown, '{ name: "Language: Larhold" }]' || char(10)) > 0;
SELECT 'larhold note' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'larhold-barbarian' AND instr(markdown, 'pairing_skills keeps those two in a pairing') > 0 AND instr(markdown, 'whole R.C.C. skill list unions onto') = 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~041-f114-larhold-pairing-skills.sql');
