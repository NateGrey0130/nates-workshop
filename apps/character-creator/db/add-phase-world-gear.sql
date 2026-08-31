-- The 43 personal-equipment items of Rifts Dimension Book 2: Phase World,
-- printed 114-129. 22 weapon, 15 armor, 6 gear.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-phase-world-gear.sql
--
-- EVERY NUMBER HERE WAS READ OFF A 200 DPI RENDER, not off the OCR cache. The
-- book is a scan with no text layer, its costs and M.D.C. figures are the
-- columns BOOK-INGEST-AUDIT.md F1 exists about - nothing checks a numeric
-- column against the page it cites - and this section prices in five and six
-- figures where a single misread digit is an order of magnitude.
--
-- Fourteen pages were rendered and compared line by line against the cache.
-- THE OCR AGREED EVERYWHERE: zero discrepancies in 43 stat blocks. That is
-- worth recording as a fact about this cache rather than as a reason to skip
-- the check next time - the reason to render was that a wrong price is
-- invisible afterwards, and that is still true where it happens to have been
-- right.
--
-- Printed-to-PDF offset is ZERO: printed N is cache pNNN and doc[N-1].
--
-- WHAT IS NOT HERE, and it is most of the book's hardware. Printed 130-149 and
-- 157-173 carry 6 power armor and robots, 5 tanks and 14 starships and
-- shuttles. `gear` has one `mdc` integer, one `damage`, one `range` and one
-- `payload`; a vessel here has M.D.C. by location across a dozen entries, a
-- numbered list of five to eight weapon systems each with its own four stats,
-- crew and passenger complements, speed in three regimes and FTL range in light
-- years per hour. Storing one means picking one weapon out of eight and
-- dropping the rest, which is worse than not storing it - the row would read as
-- complete. Filed as BOOK-INGEST-AUDIT.md F3, along with the fact that this is
-- not new: the catalog's existing robot rows lose the same data silently.
--
-- The Psionic Power Armor on printed 128-130 is the boundary case and it falls
-- on the excluded side: it is written as a power armor stat block, M.D.C. by
-- location and all.
--
-- CATEGORIES. Force fields and phase fields are 'armor' rather than 'gear',
-- which is a FIRST for this catalog - there are no force fields in it today.
-- The argument is the book's own rule on printed 121: a force field cannot be
-- worn over armour unless it is built into it, so it is not an accessory to
-- protection, it IS the protection, and its M.D.C. belongs where the sheet's
-- armour block reads M.D.C. from. Helmets go the other way and follow the
-- catalog's existing precedent - `pas-helmet`, the Psychic Amplification System
-- Helmet, is 'gear' with mdc 30 - because a helmet is worn WITH body armour and
-- filing it as armour would double-count.
--
-- COSTS. `cost` holds the plain purchase price; `cost_note` holds everything
-- the integer cannot. That is more than usual here, because Naruni prices most
-- items three ways - personal, integral (built into armour) and robot model -
-- and the ammunition is priced separately from the gun on nine of the weapons.
-- The integer is always the FIRST of those, the one a character actually buys.
--
-- Prices are written `Black Market Cost:` on the Naruni weapons and
-- `Market Cost:` on the armour. The label WRAPS ACROSS A LINE BREAK in the
-- narrow columns, so a `^Cost:` scan of the cache finds 36 of them and misses
-- every one on printed 119-122. Anything re-parsing this section has to join
-- lines first; this transcription did not parse, it read.
--
-- ONE NEAR-COLLISION, and it is not one. The catalog holds `halberd` and
-- `sabre-halberd`, both Palladium Fantasy pole-arms. The Power Halberd is a
-- mega-damage vibro-weapon on a backpack power supply and takes
-- `power-halberd`. Nothing else in these 43 collides with the 975 rows live.
--
-- The book notes on printed 117 that the power halberd was DEPICTED but not
-- described in Wormwood. This is its first stat block, so it is cited here and
-- not there.

INSERT INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage,
                  range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES

-- ===== Weapons, printed 115-118 =====
('hi-30-laser-pistol', 'HI-30 Laser Pistol', 'rifts', 'weapon', 2, 15000,
 'A standard E-Clip is 2,000 credits.', '2D6 M.D.', 1,
 '1000 feet (305 m)', '20 shots', 'Standard', NULL, NULL, NULL,
 'High-intensity laser pistol, the most popular handgun in the CCW and on many independent worlds. HI lasers fire on a higher wavelength than normal lasers for greater penetration. Short-barreled and square, resembling a cut-down Colt .45; light and easy to conceal, a favourite of bodyguards and assassins. The thick barrel is a cooling system. All prices in this book are Three Galaxies Universal credits, not Earth credits.',
 'Rifts Dimension Book 2: Phase World p.115'),

