-- The Glitter Boy: the last item of BOOK-INGEST-AUDIT.md F41, and it turned out
-- not to be the decision that finding expected.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-web-glitter-boy-p071-072.sql
--
-- == F41 SAYS THIS ROW HAS NO BOOK BEHIND IT. THREE BOOKS ON THIS MACHINE STAT IT ==
--
-- `glitter-boy-power-armor` carries `source_book = 'Web reference (not
-- book-verified)'`, and F41 sets it aside as "a sixth decision for the
-- web-sourced row" - a judgement about whether to trust an unverifiable figure.
-- There was nothing to judge. Rifts Ultimate Edition prints the whole entry on
-- printed 71-72 under the row's own model designation, and every one of the
-- seven M.D.C. figures the row stores is printed there verbatim:
--
--   Rail Gun 175, Head 290, Hands 100 each, Arms 270 each, Legs 450 each,
--   Reinforced Pilot's Compartment 150, Main Body 770
--
-- So does the height, the weight, the running speed, the leap, the
-- laser-does-half-damage rule and the main-body shutdown rule. The row is a
-- faithful transcription of a book nobody credited. The original core book and
-- Free Quebec printed 82 carry it too.
--
-- **THE ROW IS RE-CITED AND ONE NUMBER IS CORRECTED.** It said `nuclear power
-- (20 year charge)`; RUE printed 72 and the original core book both print
-- **25 years**. Free Quebec prints 20, so the row was a blended reading - which
-- is exactly what the marker exists to warn about, and the README's own worked
-- example of the marker is this very item.
--
-- CORRECTING A GEAR VALUE HERE IS NOT WHAT F42 DECLINED, and the difference
-- matters. F42 left six RUE rows' figures alone because WHICH EDITION the
-- catalog states is a real decision with two coherent answers. This row states
-- no edition and claims no book at all; leaving a figure that contradicts the
-- book it is now cited to would MANUFACTURE an F42. The repo already has the
-- pattern - `backfill-rue-equipment.sql` re-cites eleven web-sourced rows to RUE
-- pages and corrects the numbers the book contradicts, each `UPDATE` guarded on
-- the marker, exactly as below.
--
-- **THE PRICE IS FILLED IN, on Nate's call 2026-09-09.** The row's `cost` was
-- NULL; RUE prints `Black Market Cost: 25 million credits and more for a new,
-- undamaged, fully powered Glitter Boy complete with Boom Gun and ammunition.
-- 15-20 million for a rebuilt GB or without the gun.` 25,000,000 is stored
-- because it is the price of the machine this row describes; the 15-20 million
-- band is a rebuilt or gunless suit - a different product, not the low end of
-- one range. That is the same reading the Road Boss got, applied to a range
-- whose ends are two different things rather than one thing armed and stripped.
--
-- == A GLITTER BOY WAS ALREADY IN `vehicles`, AND IT IS A DIFFERENT MACHINE ==
--
-- The Free Quebec sequence imported `classic-glitter-boy-qgb-100` - "Classic
-- Glitter Boy (QGB-100 / USA-G10)", Free Quebec printed 81-83 - carrying all
-- seven of this row's figures **plus an eighth**, the Rimouski Left Forearm
-- Weapon Package at 110, which the USA-G10 does not have. Its Boom Gun is the
-- RG-1S at Mach 5, its power system runs 20 years and its price is Free Quebec's
-- 20 million.
--
-- Nate settled the shape on 2026-09-09: **import RUE's USA-G10 as its own
-- vessel** rather than point a RUE-cited row at Quebec's production model. The
-- two are genuinely different machines - the catalog already holds five other
-- Quebec Glitter Boy variants beside the classic - and Free Quebec's own survey
-- calls the USA-G10 the one the whole line descends from. Pointing this row at
-- the QGB-100 would have sent a reader from a RUE citation to a weapon package
-- RUE never gives it.
--
-- **THIS IS NOT AN F44 DUPLICATE.** They differ by a real location, a real
-- weapon model, a real power system and a real price, and the books print them
-- as separate entries. `findDuplicates` will score the names; a reviewer reading
-- the pair should see two machines, not one row entered twice.
--
-- == READ FROM THE BOOK, AND RENDERED, BECAUSE `rue` IS A SCAN ==
--
-- `text_layer: false`, so `scripts/read-columns.py` cannot be used - the same
-- constraint as the Wormwood, RUE and Phase World sessions. Every figure was
-- read from the cached OCR of printed 71-72 and confirmed against a 200 dpi
-- render of both pages. The folios 71 and 72 are legible at the foot of each
-- render, confirming `page_offset: 3` as `scripts/books.json` records.
--
-- EIGHT Z'S AND THE NAME MATTERS. `zzzzzzzz-rue-vessels-p266-267.sql` asserts
-- `count(*) FROM gear WHERE vehicle_slug IS NOT NULL AND source_book LIKE
-- '%Ultimate%'` is **8**. This file re-cites a ninth row into that book AND
-- points it, so it must sort AFTER that script or falsify its readback on a
-- clean rebuild - which `web-` does at the same tier and `gb-` would not. That
-- is the ordering trap `docs/operations.md` describes, hit for real.
--
-- Pure ASCII with LF endings.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('glitter-boy-power-armor', 'Glitter Boy Power Armor (USA-G10)', 'rifts', 'power-armor',
   'One pilot. The compartment is padded and air-conditioned and can hold a pilot for days or weeks, with ten gallons of drinking water and about four weeks of nutrient paste - but more than 24 hours at a stretch cramps the muscles, and three weeks or more reduces P.S., P.P. and Spd by 1D4+1 until recovered by four hours of exercise a day for 1D4 weeks.',
   NULL,
   'Running: 60 mph (96 km) maximum; running tires the operator at only 10% of the usual fatigue rate. Leaping: 12 feet (3.6 m) high or across, plus 10 feet (3 m) with a running start; jet-thruster assisted leaps reach 80 feet (24 m). The thrusters can hold the G10 momentarily aloft as high as 12 feet (3.6 m) for 1D6x10 seconds and are NOT made for flying.',
   NULL,
   'Swimming at a sluggish 15 mph (24 km or 13 knots), the same speed on the surface, and it can walk the sea or lake bed at about 25% of normal running speed. Maximum ocean depth one mile (1.6 km). To fire the Boom Gun underwater it must engage its pylons into the sea floor or other firm support; without one, the shock wave propels it backwards in a spiral for 1D4x100 yards/metres and costs it initiative and its next 1D4+3 melee actions - half that if sunk into soft flooring.',
   'Height: 10 feet 5 inches (3.1 m); Width: 4 feet 4 inches (1.3 m); Length: 4 feet (1.2 m)',
   '1.2 tons fully loaded',
   770,
   25000000,
   'Black market 25 million credits and more for a new, undamaged, fully powered Glitter Boy complete with Boom Gun and ammunition; 15 to 20 million for a rebuilt one or one without the gun. Rare, and poor availability. The 25 million is stored because it is the price of the machine this row describes - the lower band is a rebuilt or gunless suit, a different product rather than the low end of one range.',
   'The first fully field-operational power armour deployed by the US military, and a key unit of the pre-Rifts peacekeeping alliance NEMA. Its original name was the Chromium Guardsman; that is long forgotten and the snappier nickname stuck. An amazingly small and mobile one-person armoured robot vehicle about ten feet tall, with fully articulated hands and the mobility of the human body, so it counts as an all-terrain vehicle. The super-dense chrome armour is constructed on a molecular level and withstands more mega-damage than any power armour built since; the frame is nearly indestructible and virtually maintenance free, and the armour-shielded joints and padded compartment absorb impacts and cushion the pilot. Robot P.S. 30. Power system nuclear, average energy life 25 years. LASER WEAPONS DO HALF DAMAGE to it, and depleting the main body shuts the armour down completely. Cargo is minimal: a one-foot compartment and storage for a rifle, a handgun, a survival knife and a first-aid kit. Free Quebec is the only kingdom in North America that manufactures and deploys Glitter Boys as part of its army, and there are no known manufacturers elsewhere - though a rumour holds that a pre-Rifts cache was excavated from an old American military installation and sold by high-tech bandits.',
   'Rifts Ultimate Edition p.71-72');

