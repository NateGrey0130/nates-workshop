-- Retiring a published class no longer destroys it.
--
-- When classes lived in committed markdown a bad row could be overridden by a
-- commit. D1 is the only source now, so a hard DELETE was unrecoverable.
-- NULL means live; a timestamp means retired.
--
-- Characters built on a retired class keep working: getStored() and the
-- level-up path deliberately do not filter on this column.

ALTER TABLE imported_classes ADD COLUMN deleted_at TEXT;

CREATE INDEX IF NOT EXISTS idx_imported_classes_deleted ON imported_classes (deleted_at);

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('003-class-soft-delete.sql');
