-- The Ley Line Walker's Perception schedule, and the note that said it had
-- nowhere to go. Rifts Ultimate Edition, O.C.C. Bonuses (#13).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-rue-ley-line-walker-perception.sql
--
-- CLASS-AUDIT.md S3, the last of its five classes. F8 gave the other four
-- their perception key and rewrote their notes; the walker was left out of
-- that script because its bonus is a SCHEDULE rather than a flat number, and
-- because half of its note is still true. Both halves are settled here.
--
-- The page reads, verbatim from the cache (rue p119, the block ending
-- "Ley Line Walker O.C.C. Stats"):
--
--   "+3 to save vs curses, +1 to save vs magic at levels three, six, nine,
--   eleven and fourteen, +1 to spell strength (the number others must save
--   against when you cast a spell) at levels 3, 7, 10, and 13. +1 on
--   Perception Rolls at levels 2, 5, 7, 10, and 13; double when on a ley
--   line."
--
-- So: five at_level entries carrying combat.perception, and NO base combat
-- block. The schedule starts at level 2, and a level-1 walker gets nothing -
-- which is the one way this differs from the mystic's shape that F8 modelled,
-- where the book grants the first point at level 1 and the base block holds
-- it. Writing a base `perception: 1` here would hand every walker a point the
-- book never gives them.
--
-- The "double when on a ley line" half stays prose. `bonuses` is applied
-- unconditionally, so a conditional number in it is silently wrong rather
-- than approximately right.
--
-- The note rewrite corrects a second, smaller claim in the same paragraph
-- while it is open. The paragraph says "+3 to save vs curses ... is carried
-- as bonuses.at_level entries" - it is not, and has not been since
-- fix-ley-line-walker-rue-bonuses.sql established that the leveled save is
-- the MAGIC save and curses is flat. The data has been right and this
-- sentence wrong ever since; leaving it while rewriting the sentence beside
-- it would be choosing not to look.
--
-- Filename sort: fix-rue-ley-line-walker-perception > fix-pre-rue-class-audit,
-- which rewrites this class's WHOLE markdown and is the last writer of both
-- spans below, and > fix-ley-line-walker-rue-bonuses, which rewrites the
-- at_level block this appends to. Named without the `fix-ley-` prefix for
-- exactly that reason: `fix-ley-line-walker-perception.sql` sorts BEFORE both
-- of them, and on a clean rebuild would find neither anchor and do nothing.
--
-- Both statements are guarded on text that the other statement does not
-- touch, so re-running the file is a no-op and the two are order-independent.

-- 1. The schedule. Appended after the existing at_level entries rather than
--    interleaved by level: classBonuses folds entries sharing a level and
--    reads them in any order, so ordering is cosmetic, and appending is the
--    shape fix-perception-bonuses.sql already used for the mystic.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }',
         '    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }' || char(10) ||
         '    - { level: 2, combat: { perception: 1 } }' || char(10) ||
         '    - { level: 5, combat: { perception: 1 } }' || char(10) ||
         '    - { level: 7, combat: { perception: 1 } }' || char(10) ||
         '    - { level: 10, combat: { perception: 1 } }' || char(10) ||
         '    - { level: 13, combat: { perception: 1 } }'),
       updated_at = datetime('now')
 WHERE class_id = 'ley-line-walker'
   AND instr(markdown, '    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }') > 0
   AND instr(markdown, '    - { level: 2, combat: { perception: 1 } }') = 0;

-- 2. The note. Matched across its line wraps: the stored text breaks
--    mid-phrase in four places, and a grep for any one of its sentences
--    returns nothing, which is how it survived earlier sweeps.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - The "+3 to save vs curses" at levels three, nine, eleven and fourteen is' || char(10) ||
         '    carried as bonuses.at_level entries, which accumulate as the character' || char(10) ||
         '    reaches each level. "+1 to spell strength" at levels 3, 7, 10 and 13 and' || char(10) ||
         '    "+1 on Perception Rolls at levels 2, 5, 7, 10, and 13; double when on a' || char(10) ||
         '    ley line" stay recorded here: neither spell strength nor perception is a' || char(10) ||
         '    derived stat yet, so there is still no key for a number to land on.',
         '  - The "+3 to save vs curses" is FLAT and lives in bonuses.saves; the' || char(10) ||
         '    leveled save is "+1 to save vs magic at levels three, six, nine, eleven' || char(10) ||
         '    and fourteen", carried as bonuses.at_level entries that accumulate as the' || char(10) ||
         '    character reaches each level. "+1 on Perception Rolls at levels 2, 5, 7,' || char(10) ||
         '    10, and 13" now lands the same way, as five at_level combat.perception' || char(10) ||
         '    entries (class audit S3). The schedule starts at level 2, so there is no' || char(10) ||
         '    base combat block and a level-1 walker has no Perception bonus. The' || char(10) ||
         '    "double when on a ley line" half stays prose, because bonuses are applied' || char(10) ||
         '    unconditionally. "+1 to spell strength" at levels 3, 7, 10 and 13 stays' || char(10) ||
         '    recorded here too: spell strength is still not a derived stat, so there' || char(10) ||
         '    is no key for that number to land on.'),
       updated_at = datetime('now')
 WHERE class_id = 'ley-line-walker'
   AND instr(markdown, 'neither spell strength nor perception is a') > 0;

-- Readback. Expected: sched 5, stale_note_gone 1, new_note 1, no_base_combat 1,
-- saves_intact 1, has_cr 0.
--
-- `no_base_combat` is the one worth explaining: it looks for a two-space
-- indented `combat:` at the head of a line, which is what a base block would
-- be. The at_level entries above contain the string "combat: {" too, so a
-- bare instr for that would pass whether or not the mistake was made.
SELECT (instr(markdown, '    - { level: 2, combat: { perception: 1 } }') > 0)
     + (instr(markdown, '    - { level: 5, combat: { perception: 1 } }') > 0)
     + (instr(markdown, '    - { level: 7, combat: { perception: 1 } }') > 0)
     + (instr(markdown, '    - { level: 10, combat: { perception: 1 } }') > 0)
     + (instr(markdown, '    - { level: 13, combat: { perception: 1 } }') > 0)   AS sched,
       (instr(markdown, 'neither spell strength nor perception is a') = 0)       AS stale_note_gone,
       (instr(markdown, 'as five at_level combat.perception') > 0)               AS new_note,
       (instr(markdown, char(10) || '  combat:') = 0)                            AS no_base_combat,
       (instr(markdown, 'mind_control: 2, curses: 3 }') > 0)                     AS saves_intact,
       (instr(markdown, char(13)) > 0)                                           AS has_cr
  FROM imported_classes WHERE class_id = 'ley-line-walker';

-- Records this run. Both statements guard themselves, so this is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-ley-line-walker-perception.sql');
