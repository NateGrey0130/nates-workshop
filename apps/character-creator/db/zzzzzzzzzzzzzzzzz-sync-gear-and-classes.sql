-- Eight gear categories and eight class markdowns that production and a
-- rebuild disagree about, reconciled in both directions.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql
--
-- Found 2026-09-24 by `repo-vs-live.mjs --offenders`, the last sixteen rows it
-- reported. Every one is an existing script whose effect one side lost, and
-- WHICH side lost it depends on the case, so each statement below is guarded
-- on the wrong side's exact text and is a no-op on the other.
--
-- GEAR. zzz-gear-tidy-3-categories.sql files every uncategorised row as
-- 'gear'. It ran live on 2026-08-25, before the Nightbane class imports of
-- 2026-09-16 created eight stubs with no category, so production still has
-- them NULL - the thin detail line that script existed to remove. A rebuild
-- runs it after them ('a' < 'z') and files all eight as gear, which is right
-- for seven and wrong for darkblade-scimitar-nb: Nightbane prints Darkblades
-- only on the Weapons line of the Hunter and Hound entries (printed 163-166),
-- and every other scimitar in the catalog, scimitar-nb included, is 'weapon'.
--
-- CLASSES WHERE PRODUCTION IS RIGHT, and a rebuild loses a later fix:
--   monk, demon-goblin   zzzzz-retro-r10-mos-choice-groups.sql sorts BEFORE
--                        zzzzz-retro-r2-mos-packages.sql ('1' < '2'), so its
--                        anchors are not there yet and the R10 W.P. choice
--                        groups never land.
--   colonist (note)      fix-labelled-saves.sql matches the doubled
--                        apostrophe the import stored; fix-doubled-apostrophes
--                        .sql sorts first ('d' < 'l') and repairs it, so the
--                        match fails and the stale F7 sentence stays.
--   imperial-legionnaire fix-class-skill-names-to-rue.sql renames the quoted
--                        string "W.P. Heavy" everywhere, including the note
--                        that QUOTES the book's "W.P. Heavy" to explain why it
--                        is a choice - which then reads as W.P. Heavy Military
--                        Weapons being a choice between itself and another.
--
-- CLASSES WHERE THE REPO IS RIGHT, and production missed it:
--   colonist (skill)     fix-class-skill-names-to-rue.sql renamed Identify
--   sea-inquisitor       Plants & Fruits, and fix-category-gear-rows.sql turned
--   fq-deep-intel-agent  "light-mdc-body-armor" into the choice 29 other
--   (back-pack)          classes carry, and merge-backpack-duplicate.sql
--                        retired back-pack - all before these three classes
--                        were imported live, so live kept the old strings
--                        (they resolve through redirects, which is why nothing
--                        broke). No character holds the old skill name.
--   fq-deep-intel-agent  fix-fq-deep-intel-agent-pb-cap.sql's replace is
--   (PB cap)             unguarded and ran twice live: the key is there twice.
--   wizard,              production holds an earlier draft of one
--   hu-super-sleuth      extraction_notes line than the file that merged.
--
-- The class statements were generated from both sides' markdown and simulated
-- before writing: each replaces a block unique in the wrong text and absent
-- from the right one, and applying them all to either side yields the same
-- markdown. Sorts after every file in the directory on the day it was written.

UPDATE gear SET category = 'gear'
 WHERE category IS NULL
   AND slug IN ('travelling-clothes-nb', 'mirror-nb', 'portable-radio-nb', 'portable-cd-player-nb',
                'walking-stick-nb', 'small-library-nb', 'magnifying-glass-nb');

UPDATE gear SET category = 'weapon'
 WHERE slug = 'darkblade-scimitar-nb'
   AND (category IS NULL OR category = 'gear');

