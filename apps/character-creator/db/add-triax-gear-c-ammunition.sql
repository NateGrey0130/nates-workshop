-- Triax ammunition, grenades, demolition blocks, flares and arrowheads.
-- Printed 141 and 149-150. Twenty-three rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-c-ammunition.sql
--
-- WHAT IS DELIBERATELY ABSENT, because the catalog already holds it: the plain
-- Fragmentation Grenade, the Explosive Grenade, the Smoke Grenade, the E-Clip,
-- and the Vibro-Knife, Vibro-Saber, Vibro-Sword and Vibro-Claws that printed
-- 150 lists without prices. Checked by name against all 1,025 gear rows before
-- writing this file, not assumed. The heavy 3D6 fragmentation grenade IS new
-- and is here; the light 2D6 one is close enough to the existing row that a
-- second would be a duplicate.
--
-- THE BOOK PRINTS THREE PRICES FOR ONE PUMP ROUND - 300 credits in the general
-- rule on printed 141, 400 in the TX-5 entry and 200 in the TX-16 entry. This
-- row carries the 300 from the general rule and its cost_note names the other
-- two. Recorded rather than averaged; the weapon rows in batch B each carry
-- what their own entry prints.
--
-- ONE ROW HAS NO PRICE AND SAYS SO: the giant Electro-Mace. The book prints
-- none anywhere - it reads as standard issue for the X-2500 Black Knight rather
-- than something for sale - so cost is NULL and cost_note explains why, which
-- is the convention for the rows already on the "gear with no price" backlog.
--
-- Sorts after add-triax-gear-b-weapons.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('triax-forward-sliding-clip', 'Triax Forward Sliding Clip (FSE-Clip)', 'rifts', 'gear', NULL, 17000, '17,000 credits; recharging costs 5,000 credits', NULL, 0, NULL, '40 to 50 shots in a pistol, or 20 to 40 in a rifle', NULL, NULL, NULL, NULL, 'The Triax long energy clip, sliding forward along the weapon rather than seating in the handle. Rechargeable.', 'Rifts World Book 5: Triax and the NGR p.141'),
('triax-short-clip', 'Triax Short Clip', 'rifts', 'gear', NULL, 9000, '9,000 credits; recharging costs about 2,000 credits', NULL, 0, NULL, '10 to 20 shots in a pistol, or 8 to 10 in a rifle', NULL, NULL, NULL, NULL, 'The Triax short energy clip, seating in the weapon handle. Rechargeable.', 'Rifts World Book 5: Triax and the NGR p.141'),
('triax-pump-rounds', 'Pump Rounds', 'rifts', 'gear', NULL, 300, '300 credits each, or 14,400 credits for a box of 48. NOTE: the TX-5 entry prices the same round at 400 credits and the TX-16 entry at 200; this is the general rule on printed 141', 'By weapon; a pump round does the weapon full damage, where a DU-Round or U-Round does only 1D6 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'High explosive mini-grenade cartridges for the TX-5 pump pistol and TX-16 pump rifle. Much smaller than a conventional grenade, with a very concentrated blast of about one foot (0.3 m).', 'Rifts World Book 5: Triax and the NGR p.141'),
('depleted-uranium-rounds', 'Depleted Uranium Rounds (DU-Rounds)', 'rifts', 'gear', NULL, 2, 'Not commonly available; black market and bandits ask about 2 to 5 credits per round', '1D6x10 M.D. for a standard 30-round burst, or 1D4x10 M.D. for a 20-round burst - about 25% more than standard metal cartridges', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'Depleted uranium rail gun cartridges, and excellent armour piercing rounds. Pump weapons can fire them too, at only 1D6 M.D. per round.', 'Rifts World Book 5: Triax and the NGR p.141'),
('uranium-rounds', 'Uranium Rounds (U-Rounds)', 'rifts', 'gear', NULL, 10, 'Black market 10 credits a round, ranging from half that to twice as much', 'About 25% more damage than standard cartridges against supernatural beings', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'Top-secret NGR ammunition, restricted to rail guns mounted in cyborgs and robots. Beyond the extra damage, a supernatural being hit by them CANNOT bio-regenerate until the rounds are surgically removed - which is the whole point of them. They are not effective against fire, air or water elementals, entities, temporal raiders, spectres and other energy beings.', 'Rifts World Book 5: Triax and the NGR p.141-143'),
('conventional-sdc-rounds', 'Conventional S.D.C. Rounds', 'rifts', 'gear', NULL, 10, 'About 10 credits for a box of 48 ordinary bullets. Armour piercing or dum-dum rounds cost triple; exploding rounds are 100 credits for a box of 48', 'By weapon. Armour piercing adds 1D6 S.D.C.; exploding rounds add 1D4x10 S.D.C.', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Ordinary .22 to 10mm ammunition for S.D.C. firearms, in normal, armour piercing, dum-dum and exploding varieties.', 'Rifts World Book 5: Triax and the NGR p.141'),
('triax-fusion-block-light', 'Fusion Block (Light)', 'rifts', 'gear', NULL, 1000, 'Black market 1,000 credits', '1D4x10 M.D.', 1, 'Placed by hand; thrown at most 1D6x10 feet (3 to 18 m), being far from aerodynamic', NULL, NULL, NULL, NULL, NULL, 'The lightest of the three Triax fusion demolition blocks.', 'Rifts World Book 5: Triax and the NGR p.149'),
('triax-fusion-block-medium', 'Fusion Block (Medium)', 'rifts', 'gear', NULL, 3000, 'Black market 3,000 credits', '2D6x10 M.D.', 1, 'Placed by hand; thrown at most 1D6x10 feet (3 to 18 m)', NULL, NULL, NULL, NULL, NULL, 'The middle of the three Triax fusion demolition blocks.', 'Rifts World Book 5: Triax and the NGR p.149'),
('triax-fusion-block-heavy', 'Fusion Block (Heavy)', 'rifts', 'gear', NULL, 8000, 'Black market 8,000 credits', '4D6x10 M.D. with a 10 foot (3 m) blast radius', 1, 'Placed by hand; thrown at most 1D6x10 feet (3 to 18 m)', NULL, NULL, NULL, NULL, NULL, 'The heaviest Triax fusion demolition block, and the only one whose blast radius the book prints.', 'Rifts World Book 5: Triax and the NGR p.149'),
('fragmentation-grenade-heavy', 'Fragmentation Grenade (Heavy)', 'rifts', 'gear', NULL, 250, '250 credits', '3D6 M.D. with a 30 foot (9 m) blast radius', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'The heavy fragmentation grenade of the Triax line. The catalog already holds a lighter Fragmentation Grenade from another book; this is the 3D6 version, and the light 2D6 version printed beside it matches the existing row closely enough not to duplicate it.', 'Rifts World Book 5: Triax and the NGR p.149'),
('triax-plasma-grenade', 'Plasma Grenade', 'rifts', 'gear', NULL, 350, '350 credits', '5D6 M.D. over a 12 foot (3.6 m) area', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'The Triax plasma grenade - the hardest-hitting of the hand grenades in this book.', 'Rifts World Book 5: Triax and the NGR p.149'),
('stun-flash-grenade', 'Stun/Flash Grenade', 'rifts', 'gear', NULL, 100, '100 credits', 'None. An unarmoured target without goggles is -8 to strike, parry and dodge, -1 on initiative, and loses one attack for 1D4 melee rounds', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A non-damaging grenade that blinds and disorients. Armour with light filters, or a pair of goggles, defeats it.', 'Rifts World Book 5: Triax and the NGR p.149'),
('triax-tear-gas-grenade', 'Tear Gas Grenade', 'rifts', 'gear', NULL, 200, '200 credits', 'None. Victims are -10 to strike, parry and dodge, -3 on initiative, and lose one attack or action for 1D6+1 melee rounds', 0, 'A cloud 25 feet (7.6 m) across', NULL, NULL, NULL, NULL, NULL, 'A non-damaging gas grenade. Sealed environmental armour and gas masks are immune.', 'Rifts World Book 5: Triax and the NGR p.149-150'),
('triax-handheld-flare', 'Handheld Flare', 'rifts', 'gear', NULL, 1, '1 credit', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A hand-held signal flare burning for about twenty minutes. Not a weapon.', 'Rifts World Book 5: Triax and the NGR p.150'),
('parachute-flare', 'Parachute Flare', 'rifts', 'gear', NULL, 10, '10 credits', '6D6 S.D.C. per melee round for one minute if fired into a person, with a 50% chance of setting them alight', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A signal flare fired into the air and drifting down under a small parachute. The book states plainly that this is NOT a weapon - the damage line is what happens when somebody uses it as one anyway.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-light-explosive', 'Arrowhead: Light Explosive', 'rifts', 'gear', NULL, 100, '100 credits', '1D6x10 S.D.C.', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'High-tech explosive arrowhead for bows and crossbows, at the S.D.C. end of the range.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-medium-explosive', 'Arrowhead: Medium Explosive', 'rifts', 'gear', NULL, 300, '300 credits', '1D6 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'The lightest mega-damage arrowhead in the Triax range.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-heavy-explosive', 'Arrowhead: Heavy Explosive', 'rifts', 'gear', NULL, 550, '550 credits', '2D6 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'A heavy explosive arrowhead for bows and crossbows.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-high-explosive', 'Arrowhead: High Explosive', 'rifts', 'gear', NULL, 900, '900 credits', '3D6 M.D.', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'The heaviest explosive arrowhead the book prints.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-gas', 'Arrowhead: Gas', 'rifts', 'gear', NULL, 100, '100 credits for tear gas, 250 for tranquilizer, 400 for paralysis', 'None; releases a gas cloud 10 feet (3 m) across', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A gas-filled arrowhead, available in tear gas, tranquilizer and paralysis varieties. The stored cost is the tear gas version, the cheapest of the three.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-smoke', 'Arrowhead: Smoke', 'rifts', 'gear', NULL, 60, '60 credits', 'None; a smoke cloud 20 feet (6 m) across', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A smoke arrowhead, available in four colours.', 'Rifts World Book 5: Triax and the NGR p.150'),
('arrowhead-flare', 'Arrowhead: Flare', 'rifts', 'gear', NULL, 10, '10 credits', 'None; burns for about sixty seconds', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A signal flare arrowhead.', 'Rifts World Book 5: Triax and the NGR p.150'),
('triax-electro-mace', 'Electro-Mace (Giant)', 'rifts', 'gear', NULL, NULL, 'The book prints no price. It reads as standard equipment for the X-2500 Black Knight rather than a market item', 'Blunt 4D6 M.D., or 5D6 M.D. when electrically charged; the electrical bolt does 1D4x10 M.D. three times per melee round', 1, 'Hand to hand, or 1000 feet (305 m) for the electrical bolt', NULL, NULL, NULL, NULL, NULL, 'A giant-size mace carrying an electrical charge, and able to throw a bolt at range. NO PRICE IS PRINTED for it anywhere in the book.', 'Rifts World Book 5: Triax and the NGR p.150');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 'arrowhead-%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-c-ammunition.sql');
