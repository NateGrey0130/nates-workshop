-- Repair the stat block on the Revised core's super abilities.
--
-- Two defects shipped in PR #1027, both found by QUERYING PRODUCTION rather
-- than by re-reading the generator's own output - every assertion in that PR
-- passed, because not one of them looked at these columns.
--
-- 1. THE SAVING THROW WAS NEVER STORED, on any of the 364 rows. The parser
--    writes the key `saving_throw`; the generator read `f.get("savings_throw")`.
--    The names differ by one letter, `.get` returns None for a missing key, and
--    the column accepts NULL - so seven values went in as NULL and nothing
--    anywhere complained. `SELECT max(length(saving_throw))` over the whole
--    table returned NULL, which is what a column nobody ever wrote looks like.
--
-- 2. A FIELD VALUE SWALLOWED THE FOLLOWING PROSE wherever the book prints no
--    blank line after the stat block. The old rule continued a value until a
--    blank line or the next label, so Sonic Power's `range` held 621 characters
--    - its entire description - and the description was missing that text.
--
-- THE CORRECTED RULE: a value continues only while the next line begins with a
-- lowercase letter, a digit or punctuation. A line starting a new sentence ends
-- it. That still keeps the multi-line Restrictions the earlier fix was for
-- ("...ice, oil or other" / "slippery substances will...") and stops at prose.
--
-- Two values remain over 90 characters and both were checked against the book:
-- Plant Control's range really is a two-clause 133 characters, and
-- Transferal/Possession's saving throw really does spell out two different
-- rolls. Length was never the fault; swallowing was.
--
-- This file sorts AFTER `add-hu-core-super-abilities.sql`, which is what makes
-- it work on a clean rebuild - a `fix-` that sorts first corrects nothing.
--
-- One-off data script. NOT a migration.

-- Energy Expulsion: Electrical Field: range
UPDATE super_abilities SET range = '10ft area plus an additional 2ft per each level of experience.'
 WHERE name = 'Energy Expulsion: Electrical Field';

-- Heightened Sense of Smell: range, description
UPDATE super_abilities SET range = '90ft',
       description = 'An exceptional sense of smell that can identify any smell within 90ft (27.4m) of the character. Abilities: Recognize/identify specific odors: 70% +4% per level of expericnee. @ Recognize a person by scent alone: 50% +5% per level of experience. @ Recognize poisons and toxins: 50% + 5% per level of experience. Note: Some poison gases are odorless/tasteless/colorless. Track by smell: 40% + 5% per level of experience. Reduce by 10% in the city. Roll for every 200 yards.'
 WHERE name = 'Heightened Sense of Smell';

-- Heightened Sense of Taste: range, description
UPDATE super_abilities SET range = 'Touch/Taste',
       description = 'Having a heightened sense of taste means being able to exactly identify the components in anything tasted. The presence of drugs or chemicals in food will be immediately apparent, although identifying the particular drug or chemical depends on the character''s skill in pharmaceutical or chemistry. Characters with heightened sense of taste will tend to be very particular about what they eat or drink. With practice, they can exactly identily the components and source of any food or drink. For example, if a character studies wine then he/she will eventually be able to identify the type, year, bottling company, and vineyard of any wine from a single taste. @ Recognize common items, such as sugar, salt, pepper, spices, gasoline, and similar, at a proficiency of 70% + 4% per level of experience. @ Recognize exotic tastes such as chemicals, toxins and poisons al a proficiency of 30% + 5% per level of experience. Practicing to recognize an unusual taste for two months will put that taste into the common item category.'
 WHERE name = 'Heightened Sense of Taste';

-- Mental Stun: saving_throw
UPDATE super_abilities SET saving_throw = '14 or higher is needed to save. M.E. bonuses'
 WHERE name = 'Mental Stun';

-- Alter Physical Structure: Fire: damage
UPDATE super_abilities SET damage = '1D6 or 2D6, plus 1D6 per each level of experience.'
 WHERE name = 'Alter Physical Structure: Fire';

-- Control Elemental Force: Air: saving_throw
UPDATE super_abilities SET saving_throw = 'None'
 WHERE name = 'Control Elemental Force: Air';

-- Control Elemental Force: Earth: saving_throw
UPDATE super_abilities SET saving_throw = 'Intended targets can attempt a dodge, but are - 10 because of the surprise of the attack.'
 WHERE name = 'Control Elemental Force: Earth';

-- Control Elemental Force: Water: saving_throw
UPDATE super_abilities SET saving_throw = 'None'
 WHERE name = 'Control Elemental Force: Water';

