-- Rifts World Book 14: New West - two backfills on fourteen classes. See
-- apps/character-creator/docs/surveys/new-west.md, "The New West backfill".
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~009-new-west-dice-and-horror-factor.sql
--
-- == A. DICE ATTRIBUTE BONUSES LEFT IN PROSE ==
--
-- Five classes were imported (PRs #885-#888) with their dice attribute bonuses
-- in prose, on the belief that `bonuses.attributes` takes only a fixed number.
-- It never did: a dice string there is rolled ONCE at creation and stored on
-- the character (js/derive.js diceBonuses / diceBonusesByGroup, called from
-- app.js rollDiceBonusesOf). BOOK-INGEST-AUDIT F52 was falsified on 2026-09-10
-- and fix-f52-false-dice-claims.sql corrected the Sky-Knight; these five were
-- not swept then. Values read off the book, printed page in brackets:
--
--   saddle-tramp      M.A. +1D4        (102, rendered - the text layer reads +!D4)
--   preacher          M.A. +1D4+2      (116)
--   saloon-bum        P.E. +1D4        (122, rendered - the text layer reads +!D4)
--   saloon-girl       M.A. +1D4+1      (124)
--   wired-gunslinger  P.S. +1D4, Spd +2D6, initiative +3+1D4, P.P. SET to 17+1D6 (107)
--
-- The Wired Gunslinger's P.P. is an ASSIGNMENT, not a bonus, so it is
-- `attribute_dice` PP "1d6+17" - rolled in place of 3D6, the shape
-- add-anti-monster-class.sql uses for an occupation's set attributes. A race
-- that states its own attribute_dice replaces it in a pairing (combineClasses);
-- the book restricts the class to humans and near-human D-bees.
--
-- The Preacher's Fire and Brimstone variant restates `bonuses`, and a variant's
-- bonuses REPLACE the base block, so the M.A. dice go in both. That variant's
-- block had also dropped the +1 save vs Horror Factor at levels 1, 3, 5, 6, 7,
-- 9, 11, 13 and 15 that printed 116 gives every Preacher; restored here, since
-- this script rewrites that block anyway.
--
-- == B. PROJECTED HORROR FACTOR ==
--
-- BOOK-INGEST-AUDIT F75 (PR #1081) added a class-level `horror_factor`
-- frontmatter key - a number or the phrase the book prints, display only - and
-- did not backfill. Ten classes here carried the value in prose with the
-- sentence "the sheet has no field for it". Each gains the key, placed after
-- starting_money (an O.C.C.) or ppe_base (an R.C.C.) as the 74 existing
-- carriers place it, and loses the sentence. A level schedule is written into
-- the phrase, because nothing on the sheet reads a level for it.
--
--   gunfighter, sheriff-lawman  8 from 6th level (91, 103-104)
--   justice-ranger              8 from 5th level (97)
--   gunslinger, psi-slinger, wired-gunslinger  8, rising (94, 100, 108)
--   cactus-people 9+1D4 (127), fennodi 9 (129), keeper-of-the-desert 10+1D4
--   (132), mountain-giant 10+1D4 (136)
--
-- Every UPDATE is guarded on the exact text it replaces, so a re-run is a no-op
-- and none can fire against a row edited since. The markdown each one was
-- written against was read from production on 2026-09-26 and matched the
-- local database byte for byte.
--
-- WHY ~009: it must sort after ~001-men-of-arms-frontmatter.sql and
-- zzzzzzzzzzzzzz-hand-to-hand-prices.sql, the last files that touch these
-- classes, and ~007 was the highest number in the tree when it was written.

-- == gunfighter ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "4d6x100 credits worth of tradeable goods, plus 1d6x1000 in universal credits"' || char(10) || 'bonuses:',
         'starting_money: "4d6x100 credits worth of tradeable goods, plus 1d6x1000 in universal credits"' || char(10) || 'horror_factor: "None until 6th level, then 8; +1 at levels 7, 8, 9, 11, 13 and 15, and +1 against ordinary citizens"' || char(10) || 'bonuses:')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, 'starting_money: "4d6x100 credits worth of tradeable goods, plus 1d6x1000 in universal credits"' || char(10) || 'bonuses:') > 0;

