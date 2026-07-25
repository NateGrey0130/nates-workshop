-- Test rows only — delete this migration (or its rows) before real campaign data matters.

INSERT INTO campaigns (name, system, gm_email, description)
VALUES ('Test Campaign — Chi-Town Burbs', 'rifts', 'test-gm@example.com', 'Smoke-test campaign, safe to delete.');

INSERT INTO characters (campaign_id, player_email, name, class_id, level, attributes, hp_max, hp_current, sdc_max, sdc_current, isp_max, isp_current)
VALUES (1, 'test-gm@example.com', 'Test Knight', 'cyber-knight', 1, '{"IQ":12,"ME":14,"MA":13,"PS":15,"PP":12,"PE":16,"PB":10,"Spd":14}', 19, 19, 30, 30, 42, 42);

INSERT INTO items (slug, name, system, category, weight_lbs, cost, stats, source_book)
VALUES ('survival-knife', 'Survival Knife', 'rifts', 'weapon', 1.0, 40, '{"damage":"1d6 S.D.C."}', 'rifts-core');

INSERT INTO character_items (character_id, item_id, qty, equipped)
VALUES (1, 1, 2, 1);

INSERT INTO journal_entries (campaign_id, character_id, author_email, title, body)
VALUES (1, 1, 'test-gm@example.com', 'Session 0', 'Character created. Smoke-test entry.');
