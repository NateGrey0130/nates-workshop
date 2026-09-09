-- `vehicles.vehicle_class` normalised to the seven values the column documents,
-- with every book phrase it replaces preserved in `description`.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-vehicle-class-vocabulary.sql
--
-- WHY THIS EXISTS. `db/schema.sql` documents the column as
-- `power-armor | robot | drone | borg | vehicle | ship | other` and then says,
-- correctly, that it is free text on purpose: "books invent categories, and a
-- CHECK would reject a book rather than record it". The vessel imports took
-- that at its word and wrote what the book gave them. On production before this
-- script, 77 of 127 rows carried one of the seven and **50 carried a book
-- phrase** - "Attack Submarine", "Light combat exoskeleton",
-- "Horune magic automaton/combat drone.", "Multi-purpose sea vessel."
--
-- That was the right call during ingestion and it is the wrong shape for a
-- reader. `vehicle_class` is what a Vehicles list shows in its meta column, the
-- way a psionic power shows its category, and a list reading `robot` on one row
-- and `Multi-purpose sea vessel.` on the next reads as a defect.
--
-- SO THE SCHEMA DOES NOT CHANGE AND NO `CHECK` IS ADDED. The column stays free
-- text, for exactly the reason the schema gives: the next book may invent a
-- category too, and recording it beats rejecting it. What changes is a
-- CONVENTION - normalise on the way in, keep the book's phrase - and the
-- convention is now written in the README beside the column.
--
-- NOTHING IN THE APP READS THIS COLUMN YET. Checked 2026-09-08 and again
-- before this script: no file under js/, functions/, app.js or sheet.js
-- references `vehicles`, and neither does the test suite. Only
-- scripts/source-coverage.mjs does, and it does not read `vehicle_class`. This
-- is a data change with no code depending on either side of it.
--
-- THE BOOK'S PHRASE IS NOT DISCARDED. Every one of the 50 was checked against
-- its own description first, with
-- `instr(coalesce(description,''), vehicle_class) > 0`, and **all 50 came back
-- absent** - the phrase existed nowhere else. So each is PREPENDED to its
-- description as a lead label before the column is overwritten. A book that
-- calls a thing a "Sea-Air-Land Strategic Navy Assault Suit" has said something
-- the word `power-armor` does not, and losing it to a tidy-up would be the
-- whole cost of this change with none of the benefit.
--
-- (LIKE cannot do that check here: a pattern built from a description column
-- returns `LIKE or GLOB pattern too complex: SQLITE_ERROR [code: 7500]` on D1.
-- `instr` is the form that works.)
--
-- ONE STATEMENT, AND THAT IS DELIBERATE. SQLite evaluates every `SET`
-- expression against the row's OLD values, so `description` is built from the
-- pre-update `vehicle_class` even though the same statement overwrites it. Two
-- statements would leave a window where a failure between them re-runs the
-- prepend and doubles the label. The `WHERE` is also the idempotency guard:
-- after this runs, no row is outside the vocabulary, so a second application
-- matches nothing.
--
-- `ELSE 'other'` is a catch-all rather than a category. If a row appears that
-- none of the 41 mapped phrases matches, it lands on a documented value instead
-- of NULL - and NULL would put it back outside the vocabulary, where the guard
-- would prepend its label a second time on the next run. Nothing is expected to
-- take that branch; the readback below asserts it took nothing.
--
-- FILENAME. Six z's. The vessel imports are all `zzzzzz-*-vessels-*.sql` and
-- this corrects rows they create, so it has to sort after every one of them -
-- `vehicle-` sorts after `underseas-`, `triax-` and `free-quebec-` inside the
-- same tier. A SEVENTH z would also sort correctly and would invent nothing:
-- `docs/operations.md` already documents that tier. The rule in `class-import`
-- is to use the shortest prefix that sorts right, and `docs/surveys/underseas.md`
-- records the session that reached for a seventh z it did not need. Checked by
-- sorting the real directory, not by reasoning about the prefix.

