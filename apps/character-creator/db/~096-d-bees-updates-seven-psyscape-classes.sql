-- Seven Psyscape classes follow their D-Bees of North America printing.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~096-d-bees-updates-seven-psyscape-classes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~096-d-bees-updates-seven-psyscape-classes.sql
--
-- The second of four batches (see ~095 for the ruling and the rule applied
-- where D-Bees is silent): the seven classes held from Rifts World Book 12:
-- Psyscape (1997) that Rifts World Book 30: D-Bees of North America (2007)
-- reprints and updates.
--
--   darkhound           D-Bees printed 54-58   (Psyscape 94-98)
--   amorph              D-Bees printed 21-25   (Psyscape 117-120)
--   demon-dragonmage    D-Bees printed 58-61   (Psyscape 120-123)
--   lanotaur-hunter     D-Bees printed 115-117 (Psyscape 123-126)
--   psi-goblin          D-Bees printed 164-166 (Psyscape 128-130)
--   yhabbayar           D-Bees printed 217-220 (Psyscape 130-135)
--   zenith-moon-warper  D-Bees printed 221-223 (Psyscape 138-140)
--
-- Each was read against BOTH books off page renders by one reader and
-- checked against renders again by another that did not write it: no wrong
-- figure in seven classes. None changes shape: all seven are stand-alone
-- R.C.C.s in both books. The experience ladders do not move (D-Bees prints
-- the same ladder, or points to a table that is figure for figure the
-- Psyscape column).
--
-- Readings a page does not settle, each stated in its class's notes:
--   amorph      D-Bees prints the save vs Horror Factor as "+1 to +6", a
--               range, where Psyscape printed a flat +6. Stored as prose.
--   psi-goblin  D-Bees prints the P.P.E. two ways on one page; the stat
--               block's is stored. It prints no P.B. die; Psyscape's 2D6 is
--               kept so the attribute does not fall back to a default.
--   yhabbayar   three secondary skills at each of levels 1, 3, 6, 10 and 14,
--               and one Physical and one Super power at every level, as the
--               sentences read.
--   darkhound   a Vibro-Knife and a Vibro-Sword, both.
--   zenith      M.A. 1D6+20 (Psyscape 1D6+2), read at 300 dpi in both books.
--
-- Each draft reads `ready` in class-check --remote. Two display-only ability
-- names change because D-Bees renames them (lanotaur-hunter); no pick-one
-- option or variant is renamed. Production held no saved character on any
-- of the seven when this was written.
--
-- Each UPDATE is guarded on the class's old source_book line and on the
-- exact stored length (trailing newline counted). THIS SCRIPT CHANGES
-- PRODUCTION: seven class rows. The tilde number is claimed at merge.

-- == darkhound ==
UPDATE imported_classes
   SET markdown = '---
id: darkhound
name: Darkhound
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.54-58
category: rcc
tags: [supernatural, hunter]
attribute_dice:
  IQ: "2d4+2"
  ME: "2d6+8"
  MA: "2d4+1"
  PS: "3d6+10"
  PP: "3d6+6"
  PE: "2d6+10"
  PB: "2d4"
  Spd: "6d6+10"
mdc_base: "3D6x10, plus 2D6 per level of experience"
ppe_base: "2d6"
starting_money: "4d6x10"
horror_factor: 11
xp_table: [0, 2061, 4161, 8521, 16901, 25601, 35901, 50501, 70901, 95501, 130901, 190501, 240901, 290501, 350901]
psionics:
  type: "master"
  isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience"
  powers: ["Sense Evil", "Sense Magic", "Deaden Senses", "Nightvision", "Resist Fatigue", "Empathy", "Meditation"]
  powers_starting: 1
  categories_allowed: ["Sensitive"]
