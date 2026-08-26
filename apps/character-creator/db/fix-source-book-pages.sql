-- 39 classes carried a bare source_book slug and dragon-hatchling a
-- pageless title, so the page-break defence (class-check --field-sources)
-- could not run on any of them (class audit F18, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-source-book-pages.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-source-book-pages.sql
--
-- The ranges are the audit's hand-located pages. All 24 Palladium Fantasy
-- start pages were re-confirmed against the pf cache before writing (each
-- class name appears on its start page; the cache runs at printed+2 - the
-- offset this check itself established). The Pantheons and Dragons & Gods
-- PDFs are not in the OCR cache on this machine today, so those 15 ranges
-- and dragon-hatchling's stand on the audit's hand-located numbers.
--
-- Filename sort: fix-source-book-pages > every add-*-class.sql and >
-- fix-pre-rue-class-audit, the last writer of dragon-hatchling's line. The
-- guard includes the trailing newline, so a stamped line never matches
-- again and re-runs are no-ops.

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.63-67' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'priest-of-light' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.70-71' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'priest-of-darkness' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.71-73' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'warrior-monk' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.73-78' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'druid' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.78-80' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'mercenary-fighter' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.81-83' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'soldier' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.83-85' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'long-bowman' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.85-87' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'knight' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.88-90' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'palladin' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.90-91' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'ranger' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.91-94' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'thief' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.94-96' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'assassin' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.96-96' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'merchant' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.96-97' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'noble' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.97-97' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'scholar' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.98-98' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'squire' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.104-107' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'wizard' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.112-116' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'witch' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.117-120' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'diabolist' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.135-137' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'summoner' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.156-157' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'psychic-sensitive' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.158-159' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'psi-healer' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.160-160' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'psi-mystic' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: palladium-fantasy-core' || char(10), 'source_book: palladium-fantasy-core p.161-163' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'mind-mage' AND instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.12-16' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'rifts-priest' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.16-17' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'godling' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.17-19' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'demigod' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.57-59' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'scorpion-person' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.92-94' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'greater-cyclops' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.141-142' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'naga' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.142-143' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'daitya' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.143-144' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'dakini' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.163-166' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'norse-giant' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.166-167' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'asgardian-dwarf' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.167-167' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'asgardian-high-elf' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.167-168' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'valkyrie' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.168-170' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'berserker' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: pantheons-of-the-megaverse' || char(10), 'source_book: pantheons-of-the-megaverse p.170-171' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'warrior-of-valhalla' AND instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: dragons-and-gods' || char(10), 'source_book: dragons-and-gods p.23-24' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, 'source_book: dragons-and-gods' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown, 'source_book: Rifts RPG (original core book)' || char(10), 'source_book: Rifts RPG (original core book) p.98-101' || char(10)),
    updated_at = datetime('now')
WHERE class_id = 'dragon-hatchling' AND instr(markdown, 'source_book: Rifts RPG (original core book)' || char(10)) > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   pf_ok       24 = every Palladium Fantasy class carries pages
--   pom_ok      14 = every Pantheons class carries pages
--   rest_ok      2 = chiang-ku-dragon and dragon-hatchling carry pages
--   bare_left    0 = no bare slug or pageless title anywhere
--   cr_free     40 = all forty touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id IN ('priest-of-light', 'priest-of-darkness', 'warrior-monk', 'druid', 'mercenary-fighter', 'soldier', 'long-bowman', 'knight', 'palladin', 'ranger', 'thief', 'assassin', 'merchant', 'noble', 'scholar', 'squire', 'wizard', 'witch', 'diabolist', 'summoner', 'psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage')
          AND instr(markdown, 'source_book: palladium-fantasy-core p.') > 0) AS pf_ok,
       (SELECT count(*) FROM imported_classes WHERE class_id IN ('rifts-priest', 'godling', 'demigod', 'scorpion-person', 'greater-cyclops', 'naga', 'daitya', 'dakini', 'norse-giant', 'asgardian-dwarf', 'asgardian-high-elf', 'valkyrie', 'berserker', 'warrior-of-valhalla')
          AND instr(markdown, 'source_book: pantheons-of-the-megaverse p.') > 0) AS pom_ok,
       (SELECT count(*) FROM imported_classes
          WHERE (class_id = 'chiang-ku-dragon' AND instr(markdown, 'source_book: dragons-and-gods p.23-24') > 0)
             OR (class_id = 'dragon-hatchling' AND instr(markdown, 'source_book: Rifts RPG (original core book) p.98-101') > 0)) AS rest_ok,
       (SELECT count(*) FROM imported_classes
          WHERE instr(markdown, 'source_book: palladium-fantasy-core' || char(10)) > 0
             OR instr(markdown, 'source_book: pantheons-of-the-megaverse' || char(10)) > 0
             OR instr(markdown, 'source_book: dragons-and-gods' || char(10)) > 0
             OR instr(markdown, 'source_book: Rifts RPG (original core book)' || char(10)) > 0) AS bare_left,
       (SELECT count(*) FROM imported_classes WHERE class_id IN ('priest-of-light', 'priest-of-darkness', 'warrior-monk', 'druid', 'mercenary-fighter', 'soldier', 'long-bowman', 'knight', 'palladin', 'ranger', 'thief', 'assassin', 'merchant', 'noble', 'scholar', 'squire', 'wizard', 'witch', 'diabolist', 'summoner', 'psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage', 'rifts-priest', 'godling', 'demigod', 'scorpion-person', 'greater-cyclops', 'naga', 'daitya', 'dakini', 'norse-giant', 'asgardian-dwarf', 'asgardian-high-elf', 'valkyrie', 'berserker', 'warrior-of-valhalla', 'chiang-ku-dragon', 'dragon-hatchling')
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-source-book-pages.sql');