-- wizard: production takes the repo text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - "Pay for hired work runs 50-150 gold for the simplest task to 3000-12,000 for dangerous assignments, roughly a long bowman''s salary below 5th level and an officer''s at 5th and above. Armies like to use wizards and warlocks as artillery, though most wizards find military life too restrictive and many men of arms do not trust them."' || char(10) || 'extraction_notes: "The six common knowledge spells are five spell rows plus the Enchanted Cauldron, which is a ritual with no P.P.E. cost or spell level and is recorded as a special ability instead. Cloud of Slumber resolves to Air: Cloud of Slumber - the only Cloud of Slumber the book prints is the first-level Air warlock spell at 4 P.P.E., which is what the wizard is being given. Decipher Magic is added to the catalog by this batch. The six extra picks - two from spell level one, two from two, one from three, one from four - are stated as spells_starting_groups, with spells_starting as their total. They were four level-1 spells_schedule entries until this fix, and in that shape they granted NOTHING: perLevelGrants skips every entry at or below the level it starts from, and creation reads the *_starting keys, so the six were printed here and reached no character. The note that stood in this place said spells_starting cannot band picks by spell level - true when the wizard was imported, false since class audit S1 gave the starting pick groups. The seventh pick is the second half of that same book paragraph: one new spell at each level of experience, starting at level one. The class holds the ongoing rule as spells_per_level and perLevelGrants begins at level two, so the level-one instance is stated as the fifth starting group - one spell from spell level one - and spells_starting is 7. Taken as transcription rather than interpretation: this book distinguishes starting at level one from starting at level two within one chapter, and the Mind Mage two hundred pages later says level two for exactly this shape of rule. Levels 1 to 15 now yield fifteen of these and not fourteen, with no double count, because the per-level grant still begins at two. Large Axes has no catalog row, so the weapon-proficiency exclusion names only Lance and Pole Arm."' || char(10) || '---',
         '  - "Pay for hired work runs 50-150 gold for the simplest task to 3000-12,000 for dangerous assignments, roughly a long bowman''s salary below 5th level and an officer''s at 5th and above. Armies like to use wizards and warlocks as artillery, though most wizards find military life too restrictive and many men of arms do not trust them."' || char(10) || 'extraction_notes: "The six common knowledge spells are five spell rows plus the Enchanted Cauldron, which is a ritual with no P.P.E. cost or spell level and is recorded as a special ability instead. Cloud of Slumber resolves to Air: Cloud of Slumber - the only Cloud of Slumber the book prints is the first-level Air warlock spell at 4 P.P.E., which is what the wizard is being given. Decipher Magic is added to the catalog by this batch. The six extra picks - two from spell level one, two from two, one from three, one from four - are stated as spells_starting_groups, with spells_starting as their total. They were four level-1 spells_schedule entries until this fix, and in that shape they granted NOTHING: perLevelGrants skips every entry at or below the level it starts from, and creation reads the *_starting keys, so the six were printed here and reached no character. The note that stood in this place said spells_starting cannot band picks by spell level - true when the wizard was imported, false since class audit S1 gave the starting pick groups. The seventh pick is the second half of that same book paragraph: one new spell at each level of experience, starting at level one. The class holds the ongoing rule as spells_per_level and perLevelGrants begins at level two, so the level-one instance is stated as a fifth starting group - one spell from spell level one - and spells_starting is 7. Taken as transcription rather than interpretation: this book distinguishes starting at level one from starting at level two, and the Mind Mage says level two for exactly this shape of rule. Levels 1 to 15 now yield fifteen of these and not fourteen, with no double count, because the per-level grant still begins at two - 21 picks over a career, which is the paragraph''s 6 + 15. The groups carry no note fields: a group note renders as a restriction the catalog cannot check, and a spell_levels gate is exactly what it can. Large Axes has no catalog row, so the weapon-proficiency exclusion names only Lance and Pole Arm."' || char(10) || '---'),
       updated_at = datetime('now')
 WHERE class_id = 'wizard'
   AND instr(markdown, '  - "Pay for hired work runs 50-150 gold for the simplest task to 3000-12,000 for dangerous assignments, roughly a long bowman''s salary below 5th level and an officer''s at 5th and above. Armies like to use wizards and warlocks as artillery, though most wizards find military life too restrictive and many men of arms do not trust them."' || char(10) || 'extraction_notes: "The six common knowledge spells are five spell rows plus the Enchanted Cauldron, which is a ritual with no P.P.E. cost or spell level and is recorded as a special ability instead. Cloud of Slumber resolves to Air: Cloud of Slumber - the only Cloud of Slumber the book prints is the first-level Air warlock spell at 4 P.P.E., which is what the wizard is being given. Decipher Magic is added to the catalog by this batch. The six extra picks - two from spell level one, two from two, one from three, one from four - are stated as spells_starting_groups, with spells_starting as their total. They were four level-1 spells_schedule entries until this fix, and in that shape they granted NOTHING: perLevelGrants skips every entry at or below the level it starts from, and creation reads the *_starting keys, so the six were printed here and reached no character. The note that stood in this place said spells_starting cannot band picks by spell level - true when the wizard was imported, false since class audit S1 gave the starting pick groups. The seventh pick is the second half of that same book paragraph: one new spell at each level of experience, starting at level one. The class holds the ongoing rule as spells_per_level and perLevelGrants begins at level two, so the level-one instance is stated as the fifth starting group - one spell from spell level one - and spells_starting is 7. Taken as transcription rather than interpretation: this book distinguishes starting at level one from starting at level two within one chapter, and the Mind Mage two hundred pages later says level two for exactly this shape of rule. Levels 1 to 15 now yield fifteen of these and not fourteen, with no double count, because the per-level grant still begins at two. Large Axes has no catalog row, so the weapon-proficiency exclusion names only Lance and Pole Arm."' || char(10) || '---') > 0;