ignores_style_attacks: true
bonuses:
  combat: { attacks_base: 4, initiative: 2, perception: 3, strike: 1, dodge: 1, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 4, disease: 3, toxins_poisons: 3, possession: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { initiative: 2 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { initiative: 2, attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
    - { level: 14, combat: { initiative: 2 } }
    - { level: 15, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "Climb (+15%)" }
    - { name: "Detect Ambush", base: 45, per_level: 5, note: "+15%" }
    - { name: "Tailing", base: 50, per_level: 5, note: "+20%" }
    - { name: "Swimming", base: 70, per_level: 5, note: "Swim (+20%)" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Intelligence", base: 37, per_level: 4, note: "+5%" }
    - { choose: 1, from: ["W.P. Sword", "W.P. Knife"], note: "W.P. Sword or Knife." }
    - { name: "Language: Native Tongue", base: 45, per_level: 3, note: "Speaks American at 45% +3% per level. Cannot read or write." }
    - { choose: 1, from: ["Language: Other"], base: 35, per_level: 3, note: "May pick up one additional spoken language at 35% +3% per level." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Psyscape gives the equivalent of Hand to Hand: Expert and prints no upgrade. It adds no attacks: four per melee to start, +1 at levels 2, 5, 8, 10, 13 and 15." }
  occ_related_skills:
    count: 0
    categories:
      - { name: "Communications", only: ["Barter", "Radio: Basic", "Sign Language"] }
      - "Domestic"
      - { name: "Physical", except: ["Acrobatics", "Kick Boxing", "SCUBA"] }
      - "Rogue"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "None at level one. Select one at levels 2, 4, 8, 12 and 15. All new skills start at first level experience."
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    note: "Two secondary skills from the Secondary Skill List at each of levels 1, 3, 6, 9 and 12. No bonuses other than a possible high I.Q. bonus; all start at the base skill level."
equipment_starting:
  - { choose: 1, label: "hooded cloak or poncho", qty: 1, from: ["hooded-cloak", "poncho"] }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "vibro-sword", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6+10" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
  - { name: "Supernatural P.S. and P.E.", description: "All physical attributes are supernatural. Its endurance takes roughly ten times the exertion that would tire a Dog Boy." }
  - { name: "Claws and bite", description: "Claws inflict 2D6 M.D. plus supernatural strength damage; the bite inflicts 4D6 M.D. regardless of P.S. Likes to leap on a foe and overwhelm it with sheer ferocity." }
  - name: "Sense Psychic and Magic Energy"
    description: "Constant and automatic, like sight and smell; a keener version of the Psi-Hound''s. Detects psychics (I.S.P.) and magic energy (P.P.E. in spell casting, magic devices, and people with 80 or more points), and senses any psionic power or spell used within range. Energy expended repeatedly, or lasting longer than one melee round, can be traced to its source; several users in one area lead it to that spot but cannot be told apart or remembered later, and users scattered over a wide area draw it to the most powerful. Base Skill: 70% +2% per level (roll once every melee round), -10% when multiple sources are scattered through the range. Range: 50 feet (15.2 m) +5 feet (1.5 m) per additional level to a psychic or mage NOT using powers; 1000 feet (305 m) +50 feet (15 m) per level to powers IN USE. Roll every 1000 feet (305 m) to stay on the trail; a failed roll loses the psychic scent. I.S.P.: none."
  - name: "Recognize Psychic Scent"
    description: "Recognizes the psychic signature - a unique psychic fingerprint given off whenever a being uses psionics or magic - of races, monsters and individuals it knows well; less developed than the Psi-Stalker''s. Base Skill: 20% +4% per additional level to recognize the general race or type; 14% +2% per additional level to recognize a specific individual, +10% with hair, skin, blood or clothing worn within the last 4 hours, and +10% if it knows the prey well. Range: 60 feet (18.3 m) +10 feet (3 m) per level. Duration: automatic and constant. I.S.P.: none."
  - name: "Sense Supernatural Beings"
    description: "As Sense Psychic and Magic Energy, but far more sensitive to the scent of the supernatural. Base Skill: 72% +2% per level to identify the specific type/race of paranormal creature, including alien intelligences, gods, demigods, demons, vampires and dragons, and can tell whether a person is possessed. Tracking by this scent: 50% +5% per level, or 70% +3% per level if the being is also using psionics or magic. Range: 100 feet (30.5 m) per level when the being is using no powers; 1000 feet (305 m) +100 feet (30.5 m) per additional level when it is actively using supernatural powers, magic or psionics. Duration: automatic and constant. I.S.P.: none."
  - name: "Superior Sense of Smell"
    description: "Same as the Dog Boy. Common and strong scents: 70% +3% per level, range 100 feet (30.5 m) per level. Identify specific odors (specific individuals, poisons or drugs in food or drink, unusual scents; needs familiarity or a reference item): 54% +2% per level, range 25 feet (7.6 m) per level. Track by smell alone: 40% +4% per level; can follow a scent through total darkness and suffers only half the normal penalties to strike, parry and dodge when blinded or in darkness. Roll every 1000 feet (305 m), half that for a light scent or a trail under light rain or snow; a failed roll loses the trail temporarily, two successes in three tries recover it, two failures lose it. Smells a trail up to four days (96 hours) old unless washed away. Cannot track through water, nor smell Astral Beings, ghosts or energy beings."
  - { name: "Keen Sense of Hearing", description: "Hears up to 35,000 vibrations per second (humans 20,000, cats 25,000). The large ears swivel to focus on a sound, and the inner ear can shut out the general din to concentrate on one noise." }
  - { name: "Good Sight", description: "20/20 vision with a 270 degree field of view (a human''s is 100). Sees color in about the human range, a bit dulled. Sees no better in the dark than a human." }
  - { name: "Sense of Taste", description: "Fair." }
  - { name: "Impervious to animal control", description: "Unaffected by the animal affinity and control powers of Simvan, Psi-Stalkers and Psi-Druids, and by similar psionic and magic powers, including Repel Animals and Summon Animals." }
special_abilities:
  - name: "Magic Resistance"
    description: "An invisible field of energy dulls magic around the Darkhound. Even when it fails a saving throw against magic, the effects - damage, duration, penalties and the like - are reduced by half."
  - name: "Sensitivity to Ley Line Energy"
    description: "On a ley line or near a nexus the psychic and supernatural sensing abilities (Sense Psychic and Magic Energy, Recognize Psychic Scent, Sense Supernatural Beings) are impaired or wiped out and cannot locate magic or supernatural prey. Physical senses, especially smell, are unaffected, and its other psychic sensitive abilities are enhanced as usual. It is nervous around places of magic, fears Ley Line Storms (headaches, crackling ears, static shocks), and is twice as likely to be struck by ley line energy and lightning."
restrictions:
  - "Alignment: any, but typically anarchist (33%), unprincipled (23%) or aberrant evil (24%). Whatever the alignment, most are bloodthirsty predators toward psychics, practitioners of magic and evil supernatural beings."
  - "Available O.C.C.s: none. The Darkhound has its own R.C.C. skills, R.C.C. related skills and secondary skills and nothing else."
  - "Cannot pilot a vehicle, operate a radio or computer, or understand the written word; it struggles even with spoken human language. Can use guns and simple weapons and tools; swords and Vibro-Blades are its favorites."
  - "Can use guns but seldom does so, and starts with no guns and no magic items. Loves magic weapons of all kinds, especially melee weapons (swords, axes, spears)."
  - "Takes an instant, lasting dislike and distrust of all magic characters and creatures of magic, even good and kind ones: it growls at them and avoids them, and answers any apparent threat to itself or a friend with immediate, deadly force. It will not negotiate with evil mages, evil psychics or supernatural beings, and attacks them without hesitation or mercy."
  - "Magic: none. Cybernetics and bionics: not possible."
  - "Size 8 or 9 feet tall, 400 to 500 pounds. Average life span 3D6+22 years; physical maturity is reached by age six."
side_effects: "Horror Factor is 11 for most humanoids and rises to 14 for supernatural creatures, psychics and practitioners of magic. Hates Mystic Knights, Bio-Wizards, Minions of Splugorth, Witch Wolves, Brodkil, Black Faeries, Witchlings and demons with a passion - an almost obsessive hatred; also hunts all Psi-Stalkers, psychics, practitioners of magic, evil creatures of magic and evil supernatural beings in general, magic practitioners and the supernatural being its favorite prey. Instinctively considers humans and Psi-Hounds friends and potential allies and likes Coalition soldiers, seldom attacking them unless attacked first. Its low intelligence, powerful instincts and drive to hunt may also work against it."
extraction_notes: |
  - This class followed Rifts World Book 12: Psyscape printed 94-98 until this update; it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 54-58, whose closing note says the Darkhound originally appeared in Psyscape (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here). Both entries were read off page renders (D-Bees cache p055-p059, Psyscape cache p096-p099).
  - Unchanged between the two printings: the eight attribute dice, M.D.C. 3D6x10 plus 2D6 per level, P.P.E. 2D6, I.S.P. 1D6x10 + M.E. +10 per additional level (regained 2 per hour of activity or 12 per hour of meditation or sleep), Master Psychic saving at 10 or higher, size 8-9 feet, weight 400-500 pounds, the alignment percentages, claws 2D6 M.D. plus Supernatural P.S. damage and bite 4D6 M.D., every base skill, range and per-level figure of the sensing abilities and the senses of smell, hearing and sight, the magic resistance, the immunity to animal control, the ley line sensitivity, no magic, no cybernetics.
  - Heading: D-Bees heads the stat block "Darkhound - Optional Player Character or NPC" (printed 55); Psyscape printed 97 headed it "Darkhound - NPC Villain & Optional Player R.C.C.". Both carry a Player Character Note; imported as a playable race on that basis. D-Bees gives the I.Q. of a six year old child and the instincts of a wolf where Psyscape gave a five year old and a crazed hunter, and an NPC experience level of 1D6 or as set by the G.M. where Psyscape gave 1D4.
  - Attacks per melee: D-Bees printed 57 prints "Starts with four, +1 attack per melee round at levels 2, 5, 8, 10, 13 and 15", a whole attack schedule of its own, stored as attacks_base 4 plus at_level with ignores_style_attacks. Psyscape printed 96-97 gave +1 attack per melee round at levels 1, 5 and 10 on top of "the equivalent of Hand to Hand: Expert". D-Bees prints no Combat line and does not restate the Hand to Hand: Expert equivalent; the skill is kept from Psyscape for its fighting techniques and bonuses.
  - Bonuses: D-Bees printed 57 prints, in addition to those acquired from attributes and skills, +2 initiative at levels 1, 4, 8 and 14, +3 on Perception Rolls, +1 strike, +1 dodge, +3 pull punch, +1 roll with impact, +4 save vs Horror Factor, +3 save vs disease and poison (stored as disease and toxins_poisons), +2 save vs possession. Psyscape printed 96 (#8) gave the same line without the Perception and dodge bonuses and with the attacks at levels 1, 5 and 10.
  - R.C.C. skills: D-Bees printed 57 adds Detect Ambush (+15%) and Tailing (+20%) to the list; Psyscape printed 97 gave Land Navigation, Wilderness Survival, Climb, Swim, Prowl, Intelligence, W.P. Sword or Knife and the two languages only. The other bonuses are the same in both.
  - R.C.C. related skills: D-Bees printed 57 prints one at levels 2, 4, 8, 12 and 15 from Communications (Barter, Radio Basic and Sign Language only), Domestic (any), Physical (any, except Acrobatics, Kick Boxing and SCUBA), Rogue (any), Weapon Proficiencies (any) and Wilderness (any, +10%), stored as a schedule over a count of 0. Psyscape printed none.
  - Secondary skills: D-Bees printed 57 prints two from the Secondary Skill List on page 300 of Rifts Ultimate Edition at levels 1, 3, 6, 9 and 12, without bonuses other than a high I.Q. bonus. Psyscape printed 97 gave four secondary skills, once, limited to Physical (any), Technical (spoken language and lore skills only) and Wilderness (any); D-Bees restates the line without that limit, so it is not stored.
  - Psionics (D-Bees #4, printed 56): Deaden Senses, Empathy (receive only, not transmission), Meditation, Nightvision, Resist Fatigue, Sense Evil, Sense Magic, plus one additional Sensitive power. Psyscape printed 96 gave the same list without Meditation. Neither printing lists Sixth Sense, unlike the Dog Boy; transcribed as printed.
  - Horror Factor: D-Bees printed 56 prints 11 for most humanoids and 14 for supernatural creatures, psychics and practitioners of magic. Psyscape printed 97 gave 11, 14 to supernatural creatures and magic practitioners, especially members of the True Federation (no psychics). 11 is stored; the 14 is conditional and stays in side_effects.
  - Guns: D-Bees prints that the character can use guns and simple weapons and tools (printed 55), can use guns but seldom does, and does not start with any guns nor magic items (printed 57). Psyscape printed 98 gave "They do not use guns of any kind" and "May also use blunt weapons (clubs, etc.), staves, and magic blade or blunt weapons".
  - Equipment: D-Bees printed 57 prints homemade, piecemeal body armor (1D4x10+15 M.D.C.), a hooded cloak or poncho, Vibro-Knife, Vibro-Sword or a magical equivalent, a backpack or satchel to carry 1D6+10 wooden stakes, a wooden mallet, a wooden cross, a mirror, a comb and some personal items, possibly a gun, and then says they start with no guns and no magic items. Stored: the cloak-or-poncho choice, the Vibro-Knife and the Vibro-Sword (read as both, the magical equivalent being ruled out by the closing sentence), the backpack, 1D6+10 wooden stakes, the mallet, the cross and the mirror. The armor (its M.D.C. is a roll no catalog row carries), the satchel alternative, the comb and the personal items are not stored and are named in GM Notes. Psyscape printed 98 gave the ragged remains of clothing, possibly some homemade piecemeal body armor, one Vibro-Blade and a knife; printed 95 said about half fashion partial armor from scraps, two thirds of those preferring Coalition armor, typical suit 1D4x10+15 M.D.C. D-Bees restates the equipment line without the plain knife, so it is removed.
  - Money: D-Bees printed 57 prints "Starts only with 4D6x10 in tradeable goods", stored as starting_money 4D6x10. Psyscape printed 98 gave "None; don''t need any".
  - Life span: D-Bees printed 56 prints 3D6+22 years, physical maturity by age six. Psyscape printed 98 gave unknown, perhaps 30-40 years.
  - xp_table: D-Bees printed 58 prints a Darkhound Experience Table at the end of the entry, and it is the same ladder as the Psi-Druid / Psi-Ghost / Darkhound column of Psyscape''s Experience Tables page (printed 157), which was already stored. Level 1 is 0-2,060 and level 15 starts at 350,901. Psyscape''s class page (printed 97) said to use the Juicer''s table, which lost to its own printed-157 table then and is not restated by D-Bees.
  - Available O.C.C.s: D-Bees prints "None, see R.C.C. above", so no occ_restrictions is written and the R.C.C. skills, related skills and secondary skills are the whole skill grant. Psyscape stated no O.C.C. pairing either way.
  - Scent tracking: D-Bees does not restate Psyscape''s notes about tracking by scent (roll every 1000 feet, half that for a light scent or under light rain or snow, two of three to recover a lost trail, a trail up to four days old, not through water, no Astral Beings, ghosts or energy beings, a dog sees no better in the dark than a human) and refers to the Dog Boy R.C.C. in Rifts Ultimate Edition instead; they are kept from Psyscape printed 97 in Superior Sense of Smell and Good Sight. D-Bees does not restate that the Darkhound''s psychic scent recognition is less developed than the Psi-Stalker''s; kept.
  - Enemies and affinities: D-Bees printed 58 names Mystic Knights, Bio-Wizards, Minions of Splugorth, Witch Wolves, Brodkil, Black Faeries, Witchlings and demons, then Psi-Stalkers, psychics, practitioners of magic, evil creatures of magic and evil supernatural beings; stored in side_effects. Psyscape printed 97 (#14) gave practitioners of magic above all, evil supernatural beings a close second, powerful Major and Master Psychics, creatures of magic including Faerie Folk and dragons, and monsters of all kinds, with an affinity for Dog Boys, CS soldiers and innocent, normal humans.
  - A Dog Boy that was transformed "begins life anew" as a Darkhound (Psyscape printed 97); D-Bees says they have no recollection of their origin. Nothing to store.
  - Not stored as mechanics, D-Bees only: slave market value 2D6x10,000; habitat now reaches Ohio, Indiana, Michigan, Kentucky, Tennessee, Arkansas and Texas; 15% of the Dog Boys experimented on survived as Darkhounds; females bear a litter of 2D4 after a five month pregnancy.
---

# Darkhound

## Lore

Darkhounds are hulking, grey-furred canine predators of the Magic Zone, eight or
nine feet tall with long gorilla-like arms, clawed hands and glowing red eyes.
Rumor holds that they are Dog Boys warped by Lord Dunscon''s supernatural allies,
and that about half of them still are, the rest being bred true; Dunscon denies
it. Whatever their origin, they hunt mages, psychics and the supernatural with
an obsessive hatred, yet they leave Dog Boys alone, trail Coalition patrols, and
have been seen defending soldiers and human children from monsters. They are
psychic hunters with the Psi-Hound''s senses sharpened, but only the intellect of
a small child.

## GM Notes

The book heads this entry as an optional player character or NPC; it is
playable at the G.M.''s discretion. Its Player Character Note warns that the
player must portray a creature with the I.Q. of a six year old and the
instincts of a wolf, more animal than human, direct in everything and
seldom bluffing, though capable of stealth and patience on the hunt.

NPC level is 1D6 or as the G.M. sets it; a player character starts at first
level. Darkhounds roam the wilderness of the Magic Zone, Ohio
and the lower Great Lakes, usually hunting at night in packs of 4D4, and
occasionally travel with mixed groups (Dog Boys, humans, animal-like D-bees).
One in an adventuring group is an extreme rarity.

About half wear partial body armor patched together from scraps, two thirds of
those preferring Coalition armor; a typical suit has 1D4x10+15 M.D.C. Their
favorite weapons are Vibro-Blades and magic blades. Officially the Coalition
lists them for extermination on sight, but most patrols (90%) leave them alone
and count being followed by one as good luck.

Standard equipment the class does not carry as items: homemade, piecemeal body
armor (1D4x10+15 M.D.C.), a satchel in place of the backpack, a comb and some
personal items. It starts with no guns and no magic items, and its 4D6x10 of
money is in tradeable goods.
',
       updated_at = datetime('now')
 WHERE class_id = 'darkhound'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.94-98') > 0
   AND length(markdown) = 13992;

-- == amorph ==
UPDATE imported_classes
   SET markdown = '---
id: amorph
name: Amorph
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.21-25
category: rcc
tags: [shapeshifter, flyer]
attribute_dice:
  IQ: "2d4+4"
  ME: "2d6+6"
  MA: "2d6+12"
  PS: "1d6+4"
  PP: "1d6+6"
  PE: "2d6+6"
  PB: "1d4"
  Spd: "2d4+4"
hit_points_base: "P.E. + 2d6x10, +1d6 per level"
sdc_base: "1d6x10+8"
ppe_base: "2d6+6"
starting_money: "1d6x100"
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
psionics:
  type: "major"
  isp_base: "M.E. attribute plus 1d4x10, +10 per level of experience"
  powers: ["Telepathy", "Empathy", "Presence Sense", "Sense Evil", "Sense Magic", "Commune with Spirit", "Alter Aura", "Ectoplasm", "Psychic Body Field", "Telekinetic Force Field", "Psychic Omni-Sight"]
  powers_starting: 0
  categories_allowed: ["Sensitive", "Physical"]
  powers_schedule:
    - { level: 2, count: 2, note: "Two powers from the Sensitive or Physical categories." }
    - { level: 4, count: 2, note: "Two powers from the Sensitive or Physical categories." }
    - { level: 8, count: 2, note: "Two powers from the Sensitive or Physical categories." }
    - { level: 12, count: 2, note: "Two powers from the Sensitive or Physical categories." }
    - { level: 15, count: 2, note: "Two powers from the Sensitive or Physical categories." }
bonuses:
  combat: { attacks_base: 4, automatic_dodge: 2 }
  saves: { possession: 6 }
  at_level:
    - { level: 3, combat: { automatic_dodge: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 6, combat: { automatic_dodge: 1 } }
    - { level: 9, combat: { automatic_dodge: 1, attacks: 1 } }
    - { level: 12, combat: { automatic_dodge: 1 } }
    - { level: 13, combat: { attacks: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Dance", base: 50, per_level: 5, note: "+20%." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Printed as Climb (+10%)." }
    - { name: "Impersonation", base: 30, per_level: 4, note: "+20% to look like another person only; no bonus to act like that person, because an Amorph cannot speak or imitate the voice and is poor at copying mannerisms. Most effective from a distance and when no words are necessary." }
    - { name: "Land Navigation", base: 61, per_level: 4, note: "+25%." }
    - { name: "Lore: Astral", base: 41, per_level: 4, note: "Printed as Lore: Astral Plane (+15%)." }
    - { name: "Lore: Psychics & Psionics", base: 40, per_level: 5, note: "+15%." }
    - { choose: 1, from: ["Lore: American Indians", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { name: "Prowl", base: 40, per_level: 5, note: "+15% in any form (stored); +25% in its natural form. 80% when hovering as an ectoplasmic blob." }
    - { name: "Tailing", base: 30, per_level: 5, note: "No bonus printed." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", except: ["Sing"] }
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Pilot", bonus: 5 }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 10 }
      - "Science"
      - { name: "Technical", except: ["Computer Programming"], bonus: 5 }
      - { name: "Weapon Proficiencies", only: ["W.P. Blunt", "W.P. Knife", "W.P. Energy Pistol"] }
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "R.C.C. Related Skills: four, plus one more at levels 4, 8 and 12. Domestic: any except Singing. Electrical, Mechanical, Military, Physical, Pilot Related and Wilderness: none."
  secondary_skills:
    count: 1
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "One skill from the Secondary Skills List on page 300 of Rifts Ultimate Edition at each of levels 1, 3, 6, 9, 12 and 15, at the base skill level; no bonuses other than a high I.Q."
equipment_starting:
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "swiss-army-knife", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "lightweight-rope", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1 }
  - { item_id: "digital-camera", qty: 1 }
natural_abilities:
  - { name: "Natural form", description: "A big glob of featureless ectoplasm: a grey ball or undulating glob (the opening text calls it a shimmering whitish blob). To humans the natural form is P.B. 1D4. Weighs 45 to 60 lbs (20.2 to 27 kg) whatever its size or shape; the average is 50 lbs (22.5 kg)." }
  - { name: "Float and fly", description: "Floats and moves through the air at slow speed, never higher than 50 feet (15.2 m) above the ground; hovering and slow flying are natural and cost no I.S.P. Spd applies walking and flying. It flies only in its natural blob form: it cannot fly in a copied form. Has the Prowl skill at 80% when hovering as an ectoplasmic blob." }
  - { name: "Body shaping", description: "Can flatten to the thickness of a sheet of paper or narrow to the thickness of a pencil, to slip under doors, through cracks and small holes, or to hide. Only in its natural form, not in a copied one. Even so it easily slips handcuffs and rope, squeezes through jail bars and narrow openings and fits inside a small trunk or suitcase without changing shape: ectoplasm squishes and balls up to one quarter of its overall apparent size." }
  - { name: "Psychic senses and telepathy", description: "Senses much of the world through psionics and sees by a sort of psychic vision rather than eyes. Understands all languages via Telepathy and communicates telepathically at no I.S.P. cost. It cannot make any vocalization: it cannot speak aloud, only via Telepathy." }
  - { name: "See the invisible", description: "Normal and automatic, at no I.S.P. cost; includes Astral beings, spirits, entities and those made magically or technologically invisible." }
  - { name: "Perfect vision and hearing", description: "The equivalent of perfect human vision and hearing." }
  - { name: "Sense Dragon Roads and ley lines", description: "Senses their presence up to one mile (1.6 km) away in the physical realm." }
  - { name: "Bio-regeneration", description: "Regenerates 2D6 Hit Points or S.D.C. per melee round." }
  - { name: "Impervious", description: "Impervious to disease, poison, drugs, gases, pollution and radiation. Resistant to heat and cold: only extreme temperatures (below zero and more than 110 degrees Fahrenheit) affect it." }
  - { name: "Needs no food, water or air", description: "Does not breathe, eat or drink. Feeds on P.P.E., roughly 1D6+20 points a week (ideally three a day), absorbed from ley lines, from living creatures at the moment of death, or from the living who willingly offer it and decide how much to share." }
  - { name: "On the Astral Plane", description: "Keeps its shape changing and telepathy; flying speed is tripled; Astral Navigation 80% +1% per level of experience; senses Dragon Roads and ley lines up to 10 miles (16 km) away; bio-regenerates 2D6 Hit Points/S.D.C. per melee round and is vulnerable only to psionics and magic." }
  - { name: "Reaching Earth", description: "Can reach Earth only through dimensional portals, never by Astral Projection. It can stay indefinitely but cannot go home until it finds another opening back to the Astral Plane; Psyscape is one place with portals to and from it. If slain in the physical world it is dead and does not reappear in the Astral Plane." }
special_abilities:
  - name: "Ectoplasmic Metamorphosis"
    description: "Can take almost any form - any living creature, humanoid, animal or plant, inanimate objects, even vehicles - from cat-sized to the size of an adult dragon, copying appearance and texture exactly (scales, fur, slime, metal, clothing, armor, gear). It copies looks only: never M.D.C., damage capacity, voice, abilities or powers, so copied armor and weapons are powerless props. Weight and attributes never change. It must have visual, three-dimensional contact with what it copies (the real thing or a 3-D image) and cannot work from memory. Asexual, so it can take either gender. Horror Factor in a copied form equals that of the creature mimicked; none in its natural form. P.B. can be anywhere from 2 to 24 by shape. It cannot fly or flatten while in a copied form, and must take an appropriate body form to use weapons made for humanoids. Given away by weight, heat signature, missing sounds, speed and capabilities, interiors of ectoplasmic fuzz, and by psionic sensing (See Aura, Presence Sense, Detect Psionics, Telepathy, Empathy and Object Read). Inanimate shapes bore it within a few minutes; animals and humanoids are preferred and the easiest to maintain."
  - name: "Automatic Dodge"
    description: "Globs the threatened part of its body out of the way of an attack as an instinctive reflex: an automatic dodge that costs no melee action or attack. +2 to automatic dodge at level one and +1 more at levels 3, 6, 9 and 12 (applied in the bonuses). To keep a disguise intact it can choose not to use it, which costs one melee attack/action and gives -1 on all combat rolls for the rest of that melee round."
  - name: "Limited Invulnerability"
    description: "Physical attacks, from punches to swords, bullets and rail gun rounds, pass harmlessly through it. A powerful explosion (80 M.D. or greater) knocks it into 1D4x100 tiny ectoplasmic globules that need 3D6 minutes to gather and reform. Energy weapons, magic weapons, psionics and M.D. fire or plasma all inflict full damage; normal fire does half damage. It never wears body armor; its M.D.C. defenses are the psionic powers Psychic Body Field and Telekinetic Force Field."
  - name: "Languages via Telepathy"
    description: "Printed as the R.C.C. skill line Languages: all, via Telepathy, at 85% proficiency."
  - name: "Save vs Horror Factor"
    description: "+1 to +6 to save vs Horror Factor, printed as a range (mainly because they are too naive to recognize trouble and danger). Needs a 12 or higher to save vs psionic attacks."
  - name: "Charm/Impress"
    description: "+10% to charm/impress, on top of any attribute bonuses."
restrictions:
  - "Takes no O.C.C. The book gives the Amorph its own R.C.C. skills, related and secondary skills, equipment and money."
  - "No magic."
  - "Cybernetics and bionics are not applicable to a being of ectoplasm."
  - "Hand to Hand: None. The Amorph has no hand to hand combat skill and can take none."
  - "Never wears body armor."
side_effects: "Needs constant stimulation: boredom is torture to an Amorph and can kill it. Not a fighter: it engages in combat only long enough to escape or help a friend escape. Most are squeamish, naive about danger, and likely to scream, flee and change shape when threatened or hurt; wearing no armor, they can be hurt by energy blasts, fire, extreme cold, psionic and magical attacks. Wealth is a low priority: it has no need for credits on the Astral Plane, though it can learn their value in the physical world."
extraction_notes: |
  - This class followed Rifts World Book 12: Psyscape printed 117-120 until
    it was brought up to Rifts World Book 30: D-Bees of North America printed
    21-25 (ruling of 2026-10-04: the newest printing that states a figure
    wins and the older figure is kept in a note). Both entries were read off
    page renders: D-Bees cache p022-p026 (folios 21-25) and Psyscape cache
    p118-p121 (folios 117-120). D-Bees printed 25 says "Originally appeared
    in Rifts World Book 12: Psyscape".
  - NPC-HEADED, G.M. DISCRETION: D-Bees heads the stat block "Amorph Optional
    Player Character or NPC" (Psyscape: "Amorph NPC and Optional Player
    Character"); both Player Notes say it is a difficult character to play,
    not advised, G.M. discretion. Said again in GM Notes.
  - TAKES NO O.C.C.: both books print a full R.C.C. package (R.C.C. skills,
    four related plus schedule, secondary skills, equipment, money) and name
    no occupation. Stored as a restriction line.
  - HIT POINTS: D-Bees prints "2D6x10 + P.E. attribute number, +1D6 Hit
    Points per level of experience". Psyscape printed 119 gave one combined
    S.D.C./Hit Points pool, "P.E. attribute plus 3D6x10", +2D6 per level.
  - S.D.C.: D-Bees prints "1D6x10+8" as its own line; stored as sdc_base.
    Psyscape printed 119 gave no separate S.D.C. (the combined pool above;
    the row held sdc_base 0). No men_of_arms line: the class states
    sdc_base. Not M.D.C.
  - P.P.E.: D-Bees 2D6+6. Psyscape printed 119 gave 2D6.
  - P.B.: both print "shape changing range of 2 to 24 (to humans, their
    natural form is P.B. 1D4)". Stored as 1d4 (the natural form); the 2-24
    range is in the Ectoplasmic Metamorphosis ability. Spd 2D4+4 is walking
    and flying in both.
  - Weight: D-Bees 45-60 pounds (20.2 to 27 kg); Psyscape printed 119 gave
    45 to 60 lbs (20.4 to 27.2 kg).
  - ATTACKS: D-Bees prints "Four melee actions/attacks +1 at levels 5, 9 and
    13". Stored as combat.attacks_base 4 with at_level attacks +1 at 5, 9
    and 13. Psyscape printed 119 gave "Combat: As per skill and training"
    with Hand to Hand: Basic.
  - HAND TO HAND: D-Bees prints "Hand to Hand: None", so the Hand to Hand:
    Basic grant is removed and hand_to_hand costs stays {} (none offered;
    Physical is also "None" among the related skills). Psyscape printed 120
    gave Hand to Hand: Basic, "can not be upgraded".
  - AUTOMATIC DODGE: D-Bees prints "+2 to automatic dodge at level one plus
    an additional bonus of +1 to auto-dodge at levels 3, 6, 9, and 12".
    Stored as combat.automatic_dodge 2 plus the four at_level entries.
    Psyscape printed 119 gave no level-one bonus, only the +1 at 3, 6, 9 and
    12, and added that all normal dodge bonuses from hand to hand training
    apply; D-Bees does not restate that sentence and gives no hand to hand.
  - BONUSES LINE: D-Bees prints "+1 to +6 to save vs Horror Factor ..., +6
    to save vs possession, and +10% to charm/impress on top of any attribute
    bonuses. Needs a 12 or higher to save vs psionic attacks." The Horror
    Factor bonus is printed as a RANGE, not a figure, so it is no longer in
    bonuses.saves; it is the special_abilities entry Save vs Horror Factor.
    Psyscape printed 119 gave a flat +6 to save vs horror factor. Possession
    +6 and charm/impress +10% are the same in both. Save vs psionics 12 is
    the major-psionic threshold, not a bonus.
  - REGENERATION AND INVULNERABILITY: D-Bees natural ability 4, Limited
    Invulnerability, is new: impervious to disease, poison, drugs, gases,
    pollution and radiation; resistant to heat and cold; physical attacks
    pass through; an 80 M.D. explosion scatters it for 3D6 minutes;
    bio-regenerates 2D6 Hit Points or S.D.C. per melee round; energy
    weapons, magic weapons, psionics and M.D. fire/plasma do full damage,
    normal fire half. Psyscape printed 119 gave bio-regeneration 1D6 S.D.C.
    per melee round in the physical realm (2D6 on the Astral Plane only),
    imperviousness to disease, poison and pollution only, "extreme cold,
    heat and fire have full effect and damage", and printed 118 said it can
    be hurt by physical, psionic and magical attacks.
  - P.P.E. FEEDING: D-Bees "roughly 1D6+20 points a week; ideally, three
    points a day", and adds absorbing it from living creatures at the moment
    of death. Psyscape printed 119 gave roughly 21 points a week.
  - New in D-Bees and stored as prose: cannot vocalize; Prowl 80% when
    hovering as a blob; sees the magically or technologically invisible;
    cannot fly or flatten in a copied form; squishes to one quarter size;
    on the Astral Plane vulnerable only to psionics and magic; if slain in
    the physical world it is dead. "Can float and fly above water" is
    Psyscape printed 119 only and is no longer in the row.
  - PSIONICS: unchanged between the books. M.E. plus 1D4x10 I.S.P., +10 per
    level; the same eleven starting powers; two from Sensitive or Physical
    at levels 2, 4, 8, 12 and 15. Tier stored as major because both books
    set save vs psionics at 12, although three of the eleven granted powers
    (Psychic Body Field, Telekinetic Force Field, Psychic Omni-Sight) are
    Super powers; they are granted by name. "Commune with Spirits" is the
    catalog row "Commune with Spirit".
  - R.C.C. SKILLS (D-Bees printed 24): Languages "All via Telepathy at 85%
    proficiency" -> the special_abilities entry Languages via Telepathy;
    Psyscape printed 120 gave "Languages: Two of choice (+15%)", and that
    choice group is removed. Dance 30+20 = 50. Climb (+10%) -> Climbing
    40+10 = 50. Impersonation is new: "+20% to look like another person, but
    no bonus to act like that person"; the bonus is conditional, so the
    skill is stored at the catalog base 30 with the condition in its note.
    Land Navigation 36+25 = 61. Lore: Astral Plane (+15%) -> Lore: Astral
    26+15 = 41. Lore: Psychics & Psionics (+15%) is new: 25+15 = 40. Lore:
    one of choice (+10%) is in both books; the option list is left as it
    was. Prowl is new: "+15% in any form, +25% in natural form" -> 25+15 =
    40, the natural-form figure in the note. Tailing is new, no bonus: 30.
    None of Impersonation, Lore: Psychics & Psionics, Prowl or Tailing is in
    Psyscape.
  - RELATED: four, plus one at levels 4, 8 and 12, in both. D-Bees changes
    two lines: "Domestic: Any, except Singing" (Psyscape: Any) and "Pilot
    Related: None" (Psyscape: Any). The catalog files Sing under
    Communications, so the exclusion is stored there. The rest is the same:
    Medical First Aid and Holistic Medicine only; Pilot (+5%); Rogue (+10%)
    except Computer Hacking; Technical (+5%) except Computer Programming;
    W.P. Blunt, Knife, Energy Pistol only; Electrical, Mechanical, Military,
    Physical and Wilderness none.
  - SECONDARY: D-Bees prints "Select one skill from the Secondary Skills
    List found on page 300 of Rifts Ultimate Edition, at levels 1, 3, 6, 9,
    12, and 15". Stored as count 1 with a schedule, and without the category
    limits. Psyscape printed 120 gave five secondary skills "from the
    previous list", limited as that list.
  - EQUIPMENT (D-Bees printed 25): backpack; "satchel or utility belt"
    stored as the utility belt; folding Swiss Army-type knife ->
    swiss-army-knife; lighter -> cigarette-lighter-refillable; compass; 50
    feet (15.2 m) of rope -> lightweight-rope (length not stored); portable
    language translator; PDD player/recorder ->
    pdd-pocket-audio-digital-disc-recorder-player (in both books; it was not
    stored before); digital camera (new in D-Bees). "A weapon for each W.P.
    (if any)" depends on the skills picked and is in GM Notes. D-Bees
    restates the line without four things Psyscape printed 120 gave, and
    they are removed: fishing tackle, sleeping roll, "conventional weapon of
    choice and one energy weapon of choice, usually a vibro-blade or
    pistol", and 1D4 extra E-clips.
  - Money: 1D6x100 credits in both.
  - Cybernetics: D-Bees "Not applicable"; Psyscape printed 120 said
    impossible because of the amorphous physiology.
  - Average life span: D-Bees "Unknown", believed immortal unless slain in
    the physical world or 2D4x100 years; Psyscape printed 119 gave "Immortal
    unless slain". Not stored.
  - xp_table: D-Bees prints the Amorph Experience Table on printed 25 and
    the fifteen lower bounds match what was stored from Psyscape printed
    157.
---

# Amorph

**Alignments.** Any, but usually unprincipled (36%) or anarchist (30%).

## Lore

Amorphs are living, thinking ectoplasm from the outer reaches of the Astral
Plane, drifting whitish blobs that can reshape themselves into a flawless copy
of almost anything they can see. They are friendly and endlessly curious,
eager to learn other peoples'' languages and histories, and often attach
themselves to travellers as guides on the Astral Plane. What they need above
all is something to do - boredom is a genuine danger to them - which is why
Psyscape''s City of the Mind''s Eye, with its crowds, shops and dimensional
gates, draws hundreds of Amorph visitors every week. A few settle there, work
for credits and spend them on translators and recorders to take pictures home.

## GM Notes

NPC-headed: the book offers the Amorph as an optional player character only at
G.M. discretion, and says it is a difficult character to play and not advised.
Player-character Amorphs usually come from Psyscape and should be played as
naive, nosy, well-meaning and fascinated by everything, following their
companions'' lead because they rarely recognise danger. Player characters
should start at first or second level.

Standard equipment the sheet does not carry: a weapon for each W.P. the
character has, if any. The rope is 50 feet (15.2 m). The book allows a satchel
in place of the utility belt. It may also keep small odds and ends as
souvenirs, and likes magic items.

Amorphs deal fairly with everyone and go to great lengths for friends, but do
not like to associate with their own kind, whom they see as rivals. They hate
and fear demons and other supernatural beings and flee from creatures of
magic.
',
       updated_at = datetime('now')
 WHERE class_id = 'amorph'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.117-120') > 0
   AND length(markdown) = 14439;

-- == demon-dragonmage ==
UPDATE imported_classes
   SET markdown = '---
id: demon-dragonmage
name: Demon-Dragonmage (Young)
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.58-60
category: rcc
tags: [supernatural, high-power]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
men_of_arms: false
attribute_dice:
  IQ: "2d6+8"
  ME: "2d6+10"
  MA: "2d6+12"
  PS: "2d6+16"
  PP: "2d6+10"
  PE: "2d6+10"
  PB: "2d6+3"
  Spd: "2d6+16"
mdc_base: "P.E. attribute x10, +3d6 per level of experience"
ppe_base: "1d4x100 + P.E. attribute number, +3d6 per level of experience"
starting_money: "1d6x1000"
horror_factor: 10
bonuses:
  at_level:
    - { level: 2, combat: { roll: 2 } }
    - { level: 5, combat: { attacks: 1, initiative: 1, pull_punch: 2 }, saves: { horror_factor: 3 } }
    - { level: 8, saves: { possession: 6 } }
    - { level: 12, combat: { perception: 2 } }
skills:
  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "anarchist or evil alignment" }, creation_only: true }
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 0 }
    - { name: "Language: Dragonese", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 15, per_level: 5, note: "Two languages of choice (+15%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 15, per_level: 5, note: "Literacy: one of choice (+15%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Seduction", base: 33, per_level: 3, note: "+13%" }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Lore: Astral", "Lore: D-Bee", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Geomancy or Lines of Power", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { choose: 2, categories: ["Pilot", "Horsemanship"], note: "Pilot or Horsemanship: two of choice." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: one Ancient of choice." }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Handguns", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"], note: "W.P.: one Modern of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert, or Assassin if Anarchist or evil. The Hand to Hand skill cannot be changed once it is selected." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - "Horsemanship"
      - "Pilot Related"
      - { name: "Rogue", bonus: 10 }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 2 }
    note: "Cowboy, Electrical, Mechanical, Medical and Wilderness: none. All new skills start at level one proficiency. The book also grants two more at each of levels 16, 18, 20, 24, 26, 28 and 30."
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
psionics:
  type: "master"
  isp_base: "2d4x10 + M.E. attribute number, +10 per level of experience"
  powers: ["Pyrokinesis", "Bio-Manipulation (the evil eye)", "Telepathy", "Mind Block"]
  powers_starting: 0
  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Super"] }
    - { level: 2, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 3, count: 1, categories: ["Super"] }
    - { level: 3, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 4, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 5, count: 1, categories: ["Super"] }
    - { level: 5, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 6, count: 1, categories: ["Super"] }
    - { level: 6, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 7, count: 1, categories: ["Super"] }
    - { level: 7, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 8, count: 1, categories: ["Super"] }
    - { level: 8, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 9, count: 1, categories: ["Super"] }
    - { level: 9, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 10, count: 1, categories: ["Super"] }
    - { level: 10, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 11, count: 1, categories: ["Super"] }
    - { level: 11, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 12, count: 1, categories: ["Super"] }
    - { level: 12, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 13, count: 1, categories: ["Super"] }
    - { level: 13, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 14, count: 1, categories: ["Super"] }
    - { level: 14, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 15, count: 1, categories: ["Super"] }
    - { level: 15, count: 3, categories: ["Healing", "Sensitive", "Physical"] }
magic:
  type: "spell"
  spells: ["Blinding Flash", "Ignite Fire", "Fuel Flame", "Fire Bolt", "Fire Ball"]
  spells_starting: 20
  spell_levels_allowed: [1, 2, 3, 4, 5, 6]
  spells_starting_groups:
    - { count: 20, spell_levels: [1, 2, 3, 4, 5, 6], note: "Roll 3D4+8 and pick that many spells from levels 1-6. 20 is the most the roll can give; the picker cannot enforce the roll, so take only what you rolled." }
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
natural_abilities:
  - { name: "Supernatural being", description: "A mega-damage being. P.S. is Robotic as a Young-Dragonmage and becomes Supernatural as a mature Demon-Dragonmage. Seemingly immortal unless slain, although a Young-Dragonmage that does not reach maturity by 2100 years of age dies. Perfect vision, senses on par with a human''s." }
  - { name: "Creature of Fire", description: "Impervious to all normal heat and fire, including M.D. plasma. Magic fire and magical flaming weapons inflict half damage." }
  - { name: "Nightvision", description: "1000 feet (305 m) (1st level)." }
  - { name: "See the Invisible", description: "1st level." }
  - { name: "Rapid Healing", description: "Heals three times faster than humans (1st level)." }
  - { name: "Impervious to Disease", description: "1st level." }
  - { name: "Leap", description: "10 feet (3 m) high or across (2nd level)." }
  - { name: "Invisibility at Will", description: "Turns invisible at will at no I.S.P. or P.P.E. cost (3rd level)." }
  - { name: "Bio-Regeneration", description: "Regenerates 1D6 M.D.C. per melee round (4th level). At 25th level, 1D6x10 M.D.C. per melee round. At 30th level, regenerates the entire body within 48 hours provided the dragon''s head is not destroyed and at least 20% of the body remains intact." }
  - { name: "Understands All Languages", description: "Magically understands and can speak all languages (6th level)." }
  - { name: "Sense Ley Lines", description: "Same as the Ley Line Walker (7th level)." }
  - { name: "Teleport", description: "Self and up to 300 lbs (135 kg), at will, up to five miles (8 km) away, at no P.P.E. cost (9th level)." }
  - { name: "Greater Demon / Dimensional Teleport", description: "At 10th level it is considered a Greater Demon and gains Dimensional Teleport at 30%, +2% per each subsequent level of experience." }
  - { name: "Later Manifestations (15th level and beyond)", description: "15th level: +2D6x10 M.D.C. and flying speed increases by 50%. 18th level: double the range of fire attacks. 20th level: +2 attacks per melee round. The 25th and 30th level entries are under Bio-Regeneration." }
  - { name: "No flight", description: "Cannot fly under its own power until it becomes a full Demon-Dragonmage." }
special_abilities:
  - name: "Ley Line Walker Spell Casting"
    description: "Has the same fundamental spell casting abilities as a Ley Line Walker, without the Walker''s O.C.C. abilities, and can learn additional magic the same as the Ley Line Walker via a tutor. Many of its early spells are fire based."
  - name: "Temporal Magic (10th level)"
    description: "Experienced characters (10th level and up) may choose to make their spell selections from Temporal Magic instead (see Rifts England or Rifts Book of Magic)."
level_progression:
  - { level: 2, grants: ["Leap 10 ft high or across", "+2 to roll with impact", "1 Super psionic power + 3 from Healing, Sensitive and/or Physical (every level from 2)"] }
  - { level: 3, grants: ["Turn invisible at will"] }
  - { level: 4, grants: ["Bio-Regenerate 1D6 M.D.C. per melee round"] }
  - { level: 5, grants: ["+1 attack per melee", "+1 initiative", "+2 pull punch", "+3 save vs Horror Factor"] }
  - { level: 6, grants: ["Magically understands and speaks all languages"] }
  - { level: 7, grants: ["Sense ley lines"] }
  - { level: 8, grants: ["+6 save vs possession"] }
  - { level: 9, grants: ["Teleport self and up to 300 lbs, five miles, at will"] }
  - { level: 10, grants: ["Considered a Greater Demon", "Dimensional Teleport 30% +2% per later level", "May select Temporal Magic spells"] }
  - { level: 12, grants: ["+2 to Perception Rolls"] }
  - { level: 15, grants: ["+2D6x10 M.D.C.", "Flying speed +50%"] }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "sack", qty: "1d4" }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 3 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Playable only with G.M. permission: the stat block is headed ''Dragonmage - NPC Villain and Optional Player Character'' and the Player Note says the character is best reserved as an NPC or villain played by the Game Master, with only the Young-Dragonmage available as a Player Character, provided the G.M. allows it."
  - "A player character is a Young-Dragonmage. The mature Demon-Dragonmage is an NPC stage and is not playable here."
  - "Available O.C.C.s: None. The character is a Dragonmage by nature and cannot change even if one tries."
  - "No cybernetics or bionics: none, impossible."
  - "Hand to Hand cannot be changed once it is selected."
  - "Starts with one weapon for each W.P.; loves magic weapons and devices of all kinds but starts with none. May or may not use body armor."
  - "Money: besides the 1D6x1000 credits, starts with an equal amount in tradeable valuables."
side_effects: "Vulnerabilities: magical cold and ice based attacks inflict double damage, as do holy weapons; most types of magic, psionics and energy weapons inflict full damage. Hated and targeted regardless of alignment and good deeds by dragons (even hatchlings), Darkhounds, Temporal Raiders and True Atlanteans (especially Undead Slayers and the Sunaj); creatures of light, angels and spirits are wary of it and of anyone with it. Those in the know usually see a Young-Dragonmage as a potential rival, enemy or monster and the people with him as fools or henchmen, which could bring trouble for the group. Demon & Monster Lore may recognize a Young-Dragonmage at -10%."
extraction_notes: |
  - PRINTING. This class followed Rifts World Book 12: Psyscape printed 120-123 until this
    update; it now follows the newer printing, Rifts World Book 30: D-Bees of North America
    printed 58-60 (the entry''s last lines run onto printed 61), which says the race
    originally appeared in Psyscape (ruling of 2026-10-04: the newest printing that states a
    figure wins and the older figure is kept here). Both entries were read off page renders
    (D-Bees cache p059-p062, Psyscape cache p121-p124).
  - UNCHANGED BETWEEN THE PRINTINGS: the eight attribute dice, M.D.C. P.E. x10 +3D6 per
    level, Horror Factor 10 (15 mature), P.P.E. 1D4x100 + P.E. +3D6 per level, size and
    weight, the Creature of Fire ability, the level 1 to 10 abilities (but for the
    teleport''s metric figure), the whole R.C.C. Skills list and its percentages, the four
    first-level psionic powers and the one Super plus three others per later level, I.S.P.
    2D4x10 + M.E. +10 per level, the five named spells plus 3D4+8 from levels 1-6, the
    equipment items, 1D6x1000 credits, and the dragon experience table.
  - NPC-HEADED, G.M. DISCRETION. D-Bees printed 59 heads the stat block "Dragonmage - NPC
    Villain and Optional Player Character"; its Player Note says the character is best
    reserved as an NPC or villain played by the Game Master and only the Young-Dragonmage
    is available as a Player Character, provided the G.M. allows it. Psyscape printed 121
    said it can be a difficult character to play and is not advised; G.M. discretion.
    Imported as the Young stage only. D-Bees printed 60 adds that Player Characters should
    start at first or second level.
  - NO VARIANTS. The book stages the race (Young / mature Demon-Dragonmage) but only the
    Young is playable. The mature stage takes hundreds or thousands of years and a
    slain hatchling or young adult dragon, and differs mostly in what a variant cannot
    override: natural abilities (immune to magic fire, fire breath and fire balls 300 ft
    6D6 M.D., flight), and doubled P.P.E. that a pool override could only approximate. So
    the adult is GM Notes prose, not a variant. Recorded adult figures: mental attributes,
    P.P. and P.E. +30%, P.S. becomes Supernatural, P.S. and Spd doubled, +1,200 M.D.C.,
    P.P.E. doubled, size doubled, weight tripled, Horror Factor 15, gains the slain
    dragon''s mystic knowledge. NPC level: D-Bees printed 60 gives the mature
    Demon-Dragonmage 2D6+15 or as set by the Game Master up to 30th level; Psyscape printed
    123 gave 15-25th level, sometimes higher. Young NPCs 1D4+4 in both.
  - P.S.: D-Bees printed 59 marks the Young''s P.S. 2D6+16 as (Robotic) and says P.S. becomes
    Supernatural in the adult; its Damage line reads "As per Robot or Supernatural P.S.".
    Psyscape printed 121 gave the same dice with no strength class, and the class had been
    stored as supernatural P.S. Stored in the Supernatural being natural ability.
  - LIFE SPAN: D-Bees prints seemingly immortal unless slain, although a Young that does not
    reach maturity by 2100 years of age dies. Psyscape printed 123 gave "Immortal unless
    slain". Psyscape''s "Hit Points: Mega-damage creature" line is not restated by D-Bees.
  - xp_table: THE DRAGON''S, copied 2026-09-26. D-Bees printed 60 says "Use the Dragon
    Experience Table", as Psyscape printed 123 and 157 did. The ladder is the one
    dragon-hatchling carries (Nate, 2026-09-26: a class whose book says to use another
    class''s experience table copies that class''s ladder).
  - LEVELS PAST 15. D-Bees prints ability, related-skill and secondary-skill ladders that
    run to level 30, where Psyscape stopped at 10, 12 and 15. Levels 1 to 15 are stored;
    every figure past 15 is prose and is listed here: abilities at 18 (double the range of
    fire attacks), 20 (+2 attacks per melee round), 25 (Bio-Regenerates 1D6x10 M.D.C. per
    melee round) and 30 (regenerates the entire body within 48 hours provided the dragon''s
    head is not destroyed and at least 20% of the body remains intact); two related skills
    at each of 16, 18, 20, 24, 26, 28 and 30; two secondary skills at each of 18, 21, 25
    and 30.
  - LEVEL ABILITIES: the numeric ones are bonuses.at_level (2: +2 roll; 5: +1 attack, +1
    initiative, +2 pull punch, +3 vs Horror Factor; 8: +6 vs possession; 12: +2 to
    Perception Rolls, new in D-Bees). The 15th level "+2D6x10 M.D.C. and increase flying
    speed by 50%" (new in D-Bees) is a rolled pool gain at a level and is prose in
    natural_abilities and level_progression, not a bonus. The rest are natural_abilities
    and level_progression (display). 2nd level reads "+2 to roll with impact" in D-Bees
    and "+2 to roll with impact or fall" in Psyscape. Teleport: D-Bees prints 300 lbs
    (135 kg); Psyscape printed 121 gave 300 lbs (122 kg).
  - RELATED SKILLS. D-Bees printed 60 prints Communications: Any (+5%), Cowboy: None,
    Domestic: Any, Electrical: None, with five to start, one more at levels 4, 8 and 12 and
    two at levels 14, 16, 18, 20, 24, 26, 28 and 30. Psyscape printed 123 scrambled the
    first three category names in the book itself ("Commuestic: Any", "Elecnications: Any
    (+5%)", "Domtrical: None") and gave one more at levels 4, 8 and 12 only; the class had
    stored that by line position as Communications Any and Domestic Any (+5%), the reverse
    of what D-Bees prints. Psyscape printed no Cowboy line. The other categories and
    percentages are the same in both. Horsemanship is granted because Pilot is Any and the
    catalog files riding under its own category (the Amazon precedent).
  - SECONDARY SKILLS. D-Bees prints two from the Secondary Skill List on page 300 of Rifts
    Ultimate Edition at levels 1, 3, 5, 8, 11, 15, 18, 21, 25 and 30, with no bonuses other
    than a possible high I.Q. bonus. Psyscape printed 123 gave two "from the previous
    list" (the related-skill categories, limited as that list is) at levels 1, 3, 5, 8, 11
    and 15, and the class had stored those categories on secondary_skills. D-Bees no longer
    ties the picks to the related list, so the category limit is removed.
  - SKILLS: Basic Math is Mathematics: Basic 45+20; Seduction 20+13; Dance 30+20; Sing
    35+10; Climb is Climbing 40+10; Land Navigation 36+10; Lore: Demons & Monsters
    25+20. Demongogian and Dragonese at 98% are their own catalog rows. "Pilot or
    Horsemanship: two of choice" is a choose 2 across Pilot and Horsemanship. The
    catalog does not split W.P.s into Ancient and Modern, so each is a named list.
  - HAND TO HAND: Expert, or Assassin if Anarchist or evil; D-Bees says the skill "cannot be
    changed once it is selected", Psyscape "can not be changed or upgraded". Stored as
    Expert granted plus a hand_to_hand block pricing Assassin at 0 with the alignment
    condition and creation_only, so the only change on offer is the creation-time swap the
    book allows. Attacks per Melee: as per Hand to Hand Combat skill (D-Bees); Psyscape
    printed "Combat: As per skill and training".
  - AVAILABLE O.C.C.s: D-Bees printed 60 prints "None. The character is a Dragonmage by
    nature and cannot change even if one tries. See R.C.C. Skills above." Psyscape printed
    no such line. An occ_restrictions only list may not be empty, so this is a
    restrictions line.
  - PSIONICS: Master Psychic (D-Bees; Psyscape said master psionic). The four first-level
    powers are granted by name; Bio-Manipulation is the catalog row "Bio-Manipulation (the
    evil eye)". Each level from 2 grants one Super power and three from Healing, Sensitive
    and/or Physical, stored as two schedule entries per level through 15. I.S.P. 2D4x10 +
    M.E., +10 per level.
  - MAGIC: the five named fire spells are granted. The book''s "plus 3D4+8 spells from
    levels 1-6" is a rolled count; a starting count must be a number, so the group is
    capped at 20 (the roll''s maximum) with a note telling the player to take only what
    was rolled. JUDGEMENT CALL - the cap is not enforced below 20. D-Bees prints "can learn
    additional magic the same as the Ley Line Walker via a tutor"; Psyscape printed 123
    said "the same as the Line Walker" without the tutor. Stored as the ley-line-walker''s
    per-level rule (spells_per_level 2, up_to_character_level), as before. Temporal Magic:
    D-Bees prints that characters of 10th level and up may choose to make selections from
    Temporal Magic instead (see Rifts England or Rifts Book of Magic); Psyscape printed
    that the experienced character can also learn Temporal Magic (see Rifts England) and
    pointed to Federation of Magic for the spell list. Stored as a special ability in
    prose; no spell_traditions_allowed, because the gate is by character level.
  - VULNERABILITIES: D-Bees adds holy weapons to the double-damage line; Psyscape printed
    121 gave magical cold and ice only. D-Bees adds Darkhounds to those who hate and target
    the character, and its Rivals and Enemies line (printed 61) adds Pogtal Dragon Slayers,
    Psi-Hounds, Lyn-Srial, Cyber-Knights and most heroes and champions of light.
  - POOLS: mega-damage creature, no hit points; mdc_base is stated so men_of_arms false
    is only the race default. Horror Factor 10 (Young) is stored in horror_factor.
  - EQUIPMENT: clothing (cloaks and leather), backpack, bedroll, 1D4 medium sacks (the
    generic sack row), utility belt, lighter, compass, 50 ft of rope as three 20 ft
    lengths, portable language translator, survival knife, canteen - the same items in
    both printings. D-Bees ends the line "and one weapon for each W.P. They love magic
    weapons and devices of all kinds, but start with none"; Psyscape printed 123 gave
    "Weapons: Two reflecting the character''s W.P.s" and a separate "Vehicle: Starts with
    none", which D-Bees does not restate. Body armor "may or may not" and the weapons are
    a restrictions line.
  - MONEY: D-Bees prints 1D6x1000 in credits and an equal amount in tradeable valuables;
    Psyscape printed 123 gave 1D6x1000 in credits only. starting_money holds the credits;
    the valuables are a restrictions line, there being no catalog row for them.
  - ALIGNMENT: D-Bees prints Young can be any, but usually Unprincipled (20%), Anarchist
    (40%) or any evil (20%); adults Miscreant (30%), Diabolic (34%) or Aberrant (15%), with
    a small percentage Anarchist (15%) or good (6%). Psyscape printed 121 gave Young
    usually anarchist (40%) or evil (40%), adults predominantly evil with 6% good. Size
    6-7 ft, weight 200-250 lbs.
  - NOT STORED, D-Bees only: Slave Market Value, Young 2D6x10,000 credits, adult 4D6
    million; habitat anywhere in the Megaverse, with at least a hundred operating from the
    Magic Zone; the female gives birth to 1D4 young after a 9 year pregnancy.
---

## Lore

The Demon-Dragonmage is a hairless, white-skinned, thick-skulled demon, probably from another dimension, and a sworn enemy of all dragons. In its youth it looks like an ordinary D-bee and spends a thousand years or more wandering the Megaverse as an adventurer, bandit, ruler or cult leader, gathering fire-based magic and psionic power. To reach maturity it must kill a hatchling or young adult dragon and magically bind the dragon''s head to its own chest, gaining wings, flaming eyes, vast M.D.C. and the dead dragon''s mystic knowledge. Most young start out unprincipled, anarchist or aberrant, but age tends to corrupt them, and the adults set out to rule kingdoms and be worshipped as gods.

**Alignments.** Young can be any, usually Unprincipled (20%), Anarchist (40%) or any evil (20%). Adults are Miscreant (30%), Diabolic (34%) or Aberrant (15%), with only a small percentage Anarchist (15%) or good (6%).

## GM Notes

Playable only with G.M. permission. The book heads the stat block "Dragonmage - NPC Villain and Optional Player Character" and says the character is best reserved as an NPC or villain; a player character is always a Young-Dragonmage and should start at first or second level.

Dragons, even hatchlings, hate the race on sight, as do Darkhounds, Temporal Raiders, True Atlanteans (Undead Slayers and the Sunaj above all) and the Splugorth, and good-aligned young are hunted along with the rest. Expect exposure to cost the whole party.

The mature Demon-Dragonmage is an NPC stage and is not modelled. On transformation: +1,200 M.D.C., P.P.E. doubled, mental attributes, P.P. and P.E. raised 30%, P.S. becomes Supernatural, P.S. and Spd doubled, twice the size and three times the weight, wings and flight, Horror Factor 15, impervious even to magic fire, fire breath and fire balls (300 ft, 6D6 M.D. each), and the slain dragon''s mystic knowledge. NPC adults run 2D6+15 or as set by the Game Master, up to 30th level, and use the dragon experience table.
',
       updated_at = datetime('now')
 WHERE class_id = 'demon-dragonmage'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.120-123') > 0
   AND length(markdown) = 18284;

-- == lanotaur-hunter ==
UPDATE imported_classes
   SET markdown = '---
id: lanotaur-hunter
name: Lanotaur Hunter
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.115-117
category: rcc
tags: [supernatural, hunter, combat]
attribute_dice:
  IQ: "2d6+8"
  ME: "3d6+8"
  MA: "1d6+1"
  PS: "2d6+14"
  PP: "1d6+20"
  PE: "3d6+8"
  PB: "2d6+2"
  Spd: "2d6x10+18"
mdc_base: "P.E. + 3d6x10, +2d6 per level"
ppe_base: "P.E. x3, +3d6 per level"
horror_factor: 12
starting_money: "1d4x10000"
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]
bonuses:
  combat: { attacks: 4, initiative: 8, strike: 4, parry: 5, automatic_dodge: 7, disarm: 3, entangle: 2, pull_punch: 5, roll: 4 }
  saves: { horror_factor: 6, toxins_poisons: 2, psionics: -2 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
    - { name: "Cook", base: 55, per_level: 5, note: "+20%" }
    - { name: "Dowsing", base: 40, per_level: 5, note: "+20%" }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Attacks per melee as per Hand to Hand: Martial Arts, but with the abilities of Paired Weapons, Kick and Leap Attack at first level." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Printed Language & Literacy: Native Tongue (alien, 98%)." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Printed Language & Literacy: Native Tongue (alien, 98%)." }
    - { name: "Language: Dragonese", base: 70, per_level: 5, note: "Printed Language: Other: Dragonese/Elven (+20%)." }
    - { name: "Prowl", base: 45, per_level: 5, note: "+20%" }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Tailing", base: 50, per_level: 5, note: "+20%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "+15%" }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0, note: "The Lanotaur is naturally ambidextrous." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One W.P. of choice." }
  occ_related_skills:
    count: 0
    categories:
      - "Communications"
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", except: ["Computer Hacking", "Safe-Cracking", "Seduction"] }
      - "Technical"
      - "Wilderness"
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 7, count: 2 }, { level: 11, count: 2 }, { level: 15, count: 2 }]
    note: "No related skills at first level: select two at levels 2, 4, 7, 11 and 15. Pilot: any except robot and military vehicles."
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
psionics:
  type: "master"
  isp_base: "M.E. + 1d6x10+10, +2d6 per level"
  powers: ["Mind Block Auto-Defense", "Presence Sense", "Sixth Sense", "Death Trance", "Telepathy", "Read Dimensional Portal", "Deaden Senses", "Alter Aura"]
  categories_allowed: ["Physical", "Sensitive", "Super"]
  powers_schedule:
    - { level: 2, count: 4, categories: ["Physical"], note: "The book grants 1D4 Physical powers at second level. Roll 1D4 and take that many; four is the most the roll allows." }
    - { level: 3, count: 4, categories: ["Sensitive"], note: "The book grants 1D4 Sensitive powers at third level. Roll 1D4 and take that many; four is the most the roll allows." }
    - { level: 4, count: 1, from: ["Psi-Sword"], note: "Psi-Sword is granted at fourth level." }
    - { level: 4, count: 1, categories: ["Super"], note: "One other Super power of choice." }
    - { level: 5, count: 1, from: ["Bio-Regeneration (Super)"], note: "Bio-Regeneration (super) is granted at fifth level." }
    - { level: 5, count: 1, categories: ["Super"], note: "One Super power of choice." }
    - { level: 6, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 7, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 8, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 9, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 10, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 11, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 12, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 13, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 14, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 15, count: 1, categories: ["Sensitive", "Physical"] }
magic:
  type: "spell"
  spells: ["Invisibility (Superior)", "Dimensional Portal", "Close Rift", "Mystic Portal", "Time Hole", "Sanctum", "Anti-Magic Cloud", "Astral Hole", "Warped Space", "Swap Places", "Lifeblast", "Magic Shield", "Lightblade", "Enchant Weapon", "Restore Life"]
  spells_starting: 1
  spells_starting_groups:
    - { count: 1, from: ["Chameleon", "Shadow Meld"], note: "The book grants Chameleon or Shadow Meld - one of the two." }
  spells_schedule:
    - { level: 6, count: 6, spell_levels: [7, 8, 9, 10, 11], note: "Above fifth level the Lanotaur may know a total of 1D4+2 more spells from spell levels 7-11. Roll 1D4+2 and take that many; six is the most the roll allows." }
natural_abilities:
  - { name: "Supernatural P.S. and P.E.", description: "P.S. and P.E. are Supernatural. Typical damage: 3D6 S.D.C. restrained punch, 1D6 M.D. full strength punch, 2D6 M.D. power punch." }
  - { name: "Claws", description: "Add 1D6 M.D. to punch damage." }
  - { name: "Slashing Prehensile Tail", description: "Inflicts 2D6+2 M.D." }
  - { name: "Superhuman Speed and Reflexes", description: "High physical attributes, superhuman speed and reflexes." }
  - { name: "Naturally Ambidextrous", description: "" }
  - { name: "Nightvision", description: "100 feet (30.5 m)." }
  - { name: "Rapid Healing", description: "Heals twice as fast as humans." }
special_abilities:
  - name: "Sense Psychic and Magic Energy"
    description: "Identical in every respect to the Psi-Stalker power (see Rifts RPG / Rifts Ultimate Edition). Senses a psychic or magic practitioner not using powers within 50 feet (15.2 m) +20 feet (6 m) per additional level, and psionic or magic powers in use within 600 feet (183 m) +100 feet (30.5 m) per level. When tracking a psychic scent, roll percentile every 1000 feet (305 m) to stay on the trail. Automatic and constant; no I.S.P."
  - name: "Combat Awareness and Lightning Reflexes"
    description: "Psychic Combat Awareness and lightning-quick reflexes: the Lanotaur telepathically and empathically picks up cues about what its opponents plan to do next, and responds instinctively and automatically to attacks, dodging and blocking them. The AUTOMATIC DODGE applies to all attacks, including those from behind; it does not use up a melee attack, but must still be rolled. The advantage does not work against an opponent who is Mind Blocked. Its bonuses are already factored into the class''s combat bonuses. Range self; automatic and constant; no I.S.P."
  - name: "Mind Over Body"
    description: "Regulates its body temperature to mask its heat signature, appearing dead or invisible on infrared and thermal-imaging optics when farther than 200 feet (61 m) away; controls heart rate, respiration and body chemistry to reduce its scent (-20% to be recognized and tracked by scent); fools a lie detector every time, and interrogators are -20% on their skill; can simulate a coma or death trance."
  - name: "Combat Training"
    description: "Attacks per melee as per Hand to Hand: Martial Arts, but with the abilities of Paired Weapons, Kick and Leap Attack at first level."
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "digital-camera", qty: 1 }
  - { item_id: "handcuffs-regular", qty: "1d4" }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "night-sight-binoculars", qty: 1 }
  - { item_id: "nylon-cord", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6+4" }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "vibro-knife", qty: 2 }
restrictions:
  - "OPTIONAL PLAYER CHARACTER. The book heads the stat block Optional Player Character and NPC. Player characters start at first level."
  - "Alignment: any, but Anarchist (30%) and Aberrant (55%) are most common."
  - "Horror Factor: 12."
  - "Available O.C.C.s: None. Makes a living as a bounty hunter, demon hunter, dragon slayer or hunter-killer."
  - "Cybernetics and Bionics: None. They consider it a sign of weakness."
  - "R.C.C. Related Skills come only from Communications, Espionage, Horsemanship (General and Exotic Animals only), Physical, Pilot (not robot or military vehicles), Rogue (not Hacking, Safe-Cracking or Seduction), Technical and Wilderness."
  - "Tends to rely on natural abilities and cunning, but may use simple melee weapons, magical constructs (Lightblade, Enchant Weapon) and the occasional tech-weapon. Collects magic weapons and devices because they are valuable, but tends not to use them unless it is fair."
  - "Standard equipment also includes a hip belt, a holster for gun or knife, a satchel in place of the backpack if preferred, and a few personal items. May wear light, medium or partial M.D.C. body armor (4D6+30 M.D.C.) and is partial to M.D.C. helmets with monstrous, demonic or humorous face plates (2D6+40 M.D.C.); none is part of the starting kit."
  - "Never allies with any Earth nation or force; does not acknowledge Earth''s people or laws."
  - "Size: 8 to 9 feet (2.4 to 2.7 m) tall; 600 to 800 lbs (270 to 360 kg). Average life span 4D6+80 years."
extraction_notes: |
  Until this update the class followed Rifts World Book 12: Psyscape printed
  123-126; it now follows the newer printing, Rifts World Book 30: D-Bees of
  North America printed 115-117, which says the race originally appeared in
  Psyscape (ruling of 2026-10-04: the newest printing that states a figure wins
  and the older figure is kept here). Both entries were read off 170 dpi page
  renders: D-Bees cache p116-p118, Psyscape cache p124-p127 and p158.

  REVISED BY D-BEES (the Psyscape figure follows each):
  1. P.B. 2D6+2. Psyscape printed 125 gave P.B. 2D6.
  2. SUPERNATURAL: D-Bees marks P.S. and P.E. alone as Supernatural, and its
     lore says the Lanotaur were long believed to be supernatural beings but
     are flesh and blood D-Bees. Psyscape printed 125 gave "supernatural
     attributes" after the whole attribute line and called them supernatural
     D-bee hunters (printed 123).
  3. BONUSES: "+7 to automatic dodge on all attacks including those from
     behind (the act of dodging does not use up a melee attack, but must
     still be rolled)" is combat.automatic_dodge 7, and the line prints no
     separate dodge bonus. Psyscape printed 125 gave "+7 to dodge, automatic
     dodge on all attacks including those from behind", stored then as
     combat.dodge 7 with the automatic dodge as prose. "+2 to entangle" is
     new in D-Bees (combat.entangle 2); Psyscape printed none. The other
     bonuses are the same in both books: four additional attacks, +8
     initiative, +4 strike, +5 parry, +3 disarm, +5 pull punch, +4 roll with
     impact, +6 vs Horror Factor, +2 vs non-lethal and lethal poisons.
  4. R.C.C. SKILLS: D-Bees printed 116 gives a full list - Acrobatics (+5%),
     Climbing (+20%), Cook (+20%), Dowsing (+20%), Hand to Hand: Martial
     Arts, Land Navigation (+20%), Language & Literacy: Native Tongue (alien,
     98%), Language: Other: Dragonese/Elven (+20%), Prowl (+20%), Skin and
     Prepare Animal Hides (+15%), Swimming (+10%), Tailing (+20%), Tracking
     (people; +15%), Track & Trap Animals (+10%), Wilderness Survival (+20%),
     W.P. Knife, W.P. Sword, W.P. Paired Weapons, W.P. Energy Pistol and one
     W.P. of choice. Each base is the catalog base plus the printed bonus.
     Language & Literacy: Native Tongue is stored as two rows at 98%;
     Language: Other: Dragonese/Elven is the Language: Dragonese row.
     Psyscape printed 123-126 gave no R.C.C. skill list at all, only the
     Combat line.
  5. NATURAL ABILITIES: the D-Bees line reads high physical attributes,
     superhuman speed and reflexes, psionics, naturally ambidextrous,
     nightvision 100 feet and heals twice as fast as humans. It leaves out
     four percentages Psyscape printed 125 gave on the same line - swim 60%,
     climb 80%/70%, prowl 50% +2% per level, and track by sight (follows
     trails, footprints and other visual signs) 44% +4% per level - and they
     are removed; swimming, climbing, prowl and tracking are R.C.C. skills in
     D-Bees.
  6. R.C.C. RELATED SKILLS: two at levels 2, 4, 7, 11 and 15, none at first
     level (count 0 plus a schedule), from Communications, Espionage (+5%),
     Horsemanship (General and Exotic Animals only), Physical, Pilot (any,
     except robot and military vehicles), Rogue (any, except Hacking,
     Safe-Cracking and Seduction), Technical and Wilderness. The Pilot
     exception is stored as the catalog''s Robots & Power Armor, Robot Combat
     and Military: rows; Hacking is the catalog''s Computer Hacking.
     SECONDARY SKILLS: two at levels 1, 3, 8 and 12. Psyscape printed neither.
  7. AVAILABLE O.C.C.s: None (D-Bees printed 116), a restriction line.
     Psyscape was silent on an O.C.C. pairing. CYBERNETICS AND BIONICS: None
     (printed 117); Psyscape printed nothing.
  8. STANDARD EQUIPMENT (D-Bees printed 117; Psyscape printed 126 gave only a
     Weapons & Equipment habit line and no kit): waist belt with pouches,
     pockets and holster (utility-belt), bandoleer, hip belt, backpack or
     satchel (backpack), canteen, language translator, handheld computer,
     digital camera, 1D4 pairs of handcuffs, binoculars, passive nightsight
     binoculars (night-sight-binoculars), 100 feet (30.5 m) of nylon cord
     (nylon-cord, one), 1D6+4 wooden stakes, wooden cross, two Vibro-Knives
     (1D6 M.D.) and a few personal items. The hip belt, the satchel
     alternative, the personal items, and the body armor and helmet the
     Lanotaur "may wear" (4D6+30 and 2D6+40 M.D.C.) are a restriction line,
     not gear rows. Psyscape said they "tend to avoid using magic weapons and
     devices because it''s not fair"; D-Bees says they collect them and tend
     not to use them unless it is fair, and adds the occasional tech-weapon.
  9. MONEY: starts with 1D4x10,000 credits (D-Bees printed 117). Psyscape
     printed none.
  10. HEADING AND ALIGNMENT: D-Bees heads the stat block "Lanotaur Hunter -
      Optional Player Character and NPC" and says player characters should
      start at first level (NPCs 2D6). Psyscape printed 125 headed it
      "Lanotaur Psi-Hunter NPC Villain" with no player note, and the class
      was imported then with a G.M.-permission note on Nate''s decision
      (cibola-gatherer precedent). Alignment in D-Bees is "Any, but Anarchist
      (30%) and Aberrant (55%) are most common"; Psyscape printed 125 gave
      "anarchist or evil are most common" and printed 123 the 55% aberrant.
  11. ABILITY 2 is named "Combat Awareness and Lightning Reflexes (special)"
      in D-Bees; Psyscape printed 125 named it "Psychic Reflexes". MIND OVER
      BODY gains "Interrogators are -20% on their skill". SENSE PSYCHIC AND
      MAGIC ENERGY now points to Rifts RPG / Rifts Ultimate Edition (Psyscape
      printed 124 cited Rifts RPG p.105 and Lone Star p.158) and prints 600
      feet as 183 m (Psyscape 182 m).
  12. SIZE AND LIFE SPAN: weight 600 to 800 lbs (270 to 360 kg) and average
      life span 4D6+80 years. Psyscape printed 125 gave 272 to 363 kg and
      80-120 Earth years.

  THE SAME IN BOTH BOOKS, and unchanged here:
  13. Attributes other than P.B.; M.D.C. P.E. plus 3D6x10, +2D6 per level;
      Horror Factor 12; P.P.E. P.E. x3 plus 3D6 per level, read as including
      first level; I.S.P. 1D6x10+10 plus M.E., +2D6 per level.
  14. XP_TABLE: D-Bees prints the Lanotaur Experience Table at the end of the
      entry (printed 117) and it is the ladder Psyscape printed 157 gives
      under "Zenith Moon Warper, Lanotaur Hunter".
  15. ATTACKS: four additional attacks is combat.attacks 4, on top of Hand to
      Hand: Martial Arts, which D-Bees now lists as an R.C.C. skill. No
      hand_to_hand block: no upgrade price is printed. Kick and Leap Attack
      at first level have no catalog rows and are prose in Combat Training.
      The Combat Awareness bonuses are already included in the printed
      bonuses, so nothing is added for them.
  16. SAVES: +2 vs non-lethal and lethal poisons is saves.toxins_poisons 2.
      Master Psychic but -2 to save vs psionic attack (needs 12) is
      saves.psionics -2; D-Bees prints it under Vulnerabilities.
  17. PSIONICS: the eight named starting powers match catalog rows exactly.
      1D4 Physical at level 2 and 1D4 Sensitive at level 3 are stored at
      count 4 with a roll-1D4 note, since a count must be a number
      (leopard-men precedent). Psi-Sword (level 4) and Bio-Regeneration
      (Super) (level 5) are schedule entries with a one-name `from`, each
      beside one Super pick. Levels 6-15 are one Sensitive or Physical pick
      each.
  18. MAGIC (limited): the same fifteen named spells and "Chameleon or
      Shadow Meld" as a one-pick starting group; D-Bees adds P.P.E. costs
      beside them. "Warp Space" is the catalog''s Warped Space. "Higher than
      5th level ... a total of 1D4+2 additional spells from spell levels
      7-11" is one level-6 schedule entry at count 6 with a roll-1D4+2 note.
  19. Not stored: habitat, allies, rivals and enemies, disposition, slave
      market value (2D4x100,000 credits) and pronunciation (Lan oh tor).
---

# Lanotaur Hunter

## Lore

The Lanotaur are huge D-bee predators, eight to nine feet tall, who
treat Rifts Earth as a vast hunting preserve. They combine a Juicer''s speed and
strength with a Psi-Stalker''s ability to sense psychics and magic, and they hunt
humanoids purely for the sport of it, using only claws, a slashing tail, psionics
and a little concealment and travel magic. Many hold to a code of fair play,
seeking out worthy prey - warriors, psychics, mages, dragons and supernatural
beings - and sometimes sparing a foe they come to respect. They feel a kinship
with Psi-Stalkers, Dog Boys and Darkhounds and avoid killing them where they can.
They favour forests and jungles rich in psychics and magic, such as the Magic
Zone, Calgary, South America, the Congo and China.

## GM Notes

The book presents the Lanotaur Hunter as an optional player character and NPC.
Player characters start at first level; an NPC is 2D6 levels or as the Game
Master sets.

A Lanotaur usually studies its prey from hiding first, then strikes hard at close
quarters and withdraws, or issues a challenge to single combat. Outnumbered, it
never stays in the open for more than 2D4 melees unless trapped. The trick to
beating one is teamwork, long-range attacks, clever psionics and magic, and
surprise. The Splugorth sometimes cater to them with game, arena fights and
safaris; True Atlanteans, the Sunaj, Chiang-Ku dragons and Temporal Raiders are
among those they hunt. A Lanotaur that claims a hunting ground defends it fiercely,
especially against loggers and developers.
',
       updated_at = datetime('now')
 WHERE class_id = 'lanotaur-hunter'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.123-126') > 0
   AND length(markdown) = 11820;

-- == psi-goblin ==
UPDATE imported_classes
   SET markdown = '---
id: psi-goblin
name: Psi-Goblin
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.164-166
category: rcc
tags: []
attribute_dice:
  IQ: "1d6+8"
  ME: "2d6+8"
  MA: "1d6"
  PS: "2d6+12"
  PP: "2d6+12"
  PE: "2d6+12"
  PB: "2d6"
  Spd: "6d6"
mdc_base: "P.E. attribute number + 6d6+10, +1d6 per level of experience"
ppe_base: "3d4x10+38; does not increase with experience"
starting_money: "2d6x100"
horror_factor: 11
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
bonuses:
  combat: { attacks: 1, initiative: 3, perception: 1, strike: 2, disarm: 3, pull_punch: 4, roll: 2 }
  saves:
    horror_factor: 6
    spell_magic: 2
    ritual_magic: 2
    toxins_poisons: 3
    other: [ { label: "vs radiation", bonus: 3 }, { label: "vs pollution", bonus: 3 } ]
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "Speaks Gobblely at 98%." }
    - { name: "Language: Other", base: 98, per_level: 0, note: "Faerie Speak at 98%. The catalog has no Faerie Speak language row." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One additional language of choice, typically American (+10%)." }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%" }
    - { name: "Interrogation", base: 50, per_level: 5, note: "+20%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "Printed as (10%); read as +10%." }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Tailing", base: 50, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. Knife or Sword." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: one Ancient of choice." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Heavy M.D. Weapons"], note: "W.P.: one Energy Weapon of choice." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Hand to Hand: Expert (cannot be changed)." }
    - { choose: 4, categories: ["Espionage"], note: "1D4 Espionage skills of choice. Roll 1D4 and take that many; four is the most the roll allows." }
    - { choose: 4, categories: ["Rogue"], note: "1D4 Rogue skills of choice. Roll 1D4 and take that many; four is the most the roll allows." }
    - { choose: 4, categories: ["Technical", "Wilderness"], note: "1D4 Technical or Wilderness skills of choice. Roll 1D4 and take that many; four is the most the roll allows." }
  occ_related_skills:
    count: 0
    categories:
      - "Espionage"
      - "Rogue"
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
psionics:
  type: "major"
  isp_base: "1d6x10+10 + M.E. attribute number, +1d6 per level of experience"
  powers: ["Detect Psionics", "Death Trance", "See The Invisible", "Sense Magic", "Sense Evil", "Mind Block", "Ectoplasm"]
  powers_starting: 2
  categories_allowed: ["Physical"]
magic:
  type: "spell"
  spells: ["Shadow Meld", "Armor of Ithan", "Fool''s Gold", "Repel Animals", "Energy Bolt", "Forcebonds", "Frostblade"]
  spells_starting: 0
trackable_resources: []
natural_abilities:
  - { name: "Supernatural P.S. and P.E.", description: "On Rifts Earth (and Wormwood). Typically 3D6 S.D.C. restrained punch, 1D6 M.D. full strength punch, 2D6 M.D. power punch." }
  - { name: "Claws and Bite", description: "Claws add 1D6 M.D. to punching attacks; a bite does 1D6 M.D. Where magic is low these become Hit Point/S.D.C. damage." }
  - { name: "Mega-Damage Creature", description: "A mega-damage being on Rifts Earth. On its native world and other low-magic places it is a Hit Point and S.D.C. being instead: Hit Points P.E. + 6D6 (+1D6 per level), S.D.C. 1D4x10." }
  - { name: "Double-Jointed", description: "Reflected in the Escape Artist bonus." }
  - { name: "Nightvision", description: "1000 feet (305 m)." }
  - { name: "Swim", description: "55%." }
  - { name: "Climb", description: "80%/70%." }
  - { name: "Bio-Regeneration", description: "Regenerates 2D6 points per hour. Regrows fingers, ears and similar within 72 hours; a hand, arm or leg in 1D4 weeks." }
  - { name: "Impervious to Disease", description: "" }
special_abilities:
  - name: "Innate Magic"
    description: "Like a Mystic, intuitively knows a handful of spells and casts them by spending P.P.E.: Shadow Meld (10), Armor of Ithan (10), Fool''s Gold (10), Repel Animals (7), Energy Bolt (5), Force Bonds (25) and Frostblade (15). No limit on uses per day is printed; the P.P.E. does not increase with experience."
equipment_starting:
  - { choose: 1, label: "large sack, satchel or backpack", qty: 1, from: ["large-sack", "purse-satchel", "backpack"] }
  - { item_id: "water-skin-half-gallon", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 1 }
  - { choose: 1, label: "torture kit: small sharp knife or scalpel", qty: 1, from: ["knife", "scalpel"] }
  - { item_id: "black-jack", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "salt", qty: 1 }
restrictions:
  - "G.M. PERMISSION: the book presents the Psi-Goblin as an optional player character and NPC. A player Psi-Goblin is either an outcast with delusions of being a hero or adventurer (scrupulous, unprincipled or anarchist) or one of Dunscon''s spies pretending to be a good guy, likely to betray the group sooner or later."
  - "Alignment: any, but most are anarchist (35%), miscreant (32%) or diabolic (30%)."
  - "Hand to Hand: Expert cannot be changed."
  - "No secondary skills. Available O.C.C.s: none. One additional Rogue or Espionage skill at levels 4, 8 and 12; all new skills start at first level proficiency."
  - "Player characters start at level one."
  - "Not sophisticated enough to use power armor, pilot robots or most combat vehicles; adores hovercycles, motorcycles and jet packs."
  - "Cybernetics and bionics: don''t need or want them."
  - "Standard equipment also includes a loincloth, war paint and, in the torture kit, 1D6+4 sharp metal or wooden needles, a pair of needle nosed pliers, six ounces of salt and other odds and ends. Starts with 2D6x100 credits in tradeable goods on top of the 2D6x100 credits in coin."
  - "Size: 4 to 5 feet (1.2 to 1.5 m) tall; 90 to 120 lbs (40.5 to 54 kg). Average life span 1D6x100+400 years; physical maturity at age 14."
extraction_notes: |
  ORIGINAL: this class was imported from Rifts World Book 12: Psyscape printed
  128-130 and followed that printing until this update, which brings it to the
  Rifts World Book 30: D-Bees of North America printing, printed 164-166 (ruling
  of 2026-10-04: the newest printing that states a figure wins and the older
  figure is kept in a note). D-Bees printed 166 says "Originally appeared in
  Rifts World Book 12: Psyscape". Both entries were read off page renders:
  D-Bees cache p165-p167, Psyscape cache p129-p131 and its Experience Point
  Tables, printed 157.

  G.M. PERMISSION: D-Bees heads the stat block "Psi-Goblin - Optional Player
  Character and NPC" (printed 165) with a Player Note, so the class stays
  playable with a G.M.-permission note in restrictions and ## GM Notes.
  Psyscape printed 129 headed it "NPC Villain & Optional Player Character" and
  its Player Note read "likely to be unprincipled or anarchist. Scrupulous,
  principled or aberrant ones are a rarity." Production''s `goblin` is the
  Palladium Fantasy goblin, a different race.

  WHAT D-BEES CHANGED (the D-Bees figure is stored; the Psyscape figure is here):
  A. ATTRIBUTES: the D-Bees attribute line (printed 165) is I.Q., M.E., M.A.,
     P.S., P.P., P.E. and Spd with the same dice as Psyscape and prints NO P.B.
     Psyscape printed 129 gave P.B. 2D6, which stays stored: an attribute with no die would roll a default neither book prints.
  B. P.P.E.: D-Bees prints it two ways. The stat block (printed 165) says
     "P.P.E.: 3D4x10+38", which is what ppe_base stores. The Magic paragraph on
     the same page says "P.P.E.: 3D4x10 plus P.E. attribute number. P.P.E. does
     not increase with experience." Psyscape printed 129 gave 3D4x10 plus P.E.
     attribute number x2, not increasing with experience.
  C. I.S.P.: D-Bees printed 165 gives 1D6x10+10 plus the M.E. attribute number,
     +1D6 per level. Psyscape printed 129 gave 1D6x10 plus M.E. attribute
     number x2, +1D6 per level.
  D. MAGIC: D-Bees printed 165 says "Like a Mystic, Psi-Goblins intuitively
     know a handful of magic spells" and prints a P.P.E. cost beside each of the
     same seven spells (10, 10, 10, 7, 5, 25, 15, which are the catalog rows''
     costs). It prints no limit on uses. Psyscape printed 129 gave each of the
     seven "three times per 24 hour period" with no P.P.E. cost, which the class
     carried as seven trackable resources; those are removed and
     trackable_resources is an empty list. The spells stay granted by name with
     spells_starting 0. The catalog rows are "Forcebonds" (RUE p.214) and
     "Frostblade" (Book of Magic p.112); the element-prefixed Frostblade,
     Fool''s Gold and Repel Animals rows were not used.
  E. BONUSES: D-Bees printed 165 restates the bonus line and adds "+1 on
     Perception Rolls" (combat.perception 1). Every other figure is the same in
     both books; Psyscape printed 130 had no Perception bonus.
  F. SKILLS: D-Bees printed 165 adds Recognize Weapon Quality (+20%) and Tailing
     (+20%) to the R.C.C. skill list; Psyscape printed 129-130 had neither.
     D-Bees also adds "One additional Rogue or Espionage skills at levels 4, 8
     and 12", stored as occ_related_skills with count 0 and a schedule over the
     Espionage and Rogue categories; Psyscape printed no later selections. The
     rest of the list is identical in both books.
  G. EQUIPMENT AND MONEY: D-Bees printed 165-166 prints a Standard Equipment
     line and a Money line; Psyscape printed none ("Weapons & Equipment" there
     is preferences only), so the class held no equipment and no money.
     starting_money is the 2D6x100 credits; the further 2D6x100 in tradeable
     goods is in restrictions. Stored gear: "a large sack, satchel or backpack"
     as a pick of one of three rows; waterskin (no size printed; the Rifts
     half-gallon row); belt; 20 feet of rope; the torture kit''s "small sharp
     knife or scalpel" as a pick of one, black jack, cigarette lighter and salt
     (six ounces printed; the row is one unit). The loincloth, war paint,
     1D6+4 needles and needle nosed pliers have no catalog row and are prose in
     restrictions.
  H. PROSE FIGURES: weight 90 to 120 lbs is "(40.5 to 54 kg)" in D-Bees and
     "(40.8 to 54 kg)" in Psyscape. Average life span is 1D6x100+400 years in
     D-Bees and "1000+ Earth years" in Psyscape. D-Bees starts player
     characters at level one; Psyscape said "level one or two". D-Bees adds
     "Cybernetics and Bionics: Don''t need or want them."

  WHAT PSYSCAPE PRINTS AND D-BEES DOES NOT RESTATE (kept):
  - The low-magic Hit Points (P.E. + 6D6, +1D6 per level) and S.D.C. (1D4x10),
    Psyscape printed 129. D-Bees says only that on their native world "they are
    Hit Point and S.D.C. beings" and prints no figures. They stay prose in the
    Mega-Damage Creature natural ability.
  - "(and Wormwood)" beside Rifts Earth for the supernatural P.S. and P.E., and
    "see bonus for escape skill" beside double-jointed.

  UNCHANGED BETWEEN THE BOOKS:
  1. XP_TABLE: D-Bees printed 165 says "Use the same Experience Table as the
     SAMAS Pilot." Psyscape printed 157 prints a "Psymbiote, Psi-Goblin" column.
     The stored ladder is that column, and it is the same fifteen figures the
     catalog''s coalition-samas-pilot (Rifts Ultimate Edition) carries, so
     nothing moved.
  2. POOLS: mdc_base only, because on Rifts Earth it is a mega-damage creature;
     P.E. attribute number plus 6D6+10, +1D6 per level, in both books. No
     men_of_arms line is needed since mdc_base is stated.
  3. PSIONICS: Major, seven named powers (See the Invisible is the catalog''s
     "See The Invisible") plus two Physical of choice, in both books. "Needs a
     12 or higher to save vs psionic attack" is the standard major-psychic
     save, so no save modifier is stored.
  4. BONUSES: "save vs magic +2" is stored as both spell_magic and
     ritual_magic 2. "+3 to save vs poison, radiation and pollution" is
     toxins_poisons 3 plus two saves.other entries. Impervious to disease is a
     natural ability (no number to store). "+2 to roll with impact or fall" is
     combat.roll 2. "+1 attack per melee" is combat.attacks 1 on top of
     Hand to Hand: Expert.
  5. SKILLS: bases are catalog base plus printed bonus. Faerie Speak has no
     catalog language row, so it is a fixed Language: Other at 98% with a
     note (godling / demon-hound-rider precedent). The extra language (typically
     American, +10%) is a Language: Other pick. "W.P. Energy Weapon of choice"
     is a pick of Energy Pistol, Energy Rifle or Heavy M.D. Weapons. The 1D4
     Espionage / Rogue / Technical-or-Wilderness selections at level one are
     stored at count 4 with a roll-1D4 note (leopard-men / lanotaur precedent).
     Hand to Hand: Expert "cannot be changed" is hand_to_hand costs {}.
     "Land Navigation (10%)" is printed without a plus in both books.
  6. NO secondary skills and no O.C.C. ("Available O.C.C.s: None", D-Bees
     printed 165).
  7. The Money, Cybernetics, Habitat, Alliances, Rivals and Experience Table
     lines at the top left of D-Bees printed 164 belong to the preceding Power
     Leech entry, not to the Psi-Goblin.
  8. Not stored: experience level of NPCs (1D6+1 in D-Bees, 3-7 in Psyscape),
     slave market value (2D6x1,000, D-Bees printed 166), litter size, habitat,
     allies, enemies, vulnerabilities and the weapons preferences beyond the
     vehicle line in restrictions.
---

# Psi-Goblin

## Lore

Psi-Goblins are small, savage D-bees from a magic-rich world much like Earth,
where they prey on Faerie Folk; many are thought to have been brought to Rifts
Earth by Lord Alistair Dunscon, who fields an army of them. Others roam the
Magic Zone as mercenaries, bandits, spies and assassins, and most people assume
every Psi-Goblin serves evil. They are jealous, greedy and cruel, resent anyone
more attractive, wealthy or powerful than themselves, and are feared as
torturers and interrogators. As creatures of magic they have more innate magic
than other goblins, along with psionics, and on Rifts Earth they become
mega-damage beings.

## GM Notes

G.M. permission required: the book presents the Psi-Goblin as an NPC villain
and an optional player character. One allowed as a player character is likely
unprincipled or anarchist.

They usually gather in groups of 6-24 ruled by one strong leader or a few
elders, and sometimes ally with Black Faeries, demons, Necromancers, high-level
evil mages, Mind Bleeders and evil psychics. They are found mainly in the Magic
Zone, with a tribe of about sixty in the ruins of Old Chicago and around a
hundred in the Pecos Empire. They hold grudges for life against anyone who
defeats or humiliates them, and they covet magic items and heavy weapons.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-goblin'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.128-130') > 0
   AND length(markdown) = 10987;

