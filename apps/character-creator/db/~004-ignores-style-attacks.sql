-- Four classes whose own attacks stand and whose Hand to Hand style adds none:
-- `ignores_style_attacks: true`, read by bonusesFromSkills() in js/parser.js.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~004-ignores-style-attacks.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~004-ignores-style-attacks.sql
--
-- WHY. A class's attacks_base and a style's now take the higher rather than
-- the sum (~003-class-attacks-are-bonuses.sql), which still let a style's
-- attacks in wherever the style's number was the bigger one, and its per-level
-- +1s on top. Two kinds of class say it should not:
--
--   Pneuma-Biform Dolphin       Underseas p.52  "Note: Do not add the melee
--   Pneuma-Biform Killer Whale  Underseas p.54   round attacks from the hand
--   Pneuma-Biform Whale         Underseas p.55   to hand combat skill, only use
--                                                it for bonuses and fighting
--                                                techniques (kicks, flips, etc.)"
--       Each already said so in a restriction the app could not act on. The
--       stored count is the book's cetacean-form one (3, 5, 2), as before.
--
--   Holy Terror                 Wormwood p.67   "Three to start and add one at
--                                                levels four, six, eight, eleven,
--                                                and thirteen", beside a granted
--                                                Hand to Hand: Expert.
--       The book does not say "do not add" in words. It states a whole attack
--       schedule of its own, which is stored as attacks_base 3 plus at_level,
--       and adding Expert's +1s at 4, 9 and 14 on top would count two
--       schedules. Nate's call, 2026-09-25.
--
-- A search of every cached book's text for the Underseas wording and its
-- variants (2026-09-25) found these three pages and nothing else about a
-- class; the other hits were telekinesis. Books that are not cached were not
-- searched.
--
-- Filename order is execution order: `~004` sorts after ~003 and every z tier.
-- Each UPDATE is guarded on the flag's absence, so a re-run changes nothing.
-- The flag goes on its own line before `bonuses:`, which each of the four
-- carries exactly once at the start of a line (measured --remote, 2026-09-25).

UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || 'bonuses:' || char(10),
    char(10) || 'ignores_style_attacks: true' || char(10) || 'bonuses:' || char(10)),
    updated_at = datetime('now')
 WHERE class_id IN ('holy-terror', 'pneuma-biform-dolphin', 'pneuma-biform-killer-whale', 'pneuma-biform-whale')
   AND instr(markdown, 'ignores_style_attacks') = 0;

SELECT 'all four carry the flag, once' AS assertion,
       count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('holy-terror', 'pneuma-biform-dolphin', 'pneuma-biform-killer-whale', 'pneuma-biform-whale')
   AND instr(markdown, char(10) || 'ignores_style_attacks: true' || char(10) || 'bonuses:') > 0
   AND length(markdown) - length(replace(markdown, 'ignores_style_attacks', '')) = 21;

SELECT 'no other class carries it' AS assertion,
       count(*) AS got, 4 AS want
  FROM imported_classes WHERE instr(markdown, 'ignores_style_attacks') > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('~004-ignores-style-attacks.sql');
