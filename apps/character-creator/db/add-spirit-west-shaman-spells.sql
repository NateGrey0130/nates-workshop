-- Shaman spells - the 34 invocations Rifts World Book 15: Spirit West defines,
-- printed 72-82. The magic of the book's seven Shaman O.C.C.s.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-spirit-west-shaman-spells.sql
--
-- The book has a TEXT LAYER. Offset comes from scripts/books.json: page_offset
-- 1, no exceptions, so printed N is cache p(N+1). None of printed 72-82 is on
-- the welded or glyph-corrupt list in this book's manifest.
--
--   group            printed   rows
--   Spirit Magic      73-75      8
--   Animal Spells     75-78     10
--   Plant Spells      78-80     11
--   Paradox/Temporal  81-82      5
--
-- THESE ARE LEVELED INVOCATIONS AND CARRY NO PREFIX. Printed 72 prints an index
-- by page AND an index by level, and every stat block repeats both figures on a
-- P.P.E. line and a Level line, so the book states the level of all 34 - unlike
-- Cloud Magic or the Spellsongs, which are level 0. No name collides with a row
-- the catalog holds (catalog-diff --remote, 2026-09-10: matched 0, missing 34),
-- so nothing needs a tradition prefix to stay unique. A prefix would not keep
-- them out of other casters' level-gated pickers either - spells carry no
-- category - and that is BOOK-INGEST-AUDIT F57, filed rather than solved here.
--
-- EVERY COST HAS FOUR READINGS AND EVERY LEVEL TWO. 33 of 34 agree on all of
-- them. The one that does not:
--
--   Nose of the Wolf - both indexes on printed 72 print 6 P.P.E.; its stat block
--   on printed 77 prints 4. Read off 200 dpi renders of both pages: the INK
--   disagrees with itself, so this is the book and not the text layer. The
--   index wins on two readings to one, 6 is stored, and the stat block's 4 is in
--   variant_note - book-survey 4c's doctrine for a book arguing with itself.
--
-- THE INDEX IS THE AUTHORITY FOR NAMES. It prints "Spirit's Blessing: Animal"
-- and "Spirit's Blessing: Plant" where the headings print "(Animal)" and
-- "(Plant)"; the index form is stored.
--
-- THE INDEX IS NOT THE AUTHORITY FOR PAGES, twice. It sends Spirit Walk and
-- Thornwall to page 81; both stat blocks sit on printed 80, under that page's
-- folio. Each row cites the page it is actually on.
--
-- TWO COSTS VARY, and ppe holds the minimum with the schedule in ppe_note:
-- Create Arrows (10, or 25 per superior fetish arrow) and Spirit Paint (10 for
-- hunting paint, 20 for war paint).
--
-- RANGE, DURATION, SAVING THROW AND AREA ARE THE BOOK'S OWN VALUES. Nourish
-- Plants prints its area on the Range line as "60 ft (9 m) diameter sphere",
-- and 60 feet is 18.3 m; transcribed as printed, into area_of_effect, with
-- range left NULL because the book states none.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose - the rule
-- add-underseas-spells.sql and add-new-west-cloud-magic.sql follow. Mechanical
-- numbers inside them were carried across from the stat blocks.
--
-- NO same_spell_as LINK. The nearest candidates were read against production:
-- Dowsing is not Earth: Dowsing or Water: Dowsing (a stick that leads to water
-- within 100 feet +20 per level for a minute per level, against a 90%/98% sense
-- over 100/200 feet per level for ten minutes per level), and Ears of the Wolf
-- is not RUE's Eyes of the Wolf.
--
-- NOT IMPORTED from these pages: the note on printed 72 that the elemental and
-- temporal spells shamans use are printed in the Conversion Book and Rifts
-- England, and the group headers saying Animal and Plant Shamans may take every
-- animal or plant spell in the Rifts line. Those are class rules and belong to
-- the Shaman imports.

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system,
   range, duration, damage, saving_throw, area_of_effect, casting_time,
   description, same_spell_as)
