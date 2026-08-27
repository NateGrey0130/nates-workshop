-- The two Elemental Fusionists' spell lists, as real magic blocks. Rifts
-- Ultimate Edition printed p.101 (rue cache p104; the rue cache runs printed+3).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-rue-elemental-fusionist-spells.sql
--
-- CLASS-AUDIT.md S1, "the biggest single mechanic currently held in prose".
-- Both classes said "Elemental spells are not yet in the spell catalog, so
-- record picks by hand". They ARE in the catalog - add-elemental-spells.sql
-- landed them under their element prefixes - so the whole mechanic can be data.
--
-- The book, read from the cache:
--
--   "3. Elemental Spell Magic: In addition to the character's fusion of power,
--   they intuitively know a handful of Elemental Magic spells. Select one from
--   the following list at first level and one for each subsequent level."
--
-- so `spells_starting: 1` bounded by `spells_from`, and a `spells_schedule`
-- entry at every level from 2 to 15 drawing `from_list` - the shifter's shape,
-- with the starting pick bounded too.
--
-- `spells_from` IS NEW, and S1 could not have been done without it. The
-- creation builder took one count and one gate and had no way to name a list
-- for a spell pick, though psionics has had `powers_from` for that since the
-- burster. Written as `spells_starting: 1` alone, a first-level Fusionist could
-- have picked ANY of the catalog's five hundred spells, including eighth-level
-- warlock magic - a loadout strictly worse than the prose it replaced. See
-- `startingGroups` in js/leveling.js.
--
-- EVERY NAME WAS CHECKED ON ITS PRINTED P.P.E., not just on its name. All 36
-- book names resolve and all 36 costs match their catalog row, which is the
-- check that catches a mapping that reads fine and is wrong. Two the name alone
-- would have missed: the book's "Thunder Clap" is stored as `Air: Thunderclap`,
-- and the book prints one undivided list per orientation while the catalog
-- files each spell under its own element (Chameleon is Earth, Create Light is
-- Air).
--
-- ONE NAME IS AMBIGUOUS AND IS DELIBERATELY LEFT SO. The Fire/Water list prints
-- "Cloud of Steam (10)" with no element, and the catalog holds two rows of that
-- name BOTH at 10 P.P.E.: `Fire: Cloud of Steam` (level 4) and
-- `Water: Cloud of Steam` (level 1). Nothing in the entry separates them, and
-- the element counts do not either. Both are on the list. A pick costs one slot
-- whichever is taken, so offering both forbids nothing the book grants and
-- invents no spell it does not name - and guessing would have buried a coin
-- flip in the data where nothing would ever flag it.
--
-- Filename sort: > fix-rue-attr-reqs-and-ranges.sql, fix-disease-saves.sql and
-- fix-language-picks.sql, the other writers of these two classes.
-- fix-rue-pool-attribute-terms.sql sorts later but rewrites only the `ppe_base`
-- line, and zz-rifts-occ-groups.sql only the header; neither touches a span
-- below. No fix-pre-rue-class-audit entry exists for either class.
--
-- Every statement is guarded on the old text; re-running is a no-op.


-- The Earth/Air magic block, spliced between starting_money and bonuses.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'starting_money: "2d4x100"' || char(10) ||
         'bonuses:',
         'starting_money: "2d4x100"' || char(10) ||
         'magic:' || char(10) ||
         '  type: "spell"' || char(10) ||
         '  # One at level one, from the orientation list, and one more at every level' || char(10) ||
         '  # after it. RUE printed 101, item 3: "Select one from the following list at' || char(10) ||
         '  # first level and one for each subsequent level."' || char(10) ||
         '  spells_starting: 1' || char(10) ||
         '  spells_from: ["Air: Breathe Without Air", "Earth: Chameleon", "Air: Change Wind Direction", "Air: Create Light", "Air: Create Mild Wind", "Earth: Dig", "Air: Distant Voice", "Air: Electric Arc", "Earth: Dust Storm", "Earth: Identify Minerals", "Earth: Identify Plants", "Earth: Mend Stone", "Earth: Sand Storm", "Air: Stop Wind", "Air: Thunderclap", "Earth: Throwing Stones", "Earth: Travel Through Walls", "Air: Walk the Wind"]' || char(10) ||
         '  spells_per_level_from: ["Air: Breathe Without Air", "Earth: Chameleon", "Air: Change Wind Direction", "Air: Create Light", "Air: Create Mild Wind", "Earth: Dig", "Air: Distant Voice", "Air: Electric Arc", "Earth: Dust Storm", "Earth: Identify Minerals", "Earth: Identify Plants", "Earth: Mend Stone", "Earth: Sand Storm", "Air: Stop Wind", "Air: Thunderclap", "Earth: Throwing Stones", "Earth: Travel Through Walls", "Air: Walk the Wind"]' || char(10) ||
         '  spells_schedule:' || char(10) ||
         '    - { level: 2, count: 1, from_list: true }' || char(10) ||
         '    - { level: 3, count: 1, from_list: true }' || char(10) ||
         '    - { level: 4, count: 1, from_list: true }' || char(10) ||
         '    - { level: 5, count: 1, from_list: true }' || char(10) ||
         '    - { level: 6, count: 1, from_list: true }' || char(10) ||
         '    - { level: 7, count: 1, from_list: true }' || char(10) ||
         '    - { level: 8, count: 1, from_list: true }' || char(10) ||
         '    - { level: 9, count: 1, from_list: true }' || char(10) ||
         '    - { level: 10, count: 1, from_list: true }' || char(10) ||
         '    - { level: 11, count: 1, from_list: true }' || char(10) ||
         '    - { level: 12, count: 1, from_list: true }' || char(10) ||
         '    - { level: 13, count: 1, from_list: true }' || char(10) ||
         '    - { level: 14, count: 1, from_list: true }' || char(10) ||
         '    - { level: 15, count: 1, from_list: true }' || char(10) ||
         'bonuses:'),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-earth-air'
   AND instr(markdown, char(10) || 'magic:' || char(10)) = 0;


