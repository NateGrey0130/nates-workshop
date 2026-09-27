-- The NGR Police's weapons of choice and holster, the last items printed 174
-- issues that were still prose after ~035-ngr-police-nightstick.sql.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~036-ngr-police-weapons.sql
--
-- Printed 174: "automatic pistol of choice (typically 9 or 10 mm), energy
-- pistol of choice, energy rifle of choice (typically TX-42 or TX-16 pump
-- rifle) ... gun holster of choice (shoulder or waist)". Each "of choice" is a
-- choose: 1 over rows checked --remote on 2026-09-27:
--
--   automatic pistol - the four 9 mm automatic pistols of Revised Heroes
--     Unlimited printed 201-202, read off a render: no Rifts row is a
--     conventional automatic pistol and no row anywhere is 10 mm. The WZ-63
--     machine pistol and everything under HU's Sub-Machineguns heading
--     (printed 203) are left out. Rifts classes already grant HU firearms
--     (cs-commando, psi-slayer).
--   energy pistol - Triax's human-size energy pistols, printed 143-144. The
--     TX-5 pump pistol fires explosive cartridges and is left out.
--   energy rifle - the TX-42 and TX-16 the book names, then Triax's other
--     human-size energy rifles, printed 144-148. Giant-size weapons, rail guns
--     and missile launchers are left out.
--   holster - the Rifts `gun-holster` row, "A belt or shoulder holster",
--     which is the book's "shoulder or waist" as it stands.
--
-- Every UPDATE is keyed on class_id and guarded on its old text present and
-- its new text absent, so a re-run is a no-op.

