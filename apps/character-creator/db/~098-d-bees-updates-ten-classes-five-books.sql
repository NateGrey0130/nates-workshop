-- Ten classes from five older books follow their D-Bees of North America
-- printing, and the Lyn-Srial Cloudweaver keeps pace with its race.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~098-d-bees-updates-ten-classes-five-books.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~098-d-bees-updates-ten-classes-five-books.sql
--
-- The last of four batches (see ~095 for the ruling and the rule applied
-- where D-Bees is silent): the classes Rifts World Book 30: D-Bees of North
-- America (2007) reprints and updates from Underseas (1995), New West (1997),
-- South America (1994), Atlantis (1992) and Lone Star (1997).
--
--   horune-pirate            D-Bees printed 100-103 (Underseas 164-165)
--   cactus-people            D-Bees printed 41-44   (New West 125-127)
--   fennodi                  D-Bees printed 83-85   (New West 128-130)
--   lyn-srial                D-Bees printed 127-129 (New West 133-134)
--   lyn-srial-sky-knight     D-Bees printed 129-130 (New West 134-135)
--   pogtalian-dragon-slayer  D-Bees printed 156-159 (South America 135-136)
--   blind-warrior-women      D-Bees printed 15-18   (Atlantis 50-51)
--   tokanii                  D-Bees printed 203-206 (Lone Star 154-156)
--   simvan-monster-rider     D-Bees printed 188-190 (Lone Star 162-163)
--   psi-x-alien              D-Bees printed 166-168 (Lone Star 98-100)
--
-- Each was read against BOTH books off page renders by one reader and
-- checked against renders again by another that did not write it: no wrong
-- figure in ten classes. None changes shape.
--
-- THE CLOUDWEAVER. lyn-srial-cloudweaver and lyn-srial-sky-knight are
-- declared copies of lyn-srial, and regression holds a copy to its original
-- on every key outside its `except` list. The race gains two blocks here:
-- the +2 dodge in flight both books print (the held row had dropped it) and
-- D-Bees's Vulnerabilities line. Both are the race's, so both copies carry
-- the same two blocks. D-Bees does not reprint the Cloudweaver (its printed
-- 130 points back to New West), so that class keeps its New West citation
-- and changes in nothing else.
--
-- Readings a page does not settle, each stated in its class's notes:
--   simvan-monster-rider  the female's Cook, Dance and Sing are listed with
--                         bonuses of their own after "+30% on all Domestic";
--                         the +30% alone is stored.
--   fennodi               D-Bees lists body flip between "+6 to pull punch"
--                         and "+2 to roll"; no figure is stored for it (the
--                         held +1 matched neither book).
--   pogtalian-dragon-slayer  no Horror Factor: South America printed 12,
--                         D-Bees prints none on any page of the entry.
--   blind-warrior-women   Hand to Hand: Martial Arts comes off, because
--                         D-Bees's skill list names no style and fixes the
--                         attacks at eight.
--
-- Each draft reads `ready` in class-check --remote. psi-x-alien's six table
-- rows take the names D-Bees prints (Kineticist, Psychic Sensitive and so
-- on) with their bands unchanged, and its two Technical variants take
-- D-Bees's names and contents; no other pick-one option or variant is
-- renamed. Production held no saved character on any of these classes when
-- this was written.
--
-- Each UPDATE is guarded on the class's old source_book line (the
-- Cloudweaver: on not yet carrying the block) and on the exact stored length
-- (trailing newline counted). THIS SCRIPT CHANGES PRODUCTION: eleven class
-- rows. The tilde number is claimed at merge.

-- == horune-pirate ==
UPDATE imported_classes
   SET markdown = '---
id: horune-pirate
name: Horune Pirate
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.100-103
category: rcc
tags: [combat]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+4"
  MA: "2d6+4"
  PS: "3d6+10"
  PP: "3d6+6"
  PE: "3d6+6"
  PB: "2d6"
  Spd: "4d6+10"
mdc_base: "P.E. + 1d4x10, +1d6 per level"
horror_factor: 10
bonuses:
  combat: { initiative: 3, strike: 2, parry: 2, dodge: 1, pull_punch: 2, roll: 1, perception: 1 }
  saves: { horror_factor: 4, disease: 4 }
  at_level:
    - { level: 3, combat: { perception: 1 } }
    - { level: 5, combat: { perception: 1 } }
    - { level: 7, combat: { perception: 1 } }
    - { level: 9, combat: { perception: 1 } }
    - { level: 11, combat: { perception: 1 } }
    - { level: 13, combat: { perception: 1 } }
psionics:
  type: "major"
  isp_base: "M.E. x5, +1d6+2 per level"
  powers: ["Hydrokinesis", "Object Read (Psychometry)", "Mind Block", "Resist Fatigue", "Resist Hunger"]
  powers_starting: 3
  categories_allowed: ["Physical"]
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Printed as Basic Math (+10%)." }
    - { name: "Military: Warships & Patrol Boats", base: 45, per_level: 4, note: "Printed as Pilot: Warships & Patrol Boats (+5%)." }
    - { name: "Water Scooters", base: 60, per_level: 5, note: "Printed as Pilot: Water Scooters (+10%)." }
    - { name: "Water Skiing & Surfing", base: 50, per_level: 4, note: "Printed as Pilot: Water Skiing and Surfing (+10%)." }
    - { name: "Navigation", base: 50, per_level: 5, note: "Printed as Pilot Related: Navigation (+10%)." }
    - { name: "Navigation: Underwater", base: 30, per_level: 4, note: "Printed as Underwater Navigation, with NO bonus." }
    - { name: "Salvage", base: 45, per_level: 5, note: "Printed as Salvage (+10%, applicable on dry land and underwater)." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "Printed as Wilderness Survival (+10%)." }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. knife or sword, pick one." }
    - { name: "W.P. Harpoon & Spear Gun", base: 0, per_level: 0 }
    - { name: "W.P. Torpedo", base: 0, per_level: 0 }
    - { name: "W.P. Trident", base: 0, per_level: 0, note: "Printed as W.P. Spear/Trident." }
    - { name: "W.P. Spear", base: 0, per_level: 0, note: "Printed as W.P. Spear/Trident." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Rifle", "W.P. Handguns", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"], note: "W.P. Modern: two of choice. W.P. Energy Pistol is already granted above." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts or Assassin at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic", "Marine Biology", "Ocean Geographic Surveying", "Undersea Farming"], bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Cowboy, Electrical, Mechanical and Medical are barred entirely. Science is math and sea-related only, which is stored as the four catalog rows that answer that description. The book gives Pilot +5% generally and +10% on all sea vessels; a category entry carries ONE bonus, so the general +5% is stored and the sea vessel half is in this note."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
    note: "NONE at first level: two arrive at each of levels two, four, eight and twelve, selected from the Secondary Skill List on page 300 of Rifts Ultimate Edition, at the base skill level without bonuses other than a possible I.Q. bonus."
equipment_starting:
  - { item_id: "horune-harpoon-gun", qty: 1 }
  - { choose: 1, label: "Vibro-Sword or Dagger", qty: 1, from: ["vibro-sword", "vibro-knife"] }
  - { item_id: "gun-holster", qty: 1 }
  - { item_id: "utility-belt", qty: 2 }
  - { item_id: "large-sack", qty: 4 }
  - { item_id: "backpack", qty: 1 }
restrictions:
  - "Optional player character and NPC: a horune may be used as a player character only if the Game Master allows it."
  - "Typical alignment: anarchist 40%, aberrant 30%, other 30% and mostly evil. A player character''s alignment is not likely to be better than anarchist or unprincipled, although good alignments are possible."
  - "ALL HORUNE ARE MEGA-DAMAGE CREATURES and may be minor supernatural beings or sub-demons from another dimension, similar to gargoyles. They are NOT a gene-splicer creation, whatever the rumours say."
  - "SUPERNATURAL STRENGTH AND ENDURANCE. A restrained punch does 4D6 S.D.C., a full strength punch 2D6 M.D., a power punch 4D6 M.D."
  - "M.D.C. is 1D4x10 plus the P.E. attribute number, plus 1D6 per level of experience. Horune also wear M.D.C. body armour or use magic for additional protection."
  - "Horror Factor: 10. Size 5 to 6 feet (1.5 to 1.8 m), weight 200 to 300 lbs (90 to 135 kg), mostly muscle. Average life span 4D6+138 years."
  - "THEY HAVE NO GILLS. Unaided, a horune holds its breath for up to 12 minutes and tolerates depths of up to 500 feet (152 m), and needs air tanks, power armour, a vehicle or magic to work underwater for long."
  - "PART OF THE COMBAT BONUSES ARE UNDERWATER-ONLY. The racial bonuses are +1 on Perception Rolls at levels 1, 3, 5, 7, 9, 11 and 13, +2 on initiative, +1 to strike and parry, +2 to pull punch, +4 to save versus disease and +4 versus horror factor. Underwater it adds a further +1 on initiative, +1 to strike, parry and dodge, +1 to disarm and +1 to roll with impact. The stored figures are the two SUMMED, on the same reasoning used for the Amphib and the naut''yll, except the underwater +1 to disarm, which is stated here only; a horune fighting on dry land should drop 1 from initiative, strike, parry, dodge and roll."
  - "Magic: only if a Horune Mystic. A horune mystic gets the psionic and magic powers of the Mystic O.C.C. (Rifts Ultimate Edition) but uses the R.C.C. skills and secondary skills on this page, not those of the Mystic O.C.C. - see BOOK-INGEST-AUDIT.md F23(a)."
  - "Standard equipment besides the stored items: a standard half suit of body armour (50 M.D.C.; other armour can be purchased or stolen), energy pistols of choice, an energy trident or M.D.C. trident, a magic Sea-Horse Scooter and a handful of personal items. Bigger, better weapons, environmental armour, magic items and equipment can be acquired later."
  - "Money: 1D6x1000 worth of tradeable valuables. Pirates spend their loot on weapons, booze and good times."
  - "Cybernetics and bionics: not applicable, because of their superhuman and regenerative nature."
  - "THE RACIAL BOND IS STRONG ENOUGH TO BE A ROLEPLAYING CONSTRAINT. Even a good horune will try to avoid conflict with other horune. Evil ones mock and torment those who leave to live among outsiders, and a captured good horune is likely to be imprisoned or sold into slavery rather than executed."
  - "They are carnivores who feed on the flesh of animals, humanoids and intelligent life forms, and ritual cannibals who devour renegades and rivals after a duel to the death - usually between Captains, and rare, since horune seldom fight each other in earnest."
natural_abilities:
  - name: "Five Eyes"
    description: "Two on short eye-stalks that bend to look up, down and backwards without moving the head - hawk-like, reading a sign two miles (3.2 km) away, but near-sighted at close range, and needing thought and concentration to aim anywhere but forward. Three fixed in the centre of the head handle close combat and detail work at roughly perfect human sight, and see into the ultraviolet and infrared - which lets a horune see in murky or dim water AND see the magically invisible."
  - name: "Nightvision"
    description: "500 feet (152 m)."
  - name: "Swimming"
    description: "Instinctual swimmers: swims at 92% with the same motions as a human. No gills: it holds its breath for up to 12 minutes and tolerates 500 feet (152 m) unaided."
  - name: "Bio-Regeneration"
    description: "Regains 1D6 M.D.C. per hour, regrows small appendages like fingers, toes, eye stalks and eyes in 1D6 weeks, and arms and legs in 2D4 months."
  - name: "Good Hearing"
    description: "A keen sense of hearing to go with the eyes."
  - name: "Nostril Flaps"
    description: "A flap of skin plugs the nostrils underwater. The mouth is an extended snout full of large sharp teeth."
extraction_notes: |
  - Followed Rifts World Book 7: Underseas printed 164-165 until this update;
    brought up to the Rifts World Book 30: D-Bees of North America printing,
    printed 100-103, under the ruling of 2026-10-04 (the newest printing that
    states a figure wins). Both books read off page renders: D-Bees cache
    p101-p104 (cache page = printed folio + 1) and Underseas cache p163-p164
    and p213 (cache page = printed folio - 1 past printed 130). The D-Bees
    entry ends on printed 103 with the note Originally appeared in World Book
    7: Rifts Underseas with a detailed update in Rifts World Book 27:
    Adventures in Dinosaur Swamp. The Dinosaur Swamp printing was not read.
  - M.D.C.: D-Bees printed 102 gives 1D4x10 + P.E. attribute number, plus 1D6
    per level; Underseas printed 164 gave P.E. plus 1D4x10 and 1D6 per level,
    the same figure. The row held 1d4x10 alone, with the per-level gain in a
    restrictions line, until this update.
  - HORROR FACTOR 10 in both books, stored as horror_factor. The row held it
    only as a restrictions line until this update.
  - HOLD BREATH: D-Bees printed 102 gives up to 12 minutes. Underseas printed
    164 gave 3D4 minutes.
  - LIFE SPAN: D-Bees gives 4D6+138 years, females bearing one or two young
    after a 12 month pregnancy, physical maturity by age 17. Underseas printed
    164 gave 160 Earth years.
  - BIO-REGENERATION: D-Bees adds eye stalks to the small appendages regrown in
    1D6 weeks. Underseas printed 165 gave fingers, toes and eyes.
  - EXPERIENCE: D-Bees printed 102 says to use the same Experience Table as the
    Operator. Underseas printed 214 prints a column headed Horune Pirate,
    Naut''Yll Soldier, and its fifteen lower bounds are the same figures as the
    operator class''s stored xp_table, so the stored ladder is unchanged and
    answers both books.
  - ITS PSIONICS ARE A REAL GRANT. Both books make every horune a MAJOR psionic
    of vast ability with five named powers - hydrokinesis, object read, mind
    block, resist fatigue, resist hunger - plus three physical powers of
    choice, I.S.P. M.E. x5 plus 1D6+2 per level. Hydrokinesis is a SUPER row in
    this catalog and is granted by name, which is why categories_allowed is
    Physical alone: the three chosen powers come from there, and the super
    power is a grant rather than a pick.
  - THE STORED COMBAT BONUSES ARE THE SUM OF A RACIAL SET AND AN UNDERWATER SET,
    printed separately in both books. The racial bonuses hold everywhere; the
    underwater ones add on top. Summing them and stating the land subtraction
    in the restrictions is the same call made on the Amphib and the naut''yll.
    D-Bees printed 102 adds two things Underseas printed 165 did not give: +1
    on Perception Rolls at levels 1, 3, 5, 7, 9, 11 and 13, stored in bonuses
    and at_level, and +1 to disarm in the underwater set, which is conditional
    and is stated in the restrictions line only, not added to the stored sum.
  - R.C.C. SKILLS: D-Bees printed 102 gives Salvage (+10%, applicable on dry
    land and underwater) and Wilderness Survival (+10%); Underseas printed 165
    gave Undersea Salvage and Undersea Survival, each with no bonus, and the
    row held Undersea Salvage at 30 and Undersea & Sea Survival at 25 until
    this update. D-Bees gives W.P. Harpoon & Spear Gun (Underseas: W.P. Harpoon
    Gun), W.P. Spear/Trident (Underseas: W.P. Trident; stored as the two
    catalog rows W.P. Trident and W.P. Spear) and W.P. Modern: Two of choice
    (Underseas: Additional W.P.s: Two of choice, which the row held as any two
    from Weapon Proficiencies; now a named list of the catalog''s modern W.P.s).
    Underwater Navigation is printed with no bonus in both books and its stored
    base is the bare catalog figure.
  - R.C.C. RELATED SKILLS: D-Bees adds Cowboy: None to the list; every other
    line is the same in both books. Cowboy was never stored as a category.
    THE PILOT BONUS IS TWO NUMBERS AND ONE IS STORED. Both books give Pilot:
    Any (+5%; +10% on all sea vessels, Underseas: seacraft). A category entry
    carries one bonus for every skill in it, so the general +5% is stored and
    the sea vessel half is in the note.
  - SECONDARY SKILLS: two at levels 2, 4, 8 and 12 in both books. D-Bees takes
    them from the Secondary Skill List on page 300 of Rifts Ultimate Edition;
    Underseas printed 165 took them from the related skills list, limited as
    that list is and without its bonuses.
  - MYSTICS ARE F23(a): D-Bees printed 103 says a Horune Mystic gets the
    psionic and magic powers of the Mystic O.C.C. (Rifts Ultimate Edition) but
    uses the R.C.C. Skills and Secondary Skills described here, not those of
    the Mystic O.C.C. Underseas printed 165 cited Rifts RPG page 85 and added
    Do not select any of the O.C.C. related skills, which D-Bees does not
    restate.
  - EQUIPMENT: the same list in both books (Underseas printed 165, D-Bees
    printed 103): standard half suit body armor (50 M.D.C.), energy pistols of
    choice, energy trident or M.D.C. trident, Vibro-Sword or dagger, harpoon
    gun, a magic Sea-Horse Scooter, holster, utility belts, four large sacks,
    backpack and a handful of personal items. The row held no equipment until
    this update. Stored: the Horune Harpoon Gun (Underseas printed 166), a
    Vibro-Sword or Vibro-Knife pick, a gun holster, two utility belts (the book
    prints the plural and no count), four large sacks and a backpack. The half
    suit, the energy pistols of choice, the trident pick (the catalog has no
    M.D.C. trident row), the Sea-Horse Scooter (no catalog row) and the
    personal items are in a restrictions line.
  - MONEY: D-Bees gives 1D6x1000 worth of tradeable valuables; Underseas gave
    1D6x1000 worth of valuables. Valuables, not coin, so no starting_money.
  - ALIGNMENT AND PLAY: D-Bees printed 102 says horune may be player characters
    only if the Game Master allows it, and that good alignments are possible.
    Underseas printed 164 said the horune can be used as a player character as
    well as an NPC villain, and that good alignments are possible, but very
    rare. D-Bees does not restate the Underseas sentences on evil horune
    mocking those who leave, on a captured good horune being imprisoned or sold
    into slavery, or on the horune not being a gene-splicer creation; they are
    kept from Underseas.
  - CYBERNETICS: D-Bees prints Cybernetics and Bionics, not applicable because
    of their superhuman and regenerative nature; Underseas printed supernatural.
  - NOT STORED: NPC experience level 2D4 or as set by the Game Master (player
    characters start at first level); slave market value 2D6x1000 with very low
    demand; P.P.E. Standard (both books); disposition (driven, organized,
    malicious and cruel); vulnerabilities none per se; habitat, allies and
    enemies. D-Bees prints the damage line as Underseas did and adds Or by
    weapon or psionics.
---

# Horune Pirate

## Lore

The horune are a stocky race with rough, almost scaly skin and five eyes. Two sit on short stalks that bend to look up, down and backwards without moving the head - hawk-sighted at two miles but near-sighted up close. The other three are fixed in the centre of the face for close work, and see into the ultraviolet and infrared, which lets a horune see through murky water and see the magically invisible. A flap of skin plugs the nostrils underwater, and the mouth is a short snout full of large sharp teeth.

They are mega-damage creatures and may be minor supernatural beings or sub-demons from another dimension, similar to gargoyles - not, whatever the rumours say, a gene-splicer creation.

They are carnivores who eat the flesh of animals, humanoids and intelligent life forms, and ritual cannibals who devour renegades and rivals after a fight to the death. That is rare in practice: horune seldom face each other in mortal combat.

Underwater they swim quickly with the same motions as a human - but they have no gills, and need air tanks, power armour, a vehicle or magic to stay down for long.

## GM Notes

As a player character a horune is likely to be a loner, an outcast or a rogue, and an alignment better than anarchist or unprincipled is possible.

The racial memories and instinctual bonds of this race are strong enough to shape play. Even a good horune will try to avoid conflict with other horune. Evil ones mock and torment those who abandon the race to live among outsiders. A captured good horune is likely to be imprisoned or sold into slavery rather than executed.

The horune keep no official alliance with any kingdom, but are friendly with Atlantis, come only to the aid of another horune, and will make deals with other pirates, villains and evildoers.
',
       updated_at = datetime('now')
 WHERE class_id = 'horune-pirate'
   AND instr(markdown, 'source_book: Rifts World Book 7: Underseas p.164-165') > 0
   AND length(markdown) = 11085;

-- == cactus-people ==
UPDATE imported_classes
   SET markdown = '---
id: cactus-people
name: Cactus People
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.41-44
category: rcc
tags: [wilderness]
xp_table: [0, 1936, 3871, 7751, 15401, 20001, 30001, 40001, 60001, 80001, 110501, 140001, 180001, 230001, 280001]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+8"
  MA: "2d6+2"
  PS: "2d6+6"
  PP: "2d6+6"
  PE: "2d6+6"
  PB: "2d6"
  Spd: "2d6+2"
hit_points_base: "P.E. attribute number plus 1d6 per level of experience"
sdc_base: "4d6+6"
ppe_base: "4d6"
horror_factor: "9+1D4"
psionics:
  type: "minor"
  isp_base: "M.E. attribute number plus 1d6 per level of experience"
  powers: ["Empathy", "See Aura", "See The Invisible"]
bonuses:
  combat: { roll: 1 }
  saves: { disease: 3, possession: 2 }
