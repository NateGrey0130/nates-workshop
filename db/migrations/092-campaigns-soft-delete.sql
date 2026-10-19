-- Deleting a campaign marks it deleted instead of removing the row.
--
-- Until this column, DELETE /campaigns/:id first deleted the campaign's
-- pictures from R2, which cannot be undone, and then removed the row, and
-- `characters.campaign_id` and every other child cascades from `campaigns`:
-- its characters, pages, notes, stash and dossiers went with it. Now the route
-- sets `deleted_at`, deletes nothing from the bucket, and every read of
-- `campaigns` under functions/ skips a row where it is set, by hand, the way
-- `characters.deleted_at` (migration 091) is read.
--
-- A character in a deleted campaign is hidden WITH it, not deleted: its own
-- `deleted_at` stays NULL, and the reads that reach a character through its
-- campaign require the campaign to be live. So clearing this column brings
-- the campaign back whole.
--
-- NULL = live. Restore is this column, by SQL, and nothing else; nothing
-- purges, and a deleted campaign keeps its pictures (Nate, 2026-10-12).
--
-- No index: production held 4 campaigns on 2026-10-15.

ALTER TABLE campaigns ADD COLUMN deleted_at TEXT;

-- READBACK. `d1-apply` applies the file even when it fails, so read it. Off
-- sqlite_master rather than pragma_table_info, which has answered from a
-- stale replica over --remote mid-migration (schema-change).
SELECT 'campaigns has deleted_at' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'campaigns' AND instr(sql, 'deleted_at TEXT') > 0;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('092-campaigns-soft-delete.sql');