('hi-10-heavy-laser-pistol', 'HI-10 Heavy Laser Pistol', 'rifts', 'weapon', 3, 18000,
 NULL, '3D6+3 M.D.', 1,
 '1000 feet (305 m)', '15 shots', 'Standard', NULL, NULL, NULL,
 'Looks like an oversized .45 pistol and is the standard issue sidearm of the Consortium Armed Forces. Like all high-intensity lasers it has more penetrating power.',
 'Rifts Dimension Book 2: Phase World p.115'),

('hi-50-laser-rifle', 'HI-50 Laser Rifle', 'rifts', 'weapon', 5, 26000,
 'A standard E-Clip is 3,500 credits.',
 '3D6+6 M.D. single shot, or 1D6x10+10 M.D. from a multiple pulse burst (three simultaneous shots, counts as one melee action)', 1,
 '2000 feet (610 m)', '30 shots', 'Standard', NULL, NULL, NULL,
 'A rifle version of the HI-30, resembling a square-shaped shotgun with the thick barrel common to high-intensity lasers. Often in the hands of Transgalactic Empire freedom fighters, bought from smugglers out of CCW planets.',
 'Rifts Dimension Book 2: Phase World p.115'),

('hi-80-combat-laser-rifle', 'HI-80 Combat Laser Rifle', 'rifts', 'weapon', 7, 40000,
 NULL,
 '4D6+6 M.D., or 2D4x10+10 M.D. multiple pulse burst (three simultaneous shots, counts as one melee action)', 1,
 '2000 feet (610 m)', '30 shots', 'Standard', NULL, NULL, NULL,
 'Only slightly bulkier than the HI-50 but fires a more powerful beam. The standard issue infantry weapon of the CAF, adopted by many armies throughout the Three Galaxies.',
 'Rifts Dimension Book 2: Phase World p.115'),

('ep-5-energy-pulse-pistol', 'EP-5 Energy Pulse Pistol', 'rifts', 'weapon', 4, 10000,
 NULL, '3D6 M.D.', 1,
 '1000 feet (305 m)', '9 shots', 'Standard; single shots only', NULL, NULL, NULL,
 'Fires brief intense bursts of charged particles that look like small balls of white flame exploding on contact. Transgalactic Empire line troops use E-Pulse weapons almost exclusively.',
 'Rifts Dimension Book 2: Phase World p.116'),

('epr-8-energy-pulse-rifle', 'EPR-8 Energy Pulse Rifle', 'rifts', 'weapon', 13, 23000,
 NULL, '5D6 M.D. single shot, or 1D6x10 M.D. for a 4-shot burst', 1,
 '1600 feet (488 m)', '40 shots', 'Single shots or short bursts only', NULL, NULL, NULL,
 'The standard issue weapon of the Transgalactic Empire''s Imperial Armies. Short, resembling a carbine or sub-machinegun, but fires devastating automatic bursts. Very sturdy under extreme field conditions, which makes it popular with explorers, colonists and mercenaries too.',
 'Rifts Dimension Book 2: Phase World p.116'),

('power-halberd', 'Power Halberd', 'rifts', 'weapon', 40, 20000,
 NULL, '1D6x10 M.D. when powered up; 4D6 S.D.C. otherwise', 1,
 'Melee weapon', 'Powered by an E-Clip for 2 hours of continual use', 'Equal to the number of hand to hand attacks', NULL, NULL, NULL,
 'A heavy blade on a haft, wired to a power supply worn on the back; powered up, the ultra-hard blade vibrates at high frequency and cuts through power armor, M.D.C. walls and vehicles. Two-handed and clumsy: -2 to strike and parry unless the wielder has a P.S. of 24 or higher, is in power armor, or has a supernatural P.S. of 20 or higher. NOT the catalog''s Halberd or Sabre Halberd, which are Palladium Fantasy pole-arms. First depicted, but not described, in Rifts Dimension Book One: Wormwood; this is its first stat block.',
 'Rifts Dimension Book 2: Phase World p.116-117'),

('ne-4-plasma-cartridge-pistol', 'NE-4 Plasma Cartridge Pistol', 'rifts', 'weapon', 6, 25000,
 'Black market. Each round costs 40 credits; a full magazine costs 400.', '1D4x10 M.D.', 1,
 '500 feet (152 m) maximum effective', '10 shot magazine', 'Standard', NULL, NULL, NULL,
 'The pistol version of the NE-10, firing the same cartridges for the same damage at reduced range. Very heavy and cumbersome for a pistol, with no auto-fire. A character with a P.S. of 17 or less is -2 to strike even on an aimed shot.',
 'Rifts Dimension Book 2: Phase World p.117'),

