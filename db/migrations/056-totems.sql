-- A totem animal: the forty Spirit West prints on printed 96-105, one row each,
-- shared by every class whose frontmatter says `totem:` (BOOK-INGEST-AUDIT.md
-- F56). Nine of the book's O.C.C.s pick one, and until now the pick lived in
-- prose, because a totem grants SKILLS and no choice a class could offer was
-- able to carry them.
--
-- `skills` is JSON shaped like an occ_skills list and `bonuses` a class bonuses
-- block, dice and pools allowed; `powers` is prose, shown only to a class whose
-- key says `powers: true`. Slug-keyed like gear and vehicles, because an id is
-- insertion order and `characters.totem` has to name the same animal in every
-- database.
CREATE TABLE IF NOT EXISTS totems (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  slug        TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  skills      TEXT,
  bonuses     TEXT,
  bonus_note  TEXT,
  powers      TEXT,
  description TEXT,
  source_book TEXT
);

-- Which one the character took, by slug, parallel to `mos`. No foreign key, so a
-- renamed or removed totem leaves the character loadable and the validator
-- says so (`totem_unknown`) rather than the row refusing to exist.
ALTER TABLE characters ADD COLUMN totem TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('056-totems.sql');
