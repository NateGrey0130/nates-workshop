-- A skill whose starting percentage is derived from an attribute.
--
-- BOOK-INGEST-AUDIT.md F2. Phase World printed 150 defines Zero Gravity
-- Movement & Combat with a base of "P.P. number x5%", plus 4% per level. The
-- per-level half fits `per_level`; the base does not. `skills.base` is an
-- INTEGER and every consumer reads it as a fixed starting percentage, so the
-- row was imported at 0 with the formula written into `note`.
--
-- Storing it at 0 is not merely lossy, it is AMBIGUOUS: the schema comment on
-- `base` says 0 = non-percentile (W.P.s, hand to hand), and 64 rows rely on
-- that reading. A skill the book starts at 40-50% for a typical P.P. was
-- indistinguishable from a weapon proficiency.
--
-- `base_formula` holds an attribute token and a multiplier - `PP*5` - and is
-- consulted only when it is set. `base` keeps its meaning for every existing
-- row and stays the fallback, so nothing that reads `base` today changes.
--
-- The grammar is deliberately just ATTR*N. A wider expression language is
-- unjustified by one row, and F2 argues the same: a second occurrence is a
-- better trigger for more than this finding is.
ALTER TABLE skills ADD COLUMN base_formula TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('042-skill-base-formula.sql');