('ne-10-plasma-cartridge-rifle', 'NE-10 Plasma Cartridge Rifle', 'rifts', 'weapon', 20, 40000,
 'Black market. Each round costs 40 credits; a full magazine costs 800.', '1D4x10 M.D. per single shot', 1,
 '1200 feet (365 m) maximum effective', '20 shot magazine', 'Standard', NULL, NULL, NULL,
 'An energy rifle that needs no E-Clip: it fires thick cartridges with an impact primer that convert to a plasma discharge when struck. High damage, limited range, and the ammunition must be bought from Naruni Enterprises - though NE has licensed producers across the Three Galaxies, so supply is ample. The bore is almost two inches wide.',
 'Rifts Dimension Book 2: Phase World p.117'),

('ne-200-plasma-cartridge-machinegun', 'NE-200 Plasma Cartridge Machinegun', 'rifts', 'weapon', 70, 95000,
 'Black market. Each round costs 40 credits; a full magazine costs 1,600 and a belt costs 8,000.',
 '1D4x10 M.D. per single shot, or 2D6x10 M.D. for a burst of 10 shots', 1,
 '2000 feet (610 m) maximum effective', '200 shot belt or 40 shot magazine', 'Standard', NULL, NULL, NULL,
 'A belt-fed, heavier NE-10, mounted on a tripod or a vehicle. A power armor/cyborg version exists as an oversized rifle with a 40 shot magazine. The user must have a P.S. of 24 or greater. Weight is with magazine; the belt weighs another 15 lbs (6.8 kg).',
 'Rifts Dimension Book 2: Phase World p.117-118'),

('ne-50-particle-beam-rifle', 'NE-50 Particle Beam Rifle', 'rifts', 'weapon', 13, 45000,
 'Black market.', '1D4x10 M.D. per blast', 1,
 '1200 feet (365 m) maximum effective', '8 shots from a standard short E-clip, 16 from a long E-clip', 'Standard', NULL, NULL, NULL,
 'A heavy energy rifle modified to run on Earth-type E-clips. The UNMODIFIED NE-50 sold in other dimensions has a range of 1600 feet (488 m) and fires 24 shots from an NE energy clip, same damage; it has not been offered to the Earth market yet, though sales reps may carry one.',
 'Rifts Dimension Book 2: Phase World p.118'),

('caf-repeating-rocket-launcher', 'CAF Repeating Rocket Launcher', 'rifts', 'weapon', 21, 20000,
 'Each cassette costs 1,000 credits plus the cost of the missiles, 1,000 to 2,200 credits each.',
 'Varies with missile type', 1,
 'About one mile (1.6 km)', 'Four mini-missiles', '2 shots per melee; reloading from a cassette takes one melee round for a trained person or 1D6 melees otherwise', NULL, NULL, NULL,
 'The Repeating Rocket Launcher System (RRLS), one issued per CAF infantry platoon: a bazooka-like tube with a revolving drum magazine of four mini-missiles, reloaded from disposable cassettes. Weight is a fully loaded launcher; each preloaded cassette of 4 missiles weighs 5 lbs (2.25 kg) and only four or five can be comfortably carried. Copies turn up with mercenaries, guerrillas and pirates.',
 'Rifts Dimension Book 2: Phase World p.118'),

-- ===== Body armor and spacesuits, printed 119-121 =====
('light-combat-armor', 'Light Combat Armor', 'rifts', 'armor', 18, 30000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 80,
 'A jumpsuit with plate inserts at chest, forearms and knees and a helmet with a transparent face plate - the Three Galaxies answer to plastic-man body armor, in far stronger composite ceramics and alloys. Worn by private security, independent planetary armies, adventurers and pirates. Good mobility: -10% prowl penalty. Fits humanoids 4 to 9 feet (1.2 to 2.7 m) tall. Like every suit in this section it is vacuum-rated with full environmental protection and an air supply of one hour or less, extendable with oxygen tanks or an air purification and recirculation system (25,000 credits).',
 'Rifts Dimension Book 2: Phase World p.119'),

('caf-jumpsuit', 'CAF Jumpsuit', 'rifts', 'armor', 12, 20000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 25,
 'The Consortium Armed Forces uniform: a form-fitting jumpsuit of fiber-metal composite that resists energy and turns ultra-hard when struck by a high velocity object. Attachments take a helmet and gloves for full environmental protection. Not intended for combat, though black market suits are worn by criminals and adventurers. Cut for wolfen (who complain about the tail pockets), noro and less humanoid races. Great mobility: -2% prowl penalty. Blue with white trimmings; rank is a white-stripe design over torso and shoulders.',
 'Rifts Dimension Book 2: Phase World p.119-120'),

('caf-battle-armor', 'CAF Battle Armor', 'rifts', 'armor', 21, 70000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 100,
 'CAF standard issue combat armor: articulated plate and a full helmet in an angular aerodynamic style. An optional power backpack (40 M.D.C.) holds ten times the energy of a standard E-clip, so a weapon corded to it has ten times the payload - and is useless if the pack is destroyed, which is why most soldiers still carry E-clips. Stealth materials mask the wearer''s heat signature and blend it with the terrain, making thermographic nightvision worse than useless. The helmet carries a line-of-sight laser communicator that cannot be intercepted, though most obstacles including thick smoke block it. Good mobility: -10% prowl penalty. Weight is 25 lbs (11.3 kg) with the backpack attached.',
 'Rifts Dimension Book 2: Phase World p.120'),

