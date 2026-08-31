-- Import the one vessel a class is actually issued.
--
-- BOOK-INGEST-AUDIT.md F3, the cheap half, taken in PR #NNN.
--
-- F3 records that `gear` has no shape for a vessel and proposes nothing yet:
-- the options are a `vehicles` table, a JSON `systems` column, or continuing to
-- drop them and saying so. That question is still open and this script does not
-- answer it. What it answers is the SECOND occurrence F3 added on 2026-08-30,
-- which is a different and sharper cost: the Noro Mystic Warrior's book issues
-- it "a suit of psionic power armor" as standard equipment (printed 65), and
-- the class shipped without it. A GM being unable to look up a starship is a
-- gap; a character sheet that is wrong every time one is rolled is a defect.
--
-- Measured before this ran: 35 rows in `gear` carry `category = 'vehicle'`, and
-- 23 of them already hold a full per-location M.D.C. breakdown in their
-- `description` as prose. The structure is in the database and nothing can read
-- it. THIS ROW MAKES THE SAME COMPROMISE THE OTHER 35 MAKE - `mdc` is the main
-- body only, the locations are prose, and all six weapon systems sit in
-- `damage` - so it is consistent with the catalog rather than a new invention.
-- The field conventions are copied from the existing vehicle rows, where
-- `range` holds the SPEED and `payload` holds the power system.
--
-- EVERY FIGURE WAS READ OFF A 200 DPI RENDER of printed 129 and 130, not from
-- the OCR cache. The folio on the render reads 129, which also re-confirms this
-- book's zero page offset.
--
-- THE MARK V IS STORED, NOT THE MARK X. The book prints both and the Mystic
-- Warrior's equipment line names neither, so the baseline suit is the one a
-- starting character gets - the Mark X adds contragravity flight, weighs twice
-- as much and costs eight million credits rather than four.
--
-- Still NOT imported, and still F3's open question: the 25 vessels this book
-- prints that no class is issued, and the four conditional spaceships the
-- Galactic Tracer, Space Pirate, Runner and Naruni Repo-Bot note as the GM's
-- option. This is the only vessel any class in the catalog is given outright.

INSERT INTO gear (slug, name, system, category, weight_lbs, cost, description,
                  source_book, damage, is_mega_damage, range, payload, mdc)
SELECT 'psionic-power-armor', 'Psionic Power Armor', 'rifts', 'vehicle', 200, 4000000,
       'Model Type: NF Model V or X - identical except for the contragravity flight system. Class: Psionic Assault Exoskeleton. Crew: one. Cargo: none. A crystal-technology exoskeleton the noro psi-technicians built when encounters with warrior races proved they needed to defend themselves. It was the only exoskeleton the noro Federation armed forces used before joining the CCW, it remains in CAF service, and it has been adapted to fit any humanoid psychic wearer. Non-psionics cannot activate its powers, but anyone with even the smallest psionic ability can operate it. M.D.C. BY LOCATION: Shoulder Plates / Mini-missile launchers (2) 100 each; Arms (2) 60 each; Legs (2) 80 each; Head 100; MAIN BODY 210; Psionic Force Field 200. Destroying the head destroys the crystalline network that powers the suit - all special powers and bonuses are lost, and the wearer must carry the armor on muscle alone: below P.S. 24 that is -6 to strike, parry and dodge with Speed cut by two thirds; at P.S. 24 or higher, -2 to parry and dodge with Speed halved; only a supernatural P.S. of 25 or higher moves without penalty. Getting out after the helmet is destroyed takes 2D4 minutes. Depleting the main body shuts the armor down completely. Physical Strength: equal to a P.S. of 40. Height 9 feet (2.7 m), width 5 feet (1.5 m), length 4 feet (1.2 m). THE MARK V IS THE ONE STORED HERE. The book prints two marks and the Mystic Warrior''s equipment line names neither, so the baseline suit is the one a starting character gets: the Mark X adds contragravity flight and a small nuclear system, weighs 400 lbs (181 kg) and costs eight million credits. ONE ROW HOLDS A MULTI-SYSTEM SUIT, which is the compromise every vehicle row in this catalog makes: `mdc` is the MAIN BODY only, the six locations are in this description, and all six weapon systems are in `damage` as prose. See BOOK-INGEST-AUDIT.md F3.',
       'Rifts Dimension Book 2: Phase World p.128-130',
       '1. Mind Bolts: 4D6 M.D. per blast, fired through the hands. Rate of fire equal to the total number of hand to hand attacks per melee, effective range 2,000 feet (610 m), and each bolt costs 2 I.S.P. drawn from the wearer or the suit''s crystal batteries. 2. Mini-Missile Launchers (2): hidden in the shoulder plates, one of the two systems that does NOT use I.S.P. Damage varies with missile type, fired one at a time or in volleys of two, four or eight, effective range about one mile, payload 16 - 8 in each shoulder. 3. GR-Rifle: a gravity-powered rail gun carrying its own power system and ammo, the armor''s main weapon. A burst is 20 rounds for 1D6x10 M.D.; a single round does 2D6 M.D. Rate of fire equal to the number of hand to hand attacks, effective range 4,000 feet (1,220 m), payload a 2,000 round drum magazine - 100 bursts. 4. Fear Beam: the helmet fires a wave of light; the target saves vs psionics or is at -3 to strike, parry and dodge with a 50% chance of turning and running, one target at a time, lasting 1D4 minutes. 5. Special Features: See the Invisible (2 I.S.P.), Telepathic Communication (4 I.S.P. per hour, range 10 miles/16 km, psychics only) and Presence Sense (2 I.S.P.). 6. Hand to Hand Combat: mega-damage hand to hand per Power Armor Combat Training, and conventional energy rifles or rail guns may be carried as additional handheld weapons.',
       1,
       'Running: 100 mph (160 km) maximum, tiring the operator at 10% of the normal rate. Flying: the Mark V only through jet packs; the Mark X''s contragravity system flies at 200 mph (320 km) in atmosphere and up to Mach One (670 mph / 1,080 kmph) in vacuum, with effectively unlimited range.',
       'Psionic crystals holding 2,000 I.S.P., spending 1 I.S.P. per hour of operation, provided by the operator or the crystal power system. Energy life 20 years. The Mark X adds a small nuclear system for the contragravity only.',
       210
 WHERE NOT EXISTS (SELECT 1 FROM gear WHERE slug = 'psionic-power-armor');

