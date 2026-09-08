-- occ_group for the nine Underseas O.C.C.s
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-occ-groups.sql
--
-- WHY THIS EXISTS is set out in full in zz-rifts-occ-groups.sql, which did the
-- same job for the 34 Rifts O.C.C.s that came before these. The short version:
-- a race restricts occupations with `occ_restrictions`, an entry may be a
-- `group:<name>` token, and that token is resolved against the occupation's
-- `occ_group`. An occupation carrying none matches NOTHING - so an `only`
-- fails CLOSED and, far worse, an `except` fails OPEN. Nine of this book's
-- classes shipped in PRs #800 through #807 without one, which regression.mjs
-- caught and which nothing else would have until a race tripped over it.
--
-- THE GROUPING HERE IS NOT READ OFF A HEADING, because this book does not
-- print one. Rifts Ultimate Edition files its O.C.C.s under men of arms,
-- practitioners, psychics and adventurers, and zz-rifts-occ-groups.sql could
-- cite those headings directly. Underseas groups by NATION instead - "Tritonian
-- O.C.C.s" on printed 97, the New Navy from printed 112 - and those are not the
-- five names OCC_GROUPS allows.
--
-- So the evidence used is the one that IS in this book and is already cited:
-- the 3D6/1D6 split behind each class's CORE_SDC_BY_CLASS entry in
-- js/compose.js, which came from the same reading of these sections. That
-- makes this table and that one agree by construction, exactly as the Rifts
-- file describes:
--
--   men-of-arms  the three 3D6 classes - the Sea Wolf, the Navy Seaman and the
--                Marine, which are the book's fighting trades
--   magic        the three spell casters - the Whale Singer, the Ocean Wizard
--                and the Sea Druid, each of which grants a spell list
--   optional     the remaining three, on the same reasoning zz-rifts-occ-groups
--                used for Adventurers & Scholars: `optional` is the closest of
--                the five allowed names for an occupation that is neither a man
--                of arms nor a spell caster
--
-- THE ONE THAT NEEDED CHECKING is the SEA INQUISITOR, because a grep for
-- "magic" in its markdown hits. That hit is `spell_magic: 1` inside its saves
-- block - the class is a monster hunter with heavy save bonuses AGAINST magic,
-- and it grants no spells and no psionics of its own. It is `optional`, not
-- `magic`, and the near-miss is recorded here so the next reader does not have
-- to repeat it.
--
-- NONE of the nine is `clergy` or `psychic`. The book's one religious O.C.C.
-- is the Cult of the Deep's, which is setting material and was never imported;
-- the psychic classes from this book are R.C.C.s, which take no group at all.
--
-- Idempotent and safe to re-run: every statement is guarded on the class not
-- already having an occ_group, so a class that acquires one by any other route
-- is left alone. Pure ASCII, LF endings.


-- men-of-arms (3)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: tritonian-sea-wolf' || char(10),
                          '---' || char(10) || 'id: tritonian-sea-wolf' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'tritonian-sea-wolf' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: navy-seaman' || char(10),
                          '---' || char(10) || 'id: navy-seaman' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'navy-seaman' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: marine' || char(10),
                          '---' || char(10) || 'id: marine' || char(10) || 'occ_group: men-of-arms' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'marine' AND instr(markdown, 'occ_group:') = 0;

-- magic (3)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: whale-singer' || char(10),
                          '---' || char(10) || 'id: whale-singer' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'whale-singer' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: ocean-wizard' || char(10),
                          '---' || char(10) || 'id: ocean-wizard' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ocean-wizard' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: sea-druid' || char(10),
                          '---' || char(10) || 'id: sea-druid' || char(10) || 'occ_group: magic' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sea-druid' AND instr(markdown, 'occ_group:') = 0;

-- optional (3)
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: sea-inquisitor' || char(10),
                          '---' || char(10) || 'id: sea-inquisitor' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sea-inquisitor' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: tritonian-scientist' || char(10),
                          '---' || char(10) || 'id: tritonian-scientist' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'tritonian-scientist' AND instr(markdown, 'occ_group:') = 0;
UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: salvage-expert' || char(10),
                          '---' || char(10) || 'id: salvage-expert' || char(10) || 'occ_group: optional' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'salvage-expert' AND instr(markdown, 'occ_group:') = 0;

-- Read the result back rather than trusting the exit code. A replace() that
-- matched nothing is a SILENT no-op, which is exactly how this fails.
SELECT 'these nine now carry a group' AS assertion,
       count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE class_id IN ('tritonian-sea-wolf', 'navy-seaman', 'marine', 'whale-singer', 'ocean-wizard', 'sea-druid', 'sea-inquisitor', 'tritonian-scientist', 'salvage-expert') AND instr(markdown, 'occ_group:') > 0;

SELECT 'and no published O.C.C. anywhere is left without one' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE status = 'published' AND deleted_at IS NULL
   AND instr(markdown, 'category: occ') > 0
   AND instr(markdown, 'occ_group:') = 0;

SELECT class_id, 'ok' AS grouped FROM imported_classes
 WHERE class_id IN ('tritonian-sea-wolf', 'navy-seaman', 'marine', 'whale-singer', 'ocean-wizard', 'sea-druid', 'sea-inquisitor', 'tritonian-scientist', 'salvage-expert') AND instr(markdown, 'occ_group:') > 0
 ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-occ-groups.sql');