-- == yhabbayar ==
UPDATE imported_classes
   SET markdown = '---
id: yhabbayar
name: Yhabbayar Bubblemaker
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.217-220
category: rcc
tags: []
men_of_arms: false
attribute_dice:
  IQ: "2d6+8"
  ME: "2d6+8"
  MA: "3d6+12"
  PS: "2d6+8"
  PP: "2d6+10"
  PE: "2d6+8"
  PB: "2d6+2"
  Spd: "5d6"
mdc_base: "P.E. attribute number + 4d6, +1d6 per level of experience"
ppe_base: "2d4x10 + P.E. attribute number, +3d6 per additional level of experience"
starting_money: "2d4x100"
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
bonuses:
  combat: { initiative: 1, perception: 1 }
  saves: { horror_factor: 2, possession: 5, toxins_poisons: 1, disease: 1, other: [ { label: "vs illusions", bonus: 2 } ] }
  at_level:
    - { level: 3, combat: { initiative: 1, perception: 1 } }
    - { level: 5, combat: { initiative: 1, perception: 1 } }
    - { level: 7, combat: { initiative: 1, perception: 1 } }
    - { level: 9, combat: { initiative: 1, perception: 1 } }
    - { level: 11, combat: { initiative: 1, perception: 1 } }
    - { level: 13, combat: { initiative: 1, perception: 1 } }
    - { level: 15, combat: { perception: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Language & Literacy: Native Tongue: American." }
    - { name: "Literacy: Native Language", base: 40, per_level: 5, note: "Language & Literacy: Native Tongue: American (no bonus printed)." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other: two of choice (+20%) - the first. Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other: two of choice (+20%) - the second. Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "Basic & Advanced Math (+25%)" }
    - { name: "Mathematics: Advanced", base: 70, per_level: 5, note: "Basic & Advanced Math (+25%)" }
    - { name: "Art", base: 50, per_level: 5, note: "+15%; professional quality." }
    - { name: "Performance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Public Speaking", base: 45, per_level: 5, note: "+15%" }
    - { name: "Philosophy", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Sing", "Play Musical Instrument"], bonus: 15, note: "Sing or Play Musical Instrument (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Lore: Magic", "Lore: Faeries & Creatures of Magic", "Lore: Religion", "Lore: Psychics & Psionics", "Lore: D-Bee", "Lore: Juicers", "Lore: Dimensions", "Lore: Astral", "Lore: Geomancy or Lines of Power", "Lore: Vampires", "Lore: Galactic/Alien", "Lore: American Indians"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { choose: 1, from: ["Boxing", "Wrestling"], note: "Boxing or Wrestling (pick one)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: one Ancient of choice." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Heavy M.D. Weapons"], note: "W.P.: one Modern Energy Weapon of choice." }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Martial Arts; cannot be changed." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Intelligence", "Disguise"] }
      - { name: "Medical", bonus: 10 }
      - { name: "Military", only: ["Camouflage", "Recognize Weapon Quality"] }
      - "Physical"
      - { name: "Pilot", except: ["Military: Jet Fighters", "Military: Tanks & APCs", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats", "Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Air Assault Armor", "Flight System Combat"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise", "Palming", "Concealment"], bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
    note: "Cowboy, Electrical and Mechanical: none. Horsemanship: General and Exotic Animals only. Piloting: any except military vehicles, power armor and robots."
  secondary_skills:
    count: 3
    schedule:
      - { level: 3, count: 3 }
      - { level: 6, count: 3 }
      - { level: 10, count: 3 }
      - { level: 14, count: 3 }
    note: "Three skills from the Secondary Skills List on page 300 of Rifts Ultimate Edition at levels 1, 3, 6, 10 and 14. Base skill level; no bonuses other than a high I.Q."
psionics:
  type: "master"
  isp_base: "4d4x10 + M.E. attribute number, +15 per additional level of experience"
  powers: ["Attack Disease", "Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear", "Transfer I.S.P.", "Astral Projection", "Clairvoyance", "Commune with Animals", "Commune with Spirit", "Dispel Spirits", "Empathy", "Induce Nightmare", "Insert Memory", "Intuitive Combat", "Invisible Haze", "Machine Ghost", "Mask I.S.P. & Psionics", "Mask P.P.E.", "Meditation", "Mental Illusion", "Object Read (Psychometry)", "Presence Sense", "Read Dimensional Portal", "Remote Viewing", "See Aura", "See The Invisible", "Sense Dimensional Anomaly", "Sense Evil", "Sense Magic", "Sense Time", "Sixth Sense", "Speed Reading", "Telepathy", "Total Recall", "Levitation"]
  powers_starting: 2
  powers_starting_groups:
    - { count: 1, categories: ["Physical"] }
    - { count: 1, categories: ["Super"] }
  categories_allowed: ["Physical", "Super"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Physical"] }
    - { level: 2, count: 1, categories: ["Super"] }
    - { level: 3, count: 1, categories: ["Physical"] }
    - { level: 3, count: 1, categories: ["Super"] }
    - { level: 4, count: 1, categories: ["Physical"] }
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 5, count: 1, categories: ["Physical"] }
    - { level: 5, count: 1, categories: ["Super"] }
    - { level: 6, count: 1, categories: ["Physical"] }
    - { level: 6, count: 1, categories: ["Super"] }
    - { level: 7, count: 1, categories: ["Physical"] }
    - { level: 7, count: 1, categories: ["Super"] }
    - { level: 8, count: 1, categories: ["Physical"] }
    - { level: 8, count: 1, categories: ["Super"] }
    - { level: 9, count: 1, categories: ["Physical"] }
    - { level: 9, count: 1, categories: ["Super"] }
    - { level: 10, count: 1, categories: ["Physical"] }
    - { level: 10, count: 1, categories: ["Super"] }
    - { level: 11, count: 1, categories: ["Physical"] }
    - { level: 11, count: 1, categories: ["Super"] }
    - { level: 12, count: 1, categories: ["Physical"] }
    - { level: 12, count: 1, categories: ["Super"] }
    - { level: 13, count: 1, categories: ["Physical"] }
    - { level: 13, count: 1, categories: ["Super"] }
    - { level: 14, count: 1, categories: ["Physical"] }
    - { level: 14, count: 1, categories: ["Super"] }
    - { level: 15, count: 1, categories: ["Physical"] }
    - { level: 15, count: 1, categories: ["Super"] }
magic:
  type: "spell"
  spells: ["Blinding Flash", "Cloud of Smoke", "Death Trance", "Decipher Magic", "Globe of Daylight", "Lantern Light", "See Aura", "See the Invisible", "Sense Evil", "Sense Magic", "Thunderclap", "Float in Air", "Fly as the Eagle", "Befuddle", "Breathe Without Air", "Magic Pigeon", "Tongues", "Life Source", "Restore Limb", "Mystic Portal"]
  spells_starting: 0
  spell_levels_allowed: [1]
  spells_schedule:
    - { level: 2, count: 5, spell_levels: [1, 2, 3], note: "Roll 1D4+1 and take only that many; 5 is the most the roll gives." }
    - { level: 3, count: 5, spell_levels: [1, 2, 3, 4], note: "Roll 1D4+1 and take only that many." }
    - { level: 4, count: 5, spell_levels: [1, 2, 3, 4, 5], note: "Roll 1D4+1 and take only that many." }
    - { level: 5, count: 5, spell_levels: [1, 2, 3, 4, 5, 6], note: "Roll 1D4+1 and take only that many." }
    - { level: 6, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7], note: "Roll 1D4+1 and take only that many." }
    - { level: 7, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8], note: "Roll 1D4+1 and take only that many." }
    - { level: 8, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9], note: "Roll 1D4+1 and take only that many." }
    - { level: 9, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], note: "Roll 1D4+1 and take only that many." }
    - { level: 10, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], note: "Roll 1D4+1 and take only that many." }
    - { level: 11, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], note: "Roll 1D4+1 and take only that many." }
    - { level: 12, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], note: "Roll 1D4+1 and take only that many." }
    - { level: 13, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], note: "Roll 1D4+1 and take only that many." }
    - { level: 14, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], note: "Roll 1D4+1 and take only that many." }
    - { level: 15, count: 5, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], note: "Roll 1D4+1 and take only that many." }
