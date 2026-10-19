-- Deleting a character marks it deleted instead of removing the row.
--
-- Until this column, DELETE /characters/:id removed the row, and twenty
-- foreign keys cascade from `characters`: its inventory, vehicles, level
-- history, unspent picks, grants and play log went with it, and a mistaken
-- delete could not be undone. Now the route sets `deleted_at` and every read
-- of `characters` under functions/ skips a row where it is set, by hand, the
-- way `imported_classes.deleted_at` (migration 003) is read.
--
-- NULL = live. Restore is this column, by SQL, and nothing else (Nate,
-- 2026-10-12: no restore button, and no purge after N days).
--
-- No index: production held 6 characters on 2026-10-15, and every read that
-- filters on this column already narrows by id, campaign or player first.

ALTER TABLE characters ADD COLUMN deleted_at TEXT;

-- READBACK. `d1-apply` applies the file even when it fails, so read it. Off
-- sqlite_master rather than pragma_table_info, which has answered from a
-- stale replica over --remote mid-migration (schema-change).
SELECT 'characters has deleted_at' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'characters' AND instr(sql, 'deleted_at TEXT') > 0;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('091-characters-soft-delete.sql');