-- hu-super-sleuth: production takes the repo text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'restrictions: ["Two skill programs, excluding Espionage and Military, at +15%", "The eight secondary skills get no bonuses at all - sorry"]' || char(10) || 'extraction_notes: "THE I.Q. IS A FLOOR, NOT A BONUS. Printed 160 says to increase the I.Q. to 14, ''higher is better if you rolled it'', which is `attribute_minimums` - the same shape the Hardware character''s I.Q. 9 takes. THE TWO ADDITIONAL LANGUAGES ARE A PICK, NOT A GRANT. `Language: Other` and `Literacy: Other` are PLACEHOLDER rows a character names when he takes them, and granting one outright leaves him holding a skill called, literally, `Literacy: Other` - BOOK-INGEST-AUDIT F34. A fixed `Language: Other` is legitimate only where the book NAMES the tongue; this one does not. THE PERCENTAGE IS A `bonus`, NEVER A `base`: the row resolves off its own 50% +5%/level and a base would FREEZE it there for fifteen levels, so the book''s 96% is stored as +46. THE PILOT CHOICE STARTS AT ITS CATALOG BASE. Printed 161 gives 96% for automobile or motorcycle; both rows are 60 in the catalog, and a `from` list cannot fix a percentage per pick - only a named entry can, and naming one would decide the player''s choice. THE SEVEN-FROM-FOURTEEN LIST LOSES ITS PER-SKILL BONUSES, as the Hunter''s and the Stage Magician''s do. `Criminal Sciences/Forensics` is the catalog''s `Forensics`, and `Chemistry: Analytical` its `Chemistry - Analytical` - with an EM DASH, which is why it is spliced through char() in the data script. THE EQUIPMENT BUDGET IS NOT IMPORTED: $8,000 to $20,000 on printed 161, plus a crime lab the character has already spent 2D4x10,000 on. Survey D7."' || char(10) || '---',
         'restrictions: ["Two skill programs, excluding Espionage and Military, at +15%", "The eight secondary skills get no bonuses at all - sorry"]' || char(10) || 'extraction_notes: "THE I.Q. IS A FLOOR, NOT A BONUS. Printed 160 says to increase the I.Q. to 14, ''higher is better if you rolled it'', which is `attribute_minimums` - the same shape the Hardware character''s I.Q. 9 takes. THE TWO ADDITIONAL LANGUAGES ARE A PICK, NOT A GRANT. `Language: Other` and `Literacy: Other` are PLACEHOLDER rows a character names when he takes them, and granting one outright leaves him holding a skill called, literally, `Literacy: Other` - BOOK-INGEST-AUDIT F34, which regression.mjs caught on the first draft of this class. A fixed `Language: Other` is legitimate only where the book NAMES the tongue; this one does not, so both are choice groups of two from the repeatable row. THE PERCENTAGE IS A `bonus`, NEVER A `base`: a language resolves off the Other row''s own 50% +5%/level, and a base would FREEZE it there for fifteen levels - the Cyber-Doc''s mistake, which regression.mjs pins. So the book''s 96% is stored as +46. THE PILOT CHOICE STARTS AT ITS CATALOG BASE. Printed 161 gives 96% for automobile or motorcycle; both rows are 60 in the catalog, and a `from` list cannot fix a percentage per pick - only a named entry can, and naming one would decide the player''s choice. THE SEVEN-FROM-FOURTEEN LIST LOSES ITS PER-SKILL BONUSES, as the Hunter''s and the Stage Magician''s do. `Criminal Sciences/Forensics` is the catalog''s `Forensics`, and `Chemistry: Analytical` its `Chemistry - Analytical` - with an EM DASH, which is why it is spliced through char() in the data script. THE EQUIPMENT BUDGET IS NOT IMPORTED: $8,000 to $20,000 on printed 161, plus a crime lab the character has already spent 2D4x10,000 on. Survey D7."' || char(10) || '---'),
       updated_at = datetime('now')
 WHERE class_id = 'hu-super-sleuth'
   AND instr(markdown, 'restrictions: ["Two skill programs, excluding Espionage and Military, at +15%", "The eight secondary skills get no bonuses at all - sorry"]' || char(10) || 'extraction_notes: "THE I.Q. IS A FLOOR, NOT A BONUS. Printed 160 says to increase the I.Q. to 14, ''higher is better if you rolled it'', which is `attribute_minimums` - the same shape the Hardware character''s I.Q. 9 takes. THE TWO ADDITIONAL LANGUAGES ARE A PICK, NOT A GRANT. `Language: Other` and `Literacy: Other` are PLACEHOLDER rows a character names when he takes them, and granting one outright leaves him holding a skill called, literally, `Literacy: Other` - BOOK-INGEST-AUDIT F34. A fixed `Language: Other` is legitimate only where the book NAMES the tongue; this one does not. THE PERCENTAGE IS A `bonus`, NEVER A `base`: the row resolves off its own 50% +5%/level and a base would FREEZE it there for fifteen levels, so the book''s 96% is stored as +46. THE PILOT CHOICE STARTS AT ITS CATALOG BASE. Printed 161 gives 96% for automobile or motorcycle; both rows are 60 in the catalog, and a `from` list cannot fix a percentage per pick - only a named entry can, and naming one would decide the player''s choice. THE SEVEN-FROM-FOURTEEN LIST LOSES ITS PER-SKILL BONUSES, as the Hunter''s and the Stage Magician''s do. `Criminal Sciences/Forensics` is the catalog''s `Forensics`, and `Chemistry: Analytical` its `Chemistry - Analytical` - with an EM DASH, which is why it is spliced through char() in the data script. THE EQUIPMENT BUDGET IS NOT IMPORTED: $8,000 to $20,000 on printed 161, plus a crime lab the character has already spent 2D4x10,000 on. Survey D7."' || char(10) || '---') > 0;

