-- Two catalog rows two books price differently, settled by Nate on 2026-09-27.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~024-dragon-helm-and-annihilate.sql
--
-- 1. DRAGON HELM. `dragon-helm`, "Dragon helm", cites Palladium Fantasy RPG
--    p.249-267 at 200,000 gold (add-pf-magic-items.sql). Dragons & Gods
--    printed 231 (pdf page 232, cache dag p232, page_offset 1), read off a
--    300 dpi render, prices the standard Dragon Helm - "known as the Dragon's
--    Skull" - at "800,000 to 1.5 million gold". add-dag-magic-weapons.sql
--    left it out for a decision. THE DECISION: no second row; the existing
--    row keeps its 200,000 and its citation, and its cost_note records the
--    Dragons & Gods price. Keyed on slug; guarded on the note not yet naming
--    Dragons & Gods, so a second run changes nothing.
--
-- 2. ANNIHILATE. The `spells` row (add-book-of-magic-rift-spells.sql, cited
--    Rifts Book of Magic p.150) stored ppe 300, the Shifter price, with
--    ppe_note "600 normally; 300 for Shifters, Conjurers, Temporal Raiders,
--    Temporal Wizards". Book of Magic printed 150 (pdf page 151, cache bom
--    p151, page_offset 1), read off a render: "P.P.E.: Six Hundred; Shifters,
--    Conjurers, Temporal Raiders and Temporal Wizards can cast this spell at
--    a cost of only 300 P.P.E." Federation of Magic prints 600 too (fom.md,
--    spell diff). THE DECISION: ppe 600, the note kept - it reads right
--    against 600 as it stands. Keyed on name; guarded on ppe = 300.

UPDATE gear
   SET cost_note = 'Palladium Fantasy RPG: 200,000 gold. Dragons & Gods printed 231 prices the standard Dragon Helm, the Dragon''s Skull, at 800,000 to 1.5 million gold.'
 WHERE slug = 'dragon-helm'
   AND instr(coalesce(cost_note, ''), 'Dragons & Gods') = 0;

UPDATE spells
   SET ppe = 600
 WHERE name = 'Annihilate'
   AND ppe = 300;

-- Read the result back.
SELECT 'dragon helm note' AS assertion, count(*) AS got, 1 AS want FROM gear WHERE slug = 'dragon-helm' AND cost = 200000 AND instr(cost_note, 'at 800,000 to 1.5 million gold') > 0 AND source_book = 'Palladium Fantasy RPG p.249-267';
SELECT 'one dragon helm' AS assertion, count(*) AS got, 1 AS want FROM gear WHERE lower(name) = 'dragon helm';
SELECT 'annihilate 600' AS assertion, count(*) AS got, 1 AS want FROM spells WHERE name = 'Annihilate' AND ppe = 600 AND ppe_note LIKE '600 normally; 300 for Shifters%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~024-dragon-helm-and-annihilate.sql');
