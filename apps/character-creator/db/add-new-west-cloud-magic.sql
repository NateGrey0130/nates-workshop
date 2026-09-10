-- Cloud Magic - the 58 spells Rifts World Book 14: New West defines, printed
-- 37-45. The magic of the Lyn-Srial; the Sky-Knight and the Cloudweaver cast
-- it, and the Psi-Slinger does not.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-new-west-cloud-magic.sql
--
-- The book has a TEXT LAYER. Offset comes from scripts/books.json: page_offset
-- 1, no exceptions, so printed N is cache p(N+1). None of printed 37-45 is on
-- the welded or glyph-corrupt list this book's manifest carries.
--
--   category               printed   rows
--   Clouds of War            37-39     13
--   Clouds of Defense        39-40      7
--   Clouds of Peace          40-41      6
--   Clouds of Travel         41-42      7
--   Clouds of Survival       42-43     10
--   Clouds of the Mind       43-44      7
--   Clouds of Creation       44-45      8
--
-- THE PREFIX IS THE CATEGORY, not the tradition, and that is a decision rather
-- than a default. Nate chose it on 2026-09-09 over "Cloud Magic:" and over a
-- new spells.category column. The reason it is the right one is the Sky-Knight
-- on printed 134: the book grants him all of Clouds of War and Clouds of Peace,
-- and then one spell per level from any category EXCEPT Clouds of Creation. A
-- grant is stated by CATEGORY, magic.spells_from is an explicit list of names,
-- and there is no category column - so with any other prefix that exclusion
-- could not be rebuilt from the catalog, only by re-reading printed 37.
--
-- It also follows the larger of the two conventions already here. Air:, Earth:,
-- Fire: and Water: are 231 rows and the prefix is the group a class grants by;
-- Ocean:, Dolphin: and Spellsong: are 72 and the prefix is the tradition. The
-- elemental families are the closer analogue and the one with the precedent.
--
-- EVERY COST HAS TWO INDEPENDENT READINGS AND ALL 58 AGREE. Printed 37 opens
-- with an index printing Name (cost) for all seven categories, and each
-- description then repeats the figure on its own P.P.E.: line. Reconciled
-- mechanically, 57 of 57 description blocks matched the index. Three of the
-- index figures are spelled as words in the stat block - One, One, Two for
-- Blinding Flash, Cloud of Ascension and Globe of Daylight - and agree.
--
-- THE INDEX IS THE AUTHORITY FOR NAMES, and it disagrees with the description
-- headings twice: the index prints "Fly Like The Wind" where the heading has a
-- lower-case "the", and "Clouds of Truth" where the heading sets "Clouds of
-- TVuth". The second is the Tr ligature fault this book's text layer also puts
-- in "Saddle TVamp" on printed 101. Both stored as the index prints them.
--
-- CLOUD MAGIC HAS NO LEVELS, so every row is level 0. The book gives one: a
-- class granting cloud magic names the categories it gets and the number of
-- picks per level, and printed 37 states only that spell strength rises at
-- levels 5, 10 and 15. This follows add-wormwood-prayers.sql and the Underseas
-- Spellsongs; leveling.js treats a named spells_from list as REPLACING the
-- spell-level gate, so 0 gates nothing rather than gating them all out.
--
-- GLOBE OF DAYLIGHT IS TWO ROWS, and that is the book's doing rather than a
-- duplicate. Printed 37 lists it under Clouds of Survival AND under Clouds of
-- Creation; printed 45 prints the Creation heading with a redirect to the
-- survival entry and no stat block of its own. Both rows carry the survival
-- stat block, the Creation row cites printed 45 where its heading is, and it
-- points at the survival row through same_spell_as so the pair can be checked
-- for drift. Verified on a 150 dpi render of printed 45, not inferred.
--
-- EIGHT ROWS SHARE A NAME WITH A ROW THE CATALOG ALREADY HOLDS, AND ONLY
-- THREE ARE LINKED. Every candidate was run through
-- scripts/same-spell-lib.mjs comparePair() against a rebuilt database on
-- 2026-09-09 rather than judged by eye, which is the only reason the split
-- came out this way - four of the eight read as obviously identical and are
-- not:
--
--   this book              catalog                  comparePair   linked
--   Globe of Daylight      (survival row, below)    pass          YES
--   Calm Storms      200   Calm Storms    L12/200   pass          YES
--   See the Invisible 10   See the Invis. L1/4      pass          YES
--   Blinding Flash     1   Blinding Flash L1/1      saving_throw  no
--   Globe of Daylight  2   Globe of Dayl. L1/2      description   no
--   Tongues           12   Tongues        L6/12     duration      no
--   Create Water      10   Create Water   L6/15     range         no
--   Breath of Life   100   Air: Breath..  L5/60     pass          no
--
-- The five unlinked rows carry the catalog's reading in variant_note instead,
-- so the disagreement is on the record rather than lost. This is the Underseas
-- Ocean:/Water: pattern, where six of ten candidates were linked and four were
-- not; the modelling gap is BOOK-INGEST-AUDIT.md F26.
--
-- Why each of the five is not linked, because "same spell" is the claim the
-- link makes and three of these five are the same spell:
--
--   Blinding Flash and Globe of Daylight ARE the same spell - same range, same
--   duration, same cost - and the checker still refuses them. Blinding Flash
--   because the Book of Magic row offers -1 to the target's save for 3 more
--   P.P.E. and New West prints no such option, so the saving_throw numbers
--   genuinely differ; Globe of Daylight because the catalog's description is a
--   thin two-liner and shares only 0.13 of its vocabulary with this one,
--   against a 0.35 floor. Neither is a disagreement about the spell, and
--   linking either would make the suite red on a rebuild. The honest fix for
--   Globe of Daylight is a better description on the Book of Magic row, which
--   is another book's row and not this import's business.
--
--   Tongues and Create Water are genuinely different printings. Tongues lasts
--   five minutes per level here and three in Rifts Ultimate Edition; Create
--   Water reaches 6 feet and fills a one gallon container here, against 10
--   feet and half a gallon per level in the Book of Magic.
--
--   BREATH OF LIFE PASSES THE CHECKER AND IS STILL NOT LINKED, and it is the
--   one worth arguing about. It passes because the two duration fields -
--   "Instant" here, "Permanent." there - contain no numbers at all, so the
--   comparison sees two empty strings and calls them equal. That is a blind
--   spot rather than agreement. The Book of Magic spell revives the recently
--   dead on a 70% +1% per level roll for 60 P.P.E.; this one costs 100 P.P.E.
--   AND a permanent P.E. point, heals every wound as well as restoring life,
--   and states no roll. Same name, more effect, a permanent cost the other
--   does not have. A passing checker is not a reason to assert something the
--   pages do not support.
--
-- THREE COSTS ARE VARIABLE. ppe holds the minimum, which is what the sheet's
-- use button spends, and the schedule is in ppe_note - migration 021:
-- Breath of Life (a permanent P.E. point on top), Cloud of Healing (15 for an
-- S.D.C. character, 45 for a mega-damage one), Cloud Castles (250, or 1000 to
-- make it semi-permanent).
--
-- RANGE, DURATION, DAMAGE AND SAVING THROW ARE THE BOOK'S OWN VALUES,
-- transcribed. Two things about them:
--
--   Flying Chariot's range is stored as the book prints it, "10 feet (12.2 m)",
--   and those two do not agree - 12.2 m is 40 feet. Read off a 500 dpi render
--   of printed 45 to rule out a text-layer fault: the INK reads 10. It is an
--   error in the book, so it is transcribed rather than corrected.
--
--   Fog of Peace's Radius and Duration lines on printed 41 run into stray
--   glyphs from the artwork beside them. Trimmed at the sentence and checked
--   against the page.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose - the same rule
-- add-underseas-spells.sql follows, and the reason the survey files can be
-- tracked at all. Every mechanical number inside them was carried across from
-- the stat block rather than retyped.
--
-- NOT IMPORTED from these pages: the Character Notes paragraph on printed 37,
-- which prices cloud magic for non-Lyn-Srial casters - 50% more P.P.E., 1500
-- extra experience per level, minimum I.Q. and M.E. of 18, and years of
-- training. That is a class rule rather than a spell field, and it belongs to
-- the Sky-Knight and Cloudweaver imports.

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system,
   range, duration, damage, saving_throw, area_of_effect, casting_time,
   description, same_spell_as)
