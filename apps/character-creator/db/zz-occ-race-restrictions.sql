-- Seven Rifts O.C.C.s that may not be paired with a race, and why.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-occ-race-restrictions.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-occ-race-restrictions.sql
--
--   juicer                       RUE p.81
--   psi-stalker                  RUE p.152
--   wild-psi-stalker             RUE p.155
--   coalition-grunt              RUE p.230
--   coalition-samas-pilot        RUE p.233
--   coalition-technical-officer  RUE p.237
--   dog-boy                      RUE p.142
--
-- THE MIRROR OF occ_restrictions. That key says which occupations a race may
-- take; this one says which races may take an occupation, and it is the half
-- the Juicer needed: its abilities add to an existing person, and the book is
-- specific about which person.
--
-- "none" IS THE HUMAN CASE, and it is the whole reason this key needs a
-- reserved word rather than a race id. Rifts prints NO Human R.C.C.: Rifts
-- Ultimate Edition's contents list exactly one Racial Character Class, the
-- Dragon Hatchling on printed 156. Human is the default and the unstated, which
-- is why a Rifts O.C.C. stands alone in the first place. So "human only" is not
-- a race to name - it is the ABSENCE of one, and only: ["none"] says that.
--
-- WHAT THIS ACTUALLY FORBIDS TODAY. The catalog holds three Rifts races -
-- dragon-hatchling, godling and demigod - and every one of them is now closed
-- to these seven. A Juicer Dragon Hatchling was constructible before this and
-- is refused now, in the wizard and on the server.
--
-- SIX OF THE SEVEN ALREADY RECORDED THE RULE IN PROSE. The seventh did not:
-- the COALITION GRUNT's markdown says a great deal about Coalition doctrine
-- toward non-humans and never states the restriction the book prints -
-- "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human
-- mutant". That one was found by reading the book rather than the class.
--
-- WHAT GETS NOTHING, and deliberately: the eight O.C.C.s whose racial line is a
-- STATISTIC rather than a bar - "None, although only about 20% are D-Bees",
-- "None; half are D-Bees", "None, at least 35% are D-Bees". A percentage of who
-- happens to play one is not a rule, and turning it into a restriction would
-- forbid characters the book allows.
--
-- The Psi-Stalker pair is the subtle one. A Psi-Stalker is a mutant HUMAN, so
-- it is human-only for the same reason as the rest rather than a race of its
-- own - and the Coalition Grunt's line allows exactly those two.

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: juicer' || char(10), '---' || char(10) || 'id: juicer' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Requirement: 95% human. The pre-Rifts technology was created specifically for humans, and adapting it to nonhumans is lethal unless the D-Bee is very human-like. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.81."' || char(10))
 WHERE class_id = 'juicer' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: psi-stalker' || char(10), '---' || char(10) || 'id: psi-stalker' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Requirement: Psi-Stalkers are mutant humans only. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.152."' || char(10))
 WHERE class_id = 'psi-stalker' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: wild-psi-stalker' || char(10), '---' || char(10) || 'id: wild-psi-stalker' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Requirement: Psi-Stalkers are mutant humans only. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.155."' || char(10))
 WHERE class_id = 'wild-psi-stalker' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-grunt' || char(10), '---' || char(10) || 'id: coalition-grunt' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.230."' || char(10))
 WHERE class_id = 'coalition-grunt' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-samas-pilot' || char(10), '---' || char(10) || 'id: coalition-samas-pilot' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Restrictions: Human. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.233."' || char(10))
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: coalition-technical-officer' || char(10), '---' || char(10) || 'id: coalition-technical-officer' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Restrictions: Human. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.237."' || char(10))
 WHERE class_id = 'coalition-technical-officer' AND instr(markdown, 'race_restrictions:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '---' || char(10) || 'id: dog-boy' || char(10), '---' || char(10) || 'id: dog-boy' || char(10) || 'race_restrictions:' || char(10) || '  only: ["none"]' || char(10) || '  note: "Racial Requirements: a mutant canine genetically created by the Coalition States. A Dog Boy IS the race, so it takes no other. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.142."' || char(10))
 WHERE class_id = 'dog-boy' AND instr(markdown, 'race_restrictions:') = 0;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS occs_restricted_by_race FROM imported_classes
 WHERE status = 'published' AND instr(markdown, char(10) || 'race_restrictions:') > 0;
SELECT count(*) AS all_of_them_human_only FROM imported_classes
 WHERE instr(markdown, char(10) || 'race_restrictions:') > 0
   AND instr(markdown, 'only: [' || char(34) || 'none' || char(34) || ']') > 0;
SELECT count(*) AS a_race_given_one FROM imported_classes
 WHERE instr(markdown, 'category: rcc') > 0
   AND instr(markdown, char(10) || 'race_restrictions:') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE instr(markdown, char(13)) > 0
   AND class_id IN ('juicer', 'psi-stalker', 'wild-psi-stalker', 'coalition-grunt', 'coalition-samas-pilot', 'coalition-technical-officer', 'dog-boy');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-occ-race-restrictions.sql');