skills:
  hand_to_hand: { costs: { expert: 2 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Botany", base: 40, per_level: 5, note: "+15%" }
    - { name: "Brewing", base: 40, per_level: 5, note: "+15%" }
    - { name: "Brewing: Medicinal", base: 35, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 15, note: "Lore: two of choice (+15%)." }
    - { name: "Holistic Medicine", base: 35, per_level: 5, note: "+15%, but on Cactus People only." }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Preserve Food", base: 40, per_level: 5, note: "+15%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { choose: 2, categories: [{ name: "Physical", except: ["Acrobatics", "SCUBA"] }], note: "Two Physical skills of choice, except Acrobatics and SCUBA." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. two of choice (any)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be traded up to Expert for two R.C.C. Related skills. No other combat choices are available." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Keen vision", description: "Sees the ultraviolet spectrum as well as ordinary light, and is not bothered by glare or bright light." }
  - { name: "Sun healing", description: "Heals 2D6 hit points or S.D.C. per day of sunlight, or 1D4 if the day is cloudy or the character is in darkness." }
  - { name: "Needs neither food nor water", description: "Can function for up to a week without either and take no ill effect. Water is drawn from the fresh plants they eat; cooked greens carry only a quarter of the nutrition and water they need, frozen a half, and dried a twentieth. They cannot eat grass or tree leaves, and never eat meat." }
  - { name: "Regrowth", description: "Like a real plant, a Cactus Person that loses a hand, foot, arm, leg or even part of its body or head grows it back in 1D4+3 weeks. It does not feel pain as humans do, but does feel some pain and fears death." }
  - { name: "Impervious to vampires", description: "Impervious to the bite and the charms of the vampire." }
  - { name: "Resistant to heat and cold", description: "Functions just fine in temperatures as hot as 120 degrees Fahrenheit or as cold as zero." }
  - { name: "Special telepathy", description: "Costs no I.S.P. and works like telepathy, except that it reaches other species at up to 200 feet and members of their own race at up to 600 feet, plus 50 feet per level of experience." }
  - { name: "Horror Factor 9+1D4", description: "Their appearance can disturb people. This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor." }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "lightweight-rope", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { choose: 1, label: "backpack or saddlebags", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Cowboy, Espionage, Military and Rogue are closed as related categories."
  - "Can only wear body armour for short periods: they need the sun on them, and M.D.C. armour blocks the ultraviolet that ordinary clothing does not."
  - "Rarely study new skills after first level, other than secondary ones."
  - "Available O.C.C.s: none; the R.C.C. is the whole of the character''s training."
  - "Magic: none."
  - "Bionics: not applicable to these plant people."
side_effects: "The life fluid of Cactus People is a highly nutritious, sweet tasting liquid and an excellent substitute for water - many a foul person lost in the desert has slain a Cactus Person to drink it. It never spoils (it stays fresh for 4D6+48 months) and is ideal for magic healing potions and elixirs, so Splugorth Slavers, Brodkil, Worm Wraiths, demons, diabolic raiders and practitioners of magic, and evil dragons view them as crops to be harvested and will pay 1000 credits per half gallon; the typical Cactus Person holds one gallon, the largest two or three. They are also harassed and killed by bandits, slavers, drifters and humans who shoot D-Bees for target practice. Vulnerabilities, as printed: the value of their life fluid, shyness and lack of aggression all tend to work against them."
extraction_notes: "This class followed Rifts World Book 14: New West printed 125-127 (experience table printed 224) until it was brought up to the 2007 reprint in Rifts World Book 30: D-Bees of North America printed 41-44, under the ruling of 2026-10-04 that the newest printing stating a figure wins. WHAT D-BEES REVISED, with the older figure: P.B. is 2D6 (New West printed 127 gave 2D6+2). Secondary skills come at levels 1, 4, 8 and 12 (New West printed 127 gave 1, 4, 8, 10 and 12) and are taken from the Secondary Skill List of Rifts Ultimate Edition (New West took them from the R.C.C. Related list, excluding the categories marked None). The R.C.C. Skills gain Brewing +15%, Brewing: Medicinal +10% and Preserve Food +15%, none of which New West printed 127 lists, and the two Physical skills of choice now exclude Acrobatics and SCUBA (New West gave two Physical skills of choice with no exception). The Bonuses line adds +1 to roll with impact, +2 to save vs possession, imperviousness to the bite and charms of the vampire and resistance to heat and cold; New West printed only the +3 to save vs disease, inside its natural abilities. Natural abilities add no bother from glare or bright light, regrowth of a lost part in 1D4+3 weeks and a reduced sense of pain. Attacks per Melee reads as per the Hand to Hand Combat skill, so `attacks_base: 2` is no longer stored; New West printed 127 gave: Typically hand to hand: basic, if any. Those without combat training have two attacks per melee round. The life fluid sells for 1000 credits per half gallon and stays fresh 4D6+48 months (New West printed 127 gave 1000 credits per gallon and stays fresh for months). Size is 4-6 feet and weight 70-150 pounds (New West gave an average 5 feet and 150 pounds); life span is 2D6+50 years (New West gave 60 years). D-Bees also prints Magic: None, Bionics: not applicable, and Available O.C.C.s: None, stored as restrictions. UNCHANGED BETWEEN THE TWO PRINTINGS: the other seven attributes, hit points, S.D.C. (both add: plus those from skills; half for young), P.P.E., Horror Factor, the psionics, the R.C.C. Related list, the equipment line and the experience table, which D-Bees prints at the end of the entry on printed 44 and which matches the Cactus People R.C.C. column of New West printed 224 figure for figure. D-Bees prints the I.S.P. costs Empathy (4), See Aura (6) and See Invisible (4). Attributes, hit points, S.D.C., P.P.E. and I.S.P. are all printed as formulas rather than numbers and are stored as written. The Horror Factor of 9+1D4 is one the character IMPOSES rather than saves against, so it is not a bonus. It was only a natural ability on import, the demigod''s precedent; the New West backfill stored it as the top-level `horror_factor` BOOK-INGEST-AUDIT F75 added in PR #1081, and the natural ability keeps the description. The special telepathy is a natural ability rather than a psionic power because it costs no I.S.P. and the catalog''s Telepathy row is a purchasable power with a cost; the three that ARE catalog powers are granted by name. Standard Equipment, the same list in both books: a set or two of clothing (one stored), light body armour for combat situations, a portable tool kit, a survival knife, a cigarette lighter, a pocket mirror, 50 feet of lightweight rope (one catalog row stored, which is priced per 20 feet), a utility belt, a knapsack, a backpack or saddlebags (a pick of one), a shoulder bag for fresh food and plants, two medium Tupperware containers, a box of 100 zip-lock sandwich bags, a canteen or water skin (the canteen is stored), a Vibro-Blade and two weapons of choice. The light body armour, shoulder bag, Tupperware, zip-lock bags, Vibro-Blade and the two weapons of choice are not stored: the book names no specific item. Neither book gives a starting money figure - D-Bees says only that they have little need for money but have learned the value of credits - and none is invented. NPC FIGURES with no field: alignment is any, but generally Principled (50%), Scrupulous (20%), Unprincipled (10%) and Anarchist (10%); experience level is 1D6 or as set by the Game Master for NPCs, and player characters start at level one. HABITAT: the plains of the New West including southwestern Canada and Mexico. ALLIES AND ENEMIES: D-Bees names the Fennodi, N''reta, Lyn-Srial, Cyber-Knights and most Native Americans and Elemental Fusionists as friends and allies, with all others viewed with suspicion until they prove otherwise; rivals and enemies are Worm Wraiths, Brodkil, demons, slavers and evil humanoids, they view other plant and insect people with suspicion, and they dislike the Simvan, who harass them for fun. New West printed 127 named the Fennodi, the Lyn-Srial and Cyber-Knights as allies and other humanoids and slavers as enemies. There is no field for either and both are here."
---

# Cactus People

**Alignments.** Any, but generally good or selfish.

The Cactus People - their own name is unpronounceable for most humans - are
cactus-green, with lumps and thorny protrusions that give them their nickname.
Some of the lumps on the head are eyes, typically three or four at the front,
while the thorny ones are decorative, much like hair. Females are the lumpiest;
males grow long leafy strands at the side and back of the head that look like
hair, and full-grown adult males develop a ribbing that resembles a wide,
toothy smile. They have two arms and two legs, with three long fingers and a
thumb on each hand, each digit ending in a suction cup.

They live on sunshine and greens - feeding on ultraviolet radiation, various
gases, and fresh vegetables and cactus - which makes the Southwest ideal. Most
live off the land or farm cactus and green vegetables: lettuce, cabbage,
spinach, tobacco (they eat the leaves), green beans, peas.

## Manner

Quiet, reserved and unassuming vegetarians who try to avoid trouble. They have
little regard for money or valuables, though most keep a handful of favourite
possessions - a favourite gun, toys, clothes, odds and ends.

They have little need of buildings except as refuge from predators and bad
storms, and they enjoy a good rain. Most live near a pre-Rifts ruin, an
abandoned vehicle, a cave or a canyon; some build a shack or take over a
covered wagon or an old truck.

They will use technology in limited ways - weapons, armour and tools - and
although they are pacifists, they fight bravely for their lives, families,
homes and crops.

## Lore

Also known as Greenies and Cactus Heads. Height four to six feet, weight 70 to
150 pounds, lifespan 2D6+50 years, and one or two young as often as every
eighteen months.
',
       updated_at = datetime('now')
 WHERE class_id = 'cactus-people'
   AND instr(markdown, 'source_book: Rifts World Book 14: New West p.125-128') > 0
   AND length(markdown) = 8055;

-- == fennodi ==
UPDATE imported_classes
   SET markdown = '---
id: fennodi
name: Fennodi
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.83-85
category: rcc
tags: [psionics]
attribute_dice:
  IQ: "3d6+2"
  ME: "2d6+8"
  MA: "2d6+10"
  PS: "2d6+10"
  PP: "2d6+8"
  PE: "2d6+8"
  PB: "2d6+2"
  Spd: "2d6+8"
hit_points_base: "P.E. attribute number plus 2d4 per level of experience"
sdc_base: "4d6"
ppe_base: "4d6+12"
horror_factor: 9
bonuses:
  combat: { attacks_base: 3, initiative: 1, disarm: 4, pull_punch: 6, parry: 1, dodge: 1, roll: 2 }
  saves: { disease: 2, toxins_poisons: 2, horror_factor: 1 }
  at_level:
    - { level: 2, combat: { attacks: 1, dodge: 1 } }
    - { level: 3, combat: { parry: 1 }, saves: { horror_factor: 1 } }
    - { level: 4, combat: { attacks: 1, dodge: 1 } }
    - { level: 6, combat: { attacks: 1, parry: 1, dodge: 1 }, saves: { horror_factor: 1 } }
    - { level: 8, combat: { attacks: 1, dodge: 1 } }
    - { level: 9, combat: { parry: 1 }, saves: { horror_factor: 1 } }
    - { level: 10, combat: { attacks: 1, dodge: 1 } }
    - { level: 12, combat: { attacks: 1, parry: 1, dodge: 1 }, saves: { horror_factor: 1 } }
    - { level: 14, combat: { attacks: 1, dodge: 1 } }
    - { level: 15, combat: { parry: 1 }, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Wilderness Survival", base: 55, per_level: 5, note: "+25%. Granted IN ADDITION to the chosen O.C.C.''s skills." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%. In addition to the O.C.C." }
    - { name: "Prowl", base: 40, per_level: 5, note: "+15%. In addition to the O.C.C." }
    - { name: "W.P. Staff", base: 0, per_level: 0, note: "In addition to the O.C.C." }
special_abilities:
  - { choose: 1, from: ["Psionics of the Male Fennodi", "Psionics of the Female Fennodi"], note: "The book gives the sexes different psionic profiles. Pick the one that matches the character." }
  - name: "Psionics of the Male Fennodi"
    description: "Empathy, telepathy, sixth sense, mind block and empathic transmission, plus two healing abilities of choice, a psychic affinity with the Whisker Coyote, and the Protective Energy Aura and Ghost Walk below. One more healing power at levels 2, 4, 6, 8, 10 and 12."
    psionics:
      type: "major"
      isp_base: "M.E. attribute times two plus 2d6 per level of experience"
      powers: ["Empathy", "Telepathy", "Sixth Sense", "Mind Block", "Empathic Transmission"]
      powers_starting: 2
      powers_per_level: 1
      categories_allowed: ["Healing"]
  - name: "Psionics of the Female Fennodi"
    description: "Empathy, telepathy, sixth sense, mind block and bio-manipulation, plus three physical abilities, a psychic affinity with the Whisker Coyote, and the Protective Energy Aura and Ghost Walk below. One more physical power at levels 2, 4, 6, 8, 10 and 12."
    psionics:
      type: "major"
      isp_base: "M.E. attribute times three plus 2d6 per level of experience"
      powers: ["Empathy", "Telepathy", "Sixth Sense", "Mind Block", "Bio-Manipulation (the evil eye)"]
      powers_starting: 3
      powers_per_level: 1
      categories_allowed: ["Physical"]
  - name: "Protective Energy Aura"
    description: "A natural psionic defence that engages the instant an attack or danger is sensed - a reflex, like an adrenaline surge. It gives 16 M.D.C. plus 1D4 per level of experience, enough to survive the average pistol or rifle blast, and regenerates 2D6 M.D.C. per melee round. It is usually what buys a Quiet Walker the moment needed to take cover."
  - name: "Ghost Walk"
    description: "Partially phases out of space and time, straddling the Astral and physical planes as a semi-transparent apparition. Nothing from the physical plane touches them - heat, cold, fire, punches, arrows, bullets, energy, explosions, psionics including telepathy and empathy, and magic all pass straight through - but they can be attacked from the Astral Plane. While phased they cannot use psionics, cannot communicate except by hand signals and gesture, and cannot touch or affect anything physical. Movement is slow: two melee actions, silent walking, and a fifth of normal speed. Range: self only, including clothing, walking stick, hat and backpack. Duration five minutes per level. I.S.P.: 10."
  - name: "The Art of Nodox"
    description: "Avoidance and defence. It is what the three attacks per melee and the initiative, disarm, pull punch, parry, dodge and roll bonuses in this class come from, along with the body flip move and pin or incapacitate on a roll of 17-20, which must be announced. Fennodi generally fight only to escape or restrain an opponent, and rarely kill for any reason."
natural_abilities:
  - { name: "Keen vision", description: "Sees the infrared spectrum. The eyes sit on small fins that fold flat, fan forward and tilt, giving a 280 degree field of vision." }
  - { name: "Impervious to carcinogens", description: "They love to smoke, prefer pipes, and cannot get cancer from it." }
  - { name: "Horror Factor 9", description: "Their appearance can disturb people despite the gentle disposition. This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor." }
equipment_starting:
  - { item_id: "survival-knife", qty: 1 }
restrictions:
  - "The Fennodi takes an O.C.C. and advances on ITS experience table - D-Bees of North America printed 84 says to use the experience table of the chosen O.C.C., as New West printed 223 did. The four skills above are granted regardless of that O.C.C., and the related and secondary skills come from the O.C.C., not from here."
  - "Available O.C.C.s: a third of all Fennodi are Cowboys and 20% are Saddle Tramps, but they can be any type of Vagabond, Rogue Scholar, Rogue Scientist, Body-Fixer, Operator, Preacher, Wilderness Scout, or Adventurer and Scholar O.C.C."
  - "Cybernetics and bionics are not possible."
  - "Equipment and money are as per the chosen O.C.C."
  - "Never study magic, though they find it fascinating and will use magic items."
  - "No interest in gambling or risk taking."
side_effects: "Vulnerabilities: Fennodi do not handle cold climates well and are sometimes too trusting of strangers. Fennodi are frequently victimised by bandits, Psi-Stalkers and supernatural menaces - Wild Psi-Stalkers prey on them for their high P.P.E. in particular."
extraction_notes: "THIS CLASS FOLLOWED Rifts World Book 14: New West printed 128-130 UNTIL IT WAS UPDATED TO Rifts World Book 30: D-Bees of North America printed 83-85 (ruling of 2026-10-04: the newest printing that states a figure wins). What D-Bees revised, with the older figure: attacks per melee are three at first level (New West printed 130 gave two); the male has two Healing abilities of choice (New West printed 129 gave three; the female keeps three Physical in both books); the weapon proficiency is W.P. Staff (New West printed 130 gave W.P. blunt/staff, stored as W.P. Blunt); Available O.C.C.s are a third Cowboys and 20% Saddle Tramps, with Wilderness Scout and Adventurer and Scholar added to the list (New West printed 130 gave 50% as 3rd to 6th level Cowboys or Saddle Tramps, 1D4+2, and ended the list with saloon bum, which D-Bees does not restate). New in D-Bees: Vulnerabilities (cold climates, too trusting), Cybernetics and Bionics not possible, M.D.C. by armor or magic only, Money as per O.C.C., and a belt with a wide buckle in the equipment line. Both books print body flip in the Art of Nodox line as a move with no figure; the body_flip bonus of 1 stored before this update matched neither book and was removed. NPC figures with no field: Experience Level 2D4 or as set by the Game Master for NPCs, player characters start at first level; Average Life Span 4D6+55 years, physical maturity at 16, females bear one child after an eight month pregnancy and can bear children until 45; Weight 150 to 200 pounds. D-Bees prints an I.S.P. cost beside each granted power: Empathy 4, Empathic Transmission 6, Mind Block 4, Sixth Sense 2, Telepathy 4, Bio-Manipulation 10. D-Bees printed 85 does not restate the New West parenthesis that a Ghost Walker cannot be touched by telepathy or empathy, nor the word partially; the Ghost Walk text keeps them from New West. THE MALE AND FEMALE PSIONIC PROFILES ARE TWO `special_abilities` ENTRIES BEHIND A `choose: 1`, because `variants` may not override `psionics` and an ability may - `ABILITY_GRANTS` in js/parser.js:1644 is [''bonuses'', ''psionics'', ''magic'']. The two differ in I.S.P. formula (M.E. x2 against x3), in the fifth granted power (empathic transmission against bio-manipulation) and in the category the per-level pick comes from (Healing against Physical). The starting picks are `powers_starting: 2` inside the male profile and `powers_starting: 3` inside the female one. THE PSYCHIC AFFINITY WITH THE WHISKER COYOTE IS NOT A CATALOG POWER and is described in each profile''s text. The combat schedule is transcribed as printed: parry rises at 1, 3, 6, 9, 12 and 15 and dodge at 1, 2, 4, 6, 8, 10, 12 and 14, so the two are on different ladders and `at_level` carries both. Attacks are three at first level, +1 at 2, 4, 6, 8, 10, 12 and 14. This class grants NO related or secondary skills of its own, which is correct for an R.C.C. - they come from the O.C.C. Standard Equipment in D-Bees is as per O.C.C., and most Fennodi also have a Nymbu staff, smoking pipe, tobacco pouch, small knife, belt with a wide buckle and cowboy hat; only the small knife is stored, as the Survival Knife row, and the rest stay in prose. New West printed 130 gave the same list without the belt, as the Fennodi''s own in addition to the O.C.C.''s items, and said many keep a Whisker Coyote as a pet with the G.M.''s agreement, which the D-Bees equipment line does not restate. Money in D-Bees is as per O.C.C.; New West printed none and none is stored. ALLIES (D-Bees): all cowboys, most Native Americans, Lyn-Srial, Cyber-Knights, Reid''s Rangers, Avianes, N''reta and Cactus People. New West gave cowboys, Saddle Tramps, Indians, Cyber-Knights and Sky-Knights. RIVALS AND ENEMIES (D-Bees): Wild Psi-Stalkers, Worm Wraiths, bandits, vampires and supernatural menaces; Simvan chest thump and threaten Fennodi but only come to trade; dinosaurs and other animals are a frequent problem. New West gave none as such."
---

# Fennodi

**Alignments.** Any, but predominantly good - four in five - with about one in
ten aberrant.

Not every D-bee is a devouring terror from another world. The Fennodi are the
peaceful ones: a quiet, gentle people who abhor violence and wander the prairies
and deserts of the west tending small herds of cattle and other livestock.

The Shoshone call them the Quiet Walkers, because the tall, thin aliens move
silently, like a summer breeze.

## Appearance

Pale grey with light tan accents, and typically about seven feet tall, slender,
with long thin fingers, arms and legs. The eyes are tiny black dots set on small
fins at the sides of the head, which most people mistake for ears - the real
ears are slits behind them. Along the jaw on each side is a flap of skin with
three whisker-like fins, and behind each flap three holes that make up a very
sensitive nose. The mouth is a small slit just above the chin, and the large
ridged cranium gives them a long head with few human features - some people say
they look like catfish.

## Company

Most Fennodi of either sex are nomads who like to wander, love the land, tend
livestock and mind their own business. They are friends to all cowboys, most
Indians and the Lyn-Srial, and welcome anyone who comes in peace - even Wild
Psi-Stalkers, who prey on them.

They are often accompanied by a Whisker Coyote, a small psionic dog-like
creature from the Rifts that has adapted well to the southwestern deserts. Their
other constant companions are the sacred crescent-shaped Nymbu staff, a sign of
peace and travel, and a smoking pipe.

They are fond of horses, cowboy hats, boots, vests and the general look of the
cowboy, which is where the other nickname comes from.

## Lore

Also known as the Cowboy Alien and the Quiet Walker; pronounced *Fen no dee*.
A third of them are Cowboys and a fifth are Saddle Tramps, and the rest can be
any type of Vagabond, Rogue Scholar, Rogue Scientist, Body-Fixer, Operator,
Preacher, Wilderness Scout, or Adventurer and Scholar. They find towns
interesting for a short visit and much prefer the wilderness, particularly light
forests, grasslands, prairies, canyons and deserts. They prefer warm, dry
climates and inhabit the deserts and plains of the American Southwest; some
travel up into the Canadian Southwest, but most migrate south for the winter.
',
       updated_at = datetime('now')
 WHERE class_id = 'fennodi'
   AND instr(markdown, 'source_book: Rifts World Book 14: New West p.128-130') > 0
   AND length(markdown) = 9393;

-- == lyn-srial ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial
name: Lyn-Srial
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.127-129
category: rcc
tags: [flyer]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spells: ["Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Surfing", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Globe of Daylight"]
  spells_from: ["Clouds of Defense: Blinding Flash", "Clouds of Defense: Clouds of Light Deflection", "Clouds of Defense: Cloud of Darkness", "Clouds of Defense: Cloud Rider Armor", "Clouds of Defense: Cloud Shield", "Clouds of Defense: Fog of War", "Clouds of Defense: Storm Rider Armor", "Clouds of Travel: Blink of an Eye", "Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Portal", "Clouds of Travel: Cloud of Speed", "Clouds of Travel: Cloud Surfing", "Clouds of Travel: Fly Like The Wind", "Clouds of Travel: Portal to the Beyond", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Breath of Life", "Clouds of Survival: Calm Storms", "Clouds of Survival: Cloud of Healing", "Clouds of Survival: Globe of Daylight", "Clouds of Survival: Hunter''s Instinct", "Clouds of Survival: See the Invisible", "Clouds of Survival: See the Light", "Clouds of Survival: Tongues", "Clouds of Survival: Warmth of the Sun"]
bonuses:
  combat: { attacks: 3, initiative: 1, perception: 1, parry: 1, pull_punch: 2, roll: 3 }
  saves: { horror_factor: 4 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks the Lyn-Srial tongue at 98%." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Reads it at 98% too." }
    - { name: "History", base: 90, per_level: 0, note: "Printed as History of their People at a flat 90% - the Lyn-Srial''s own history rather than Earth''s. Stored on the generic History row rather than inventing a Lyn-Srial one." }
    - { choose: 3, from: ["Language: Other"], bonus: 30, note: "Language: Other: American and two of choice (+30%). One of the three picks is American." }
    - { choose: 2, from: ["Literacy: Other"], bonus: 10, note: "Literacy: Other: two of choice (+10%)." }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+10%. Printed as Lore: Ley Lines & Magic." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Whittling & Sculpting", base: 45, per_level: 5, note: "+15%. Printed as Whittle/Sculpt." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to Hand: Basic; cannot be changed." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", bonus: 10 }
      - { name: "Physical", except: ["Boxing"], note: "Any Physical skill except Boxing. Hand to Hand: Basic is an R.C.C. skill and cannot be changed." }
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], note: "Printed as Read Sensory Equipment and Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Rogue", only: ["Ventriloquism", "Computer Hacking"] }
      - { name: "Science", bonus: 15 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies", only: ["W.P. Handguns", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "Any ANCIENT W.P.; of the MODERN ones, Handguns, Energy Pistol and Energy Rifle only. The catalog does not mark a W.P. ancient or modern, so the ancient ones are listed." }
      - { name: "Wilderness", bonus: 5 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES; the sheet has no field for either." }
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "sculpting-tools-case", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
restrictions:
  - "Cowboy, Espionage, Military and Pilot are closed as related categories."
  - "Never uses a vehicle or a riding animal."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
  - "Starts with no weapons."
  - "Also starts with personal jewelry (armbands, bracelets, necklaces, mantles and similar), a loincloth, a whittling knife and a purse; the canteen may be a water skin instead."
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "This class followed Rifts World Book 14: New West printed 133-134 (experience table on its unnumbered page 224) until it was updated to the 2007 printing in Rifts World Book 30: D-Bees of North America printed 127-129 (ruling of 2026-10-04: the newest printing that states a figure wins). WHAT D-BEES REVISED. Bonus line: D-Bees printed 129 gives +3 attacks per melee round in addition to those of the Hand to Hand skill, and +1 on Perception Rolls; New West printed 133 gave three attacks per melee round plus those gained from optional Hand to Hand: Basic (stored then as attacks: 1) and printed no Perception bonus. Hand to Hand: D-Bees printed 128 lists Hand to Hand: Basic among the R.C.C. skills and says it cannot be changed, stored as the skill with an empty hand_to_hand cost list; New West printed 134 left it optional, a related Physical pick (only Hand to Hand: Basic can be selected from the combat skills). Languages: D-Bees prints Language: Other: American and two of choice (+30%); New West printed 134 gave speak three Earth languages (+30%). The catalog holds no American language row, so the group stays three picks of Language: Other and the note names American as one of them. W.P.: D-Bees adds Handguns to the modern proficiencies; New West printed 134 gave Any W.P. Ancient, and W.P. Energy Pistol and Rifle only. Experience: D-Bees printed 129 says to use the same Experience Table as the Operator, so xp_table is copied from the stored operator class (Rifts Ultimate Edition); New West printed 224 gave the Lyn-Srial Average Citizen its own column, shared with the Cowboy, which differs only at level 6: 21,301 where the Operator has 21,001. Secondary skills: both books give two at levels 1, 4, 8, 10 and 12; D-Bees draws them from the Secondary Skill List on page 300 of Rifts Ultimate Edition, where New West drew them from the related list above, excluding the categories marked None. Life span: D-Bees gives 1D6x10+135 years, physical maturity by 17, 1D4 live young after a 10 month pregnancy, and child-bearing until 70; New West printed 133 gave approximately 150-200 years, some living to 350, most elders 160 and up. Alignment: D-Bees splits New West''s 80% principled or scrupulous into Principled 50% and Scrupulous 30%, with Aberrant 10%. D-Bees marks P.S. and P.E. as Supernatural on the attribute line and prints Damage: as per Supernatural P.S. or by weapon or magic; the dice are unchanged. NEW IN D-BEES, no field: Vulnerabilities (stored as side_effects); experience level 1D6 for NPCs; Slave Market Value 3D4x10,000 credits, valued as warriors, guards and gladiators; allies are Cyber-Knights, Justice Rangers, Arzno and the Tolkeen refugees; they regard the Coalition States and the Federation of Magic with disappointment and apprehension; most numerous in Arizona, Utah and New Mexico. Available O.C.C.s: not applicable. BOTH BOOKS PRINT, added with this update: +2 to dodge when in flight (a conditional bonus, stored as a special ability), and the pocket mirror, sculpting tools and air filter of the equipment line. The personal jewelry, loincloth, whittling knife and purse of that line have no catalog row and are a restrictions line; the canteen or water skin is stored as the canteen. UNCHANGED BETWEEN THE PRINTINGS: attribute dice, M.D.C., Awe Factor, P.P.E., natural abilities, the four known spells and the one-per-3-I.Q. picks, the other R.C.C. skills and their bonuses, the related categories and their bonuses, the related-skill schedule, money, and the cybernetics line. FROM THE ORIGINAL IMPORT: THIS IS THE FIRST CLASS TO CONSUME THE CLOUD MAGIC SPELLS imported in PR #881, and the category prefix is what makes its magic expressible. The four granted spells are named outright. The additional picks are ONE PER 3 POINTS OF I.Q. from Clouds of Defense, Travel and Survival - an attribute-derived COUNT, which `spells_starting` cannot express because it takes a number. The three categories are given as `spells_from`, which per the frontmatter reference REPLACES the spell-level gate, so the pool is exactly right and only the count is prose. Divide the character''s I.Q. by three at creation. The Globe of Daylight granted is the Clouds of Survival one, because the character''s three categories are Defense, Travel and Survival and the Creation copy is out of scope for them. `attribute_dice.Spd` is the GROUND speed; flying is 3D6+20 and is in the four-arms natural ability, since one attribute cannot hold two values. AWE FACTOR, not Horror Factor - the book prints Awe, and there is no field for either, so it is a natural ability. ''History of their People at 90%'' is stored on the generic `History` row at a flat 90 rather than inventing a Lyn-Srial history row. This catalog does not mark a proficiency ancient or modern, so the ancient ones are enumerated and the three modern ones added. 55% of all Lyn-Srial females become Cloudweavers, which is a fact about the race rather than a mechanic."
---

# Lyn-Srial

**Alignments.** Any, but four in five are principled or scrupulous, one in ten
aberrant and one in ten something else. Very few ever turn selfish, and a
diabolic or miscreant Lyn-Srial is almost unheard of.

The Lyn-Srial - the Golden Ones - are a race of bird-like, golden-skinned
humanoids from a dimension of mountains, towering bluffs, cloud cities and
endless blue-green sky. They are a peaceful people who have given their lives to
helping others end violence and find peace as they have.

Not every Lyn-Srial is a Sky-Knight, a Cloudweaver or an adventurer, but nearly
all share the same ethics and goals. Many are artists of one kind or another and
all of them are creative and imaginative. Most have dedicated themselves to
helping others and to the pursuit of knowledge, art, beauty, and peace of mind
and spirit.

## Body

Seven to eight feet tall and two hundred to three hundred and twenty pounds,
with four arms - a bat-like membrane between one pair lets them fly, and glide
at half that speed. The average life span is 1D6x10+135 years, and
physical maturity comes by the age of seventeen.

They can be found anywhere in the Americas but are most numerous in the
Southwest, and keep a hidden city in the Grand Canyon. They are most at home
among canyons, buttes, mountains and clouds.

## Lore

Also known as the Golden Ones. Their magic is Cloud Magic, which is theirs
alone - the section on Arizona covers the people, their society and their hidden
city in more detail. The average Lyn-Srial is not trained to fight and shies
away from violence.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, 'source_book: Rifts World Book 14: New West p.133-134') > 0
   AND length(markdown) = 9597;

-- == lyn-srial-sky-knight ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial-sky-knight
name: Lyn-Srial Sky-Knight
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.129-130
category: rcc
tags: [combat, flyer]
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]
copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions", "xp_table"] }
attribute_requirements: { IQ: 18, ME: 18 }
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spell_traditions_allowed: ["cloud"]
  spells: ["Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Surfing", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Globe of Daylight", "Clouds of Defense: Storm Rider Armor", "Clouds of War: Cloud Blast", "Clouds of War: Cloud Disc", "Clouds of War: Clouds of Imprisonment", "Clouds of War: Cloud Lance", "Clouds of War: Cloud Sword", "Clouds of War: Cloud Whip", "Clouds of War: Fiery Cloud", "Clouds of War: Poisonous Cloud", "Clouds of War: Rolling Thunder", "Clouds of War: Storm Cloud", "Clouds of War: Storm Cloud Sword", "Clouds of War: Wind Hammer", "Clouds of War: Wind Spear", "Clouds of Peace: Cloud of Harmony", "Clouds of Peace: Cloud Haven", "Clouds of Peace: Fog of Peace", "Clouds of Peace: Healing Rain", "Clouds of Peace: Winds of Change", "Clouds of Peace: Winds of Regret"]
  spell_lists:
    any_but_creation:
      - "Clouds of War: Cloud Blast"
      - "Clouds of War: Cloud Disc"
      - "Clouds of War: Clouds of Imprisonment"
      - "Clouds of War: Cloud Lance"
      - "Clouds of War: Cloud Sword"
      - "Clouds of War: Cloud Whip"
      - "Clouds of War: Fiery Cloud"
      - "Clouds of War: Poisonous Cloud"
      - "Clouds of War: Rolling Thunder"
      - "Clouds of War: Storm Cloud"
      - "Clouds of War: Storm Cloud Sword"
      - "Clouds of War: Wind Hammer"
      - "Clouds of War: Wind Spear"
      - "Clouds of Defense: Blinding Flash"
      - "Clouds of Defense: Clouds of Light Deflection"
      - "Clouds of Defense: Cloud of Darkness"
      - "Clouds of Defense: Cloud Rider Armor"
      - "Clouds of Defense: Cloud Shield"
      - "Clouds of Defense: Fog of War"
      - "Clouds of Defense: Storm Rider Armor"
      - "Clouds of Peace: Cloud of Harmony"
      - "Clouds of Peace: Cloud Haven"
      - "Clouds of Peace: Fog of Peace"
      - "Clouds of Peace: Healing Rain"
      - "Clouds of Peace: Winds of Change"
      - "Clouds of Peace: Winds of Regret"
      - "Clouds of Travel: Blink of an Eye"
      - "Clouds of Travel: Cloud of Ascension"
      - "Clouds of Travel: Cloud Portal"
      - "Clouds of Travel: Cloud of Speed"
      - "Clouds of Travel: Cloud Surfing"
      - "Clouds of Travel: Fly Like The Wind"
      - "Clouds of Travel: Portal to the Beyond"
      - "Clouds of Survival: Aerial Navigation"
      - "Clouds of Survival: Breath of Life"
      - "Clouds of Survival: Calm Storms"
      - "Clouds of Survival: Cloud of Healing"
      - "Clouds of Survival: Globe of Daylight"
      - "Clouds of Survival: Hunter''s Instinct"
      - "Clouds of Survival: See the Invisible"
      - "Clouds of Survival: See the Light"
      - "Clouds of Survival: Tongues"
      - "Clouds of Survival: Warmth of the Sun"
      - "Clouds of the Mind: Cloud of Insanity"
      - "Clouds of the Mind: Clouds of Truth"
      - "Clouds of the Mind: Mind Fog"
      - "Clouds of the Mind: Mind Over Matter"
      - "Clouds of the Mind: Mist of Illusion"
      - "Clouds of the Mind: Spirit Mist"
      - "Clouds of the Mind: Warrior''s Mist"
  spells_starting: 1
  spells_starting_groups:
    - { count: 1, from_list: "any_but_creation", note: "One more spell from any category except Clouds of Creation, from level one (D-Bees printed 129)." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "any_but_creation" }
    - { level: 3, count: 1, from_list: "any_but_creation" }
    - { level: 4, count: 1, from_list: "any_but_creation" }
    - { level: 5, count: 1, from_list: "any_but_creation" }
    - { level: 6, count: 1, from_list: "any_but_creation" }
    - { level: 7, count: 1, from_list: "any_but_creation" }
    - { level: 8, count: 1, from_list: "any_but_creation" }
    - { level: 9, count: 1, from_list: "any_but_creation" }
    - { level: 10, count: 1, from_list: "any_but_creation" }
    - { level: 11, count: 1, from_list: "any_but_creation" }
    - { level: 12, count: 1, from_list: "any_but_creation" }
    - { level: 13, count: 1, from_list: "any_but_creation" }
    - { level: 14, count: 1, from_list: "any_but_creation" }
    - { level: 15, count: 1, from_list: "any_but_creation" }
bonuses:
  attributes: { PS: "1d6" }
  combat: { attacks: 4, initiative: 3, perception: 4, parry: 1, roll: 4, pull_punch: 4, disarm: 3 }
  saves: { horror_factor: 1 }
  pools: { mdc: "2d6+6", ppe: "1d4x10" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { name: "Literacy: Native Language", base: 98, per_level: 0 }
    - { name: "History", base: 90, per_level: 0, note: "Printed as History of their People at a flat 90%." }
    - { choose: 3, from: ["Language: Other"], bonus: 30, note: "Language: Other: American and two of choice (+30%)." }
    - { choose: 2, from: ["Literacy: Other"], bonus: 10, note: "Literacy: Other: two of choice (+10%)." }
    - { name: "Lore: Magic", base: 35, per_level: 5, note: "+10%. Printed as Lore: Ley Lines & Magic." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Whittling & Sculpting", base: 45, per_level: 5, note: "+15%. Printed as Whittle/Sculpt." }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "W.P. one ANCIENT weapon of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. one energy weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be traded up to Martial Arts for one R.C.C. Related skill." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", only: ["Intelligence", "Tracking (people)"], bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics"], bonus: 5 }
      - { name: "Medical", bonus: 10 }
      - { name: "Military", except: ["Trap Construction", "Trap/Mine Detection", "Parachuting", "NBC Warfare"], bonus: 5 }
      - "Physical"
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], bonus: 10, note: "Printed as Read Sensory Equipment & Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Rogue", only: ["Ventriloquism", "Streetwise", "Computer Hacking"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES; the sheet has no field for either." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: 12 }
starting_money: "3d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
restrictions:
  - "Cowboy and Pilot are closed as related categories, and Military excludes the trap skills, Parachuting and NBC Warfare."
  - "Rarely uses a vehicle or a riding animal."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
  - "The +2 to dodge applies only when in flight, and the book prints a +3 to disarm on a called shot beside the plain +3 to disarm. Neither of those two conditional figures (the dodge in flight and the called-shot disarm) is in the bonus totals; the plain +3 to disarm is."
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "This class followed Rifts World Book 14: New West printed 134-135 (experience table on its printed 224) until it was brought up to the 2007 reprint, D-Bees of North America printed 129-130, under the ruling of 2026-10-04 that the newest printing which states a figure wins. WHAT D-BEES REVISED, with the New West figure kept here. ATTACKS: New West printed 135 gave four attacks per melee round, plus those gained from hand to hand combat, stored as attacks 2; D-Bees prints Attacks per Melee as per Hand to Hand Combat skill and bonuses and puts +4 attacks per melee round in the bonus line, stored as attacks 4. M.D.C. BONUS: New West +2D6, D-Bees +2D6+6. PERCEPTION: New West printed none, D-Bees +4 to Perception Rolls. DISARM: New West printed only +3 to disarm on a called shot; D-Bees prints +3 to disarm and then +3 to disarm on a called shot, so the plain +3 is the stored bonus and the called-shot line is a restriction line. DODGE: both books print +2 to dodge when in flight; it is conditional, so it is a restriction line and not a bonus (the row stored it as an unconditional dodge 2 until this update). R.C.C. SKILLS: New West printed 135 gave the Sky-Knight its own list - three Earth languages (+30%), Lore: one of choice (+10%), Land Navigation (+20%), Sing & Whistle (+15%), Art (+15%), and neither Holistic Medicine nor Identify Fruit and Plants. D-Bees printed 129 says same as the average Lyn-Srial citizen plus the two fixed W.P.s, the two W.P.s of choice and Hand to Hand: Expert, so the list is now the average citizen list of D-Bees printed 128: Language: Other: American and two of choice (+30%), Lore: Ley Lines & Magic (+10%) on the Lore: Magic row, Land Navigation (+10%), Sing & Whistle (+20%), Art (+20%), Holistic Medicine (+10%), Identify Fruit and Plants (+20%). The catalog holds no American language row, so the three languages stay three picks of Language: Other with the printed wording in the note. The average citizen line Hand to Hand: Basic, cannot be changed, is replaced by the Sky-Knight line Hand to Hand: Expert. RELATED SKILLS: New West printed Physical: Any, except boxing; D-Bees prints Physical: Any. Every other category line is the same in both books. SECONDARY SKILLS: D-Bees says same as above, which is the average citizen line - two from the Secondary Skill List on page 300 of Rifts Ultimate Edition at levels 1, 4, 8, 10 and 12; New West drew them from the related list above, excluding the categories marked None. The counts are the same. EXPERIENCE: New West printed 224 gives a Lyn-Srial Sky-Knight ladder of its own - 0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301 (misprinted 18,301), 231401, 281501, 341601. D-Bees printed 130 says to use the same experience table as the Cyber-Knight, so `xp_table` is copied from the stored `cyber-knight` row (Rifts Ultimate Edition); the two ladders differ only at level 10, 96101 against 96001. D-Bees also prints an N.P.C. experience level of 2D4. WHAT D-BEES DOES NOT RESTATE, kept from New West: Money (3D6x100 in tradeable goods, New West printed 135; the average citizen in D-Bees printed 129 has 2D6x100), rarely uses a vehicle or riding animal (the average citizen in D-Bees never does), and the cybernetics line. Attributes, M.D.C., P.P.E., Awe Factor and natural abilities are the average citizen figures in both books and are the same in both. MAGIC: both books open the list with Cloud of Ascension, Cloud Surfing, Aerial Navigation, Globe of Daylight and Storm Rider Armor before all Clouds of War and Clouds of Peace; those five were missing from `spells` until this update. EQUIPMENT is the same list in both books; the pocket mirror, the large wooden cross and the twelve wooden stakes were added in this update from catalog rows. `copy_of` records that New West printed 134 and D-Bees printed 129 define this class as the Average Lyn-Srial for alignment, attributes and all basic stats, and then replaces magic, skills, bonuses and equipment. The copied halves are repeated in full because nothing composes one class from another; the `except` list names what differs. THE MAGIC IS THE POINT OF THIS CLASS: the five named spells, all thirteen Clouds of War and all six Clouds of Peace outright, plus one more spell per level from any category EXCEPT Clouds of Creation - which is 50 of the 58 rows, declared once as `spell_lists.any_but_creation`. That exclusion is only expressible because the spells carry their category in the name; under a tradition prefix it could not be written at all. The level-one pick is a starting group and levels 2-15 are `spells_schedule` entries, both drawing from that list; until BOOK-INGEST-AUDIT.md F59 the list was `spells_from` with no starting count, so it bounded nothing and every level-up could reach Clouds of Creation. THE +1D6 TO P.S. IS IN `bonuses.attributes`, where a dice string is rolled once at creation and stored on the character - the same path a Juicer''s +2D6 P.S. takes. It was first stored as `special_abilities` prose on the strength of BOOK-INGEST-AUDIT.md F52, which claimed a dice bonus there was silently dropped; F52 was FALSIFIED and closed on 2026-09-10 and this class was corrected in the same PR. The +2D6+6 M.D.C. and +1D4x10 P.P.E. ARE in `bonuses.pools`, which does take dice (js/dice.js:221, js/parser.js:1454). Standard Equipment stores only the catalog rows that exist; the book also lists personal jewelry, the Sky-Knight''s golden chest plate at 25 M.D.C. (more symbolic than functional), a chain mail loin cloth, a whittling knife, and one weapon per W.P. plus a matched pair of one type."
---

# Lyn-Srial Sky-Knight

**Alignments.** As the Average Lyn-Srial: four in five principled or scrupulous,
one in ten aberrant.

The Sky-Knight is the Lyn-Srial warrior for peace. These noble fighters battle
only to protect others, to destroy evil and the supernatural, and to bring
justice and wisdom to the world in the pursuit of peace.

In many ways they are philosopher knights, trying to instil values in everyone
they meet and to be living examples of what friendship, brotherhood and love can
achieve. They are often taken for avenging angels or warriors of light who fight
for the innocent and the underdog. They stand against evil in all its forms, and
while they show respect and understanding to all peoples, religions and nations,
they will stand against any of them known to be evil or to crush people''s
spirits.

All Sky-Knights are accomplished magic users, and will use magic to avoid or
defuse a fight before using force to finish one. They are courageous in battle
and tender in life.

## Lore

Also known as the Philosopher Knight, the Golden One and the Hope Bringer. They
are the personification of the ideal the word *knight* stands for.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, 'source_book: Rifts World Book 14: New West p.134-135') > 0
   AND length(markdown) = 13409;

-- == pogtalian-dragon-slayer ==
UPDATE imported_classes
   SET markdown = '---
id: pogtalian-dragon-slayer
name: Pogtalian Dragon Slayer
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.156-159
category: rcc
tags: [hunter, supernatural, wilderness]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
attribute_dice:
  IQ: "3d6+1"
  ME: "4d6"
  MA: "3d6"
  PS: "5d6+10"
  PP: "4d6+2"
  PE: "4d6+6"
  PB: "1d6+1"
  Spd: "4d6"
mdc_base: "P.E. + 1d4x100, +1d6 per level"
ppe_base: "2d6x10"
starting_money: "2d6x1000"
psionics_allowed: false
bonuses:
  combat: { attacks: 1, strike: 2, parry: 1, dodge: 2, initiative: 3, perception: 2, pull_punch: 2 }
  saves: { spell_magic: 3, psionics: 3, horror_factor: 5 }
skills:
  occ_skills:
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Language: Native Tongue", base: 94, per_level: 0, note: "Pogtalian at 94%." }
    - { name: "Language: Spanish", base: 65, per_level: 5, note: "Printed as Language: Other: Spanish (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Skin & Prepare Animal Hides", base: 50, per_level: 5, note: "+20% for large animals, as stored; the book gives only +10% (40%) for small animals." }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed as Track (people; +10%)." }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Printed as Track Animals (+20%), including dragons and dinosaurs." }
    - { name: "Wilderness Survival", base: 55, per_level: 5, note: "+25%" }
    - { choose: 1, from: ["W.P. Archery", "W.P. Targeting"], note: "W.P. Archery or W.P. Targeting." }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { choose: 3, from: ["W.P. Archery", "W.P. Axe", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: Three Ancient Weapons of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed; W.P. Blunt is already granted." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Handguns", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"], note: "W.P.: Two Modern Weapons of choice." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Communications", only: ["Barter", "Public Speaking", "Radio: Basic", "Language: Dolphin/Whale", "Literacy: Euro", "Literacy: Gypsy", "Literacy: Native Language", "Literacy: Other", "Literacy: Russian", "Literacy: Techno-Can"], note: "Barter, Language, Literacy, Public Speaking and Radio: Basic only. Most languages are Technical rows, which are open in full." }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Detect Ambush", "Interrogation", "Tracking (people)", "Sniper", "Intelligence"], bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics"], bonus: 10 }
      - { name: "Pilot", only: ["Boat: Motor, Race & Hydrofoil", "Boat: Paddle Types/Canoe/Kayak", "Boat: Sail Type", "Boat: Ships", "Boat: Submersibles"], note: "Boats only." }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy", "Astronomy & Navigation"], bonus: 5 }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Five other skills at first level and two more at levels 3, 6, 9, 12 and 15; all new skills start at level one proficiency. Cowboy, Mechanical, Military, Pilot Related and Rogue are printed as None, and Electrical is not listed. The Physical +10% applies only where a skill has a percentage."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
    note: "Two Secondary Skills from the Secondary Skill List on page 300 of Rifts Ultimate Edition at each of levels 2, 4, 8 and 12, at the base skill level; no bonuses other than a possible high I.Q. bonus."
natural_abilities:
  - { name: "Supernatural Attributes", description: "P.S. and P.E. are supernatural. Damage is as per Supernatural P.S. or by weapon." }
  - { name: "Mega-Damage Being", description: "1D4x100 M.D.C. plus the P.E. attribute number, and 1D6 M.D.C. per level of experience. On S.D.C. worlds: 1D4x100 S.D.C., and Hit Points equal to P.E. x5 plus 2D6 per level." }
  - { name: "Impervious to Fire and Cold", description: "Impervious to magic fire (dragon fire and magic M.D. fire included) and to normal fire and cold." }
  - { name: "Bio-Regeneration", description: "With but a thought, instantly restores 1D6x10 M.D.C., three times per 24 hours. Otherwise lost M.D.C. recovers at 1D6 per hour." }
  - { name: "Regrowing Teeth", description: "Printed under Deadly Maw (special). The mouth is lined with teeth the size of short swords; a lost tooth grows back in about two weeks." }
  - { name: "Unhinging Jaw and Bite", description: "Printed under Deadly Maw (special). The jaw unhinges like a snake''s, so it cannot be broken, and opens for a bite about 4x4x4 feet (1.2 x 1.2 x 1.2 m) doing 6D6 M.D. The giants have been known to bite off the hand and forearm of a power armor, or a chunk out of a giant robot, in a single bite. Not usable inside Dragon Death power armor." }
special_abilities:
  - name: "Energy Aura"
    description: "An invisible energy field that switches on by itself, like an adrenaline rush, the moment the giant is frightened, angry, excited or exerting himself. It adds 100 M.D.C. that takes damage first, covers whatever the giant wears or holds, and recovers within 24 hours. It also turns ordinary hand-held S.D.C. weapons and material into M.D.C. extensions of the giant for as long as he holds them: a strike with an S.D.C. giant sword, club, dagger or uprooted tree does the giant''s usual Supernatural P.S. punch damage, and a magic weapon does its own damage or the punch damage, whichever is greater. This holds even when the aura''s M.D.C. protection is gone; S.D.C. weapons remain M.D. A Pogtalian can extend the field around a suit of Dragon Death power armor (South America printed 141), where it is the suit''s 100-M.D.C. force-field location; no other race can."
trackable_resources:
  - { key: energy_aura, label: "Energy Aura M.D.C.", max: 100, reset_on: day, note: "Taken before the giant''s own M.D.C.; restored within 24 hours." }
  - { key: bio_regeneration, label: "Bio-Regeneration", max: 3, reset_on: day, note: "Each use restores 1D6x10 M.D.C. instantly." }
equipment_starting:
  - { item_id: "dragon-skin-armor", qty: 1 }
  - { choose: 4, label: "giant-sized melee weapon", qty: 1, from: ["broadsword", "long-sword", "axe-battle", "war-club", "mace", "war-hammer"], note: "The book gives a giant-sized melee weapon for each W.P.: one for W.P. Blunt and one for each of the three ancient W.P.s. These are the catalog''s human-sized rows; a giant weapon typically does two dice of damage more." }
restrictions:
  - "Available O.C.C.s: none. Pogtal are what they are."
  - "Magic: none. Psionics: none."
  - "Standard equipment is a giant-sized melee weapon for each W.P. A giant weapon typically does two dice of damage more than the human-sized equivalent, and many Pogtal weapons are made from the bones of the dragons and monsters they slay. May also use giant-sized modern guns, Vibro-Blades, magic weapons and other specially made giant-sized gear."
  - "Dragon Skin Armor: Pogtal Giants prefer the traditional Dragon Slayers'' body armor made from the prepared skin of a dragon, 2D6x10+100 M.D.C.; a suit reinforced with M.D.C. bone plates or ribbing, chitinous exoskeleton or metal plates has 3D6x10+140 M.D.C. It weighs 600 to 1200 pounds (270 to 540 kg). Armor penalties: reduce Spd by 30%, Prowl is impossible, and Climbing, Gymnastics, Swimming and similar Physical skills are -20%. Worth 600,000 to one million credits. Dragons and many other people find it abhorrent."
  - "Custom Made Modern Armor: giant-size armor for a wearer 13 to 16 feet tall costs three times the normal price, weighs three times as much and gives three times the M.D.C. Truly giant armor, 17 to 28 feet, costs eight times the normal price, gives eight times the M.D.C. and weighs ten times as much; reduce speed by 1/3 and prowl is impossible. It can be built only where body armor or giant robots are made."
  - "Besides 2D6x1000 credits, starts with 3D6x1000 credits'' worth of tradeable goods (probably dragon teeth or claws)."
  - "Size: 3D6+10 feet tall. Weight: 1D6x1000 lbs. Average life span: 3D6x10+150 years; physical maturity at age 30."
  - "Starts with no cybernetics or bionics, but is not opposed to getting a bionic limb if the original is lost in combat."
side_effects: "Giant size is a liability: most opponents assume the giant is the greatest danger and target him first, he is hard to conceal, and his gruesome appearance may make people flee in terror or attack. His size and mass can make small, light bridges impassable and narrow streets or alleys difficult, and he may not fit into human-sized dwellings and buildings. Going into Coalition territory is dangerous, and going into the ''Burbs or near any Coalition city or military base is likely to scramble 1D6 SAMAS and Quick Response teams to destroy the monster. Most people in South America take a Pogtalian for a dangerous D-bee monster. Manoans and Omaguans attack one on sight unless he travels with other humanoids and takes care not to look threatening, which does not come naturally to the species. Pogtalians have been known to eat humanoid flesh (never their own kind''s), which does not help."
extraction_notes: |
  - This class followed Rifts World Book 6: South America printed 135-136 until
    this update; by the ruling of 2026-10-04 (the newest printing that states a
    figure wins, and the older figure is kept here) it now follows Rifts World
    Book 30: D-Bees of North America printed 156-159 (cache p157-p160, cache
    page = printed folio + 1), where the entry is headed Pogtal Giants and its
    stat block Pogtal Dragon Slayer - Optional Player Character and NPC. Both
    entries were read off page renders. The class id and name are unchanged:
    D-Bees itself opens "Pogtalian Dragon Slayers are most numerous in South
    America" and lists Pogtal, Pogtal Giants, Pogtal Dragon Slayers and Giant
    Monster Slayers as other names. D-Bees closes by noting the race first
    appeared in World Book One: Vampire Kingdoms as the Bonecruncher NPC and as
    an R.C.C. in World Book 6: South America.
  - HORROR FACTOR: South America printed 135 gave Horror Factor 12. D-Bees
    restates the stat block and prints no Horror Factor line, so none is stored.
  - ATTRIBUTES: the dice are the same in both books. South America printed 135
    said the attributes are considered supernatural; D-Bees marks only P.S. and
    P.E. Supernatural.
  - POOLS: South America printed 135 gave M.D.C. 1D4x100 flat, and in S.D.C.
    environments 1D4x100 S.D.C. with Hit Points P.E. x5 plus 1D6 per level.
    D-Bees prints 1D4x100 plus the P.E. attribute number and 1D6 M.D. per
    level, and on S.D.C. worlds 1D4x100 S.D.C. with P.E. x5 plus 2D6 per level
    for Hit Points; the S.D.C.-world figures are in the natural-ability text.
    D-Bees prints P.P.E. 2D6x10, stored; South America printed none. No I.S.P.
    is printed. men_of_arms is not stated because mdc_base is.
  - BONUSES: D-Bees''s bonus line is +1 attack per melee, +3 initiative, +2
    Perception, +2 strike, +1 parry, +2 dodge, +2 pull punch, +3 save vs magic,
    +3 vs psionic attacks, +5 vs Horror Factor. South America printed 135 had
    no Perception, strike or pull punch bonus, and tied the +1 parry, +2 dodge
    and +3 initiative to supersensitive hearing equal to cybernetic amplified
    hearing; D-Bees''s natural abilities and bonus lines do not mention the
    hearing, so that natural ability is no longer stored. Attacks per melee
    are as per Hand to Hand and bonuses.
  - NATURAL ABILITIES: D-Bees adds recovery of 1D6 M.D.C. per hour beside the
    three-a-day instant bio-regeneration, and names the teeth and jaw Deadly
    Maw (special); the two stored ability names are kept and each says so. The
    bite is printed 4x4x4 feet in D-Bees (South America: four foot by four
    foot); South America had it snap off an entire hand from power armor or
    bots, D-Bees the hand and forearm of power armor or a chunk out of giant
    robots. The line about Dragon Death power armor comes from South America
    printed 141 and D-Bees does not restate it.
  - ENERGY AURA: unchanged apart from D-Bees''s added sentence that S.D.C.
    weapons remain M.D. even when the aura''s M.D.C. is gone. The 100 M.D.C. is
    a trackable resource reset daily; BIO-REGENERATION is three uses per day.
    The Dragon Death power armor extension is South America''s (printed 141,
    vehicle row dragon-death-power-armor); D-Bees does not restate it.
  - PSIONICS AND MAGIC: D-Bees prints Psionics: None and Magic: None; South
    America printed neither line. psionics_allowed is false; Magic: None is a
    restrictions line. Available O.C.C.s: None is a restrictions line.
  - R.C.C. SKILLS: South America printed 135 gave hunting, wilderness survival
    +25%, land navigation +20%, track animals +20%, skin and prepare animal
    hides +20%/+10%, hand to hand: martial arts, swimming +10%, W.P. Targeting,
    W.P. Blunt and two W.P.s of choice (archaic if native to Pogtalia, any if
    trained in Cibola). D-Bees keeps those percentages and adds Language:
    Native Tongue (Pogtalian at 94%, stored at 94 against the catalog''s 98),
    Language: Other: Spanish +15% (Language: Spanish 50+15), Lore: Demons &
    Monsters +10% (25+10) and Track (people) +10% (Tracking (people) 25+10);
    turns W.P. Targeting into W.P. Archery or W.P. Targeting; and replaces the
    two W.P.s of choice with three Ancient and two Modern, each a named list
    because the catalog does not split W.P.s into ancient and modern. Skin &
    Prepare Animal Hides is stored at the large-animal figure with the small
    one in the note. Track Animals maps to Track & Trap Animals. Hand to Hand:
    Martial Arts is granted outright and no upgrade price is printed, so there
    is no hand_to_hand block.
  - R.C.C. RELATED SKILLS: South America printed 135-136 gave six at first
    level; D-Bees gives five, with the same two at levels 3, 6, 9, 12 and 15.
    South America''s list was Communications: radio basic and scrambler only;
    Domestic any (+10%); Espionage: tracking, sniper, intelligence only (+10%);
    Mechanical none; Medical first aid or holistic medicine only; Military
    none; Physical any except acrobatics (+10% when applicable); Pilot any if
    trained in Cibola, otherwise horsemanship and boats only; Pilot Related and
    Rogue any if trained in Cibola, none otherwise; Science math and astronomy
    only; Technical languages, literacy and lore only; W.P. any; Wilderness
    any (+10%). D-Bees prints Communications: Barter, Language, Literacy,
    Public Speaking, Radio: Basic only; Cowboy none; Domestic any (+5%);
    Espionage: Detect Ambush, Interrogation, Tracking, Sniper, Intelligence
    only (+10%); Horsemanship: Exotic Animals only; Mechanical none; Medical
    First Aid or Holistic Medicine only; Military none; Physical any except
    Acrobatics (+10% when applicable); Pilot: Boats only; Pilot Related none;
    Rogue none; Science: Math and Astronomy only (+5%); Technical any; W.P.
    any, Ancient and Modern; Wilderness any (+10%). The Cibola/native split is
    gone from D-Bees. Communications is an only list of Barter, Public
    Speaking, Radio: Basic and the language and literacy rows the catalog
    files under Communications; the other languages are Technical rows, open
    in full. Pilot is an only list of the five Boat: rows. Science grants both
    Mathematics rows and both Astronomy rows.
  - SECONDARY SKILLS: South America printed none. D-Bees printed 158 gives two
    from the Rifts Ultimate Edition list at levels 2, 4, 8 and 12, and none at
    level 1.
  - EXPERIENCE: South America printed 168 gives the ladder as "same as the
    dragon R.C.C.", and D-Bees printed 158 says to use the same Experience
    Table as the Dragon. The stored xp_table is the one dragon-hatchling
    stores, RUE''s Dragon Hatchling & Adult Dragon ladder (RUE printed 295),
    given to both classes by ~006-rue-xp-ladders.sql.
  - EQUIPMENT: South America printed 136 gave a Cibolan-trained Pogtalian a
    heavy energy rifle, dragon-skin armor (250 to 300 M.D.C.) and two or three
    archaic weapons such as swords, axes and clubs. D-Bees''s equipment line is
    a giant-sized melee weapon for each W.P., with notes on giant-sized modern
    gear, custom made modern armor and Dragon Skin Armor at 2D6x10+100 M.D.C.
    (3D6x10+140 reinforced). The heavy energy rifle is no longer stored. The
    armor IS still stored as a starting item although the restated line does
    not list it: D-Bees describes the traditional armor in the same equipment
    passage as what Pogtal wear, where it names no energy rifle at all. The
    melee weapons are a pick of four from the catalog''s human-sized archaic
    rows (W.P. Blunt and the three ancient W.P.s); the catalog holds no
    giant-sized archaic weapons. The dragon-skin-armor gear row still carries
    South America''s 250 to 300 M.D.C.; D-Bees''s figures are in restrictions.
  - MONEY: both books print 2D6x1000 credits. D-Bees adds 3D6x1000 credits''
    worth of tradeable goods, kept in restrictions because money is coin only.
  - CYBERNETICS: South America printed 136 said starts with none but is not
    opposed to cybernetic augmentation; D-Bees says not opposed to getting a
    bionic limb if the original is lost in combat.
  - LIFE SPAN: South America printed 136 gave an average of 300 years; D-Bees
    prints 3D6x10+150 years, maturity at 30. Size and weight are the same.
  - NOT STORED (no field): D-Bees''s alignment split - any, but leans towards
    Unprincipled (10%), Anarchist (40%), Aberrant (10%) and Miscreant (30%),
    where South America printed 135 said leans towards anarchist, most in
    Cibola''s service anarchist or miscreant; NPC experience level 1D6+2 or as
    set by the Game Master, player characters starting at level one; Slave
    Market Value 2D6x100,000 credits as warriors, gladiators and dragon
    slayers; females bear one young after a 24 month pregnancy.
---

# Pogtalian Dragon Slayer

**Alignments.** Any, but leaning anarchist; those serving Cibola are mostly anarchist or miscreant.

## Lore

The Pogtalians are giant D-bees and creatures of magic, from a world of jungle,
subtropical forest, swamp and marsh where the dominant life is dragons and
dragon-like predators. They grew huge, resistant to magic and equipped to fight
their natural enemy. At home they live in small tribes of twenty to a hundred,
most of them nomads.

In South America they are, beside the pincer warriors, the backbone of Cibola''s
defence: the soul worm Inix has hired thousands of them as mercenaries, trading
their home world''s one city energy weapons, drugs and drink for captured
dragons, dragon-skin armor and raw materials. The two species are bitter rivals
for their master''s favour, and duels between them - many in the arena - are
routine. Unlike the pincer warriors, Pogtalians love advanced weapons, and
Cibola''s technologists built the Dragon Death power armor around their powers.

They are proud warriors who see no glory in killing the unarmed or the weak and
care little for treasure or ruling others. What they want is a challenge:
dragons, powerful mages, greater demons, giant monsters and giant robots, or
simply overwhelming odds.

## As a player character

Some dragon slayers deserted Cibola rather than obey a dishonourable order, or
turned from the city''s evil; others are escaped slaves, come from tribes that
never dealt with Cibola, or are simply looking for adventure.
',
       updated_at = datetime('now')
 WHERE class_id = 'pogtalian-dragon-slayer'
   AND instr(markdown, 'source_book: Rifts World Book 6: South America p.135-136') > 0
   AND length(markdown) = 12426;

-- == blind-warrior-women ==
UPDATE imported_classes
   SET markdown = '---
id: blind-warrior-women
name: Blind Warrior Women (Altara)
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.15-18
category: rcc
tags: [combat, hunter]
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]
attribute_dice:
  IQ: "1d6+10"
  ME: "1d6+15"
  MA: "1d6+16"
  PS: "1d6+22"
  PP: "1d6+21"
  PE: "1d6+22"
  PB: "2d6+14"
  Spd: "2d6+22"
hit_points_base: "1d4x10, +1d6 per level of experience"
sdc_base: "2d6x10"
ppe_base: "2d6"
horror_factor: 12
ignores_style_attacks: true
bonuses:
  combat: { attacks_base: 7, strike: 1, parry: 2, dodge: 2, initiative: 2, perception: 3, disarm: 3, roll: 4, pull_punch: 2, damage_bonus: 2 }
  saves: { psionics: 2, spell_magic: 1, ritual_magic: 1, horror_factor: 4, coma_death_pct: 10 }
skills:
  occ_skills:
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 40, per_level: 5, note: "+5%" }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%; the book prints Demon and Monster Lore." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "The book prints General Athletics." }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5% where applicable" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Identify Plants & Fruit", base: 30, per_level: 5, note: "+5%; the book prints Identify Plants." }
    - { name: "Intelligence", base: 37, per_level: 4, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { name: "Language: Demongogian", base: 98, per_level: 0, note: "Language: Native Tongue (Demongogian)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints Math: Basic." }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Preserve Food", base: 30, per_level: 5, note: "+5%" }
    - { name: "Prowl", base: 25, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Archery", base: 0, per_level: 0 }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "R.C.C. Related Skills: two of Language: Other (+15%). Taken once per language - the picker asks which." }
    - { choose: 2, categories: ["Espionage", "Military"], bonus: 10, note: "R.C.C. Related Skills: two choices from Espionage (+10%) or Military (+10%). That is all the related skills the class gets." }
  secondary_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 5, count: 1 }, { level: 7, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "Three Secondary Skills at level one from the Secondary Skill List on page 300 of Rifts Ultimate Edition, +1 additional Secondary Skill at levels 3, 5, 7, 9, 12 and 15. All start at the base skill level. She cannot learn to read, so no Literacy."
psionics:
  type: "major"
  isp_base: "3d6x10, +1d6 per level of experience"
  powers: ["Sixth Sense", "Presence Sense", "Empathy", "Sense Magic", "Sense Evil", "Object Read (Psychometry)", "Clairvoyance", "Mind Block"]
trackable_resources:
  - key: armor-of-ithan
    label: "Talisman: Armor of Ithan"
    max: 3
    reset_on: day
    note: "Armor of Ithan around herself: 100 M.D.C., lasts ten minutes (40 melee rounds); recharges every 24 hours, or in one hour at a stone pyramid"
equipment_starting:
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "slavers-net-gun", qty: 1 }
  - { item_id: "kittani-laser-wrist-blasters", qty: 1 }
  - { item_id: "bio-wizard-mental-incapacitator", qty: 1 }
natural_abilities:
  - { name: "Born Blind", description: "Every warrior woman is born blind but suffers no penalty for blindness or total darkness; she enjoys heightened senses and is otherwise strong and healthy." }
  - { name: "Superb Physical Condition", description: "Fast reflexes and keen awareness. Recovers lost Hit Points and S.D.C. three times faster than a human." }
  - { name: "Heightened Sense of Hearing", description: "Equal to cybernetic Amplified Hearing (Rifts Ultimate Edition page 49)." }
  - { name: "Heightened Sense of Smell", description: "Recognize specific odors 90%. Recognize a specific person, animal or plant by scent alone 70% +1% per level of experience. Recognize poisons and toxins 80% +1% per level. Track by scent 80% (-20% in cities or ''Burbs)." }
  - { name: "Heightened Sense of Touch", description: "Recognize items by feel 66% +2% per level of experience." }
  - { name: "Radar Sense", description: "Knows and senses the location of people, objects and movement and the general shapes of people, animals and objects around her, range 1200 ft (366 m). Interpret shapes 85%, estimate distances 95%, estimate direction 75%, estimate speed 75%, estimate exact location 75%; the last three gain +1% per level of experience. Its bonuses are already factored into her bonuses and R.C.C. skills." }
  - { name: "Extraordinary Physical Endurance", description: "Unnatural physical endurance, reflected in her P.E. attribute and high S.D.C." }
  - { name: "Cloning", description: "The Altara are all women and sterile, and are reproduced by the Splugorth through an unusual means of cloning; D-Bees of North America refers to World Book Two: Atlantis for the process, which is: in a laboratory or naturally, in a secluded place the woman enters a trance, wraps herself in an ectoplasmic cocoon and in 48 hours creates an adult duplicate, typically once every 12 years and when she is crippled or dying. The clone has the same physical and psionic attributes and all her skills except secondary ones, at half her level of experience, without her deeply personal memories, injuries, diseases, mutations or any symbiotic, cybernetic, magic or genetic additions. Her alignment is usually the same or similar." }
  - { name: "Martial Arts Strikes", description: "Combat moves: body flip 2D4 S.D.C., karate kick 2D6 S.D.C., karate leap kick 3D8 S.D.C., power kick double damage (counts as two attacks), karate punch 2D4 S.D.C.; apply the P.S. damage bonus to each type of attack. Critical strike (double damage) on a natural 18, 19 or 20. Fights with paired weapons." }
special_abilities:
  - name: "Talisman of Armor of Ithan"
    description: "Each warrior wears a runic Splugorthian talisman around her neck that casts Armor of Ithan on her three times a day: 100 M.D.C., lasting ten minutes (40 melee rounds). Unlike an ordinary Rifts talisman it recharges automatically every 24 hours, and in one hour at a stone pyramid."
restrictions:
  - "A woman not subservient to the Splugorth and their minions is a runaway slave, unwelcome in Atlantis, and will be attacked and captured or killed by any Splugorth minions who know her for one."
  - "Usually silent; speaks only when absolutely necessary."
  - "Cannot ever learn to read the written word (blind)."
  - "Does not know magic, but may use magic weapons and devices, as well as Splugorth parasites and symbiotes."
  - "Eight attacks per melee regardless of level or combat training; the number does not improve."
side_effects: "Senses fouled by storms of every kind (rain, snow, sand, dust, ley line storms): radar, hearing, abilities and combat bonuses are halved. Her reputation as a Minion of Splugorth means many people fear her and never trust her; some believe the worst no matter what and seek her destruction."
extraction_notes: "ORIGINAL: this class followed Rifts World Book 2: Atlantis printed 50-51 until this update; by the ruling of 2026-10-04 the newest printing that states a figure wins, so it now follows Rifts World Book 30: D-Bees of North America printed 15-18 (cache p016-p019, page_offset 1; the entry is headed Altara, Blind Warrior Women, the stat block Altara Warrior Women R.C.C., NPC Villain or Optional Player Character, and its weapon list and talisman run onto printed 18). Both books were read off page renders. || XP: D-Bees printed 17 says to use the same experience table as the Juicer; the ladder is the stored xp_table of the production class juicer (0, 2141, 4281 ... 341601). Atlantis printed 68 assigned the Cyber-Knight table, which is the same column of Rifts Ultimate Edition printed 295 (Cyber-Knight, Crazy and Juicer), so no figure moved. || ATTRIBUTES: the same dice in both books. Atlantis printed 51 added that the Rifts Sourcebook prints lower dice for the run-of-the-mill warrior; D-Bees does not restate that. || POOLS: hit points 1D4x10 +1D6 per level, S.D.C. 2D6x10 as sdc_base (the R.C.C.''s own pool, no O.C.C.), P.P.E. 2D6, I.S.P. 3D6x10 +1D6 per level: the same in both books. M.D.C. only from magic or armor: the thin rubbery suit and padded helmet give 30 M.D.C. (prose; no gear row). An Absurr Life Node symbiote or Chest Amalgamate awarded for loyalty makes her an M.D.C. being (prose). || PSIONICS: the same eight fixed powers and no picks in both books; neither states a tier, stored as major (judgement: it sets only the save target). Object Read is the catalog''s Object Read (Psychometry). || COMBAT: D-Bees printed 17 gives eight attacks per melee regardless of level or combat training, does not improve; Atlantis printed 51 gave six. Boxing is a fixed R.C.C. skill whose catalog row adds one attack, so attacks_base is stored as 7 and Boxing brings the total to the printed eight (the Atlantis figure was stored as 5 the same way), with ignores_style_attacks so no combat training adds more. Bonuses as D-Bees prints them, in addition to attributes and skills: +2 initiative, +3 Perception Rolls, +1 strike, +2 parry and dodge, +3 disarm, +2 pull punch, +4 roll with impact, +2 damage (S.D.C., plus any P.S. damage bonus), +2 vs psionic attacks, +1 vs magic (spell_magic and ritual_magic), +4 vs Horror Factor, +10% vs coma/death. Atlantis printed 51 gave the same line without the +3 Perception and the +3 disarm. Combat moves are prose: D-Bees gives body flip 2D4, karate kick 2D6, karate leap kick 3D8, power kick double damage counting as two attacks, karate punch 2D4 (all S.D.C.), paired weapons and critical on 18-20; Atlantis printed 51 gave karate kick 1D8, karate leap kick 2D8, karate punch 1D6 and no body flip or power kick. || SKILLS: D-Bees printed 17 restates the complete R.C.C. skill list, headed R.C.C. Skills: Blind Warrior. It leaves out Hand to Hand: Martial Arts, which headed the Atlantis printed 51 list, so that grant was removed; the karate moves it implied are printed as Combat Moves instead. It adds Language: Native Tongue (Demongogian), stored as Language: Demongogian at 98 with no per-level gain. Demon and Monster Lore is +10% (25+10; Atlantis gave +5%, stored 30). Gymnastics is +5% where applicable (30+5; Atlantis gave no bonus, stored 30). Unchanged: climbing 40+10, swimming 50+10, land navigation 36+5 at 4 per level, wilderness survival 30+10, Identify Plants is Identify Plants & Fruit 25+5, skin and prepare animal hides 30+10, preserve food 25+5, cook 35+5, Math: Basic 45+20, intelligence 32+5 at 4 per level, paramedic 40+10; General Athletics is Athletics (general). D-Bees adds R.C.C. Related Skills, which Atlantis did not print: two of Language: Other (+15%) and two choices from Espionage (+10%) or Military (+10%), stored as two choice groups in occ_skills because that is all the class gets. Secondary skills: D-Bees gives three at level one from the Secondary Skill List of Rifts Ultimate Edition page 300, +1 at levels 3, 5, 7, 9, 12 and 15, at the base skill level; Atlantis printed 51 gave six secondary skills from any category except medical, electrical and science. || NATURAL ABILITIES: D-Bees adds superb physical condition, fast reflexes and recovery of Hit Points and S.D.C. three times faster than a human; adds plant to the scents recognized; and says Radar Sense is factored into the bonuses and R.C.C. skills. Atlantis printed 51 called the senses Special Super Powers and noted they are based on powers in Heroes Unlimited, suggesting D-Bees or genetically altered mutants; D-Bees calls the Altara human or human-like and genetically improved, and does not restate that note. Cloning: D-Bees printed 17 refers to Atlantis for the process, so the Atlantis printed 51 description is kept. || VULNERABILITIES: D-Bees restates the line as storms of all kinds, rain, snow, sand, dust and Ley Line Storms, halving all radar, hearing, abilities and combat bonuses; Atlantis printed 51 also listed smoke and named smell. D-Bees adds that she can never learn to read and that her reputation follows her. || MAGIC: does not know magic. The talisman is a trackable resource (three a day), not a spell grant; D-Bees printed 18 adds that it recharges in one hour at a stone pyramid. || EQUIPMENT: D-Bees printed 18 names the standard issue as a conventional dagger (1D6 S.D.C.), Vibro-Knife (1D6 M.D.), net gun, laser wrist blaster and Mental Incapacitator, and says even a runaway is likely to have all or at least half of them. Atlantis printed 51 said vibro-blade without naming one, which was stored as a pick between vibro-knife and vibro-sword; it is now the vibro-knife. The net gun, wrist blasters and incapacitator have been equipment_starting since fix-atlantis-minion-class-gear.sql, by Nate''s decision to wire the book''s named gear in. The conventional dagger and the 30 M.D.C. suit and helmet have no Rifts gear row and stay in the body. Bio-Wizard microbes (frequently 1D4+1 of each of six kinds, D-Bees; no number in Atlantis) vary with the assignment and stay in the body. || NPC FIGURES: average experience level 2D6+1 or as set by the G.M. (Atlantis: 4th to 10th, 2D4+2); player characters should start at level one or two; average life span 4D6+60 years; NPC villains anarchist or evil, player characters any alignment but tending to unprincipled (30%) or anarchist (30%); 2% resent and resist slavery (Atlantis: about 25%). These are in the Lore body. || No starting money is printed in either book."
---

## Lore

The blind warrior women of Altara are among the best known of the Splugorth''s lesser minions, because four to six of them ride every Splugorth slave barge and help capture and herd the slaves. Each is an exceptional fighter with heightened senses and martial arts training. The Coalition has guessed they are juicers or crazies; others take them for D-bee psychics, which is nearer the truth.

The Splugorth conquered the Altarains some 2000 years ago and have bred them through generations of mind control, bio-wizard experimentation and brutality to accept slavery. They obey the Splugorth''s elite minions without hesitation, for anything else means death, and many have come to enjoy their place. But a small percentage (2%) resent and resist slavery, and these are the ones who sometimes break with the Splugorth and flee. Runaways are regarded as traitorous escaped slaves to be found and destroyed, but the search is usually half-hearted and is abandoned after 48 hours; a free Altara met later, or one who attacks Splugorth holdings, is slain on the spot or captured for bio-wizard experimentation, the arena or hard labor.

There are no Altarain men. Born blind but otherwise healthy, the women are instinctive warriors with nearly indomitable wills and a hunger for challenge, adventure and combat. They are usually silent. Alignment: NPC villains are anarchist or evil; player characters can be any alignment but tend to be unprincipled (30%) or anarchist (30%). Height 5.8 to 6.2 ft (1.7 to 1.9 m), weight about 160 lbs (72 kg), always very attractive. Average life span 4D6+60 years. NPCs average 2D6+1 levels of experience or as set by the G.M.; player characters should start at level one or two.

## Equipment

Standard issue: a conventional dagger (1D6 S.D.C.), Vibro-Knife (1D6 M.D.), net gun, laser wrist blaster and mental incapacitator; even a runaway is likely to have all or at least half of them. They can use just about any other weapon. Her only armor is a light, padded M.D.C. suit and helmet (30 M.D.C.); rogues may wear any armor but prefer light and medium types and force fields for mobility and speed.

Bio-wizard devices vary with the assignment; they are frequently given 1D4+1 each of aerobes, aquarobes, clotrobes, purirobes, stasirobes and watrobes. Those who show great loyalty and bravery are occasionally awarded an Absurr life node symbiote or a chest amalgamate, either of which makes her an M.D.C. being. Available upon assignment: one Eylor floating eye or Eylor seeker-hunter, forearm plasma blaster, helmet laser, jolt gun, microbes, Kittani plasma rifle, psi-interrogator, a telepathic holographic imager (special operatives and officers), and symbiotic organisms (limited; dangerous parasites are never used on loyal minions).
',
       updated_at = datetime('now')
 WHERE class_id = 'blind-warrior-women'
   AND instr(markdown, 'source_book: Rifts World Book 2: Atlantis p.50-51') > 0
   AND length(markdown) = 11916;

-- == tokanii ==
UPDATE imported_classes
   SET markdown = '---
id: tokanii
name: Tokanii Warrior
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.203-206
category: rcc
tags: [combat, wilderness]
xp_table: [0, 2351, 4651, 9251, 18501, 27001, 37001, 52001, 73001, 98001, 140001, 190001, 232001, 292001, 360001]
attribute_dice:
  IQ: "2d6+3"
  ME: "3d6"
  MA: "2d6+3"
  PS: "4d6"
  PP: "3d6+3"
  PE: "4d6+3"
  PB: "2d4"
  Spd: "3d6+6"
mdc_base: "P.E. x3 + 4d6 per level"
ppe_base: "4d6"
horror_factor: 13
starting_money: "1d6x100"
bonuses:
  combat: { attacks: 1, initiative: 1, strike: 2, parry: 2, pull_punch: 2, roll: 2 }
  saves: { toxins_poisons: 3, harmful_drugs: 3, disease: 3, horror_factor: 8 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Barter", base: 40, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Tokanii." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American or Spanish (+20%)." }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%" }
    - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "+15%. Printed as Track Animals." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. three of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Cannot change this skill." }
    - { name: "Climbing", base: 95, per_level: 0, note: "Natural ability: the book prints climb 95%/90%." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", except: ["Electronic Countermeasures", "Laser Communications", "Optic Systems", "Radio: Satellite Relay", "Space: Radio: Deep Space", "Surveillance", "T.V./Video"] }
      - "Cowboy"
      - { name: "Domestic", bonus: 10 }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], bonus: 5 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5 }
      - { name: "Physical", except: ["Gymnastics"] }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes", "Hover Craft (ground)", "Truck"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Law", "Law: CCW", "Philosophy"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Communications: any, except high-tech skills. Cowboy: any. Electrical, Mechanical, Military and Pilot Related: none. Horsemanship: General and Exotic Animals only. Medical: First Aid and Holistic Medicine only. Physical: any except Gymnastics. Pilot: Motorcycle, Hovercycle, Hover Vehicle (ground), or Truck only, but most (98%) have no interest in Piloting skills. Rogue: any except Computer Hacking. Science: Mathematics only. Technical: any except Computer Operation, Computer Programming and other high-tech or civilized skills (Law, Philosophy, etc.). Other than Ronii, most Tokanii care nothing about learning to read or higher education. Ronii exclusive: a Ronii warrior can select ANY skills from Communications, Military, Piloting and Rogue."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "Three skills at level one from the Secondary Skills List on page 300 of Rifts Ultimate Edition, and one additional at levels 2, 4, 8 and 12, at the base skill level; no bonuses other than a high I.Q."
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 E-Clips for energy weapons." }
  - { item_id: "vibro-sword", qty: 1 }
  - { choose: 1, label: "survival knife or hatchet", qty: 1, from: ["survival-knife", "hatchet"] }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "utility-belt", qty: 1 }
  - { choose: 1, label: "two canteens or waterskins", qty: 2, from: ["canteen", "water-skin-half-gallon"] }
  - { item_id: "rope-per-20-feet-6-m", qty: 1, note: "30 feet (9.1 m) of rope." }
