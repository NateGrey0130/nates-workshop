-- Experience ladders printed in their own books for twelve Coalition War
-- Campaign O.C.C.s and four Free Quebec O.C.C.s, which stored none.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~012-cwc-fq-xp-ladders.sql
--
-- THE DECISIONS. Nate, 2026-09-17 and 2026-09-26: a class carries the ladder
-- its own book prints for it, and a class whose book says "use X's experience
-- table" copies X's. ~012 and ~013-triax-xp-ladders.sql are one change in two
-- files, split so each file's read-backs stay short: d1-apply re-runs them as
-- ONE command line, and Windows refuses one much past 4,000 characters.
--
-- Each figure is the LOWER bound of each band. A lower bound printed inside
-- the band before it is stored as that band's top plus one, per
-- fix-nb-race-xp-ladders.sql and #1406.
--
-- COALITION WAR CAMPAIGN printed 224 (pdf page 225, cache p225, page_offset 1),
-- read off a 300 dpi render; the text layer agrees on every figure.
--   iss-peacekeeper: "ISS Peacekeeper, RPA Elite SAMAS Pilot"
--   iss-specter: "ISS Specter, CS Technical Officer, CS Military Specialist"
--   ntset-protector, cs-rcsg-scientist, iss-intel-specter: "NTSET
--     Protector/Hunter, CS RCSG Scientist, ISS Intel Specter"
--   ntset-psi-hound: "NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD
--     Specialist, CS Nautical Specialist". Level 6 prints 24,561 under level
--     5's top of 25,560 and level 15 prints 331,401 under level 14's top of
--     331,800; stored 25,561 and 331,801, exactly as vanguard-brawler (#1406).
--   psi-net-agent, cs-special-forces: "Psi-Net Agent, Special Forces"
--   cs-commando, cs-cyborg-strike-trooper: "CS Juicer, CS Commando, CS Strike
--     Cyborg" - the ladder coalition-juicer stores since ~010.
--   cs-rpa-fly-boy-ace, cs-ranger: "CS "Fly Boy" RPA, ISS Psi-Stalker, CS
--     Ranger/Scout". Its figures equal RUE's 'Borg ladder (combat-cyborg).
--
-- FREE QUEBEC printed 191 (pdf page 192, page_offset 1), the box headed
-- "Experience Points" under the adventure hooks, read off a 300 dpi render;
-- the PDF's text layer agrees. The survey said the book prints no experience
-- table because it searched for "Experience Table"; the box says "Experience
-- Points". Do not read it off the cache: p192 prints the Side Kick heading
-- above the Descended column's figures and drops the other two headings.
--   fq-descended-glitter-boy-pilot: "Descended Glitter Boy Pilot"
--   fq-glitter-girl-pilot: "Glitter "Girl" Pilot"
--   fq-side-kick-rpa, fq-gb-reloader: "Side Kick RPA & Reloader O.C.C."
--
-- NOT stored, and why:
--   cs-eod-specialist, cs-nautical-specialist - printed 224 names both in TWO
--     columns that disagree: "CS EOD Specialist, CS Nautical Specialist"
--     (0, 2,001, 4,001, 8,201 ... 329,401) and the Psi-Hound's column above
--     (0, 2,051, 4,101, 8,401 ... 331,401). Which one the book means is a
--     decision, not a transcription.
--   nmbyr-gorilla-man, tirrvol-sword-fist - settled in ~011: the D-Bee
--     Vagabond column names neither, and both always take an O.C.C.
--   fq-deep-intel-agent and the five fq-cyborg-* rows - the Free Quebec box
--     has no column for them and their entries name no table.
--
-- MECHANICS. One xp_table line straight after each class's single
-- "category: occ" line, guarded on no xp_table LINE yet, so a second run
-- changes nothing. No note on these classes said a ladder was not stored;
-- the Psi-Hound's gains one recording its two adjusted bounds. The ~ tier
-- sorts after every z- tier, so nothing rewrites these rows later.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'iss-peacekeeper'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'iss-specter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ntset-protector'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rcsg-scientist'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'iss-intel-specter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8401, 16801, 25561, 35801, 50401, 70801, 95401, 130801, 180401, 230801, 280401, 331801]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ntset-psi-hound'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'psi-net-agent'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-special-forces'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-commando'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-cyborg-strike-trooper'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rpa-fly-boy-ace'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cs-ranger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8401, 17501, 25601, 35701, 52801, 72901, 98501, 132501, 183501, 235001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'fq-descended-glitter-boy-pilot'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4501, 8801, 18001, 26001, 36301, 53501, 74501, 100001, 135001, 185501, 237501, 297501, 357501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'fq-glitter-girl-pilot'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1951, 3901, 7451, 14601, 21801, 30201, 40201, 53201, 73201, 103201, 138201, 190001, 242001, 292001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'fq-side-kick-rpa'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1951, 3901, 7451, 14601, 21801, 30201, 40201, 53201, 73201, 103201, 138201, 190001, 242001, 292001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'fq-gb-reloader'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- The Psi-Hound's note records the two adjusted bounds.
UPDATE imported_classes
   SET markdown = replace(markdown, 'extraction_notes: "Page span: the NTSET section opens', 'extraction_notes: "XP: stored 2026-09-26 as xp_table, printed 224''s column headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist, read off a render. It prints two lower bounds inside the band before (level 6 at 24,561 under level 5''s 16,801-25,560; level 15 at 331,401 under level 14''s top of 331,800); both are stored as the previous top plus one, 25,561 and 331,801, as vanguard-brawler stores the same column (#1406). Page span: the NTSET section opens'), updated_at = datetime('now')
 WHERE class_id = 'ntset-psi-hound' AND instr(markdown, 'extraction_notes: "Page span: the NTSET section opens') > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'peacekeeper' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('iss-peacekeeper') AND instr(markdown, char(10) || 'xp_table: [0, 1926, 3851, 7451, ') > 0 AND instr(markdown, ', 289001]' || char(10)) > 0;
