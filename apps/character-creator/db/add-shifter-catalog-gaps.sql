-- Catalog rows the Shifter O.C.C. references and the catalog never had.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-shifter-catalog-gaps.sql
--
-- Found by scripts/class-check.mjs: add-shifter-class.sql (PR #120, "Magic
-- Powers nearly complete") granted one skill and six spells BY NAME with no
-- row behind any of them. A granted power that resolves to nothing is silent -
-- the class looks complete and the character gets less than the book gives.


-- Lore: Dimensions - a Shifter-only skill, Rifts Ultimate Edition p.120-126.
--
-- Base 15% +5% per level, as printed. The class file already carries base 35
-- with its working shown ("Printed base 15% +5%/level, +20% O.C.C. bonus
-- folded in"), so the catalog row is the printed number and the class keeps
-- the bonus folded in, exactly as every other O.C.C. skill does.
--
-- Filed under Technical, where the catalog keeps the other Rifts lore skills
-- (Lore: Magic, Lore: D-Bee, Lore: Demons & Monsters are all Technical).
-- `systems` is left NULL - no skill row sets it.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book)
VALUES ('Lore: Dimensions', 'Technical', 15, 5, 'import', 'Rifts Ultimate Edition');


-- The six spells the Shifter grants by name, Rifts Ultimate Edition.
--
-- Level and P.P.E. are the two fields the app acts on: the wizard's picker
-- groups spells by level, and the sheet's use button deducts the cost. The
-- descriptive fields (range, duration, saving throw) are left NULL, which is
-- the catalog's normal state - only 112 of 360 rows carry them.
--
-- These extend the catalog's range: it topped out at level 10 and 100 P.P.E.
-- before this, and Dimensional Portal is level 15 at 1000. Nothing caps either
-- value - `spell_levels_allowed` is a per-class list and the Shifter grants
-- these BY NAME, which bypasses it entirely, and the sheet groups by level
-- numerically. Costs the character cannot pay yet are correct, not a bug: a
-- first-level Shifter knows Dimensional Portal and spends years unable to
-- cast it.
INSERT OR IGNORE INTO spells (name, level, ppe, system, source, source_book) VALUES
  ('Dimensional Portal',          15, 1000, 'rifts', 'import', 'Rifts Ultimate Edition'),
  ('Re-Open Gateway',             11,  180, 'rifts', 'import', 'Rifts Ultimate Edition'),
  ('Summon and Control Canines',   9,   50, 'rifts', 'import', 'Rifts Ultimate Edition'),
  ('Summon and Control Rodents',  10,   70, 'rifts', 'import', 'Rifts Ultimate Edition'),
  ('Sustain',                      5,   12, 'rifts', 'import', 'Rifts Ultimate Edition'),
  ('Time Slip',                    6,   20, 'rifts', 'import', 'Rifts Ultimate Edition');


-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level, COALESCE(source_book, '-') AS source_book
  FROM skills WHERE name = 'Lore: Dimensions';

-- Everything the Shifter grants by name that still has no row. Expect the six
-- nothing missing on either count now.
SELECT 'Lore: Dimensions present (expect 1)' AS check_name,
       (SELECT count(*) FROM skills WHERE name = 'Lore: Dimensions') AS n;

-- Counted with IN rather than a UNION list: D1 caps the number of terms in a
-- compound SELECT well below six, and the whole file rolls back when one
-- statement fails.
SELECT 'shifter spells still missing (expect 0)' AS check_name,
       6 - count(*) AS n
  FROM spells
 WHERE name IN ('Dimensional Portal', 'Re-Open Gateway', 'Summon and Control Canines',
                'Summon and Control Rodents', 'Sustain', 'Time Slip');
