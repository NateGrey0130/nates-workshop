-- The vampires' exclusive psionic power, Nightbane RPG printed 185. One row.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-nb-0-psionic-super-hypnotic-suggestion.sql
--
-- Survey D7 (#1128) resolved the book's `Suggestion` to the existing `Hypnotic
-- Suggestion` and held this one back to ship with the vampire classes, which grant it
-- by name. The book heads it "(special)" and calls it new and exclusive to vampires;
-- the catalog has no special category, and `Hypnotic Suggestion` is filed as Super, so
-- this is Super too, with the book's wording kept in the description.
--
-- THE FILENAME IS DELIBERATE. The vampire class scripts (add-nb-secondary-vampire-,
-- add-nb-wild-vampire-, add-nb-wampyr-class.sql) name this power, and `class-check
-- --emit-script` writes a zero-I.S.P. stub for any power production lacks. This file
-- sorts BEFORE every add-nb-*-class.sql and was applied --remote before those scripts
-- were emitted, so no stub was written and none can win a clean rebuild.

INSERT INTO psionic_powers
  (name, category, isp, isp_note, variant_note, source, source_book, system, range, duration, saving_throw, description, min_tier)
VALUES
  ('Super-Hypnotic Suggestion', 'Super', 20, NULL, NULL, 'import', 'Nightbane RPG p.185', 'nightbane',
   'Line of sight; must look the victim directly in the eyes (the vampire''s eyes glow red or yellow)',
   'Five minutes per level of experience (20 minutes for the average vampire), or until the vampire is killed or willingly releases the victim',
   'Standard',
   'This mind control power enables the vampire to place any living creature in a light trance and enforce his will over the victim''s. The vampire''s commands will be obeyed except where they would go completely against the victim''s alignment. By cunningly using this power, the vampire can phrase a command in a way that the victim will have no compunction to refuse. The book files it as a special power, new and exclusive to vampires; the vampire''s psionic powers are all equal to a fourth level psionic.',
   NULL);

-- Read the result back.
SELECT 'Super-Hypnotic Suggestion is in at 20 I.S.P., as nightbane' AS assertion, count(*) AS got, 1 AS want
  FROM psionic_powers WHERE name = 'Super-Hypnotic Suggestion' AND isp = 20 AND system = 'nightbane'
   AND source_book = 'Nightbane RPG p.185' AND length(description) > 200;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-nb-0-psionic-super-hypnotic-suggestion.sql');
