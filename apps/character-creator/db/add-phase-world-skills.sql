-- The seven skills Rifts Dimension Book 2: Phase World adds that the catalog
-- does not already hold under any name.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-phase-world-skills.sql
--
-- The book is a SCAN with no text layer. Every number below was read off a
-- 200 dpi page render, not off the OCR cache, because the cache is the only
-- reading available and there is no second table in this book to check it
-- against: Phase World prints each skill's percentage exactly once, in the
-- skill's own description. Printed-to-PDF offset is ZERO - printed N is cache
-- pNNN and doc[N-1] - recorded in scripts/books.json.
--
-- SEVEN, not twelve. The book prints twelve new skills on printed 150-151 plus
-- six trade tongues on printed 52. Eight of those eighteen are already in the
-- catalog under a different name, every one of them citing "Rifts Skill List",
-- and they are re-cited rather than duplicated by
-- zzzzz-recite-phase-world-skills.sql. See that file for the mapping and for
-- why the action is a citation change and never a rename.
--
-- Three more are already correct and untouched: Astrophysics and Xenology
-- (both 30% +5%, Science) cite RUE p.302-303 and agree with printed 151
-- exactly, and Lore: Galactic/Alien is re-cited by the other file.
--
-- TWO THE BOOK PRINTS THAT ARE DELIBERATELY NOT HERE. Both are near-duplicates
-- of an existing row and both are catalog-editor judgement calls rather than
-- SQL, on the reasoning BOOK-INGEST-QUEUE.md records for W.P. Rope:
--
--   book prints (page)                 catalog holds                  why not
--   Spaceship Mechanics 22%+5% (150)   Space: Spacecraft Mechanics    same skill,
--                                      20%+5%, Mechanical             20 vs 22
--   Pilot: Contragravity Pak (150)     Space: Antigrav Suit 44%+4%    DIFFERENT
--
-- The first is one word and two points apart, same category and same per-level
-- step. Correcting 20 to 22 would be adopting a printed authority over an
-- unsourced value, which is defensible; adding a second row would manufacture
-- a duplicate, which is not. Neither is urgent and neither is obviously right,
-- so it is left alone and recorded in the survey.
--
-- The second went the other way and IS here: different name AND different
-- number, 42 against 44, so these are two skills rather than one reading.
--
-- NAMING. Two of these take the catalog's Space: prefix rather than the book's
-- own heading. Phase World files them under "Physical Skills" and "Pilot
-- Skills" and prints "Pilot: Contragravity Pak", but the class-import skill is
-- explicit that a Pilot skill stores WITHOUT the Pilot: prefix - the catalog
-- row is Jet Fighters, not Military: Jet Fighters - and eight sibling space
-- skills already carry Space:. Keeping the family together is what a picker
-- shows the user. The book's own spelling is in each row's note.
--
-- ZERO GRAVITY MOVEMENT & COMBAT HAS NO STARTING PERCENTAGE THIS COLUMN CAN
-- HOLD. Printed 150 gives its base as the character's P.P. attribute times 5%,
-- which is the first attribute-derived base in this catalog. skills.base is
-- INTEGER NOT NULL and nothing evaluates a formula, so the row carries 0 and
-- the formula is in its note. That 0 is NOT the 0 the schema comment describes
-- - it does not mean non-percentile the way a W.P.'s does - and a character
-- sheet will show 0% for a skill the book starts around 40-50% for a typical
-- P.P. Filed as BOOK-INGEST-AUDIT.md F2; do not "fix" it by inventing a number.
--
-- THE FOUR TRADE TONGUES ARE A REAL GAP, not a naming variant. The catalog
-- holds Language: Trade Five/Reptile and Language: Trade Six and none of One
-- through Four, so an NPC on printed 181 listing Trade One, Four and Five has
-- two skills nothing in the catalog resolves. All six are Galactic Trade
-- Tongues from one section of printed 52-53; the two that already exist keep
-- their names and get their citation moved.
--
-- systems is left NULL, matching every existing row: the column means
-- "restricted to", and nothing in the catalog is restricted today.

INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Language: Trade One', 'Technical', 50, 5,
 'Galactic Trade Tongue One, the oldest of the six and believed to be a language of the First Race. Many of its sounds have equivalent hand or limb signs, so it carries an automatic +10% to learn on top of any O.C.C. or I.Q. bonus. The 50% base is before any I.Q. bonus.',
 'import', 'Rifts Dimension Book 2: Phase World p.52'),
('Language: Trade Two', 'Technical', 50, 5,
 'Galactic Trade Tongue Two, favoured by telepathic races because it uses telepathy alongside the spoken word. A character with the telepathy or empathy psi-power learns it at +20%; a non-psychic is at -15%. The 50% base is before any I.Q. bonus. Neither modifier is stored as a bonus: both are conditional on the character, which bonuses cannot express.',
 'import', 'Rifts Dimension Book 2: Phase World p.52'),
('Language: Trade Three', 'Technical', 50, 5,
 'Galactic Trade Tongue Three, the Wolfen language streamlined to reduce its guttural elements but otherwise identical to it. The 50% base is before any I.Q. bonus.',
 'import', 'Rifts Dimension Book 2: Phase World p.52'),
('Language: Trade Four', 'Technical', 50, 5,
 'Galactic Trade Tongue Four, evolved from English/American with added technical terms and loan words. A native English/American speaker has it automatically at 50% plus any I.Q. bonus.',
 'import', 'Rifts Dimension Book 2: Phase World p.52'),
('Law: CCW', 'Technical', 30, 5,
 'The law of the Consortium of Civilized Worlds, including the Civilization Compact. Distinct from the catalog''s Law (General) at 35% and Law at 25%: this is one polity''s code, not general jurisprudence.',
 'import', 'Rifts Dimension Book 2: Phase World p.151'),
('Space: Contragravity Pak', 'Pilot', 42, 4,
 'Printed as Pilot: Contragravity Pak, under Pilot Skills; stored with the catalog''s Space: prefix and without the Pilot: one, per the catalog naming rules. Similar to piloting a jet pack. NOT the same row as Space: Antigrav Suit (44% +4%), which is a different name and a different number.',
 'import', 'Rifts Dimension Book 2: Phase World p.150'),
('Space: Zero Gravity Movement & Combat', 'Physical', 0, 4,
 'Printed as Zero Gravity Movement & Combat, under Physical Skills; stored with the catalog''s Space: prefix. BASE IS NOT ZERO: the book gives it as the character''s P.P. attribute number times 5%, plus 4% per level. skills.base is an integer and cannot hold a formula, so it is 0 here and the real figure is this sentence - see BOOK-INGEST-AUDIT.md F2. Moving in zero gravity without penalty except speed, which is reduced by 20%. A character WITHOUT this skill is at -15% on skill performance, -1 attack per melee, -2 on initiative, half combat bonuses and half speed.',
 'import', 'Rifts Dimension Book 2: Phase World p.150')
ON CONFLICT(name) DO NOTHING;

-- Read the result back rather than trusting the exit code. One SELECT with IN
-- rather than a UNION: D1 rejects a compound SELECT past five terms and rolls
-- the whole file back.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Language: Trade One', 'Language: Trade Two', 'Language: Trade Three',
                'Language: Trade Four', 'Law: CCW', 'Space: Contragravity Pak',
                'Space: Zero Gravity Movement & Combat')
 ORDER BY name;
SELECT COUNT(*) AS total_skills FROM skills;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-phase-world-skills.sql');