natural_abilities:
  - { name: "Mega-Damage Being on Rifts Earth", description: "On Rifts Earth the Yhabbayar has supernatural P.S. and P.E. and is a mega-damage creature. On its home world, the Astral Plane and other low-magic places it is a Hit Point / S.D.C. being instead (see GM Notes)." }
  - { name: "Psychic Third Eye", description: "Every Yhabbayar has an opened Third Eye: heightened psychic sensitivity and awareness." }
  - { name: "Long-Lived", description: "Average life span 6D6x10 +140 years. Physically mature by age 17, then spends the next 1D4x10+20 years meditating and finding self-awareness before leaving Psyscape; most look 50-60 whatever their age." }
special_abilities:
  - name: "Bubble Magic"
    description: "Racial ability, cannot be taught. Seated cross-legged in a meditative trance, the Bubblemaker floats 1-3 ft (0.3-0.9 m) up with his bowl of soap solution and has the equivalent of Psychic Omni-Sight (500 ft / 152 m radius) without leaving his body. One magic bubble per melee action (up to a dozen ordinary ones for fun). He pays the normal I.S.P. or P.P.E. of a psi-power or spell he actually knows and places it in the bubble; it is released when the bubble touches its target. Range: 500 ft (152 m). Duration: 30 seconds per level, or until it pops. Bubble M.D.C.: 2 (an ordinary bubble 2 S.D.C.). Silent and hard to see: targets are -1 to strike, parry and dodge; a bubble dropping from above has an 80% prowl and is -3 to dodge; parrying it just pops it. A psi-power given to another person through a bubble lasts one third its normal first-level duration. Mind Bleeder powers can never be used. Extra I.S.P. costs are listed in GM Notes."
  - name: "Sense Supernatural Evil"
    description: "Automatic, no I.S.P. cost: feels the presence of supernatural evil like an icy chill, and whether it is near or far and great or lesser, but not its exact location. Range 300 ft (91 m) +50 ft (15.2 m) per additional level. Also senses possession and recognizes magic enchantment: 70% +3% per additional level."
  - name: "Opening Oneself to the Supernatural"
    description: "As the Mystic: can act as a medium through which spirits and entities speak, and is receptive to all telepathic and empathic communication (+10% to receive a Ley Line Transmission while open). In the open-state trance he cannot speak or act, is invisible to psionic probes and seems to melt into his surroundings: 50% +5% per additional level to go unseen. While in the trance he is +8 to save vs psionic attack and +4 vs magic."
  - name: "Sense Life"
    description: "No I.S.P. cost. As the Grey Seer: senses pregnancy within 72 hours of conception and the child''s sex (or litter size), and whether a person is a healer or defender of life or a destroyer of it. Senses supernatural good within 100 ft (30.5 m) +25 ft (7.6 m) per level, without location or numbers, and recognizes great good in a person through close contact."
  - name: "Master Psionic"
    description: "Needs a 10 or higher to save vs psionic attack. Knows all Healing and Sensitive powers plus Levitation, and selects one more power each from the Physical and the Super-Psionic categories at every level of experience. Mind Bleeder powers are not available."
  - name: "Intuitive Spell Knowledge"
    description: "As a Mystic, after eight days of fasting and meditation he knows all level one spells plus Float (in Air), Fly as the Eagle, Befuddle, Breathe Without Air, Magic Pigeon, Tongues, Life Source, Restore Limb and Mystic Portal; these never change. Each later level he meditates and gains 1D4+1 spells from any level up to one above his own. He can never be taught or buy spells, but may use Techno-Wizard devices and the occasional scroll. Draws P.P.E. from ley lines, nexus points and people like a Line Walker."
