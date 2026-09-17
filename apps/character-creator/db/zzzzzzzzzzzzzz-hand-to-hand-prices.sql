-- What each class charges to change, or to buy, a Hand to Hand style.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzzz-hand-to-hand-prices.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzzz-hand-to-hand-prices.sql
--
-- ===================================================================
-- WHY
-- ===================================================================
--
-- 199 published classes state a price in PROSE - "Can be changed to Hand to
-- Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts for the
-- cost of two" - in a note on the skill, or on the related-skills block for the
-- classes that grant no style and sell all of them. Nothing could charge it: a
-- style cost the one pick it occupied, whatever the class said. Four class
-- notes said so outright ("the model has no way to charge"), and those four
-- sentences are corrected at the bottom of this file, because a note about a
-- limit that has been lifted is worse than no note.
--
-- The block is `skills.hand_to_hand`, read by js/hand-to-hand.js:
--
--   hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
--
--   costs        style -> related-skill picks. 0 is a real price. A style that is
--                ABSENT is not offered, and `costs: {}` is a class that sells none.
--   conditions   the book's condition on a style, in words. Shown, not enforced:
--                alignment is chosen four steps after skills are.
--   creation_only  the change is allowed "only when the character is being
--                initially created" - the Combat Cyborg, and nobody else.
--
-- The keys are bare (martial_arts) because the frontmatter parser keeps the
-- quotes on a quoted KEY, which would then match nothing.
--
-- ===================================================================
-- HOW THE TABLE WAS MADE, AND HOW IT WAS CHECKED
-- ===================================================================
--
-- Read out of production on 2026-09-17 (--remote): every published, live class
-- whose frontmatter prices a style. A parser produced the first pass and
-- flagged what it was unsure of; 16 classes were then resolved by hand. The
-- whole table was checked by an independent reader working from the English
-- alone, with no access to the parser: 199 read, 1 disagreement (the
-- Maxi-Killer, where the parser had invented prices out of "starts at Martial
-- Arts or Assassin" - fixed), and 5 notes where Assassin follows a priced
-- Martial Arts with only an alignment. Those five went to the PRINTED page:
-- Phase World and New West both print "can be changed to martial arts at the
-- cost of one 'other' skill (or assassin if an evil alignment)" - a
-- parenthetical alternative at the same price. Stored as 1.
--
-- Every statement below was applied to a copy of the live markdown and parsed
-- back through js/parser.js before this file was written, and each of the five
-- styles was read through handToHandCost() against the table.
--
-- THREE DELIBERATE READINGS.
--   gypsy-thief           Triax printed 180 says "expert at the cost of one ...
--                         expert (or assassin if evil) ... for the cost of two".
--                         Almost certainly a misprint for martial arts. Stored AS
--                         PRINTED - expert 1, assassin 2 - and Martial Arts is
--                         therefore not offered. Change it on Nate's word.
--   imperial-legionnaire  is granted two styles on purpose (zero gravity Basic,
--                         normal Expert). The Expert is the row that stands, so
--                         its note's prices are the ones stored.
--   crazy, ngr-intelligence-officer, ngr-intelligence-commando
--                         "May be changed to Assassin if ... evil" with no price
--                         stated is a free change: 0.
--
-- NOT GIVEN A BLOCK, on purpose: the Heroes Unlimited education levels and
-- power categories (they state a condition on Assassin and no price), and the
-- classes that exclude hand to hand through their Physical category. No block
-- means "this class states no price", and any style costs its one pick.
--
-- IDEMPOTENT. Each UPDATE is guarded on the block being absent, and inserts it
-- directly above `occ_skills:`, which appears exactly once at that indent in
-- every one of these classes (checked).

-- ===================================================================
-- THE PRICES
-- ===================================================================
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ley-line-walker' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mind-melter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'glitter-boy' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 4 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'priest-of-light' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'merc-soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 2, commando: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'robot-pilot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-fire-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-earth-air' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 4 }, conditions: { assassin: "anarchist or evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "anarchist or evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'shifter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 4 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'techno-wizard' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'burster' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'dog-boy' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psi-stalker' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'stone-master' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" }, creation_only: true }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'combat-cyborg' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { assassin: 0, commando: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'crazy' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'city-rat' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'vagabond' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil or anarchist alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'coalition-technical-officer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'operator' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'knight' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'squire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'palladin' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ranger' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mercenary-fighter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'thief' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'assassin' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'merchant' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'noble' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'scholar' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'diabolist' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'summoner' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wizard' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'druid' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warrior-monk' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'witch' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mind-mage' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psi-healer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psi-mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psychic-sensitive' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'vagabond-peasant' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'hyperion-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'titan-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'phaeton-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mega-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'delphi-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'coalition-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psycho-stalker' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'dragon-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'maxi-killer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'juicer-gladiator' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'juicer-assassin' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'juicer-scout' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gambler' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'freelancer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'knight-of-the-order-of-the-hospital' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'knight-of-the-order-of-the-temple' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wormwood-priest-of-light' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'tvia-inspector' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'caf-trooper' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'caf-fleet-officer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'caf-scientist' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 4 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'noro-psychic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'noro-mystic-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "aberrant alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wolfen-quatoria' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'machine-people' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'imperial-legionnaire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'imperial-security-agent' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'freedom-fighter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'spacer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'galactic-tracer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'space-pirate' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'runner' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'colonist' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'draconid' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'phantom' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'naruni-repo-bot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'pleasurer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'first-stage-promethean' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'promethean-time-master' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'phase-mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-air' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-earth' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-fire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-air-earth' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-air-fire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-air-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-earth-fire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-earth-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'warlock-fire-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-infantry-soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-communications-officer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-medical-officer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-field-mechanic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-combat-pilot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "anarchist or evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-officer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "anarchist or evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-commando' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ngr-police' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'euro-juicer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'sea-inquisitor' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-whale' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'whale-singer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'ocean-wizard' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'tritonian-sea-wolf' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'tritonian-scientist' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'navy-seaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'marine' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'sea-titan' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'salvage-expert' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-devastator' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-koral-shaper' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'horune-pirate' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-descended-glitter-boy-pilot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-glitter-girl-pilot' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-side-kick-rpa' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 4 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-gb-reloader' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-soldier' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-imprimer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-dervish' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-slasher' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-leviathan' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'bandit' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'bounty-hunter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gunfighter' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'highwayman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gunslinger' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'justice-ranger' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'psi-slinger' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'saddle-tramp' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'cowboy' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2, commando: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'sheriff-lawman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'sheriffs-deputy' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'wired-gunslinger' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mining-borg' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'professional-gambler' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'saloon-bum' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'saloon-girl' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'cactus-people' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'tribal-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mystic-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'totem-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'spirit-warrior' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'plant-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'animal-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'mask-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'healing-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'fetish-shaman' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-air' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-earth' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-fire' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-water' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'night-witch' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'hidden-witch' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'necromancer-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'born-mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'old-believer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'slayer-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: {} }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-beguiler' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'russian-ley-line-walker' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-sorcerer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-nightbane-mystic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-nightbane-sorcerer' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-package-basic' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-package-nocturne' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-package-resistance' AND instr(markdown, 'hand_to_hand:') = 0;
UPDATE imported_classes SET markdown = replace(markdown,
    char(10) || '  occ_skills:',
    char(10) || '  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }' || char(10) || '  occ_skills:'),
    updated_at = datetime('now')
 WHERE class_id = 'nb-package-warlord' AND instr(markdown, 'hand_to_hand:') = 0;

-- ===================================================================
-- FOUR NOTES THAT SAID THIS COULD NOT BE DONE
-- ===================================================================
UPDATE imported_classes SET markdown = replace(markdown,
    'Hand to Hand upgrades are priced in other skills, which the model has no way to charge, so they are stated in the note.',
    'Hand to Hand upgrades are priced in other skills: stated in the note, and charged from skills.hand_to_hand since PR #1148.'),
    updated_at = datetime('now')
 WHERE class_id = 'soldier' AND instr(markdown, 'Hand to Hand upgrades are priced in other skills, which the model has no way to charge, so they are stated in the note.') > 0;
UPDATE imported_classes SET markdown = replace(markdown,
    'The app has no way to price a skill against a pick, so a player wanting hand to hand has to spend the picks by hand.',
    'The price is charged from skills.hand_to_hand since PR #1148.'),
    updated_at = datetime('now')
 WHERE class_id = 'phantom' AND instr(markdown, 'The app has no way to price a skill against a pick, so a player wanting hand to hand has to spend the picks by hand.') > 0;
UPDATE imported_classes SET markdown = replace(markdown,
    'That is a cost rule the app cannot express; a player buying hand to hand should spend related picks for it.',
    'The hand to hand prices are charged from skills.hand_to_hand since PR #1148; the other combat skills cost one pick each, as any skill does.'),
    updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-whale' AND instr(markdown, 'That is a cost rule the app cannot express; a player buying hand to hand should spend related picks for it.') > 0;
UPDATE imported_classes SET markdown = replace(markdown,
    'Recorded in the related-skills note; the app has no way' || char(10) || '    to price a skill against a pick.',
    'Recorded in the related-skills note, and charged from' || char(10) || '    skills.hand_to_hand since PR #1148.'),
    updated_at = datetime('now')
 WHERE class_id = 'noro-psychic' AND instr(markdown, 'the app has no way' || char(10) || '    to price a skill against a pick.') > 0;

-- ===================================================================
-- READ-BACKS
-- ===================================================================
-- NO class_id IN (...) LIST. d1-apply sends every read-back in ONE --command,
-- and 199 quoted ids ran it past the Windows command-line limit: the apply
-- succeeded and the assertions were never evaluated (found on --local, before
-- this went anywhere near production). The count is the whole table, and a
-- class imported later with its own block sorts BEFORE this file, so on a
-- rebuild the number only ever grows - hence >=, spelled as a 0/1 so got and
-- want still compare equal.
SELECT 'at least the 199 classes in the table carry a block' AS assertion,
       (count(*) >= 199) AS got, 1 AS want
  FROM imported_classes
 WHERE instr(markdown, char(10) || '  hand_to_hand: { costs: ') > 0;
SELECT 'and none carries two' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(substr(markdown, instr(markdown, 'hand_to_hand:') + 13), char(10) || '  hand_to_hand:') > 0;
SELECT 'every block sits directly above occ_skills' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(markdown, char(10) || '  hand_to_hand: {') > 0
   AND instr(substr(markdown, instr(markdown, char(10) || '  hand_to_hand: {') + 1), char(10) || '  occ_skills:') = 0;
SELECT 'the Juicer sells Martial Arts and Assassin at one pick' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'juicer'
   AND instr(markdown, 'hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }') > 0;
SELECT 'the Druid sells nothing' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'druid' AND instr(markdown, 'hand_to_hand: { costs: {} }') > 0;
SELECT 'the Scholar buys from nothing: one, two, three' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'scholar'
   AND instr(markdown, 'hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }') > 0;
SELECT 'the Crazy changes to Assassin for free' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'crazy' AND instr(markdown, 'costs: { assassin: 0, commando: 2 }') > 0;
SELECT 'only the Combat Cyborg is creation-only' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE instr(markdown, 'creation_only: true') > 0 AND class_id = 'combat-cyborg';
SELECT 'and nobody else is' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE instr(markdown, 'creation_only: true') > 0 AND class_id <> 'combat-cyborg';
SELECT 'no class still says the price cannot be charged' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('soldier', 'phantom', 'pneuma-biform-whale', 'noro-psychic')
   AND (instr(markdown, 'no way to charge') > 0
    OR instr(markdown, 'to price a skill against a pick') > 0
    OR instr(markdown, 'a cost rule the app cannot express') > 0);
SELECT 'the four corrected notes cite the change instead' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('soldier', 'phantom', 'pneuma-biform-whale', 'noro-psychic')
   AND instr(markdown, 'skills.hand_to_hand since PR #1148') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzz-hand-to-hand-prices.sql');
