-- Four W.P.s cite RUE for proficiencies RUE does not have.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-wp-source-pre-rue-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-wp-source-pre-rue-citations.sql
--
-- INGESTION-AUDIT.md F25. Rifts Ultimate Edition prints ONE rifle proficiency
-- and ONE handgun proficiency, both on printed 328 - `W.P. Rifles`, whose own
-- text covers "bolt-action style of rifles... and automatic and semi-automatic,
-- military assault rifles", and `W.P. Handguns`. Its W.P. checklist on printed
-- 303 lists no Automatic Pistol, no Revolver and no Bolt Action Rifle, and
-- across all 382 cached pages "w p automatic", "w p revolver" and "w p bolt
-- action" appear NOWHERE. These four are the pre-RUE breakdown that RUE
-- consolidated, and the catalog already holds both replacements correctly cited
-- to p.302-303.
--
-- THIS IS THE THREAD `fix-wp-source-and-literacy.sql` LEFT TO BE PULLED. That
-- script filled eight blank W.P. `source_book` values with 'Rifts Ultimate
-- Edition' and said so plainly: "the aimed/burst numbers on some of these rows
-- come from an older edition's tables, and the label now says RUE anyway. If
-- that ever matters, this comment is the thread to pull." It matters now. The
-- rows are not wrong because anyone transcribed carelessly; they are wrong
-- because a deliberate blanket assumption was recorded as an assumption, and
-- this is the case where it failed.
--
-- WHY 'Rifts Skill List' AND NOT A PALLADIUM BOOK. No cached book DEFINES
-- these four. They appear across many books only inside O.C.C. skill lists -
-- Mystic Russia printed 136 lists "W.P. Automatic and Semi-Automatic Rifles
-- (including shotguns)" between "W.P. Ancient, three of choice" and "W.P.
-- Modern Weapons, two of choice", which is a class using the skill, not a book
-- defining it. That is the same trap F25 names for RUE's own prose, where
-- "Typical Payload: Revolver: Six bullets. Automatic Pistol: 8-16 rounds" sits
-- in a weapon stat block. The definitions live in the original Rifts core book,
-- which `scripts/books.json` records as deliberately NOT cached and whose rows
-- were re-cited to RUE by REBUILD-AUDIT F17.
--
-- 'Rifts Skill List' is the registry's compiled skill list and is already what
-- 40 skills cite for exactly this situation: real Rifts skills that no cached
-- Palladium book defines - Juicer Technology, Falconry, Combat Pod, the Space:
-- family. These four belong with those.
--
-- NOT RETIRED into W.P. Handguns / W.P. Rifles, though both exist and are
-- correctly cited. They are separate proficiencies, not a naming variance, and
-- a live character holds two of these four.
--
-- Guards on the WRONG value, so this is a no-op on a row already corrected and
-- cannot clobber a better citation. Sorts after fix-wp-source-and-literacy.sql,
-- which is the file that wrote the value being corrected.

UPDATE skills SET source_book = 'Rifts Skill List'
  WHERE name = 'W.P. Automatic Pistol' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Skill List'
  WHERE name = 'W.P. Revolver' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Skill List'
  WHERE name = 'W.P. Bolt Action Rifle' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Skill List'
  WHERE name = 'W.P. Automatic and Semi-automatic Rifles' AND source_book = 'Rifts Ultimate Edition';

-- Reports the result back, so it is read rather than assumed.
--   repointed        4 = all four now name the compiled skill list
--   still_bare_rue   1 = W.P. Heavy M.D. Weapons ONLY, which RUE really does
--                    print and which is deliberately left alone
--   rifles_handguns  2 = the RUE replacements, untouched, still on p.302-303
SELECT (SELECT count(*) FROM skills
          WHERE source_book = 'Rifts Skill List'
            AND name IN ('W.P. Automatic Pistol', 'W.P. Revolver',
                         'W.P. Bolt Action Rifle',
                         'W.P. Automatic and Semi-automatic Rifles')) AS repointed,
       (SELECT count(*) FROM skills
          WHERE name LIKE 'W.P.%' AND source_book = 'Rifts Ultimate Edition') AS still_bare_rue,
       (SELECT count(*) FROM skills
          WHERE name IN ('W.P. Rifles', 'W.P. Handguns')
            AND source_book = 'Rifts Ultimate Edition p.302-303') AS rifles_handguns;

-- Records this run. REQUIRED: the smoke test fails a data script with no footer.
INSERT INTO data_script_runs (filename) VALUES ('fix-wp-source-pre-rue-citations.sql');
