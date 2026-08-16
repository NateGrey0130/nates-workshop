-- 013 — which variant of its class a character is.
--
-- Several RCCs come in stages rather than as one statblock: a Dragon is a
-- hatchling, then young, then adult, then ancient, sharing lore, natural
-- abilities and skills while differing in attribute dice, M.D.C. and what the
-- class grants. Modelling those as four unrelated classes means maintaining the
-- shared 90% four times and watching it drift.
--
-- A class now carries `variants`, and a character records which one it is.
-- NULL means the class has no variants, or predates them — both read as "use
-- the class as written".
--
-- Deliberately its own column rather than encoded into class_id: every reader
-- of class_id would otherwise have to know to split it, and the ones that
-- forgot would silently fail to resolve the class.
ALTER TABLE characters ADD COLUMN class_variant TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('013-character-variant.sql');
