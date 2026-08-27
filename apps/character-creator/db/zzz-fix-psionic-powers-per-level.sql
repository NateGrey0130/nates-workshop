-- Mind Mage and Delphi Juicer: the powers they gain as they advance.
--
-- Both classes were published with a per-level psionic progression that lived
-- only in prose, so `powers_schedule` was absent and the Advancement step
-- offered NOTHING when either levelled up. The powers were printed, described
-- in a natural ability, and repeated in the extraction notes - and a player
-- levelling one of these two got an empty panel.
--
-- WHY IT WAS PROSE, AND WHY THAT REASON WAS WRONG. Both extraction notes used
-- to say the app could not hold a split like this. It can, and has since the
-- Mystic: a schedule ENTRY carries its own `categories`, several entries may
-- share a LEVEL and become separate slots, and `psionicCategoriesForGrant`
-- resolves each by (level, slot). The Shifter does the same thing with three
-- spell slots a level. The false reason was corrected in
-- zz-starting-power-splits.sql (CLASS-AUDIT.md S9), which left the schedules
-- themselves still unwritten. This is that half.
--
-- Both schedules run to 15. A schedule is a finite list rather than a rule, so
-- "each additional level of experience" has to be written out; 15 is the level
-- cap of the Mind Mage's own xp_table and of the default table the Delphi
-- uses.
--
-- FILENAME. `zzz-` rather than `fix-`, because a clean rebuild applies
-- db/*.sql as one sorted glob and a correction that sorts BEFORE the file it
-- corrects is silently undone. The last writer of the Mind Mage's markdown is
-- zz-starting-power-splits.sql and of the Delphi's is
-- zz-wire-juicer-uprising-equipment.sql; `fix-` sorts ahead of both.
--
-- Guarded with instr() rather than LIKE, because `_` is a single-character
-- wildcard in a LIKE pattern and '%powers_schedule%' would also match the
-- words written as prose - which both of these classes contain.

-- ---------------------------------------------------------------------------
-- MIND MAGE. Palladium Fantasy core, printed page 161, "The Powers of the Mind
-- Mage", bullet 1:
--
--   "Additional psionic abilities: The character gets to select a total of two
--    additional powers from any of the three lesser psionic categories, plus
--    three from the super psionic category for each additional level of
--    experience, starting at level two."
--
-- The same bullet names the four categories - "healing, sensitive, physical
-- and Super" - so the three LESSER ones are Healing, Sensitive and Physical.
-- Five powers a level, in two groups with different gates, which is two
-- entries per level rather than one entry of five: a grant carries its own
-- restriction, and one open count of five would let a Mind Mage take five
-- Super powers a level where the book grants three.
--
-- The book's Limitations line - "Mind wipe, psi-sword, and possess others
-- cannot be selected until third level" - names three powers the catalog files
-- under Super, so it can only bite on the level-two Super entry. It rides
-- there as a grant `note`, which the Advancement step prints above the picker.
-- The catalog cannot enforce it (a schedule entry gates by category, not by
-- name), so it is stated where the choice is made, the same posture the
-- Shifter's spell notes take.
--
-- Written in two statements because a `||` chain is one expression node per
-- term and SQLite rejects a tree deeper than 100. The marker line makes the
-- pair idempotent: the first cannot fire once the schedule is present, the
-- second cannot fire once the marker is gone.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]',
      '  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]' || char(10) ||
      '  powers_schedule:' || char(10) ||
      '    - { level: 2, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 2, count: 3, categories: ["Super"], note: "Mind Wipe, Psi-Sword and Mentally Possess Others cannot be selected until third level." }' || char(10) ||
      '    - { level: 3, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 3, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 4, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 4, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 5, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 5, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 6, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 6, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 7, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 7, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 8, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 8, count: 3, categories: ["Super"] }' || char(10) ||
      '  # MIND-MAGE-SCHEDULE-TAIL'
    )
WHERE class_id = 'mind-mage'
  AND instr(markdown, '  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]') > 0
  AND instr(markdown, 'powers_schedule:') = 0;

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  # MIND-MAGE-SCHEDULE-TAIL',
      '    - { level: 9, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 9, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 10, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 10, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 11, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 11, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 12, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 12, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 13, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 13, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 14, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 14, count: 3, categories: ["Super"] }' || char(10) ||
      '    - { level: 15, count: 2, categories: ["Healing", "Sensitive", "Physical"] }' || char(10) ||
      '    - { level: 15, count: 3, categories: ["Super"] }'
    )
WHERE class_id = 'mind-mage'
  AND instr(markdown, '  # MIND-MAGE-SCHEDULE-TAIL') > 0;

-- Read it back rather than trusting an exit code.
SELECT class_id,
       instr(markdown, '  powers_schedule:') > 0 AS has_schedule,
       instr(markdown, '# MIND-MAGE-SCHEDULE-TAIL') = 0 AS marker_gone,
       instr(markdown, 'level: 2, count: 3, categories: ["Super"], note: "Mind Wipe') > 0 AS has_limit_note,
       instr(markdown, 'level: 15, count: 2, categories: ["Healing", "Sensitive", "Physical"] }') > 0 AS has_tail_lesser,
       instr(markdown, 'level: 15, count: 3, categories: ["Super"] }') > 0 AS has_tail_super
FROM imported_classes
WHERE class_id = 'mind-mage';

-- ---------------------------------------------------------------------------
-- DELPHI JUICER. Rifts World Book 10: Juicer Uprising, printed page 40 (the
-- O.C.C. runs 39-41), ability 5, "Psionic Powers":
--
--   "The conversion process turns the Delphi into a master psionic with the
--    following abilities: Clairvoyance, presence sense, see aura, see the
--    invisible and three powers from the physical category and one power from
--    the super category (with the same restrictions as a Mind Melter). Each
--    level after the first, the Delphi can select one power from the physical,
--    sensitive or super categories."
--
-- CHECKED AGAINST THE PAGE, after the fact. This schedule was written before
-- the book was readable on this machine, from the class's own two records of
-- the rule - the "Master Psionic" special ability and the extraction notes -
-- and the header said so, as the one thing here resting on the repo rather
-- than on the book. The book has since been cached and the last sentence above
-- read off it: it agrees with both records on the count, the categories and
-- the starting level, so nothing in the schedule changes.
--
-- The same sentence is also the authority for the STARTING pick that
-- zz-starting-power-splits.sql wrote - three Physical and one Super, beside
-- the four powers it names outright.
--
-- SENSITIVE IS THE POINT. The class's `categories_allowed` is Physical and
-- Super, which is what the STARTING four are drawn from; the per-level pick
-- adds Sensitive. A grant's categories REPLACE the class's rather than
-- narrowing them, so naming all three here is the book granting an exception -
-- exactly the shape of the Mystic's Super grants at levels 4 and 8.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  categories_allowed: ["Physical", "Super"]',
      '  categories_allowed: ["Physical", "Super"]' || char(10) ||
      '  powers_schedule:' || char(10) ||
      '    - { level: 2, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 3, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 4, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 5, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 6, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 7, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 8, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 9, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 10, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 11, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 12, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 13, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 14, count: 1, categories: ["Physical", "Sensitive", "Super"] }' || char(10) ||
      '    - { level: 15, count: 1, categories: ["Physical", "Sensitive", "Super"] }'
    )
WHERE class_id = 'delphi-juicer'
  AND instr(markdown, '  categories_allowed: ["Physical", "Super"]') > 0
  AND instr(markdown, 'powers_schedule:') = 0;

SELECT class_id,
       instr(markdown, '  powers_schedule:') > 0 AS has_schedule,
       instr(markdown, 'level: 2, count: 1, categories: ["Physical", "Sensitive", "Super"] }') > 0 AS has_head,
       instr(markdown, 'level: 15, count: 1, categories: ["Physical", "Sensitive", "Super"] }') > 0 AS has_tail
FROM imported_classes
WHERE class_id = 'delphi-juicer';

-- ---------------------------------------------------------------------------
-- The notes that said this was prose. Both are now false, and a note claiming
-- a limitation that has been lifted is worse than no note: the next reader
-- takes it as a reason not to look.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      'The five-a-level progression from level two - two from the lesser categories plus three from Super - is still prose, and is now the larger gap in this class: powers_schedule carries per-entry categories and several entries may share a level, so it is expressible and simply not written.',
      'The five-a-level progression from level two - two from the lesser categories plus three from Super - is DATA now: powers_schedule holds two entries at every level from 2 to 15, the three lesser categories in the first slot and Super in the second, because a grant carries its own restriction and one open count of five would let a Mind Mage take five Super powers a level. The level-two Super entry carries the book''s third-level limitation as its grant note, which is the only place the app can state it: a schedule entry gates by category, not by power name.'
    )
WHERE class_id = 'mind-mage'
  AND instr(markdown, 'is still prose, and is now the larger gap in this class') > 0;

UPDATE imported_classes
SET markdown = replace(
      markdown,
      'The per-level pick (one from Physical, Sensitive or Super each level after the first) is still prose, but NOT because the app cannot hold it: a powers_schedule entry carries its own categories, and has since the mystic. It simply has not been written.',
      'The per-level pick (one from Physical, Sensitive or Super each level after the first) is DATA now: powers_schedule holds one entry at every level from 2 to 15, each naming Physical, Sensitive and Super. Sensitive is a category the starting block does not allow, and a grant''s categories REPLACE the class''s rather than narrowing them, so the entry is the book granting an exception - the shape the Mystic''s Super grants already use. Juicer Uprising has no OCR cache on this machine, so the schedule was written from the class''s own two records of the rule - the Master Psionic ability and this note - rather than re-read off the page.'
    )
WHERE class_id = 'delphi-juicer'
  AND instr(markdown, 'is still prose, but NOT because the app cannot hold it') > 0;

-- The two ability descriptions that state the rule in the book's words. They
-- stay as they are; each gains a sentence saying the app now offers it, so the
-- prose does not read as the only place the rule lives. Same treatment the
-- Mind Mage's starting-powers paragraph got in zz-starting-power-splits.sql.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      'five new powers a level, which is what makes this the most powerful psychic class in the book."',
      'five new powers a level, which is what makes this the most powerful psychic class in the book. The psionics block states this as a powers_schedule now - two entries at every level from 2 to 15 - so the Advancement step offers the picks rather than leaving them to be read here."'
    )
WHERE class_id = 'mind-mage'
  AND instr(markdown, 'five new powers a level, which is what makes this the most powerful psychic class in the book."') > 0;

UPDATE imported_classes
SET markdown = replace(
      markdown,
      'From level two onward he selects one power per level from the Physical, Sensitive or Super categories."',
      'From level two onward he selects one power per level from the Physical, Sensitive or Super categories. The psionics block states this as a powers_schedule now - one entry at every level from 2 to 15 - so the Advancement step offers the pick rather than leaving it to be read here."'
    )
WHERE class_id = 'delphi-juicer'
  AND instr(markdown, 'From level two onward he selects one power per level from the Physical, Sensitive or Super categories."') > 0;

SELECT class_id,
       instr(markdown, 'is still prose') = 0 AS note_corrected,
       instr(markdown, 'is DATA now: powers_schedule holds') > 0 AS note_says_data,
       instr(markdown, 'so the Advancement step offers') > 0 AS ability_updated
FROM imported_classes
WHERE class_id IN ('mind-mage', 'delphi-juicer')
ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('zzz-fix-psionic-powers-per-level.sql');