level_progression:
  - { level: 2, grants: ["1D4+1 spells from levels 1-3", "1 Physical and 1 Super psi-power"] }
  - { level: 3, grants: ["+1 initiative", "+1 Perception", "1D4+1 spells from levels 1-4", "1 Physical and 1 Super psi-power"] }
restrictions:
  - "NPC-headed: the stat block is ''The Yhabbayar - Optional Player Character and NPC''. A player character is a young Yhabbayar starting at level one."
  - "Hand to Hand: Martial Arts cannot be changed."
  - "No cybernetics or physical augmentation (it interferes with psionics and magic); a bio-system prosthetic only if necessary."
  - "Cannot learn, be taught or purchase spells beyond its intuitive ones."
  - "Mind Bleeder powers are never available, as powers or in bubbles."
  - "Vulnerabilities: small size and appearance can sometimes cause a problem, and many people underestimate them. Needs the simple, physical components (soap solution and a hoop) to make bubbles."
  - "Also carries, with no catalog row and so not given as items: one weapon for each W.P. with 1D4+1 E-Clips or ammo-clips for each weapon that needs one, a shoulder bag, a waterskin of bubble solution, 1D6 rings for blowing bubbles, a comb and other personal items; many also have a digital camera with a variety of lenses."
side_effects: "Money means little to them: a Yhabbayar gives away half of whatever money he or she comes into."
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "marker-pen-1", qty: 2 }
  - { item_id: "pencil", qty: 2 }
  - { item_id: "eraser", qty: 1 }
  - { item_id: "sketch-pad", qty: 1 }
