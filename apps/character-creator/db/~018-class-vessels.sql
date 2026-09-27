-- Classes whose own book issues them a vessel: the vessel goes in
-- equipment_starting through a gear row pointing at it, the way
-- `glitter-boy-power-armor` does. BOOK-INGEST-AUDIT.md F41.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~018-class-vessels.sql
--
-- == THE SHAPE, AND WHY IT IS NOT A NEW KEY ==
--
-- equipment_starting cites `gear` slugs and nothing else. F41 settled on
-- 2026-09-09 that a vessel is cited through a gear row carrying
-- `vehicle_slug` (migration 053) rather than by teaching the class format a
-- vessel reference, and three Glitter Boy classes already list
-- `glitter-boy-power-armor` that way. Nate chose that shape for this job on
-- 2026-09-26: no frontmatter key, no code. So each issued vessel gains ONE
-- gear row whose slug is the vessel's own slug, and the class lists it.
--
-- == WHAT GOES IN ==
--
-- Four gear pointer rows, each citing its vessel's own pages:
--   glitter-boy-side-kick-qpa-98   -> fq-side-kick-rpa        (Free Quebec p.92-94)
--   rhv-60-reloader-hover-vehicle  -> fq-gb-reloader          (Free Quebec p.60-61)
--   t-31-super-trooper             -> ngr-power-armor-commando (Triax p.42-45)
--   x-2000-dyna-max                -> ngr-robot-combat-pilot  (Triax p.70-73)
-- The two Triax ones were found by searching production for class notes that
-- still left a vessel out under F3: printed 164 and 165 issue each machine
-- outright ("Standard Military issue for ..."). The same search found three
-- NGR classes calling the T-11 Enhanced body armour and T-100 Eagle jet pack
-- vessels; both are GEAR rows (Triax p.34-35), imported after those classes,
-- so they are added to equipment_starting as they stand.
--
-- Two `vehicles` rows for the Mining 'Borg's chassis, New West printed
-- 113-114, with nine M.D.C. locations, read off a render of printed 113
-- (PDF page 114, offset +1) and matching the cache's text layer. The class
-- points at them the way the Free Quebec cyborgs point at theirs - a
-- restriction line naming the vessel rows - and keeps `mdc_base` in its two
-- variants. No `vehicle_weapons`: the page prints no weapon systems, only
-- tool attachments, which are gear rows from add-new-west-gear-b-bionics.sql.
-- No gear pointer either: a cyborg body is the character, not something
-- issued to it, which is also why the Free Quebec cyborgs have none.
--
-- == WHAT DOES NOT, AND WHY ==
--
-- cs-rpa-fly-boy-ace: CWC printed 85 issues "hovercycle or jeep" and names
-- no model. `vehicles` holds no Coalition hovercycle or jeep (the rocket and
-- sky cycles are aircraft; the jeeps are Heroes Unlimited, Nightbane and
-- Quebec machines), so there is nothing to point at. Its restriction stays,
-- and its reason is rewritten: it cited F3 and "vehicles are not gear here",
-- which F41 made false. Three other CWC classes said their vehicles were
-- prose "as the Side Kick RPA does"; the Side Kick no longer does, so that
-- clause goes.
--
-- Class markdown is edited with replace(), guarded on the text it replaces
-- AND on the replacement being absent, so a re-run is a no-op.
--
-- == FILENAME ==
--
-- `~` (0x7E) sorts after every `z` tier, so this runs after every file that
-- creates the rows it edits, including zzzzzzzz-nw-vessels-p196-223.sql,
-- whose New West vessel count this file raises. ~008 to ~017 are claimed by
-- parallel work; this is ~018. Sort checked, not assumed.