natural_abilities:
  - { name: "Supernatural P.S. and P.E.", description: "The equivalent of Supernatural P.S. and P.E. Damage is as per Supernatural P.S. or by weapon." }
  - { name: "Natural Attacks", description: "Claws on the massive hands: 2D6+2 M.D. + Supernatural P.S. damage in claw strikes; a power claw strike inflicts double damage but counts as two melee attacks. Head butt with horns: the same as a punch attack. Goring/stabbing horn attack: 2D6 + Supernatural P.S. damage. Bite: 2D4 M.D." }
  - { name: "Mega-Damage Exoskeleton", description: "A mega-damage being with M.D.C. bone body armor. Add 10 M.D.C. for every 20 years of age. The bone exoskeleton holds most of the M.D.C. (printed as 90% in the Mega-Damage line and 80% under Bone Regeneration); a Tokanii whose M.D.C. is reduced by 80% knows he is in mortal danger." }
  - { name: "Bone Regeneration", description: "Any horn or bone that is broken or damaged in any way regenerates at a rate of 2D6+4 M.D.C. per day." }
  - { name: "Regenerate Hands and Feet", description: "The hands and feet are the only parts not protected by bone (roughly 10 M.D.C. per each foot, 28 M.D.C. per each hand, 20 M.D.C. per claw). A lost hand or foot is completely regrown in 1D4+2 weeks." }
  - { name: "Nightvision", description: "300 feet (91.5 m). The eyes flash like a cat''s at night." }
  - { name: "Hawk-like Color Vision", description: "Hawk-like color vision." }
  - { name: "Fire and Heat Resistant", description: "Resistant to fire and heat: even M.D. fire does half damage." }
  - { name: "Natural Climber", description: "Climb 95%/90%. Short, retractable cat''s claws on the fingertips and the three toes, evolved for climbing giant trees and sheer cliff faces." }
  - { name: "Size and Life Span", description: "7 to 9 feet (2.1 to 2.7 m) tall and 350 to 550 lbs (158 to 248 kg). Average life span 1D6x10+180 years. Physical maturity is attained by age 20, but most behave like energetic and risk-taking teenagers until about the age of 70." }
