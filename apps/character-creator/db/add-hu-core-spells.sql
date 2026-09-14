-- The 16 spells of Revised Heroes Unlimited the catalog did not hold.
-- Printed 96-103. Seventy spells were extracted; fifty-four are already here.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-core-spells.sql
--
-- SEVEN OF THE SEVENTY ARE THE SAME ROW UNDER A DIFFERENT SPELLING and get no
-- new row - decision D4 in the survey, plus two more found while planning this
-- script:
--
--   the book prints              the catalog holds
--   Invisibility (self)          Invisibility: Simple      (NOT (Superior))
--   Dispel Magic Barrier         Dispel Magic Barriers
--   Breath Without Air           Breathe Without Air
--   Sword to Snakes              Swords to Snakes
--   Expel Devils/Demons          Expel Demons
--   Teleport (self)              Teleport: Lesser
--   Swim as the Fish             Swim as a Fish (lesser)
--
-- FIVE OF THESE SIXTEEN ARE GENERAL INVOCATIONS THE CATALOG HAS ONLY EVER HELD
-- IN TRADITION FORM, which is the substantive half of D4. For Levitate,
-- Mesmerism, Wall of Flame, Spontaneous Combustion and Swirling Lights the only
-- existing rows are `Air: Levitate`, `Fire: Wall of Flame` and so on - Warlock
-- rows, which are separate and cheaper, never the general invocation. So this
-- import closes a gap that is not about Heroes Unlimited at all: a Rifts Ley
-- Line Walker could not reach Wall of Flame either. `Darkness` is a sixth of
-- the same shape, held only as `Fire: Darkness` and `Air: Darkness`.
--
-- `same_spell_as` is deliberately NULL on all sixteen. It links two retellings
-- of ONE spell; a general invocation and its tradition counterpart are
-- different rows with different levels and costs, which is the whole reason the
-- tradition namespace exists.
--
-- LEVEL 0 AND P.P.E. 0 ARE NOT PLACEHOLDERS TO BE FILLED IN LATER - they are
-- what this book states, which is nothing. The Revised core gives a caster a
-- number of spells PER DAY rather than a P.P.E. pool (`P.P.E.` appears on zero
-- of its 240 pages), and its index prints a PICK COST in parentheses rather
-- than a level. `ppe_note` says so on every row instead of leaving a reader to
-- infer that 0 means free. Decision D5.
--
-- BLIND'S HEADING IS IN THE INK AND MISSING FROM THE CACHE - the OCR dropped
-- the line on printed 96. Confirmed by rendering that page. It is not among the
-- sixteen (the catalog already holds Blind), but the recovery is why the
-- extraction reads 70 of 70 rather than 69.
--
-- SEVEN HEADINGS DIFFER FROM THE INDEX on these pages, one of them an OCR typo:
-- Dispel Magic Barriers, Expel Demons and Devils, impenetrable Wall of Force,
-- The Sorcerer's Seal, Swim as a Fish, Spontancous Combustion, and Levitate.
-- The indexed spelling is stored.

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Darkness', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.102', 'heroes-unlimited', '5ft radius per level of the spell caster.', '10 melees per level of spell caster.', NULL, 'None', NULL, NULL, 'This is an unnatural darkness which can not be dispelled by normal flames. Nightvision is cut to half in such enchanted darkness. Those with a prowling ability add 16% to their prow! skill while in the darkness only.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Diminish Others', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.97', 'heroes-unlimited', '100ft (30.5m)', '10 melees per level of spell caster', NULL, 'Standard', NULL, NULL, 'This spell will affect any living creature; it will not affect devils, demons, elementals, golems, or skeletons (vampires and were-creatures are affected). This spell will reduce any one target/person to six inches in height, so long as that person is within the spell caster''s line of vision and within range.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Impenetrable Wall', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.98', 'heroes-unlimited', '100/t (30.5m)', '5 melees per level of the spell caster', NULL, 'None', NULL, NULL, 'This spell creates a shimmering wall of light that no creature, weapon, or object may penetrate. Only a Dispel Magic Barrier spell or a powerful Negate Magic will destroy the wall. The spell caster is able to create a wall of force that measures 20 x 20 feet per level of experience. The wall can be cast up to 100ft away.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Levitate (self or others)', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.98', 'heroes-unlimited', '60ft (18.3m)', '8 melees per level of spell caster', NULL, 'None', NULL, NULL, '''This spell enables the spell caster to raise himself or others into the air. The spell weaver can raise an object or person 30ft per level of his experience. Weight limitation is 350lbs per level of the spell caster. This is a vertical movement only. Horizontal movement is impossible.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Mesmerism', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.98', 'heroes-unlimited', '6ft (1.8m)', '5 melees per level of spell caster', NULL, 'Standard', NULL, NULL, 'Mesmerism enables the spell caster to induce simple hypnotic suggestions upon any intelligent being such as "you like me", "you trust me," or "let us pass." The verbal suggestion should be weaved into a sentence or brief conversation. Remember, the enchanted person responds only to simple suggestions and can not be forced to do-bodily harm to himself or friends. The tactics used are similar to getting information by getting that person drunk. Subtlety is the key.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Mystic Illusion', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.103', 'heroes-unlimited', '90ft', '2 melees (conditional) per level of spell caster.', NULL, 'Standard vs illusion', NULL, NULL, 'This incantation conjures forth an image or illusion of anything the spell caster would like. Anyone not making his savings throw will believe the image to be true and respond accordingly. Although the image can be of anything, and as large as 20 by 20 by 20ft, it has no audio, only visual effects. The illusion is immediately dispelled when touched by metal. Savings Throw: To save against the effects of this spell, players roll to save vs illusion, not magic, needing a roll of 14 or better. See the Invisible Range: Sclf or Others Duration: 10 melees per level of spell caster. Saving Throw: None This spell enables a person to sce any invisible object or being (including elementals, jinn, etc.) clearly and distinctly within his line of vision for up to 6Oft. This spell can be cast upon oneself or another person.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Mystic Shield', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.99', 'heroes-unlimited', 'Self or to protect others up to 100ft (30.5m) away.', 'Until destroyed, dispelled or willed away by the spell caster.', NULL, 'None', NULL, NULL, 'Shield S.D.C.: 120 per level of the spell caster A magic shield or enclosure can be created instantly out of thin air to protect the spell caster and up to six normal size people. The shield is effective against all manner of physical attack, from energy bolts to an explosion. If the mystic shield is being created to block/protect oneself from an incoming attack, the spell caster must roll to see if the shield is erected in time, The roll is exactly like a parry (1D20); highest roll wins, defender wins ties. If erected in time, the shield will take the brunt of the attack. If the roll fails, the spell caster or the target of the attack is struck and takes full damage. If the spell caster is hit, the spell is never completed and the shield never materializes. Once the mystic shield is created the spell caster must continue to concentrate lo maintain the shicld. This means he can not physically attack, move, nor cast any spells through the shield. However, he can still talk and cast one spell per melee on himself or anybody with him behind the shield. The shield can be molded to appear as a semi-transparent, floating disc, wall, dome or bubble. It will remain until destroyed, dispelled via a dispel magic barrier spell, or the spell weaver wills it to go (breaks concentration). If the spell caster is rendered unconscious, the shield will instantly disappear.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Paralysis Bolt', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.99', 'heroes-unlimited', '30ft (9m) per level of experience', 'Instant', NULL, 'Standard', NULL, NULL, 'This mystic energy bolt short circuits the victim''s motor parts of the brain, rendering him totally paralyzed. The victim can not move or speak, but can breathe, hear, and think. Paralysis lasts for 6 melees per level of spell caster. The bolt hits automatically, leaping from the spell caster''s hand or eye in a flash. Only a dodge of 19 or 20 can evade the mystic bolt (parry does not apply) and a mystic shield or force field can block. Does not affect robots or bionics.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Shadow Beast', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.99', 'heroes-unlimited', 'Immediate', 'Special', NULL, 'None', NULL, NULL, 'This inter-dimensional spell summons a creature not of this world to do the bidding of the spell caster. Shadow beasts are large, vicious predators of some other, strange world. They stand 9 to 12ft tall, with sharp claws and wicked fangs. Deadliest of all is their ability to completely merge into the smallest shadow, becoming completely invisible. While hidden in shadows they are undetectable, even by a See the Invisible spell, since they are not truly invisible, but one with the shadow. Abilities in darkness or shadows I.Q. 7, M.E. 7, M.A. 7 P.S. 26, P.P. 24, P.E. 30 Spd. 24, Hit Points: 90 Attacks Per Melee: 3 Damage bonus +11 Dodge/Parry bonus +5 Strike bonus +5 Invisible Prowl 90% Abilities in Light I.Q. 7, M.E. 7, M.A. 7 P.S. 18, P.P. 16, P.E. 15 Spd. 8, Hit Points: 45 Attacks Per Melee: 2 Damage bonus +2 Dodge/Parry bonus + 1 Strike bonus +1 Visible The spell caster can command the shadow beast in a combat situation for six melees per level of experience, or in a non-combat situation, send the beast on a simple mission ("Bring me so and so", or "Slay so and so"). The shadow beast will remain in this dimension until the mission is completed or it is slain. There is a 15% chance that the shadow beast will not return to its own dimension and will no longer obey the spell caster who summoned it. If this happens, it will remain in our world wreaking havoc and killing innocent people for food and pleasure. Likewise, it will kill any who try to send it back. Does 1-8 damage (plus bonus).', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Shadow Walk', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.103', 'heroes-unlimited', 'Self or others', '2 melees per level of spell caster.', NULL, 'None', NULL, NULL, 'This unique spell allows the spell caster to step in shadows, becoming totally invisible even to a See the Invisible spell (a psionic presence sense will detect the presence of someone in the shadow). While in the shadow the spell caster can not be seen or harmed by weapons or most magic (only charms and sleep are effective, but all psionic attacks are still applicable). The person in the shadow can talk and cast spells, but can not use a physical attack unless he steps out from the protective shadows. Sudden or intense light will dispel the shadow, revealing the spell caster who must flee into a new shadow for sanctuary. Feeble light (less than 10 torches or 5 lanterns) will only create more shadows, While in shadows or darkness, the spell caster prowls at 60%. Note: The mage can step into any size shadow, large or small, with the same results. This spell can be cast on others by reciting the spell and touching the intended recipient.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Sorcerer''s Seal', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.100', 'heroes-unlimited', '1Oft', 'Conditional', NULL, 'Special', NULL, NULL, 'The sorcerer''s seal can permanently scal/lock a door, chamber, box, compartment, etc. Once the seal is cast, no amount of brute strength, beating, or assault by weapons will break the seal nor will fire, lightning, cold, energy weapons, or magic affect it. Not even a superhuman being can open such a mystic seal. Only a Dispel Magic Barrier spell has any chance of penetrating/dispelling it. Before the seal can be cast, the object (door, portal, etc.), must be 100 completely sealed in wax. Only after all openings, cracks and crevices are sealed/filled with melted wax can the spell be placed upon it. Once sealed in wax and the spell invoked, nothing can open it, including the mage who cast the spell. Only a Dispel Magic Barrier may open it. Savings Throw: None to place the spell, but the seal is +2 to save against the spell magic: Dispel Magic Barriers.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Sphere of Invisibility', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.100', 'heroes-unlimited', '15ft radius', '15 melees per level of spell caster', NULL, 'None', NULL, NULL, 'The spell caster is able to create a sphere or bubble of invisibility in which everyone within the radius is invisible. The spell caster can alter the radius to his desire up to the maximum of fifteen feet. He can also mentally move the sphere (but can not cast spells while doing so), or place it in a stationary area, or cast it around something up to 30 feet away. For additional information about invisibility see: invisibility (self).', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Spontaneous Combustion', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.103', 'heroes-unlimited', '40ft', 'Instant', NULL, 'None', NULL, NULL, 'This spell causes combustible items (paper, wood, cloth, dry grass, etc.) to smolder and burn. The spell''s initial effect is to instantly create the spark to start combustibles burning. However, it takes 1-6 melees for a fire to really begin to burn. The success ratio for each attempt at spontaneous combustion is 75%. 103', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Swirling Lights', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.103', 'heroes-unlimited', '10ft radius', '4 melees per level of spell caster.', NULL, 'Standard', NULL, NULL, 'This spell conjures forth a dazzling display of swirling, flickering lights which stun/bedazzle all who see them. Victims will gaze helplessly into the dancing light display, oblivious to-everything happening around them. If attacked/struck, the victim will be roused from the enchantment, but will move at one-half speed and have half as many attacks as normal as long as the swirling lights spell is in effect.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Turn Self to Mist', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.103', 'heroes-unlimited', 'Self', '5 melees per level of the spell caster.', NULL, 'None', NULL, NULL, 'Turning into mist is particularly useful for escaping prisons, traps, and all sorts of unpleasant situations. While in this form the spell caster can not speak, cast spells, or carry anything, but he can hear and think. Only the physical body is affected, not any possessions, weapons, or clothes: these simply drop to the floor after the transformation. No weapons can hit or cut a mist and pass harmlessly through. Fire does do half damage, however, and lightning and cold based spells slow the mist''s movement by one-half. Normal movement of the mist as it floats through the air is a maximum speed of 12.', NULL, NULL);

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition)
VALUES ('Wall of Flame', 0, 0, 'The Revised core states no spell level and no P.P.E. cost; capacity is spells per day and a spell may cost two or three of a character''s selections. See D5.', NULL, 'import', 'Revised Heroes Unlimited p.101', 'heroes-unlimited', '90ft', '10 melees per level of spell caster', NULL, 'None', NULL, NULL, 'This spell creates a raging wall of flame that is 10ft high by 15ft long by 5ft wide per each level of the spell caster. Anyone touching or running through the wall takes 4-32 points of damage for each five feet of width. Can be cast up to ninety feet away.', NULL, NULL);