-- The Fire/Water magic block, spliced between starting_money and bonuses.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'starting_money: "2d4x100"' || char(10) ||
         'bonuses:',
         'starting_money: "2d4x100"' || char(10) ||
         'magic:' || char(10) ||
         '  type: "spell"' || char(10) ||
         '  # One at level one, from the orientation list, and one more at every level' || char(10) ||
         '  # after it. RUE printed 101, item 3: "Select one from the following list at' || char(10) ||
         '  # first level and one for each subsequent level."' || char(10) ||
         '  spells_starting: 1' || char(10) ||
         '  spells_from: ["Fire: Blinding Flash", "Water: Breathe Underwater", "Fire: Cloud of Ash", "Fire: Cloud of Steam", "Water: Cloud of Steam", "Water: Dowsing", "Water: Float on Water", "Water: Fog of Fear", "Water: Frostblade", "Fire: Extinguish Fire", "Fire: Fiery Touch", "Fire: Fire Bolt", "Fire: Globe of Daylight", "Fire: Impervious to Fire", "Fire: Nightvision", "Fire: Resist Cold", "Water: Sense Direction Underwater", "Fire: Spontaneous Combustion", "Water: Walk the Waves"]' || char(10) ||
         '  spells_per_level_from: ["Fire: Blinding Flash", "Water: Breathe Underwater", "Fire: Cloud of Ash", "Fire: Cloud of Steam", "Water: Cloud of Steam", "Water: Dowsing", "Water: Float on Water", "Water: Fog of Fear", "Water: Frostblade", "Fire: Extinguish Fire", "Fire: Fiery Touch", "Fire: Fire Bolt", "Fire: Globe of Daylight", "Fire: Impervious to Fire", "Fire: Nightvision", "Fire: Resist Cold", "Water: Sense Direction Underwater", "Fire: Spontaneous Combustion", "Water: Walk the Waves"]' || char(10) ||
         '  spells_schedule:' || char(10) ||
         '    - { level: 2, count: 1, from_list: true }' || char(10) ||
         '    - { level: 3, count: 1, from_list: true }' || char(10) ||
         '    - { level: 4, count: 1, from_list: true }' || char(10) ||
         '    - { level: 5, count: 1, from_list: true }' || char(10) ||
         '    - { level: 6, count: 1, from_list: true }' || char(10) ||
         '    - { level: 7, count: 1, from_list: true }' || char(10) ||
         '    - { level: 8, count: 1, from_list: true }' || char(10) ||
         '    - { level: 9, count: 1, from_list: true }' || char(10) ||
         '    - { level: 10, count: 1, from_list: true }' || char(10) ||
         '    - { level: 11, count: 1, from_list: true }' || char(10) ||
         '    - { level: 12, count: 1, from_list: true }' || char(10) ||
         '    - { level: 13, count: 1, from_list: true }' || char(10) ||
         '    - { level: 14, count: 1, from_list: true }' || char(10) ||
         '    - { level: 15, count: 1, from_list: true }' || char(10) ||
         'bonuses:'),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-fire-water'
   AND instr(markdown, char(10) || 'magic:' || char(10)) = 0;


