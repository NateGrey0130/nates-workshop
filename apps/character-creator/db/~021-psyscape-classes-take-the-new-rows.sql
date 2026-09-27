-- Wires six Rifts World Book 12: Psyscape classes to the rows
-- ~020-psyscape-exclusive-powers-and-gear.sql added, and rewrites each note
-- that said the row did not exist.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~021-psyscape-classes-take-the-new-rows.sql
--
--   psi-slayer          the four exclusive powers become a starting group of
--                       two picks from the four (printed 71: "select any two
--                       of the following"); powers_starting 8 -> 10; the five
--                       special_abilities that carried them as prose go; the
--                       1D4+1 sets of fake identification (printed 74) join
--                       the equipment
--   psi-tech            Machine & Electrical Diagnosis (printed 75) granted by
--                       name in powers; its special ability goes
--   psi-nullifier       "Neuro-Mace or Electro-Stunner" (printed 69) becomes a
--   zapper              choice of the two (printed 83); both granted the
--                       neural-mace outright before
--   zenith-moon-warper  1D4+1 sets of fake identification (printed 140)
--   yhabbayar           the eraser (printed 135)
--
-- MECHANICS. Each change is one replace() on text that appears exactly once in
-- the class's live markdown (checked against a --remote read on 2026-09-26 by
-- the generator that wrote this file). A replacement is guarded on its old
-- text being present; an insertion also on its new text being absent. A
-- re-run is a no-op. The file sorts after ~020, whose rows it names, and after
-- every add-*-class.sql it edits.
--
-- The read-backs assert a short marker of each change present and, where
-- text was replaced or removed, a short marker of the old text gone. They are
-- short on purpose: d1-apply sends every read-back in one --command, and
-- full-text assertions overran the Windows command line on the first try.

