-- MediaVault library storage, scoped per Cloudflare Access user email
CREATE TABLE IF NOT EXISTS media_items (
  user_email TEXT NOT NULL,
  item_id    TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'audiobook',
  format     TEXT NOT NULL DEFAULT 'digital',
  title      TEXT NOT NULL,
  author     TEXT NOT NULL DEFAULT '',
  actors     TEXT NOT NULL DEFAULT '',
  producers  TEXT NOT NULL DEFAULT '',
  genre      TEXT NOT NULL DEFAULT '',
  series     TEXT NOT NULL DEFAULT '',
  location   TEXT NOT NULL DEFAULT '',
  cover      TEXT NOT NULL DEFAULT '',
  notes      TEXT NOT NULL DEFAULT '',
  added_at   INTEGER NOT NULL,
  PRIMARY KEY (user_email, item_id)
);

CREATE INDEX IF NOT EXISTS idx_media_items_user ON media_items (user_email);