-- Printed order, exactly as the book lists them.
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('glitter-boy-power-armor', 'Rail Gun (a.k.a. Boom Gun)', 175, NULL, 1),
  ('glitter-boy-power-armor', 'Head', 290, 'A small and difficult target: the attacker must make a Called Shot, and is -4 to strike even then.', 2),
  ('glitter-boy-power-armor', 'Hands (2)', 100, 'Each. A small and difficult target, as the head is - Called Shot at -4 to strike.', 3),
  ('glitter-boy-power-armor', 'Arms (2)', 270, 'Each.', 4),
  ('glitter-boy-power-armor', 'Legs (2)', 450, 'Each.', 5),
  ('glitter-boy-power-armor', 'Reinforced Pilot''s Compartment', 150, 'The original core book prints 110 here; Rifts Ultimate Edition and Free Quebec both print 150, and the later figure is stored.', 6),
  ('glitter-boy-power-armor', 'Main Body', 770, 'Depleting the main body shuts the power armour down completely, rendering it useless. Note that laser weapons do HALF damage to the Glitter Boy.', 7);

-- ORDINALS ARE THE BOOK'S. RUE numbers its Weapon Systems 1 to 3.
INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('glitter-boy-power-armor', 1, 'RG-14 Rapid Acceleration Electromagnetic Rail Gun (1)',
   'One Boom Gun flechette round holds 200 slugs and inflicts 3D6x10 M.D.', 1,
   '11,000 feet (about 2 miles/3.2 km) maximum effective',
   'Each booming blast counts as one melee attack or action. Bursts and sprays are NOT possible.',
   '1000 round auto-feed ammo canister. Reloading by hand takes 15 minutes per 40 rounds. A 400-round extra drum can be hung on the hip - 30 M.D.C., needing a Called Shot at -4 to hit. A team of Operators with the right equipment replaces a full drum in 1D6+2 minutes; Free Quebec Reload Teams do it in 45 seconds, or six minutes by hand with two or three people.',
   NULL,
   'The famous "Boom Gun", primary purpose assault, anti-armor and anti-aircraft. It accelerates its flechette rounds to Mach 5 and creates a SONIC BOOM, and is the most powerful personal or vehicular weapon to survive the Great Cataclysm. The gun weighs 867 lbs (390 kg) and mounts on the back and right shoulder, reversible for a left-handed pilot. Without the automatic stabilization system - synchronised jet thrusters and retractable leg pylons - firing would throw the armour to the ground and knock it back 30 feet (9.1 m). Everyone within 200 feet (61 m) is temporarily deafened, tripled underwater: 2D4 minutes and -8 initiative, -3 parry and dodge without ear protection, or 1D4 minutes inside environmental armour or a light M.D. vehicle. Greater Demons, Demon Lords, Elementals and gods are impervious; dragons are affected as those inside a light vehicle. The boom shakes buildings and shatters S.D.C. windows within a 300 foot (91 m) radius.'),

  ('glitter-boy-power-armor', 2, 'Alternative Weapons',
   'By weapon.', 1, NULL, NULL, NULL, NULL,
   'Not a built-in system. The Glitter Boy may pick up and use any weapon it can get its hands around, including heavy weapons such as rail guns MODIFIED to have the trigger guard removed and the trigger enlarged. Each of its fingers is roughly three human fingers thick, which prevents it using man-sized weapons at all; oversized ones are uncommon and expensive. The book notes most traditional GB pilots would never permanently replace the Boom Gun.'),

  ('glitter-boy-power-armor', 3, 'Hand to Hand Combat Elite: Glitter Boy',
   NULL, 0, NULL, NULL, NULL,
   '+2 extra attacks or actions per melee round at level one, and +1 additional at levels 3, 7 and 11.',
   'Not a weapon system. Available only to a pilot who takes Power Armor Combat Elite: Glitter Boy, which is automatic to the Glitter Boy O.C.C.; anyone else uses the Power Armor Basic stats. These bonuses are in addition to the pilot''s own hand to hand training and attribute bonuses, and do NOT apply to the pilot outside the armour.');

