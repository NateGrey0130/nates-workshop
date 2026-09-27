-- BOOK-INGEST-AUDIT F111, the Larhold part, taken as a RACE-side key on
-- Nate's word (2026-09-27): four races whose own book prints their P.P.E. as
-- the figure for a character who does NOT take a magic (or clergy) O.C.C. now
-- say so, and yield it to such an occupation's stated P.P.E. in a pairing.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~032-f111-race-yields-ppe.sql
--
-- WHAT. js/parser.js combineClasses now reads a race's
-- yields_to_occupation: { <ppe_base|starting_money>: [<occ groups>] } and lets
-- an occupation of a named group win that key when it states one. Set on:
--   larhold-barbarian  ppe_base [magic]; starting_money [all five groups]
--       South America 2 printed 186: P.P.E. 3D6 beside Magic Powers: None
--       unless a magical O.C.C. is selected. Its 1D6x1000 is in the R.C.C.'s
--       own Other Equipment line, and the O.C.C.s paragraph on the same page
--       has a Larhold take an O.C.C. in place of the basic R.C.C., keeping
--       only War Bison riding and W.P. Archery - nothing there limits that to
--       magic, so the money yields to every group. The Larhold Shaman prints
--       its own 2D6x1000 (printed 190).
--   amphib             ppe_base [magic]
--       Underseas printed 99: P.P.E.: 3D6 unless a magic O.C.C.
--   human              ppe_base [magic, clergy]
--   elf                ppe_base [magic, clergy]
--       Palladium Fantasy printed 289 and 291: 2D6 (5D6) for most adults,
--       unless a mage or clergy O.C.C. Clergy is named by the book, so the
--       priests, the druid and the warrior monk (printed 71: a member of the
--       clergy) yield too.
--
-- NOT keyed: rifts-cyclops, rifts-elf and true-atlantean, whose books ADD the
-- race's P.P.E. to a mage's; godling, true-inca and draconid, which print a
-- mage figure of their own; felinoid, which says magic only with a magic
-- O.C.C. but states no P.P.E.
--
-- CENSUS, against a production snapshot of 525 published classes taken
-- 2026-09-27: 37,024 legal same-system pairings, race variants included.
-- The key moves 298 of them and no other: larhold-barbarian 65 P.P.E. and 154
-- money, amphib 65 P.P.E., human 7 and elf 7 P.P.E. No moved P.P.E. lands
-- below the race's own figure.
--
-- NOTES. The Barbarian's pool and money notes, the Shaman's money and warning
-- notes, the human's and elf's P.P.E. notes and the amphib's P.P.E.
-- restriction are rewritten past-tense.
--
-- MECHANICS. Each statement is a replace() guarded on its old text being
-- present - and each key insert also on no yields_to_occupation line yet,
-- because its old text survives inside the new - so a second run changes
-- nothing. updated_at is stamped so the /classes ETag moves.

-- larhold-barbarian key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'starting_money: "1d6x1000"' || char(10), char(10) || 'starting_money: "1d6x1000"' || char(10) || 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms, clergy, psychic, optional] }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-barbarian'
   AND instr(markdown, char(10) || 'starting_money: "1d6x1000"' || char(10)) > 0
   AND instr(markdown, char(10) || 'yields_to_occupation:') = 0;

