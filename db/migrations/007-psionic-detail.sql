-- Give a psionic power the same stat block a spell has, plus the tier a book
-- says is required to use it.
--
-- Field names deliberately match spells (range, duration, saving_throw,
-- description) so the sheet can render both through one code path.
--
-- min_tier is nullable with no default, and NULL means "no restriction beyond
-- this power's category" — which is today's behaviour. Books express tier
-- gating mostly at the category level ("Super Psionics are Master only"), so
-- most powers will legitimately have no stated tier. Do not infer one from the
-- category: that would record a guess as though the book said it.
--
-- Nothing enforces min_tier yet. That is PR 12, which needs real data in this
-- column before it can be built or tested.

ALTER TABLE psionic_powers ADD COLUMN range TEXT;
ALTER TABLE psionic_powers ADD COLUMN duration TEXT;
ALTER TABLE psionic_powers ADD COLUMN saving_throw TEXT;
ALTER TABLE psionic_powers ADD COLUMN description TEXT;
ALTER TABLE psionic_powers ADD COLUMN min_tier TEXT;

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('007-psionic-detail.sql');
