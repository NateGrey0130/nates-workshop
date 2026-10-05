-- The stale-notes sweep, part 2 of 2: sentences in class records that say
-- the catalog lacks something it now holds.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~125-stale-notes-sweep-part-2.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~125-stale-notes-sweep-part-2.sql
--
-- Close-out package A14, last of Phase A. A note describing a limit that has
-- been lifted tells the next reader not to try, and nothing fails when it
-- goes stale. Every published class was searched for sentences saying a
-- thing "has no catalog row", "is not in the catalog" or the like: 484
-- sentences in 293 classes. Four read-only passes asked production whether
-- each named thing has a row today, with a near-match rule (a similar word
-- is not the thing): 71 sentences were false. The clear-cut ones are
-- corrected here; the ones that turn on judgement (a row from another game
-- system, a named model standing in for a generic item) are left and listed
-- in the PR.
--
-- A corrected sentence says the row exists and that the class still stores
-- what it stored. NOTHING A CLASS GRANTS CHANGES, with one exception: the
-- Jungle Elf's occupation list gains african-priest, rain-maker and
-- medicine-man, which its own note said to add once they were imported. The
-- generator parsed every class before and after and refuses any other
-- difference outside notes, descriptions and prose.
--
-- Also here: four classes' "add it by hand" notes that ~122/~123 made false.
-- And one skill note: Law: CCW spoke of two Law rows, where the catalog holds
-- one, Law at 35%.
--
-- Every replace() is guarded and a second run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: 28 class rows and one skill row.

