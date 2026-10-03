-- The 29 Chi-Gung powers of Rifts World Book 25: China 2 (printed 56-62),
-- the powers of the Chi-Gung Seng Ren, Monk of Internal Energy.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-china-2-chi-gung-powers.sql
--
-- SCAN, page_offset +1 (scripts/books.json). Every figure was read off a 200
-- dpi render by a book-extract-worker. The survey is
-- apps/character-creator/docs/surveys/china-2.md.
--
-- CATEGORY Special, by Nate's decision on 2026-10-01 (survey, Agreed with
-- Nate), rather than a new Chi-Gung category. No class gates its picks on
-- Special by category today, so these reach a class only by name - the Seng
-- Ren's own list.
--
-- I.S.P. is the smallest printed cost of using the power: the start-up cost
-- where it runs per round, the cheaper of a power's forms where it has
-- several. The printed cost is in isp_note whenever it is more than one
-- number. Descriptions paraphrase the book.
--
-- It SORTS before the class scripts that grant these powers by name.

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Attack Damage (S.D.C.)', 'Special', 4, '4 per melee round (per-round)', 'rifts',
  'Touch', 'One melee round', NULL,
  'Adds a Chi boost to hand-to-hand strikes with body parts only, on top of normal damage and P.S. bonus. Does nothing for weapons or thrown objects. Damage/effect: Extra 2D6 S.D.C. on punches and kicks. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.56'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Attack Damage (S.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Attack Damage (M.D.C.)', 'Special', 15, '15 per melee round (per-round)', 'rifts',
  'Touch', 'One melee round', NULL,
  'As the S.D.C. version but strikes do M.D. Also adds to head butt or tail swipe, not bites, weapons or thrown objects. Damage/effect: 2D6 M.D. on punches and kicks; extra on top of the usual damage of a creature already Mega-Damage. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.56'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Attack Damage (M.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Blast', 'Special', 5, '5 (S.D.C. blast) or 15 (M.D. blast)', 'rifts',
  'Up to 100 feet (30.5 m), +10 feet (3 m) per level of experience', 'Instant', NULL,
  'Energy blast from fingers, fist or eyes, leaving a visible trail to the target. Damage/effect: 6D6 S.D.C. or 4D6 M.D.. Scaling: range +10 ft per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Blast');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Energy Channeling', 'Special', 10, '10 per melee round (per-round)', 'rifts',
  'Touch and up to 10 feet (3 m) per level of experience; line of sight is a must', 'Special; as long as he is physically touching the power source and can see the device, until the source is drained; needs sufficient I.S.P.', NULL,
  'The Monk acts as a conduit moving energy from one source (generator, E-Clip) into another device. Links to one visible item only. Scaling: range 10 ft per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Energy Channeling');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Energy Parry', 'Special', 5, '5 per melee round (per-round)', 'rifts',
  'Self', 'One melee round', NULL,
  'A plate-sized energy field around the hands lets him parry M.D. weapons, magic flaming weapons and visible energy blasts, without bonuses (high roll wins). A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Energy Parry');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Energy-Powering Touch', 'Special', 15, '15 per melee round (per-round)', 'rifts',
  'Touch', 'Special; as long as he touches the device and has sufficient I.S.P.', NULL,
  'Powers a drained battery, generator, device or gun by touch: handheld full power, generators 80%, vehicles up to 70%, weapons one blast per two of his attacks. Can recharge E-Clips at three charges per melee round. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Energy-Powering Touch');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Enticement', 'Special', 25, 'Twenty-five I.S.P.', 'rifts',
  '1,000 feet (305 m)', 'One day per level of experience', 'Standard',
  'Sets an item or creature as a lure that draws Entities of Pure Chi seeking a host. The spell is dispelled when an Entity enters; it does not hold the Entity. Scaling: duration 1 day per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Enticement');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Erase Self', 'Special', 15, 'Fifteen to initiate the erasure, plus two I.S.P. per melee round', 'rifts',
  'Self', 'Four melee rounds (one minute) per level of experience', 'Standard',
  'The Monk becomes undetectable to sight, see-the-invisible, Presence Sense, See Aura and mechanical sensors while paying I.S.P. each round. Scaling: duration 4 rounds per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.57-58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Erase Self');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Exorcism', 'Special', 40, '40 to start + 1 per melee round', 'rifts',
  'Touch; laying of hands', 'Must continue to touch the victim until the Possessing Entity flees', NULL,
  'Fills a possessed person with positive Chi that hurts the Entity and drives it out or destroys it, usually in 4-8 rounds. Victim is then immune to possession for 48 hours. Damage/effect: 1D6+10 (S.D.C. or M.D. by creature) per melee round to the Entity. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Exorcism');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Healing (S.D.C.)', 'Special', 10, '10 to start + 5 per melee round', 'rifts',
  'Self or other by touch', 'Special', NULL,
  'Laying-on healing for living non-M.D.C. beings. Disease cure needs up to six rounds (penalties halved, gone in 4D6 hours); broken bones another 2D4 rounds. Monk can do nothing else. Damage/effect: Restores 1D6 Hit Points and 2D6 S.D.C. per melee round. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Healing (S.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Healing (M.D.C.)', 'Special', 20, 'Twenty I.S.P. per Healing Touch', 'rifts',
  'Self or other by touch', 'Instant', NULL,
  'One full round of concentration, then laying of hands. Works only on living Mega-Damage beings. Damage/effect: Restores 2D6 M.D. per Healing Touch. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Healing (M.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Heat', 'Special', 2, 'Varies by form: Internal Heat: 3 to initiate + 1 per additional round; External Heat: 5 per melee round; Boil Liquids: 2 per melee round', 'rifts',
  'Touch/self', 'Varies according to I.S.P. expended', 'Standard',
  'Converts Chi to heat in one of three forms: Internal Heat, External Heat, Boil Liquids. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Heat');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Ice', 'Special', 10, 'Ten I.S.P. +4 I.S.P. for each additional 10 gallons (38 liters)', 'rifts',
  'Touch', 'Instant', 'Standard',
  'Freezes water on surfaces or in containers (up to 10 gallons base). Uses: slippery ice (movement 10%, falls 1 S.D.C.), frost-covered glass (-6 to strike, depth perception 50%, dodge/parry halved), freeze water. Damage/effect: Snowballs frozen do 1D4 S.D.C.. Scaling: 10 gallons base; +4 I.S.P. per extra 10 gallons. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.58'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Ice');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Ignition', 'Special', 4, 'Four I.S.P.', 'rifts',
  'Touch', 'Instant', NULL,
  'A burst of energy to revive people in shock, fainted or in a coma, or switch on devices and machines. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.59'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Ignition');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Lightning', 'Special', 15, 'Shocker 40 to start then 10 per additional melee round; Lightning Bolt 15 each; Living Lightning Rod 30', 'rifts',
  '300 feet (91.5 m)', 'Varies', 'Standard for lightning/electrical',
  'Three uses: Shocker (charged body), Lightning Bolts from fingers, and Living Lightning Rod (draws storm lightning, channels it to recharge or destroy). Damage/effect: Shocker 4D6 S.D.C. (or 1D6 M.D.); Lightning Bolts 5D6 M.D. per blast; Living Lightning Rod 1D6x10+15 M.D. to touched item. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.59'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Lightning');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Lightning Fists', 'Special', 20, '20 per melee round (per-round)', 'rifts',
  'Self via touch', 'One melee round', 'By dodging only',
  'Hands crackle with energy; each punch does extra electrical damage, doubled to electronics and Earth/Wood creatures. Cannot use electronics, modern weapons or pilot modern vehicles while engaged. Damage/effect: 3D6 S.D.C./Hit Points + P.S. bonus, or 2D6 M.D. to Mega-Damage targets; double vs electrical devices and Earth/Wood supernatural. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.59'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Lightning Fists');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Mystic Body (M.D.C.)', 'Special', 10, '10 to start + 3 per melee round', 'rifts',
  'Self', 'Special', NULL,
  'Turns all S.D.C. and Hit Points into M.D.C., with +4 to save vs disease and +2 vs poison. Other powers usable next round; at 8 M.D.C. or less he is seriously injured. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.59'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Mystic Body (M.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Purification', 'Special', 40, 'Forty I.S.P. per melee round', 'rifts',
  'Attack by touch or to protect self or other by touch', 'Varies', NULL,
  'Destructive Chi sent by touch, with four uses: remove entities from objects, purging attack, purify food and drink (two rounds, 80 I.S.P. total, up to 100 gallons/100 lbs), and protection from unclean spirits (+2 vs Demonic Curses, half damage punches to ghosts). Damage/effect: 2D10 M.D. per round to a Possessing Entity in an object; 5D10 M.D. per round (laying of hands or power punch) to evil supernatural beings. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.59'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Purification');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Sense', 'Special', 10, '10 per melee round (per-round)', 'rifts',
  'Self (and a second Range line: 20 feet (6.1 m), line of sight, one person or object at a time)', 'Varies as desired and as long as I.S.P. is spent on the sensing', 'None per se; a psionic Mind Block prevents the sensing',
  'After a full round of concentration the Monk senses weaknesses of a target: +2 to strike and +1D6 damage on it while sensing is maintained. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.60'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Sense');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Sparks', 'Special', 4, 'Four', 'rifts',
  'Touch', 'Instant', NULL,
  'Harmless sparks at the fingertips for light (about 10 ft), lighting fires, candles or flammables. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.60'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Sparks');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Spirit Defense', 'Special', 5, 'Five', 'rifts',
  'Self', 'Two minutes (8 melee rounds) per level of experience', NULL,
  'Immune to supernatural possession, +1 per level to save vs other possession, charm and mind control (control lasts half time on a failed save), +4 vs Demonic Curses. May be used with another Chi-Gung power. Scaling: duration 2 min per level; +1 per level to save vs possession/charm/mind control. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.60'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Spirit Defense');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Shared-Spirit Defense', 'Special', 10, 'Ten', 'rifts',
  'Self and others up to a 100 foot (30.5 m) radius around the Monk sharing his defense', 'One minute (four melee rounds) per level of experience', NULL,
  'Shares the spirit defense: others get +5 vs possession, +3 vs mind control, +1 vs Demonic Curse while within 100 ft. The Monk loses immunity (+11 vs possession, minus 1 per person shared with) and halves his other saves. Usable with another power. Scaling: duration 1 min per level; shares with one person per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.60'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Shared-Spirit Defense');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Tough Skin (S.D.C.)', 'Special', 10, '10 self / 15 other', 'rifts',
  'Touch', 'Half an hour for the Seng Ren Monk, 15 minutes when placed on another person', NULL,
  'Armor Rating becomes 17 and extra S.D.C. is added; S.D.C. attacks striking 17 or less do no damage. Does not work against psionics, magic, explosives or M.D. attacks. Must be on before initiative. Damage/effect: Adds 40 S.D.C. +2D6 per level of experience. Scaling: extra S.D.C. 40 +2D6 per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.61'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Tough Skin (S.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Tough Skin (M.D.C.)', 'Special', 20, '20 self / 30 other', 'rifts',
  'Self or other by touch', 'One hour for the Seng Ren Monk, 20 minutes when placed on another person', NULL,
  'Adds a layer of M.D.C. protection to the skin; can combine with Mystic Body to make the Monk himself a very tough M.D.C. being (optional, not required). Damage/effect: Adds 30 M.D.C. +1D10 per level of experience. Scaling: extra M.D.C. 30 +1D10 per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.61'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Tough Skin (M.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Turn Away Animated Dead', 'Special', 10, '10 per melee round (per-round)', 'rifts',
  'Up to 60 feet (18.3 m) away', 'One melee round', 'Standard',
  'An aura repels up to 1D6 animated dead per level for 24 hours; does not affect Ghouls, Vampires, Living-Dead Immortals or entity-possessed corpses. Monk can also strike them for 3D6. Damage/effect: 3D6 (M.D. or S.D.C.) when striking animated dead. Scaling: affects up to 1D6 animated dead per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.61'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Turn Away Animated Dead');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Vibrating Palm (S.D.C. Version)', 'Special', 8, '8 to start + 2 per subsequent round', 'rifts',
  'Touch', 'Special', NULL,
  'Shakes a non-living S.D.C. object to pieces by doubling vibration each round; needs full attention. If interrupted it starts over. Damage/effect: Vibration doubles each round after the second: 1, 2, 4... 256 points by round ten; object shatters when vibration exceeds its S.D.C.. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.61'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Vibrating Palm (S.D.C. Version)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Vibrating Palm (M.D.C.)', 'Special', 24, '24 to start + 8 per subsequent round', 'rifts',
  'Touch', 'Special', NULL,
  'Same as the S.D.C. version for M.D.C. objects at four times the I.S.P.; shattered objects become salt-like powder. Damage/effect: As S.D.C. version; takes 2D6 melee rounds for the first point of vibration. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.62'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Vibrating Palm (M.D.C.)');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Chi-Gung Ward Body', 'Special', 20, 'Twenty I.S.P.', 'rifts',
  'Other or object by touch (never self)', 'Ten minutes per level of experience', NULL,
  'A layer of Chi protection that marks the target and blocks possession or entry by disembodied spirits and ghosts. Vanishes if the Seng Ren dies. More Wards or powers allowed next round. Scaling: duration 10 min per level. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.62'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Chi-Gung Ward Body');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Fill Other With Chi-Gung Attack Damage (M.D.C.)', 'Special', 20, 'Twenty I.S.P.', 'rifts',
  'Touch', '4 melee rounds (one minute)', NULL,
  'Fills another character with Chi-Gung energy so their hand-to-hand strikes do M.D. plus 1D4; not weapons or thrown objects. Damage/effect: Every punch and kick does Mega-Damage (S.D.C. becomes M.D. equivalent) +1D4 M.D. extra. A Chi-Gung power of the Chi-Gung Seng Ren monk (printed 56-62), which uses only one at a time.',
  'import', 'Rifts World Book 25: China 2 p.62'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Fill Other With Chi-Gung Attack Damage (M.D.C.)');

SELECT 'China 2 adds 29 Chi-Gung powers' AS assertion, count(*) AS got, 29 AS want
  FROM psionic_powers WHERE source_book LIKE 'Rifts World Book 25: China 2 p.%' AND category = 'Special';

SELECT 'no Chi-Gung power costs zero' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers WHERE source_book LIKE 'Rifts World Book 25: China 2 p.%' AND (isp IS NULL OR isp = 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-china-2-chi-gung-powers.sql');
