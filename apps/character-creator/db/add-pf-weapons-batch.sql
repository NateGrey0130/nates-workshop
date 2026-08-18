-- Seventy-four weapon rows from the Palladium RPG Main Book weapons table,
-- p.270-271: axes, pole arms, spears, knives, swords, ball-and-chain, blunt
-- weapons, staves, missile weapons and the miscellaneous (no W.P. bonuses)
-- list. Extracted from page scans and spot-verified against full-resolution
-- crops of every ambiguous cell.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-pf-weapons-batch.sql
--
-- Three rows fill existing STUBs in place (same slug, so the upsert lands on
-- them): long-bow and short-sword, referenced by class markdown, and
-- arrows-standard, which the Long Bowman references and which therefore
-- takes the LONG bow arrows' price. Ammunition is category 'gear' matching
-- that stub; everything else is 'weapon'.
--
-- Transcription decisions, recorded so they are not re-litigated:
-- - Values are as printed, even where the book's own unit pairs disagree
--   (battle axe "2 kg/4.6lb"; guisarme "2.5m/7.25ft"). weight_lbs takes the
--   printed pound figure; oz rows are fractional (2 oz = .125).
-- - "Hammer (tool)" prints "1/4kg/3 lb" - a scan artifact of 1.4kg; stored 3.
-- - Arrows and bolts are priced BY THE DOZEN; cost holds the dozen price and
--   the description says so. Their damage is NULL - the bow's row carries it.
-- - Two "Beaked Axe" listings exist, one under POLE ARMS (7.5 ft) and one
--   under SPEARS (4.5 ft); the second is stored as "Beaked Axe (short)".
-- - The STAVES rows print bare "Short"/"Long"; stored "Staff, Short"/
--   "Staff, Long" so the names survive outside their section heading.
-- - Lance restriction kept as printed ("Palladin & Knights ONLY").
-- - Giant/gnome damage variants are page-level rules, not rows; not stored.
--
-- ON CONFLICT (slug) DO UPDATE, deliberately: re-running is repair, and the
-- stub fills depend on it. Pure ASCII on purpose - see PR #101's pre-flight.

