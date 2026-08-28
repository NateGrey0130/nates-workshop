-- The psionic power text a rebuild does not have, from the rows that hold it
-- (REBUILD-AUDIT.md F13, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-psionic-powers-full.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-psionic-powers-full.sql
--
-- WHAT HAPPENED. db/seed-catalogs.sql creates most of the psionics with a
-- name, a category and an I.S.P. cost and nothing else. The rest of each row -
-- range, duration, saving throw, the description, the page it is printed on -
-- was typed into the CATALOG EDITOR, which writes straight to D1 and leaves
-- nothing in git. restore-psionics-missing-from-repo.sql cannot help: it is
-- `INSERT OR IGNORE` on name and recovers a row that was ABSENT, never one
-- that was present and got ENRICHED. `add-rue-psionics-batch.sql` is the same
-- shape and finds the seed row already sitting there.
--
-- So a database built from this repo served 21 psionic powers with NO
-- DESCRIPTION AT ALL against production's one, and 32 with no source_book
-- against production's twelve. Healing Touch, Telepathy, Telekinetic Lift,
-- Mind Bolt and Sixth Sense were name-and-I.S.P. stubs. See operations.md,
-- "What a data script cannot recover".
--
-- 98 values across 22 rows, exported column for column from --remote rather
-- than transcribed, and only the columns that actually differ.
--
-- ================================================================
-- `system` IS DELIBERATELY NOT EXPORTED, AND THAT IS THE WHOLE CARE
-- IN THIS FILE.
-- ================================================================
--
-- Sixteen more rows differ from production in `system` alone: production says
-- 'rifts', a rebuild says NULL. **The rebuild is the one that is right.**
-- untag-cross-system.sql sets every psionic power's system to NULL and says in
-- as many words that this is "a DELIBERATE setting decision, not an oversight"
-- and "Do not 'fix' it by tagging these rows from their source_book; that was
-- considered and rejected" - because a tag strips the power from Palladium
-- characters, and untagging the Rifts psionics chapter is what makes a major
-- psychic's "eight powers from one category" possible there at all.
--
-- Those sixteen rows reached production AFTER untag-cross-system.sql ran there,
-- through the importer, so they never got untagged. Exporting production's
-- value would re-tag them rifts-only and undo the decision. The divergence is
-- real and it points the other way; it is REBUILD-AUDIT.md F15, and it is a
-- correction to PRODUCTION rather than to the repo, so it is not made here.
--
-- ONE ROW IS A RULES CALL AND WAS READ RATHER THAN ASSUMED. `Resist Fatigue`
-- is category Healing in production and Physical in a rebuild. Rifts Ultimate
-- Edition prints it in BOTH category lists on printed 164 (cache p167), and
-- prints its description in the HEALING section on printed 166 (cache p169),
-- which is the page production cites. Healing is taken on that basis. The
-- catalog holds one category per row, so this is a choice, not a correction.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after untag-cross-system.sql,
-- which rewrites `system` on every row here, and after zz-merge-psionic-
-- duplicates.sql, which merges rows it would otherwise write to twice.
--
-- Every statement targets one name and sets absolute values, so it is safe to
-- re-run and safe to run early: on production every value below is already the
-- value in the row, which is why applying it there changes nothing.

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.165',
      range = 'Immediate proximity, touch or within 3ft (0.9m).',
      duration = 'One hour per level of experience.',
      description = 'The ability to deaden pain can be used as a pain killer which temporarily negates existing pain or as an anesthetic to be used for surgery.'
  WHERE name = 'Deaden Pain';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.165',
      range = 'Touch.',
      duration = 'Instant, with lasting effects.',
      description = 'The healing touch is a remarkable healing ability that can instantly heal cuts, burns, bruises and similar physical wounds. The touch restores 1D8 hit points or 2D6 S.D.C. The healing touch can only be used on other living creatures, never on himself.'
  WHERE name = 'Healing Touch';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.165',
      range = 'Touch or within 6ft (1.8m).',
      duration = 'One hour per level of experience (or until awakened).',
      saving_throw = 'Standard; plus unwilling victims are +5 to save vs psychic attack.',
      description = 'This is not an offensive ability, but is intended to be a recuperative power to induce sleep on those who are ill, exhausted, or an insomniac. The person will fall into a normal, restful sleep from which he can be easily roused. Unwilling victims of the induce sleep psi-power get a +5 bonus to save (because this is not the intent of the ability) and can not be involved in combat at the time.'
  WHERE name = 'Induce Sleep';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.166',
      range = 'Self',
      duration = 'One hour per each level of experience.',
      saving_throw = 'None',
      description = 'A truly unique power that many psychic investigators claim is impossible and does not exist. Only a handful of physical psychics can manipulate their physical energy in such a way that it changes their aura. The altered aura will send the wrong message to those who can see auras. Alterations include: General level of experience can be made to seem much lower (level 1 or 2) or much higher (2D4 levels higher) than it really is. Conceal the presence of psychic powers. Conceal level of base P.P.E. (made to seem much lower). Conceal the presence of magic.'
  WHERE name = 'Alter Aura';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.167',
      range = 'Self',
      duration = 'As long as the psychic senses he must feign death, up to a maximum of four days.',
      description = 'It''s easy for the physical psychic to control his body, because that''s the focus of his powers. A state of mind over matter that slows the metabolism to such a degree that it creates a temporary state of suspended animation, simulating death. Without hospital facilities, even a medical doctor is likely to believe the character is dead (1-89% likelihood). The effects of drugs, toxins and chemicals are slowed to a crawl, doing 1/4 damage or effect, but will take full effect the instant the death trance is stopped (unless treatment is administered first). While in the death-like state, the psychic can not be roused or respond to any type of stimulation, including psychic probes. This means he is incapable of attacking or defending himself in any way until the trance is broken.'
  WHERE name = 'Death Trance';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.168',
      range = 'Self',
      duration = '20 minutes per level of experience.',
      description = 'A mind over matter discipline which enables the character to suffer absolutely no ill effects or discomfort from exposure to even extreme freezing conditions.'
  WHERE name = 'Impervious to Cold';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.168',
      range = 'Self',
      duration = '3 minutes per level of experience.',
      description = 'Another mind over matter discipline enabling the psychic to endure intense heat, fire, boiling water, hot coals, and so on, without suffering pain, damage or scarring. Magic fires inflict half damage.'
  WHERE name = 'Impervious to Fire';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.169',
      range = 'Self',
      duration = '10 minutes per level of experience.',
      description = 'I.S.P. cost is per each duration period. This is the ability to completely close or block oneself from all psychic/mental emanations. When intentionally closed to supernatural or psychic forces the character can not sense anything, can not use psychic abilities, nor be influenced by others. A mind block will prevent penetration of telepathy, empathy, hypnotic suggestion, and empathic transfer. It can be an invaluable protective mask when dealing with malevolent psychic forces. Adds a bonus of +1 to save vs all psychic and mental attacks.'
  WHERE name = 'Mind Block';

UPDATE psionic_powers SET
      category = 'Healing',
      source_book = 'Rifts Ultimate Edition p.166',
      range = 'Self',
      duration = 'One hour plus 20 minutes per level of experience.',
      description = 'A mind over matter discipline which enables the character to engage in physical activity without suffering from exhaustion. Although fatigue is temporarily suspended, the psychic will feel extremely tired and may even collapse when the psi-power''s time limit lapses.'
  WHERE name = 'Resist Fatigue';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.169',
      range = 'Self',
      duration = '10 minutes per level of experience.',
      description = 'This psi-power enables the character to draw on his inner reserves of strength to ward off pain and fatigue. Every time the psychic calls upon his inner strength the following bonuses apply: Add +10 S.D.C. Add +2 to save vs poison or toxins. Add +5% to save vs coma/death. Fatigue is temporarily forgotten and the character can function as if he was fully rested for the full duration of the summon inner strength power.'
  WHERE name = 'Summon Inner Strength';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.172',
      range = 'Self (although the image could pertain to people or places thousands of miles away).',
      duration = '6D6 Melees',
      description = 'This allows the psychic to see or feel glimpses of the possible future. Achieved through meditation or intense concentration in which the clairvoyant thinks about a particular person, event or place. Add +5% to the base skill if the person involved is a friend or loved one. Clairvoyance is unpredictable and can not be turned on and off like a light bulb; if the roll is under the base skill it works, otherwise it fails and no insight is received. A trance can be attempted as often as twice every day. The message may be a sudden feeling that somebody is in need, or more often a sudden flash of insight, a brief snippet like a piece of film, often not entirely clear but the potential danger evident. The glimpse into the future could be twenty minutes, eight hours, 24 hours, or a week away, with no way of knowing which. The psychic can NOT engage in any action, combat or otherwise, during a moment of clairvoyance or the image will instantly stop. It usually requires 2D4 melees of concentration before the image occurs. A failed base skill roll means nothing happens but still burns 4 I.S.P. and time. Clairvoyant images may also occur unintentionally as dreams or nightmares, or rarely, unbeckoned while awake.'
  WHERE name = 'Clairvoyance';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.172',
      range = '100ft area (30.5m)',
      duration = 'Two minutes (8 melees) per level of experience.',
      saving_throw = 'Standard; a save vs empathy means the psychic can not get a clear sense of the emotions of that particular person. To save vs empathy the person must roll to save once each melee that the psychic is using empathy. Mind block will prevent any empathic emanations from the blocked person.',
      description = 'Empathy is a psi-ability that makes the psychic aware of, or feel, the emotions of other people, animals and supernatural creatures. The strongest emotions are easiest to sense: hate, anger, terror, love. Feeling for emotions can be used to establish that somebody or something is nearby, but can not be used to pinpoint an invisible or hiding person/creature. Can be helpful in recognizing and communicating with ghosts and other supernatural creatures. Can be used like a lie detector to see if emotions match verbal responses, though this is circumstantial and inadmissible in court. Haunting ghosts and entities rarely mask their emotions, so the psychic can easily tell if one or more is nearby (within 100ft/30.5m) and what it is feeling.'
  WHERE name = 'Empathy';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.175',
      range = '120ft/36m area',
      duration = '2 minutes (8 melees) per level of experience.',
      saving_throw = 'None',
      description = 'Presence sense is a sixth sense which will alert the character to the presence of supernatural and magic creatures in the area. Can not pinpoint location, but gives the impression of whether it is near (within 50ft/15.2m) or far (beyond 90ft/27.4m), and a vague idea of numbers: one (1 or 2), a few (3 to 6), several (7 to 14), or many (15 or more). Can also sense human presences, but with much less accuracy - more a feeling of ''we are not alone,'' with distance undeterminable and numbers limited to a sense of one, two, or many (correct only 50% of the time).'
  WHERE name = 'Presence Sense';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.175',
      range = '60ft and must be visible.',
      duration = '2 melees (30 seconds)',
      saving_throw = 'None, but a mind block will hide the presence of psychic abilities, the level of P.P.E., and possessions by a supernatural force.',
      description = 'All things, organic and inorganic, have an aura which can be seen or sensed. Seeing an aura will indicate: estimate of general level of experience - low (1-3), medium (4-7), high (8th and up); the presence of magic (no indication of what or power level); the presence of psychic abilities; high or low base P.P.E.; the presence of a possessing entity; the presence of an unusual human aberration indicating serious illness, non-human, or mutant, but not which. Can not tell one''s alignment from see aura.'
  WHERE name = 'See Aura';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.176',
      range = '90ft/27.4m',
      duration = 'Until the danger passes or happens',
      saving_throw = 'None',
      description = 'Gives the psychic a precognitive flash of imminent danger to himself or somebody near him within 90ft. The character will not know what the danger is or where it will come from, only that something life threatening will happen within the next 60 seconds (4 melees). Triggered automatically without consent, only by an unexpected, already-set-in-motion life threatening event; cannot be called upon at will. Bonuses (initial melee only): +6 initiative, +2 parry, +3 dodge. Character cannot be surprised by a sneak attack from behind.'
  WHERE name = 'Sixth Sense';

UPDATE psionic_powers SET
      source_book = 'Rifts Ultimate Edition p.177',
      range = 'Read surface thoughts up to 60ft/18.3m away or two-way telepathic communication ' || char(8212) || ' 140ft/32.7m',
      duration = '2 minutes per level of experience',
      saving_throw = 'Conditional. When a person suspects he is being telepathically probed he can resist, getting the standard saving throw. Mind blocks completely prevent telepathic probes or communications as long as the block is up.',
      description = 'Allows the psychic to eavesdrop on a person''s surface thoughts by focusing on that one person; a deep probe into memory is not possible, and only one person can be focused on at a time. Limited directed telepathic communication is also possible, sending a brief clear thought message to one person; two-way communication is not possible except between two telepathic psychics.'
  WHERE name = 'Telepathy';

UPDATE psionic_powers SET
      isp = 2,
      isp_note = '2-4 by ability',
      source_book = 'Rifts Ultimate Edition p.178',
      range = 'Varies',
      duration = 'Varies',
      description = 'Allows amazing physical control over electricity, with several distinct effects: 1) Electrical Resistance - up to 60,000 volts inflict no damage, greater currents (incl. lightning/magic electricity) do half damage; Range: self; Duration: 3 min/level; I.S.P.: 4. 2) Electrical Discharge - causes static electricity in a 6ft area or an electrical discharge by touch inflicting up to 1D6 damage once per melee; Range: touch or 2ft; Duration: Instant; I.S.P.: 2 per discharge. 3) Manipulate Electrical Devices - limited control over electrical devices/appliances, up to a dozen functions per melee; Range: 45ft + 5ft per level; Duration: 2 min/level; I.S.P.: 4. 4) Sense Electricity - sense/pinpoint electricity sources; Range: 45ft + 5ft per level; Duration: 2 minutes of extreme sensitivity; I.S.P.: 2 per two minutes; Base Skill: 55% + 5% per level, failed roll senses only 1D6x10% of sources.'
  WHERE name = 'Electrokinesis';

UPDATE psionic_powers SET
      isp = 2,
      isp_note = '2-5 by ability',
      source_book = 'Rifts Ultimate Edition p.179',
      range = 'Varies',
      duration = 'Varies',
      description = 'Enables use of psychic energy to sense and influence water: 1) Sense Chemical Impurities - determine if water is pure/polluted and general nature of pollutant; Range: self/six inches; Duration: 1 minute (4 melees); I.S.P.: 2 per minute; success 70%+5%/level for purity, 35%+5%/level for pollutant type. 2) Boil Water - raises up to one gallon to boiling within one minute; Range: 8ft + 2ft per level; Duration: 1 minute (4 melees); I.S.P.: 3 per gallon. 3) Water Spout - control/hurl water (must be 75% water) up to one gallon per level up to 20ft; hurling water/hot water can blind, cause loss of initiative/attack, boiling water in face causes 2D4 damage, loss of initiative, loss of all attacks for 1D6 melees, blindness for 3D6 melees (-10 to strike/parry/dodge); Range: 20ft/6.1m; Duration: Instant (bubbling can be maintained 30 seconds); I.S.P.: 5; Bonus: +1 to strike. 4) Sense Water - automatically sense presence of exposed water; Range: 20ft/6.1m; Duration: Permanent; I.S.P.: None.'
  WHERE name = 'Hydrokinesis';

UPDATE psionic_powers SET
      isp = 6,
      isp_note = '6-40 by damage',
      source_book = 'Rifts Ultimate Edition p.180',
      range = '100 feet (30.5 m) per level of experience',
      duration = 'Instant',
      description = 'The psionic focuses psionic energy into a bolt of mental force hurled at a visible target with amazing accuracy. 6 I.S.P. = 1D6 S.D.C. damage, 12 I.S.P. = 3D6 damage, 20 I.S.P. = 6D6 S.D.C. damage, 40 I.S.P. = 2D4 Mega-Damage. All mind bolts are +4 to strike; an additional 10 I.S.P. increases the strike bonus to +8. Ley lines and nexus points increase range and damage.'
  WHERE name = 'Mind Bolt';

UPDATE psionic_powers SET
      isp = 2,
      isp_note = '2-25 by ability',
      source_book = 'Rifts Ultimate Edition p.182',
      range = 'Varies',
      duration = 'Varies',
      description = 'Gives the power to manipulate fire: 1) Fire Resistant - damage from fire/heat reduced by half, magic fires do full damage; Range: self; Duration: 5 min/level; I.S.P.: 2. 2) Spontaneous Combustion - ignites combustible material (not hair); Range: up to 30ft; Duration: Instant, fire spreads until put out; I.S.P.: 2. 3) Fuel Flame - doubles a fire''s size in a 10ft area; Range: 30ft + 5ft per level; Duration: Instant; I.S.P.: 4. 4) Extinguish Flames - instantly puts out a 15ft area of fire; Range: 30ft + 5ft per level; Duration: Permanent until relit; I.S.P.: 4. 5) Create Flame - creates an 8ft pillar (4ft area, 4D6 damage) or a 6ft+ wall of fire (6D6 damage), 72% chance of igniting combustibles; Range: 30ft + 2ft per level; Duration: 2 min/level; I.S.P.: 20. Also can hurl a fire ball for 6D6 damage, Range 30ft + 2ft per level, Instant, +2 to strike, I.S.P.: 25. 6) Sense Fire - sense/pinpoint fire sources; Range: 100ft + 5ft per level; Duration: 2 minutes of extreme sensitivity; Base Skill: 90%, failed roll locates only 2D4x10% of fires; I.S.P.: 2 per 2 minutes.'
  WHERE name = 'Pyrokinesis';

UPDATE psionic_powers SET
      variant_note = 'Palladium Fantasy: 8 I.S.P.'
  WHERE name = 'Commune with Spirit';

UPDATE psionic_powers SET
      variant_note = 'Palladium Fantasy: 6 I.S.P.'
  WHERE name = 'Sense Dimensional Anomaly';

-- Reads the result back rather than trusting the exit code.
--   powers_with_no_description    1 = production's own figure. A rebuild had 21.
--   powers_with_no_source_book   12 = production's own figure. A rebuild had 32.
--   telepathy_has_text            1 = the emblematic row now carries its text
--                                 ON A FRESH BUILD and on production. A
--                                 long-lived local database can read 0 and be
--                                 fine: this machine's holds 81 of the 101
--                                 powers and has no row named Telepathy at
--                                 all. Local is not a mirror; check a build.
--   powers_tagged_to_one_system   0 = untag-cross-system.sql's decision still
--                                 holds. If this is ever non-zero on a REBUILD,
--                                 something here exported `system` and undid it.
--                                 On production it reads 16, which is F15.
SELECT (SELECT count(*) FROM psionic_powers WHERE description IS NULL) AS powers_with_no_description,
       (SELECT count(*) FROM psionic_powers WHERE source_book IS NULL) AS powers_with_no_source_book,
       (SELECT count(*) FROM psionic_powers WHERE name = 'Telepathy' AND description IS NOT NULL) AS telepathy_has_text,
       (SELECT count(*) FROM psionic_powers WHERE system IS NOT NULL) AS powers_tagged_to_one_system;

-- Records this run. One row per run rather than per file: the statements above
-- set absolute values, so this script is safe to re-run, and a run that
-- correctly changed nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-psionic-powers-full.sql');
