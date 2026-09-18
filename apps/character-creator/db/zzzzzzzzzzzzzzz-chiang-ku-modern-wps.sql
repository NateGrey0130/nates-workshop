-- The Chiang-Ku Dragon's "three modern weapon proficiencies", named.
--
-- Palladium Fantasy Dragons and Gods printed 22-23 gives the dragon "three
-- ancient (and three modern) Weapon Proficiencies" in its Palladium block, not
-- only in its Rifts conversion box. The class stored the modern half as a bare
-- choose-3 from the whole Weapon Proficiencies category. Since
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql, Palladium Fantasy's tag holds only
-- ancient W.P.s, so that group offered fifteen ancient weapons under a note
-- saying modern.
--
-- The group now names the modern W.P.s in an `only` list. A skill a class names
-- that way is offered past the game filter for that grant alone (parser.js
-- namedByOnly, read by the wizard's catalogFor and the NPC generator), so the
-- dragon can take a pistol and no other Palladium Fantasy class is offered one.
--
-- Keyed on class_id and guarded on the text it replaces, so a re-run is a
-- no-op. Sorts after every file that rewrites this class, the last being
-- zzzzzzzzzzzzzz-hand-to-hand-prices.sql.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzz-chiang-ku-modern-wps.sql

UPDATE imported_classes
   SET markdown = replace(markdown,
         '{ choose: 3, categories: ["Weapon Proficiencies"], note: "Three modern weapon proficiencies of choice" }',
         '{ choose: 3, categories: [{ name: "Weapon Proficiencies", only: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Handguns", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"] }], note: "Printed 23: three modern W.P.s of choice. Named, so the pick reaches past the Palladium Fantasy skill list." }'),
       updated_at = datetime('now')
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, '{ choose: 3, categories: ["Weapon Proficiencies"], note: "Three modern weapon proficiencies of choice" }') > 0;

-- ASSERTIONS.

SELECT 'the modern group names its W.P.s' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, 'only: ["W.P. Automatic Pistol"') > 0;

SELECT 'and the bare modern group is gone' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, 'note: "Three modern weapon proficiencies of choice"') > 0;

SELECT 'every name it lists is a catalog skill' AS assertion, count(*) AS got, 13 AS want
  FROM skills
 WHERE name IN ('W.P. Automatic Pistol', 'W.P. Automatic and Semi-automatic Rifles', 'W.P. Bolt Action Rifle',
                'W.P. Energy Pistol', 'W.P. Energy Rifle', 'W.P. Handguns', 'W.P. Heavy M.D. Weapons',
                'W.P. Heavy Military Weapons', 'W.P. Military Flamethrowers', 'W.P. Revolver', 'W.P. Rifles',
                'W.P. Shotgun', 'W.P. Submachine-Gun')
   AND category = 'Weapon Proficiencies';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzz-chiang-ku-modern-wps.sql');