variants:
  - id: ronii
    name: "Ronii Tribe"
    skills_additional:
      occ_skills:
        - { name: "Horsemanship: General", base: 70, per_level: 4, note: "+30%. Ronii exclusive." }
        - { name: "Horsemanship: Exotic Animals", base: 60, per_level: 5, note: "+30%. Ronii exclusive." }
trackable_resources: []
side_effects: "Vulnerabilities: their demonic appearance and arrogance both work against them. They believe they are the best warriors in the world, which means they tend to underestimate their opponents as well as technology and magic."
restrictions:
  - "O.C.C.: a Ronii is the only Tokanii who can deviate from the Tokanii Warrior R.C.C. and select any Men at Arms O.C.C., Wilderness Scout, or any Practitioner of Magic O.C.C. (less than 1% have taken up the study of magic). Tokae and Kreenae are Tokanii Warriors."
  - "Magic: typically none. Only Tokanii Shamans (effectively Mystics) and members of the Ronii tribe can select a magic O.C.C."
  - "Psionics: same chance of being psychic as humans."
  - "Never use armor or power armor or most high-tech equipment. Love magic items but start with none."
  - "Cybernetics and bionics: won''t consider them."
  - "Hand to Hand: Expert cannot be changed."
  - "Money: 1D6x100 credits, plus 2D6x1,000 credits in tradeable goods."
  - "Ronii exclusive: a Ronii warrior can select any skills from Communications, Military, Piloting and Rogue, and also starts with a good quality horse or exotic riding animal."
  - "Most Tokanii other than the Ronii are ground and tree dwellers who seldom learn to ride animals or vehicles, and care nothing about learning to read or higher education."
  - "Alignment: any, but most are anarchist or evil. Only the Ronii tribe have about 10% scrupulous, 28% unprincipled, 20% anarchist, 22% aberrant and the rest various evil alignments."
  - "Clan vendetta: a crime or insult against the clan, a clan leader or a warrior of note is answered with a challenge or attack, usually to the death; the Tokanii cannot be appeased with apologies, valuables or punishment."
