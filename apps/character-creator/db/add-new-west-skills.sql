-- The skills Rifts World Book 14: New West adds, printed 70-81 - and it is a
-- much shorter list than that page range suggests.
--
-- One-off data script, run once per environment. NOT a migration - it adds and
-- corrects rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-new-west-skills.sql
--
-- The book has a TEXT LAYER. Offset from scripts/books.json: page_offset 1, no
-- exceptions, so printed N is cache p(N+1). None of printed 70-81 is on this
-- book's welded or glyph-corrupt list.
--
-- ONLY THREE ROWS ARE NEW, out of 38 skill definitions on printed 71-79.
-- `catalog-diff --remote --table skills` over 43 entries returned matched 30,
-- missing 13; nine of the thirteen were rows the catalog already holds under
-- another name, and one more turned out to be a second spelling of a row this
-- book itself names correctly forty-eight times. Hand-checked one at a time
-- against production rather than taken from the diff:
--
--   the book prints                        the catalog holds
--   Horsemanship: Exotic                   Horsemanship: Exotic Animals
--   Lore: Indians                          Lore: American Indians
--   Imitate Voices & Impersonation         Imitate Voices & Sounds
--   Armorer (Field Armorer)                Field Armorer & Munitions Expert
--   Find Contraband, Weapons & Cybernetics Find Contraband
--   Nuclear, Biological, & Chemical Warfare NBC Warfare
--   Underwater Demolitions                 Demolitions: Underwater
--   Hovercycle                             Hovercycles, Skycycles & Rocket Bikes
--   Safecracking                           Safe-Cracking
--   W.P. Snapshooting Specialty            W.P. Sharpshooting   -- see below
--
-- THE REASON THE LIST IS SO SHORT IS RIFTS ULTIMATE EDITION. RUE p.302-303
-- reprints this book's cowboy and horsemanship skills wholesale, and the
-- catalog already holds all of them from there - Branding, Breaking/Taming
-- Wild Horse, Herding Cattle, Horsemanship: Cowboy, Lore: American Indians,
-- Lore: Cattle & Animals, Roping, Trick Riding and the whole Horsemanship
-- category. RUE is the later book, so those rows stand untouched. Their base
-- percentages were spot-checked against printed 73-74 and agree: Horsemanship
-- Cowboy 66, Cyber-Knight 70, Exotic Animals 30.
--
-- "W.P. SNAPSHOOTING SPECIALTY" IS NOT A NEW SKILL, and this is the one that
-- would have shipped as a duplicate. The heading on printed 79 and the entries
-- in both indexes read "Snapshooting", and the body of that same entry says
-- "Sharpshooting" throughout. Counted across the whole book: Snapshooting 9,
-- Sharpshooting 48 - and the class entries that GRANT it write it out as
-- "Sharpshooting: Revolver" (printed 108) and "W.P. Snapshooting Specialty:
-- Sharpshooting: Revolver" in the same line. One skill, two spellings, and the
-- catalog already holds it as W.P. Sharpshooting from Juicer Uprising p.57.
-- This script enriches that row rather than adding a second one.
--
-- W.P. ROPE IS NOT IN THIS BOOK AT ALL, and the catalog said it was. The row
-- `skills.W.P. Rope` carried `source_book = 'Rifts New West'` - the whole of
-- this book's 0/1 line in source-coverage, and the reason it was 0: the
-- citation has no page range, so nothing could check it. The book's W.P.
-- section on printed 79 defines exactly three - Bola, Whip, Snapshooting
-- Specialty - and its skill list on printed 71 names the same three. A grep of
-- all 226 cached pages finds no "W.P. Rope" anywhere.
--
-- It is Rifts Ultimate Edition's. RUE lists it on printed 302 among the Cowboy
-- skills and on 303 among the W.P.s, and DESCRIBES it on printed 306 - the
-- lariat and lasso, the trip attack, the entangle and disarm rolls. This
-- script re-cites the row to RUE p.306. Its level_bonuses block already
-- matches that description and is not touched.
--
-- The eight cowboy skills that DO come from RUE all cite "Rifts Ultimate
-- Edition p.302-303", the list pages. W.P. Rope cites p.306 instead because
-- that is where the entry actually is; a citation is checkable or it is
-- decoration, which is what this row has just spent however long demonstrating.