VALUES
  ('Call Totem', 13, 750, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.73', 'rifts', '60 ft (18.3m)', 'One minute per level or until a specific task is completed.', NULL, 'None', NULL, NULL, 'Summons the shaman''s own Totem Spirit - the greater protector of his totem species - which reaches the ritual site within 1D6 minutes. It will fight for one minute per level of the caster or undertake one task, which must be truly needed and serve the circle of life. It may refuse a task but cannot leave before the duration ends. Its statistics are in the Great Spirits section.', NULL),
  ('Call Totem Animal', 3, 25, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.73', 'rifts', 'Varies', '4 hours per level of the spell caster''s experience.', NULL, 'Standard', NULL, NULL, 'Summons one ordinary animal of the caster''s totem species, arriving within 4D6x10 minutes (halved or doubled by how likely the species is to be near). It is friendly and loyal and follows simple commands like a trained animal; real conversation needs Animal Speech. If the spell runs past 24 hours and the animal is well treated, it may stay a while afterwards at the G.M.''s option.', NULL),
  ('Call Totem Spirit', 11, 175, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.73', 'rifts', 'Not applicable.', '24 hours, no longer.', NULL, 'None', NULL, NULL, 'Summons a supernatural animal that looks like an ordinary member of the caster''s totem species. It has human intelligence but speaks only its animal tongue, follows complex requests, and serves faithfully, to the death if need be. Base stats: all attributes 12 or higher, 20 M.D.C., 3 attacks per melee, 1 M.D. plus strength and claw damage; +1 initiative, +2 to strike, parry and dodge, +4 vs magic and psionics, +5 vs horror factor, immune to mind control - modified by its species'' Totem Warrior bonuses.', NULL),
  ('Contact Spirits', 2, 8, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.74', 'rifts', 'Self or others by touch.', 'One question or one minute of conversation per level.', NULL, 'None, but contacted spirits can refuse to talk to the spell caster.', NULL, NULL, 'The shaman falls into a dream-like trance and speaks with a chosen kind of spirit - animal, plant, ancestor, lesser, greater, elemental, or a god - for one question or a minute per level. Answers come as stories, fables and riddles, and cannot reveal secrets, spells, minds or the future; the caster is helpless while in contact. Success: animal, plant and ancestor spirits 50% +5% per level; Nunnehi and other lesser spirits 35% +5%; greater spirits 30% +3%; great elemental spirits 20% +3% (+10% for Elemental Shamans); gods 12% +3%. A fetish made for this spell adds +15%.', NULL),
  ('Create Arrows', 4, 10, '10 for ordinary or fetish arrows; 25 for each superior fetish arrow, from 8th level.', NULL, 'import', 'Rifts World Book 15: Spirit West p.74', 'rifts', 'Touch', 'Indefinite', 'Fetish arrow 1 M.D.; superior fetish arrow 1D4 M.D.', 'Not applicable.', NULL, NULL, 'Conjures 1D4+1 ordinary S.D.C. arrows per level of the caster, or instead one fetish arrow per level, each doing 1 M.D. From 8th level the book adds one fetish arrow per level beyond 7th, and allows superior fetish arrows doing 1D4 M.D. at 25 P.P.E. each (300 for a dozen).', NULL),
  ('Spirit Fence', 12, 200, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.74', 'rifts', '100 square miles (160 sq. km) per level.', 'Two days per level of experience.', NULL, 'Standard (see below)', NULL, NULL, 'Raises an invisible, insubstantial wall 40 feet high around an area of any shape. It stops nothing: each creature that crosses it is subjected to see aura, see the invisible, sense evil and sense magic, and the caster - if inside the enclosed area - learns the results at once. A dozen or more crossing together yields only sketchy information. Ordinary animals register weakly; the fence is tuned to intelligent, supernatural, evil and magical beings.', NULL),
  ('Spirit Paint', 4, 10, '10 for hunting paint; 20 for war paint.', NULL, 'import', 'Rifts World Book 15: Spirit West p.75', 'rifts', 'Touch', 'Two days per level of the spell caster''s experience.', NULL, 'None.', NULL, NULL, 'Enchants face and body paint already applied, making it a short-lived minor fetish. Hunting paint gives +1 to strike and dodge and +5% to track animals and prowl. War paint gives +2 to initiative, strike, pull punch, roll with impact and save vs horror factor.', NULL),
  ('Spirit Quest', 2, 5, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.75', 'rifts', 'Self or other within 20 ft (6 m)', 'Until canceled or the quest is fulfilled.', NULL, 'None. Spell only works on willing targets.', NULL, NULL, 'A minor astral journey to the threshold of the Spirit Realm, to seek new spells or answers; without it a shaman must travel bodily to a sacred spirit cave to learn each new level''s spells. Willing companions may be taken along, even non-shamans. The quest is a trial set by the spirits, and time runs differently there - days inside are usually minutes outside, rarely the reverse. The book suggests a G.M. may make a low-level shaman travel rather than start with it.', NULL),
  ('Animal Companion', 3, 20, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.75-76', 'rifts', 'Varies', 'Indefinite', NULL, 'Standard', NULL, NULL, 'Summons a normal animal of a chosen species - typically a dog, cat or horse - that arrives behaving as a devoted, lifelong companion. There is no magical bond as with a familiar, only friendship, which the caster must nurture or it fades. Giant animals and mega-damage creatures over 50 M.D.C. cannot be summoned. A well-treated animal stays at least 1D4 weeks and may stay for good. Castable once a month, or whenever the caster has two or fewer companions.', NULL),
  ('Animal Speech', 2, 5, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.76', 'rifts', 'Self; extent of voice and hearing, about 250 feet (75 m).', '5 minutes (20 melees) per level of experience.', NULL, 'None', NULL, NULL, 'The caster and ordinary animals - or supernatural beings in animal form - understand each other''s speech. Conversation is limited by the animal''s intelligence and gives no control over it. One animal per level can be spoken to, and the spell cannot be cast on others.', NULL),
  ('Ears of the Wolf', 4, 10, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.76', 'rifts', 'Self or others by touch.', 'One minute (4 melees) per level of experience.', NULL, 'None', NULL, NULL, 'Grants a canine''s hearing: sounds up to 35,000 vibrations per second, the ability to filter out background noise, and a 01-40% chance to recognize a known voice even when disguised. Bonuses: +2 to initiative, +1 to dodge and parry.', NULL),
  ('Metamorphosis: Totem', 12, 250, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'Self', '20 minutes per level of experience.', NULL, 'None', NULL, NULL, 'Turns the caster into a supernatural form of his totem animal, half again as large, with supernatural P.S. and attributes, using the Totem Warrior bonuses and abilities listed under his totem - but none of the Totem Warrior O.C.C.''s own abilities, skills or other bonuses. Clothing and gear are left behind.', NULL),
  ('Metamorphosis: Totem Animal', 5, 18, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'Self', '30 minutes per level of experience.', NULL, 'None', NULL, NULL, 'Works as the level 7 Metamorphosis: Animal, except the caster can become only an animal of his own totem species. A shaman in animal form is unaffected by Spirit''s Blessing but can still use Totem Gift.', NULL),
  ('Nose of the Wolf', 1, 6, NULL, 'The stat block on printed 77 prints 4 P.P.E.; both indexes on printed 72 print 6. Checked on 200 dpi renders - the ink disagrees with itself, and the index figure is stored.', 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'Self or two others by touch.', '5 minutes (20 melees) per level of experience.', NULL, 'None', NULL, NULL, 'Grants a wolf''s sense of smell: identify odors 70%, track by smell alone 60%, and recognize the scent of a very familiar person 50%. Cast on a normal animal or a Dog Boy, it instead adds +5% to scent tracking.', NULL),
  ('Shared Spirits', 4, 7, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'Self or two others by touch.', '5 minutes (20 melees) per level of experience.', NULL, 'None', NULL, NULL, 'Animals regard the subject as one of their own species. It is a disguise, not invisibility or a charm: the animals may still assert dominance, and will flee or fight if the subject behaves threateningly.', NULL),
  ('Spirit''s Blessing: Animal', 7, 20, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'One by Touch.', '2 minutes (8 melees) per level of experience.', NULL, 'None', NULL, NULL, 'Cast only on a normal S.D.C. animal, which gains M.D.C. equal to its S.D.C. and hit points plus 30%, supernatural strength (bites and claws do 2D6 M.D.), double its natural speed, and immunity to horror factor, fatigue and poison. It fights no harder than it normally would. When the spell ends, half the M.D. damage it took carries over to its S.D.C. and hit points and the rest is lost.', NULL),
  ('Summon Game Animals', 8, 30, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.77', 'rifts', 'Varies', 'Special', NULL, 'Standard', NULL, NULL, 'Draws one large or 2D4 small game animals into hunting range so the caster and companions can eat. It gives no control: the animals behave normally and flee at the first sign of danger, so they must still be caught.', NULL),
  ('Totem Gift', 5, 12, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.78', 'rifts', 'Self', '2 melees per level of experience.', NULL, 'None', NULL, NULL, 'The caster gains the Totem Warrior bonuses listed under his totem without changing shape. He does not become a mega-damage being, so the bonuses apply at S.D.C. scale unless other magic makes him one. Animal abilities such as digging work at half speed with human hands.', NULL),
  ('Animate the Forest Floor', 5, 15, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.78', 'rifts', 'Affects a 35 foot (10.4 m) radius per level of the spell caster and can be cast up to a 50 foot (15.2 m) distance per level.', 'Two minutes (8 melees) per level of the spell caster.', NULL, 'Special', NULL, NULL, 'Like Carpet of Adhesion, except living vegetation animates and seizes the feet of those in the area; it needs real plant cover and fails in deserts or indoors. Pulling free takes P.S. 25 and 1D4+2 melee actions, and anyone still on the ground is caught again. A successful save lets a character keep moving and struggle out in 1D4 melee rounds per level of the caster. Save penalties: scrub -2, light forest or tall grass -1, forest -2, jungle -4, none of them applying to M.D.C. or supernatural beings. The arms stay free for weapons, spells and psionics.', NULL),
  ('Animate Tree', 7, 25, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.78', 'rifts', '120 ft (36m)', 'One minute (4 melees) per level of experience.', NULL, 'None', NULL, NULL, 'Brings a normal tree''s limbs to life to lift, hold, strike or entangle; it cannot walk or talk. The caster animates about 10 feet of tree height per level. For each 10 feet the tree has the equivalent of 3 supernatural P.S. for damage (4 for lifting), 100 S.D.C. (1 M.D.), 2 attacks per melee and +1 A.R. from a base of 6. A tree 50 feet or taller also entangles as Animate the Forest Floor and imposes -1 to all combat bonuses per 10 feet beyond 50. Reach is about half the tree''s height.', NULL),
  ('Call Forest Guardian', 11, 160, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.79', 'rifts', 'Distance is not applicable, but this spell only works in forested or jungle areas.', '24 hours.', NULL, 'None.', NULL, NULL, 'Summons a powerful spirit of the woods that arrives in 1D6 minutes and answers questions, performs tasks or fights for 24 hours. It has the shaman''s O.C.C. abilities and every plant spell, cast at 6th level. Stats: physical attributes 22 and supernatural, others 12; P.P.E. 100+4D6x10; 90 M.D.C.; 4 attacks per melee at 2D6 M.D.; +4 to strike, parry and dodge, +4 vs magic and psionics, +5 vs horror factor, +6 vs mind control.', NULL),
  ('Dowsing', 1, 6, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.79', 'rifts', '100 feet (30.5 m) +20 feet (6 m) per level of experience.', 'One minute (4 melees) per level of experience.', NULL, 'Not applicable.', NULL, NULL, 'Cast on a supple stick, which tugs the caster toward the nearest water within range - underground included - and points at it on arrival. Not the warlock spells Earth: Dowsing or Water: Dowsing, which differ in range, duration and mechanism.', NULL),
  ('Magic Stick', 6, 20, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.79', 'rifts', 'Single club-sized stick', 'Until all M.D. strikes are used up or 12 hours, whichever comes first.', 'The branch''s own damage (typically 1D6, 2D4 or 2D6) as M.D.', 'None', NULL, NULL, 'Charges a natural branch - cut or found, never a carved weapon and never Millennium Tree wood - with one mega-damage strike per level of the caster, so a club doing 2D4 S.D.C. does 2D4 M.D. A strike is spent only when it lands. The same item can take the spell only twice, and an S.D.C. item can parry the stick.', NULL),
  ('Nourish Plants', 6, 15, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.79', 'rifts', NULL, 'Permanent.', NULL, 'None.', '60 ft (9 m) diameter sphere.', NULL, 'Gives every plant in the area a full day''s nutrients and the equivalent of sunlight, then repeats it for one day per level of the caster, so it works indoors or in darkness. Sickly plants recover within 24 hours; cuts and breaks are not healed.', NULL),
  ('Plant Growth', 7, 25, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.79', 'rifts', '60 ft (18.3m)', 'Permanent', NULL, 'Standard, but at -4.', NULL, NULL, 'Instantly ages a plant by 3D6 months per level of the caster, stopping wherever the caster chooses - to raise a barrier of growth, cover tracks, bring fruit out of season or restore damaged woodland. The plant grows in its own natural way rather than to the caster''s design, and ends up healthier than natural growth would leave it.', NULL),
  ('Plant Travel', 6, 25, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.80', 'rifts', 'Self or two others by touch.', 'One hour per level of experience.', NULL, 'Standard, but only for unwilling targets.', NULL, NULL, 'Surrounding plants pass the caster along, one to the next, at about 6 mph - 3 mph over grassland, 10 mph in jungle, not at all in desert - and he can eat or sleep on the way. Cast on an unwilling target who fails to save, it carries the victim off in a direction the caster chooses, with a new save every 30 minutes.', NULL),
  ('Spirit''s Blessing: Plant', 5, 15, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.80', 'rifts', '75 feet (22.5 m)', 'Varies with the different magical effects; some permanent, others temporary. The doubled S.D.C. lasts only five minutes (20 melees) per level of experience.', NULL, 'None.', NULL, NULL, 'Cures one plant of disease, blight or poison, restores it to full health, and temporarily doubles its S.D.C. It affects a single plant only - an animated tree or a Thornwall qualifies, the forest floor does not - and not intelligent plants, plant spirits or mega-damage plants.', NULL),
  ('Spirit Walk', 9, 65, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.80', 'rifts', 'Self or two others by touch.', 'Indefinite.', NULL, 'None.', NULL, NULL, 'A specialized Mystic Portal: the caster opens a one-way doorway through the P.P.E. of a large tree into the Realm of the Gods and walks in bodily, not astrally. Entry still depends on getting past the Realm''s defenses, usually by first gaining the spirits'' permission; once inside he may stay until he chooses to leave or is asked to go.', NULL),
  ('Thornwall', 3, 10, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.80', 'rifts', '60 feet (18.3 m) +10 feet (3 m) per level of experience.', 'One hour per level of experience.', NULL, 'None.', NULL, NULL, 'Raises dense thorny branches in 10-foot cubes, one per level, which can be chained into a wall (never a closed ring) or merged into one larger cube. It stops a normal vehicle under 60 mph; a faster one loses half its momentum, takes 3D6x5 damage, and breaks through 10 feet on 10% per 10 mph over 50 (+40% for large or armored vehicles). Cutting through takes four melee rounds per 10 feet, and unarmored people forcing a way take 3D6 S.D.C. per melee; a charging character must dodge 16+ or take 6D6 S.D.C. M.D.C. armor, power armor, cyborgs and supernatural beings are unhurt, and the larger ones push through 10 feet per melee. Spirit''s Blessing doubles its density.', NULL),
  ('Absolute Darkness', 10, 120, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.81', 'rifts', '100 feet (30.5 m) +5 feet (1.5 m) per level of experience.', 'One minute (4 melees) per level of experience.', NULL, 'None.', '5-20 foot (1.5 to 6 m) spherical radius.', NULL, 'The reverse of Globe of Daylight: a globe of total darkness. Only radar, keen smell and hearing, feelers and supernatural sight work inside it; nightvision, light amplification, infrared and thermal vision fail. Those inside are effectively blind (-9 to combat maneuvers), vampires included, nobody outside can see in, and shots into or out of it count as shooting wild.', NULL),
  ('Little Force', 11, 135, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.81', 'rifts', 'Self', 'One melee round (15 seconds) per level of experience.', NULL, 'None.', NULL, NULL, 'Wraps the caster in an aura that throws non-magical force and energy back at its source at double strength - punches, weapon blows, bullets, rail gun rounds and energy beams alike, with no dodge or parry. Magic, magical weapons and psionics pass through unaffected. While it lasts the caster''s own physical attacks do half damage; magical and psionic ones are unaffected.', NULL),
  ('Will of the Earth', 8, 80, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.81', 'rifts', 'Varies', 'Two minutes (8 melees) per level of experience.', NULL, 'None if cast on an inanimate object, area or self. Standard if targeting an unwilling victim.', 'Either a specific target (person or object) or an area that has a spherical radius of 10 feet (3 m).', NULL, 'Bends gravity one of three ways, chosen at casting. Reduced: one item or person up to 140 feet away weighs a fiftieth as much, and a person gains +2 to dodge and can leap three feet per P.S. point. Increased: weight up to 30 times normal, immobilizing anyone too weak to carry it and costing 5 Speed per 200 pounds. Cancelled: everything in a 10-foot radius floats, at -3 to combat rolls and -1 melee action, until tethered and pulled out.', NULL),
  ('Sphere of Negation', 10, 120, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.81', 'rifts', 'Self', 'One minute (4 melees) per level of experience, or disappears the moment the spell caster steps out of the sphere, whichever comes first.', NULL, 'None.', NULL, NULL, 'An eight-foot sphere of perfect balance around the caster, with room for two more pressed to his sides. Bullets drop, beams disperse, and blows and spells have no effect on those inside. It works both ways: nobody inside can attack, cast, use magic items or sense magic, and psionics used into or within it work at half potency. The book presents it as a tool for negotiating with hostile parties.', NULL),
  ('Universal Balance', 9, 100, NULL, NULL, 'import', 'Rifts World Book 15: Spirit West p.82', 'rifts', '90 ft (27 m)', 'One melee action (roughly 3 seconds) per level of experience.', NULL, 'Standard.', NULL, NULL, 'Briefly turns a supernatural creature into an S.D.C. being. It keeps its abilities and spells, and its M.D.C. converts at 100 S.D.C. per point rather than being reduced - but for the duration ordinary S.D.C. weapons can hurt it.', NULL);

-- Read the result back rather than trusting the exit code. Every want below is
-- derived from the book's printed 72 index, not from the database that just
-- loaded these rows.
SELECT 'the 34 shaman spells are present' AS assertion,
       count(*) AS got, 34 AS want
  FROM spells
 WHERE source_book LIKE 'Rifts World Book 15: Spirit West%';

-- The printed 72 index costs, summed: 2497. A single mistyped cost moves it.
SELECT 'their P.P.E. costs sum to the index total' AS assertion,
       sum(ppe) AS got, 2497 AS want
  FROM spells
 WHERE source_book LIKE 'Rifts World Book 15: Spirit West%';

-- The by-level index counts 2/3/3/4/4/3/3/2/2/2/3/2/1 across levels 1-13: 216.
SELECT 'their levels sum to the by-level index total' AS assertion,
       sum(level) AS got, 216 AS want
  FROM spells
 WHERE source_book LIKE 'Rifts World Book 15: Spirit West%';

SELECT 'Nose of the Wolf carries the index cost and records the stat block' AS assertion,
       count(*) AS got, 1 AS want
  FROM spells
 WHERE name = 'Nose of the Wolf' AND ppe = 6 AND instr(variant_note, 'prints 4 P.P.E.') > 0;

SELECT 'none of them lacks a description' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells
 WHERE source_book LIKE 'Rifts World Book 15: Spirit West%'
   AND (description IS NULL OR description = '');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-spirit-west-shaman-spells.sql');