-- The ability description, identical in both classes.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '    description: "Intuitively knows a handful of Elemental Magic spells from the character''s own orientation list - select one at first level and one per subsequent level. The lists (with P.P.E. costs) are in GM Notes; Elemental spells are not yet in the spell catalog, so record picks by hand."',
         '    description: "Intuitively knows a handful of Elemental Magic spells from the character''s own orientation list - select one at first level and one per subsequent level. The list is a real magic block now: the picker offers exactly those spells at level one and one more at every level after, and the P.P.E. costs come from the catalog rather than from this paragraph. The book''s own printing of the two lists is kept in GM Notes."'),
       updated_at = datetime('now')
 WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water')
   AND instr(markdown, 'not yet in the spell catalog') > 0;


-- The Earth/Air extraction note.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - Elemental Magic spells are not in the spell catalog; the class''s spell' || char(10) ||
         '    lists live in GM Notes and picks are recorded by hand.',
         '  - Elemental Magic spells ARE in the spell catalog - add-elemental-spells.sql' || char(10) ||
         '    landed them under their element prefixes - so the orientation list is a real' || char(10) ||
         '    magic block rather than prose (class audit S1): spells_from bounds the' || char(10) ||
         '    level-one pick and a spells_schedule entry at every level from 2 to 15 draws' || char(10) ||
         '    from the same list. All eighteen names resolve AND every printed P.P.E.' || char(10) ||
         '    matches its catalog row, which is the check that catches a mapping reading' || char(10) ||
         '    fine and being wrong. The book prints one undivided list per orientation;' || char(10) ||
         '    the catalog files each spell under its own element.' || char(10) ||
         '    One name needed the catalog spelling rather than the book''s: "Thunder Clap"' || char(10) ||
         '    is stored as Air: Thunderclap.'),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-earth-air'
   AND instr(markdown, 'are not in the spell catalog') > 0;


-- The Fire/Water extraction note, which carries the ambiguity.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - Elemental Magic spells are not in the spell catalog; the class''s spell' || char(10) ||
         '    lists live in GM Notes and picks are recorded by hand.',
         '  - Elemental Magic spells ARE in the spell catalog - add-elemental-spells.sql' || char(10) ||
         '    landed them under their element prefixes - so the orientation list is a real' || char(10) ||
         '    magic block rather than prose (class audit S1): spells_from bounds the' || char(10) ||
         '    level-one pick and a spells_schedule entry at every level from 2 to 15 draws' || char(10) ||
         '    from the same list. All eighteen names resolve AND every printed P.P.E.' || char(10) ||
         '    matches its catalog row, which is the check that catches a mapping reading' || char(10) ||
         '    fine and being wrong. The book prints one undivided list per orientation;' || char(10) ||
         '    the catalog files each spell under its own element.' || char(10) ||
         '    ONE NAME IS AMBIGUOUS AND IS LEFT SO ON PURPOSE. The book prints "Cloud of' || char(10) ||
         '    Steam (10)" with no element, and the catalog holds two rows of that name both' || char(10) ||
         '    at 10 P.P.E. - Fire: Cloud of Steam (level 4) and Water: Cloud of Steam' || char(10) ||
         '    (level 1). Nothing in the entry separates them and the element counts do not' || char(10) ||
         '    either, so BOTH are on the list. A pick costs one slot whichever is taken, so' || char(10) ||
         '    offering both forbids nothing the book grants and invents no spell it does' || char(10) ||
         '    not name; guessing would have buried a coin flip where nothing flags it.'),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-fire-water'
   AND instr(markdown, 'are not in the spell catalog') > 0;


-- Readback. Expected: magic 2, starting 2, sched 28, note_gone 0, ambiguous 1,
-- has_cr 0. `sched` is 14 levels x 2 classes; `ambiguous` proves the Fire/Water
-- list kept BOTH Cloud of Steam rows, which is the one judgement call here and
-- the one a later tidy-up would most plausibly "fix" by accident.
SELECT sum(instr(markdown, char(10) || 'magic:' || char(10)) > 0)            AS magic,
       sum(instr(markdown, '  spells_starting: 1') > 0)                      AS starting,
       sum((length(markdown) - length(replace(markdown, ', count: 1, from_list: true }', ''))) / length(', count: 1, from_list: true }')) AS sched,
       sum(instr(markdown, 'are not in the spell catalog') > 0)              AS note_gone,
       sum(instr(markdown, '"Fire: Cloud of Steam", "Water: Cloud of Steam"') > 0) AS ambiguous,
       sum(instr(markdown, char(13)) > 0)                                    AS has_cr
  FROM imported_classes
 WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water');

-- Records this run. Every statement guards itself, so this is safe to re-run.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-elemental-fusionist-spells.sql');
