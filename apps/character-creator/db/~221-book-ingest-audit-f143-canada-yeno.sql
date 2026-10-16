-- The Yeno's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Canada part 4 of 4).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~221-book-ingest-audit-f143-canada-yeno.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~221-book-ingest-audit-f143-canada-yeno.sql
--
-- The class yeno follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 215-217, but its creatures row still cited Rifts World
-- Book 20: Canada printed 139-140 and carried its figures. By Nate's ruling
-- of 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Canada's figure stays. A complete line D-Bees restates without an item
-- drops that item: the Available O.C.C.s line (Grunt and Spy/Espionage
-- agent), the Enemies line (looking down on humans) and the Habitat line
-- (the dozen rumored at Tolkeen and the New West, and the violence in
-- Ontario and Quebec). creatures has no notes column, so each Canada figure
-- that changed is kept in description with its printed page.
--
-- Body and field: D-Bees makes the body an S.D.C. one, Hit Points 1D6 plus
-- the P.E. number and 5D6+30 S.D.C., and moves Canada's 2D4x10+P.E. (+3D6
-- per level) from the body to the force field. By Nate's ruling of
-- 2026-10-16 hp is '1D6+PE', sdc '5D6+30', mdc NULL, and the field's figure
-- is written in pools_note, the way vallax carries its force field. The
-- combat keys (initiative and roll, +2 each) are the same in both books, so
-- the key set is unchanged and the row keeps its shape (F141); the new
-- Perception, disarm, pull punch and per-level strike bonuses are in
-- bonuses_note. The five energy bolt stat_attacks rows (4D6 S.D.C.,
-- 2D4x10 S.D.C., 1D6, 2D6 and 4D6 M.D.) are the same in both books, and this
-- script writes none.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the
-- row still citing Canada, so a re-run is a no-op. THIS SCRIPT CHANGES
-- PRODUCTION: one creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but most are Anarchist (30%), Miscreant (30%) or Diabolic (30%)',
       hp = '1D6+PE',
       sdc = '5D6+30',
       mdc = NULL,
       horror_factor = 11,
       pools_note = 'Hit Points: 1D6 plus the P.E. number, +1D6 per level of experience from level one (the per-level part is printed as M.D.). S.D.C.: 5D6+30, plus any gained from Physical skills. M.D.C. only from body armor or the natural force field. Force field: 2D4x10 M.D.C. plus the P.E. number, +3D6 M.D.C. per level of experience from level one. On an S.D.C. world: Hit Points 1D6x10 plus the P.E. number, S.D.C. 1D6x10, +1D6 H.P. per level, Natural A.R. 10, and the force field counts as S.D.C. point for point with an A.R. of 19.',
       bonuses_note = '+2 on Perception Rolls. +3 to strike with natural energy blasts only, +1 at levels 3, 5, 7, 10 and 13. +1 to disarm, +1 to pull punch. +4 to save vs Horror Factor. All in addition to attribute bonuses. Attacks per melee are those of the Hand to Hand skill, plus two more that may be spent only on energy blasts, not on hand to hand combat or guns. Whether the force field goes up in time to block an attack is an initiative roll, with +2 at levels 1, 3, 4, 6, 8, 10, 12 and 14 for raising the field only. Vulnerabilities: an alien appearance makes disguise difficult. Phobia of darkness: blinded or trapped in darkness it tends to panic, and on top of the normal penalties for blindness takes -3 to all combat maneuvers (-13 in all), half its attacks per melee and Spd, and -30% on skills. Also dislikes small, cramped places and being in, on or over water, boating included.',
       natural_abilities = 'Sharp, hawk-like vision across every spectrum of light, infrared and ultraviolet included; cannot be blinded by bright light or glare. Energy attacks do half damage; kinetic ones (M.D. punches, kicks, claw strikes, rail guns, explosives) do full. Fire Energy Bolts: blasts from hands and eyes at a chosen strength, 4D6 S.D.C., 2D4x10 S.D.C., 1D6 M.D., 2D6 M.D. or 4D6 M.D., each one a melee attack; range 1000 feet (305 m) +30 feet (9.1 m) per level. Blinding Flash: a beam at one target or a flash all around, as the spell of that name. Generate Light: the hands glow like a low lantern, lighting about six feet (1.8 m) ahead, which does not ease it when trapped in total darkness. Force Field: raised by thought (figures in pools_note) and kept up as long as it is conscious; the field regains 12 M.D.C. an hour, twice that asleep or meditating. Once depleted it cannot be raised again for at least an hour, and comes back at only 12 M.D.C., building hourly.',
       psionics = 'None, other than the art of Meditation at no I.S.P. cost',
       life_span = '6D6+170 years; physically mature by the age of 19',
       habitat = 'Can be found anywhere, but most common in Manitoba, Ontario, Quebec, Wisconsin, Minnesota, the Dakotas and the New West. Once believed to number fewer than 2,000 in all of North America, a figure since adjusted to three times as many',
       allies = 'Other killers, bandits and cutthroats. Though they would never show or admit it, they rather like humans and Grackle Tooth; they hate Kraks, Fingertooth and other nice or friendly people',
       enemies = 'Anybody who gets in their way, causes them trouble or gets on their nerves; a strong dislike of the CS, Cyber-Knights, lawmen in general, Psi-Stalkers and Quick-Flex aliens. Little respect for life, they see most other races as inferiors or rivals, and they hate the undead',
       occ_note = 'Optional player character and NPC. Available O.C.C.s: nearly any, but most lean toward Assassin, Spy, Bandit, Bounty Hunter, Gunfighter, Gunslinger, Commando, Special Forces, Merc Soldier and other Men at Arms, military or criminal O.C.C.s, seldom any other profession. Never magic. Juicer and Crazy conversions are impossible, and they avoid bionic reconstruction: with more than half the body replaced by bionics their energy powers are halved (damage, range and so on). Experience level 2D4 for NPCs, player characters start at first level, on the chosen O.C.C.''s table. Equipment and money as per O.C.C.; they favor powerful, accurate energy weapons. Slave market value 1D6x10,000 credits.',
       description = 'Energy Weavers or Energy Men: rare, lanky humanoids whose scaly skin is red, orange and yellow, with a melon-shaped head, glowing yellow eyes, three-fingered hands and two-toed feet. Permanently foul-tempered and quick to kill, they soak up and throw energy and are notorious as assassins and hired guns. Canada printed 139-140, which this row followed until ~221, made the body itself a minor M.D.C. creature of 2D4x10 plus the P.E. number, +3D6 per level, with no Hit Points or S.D.C. on Rifts Earth, and gave the force field 30 M.D.C. +10 per level (30 S.D.C. +10 per level on an S.D.C. world). It also gave no Horror Factor; the alignment with no percentages; a life span uncertain, at least 200 years and quite possibly longer; sharp vision with no infrared, ultraviolet or glare immunity, and no Blinding Flash or Generate Light; no Perception, disarm or pull punch bonus, no per-level strike bonus and no force-field initiative bonus; no vulnerabilities, experience level, bionics rule or slave value; the art of meditation with no I.S.P. cost named; the O.C.C.s as Assassin, Commando, Special Forces, Spy/Espionage agent, Grunt, Bandit, Bounty Hunter or Gunslinger; allies as other cutthroats only; enemies as whoever messes with them, looking down on humans and most other races; and a habitat with about a dozen rumored at Tolkeen and the New West, those in Ontario and Quebec making themselves known through violence, and fewer than 2000 in all.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.215-217'
 WHERE slug = 'yeno'
   AND source_book = 'Rifts World Book 20: Canada p.139-140';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Yeno cites D-Bees and not Canada' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yeno'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.215-217';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yeno'
   AND hp = '1D6+PE'
   AND sdc = '5D6+30'
   AND mdc IS NULL
   AND horror_factor = 11
   AND life_span LIKE '6D6+170 years%'
   AND instr(pools_note, 'Force field: 2D4x10 M.D.C.') > 0;

SELECT 'the combat keys are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yeno'
   AND combat = '{"initiative":2,"roll":2}';

SELECT 'it keeps the Canada figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yeno'
   AND instr(description, 'which this row followed until ~221') > 0;

SELECT 'and its five energy bolt stat_attacks rows are untouched' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'yeno'
   AND name LIKE 'Energy Bolt (%';

INSERT INTO data_script_runs (filename) VALUES ('~221-book-ingest-audit-f143-canada-yeno.sql');