extraction_notes: "This class followed Rifts World Book 13: Lone Star printed 154-156 (experience ladder on the Experience Tables page after printed 174) until this update; under the ruling of 2026-10-04 it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 203-206 (cache p204-p207, cache page = printed folio + 1), whose closing note says the race originally appeared in World Book 13: Lone Star. The newest printing that states a figure wins and the older figure is kept here. Every figure was read off 170 dpi page renders of both books (D-Bees cache p204-p207; Lone Star cache p155-p157 and the experience chart). || HEADING: D-Bees heads the stat block Tokanii - Optional Player Character and NPC and the skill list R.C.C. Skills of the Tokanii Warrior; Lone Star headed it Tokanii Warrior R.C.C. - Optional Player Character. A D-Bee race; mdc_base is stated, so there is no men_of_arms line. || UNCHANGED between the two printings: the eight attribute dice (I.Q. 2D6+3, M.E. 3D6, M.A. 2D6+3, P.S. 4D6, P.P. 3D6+3, P.E. 4D6+3, P.B. 2D4 by human standards, Spd 3D6+6); Mega-Damage P.E. attribute number x3 +4D6 M.D.C. per level of experience plus 10 M.D.C. for every 20 years of age (the age part is ability text, not in the formula); the exoskeleton''s share of the M.D.C. printed as 90% in the Mega-Damage line and 80% under Bone Regeneration; bone regeneration 2D6+4 M.D.C. per day; hands and feet regrown in 1D4+2 weeks; Horror Factor 13; P.P.E. 4D6; nightvision 300 feet; hawk-like color vision; climb 95%/90%; +1 attack per melee round; +3 to save vs poison and drugs (toxins_poisons 3 and harmful_drugs 3); +3 vs disease; +8 vs Horror Factor; the alignment percentages; Radio: Basic +10%, Running, Swim +10%, Identify Plants & Fruits +15%, Land Navigation +15%, Track Animals +15%, Skin & Prepare Animal Hides +15%, Wilderness Survival +20%, W.P. Blunt, W.P. Energy Rifle, three W.P. of choice, Hand to Hand: Expert; the Ronii''s Horsemanship and Horsemanship: Exotic Animals at +30% each and their wider skill selection and choice of O.C.C.; four related skills at level one plus one at levels 2, 5, 8 and 12; Domestic +10%, Espionage any, Medical First Aid and Holistic Medicine only +5%, Physical any except Gymnastics, Rogue +5% except Computer Hacking, W.P. any, Wilderness +10%, and Electrical, Mechanical, Military and Pilot Related none; the magic line; never using armor or power armor. || BONUSES: D-Bees printed 206 prints, in addition to those from attributes and skills, +1 attack per melee round, +1 on initiative, +2 to strike and parry, +2 to pull punch, +2 to roll with impact, +3 to save vs poison and drugs, +3 to save vs disease, +8 to save vs Horror Factor, and resistant to fire/heat (even M.D. fire does half damage). Lone Star printed 156 gave only the attack and the three saves, with no initiative, strike, parry, pull punch or roll bonus, and fire/heat resistant (does 1/2 damage) with no word on M.D. fire. || NATURAL ABILITIES: D-Bees restates the line as Supernatural Strength, M.D.C. bone body armor, nightvision 300 feet, hawk-like color vision and climb 95%/90%. Lone Star printed 156 also gave a superior sense of smell (twice as keen as humans); D-Bees leaves it out of the restated line, so it is no longer stored. D-Bees marks P.S. and P.E. as (Supernatural) in the attribute line; Lone Star added that the Tokanii are not supernatural in and of themselves. Regenerate Hands and Feet: D-Bees prints roughly 10 M.D.C. per each foot, 28 M.D.C. per each hand and 20 M.D.C. per claw; Lone Star printed 156 gave roughly 10 M.D.C. each. || ATTACKS: D-Bees printed 206 prints damage as per Supernatural P.S. or weapon; claws 2D6+2 M.D. + Supernatural P.S. damage, a power claw strike doing double damage and counting as two melee attacks; a head butt with horns the same as a punch attack; a goring/stabbing horn attack 2D6 + Supernatural P.S. damage; a bite 2D4 M.D. Lone Star printed 155 gave bite 1D6 M.D., head butt 1D6 M.D. and a running ram with the horns 2D6 +P.S. M.D., and no claw damage. Text only, in the Natural Attacks ability. || SIZE AND AGE: D-Bees prints 7-9 feet (2.1 to 2.7 m), 350-550 lbs (158 to 248 kg) and an average life span of 1D6x10+180 years, physical maturity by age 20, behaving like teenagers until about 70, 1D4 live young after an 18 month pregnancy. Lone Star printed 156 gave 160 to 250 kg, a life span of 180-240 years, and that player characters start out as young warriors between the age of 20 and 40; D-Bees restates the life span line without the starting age, so it is no longer in the ability text. || PSIONICS: D-Bees prints Same chance of being psychic as humans (Lone Star: Standard; roughly the same as humans); no psionics block, the line is in restrictions. || SKILLS: D-Bees adds Barter (+10%), 30+10 = 40; Language: Native Tongue: Tokanii, the catalog''s Language: Native Tongue at its own 98; Language: Other: American or Spanish (+20%), the catalog''s Language: Other 50+20 = 70 with the two tongues in the note; and Recognize Weapon Quality (+20%), 25+20 = 45. Lone Star printed 156 gave none of the four and printed Speaks American at 80% efficiency, which was stored as Language: Native Tongue 80. D-Bees prints Hand to Hand: Expert (cannot change this skill), stored as a hand_to_hand block with no styles on offer; Lone Star printed the style with no such clause. Unchanged figures: Radio: Basic 45+10 = 55. Swimming 50+10 = 60. Identify Plants & Fruits is the catalog''s Identify Plants & Fruit, 25+15 = 40. Land Navigation 36+15 = 51. Track Animals is the catalog''s Track & Trap Animals, 20+15 = 35. Skin & Prepare Animal Hides 30+15 = 45. Wilderness Survival 30+20 = 50. Climb 95%/90% is printed under natural abilities in both books and stored as Climbing 95 with per_level 0 (judgement: a fixed figure and no per-level step; the second figure, 90%, is in the note). || RONII: the one tribe with its own printed skills is the ronii variant; the class with no variant is a Tokae or Kreenae warrior. Horsemanship is the catalog''s Horsemanship: General, 40+30 = 70; Horsemanship: Exotic Animals 30+30 = 60. The Ronii''s wider skill selection (any Communications, Military, Piloting and Rogue), the horse or exotic riding animal and the choice of another O.C.C. are restriction text, the same in both books. || RELATED: D-Bees printed 205-206 revises five lines and adds one. Communications: Any, except high-tech skills (Lone Star printed 156: Radio: Basic and Scrambler only); the book names no skill, so the exception list is a judgement - Electronic Countermeasures, Laser Communications, Optic Systems, Radio: Satellite Relay, Space: Radio: Deep Space, Surveillance and T.V./Video - and the two radio skills Lone Star allowed stay open. Cowboy: Any (not in Lone Star). Horsemanship: General and Exotic Animals only (+5%) (Lone Star folded horsemanship into its Pilot line with no bonus). Pilot: Motorcycle, Hovercycle, Hover Vehicle (ground), or Truck only, but most (98%) have no interest in Piloting skills (Lone Star: Truck, Hovercraft and horsemanship only, 99%); the catalog rows are Motorcycles & Snowmobiles, Hovercycles, Skycycles & Rocket Bikes, Hover Craft (ground) and Truck. Science: Mathematics only (Lone Star: None), the catalog''s Mathematics: Basic and Mathematics: Advanced. Technical: Any (+5%); except Computer Operation, Computer Programming and other high-tech or civilized skills (Law, Philosophy, etc.) (Lone Star: except computer operation & programming); the two named examples are stored with the catalog''s Law and Law: CCW and Philosophy, and the open-ended etc. is in the note. || SECONDARY: D-Bees prints three skills at level one from the Secondary Skills List on page 300 of Rifts Ultimate Edition and one additional at levels 2, 4, 8 and 12. Lone Star printed 156 gave four secondary skills from the class''s own related list, excluding those marked None, with the same four later levels; the category list is no longer stored. || XP: D-Bees prints no experience table for the Tokanii (Experience Level: 1D8 or as set by the Game Master for NPCs; player characters should start at first level) and the book has no experience-table page, so it does not restate the ladder. The xp_table is Lone Star''s column headed Tokanii R.C.C. on its Experience Tables page (the chart page after printed 174), read off the render, lower bound of each band. || EQUIPMENT: D-Bees printed 206 prints Standard Equipment for Tokanii Warriors as one weapon for each W.P. and 1D4+2 E-Clips for energy weapons, Vibro-Sword (2D6 M.D.), survival knife or hatchet (1D6 S.D.C.), backpack, 1D4 large sacks, utility belt, two canteens or waterskins, and 30 feet (9.1 m) of rope; Ronii tribesmen also start with a good quality horse or exotic riding animal. One weapon for each W.P. is the catalog''s weapons-matching-w-p-skills row; the rope is one rope-per-20-feet-6-m row with the printed length in its note; canteens or waterskins is a pick of one kind at quantity two. Lone Star printed 156 gave a survival knife or hatchet, one or two Vibro-Blades, an energy rifle, 1D4 additional E-clips for the weapon, a knapsack, utility belt, air filter and two canteens; the energy rifle choice, the Vibro-Blade choice, the knapsack and the air filter are not in the D-Bees list and are no longer stored. D-Bees adds that they love magic items but start with none. || MONEY: D-Bees prints Tokanii Warriors start with 1D6x100 credits and 2D6x1,000 in tradeable goods. starting_money holds the credits; the tradeable goods are a restriction line. Lone Star printed no starting sum. || D-BEES ONLY, not stored as mechanics: Cybernetics and Bionics: Won''t consider them (restriction line); Vulnerabilities (side_effects); Experience Level 1D8 for NPCs; Slave Market Value 3D6x10,000 credits, coveted for heavy infantry soldiers, gladiators and other combat roles; population 109 P.A. Tokae 27,500 in 24 clans, Kreenae 23,100 in 21 clans, Ronii 16,700 in seven clans (Lone Star printed 154: 24,000 in 22, 19,500 in 20, 11,500 in six); the arrival is 56 years ago in D-Bees and 49 in Lone Star. Tribal ranges, disposition, allies and enemies are lore."
---

## Lore

The Tokanii are D-Bees from a jungle world of giant predators, driven through
a Rift when an asteroid strike wrecked their Bronze Age home. They arrived in
Lone Star about half a century ago, were cut down in the tens of thousands by
Coalition troops, and the survivors rebuilt in the forests of the Pecos
Empire. They look like horned, black-skinned skeletons: a shell of gray bone
plates, a long toothy skull, a black mane, and arms and hands far too big for
the body.

Three tribes exist today. The Tokae raid from the eastern forests, the Kreenae
are the most savage and unforgiving, and the Ronii broke away to live on the
plains beside the Pervic Simvan, who taught them to ride. Every tribe shares a
fierce clan loyalty and a grim idea of honor in which an insult is paid for in
blood and nothing else.

Young warriors hire on with bandit gangs for the fighting and for the weapons
they can carry home, since a pile of captured arms is how a Tokanii shows
wealth and standing.

## GM Notes

Pick the Ronii variant for a Ronii warrior: it adds the two riding skills, and
the book also opens Communications, Military, Piloting and Rogue skills to
them and gives them a mount. Only a Ronii may take a different O.C.C. instead
of this R.C.C.

The Tokanii is a mega-damage being with supernatural strength, but it never
wears armor, so its own M.D.C. is all it has; add 10 M.D.C. per 20 years of
age by hand. Chieftains rule by answering every challenge, and the loser of
such a duel usually dies and forfeits everything he owns.
',
       updated_at = datetime('now')
 WHERE class_id = 'tokanii'
   AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.154-156') > 0
   AND length(markdown) = 13736;

-- == simvan-monster-rider ==
UPDATE imported_classes
   SET markdown = '---
id: simvan-monster-rider
men_of_arms: false
name: Simvan Monster Rider
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.188-190
category: rcc
tags: [combat, hunter, wilderness]
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
horror_factor: 12
attribute_dice:
  IQ: "3d6"
  ME: "4d6"
  MA: "2d6"
  PS: "4d6"
  PP: "4d6"
  PE: "5d6"
  PB: "2d6"
  Spd: "4d6"