-- ---------------------------------------------------------------------------
-- The Mining 'Borg's two chassis. New West printed 113-114.
-- ---------------------------------------------------------------------------

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('partial-reconstruction-mining-cyborg', 'Partial Reconstruction Mining Cyborg', 'rifts', 'borg',
   'The augmented character; this is a cyborg body, not a piloted vehicle.', 'None.',
   'Spd 44, or 30 mph (48 km). Leaps 10 feet (3 m) high or lengthwise from a standing position, or three times that distance with a running start.',
   NULL, NULL,
   'Height 6.6 to 7 feet (1.95 to 2.1 m).',
   NULL,
   130, NULL,
   'Not sold for credits. The conversion costs 5-6 years of service to whoever pays for it - often a landowner, a mining tycoon, a mining union or a town.',
   'The lighter of the two bodies the Mining ''Borg/Prospector O.C.C. is built into. Emphasis is on strength, construction and mining: as heavy as possible, with reinforced spine, neck and shoulders, bionic hands and arms, bionic legs, plus optics and internal implants. BIONIC PHYSICAL ATTRIBUTES: P.S. 20, P.P. 18, Spd 44. BIONIC BODY ARMOUR: 120 M.D.C. on top of the 130 main body. TYPICAL BIONIC FEATURES: universal headjack; amplified hearing with sound filtration system; passive night vision and a thermal eye for one eye, the other eye normal; modular hands and arms that fit a variety of hand and forearm attachments, standard with one hand carrying a laser finger and sensor hand and one hand and arm replaced with a heavy drill; cybernetic lung implants - toxic filter, oxygen storage cell and molecular analyzer (Rifts RPG page 232); concealed large and small compartments in the left leg for flashlight, flares and tools, and in the right leg for rope and a first-aid kit. Other features and attachments can be added later, if the character has the money.',
   'Rifts World Book 14: New West p.113'),

  ('full-construction-mining-cyborg', 'Full Construction Mining Cyborg', 'rifts', 'borg',
   'The augmented character; this is a cyborg body, not a piloted vehicle.', 'None.',
   'Spd 66, or 45 mph (72 km). Leaps 12 feet (3.6 m) high or lengthwise from a standing position, or three times that distance with a running start.',
   NULL, NULL,
   'Height 7.6 to 9 feet (2.25 to 2.7 m).',
   NULL,
   200, NULL,
   'Not sold for credits. The conversion costs 8-10 years of service, one more year for the extra appendage a third of them carry, and 1-4 more for additional bionic features and arm attachments that belong to the miner.',
   'The heavier of the two bodies the Mining ''Borg/Prospector O.C.C. is built into: a full bionic conversion, with emphasis on strength, construction and mining and as heavy as possible, with reinforced spine, neck and shoulders. BIONIC PHYSICAL ATTRIBUTES: P.S. 28-30 (printed as a range), P.P. 22, Spd 66. BIONIC BODY ARMOUR: 150 M.D.C. on top of the 200 main body. TYPICAL BIONIC FEATURES FOR FULL CONVERSION BORGS: universal headjack; amplified hearing with sound filtration system; a Multi-Optic System (Rifts RPG page 231); modular hands and arms, standard with one shovel hand carrying laser finger and sensor hand features and one hand and arm replaced with a heavy drill or plasma torch (see the cybernetic equipment section of New West); a bionic lung with all features - gas filter, oxygen storage cell, molecular analyzer, radio, loudspeaker, language translator and voice synthesizer (Rifts RPG page 242); concealed large and small compartments in the left leg for flashlight, flares, tools and a concealed ion or laser rod, and in the right leg for rope, a first-aid kit and other equipment. 33% HAVE AN EXTRA APPENDAGE - a prehensile tail or a pair of extra arms - which gives one extra attack per melee round. Other features and attachments can be added later, if the character has the money.',
   'Rifts World Book 14: New West p.113-114');

-- Printed order. The page writes "hands (2) 25" without "each" and "arms (2)
-- 75 each"; a pair sharing one figure is per hand, as on every other borg.
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('partial-reconstruction-mining-cyborg', 'Main Body', 130, 'Plus 120 M.D.C. of bionic body armour, printed as "Main Body: 130 M.D.C. +120 bionic body armor".', 1),
  ('partial-reconstruction-mining-cyborg', 'Hands (2)', 25, 'Each.', 2),
  ('partial-reconstruction-mining-cyborg', 'Arms (2)', 75, 'Each.', 3),
  ('partial-reconstruction-mining-cyborg', 'Legs (2)', 110, 'Each.', 4),
  ('full-construction-mining-cyborg', 'Main Body', 200, 'Plus 150 M.D.C. of bionic body armour, printed as "Main Body: 200 M.D.C. +150 bionic body armor".', 1),
  ('full-construction-mining-cyborg', 'Hands (2)', 30, 'Each.', 2),
  ('full-construction-mining-cyborg', 'Arms (2)', 100, 'Each.', 3),
  ('full-construction-mining-cyborg', 'Legs (2)', 180, 'Each.', 4),
  ('full-construction-mining-cyborg', 'Head', 90, NULL, 5);

-- ---------------------------------------------------------------------------
-- The four gear pointers. Figures copied from each vessel row (production,
-- 2026-09-26): mdc is the main body, cost the vessel's cost, weight its
-- printed empty weight where it prints one in pounds.
-- ---------------------------------------------------------------------------

INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, is_mega_damage,
   mdc, description, source_book, vehicle_slug)
