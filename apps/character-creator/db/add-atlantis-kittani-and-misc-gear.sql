-- Rifts World Book 2: Atlantis - Kittani equipment (printed 137-138), the
-- odds and ends (152-154) and the Sunaj armor (66): 13 new rows. See
-- apps/character-creator/docs/surveys/atlantis.md.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-atlantis-kittani-and-misc-gear.sql
--
-- READ FROM A SCAN. Extracted by book-extract-worker; printed 66, 137, 138 and
-- 152-154 were rendered. The K-4's pulse burst is 1D6x10+6 M.D. on the render
-- (the OCR ran it together as 1D610+6).
--
-- MOST OF THIS SLICE WAS ALREADY IN THE CATALOG, reprinted by later books, and
-- is left on the book that brought it in:
--   * K-4, K-30, K-E4, K-500 and KEP-Special - Rifts World Book 4: Africa p.140
--   * Laser Wrist Blasters, Double Blade Plasma Axe, Plasma Sword, Energy Lance
--     - Rifts World Book 5: Triax and the NGR p.213-214
--   * every high-tech arrowhead - Triax p.150 and Spirit West p.203
--   * the typical bow - generic; the catalog has its bows from other books
-- The estimated `explorer-armor` row (from the Book of Magic, which names the
-- armor without stats or a maker) is left alone; Kittani Explorer Armor is its
-- own row.
--
-- THE BOOK PRINTS "250,00" for the Slaver's Net Gun; cost is 250,000 and
-- cost_note says so. Where a range is printed, cost is the low end.
-- Power armor, robots, drones and vehicles (printed 138-158) are batch 8,
-- including the K-Universal Light Power Armor, whose heading is on 138.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('k-1-sniper-laser-rifle', 'K-1 Sniper Laser Rifle and Launcher', 'rifts', 'weapon', 6, 60000, '60,000 credits; +10,000 per additional SPG grenade', 'Laser 4D6 M.D.; grenade 6D6 M.D.', 1, '2000 feet (610 m); the grenade launcher half that', 'Laser 20 shots (standard E-clip) or 30 (long E-clip); the launcher holds 2 grenades and takes a full melee to reload', 'Equal to the operator''s hand to hand attacks; aimed or wild shots only, no bursts', NULL, NULL, NULL, 'A Kittani sniper laser rifle with an underslung grenade launcher that fires in place of the laser. +1 to strike (+4 on an aimed shot) with either.', 'Rifts World Book 2: Atlantis p.137'),
('k-1000-spider-defense-system', 'K-1000 Spider Defense System', 'rifts', 'weapon', 80, 1000000, 'fair availability', 'Light laser 4D6 M.D. or heavy laser 1D4x10 M.D. per blast; electric current 3D6 S.D.C. at 20 feet (6 m)', 1, 'Light laser 4000 feet (1200 m); heavy laser 3000 feet (915 m)', '100 light and 40 heavy blasts, then a two-hour recharge from its nuclear power supply; an emergency E-clip gives 10 light or 5 heavy', 'Standard', NULL, NULL, 50, 'A nuclear-powered Kittani laser that can be carried as a rifle, mounted, or left as an autonomous defense robot on four crab-like legs that climb vertical surfaces and hang from ceilings. As a robot it remembers up to 1000 targets and has 6 attacks per melee, +2 to strike and dodge, Spd 22 and 50 M.D.C.; it also carries up to four smoke grenades (100 ft/30.5 m range).', 'Rifts World Book 2: Atlantis p.138'),
('kittani-explorer-armor', 'Kittani Explorer Armor (Full Composite)', 'rifts', 'armor', 15, 75000, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 85, 'Kittani full composite body armor: 85 M.D.C., fair mobility (-15% prowl). Comes in green, tan, brown, white, black or camouflage, and is built for a jet pack to be attached quickly. Not the estimated Explorer Armor row the Book of Magic import created, which names no maker.', 'Rifts World Book 2: Atlantis p.138'),
('kittani-centaur-body-armor', 'Kittani Centaur Body Armor', 'rifts', 'armor', 100, 125000, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 130, 'Kittani body armor for centaurs or horses: 130 M.D.C., fair mobility (-15% prowl) and -10% Spd. Not the Equestrian Power Armor.', 'Rifts World Book 2: Atlantis p.138'),
('bio-wizard-jolt-gun', 'Jolt Gun (Bio-Wizard)', 'rifts', 'magic', NULL, 45000, 'limited availability', '2D6 S.D.C., 4D6 S.D.C. or 1D4 M.D.; double damage and range on a ley line', 1, '1000 feet (305 m)', '20 blasts; magically recharged by a High Lord, techno-wizard or stone pyramid for 30 P.P.E.', 'Equal to the user''s melee attacks', NULL, NULL, NULL, 'A Splugorth bio-wizard weapon used to herd slaves, with three settings.', 'Rifts World Book 2: Atlantis p.153'),
('bio-wizard-mental-incapacitator', 'Mental Incapacitator (Bio-Wizard)', 'rifts', 'magic', NULL, 200000, '200,000 credits; 8,000 to recharge', NULL, 0, '180 feet (55 m)', '10 blasts', 'Two per melee', NULL, NULL, NULL, 'A Splugorth bio-wizard weapon firing wisps of confusion (as the spell) that affect 1D8 people in a closed area for 50 minutes; a successful save vs magic negates it.', 'Rifts World Book 2: Atlantis p.153'),
('bio-wizard-forearm-plasma-blaster', 'Forearm Plasma Blaster (Bio-Wizard)', 'rifts', 'magic', NULL, 110000, 'limited availability', '5D6 M.D. per blast; double damage and range on a ley line or at a nexus', 1, '2000 feet (610 m)', '20 blasts; magically recharged for 70 P.P.E.', 'Equal to the user''s melee attacks', NULL, NULL, NULL, 'A bio-wizard plasma weapon worn on the forearm.', 'Rifts World Book 2: Atlantis p.153'),
('bio-wizard-plasma-rifle', 'Plasma Rifle (Bio-Wizard)', 'rifts', 'magic', NULL, 150000, 'limited availability', '6D6 M.D. per blast; double damage and range on a ley line or at a nexus', 1, '3000 feet (914 m)', '20 blasts; magically recharged for 80 P.P.E.', 'Equal to the user''s melee attacks', NULL, NULL, NULL, 'The rifle version of the bio-wizard forearm plasma blaster.', 'Rifts World Book 2: Atlantis p.153'),
('bio-wizard-head-laser', 'Head or Helmet Laser (Bio-Wizard)', 'rifts', 'magic', NULL, 125000, 'limited availability', '2D6 M.D. per blast; double damage and range on a ley line or at a nexus', 1, '2000 feet (610 m)', '20 blasts; magically recharged for 60 P.P.E.', 'Up to four blasts per melee', NULL, NULL, NULL, 'A rod mounted on a helmet or headband, combining light spells and laser optics.', 'Rifts World Book 2: Atlantis p.154'),
('slavers-net-gun', 'Slaver''s Net Gun', 'rifts', 'magic', NULL, 250000, 'The book prints "250,00"; read as 250,000. Recharging costs about 8,000 credits.', NULL, 0, '180 feet (55 m)', '20 nets', 'Two per melee', NULL, NULL, NULL, 'A Splugorth bio-wizard gun that launches a magic net with the stats of the spell, lasting up to 20 minutes.', 'Rifts World Book 2: Atlantis p.154'),
('splugorth-bio-power-armor', 'Splugorth Bio-Power Armor', 'rifts', 'armor', 30, 300000, 'Not legal; sold by discreet merchants at 3D4x100,000 credits, occasionally more or less. Repairs by a Splugorthian alchemist cost 150,000 credits per 10 M.D.C.', NULL, 1, 'self', '120 P.P.E., regenerating 10 an hour; full recharge at a ley line nexus or stone pyramid; its Eylor component lasts 150 years', 'two kinds of magic per melee', NULL, NULL, 130, 'Splugorth magic body armor powered by an eye of Eylor: 130 M.D.C. plus an energy field, good mobility (-10% prowl). Chest stones cast as a fifth level wizard (save 13 or higher): fly as the eagle, swim as the fish, breathe without air, superhuman speed and energy field; see the invisible, sense magic, tongues, heal wounds (self) and negate poison (self). A hidden control lets a High Lord locate, paralyze, dominate, put to sleep or blind the wearer.', 'Rifts World Book 2: Atlantis p.154'),
('talisman-of-armor', 'Talisman of Armor', 'rifts', 'magic', NULL, 20000000, 'Twenty million credits, because its M.D.C. renews perpetually.', NULL, 0, 'self', 'three activations a day, recharging every 24 hours', NULL, NULL, NULL, 100, 'A Splugorth talisman that surrounds its wearer with an Armor of Ithan of 100 M.D.C. for 10 minutes (40 melee rounds), three times a day.', 'Rifts World Book 2: Atlantis p.154'),
('sunaj-environmental-armor', 'Sunaj Assassin Environmental Armor', 'rifts', 'armor', 16, 85000, '85,000 to 100,000 credits on the black market; sometimes available in the Splugorth markets of Atlantis', NULL, 1, NULL, NULL, NULL, NULL, NULL, 110, 'Comparatively light plate armor of Sunaj design, alien to other Atlanteans, with a helmet always styled as a monster: 110 M.D.C., good mobility (-10% prowl).', 'Rifts World Book 2: Atlantis p.66');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 13 Kittani and misc gear rows are in' AS assertion, count(*) AS got, 13 AS want
  FROM gear WHERE slug IN ('k-1-sniper-laser-rifle', 'k-1000-spider-defense-system', 'kittani-explorer-armor', 'kittani-centaur-body-armor', 'bio-wizard-jolt-gun', 'bio-wizard-mental-incapacitator', 'bio-wizard-forearm-plasma-blaster', 'bio-wizard-plasma-rifle', 'bio-wizard-head-laser', 'slavers-net-gun', 'splugorth-bio-power-armor', 'talisman-of-armor', 'sunaj-environmental-armor') AND source_book LIKE 'Rifts World Book 2: Atlantis p.%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-atlantis-kittani-and-misc-gear.sql');
