-- The Triax cybernetic and bionic implants of printed 153-154. Twenty-five rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-e-cybernetics.sql
--
-- THIS ESTABLISHES A CONVENTION AND SAYS SO RATHER THAN SETTING IT QUIETLY.
-- The catalog held essentially no cybernetics before this: a query for bionic,
-- cyber and implant across all 1,025 gear rows returned one row, and that was
-- Cyber-Armor, a suit of armour from a web reference. These twenty-five are
-- filed as ordinary "gear" - and as "weapon" for the four that do damage, all
-- of them on printed 154 - on the same reading that puts Juicer Uprising's
-- designer drugs and the bio-comp system in "gear": they are priced,
-- purchasable augmentations a character buys. A cybernetics catalog of its
-- own would be a schema change, and this batch does not make one.
--
-- WHAT THAT MEANS IN PRACTICE: 113 published classes mention cybernetics in
-- their markdown, almost all of them in a restriction saying the class starts
-- with none. Nothing in the app installs an implant or tracks one, so these
-- rows are purchasable items and no more than that. They do not become a
-- mechanic by being here.
--
-- ONE ROW HAS NO PRICE AND SAYS SO: the Psionic Electro-Magnetic Dampers. Every
-- other entry on these two pages prints a cost and that one does not - checked
-- against the page rather than assumed from a bad OCR line. cost is NULL and
-- cost_note explains, which is the convention for the rows already on the
-- "gear with no price" backlog.
--
-- THE SPU-5 IS NOT REPEATED HERE. Printed 152-153 sells it both as a worn
-- accessory and as a 2,000 credit implant; it is one device and it is one row,
-- in add-triax-gear-d-equipment.sql, with both prices in its cost_note.
--
-- TWO OF THE p.153 CITATIONS BELOW ARE WRONG AND ARE CORRECTED LATER. The
-- Extendible Hydraulic Hands/Arm and the Psionic Electro-Magnetic Dampers are
-- printed on 154, not 153; this file assigned pages by category rather than by
-- page. zzzzzz-triax-gear-citations.sql sets both to p.154, and it sorts after
-- this file. BOOK-INGEST-AUDIT.md F40. The rows are left as they shipped here.
--
-- Sorts after add-triax-gear-d-equipment.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('macro-eye', 'Macro-Eye', 'rifts', 'gear', NULL, 20000, '20,000 credits per eye; +20,000 for the camera feature and +10,000 to make it removable', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Eye augmentation. A robot-looking eye that works as a microscope, magnifying 1x to 30x within 3 feet (0.9 m). Popular with medical officers.', 'Rifts World Book 5: Triax and the NGR p.153'),
('macro-eye-laser', 'Macro-Eye Laser', 'rifts', 'gear', NULL, 80000, '80,000 credits per eye', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Eye augmentation with a surgical laser built in, magnifying 1x to 10x. A targeting beam shows where the laser will fire. Its damage is under 1 S.D.C. externally - it is a surgical instrument, not a weapon.', 'Rifts World Book 5: Triax and the NGR p.153'),
('multi-system-eye-socket', 'Multi-System Eye Socket', 'rifts', 'gear', NULL, 200000, '200,000 credits for the socket, plus 10,000 credits for each interchangeable eye', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A permanent housing that takes swappable mechanical eyes. Bio-system eyes do not fit it.', 'Rifts World Book 5: Triax and the NGR p.153'),
('third-eye-implant', 'Third Eye', 'rifts', 'gear', NULL, 350000, '350,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A third eye socket implanted above a real eye or centred on the forehead, housing any type of artificial eye. Penalty: -20% to physical beauty.', 'Rifts World Book 5: Triax and the NGR p.153'),
('medical-sensor-hand', 'Medical Sensor Hand', 'rifts', 'gear', NULL, 20000, '20,000 credits for the mechanical version, or 33,000 credits for one that looks human', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An artificial hand built to house up to fourteen sensor features, each bought separately. The Triax variant of the Rifts sensor hand.', 'Rifts World Book 5: Triax and the NGR p.153'),
('epidermic-analyzer', 'Epidermic Analyzer', 'rifts', 'gear', NULL, 35000, '35,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A sensor-hand feature: a molecular analyzer reading skin and perspiration by touch over about a minute - salt, sugar, enzymes and body temperature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('pulse-and-pressure-detector', 'Pulse & Pressure Detector', 'rifts', 'gear', NULL, 25000, '25,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A sensor-hand feature measuring pulse from a minute of contact, and blood pressure from the squeeze and release.', 'Rifts World Book 5: Triax and the NGR p.153'),
('stethoscopic-feature', 'Stethoscopic Feature', 'rifts', 'gear', NULL, 10000, '10,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A sensor-hand feature turning the hand into a stethoscope. Needs an ear implant, or a universal finger jack and a receiver, to hear anything.', 'Rifts World Book 5: Triax and the NGR p.153'),
('universal-finger-jack', 'Universal Finger Jack', 'rifts', 'gear', NULL, 10000, '10,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A cybernetic plug in the fingertip for computers, audio and sensory equipment, radios, video, microphones and disc players. Pairs with an ear receiver.', 'Rifts World Book 5: Triax and the NGR p.153'),
('universal-laser-finger-scalpel', 'Universal Laser Finger Scalpel', 'rifts', 'gear', NULL, 5000, '5,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A finger that doubles as a surgical laser scalpel. Maximum damage 1D4 S.D.C. - it is not a mega-damage weapon and will not be mistaken for one.', 'Rifts World Book 5: Triax and the NGR p.153'),
('universal-finger-camera', 'Universal Finger Camera', 'rifts', 'gear', NULL, 1200, '1,200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A tiny automatic-exposure still camera in the fingertip, holding 48 photographs on microfilm.', 'Rifts World Book 5: Triax and the NGR p.153'),
('bio-comp-self-monitoring-system', 'Bio-Comp Self-Monitoring System', 'rifts', 'gear', NULL, 2500, '2,500 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A nano-implant tracking pulse, blood pressure, temperature, blood sugar, respiration and foreign substances, displaying to a wristwatch, a bracelet, or a computer through a finger jack or headjack.', 'Rifts World Book 5: Triax and the NGR p.153'),
('internal-comp-calculator', 'Internal Comp-Calculator', 'rifts', 'gear', NULL, 1000, '1,000 credits for the basic version - addition, subtraction, multiplication, division and fractions - or 5,000 credits for one handling algebra, geometry and calculus', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A calculator implant driven by voice, radio or computer, reached through a headjack, an ear implant or an artificial eye. The stored cost is the basic version.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-clock-calendar', 'Clock Calendar (Implant)', 'rifts', 'gear', NULL, 200, '200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand clock and calendar feature, as the Rifts core rules describe it.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-heat-sensor', 'Heat Sensor (Implant)', 'rifts', 'gear', NULL, 5000, '5,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand heat sensor feature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-gyro-compass', 'Gyro-Compass (Implant)', 'rifts', 'gear', NULL, 600, '600 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand gyro-compass feature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-motion-detector', 'Motion Detector (Implant)', 'rifts', 'gear', NULL, 15000, '15,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand motion detector feature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-radar-sensor', 'Radar Sensor (Implant)', 'rifts', 'gear', NULL, 2000, '2,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand radar feature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('cyber-radiation-sensor', 'Radiation Sensor (Implant)', 'rifts', 'gear', NULL, 1200, '1,200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A standard sensor-hand radiation sensor feature.', 'Rifts World Book 5: Triax and the NGR p.153'),
('extendible-hydraulic-arm', 'Extendible Hydraulic Hands/Arm', 'rifts', 'gear', NULL, 150000, '150,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A bionic arm that extends 3 to 6 feet (0.9 to 1.2 m) on mental or verbal command, at a typical arm P.S. of 10 to 20.', 'Rifts World Book 5: Triax and the NGR p.153'),
('psionic-electro-magnetic-dampers', 'Psionic Electro-Magnetic Dampers', 'rifts', 'gear', NULL, NULL, 'The book prints NO price for this implant, where every other entry on these pages carries one', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A brain implant that fogs telepathic and psionic probes. Bonuses: +1 to save against all psionic attacks, +2 to save against possession, and +1 to save against magic illusions and mind control.', 'Rifts World Book 5: Triax and the NGR p.153'),
('laser-beam-eye', 'Laser Beam Eye', 'rifts', 'weapon', NULL, 130000, '130,000 credits', '2D6 M.D. from a single eye, or 4D6 M.D. from both fired together, which counts as one attack', 1, '1000 feet (305 m)', 'Unlimited', 'Equal to the total hand to hand attacks of the borg', NULL, NULL, NULL, 'An eye-mounted laser for robots and cyborgs. Bonus: +1 to strike. The NGR also fields a particle beam version.', 'Rifts World Book 5: Triax and the NGR p.154'),
('lgl-31-grapnel-launcher', 'LGL-31 Grapnel & Launcher', 'rifts', 'weapon', NULL, 5000, '5,000 credits', 'Minimal - it is a tool, not a weapon', 0, '100 feet (30.5 m) of retractable cord, test strength 2000 lbs (900 kg)', NULL, NULL, NULL, NULL, NULL, 'A bionic grappling hook launcher with a pneumatic winch.', 'Rifts World Book 5: Triax and the NGR p.154'),
('pl-31-palm-laser-torch', 'PL-31 Palm Laser Torch', 'rifts', 'weapon', NULL, 15000, 'Black market 15,000 credits', '3D6 M.D. from one hand, or 6D6 M.D. from both', 1, '1 foot (0.3 m)', 'Unlimited', 'Equal to the hand to hand actions of the operator', NULL, NULL, NULL, 'A short-range palm laser torch for cutting through armour and locks. Currently standard only on the NGR T-31 Super Trooper.', 'Rifts World Book 5: Triax and the NGR p.154'),
('rvb-31-concealed-vibro-blade', 'RVB-31 Concealed Vibro-Blade', 'rifts', 'weapon', NULL, 5000, '5,000 to 10,000 credits', '2D4 M.D. for a human-sized sabre blade, 2D6 M.D. for an 8 to 10 foot borg or robot, or 3D6 M.D. for a giant unit over 10 feet', 1, 'Hand to hand', NULL, NULL, NULL, NULL, NULL, 'A retractable vibro-blade housed in the forearm.', 'Rifts World Book 5: Triax and the NGR p.154');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 'cyber-%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-e-cybernetics.sql');