extraction_notes: |
  - UPDATED TO D-BEES: this class followed Rifts World Book 12: Psyscape printed 130-135
    until this update; it now follows the newer printing, Rifts World Book 30: D-Bees of
    North America printed 217-220 (stat block 219-220), which says the race originally
    appeared in Psyscape (ruling of 2026-10-04: the newest printing that states a figure
    wins and the older figure is kept here). Both entries were read off page renders
    (D-Bees cache p218-p221 and p026; Psyscape cache p133-p136 and p158). The bullets
    after the D-BEES ones are the Psyscape record; where a D-BEES bullet names the same
    field, the D-BEES bullet is what is stored.
  - D-BEES ATTRIBUTES: P.B. 2D6+2 (Psyscape printed 134 gave 2D6). Every other die is the
    same in both. Average life span 6D6x10 +140 years (Psyscape printed 134 gave 300 to
    500 Earth years).
  - D-BEES BONUSES (printed 220): adds +1 to Perception Rolls at levels 1, 3, 5, 7, 9, 11,
    13 and 15 (stored as combat.perception 1 plus at_level, level 15 perception only),
    and "+2 to save vs Horror Factor and illusions" (the illusions half stored as
    saves.other). Psyscape printed 134 gave neither. Initiative, possession, poison and
    disease are the same in both.
  - D-BEES SKILLS (printed 219, headed "Bubblemaker R.C.C. Skills"): "Language &
    Literacy: Native Tongue: American" with no percentage is stored as Language: Native
    Tongue (catalog 98) and Literacy: Native Language (catalog 40, +5 per level);
    Psyscape printed 134 gave "Speaks and is literate in American (+25%)", which was
    stored as Language: Other +25 and Literacy: Other +25. "Language: Other: Two of
    choice (+20%)" is two pick-one groups (Psyscape printed 134 gave one language of
    choice at +20%). Added: Performance 30+15, Public Speaking 30+15, Philosophy 30+20;
    Psyscape prints none of the three. The energy W.P. is "One Modern Energy Weapon of
    choice". Every other skill and bonus is the same in both.
  - D-BEES RELATED SKILLS (printed 219-220): prints "Horsemanship: General and Exotic
    Animals only", stored as an only-list; Psyscape printed 134 has no Horsemanship line
    and the category was granted whole. Six picks, +1 at 3, 6, 9, 12 and 15, and every
    other line are the same in both.
  - D-BEES SECONDARY SKILLS (printed 220): "Select three skills from the Secondary
    Skills List found on page 300 of Rifts Ultimate Edition, at levels 1, 3, 6, 10 and
    14", read as three at each of those levels (count 3, then 3 at 3, 6, 10 and 14) and
    drawn from that list rather than from the related list, so the category list is no
    longer stored. Psyscape printed 134 gave three from the related list above,
    excluding the lines marked None, plus one at levels 3, 6, 9 and 12.
  - D-BEES PSIONICS (printed 220): "Select one additional psychic ability each from the
    Physical and Super-Psionic categories each level of experience" - one Physical AND
    one Super at every level, level 1 included (powers_starting 2 in two groups, two
    schedule entries a level). Psyscape printed 133 gave "one additional psychic
    ability from the Physical and Super-Psionic categories each level", stored as one
    pick from either. I.S.P., the Healing/Sensitive/Levitation grant, the Mind Bleeder
    bar and the save of 10 are the same in both.
  - D-BEES MAGIC, P.P.E., M.D.C., Hit Points/S.D.C., money: same figures in both books.
  - D-BEES EXPERIENCE (printed 220): "Use the same Experience Table as the Amorph on page
    25 of this book". The Amorph table on D-Bees printed 25 is figure for figure the
    "Amorph, Psi-Slayer, Yhabbayar Bubblemaker" column of Psyscape printed 157, so the
    stored xp_table is unchanged. NPC level is 1D6+4 (Psyscape gave 4-10th).
  - D-BEES EQUIPMENT (printed 220): the list is restated. Added and stored: portable
    language translator, pocket mirror. Added and kept as a restrictions line because
    no catalog row fits: shoulder bag, waterskin with bubble solution, 1D6 rings for
    blowing bubbles, a comb and other personal items, one weapon for each W.P. with
    1D4+1 E-Clips/ammo-clips each. Left out by D-Bees and so removed: the gas mask
    (Psyscape printed 135 gave "air filter and gas mask"), and the survival knife and
    hand axe (Psyscape printed 135 gave "Weapons: Two reflect his W.P. skills plus a
    survival knife, and hand axe"). The camera many carry is now digital (Psyscape gave
    35 mm). Armor line now reads "seldom wear medium or heavy armor" (Psyscape: heavy).
  - D-BEES BUBBLE MAGIC (printed 217-219): costs and features are the same as Psyscape
    except the Extend Duration example - D-Bees gives a 3rd level bubble 90 seconds,
    180 for 6 I.S.P. and 270 for 12 (Psyscape printed 132 gave 360 for 12). D-Bees does
    not restate Psyscape''s Limitations block (printed 133: duration, M.D.C. two, cost,
    race only, Mind Bleeder powers not available in bubbles, limited spell knowledge),
    nor the details of Sense Supernatural Evil''s icy chill and of Opening Oneself to the
    Supernatural (it prints "Same as the Mystic O.C.C."); those are kept from Psyscape.
  - D-BEES NEW LINES (printed 220): Vulnerabilities (a restrictions line), Slave Market
    Value 2D6x100,000 credits and Rivals and Enemies (GM Notes), Available O.C.C.s None
    (already so), Horror Factor not applicable. The cybernetics line drops Psyscape''s
    reason ("because it interferes with psionics and magic"); the reason is kept.
  - NPC-HEADED: the stat block (printed 134) is headed "The Yhabbayar NPC & Optional Player
    Character", with a Player Character Note saying a player character is a young Yhabbayar.
    No G.M.-permission wording; treated as playable, flagged in GM Notes and restrictions.
  - PAGES: heading printed 130 (cache p131), lore 130; printed 131 (cache p132) is a
    full-page illustration with no text (render checked); Bubble Magic printed 132-133;
    Special Powers 133-134; stat block 134-135. The Allies and history Note sit in the
    right column of printed 135 above the Zaayr Crystal Dragon heading (render checked);
    the cache interleaves them into the Zaayr text. No Enemies line is printed. Printed
    136 (cache p137) is art only.
  - DIGIT FAULTS: 4D4xlO, 2D4xlO, 2D4xlOO, 3D4xlOO read as 4D4x10, 2D4x10, 2D4x100 and
    3D4x100 (money confirmed on the printed 135 render: "2D4x100", "3D4x100").
  - xp_table: the 15 lower bounds given by the batch brief (read off printed 157).
  - POOLS: M.D.C. on Rifts Earth P.E. + 4D6, +1D6 per level, stored as mdc_base, so
    men_of_arms: false is the race default only (heading "Yhabbayar R.C.C."). The book
    also prints Hit Points P.E. + 3D6 (+1D6/level) and S.D.C. 5D6 for low-magic worlds;
    not stored as pools (a class carries one pool set) - GM Notes.
  - PSIONICS: "Master Psionic" (ability 5), I.S.P. 4D4x10 + M.E., +15 per level; save 10+
    (ability 6) follows from type master. "All healing and sensitive powers, plus
    levitation" is granted by name: every Healing and Sensitive catalog row with no
    system tag or a rifts tag (46 rows) plus Levitation. JUDGEMENT CALL - rows tagged
    heroes-unlimited or nightbane (Calm Rage, Wound Transfer, Induce Pain, Divination,
    Mediumship/Clairsentience, Mimic Skills, Precognition, Sensory Link) are left out.
    "Select one additional psychic ability from the Physical and Super-Psionic categories
    each level of experience" is read as one pick per level, including level 1
    (powers_starting 1) - JUDGEMENT CALL; Mind Bleeder is excluded by the category gate.
  - MAGIC: "All level one spells" is granted as the catalog''s eleven general Rifts level
    one invocations (Blinding Flash, Cloud of Smoke, Death Trance, Decipher Magic, Globe
    of Daylight, Lantern Light, See Aura, See the Invisible, Sense Evil, Sense Magic,
    Thunderclap). JUDGEMENT CALL - Increase Weight and Ventriloquism (palladium-fantasy)
    and Sense Nightbane / Sense P.P.E. (nightbane) are left out. "Float" is the catalog
    row Float in Air. 1D4+1 spells per later level from levels up to one above his own
    is a per-level schedule of 5 (the roll''s maximum) with a note to take only what was
    rolled, each capped at levels 1 to L+1 (the dragonmage precedent).
  - BUBBLE MAGIC is a class ability, not spells: prose in special_abilities and GM Notes,
    no spell rows. Its I.S.P. surcharge table is in GM Notes.
  - BONUSES (ability 10): +1 initiative at levels 1,3,5,7,9,11,13 (base + at_level); +2
    vs Horror Factor, +5 vs possession, +1 vs poison (toxins_poisons) and disease.
  - SKILLS: printed as "O.C.C. Skills" on an R.C.C.; the race carries its own full
    package and the book names no O.C.C., so no occ_restrictions. American is not a
    catalog language: stored as Language: Other +25 and Literacy: Other +25 with a note.
    Basic & Advanced Math +25 is Mathematics: Basic and Mathematics: Advanced 45+25.
    Art 35+15, Lore: Demons & Monsters 25+10, Wilderness Survival 30+10, Land Navigation
    36+10, Climbing 40+10, Swimming 50+10. Lore: one of choice enumerates the Rifts lore
    rows (as nega-psychic). W.P. Ancient and Energy Weapon are named lists. Related
    skills: six, +1 at 3,6,9,12,15; Horsemanship granted because Piloting is Any-except
    (the Amazon precedent); the Pilot exclusion names the Military:, Robot and power
    armor rows. Rogue +5% applies to the three allowed. Secondary: three, +1 at 3,6,9,12,
    from the same categories without bonuses (Espionage/Military/Rogue only-lists not
    repeated on the secondary list - JUDGEMENT CALL, the secondary block is category-only).
  - EQUIPMENT: "several pens/markers and/or pencils, eraser" is two marker pens, two
    pencils and an eraser (the eraser row arrived with ~020); "sketch book" is sketch-pad; the 35 mm camera "many" carry is
    prose, not stored. Weapons: two matching the W.P.s are prose; survival knife and hand
    axe stored. Vehicle none. Money 2D4x100 credits stored; 3D4x100 in tradeable goods
    is prose.
  - NOT STORED: alignment (50% scrupulous, 26% principled, 20% unprincipled, 4% anarchist
    or other), size 4-5 ft, weight 90-120 lbs, average NPC level 4-10.
