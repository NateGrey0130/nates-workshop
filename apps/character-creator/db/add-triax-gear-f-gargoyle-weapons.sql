-- The gargoyle and Kittani weapons of printed 210-214. Fourteen rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-f-gargoyle-weapons.sql
--
-- THREE ROWS HAVE NO PRICE, OR AN INCOMPLETE STAT BLOCK, AND SAY SO. The
-- Blaster Neural Whip prints only its damage - no weight, range, payload, rate
-- of fire or cost, where every other entry in the range gives them. The Wing
-- and Tail Blades are fitted to the creature rather than sold. Both carry a
-- NULL cost with a cost_note explaining, which is the convention for the rows
-- already on the "gear with no price" backlog. The Kittani Laser Wrist Blasters
-- are priced but print no weight.
--
-- THE KITTANI ENERGY LANCE CONTRADICTS ITSELF: printed 214 says "fair
-- availability" beside its payload and "poor availability" beside its price,
-- two lines apart. Both are in the cost_note. The book prints both; nothing
-- here chooses between them.
--
-- NOT IMPORTED, and each for a stated reason: the "Triax Electro-Mace & Neural
-- Mace" on printed 212 is a bare cross-reference to the Triax weapon section
-- with no stats on the page - the Electro-Mace is imported from printed 150 in
-- batch C, and the catalog already holds a Neural Mace. The G-10, G-11, G-20,
-- G-30 and G-40 machines on printed 205-209 are vessels with M.D.C. BY LOCATION
-- and several numbered weapon systems, which is the BOOK-INGEST-AUDIT.md F3
-- shape this catalog has no room for; the one worn suit from that section, the
-- Gargoyle Body Armor, is in batch A.
--
-- Sorts after add-triax-gear-e-cybernetics.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('blaster-knuckle-spikes', 'Blaster Knuckle Spikes', 'rifts', 'weapon', 5, 15000, '15,000 credits; fair availability', 'Switched off: 1D4 M.D. plus P.S. bonus, or 1D6 M.D. from the spike. Switched on: 2D4 M.D. plus P.S. bonus, or 2D6 M.D. from the spike', 1, 'Arm reach', '32 blasts or jolts; recharges in two hours', 'Hand to hand punches', NULL, NULL, NULL, 'Spiked knuckle guards that carry an energy charge, used by gargoyle warriors.', 'Rifts World Book 5: Triax and the NGR p.210-211'),
('blaster-neural-whip', 'Blaster Neural Whip', 'rifts', 'weapon', NULL, NULL, 'The book prints no weight, range, payload, rate of fire or cost for this weapon - only its damage and stun effect', '2D4 M.D. plus supernatural strength', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'A gargoyle neural whip. Its entry is the one weapon in this section the book leaves almost entirely unstatted.', 'Rifts World Book 5: Triax and the NGR p.211'),
('gargoyle-wing-tail-blades', 'Wing and Tail Blades', 'rifts', 'weapon', NULL, NULL, 'No price is printed. These are fitted to the creature rather than sold as a weapon', 'Ordinary blades add 1D6 M.D. to strength damage; vibro-blade versions add 2D6 M.D.', 1, 'A wing rake or tail whip', NULL, NULL, NULL, NULL, NULL, 'Blades mounted on a gargoyle''s wings and tail, turning a wing rake or a tail whip into a cutting attack.', 'Rifts World Book 5: Triax and the NGR p.211'),
('gargoyle-firebrand-spear', 'Gargoyle Firebrand Spear', 'rifts', 'weapon', 15, 75000, '75,000 to 100,000 credits; no availability wording printed', 'Uncharged 2D6 M.D. plus P.S. bonus, or 1D6 M.D. in the human-size version. Charged as a firebrand: 5D6 M.D. plus P.S. bonus', 1, 'Hand to hand, or thrown 500 feet (153 m) - 200 feet (61 m) for a human-thrown human-size spear', 'Depends on the P.P.E. or I.S.P. of the wielder: 15 I.S.P. or 7 P.P.E. per strike', 'Equal to the attacks per melee of the warrior', NULL, NULL, NULL, 'A spear a gargoyle charges from its own psychic or magical energy. The giant version weighs 15 lbs (6.8 kg); a human-size version exists and does less damage.', 'Rifts World Book 5: Triax and the NGR p.212'),
('gargoyle-grenade-mace', 'Gargoyle Grenade Mace', 'rifts', 'weapon', 25, 20000, '20,000 credits for the weapon and 200 credits per grenade; fair availability', 'Mace or axe head 1D6 M.D. plus P.S. bonus; grenade 5D6 M.D. over a 20 foot (6 m) radius', 1, '400 feet (122 m) for the grenade', 'Six grenades, reloaded in one melee round', 'One grenade per melee action', NULL, NULL, NULL, 'A giant mace with a grenade launcher built into the haft.', 'Rifts World Book 5: Triax and the NGR p.212'),
('wr-12-giant-ion-pistol', 'WR-12 Giant Ion Pistol', 'rifts', 'weapon', 10, 10000, '10,000 credits; fair availability', '2D6 M.D.', 1, '600 feet (183 m)', '30 shots per E-clip', 'Standard, see the Modern Weapon Proficiency section', NULL, NULL, NULL, 'A giant-size ion pistol, sized for gargoyle and gurgoyle hands.', 'Rifts World Book 5: Triax and the NGR p.212'),
('gargoyle-laser-mace', 'Gargoyle Laser Mace', 'rifts', 'weapon', 20, 25000, '25,000 credits; fair availability', 'Mace or axe head 1D6 M.D. plus P.S. bonus; laser 3D6 M.D. per shot', 1, '800 feet (244 m)', '20 shots from a forward sliding energy clip, or 10 from a short clip', 'Standard, see the Modern Weapon Proficiency section', NULL, NULL, NULL, 'A giant mace with a laser built into the haft.', 'Rifts World Book 5: Triax and the NGR p.212'),
('super-eight-pistol-mace', 'Super-Eight Pistol Mace', 'rifts', 'weapon', 25, 15000, '15,000 credits, plus 100 credits for a box of 48 rounds; fair availability', 'Mace head 1D6 M.D. plus P.S. bonus; bullets 1D4 M.D. per shot, 4D4 M.D. for a short burst of four, or 5D6 M.D. for a full burst of eight', 1, '800 feet (244 m)', '48 shots, or six full bursts', 'Standard, see the Modern Weapon Proficiency section', NULL, NULL, NULL, 'A giant mace with an eight-barrelled pistol in the haft.', 'Rifts World Book 5: Triax and the NGR p.213'),
('wr-100-giant-laser-rifle', 'WR-100 Giant Laser Rifle', 'rifts', 'weapon', 20, 25000, '25,000 credits; fair availability', '3D6 M.D. per blast', 1, '1600 feet (488 m)', '20 shots per E-clip', 'Standard, see the Modern Weapon Proficiency section', NULL, NULL, NULL, 'A giant-size laser rifle for gargoyle and gurgoyle troops.', 'Rifts World Book 5: Triax and the NGR p.213'),
('wr-200-giant-rail-gun', 'WR-200 Giant Rail Gun', 'rifts', 'weapon', 250, 65000, '65,000 credits; good availability', 'Full burst of 30 rounds 1D4x10 M.D.; short burst of 15 rounds 3D6 M.D.', 1, '6000 feet (1828 m)', 'Short clip 300 rounds (10 full bursts); drum 3000 rounds (100 full bursts)', 'Equal to the combined hand to hand attacks of the user, usually four to eight', NULL, NULL, NULL, 'A giant rail gun. The ammunition drum weighs as much as the gun again, 250 lbs. Not to be confused with the catalog''s NE-200 Plasma Cartridge Machinegun, which is a different weapon from another book.', 'Rifts World Book 5: Triax and the NGR p.213'),
('kittani-laser-wrist-blasters', 'Kittani Laser Wrist Blasters', 'rifts', 'weapon', NULL, 22000, '22,000 credits; poor availability. The book prints no weight', '2D6 M.D.', 1, '1200 feet (366 m)', '60 blasts; recharges in four hours', 'Up to five blasts per melee round', NULL, NULL, NULL, 'Kittani wrist-mounted laser blasters, sold to the Gargoyle Empire by the Splugorth.', 'Rifts World Book 5: Triax and the NGR p.213'),
('kittani-double-blade-plasma-axe', 'Kittani Double Blade Plasma Axe', 'rifts', 'weapon', 10, 32000, '32,000 credits human-size or 45,000 credits giant-size; good availability. The stored cost is the human-size version', 'Human-size 3D6 M.D. per axe blow or 6D6 M.D. per plasma blast, and 3D6 S.D.C. unenergized. Giant-size 1D4x10 M.D. for both the blow and the blast, and 3D6 S.D.C. unenergized', 1, 'Close combat, or 100 feet (30.5 m) for the plasma blast', 'Sixty minutes or less per clip, and a maximum of six plasma blasts', 'Equal to the hand to hand attacks of the user, usually four to six', NULL, NULL, NULL, 'A Kittani double-bladed axe that can also throw a plasma blast.', 'Rifts World Book 5: Triax and the NGR p.214'),
('kittani-plasma-sword', 'Kittani Plasma Sword', 'rifts', 'weapon', 3, 28000, '28,000 credits; good availability', '2D6 M.D. per strike or 4D6 M.D. per plasma blast, and 2D6+2 S.D.C. unenergized', 1, 'Close combat, or 100 feet (30.5 m) for the plasma blast', 'Sixty minutes or less per clip, and a maximum of six plasma blasts', 'Equal to the hand to hand attacks of the user, usually four to six', NULL, NULL, NULL, 'A light Kittani energy sword that can also throw a plasma blast.', 'Rifts World Book 5: Triax and the NGR p.214'),
('kittani-energy-lance', 'Kittani Energy Lance', 'rifts', 'weapon', 20, 39000, 'Market price 39,000 credits. THE BOOK PRINTS TWO DIFFERENT AVAILABILITIES two lines apart - "fair availability" beside the payload and "poor availability" beside the price. Both are reproduced here rather than one being chosen', '3D6 M.D. per shot at long range, 6D6 M.D. at half range, or 2D4 M.D. used as a blunt or stabbing weapon', 1, '6000 feet (1828 m), or 3000 feet (915 m) at the harder-hitting setting', '40 shots; recharges in four hours', 'Equal to the combined hand to hand attacks of the user, usually four to six', NULL, NULL, NULL, 'A Kittani energy lance, usable as a ranged weapon or a polearm.', 'Rifts World Book 5: Triax and the NGR p.214');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 'kittani-%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-f-gargoyle-weapons.sql');
