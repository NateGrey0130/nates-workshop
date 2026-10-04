-- The Power Leech's creature row follows D-Bees of North America.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~103-power-leech-follows-d-bees.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~103-power-leech-follows-d-bees.sql
--
-- Every other race in this batch gets a NEW creatures row. The Power Leech
-- already has one, from Rifts World Book 12: Psyscape printed 126-128, entered
-- as a monster (playable 0). Rifts World Book 30: D-Bees of North America
-- (2007) reprints it on printed 161-164 as an optional player character and
-- revises it, and the class power-leech cites that printing. By Nate's ruling
-- of 2026-10-04 the newest printing that states a figure wins, so the row is
-- UPDATED in place: one row for one race.
--
-- What D-Bees revises (Psyscape's figure in brackets): absorption range 10
-- feet [5]; a caster whose spell is aimed at the leech gets no save [a save
-- at -4]; the 20 P.P.E. a melee comes only from talismans, amulets and
-- batteries unless the victim is casting [any mage or dragon]; alignment
-- percentages; size 3-4 feet [2.5-4]; life span 3D6+75 years [90-110]; one
-- ancient and one modern W.P. [Paired Weapons and one of choice]; Dance. The
-- attribute dice, M.D.C., P.P.E., I.S.P., combat bonuses and the three punch
-- damages are the same in both books, so the stat_attacks rows are untouched.
--
-- Read off renders of both books and checked against the D-Bees render again
-- by a reader that did not write it. Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET name = 'Power Leech',
       category = 'alien',
       system = 'rifts',
       playable = 1,
       alignment = 'Any, but typically Unprincipled (5%), Anarchist (55%), Miscreant (30%) or Diabolic (5%)',
       attributes = '{"IQ":"2D6+5","ME":"3D6+5","MA":"2D6+3","PS":"2D6","PP":"2D6+5","PE":"2D6+1","PB":"3D6+5","Spd":"2D6+5"}',
       hp = NULL,
       sdc = NULL,
       mdc = '2D6+PE',
       ppe = '5D6',
       isp = 'ME+1D4x10',
       pools_note = 'M.D.C. is 2D6 plus the P.E. number, +1D6 per level of experience. I.S.P. is the M.E. number plus 1D4x10, +2D4 per level. P.P.E. 5D6 is a personal base that nothing can feed on and that does not count as absorbed energy. P.S. is Supernatural. GROWTH: every 100 points of M.D. or P.P.E. absorbed inside one hour adds, cumulatively, 1D4x10+20 M.D.C., 20% size and weight, 1D4 P.S., Horror Factor 1.5 and 2D6+10 I.S.P., and gives bio-regeneration of 2D6 M.D. per minute. The overload lasts 48 hours (longer if another 100 points arrive in a later hour of that span); afterwards no feeding is needed for 1D4 weeks per 100 points taken in one hour. NPC experience level 1D6 or as the G.M. sets; player characters start at level one.',
       ar = NULL,
       horror_factor = NULL,
       combat = '{"strike":1,"parry":2,"dodge":2,"roll":4}',
       bonuses_note = 'Horror Factor: none at natural size, rising 1.5 per growth step. Attacks per melee by Hand to Hand skill, +1 attack per melee round from the R.C.C. +1D4+2 to save vs magic; +5% to every skill needing manual dexterity (Escape Artist, Pick Locks, Demolitions, Mechanical and Electrical skills). All in addition to attribute and skill bonuses. Saves vs psionics as a Major Psychic (12). Hand to hand damage is by Supernatural P.S. and climbs steeply with growth.',
       skills_note = 'R.C.C. skills: Language: Native Tongue 98%, Languages: Other two of choice (+10%), Land Navigation (+10%), Climbing (+20%), Dance (+10%), Prowl (+10%), Palming (+10%), W.P. one Ancient and one Modern of choice, Hand to Hand: Basic (Expert costs two R.C.C. Related skills; no higher). Four related skills at level one, plus two at levels 3, 7, 11 and 15: Communications any; Domestic any (+5%); Electrical Basic Electronics only (+5%); Espionage Escape Artist, Intelligence and Wilderness Survival only; Mechanical Basic Mechanics only; Physical any except Boxing and Body Building; Pilot any; Pilot Related any; Rogue any (+2%); Science Math only; Technical any (+5%); Weapon Proficiencies any; Cowboy, Medical, Military and Wilderness none. Two secondary skills at levels 1, 5 and 10.',
       natural_abilities = 'Human-shaped but small and slight, nimble, ambidextrous and psychic, with pale rubbery M.D. skin. ENERGY ABSORPTION: feeds by touch or from within 10 ft (3 m) on ley line P.P.E. (15 points an hour), batteries, E-Clips and generators, and on anything energetic aimed its way. Energy bolts, radiation, lightning, nuclear blasts and any spell thrown at it are swallowed whole and do it no harm; an area blast is swallowed too, sparing bystanders. One M.D. of such an attack equals one P.P.E. point. Yields: flashlight or radio battery 0.25 M.D.; car battery 2 M.D.; full E-Clip about 200 M.D. (long clip 300); nuclear power armor, robot, vehicle or medium nuclear bomb about 2,000 M.D. at 200 M.D. a minute; a city power plant 200 M.D. per minute. It may sip a source or empty it. MAGIC: a spell aimed at the leech is eaten with no save for the caster. A caster it touches or stands within 10 ft (3 m) of saves vs psionic attack at -4: failure means the spell never happens and its P.P.E. is lost to the leech; success means the spell works at one third damage, effect, duration and range while the leech still takes 1D4x10% of the P.P.E. Talismans, amulets, TW batteries and P.P.E. clips lose up to 20 P.P.E. per melee round; Rune Weapons and Techno-Wizard devices themselves are immune. A person''s own P.P.E. is out of reach unless given up in ritual or blood sacrifice within that range. NOT ABSORBED: kinetic damage (M.D. punches, kicks, blunt and bladed weapons, arrows, bullets, rail gun rounds, ordinary M.D. explosions) and cold do full damage.',
       magic = 'None; cannot cast spells at all',
       psionics = 'Major Psychic (saves at 12): Mind Block, Mind Bolt, See Aura, Sense Magic, Telekinetic Punch, Telekinetic Push, plus two of choice from the Healing or Physical categories.',
       size = '3-4 feet (0.9 to 1.2 m); grows 20% per 100 points of energy absorbed',
       weight = '50-80 lbs (22.5 to 36 kg); grows 20% per 100 points of energy absorbed',
       life_span = '3D6+75 years; physically mature by age 11',
       habitat = 'Anywhere, and scattered across the Megaverse; fewer than 200 on Rifts Earth as of 109 P.A., a third of them roaming North America, the Magic Zone especially',
       allies = 'Most clans that came to Earth are sworn citizens of Psyscape; individuals befriend anyone of like alignment and get along with most people',
       enemies = 'None as such',
       occ_note = 'Optional player character and NPC, allowed only if the G.M. agrees: the book notes the race was not first written for players. Available O.C.C.s: none; the R.C.C. has its own skills and its own experience table. No cybernetics or bionics (they hinder its psionics and growth). Gear: durable clothes, a backpack and sleeping bag, a utility belt with pouches, a canteen and a survival knife, one weapon per W.P. with 1D4 spare E-Clips; rarely any armor. Money 3D6x100 credits plus 2D4x1,000 credits in trade or Black Market goods.',
       description = 'Small D-Bees that pass for human children: big heads, large innocent eyes, round bellies, thin limbs, and a playful curiosity that never fades with age. Cute, friendly and selfish, they come from a world battered by solar flares, radiation and ley line storms, where soaking up energy through the skin is how they eat. A ley line storm stranded a small number on Rifts Earth. One that gorges swells into a giant for two days while the machines and mages it drained are left powerless. Psyscape printed 126-128 (1997), which this row followed until ~103, gave an absorption range of 5 feet, a save at -4 for a caster whose spell is aimed at it, 20 P.P.E. a melee drawn from any mage, dragon or battery, a size of 2.5 to 4 feet and a life span of 90 to 110 years, and printed it as a monster not meant for players.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.161-164'
 WHERE slug = 'power-leech'
   AND source_book = 'Rifts World Book 12: Psyscape p.126-128';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Power Leech is one playable row citing D-Bees' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'power-leech' AND playable = 1 AND source_book = 'Rifts World Book 30: D-Bees of North America p.161-164';

SELECT 'and it still owns its three punches' AS assertion, count(*) AS got, 3 AS want
  FROM stat_attacks WHERE owner_kind = 'creature' AND owner_slug = 'power-leech';

INSERT INTO data_script_runs (filename) VALUES ('~103-power-leech-follows-d-bees.sql');
