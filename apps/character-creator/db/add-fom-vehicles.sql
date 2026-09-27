-- Federation of Magic: the seven Magic Automatons (printed 97-112) and the
-- Stormspire Techno-Wizard vehicles (printed 120-125). Twelve `vehicles` rows:
-- seven automatons, four TW vehicles and the Battle Streaker.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-fom-vehicles.sql
--
-- Survey: apps/character-creator/docs/surveys/fom.md, PR C of its plan.
--
-- == AUTOMATONS ARE `vehicles` ROWS, CLASS `robot` ==
--
-- Decided in the survey (orchestrator, 2026-09-26; Nate may override), on the
-- precedent of New West's Glittermount: a magical construct a character owns
-- and rides is a vessel, and `character_vehicles` is how a character owns one.
-- Two automatons fit that shape less well and say so in their description:
-- the INFILTRATOR is never ridden (it is remote-controlled by a bonded
-- Controller out to 500 feet), and the COLOSSUS cannot be piloted by the
-- Controller O.C.C. at all - only a High Magus or a Lord of Magic.
-- No automaton has a price: every one prints "completely unavailable", so
-- `cost` is NULL and the note carries what the book says instead.
--
-- == THE BATTLE STREAKER IS ITS OWN ROW ==
--
-- Printed 122 prices it inside the Ley Streaker's cost line: a combat version
-- at 8 million credits against the Streaker's 5-6 million, with two weapon
-- systems the Streaker lacks, "all other stats the same". A different price
-- and a different weapons fit make it a different thing to own, so it gets a
-- row, repeating the Streaker's stat block, and its own weapons.
--
-- == THE ZONE RANGER'S SIX ADD-ONS ARE `vehicle_weapons` ROWS, NOT GEAR ==
--
-- Printed 123-124 lists them as the vehicle's numbered "TW Weapons and Special
-- Features", each priced as an extra. `gear.vehicle_slug` was NOT used: that
-- column (migration 053) means "this gear row IS a vessel", not "an option for
-- one", and a gear row pointing at the Zone Ranger would read as the Zone
-- Ranger itself. The book's own numbering fits `vehicle_weapons.ordinal`, and
-- each row's note carries its price. The Trailblazer's feature 6 says the same
-- options are available to it at extra cost; that is prose on its row, not a
-- second copy of the six.
--
-- == WHERE THE TEXT LAYER LIES ==
--
-- Every `1D` on the automaton pages reads `ID`, and `x` multipliers read `~`
-- (`1D6~10+12`). Printed 100 is welded (the Colossus's speed and statistics
-- interleave with its mace): read off a render. Printed 102, 105 and 109 are
-- full-page illustrations and carry no text; nothing printed is missing there.
-- The Earth Thunder's combat bonuses and Horror Factor are on printed 104.
--
-- == THE BOOK DISAGREES WITH ITSELF, AND BOTH READINGS ARE RECORDED ==
--
--   Earth Thunder P.P.E. battery: the stat block says 100, regenerating 10 an
--     hour; the spell paragraph on the same page says a reserve of 120,
--     regenerating 20 an hour. The stat block is the one stored first.
--   Battle Skimmer: the M.D.C. table prints Starfire Cannons (4-6); the weapon
--     entry prints four.
--   Starfire Pulse Cannon range: 2000 feet on the Battle Skimmer, 4500 feet on
--     the Trailblazer.
--   Ice Drake spell list: Sub-Particle Acceleration at 30 P.P.E. (double range)
--     where the Colossus and Kilairgh lists print 20.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('battlelord-automaton', 'Battlelord Automaton', 'rifts', 'robot',
   'One; typically an experienced Battle Magus Controller or Lord Magus. Only elite Controllers (7th level and higher), Lord Magi (5th level and up) and High Magi (4th level and higher) are allowed to pilot one.',
   'None.',
   'Running 50 mph (80.4 km). Leaping 20 feet (6 m) long and 8 feet (2.4 m) high. Climbs with its fingers and hands up mountains and sheer walls, if the structure can bear its weight.',
   'Not possible.',
   'Cannot swim, but can walk the sea floor, withstanding pressure to one mile (1.6 km) deep; the pilot has no such protection.',
   'Height 18-24 feet (5.4 to 7.3 m). Width 9-11 feet (2.7 to 3.3 m) at the shoulders. Length 7-9 feet (2.1 to 2.7 m).',
   '11-15 tons',
   1000, NULL,
   'Completely unavailable. Would sell for millions if the buyer could activate and use it in any capacity; may sell as a work of art for several thousand credits.',
   'Magic Automaton, Dweomer City. An 18-24 foot humanoid war machine of metal or stone: ornate armor, thick waist, barrel chest, a large head with two stark white orbs for eyes, crowned with a helmet or stylized ram''s horns and an ornate roaring lion. It carries a 12-18 foot magic two-handed sword weighing half a ton, and it is one of only two automatons that can speak (the words are its Controller''s). Considered the most reliable automaton, strongest against infantry, tanks and robots and weakest against fast, agile fliers such as SAMAS. PILOT AREA: the head; the Controller sits in the crown as in a giant bowl. BODY TYPE: metal or stone. P.S.: supernatural 45. POWER: magic, unlimited lifetime on a high-magic world like Rifts Earth. P.P.E. BATTERY: 200, regenerating 20 per hour. CONTROL RANGE: standard (about 200 feet for a Controller). REGENERATION: with the main body destroyed it collapses, but while it has 2 M.D.C. a Controller spending 20 of his own P.P.E. regenerates it at 5D6 M.D. per melee round, to full or 100 M.D.C., whichever is less. DAMAGE NOTES: a destroyed foot reduces speed 15%, a destroyed leg 50%; the eyes are a called shot at -4 and shooting them out has no effect; destroying the head exposes the Controller, who is then vulnerable to called shots and area attacks, and the headless automaton fights on through his eyes but loses any head weapons. The sword may be used one- or two-handed. ATTACKS: equal to the pilot''s; +1 when piloted by a High Magus; a Controller adds +1 per two levels starting at level two; +6 under a Lord of Magic. HAND TO HAND DAMAGE: restrained punch 1D6 M.D., full strength punch 1D4x10 M.D., power punch 2D4x10 M.D. (counts as two attacks), body block 4D6 M.D., stomp 4D6 M.D., kick 6D6 M.D.; no leap kick. BONUSES: Horror Factor 15; +3 on initiative (+4 with sword), +4 to strike (+6 with sword), +6 to parry (+8 with sword), critical strike on a natural 18-20; cannot roll with impact or fall. The pilot''s bonuses are not added, but a Controller adds +1 to each. COMMON AUTOMATON FEATURES (printed 96-97): not alive; needs no food, air or energy; impervious to fear, disease, poisons, gases, radiation, heat, cold, fire, mind control, illusions and possession (except by gods and alien intelligences); sees and hears everything its Controller does and vice versa; a linked automaton answers only its Controller or the High Magus who made it; if its pilot is knocked out it fights at half ability only to get him to safety, and if he dies it stands inert. Only a Controller, its creator or a Lord of Magic can make it cast spells; at most two spells per melee round, at the Controller''s level.',
   'Rifts World Book 16: Federation of Magic p.97-99'),

  ('colossus-automaton', 'Colossus Automaton', 'rifts', 'robot',
   'One; typically an experienced High Magus or a Lord of Magic. THE CONTROLLER O.C.C. CANNOT PILOT IT: the Colossus is the one automaton reserved to the most heroic and noble High Magi and the three Lords of Magic.',
   'None.',
   'Running 50 mph (80.4 km). Leaping 30 feet (9 m) long and 12 feet (3.6 m) high. Climbs with its fingers and hands up mountains and sheer walls, if the structure can bear its weight.',
   'Not possible.',
   'Cannot swim, but can walk the sea floor, withstanding pressure to one mile (1.6 km) deep; the pilot has no such protection.',
   'Height 60-68 feet (18.3 to 20.7 m). Width 25 feet (7.6 m) at the shoulders. Length 15 feet (4.6 m).',
   '200-250 tons',
   2000, NULL,
   'Completely unavailable. Would sell for hundreds of millions if the buyer could activate and use it; stealing one is virtually impossible.',
   'Magic Automaton, Dweomer City. The largest automaton, over 60 feet tall, of iron, steel or lead: a giant metal Celtic warrior with tattoo-like ornament, a face bound as if with strips of cloth, blank blue-white eyes and a crown of curled ram''s horns, a spiked mace for a right hand. Only 90 have been built; the Lords of Magic have used it in other dimensions and hold it back on Earth as a secret weapon. PILOT AREA: the top of the head, cradled in the ram''s horns. WHO MAY PILOT IT: a High Magus or a Lord of Magic only - it is the one automaton NOT piloted by the Controller O.C.C. It is one of only two automatons that can speak. P.S.: supernatural 70. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 1200, regenerating about 2D6x10 per hour. CONTROL RANGE: standard. REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 1D6x10 M.D. per melee round, to full or 200 M.D.C., whichever is less. DAMAGE NOTES: a destroyed foot reduces speed 15%, a destroyed leg 50%; the eyes are a called shot at -4 with no effect; destroying the head exposes the pilot and loses any head weapons, though it fights on through his eyes. ATTACKS: the High Magus''s attacks +2; a Lord of Magic''s +4. HAND TO HAND DAMAGE: restrained punch 2D6 M.D., full strength punch 2D4x10 M.D., power punch 2D6x10 M.D. (counts as two attacks), body block 6D6 M.D., stomp 1D6x10 M.D. or a light kick; no martial-arts kicks. The mace adds its own damage (see its weapon entry). BONUSES: Horror Factor 18; +4 on initiative (+5 with mace), +7 to strike (+9 with mace), +7 to parry (+9 with mace), +6 to pull punch, critical strike on a natural 17-20; cannot roll with impact or fall. The pilot''s bonuses are not added. Shares the common automaton features (printed 96-97): not alive, impervious to fear, disease, poison, gases, radiation, heat, cold, fire, mind control, illusions and most possession; stands inert if its pilot dies.',
   'Rifts World Book 16: Federation of Magic p.99-101'),

  ('earth-thunder-automaton', 'Earth Thunder Automaton', 'rifts', 'robot',
   'One; typically a Battle Magus Controller. Controllers often direct three or more at once from cover behind them rather than ride.',
   'None.',
   'Running 40 mph (64 km). Leaping 20 feet (6 m) long and 10 feet (3 m) high. Climbs with its fingers and hands up mountains and sheer walls, if the structure can bear its weight.',
   'Not possible.',
   'Cannot swim, but can walk the sea floor, withstanding pressure to one mile (1.6 km) deep; the pilot has no such protection.',
   'Height 10-12 feet (3 to 3.6 m). Width 5-6 feet (1.5 to 1.8 m) at the shoulders. Length 4-5 feet (1.2 to 1.5 m).',
   '5-7 tons',
   500, NULL,
   'Completely unavailable. Would sell for millions if the buyer could activate and use it in any capacity; may sell as a work of art for several thousand credits.',
   'Magic Automaton, Dweomer City; sometimes confused with golems. The FIRST automaton created and the simplest: a stone or hard clay figure like a golem or earth elemental, a lump of a head with star-bright eyes, two-fingered hands and block feet, with a bronze regimental symbol (crown, trident, sword, shield, plate, crescent or skull) on its forehead. A newer cosmetic design gives it a spiked, bolted-on helmet head and optional shoulder plates, with identical stats. It carries a huge single-edged hooked sword (6-7 feet, 500 lbs) for stabbing, chopping and tearing open armor. The Earth Thunder is mute. PILOT AREA: carved between the shoulders; the rider cannot see forward and sees through the automaton''s eyes, often in a "combat trance". BODY TYPE: stone or hard clay, always an M.D.C. structure. P.S.: supernatural 30. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 100, regenerating 10 per hour, per its stat block (printed 103). THE BOOK DISAGREES WITH ITSELF: the spell-casting paragraph on the same page gives a reserve of 120 regenerating 20 per hour. Both are recorded; the stat block''s is the one stated first here. CONTROL RANGE: standard. EYES: see in any darkness including magical darkness, through smoke, the invisible, and Astral travelers and spirits, and give a linked Controller hawk-like vision (a signpost two miles away). REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 3D6 M.D. per melee round, to full or 100 M.D.C., whichever is less. DAMAGE NOTES: a destroyed foot reduces speed 15%, a destroyed leg 50%; the eyes are a called shot at -4 with no effect; destroying the head partially exposes the Controller and loses head weapons. The sword is used one-handed. ATTACKS: equal to the pilot''s; +1 when piloted by a Lord Magus or High Magus; a Controller adds +1 per two levels starting at level two; +6 under a Lord of Magic. HAND TO HAND DAMAGE: restrained punch 5D6+15 S.D.C., full strength punch 3D6 M.D., power punch 6D6 M.D. (counts as two attacks), kick 4D6 M.D., body flip/throw 2D6 M.D. plus the opponent loses initiative and one attack, stomp 1D6 M.D.; no leap kick. BONUSES (printed 104): Horror Factor 14; +2 on initiative, +3 to strike (+5 with sword), +4 to parry (+6 with sword), critical strike on a natural 19-20, +2 to pull punch; cannot roll with impact or fall. The pilot''s hand to hand bonuses are not added unless he is a linked Controller, who adds +2 to each. Shares the common automaton features (printed 96-97).',
   'Rifts World Book 16: Federation of Magic p.101-104'),

  ('fire-demon-automaton', 'Fire Demon Automaton', 'rifts', 'robot',
   'One; typically an experienced Battle Magus Controller.',
   'None.',
   'Running 75 mph (120 km), and it can run and fight without tiring. Leaping 40 feet (12.2 m) long and 20 feet (6 m) high. Climbs with its fingers and hands up mountains and sheer walls, if the structure can bear its weight.',
   'Not possible.',
   'Cannot swim, and SUFFERS 2D6 M.D. PER MINUTE while submerged.',
   'Height 16-20 feet (4.8 to 6.1 m). Width 8-10 feet (2.4 to 3 m) at the shoulders. Length 6-7 feet (1.8 to 2.1 m).',
   '7-10 tons',
   500, NULL,
   'Completely unavailable. Would sell for millions if the buyer could activate and use it.',
   'Magic Automaton, Dweomer City; sometimes confused with fire elementals and demons. Sculpted from red clay or coal to look like a red demon, with horn-like smoke stacks, blazing yellow eyes, clawed hands, cloven hooves and a slashing prehensile tail; once empowered it appears to be red-hot metal. Less durable and strong than the Battlelord but a brutal engine of fire, most of it spells drawn on its battery. It can only hiss and growl. PILOT AREA: the back of the head, in the crown like a bowl; that seat, the feet, lower legs and tail are not hot. BODY TYPE: clay or coal turned to metal. P.S.: supernatural 38. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 280, regenerating 30 per hour. CONTROL RANGE: standard. REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 5D6 M.D. per melee round, to full or 100 M.D.C., whichever is less. DAMAGE NOTES: a destroyed foot reduces speed 15%, a destroyed leg 50%; the prehensile tail lashes, beats, entangles, grabs and carries, and destroying it costs one melee attack; destroying the horns pours smoke from the head and halves initiative; the eyes are a called shot at -4 with no effect; destroying the head exposes the Controller and loses head weapons. ATTACKS: the pilot''s +1 for the tail; +2 when piloted by a High Magus; a Controller adds +1 per two levels starting at level two; +5 under a Lord of Magic. HAND TO HAND DAMAGE (before heat and fire): restrained punch 1D4 M.D., full strength punch 5D6 M.D., power punch 1D6x10 M.D. (counts as two attacks), claw strike 1D4x10 M.D., tail strike 5D6 M.D., body block 2D6 M.D., stomp 1D6 M.D., kick 5D6 M.D., leap (power) kick 6D6 M.D. (counts as two attacks); the fire touch bonus does not apply to the tail, stomp or kicks. BONUSES: Horror Factor 15; +4 on initiative (+5 with tail), +6 to strike, +5 to parry and dodge, +5 to pull punch, +4 to roll with impact, critical strike on a natural 19-20. IMPERVIOUS TO HEAT AND FIRE, including M.D. plasma and dragon breath, and sees through smoke. The pilot''s bonuses are not added, but a Controller adds +1 to each. Shares the common automaton features (printed 96-97).',
   'Rifts World Book 16: Federation of Magic p.104-106'),

  ('ice-drake-automaton', 'Ice Drake Automaton', 'rifts', 'robot',
   'One; typically a Controller Battle Magus.',
   'None.',
   'Running 120 mph (192 km), and it can run, walk and stand on walls and ceilings. Leaping 50 feet (15.2 m) long and 20 feet (6 m) high, double with a running start of at least 50 mph (80 km). Climbs and runs up any surface that can bear its weight.',
   'Flying 400 mph (640 km), by magic: blue energy fills the two bony wing armatures. The ONLY automaton that can fly.',
   'Cannot swim, but can walk the sea floor to a maximum depth of 1000 feet (305 m).',
   'Height six feet (1.8 m) at the shoulders, 12-15 feet (3.6 to 4.6 m) to the top of the head. Width 5-6 feet (1.5 to 1.8 m) at the shoulders. Length 9-10 feet (2.7 to 3 m) from chest to rump; the tail adds another 6 feet (1.8 m) and the neck another 10 feet (3 m).',
   '5-6 tons',
   300, NULL,
   'Completely unavailable. Would sell for millions if the buyer could activate and use it in any capacity; may sell as a work of art for several thousand credits.',
   'Magic Automaton, Dweomer City. The flying automaton, built to contest Coalition air supremacy: a small blue-and-white dragon of glistening pale-blue ice or glass, thin legs and a long delicate neck, with a saddle seat on its back. It does not need to be aerodynamic; energy wings fill its bony armatures, and attacks on the energy part of a wing pass harmlessly through. Many of its attacks aim to cripple aircraft - icing wings, freezing weapons, frosting canopies. It can only hiss and growl. PILOT AREA: the back, between the shoulders and behind the neck; the exposed rider is a called shot at -1. BODY TYPE: sculpted ice or glass, made an M.D.C. structure by the magic. P.S.: supernatural 30. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 180, regenerating 20 per hour. CONTROL RANGE: standard. EYES: see in any darkness including magical darkness, the invisible, Astral travelers and spirits, and all spectrums of light, and give a linked Controller hawk-like vision (a signpost two miles away). REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 3D6 M.D. per melee round, to full or 100 M.D.C., whichever is less; a Controller can focus it to regrow a wing armature, which needs at least half its M.D.C. to fly. DAMAGE NOTES: one destroyed leg reduces speed 15%, two 50%; the wing armatures are a called shot at -3, and losing one reduces all combat bonuses to zero and flying speed to 30%; the eyes are a called shot at -4 with no effect; destroying the head partially exposes the Controller and loses head weapons. ATTACKS: equal to the pilot''s; +1 when piloted by a Lord Magus or High Magus; a Controller adds +1 per two levels; +5 under a Lord of Magic. HAND TO HAND DAMAGE (the head and neck reach 10 feet in all directions): restrained punch or head jab 5D6+15 S.D.C., full strength punch or head jab 3D6 M.D., power punch or head jab 6D6 M.D. (counts as two attacks), kick 4D6 M.D., leap kick 6D6 M.D. (counts as two attacks), flying body slam/ram 3D6 M.D. per 100 mph of speed and knocks a human- to 12-foot target 1D6x10 yards, costing it initiative and 1D4 melee actions (counts as three actions), bite 3D6 M.D., stomp 1D4 M.D. BONUSES: Horror Factor 9; +3 on initiative, +5 to strike, +4 to parry, +4 to dodge on the ground, +6 to dodge in the air, critical strike on a natural 19-20, +2 to pull punch; cannot roll with impact or fall. The pilot''s hand to hand bonuses are not added unless he is a linked Controller, who adds +2 to each. Shares the common automaton features (printed 96-97).',
   'Rifts World Book 16: Federation of Magic p.106-108'),

  ('infiltrator-automaton', 'Infiltrator Automaton', 'rifts', 'robot',
   'None. THE INFILTRATOR IS NEVER RIDDEN: a bonded Controller Battle Magus directs it by remote control out to 500 feet (152 m), over double the usual range. Only the Controller O.C.C. and the Lords of Magic can use one.',
   'None.',
   'Running 50 mph (80 km), indefinitely without fatigue, though it stops when its Controller falls asleep. Leaping 10 feet (3 m) high and 15 feet (4.6 m) long, double from a running start. Climbing equal to the Climb skill at 95/85%.',
   'Not possible.',
   'The only automaton that swims: equal to the Swim skill at 80%. Can also walk the sea floor to a depth of 1000 feet (305 m).',
   'Height 6-8 feet (1.8 to 2.4 m). Width 3 feet (0.9 m) at the shoulders. Length (depth) 2 feet (0.6 m), a bit barrel-chested.',
   'One ton',
   220, NULL,
   'Completely unavailable. Would sell for millions if the buyer could activate and use it in any capacity; may sell as a work of art for several thousand credits.',
   'Magic Automaton, Dweomer City; sometimes confused with a robot or spirit. The only automaton that is not gigantic or built for the front line: a man-sized espionage construct of glass, crystal or ice, glass-like even when empowered, cool to the touch, with a human body and a completely blank face. It is mute. The Controller sends it to scout, spy, steal or strike by surprise, as a diversion or as a sidekick; everything it sees and hears reaches him at once, even if it is captured or destroyed. HOW IT IS OWNED: it is NOT RIDDEN and has no pilot area. It must be bonded to a Controller, who directs it remotely out to 500 feet; while it acts, the Controller''s own attacks per melee round are halved. BODY TYPE: glass, always an M.D.C. structure. P.S.: supernatural 38. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 120, regenerating 10 per hour. REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 3D6 M.D. per melee round, to full or 100 M.D.C., whichever is less. DAMAGE NOTES: a destroyed leg reduces speed 50%; the head is a called shot at -3, and destroying it halves the automaton''s attacks and combat bonuses until the regeneration regrows it, which takes twice as long and must restore 90% of the head''s M.D.C. (54 points). ATTACKS: four, +2 when bonded to a Controller O.C.C.; +4 under a Lord of Magic. HAND TO HAND DAMAGE: restrained punch 5D6+13 S.D.C., full strength punch 3D6 M.D., power punch 6D6 M.D. (counts as two attacks), kick 4D6 M.D., body flip/throw 2D6 M.D. plus the opponent loses initiative and one attack. BONUSES: Horror Factor 10; +2 on initiative, +3 to strike, +3 to parry, +5 to dodge, critical strike on a natural 19-20, +6 to pull punch, +2 to roll with impact or fall, prowl 60%. The Controller''s hand to hand bonuses are not added unless he is linked, in which case +2 is added to each. Shares the common automaton features (printed 96-97); rumor has it one has walked the halls of Chi-Town.',
   'Rifts World Book 16: Federation of Magic p.108-110'),

  ('kilairgh-automaton', 'Kilairgh Automaton', 'rifts', 'robot',
   'One; typically an experienced High Magus Controller. Only a Controller, the High Magus who created it, or a Lord of Magic can pilot it.',
   'None.',
   'Running 80 mph (128.7 km); it scuttles like a centipede and closes on an opponent astonishingly fast. Leaping not possible. Climbing fair to poor on steep or sheer walls (50%), excellent over rugged terrain (98%).',
   'Not possible.',
   'Cannot swim, but can walk the sea floor; depth tolerance one mile, though the pilot could not withstand it without protection.',
   'Height about 12 feet (3.6 m) crawling prone, 20-30 feet (6 to 9 m) when it rears up. Width 15-20 feet (4.6 to 6 m) at the shoulders. Length 60-70 feet (18.3 to 21.3 m) from head to tail.',
   '180 tons',
   1600, NULL,
   'Completely unavailable. Would sell for hundreds of millions if the buyer could activate and use it; stealing one is virtually impossible.',
   'Magic Automaton, Dweomer City; sometimes called the Crawling Colossus. Named (pronounced kill-lair) for a supernatural predator the Lords of Magic remember fondly: a man-insect with a vaguely human upper torso, two massive arms ending in pincer claws, and a long segmented body on six short legs. It rears up on four hind legs in combat, bellows, and pounds, swats and snips. A close-combat specialist, used by the Lords of Magic against demon hordes and armies for centuries, and vulnerable to fliers that stay out of its reach. It only bellows. PILOT AREA: where the head should be, a compartment with defensive walls and a high-backed chair. BODY TYPE: metal or stone. P.S.: supernatural 55. POWER: magic, unlimited lifetime on a high-magic world. P.P.E. BATTERY: 400, regenerating about 1D4x10 per hour. CONTROL RANGE: standard (the pilot can control it from up to 200 feet). REGENERATION: while it has 2 M.D.C., 20 P.P.E. from its Controller regenerates it at 1D6x10 M.D. per melee round, to full or 200 M.D.C., whichever is less. DAMAGE NOTES: one destroyed leg has no effect, two reduce speed 15%, three or four 50%; it has no eyes and sees what its pilot sees; destroying the head/pilot area leaves the pilot to hang on or fall, and halves its initiative, parry and dodge bonuses. ATTACKS: the Controller''s attacks +1 per two levels of his experience; a Lord of Magic''s +5. HAND TO HAND DAMAGE: claw strikes as its pincer weapon entry; body slam 2D4x10 M.D. on everything in an area about 15 feet wide and 20-30 feet long, the pilot magically cushioned (counts as two attacks; a favorite); thrown giant objects (cars, boulders, trees) 1D6x10 M.D. to 1000 feet (305 m); prehensile tail 1D6x10 M.D.; stomp 4D6 M.D.; kicks not possible. BONUSES: Horror Factor 16; +3 on initiative (+4 with claws), +6 to strike, +6 to parry, +4 to dodge, +4 to pull punch, +3 to roll with impact or fall, critical strike on a natural 19-20. A Controller adds +2 to each. Shares the common automaton features (printed 96-97).',
   'Rifts World Book 16: Federation of Magic p.110-112'),

  ('tw-battle-skimmer', 'TW Battle Skimmer', 'rifts', 'vehicle',
   'One Techno-Wizard pilot and 4-6 gunners (any O.C.C.).',
   'Up to 30 passengers can be carried comfortably on the open deck.',
   'Not applicable: it always floats above the ground and cannot move off a ley line unless hauled.',
   'Floats and flies along a ley line at up to 200 mph (321.8 km), indefinitely, completely silent, at any height within the line from a few feet up to just above its top (a half mile to a mile, 0.8 to 1.6 km). It cannot move sideways across the line, and changes lines only where another intersects. If derailed it is helpless until hauled back to a line.',
   'Not applicable.',
   'Height 22 feet (6.7 m). Width: deck 20-30 feet (6 to 9 m); overall 80-90 feet (24.4 to 27.4 m) with the downward-pointing wings. Length: deck 60-70 feet (18.3 to 21.3 m); overall 80-90 feet (24.4 to 27.4 m).',
   '48 tons',
   1280, 8000000,
   '8-10 million credits (Stormspire). Stormspire has sold a fair number despite the high price and limited abilities.',
   'Model Type: Ley Line Skimmer, also known as a TW Battle Barge. Class: combat barge and patrol vehicle; light transport. A Stormspire design: little more than a floating firing platform shaped like a huge manta ray, its "wings" draped over the ley line it rides so it arches over the line to tap its P.P.E. The flat top is an open platform with only a railing between the crew and a fall. The typical fit is 4-6 Starfire Pulse Cannons, one at each corner and sometimes two more in the middle or on the bridge, and the line powers a constantly regenerating energy field. A potent war machine with poor maneuverability; the Magic Zone is crisscrossed with ley lines, which is why it sells. PILOTING SKILL: Techno-Wizards and aircraft pilots 55% +5% per level; any other O.C.C. 30% +3% per level. CARGO: as much as the occupants pile on top, up to 350 tons. POWER: magic / ley lines. CONTROLS: a throttle, brake and directional control only; no computers, sensors or radio unless the owner adds them at extra cost. DAMAGE NOTES: a single asterisk marks a small or difficult target, a called shot at -2; the deck can only be attacked from above; depleting the main body destroys it and it crashes to the ground. ADDITIONS: other TW or conventional weapons may be added at the owner''s expense, each needing its own gunner, and 6-12 Wing Boards or other small fliers are likely carried for dogfights and scouting, along with rope ladders and spotlights. THE BOOK DISAGREES WITH ITSELF on the cannon count: the M.D.C. table prints Starfire Cannons (4-6) and the weapon entry prints four.',
   'Rifts World Book 16: Federation of Magic p.120-121'),

  ('tw-ley-streaker', 'TW Ley Streaker', 'rifts', 'vehicle',
   'One pilot.',
   'Four passengers ride comfortably in the cockpit with the pilot; six cramped.',
   'Not applicable: a floating skimmer.',
   'Up to 600 mph (960 km) on a ley line, where it can also float, glide and hover. Away from a ley line about 60 mph (96.5 km), best altitude 300 feet (91 m), for four hours before its energy runs out. Completely silent.',
   'Not applicable.',
   'Height 10 feet (3 m). Width: wingspan 50 feet (15.2 m); cockpit 12 feet (3.6 m). Length 50-60 feet (15.2 to 18.3 m).',
   '6 tons',
   220, 5000000,
   '5-6 million credits (Stormspire). A combat version, the Battle Streaker, costs 8 million; it is its own row.',
   'Model Type: Ley Line Skimmer. Class: scout. An UNARMED Stormspire ley line skimmer built for speed, with an enclosed cockpit at the front and a long, sleek, flat, slightly curved body that hugs the surface of a ley line through dives, sharp turns and dogfight maneuvers; a fast scout and light transport. It looks surprisingly high-tech but has no computers or onboard sensors unless added. PILOTING SKILL: Techno-Wizards and aircraft pilots 50% +5% per level; any other O.C.C. 27% +3% per level. CARGO: minimal; a locker 2 feet deep, 4 feet wide and 3 feet tall in the cockpit. POWER: magic, running on ley line energy; four hours away from a line. CONTROLS: a steering wheel, throttle, brake and directional control. WEAPONS: none. ADDITIONS: TW or conventional equipment such as computers, radar, sensors and radio at the owner''s expense. MAIN BODY: the book files the two wings as the main body, 220 M.D.C. each; the figure stored as main body is one wing''s. DAMAGE NOTES: destroying the forward section crashes the vehicle if moving and blows everyone in the cockpit into the sky; destroying the neck cuts it in half, both halves spiralling gently to the ground with every system shut down; destroying one wing''s rear section knocks out propulsion and it crashes.',
   'Rifts World Book 16: Federation of Magic p.122'),

  ('tw-battle-streaker', 'TW Battle Streaker', 'rifts', 'vehicle',
   'One pilot.',
   'Four passengers ride comfortably in the cockpit with the pilot; six cramped.',
   'Not applicable: a floating skimmer.',
   'Up to 600 mph (960 km) on a ley line, where it can also float, glide and hover. Away from a ley line about 60 mph (96.5 km), best altitude 300 feet (91 m), for four hours before its energy runs out. Completely silent.',
   'Not applicable.',
   'Height 10 feet (3 m). Width: wingspan 50 feet (15.2 m); cockpit 12 feet (3.6 m). Length 50-60 feet (15.2 to 18.3 m).',
   '6 tons',
   220, 8000000,
   '8 million credits (Stormspire), against the unarmed Ley Streaker''s 5-6 million.',
   'The combat version of the TW Ley Streaker, priced separately in the Streaker''s own cost line (printed 122): it fires electrical blasts and carries either a rack of six conventional mini-missiles or a double-barrelled laser turret. The book says all its other stats are the same as the Ley Streaker''s, so that stat block is repeated here: Model Type Ley Line Skimmer; an enclosed cockpit at the front and a long, flat, slightly curved body that hugs a ley line. PILOTING SKILL: Techno-Wizards and aircraft pilots 50% +5% per level; any other O.C.C. 27% +3% per level. CARGO: a locker 2 feet deep, 4 feet wide and 3 feet tall in the cockpit. POWER: magic, running on ley line energy; four hours away from a line. CONTROLS: a steering wheel, throttle, brake and directional control. MAIN BODY: the two wings, 220 M.D.C. each; the figure stored as main body is one wing''s. DAMAGE NOTES: as the Ley Streaker - losing the forward section crashes it and throws the cockpit''s occupants out, losing the neck cuts it in half to settle gently to the ground powerless, losing a wing''s rear section crashes it. The book prints no M.D.C. for the added weapons. STORED AS ITS OWN ROW (2026-09-26, fom survey PR C) because it has its own price and its own weapons.',
   'Rifts World Book 16: Federation of Magic p.122'),

  ('tw-zone-ranger-atv', 'TW Zone Ranger ATV', 'rifts', 'vehicle',
   'One pilot.',
   'Up to six passengers.',
   '120 mph (192 km) maximum; 50% faster when driving on a ley line.',
   'Not possible without the Sky Rider feature (100 feet up at 30 mph).',
   'Not possible without the Float on Water feature (35 mph on the surface).',
   'Height 14 feet (4.3 m). Width 16 feet (4.9 m). Length 25 feet (7.6 m).',
   '10 tons',
   350, 1500000,
   '1.5 to 2 million credits for the basic vehicle without special features or weapons. Each of the six TW features is extra (see its weapon entries): float on water 400,000, total chameleon 600,000, sky rider 700,000, shoot fire ball 500,000, call lightning 750,000, and a mounted weapon at that weapon''s price plus a 75,000 credit integration fee.',
   'Model Type: four-wheeled all terrain vehicle. A sturdy, P.P.E.-driven, land-rover-style Stormspire ground vehicle built for the hostile Magic Zone: durable, reasonably fast and surprisingly spacious, a quick favorite with those who can afford it, though like most TW vehicles it is expensive and hard to find. The basic model has NO BUILT-IN WEAPONS but a top hatch for mounting one. PILOTING SKILL: Techno-Wizards, Controllers and APC pilots 70% +3% per level; any other character 60% +3% per level. CARGO: a small 5 x 5 x 5 foot cargo area. POWER: magic; the engine burns 30 P.P.E. per hour of use and holds up to 300. Anyone can add P.P.E. by touching it and willing their energy in, and parked on a ley line it regenerates 40 P.P.E. per hour; it is sold fully charged. CONTROLS: a steering wheel, a "go" pedal (it uses no gasoline) and a brake. Magically resistant to heat and fire, which do half damage. DAMAGE NOTES: depleting the main body destroys the vehicle; one destroyed wheel reduces speed 33%, two 80%, three immobilize it. TW WEAPONS AND SPECIAL FEATURES: six options, each bought separately, stored as its numbered weapon entries rather than as gear (2026-09-26, fom survey PR C). A Zone Ranger with all of them is a "Super-Ranger"; with a few, a "Boosted Ranger". Other conventional equipment such as computers, radar, sensors and radio may be added at the owner''s expense.',
   'Rifts World Book 16: Federation of Magic p.122-124'),

  ('tw-trailblazer-assault-atv', 'TW Trailblazer Assault ATV', 'rifts', 'vehicle',
   'Four: one pilot and three gunners.',
   'None; there is no space for passengers.',
   '100 mph (160 km) maximum ground speed; 50% faster when driving on a ley line.',
   'Not possible.',
   'Not possible.',
   'Height 12 feet (3.6 m). Width 15 feet (4.6 m). Length 22 feet 6 inches (6.7 m).',
   '11 tons',
   475, 7000000,
   '7-8 million credits for the basic combat vehicle. The Zone Ranger''s TW features can be added, each at extra cost.',
   'Model Type: four-wheeled all terrain vehicle. Class: light assault vehicle. Stormspire''s compromise between an ATV and a tank: a heavy ATV with extra armor and built-in weapons, less firepower than a tank but faster and more mobile - an excellent raider and skirmisher, snapped up by mercenaries and Tolkeen forces despite the price. PILOTING SKILL: Techno-Wizards, Controllers and APC pilots 66% +3% per level; any other character 54% +3% per level. CARGO: a small weapons locker holding four suits of armor and four rifles. POWER: magic; 30 P.P.E. per hour of use, the engine holding 600. Anyone can replenish it, and parked on a ley line it regenerates 40 P.P.E. per hour; sold fully charged. SENSORS: the standard sensors of most vehicles, including radar. MAGICAL FORCE FIELD: in desperate situations a force field of 100 M.D.C. can be raised, but no weapon can fire from the vehicle while it is up. Magically resistant to heat and fire, which do half damage. DAMAGE NOTES: depleting the main body destroys the vehicle; one destroyed wheel reduces speed 33%, two 80%, three immobilize it. TW WEAPONS AND SPECIAL FEATURES: the same six options as the Zone Ranger, each costing extra; they are stored once, on the Zone Ranger''s row. THE BOOK DISAGREES WITH ITSELF on the Starfire Pulse Cannon''s range: 4500 feet here, 2000 feet on the Battle Skimmer.',
   'Rifts World Book 16: Federation of Magic p.124-125');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('battlelord-automaton', 'Hands (2)',          120, 'Each.', 1),
  ('battlelord-automaton', 'Arms (2)',           300, 'Each.', 2),
  ('battlelord-automaton', 'Legs (2)',           320, 'Each. Destroying an entire leg reduces speed by 50%.', 3),
  ('battlelord-automaton', 'Feet (2)',           150, 'Each. Destroying a foot reduces speed by 15%.', 4),
  ('battlelord-automaton', 'Mystic Sword',       200, 'Damaged only by an attack deliberately aimed at it; regenerates as part of the automaton.', 5),
  ('battlelord-automaton', 'Shoulder Plates (2)', 150, 'Each.', 6),
  ('battlelord-automaton', 'Main Body',         1000, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 5D6 M.D. per melee round, to full or 100, whichever is less.', 7),
  ('battlelord-automaton', 'Head',               360, 'Destroying it exposes the Controller seated in the crown; it fights on through his eyes but loses any head weapons.', 8),
  ('battlelord-automaton', 'Eyes (2)',           100, 'Each. A called shot at -4; shooting them out has no effect.', 9),

  ('colossus-automaton', 'Hand (1; left)',         500, NULL, 1),
  ('colossus-automaton', 'Mace Hand (1; right)',   600, NULL, 2),
  ('colossus-automaton', 'Lower Arms (2)',         400, 'Each.', 3),
  ('colossus-automaton', 'Upper Arms (2)',         500, 'Each.', 4),
  ('colossus-automaton', 'Shoulder Plates (2)',    200, 'Each.', 5),
  ('colossus-automaton', 'Feet (2)',               400, 'Each. Destroying a foot reduces speed by 15%.', 6),
  ('colossus-automaton', 'Lower Legs (2)',         550, 'Each. Destroying an entire leg reduces speed by 50%.', 7),
  ('colossus-automaton', 'Upper Legs (2)',         800, 'Each. Destroying an entire leg reduces speed by 50%.', 8),
  ('colossus-automaton', 'Main Body',             2000, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 1D6x10 M.D. per melee round, to full or 200, whichever is less.', 9),
  ('colossus-automaton', 'Head',                  1000, 'Destroying it exposes the pilot in the bowl of the ram''s horns; it fights on through his eyes but loses any head weapons.', 10),
  ('colossus-automaton', 'Eyes (2)',               200, 'Each. A called shot at -4; shooting them out has no effect.', 11),

  ('earth-thunder-automaton', 'Hands (2)',     75, 'Each.', 1),
  ('earth-thunder-automaton', 'Arms (2)',     140, 'Each.', 2),
  ('earth-thunder-automaton', 'Legs (2)',     200, 'Each. Destroying an entire leg reduces speed by 50%.', 3),
  ('earth-thunder-automaton', 'Feet (2)',     100, 'Each. Destroying a foot reduces speed by 15%.', 4),
  ('earth-thunder-automaton', 'Mystic Sword', 200, 'Damaged only by an attack deliberately aimed at it; regenerates as part of the automaton.', 5),
  ('earth-thunder-automaton', 'Main Body',    500, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 3D6 M.D. per melee round, to full or 100, whichever is less.', 6),
  ('earth-thunder-automaton', 'Head',         120, 'Destroying it partially exposes the Controller seated between the shoulders; it fights on through his eyes but loses any head weapons.', 7),
  ('earth-thunder-automaton', 'Eyes (2)',     100, 'Each. A called shot at -4; shooting them has no effect.', 8),

  ('fire-demon-automaton', 'Hands (2)',                         60, 'Each.', 1),
  ('fire-demon-automaton', 'Arms (2)',                         140, 'Each.', 2),
  ('fire-demon-automaton', 'Legs (2)',                         180, 'Each. Destroying an entire leg reduces speed by 50%.', 3),
  ('fire-demon-automaton', 'Feet (2)',                         120, 'Each. Destroying a foot reduces speed by 15%.', 4),
  ('fire-demon-automaton', 'Tail',                             100, 'Prehensile; destroying it costs one melee attack.', 5),
  ('fire-demon-automaton', 'Smoking Horn Smoke Stacks (2)',     90, 'Each. Destroying the horns pours smoke from the head and halves initiative.', 6),
  ('fire-demon-automaton', 'Main Body',                        500, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 5D6 M.D. per melee round, to full or 100, whichever is less.', 7),
  ('fire-demon-automaton', 'Head',                             200, 'Destroying it exposes the Controller seated in the crown; it fights on through his eyes but loses any head weapons.', 8),
  ('fire-demon-automaton', 'Eyes (2)',                         100, 'Each. A called shot at -4; shooting them out has no effect.', 9),

  ('ice-drake-automaton', 'Front Legs (2)',     100, 'Each. One destroyed leg reduces speed by 15%, two by 50%.', 1),
  ('ice-drake-automaton', 'Hind Legs (2)',      140, 'Each. One destroyed leg reduces speed by 15%, two by 50%.', 2),
  ('ice-drake-automaton', 'Tail (1)',            60, NULL, 3),
  ('ice-drake-automaton', 'Wing Armatures (2)',  90, 'Each. A called shot at -3. Losing one reduces all combat bonuses to zero and flying speed to 30%; a Controller can regrow it, and it needs half its M.D.C. to fly.', 4),
  ('ice-drake-automaton', 'Neck',               160, NULL, 5),
  ('ice-drake-automaton', 'Main Body',          300, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 3D6 M.D. per melee round, to full or 100, whichever is less.', 6),
  ('ice-drake-automaton', 'Head',               100, 'Destroying it partially exposes the Controller seated behind the neck; it fights on through his eyes but loses any head weapons.', 7),
  ('ice-drake-automaton', 'Eyes (2)',           100, 'Each. A called shot at -4; shooting them has no effect.', 8),

  ('infiltrator-automaton', 'Hands (2)',  20, 'Each.', 1),
  ('infiltrator-automaton', 'Arms (2)',   60, 'Each.', 2),
  ('infiltrator-automaton', 'Legs (2)',  110, 'Each. Destroying a leg reduces speed by 50%.', 3),
  ('infiltrator-automaton', 'Main Body', 220, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 3D6 M.D. per melee round, to full or 100, whichever is less.', 4),
  ('infiltrator-automaton', 'Head',       60, 'A called shot at -3. Destroying it halves attacks and combat bonuses until regrown, which takes twice as long and must restore 90% (54 points).', 5),

  ('kilairgh-automaton', 'Pincer Claws (2)',               500, 'Each.', 1),
  ('kilairgh-automaton', 'Arms (2)',                       600, 'Each.', 2),
  ('kilairgh-automaton', 'Legs (6)',                       160, 'Each. One destroyed leg has no effect; two reduce speed by 15%; three or four by 50%.', 3),
  ('kilairgh-automaton', 'Thick Clubbing Tail Section',    500, NULL, 4),
  ('kilairgh-automaton', 'Main Body',                     1600, 'Destroying it collapses the automaton; while it has 2 M.D.C. a Controller spending 20 P.P.E. regenerates it at 1D6x10 M.D. per melee round, to full or 200, whichever is less.', 5),
  ('kilairgh-automaton', 'Head/Pilot Area',                500, 'Destroying it leaves the pilot to hang on or fall, and halves initiative, parry and dodge bonuses.', 6),

  ('tw-battle-skimmer', 'Side Fins/Wings (2; large)', 450, 'Each.', 1),
  ('tw-battle-skimmer', 'Starfire Cannons (4-6)',     100, 'Each. A small target: called shot at -2.', 2),
  ('tw-battle-skimmer', 'Bridge Platform',            300, NULL, 3),
  ('tw-battle-skimmer', 'Bridge Stairs (2)',          100, 'Each. A small target: called shot at -2.', 4),
  ('tw-battle-skimmer', 'Railing',                     50, 'Per 10 foot (3 m) section. A small target: called shot at -2.', 5),
  ('tw-battle-skimmer', 'Deck',                       200, 'Per 20 feet (6 m). The deck can only be attacked from above.', 6),
  ('tw-battle-skimmer', 'Main Body',                 1280, 'Depleting it destroys the vehicle, which crashes to the ground.', 7),

  ('tw-ley-streaker', 'Forward Section/Cockpit', 150, 'A small target. Destroying it crashes the vehicle if moving and blows everybody in the cockpit into the sky.', 1),
  ('tw-ley-streaker', 'Neck',                    120, 'Destroying it cuts the vehicle in half; both pieces spiral gently to the ground with every system shut down.', 2),
  ('tw-ley-streaker', 'Wings (2; main body)',    220, 'Each. The book files the wings as the main body. Destroying one wing''s rear section knocks out propulsion and it crashes.', 3),

  ('tw-battle-streaker', 'Forward Section/Cockpit', 150, 'As the Ley Streaker. A small target. Destroying it crashes the vehicle if moving and blows everybody in the cockpit into the sky.', 1),
  ('tw-battle-streaker', 'Neck',                    120, 'As the Ley Streaker. Destroying it cuts the vehicle in half; both pieces spiral gently to the ground with every system shut down.', 2),
  ('tw-battle-streaker', 'Wings (2; main body)',    220, 'Each. As the Ley Streaker; the book files the wings as the main body. Destroying one wing''s rear section knocks out propulsion and it crashes.', 3),

  ('tw-zone-ranger-atv', 'Tires (4)',  100, 'Each. One destroyed wheel reduces speed by 33%, two by 80%; three immobilize the vehicle.', 1),
  ('tw-zone-ranger-atv', 'Top Hatch',   75, NULL, 2),
  ('tw-zone-ranger-atv', 'Main Body',  350, 'Depleting it completely destroys the vehicle.', 3),

  ('tw-trailblazer-assault-atv', 'Tires (4)',                            100, 'Each. One destroyed wheel reduces speed by 33%, two by 80%; three immobilize the vehicle.', 1),
  ('tw-trailblazer-assault-atv', 'Forward Hatch',                         80, NULL, 2),
  ('tw-trailblazer-assault-atv', 'Rear Hatch',                            80, NULL, 3),
  ('tw-trailblazer-assault-atv', 'Starfire Pulse Cannon',                100, NULL, 4),
  ('tw-trailblazer-assault-atv', 'Nova Rifle',                            50, NULL, 5),
  ('tw-trailblazer-assault-atv', 'Mini-Missile Launcher (conventional)',  50, NULL, 6),
  ('tw-trailblazer-assault-atv', 'Magical Force Field',                  100, 'No weapon can fire from the vehicle while it is up.', 7),
  ('tw-trailblazer-assault-atv', 'Main Body',                            475, 'Depleting it completely destroys the vehicle.', 8);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('battlelord-automaton', 1, 'Two-Handed Sword',
   '1D6x10 M.D. per strike of the blade. Lightning bolts: 2D6 M.D. per level of the Controller or pilot.', 1,
   'Sword reach about 24 feet (7.3 m). Lightning 1000 feet for ordinary pilots; 1000 feet (305 m) +200 feet (61 m) per level of a Controller or Lord of Magic.',
   'Equal to the number of hand to hand attacks; each lightning blast counts as one melee action.',
   'Effectively unlimited; the lightning draws on neither the battery nor the pilot.',
   'Lightning +3 to strike.',
   'A 12-18 foot (3.6 to 5.4 m) magic sword weighing half a ton, carried always, never thrown or left behind. Full damage to creatures of magic, supernatural beings and magic armor. It releases lightning like a Call Lightning spell when pointed at a line-of-sight target. Primary purpose anti-robot and anti-dragon; secondary defense.'),
  ('battlelord-automaton', 2, 'Eye Beams',
   '3D6 M.D. per single blast, or 6D6 M.D. per simultaneous dual blast at one target.', 1,
   '1000 feet (305 m)', 'Each blast counts as one melee attack.',
   'Effectively unlimited; does not draw on the P.P.E. battery.', '+2 to strike.',
   'The eyes see the invisible and fire bolts of magic energy at anything in line of sight. Primary purpose anti-robot and anti-personnel; secondary anti-aircraft and anti-missile.'),
  ('battlelord-automaton', 3, 'Magic Spell Casting',
   'By spell. Magic Shield (6), Magic Net (7), Deflect (10), Watchguard (10), Implosion Neutralizer (12), Barrage (15), Call Lightning (15), Lifeblast (15), Targeted Deflection (15), Magic Pigeon (20), Sheltering Force (20), Dessicate the Supernatural (50).', 0,
   'By spell.', 'At most two spells per melee round, at the Controller''s level.',
   'The battery''s 200 P.P.E., regenerating 20 per hour, and/or the Controller''s own P.P.E.', NULL,
   'Only a Controller Magus, High Magus or Lord of Magic can make it cast spells. The book spells Dessicate this way here.'),

  ('colossus-automaton', 1, 'Iron Mace',
   '+1D4x10 M.D. added to punch damage with every crushing blow, and double damage to supernatural beings and creatures of magic.', 1,
   'Reach about 35 feet (10.6 m).', 'Equal to the hand to hand attacks of the automaton.', 'Not applicable.', NULL,
   'The massive spiked mace that serves as its right hand; it fires nothing. Against targets 10 feet (3 m) tall or less it damages everything in a 10 foot (3 m) area. Primary purpose close assault; secondary anti-armor and defense.'),
  ('colossus-automaton', 2, 'Earth Tremors',
   '4D6 M.D. to everything in the area, and a knockdown roll by weight: under 500 lbs 01-88% (loses initiative and two melee actions), 500-1000 lbs 01-65%, up to one ton 01-40%, over a ton 01-25%. Fliers are unaffected. Buildings take double damage and those inside lose another melee action.', 1,
   '100 feet (30.5 m) directly in front of it, in a 20 foot (6 m) wide swath.', 'Up to once per melee round; counts as one of its attacks.',
   'Effectively unlimited; requires no P.P.E.', NULL,
   'A deliberate stomp releases a shockwave lasting about five seconds. Primary purpose anti-infantry; secondary against structures and buildings.'),
  ('colossus-automaton', 3, 'Mystic Eye Blasts',
   '6D6 M.D. per single blast, or 1D6x10+12 M.D. per simultaneous dual blast at one target.', 1,
   '3000 feet (910 m)', 'Each blast counts as one melee attack.',
   'Effectively unlimited; does not draw on the P.P.E. battery.', '+3 to strike.',
   'The eyes are telescopic and see the invisible. Primary purpose anti-robot and armor; secondary defense.'),
  ('colossus-automaton', 4, 'Magic Spell Casting',
   'By spell. Deflect (10), Distant Voice (10), Death Curse (special), Weight of Duty (10), Lifeblast (15), Wind Rush (20), Sub-particle Acceleration (20), Wall of Wind (40), World Bizarre (40), Meteor (75), Collapse (70-400), Disharmonize (150), Firequake (160), Heavy Air (200), Annihilate (600).', 0,
   'By spell.', 'At most two spells per melee round.',
   'The battery''s 1200 P.P.E., regenerating 2D6x10 per hour, and/or the pilot''s own P.P.E.', NULL,
   'Only a High Magus or Lord of Magic can make it cast spells. The last two entries on the list wrap to the head of the next column on printed 101.'),

  ('earth-thunder-automaton', 1, 'Single-edged Sword',
   '1D4x10 M.D. per strike of the blade.', 1,
   'Reach approximately 12 feet (3.6 m).', 'Not applicable.', 'Not applicable.', NULL,
   'A huge hooked sword, 6-7 feet (1.8 to 2.1 m) long and 500 pounds (226 kg), usually clutched in one hand. A magic weapon: full damage to creatures of magic, supernatural beings and magic armor. It may be thrown or magically manipulated but is never left behind, and is damaged only by an attack aimed at it. Primary purpose anti-robot and anti-dragon; secondary defense.'),
  ('earth-thunder-automaton', 3, 'Magic Spell Casting',
   'By spell. See Aura (6), Chameleon (6; conceals automaton and rider), Detect Concealment (6), Throwing Stones (5), Mystic Fulcrum (5), Fireblast (8), Deflect (10), Crushing Fist (12), Power Bolt (20), Spinning Blades (20; can be applied to its giant sword), Wall of Defense (55).', 0,
   'By spell.', 'At most two spells per melee round.',
   'The battery (100 P.P.E. regenerating 10 per hour by its stat block; the spell paragraph says 120 regenerating 20) and/or the Controller''s own P.P.E.', NULL,
   'Only a Controller Magus, High Magus or the Lords of Magic can make it cast spells. The book''s item 2 is its eyes, a sense rather than a weapon, and is in the description.'),

  ('fire-demon-automaton', 1, 'Burning Hot Body',
   'Touch 1D4 M.D.; grabbing, holding or grappling it 2D6 M.D. per five seconds of contact; +1D6 M.D. to every blow with the upper body.', 1,
   'Touch; reach about 10 feet (3 m).', NULL, 'Always hot, even when inactive.', NULL,
   'Always red and orange hot, with heat vapors and flame from the head, shoulders and upper torso; the heat keeps most people without environmental or M.D. armor 10-15 feet away and ignites combustibles. The feet, lower legs, tail and the pilot''s seat are not hot. Primary purpose self-defense.'),
  ('fire-demon-automaton', 2, 'Flaming Hands',
   '+1D6 M.D. to punches and claw strikes, on top of the body''s +1D6.', 1,
   'Touch; reach about 10 feet (3 m).', 'Igniting them is a thought and not a melee action.', 'Effectively unlimited.', NULL,
   'Hands and forearms burst into flame at will without spending P.P.E. Primary purpose combat.'),
  ('fire-demon-automaton', 3, 'Breathe Fire',
   '6D6 M.D. per blast. The sulfur cloud leaves those without environmental helmets or filters and goggles -3 on initiative, -1 to strike and parry and one attack down per round; it lingers 1D4 minutes.', 1,
   '100 feet (30.5 m)', 'Each blast counts as one of its melee attacks.', 'Effectively unlimited; does not draw on the battery.', NULL,
   'A blast of fire and a billowing sulfuric cloud from the mouth. Primary purpose anti-infantry; secondary setting buildings and combustibles alight.'),
  ('fire-demon-automaton', 4, 'Fire Tremor',
   '4D6 M.D. to everything it touches; combustibles have a 01-55% chance of catching fire.', 1,
   '100 feet (30.5 m)', 'Once per melee round; counts as one of its melee attacks.', 'Effectively unlimited.', NULL,
   'A stomp sends a stream of fire three feet wide, two feet tall and up to 100 feet long across the ground; it vanishes in 10 seconds. Primary purpose anti-infantry; secondary general assault.'),
  ('fire-demon-automaton', 5, 'Magic Spell Casting',
   'By spell. Lantern Light (1), Fuel Flame (5), Ignite Flame (6), Fireblast (8), Fire Ball (10), Circle of Flame (10), Fire Blossom (20), Fire Gout (20), Fire Globe (40), Dragon Fire (40).', 0,
   'By spell.', 'At most two spells per melee round.',
   'The battery''s 280 P.P.E., regenerating 30 per hour, and/or the Controller''s own P.P.E.', NULL,
   'Only a Controller Magus, High Magus or Lord of Magic can make it cast spells.'),

  ('ice-drake-automaton', 1, 'Burning Cold Body',
   '1D6 S.D.C. per five seconds of contact to anyone who grabs, holds or grapples it.', 0,
   'Touch; reach about 10 feet (3 m).', NULL, 'Always cold, even when inactive.', NULL,
   'Touching it is like touching a block of ice; the pilot''s seat is not cold. Primary purpose self-defense.'),
  ('ice-drake-automaton', 2, 'Frost Blasts',
   '2D6 M.D., plus: frost blinds windows and visors until defrosted (1D4+1 minutes) or scraped (2D4 melee actions); armor, borg and man-sized robot joints stiffen, -20% speed for 1D4+1 melee rounds; aircraft, power armor, giant robots and vehicles lose 10% speed and -15% piloting for 1D4+1 melees; hit-point beings in non-environmental armor save vs numbing cold at 16 or take 3D6 S.D.C./Hit Points and lose initiative and two actions; mega-damage beings save at 11 or take 1D4 M.D. and lose one action.', 1,
   '400 feet (122 m); line of sight.', 'Each breath counts as one hand to hand attack; at most twice per round.', 'Effectively unlimited.', '+3 to strike.',
   'Breathed blasts of mega-damage cold, aimed at windshields, wing flaps, wings and intakes to impair flight. Primary purpose anti-aircraft; secondary anti-infantry.'),
  ('ice-drake-automaton', 4, 'Magic Spell Casting',
   'By spell. Energy Bolt (5), Float in Air (5), Chameleon (6; conceals automaton and rider), Orb of Cold (6), Wave of Frost (6), Frost Blade (15; a long horn-like blade on its nose or forehead), Ice (15), Sub-Particle Acceleration (30, but at double the normal range), Wind Rush (20), Dispel Magic Barrier (20).', 0,
   'By spell.', 'At most two spells per melee round.',
   'The battery''s 180 P.P.E., regenerating 20 per hour, and/or the Controller''s own P.P.E.', NULL,
   'Only a Controller Magus, High Magus or the Lords of Magic can make it cast spells. The book''s item 3 is its eyes, a sense rather than a weapon, and is in the description.'),

  ('infiltrator-automaton', 1, 'Weapons & Guns',
   'By the weapon used.', 0, NULL, NULL, NULL, NULL,
   'It can use any type of weapon familiar to its Controller, from sword to laser rifle.'),
  ('infiltrator-automaton', 2, 'Momentary Intangibility',
   'None; a movement power.', 0, 'Self.', 'Counts as one melee action.', '10 P.P.E. per use.', NULL,
   'It becomes intangible for about 2-3 seconds to pass through walls or floors like a ghost.'),
  ('infiltrator-automaton', 3, 'Magic Spell Casting',
   'By spell. Chameleon (6), Concealment (6), Detect Concealment (6), Reflection (7), Electric Arc (8), Shadow Meld (10), Deflect (10), Ricochet Strike (12), House of Glass (12), Frequency Jamming (15), Mask of Deceit (15), Negate Mechanics (20), Phantom Mount (45), Mystic Portal (60).', 0,
   'By spell.', 'Up to two spells per melee round.',
   'The battery''s 120 P.P.E., regenerating 10 per hour, and/or the Controller''s own P.P.E.', NULL,
   'Only a Controller Magus or the Lords of Magic can make it cast spells.'),

  ('kilairgh-automaton', 1, 'Pincer Claws (2)',
   'Restrained punch 1D6 M.D.; punch/blunt strike 1D6x10 M.D.; power punch 2D6x10 M.D. (counts as two attacks); cutting snip 1D4x10+10 M.D.; clamp and tear 1D4x10 M.D.; crush 1D6x10 M.D. per squeeze (one melee attack). Prying a held victim loose needs a supernatural P.S. of 60.', 1,
   'Reach about 20 feet (6 m).', 'Equal to the hand to hand attacks of the automaton.', 'Not applicable.', NULL,
   'Massive razor-sharp pincers that can snip a man in two, hammer robots or tear apart mechanical limbs. Primary purpose close assault; secondary anti-armor and defense.'),
  ('kilairgh-automaton', 2, 'Magic Spell Casting',
   'By spell. Orb of Cold (6; quadruple normal range), Electric Arc (8), Deflect (10), Horror (10), House of Glass (12), Lifeblast (15), Barrage (15), Wind Rush (20), Sub-particle Acceleration (20), Ballistic Fire (25), Shockwave (35), Desiccate the Supernatural (50), Disharmonize (150).', 0,
   'By spell.', 'At most two spells per melee round.',
   'The battery''s 400 P.P.E., regenerating 1D4x10 per hour, and/or the pilot''s own P.P.E.', NULL,
   'Only a Controller, the High Magus who created it or a Lord of Magic can make it cast spells.'),

  ('tw-battle-skimmer', 1, 'Starfire Pulse Cannons (4)',
   '2D6x10 M.D.', 1, '2000 feet (610 m)', 'Single shots only.',
   'Two shots per P.P.E. clip, eight clips fitted in the top of each cannon: 16 shots. It comes with 2 extra sets of clips per weapon.', '+1 to strike.',
   'Four cannons pre-installed and linked to the generators that tap the ley line, modified to accept its energy so they need no energy cell; ammunition is the only limit. The M.D.C. table prints 4-6. Primary purpose assault; secondary defense.'),

  ('tw-battle-streaker', 1, 'Electrical Blasts',
   '1D4x10 M.D.', 1, '2000 feet (610 m)', NULL, NULL, NULL,
   'The Battle Streaker''s own weapon; printed in the Ley Streaker''s cost line, which gives no rate of fire or payload.'),
  ('tw-battle-streaker', 2, 'Mini-Missile Rack or Laser Turret',
   'Six conventional mini-missiles (damage by missile type), OR a double-barrelled laser turret at 4D6 M.D. per dual blast.', 1,
   'Laser turret 2000 feet (610 m).', NULL, 'Six mini-missiles in the rack.', NULL,
   'One or the other, per the book: a rack of six conventional mini-missiles or a double-barrelled laser turret.'),

  ('tw-zone-ranger-atv', 1, 'Float on Water',
   NULL, 0, NULL, NULL, NULL, NULL,
   'A special feature, bought separately: 400,000 credits. The vehicle rides on the surface of water at up to 35 mph (56 km).'),
  ('tw-zone-ranger-atv', 2, 'Total Chameleon',
   NULL, 0, NULL, NULL, '10 P.P.E. to activate.', NULL,
   'A special feature, bought separately: 600,000 credits. The whole vehicle and everyone in it blend into the landscape, effectively invisible and with no heat signature, but only at a complete stop with the engine off. Duration as the Chameleon spell at 5th level.'),
  ('tw-zone-ranger-atv', 3, 'Sky Rider',
   NULL, 0, NULL, NULL, '20 P.P.E. to activate; lasts 1 hour.', NULL,
   'A special feature, bought separately: 700,000 credits. The vehicle rides into the air, to a maximum altitude of 100 feet (30.5 m) at up to 30 mph (48.2 km).'),
  ('tw-zone-ranger-atv', 4, 'Shoot Fire Ball',
   '5D6 M.D.', 1, '800 feet (244 m)', NULL, '10 P.P.E. per blast.', NULL,
   'A special feature, bought separately: 500,000 credits. A fire ball appears in front of the vehicle and flies at the forward-facing target the pilot indicates.'),
  ('tw-zone-ranger-atv', 5, 'Call Lightning',
   '5D6 M.D.', 1, '1200 feet (366 m); line of vision.', NULL, '15 P.P.E. per blast.', NULL,
   'A special feature, bought separately: 750,000 credits. Same as the 5th level spell, pilot controlled.'),
  ('tw-zone-ranger-atv', 6, 'Mounted Weapon System',
   'By the weapon fitted.', 1, NULL, NULL, NULL, NULL,
   'A special feature, bought separately: a Starfire Pulse Cannon or any conventional weapon system (laser cannon, rail gun, mini-missile), at that weapon''s price plus a 75,000 credit system integration fee. Mounted through the top hatch.'),

  ('tw-trailblazer-assault-atv', 1, 'Starfire Pulse Cannon',
   '2D6x10 M.D.', 1, '4500 feet', 'Equal to the hand to hand attacks of the gunner.',
   '16 shots total, 2 per energy clip; comes with 2 spare sets of clips.', '+1 to strike.',
   'The main gun, mounted like a machine-gun and fired by a gunner standing in the forward hatch. The Battle Skimmer''s cannon prints a 2000 foot range. Primary purpose assault; secondary anti-infantry.'),
  ('tw-trailblazer-assault-atv', 2, 'Nova Rifle',
   '1D4x10 M.D. to all targets in a 6 foot (1.8 m) radius.', 1, '1200 feet (366 m)', 'Single shots only.',
   '50 shots from the vehicle''s energy supply, regenerating 1D6 per hour or 10 per hour on a ley line; beyond 50 it needs a separate P.P.E. clip.', NULL,
   'Mounted by the rear hatch against infantry and incoming missiles; it cannot fire directly ahead, only behind and to both sides. Primary purpose anti-infantry; secondary defense.'),
  ('tw-trailblazer-assault-atv', 3, 'Mini-Missile Launcher',
   'Varies with the type of mini-missile.', 1, 'One mile (1.6 km)',
   'Singly or in volleys of 2, 4 or 8; each volley counts as one attack by the gunner.',
   'Eight in the launcher; the vehicle carries 32 more. Reloading takes one full minute with the launcher retracted.', NULL,
   'A conventional, high-tech box launcher on the right side, fired and reloaded by the third gunner; fires straight ahead or up and down through a 90 degree arc. Primary purpose assault; secondary anti-infantry.');

-- INSERT OR IGNORE is SILENT on a collision, so these COUNT. Every want is
-- counted off the VALUES lists in THIS FILE, by slug.

SELECT 'the twelve fom vessels' AS assertion, count(*) AS got, 12 AS want
  FROM vehicles WHERE slug IN
    ('battlelord-automaton','colossus-automaton','earth-thunder-automaton',
     'fire-demon-automaton','ice-drake-automaton','infiltrator-automaton',
     'kilairgh-automaton','tw-battle-skimmer','tw-ley-streaker',
     'tw-battle-streaker','tw-zone-ranger-atv','tw-trailblazer-assault-atv');

SELECT 'the seven automatons are robots with no price' AS assertion, count(*) AS got, 7 AS want
  FROM vehicles WHERE slug LIKE '%-automaton' AND vehicle_class = 'robot' AND cost IS NULL
    AND source_book LIKE 'Rifts World Book 16: Federation of Magic p.%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 80 AS want
  FROM vehicle_locations WHERE vehicle_slug IN
    ('battlelord-automaton','colossus-automaton','earth-thunder-automaton',
     'fire-demon-automaton','ice-drake-automaton','infiltrator-automaton',
     'kilairgh-automaton','tw-battle-skimmer','tw-ley-streaker',
     'tw-battle-streaker','tw-zone-ranger-atv','tw-trailblazer-assault-atv');

SELECT 'their weapon entries' AS assertion, count(*) AS got, 34 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN
    ('battlelord-automaton','colossus-automaton','earth-thunder-automaton',
     'fire-demon-automaton','ice-drake-automaton','infiltrator-automaton',
     'kilairgh-automaton','tw-battle-skimmer','tw-ley-streaker',
     'tw-battle-streaker','tw-zone-ranger-atv','tw-trailblazer-assault-atv');

-- Each vessel's stored main body agrees with its own Main Body location row,
-- where it has one (the Streakers file their wings as the main body).
SELECT 'main body agrees with its location row' AS assertion, count(*) AS got, 10 AS want
  FROM vehicles v JOIN vehicle_locations l
    ON l.vehicle_slug = v.slug AND l.location = 'Main Body' AND l.mdc = v.mdc_main_body
  WHERE v.source_book LIKE 'Rifts World Book 16: Federation of Magic p.%';

-- The Zone Ranger's six priced features are weapon rows, and nothing was
-- written to gear for them.
SELECT 'the Zone Ranger features are its six weapon rows' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'tw-zone-ranger-atv';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-fom-vehicles.sql');
