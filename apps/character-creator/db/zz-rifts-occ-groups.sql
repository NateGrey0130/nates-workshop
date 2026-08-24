-- occ_group for every Rifts O.C.C.
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zz-rifts-occ-groups.sql
--
-- WHY THIS EXISTS. A race restricts which occupations it may take with
-- `occ_restrictions`, and an entry is either a class id or a `group:<name>`
-- token resolved against the occupation's `occ_group`. zz-race-occ-restrictions.sql
-- set that key on the 25 PALLADIUM O.C.C.s. It was never set on a single Rifts
-- one - all 34 of them carried no occ_group at all - so a group token matched
-- NOTHING on the Rifts side.
--
-- That is not a latent tidiness problem, it is two opposite silent failures
-- waiting for the first Rifts race that states a restriction:
--
--   only: ["group:men-of-arms"]  fails CLOSED - the race can take nothing
--   except: ["group:magic"]      fails OPEN   - the race can take everything
--
-- The second is the dangerous one, and it is the same shape as the Godling's
-- dead `except` that shipped to production and went unnoticed for months
-- (see fix-godling-demigod-accuracy.sql). Nothing is broken TODAY only because
-- every existing user of a group token - dwarf, gnome, goblin, troll - is a
-- Palladium Fantasy race restricting Palladium occupations, where both sides
-- have the key. Found while importing the Norse Giant and the Warriors of
-- Valhalla from Pantheons of the Megaverse, which are the first Rifts races
-- that need one.
--
-- THE GROUPING IS THE BOOK'S, NOT MINE, with one exception stated below. Rifts
-- Ultimate Edition files its O.C.C.s under headings, and those headings are
-- already the cited evidence for the 3D6/1D6 split in CORE_SDC_BY_CLASS in
-- js/compose.js - so this table and that one agree by construction.
--
--   men of arms          RUE printed 45-85, plus Coalition Military 231-237
--   practitioners        RUE printed 100-135
--   psychics             RUE printed 139-156
--   adventurers/scholars RUE printed 86-99
--
-- THE ONE JUDGEMENT: Adventurers & Scholars are filed as `optional`. The five
-- allowed group names are fixed in OCC_GROUPS in js/parser.js - clergy,
-- men-of-arms, optional, magic, psychic - and none of them is "adventurer".
-- `optional` carries the closest meaning: in Palladium it is the book's own
-- heading for the O.C.C.s that are not men of arms and not spell casters, which
-- is exactly what Adventurers & Scholars is in Rifts. Naming a sixth group
-- would have been a parser change for eight rows; if that becomes worth doing,
-- these eight are the ones to move.
--
-- Two more worth stating outright. The MYSTIC is filed under magic, not
-- psychic, because RUE files it under practitioners of magic even though it
-- wields both. The two PSI-STALKERS are filed under psychic even though
-- CORE_SDC_BY_CLASS gives them a man-of-arms 3D6 - that table's own comment
-- says why, "psychics by the book's grouping, but hunters by trade", and the
-- S.D.C. follows the trade while the group follows the book.
--
-- Idempotent and safe to re-run: every statement is guarded on the class not
-- already having an occ_group, so a class that acquires one by any other route
-- is left alone. Pure ASCII, LF endings.

-- men-of-arms (11)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: combat-cyborg' || char(10),
                          '---' || char(10) || 'id: combat-cyborg' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'combat-cyborg' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: crazy' || char(10),
                          '---' || char(10) || 'id: crazy' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'crazy' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: cyber-knight' || char(10),
                          '---' || char(10) || 'id: cyber-knight' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: glitter-boy' || char(10),
                          '---' || char(10) || 'id: glitter-boy' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'glitter-boy' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: headhunter-techno-warrior' || char(10),
                          '---' || char(10) || 'id: headhunter-techno-warrior' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: juicer' || char(10),
                          '---' || char(10) || 'id: juicer' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: merc-soldier' || char(10),
                          '---' || char(10) || 'id: merc-soldier' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'merc-soldier' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: robot-pilot' || char(10),
                          '---' || char(10) || 'id: robot-pilot' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'robot-pilot' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-grunt' || char(10),
                          '---' || char(10) || 'id: coalition-grunt' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-grunt' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-samas-pilot' || char(10),
                          '---' || char(10) || 'id: coalition-samas-pilot' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-technical-officer' || char(10),
                          '---' || char(10) || 'id: coalition-technical-officer' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-technical-officer' AND instr(markdown, 'occ_group:') = 0;