-- sea-inquisitor: production takes the repo text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'equipment_starting:' || char(10) || '  - { item_id: "light-mdc-body-armor", qty: 1 }' || char(10) || '  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle", "l-20-pulse-rifle"], note: "The book says one energy weapon of choice without enumerating; this is the catalog set, widened as more books are imported." }',
         'equipment_starting:' || char(10) || '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }' || char(10) || '  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle", "l-20-pulse-rifle"], note: "The book says one energy weapon of choice without enumerating; this is the catalog set, widened as more books are imported." }'),
       updated_at = datetime('now')
 WHERE class_id = 'sea-inquisitor'
   AND instr(markdown, 'equipment_starting:' || char(10) || '  - { item_id: "light-mdc-body-armor", qty: 1 }' || char(10) || '  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle", "l-20-pulse-rifle"], note: "The book says one energy weapon of choice without enumerating; this is the catalog set, widened as more books are imported." }') > 0;

-- fq-deep-intel-agent: production takes the repo text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'attribute_maximums: { PB: 12 }' || char(10) || 'attribute_maximums: { PB: 12 }' || char(10) || 'bonuses:',
         'attribute_maximums: { PB: 12 }' || char(10) || 'bonuses:'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent'
   AND instr(markdown, 'attribute_maximums: { PB: 12 }' || char(10) || 'attribute_maximums: { PB: 12 }' || char(10) || 'bonuses:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "air-filter", qty: 1 }' || char(10) || '  - { item_id: "back-pack", qty: 1 }' || char(10) || '  - { item_id: "canteen", qty: 1 }',
         '  - { item_id: "air-filter", qty: 1 }' || char(10) || '  - { item_id: "backpack", qty: 1 }' || char(10) || '  - { item_id: "canteen", qty: 1 }'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent'
   AND instr(markdown, '  - { item_id: "air-filter", qty: 1 }' || char(10) || '  - { item_id: "back-pack", qty: 1 }' || char(10) || '  - { item_id: "canteen", qty: 1 }') > 0;

-- monk: a rebuild takes production text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    choose: 1' || char(10) || '    note: "Powers of Mastery, printed 60-61: ''Select only ONE of the three available areas of focus and study.'' These are the ADDITIONAL SKILLS each area grants; its combat techniques, bonuses and superhuman abilities stay on the ability of the same name, because they are not skills. NOT EXPRESSIBLE HERE and left in this note: the open weapon-proficiency picks each area grants alongside them - two for Defense, four for Offense, two for Meditation, all ''of choice from any category''. The occ_related_skills block above already excludes Acrobatics, Gymnastics and Boxing from the Physical category, so a monk cannot take one of these twice."' || char(10) || '    options:',
         '    choose: 1' || char(10) || '    note: "Powers of Mastery, printed 60-61: ''Select only ONE of the three available areas of focus and study.'' These are the ADDITIONAL SKILLS each area grants; its combat techniques, bonuses and superhuman abilities stay on the ability of the same name, because they are not skills. The open weapon-proficiency picks each area grants - two for Defense, four for Offense, two for Meditation - are choice groups over the Weapon Proficiencies category, added by RETRO-AUDIT R10 (2026-09-04). This note said they were not expressible, which was false when R2 wrote it: an MOS option takes the same skill entries occ_skills does, choice groups included. The occ_related_skills block above already excludes Acrobatics, Gymnastics and Boxing from the Physical category, so a monk cannot take one of these twice."' || char(10) || '    options:'),
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, '    choose: 1' || char(10) || '    note: "Powers of Mastery, printed 60-61: ''Select only ONE of the three available areas of focus and study.'' These are the ADDITIONAL SKILLS each area grants; its combat techniques, bonuses and superhuman abilities stay on the ability of the same name, because they are not skills. NOT EXPRESSIBLE HERE and left in this note: the open weapon-proficiency picks each area grants alongside them - two for Defense, four for Offense, two for Meditation, all ''of choice from any category''. The occ_related_skills block above already excludes Acrobatics, Gymnastics and Boxing from the Physical category, so a monk cannot take one of these twice."' || char(10) || '    options:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }' || char(10) || '      - id: "offense"',
         '            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }' || char(10) || '            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }' || char(10) || '      - id: "offense"'),
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, '            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }' || char(10) || '      - id: "offense"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }' || char(10) || '      - id: "meditation"',
         '            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }' || char(10) || '            - { choose: 4, categories: ["Weapon Proficiencies"], note: "The book: four weapon proficiencies of choice from any category." }' || char(10) || '      - id: "meditation"'),
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, '            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }' || char(10) || '      - id: "meditation"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }' || char(10) || '  occ_related_skills:',
         '            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }' || char(10) || '            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }' || char(10) || '  occ_related_skills:'),
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, '            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }' || char(10) || '  occ_related_skills:') > 0;

