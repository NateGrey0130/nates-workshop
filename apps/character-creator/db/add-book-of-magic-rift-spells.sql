-- Spells the Shifter and Ley Line Rifter name that the catalog never had.
--
-- Read out of Rifts Book of Magic with the app's own spell importer, in three
-- batches of eight pages, then staged and reviewed before any of it landed.
-- Applied here as a script rather than confirmed through the import UI because
-- production sits behind Cloudflare Access - the same reason the class
-- corrections go in this way.
--
-- THE LEVEL DOES NOT COME FROM THE DESCRIPTION. The book prints a spell's level
-- only in the section it is listed under, so slicing description pages returned
-- level 0 for 69 of these. The book's master by-level index (pp. 89-92) is its
-- own answer to that question and is where every level below comes from; a
-- spell that index could not place is not here at all.
--
-- Two independent readings agreed on the costs, which is the reason to trust
-- them: each spell's own stat block, and the cost the index prints beside the
-- name. Where the Shifter's CLASS page disagreed - Influence the Beast at 20
-- against 12, Tame Beast at 30 against 60 - the description and the index agree
-- with each other, so the class page is the outlier and the stat block wins.
--
-- Spells of Legend are recorded as level 15 with a note. They sit above the
-- fifteen levels, and inventing a sixteenth to hold them would be inventing a
-- rule.
--
-- INSERT OR IGNORE on a UNIQUE name: re-running this adds nothing, and it
-- cannot overwrite a row that already exists.

INSERT OR IGNORE INTO spells
  (name, level, ppe, ppe_note, range, duration, damage, saving_throw, system, source_book, source)
