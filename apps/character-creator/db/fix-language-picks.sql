-- Every "languages of choice" pick now comes from languages.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-language-picks.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-language-picks.sql
--
-- 33 classes: 25 via Communications, 7 via Technical.
--
--   body-fixer                     pick 2, +20%   (was Communications)
--   burster                        pick 1, +30%   (was Communications)
--   chiang-ku-dragon               pick 3, +30%   (was Technical)
--   city-rat                       pick 1, +10%   (was Communications)
--   crazy                          pick 1, +15%   (was Communications)
--   cyber-doc                      pick 1, +20%   (was Communications)
--   cyber-knight                   pick 2, +30%   (was Technical)
--   dog-boy                        pick 1, +5%   (was Communications)
--   elemental-fusionist-earth-air  pick 2, +15%   (was Communications)
--   elemental-fusionist-fire-water pick 2, +15%   (was Communications)
--   glitter-boy                    pick 2, +20%   (was Technical)
--   headhunter-techno-warrior      pick 3, +20%   (was Communications)
--   juicer                         pick 2, +10%   (was Communications)
--   knight                         pick 2, +15%   (was Technical)
--   ley-line-rifter                pick 2, +20%   (was Communications)
--   ley-line-walker                pick 2, +20%   (was Technical)
--   merc-soldier                   pick 1, +10%   (was Communications)
--   mind-melter                    pick 2, +30%   (was Technical)
--   mystic                         pick 3, +15%   (was Communications)
--   operator                       pick 1, +20%   (was Communications)
--   priest-of-light                pick 2, +20%   (was Technical)
--   psi-stalker                    pick 1, +20%   (was Communications)
--   robot-pilot                    pick 1, +20%   (was Communications)
--   rogue-scholar                  pick 2, +25%   (was Communications)
--   rogue-scientist                pick 3, +20%   (was Communications)
--   shifter                        pick 2, +15%   (was Communications)
--   stone-master                   pick 3, +15%   (was Communications)
--   techno-wizard                  pick 2, +15%   (was Communications)
--   vagabond                       pick 2, +15%   (was Communications)
--   warlock                        pick 2, +10%   (was Communications)
--   wild-psi-stalker               pick 1, +25%   (was Communications)
--   wilderness-scout               pick 2, +15%   (was Communications)
--   diabolist                      pick 3, +20%   (was two groups, 2 + 1)
--
-- WHAT WAS WRONG. Every one of these says "two languages of choice" - one,
-- three, whatever the book gives - and every one was written as a whole
-- CATEGORY, because the catalog has no row per language and the workaround
-- looked like offering the category the languages live in.
--
-- The Technical seven were merely too wide: Technical is about sixty skills, so
-- the pick was spendable on Gemology or Masonry at the class's language bonus.
-- Nobody did that, but two Priests of Light in production took
-- `Language: Mongolian` - a Rifts-world language, on a Palladium class, offered
-- because it happens to sit in Technical.
--
-- THE COMMUNICATIONS TWENTY-FIVE ARE WORSE, and this is the part worth reading
-- twice. `Language: Other` is filed under TECHNICAL. The only language row in
-- Communications is `Language: All (magical)`, which is a magical ability and
-- not a language anybody learns. So those twenty-five classes offered
-- seventeen Communications skills for a language pick and NOT ONE OF THEM WAS
-- A LANGUAGE. A Ley Line Rifter's two languages could only be spent on Radio:
-- Basic, Cryptography or Surveillance.
--
-- THE REAL DEFECT UNDERNEATH. "Language: Other" is the catalog's escape hatch:
-- one row standing in for every language the books never print, taken ONCE PER
-- LANGUAGE and stored under the language's own name. The wizard has always
-- known that on the related and secondary pickers, where the row prompts
-- "Which language?" instead of toggling. It did NOT know it inside an
-- occ_skills choice group, which is a separate control - so there the same row
-- was a plain checkbox, and ticking it gave the character a placeholder for a
-- name. Both Priests of Light are carrying a skill called, literally,
-- "Language: Other". The app change alongside this file teaches the group
-- control the same rule, and teaches resolveSkill to price a named language
-- off the Other row rather than saving it at 0%.
--
-- NO NUMBER CHANGES IN THIRTY OF THE THIRTY-TWO. Each entry keeps its own
-- `choose`, `bonus` and `per_level` exactly as the class already stated them,
-- and each keeps the book's own wording in its note; only the pool the picks
-- come from changes.
--
-- TWO DO CHANGE A NUMBER, because the same line carried a second defect and
-- rewriting it while leaving that in place would be worse. Both are the printed
-- percentage read wrong, and in both the class's own note records what the book
-- says - so the note is the citation:
--
--   cyber-doc: base 20 + per_level 0  ->  bonus 20 (50% +5/lvl becomes 70%)
--   vagabond: no bonus at all  ->  bonus 15 (the note said so all along)
--
-- Every sibling class writes this as `bonus`; these two are the outliers.
-- Existing characters keep every skill they hold - this narrows what may be
-- CHOSEN, not what has been.
--
-- THE DIABOLIST IS THE THIRTY-THIRD, and it is the same defect wearing the
-- opposite disguise. Its three languages were written as TWO groups, 2 + 1,
-- with a note reading "Split into two groups because a choice group cannot ask
-- for more options than it lists, and Language: Other is the one row that may
-- be taken repeatedly." That is precisely the check the parser change removes,
-- so the split and its explanation both go and the three languages are one
-- group again.
--
-- ONE ALTERNATIVE THE SHAPE STILL CANNOT HOLD, stated in its own note rather
-- than dropped: the Headhunter Techno-Warrior's book line is "three languages
-- of choice, OR one other language and two Lore skills". A choice group picks
-- from one pool, so it offers the three languages and the note carries the
-- alternative.
--
-- Guarded on the exact old line, so re-running is a no-op and a row somebody has
-- since edited is left alone. This file sorts after every script that writes
-- any of these classes.

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'body-fixer' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 30, note: "Language: Other, one of choice (+30%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 30, note: "Language: Other, one of choice (+30%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'burster' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 30, note: "Language: Other, one of choice (+30%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Technical"], bonus: 30, per_level: 5, note: "Three other languages of choice, at least one human (+30%). The catalog has no individual language rows, so this offers the Technical category; pick languages." }', '- { choose: 3, from: ["Language: Other"], bonus: 30, per_level: 5, note: "Three other languages of choice, at least one human (+30%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { choose: 3, categories: ["Technical"], bonus: 30, per_level: 5, note: "Three other languages of choice, at least one human (+30%). The catalog has no individual language rows, so this offers the Technical category; pick languages." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other, one of choice (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'city-rat' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 15, note: "Language: Other, one of choice (+15%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: Other, one of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'crazy' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 15, note: "Language: Other, one of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], base: 20, per_level: 0, note: "Language: Other, one of choice (+20%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { choose: 1, categories: ["Communications"], base: 20, per_level: 0, note: "Language: Other, one of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 30, per_level: 5, note: "Two additional languages of choice (+30%). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 30, per_level: 5, note: "Two additional languages of choice (+30%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'cyber-knight' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 30, per_level: 5, note: "Two additional languages of choice (+30%). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 5, note: "Language: Other, one of choice (+5%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 5, note: "Language: Other, one of choice (+5%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'dog-boy' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 5, note: "Language: Other, one of choice (+5%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'elemental-fusionist-earth-air' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'elemental-fusionist-fire-water' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'glitter-boy' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%)." }', '- { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '- { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 10, note: "Language: Other, two of choice (+10%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: Other, two of choice (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'juicer' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 10, note: "Language: Other, two of choice (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 15, note: "Two languages of choice (+15% each). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two languages of choice (+15% each). Taken once per language - the picker asks which." }')
 WHERE class_id = 'knight' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 15, note: "Two languages of choice (+15% each). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'ley-line-walker' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other, one of choice (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'merc-soldier' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 30, per_level: 5, note: "Language: Other, two of choice (+30%). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 30, per_level: 5, note: "Language: Other, two of choice (+30%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'mind-melter' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 30, per_level: 5, note: "Language: Other, two of choice (+30%). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Communications"], bonus: 15, note: "Language: Other, three of choice (+15%)." }', '- { choose: 3, from: ["Language: Other"], bonus: 15, note: "Language: Other, three of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'mystic' AND instr(markdown, '- { choose: 3, categories: ["Communications"], bonus: 15, note: "Language: Other, three of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'operator' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }', '- { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'priest-of-light' AND instr(markdown, '- { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'psi-stalker' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'robot-pilot' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 25, note: "Language: Other, two of choice (+25%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 25, note: "Language: Other, two of choice (+25%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 25, note: "Language: Other, two of choice (+25%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%)." }', '- { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: Other, three of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'rogue-scientist' AND instr(markdown, '- { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'shifter' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Communications"], bonus: 15, note: "Speaks three additional languages of choice (+15%)." }', '- { choose: 3, from: ["Language: Other"], bonus: 15, note: "Speaks three additional languages of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { choose: 3, categories: ["Communications"], bonus: 15, note: "Speaks three additional languages of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'techno-wizard' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { choose: 2, categories: ["Communications"], note: "Language: Other, two of choice (+15%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 10, note: "Speaks two additional Languages (+10%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 10, note: "Speaks two additional Languages (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'warlock' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 10, note: "Speaks two additional Languages (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 1, categories: ["Communications"], bonus: 25, note: "Language: Other, one of choice (+25%)." }', '- { choose: 1, from: ["Language: Other"], bonus: 25, note: "Language: Other, one of choice (+25%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'wild-psi-stalker' AND instr(markdown, '- { choose: 1, categories: ["Communications"], bonus: 25, note: "Language: Other, one of choice (+25%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }', '- { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }') > 0;

-- The Diabolist's three languages, back in one group.
UPDATE imported_classes
   SET markdown = replace(markdown, '    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "The third language of choice (+20%). Split into two groups because a choice group cannot ask for more options than it lists, and Language: Other is the one row that may be taken repeatedly." }' || char(10), '')
 WHERE class_id = 'diabolist' AND instr(markdown, '    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "The third language of choice (+20%). Split into two groups because a choice group cannot ask for more options than it lists, and Language: Other is the one row that may be taken repeatedly." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two of the three languages of choice (+20% each)" }', '    - { choose: 3, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Three languages of choice (+20% each). Taken once per language - the picker asks which." }')
 WHERE class_id = 'diabolist' AND instr(markdown, '    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two of the three languages of choice (+20% each)" }') > 0;


-- Read the result back rather than trusting the exit code. Scoped to the rows
-- this script touches: a count over the whole table reports whatever else the
-- environment is carrying, which is how a dirty local database gets mistaken
-- for a failed apply.
SELECT count(*) AS narrowed_to_the_language_row FROM imported_classes
 WHERE class_id IN ('body-fixer', 'burster', 'chiang-ku-dragon', 'city-rat', 'crazy', 'cyber-doc', 'cyber-knight', 'diabolist', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'glitter-boy', 'headhunter-techno-warrior', 'juicer', 'knight', 'ley-line-rifter', 'ley-line-walker', 'merc-soldier', 'mind-melter', 'mystic', 'operator', 'priest-of-light', 'psi-stalker', 'robot-pilot', 'rogue-scholar', 'rogue-scientist', 'shifter', 'stone-master', 'techno-wizard', 'vagabond', 'warlock', 'wild-psi-stalker', 'wilderness-scout');
SELECT count(*) AS still_offering_a_category FROM imported_classes
 WHERE class_id IN ('body-fixer', 'burster', 'chiang-ku-dragon', 'city-rat', 'crazy', 'cyber-doc', 'cyber-knight', 'diabolist', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'glitter-boy', 'headhunter-techno-warrior', 'juicer', 'knight', 'ley-line-rifter', 'ley-line-walker', 'merc-soldier', 'mind-melter', 'mystic', 'operator', 'priest-of-light', 'psi-stalker', 'robot-pilot', 'rogue-scholar', 'rogue-scientist', 'shifter', 'stone-master', 'techno-wizard', 'vagabond', 'warlock', 'wild-psi-stalker', 'wilderness-scout')
   AND instr(markdown, 'categories: [' || char(34)) > 0
   AND instr(markdown, 'languages') > 0
   AND instr(markdown, 'from: [' || char(34) || 'Language: Other') = 0;
SELECT count(*) AS stale_workaround_note_left FROM imported_classes
 WHERE instr(markdown, 'no individual language rows') > 0;
SELECT count(*) AS diabolist_groups_merged FROM imported_classes
 WHERE class_id = 'diabolist' AND instr(markdown, 'The third language of choice') = 0
   AND instr(markdown, 'Three languages of choice') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE class_id IN ('body-fixer', 'burster', 'chiang-ku-dragon', 'city-rat', 'crazy', 'cyber-doc', 'cyber-knight', 'diabolist', 'dog-boy', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'glitter-boy', 'headhunter-techno-warrior', 'juicer', 'knight', 'ley-line-rifter', 'ley-line-walker', 'merc-soldier', 'mind-melter', 'mystic', 'operator', 'priest-of-light', 'psi-stalker', 'robot-pilot', 'rogue-scholar', 'rogue-scientist', 'shifter', 'stone-master', 'techno-wizard', 'vagabond', 'warlock', 'wild-psi-stalker', 'wilderness-scout') AND instr(markdown, char(13)) > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-language-picks.sql');