VALUES
  ('glitter-boy-side-kick-qpa-98', 'Glitter Boy Side Kick (QPA-98 "Little Buddy")', 'rifts', 'vehicle',
   600, 8500000,
   'Free Quebec cost 8.5 million credits. Exclusive to the Quebec Military and not available on the black market.',
   1, 280,
   'Free Quebec''s small, laser-resistant chrome power armour, issued to the Side Kick RPA O.C.C. for field use (printed 40). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.',
   'Rifts World Book 22: Free Quebec p.92-94', 'glitter-boy-side-kick-qpa-98'),

  ('rhv-60-reloader-hover-vehicle', 'RHV-60 Reloader Hover Vehicle', 'rifts', 'vehicle',
   NULL, 2500000,
   'Free Quebec cost 2.5 million credits fully loaded. Not available on the black market.',
   1, 328,
   'The Glitter Boy Reload Team''s hover vehicle: seats four in the open like a hovercycle, with a cargo bay for ammo-drums, munitions and parts and clamps for a back-up Boom Gun. Issued with the Reloader O.C.C. (printed 41). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.',
   'Rifts World Book 22: Free Quebec p.60-61', 'rhv-60-reloader-hover-vehicle'),

  ('t-31-super-trooper', 'T-31 Super Trooper Power Armor', 'rifts', 'vehicle',
   450, 1800000,
   'Black market 1.8 million credits for a new, fully powered suit with complete weapon systems. Poor availability; exclusive to the NGR military.',
   1, 250,
   'The NGR''s power armour, standard military issue for the Power Armor Commando O.C.C. (printed 164). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.',
   'Rifts World Book 5: Triax and the NGR p.42-45', 't-31-super-trooper'),

  ('x-2000-dyna-max', 'X-2000 Dyna-Max', 'rifts', 'vehicle',
   24000, 40000000,
   'Black market 40 million credits for a new, undamaged unit with all weapon systems intact.',
   1, 550,
   'The NGR''s two-man combat robot, standard military issue for the Robot Combat Pilot O.C.C. (printed 165). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.',
   'Rifts World Book 5: Triax and the NGR p.70-73', 'x-2000-dyna-max');

