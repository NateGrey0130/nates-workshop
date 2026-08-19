-- Sign Language, Palladium Fantasy RPG 2nd Ed. - Communications skill.
--
-- Base 25%, +5% per level of experience. The book's "up to a maximum of 98%"
-- needs no note: the 98% ceiling is a general rule (p.22) the app already
-- applies at creation and on every level-up.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not a column.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-sign-language.sql
--   npx wrangler d1 execute nates-workshop-media --remote --command "<paste the INSERT>"
--
-- WHY THIS MATTERS, beyond one missing catalog row:
--
-- The Long Bowman O.C.C. restricts its Communications related-skill choices to
-- "Sign Language only" (PF2E p.84), stored as:
--
--     { name: "Communications", only: ["Sign Language"] }
--
-- `categoryAllows` compares literal names, so an `only` naming a skill the
-- catalog does not hold narrows the category to nothing. With Sign Language
-- absent, a Long Bowman was offered NONE of the nine Communications skills that
-- exist - silently denied the one choice the book grants. Adding the row is the
-- whole fix; the class markdown is already correct.
--
-- Found by the cross-reference check that now reports restriction names
-- resolving to nothing. The other four unresolved names on this class
-- (Falconry, Interrogation, Locate Secret Compartments, Ventriloquism) are
-- `except` entries for skills not imported yet, which correctly exclude nothing
-- and need no action.
--
-- `systems` is NULL, meaning every system. Skills are deliberately cross-system
-- here - Rifts and Palladium Fantasy share a multiverse - and untagging them is
-- what untag-cross-system.sql exists to maintain. Do not tag this from the book.
--
-- Idempotent through the UNIQUE name: re-running inserts nothing, and a row
-- someone has already corrected by hand is left exactly as it is.
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book)
VALUES ('Sign Language', 'Communications', 25, 5, NULL, 'manual', 'Palladium Fantasy RPG 2nd Ed.');

-- Reports what the environment now has, so the result is read rather than
-- assumed - `wrangler d1 execute` has been observed reporting a non-zero exit
-- on a run that fully applied.
SELECT name, category, base, per_level, source, source_book
  FROM skills WHERE name = 'Sign Language';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-sign-language.sql');