-- == gunslinger ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'bonuses:',
         'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'horror_factor: "8; +1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15, and +2 against common folk"' || char(10) || 'bonuses:')
 WHERE class_id = 'gunslinger'
   AND instr(markdown, 'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'bonuses:') > 0;

-- == justice-ranger ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "3d6x100 in credits, plus tradeable items worth another 1d4x1000"' || char(10) || 'bonuses:',
         'starting_money: "3d6x100 in credits, plus tradeable items worth another 1d4x1000"' || char(10) || 'horror_factor: "None until 5th level, then 8; +1 at levels 6, 7, 8, 9, 11, 13 and 15, and +2 against ordinary citizens, lowlifes and two-bit bandits"' || char(10) || 'bonuses:')
 WHERE class_id = 'justice-ranger'
   AND instr(markdown, 'starting_money: "3d6x100 in credits, plus tradeable items worth another 1d4x1000"' || char(10) || 'bonuses:') > 0;

-- == psi-slinger ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'psionics:',
         'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'horror_factor: "8; +1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15"' || char(10) || 'psionics:')
 WHERE class_id = 'psi-slinger'
   AND instr(markdown, 'starting_money: "3d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'psionics:') > 0;

-- == sheriff-lawman ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "2d6x100 credits worth of tradeable goods and 1d6x1000 in universal credits"' || char(10) || 'bonuses:',
         'starting_money: "2d6x100 credits worth of tradeable goods and 1d6x1000 in universal credits"' || char(10) || 'horror_factor: "None until 6th level, then 8; +1 at levels 7, 8, 9, 11, 13 and 15, and +1 against ordinary citizens and two-bit bandits"' || char(10) || 'bonuses:')
 WHERE class_id = 'sheriff-lawman'
   AND instr(markdown, 'starting_money: "2d6x100 credits worth of tradeable goods and 1d6x1000 in universal credits"' || char(10) || 'bonuses:') > 0;

-- == wired-gunslinger ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'starting_money: "4d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'bonuses:',
         'starting_money: "4d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'horror_factor: "8; +1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15, and +2 against ordinary folk"' || char(10) || 'bonuses:')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'starting_money: "4d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"' || char(10) || 'bonuses:') > 0;

-- == cactus-people ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'ppe_base: "4d6"' || char(10) || 'psionics:',
         'ppe_base: "4d6"' || char(10) || 'horror_factor: "9+1D4"' || char(10) || 'psionics:')
 WHERE class_id = 'cactus-people'
   AND instr(markdown, 'ppe_base: "4d6"' || char(10) || 'psionics:') > 0;

-- == fennodi ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'ppe_base: "4d6+12"' || char(10) || 'bonuses:',
         'ppe_base: "4d6+12"' || char(10) || 'horror_factor: 9' || char(10) || 'bonuses:')
 WHERE class_id = 'fennodi'
   AND instr(markdown, 'ppe_base: "4d6+12"' || char(10) || 'bonuses:') > 0;

-- == keeper-of-the-desert ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'ppe_base: "3d4x10, +1d6 per level of experience"' || char(10) || 'bonuses:',
         'ppe_base: "3d4x10, +1d6 per level of experience"' || char(10) || 'horror_factor: "10+1D4"' || char(10) || 'bonuses:')
 WHERE class_id = 'keeper-of-the-desert'
   AND instr(markdown, 'ppe_base: "3d4x10, +1d6 per level of experience"' || char(10) || 'bonuses:') > 0;

-- == mountain-giant ==