-- == THE GEAR ROW: RE-CITED, ONE FIGURE CORRECTED, PRICED, AND POINTED ==
-- Every UPDATE is guarded on the marker, so this file is inert if it is ever run
-- twice or after somebody else has re-cited the row. That is the guard shape
-- backfill-rue-equipment.sql uses for the same job.

UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.71-72',
       cost = 25000000,
       cost_note = 'Black market 25 million credits for a new, complete Glitter Boy with Boom Gun and ammunition; 15 to 20 million rebuilt or without the gun. Rare.',
       description = replace(description, 'nuclear power (20 year charge)', 'nuclear power (25 year charge)')
 WHERE slug = 'glitter-boy-power-armor'
   AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET vehicle_slug = 'glitter-boy-power-armor'
 WHERE slug = 'glitter-boy-power-armor';

-- --- readback ---
-- Every want is counted off the VALUES lists in THIS FILE.

SELECT 'the vessel' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'glitter-boy-power-armor';

SELECT 'its M.D.C. locations' AS assertion, count(*) AS got, 7 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'glitter-boy-power-armor';

SELECT 'its weapon systems' AS assertion, count(*) AS got, 3 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'glitter-boy-power-armor';

-- The seven figures F41 called unverifiable, now carried by a cited vessel.
SELECT 'the seven printed figures' AS assertion, count(*) AS got, 7 AS want
  FROM vehicle_locations
  WHERE vehicle_slug = 'glitter-boy-power-armor'
    AND ((location = 'Rail Gun (a.k.a. Boom Gun)' AND mdc = 175)
      OR (location = 'Head' AND mdc = 290)
      OR (location = 'Hands (2)' AND mdc = 100)
      OR (location = 'Arms (2)' AND mdc = 270)
      OR (location = 'Legs (2)' AND mdc = 450)
      OR (location = 'Reinforced Pilot''s Compartment' AND mdc = 150)
      OR (location = 'Main Body' AND mdc = 770));