-- The mapping, one line per phrase the books actually printed.
--
--   exoskeleton / assault suit / power armour worn by a pilot  -> power-armor
--   piloted walking machine, robot vehicle                     -> robot
--   automaton, unmanned combat drone                           -> drone
--   full conversion cyborg                                     -> borg
--   crewed submarine, submersible, carrier, warship            -> ship
--   sled, scooter, tank, jet, helicopter, troop carrier        -> vehicle
--
-- The sled/scooter rows go to `vehicle` rather than `ship` on the grounds that
-- a one-man underwater sled is ridden, not crewed - the same reading that puts
-- a motorcycle and a submarine in different buckets on land.
UPDATE vehicles
SET description = vehicle_class
                  || CASE WHEN substr(vehicle_class, -1) = '.' THEN ' ' ELSE '. ' END
                  || description,
    vehicle_class = CASE vehicle_class
      WHEN 'All-Purpose Underwater Sled'                            THEN 'vehicle'
      WHEN 'Amphibious Armored Exo-Skeleton/Power Armor'            THEN 'power-armor'
      WHEN 'Amphibious Main Battle Tank'                            THEN 'vehicle'
      WHEN 'Assault Robot'                                          THEN 'robot'
      WHEN 'Attack Submarine'                                       THEN 'ship'
      WHEN 'Attack Submarine - full size.'                          THEN 'ship'
      WHEN 'Deep Sea Tactical Assault Exoskeleton'                  THEN 'power-armor'
      WHEN 'Dolphin & Orca Combat Power Armor'                      THEN 'power-armor'
      WHEN 'Dolphin Scout Power Armor'                              THEN 'power-armor'
      WHEN 'Exploration Mini-Submarine.'                            THEN 'ship'
      WHEN 'Fighter Jet'                                            THEN 'vehicle'
      WHEN 'Full Conversion Cyborg - Deep-Sea Heavy Assault.'       THEN 'borg'
      WHEN 'Heavy Infantry Environmental Exo-Skeleton.'             THEN 'power-armor'
      WHEN 'Heavy combat exoskeleton'                               THEN 'power-armor'
      WHEN 'Helicopter Gunship'                                     THEN 'vehicle'
      WHEN 'Horune assault ship.'                                   THEN 'ship'
      WHEN 'Horune magic automaton/combat drone.'                   THEN 'drone'
      WHEN 'Light All-Purpose Submersible'                          THEN 'ship'
      WHEN 'Light Combat Submersible'                               THEN 'ship'
      WHEN 'Light Combat Underwater Sled'                           THEN 'vehicle'
      WHEN 'Light Strategic Environmental Exo-Skeleton.'            THEN 'power-armor'
      WHEN 'Light Strategic Environmental Exoskeleton.'             THEN 'power-armor'
      WHEN 'Light Submersible Carrier'                              THEN 'ship'
      WHEN 'Light combat exoskeleton'                               THEN 'power-armor'
      WHEN 'Magic one-man aqua-sleds or scooters.'                  THEN 'vehicle'
      WHEN 'Marine Infantry Fighting Vehicle (MIFV)/Troop Carrier'  THEN 'vehicle'
      WHEN 'Medium techno-wizard combat exoskeleton'                THEN 'power-armor'
      WHEN 'Military Attack Submersible.'                           THEN 'ship'
      WHEN 'Military Submersible.'                                  THEN 'ship'
      WHEN 'Multi-Environment Attack Ship'                          THEN 'ship'
      WHEN 'Multi-purpose sea vessel.'                              THEN 'ship'
      WHEN 'Navy Battleship & Escort.'                              THEN 'ship'
      WHEN 'Orca Combat Power Armor'                                THEN 'power-armor'
      WHEN 'Orca Scout & Light Combat Power Armor'                  THEN 'power-armor'
      WHEN 'Sea-Air Attack Vehicle'                                 THEN 'vehicle'
      WHEN 'Sea-Air-Land Strategic Navy Assault Suit.'              THEN 'power-armor'
      WHEN 'Sea-Air-Land Tactical Assault Exoskeleton'              THEN 'power-armor'
      WHEN 'Sea-Land Assault Robot.'                                THEN 'robot'
      WHEN 'Strategic Robot Vehicle.'                               THEN 'robot'
      WHEN 'Submersible Air-Sea-Land Carrier'                       THEN 'ship'
      WHEN 'Submersible Air-Sea-Land Carrier.'                      THEN 'ship'
      ELSE 'other'
    END
WHERE vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

-- ---- readback ----
-- Numeric, because a readback that quotes a phrase cannot assert the phrase is
-- absent once the note itself contains it.

SELECT 'every vessel is now one of the seven' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicles
  WHERE vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

-- The catch-all branch is expected to be dead. If this is not 0, a phrase
-- reached the ELSE and its row now says `other` - find it and map it.
SELECT 'nothing fell through to the catch-all' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicles WHERE vehicle_class = 'other';

SELECT 'no vessel lost its description' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicles WHERE description IS NULL OR trim(description) = '';

SELECT 'the row count did not move' AS assertion,
       count(*) AS got, 127 AS want FROM vehicles;

-- `ship` is new: nothing carried it before this script, and 19 rows carry it
-- after. That number is the single best check that the sea books landed where
-- they should, since every one of them came from Underseas or Phase World.
SELECT 'vessels now classed as a ship' AS assertion,
       count(*) AS got, 19 AS want FROM vehicles WHERE vehicle_class = 'ship';

SELECT vehicle_class, count(*) AS n FROM vehicles GROUP BY vehicle_class ORDER BY n DESC;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-vehicle-class-vocabulary.sql');