-- the projected Horror Factor, as the top-level key
UPDATE imported_classes
   SET markdown = replace(markdown,
         'ppe_base: "2d6"' || char(10) || 'psionics:',
         'ppe_base: "2d6"' || char(10) || 'horror_factor: "10+1D4"' || char(10) || 'psionics:')
 WHERE class_id = 'mountain-giant'
   AND instr(markdown, 'ppe_base: "2d6"' || char(10) || 'psionics:') > 0;

-- == gunfighter ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES on others, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES on others, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES on others, not a save; the sheet has no field for it.') > 0;

-- == gunslinger ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'gunslinger'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES; the sheet has no field for it.') > 0;

-- == wired-gunslinger ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES; the sheet has no field for it.') > 0;

-- == justice-ranger ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'justice-ranger'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == psi-slinger ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'psi-slinger'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == sheriff-lawman ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'sheriff-lawman'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == cactus-people ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'cactus-people'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == fennodi ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'fennodi'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == keeper-of-the-desert ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'keeper-of-the-desert'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == mountain-giant ==

-- drop the "no field" sentence
UPDATE imported_classes
   SET markdown = replace(markdown,
         'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.',
         'This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor.')
 WHERE class_id = 'mountain-giant'
   AND instr(markdown, 'This is a Horror Factor the character IMPOSES, not a save; the sheet has no field for it.') > 0;

-- == gunfighter ==

-- the extraction note on the Horror Factor
UPDATE imported_classes
   SET markdown = replace(markdown,
         '(3) The Horror Factor of 8 at 6th level is one the character PROJECTS; bonuses.saves.horror_factor is the save against one, so this is prose, following the demigod.',
         '(3) The Horror Factor of 8 at 6th level is one the character PROJECTS; bonuses.saves.horror_factor is the save against one. It was prose on import, following the demigod; the New West backfill stored it as the top-level `horror_factor` BOOK-INGEST-AUDIT F75 added in PR #1081, and the ability keeps the rules text.')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, '(3) The Horror Factor of 8 at 6th level is one the character PROJECTS; bonuses.saves.horror_factor is the save against one, so this is prose, following the demigod.') > 0;

-- == cactus-people ==

-- the extraction note on the Horror Factor
UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Horror Factor of 9+1D4 is one the character IMPOSES rather than saves against, so it is a natural ability rather than a bonus - the demigod''s precedent.',
         'The Horror Factor of 9+1D4 is one the character IMPOSES rather than saves against, so it is not a bonus. It was only a natural ability on import, the demigod''s precedent; the New West backfill stored it as the top-level `horror_factor` BOOK-INGEST-AUDIT F75 added in PR #1081, and the natural ability keeps the description.')
 WHERE class_id = 'cactus-people'
   AND instr(markdown, 'The Horror Factor of 9+1D4 is one the character IMPOSES rather than saves against, so it is a natural ability rather than a bonus - the demigod''s precedent.') > 0;

-- == mountain-giant ==

-- the extraction note on the Horror Factor
UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Horror Factor of 10+1D4 is one the character IMPOSES rather than saves against.',
         'The Horror Factor of 10+1D4 is one the character IMPOSES rather than saves against; the New West backfill stored it as the top-level `horror_factor` BOOK-INGEST-AUDIT F75 added in PR #1081.')
 WHERE class_id = 'mountain-giant'
   AND instr(markdown, 'The Horror Factor of 10+1D4 is one the character IMPOSES rather than saves against.') > 0;

-- == saddle-tramp ==

-- +1D4 M.A. into bonuses.attributes
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { initiative: 1, pull_punch: 2, roll: 2 }',
         'bonuses:' || char(10) || '  attributes: { MA: "1d4" }' || char(10) || '  combat: { initiative: 1, pull_punch: 2, roll: 2 }')
 WHERE class_id = 'saddle-tramp'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { initiative: 1, pull_punch: 2, roll: 2 }') > 0;