SELECT 'specter' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('iss-specter') AND instr(markdown, char(10) || 'xp_table: [0, 2121, 4241, 8481, ') > 0 AND instr(markdown, ', 329961]' || char(10)) > 0;
SELECT 'protector' AS assertion, count(*) AS got, 3 AS want FROM imported_classes WHERE class_id IN ('ntset-protector', 'cs-rcsg-scientist', 'iss-intel-specter') AND instr(markdown, char(10) || 'xp_table: [0, 2141, 4281, 8561, ') > 0 AND instr(markdown, ', 341601]' || char(10)) > 0;
SELECT 'psihound' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ntset-psi-hound') AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8401, ') > 0 AND instr(markdown, ', 331801]' || char(10)) > 0;
SELECT 'psinet' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('psi-net-agent', 'cs-special-forces') AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 8801, ') > 0 AND instr(markdown, ', 345901]' || char(10)) > 0;
SELECT 'csjuicer' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('cs-commando', 'cs-cyborg-strike-trooper') AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, ') > 0 AND instr(markdown, ', 385001]' || char(10)) > 0;
SELECT 'flyboy' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('cs-rpa-fly-boy-ace', 'cs-ranger') AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 342401]' || char(10)) > 0;
SELECT 'fqdescended' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('fq-descended-glitter-boy-pilot') AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8401, ') > 0 AND instr(markdown, ', 345001]' || char(10)) > 0;
SELECT 'fqgirl' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('fq-glitter-girl-pilot') AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4501, 8801, ') > 0 AND instr(markdown, ', 357501]' || char(10)) > 0;
SELECT 'fqsidekick' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('fq-side-kick-rpa', 'fq-gb-reloader') AND instr(markdown, char(10) || 'xp_table: [0, 1951, 3901, 7451, ') > 0 AND instr(markdown, ', 292001]' || char(10)) > 0;
SELECT 'psihound note' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'ntset-psi-hound' AND instr(markdown, 'as vanguard-brawler stores the same column') > 0;
SELECT 'one xp line' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~012-cwc-fq-xp-ladders.sql');