hit_points_base: "1d4x10"
starting_money: "1d4x100"
bonuses:
  pools: { sdc: "2d6x10" }
  combat: { initiative: 1, perception: 1, strike: 1, parry: 1, dodge: 1, pull_punch: 2, roll: 1 }
  saves: { horror_factor: 2, other: [ { label: "vs spoiled meat/food", bonus: 2 } ] }
skills:
  occ_skills:
    - { name: "Running", base: 0, per_level: 0, note: "R.C.C. skill of both males and females." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Weapon proficiency of both males and females." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Cowboy", bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Detect Ambush", "Escape Artist", "Intelligence", "Interrogation"], bonus: 5 }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Automobile", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Boat: Motor, Race & Hydrofoil"], bonus: 10 }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Technical", only: ["Appraise Goods", "Gemology", "Salvage", "Whittling & Sculpting", "Lore: Aborigines", "Lore: Astral", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Buddhist", "Lore: Chinese Mythology: Taoist", "Lore: Cities", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Dreamtime Culture", "Lore: Faeries & Creatures of Magic", "Lore: Feng Shui/Geomancy", "Lore: Galactic/Alien", "Lore: General Law", "Lore: History of Russia", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Rifts China", "Lore: Vampires", "Lore: Western World", "Lore: Wormwood"], bonus: 5 }
      - "Weapon Proficiencies"
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }]
equipment_starting:
  - { item_id: "vibro-knife", qty: 1, note: "Vibro-Knife (1D6 M.D.)." }
  - { item_id: "survival-knife", qty: 1, note: "Survival knife (1D6 S.D.C.)." }
  - { item_id: "e-clip", qty: "1d4+1", note: "1D4+1 E-Clips for each energy weapon." }
  - { item_id: "arrows-standard", qty: "2d6+10", note: "2D6+10 arrows." }
  - { item_id: "mdc-arrow", qty: "1d6+2", note: "1D6+2 M.D. arrows." }
  - { item_id: "light-mdc-body-armor", qty: 1, note: "Light or medium Mega-Damage body armor." }
  - { item_id: "wooden-stake", qty: "1d6", note: "1D6 wooden stakes." }
  - { item_id: "small-mallet", qty: 1, note: "A wooden mallet." }
  - { choose: 1, label: "wood or silver cross", qty: 1, from: ["wooden-cross", "small-silver-cross"] }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1, note: "Saddlebag." }
  - { item_id: "large-sack", qty: "1d4", note: "1D4 large sacks." }
  - { item_id: "small-sack", qty: 2, note: "Two small sacks." }
  - { item_id: "utility-belt", qty: 1, note: "Military style utility belt with gun holster." }
  - { item_id: "gun-holster", qty: 1, note: "The holster of the utility belt." }
  - { item_id: "binoculars", qty: 1 }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
natural_abilities:
  - { name: "Size", description: "5 feet, 7 inches (1.7 m) to 6 feet (1.8 m) tall; 150 to 200 pounds (67 to 90 kg)." }
  - { name: "Keen Vision and Nightvision", description: "Keen vision; nightvision 120 feet (36.5 m)." }
  - { name: "Psionics", description: "All Simvan are psychic, with a natural affinity with animals very similar to that of the Psi-Stalker. Males have five set powers and Psionic Empathy with Animals; females have seven set healing powers and one healing power of choice at levels 1, 3, 6, 9 and 12. Choose the matching entry under special abilities." }
  - { name: "Monster Riders", description: "An uncanny ability to tame monsters, usually carnivores thought untamable, as mounts, attack animals and beasts of burden. Animal predators, including dinosaurs, monsters and giant insects, accept a Simvan and do not attack. To turn one into a riding animal the Simvan must leap on its back and stay on for one melee round (15 seconds): roll 1D20 for each of the rider''s attacks that melee; any roll of 1-6 (bonuses to parry may be applied) means he is knocked off and has to start over, 7 and higher means he holds on. The animal then obeys the Simvan''s every command, and that Simvan and any other can ride it from that day forward, though it is not truly tame and attacks any human or D-Bee who comes near unless commanded otherwise. I.S.P. cost: one point to try to break and ride an unfamiliar wild animal. A player character starts with a horse, an Ostrosaurus or a Silonar as a riding animal." }
  - { name: "Attacks per Melee", description: "As per the Hand to Hand combat skill." }
special_abilities:
  - { choose: 1, from: ["Psionic Powers, Male", "Psionic Powers, Female"], note: "Pick the one that matches the variant chosen (male or female)." }
  - name: "Psionic Powers, Male"
    description: "I.S.P. 2D4x10 plus M.E. Empathy, Mind Block, Mind Bond, Sixth Sense and Telepathy, and Psionic Empathy with Animals (special): domesticated animals take an immediate liking to the Simvan and obey his every command, and he can ride any horse (wild or tame) or any other animal as if he had Horsemanship: General with a +15% bonus. Wild animals, predators included (only alien animals with a human intelligence are excluded), treat him as a fellow woodland creature and do not flee, attack or give warning of his approach; even watchdogs do not bark. Both are automatic and cost no I.S.P. The character hunts and eats animal meat only for food, never for pleasure, and feels sadness at an animal in distress. For the male variant only."
    psionics:
      type: "major"
      isp_base: "2d4x10 plus M.E. attribute number"
      powers: ["Empathy", "Telepathy", "Sixth Sense", "Mind Block", "Mind Bond", "Psionic Empathy with Animals"]
  - name: "Psionic Powers, Female"
    description: "I.S.P. 4D4x10 plus M.E. Deaden Pain, Detect Psionics, Exorcism, Healing Touch, Increased Healing, Psychic Diagnosis, Psychic Surgery and one Healing power of choice at levels 1, 3, 6, 9 and 12. For the female variant only."
    psionics:
      type: "major"
      isp_base: "4d4x10 plus M.E. attribute number"
      powers: ["Detect Psionics", "Deaden Pain", "Exorcism", "Healing Touch", "Increased Healing", "Psychic Diagnosis", "Psychic Surgery"]
      powers_starting: 1
      categories_allowed: ["Healing"]
      powers_schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