-- the extraction note
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE M.A. BONUS IS NOT STORED AS A NUMBER. The book prints ''+1D4 to M.A.'' among the O.C.C. Bonuses on printed 102; `bonuses.attributes` takes a fixed number, and a dice expression there is not applied. Recorded here rather than rounded to an invented figure - roll 1D4 and add it to M.A. at creation.',
         'The book prints ''+1D4 to M.A.'' among the O.C.C. Bonuses on printed 102; it is `bonuses.attributes` MA "1d4", rolled once at creation. On import (PR #885) it was left here in prose, on the belief that `bonuses.attributes` took only a fixed number; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved it into the block.')
 WHERE class_id = 'saddle-tramp'
   AND instr(markdown, 'THE M.A. BONUS IS NOT STORED AS A NUMBER. The book prints ''+1D4 to M.A.'' among the O.C.C. Bonuses on printed 102; `bonuses.attributes` takes a fixed number, and a dice expression there is not applied. Recorded here rather than rounded to an invented figure - roll 1D4 and add it to M.A. at creation.') > 0;

-- == preacher ==

-- +1D4+2 M.A. into the base bonuses
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { pull_punch: 4, disarm: 2 }' || char(10) || '  saves: { mind_control: 1, possession: 4, horror_factor: 1 }',
         'bonuses:' || char(10) || '  attributes: { MA: "1d4+2" }' || char(10) || '  combat: { pull_punch: 4, disarm: 2 }' || char(10) || '  saves: { mind_control: 1, possession: 4, horror_factor: 1 }')
 WHERE class_id = 'preacher'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { pull_punch: 4, disarm: 2 }' || char(10) || '  saves: { mind_control: 1, possession: 4, horror_factor: 1 }') > 0;

-- the Fire and Brimstone variant: the M.A. dice, and the Horror Factor save ladder its restated bonuses dropped
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    bonuses:' || char(10) || '      combat: { pull_punch: 4, disarm: 2 }' || char(10) || '      saves: { mind_control: 1, possession: 4 }' || char(10) || '      pools: { sdc: "2d6+10" }',
         '    bonuses:' || char(10) || '      attributes: { MA: "1d4+2" }' || char(10) || '      combat: { pull_punch: 4, disarm: 2 }' || char(10) || '      saves: { mind_control: 1, possession: 4, horror_factor: 1 }' || char(10) || '      pools: { sdc: "2d6+10" }' || char(10) || '      at_level:' || char(10) || '        - { level: 3, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 5, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 6, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 7, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 9, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 11, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 13, saves: { horror_factor: 1 } }' || char(10) || '        - { level: 15, saves: { horror_factor: 1 } }')
 WHERE class_id = 'preacher'
   AND instr(markdown, '    bonuses:' || char(10) || '      combat: { pull_punch: 4, disarm: 2 }' || char(10) || '      saves: { mind_control: 1, possession: 4 }' || char(10) || '      pools: { sdc: "2d6+10" }') > 0;

-- the M.A. ability goes: the bonus is in the block now
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - name: "M.A. bonus"' || char(10) || '    description: "+1D4+2 to M.A. It is dice rather than a fixed number, so it is not applied automatically - roll it at creation."' || char(10) || '',
         '')
 WHERE class_id = 'preacher'
   AND instr(markdown, '  - name: "M.A. bonus"' || char(10) || '    description: "+1D4+2 to M.A. It is dice rather than a fixed number, so it is not applied automatically - roll it at creation."' || char(10) || '') > 0;

-- the extraction note
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +1D4+2 TO M.A. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the same call the Saddle Tramp and the Wired Gunslinger needed.',
         'The +1D4+2 to M.A. is `bonuses.attributes` MA "1d4+2", rolled once at creation, in the base block AND in the Fire and Brimstone variant''s, because a variant''s bonuses replace. On import (PR #887) it was an ability, on the belief that a dice expression there was not applied; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved it into both blocks. The same backfill restored the variant''s +1 save vs Horror Factor at levels 1, 3, 5, 6, 7, 9, 11, 13 and 15 (printed 116, for every Preacher), which its restated block had dropped.')
 WHERE class_id = 'preacher'
   AND instr(markdown, 'THE +1D4+2 TO M.A. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the same call the Saddle Tramp and the Wired Gunslinger needed.') > 0;

