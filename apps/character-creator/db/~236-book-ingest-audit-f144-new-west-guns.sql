-- Six New West Techno-Wizard guns take the Book of Magic's figures (BOOK-INGEST-AUDIT F144).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~236-book-ingest-audit-f144-new-west-guns.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~236-book-ingest-audit-f144-new-west-guns.sql
--
-- Nate's ruling of 2026-10-04: the newest printing that STATES a figure wins,
-- and the older figure is kept in the row's notes with its page. 2026-10-12: a
-- row taking the Book of Magic's figure moves its source_book there.
-- 2026-10-19: the Spitfire Revolver's and the Thundergun's ranges are taken as
-- the Book of Magic prints them, although they look swapped against New West.
--
--   tw-snare-gun                 New West printed 217 (1998) -> Rifts Book of
--                                Magic printed 326 (2001): cost 45,000 ->
--                                175,000 plus 40,000 per clip; range 200 ft ->
--                                600 ft; two nets reloaded for 10 P.P.E. or
--                                20 I.S.P. -> Stormspire's 8 nets per clip,
--                                others two, 12 P.P.E. or 24 I.S.P. per two.
--   tw-thundergun                printed 215 -> 324: cost 60,000 -> 70,000;
--                                range 500 ft -> 200 ft; recharge 15 P.P.E. or
--                                30 I.S.P. -> 10 P.P.E. or 20 I.S.P.
--   tw-spitfire-revolver         printed 215 -> 324: cost 60,000 -> 65,000;
--                                range 200 ft -> 500 ft.
--   tw-super-six-carbine         printed 215 -> 326: cost 75,000 -> 80,000.
--   tw-eagle-eye-marksman-rifle  printed 216 -> 325: cost 75,000 -> 80,000.
--   tw-hellfire-shotgun          printed 217 -> 325: cost 65,000 -> 60,000. The
--                                Book of Magic prints no weight, so 5 lbs stays.
--
-- gear has no notes column: New West's cost is kept in cost_note and its
-- range, payload or recharge in description, each with its page. Two
-- descriptions compared the old figures with the rest of New West's line (the
-- Spitfire as the shortest ranged, the Snare Gun as the cheapest long arm);
-- those comparisons are now credited to New West. Metric roundings alone
-- (457 vs 457.2 m, 548 vs 548.6 m) are not taken. Every other column matched.
-- Figures were read off 150 dpi renders of both books on 2026-10-18.
--
-- No slug or name changes, so no class's equipment pointer and no saved
-- character's pick moves.
--
-- Each UPDATE is guarded on the New West citation and cost it replaces, so a
-- re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: six gear rows. The tilde
-- number is claimed at merge.

UPDATE gear
   SET cost = 175000,
       cost_note = '175,000 credits, plus 40,000 credits per clip (Rifts Book of Magic printed 326). New West printed 217 gave 45,000 credits and poor availability.',
       range = '600 feet (183 m)',
       payload = 'Stormspire''s model holds 8 magic nets per clip; other makers'' guns hold two. Reloading two nets costs 12 P.P.E. or 24 I.S.P. (Rifts Book of Magic printed 326).',
       description = 'A double-barrelled, sawed-off shotgun or flare gun that fires a magic net with each pull of the trigger, at 5th level spell strength. It TAKES rather than kills, which is why it is a favourite of bounty hunters and lawmen. Weight typically 3 to 5 lbs. CREATION: initial P.P.E. cost 45; spells needed Energy Bolt (5) and Magic Net (7); physically a short, double barrelled, sawed-off shotgun and a clear crystal worth 300 credits or more; about 40 hours of work. BONUS NOTE: no bonuses apply. Cost, range and payload are Rifts Book of Magic printed 326, the newer printing; the other columns agree with New West printed 217. New West gave 45,000 credits, flat rather than a "plus" figure, which made it the cheapest of that book''s TW long arms; a range of 200 feet (61 m); and two magic net blasts, reloading two more costing 10 P.P.E. or 20 I.S.P. and one melee action, with conventional rounds or flares loadable by hand only once both barrels are spent. New West''s price was read off a render of its printed 217, one of that book''s three glyph-corrupt pages. This row carried New West''s figures until ~236.',
       source_book = 'Rifts Book of Magic p.326'
 WHERE slug = 'tw-snare-gun'
   AND cost = 45000
   AND source_book = 'Rifts World Book 14: New West p.217';

UPDATE gear
   SET cost = 70000,
       cost_note = '70,000 credits (Rifts Book of Magic printed 324). New West printed 215 gave 60,000+ credits, fair availability, and a 10% discount for famed champions of good or fellow mages of renown.',
       range = '200 feet (61 m)',
       payload = '6 shots, whether enchanted silver bullets or conventional rounds; conventional bullets have no special properties. Enchanting six more silver bullets costs 10 P.P.E. or 20 I.S.P., and works ONLY on bullets coated with or made of silver.',
       description = description || ' Cost, range and the recharge are Rifts Book of Magic printed 324, the newer printing; the other columns agree with New West printed 215. New West gave 60,000+ credits, a range of 500 feet (152 m), and 15 P.P.E. or 30 I.S.P. to enchant six more silver bullets; this row carried those figures until ~236.',
       source_book = 'Rifts Book of Magic p.324'
 WHERE slug = 'tw-thundergun'
   AND cost = 60000
   AND source_book = 'Rifts World Book 14: New West p.215';

