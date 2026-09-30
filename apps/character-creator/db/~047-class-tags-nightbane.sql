-- Authored class tags for nightbane classes, one line each, from a reviewed
-- scripts/class-tags.mjs table. Derived tags (magic, psionics, mega-damage,
-- horror-factor) are computed from the class and never written.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~047-class-tags-nightbane.sql
--
-- A TILDE SCRIPT ON PURPOSE: seven fix- scripts rewrite a class's whole
-- markdown, and any that sorted after this file would erase the tags on a
-- rebuild. Guarded on the class having no tags line, so a re-run is a no-op.
-- The tilde number is claimed at merge.

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-sorcerer' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-nightbane-sorcerer' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-doppleganger' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, flyer, stealth, evil]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-hunter' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, shapeshifter, evil]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-ashmedai' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, stealth, evil]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-namtar' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, flyer]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-snake-bird' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, shapeshifter]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-secondary-vampire' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, shapeshifter, evil]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-wild-vampire' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, hunter]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-wampyr' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, flyer, healer]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-guardian' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [supernatural, shapeshifter]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-nightbane' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [beginner]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-basic' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-nocturne' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-resistance' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [stealth]' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-warlord' AND instr(markdown, char(10) || 'tags:') = 0;

SELECT 'the 16 reviewed classes carry a tags line' AS assertion, count(*) AS got, 16 AS want FROM imported_classes WHERE class_id IN ('nb-sorcerer', 'nb-nightbane-sorcerer', 'nb-doppleganger', 'nb-hunter', 'nb-ashmedai', 'nb-namtar', 'nb-snake-bird', 'nb-secondary-vampire', 'nb-wild-vampire', 'nb-wampyr', 'nb-guardian', 'nb-nightbane', 'nb-package-basic', 'nb-package-nocturne', 'nb-package-resistance', 'nb-package-warlord') AND instr(markdown, char(10) || 'tags: [') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~047-class-tags-nightbane.sql');
