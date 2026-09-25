-- The sixteen psionic powers Rifts World Book 12: Psyscape adds that the
-- catalog does not already hold: Astral Golem (Super, printed 42) and the
-- fifteen Mind Bleeder powers (printed 45-48), which go in as a new category,
-- `Mind Bleeder`.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-psyscape-psionic-powers.sql
--
-- WHICH SIXTEEN. The book's Complete Alphabetical Listing (printed 35-36)
-- marks 43 powers New. catalog-diff --remote on 2026-09-25 matched 25 of them
-- to rows Rifts Ultimate Edition reprinted, one more by alias (Commune with
-- Spirits), and one is the listing's misprint "Pyschic Body Field", which the
-- description heading on printed 43 spells correctly and the catalog holds.
-- Telekinetic Acceleration Attack is listed Physical here and filed Super by
-- RUE; the later edition wins and that row is not touched. The survey
-- (apps/character-creator/docs/surveys/psyscape.md) has the whole diff.
--
-- WHY A NEW CATEGORY IS SAFE. `Phase` (add-phase-world-phase-powers.sql, #417)
-- established it and checked the reason: the category field allows other
-- values, and a class that states no categories_allowed defaults to the core
-- four, so only a class naming `Mind Bleeder` reaches these rows. The book
-- lists them apart from the four core categories, as powers of the Mind
-- Bleeder R.C.C.; that class is a later PR of this book.
--
-- `isp` holds the MINIMUM cost, the catalog's convention (Telekinetic
-- Acceleration Attack, 10-20, holds 10), and isp_note carries the rest where
-- the book prints a schedule. Every cost here is printed twice, in the listing
-- and in the power's own block, and the two agree on all sixteen.
--
-- The descriptions are paraphrased from the book with every mechanic kept -
-- numbers, penalties, durations and defences - not transcribed.

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Astral Golem', 'Super', 50, 'plus 10 to mentally animate and control it; repairs cost 1 I.S.P. per 2 M.D.C. (200 S.D.C.) restored', 'rifts', 'One mile (1.6 km) per level of experience.', 'Special', NULL, 'Known only to psychics trained in Psyscape, and usable only on the Astral Plane. The psychic shapes the loose ectoplasm of the Astral Plane, mixed with some of his own, into a large construct - human to double human size, whitish or light grey, semi-translucent and faintly glowing, usually humanoid - and animates it like a stringless puppet. It is not alive: it cannot see, hear, feel, think or act on its own, and it must stay in the psychic''s sight, rarely sent more than a few hundred feet away. It floats and flies naturally, and is used for carrying, defence and combat. Stats: Horror Factor 8 (human-sized) or 10 (giant-sized); supernatural P.S. 18, Spd 16+1D6; attacks per melee equal to its creator''s, and each of its actions counts as one of the psychic''s; punches and kicks do 1D6 M.D. to other Astral beings, and it can damage any Astral being; -2 on initiative, -1 to parry and dodge; 3000 S.D.C./30 M.D.C. Impervious to most psionic attacks, mind control, fear, possession, cold, heat, disease, poison and gases; energy and projectile attacks do half damage; vulnerable to physical attacks by other Astral beings.', 'import', 'Rifts World Book 12: Psyscape p.42'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Astral Golem');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Bleed P.E. Energy', 'Mind Bleeder', 10, NULL, 'rifts', 'Four feet (1.2 m) per level of experience.', 'Instant', 'Standard', 'Usable only when the Mind Bleeder is physically fatigued or needs sleep. He siphons physical stamina from a living being - human, D-Bee or animal. The victim tires twice as quickly as normal and temporarily loses 1D4 S.D.C. The Mind Bleeder is instantly refreshed and no longer fatigued, and gains 1D4 S.D.C. toward healing his wounds. If he has gone unusually long without sleep, the stolen energy keeps him awake and alert for another 1D4 hours without the effects of sleep deprivation.', 'import', 'Rifts World Book 12: Psyscape p.45'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bleed P.E. Energy');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Bleed Aura', 'Mind Bleeder', 6, NULL, 'rifts', 'Four feet (1.2 m) per level of experience.', 'Instant', '-2 to save.', 'Copies the aura of another living being - human, D-Bee or large animal - to disguise the Mind Bleeder''s own aura completely. As a side effect the victim''s aura is distorted: anyone reading it finds it very hard to see and is badly wrong about the victim''s level, health and the other things an aura usually shows.', 'import', 'Rifts World Book 12: Psyscape p.45'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bleed Aura');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Bleed Memory', 'Mind Bleeder', 6, 'per thought', 'rifts', 'Four feet (1.2 m) per level of experience.', 'Instant', '-2 to save.', 'A limited but powerful telepathy, for non-combat use only. The Mind Bleeder focuses on one very specific thought - a code word or number, a lock combination, a name, an address - of up to four words or a 24-digit sequence, and plucks it from the victim''s mind. He can also catch the last one to four words of what someone is about to say, a second before they say it, which lets him pretend to knowledge he does not have. Only a mind block is an absolute defence; otherwise the victim saves vs psionic attack as usual.', 'import', 'Rifts World Book 12: Psyscape p.45'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bleed Memory');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Bleed Skills', 'Mind Bleeder', 15, 'per skill; one skill per level of experience', 'rifts', 'Self, and the victim must be within four feet (1.2 m).', 'Five minutes per level of experience.', 'Standard', 'Temporarily takes another character''s non-combat skills along with his level of proficiency in them: one skill per level of the Mind Bleeder, at 15 I.S.P. each. While it lasts the Mind Bleeder performs the skill at the victim''s level, and the victim has trouble remembering and doing it: -50% and it takes twice as long. When the duration ends the Mind Bleeder forgets the skills completely and the victim is fully restored. Only a mind block is an absolute defence; otherwise the victim saves vs psionic attack as usual. A sleeping or unconscious victim gets no save.', 'import', 'Rifts World Book 12: Psyscape p.45-46'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bleed Skills');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Bleed Truth', 'Mind Bleeder', 8, 'per thought, key word or phrase', 'rifts', 'Four feet (1.2 m) per level of experience.', 'Instant', 'Standard', 'A limited telepathy for non-combat situations. The Mind Bleeder focuses on one key word or phrase the target says and gets an instant word association from what the target is really thinking, which tells him whether the statement is true - a hostile association to a promise of peace marks a lie. Useful for uncovering traps and truths, but the association is limited and not always clear. No association at all means the target saved or has a mind block, and a mind block should raise suspicion. Only a mind block is an absolute defence; otherwise the target saves vs psionic attack as usual.', 'import', 'Rifts World Book 12: Psyscape p.46'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bleed Truth');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Brain Bleed', 'Mind Bleeder', 10, NULL, 'rifts', '10 feet (3 m)', 'Four minutes per level of experience.', NULL, 'The victim''s head throbs, he hears his heartbeat and the rush of blood in his ears, and feels as if his head is about to explode, with a sense of panic. Penalties for the duration: all skills -40%, all combat bonuses halved, -4 to save vs Horror Factor, empathic transmission, mind control drugs and magic illusions, and speed reduced by 25% unless fleeing.', 'import', 'Rifts World Book 12: Psyscape p.46'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Brain Bleed');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Brain Scan', 'Mind Bleeder', 10, NULL, 'rifts', 'Touch', 'Varies', NULL, 'Scans a brain to locate and identify physical and mental aberrations, damage and impairment: bruises, tumors, aneurysms, disease, mental blocks, hypnotic suggestions, phobias, obsessions, traumas, magic insanities, magic curses and similar. It reveals nothing of the subject''s personality, memories, skills or thoughts. A brain scan is required before mental blocks, magic insanity and other insanities can be removed (see Mental Block Removal).', 'import', 'Rifts World Book 12: Psyscape p.46'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Brain Scan');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Day Dream', 'Mind Bleeder', 8, NULL, 'rifts', 'Four feet (1.2 m) per level of experience.', 'Two minutes per level of experience.', 'Standard', 'Works only on a victim who is not in combat or other intense activity - sedentary, relaxed or bored, like a guard, a reader, or someone resting or eating. It calls up a random pleasant memory and the victim day dreams about it: -10 on initiative; speed and attacks halved for the first melee round of action; does not notice intruders or pickpockets with a Prowl or Pick Pockets skill of 60% or better; and takes 4D4 seconds to notice a knock, a scream, a ringing phone or an alarm. Once activity breaks the day dream, every penalty ends.', 'import', 'Rifts World Book 12: Psyscape p.46'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Day Dream');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Healing Leech', 'Mind Bleeder', 6, NULL, 'rifts', 'Touch', 'Instant', 'Standard', 'An injured Mind Bleeder heals himself from another creature. For 6 I.S.P., touching the creature, a victim who fails to save loses six hit points and six S.D.C., which the Mind Bleeder gains; his wounds visibly close. He can drain one victim down to about half its normal hit points and must then find another. Victims of the leech recover twice as fast as normal.', 'import', 'Rifts World Book 12: Psyscape p.46-47'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Healing Leech');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Impervious to Bio-Manipulation', 'Mind Bleeder', 10, NULL, 'rifts', 'Self', 'Four minutes per level of experience.', NULL, 'Used before a psionic bio-manipulation attack, the Mind Bleeder automatically saves against it. Used after being affected, it negates the attack''s effects for its duration, which may be shorter than the attack''s own.', 'import', 'Rifts World Book 12: Psyscape p.47'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Impervious to Bio-Manipulation');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Mental Block', 'Mind Bleeder', 10, '10 for a simple block, 30 for a severe one', 'rifts', 'Touch', 'Varies', 'Standard', 'A form of hypnotism and mind control that plants blocks in the victim''s memory. A simple block is a small pocket of memory loss: a name (never his own), a face, an object, an address, a code or password, a lock combination. A severe block hides much more: the events of a particular hour, ever having met the Mind Bleeder or others, or one specific skill or memory. Victims with psionics or a high M.E. feel a nagging sense that something is wrong whenever they meet the blocked subject. Only a mind block defends; otherwise the victim saves vs psionic attack. A block can be removed only by a Mind Bleeder (Mental Block Removal) or by another powerful psychic through a mind bond.', 'import', 'Rifts World Book 12: Psyscape p.47'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Mental Block');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Mental Block Removal', 'Mind Bleeder', 12, 'per block removed: 12 simple mind block, 35 severe mind block, 40 to break mental/magic/supernatural possession, 40 to break magic or chemical mind control, 80 for a magic insanity or curse, 100 for one phobia or obsession, 200 for a trauma or other serious insanity', 'rifts', 'Touch', 'Varies', NULL, 'Only the Mind Bleeder can find and remove mental blocks without enduring a full mind bond. He must first perform a Brain Scan, which locates every block and trauma, then removes them one at a time, paying I.S.P. for each (see the cost schedule). Curing a genuine insanity - phobia, obsession, disorder, trauma - is likely to be temporary: exposure to a similar traumatic situation brings it back on 1-75%. Insanities caused by M.O.M. conversion cannot be removed.', 'import', 'Rifts World Book 12: Psyscape p.47'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Mental Block Removal');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Mind Trip', 'Mind Bleeder', 6, NULL, 'rifts', '10 feet per level of experience; the victim must be visible.', 'Four minutes per level of experience.', 'Victims are -1 to save.', 'Makes the victim slip up mentally or physically. Reading, calculating or pricing, he makes an error of 1D4x10%, always in the Mind Bleeder''s favour. It can also make him misread the time, mis-measure ingredients for food or a potion, misread or misquote text, get tongue-tied or mispronounce a name, make typing errors, or fumble a skill (-10%). In combat it makes an attacker hesitate or stumble: his strike, parry, dodge or initiative bonuses are halved for that one melee action only.', 'import', 'Rifts World Book 12: Psyscape p.47'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Mind Trip');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Neuro-Touch', 'Mind Bleeder', 4, 'by effect: Stumble 4, Jolt 6, Momentary Stun 10, Disorientation 12, Paralysis of Arms 14; double the cost when used as a purely mental attack at up to 10 feet', 'rifts', 'Touch or 10 feet (3 m)', 'Varies', 'Standard', 'A neurological disruption of the brain with one of five effects, chosen at use. Stumble: loses control of his legs for an instant and loses one melee action. Jolt: a light electric-like shock for 1D4 S.D.C./hit points (one M.D. to a mega-damage creature), usually a warning. Momentary Stun: for seven or eight seconds loses initiative and half his attacks, and is -4 to parry and dodge. Disorientation: blurred vision, -3 on initiative, strike, parry, dodge and roll with impact, speed halved and one melee action lost, for one melee round per level of the Mind Bleeder. Paralysis of Arms: the arms and hands go limp - nothing can be held, and no hand to hand attack or hand-operated machine is possible - leaving only evasion, psionics, magic or voice commands, for one melee round per level of the Mind Bleeder.', 'import', 'Rifts World Book 12: Psyscape p.47-48'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Neuro-Touch');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Neural Strike', 'Mind Bleeder', 25, NULL, 'rifts', 'Touch or five feet (1.5 m) per level of experience.', 'Varies', 'Standard', 'An attack on the brain with one of two effects. Hit point attack: 2D6 damage direct to hit points (2D6 M.D. to a mega-damage creature); the victim also loses one melee action and the initiative, his speed drops 25% for one melee per level of the attacker, and a pounding headache gives -10% on skills for 30 minutes (headaches from repeated strikes add their time together). Paralysis of motor responses: the legs are paralysed and the arms numb and trembling - no movement, attacks reduced to one per melee and every combat action at -10 - for one melee round per level of the Mind Bleeder.', 'import', 'Rifts World Book 12: Psyscape p.48'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Neural Strike');

