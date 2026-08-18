-- Twenty-two psionic powers from the Rifts Ultimate Edition psionics chapter
-- that the catalog did not carry, extracted through the session importer
-- (session 907: four page-range passes plus three seam sweeps over the chunk
-- boundaries) and confirmed after review.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-rue-psionics-batch.sql
--
-- ON CONFLICT (name) DO UPDATE rather than INSERT OR IGNORE, deliberately:
-- the environment this was reviewed in already holds the rows, and the upsert
-- makes this script the authoritative bytes in both environments - it also
-- normalises two descriptions whose extraction carried an em-dash, since
-- passing one through `wrangler d1 execute` on Windows has produced mojibake
-- before. Pure ASCII on purpose, for the same reason.
--
-- The 56 powers the chapter shares with the existing catalog were left
-- untouched on review. Three of them (Mind Block Auto-Defense, Mind Bolt,
-- Mind Wipe) print variable/special I.S.P. costs that the extraction staged
-- as 0; the stored numbers predate this import and were kept - a zero would
-- read as free and match the stub heuristic.

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Advanced Trance State', 'Super', 10, 'Self', 'Up to 8 hours per level of experience.', 'None', 'This meditation state puts the psychic into a deep trance in which he can heal at double the normal rate and recover 12 I.S.P. per hour (no additional bonus for the Mind Mage). While in the trance, the psychic hovers in mid-air sitting or prone. Alternatively, the psychic can enter suspended animation/stasis sleep, slowing metabolism to one-tenth normal, needing only one-tenth normal air and no food/water, and stopping toxin/drug/disease effects (must remain at least two days to destroy them). The character can still sense danger and wake instantly to defend himself.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Attack Disease', 'Healing', 12, 'Touch', 'Special', NULL, 'The psychic can reduce the symptoms of disease in a debilitating psionic melding. The psychic touches his patient, linking himself to the sick individual, and draws part of the illness into his own body (this takes 1D4 minutes of concentration). Once the sickness has been drawn into the psychic, it reduces the effects, penalties and normal duration of the disease in the sick individual by half. Likewise, the psychic also exhibits the symptoms and penalties of the disease but also at half the normal severity and his symptoms last only 1D4 hours. This power does not work against magic diseases and curses, as well as lethal and chronic diseases like cancers, tuberculosis, polio, Altheimer''s, Parkinson''s disease, ebola, and similar.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Catatonic Strike', 'Super', 40, 'Touch by stabbing attack!', 'Special', 'Once stabbed, the victim is -1 to save per every two levels of the psychic attacker.', 'Summons a nerve shattering force delivered from a stabbing attack with a blade weapon, requiring the weapon to penetrate flesh, most effective from behind (+2 to strike) or against an incapacitated foe. The intended victim can try to parry or dodge if aware of the attack; the attacker gets two tries before the psychic energy dissipates. The stabbing inflicts usual weapon damage. Regardless of damage, the victim falls into complete catatonic coma unless he saves vs psionic attack. A successful save means the character suffers weapon damage plus 2D6 shock damage and halves melee attacks/bonuses for 1D4 melee rounds. A failed save means the character instantly collapses into a coma, helpless and incapable of any action. There is a cumulative 15% chance of recovery each day, but the character could die from blood loss if not found. The victim can remain comatose for one day per P.E. attribute point; if he doesn''t wake by then, he dies.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Cause Insanity', 'Super', 30, 'Others by touch.', 'One week per level of experience.', 'Standard', 'Anyone who fails to save vs psionic attack contracts one insanity (phobia, obsession, or neurosis specified by the psionic), lasting one week per level of the psychic. Use of this ability does not inform the psychic of any prior insanity the character may possess. The psychic can make the insanity permanent by permanently subtracting 2D6 points from his I.S.P. base.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Commune with Animals', 'Sensitive', 6, '200 feet; line of sight.', 'Two minutes (8 melee rounds) per level of experience.', 'Animals save as non-psionics and need a 15 or better.', 'A combination of empathy and telepathy that allows the psychic to commune with animals (mammals, birds, reptiles, and amphibians - not insects or fish), making the creature(s) accept the psionic as one of their own. Enables sending and receiving emotions and rudimentary thought images. Affected animals will not harm the psionic and will usually (1-80%) obey simple commands like run/flee, defend self/attack, come, go, stay, etc. The character can commune with one animal per level of experience.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Commune with Spirit', 'Sensitive', 8, 'Self', '8 melees', 'None per se; the chance of successfully contacting a spirit or entity is 7% per level of experience, but add +20% if ghosts or entities are known to inhabit the immediate area.', 'The ability by which mediums communicate with entities, astral travelers, astral beings, ghosts, and spirits. The psionic sends a general call into the spirit world; the being usually communicates by temporarily possessing another person, who may or may not be the caller. Various random spirits may respond with varying degrees of helpfulness, hostility, or deceit, per a percentile table of possible outcomes.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Cure Insanity', 'Super', 30, 'Others by touch.', 'Special', 'Standard and automatic; the character saves whether he wants to or not.', 'Most types of insanity can be cured at least temporarily, except schizophrenia, organic retardation, insanity from brain damage, and those inflicted by magic/curses. A successful save vs psionic attack means no cure, but the I.S.P. is expended nonetheless. A failed save means temporary cure of that particular insanity, with a 1-10% chance of resurfacing each week or upon a similar traumatic situation. Each specific insanity must be targeted individually. The psychic can make the cure permanent by permanently spending 2D6 of his I.S.P. base.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Dispel Spirits', 'Sensitive', 10, '50 foot (15.2 m) radius per level of experience.', '30 minutes per level of experience.', 'The spirit receives no saving throw but if a psionic summoned the spirit, then he can roll a standard save to maintain contact and prevent it from leaving.', 'Any lesser spirits, ghosts or minor entities within a 50 foot (15.2 m) radius of the psychic are forced to flee the area immediately. This does no damage to the spirit but sends them fleeing and breaks any communication they may have with another psychic. Tectonic and possessing entities, demons, gods, Will-O-The-Wisps, nymphs, specters, and similar creatures are not affected.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Float', 'Physical', 8, 'Self', '2 hours', 'None', 'This ability controls the distribution of body weight and creates a mild telekinetic field which enables the psionic to float effortlessly on water or one foot in the air per level of experience. On the water, the character can float and rest without exerting any physical energy to do so. Using a psionic float in the air allows the character to sit or lay (or sleep) comfortably above the ground as if on a cushion of air. The only down side is he may get blown away during a strong wind (at least until he cancels the power). Float can also be used to break a fall by slowing the rate of descent until the character is gently hovering above the ground. Roll 1D20 to roll with fall or impact. Using the psionic float, a successful roll means no damage. A failed roll means half damage. Counts as two melee actions.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Induce Nightmare', 'Sensitive', 15, 'Touch or 10 feet (3 m) per level of experience; must have a clear line of vision of the sleeping individual', 'Two melee rounds per level of the psychic', 'Standard', 'The psionic attacks by implanting a terrifying dream that causes the dreaming character to suffer great distress. The sleeper may toss and turn, mumble and moan. While under the psychic thrall of the induced nightmare, it is impossible for the victim to wake up unless another psychic uses telepathy or empathy to jar him awake. After waking, the subject of the attack will be on edge and unable to fall asleep for 1D4 hours (which may lead to exhaustion).', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Insert Memory', 'Sensitive', 25, 'Touch', 'Permanent', 'Standard; although innocuous false memories or ones that deal with something the character wanted to know/remember, may not be resisted at all (G.M.''s or the player''s call)', 'An artificial memory can be implanted into the mind of the subject. This memory is completely convincing and will affect all related actions of the victim. Implants that are seemingly unimportant or not strongly defined (rumors, hearsay, etc.) are the easiest to implant in a character''s mind because the memory doesn''t conflict with real memories or the character''s alignment or ethics. The only chance that the victim has of detecting an artificial memory is when it conflicts with obvious reality, strong beliefs, strong emotions, or alignment. But even if the victim disbelieves the memory or realizes it''s false, it still remains.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Invisible Haze', 'Sensitive', 30, 'Self', 'Six minutes', 'Standard', 'The psychic transmits a powerful hypnotic suggestion that telepathically tells all who look upon him that they cannot see him! Thus, one moment he is there and the next second he''s gone. The character and everything on his person disappears. All who see the psychic get to roll to save vs psionic attack as normal. Those who fail to save cannot see the character for the full duration of the psionic power. Even characters who can see the invisible and see aura cannot "see" the invisible psychic. Those who make a successful save vs psionic attack see the character without difficulty. Attacks against an invisible foe are -6 to strike, parry, and dodge, and -6 on initiative, unless the invisible character picks up or throws a visible object.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Lust for Life', 'Healing', 15, 'Touch', '3 rolls vs coma recovery.', NULL, 'By the laying of hands, the psychic can instill a lust for life into someone who is in a coma and apparently dying. This adds a bonus of 6% per each level of the psychic''s experience to the comatose character''s recovery from coma rolls. Example: a second level Psi-Healer adds 12% to the save vs coma, third level 18%, etc. The percentage bonus is subtracted from the coma percentile the character must roll above to survive, reducing the risk of a fatality.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Meditation', 'Sensitive', 0, 'Self', 'Varies', 'None', 'This psychic sensitive ability is automatically available to all master psionics. It is a simple self-hypnotic trance which allows the psychic to completely relax. During such trances the psychic regains six I.S.P. per hour (the Mind Mage gets 12!).', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Mental Illusion', 'Sensitive', 20, '90 feet', 'Special', 'Standard', 'This power is an incredible psionic hypnotic suggestion that causes the victim to see, hear, feel and interact with an illusionary being. This being can be a horrible, attacking monster, friend, family member, a seductive woman, or anything in between. Only the character affected sees this mental image. The being reacts as the character would expect it to react, which may rely entirely on what he believes it to be or be influenced by the hypnotic suggestion. Powerful psychics often use this power to trick, distract, divide and delay their opponents. The psychic can also use this power to make another person believe he is a completely different person; friend, loved one, acquaintance, stranger or monster.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Sense Dimensional Anomaly', 'Sensitive', 6, '120 foot (36.5 m) radius.', '2 minutes per level of experience.', 'None', 'This power will detect the presence of a dimensional anomaly like a dimensional portal or Rift leading to another dimension, world, or time, as well as any disturbances caused by teleportation, temporal magic, or other powers that disrupt the fabric of reality.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Spontaneous Combustion', 'Physical', 6, 'Touch or 10 feet (3 m) and must be in the line of vision.', 'Instant', 'None', 'This pyrotechnic ability enables the psionic to manipulate combustible material, causing it to ignite. Spontaneous combustion creates only the spark to start a fire, not a roaring wall of flame. Combustible material must be present to burn. This power works best on extremely combustible materials such as paper, dry wood, dry leaves, old dry rags, hot coals, lamp oil, and similar items. It cannot be used to set a person''s hair or clothes on fire.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Suppress Fear', 'Healing', 8, 'Self or others by touch.', 'One minute per level of experience.', 'None', 'This power temporarily suppresses the chemical and psychological components of fear in the subject. As a result, the character is unable to feel the emotion, even if intellectually, he realizes he is in danger or is facing a terrifying situation. This enables the character to take perfectly rational actions rather than respond with the typical "fight or flight" reactions of those who are frightened. While this power is activated, the character automatically succeeds on any check to resist horror factor, even if magically induced. This power can be used on the psychic himself or on others.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Telekinetic Leap', 'Physical', 8, 'Self (leaping range is increased by 3 or 5 feet/0.9 to 1.5 m per level of experience.', 'One melee attack/action (leap)', 'None', 'This telekinetic application boosts the person''s leaping ability, propelling the psychic an additional 3 feet (0.9 m) for high jumps, and 5 feet (1.5 m) for broad jumps (lengthwise), per level of experience. This power can be used in conjunction with a leap kick attack (damage: 6D6+6 plus P.S. bonuses), but the character will take 2D6 points of damage himself from the hard impact. An acrobatics or gymnastics roll, or a roll with punch, fall or impact, may be needed to land safely after one of these leaps.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Telekinetic Punch', 'Physical', 6, 'By touch or one foot (0.3 m) per level of experience.', 'Instant', 'None.', 'This telekinetic power enables the psychic to deliver a powerful force through telekinetic energy that feels like a punch or kick. A telekinetic punch will inflict 4D6 plus P.S. bonus, and a kick will do 5D6 plus P.S. bonus. The I.S.P. is spent whether or not the punch or kick actually hits the target (roll to strike as normal). The power is used in conjunction with a normal, physical attack, so the telekinetic attack can be parried or dodged by the enemy. Every time the power is used, the psychic must make a save of 14 or higher, or he will take 1D6 points of damage himself as a result of wrenched muscles or a dislocated joint from the extra strain on his body.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Teleport Object', 'Physical', 10, 'Touch', 'Immediate', 'None', 'This is the ability to cause physical matter to disappear and reappear at a different location. Such teleportation is limited by the level of the psychic. A psionic character can teleport one pound per level of experience a distance of 50 feet (15.2 m) per level of experience. This is one-way teleportation; once sent away, the psychic cannot call it back. It is also helpful to know where one is teleporting the object. Teleporting small objects to any place in one''s clothes is automatically successful. Teleporting it into somebody else''s pocket, sack, etc., who is within clear line of sight has an 80% likelihood of success (crowd: -20%). Teleporting the object to any open location that the psychic can see clearly, or to a familiar place, is 88%. Teleporting the object to an unfamiliar place has a 60% chance of success. Teleporting the object to a completely unknown place has a 45% chance of success. A failed success roll means the teleporter has no idea where the object is - and it could be within a radius anywhere within the character''s range.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO psionic_powers (name, category, isp, "range", duration, saving_throw, description, min_tier, source, source_book)
VALUES ('Transfer I.S.P.', 'Healing', 4, 'Touch', 'Instant transferal.', 'None', 'The psychic can transfer some of his own I.S.P. to another psychic. The operation costs four I.S.P. plus the amount transferred. So, for example, transferring 10 I.S.P. to another psychic would cost 14 I.S.P. total. A mind block will prevent this energy transfer.', NULL, 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET category = excluded.category,
       isp = excluded.isp,
       range = excluded.range,
       duration = excluded.duration,
       saving_throw = excluded.saving_throw,
       description = excluded.description,
       min_tier = excluded.min_tier,
       source = excluded.source,
       source_book = excluded.source_book;

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS new_powers FROM psionic_powers WHERE name IN ('Advanced Trance State', 'Attack Disease', 'Catatonic Strike', 'Cause Insanity', 'Commune with Animals', 'Commune with Spirit', 'Cure Insanity', 'Dispel Spirits', 'Float', 'Induce Nightmare', 'Insert Memory', 'Invisible Haze', 'Lust for Life', 'Meditation', 'Mental Illusion', 'Sense Dimensional Anomaly', 'Spontaneous Combustion', 'Suppress Fear', 'Telekinetic Leap', 'Telekinetic Punch', 'Teleport Object', 'Transfer I.S.P.');
SELECT category, count(*) AS n FROM psionic_powers GROUP BY category ORDER BY category;