-- magic (9)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: elemental-fusionist-earth-air' || char(10),
                          '---' || char(10) || 'id: elemental-fusionist-earth-air' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-earth-air' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: elemental-fusionist-fire-water' || char(10),
                          '---' || char(10) || 'id: elemental-fusionist-fire-water' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-fire-water' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: ley-line-rifter' || char(10),
                          '---' || char(10) || 'id: ley-line-rifter' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: ley-line-walker' || char(10),
                          '---' || char(10) || 'id: ley-line-walker' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ley-line-walker' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mystic' || char(10),
                          '---' || char(10) || 'id: mystic' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mystic' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: shifter' || char(10),
                          '---' || char(10) || 'id: shifter' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'shifter' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: stone-master' || char(10),
                          '---' || char(10) || 'id: stone-master' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'stone-master' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: techno-wizard' || char(10),
                          '---' || char(10) || 'id: techno-wizard' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'techno-wizard' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: warlock' || char(10),
                          '---' || char(10) || 'id: warlock' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'warlock' AND instr(markdown, 'occ_group:') = 0;

-- psychic (5)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: burster' || char(10),
                          '---' || char(10) || 'id: burster' || char(10) || 'occ_group: psychic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'burster' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: dog-boy' || char(10),
                          '---' || char(10) || 'id: dog-boy' || char(10) || 'occ_group: psychic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'dog-boy' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mind-melter' || char(10),
                          '---' || char(10) || 'id: mind-melter' || char(10) || 'occ_group: psychic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mind-melter' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-stalker' || char(10),
                          '---' || char(10) || 'id: psi-stalker' || char(10) || 'occ_group: psychic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'psi-stalker' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: wild-psi-stalker' || char(10),
                          '---' || char(10) || 'id: wild-psi-stalker' || char(10) || 'occ_group: psychic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker' AND instr(markdown, 'occ_group:') = 0;

-- clergy (1)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: rifts-priest' || char(10),
                          '---' || char(10) || 'id: rifts-priest' || char(10) || 'occ_group: clergy' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-priest' AND instr(markdown, 'occ_group:') = 0;

-- optional (8)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: body-fixer' || char(10),
                          '---' || char(10) || 'id: body-fixer' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'body-fixer' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: city-rat' || char(10),
                          '---' || char(10) || 'id: city-rat' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'city-rat' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: cyber-doc' || char(10),
                          '---' || char(10) || 'id: cyber-doc' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-doc' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: operator' || char(10),
                          '---' || char(10) || 'id: operator' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'operator' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: rogue-scholar' || char(10),
                          '---' || char(10) || 'id: rogue-scholar' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: rogue-scientist' || char(10),
                          '---' || char(10) || 'id: rogue-scientist' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rogue-scientist' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: vagabond' || char(10),
                          '---' || char(10) || 'id: vagabond' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'vagabond' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: wilderness-scout' || char(10),
                          '---' || char(10) || 'id: wilderness-scout' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'occ_group:') = 0;

-- Read the result back rather than trusting the exit code. Counted with
-- arithmetic rather than a UNION of literals: D1 rejects a compound SELECT
-- built from about nine terms and rolls the whole file back when it does.
SELECT count(*) AS rifts_occs,
       sum(CASE WHEN instr(markdown, 'occ_group:') > 0 THEN 1 ELSE 0 END) AS with_group
  FROM imported_classes
 WHERE status = 'published'
   AND instr(markdown, 'system: rifts') > 0
   AND instr(markdown, 'category: occ') > 0;

-- And that every group name written is one js/parser.js will resolve.
SELECT sum(CASE WHEN instr(markdown, 'occ_group: men-of-arms') > 0 THEN 1 ELSE 0 END) AS men_of_arms,
       sum(CASE WHEN instr(markdown, 'occ_group: magic') > 0 THEN 1 ELSE 0 END)       AS magic,
       sum(CASE WHEN instr(markdown, 'occ_group: psychic') > 0 THEN 1 ELSE 0 END)     AS psychic,
       sum(CASE WHEN instr(markdown, 'occ_group: clergy') > 0 THEN 1 ELSE 0 END)      AS clergy,
       sum(CASE WHEN instr(markdown, 'occ_group: optional') > 0 THEN 1 ELSE 0 END)    AS optional
  FROM imported_classes
 WHERE status = 'published'
   AND instr(markdown, 'system: rifts') > 0
   AND instr(markdown, 'category: occ') > 0;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zz-rifts-occ-groups.sql');
