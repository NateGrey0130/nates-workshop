-- The Ley Line Walker O.C.C., Rifts Ultimate Edition (rifts-core).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-ley-line-walker-class.sql
--
-- FIRST CLASS EXTRACTED BY CLAUDE rather than transcribed by hand: the page
-- images went through /api/character-creator/import/extract and the output was
-- corrected in review (see `extraction_notes` in the markdown). The markdown
-- here is byte-identical to what the local dress rehearsal published through
-- the real confirm endpoint.
--
-- The gear stubs mirror what that confirm created locally: fourteen items the
-- class references that the catalog did not carry. INSERT OR IGNORE, exactly
-- like buildStubStatements(), so re-running or racing an import is harmless.
-- The em-dash in the stub description is built with char(8212) because passing
-- one through `wrangler d1 execute` on Windows has produced mojibake before.
--
-- Pure ASCII on purpose, for the same reason.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('robe-or-cape', 'Robe Or Cape', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('clothing', 'Clothing', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('wooden-stake-and-mallet', 'Wooden Stake And Mallet', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('flashlight', 'Flashlight', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('lightweight-cord', 'Lightweight Cord', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('grappling-hook', 'Grappling Hook', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pen-or-pencil', 'Pen Or Pencil', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('note-or-sketch-pad', 'Note Or Sketch Pad', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hand-axe', 'Hand Axe', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('automatic-pistol', 'Automatic Pistol', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('submachine-gun', 'Submachine Gun', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('energy-pistol', 'Energy Pistol', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('energy-rifle', 'Energy Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('ammunition-clips', 'Ammunition Clips', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('ley-line-walker', 'Ley Line Walker', 'rifts', '---
id: ley-line-walker
name: Ley Line Walker
system: rifts
source_book: rifts-core
category: occ
attribute_requirements: { IQ: 10, PE: 12 }
ppe_base: "3d6x10+20, +3d6 per additional level starting at level two"
starting_money: "1d4x1000"
bonuses:
  saves: { horror_factor: 4, possession: 2, insanity: 2, mind_control: 2 }
  at_level:
    - { level: 3, saves: { curses: 3 } }
    - { level: 9, saves: { curses: 3 } }
    - { level: 11, saves: { curses: 3 } }
    - { level: 14, saves: { curses: 3 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Basic Math", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 40, per_level: 4, note: "+4%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 5, note: "Pilot: one of choice (+5%)" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Lore: Demon & Monster (+15%)" }
    - { choose: 4, categories: ["Technical"], bonus: 10, note: "Lore: four of choice (+10%). The catalog files lore skills under Technical." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if evil alignment) at the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Gymnastics", "Wrestling"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two of the seven must be from Science and one from Technical. Electrical, Mechanical and Military offer none and are omitted. Paramedic counts as two skills. Category bonuses: Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5%."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    note: "Plus one additional Secondary Skill at levels 4, 8 and 12. These get no bonus other than a possible I.Q. bonus."
equipment_starting:
  - { item_id: "robe-or-cape", qty: 1 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "wooden-stake-and-mallet", qty: 6 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "pen-or-pencil", qty: 1 }
  - { item_id: "note-or-sketch-pad", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { choose: 1, label: "automatic pistol or submachine-gun", qty: 1, from: ["automatic-pistol", "submachine-gun"] }
  - { choose: 1, label: "energy pistol or rifle", qty: 1, from: ["energy-pistol", "energy-rifle"] }
  - { item_id: "ammunition-clips", qty: 3 }
natural_abilities:
  - name: "Sense Ley Line"
    description: "The Ley Line Walker can feel whether there is a ley line within the area of his sensing abilities, 10 miles (16 km) per level of experience. He can tell whether it is near or far and follow the feeling to the location of the ley line. Base Skill: 30% +5% per each additional level of experience."
  - name: "Sense Ley Line Nexus"
    description: "Once the ley line has been found, the walker can follow the ley line to as many nexus points as it may have. A nexus point is where two or more ley lines cross/intersect. Base Skill: 40% +5% per each additional level of experience."
  - name: "Sense a Rift"
    description: "The mage will automatically feel the sensation of a Rift opening or closing anywhere within 50 miles (80 km) of him. Increase the sensing range 10 miles (16 km) per each additional level of experience starting with level two. Although he cannot tell exactly where this Rift is, the mage knows if it is near or far and whether it is big or small. Note: When actually on a ley line, the Line Walker will know exactly where the Rift is located and he can sense one wherever it is, as long as it is on the ley line or a connecting line."
  - name: "Sense Magic in Use"
    description: "The expenditure of magic in the form of a spell, Rifting, or Techno-Wizardry can be felt, if not seen, up to 100 feet (30.5 m) away per every level of the Line Walker''s experience. The Line Walker will not know the location nor be able to trace it, but he will feel its energy and know that magic is being used in the area of his sensing range. Note: This does not include the use of psionic powers."
  - name: "See Magic Energy"
    description: "The mage sees magic energy/P.P.E. radiating from people, creatures, objects, and areas, as a faint aura whenever more than 20 P.P.E. points are present. The sensing ability is so acute that the Ley Line Walker can see things made invisible by magic and invisible things that are magical, including invisible dragons and other creatures of magic. This special sight occurs only when the mage desires to use it and focuses on seeing the magically invisible. However, the effort uses up one melee attack/action per round (15 seconds) that this special sight is willed in place. Note: Does not work on the spell, Invisibility Superior. Range: Line of sight, about 1000 feet (305 m)."
  - name: "Read Ley Lines"
    description: "This power instills the mage with instant information about the ley line in a matter of moments. The Ley Line Walker will know the following: what directions the ley line runs (and therefore, his location on it; north, south, east, west, etc.), how long the line runs, whether there are any nexus points and where, and whether there are any Rifts presently open along the line. The character also knows about any major natural disasters currently happening along the line, such as a forest fire, flooding, hurricane, or earthquake. War and magic are not natural disasters. The power is automatic and does not require the expenditure of personal P.P.E."
  - name: "Ley Line Transmission"
    description: "A Ley Line Walker can send a verbal and/or visual message directly along a ley line to another person so long as that person is located somewhere on the line. The best messages are brief ones of under a hundred words to avoid overwhelming the recipient. Unfortunately, the message is a one way transmission unless the other person is also a Line Walker or other mage with the Transmission spell. Range is limited only by the length of the ley line and the people''s position on the line. The time lapse between sending and receiving a ley line transmission is only a matter of seconds. The message can be sent to one specific person or several people (one person per level of the sender''s experience), or several people at different locations on the line. There is a 01-20% chance that a telepathic individual (psionic or magic) may be able to listen in on the message. Any psionic or magic character with Telepathy will sense a Ley Line Transmission coming through, and eavesdrop (01-31% chance) that they too can receive the message). There is no way for the sender to know if others have eavesdropped on his message. Nor is there any way to scramble the message. This power is an automatic ability for the Ley Line Walker and does not require the expenditure of personal P.P.E."
  - name: "Ley Line Phasing (teleportaton)"
    description: "A Ley Line Walker also has the power to instantly teleport from one place to another, FLAWLESSLY anywhere on the same ley line. That can be anywhere in any direction (ley lines can be a quarter/0.4 km to one full mile/1.6 km wide!), including up into the air (ley lines are typically a half mile/0.8 km to two miles/3.2 km tall) and hang there because Line Walkers can walk a ley line, as in walk floating above the ground. If he teleports up into the air he can stay suspended (+20% to Prowl/hide, because us ground dwelling humans don''t usually look up). To do this Ley Line Teleport the mage must concentrate, opening himself to the ley line energy and focusing all of his thoughts to the task of teleporting to the new location. Engaging in conversation or combat, even self-defense, will break the concentration, forcing the mage to start over. The process requires 1D4 melees (15 to 60 seconds) of concentration every time before the teleportation happens, so he can''t just pop out in a heartbeat, but it''s very, very handy. The teleport is always on target, because the Ley Line Walker is one with the ley line. Of course, unless he can see his destination, he can''t know who or what might also be present in that area and he could appear in the middle of an armed camp (but not inside one of them or a tree, etc., as is the danger with the Teleportation spell). Note: Ley Line Phasing is an automatic ability common to all Ley Line Walkers at NO P.P.E. cost, but it does take its toll on the body. The maximum number of phasings/teleports possible is four per hour. The per 24 hour period is 4 +2 per each level of experience (6 at level one, 8 at level two, 10 at level three, etc). More than this is just impossible. The only other limitations are: 1) He can only teleport himself and his possessions, nobody else. 2) The location must be along the same ley line as if traveling on a mystic railway. To switch to a different ley line, the character must travel or teleport to the nexus point intersection where two or more different ley lines cross paths to follow one of the other lines."
  - name: "Ley Line Walking or Line Drifting"
    description: "A Ley Line Walker can open himself to the ley line energies and walk or float through the air along the length of the ley line. The speed factor is a mere Speed of 10, but is relaxing and requires absolutely no exertion or even physical movement of the feet or body if drifting afloat. NO P.P.E. is necessary for Ley Line Walker to do this, because he''s drawing on the ambient energy of the line and his attunement to ley line energy make him practically a living part of the line itself. Note: He can even meditate while drifting down a ley line. Height is typically 1-5 feet (0.3 to 1.5 m) above the ground, but if he concentrates he can reach a height as great as the line itself. This is dangerous, however, as it leaves him out in the open easy to see from a great distance. Just below or just above treetop level is common among those who like to be high above the ground."
  - name: "Ley Line Rejuvenation"
    description: "The character can absorb ley line energy to double the rate of natural healing. To do this, the mage must concentrate and relax on a ley line, letting the mystic energy fill him and heal him over a period of days. The mage can also perform an instant rejuvenation on a ley line as often as once every 24 hours, in which after about ten minutes of concentration, he is completely rested, alert, and healed of 20 Hit Points and 20 S.D.C. +1D6 additional Hit Points and 2D6 S.D.C. (or 4D6 M.D.C. if a Mega-Damage being) per level of experience! Again at no P.P.E. cost, but only possible on a ley line. Note: No P.P.E. or I.S.P. can be restored this way, only Hit Points and S.D.C."
  - name: "Ley Line Observation Ball"
    description: "A globe of light, about the size of a soccer ball, can be conjured out of thin air and linked to the Ley Line Walker like a third eye. The sphere of blue or white light can be directed by its creator to zoom ahead or behind him like a remote control spy device or familiar. Everything that the ball sees and hears is instantly transmitted to its maker. The sphere will remain in existence as long as the Ley Line Walker stays within the ley line, or until he dispels it, or until it is destroyed. Stats for a typical Observation Ball: M.D.C.: One point per level of its creator. Range: Up to 500 feet (152 m) away from its creator per level of experience, so a fifth level Ley Line Walker could send his Observation Ball 2500 feet away and a tenth level mage almost one mile (1.6 km). Speed: Up to Spd 44 (30 mph/48 km). Bonuses: +3 to dodge. It has no offensive capabilities other than to buzz onlookers and possibly startle them (not likely). Actions of that sort, however, require the Ley Line Walker to have line of sight on the ball for him to direct it mentally, each attack/action of the ball counting as one of his own melee actions/attacks."
  - name: "Affinity with Rift & Ley Line Magic"
    description: "The Spell Invocations known as Rift & Ley Line Magic are most commonly known by the Ley Line Walker O.C.C. These spells are common to the Ley Line Walker and although these spells can be important to the profession, the Ley Line Walker does not start with any at level one (unless a Ley Line Rifter O.C.C.). They are usually acquired over time. The Rift & Ley Line Magic spells are: Dimensional Portal (1000), Ley Line Fade (20), Ley Line Ghost (80 or 240), Ley Line Phantom (40), Ley Line Restoration (800+), Ley Line Resurrection (2000+), Ley Line Shutdown (3000), Ley Line Storm Defense (180), Ley Line Tendril Bolts (26), Ley Line Time Capsule (15), Ley Line Time Flux (80), Ley Line Transmission (30), Rift to Limbo (160), Rift Teleportation (200), Rift Triangular Defense System (840), Summon Ley Line Storm (500), Swallowing Rift (300). Learning them: These spells can be learned by being taught by an elder mage or by communing with the ley line. This can occur upon reaching a new mystic plateau (new level of experience), in which the character goes off onto a ley line allow and goes into a meditative trance that last 48 hours. At the end of the trance he knows one of these spells (pick one)."
  - name: "Ley Line Force Field"
    description: "The Ley Line Walker can also put in place an energy field reminiscent of the Armor of Ithan around himself whenever he''s on a ley line. This extra bit of protection provides 20 M.D.C. +2 M.D.C. per level of its creator''s experience. It costs the mage 10 P.P.E. to create/summon it initially, but once it is in place it remains up for the entire time he remains on the ley line or until he dispels it. If the Ley Line Force Field is destroyed, it will regenerate at full strength at the start of the next melee round. Note: Having the force field up and in place draws upon half the ambient P.P.E. of the ley line normally available (20 P.P.E.) to the Ley Line Walker per melee round. Energy the mage often draws upon to supplement his own spell casting. This could be a problem in a combat situation and require the character to drop his protective field to tap more energy."
  - name: "Initial Spell Knowledge"
    description: "In addition to the ley line powers, the Ley Line Walker is a master of spell magic (tends to avoid ritual magic, but can perform rituals if so needed). At level one experience, players may select any three spells from each magic Level 1-4, for a total of 12 spells (three from each). Each additional level of experience, the character will be able to figure out/select one new spell equal to his own level of achievement/experience. So a 4th level Ley Line Walker can select one new spell from level four, or from levels one, two or three (not one from each)."
  - name: "Learning New Spells"
    description: "Additional spells and rituals of any magic level can be learned and or purchased at any time regardless of the character''s experience level."
  - name: "P.P.E."
    description: "Like all practitioners of magic, the Ley Line Walker is a living battery of mystic energy. He draws upon that energy reserve to cast his spells and use magic. The Line Walker has the greatest amount of permanent P.P.E. of all mortal practitioners of magic. Permanent Base P.P.E.: 3D6x10+20 added to the character''s P.E. attribute number to start. Plus an additional 3D6 P.P.E. per each additional level of experience starting at level two. Supplemental P.P.E.: The Ley Line Walker can also draw an extra 20 P.P.E. per melee round when on a ley line and 40 when at a ley lines nexus point! P.P.E. can also be stolen from living creatures and people by killing them (hence rituals involving human sacrifices) because their P.P.E. is doubled at the moment of death! However, a character of good or Unprincipled alignment would never do such a thing (except possibly under the most extreme circumstance). People can also willingly give up a portion of their P.P.E., but that''s an unusual situation."
special_abilities:
  - name: "Mental Attribute Bonus (I.Q.)"
    description: "+1D4 to I.Q. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { IQ: "1d4" } }
  - name: "Mental Attribute Bonus (M.E.)"
    description: "+1D4 to M.E. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { ME: "1d4" } }
  - name: "Mental Attribute Bonus (M.A.)"
    description: "+1D4 to M.A. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { MA: "1d4" } }
  - { choose: 1, from: ["Mental Attribute Bonus (I.Q.)", "Mental Attribute Bonus (M.E.)", "Mental Attribute Bonus (M.A.)"] }
magic:
  type: "Ley Line Walker (Wizard)"
  spells_starting: 12
  spell_levels_allowed: [1, 2, 3, 4]
extraction_notes: |
  - The +1D4 bonus applies to any ONE Mental attribute (I.Q., M.E., or M.A.) at
    the player''s choice; modelled as three special_abilities fragments behind a
    choose-1 group, so the wizard offers the pick and the die rolls at creation.
  - The ley line powers are automatic rather than chosen, so they live under
    natural_abilities; special_abilities holds only the attribute pick. Fixed
    skill bases fold the O.C.C. bonus into the catalog base (Climbing 40+5=45),
    and "Math: Basic" / "Lore: Demon & Monster" are stored under their catalog
    names, Basic Math and Lore: Demons & Monsters.
  - The "+2 to save vs possession and mind control" bonus is recorded as both
    possession and mind_control - the derive layer carries a mind_control key
    (the Juicer''s +6 uses it), which an earlier revision of these notes
    believed did not exist.
  - The "+3 to save vs curses" at levels three, nine, eleven and fourteen is
    carried as bonuses.at_level entries, which accumulate as the character
    reaches each level. "+1 to spell strength" at levels 3, 7, 10 and 13 and
    "+1 on Perception Rolls at levels 2, 5, 7, 10, and 13; double when on a
    ley line" stay recorded here: neither spell strength nor perception is a
    derived stat yet, so there is still no key for a number to land on.
  - P.P.E. Recovery: spent P.P.E. recovers at a rate of seven points per hour of sleep or rest. Meditation restores P.P.E. at 15 per hour of meditation and is equal to one hour of sleep for this character when it comes to recovery from fatigue and physical rest. Not a schema field.
  - Cybernetics: "Starts with none and will avoid getting any cybernetic or other forms of physical augmentation because it interferes with magic. However, Bio-System prosthetics will be considered if necessary." Not modeled as a field; noted here.
  - Racial Requirement: "None. At least 30% are D-Bees." Not modeled since no explicit numeric requirement field exists for a distribution note; noted here.
  - Vehicle/weapon choice notes: "Vehicle of choice is usually a Techno-Wizardry device or hover vehicle or motorcycle or jet pack" is left as a choice not encoded in equipment_starting since no specific item slugs are given.
  - Ley Line Rifter O.C.C. begins at the end of this page range (page 4) but is a separate class and intentionally excluded from this extraction.
---

## Lore

The Ley Line Walker is a spell casting wizard but is anything but traditional. The mage is so attuned to ley lines that he can see magic energy emanating from even weak ley lines, normally invisible to the human eye, and see invisible magic energy (P.P.E.) radiating from living beings, enchanted/magic objects, Techno-Wizard devices, and supernatural creatures. This is not a see aura, but an ability to actually see mystic energy waves. Furthermore, the Ley Line Walker can feel the presence of ley lines, pinpoint nexus areas, and tell when a Rift has opened nearby.

The pursuit of magic is a means to utilize natural energy and direct it with one''s own force of will. The Ley Line Walker spends years learning to focus his thoughts and build his will in order to direct and mold mystic energy. He also spends years learning how to let the ley line energy flow into and through him, building his tolerance for magic energy and making the Line Walker a sort of living relay station and energy transformer, as well as a P.P.E. battery. At these moments, the Line Walker becomes part of the energy he is directing and it gives him much greater control and range of magic abilities.

Ley Line Walkers are inquisitive and open to new ideas, people, and philosophies. Many are literate, study areas of science and have no aversion to using high-tech weapons, vehicles, and equipment. Lightweight weapons and armor are generally preferred because they are less cumbersome and do not interfere with the flow of magic energy (full body armor and bionics block and disrupt magic energy).

The traditional garb of the Ley Line Walker comes from the beginning of the Dark Age and always includes some kind of headgear and tunic to cover the head and part of the face, a hooded cloak or cape (very big in cloaks and capes), loose fitting robes, loincloth (worn over pants or robes) and/or ornate belt with inscribed strips of cloth or ornate jewelry dangling from the waist, walking boots, and a gas mask or air filter to cover the mouth. Goggles, horns, and other face wrappings and coverings may also be part of the ensemble.

There are two schools of thought about Rift & Ley Line Magic. One is the typical Line Walker who feels Ley Line Magic is useful, but no more important or significant than any other spell invocation. The smaller camp who feel Ley Line Magic is of significant and overriding value is the Ley Line Rifter camp, described as elitists with unique and keen insights whose focus makes them special - specialists in Rift and Ley Line Magic, which most Ley Line Walkers and other practitioners of magic regard as short-sighted and limiting.

## GM Notes

**Ley Line Walker Concealed Body Armor:** Although it is not usually visible, light to medium body armor is worn under the robes. The chest, shoulders, thighs and back of the head are always protected. Two thirds of the time the M.D.C. plating also covers the arms as vambraces and armored gauntlets, and the rest of the legs as well. Again, it is either concealed under the robes or loose, baggy clothing, or so stylish it looks like ornamental arm bracelets or vambraces rather than armor. The materials are often made from natural M.D.C. materials like the plates from a Fury Beetle or hide of a dinosaur, and interlaced with M.D. ceramic plates, padding and miracle fibers. M.D. metal alloys may be used but are kept to a minimum because they interfere with the flow of P.P.E. and interferes with the ability to cast spells. Remember, the mage also has magic spells, such as Armor of Ithan, Impervious to Fire, etc., he can cast to provide additional protection for himself.

Stats for Concealed Ley Line Walker Armor: Light Armor Protection: 2D6+32 M.D.C. main body. Medium Armor: 3D6+50 M.D.C. main body; arms typically have 11-18 M.D.C., legs have 22-28 M.D.C.; -5% to Prowl, Climb, Swimming and other physical skills. Both are very common. Seldom wears heavy body armor. Heavy and full body armor are available in a variety of styles, but are seldom worn (maybe 10% wear them). For one, it''s too bulky and uncomfortable, and for another, it''s expensive, and lastly, unless it is made predominantly with natural materials, conventional environmental armor prevents spell casting. Techno-Wizard armor is one alternative for superior protection as well as a few non-magical alternatives, but Mage Armor always requires special consideration and construction to allow spell casting and the use of special abilities.

GMs should note the tension between the two philosophical camps of Ley Line Walkers (generalists vs. the specialist "Ley Line Rifter" mindset) as a roleplaying and rivalry hook - some Rifters look down on generalist Walkers, and vice versa.', 'published', 'import')
ON CONFLICT (class_id) DO UPDATE
   SET markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, created_by, length(markdown) AS markdown_bytes
  FROM imported_classes WHERE class_id = 'ley-line-walker';
SELECT count(*) AS stub_gear_rows FROM gear
 WHERE slug IN ('robe-or-cape', 'clothing', 'wooden-stake-and-mallet', 'flashlight', 'lightweight-cord', 'grappling-hook', 'pen-or-pencil', 'note-or-sketch-pad', 'hand-axe', 'automatic-pistol', 'submachine-gun', 'energy-pistol', 'energy-rifle', 'ammunition-clips');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-ley-line-walker-class.sql');