('caf-heavy-battle-armor', 'CAF Heavy Battle Armor', 'rifts', 'armor', 25, 80000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 120,
 'A heavier CAF Battle Armor: more protection for more weight and less mobility, issued to heavy weapon squads and to humanoid races with greater than average strength. Takes the same energy backpack and accessories. Non-humanoid versions have roughly the same protection. Fair mobility: -15% prowl penalty. Weight is 30 lbs (13.6 kg) with the power backpack.',
 'Rifts Dimension Book 2: Phase World p.120'),

('spacer-suit', 'Spacer Suit', 'rifts', 'armor', 10, 10000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 20,
 'A civilian spacesuit for life support failures and vacuum work, and light body armour in a pinch. A soft suit of form-fitting flexible super-plastics with a sealed helmet, a small compressed oxygen supply, and fittings for extra tanks, jet packs and grav packs. Great mobility: -5% prowl penalty. Any colour imaginable.',
 'Rifts Dimension Book 2: Phase World p.120'),

('spacer-hard-suit', 'Spacer Hard Suit', 'rifts', 'armor', 21, 65000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 50,
 'The heavy spacesuit, for solar flares, particle showers and vacuum mining - bulky for the protection it gives and a poor substitute for real combat armor, but with a far better life support system. Full life support: a week of food and two weeks of water on word command, an integral oxygen tank and recycler good for two weeks of activity, extra radiation, heat and cold shielding, temperature control, clock, mini-computer on the left arm and a radio communicator. Poor mobility: -20% prowl penalty. Typically white, being easier to spot in an emergency.',
 'Rifts Dimension Book 2: Phase World p.120-121'),

('kreeghor-battle-armor', 'Kreeghor Battle Armor', 'rifts', 'armor', 21, 25000,
 'Poor availability outside the Transgalactic Empire.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 110,
 'A modern fully-sealed version of the mail and segmented armour the ancient kreeghor wore, issued to Transgalactic Empire troopers. Perfectly articulated, fitted to the natural exoskeleton of the race like a second skin, and almost organic in appearance. Full mobility: no prowl penalty. FITS ONLY MEMBERS OF THE KREEGHOR RACE - non-kreeghor soldiers make do with the Imperial Legionnaire''s Armor. Dark gray or jet black with silver trimmings.',
 'Rifts Dimension Book 2: Phase World p.121'),

('imperial-legionnaires-armor', 'Imperial Legionnaire''s Armor', 'rifts', 'armor', NULL, 30000,
 'Poor availability outside the Transgalactic Empire.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 90,
 'Issued to the combat soldiers of the Transgalactic Empire and best known for a face mask sculpted into the face of a snarling kreeghor. Good protection, and manufactured in versions for all the major races of the Empire. Fair mobility: -10% prowl penalty. Dark gray only. THE BOOK GIVES NO WEIGHT for this suit - its stat list runs M.D.C., mobility, colours and price - so weight_lbs is NULL rather than guessed.',
 'Rifts Dimension Book 2: Phase World p.121'),

-- ===== Personal force fields, printed 121-122 =====
-- Naruni Enterprises. Filed 'armor' rather than 'gear': the book's own rule is
-- that a force field cannot be worn over armour unless built into it, so the
-- field IS the protection. mdc holds the PERSONAL model; the robot model's
-- doubled figure is in the description, because it is a different purchase.
('n-f12a-light-force-field', 'N-F12A Light Force Field', 'rifts', 'armor', 8, 25000,
 'Personal field. The integral model (N-F12B) is 35,000 credits including installation, armour bought separately; the Robot Model is 700,000.',
 NULL, 0, NULL, 'One E-Clip runs the field for 12 hours', NULL, NULL, NULL, 45,
 'Naruni Enterprises. The lightest field, worn as two crossed belts over the torso which convert to bandoleers at no extra cost, holding 6 grenades or 4 E-Clips each. Activating it takes one melee action and protects immediately. The integral N-F12B builds into any M.D.C. or powered armour; the powered armour version taps the suit reactor and needs no E-Clip. The ROBOT MODEL has 90 M.D.C. General force field rules, printed 121: no prowl penalty; the field reacts to energy beams and fast-moving objects, so a weapon pressed slowly against the target is at -6 to strike but works. No protection against gases, hostile environments, drowning or fire. A depleted field has overloaded and cannot be reactivated for 12 hours; short of that it regenerates 1 M.D.C. per melee round.',
 'Rifts Dimension Book 2: Phase World p.121'),

