-- Rifts World Book 27: Adventures in Dinosaur Swamp - the Lazlo Model Behemoth (printed 104-106)
-- 1 vehicle rows, with 18 locations and 3 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~247-adventures-in-dinosaur-swamp-behemoth.sql
--
-- Written by scripts/vessel-sql.mjs from 1 worker file(s). Every value
-- is printable ASCII, every row cites its book, and a Main Body location
-- agrees with its vehicle's mdc_main_body.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('lazlo-model-behemoth', 'Lazlo Model Behemoth', 'rifts', 'robot', 'Four: one pilot, one copilot, one communications officer and a gunner.', 'Houses 48 comfortably, 72 under cramped and uncomfortable conditions. The forward observation deck holds as many as 16 besides the crew; the whole expedition can squeeze in during a hurricane.', 'Running: 32 mph (51.2 km) maximum. Leaping and dodging are not possible.', NULL, NULL, 'Height: 84 feet (25.6 m); Width: 33 feet (10 m); Length: 82 feet (25 m)', '59 tons fully loaded, not including crew, passengers and cargo', 668, 1, NULL, 155000000, 'The prototype''s cost was astronomical and it is one of a kind. Titan Industries plans to sell mass production units for 155 million credits without the Observation Arm and 182 million with it.', 'Model EX-L6 Robot Lab & Command Center, a Mobile Medical/Research Robot Vehicle: Titan Industries'' customized prototype of the Behemoth Explorer, built for the Second Neenok Expedition as its mobile base. Two levels: a main science lab, a live-specimen hold and four private labs above; 12 living quarters, a dining lounge, sick bay and a storage bay for four small vehicles and six suits of power armor below. It lacks the Explorer''s two large robot arms; instead a folding arm in front carries a mini-station (holds 1-4) with two small robot arms in its nose, a long arm on its left side holding a searchlight, a video camera and a light laser (2D6 M.D. per blast, 2000 feet/610 m), and a small sensor cluster (10 M.D.C.). M.D.C. shutters (75 M.D.C.) slide over the forward observation bubble. Robotic P.S. 40 (feet and legs). No hand to hand as such: a stomp does 6D6 M.D. to opponents up to 15 feet (4.6 m) tall, and a body block/ram does 3D6+6 M.D. and counts as two melee attacks. Cargo: 400 square feet (37 sq. m) plus other interior storage, 250 ton limit. Nuclear, average energy life 12 years. Sensors: thermal-imager 2000 feet (610 m); infrared and ultraviolet optics 1500 feet (457.2 m); infrared searchlights 1500 feet; enhanced radar tracking up to 800 targets at 200 miles (320 km); communications 600 miles (960 km). Its release cuts the old Behemoth Explorer''s price from 100 million credits to 54 million.', 'Rifts World Book 27: Adventures in Dinosaur Swamp p.104-106');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('lazlo-model-behemoth', 'Front Observation Deck & Main Crew Compartment', 300, 'Overall.', 1),
  ('lazlo-model-behemoth', 'Glass Bubbles of Front & Rear Observation Decks (2)', 50, 'Each, on top. 125 each when closed with the wraparound shielding; nobody can see out from the deck while it is closed.', 2),
  ('lazlo-model-behemoth', 'Top Observation Glass Bubbles (3)', 35, 'Each.', 3),
  ('lazlo-model-behemoth', 'Top Observation Decks (3, metal)', 115, 'Each.', 4),
  ('lazlo-model-behemoth', 'Bottom Observation Glass Bubble (1)', 35, NULL, 5),
  ('lazlo-model-behemoth', 'Bottom Observation Deck (1, metal)', 225, NULL, 6),
  ('lazlo-model-behemoth', 'Top Folding Arm (1)', 125, 'Just the arm itself.', 7),
  ('lazlo-model-behemoth', 'Mini-Station (1)', 180, 'Small or difficult target: an Aimed or Called Shot is -4 to strike, -6 if the attacker or the Behemoth is moving.', 8),
  ('lazlo-model-behemoth', 'Mini-Station Arm Light & Laser (1)', 30, 'Small or difficult target: an Aimed or Called Shot is -4 to strike, -6 if the attacker or the Behemoth is moving.', 9),
  ('lazlo-model-behemoth', 'Small Robot Arms of the Mini-Station (2)', 28, 'Each. Small or difficult target: an Aimed or Called Shot is -4 to strike, -6 if the attacker or the Behemoth is moving.', 10),
  ('lazlo-model-behemoth', 'Legs (2)', 325, 'Each.', 11),
  ('lazlo-model-behemoth', 'Medium Searchlights (8)', 10, 'Each. Small or difficult target: an Aimed or Called Shot is -4 to strike, -6 if the attacker or the Behemoth is moving.', 12),
  ('lazlo-model-behemoth', 'Front Observation Deck Searchlights (2)', 12, 'Each.', 13),
  ('lazlo-model-behemoth', 'Rear Observation Deck Searchlights (2)', 12, 'Each.', 14),
  ('lazlo-model-behemoth', 'Auxiliary Pilot''s Compartment (1)', 160, NULL, 15),
  ('lazlo-model-behemoth', 'Blast Doors', 150, 'Each. They seal off a breached observation deck.', 16),
  ('lazlo-model-behemoth', 'Main Sensor Tower (1, rear)', 120, 'Destroying it cuts sensor range and capabilities by two-thirds. A target only for attackers behind the vehicle; impossible to hit from the front.', 17),
  ('lazlo-model-behemoth', 'Main Body', 668, 'Depleting it shuts the robot down completely: immobile, no weapons, communications or sensors. Internal lights, heating, cooling and the labs and housing keep working for 72 hours unless the damage inflicted is greater than 800 M.D.C.', 18);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('lazlo-model-behemoth', 1, 'Mini-Missile Launchers (2)', 'Any mini-missile; standard issue is fragmentation (5D6 M.D.) and plasma (1D6x10 M.D.)', 1, 'One mile (1.6 km)', 'One at a time or in volleys of two, three, four or six; a single missile or a volley of 2-6 counts as one melee attack.', '96 per launcher; hundreds more can be stored inside the vehicle.', NULL, 'Antipersonnel and defense. Mounted on the sides of the vehicle toward the rear; the copilot or a designated gunner typically controls them.'),
  ('lazlo-model-behemoth', 2, 'Main Observation Deck Lasers (1 pair per deck)', '2D6 M.D. per single blast or 4D6 M.D. per simultaneous double blast', 1, '2000 feet (610 m)', 'Each single or double blast counts as one of the gunner''s melee attacks.', 'Effectively unlimited; tied to the nuclear power supply.', NULL, 'Defense. A pair of medium-powered lasers in the nose of each of the two main observation decks, with a 45 degree arc of fire up and down and 90 degrees side to side. The pilot or copilot typically fires the forward pair, a designated passenger or crew member the rear.'),
  ('lazlo-model-behemoth', 3, 'Gas & Smoke Defense', 'None', 0, '100 feet (30.5 m) around the entire vehicle', 'Once per 15 minutes.', '18 full doses.', NULL, 'Defense. A cloud of noxious gas and smoke released from the undercarriage. All caught in it are -1 melee attack, -4 on initiative, -6 to strike and parry and -4 to dodge, cannot see more than three feet (0.9 m), and choke and cough. Equal to Horror Factor 17 to most animals and dinosaurs, causing them to flee, and H.F. 15 to intelligent but primitive humanoids and intelligent dinosaurs. Those in environmental body armor and familiar with technology suffer only the obscured vision (the strike, parry and dodge penalties still apply). Lingers up to 15 minutes, half that in a wind of 20 mph (32 km) or more.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 machines are in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug IN ('lazlo-model-behemoth');
SELECT 'their 18 locations are in' AS assertion, count(*) AS got, 18 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('lazlo-model-behemoth');
SELECT 'their 3 weapon entries are in' AS assertion, count(*) AS got, 3 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('lazlo-model-behemoth');
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('lazlo-model-behemoth') AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~247-adventures-in-dinosaur-swamp-behemoth.sql');