---

## Lore

The Yhabbayar are small, big-eared, gentle-featured D-bees who were swept to Rifts Earth by a ley line storm and found the psychic people of Psyscape within hours of arriving. Unable to return home, they made Psyscape their home, where some ten thousand live as honored philosophers and teachers who helped humans and D-bees open their Third Eye. They are part guru, part child and part warrior: endlessly curious, cheerful, fond of puns and harmless practical jokes, and always ready to help. They are best known as the Bubblemakers, who shape soap bubbles with their minds and can seal psionic powers and spells inside them.

**Alignments.** Almost always good: 50% scrupulous, 26% principled, 20% unprincipled, 4% anarchist or other; evil or selfish Yhabbayar are rare.

## GM Notes

NPC-headed: the book''s stat block is "The Yhabbayar - Optional Player Character and NPC". A player character is a young Yhabbayar, starting at level one.

**Low-magic worlds.** On its home world, the Astral Plane and anywhere magic is weak, the Yhabbayar is not a mega-damage being: Hit Points P.E. + 3D6 (+1D6 per level), S.D.C. 5D6, and its P.S. and P.E. are not supernatural.

**Bubble Magic, extra I.S.P. costs.** For bubbles holding psionics only (not spells): +2 if the bubble inflicts damage; +3 for healing powers; +5 to temporarily give another person a psionic power (not Super or Mind Bleeder); +10 to give to or inflict on another person one Super-Psionic power. Special features (any bubble, line of sight unless stated): Float in One Place +1 (hovering aerial mine); Special Program +2 (pops only on a specific person or type of person); Straight Arrow Strike +2 (-3 to dodge, parry futile); High Floater +2 (drops from above, -3 to dodge); Surprise Attack +4 (bobs innocently then hurls, -4 to dodge); Zig-Zag +4 (-3 for others to strike it); Seek Out +20 (finds a person or place the Bubblemaker knows well); Extend Duration +6 for each further stretch of the base 30 seconds per level (a 3rd level bubble lasts 90 seconds, 180 for 6 extra I.S.P., 270 for 12).

Reading bubbles: large elaborate bubbles usually hold illusion, dimensional or high-P.P.E. magic; small ones are usually attacks. A blue tint means a spell, clear or faintly rosy means psionics. Long-range energy attacks are the best way to pop one (no strike penalty, 2 M.D.C.). The Bubblemaker can also make empty bubbles that look dangerous, to bluff or distract. Yhabbayar never use a crippling or lethal bubble against someone who does not know what to expect.

**Allies.** The people of Psyscape and most champions of good; favorably disposed toward Cyber-Knights, Dog Boys and Psi-Stalkers, but they judge each person individually. Before 105 P.A. no Yhabbayar had been seen on Earth in nearly two hundred years; their reappearance that spring foreshadowed the return of Psyscape, a sign recognized by Erin Tarn and the Grey Seers.

**Slave Market Value.** 2D6x100,000 credits.

**Rivals and Enemies.** The forces of evil in all its forms: the Minions of Splugorth, vampires, all evil supernatural beings and evil men. They hate injustice, cruelty, slavery, genocide and tyranny.
',
       updated_at = datetime('now')
 WHERE class_id = 'yhabbayar'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.130-135') > 0
   AND length(markdown) = 22279;