-- == saloon-bum ==

-- +1D4 P.E. into bonuses.attributes
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { initiative: 1, roll: 2 }',
         'bonuses:' || char(10) || '  attributes: { PE: "1d4" }' || char(10) || '  combat: { initiative: 1, roll: 2 }')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { initiative: 1, roll: 2 }') > 0;

-- the P.E. ability goes
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - name: "P.E. bonus"' || char(10) || '    description: "+1D4 to P.E. It is dice rather than a fixed number, so it is not applied automatically - roll it at creation."' || char(10) || '',
         '')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, '  - name: "P.E. bonus"' || char(10) || '    description: "+1D4 to P.E. It is dice rather than a fixed number, so it is not applied automatically - roll it at creation."' || char(10) || '') > 0;

-- the extraction note
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +1D4 TO P.E. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the fourth class in this book to need that call, after the Saddle Tramp, the Wired Gunslinger and the Preacher.',
         'The +1D4 to P.E. is `bonuses.attributes` PE "1d4", rolled once at creation. On import (PR #887) it was an ability, on the belief that a dice expression there was not applied; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved it into the block.')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, 'THE +1D4 TO P.E. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the fourth class in this book to need that call, after the Saddle Tramp, the Wired Gunslinger and the Preacher.') > 0;

-- == saloon-girl ==

-- +1D4+1 M.A. into bonuses.attributes
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { initiative: 2, roll: 2 }',
         'bonuses:' || char(10) || '  attributes: { MA: "1d4+1" }' || char(10) || '  combat: { initiative: 2, roll: 2 }')
 WHERE class_id = 'saloon-girl'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { initiative: 2, roll: 2 }') > 0;

-- the ability keeps only the charm bonus
UPDATE imported_classes
   SET markdown = replace(markdown,
         '"+1D4+1 to M.A., and +10% to charm and impress if P.B. is over 20. The M.A. figure is dice rather than a fixed number, so it is not applied automatically - roll it at creation. The charm bonus is conditional on an attribute threshold and has no field on the sheet."',
         '"+1D4+1 to M.A., rolled once at creation, and +10% to charm and impress if P.B. is over 20. The charm bonus is conditional on an attribute threshold and has no field on the sheet."')
 WHERE class_id = 'saloon-girl'
   AND instr(markdown, '"+1D4+1 to M.A., and +10% to charm and impress if P.B. is over 20. The M.A. figure is dice rather than a fixed number, so it is not applied automatically - roll it at creation. The charm bonus is conditional on an attribute threshold and has no field on the sheet."') > 0;

-- the extraction note
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +1D4+1 TO M.A. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the sixth class in this book to need that call. The +10% to charm and impress when P.B. is over 20 is conditional on an attribute threshold and has no sheet field; it is in the same ability.',
         'The +1D4+1 to M.A. is `bonuses.attributes` MA "1d4+1", rolled once at creation. On import (PR #888) it was ability prose, on the belief that a dice expression there was not applied; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved it into the block. The +10% to charm and impress when P.B. is over 20 is conditional on an attribute threshold and has no sheet field; it stays in the ability.')
 WHERE class_id = 'saloon-girl'
   AND instr(markdown, 'THE +1D4+1 TO M.A. IS NOT STORED AS A NUMBER: `bonuses.attributes` takes a fixed value and a dice expression there is not applied, so it is an ability to be rolled at creation - the sixth class in this book to need that call. The +10% to charm and impress when P.B. is over 20 is conditional on an attribute threshold and has no sheet field; it is in the same ability.') > 0;

