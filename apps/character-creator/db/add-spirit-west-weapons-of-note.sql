-- Weapons of Note - the priced gear on printed 203 of Rifts World Book 15:
-- Spirit West. 13 new rows and one note on an existing row.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-spirit-west-weapons-of-note.sql
--
-- The book has a TEXT LAYER; offset +1, so printed 203 is cache p204. It is
-- not on the welded or glyph-corrupt list. The Light Explosive arrowhead's
-- "!D6xlO" is the digit substitution of BOOK-INGEST-AUDIT F53 (1D6x10).
--
-- WHAT THE PAGE HOLDS, and what was already here:
--
--   NA-LB1 Laser Bow, NA-SW4 M.D.C. Bow and its arrows    new
--   high-tech arrowheads: seven of nine                    ALREADY HELD, from
--                                                          Triax p.150, at the
--                                                          same prices
--   Neural Disrupter and Tracer Bug arrowheads             new
--   Smoke arrowhead, 80 credits                            HELD at 60 (Triax);
--                                                          not overwritten - the
--                                                          Spirit West figure
--                                                          goes in cost_note
--   six bows and crossbows priced in CREDITS               new
--   Vibro-Axe or Tomahawk, Vibro-Spear                     new
--
-- THE BOWS ARE NEW ROWS, NOT THE CATALOG'S. short-bow, long-bow and cross-bow
-- are Palladium Fantasy rows priced in gold; a gold price is not a credit
-- price. Printed 203 prices bows built with modern materials for characters
-- who lack Carpentry (anyone with it makes one free), so the names say so. No
-- damage is stored for them: the page points at W.P. Archery and Targeting in
-- the Rifts RPG for S.D.C. damage and range, and gives only the ceiling.
--
-- No production row collided with any slug below (checked 2026-09-10).

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('na-lb1-laser-bow', 'NA-LB1 Laser Bow', 'rifts', 'weapon', 4, 8000, '8,000 credits, Black Market', '2D6 M.D.', 1, '1,000 feet (305 m)', 'Effectively unlimited; the draw cord and plunger wear out after about 500 shots. An E-clip port (20 shots) backs up a broken string or jammed plunger.', 'Single shot.', NULL, NULL, NULL, 'A compound bow with a laser discharger where the arrow would sit: drawing the cable drives a plunger generator that charges one shot, fired on release or stored in a small battery for one push-button shot. It cannot fire arrows. Needs P.S. 12 or more to draw. Made by high-tech Modern Indian communities and sold through Bandito Arms and Northern Gun.', 'Rifts World Book 15: Spirit West p.203'),
('na-sw4-mdc-bow', 'NA-SW4 M.D.C. Bow', 'rifts', 'weapon', 24, 18000, '18,000 credits for the bow; its M.D.C. arrows are a separate row', 'Ordinary arrows +3D6 S.D.C. (and may shatter); M.D.C. arrows 2D6 M.D.', 1, '1,500 feet (450 m)', 'Six arrows clip onto the bow; quivers hold 12, 20 or 24.', '2 to 8; see W.P. Archery and Targeting in the Rifts RPG.', NULL, NULL, NULL, 'A compound bow of M.D.C. materials for Spirit Warriors and others with supernatural strength, with a pull of nearly 1,000 pounds eased by its pulleys. A human cannot draw it without a P.S. of 21, and the book puts full non-supernatural use at P.S. 35; a supernatural P.S. of 18 or more uses it fully.', 'Rifts World Book 15: Spirit West p.203'),
('mdc-arrow', 'M.D.C. Arrow', 'rifts', 'gear', 3.5, 80, '80 credits each', '2D6 M.D. from the NA-SW4 M.D.C. Bow', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'An arrow of M.D.C. material about three times as thick as a normal one, made for the NA-SW4 M.D.C. Bow.', 'Rifts World Book 15: Spirit West p.203'),
('arrowhead-neural-disrupter', 'Arrowhead: Neural Disrupter', 'rifts', 'gear', NULL, 400, '400 credits', 'Works like a neural mace', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A high-tech arrowhead that stuns like a neural mace. Fits bows ancient and modern and crossbows; special arrowheads weigh 1 to 2 lbs.', 'Rifts World Book 15: Spirit West p.203'),
('arrowhead-tracer-bug', 'Arrowhead: Tracer Bug', 'rifts', 'gear', NULL, 200, '200 credits', 'None; transmits a tracking signal', 0, '8 miles (12 km) transmission', NULL, NULL, NULL, NULL, NULL, 'A high-tech arrowhead carrying a tracking transmitter. Fits bows ancient and modern and crossbows; special arrowheads weigh 1 to 2 lbs.', 'Rifts World Book 15: Spirit West p.203'),
('short-bow-modern-materials', 'Short Bow (modern materials)', 'rifts', 'weapon', NULL, 200, '200 credits', NULL, 0, 'Varies with the bow; the page gives a ceiling of about 700 feet (213 m)', NULL, '2 to 8; see W.P. Archery and Targeting in the Rifts RPG.', NULL, NULL, NULL, 'A short bow built with modern materials. A character with Carpentry makes a bow for nothing; this is the price for one who must buy it. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('long-bow-modern-materials', 'Long Bow (modern materials)', 'rifts', 'weapon', NULL, 400, '400 to 600 credits', NULL, 0, 'Varies with the bow; the page gives a ceiling of about 700 feet (213 m)', NULL, '2 to 8; see W.P. Archery and Targeting in the Rifts RPG.', NULL, NULL, NULL, 'A long bow built with modern materials. A character with Carpentry makes a bow for nothing; this is the price for one who must buy it. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('modern-bow', 'Modern Bow', 'rifts', 'weapon', NULL, 500, '500 to 1,200 credits', NULL, 0, 'Varies with the bow; the page gives a ceiling of about 700 feet (213 m)', NULL, '2 to 8; see W.P. Archery and Targeting in the Rifts RPG.', NULL, NULL, NULL, 'A modern bow, such as a compound bow. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('crossbow-modern-materials', 'Crossbow (modern materials)', 'rifts', 'weapon', NULL, 400, '400 to 600 credits', NULL, 0, 'Varies with the bow; the page gives a ceiling of about 700 feet (213 m)', NULL, NULL, NULL, NULL, NULL, 'A crossbow built with modern materials. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('crossbow-pistol', 'Crossbow Pistol', 'rifts', 'weapon', NULL, 200, '200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A pistol crossbow. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('modern-crossbow', 'Modern Crossbow', 'rifts', 'weapon', NULL, 600, '600 to 1,200 credits', NULL, 0, 'Varies with the bow; the page gives a ceiling of about 700 feet (213 m)', NULL, NULL, NULL, NULL, NULL, 'A modern crossbow. S.D.C. damage per W.P. Archery and Targeting in the Rifts RPG.', 'Rifts World Book 15: Spirit West p.203'),
('vibro-axe-or-tomahawk', 'Vibro-Axe or Tomahawk', 'rifts', 'weapon', NULL, 1600, '1,600 credits, Black Market', '1D6+3 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'An axe or tomahawk wrapped in the invisible high-frequency field every Vibro-Blade carries, giving it mega-damage capability.', 'Rifts World Book 15: Spirit West p.203'),
('vibro-spear', 'Vibro-Spear', 'rifts', 'weapon', NULL, 2500, '2,500 credits, Black Market', '2D6+2 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'A spear wrapped in a Vibro-Blade''s high-frequency field, giving it mega-damage capability.', 'Rifts World Book 15: Spirit West p.203');

-- The Smoke arrowhead: Triax p.150 prices it at 60 and Spirit West p.203 at 80.
-- A disagreement is not a gap: the cost stays, and the second reading is
-- recorded beside it, the shape PR #908 used for three New West armour prices.
-- Guarded, so a second run changes nothing.
UPDATE gear
   SET cost_note = cost_note || '. Rifts World Book 15: Spirit West p.203 prices it at 80 credits.'
 WHERE slug = 'arrowhead-smoke'
   AND instr(coalesce(cost_note, ''), 'Spirit West') = 0;

-- Read the result back. Every want is from the page, not the database.
SELECT 'the 13 new rows' AS assertion, count(*) AS got, 13 AS want
  FROM gear WHERE source_book = 'Rifts World Book 15: Spirit West p.203';

-- 8000 + 18000 + 80 + 400 + 200 + 200 + 400 + 500 + 400 + 200 + 600 + 1600 + 2500.
SELECT 'their prices sum to the page' AS assertion, sum(cost) AS got, 33080 AS want
  FROM gear WHERE source_book = 'Rifts World Book 15: Spirit West p.203';

SELECT 'the smoke arrowhead keeps its 60 and records the 80' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'arrowhead-smoke' AND cost = 60 AND instr(cost_note, 'prices it at 80 credits') > 0;

SELECT 'and no Spirit West row duplicates a held arrowhead' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Rifts World Book 15: Spirit West p.203'
   AND name IN ('Arrowhead: Light Explosive', 'Arrowhead: Medium Explosive', 'Arrowhead: Heavy Explosive', 'Arrowhead: High Explosive', 'Arrowhead: Gas', 'Arrowhead: Smoke', 'Arrowhead: Flare');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-spirit-west-weapons-of-note.sql');