-- Read the result back. This batch asserts its OWN rows and nothing else.
SELECT 'sixteen psyscape powers inserted' AS assertion, count(*) AS got, 16 AS want
  FROM psionic_powers WHERE source_book LIKE 'Rifts World Book 12: Psyscape p.%';

SELECT 'fifteen in the Mind Bleeder category' AS assertion, count(*) AS got, 15 AS want
  FROM psionic_powers WHERE category = 'Mind Bleeder';

SELECT 'Astral Golem is a Super power at 50' AS assertion, count(*) AS got, 1 AS want
  FROM psionic_powers WHERE name = 'Astral Golem' AND category = 'Super' AND isp = 50;

SELECT 'the variable costs keep their minimum' AS assertion, count(*) AS got, 4 AS want
  FROM psionic_powers WHERE category = 'Mind Bleeder'
   AND ((name = 'Mental Block' AND isp = 10) OR (name = 'Mental Block Removal' AND isp = 12)
     OR (name = 'Neuro-Touch' AND isp = 4) OR (name = 'Neural Strike' AND isp = 25));

SELECT 'every one carries a description' AS assertion, count(*) AS got, 16 AS want
  FROM psionic_powers WHERE source_book LIKE 'Rifts World Book 12: Psyscape p.%' AND length(description) > 150;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-psyscape-psionic-powers.sql');
