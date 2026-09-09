-- Phase World vessel, printed 128-130: the Psionic Power Armor, moved from prose
-- in `gear` into the three tables built for it.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-pw-vessels-p128-130.sql
--
-- BOOK-INGEST-AUDIT.md F41, taken for Phase World - the fourth of the five book
-- sessions that finding proposes. Migration 053 added `gear.vehicle_slug` in its
-- own PR ahead of the first of them, per F41.
--
-- == ONE ROW, AND FOR ONCE F41'S COUNT IS RIGHT ==
--
-- This finding's `LIKE '%Main Body%'` filter has been wrong for all three books
-- before this one - it understated Juicer Uprising, counted 9 Wormwood rows
-- where 2 were vessels, and counted 6 RUE rows where 5 are. Here it returns
-- ONE, `psionic-power-armor`, and one is what the catalog holds and what this
-- file imports. Worth saying plainly, because three consecutive corrections
-- would otherwise make the next reader assume a fourth.
--
-- It is a machine, not a creature - the test the Wormwood session established.
-- The book's own `Class:` line reads `Psionic Assault Exoskeleton`, and the
-- entry carries a crew, a power system, a market cost and six numbered weapon
-- systems. Nothing in it has a Horror Factor or an I.Q.
--
-- == THE GEAR ROW IS CORRECT, WHICH IS ALSO NEW ==
--
-- `psionic-power-armor` stores `mdc = 210` and `cost = 4000000`. The book prints
-- `** Main Body - 210` and `Market Cost: Mark V: Four million credits. Mark X:
-- Eight million credits.` Both were read off the book before the catalog was
-- consulted, and both match - the 4,000,000 being the low end of the two-model
-- range, which is the convention `gear.cost` documents.
--
-- **That is one confirmation, and it is not the same evidence F42 discredited.**
-- The RUE session found six rows whose prices matched RUE exactly while every
-- M.D.C. came from an earlier edition, because the errata moved combat numbers
-- and left prices alone. Here the M.D.C. matches too, which is the check that
-- actually bears weight. Phase World has had no second edition.
--
-- == THE ENTRY DESCRIBES TWO MODELS AND THIS IS ONE ROW ==
--
-- `Model Type: NF Model V or X (identical except for the contragravity flight
-- system)`. The M.D.C. table is shared - the book prints ONE set of locations
-- for both - and the models differ only in flight, weight, power system and
-- price. So one vessel row, with the X's figures in `speed_air`, `weight_tons`
-- and `cost_note`.
--
-- That is the shape Nate settled for the NG-JK1 in the Juicer Uprising session,
-- and it applies more cleanly here: the JK1B changed nine location values and
-- still got one row, where the Model X changes none.
--
-- THE BOOK SPELLS THE MODELS TWO WAYS IN ONE ENTRY - `Model V or X` in
-- `Model Type:` and `Mark V` / `Mark X` in `Weight:`, `Power System:`,
-- `Range:` and `Market Cost:`. Both spellings are the book's. `Model` is used
-- below because that is what the naming line uses, and the variance is recorded
-- here rather than silently normalised.
--
-- == THE ORDINALS ARE THE BOOK'S, FOR THE FIRST TIME IN THIS SEQUENCE ==
--
-- Phase World prints `Weapon Systems` as a numbered list, 1 through 6, so the
-- ordinals below are transcribed rather than invented - unlike the Wormwood and
-- RUE scripts, which had to number their own because those books print prose.
-- Entries 5 and 6 are not guns and say so in their `note`, which is the
-- convention the Free Quebec import set for `Special Features` and
-- `Hand to Hand Combat`.
--
-- == A WEAPON THE PROSE NAMES AND THE STAT BLOCK OMITS ==
--
-- Printed 129 says *the most fearsome weapon of the armor is a two-handed energy
-- blade, an artificial version of a psi-sword* - and the numbered `Weapon
-- Systems` list on 130 does not include it, gives it no damage, and never
-- mentions it again. It is recorded in the vessel's description as prose,
-- NOT as a `vehicle_weapons` row with a NULL damage, because inventing a
-- seventh numbered system the book does not number would put a weapon in the
-- list that no reader can find in the book.
--
-- == READ TWICE, AND THE CACHE WELDED ==
--
-- Every figure was read from the cached OCR of printed 128-130 and then
-- confirmed against a 200 dpi RENDER of all three pages. **The render was not a
-- formality here**: cache `p129` interleaves the two columns line by line, so
-- `Speed:` / `Running: 100 mph` from the left column and `Flying:` / `Range:` /
-- `Statistical Data:` from the right arrive alternating -
--
--     Speed: Statistical Data:
--     Running: 100 mph (160 km) maximum; the act of running Height: 9 feet (2.7 m)
--
-- - which is exactly the welded read `book-survey` section 0b warns about. The
-- numbers were separable by eye in this instance and would not be in general.
-- The M.D.C. block on the same page came through clean and the render confirms
-- every value in it.
--
-- The offset was confirmed the free way section 0d prescribes: the renders of
-- printed 128, 129 and 130 carry folios 128, 129 and 130, so `page_offset: 0` as
-- `scripts/books.json` records - and zero is the awkward case section 0d names,
-- because there is no offset left to explain a wrong page with.
--
-- THE CITATION IS RIGHT AND WAS CHECKED. The gear row cites `p.128-130`; the
-- entry's heading `Psionic Power Armor` sits at the foot of printed 128 and the
-- stat block ends on 130. Both earlier sessions found a page citation off by
-- one or wider than the entry, so this was verified rather than copied.
--
-- EIGHT Z'S, sorting after the Juicer Uprising and Wormwood files and BEFORE the
-- RUE one. The `ju` script asserts a **global** `gear.vehicle_slug` count of 7,
-- so every later book must sort after it; the `rue` script's readbacks are all
-- book-scoped, so `pw` sorting ahead of it alphabetically breaks nothing. A
-- ninth `z` would have needed a new tier row in `docs/operations.md` to buy
-- nothing.
--
-- Pure ASCII with LF endings. The book sets curly quotes and em-dashes; they are
-- stripped here.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('psionic-power-armor', 'Psionic Power Armor', 'rifts', 'power-armor',
   'One. Non-psionics cannot activate the armour''s powers, but anybody with even the smallest amount of psionic ability can operate it as if it were an extension of his own body. The suit has been adapted to fit any humanoid psychic wearer.',
   NULL,
   'Running: 100 mph (160 km) maximum. Running tires the operator, but at only 10% the normal fatigue rate.',
   'Model V: only through the use of jet packs. Model X: a contragravity system flies the wearer at 200 mph (320 km) in an atmosphere and up to Mach One (670 mph/1080 km) in a vacuum, at effectively unlimited range.',
   NULL,
   'Height: 9 feet (2.7 m); Width: 5 feet (1.5 m); Length: 4 feet (1.2 m)',
   'Model V: 200 lbs (91 kg). Model X: 400 lbs (181 kg), including the contragravity and nuclear power system.',
   210,
   4000000,
   'Market cost four million credits for the Model V and EIGHT million for the Model X. The low end is stored, per the convention gear.cost documents. It matches the figure an earlier session had already stored on the gear row, read from the book before the catalog was consulted.',
   'A crystal-technology power armour developed by the noro, who did not enjoy building weapons and built this after encounters with warrior races proved they had to. It was the only exoskeleton the noro Federation armed forces used before they joined the CCW, it held its own against all comers, and it is still in CAF service. Physical Strength is equal to a P.S. of 40 and it carries no cargo. The power system is psionic crystals holding 2,000 I.S.P. and drawing 1 I.S.P. per hour of operation, supplied by either the operator or the crystals; the Model X adds a small nuclear system for the contragravity alone. Energy life is 20 years. The profile is slender, like the noro themselves, except at the upper torso and head: two thick plates hide the missile launchers, and the head carries cheek guards and extra ornamental armour because losing the helmet cuts the armour''s power and leaves the wearer trapped in almost two hundred pounds (91 kg) of unyielding metal. The book adds that the most fearsome weapon of the armour is a two-handed energy blade, an artificial version of a psi-sword - and then gives it no entry in the numbered weapon systems, no damage and no further mention. The original Model V was not built for space and was used inside ships as an interior defence against boarders, which caused military disasters; the Model X answered that with a contragrav pack, was still inferior to other CAF battlesuits, and is no longer in military service, though it turns up among planetary forces, pirates and mercenaries.',
   'Rifts Dimension Book 2: Phase World p.128-130');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('psionic-power-armor', 'Shoulder Plates/Mini-Missile Launchers (2)', 100, 'Each.', 1),
  ('psionic-power-armor', 'Arms (2)',  60, 'Each.', 2),
  ('psionic-power-armor', 'Legs (2)',  80, 'Each.', 3),
  ('psionic-power-armor', 'Head',     100, 'Destroying the head destroys the crystalline network that powers the armour: all special powers and bonuses are lost, and the wearer falls back on his own muscle power. Below a P.S. of 24 that is -6 to strike, parry and dodge with Speed cut by two-thirds; at P.S. 24 or higher it is -2 to parry and dodge with Speed halved. Only a supernatural P.S. of 25 or higher carries the armour without penalty. Getting out afterwards takes 2D4 minutes.', 4),
  ('psionic-power-armor', 'Main Body', 210, 'Depleting the main body shuts the armour down completely, making it useless.', 5),
  ('psionic-power-armor', 'Psionic Force Field', 200, 'Printed in the M.D.C. by Location list as its own entry rather than as a separate system.', 6);

