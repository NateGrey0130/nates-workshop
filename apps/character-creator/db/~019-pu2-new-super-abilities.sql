-- Powers Unlimited Two's New Super Abilities, printed 94-95: FOUR rows, two
-- major and two minor. Directed Force (major, printed 94-95), Super Power
-- Punch (major, printed 95), Sidestep (minor, printed 95) and Spit Spikes
-- (minor, printed 95).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~019-pu2-new-super-abilities.sql
--
-- WHY THESE COME IN WHEN THE BOOK IS EXCLUDED. Decision D0
-- (docs/surveys/heroes-unlimited-core.md) excludes Powers Unlimited Two because
-- its twelve power CATEGORIES name HU2-core abilities by page and assume
-- P.P.E. Nate carved this section out of D0 on 2026-09-26: the four abilities
-- are self-contained, cite no HU2 page, and have the same shape as Powers
-- Unlimited One's and Three's rows. The twelve categories stay excluded.
--
-- FOUR, NOT TWO. The survey, D0's table and the carve-out brief all said "two
-- new major super abilities". Printed 95 prints four headings under New Super
-- Abilities: the two majors, then "Sidestep (Minor Ability)" and "Spit Spikes
-- (Minor Ability)". Both pages were rendered (cache p095, p096) and the count
-- is the page's; the two minors were read past because they sit at the foot of
-- the right-hand column. All four are imported.
--
-- NONE IS A DUPLICATE. Checked --remote on 2026-09-26 against all 364 rows:
-- no name matches, and the nearest - Force Strike (PU3), Force Manipulation
-- (PU3) and Shadow Stepping (PU1) - are different powers.
--
-- THE STAT-BLOCK COLUMNS: Super Power Punch prints a leading Range / Duration
-- / Damage block, so those three columns are filled and the lines leave the
-- description, as the Revised core's rows do. Directed Force's Range and
-- Damage belong to its Bolts of Force sub-power, and Spit Spikes prints its
-- labels inside the paragraph; both stay NULL, the Powers Unlimited Three rule.
--
-- TEXT. Directed Force runs across two columns and a page break; the OCR
-- interleaves the right-hand column's first line ("A strong push is designed
-- to knock an opponent off his") into the heading, and the text was put back
-- in the order of the render. OCR slips fixed against the render: levels,
-- blast, them/it, only, lose, roll, wall, unable, dodging, all. Super Power
-- Punch's Damage line moved to its column, so the worked example that follows
-- it is labelled "Damage example:" in the description (the book prints
-- "Example:"). Line-wrap
-- hyphens rejoined between letters only; curly quotes and dashes folded to
-- ASCII for d1-apply's pre-flight.
--
-- Keyed on name (UNIQUE), so a re-run is a no-op.

INSERT INTO super_abilities
  (name, tier, source, source_book, system, range, duration, damage, saving_throw, description)
