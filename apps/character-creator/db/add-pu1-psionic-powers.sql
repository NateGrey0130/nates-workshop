-- The eight new psionic powers of Powers Unlimited One, printed 88-95.
-- The FIRST data of the Heroes Unlimited batch, and the first rows anywhere in
-- this catalog to carry system = 'heroes-unlimited'.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-pu1-psionic-powers.sql
--
-- WHY THESE EIGHT AND NOT THE BOOK'S TWENTY-ONE. The book's psionics section
-- holds 21 powers; catalog-diff --remote matched 13 of them against rows this
-- catalog already had, leaving 8. Every near-match was hand-checked and none is
-- a false gap - production holds Bio-Manipulation (the evil eye),
-- Bio-Regeneration and Bio-Regeneration (Super), and NO Precognition, NO
-- Sensory Link and NO Mimic Skills at all. A 116-row psionics catalog with no
-- Precognition is a real hole independent of this book.
--
-- WHY NINE ROWS FOR EIGHT ENTRIES. The book prints Mimic Skills once, tagged
-- "Sensitive & Super Psionics", and gives it a DIFFERENT duration in each
-- category - ten minutes per level as a Super power, two minutes per level as a
-- Sensitive one. `category` is single-valued and the pickers filter on it, so
-- one row would deny the power to half the psychics entitled to it and would
-- have to discard one of the two durations. This catalog already answers that
-- shape: Bio-Regeneration / Bio-Regeneration (Super) and Telekinesis (Super)
-- are all sibling rows. The `(Super)` suffix is a CATALOG convention and not a
-- claim that the book prints that name.
--
-- TWO INDEPENDENT READINGS OF THE COST, for four of the eight. Printed 88
-- carries a summary list of the Super Psionics with their I.S.P., and each
-- power's own stat block repeats it: Bio-Alteration 10 = 10, Mimic Skills
-- 12 = 12, Steal Memory 6 = 6, Steal Skills 15 = 15. The other four - Calm
-- Rage, Precognition, Sensory Link, Wound Transfer - are Healing or Sensitive
-- and that list does not cover them, so they are transcribed from one reading.
--
-- PRECOGNITION'S BLOCK IS SPLIT ACROSS A PAGE BREAK and has NO Saving Throw
-- line. Its Range/Duration/I.S.P. and its Note end printed 92; the description
-- begins printed 93. The missing save is the book's own shape, not a lost line
-- - checked on the render of both pages.
--
-- Page citations are printed folios. The cache is at page_offset 2, re-confirmed
-- here by two inline folios: cache p091 carries 89 and cache p093 carries 91.
--
-- system = 'heroes-unlimited' rather than NULL: these are powers of a specific
-- game, and NULL means unrestricted in this catalog. The value became valid in
-- BOOK-INGEST-AUDIT F73 (PR #996); psionic_powers.system is bare TEXT with no
-- CHECK, so nothing else had to change.
--
-- Curly apostrophes and em-dashes from the OCR are folded to ASCII, per
-- d1-apply's pure-ASCII pre-flight.

INSERT INTO psionic_powers
  (name, category, isp, isp_note, variant_note, source, source_book, system, range, duration, saving_throw, description, min_tier)
VALUES
  ('Bio-Alteration', 'Super', 10, NULL, NULL, 'import', 'Powers Unlimited One p.88', 'heroes-unlimited',
   '160 feet (48.8 m); line of sight.',
   '4-16 minutes (roll 4D4).',
   'Standard',
   'A similar ability to Bio-Manipulation, but with different effects and results. The psychic induces a physical influence on his victim''s nervous system. Each effect can be used against only one person per psychic attack and they can be used in any combination. Intended victims must be within line of vision or their exact location known to the psychic. Each attack costs 10 I.S.P. to inflict, and the duration can be extended 4-16 (4D4) minutes per additional 6 I.S.P. spent. Bodily Fluids: the victim is overcome with the urgent sensation that he must relieve himself; -20% Spd, -1 on all combat bonuses and -15% on skill performance until he can, and a failed save vs Horror Factor (or a punch to the kidneys, 01-33%) causes an accident. Chemical Alteration: the victim is -4 to save vs possession, mind control, illusion, Horror Factor and Charm-type attacks. Crossed Wires: smell and taste are inverted, so sweet tastes sour, mild becomes hot and spicy, and burnt food can be made to seem pleasant. Headache: all skills at -20%, all combat bonuses halved, -2 to save vs Horror Factor, psionics, mind control and illusions. Synaptic Misfire: the victim makes mental slips - misread numbers (off by 1D4x10%), wrong words, forgotten passwords - and all skill rolls are at -10%. Tremors: the victim loses one melee attack, speed is reduced by 10%, skills needing a steady hand are at -30%, and he loses all bonuses for shooting firearms and is -1 to strike. Vertigo/Dizziness: the inner ear is scrambled and balance is lost; the victim may roll a 15 or higher to keep his balance for a melee round.',
   NULL),

  ('Calm Rage', 'Healing', 10, NULL, NULL, 'import', 'Powers Unlimited One p.89', 'heroes-unlimited',
   'Touch.',
   'Instant effects.',
   'Subject is -3 to save.',
   'The psychic can instantly calm a character lost to berserker rage or battle rage, bringing the individual down to see and think clearly in a heartbeat. Because the power works only by touch, the psychic is likely to be struck once, badly, before calm is restored. To avoid it he may touch the subject, unleash the calming energies and try to dodge; the dodge costs one melee action and is made without bonuses except for the P.P. attribute. If the dodge fails, roll for berserker rage damage. The ability can also be used to calm the mentally deranged and anyone overcome with anger or rage.',
   NULL),

  ('Mimic Skills', 'Sensitive', 12, '12 per each skill.', NULL, 'import', 'Powers Unlimited One p.91', 'heroes-unlimited',
   'Touch or line of vision at four feet (1.2 m) per level of experience.',
   'Two minutes per level of experience as a Sensitive ability.',
   'Standard',
   'Limitations: non-combat skills only. The psychic can temporarily absorb and copy another character''s skills and level of skill proficiency, as many as one skill per level of experience, each costing 12 I.S.P. When the duration elapses the copier forgets how to perform the skill entirely, as though he had never known it; the victim''s own knowledge is unhampered. The book prints this power once, tagged for both the Sensitive and Super categories, with a longer duration as a Super power - see Mimic Skills (Super).',
   NULL),

  ('Mimic Skills (Super)', 'Super', 12, '12 per each skill.', NULL, 'import', 'Powers Unlimited One p.91', 'heroes-unlimited',
   'Touch or line of vision at four feet (1.2 m) per level of experience.',
   'Ten minutes per level of experience as a Super Psionic power.',
   'Standard',
   'Limitations: non-combat skills only. The psychic can temporarily absorb and copy another character''s skills and level of skill proficiency, as many as one skill per level of experience, each costing 12 I.S.P. When the duration elapses the copier forgets how to perform the skill entirely, as though he had never known it; the victim''s own knowledge is unhampered. The book prints this power once, tagged for both the Sensitive and Super categories; this row is the Super reading, which lasts ten minutes per level instead of two. The name suffix is this catalog''s convention for a power available at two tiers, as with Bio-Regeneration (Super) - the book prints the name without it.',
   NULL),

  ('Precognition', 'Sensitive', 8, NULL, NULL, 'import', 'Powers Unlimited One p.92-93', 'heroes-unlimited',
   'Self.',
   '2 melee rounds.',
   NULL,
   'Note: rare and unusual even among psychics, most common among supernatural beings. The ability to pick up psychic emanations and glimpse a few moments of the future. The insight may cover a few moments or a couple of hours; time is a tenuous element caught up in continual change, so the potential future can be altered and avoided. Using Precognition on an unopened door may reveal what lies beyond, and the psychic may see himself engaged in battle or at work on something. G.M. note: reveal the nature of the danger and the identity of the opponent rather than the actual outcome - the fewer hard facts the better, since the future is open to speculation. The book prints no Saving Throw line for this power.',
   NULL),

  ('Sensory Link', 'Sensitive', 10, NULL, NULL, 'import', 'Powers Unlimited One p.93', 'heroes-unlimited',
   'Touch to establish the link, one mile (1.6 km) per level of experience to maintain it.',
   '10 minutes per level of experience.',
   'Not applicable, but -2 for an animal.',
   'A sensory link can only be established with a willing person or animal, and with a beast only if it fails a saving throw vs psionics or is a pet. Once established, the psychic can see through the eyes of the person or animal he is linked to, and hear, smell and feel whatever it experiences. This is excellent for spying and little else: the psychic cannot speak, use his psionic powers, or communicate with the individual he is linked to. While linked he falls into a trance-like state and can take no action of his own unless he breaks the link, which instantly returns his awareness to his own body. Any threat to his body is known to him and he can return and respond in a fraction of a second, and the link can be broken whenever he desires.',
   NULL),

  ('Steal Memory', 'Super', 6, '6 per each thought.', NULL, 'import', 'Powers Unlimited One p.94', 'heroes-unlimited',
   'Four feet (1.2 m) per level of experience.',
   'Instant.',
   '-2 to save.',
   'A limited but powerful form of mental telepathy. The psychic focuses on a very specific thought - a secret code word or number, the combination to a lock, a name, an address - of up to four words or a 24 number sequence, and plucks it from a person''s mind. He can also concentrate on what a person is about to say and know or speak the last one to four words of the statement a second before the speaker does, which is an excellent means of pretending to knowledge he does not have. The only absolute defense against Steal Memory is a Mind Block; otherwise the intended victim rolls to save vs psionics as usual.',
   NULL),

  ('Steal Skills', 'Super', 15, '15 per each skill.', NULL, 'import', 'Powers Unlimited One p.94', 'heroes-unlimited',
   'Touch or line of vision at four feet (1.2 m) per level of experience.',
   'Five minutes per level of experience.',
   'Standard',
   'Limitations: non-combat skills only. The psychic can temporarily syphon another character''s skills and level of skill proficiency, as many as one skill per level of experience, each costing 15 I.S.P. Unlike Mimic Skills, stealing the knowledge means the psychic has it and the character it was taken from does NOT - it is completely gone, which can be disastrous at a pivotal moment such as while driving a vehicle, picking a lock or operating a device. When the duration expires the psychic forgets the stolen skills entirely and the person robbed of them suddenly has them back.',
   NULL),

  ('Wound Transfer', 'Healing', 12, NULL, NULL, 'import', 'Powers Unlimited One p.95', 'heroes-unlimited',
   'Touch.',
   'One melee for transfer and relief.',
   'Standard',
   'Note: the psychic can take away pain and injury in increments of 10% to a maximum of 50%. The psychic reduces the suffering of another person by taking that character''s pain onto himself through a debilitating psionic melding. He touches his patient, linking himself to the wounded or sick individual and drawing part of the wounds into his own body; this takes one melee round of concentration.',
   NULL);

-- ASSERTIONS. Each batch asserts its own rows and nothing else, so a count here
-- is not an assertion about execution order wearing a disguise.

SELECT 'nine rows cite Powers Unlimited One' AS assertion,
       count(*) AS got, 9 AS want
  FROM psionic_powers WHERE source_book LIKE 'Powers Unlimited One%';

SELECT 'every one of them is tagged heroes-unlimited' AS assertion,
       count(*) AS got, 9 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Powers Unlimited One%' AND system = 'heroes-unlimited';

SELECT 'every one of them carries a category the pickers know' AS assertion,
       count(*) AS got, 9 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Powers Unlimited One%'
   AND category IN ('Healing', 'Physical', 'Sensitive', 'Super');

SELECT 'no row outside this book was written' AS assertion,
       count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE source_book LIKE 'Powers Unlimited One%' AND source <> 'import';

SELECT 'the two Mimic Skills rows differ in category and duration' AS assertion,
       count(DISTINCT category || '|' || duration) AS got, 2 AS want
  FROM psionic_powers WHERE name LIKE 'Mimic Skills%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-pu1-psionic-powers.sql');
