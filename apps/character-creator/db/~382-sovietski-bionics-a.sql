-- Rifts World Book 36: Sovietski - cybernetics and bionics, printed 157-159.
-- 9 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~382-sovietski-bionics-a.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.
-- ALL 9 ARE NEW: no gear row in production cites Rifts World Book 36, and
-- catalog-diff --remote (2026-11-22) matched none of these names but the
-- Combat Computer, by alias only (see below).
--
-- PRINTED 155-159 CARRY 11 Cost: LINES. The first (p.155) prices the cyborg
-- bear, not a cybernetic, and is not this script's. Cyberlink (p.159, priced
-- on a "Cost (in Russia):" line) is a later row's, and so is Cyber-Skates,
-- which starts on p.159 and is priced on p.160. That leaves 10 systems.
--
-- CAMERA FINGER (p.158) IS LEFT OUT. It reprints the held Universal Finger
-- Camera (Triax and the NGR p.153): the same 48-shot microfilm fingertip
-- camera at the same 1,200 credits. The held row is left as it is.
--
-- THE SOVIETSKI COMBAT COMPUTER IS NOT THE NEW WEST ONE. The held
-- combat-computer (New West p.189) costs 150,000 and gives +2 to pull punch
-- and roll; the pirated Triax copy costs 200,000 and gives +1 to each. A new
-- row; the held one is left as it is.
--
-- THE SECTION OPENING (p.155-157) IS NOT ROWS. Salvaging bionics from the
-- dead is routine in Russia; a finder who sells a working part gets 10-15% of
-- its original value, or 2% from the government, and selling a dead Sovietski
-- cyborg for parts is a crime (p.156). The optional Unauthorized Vendors table
-- (p.156-157) rolls for flaws in Body-Chop-Shop work. Neither is stored.
--
-- A cost printed as two figures (the Advanced Remote Hand with or without
-- auto-retrieve, Cyber-Crampons by machine class) stores the lower, with both
-- in cost_note. The cache was checked against a 110 dpi render of p.158; the
-- manifest lists no substituted digits on p.155-159.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('sovietski-advanced-remote-hand', 'Advanced Remote Hand', 'rifts', 'cybernetics', NULL, 20000, '20,000 credits for the advanced upgrade; 22,000 with the auto-retrieve function (2,000 extra). Requires the Remote Hand tool appendage.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 20, 'Espionage upgrade to the remote hand tool prosthetic: the hand detaches and is steered by a built-in radio link out to 4,000 ft (1,219 m), scuttling on its fingers like a crab to scout or reach tight spots. Cameras, finger weapons or a bionic eye can be fitted to it, each bought separately; without a camera the owner must keep it in sight to guide it. Because the fingers serve as legs, only the middle finger may take an enhancement that locks it rigid (such as a finger gun), and that cuts its speed by 20%. The hand''s P.S. and P.P. are capped at 14. It moves at Spd 5, about 3.5 mph (5.6 km). The optional auto-retrieve lets the hand find its way back to its owner within radio range. M.D.C. of the hand: 20. Prerequisite: Remote Hand tool appendage.', 'Rifts World Book 36: Sovietski p.157-158', NULL),
  ('sovietski-built-in-loudspeaker', 'Built-In Loudspeaker', 'rifts', 'cybernetics', NULL, 6000, '6,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An implanted amplifier that lets the cyborg boost his voice like a bullhorn, to roughly 80 decibels.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-video-finger-camera', 'Camera, Video Finger', 'rifts', 'cybernetics', NULL, 10000, '10,000 credits, a hand-held monitor included', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A miniature digital camera in a fingertip that transmits silent color video to a separate monitor or recorder: a hand-held unit, a computer screen rigged to receive it, or a studio system. Most military robots and vehicles able to receive such signals can view the feed, though usually not record it. A cyborg or anyone with cybernetic eyes can watch the feed in his own eyes, which makes it ideal for peering around corners.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-climb-cord', 'Climb Cord', 'rifts', 'cybernetics', NULL, 1500, '1,500 credits; a grappling hook or other attachment is extra (under 30 credits to make or buy).', '1D6 S.D.C. (weighted, swung like a chain)', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A spy''s tool akin to the cybernetic garrote: 20 ft (6.1 m) of string-thin cord rated to 1,500 lbs (675 kg), drawn out of an artificial wrist or arm. With a weight tied on it serves as a chain-type weapon; with a small grappling hook it becomes a climbing line.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-combat-computer-pirated-triax', 'Combat Computer (Pirated Triax Tech)', 'rifts', 'cybernetics', NULL, 200000, '200,000 credits. A few have reached the Black Market, where they are rare and fetch up to 1 million credits.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'The Sovietski''s copy of a New German Republic design, now fitted to many of its factory-built full conversion chassis. Built from German plans on slightly older technology, it is bulkier and hungrier for power than the original. It pools whatever the cyborg''s own senses and sensors take in, analyzes it, and feeds the result to the brain as quicker reflexes. Too big and power-hungry for anything but full conversion Light, Heavy and Superheavy Machines. Bonuses: +1 each to initiative, dodge, disarm, pull punch and roll with impact. Prerequisite: a nuclear-powered full conversion chassis (Light, Heavy or Superheavy Machine). Not the New West Combat Computer, which prices and scores differently.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-combat-computer-ranged-program', 'Combat Computer Ranged Enhancement Program (CCREP)', 'rifts', 'cybernetics', NULL, 200000, '200,000 credits. Requires the Combat Computer.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A targeting program for the Combat Computer that tunes its sensors to far-off targets, keeps refining the aim and steadies the cyborg''s internals into a firmer gun platform. Switching it on takes a full melee round of recalibration, with no Combat Computer bonuses meanwhile. Applies only to weapons built into the cyborg, never hand-held rifles or pistols. Bonuses: on a Called Shot +2 strike and +1 disarm; on an Aimed shot +1 strike; half the usual penalty against small or fast targets. While it runs, melee goes badly: -1 to roll with impact and -2 each to strike, parry and dodge. It can be shut off at once, but the Combat Computer or the CCMEP then needs a full melee round (15 seconds) to come back. Prerequisite: Combat Computer.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-combat-computer-melee-program', 'Combat Computer Melee Enhancement Program (CCMEP)', 'rifts', 'cybernetics', NULL, 325000, '325,000 credits. Requires the Combat Computer.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A close-quarters program for the Combat Computer, focusing its sensors on foes nearby in hand to hand and urban fighting; it reads shifts in air temperature and pressure that betray someone hiding or about to strike, and the world seems to slow a little for the cyborg. Switching it on takes a full melee round of recalibration, with no computer or program bonuses meanwhile. Applies only bare-handed or with melee weapons, never ranged weapons, pistols included. Bonuses: +1 melee attack, +1 to parry and dodge. On a Light Machine chassis it also grants an automatic dodge against melee attacks that costs no attack; that dodge is a bare D20 plus P.P. modifiers only, with no other bonus of any kind. Penalty: -3 to dodge ranged attacks while it runs. Prerequisite: Combat Computer.', 'Rifts World Book 36: Sovietski p.158', NULL),
  ('sovietski-cyber-crampons', 'Cyber-Crampons', 'rifts', 'cybernetics', NULL, 3000, '3,000 credits a pair for Light Machines; 5,000 for Heavy and Superheavy Machines. The lower figure is stored.', '+6 M.D. to a leap kick, +2 M.D. to other kicks (on ice)', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'Retractable spikes in the toes, heels and soles, a favorite of Russian cyborgs for winter footing; extending them takes one melee action. On ice a cyborg without them moves at a quarter of his Spd and must roll to keep his balance (-30%) after every combat action. With them he loses only 30% of his Spd on ice, needs no balance roll, and gains +10% to maintain balance, +5% to Climbing on icy cliffs or slick rock, and +6 M.D. to leap kicks and +2 M.D. to other kicks. Off the ice they are clumsy and give no bonus, beyond anchoring the cyborg in hard ground (not soft earth or mud). Feet fitted with them can take no other foot enhancement.', 'Rifts World Book 36: Sovietski p.158-159', NULL),
  ('sovietski-cyber-nano-robot-repair-system', 'Cyber-Nano-Robot Repair Systems (CNRRS)', 'rifts', 'cybernetics', NULL, 250000, '250,000 credits', NULL, 0, NULL, 'Two repair jobs, then used up', NULL, NULL, NULL, NULL, 'The cyborg''s answer to the RMK and IRMSS medical nano-systems: nano-bots released on demand that scavenge spare material to mend armor and machinery, and can also reroute and seal internal circuits and repair internal organs to a degree. One job restores up to 40 M.D.C. to armor or to a single limb, the head or the main body, or fixes one eye, sensor, implant, weapon or organ more or less completely. Time depends on the job: a small job (up to 10 M.D.C.) takes 3D6 minutes; a medium one (15-25 M.D.C.) takes 1D6x10+30 minutes; large or complex, such as a whole arm and hand, a leg, a major organ or weapon, or the main body (40 M.D.C. at most), 2D6x10+90 minutes. See also Micro-Repair Robots (MiRR).', 'Rifts World Book 36: Sovietski p.159', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 9 gear rows are in' AS assertion, count(*) AS got, 9 AS want
  FROM gear WHERE slug IN ('sovietski-advanced-remote-hand', 'sovietski-built-in-loudspeaker', 'sovietski-video-finger-camera', 'sovietski-climb-cord', 'sovietski-combat-computer-pirated-triax', 'sovietski-combat-computer-ranged-program', 'sovietski-combat-computer-melee-program', 'sovietski-cyber-crampons', 'sovietski-cyber-nano-robot-repair-system') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~382-sovietski-bionics-a.sql');