UPDATE gear
   SET cost = 65000,
       cost_note = '65,000 credits (Rifts Book of Magic printed 324). New West printed 215 gave 60,000+ credits, fair availability, and a 10% discount for famed champions of good or fellow mages of renown.',
       range = '500 feet (152 m)',
       description = 'A large, heavy revolver based on the old Wells Fargo .31 caliber single action revolver, with all the same basic features as the TW Six-Gun but shooting magical, mega-damage mini-fire balls. CREATION: initial P.P.E. cost 60; spells needed Energy Bolt (7) and Fire Balls (10); physically a Wells Fargo .31 caliber revolver and a diamond worth 2000 credits or more; about 60 hours of work. BONUS NOTE: the character''s usual W.P. and O.C.C. bonuses to strike with a revolver apply. Cost and range are Rifts Book of Magic printed 324, the newer printing; the other columns agree with New West printed 215. New West gave 60,000+ credits and a range of 200 feet (61 m), which made it the shortest ranged gun in that book''s TW line; this row carried those figures until ~236.',
       source_book = 'Rifts Book of Magic p.324'
 WHERE slug = 'tw-spitfire-revolver'
   AND cost = 60000
   AND source_book = 'Rifts World Book 14: New West p.215';

UPDATE gear
   SET cost = 80000,
       cost_note = '80,000 credits (Rifts Book of Magic printed 326). New West printed 215 gave 75,000+ credits; fairly common with fair to good availability, and a 10% to 20% discount for famed champions of good or fellow mages of renown.',
       description = description || ' Cost is Rifts Book of Magic printed 326, the newer printing; the other columns agree with New West printed 215, whose 75,000+ credits this row carried until ~236.',
       source_book = 'Rifts Book of Magic p.326'
 WHERE slug = 'tw-super-six-carbine'
   AND cost = 75000
   AND source_book = 'Rifts World Book 14: New West p.215';

UPDATE gear
   SET cost = 80000,
       cost_note = '80,000 credits (Rifts Book of Magic printed 325). New West printed 216 gave 75,000+ credits, fair availability, and a 10% to 20% discount for famed champions of good or fellow mages of renown.',
       description = description || ' Cost is Rifts Book of Magic printed 325, the newer printing; the other columns agree with New West printed 216, whose 75,000+ credits this row carried until ~236.',
       source_book = 'Rifts Book of Magic p.325'
 WHERE slug = 'tw-eagle-eye-marksman-rifle'
   AND cost = 75000
   AND source_book = 'Rifts World Book 14: New West p.216';

UPDATE gear
   SET cost = 60000,
       cost_note = '60,000 credits (Rifts Book of Magic printed 325). New West printed 217 gave 65,000+ credits, fair availability, and a 10% discount for famed champions of good or fellow mages of renown.',
       description = 'A heavy, double-barrelled, sawed-off shotgun that shoots devastating magic fire balls with each pull of the trigger. Weight typically 5 to 6 lbs. CREATION: initial P.P.E. cost 55; spells needed Ignite Fire (6), Fire Bolt (7) and Fireball (10); physically a heavy, double barrelled, sawed-off shotgun and a rose quartz or red or orange sapphire worth 1000 credits or more; about 60 hours of work. BONUS NOTE: no bonuses for shotguns, but the SPELL bonuses and effects all apply. Cost is Rifts Book of Magic printed 325, the newer printing, which prints no weight, so the 5 lbs is New West''s; the other columns agree with New West printed 217. New West gave 65,000+ credits, read off a render of its printed 217, one of that book''s three glyph-corrupt pages; this row carried that price until ~236.',
       source_book = 'Rifts Book of Magic p.325'
 WHERE slug = 'tw-hellfire-shotgun'
   AND cost = 65000
   AND source_book = 'Rifts World Book 14: New West p.217';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the six guns carry the Book of Magic figures' AS assertion, count(*) AS got, 6 AS want
  FROM gear
 WHERE (slug = 'tw-snare-gun' AND cost = 175000 AND range = '600 feet (183 m)'
        AND instr(payload, '8 magic nets per clip') > 0 AND instr(payload, '12 P.P.E. or 24 I.S.P.') > 0
        AND source_book = 'Rifts Book of Magic p.326')
    OR (slug = 'tw-thundergun' AND cost = 70000 AND range = '200 feet (61 m)'
        AND instr(payload, '10 P.P.E. or 20 I.S.P.') > 0 AND instr(payload, '15 P.P.E.') = 0
        AND source_book = 'Rifts Book of Magic p.324')
    OR (slug = 'tw-spitfire-revolver' AND cost = 65000 AND range = '500 feet (152 m)'
        AND source_book = 'Rifts Book of Magic p.324')
    OR (slug = 'tw-super-six-carbine' AND cost = 80000 AND source_book = 'Rifts Book of Magic p.326')
    OR (slug = 'tw-eagle-eye-marksman-rifle' AND cost = 80000 AND source_book = 'Rifts Book of Magic p.325')
    OR (slug = 'tw-hellfire-shotgun' AND cost = 60000 AND weight_lbs = 5 AND source_book = 'Rifts Book of Magic p.325');

SELECT 'each keeps New West''s figure with its page' AS assertion, count(*) AS got, 6 AS want
  FROM gear
 WHERE slug IN ('tw-snare-gun', 'tw-thundergun', 'tw-spitfire-revolver', 'tw-super-six-carbine', 'tw-eagle-eye-marksman-rifle', 'tw-hellfire-shotgun')
   AND instr(cost_note, 'New West printed 21') > 0
   AND instr(description, 'until ~236') > 0;

SELECT 'no description still compares a New West figure as current' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE slug IN ('tw-snare-gun', 'tw-spitfire-revolver', 'tw-hellfire-shotgun')
   AND (instr(description, 'The shortest ranged gun in the TW line') > 0
        OR instr(description, 'The cheapest of this book') > 0
        OR instr(description, 'THE PRICE WAS READ OFF A RENDER') > 0);

INSERT INTO data_script_runs (filename) VALUES ('~236-book-ingest-audit-f144-new-west-guns.sql');
