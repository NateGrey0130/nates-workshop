-- The 19 choice-group gear citations that retire-orphan-gear-stubs.sql left
-- pointing at nothing (class audit F2, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzz-resolve-choice-group-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzz-resolve-choice-group-gear.sql
--
-- WHAT HAPPENED. retire-orphan-gear-stubs.sql (2026-08-19) deleted 33 stub
-- rows guarded on "no class markdown names the slug" - but the guard pattern
-- was instr(markdown, 'item_id: "slug"'), which matches only FIXED equipment
-- entries. Choice groups cite slugs inside from: ["..."] lists, the guard
-- never saw them, and eight live classes were citing 19 of the deleted rows
-- that way. A wizard pick of one of those options resolves to nothing: the
-- item lands as a bare custom line with no stats. No redirect covers any of
-- them.
--
-- Two shapes of fix, mirroring how this class of problem was fixed before:
--
--   RESTORE   Real products get real rows back, transcribed from their book
--             entries: the C-10 and C-12 (RUE printed 257-258, dog-boy's
--             rifle choice) and the two TW vehicles (RUE printed 136-137,
--             techno-wizard's vehicle choice). The Warlock's Triax pump
--             weapon has NO entry in any book on this machine - the citation
--             is Conversion Book One's Warlock equipment list, the stats live
--             in Triax & The NGR - so it returns as the exact STUB the class
--             importer would have made, for the gear importer to fill later.
--
--   REWIRE    Category placeholders are NOT recreated - each citing choice is
--             rewritten to enumerate real catalog slugs, the way
--             retire-gear-placeholders.sql handled the Juicer's energy-pistol.
--             The lists are the AVAILABLE set, not a claim about what any
--             page enumerates - widen them as more books are imported.
--
-- Three rewrites deserve their own note:
--
--   glitter-boy's armor choice cited urban-warrior-armor, but the Urban
--   Warrior suit already exists as urban-warrior-padded-environmental-body-
--   armor (RUE printed 261-270 import; the old urban-warrior-body-armor slug
--   redirects there). The citation is repointed, not re-imported - a second
--   row for the same suit is what the duplicate checks exist to prevent.
--
--   The conventional-firearm choices (glitter-boy, mind-melter, ley-line-
--   walker, ley-line-rifter) shrink to ["submachine-gun"], the one
--   conventional firearm row the catalog holds - itself a priced generic
--   (see the README's stub-tier notes), but a row a pick resolves to.
--   fix-phantom-choice-options.sql left these slugs
--   alone because there was nothing to substitute; that was livable while the
--   rows existed and is not now that they are deleted. One real option beats
--   two phantoms; the labels keep the book's wording, and the lists widen
--   when a book with conventional firearms is imported.
--
--   mind-melter's vehicle list (RUE printed 151: "Hover vehicle, hovercycle,
--   robot horse, jet pack, motorcycle, car, or a Techno-Wizard vehicle")
--   enumerates the catalog's real vehicles. NO ROBOT HORSE EXISTS in the
--   catalog and no book on this machine stats one, so that option is absent
--   from the list until one is imported.
--
-- FILENAME SORTS LAST ON PURPOSE. A clean rebuild applies db/*.sql as one
-- sorted glob, and retire-orphan-gear-stubs.sql deletes STUB rows whose slug
-- is on its list and whose only citations are choice groups - which is
-- exactly what the restored Triax stub is. This file must therefore run after
-- it, and after the zz-/zzz- gear scripts; zzz-r sorts after zzz-gear-tidy-3,
-- the current last file.
--
-- Every statement guards itself, so this is safe to re-run and safe to run
-- early: in an environment missing the option rows, a rewrite waits rather
-- than swapping phantoms for absentees.

-- -- 1. The dog-boy's rifles, back from RUE printed 257-258 --

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('c-10-laser-rifle', 'C-10 Light Assault Laser Rifle', 'rifts', 'weapon', 5.0, 16000, 'Black market 16,000 credits; standard clip and recharge costs',
        '2D6 M.D., no variable settings', 1, '2000 feet (610 m)',
        '20 blasts from a standard E-Clip or 30 from a long E-Clip; an E-Clip canister cannot be used with this weapon',
        'Each laser blast counts as one melee attack',
        'An earlier version of the C-12 that greatly resembles the heavy laser, with a longer barrel and a built-in computer enhanced laser targeting system. A favorite sniper rifle known for its accuracy and durability in the field. The experimental targeting system is not as reliable as the weapon itself: 01-23% chance of failure every time it undergoes strenuous combat, 01-40% after a hard fall, and the design was scrapped from all later weapons. Laser targeting: +3 to strike on an Aimed shot, but only while the targeting system is functioning.',
        'Rifts Ultimate Edition p.257');

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, description, source_book)
VALUES ('c-12-laser-rifle', 'C-12 Heavy Assault Laser Rifle', 'rifts', 'weapon', 7.0, 20000, 'Black market 20,000 credits',
        'Setting One: 2D6 M.D. single shot; Setting Two (burst): 6D6 M.D.; Setting Three (S.D.C.): 6D6 S.D.C.', 1, '2000 feet (610 m)',
        '20 M.D. blasts from a standard E-Clip or 30 from a long E-Clip, plus another 30 from an E-Clip canister; six S.D.C. shots equal one M.D. blast',
        'Single shot or a burst of three; each blast or burst counts as one melee attack',
        'The standard Coalition infantry weapon until 105 P.A. and still a favorite of Commandos and Special Ops - a sturdy, reliable rifle that survives a great amount of combat abuse without mechanical failure. Three settings, one S.D.C. and two M.D.C. Comes standard with a passive nightvision scope and laser targeting (+1 to strike on an Aimed shot).',
        'Rifts Ultimate Edition p.257-258');

-- -- 2. The techno-wizard's vehicles, back from RUE printed 136-137 --

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, is_mega_damage, description, source_book)
VALUES ('tw-wing-board', 'TW Wing Board', 'rifts', 'vehicle', 26000, 'Black market 26,000 credits', 0,
        'A popular one person glider, also called a TK-Glider - a flying surfboard that rides the wind and ley line energy. It needs no ignition or spell to fly along a ley line, so ANYONE can use one while on a ley line; no ley line energy, no flight. To launch, the rider rises at least 60 feet (18.3 m) by Levitation or Telekinesis and releases on the next gust of wind, or leaps from a tower, tree or cliff on a ley line. Base skill proficiency equals the Jet Pack skill. Maximum speed 150 mph (240 km), maximum height 1000 feet (305 m); it stays in flight for the length of the ley line and can change direction at a nexus. Device Level: One. P.P.E. Construction Cost: 525. Spell chain: Fly as the Eagle (25), Energy Bolt (5), Float in Air (3). Physical requirements: a diamond worth 15,000 credits, a red zircon worth 2,000 credits, a clear zircon worth 3,500 credits and an aerodynamic board with steering mechanism. Construction time: 2 days and 5 hours, up to a week for a fancy board.',
        'Rifts Ultimate Edition p.137');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, is_mega_damage, description, source_book)
VALUES ('tw-tree-trimmer', 'TW Tree Trimmer', 'rifts', 'vehicle', 20000, 'Black market 20,000 credits', 0,
        'A strange, low flying, one or two person hover vehicle for ley line cruising - basically a bicycle with paddles front and back instead of wheels: the rider pedals, the paddles spin, and the flying bicycle goes. Can be designed for one or two riders, plus one passenger on the handlebars or rear. Named for its maximum altitude of about treetop level - 200 feet (61 m); maximum speed 120 mph (192 km). Duration of charge: 30 minutes, extendable in flight for another 9 P.P.E. or 18 I.S.P.; takeoff costs 9 P.P.E. or 18 I.S.P. Device Level: Three. P.P.E. Creation Cost: 180. Spell chain: Float in Air (5), Energy Bolt (5), Telekinesis (8). Physical requirements: an opal worth 500 credits, a red zircon worth 2,000 credits and a clear zircon worth 10,500 credits, plus an old bicycle and some paddles. Construction time: 54 hours.',
        'Rifts Ultimate Edition p.136-137');

-- -- 3. The warlock's Triax pump weapon, back as the stub it was --
-- Cited by Conversion Book One's Warlock equipment ("automatic pistol or
-- Triax pump weapon"); the item's own stats are in Triax & The NGR, which is
-- not on this machine, and stats are transcribed, never guessed.

INSERT OR IGNORE INTO gear (slug, name, system, category, description, source_book)
VALUES ('triax-pump-weapon', 'Triax Pump Weapon', 'rifts', 'weapon',
        'STUB ' || char(8212) || ' created by class import, needs stats',
        'Triax & The NGR');

-- -- 4. The glitter-boy's armor choice points at the suit that exists --

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["urban-warrior-armor", "huntsman-armor"]',
      'from: ["urban-warrior-padded-environmental-body-armor", "huntsman-armor"]'),
    updated_at = datetime('now')
WHERE class_id = 'glitter-boy'
  AND instr(markdown, 'from: ["urban-warrior-armor", "huntsman-armor"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('urban-warrior-padded-environmental-body-armor', 'huntsman-armor')) = 2;

-- -- 5. The conventional-firearm choices enumerate the one real gun --

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["rifle", "automatic-pistol", "submachine-gun"]',
      'from: ["submachine-gun"]'),
    updated_at = datetime('now')
WHERE class_id = 'glitter-boy'
  AND instr(markdown, 'from: ["rifle", "automatic-pistol", "submachine-gun"]') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'submachine-gun');

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["rifle", "automatic-pistol", "submachine-gun"]',
      'from: ["submachine-gun"]'),
    updated_at = datetime('now')
WHERE class_id = 'mind-melter'
  AND instr(markdown, 'from: ["rifle", "automatic-pistol", "submachine-gun"]') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'submachine-gun');

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["automatic-pistol", "submachine-gun"]',
      'from: ["submachine-gun"]'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-walker'
  AND instr(markdown, 'from: ["automatic-pistol", "submachine-gun"]') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'submachine-gun');

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["automatic-pistol", "submachine-gun"]',
      'from: ["submachine-gun"]'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, 'from: ["automatic-pistol", "submachine-gun"]') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'submachine-gun');

-- -- 6. The mind-melter's vehicle list enumerates real vehicles --
-- Guarded on all eight options, including the two TW vehicles restored above.

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["hover-vehicle", "hovercycle", "robot-horse", "jet-pack", "motorcycle", "car", "techno-wizard-vehicle"]',
      'from: ["hovercycle", "a-t-v-speedster-hover-cycle", "wilk-s-jet-pack", "the-highway-man-motorcycle", "the-wastelander-motorcycle", "jeep", "tw-wing-board", "tw-tree-trimmer"]'),
    updated_at = datetime('now')
WHERE class_id = 'mind-melter'
  AND instr(markdown, 'from: ["hover-vehicle", "hovercycle", "robot-horse", "jet-pack", "motorcycle", "car", "techno-wizard-vehicle"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'hovercycle', 'a-t-v-speedster-hover-cycle', 'wilk-s-jet-pack',
        'the-highway-man-motorcycle', 'the-wastelander-motorcycle', 'jeep',
        'tw-wing-board', 'tw-tree-trimmer')) = 8;

-- -- 7. The priest-of-light's weapon families become the PF rows they meant --
-- Printed 67: "most seem to favor staves, blunt weapons, chain weapons,
-- spears, and swords. Starts with two of choice." Two real rows per family.

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["staff", "blunt-weapon", "chain-weapon", "spear", "sword"]',
      'from: ["quarterstaff", "long-staff", "mace", "morning-star", "mace-and-chain", "flail", "short-spear", "long-spear", "short-sword", "long-sword"]'),
    updated_at = datetime('now')
WHERE class_id = 'priest-of-light'
  AND instr(markdown, 'from: ["staff", "blunt-weapon", "chain-weapon", "spear", "sword"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'quarterstaff', 'long-staff', 'mace', 'morning-star', 'mace-and-chain',
        'flail', 'short-spear', 'long-spear', 'short-sword', 'long-sword')) = 10;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   rows_restored          5 = the four real rows plus the Triax stub
--   citations_unresolved   0 = no published class cites any of the 19 slugs
--                          any more (the four real slugs restored above are
--                          excluded - those citations now resolve)
--   choices_rewired        5 = glitter-boy, mind-melter, ley-line-walker,
--                          ley-line-rifter and priest-of-light carry a
--                          rewritten list (dog-boy, techno-wizard and warlock
--                          needed rows back, not new lists)
SELECT (SELECT count(*) FROM gear WHERE slug IN ('c-10-laser-rifle', 'c-12-laser-rifle', 'tw-wing-board', 'tw-tree-trimmer', 'triax-pump-weapon')) AS rows_restored,
       (SELECT count(*) FROM imported_classes WHERE status = 'published' AND deleted_at IS NULL AND (instr(markdown, '"urban-warrior-armor"') > 0 OR instr(markdown, '"rifle"') > 0 OR instr(markdown, '"automatic-pistol"') > 0 OR instr(markdown, '"hover-vehicle"') > 0 OR instr(markdown, '"robot-horse"') > 0 OR instr(markdown, '"jet-pack"') > 0 OR instr(markdown, '"motorcycle"') > 0 OR instr(markdown, '"car"') > 0 OR instr(markdown, '"techno-wizard-vehicle"') > 0 OR instr(markdown, '"staff"') > 0 OR instr(markdown, '"blunt-weapon"') > 0 OR instr(markdown, '"chain-weapon"') > 0 OR instr(markdown, '"spear"') > 0 OR instr(markdown, '"sword"') > 0)) AS citations_unresolved,
       (SELECT count(*) FROM imported_classes WHERE status = 'published' AND deleted_at IS NULL AND (instr(markdown, 'from: ["submachine-gun"]') > 0 OR instr(markdown, '"jeep", "tw-wing-board"') > 0 OR instr(markdown, '"short-sword", "long-sword"]') > 0)) AS choices_rewired;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzz-resolve-choice-group-gear.sql');
