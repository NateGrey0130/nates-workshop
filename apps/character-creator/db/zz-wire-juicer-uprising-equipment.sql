-- Wire the Juicer Uprising classes' Standard Equipment paragraphs to real gear
-- rows, now that gear batches A, B and C have put those rows in the catalog.
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zz-wire-juicer-uprising-equipment.sql
--
-- TEN OF THE FIFTEEN CLASSES GET AN equipment_starting BLOCK. The other five do
-- not, and each for a printed reason rather than an omission:
--   - Juicer Gladiator, Juicer Assassin and Juicer Scout print NO Standard
--     Equipment line at all. They are training programmes laid over a Juicer who
--     already has his kit, and the book gives them a Money Bonus and nothing
--     else.
--   - The Murder-Wraith's equipment is "usually basic Juicer stuff" - it is an
--     NPC villain whose gear is whatever it had when it died.
--   - The Maxi-Killer's is "provided by the slave's owner on the basis of need."
--     A list would be an invention.
--
-- THREE NEW GEAR ROWS come with this. The PAS Helmet is a real item with printed
-- stats (30 M.D.C., an 80 I.S.P. pool, low-light/infrared/thermal optics) and is
-- added properly. The C-14 Fire-Breather and the C-27 Heavy Plasma Cannon are
-- only NAMED by this book - their stats live in Coalition War Machine - so they
-- are added as STUBS carrying the marker the gear importer recognises, which is
-- the class-import skill's own answer to an item a class needs and a book does
-- not describe.
--
-- WHAT COULD NOT BE WIRED, and is left in the prose where it already was:
-- bio-data implants, the drug supply itself, "one automatic weapon", "two melee
-- weapons of choice", the Wannabe's tiny apartment and gang colors, the
-- Gambler's two decks of cards and dice, and the Coalition Juicer's 48 grenades
-- and Forearm Integral Weapon System reloads. Some are not objects, some have no
-- catalog row, and inventing a row for "two melee weapons of choice" would put a
-- name in the catalog that no book prints.
--
-- Quantities: a FIXED entry may take a dice expression and rolls once behind the
-- wizard's equipInit guard; a CHOICE must take a plain number, because its qty is
-- re-derived on every render and a dice value there would re-roll each repaint.
-- That is why "2D4 energy clips for each" of two weapons is one fixed e-clip
-- entry at 4d4 rather than two entries of 2d4.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: every UPDATE is guarded on equipment_starting being absent.

-- The PAS Helmet, printed 40, in the Delphi Juicer's own entry.
INSERT INTO gear (slug, name, system, category, cost, mdc, description, source_book)
VALUES ('pas-helmet', 'Psychic Amplification System (PAS) Helmet', 'rifts', 'gear', 100000, 30,
        'Surgically attached to a Delphi Juicer and synchronised to his brain waves - it cannot be used by anybody else. It increases the RANGE of all psionic powers by 10% and DOUBLES their duration, carries its own pool of 80 I.S.P. recovering at 8 per hour, armours the head with 30 M.D.C., and adds low-light, infrared and thermal optics. It comes off only by surgery, by being torn off, or by being blasted apart - attackers are -5 to strike on the called shot. However it comes off, the Delphi instantly loses every feature above, and is so psychologically dependent on it that he loses ALL combat bonuses, one melee attack, and takes -20% on all skill performance until a replacement is fitted and calibrated. Built on stolen Psynetic technology by Dr. Heinrich Rommel. Juicer Uprising p.40.',
        'Rifts World Book 10: Juicer Uprising p.40')
ON CONFLICT (slug) DO NOTHING;

-- Two Coalition weapons this book NAMES and does not describe. Stubs, carrying
-- the exact marker the gear importer looks for when filling one in later.
INSERT INTO gear (slug, name, system, category, description, source_book) VALUES
('c-14-fire-breather-rifle', 'C-14 Fire Breather Assault Rifle', 'rifts', 'weapon',
 'STUB ' || char(8212) || ' created by class import, needs stats. Standard issue to the Coalition Juicer (Juicer Uprising p.45), which names it without printing its numbers; the stat block is in Rifts World Book 11: Coalition War Machine.',
 'Rifts World Book 10: Juicer Uprising p.45'),
('c-27-heavy-plasma-cannon', 'C-27 Heavy Plasma Cannon', 'rifts', 'weapon',
 'STUB ' || char(8212) || ' created by class import, needs stats. The Coalition Juicer''s alternative issued heavy weapon (Juicer Uprising p.45), which names it without printing its numbers; the stat block is in Rifts World Book 11: Coalition War Machine.',
 'Rifts World Book 10: Juicer Uprising p.45')
