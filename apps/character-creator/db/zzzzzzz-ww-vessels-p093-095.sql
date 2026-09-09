-- Wormwood vessels, printed 93-95: the TWO machines this book stats, moved from
-- prose in `gear` into the three tables built for them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-ww-vessels-p093-095.sql
--
-- BOOK-INGEST-AUDIT.md F41, taken for Wormwood - the second of the five book
-- sessions that finding proposes. Migration 053 added `gear.vehicle_slug` in its
-- own PR ahead of the first of them, per F41.
--
-- == TWO, NOT NINE, AND THE BOOK SAYS SO IN ITS OWN Class: FIELD ==
--
-- F41 counts NINE Wormwood rows, from `category = 'vehicle' AND description LIKE
-- '%Main Body%'`. That filter is wrong in BOTH directions here, and reading the
-- book rather than the gear descriptions is what shows it:
--
--   * It INCLUDES the eight shock parasites, which are living monsters. Every
--     one of them prints its own `Class:` line, and all eight read
--     `Class: Wormwood organism: <name> Parasite.` The battle saint and its orb
--     read `Class: Magic symbiotic war machine.` That is the same field
--     `vehicles.vehicle_class` exists to hold, and the book fills it in
--     differently for the two groups. Checked by grepping `^Class:` across the
--     cached parasite pages 101-108: eight hits, eight organisms, no exception.
--
--   * It EXCLUDES `battle-saint-orb`, which IS one of these machines. Its gear
--     description happens to say "M.D.C. is the pilot's own hit points or M.D.C.
--     times 10" where the battle saint's says "main body", so the LIKE missed
--     it. The book prints `M.D.C. by Location: Main Body` for the orb on printed
--     94, in the same words as the saint, under the same `Class:` line.
--
-- So this file imports 2 vessels, one of which F41 does not list, and leaves 8
-- of the 9 it does list where they are.
--
-- `add-wormwood-gear.sql` gave all ten the 'vehicle' category on the reasonable
-- ground that the krikton battle wagon carries a rider and three passengers and
-- the catalog already files a Riding Horse there. That was a PICKER-CATEGORY
-- decision and it stands; it was never a claim that a parasite is a vessel.
--
-- THE EIGHT PARASITES STAY IN `gear`, AND NATE ALREADY DECIDED THAT. The `ww`
-- survey's ledger records it under 2026-08-27: "The 8 parasites ARE gear -
-- overriding this survey's first recommendation ... on the grounds that Ride
-- Giant Parasites and Summon and Command Parasites make them player-reachable."
-- Moving them now would reverse a settled decision, which `audit-menu` names as
-- the failure a subject grep is meant to catch.
--
-- There is a second, mechanical reason and it is the stronger one: `vehicles`
-- has nowhere to put a Horror Factor, an I.Q., attacks per melee, save-vs-magic
-- bonuses, prowl and climb percentages, or bio-regeneration. Every parasite
-- entry carries most of those. Importing one into `vehicles` would DROP them,
-- which is worse than the cosmetic split F41 set out to fix.
--
-- THE GEAR ROWS STAY. Both keep their slug, their prose and their NULL price,
-- and each gains a pointer at its new vessel. That is F41's settled posture. It
-- happens to cost nothing here: NO Wormwood gear slug is cited by any class
-- markdown at any status, so unlike `road-boss-motorcycle` in the Juicer
-- Uprising import, nothing would have broken either way.
--
-- THE VESSEL SLUG IS THE GEAR SLUG, as in the Juicer Uprising import: the two
-- rows are the same machine, and a second name would put a mapping between them
-- that only this file knows.
--
-- READ FROM THE BOOK, NOT FROM THE GEAR ROWS. Every figure below was read off
-- the cached OCR of printed 93-95 and then confirmed against a 200 dpi RENDER of
-- all three pages, because `ww`'s cache manifest carries no `welded_pages` or
-- `corrupt_pages` key - the tell `book-survey` section 0b names for a cache built
-- before that detector existed. The render and the OCR agree character for
-- character on every number in these two entries. `scripts/read-columns.py` was
-- NOT used and cannot be: it needs a text layer, and `ww` is a scan.
--
-- The offset was confirmed the free way section 0d prescribes, three times over:
-- the renders of 93, 94 and 95 each carry that folio at the foot of the page, so
-- `page_offset: 0` as `scripts/books.json` records. The cache manifest agrees
-- with the registry on both `page_offset` and `printed_pages` - the `ju`-style
-- disagreement does not recur here.
--
-- == NO M.D.C. NUMBERS EXIST FOR EITHER VESSEL, AND THAT IS THE BOOK'S ANSWER ==
--
-- A battle saint's main body is "equal to the pilot's hit points/M.D.C. x 20",
-- and every other location is a percentage of that. The orb is x 10. There is no
-- printed figure anywhere, for any location, on either machine.
--
-- So `mdc_main_body` is NULL on both rows and every `vehicle_locations.mdc` is
-- NULL with the formula in `mdc_note`. The schema anticipated exactly this - the
-- column comments itself "NULL where a book prints a formula" - so nothing had
-- to be widened and this file makes no schema change, which is F41's stated
-- posture for a book session.
--
-- A reader who wants a number can have one from the book's own worked examples,
-- and they are in the notes below: a pilot with 32 hit points instills 640 in a
-- battle saint and 320 in an orb; a pilot with 60 instills 1200 and 600.
--
-- == WHAT WENT INTO `vehicle_weapons`, AND WHY A SPELL LIST DID ==
--
-- Neither machine has a weapon system. What each has is a `Mega-Damage:` list of
-- melee attacks and a `Magic Powers of Note:` list of spells it casts a fixed
-- number of times a day. Both are entered as `vehicle_weapons` rows carrying a
-- `note` that says what they are, which is the convention the Free Quebec import
-- already set for non-gun entries - see `Hand to Hand Combat` and
-- `Combat Bonuses` in `zzzzzz-free-quebec-vessels-p052-069.sql`.
--
-- The spell list is the one worth defending. It is the only ranged offense
-- either vessel has, a player at a table reads the weapon list to find it, and
-- the alternative is leaving it in description prose - the shape F41 exists to
-- get structured combat numbers OUT of. The book prints no numbering for either
-- list, so the ordinals here are this file's, NOT the book's - unlike the Free
-- Quebec and Triax vessels, whose ordinals are printed.
--
-- `vehicle_class` is `robot` for both, on the book's own words rather than on
-- its `Class:` line: printed 93 opens "One might consider the Battle Saint to be
-- a giant, organic, combat robot" and printed 94 calls the orb "The giant,
-- organic robot". "Magic symbiotic war machine" is not in the seven-value
-- vocabulary `zzzzzz-vehicle-class-vocabulary.sql` establishes, and that script
-- asserts ZERO rows land on `other`, so `other` is not available either.
--
-- Pure ASCII with LF endings. The book sets curly quotes and em-dashes
-- throughout; they are stripped here, as `add-wormwood-gear.sql` records.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('battle-saint', 'Battle Saint', 'rifts', 'robot',
   'One pilot, in a compartment inside the hollow octagonal head. Only the apok, knights of the Temple or Hospital, or monks can pilot one - not freelancers or other O.C.C.s. A Priest of Light can summon a battle saint but cannot pilot one. Only HUMANS can pilot: human-like beings, including elves, dwarves, simvans and humans turned into vampires, cannot, though they may ride as passengers. Off-worlders must be a human with major or master psionics, a cyber-knight or a True Atlantean.',
   '24, inside the head with the pilot. Two to four of them should be defenders: the head has two large window-like openings, an enemy can send flying attackers through them to reach the pilot, and the pilot cannot defend himself without immobilizing the machine.',
   '3D6x10, printed with no mph conversion. Leap: 100 feet (30.5 m) high or lengthwise.',
   NULL,
   NULL,
   'Height: 100 to 200 feet (30.5 to 61 m); Width: 25 feet (7.6 m)',
   '2D4x10,000',
   NULL,
   NULL,
   'No published price, and no market. Battle saints are grown by the living planet and awakened by a priest''s prayers rather than sold; only twelve are known to exist, and an evil character cannot summon, use or corrupt one at all. Wormwood runs on barter - the Priest of Light O.C.C. prints "Money: Not applicable" on printed 54.',
   'A skyscraper-size organic war machine the book introduces as a giant, organic, combat robot. The pilot physically joins to it and directs its every movement; everything it sees and feels reaches the pilot, and its attacks per melee round are the pilot''s plus three. Its M.D.C. is the pilot''s own hit points or M.D.C. times 20 - a pilot with 32 instills 640, a pilot with 60 instills 1200 - and a non-mega-damage human contributes his hit points, not his S.D.C. Supernatural P.S. 60, P.P. 2D6+10, P.B. 3D6+12; I.Q., M.A. and M.E. are not applicable. It is a LAND vehicle and cannot fly. When its main body is depleted it drops to its knees, falls gently to protect those inside, and fades into the ground as a hill or part of a mountain within 1D4 minutes; it cannot be raised again for one week, and returns at full power. It runs 24 hours before needing a full 24 hours of rest, and must complete that rest to the minute to regain even one M.D.C. point or one hour of fuel - a priest may send it back early and raise it again as needed until the 24 hours of use are spent. It does not fatigue and is impervious to poisons, drugs, gases, normal fire, cold, S.D.C. weapons, possession, mind control and illusions; mega-damage weapons, energy attacks and magic do full damage, and the pilot may still be open to psionics. Twelve are known to exist, mostly lying inside a mountain or under a hill until a priest''s prayers wake them; the Forces of Darkness keep armed camps around several of the resting places they have found.',
   'Rifts Dimension Book 1: Wormwood p.93'),

  ('battle-saint-orb', 'Battle Saint Orb', 'rifts', 'robot',
   'One pilot, in a compartment inside the hollow orb. The same restriction as the battle saint: apok, knights of the Temple or Hospital, or monks only, and a Priest of Light can summon one but cannot pilot it.',
   '12, inside the orb with the pilot. As with the battle saint, two to four should be defenders - the orb has the same two window-like openings and the pilot cannot defend himself without immobilizing it.',
   NULL,
   '4D4x10 flying, printed with no mph conversion; maximum altitude 5000 feet (1534 m). Leap: not applicable.',
   NULL,
   'Height: 12 to 20 feet (3.6 to 6 m); Width: 12 to 20 feet (3.6 to 6 m)',
   '1D4x10',
   NULL,
   NULL,
   'No published price, and no market - the same as the battle saint. Grown by the living planet and summoned by prayer; legend puts the number at 32, of which only 20 are located. An evil character cannot summon, use or corrupt one.',
   'The flying counterpart of the battle saint, which the book also calls a giant, organic robot. Orbs look like the dismembered heads of battle saints, and despite the name the shape is OCTAGONAL rather than spherical - the book says so outright. Attacks per melee round are the pilot''s plus one. Its M.D.C. is the pilot''s own hit points or M.D.C. times 10 - a pilot with 32 instills 320, a pilot with 60 instills 600. P.B. 2D6+10; I.Q., P.P., M.A. and M.E. are not applicable, and so is supernatural P.S. When depleted it drops to the ground, fades into it as a small hill or part of a mountain within 1D4 minutes, and cannot be awakened for one week; it then returns at full power. It runs 48 hours - twice the battle saint''s - and then needs a full 24 hours of rest, to the minute, before it regains even one M.D.C. point or one hour of fuel. It does not fatigue and is impervious to poisons, drugs, gases, normal fire, cold, S.D.C. weapons, possession, mind control and illusions; mega-damage weapons, energy attacks and magic do full damage, and the pilot may still be open to psionics.',
   'Rifts Dimension Book 1: Wormwood p.94-95');

