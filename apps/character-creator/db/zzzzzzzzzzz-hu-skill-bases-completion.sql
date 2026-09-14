-- The Heroes Unlimited percentages still missing after the second extraction,
-- and the languages, which no pass had looked at.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzz-hu-skill-bases-completion.sql
--
-- `BOOK-INGEST-AUDIT` F83, third pass. The first pass lost eleven skills, the
-- second recovered them (zzzzzzzz-hu-skill-system-bases-2.sql, which records
-- that bug in its own header), and this one was written only because the
-- READER was rebuilt from scratch and made to prove itself against what already
-- shipped before it was allowed to report anything new.
--
-- THE VALIDATION IS THE WHOLE REASON TO BELIEVE THESE FIVE ROWS. The new reader
-- reproduces all 59 existing overrides exactly - every one reached, every base
-- and per-level matching the page, and none of them contradicted. A reader that
-- finds new disagreements while losing old ones is finding its own bugs. Four
-- earlier drafts of it did exactly that, and each loss is written up below.
--
-- ===================================================================
-- WHY FOUR MORE PASSES WERE NEEDED, WHICH IS THE PART WORTH KEEPING
-- ===================================================================
--
-- F83 recorded two reading traps. There are more, and every one of them is
-- silent in the same direction: a missing override leaves the CATALOG's number
-- standing and nothing anywhere reports it.
--
-- 1. THE MARKER IS SPELLED FIVE WAYS on printed 30-36. Censused, not assumed:
--
--        68  Base Skill:          1  Base. Skill:    (Basic Mechanics, p.32)
--         2  Base Skill is        1  Basic Skill:    (Robot Mechanics, p.32)
--         1  base skill  (lower case)
--
--    A pattern anchored on `Base Skill:` alone walks past four entries. Basic
--    Mechanics is one of them and it is one of the rows below.
--
-- 2. A STOP LIST OF SINGLE WORDS DOES NOT CLOSE F83's WRAP TRAP. Pathology's
--    figure sits on a line reading "Chemistry. Base Skill: 45% +5% per level of
--    experience." - a line-initial `Name:` whose name is "Chemistry. Base
--    Skill". It matches a run-in heading perfectly, steals the percentage, and
--    Pathology drops out. This reader reproduced that failure before a rule
--    rejecting a name containing a full stop followed by a space was added.
--
-- 3. A LIST INTRO IS NOT A HEADING EITHER. "Areas of training/study include:"
--    on p.33 took Medical Doctor's number the same way. The rule that separates
--    them is Title Case: a run-in heading here is a skill's NAME.
--
-- 4. HEADINGS USE AN EM DASH - `Mathematics - Basic`, `Navigation - Space`,
--    `Chemistry - Analytical` - and one of them OCRs as two dash characters. A
--    charset without them folds the entry into its neighbour.
--
-- 5. ONE OCR FIGURE IS SIMPLY WRONG. Land Navigation reads `40% +49%` in the
--    cache. Printed 31 was rendered at 260 dpi and read: it says `40% + 4%`.
--    The base was right and the per-level was not, which is the direction a
--    count never catches.
--
-- ===================================================================
-- THE FIVE SKILLS
-- ===================================================================
--
-- Every one was read off a rendered page, not off the cache alone. Basic
-- Mechanics, Medical Doctor and Land Navigation were rendered because their
-- markers were mangled; Pathology because its number had been stolen; and
-- Impersonation because the book states it in prose rather than in the usual
-- form.
--
-- TWO OF THEM PRINT TWO PERCENTAGES, and the catalog already has a convention
-- for that which is followed here rather than invented: `base` carries the
-- FIRST number and `note` carries both. Rifts' own rows do this - the catalog's
-- `Impersonation` note reads `30%/16%+4%` with base 30, and its `Medical
-- Doctor` note reads `60%/50% - first number is diagnostic ability, second is
-- treatment ability` with base 60.
--
--   Impersonation    p.31   40%/20% +4%   catalog 30/4   "The Base Skill is 40%
--                                                        to impersonate general
--                                                        personnel and 20% to
--                                                        impersonate a specific
--                                                        individual"
--   Land Navigation  p.31   40% +4%       catalog 36/4   cache says +49%
--   Basic Mechanics  p.32   40% +4%       catalog 30/5   marker is `Base. Skill:`
--   Medical Doctor   p.33   70/60% +3%    catalog 60/5   diagnose / treat
--   Pathology        p.33   45% +5%       catalog 40/5   number was stolen
--
-- ===================================================================
-- AND THE LANGUAGES, WHICH ARE A RULE RATHER THAN FIVE TRANSCRIPTIONS
-- ===================================================================
--
-- Printed 35 gives ONE figure for the whole family: "Language: Characters with
-- a language skill can understand, speak, write and read in a language other
-- than his/her native tongue ... Base Skill: 55% +5% per level of experience."
-- The catalog holds 50%/+5 for most of its language rows, 40% for two and 45%
-- for one. So every language an HU character picks arrives five to fifteen
-- points light, and the education classes' Language Program is a choice group,
-- which is exactly the case this table was built for.
--
-- Written as ONE set-based statement rather than 23 transcriptions, because the
-- book states a rule and transcribing it 23 times would invite 23 chances to
-- differ from it.
--
-- TWO EXCLUSIONS, both deliberate:
--
--   * `Language: Native Tongue` (98%/+0) - the book's sentence says "a language
--     OTHER than his/her native tongue", so this row is outside the rule it
--     states. The education classes grant it as a named absolute at 98 anyway.
--   * `Language: All (magical)` (98%/+0) - a magic effect, not a learned skill.
--
-- LITERACY IS DELIBERATELY NOT TOUCHED, and this is a decision rather than an
-- omission. Heroes Unlimited has no separate literacy skill: its Language skill
-- covers read and write in the same sentence. The catalog's six `Literacy:`
-- rows are a Palladium distinction, and giving them 55% would be inventing a
-- rule the book does not state. The classes that grant `Literacy: Native
-- Language` do it as a named absolute at 98, which is unaffected either way.
--
-- THE PALLADIUM-WORLD LANGUAGES ARE INCLUDED ANYWAY - Dragonese, Gargoyle,
-- Brodkil, the Trade tongues. A Heroes Unlimited character has no business
-- taking Dragonese, but that is a question about what the Language Program
-- OFFERS, not about what the skill is worth if taken, and answering it here
-- would hide it. The override makes nothing worse and keeps the rule whole.
--
-- Guarded on the primary key, so re-running is a no-op.
-- Sorts LAST of all data scripts, so its assertions read the finished table.

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Impersonation', 'heroes-unlimited', 40, 4,
       '40%/20% +4% - 40% to impersonate general personnel, 20% to impersonate a specific individual. Base carries the first number, as the catalog row does.',
       'Revised Heroes Unlimited p.31'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Impersonation');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Land Navigation', 'heroes-unlimited', 40, 4,
       'The OCR cache reads +49%; printed 31 rendered at 260 dpi says 40% + 4%.',
       'Revised Heroes Unlimited p.31'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Land Navigation');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Basic Mechanics', 'heroes-unlimited', 40, 4,
       'Printed 32 spells the marker Base. Skill: with a full stop, which is why no earlier pass found it.',
       'Revised Heroes Unlimited p.32'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Basic Mechanics');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Medical Doctor', 'heroes-unlimited', 70, 3,
       '70/60% +3% - printed 33 states the first percentile is the ability to diagnose a problem and the second the ability to successfully treat it. Base carries the first number, as the catalog row does.',
       'Revised Heroes Unlimited p.33'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Medical Doctor');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Pathology', 'heroes-unlimited', 45, 5,
       'Printed 33. Its figure shares a line with the Requirements sentence, which is why an earlier pass lost it.',
       'Revised Heroes Unlimited p.33'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Pathology');

