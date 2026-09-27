-- Class notes made false by the vessel work: every class that still said a
-- vessel was missing, or could not be held, because of BOOK-INGEST-AUDIT.md F3.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~029-class-vessel-notes.sql
--
-- == WHY ==
--
-- F3 said `gear` had no shape for a vessel. PR #787 built `vehicles`, the
-- books' vessels have been imported into it since (#791 Triax, #1445 Phase
-- World), F41 settled that a class cites a vessel through a gear row carrying
-- `vehicle_slug`, and #1450 (~018-class-vessels.sql) used that shape for four
-- classes. Its search left the rest of the notes naming F3, and this file is
-- the sweep: production searched on 2026-09-27 for instr(markdown, 'F3'),
-- 'no vehicles row', 'not gear here' and 'vehicles are not gear'.
--
-- == WHAT GOES IN ==
--
-- One gear pointer row, `x-60-flanker`, whose slug is its vessel's own (Triax
-- p.51-54, a vessel since #791). Figures copied from the vessel row in
-- production on 2026-09-27: mdc is the main body, cost the vessel's cost,
-- weight its printed 1000 lbs.
--
-- ngr-police: printed 174 issues "X-60 Flanker and/or hovercycle or hover
--   pod". equipment_starting has no and/or, so it offers a choice of the
--   Flanker pointer or the generic `hovercycle` row, and a restriction line
--   says a GM may issue both. The hover pod names no machine.
-- ngr-cyborg-soldier, ngr-robot-soldier: the body is the character, as the
--   Mining 'Borg's is (#1450), so a restriction line names the vessel rows and
--   there is no gear pointer. Printed 99 lists EIGHT VX cyborgs and points at
--   the EIC-100 (the old note said five); printed 169 names the DV-13, which
--   the book never stats, so it has no row.
-- cs-rpa-fly-boy-ace: CWC printed 85 issues a "hovercycle or jeep" and names
--   no model, so equipment_starting offers a choice of the generic
--   `hovercycle` and `jeep` gear rows. #1450 kept it prose because no
--   Coalition VESSEL existed to point at; the generic gear rows were there.
--
-- == WHAT IS ONLY REWORDED ==
--
-- noro-mystic-warrior: its gear row points at its vessel since #860.
-- cs-special-forces: an open list ("etc.") with no generic motorcycle row.
--   cs-commando prints the same list and gets the same reason.
-- iss-peacekeeper, iss-specter, iss-intel-specter, ntset-protector,
--   ntset-psi-hound, psi-net-agent: the vehicles are on assignment, not
--   standard issue, which is the reason they were never starting equipment.
-- galactic-tracer, space-pirate, runner, naruni-repo-bot (Phase World): an
--   optional or unnamed vessel, so nothing to list; the runner's note names
--   the book's `typical-runner-ship` row.
-- salvage-expert (Underseas): two of its four options are generic gear rows
--   (`sailboat-large`, `cabin-cruiser`) and two have none, so a choice would
--   offer half the list; it stays a restriction line with that reason.
-- cs-commando (CWC), nb-sorcerer and nb-psychic (Nightbane): these cite no
--   F3, and a verification pass found them giving the same retired reason -
--   a vehicle is not gear. Reworded to the book naming no model.
--
-- NOT CHANGED, on purpose: the Heroes Unlimited power categories that cite F3
-- (hu-aliens, hu-bionics, hu-hardware, hu-mutants, hu-robotics,
-- hu-secret-operative) say the catalog has no BUILDER for a constructed
-- robot, bionic body or vehicle, which is still true; and
-- fq-descended-glitter-boy-pilot, fq-gb-reloader, fq-side-kick-rpa,
-- ngr-power-armor-commando and ngr-robot-combat-pilot, whose F3 mentions are
-- already past-tense decisions.
--
-- Class markdown is edited with replace(), guarded on the text it replaces
-- AND on the replacement being absent, so a re-run is a no-op.
--
-- == FILENAME ==
--
-- `~` sorts after every `z` tier, so this runs after every file that creates
-- the rows it edits, including ~018-class-vessels.sql, whose fly-boy
-- wording it replaces. ~029 is this change's claimed number. Sort checked.

INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, is_mega_damage,
   mdc, description, source_book, vehicle_slug)
VALUES
  ('x-60-flanker', 'X-60 Flanker Power Armor', 'rifts', 'vehicle',
   1000, 500000,
   'Black Market Cost: 500,000 credits in perfect condition and fully loaded. Very poor availability. Not offered by Triax in the mass market.',
   1, 380,
   'NGR power armour, issued to the Police O.C.C. as "X-60 Flanker and/or hovercycle or hover pod" (printed 174). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.',
   'Rifts World Book 5: Triax and the NGR p.51-54', 'x-60-flanker');