INSERT INTO gear (slug, name, system, category, weight_lbs, cost, damage, description, source_book) VALUES
('axe-battle', 'Axe, Battle', 'palladium-fantasy', 'weapon', 4.6, 40, '3D6', 'Axe. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.270'),
('axe-throwing', 'Axe, Throwing', 'palladium-fantasy', 'weapon', 3, 8, '2D4', 'Axe. Average length .4m/1.25 ft.', 'Palladium RPG Main Book p.270'),
('axe-stone', 'Axe, Stone', 'palladium-fantasy', 'weapon', 4, 18, '2D6', 'Axe. Average length .6m/2 ft.', 'Palladium RPG Main Book p.270'),
('axe-bipennis', 'Axe, Bipennis (2-head)', 'palladium-fantasy', 'weapon', 6, 45, '2D6', 'Axe. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.270'),
('oncin-pick', 'Oncin Pick', 'palladium-fantasy', 'weapon', 4, 20, '2D4', 'Axe. Two-handed. Average length 1.0m/3.75 ft.', 'Palladium RPG Main Book p.270'),
('awl-pike', 'Awl Pike', 'palladium-fantasy', 'weapon', 6, 45, '2D6', 'Pole arm. Two-handed. Average length 3.2m/10 ft.', 'Palladium RPG Main Book p.270'),
('beaked-axe', 'Beaked Axe', 'palladium-fantasy', 'weapon', 5, 40, '2D6', 'Pole arm. Two-handed. Average length 2.3m/7.5 ft.', 'Palladium RPG Main Book p.270'),
('berdiche', 'Berdiche', 'palladium-fantasy', 'weapon', 7, 50, '3D6', 'Pole arm. Two-handed. Average length 2.1m/7 ft.', 'Palladium RPG Main Book p.270'),
('glaive', 'Glaive', 'palladium-fantasy', 'weapon', 6, 40, '2D6', 'Pole arm. Two-handed. Average length 2.3m/7.5 ft.', 'Palladium RPG Main Book p.270'),
('guisarme', 'Guisarme', 'palladium-fantasy', 'weapon', 6, 50, '2D6', 'Pole arm. Two-handed. Average length 2.5m/7.25 ft (as printed).', 'Palladium RPG Main Book p.270'),
('halberd', 'Halberd', 'palladium-fantasy', 'weapon', 5, 60, '3D6', 'Pole arm. Two-handed. Average length 2.2m/7.25 ft.', 'Palladium RPG Main Book p.270'),
('sabre-halberd', 'Sabre Halberd', 'palladium-fantasy', 'weapon', 7, 60, '3D6', 'Pole arm. Two-handed. Average length 2.4m/8 ft.', 'Palladium RPG Main Book p.270'),
('hippe', 'Hippe', 'palladium-fantasy', 'weapon', 6, 55, '3D6', 'Pole arm. Two-handed. Average length 2.3m/7.5 ft.', 'Palladium RPG Main Book p.270'),
('lucerne-hammer', 'Lucerne Hammer', 'palladium-fantasy', 'weapon', 6.5, 40, '3D6', 'Pole arm. Two-handed. Average length 2.9m/9.75 ft.', 'Palladium RPG Main Book p.270'),
('military-fork', 'Military Fork', 'palladium-fantasy', 'weapon', 5, 30, '2D4+2', 'Pole arm. Two-handed. Average length 2.1m/7 ft.', 'Palladium RPG Main Book p.270'),
('pike', 'Pike', 'palladium-fantasy', 'weapon', 8, 45, '2D6', 'Pole arm. Two-handed. Average length 5.0m/16 ft.', 'Palladium RPG Main Book p.270'),
('runka', 'Runka', 'palladium-fantasy', 'weapon', 6, 45, '2D6', 'Pole arm. Two-handed. Average length 2.3m/7.5 ft.', 'Palladium RPG Main Book p.270'),
('scythe', 'Scythe', 'palladium-fantasy', 'weapon', 5, 45, '3D6', 'Pole arm. Two-handed. Average length 2.4m/8 ft.', 'Palladium RPG Main Book p.270'),
('voulge', 'Voulge', 'palladium-fantasy', 'weapon', 5, 60, '4D6', 'Pole arm. Two-handed. Average length 2.1m/7 ft.', 'Palladium RPG Main Book p.270'),
('short-spear', 'Short Spear', 'palladium-fantasy', 'weapon', 4, 30, '1D6', 'Spear. Average length 1.2-1.8m/4-6 ft.', 'Palladium RPG Main Book p.270'),
('long-spear', 'Long Spear', 'palladium-fantasy', 'weapon', 6.5, 40, '2D6', 'Spear. Two-handed. Average length 2.1-3.0m/7-10 ft.', 'Palladium RPG Main Book p.270'),
('javelin', 'Javelin', 'palladium-fantasy', 'weapon', 4, 30, '2D4', 'Spear. Average length 2.1m/7 ft.', 'Palladium RPG Main Book p.270'),
('beaked-axe-short', 'Beaked Axe (short)', 'palladium-fantasy', 'weapon', 5, 30, '2D6', 'Spear-length listing of the Beaked Axe (the book carries both). Average length 1.4m/4.5 ft.', 'Palladium RPG Main Book p.270'),
('trident', 'Trident', 'palladium-fantasy', 'weapon', 4, 40, '2D6+2', 'Spear. Two-handed. Average length 1.5m/5 ft.', 'Palladium RPG Main Book p.270'),
('lance', 'Lance', 'palladium-fantasy', 'weapon', 8, 60, '2D6+2', 'Spear. Average length 4.0m/13 ft. "Palladin & Knights ONLY" as printed.', 'Palladium RPG Main Book p.270'),
('daggers-and-knives', 'Daggers and Knives', 'palladium-fantasy', 'weapon', 1, 10, '1D6', 'Knife. Average length .2-.5m/10-20 in.', 'Palladium RPG Main Book p.270'),
('short-sword', 'Short Sword', 'palladium-fantasy', 'weapon', 3, 40, '2D4', 'Short sword. Average length .7m/2.5 ft.', 'Palladium RPG Main Book p.271'),
('sabre', 'Sabre', 'palladium-fantasy', 'weapon', 3, 30, '2D4', 'Short sword. Average length .6m/2 ft.', 'Palladium RPG Main Book p.271'),
('scimitar', 'Scimitar', 'palladium-fantasy', 'weapon', 3.5, 35, '2D6', 'Short sword. Average length .7m/2.5 ft.', 'Palladium RPG Main Book p.271'),
('falchion', 'Falchion', 'palladium-fantasy', 'weapon', 4, 50, '2D6', 'Short sword. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('cutlass', 'Cutlass', 'palladium-fantasy', 'weapon', 3, 35, '2D4', 'Short sword. Average length .6m/2 ft.', 'Palladium RPG Main Book p.271'),
('bastard-sword', 'Bastard', 'palladium-fantasy', 'weapon', 4.5, 50, '2D6+2', 'Large sword. Two-handed. Average length 1.0m/3.75 ft.', 'Palladium RPG Main Book p.271'),
('broadsword', 'Broadsword', 'palladium-fantasy', 'weapon', 3.5, 40, '2D4+1', 'Large sword. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('claymore', 'Claymore', 'palladium-fantasy', 'weapon', 6.5, 60, '3D6', 'Large sword. Two-handed. Average length 1.2m/4 ft.', 'Palladium RPG Main Book p.271'),
('flamberge', 'Flamberge', 'palladium-fantasy', 'weapon', 7.5, 70, '3D6', 'Large sword. Two-handed. Average length 1.3m/4.25 ft.', 'Palladium RPG Main Book p.271'),
('long-sword', 'Long Sword', 'palladium-fantasy', 'weapon', 3.5, 55, '2D6', 'Large sword. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('espandon', '2-Handed Espandon', 'palladium-fantasy', 'weapon', 4.5, 60, '2D6+2', 'Large sword. Two-handed. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('ball-and-chain', 'Ball and Chain', 'palladium-fantasy', 'weapon', 4.5, 50, '2D4', 'Ball and chain. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('flail', 'Flail', 'palladium-fantasy', 'weapon', 5.5, 55, '2D6', 'Ball and chain. Two-handed. Average length 1.6m/5.25 ft.', 'Palladium RPG Main Book p.271'),
('goupillon-flail', 'Goupillon Flail', 'palladium-fantasy', 'weapon', 4.5, 60, '3D6', 'Ball and chain. Two-handed. Average length .5m/2 ft.', 'Palladium RPG Main Book p.271'),
('mace-and-chain', 'Mace and Chain', 'palladium-fantasy', 'weapon', 4.5, 50, '3D6', 'Ball and chain. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('nunchaku', 'Nunchaku', 'palladium-fantasy', 'weapon', 2.5, 30, '2D4', 'Ball and chain. Two-handed. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('arab-mace', 'Arab Mace', 'palladium-fantasy', 'weapon', 3, 40, '2D6', 'Blunt weapon. Average length .6m/2 ft.', 'Palladium RPG Main Book p.271'),
('mace', 'Mace', 'palladium-fantasy', 'weapon', 4.5, 40, '2D6', 'Blunt weapon. Average length .7m/2.5 ft.', 'Palladium RPG Main Book p.271'),
('cudgel', 'Cudgel', 'palladium-fantasy', 'weapon', 2.5, 40, '2D4', 'Blunt weapon. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('club-stick-pipe', 'Club / Stick / Pipe', 'palladium-fantasy', 'weapon', 3, 10, '2D4', 'Blunt weapon. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('hercules-club', 'Hercules Club', 'palladium-fantasy', 'weapon', 5.5, 60, '3D6', 'Blunt weapon. Two-handed. Average length 1.2m/4 ft.', 'Palladium RPG Main Book p.271'),
('horseman-hammer', 'Horseman Hammer', 'palladium-fantasy', 'weapon', 3.5, 45, '2D6', 'Blunt weapon. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('maul', 'Maul', 'palladium-fantasy', 'weapon', 4, 12, '2D4', 'Blunt weapon. Average length 1.2m/4 ft.', 'Palladium RPG Main Book p.271'),
('morning-star', 'Morning Star', 'palladium-fantasy', 'weapon', 2.5, 40, '2D6', 'Blunt weapon. Average length .8m/2.75 ft.', 'Palladium RPG Main Book p.271'),
('war-club', 'War Club (wood)', 'palladium-fantasy', 'weapon', 3, 25, '2D4', 'Blunt weapon. Average length .9m/3 ft.', 'Palladium RPG Main Book p.271'),
('war-hammer', 'War Hammer', 'palladium-fantasy', 'weapon', 4.5, 40, '3D4', 'Blunt weapon. Average length .7m/2.5 ft.', 'Palladium RPG Main Book p.271'),
('short-staff', 'Staff, Short', 'palladium-fantasy', 'weapon', 3, 20, '1D6', 'Staff. Average length 1.2-1.8m/4-6 ft.', 'Palladium RPG Main Book p.271'),
('long-staff', 'Staff, Long', 'palladium-fantasy', 'weapon', 5, 25, '2D4', 'Staff. Two-handed. Average length 1.9-2.7m/7-9 ft.', 'Palladium RPG Main Book p.271'),
('bo-staff', 'Bo Staff', 'palladium-fantasy', 'weapon', 3, 40, '2D6', 'Staff. Two-handed. Average length 2.8m/9.5 ft.', 'Palladium RPG Main Book p.271'),
('quarterstaff', 'Quarterstaff', 'palladium-fantasy', 'weapon', 3.5, 30, '2D6', 'Staff. Two-handed. Average length 1.8m/6 ft.', 'Palladium RPG Main Book p.271'),
('iron-staff', 'Iron Staff', 'palladium-fantasy', 'weapon', 7, 45, '2D6+2', 'Staff. Two-handed. Average length 1.8-2.1m/6-7 ft.', 'Palladium RPG Main Book p.271'),
('short-bow', 'Short Bow', 'palladium-fantasy', 'weapon', 1, 30, '1D6', 'Missile weapon. Two-handed.', 'Palladium RPG Main Book p.271'),
('arrows-short-bow', 'Arrows (short bow)', 'palladium-fantasy', 'gear', NULL, 10, NULL, 'Ammunition for the short bow. Priced per dozen.', 'Palladium RPG Main Book p.271'),
('long-bow', 'Long Bow', 'palladium-fantasy', 'weapon', 2, 70, '2D6', 'Missile weapon. Two-handed.', 'Palladium RPG Main Book p.271'),
('arrows-standard', 'Arrows (long bow)', 'palladium-fantasy', 'gear', NULL, 20, NULL, 'Ammunition for the long bow. Priced per dozen.', 'Palladium RPG Main Book p.271'),
('cross-bow', 'Cross Bow', 'palladium-fantasy', 'weapon', 7, 60, '1D6 (small), 2D6 (large)', 'Missile weapon. Two-handed.', 'Palladium RPG Main Book p.271'),
('crossbow-bolts', 'Bolts (crossbow)', 'palladium-fantasy', 'gear', NULL, 15, NULL, 'Ammunition for the cross bow. Priced per dozen.', 'Palladium RPG Main Book p.271'),
('sling', 'Sling', 'palladium-fantasy', 'weapon', 0.125, 10, '1D6', 'Missile weapon. Average weight 2 oz.', 'Palladium RPG Main Book p.271'),
('black-jack', 'Black Jack', 'palladium-fantasy', 'weapon', 3, 8, '1D6', 'Miscellaneous (no W.P. bonuses). Average length 10 in.', 'Palladium RPG Main Book p.271'),
('dart', 'Dart', 'palladium-fantasy', 'weapon', 0.375, 1, '1D4', 'Miscellaneous (no W.P. bonuses). Average length 6 in; average weight 6 oz.', 'Palladium RPG Main Book p.271'),
('bull-whip', 'Bull Whip', 'palladium-fantasy', 'weapon', 3, 20, '2D6', 'Miscellaneous (no W.P. bonuses). Average length 2.4m/8 ft.', 'Palladium RPG Main Book p.271'),
('cat-o-nine-tails', 'Cat-o-Nine Tails', 'palladium-fantasy', 'weapon', 1, 15, '2D6', 'Miscellaneous (no W.P. bonuses). Average length .8m/3 ft (as printed).', 'Palladium RPG Main Book p.271'),
('meat-cleaver', 'Meat Cleaver', 'palladium-fantasy', 'weapon', 1, 2, '1D6', 'Miscellaneous (no W.P. bonuses). Average length .3m/1 ft.', 'Palladium RPG Main Book p.271'),
('frying-pan', 'Frying Pan', 'palladium-fantasy', 'weapon', 1, 2, '1D6', 'Miscellaneous (no W.P. bonuses). Average length .3m/1 ft.', 'Palladium RPG Main Book p.271'),
('hand-pick', 'Hand Pick', 'palladium-fantasy', 'weapon', 0.5, 1, '1D4', 'Miscellaneous (no W.P. bonuses). Average length 7 in; average weight 8 oz.', 'Palladium RPG Main Book p.271'),
('large-pick-mattock', 'Large Pick/Mattock', 'palladium-fantasy', 'weapon', 5, 25, '3D4', 'Miscellaneous (no W.P. bonuses). Two-handed. Average length 1.2m/4 ft.', 'Palladium RPG Main Book p.271'),
('shovel', 'Shovel', 'palladium-fantasy', 'weapon', 5, 10, '1D6', 'Miscellaneous (no W.P. bonuses). Two-handed. Average length 1.2m/4 ft.', 'Palladium RPG Main Book p.271'),
('hammer-tool', 'Hammer (tool)', 'palladium-fantasy', 'weapon', 3, 7, '1D4', 'Miscellaneous (no W.P. bonuses). Average length 10 in. The book prints weight "1/4kg/3 lb"; 3 lb stored.', 'Palladium RPG Main Book p.271')
ON CONFLICT (slug) DO UPDATE SET
  name = excluded.name,
  system = excluded.system,
  category = excluded.category,
  weight_lbs = excluded.weight_lbs,
  cost = excluded.cost,
  damage = excluded.damage,
  description = excluded.description,
  source_book = excluded.source_book;

-- Read the result back rather than trusting the exit code.
SELECT COUNT(*) AS pf_weapon_rows FROM gear WHERE system = 'palladium-fantasy' AND source_book LIKE 'Palladium RPG Main Book%';
SELECT slug, name, cost, description FROM gear WHERE slug IN ('long-bow', 'short-sword', 'arrows-standard');
SELECT slug, cost FROM gear WHERE description LIKE '%per dozen%' ORDER BY slug;
SELECT COUNT(*) AS remaining_weapon_stubs FROM gear WHERE system = 'palladium-fantasy' AND description LIKE 'STUB%' AND category = 'weapon';
