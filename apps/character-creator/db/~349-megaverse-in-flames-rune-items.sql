-- Rifts World Book 35: Megaverse in Flames, the Rune armor Soul Steel and the Rune axe Deceiver (printed 69-70, 167-168)
-- 2 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~349-megaverse-in-flames-rune-items.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.
-- Two named Rune items, each its own entry inside its owner's NPC write-up:
-- Soul Steel, Hell Lord Rune's armor (printed 69-70), and Deceiver, Overlord
-- Sindel's battle axe (printed 167-168). Every M.D.C., damage, P.P.E. and
-- attribute figure was read off a render of its page. Soul Steel prints M.D.C.
-- by location; mdc holds the chest plate's 1,000, which the book calls the main
-- body, and the description gives every location. Its mystic blast is a power
-- of the assembled suit, so it stays in the description and damage is empty.
-- Neither item has a printed price, so cost is NULL. Not the same items as the
-- Nuhr rune armors and axe (D-Bees of North America) or dragon-slayer-rune-armor
-- and dragon-slayer-rune-axe (Dragons and Gods).

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('soul-steel', 'Soul Steel', 'rifts', 'armor', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1000, 'A Greatest Rune armor, the prize of Hell Lord Rune (Sonja Kerram), who got it after Tolkeen Shifters turned up a whole suit. It comes in five parts - helmet, chest plate, a gauntlet for each hand and a pair of greaves - and legend says five such suits were broken up and their parts strewn through the Megaverse, each part fitting only its own suit. Sentient: I.Q. 14, Aberrant alignment, speaks by telepathy; it hates the Minions of Dyval and most gods, the Gods of Light worst of all. M.D.C. by location: helmet 500, chest plate 1,000 (the main body, stored here), each gauntlet 350, each greave 500. Each part casts its own spell invocations three times a day, at 3rd level for a lone part and three levels more for every part added, so 15th with all five (the wearer may cast lower, from 1st to 15th). Helmet: Breathe without Air, Eyes of the Wolf, See Aura, See the Invisible. Chest plate: Supernatural Strength, Armor of Ithan. Left gauntlet: Power Bolt, Shockwave, Mystic Shield. Right gauntlet: Lightning Arc, Deflect, Sub-Particle Acceleration. Greaves, only as a pair: Walk the Wind, Walk the Waves, Superhuman Speed, Climb, Swim as the Fish: Superior. With all five parts on and linked by their chains, it also gives: regeneration of 1D4x10 M.D.C. per melee to every damaged part at once (a part on its own mends 1D6 M.D.C. a minute); double Spd and +2 attacks per melee; flight at 300 mph (480 kph), no altitude or time limit; a mystic blast of 4D6 M.D. to 2,000 feet (610 m), unlimited payload, one attack per blast; +1 on all saves and +3 to save vs Horror Factor; and Teleport: Superior three times a day. Losing any part ends those. Unlike a Rune weapon it can be destroyed. Once bonded to an owner for a month it can shrink away into one gauntlet and rebuild itself around the owner at a touch of a gold rune or a thought, which takes a full melee round (15 seconds) with none of its powers working. It must feed on at least one soul a month (it would rather have one a week), taking them without its owner''s leave and holding up to four in reserve; starved, it drops a third of its power after one week, two thirds after two, and at three weeks devours its owner''s soul and falls dormant. No price printed.', 'Rifts World Book 35: Megaverse in Flames p.69-70', NULL),
  ('deceiver', 'Deceiver', 'rifts', 'weapon', NULL, NULL, NULL, '6D6 M.D. in any of its forms', 1, NULL, NULL, NULL, NULL, NULL, NULL, 'The Rune battle axe of Overlord Sindel of Dyval, with the usual eight Rune Weapon traits and a Miscreant alignment. It can take the shape of any of three melee weapons, normally ones its wielder has a W.P. in (for Sindel an axe, a pole arm and a spear); changing shape costs one melee attack, and it hits for 6D6 M.D. whatever its form. It can also pass itself off as any stringed instrument, and as Sindel''s axe its haft looks like an electric guitar. A foe facing it rolls a save vs magic of 14; on a failure that foe is -2 to parry and dodge its blows, never sure which weapon is coming. A Soul Drinker: unless it takes a soul at least once a week its damage falls 1D6 M.D. at a time to a floor of 1D6 M.D., and it can cast no spells. Spells, each castable three times a day (P.P.E. in brackets): Horror (10), Horrific Illusion (10), Multiple Image (7) and Aura of Power (4). No price printed.', 'Rifts World Book 35: Megaverse in Flames p.167-168', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 2 gear rows are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('soul-steel', 'deceiver') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~349-megaverse-in-flames-rune-items.sql');