UPDATE imported_classes
   SET markdown = replace(markdown, '  - { item_id: "light-combat-armor", qty: 1 }',
       '  - { item_id: "psionic-power-armor", qty: 1 }' || char(10) || '  - { item_id: "light-combat-armor", qty: 1 }'),
       updated_at = datetime('now')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, '  - { item_id: "light-combat-armor", qty: 1 }') > 0
   AND instr(markdown, '  - { item_id: "psionic-power-armor", qty: 1 }' || char(10) || '  - { item_id: "light-combat-armor", qty: 1 }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- THE SUIT OF PSIONIC POWER ARMOR IS NOT IN equipment_starting, and it is this' || char(10) || '    class''s signature kit. The book gives it on printed 128-130 as a power armor' || char(10) || '    stat block - M.D.C. by location, two mini-missile launchers, a two-handed' || char(10) || '    energy blade - and `gear` has no shape that holds one. See' || char(10) || '    BOOK-INGEST-AUDIT.md F3; this is the first class where the exclusion costs a' || char(10) || '    player something they are meant to start with. The light body armour it is' || char(10) || '    issued alongside IS here.',
       '- THE SUIT OF PSIONIC POWER ARMOR IS IN equipment_starting, as the Mark V.' || char(10) || '    The book gives it on printed 128-130 as a power armor stat block, and one' || char(10) || '    `gear` row holds it the way all 35 vehicle rows do: `mdc` is the MAIN BODY' || char(10) || '    (210), the six locations are in the description, and all six weapon systems' || char(10) || '    are in `damage` as prose. That is lossy and deliberate - BOOK-INGEST-AUDIT.md' || char(10) || '    F3 records what a vessel row cannot hold, and this class is why the cheap' || char(10) || '    half of it was taken: a character sheet was wrong every time one was rolled.' || char(10) || '    The book prints a Mark V and a Mark X and names neither here, so the' || char(10) || '    baseline suit is the one a starting character gets.'),
       updated_at = datetime('now')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, '- THE SUIT OF PSIONIC POWER ARMOR IS NOT IN equipment_starting, and it is this' || char(10) || '    class''s signature kit. The book gives it on printed 128-130 as a power armor' || char(10) || '    stat block - M.D.C. by location, two mini-missile launchers, a two-handed' || char(10) || '    energy blade - and `gear` has no shape that holds one. See' || char(10) || '    BOOK-INGEST-AUDIT.md F3; this is the first class where the exclusion costs a' || char(10) || '    player something they are meant to start with. The light body armour it is' || char(10) || '    issued alongside IS here.') > 0
   AND instr(markdown, '- THE SUIT OF PSIONIC POWER ARMOR IS IN equipment_starting, as the Mark V.' || char(10) || '    The book gives it on printed 128-130 as a power armor stat block, and one' || char(10) || '    `gear` row holds it the way all 35 vehicle rows do: `mdc` is the MAIN BODY' || char(10) || '    (210), the six locations are in the description, and all six weapon systems' || char(10) || '    are in `damage` as prose. That is lossy and deliberate - BOOK-INGEST-AUDIT.md' || char(10) || '    F3 records what a vessel row cannot hold, and this class is why the cheap' || char(10) || '    half of it was taken: a character sheet was wrong every time one was rolled.' || char(10) || '    The book prints a Mark V and a Mark X and names neither here, so the' || char(10) || '    baseline suit is the one a starting character gets.') = 0;

-- Readback: the row exists with the main body M.D.C. and all six weapon
-- systems, the class now issues it, and nothing still says it was left out.
SELECT slug, mdc, weight_lbs, cost,
       (instr(damage, 'Mind Bolts') > 0)
         + (instr(damage, 'Mini-Missile Launchers') > 0)
         + (instr(damage, 'GR-Rifle') > 0)
         + (instr(damage, 'Fear Beam') > 0)
         + (instr(damage, 'Special Features') > 0)
         + (instr(damage, 'Hand to Hand Combat') > 0) AS weapon_systems_named,
       instr(description, 'MAIN BODY 210') > 0 AS locations_kept
  FROM gear
 WHERE slug = 'psionic-power-armor';

SELECT class_id,
       instr(markdown, 'item_id: "psionic-power-armor"') > 0 AS issued,
       instr(markdown, 'IS NOT IN equipment_starting') AS stale_claim
  FROM imported_classes
 WHERE class_id = 'noro-mystic-warrior';

INSERT INTO data_script_runs (filename) VALUES ('add-noro-psionic-power-armor.sql');
