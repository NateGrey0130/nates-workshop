-- `media_shares`: this MediaVault user lets that one READ their library.
--
-- SHARE-AUDIT.md V1. Every statement in MediaVault binds the caller's own
-- email - items.js, items/bulk.js, items/bulk-update.js, items/bulk-delete.js
-- and duplicates.js all carry `WHERE user_email = ?` - so a library has been
-- readable by exactly one person since it was built. This row is the only thing
-- that will say otherwise, and V2 adds the single endpoint that consults it.
--
-- A ROW, NOT A TOKEN. The viewer must pass Cloudflare Access to reach the site
-- at all, so identity is already established by the time any share is consulted;
-- a secret in a URL would add a second, weaker credential guarding the same
-- door. Nothing here is a bearer: a leaked row identifier grants nothing,
-- because the reader checks the VIEWER'S OWN Access email against viewer_email.
--
-- THE PAIR IS THE KEY, so granting twice is idempotent rather than a duplicate
-- row, and revoking is a DELETE of one known row rather than a search. There is
-- no id column for the same reason `media_items` has no surrogate key: the
-- natural key is complete.
--
-- NO foreign key to anything. There is no users table on this site - identity
-- is a header Cloudflare Access injects, and the set of valid emails lives in a
-- dashboard policy no database can see. A grant naming an address that cannot
-- sign in is inert rather than broken: the viewer never arrives, so the row is
-- never read. V4 is what stops one being created by accident.
--
-- NO revoked_at and no soft delete. Revocation is a DELETE, and a row that
-- claimed a share was revoked would be a second copy of a fact the absence of
-- the row already states. The same argument `050` makes for recording only the
-- NO, from the other direction.
--
-- created_at is INTEGER epoch milliseconds, matching `media_items.added_at`
-- rather than the TEXT `datetime('now')` the character creator's tables use.
-- This is MediaVault's table and its sibling's convention is the one a reader
-- of this app will expect.
CREATE TABLE IF NOT EXISTS media_shares (
  owner_email  TEXT NOT NULL,             -- whose library is being shared
  viewer_email TEXT NOT NULL,             -- who may read it, Access identity
  created_at   INTEGER NOT NULL,          -- epoch ms, like media_items.added_at
  PRIMARY KEY (owner_email, viewer_email)
);

-- The reader asks "whose libraries may I see", which is a lookup by VIEWER.
-- The primary key already indexes owner-first, so this is the other direction.
CREATE INDEX IF NOT EXISTS idx_media_shares_viewer ON media_shares (viewer_email);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('051-media-shares.sql');
