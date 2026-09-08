-- `catalog_pair_dismissals`: this pair was looked at, and it is NOT a duplicate.
--
-- BOOK-INGEST-AUDIT.md F33. `findDuplicates` suggests pairs; a human confirms
-- them one at a time. Confirming a DUPLICATE already has somewhere to go - the
-- merge repoints, redirects and deletes the losing row, so the pair cannot come
-- back and there is nothing to remember. Confirming a pair is DISTINCT had
-- nowhere to go at all, so every reader started from scratch: gear suggests
-- 591 pairs today, 589 of them in the loosest tier, and the 27 bare-vs-qualified
-- and 18 cross-system pairs INGESTION-AUDIT F29 read on 2026-09-06 are all
-- still in that list, indistinguishable from pairs nobody has judged.
--
-- The shape is `npc_proposals_dismissed`, which solved the same problem for a
-- different suggester, and whose own code says why: "a proposal for a name a
-- human already rejected is worse than noise - it is the button asking the same
-- question again."
--
-- THE TWO KEYS ARE STORED SORTED. The detector walks rows in id order, so which
-- of a pair is `a` and which is `b` depends on insertion order and would differ
-- between a rebuilt database and production. Sorting them gives one pair one
-- identity, and the UNIQUE constraint then means what it looks like it means.
--
-- Keys rather than ids for the same reason `spells.same_spell_as` uses a name:
-- ids are insertion order and differ per environment. It is the catalog's own
-- unique field - a slug for gear, a name for skills, spells and psionics.
--
-- NO foreign key, deliberately. A dismissal must survive one of its rows being
-- merged away later: the record that somebody judged this pair is still true,
-- and a cascade would delete the evidence. A dismissal naming a row that no
-- longer exists is inert, not broken - nothing can suggest that pair again.
--
-- This table is NOT a record of confirmed duplicates. There is no verdict
-- column and no 'duplicate' value, because a confirmed duplicate is executed
-- rather than recorded, and a row here claiming a merge that never ran would be
-- exactly the kind of stale second copy this catalog already has too many of.
CREATE TABLE IF NOT EXISTS catalog_pair_dismissals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                     -- skills | spells | psionics | gear
  key_a TEXT NOT NULL COLLATE NOCASE,        -- the pair's two unique keys, sorted,
  key_b TEXT NOT NULL COLLATE NOCASE,        -- so one pair has exactly one identity
  note TEXT,                                 -- why they are distinct, in a human's words
  dismissed_by TEXT NOT NULL,
  dismissed_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (catalog, key_a, key_b)
);

CREATE INDEX IF NOT EXISTS idx_catalog_pair_dismissals_catalog
  ON catalog_pair_dismissals (catalog);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('050-catalog-pair-dismissals.sql');