SELECT 'Directed Force', 'major', 'import', 'Powers Unlimited Two p.94-95', 'heroes-unlimited', NULL, NULL, NULL, NULL, 'The character fires bolts of force that are neither energy nor matter, but something akin to Telekinesis or a Force Field. However, the ability does not create any sort of defensive barrier and is primarily an offensive weapon. Bolts of Force: The superbeing fires bolts of force that hit an opponent or target like a sledgehammer. To strike an opponent the character must see his target and have a clear line of fire, point and shoot. The force blast is typically emitted from the character''s hands/fingertips, but can also be fired at close range from the forehead by concentrating to do so. Range: 100 feet (30.5 m) +20 feet (6.1 m) per level of experience from the hands; 10 feet (3 m) +1 foot (0.3 m) per level of experience from the forehead. Damage: 3D6 points of damage +1D6 at experience levels 2, 4, 7, 9 and 12. Battering Doors Open: Directed Force that functions like an invisible battering ram to smash doors open (think SWAT team and battering ram). Each battering attack does 2D6 damage to the door itself and any secondary locks, bolts and hinges, but the brunt of the damage, 4D6+30, goes to the main lock or the small area where the lock slides into the doorframe. The weak spot for most ordinary doors is the wooden doorframe which usually gives way under force. One force blast smashes open the typical door by cracking and splintering the wooden doorframe (the focal point of the damage being the area where the lock slides into the wooden doorjamb, which typically has only 3D6+10 S.D.C.). Heavy locks and doorframes can withstand 4D6+20 S.D.C. before shattering and giving way to the battering force with only one or two blasts. Security doors or any metal reinforced doors with a metal reinforced frame typically require 3-5 blasts before the lock (which typically has 5D6+40 S.D.C.) gives way, or the metal door frame (which has 5D6+70 S.D.C.) bends or snaps to force the door open. Ultimately, when the S.D.C. of the lock or the door frame (not the S.D.C. of the entire door) is reduced to zero the door gives and pops open. Likewise, an entire window of glass is shattered, usually blowing the window out completely, with a single blast of Directed Force (automobile safety glass requires two blasts to blow out completely). Pushing Force: This aspect of Directed Force has a number of interesting applications, but the bottom line is the Pushing Force is able to hold someone or something in place as if an invisible force were pushing against them/it. Pushing/Ramming People: Rather than inflict a powerful punching blow, as above, the character may choose to use the force blast to push/shove an opponent. The force feels like someone has just shoved the victim with both hands. A light shove does only 1D4 damage and may cause the victim to stumble a few steps. A strong push is designed to knock an opponent off his feet with the impact of getting struck by a car. It does 2D6 damage, knocks the victim off his feet, and sends him slamming into the next nearest person or wall, or onto his backside 1D6 yards/meters away. The jarring attack momentarily knocks the breath out of most humanoid victims, causing them to lose initiative, lose two melee attacks and drop anything they were holding, unless a successful roll with impact is made. A successful roll to save vs (punch, fall and) impact means the victim only loses one melee attack, he holds on to whatever was in his hands, he takes half damage, and is back on his feet and ready to retaliate without losing initiative (he only loses that one melee attack). Note: This "push" attack is ineffective against opponents who weigh 600 pounds (270 kg) or more. Nail Someone to the Wall: The Directed Force is used to push an adversary against a wall or any solid surface and hold him in place. Only a Supernatural P.S. of 31 or greater can slowly push against the Directed Force or is sufficient enough to slide and slip out of its crushing force (takes 1D4 melee rounds to slip out). Otherwise, the victim is held tight and held flat, unable to swing a punch, kick or point a weapon. However, mind powers and super abilities that only require line of sight (like energy blasts from the eyes) are not blocked or affected by the holding force. Also see the Note at the end of this description. Hold Doors Closed: To hold a door closed, the hero must be on the side of the door that swings open, because his ability is to create a force that pushes against the door and therefore, holds it so tightly that it doesn''t budge. A door without a viable lock is held as if someone with a Supernatural P.S. of 32 were braced against it; a basic door and working lock is the equivalent of a Supernatural P.S. of 34; a reinforced door with heavy-duty locks the equivalent of a Supernatural P.S. of 44 - the locks and reinforcement adding to the overall strength and resistance to those trying to push it open. Only a Supernatural P.S. greater than that can force the door open while the Directed Force is holding it shut. Also see the Note at the end of this description. Holding Vehicles in Place: Again, the character must be facing the vehicle and using the Directed Force to push against it, to hold it in place and to stop it from going forward. If the vehicle is put into reverse or manages to turn, however, it can spin away from the force pushing against it. Similarly, if the superbeing is off to the side of the vehicle he can use Directed Force to pin a vehicle against a wall, barrier or larger vehicle, provided the force attack occurs while the vehicle is NOT in motion or is traveling under 10 mph (16 km). The Directed Force holding the vehicle has the equivalent of a Supernatural P.S. of 30. Also see the Note at the end of this description. Note: In the three latter cases, holding someone or something in place requires the superbeing to do nothing else. All his attacks are focused on maintaining the Directed Force to hold the target in place. He can talk or shout but cannot move, look away or use a different power, nor draw a conventional weapon. He must keep his eyes on the target and remain focused on the task of holding it in place with his force power.'
WHERE NOT EXISTS (SELECT 1 FROM super_abilities WHERE name = 'Directed Force');

INSERT INTO super_abilities
  (name, tier, source, source_book, system, range, duration, damage, saving_throw, description)