-- Control Others: saving_throw
UPDATE super_abilities SET saving_throw = 'Same as psionics.'
 WHERE name = 'Control Others';

-- Darkness Control: range, description
UPDATE super_abilities SET range = '140ft (42.7m)',
       description = 'A power that allows the character to create and manipulate darkness. 1. Create Darkness Area of Affect: Up to a 40ft area (12.2m) + 10ft (3m) per each additional level of experience. The character can create an area of total darkness up to 140ft away. The darkness is so black that normal vision, nightvision and light amplification optic systems are ineffective. Those trapped in the darkness are blind and - 8 to strike, 182 parry and dodge. The firing of weapons and energy blasts is equal to shooting wild and likely to hit an innocent bystander or comrade. Note: Infrared optics, heat sensors and exceptional hearing can be effective in this darkness. The creator of the darkness can expand, contract and move the darkness (speed 6) at will. Creating darkness counts as one attack/action per melee. Other actions during the same melee are possible. . 2. Shadow Meld The ability to become invisible in shadows or darkness. The only requirement is that the shadow or area of darkness must be man-sized. Exposure to light will dispel the darkness/ shadow and reveal the character. Nightvision Range: - 600ft (183m) in normal darkness; 30ft 0. lm) in his own, unnatural, darkness. :'
 WHERE name = 'Darkness Control';

-- Gravity Manipulation: range, duration, description
UPDATE super_abilities SET range = 'Self or item/person up to 140ft (42.7m) away.',
       duration = 'Indefinite',
       description = 'The control and manipulation of gravity. 1. Reduce Gravity Area Affected: Self, others, or 20ft radius. The super being can reduce gravity to a fraction, with the following results: The affected person, whether it is oneself or others, can: Carry up to 100 times his normal weight capacity. Leap two feet for each P.S. attribute point. Example: P.S. of 10x 2=20ft. That''s up or lengthwise. Speed is tripled. +3 to dodge. : Throw objects (even huge, heavy objects) great distances. If the object can be lifted overhead it can be thrown a distance of 400ft. Reduce the distance by SOft (16.2m) for every 1000lbs. Remember, this effect can be placed on oneself, or others within the 120ft range, or on an area (20ft radius) up to 120ft away. Duration: The effects will last as long as the gravity controller maintains his concentration. Fortunately, only minimal concentration is required, enabling him to engage in combat or other actions. However, he can not use any other gravity power. 2. Increase Gravity Range: 140ft (42.7m) away. Area Affected: Self, or other object or 20ft radius. Duration: Indefinite This ability is the opposite of the reduce gravity effect, enabling the super being to create bone crushing gravitational conditions. @ Increase weight up to 50 times the objects or person''s normal weight. Actually, the weight is not altered, but it''s the gravitational pull that makes it seem like it weighs more. Speed is reduced by 5 points per every 200lbs of weight. @ The gravity effect can be concentrated on one individual target (object or person), completely immobilizing him/it. The pull is such that he can not move or be budged. Duration: Same as reduce gravity. 3. Zero Gravity Range: 20ft per level of experience. Area Affected: 6ft radius (1.8m) Duration: 4 minutes The character can create an area with no gravity at all. Anything within the radius, or anything specifically affected, is completely weightless and will float about 10ft above the ground. People caught in zero gravity are - 2 to strike, parry and dodge. Weight Limit: The maximum amount of weight that can be made weightless is 10,000lbs (that''s 5 tons), plus 1000ibs additional per each level of experience. Zero gravity can be made to affect one person, object, or an area. As with the previous two gravity abilities, the effect can be maintained as long as the super being is concentrating to do so. 4. Antigravity Flight Speed: 20mph (32kmph) maximum. Height: 100ft (300m) maximum The character can hover or propel himself through the air.'
 WHERE name = 'Gravity Manipulation';

-- Mimic: saving_throw
UPDATE super_abilities SET saving_throw = 'None'
 WHERE name = 'Mimic';

-- Plant Control: range
UPDATE super_abilities SET range = '40ft (12.2m) + 10ft (3m) per additional level of experience, at distances up to 100ft (30.5m) plus 10ft per level of experience away.'
 WHERE name = 'Plant Control';

