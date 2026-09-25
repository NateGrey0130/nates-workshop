-- 085: drop the ten tables that moved out of Palladium's database.
--
-- On 2026-09-25 each group of apps got a D1 of its own (groups.json): the six
-- ff_ tables and the two media_ tables moved to the tools' DB_TOOLS
-- (nates-workshop-tools), and the two msh_ tables to Marvel's DB_MARVEL
-- (nates-workshop-marvel), each copied row for row and compared by content
-- before its code switched. The originals stayed here, unread, as a rollback.
-- This retires them (Nate, 2026-09-25). Before it was applied, every row of
-- all ten was compared against its new copy once more - identical - and all
-- three databases were backed up.
--
-- The MIGRATIONS that created them (039, 040, 051, 081, 082) keep their rows in
-- this database's schema_migrations, as history; their files now live in
-- db/migrations/tools/ and db/migrations/marvel/. No foreign key reaches any of
-- these tables, so the order does not matter; DROP TABLE takes the indexes.
DROP TABLE IF EXISTS ff_brands;
DROP TABLE IF EXISTS ff_filaments;
DROP TABLE IF EXISTS ff_config;
DROP TABLE IF EXISTS ff_history;
DROP TABLE IF EXISTS ff_presets;
DROP TABLE IF EXISTS ff_custom_filaments;
DROP TABLE IF EXISTS media_items;
DROP TABLE IF EXISTS media_shares;
DROP TABLE IF EXISTS msh_power_text;
DROP TABLE IF EXISTS msh_heroes;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('085-drop-moved-group-tables.sql');

SELECT 'moved tables left in DB' AS assertion, count(*) AS got, 0 AS want FROM sqlite_master WHERE type = 'table' AND name IN ('ff_brands', 'ff_filaments', 'ff_config', 'ff_history', 'ff_presets', 'ff_custom_filaments', 'media_items', 'media_shares', 'msh_power_text', 'msh_heroes');
