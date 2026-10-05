-- Related-skill category bonuses that were printed in a note and applied by
-- nothing, part 1 of 2.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~122-category-bonuses-stored-as-notes-part-1.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~122-category-bonuses-stored-as-notes-part-1.sql
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
-- THIS SCRIPT CHANGES PRODUCTION: 37 class rows.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%; two of the eight must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other six may also be Communications." }
',
         '      - { name: "Communications", bonus: 10, note: "+10%; two of the eight must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other six may also be Communications." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'knight'
   AND instr(markdown, '      - { name: "Communications", note: "+10%; two of the eight must come from here. Carried as occ_related_skills.minim') > 0
   AND instr(markdown, 'onus: 10, note: "+10%; two of the eight must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R1') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+10%" }
',
         '      - { name: "Espionage", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'knight'
   AND instr(markdown, '      - { name: "Espionage", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'knight'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%" }
',
         '      - { name: "Military", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'knight'
   AND instr(markdown, '      - { name: "Military", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'knight'
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
 WHERE class_id = 'knight'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
',
         '      - { name: "Communications", only: ["Sign Language"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", only: ["Sign Language"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Military - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Military - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%; two of the nine must come from Military or Espionage. ONE union floor across th') > 0
   AND instr(markdown, 'Espionage", bonus: 5, note: "+5%; two of the nine must come from Military or Espionage. ONE union floor across the pair ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
') > 0
   AND instr(markdown, '     - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["First Aid"], note: "+5%" }
',
         '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Espionage - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
',
         '      - { name: "Military", bonus: 10, note: "+10%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Espionage - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Military", note: "+10%; two of the nine must come from Military or Espionage. ONE union floor across th') > 0
   AND instr(markdown, 'litary", bonus: 10, note: "+10%; two of the nine must come from Military or Espionage. ONE union floor across the pair -') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+5%" }
',
         '      - { name: "Technical", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'soldier'
   AND instr(markdown, '      - { name: "Technical", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'squire'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%" }
',
         '      - { name: "Military", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'squire'
   AND instr(markdown, '      - { name: "Military", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'squire'
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
 WHERE class_id = 'squire'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%; two of the seven must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other five may also be Communications." }
',
         '      - { name: "Communications", bonus: 10, note: "+10%; two of the seven must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other five may also be Communications." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Communications", note: "+10%; two of the seven must come from here. Carried as occ_related_skills.minim') > 0
   AND instr(markdown, 'nus: 10, note: "+10%; two of the seven must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%" }
',
         '      - { name: "Military", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Military", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], note: "+10%" }
',
         '      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'palladin'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Detect Ambush", "Intelligence"], note: "Detect Ambush +5%, Intelligence +10%" }
',
         '      - { name: "Espionage", only: ["Detect Ambush"], bonus: 5, note: "Detect Ambush +5%." }
      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence +10%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Espionage", only: ["Detect Ambush", "Intelligence"], note: "Detect Ambush +5%, Intelligence +10%" }
') > 0
   AND instr(markdown, 'te: "Detect Ambush +5%." }
      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence +10%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
') > 0
   AND instr(markdown, '     - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", only: ["Cardsharp"], note: "Card Shark and Use/Recognize Poison (+6%) only; the catalog has no poison row." }
',
         '      - { name: "Rogue", only: ["Cardsharp"], bonus: 6, note: "Card Shark and Use/Recognize Poison (+6%) only; the catalog has no poison row." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Rogue", only: ["Cardsharp"], note: "Card Shark and Use/Recognize Poison (+6%) only; the catalog has no ') > 0
   AND instr(markdown, 'only: ["Cardsharp"], bonus: 6, note: "Card Shark and Use/Recognize Poison (+6%) only; the catalog has no poison row." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
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
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+10%" }
',
         '      - { name: "Wilderness", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'ranger'
   AND instr(markdown, '      - { name: "Wilderness", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
',
         '      - { name: "Communications", only: ["Sign Language"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", only: ["Sign Language"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
',
         '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
') > 0
   AND instr(markdown, '     - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+5%" }
',
         '      - { name: "Military", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Military", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Military", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+4%, on Streetwise only" }
',
         '      - { name: "Rogue", note: "+4%, on Streetwise only" }
      - { name: "Rogue", only: ["Streetwise"], bonus: 4, note: "+4% on Streetwise only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Rogue", note: "+4%, on Streetwise only" }
') > 0
   AND instr(markdown, ' "+4%, on Streetwise only" }
      - { name: "Rogue", only: ["Streetwise"], bonus: 4, note: "+4% on Streetwise only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on language, literacy and lore only" }
',
         '      - { name: "Technical", note: "+10% on language, literacy and lore only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on language, literacy and lore only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on language, literacy and lore only" }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on language, literacy and lore only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+10%" }
',
         '      - { name: "Rogue", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'thief'
   AND instr(markdown, '      - { name: "Rogue", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'assassin'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+10%, and +15% on Disguise. Two of the nine must come from here." }
',
         '      - { name: "Espionage", bonus: 10, note: "+10%, and +15% on Disguise. Two of the nine must come from here." }
      - { name: "Espionage", only: ["Disguise"], bonus: 15, note: "+15% on Disguise." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'assassin'
   AND instr(markdown, '      - { name: "Espionage", note: "+10%, and +15% on Disguise. Two of the nine must come from here." }
') > 0
   AND instr(markdown, 'he nine must come from here." }
      - { name: "Espionage", only: ["Disguise"], bonus: 15, note: "+15% on Disguise." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", note: "+10%" }
',
         '      - { name: "Military", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'assassin'
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
 WHERE class_id = 'assassin'
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
 WHERE class_id = 'assassin'
   AND instr(markdown, '      - { name: "Technical", note: "+15% on language and literacy skills only" }
') > 0
   AND instr(markdown, 'me: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on language and literacy skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'merchant'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'merchant'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'merchant'
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
 WHERE class_id = 'noble'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], note: "+10%" }
',
         '      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'noble'
   AND instr(markdown, '      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+5%" }
',
         '      - { name: "Technical", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'noble'
   AND instr(markdown, '      - { name: "Technical", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'scholar'
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
 WHERE class_id = 'scholar'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Forgery"], note: "+5%" }
',
         '      - { name: "Espionage", only: ["Forgery"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'scholar'
   AND instr(markdown, '      - { name: "Espionage", only: ["Forgery"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", only: ["Forgery"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Heraldry"], note: "+10%" }
',
         '      - { name: "Military", only: ["Heraldry"], bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'scholar'
   AND instr(markdown, '      - { name: "Military", only: ["Heraldry"], note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", only: ["Heraldry"], bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'scholar'
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
 WHERE class_id = 'scholar'
   AND instr(markdown, '      - { name: "Technical", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+10%" }
',
         '      - { name: "Communications", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, '      - { name: "Communications", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Interrogation Techniques", "Surveillance"], note: "Interrogation Techniques +5%" }
',
         '      - { name: "Military", only: ["Interrogation Techniques", "Surveillance"], note: "Interrogation Techniques +5%" }
      - { name: "Military", only: ["Interrogation Techniques"], bonus: 5, note: "Interrogation Techniques +5%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, '      - { name: "Military", only: ["Interrogation Techniques", "Surveillance"], note: "Interrogation Techniques +5%" }
') > 0
   AND instr(markdown, '5%" }
      - { name: "Military", only: ["Interrogation Techniques"], bonus: 5, note: "Interrogation Techniques +5%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
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
 WHERE class_id = 'summoner'
   AND instr(markdown, '      - { name: "Technical", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'wizard'
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
 WHERE class_id = 'wizard'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Forgery", "Escape Artist", "Intelligence"], note: "+5%" }
',
         '      - { name: "Espionage", only: ["Forgery", "Escape Artist", "Intelligence"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'wizard'
   AND instr(markdown, '      - { name: "Espionage", only: ["Forgery", "Escape Artist", "Intelligence"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", only: ["Forgery", "Escape Artist", "Intelligence"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'wizard'
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
 WHERE class_id = 'wizard'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+15%" }
',
         '      - { name: "Medical", bonus: 15, note: "+15%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, '      - { name: "Medical", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Camouflage", "Falconry"], note: "Both +10%" }
',
         '      - { name: "Military", only: ["Camouflage", "Falconry"], bonus: 10, note: "Both +10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, '      - { name: "Military", only: ["Camouflage", "Falconry"], note: "Both +10%" }
') > 0
   AND instr(markdown, '      - { name: "Military", only: ["Camouflage", "Falconry"], bonus: 10, note: "Both +10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+15%" }
',
         '      - { name: "Science", bonus: 15, note: "+15%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, '      - { name: "Science", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+10%" }
',
         '      - { name: "Wilderness", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'druid'
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
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["Brewing", "First Aid"], note: "+10%" }
',
         '      - { name: "Medical", only: ["Brewing", "First Aid"], bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, '      - { name: "Medical", only: ["Brewing", "First Aid"], note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", only: ["Brewing", "First Aid"], bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], note: "+5%" }
',
         '      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, '      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+5%" }
',
         '      - { name: "Rogue", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, '      - { name: "Rogue", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness'
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
 WHERE class_id = 'priest-of-darkness'
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
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+15%" }
',
         '      - { name: "Domestic", bonus: 15, note: "+15%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, '      - { name: "Domestic", note: "+15%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 15, note: "+15%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5%" }
',
         '      - { name: "Medical", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, '      - { name: "Medical", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%" }
',
         '      - { name: "Technical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, '      - { name: "Technical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Wilderness - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Wilderness - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across th') > 0
   AND instr(markdown, 'estic", bonus: 10, note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", note: "+5%" }
',
         '      - { name: "Espionage", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Espionage", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Espionage", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+5%" }
',
         '      - { name: "Medical", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Medical", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+6%" }
',
         '      - { name: "Rogue", bonus: 6, note: "+6%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Rogue", note: "+6%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 6, note: "+6%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on lore and language skills only" }
',
         '      - { name: "Technical", note: "+10% on lore and language skills only" }
      - { name: "Technical", only_prefix: ["Lore", "Language"], bonus: 10, note: "+10% on lore and language skills only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on lore and language skills only" }
') > 0
   AND instr(markdown, '  - { name: "Technical", only_prefix: ["Lore", "Language"], bonus: 10, note: "+10% on lore and language skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Wilderness", note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Domestic - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
',
         '      - { name: "Wilderness", bonus: 5, note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Domestic - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across t') > 0
   AND instr(markdown, 'ilderness", bonus: 5, note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, '      - { name: "Communications", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Communications", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], note: "Intelligence +10%, Escape Artist +5%" }
',
         '      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence +10%." }
      - { name: "Espionage", only: ["Escape Artist"], bonus: 5, note: "Escape Artist +5%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, '      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], note: "Intelligence +10%, Escape Artist +5%" }
') > 0
   AND instr(markdown, 'te: "Intelligence +10%." }
      - { name: "Espionage", only: ["Escape Artist"], bonus: 5, note: "Escape Artist +5%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
',
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-healer'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+10%" }
',
         '      - { name: "Medical", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-healer'
   AND instr(markdown, '      - { name: "Medical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-healer'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
',
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-healer'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+5%" }
',
         '      - { name: "Science", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, '      - { name: "Science", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
',
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10% on Mathematics skills only" }
',
         '      - { name: "Science", note: "+10% on Mathematics skills only" }
      - { name: "Science", only_prefix: ["Mathematics"], bonus: 10, note: "+10% on Mathematics skills only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psychic-sensitive'
   AND instr(markdown, '      - { name: "Science", note: "+10% on Mathematics skills only" }
') > 0
   AND instr(markdown, ' only" }
      - { name: "Science", only_prefix: ["Mathematics"], bonus: 10, note: "+10% on Mathematics skills only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
',
         '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'psychic-sensitive'
   AND instr(markdown, '      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+10%" }
',
         '      - { name: "Domestic", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'vagabond-peasant'
   AND instr(markdown, '      - { name: "Domestic", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+2%" }
',
         '      - { name: "Rogue", bonus: 2, note: "+2%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'vagabond-peasant'
   AND instr(markdown, '      - { name: "Rogue", note: "+2%" }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 2, note: "+2%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+5%" }
',
         '      - { name: "Technical", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'vagabond-peasant'
   AND instr(markdown, '      - { name: "Technical", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on languages - the picker carries the +10% and the extra 5% on a language pick is prose." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "+15% on languages." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on languages - the picker carries the +10% and the extra 5') > 0
   AND instr(markdown, 'e next line carries." }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "+15% on languages." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on literacy and languages - the picker carries the +10% and the extra 5% on a literacy or language pick is prose." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on literacy and languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on literacy and languages." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%, and +15% on literacy and languages - the picker carries the +10% an') > 0
   AND instr(markdown, '     - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on literacy and languages." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a bonus, at +8%." }
',
         '      - { name: "Rogue", note: "Any Rogue skill may be taken; the bonus is on the next line." }
      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a bonus, at +8%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'bounty-hunter'
   AND instr(markdown, '      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a ') > 0
   AND instr(markdown, ' on the next line." }
      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Military", bonus: 10, note: "+10%, and +15% to the trap and demolitions skills." }
',
         '      - { name: "Military", bonus: 10, note: "+10%, and +15% to the trap and demolitions skills." }
      - { name: "Military", only_prefix: ["Demolitions", "Trap"], bonus: 15, note: "+15% to the trap and demolitions skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, '      - { name: "Military", bonus: 10, note: "+10%, and +15% to the trap and demolitions skills." }
') > 0
   AND instr(markdown, '{ name: "Military", only_prefix: ["Demolitions", "Trap"], bonus: 15, note: "+15% to the trap and demolitions skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a bonus, at +8%." }
',
         '      - { name: "Rogue", note: "Any Rogue skill may be taken; the bonus is on the next line." }
      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a bonus, at +8%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, '      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries a ') > 0
   AND instr(markdown, '}
      - { name: "Rogue", only: ["Streetwise"], bonus: 8, note: "Any Rogue skill may be taken; only Streetwise carries ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", bonus: 10, note: "Any Rogue skill; the +10% is printed against Cardsharp, Palming and Streetwise only." }
',
         '      - { name: "Rogue", note: "Any Rogue skill; the +10% is printed against Cardsharp, Palming and Streetwise only." }
      - { name: "Rogue", only: ["Cardsharp", "Palming", "Streetwise"], bonus: 10, note: "The +10% is printed against Cardsharp, Palming and Streetwise only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'saddle-tramp'
   AND instr(markdown, '      - { name: "Rogue", bonus: 10, note: "Any Rogue skill; the +10% is printed against Cardsharp, Palming and Streetwis') > 0
   AND instr(markdown, 'rp", "Palming", "Streetwise"], bonus: 10, note: "The +10% is printed against Cardsharp, Palming and Streetwise only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+10%, and Prospecting is +15%." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%, and Prospecting is +15%." }
      - { name: "Technical", only: ["Prospecting"], bonus: 15, note: "Prospecting is +15%." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'saddle-tramp'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%, and Prospecting is +15%." }
') > 0
   AND instr(markdown, 'd Prospecting is +15%." }
      - { name: "Technical", only: ["Prospecting"], bonus: 15, note: "Prospecting is +15%." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "The +10% is printed against Art, Language and Lore skills." }
',
         '      - { name: "Technical", note: "The +10% is printed against Art, Language and Lore skills." }
      - { name: "Technical", only_prefix: ["Art", "Language", "Lore"], bonus: 10, note: "The +10% is printed against Art, Language and Lore skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'cowboy'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "The +10% is printed against Art, Language and Lore skills." }
') > 0
   AND instr(markdown, 'ly_prefix: ["Art", "Language", "Lore"], bonus: 10, note: "The +10% is printed against Art, Language and Lore skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 5, note: "+5%, and +10% to language, lore and history skills." }
',
         '      - { name: "Technical", bonus: 5, note: "+5%, and +10% to language, lore and history skills." }
      - { name: "Technical", only_prefix: ["Language", "Lore", "History"], bonus: 10, note: "+10% to language, lore and history skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'sheriff-lawman'
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+5%, and +10% to language, lore and history skills." }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Language", "Lore", "History"], bonus: 10, note: "+10% to language, lore and history skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, lore and history skills." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, lore and history skills." }
      - { name: "Technical", only_prefix: ["Language", "Lore", "History"], bonus: 15, note: "+15% to language, lore and history skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'sheriffs-deputy'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, lore and history skills." }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Language", "Lore", "History"], bonus: 15, note: "+15% to language, lore and history skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, history and lore skills." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, history and lore skills." }
      - { name: "Technical", only_prefix: ["Language", "Lore", "History"], bonus: 15, note: "+15% to language, history and lore skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'preacher'
   AND instr(markdown, '      - { name: "Technical", bonus: 10, note: "+10%, and +15% to language, history and lore skills." }
') > 0
   AND instr(markdown, 'chnical", only_prefix: ["Language", "Lore", "History"], bonus: 15, note: "+15% to language, history and lore skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", bonus: 5, note: "+5%, and +15% to Sing and Play Musical Instrument." }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%, and +15% to Sing and Play Musical Instrument." }
      - { name: "Domestic", only: ["Play Musical Instrument"], bonus: 15, note: "+15% to Play Musical Instrument. Sing takes the same +15% in the book and is filed under Communications in this catalog; add it by hand." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'professional-gambler'
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%, and +15% to Sing and Play Musical Instrument." }
') > 0
   AND instr(markdown, ' Instrument. Sing takes the same +15% in the book and is filed under Communications in this catalog; add it by hand." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", except: ["Seduction"], bonus: 10, note: "Any Rogue skill except Seduction; the +10% is printed against Pick Pockets and Cardsharp only." }
',
         '      - { name: "Rogue", except: ["Seduction"], note: "Any Rogue skill except Seduction; the +10% is printed against Pick Pockets and Cardsharp only." }
      - { name: "Rogue", only: ["Cardsharp"], bonus: 10, note: "The +10% is printed against Pick Pockets and Cardsharp only. Pick Pockets is an Espionage skill in this catalog; add its +10% by hand." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, '      - { name: "Rogue", except: ["Seduction"], bonus: 10, note: "Any Rogue skill except Seduction; the +10% is printed ') > 0
   AND instr(markdown, 'd against Pick Pockets and Cardsharp only. Pick Pockets is an Espionage skill in this catalog; add its +10% by hand." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", bonus: 5, note: "+5%, and +15% to Language and Lore skills." }
',
         '      - { name: "Technical", bonus: 5, note: "+5%, and +15% to Language and Lore skills." }
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "+15% to Language and Lore skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'saloon-girl'
   AND instr(markdown, '      - { name: "Technical", bonus: 5, note: "+5%, and +15% to Language and Lore skills." }
') > 0
   AND instr(markdown, '
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "+15% to Language and Lore skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", only: ["Holistic Medicine", "Brewing"], note: "The book prints +10% against Holistic Medicine only; one category bonus cannot say that, so neither takes it." }
',
         '      - { name: "Medical", only: ["Holistic Medicine", "Brewing"], note: "The book prints +10% against Holistic Medicine only; the next line carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "+10% against Holistic Medicine only." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'totem-warrior'
   AND instr(markdown, '      - { name: "Medical", only: ["Holistic Medicine", "Brewing"], note: "The book prints +10% against Holistic Medicine') > 0
   AND instr(markdown, 't." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "+10% against Holistic Medicine only." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Domestic", note: "+5%" }
',
         '      - { name: "Domestic", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '      - { name: "Domestic", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5, note: "+5%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Medical", note: "+20%" }
',
         '      - { name: "Medical", bonus: 20, note: "+20%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '      - { name: "Medical", note: "+20%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 20, note: "+20%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '      - { name: "Science", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Science", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Technical", note: "+10%; +15% to language and lore skills." }
',
         '      - { name: "Technical", bonus: 10, note: "+10%; +15% to language and lore skills." }
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "+15% to language and lore skills." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '      - { name: "Technical", note: "+10%; +15% to language and lore skills." }
') > 0
   AND instr(markdown, '
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "+15% to language and lore skills." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Communications", note: "+5%" }
',
         '      - { name: "Communications", bonus: 5, note: "+5%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'hidden-witch'
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
 WHERE class_id = 'hidden-witch'
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
 WHERE class_id = 'hidden-witch'
   AND instr(markdown, '      - { name: "Medical", note: "+10%" }
') > 0
   AND instr(markdown, '      - { name: "Medical", bonus: 10, note: "+10%" }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Rogue", note: "+5%; THREE of the nine must come from this category." }
',
         '      - { name: "Rogue", bonus: 5, note: "+5%; THREE of the nine must come from this category." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'hidden-witch'
   AND instr(markdown, '      - { name: "Rogue", note: "+5%; THREE of the nine must come from this category." }
') > 0
   AND instr(markdown, '      - { name: "Rogue", bonus: 5, note: "+5%; THREE of the nine must come from this category." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - { name: "Science", note: "+10%" }
',
         '      - { name: "Science", bonus: 10, note: "+10%" }
'),
       updated_at = datetime('now')
 WHERE class_id = 'hidden-witch'
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
 WHERE class_id = 'hidden-witch'
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
 WHERE class_id = 'hidden-witch'
   AND instr(markdown, '      - { name: "Wilderness", note: "+5%" }
') > 0
   AND instr(markdown, '      - { name: "Wilderness", bonus: 5, note: "+5%" }
') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'part 1: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'knight' AND length(markdown) = 6280)
    OR (class_id = 'soldier' AND length(markdown) = 9140)
    OR (class_id = 'squire' AND length(markdown) = 6494)
    OR (class_id = 'palladin' AND length(markdown) = 11030)
    OR (class_id = 'ranger' AND length(markdown) = 8441)
    OR (class_id = 'mercenary-fighter' AND length(markdown) = 9317)
    OR (class_id = 'thief' AND length(markdown) = 9440)
    OR (class_id = 'assassin' AND length(markdown) = 10292)
    OR (class_id = 'merchant' AND length(markdown) = 6174)
    OR (class_id = 'noble' AND length(markdown) = 7064)
    OR (class_id = 'scholar' AND length(markdown) = 6598)
    OR (class_id = 'summoner' AND length(markdown) = 11171);

SELECT 'part 2: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'wizard' AND length(markdown) = 12125)
    OR (class_id = 'druid' AND length(markdown) = 11264)
    OR (class_id = 'priest-of-darkness' AND length(markdown) = 8879)
    OR (class_id = 'warrior-monk' AND length(markdown) = 10047)
    OR (class_id = 'witch' AND length(markdown) = 17206)
    OR (class_id = 'mind-mage' AND length(markdown) = 11644)
    OR (class_id = 'psi-healer' AND length(markdown) = 9044)
    OR (class_id = 'psi-mystic' AND length(markdown) = 8757)
    OR (class_id = 'psychic-sensitive' AND length(markdown) = 8865)
    OR (class_id = 'vagabond-peasant' AND length(markdown) = 8147)
    OR (class_id = 'gypsy-thief' AND length(markdown) = 12569)
    OR (class_id = 'gypsy-wizard-thief' AND length(markdown) = 12862);

SELECT 'part 3: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'bounty-hunter' AND length(markdown) = 8568)
    OR (class_id = 'gunfighter' AND length(markdown) = 12387)
    OR (class_id = 'saddle-tramp' AND length(markdown) = 6641)
    OR (class_id = 'cowboy' AND length(markdown) = 7426)
    OR (class_id = 'sheriff-lawman' AND length(markdown) = 11424)
    OR (class_id = 'sheriffs-deputy' AND length(markdown) = 8527)
    OR (class_id = 'preacher' AND length(markdown) = 11442)
    OR (class_id = 'professional-gambler' AND length(markdown) = 11264)
    OR (class_id = 'saloon-bum' AND length(markdown) = 8968)
    OR (class_id = 'saloon-girl' AND length(markdown) = 7732)
    OR (class_id = 'totem-warrior' AND length(markdown) = 11069)
    OR (class_id = 'night-witch' AND length(markdown) = 11707);

SELECT 'part 4: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'hidden-witch' AND length(markdown) = 10007);

INSERT INTO data_script_runs (filename) VALUES ('~122-category-bonuses-stored-as-notes-part-1.sql');