-- Sonic Power: range, description
UPDATE super_abilities SET range = '1000ft (305m) + 100ft per level of experience.',
       description = 'The ability to manipulate and control aspects of sound. 1. Hear Wider Spectrum of Sound Loudness or intensity of loudness is measured in decibels. This super being can hear even a one decibel sound at a great distance (1000ft). This enables him to: Estimate the distance of the sound - 50%+10% per level; Estimate speed of approach/departure - 40% + 10% per level; Recognize the type of sound - 50% + 10% per level; Pinpoint the exact location of sound - 22% + 8% per level. Minuses to strike, parry and dodge in darkness or while blinded or attacking the invisible, are all reduced by half. Example: - 8 to strike, parry and dodge while blind is reduced to - 4. The Decibel Scale A 20 decibel sound is 10 times louder than a 10 decibel sound: 30 decibels is 100 times louder; 40 decibels is 1000 times louder, etc. One decibel: The smallest difference between sounds detectable by the human ear. 10 decibels: A light whisper. 20 decibels: A quiet conversation. 30 decibels: A normal conversation. 40 decibels: Light traffic. 50 decibels: Loud conversation. 60 decibels: Shouting 70 decibels: Heavy traffic. 80 decibels: Loud noise, subways, rock concerts. 90 decibels: Very loud; thunder. 100 decibels: Jet plane take-off; temporarily deafening. 140 decibels: Extremely loud, painful, deafening. Sound waves travel better and faster through solids and water because of the denser molecules. Thus, the character can hear clearly through walls by leaning his ear against the wall or floor. Note: The range of all hearing abilities are reduced by half in the city during the day. Emit Highpitched Whine Range: 180ft Area Affected: 30ft radius, with hero as focal point. This ability enables the character to emit a highpitched frequency or whine which will hurt, deafen and distract all who fall prey to it. Victims are - 6 on initiative, and - 6 to strike, parry and dodge. Victims also take 1D6 points of damage each melee round (subtract damage from S.D.C. first). The only defense is to plug the ears. Plugging ears (both must be plugged) with fingers reduces damage and minuses by half, but also prevents any counterattacks except psionic. Plugging ears with cotton, tissue or cloth reduces the damage by half and minuses by one. Ear plugs will prevent any damage and reduce minuses by half. 189 Note: The hero must concentrate to maintain the sound frequency and can not use any other sonic power simultaneously. However, the character can engage in hand to hand combat without penalty. 3. Sonic Boom or Blast Range: 200ft Damage: 1D4x 10 Attacks Per Melee: Equal to the character''s total hand to hand melee attacks. This is a blast or bolt of concentrated sound waves. Add +10 to the damage for any attacks underwater. 4. Other Abilities and Bonuses @ +1 to strike Add 1D4~x 10 S.D.C. @ +1 to parry and dodge. @ +2 on initiative. 5. Sonar Range: 400ft+ 100ft per level of experience. This is the emitting of high-frequency sound waves underwater which bounce off objects, returning and indicating the direction and distance of the reflecting objects. The abilities include: Interpreting shapes: 50% + 8% per level of experience. Estimating Distance: 60% + 8% per level of experience. Estimating Direction: 50% + 8% per level of experience. Estimating Exact Location: 34% + 8% per level of experience.'
 WHERE name = 'Sonic Power';

-- Transferal/Possession: range, duration, saving_throw
UPDATE super_abilities SET range = '30ft (9.1m) + 10ft per each additional level of experience.',
       duration = 'The transferal is instant and the character can maintain the possession indefinitely.',
       saving_throw = 'Same as psionics. Non-psionics must roll 15 or higher, psionic individuals must roll 10 or higher to save against being possessed.'
 WHERE name = 'Transferal/Possession';

-- ASSERTIONS.

SELECT 'the seven saving throws are stored' AS assertion,
       count(*) AS got, 7 AS want
  FROM super_abilities
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND saving_throw IS NOT NULL;

SELECT 'no stat value still holds a swallowed description' AS assertion,
       count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND (length(range) > 140 OR length(duration) > 140 OR length(damage) > 140);

SELECT 'Sonic Power keeps a short range and a full description' AS assertion,
       count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Sonic Power' AND length(range) < 60 AND length(description) > 600;

SELECT 'the row count is unchanged' AS assertion, count(*) AS got, 69 AS want
  FROM super_abilities WHERE source_book LIKE 'Revised Heroes Unlimited%';

SELECT 'and the other two books are untouched' AS assertion, count(*) AS got, 295 AS want
  FROM super_abilities
 WHERE source_book LIKE 'Powers Unlimited%';

INSERT INTO data_script_runs (filename) VALUES ('fix-hu-core-ability-stat-blocks.sql');