('n-20a-medium-force-field', 'N-20A Medium Force Field', 'rifts', 'armor', 10, 50000,
 'Personal field. The integral model (N-20B) is 65,000 credits; the Robot Model is one million.',
 NULL, 0, NULL, 'One E-Clip runs the field for 8 hours', NULL, NULL, NULL, 75,
 'Naruni Enterprises. As the N-F12A but with greater protection. The ROBOT MODEL has 150 M.D.C. See the N-F12A for the general force field rules on printed 121.',
 'Rifts Dimension Book 2: Phase World p.121'),

('n-40a-heavy-force-field', 'N-40A Heavy Force Field', 'rifts', 'armor', 15, 90000,
 'Personal field. The integral model (N-40B) is 130,000 credits; the Robot Model is two million.',
 NULL, 0, NULL, 'One E-Clip runs the field for 4 hours of continual use', NULL, NULL, NULL, 110,
 'Naruni Enterprises. Requires a harness system and is slightly heavier than the N-F12 or N-20. This is the usual limit for infantry force fields. The ROBOT MODEL has 220 M.D.C. See the N-F12A for the general force field rules on printed 121.',
 'Rifts Dimension Book 2: Phase World p.122'),

('n-50a-superheavy-force-field', 'N-50A Superheavy Force Field', 'rifts', 'armor', 15, 170000,
 'Personal field. The integral model (N-50B) is 280,000 credits; the Robot Model is five million.',
 NULL, 0, NULL, NULL, NULL, NULL, NULL, 160,
 'Naruni Enterprises, and the most powerful force field available. Looks and weighs the same as the N-40 but is much more intense. The ROBOT MODEL has 320 M.D.C. See the N-F12A for the general force field rules on printed 121.',
 'Rifts Dimension Book 2: Phase World p.122'),

-- ===== Phase technology, printed 122-125 =====
('ph-21-phase-beamer', 'PH-21 Phase Beamer', 'rifts', 'weapon', 4, 50000,
 NULL, '3D6 S.D.C. to humans and other S.D.C. creatures; 4D6 M.D. to M.D.C. beings and force fields', 1,
 '400 feet (122 m)', '10 shots', 'Equal to the total number of hand to hand attacks', NULL, NULL, NULL,
 'The pistol phase beamer, popular with pirates, assassins, mercenaries and adventurers. A phase beamer projects a phase field that disrupts the target''s vital functions and BYPASSES ARMOR OF ANY KIND - it damages the target, never the armour - and it hurts S.D.C. and M.D.C. creatures roughly alike, including vampires and supernatural beings, whose animating energies it dispels. Damage regenerates far more slowly than normal: what usually heals in melee rounds takes hours, minutes become days, hours become weeks. Magical, psionic and technological healing work normally. Three limits: it is useless against inanimate objects (walls, furniture, robots, vehicles), which is why it is popular aboard ships; it is stopped by normal force fields, damaging the field without penetrating it, and does nothing at all to a target in a phase field; and it is stopped by magic barriers, and halts harmlessly at the perimeter of any magic protection circle.',
 'Rifts Dimension Book 2: Phase World p.123'),

('ph-100-heavy-phase-beamer', 'PH-100 Heavy Phase Beamer', 'rifts', 'weapon', 7, 85000,
 NULL, '4D6 S.D.C. to humans and other S.D.C. creatures; 5D6 M.D. to mega-damage beings and force fields', 1,
 '800 feet (244 m)', '20 shots', 'Equal to the total number of hand to hand attacks', NULL, NULL, NULL,
 'The rifle model of the PH-21 and identical to it except for damage and range. Body armor is not damaged. See the PH-21 for the phase beamer rules on printed 122.',
 'Rifts Dimension Book 2: Phase World p.123'),

('ph-400-heavy-phase-beamer', 'PH-400 Heavy Phase Beamer', 'rifts', 'weapon', 80, 180000,
 NULL,
 '4D6 to all targets in a 10 foot (3 m) radius, or 6D6 to any creature 10 feet (3 m) or taller; force fields also suffer 6D6. S.D.C. to non-M.D.C. creatures, M.D. to M.D.C. creatures and force fields', 1,
 '1600 feet (488 m)', '60 shots', 'Equal to the total number of hand to hand attacks', NULL, NULL, NULL,
 'A tripod-mounted support weapon or light vehicle cannon, with a rifle model for giant creatures and robot vehicles. The phase field covers a 10 foot (3 m) radius - roughly 20 ft/6.1 m across - damaging every man-sized or smaller target in it, OR two giant creatures 10 feet or larger, which take more because their energies are disrupted over a wider portion of the body. See the PH-21 for the phase beamer rules on printed 122.',
 'Rifts Dimension Book 2: Phase World p.123'),

