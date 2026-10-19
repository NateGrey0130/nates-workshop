-- The TW Ley Streaker takes the Book of Magic's figures (BOOK-INGEST-AUDIT F144).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~235-book-ingest-audit-f144-ley-streaker.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~235-book-ingest-audit-f144-ley-streaker.sql
--
-- Nate's ruling of 2026-10-04: the newest printing that STATES a figure wins,
-- and the older figure is kept in the row's notes with its page. 2026-10-12: a
-- row taking the Book of Magic's figure moves its source_book there.
-- 2026-10-19: take the Ley Streaker as printed, Main Body 150 AND the
-- Electro-Blaster, and move the wing location row to match so the row does not
-- contradict itself.
--
--   tw-ley-streaker   Federation of Magic printed 122 (1997) -> Rifts Book of
--                     Magic printed 337 (2001, cache p338). The Book of Magic
--                     prints Main Body 150 (was 220), flight 600 mph on a ley
--                     line with no movement off one (was about 60 mph off a
--                     line for four hours), range unlimited along ley lines,
--                     and an Electro-Blaster the row lacked. Crew and cost
--                     agree. It prints no location list, so the cockpit and
--                     neck rows keep Federation of Magic's figures.
--
-- vehicles has no notes column, so Federation of Magic's replaced figures are
-- kept in description with their page; the wing row keeps its old figure in
-- mdc_note. Every figure was read off a 150 dpi render of cache p338; the text
-- layer there prints the damage as a digit cipher.
--
-- NOT changed: tw-battle-streaker, the armed variant, which is its own row and
-- carries the "Other Weapons" package (the 8 million credit price).
--
-- Each UPDATE is guarded on the figure it replaces, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: one vehicles row, one vehicle_locations row,
-- one new vehicle_weapons row. The tilde number is claimed at merge.

UPDATE vehicles
   SET mdc_main_body = 150,
       speed_air = 'Up to 600 mph (960 km) on a ley line, where it can also float, glide and hover. No movement off of a ley line. Range unlimited along ley lines. Completely silent.',
       description = 'Model Type: Ley Line Skimmer. Class: scout. A Stormspire ley line skimmer built for speed, with an enclosed cockpit at the front and a long, sleek, flat, slightly curved body that hugs the surface of a ley line through dives, sharp turns and dogfight maneuvers; a fast scout and light transport. It looks surprisingly high-tech but has no computers or onboard sensors unless added. PILOTING SKILL: Techno-Wizards and aircraft pilots 50% +5% per level; any other O.C.C. 27% +3% per level. CARGO: minimal; a locker 2 feet deep, 4 feet wide and 3 feet tall in the cockpit. POWER: magic, running on ley line energy. CONTROLS: a steering wheel, throttle, brake and directional control. WEAPONS: an Electro-Blaster. ADDITIONS: TW or conventional equipment such as computers, radar, sensors and radio at the owner''s expense. DAMAGE NOTES: destroying the forward section crashes the vehicle if moving and blows everyone in the cockpit into the sky; destroying the neck cuts it in half, both halves spiralling gently to the ground with every system shut down; destroying one wing''s rear section knocks out propulsion and it crashes. Main body, flight and the Electro-Blaster are Rifts Book of Magic printed 337, the newer printing, which prints no location list; the cockpit and neck figures are Federation of Magic''s. Federation of Magic printed 122 filed the two wings as the main body at 220 M.D.C. each, described the Ley Streaker as unarmed, and gave it about 60 mph (96.5 km) away from a ley line, best altitude 300 feet (91 m), for four hours before its energy runs out; this row carried those figures until ~235.',
       source_book = 'Rifts Book of Magic p.337'
 WHERE slug = 'tw-ley-streaker'
   AND mdc_main_body = 220
   AND source_book = 'Rifts World Book 16: Federation of Magic p.122';

UPDATE vehicle_locations
   SET mdc = 150,
       mdc_note = 'The main body: Rifts Book of Magic printed 337 prints Main Body 150 and no location list. Federation of Magic printed 122 filed the two wings as the main body at 220 M.D.C. each, which this row carried until ~235. Destroying one wing''s rear section knocks out propulsion and it crashes.'
 WHERE vehicle_slug = 'tw-ley-streaker'
   AND location = 'Wings (2; main body)'
   AND mdc = 220;

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('tw-ley-streaker', 1, 'Electro-Blaster', '1D4x10 M.D.', 1, '2,000 feet (610 m)', 'Equal to the number of attacks per melee round', 'Unlimited', NULL, 'Rifts Book of Magic printed 337. Federation of Magic printed 122 described the Ley Streaker as unarmed.');

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Ley Streaker carries the Book of Magic figures' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles
 WHERE slug = 'tw-ley-streaker'
   AND mdc_main_body = 150
   AND source_book = 'Rifts Book of Magic p.337'
   AND instr(speed_air, 'No movement off of a ley line') > 0
   AND instr(speed_air, 'four hours') = 0
   AND instr(description, 'WEAPONS: none') = 0
   AND instr(description, 'Federation of Magic printed 122 filed the two wings as the main body at 220') > 0;

SELECT 'its wing row matches the main body' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_locations
 WHERE vehicle_slug = 'tw-ley-streaker' AND location = 'Wings (2; main body)' AND mdc = 150;

SELECT 'no Ley Streaker location still carries 220' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations
 WHERE vehicle_slug = 'tw-ley-streaker' AND mdc = 220;

SELECT 'it has one weapon row, the Electro-Blaster' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_weapons
 WHERE vehicle_slug = 'tw-ley-streaker' AND name = 'Electro-Blaster' AND damage = '1D4x10 M.D.';

SELECT 'the Battle Streaker is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles
 WHERE slug = 'tw-battle-streaker' AND mdc_main_body = 220
   AND source_book = 'Rifts World Book 16: Federation of Magic p.122';

INSERT INTO data_script_runs (filename) VALUES ('~235-book-ingest-audit-f144-ley-streaker.sql');