-- The gear row now names a book, carries the price and points at the vessel.
SELECT 'the gear row is re-cited, priced and pointed' AS assertion, count(*) AS got, 1 AS want
  FROM gear
  WHERE slug = 'glitter-boy-power-armor'
    AND source_book = 'Rifts Ultimate Edition p.71-72'
    AND cost = 25000000
    AND vehicle_slug = 'glitter-boy-power-armor';

-- And the one figure the book contradicted is corrected.
SELECT 'the 25-year charge replaced the 20' AS assertion, count(*) AS got, 1 AS want
  FROM gear
  WHERE slug = 'glitter-boy-power-armor'
    AND instr(description, '25 year charge') > 0
    AND instr(description, '20 year charge') = 0;

-- FOUR web-sourced rows still carry a combat number, and this file asserts that
-- rather than zero because the first draft asserted zero and was WRONG - caught
-- on the first --local apply. The Glitter Boy was the only web-sourced row with
-- a per-location M.D.C. stat block, which is not the same claim.
--
-- Worth knowing, and NOT fixed here: the README's estimate tier forbids an
-- ESTIMATED row from carrying M.D.C., damage or an A.R. at all. The web marker
-- carries no equivalent rule, and these four have combat numbers no book has
-- been shown to back: c-18-laser-pistol (damage 2D4), cyber-armor (mdc 50,
-- ar 16), hand-axe and hatchet (1D6 each). Measured --remote 2026-09-09.
SELECT 'four web-sourced rows still carry a combat number' AS assertion, count(*) AS got, 4 AS want
  FROM gear
  WHERE source_book = 'Web reference (not book-verified)'
    AND (mdc IS NOT NULL OR damage IS NOT NULL OR ar IS NOT NULL);

SELECT 'the web marker survives on the other rows' AS assertion, count(*) AS got, 27 AS want
  FROM gear WHERE source_book = 'Web reference (not book-verified)';

-- Free Quebec's Quebec-built machine is untouched and still distinct: it keeps
-- its eighth location, which is what makes it a different vessel.
SELECT 'the Quebec QGB-100 is untouched' AS assertion, count(*) AS got, 8 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'classic-glitter-boy-qgb-100';

SELECT 'every pointer in the catalog resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT 'it carries a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE slug = 'glitter-boy-power-armor'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;
SELECT count(*) AS total_gear_pointers FROM gear WHERE vehicle_slug IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-web-glitter-boy-p071-072.sql');
