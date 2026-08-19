-- Optional local-dev seed data. Not part of db/schema.sql and never applied to
-- production. Apply from the repo root after the schema:
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/seed-dev.sql

-- char(8212) rather than a literal em-dash: wrangler on Windows has mangled
-- non-ASCII bytes into mojibake in production, and scripts/d1-apply.mjs
-- refuses any file carrying them at all.
INSERT INTO campaigns (name, system, gm_email, description)
VALUES ('Test Campaign ' || char(8212) || ' Chi-Town Burbs', 'rifts', 'test-gm@example.com', 'Smoke-test campaign, safe to delete.');

INSERT INTO characters (campaign_id, player_email, name, class_id, level, attributes, hp_max, hp_current, sdc_max, sdc_current, isp_max, isp_current)
VALUES (1, 'test-gm@example.com', 'Test Knight', 'cyber-knight', 1, '{"IQ":12,"ME":14,"MA":13,"PS":15,"PP":12,"PE":16,"PB":10,"Spd":14}', 19, 19, 30, 30, 42, 42);

-- `stats` was a JSON blob until migration 008 replaced it with real columns
-- and dropped it. This seed still wrote to it, so the documented local-dev
-- step failed with "table gear has no column named stats".
INSERT INTO gear (slug, name, system, category, weight_lbs, cost, damage, source_book)
VALUES ('survival-knife', 'Survival Knife', 'rifts', 'weapon', 1.0, 40, '1d6 S.D.C.', 'rifts-core');

INSERT INTO character_items (character_id, item_id, qty, equipped)
VALUES (1, 1, 2, 1);

INSERT INTO journal_entries (campaign_id, character_id, author_email, title, body)
VALUES (1, 1, 'test-gm@example.com', 'Session 0', 'Character created. Smoke-test entry.');

-- Records this run, same as the correction scripts do. Unlike them, this
-- one is NOT safe to re-run: its inserts are unguarded and a second pass
-- fails on gear.slug, which is the right behaviour for a file whose job is
-- to put known rows into an empty local database.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('seed-dev.sql');