-- Every LEARNED language, from the one rule printed 35 states.
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT name, 'heroes-unlimited', 55, 5,
       'Printed 35 gives one figure for any language other than the native tongue: 55% +5% per level.',
       'Revised Heroes Unlimited p.35'
  FROM skills
 WHERE name LIKE 'Language: %'
   AND name NOT IN ('Language: Native Tongue', 'Language: All (magical)');

-- ASSERTIONS.

SELECT 'the five point corrections landed' AS assertion, count(*) AS got, 5 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name IN ('Impersonation', 'Land Navigation', 'Basic Mechanics',
                      'Medical Doctor', 'Pathology');

SELECT 'every learned language carries the rule' AS assertion, count(*) AS got, 0 AS want
  FROM skills s
 WHERE s.name LIKE 'Language: %'
   AND s.name NOT IN ('Language: Native Tongue', 'Language: All (magical)')
   AND NOT EXISTS (SELECT 1 FROM skill_system_bases b
                    WHERE b.system = 'heroes-unlimited' AND b.skill_name = s.name
                      AND b.base = 55 AND b.per_level = 5);

-- The two exclusions are exclusions, not oversights. If either ever gains a
-- row, somebody decided something and this assertion is where they will notice.
SELECT 'the native tongue and the magical language have no row' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name IN ('Language: Native Tongue', 'Language: All (magical)');

SELECT 'and no literacy row was invented' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name LIKE 'Literacy:%';

-- Every row still names a real skill, and none of them merely restates the
-- catalog. Both are re-asserted over the WHOLE table rather than over the rows
-- this file adds, because that is the property that matters and this file is
-- the last data script to run.
SELECT 'every override names a real skill' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases b LEFT JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited' AND s.name IS NULL;

SELECT 'none restates the catalog it overrides' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases b JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited' AND b.base = s.base AND b.per_level = s.per_level;

-- The four read off a rendered page, spelled out so a silent re-extraction
-- cannot quietly change them.
SELECT 'Basic Mechanics is 40%/+4 (printed 32)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Basic Mechanics' AND base = 40 AND per_level = 4;

SELECT 'Land Navigation is 40%/+4, not +49 (printed 31)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Land Navigation' AND base = 40 AND per_level = 4;

SELECT 'Medical Doctor is 70%/+3, the diagnose half (printed 33)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Medical Doctor' AND base = 70 AND per_level = 3;

SELECT 'Pathology is 45%/+5 (printed 33)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Pathology' AND base = 45 AND per_level = 5;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzz-hu-skill-bases-completion.sql');
