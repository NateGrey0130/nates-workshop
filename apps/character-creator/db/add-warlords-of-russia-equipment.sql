-- Rifts World Book 17: Warlords of Russia, batch 2c: equipment.
-- 11 new gear rows from printed 186-189.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-warlords-of-russia-equipment.sql
--
-- ALL 11 ARE NEW - catalog-diff --table gear --remote and a slug query,
-- 2026-10-01. The first draft of this script held 27 rows and its own
-- pre-flight refused it: sixteen were already in the catalog.
--
-- WHAT IS LEFT OUT, AND WHY - the catalog already holds it, and the catalog
-- wins (class-import reference/catalog.md):
--   The high-tech arrowheads (printed 186): nine rows from Triax and the NGR
--     p.150 and Spirit West p.203, plus Japan's tranquilizer and paralysis
--     gas. Same names, same prices as this book prints.
--   Computer: Portable Field Unit, the small and medium Radio Communicators
--     and the Communication Helmet: Rifts Ultimate Edition p.261-270. The
--     LARGE communicator (printed 187: toaster-sized, 20 miles, 6,000
--     credits) has no row of its own and RUE's medium row mentions a 6,000
--     credit version; ambiguous, so left alone and said so.
--   Miscellaneous Equipment (printed 188) and Clothing of Note (printed 189):
--     held under the same names from other books. Battle Dress Utility is the
--     one entry there the catalog did not hold.
--   The three bare price lists - Hunting, Trapping, Hiking & Camping;
--     Containers; Clothes: General Purpose (printed 187-189) - are name and
--     price only, reprinted across Palladium books and largely held.
--   Basic Types of Bows (printed 186) prints a price per generic bow and
--     points to the Rifts RPG for damage and range. Magic arrows print a price
--     range and no item.
--
-- THE TWO JET PACKS ARE NOT THE CATALOG'S 'Jet Pack'. That name belongs to
-- Heroes Unlimited and Nightbane rows (80 mph, 40 minutes, dollars). These
-- are named as the book prints them, with the parenthetical.
--
-- A RANGE STORES ITS LOW END with the range in cost_note.
-- The Ecto-Sensor's 300 foot radius is printed with 183 m, which is 600 feet;
-- both are recorded and 300 feet is stored.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('ecto-sensor', 'Ecto-Sensor', 'rifts', 'gear', NULL, 350000, '350,000 credits; poor availability.', NULL, 0, '300 foot radius (the book prints 183 m)', NULL, NULL, NULL, NULL, NULL, 'A "ghost detector" the size of a backpack field radio. Detects entities, similar energy beings and solid but invisible beings (magic included) at 89%, rolled once a minute to keep contact, and tracks their movement at 89%. Ethereal beings, Astral beings and fragmented life essences are found only 01-12% of the time, +12% while they use magic or move objects. Shows a rough image on a HUD or built-in screen.', 'Rifts World Book 17: Warlords of Russia p.186'),
('jet-pack-common', 'Jet Pack (common)', 'rifts', 'vehicle', NULL, 55000, '55,000 credits E-Pack powered; 900,000 nuclear powered.', NULL, 0, NULL, '24 hours from an E-Pack, or nuclear with a 10 year life', NULL, NULL, NULL, 100, 'An all-purpose jet pack for humans and Light Machines; a Heavy cyborg flies it at 40% less speed and altitude. Maximum speed 220 mph (352 km), cruising 60-100 mph; maximum altitude 2,500 feet (762 m). After three hours of continuous flight it must cool for 30 minutes or it overheats.', 'Rifts World Book 17: Warlords of Russia p.186'),
('jet-pack-light-and-cheap', 'Jet Pack (light & cheap)', 'rifts', 'vehicle', NULL, 19000, '19,000 credits; E-Pack powered units only.', NULL, 0, NULL, 'One hour of flight, then a half hour to cool', NULL, NULL, NULL, 22, 'A cheap jet pack: maximum speed 90 mph (145 km), maximum altitude 300 feet (91 m). It overheats and shuts down after an hour.', 'Rifts World Book 17: Warlords of Russia p.186'),
('mo-2050-long-range-optic-system', 'Magnovo Corp. MO-2050 Long-Range Optic System', 'rifts', 'gear', 15, 26000, '26,000 credits. Fair to poor availability.', NULL, 0, 'Optics 3,000 feet (914 m), line of sight; laser distancer to 6,000 feet (1828 m)', NULL, NULL, NULL, NULL, NULL, 'A tripod-mounted optic system used in surveying, accurate to 99.8%. It will not work unless set on its tripod or a sturdy flat surface, or held by a cyborg. Laser distancer and measuring, macro and micro magnification (up to x150), x40 telescopic magnification, passive nightvision and infrared, all computer enhanced; links to other computers, vehicle systems and weapon systems.', 'Rifts World Book 17: Warlords of Russia p.187'),
('skis-downhill', 'Skis: Downhill', 'rifts', 'gear', NULL, 500, '500-750 credits; the low end is stored. Excellent availability.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Modern Russian super-ceramic downhill skis. Each ski breaks down into two pieces for storage.', 'Rifts World Book 17: Warlords of Russia p.187'),
('skis-cross-country', 'Skis: Cross-Country', 'rifts', 'gear', NULL, 300, '300-500 credits; the low end is stored. Excellent availability.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Cross-country skis built for long treks over rough terrain. Each ski breaks down into two pieces for storage.', 'Rifts World Book 17: Warlords of Russia p.187'),
('thermal-suit', 'Thermal Suit', 'rifts', 'gear', NULL, 750, '750-850 credits for the suit; the low end is stored. The battery is 150 credits.', NULL, 0, NULL, 'Battery life: one winter of constant use', NULL, NULL, NULL, NULL, 'A waterproof environmental suit for cold weather, padded and insulated with battery-powered warming coils and thick gloves molded to handle weapons and machinery. Protects completely down to -100 Centigrade (-148 Fahrenheit). Good mobility: -5% to prowl, climb, swim, acrobatics and gymnastics.', 'Rifts World Book 17: Warlords of Russia p.187'),
('thermal-jacket', 'Thermal Jacket', 'rifts', 'gear', NULL, 450, '450 credits for the jacket; the battery is 150.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'The thermal suits heated, waterproof system as a hooded jacket to just below the waist, with heated gloves.', 'Rifts World Book 17: Warlords of Russia p.187'),
('thermal-arctic-boots', 'Thermal Arctic Boots', 'rifts', 'gear', NULL, 180, '180 credits a pair; a replacement battery is 40.', NULL, 0, NULL, 'Battery life: one winter of constant use', NULL, NULL, NULL, 5, 'Insulated boots reinforced with overlapping ceramic plates and warmed by an internal battery; in widespread use across Russia. 5 M.D.C.', 'Rifts World Book 17: Warlords of Russia p.187'),
('winter-survival-kit', 'Winter Survival Kit', 'rifts', 'gear', NULL, 100, '100 credits. Excellent availability.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Standard issue to Warlord reavers, knights and soldiers. A light metal box (25 S.D.C.) holding 3 hand flares, a smoke grenade, signal mirror, 36 waterproof matches, a cigarette lighter, 6 sterno canisters, a thermo-blanket, 4 heat packs lasting 4 hours each, seven days of freeze-dried food and vitamins, 16 concentrated fat pills, thick mittens and socks, a ski mask, scarf, tinted goggles, a pocket knife and a hand axe (1D6 S.D.C.).', 'Rifts World Book 17: Warlords of Russia p.187'),
('battle-dress-utility', 'Battle Dress Utility', 'rifts', 'gear', NULL, 85, 'Lightweight (desert and jungle) 85 credits; medium weight (forest and mountain) 130; arctic weight, down lined, 300-500. The lightweight price is stored.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A camouflage shirt and pants in arctic, desert, jungle or autumn forest patterns. The shirt has two breast pockets, a pen pocket and a left interior pocket; the pants have hip, back and thigh pockets.', 'Rifts World Book 17: Warlords of Russia p.189');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 11 Warlords of Russia equipment rows are in' AS assertion, count(*) AS got, 11 AS want
  FROM gear WHERE slug IN ('ecto-sensor', 'jet-pack-common', 'jet-pack-light-and-cheap', 'mo-2050-long-range-optic-system', 'skis-downhill', 'skis-cross-country', 'thermal-suit', 'thermal-jacket', 'thermal-arctic-boots', 'winter-survival-kit', 'battle-dress-utility');
SELECT 'and every one cites Warlords of Russia' AS assertion, count(*) AS got, 11 AS want
  FROM gear WHERE source_book LIKE 'Rifts World Book 17: Warlords of Russia p.%' AND slug IN ('ecto-sensor', 'jet-pack-common', 'jet-pack-light-and-cheap', 'mo-2050-long-range-optic-system', 'skis-downhill', 'skis-cross-country', 'thermal-suit', 'thermal-jacket', 'thermal-arctic-boots', 'winter-survival-kit', 'battle-dress-utility');
SELECT 'the two jet packs are in at their own figures' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE (slug = 'jet-pack-common' AND mdc = 100 AND cost = 55000) OR (slug = 'jet-pack-light-and-cheap' AND mdc = 22 AND cost = 19000);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-warlords-of-russia-equipment.sql');
