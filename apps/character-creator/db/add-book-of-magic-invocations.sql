-- The Book of Magic's Invocations - every one the catalog did not have.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-book-of-magic-invocations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-book-of-magic-invocations.sql
--
-- Read out of Rifts Book of Magic pp.92-161 with the app's own spell importer,
-- one request per LEVEL SECTION, then reviewed before any of it landed.
-- Applied as a script rather than through the import UI because production sits
-- behind Cloudflare Access.
--
-- 108 spells: level 2: 4, level 3: 4, level 4: 8, level 5: 7, level 6: 13, level 7: 5, level 8: 8, level 9: 7, level 10: 10, level 11: 7, level 12: 12, level 13: 7, level 15: 16.
--
-- THE LEVEL COMES FROM THE INDEX, NOT THE PAGE. The book prints a spell's level
-- only in the section heading it sits under, so the level was supplied per
-- batch rather than inferred. That was necessary and NOT sufficient: the
-- "Level N" headings sit PARTWAY DOWN a page, so the first page of every batch
-- still carries the tail of the previous level. Thirteen rows came back exactly
-- one level too high - Sonic Blast, Wards, Wall of the Weird and ten others -
-- and every one of them looked completely ordinary. They were corrected against
-- the master by-level index (pp.89-92), which states each spell's level in one
-- place independent of where its description falls.
--
-- Two independent readings agree on every row: the cost in each spell's own
-- stat block, and the cost the index prints beside the name. 108 of 108 match.
--
-- Parsing that index correctly took three passes, and the first two were
-- quietly wrong:
--   * Read as a linear text stream it puts Blinding Flash and Globe of Daylight
--     - both level one - under level three, and returns levels one and two
--     EMPTY. It is set in three columns and the stream does not follow them.
--     Reading it geometrically fixes that.
--   * A name pattern allowing only letters silently dropped every
--     "Summon & Control ..." entry and every name carrying its own parenthetical
--     like "Doppleganger (Superior) (1,000)".
--   * A cost pattern strict enough to reject junk also rejected "(l)" - an
--     OCR'd 1 - and "(400 to 1000+)" and "(1,600 or Special)".
-- The finished index holds 311 entries and every staged row matched one.
--
-- Rift Teleportation is the clearest case of the page-straddle problem: its
-- stat block starts on p143 and its "P.P.E.: Two Hundred" line falls on p144,
-- so the Level Twelve batch saw only the tail and produced a second row under a
-- conflated name, at the wrong level, costing nothing. The catalog already has
-- that spell; the bad row is not here.
--
-- Spells of Legend sit above the fifteen levels and are recorded as level 15
-- carrying a note that says so - the convention Hivemind and Ley Line
-- Resurrection already follow. Which spells those are comes from the index, not
-- from the page range: Void and Enchant Weapon are printed among those pages
-- but the index lists them at level 15.
--
-- Descriptions are not written here. The earlier Book of Magic script records
-- stat-block fields only; backfill-spell-descriptions.sql is the separate path
-- for prose.
--
-- INSERT OR IGNORE on a UNIQUE name: re-running this adds nothing, and it
-- cannot overwrite a row that already exists.

INSERT OR IGNORE INTO spells
  (name, level, ppe, ppe_note, range, duration, damage, saving_throw,
   area_of_effect, casting_time, system, source_book, source)