ON CONFLICT (slug) DO NOTHING;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { choose: 1, label: "light body armour - a Hyperion favours Spike or Vibro-Spike", qty: 1, from: ["spiked-armor", "vibro-spike-armor", "explorer-armor", "bushman-full-composite-environmental-body-armor"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws"] }
skills:
')
 WHERE class_id = 'hyperion-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "titan-plate-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws"] }
skills:
')
 WHERE class_id = 'titan-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "pas-helmet", qty: 1 }
  - { choose: 1, label: "light body armour - usually Juicer Assassin flex-plate", qty: 1, from: ["explorer-armor", "bushman-full-composite-environmental-body-armor", "crusader-full-environmental-body-armor", "gladiator-full-environmental-body-armor"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws"] }
skills:
')
 WHERE class_id = 'phaeton-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "mega-juicer-combat-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
skills:
')
 WHERE class_id = 'mega-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "pas-helmet", qty: 1 }
  - { choose: 1, label: "light body armour - usually Juicer Assassin flex-plate", qty: 1, from: ["explorer-armor", "bushman-full-composite-environmental-body-armor", "crusader-full-environmental-body-armor", "gladiator-full-environmental-body-armor"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
skills:
')
 WHERE class_id = 'delphi-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "super-hide-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: 10 }
skills:
')
 WHERE class_id = 'dragon-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "bio-comp-monitor", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "fiws-forearm-integral-weapon-system", qty: 1 }
  - { choose: 1, label: "Coalition Special Trooper Armor - 115 M.D.C. with the FIWS built in", qty: 1, from: ["ca-1-heavy-dead-boy-armor", "ca-2-light-dead-boy-armor", "coalition-dead-boy-body-armor"] }
  - { choose: 1, label: "issued heavy weapon", qty: 1, from: ["c-14-fire-breather-rifle", "c-27-heavy-plasma-cannon"] }
  - { item_id: "c-18-laser-pistol", qty: 1 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "e-clip", qty: 16 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1 }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "emergency-food-rations", qty: 14 }
skills:
')
 WHERE class_id = 'coalition-juicer' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { choose: 1, label: "Coalition Dead Boy armor, new or old", qty: 1, from: ["ca-1-heavy-dead-boy-armor", "ca-2-light-dead-boy-armor", "coalition-dead-boy-body-armor"] }
  - { choose: 1, label: "heavy energy rifle", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: 12 }
  - { choose: 2, label: "a pair of vibro-blades of choice", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "backpack", qty: 1 }
skills:
')
 WHERE class_id = 'psycho-stalker' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "knife-small", qty: 1 }
  - { choose: 1, label: "energy pistol, possibly a hold-out", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "1d4" }
  - { choose: 1, label: "light M.D.C. armour", qty: 1, from: ["explorer-armor", "bushman-full-composite-environmental-body-armor", "crusader-full-environmental-body-armor", "gladiator-full-environmental-body-armor"] }
  - { item_id: "dress-clothing", qty: 4 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
skills:
')
 WHERE class_id = 'gambler' AND instr(markdown, 'equipment_starting:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '
skills:
', '
equipment_starting:
  - { item_id: "knife", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: 2 }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1 }
  - { choose: 1, label: "a motorcycle - no hover bikes, no heavy combat bikes", qty: 1, from: ["the-highway-man-motorcycle", "the-wastelander-motorcycle", "road-boss-motorcycle"] }
  - { choose: 1, label: "mega-damage body armour, preferably Juicer style", qty: 1, from: ["spiked-armor", "explorer-armor", "bushman-full-composite-environmental-body-armor"] }
  - { item_id: "goggles", qty: 1 }
  - { item_id: "dress-clothing", qty: 2 }
skills:
')
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'equipment_starting:') = 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id, instr(markdown, 'equipment_starting:') > 0 AS wired,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes
 WHERE class_id IN ('hyperion-juicer', 'titan-juicer', 'phaeton-juicer', 'mega-juicer', 'delphi-juicer')
 ORDER BY class_id;
SELECT class_id, instr(markdown, 'equipment_starting:') > 0 AS wired
  FROM imported_classes
 WHERE class_id IN ('dragon-juicer', 'coalition-juicer', 'psycho-stalker', 'gambler', 'juicer-wannabe')
 ORDER BY class_id;
SELECT COUNT(*) AS new_gear FROM gear
 WHERE slug IN ('pas-helmet', 'c-14-fire-breather-rifle', 'c-27-heavy-plasma-cannon');

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zz-wire-juicer-uprising-equipment.sql');