-- ASSERTIONS.

SELECT 'sixteen spells cite the Revised core' AS assertion,
       count(*) AS got, 16 AS want
  FROM spells WHERE source_book LIKE 'Revised Heroes Unlimited%';

SELECT 'every one is tagged heroes-unlimited' AS assertion, count(*) AS got, 16 AS want
  FROM spells
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND system = 'heroes-unlimited';

SELECT 'every one carries a description and a range' AS assertion,
       count(*) AS got, 16 AS want
  FROM spells
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND length(description) > 60 AND range IS NOT NULL;

SELECT 'every one says why level and ppe are zero' AS assertion,
       count(*) AS got, 16 AS want
  FROM spells
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND ppe_note LIKE 'The Revised core states no spell level%';

-- The five general invocations the catalog held only in tradition form, plus
-- Darkness. Each must now exist BOTH ways - bare and namespaced.
SELECT 'the six general invocations now exist alongside their tradition rows'
         AS assertion, count(*) AS got, 6 AS want
  FROM spells
 WHERE name IN ('Levitate (self or others)', 'Mesmerism', 'Wall of Flame',
                'Spontaneous Combustion', 'Swirling Lights', 'Darkness')
   AND source_book LIKE 'Revised Heroes Unlimited%';

SELECT 'and their tradition rows are untouched' AS assertion, count(*) AS got, 7 AS want
  FROM spells
 WHERE name IN ('Air: Levitate', 'Air: Mesmerism', 'Fire: Wall of Flame',
                'Fire: Spontaneous Combustion', 'Fire: Swirling Lights',
                'Fire: Darkness', 'Air: Darkness');

-- None of the seven same-spelling cases was duplicated.
SELECT 'no duplicate was created for a spell the catalog already held'
         AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND name IN ('Invisibility (self)', 'Dispel Magic Barrier',
                'Breath Without Air', 'Sword to Snakes', 'Expel Devils/Demons',
                'Teleport (self)', 'Swim as the Fish');

SELECT 'no row outside this book was written' AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND source <> 'import';

INSERT INTO data_script_runs (filename) VALUES ('add-hu-core-spells.sql');