-- Every `mdc` is NULL because every value the book prints is a formula. The
-- percentages are of the MAIN BODY, which is itself derived from the pilot, so
-- nothing here resolves to a number without a specific character.
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('battle-saint', 'Head (1)',  NULL, 'Equal to half the main body.',   1),
  ('battle-saint', 'Hands (2)', NULL, 'Equal to 10% of the main body.', 2),
  ('battle-saint', 'Arms (2)',  NULL, 'Equal to 25% of the main body.', 3),
  ('battle-saint', 'Legs (2)',  NULL, 'Equal to 25% of the main body.', 4),
  ('battle-saint', 'Main Body', NULL, 'Equal to the pilot''s hit points/M.D.C. x 20. Depleting it shuts the symbiote down and causes it to slip back into the ground. A pilot with 32 hit points/M.D.C. instills 640; a pilot with 60 instills 1200.', 5),

  ('battle-saint-orb', 'Main Body', NULL, 'Equal to the pilot''s hit points/M.D.C. x 10. Depleting it shuts the symbiote down and causes it to slip back into the ground. A pilot with 32 hit points/M.D.C. instills 320; a pilot with 60 instills 600. The book prints no other location for the orb.', 1);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('battle-saint', 1, 'Hand to Hand Combat',
   'Restrained punch 1D6 M.D.; full strength punch or kick 1D6x10 M.D.; power punch 2D6x10 M.D.; judo style body throw 5D6x10 M.D.',
   1, 'Reach', 'The pilot''s own attacks per melee round plus three additional.', NULL, NULL,
   'Not a weapon system - this machine has none. The book prints these under Mega-Damage:. Supernatural P.S. 60. All of it inflicts DOUBLE damage to supernatural monsters and creatures of magic such as dragons.'),

  ('battle-saint', 2, 'Magic Powers of Note',
   NULL, 0, NULL,
   'Each may be performed four times per 24 hours of activity.', NULL, NULL,
   'Not a weapon system, but the only ranged offense a battle saint has, so it is recorded here rather than left in prose. Each is equal to a 12th level spell of the same name: Call Lightning, Heat Point, Hell Fire, Invisibility (self and occupants), Levitate, Breathe Without Air (all occupants), Close Rift.'),

  ('battle-saint-orb', 1, 'Ram Attacks',
   'Restrained ram 2D6 M.D.; full strength ram 1D6x10 M.D.',
   1, 'Contact', 'The pilot''s own attacks per melee round plus one additional.', NULL, NULL,
   'Not a weapon system - the orb has none, and no limbs either. The book prints these under Mega-Damage:. Supernatural P.S. is not applicable. Both inflict DOUBLE damage to supernatural monsters and creatures of magic such as dragons.'),

  ('battle-saint-orb', 2, 'Magic Powers of Note',
   NULL, 0, NULL,
   'Each may be performed five times per 24 hours of activity.', NULL, NULL,
   'Not a weapon system, but the orb''s only ranged offense. Each is equal to a 7th level spell of the same name - a lower level than the battle saint''s 12th, on a longer list of twelve: Breathe Without Air (all occupants), Create Opening (in Wormwood buildings), Call Lightning, Dispel Magic Barriers, Energy Disruption, Fire Ball, Heat Point, Hell Fire, Invisibility (self and occupants), Negate Magic, Protection Circle: Simple (all occupants inside), Tongues (all occupants).');