VALUES
  ('Aura of Power', 2, 4, NULL, 'Self or one other by touch.', 'One minute per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mystic Alarm', 2, 5, NULL, '12 feet (3.65 m; one object).', 'One year per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Shatter', 2, 5, NULL, '20 feet (6 m) or by touch.', 'Instant.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Throwing Stones', 2, 5, NULL, '200 feet (61 m) + 100 feet (30.5 m) per level of experience. Self only.', 'Two melee rounds.', '1D6 M.D. + 1 M.D. point per level of experience.', 'Dodge.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Wood', 3, 10, '10 for soft wood, 20 for hard wood', '10 feet (3 m).', 'Permanent.', NULL, 'Not applicable.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Light Target', 3, 6, NULL, 'One target up to 10 feet (3 m) away or two by touch.', 'Two minutes per level of the spell caster.', NULL, 'Standard.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Orb of Cold', 3, 6, NULL, 'Throw: 200 feet (61 m).', 'One melee round (15 seconds); 1D4 minutes for numbness.', '3D6 M.D. plus numbness penalties.', 'Dodge; standard.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Telekinesis', 3, 8, NULL, '60 feet (18.3 m).', 'One minute (4 melee rounds) per level of experience.', NULL, 'Dodge.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Chromatic Protection', 4, 10, NULL, 'Self or touch to cast the magic; 10 foot (3 m) range for the protective light against attacking enemies', 'The protection magic remains in effect for one minute (4 melees) per level of the spell caster and will automatically activate against each and every attacker within its 10 foot (3 m) radius of influence; victim is blind for 1D4 melee rounds', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Deflect', 4, 10, NULL, 'Self', 'One melee "action" per level of experience. Thus, a 3rd level mage can try three magical deflections, a 6th level mage six deflections. Each attempt to deflect counts as one of the spell caster''s melee attacks/actions. If the mage chooses to take some action other than Deflect, he loses that Deflect option. Thus, if five Deflect actions were left and the mage throws a punch, he loses one Deflect, leaving him with four. Each action taken after the Deflect spell is cast uses up one available Deflect action', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Fireblast', 4, 8, NULL, '50 feet (15.2 m)', 'Instant', '3D6 M.D.', 'Dodge', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Reflection', 4, 7, NULL, 'Up to 20 feet (6.1 m) away', 'Two minutes (8 melee rounds) per level of experience', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ricochet Strike', 4, 12, NULL, 'Varies with the type of weapon - must be a physical weapon, such as a knife, throwing axe, spear, arrow, or stone. Not applicable to missiles, rail guns, machine-guns or any "burst" weapons, nor energy blasts', 'One melee round (15 seconds)', 'Normal for the weapon used', 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Seal', 4, 7, NULL, '100 feet (30.5 m)', 'Two minutes (8 melees) per level of experience', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Watchguard', 4, 10, NULL, 'Six foot (1.2 m) radius per level of experience', 'One hour per level of experience', NULL, 'Special; -5 to save', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Weight of Duty', 4, 10, NULL, 'One victim up to 200 feet (61 m) distant or two by touch', 'One minute (4 melee rounds) per level of the spell caster', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Aura of Death', 5, 12, NULL, 'Self.', 'Two melee rounds per level of the spell caster.', NULL, 'Not applicable.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Death Curse', 5, 0, 'None/Special', '100 miles (160 km) per level of experience. Unlimited for Shifters and Temporal Raiders who can even transmit the curse to other dimensions.', 'Potentially permanent.', 'Special.', 'None!', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Horrific Illusion', 5, 10, NULL, '30 feet (9.1 m).', 'Two minutes (8 melees) per level of experience.', NULL, 'Save vs Horror Factor 14.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Instill Knowledge', 5, 15, NULL, 'One person (one skill or bit of knowledge) by touch.', '30 minutes per level of the spell caster.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mend the Broken', 5, 10, 'plus cost of structural repairs', 'Touch.', 'Instant and permanent.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mental Blast', 5, 15, NULL, '100 feet (30.5 m) + 10 feet (3 m) per level of experience, but the intended victim must be visible.', 'Instant, and add 1 melee per level.', '5D6 damage plus disorientation penalties. Double damage by touch, but must actually touch bare skin.', 'Save vs psionic attack.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Swim as a Fish (Superior)', 5, 12, NULL, 'Self or others by touch.', '40 melees/10 minutes per level of spell caster.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Apparition', 6, 20, NULL, '30 feet (9.1 m)', 'One minute (4 melees) per level of experience', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Barrage', 6, 15, NULL, '100 feet (30.5 m) +30 feet (9 m) per level', 'Seven seconds (approximately half a melee round)', 'Two M.D. per each force blast. Unleashes three blasts +1 per level of the spell caster', 'Dodge or parry', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Water', 6, 15, NULL, '10 feet (3 m), line of sight, or touch (of a container)', 'Permanent', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Crushing Fist', 6, 12, NULL, 'Self or 50 feet (15.2 m) per level of experience', 'One minute per level of the spell caster', '2D6 M.D.', 'Dodge', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Energize Spell', 6, 12, 'plus full P.P.E. of original spell', 'Touch or 10 feet (3 m) away', 'Special', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Fire Blossom', 6, 20, NULL, 'Touch; appears above the open palm of the mage''s hand', 'One month per level of the spell caster without burning, but burns out within 1D6 minutes after it is activated to burn', 'Varies', 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Fortify Against Disease', 6, 15, NULL, 'One person up to 100 feet (30.5 m) away, self, or two by touch', 'Two hours per level of experience', NULL, 'Not applicable, unless the character doesn''t want to be fortified (in the latter case, a standard save applies)', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Frequency Jamming', 6, 15, NULL, '100 feet (3 m) per level of experience; line of sight or two machines by touch', 'Two melee rounds (30 seconds) per level of the spell caster''s experience', NULL, 'Not applicable; affects machines', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Frostblade', 6, 15, NULL, 'Close, hand to hand combat', 'One minute per level of experience', '4D6 M.D.', 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ice', 6, 15, NULL, '50 feet (15.2 m) per level of experience', 'Five minutes per level of the spell caster', NULL, 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Illusion Booster', 6, 15, NULL, 'As per illusion; area affect', 'Double that of the original illusion', NULL, 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Illusory Wall', 6, 15, '30 for an elaborate illusion', 'Can be cast up to 500 feet (152 m) away and affects 1,000 square feet (305 m) per level of the spell caster; area affect', '30 minute per level of the spell caster', NULL, '-2 to save', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Targeted Deflection', 6, 15, NULL, 'Effective targeting deflection is 500 feet (152 m) +50 feet (15.2 m) per level of experience. Trying to hit a target beyond this range is -1 to strike per every additional 100 feet (30.5 m). This spell can only be cast on the sorcerer himself.', 'One melee round per level of experience', NULL, 'Dodge', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Fire Gout', 7, 20, NULL, '30 feet (9 m) per level of experience', 'Instant', '6D6 M.D.+1 per level of experience', 'Dodge at -3 to do so', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mental Shock', 7, 30, NULL, '200 feet (61 m) +50 feet (15.2 m) per level of experience', 'Special', NULL, '-1 to save', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Sonic Blast', 7, 25, NULL, '20 foot (6 m) radius', 'Instant', '4D6 M.D.', 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Spinning Blades', 7, 20, NULL, 'Varies', 'One melee round per level of experience or until used up in offensive attacks', '1D6 M.D. per blade', 'Parry (when applicable) and dodge', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Sub-Particle Acceleration', 7, 20, NULL, '100 feet (30 m) per level of experience; line of sight', 'Instant', '1D6x10 +1 M.D. point per level of experience', 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Fire Globe', 8, 40, NULL, 'Touch; appears above the open palm of the mage''s hand. Can be thrown 200 feet (61 m)', 'Stored as a globe for one week per level of the spell caster, but burns out within 1D4 minutes after it is activated', '5D6 M.D. at the moment of impact and 5D6 additional M.D. per melee round', 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Minor Curse', 8, 35, NULL, 'Touch or 10 feet (3 m)', '24 hours per level of experience', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Oracle', 8, 30, NULL, 'Self', 'One minute (4 melees)', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Sorcerous Fury', 8, 70, NULL, 'Self for the Fury, 300 feet (91 m) per level for lightning bolts', 'One minute per level of experience', '2D4x10 M.D. from lightning bolts; 2D6 M.D. per touch', 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Stone to Flesh', 8, 30, NULL, '12 feet (3.6 m)', 'Instant/permanent', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Wall of Wind', 8, 40, NULL, 'Can be cast up to 100 feet (30.5 m) away', 'Five minutes per level of experience', '2D4 M.D.', 'Special', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Winged Flight', 8, 35, NULL, 'Touch (can not be performed on self)', '20 minutes per level of experience', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('World Bizarre', 8, 40, NULL, 'Can be cast up to 200 feet (61 m) away; radius affect', 'One melee round per level of experience', NULL, 'Special', '20 foot (6 m) radius per level of the spell caster', NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Aura of Doom', 9, 40, NULL, 'The spell can be cast on a person up to 200 feet (61 m) away', 'Two minutes per level of the spell caster', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Beat Insurmountable Odds', 9, 70, NULL, 'Self or one other. Can be cast up to 1,000 feet (305 m) away; line of sight', 'One specific action; a few seconds', NULL, 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Illusion Manipulation', 9, 25, '25 for simple visual illusion, 60 for elaborate illusion', 'Can be cast up to 500 feet (152 m) away per level of the spell caster', '30 minutes per level of the spell caster', NULL, '-1 to save against a simple illusion, -4 to save vs an elaborate one', 'Up to 300 square feet (91.5 m) per level of experience', NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Phantom Mount', 9, 45, NULL, '40 feet (12.2 m)', '10 minutes per level of experience', NULL, 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Purge Self', 9, 70, NULL, 'Self', 'Instant', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon & Control Canines', 9, 50, NULL, 'Varies', 'Five hours per level of experience', NULL, 'Standard, but only if a part of the player characters'' group. Wild animals do not get a save, they just come as summoned', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Transferal', 9, 50, NULL, 'Touch or 10 feet (3 m)', 'One hour per level of experience', NULL, 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Armorbane', 10, 100, NULL, '300 feet (91.5 m); line of vision. One target per spell', 'Instant', NULL, 'None, because it attacks an inanimate object', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Deathword', 10, 70, NULL, '30 feet (9 m); clear sound', 'Instant effect', '2D6 + 1D6 points of damage per level of the spell caster', 'Standard to save vs magic (takes damage, but no coma). To survive death, roll to save vs coma. Greater supernatural beings and gods are +3 to save, in addition to likely natural bonuses to save vs magic', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Enemy Mind', 10, 100, NULL, '10 feet (3 m)', 'One minute per level of the spell caster', NULL, '-1 to save', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Giant', 10, 80, NULL, 'Self or one other by touch', 'One melee round per level of experience', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Havoc', 10, 70, NULL, '90 feet (27.4 m); affects a 20 foot (6.1 m) area', 'Two melee rounds (30 seconds) per level of the spell caster', '1D6 points of damage direct to Hit Points even if in environmental armor or power armor (or 2D6 M.D. if a Mega-Damage being) per melee round', 'Standard', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Shadow Beast', 10, 140, NULL, 'Immediate', 'For straight out combat situations: Two minutes (8 melee rounds) per level of experience. Three hours per level of experience to do labor or stays until it has finished its mission or been destroyed', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Super-Healing', 10, 70, NULL, 'One character by touch (cannot be used on oneself)', 'Instant', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Wall of Not', 10, 70, NULL, 'By touch or up to 100 feet (30.5 m) away', 'Five minutes per level of the spell caster', NULL, 'Not applicable', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Wards', 10, 90, NULL, 'Varies with type.', 'Effects vary with type.', NULL, 'Standard; spells are base 12, wards created by ritual magic are 16.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Warped Space', 10, 90, NULL, 'Can be cast a distance of 150 feet (45.7 m) away.', 'One melee round (15 seconds).', 'None per se; varies.', 'None.', '10 foot (3 m) radius per level of experience.', NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Anti-Magic Cloud', 11, 140, NULL, '100 foot (30.5 m) radius per level of the spell caster.', '20 melees per level of the spell caster.', NULL, 'Special. Only a Natural (unmodified) 18, 19 to 20 saves against the cloud, and even these lucky few will find their magic reduced to half strength.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Astral Hole', 11, 120, NULL, 'Self.', 'One melee round (15 seconds) per level of experience.', NULL, 'Not applicable.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Bottomless Pit', 11, 100, NULL, '50 feet (15.2 m). The portal/hole appears to be about four feet (1.2 m) in diameter, per level of the spell caster.', 'Two minutes per level of experience.', NULL, 'Dodge.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Mummy', 11, 160, NULL, 'Touch.', 'Exists until destroyed.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('See in Magic Darkness', 11, 125, NULL, 'Self or two others by touch; line of sight.', 'One minute per level of the spell caster.', NULL, 'Not applicable.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon and Control Animals', 11, 125, NULL, '600 feet (183 m).', 'Five hours per level of experience.', NULL, 'Standard for animals.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Fog', 11, 140, NULL, 'Up to 10 miles (16 km) away per level of experience.', 'One hour per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Amulet', 12, 290, '290 to 500 depending on ability granted', 'Holder/wearer of the amulet.', 'Exists as long as the medallion is not destroyed.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Calm Storms', 12, 200, NULL, 'Immediate area around the mage, affecting a one mile (1.6 km) area per level of experience.', 'One hour per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Zombie', 12, 250, NULL, 'Touch.', 'Exists until destroyed.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ensorcel', 12, 400, NULL, 'Touch.', '20 minutes per level of the spell caster (double if 800 P.P.E. is expended).', NULL, '-3 to save.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Heavy Air', 12, 200, NULL, 'Can be cast up to 100 feet (30.5 m) away per level of experience.', '10 minutes per level of the spell caster.', NULL, '-1; everybody in the area of affect must roll to save vs magic, including animals.', 'Covers a radius of 300 feet (91.4 m) per level of experience.', NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ironwood', 12, 50, 'point-for-point conversion of S.D.C. to P.P.E., 50 minimum', 'Touch.', 'Permanent.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Metamorphosis: Mist', 12, 250, NULL, 'Self; or others through ritual magic.', '20 minutes per level of experience.', NULL, 'None; standard if an unwilling subject.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Null Sphere', 12, 220, NULL, '10 foot (3 m) radius per level of experience.', '5 minutes per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Soultwist', 12, 170, NULL, '100 feet (30.5 m); line of sight or touch.', 'Doubt and temptation for a minimum of 3D4 weeks; physical damage is instant.', '6D6 M.D. or Hit Points, as is appropriate.', '-6 to save. A successful save means no physical damage and only minor doubt and temptation, reevaluation.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon and Control Entity', 12, 250, NULL, 'Not applicable.', '24 hours per level of experience.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon and Control Rain', 12, 200, NULL, 'Immediate area around the mage or up to 10 miles (16 km) away per level of experience.', 'One hour per level of experience.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Wall of the Weird', 12, 180, NULL, 'The wall can be cast up to 200 feet (61 m) away.', 'Five minutes per level of experience.', '4D6 M.D. or entanglement/capture.', 'Dodge or parry.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Collapse', 13, 70, '70 to 400 depending on structure size/type', '100 feet (30.5 m) + 10 feet (3 m) per level of experience.', '1D4+1 melee rounds delayed reaction (30-75 seconds).', 'Special; described below.', 'Special.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Golem', 13, 700, '700 for Stone, 1000 for Iron', 'Touch.', 'Exists until destroyed.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Sanctum', 13, 390, NULL, '30x30 feet (9.1 x 9.1 m) room; can be created up to 200 miles (320 km) away.', 'The lifetime of the mage or until canceled.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Shadow Wall', 13, 400, NULL, 'Can be cast 100 feet (30.5 m) away per level of experience.', 'Five minutes per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon and Control Storm', 13, 300, NULL, 'Immediate area around the mage or up to 10 miles (16 km) away.', 'One hour per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Lesser Being', 13, 425, NULL, 'Not applicable.', '24 hours per level of experience.', NULL, 'None.', NULL, 'Ritual', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Swap Places', 13, 300, NULL, '50 feet (15.2 m) per level of experience; line of sight. Self or one other person by touch.', 'One minute per level of experience.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Barrier of Thoth', 15, 3000, 'A Spell of Legend, beyond the fifteen levels', 'Can be cast up to 50 feet (15.2 m) per level of the spell caster and creates a length of wall/force barrier that is 75x75 feet (22.9 x 22.9 m) per level of the spell caster', 'Four minutes per level of the spell caster', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Blight of Ages', 15, 600, 'A Spell of Legend, beyond the fifteen levels', '100 foot (30.5 m) radius per level of the spell caster, initially. Once the spell is cast, the radius of effect expands by another 100 feet (30.5 m) per level of the spell caster, per melee round', 'One minute (four melees) per level of the spell caster', 'All plants within this spell''s area of effect will wither and die instantly. Plant-like creatures, or magical plants will take 1D4x10 M.D. per melee round (15 seconds) of exposure', 'None for most lower forms of plant life (i.e. lichen, moss, and fungus) and simple vegetation like grass, flowering plants, crop plants, and similar. Trees get a standard saving throw - those who save are unaffected. This magic does not affect processed foods', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Blood and Thunder', 15, 770, 'A Spell of Legend, beyond the fifteen levels', '100 feet (30.5 m) per level of experience of the caster', 'One minute (four melees) per level of experience', '2D4x10 M.D. or by spell', 'None for willing participants, +2 for those who resist the spell''s effects', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Circle of Travel (Ritual)', 15, 600, '300 per circle, +30 to reactivate', '800 miles (1280 km) per level of experience.', 'Indefinite, as long as both circles exist undamaged and the user has sufficient P.P.E. to activate it.', NULL, 'Not applicable.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Crimson Wall of Lictalon', 15, 6000, 'A Spell of Legend, beyond the fifteen levels', '50x50x25 feet deep (15.2 x 15.2 x 7.6 m) per level of the spell caster', 'Five minutes per level of the spell caster', NULL, 'Save vs Horror Factor 18, and save vs magic 16', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Doppleganger (Superior)', 15, 1000, 'A Spell of Legend, beyond the fifteen levels', 'Self', 'One year per level of the spell caster, plus a 5% chance per each year that the doppleganger exists that it will remain permanently', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Enchant Weapon (Minor)', 15, 400, '400 for temporary, 1000 for permanent', 'Touch.', 'One month per level of experience, or permanent.', NULL, 'None.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Metropolis', 15, 1600, 'or 7,600 + 1 P.E. point to make permanent; A Spell of Legend, beyond the fifteen levels', '200 foot (61 m) radius per level of experience (double at ley lines)', 'One day (24 hours) per level of experience', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mystic Quake', 15, 420, 'half for Ley Line Walkers and Shifters on a ley line; A Spell of Legend, beyond the fifteen levels', 'Can be cast up to 1,000 feet (305 m) away, double at ley lines', 'One minute per level of experience, triple at ley lines', 'Special, see description', 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Sanctuary', 15, 1500, 'A Spell of Legend, beyond the fifteen levels', '50 foot (15.2 m) radius per level of the spell caster', '1D6 hours per level of the spell caster', NULL, 'None', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Steel Rain', 15, 360, 'half for Line Walkers and Shifters when cast on a ley line; A Spell of Legend, beyond the fifteen levels', '100 feet (30.5 m) per level of experience', 'Steel Rain: One minute (four melees) per level of experience. Torrent of Steel Rain: five seconds', 'Steel Rain: 3D6 M.D. per melee round (15 seconds) to everybody in the affected area. 3D6x10 M.D. from a narrowly focused "torrent" (6D6x10 at a ley line or nexus)', 'None; must move out of the area of effect or take cover under M.D.C. protective shielding. A "torrent" can be dodged with a penalty of -2', 'Small blades fall from the sky, affecting a 50 foot (15.2 m) diameter area per level of the spell caster''s experience. Alternatively, a narrowly focused ''torrent'' can strike one target or narrow area', NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('The Slowness', 15, 1300, 'half for Temporal Raiders; A Spell of Legend, beyond the fifteen levels', '100 feet (30.5 m) per level of experience (double on ley lines); affects up to a 30 foot (9 m) diameter per level of experience', 'One melee round (15 seconds) +5 seconds per level of experience (double on ley lines)', NULL, '-8 to save. Those who successfully save continue to move and can take action but do so in slow motion', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Transformation (Ritual)', 15, 2000, NULL, 'Touch.', 'Three days per level of experience.', NULL, 'Standard (minus) -3 to save.', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Vicious Circle', 15, 350, 'A Spell of Legend, beyond the fifteen levels', '300 foot (91.5 m) diameter, plus 100 feet (30.5 m) per level of experience', 'One minute (four melee rounds) per level of experience', '1D4x10 M.D. per level of experience of the spell caster per melee, or Agony, as described', '-3 to save vs magic', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Void', 15, 700, NULL, '200 feet (61 m) or one person by touch', 'One week per level of experience', NULL, 'Standard, but at -2', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Warrior Horde', 15, 1100, 'A Spell of Legend, beyond the fifteen levels', '100 feet (30.5 m); triple at ley lines', 'Two melee rounds per level of the spell caster; triple the duration if cast at a ley line or nexus', NULL, 'Those under attack by a Warrior Horde can battle them as they would any foe. Those caught off guard by their sudden appearance or heavily outnumbered may be forced to flee or hide', NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS book_of_magic_invocations
  FROM spells WHERE source_book = 'Rifts Book of Magic';
SELECT level, count(*) AS n
  FROM spells WHERE source_book = 'Rifts Book of Magic' GROUP BY level ORDER BY level;
SELECT count(*) AS spells_of_legend
  FROM spells WHERE ppe_note LIKE '%Spell of Legend%';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-book-of-magic-invocations.sql');
