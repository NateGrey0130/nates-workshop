-- The 4 psionic powers of Revised Heroes Unlimited the catalog did not hold.
-- Printed 128-135. Thirty-three were extracted; twenty-nine are already here.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-core-psionics.sql
--
-- THE ROSTER IS THE INDEX ON PRINTED 128 - nineteen Major Psionics and fourteen
-- Secondary Psi-Powers - and it is clean, both lists printing in a single
-- column. The spell index on printed 92 was not, which is why that pass needed
-- two independent readings and this one does not.
--
-- THREE OF THE THIRTY-THREE ARE THE SAME POWER UNDER ANOTHER NAME and get no
-- new row. Each was resolved by reading BOTH descriptions, not by name
-- similarity:
--
--   the book prints        the catalog holds                   why
--   Bio-Manipulation       Bio-Manipulation (the evil eye)      same seven effects,
--                                                               same 4D4-minute
--                                                               extension for 6 I.S.P.
--   Empathic Transfer      Empathic Transmission                both project a false
--                                                               emotion into one
--                                                               creature; the same
--                                                               Despair, Confusion,
--                                                               Fear and Hate list
--   Object Read            Object Read (Psychometry)            a parenthesised name
--
-- AND TWO NEAR-MISSES THAT ARE NOT THE SAME POWER, which is the half worth
-- writing down:
--
--   Ectoplasmic Arm is NOT `Ectoplasm`. The catalog's row is the vapour and
--   solid substance; this is a hand and arm with S.D.C. 40, one hit point, its
--   own attacks and a P.P. of 12.
--
--   Resist Cold is NOT `Impervious to Cold`. The catalog's row is absolute -
--   "absolutely no ill effects" - while this one scales with the temperature,
--   two I.S.P. per twelve degrees below freezing, and still takes HALF DAMAGE
--   from extreme or unnatural cold. A resist and an impervious are different
--   powers in this system, and the names say so.
--
-- Hypnosis/Mesmerism is a MAJOR power here and the catalog's `Hypnotic
-- Suggestion` is this book's own SECONDARY one - both appear in its lists, so
-- they cannot be the same row.
--
-- THE CATEGORY ON EACH NEW ROW IS AN ASSIGNMENT. Heroes Unlimited files a power
-- as Major or Secondary and the catalog files one as Healing, Physical,
-- Sensitive or Super; the taxonomies do not map (survey G8). Each is filed
-- beside the catalog row it most resembles, and the reasoning is in the
-- generator. Nothing is gated on it: the Psionics power category names its
-- powers in a LIST, and a named list replaces the category gate outright.
--
-- I.S.P. costs where the book prints a variable one go in `isp_note` with the
-- minimum in `isp`, the same shape the catalog already uses for a variable cost.

INSERT INTO psionic_powers
  (name, category, isp, isp_note, source, source_book, system,
   range, duration, saving_throw, description, min_tier, variant_note)
VALUES ('Ectoplasmic Arm', 'Physical', 8, NULL, 'import', 'Revised Heroes Unlimited p.129', 'heroes-unlimited',
        '30ft (9.1m)', '4 minutes per level of psionic', 'As a dodge or parry', 'This mystifying ability enables the psionic to actually create a vaporous, luminous substance in the shape of a hand and arm. The arm has the option of one attack per melee, or two actions in addition to its creator''s attacks, and is +1 to strike and +2 to parry and dodge. It has a S.D.C. of 40 and one hit point. The psionic can restore 30 S.D.C. by pumping in another 6 I.S.P. If the arm is destroyed the psionic takes damage, losing the one hit point. The ectoplasmic arm is quite agile (P.P. 12), but MUST be controlled and directed by its psionic creator. If the psionic is rendered unconscious or slain it will immediately disappear. Weight limitation of the arm is 40lbs per each of the psionic''s experience levels. Thus, a first level psionic''s arm can lift 40lbs, at second level 80lbs, at third level 120lbs, and so on. Note: The psionic needs one minute/four melees of concentration to create the arm and can instantly dispel it at any time. The maximum distance the arm can be from its creator is 30ft. Savings Throw: There is no savings throw per se, but characters can dodge or parry the arm in a combat situation.', NULL, NULL);

INSERT INTO psionic_powers
  (name, category, isp, isp_note, source, source_book, system,
   range, duration, saving_throw, description, min_tier, variant_note)
VALUES ('Hypnosis/Mesmerism', 'Super', 2, '2 I.S.P. per suggestion or command.', 'import', 'Revised Heroes Unlimited p.130', 'heroes-unlimited',
        '60ft (18.3m)', '8 melees/2 minutes per level of psionic', 'Standard', 'Hypnosis or mesmerism enables the psionic to implant commands and suggestions in another person''s mind. To avoid confusion and mistakes, it is best to keep the commands simple and clear. Example: "You are very tired . . . go to sleep. . . when you awaken you will not remember any of this." The example actually has three suggestions and the intended victim has a chance to save against each one. Other commands might take the form of a simple phrase or a single word like "don''t shoot," or "lay down your weapons," or "you will fear me," or "he is your enemy," or "sleep" or "stop" and so on. The psionic can make two commands or suggestions each melee, and can repeat a command if the opponent saves against it the first or second time. As the psionic develops his hypnotic powers he can influence more than one mind at a time; one per each level of experience. This means a first level psionic can affect only one person, at second level two people, at third level, three people and so on. Savings Throw: Standard, but the opponent gets to roll to save against each suggestion or command. An unsuccessful save means the opponent is under the complete control of the psionic.', NULL, NULL);

INSERT INTO psionic_powers
  (name, category, isp, isp_note, source, source_book, system,
   range, duration, saving_throw, description, min_tier, variant_note)
VALUES ('Mind Control', 'Super', 6, NULL, 'import', 'Revised Heroes Unlimited p.131', 'heroes-unlimited',
        '40ft (12.2m)', '5 minutes per level of the psionic', 'Standard', 'This psi-power affects any intelligent creature, but can only be used on one person at a time. It is not an area affect power. The affected person will fall under the complete control of the psionic. Victims of mind control will obey the psionic without question and answer all questions truthfully. They can even be made to combat friends and allies, although the controlled person''s reactions and reflexes are somewhat impaired. - 2 to strike, parry and dodge. '' Note: If an evil character should try to make another person under his control commit suicide, or do something which is obviously certain death, that person will hesitate and is given a chance to break free of his control. This provides an extra savings throw to break the mind control. The person is +4 to save. If the savings throw is unsuccessful the person will do exactly as told. As the psionic grows in experience he can control more than one person simultaneously. He can control two people at third level, another at fifth level, and one at every other level thereafter. A psionic can attempt to control one person, or several simultaneously, once per melee.', NULL, NULL);

INSERT INTO psionic_powers
  (name, category, isp, isp_note, source, source_book, system,
   range, duration, saving_throw, description, min_tier, variant_note)
VALUES ('Resist Cold', 'Physical', 2, 'Two I.S.P. for every 12 degrees below freezing.', 'import', 'Revised Heroes Unlimited p.133', 'heroes-unlimited',
        'Self', '4 hours', 'None', 'This mental discipline is one of many mind over matter abilities. It enables the psionic to suffer no ill effects or discomfort from prolonged exposure to cold conditions. Two I.S.P. are required for every 12 degrees below freezing. The psionic will suffer half damage from extreme or unnatural cold. Four full minutes of concentration are required to prepare for the resistance.', NULL, NULL);

-- ASSERTIONS.

SELECT 'four powers cite the Revised core' AS assertion, count(*) AS got, 4 AS want
  FROM psionic_powers WHERE source_book LIKE 'Revised Heroes Unlimited%';

SELECT 'every one is tagged heroes-unlimited' AS assertion, count(*) AS got, 4 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND system = 'heroes-unlimited';

SELECT 'every one carries a description, a range and a duration' AS assertion,
       count(*) AS got, 4 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND length(description) > 200 AND range IS NOT NULL AND duration IS NOT NULL;

SELECT 'every one carries a saving throw' AS assertion, count(*) AS got, 4 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND saving_throw IS NOT NULL;

-- The two whose cost varies say so; the two whose cost is flat do not.
SELECT 'two of the four carry an isp_note' AS assertion, count(*) AS got, 2 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND isp_note IS NOT NULL;

-- The three same-power cases were NOT duplicated.
SELECT 'no duplicate was created for a power the catalog already held'
         AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE name IN ('Bio-Manipulation', 'Empathic Transfer', 'Object Read');

-- And the rows they resolve to are untouched.
SELECT 'the three rows they resolve to are still there' AS assertion,
       count(*) AS got, 3 AS want
  FROM psionic_powers
 WHERE name IN ('Bio-Manipulation (the evil eye)', 'Empathic Transmission',
                'Object Read (Psychometry)');

-- The two near-misses exist ALONGSIDE the rows they are not.
SELECT 'both near-misses exist beside the row they are not' AS assertion,
       count(*) AS got, 4 AS want
  FROM psionic_powers
 WHERE name IN ('Ectoplasmic Arm', 'Ectoplasm', 'Resist Cold', 'Impervious to Cold');

SELECT 'no row outside this book was written' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND source <> 'import';

INSERT INTO data_script_runs (filename) VALUES ('add-hu-core-psionics.sql');