('phase-sword', 'Phase Sword', 'rifts', 'weapon', NULL, 30000,
 NULL, '4D6 M.D.C. or S.D.C./Hit Point damage, plus the wielder''s P.S. bonus if any', 1,
 'Melee weapon', NULL, NULL, NULL, NULL, NULL,
 'A high strength alloy blade sheathed in a phase field. The P-field disrupts inanimate and living things alike, so the blade cuts mega-damage alloys and hurts supernatural and M.D.C. beings the way a phase beamer does. The book gives it no weight; weight_lbs is NULL rather than guessed.',
 'Rifts Dimension Book 2: Phase World p.124'),

('p-field-defensive-field', 'P-Field (Defensive Field)', 'rifts', 'armor', 5, 25000,
 'Extra batteries are 1,000 credits each. Built into a suit of armour costs double.',
 NULL, 0, NULL, 'A battery powers the field for 12 hours of continual use', NULL, NULL, NULL, 10,
 'A phase distortion projected around the wearer that DIVIDES INCOMING DAMAGE BY TEN - energy blasts, beams of all kinds, bullets, rail gun blasts, missiles and explosions. Roll damage as usual, divide by ten, and apply it to the character or to the armour they are wearing. PUNCHES, KICKS AND MELEE WEAPONS MOVE TOO SLOWLY TO BE STOPPED and do full damage; parry or dodge them. The field passes sunlight and slow-moving objects and lets the wearer shoot out through it without penalty; it disperses 90% of an energy attack rather than all of it, because a field that stopped everything would leave the wearer inside an immovable black bubble. Worn as a harness with a projector front and back - the mdc column here is ONE projector, 10 M.D.C.; destroying one kills the field on that side. The harness goes over light body armour of 50 M.D.C. maximum, or builds into a suit at double cost, where the projector dies once over half the armour''s M.D.C. is gone. No prowl penalty. Magic and psionic attacks penetrate it entirely. The built-in version adds 6 lbs (2.7 kg) to the armour.',
 'Rifts Dimension Book 2: Phase World p.124'),

('op-field-out-of-phase-field', 'OP-Field (Out-of-Phase Field)', 'rifts', 'armor', NULL, 60000,
 'Standard harness. Building it into normal body armour is 90,000 credits; into powered armour, 600,000 plus the cost of the armour. Batteries are 5,000 credits and are not interchangeable with E-clips or conventional batteries.',
 NULL, 0, NULL, 'One hour of uninterrupted intangibility or 20 switch-ons, whichever comes first', NULL, NULL, NULL, 10,
 'Turns the wearer insubstantial: they walk through walls, though not force fields or magical barriers, and cannot be hurt by any non-magical attack including physical blows from most supernatural creatures. THE WEARER CANNOT ATTACK OR AFFECT PHYSICAL TARGETS while out of phase. Magic and psionic attacks do normal damage anyway, phase beamers do normal damage anyway, and normal force fields - the kind protecting medium and large spaceships - still stop the character. Activating it costs one melee action and can be used as a dodge at +1, rolled normally. Same M.D.C. as the other phase fields. Wired to a nuclear power plant it does not become unlimited: 40 switches and six hours per 24 hour period, after which the generator overloads and must cool off for 12 hours.',
 'Rifts Dimension Book 2: Phase World p.124-125'),

('phase-tech-med-kit-field', 'Phase-Tech Med Kit (Field)', 'rifts', 'gear', NULL, 80000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL,
 'The field version of the phase-tech medical kit. Gives a Recovery Ratio of 55% in the field. Phase-tech surgery works by turning foreign objects insubstantial - bullets and shrapnel drop straight out of the patient - and by irradiating viruses with phase beams calibrated to kill only them, leaving beneficial micro-organisms alone. Cybernetic and bionic implants are unaffected, being attached to the nervous system and phasing out with it.',
 'Rifts Dimension Book 2: Phase World p.125'),

('phase-tech-med-kit-full', 'Phase-Tech Med Kit (Full)', 'rifts', 'gear', 30, 200000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL,
 'The full phase-tech medical kit: the equivalent of RMK and IRMSS med systems, a drug dispenser with a full variety of medicines, and a phase-tech kit. Gives a Recovery Ratio of 80% in the field, and 98% in a proper sick bay or hospital.',
 'Rifts Dimension Book 2: Phase World p.125'),

-- ===== Gravitonic technology, printed 125-127 =====
-- Gravity rail guns fire pellets on gravitonic rather than electromagnetic
-- power: more damage, slightly shorter range than an equivalent rail gun, and
-- small enough to build as rifles. DOUBLE THE EFFECTIVE RANGE IN SPACE; in zero
-- gravity the slugs never lose velocity, though accuracy at distance still
-- applies. Issued by many independent worlds, and by selected Transgalactic
-- Empire units specifically to deal with cosmo-knights, who are effectively
-- invulnerable to energy weapons.
('gr-10p-pistol', 'GR-10P Pistol', 'rifts', 'weapon', 2, 8000,
 'Magazines cost 500 credits.', '2D4 M.D. per shot', 1,
 '800 feet (244 m); double in space', '15 shots', 'Single shot only', NULL, NULL, NULL,
 'A long-barreled gravity rail pistol, somewhat like Earth''s ancient Luger automatics. Each magazine carries both the bullets and the micro-gravitonic generator that propels them.',
 'Rifts Dimension Book 2: Phase World p.125'),