variants:
  - id: male
    name: "Male (hunter and warrior)"
    ppe_base: "4d4"
    skills_additional:
      occ_skills:
        - { name: "Boat Building", base: 45, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Carpentry", base: 45, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Hunting", base: 0, per_level: 0, note: "All Wilderness skills; Hunting has no percentage." }
        - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Land Navigation", base: 56, per_level: 4, note: "All Wilderness skills, +20%." }
        - { name: "Preserve Food", base: 45, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Skin & Prepare Animal Hides", base: 50, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "All Wilderness skills, +20%." }
        - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
        - { name: "Athletics (general)", base: 0, per_level: 0, note: "Athletics (General)." }
        - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
        - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
        - { name: "Dance", base: 40, per_level: 5, note: "+10%" }
        - { choose: 1, from: ["Hand to Hand: Expert", "Hand to Hand: Assassin"], note: "Hand to Hand: Expert or Assassin (pick one)." }
        - { name: "Horsemanship: Cowboy", base: 76, per_level: 3, note: "+10%" }
        - { name: "Horsemanship: Exotic Animals", base: 60, per_level: 5, note: "+30%" }
        - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic, +20%." }
        - { choose: 3, categories: [{ name: "Physical", except: ["Hand to Hand: Basic", "Hand to Hand: Expert", "Hand to Hand: Martial Arts", "Hand to Hand: Assassin", "Hand to Hand: Commando"] }], note: "Three Physical skills of choice." }
        - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
        - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
        - { name: "Tracking (people)", base: 45, per_level: 5, note: "Track (people), +20%." }
        - { name: "W.P. Archery", base: 0, per_level: 0 }
        - { name: "W.P. Targeting", base: 0, per_level: 0 }
        - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
        - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P.s of choice (any)." }
  - id: female
    name: "Female (healer and homemaker)"
    ppe_base: "4d6"
    skills_additional:
      occ_skills:
        - { name: "Cook", base: 65, per_level: 5, note: "All Domestic skills, +30% on all. The line also prints Cook (+10%), which is not added." }
        - { name: "Dance", base: 60, per_level: 5, note: "All Domestic skills, +30% on all. The line also prints Dance (+10%), which is not added." }
        - { name: "Fishing", base: 70, per_level: 5, note: "All Domestic skills, +30%." }
        - { name: "Sewing", base: 70, per_level: 5, note: "All Domestic skills, +30%." }
        - { name: "Sing", base: 65, per_level: 5, note: "All Domestic skills, +30% on all. The line also prints Sing (+15%), which is not added." }
        - { name: "Play Musical Instrument", base: 65, per_level: 5, note: "All Domestic skills, +30%." }
        - { name: "Boat Building", base: 35, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Carpentry", base: 35, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Hunting", base: 0, per_level: 0, note: "All Wilderness skills; Hunting has no percentage." }
        - { name: "Identify Plants & Fruit", base: 35, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Land Navigation", base: 46, per_level: 4, note: "All Wilderness skills, +10%." }
        - { name: "Preserve Food", base: 35, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Wilderness Survival", base: 40, per_level: 5, note: "All Wilderness skills, +10%." }
        - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
        - { name: "Breed Dogs", base: 60, per_level: 5, note: "+20%" }
        - { name: "Brewing", base: 35, per_level: 5, note: "+10%" }
        - { name: "Brewing: Medicinal", base: 40, per_level: 5, note: "+15%" }
        - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
        - { name: "Hand to Hand: Basic", base: 0, per_level: 0 }
        - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%" }
        - { name: "Horsemanship: Exotic Animals", base: 50, per_level: 5, note: "+20%" }
        - { choose: 2, categories: [{ name: "Physical", except: ["Hand to Hand: Basic", "Hand to Hand: Expert", "Hand to Hand: Martial Arts", "Hand to Hand: Assassin", "Hand to Hand: Commando"] }], note: "Two Physical skills of choice." }
        - { name: "Veterinary Science", base: 65, per_level: 4, note: "+15%" }
        - { name: "W.P. Blunt", base: 0, per_level: 0 }
        - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice (any)." }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Male and female Simvan differ: choose the male or female variant and the matching psionic powers entry. Males have no healing powers."
  - "Available O.C.C.s: none."
  - "R.C.C. Related Skills: only Simvan females may also select from Medical skills; the categories listed for the class are those open to both sexes."
  - "Secondary Skills: none at first level; two at levels 2, 4, 8 and 10, at the base skill level with no bonus other than a high I.Q."
  - "Standard equipment also includes one weapon for every W.P. and some personal items."
  - "Money: 2D6x1,000 credits in trade goods on top of the starting credits."
  - "Cybernetics and bionics: avoids them as unnatural."
  - "Vulnerabilities: their aggressive natures and dietary habits (eating people) can cause problems. Cannibals with a preference for human and humanoid flesh."
  - "Psi-Stalkers, especially in the Pecos Empire, are rivals in a mounting, long-running feud; the Coalition Army is another enemy."
extraction_notes: "This class followed Rifts World Book 13: Lone Star printed 162-163 until it was brought up to its later printing, Rifts World Book 30: D-Bees of North America printed 188-190 (2007), under the ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here. D-Bees cache p189-p191 (cache page = printed folio + 1) and Lone Star cache p164 and p176 read off 170 dpi renders. The D-Bees entry opens under the heading Simvan Monster Riders on printed 188, its stat block Simvan Monster Riders - Optional Player Character and NPC starts in the left column of printed 189 and ends at Rivals and Enemies in the right column of printed 190, where Slurmph begins. || HEADING: a D-Bee race printed as an optional player character with its own R.C.C. skills and Available O.C.C.s: None, so category rcc and self-contained, as held. No sdc_base or mdc_base: S.D.C. is printed as flat dice 2D6x10, stored as bonuses.pools.sdc with men_of_arms: false (a race). Hit Points 1D4x10 with no per level gain printed. || UNCHANGED BY D-BEES (both books print the same): the eight attribute dice, Horror Factor 12, size and weight, Hit Points 1D4x10, S.D.C. 2D6x10, P.P.E. 4D4 males and 4D6 females, keen vision and nightvision 120 feet, the I.S.P. of each sex and the named powers of each sex. || ALIGNMENT: D-Bees prints Any, but the majority are Anarchist (30%), Aberrant (30%) and Miscreant (20%); Lone Star printed 163 gave Aberrant evil, or any, and as NPC villains likely anarchist, aberrant or other evil. The percentages describe the population and are in GM Notes. || BONUSES: D-Bees prints +1 on initiative, +1 on Perception Rolls, +1 to strike, +1 to parry and dodge, +2 to pull punch, +1 to roll with impact, +2 to save vs Horror Factor and +2 to save vs spoiled meat/food (stored as saves.other). Lone Star printed 163 gave no bonus line at all. || ATTACKS: D-Bees prints Attacks per Melee: As per Hand to Hand Combat skill, so no attacks figure is stored. Lone Star printed 163 gave two attacks per melee round plus those of the hand to hand training, which was stored as bonuses.combat.attacks 2 and is removed. || SKILLS OF BOTH SEXES (parent list): Running and W.P. Knife, which D-Bees prints in both the male and the female line. Climbing was in the parent list at 40 with no bonus (Lone Star printed 163 gave both sexes climbing); D-Bees prints Climbing (+10%) for males and leaves it out of the complete female line, so it is now a male skill only. || MALES as D-Bees prints them: All Wilderness Skills with a +20% bonus on each, stored as the nine Wilderness skills the class already held (judgement made at the first import: the Rifts main rule book list; rows added by later books are left out) - Boat Building 25+20, Carpentry 25+20, Hunting, Identify Plants & Fruit 25+20, Land Navigation 36+20, Preserve Food 25+20, Skin & Prepare Animal Hides 30+20, Track & Trap Animals 20+20 - and Wilderness Survival at its own +30 (30+30); Athletics (General); Body Building; Climbing 40+10; Dance 30+10; Hand to Hand: Expert or Assassin (pick one), a choice of one; Horsemanship: Cowboy 66+10; Horsemanship: Exotic Animals 30+30; Math: Basic (catalog Mathematics: Basic) 45+20; three Physical skills of choice; Recognize Weapon Quality 25+10; Running; Sing 35+10; Track (people) (catalog Tracking (people)) 25+20; W.P. Archery, W.P. Targeting, W.P. Knife, W.P. Energy Rifle and three W.P.s of choice (any). Lone Star printed 163 gave males horsemanship (and, in this case, monstermanship; +20%), which was stored as Horsemanship: General 60 and Horsemanship: Exotic Animals 50; dance and sing with no bonus (30 and 35); Hand to Hand: Assassin with no choice; three other Physical skills with boxing and acrobatics not available, an exclusion D-Bees does not print and which is removed; and no Math, no Recognize Weapon Quality and no bonus on climbing. || FEMALES as D-Bees prints them: All Domestic (+30% on all), stored as the six Domestic skills the class already held (the same judgement) - Cook 35+30, Dance 30+30, Fishing 40+30, Sewing 40+30, Sing 35+30, Play Musical Instrument 35+30; Wilderness Skills (+10%), the same nine with Wilderness Survival now at 30+10; Animal Husbandry 35+20; Breed Dogs 40+20; Brewing 25+10; Brewing: Medicinal 25+15; Holistic Medicine 20+20; Hand to Hand: Basic; Horsemanship: General 40+10; Horsemanship: Exotic Animals 30+20; Running; two Physical skills of choice; Veterinary Science 50+15; W.P. Blunt, W.P. Knife and two W.P.s of choice (any). The same line also prints Cook (+10%), Dance (+10%) and Sing (+15%) after its +30% on all Domestic; whether those are added to the +30% or are a restatement is not said, and the three are stored at the +30% only (judgement). Lone Star printed 163 gave females wilderness survival (+15%), stored as 45, which the complete D-Bees line leaves out; horsemanship (and monstermanship) with no bonus, stored as General 40 and Exotic Animals 30; climbing; and none of Animal Husbandry, Breed Dogs, Brewing, Brewing: Medicinal or Veterinary Science. || RELATED SKILLS: D-Bees prints R.C.C. Related Skills (male or female): a total of five from Communications (any, +5%), Cowboy (any, +10%), Domestic (any, +10%), Espionage (Detect Ambush, Escape Artist, Intelligence and Interrogation only; +5%), Pilot (Motorcycle, Automobile, Hover Craft, Hovercycle, Sail, Paddle or Motor Boat only, +10%), Rogue (any, except Computer Hacking), Technical (Appraise Goods, Gemology, any Lore skills, Salvage and Whittling only, +5%) and W.P. (any), with the note that only Simvan females may also select from Medical skills. Stored as occ_related_skills with count 5; the pilot names are the catalog rows Motorcycles & Snowmobiles, Automobile, Hover Craft (ground), Hovercycles, Skycycles & Rocket Bikes, Boat: Sail Type, Boat: Paddle Types/Canoe/Kayak and Boat: Motor, Race & Hydrofoil; Whittling is Whittling & Sculpting; any Lore skills is every Technical Lore row of the Rifts catalog. The Medical category for females is a restriction line, not a category, because it belongs to one sex. Lone Star printed 163 gave instead a total of six skills, no bonuses applicable, from Radio: basic, escape artist, pick pockets, palming, concealment, pilot motorcycle, pilot automobile, pilot hover craft, pilot sail or motor boat, monster lore, faerie lore, any languages and art; that was stored as one choice of six in the parent skill list and is removed. || SECONDARY SKILLS: D-Bees prints two at levels 2, 4, 8 and 10 from the Secondary Skills List of Rifts Ultimate Edition page 300, at base level; stored as a count of 0 and a schedule. Lone Star printed none. || EXPERIENCE: D-Bees prints Use the same Experience Table as the Psi-Stalker; the ladder is copied from the stored xp_table of the production class psi-stalker (0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501). Lone Star''s Experience Tables page (folio 175, cache p176) gave the class its own column headed Monkey Boy Tech, Simvan Monster Rider: 0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001. Experience Level 1D8 for NPCs is in GM Notes; Lone Star gave most males as 3rd to 9th level (2D4+1). || PSIONICS: neither book names a tier; major is kept for both (judgement made at the first import). Males: I.S.P. 2D4x10+M.E., Empathy, Mind Block, Mind Bond, Sixth Sense, Telepathy and the Psionic Empathy with Animals (special) that D-Bees now describes in full (the catalog power of that name, with the description in the ability text); Lone Star printed 163 called it a psychic affinity with animals similar to the Psi-Stalker''s. Females: I.S.P. 4D4x10+M.E., Deaden Pain, Detect Psionics, Exorcism, Healing Touch, Increase Healing (catalog Increased Healing), Psychic Diagnosis, Psychic Surgery and one Healing ability of choice at levels 1, 3, 6, 9 and 12, stored as one starting pick and a schedule; Lone Star printed 163 gave one healing ability of choice, once. The I.S.P. costs D-Bees prints beside each power are the powers'' own and are not stored on the class. Magic: None. || MONSTER TAMING: the 1D20 roll for each attack in the melee, the 1-6 failure and the one I.S.P. cost are D-Bees printed 190 and are in the Monster Riders natural ability; Lone Star printed no procedure. || EQUIPMENT as D-Bees prints it: Vibro-Knife (vibro-knife), survival knife (survival-knife), one weapon for every W.P. (a restriction line: it depends on the W.P.s chosen), 1D4+1 E-Clips for each energy weapon (e-clip, one roll), 2D6+10 arrows (arrows-standard), 1D6+2 M.D. arrows (mdc-arrow), light or medium Mega-Damage body armor (light-mdc-body-armor, the row the class already used), 1D6 wooden stakes (wooden-stake), a wooden mallet (small-mallet), a wood or silver cross (a choice of wooden-cross or small-silver-cross; no size is printed), backpack, saddlebag (saddlebags), 1D4 large sacks (large-sack), two small sacks (small-sack), military style utility belt with gun holster (utility-belt and gun-holster), binoculars, air filter or gas mask, some personal items, and a horse, Ostrosaurus or Silonar for a riding animal (the Monster Riders natural ability). Lone Star printed 163 gave knife and two energy weapons and perhaps bow and arrows, light mega-damage body armor, backpack, a couple of sacks, utility/ammo-belt, gun holster, binoculars, air filter or gas mask and personal items, and a horse or Ostrosaurus; the knife, the two energy weapon choices, the two plain sacks and the utility/ammo-belt of that list are removed. || MONEY: D-Bees prints 1D4x100 credits and 2D6x1,000 in trade goods; the credits are starting_money and the trade goods a restriction line. Lone Star printed no money. || CYBERNETICS: D-Bees prints Avoids them as unnatural; Lone Star printed nothing. || NOT STORED: Average Life Span 3D6+44 years, Slave Market Value 3D6x1,000 credits, the alignment percentages and the NPC experience level are in GM Notes. Neither book prints a language line or a hand to hand upgrade price. || TAGS: combat, hunter and wilderness for the males the book describes as warriors, trackers and hunters; the females are the tribe''s psychic healers. Not evil: the alignment line is any."
---

## Lore

The Simvan came through the Calgary Rift and spread across the plains and
deserts of the West, down into the Pecos Empire and northern Mexico. They live
as nomads in clans of a few hundred to a couple of thousand, pitching camp for
a season and moving on when the game thins out or the neighbours turn dangerous.

Inside the tribe they are warm, patient and quick to laugh. Toward everyone
else they are proud, short-tempered and frightening, and they are cannibals:
other humanoids are either useful or edible, and a brave enemy is the finest
meal there is. That does not stop them trading. Simvan sell furs, horses and
their own services as scouts, hunters and hired guns, and they get along well
with mutant animals. With the Psi-Stalkers, once close friends, a feud that
began in the Pecos Empire has spread through most of both peoples.

The men hunt, track and fight, and treat a dangerous challenge as the point of
being alive. The women run the camp and are its healers, born with psychic
healing powers the men lack. The name Monster Rider comes from the race''s gift
for breaking savage, meat-eating beasts to the saddle, above all the two-legged
dinosaur called the Ostrosaurus.

## GM Notes

Pick the male or female variant AND the psionic powers entry of the same sex;
the two choices must match. The variant sets P.P.E. and skills, the powers
entry sets I.S.P. and psionics. The book names no psionic tier; major is used.

A player character starts with a horse, an Ostrosaurus or a Silonar as a riding
animal, which is not on the equipment list. The catalog holds the Ostrosaurus
as a creature from Rifts World Book 14: New West.

Beyond the listed kit a Simvan carries one weapon for every W.P. and some
personal items, and has 2D6x1,000 credits in trade goods. Favorite weapons
include Vibro-Blades, M.D. arrows and bows, powerful energy weapons and magic
items, especially magic melee weapons; they have adopted long-range guns but
prefer to fight in close combat with melee weapons.

Only females may take R.C.C. Related Skills from the Medical category. The
book prints no language and no hand to hand upgrade price.

Alignment is any, but the majority are Anarchist (30%), Aberrant (30%) and
Miscreant (20%). NPCs are 1D8 in experience level or as set by the Game Master.
Average life span is 3D6+44 years, with physical maturity at 16. Slave market
value is 3D6x1,000 credits, particularly as animal trainers, cattle wranglers,
warriors and gladiators. Allies are other Simvan tribes, the Ronii Tokanii
tribesmen, and Tokanii and Pecos bandits in general; Simvan welcome intelligent
mutant animals, Were-Beasts and any animal-like D-Bee. The feud with the
Psi-Stalkers runs from friendly rivalry to hatred depending on tribe and
region, and the Coalition Army is an enemy. Among outsiders the Simvan''s Horror
Factor and diet make them hard company.
',
       updated_at = datetime('now')
 WHERE class_id = 'simvan-monster-rider'
   AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.162-163') > 0
   AND length(markdown) = 17936;

-- == psi-x-alien ==
UPDATE imported_classes
   SET markdown = '---
id: psi-x-alien
name: Psi-X Alien
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.166-168
category: rcc
tags: []
xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6"
  MA: "2d6"
  PS: "2d4+4"
  PP: "2d4+4"
  PE: "2d4+1"
  PB: "2d4+2"
  Spd: "2d6+4"
hit_points_base: "P.E. x2 + 1d6 per level"
sdc_base: "2d6+2"
ppe_base: "P.E. x10"
starting_money: "3d6x100"
psionics:
  type: "master"
  powers: ["See Aura", "Sense Magic", "Detect Psionics", "Bio-Regeneration"]
bonuses:
  combat: { attacks_base: 1 }
  saves: { horror_factor: 5, illusionary_magic: 5 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { choose: 2, from: ["Language: Other"], bonus: 48, note: "Speaks two languages of choice at 98%: stored as +48% on the catalog base of 50%, which is 98% at level one. Taken once per language - the picker asks which." }
  secondary_skills:
    count: 4
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
equipment_starting:
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "energy-weapon-of-choice", qty: 1, note: "One energy weapon of choice; the Psi-X prefer light, rapid-fire energy weapons or magic items." }
  - { item_id: "e-clip", qty: "1d4", note: "1D4 additional E-clips for the weapon." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "protective-goggles", qty: 1, note: "Protective eye goggles; the Psi-X must keep tinted coverings over the eyes in daylight." }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says universal translator." }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "Cigarette lighter." }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "clothing", qty: 2, note: "A couple sets of clothing, and some personal items." }
natural_abilities:
  - { name: "Size and Life Span", description: "Weight 90 to 130 lbs (40.5 to 58.5 kg). Height 4 to 5.6 feet (1.2 to 1.7 m). Average life span 1D6x10+170 years; physical maturity comes around age 20. Completely hairless, with a huge head, large dark eyes and a small, slight frame. P.B. is by human standards." }
  - { name: "Psi-X Vision", description: "Nightvision 3000 ft (914 m), hawk-like color vision, sees the infrared and ultraviolet spectrums of light, sees electromagnetic energy, and sees the invisible as an automatic ability (including Astral beings, entities and energy beings)." }
  - { name: "Psi-Powers of Every Psi-X", description: "See Aura, Sense Magic, Detect Psionics and Bio-Regeneration (healing), on top of the powers rolled on the random psi-power table." }
  - { name: "Telekinetic Hover", description: "A unique, telekinesis related ability to hover and move 1-4 feet (0.3 to 1.2 m) above the ground instead of walking. It is the natural mode of travel, at the same speed as the Spd attribute; the Psi-X has to concentrate to negate it and walk on its own two legs. It costs no I.S.P." }
  - { name: "Attacks Per Melee Round", description: "One physical attack at levels 1, 2, 4, 8 and 12, OR two attacks via psionics at levels 1, 3, 6, 10 and 15. The physical ladder is the one counted on the sheet; the psionic ladder (2 at level 1, 4 at level 3, 6 at level 6, 8 at level 10, 10 at level 15) is tracked by hand." }
  - { name: "M.A. and Alignment", description: "M.A. is 2D6, +2 if the character is of a good alignment (added by hand)." }
special_abilities:
  - { choose: 1, from: ["Psi-Powers (01-12): Kineticist", "Psi-Powers (13-24): Psychic Sensitive", "Psi-Powers (25-37): Psychic Energy Conduit", "Psi-Powers (38-49): Psychic Intuitive", "Psi-Powers (50-61): Psychic Spiritualist", "Psi-Powers (62-73): Psychic Manipulator", "Psi-Powers (74-85): Healer", "Psi-Powers (86-97): Closed Mind", "Psi-Powers (98-00): Mind Melter"], note: "Random Psi-Powers: roll percentile dice and take the entry rolled." }
  - name: "Psi-Powers (01-12): Kineticist"
    description: "Roll 01-12. Has all kinesis abilities, including Telekinesis (Super), Telekinetic Acceleration Attack, Telekinetic Force Field, Telekinetic Leap, Telekinetic Lift, Telekinetic Punch, Telekinetic Push, Levitation, Electrokinesis, Hydrokinesis and Pyrokinesis. The eleven named powers and ordinary Telekinesis are granted; any other kinesis power is the G.M.''s call."
    psionics:
      type: "master"
      powers: ["Telekinesis", "Telekinesis (Super)", "Telekinetic Acceleration Attack", "Telekinetic Force Field", "Telekinetic Leap", "Telekinetic Lift", "Telekinetic Punch", "Telekinetic Push", "Levitation", "Electrokinesis", "Hydrokinesis", "Pyrokinesis"]
  - name: "Psi-Powers (13-24): Psychic Sensitive"
    description: "Roll 13-24. All Sensitive abilities, including Empathic Transmission, all at double the normal range and duration (the doubling is applied by hand)."
    psionics:
      type: "master"
      powers: ["Astral Projection", "Clairvoyance", "Commune with Spirit", "Empathy", "Intuitive Combat", "Machine Ghost", "Mask I.S.P. & Psionics", "Mask P.P.E.", "Meditation", "Object Read (Psychometry)", "Presence Sense", "Read Dimensional Portal", "Remote Viewing", "See Aura", "See The Invisible", "Sense Dimensional Anomaly", "Sense Evil", "Sense Magic", "Sense Time", "Sixth Sense", "Speed Reading", "Telepathy", "Total Recall", "Empathic Transmission"]
  - name: "Psi-Powers (25-37): Psychic Energy Conduit"
    description: "Roll 25-37. Psi-Sword, Psi-Shield, Electrokinesis, Pyrokinesis, Mind Bolt, Summon Inner Strength and Impervious to Fire (even mega-damage fire)."
    psionics:
      type: "master"
      powers: ["Psi-Sword", "Psi-Shield", "Electrokinesis", "Pyrokinesis", "Mind Bolt", "Summon Inner Strength", "Impervious to Fire"]
  - name: "Psi-Powers (38-49): Psychic Intuitive"
    description: "Roll 38-49. Clairvoyance, Intuitive Combat, Object Read, Presence Sense, Psychic Diagnosis, Read Dimensional Portal, Sense Dimensional Anomaly, Sense Evil, Sense Magic, Sense Time, Sixth Sense and Telemechanics."
    psionics:
      type: "master"
      powers: ["Telemechanics", "Clairvoyance", "Object Read (Psychometry)", "Presence Sense", "Sense Evil", "Sense Magic", "Sixth Sense", "Psychic Diagnosis", "Intuitive Combat", "Read Dimensional Portal", "Sense Dimensional Anomaly", "Sense Time"]
  - name: "Psi-Powers (50-61): Psychic Spiritualist"
    description: "Roll 50-61. Astral Projection (+20% to find the way home), Clairvoyance, Commune with Spirits, Ectoplasm, Object Read, Psychic Omni-Sight, See Aura and Telepathy."
    psionics:
      type: "master"
      powers: ["See Aura", "Clairvoyance", "Object Read (Psychometry)", "Telepathy", "Astral Projection", "Ectoplasm", "Commune with Spirit", "Psychic Omni-Sight"]
  - name: "Psi-Powers (62-73): Psychic Manipulator"
    description: "Roll 62-73. Bio-Manipulation, Deaden Pain, Empathic Transmission, Empathy, Hypnotic Suggestion, Increased Healing, Induce Sleep, Mentally Possess Others, Mind Wipe, Psychic Purification, Psychosomatic Disease, Radiate Horror Factor, Stop Bleeding, Telemechanic Mental Operation and Telepathy."
    psionics:
      type: "master"
      powers: ["Empathic Transmission", "Empathy", "Telepathy", "Hypnotic Suggestion", "Mentally Possess Others", "Mind Wipe", "Induce Sleep", "Bio-Manipulation (the evil eye)", "Deaden Pain", "Increased Healing", "Psychic Purification", "Psychosomatic Disease", "Radiate Horror Factor", "Stop Bleeding", "Telemechanic Mental Operation"]
  - name: "Psi-Powers (74-85): Healer"
    description: "Roll 74-85. All Healing powers. Healing Touch does double the usual level of healing, and the character is +30% to perform an exorcism (both applied by hand)."
    psionics:
      type: "master"
      powers: ["Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear"]
  - name: "Psi-Powers (86-97): Closed Mind"
    description: "Roll 86-97. Group Mind Block, Mind Block, Mind Block Auto-Defense, P.P.E. Shield, Psionic Invisibility and Suppress Fear, and the character is impervious to empathy, empathic transmission, mind bond, mind wipe, possession, see aura, presence sense, remote viewing (cannot be found or seen) and all vampire powers."
    psionics:
      type: "master"
      powers: ["Mind Block", "Group Mind Block", "P.P.E. Shield", "Mind Block Auto-Defense", "Psionic Invisibility", "Suppress Fear"]
  - name: "Psi-Powers (98-00): Mind Melter"
    description: "Roll 98-00. Powers as per the Mind Melter psychic O.C.C. No powers are granted here: the G.M. gives the character that O.C.C.''s powers."
    psionics:
      type: "master"
  - { choose: 1, from: ["I.S.P. (01-20): M.E. x10", "I.S.P. (21-40): M.E. x5", "I.S.P. (41-60): M.E. x2", "I.S.P. (61-80): M.E. x3", "I.S.P. (81-00): M.E. number"], note: "I.S.P.: roll percentile dice to determine the random level of power." }
  - name: "I.S.P. (01-20): M.E. x10"
    description: "Roll 01-20. I.S.P. is the M.E. attribute number x10, +8 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x10, +8 per level"
  - name: "I.S.P. (21-40): M.E. x5"
    description: "Roll 21-40. I.S.P. is the M.E. attribute number x5, +2D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x5, +2d6 per level"
  - name: "I.S.P. (41-60): M.E. x2"
    description: "Roll 41-60. I.S.P. is the M.E. attribute number x2, +12 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x2, +12 per level"
  - name: "I.S.P. (61-80): M.E. x3"
    description: "Roll 61-80. I.S.P. is the M.E. attribute number x3, +1D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x3, +1d6 per level"
  - name: "I.S.P. (81-00): M.E. number"
    description: "Roll 81-00. I.S.P. is the M.E. attribute number, +4D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E., +4d6 per level"
side_effects: "Terrible day vision (40 ft / 12 m), and eyes so sensitive to light that some sort of tinted protective covering must be worn over them; blinded by bright sunlight, flashbulbs and other bright lights. Ley lines increase the psychic''s powers as usual, but also heighten confidence, aggression and other base and evil emotions. Insanity: randomly roll or determine three phobias and one obsession. Tires easily (one third the endurance of a normal human), and is prone to substance abuse and easily addicted to alcohol and drugs."
restrictions:
  - "Optional player character and NPC."
  - "Alignment: any, but they tend to vary in extremes: principled (30%), diabolic (30%), aberrant (17%) and anarchist (17%)."
  - "Magic: none."
  - "Skills: two languages plus ONE skill category of choice, chosen with the class - every skill in that category is known at +20%. Outside it the Psi-X learns only its secondary skills. R.C.C. Related Skills: none."
  - "Secondary skills come from the Secondary Skill List of Rifts Ultimate Edition page 300, and all start at the base skill level."
  - "Available O.C.C.s: none, although depending on its skill category a Psi-X can get employment as a doctor, mechanic, electrician, researcher and so on."
  - "M.D.C.: via body armor, force fields or psionics."
  - "May use light armor; prefers light, rapid-fire energy weapons or magic items."
variants:
  - id: communications
    name: "Psi-X Alien (Communications)"
    skills_additional:
      occ_skills:
        - { name: "Barter", base: 50, per_level: 4, note: "+20%" }
        - { name: "Cryptography", base: 45, per_level: 5, note: "+20%" }
        - { name: "Electronic Countermeasures", base: 50, per_level: 5, note: "+20%" }
        - { name: "Language: Dolphin/Whale", base: 70, per_level: 5, note: "+20%" }
        - { name: "Laser Communications", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Euro", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Gypsy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%" }
        - { name: "Literacy: Russian", base: 50, per_level: 5, note: "+20%" }
        - { name: "Optic Systems", base: 50, per_level: 5, note: "+20%" }
        - { name: "Performance", base: 50, per_level: 5, note: "+20%" }
        - { name: "Public Speaking", base: 50, per_level: 5, note: "+20%" }
        - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
        - { name: "Radio: Scramblers", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sign Language", base: 45, per_level: 5, note: "+20%" }
        - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
        - { name: "Space: Radio: Deep Space", base: 65, per_level: 5, note: "+20%" }
        - { name: "Surveillance", base: 50, per_level: 5, note: "+20%" }
        - { name: "T.V./Video", base: 45, per_level: 4, note: "+20%" }
  - id: electrical
    name: "Psi-X Alien (Electrical)"
    skills_additional:
      occ_skills:
        - { name: "Basic Electronics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Computer Repair", base: 45, per_level: 5, note: "+20%" }
        - { name: "Electrical Engineer", base: 50, per_level: 5, note: "+20%" }
        - { name: "Electricity Generation", base: 70, per_level: 5, note: "+20%" }
        - { name: "Robot Electronics", base: 50, per_level: 5, note: "+20%" }
  - id: mechanical
    name: "Psi-X Alien (Mechanical)"
    skills_additional:
      occ_skills:
        - { name: "Aircraft Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Automotive Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Basic Mechanics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Bioware Mechanics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Locksmith", base: 45, per_level: 5, note: "+20%" }
        - { name: "Mechanical Engineer", base: 45, per_level: 5, note: "+20%" }
        - { name: "Robot Mechanics", base: 40, per_level: 5, note: "+20%" }
        - { name: "Ship Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Space: Satellite Systems", base: 50, per_level: 5, note: "+20%" }
        - { name: "Space: Spacecraft Mechanics", base: 40, per_level: 5, note: "+20%" }
        - { name: "Submersible Vehicle Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Vehicle Armorer", base: 50, per_level: 5, note: "+20%" }
        - { name: "Weapons Engineer", base: 45, per_level: 5, note: "+20%" }
  - id: medical
    name: "Psi-X Alien (Medical)"
    skills_additional:
      occ_skills:
        - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
        - { name: "Brewing", base: 45, per_level: 5, note: "+20%" }
        - { name: "Brewing: Medicinal", base: 45, per_level: 5, note: "+20%" }
        - { name: "Crime Scene Investigation", base: 55, per_level: 5, note: "+20%" }
        - { name: "Cybernetic Medicine", base: 60, per_level: 5, note: "+20%" }
        - { name: "Doctor of Veterinary Medicine", base: 80, per_level: 5, note: "+20%" }
        - { name: "Entomological Medicine", base: 60, per_level: 5, note: "+20%" }
        - { name: "Field Surgery", base: 36, per_level: 4, note: "+20%" }
        - { name: "First Aid", base: 65, per_level: 5, note: "+20%" }
        - { name: "Forensics", base: 55, per_level: 5, note: "+20%" }
        - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
        - { name: "Juicer Technology", base: 60, per_level: 5, note: "+20%" }
        - { name: "M.D. in Cybernetics", base: 60, per_level: 5, note: "+20%" }
        - { name: "Medical Doctor", base: 80, per_level: 5, note: "+20%" }
        - { name: "Paramedic", base: 60, per_level: 5, note: "+20%" }
        - { name: "Pathology", base: 60, per_level: 5, note: "+20%" }
        - { name: "Psychology", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sea Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
        - { name: "Veterinary Science", base: 70, per_level: 4, note: "+20%" }
  - id: pilot-related
    name: "Psi-X Alien (Pilot Related)"
    skills_additional:
      occ_skills:
        - { name: "Navigation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Stellar", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Terrestrial", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "+20%" }
        - { name: "Radar/Sonar Operations", base: 50, per_level: 5, note: "+20%" }
        - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20%" }
        - { name: "Weapon Systems", base: 60, per_level: 5, note: "+20%" }
  - id: rogue
    name: "Psi-X Alien (Rogue)"
    skills_additional:
      occ_skills:
        - { name: "Cardsharp", base: 44, per_level: 4, note: "+20%" }
        - { name: "Computer Hacking", base: 35, per_level: 5, note: "+20%" }
        - { name: "Concealment", base: 40, per_level: 4, note: "+20%" }
        - { name: "Gambling (Dirty Tricks)", base: 40, per_level: 4, note: "+20%" }
        - { name: "Gambling (Standard)", base: 50, per_level: 5, note: "+20%" }
        - { name: "I.D. Undercover Agent", base: 50, per_level: 4, note: "+20%" }
        - { name: "Imitate Voices & Sounds", base: 62, per_level: 4, note: "+20%" }
        - { name: "Locate Secret Compartments", base: 40, per_level: 5, note: "+20%" }
        - { name: "Palming", base: 40, per_level: 5, note: "+20%" }
        - { name: "Roadwise", base: 46, per_level: 4, note: "+20%" }
        - { name: "Safe-Cracking", base: 40, per_level: 4, note: "+20%" }
        - { name: "Seduction", base: 40, per_level: 3, note: "+20%" }
        - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
        - { name: "Streetwise: Drugs", base: 45, per_level: 5, note: "+20%" }
        - { name: "Tailing", base: 50, per_level: 5, note: "+20%" }
  - id: science
    name: "Psi-X Alien (Science)"
    skills_additional:
      occ_skills:
        - { name: "Anthropology", base: 40, per_level: 5, note: "+20%" }
        - { name: "Antiquarian", base: 60, per_level: 5, note: "+20%" }
        - { name: "Archaeology", base: 40, per_level: 5, note: "+20%" }
        - { name: "Artificial Intelligence", base: 50, per_level: 3, note: "+20%" }
        - { name: "Astronomy", base: 45, per_level: 5, note: "+20%" }
        - { name: "Astronomy & Navigation", base: 50, per_level: 5, note: "+20%" }
        - { name: "Astrophysics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Botany", base: 45, per_level: 5, note: "+20%" }
        - { name: "Chemistry", base: 50, per_level: 5, note: "+20%" }
        - { name: "Chemistry: Pharmaceutical", base: 50, per_level: 5, note: "+20%" }
        - { name: "Geology", base: 45, per_level: 5, note: "+20%" }
        - { name: "Marine Biology", base: 55, per_level: 5, note: "+20%" }
        - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "+20%" }
        - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
        - { name: "Ocean Geographic Surveying", base: 35, per_level: 5, note: "+20%" }
        - { name: "Physics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Undersea Farming", base: 55, per_level: 5, note: "+20%" }
        - { name: "Xenology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Zoology", base: 50, per_level: 5, note: "+20%" }
  - id: technical-languages-lores
    name: "Psi-X Alien (Technical Studies)"
    skills_additional:
      occ_skills:
        - { name: "Computer Hacking", base: 35, per_level: 5, note: "+20%; from Rogue" }
        - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Computer Programming", base: 50, per_level: 5, note: "+20%" }
        - { name: "History", base: 50, per_level: 5, note: "+20%" }
        - { name: "History of the West", base: 50, per_level: 5, note: "+20%" }
        - { name: "History: Post-Apocalypse", base: 55, per_level: 5, note: "+20%" }
        - { name: "History: Pre-Rifts", base: 52, per_level: 4, note: "+20%" }
        - { name: "Japanese Mythology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Law", base: 55, per_level: 5, note: "+20%" }
        - { name: "Law: CCW", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Astral", base: 46, per_level: 4, note: "+20%" }
        - { name: "Lore: D-Bee", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Dimensions", base: 35, per_level: 5, note: "+20%" }
        - { name: "Lore: Faeries & Creatures of Magic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Galactic/Alien", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Juicers", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Magic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Nightbane", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Nightlands", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Psychics & Psionics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Vampires", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Wormwood", base: 40, per_level: 5, note: "+20%" }
        - { name: "Mythology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Research", base: 60, per_level: 5, note: "+20%" }
  - id: technical-others
    name: "Psi-X Alien (Technical Applications)"
    skills_additional:
      occ_skills:
        - { name: "Advanced Fishing", base: 50, per_level: 5, note: "+20%" }
        - { name: "Appraise Goods", base: 50, per_level: 5, note: "+20%" }
        - { name: "Art", base: 55, per_level: 5, note: "+20%" }
        - { name: "Art: Line Drawing", base: 55, per_level: 5, note: "+20%" }
        - { name: "Begging", base: 50, per_level: 3, note: "+20%" }
        - { name: "Breed Dogs", base: 60, per_level: 5, note: "+20%" }
        - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%" }
        - { name: "Creative Writing", base: 45, per_level: 5, note: "+20%" }
        - { name: "Cyberjacking", base: 70, per_level: 3, note: "+20%" }
        - { name: "Cybernetics: Basic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Excavation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Firefighting", base: 50, per_level: 5, note: "+20%" }
        - { name: "Gemology", base: 45, per_level: 5, note: "+20%" }
        - { name: "General Repair & Maintenance", base: 55, per_level: 5, note: "+20%" }
        - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
        - { name: "Language Dialects", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Amaki", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Ancient Greek", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Arkhon", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Aymara", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Brodkil", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Chinese", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Creole", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Dragonese", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Dwarven", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Euro", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gargoyle", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gobblely", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gypsy", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Larhold", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Mongolian", base: 60, per_level: 5, note: "+20%" }
        - { name: "Language: Old Norse", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Quechua", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Russian", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Spanish", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Five/Reptile", base: 60, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Four", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade One", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Six", base: 65, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Three", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Two", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Troll/Giant", base: 70, per_level: 5, note: "+20%" }
        - { name: "Leather Working", base: 60, per_level: 5, note: "+20%" }
        - { name: "Literacy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Dragonese/Elven", base: 50, per_level: 5, note: "+20%" }
        - { name: "Masonry", base: 60, per_level: 5, note: "+20%" }
        - { name: "Metalwork and Forge", base: 80, per_level: 3, note: "+20%" }
        - { name: "Mining", base: 55, per_level: 5, note: "+20%" }
        - { name: "Philosophy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Photography", base: 55, per_level: 5, note: "+20%" }
        - { name: "Prospecting", base: 40, per_level: 5, note: "+20%" }
        - { name: "Recognize Enchantment", base: 30, per_level: 5, note: "+20%" }
        - { name: "Recognize Wards, Runes & Circles", base: 35, per_level: 5, note: "+20%" }
        - { name: "Recycling", base: 50, per_level: 5, note: "+20%" }
        - { name: "Rope Works", base: 50, per_level: 5, note: "+20%" }
        - { name: "Salvage", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sculpt, Carve & Whittle Wood", base: 90, per_level: 3, note: "+20%" }
        - { name: "Shape, Engrave, Etch & Emboss Metal", base: 90, per_level: 3, note: "+20%" }
        - { name: "Undersea Salvage", base: 50, per_level: 5, note: "+20%" }
        - { name: "Ventriloquism", base: 36, per_level: 4, note: "+20%" }
        - { name: "Whittling & Sculpting", base: 50, per_level: 5, note: "+20%" }
extraction_notes: "This class followed Rifts World Book 13: Lone Star printed 98-100 until the update of 2026-10-04 (ruling of that date: the newest printing that states a figure wins, and the older figure is kept here); it now follows Rifts World Book 30: D-Bees of North America printed 166-168, whose own Note says the entry originally appeared in Lone Star. D-Bees printed 166-168 (cache p167-p169, cache page = printed folio + 1): the heading and the first paragraph of the introduction are on 166, the rest of the introduction and the stat block down to Vulnerabilities on 167, Insanity, Psionics, the psi-power table, I.S.P., equipment, money and the closing lines on 168, where Quick-Flex Alien begins. Lone Star printed 98-100 (cache p099-p101, same offset): the introduction and the R.C.C. heading are on 98, natural abilities, bonuses, attacks, penalties and the psi-power table on 99, the last table entry, I.S.P., disposition, skills and equipment on 100, where Notable CS Characters begins. All numbers of both books read off 170 dpi renders; the D-Bees psi-power table was read again at 300 dpi. || HEADING: D-Bees heads the block Psi-X Alien - Optional Player Character and NPC, Race: Genetically Altered Humans believed to be D-Bees. Lone Star printed 98 gave Psi-X Alien R.C.C., Optional Player Character - and a great NPC Villain, Race: Genetically Altered Human. D-Bees prints Available O.C.C.s: None (a restrictions line); Lone Star did not name O.C.C.s at all. Neither entry calls for a roll on the Human Special Abilities table of Lone Star printed 97. || ALIGNMENT: D-Bees prints Principled (30%), Diabolic (30%), Aberrant (17%), Anarchist (17%), which adds up to 94. Lone Star printed 98 gave 30% principled, 30% diabolic, 30% anarchist and 10% other. || XP: D-Bees printed 167 says to use the same experience table as the Mind Melter, so the ladder stored is a copy of the production mind-melter class''s xp_table (Rifts Ultimate Edition). Lone Star gave the ladder headed Psi-X Alien, Xiticix Killer on the unnumbered Experience Tables page after its printed 174 (cache p176): 0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001. || ATTRIBUTES, the same in both books: I.Q. 3D6+6 (but special, see skills), M.E. 3D6, M.A. 2D6 (+2 if a good alignment: text), P.S. 2D4+4, P.P. 2D4+4, P.E. 2D4+1, P.B. 2D4+2, Spd 2D6+4. Lone Star adds by human standards after P.B.; D-Bees does not restate those words and they are kept. || SIZE: the same weight and height in both books (D-Bees rounds 1.21 m to 1.2 m). Average life span is 1D6x10+170 years in D-Bees, with physical maturity around age 20; Lone Star printed 98 gave 60-90. || POOLS, the same in both books: hit points P.E. x2 plus 1D6 per level. S.D.C. is printed as 2D6+2 and nothing else - no P.E. term and no plus-those-gained-from-skills wording - so it is the whole figure and is stored as sdc_base with no men_of_arms line (judgement; the entry takes no O.C.C. whose pool it could override). P.P.E. is printed P.E. x10. D-Bees adds M.D.C.: via body armor, force fields or psionics (a restrictions line). || PSIONICS: every Psi-X has See Aura, Sense Magic, Detect Psionics and Bio-Regeneration (stored as the Healing power, not the Super one; Lone Star says healing after it, D-Bees prints its I.S.P. as 6); see the invisible is printed among the vision abilities as automatic and is natural-ability text. D-Bees moves the hover from Natural Abilities to Psionics and adds that it costs no I.S.P. Neither book states a psychic tier or a save target; master is stored because the power packages include Super powers, which only a master holds. || PSI-POWER TABLE: a percentile table (Additional Random Psionic Powers in D-Bees, Random Psi-Powers in Lone Star) stored as a choice of one of nine abilities, each carrying its named powers. The nine bands are the same in both books and skip nothing. D-Bees renames six rows and lengthens seven; the option names follow D-Bees and the Lone Star names and lists are recorded here. 01-12 Kineticist (Lone Star: Kinetesis, listing telekinesis (super), telekinetic force field, levitation, electrokinesis, hydrokinesis, pyrokinesis): D-Bees adds Telekinetic Acceleration Attack, Telekinetic Leap, Telekinetic Lift, Telekinetic Punch and Telekinetic Push. Both books say all kinesis abilities, including the named ones; ordinary Telekinesis is stored on that wording. 13-24 Psychic Sensitive (Lone Star: Psi-Sensitive, all sensitive abilities at double the normal range): D-Bees says all Sensitive abilities, including Empathic Transmission, all at double the normal range and duration. Stored as the 23 Sensitive catalog rows whose source is the Rifts core book, plus Empathic Transmission; the doubling is text. 25-37 Psychic Energy Conduit (Lone Star: Energy Conduit): the same six powers, and D-Bees prints the last item as Impervious to Fire (40; even M.D. fire), in the form it gives a power and its I.S.P. cost, where Lone Star said and impervious to fire (even mega-damage fire). Stored as the catalog power Impervious to Fire, which the catalog holds at 4 I.S.P.; the printed 40 is recorded here and not stored. 38-49 Psychic Intuitive (Lone Star: Intuitive, listing telemechanics, clairvoyance, object read, presence sense evil with no comma, sense magic, sixth sense, psychic diagnosis): D-Bees prints Presence Sense and Sense Evil apart and adds Intuitive Combat, Read Dimensional Portal, Sense Dimensional Anomaly and Sense Time. 50-61 Psychic Spiritualist (Lone Star: Spiritualist, listing see aura, clairvoyance, object read, telepathy, astral projection, ectoplasm): D-Bees adds Commune with Spirits (the catalog row is Commune with Spirit) and Psychic Omni-Sight. The +20% to find the way home on Astral Projection is text in both. 62-73 Psychic Manipulator (Lone Star: Manipulator, listing empathic transmission, empathy, telepathy, hypnotic suggestion, mentally possess others, mind wipe, induce sleep): D-Bees adds Bio-Manipulation (the catalog row carries the words the evil eye), Deaden Pain, Increase Healing (the catalog row is Increased Healing), Psychic Purification, Psychosomatic Disease, Radiate Horror Factor, Stop Bleeding and Telemechanic Mental Operation. 74-85 Healer, the same in both books: all Healing powers, stored as the 15 Healing catalog rows whose source is the Rifts core book; doubled Healing Touch and +30% to perform Exorcism are text. 86-97 Closed Mind (Lone Star: mind block, group mind block, P.P.E. shield, impervious to empathy, empathic transmission, mind bond, mind wipe and possession): D-Bees adds Mind Block Auto-Defense, Psionic Invisibility and Suppress Fear, and adds See Aura, Presence Sense, Remote Viewing (cannot be found or seen) and all vampire powers to the imperviousness, which is text. 98-00 Mind Melter: D-Bees prints Powers as per that Psychic O.C.C.; Lone Star printed only the two words and an exclamation mark. No powers are stored on the row in either case; the G.M. assigns them. The I.S.P. costs D-Bees prints beside the powers are not stored on the class; they match the catalog except Impervious to Fire (printed 40, catalog 4), Stop Bleeding (printed 4, catalog 2) and Mind Block Auto-Defense (printed special, catalog 14). || I.S.P. (Roll to determine random level of Inner Strength in D-Bees) is a second percentile table stored as a choice of one of five abilities, each carrying its isp_base, the same in both books: M.E. x10 +8 per level, M.E. x5 +2D6, M.E. x2 +12, M.E. x3 +1D6, M.E. +4D6 per level. || BONUSES, the same in both books: +5 save vs horror factor, +5 save vs magic illusions (illusionary_magic). || ATTACKS, the same in both books: one physical at levels 1, 2, 4, 8 and 12, or two via psionics at levels 1, 3, 6, 10 and 15. Stored as attacks_base 1 and +1 at levels 2, 4, 8 and 12; the psionic ladder is text. No hand to hand is printed. || SKILLS (R.C.C. Skills of Psi-X Aliens in D-Bees, O.C.C. Skills of Psi-X Aliens in Lone Star): two languages of choice at 98%, stored as two picks of Language: Other at base 98. Then select ONE skill category, all the skills in it known at +20%: stored as nine variants, one per printed category, each adding the catalog''s Rifts skills of that category at catalog base + 20 as the catalog stood on the day of the first import (Communications 19, Electrical 5, Mechanical 13, Medical 19, Pilot Related 7, Rogue 15, Science 20). D-Bees revises the two Technical choices. It prints Technical Studies (all Computer, History, Law, Lore, Myth and Research skills, including Computer Hacking from Rogue) and Technical Applications (all the Technical skills not covered in the previous category; no Computer, Lore, etc. skills, but everything else). Lone Star printed 100 gave technical: languages and lores (all) and technical: others (all, except language and lore). The two variants keep their ids (technical-languages-lores, technical-others) and take the D-Bees names; the 87 Technical rows already held were re-sorted between them - the Computer, History, Law, Lore, Mythology and Research rows to Technical Studies (25, plus Computer Hacking at 35% = 15 + 20), every language row and every other Technical row to Technical Applications (62). Technical rows the catalog gained after the first import were not added in this update. Left out as before: the generic rows Language: Other, Language: Native Tongue and Literacy: Other (a tongue with no row of its own is taken at +20% by hand), and three skills the catalog marks exclusive to another O.C.C. (Professional Restoration, Recognize Authenticity, Recognize Machine Quality). Also left out of Science: the analytical chemistry skill, whose catalog name carries an em-dash that a pure-ASCII class file cannot spell; it is known at 45% (25 + 20) and is added by hand. R.C.C. Related Skills: None in both books, so no related block. Secondary: four at level one and one more at levels 3, 5, 9 and 11 in both books. D-Bees takes them from the Secondary Skill List in Rifts Ultimate Edition, page 300, all at the base skill level, and the category limit is removed; Lone Star printed 100 limited them to the categories of domestic, pilot and W.P. (no bonuses). || EQUIPMENT: survival knife, one energy weapon of choice (the catalog''s energy-weapon-of-choice row), 1D4 additional E-clips, backpack, knapsack, utility belt, air filter, protective eye goggles, universal translator (portable language translator row), cigarette lighter, note pad and canteen in both books. D-Bees adds a portable tool kit, a flashlight, a couple sets of clothing (two of the clothing row) and some personal items (no row; a note on the clothing line). Lone Star printed 100 had none of those four. No armor is listed; may use light armor is a restriction line. || MONEY: D-Bees prints start with 3D6x100 credits. Lone Star printed none and none was stored. || VULNERABILITIES (Penalties of Note in Lone Star): day vision of 40 ft, light-sensitive eyes, the ley line effect, and insanity (three phobias and one obsession) are in both books and are side_effects. D-Bees says ley lines increase confidence, aggression and other base and evil emotions; Lone Star said other base emotions. Lone Star printed 99 also gave: psionic attacks that use bio-manipulation or empathic transmission do double damage and last twice as long. D-Bees restates the block without that sentence, and it was removed. One-third endurance and addiction are in the introduction of both books and stay in side_effects. Disposition is lore. || NPC FIGURES, D-Bees only, no field: experience level 1D10 or as set by the Game Master for NPCs (player characters start at level one); slave market value 1D4x10,000 credits; females give birth to one young after a nine month pregnancy, till the age of 90; habitat mostly the Coalition States of Lone Star, El Dorado and Chi-Town, some in the Pecos Empire and Arzno; alliances none per se; rivals other psychics, and a dislike of slavers, shape-changers, Cyber-Docs, Gene-Splicers and scientists who dabble in genetics."
---

## Lore

The Psi-X are what came of Desmond Bradford''s private, illegal attempt to
find the genetic root of psychic power and switch it on. His subjects were
human, many of them teenagers taken against their will, and he spliced
Psi-Stalker and D-Bee material into them on little more than a hunch. The
psionics arrived. So did a body that never fills out, a hairless oversized
head and a pair of huge dark eyes; one of the first victims said he had been
made into a saucer alien, and the name stuck.

Bradford counts them his worst personal failure, but could not bring himself
to put down people the way the labs put down animals. More than 150 were
quietly turned loose in the Pecos Badlands, where most survived and have
started families.

A Psi-X drifts a few feet off the ground rather than walking, sees almost
everything except a bright afternoon, and leans on its mind for nearly all it
does. Each is brilliant inside one narrow field and hopeless outside it. Good
ones tend to be sunny and guileless, selfish ones sly and boastful, and the
evil ones brooding, cruel and trusting of nobody.

## GM Notes

Two percentile rolls define the character: the psi-power package and the
I.S.P. level. Both are stored as choices, so roll and then pick the entry
rolled. A result of 98-00 on the power table gives the powers of the Mind Melter
O.C.C.; assign that O.C.C.''s powers yourself.

Pick the one skill category with the class. Every skill in it is known at
+20%; outside it the character has two languages and a few secondary skills
and can learn nothing else.

The sheet counts the physical attack ladder. A Psi-X fighting with its mind
uses the other one: two psionic attacks at level 1, with two more at levels
3, 6, 10 and 15. Add +2 M.A. for a good alignment by hand.

Play the drawbacks: day vision of 40 feet, eyes that must stay covered, three
phobias and an obsession, a third of human stamina, and a weakness for drink
and drugs.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-x-alien'
   AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.98-100') > 0
   AND length(markdown) = 32516;

-- == lyn-srial-cloudweaver (a declared copy of lyn-srial; not reprinted in D-Bees) ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial-cloudweaver
name: Lyn-Srial Cloudweaver
system: rifts
source_book: Rifts World Book 14: New West p.135-136
category: rcc
tags: [flyer]
xp_table: [0, 2151, 4301, 9601, 18201, 28401, 38601, 54801, 75201, 100401, 132601, 185801, 240201, 295401, 365601]
copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions", "xp_table"] }
attribute_requirements: { IQ: 18, MA: 18, ME: 18 }
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spell_traditions_allowed: ["cloud"]
  spells: ["Clouds of Defense: Blinding Flash", "Clouds of Defense: Clouds of Light Deflection", "Clouds of Defense: Cloud of Darkness", "Clouds of Defense: Cloud Rider Armor", "Clouds of Defense: Cloud Shield", "Clouds of Defense: Fog of War", "Clouds of Defense: Storm Rider Armor", "Clouds of Travel: Blink of an Eye", "Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Portal", "Clouds of Travel: Cloud of Speed", "Clouds of Travel: Cloud Surfing", "Clouds of Travel: Fly Like The Wind", "Clouds of Travel: Portal to the Beyond", "Clouds of Creation: Cloudweaving", "Clouds of Creation: Cloud Castles", "Clouds of Creation: Create Cloud Figures", "Clouds of Creation: Create Water", "Clouds of Creation: Flying Chariot", "Clouds of Creation: Food from the Heavens", "Clouds of Creation: Globe of Daylight", "Clouds of Creation: Paint the Sky"]
  spell_lists:
    any_but_war:
      - "Clouds of Defense: Blinding Flash"
      - "Clouds of Defense: Clouds of Light Deflection"
      - "Clouds of Defense: Cloud of Darkness"
      - "Clouds of Defense: Cloud Rider Armor"
      - "Clouds of Defense: Cloud Shield"
      - "Clouds of Defense: Fog of War"
      - "Clouds of Defense: Storm Rider Armor"
      - "Clouds of Peace: Cloud of Harmony"
      - "Clouds of Peace: Cloud Haven"
      - "Clouds of Peace: Fog of Peace"
      - "Clouds of Peace: Healing Rain"
      - "Clouds of Peace: Winds of Change"
      - "Clouds of Peace: Winds of Regret"
      - "Clouds of Travel: Blink of an Eye"
      - "Clouds of Travel: Cloud of Ascension"
      - "Clouds of Travel: Cloud Portal"
      - "Clouds of Travel: Cloud of Speed"
      - "Clouds of Travel: Cloud Surfing"
      - "Clouds of Travel: Fly Like The Wind"
      - "Clouds of Travel: Portal to the Beyond"
      - "Clouds of Survival: Aerial Navigation"
      - "Clouds of Survival: Breath of Life"
      - "Clouds of Survival: Calm Storms"
      - "Clouds of Survival: Cloud of Healing"
      - "Clouds of Survival: Globe of Daylight"
      - "Clouds of Survival: Hunter''s Instinct"
      - "Clouds of Survival: See the Invisible"
      - "Clouds of Survival: See the Light"
      - "Clouds of Survival: Tongues"
      - "Clouds of Survival: Warmth of the Sun"
      - "Clouds of the Mind: Cloud of Insanity"
      - "Clouds of the Mind: Clouds of Truth"
      - "Clouds of the Mind: Mind Fog"
      - "Clouds of the Mind: Mind Over Matter"
      - "Clouds of the Mind: Mist of Illusion"
      - "Clouds of the Mind: Spirit Mist"
      - "Clouds of the Mind: Warrior''s Mist"
      - "Clouds of Creation: Cloudweaving"
      - "Clouds of Creation: Cloud Castles"
      - "Clouds of Creation: Create Cloud Figures"
      - "Clouds of Creation: Create Water"
      - "Clouds of Creation: Flying Chariot"
      - "Clouds of Creation: Food from the Heavens"
      - "Clouds of Creation: Globe of Daylight"
      - "Clouds of Creation: Paint the Sky"
  spells_starting: 2
  spells_starting_groups:
    - { count: 2, from_list: "any_but_war", note: "Two more Cloud spells from any category except Clouds of War, from level one (printed 135)." }
  spells_schedule:
    - { level: 2, count: 2, from_list: "any_but_war" }
    - { level: 3, count: 2, from_list: "any_but_war" }
    - { level: 4, count: 2, from_list: "any_but_war" }
    - { level: 5, count: 2, from_list: "any_but_war" }
    - { level: 6, count: 2, from_list: "any_but_war" }
    - { level: 7, count: 2, from_list: "any_but_war" }
    - { level: 8, count: 2, from_list: "any_but_war" }
    - { level: 9, count: 2, from_list: "any_but_war" }
    - { level: 10, count: 2, from_list: "any_but_war" }
    - { level: 11, count: 2, from_list: "any_but_war" }
    - { level: 12, count: 2, from_list: "any_but_war" }
    - { level: 13, count: 2, from_list: "any_but_war" }
    - { level: 14, count: 2, from_list: "any_but_war" }
    - { level: 15, count: 2, from_list: "any_but_war" }
bonuses:
  combat: { attacks: 1, initiative: 2, parry: 1, dodge: 2, pull_punch: 3, roll: 2 }
  pools: { ppe: "2d4x10" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { name: "Literacy: Native Language", base: 98, per_level: 0 }
    - { name: "History", base: 98, per_level: 0, note: "Printed as History of their People at a flat 98%." }
    - { choose: 3, from: ["Language: Other"], bonus: 48, note: "Speak three Earth languages at 98%. The catalog holds Language: Other at 50%, so 98% is stated as +48." }
    - { choose: 3, from: ["Literacy: Other"], bonus: 20, note: "Literate in the same three Earth languages (+20%)." }
    - { name: "Lore: Magic", base: 45, per_level: 5, note: "+15%. Printed as Lore: Ley Lines & Magic." }
    - { choose: 2, from: ["Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 15, note: "Lore: two of choice (+15%). Lore: Magic is granted outright above and is not one of the two." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 50, per_level: 5, note: "+15%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%, professional quality. The book prints this as Write; the catalog''s nearest row is Calligraphy and no Writing row exists." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", bonus: 15 }
      - { name: "Physical", except: ["Boxing", "Wrestling"], note: "Any Physical skill except boxing and wrestling, and only Hand to Hand: Basic from the combat skills." }
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], note: "Printed as Read Sensory Equipment and Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Science", bonus: 20 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "Any W.P. ANCIENT only. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
      - { name: "Wilderness", bonus: 5 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES; the sheet has no field for either." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 1 }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits unless adventuring"
restrictions:
  - "Impervious to Horror Factor and to possession - not a bonus but an immunity, and there is no field for either, so it is recorded here."
  - "Cowboy, Espionage, Military, Pilot and Rogue are closed as related categories."
  - "Never uses a vehicle or a riding animal, and starts with no weapons."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "`copy_of` records that printed 135 defines this class as the Average Lyn-Srial for alignment, attributes and all basic stats, then replaces magic, skills, bonuses and equipment. The copied halves are repeated in full because nothing composes one class from another. THE MAGIC IS THE POINT: all seven Clouds of Defense, all seven Clouds of Travel and all eight Clouds of Creation outright - 22 spells - plus TWO more per level from any category EXCEPT Clouds of War, which is 45 of the 58 rows, declared once as `spell_lists.any_but_war`. That exclusion is only expressible because the spells carry their category in the name. The level-one pair is a starting group and levels 2-15 are `spells_schedule` entries of two, all drawing from that list; until BOOK-INGEST-AUDIT.md F59 the list was `spells_from` with no starting count, so it bounded nothing and every level-up could reach Clouds of War. IMPERVIOUS TO HORROR FACTOR AND POSSESSION is an immunity rather than a bonus; `bonuses.saves` holds numbers and there is no field for an immunity, so it is in `restrictions` where a reader will meet it. The +2D4x10 P.P.E. IS in `bonuses.pools`, which takes dice. The book prints a skill called Write at professional quality; there is no Writing row in this catalog and Calligraphy is the nearest, so that is what is stored, with the book''s own word in the note. Standard Equipment stores only the catalog rows that exist; the book also lists personal jewelry, a loin cloth, a pocket mirror and a purse, and states outright that the Cloudweaver starts with no weapons."
---

# Lyn-Srial Cloudweaver

**Alignments.** As the Average Lyn-Srial: four in five principled or scrupulous,
one in ten aberrant.

Cloudweavers are the Lyn-Srial - women in about eleven cases in twenty, and men
- who have become adept at casting and understanding Cloud Magic. They are
highly prized in the Golden Ones'' society and are treated as nobility or high
priests.

Most spend decades developing the skill and learning the theory and history of
magic and of Cloudweaving itself. The average Cloudweaver is not a warrior and
stays close to the city of Tryth-Sal, serving as historian, philosopher, healer,
diplomat and wise counsel - half the Council of Elders are Cloudweavers.
Occasionally one is sent into the wilderness to accompany a party of Sky-Knights
or to advise and help others in need.

## Lore

Also known as the Wise One and the Golden Creator. Fifty-five percent of all
Lyn-Srial women become Cloudweavers.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-cloudweaver'
   AND instr(markdown, 'name: "Dodge in flight"') = 0
   AND length(markdown) = 12353;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'all 10 classes cite D-Bees of North America' AS assertion, count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE (class_id = 'horune-pirate' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.100-103') > 0)
    OR (class_id = 'cactus-people' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.41-44') > 0)
    OR (class_id = 'fennodi' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.83-85') > 0)
    OR (class_id = 'lyn-srial' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.127-129') > 0)
    OR (class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.129-130') > 0)
    OR (class_id = 'pogtalian-dragon-slayer' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.156-159') > 0)
    OR (class_id = 'blind-warrior-women' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.15-18') > 0)
    OR (class_id = 'tokanii' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.203-206') > 0)
    OR (class_id = 'simvan-monster-rider' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.188-190') > 0)
    OR (class_id = 'psi-x-alien' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.166-168') > 0);

SELECT 'none still carries its old source line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'horune-pirate' AND instr(markdown, 'source_book: Rifts World Book 7: Underseas p.164-165') > 0)
    OR (class_id = 'cactus-people' AND instr(markdown, 'source_book: Rifts World Book 14: New West p.125-128') > 0)
    OR (class_id = 'fennodi' AND instr(markdown, 'source_book: Rifts World Book 14: New West p.128-130') > 0)
    OR (class_id = 'lyn-srial' AND instr(markdown, 'source_book: Rifts World Book 14: New West p.133-134') > 0)
    OR (class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'source_book: Rifts World Book 14: New West p.134-135') > 0)
    OR (class_id = 'pogtalian-dragon-slayer' AND instr(markdown, 'source_book: Rifts World Book 6: South America p.135-136') > 0)
    OR (class_id = 'blind-warrior-women' AND instr(markdown, 'source_book: Rifts World Book 2: Atlantis p.50-51') > 0)
    OR (class_id = 'tokanii' AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.154-156') > 0)
    OR (class_id = 'simvan-monster-rider' AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.162-163') > 0)
    OR (class_id = 'psi-x-alien' AND instr(markdown, 'source_book: Rifts World Book 13: Lone Star p.98-100') > 0);

SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('horune-pirate', 'cactus-people', 'fennodi', 'lyn-srial', 'lyn-srial-sky-knight', 'pogtalian-dragon-slayer', 'blind-warrior-women', 'tokanii', 'simvan-monster-rider', 'psi-x-alien') AND instr(markdown, char(13)) > 0;

SELECT 'all 10 are still live and published' AS assertion, count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id IN ('horune-pirate', 'cactus-people', 'fennodi', 'lyn-srial', 'lyn-srial-sky-knight', 'pogtalian-dragon-slayer', 'blind-warrior-women', 'tokanii', 'simvan-monster-rider', 'psi-x-alien') AND deleted_at IS NULL AND status = 'published';

SELECT 'the Cloudweaver carries its race''s two new blocks and still cites New West' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'lyn-srial-cloudweaver' AND instr(markdown, 'name: "Dodge in flight"') > 0 AND instr(markdown, 'side_effects: "Vulnerabilities:') > 0 AND instr(markdown, 'source_book: Rifts World Book 14: New West') > 0 AND deleted_at IS NULL;

INSERT INTO data_script_runs (filename) VALUES ('~098-d-bees-updates-ten-classes-five-books.sql');
