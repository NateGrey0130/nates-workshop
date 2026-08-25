-- The four skills Rifts World Book Ten: Juicer Uprising adds that the catalog
-- does not already hold. Read from the book's own authority table, the
-- "Alphabetical List of New Skills by Category" on printed page 64, with the
-- descriptions on printed 65-66.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-juicer-uprising-skills.sql
--
-- The book has a text layer; these were read with scripts/read-columns.py and
-- transcribed, not OCR'd and not inferred. Printed-to-PDF offset is ZERO in
-- this book, verified against three folios.
--
-- FOUR OF TWELVE. The book's list names twelve new skills. EIGHT OF THEM ARE
-- ALREADY IN THE CATALOG, because Rifts Ultimate Edition absorbed them into
-- its own skill list a decade later and the RUE import brought them in:
--
--   book name                          catalog row                 base/level
--   Communications: Performance        Performance                 30 / 5
--   Espionage: Interrogation Tech.     Interrogation               30 / 5
--   Medical: Juicer Technology         Juicer Technology           40 / 5
--   Piloting: Flight System Combat     Flight System Combat        40 / 5
--   Piloting: Jump Bike Combat         Jump Bike Combat            45 / 5
--   Rogue: Gambling (Standard)         Gambling (Standard)         30 / 5
--   Rogue: Gambling (Dirty Tricks)     Gambling (Dirty Tricks)     20 / 4
--   Technical: Juicer Lore             Lore: Juicers               30 / 5
--
-- Seven of those eight match the book's printed figures exactly. The only
-- disagreement is Gambling (Standard): this book prints 30% +4% per level and
-- the catalog holds 30% +5%, from RUE p.302-303. RUE is the later book and
-- wins; the losing figure is recorded in the note below rather than applied,
-- which is this repo's standing rule for a book disagreeing with a book.
--
-- Re-inserting any of the eight under the book's own spelling would have
-- manufactured duplicates - characters reference skills BY NAME - which is
-- the lesson add-rue-skills-batch.sql was written around. They are left alone.
--
-- Note the catalog's Lore naming: it files these as "Lore: X", so the book's
-- "Juicer Lore" is the existing "Lore: Juicers" and not a gap.
--
-- CONVENTIONS, taken from the catalog rather than the book:
--   - base 0 / per_level 0 means non-percentile. Deadball, Murderthon and
--     W.P. Deadball print no percentage at all - they are pure bonus skills,
--     the Boxing/Wrestling shape.
--   - W.P.s use the single 'Weapon Proficiencies' category, not the book's
--     Ancient/Modern split.
--   - DICE-VALUED bonuses go in the note, never in `bonuses` - that column
--     holds integers, and Boxing's "Also +3D6 S.D.C." is the precedent. Every
--     one of these four grants S.D.C. and three grant Speed, all as dice.
--   - systems stays NULL: skills are deliberately cross-system.
--
-- W.P. Deadball straddles a page break - its name and first clause are on
-- printed 66 and the rest of the sentence is on printed 67. Both halves were
-- read; a row whose description stops mid-sentence is the failure mode the
-- book-survey skill warns about.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: ON CONFLICT(name) DO NOTHING, and every UPDATE guards itself.

INSERT INTO skills (name, category, base, per_level, note, bonuses, source, source_book) VALUES
('Deadball', 'Physical', 0, 0,
 'Also +1D6 to Spd and +2D4 S.D.C. A character with this skill automatically knows W.P. Deadball and the rules of the game. Juicer Uprising p.65.',
 '{"combat":{"initiative":1,"dodge":1,"roll":1}}',
 'import', 'Rifts World Book 10: Juicer Uprising p.64-66'),
('Juicer Football', 'Physical', 32, 4,
 'Also +1D4 to Spd and +3D6 S.D.C. Body Block/Tackle knocks an opponent down - 90% if the target is smaller, 60% at the same weight, 50% up to 50% larger, 20% if 100% larger, no chance beyond that; the tackled person loses initiative and one melee action and takes 1D4 S.D.C. plus P.S. bonus per tackler. The book says this skill is not recommended for ordinary humans. Juicer Uprising p.65.',
 '{"attributes":{"PS":1,"PE":1},"combat":{"roll":1}}',
 'import', 'Rifts World Book 10: Juicer Uprising p.64-66'),
('Murderthon', 'Physical', 0, 0,
 'Also +2D6 to Spd and +2D4 S.D.C. Teaches the rules and combat maneuvers of the game. Juicer Uprising p.65.',
 '{"combat":{"strike":1,"dodge":1,"roll":1}}',
 'import', 'Rifts World Book 10: Juicer Uprising p.64-66'),
('W.P. Deadball', 'Weapon Proficiencies', 0, 0,
 'Throwing the spiked, ricocheting deadball. The character can strike a target by ricocheting the ball off walls, ceilings and floors: a called shot at -1 for every ricochet needed. The ricocheting ball is very hard to parry or dodge - the victim is -2 to dodge, and a further -1 for every ricochet beyond the first. Juicer Uprising p.66.',
 NULL,
 'import', 'Rifts World Book 10: Juicer Uprising p.64-66')
ON CONFLICT(name) DO NOTHING;

-- The one number this book and RUE disagree on. RUE wins because it is later;
-- the book's figure is recorded so the disagreement is visible rather than
-- lost. Guarded so a re-run does not append it twice.
UPDATE skills SET note = COALESCE(note || '; ', '') || 'Juicer Uprising p.66 lists 30%+4%'
 WHERE name = 'Gambling (Standard)' AND (note IS NULL OR note NOT LIKE '%Juicer Uprising%');

-- The book files Interrogation Techniques under Espionage, where the catalog
-- holds 'Interrogation'. It ALSO holds a separate 'Interrogation Techniques'
-- under Military with no source book at all, which looks like a duplicate.
-- Deliberately NOT merged here: characters reference skills by name, so a
-- merge belongs to the catalog editor's duplicate tools, which write redirects
-- and rewrite characters. SQL here cannot do it safely. Recorded instead.
UPDATE skills SET note = COALESCE(note || '; ', '') || 'Possible duplicate of Interrogation (Espionage); Juicer Uprising p.64 files this skill under Espionage'
 WHERE name = 'Interrogation Techniques' AND (note IS NULL OR note NOT LIKE '%Possible duplicate%');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Deadball', 'Juicer Football', 'Murderthon', 'W.P. Deadball')
 ORDER BY name;
SELECT COUNT(*) AS juicer_uprising_skills FROM skills
 WHERE source_book = 'Rifts World Book 10: Juicer Uprising p.64-66';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-juicer-uprising-skills.sql');