('gr-45hp-jackhammer-heavy-pistol', 'GR-45HP "Jackhammer" Heavy Pistol', 'rifts', 'weapon', 6, 15000,
 'Each magazine costs 1,000 credits.', 'A single round does 2D6 M.D.; a three round burst does 5D6 M.D.', 1,
 '800 feet (244 m); double in space', '27 shots', 'Single shots or three round bursts only', NULL, NULL, NULL,
 'Resembles an Ingram or another machine-pistol with a long barrel. Heavier and harder to conceal than the GR-10P, with more penetration and stopping power. Used mostly by outlaws and mercenaries.',
 'Rifts Dimension Book 2: Phase World p.126'),

('gr-15ar-assault-rifle', 'GR-15AR Assault Rifle', 'rifts', 'weapon', 13, 22000,
 'Each loaded magazine costs 2,000 credits. The multi-spectrum scope and barrel extension cost extra.',
 'A single round does 3D4 M.D.; a three round burst does 1D4x10 M.D.; a 10-round burst does 2D4x10 M.D.', 1,
 '1,000 feet (305 m), or 2,000 feet (610 m) with sniper attachments; double in space', '30 shots',
 'Selector for single shots, 3-round bursts and 10-round bursts only; each burst or shot counts as one melee attack', NULL, NULL, NULL,
 'A heavy gravity rail assault rifle with a carrying handle on top, much like a 20th century M-16, and the long barrel every GR gun needs to bring the slugs to ultrasonic speed. Reconfigures as a sniper rifle with a multi-spectrum scope and a barrel extension, which also adds +3 to strike; so equipped it weighs 16 lbs (6.75 kg).',
 'Rifts Dimension Book 2: Phase World p.126'),

('grav-pack', 'Grav Pack', 'rifts', 'gear', 20, 150000,
 'A nuclear powered grav pack with an average energy life of 10 years, allowing continual use, is 550,000 credits.',
 NULL, 0, NULL, '12 hours on a normal replaceable battery; an E-clip can be jury-rigged in its place', NULL, NULL, NULL, 30,
 'A small contra-gravity flight unit strapped to the back and worked from a wrist controller or neural connections; with neural connectors the wearer is +1 to dodge while flying. Flies at up to 200 mph (320 km) in atmosphere and Mach One (660 mph/1056 km) in a vacuum. Speed trades for lift: 400 lbs (181 kg) at full speed, 800 lbs (362 kg) at 50 mph, one ton (907 kg) at 10 mph, and two tons (1,800 kg) moved or pushed as if near-weightless - though NOT inertialess, so stopping two tons takes as much force as starting it. A human wearing the pack cannot carry super-heavy weights themselves; the pack is strapped to the load instead and the user rides it, which drains the battery twice as fast.',
 'Rifts Dimension Book 2: Phase World p.126-127'),

-- ===== Psionic crystal technology, printed 127-128 =====
-- Noro technology, built on psylite - a crystal found in about one millionth
-- part of quartz, which only a psychic sensitive can tell from worthless stone,
-- and which stores I.S.P. even in its natural state.
('crystal-cell', 'Crystal-Cell', 'rifts', 'gear', NULL, 4000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL,
 'The psylite power pack that runs every noro crystal weapon. Recharged by spending I.S.P. into it at 8 I.S.P. per charge, or only 4 at a ley line.',
 'Rifts Dimension Book 2: Phase World p.127'),

('crystal-bolt-pistol', 'Crystal Bolt-Pistol', 'rifts', 'weapon', 3, 30000,
 NULL, '2D6 M.D., or 4D6 M.D. at ley lines', 1,
 '1,000 feet (305 m)', '20 shots; a psionic can power it directly at 5 I.S.P. per shot, and 100 I.S.P. reloads it',
 'Equal to the total number of hand to hand attacks per melee', NULL, NULL, NULL,
 'ONLY A PSIONIC CHARACTER - minor, major or master - can use this weapon, though firing it costs no I.S.P. It fires mega-damage mind bolts identical to the mind bolt super-psionic power but for more damage, and the damage doubles at a ley line. The crystal battery recharges on 100 I.S.P.',
 'Rifts Dimension Book 2: Phase World p.127'),

