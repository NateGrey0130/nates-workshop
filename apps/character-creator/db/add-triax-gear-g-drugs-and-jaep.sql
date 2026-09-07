-- The four JAEP enhancement programmes and the three designer drugs this book
-- prints that the catalog does not already hold. Printed 175-178. Seven rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-g-drugs-and-jaep.sql
--
-- PRINTED 175-178 IS NOT IN THE SURVEY'S GEAR PLAN. That plan covers printed
-- 34-38, 141-154, 205 and 210-214, and none of 175-178 - so these seven rows
-- were found by reading the Euro-Juicer's own pages during the class batch
-- rather than by the survey's diff. Recorded in BOOK-INGEST-QUEUE.md at the
-- time.
--
-- THREE OF THIS BOOK'S SIX DESIGNER DRUGS ARE ALREADY IN THE CATALOG and are
-- NOT duplicated: boing-go, crash and rush, all imported from Rifts World Book
-- Ten: Juicer Uprising. They are the same drugs - Triax and Juicer Uprising
-- print the same durations and effects - but they are NOT priced the same:
--
--     drug       Triax p.176-178      catalog, from Juicer Uprising
--     boing-go   20 to 50 credits     30 to 60 credits
--     crash      100 to 200 credits   150 to 300 credits
--     rush       50 to 100 credits    65 to 120 credits
--
-- The catalog wins and a disagreement is not a gap, so nothing is overwritten
-- and no second row is made. The Triax figures are recorded HERE, in this
-- header, rather than in three rows belonging to another book.
--
-- THE FOUR JAEP PROGRAMMES ARE GEAR, on the same reading that puts the designer
-- drugs and the bio-comp system in "gear": they are priced, purchasable
-- chemical augmentation. Note that JAEP is explicitly CLOSED to Juicers, Robots
-- and Borgs, which is why the Euro-Juicer O.C.C. carries a restriction saying
-- so - the one class in the book that cannot buy any of these four.
--
-- Every figure here was read off a 200 dpi render of the page as well as the
-- OCR: the four market costs on printed 176, and the three per-dose prices on
-- printed 177 and 178.
--
-- Sorts after add-triax-gear-f-gargoyle-weapons.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('drug-euphie', 'Euphie', 'rifts', 'gear', NULL, 30, '30 to 60 credits per dose', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Designer drug, short for euphoria: it makes the user happy, giggly and without a care, anger or fear in the world. Duration: 1D4 hours. Bonuses: +3 to M.A. and all the bonuses that follow from it, +5 to save versus horror factor, +2 to save versus illusion and empathic transmission, and +3 to roll with impact, punch or fall; the character is completely relaxed, cheerful, friendly and fearless. Penalties: so relaxed and fearless that he takes foolish risks and will not avoid danger, and is likely to be oblivious to injury and blood loss in himself and everyone around him - -4 on initiative, speed reduced by 20%, -1 attack per melee, and -20% on skill performance. Addictiveness: HIGH. More than once a week and the character is an addict, craving it 1D4 times daily and suffering the penalties all the time, high or not. After six months he cannot bear to face the world without it, avoids people and conflict except when high, and turns paranoid about anyone who speaks against it.', 'Rifts World Book 5: Triax and the NGR p.177'),
('drug-psike-b', 'Psike-B', 'rifts', 'gear', NULL, 25, '25 to 50 credits per dose', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Designer drug that clouds the mind and interferes with psionic powers, working like a mind block on a non-psychic. Duration: 1D6x10 minutes. For a NON-PSYCHIC the bonuses are real: impervious to empathic and telepathic communication, mind bond and psionic possession, and +1 to save against other psionic attacks - at the cost of feeling drunk, -30% on skills, and a lost sense of time and detail. For a PSYCHIC it is all penalty: powers are blocked and cannot be used without intense concentration, and then at twice the I.S.P. for half the duration and range. It also triggers an automatic mind block, cutting off empathic and telepathic contact whether the psychic wants it or not, and brings a pounding headache, a twitching eyelid, and memory loss severe enough to forget his own name, his past, his friends and his skills (01-50% a skill is forgotten outright, 51-00 it is remembered at -30%), with all sense of direction and time gone and attacks per melee and combat bonuses halved. Memory, powers and skills all return when it wears off. Addictiveness: MEDIUM for non-psionics, at more than four times a week; psionic characters avoid it.', 'Rifts World Book 5: Triax and the NGR p.177-178'),
('drug-psike-e', 'Psike-E', 'rifts', 'gear', NULL, 30, '30 to 75 credits per dose', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Designer drug: a mild hallucinogenic and minor euphoric for the average person, and something far stronger for a psychic. Duration: 2D4x10 minutes. Bonuses: the duration and range of psionic powers increase by 50%, the psychic is +2 to save against most psionic attacks, and can sense other psychics and see their auras. Penalties: -5 to save against mind control and possession, -10 to save against magic illusions and other hallucinogens, disoriented at -20% on skill performance, and no sense of time; dazed and slow to react at -1 on initiative and one melee action lost. Afterwards the recollection of what happened while high is foggy and incomplete, and there is a 01-50% chance of one or two drug-induced hallucinations, happy or frightening. Addictiveness: MEDIUM, at more than four times a week. Most psychics avoid it because it is more debilitating than helpful.', 'Rifts World Book 5: Triax and the NGR p.178'),
('jaep-physical-enhancement', 'JAEP: Physical Enhancement', 'rifts', 'gear', NULL, 125000, 'Market cost 125,000 credits. Recommended length of the programme: three months, followed by three months of abstinence', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Juicer Augmentation Enhancement Programme - "jape" - focused on the body. Steroids, hormones and other chemicals bulk up the muscles and speed the reflexes. Bonuses: +6D6 to S.D.C., +4 to P.S., +2D4 to Spd, +1 on initiative, +1 to strike, parry and dodge, and +2 to save against disease, poisons and toxins. ANY human character of any O.C.C. except a Juicer, Robot or Borg may use JAEP, and only one programme at a time - two at once causes an overdose and 1D4 of cardiac arrest, stroke, convulsions with paralysis, or permanent brain damage. It is not recommended for anyone using bio-wizardry augmentation or M.O.M. implants, nor for psionics or alien life forms.', 'Rifts World Book 5: Triax and the NGR p.176'),
('jaep-speed-enhancement', 'JAEP: Speed Enhancement', 'rifts', 'gear', NULL, 85000, 'Market cost 85,000 credits. Recommended length of the programme: three months, followed by three months of abstinence', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Juicer Augmentation Enhancement Programme focused on speed: drugs that accelerate the metabolism and bulk up the muscles. Bonuses: +2D6 to S.D.C., +1 to P.S., +1 to P.P., +5D6 to Spd, one additional attack or action per melee round, +2 to dodge, +2 to pull a punch and +2 to roll with impact.', 'Rifts World Book 5: Triax and the NGR p.176'),
('jaep-healing-enhancement', 'JAEP: Healing Enhancement', 'rifts', 'gear', NULL, 85000, 'Market cost 85,000 credits. Recommended length of the programme: three months, followed by three months of abstinence', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Juicer Augmentation Enhancement Programme focused on recovery: the character heals from injury and sickness twice as fast as normal. Bonuses: +5 to save against disease, +3 to save against poisons, drugs and toxins, and +10% to save against coma and death.', 'Rifts World Book 5: Triax and the NGR p.176'),
('jaep-mental-enhancement', 'JAEP: Mental Enhancement', 'rifts', 'gear', NULL, 95000, 'Market cost 95,000 credits. Recommended length of the programme: three months, followed by three months of abstinence', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Juicer Augmentation Enhancement Programme focused on the mind: chemical stimulants and other drugs sharpening alertness and mental stamina. Bonuses: +2% on all skills, +2 on initiative, +1 to save against psionic attack, +2 to save against mind control drugs, and productivity increased by 33%.', 'Rifts World Book 5: Triax and the NGR p.176');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 'jaep-%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-g-drugs-and-jaep.sql');