-- ORDINALS ARE THE BOOK'S. Phase World prints `Weapon Systems` numbered 1 to 6.
INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('psionic-power-armor', 1, 'Mind Bolts',
   '4D6 M.D. per blast', 1, '2000 feet (610 m)',
   'Equal to the total number of hand to hand attacks per melee.',
   'Each bolt costs 2 I.S.P.', NULL,
   'Primary purpose assault, secondary defense. Shot through the armour''s hands. These do more damage, reach further and cost less I.S.P. than a normal mind bolt, and the I.S.P. may come from the wearer or from the suit''s crystal batteries.'),

  ('psionic-power-armor', 2, 'Mini-Missile Launchers (2)',
   'Varies with missile type.', 1, 'About one mile.',
   'One at a time, or volleys of two, four or eight.',
   '16, eight in each shoulder.', NULL,
   'Primary purpose anti-armor, secondary defense. Hidden inside the shoulder plates, and one of the two weapon systems that do not run on I.S.P.'),

  ('psionic-power-armor', 3, 'GR-Rifle',
   'A burst of 20 rounds does 1D6x10 M.D.; a single round does 2D6 M.D.', 1, '4000 feet (1200 m)',
   'Equal to the number of hand to hand attacks.',
   '2,000 round drum magazine, which is 100 bursts.', NULL,
   'Primary purpose anti-armor and anti-infantry, secondary defense. A gravity-powered rail gun used as the armour''s main weapon; it carries its own power system and ammunition, and is the other system that does not run on I.S.P.'),

  ('psionic-power-armor', 4, 'Fear Beam',
   NULL, 0, NULL, NULL, NULL,
   'Target is -3 to strike, parry and dodge.',
   'Not a damaging weapon. The helmet projects a special form of the empathic transmission super-psionic power, seen as a wave of light. The target saves vs psionics or is struck by unreasoning terror, with a 50% chance of turning and running. One target at a time, lasting 1D4 minutes.'),

  ('psionic-power-armor', 5, 'Special Features',
   NULL, 0, NULL, NULL, NULL, NULL,
   'Not a weapon. The standard sensors found in most powered armour, plus three psionic powers whose I.S.P. may come from the wearer or the suit: See the Invisible (2 I.S.P.), Presence Sense (2 I.S.P.), and Telepathic Communication (4 I.S.P. per hour, range 10 miles/16 km, allowing radio-like conversation between two psionic characters and useless to non-psionics).'),

  ('psionic-power-armor', 6, 'Hand to Hand Combat',
   NULL, 0, NULL, NULL, NULL, NULL,
   'Not a weapon system. The pilot may fight in mega-damage hand to hand under Power Armor Combat Training instead of using a weapon, and may carry conventional energy rifles or rail guns as additional handheld weapons.');

