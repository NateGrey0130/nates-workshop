-- The largest unenforced rule in the app, given a field it can be enforced from.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Both keys live in class markdown, like xp_table.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-race-occ-restrictions.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-race-occ-restrictions.sql
--
-- TWO KEYS. `occ_group` on each of the 25 Palladium O.C.C.s, and
-- `occ_restrictions` on the 8 races that limit what may be taken alongside them.
--
--   clergy        4  priest-of-light, priest-of-darkness, warrior-monk, druid
--   men-of-arms   8  mercenary-fighter, long-bowman, soldier, knight, palladin, ranger, thief, assassin
--   optional      5  merchant, noble, scholar, squire, vagabond-peasant
--   magic         4  wizard, witch, diabolist, summoner
--   psychic       4  psychic-sensitive, psi-healer, psi-mystic, mind-mage
--
-- THE GROUPS ARE THE BOOK'S OWN, not a judgement. Each class is grouped by the
-- SECTION it is printed in: Clergy, Men of Arms (78-95), Optional O.C.C.s (96),
-- the Ways of Magic (100) and Psychic Character Classes (156). The Long Bowman
-- at printed 83 and the Priest of Light at 63 were the only two whose import
-- script did not cite a page, and both were read off the book directly.
--
-- WHY GROUPS AT ALL, rather than eight lists of class ids. "A dwarf may take any
-- O.C.C. except magic" is a rule about a GROUP. Written as a list of the four
-- magic classes the catalog holds today, it would silently stop covering the
-- fifth the day one is imported - and a restriction that quietly stops
-- restricting is worse than none, because nothing says it happened.
--
-- ONLY OR EXCEPT, NEVER BOTH. A closed list or an open one; the parser rejects
-- a race that states both, and rejects an empty list either way (an empty
-- `only` forbids everything, an empty `except` forbids nothing, and neither is
-- what anybody meant).
--
-- EVERY NAME MUST RESOLVE, and the generator refuses to write one that does not.
-- A class id with no class silently ALLOWS exactly what it meant to forbid,
-- which is the same failure an `only` naming a skill with no catalog row causes.
-- Three names in the book needed mapping and are recorded in each race's note:
--
--   "black priest"   the Priest of Darkness. Printed 68: "Priests of darkness
--                    or black priests are clergy who worship and serve..."
--   "monk"           the Warrior Monk, which is what this catalog calls it.
--   "vagabond"       the Vagabond, Peasant or Farmer O.C.C.
--
-- ONE RESTRICTION IS DELIBERATELY NOT ENFORCED. The troll may take no psychic
-- P.C.C. AND no illusionist, and there is no illusionist row: the main book
-- names it among the practitioners of magic on printed 100 and never prints one.
-- Naming it in an `except` would be naming nothing, so the bar is recorded in
-- the note and the psychic half is enforced.
--
-- NO LIVE CHARACTER IS AFFECTED. All nine are on races that carry no
-- restriction, so nothing that exists becomes invalid.

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: priest-of-light' || char(10), '---' || char(10) || 'id: priest-of-light' || char(10) || 'occ_group: clergy' || char(10))
 WHERE class_id = 'priest-of-light' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: priest-of-darkness' || char(10), '---' || char(10) || 'id: priest-of-darkness' || char(10) || 'occ_group: clergy' || char(10))
 WHERE class_id = 'priest-of-darkness' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: warrior-monk' || char(10), '---' || char(10) || 'id: warrior-monk' || char(10) || 'occ_group: clergy' || char(10))
 WHERE class_id = 'warrior-monk' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: druid' || char(10), '---' || char(10) || 'id: druid' || char(10) || 'occ_group: clergy' || char(10))
 WHERE class_id = 'druid' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mercenary-fighter' || char(10), '---' || char(10) || 'id: mercenary-fighter' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'mercenary-fighter' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: long-bowman' || char(10), '---' || char(10) || 'id: long-bowman' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'long-bowman' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: soldier' || char(10), '---' || char(10) || 'id: soldier' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'soldier' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: knight' || char(10), '---' || char(10) || 'id: knight' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'knight' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: palladin' || char(10), '---' || char(10) || 'id: palladin' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'palladin' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: ranger' || char(10), '---' || char(10) || 'id: ranger' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'ranger' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: thief' || char(10), '---' || char(10) || 'id: thief' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'thief' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: assassin' || char(10), '---' || char(10) || 'id: assassin' || char(10) || 'occ_group: men-of-arms' || char(10))
 WHERE class_id = 'assassin' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: merchant' || char(10), '---' || char(10) || 'id: merchant' || char(10) || 'occ_group: optional' || char(10))
 WHERE class_id = 'merchant' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: noble' || char(10), '---' || char(10) || 'id: noble' || char(10) || 'occ_group: optional' || char(10))
 WHERE class_id = 'noble' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: scholar' || char(10), '---' || char(10) || 'id: scholar' || char(10) || 'occ_group: optional' || char(10))
 WHERE class_id = 'scholar' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: squire' || char(10), '---' || char(10) || 'id: squire' || char(10) || 'occ_group: optional' || char(10))
 WHERE class_id = 'squire' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: vagabond-peasant' || char(10), '---' || char(10) || 'id: vagabond-peasant' || char(10) || 'occ_group: optional' || char(10))
 WHERE class_id = 'vagabond-peasant' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: wizard' || char(10), '---' || char(10) || 'id: wizard' || char(10) || 'occ_group: magic' || char(10))
 WHERE class_id = 'wizard' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: witch' || char(10), '---' || char(10) || 'id: witch' || char(10) || 'occ_group: magic' || char(10))
 WHERE class_id = 'witch' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: diabolist' || char(10), '---' || char(10) || 'id: diabolist' || char(10) || 'occ_group: magic' || char(10))
 WHERE class_id = 'diabolist' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: summoner' || char(10), '---' || char(10) || 'id: summoner' || char(10) || 'occ_group: magic' || char(10))
 WHERE class_id = 'summoner' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psychic-sensitive' || char(10), '---' || char(10) || 'id: psychic-sensitive' || char(10) || 'occ_group: psychic' || char(10))
 WHERE class_id = 'psychic-sensitive' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-healer' || char(10), '---' || char(10) || 'id: psi-healer' || char(10) || 'occ_group: psychic' || char(10))
 WHERE class_id = 'psi-healer' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-mystic' || char(10), '---' || char(10) || 'id: psi-mystic' || char(10) || 'occ_group: psychic' || char(10))
 WHERE class_id = 'psi-mystic' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: mind-mage' || char(10), '---' || char(10) || 'id: mind-mage' || char(10) || 'occ_group: psychic' || char(10))
 WHERE class_id = 'mind-mage' AND instr(markdown, 'occ_group:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: dwarf' || char(10), '---' || char(10) || 'id: dwarf' || char(10) || 'occ_restrictions:' || char(10) || '  except: ["group:magic"]' || char(10) || '  note: "No magic O.C.C. at all - not a single dwarf has practised magic in over 7,000 years."' || char(10))
 WHERE class_id = 'dwarf' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: gnome' || char(10), '---' || char(10) || 'id: gnome' || char(10) || 'occ_restrictions:' || char(10) || '  only: ["group:magic", "group:clergy", "group:optional", "ranger", "mercenary-fighter", "soldier", "thief", "assassin"]' || char(10) || '  note: "Any magic, clergy or optional O.C.C., plus ranger, mercenary, soldier, thief or assassin."' || char(10))
 WHERE class_id = 'gnome' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: troglodyte' || char(10), '---' || char(10) || 'id: troglodyte' || char(10) || 'occ_restrictions:' || char(10) || '  only: ["mercenary-fighter", "soldier", "thief", "assassin", "warrior-monk", "vagabond-peasant"]' || char(10) || '  note: "Six occupations by name. The book writes monk for the Warrior Monk and vagabond for the Vagabond, Peasant or Farmer."' || char(10))
 WHERE class_id = 'troglodyte' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: kobold' || char(10), '---' || char(10) || 'id: kobold' || char(10) || 'occ_restrictions:' || char(10) || '  except: ["long-bowman", "knight", "palladin"]' || char(10) || '  note: "Any except long bowman, knight or palladin."' || char(10))
 WHERE class_id = 'kobold' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: goblin' || char(10), '---' || char(10) || 'id: goblin' || char(10) || 'occ_restrictions:' || char(10) || '  only: ["assassin", "thief", "mercenary-fighter", "soldier", "priest-of-darkness", "witch", "vagabond-peasant", "group:psychic"]' || char(10) || '  note: "The book writes black priest, which is the Priest of Darkness, and allows the occasional psychic."' || char(10))
 WHERE class_id = 'goblin' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: hob-goblin' || char(10), '---' || char(10) || 'id: hob-goblin' || char(10) || 'occ_restrictions:' || char(10) || '  only: ["assassin", "thief", "mercenary-fighter", "soldier", "priest-of-darkness", "witch", "vagabond-peasant"]' || char(10) || '  note: "The book writes black priest, which is the Priest of Darkness. No psychic: the hob-goblin has no psionics."' || char(10))
 WHERE class_id = 'hob-goblin' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: orc' || char(10), '---' || char(10) || 'id: orc' || char(10) || 'occ_restrictions:' || char(10) || '  only: ["mercenary-fighter", "soldier", "assassin", "thief", "priest-of-darkness", "witch", "vagabond-peasant"]' || char(10) || '  note: "Magic by witchcraft and priest O.C.C.s only. The book writes black priest, which is the Priest of Darkness."' || char(10))
 WHERE class_id = 'orc' AND instr(markdown, 'occ_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: troll' || char(10), '---' || char(10) || 'id: troll' || char(10) || 'occ_restrictions:' || char(10) || '  except: ["group:psychic"]' || char(10) || '  note: "The book also bars the illusionist, which this catalog has no row for - the main book names it as a practitioner of magic without printing one."' || char(10))
 WHERE class_id = 'troll' AND instr(markdown, 'occ_restrictions:') = 0;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS occ_with_a_group FROM imported_classes
 WHERE status = 'published' AND instr(markdown, char(10) || 'occ_group: ') > 0;
SELECT count(*) AS races_with_restrictions FROM imported_classes
 WHERE status = 'published' AND instr(markdown, char(10) || 'occ_restrictions:') > 0;
SELECT count(*) AS a_race_given_a_group FROM imported_classes
 WHERE instr(markdown, 'category: rcc') > 0 AND instr(markdown, char(10) || 'occ_group: ') > 0;
SELECT count(*) AS an_occ_given_restrictions FROM imported_classes
 WHERE instr(markdown, 'category: occ') > 0 AND instr(markdown, char(10) || 'occ_restrictions:') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE instr(markdown, char(13)) > 0
   AND class_id IN ('priest-of-light', 'priest-of-darkness', 'warrior-monk', 'druid', 'mercenary-fighter', 'long-bowman', 'soldier', 'knight', 'palladin', 'ranger', 'thief', 'assassin', 'merchant', 'noble', 'scholar', 'squire', 'vagabond-peasant', 'wizard', 'witch', 'diabolist', 'summoner', 'psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage', 'dwarf', 'gnome', 'troglodyte', 'kobold', 'goblin', 'hob-goblin', 'orc', 'troll');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-race-occ-restrictions.sql');