-- ---------------------------------------------------------------------------
-- The class edits, one guarded replace() each.
-- ---------------------------------------------------------------------------

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || 'extraction_notes: |',
  '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || '  - { choose: 1, label: "X-60 Flanker or hovercycle", qty: 1, from: ["x-60-flanker", "hovercycle"] }' || char(10) || 'restrictions:' || char(10) || '  - "ISSUED AN X-60 FLANKER AND/OR A HOVERCYCLE OR HOVER POD (printed 174). The starting equipment offers the Flanker or a hovercycle; a GM may issue both, and a hover pod in place of the hovercycle."' || char(10) || 'extraction_notes: |')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || 'extraction_notes: |') > 0
    AND instr(markdown, '  - { item_id: "dress-uniform", qty: 1 }' || char(10) || '  - { choose: 1, label: "X-60 Flanker or hovercycle", qty: 1, from: ["x-60-flanker", "hovercycle"] }' || char(10) || 'restrictions:' || char(10) || '  - "ISSUED AN X-60 FLANKER AND/OR A HOVERCYCLE OR HOVER POD (printed 174). The starting equipment offers the Flanker or a hovercycle; a GM may issue both, and a hover pod in place of the hovercycle."' || char(10) || 'extraction_notes: |') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - The X-60 Flanker and the hovercycle or hover pod issued alongside are NOT' || char(10) || '    stored: the Flanker is a BOOK-INGEST-AUDIT.md F3 vessel, as are the T-11' || char(10) || '    Enhanced body armour, X-10A Predator and X-535 Jager offered on assignment.' || char(10) || '    In the body.' || char(10) || '',
  '  - THE X-60 FLANKER IS IN equipment_starting since 2026-09-27' || char(10) || '    (~029-class-vessel-notes.sql), as a choice against the generic hovercycle.' || char(10) || '    Printed 174 issues "X-60 Flanker and/or hovercycle or hover pod";' || char(10) || '    equipment_starting has no and/or, so the player picks one and a restriction' || char(10) || '    line says a GM may issue both. The Flanker is the `x-60-flanker` gear row,' || char(10) || '    which points at the vessel of the same slug (#791) the way' || char(10) || '    `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41. The hover pod' || char(10) || '    names no machine: the only NGR pods in `vehicles` are the XM-50, XM-60 and' || char(10) || '    XM-70 medic, mechanic and covert-operations pods. Until then this note said' || char(10) || '    the Flanker, and the T-11 Enhanced body armour, X-10A Predator and X-535' || char(10) || '    Jager offered on assignment, were F3 vessels the catalog could not hold:' || char(10) || '    the T-11 is a gear row (printed 35) and the other three are vessel rows' || char(10) || '    since #791. What comes on assignment stays in the body.' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - The X-60 Flanker and the hovercycle or hover pod issued alongside are NOT' || char(10) || '    stored: the Flanker is a BOOK-INGEST-AUDIT.md F3 vessel, as are the T-11' || char(10) || '    Enhanced body armour, X-10A Predator and X-535 Jager offered on assignment.' || char(10) || '    In the body.' || char(10) || '') > 0
    AND instr(markdown, '  - THE X-60 FLANKER IS IN equipment_starting since 2026-09-27' || char(10) || '    (~029-class-vessel-notes.sql), as a choice against the generic hovercycle.' || char(10) || '    Printed 174 issues "X-60 Flanker and/or hovercycle or hover pod";' || char(10) || '    equipment_starting has no and/or, so the player picks one and a restriction' || char(10) || '    line says a GM may issue both. The Flanker is the `x-60-flanker` gear row,' || char(10) || '    which points at the vessel of the same slug (#791) the way' || char(10) || '    `glitter-boy-power-armor` does - BOOK-INGEST-AUDIT.md F41. The hover pod' || char(10) || '    names no machine: the only NGR pods in `vehicles` are the XM-50, XM-60 and' || char(10) || '    XM-70 medic, mechanic and covert-operations pods. Until then this note said' || char(10) || '    the Flanker, and the T-11 Enhanced body armour, X-10A Predator and X-535' || char(10) || '    Jager offered on assignment, were F3 vessels the catalog could not hold:' || char(10) || '    the T-11 is a gear row (printed 35) and the other three are vessel rows' || char(10) || '    since #791. What comes on assignment stays in the body.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Also the X-60 Flanker and a hovercycle or hover pod, which are vessel-shaped stat blocks this catalog does not hold.',
  'Also the X-60 Flanker and/or a hovercycle or hover pod: the starting equipment offers the Flanker or a hovercycle, and a GM may issue both.')
  WHERE class_id = 'ngr-police' AND instr(markdown, 'Also the X-60 Flanker and a hovercycle or hover pod, which are vessel-shaped stat blocks this catalog does not hold.') > 0
    AND instr(markdown, 'Also the X-60 Flanker and/or a hovercycle or hover pod: the starting equipment offers the Flanker or a hovercycle, and a GM may issue both.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "walkie-talkie", qty: 1 }' || char(10) || 'extraction_notes: |',
  '  - { item_id: "walkie-talkie", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "THE BODY IS ONE OF NINE CHASSIS, printed 99-117: the `vx-300-striker`, `vx-320-cyclops`, `vx-340-slasher`, `vx-370-stopper`, `vx-500-manhunter`, `vx-635-prowler`, `vx-2010-marauder` and `vx-2020-monster` vessel rows - the eight standard combat cyborgs printed 99 lists - and the `eic-100-gurgoyle-cyborg` that page points to. Each row carries the chassis''s M.D.C. by location and weapon systems."' || char(10) || 'extraction_notes: |')
  WHERE class_id = 'ngr-cyborg-soldier' AND instr(markdown, '  - { item_id: "walkie-talkie", qty: 1 }' || char(10) || 'extraction_notes: |') > 0
    AND instr(markdown, '  - { item_id: "walkie-talkie", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "THE BODY IS ONE OF NINE CHASSIS, printed 99-117: the `vx-300-striker`, `vx-320-cyclops`, `vx-340-slasher`, `vx-370-stopper`, `vx-500-manhunter`, `vx-635-prowler`, `vx-2010-marauder` and `vx-2020-monster` vessel rows - the eight standard combat cyborgs printed 99 lists - and the `eic-100-gurgoyle-cyborg` that page points to. Each row carries the chassis''s M.D.C. by location and weapon systems."' || char(10) || 'extraction_notes: |') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THE CLASS''S OWN BODY IS A VESSEL THIS CATALOG CANNOT HOLD, which is a' || char(10) || '    sharper occurrence of BOOK-INGEST-AUDIT.md F3 than the ones recorded so far.' || char(10) || '    Printed 161 says a cyborg soldier must be a partial or full conversion' || char(10) || '    cyborg and that any of the borg designs in the book''s own cybernetics and' || char(10) || '    borg section, printed 99-116, is available as a player character. Those five' || char(10) || '    designs are F3 vessels, so the class ships with NO mdc_base: its M.D.C.,' || char(10) || '    its P.S. and its speed all live in a chassis the catalog has no row for. A' || char(10) || '    character built from this class gets the core S.D.C. rule instead, which is' || char(10) || '    a human''s. The GM supplies the chassis from the book.' || char(10) || '',
  '  - THE CLASS''S OWN BODY IS A CHOICE OF VESSEL ROWS, and a restriction line' || char(10) || '    names them since 2026-09-27 (~029-class-vessel-notes.sql). Printed 161 says a cyborg' || char(10) || '    soldier must be a partial or full conversion cyborg and that any of the' || char(10) || '    cyborgs in the book''s cybernetics and borg section is available as a player' || char(10) || '    character. Printed 99 lists that section''s eight standard combat cyborgs,' || char(10) || '    VX-300 to VX-2020, and points at the EIC-100 as well; all nine are' || char(10) || '    `vehicles` rows since #791. The body is the character rather than something' || char(10) || '    issued to it, so there is no gear pointer - the Mining ''Borg and the Free' || char(10) || '    Quebec cyborgs do the same. The class still states NO mdc_base: its M.D.C.,' || char(10) || '    P.S. and speed are the chosen chassis''s, which the class cannot pick for the' || char(10) || '    player, so a character built from it gets the core S.D.C. rule and the GM' || char(10) || '    applies the chassis row. Until then this note said the catalog had no row' || char(10) || '    for the chassis, under BOOK-INGEST-AUDIT.md F3, and counted five designs' || char(10) || '    where printed 99 prints eight.' || char(10) || '')
  WHERE class_id = 'ngr-cyborg-soldier' AND instr(markdown, '  - THE CLASS''S OWN BODY IS A VESSEL THIS CATALOG CANNOT HOLD, which is a' || char(10) || '    sharper occurrence of BOOK-INGEST-AUDIT.md F3 than the ones recorded so far.' || char(10) || '    Printed 161 says a cyborg soldier must be a partial or full conversion' || char(10) || '    cyborg and that any of the borg designs in the book''s own cybernetics and' || char(10) || '    borg section, printed 99-116, is available as a player character. Those five' || char(10) || '    designs are F3 vessels, so the class ships with NO mdc_base: its M.D.C.,' || char(10) || '    its P.S. and its speed all live in a chassis the catalog has no row for. A' || char(10) || '    character built from this class gets the core S.D.C. rule instead, which is' || char(10) || '    a human''s. The GM supplies the chassis from the book.' || char(10) || '') > 0
    AND instr(markdown, '  - THE CLASS''S OWN BODY IS A CHOICE OF VESSEL ROWS, and a restriction line' || char(10) || '    names them since 2026-09-27 (~029-class-vessel-notes.sql). Printed 161 says a cyborg' || char(10) || '    soldier must be a partial or full conversion cyborg and that any of the' || char(10) || '    cyborgs in the book''s cybernetics and borg section is available as a player' || char(10) || '    character. Printed 99 lists that section''s eight standard combat cyborgs,' || char(10) || '    VX-300 to VX-2020, and points at the EIC-100 as well; all nine are' || char(10) || '    `vehicles` rows since #791. The body is the character rather than something' || char(10) || '    issued to it, so there is no gear pointer - the Mining ''Borg and the Free' || char(10) || '    Quebec cyborgs do the same. The class still states NO mdc_base: its M.D.C.,' || char(10) || '    P.S. and speed are the chosen chassis''s, which the class cannot pick for the' || char(10) || '    player, so a character built from it gets the core S.D.C. rule and the GM' || char(10) || '    applies the chassis row. Until then this note said the catalog had no row' || char(10) || '    for the chassis, under BOOK-INGEST-AUDIT.md F3, and counted five designs' || char(10) || '    where printed 99 prints eight.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Printed 161 says any of the borg designs in the book''s cybernetics and borg section, printed 99-116, is available as a player character, and those are giant machine stat blocks this catalog does not store. The GM picks the design from the book and supplies its M.D.C., P.S., speed and weapon systems.',
  'Printed 161 says any of the cyborgs in the book''s cybernetics and borg section is available as a player character: the eight VX-series combat cyborgs of printed 99-117, and the EIC-100 that section points to. Each is a vessel row with its M.D.C. by location and weapon systems, named in the restrictions. The GM picks the design and applies its M.D.C., P.S., speed and weapon systems.')
  WHERE class_id = 'ngr-cyborg-soldier' AND instr(markdown, 'Printed 161 says any of the borg designs in the book''s cybernetics and borg section, printed 99-116, is available as a player character, and those are giant machine stat blocks this catalog does not store. The GM picks the design from the book and supplies its M.D.C., P.S., speed and weapon systems.') > 0
    AND instr(markdown, 'Printed 161 says any of the cyborgs in the book''s cybernetics and borg section is available as a player character: the eight VX-series combat cyborgs of printed 99-117, and the EIC-100 that section points to. Each is a vessel row with its M.D.C. by location and weapon systems, named in the restrictions. The GM picks the design and applies its M.D.C., P.S., speed and weapon systems.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '    - { level: 12, combat: { attacks: 1 } }' || char(10) || 'extraction_notes: |',
  '    - { level: 12, combat: { attacks: 1 } }' || char(10) || 'restrictions:' || char(10) || '  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, each a vessel row: any EIR (`eir-10-gargoyle-drone`, `eir-15-gargoyle-manned-robot`, `eir-20-gurgoyle-drone`, `eir-30-gargoylite-drone`, `eir-50-gurgoyle-android`), `dv-12-dyna-bot`, `dv-15-sentry-bot`, `dv-40-hunter-killer-drone`, and a modified `x-545-super-hunter`, `x-2000-dyna-max`, `x-2500-black-knight` or `x-2700-dragonwing`. The DV-13 Dyna-Bot the page also names is statted nowhere in the book."' || char(10) || 'extraction_notes: |')
  WHERE class_id = 'ngr-robot-soldier' AND instr(markdown, '    - { level: 12, combat: { attacks: 1 } }' || char(10) || 'extraction_notes: |') > 0
    AND instr(markdown, '    - { level: 12, combat: { attacks: 1 } }' || char(10) || 'restrictions:' || char(10) || '  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, each a vessel row: any EIR (`eir-10-gargoyle-drone`, `eir-15-gargoyle-manned-robot`, `eir-20-gurgoyle-drone`, `eir-30-gargoylite-drone`, `eir-50-gurgoyle-android`), `dv-12-dyna-bot`, `dv-15-sentry-bot`, `dv-40-hunter-killer-drone`, and a modified `x-545-super-hunter`, `x-2000-dyna-max`, `x-2500-black-knight` or `x-2700-dragonwing`. The DV-13 Dyna-Bot the page also names is statted nowhere in the book."' || char(10) || 'extraction_notes: |') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THE BODY IS A VESSEL THIS CATALOG CANNOT HOLD, per BOOK-INGEST-AUDIT.md F3,' || char(10) || '    and the effect is larger here than on any other class in this book. Printed' || char(10) || '    169 lists the nine machines a robot soldier may be built into - any EIR, the' || char(10) || '    DV-12, DV-13, DV-15 and DV-40 bots, and modified X-545, X-2000, X-2500 and' || char(10) || '    X-2700 robot vehicles - and every one is an F3 vessel. The class therefore' || char(10) || '    states no mdc_base, no attribute_dice and no speed: printed 169 says' || char(10) || '    strength, speed, leaping, flight and weapon systems are exactly the robot''s' || char(10) || '    own. A character built from this class has the bonuses below and a body the' || char(10) || '    GM supplies from the book.' || char(10) || '',
  '  - THE BODY IS A CHOICE OF VESSEL ROWS, and a restriction line names them' || char(10) || '    since 2026-09-27 (~029-class-vessel-notes.sql). Printed 169 lists the nine lines a' || char(10) || '    robot soldier may be built from - any EIR, the DV-12, DV-13, DV-15 and DV-40' || char(10) || '    bots, and modified X-545, X-2000, X-2500 and X-2700 robot vehicles - and' || char(10) || '    twelve `vehicles` rows answer them since #791: the five EIR units, three DV' || char(10) || '    bots and four X-series robots. THE DV-13 HAS NO ROW because the book stats' || char(10) || '    none; its robot section prints the DV-12, DV-15 and DV-40 only. The body is' || char(10) || '    the character, not issued kit, so there is no gear pointer, as with the' || char(10) || '    Mining ''Borg. The class still states no mdc_base, no attribute_dice and no' || char(10) || '    speed: printed 169 says strength, speed, leaping, flight and weapon systems' || char(10) || '    are exactly the robot''s own, so the GM applies the chosen row. Until then' || char(10) || '    this note said every one of the nine was a BOOK-INGEST-AUDIT.md F3 vessel' || char(10) || '    the catalog could not hold.' || char(10) || '')
  WHERE class_id = 'ngr-robot-soldier' AND instr(markdown, '  - THE BODY IS A VESSEL THIS CATALOG CANNOT HOLD, per BOOK-INGEST-AUDIT.md F3,' || char(10) || '    and the effect is larger here than on any other class in this book. Printed' || char(10) || '    169 lists the nine machines a robot soldier may be built into - any EIR, the' || char(10) || '    DV-12, DV-13, DV-15 and DV-40 bots, and modified X-545, X-2000, X-2500 and' || char(10) || '    X-2700 robot vehicles - and every one is an F3 vessel. The class therefore' || char(10) || '    states no mdc_base, no attribute_dice and no speed: printed 169 says' || char(10) || '    strength, speed, leaping, flight and weapon systems are exactly the robot''s' || char(10) || '    own. A character built from this class has the bonuses below and a body the' || char(10) || '    GM supplies from the book.' || char(10) || '') > 0
    AND instr(markdown, '  - THE BODY IS A CHOICE OF VESSEL ROWS, and a restriction line names them' || char(10) || '    since 2026-09-27 (~029-class-vessel-notes.sql). Printed 169 lists the nine lines a' || char(10) || '    robot soldier may be built from - any EIR, the DV-12, DV-13, DV-15 and DV-40' || char(10) || '    bots, and modified X-545, X-2000, X-2500 and X-2700 robot vehicles - and' || char(10) || '    twelve `vehicles` rows answer them since #791: the five EIR units, three DV' || char(10) || '    bots and four X-series robots. THE DV-13 HAS NO ROW because the book stats' || char(10) || '    none; its robot section prints the DV-12, DV-15 and DV-40 only. The body is' || char(10) || '    the character, not issued kit, so there is no gear pointer, as with the' || char(10) || '    Mining ''Borg. The class still states no mdc_base, no attribute_dice and no' || char(10) || '    speed: printed 169 says strength, speed, leaping, flight and weapon systems' || char(10) || '    are exactly the robot''s own, so the GM applies the chosen row. Until then' || char(10) || '    this note said every one of the nine was a BOOK-INGEST-AUDIT.md F3 vessel' || char(10) || '    the catalog could not hold.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'None of those nine is stored. Strength, speed, leaping, flight and weapon systems are the robot''s own, from the book''s robot section; the GM supplies them.',
  'Each is a vessel row, named in the restrictions, except the DV-13, which the book never stats. Strength, speed, leaping, flight and weapon systems are the robot''s own, from that row; the GM applies them.')
  WHERE class_id = 'ngr-robot-soldier' AND instr(markdown, 'None of those nine is stored. Strength, speed, leaping, flight and weapon systems are the robot''s own, from the book''s robot section; the GM supplies them.') > 0
    AND instr(markdown, 'Each is a vessel row, named in the restrictions, except the DV-13, which the book never stats. Strength, speed, leaping, flight and weapon systems are the robot''s own, from that row; the GM applies them.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '    The book gives it on printed 128-130 as a power armor stat block, and one' || char(10) || '    `gear` row holds it the way all 35 vehicle rows do: `mdc` is the MAIN BODY' || char(10) || '    (210), the six locations are in the description, and all six weapon systems' || char(10) || '    are in `damage` as prose. That is lossy and deliberate - BOOK-INGEST-AUDIT.md' || char(10) || '    F3 records what a vessel row cannot hold, and this class is why the cheap' || char(10) || '    half of it was taken: a character sheet was wrong every time one was rolled.' || char(10) || '',
  '    The book gives it on printed 128-130 as a power armor stat block. The' || char(10) || '    `psionic-power-armor` gear row the class lists carries `mdc` as the MAIN' || char(10) || '    BODY (210), with the six locations in its description and the six weapon' || char(10) || '    systems in `damage` as prose, and it points at the vessel of the same slug' || char(10) || '    (#860, BOOK-INGEST-AUDIT.md F41), whose six locations and six weapon' || char(10) || '    systems are rows of their own. Until 2026-09-27 (~029-class-vessel-notes.sql)' || char(10) || '    this note called the gear row lossy under F3; it was, when the class shipped' || char(10) || '    and before F41 gave it a vessel. F3 is why the gear row was made at all: a' || char(10) || '    character sheet was wrong every time one was rolled.' || char(10) || '')
  WHERE class_id = 'noro-mystic-warrior' AND instr(markdown, '    The book gives it on printed 128-130 as a power armor stat block, and one' || char(10) || '    `gear` row holds it the way all 35 vehicle rows do: `mdc` is the MAIN BODY' || char(10) || '    (210), the six locations are in the description, and all six weapon systems' || char(10) || '    are in `damage` as prose. That is lossy and deliberate - BOOK-INGEST-AUDIT.md' || char(10) || '    F3 records what a vessel row cannot hold, and this class is why the cheap' || char(10) || '    half of it was taken: a character sheet was wrong every time one was rolled.' || char(10) || '') > 0
    AND instr(markdown, '    The book gives it on printed 128-130 as a power armor stat block. The' || char(10) || '    `psionic-power-armor` gear row the class lists carries `mdc` as the MAIN' || char(10) || '    BODY (210), with the six locations in its description and the six weapon' || char(10) || '    systems in `damage` as prose, and it points at the vessel of the same slug' || char(10) || '    (#860, BOOK-INGEST-AUDIT.md F41), whose six locations and six weapon' || char(10) || '    systems are rows of their own. Until 2026-09-27 (~029-class-vessel-notes.sql)' || char(10) || '    this note called the gear row lossy under F3; it was, when the class shipped' || char(10) || '    and before F41 gave it a vessel. F3 is why the gear row was made at all: a' || char(10) || '    character sheet was wrong every time one was rolled.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'which is not in equipment_starting because vehicles are not gear here; see extraction_notes.',
  'which is not in equipment_starting: the book leaves the choice open and names no model; see extraction_notes.')
  WHERE class_id = 'cs-special-forces' AND instr(markdown, 'which is not in equipment_starting because vehicles are not gear here; see extraction_notes.') > 0
    AND instr(markdown, 'which is not in equipment_starting: the book leaves the choice open and names no model; see extraction_notes.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The vehicle for daily use is prose; see BOOK-INGEST-AUDIT.md F3.',
  'The vehicle for daily use is a restriction line rather than a choice: printed 87 gives it as a conventional military vehicle of choice (motorcycle, jeep, hovercycle, etc.), an open list, and the catalog has generic hovercycle and jeep rows but no generic motorcycle, so a choice would close it. Decided 2026-09-27 (~029-class-vessel-notes.sql); this cited BOOK-INGEST-AUDIT.md F3 until then.')
  WHERE class_id = 'cs-special-forces' AND instr(markdown, 'The vehicle for daily use is prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'The vehicle for daily use is a restriction line rather than a choice: printed 87 gives it as a conventional military vehicle of choice (motorcycle, jeep, hovercycle, etc.), an open list, and the catalog has generic hovercycle and jeep rows but no generic motorcycle, so a choice would close it. Decided 2026-09-27 (~029-class-vessel-notes.sql); this cited BOOK-INGEST-AUDIT.md F3 until then.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'iss-peacekeeper' AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'iss-specter' AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'iss-intel-specter' AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'ntset-protector' AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'psi-net-agent' AND instr(markdown, 'Vehicles are prose; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles are a restriction line because the book lists them under equipment available upon assignment, not standard issue, so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - "Vehicles are not issued as gear: usually',
  '  - "Vehicles come on assignment, not as standard issue: usually')
  WHERE class_id = 'iss-peacekeeper' AND instr(markdown, '  - "Vehicles are not issued as gear: usually') > 0
    AND instr(markdown, '  - "Vehicles come on assignment, not as standard issue: usually') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - "Vehicles are not issued as gear: usually',
  '  - "Vehicles come on assignment, not as standard issue: usually')
  WHERE class_id = 'iss-specter' AND instr(markdown, '  - "Vehicles are not issued as gear: usually') > 0
    AND instr(markdown, '  - "Vehicles come on assignment, not as standard issue: usually') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - "Vehicles are not issued as gear: usually',
  '  - "Vehicles come on assignment, not as standard issue: usually')
  WHERE class_id = 'iss-intel-specter' AND instr(markdown, '  - "Vehicles are not issued as gear: usually') > 0
    AND instr(markdown, '  - "Vehicles come on assignment, not as standard issue: usually') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'They are not in equipment_starting because vehicles are not gear here; see extraction_notes.',
  'They come on assignment rather than as standard issue, so they are not in equipment_starting; see extraction_notes.')
  WHERE class_id = 'ntset-protector' AND instr(markdown, 'They are not in equipment_starting because vehicles are not gear here; see extraction_notes.') > 0
    AND instr(markdown, 'They come on assignment rather than as standard issue, so they are not in equipment_starting; see extraction_notes.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'They are not in equipment_starting because vehicles are not gear here; see extraction_notes.',
  'They come on assignment rather than as standard issue, so they are not in equipment_starting; see extraction_notes.')
  WHERE class_id = 'psi-net-agent' AND instr(markdown, 'They are not in equipment_starting because vehicles are not gear here; see extraction_notes.') > 0
    AND instr(markdown, 'They come on assignment rather than as standard issue, so they are not in equipment_starting; see extraction_notes.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Vehicles: seldom issued; see BOOK-INGEST-AUDIT.md F3.',
  'Vehicles: seldom issued, and only on assignment (printed 188), so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).')
  WHERE class_id = 'ntset-psi-hound' AND instr(markdown, 'Vehicles: seldom issued; see BOOK-INGEST-AUDIT.md F3.') > 0
    AND instr(markdown, 'Vehicles: seldom issued, and only on assignment (printed 188), so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql).') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting: the book names no model, and the catalog holds no Coalition hovercycle or jeep vessel to point at - see extraction_notes."' || char(10) || '',
  '  - { item_id: "canteen", qty: 1 }' || char(10) || '  - { choose: 1, label: "hovercycle or jeep", qty: 1, from: ["hovercycle", "jeep"] }' || char(10) || 'restrictions:' || char(10) || '')
  WHERE class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "ISSUED A HOVERCYCLE OR JEEP, which is not in equipment_starting: the book names no model, and the catalog holds no Coalition hovercycle or jeep vessel to point at - see extraction_notes."' || char(10) || '') > 0
    AND instr(markdown, '  - { item_id: "canteen", qty: 1 }' || char(10) || '  - { choose: 1, label: "hovercycle or jeep", qty: 1, from: ["hovercycle", "jeep"] }' || char(10) || 'restrictions:' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The hovercycle or jeep lives in restrictions. Printed 85 names no model, and on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles`, so the gear-pointer shape the Side Kick RPA took that day (BOOK-INGEST-AUDIT.md F41) had nothing to point at.',
  'THE HOVERCYCLE OR JEEP IS A CHOICE IN equipment_starting since 2026-09-27 (~029-class-vessel-notes.sql), over the generic `hovercycle` and `jeep` gear rows. Printed 85 names no model, so neither is a vessel pointer; a GM who wants a statted machine has the vessel rows. Until then it was a restriction line: on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles` for the gear-pointer shape (BOOK-INGEST-AUDIT.md F41), and before that the line said vehicles were not gear.')
  WHERE class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, 'The hovercycle or jeep lives in restrictions. Printed 85 names no model, and on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles`, so the gear-pointer shape the Side Kick RPA took that day (BOOK-INGEST-AUDIT.md F41) had nothing to point at.') > 0
    AND instr(markdown, 'THE HOVERCYCLE OR JEEP IS A CHOICE IN equipment_starting since 2026-09-27 (~029-class-vessel-notes.sql), over the generic `hovercycle` and `jeep` gear rows. Printed 85 names no model, so neither is a vessel pointer; a GM who wants a statted machine has the vessel rows. Until then it was a restriction line: on 2026-09-26 (~018-class-vessels.sql) the catalog held no Coalition hovercycle or jeep in `vehicles` for the gear-pointer shape (BOOK-INGEST-AUDIT.md F41), and before that the line said vehicles were not gear.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THE SMALL SPACESHIP IS NOT IMPORTED. "The GM can also let the character own' || char(10) || '    a small spaceship (capacity for 2 to 8 passengers and a little cargo)" - it' || char(10) || '    is optional by the book''s own wording, and `gear` has no shape for a vessel' || char(10) || '    in any case. See BOOK-INGEST-AUDIT.md F3. It is in the GM Notes.' || char(10) || '',
  '  - THE SMALL SPACESHIP IS NOT IN equipment_starting. "The GM can also let the' || char(10) || '    character own a small spaceship (capacity for 2 to 8 passengers and a' || char(10) || '    little cargo)" - it is optional by the book''s own wording and names no' || char(10) || '    model, so there is nothing to list. It is in the GM Notes. Until' || char(10) || '    2026-09-27 (~029-class-vessel-notes.sql) this note also cited BOOK-INGEST-AUDIT.md' || char(10) || '    F3; a class lists an issued vessel through a gear row pointing at it since' || char(10) || '    #1450 (F41), and this book''s ships are `vehicles` rows since #1445.' || char(10) || '')
  WHERE class_id = 'galactic-tracer' AND instr(markdown, '  - THE SMALL SPACESHIP IS NOT IMPORTED. "The GM can also let the character own' || char(10) || '    a small spaceship (capacity for 2 to 8 passengers and a little cargo)" - it' || char(10) || '    is optional by the book''s own wording, and `gear` has no shape for a vessel' || char(10) || '    in any case. See BOOK-INGEST-AUDIT.md F3. It is in the GM Notes.' || char(10) || '') > 0
    AND instr(markdown, '  - THE SMALL SPACESHIP IS NOT IN equipment_starting. "The GM can also let the' || char(10) || '    character own a small spaceship (capacity for 2 to 8 passengers and a' || char(10) || '    little cargo)" - it is optional by the book''s own wording and names no' || char(10) || '    model, so there is nothing to list. It is in the GM Notes. Until' || char(10) || '    2026-09-27 (~029-class-vessel-notes.sql) this note also cited BOOK-INGEST-AUDIT.md' || char(10) || '    F3; a class lists an issued vessel through a gear row pointing at it since' || char(10) || '    #1450 (F41), and this book''s ships are `vehicles` rows since #1445.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THE SMALL SPACESHIP IS NOT IMPORTED, for the same reasons as the Galactic' || char(10) || '    Tracer''s: the book makes it the GM''s option, and `gear` has no shape for a' || char(10) || '    vessel. See BOOK-INGEST-AUDIT.md F3.' || char(10) || '',
  '  - THE SMALL SPACESHIP IS NOT IN equipment_starting, for the same reasons as' || char(10) || '    the Galactic Tracer''s: the book makes it the GM''s option and names no' || char(10) || '    model. Until 2026-09-27 (~029-class-vessel-notes.sql) this note also cited' || char(10) || '    BOOK-INGEST-AUDIT.md F3; this book''s ships are `vehicles` rows since #1445.' || char(10) || '')
  WHERE class_id = 'space-pirate' AND instr(markdown, '  - THE SMALL SPACESHIP IS NOT IMPORTED, for the same reasons as the Galactic' || char(10) || '    Tracer''s: the book makes it the GM''s option, and `gear` has no shape for a' || char(10) || '    vessel. See BOOK-INGEST-AUDIT.md F3.' || char(10) || '') > 0
    AND instr(markdown, '  - THE SMALL SPACESHIP IS NOT IN equipment_starting, for the same reasons as' || char(10) || '    the Galactic Tracer''s: the book makes it the GM''s option and names no' || char(10) || '    model. Until 2026-09-27 (~029-class-vessel-notes.sql) this note also cited' || char(10) || '    BOOK-INGEST-AUDIT.md F3; this book''s ships are `vehicles` rows since #1445.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'call)". Optional by the book''s own wording, and `gear` has no shape for a' || char(10) || '    vessel. See BOOK-INGEST-AUDIT.md F3.' || char(10) || '',
  'call)". Optional by the book''s own wording, so it is not in' || char(10) || '    equipment_starting. The book''s Typical Runner Ship (printed 171-172) is the' || char(10) || '    `typical-runner-ship` vessel row since #1445, for a GM who grants one.' || char(10) || '    Until 2026-09-27 (~029-class-vessel-notes.sql) this note cited' || char(10) || '    BOOK-INGEST-AUDIT.md F3 instead.' || char(10) || '')
  WHERE class_id = 'runner' AND instr(markdown, 'call)". Optional by the book''s own wording, and `gear` has no shape for a' || char(10) || '    vessel. See BOOK-INGEST-AUDIT.md F3.' || char(10) || '') > 0
    AND instr(markdown, 'call)". Optional by the book''s own wording, so it is not in' || char(10) || '    equipment_starting. The book''s Typical Runner Ship (printed 171-172) is the' || char(10) || '    `typical-runner-ship` vessel row since #1445, for a GM who grants one.' || char(10) || '    Until 2026-09-27 (~029-class-vessel-notes.sql) this note cited' || char(10) || '    BOOK-INGEST-AUDIT.md F3 instead.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THE SPACE SHUTTLE IS NOT IMPORTED. "They may also be given a space shuttle' || char(10) || '    with an FTL drive for travel and pursuit" is conditional and is a vessel:' || char(10) || '    `gear` has one `mdc`, one `damage`, one `range` and one `payload`, and this' || char(10) || '    book''s 25 vessels are out of scope for the same reason. See' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The receipts',
  '  - THE SPACE SHUTTLE IS NOT IN equipment_starting. "They may also be given a' || char(10) || '    space shuttle with an FTL drive for travel and pursuit" is conditional and' || char(10) || '    names no model. This book''s vessels are `vehicles` rows since #1445 and' || char(10) || '    none is a Naruni shuttle, so there is nothing to point at. Until' || char(10) || '    2026-09-27 (~029-class-vessel-notes.sql) this note called them out of scope under' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The receipts')
  WHERE class_id = 'naruni-repo-bot' AND instr(markdown, '  - THE SPACE SHUTTLE IS NOT IMPORTED. "They may also be given a space shuttle' || char(10) || '    with an FTL drive for travel and pursuit" is conditional and is a vessel:' || char(10) || '    `gear` has one `mdc`, one `damage`, one `range` and one `payload`, and this' || char(10) || '    book''s 25 vessels are out of scope for the same reason. See' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The receipts') > 0
    AND instr(markdown, '  - THE SPACE SHUTTLE IS NOT IN equipment_starting. "They may also be given a' || char(10) || '    space shuttle with an FTL drive for travel and pursuit" is conditional and' || char(10) || '    names no model. This book''s vessels are `vehicles` rows since #1445 and' || char(10) || '    none is a Naruni shuttle, so there is nothing to point at. Until' || char(10) || '    2026-09-27 (~029-class-vessel-notes.sql) this note called them out of scope under' || char(10) || '    BOOK-INGEST-AUDIT.md F3. The receipts') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'None of the four is in the starting equipment, because the catalog has no vessel rows for the first three - see BOOK-INGEST-AUDIT.md F3 on gear having no shape for a vessel.',
  'None of the four is in the starting equipment: the large sailboat and the cabin cruiser are generic gear rows, but the submersible and the power armour name no model and have none, so a choice would offer half of what the book offers.')
  WHERE class_id = 'salvage-expert' AND instr(markdown, 'None of the four is in the starting equipment, because the catalog has no vessel rows for the first three - see BOOK-INGEST-AUDIT.md F3 on gear having no shape for a vessel.') > 0
    AND instr(markdown, 'None of the four is in the starting equipment: the large sailboat and the cabin cruiser are generic gear rows, but the submersible and the power armour name no model and have none, so a choice would offer half of what the book offers.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '    suit of power armour. Three of those four are vessels, and the catalog has' || char(10) || '    no shape for a vessel in `gear` - BOOK-INGEST-AUDIT.md F3. It is a' || char(10) || '    restriction line so the choice is at least visible.' || char(10) || '',
  '    suit of power armour, and names no model for any of them. Two have generic' || char(10) || '    gear rows from printed 135-136, `sailboat-large` and `cabin-cruiser`; the' || char(10) || '    two- to six-man submersible and the power armour have none (this book''s' || char(10) || '    mini-subs are named-model `vehicles` rows), so a choice would offer two of' || char(10) || '    the four and it stays a restriction line. Until 2026-09-27 (~029-class-vessel-notes.sql)' || char(10) || '    this note gave the reason as BOOK-INGEST-AUDIT.md F3.' || char(10) || '')
  WHERE class_id = 'salvage-expert' AND instr(markdown, '    suit of power armour. Three of those four are vessels, and the catalog has' || char(10) || '    no shape for a vessel in `gear` - BOOK-INGEST-AUDIT.md F3. It is a' || char(10) || '    restriction line so the choice is at least visible.' || char(10) || '') > 0
    AND instr(markdown, '    suit of power armour, and names no model for any of them. Two have generic' || char(10) || '    gear rows from printed 135-136, `sailboat-large` and `cabin-cruiser`; the' || char(10) || '    two- to six-man submersible and the power armour have none (this book''s' || char(10) || '    mini-subs are named-model `vehicles` rows), so a choice would offer two of' || char(10) || '    the four and it stays a restriction line. Until 2026-09-27 (~029-class-vessel-notes.sql)' || char(10) || '    this note gave the reason as BOOK-INGEST-AUDIT.md F3.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The daily-use vehicle is a vehicle, not gear, and is in restrictions.',
  'The daily-use vehicle is in restrictions: printed 71 gives an open list (motorcycle, jeep, hovercycle, etc.), and the catalog has generic hovercycle and jeep gear rows but no generic motorcycle, so a choice would close it. Decided 2026-09-27 (~029-class-vessel-notes.sql); until then this said a vehicle was not gear.')
  WHERE class_id = 'cs-commando' AND instr(markdown, 'The daily-use vehicle is a vehicle, not gear, and is in restrictions.') > 0
    AND instr(markdown, 'The daily-use vehicle is in restrictions: printed 71 gives an open list (motorcycle, jeep, hovercycle, etc.), and the catalog has generic hovercycle and jeep gear rows but no generic motorcycle, so a choice would close it. Decided 2026-09-27 (~029-class-vessel-notes.sql); until then this said a vehicle was not gear.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'the car or jeep is not in equipment_starting because a vehicle is not a gear row (BOOK-INGEST-AUDIT F41); the chapter''s vehicle list holds compact-nb and jeep-4-wheel-drive-nb.',
  'the car or jeep is not in equipment_starting: printed 117 names no model, and the chapter''s compact-nb and jeep-4-wheel-drive-nb are `vehicles` rows that no gear row points at - the BOOK-INGEST-AUDIT F41 shape a class lists - and none was made. Until 2026-09-27 (~029-class-vessel-notes.sql) this gave a vehicle not being gear as the reason.')
  WHERE class_id = 'nb-sorcerer' AND instr(markdown, 'the car or jeep is not in equipment_starting because a vehicle is not a gear row (BOOK-INGEST-AUDIT F41); the chapter''s vehicle list holds compact-nb and jeep-4-wheel-drive-nb.') > 0
    AND instr(markdown, 'the car or jeep is not in equipment_starting: printed 117 names no model, and the chapter''s compact-nb and jeep-4-wheel-drive-nb are `vehicles` rows that no gear row points at - the BOOK-INGEST-AUDIT F41 shape a class lists - and none was made. Until 2026-09-27 (~029-class-vessel-notes.sql) this gave a vehicle not being gear as the reason.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'The vehicle is a vehicles-catalog row (for example compact-nb, small-truck-nb, motorcycle-light-nb), not a gear row, so it is not in equipment_starting.',
  'The vehicle is not in equipment_starting: the book names a kind, not a model, and the chapter''s vehicles (for example compact-nb, small-truck-nb, motorcycle-light-nb) are vehicles-catalog rows that no gear row points at.')
  WHERE class_id = 'nb-psychic' AND instr(markdown, 'The vehicle is a vehicles-catalog row (for example compact-nb, small-truck-nb, motorcycle-light-nb), not a gear row, so it is not in equipment_starting.') > 0
    AND instr(markdown, 'The vehicle is not in equipment_starting: the book names a kind, not a model, and the chapter''s vehicles (for example compact-nb, small-truck-nb, motorcycle-light-nb) are vehicles-catalog rows that no gear row points at.') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'a basic car, pick-up truck or motorcycle - vehicle rows, not gear, so prose only.',
  'a basic car, pick-up truck or motorcycle - prose only, because the book names no model and no gear row points at the chapter''s vehicles rows. Decided 2026-09-27 (~029-class-vessel-notes.sql); until then this gave the vehicles not being gear as the reason.')
  WHERE class_id = 'nb-psychic' AND instr(markdown, 'a basic car, pick-up truck or motorcycle - vehicle rows, not gear, so prose only.') > 0
    AND instr(markdown, 'a basic car, pick-up truck or motorcycle - prose only, because the book names no model and no gear row points at the chapter''s vehicles rows. Decided 2026-09-27 (~029-class-vessel-notes.sql); until then this gave the vehicles not being gear as the reason.') = 0;

