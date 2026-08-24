-- Whether a campaign accepts new characters from anyone on the site.
--
-- Membership has always been "owns a character in the campaign" (see
-- _lib/auth.js campaignAccess), and creating one was ungated: any
-- authenticated friend could join any campaign, and with it read and write
-- its notes, stash, ledger and dossiers. The GM now holds the door.
-- 1 (the default) is the open-table behaviour every existing campaign keeps;
-- 0 means only the GM and existing members may create a character in it.
ALTER TABLE campaigns ADD COLUMN open INTEGER NOT NULL DEFAULT 1;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('037-campaign-open.sql');
