-- Four psionic powers the Burster O.C.C. names in its own selection list
-- (Rifts Ultimate Edition p.141) that the catalog did not carry. Without
-- them the Burster's picker would silently offer thirteen options where the
-- book prints seventeen - the wizard now reports such gaps, and this closes
-- the four it would report.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-burster-psionic-powers.sql
--
-- I.S.P. costs are the ones printed in the Burster's list. Categories are
-- assigned from the power's nature; the two Super ones are marked as such in
-- the book's own list. min_tier stays NULL - the category is the gate, which
-- is the catalog's overwhelming default.

INSERT INTO psionic_powers (name, category, isp, description, source, source_book)
SELECT 'Deaden Senses', 'Physical', 4, 'Dulls the psychic''s own sense of touch, taste, smell and hearing to shut out distraction and pain. RUE minor psionic power named on the Burster''s list.', 'import', 'Rifts Ultimate Edition p.141'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Deaden Senses');
INSERT INTO psionic_powers (name, category, isp, description, source, source_book)
SELECT 'Sense Time', 'Sensitive', 2, 'An unerring internal clock: the psychic always knows the time of day and how much time has elapsed, even when unconscious or in darkness. RUE minor psionic power named on the Burster''s list.', 'import', 'Rifts Ultimate Edition p.141'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Sense Time');
INSERT INTO psionic_powers (name, category, isp, description, source, source_book)
SELECT 'Psychic Body Field', 'Super', 30, 'A protective field of psychic energy around the body. Counts as TWO power selections when taken from the Burster''s list.', 'import', 'Rifts Ultimate Edition p.141'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Psychic Body Field');
INSERT INTO psionic_powers (name, category, isp, description, source, source_book)
SELECT 'Radiate Horror Factor', 'Super', 8, 'The psychic radiates an aura of dread, imposing a Horror Factor on those who see him. Counts as TWO power selections when taken from the Burster''s list.', 'import', 'Rifts Ultimate Edition p.141'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Radiate Horror Factor');

-- Read the result back rather than trusting the exit code.
SELECT name, category, isp FROM psionic_powers WHERE source_book = 'Rifts Ultimate Edition p.141' ORDER BY name;