('crystal-paralyzer', 'Crystal Paralyzer', 'rifts', 'weapon', 3, 35000,
 NULL,
 'None. A hit forces a save vs psionic attack, adding P.E. bonuses, on a 14 or higher', 0,
 '500 feet (152 m)', 'Crystal magazine holds 20 shots; a psychic wielder can power it at 8 I.S.P. per shot, and 160 I.S.P. reloads it',
 'Equal to the total number of hand to hand attacks per melee', NULL, NULL, NULL,
 'Fires a psionic burst - a visible flash of purple light - that scrambles the target''s nerve impulses. Only a psionic character can use it, and it costs no I.S.P. to operate. ON A FAILED SAVE the character collapses for 1D4 melees, only vaguely aware of what is happening around them. ON A SAVE ROLL OF 5 OR LESS, counting P.E. bonuses, the heart has stopped: roll against coma/death, with recovery depending on the medical aid given in the next 10 minutes. Meant to neutralise voluntary nerve impulses only, but involuntary ones - heartbeat, breathing - may be caught too. Used by security forces, kidnappers and slavers for non-lethal work.',
 'Rifts Dimension Book 2: Phase World p.127-128'),

('crystal-assault-rifle', 'Crystal Assault Rifle', 'rifts', 'weapon', 6, 55000,
 NULL,
 '4D6 M.D. for mind bolt or paralysis; paralysis victims must roll 16 or higher to save, adding P.E. bonuses', 1,
 '2,000 feet (610 m) for both attack settings',
 '40 shots from a Crystal-cell; can be fired unloaded at 8 I.S.P. per shot, or reloaded at the same rate, 320 I.S.P. for a full reload',
 'Equal to the total number of hand to hand attacks per melee', NULL, NULL, NULL,
 'Combines the bolt pistol and the paralyzer with greater damage and effect; the user, who must be psionic, selects the setting mentally and may change it between attacks. The risk of heart failure on a low paralysis save is the same as for the Crystal Paralyzer. Standard issue for the noro military, and often found in special units of the CAF.',
 'Rifts Dimension Book 2: Phase World p.128'),

('augmenting-helmet', 'Augmenting Helmet', 'rifts', 'gear', NULL, 50000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 30,
 'A helmet latticed with perfectly aligned psylite crystals that focuses a psychic''s I.S.P.: EVERY I.S.P. POINT SPENT COUNTS AS TWO, so the character''s effective I.S.P. capacity is doubled. A group mind block costing 22 I.S.P. costs 11 while the helmet is worn. Typically built inside layers of M.D.C. armour and can replace a normal environmental armour helmet. Filed as gear rather than armor, following the catalog''s existing pas-helmet, because a helmet is worn WITH body armour and filing it as armour would double-count its M.D.C.',
 'Rifts Dimension Book 2: Phase World p.128'),

('telepathic-communicator', 'Telepathic Communicator', 'rifts', 'gear', NULL, 52000,
 NULL, NULL, 0, '10 miles (16 km), or 20 miles (32 km) if both telepaths wear one', NULL, NULL, NULL, NULL, NULL,
 'Worn as a wristband or a headband. Its crystals amplify telepathic powers so that a character with any type of telepathy can reach another telepath at range. I.S.P.: 10.',
 'Rifts Dimension Book 2: Phase World p.128'),

('psionic-crystal-armor', 'Psionic Crystal Armor', 'rifts', 'armor', 10, 100000,
 NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 35,
 'Light body armour with an embedded psylite lattice that projects a psionic force field of 70 M.D.C. on top of the suit''s own 35. When the field drops to zero it re-activates automatically, four times per 24 hour period at no I.S.P. cost; beyond that the wearer, who must be psionic, spends 20 I.S.P. to raise it, and the same 20 recharges the crystal array. WHILE THE FIELD IS UP the wearer is +2 to save vs psionic attack. The mdc column holds the armour''s own 35: the force field is a separate, regenerating pool the sheet has no shape for. No prowl penalty.',
 'Rifts Dimension Book 2: Phase World p.128')

ON CONFLICT(slug) DO NOTHING;

-- Read the result back rather than trusting the exit code.
SELECT category, COUNT(*) AS n, MIN(cost) AS cheapest, MAX(cost) AS dearest
  FROM gear WHERE source_book LIKE 'Rifts Dimension Book 2: Phase World%'
 GROUP BY category ORDER BY category;
SELECT COUNT(*) AS phase_world_gear FROM gear
 WHERE source_book LIKE 'Rifts Dimension Book 2: Phase World%';
SELECT COUNT(*) AS total_gear FROM gear;

-- Every row must carry a price: this book sells everything and none of it is
-- barter, so a NULL cost here is a failed read rather than a fact about the
-- book. Should be zero.
SELECT COUNT(*) AS priceless_rows FROM gear
 WHERE source_book LIKE 'Rifts Dimension Book 2: Phase World%' AND cost IS NULL;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-phase-world-gear.sql');
