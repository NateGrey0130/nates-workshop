-- Heroes Unlimited's heavy weapons, energy weapons, incendiaries, gases,
-- explosives, miscellaneous modern weapons and firearm accessories.
-- Printed 207-211. Eighty-seven rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-d-heavy-and-accessories.sql
--
-- THREE FORMATS IN FIVE PAGES, and none of them is the labelled firearm run of
-- printed 201-206 that the previous batch could parse:
--
--   207-208   prose, with inline Cost:/Damage:/Range: markers under a heading
--   209-210   line-per-field stat blocks - Range:, Damage:, Weight:, Cost:
--   210-211   a black-market price CHART, and then prose descriptions carrying
--             the damage for the rows that chart prices
--
-- Transcribed by hand off renders of all five pages rather than parsed. A parser
-- tuned to one of those shapes would have skipped the other two silently, and
-- `Country:` - the marker the last batch counted on - appears ZERO times on any
-- of these pages.
--
-- ===================================================================
-- ONE HEADING, SEVERAL PRICES - THE COMMONEST SHAPE HERE
-- ===================================================================
--
-- These pages price accessories and ammunition inside the weapon's own
-- paragraph, and a row cannot hold two prices. Each becomes its own row:
--
--   Gas Gun          -> the gun, plus FOUR canister types at $50/$50/$75/$25
--   Stun Gun         -> the gun at $4,000, energy clips at $1,000
--   every energy weapon -> the weapon, plus its energy clip
--   Flare Gun        -> the gun at $200, flares at $10 each
--   Rocket Parachute Flare -> the flare at $10, the launcher at $300
--   Tranquilizer Rifle and Dart Gun -> ONE shared Tranquilizer Darts row, since
--                                      printed 207 gives both the same $10.00
--   SLR-60           -> the rod, spikes at $30 a dozen, line spools at $200
--   Nerve Gas        -> the gas, and the Atropine Injector that negates it
--
-- ===================================================================
-- TWO NAMES THIS BOOK USES TWICE, FOR DIFFERENT THINGS
-- ===================================================================
--
-- Both collide with rows already imported from printed 194:
--
--   Black Jack   printed 194, ancient miscellaneous   $10   1-4
--                printed 211, modern                  $20   1D6
--   Mace         printed 194, blunt weapon            $240  1-8
--                printed 211, chemical spray          $16   blinds, no damage
--
-- The printed-211 rows carry a qualifier the book does not print, so the two
-- are separable in a picker. The printed-194 rows keep the bare name.
--
-- AND THREE GAS NAMES COLLIDE WITH EACH OTHER inside this batch. Printed 208
-- prices tear, tranquilizer, nerve and smoke gas as GAS GUN CANISTERS; printed
-- 210 heads Tear Gas, Knockout Gas and Nerve Gas as grenades and bombs at
-- different prices - $50 against $40 for tear gas, $75 against $120 for nerve
-- gas. They are different items and both sets are kept, the canisters carrying
-- the qualifier because the book prices them inside another entry's paragraph.
--
-- ===================================================================
-- WHAT THE CHART PRICES, AND WHAT PRICES ITSELF
-- ===================================================================
--
-- `Explosive Grenade`, `Smoke Grenade` and `Rifle Launcher Grenades` each end
-- with "Cost: See Explosives Chart below" and have no figure of their own. The
-- chart on printed 210 lists them under slightly different names - Hand
-- Grenades, Smoke Grenades, Rifle Launched Grenades - at $60, $30 and $80. The
-- headed name is kept and the chart's name and availability go in `cost_note`,
-- so no row is duplicated between the two readings.
--
-- The chart's other six rows - Dynamite, Detonation Caps/Fuses, Plastic
-- Explosive, Gelatin Explosive, Liquid Nitroglycerin and Mortar Shells - have no
-- headed entry and are imported from the chart, with their damage taken from the
-- prose that follows it on printed 210-211.
--
-- Every chart price carries its AVAILABILITY percentage in `cost_note`, because
-- these are black-market prices and the chance of finding the item is half of
-- what the chart is telling you. The chart was read off a 240 dpi render: the
-- OCR runs the cells together ("$30each", "2 0z", "LaunchedGrenades") and every
-- figure was confirmed against the page.
--
-- ===================================================================
-- TWO ROWS WITH NO PRICE, AND THEY ARE NOT THE SAME KIND OF NO
-- ===================================================================
--
--   Molotov Cocktail   the entry gives a thrown range and damage and STOPS.
--                      The book prints no price. NULL is the finished state.
--   Itching Powder     the book says "only a couple of bucks per ounce from a
--                      novelty shop" - a real statement about price that is not
--                      a figure this column can hold. NULL cost, and the words
--                      in `cost_note`.
--
-- THE M.D.C. FIGURE ON THE INCENDIARY GRENADE IS NOT A MEGA-DAMAGE RULE. Printed
-- 209 gives "1D100+20 S.D.C. or 1 M.D.C." as an equivalence for anyone crossing
-- this game with one that has M.D.C.; the survey records it as one of only two
-- M.D.C. mentions in 240 pages. `is_mega_damage` is 0 on every row in this file.
--
-- Weights are the POUND figure, converted from ounces where the book prints
-- those. Where the book prints a RANGE - the machineguns are "15 to 25lbs" and
-- "30 to 100lbs" - the LOW end is stored and the range is in the description.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('light-machinegun-30-5-62mm-and-7-62mm-calibre', 'Light Machinegun (.30, 5.62mm and 7.62mm Calibre)', 'heroes-unlimited', 'weapon', 15, 2000, '$2000.00 and up (mostly illegal)', '5D6 per round', 0, '3000ft', '.30, 5.62mm and 7.62mm in 100, 200 and 250 round belts', 'The most common kinds of light machinegun in military forces the world over. Printed weight is a RANGE, 15 to 25lbs; the low end is stored. Rate of fire: can empty the weapon in two melee rounds. The book writes the middle calibre as 5.62mm and it is transcribed as printed.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('heavy-machinegun-50-and-14-5mm', 'Heavy Machinegun (.50 and 14.5mm)', 'heroes-unlimited', 'weapon', 30, 5000, '$5000 and up (highly illegal)', '7D6 per round', 0, '3000ft', '.50 and 14.5mm belts of varying sizes', 'Commonly mounted on armored military vehicles and usually found only in military units. Accuracy is poor - they are meant for use against large vehicles or massed soldiers - but they punch through armor or engine blocks. Printed weight is a RANGE, 30 to 100lbs; the low end is stored.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('90mm-recoilless-rifle', '90mm Recoilless Rifle', 'heroes-unlimited', 'weapon', 35, 1600, 'highly illegal', '1D10x100', 0, '1200ft (400m)', 'Breech', 'Looks like a bazooka or rocket launcher and fires a single antitank round. Blast radius 80ft (24m). Rate of fire: (rapid) 10 rounds per minute to a maximum of 5, sustained 1 round per minute, with a 15 minute cooling period after every 5 rounds. Weight is unloaded.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('40mm-grenade-launcher-mounted-on-rifle', '40mm Grenade Launcher Mounted on Rifle', 'heroes-unlimited', 'weapon', 11, 1000, 'highly illegal', '1D4x100', 0, '1150ft (350m)', 'Single shot', 'Basically an M-79 installed under the barrel of an M-16 assault rifle. Length 15.6 inches (361mm). Blast radius 20ft (6.1m). Rate of fire 3-5 rounds per minute.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('rocket-launcher', 'Rocket Launcher', 'heroes-unlimited', 'weapon', 12, 900, 'mostly illegal', '1D4x100', 0, '3600ft (1200m)', NULL, 'Called the Super Bazooka, designed as an antitank weapon but sometimes used against bunkers. Length 61 inches (1549mm). Blast radius 50ft (15m). Printed weight is 12lbs (5.4kg) for the front and rear tubes plus 9lbs for the rocket; the tubes are stored.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('66mm-light-antitank-weapon-law', '66mm Light Antitank Weapon (LAW)', 'heroes-unlimited', 'weapon', 5.2, 1000, 'mostly illegal', '1D6x100', 0, '1000ft (325m)', 'Single shot and discard', 'Light and disposable, a favourite for taking out hardened positions where the enemy has metal or concrete protection. Against tanks it is less effective, killing only about 10% of the time. Size 35 inches (889mm) extended. Blast radius 50ft (15m).', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('tranquilizer-rifle', 'Tranquilizer Rifle', 'heroes-unlimited', 'weapon', NULL, 1000, NULL, 'Renders its victim unconscious within 1D4 melees; effects last 4D4 minutes. Saving throw vs toxin', 0, '800ft (240m)', 'Hand loaded, maximum capacity two', 'Effective range is about half that of a normal rifle. Both darts can be fired per melee and require the following melee as reload time. Rate of fire 2 per melee. Requires W.P. Rifle.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('dart-gun', 'Dart Gun', 'heroes-unlimited', 'weapon', NULL, 500, NULL, 'Renders victim unconscious; effects last 4D4 minutes. Saving throw vs toxin', 0, '110ft (33.5m)', NULL, 'Rate of fire 2 per melee. Requires a W.P. with Pistol or Revolver.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('tranquilizer-darts', 'Tranquilizer Darts', 'heroes-unlimited', 'gear', NULL, 10, '$10.00 each', NULL, 0, NULL, NULL, 'Printed 207 prices darts separately from both the Tranquilizer Rifle and the Dart Gun, at the same figure for each.', 'Revised Heroes Unlimited p.207');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('gas-gun-pistol', 'Gas Gun (pistol)', 'heroes-unlimited', 'weapon', NULL, 200, NULL, 'Varies with the type of gas used', 0, '160ft (48.8m)', 'One gas canister', 'A long, wide, tubular barrelled handgun that fires a gas canister. Rate of fire 1 per melee. Requires a W.P. with Pistol. The four canister types are priced separately and are their own rows.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('tear-gas-canister-gas-gun', 'Tear Gas Canister (gas gun)', 'heroes-unlimited', 'gear', NULL, 50, '$50.00', NULL, 0, NULL, NULL, 'For the Gas Gun on printed 208, which prices tear gas and tranquilizer canisters together at $50.00. NOT the same item as the Tear Gas grenade on printed 210, which is $40.00 each.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('tranquilizer-gas-canister-gas-gun', 'Tranquilizer Gas Canister (gas gun)', 'heroes-unlimited', 'gear', NULL, 50, '$50.00', NULL, 0, NULL, NULL, 'For the Gas Gun on printed 208, priced with the tear gas canister at $50.00.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('nerve-gas-canister-gas-gun', 'Nerve Gas Canister (gas gun)', 'heroes-unlimited', 'gear', NULL, 75, '$75.00', NULL, 0, NULL, NULL, 'For the Gas Gun on printed 208. NOT the same item as the Nerve Gas on printed 210, which is $120.00 each.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('smoke-gas-canister-gas-gun', 'Smoke Gas Canister (gas gun)', 'heroes-unlimited', 'gear', NULL, 25, '$25.00', NULL, 0, NULL, NULL, 'For the Gas Gun on printed 208.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('stun-gun-blaster', 'Stun Gun (blaster)', 'heroes-unlimited', 'weapon', NULL, 4000, NULL, 'Special - victims are dazed, -10 to strike, parry and dodge, for 2D4 melees. A successful save vs toxins means the person fought the effect off and is unimpaired; roll to save against each blast that strikes', 0, '100ft (30.5m)', '10 charges', 'A pistol that fires an energy charge which short circuits the nervous system. Rate of fire 5 per melee. Requires a W.P. with Energy Pistol.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('stun-gun-energy-clip', 'Stun Gun Energy Clip', 'heroes-unlimited', 'gear', NULL, 1000, NULL, NULL, 0, NULL, NULL, 'Printed 208 prices the stun gun''s energy clips separately from the gun.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('standard-laser-pistol', 'Standard Laser Pistol', 'heroes-unlimited', 'weapon', 1.5, 300000, NULL, '4D6 or 5D6', 0, '600ft (183m)', '10 blasts', 'Attacks per melee: up to four blasts. Energy weapons are highly experimental, rare and terribly expensive - printed 208 notes each is hand built, and that mass production would drop the cost to about 10% of it.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('standard-laser-pistol-energy-clip', 'Standard Laser Pistol Energy Clip', 'heroes-unlimited', 'gear', NULL, 25000, NULL, NULL, 0, NULL, NULL, 'Printed 208.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('standard-laser-pistol-with-energy-hip-pack', 'Standard Laser Pistol with Energy Hip-Pack', 'heroes-unlimited', 'weapon', 16, 180000, NULL, '4D6 or 5D6', 0, '300ft (91.5m)', '20 blasts', 'Printed 208 gives this as a Note under the Standard Laser Pistol: the same pistol with a 16lb (7.3kg) energy hip-pack, which SHORTENS the range to 300ft and limits the clip to 20. It is a separate row because it carries its own price.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('standard-laser-rifle', 'Standard Laser Rifle', 'heroes-unlimited', 'weapon', 7, 400000, NULL, '6D6', 0, '4000ft (1200m)', '20 blasts', 'Attacks per melee: four.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('standard-laser-rifle-energy-clip', 'Standard Laser Rifle Energy Clip', 'heroes-unlimited', 'gear', NULL, 25000, NULL, NULL, 0, NULL, NULL, 'Printed 208.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('heavy-laser-with-back-pack', 'Heavy Laser (with back-pack)', 'heroes-unlimited', 'weapon', 22, 1000000, '$1,000,000 for the whole unit', '6D6+10', 0, '2000ft (609.6m)', 'Energy back-pack capacity 100; requires 24 hours for the pack to regenerate', 'Attacks per melee: up to six blasts. Printed weight is 6lbs (2.7kg) for the gun and 16lbs (7.3kg) for the pack; 22 is the pair, because the price is for the whole unit and a character carries both.', 'Revised Heroes Unlimited p.208');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('mini-laser-tool', 'Mini-Laser (tool)', 'heroes-unlimited', 'weapon', 0.25, 300000, NULL, '1D6 or 2D6', 0, '300ft (90m)', '20 charges', 'A utility tool used by mechanics and communications engineers, slightly longer than a writing pen and twice as wide. Attacks per melee: two. Printed weight is 4 ounces (113.4gms). Short burst: 1D6 for one energy charge or 2D6 for two. Continual beam: 1D6 for two charges or 2D6 for three.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('mini-laser-energy-clip', 'Mini-Laser Energy Clip', 'heroes-unlimited', 'gear', NULL, 10000, NULL, NULL, 0, NULL, NULL, 'Printed 209.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('particle-beam-rifle', 'Particle Beam Rifle', 'heroes-unlimited', 'weapon', 12, 800000, NULL, '1D6x10 or 2D8x10', 0, '4000ft (1200m)', '10 blasts', 'Comes with an infrared telescopic targeting scope. Attacks per melee: two. PARTICLE BEAM WEAPONS HAVE THEIR OWN STRIKE RULE, printed 209: only a roll of 11 through 20 hits, and 11-17 is a nick doing 10 to 60 points; 18, 19 or 20 is a direct hit.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('particle-beam-rifle-energy-clip', 'Particle Beam Rifle Energy Clip', 'heroes-unlimited', 'gear', NULL, 30000, NULL, NULL, 0, NULL, NULL, 'Printed 209.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('simple-blaster-ion', 'Simple Blaster (Ion)', 'heroes-unlimited', 'weapon', 2, 200000, NULL, '2D6+2', 0, '400ft (122m)', '14 blasts', 'Attacks per melee: up to seven blasts.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('simple-blaster-energy-clip', 'Simple Blaster Energy Clip', 'heroes-unlimited', 'gear', NULL, 20000, NULL, NULL, 0, NULL, NULL, 'Printed 209.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('heavy-ion-blaster', 'Heavy Ion Blaster', 'heroes-unlimited', 'weapon', 2, 250000, NULL, '4D6', 0, '200ft (61m)', '10 blasts', 'Attacks per melee: up to four blasts.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('heavy-ion-blaster-energy-clip', 'Heavy Ion Blaster Energy Clip', 'heroes-unlimited', 'gear', NULL, 20000, NULL, NULL, 0, NULL, NULL, 'Printed 209.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('m-2a1-7-portable-flamethrower', 'M-2A1-7 Portable Flamethrower', 'heroes-unlimited', 'weapon', 42.5, 400, 'mostly illegal', '5D10, plus ignition of all combustible material', 0, '70ft (20m) unthickened; 150ft (45m) thickened', 'Manual', 'With a solid stream of fire a soldier could clear an entire machinegun nest. In confined spaces everyone in the target area is affected equally. Only 1 shot per combat round with incendiaries.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('an-m14-th3-incendiary-hand-grenade', 'AN-M14 TH3 Incendiary Hand Grenade', 'heroes-unlimited', 'weapon', 1.5, 30, NULL, 'Up to 12ft from impact 1D100+20 S.D.C. or 1 M.D.C.; 12-24ft away 1D100; 24-36ft away 3D10; 36-120ft away 1D10. Burns for 10 melee rounds', 0, NULL, NULL, 'One of the most dangerous weapons and not just for the enemy: it is difficult or impossible to throw far enough to avoid the fragments. Time delay fuse 4-5 seconds. Effective casualty radius lethal to 60ft (18m), dangerous to 120ft (36m). Printed weight 24 ounces. THE M.D.C. FIGURE IS ONE OF ONLY TWO IN THIS BOOK and is an equivalence beside an S.D.C. number, not a mega-damage rule; is_mega_damage stays 0.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('molotov-cocktail', 'Molotov Cocktail', 'heroes-unlimited', 'weapon', NULL, NULL, 'NO PRICE IS PRINTED. The entry gives a thrown range and damage and stops, which is the finished state for this row rather than a gap', 'Up to a 12ft area - 3D6. Burns for 4 melee rounds', 0, '30ft (9m) thrown', NULL, 'Printed 209.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('flare-gun', 'Flare Gun', 'heroes-unlimited', 'weapon', 2, 200, '$200 for the gun only; wide availability', '2D6 per melee ignited (5 melees)', 0, '300ft (91.5m)', NULL, 'Attacks per melee: two. Generally used as a signal or to light an area - used for luminescence it lights a 300ft (90m) area for about five melees (75 seconds). NOT intended as a weapon and not balanced for aiming, so W.P. handgun bonuses do NOT apply.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('flare-gun-flares', 'Flare Gun Flares', 'heroes-unlimited', 'gear', NULL, 10, '$10 each', NULL, 0, NULL, NULL, 'Printed 209 prices the flares separately from the gun.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('hand-held-flares', 'Hand-Held Flares', 'heroes-unlimited', 'gear', 0.375, 3, '$3 each; wide availability', 'One point', 0, 'Hand held', NULL, 'Attacks per melee equal to hand to hand attacks. Printed weight 6 ounces (170gms). Generally used to mark an area or for signalling, similar to those used by present day truck drivers.', 'Revised Heroes Unlimited p.209');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('rocket-flare', 'Rocket Flare', 'heroes-unlimited', 'weapon', 0.3, 10, '$10 each; wide availability', '2D6', 0, '300ft (90m) straight up', 'One', 'A hand-held flare with a disposable one-time launch mechanism. Commonly used for expeditions in the wild. A -3 to strike penalty applies if used as a weapon. Printed weight 5 ounces (141gms).', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('rocket-parachute-flare', 'Rocket Parachute Flare', 'heroes-unlimited', 'gear', NULL, 10, '$10 per flare', NULL, 0, NULL, NULL, 'A signal flare fired from a single hand launch tube or flare gun, deploying a parachute-supported star. No visible rocket trail gives away the firer''s position. Maximum height 1000ft (305m), 30 seconds of illumination, 200,000 candela. Available in white, red, green and yellow.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('rocket-parachute-flare-launcher', 'Rocket Parachute Flare Launcher', 'heroes-unlimited', 'gear', NULL, 300, '$300 for the launcher', NULL, 0, NULL, NULL, 'Printed 210 prices the launcher separately from the flares.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('distress-signal-kit', 'Distress Signal Kit', 'heroes-unlimited', 'gear', NULL, 120, NULL, NULL, 0, NULL, NULL, 'A tube launcher and six red flares. Maximum height 900ft (275m), 30 seconds of illumination, 10,000 candela.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('mini-signal-cartridges', 'Mini Signal Cartridges', 'heroes-unlimited', 'gear', NULL, 250, NULL, NULL, 0, NULL, NULL, 'A lightweight signal cartridge designed for military special forces, fired from a single-handed pen-type launcher. Maximum height 320ft (98m), 10 seconds of illumination, 150,000 candela. Green, red or white.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('tear-gas', 'Tear Gas', 'heroes-unlimited', 'gear', NULL, 40, '$40.00 each', 'None; victims are -6 to strike, parry and dodge and lose any chance for initiative', 0, NULL, NULL, 'A potent irritant that temporarily impairs vision and respiration. Effects are immediate. NO saving throw, but gas masks counter it effectively. NOT the same item as the Tear Gas Canister for the gas gun on printed 208, which is $50.00.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('knockout-gas', 'Knockout Gas', 'heroes-unlimited', 'gear', NULL, 60, '$60.00 each', 'None; induces drowsiness within 1D4 melees and sleep within 1D4 minutes', 0, NULL, NULL, 'Anesthesia-type tranquilizer mists. A successful save vs toxins fights off the effects, but the player rolls once for every minute of exposure. Gas masks counter it effectively.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('nerve-gas-paralysis', 'Nerve Gas (paralysis)', 'heroes-unlimited', 'gear', NULL, 120, '$120.00 each', 'None; causes paralysis, taking effect within 2D4 melees', 0, NULL, NULL, 'Attacks the nervous system. A successful save vs toxins fights off the effects; roll for each minute exposed. GAS MASKS ARE USELESS against most nerve agents - only an Atropine Injector negates it.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('atropine-injector', 'Atropine Injector', 'heroes-unlimited', 'gear', NULL, 400, '$400.00 per dosage', NULL, 0, NULL, NULL, 'An anti-nerve gas agent. One injector is needed for every ten minutes of exposure and must be administered immediately.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('explosive-grenade-hu', 'Explosive Grenade', 'heroes-unlimited', 'weapon', 0.625, 60, '$60 each on the black-market chart on printed 210, which lists it as Hand Grenades, 30% availability', '2D4x10', 0, '100ft (30m)', NULL, 'Effective casualty radius 20ft. Printed weight 10 ounces (283 grams). Illegal. Its own entry says only ''Cost: See Explosives Chart below'', so the price comes from that chart.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('smoke-grenade-hu', 'Smoke Grenade', 'heroes-unlimited', 'weapon', 0.625, 30, '$30 each on the black-market chart on printed 210, 40% availability', 'None; creates a smoke filled area for cover or as a signal', 0, '100ft', NULL, 'Opponents cannot see into or through the smoke and are -6 to strike. Effective casualty radius 20ft. Colors: black, grey, red, yellow. Printed weight 10 ounces (283 grams).', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('rifle-launcher-grenades', 'Rifle Launcher Grenades', 'heroes-unlimited', 'weapon', NULL, 80, '$80 each on the black-market chart on printed 210, which lists it as Rifle Launched Grenades, 20% availability', '2D4x10 to a 20ft area', 0, '1150ft (350m)', 'Single shot', 'Explosive or smoke grenades fired from an assault rifle; the damage and effects of the grenade itself apply.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('dynamite', 'Dynamite', 'heroes-unlimited', 'gear', NULL, 30, '$30 per stick; 45% black-market availability', 'One stick: 1D4x10. Effective casualty radius 10ft (3m)', 0, NULL, NULL, 'A nitroglycerin based explosive widely used in mining and road construction, detonated with blasting caps, fuses and timing devices. Wick fuses are rarely used today.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('detonation-caps-fuses', 'Detonation Caps/Fuses', 'heroes-unlimited', 'gear', NULL, 30, '$30 each; 32% black-market availability', NULL, 0, NULL, NULL, 'An electrical blasting cap is the only thing that sets off plastic and gelatin explosives.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('plastic-explosive', 'Plastic Explosive', 'heroes-unlimited', 'gear', NULL, 100, '$100 per each 2oz; 19% black-market availability', '2 ounces is equal to one stick of dynamite: 1D4x10. The blast is where the plastic was placed, about one foot', 0, NULL, NULL, 'A localized blast explosive that can be moulded like putty. INERT until an electrical blasting cap passes a charge through it - slamming it into a wall does nothing - but any electrical charge, blast or bolt is 55% likely to detonate it. Used to open safes and for sabotage; NOT an effective area effect weapon.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('gelatin-explosive', 'Gelatin Explosive', 'heroes-unlimited', 'gear', NULL, 140, '$140 per ounce; 18% black-market availability', 'As plastic explosive: 2 ounces equal one stick of dynamite, 1D4x10, in about a one foot area', 0, NULL, NULL, 'Printed 211 describes plastic and gelatin explosives together and gives them the same behaviour; only the price differs.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('liquid-nitroglycerin', 'Liquid Nitroglycerin', 'heroes-unlimited', 'gear', NULL, 200, '$200 per ounce; 20% black-market availability', 'One ounce is equal to four sticks of dynamite: 4D4x10. Effective casualty radius 20ft (6.1m)', 0, NULL, NULL, 'An extremely dangerous, unstable chemical concentrate. A severe jar, jerk or bump detonates it: 30% chance.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('mortar-shells', 'Mortar Shells', 'heroes-unlimited', 'gear', NULL, 100, '$100 each; 10% black-market availability', NULL, 0, NULL, NULL, 'Priced on the black-market chart on printed 210. No damage figure is printed for them there.', 'Revised Heroes Unlimited p.210');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('black-jack-modern', 'Black Jack (modern)', 'heroes-unlimited', 'weapon', 3, 20, NULL, '1D6', 0, NULL, NULL, 'A small hand held club, usually handmade, 10 inches long, weighing 2 to 4 pounds. THE BOOK PRINTS A SECOND, DIFFERENT BLACK JACK on printed 194 among the ancient miscellaneous weapons, at $10 and 1-4. Two entries, one name; the qualifier is added here and the book prints the bare name.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('brass-knuckles', 'Brass Knuckles', 'heroes-unlimited', 'weapon', NULL, 20, NULL, '1D6', 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('cattle-prod', 'Cattle Prod', 'heroes-unlimited', 'weapon', NULL, 20, NULL, '1D4', 0, NULL, NULL, 'An electric rod on C cell batteries emitting a 4500 volt shock when touched to the skin. 12 or 22 inch lengths.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('itching-powder', 'Itching Powder', 'heroes-unlimited', 'gear', NULL, NULL, 'NO FIRM PRICE IS PRINTED - the book says only a couple of bucks per ounce from a novelty shop, which is not a figure this column can hold', 'None; victims are very uncomfortable, distracted and -3 on initiative for 1D4 hours or until washed off', 0, 'Varies with the application', NULL, 'Can be used as a powder, launched in a grenade, housed in a pellet that ruptures on impact, and similar devices. Affects only bare skin.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('hair-spray', 'Hair Spray', 'heroes-unlimited', 'gear', NULL, 3, NULL, 'None; victims are -6 to strike, parry and dodge for 1D4 melees', 0, '3ft (.9m)', NULL, 'Can be used to temporarily blind an opponent.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('mace-chemical-spray', 'Mace (chemical spray)', 'heroes-unlimited', 'weapon', NULL, 16, '$16.00, with about 20 sprays before empty', 'None; victims are -6 to strike, parry and dodge for 4D4 melees', 0, '4 to 6ft (1.2 to 1.8m)', NULL, 'A stinging chemical spray that blinds an opponent, much better than hair spray. THE BOOK PRINTS A SECOND, DIFFERENT MACE on printed 194 among the blunt weapons, at $240 and 1-8. The qualifier is added here; the book prints the bare name.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('modern-crossbow-hu', 'Modern Crossbow', 'heroes-unlimited', 'weapon', NULL, 180, NULL, '2D6', 0, '500ft (150m)', '150lb draw weight', 'With a rifle stock.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('slap-glove', 'Slap Glove', 'heroes-unlimited', 'weapon', NULL, 30, NULL, '+2 to damage', 0, NULL, NULL, 'Six ounces of powdered lead built into each glove just above the knuckles, padding the wearer and adding weight to one blow. Available from most security guard suppliers.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('fiberglass-nightstick', 'Fiberglass Nightstick', 'heroes-unlimited', 'weapon', NULL, 10, NULL, '1D4', 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('steel-rod-encased-nightstick', 'Steel Rod Encased Nightstick', 'heroes-unlimited', 'weapon', NULL, 20, NULL, '1D6', 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('s-w-a-t-entry-tool-hooligan-tool', 'S.W.A.T. Entry Tool (Hooligan Tool)', 'heroes-unlimited', 'weapon', NULL, 240, NULL, '1D8 (either end)', 0, NULL, NULL, 'A long, one inch thick stress proof bar, heat treated for durability. One end is a large chisel-like pry bar, the other a claw/chisel crowbar point. Pops normal door locks on a roll to strike of 8-20 and heavy or security door locks on 12-20.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('combat-bush-knife', 'Combat Bush Knife', 'heroes-unlimited', 'weapon', NULL, 200, NULL, '1D6', 0, NULL, NULL, 'A heavy-duty all-purpose survival knife with the best carbon steel 7in blade.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('slimpack-throwing-knife', 'Slimpack Throwing Knife', 'heroes-unlimited', 'weapon', NULL, 50, NULL, '1D6', 0, NULL, NULL, 'A perfectly balanced 6in blade with a flat lambskin sheath, perfect for concealment.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('belt-throwing-knife-set', 'Belt Throwing Knife Set', 'heroes-unlimited', 'weapon', NULL, 135, NULL, '1D6', 0, NULL, NULL, 'Four ultrathin throwing knives in a single belt sheath designed for an easy, fast draw.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('polycarbonate-knife', 'Polycarbonate Knife', 'heroes-unlimited', 'weapon', NULL, 300, NULL, '1D6', 0, NULL, NULL, 'A 7in knife with a silk sheath, guaranteed not to show up on metal detectors. Balanced for throwing with a keen edge for slicing.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('small-boot-knife', 'Small Boot Knife', 'heroes-unlimited', 'weapon', NULL, 20, NULL, '1D4', 0, NULL, NULL, 'For easy concealment.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('bayonet', 'Bayonet', 'heroes-unlimited', 'weapon', NULL, 140, NULL, '1D6', 0, NULL, NULL, 'Attaches to combat rifles.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('slr-60-spike-launch-rod', 'SLR-60/Spike Launch Rod', 'heroes-unlimited', 'gear', 2, 1200, NULL, '2D6', 0, '200ft (60m)', '30 charges', 'A 2ft (.6m) rod-like device used for climbing: it fires a 6 inch metal spike up to 60 meters carrying a high test line for scaling surfaces. Comes with 130 meters of heavy-duty cord, a detachable spool and a feeder with digital counter. Attacks per melee: one.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('slr-60-spikes', 'SLR-60 Spikes', 'heroes-unlimited', 'gear', NULL, 30, '$30 a dozen', NULL, 0, NULL, NULL, 'Additional spikes for the SLR-60.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('slr-60-line-spool', 'SLR-60 Line Spool', 'heroes-unlimited', 'gear', NULL, 200, '$200 each', NULL, 0, NULL, NULL, 'An additional clip-in, prewound spool of 400ft (130m) line for the SLR-60.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('grappling-hook-line', 'Grappling Hook & Line', 'heroes-unlimited', 'gear', 2, 150, '$150 for hook and 300ft of line', '1D4', 0, '100ft (30.5m)', NULL, 'A typical grappling hook and line for scaling surfaces. Attacks per melee equal to hand to hand attacks.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('ankle-holster', 'Ankle Holster', 'heroes-unlimited', 'gear', NULL, 34, NULL, NULL, 0, NULL, NULL, 'Padded for comfort with a velcro closure. Fits a snub-nosed revolver or any small frame automatic, and conceals under a pant leg.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('inside-trouser-holster', 'Inside Trouser Holster', 'heroes-unlimited', 'gear', NULL, 20, NULL, NULL, 0, NULL, NULL, 'Clips on the belt or waistband.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('side-holster', 'Side Holster', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, NULL, NULL, 'Fits onto a belt.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('belt-slide-holster', 'Belt Slide Holster', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('belt-thumbreak-holster', 'Belt Thumbreak Holster', 'heroes-unlimited', 'gear', NULL, 50, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('patrolman-police-style-belt-and-holster', 'Patrolman, Police-Style Belt and Holster', 'heroes-unlimited', 'gear', NULL, 80, NULL, NULL, 0, NULL, NULL, 'With 24 bullet loops.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('police-style-shoulder-holster', 'Police-style Shoulder Holster', 'heroes-unlimited', 'gear', NULL, 80, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('military-style-shoulder-holster', 'Military-style Shoulder Holster', 'heroes-unlimited', 'gear', NULL, 70, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('horizontal-shoulder-holster', 'Horizontal Shoulder Holster', 'heroes-unlimited', 'gear', NULL, 85, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('scoped-shoulder-holster', 'Scoped Shoulder Holster', 'heroes-unlimited', 'gear', NULL, 90, NULL, NULL, 0, NULL, NULL, 'Printed 211.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('concealed-wallet-holster', 'Concealed Wallet Holster', 'heroes-unlimited', 'gear', NULL, 40, NULL, NULL, 0, NULL, NULL, 'For small automatic weapons; fits easily into a back trouser pocket.', 'Revised Heroes Unlimited p.211');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, description, source_book)
VALUES ('web-belt-with-holster', 'Web Belt with Holster', 'heroes-unlimited', 'gear', NULL, 60, NULL, NULL, 0, NULL, NULL, 'With a holster, two ammo pouches and four accessory attachment clips.', 'Revised Heroes Unlimited p.211');

-- ASSERTIONS.

SELECT 'all eighty-seven rows landed' AS assertion, count(*) AS got, 87 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.207',
    'Revised Heroes Unlimited p.208', 'Revised Heroes Unlimited p.209',
    'Revised Heroes Unlimited p.210', 'Revised Heroes Unlimited p.211');

-- Per page, so a whole section going missing cannot hide inside the total.
SELECT 'nine from printed 207' AS assertion, count(*) AS got, 9 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.207';
SELECT 'thirteen from printed 208' AS assertion, count(*) AS got, 13 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.208';
SELECT 'fourteen from printed 209' AS assertion, count(*) AS got, 14 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.209';
SELECT 'eighteen from printed 210' AS assertion, count(*) AS got, 18 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.210';
SELECT 'thirty-three from printed 211' AS assertion, count(*) AS got, 33 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.211';

SELECT 'every one is Heroes Unlimited' AS assertion, count(*) AS got, 87 AS want
  FROM gear WHERE source_book LIKE 'Revised Heroes Unlimited p.2%'
   AND source_book NOT LIKE '%201-206%' AND system = 'heroes-unlimited';

SELECT 'none is mega-damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book LIKE 'Revised Heroes Unlimited p.2%'
   AND source_book NOT LIKE '%201-206%' AND is_mega_damage = 1;

-- EXACTLY TWO rows have no price, and they are the two the book leaves unpriced
-- for two different reasons.
SELECT 'exactly two rows have no cost' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.209', 'Revised Heroes Unlimited p.211')
   AND cost IS NULL;
SELECT 'and both carry a cost_note saying why' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Molotov Cocktail', 'Itching Powder')
   AND cost IS NULL AND cost_note IS NOT NULL;

-- THE TWO NAMES THE BOOK USES TWICE. Four rows, two prices each, and the
-- printed-194 originals must be untouched.
SELECT 'both Black Jacks exist and differ' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Black Jack', 'Black Jack (modern)') AND cost IN (10, 20);
SELECT 'both Maces exist and differ' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Mace', 'Mace (chemical spray)') AND cost IN (240, 16);

-- THE GAS COLLISION. The gas-gun canister and the grenade are different items
-- at different prices, and both must survive.
SELECT 'tear gas exists at both its prices' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Tear Gas', 'Tear Gas Canister (gas gun)') AND cost IN (40, 50);
SELECT 'nerve gas exists at both its prices' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Nerve Gas (paralysis)', 'Nerve Gas Canister (gas gun)') AND cost IN (120, 75);

-- THE CHART. Its six chart-only rows, and the three headed rows that take their
-- price from it.
SELECT 'the six chart-only explosives landed' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Dynamite', 'Detonation Caps/Fuses', 'Plastic Explosive',
                'Gelatin Explosive', 'Liquid Nitroglycerin', 'Mortar Shells');
SELECT 'the three grenades took the chart price' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Explosive Grenade', 'Smoke Grenade', 'Rifle Launcher Grenades')
   AND cost IN (60, 30, 80);

-- TEXT CHECKS, because the previous batch passed every count while every string
-- in it was mangled. These are strings the broken fold would have eaten.
SELECT 'the nitroglycerin description survived' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Liquid Nitroglycerin'
   AND instr(description, 'unstable chemical concentrate') > 0;
SELECT 'and the flamethrower kept its s letters' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'M-2A1-7 Portable Flamethrower'
   AND instr(description, 'machinegun nest') > 0
   AND instr(damage, 'combustible material') > 0;

-- The twelve firearm accessories, which are the easiest rows to lose because
-- they are one line each with no stat block.
SELECT 'all twelve firearm accessories landed' AS assertion, count(*) AS got, 12 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.211'
   AND category = 'gear' AND instr(name, 'Holster') + instr(name, 'Web Belt') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-d-heavy-and-accessories.sql');