UPDATE skills
   SET note = 'The law of the Consortium of Civilized Worlds, including the Civilization Compact. Distinct from the catalog''s Law row (35%): this is one polity''s code, not general jurisprudence.'
 WHERE name = 'Law: CCW'
   AND instr(note, 'Law (General) at 35% and Law at 25%') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'this catalog has no Necromancer O.C.C. yet.',
         'the catalog holds two Necromancer O.C.C.s now (necromancer and necromancer-russian) and this list names neither.'),
       updated_at = datetime('now')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, 'this catalog has no Necromancer O.C.C. yet.') > 0
   AND instr(markdown, 'the catalog holds two Necromancer O.C.C.s now (necromancer and necromancer-russian) and this list names neither.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'this
  catalog holds no Necromancer O.C.C. A dangling',
         'this
  catalog held no Necromancer O.C.C. when the list was drafted. Two exist now,
  `necromancer` (Rifts World Book 4: Africa) and `necromancer-russian` (Mystic
  Russia), and the list still names neither. A dangling'),
       updated_at = datetime('now')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, 'this
  catalog holds no Necromancer O.C.C. A dangling') > 0
   AND instr(markdown, '` (Rifts World Book 4: Africa) and `necromancer-russian` (Mystic
  Russia), and the list still names neither. A dangling') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 2, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 2, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 2, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'mporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Englan') > 0
   AND instr(markdown, 'level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic, which this catalog does not hold." }',
         'level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts Engla') > 0
   AND instr(markdown, 'level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The catalog holds no temporal magic, so only the listed spells are offered.',
         'Only the listed spells are offered here.'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'The catalog holds no temporal magic, so only the listed spells are offered.') > 0
   AND instr(markdown, 'Only the listed spells are offered here.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book also allows Rifts England''s temporal magic for any of those picks, and the catalog holds none - the Time Master precedent from phase-world batch 9: grant the half that exists and say so.',
         'The book also allows Rifts England''s temporal magic for any of those picks. The catalog holds 25 temporal spells now (tradition temporal, names prefixed Temporal: , Rifts Book of Magic p.244-251); the class does not grant or list them and still offers the printed 64 list only, on the Time Master precedent from phase-world batch 9.'),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'The book also allows Rifts England''s temporal magic for any of those picks, and the catalog holds none - the Time Master') > 0
   AND instr(markdown, 'not grant or list them and still offers the printed 64 list only, on the Time Master precedent from phase-world batch 9.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'snowshoes or skis (no row), sewing kit',
         'snowshoes or skis (no row for snowshoes; ski rows exist now, skis-downhill and skis-cross-country, and the class does not list them), sewing kit'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-druid'
   AND instr(markdown, 'snowshoes or skis (no row), sewing kit') > 0
   AND instr(markdown, 'w for snowshoes; ski rows exist now, skis-downhill and skis-cross-country, and the class does not list them), sewing kit') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '2D4 magic herbs (see Rifts England; no row)',
         '2D4 magic herbs (see Rifts England; about thirty herb rows exist now, slugs starting herb-, and the class does not list them)'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-druid'
   AND instr(markdown, '2D4 magic herbs (see Rifts England; no row)') > 0
   AND instr(markdown, 'agic herbs (see Rifts England; about thirty herb rows exist now, slugs starting herb-, and the class does not list them)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The catalog has no Land Rover; jeep stands in.',
         'The catalog''s Land Rover (wr-1010-land-rover, Triax and the NGR p.138) is a vehicle row with no gear pointer, so jeep still stands in.'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-tech'
   AND instr(markdown, 'The catalog has no Land Rover; jeep stands in.') > 0
   AND instr(markdown, 'Land Rover (wr-1010-land-rover, Triax and the NGR p.138) is a vehicle row with no gear pointer, so jeep still stands in.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'bedroll, belt, boots, cloak or cape (often fur) and personal items have no row; the starting vehicle of choice (',
         'belt, boots and personal items have no row; the bedroll and the cloak or cape (often fur) are not listed, though rows exist now (bedroll-rifts, cape-or-cloak-long); the starting vehicle of choice ('),
       updated_at = datetime('now')
 WHERE class_id = 'reaver-mechanized-cavalryman'
   AND instr(markdown, 'bedroll, belt, boots, cloak or cape (often fur) and personal items have no row; the starting vehicle of choice (') > 0
   AND instr(markdown, ' (often fur) are not listed, though rows exist now (bedroll-rifts, cape-or-cloak-long); the starting vehicle of choice (') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'or any snow mobile or jet sled) has no row.',
         'or any snow mobile or jet sled) is not granted, though vehicle rows exist now (tek-12-yy110-bushbike, tek-20-yy210-borgbike, warrior-assault-hoversled-light, warrior-assault-hoversled-heavy, landflier, heavy-mdc-snowmobile, novyet-snow-jetsled; Warlords of Russia p.145-156).'),
       updated_at = datetime('now')
 WHERE class_id = 'reaver-mechanized-cavalryman'
   AND instr(markdown, 'or any snow mobile or jet sled) has no row.') > 0
   AND instr(markdown, 't, warrior-assault-hoversled-heavy, landflier, heavy-mdc-snowmobile, novyet-snow-jetsled; Warlords of Russia p.145-156).') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'folding shovel, bedroll, belt, boots and a handful of personal items have no row.',
         'folding shovel, belt, boots and a handful of personal items have no row. A bedroll row exists now (bedroll-rifts); the class does not list it.'),
       updated_at = datetime('now')
 WHERE class_id = 'reaver-soldier'
   AND instr(markdown, 'folding shovel, bedroll, belt, boots and a handful of personal items have no row.') > 0
   AND instr(markdown, 'boots and a handful of personal items have no row. A bedroll row exists now (bedroll-rifts); the class does not list it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Cyborg Body Armor plates (printed 97) have no catalog rows and are not stubbed: they are prose in an ability.',
         'The Cyborg Body Armor plates (printed 97) have catalog rows now (cyborg-body-armor-light-undercover, cyborg-body-armor-light-infiltration, cyborg-body-armor-light-infantry, cyborg-body-armor-heavy-infantry); the class does not list them, and they stay prose in an ability.'),
       updated_at = datetime('now')
 WHERE class_id = 'republic-cyborg-soldier'
   AND instr(markdown, 'The Cyborg Body Armor plates (printed 97) have no catalog rows and are not stubbed: they are prose in an ability.') > 0
   AND instr(markdown, 'rmor-light-infantry, cyborg-body-armor-heavy-infantry); the class does not list them, and they stay prose in an ability.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Since the Roane Musician O.C.C. is not in the catalog, every pairing qualifies.',
         'The Roane Musician O.C.C. is in the catalog now (roane-musician); the race still grants both skills on every pairing.'),
       updated_at = datetime('now')
 WHERE class_id = 'roane-piper'
   AND instr(markdown, 'Since the Roane Musician O.C.C. is not in the catalog, every pairing qualifies.') > 0
   AND instr(markdown, 'The Roane Musician O.C.C. is in the catalog now (roane-musician); the race still grants both skills on every pairing.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Roane Musician O.C.C. printed with the race (printed 172-173) is not
imported as a class.',
         'The Roane Musician O.C.C. printed with the race (printed 172-173) is a
separate class.'),
       updated_at = datetime('now')
 WHERE class_id = 'roane-piper'
   AND instr(markdown, 'The Roane Musician O.C.C. printed with the race (printed 172-173) is not
imported as a class.') > 0
   AND instr(markdown, 'The Roane Musician O.C.C. printed with the race (printed 172-173) is a
separate class.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Republic''s robots (printed 158-180) are not in the catalog yet; they are described in the Issued Machines section and side_effects, to be wired to the vehicles tables once the book''s robots are imported.',
         'The Republic''s robots (printed 158-180) are in the catalog now as vehicle rows (at-1053-ka-kuma-metal-bear, at-1063-hi-tora-fire-tiger, ir-2015-kani-crab-walker, ir-2020-wrecker, ir-2040-destroyer, ir-2050-apocalypse, ir-2060-banshee, ir-2070-gemini, ir-4000-tatsu-dragon; Japan p.158-181); the class does not grant one and still describes them in the Issued Machines section and side_effects.'),
       updated_at = datetime('now')
 WHERE class_id = 'robot-pilot-japan'
   AND instr(markdown, 'The Republic''s robots (printed 158-180) are not in the catalog yet; they are described in the Issued Machines section an') > 0
   AND instr(markdown, 'Japan p.158-181); the class does not grant one and still describes them in the Issued Machines section and side_effects.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The full statistics will be linked here once the book''s robots are in the catalog.',
         'The full statistics are printed on those pages.'),
       updated_at = datetime('now')
 WHERE class_id = 'robot-pilot-japan'
   AND instr(markdown, 'The full statistics will be linked here once the book''s robots are in the catalog.') > 0
   AND instr(markdown, 'The full statistics are printed on those pages.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Samurai armor and silver-tipped arrows have no catalog row.',
         'Samurai armor and silver-tipped arrows are catalog rows (samurai-armor, silver-tipped-arrows), and equipment_starting lists both.'),
       updated_at = datetime('now')
 WHERE class_id = 'ronin'
   AND instr(markdown, 'Samurai armor and silver-tipped arrows have no catalog row.') > 0
   AND instr(markdown, 'rmor and silver-tipped arrows are catalog rows (samurai-armor, silver-tipped-arrows), and equipment_starting lists both.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a bed roll, a belt, a note or sketch pad and personal items have no catalog row.',
         'a belt and personal items have no catalog row. Bed roll, note pad and sketch pad rows exist now (bedroll-rifts, note-pad, sketch-pad); the class does not list them.'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-explorer'
   AND instr(markdown, 'a bed roll, a belt, a note or sketch pad and personal items have no catalog row.') > 0
   AND instr(markdown, 'w. Bed roll, note pad and sketch pad rows exist now (bedroll-rifts, note-pad, sketch-pad); the class does not list them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'pitchfork or blunt weapon, walking stick/staff or sword, shovel, tinted goggles, bedroll, a water skin, belt, boots and personal items have no catalog row and are in GM Notes.',
         'pitchfork or blunt weapon, staff or sword, shovel, belt, boots and personal items have no catalog row and are in GM Notes. Rows exist now for the walking stick, tinted goggles, bedroll and water skin (walking-stick, tinted-goggles, bedroll-rifts, water-skin-half-gallon); the class does not list them and they are still in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-villager'
   AND instr(markdown, 'pitchfork or blunt weapon, walking stick/staff or sword, shovel, tinted goggles, bedroll, a water skin, belt, boots and ') > 0
   AND instr(markdown, 'ck, tinted-goggles, bedroll-rifts, water-skin-half-gallon); the class does not list them and they are still in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'is not in the catalog yet; it is described in the Issued Power Armor section and side_effects, to be wired to the vehicles tables once the book''s power armor is imported.',
         'is in the catalog now as the vehicle row at-samurai-samas-pa-10a (Japan p.134-135); the class does not grant it and still describes it in the Issued Power Armor section and side_effects.'),
       updated_at = datetime('now')
 WHERE class_id = 'samas-samurai-pilot'
   AND instr(markdown, 'is not in the catalog yet; it is described in the Issued Power Armor section and side_effects, to be wired to the vehicl') > 0
   AND instr(markdown, 'Japan p.134-135); the class does not grant it and still describes it in the Issued Power Armor section and side_effects.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The full statistics are printed 132-135 and will be linked here once the book''s power armor is in the catalog.',
         'The full statistics are printed 132-135.'),
       updated_at = datetime('now')
 WHERE class_id = 'samas-samurai-pilot'
   AND instr(markdown, 'The full statistics are printed 132-135 and will be linked here once the book''s power armor is in the catalog.') > 0
   AND instr(markdown, 'The full statistics are printed 132-135.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Medical carries +5% on Paramedic or First Aid only: add it to that skill by hand.',
         'Medical carries +5% on Paramedic or First Aid only: the second Medical entry carries it.'),
       updated_at = datetime('now')
 WHERE class_id = 'serpentoid'
   AND instr(markdown, 'Medical carries +5% on Paramedic or First Aid only: add it to that skill by hand.') > 0
   AND instr(markdown, 'Medical carries +5% on Paramedic or First Aid only: the second Medical entry carries it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a category bonus applies to every pick, so no bonus is stored and the +5 is a note.',
         'a category bonus applies to every pick, so the second Medical entry, limited to those two skills, carries the +5.'),
       updated_at = datetime('now')
 WHERE class_id = 'serpentoid'
   AND instr(markdown, 'a category bonus applies to every pick, so no bonus is stored and the +5 is a note.') > 0
   AND instr(markdown, 'a category bonus applies to every pick, so the second Medical entry, limited to those two skills, carries the +5.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Feng Shui or Geomancy (15% +5%) and Sohei Meditation (20% +6%) have no catalog rows and are special abilities with their percentages in prose.',
         'Feng Shui or Geomancy (15% +5%) has a catalog row now (Lore: Feng Shui/Geomancy, base 15, +5); the class does not grant it and still stores a special ability with the percentage in prose. Sohei Meditation (20% +6%) has no catalog row and is a special ability with its percentage in prose.'),
       updated_at = datetime('now')
 WHERE class_id = 'sohei-warrior-monk'
   AND instr(markdown, 'Feng Shui or Geomancy (15% +5%) and Sohei Meditation (20% +6%) have no catalog rows and are special abilities with their') > 0
   AND instr(markdown, 'ercentage in prose. Sohei Meditation (20% +6%) has no catalog row and is a special ability with its percentage in prose.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'bedroll and uniforms have no catalog row.',
         'bedroll and uniforms are not listed, though rows exist now (bedroll-rifts, uniform).'),
       updated_at = datetime('now')
 WHERE class_id = 'sovietski-soldier'
   AND instr(markdown, 'bedroll and uniforms have no catalog row.') > 0
   AND instr(markdown, 'bedroll and uniforms are not listed, though rows exist now (bedroll-rifts, uniform).') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The catalog holds one Surveillance row and no tailing-only form, so the whole skill is granted and the restriction is recorded in restrictions.',
         'A Tailing row (Rogue) exists now; the class does not grant it and still grants the whole Surveillance skill, with the restriction recorded in restrictions.'),
       updated_at = datetime('now')
 WHERE class_id = 'spirit-wolf'
   AND instr(markdown, 'The catalog holds one Surveillance row and no tailing-only form, so the whole skill is granted and the restriction is re') > 0
   AND instr(markdown, 'he class does not grant it and still grants the whole Surveillance skill, with the restriction recorded in restrictions.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book grants ''surveillance (tailing only)'' and the catalog holds no tailing-only row to narrow it to.',
         'The book grants ''surveillance (tailing only)''; a Tailing row (Rogue) exists now and the class does not grant it.'),
       updated_at = datetime('now')
 WHERE class_id = 'spirit-wolf'
   AND instr(markdown, 'The book grants ''surveillance (tailing only)'' and the catalog holds no tailing-only row to narrow it to.') > 0
   AND instr(markdown, 'The book grants ''surveillance (tailing only)''; a Tailing row (Rogue) exists now and the class does not grant it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Silver-coated weapons, garlic and iron spikes have no catalog rows and no printed prices, and are recorded in restrictions instead of stubbed.',
         'Silver-coated weapons have no Palladium catalog row and no printed price, and are recorded in restrictions instead of stubbed. Garlic and iron spikes have no printed prices either; rows exist now (garlic-cloves, an estimate-priced row, and iron-spike, a Rifts row), the class does not list them, and they are still recorded in restrictions.'),
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'Silver-coated weapons, garlic and iron spikes have no catalog rows and no printed prices, and are recorded in restrictio') > 0
   AND instr(markdown, 'ate-priced row, and iron-spike, a Rifts row), the class does not list them, and they are still recorded in restrictions.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'has no gear row, so the armor pick offers the alternatives the book names and the Sunaj armor is prose until the gear batch adds it.',
         'is the gear row sunaj-environmental-armor, and the armor pick offers it first, ahead of the alternatives the book names.'),
       updated_at = datetime('now')
 WHERE class_id = 'sunaj-assassin'
   AND instr(markdown, 'has no gear row, so the armor pick offers the alternatives the book names and the Sunaj armor is prose until the gear ba') > 0
   AND instr(markdown, 'is the gear row sunaj-environmental-armor, and the armor pick offers it first, ahead of the alternatives the book names.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book says one medium size sack; the catalog has no medium.',
         'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.'),
       updated_at = datetime('now')
 WHERE class_id = 'symbiotic-warrior'
   AND instr(markdown, 'The book says one medium size sack; the catalog has no medium.') > 0
   AND instr(markdown, 'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment names Titan Plate Armor at 180 M.D.C., which has no gear row yet.',
         'Standard equipment names Titan Plate Armor at 180 M.D.C.; its gear row exists (titan-plate-armor, which carries 195 M.D.C.) and equipment_starting lists it.'),
       updated_at = datetime('now')
 WHERE class_id = 'titan-juicer'
   AND instr(markdown, 'Standard equipment names Titan Plate Armor at 180 M.D.C., which has no gear row yet.') > 0
   AND instr(markdown, ' Armor at 180 M.D.C.; its gear row exists (titan-plate-armor, which carries 195 M.D.C.) and equipment_starting lists it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a box of 100 large resealable plastic bags, cloak or long coat, bedroll, belt, boots, note pad, a dozen pencils and personal items have no catalog row and are in GM Notes.',
         'a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row and are in GM Notes. The cloak or long coat, bedroll, note pad and dozen pencils have rows now (cape-or-cloak-long, bedroll-rifts, note-pad, pencil); the class does not list them and they stay in GM Notes too.'),
       updated_at = datetime('now')
 WHERE class_id = 'travelling-story-teller'
   AND instr(markdown, 'a box of 100 large resealable plastic bags, cloak or long coat, bedroll, belt, boots, note pad, a dozen pencils and pers') > 0
   AND instr(markdown, 's now (cape-or-cloak-long, bedroll-rifts, note-pad, pencil); the class does not list them and they stay in GM Notes too.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Equipment the catalog holds no Rifts row for stays in the body: the bow and arrows, the tomahawks, 50 feet of rope, rations, string, and war and camouflage paint.',
         'Equipment the catalog holds no Rifts row for stays in the body: the tomahawks, string and war paint. The bow and arrows, 50 feet of rope, rations and camouflage paint have Rifts rows now (short-bow-modern-materials, long-bow-modern-materials, modern-bow, mdc-arrow, rope-per-20-feet-6-m, lightweight-rope, food-rations, camouflage-paint-kit-rifts); the class does not list them and they stay in the body as well.'),
       updated_at = datetime('now')
 WHERE class_id = 'tribal-warrior'
   AND instr(markdown, 'Equipment the catalog holds no Rifts row for stays in the body: the bow and arrows, the tomahawks, 50 feet of rope, rati') > 0
   AND instr(markdown, 'tweight-rope, food-rations, camouflage-paint-kit-rifts); the class does not list them and they stay in the body as well.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '## Equipment the catalog cannot hold yet',
         '## Equipment beyond the stored list'),
       updated_at = datetime('now')
 WHERE class_id = 'tribal-warrior'
   AND instr(markdown, '## Equipment the catalog cannot hold yet') > 0
   AND instr(markdown, '## Equipment beyond the stored list') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the horse-borg and horse-bot have no catalog row.',
         'the horse-borg has no catalog row, and the horse-bot exists only as vehicle rows (four Bandito Arms robot horses, New West p.196-200) that no gear row points at, so neither is offered.'),
       updated_at = datetime('now')
 WHERE class_id = 'ultra-crazy'
   AND instr(markdown, 'the horse-borg and horse-bot have no catalog row.') > 0
   AND instr(markdown, ' as vehicle rows (four Bandito Arms robot horses, New West p.196-200) that no gear row points at, so neither is offered.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '(the horse-borg and horse-bot have no row and are not stubbed)',
         '(the horse-borg has no row and is not stubbed; robot horse rows exist now as vehicles, the four Bandito Arms models of New West p.196-200 such as rh-1002b-mustang-medium-robot-horse, with no gear row pointing at them, and the class does not list one)'),
       updated_at = datetime('now')
 WHERE class_id = 'ultra-crazy'
   AND instr(markdown, '(the horse-borg and horse-bot have no row and are not stubbed)') > 0
   AND instr(markdown, '196-200 such as rh-1002b-mustang-medium-robot-horse, with no gear row pointing at them, and the class does not list one)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Rifts Vampire Kingdoms 31-32) have no catalog rows and are prose; no stubs were made for another book''s gear.',
         'Rifts Vampire Kingdoms 31-32) are prose. Rows for the three exist now (tw-flare-storm, tw-flare-globe-of-daylight, tw-full-size-water-shotgun); the class does not list them.'),
       updated_at = datetime('now')
 WHERE class_id = 'undead-slayer'
   AND instr(markdown, 'Rifts Vampire Kingdoms 31-32) have no catalog rows and are prose; no stubs were made for another book''s gear.') > 0
   AND instr(markdown, ' three exist now (tw-flare-storm, tw-flare-globe-of-daylight, tw-full-size-water-shotgun); the class does not list them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The catalog holds no Rifts Military Specialist ladder (geofront-military-specialist is the Japan class of that name, a different book and table; the hu- rows are Heroes Unlimited), so no xp_table is stored. Copy that ladder here if a Rifts Military Specialist is imported.',
         'The catalog holds a Rifts Military Specialist ladder now, on coalition-military-specialist (Rifts Ultimate Edition p.235-236; geofront-military-specialist is the Japan class of that name, a different book and table; the hu- rows are Heroes Unlimited). This class does not copy it and still stores no xp_table.'),
       updated_at = datetime('now')
 WHERE class_id = 'vintex-warrior'
   AND instr(markdown, 'The catalog holds no Rifts Military Specialist ladder (geofront-military-specialist is the Japan class of that name, a d') > 0
   AND instr(markdown, ' different book and table; the hu- rows are Heroes Unlimited). This class does not copy it and still stores no xp_table.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'It has no gear row and is to be imported separately as a vehicle, so it is NOT in equipment_starting;',
         'It is a vehicle row now (war-knight-power-armor, Warlords of Russia p.93-94) and still has no gear pointer row, so it is NOT in equipment_starting;'),
       updated_at = datetime('now')
 WHERE class_id = 'war-knight'
   AND instr(markdown, 'It has no gear row and is to be imported separately as a vehicle, so it is NOT in equipment_starting;') > 0
   AND instr(markdown, 'r-knight-power-armor, Warlords of Russia p.93-94) and still has no gear pointer row, so it is NOT in equipment_starting;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'It is not on the equipment list;
it is to be entered as a vehicle.',
         'It is not on the equipment list;
it is listed among the vehicles.'),
       updated_at = datetime('now')
 WHERE class_id = 'war-knight'
   AND instr(markdown, 'It is not on the equipment list;
it is to be entered as a vehicle.') > 0
   AND instr(markdown, 'It is not on the equipment list;
it is listed among the vehicles.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book says one medium size sack; the catalog has no medium.',
         'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.'),
       updated_at = datetime('now')
 WHERE class_id = 'wormwood-priest-of-light'
   AND instr(markdown, 'The book says one medium size sack; the catalog has no medium.') > 0
   AND instr(markdown, 'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'Law: CCW names the one Law row' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Law: CCW' AND instr(note, 'Law row (35%)') > 0 AND instr(note, 'Law at 25%') = 0;

SELECT 'part 1: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'norse-giant' AND length(markdown) = 12409)
    OR (class_id = 'paradox-shaman' AND length(markdown) = 15549)
    OR (class_id = 'psi-druid' AND length(markdown) = 18548)
    OR (class_id = 'psi-tech' AND length(markdown) = 14081)
    OR (class_id = 'reaver-mechanized-cavalryman' AND length(markdown) = 15612)
    OR (class_id = 'reaver-soldier' AND length(markdown) = 12390)
    OR (class_id = 'republic-cyborg-soldier' AND length(markdown) = 19733)
    OR (class_id = 'roane-piper' AND length(markdown) = 8446)
    OR (class_id = 'robot-pilot-japan' AND length(markdown) = 11875)
    OR (class_id = 'ronin' AND length(markdown) = 15616)
    OR (class_id = 'russian-explorer' AND length(markdown) = 13493)
    OR (class_id = 'russian-villager' AND length(markdown) = 13466);

SELECT 'part 2: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'samas-samurai-pilot' AND length(markdown) = 13114)
    OR (class_id = 'serpentoid' AND length(markdown) = 12004)
    OR (class_id = 'sohei-warrior-monk' AND length(markdown) = 21451)
    OR (class_id = 'sovietski-soldier' AND length(markdown) = 14717)
    OR (class_id = 'spirit-wolf' AND length(markdown) = 10479)
    OR (class_id = 'summoner' AND length(markdown) = 11369)
    OR (class_id = 'sunaj-assassin' AND length(markdown) = 22012)
    OR (class_id = 'symbiotic-warrior' AND length(markdown) = 6920)
    OR (class_id = 'titan-juicer' AND length(markdown) = 8862)
    OR (class_id = 'travelling-story-teller' AND length(markdown) = 13282)
    OR (class_id = 'tribal-warrior' AND length(markdown) = 10562)
    OR (class_id = 'ultra-crazy' AND length(markdown) = 14920);

SELECT 'part 3: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'undead-slayer' AND length(markdown) = 23573)
    OR (class_id = 'vintex-warrior' AND length(markdown) = 12196)
    OR (class_id = 'war-knight' AND length(markdown) = 17905)
    OR (class_id = 'wormwood-priest-of-light' AND length(markdown) = 10356);

INSERT INTO data_script_runs (filename) VALUES ('~125-stale-notes-sweep-part-2.sql');
