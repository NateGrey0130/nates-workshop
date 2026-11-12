-- Three Millennium Tree gear rows held from Rifts World Book 8: Japan carry
-- figures that Rifts World Book 3: England (1993) prints differently; each
-- row now says so in its description (england-2026-11-12, row 4).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~275-england-millennium-compare.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~275-england-millennium-compare.sql
--
-- By Nate's ruling of 2026-10-04 the newest printing that STATES a figure
-- wins, so Japan's figure stays each row's figure and the rows keep citing
-- Japan (the D23 shape, taken 2026-11-12). Only description changes: one
-- sentence is appended giving England's figure and its printed page. Every
-- other column, damage and source_book included, is left alone.
--
-- All three differ, so all three are edited; no row was left without a
-- statement. Read off 2026-11-12 renders of the England PDF (pymupdf index
-- = printed page, page_offset 1), not the text layer: the javelin and the
-- throwing stick on printed 20, the corrupted staff on printed 22, whose
-- cache page is welded. On printed 22 the corrupted wand's own damage (1D4
-- S.D.C., 1D4 M.D. to vampires) and the 4D6 cap for a wand built into a
-- weapon match the held row, so the sentence names only the staff.
--
-- Guarded on each row still citing Japan and its description not yet naming
-- England, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

UPDATE gear
   SET description = description || ' Rifts World Book 3: England printed p.20 gives the javelin 1D6 S.D.C. against most creatures and 6D6 M.D. against vampires and all undead, including animated dead, zombies, mummies and maxpary shamblers, and prints no separate damage against other supernatural beings.'
 WHERE slug = 'millennium-vampire-slaying-javelin'
   AND source_book = 'Rifts World Book 8: Japan p.35'
   AND instr(description, 'England') = 0;

UPDATE gear
   SET description = description || ' Rifts World Book 3: England printed p.20 gives the throwing stick 1D6 S.D.C. against most creatures and 4D6 M.D. against vampires, so-called demons and supernatural monsters alike, with no lower figure for the supernatural.'
 WHERE slug = 'millennium-throwing-stick'
   AND source_book = 'Rifts World Book 8: Japan p.35'
   AND instr(description, 'England') = 0;

UPDATE gear
   SET description = description || ' Rifts World Book 3: England printed p.22 gives the corrupted staff 2D6 M.D., double to vampires, +2D6 M.D. per low-level spell given up, to a maximum of 8D6 M.D. for four spells.'
 WHERE slug = 'corrupted-millennium-wand-or-staff'
   AND source_book = 'Rifts World Book 8: Japan p.36-37'
   AND instr(description, 'England') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the three rows name England once and still cite Japan' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE slug IN ('millennium-vampire-slaying-javelin', 'millennium-throwing-stick', 'corrupted-millennium-wand-or-staff')
   AND source_book LIKE 'Rifts World Book 8: Japan p.%'
   AND instr(description, 'Rifts World Book 3: England printed p.2') > 0
   AND instr(substr(description, instr(description, 'England') + 7), 'England') = 0;

SELECT 'the held damage figures are unchanged' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'millennium-vampire-slaying-javelin' AND instr(damage, '4D6 M.D. to supernatural beings') > 0)
    OR (slug = 'millennium-throwing-stick' AND instr(damage, '3D6 M.D. to supernatural beings') > 0)
    OR (slug = 'corrupted-millennium-wand-or-staff' AND instr(damage, 'maximum of 1D6x10') > 0);

INSERT INTO data_script_runs (filename) VALUES ('~275-england-millennium-compare.sql');