-- The pointer. The two slugs are NAMED rather than derived from the category,
-- because eight other Wormwood rows share that category and are NOT vessels.
UPDATE gear SET vehicle_slug = slug
 WHERE category = 'vehicle'
   AND source_book LIKE '%Wormwood%'
   AND slug IN ('battle-saint', 'battle-saint-orb');

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is exactly how a row goes
-- missing without an error, so these COUNT. Every want below is counted off the
-- VALUES lists in THIS FILE, not read back out of a database that has just
-- loaded it - three of the Juicer Uprising script's assertions were wrong on
-- first apply for want of that distinction.

SELECT 'the two vessels' AS assertion, count(*) AS got, 2 AS want
  FROM vehicles WHERE source_book LIKE '%Wormwood%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Wormwood%';

SELECT 'their weapon entries' AS assertion, count(*) AS got, 4 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.source_book LIKE '%Wormwood%';

-- The point of the whole entry: not one of these six is a number.
SELECT 'every location is a formula, not a figure' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Wormwood%' AND l.mdc IS NOT NULL;

SELECT 'and both main bodies are NULL too' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE source_book LIKE '%Wormwood%' AND mdc_main_body IS NOT NULL;

SELECT 'the two gear rows now point at a vessel' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE vehicle_slug IS NOT NULL AND source_book LIKE '%Wormwood%';

-- The eight parasites keep the 'vehicle' category and gain NO pointer. If a
-- later session decides otherwise it will have to change this line, which is
-- exactly why it is asserted rather than left implicit.
SELECT 'the eight parasites are untouched' AS assertion, count(*) AS got, 8 AS want
  FROM gear
  WHERE category = 'vehicle' AND source_book LIKE '%Wormwood%' AND vehicle_slug IS NULL;

-- Every pointer resolves. A dangling one is allowed by the schema on purpose -
-- three books are still not imported - but none of THESE may dangle.
SELECT 'and every pointer in the catalog resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Scoped to THIS book's two, for the reason the Juicer Uprising script gives:
-- the global version belongs to zzzzzz-vehicle-class-vocabulary.sql, and
-- asserting it here fails on any environment that has not had that script.
SELECT 'these two carry a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Wormwood%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;
SELECT count(*) AS total_gear_pointers FROM gear WHERE vehicle_slug IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-ww-vessels-p093-095.sql');
