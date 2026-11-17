-- Northern Gun Two: nine held gear rows brought to this book's printing.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~339-northern-gun-2-held-price-fixes.sql
--
-- Nate's ruling of 2026-10-04: where two printings disagree, the newest
-- printing that states a figure wins, the older figure kept in the description.
-- Read off the cached pages of Rifts World Book 34 (text layer, no substituted
-- digits recorded for this book).
--
--   1. Five gear twins of vehicles that ~333 re-cited. Each takes its vehicles
--      row's cost and cost_note (copied by subquery, so the two cannot drift),
--      this book's citation, and a lead sentence naming the figures that
--      supersede the older text that follows it.
--   2. ng-wild-coyote-jet-pack. The book prints the pack twice: in the Coyote's
--      entry (p.77: 70,000 electric, 290,000 Solid Oxide, 910,000 nuclear) and
--      in the pack's own entry (printed 193: 85,000, 375,000, 890,000). The
--      pack's own entry wins; p.77 goes in the description. Stored cost stays
--      52,000 (combustion, the lowest), which both agree on.
--   3. Three held rows this book prints again: ng-icss-combat-and-survival-
--      shelter (1,000, held 800-1000), ng-ccs-command-and-control-shelter
--      (3,600, held 3,000), rocket-boots (NG-RB-5, p.252: 12 M.D.C. each,
--      2,000-4,000 to build into armor, held 2,000).
--
-- Guarded on each row still citing its older book, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

UPDATE gear
   SET cost = (SELECT cost FROM vehicles WHERE slug = 'the-wastelander-motorcycle'),
       cost_note = (SELECT cost_note FROM vehicles WHERE slug = 'the-wastelander-motorcycle'),
       description = 'Northern Gun Two (p.204-205) supersedes these figures in the older text that follows: M.D.C. main body 66 and tires 5 each; gasoline, electric, Solid Oxide or nuclear power, 400 miles (640 km) on gasoline and 3,000 miles (4,800 km) per charge on the upgraded battery; no weapon is standard and one light hovercycle weapon costs extra; electric 28,500 credits, Solid Oxide 385,000, nuclear 880,000. The machinegun and laser prices below are the older printing''s. ' || description,
       source_book = 'Rifts World Book 34: Northern Gun Two p.204-205'
 WHERE slug = 'the-wastelander-motorcycle'
   AND source_book = 'Rifts Ultimate Edition p.266';

UPDATE gear
   SET cost = (SELECT cost FROM vehicles WHERE slug = 'speedster-hovercycle'),
       cost_note = (SELECT cost_note FROM vehicles WHERE slug = 'speedster-hovercycle'),
       description = 'Northern Gun Two (p.169-170) supersedes these figures in the older text that follows: M.D.C. main body 75 (a deluxe armored model has 97 at 30% more cost); maximum 220 mph (352 km) and altitude 120 feet (36.6 m); 80,000 credits gasoline, 98,000 electric, 600,000 Solid Oxide, 950,000 nuclear; any hovercycle weapon can go on each side at the front and on the back, each cutting speed by 5%, and weapons are full price. The laser, machine-gun and mini-missile figures below are the older printing''s. ' || description,
       source_book = 'Rifts World Book 34: Northern Gun Two p.169-170'
 WHERE slug = 'speedster-hovercycle'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET cost = (SELECT cost FROM vehicles WHERE slug = 'big-boss-atv'),
       cost_note = (SELECT cost_note FROM vehicles WHERE slug = 'big-boss-atv'),
       description = 'Northern Gun Two (p.209-210) supersedes the older text that follows: 16 feet (4.9 m) long; three Armored Tires of 18 M.D.C. each; a sunroof and a swivel-mounted laser rifle are standard, the rifle and its E-Clips sold separately; every power system is offered, 300 miles (480 km) on gasoline and 1,000 miles (1,600 km) per charge on the advanced battery; it pulls 4 tons and takes up to three hovercycle weapons at the front. ' || description,
       source_book = 'Rifts World Book 34: Northern Gun Two p.209-210'
 WHERE slug = 'big-boss-atv'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET cost = (SELECT cost FROM vehicles WHERE slug = 'mountaineer-atv'),
       cost_note = (SELECT cost_note FROM vehicles WHERE slug = 'mountaineer-atv'),
       description = 'Northern Gun Two (p.213-214) supersedes the older text that follows: sold new at 138,000 credits (the 76,000 and 500,000 Black Market prices are for used rigs); three Armored Super-Tires; height 5.5 m; carries 40 tons and pulls 20 more; no weapon is standard, and up to six hovercycle weapons or two heavy vehicle weapons can be added. ' || description,
       source_book = 'Rifts World Book 34: Northern Gun Two p.213-214'
 WHERE slug = 'mountaineer-atv'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET cost = (SELECT cost FROM vehicles WHERE slug = 'rolling-thunder-apv'),
       cost_note = (SELECT cost_note FROM vehicles WHERE slug = 'rolling-thunder-apv'),
       description = 'Northern Gun Two (p.217-219) supersedes the older text that follows: 635,000 credits new for the flex-fuel model (275,000 used), full electric 758,000, Solid Oxide 895,000, nuclear 1.1 million; a rear mini-missile launcher of six mini-missiles; the mine layer is now an optional alternative with six mines, not twelve standard; the rail gun belt is 2,000 rounds; wheels and particle beams are -4 on a called shot; height 5 feet 6 inches (1.7 m). It now sells poorly and may be discontinued. ' || description,
       source_book = 'Rifts World Book 34: Northern Gun Two p.217-219'
 WHERE slug = 'rolling-thunder-apv'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.77-88';