-- larhold-barbarian pool note
UPDATE imported_classes
   SET markdown = replace(markdown, 'no hit points. P.P.E. 3D6. Horror Factor 8 stored', 'no hit points. P.P.E. 3D6, the figure for a Larhold with no magical O.C.C. (printed 186 beside Magic Powers: None unless a magical O.C.C. is selected); yields_to_occupation gives a magic occupation''s stated P.P.E. the pairing (BOOK-INGEST-AUDIT F111, taken 2026-09-27), and until then this 3D6 won every pairing. Horror Factor 8 stored'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-barbarian'
   AND instr(markdown, 'no hit points. P.P.E. 3D6. Horror Factor 8 stored') > 0;

-- larhold-barbarian money note
UPDATE imported_classes
   SET markdown = replace(markdown, 'In a pairing the race''s starting_money wins over the occupation''s, so a Larhold Shaman shows this figure rather than its own 2D6x1000.', 'It is the Barbarian R.C.C.''s own kit: the O.C.C.s paragraph on printed 186 has a Larhold take an O.C.C. in place of the basic R.C.C., keeping only War Bison riding and W.P. Archery, and limits that to no kind of O.C.C. So yields_to_occupation gives every occupation group''s stated money the pairing (BOOK-INGEST-AUDIT F111, taken 2026-09-27), and a Larhold Shaman starts with its own 2D6x1000. Until then this figure won every pairing.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-barbarian'
   AND instr(markdown, 'In a pairing the race''s starting_money wins over the occupation''s, so a Larhold Shaman shows this figure rather than its own 2D6x1000.') > 0;

-- larhold-shaman money note
UPDATE imported_classes
   SET markdown = replace(markdown, 'In a pairing with the Larhold R.C.C., which states 1D6x1000, the race''s figure wins.', 'In a pairing with the Larhold R.C.C., which states 1D6x1000, this figure wins: that race yields its money to every occupation through yields_to_occupation (BOOK-INGEST-AUDIT F111, taken 2026-09-27). Until then the race''s figure won.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-shaman'
   AND instr(markdown, 'In a pairing with the Larhold R.C.C., which states 1D6x1000, the race''s figure wins.') > 0;

-- larhold-shaman warning note
UPDATE imported_classes
   SET markdown = replace(markdown, 'mdc_base and starting_money are discarded as the book intends or harmlessly (above). ppe_base is NOT harmless: the Larhold R.C.C. states P.P.E. 3D6 (printed 186, the figure for a Larhold with no magical O.C.C.), so a Larhold shaman composes to 3D6 P.P.E. instead of this page''s 3D6x10 plus P.E., +3D6 per level. Recorded, not worked around; a human shaman (no race) gets the printed figure. Not stored differently; see BOOK-INGEST-AUDIT.md F111 (it also covers the 2D6x1000 starting money the race''s 1D6x1000 replaces).', 'mdc_base is discarded as the book intends (above). ppe_base and starting_money are kept in a pairing with the Larhold R.C.C.: that race states P.P.E. 3D6 as the figure for a Larhold with no magical O.C.C. (printed 186) and carries yields_to_occupation, so a Larhold shaman composes to this page''s 3D6x10 plus P.E., +3D6 per level, and its 2D6x1000 (BOOK-INGEST-AUDIT F111, taken 2026-09-27). The key sits on the race rather than here because this class is open to every race, and an overrides_race here would also have replaced the P.P.E. of races whose book adds theirs to a mage''s. Any other race that states its own P.P.E. or money and carries no such key keeps it; a human shaman (no race) gets the printed figures. Until then a Larhold shaman composed to the race''s 3D6 and 1D6x1000.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-shaman'
   AND instr(markdown, 'ppe_base is NOT harmless: the Larhold R.C.C. states P.P.E. 3D6') > 0;

-- amphib key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'ppe_base: "3d6"' || char(10), char(10) || 'ppe_base: "3d6"' || char(10) || 'yields_to_occupation: { ppe_base: [magic] }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, char(10) || 'ppe_base: "3d6"' || char(10)) > 0
   AND instr(markdown, char(10) || 'yields_to_occupation:') = 0;

-- amphib restriction
UPDATE imported_classes
   SET markdown = replace(markdown, '"P.P.E. is 3D6 unless the character takes a magic O.C.C."', '"P.P.E. is 3D6 unless the character takes a magic O.C.C., whose own P.P.E. then applies (printed 99; yields_to_occupation, BOOK-INGEST-AUDIT F111)."'),
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, '"P.P.E. is 3D6 unless the character takes a magic O.C.C."') > 0;

-- human key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'ppe_base: "2d6"' || char(10), char(10) || 'ppe_base: "2d6"' || char(10) || 'yields_to_occupation: { ppe_base: [magic, clergy] }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'human'
   AND instr(markdown, char(10) || 'ppe_base: "2d6"' || char(10)) > 0
   AND instr(markdown, char(10) || 'yields_to_occupation:') = 0;

-- human note
UPDATE imported_classes
   SET markdown = replace(markdown, 'the mage-or-clergy exception is NOT modelled: composition keeps the race''s pool, so a human paired with an occupation that states its own P.P.E. (the wizard, summoner, diabolist and witch) composes to this 2D6. An occupation takes its own figure over a race''s only when it lists ppe_base in overrides_race, and none of these does; see BOOK-INGEST-AUDIT F111 (2026-09-27), which declined making that the general rule. Until then this note said the occupation''s figure won, which was never true.', 'the mage-or-clergy exception is modelled by yields_to_occupation: { ppe_base: [magic, clergy] } (BOOK-INGEST-AUDIT F111, taken 2026-09-27): a magic or clergy O.C.C. that states its own P.P.E. composes to that figure, and every other occupation keeps this 2D6. Until then the race''s 2D6 won every pairing, and before PR #1467 this note said the reverse.'),
       updated_at = datetime('now')
 WHERE class_id = 'human'
   AND instr(markdown, 'the mage-or-clergy exception is NOT modelled') > 0;

-- elf key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'ppe_base: "5d6"' || char(10), char(10) || 'ppe_base: "5d6"' || char(10) || 'yields_to_occupation: { ppe_base: [magic, clergy] }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elf'
   AND instr(markdown, char(10) || 'ppe_base: "5d6"' || char(10)) > 0
   AND instr(markdown, char(10) || 'yields_to_occupation:') = 0;

-- elf note
UPDATE imported_classes
   SET markdown = replace(markdown, '1D6x10 for elven children till about age 16". The child figure is not a player character.', '1D6x10 for elven children till about age 16". The child figure is not a player character. The mage-or-clergy exception is modelled by yields_to_occupation: { ppe_base: [magic, clergy] } (BOOK-INGEST-AUDIT F111, taken 2026-09-27): a magic or clergy O.C.C. that states its own P.P.E. composes to that figure, and every other occupation keeps this 5D6. Until then the race''s 5D6 won every pairing.'),
       updated_at = datetime('now')
 WHERE class_id = 'elf'
   AND instr(markdown, '1D6x10 for elven children till about age 16". The child figure is not a player character.') > 0
   AND instr(markdown, 'The mage-or-clergy exception is modelled') = 0;

-- Read the result back: each key once, each new note present, each old one gone.
SELECT 'larhold key' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'larhold-barbarian' AND instr(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms, clergy, psychic, optional] }' || char(10)) > 0;
SELECT 'larhold notes' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'larhold-barbarian' AND instr(markdown, 'the figure for a Larhold with no magical O.C.C. (printed 186 beside') > 0 AND instr(markdown, 'It is the Barbarian R.C.C.''s own kit') > 0 AND instr(markdown, 'shows this figure rather than its own 2D6x1000') = 0;
SELECT 'shaman notes' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'larhold-shaman' AND instr(markdown, 'this figure wins: that race yields its money') > 0 AND instr(markdown, 'The key sits on the race rather than here') > 0 AND instr(markdown, 'ppe_base is NOT harmless') = 0;
SELECT 'amphib key and restriction' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'amphib' AND instr(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic] }' || char(10)) > 0 AND instr(markdown, 'whose own P.P.E. then applies (printed 99') > 0;
SELECT 'human key and note' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'human' AND instr(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic, clergy] }' || char(10)) > 0 AND instr(markdown, 'the mage-or-clergy exception is NOT modelled') = 0;
SELECT 'elf key and note' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'elf' AND instr(markdown, char(10) || 'yields_to_occupation: { ppe_base: [magic, clergy] }' || char(10)) > 0 AND instr(markdown, 'The mage-or-clergy exception is modelled') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~032-f111-race-yields-ppe.sql');
