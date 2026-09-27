-- Rifts World Book 12: Psyscape - the rows its import left as class prose.
-- Five psionic powers: the Psi-Slayer's four exclusive powers (Sleepwalk,
-- Locate & Track Mark, Telekinetic Air Walk, Psi-Dagger; printed 71-73) and
-- the Psi-Tech's Machine & Electrical Diagnosis (printed 75). Three gear rows
-- its class drafts named and found missing: the Electro-Stunner, a set of
-- fake identification, and an eraser.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~019-psyscape-exclusive-powers-and-gear.sql
--
-- The classes are wired to these rows by the NEXT file,
-- ~020-psyscape-classes-take-the-new-rows.sql, which must sort after this one.
--
-- NONE IS A DUPLICATE. Checked --remote on 2026-09-26: no psionic_powers name
-- contains sleep-, track, air walk, dagger or diagnos- except Induce Sleep and
-- Psychic Diagnosis (both Healing, both different powers); no gear name
-- contains stun-, eraser, fake or ident- except unrelated stun guns and a
-- field identifier computer.
--
-- CATEGORY 'Special' for all five. The book puts the four under "Special
-- Psionic Powers, Exclusive to the Psi-Slayer" and the Diagnosis among the
-- Psi-Tech's R.C.C. abilities; filed under Sensitive or Physical they would be
-- offered to every psychic whose gate names that category. 'Special' is the
-- category Africa's two racial powers took for the same reason
-- (add-africa-psionic-powers.sql), and a class reaches these only by name.
--
-- `system` is NULL, not 'rifts': a psionic power carries a game tag only when
-- its book belongs to one game alone (Heroes Unlimited, Nightbane, Phase
-- World), and regression holds every other row to none - the untag decision
-- Psyscape's own Mind Bleeder rows ended up under.
--
-- `isp` is the printed cost; each block prints one number. Descriptions are
-- paraphrased from the book with every mechanic kept, the convention of
-- add-psyscape-psionic-powers.sql. Psi-Dagger's damage has no column on
-- psionic_powers and is in its description.
--
-- THE GEAR PRINTS NO STATISTICS, and the rows say so rather than guessing.
-- Psyscape names the Electro-Stunner twice (printed 69, 83) as the
-- alternative to a Neuro-Mace and sends the reader to Rifts Lone Star, a book
-- this catalog does not hold, so damage, range and cost are NULL. It is not
-- the CS robot's H-02 Electro-Stunner (Coalition War Campaign printed 142),
-- which is a mounted weapon. Fake identification (printed 74 and 140) and the
-- eraser (printed 135) are priced nowhere in the cached books.

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Sleepwalk', 'Special', 6, NULL, NULL, '20 feet (6 m); line of sight.', 'Five minutes per level of experience, or until the subject has walked up to 1000 feet (305 m). A comfortable sleeper sleeps on normally.', 'Standard, at -3; the subject must already be asleep or very tired.', 'Exclusive to the Psi-Slayer, who picks two of his four exclusive powers. Entrances one subject per level of experience within 20 feet (6 m), who must be asleep or tired and ready for sleep and fail a save vs psionic attack at -3. Two uses, chosen per subject: (1) deep slumber - the subject can be led to lie or sit down and sleeps so soundly that only a very loud noise or rough jostling wakes him; normal conversation, footsteps, a bump or a light touch (such as having his pockets searched) do not, and he remembers nothing said and no one seen, even a glimpse just before the trance; (2) sleepwalk - the subject is coaxed up and led somewhere else, can be handed something to hold (a bloody knife, a smoking gun) and left standing or lying there, and remembers nothing of it. Left standing or somewhere uncomfortable (cold, wet) he wakes in 2D6 minutes; somewhere warm and comfortable, at his normal rising time or when woken by sound or shaking. The power soothes, so it fails if the Psi-Slayer intends the subject bodily harm; the subject then wakes from a nightmare of being attacked from the shadows. A favourite for mischief, confusion and framing an innocent for the Psi-Slayer''s crime.', 'import', 'Rifts World Book 12: Psyscape p.71'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Sleepwalk');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Locate & Track Mark', 'Special', 6, NULL, NULL, '3 miles (4.8 km) plus one mile (1.6 km) per level of experience.', 'Special: lasts as long as the mark is within tracking range; the link breaks if the mark gets out and stays out of range for more than 30 minutes.', 'Standard, at -2.', 'Exclusive to the Psi-Slayer, who picks two of his four exclusive powers. One target (the "mark") at a time. By handling a piece of the mark''s hair, a nail clipping, a smudge of blood, a piece of skin, or clothing worn in the last four hours, the psychic forges a telepathic link: while the mark is in range he senses its direction and distance to within 20 feet (6 m), and whether it is travelling quickly (in a vehicle, making a run for it). No counter-tracking and no Mind Block prevents it; the only escapes are getting out of range or killing or subduing the Psi-Slayer.', 'import', 'Rifts World Book 12: Psyscape p.72'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Locate & Track Mark');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Telekinetic Air Walk', 'Special', 4, NULL, NULL, 'Self.', '10 minutes per level of experience.', NULL, 'Exclusive to the Psi-Slayer, who picks two of his four exclusive powers. A form of telekinesis: the psychic levitates up to 10 feet (3 m) per level of experience and walks on air, moving at one third of his Spd, supporting his own weight plus 15 lbs (6.8 kg) per level. Used to cross between rooftops or over a ravine, reach windows and balconies, move silently over noisy ground (dry leaves, crisp snow, creaky floorboards) and avoid land mines, trip wires and pressure sensors. While air walking: +10% to Prowl, Camouflage, Climbing, Acrobatics and Escape Artist.', 'import', 'Rifts World Book 12: Psyscape p.72'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telekinetic Air Walk');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Psi-Dagger', 'Special', 8, NULL, NULL, 'Self.', 'Five minutes per level of experience.', NULL, 'Exclusive to the Psi-Slayer, who picks two of his four exclusive powers. A small version of the Psi-Sword: Damage 1D4 M.D. at first level, +1D4 M.D. at levels four, eight and twelve. Far weaker than a Psi-Sword, but cheap in I.S.P., small and easy to conceal, which suits assassinations - especially inside mega-cities where mega-damage weapons are outlawed and few people wear M.D.C. body armor.', 'import', 'Rifts World Book 12: Psyscape p.72-73'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Psi-Dagger');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Machine & Electrical Diagnosis', 'Special', 6, NULL, NULL, 'Touch.', 'Two minutes per level of experience.', NULL, 'An R.C.C. ability of the Psi-Tech: a more specific, specialised form of Object Read for devices. By touch the psychic senses the cause of a malfunction, pinpoints the problem or damage, and knows what must be done to fix it. The repair itself still needs the relevant skill or psi-power roll.', 'import', 'Rifts World Book 12: Psyscape p.75'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Machine & Electrical Diagnosis');

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('electro-stunner', 'Electro-Stunner', 'rifts', 'weapon', NULL, NULL, 'Psyscape prints no price.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A hand-held electrical stun weapon, offered as the alternative to a Neuro-Mace in the Psi-Nullifier''s (printed 69) and the Zapper''s (printed 83) equipment. Psyscape prints no statistics and refers to Rifts Lone Star, which this catalog does not hold, so damage, range and cost are not stored. Not the CS robot''s mounted H-02 Electro-Stunner (Coalition War Campaign printed 142).', 'Rifts World Book 12: Psyscape p.69'),
('fake-identification', 'Fake Identification (one set)', 'rifts', 'gear', NULL, NULL, 'Psyscape prints no price.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'One set of forged identity papers. The Psi-Slayer (printed 74) and the Zenith Moon Warper (printed 140) each start with 1D4+1 sets.', 'Rifts World Book 12: Psyscape p.74'),
('eraser', 'Eraser', 'rifts', 'gear', NULL, NULL, 'Psyscape prints no price.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A pencil eraser, part of the Yhabbayar''s drawing kit with its pens, markers, pencils and sketch book (printed 135).', 'Rifts World Book 12: Psyscape p.135');

-- Read-backs.
SELECT 'five Special psionic powers from Psyscape' AS assertion, count(*) AS got, 5 AS want
  FROM psionic_powers
 WHERE category = 'Special' AND source_book LIKE 'Rifts World Book 12: Psyscape p.%';

SELECT 'their printed costs sum to 30 (6+6+4+8+6)' AS assertion, sum(isp) AS got, 30 AS want
  FROM psionic_powers
 WHERE name IN ('Sleepwalk', 'Locate & Track Mark', 'Telekinetic Air Walk', 'Psi-Dagger',
                'Machine & Electrical Diagnosis');

SELECT 'and none of the five carries a game tag' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE category = 'Special' AND source_book LIKE 'Rifts World Book 12: Psyscape p.%'
   AND system IS NOT NULL;

SELECT 'three Psyscape gear rows by slug' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE slug IN ('electro-stunner', 'fake-identification', 'eraser')
   AND source_book LIKE 'Rifts World Book 12: Psyscape p.%';

SELECT 'no stub marker on them' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE slug IN ('electro-stunner', 'fake-identification', 'eraser')
   AND description LIKE '%STUB%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~019-psyscape-exclusive-powers-and-gear.sql');