UPDATE imported_classes SET markdown = replace(markdown,
  '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '',
  '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '  - { item_id: "gun-holster", qty: 1 }' || char(10) || '  - { choose: 1, label: "automatic pistol", qty: 1, from: ["9mm-model-p5-walther", "9mm-model-951r-semi-p-full-auto-beretta", "p210-5-p-9mm-model-49-sig", "p230-sig-sauer"] }' || char(10) || '  - { choose: 1, label: "energy pistol", qty: 1, from: ["tx-20-short-laser-pistol", "tx-22-precision-laser-pistol", "tx-24-ion-pulse-pistol", "tx-26-particle-beam-pistol", "wr-10-wilderness-ion-pistol"] }' || char(10) || '  - { choose: 1, label: "energy rifle", qty: 1, from: ["tx-42-laser-pulse-rifle", "tx-16-pump-rifle", "tx-11-triax-sniper-laser-rifle", "tx-30-triax-ion-pulse-rifle", "tx-43-light-assault-laser-rifle", "tx-45-particle-beam-rifle", "wr-15-wilderness-laser-rifle", "wr-17-wilderness-double-rifle"] }' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '') > 0
    AND instr(markdown, '  - { item_id: "steel-rod-encased-nightstick", qty: 1 }' || char(10) || '  - { item_id: "gun-holster", qty: 1 }' || char(10) || '  - { choose: 1, label: "automatic pistol", qty: 1, from: ["9mm-model-p5-walther", "9mm-model-951r-semi-p-full-auto-beretta", "p210-5-p-9mm-model-49-sig", "p230-sig-sauer"] }' || char(10) || '  - { choose: 1, label: "energy pistol", qty: 1, from: ["tx-20-short-laser-pistol", "tx-22-precision-laser-pistol", "tx-24-ion-pulse-pistol", "tx-26-particle-beam-pistol", "wr-10-wilderness-ion-pistol"] }' || char(10) || '  - { choose: 1, label: "energy rifle", qty: 1, from: ["tx-42-laser-pulse-rifle", "tx-16-pump-rifle", "tx-11-triax-sniper-laser-rifle", "tx-30-triax-ion-pulse-rifle", "tx-43-light-assault-laser-rifle", "tx-45-particle-beam-rifle", "wr-15-wilderness-laser-rifle", "wr-17-wilderness-double-rifle"] }' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown,
  '  - Four issued items are choices the book does not resolve, and none is' || char(10) || '    stubbed: an automatic pistol, an energy pistol, an energy rifle and a gun' || char(10) || '    holster, each of choice. All are in the body.' || char(10) || '',
  '  - THE WEAPONS OF CHOICE AND THE HOLSTER ARE IN equipment_starting since' || char(10) || '    2026-09-27 (~036-ngr-police-weapons.sql). Printed 174 issues an' || char(10) || '    "automatic pistol of choice (typically 9 or 10 mm)", an "energy pistol of' || char(10) || '    choice", an "energy rifle of choice (typically TX-42 or TX-16 pump rifle)"' || char(10) || '    and a "gun holster of choice (shoulder or waist)".' || char(10) || '    - The automatic pistol is a choice of the four 9 mm automatic pistols in' || char(10) || '      Revised Heroes Unlimited printed 201-202 (Walther P5, Beretta 951R, SIG' || char(10) || '      P210-5, SIG Sauer P230). No Rifts row is a conventional automatic' || char(10) || '      pistol and no row anywhere is 10 mm; the WZ-63 machine pistol and the' || char(10) || '      guns under HU''s own Sub-Machineguns heading are left out.' || char(10) || '    - The energy pistol is a choice of Triax''s human-size energy pistols,' || char(10) || '      printed 143-144: TX-20, TX-22, TX-24, TX-26 and WR-10. The TX-5 pump' || char(10) || '      pistol fires explosive cartridges, not energy, and is left out.' || char(10) || '    - The energy rifle is a choice of the two the book names, TX-42 and TX-16,' || char(10) || '      then Triax''s other human-size energy rifles, printed 144-148: TX-11,' || char(10) || '      TX-30, TX-43, TX-45, WR-15 and WR-17. The TX-16 fires projectiles, but' || char(10) || '      the book names it here, so it is offered. Giant-size weapons, rail' || char(10) || '      guns and missile launchers are left out.' || char(10) || '    - The holster is the `gun-holster` row, "a belt or shoulder holster",' || char(10) || '      which is the book''s choice as it stands.' || char(10) || '    Until then this note said all four were in the body.' || char(10) || '')
  WHERE class_id = 'ngr-police' AND instr(markdown, '  - Four issued items are choices the book does not resolve, and none is' || char(10) || '    stubbed: an automatic pistol, an energy pistol, an energy rifle and a gun' || char(10) || '    holster, each of choice. All are in the body.' || char(10) || '') > 0
    AND instr(markdown, '  - THE WEAPONS OF CHOICE AND THE HOLSTER ARE IN equipment_starting since' || char(10) || '    2026-09-27 (~036-ngr-police-weapons.sql). Printed 174 issues an' || char(10) || '    "automatic pistol of choice (typically 9 or 10 mm)", an "energy pistol of' || char(10) || '    choice", an "energy rifle of choice (typically TX-42 or TX-16 pump rifle)"' || char(10) || '    and a "gun holster of choice (shoulder or waist)".' || char(10) || '    - The automatic pistol is a choice of the four 9 mm automatic pistols in' || char(10) || '      Revised Heroes Unlimited printed 201-202 (Walther P5, Beretta 951R, SIG' || char(10) || '      P210-5, SIG Sauer P230). No Rifts row is a conventional automatic' || char(10) || '      pistol and no row anywhere is 10 mm; the WZ-63 machine pistol and the' || char(10) || '      guns under HU''s own Sub-Machineguns heading are left out.' || char(10) || '    - The energy pistol is a choice of Triax''s human-size energy pistols,' || char(10) || '      printed 143-144: TX-20, TX-22, TX-24, TX-26 and WR-10. The TX-5 pump' || char(10) || '      pistol fires explosive cartridges, not energy, and is left out.' || char(10) || '    - The energy rifle is a choice of the two the book names, TX-42 and TX-16,' || char(10) || '      then Triax''s other human-size energy rifles, printed 144-148: TX-11,' || char(10) || '      TX-30, TX-43, TX-45, WR-15 and WR-17. The TX-16 fires projectiles, but' || char(10) || '      the book names it here, so it is offered. Giant-size weapons, rail' || char(10) || '      guns and missile launchers are left out.' || char(10) || '    - The holster is the `gun-holster` row, "a belt or shoulder holster",' || char(10) || '      which is the book''s choice as it stands.' || char(10) || '    Until then this note said all four were in the body.' || char(10) || '') = 0;

UPDATE imported_classes SET markdown = replace(markdown,
  'Issued alongside it, and not given catalog rows: an automatic pistol of choice - typically 9 or 10 mm - an energy pistol of choice, an energy rifle of choice - typically the TX-42 or TX-16 pump rifle - and a gun holster of choice. The billy club',
  'The automatic pistol (typically 9 or 10 mm), energy pistol and energy rifle (typically the TX-42 or TX-16 pump rifle) are each a choice, and the holster may be worn at the shoulder or the waist. The billy club')
  WHERE class_id = 'ngr-police' AND instr(markdown, 'Issued alongside it, and not given catalog rows: an automatic pistol of choice - typically 9 or 10 mm - an energy pistol of choice, an energy rifle of choice - typically the TX-42 or TX-16 pump rifle - and a gun holster of choice. The billy club') > 0
    AND instr(markdown, 'The automatic pistol (typically 9 or 10 mm), energy pistol and energy rifle (typically the TX-42 or TX-16 pump rifle) are each a choice, and the holster may be worn at the shoulder or the waist. The billy club') = 0;

SELECT 'ngr-police offers the three weapons of choice and grants the holster' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
  WHERE class_id = 'ngr-police'
    AND instr(markdown, '{ item_id: "gun-holster", qty: 1 }') > 0
    AND instr(markdown, 'label: "automatic pistol", qty: 1, from: ["9mm-model-p5-walther"') > 0
    AND instr(markdown, 'label: "energy pistol", qty: 1, from: ["tx-20-short-laser-pistol"') > 0
    AND instr(markdown, 'label: "energy rifle", qty: 1, from: ["tx-42-laser-pulse-rifle"') > 0
    AND instr(markdown, 'THE WEAPONS OF CHOICE AND THE HOLSTER ARE IN') > 0
    AND instr(markdown, 'each of choice. All are in the body.') = 0
    AND instr(markdown, 'and not given catalog rows: an automatic pistol') = 0;

SELECT 'every gear row those choices name exists' AS assertion, count(*) AS got, 18 AS want
  FROM gear
  WHERE slug IN ('9mm-model-p5-walther', '9mm-model-951r-semi-p-full-auto-beretta', 'p210-5-p-9mm-model-49-sig', 'p230-sig-sauer', 'tx-20-short-laser-pistol', 'tx-22-precision-laser-pistol', 'tx-24-ion-pulse-pistol', 'tx-26-particle-beam-pistol', 'wr-10-wilderness-ion-pistol', 'tx-42-laser-pulse-rifle', 'tx-16-pump-rifle', 'tx-11-triax-sniper-laser-rifle', 'tx-30-triax-ion-pulse-rifle', 'tx-43-light-assault-laser-rifle', 'tx-45-particle-beam-rifle', 'wr-15-wilderness-laser-rifle', 'wr-17-wilderness-double-rifle', 'gun-holster');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~036-ngr-police-weapons.sql');
