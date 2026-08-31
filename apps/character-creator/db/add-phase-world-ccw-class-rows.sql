-- The four catalog rows the CCW O.C.C. batch needs and the catalog lacks:
-- two skills and two items.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-phase-world-ccw-class-rows.sql
--
-- TWO SKILLS THE SKILLS BATCH MISSED, and the miss is worth stating because it
-- is a shape rather than an oversight. add-phase-world-skills.sql took the
-- book's new skills from the two places the book collects them - printed 52-53
-- for the trade tongues and printed 150-151 for the "Space Skills (New)"
-- section. Fighter Combat is in neither. Its bonuses are printed on the far
-- side of printed 151, inside the space-combat RULES, under two headings that
-- are not called skills at all: "Bonuses for Space Fighter Combat 'Basic'
-- Training" and "Bonuses for Fighter Combat 'Elite' Combat Training".
--
-- Nothing surfaced it until the CAF Fleet Officer's O.C.C. skill list on
-- printed 58 named "Fighter Pilot: Basic" and the catalog had no such row. A
-- section heading that says New is not the whole of what a book adds.
--
-- NAMING. Three spellings for one thing: "Fighter Pilot: Basic" in the class
-- list, "Space Fighter Combat 'Basic' Training" over the bonuses, and "Fighter
-- Combat 'Elite' Combat Training" over the other set. The rows follow the
-- CATALOG's existing pair instead - Robot Combat: Basic and Robot Combat Elite
-- - because these are the same kind of thing in the same category and a picker
-- shows them together. All three book spellings are in each note.
--
-- NO BONUSES ARE STORED, which follows Robot Combat: Basic exactly and for its
-- reason: every bonus here is conditional on being in a fighter. The extra
-- attacks are explicitly "involving the fighter's weapon systems" and the dodge
-- is "while flying". `bonuses` is applied unconditionally, so storing them
-- would follow the pilot out of the cockpit and onto the ground. They are in
-- the note, where a player and a G.M. can both read them.
--
-- That also covers the two attacks each grants at later levels: `level_bonuses`
-- would be the column for them and it has the same problem.
--
-- TWO ITEMS, and NEITHER IS A STUB. class-check offers a stub for each, marked
-- "needs stats" - but the book gives neither any stats to need. A survival kit
-- and a TVIA badge appear inside equipment lists as names, with no weight, no
-- price and no description anywhere in 208 pages. A stub claims someone should
-- come back and fill it in; these rows are complete at what the book says.
-- cost stays NULL with cost_note explaining why, the same posture Wormwood's
-- 71 unpriced items take.
--
-- The survival kit is generic Rifts equipment named by two of this book's
-- classes; it is filed to Phase World because that is where these rows are
-- cited from, not because the book invented it.

INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Fighter Combat: Basic', 'Pilot', 0, 0,
 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while flying a space fighter, so none is stored: they would otherwise follow the pilot onto the ground. One extra attack or action involving the fighter''s weapon systems, +2 to strike on top of other cumulative bonuses, +3 to dodge attacks while flying, +1 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. One further attack at level six and another at level eleven. The book calls this Fighter Pilot: Basic in the CAF Fleet Officer''s skill list (p.58) and Space Fighter Combat "Basic" Training over the bonuses themselves (p.151); the catalog name follows its own Robot Combat: Basic.',
 'import', 'Rifts Dimension Book 2: Phase World p.151'),
('Fighter Combat: Elite', 'Pilot', 0, 0,
 'Base NA, no percentage - what it grants is bonuses, and ALL of them apply only while flying a space fighter, so none is stored. Two extra attacks or actions involving the fighter''s weapon systems, +2 to strike cumulative with bonuses from Weapon Systems training, +5 to dodge attacks while flying, +3 to dog-fighting rolls, and critical strike as the pilot''s own hand to hand. One further attack at level five and another at level ten. The book calls this Fighter Combat "Elite" Combat Training (p.151); the catalog name follows its own Robot Combat Elite.',
 'import', 'Rifts Dimension Book 2: Phase World p.151')
ON CONFLICT(name) DO NOTHING;

INSERT INTO gear (slug, name, system, category, weight_lbs, cost, cost_note,
                  damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc,
                  description, source_book) VALUES
('survival-kit', 'Survival Kit', 'rifts', 'gear', NULL, NULL,
 'Phase World names this in two O.C.C. equipment lists and gives it no price, no weight and no contents anywhere in the book. NULL rather than an invented figure or the estimate marker, which would claim a price was looked for and not found.',
 NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL,
 'Standard field survival kit, issued to CAF troopers and fleet officers on a combat mission alongside a survival knife, utility belt and hand computer/radio. The book carries no stat block for it.',
 'Rifts Dimension Book 2: Phase World p.57'),
('tvia-badge-and-id', 'TVIA Badge and I.D.', 'rifts', 'gear', NULL, NULL,
 'Issued, not bought. No price is printed and none would mean anything: the badge is the office.',
 NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL,
 'Credentials of the Treaty Violation Investigation Agency, the CCW body that enforces the Civilization Compact. Carries the authority of the agency and its reputation with it: printed 59 records that ordinary citizens often distrust or hate the TVIA, and that the CAF and the GSA are both openly hostile to it.',
 'Rifts Dimension Book 2: Phase World p.59-60')
ON CONFLICT(slug) DO NOTHING;

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Fighter Combat: Basic', 'Fighter Combat: Elite') ORDER BY name;
SELECT slug, name, cost, category FROM gear
 WHERE slug IN ('survival-kit', 'tvia-badge-and-id') ORDER BY slug;
SELECT COUNT(*) AS total_skills FROM skills;
SELECT COUNT(*) AS total_gear FROM gear;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-phase-world-ccw-class-rows.sql');