VALUES
  ('Clouds of War: Cloud Blast', 0, 12, NULL, NULL, 'import', 'Rifts World Book 14: New West p.37', 'rifts', '600 feet (183 m) +100 feet (30.5 m) per level of experience.', 'One melee round (15 seconds) per level of the spell caster.', '2D6 S.D.C. or M.D. (as desired by the spell caster)', 'Dodge at -5; a 17 or higher is needed to dodge.', NULL, NULL, 'A charged grey cloud forms above the caster''s head; each pointing gesture costs one melee action and fires a blast of ball lightning from it.', NULL),
  ('Clouds of War: Cloud Disc', 0, 8, NULL, NULL, 'import', 'Rifts World Book 14: New West p.37', 'rifts', '900 feet (270 m) +20 feet (6 m) per level of experience.', 'One melee round (15 seconds)', '1D6 M.D. plus knock-down regardless of the opponent''s size.', 'Dodge at -3; a 17 or higher is needed to dodge.', NULL, NULL, 'A swirling shield-sized disc of cloud forms above the caster''s shoulder and is hurled at an aimed target, vanishing on impact. It knocks the target off its feet and back 3D4 yards regardless of size, costing them initiative and one melee action. One disc can be created and thrown per melee action, so a character with five attacks can throw five.', NULL),
  ('Clouds of War: Clouds of Imprisonment', 0, 25, NULL, NULL, 'import', 'Rifts World Book 14: New West p.37', 'rifts', '60 feet (18 m) +10 feet (3 m) per level of experience.', 'One melee round (15 seconds) per every two levels of experience (2,4, 6, 8, 10, 12 and 14).', NULL, 'Standard save; success reduces duration by half.', NULL, NULL, 'A sphere of cloud encircles one target per three levels of the caster. The prisoner can see, hear and smell nothing but the caster''s voice, and stepping into the cloud only leads him through endless white mist. While imprisoned he cannot be attacked or hurt by anything, magic and psionics included. When the spell ends the cloud vanishes and he is standing exactly where he was taken. A successful save halves the duration; dispel magic barriers or negate magic ends it. The caster cannot use it on himself.', NULL),
  ('Clouds of War: Cloud Lance', 0, 5, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', 'Self', 'Three minutes per level of experience.', NULL, 'None', NULL, NULL, 'A lance of cloud-stuff forms in the caster''s hands, doing either mega-damage or S.D.C. as the caster chooses. A flying charge adds 1D6 S.D.C. for every 10 mph of speed, S.D.C. attacks only. It grants +1 to strike and disarm. A Sky-Knight will not use the mega-damage setting against an opponent armed with S.D.C. weapons.', NULL),
  ('Clouds of War: Cloud Sword', 0, 6, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', 'Self', 'Two minutes per level of experience.', NULL, 'None; can be parried and dodged as normal.', NULL, NULL, 'A sword of apparently soft cloud forms in the caster''s hand and is nothing of the kind, doing either mega-damage or S.D.C. as the caster chooses. A Sky-Knight will not use the mega-damage setting against an opponent armed with S.D.C. weapons.', NULL),
  ('Clouds of War: Cloud Whip', 0, 8, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', 'Self, to use the weapon; the whip has a range of 60 feet (18.3 m).', '2 minutes per level of experience.', NULL, 'None', NULL, NULL, 'A whip of cloud and trailing mist forms in the caster''s hand, doing either mega-damage or S.D.C. as the caster chooses. It reaches targets 60 feet away and is +2 to disarm.', NULL),
  ('Clouds of War: Fiery Cloud', 0, 12, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', '100 feet (30.5 m) +20 feet (6 m) per level of experience.', 'One melee round (15 seconds) per level of experience.', NULL, 'Standard', 'Radius: 20 feet (6 m) +5 (1.5 m) per level of experience.', NULL, 'A greyish-red cloud burns everything it engulfs and blinds heat sensors and infrared optics inside it. Anyone unarmoured who breathes it chokes on sulphur and ash, halving all combat bonuses and attacks per melee. A successful save negates the hit point damage and halves the other penalties.', NULL),
  ('Clouds of War: Poisonous Cloud', 0, 20, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', '100 feet (30.5 m) per level of experience.', 'One melee per level of experience.', NULL, 'Standard', 'Radius: 20 feet (6 m) +5 feet (1.5 m) per level.', NULL, 'Everyone caught without full environmental armour or an air filter is left dizzy and nauseous, at half speed, half attacks per melee and half skill performance. A successful save reduces those penalties to a quarter.', NULL),
  ('Clouds of War: Rolling Thunder', 0, 60, NULL, NULL, 'import', 'Rifts World Book 14: New West p.38', 'rifts', '20 feet (6 m) plus 10 feet (3 m) per each subsequent level of the spell caster (20 feet at level one, 30 at level two, etc.).', 'Two melee rounds (30 seconds) per level of the spell caster.', '1D6x10 M.D.', 'Living creatures can dodge by dropping to a prone position and letting the thunderhead roll over them, or by leaping out of the way if near the edge of the cloud (roll initiative to see if leaping dodge is successful).', 'Size: About 20 feet (6 m) wide and tall; the length is the full range.', NULL, 'A black thunderhead 20 feet high rolls low along the ground, knocking down or shoving aside everything in its path. The first hit knocks victims down and stuns them for 1D4 melee rounds, or pushes them to the limit of its range. Against an obstacle heavier than two tons it stops and keeps battering, dealing its damage again every melee round. Once it reaches maximum range the cloud keeps rolling in place, pinning anyone underneath at a quarter speed with no combat bonuses and almost no visibility; standing up into it inflicts 2D4x10 M.D. and knocks the character down again every time.', NULL),
  ('Clouds of War: Storm Cloud', 0, 80, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', '500 feet (152 m) +100 feet (30.5 m) per level of the caster.', 'Two melee rounds (30 seconds) per level of experience.', NULL, 'None; although lightning bolts can be dodged at -5.', 'Radius: 200 feet (61 m) +10 feet (3 m) per level of experience.', NULL, 'A storm cloud appears over the enemy and acts like a summoned creature, with a horror factor of 10. Gusting wind and rain leave everyone in the area at -3 on initiative and -1 to strike, and it can loose a lightning bolt twice per melee round. Directing it costs the caster all but one melee action, though focus can be released and retaken later. It cannot be harmed physically, but dispel magic barriers or negate magic destroys it.', NULL),
  ('Clouds of War: Storm Cloud Sword', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', 'Self, to use the sword; lightning: 100 feet (30.5 m) +10 feet (3 m) per level of experience.', '2 minutes per level of experience.', NULL, 'None; can be parried and dodged as normal.', NULL, NULL, 'A sword of black storm cloud shot through with muted lightning, doing either mega-damage or S.D.C. as the caster chooses. Twice per melee round it can fire an electrical blast for 4D6 M.D. at 100 feet plus 10 feet per level.', NULL),
  ('Clouds of War: Wind Hammer', 0, 8, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', 'Self, to use the weapon, but can be thrown 1000 ft (305 m).', 'Two minutes per level of experience.', NULL, 'None, other than dodge; a parry will cause the opponent to suffer half damage.', NULL, NULL, 'A semitransparent hammer of mist that strikes with the force of a tornado. It can be thrown 1000 feet and returns to the thrower within about one melee action.', NULL),
  ('Clouds of War: Wind Spear', 0, 6, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', 'Self, to use the weapon; lightning: 100 feet (30.5 m) +10 feet (3 m) per level of experience.', 'Instant', NULL, 'None, other than dodge; a parry will cause the opponent to suffer half damage.', NULL, NULL, 'A semitransparent spear of mist that strikes with the force of a tornado, and can be thrown 100 feet plus 10 feet per level of experience.', NULL),
  ('Clouds of Defense: Blinding Flash', 0, 1, NULL, 'The Book of Magic p.91 prints the same spell at level 1 for the same 1 P.P.E., and additionally allows -1 to the target save for 3 more P.P.E.; New West prints no such option.', 'import', 'Rifts World Book 14: New West p.39', 'rifts', '10 feet (3 m) radius; up to 60 feet (18.3 m) away.', 'Instant', NULL, 'Standard', NULL, NULL, 'A burst of white light blinds everyone in a ten foot radius for 1D4 melee rounds, at -5 to strike and -10 to parry and dodge, with a 1-50% chance of falling per 10 feet travelled. A successful save vs magic prevents the blinding. It does not affect bionic or cybernetic eyes.', NULL),
  ('Clouds of Defense: Clouds of Light Deflection', 0, 8, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', 'Self or others by touch.', 'One minute per level of the spell caster.', NULL, 'None', NULL, NULL, 'Sparkling clouds swirl around the character and diffuse lasers completely, so nothing inside takes laser damage. Other energy - magic lightning, fire balls, particle beams, plasma - penetrates and does full damage, but every attacker shoots at -5 to strike either way. Those inside can see out perfectly.', NULL),
  ('Clouds of Defense: Cloud of Darkness', 0, 12, NULL, NULL, 'import', 'Rifts World Book 14: New West p.39', 'rifts', 'Self or others up to 60 feet (18.3 m) away.', 'One minute per level of the spell caster.', NULL, 'None, unless used against an opponent. Standard otherwise.', NULL, NULL, 'A dark cloud wraps the target and hides him from all non-magical detection. A willing subject is himself blinded by it, at -4 to strike and a third slower. Used as an attack, a victim who fails to save is lost in the blackness - -9 on all combat attacks, half speed, blind except by magical sight, and a 75% chance of stumbling and falling for every action taken. The cloud clings to him wherever he goes and hides him too, so attackers are also -9 to strike him. A successful save lets the darkness fade within six seconds; dispel magic barrier or negate magic destroys it instantly.', NULL),
  ('Clouds of Defense: Cloud Rider Armor', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', 'Self or by touch.', 'Two minutes per level of the spell caster.', NULL, 'None', NULL, NULL, 'Mist clings to the recipient and forms armour resembling chain mail, worth 20 M.D.C. plus 10 M.D.C. per level of the caster. Elemental magic, lightning and similar natural energy do half damage against it. It offers no environmental protection from gas, radiation, heat or disease.', NULL),
  ('Clouds of Defense: Cloud Shield', 0, 6, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', 'Self', 'Three minutes per level of experience.', NULL, 'None', NULL, NULL, 'A cloud-like shield forms in one hand and parries as a physical shield does, with 50 M.D.C. plus 10 M.D.C. per level and +1 to parry. Energy attacks can be parried with it at -5. Bullets, arrows, punches and other kinetic attacks pass straight through it.', NULL),
  ('Clouds of Defense: Fog of War', 0, 35, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', '500 feet (152 m) +100 feet (30.5 m) per level of the caster.', 'One minute per level of the spell caster.', NULL, 'None', 'Radius: 100 feet (30.5 m) +10 feet (3 m) per level of experience.', NULL, 'Visions of battle and death appear in the fog. Characters reluctant or uncertain consider retreat or a settlement, and if they attack anyway are -3 on initiative and -3 to save vs horror factor. Characters already driven to fight are instead motivated, at +1 on initiative and +3 to save vs horror factor.', NULL),
  ('Clouds of Defense: Storm Rider Armor', 0, 30, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', 'Self only.', 'Two minutes per level of the spell caster.', NULL, 'None', NULL, NULL, 'A white mist crackling with blue lightning grants 20 M.D.C. plus 10 M.D.C. per level, like cloud rider armor, and additionally makes the wearer impervious to all elemental magic, lightning and even ley line storms, with all other energy at half damage. It also allows hovering and flight at 60 mph with +2 to dodge airborne, at any altitude with breathable air.', NULL),
  ('Clouds of Peace: Cloud of Harmony', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', '100 feet (30.5 m) +10 feet (3m) per level of experience.', '4 melees per level', NULL, 'Standard', 'Radius: 20 feet (6 m) +5 feet (1.5 m) per level.', NULL, 'Beautiful music fills the radius and everyone within must save or be content to do nothing but listen until it ends. When it stops, most hostility has been soothed and the listeners may be open to negotiation. Any aggression against them breaks the trance at once and they attack without penalty.', NULL),
  ('Clouds of Peace: Cloud Haven', 0, 25, NULL, NULL, 'import', 'Rifts World Book 14: New West p.40', 'rifts', 'Line of sight up to 100 feet (30.5 m)', 'One hour per level of experience.', NULL, 'None, if used on receptive targets, standard otherwise.', NULL, NULL, 'A mist sweeps up those willing to go and hides them in a cloud that is warm and calming, and where time seems half as long. They can be kept safe for up to one hour per level of the caster and returned whenever the caster wishes. If the caster is killed they stay for the full duration and are then returned to where they were taken from.', NULL),
  ('Clouds of Peace: Fog of Peace', 0, 50, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', '100 feet (30.5 m) per level of experience.', 'One minute per level of the spell caster.', NULL, 'Standard', 'Radius: 20 feet (6 m) +10 feet (3 m) per level of experience.', NULL, 'Swirling fog clouds the thoughts of everyone in the radius, making them uncertain of the fight and of their reasons for it. All affected are -5 on initiative, -3 to strike and -3 to save vs horror factor.', NULL),
  ('Clouds of Peace: Healing Rain', 0, 100, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', 'Up to 200 feet (61 m) +100 feet (30.5 m) per level of experience.', 'Permanent', NULL, 'None', 'Radius: 100 feet (30.5 m) +10 feet (3 m) per level.', NULL, 'A gentle rain washes away the aftermath of battle - blood, acid, disease and radiation - and makes vegetation grow at twice its normal rate.', NULL),
  ('Clouds of Peace: Winds of Change', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', '200 feet (61 m) +100 feet (30.5 m) per level.', 'Instant', NULL, 'None if used on receptive targets, standard otherwise.', NULL, NULL, 'The target is given two melee rounds to rethink what he is about to do, with a flash of insight into how it might go wrong. The G.M. describes a few consequences the character had not considered; whether he acts on them is up to the player.', NULL),
  ('Clouds of Peace: Winds of Regret', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', '100 feet (30.5 m) +50 feet (15.2 m) per level of experience.', 'Instant', NULL, 'Standard', 'Radius: One character per every two levels within a 20 foot (6 m) radius.', NULL, 'A wind blows across the target, who must save or hesitate, burning two of his melee actions, and is shown the consequences of what he is about to do. It works only when a character is about to seriously harm or kill someone, and does nothing in any other situation.', NULL),
  ('Clouds of Travel: Blink of an Eye', 0, 24, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', 'Self or object weighing less than 50 Ibs (22.7 kg).', 'Instant', NULL, 'None', NULL, NULL, 'The caster teleports instantly to any spot within eyesight, carrying everything on his person but nothing merely held or touched. Alternatively a single object under 50 pounds can be teleported instead.', NULL),
  ('Clouds of Travel: Cloud of Ascension', 0, 1, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', 'Self only.', '10 minutes per level', NULL, 'Not applicable', NULL, NULL, 'Every Lyn-Srial knows this spell and uses it almost without thinking. It levitates the character up and down at a speed equal to their Spd attribute and holds them hovering, at any altitude with breathable air, with slight lateral movement at a speed of 3.', NULL),
  ('Clouds of Travel: Cloud Portal', 0, 550, NULL, NULL, 'import', 'Rifts World Book 14: New West p.41', 'rifts', 'Appears within 10 feet (3 m) of the spell caster.', 'One melee round (15 seconds) per level of the caster.', NULL, 'None', 'Size: 6 foot (1.8 m) radius.', NULL, 'A white portal that teleports anyone passing through it to a place the caster has chosen, which must be well known to him and within one hundred miles per level. The base chance of arriving correctly is 70% plus 3% per level.', NULL),
  ('Clouds of Travel: Cloud of Speed', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self or one other person by touch.', 'One minute per level of experience.', NULL, 'None', NULL, NULL, 'Wisps of cloud gather at the recipient''s feet and lift him a foot off the ground, letting him run at 50 mph without tiring, with +1 on initiative and +2 to dodge.', NULL),
  ('Clouds of Travel: Cloud Surfing', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self or one other person by touch.', '10 minutes per level of experience.', NULL, 'None', NULL, NULL, 'An airborne character rides a wisp of cloud like a surfer on a wave, able to change direction, climb or dive at double speed, at any altitude with breathable air. Typical speed is 15-30 mph, or 70-150 mph on storm winds. Above 50 mph the rider must roll under gymnastics or acrobatics at -20% to keep his balance or be swept off as the cloud vanishes. The cloud also vanishes below 600 feet, which is no trouble for a naturally flying Lyn-Srial and serious trouble for anyone else.', NULL),
  ('Clouds of Travel: Fly Like The Wind', 0, 30, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self or one other by touch.', 'Five minutes per level of experience.', NULL, 'None', NULL, NULL, 'The recipients can fly at 150 mph, at any altitude with breathable air, with +1 on initiative and +4 to dodge while flying.', NULL),
  ('Clouds of Travel: Portal to the Beyond', 0, 700, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self and up to one other per level of experience.', 'One melee round (15 seconds) per level of the caster.', NULL, 'None', 'Size: 10 foot (3 m) long, 6 foot (1.8 m) wide opening in the sky.', NULL, 'A dimensional tear opens in the sky 30 feet above the caster. Flying or jumping into it transports the character in body and spirit either to the Astral Plane or back to Tryth-Sal, regardless of distance.', NULL),
  ('Clouds of Survival: Aerial Navigation', 0, 4, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self', '10 minutes per level of experience.', NULL, 'None', NULL, NULL, 'The character navigates by land patterns and landmarks seen from the air and by the position of the sun, moon and stars, and always knows where Tryth-Sal lies. Equal to the navigation and land navigation skills at 90%.', NULL),
  ('Clouds of Survival: Breath of Life', 0, 100, 'The caster also permanently loses one P.E. point.', 'The Book of Magic p.62 prints Air: Breath of Life at level 5 for 60 P.P.E., reviving the recently dead on a 70% +1% per level roll and costing the caster nothing permanent.', 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Touch only.', 'Instant', NULL, 'None', NULL, NULL, 'The caster heals all wounds and restores life to the dying or recently dead, within the hour, by casting the magic and breathing into their mouth; a swirling wind then rushes in and revives them. It restores 2D6 S.D.C. and 2D6 hit points. It cannot replace severed limbs or missing organs.', NULL),
  ('Clouds of Survival: Calm Storms', 0, 200, NULL, NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Immediate area around the mage, affecting one mile (1.6 km) in diameter per level of experience.', 'One hour per level of experience.', NULL, 'None', NULL, NULL, 'As a spell, the caster slows a downpour to light rain, halves wind speed, halves wave height and lightens a dark sky. Cast as a ten minute ritual it turns torrential rain to drizzle, drops wind to a breeze, returns ocean waves to normal, disperses a tornado instantly and clears the sky. It works on natural and magically induced storms alike. If the magic outlasts the storm, the storm is gone when it ends; if the storm outlasts the magic, the sky darkens again and it resumes at full force.', 'Calm Storms'),
  ('Clouds of Survival: Cloud of Healing', 0, 15, '15 for an S.D.C. character; 45 to restore 3D6 M.D.C. to a mega-damage being.', NULL, 'import', 'Rifts World Book 14: New West p.42', 'rifts', 'Self or Touch', 'Instant/3 hours per level of experience.', NULL, 'None', NULL, NULL, 'The most basic of the healing spells: a swirling mist forms over the patient and draws out pain, infection or disease, with a 01-60% chance plus 2% per level of the caster to cure sickness or restore injury. It removes pain, restores 2D6 hit points, and leaves the patient healing at twice the normal rate afterwards. Used on a mega-damage being it restores 3D6 M.D.C. instead and costs 45 P.P.E.', NULL),
  ('Clouds of Survival: Globe of Daylight', 0, 2, NULL, 'The Book of Magic p.91 prints the same spell at level 1 for the same 2 P.P.E., with the same range and duration.', 'import', 'Rifts World Book 14: New West p.43', 'rifts', 'Near self or up to 30 feet (9.1 m) away.', '12 melee rounds (3 minutes) per level of experience.', NULL, 'None', NULL, NULL, 'A globe of true daylight bright enough to light a 12 foot area per level of the creator. Being real daylight it holds vampires just beyond its edge and may frighten nocturnal or subterranean animals. The creator can move it with himself or send it up to 30 feet ahead, at a speed of 12.', NULL),
  ('Clouds of Survival: Hunter''s Instinct', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', 'Self', '30 minutes per level of experience.', NULL, 'None', NULL, NULL, 'Clouds swirl and wolves are heard baying, and the character gains hunting ability: track animals 90%, track humanoids 75%, track by smell 70%, recognize tracks 90%, identify plants and fruits 80%, and climb 80%.', NULL),
  ('Clouds of Survival: See the Invisible', 0, 10, NULL, 'Rifts Ultimate Edition p.199 publishes this as a level 1 invocation for 4 P.P.E.', 'import', 'Rifts World Book 14: New West p.43', 'rifts', '200 feet (91 m)', 'One minute (4 melees) per each level of experience.', NULL, 'None', NULL, NULL, 'The character sees forces, objects and creatures that are invisible by magic or by nature, including ghosts, entities, elementals and the astral body, discerning even a formless being as a vaporous shape or sphere of energy.', 'See the Invisible'),
  ('Clouds of Survival: See the Light', 0, 10, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', 'Self or one other by touch.', '10 minutes per level of the spell caster.', NULL, 'None', NULL, NULL, 'The recipient sees every spectrum of light including infrared, ultraviolet and heat, giving nightvision to 200 feet per level of experience, and see aura.', NULL),
  ('Clouds of Survival: Tongues', 0, 12, NULL, 'Rifts Ultimate Edition p.211 prints this at level 6 for the same 12 P.P.E. but lasting three minutes per level rather than five.', 'import', 'Rifts World Book 14: New West p.43', 'rifts', 'Self or others by touch.', 'Five minutes per level of experience.', NULL, 'None', NULL, NULL, 'The character understands and speaks every spoken language at 98%, including elemental and alien tongues. Written language is not included.', NULL),
  ('Clouds of Survival: Warmth of the Sun', 0, 12, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', '6 foot (1.8 m) radius or one person by touch.', '30 minutes per level of experience.', NULL, 'None', NULL, NULL, 'A golden sphere the size of an orange hovers three feet above the ground and radiates comfortable heat across its radius. The caster may instead touch one person and wrap them in an invisible blanket of warmth, which lasts twice as long.', NULL),
  ('Clouds of the Mind: Cloud of Insanity', 0, 30, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', '20 feet (6 m) +10 feet per level.', 'One minute per level', NULL, '16 or better but bonuses to save vs insanity may be added.', NULL, NULL, 'A victim who fails to save loses his grip on the real world - equipment seems to melt in his hands, he feels himself spinning out of control and he hears voices. He is completely incapacitated for the duration.', NULL),
  ('Clouds of the Mind: Clouds of Truth', 0, 12, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', 'One individual up to 10 feet (3 m) away.', 'One minute per level', NULL, '16 or better', NULL, NULL, 'A wispy white cloud encircles the subject and turns grey whenever he lies.', NULL),
  ('Clouds of the Mind: Mind Fog', 0, 24, NULL, NULL, 'import', 'Rifts World Book 14: New West p.43', 'rifts', '10 feet (3 m) +2 feet (0.6 m) per subsequent level of experience, or by touch.', 'One minute per level of the spell caster.', NULL, '16 or better but bonuses vs illusions can be added in.', NULL, NULL, 'The victim forgets whatever matters most to him, struggles to remember anything about the caster and is confused, at -1 on initiative and -20% on all skills. Memory and skill are fully restored when the magic ends.', NULL),
  ('Clouds of the Mind: Mind Over Matter', 0, 22, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Self or other up to 20 feet (6 m) away; line of sight.', 'One melee round (15 seconds) per level of the caster.', NULL, 'None', NULL, NULL, 'The recipient''s eyes flash like lightning and he fights past his physical limits: lifting five times his usual weight, carrying three times as much, holding his breath three times as long, ignoring his own injury to help others so that hit points can go twice as far below zero, and becoming impervious to horror factor, possession and mind control.', NULL),
  ('Clouds of the Mind: Mist of Illusion', 0, 24, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', '100 feet (30.5 m) +10 feet (3 m) per subsequent level of experience.', 'One melee round per level of the spell caster.', NULL, '16 or better but bonuses vs illusions can be added in.', NULL, NULL, 'The sky turns black and an ominous green mist rises, full of shapes, noises and movement while the real surroundings are unchanged. Everyone affected is -4 on initiative, at half combat bonuses and -4 to save vs horror factor. The illusion has a horror factor of 10, rising by 1 for every melee round a character remains trapped, rolled again at the start of each round; a failed roll costs two melee actions or sends the character fleeing, and he must run 300 yards to seem to escape it.', NULL),
  ('Clouds of the Mind: Spirit Mist', 0, 15, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Within eyesight.', 'One melee per level of the caster.', NULL, '16 or better.', NULL, NULL, 'A mist fills a 30 foot radius and gives visible shape to every entity, astral being and similar spirit within it, revealing where they are and how they move. It also tells the caster each creature''s alignment and general intent.', NULL),
  ('Clouds of the Mind: Warrior''s Mist', 0, 20, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Self or one person by touch.', 'One minute per level.', NULL, 'None', NULL, NULL, 'A dark mist masks the recipient''s features and creates a shifting image of someone larger, more muscular and dull-eyed. Everyone who sees him believes he is stronger, more dangerous and 1D4+1 levels higher than he really is.', NULL),
  ('Clouds of Creation: Cloudweaving', 0, 100, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Line of sight no farther than 500 feet (152 m), but the spell caster must actually be inside the cloud to shape it.', '12 hours per level of the spell caster.', NULL, 'None', 'Radius: 400 feet (122 m) +100 feet (30.5 m) per level.', NULL, 'The caster moves real clouds, joins them together and moulds them into large, simple geometric shapes, and can cut tunnels or holes through them. The magic holds the shape but does not make the cloud solid; anything can still fly through it.', NULL),
  ('Clouds of Creation: Cloud Castles', 0, 250, '250 for the normal duration; 1000 makes the castle semi-permanent, one year per level of the caster.', NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Line of sight no farther than 500 feet (152 m), but the spell caster must actually be inside the cloud to shape it.', 'One day per level of the spell caster.', NULL, 'None', 'Radius: 400 feet (122 m) +50 feet (15.2 m) per level of experience.', NULL, 'The caster sculpts real clouds into architecture - walls, floors, windows, cathedral ceilings, corridors, tunnels, mazes - and makes them solid enough to stand and walk on, producing genuine floating castles. Three of them float above the Grand Canyon near the Golden City.', NULL),
  ('Clouds of Creation: Create Cloud Figures', 0, 50, NULL, NULL, 'import', 'Rifts World Book 14: New West p.44', 'rifts', 'Up to two miles in the air (3.2 m)', '10 minutes per level of experience.', NULL, 'None', NULL, NULL, 'The caster mentally sculpts a real cloud into a recognisable figure, animal, structure or symbol, which holds its shape until the magic ends or is cancelled. Fine detail is not possible.', NULL),
  ('Clouds of Creation: Create Water', 0, 10, NULL, 'Rifts Book of Magic p.111 prints this at level 6 for 15 P.P.E., reaching 10 feet and conjuring half a gallon per level rather than reaching 6 feet with a one gallon maximum.', 'import', 'Rifts World Book 14: New West p.44', 'rifts', '6 feet (1.8m)', 'Permanent', NULL, 'None', NULL, NULL, 'A mist comes down from the heavens, fills a container the caster directs it to, and turns into fresh drinking water. The container may hold at most one gallon.', NULL),
  ('Clouds of Creation: Flying Chariot', 0, 80, NULL, NULL, 'import', 'Rifts World Book 14: New West p.45', 'rifts', '10 feet (12.2 m); can only be used by the spell caster.', '15 minutes per level of experience.', NULL, 'None', NULL, NULL, 'A chariot of cloud-stuff appears, carrying up to four people and worth 80 M.D.C.; destroying that destroys the chariot. It flies under its own power at 200 mph, directed mentally by the caster, and is a favourite Lyn-Srial way of carrying passengers who cannot fly.', NULL),
  ('Clouds of Creation: Food from the Heavens', 0, 80, NULL, NULL, 'import', 'Rifts World Book 14: New West p.45', 'rifts', '10 feet (2 m)', 'Permanent', NULL, 'None', NULL, NULL, 'The caster creates manna from the heavens - a light, tasty bread carrying the nourishment and vitamins of a complete meal. Up to 10 pounds can be created per level of experience.', NULL),
  ('Clouds of Creation: Globe of Daylight', 0, 2, NULL, NULL, 'import', 'Rifts World Book 14: New West p.45', 'rifts', 'Near self or up to 30 feet (9.1 m) away.', '12 melee rounds (3 minutes) per level of experience.', NULL, 'None', NULL, NULL, 'A globe of true daylight bright enough to light a 12 foot area per level of the creator. Being real daylight it holds vampires just beyond its edge and may frighten nocturnal or subterranean animals. The creator can move it with himself or send it up to 30 feet ahead, at a speed of 12.', 'Clouds of Survival: Globe of Daylight'),
  ('Clouds of Creation: Paint the Sky', 0, 200, NULL, NULL, 'import', 'Rifts World Book 14: New West p.45', 'rifts', 'The sky', 'Six hours per level of the spell caster.', NULL, 'None', 'Radius: 3000 feet (914 m) +500 feet (152 m) per level of experience.', NULL, 'The caster colours the clouds or the sky itself in streaks of yellow, orange, red, pink, violet, purple and even green. The results are usually artistic and awe-inspiring, and leave onlookers feeling good.', NULL);

-- Read the 58 back, grouped as the book groups them.
SELECT
  substr(name, 1, instr(name, ':') - 1) AS category,
  COUNT(*) AS rows_in_category
FROM spells
WHERE source_book LIKE 'Rifts World Book 14: New West%'
GROUP BY category
ORDER BY category;
SELECT COUNT(*) AS total_spells FROM spells;

-- Records this run.
INSERT INTO data_script_runs (filename) VALUES ('add-new-west-cloud-magic.sql');