-- == zenith-moon-warper ==
UPDATE imported_classes
   SET markdown = '---
id: zenith-moon-warper
men_of_arms: false
name: Zenith Moon Warper
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.221-223
category: rcc
tags: [stealth, shapeshifter]
attribute_dice:
  IQ: "1d6+10"
  ME: "1d6+12"
  MA: "1d6+20"
  PS: "2d6+12"
  PP: "2d6+12"
  PE: "2d6+12"
  PB: "3d6+8"
  Spd: "6d6+20"
mdc_base: "P.E. attribute number plus 6d6+12, +1d6 per level of experience"
ppe_base: "2d4x10 plus P.E. attribute number x2, +1d6+1 per level of experience"
starting_money: "2d6x1000"
horror_factor: 10
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]
psionics:
  type: "major"
  isp_base: "1d4x10 plus M.E. attribute number x3, +1d6+1 per level of experience"
  powers: ["Psionic Invisibility", "Deaden Pain", "Induce Sleep", "Empathy"]
  powers_starting: 2
  categories_allowed: ["Healing", "Physical", "Sensitive"]
magic:
  type: "spell"
  spells: ["Swap Places", "Teleport: Lesser", "Escape", "Tongues"]
  spells_starting: 0
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "Native tongue. D-Bees prints Language: Native Tongue: Gobblely with no percentage; 98% is the Psyscape figure." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One additional language of choice, typically American (+20%)." }
    - { name: "Appraise Goods", base: 45, per_level: 5, note: "+15%." }
    - { name: "Escape Artist", base: 45, per_level: 5, note: "+15%." }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%." }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%." }
    - { name: "Concealment", base: 30, per_level: 4, note: "+10%." }
    - { name: "Cardsharp", base: 34, per_level: 4, note: "+10%." }
    - { name: "Seduction", base: 40, per_level: 3, note: "+20%." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "Printed as (10%), read as +10%." }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P.: one Ancient of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. Energy Weapon of choice." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Hand to Hand: Expert (cannot be changed)." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", only: ["Find Contraband"], bonus: 5 }
      - { name: "Physical", except: ["Boxing"] }
      - "Pilot"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 10 }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 10 }
      - "Technical"
      - "Weapon Proficiencies"
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 12, count: 2 }
    note: "R.C.C. Related Skills: six at level one, plus two more at levels 3, 5, 8, 10 and 12. Horsemanship: General (+5%) and Exotic Animals only. Technical: any (+10% to Lore skills only). Cowboy, Electrical, Mechanical, Pilot Related and Wilderness: none."
  secondary_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 14, count: 1 }]
    note: "Three from the Secondary Skills List on page 300 of Rifts Ultimate Edition at level one, plus one more at levels 3, 6, 8, 10 and 14, at the base skill level; no bonuses other than a high I.Q."
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "black-clothing-covert", qty: 1 }
  - { item_id: "camouflage-fatigues", qty: 1 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 15 }
  - { item_id: "full-rappelling-equipment", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "e-clip", qty: "1d4+1" }
  - { item_id: "fake-identification", qty: "1d4+1" }
natural_abilities:
  - { name: "Supernatural P.S. and P.E.", description: "The P.S. and P.E. are supernatural and the creature is mega-damage. In S.D.C. environments it is a Hit Point and S.D.C. being instead: hit points P.E. plus 5D6 (+1D6 per level), S.D.C. 6D6 plus those from skills, and a natural A.R. of 10." }
  - { name: "Ambidextrous", description: "" }
  - { name: "Double-jointed", description: "" }
  - { name: "Nightvision", description: "1000 feet (305 m)." }
  - { name: "Swim", description: "60%." }
  - { name: "Climb", description: "80%/70%." }
  - { name: "Leap", description: "10 feet (3 m) high or across; 50% higher or farther with a running start." }
  - { name: "Bio-regeneration", description: "Regenerates 3D6 M.D.C. per hour." }
special_abilities:
  - name: "Innate Magic"
    description: "Casts Swap Places, Teleport: Lesser, Escape and Tongues as natural abilities. Each casting costs half the spell''s normal P.P.E.; the book prints the spells'' costs as 300, 15, 8 and 12."
  - name: "Shape Change"
    description: "Can take a completely human appearance at will, and take on different facial appearances and skin tones; in human or canine-headed form it is beautiful and seductive. Whenever the moon reaches its zenith in the sky, it is forced into its natural form for 1D4 hours."
  - name: "Powers of the Full Moon"
    description: "About six days a month, while the moon is full or nearly full: P.S., M.D.C. and I.S.P. increase by 20%, and it is +2 to save vs poison, drugs, possession and mind control, +2 on initiative, +1 to strike, +1 attack per melee round, and +2 to save vs Horror Factor. None of these are in the class''s standing bonuses."
restrictions:
  - "OPTIONAL PLAYER CHARACTER OR NPC. The book heads the stat block as an optional player character or NPC; player characters start at level one."
  - "Takes no O.C.C. The book gives the Zenith Moon Warper its own R.C.C. skills, related and secondary skills, equipment and money."
  - "Hand to Hand: Expert cannot be changed."
  - "Cybernetics: avoids them completely, favouring natural powers. Will consider bionic prosthetics or organs only if absolutely necessary, and then prefers bio-systems."
  - "Alignment: any, though most lean toward unprincipled (10%), anarchist (40%), aberrant (20%) and miscreant (10%)."
side_effects: "Anyone who learns the character''s true nature is likely to see him or her as untrustworthy and dangerous, and many people, the Coalition States included, fear and hate shape-changers and kill them on sight. Horror/Awe Factor 10 rises by +1 at levels 4, 8 and 12."
extraction_notes: |
  - UPDATED TO D-BEES: this class followed Rifts World Book 12: Psyscape
    printed 138-140 until it was brought up to Rifts World Book 30: D-Bees of
    North America printed 221-223 (cache p222-p224; ruling of 2026-10-04: the
    newest printing that states a figure wins, the older figure kept here).
    D-Bees printed 223 says the entry originally appeared in Psyscape. Both
    books were read off page renders. In Psyscape the lore and the numbered
    Special R.C.C. Abilities are on printed 138 and the stat block runs from
    printed 138 to 140 (cache p139-p141); printed 139 is a full-page
    illustration with no text.
  - M.A.: D-Bees printed 221 prints M.A. 1D6+20 and that is stored. Psyscape
    printed 138 gave M.A. 1D6+2 (printed "1D6+2 ," with a gap before the
    comma). Every other attribute die is the same in both books.
  - HEADING: D-Bees titles the stat block "Zenith Moon Warper - Optional
    Player Character or NPC" and says player characters start at level one.
    Psyscape printed 138 titled it "NPC Villain & Optional Player Character".
    NPCs are level 1D4+3 or as set by the Game Master (a population fact, not
    stored). D-Bees adds "Z-Warper" to the also-known-as names.
  - PLAYER NOTE AND ALIGNMENT: D-Bees prints "untrustworthy and dangerous" and
    that many people, the Coalition States included, kill shape-changers on
    sight; stored in side_effects. Psyscape printed 138 gave "an untrustworthy
    criminal" and added that evil characters are likely to clash with groups
    of predominantly good alignment, which D-Bees leaves out. Alignment in
    D-Bees: any, most lean toward Unprincipled (10%), Anarchist (40%),
    Aberrant (20%) and Miscreant (10%). Psyscape printed 138 gave anarchist
    (40%) and evil (30%).
  - xp_table: D-Bees printed 222 says to use the same experience table as the
    Lanotaur on printed 117 of that book. Read off the render, that table is
    the same fifteen bands as the "Zenith Moon Warper, Lanotaur Hunter" column
    on Psyscape printed 157, so the stored ladder is unchanged.
  - POOLS: men_of_arms false (a race). A mega-damage creature, so only
    mdc_base is stored (P.E. plus 6D6+12, +1D6 per level; the same in both
    books). The S.D.C.-environment figures (hit points P.E. plus 5D6, +1D6
    per level; S.D.C. 6D6) are prose in the Supernatural P.S. and P.E.
    natural ability rather than hit_points_base / sdc_base, which would have
    stacked on top of the M.D.C. D-Bees adds "plus those from skills" to the
    S.D.C. and a Natural A.R. of 10 for S.D.C. environments; Psyscape printed
    138 gave neither, and described the condition as the native world and
    other places where magic energies are considerably weaker.
  - I.S.P. and P.P.E. are the same in both books (D-Bees prints them under
    Psionic Powers and Magic Abilities, printed 222-223).
  - PSIONICS: Major Psychic. The book''s "Psychic Invisibility" is the catalog
    row "Psionic Invisibility" (a Super power from Psyscape printed 42);
    granted by name, so the Major tier gates nothing about it. Deaden Pain,
    Induce Sleep and Empathy match exactly. Plus two of choice from Healing,
    Physical or Sensitive (powers_starting 2). No powers with level are
    printed. D-Bees prints the I.S.P. costs beside the powers (10, 4, 4, 4).
    Psyscape printed 138 added "Needs a 12 or higher to save vs psionic
    attack" (the Major threshold, not a bonus); D-Bees does not restate it.
  - MAGIC: four spells as natural abilities at half P.P.E. cost. Granted by
    name with spells_starting 0. No key holds a cost multiplier, so the half
    cost is prose in the Innate Magic ability. D-Bees prints "Swap Places
    (300), Teleport: Lesser (15), Escape (8) and Tongues (12)"; Psyscape
    printed 138 gave "Teleport: Lesser (objects)" and no costs.
  - FULL MOON: the P.S./M.D.C./I.S.P. +20% and the full-moon combat and save
    bonuses are conditional, so they are prose in Powers of the Full Moon and
    not in bonuses. The same in both books. No standing combat or save
    bonuses are printed.
  - SHAPE CHANGE: D-Bees prints the heading as "Shapechange (special)" and
    adds that the character can take on different facial appearances and skin
    tones; Psyscape printed 138 headed it "Shape change (special)" and gave
    only the human appearance. The stored ability keeps its name.
  - HORROR FACTOR 10, +1 at levels 4, 8 and 12: horror_factor stores 10; the
    increases are prose in side_effects (no at_level key for it). The same in
    both books.
  - SKILLS: bases are catalog base plus the printed bonus. D-Bees adds
    Appraise Goods (+15%), which Psyscape did not print (catalog 30, stored
    45). D-Bees prints one language line, "Language: Native Tongue:
    Gobblely", with no percentage: stored as Language: Gobblely at 98, the
    Psyscape figure. Psyscape printed 138 gave "Speaks Gobbleley and Native
    Tongue at 98%", which had been stored as two rows (Language: Gobblely and
    Language: Native Tongue, both 98); the separate Native Tongue row is
    removed. "Language: Other: One of choice (typically American; +20%)" is a
    one-pick Language: Other at +20, since the catalog has no American row.
    "Land Navigation (10%)" is printed without a plus sign in both books and
    is read as +10%, like every line around it. W.P. One Ancient uses the
    batch''s ancient list; W.P. Energy Weapon is Energy Pistol or Energy
    Rifle. Hand to Hand: Expert "cannot be changed" is hand_to_hand costs {}.
    The other bonuses are the same in both books.
  - RELATED: six plus two at levels 3, 5, 8, 10 and 12 (D-Bees printed 222).
    Psyscape printed 138 gave levels 3, 5, 8 and 11. D-Bees prints
    "Horsemanship: General (+5%) and Exotic Animals only" and "Pilot: Any":
    stored as two Horsemanship entries, General at +5 and Exotic Animals
    with no bonus, and Pilot with no bonus. Psyscape printed 140 gave "Pilot:
    Any (+5% to horsemanship only)" and no Horsemanship line, which had been
    stored as the whole Horsemanship category at +5. D-Bees prints
    "Technical: Any (+10 to Lore skills only)": stored as Technical twice,
    the Lore: rows at +10 and the rest with no bonus. Psyscape printed 140
    gave "+10 to language and lore skills only"; the language half is gone
    in D-Bees. "Military: Find Contraband (+5%) only", "Science: Basic Math
    only (+10%)" (catalog Mathematics: Basic), "Medical: First Aid only",
    Physical except Boxing and Rogue (+5%) are the same in both books.
    Cowboy, Electrical, Mechanical, Pilot Related and Wilderness: none.
  - SECONDARY: D-Bees printed 222 gives three from the Secondary Skills List
    on page 300 of Rifts Ultimate Edition at level one, and one more at
    levels 3, 6, 8, 10 and 14; stored as count 3 with that schedule and no
    category list. Psyscape printed 140 gave four secondary skills from the
    related list with its any/only/none limits and no later picks.
  - TAKES NO O.C.C.: D-Bees prints "Available O.C.C.s: None, although the
    character may find employment as a thief, con artist, pickpocket, bounty
    hunter, spy or assassin". Psyscape printed a full R.C.C. package and
    named no occupation. There is no key for "no occupation", so it is a
    restriction line (amorph precedent).
  - EQUIPMENT: the list is the same in both books. "personalized, light
    M.D.C. body armor" is light-mdc-body-armor; "black jump suit" is
    black-clothing-covert (no jumpsuit row fits better); camouflage clothing
    is camouflage-fatigues; personal clothing is clothing; 300 feet of
    durable rope is 15 x rope-per-20-feet-6-m; "climbing & rappelling gear
    (harness, pitons, etc.)" is full-rappelling-equipment; 1D4+1 ammo clips
    are e-clip 1d4+1 (the clips serve the W.P. weapons, energy most likely).
    1D4+1 sets of fake identification are fake-identification 1d4+1 (the row
    arrived with ~020). D-Bees prints the Vibro-Knife as 1D6 M.D.
    NOT STORED: jewelry, personal
    items, and "one weapon for each W.P." (unspecified; pick by hand). They
    love magic and TW weapons but start with none. Psyscape printed 140 added
    "Vehicle: None to start, but prefer hover cycles and horses"; D-Bees
    restates the equipment and leaves the vehicle line out.
  - MONEY: 2D6x1000 credits stored; the same in both books. "Black Market
    items worth 1D6x1000 credits" is not coin and is not stored (GM Notes).
  - Not stored: size 5-6 ft, weight 120-150 lbs (D-Bees adds "lean and
    muscular"), habitat, allies and enemies, and the Slave Market Value of
    2D6x10,000 credits that D-Bees adds. Life span: D-Bees prints "Once
    believed to live 600+ years, the truth is the D-Bee lives for 5D6+70
    years", with full physical maturity by age 13; Psyscape printed 138 gave
    600+ Earth years. Psyscape printed 140 listed the race among Free
    Quebec''s dangerous D-bees marked for extermination; D-Bees restates the
    Rivals and Enemies entry without it.
---

# Zenith Moon Warper

## Lore

Zenith Moon Warpers are sleek, attractive canine-headed humanoids, often
mistaken for werewolves or Dog Boys, who can pass as fully human until the
moon at its zenith drags them back into their true shape for a few hours.
Around the full moon they grow stronger, tougher and more psychically
potent. They are hunters by instinct: the evil and anarchist ones prey on
people, while the rest hunt animals and fight their enemies fairly. Cunning
and manipulative, they treat almost everyone outside their own kind and
close friends as a mark, and make natural con artists, thieves, spies and
assassins. Also called Zenith Wolves or the Midnight People, they are found
mostly in the Magic Zone and the northeast of North America, especially
eastern Canada and the ''Burbs of Free Quebec.

## GM Notes

The book presents the Zenith Moon Warper as an optional player character or
NPC; player characters start at level one.

Starting gear also includes jewelry,
personal items, one weapon for each W.P. the character knows, and Black
Market items worth 1D6x1000 credits. Their thieving and spying services are
in demand, with pay varying by level, reputation, employer and situation.

Remember the moon: for 1D4 hours when it reaches its zenith the character is
forced into natural form, and for about six days a month the full-moon
bonuses apply. Many people, the Coalition States included, fear and hate
shape-changers and kill them on sight.
',
       updated_at = datetime('now')
 WHERE class_id = 'zenith-moon-warper'
   AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.138-140') > 0
   AND length(markdown) = 14317;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'all 7 classes cite D-Bees of North America' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'darkhound' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.54-58') > 0)
    OR (class_id = 'amorph' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.21-25') > 0)
    OR (class_id = 'demon-dragonmage' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.58-60') > 0)
    OR (class_id = 'lanotaur-hunter' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.115-117') > 0)
    OR (class_id = 'psi-goblin' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.164-166') > 0)
    OR (class_id = 'yhabbayar' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.217-220') > 0)
    OR (class_id = 'zenith-moon-warper' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.221-223') > 0);

SELECT 'none still carries its old source line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'darkhound' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.94-98') > 0)
    OR (class_id = 'amorph' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.117-120') > 0)
    OR (class_id = 'demon-dragonmage' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.120-123') > 0)
    OR (class_id = 'lanotaur-hunter' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.123-126') > 0)
    OR (class_id = 'psi-goblin' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.128-130') > 0)
    OR (class_id = 'yhabbayar' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.130-135') > 0)
    OR (class_id = 'zenith-moon-warper' AND instr(markdown, 'source_book: Rifts World Book 12: Psyscape p.138-140') > 0);

SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('darkhound', 'amorph', 'demon-dragonmage', 'lanotaur-hunter', 'psi-goblin', 'yhabbayar', 'zenith-moon-warper') AND instr(markdown, char(13)) > 0;

SELECT 'all 7 are still live and published' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE class_id IN ('darkhound', 'amorph', 'demon-dragonmage', 'lanotaur-hunter', 'psi-goblin', 'yhabbayar', 'zenith-moon-warper') AND deleted_at IS NULL AND status = 'published';

INSERT INTO data_script_runs (filename) VALUES ('~096-d-bees-updates-seven-psyscape-classes.sql');