-- demon-goblin: a rebuild takes production text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    choose: 1' || char(10) || '    note: "The book gives three complete R.C.C. skill packages - assassin, thief and spy - and every demon-goblin is one of them. Printed 123-124. Each option''s skills are granted in addition to the three above, which are the only ones identical across all three professions. NOT EXPRESSIBLE HERE and deliberately left in this note rather than dropped: the open weapon-proficiency picks (the book''s ''one modern W.P. of choice and one W.P. from any category'' for the assassin, ''one W.P. of choice'' for the thief, ''two W.P.s of choice'' for the spy), the spy''s one additional language of choice, and the assassin''s +5% to all acrobatic skills, which needs the per-skill modifier CLASS-AUDIT records as absent."' || char(10) || '    options:',
         '    choose: 1' || char(10) || '    note: "The book gives three complete R.C.C. skill packages - assassin, thief and spy - and every demon-goblin is one of them. Printed 123-124. Each option''s skills are granted in addition to the three above, which are the only ones identical across all three professions. The open weapon-proficiency picks and the spy''s extra language are choice groups on each option, added by RETRO-AUDIT R10 (2026-09-04). This note said they were not expressible, which was false when R2 wrote it. STILL not expressible, and checked rather than assumed: the assassin''s +5% to all acrobatic skills, because the package grants no acrobatic skill at all, so it modifies skills obtained elsewhere - the per-skill modifier CLASS-AUDIT records as absent. The catalog also does not divide W.P.s into ancient and modern, so the assassin''s and thief''s groups are broader than the book by that much."' || char(10) || '    options:'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, '    choose: 1' || char(10) || '    note: "The book gives three complete R.C.C. skill packages - assassin, thief and spy - and every demon-goblin is one of them. Printed 123-124. Each option''s skills are granted in addition to the three above, which are the only ones identical across all three professions. NOT EXPRESSIBLE HERE and deliberately left in this note rather than dropped: the open weapon-proficiency picks (the book''s ''one modern W.P. of choice and one W.P. from any category'' for the assassin, ''one W.P. of choice'' for the thief, ''two W.P.s of choice'' for the spy), the spy''s one additional language of choice, and the assassin''s +5% to all acrobatic skills, which needs the per-skill modifier CLASS-AUDIT records as absent."' || char(10) || '    options:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }' || char(10) || '      - id: "thief"',
         '            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }' || char(10) || '            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: one MODERN W.P. of choice and one W.P. from any category. The catalog does not divide W.P.s into ancient and modern, so this group is broader than the book by that much." }' || char(10) || '      - id: "thief"'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, '            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }' || char(10) || '      - id: "thief"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }' || char(10) || '      - id: "spy"',
         '            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }' || char(10) || '            - { choose: 1, categories: ["Weapon Proficiencies"], note: "The book: one W.P. of choice, including modern weapons. The catalog does not divide W.P.s into ancient and modern." }' || char(10) || '      - id: "spy"'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, '            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }' || char(10) || '      - id: "spy"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }' || char(10) || 'natural_abilities:',
         '            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }' || char(10) || '            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two W.P.s of choice, any category." }' || char(10) || '            - { choose: 1, from: ["Language: Other"], note: "The book: one additional language of choice. Language: Other is the repeatable catalog row for a language the books never print." }' || char(10) || 'natural_abilities:'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, '            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }' || char(10) || 'natural_abilities:') > 0;