-- The Wild Coyote Jet Pack, its own entry printed 193.

UPDATE gear
   SET cost_note = '52,000 credits combustion, 85,000 electric, 375,000 Solid Oxide, 890,000 nuclear; the lowest is stored. Wiring it into a power armor''s supply costs 385,000. Standard with the Coyote power armor.',
       description = description || ' The Coyote''s own entry (p.77) prints electric 70,000, Solid Oxide 290,000 and nuclear 910,000; the pack''s entry (printed 193), which this row follows, prints 85,000, 375,000 and 890,000.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.77, 193'
 WHERE slug = 'ng-wild-coyote-jet-pack'
   AND source_book = 'Rifts World Book 34: Northern Gun Two p.77';

-- Shelters and rocket boots, printed 252 and 254.

UPDATE gear
   SET cost = 1000,
       cost_note = '1,000 credits; common. An M.D.C. version costs 6,000 (held as ng-icss-combat-and-survival-shelter-mdc).',
       description = description || ' Adventures in Dinosaur Swamp p.158, which this row followed before Northern Gun Two, priced it at 800-1000 credits; Northern Gun Two (p.254) prints 1,000.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.254'
 WHERE slug = 'ng-icss-combat-and-survival-shelter'
   AND source_book = 'Rifts World Book 27: Adventures in Dinosaur Swamp p.158';

UPDATE gear
   SET cost = 3600,
       cost_note = '3,600 credits for the standard S.D.C. fabric; common. The M.D.C. version costs 36,000 (held as ng-ccs-command-and-control-shelter-mdc).',
       description = description || ' Adventures in Dinosaur Swamp p.158, which this row followed before Northern Gun Two, priced it at 3,000 credits; Northern Gun Two (p.254) prints 3,600 for the S.D.C. fabric.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.254'
 WHERE slug = 'ng-ccs-command-and-control-shelter'
   AND source_book = 'Rifts World Book 27: Adventures in Dinosaur Swamp p.158';

UPDATE gear
   SET cost_note = '30,000 credits (Black market); 2,000-4,000 more to build into a suit of mega-damage environmental armor',
       mdc = 12,
       description = description || ' Northern Gun Two (p.252) sells it as the NG-RB-5 Rocket Boots: 12 M.D.C. each, 20 jumps per standard E-Clip, no hovering or flight, 30,000 credits and 2,000-4,000 more to build into mega-damage environmental armor; Juicer Uprising printed 2,000.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.252'
 WHERE slug = 'rocket-boots'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.61-71';

-- Read-backs.

SELECT 'the five twins cite Northern Gun Two and carry their vehicle''s cost' AS assertion, count(*) AS got, 5 AS want
  FROM gear g JOIN vehicles v ON v.slug = g.slug
 WHERE g.slug IN ('the-wastelander-motorcycle', 'speedster-hovercycle', 'big-boss-atv', 'mountaineer-atv', 'rolling-thunder-apv')
   AND g.source_book = v.source_book AND g.cost = v.cost AND g.cost_note = v.cost_note
   AND g.source_book LIKE 'Rifts World Book 34: Northern Gun Two p.%';

SELECT 'the jet pack follows its own entry' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'ng-wild-coyote-jet-pack' AND cost = 52000
   AND instr(cost_note, '85,000 electric, 375,000 Solid Oxide, 890,000 nuclear') > 0
   AND source_book = 'Rifts World Book 34: Northern Gun Two p.77, 193';

SELECT 'the shelters and boots cite Northern Gun Two' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'ng-icss-combat-and-survival-shelter' AND cost = 1000 AND source_book LIKE '%Northern Gun Two p.254')
    OR (slug = 'ng-ccs-command-and-control-shelter' AND cost = 3600 AND source_book LIKE '%Northern Gun Two p.254')
    OR (slug = 'rocket-boots' AND cost = 30000 AND mdc = 12 AND source_book LIKE '%Northern Gun Two p.252');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~339-northern-gun-2-held-price-fixes.sql');
