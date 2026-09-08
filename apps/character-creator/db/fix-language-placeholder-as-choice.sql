-- Nine classes granted the Language: Other PLACEHOLDER as a fixed skill.
--
-- BOOK-INGEST-AUDIT.md F34, taken in PR #832.
--
-- `Language: Other` is a placeholder row. It exists to be PICKED FROM so the
-- player names the actual language; a class that grants it fixed leaves the
-- character holding a skill called, literally, "Language: Other". The literacy
-- family has been guarded against exactly this since regression.mjs learned to
-- look; the language family was not, so the identical mistake was fatal on one
-- and invisible on the other.
--
-- NINE, NOT THE FIFTEEN THE FINDING'S PROPOSAL ASKS FOR. Six of the fifteen
-- carry a fixed NAMED tongue at 98% - Br'talb on the demon-hound-rider and
-- sky-rider, Promethean on the four Promethean/phase classes - which is a
-- language the book NAMES, not a selection the player makes. Converting those
-- would be the regression, not the fix. They are untouched here.
--
-- godling has TWO entries and only the second is converted. The first is
-- `base: 98, per_level: 0, note: "One language of choice, at 98%."` - the
-- legitimate SHAPE with the defect's WORDING, and the one entry in the set
-- where the two signals disagree. It is left fixed on Nate's decision, and the
-- arithmetic says the same: 98% flat cannot be reproduced by a bonus on a
-- 50% +5%/level row, so a conversion would change what the class grants.
--
-- EVERY CONVERSION HERE IS LOSSLESS, which is why `bonus` and not `base`:
-- `Language: Other` is 50% +5%/level, `bonus` adds to each pick's own base, and
-- every one of these eight is base = 50 + B with per_level already 5. The
-- ninth, godling's second, is already `choose: 2, bonus: 15` and merely carries
-- a `name` alongside - which makes `isChoiceGroup` (it requires `!entry.name`)
-- read it as a fixed skill, so the `choose: 2` has been silently ignored and
-- the class has been granting one 65% skill named "Language: Other" instead of
-- offering two languages.

-- -- the eight with per_level 5: fixed grant -> a pick of one ----------------
UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 65, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 15,'), updated_at = datetime('now')
 WHERE class_id = 'freelancer';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 70, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 20,'), updated_at = datetime('now')
 WHERE class_id = 'knight-of-the-order-of-the-hospital';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 65, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 15,'), updated_at = datetime('now')
 WHERE class_id = 'knight-of-the-order-of-the-temple';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 70, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 20,'), updated_at = datetime('now')
 WHERE class_id = 'ngr-medical-officer';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 60, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 10,'), updated_at = datetime('now')
 WHERE class_id = 'ngr-field-mechanic';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 60, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 10,'), updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 70, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 20,'), updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-combat-pilot';

UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", base: 60, per_level: 5,',
  '{ choose: 1, from: ["Language: Other"], bonus: 10,'), updated_at = datetime('now')
 WHERE class_id = 'ngr-police';

-- -- godling's SECOND entry only ---------------------------------------------
-- Anchored on `choose: 2`, which the first entry does not have, so this cannot
-- touch the 98% one two lines above it.
UPDATE imported_classes SET markdown = replace(markdown,
  '{ name: "Language: Other", choose: 2, bonus: 15,',
  '{ choose: 2, from: ["Language: Other"], bonus: 15,'), updated_at = datetime('now')
 WHERE class_id = 'godling';

-- Every replace must have bitten, and the six must NOT have moved. A replace()
-- that matches nothing succeeds silently and leaves the row exactly as it was.
SELECT
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, '{ name: "Language: Other", base: 65, per_level: 5,') > 0) AS left_65,
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, '{ name: "Language: Other", base: 70, per_level: 5,') > 0) AS left_70,
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, '{ name: "Language: Other", base: 60, per_level: 5,') > 0) AS left_60,
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, '{ name: "Language: Other", choose: 2,') > 0) AS left_godling,
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, '{ name: "Language: Other", base: 98, per_level: 0,') > 0) AS kept_98;

INSERT INTO data_script_runs (filename) VALUES ('fix-language-placeholder-as-choice.sql');