INSERT INTO skills
  (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES
  ('History of the West', 'Technical', 30, 5, NULL, 'import',
   'Rifts World Book 14: New West p.79',
   'Myths, legends and distorted history of the pre-Rifts and post-Rifts West - cowboys, gunslingers, Indians and their weapons and manners, the Code of the New West and the Cowboy''s Code, and notable monsters, outlaws and famous people. The roll is how much of it the character remembers accurately.',
   NULL, NULL),
  ('Prospecting', 'Technical', 20, 5, NULL, 'import',
   'Rifts World Book 14: New West p.79',
   'Recognising and valuing precious and semi-precious metals as raw ore and as worked jewelry, knowing where deposits are likely to be, panning for gold, and the fundamentals of mining and simple mining equipment. Identifying a fake is the same roll at -10%; a failed roll means the character cannot tell either way.',
   NULL, NULL),
  ('W.P. Bola', 'Weapon Proficiencies', 0, 0, NULL, 'import',
   'Rifts World Book 14: New West p.79',
   'Three weighted cords joined at one end, thrown to entangle the legs and bring down a running target. One or two weights are used for small game.',
   NULL,
   '[{"level":1,"note":"2D4 S.D.C. Manufactured variants replace the weights with one to three grenades, and Northern Gun makes one that delivers a Neural Mace charge by remote once the target is ensnared."},{"level":2,"applies_when":"with a bola","combat":{"strike":1,"disarm":1,"entangle":1}},{"level":5,"applies_when":"with a bola","combat":{"strike":1,"disarm":1,"entangle":1}},{"level":10,"applies_when":"with a bola","combat":{"strike":1,"disarm":1,"entangle":1}},{"level":15,"applies_when":"with a bola","combat":{"strike":1,"disarm":1,"entangle":1}}]');

-- W.P. Rope was never this book's. Re-cited to the page that describes it.
UPDATE skills
   SET source_book = 'Rifts Ultimate Edition p.306'
 WHERE name = 'W.P. Rope'
   AND source_book = 'Rifts New West';

-- W.P. Sharpshooting: New West is the book that documents this skill properly,
-- at printed 79-81, where Juicer Uprising p.57 only names it. The bonuses it
-- prints scale on the P.P. ATTRIBUTE rather than on level, so they go in a
-- level-1 note and are NOT applied automatically - the same shape and the same
-- reason as W.P. Quick Draw, which RUE states the same way. docs/leveling.md
-- covers conditional and non-automatic W.P. bonuses; nothing here needs code.
UPDATE skills
   SET source_book = 'Rifts World Book 14: New West p.79-81',
       note = 'A paired skill: taken WITH another W.P., naming the weapon it sharpens, and it costs two O.C.C. Related picks each time. Juicer Uprising p.57 names it; New West printed 79-81 is where it is defined. Never available to robots, master psionics, practitioners of magic, dragons, demons or supernatural beings, and Juicers, Crazies and Borgs may take only one.',
       level_bonuses = '[{"level":1,"note":"Bonuses scale on P.P., not on level, and are NOT applied automatically. Aimed shot: +1 to strike at P.P. 20 and +1 per further five points above 20. Called shot: instead of the aimed bonus, +1 to strike at P.P. 18 and +1 per further three points above 18, and the shot costs two melee actions. Quick draw: +1 to initiative at P.P. 18 and +1 per further four points. All of it applies only to the one W.P. the specialty was bought for."},{"level":1,"note":"One extra melee attack when using that specific weapon for the whole round."},{"level":1,"note":"Trick shooting: most Men at Arms pick one of six, and the Gunfighter, Sheriff and Gunslinger get all six. Cannot be applied to W.P. Heavy or Heavy Energy Weapons, nor to any weapon that is not shot."}]'
 WHERE name = 'W.P. Sharpshooting';

-- Read back what this script touched.
SELECT name, category, base, per_level, source_book
  FROM skills
 WHERE source_book LIKE 'Rifts World Book 14: New West%'
    OR name = 'W.P. Rope'
 ORDER BY name;
SELECT COUNT(*) AS total_skills FROM skills;

-- Records this run.
INSERT INTO data_script_runs (filename) VALUES ('add-new-west-skills.sql');
