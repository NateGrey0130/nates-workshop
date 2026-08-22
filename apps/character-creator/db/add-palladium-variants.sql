-- What the Palladium Fantasy main book states, where it differs.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires migration 033.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-palladium-variants.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-palladium-variants.sql
--
-- THE RULE: the later book wins. Rifts Ultimate Edition (2005) over the Rifts
-- Book of Magic, either over the Palladium Fantasy main book (1983). So NO
-- STORED NUMBER CHANGES HERE - every value already comes from a Rifts book and
-- stays. What lands is the LOSING number, recorded rather than discarded,
-- because a GM running Palladium Fantasy wants to know the book at their elbow
-- says 10 P.P.E. where the sheet says 7.
--
-- The rule proved itself before it was written down. Of 78 psionic powers the
-- Palladium book shares with the catalog, exactly TWO disagree - Commune with
-- Spirit and Sense Dimensional Anomaly - and those are precisely the two RUE
-- corrected earlier. The catalog had been carrying Palladium's older numbers.
--
-- SCALE, measured before any of this was written: 31 disagreements across 273
-- shared rows. Skills disagree most (15 of 45 matched), spells rarely (14 of
-- 150), psionics almost never (2 of 78).
--
-- Skills use their existing free-text `note`. Spells and psionic powers use
-- `variant_note` from migration 033, NOT ppe_note/isp_note: the wizard renders
-- `${sp.ppe}${sp.ppe_note ? '+' : ''}`, so the mere presence of that column
-- means "this cost varies" and would make fourteen fixed-cost spells display as
-- variable ones.
--
-- GENERATED from the parsed book and the live catalog, not from anything
-- retyped: a hand-built guard table got three of fifteen catalog values wrong,
-- because the survey printed only the field that differed.
--
-- A skill that already carries a note gets this APPENDED. Overwriting would
-- have discarded three real ones - "Requires: Electronics:", "base transcribed
-- from...".
--
-- Guarded on the stored values still being what was surveyed, so a row somebody
-- has since changed stops rather than gaining a stale note.

-- ---- skills: 15 rows
UPDATE skills SET note = 'Palladium Fantasy: 15% +5% per level'
 WHERE name = 'Cryptography' AND base = 25 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 30% +5% per level'
 WHERE name = 'Cook' AND base = 35 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 30% +5% per level'
 WHERE name = 'Fishing' AND base = 40 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = note || '; Palladium Fantasy: 25% +5% per level'
 WHERE name = 'Play Musical Instrument' AND base = 35 AND per_level = 5 AND note IS NOT NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 30% +5% per level'
 WHERE name = 'Sing' AND base = 35 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 25% +5% per level'
 WHERE name = 'Escape Artist' AND base = 30 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = note || '; Palladium Fantasy: 25%, no per-level gain'
 WHERE name = 'Brewing' AND base = 25 AND per_level = 5 AND note IS NOT NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 30% +5% per level'
 WHERE name = 'First Aid' AND base = 45 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = note || '; Palladium Fantasy: 20% +5% per level'
 WHERE name = 'Interrogation Techniques' AND base = 40 AND per_level = 5 AND note IS NOT NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = note || '; Palladium Fantasy: 25% +5% per level'
 WHERE name = 'Surveillance' AND base = 30 AND per_level = 5 AND note IS NOT NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 40% +5% per level'
 WHERE name = 'Swimming' AND base = 50 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 15% +5% per level'
 WHERE name = 'Locate Secret Compartments' AND base = 20 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = note || '; Palladium Fantasy: 40%, no per-level gain'
 WHERE name = 'Breed Dogs' AND base = 40 AND per_level = 5 AND note IS NOT NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 30% +5% per level'
 WHERE name = 'Masonry' AND base = 40 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';
UPDATE skills SET note = 'Palladium Fantasy: 20%, no per-level gain'
 WHERE name = 'Track & Trap Animals' AND base = 20 AND per_level = 5 AND note IS NULL AND COALESCE(note, '') NOT LIKE '%Palladium Fantasy:%';

-- ---- spells: 14 rows
UPDATE spells SET variant_note = 'Palladium Fantasy: 6 P.P.E.'
 WHERE name = 'Impervious to Fire' AND level = 3 AND ppe = 5 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 3 P.P.E.'
 WHERE name = 'Resist Fire' AND level = 3 AND ppe = 6 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: level 3 and 8 P.P.E.'
 WHERE name = 'See Wards' AND level = 7 AND ppe = 20 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 8 P.P.E.'
 WHERE name = 'Blind' AND level = 4 AND ppe = 6 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 10 P.P.E.'
 WHERE name = 'Fire Bolt' AND level = 4 AND ppe = 7 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 15 P.P.E.'
 WHERE name = 'Energy Disruption' AND level = 5 AND ppe = 12 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: level 6'
 WHERE name = 'Swim as a Fish (Superior)' AND level = 5 AND ppe = 12 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 25 P.P.E.'
 WHERE name = 'Second Sight' AND level = 7 AND ppe = 20 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: level 9 and 50 P.P.E.'
 WHERE name = 'Havoc' AND level = 10 AND ppe = 70 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 250 P.P.E.'
 WHERE name = 'Protection Circle: Superior' AND level = 13 AND ppe = 300 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 260 P.P.E.'
 WHERE name = 'Summon and Control Storm' AND level = 13 AND ppe = 300 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: level 15 and 2000 P.P.E.'
 WHERE name = 'Resurrection' AND level = 14 AND ppe = 650 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: level 15 and 580 P.P.E.'
 WHERE name = 'Summon Greater Familiar' AND level = 10 AND ppe = 80 AND variant_note IS NULL;
UPDATE spells SET variant_note = 'Palladium Fantasy: 5000 P.P.E.'
 WHERE name = 'Crimson Wall of Lictalon' AND level = 15 AND ppe = 6000 AND variant_note IS NULL;

-- ---- psionic powers: 2 rows
-- The two that prove the rule: RUE corrected both, and this is where the
-- old numbers came from.
UPDATE psionic_powers SET variant_note = 'Palladium Fantasy: 8 I.S.P.'
 WHERE name = 'Commune with Spirit' AND isp = 6 AND variant_note IS NULL;
UPDATE psionic_powers SET variant_note = 'Palladium Fantasy: 6 I.S.P.'
 WHERE name = 'Sense Dimensional Anomaly' AND isp = 4 AND variant_note IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT (SELECT count(*) FROM skills WHERE note LIKE '%Palladium Fantasy:%') AS skills_noted,
       (SELECT count(*) FROM spells WHERE variant_note IS NOT NULL) AS spells_noted,
       (SELECT count(*) FROM psionic_powers WHERE variant_note IS NOT NULL) AS psionics_noted;

-- Nothing moved: no stored number changed, only notes were added.
SELECT (SELECT count(*) FROM spells) AS spells_total,
       (SELECT count(*) FROM skills) AS skills_total,
       (SELECT count(*) FROM psionic_powers) AS psionics_total;

INSERT INTO data_script_runs (filename) VALUES ('add-palladium-variants.sql');
