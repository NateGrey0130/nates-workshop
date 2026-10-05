-- Related-skill category bonuses that were printed in a note and applied by
-- nothing, part 2 of 2.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~123-category-bonuses-stored-as-notes-part-2.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~123-category-bonuses-stored-as-notes-part-2.sql
--
-- Close-out package A13: the backlog BOOK-INGEST-AUDIT F109 left as "about
-- forty live classes" and never measured. A sweep of every published class
-- (production, 2026-10-04) found 284 related-skill category entries whose
-- note carries a percentage, in 83 classes. js/parser.js categoryBonus reads
-- an entry's `bonus` key and nothing else, so a bonus that lives only in
-- the note reaches no character.
--
-- TWO KINDS, both taken from the class's OWN stored note; no book was reopened:
--   plain    the note is the category's bonus ("+10%") and the entry had no
--            `bonus`: the key is added. Most of these are the Palladium
--            Fantasy core classes, imported before the key existed.
--   scoped   the bonus is for part of the category ("+10% on Lore, Language
--            and Literacy only", "+10%, and +15% on Disguise"): a second entry
--            naming those skills carries it, F109's shape, the existing entry
--            first. Every name in an `only` list is a catalog row of that
--            category, checked when this file was generated.
-- Three New West classes stored `only` plus a bonus where their note says
-- any skill of the category may be taken; they gain the open entry first.
--
-- LEFT, each for a reason the generator records: a bonus that depends on
-- alignment or on the player's choice of picks; a skill the catalog files
-- under another category; four Mystic Russia Pilot lines whose page must say
-- whether an exception bars the skills or only the bonus. Ten classes are
-- Phase C's and are not touched here.
--
-- No skill's bonus goes down except where a class had given a whole category
-- a bonus its own note prints against two or three named skills: the
-- generator compared categoryBonus for every catalog skill, before and
-- after, in every class it edits, and refuses any other fall.
-- Every replace() is guarded and a second run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: 27 class rows.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "First Aid only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "First Aid only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Pilot", note: "+2%" }
',
         '      - { name: "Pilot", bonus: 2, note: "+2%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Pilot", note: "+2%" }
') > 0
   AND instr(markdown, '      - { name: "Pilot", bonus: 2, note: "+2%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Pilot Related", note: "+2%" }
',
         '      - { name: "Pilot Related", bonus: 2, note: "+2%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Pilot Related", note: "+2%" }
') > 0
   AND instr(markdown, '      - { name: "Pilot Related", bonus: 2, note: "+2%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+5%" }
',
         '      - { name: "Rogue", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Rogue", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on lore, literacy, language or writing" }
',
         '      - { name: "Technical", note: "+10% on lore, literacy, language or writing" }
      - { name: "Technical", only: ["Creative Writing"], only_prefix: ["Lore", "Literacy", "Language"], bonus: 10, note: "+10% on lore, literacy, language or writing." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on lore, literacy, language or writing" }
') > 0
   AND instr(markdown, 'ing"], only_prefix: ["Lore", "Literacy", "Language"], bonus: 10, note: "+10% on lore, literacy, language or writing." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Escape Artist", "Disguise", "Intelligence"], note: "Escape Artist, Disguise and Intelligence only (+5%)" }
',
         '      - { name: "Espionage", only: ["Escape Artist", "Disguise", "Intelligence"], bonus: 5, note: "Escape Artist, Disguise and Intelligence only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, '      - { name: "Espionage", only: ["Escape Artist", "Disguise", "Intelligence"], note: "Escape Artist, Disguise and Int') > 0
   AND instr(markdown, ' ["Escape Artist", "Disguise", "Intelligence"], bonus: 5, note: "Escape Artist, Disguise and Intelligence only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, '      - { name: "Science", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%" }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Intelligence"], note: "Intelligence only (+5%)" }
',
         '      - { name: "Espionage", only: ["Intelligence"], bonus: 5, note: "Intelligence only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer'
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence"], note: "Intelligence only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence"], bonus: 5, note: "Intelligence only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer'
   AND instr(markdown, '      - { name: "Science", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], note: "Basic and Automotive Mechanics only (+5%)" }
',
         '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive Mechanics only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], note: "Basic and Automotive Mechanics o') > 0
   AND instr(markdown, 'ical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive Mechanics only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10% on chemistry skills" }
',
         '      - { name: "Science", note: "+10% on chemistry skills" }
      - { name: "Science", only_prefix: ["Chemistry"], bonus: 10, note: "+10% on chemistry skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, '      - { name: "Science", note: "+10% on chemistry skills" }
') > 0
   AND instr(markdown, 'emistry skills" }
      - { name: "Science", only_prefix: ["Chemistry"], bonus: 10, note: "+10% on chemistry skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%" }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+10%" }
',
         '      - { name: "Medical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Medical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Camouflage"], note: "Camouflage only (+10%)" }
',
         '      - { name: "Military", only: ["Camouflage"], bonus: 10, note: "Camouflage only (+10%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Military", only: ["Camouflage"], note: "Camouflage only (+10%)" }
') > 0
   AND instr(markdown, '      - { name: "Military", only: ["Camouflage"], bonus: 10, note: "Camouflage only (+10%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+15%" }
',
         '      - { name: "Technical", bonus: 15, note: "+15%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Technical", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+10%" }
',
         '      - { name: "Wilderness", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, '      - { name: "Wilderness", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'slayer-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'slayer-russian'
   AND instr(markdown, '      - { name: "Science", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'slayer-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems", "Surveillance"], note: "The book allows ''Radio: Basic, Scramblers & Optics and Surveillance only (+5%)''; the catalog files those as Radio: Scramblers and Optic Systems." }
',
         '      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems", "Surveillance"], bonus: 5, note: "The book allows ''Radio: Basic, Scramblers & Optics and Surveillance only (+5%)''; the catalog files those as Radio: Scramblers and Optic Systems." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems", "Surveillance"], note: "T') > 0
   AND instr(markdown, ': 5, note: "The book allows ''Radio: Basic, Scramblers & Optics and Surveillance only (+5%)''; the catalog files those as ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], note: "Disguise, Forgery, Intelligence and Wilderness Survival only (+10%). Wilderness Survival is a WILDERNESS skill in this catalog, so naming it here is cross-category - deliberate, and it works." }
',
         '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], bonus: 10, note: "Disguise, Forgery, Intelligence and Wilderness Survival only (+10%). Wilderness Survival is a WILDERNESS skill in this catalog, so naming it here is cross-category - deliberate, and it works." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], note: "Disguise, Forg') > 0
   AND instr(markdown, 'val"], bonus: 10, note: "Disguise, Forgery, Intelligence and Wilderness Survival only (+10%). Wilderness Survival is a W') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "First Aid only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "First Aid only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+10%, particularly Cardsharp and Seduction" }
',
         '      - { name: "Rogue", bonus: 10, note: "+10%, particularly Cardsharp and Seduction" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Rogue", note: "+10%, particularly Cardsharp and Seduction" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 10, note: "+10%, particularly Cardsharp and Seduction" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%; languages +15%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%; languages +15%" }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "Languages +15%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+10%; languages +15%" }
') > 0
   AND instr(markdown, ': "+10%; languages +15%" }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "Languages +15%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+10%" }
',
         '      - { name: "Wilderness", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, '      - { name: "Wilderness", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], note: "Disguise, forgery, intelligence and wilderness survival only (+10%). Wilderness Survival is a WILDERNESS skill in this catalog, so naming it here is cross-category - deliberate, and it works because the class grants Wilderness too." }
',
         '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], bonus: 10, note: "Disguise, forgery, intelligence and wilderness survival only (+10%). Wilderness Survival is a WILDERNESS skill in this catalog, so naming it here is cross-category - deliberate, and it works because the class grants Wilderness too." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], note: "Disguise, forg') > 0
   AND instr(markdown, 'val"], bonus: 10, note: "Disguise, forgery, intelligence and wilderness survival only (+10%). Wilderness Survival is a W') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+5%" }
',
         '      - { name: "Rogue", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Rogue", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%; literacy and languages +15%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%; literacy and languages +15%" }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "Literacy and languages +15%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+10%; literacy and languages +15%" }
') > 0
   AND instr(markdown, '}
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "Literacy and languages +15%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%" }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], note: "First aid or Holistic Medicine only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5, note: "First aid or Holistic Medicine only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], note: "First aid or Holistic Medicine only (+5%)" }') > 0
   AND instr(markdown, 'ame: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5, note: "First aid or Holistic Medicine only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+4%" }
',
         '      - { name: "Rogue", bonus: 4, note: "+4%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Rogue", note: "+4%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 4, note: "+4%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%" }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], note: "Intelligence and Escape only (+5%). The catalog''s escape row is Escape Artist." }
',
         '      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], bonus: 5, note: "Intelligence and Escape only (+5%). The catalog''s escape row is Escape Artist." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], note: "Intelligence and Escape only (+5%). The cat') > 0
   AND instr(markdown, '", "Escape Artist"], bonus: 5, note: "Intelligence and Escape only (+5%). The catalog''s escape row is Escape Artist." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+4%" }
',
         '      - { name: "Rogue", bonus: 4, note: "+4%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Rogue", note: "+4%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 4, note: "+4%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+15%" }
',
         '      - { name: "Technical", bonus: 15, note: "+15%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Technical", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+10%" }
',
         '      - { name: "Wilderness", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '      - { name: "Wilderness", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Intelligence"], note: "Intelligence only (+10%)" }
',
         '      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence only (+10%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence"], note: "Intelligence only (+10%)" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence only (+10%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, '      - { name: "Science", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%" }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-beguiler'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+4%" }
',
         '      - { name: "Rogue", bonus: 4, note: "+4%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-beguiler'
   AND instr(markdown, '      - { name: "Rogue", note: "+4%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 4, note: "+4%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-beguiler'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], note: "Basic and Automotive only (+5%)" }
',
         '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], note: "Basic and Automotive only (+5%)"') > 0
   AND instr(markdown, 'e: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "First aid only (+5%)" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%; THREE of the six must come from this category." }
',
         '      - { name: "Military", bonus: 10, note: "+10%; THREE of the six must come from this category." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Military", note: "+10%; THREE of the six must come from this category." }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%; THREE of the six must come from this category." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+5%" }
',
         '      - { name: "Rogue", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Rogue", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+5%; language and lore +15%" }
',
         '      - { name: "Technical", bonus: 5, note: "+5%; language and lore +15%" }
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "Language and lore +15%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, '      - { name: "Technical", note: "+5%; language and lore +15%" }
') > 0
   AND instr(markdown, 're +15%" }
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "Language and lore +15%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on language, literacy, writing, art and lore only - not applied by the picker." }
',
         '      - { name: "Technical", note: "+10% on language, literacy, writing, art and lore only; the next line carries it." }
      - { name: "Technical", only: ["Creative Writing"], only_prefix: ["Language", "Literacy", "Art", "Lore"], bonus: 10, note: "+10% on language, literacy, writing, art and lore only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'biomancer'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on language, literacy, writing, art and lore only - not applied by the picker."') > 0
   AND instr(markdown, ': ["Language", "Literacy", "Art", "Lore"], bonus: 10, note: "+10% on language, literacy, writing, art and lore only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5% on Paramedic only." }
',
         '      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, '      - { name: "Medical", note: "+5% on Paramedic only." }
') > 0
   AND instr(markdown, ': "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5% on Paramedic only." }
',
         '      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-spectral-hunter'
   AND instr(markdown, '      - { name: "Medical", note: "+5% on Paramedic only." }
') > 0
   AND instr(markdown, ': "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5% on Paramedic or First Aid only." }
',
         '      - { name: "Medical", note: "+5% on Paramedic or First Aid only." }
      - { name: "Medical", only: ["Paramedic", "First Aid"], bonus: 5, note: "+5% on Paramedic or First Aid only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'serpentoid'
   AND instr(markdown, '      - { name: "Medical", note: "+5% on Paramedic or First Aid only." }
') > 0
   AND instr(markdown, ' }
      - { name: "Medical", only: ["Paramedic", "First Aid"], bonus: 5, note: "+5% on Paramedic or First Aid only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5% on Paramedic only." }
',
         '      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'condoroid'
   AND instr(markdown, '      - { name: "Medical", note: "+5% on Paramedic only." }
') > 0
   AND instr(markdown, ': "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5% on Paramedic only." }
',
         '      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'falconoid'
   AND instr(markdown, '      - { name: "Medical", note: "+5% on Paramedic only." }
') > 0
   AND instr(markdown, ': "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid", "Paramedic"], note: "+5% on First Aid only." }
',
         '      - { name: "Medical", only: ["First Aid", "Paramedic"], note: "+5% on First Aid only." }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "+5% on First Aid only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'duelist'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid", "Paramedic"], note: "+5% on First Aid only." }
') > 0
   AND instr(markdown, ': "+5% on First Aid only." }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "+5% on First Aid only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "Any; +20% on lore, literacy, language or writing skills only, so no category bonus is stored." }
',
         '      - { name: "Technical", note: "Any; +20% on lore, literacy, language or writing skills only, which the next line carries." }
      - { name: "Technical", only: ["Creative Writing"], only_prefix: ["Lore", "Literacy", "Language"], bonus: 20, note: "+20% on lore, literacy, language or writing skills only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'african-priest'
   AND instr(markdown, '      - { name: "Technical", note: "Any; +20% on lore, literacy, language or writing skills only, so no category bonus i') > 0
   AND instr(markdown, 'prefix: ["Lore", "Literacy", "Language"], bonus: 20, note: "+20% on lore, literacy, language or writing skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gosai-assassin'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", except: ["Disguise"], note: "+10%. Two of the nine must come from here. Never Disguise." }
',
         '      - { name: "Espionage", except: ["Disguise"], bonus: 10, note: "+10%. Two of the nine must come from here. Never Disguise." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gosai-assassin'
   AND instr(markdown, '      - { name: "Espionage", except: ["Disguise"], note: "+10%. Two of the nine must come from here. Never Disguise." }
') > 0
   AND instr(markdown, 'ame: "Espionage", except: ["Disguise"], bonus: 10, note: "+10%. Two of the nine must come from here. Never Disguise." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%" }
',
         '      - { name: "Military", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gosai-assassin'
   AND instr(markdown, '      - { name: "Military", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+10%. Two of the nine must come from Rogue or Physical." }
',
         '      - { name: "Rogue", bonus: 10, note: "+10%. Two of the nine must come from Rogue or Physical." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gosai-assassin'
   AND instr(markdown, '      - { name: "Rogue", note: "+10%. Two of the nine must come from Rogue or Physical." }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 10, note: "+10%. Two of the nine must come from Rogue or Physical." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+15% on language and literacy skills only" }
',
         '      - { name: "Technical", note: "+15% on language and literacy skills only" }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on language and literacy skills only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gosai-assassin'
   AND instr(markdown, '      - { name: "Technical", note: "+15% on language and literacy skills only" }
') > 0
   AND instr(markdown, 'me: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on language and literacy skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
',
         '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
      - { name: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'bogatyr-hero-knight'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
') > 0
   AND instr(markdown, 'e: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
',
         '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
      - { name: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-explorer'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
') > 0
   AND instr(markdown, 'e: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "General (+10%) or Exotic only; the +10% is on General only - add it by hand." }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "General (+10%) or Exotic only; the +10% is on General only, and the next line carries it." }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "The +10% is on General only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'idie-fisherman'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "General (+10%) o') > 0
   AND instr(markdown, '." }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "The +10% is on General only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["Animal Husbandry", "First Aid", "Holistic Medicine"], note: "Holistic Medicine is +10% - add it by hand." }
',
         '      - { name: "Medical", only: ["Animal Husbandry", "First Aid", "Holistic Medicine"], note: "Holistic Medicine is +10%; the next line carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "Holistic Medicine is +10%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'idie-fisherman'
   AND instr(markdown, '      - { name: "Medical", only: ["Animal Husbandry", "First Aid", "Holistic Medicine"], note: "Holistic Medicine is +10') > 0
   AND instr(markdown, ' carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "Holistic Medicine is +10%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Pilot", only: ["Bicycling", "Boat: Motor, Race & Hydrofoil", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Water Scooters", "Water Skiing & Surfing"], note: "Boat: Motor & Hydrofoil +5%, Water Scooters +10%, Water Skiing & Surfing +14% - add them by hand." }
',
         '      - { name: "Pilot", only: ["Bicycling", "Boat: Motor, Race & Hydrofoil", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Water Scooters", "Water Skiing & Surfing"], note: "Boat: Motor & Hydrofoil +5%, Water Scooters +10%, Water Skiing & Surfing +14%; the next three lines carry them." }
      - { name: "Pilot", only: ["Boat: Motor, Race & Hydrofoil"], bonus: 5, note: "Boat: Motor & Hydrofoil +5%." }
      - { name: "Pilot", only: ["Water Scooters"], bonus: 10, note: "Water Scooters +10%." }
      - { name: "Pilot", only: ["Water Skiing & Surfing"], bonus: 14, note: "Water Skiing & Surfing +14%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'idie-fisherman'
   AND instr(markdown, '      - { name: "Pilot", only: ["Bicycling", "Boat: Motor, Race & Hydrofoil", "Hover Craft (ground)", "Hovercycles, Skyc') > 0
   AND instr(markdown, 's +10%." }
      - { name: "Pilot", only: ["Water Skiing & Surfing"], bonus: 14, note: "Water Skiing & Surfing +14%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on Lore skills only - add it by hand." }
',
         '      - { name: "Technical", note: "+10% on Lore skills only; the next line carries it." }
      - { name: "Technical", only_prefix: ["Lore"], bonus: 10, note: "+10% on Lore skills only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'idie-fisherman'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on Lore skills only - add it by hand." }
') > 0
   AND instr(markdown, ' line carries it." }
      - { name: "Technical", only_prefix: ["Lore"], bonus: 10, note: "+10% on Lore skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["Animal Husbandry", "Brewing: Medicinal", "First Aid", "Holistic Medicine"], note: "Brewing: Medicinal +10%, First Aid +5%, Holistic Medicine +10% - add them by hand." }
',
         '      - { name: "Medical", only: ["Animal Husbandry", "Brewing: Medicinal", "First Aid", "Holistic Medicine"], note: "Brewing: Medicinal +10%, First Aid +5%, Holistic Medicine +10%; the next two lines carry them." }
      - { name: "Medical", only: ["Brewing: Medicinal", "Holistic Medicine"], bonus: 10, note: "Brewing: Medicinal +10%, Holistic Medicine +10%." }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid +5%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'iktektumik-hunter-gatherer'
   AND instr(markdown, '      - { name: "Medical", only: ["Animal Husbandry", "Brewing: Medicinal", "First Aid", "Holistic Medicine"], note: "Br') > 0
   AND instr(markdown, 'nal +10%, Holistic Medicine +10%." }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid +5%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 5, note: "+10% on Lore, Mining, Recycling and Salvage; +5% on others - add the extra 5% by hand." }
',
         '      - { name: "Technical", bonus: 5, note: "+10% on Lore, Mining, Recycling and Salvage, which the next line carries; +5% on others." }
      - { name: "Technical", only: ["Mining", "Recycling", "Salvage"], only_prefix: ["Lore"], bonus: 10, note: "+10% on Lore, Mining, Recycling and Salvage." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'iktektumik-hunter-gatherer'
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+10% on Lore, Mining, Recycling and Salvage; +5% on others - add the extra') > 0
   AND instr(markdown, 'ing", "Recycling", "Salvage"], only_prefix: ["Lore"], bonus: 10, note: "+10% on Lore, Mining, Recycling and Salvage." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", bonus: 10, note: "+15% on Dowsing, Spelunking and Skin & Prepare Animal Hides; +10% on others - add the extra 5% by hand." }
',
         '      - { name: "Wilderness", bonus: 10, note: "+15% on Dowsing, Spelunking and Skin & Prepare Animal Hides, which the next line carries; +10% on others." }
      - { name: "Wilderness", only: ["Dowsing", "Spelunking", "Skin & Prepare Animal Hides"], bonus: 15, note: "+15% on Dowsing, Spelunking and Skin & Prepare Animal Hides." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'iktektumik-hunter-gatherer'
   AND instr(markdown, '      - { name: "Wilderness", bonus: 10, note: "+15% on Dowsing, Spelunking and Skin & Prepare Animal Hides; +10% on oth') > 0
   AND instr(markdown, 'ing", "Skin & Prepare Animal Hides"], bonus: 15, note: "+15% on Dowsing, Spelunking and Skin & Prepare Animal Hides." }
') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'part 1: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'necromancer-russian' AND length(markdown) = 11277)
    OR (class_id = 'born-mystic' AND length(markdown) = 11516)
    OR (class_id = 'russian-fire-sorcerer' AND length(markdown) = 8552)
    OR (class_id = 'russian-mystic-kuznya' AND length(markdown) = 10930)
    OR (class_id = 'old-believer' AND length(markdown) = 10946)
    OR (class_id = 'slayer-russian' AND length(markdown) = 10541)
    OR (class_id = 'gypsy-thief-russian' AND length(markdown) = 8937)
    OR (class_id = 'gypsy-wizard-thief-russian' AND length(markdown) = 9471)
    OR (class_id = 'gypsy-seer-russian' AND length(markdown) = 10524)
    OR (class_id = 'gypsy-fortune-teller' AND length(markdown) = 13495)
    OR (class_id = 'gifted-one-russian' AND length(markdown) = 11310)
    OR (class_id = 'layer-of-laws' AND length(markdown) = 10028);

SELECT 'part 2: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-beguiler' AND length(markdown) = 10007)
    OR (class_id = 'gypsy-enforcer' AND length(markdown) = 8064)
    OR (class_id = 'biomancer' AND length(markdown) = 17739)
    OR (class_id = 'arkhon' AND length(markdown) = 12580)
    OR (class_id = 'arkhon-spectral-hunter' AND length(markdown) = 11547)
    OR (class_id = 'serpentoid' AND length(markdown) = 11967)
    OR (class_id = 'condoroid' AND length(markdown) = 11120)
    OR (class_id = 'falconoid' AND length(markdown) = 10126)
    OR (class_id = 'duelist' AND length(markdown) = 12502)
    OR (class_id = 'african-priest' AND length(markdown) = 14834)
    OR (class_id = 'rifts-gosai-assassin' AND length(markdown) = 8901)
    OR (class_id = 'bogatyr-hero-knight' AND length(markdown) = 13821);

SELECT 'part 3: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'russian-explorer' AND length(markdown) = 13409)
    OR (class_id = 'idie-fisherman' AND length(markdown) = 10285)
    OR (class_id = 'iktektumik-hunter-gatherer' AND length(markdown) = 9475);

INSERT INTO data_script_runs (filename) VALUES ('~123-category-bonuses-stored-as-notes-part-2.sql');
