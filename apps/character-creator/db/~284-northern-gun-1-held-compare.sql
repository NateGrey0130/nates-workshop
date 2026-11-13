-- Four Northern Gun weapons the catalog already held follow Rifts World Book
-- 33: Northern Gun One, their newest printing.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~284-northern-gun-1-held-compare.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~284-northern-gun-1-held-compare.sql
--
-- Northern Gun One reprints eleven weapons production already held under
-- older citations (Rifts Ultimate Edition and Rifts World Book 10: Juicer
-- Uprising). Each was read off a render of Northern Gun One (PDF offset +1,
-- printed 191-210) and compared with the held row read whole from production
-- on 2026-11-13. By Nate's rulings of 2026-10-04 (the newest printing that
-- states a figure wins) and 2026-11-13 (the held row takes this book's figure
-- and its citation, and the older figure goes in the description), a row
-- where a figure differs is UPDATED in place, its source_book moves to
-- Northern Gun One, and one sentence appended to description gives the older
-- figure and the book it came from. Name and slug are unchanged.
--
-- A column counts as differing when this book prints another value for it,
-- or prints one where the held column is empty. A Block II or Block III
-- figure this book adds beside an unchanged Block I figure is an addition,
-- not a difference; neither is a metric conversion of an unchanged imperial
-- figure on a row nothing else moves. A row that does change takes this
-- book's metric figure too.
--
-- Edited (4):
--   ng-super-laser-pistol-and-grenade-launcher (p.191): cost, rate of fire.
--   ng-11s-sawed-off (p.208): weight, range, reload time, cost.
--   ng-101-rail-gun (p.209): cost, range in metres.
--   ng-202-rail-gun (p.209-210): payload, range in metres.
--
-- Left as they are, citation included, because the render shows no
-- differing figure (7):
--   ng-33-northern-gun-laser-pistol (p.191; adds a 2D4 M.D. Block II).
--   ng-45lp-long-pistol (p.191-192; 366 m where the row says 365 m for the
--     same 1,200 feet).
--   ng-l5-northern-gun-laser-rifle (p.192; adds lighter Block II and III).
--   ng-h5-holdout-ion-pistol (p.198; still 50,000 credits, and adds a recent
--     cut to 35,000 list).
--   ng-57-northern-gun-heavy-duty-ion-blaster (p.199; adds a 15,000 official
--     list price beside the 8,000 it sells for).
--   ng-ip7-ion-pulse-rifle (p.199; adds 15 shots per single standard E-Clip).
--   ng-p7-northern-gun-particle-beam-rifle (p.202; adds a long E-Clip of 12
--     and lighter Block II and III).
--
-- Guarded on each row still citing its older book, so a re-run is a no-op.
-- No row is inserted. THIS SCRIPT CHANGES PRODUCTION. The tilde number is
-- claimed at merge.

UPDATE gear
   SET cost = 21000,
       cost_note = 'List price; used ones sell for 11,000-15,000 credits and new ones are often on sale in that range. Grenades 400 credits each or 3,800 a dozen',
       rate_of_fire = 'Each grenade or laser blast counts as one melee attack',
       description = description || ' Rifts Ultimate Edition, which this row followed before Northern Gun One, printed no price and let the launcher put four grenades out in quick succession as a burst or a wild spray.',
       source_book = 'Rifts World Book 33: Northern Gun One p.191'
 WHERE slug = 'ng-super-laser-pistol-and-grenade-launcher'
   AND source_book = 'Rifts Ultimate Edition';

UPDATE gear
   SET weight_lbs = 4,
       cost = 6000,
       cost_note = 'Explosive shells 150 credits each and APRJ rounds 200 credits each at most places; poor availability and rising prices',
       range = 'Shotgun shells and slugs 200 feet (61 m); explosive shells 300 feet (91.5 m); APRJ 500 feet (152 m)',
       payload = 'Two shots; reloading takes three melee actions',
       description = description || ' Juicer Uprising, which this row followed before Northern Gun One, gave it a weight of 3 lbs, a reach of 300 feet for shells and slugs and 500 feet for explosive shells, a reload of one full melee round and a black market price of 4,000 credits.',
       source_book = 'Rifts World Book 33: Northern Gun One p.208'
 WHERE slug = 'ng-11s-sawed-off'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.71-76';

UPDATE gear
   SET cost = 70000,
       cost_note = 'Gun and power pack; used NG-101s sell for 35,000-40,000 credits',
       range = '4,000 feet (1,219 m)',
       description = description || ' Rifts Ultimate Edition, which this row followed before Northern Gun One, priced it at 55,000 credits and put its range at 1200 m.',
       source_book = 'Rifts World Book 33: Northern Gun One p.209'
 WHERE slug = 'ng-101-rail-gun'
   AND source_book = 'Rifts Ultimate Edition p.270';

UPDATE gear
   SET payload = '320 round belt (8 bursts), or a 2,400 round drum (60 bursts) weighing 175 lbs (79 kg)',
       range = '4,000 feet (1,219 m)',
       description = description || ' Rifts Ultimate Edition, which this row followed before Northern Gun One, fed it from a 300 round belt and put its range at 1200 m.',
       source_book = 'Rifts World Book 33: Northern Gun One p.209-210'
 WHERE slug = 'ng-202-rail-gun'
   AND source_book = 'Rifts Ultimate Edition p.271';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the four differing rows cite Northern Gun One' AS assertion, count(*) AS got, 4 AS want
  FROM gear
 WHERE (slug = 'ng-super-laser-pistol-and-grenade-launcher' AND source_book = 'Rifts World Book 33: Northern Gun One p.191')
    OR (slug = 'ng-11s-sawed-off' AND source_book = 'Rifts World Book 33: Northern Gun One p.208')
    OR (slug = 'ng-101-rail-gun' AND source_book = 'Rifts World Book 33: Northern Gun One p.209')
    OR (slug = 'ng-202-rail-gun' AND source_book = 'Rifts World Book 33: Northern Gun One p.209-210');

SELECT 'the four rows carry this book''s figures' AS assertion, count(*) AS got, 4 AS want
  FROM gear
 WHERE (slug = 'ng-super-laser-pistol-and-grenade-launcher' AND cost = 21000
        AND rate_of_fire = 'Each grenade or laser blast counts as one melee attack')
    OR (slug = 'ng-11s-sawed-off' AND weight_lbs = 4 AND cost = 6000
        AND range LIKE 'Shotgun shells and slugs 200 feet%'
        AND payload = 'Two shots; reloading takes three melee actions')
    OR (slug = 'ng-101-rail-gun' AND cost = 70000 AND range = '4,000 feet (1,219 m)')
    OR (slug = 'ng-202-rail-gun' AND range = '4,000 feet (1,219 m)'
        AND payload LIKE '320 round belt%');

SELECT 'the seven matching rows keep their older citation' AS assertion, count(*) AS got, 7 AS want
  FROM gear
 WHERE slug IN ('ng-33-northern-gun-laser-pistol', 'ng-45lp-long-pistol',
                'ng-l5-northern-gun-laser-rifle', 'ng-h5-holdout-ion-pistol',
                'ng-57-northern-gun-heavy-duty-ion-blaster', 'ng-ip7-ion-pulse-rifle',
                'ng-p7-northern-gun-particle-beam-rifle')
   AND source_book NOT LIKE 'Rifts World Book 33:%';

INSERT INTO data_script_runs (filename) VALUES ('~284-northern-gun-1-held-compare.sql');
