-- What the Palladium Fantasy main book prints for the Warlock, where it
-- differs from the stored Rifts Book of Magic version.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- a row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/record-warlock-palladium-deltas.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/record-warlock-palladium-deltas.sql
--
-- NO STORED NUMBER CHANGES HERE. Same rule as add-palladium-variants.sql: the
-- later book wins - Rifts Ultimate Edition over the Rifts Book of Magic, either
-- over the Palladium Fantasy main book (1983). What lands is the LOSING
-- version, recorded rather than discarded, because a GM running Palladium
-- Fantasy wants to know the book at their elbow says 150 gold where the sheet
-- says 2D6x1000 credits.
--
-- WHY THERE IS NO SECOND WARLOCK CLASS. The Palladium Fantasy Warlock and the
-- Book of Magic Warlock are the same class in two editions, and they agree on
-- everything that matters mechanically: I.Q. 6 / M.E. 10 for one elemental
-- force and I.Q. 12 / M.E. 14 for two, 2D4x10+20 P.P.E. rising to 2D4x10+40 for
-- two forces, +2D6 per level, three spells per level of experience, +2 to save
-- vs horror factor, +1 vs magic, +1 vs possession. The stored class already
-- carries both one-force and two-forces variants with exactly those numbers.
--
-- What differs is Rifts furniture - credits instead of gold, M.D.C. body armour
-- instead of soft leather, Pilot Hover Craft, a modern W.P., and Electrical,
-- Mechanical, Pilot and Pilot Related in the related-skill list. Adding a
-- near-duplicate class to carry that would put two rows called Warlock in the
-- picker to express a difference in shopping list.
--
-- THE APPEND IS GUARDED on the section not already being present, so this is
-- safe to run twice. It also has to sort AFTER the two files that write this
-- class's markdown - add-warlock-class.sql and fix-phantom-choice-options.sql -
-- or a rebuild would append the section and then overwrite it. 'record-' lands
-- after both; that ordering is the whole reason for the prefix.

UPDATE imported_classes
   SET markdown = markdown || char(10) ||
'## Palladium Fantasy' || char(10) || char(10) ||
'The Palladium Fantasy main book (printed pp.108-111) has this class first, and' || char(10) ||
'the numbers above are the later Rifts Book of Magic printing. They agree on' || char(10) ||
'nearly everything mechanical: the same attribute requirements for one and two' || char(10) ||
'elemental forces, the same 2D4x10+20 and 2D4x10+40 P.P.E. with +2D6 per level,' || char(10) ||
'the same three spells per level of experience, and the same saving throw' || char(10) ||
'bonuses. Where the older book differs:' || char(10) || char(10) ||
'- **Money is 150 gold**, not 2D6x1000 credits.' || char(10) ||
'- **Armour is soft leather** (A.R. 10, 20 S.D.C.), not a light M.D.C. suit.' || char(10) ||
'- **Weapons** are a knife and one more of choice, basic S.D.C. and good' || char(10) ||
'  quality. Favourites are iron or wood staves, morning stars, maces, swords' || char(10) ||
'  and cross bows.' || char(10) ||
'- **W.P.: two of choice**, both ancient. The Rifts entry splits them into one' || char(10) ||
'  ancient and one modern.' || char(10) ||
'- **No Pilot Hover Craft.** The Palladium O.C.C. skill list has no pilot skill' || char(10) ||
'  at all.' || char(10) ||
'- **Related skills** are the same count of eight, but from a shorter list: no' || char(10) ||
'  Electrical, Mechanical, Pilot or Pilot Related. Communications any, Domestic' || char(10) ||
'  +10%, Espionage limited to Disguise, Escape Artist and Intelligence (+5%),' || char(10) ||
'  Horsemanship General or Exotic only, Medical any, Military none, Physical any' || char(10) ||
'  except Acrobatics, Gymnastics, Boxing and Wrestling, Rogue any, Science +10%,' || char(10) ||
'  Scholar/Technical +10%, W.P. any except the Lance and Long Bow, Wilderness' || char(10) ||
'  any (+5%). One extra skill at levels three, six, nine and twelve.' || char(10) ||
'- **Secondary skills** are three at level one, plus two at levels two, five,' || char(10) ||
'  seven, ten and thirteen.' || char(10) ||
'- **Standard equipment** is two sets of clothing, an appropriately coloured' || char(10) ||
'  hooded robe, bedroll, backpack, 1D4 small sacks, one large sack, a water' || char(10) ||
'  skin, flint and tinder box, 1D4 candles, a wooden cross, a small mirror, 1D4' || char(10) ||
'  sticks of charcoal, and 1D4 items representing the warlock''s elemental' || char(10) ||
'  symbol.' || char(10) ||
'- **Spell strength** rises +1 at levels three, six, ten and fourteen, and the' || char(10) ||
'  horror factor bonus is **+6 against elemental beings** specifically.' || char(10) ||
'- **Speak Elemental** at 92%: every warlock speaks and understands the' || char(10) ||
'  elementals'' language, a combination of telepathy and speech that is' || char(10) ||
'  incomprehensible to anyone else. Elementals have no written language.' || char(10) ||
'- The warlock also knows the four elemental power words - Cherubot-kyn (air),' || char(10) ||
'  Ariel-Rapere-kyn (earth), Seraph-mytyn (fire), Tharsis-mycn (water) - and' || char(10) ||
'  yin, the linking word, plus the mystic symbols of the four elements and the' || char(10) ||
'  six stone symbols. See the Diabolist.' || char(10) ||
'- **A warlock cannot learn spell magic of any other kind.** The power is given' || char(10) ||
'  by a supernatural force rather than learned, and the elemental force, once' || char(10) ||
'  chosen, cannot be changed.' || char(10)
 WHERE class_id = 'warlock'
   AND instr(markdown, '## Palladium Fantasy') = 0;

-- ---- read the result back rather than trusting the exit code ---------------
SELECT class_id, name, system, length(markdown) AS md_bytes,
       instr(markdown, '## Palladium Fantasy') > 0 AS has_section
  FROM imported_classes WHERE class_id = 'warlock';
-- Expect 1: the section is present exactly once, so a second run added nothing.
SELECT (length(markdown) - length(replace(markdown, '## Palladium Fantasy', ''))) /
       length('## Palladium Fantasy') AS section_count
  FROM imported_classes WHERE class_id = 'warlock';
-- Expect the stored Rifts numbers, untouched.
SELECT count(*) AS still_rifts FROM imported_classes
 WHERE class_id = 'warlock' AND system = 'rifts'
   AND instr(markdown, '2d6x1000') > 0;

INSERT INTO data_script_runs (filename) VALUES ('record-warlock-palladium-deltas.sql');
