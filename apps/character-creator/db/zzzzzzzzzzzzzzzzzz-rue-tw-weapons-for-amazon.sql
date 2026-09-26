-- Two Techno-Wizard weapons from Rifts Ultimate Edition (printed 137-138) -
-- the TW Flaming Sword and the TK-Machine-Gun - and the Amazon R.C.C.'s
-- equipment, which names both.
--
-- One-off data script, run once per environment.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzzzzz-rue-tw-weapons-for-amazon.sql
--
-- WHY. Rifts World Book 6: South America issues an Amazon in Manoa's service
-- "a Fireball (TW Flame) Rifle or TK-Machinegun" and "a TW Flaming Sword"
-- (printed 98). Neither weapon had a catalog row, so the Amazon import
-- (add-amazon-class.sql) gave the rifle only and left both in prose. Nate
-- asked for them (2026-09-25). Both are Rifts core-book items, so they cite
-- RUE, not South America.
--
-- READ OFF A RENDER. The RUE cache is an OCR scan; every figure below was read
-- from 120 dpi renders of printed 137 and 138.
--
-- CONVENTIONS: category 'weapon', like the Psyscape TW TK Pistol and Assault
-- Rifle (tw-tk-pistol, tw-tk-assault-rifle) and the Madhaven TW Conduit Sword;
-- cost is the book's Black Market Cost.
--
-- THE AMAZON. Its rifle line becomes the book's either/or, and the sword is
-- added. The edits are guarded on the text they replace, so a re-run does
-- nothing; the name sorts after add-amazon-class.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('tw-flaming-sword', 'TW Flaming Sword', 'rifts', 'weapon', NULL, 90000, 'Black Market Cost 90,000 credits.', '4D6 M.D.', 1, 'Handheld melee weapon', '10 minutes (40 melee rounds) per activation; activating costs 14 P.P.E. or 28 I.S.P.', NULL, NULL, NULL, NULL,
 'A bladeless sword hilt of wood or metal holding two rubies wired together; charged with P.P.E. or I.S.P., a crackling red, orange or yellow flame springs from the slot at its top and fights as a magic sword. Device level five. CONSTRUCTION: 275 P.P.E.; spell chain Fire Bolt (7) primary, Impervious to Fire (5) and Circle of Flame (10); two red rubies worth 76,000 credits and a smoky quartz worth 150; 5 days and 18 hours.', 'Rifts Ultimate Edition p.137'),
('tw-tk-machine-gun', 'TW TK-Machine-Gun', 'rifts', 'weapon', NULL, 75000, 'Black Market Cost 75,000 credits (an average example).', '2D4 M.D. per single shot; 4D4 M.D. per short burst (5 rounds); 4D6 M.D. per long burst (10 rounds); 1D6x10+10 M.D. per full melee burst (20 rounds)', 1, '2000 feet (610 m), double at ley lines', '60 TK-bolts; 2 P.P.E. or 4 I.S.P. recharges six, 20 P.P.E. or 40 I.S.P. all of them', 'Single shots or bursts', NULL, NULL, NULL,
 'A portable Techno-Wizard squad support gun that fires bullet-hard bolts of telekinetic force - no casings, bullets or muzzle flash, and nothing left behind once a bolt hits. No bonus to strike. Device level five. CONSTRUCTION: 240 P.P.E.; spell chain Telekinesis (8) primary, Barrage (15), Energy Bolt (5) and Power Bolt (20); eleven opals worth 5,500 credits, a red zircon worth 2,000, turquoise worth 240 and a conventional S.D.C. machinegun; 5 days.', 'Rifts Ultimate Edition p.137-138');

UPDATE imported_classes SET markdown = replace(markdown,
  '  - { item_id: "manoan-fireball-rifle", qty: 1, note: "The TW Flame Rifle issued to Amazons in the service of Manoa; the book offers a TK-Machinegun instead, which has no catalog row." }',
  '  - { choose: 1, label: "TW Flame Rifle or TK-Machinegun", qty: 1, from: ["manoan-fireball-rifle", "tw-tk-machine-gun"], note: "Issued to Amazons in the service of Manoa; the Flame Rifle is the Manoan Fireball Rifle." }' || char(10) ||
  '  - { item_id: "tw-flaming-sword", qty: 1 }'),
  updated_at = datetime('now')
WHERE class_id = 'amazon'
  AND instr(markdown, '  - { item_id: "manoan-fireball-rifle", qty: 1, note: "The TW Flame Rifle issued to Amazons in the service of Manoa; the book offers a TK-Machinegun instead, which has no catalog row." }') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
  'The TK-Machinegun alternative and the TW Flaming Sword are Rifts RPG items with no catalog row; rather than stub them from this book, both are named in the equipment prose and left out of equipment_starting.',
  'The TK-Machinegun alternative and the TW Flaming Sword are Rifts RPG items; zzzzzzzzzzzzzzzzzz-rue-tw-weapons-for-amazon.sql added both from RUE printed 137-138 and put them in equipment_starting.'),
  updated_at = datetime('now')
WHERE class_id = 'amazon'
  AND instr(markdown, 'The TK-Machinegun alternative and the TW Flaming Sword are Rifts RPG items with no catalog row') > 0;

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the two RUE TW weapons are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('tw-flaming-sword', 'tw-tk-machine-gun');
SELECT 'the Amazon offers the TK-Machine-Gun and carries the sword' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'amazon'
   AND instr(markdown, '"tw-tk-machine-gun"') > 0 AND instr(markdown, 'item_id: "tw-flaming-sword"') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzzz-rue-tw-weapons-for-amazon.sql');
