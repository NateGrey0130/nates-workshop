-- Four gear rows take the Book of Magic's figures (BOOK-INGEST-AUDIT F144).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~237-book-ingest-audit-f144-four-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~237-book-ingest-audit-f144-four-gear.sql
--
-- Nate's ruling of 2026-10-04: the newest printing that STATES a figure wins,
-- and the older figure is kept in the row's notes with its page. 2026-10-12: a
-- row taking the Book of Magic's figure moves its source_book there.
-- 2026-10-19: the Force Cannon takes "3D6 M.D. at a ley line" as printed.
--
--   talisman-of-armor      Atlantis printed 154 (1992) -> Rifts Book of Magic
--                          printed 316 (2001): cost 20,000,000 -> 10,000,000;
--                          weight none -> 1 lb.
--   tw-fireburst-rifle     Federation of Magic printed 115 (1997) -> 325: cost
--                          125,000 -> 150,000; 40,000 per clip stands.
--   tw-force-cannon        Federation of Magic printed 115 -> 325: damage
--                          1D6x10+10 M.D. -> 1D6x10 M.D. per shot, plus 3D6
--                          M.D. at a ley line. Cost unchanged.
--   manoan-fireball-rifle  South America printed 92 (1994) -> 313: cost_note
--                          none -> 20,000-35,000 credits (cost stays 20000);
--                          payload adds 15 P.P.E. per individual blast.
--
-- gear has no notes column: the older cost is kept in cost_note and an older
-- damage, weight or payload in description, each with its page. Every other
-- column matched. Figures were read off 150 dpi renders of both books on
-- 2026-10-18.
--
-- No slug or name changes, so no class's equipment pointer and no saved
-- character's pick moves.
--
-- Each UPDATE is guarded on the citation and the figure it replaces, so a
-- re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: four gear rows. The tilde
-- number is claimed at merge.

UPDATE gear
   SET cost = 10000000,
       cost_note = '10,000,000 credits (Rifts Book of Magic printed 316). Atlantis printed 154 gave twenty million credits, because its M.D.C. renews perpetually.',
       weight_lbs = 1,
       description = description || ' Cost and weight are Rifts Book of Magic printed 316, the newer printing; the other columns agree with Atlantis printed 154. Atlantis gave twenty million credits and no weight; this row carried that price until ~237.',
       source_book = 'Rifts Book of Magic p.316'
 WHERE slug = 'talisman-of-armor'
   AND cost = 20000000
   AND source_book = 'Rifts World Book 2: Atlantis p.154';

UPDATE gear
   SET cost = 150000,
       cost_note = '150,000 credits for the rifle; 40,000 credits for each clip (Rifts Book of Magic printed 325). Federation of Magic printed 115 gave 125,000 credits for the rifle (Black Market).',
       description = description || ' Cost is Rifts Book of Magic printed 325, the newer printing; the other columns agree with Federation of Magic printed 115, whose 125,000 credits for the rifle this row carried until ~237.',
       source_book = 'Rifts Book of Magic p.325'
 WHERE slug = 'tw-fireburst-rifle'
   AND cost = 125000
   AND source_book = 'Rifts World Book 16: Federation of Magic p.115';

UPDATE gear
   SET damage = '1D6x10 M.D. per shot; 3D6 M.D. at a ley line',
       description = description || ' Damage is Rifts Book of Magic printed 325, the newer printing; the other columns agree with Federation of Magic printed 115. Federation of Magic gave 1D6x10+10 M.D. per shot (three force bolts) and nothing for a ley line; this row carried that damage until ~237.',
       source_book = 'Rifts Book of Magic p.325'
 WHERE slug = 'tw-force-cannon'
   AND damage = '1D6x10+10 M.D. per shot (three force bolts)'
   AND source_book = 'Rifts World Book 16: Federation of Magic p.115';

UPDATE gear
   SET cost_note = '20,000-35,000 credits in Manoa, rarely found elsewhere (Rifts Book of Magic printed 313). South America printed 92 gave 20,000 credits.',
       payload = '24 shots with a TW-Cell, or 15 P.P.E. per individual blast',
       description = description || ' The cost range and the P.P.E. payload are Rifts Book of Magic printed 313, the newer printing; the other columns agree with South America printed 92, which gave 20,000 credits flat and 24 shots with a TW-Cell with no P.P.E. option; this row carried those until ~237.',
       source_book = 'Rifts Book of Magic p.313'
 WHERE slug = 'manoan-fireball-rifle'
   AND cost_note IS NULL
   AND source_book = 'Rifts World Book 6: South America p.92';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the four rows carry the Book of Magic figures' AS assertion, count(*) AS got, 4 AS want
  FROM gear
 WHERE (slug = 'talisman-of-armor' AND cost = 10000000 AND weight_lbs = 1
        AND instr(cost_note, 'Atlantis printed 154 gave twenty million') > 0
        AND source_book = 'Rifts Book of Magic p.316')
    OR (slug = 'tw-fireburst-rifle' AND cost = 150000 AND instr(cost_note, '40,000 credits for each clip') > 0
        AND source_book = 'Rifts Book of Magic p.325')
    OR (slug = 'tw-force-cannon' AND damage = '1D6x10 M.D. per shot; 3D6 M.D. at a ley line' AND cost = 300000
        AND source_book = 'Rifts Book of Magic p.325')
    OR (slug = 'manoan-fireball-rifle' AND cost = 20000 AND instr(cost_note, '20,000-35,000 credits') > 0
        AND instr(payload, '15 P.P.E. per individual') > 0
        AND source_book = 'Rifts Book of Magic p.313');

SELECT 'each keeps the older figure with its page' AS assertion, count(*) AS got, 4 AS want
  FROM gear
 WHERE slug IN ('talisman-of-armor', 'tw-fireburst-rifle', 'tw-force-cannon', 'manoan-fireball-rifle')
   AND instr(description, 'until ~237') > 0
   AND (instr(description, 'Atlantis printed 154') > 0
        OR instr(description, 'Federation of Magic printed 115') > 0
        OR instr(description, 'South America printed 92') > 0);

INSERT INTO data_script_runs (filename) VALUES ('~237-book-ingest-audit-f144-four-gear.sql');