-- ---------------------------------------------------------------------------
-- Read-backs. INSERT OR IGNORE and a guarded replace() are both SILENT when
-- they do nothing, so every want is counted off THIS FILE.
-- ---------------------------------------------------------------------------

SELECT 'the Flanker gear pointer resolves to its vessel' AS assertion, count(*) AS got, 1 AS want
  FROM gear g JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.slug = 'x-60-flanker' AND g.vehicle_slug = 'x-60-flanker' AND g.mdc = v.mdc_main_body;

SELECT 'every option the two new choices name is a gear row' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug IN ('x-60-flanker', 'hovercycle', 'jeep');

SELECT 'the two classes offer their vehicle choice' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
  WHERE (class_id = 'ngr-police' AND instr(markdown, 'from: ["x-60-flanker", "hovercycle"]') > 0)
     OR (class_id = 'cs-rpa-fly-boy-ace' AND instr(markdown, 'from: ["hovercycle", "jeep"]') > 0
         AND instr(markdown, 'ISSUED A HOVERCYCLE OR JEEP') = 0);

SELECT 'the two NGR bodies name their vessel rows' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
  WHERE (class_id = 'ngr-cyborg-soldier' AND instr(markdown, '`vx-2020-monster` vessel rows') > 0
         AND instr(markdown, '`eic-100-gurgoyle-cyborg`') > 0)
     OR (class_id = 'ngr-robot-soldier' AND instr(markdown, '`eir-50-gurgoyle-android`') > 0
         AND instr(markdown, '`x-2700-dragonwing`') > 0);