-- imperial-legionnaire: a rebuild takes production text.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    is what the book says and looks like an error until you read the note.' || char(10) || '  - "W.P. Heavy Military Weapons" IS AMBIGUOUS IN THIS CATALOG and is offered as a choice between' || char(10) || '    W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons. This book predates',
         '    is what the book says and looks like an error until you read the note.' || char(10) || '  - "W.P. Heavy" IS AMBIGUOUS IN THIS CATALOG and is offered as a choice between' || char(10) || '    W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons. This book predates'),
       updated_at = datetime('now')
 WHERE class_id = 'imperial-legionnaire'
   AND instr(markdown, '    is what the book says and looks like an error until you read the note.' || char(10) || '  - "W.P. Heavy Military Weapons" IS AMBIGUOUS IN THIS CATALOG and is offered as a choice between' || char(10) || '    W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons. This book predates') > 0;

-- colonist: the skill name goes to production, the note to a rebuild.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    - { name: "Track Animals", bonus: 10, note: "+10% bonus over base." }' || char(10) || '    - { name: "Identify Plants & Fruits", bonus: 15, note: "Printed as Identify Plants and Fruits (+15%)." }' || char(10) || '    - { name: "Botany", bonus: 10, note: "+10% bonus over base." }',
         '    - { name: "Track Animals", bonus: 10, note: "+10% bonus over base." }' || char(10) || '    - { name: "Identify Plants & Fruit", bonus: 15, note: "Printed as Identify Plants and Fruits (+15%)." }' || char(10) || '    - { name: "Botany", bonus: 10, note: "+10% bonus over base." }'),
       updated_at = datetime('now')
 WHERE class_id = 'colonist'
   AND instr(markdown, '    - { name: "Track Animals", bonus: 10, note: "+10% bonus over base." }' || char(10) || '    - { name: "Identify Plants & Fruits", bonus: 15, note: "Printed as Identify Plants and Fruits (+15%)." }' || char(10) || '    - { name: "Botany", bonus: 10, note: "+10% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    `saves.toxins_poisons` and +1 vs horror factor is `saves.horror_factor`.' || char(10) || '    Both are real keys that `sheet.js` renders - unlike the Spacer''s' || char(10) || '    decompression save, which has no field at all. See BOOK-INGEST-AUDIT.md F7.' || char(10) || '  - Experience table transcribed from a 200 dpi render of printed 183, shared',
         '    `saves.toxins_poisons` and +1 vs horror factor is `saves.horror_factor`.' || char(10) || '    Both are real keys that `sheet.js` renders directly. The Spacer''s' || char(10) || '    decompression save had no field at all when this class was imported and now' || char(10) || '    has one: BOOK-INGEST-AUDIT.md F7 has since been taken, and a save the' || char(10) || '    sixteen fixed fields do not name goes in `bonuses.saves.other` with the' || char(10) || '    book''s own wording as its label.' || char(10) || '  - Experience table transcribed from a 200 dpi render of printed 183, shared'),
       updated_at = datetime('now')
 WHERE class_id = 'colonist'
   AND instr(markdown, '    `saves.toxins_poisons` and +1 vs horror factor is `saves.horror_factor`.' || char(10) || '    Both are real keys that `sheet.js` renders - unlike the Spacer''s' || char(10) || '    decompression save, which has no field at all. See BOOK-INGEST-AUDIT.md F7.' || char(10) || '  - Experience table transcribed from a 200 dpi render of printed 183, shared') > 0;