-- == wired-gunslinger ==

-- P.P. is SET to 17+1D6: attribute_dice, rolled in place of 3D6
UPDATE imported_classes
   SET markdown = replace(markdown,
         'occ_group: men-of-arms' || char(10) || 'hit_points_base: "P.E. + 1d6 per level"',
         'occ_group: men-of-arms' || char(10) || 'attribute_dice:' || char(10) || '  PP: "1d6+17"' || char(10) || 'hit_points_base: "P.E. + 1d6 per level"')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'occ_group: men-of-arms' || char(10) || 'hit_points_base: "P.E. + 1d6 per level"') > 0;

-- P.S. +1D4, Spd +2D6 and initiative +3+1D4 into bonuses
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { attacks: 1, automatic_dodge: 1, pull_punch: 2 }',
         'bonuses:' || char(10) || '  attributes: { PS: "1d4", Spd: "2d6" }' || char(10) || '  combat: { attacks: 1, automatic_dodge: 1, pull_punch: 2, initiative: "1d4+3" }')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { attacks: 1, automatic_dodge: 1, pull_punch: 2 }') > 0;

-- the augmentation ability stops saying none of it is applied
UPDATE imported_classes
   SET markdown = replace(markdown,
         'All four are dice rather than fixed numbers, so none of them is applied automatically - roll each at creation. The extra melee attack and the automatic dodge from the same augmentation ARE fixed and are in the bonuses block.',
         'The P.S., Speed and initiative dice are rolled once at creation, and P.P. is rolled as 17+1D6 in place of the usual 3D6. The extra melee attack and the automatic dodge from the same augmentation are fixed.')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'All four are dice rather than fixed numbers, so none of them is applied automatically - roll each at creation. The extra melee attack and the automatic dodge from the same augmentation ARE fixed and are in the bonuses block.') > 0;

-- the extraction note
UPDATE imported_classes
   SET markdown = replace(markdown,
         'FOUR OF THIS CLASS''S AUGMENTATION BONUSES ARE DICE AND ARE NOT STORED AS NUMBERS: P.S. +1D4, P.P. SET to 17+1D6, Speed +2D6, and +3+1D4 to initiative. `bonuses.attributes` and `bonuses.combat` take fixed values and a dice expression there is not applied, so all four are in the Crazies Augmentation ability to be rolled at creation. The P.P. one is not even a bonus - it SETS the attribute, which nothing in the schema expresses.',
         'FOUR OF THIS CLASS''S AUGMENTATION BONUSES ARE DICE. P.S. +1D4, Speed +2D6 and +3+1D4 to initiative are `bonuses` (PS "1d4", Spd "2d6", initiative "1d4+3"), rolled once at creation. P.P. is SET to 17+1D6 rather than raised, so it is `attribute_dice` PP "1d6+17", rolled in place of 3D6 - the shape the Anti-Monster uses; a race that states its own attribute_dice replaces it in a pairing. On import (PR #886) all four were prose in the Crazies Augmentation ability, on the belief that a dice expression in bonuses was not applied and that nothing expressed a set attribute; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved all four.')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'FOUR OF THIS CLASS''S AUGMENTATION BONUSES ARE DICE AND ARE NOT STORED AS NUMBERS: P.S. +1D4, P.P. SET to 17+1D6, Speed +2D6, and +3+1D4 to initiative. `bonuses.attributes` and `bonuses.combat` take fixed values and a dice expression there is not applied, so all four are in the Crazies Augmentation ability to be rolled at creation. The P.P. one is not even a bonus - it SETS the attribute, which nothing in the schema expresses.') > 0;

-- == Read the result back rather than trusting the exit code ==

SELECT 'ten classes carry a top-level horror_factor' AS assertion, count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id IN ('gunfighter', 'gunslinger', 'justice-ranger', 'psi-slinger', 'sheriff-lawman',
                    'wired-gunslinger', 'cactus-people', 'fennodi', 'keeper-of-the-desert', 'mountain-giant')
   AND instr(markdown, char(10) || 'horror_factor: ') > 0;