UPDATE imported_classes SET markdown = replace(markdown, '  powers_starting: 8
', '  powers_starting: 10
'), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, '  powers_starting: 8
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '    - { count: 2, categories: ["Mind Bleeder"], note: "Two Mind Bleeder powers at first level." }
', '    - { count: 2, categories: ["Mind Bleeder"], note: "Two Mind Bleeder powers at first level." }
    - { count: 2, from: ["Sleepwalk", "Locate & Track Mark", "Telekinetic Air Walk", "Psi-Dagger"], note: "Any two of the four powers exclusive to the Psi-Slayer (printed 71-73)." }
'), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, '    - { count: 2, categories: ["Mind Bleeder"], note: "Two Mind Bleeder powers at first level." }
') > 0 AND instr(markdown, '    - { count: 2, categories: ["Mind Bleeder"], note: "Two Mind Bleeder powers at first level." }
    - { count: 2, from: ["Sleepwalk", "Locate & Track Mark", "Telekinetic Air Walk", "Psi-Dagger"], note: "Any two of the four powers exclusive to the Psi-Slayer (printed 71-73)." }
') = 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - name: "Exclusive Psionic Powers (choose two)"
    description: "At creation the Psi-Slayer picks any TWO of the four powers below - Sleepwalk, Locate & Track Mark, Telekinetic Air Walk and Psi-Dagger. They are exclusive to the class and are not psionic_powers catalog rows."
  - name: "Sleepwalk (exclusive; one of two picks)"
    description: "Range 20 feet (6 m), line of sight. I.S.P. 6. Affects one person per level of experience, who must already be asleep or very tired and fails a save vs psionic attack at -3. Lasts five minutes per level, or until the subject has walked up to 1000 feet (305 m). Either deepens sleep so that only a loud noise or rough shaking wakes the subject, or lets the psychic coax the sleeper up and lead him somewhere, hand him an object and leave him; the subject remembers nothing. Left standing or somewhere uncomfortable he wakes in 2D6 minutes, otherwise at his normal time. Fails if the Psi-Slayer intends the subject bodily harm; the target then wakes from a nightmare of being attacked."
  - name: "Locate & Track Mark (exclusive; one of two picks)"
    description: "I.S.P. 6; save at -2. One target at a time. Needs a piece of the mark''s hair, nail, blood, skin, or clothing worn within the last four hours. While the mark is within 3 miles (4.8 km) plus 1 mile (1.6 km) per level, the psychic senses direction, distance to within 20 feet (6 m), and whether the mark is moving fast. Counter-tracking and Mind Block do not stop it. The link breaks if the mark stays out of range for more than 30 minutes."
  - name: "Telekinetic Air Walk (exclusive; one of two picks)"
    description: "Self; I.S.P. 4; lasts 10 minutes per level. The psychic levitates up to 10 feet (3 m) per level and walks on air at one third his Spd, carrying his own weight plus 15 lbs (6.8 kg) per level. While air walking: +10% to Prowl, Camouflage, Climbing, Acrobatics and Escape Artist."
  - name: "Psi-Dagger (exclusive; one of two picks)"
    description: "Self; I.S.P. 8; lasts five minutes per level. A small, easily hidden version of the Psi-Sword: 1D4 M.D. at first level, +1D4 M.D. at levels 4, 8 and 12."
', ''), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, '  - name: "Exclusive Psionic Powers (choose two)"
    description: "At creation the Psi-Slayer picks any TWO of the four powers below - Sleepwalk, Locate & Track Mark, Telekinetic Air Walk and Psi-Dagger. They are exclusive to the class and are not psionic_powers catalog rows."
  - name: "Sleepwalk (exclusive; one of two picks)"
    description: "Range 20 feet (6 m), line of sight. I.S.P. 6. Affects one person per level of experience, who must already be asleep or very tired and fails a save vs psionic attack at -3. Lasts five minutes per level, or until the subject has walked up to 1000 feet (305 m). Either deepens sleep so that only a loud noise or rough shaking wakes the subject, or lets the psychic coax the sleeper up and lead him somewhere, hand him an object and leave him; the subject remembers nothing. Left standing or somewhere uncomfortable he wakes in 2D6 minutes, otherwise at his normal time. Fails if the Psi-Slayer intends the subject bodily harm; the target then wakes from a nightmare of being attacked."
  - name: "Locate & Track Mark (exclusive; one of two picks)"
    description: "I.S.P. 6; save at -2. One target at a time. Needs a piece of the mark''s hair, nail, blood, skin, or clothing worn within the last four hours. While the mark is within 3 miles (4.8 km) plus 1 mile (1.6 km) per level, the psychic senses direction, distance to within 20 feet (6 m), and whether the mark is moving fast. Counter-tracking and Mind Block do not stop it. The link breaks if the mark stays out of range for more than 30 minutes."
  - name: "Telekinetic Air Walk (exclusive; one of two picks)"
    description: "Self; I.S.P. 4; lasts 10 minutes per level. The psychic levitates up to 10 feet (3 m) per level and walks on air at one third his Spd, carrying his own weight plus 15 lbs (6.8 kg) per level. While air walking: +10% to Prowl, Camouflage, Climbing, Acrobatics and Escape Artist."
  - name: "Psi-Dagger (exclusive; one of two picks)"
    description: "Self; I.S.P. 8; lasts five minutes per level. A small, easily hidden version of the Psi-Sword: 1D4 M.D. at first level, +1D4 M.D. at levels 4, 8 and 12."
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - The four exclusive powers (Sleepwalk, Locate & Track Mark, Telekinetic Air
    Walk, Psi-Dagger; printed 71-73) are not psionic_powers catalog rows; the
    character picks any two. Stored as special_abilities with their stats; the
    pick-two rule is not enforced. Candidate catalog rows for a later PR.
', '  - The four exclusive powers (Sleepwalk, Locate & Track Mark, Telekinetic Air
    Walk, Psi-Dagger; printed 71-73) were special_abilities with their stats
    until ~020-psyscape-exclusive-powers-and-gear.sql made them psionic_powers
    rows (category Special). ~021-psyscape-classes-take-the-new-rows.sql then made them a starting group of
    two picks from the four, so the pick-two rule is enforced, and
    powers_starting went from 8 to 10.
'), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, '  - The four exclusive powers (Sleepwalk, Locate & Track Mark, Telekinetic Air
    Walk, Psi-Dagger; printed 71-73) are not psionic_powers catalog rows; the
    character picks any two. Stored as special_abilities with their stats; the
    pick-two rule is not enforced. Candidate catalog rows for a later PR.
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "walkie-talkie", qty: 1 }
', '  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "fake-identification", qty: "1d4+1" }
'), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "walkie-talkie", qty: 1 }
') > 0 AND instr(markdown, '  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "fake-identification", qty: "1d4+1" }
') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'NOT stored:
    "1D4+1 sets of fake identification" (no gear row), "some personal items",', '"1D4+1 sets
    of fake identification" as fake-identification 1d4+1 (the row arrived
    with ~020). NOT stored: "some personal items",'), updated_at = datetime('now')
 WHERE class_id = 'psi-slayer' AND deleted_at IS NULL AND instr(markdown, 'NOT stored:
    "1D4+1 sets of fake identification" (no gear row), "some personal items",') > 0;

SELECT 'psi-slayer: every new text is in' AS assertion, (instr(markdown, 'powers_starting: 10') > 0) + (instr(markdown, 'from: ["Sleepwalk", "Locate & Track Mark", "Telekinetic Air Walk", "Psi-Dagger"]') > 0) + (instr(markdown, 'so the pick-two rule is enforced') > 0) + (instr(markdown, 'item_id: "fake-identification", qty: "1d4+1"') > 0) + (instr(markdown, 'fake-identification 1d4+1 (the row arrived') > 0) AS got, 5 AS want
  FROM imported_classes WHERE class_id = 'psi-slayer' AND deleted_at IS NULL;

SELECT 'psi-slayer: every replaced text is gone' AS assertion, (instr(markdown, 'powers_starting: 8') > 0) + (instr(markdown, 'name: "Exclusive Psionic Powers (choose two)"') > 0) + (instr(markdown, 'pick-two rule is not enforced') > 0) + (instr(markdown, '(no gear row)') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'psi-slayer' AND deleted_at IS NULL;

UPDATE imported_classes SET markdown = replace(markdown, '    - "Total Recall"
  powers_starting: 2
', '    - "Total Recall"
    - "Machine & Electrical Diagnosis"
  powers_starting: 2
'), updated_at = datetime('now')
 WHERE class_id = 'psi-tech' AND deleted_at IS NULL AND instr(markdown, '    - "Total Recall"
  powers_starting: 2
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - name: "Machine & Electrical Diagnosis"
    description: "A specialised Object Read for devices: by touch the Psi-Tech senses what is malfunctioning or damaged and what must be done to fix it. The repair itself still needs the relevant skill or psi-power roll. Range: touch. Duration: two minutes per level of experience. I.S.P.: 6."
', ''), updated_at = datetime('now')
 WHERE class_id = 'psi-tech' AND deleted_at IS NULL AND instr(markdown, '  - name: "Machine & Electrical Diagnosis"
    description: "A specialised Object Read for devices: by touch the Psi-Tech senses what is malfunctioning or damaged and what must be done to fix it. The repair itself still needs the relevant skill or psi-power roll. Range: touch. Duration: two minutes per level of experience. I.S.P.: 6."
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - Machine & Electrical Diagnosis (6 I.S.P.) is a class ability, not a catalog psionic row; stored as a special ability, not in powers.
', '  - Machine & Electrical Diagnosis (6 I.S.P., printed 75) was a special ability until ~020-psyscape-exclusive-powers-and-gear.sql made it a psionic_powers row (category Special); ~021-psyscape-classes-take-the-new-rows.sql granted it by name in powers and dropped the special ability.
'), updated_at = datetime('now')
 WHERE class_id = 'psi-tech' AND deleted_at IS NULL AND instr(markdown, '  - Machine & Electrical Diagnosis (6 I.S.P.) is a class ability, not a catalog psionic row; stored as a special ability, not in powers.
') > 0;

SELECT 'psi-tech: every new text is in' AS assertion, (instr(markdown, '- "Machine & Electrical Diagnosis"') > 0) + (instr(markdown, 'was a special ability until ~020') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'psi-tech' AND deleted_at IS NULL;

SELECT 'psi-tech: every replaced text is gone' AS assertion, (instr(markdown, '- name: "Machine & Electrical Diagnosis"') > 0) + (instr(markdown, 'is a class ability, not a catalog psionic row') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'psi-tech' AND deleted_at IS NULL;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "neural-mace", qty: 1 }
', '  - { choose: 1, label: "Neuro-Mace or Electro-Stunner", qty: 1, from: ["neural-mace", "electro-stunner"] }
'), updated_at = datetime('now')
 WHERE class_id = 'psi-nullifier' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "neural-mace", qty: 1 }
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '"Neuro-Mace or
    Electro-Stunner (Rifts Lone Star)" - no Electro-Stunner row exists, so the
    neural-mace is granted.', '"Neuro-Mace or
    Electro-Stunner (Rifts Lone Star)" is a choice of neural-mace or
    electro-stunner; the neural-mace was granted outright until ~020 added
    the Electro-Stunner row.'), updated_at = datetime('now')
 WHERE class_id = 'psi-nullifier' AND deleted_at IS NULL AND instr(markdown, '"Neuro-Mace or
    Electro-Stunner (Rifts Lone Star)" - no Electro-Stunner row exists, so the
    neural-mace is granted.') > 0;

SELECT 'psi-nullifier: every new text is in' AS assertion, (instr(markdown, 'from: ["neural-mace", "electro-stunner"]') > 0) + (instr(markdown, 'is a choice of neural-mace or') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'psi-nullifier' AND deleted_at IS NULL;

SELECT 'psi-nullifier: every replaced text is gone' AS assertion, (instr(markdown, '- { item_id: "neural-mace", qty: 1 }') > 0) + (instr(markdown, 'no Electro-Stunner row exists') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'psi-nullifier' AND deleted_at IS NULL;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "neural-mace", qty: 1 }
', '  - { choose: 1, label: "Neuro-Mace or Electro-Stunner", qty: 1, from: ["neural-mace", "electro-stunner"] }
'), updated_at = datetime('now')
 WHERE class_id = 'zapper' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "neural-mace", qty: 1 }
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '"Neuro-Mace or Electro-Stunner (see
    Rifts Lone Star)": no Electro-Stunner row exists, so the neural-mace is
    granted.', '"Neuro-Mace or Electro-Stunner (see
    Rifts Lone Star)" is a choice of neural-mace or electro-stunner; the
    neural-mace was granted outright until ~020 added the Electro-Stunner row.'), updated_at = datetime('now')
 WHERE class_id = 'zapper' AND deleted_at IS NULL AND instr(markdown, '"Neuro-Mace or Electro-Stunner (see
    Rifts Lone Star)": no Electro-Stunner row exists, so the neural-mace is
    granted.') > 0;

SELECT 'zapper: every new text is in' AS assertion, (instr(markdown, 'from: ["neural-mace", "electro-stunner"]') > 0) + (instr(markdown, 'is a choice of neural-mace or') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'zapper' AND deleted_at IS NULL;

SELECT 'zapper: every replaced text is gone' AS assertion, (instr(markdown, '- { item_id: "neural-mace", qty: 1 }') > 0) + (instr(markdown, 'no Electro-Stunner row exists') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'zapper' AND deleted_at IS NULL;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "e-clip", qty: "1d4+1" }
', '  - { item_id: "e-clip", qty: "1d4+1" }
  - { item_id: "fake-identification", qty: "1d4+1" }
'), updated_at = datetime('now')
 WHERE class_id = 'zenith-moon-warper' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "e-clip", qty: "1d4+1" }
') > 0 AND instr(markdown, '  - { item_id: "e-clip", qty: "1d4+1" }
  - { item_id: "fake-identification", qty: "1d4+1" }
') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'NOT STORED:
    jewelry, 1D4+1 sets of fake identification (no gear row), personal', '1D4+1 sets of fake
    identification are fake-identification 1d4+1 (the row arrived with ~020).
    NOT STORED: jewelry, personal'), updated_at = datetime('now')
 WHERE class_id = 'zenith-moon-warper' AND deleted_at IS NULL AND instr(markdown, 'NOT STORED:
    jewelry, 1D4+1 sets of fake identification (no gear row), personal') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Starting gear also includes jewelry, 1D4+1 sets of fake identification,
personal items,', 'Starting gear also includes jewelry,
personal items,'), updated_at = datetime('now')
 WHERE class_id = 'zenith-moon-warper' AND deleted_at IS NULL AND instr(markdown, 'Starting gear also includes jewelry, 1D4+1 sets of fake identification,
personal items,') > 0;

SELECT 'zenith-moon-warper: every new text is in' AS assertion, (instr(markdown, 'item_id: "fake-identification", qty: "1d4+1"') > 0) + (instr(markdown, 'fake-identification 1d4+1 (the row arrived') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'zenith-moon-warper' AND deleted_at IS NULL;

SELECT 'zenith-moon-warper: every replaced text is gone' AS assertion, (instr(markdown, '(no gear row)') > 0) + (instr(markdown, 'jewelry, 1D4+1 sets of fake identification,') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'zenith-moon-warper' AND deleted_at IS NULL;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "pencil", qty: 2 }
', '  - { item_id: "pencil", qty: 2 }
  - { item_id: "eraser", qty: 1 }
'), updated_at = datetime('now')
 WHERE class_id = 'yhabbayar' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "pencil", qty: 2 }
') > 0 AND instr(markdown, '  - { item_id: "pencil", qty: 2 }
  - { item_id: "eraser", qty: 1 }
') = 0;

UPDATE imported_classes SET markdown = replace(markdown, 'two marker pens and two
    pencils (no eraser row);', 'two marker pens, two
    pencils and an eraser (the eraser row arrived with ~020);'), updated_at = datetime('now')
 WHERE class_id = 'yhabbayar' AND deleted_at IS NULL AND instr(markdown, 'two marker pens and two
    pencils (no eraser row);') > 0;

SELECT 'yhabbayar: every new text is in' AS assertion, (instr(markdown, 'item_id: "eraser", qty: 1') > 0) + (instr(markdown, 'and an eraser (the eraser row arrived with ~020)') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'yhabbayar' AND deleted_at IS NULL;

SELECT 'yhabbayar: every replaced text is gone' AS assertion, (instr(markdown, '(no eraser row)') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'yhabbayar' AND deleted_at IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~021-psyscape-classes-take-the-new-rows.sql');
