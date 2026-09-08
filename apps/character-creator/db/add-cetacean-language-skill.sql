-- One skill row: the language of dolphins and whales.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-cetacean-language-skill.sql
--
-- WHY THIS IS NOT IN add-underseas-skills.sql, which took that book's skills
-- chapter: the chapter on printed 210-213 does not define it. Cetacean speech
-- is described on printed 75-76, in the middle of the Dolphins & Cetaceans
-- chapter, under the heading "Dolphin Speak" - prose about how the language
-- works rather than a skill entry with a base percentage. The skills pass read
-- the chapter that announces itself as the skill list and correctly found
-- nothing here.
--
-- WHAT FORCED IT: seven Underseas classes grant this language by name and the
-- catalog had no row for it. The three Pneuma-Biforms, the Dolphin R.C.C., the
-- Killer Whale, the Sperm Whale and the Humpback Whale all print a line like
-- "Dolphin/Whale Language 98%" in their own skill lists. Without a row, each
-- of those grants resolves to nothing.
--
-- THE BOOK STATES NO LEARNABLE PERCENTAGE, only 98% for a native speaker, over
-- and over, in each class that grants it. The base and per-level step here
-- follow the catalog's other named languages - Language: Dragonese, Language:
-- Gobblely and the rest are all 50% +5% - because that is what the column
-- means and a row has to hold something. Every class that grants it states
-- base 98 explicitly, so no character is affected by the figure chosen here;
-- it governs only a character who somehow takes the language as a related or
-- secondary skill.
--
-- AND PRINTED 76 SAYS THAT SHOULD ESSENTIALLY NEVER HAPPEN. It states that no
-- surface dweller has managed to speak to cetaceans in the dolphin/whale
-- language, and that magic and telepathy are far easier. That is a G.M. rule
-- rather than a column - the schema has no "this row is unlearnable by most
-- species" - so it is in the note, where a player picking the skill will read
-- it.
--
-- NAMING follows the catalog's Language: prefix and uses the spelling the
-- class lists use, which is "Dolphin/Whale". Printed 76 also calls it "the
-- dolphin/whale language" in prose, so the two agree.

INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Language: Dolphin/Whale', 'Communications', 50, 5,
 'The language of dolphins, porpoises and whales - clicks, chirps, chattering, grunts, groans, honks, humming, squeals, snorts and whistles, high-pitched among dolphins and porpoises and deeper and more resonant in whales. THE BOOK GIVES NO LEARNABLE PERCENTAGE: every class that grants it grants it at 98%, as a native speaker, and printed 76 states that no surface dweller has ever managed to speak it - magic and telepathy are far easier. The best humans have managed is rudimentary impressions of mood rather than words. The 50% +5% here is the catalog''s standard for a named language and applies only to a character taking this as a related or secondary skill, which the book effectively rules out for a non-cetacean.',
 'import', 'Rifts World Book 7: Underseas p.75-76')
ON CONFLICT(name) DO NOTHING;

SELECT name, category, base, per_level FROM skills WHERE name = 'Language: Dolphin/Whale';
SELECT COUNT(*) AS total_skills FROM skills;

INSERT INTO data_script_runs (filename) VALUES ('add-cetacean-language-skill.sql');