SELECT 'the three racial dice values are the printed ones' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'cactus-people' AND instr(markdown, char(10) || 'horror_factor: "9+1D4"' || char(10)) > 0)
    OR (class_id IN ('keeper-of-the-desert', 'mountain-giant') AND instr(markdown, char(10) || 'horror_factor: "10+1D4"' || char(10)) > 0);

SELECT 'the Fennodi is a plain 9' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'fennodi' AND instr(markdown, char(10) || 'horror_factor: 9' || char(10)) > 0;

SELECT 'the three late-starting lawmen say so' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('gunfighter', 'justice-ranger', 'sheriff-lawman')
   AND instr(markdown, char(10) || 'horror_factor: "None until ') > 0;

SELECT 'the three slingers start at 8' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('gunslinger', 'psi-slinger', 'wired-gunslinger')
   AND instr(markdown, char(10) || 'horror_factor: "8; +1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15') > 0;

SELECT 'none of the ten still says the sheet has no field for it' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gunfighter', 'gunslinger', 'justice-ranger', 'psi-slinger', 'sheriff-lawman',
                    'wired-gunslinger', 'cactus-people', 'fennodi', 'keeper-of-the-desert', 'mountain-giant')
   AND instr(markdown, 'the sheet has no field for it') > 0;

SELECT 'and each of the ten says the sheet shows it instead' AS assertion, count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id IN ('gunfighter', 'gunslinger', 'justice-ranger', 'psi-slinger', 'sheriff-lawman',
                    'wired-gunslinger', 'cactus-people', 'fennodi', 'keeper-of-the-desert', 'mountain-giant')
   AND instr(markdown, 'the sheet shows it as the class''s Horror Factor.') > 0;

SELECT 'saddle tramp M.A. +1D4 is in bonuses' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'saddle-tramp' AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { MA: "1d4" }' || char(10)) > 0;

SELECT 'preacher M.A. +1D4+2 is in the base block AND the variant' AS assertion,
       (length(markdown) - length(replace(markdown, 'attributes: { MA: "1d4+2" }', ''))) / length('attributes: { MA: "1d4+2" }') AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'preacher';

SELECT 'preacher carries the save vs Horror Factor ladder twice' AS assertion,
       (length(markdown) - length(replace(markdown, 'saves: { horror_factor: 1 } }', ''))) / length('saves: { horror_factor: 1 } }') AS got, 16 AS want
  FROM imported_classes WHERE class_id = 'preacher';

SELECT 'saloon bum P.E. +1D4 is in bonuses' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'saloon-bum' AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PE: "1d4" }' || char(10)) > 0;

SELECT 'saloon girl M.A. +1D4+1 is in bonuses' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'saloon-girl' AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { MA: "1d4+1" }' || char(10)) > 0;

SELECT 'wired gunslinger P.P. is set by attribute_dice' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'wired-gunslinger' AND instr(markdown, 'attribute_dice:' || char(10) || '  PP: "1d6+17"' || char(10)) > 0;

SELECT 'wired gunslinger P.S., Spd and initiative dice are in bonuses' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, '  attributes: { PS: "1d4", Spd: "2d6" }' || char(10)) > 0
   AND instr(markdown, 'initiative: "1d4+3" }') > 0;

SELECT 'no dice-in-prose sentence survives' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('saddle-tramp', 'preacher', 'saloon-bum', 'saloon-girl', 'wired-gunslinger')
   AND (instr(markdown, 'dice rather than a fixed number') > 0
     OR instr(markdown, 'a dice expression there is not applied') > 0
     OR instr(markdown, 'IS NOT STORED AS A NUMBER') > 0
     OR instr(markdown, 'ARE NOT STORED AS NUMBERS') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~009-new-west-dice-and-horror-factor.sql');