SELECT 'every vessel row those two restriction lines name exists' AS assertion, count(*) AS got, 21 AS want
  FROM vehicles
  WHERE slug IN ('vx-300-striker', 'vx-320-cyclops', 'vx-340-slasher', 'vx-370-stopper',
                 'vx-500-manhunter', 'vx-635-prowler', 'vx-2010-marauder', 'vx-2020-monster',
                 'eic-100-gurgoyle-cyborg', 'eir-10-gargoyle-drone', 'eir-15-gargoyle-manned-robot',
                 'eir-20-gurgoyle-drone', 'eir-30-gargoylite-drone', 'eir-50-gurgoyle-android',
                 'dv-12-dyna-bot', 'dv-15-sentry-bot', 'dv-40-hunter-killer-drone',
                 'x-545-super-hunter', 'x-2000-dyna-max', 'x-2500-black-knight', 'x-2700-dragonwing');

SELECT 'and each rewritten class names this file' AS assertion, count(*) AS got, 20 AS want
  FROM imported_classes
  WHERE class_id IN ('ngr-police', 'ngr-cyborg-soldier', 'ngr-robot-soldier', 'noro-mystic-warrior',
                     'cs-special-forces', 'iss-peacekeeper', 'iss-specter', 'iss-intel-specter',
                     'ntset-protector', 'ntset-psi-hound', 'psi-net-agent', 'cs-rpa-fly-boy-ace',
                     'galactic-tracer', 'space-pirate', 'runner', 'naruni-repo-bot', 'salvage-expert',
                     'cs-commando', 'nb-sorcerer', 'nb-psychic')
    AND instr(markdown, '~029-class-vessel-notes.sql') > 0;

SELECT 'no class still says vehicles are not gear, or that a vessel cannot be held' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
  WHERE instr(markdown, 'not gear here') > 0
     OR instr(markdown, 'Vehicles are prose; see') > 0
     OR instr(markdown, 'VESSEL THIS CATALOG CANNOT HOLD') > 0
     OR instr(markdown, 'Flanker is a BOOK-INGEST-AUDIT.md F3 vessel') > 0
     OR instr(markdown, 'no shape for a vessel in') > 0
     OR instr(markdown, 'has no vessel rows for') > 0
     OR instr(markdown, 'vessel-shaped stat blocks this catalog does not hold') > 0
     OR instr(markdown, 'out of scope for the same reason') > 0
     OR instr(markdown, 'is a vehicle, not gear') > 0
     OR instr(markdown, 'because a vehicle is not a gear row') > 0
     OR instr(markdown, 'not a gear row, so') > 0
     OR instr(markdown, 'vehicle rows, not gear') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~029-class-vessel-notes.sql');