SELECT 'Super Power Punch', 'major', 'import', 'Powers Unlimited Two p.95', 'heroes-unlimited', 'Close combat/touch/hand to hand.', 'Instant: punch and damage, lingering penalties and side effects (1 melee).', 'Punch or kick damage +P.S. damage bonus multiplied by the number of attacks the character has that melee round.', NULL, 'This power uses up ALL of the character''s attacks per melee round in one devastating blow. The Super Attack takes all the destructive force from each of the superbeing''s potential attacks and compacts them into one pile-driver of a punch. Damage example: If the character has five attacks per melee round, and for him, a normal punch does 1D6 damage and he has a +6 damage bonus from P.S. and +4 damage bonus from Hand to Hand Combat: Assassin, he has a combined damage bonus of +10. When he does a Super Power Punch, roll the 1D6, multiply the result by 5x +50. The 50 is the total, normal damage bonus x 5 (the number of attacks per melee round). The end result is damage in the range of 5-30+50 S.D.C./H.P., and that''s from a comparatively puny character. A powerhouse with Superhuman or Supernatural P.S. or Super Speed and/or a greater number of attacks could inflict two to five times that amount of damage! A Super Power Punch (or strike) can also be done with a melee weapon such as a club, knife, sword, axe, etc., however, in this case the weapon''s usual damage is only counted once and then the punch damage +P.S. and other normal damage bonuses are added together and multiplied by the number of attacks the character has per melee round. Limitations, Penalties & Dangers: 1. This attack can only be used once per minute of combat (i.e., once every four melee rounds). 2. This attack must be announced at the beginning of the melee round. 3. ALL attacks are used up whether the superbeing hits or misses. Roll to strike as usual. A miss means the superbeing is likely to hit something (a wall, vehicle, etc.), or someone, standing next to or behind his opponent. If so, whatever he hits takes the full brunt of the punch. Only a successful roll to save vs punch/fall/impact will reduce the damage (by half). 4. This attack cannot be pulled - no pull punch applies when using this haymaker attack. 5. The character uses up all of his attacks in that one, single punch! He has no other actions/attacks for the rest of that melee round and can do nothing else. Not run, not step to the side, not make a call on his cell phone, nothing! Any attacks directed at him for the rest of the melee round can be parried or dodged, but at half the character''s usual bonuses, because he is spent from the Super Power Punch. If the character opts to dodge, each dodge counts as one of his attacks for the next melee round. If the character has automatic dodge, the energy taken out of him by the Super Power Punch is so draining that even the act of automatic dodging now counts as one melee attack for every two auto-dodges he attempts. 6. Other Ramifications. A miss that hits a load bearing wall could knock half a building down, killing dozens of innocent people and hurting scores of others. A miss that hits a car could destroy it or knock it into another car and cause a pileup and block traffic. And a miss that hits a teammate or a bystander could kill him! In addition, such a display of raw power may also terrify bystanders and law enforcement (and maybe even the bad guys), and cause a panic and/or get all (or many) of the opponents to draw all (or a lot) of their firepower/attacks on the superbeing who demonstrated the Super Power Punch. Other damage and consequences, from damaging property, breaking water mains and gas lines to injuring others and creating panic, among others, may result from the reckless use of this super ability. Game Master Condition: This power can, if not played with all its penalties and some thought on the part of the player and the Game Master, unbalance game play, and for that reason is only available if the G.M. allows it.'
WHERE NOT EXISTS (SELECT 1 FROM super_abilities WHERE name = 'Super Power Punch');

INSERT INTO super_abilities
  (name, tier, source, source_book, system, range, duration, damage, saving_throw, description)
SELECT 'Sidestep', 'minor', 'import', 'Powers Unlimited Two p.95', 'heroes-unlimited', NULL, NULL, NULL, NULL, 'The ability to make an automatic dodge with a +8 bonus to do so, but only by stepping to the side. This power is even good for sidestepping thrown and falling objects, arrows, bullets, and missiles, provided the superbeing can step sideways to avoid it, and sees the shooter fire or the object coming (if it''s large enough). Note: Reduce the bonus to sidestep to only +3 when attempting to dodge bullets and energy blasts. If held in place, held down, or if there is no room to take one full step (approximately one foot/0.3 m) to either side, the character cannot sidestep and must dodge as normal, using up one melee attack/action with the movement to dodge.'
WHERE NOT EXISTS (SELECT 1 FROM super_abilities WHERE name = 'Sidestep');

INSERT INTO super_abilities
  (name, tier, source, source_book, system, range, duration, damage, saving_throw, description)
SELECT 'Spit Spikes', 'minor', 'import', 'Powers Unlimited Two p.95', 'heroes-unlimited', NULL, NULL, NULL, NULL, 'The superbeing generates and spits tiny dart-like spikes (small needles) from his mouth. Each spike spitting attack counts as one melee action/attack and unleashes 1D4 tiny spikes +1 per level of the character''s experience. The attack must be directed at one target with all spikes either hitting or missing (roll to strike once for the entire volley of spikes). Damage: One point per each spike. Range: 10 feet (3 m) +2 feet (0.6 m) per level of experience. Payload: Unlimited. Special Combo: If the character also has the Chemical Secretion power (see page 64 of Powers Unlimited One), the spikes can be laced with a toxin as outlined under that power, excluding Acid, but the duration for the chemical effect is half.'
WHERE NOT EXISTS (SELECT 1 FROM super_abilities WHERE name = 'Spit Spikes');

-- Read-backs.
SELECT 'Powers Unlimited Two holds four super abilities' AS assertion,
       count(*) AS got, 4 AS want
  FROM super_abilities WHERE source_book LIKE 'Powers Unlimited Two p.%';

SELECT 'two major, two minor' AS assertion, count(*) AS got, 2 AS want
  FROM super_abilities WHERE source_book LIKE 'Powers Unlimited Two p.%' AND tier = 'major';

SELECT 'only Super Power Punch carries a stat block' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities WHERE source_book LIKE 'Powers Unlimited Two p.%' AND range IS NOT NULL;

SELECT 'the Spit Spikes combo points at a row this catalog holds' AS assertion,
       count(*) AS got, 1 AS want
  FROM super_abilities WHERE name = 'Chemical Secretion' AND source_book = 'Powers Unlimited One p.64';

SELECT 'the three earlier books are untouched' AS assertion, count(*) AS got, 364 AS want
  FROM super_abilities
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
    OR source_book LIKE 'Powers Unlimited One%'
    OR source_book LIKE 'Powers Unlimited Three%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~019-pu2-new-super-abilities.sql');