-- ---------------------------------------------------------------------------
-- The classes. Generated from production markdown read 2026-09-26; every
-- anchor below was asserted to occur exactly once in its class.
-- ---------------------------------------------------------------------------

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "STARTS WITH A SIDE KICK POWER ARMOR, which is not in equipment_starting because it is a vessel rather than a gear row - see extraction_notes and BOOK-INGEST-AUDIT.md F3."' || char(10),
  '  - { item_id: "canteen", qty: 1 }' || char(10) || '  - { item_id: "glitter-boy-side-kick-qpa-98", qty: 1 }' || char(10) || 'restrictions:' || char(10))
  WHERE class_id = 'fq-side-kick-rpa' AND instr(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "STARTS WITH A SIDE KICK POWER ARMOR, which is not in equipment_starting because it is a vessel rather than a gear row - see extraction_notes and BOOK-INGEST-AUDIT.md F3."' || char(10)) > 0
    AND instr(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || '  - { item_id: "glitter-boy-side-kick-qpa-98", qty: 1 }' || char(10) || 'restrictions:' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'NO SIDE KICK POWER ARMOR IN equipment_starting: the Side Kick is imported as a `vehicles` row (printed 92-94) and equipment_starting can only reference `gear` slugs, so the class ships without the one item its own book issues it. Recorded in restrictions where a player will see it. See BOOK-INGEST-AUDIT.md F3, and note this is the same cost the Noro Mystic Warrior paid.',
  'THE SIDE KICK POWER ARMOR IS IN equipment_starting since 2026-09-26 (~018-class-vessels.sql). The Side Kick is a `vehicles` row (printed 92-94) and equipment_starting references `gear` slugs, so the class first shipped without it and said so in restrictions, under F3. It now lists the `glitter-boy-side-kick-qpa-98` gear row, which points at the vessel of the same slug the way `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41.')
  WHERE class_id = 'fq-side-kick-rpa' AND instr(markdown, 'NO SIDE KICK POWER ARMOR IN equipment_starting: the Side Kick is imported as a `vehicles` row (printed 92-94) and equipment_starting can only reference `gear` slugs, so the class ships without the one item its own book issues it. Recorded in restrictions where a player will see it. See BOOK-INGEST-AUDIT.md F3, and note this is the same cost the Noro Mystic Warrior paid.') > 0
    AND instr(markdown, 'THE SIDE KICK POWER ARMOR IS IN equipment_starting since 2026-09-26 (~018-class-vessels.sql). The Side Kick is a `vehicles` row (printed 92-94) and equipment_starting references `gear` slugs, so the class first shipped without it and said so in restrictions, under F3. It now lists the `glitter-boy-side-kick-qpa-98` gear row, which points at the vessel of the same slug the way `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "hand-held-computer", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "MAY NOT PILOT ROBOTS OR POWER ARMOR. The book states it as a fail-safe measure for security purposes: the man who loads and repairs the Glitter Boys is deliberately not trained to take one."' || char(10) || '  - "STARTS WITH AN RHV-60 RELOADER HOVER VEHICLE, which is not in equipment_starting because it is a vessel rather than a gear row - see extraction_notes and BOOK-INGEST-AUDIT.md F3."' || char(10),
  '  - { item_id: "hand-held-computer", qty: 1 }' || char(10) || '  - { item_id: "rhv-60-reloader-hover-vehicle", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "MAY NOT PILOT ROBOTS OR POWER ARMOR. The book states it as a fail-safe measure for security purposes: the man who loads and repairs the Glitter Boys is deliberately not trained to take one."' || char(10))
  WHERE class_id = 'fq-gb-reloader' AND instr(markdown, '  - { item_id: "hand-held-computer", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "MAY NOT PILOT ROBOTS OR POWER ARMOR. The book states it as a fail-safe measure for security purposes: the man who loads and repairs the Glitter Boys is deliberately not trained to take one."' || char(10) || '  - "STARTS WITH AN RHV-60 RELOADER HOVER VEHICLE, which is not in equipment_starting because it is a vessel rather than a gear row - see extraction_notes and BOOK-INGEST-AUDIT.md F3."' || char(10)) > 0
    AND instr(markdown, '  - { item_id: "hand-held-computer", qty: 1 }' || char(10) || '  - { item_id: "rhv-60-reloader-hover-vehicle", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "MAY NOT PILOT ROBOTS OR POWER ARMOR. The book states it as a fail-safe measure for security purposes: the man who loads and repairs the Glitter Boys is deliberately not trained to take one."' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'NO RHV-60 IN equipment_starting: the Reloader Hover Vehicle is imported as a `vehicles` row (printed 60-61) and equipment_starting can only reference `gear` slugs.',
  'THE RHV-60 IS IN equipment_starting since 2026-09-26 (~018-class-vessels.sql). The Reloader Hover Vehicle is a `vehicles` row (printed 60-61) and equipment_starting references `gear` slugs, so the class first shipped without it and said so in restrictions, under F3. It now lists the `rhv-60-reloader-hover-vehicle` gear row, which points at the vessel of the same slug the way `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41. Printed 41 says the Reload Team pilots it, one vehicle seating the team of four, so a party of Reloaders holds one each where the book has one between them.')
  WHERE class_id = 'fq-gb-reloader' AND instr(markdown, 'NO RHV-60 IN equipment_starting: the Reloader Hover Vehicle is imported as a `vehicles` row (printed 60-61) and equipment_starting can only reference `gear` slugs.') > 0
    AND instr(markdown, 'THE RHV-60 IS IN equipment_starting since 2026-09-26 (~018-class-vessels.sql). The Reloader Hover Vehicle is a `vehicles` row (printed 60-61) and equipment_starting references `gear` slugs, so the class first shipped without it and said so in restrictions, under F3. It now lists the `rhv-60-reloader-hover-vehicle` gear row, which points at the vessel of the same slug the way `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41. Printed 41 says the Reload Team pilots it, one vehicle seating the team of four, so a party of Reloaders holds one each where the book has one between them.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting because vehicles are not gear here - see extraction_notes.',
  'ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting: the book names no model, and the catalog holds no Coalition hovercycle or jeep vessel to point at - see extraction_notes.')
  WHERE class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, 'ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting because vehicles are not gear here - see extraction_notes.') > 0
    AND instr(markdown, 'ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting: the book names no model, and the catalog holds no Coalition hovercycle or jeep vessel to point at - see extraction_notes.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The hovercycle or jeep is a vehicle and lives in restrictions, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.',
  'The hovercycle or jeep lives in restrictions. Printed 85 names no model, and on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles`, so the gear-pointer shape the Side Kick RPA took that day (BOOK-INGEST-AUDIT.md F41) had nothing to point at.')
  WHERE class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, 'The hovercycle or jeep is a vehicle and lives in restrictions, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'The hovercycle or jeep lives in restrictions. Printed 85 names no model, and on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles`, so the gear-pointer shape the Side Kick RPA took that day (BOOK-INGEST-AUDIT.md F41) had nothing to point at.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The vehicle for daily use is prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.',
  'The vehicle for daily use is prose; see BOOK-INGEST-AUDIT.md F3.')
  WHERE class_id = 'cs-special-forces' AND instr(markdown, 'The vehicle for daily use is prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'The vehicle for daily use is prose; see BOOK-INGEST-AUDIT.md F3.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.')
  WHERE class_id = 'iss-peacekeeper' AND instr(markdown, 'Vehicles are prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.')
  WHERE class_id = 'ntset-protector' AND instr(markdown, 'Vehicles are prose, as the Side Kick RPA does; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - "No vehicle to start."' || char(10),
  '  - "No vehicle to start."' || char(10) || '  - "The two chassis are the `partial-reconstruction-mining-cyborg` and `full-construction-mining-cyborg` vessel rows, imported from the same pages: M.D.C. by location, the bionic body armour and the typical bionic features."' || char(10))
  WHERE class_id = 'mining-borg' AND instr(markdown, '  - "No vehicle to start."' || char(10)) > 0
    AND instr(markdown, '  - "No vehicle to start."' || char(10) || '  - "The two chassis are the `partial-reconstruction-mining-cyborg` and `full-construction-mining-cyborg` vessel rows, imported from the same pages: M.D.C. by location, the bionic body armour and the typical bionic features."' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'THE NEW WEST VESSEL IMPORT HAS NOT RUN YET - printed 171-223 is a later batch - so there is no vessel row to point at, and the full M.D.C.-by-location figures are in the ability text until there is.',
  'THE TWO CHASSIS ARE VESSEL ROWS since 2026-09-26 (~018-class-vessels.sql): `partial-reconstruction-mining-cyborg` and `full-construction-mining-cyborg`, their M.D.C. by location read off a render of printed 113, and a restriction line names both. Until then there was nothing to point at: this class was imported before New West''s vessels, and the vessel batches that followed covered printed 183-223, never these two bodies printed inside the O.C.C. The figures also stay in the ability text.')
  WHERE class_id = 'mining-borg' AND instr(markdown, 'THE NEW WEST VESSEL IMPORT HAS NOT RUN YET - printed 171-223 is a later batch - so there is no vessel row to point at, and the full M.D.C.-by-location figures are in the ability text until there is.') > 0
    AND instr(markdown, 'THE TWO CHASSIS ARE VESSEL ROWS since 2026-09-26 (~018-class-vessels.sql): `partial-reconstruction-mining-cyborg` and `full-construction-mining-cyborg`, their M.D.C. by location read off a render of printed 113, and a restriction line names both. Until then there was nothing to point at: this class was imported before New West''s vessels, and the vessel batches that followed covered printed 183-223, never these two bodies printed inside the O.C.C. The figures also stay in the ability text.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "e-clip", qty: 4 }' || char(10),
  'equipment_starting:' || char(10) || '  - { item_id: "t-31-super-trooper", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-100-eagle-jet-pack", qty: 1 }' || char(10) || '  - { item_id: "e-clip", qty: 4 }' || char(10))
  WHERE class_id = 'ngr-power-armor-commando' AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "e-clip", qty: 4 }' || char(10)) > 0
    AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-31-super-trooper", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-100-eagle-jet-pack", qty: 1 }' || char(10) || '  - { item_id: "e-clip", qty: 4 }' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'THE CLASS''S DEFINING EQUIPMENT IS A VESSEL THIS CATALOG CANNOT HOLD, per' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The T-31 Super Trooper is standard issue and the' || char(10) || '    entry is built around it - printed 164 says the commando is sent out in one' || char(10) || '    to fight giant robots and tanks one on one - and it is a power armour stat' || char(10) || '    block of the kind F3 excludes, as are the T-11 Enhanced body armour and the' || char(10) || '    T-100 Eagle jet pack issued beside it. All three are in the body. This is' || char(10) || '    the same shape as the Noro Mystic Warrior''s psionic power armour.' || char(10),
  'THE CLASS''S DEFINING EQUIPMENT IS IN equipment_starting since 2026-09-26' || char(10) || '    (~018-class-vessels.sql). The T-31 Super Trooper is standard issue and the' || char(10) || '    entry is built around it - printed 164 says the commando is sent out in one' || char(10) || '    to fight giant robots and tanks one on one. It is the `t-31-super-trooper`' || char(10) || '    gear row, which points at the vessel of the same slug the way' || char(10) || '    `glitter-boy-power-armor` does (BOOK-INGEST-AUDIT.md F41). The T-11 Enhanced' || char(10) || '    body armour and T-100 Eagle jet pack issued beside it are gear rows of' || char(10) || '    their own (printed 34-35). Until then all three were in the body, under F3.' || char(10))
  WHERE class_id = 'ngr-power-armor-commando' AND instr(markdown, 'THE CLASS''S DEFINING EQUIPMENT IS A VESSEL THIS CATALOG CANNOT HOLD, per' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The T-31 Super Trooper is standard issue and the' || char(10) || '    entry is built around it - printed 164 says the commando is sent out in one' || char(10) || '    to fight giant robots and tanks one on one - and it is a power armour stat' || char(10) || '    block of the kind F3 excludes, as are the T-11 Enhanced body armour and the' || char(10) || '    T-100 Eagle jet pack issued beside it. All three are in the body. This is' || char(10) || '    the same shape as the Noro Mystic Warrior''s psionic power armour.' || char(10)) > 0
    AND instr(markdown, 'THE CLASS''S DEFINING EQUIPMENT IS IN equipment_starting since 2026-09-26' || char(10) || '    (~018-class-vessels.sql). The T-31 Super Trooper is standard issue and the' || char(10) || '    entry is built around it - printed 164 says the commando is sent out in one' || char(10) || '    to fight giant robots and tanks one on one. It is the `t-31-super-trooper`' || char(10) || '    gear row, which points at the vessel of the same slug the way' || char(10) || '    `glitter-boy-power-armor` does (BOOK-INGEST-AUDIT.md F41). The T-11 Enhanced' || char(10) || '    body armour and T-100 Eagle jet pack issued beside it are gear rows of' || char(10) || '    their own (printed 34-35). Until then all three were in the body, under F3.' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Standard issue includes the T-31 Super Trooper, T-11 Enhanced body armour and the T-100 Eagle jet pack. None is stored: all three are vessel-shaped stat blocks this catalog does not hold. The elite training in them is stored, as Robot Combat Elite rows.',
  'Standard issue includes the T-31 Super Trooper, T-11 Enhanced body armour and the T-100 Eagle jet pack, all three in the starting equipment; the T-31''s full stat block is its vessel row. The elite training in them is stored, as Robot Combat Elite rows.')
  WHERE class_id = 'ngr-power-armor-commando' AND instr(markdown, 'Standard issue includes the T-31 Super Trooper, T-11 Enhanced body armour and the T-100 Eagle jet pack. None is stored: all three are vessel-shaped stat blocks this catalog does not hold. The elite training in them is stored, as Robot Combat Elite rows.') > 0
    AND instr(markdown, 'Standard issue includes the T-31 Super Trooper, T-11 Enhanced body armour and the T-100 Eagle jet pack, all three in the starting equipment; the T-31''s full stat block is its vessel row. The elite training in them is stored, as Robot Combat Elite rows.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10),
  'equipment_starting:' || char(10) || '  - { item_id: "x-2000-dyna-max", qty: 1 }' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10))
  WHERE class_id = 'ngr-robot-combat-pilot' AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10)) > 0
    AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "x-2000-dyna-max", qty: 1 }' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'THE CLASS''S STANDARD ISSUE IS A VESSEL THIS CATALOG CANNOT HOLD, per' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The X-2000 Dyna-Max is issued outright and is a' || char(10) || '    robot vehicle stat block of the kind F3 excludes, as is every X-series robot' || char(10) || '    the entry offers on assignment. The elite training in them is stored; the' || char(10) || '    machines are in the body.' || char(10),
  'THE CLASS''S STANDARD ISSUE IS IN equipment_starting since 2026-09-26' || char(10) || '    (~018-class-vessels.sql). The X-2000 Dyna-Max is issued outright; it is the' || char(10) || '    `x-2000-dyna-max` gear row, which points at the vessel of the same slug the' || char(10) || '    way `glitter-boy-power-armor` does (BOOK-INGEST-AUDIT.md F41). Until then it' || char(10) || '    was in the body, under F3. The X-series robots the entry offers on' || char(10) || '    assignment are vessel rows too and are not issued, so they stay in the' || char(10) || '    body; the elite training in them is stored.' || char(10))
  WHERE class_id = 'ngr-robot-combat-pilot' AND instr(markdown, 'THE CLASS''S STANDARD ISSUE IS A VESSEL THIS CATALOG CANNOT HOLD, per' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The X-2000 Dyna-Max is issued outright and is a' || char(10) || '    robot vehicle stat block of the kind F3 excludes, as is every X-series robot' || char(10) || '    the entry offers on assignment. The elite training in them is stored; the' || char(10) || '    machines are in the body.' || char(10)) > 0
    AND instr(markdown, 'THE CLASS''S STANDARD ISSUE IS IN equipment_starting since 2026-09-26' || char(10) || '    (~018-class-vessels.sql). The X-2000 Dyna-Max is issued outright; it is the' || char(10) || '    `x-2000-dyna-max` gear row, which points at the vessel of the same slug the' || char(10) || '    way `glitter-boy-power-armor` does (BOOK-INGEST-AUDIT.md F41). Until then it' || char(10) || '    was in the body, under F3. The X-series robots the entry offers on' || char(10) || '    assignment are vessel rows too and are not issued, so they stay in the' || char(10) || '    body; the elite training in them is stored.' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Standard issue includes the X-2000 Dyna-Max, which is not stored: it is a robot vehicle stat block this catalog does not hold. The elite training in it is stored, as a Robot Combat Elite row.',
  'Standard issue includes the X-2000 Dyna-Max, in the starting equipment; its full stat block is its vessel row. The elite training in it is stored, as a Robot Combat Elite row.')
  WHERE class_id = 'ngr-robot-combat-pilot' AND instr(markdown, 'Standard issue includes the X-2000 Dyna-Max, which is not stored: it is a robot vehicle stat block this catalog does not hold. The elite training in it is stored, as a Robot Combat Elite row.') > 0
    AND instr(markdown, 'Standard issue includes the X-2000 Dyna-Max, in the starting equipment; its full stat block is its vessel row. The elite training in it is stored, as a Robot Combat Elite row.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10),
  'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-100-eagle-jet-pack", qty: 1 }' || char(10))
  WHERE class_id = 'ngr-intelligence-officer' AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10)) > 0
    AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-100-eagle-jet-pack", qty: 1 }' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The T-11 Enhanced body armour and T-100 Eagle jet pack issued alongside the' || char(10) || '    T-10 are NOT stored: both are BOOK-INGEST-AUDIT.md F3 vessels, as is the' || char(10) || '    EIR-15 gargoyle bot the entry offers on assignment. In the body.' || char(10),
  'The T-11 Enhanced body armour and T-100 Eagle jet pack issued alongside the' || char(10) || '    T-10 are in equipment_starting since 2026-09-26 (~018-class-vessels.sql):' || char(10) || '    both are gear rows (printed 34-35), not vessels, which this note said they' || char(10) || '    were until then. The EIR-15 gargoyle bot the entry offers on assignment is' || char(10) || '    a vessel row and is not issued. In the body.' || char(10))
  WHERE class_id = 'ngr-intelligence-officer' AND instr(markdown, 'The T-11 Enhanced body armour and T-100 Eagle jet pack issued alongside the' || char(10) || '    T-10 are NOT stored: both are BOOK-INGEST-AUDIT.md F3 vessels, as is the' || char(10) || '    EIR-15 gargoyle bot the entry offers on assignment. In the body.' || char(10)) > 0
    AND instr(markdown, 'The T-11 Enhanced body armour and T-100 Eagle jet pack issued alongside the' || char(10) || '    T-10 are in equipment_starting since 2026-09-26 (~018-class-vessels.sql):' || char(10) || '    both are gear rows (printed 34-35), not vessels, which this note said they' || char(10) || '    were until then. The EIR-15 gargoyle bot the entry offers on assignment is' || char(10) || '    a vessel row and is not issued. In the body.' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, '; and T-11 Enhanced body armour and the T-100 Eagle jet pack, which are vessel-shaped stat blocks this catalog does not hold.',
  '. The T-11 Enhanced body armour and the T-100 Eagle jet pack are in the starting equipment.')
  WHERE class_id = 'ngr-intelligence-officer' AND instr(markdown, '; and T-11 Enhanced body armour and the T-100 Eagle jet pack, which are vessel-shaped stat blocks this catalog does not hold.') > 0
    AND instr(markdown, '. The T-11 Enhanced body armour and the T-100 Eagle jet pack are in the starting equipment.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10),
  'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10))
  WHERE class_id = 'ngr-intelligence-commando' AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10)) > 0
    AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "t-10-infantry-cyclops-body-armor", qty: 1 }' || char(10) || '  - { item_id: "t-11-enhanced-body-armor", qty: 1 }' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The T-11 Enhanced body armour issued alongside the T-10 is NOT stored: it is' || char(10) || '    a BOOK-INGEST-AUDIT.md F3 vessel, as are the T-Series power armour, the' || char(10) || '    X-10A Predator, X-60 Flanker, X-500 Forager and EIR-15 gargoyle bot the' || char(10) || '    entry offers on assignment. In the body.' || char(10),
  'The T-11 Enhanced body armour issued alongside the T-10 is in' || char(10) || '    equipment_starting since 2026-09-26 (~018-class-vessels.sql): it is a gear row' || char(10) || '    (printed 35), not a vessel, which this note said it was until then. The' || char(10) || '    T-Series power armour, the X-10A Predator, X-60 Flanker, X-500 Forager and' || char(10) || '    EIR-15 gargoyle bot the entry offers on assignment are vessel rows and are' || char(10) || '    not issued. In the body.' || char(10))
  WHERE class_id = 'ngr-intelligence-commando' AND instr(markdown, 'The T-11 Enhanced body armour issued alongside the T-10 is NOT stored: it is' || char(10) || '    a BOOK-INGEST-AUDIT.md F3 vessel, as are the T-Series power armour, the' || char(10) || '    X-10A Predator, X-60 Flanker, X-500 Forager and EIR-15 gargoyle bot the' || char(10) || '    entry offers on assignment. In the body.' || char(10)) > 0
    AND instr(markdown, 'The T-11 Enhanced body armour issued alongside the T-10 is in' || char(10) || '    equipment_starting since 2026-09-26 (~018-class-vessels.sql): it is a gear row' || char(10) || '    (printed 35), not a vessel, which this note said it was until then. The' || char(10) || '    T-Series power armour, the X-10A Predator, X-60 Flanker, X-500 Forager and' || char(10) || '    EIR-15 gargoyle bot the entry offers on assignment are vessel rows and are' || char(10) || '    not issued. In the body.' || char(10)) = 0;

UPDATE imported_classes SET markdown = replace(markdown, '; and T-11 Enhanced body armour, which is a vessel-shaped stat block this catalog does not hold.',
  '. The T-11 Enhanced body armour is in the starting equipment.')
  WHERE class_id = 'ngr-intelligence-commando' AND instr(markdown, '; and T-11 Enhanced body armour, which is a vessel-shaped stat block this catalog does not hold.') > 0
    AND instr(markdown, '. The T-11 Enhanced body armour is in the starting equipment.') = 0;

-- ---------------------------------------------------------------------------
-- Read-backs. INSERT OR IGNORE and a guarded replace() are both SILENT when
-- they do nothing, so every want is counted off THIS FILE.
-- ---------------------------------------------------------------------------

SELECT 'the two Mining Borg chassis are vessels' AS assertion, count(*) AS got, 2 AS want
  FROM vehicles
  WHERE slug IN ('partial-reconstruction-mining-cyborg', 'full-construction-mining-cyborg')
    AND vehicle_class = 'borg' AND mdc_main_body IN (130, 200);

SELECT 'with nine M.D.C. locations between them' AS assertion, count(*) AS got, 9 AS want
  FROM vehicle_locations
  WHERE vehicle_slug IN ('partial-reconstruction-mining-cyborg', 'full-construction-mining-cyborg');

SELECT 'each of the four gear pointers resolves to its vessel' AS assertion, count(*) AS got, 4 AS want
  FROM gear g JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.slug IN ('glitter-boy-side-kick-qpa-98', 'rhv-60-reloader-hover-vehicle',
                   't-31-super-trooper', 'x-2000-dyna-max')
    AND g.slug = g.vehicle_slug;

SELECT 'each class lists what its book issues it' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes
  WHERE (class_id = 'fq-side-kick-rpa'         AND instr(markdown, 'item_id: "glitter-boy-side-kick-qpa-98"') > 0)
     OR (class_id = 'fq-gb-reloader'           AND instr(markdown, 'item_id: "rhv-60-reloader-hover-vehicle"') > 0)
     OR (class_id = 'ngr-power-armor-commando' AND instr(markdown, 'item_id: "t-31-super-trooper"') > 0
                                               AND instr(markdown, 'item_id: "t-11-enhanced-body-armor"') > 0
                                               AND instr(markdown, 'item_id: "t-100-eagle-jet-pack"') > 0)
     OR (class_id = 'ngr-robot-combat-pilot'   AND instr(markdown, 'item_id: "x-2000-dyna-max"') > 0)
     OR (class_id = 'ngr-intelligence-officer' AND instr(markdown, 'item_id: "t-11-enhanced-body-armor"') > 0
                                               AND instr(markdown, 'item_id: "t-100-eagle-jet-pack"') > 0)
     OR (class_id = 'ngr-intelligence-commando' AND instr(markdown, 'item_id: "t-11-enhanced-body-armor"') > 0)
     OR (class_id = 'mining-borg'              AND instr(markdown, '`partial-reconstruction-mining-cyborg` and `full-construction-mining-cyborg` vessel rows') > 0)
     OR (class_id = 'cs-rpa-fly-boy-ace'       AND instr(markdown, 'no Coalition hovercycle or jeep vessel to point at') > 0);

SELECT 'and each rewritten note names this file' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes
  WHERE class_id IN ('fq-side-kick-rpa', 'fq-gb-reloader', 'ngr-power-armor-commando',
                     'ngr-robot-combat-pilot', 'ngr-intelligence-officer',
                     'ngr-intelligence-commando', 'mining-borg', 'cs-rpa-fly-boy-ace')
    AND instr(markdown, '~018-class-vessels.sql') > 0;

SELECT 'no note still leaves one of these out as a vessel' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
  WHERE instr(markdown, 'because it is a vessel rather than a gear row') > 0
     OR instr(markdown, 'VESSEL IMPORT HAS NOT RUN YET') > 0
     OR instr(markdown, 'as the Side Kick RPA does') > 0
     OR (class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, 'because vehicles are not gear here') > 0)
     OR (class_id IN ('ngr-power-armor-commando', 'ngr-robot-combat-pilot',
                      'ngr-intelligence-officer', 'ngr-intelligence-commando')
         AND (instr(markdown, 'CATALOG CANNOT HOLD') > 0
              OR instr(markdown, 'vessel-shaped stat block') > 0
              OR instr(markdown, 'stat block this catalog does not hold') > 0
              OR instr(markdown, 'F3 vessel') > 0));

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~018-class-vessels.sql');