-- Read the result back. This batch asserts its OWN rows and nothing else.

SELECT 'seven Nightbane stubs are gear' AS assertion, count(*) AS got, 7 AS want
  FROM gear
 WHERE category = 'gear'
   AND slug IN ('travelling-clothes-nb', 'mirror-nb', 'portable-radio-nb', 'portable-cd-player-nb',
                'walking-stick-nb', 'small-library-nb', 'magnifying-glass-nb');

SELECT 'the Darkblade Scimitar is a weapon' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'darkblade-scimitar-nb' AND category = 'weapon';

-- Each class is asserted on a phrase only its right version holds. The full
-- replaced blocks are too long for wrangler to take as a read-back command.

SELECT 'wizard: the merged extraction note' AS assertion,
       instr(markdown, 'The groups carry no note fields') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'wizard';

SELECT 'hu-super-sleuth: the merged extraction note' AS assertion,
       instr(markdown, 'which regression.mjs caught on the first draft') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-super-sleuth';

SELECT 'sea-inquisitor: the armour is a choice, not a category row' AS assertion,
       (instr(markdown, 'item_id: "light-mdc-body-armor"') = 0
        AND instr(markdown, 'label: "light M.D.C. body armor"') > 0) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'sea-inquisitor';

SELECT 'fq-deep-intel-agent: one PB cap and the merged backpack' AS assertion,
       ((length(markdown) - length(replace(markdown, 'attribute_maximums:', ''))) / 19 = 1
        AND instr(markdown, 'back-pack') = 0
        AND instr(markdown, 'item_id: "backpack"') > 0) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'fq-deep-intel-agent';

SELECT 'monk: the R10 choice groups replace the note' AS assertion,
       (instr(markdown, 'choose: 4, categories: ["Weapon Proficiencies"]') > 0
        AND instr(markdown, 'NOT EXPRESSIBLE HERE and left in this note') = 0) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'monk';

SELECT 'demon-goblin: the R10 choice groups replace the note' AS assertion,
       (instr(markdown, 'two W.P.s of choice, any category') > 0
        AND instr(markdown, 'NOT EXPRESSIBLE HERE and deliberately left') = 0) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'demon-goblin';

SELECT 'imperial-legionnaire: the note quotes the book' AS assertion,
       instr(markdown, '"W.P. Heavy" IS AMBIGUOUS') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'imperial-legionnaire';

SELECT 'colonist: the catalog skill name and the current F7 note' AS assertion,
       (instr(markdown, '"Identify Plants & Fruit"') > 0
        AND instr(markdown, 'F7 has since been taken') > 0) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'colonist';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql');
