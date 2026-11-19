-- Splynn Dimensional Market restates the four Splugorth flying ships on p.190.
-- The held rows came from Rifts World Book 2: Atlantis p.154-155
-- (add-atlantis-vehicles.sql). Read side by side on renders of both pages,
-- 2026-11-19, this printing changes three things and nothing else:
--
--   M.D.C.  Atlantis prints one figure per size; Splynn prints a range.
--           small 250 -> 250-350, medium 400 -> 400-800,
--           large 650 -> 650-1500, frigate 1000 -> 1000-4000.
--           The floor is unchanged, so mdc_main_body stays the low end and
--           the range goes in the Main Body location's mdc_note.
--   Speed   frigate 75 mph (120 km) -> 75-100 mph (120-160 km).
--   Price   frigate 100 million -> 100+ million (cost keeps the low end).
--
-- Unchanged on both pages: the other three speeds, the three other prices,
-- crew, altitude, the 25% water speed, hover, the half-speed rule, the Eylor
-- eye(s), the nine standard spells and the six extra for elite Minions, and
-- weapon systems as optional additions with no list. None of the four has a
-- vehicle_weapons row, and each has only a Main Body location.
--
-- Rule: the newest printing that states a figure wins (Nate, 2026-10-04), so
-- each changed row is re-cited to this book and keeps the Atlantis figure in
-- its description. Every UPDATE is guarded on the Atlantis state it replaces,
-- so a second run changes nothing.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~368-splynn-flying-ships.sql

UPDATE vehicle_locations SET mdc_note = '250-350 by the ship; the low end is stored. Atlantis p.155 printed 250.'
  WHERE vehicle_slug = 'splugorth-flying-ship-small' AND location = 'Main Body' AND mdc_note IS NULL;
UPDATE vehicle_locations SET mdc_note = '400-800 by the ship; the low end is stored. Atlantis p.155 printed 400.'
  WHERE vehicle_slug = 'splugorth-flying-ship-medium' AND location = 'Main Body' AND mdc_note IS NULL;
UPDATE vehicle_locations SET mdc_note = '650-1,500 by the ship; the low end is stored. Atlantis p.155 printed 650.'
  WHERE vehicle_slug = 'splugorth-flying-ship-large' AND location = 'Main Body' AND mdc_note IS NULL;
UPDATE vehicle_locations SET mdc_note = '1,000-4,000 by the ship; the low end is stored. Atlantis p.155 printed 1,000.'
  WHERE vehicle_slug = 'splugorth-flying-ship-frigate' AND location = 'Main Body' AND mdc_note IS NULL;

UPDATE vehicles SET
    description = description || ' Splynn Dimensional Market (p.190) restates the ship and prints its M.D.C. as a range, 250-350; Atlantis (p.155) printed a single 250.',
    source_book = 'Rifts World Book 21: Splynn Dimensional Market p.190'
  WHERE slug = 'splugorth-flying-ship-small' AND source_book = 'Rifts World Book 2: Atlantis p.154-155';
UPDATE vehicles SET
    description = description || ' Splynn Dimensional Market (p.190) restates the ship and prints its M.D.C. as a range, 400-800; Atlantis (p.155) printed a single 400.',
    source_book = 'Rifts World Book 21: Splynn Dimensional Market p.190'
  WHERE slug = 'splugorth-flying-ship-medium' AND source_book = 'Rifts World Book 2: Atlantis p.154-155';
UPDATE vehicles SET
    description = description || ' Splynn Dimensional Market (p.190) restates the ship and prints its M.D.C. as a range, 650-1,500; Atlantis (p.155) printed a single 650.',
    source_book = 'Rifts World Book 21: Splynn Dimensional Market p.190'
  WHERE slug = 'splugorth-flying-ship-large' AND source_book = 'Rifts World Book 2: Atlantis p.154-155';
UPDATE vehicles SET
    speed_air = replace(speed_air, 'Flying 75 mph (120 km)', 'Flying 75-100 mph (120-160 km)'),
    cost_note = '100+ million credits for a simple frigate; features, weapons and decoration can add millions.',
    description = description || ' Splynn Dimensional Market (p.190) restates the ship with an M.D.C. range of 1,000-4,000, a flying speed of 75-100 mph (120-160 km) and a price of 100+ million; Atlantis (p.155) printed a single 1,000 M.D.C., 75 mph (120 km) and 100 million.',
    source_book = 'Rifts World Book 21: Splynn Dimensional Market p.190'
  WHERE slug = 'splugorth-flying-ship-frigate' AND source_book = 'Rifts World Book 2: Atlantis p.154-155'
    AND instr(speed_air, 'Flying 75 mph (120 km)') > 0;

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 4 flying ships cite Splynn p.190' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE slug IN ('splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate')
    AND source_book = 'Rifts World Book 21: Splynn Dimensional Market p.190';
SELECT 'each keeps its Atlantis figure in its description' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE slug IN ('splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate')
    AND instr(description, 'Atlantis (p.155) printed a single') > 0;
SELECT 'each Main Body carries its range' AS assertion, count(*) AS got, 4 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate')
    AND location = 'Main Body' AND instr(mdc_note, 'by the ship; the low end is stored') > 0;
SELECT 'the frigate flies 75-100 mph at 100+ million' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'splugorth-flying-ship-frigate'
    AND instr(speed_air, 'Flying 75-100 mph (120-160 km)') > 0 AND instr(cost_note, '100+ million') > 0;
SELECT 'the low ends are unchanged' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate')
    AND (l.mdc <> v.mdc_main_body OR v.mdc_main_body NOT IN (250, 400, 650, 1000));

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~368-splynn-flying-ships.sql');