VALUES
  ('Wave of Frost', 3, 6, NULL, '200 feet (61 m) +20 feet (6 m) per level of experience', 'One minute (4 melee rounds) per level of experience', 'Special', 'Special', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Astral Projection', 4, 10, NULL, 'Self', 'Five minutes per level of experience', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Horror', 5, 10, NULL, NULL, NULL, NULL, 'Standard; and vs Horror Factor', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Implosion Neutralizer', 5, 12, NULL, 'Can be cast on one explosive item up to 50 feet (15.2 m) away per level of experience, or two by touch', 'Special; varies', 'Reduced', 'Not applicable', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Influence the Beast', 5, 12, NULL, 'Can be cast up to 30 feet (9 m) away', 'One minute per level of the spell caster', NULL, 'Animals with low intelligence (reptiles, for example) are -2 to save, but predators and animals with high intelligence are +2 to save', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Memory Bank', 6, 12, NULL, 'One other by touch', 'Three months per level of experience', NULL, 'None if willing; standard if unwilling', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Power Bolt', 6, 20, NULL, '1,600 feet (487 m) +100 feet (30.5 m) per level of experience', 'Instant', '5D6 M.D. +2 per level of the spell caster', 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Invulnerability', 7, 25, NULL, 'Self or one other by touch', 'One melee (15 seconds) per level of experience', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Fade', 7, 20, 'half for Ley Line Walkers and Shifters', 'Self and as many as two others by touch', '10 minutes per level of the spell caster', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Negate Mechanics', 7, 20, NULL, 'One target mechanism up to 100 feet (30 m) away or two by touch', 'One melee round (15 seconds)', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Second Sight', 7, 20, NULL, '5 miles (8 km) per level of experience', 'Two melees (30 seconds)', NULL, 'None; Mind Block will temporarily prevent the use of Second Sight', 'rifts', 'Rifts Book of Magic', 'import'),
  ('See Wards', 7, 20, NULL, '90 feet (27.4 m)', 'Four minutes per level of the spell caster', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Hallucination', 8, 30, NULL, 'Touch, or 3 feet (0.9 m)', 'Three minutes (12 melees) per level of experience', NULL, 'Standard', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Invincible Armor', 8, 30, NULL, 'Self or one other by touch', 'Three minutes per level of the spell caster', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Time Capsule', 8, 15, '8 for Line Walker/Shifter on a ley line; 30 off a ley line', 'Touch', 'Up to 50 years per level of experience', NULL, 'Not applicable', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Lifeward', 8, 40, NULL, 'Self or one character by touch', 'Special delayed reaction. The spell is not activated until the enchanted and marked outer armor is destroyed. Then it activates and lasts one minute per level of the spell caster', NULL, 'Not applicable', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Steel', 9, 68, 'half for Earth Warlocks with this spell', 'Can be cast up to 10 feet (3 m) away', 'Permanent', NULL, 'Not applicable', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Curse: Phobia', 9, 40, NULL, 'Touch or 20 feet (6.1 m)', '24 hours per level of experience', NULL, 'Standard', 'rifts', 'Rifts Book of Magic', 'import'),
  ('D-Step', 9, 50, NULL, 'Three feet (0.9 m)', 'One melee round per level of experience', NULL, 'None', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Phantom', 9, 40, NULL, 'Self only.', 'Five minutes per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Time Flux', 9, 80, NULL, 'Self and one other per level of experience.', 'To slow or increase the seeming passage of time: Five minutes per level of the spell caster. To leap ahead in time, the effect takes only 15 seconds (one melee round), but the character(s) can leap forward up to 12 hours per level of experience (double for Temporal Raiders and Temporal Wizards).', NULL, 'Standard for those who do not wish to be affected by this spell.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Metamorphosis: Insect', 9, 60, NULL, 'Self, or others through ritual magic.', '20 minutes per level of experience.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Realm of Chaos', 9, 0, NULL, NULL, NULL, NULL, NULL, 'rifts', 'Rifts Book of Magic', 'import'),
  ('Swords to Snakes', 9, 50, NULL, '60 feet (18.3 m).', 'Two melees per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Tame Beast', 9, 60, NULL, 'Can be cast up to 10 feet (3 m) away.', 'Takes 1D4 hours of attention, touch commands and training, with permanent results.', NULL, 'Standard.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Illusory Forest', 10, 45, '45 simple, 90 elaborate', NULL, '30 minutes per level of the spell caster.', NULL, '-1 to save against a simple illusion, -4 to save vs an elaborate one (only -3 if an alien looking forest).', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Ghost', 10, 80, '80 self, 240 to preserve another', 'Self or one other by touch at the moment of death.', '24 hours per level of the deceased.', NULL, 'Standard, but only if the dying character resists the magic, none if cast upon oneself or a willing participant.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Magic Warrior', 10, 60, NULL, '100 feet (30.5 m).', 'Two melee rounds (30 seconds) per level of experience.', NULL, 'Special "disbelieve" option.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Metamorphosis: Superior', 10, 100, NULL, 'Self, or one other by use of ritual only.', '20 minutes per level of experience.', NULL, 'None; standard if an unwilling victim.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Meteor', 10, 75, NULL, '200 feet (61 m) per level of experience.', 'Instant.', '1D6x10 M.D. to a 40 foot (12.2 m) radius, +2 M.D. per level of the spell caster''s experience!', 'Dodge if victims see it coming.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mystic Portal', 10, 60, NULL, '20 feet (6.1 m) away.', 'Four melee rounds per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Plane Skip', 10, 65, NULL, 'Self and one other by touch.', 'Instant.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Purge Other', 10, 100, NULL, 'One character by touch.', 'Instant.', NULL, 'None if the treatment is wanted, but +8 to save if the character refuses treatment.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Reality Flux', 10, 75, NULL, 'One weapon up to 60 feet (18.3 m) away, or two by touch.', 'One melee round (15 seconds) per level of the spell caster.', NULL, 'Not applicable to most, except for Rune and Bio-Wizard weapons, and any magical device that contains a living being inside it; they get to make a standard save vs magic.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Restore Limb', 10, 80, NULL, 'Touch.', 'Permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Speed Weapon', 10, 100, NULL, 'Touch.', 'One melee round per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Greater Familiar', 10, 80, NULL, 'Immediate area.', 'Special.', NULL, 'Special: battle of wills.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Create Magic Scroll', 11, 100, 'plus the P.P.E. needed to cast the spell placed on the scroll', 'Identical to spell placed on scroll.', 'As per scroll.', NULL, 'Standard magic save; 12 or higher.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Curse of the World Bizarre', 11, 100, NULL, '50 feet/15.2 m (line of sight) or by touch.', '1D4 days per level of the spell caster.', NULL, '-1 to save.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Disharmonize', 11, 150, NULL, 'The spell can be cast up to 1000 feet (305 m) away.', 'Five minutes per level of experience.', NULL, 'Standard.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Energy Sphere', 11, 120, NULL, '100 feet (30.5 m).', 'Two days per level of experience, or until used up.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Firequake', 11, 160, '80 for Earth Warlocks', 'Up to 500 feet (152 m) away.', 'One melee round per level of experience.', 'Varies, see description; 5D6 M.D. from flame jets, triple for large vehicles/giant robots.', 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Id Alter Ego', 11, 130, '+200 for an additional hour duration', 'Self or other up to 60 feet (18.3 m) away.', 'Three minutes per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Illusory Terrain', 11, 55, '55 simple, 120 elaborate', 'Can be cast up to 500 (152 m) away and affects 3,000x3,000 foot (914x914 m) area per level of the spell caster; area affect.', '30 minutes per level of the spell caster.', NULL, '-1 to save against a simple illusion, -4 to save vs an elaborate one (only -3 if an alien looking terrain).', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Storm Defense', 11, 180, NULL, '10 foot (3 m) diameter per level of the spell caster, x10 if performed at a ley line nexus, x100 if a triangle of connecting ley lines is involved.', '10 minutes per level of the spell caster, x10 if performed at a ley line nexus, x100 if done at a nexus that is part of a triangular conjunction of ley lines.', NULL, 'Not applicable.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Mindshatter', 11, 130, NULL, 'Touch.', 'Special; 24 hours minimum.', NULL, '-2 to save against the initial mental attack, standard every 24 hours thereafter.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Remove Curse', 11, 140, NULL, 'Touch or 10 feet (3 m).', 'Instant removal.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Rift to Limbo', 11, 160, NULL, 'Must be performed at a nexus point.', 'Limbo: One hour per level of the spell caster. May be set to automatically reopen at a specific, predetermined time, or upon the command of its creator.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Rift Teleportation', 11, 200, NULL, 'Up to 100 miles (160 km) per level of the spell caster.', 'Roughly 1D4+4 seconds/half a melee round.', NULL, '+3 to save if an unwilling participant of this magic.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Ley Line Storm', 12, 500, 'half for Shifters; Nazcan Line Magic 800', 'One mile (1.6 km) per level of experience.', 'Five minutes per level of the spell caster.', NULL, 'Standard per the effects of the storm.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Swallowing Rift', 12, 300, 'half for Shifters', 'Opens at a ley line nexus, but affects a one mile (1.6 km) radius around the portal, triple if part of a triangular ley line grid.', 'One melee round (15 seconds) per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Time Hole', 12, 210, NULL, 'Self.', 'Special.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Protection Circle: Superior', 13, 300, '20 to reactivate', 'Radius of the circle.', '24 hours; but can be reactivated immediately at a cost of 20 P.P.E.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Restore Life', 13, 275, NULL, 'Touch.', 'Permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Talisman', 13, 500, NULL, 'Varies with type of spell.', 'Talisman exists until destroyed.', NULL, 'Standard.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Annihilate', 14, 300, '600 normally; 300 for Shifters, Conjurers, Temporal Raiders, Temporal Wizards', '500 feet (152 m) + 100 feet (30.5 m) per level of experience.', 'Instant.', 'Special.', 'Dodge.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Close Rift', 14, 200, 'plus 2 permanent P.P.E. from base', '100 feet (30.5 m).', 'Instant results.', NULL, 'Standard.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Id Barrier', 14, 600, NULL, 'Up to 200 feet (61 m) away, plus 100 feet (30.5 m) per each additional level of experience.', 'Three minutes (12 melees) per level of experience.', NULL, 'Standard and vs Horror Factor.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Impenetrable Wall of Force', 14, 600, NULL, '100 feet (30.5 m).', 'Five melee rounds per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Restoration', 14, 750, NULL, 'Touch or 3 feet (0.9 m) away.', 'Instant/permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Resurrection', 14, 650, NULL, 'Touch or six feet (1.8 m) away.', 'Instant and permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Rift Triangular Defense System', 14, 840, 'half for Shifters', 'Only where three ley lines crisscross to create a triangle of magic power, and even then only the area within the triangle is protected.', 'One minute (four melee rounds) per level of the spell caster.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon & Control Sea Serpents', 14, 300, NULL, '6,000 feet (1,828 m).', '12 hours per level of experience.', NULL, 'Standard.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Circle of Travel', 15, 600, '300 per circle, plus 30 to reactivate', '800 miles (1280 km) per level of experience.', 'Indefinite, as long as both circles exist undamaged and the user has sufficient P.P.E. to activate it.', NULL, 'Not applicable.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Dimensional Teleport', 15, 800, NULL, 'Another dimension.', 'Instant.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Restoration', 15, 800, 'half for Ley Line Walkers and Shifters', 'One individual via ritual, within 10 feet (3 m). Can not be performed on oneself.', 'The ritual takes 20 minutes, the restoration is permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Shutdown', 15, 3000, NULL, 'Length of the ley line; does not affect connecting lines unless performed at a nexus, then all connecting lines are shutdown but for half the usual duration.', 'One melee round (15 seconds) per every three levels of experience.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Summon Ally', 15, 600, NULL, '1000 miles (1600 km).', 'Instant teleport, but the ritual takes 20 minutes.', NULL, 'Special; the ally must be willing or this magic will not work on him.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Teleport: Superior', 15, 600, NULL, 'Self or others; distance of 300 miles (480 km) per level of experience.', 'Instant.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Transformation', 15, 2000, NULL, 'Touch.', 'Three days per level of experience.', NULL, 'Standard (minus) -3 to save.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Hivemind', 15, 350, 'A Spell of Legend, beyond the fifteen levels', '200 foot (61 m) radius per level of experience.', '1D4 minutes (four melees per minute) per level of the spell caster.', 'None per se; mind control.', 'None for willing participants. Standard plus any bonuses to save vs mind control and/or psionic (type) attacks.', 'rifts', 'Rifts Book of Magic', 'import'),
  ('Ley Line Resurrection', 15, 2000, 'half for Shifters and Necromancers; A Spell of Legend, beyond the fifteen levels', 'One designated individual within 10 feet (3 m). Can not be performed on oneself.', 'The ritual takes 15 minutes, the resurrection is permanent.', NULL, 'None.', 'rifts', 'Rifts Book of Magic', 'import');

SELECT count(*) AS spells_now FROM spells;
SELECT count(*) AS from_this_import FROM spells WHERE source_book = 'Rifts Book of Magic';

INSERT INTO data_script_runs (filename) VALUES ('add-book-of-magic-rift-spells.sql');