-- The pointer. One gear row, one vessel.
UPDATE gear SET vehicle_slug = 'psionic-power-armor'
 WHERE slug = 'psionic-power-armor';

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is how a row goes missing
-- without an error, so these COUNT. Every want is counted off the VALUES lists
-- in THIS FILE, not read back out of a database that has just loaded it.

SELECT 'the one vessel' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE source_book LIKE '%Phase World%';

SELECT 'its M.D.C. locations' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Phase World%';

SELECT 'its weapon systems' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.source_book LIKE '%Phase World%';

-- Every location carries a printed figure - this book prints no formulas and
-- hides nothing under an illustration, unlike the two books before it.
SELECT 'every location has a printed figure' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Phase World%' AND l.mdc IS NULL;

-- The ordinals are the book's own 1-6, contiguous.
SELECT 'the weapon ordinals run 1 to 6 with no gap' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'psionic-power-armor' AND ordinal BETWEEN 1 AND 6;

SELECT 'the gear row now points at the vessel' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'psionic-power-armor' AND vehicle_slug = 'psionic-power-armor';

-- The gear row is unchanged apart from the pointer, and its two figures are the
-- ones the book prints. Asserted by value because this is the first book in the
-- sequence where the stored figures agreed with the book on the FIRST reading.
SELECT 'and still carries the figures the book prints' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'psionic-power-armor' AND category = 'vehicle'
    AND mdc = 210 AND cost = 4000000;

SELECT 'every pointer in the catalog resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Scoped to THIS book, for the reason the Juicer Uprising script gives: the
-- global version belongs to zzzzzz-vehicle-class-vocabulary.sql.
SELECT 'it carries a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Phase World%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;
SELECT count(*) AS total_gear_pointers FROM gear WHERE vehicle_slug IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-pw-vessels-p128-130.sql');
