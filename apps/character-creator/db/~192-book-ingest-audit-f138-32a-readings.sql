-- Take BOOK-INGEST-AUDIT F138 on Nate's rulings: language, computer and Whittling bonuses on five Warlords and Japan classes
-- 5 classes, each replaced whole: travelling-story-teller, sohei-warrior-monk, mystic-ninja, ectohunter, huntsman-trapper.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~192-book-ingest-audit-f138-32a-readings.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Nate's rulings of 2026-10-14 on three readings ~189 stored (BOOK-INGEST-AUDIT F138):
-- - Language skills +N% reaches every Language: and Literacy: row in whichever
--   category the catalog files it, and not Language Dialects. Technical's entry
--   takes the prefixes with the colon; Communications gets a scoped entry where
--   the class already grants Communications (not the Sohei, granted none).
--   Language: All (magical) is left out: the catalog files it as an innate
--   ability, not a learned language.
-- - The Ectohunter's computer bonus reaches every Computer row in any category
--   it may already take: Technical and Electrical. Computer Hacking is Rogue,
--   which the book limits to Streetwise, so it gets no entry.
-- - The Huntsman/Trapper's Whittling entry is dropped; Technical's +10 covers it
--   and the printed +15% is prose.
-- No class's admitted skill set changes: every new entry sits on a category the
-- class already grants whole.

-- == travelling-story-teller ==
UPDATE imported_classes
   SET markdown = '---
id: travelling-story-teller
name: Travelling Story Teller
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.69-71
category: occ
tags: [scholar]
occ_group: optional
men_of_arms: false
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_requirements: { IQ: 8, MA: 10, PE: 10 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "3d4x20"
bonuses:
  saves: { possession: 1, toxins_poisons: 1, disease: 1, horror_factor: 2 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { name: "Language: Euro", base: 70, per_level: 5, note: "Speaks Euro (+20%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)." }
    - { name: "Literacy: Russian", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Literacy: Other"], bonus: 10, note: "Literacy: one of choice (+10%)." }
    - { name: "Lore: History of Russia", base: 50, per_level: 5, note: "Lore: all those applicable to Europe and Asia (+20%): history." }
    - { name: "Lore: Cattle & Animals", base: 50, per_level: 5, note: "Lore: all those applicable to Europe and Asia (+20%): animal lore." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: all those applicable to Europe and Asia (+20%): demon and monster lore." }
    - { name: "Lore: Magic", base: 45, per_level: 5, note: "Lore: all those applicable to Europe and Asia (+20%): magic lore." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 45, per_level: 5, note: "Lore: all those applicable to Europe and Asia (+20%): faerie lore." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 5, note: "Pilot: one of choice (+5%)." }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "Identify Plants & Fruits (+15%)." }
    - { name: "Animal Husbandry", base: 45, per_level: 5, note: "+10%" }
    - { name: "Brewing", base: 40, per_level: 5, note: "+15%" }
    - { name: "Cook", base: 50, per_level: 5, note: "+15%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "No others are available." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 15 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Choose four other skills at level one and two additional at levels 3, 6, 9 and 12. Communications: any (+5%). Domestic: any (+10%). Electrical: none. Espionage: none. Mechanical: none. Medical: none, other than the O.C.C. skills. Military: none. Physical: any, except Boxing, Gymnastics and Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft (horsemanship is filed in its own category here). Pilot Related: any. Rogue: none, other than Streetwise. Science: any (+10%). Technical: any (+10%; +15% to language skills). W.P.: any. Wilderness: any (+5%)."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Five secondary skills from the list at level one and two additional at levels 2, 4, 6, 9 and 12, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1, note: "Light suit of M.D.C. body armor." }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says a language translator." }
  - { item_id: "marker", qty: "2d4" }
  - { item_id: "winter-survival-kit", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1, note: "10 feet (3 m) of thin nylon cord, 600 lb (270 kg) test strength." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none, although the majority (80%) are human."
  - "Attribute requirements: I.Q. 8, M.A. 10 and P.E. 10 or higher."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Basic only; no others are available."
  - "Cybernetics: none to start, and usually avoids them. A Story Teller might consider one or two minor implants, and will use cybernetics as prosthetics and organ replacements if needed."
  - "Vehicle: none to start; most Story Tellers like to walk, but eventually acquire a horse or small vehicle."
extraction_notes: "WB17 Warlords of Russia printed 69-71 (cache p070-p072, cache page = printed folio + 1), read off the text layer. Heading Travelling Story Teller O.C.C. on printed 69, where the text layer interleaves its opening with the end of the Huntsman-Trapper (cache p070 lines 57-80 belong to the Huntsman); the stat block headed The Russian Story Teller O.C.C. starts on printed 69 and the entry ends with its Vehicle, Secret Resources, Money and Cybernetics lines at the top of printed 71, past the page break. || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the ladder naming the Travelling Story Teller on the Experience Tables, printed 6, read off a render. || BONUSES: +1 vs possession, +1 vs poison and disease (stored as toxins_poisons 1 and disease 1) and +2 vs Horror Factor, all flat. || LORE: the book prints Lore: all those applicable to Europe and Asia, including history, animal, demon, monster, magic and faerie lore (+20%). Stored as the five the line names: Lore: History of Russia, Lore: Cattle & Animals (a reading for animal lore; it is the only animal lore row, filed under Cowboy), Lore: Demons & Monsters, Lore: Magic, Lore: Faeries & Creatures of Magic, each at catalog base +20. Other lores a GM may judge applicable (D-Bee, Vampires, Religion, Psychics & Psionics) are NOT stored; the line says including, so the five are not a closed list. || SKILL READINGS: Speaks Euro and two other languages of choice (+20%) is Language: Euro at 70 plus two Language: Other picks at +20; Literacy: one of choice is one Literacy: Other pick at +10; Identify Plants & Fruits is Identify Plants & Fruit. Technical +15% to language skills reaches every Language: and Literacy: row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): a second Technical entry holds the Language: and Literacy: rows by prefix at +15 beside the flat +10 for the rest of Technical, and a second Communications entry holds the Literacy: rows and Language: Dolphin/Whale at +15 beside the flat +5. Language: All (magical) is left at Communications'' +5, because the catalog files it as an innate ability and not a learned language. Medical: none, other than those above, is stored as no Medical category. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft; Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Story Teller eventually acquires a horse. Hand to Hand: Basic, no others available, is costs: {}. || MONEY: 3D4x20 credits, as printed. || EQUIPMENT not stored as rows: one M.D. weapon of choice; butcher''s knife, meat cleaver, cooking utensils, frying pan, small pot, small kettle, bowl and grinder, a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row and are in GM Notes. The cloak or long coat, bedroll, note pad and dozen pencils have rows now (cape-or-cloak-long, bedroll-rifts, note-pad, pencil); the class does not list them and they stay in GM Notes too. The book attaches the 600 lb test strength to the 10 feet of thin nylon cord here. || NOT STORED: Secret Resources (regard and influence) and the neutrality that lets a Muzhik cross between Warlords'' Spheres of Influence without fees or tribute are in GM Notes. The body text on printed 69 says they are well versed in medicine and practical skills; no numbers beyond the skill list."
---

## Lore

The Travelling Story Teller, the Muzhik, is a wandering wise man: part
entertainer, part teacher, part healer. The tales are history lessons and
moral instruction as often as they are amusement, and the teller arrives
carrying news and rumor that isolated farms and villages badly want.

They pitch in with the work, tend the sick, and are asked to settle disputes
and to speak for a community to bandits, rival villages, monsters or a
Warlord''s officers. In superstitious country they are also the ones asked to
deal with a ghost, a demon or troublesome faerie folk. Because they respect
local law and take no side, the Warlords treat them as neutral and let them
cross between Spheres of Influence unmolested.

They are no great fighters but love adventure, and their range of lore,
medicine and wilderness knowledge makes them welcome among knights and
mercenaries. They treat D-Bees and creatures of magic as equals, which
unsettles the powers that be more than any speech would.

## GM Notes

Starting kit beyond what the sheet lists: one M.D. weapon of choice, butcher''s
knife, meat cleaver, cooking utensils, frying pan, small pot, small kettle,
bowl and grinder, a box of 100 large resealable plastic bags, cloak or long
coat, bedroll, belt, boots, note pad, a dozen pencils and a handful of
personal items. They start with no magic items, potions or artifacts, though
many acquire a handful over time.

The Lore grant is every lore applicable to Europe and Asia at +20%; the sheet
carries history, animal, demon and monster, magic and faerie lore. Add others
you judge applicable at the same bonus.

Secret resources: none as such, but Story Tellers are highly regarded,
especially by peasants and D-Bees, and favorably by the Mystic Kuznya,
Mega-Horses and good practitioners of magic; most Huntsmen and Bogatyrs
respect them. Muzhiks are not charged fees, fines or tribute unless the
situation is desperate or they have openly broken their neutrality.
',
       updated_at = datetime('now')
 WHERE class_id = 'travelling-story-teller'
   AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 15 }') > 0
   AND length(markdown) = 13461;

-- == sohei-warrior-monk ==
UPDATE imported_classes
   SET markdown = '---
id: sohei-warrior-monk
occ_group: men-of-arms
men_of_arms: true
name: Sohei Warrior Monk
system: rifts
source_book: Rifts World Book 8: Japan p.58-60
category: occ
tags: [combat, divine]
xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 325501, 400501]
attribute_requirements: { PP: 11, PE: 11 }
ppe_base: "P.E. x3 + 1d6 per level"
starting_money: "3d4x10"
bonuses:
  saves: { possession: 3 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { teng_jutsu: 3 } }
  occ_skills:
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Calligraphy", base: 45, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Japanese Mythology", base: 45, per_level: 5, note: "+15%" }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The book prints Literacy: Japanese at 98%; the catalog has no Japanese literacy row." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints Language: Japanese at 98%; the catalog has no Japanese language row." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two languages of choice (+15% each)." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10% for a nun; the monk variant restates it at +20%." }
    - { name: "W.P. Staff", base: 0, per_level: 0, note: "In addition to the jodo abilities and bonuses." }
    - { name: "Hand to Hand: Jujitsu", base: 0, per_level: 0, note: "Can be changed to Teng-jutsu at the cost of three other skill selections; no other combat alternative is allowed." }
    - { name: "Begging", base: 20, per_level: 3, note: "Temple skill; the book prints 20% +3% per level for the sohei." }
    - { name: "Fasting", base: 40, per_level: 3, note: "Temple skill." }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Magic", "Poetry (Haiku)", "Go", "Gardening"], bonus: 15, note: "Oriental Philosophies: one of demon and monster lore, magic lore, haiku poetry, go or (Zen) gardening, +15%." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise"], bonus: 8 }
      - { name: "Rogue", only: ["Concealment"], bonus: 6 }
      - { name: "Science", bonus: 5 }
      - "Technical"
      - { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - { name: "Weapon Proficiencies", only: ["W.P. Blunt", "W.P. Knife", "W.P. Forked"] }
      - { name: "Wilderness", bonus: 5 }
    note: "Communications, Electrical, Espionage, Mechanical, Military, Pilot and Pilot Related: none (not even horsemanship; monks walk or ride in a cart). Rogue: Streetwise (+8%) and Concealment (+6%) only. Technical: any, +10% to language skills only."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Domestic"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise", "Concealment"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", only: ["W.P. Blunt", "W.P. Knife", "W.P. Forked"] }
      - "Wilderness"
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
variants:
  - id: monk
    name: "Sohei Warrior Monk"
    skills_additional:
      occ_skills:
        - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
        - { name: "Lore: Magic", base: 35, per_level: 5, note: "+10%; the book prints Magic Lore." }
        - { name: "W.P. Spear", base: 0, per_level: 0 }
    skill_overrides:
      - { name: "Mathematics: Basic", base: 65, per_level: 5 }
  - id: nun
    name: "Female Sohei (Warrior Nun)"
    skills_additional:
      occ_skills:
        - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
        - { name: "Sewing", base: 50, per_level: 5, note: "+10%; the book prints Sew." }
        - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
        - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
equipment_starting:
  - { item_id: "millennium-leaf-body-armor", qty: 1, note: "Millennium Tree leaf armor, 60 M.D.C., worn under the robes; not an environmental suit." }
  - { item_id: "sohei-staff-of-defense", qty: 1, note: "Most sohei (90%) are given this Millennium Tree staff; other magic staves or spears may be used instead." }
  - { item_id: "naginata-yari-rifts", qty: 1, note: "The book prints naginata spear." }
  - { item_id: "knife", qty: 1 }
  - { item_id: "robe", qty: 4, note: "A pair of white robes and a pair of light brown robes." }
  - { item_id: "sandals", qty: 1, note: "Sandals or tabi." }
  - { item_id: "rope", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "water-skin-1-gallon", qty: 1, note: "The book prints a large water skin." }
  - { item_id: "food-rations", qty: 1, note: "The book prints 4D4 days of rations." }
special_abilities:
  - name: "Jodo, the Way of the Staff"
    description: "A staff (and spear) martial art first developed against sword-bearing samurai; the monks have also earned the right to carry spears and polearms. Jodo Strike: a deliberate thrust to the side of the head with the staff point or spear butt, announced before the roll. On a strike roll of 18 or higher (bonuses included) it does an extra 1D6 damage, the victim loses initiative and one melee action, and has a 01-50% chance to drop one held weapon (victim''s choice if paired). A hit under 18 does normal damage only. Jodo bonuses: one extra attack per melee round when using a staff or spear of any kind, and +1 to parry in addition to jujitsu and attribute bonuses."
  - name: "Parry Arrows with Staff or Spear"
    description: "Can parry arrows, darts and thrown objects at -2 and gunfire at -6, against one opponent''s projectiles at a time. The penalty improves by +2 at level three and by +1 at levels 4, 6, 9, 12 and 15."
  - name: "Chi M.D. Death Blow"
    description: "Same as the samurai''s: against supernatural beings and creatures of magic only, a punch, kick, staff or spear strike does double normal damage plus P.S. bonus as mega-damage, and the victim cannot bio-regenerate that injury for 1D4 hours. Counts as two melee actions; must be used with a pure spirit, never in anger, fear or revenge; useless against machines, ordinary humans, guns and bows. Draws on the character''s P.P.E. and counts as a magical attack."
  - name: "Mystic Martial Arts Powers"
    description: "One body hardening exercise at each of levels 1, 5 and 9, and one zenjoriki power at level 14 (printed 59), chosen from the groups below when the level is reached. Each body hardening exercise also lets the character spend 5 P.P.E. (unless stated otherwise) to turn his S.D.C., not hit points, into M.D.C. for one minute (4 melee rounds); bonuses from several exercises are cumulative."
  - { choose: 1, at_levels: [1, 5, 9], from: ["Stone Ox", "Kangeiko & Shochu Geiko", "Iron Hand (Kanshu)", "Chi-Gung Mega-Damage Skin", "Dam Sum Sing", "Wrist Hardening", "Kick Practice (Chagi)"], note: "One body hardening exercise at level 1, another at level 5 and another at level 9 (printed 59; the exercises are printed 196-197)." }
  - name: "Stone Ox"
    description: "Body hardening: the ultimate endurance training. Fatigues at half the normal rate and can lift and carry 50 times the normal weight capacity. +2 P.S., +1 P.E., +4D4x10 S.D.C., on top of any O.C.C. and skill bonuses. Immune to the vital strike atemi. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: 2, PE: 1 }, pools: { sdc: "4d4x10" } }
  - name: "Kangeiko & Shochu Geiko"
    description: "Body hardening: winter and summer training combined. Can endure severe weather unprotected for a full day (24 hours) without harm; invulnerable to stun and paralysis attacks; fire and cold based attacks, including magic and plasma, do half damage; impervious to the withering flesh atemi. +3D6 S.D.C., +1D6 hit points, +1 P.E. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: "3d6", hp: "1d6" } }
  - name: "Iron Hand (Kanshu)"
    description: "Body hardening, the Penetration Hand: toughened hands take no damage from striking or breaking hard objects and can handle burning coals, boiling oil, lava or fire without pain or harm; even magic fire and plasma do half damage to the hands. Normal punch 2D6 S.D.C., karate punch 4D6 S.D.C., knife hand or palm strike 1D6 M.D., power punch 2D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Punches can be pulled to do S.D.C. instead of mega-damage. +4 to damage on all hand strikes. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
  - name: "Chi-Gung Mega-Damage Skin"
    description: "Body hardening: skin that blades cannot cut and arrows cannot pierce, with a natural A.R. of 18 and at least 100 S.D.C. Whenever chi-gung focus is used the S.D.C. AND hit points of that skin become mega-damage, at 1 P.P.E. per two minutes (8 melee rounds) - this replaces the usual 5 P.P.E. for one minute of the other exercises. +1 P.E., +2D6 hit points, +90 S.D.C., on top of any O.C.C. and skill bonuses. Takes half damage from the vital strike and withering flesh atemi without rolling. Bonuses are cumulative with other exercises."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: 90, hp: "2d6" } }
  - name: "Dam Sum Sing"
    description: "Body hardening: full-power sparring for strength and resistance. All damage from punches, kicks, falls, impacts, explosions and even projectiles (arrows, bullets, rail gun rounds) is halved. +1 P.E., +20 S.D.C., +2 to roll with punch, fall or impact (a successful roll halves the damage again). As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: 20 }, combat: { roll: 2 } }
  - name: "Wrist Hardening"
    description: "Body hardening: superhumanly strong wrists and joints. +5 to escape from all holds; can lock the joints so that a combined strength of double the character''s natural P.S. is needed to bend them or break his grip; can parry attacks, even mega-damage attacks, with the wrists (normal bonuses apply). +1D6 P.S., +4 to maintain balance. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: "1d6" } }
  - name: "Kick Practice (Chagi)"
    description: "Body hardening: kicks at every height, the splits, and a jump kick straight overhead. Normal kick 4D6 S.D.C., karate and wheel kick 6D6 S.D.C., snap kick 2D6 S.D.C., jump kick 3D6 M.D., roundhouse kick 6D6 M.D., power kick 5D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Kicks can be pulled to do S.D.C. instead of mega-damage. Leaps 10 ft (3 m) high +2 ft (0.6 m) per level from a standing or crouched position; add 10 ft to lengthwise leaps with a running start. +1 to strike, +3D6 Spd. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { Spd: "3d6" }, combat: { strike: 1 } }
  - { choose: 1, at_levels: [14], from: ["Zenjoriki: Calm Minds", "Zenjoriki: Karumi-Jutsu", "Zenjoriki: Two Minds", "Zenjoriki: Vibrating Palm", "Zenjoriki: Vital Strike Atemi", "Zenjoriki: Withering Flesh Atemi"], note: "One zenjoriki power, selected at level 14 (printed 59; the powers are printed 197-199)." }
  - name: "Zenjoriki: Calm Minds"
    description: "10 P.P.E.; range 120 feet (36.5 m); lasts three minutes (12 melee rounds); takes one melee action (3 seconds) to perform. Everyone in range, friend and foe alike, who fails a save vs calm of 17 or better on a twenty-sided die (M.E. bonus applies) stops attacking at once and cannot resume offensive action until it ends, though they may defend, flee or do anything else. Any attack by the user dispels it instantly. It cannot be used on the same group again for another hour. It also dispels fear and any other hysterical emotion, whatever the cause."
  - name: "Zenjoriki: Karumi-Jutsu"
    description: "10 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The character changes his own body''s weight at will - not his clothing or possessions. It takes total concentration: no other attacks, defenses or actions while it is used, and it does not work in combat or when unconscious. Falling: lands on his feet unhurt from any distance. Jumping: up to 10 times his normal distance (at least 40 feet/12.2 m). Climbing: any surface, like an insect, with no fear of falling. Treading lightly: walks on a spider''s web, thread, a thin branch, an extremely fragile bridge, china teacups or leaves without breaking or disturbing them."
  - name: "Zenjoriki: Two Minds"
    description: "30 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The soul splits into the Hun (Cloud Soul) and the Po (Bone Soul), which act independently, even in two places at once; typically the Po fights with the body while the Hun works on tactics, calls commands or makes simultaneous psionic, magic or long-range attacks at -4 to strike. Hun: a wispy ghost with speech, analytical thought, mathematics, map reading, all thinking skills and the use of magic/P.P.E. and psionics/I.S.P.; mental attributes at full, physical at half; it cannot fight or use martial arts, recharge P.P.E. or I.S.P., or sense danger, art, taste or smell, and is barely able to walk. Po: keeps the body with all combat bonuses, physical skills, martial arts, weapon proficiencies and pilot skills, P.P.E. and I.S.P. regeneration, and taste, scent and esthetics; physical attributes at full, mental at half; it cannot speak, use thinking skills, magic or psionics, or control its emotions. Hit points and S.D.C. are split 50/50 between the two. Once split the roles cannot be swapped without rejoining and starting over."
  - name: "Zenjoriki: Vibrating Palm"
    description: "70 P.P.E.; range 120 feet (36.5 m); lasts up to 10 melee rounds (two and a half minutes); no save. Sympathetic vibrations shatter any material object: 1 point in the first melee round, doubling every round after (2, then 4, then 8 and so on) to the maximum of 512 points by the tenth round of an uninterrupted attack. S.D.C. damage to humans and S.D.C. structures, mega-damage to mega-damage beings and structures. More than 512 takes a second attack and another 70 P.P.E. It needs complete, undivided attention: no other attacks, actions or defenses, not even talking or looking elsewhere; being knocked out, blinded or tackled interrupts it. Stopped or interrupted, the vibrations end, no more damage is added, and starting again begins at 1 point."
  - name: "Zenjoriki: Vital Strike Atemi"
    description: "20 P.P.E.; a punch, kick or hand-held weapon strike (not thrown weapons or arrows); instant. The blow does its normal damage directly to hit points, bypassing physical S.D.C.; a victim at zero hit points or below falls into a coma whatever S.D.C. remains. Save: the victim halves the damage with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot be used to inflict S.D.C. damage, does only normal damage to body armor and inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni and dragons each strike does the blow''s damage x2 as M.D. (a 1D6 S.D.C. punch does 2D6 M.D., a 3D6 sword 6D6 M.D.). Characters with Stone Ox are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Zenjoriki: Withering Flesh Atemi"
    description: "25 P.P.E. if the punch or kick strikes, 5 P.P.E. if it misses; instant. Instead of normal damage the strike knocks out up to 100 points of a living victim''s natural S.D.C., leaving him open to attacks on hit points. Save: the victim halves it with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot inflict hit point damage, cannot damage body armor or inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni, dragons and even gods each strike does 2D4x10 M.D. (only 1D4x10 against elementals), until half the creature''s M.D.C. is gone, after which it has no effect; that damage cannot be regenerated by any means for one full hour. Characters with Kangeiko & Shochu Geiko are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Feng Shui or Geomancy"
    description: "Temple skill, 15% +5% per level. Evaluates the P.P.E. of an area: whether good or evil forces control it, whether its flow is natural or being tapped (wizards, rituals, Rifts), the direction of a nexus on that line, its strength, an approaching ley line storm, and whether the line connects to an open Rift, including one to a world ruled by demons or other evil supernatural forces."
  - name: "Sohei Meditation"
    description: "Temple skill, 20% +6% per level. The body rests motionless without fatigue or pain while the mind stays clear; I.S.P., P.P.E. and other inner resources recover three times as fast. Not a substitute for sleep. The meditator stays aware of the surroundings and can leave the meditation instantly with no combat penalty. Can meditate one hour at first level, plus one hour per level of experience."
restrictions:
  - "Cybernetics: none. A true Shinto monk never takes cybernetics; only 3% will even consider bio-systems."
  - "Hand to hand: Jujitsu, or Teng-jutsu at the cost of three other skills; no other combat alternatives."
  - "Pilot: none, not even horsemanship."
side_effects: "At 6th level the monastery presents a suit of Millennium Tree bark armor (120 M.D.C., millennium-bark-body-armor). Higher level monks (6th or higher) who show great courage or self-sacrifice may be given one of the more powerful Millennium Tree staves. Two towels to wrap the head are part of the kit and have no catalog row."
extraction_notes: "Rifts World Book 8: Japan printed 58-60 (cache p059-p061, text layer, page_offset +1). The entry opens under Sohei / Warrior Monk O.C.C. on printed 58 and the female sohei note ends mid-column on printed 60, where Yamabushi begins. Printed 59 and the top of 60 were rendered to read the digit cipher: parry arrows +1 at levels 4, 6, 9, 12 and 15; horror factor at 2, 4, 7, 9, 11, 13 and 15; money 3D4x10 (the book prints 3D4xlO even on the render). || XP: the Bishamon, Fighting Monk / Sohei, Warrior Monk column on the Experience Point Tables page (cache p217, printed folio 216), read off a render: 0 / 2,201 / 4,401 / 8,801 / 17,601 / 24,001 / 35,001 / 50,501 / 72,501 / 98,501 / 140,501 / 200,501 / 250,501 / 325,501 / 400,501. || GROUP: men-of-arms, men_of_arms: true. The book files it under no Men of Arms heading (the section is the New Empire''s traditional O.C.C.s); the sohei is a martial artist first, as the samurai. No S.D.C. or hit point formula is printed. || VARIANTS: printed 60 says women join as nuns with the same martial arts and a different O.C.C. skill list. A variant cannot remove a parent skill, so the parent holds the skills both lists share and each variant adds its own: the monk adds Land Navigation, Magic Lore and W.P. Spear and restates Mathematics: Basic at +20%; the nun adds Cook, Sew (Sewing), Sing and Holistic Medicine, and keeps Mathematics: Basic at +10%. Related and secondary skills, abilities and equipment are shared, as the book says. || SKILLS: Japanese at 98% is stored as Language: Native Tongue and Literacy: Native Language at 98 (no Japanese rows in the catalog). Begging is printed at 20% +3% for this class; the catalog row holds 30% +3%, and the class states the printed figure. Fasting 40% +3% matches the catalog. Oriental Philosophies is one choice of five at +15%. Feng Shui or Geomancy (15% +5%) has a catalog row now (Lore: Feng Shui/Geomancy, base 15, +5); the class does not grant it and still stores a special ability with the percentage in prose. Sohei Meditation (20% +6%) has no catalog row and is a special ability with its percentage in prose. || RELATED: five, plus one at levels 2, 5, 9 and 12. Technical is any, and its +10% applies to language skills only, so Technical is listed twice: once plain and once for the Language: and Literacy: rows by prefix at +10, which leaves out Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14). The Literacy: and Language: rows the catalog files under Communications get no entry, because the book grants this class no Communications skills and a bonus entry there would admit them. Rogue: Streetwise (+8%) and Concealment (+6%) only, each stored as its own Rogue entry with its own bonus (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Secondary: three, plus two at levels 4, 8 and 12, same limits without bonuses. || MYSTIC MARTIAL ARTS: one body hardening exercise at levels 1, 5 and 9 plus one zenjoriki power at level 14 (printed 59; powers printed 195-199). 2026-10-05, the picks (BOOK-INGEST-AUDIT.md F116): printed 59, ability 3, reads that one body hardening exercise/power can be selected at levels 1, 5 and 9, plus one zenjoriki power at level 14, and sends the reader to the mystic martial arts section (printed 195-199); it gives the class no art of invisibility. Stored as two pick groups: the seven body hardening exercises at levels 1, 5 and 9, and the six zenjoriki powers at level 14. The seven exercise definitions were replaced by the section''s fuller entries under the same names and with the same unconditional bonuses as before, and the six zenjoriki definitions were added; a picked exercise carries its own bonuses. The three level progression lines the groups replace were removed, which leaves the class with no level progression list. || BONUSES: +3 save vs possession; +1 save vs horror factor at levels 2, 4, 7, 9, 11, 13 and 15. The jodo extra attack and +1 parry (tied to staff or spear use) and the parry-arrows penalties are prose. Jujitsu''s own bonuses come from its skill row. Iron Hand''s +4 damage applies to hand strikes only and is prose. || MONEY: 3D4x10 credits'' worth of gold or tradeable goods. || EQUIPMENT: leaf armor, the Staff of Defense (90% of sohei), naginata as naginata-yari-rifts, knife, four robes, sandals or tabi as sandals, rope, backpack, three small sacks, a large water skin as water-skin-1-gallon, 4D4 days of rations as one food-rations. Towels are prose (no catalog row). The 6th-level bark armor is prose."
---

## Lore

The sohei are the traditional Shinto warrior monks of Japan. Many wander alone or in pairs, helping villagers with their children and harvests, advising elders and officials, preparing festivals, tending the sick, bargaining with landlords on the farmers'' behalf, carrying news and stories, and driving off or slaying oni and bandits. Some counsel or assist samurai and daimyo, or teach language, calligraphy, dance and poetry to nobles.

In wartime whole armies of sohei defend temples, villages and shogunates against rival factions, oni and invaders, and attacking a sohei temple is known to be folly: the monks can disarm and beat seasoned samurai with their tall wooden staves and naginata. A typical temple holds 2D4 jodo masters (1D4+9th level), 4D6 experienced monks (1D4+5th level), 6D6 young monks (1D4+1 level), 1D4x10 first-level monks and 1D6x10 novices still in training; large temples have three times as many and small ones half. There are at least 80 sohei temples in the New Empire and perhaps 400 across the islands. Two large sohei monasteries and a bishamon monastery stand within half a mile of the Millennium Tree at Kyoto, and the monks and Shinto priests share the tree''s gifts to arm their orders. The sohei and bishamon orders are friendly rivals, each vying for the people''s favor.

A sohei shaves his head and face as a sign of humility, covers his head with a knotted towel (often cut from a Millennium Tree leaf) when travelling or fighting, and wears Millennium Tree leaf or bark armor under a white robe, often with a darker brown or tan robe over it. The tall staff and the naginata are the order''s trademarks. Any alignment is possible; typically 20% principled, 25% scrupulous, 15% anarchist, 15% aberrant and 25% other. Any "willing spirit" may join, so some temples are associated with dragons or with the tengu and other minions of Shinto gods. A high P.S., M.E. and M.A. help but are not required.

Sohei acquire little wealth. Monasteries supply their basic needs, and a travelling monk can find shelter, food, water, a new robe and a place to sleep at any sohei monastery, or usually with farmers and villagers, in return for a small donation or some help with chores. A community the monk has defended usually offers a little money and free food and lodging. Some monks have a weakness for drink and books, but most live modestly and give much of what they earn to the poor and their order.

## Warrior Nuns

Women join sohei monasteries as nuns and learn the same martial arts, including jodo; only their O.C.C. skills differ (the nun variant). Most nuns defend their monastery, temples and shrines, the Millennium Trees and their community, and fight oni and evil spirits when needed, but seldom travel, spending their days as cooks, seamstresses, craftswomen, healers, teachers and advisors. A few are born with the urge to travel, fight and adventure; they are uncommon but do exist.

## Mystic Martial Arts Powers

The sohei chooses one body hardening exercise at level 1, and chooses another at level 5 and another at level 9, from the seven exercises listed with the class abilities: Stone Ox, Kangeiko & Shochu Geiko, Iron Hand (Kanshu), Chi-Gung Mega-Damage Skin, Dam Sum Sing, Wrist Hardening and Kick Practice (Chagi). The bonuses of several exercises are cumulative. The sheet offers each pick when its level is reached.

At level 14 the sohei learns one zenjoriki power, a spirit power fuelled by P.P.E., picked from the six listed with the class abilities and summarised here (printed 197-199):

- Calm Minds (10 P.P.E., 120 ft, three minutes): everyone in range, friend or foe, who fails a save of 17 (M.E. bonus applies) stops attacking, though they may defend or flee; any attack by the user ends it, and it cannot be used on the same group again for an hour. It also dispels fear and hysteria.
- Karumi-Jutsu (10 P.P.E., self, three minutes per level): the character controls his body''s weight while concentrating, to fall any distance unhurt, jump ten times his normal distance, climb any surface like an insect, and tread on the most delicate surfaces without harm. It does not work in combat.
- Two Minds (30 P.P.E., self, three minutes per level): the soul splits into the analytical Hun, a ghostly form with the mental skills and magic or psionics, and the instinctive Po, which keeps the body and fights with every physical skill but cannot speak or think tactically. Hit points and S.D.C. are split between them, and the roles cannot be swapped until they rejoin.
- Vibrating Palm (70 P.P.E., 120 ft, up to 10 melee rounds): sympathetic vibrations shatter an object or being, 1 point in the first round and doubling each round to a maximum of 512 by the tenth; S.D.C. against S.D.C. targets and M.D. against mega-damage ones. It takes the user''s complete attention, and any interruption resets it.
- Vital Strike Atemi (20 P.P.E.): a punch, kick or hand-weapon strike does its normal damage directly to hit points, and a victim reduced to zero falls into a coma whatever S.D.C. remains; a roll with impact that beats the strike halves it. Against mega-damage supernatural beings it does the blow''s damage x2 as M.D. It cannot pass environmental armor, and Stone Ox makes a target immune.
- Withering Flesh Atemi (25 P.P.E. on a hit, 5 on a miss; punch or kick): instead of normal damage the strike strips up to 100 of the victim''s natural S.D.C., leaving hit points exposed; a roll with impact that beats the strike halves it. Against mega-damage supernatural beings it does 2D4x10 M.D. (1D4x10 against elementals), up to half the creature''s M.D.C., and that damage cannot regenerate for an hour. Kangeiko & Shochu Geiko makes a target immune, and Chi-Gung skin halves it.
',
       updated_at = datetime('now')
 WHERE class_id = 'sohei-warrior-monk'
   AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 10 }') > 0
   AND length(markdown) = 29730;

-- == mystic-ninja ==
UPDATE imported_classes
   SET markdown = '---
id: mystic-ninja
occ_group: men-of-arms
men_of_arms: true
name: Mystic Ninja
system: rifts
source_book: Rifts World Book 8: Japan p.51-55
category: occ
tags: [combat, stealth]
xp_table: [0, 2401, 4601, 9201, 18401, 28301, 48001, 78001, 110001, 150001, 200001, 250001, 310001, 380001, 470001]
attribute_requirements: { IQ: 9, MA: 12, PP: 14 }
ppe_base: "1d4x10 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "2d6x100"
bonuses:
  saves: { horror_factor: 1, other: [{ label: "vs illusions", bonus: 1 }] }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
psionics:
  type: "major"
  isp_base: "1d4x10 plus M.E. attribute number, +1d6+2 per additional level of experience"
  powers: ["Bio-Regeneration", "Induce Sleep"]
  categories_allowed: ["Physical"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Physical"] }
    - { level: 3, count: 1, categories: ["Physical"] }
    - { level: 4, count: 1, categories: ["Physical"] }
    - { level: 5, count: 1, categories: ["Physical"] }
    - { level: 6, count: 1, categories: ["Physical"] }
    - { level: 6, count: 1, from: ["Psi-Sword"], note: "The super-psionic power of Psi-Sword, gained at level six." }
    - { level: 7, count: 1, categories: ["Physical"] }
    - { level: 8, count: 1, categories: ["Physical"] }
    - { level: 9, count: 1, categories: ["Physical"] }
    - { level: 10, count: 1, categories: ["Physical"] }
    - { level: 11, count: 1, categories: ["Physical"] }
    - { level: 12, count: 1, categories: ["Physical"] }
    - { level: 13, count: 1, categories: ["Physical"] }
    - { level: 14, count: 1, categories: ["Physical"] }
    - { level: 15, count: 1, categories: ["Physical"] }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Disguise", base: 45, per_level: 5, note: "+20%" }
    - { name: "Forgery", base: 30, per_level: 5, note: "+10%" }
    - { name: "Imitate Voices & Sounds", base: 56, per_level: 4, note: "+14%; the book prints Imitate Voices." }
    - { name: "Palming", base: 35, per_level: 5, note: "+15%" }
    - { name: "Pick Locks", base: 40, per_level: 5, note: "+10%; the book prints (10%) without a plus sign." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "The book prints Language: Japanese at 96%." }
    - { name: "Literacy: Native Language", base: 96, per_level: 0, note: "The book prints Literate in Japanese at 96%." }
    - { choose: 2, from: ["Language: Chinese", "Language: Mongolian", "Language: Russian", "Language: Euro", "Language: Spanish", "Language: Dragonese", "Language: Gobblely", "Language: Other"], bonus: 15, note: "Two additional languages to speak (+15%)." }
    - { name: "Horsemanship: General", base: 54, per_level: 4, note: "Ninja Horsemanship: ride any horse-like creature at 54% +4% per level (printed 54), the same as the samurai''s. Roll for a leap or a difficult maneuver such as riding while shooting a bow." }
    - { name: "W.P. Chain", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Small Thrown Weapons", base: 0, per_level: 0 }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book prints W.P. Archery and Targeting. The ninja''s own short-bow rate of fire and range are under Ninja Bowmanship." }
    - { name: "Hand to Hand: Ninjitsu", base: 0, per_level: 0, note: "Printed Ninjutsu/Tai-Jutsu. Exclusive; no alternatives are possible." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 10 }
      - "Science"
      - "Technical"
      - { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical and Pilot Related: none. Pilot: horsemanship (exotic animals), motorcycle and hover car only. Technical: any, +10% on all language skills. Physical: +5% when applicable. Weapon proficiencies: any, though ninja tend to stick with ancient types."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
      - { level: 15, count: 1 }
  secondary_skills:
    count: 0
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage"] }
      - "Physical"
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "A set of regular, nondescript clothing, usually peasant or traveler garb, and several simple disguises." }
  - { item_id: "ninja-clothing-and-boots", qty: 1, note: "A black or camouflage ninja outfit; the book also gives two pairs of rubber-soled tabi boots." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "food-rations", qty: "2d4", note: "2D4 days of rations." }
  - { item_id: "survival-kit", qty: 1, note: "Basic survival gear." }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "shuriken-rifts", qty: 12 }
  - { choose: 2, label: "ancient weapons of choice", qty: 1, from: ["katana-rifts", "wakizashi-rifts", "ninja-to-ninja-short-sword", "aikuchi-tanto-rifts", "kusari-gama-rifts", "manriki-gusari-rifts", "kusari-fundo", "kyoketsu-shoge", "nunchaku-rifts", "jitte-or-sai-rifts", "tonfa-rifts", "shikomi-zue-rifts", "shinobi-zue", "naginata-yari-rifts", "short-bow-rifts", "kawanga-rifts"], note: "The book says two ancient weapons of choice, usually concealable, without naming them; this is the catalog set of this book''s traditional weapons." }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife-tanto-jitte-sai", "vibro-saber-short-sword-ninja-short-sword", "vibro-katana", "vibro-wakizashi", "vibro-knife", "vibro-saber", "vibro-sword"], note: "The book says one vibro-blade without naming it; this book''s own vibro-blades (printed 117) come first." }
  - { item_id: "ninja-emergency-kit-rifts", qty: "1d4", note: "Carried or stored in the vicinity." }
special_abilities:
  - name: "Mega-Damage Transformation"
    description: "By will and concentration the ninja temporarily converts his hit points and S.D.C., including S.D.C. from physical skills, into M.D.C., becoming a mega-damage creature. Duration: three minutes per level of experience. Cost: 35 P.P.E. per transformation. Damage heals at the normal non-M.D.C. rate, since it is still his hit points and S.D.C. being hurt. His punches and kicks still inflict S.D.C. damage while transformed."
  - name: "Art of Escape (Inton-Jutsu)"
    description: "Like the escape artist skill but more complete: the ninja can dislocate joints and contort to slip bonds and squeeze into small openings, with muscle control, knots and ropes, and concealing tiny objects on the body. It does not include picking locks. Escapes handcuffs, locked chains, tied rope or plastic bonds automatically in 1D4 melee rounds; a straightjacket or similar restraint takes 1D4 melee rounds and a successful roll (each attempt takes time and may make noise). Escapes a hold in one melee action and a joint lock in one full melee round. High-tech restraints, confinement and difficult maneuvers take a roll and 3D4 melee rounds. Base skill: 46% +3% per level of experience."
  - name: "Ninja Bowmanship"
    description: "Uses the concealable short bow. Rate of fire with a short bow: two shots at level one, +1 at levels 2, 4, 6, 8, 10, 12 and 14; half that with a long bow. Effective range with a short bow: 320 ft (97.5 m) +10 ft (3.0 m) per level. Loses all bonuses to strike and half the rate of fire when off balance or shooting from a moving vehicle or horseback; the same penalties apply with a samurai long bow. The ninja may try to dodge arrows at -3, and energy blasts or gunfire at -6; a dodge counts as one melee action."
  - name: "False Identities"
    description: "Starts with two false, real-world identities (for example a sake merchant and a monk) and creates more aliases throughout life."
  - name: "P.P.E. from Chi-Mastery"
    description: "The ninja''s P.P.E. comes from an inward focus through meditation and ninjutsu, so he cannot draw P.P.E. from others, ley lines or nexus points. P.P.E. recovers at three points an hour, or six an hour through meditation. Hand to Hand: Ninjitsu doubles existing P.P.E. at level 11."
  - { choose: 1, at_levels: [1, 3, 6, 9, 12, 15], from: ["Art of Stealth (Pi Mi Hsing Tung)", "Art of Hiding (Inpo)", "Art of Evasion (Hsing Tsia)", "Art of Vanishing (Sun Shih K''an Chien Chih)", "Art of Disguise (Hensho-Jutsu)", "Art of Mystic Invisibility (Chi Zoshiki)"], note: "The Mystic Art of Stealth (printed 52): select one art of invisibility at each of levels 1, 3, 6, 9, 12 and 15, so all six are known by level 15. The arts are printed 195-196." }
  - name: "Art of Stealth (Pi Mi Hsing Tung)"
    description: "Mystic Art of Invisibility, the martial equivalent of prowl. Moving silently and out of sight in the dark while unsuspected is automatic, with no prowl roll; if the area comes under inspection (a spotlight, investigators) the chance to stay undetected is 43% +3% per level. Also Jung Hua, melting into water: moving silently into, out of and through water at 50% +3% per level (deep water requires the swimming skill)."
  - name: "Art of Hiding (Inpo)"
    description: "Mystic Art of Invisibility: becoming one with a surrounding object and staying motionless for hours or even days. Normally no chance of detection; in a well-lit area under careful inspection the chance to remain undetected is 60% +3% per level. Works only while the character stays motionless."
  - name: "Art of Evasion (Hsing Tsia)"
    description: "Mystic Art of Invisibility: staying out of view behind someone, turning as he turns. Automatic if the enemy is unaware of the character; if he knows or suspects someone is behind him, 50% +3% per level. The character can keep attacking from behind (critical strikes, knockout attacks) for as long as each roll keeps him unseen. Fails if a companion of the victim can see the attacker and warn him, or if the victim backs against a wall. Only the person stalked is fooled; everyone else sees both clearly. Once the victim catches sight of the stalker the power is negated and cannot be resumed unless the character can also vanish."
  - name: "Art of Vanishing (Sun Shih K''an Chien Chih)"
    description: "Mystic Art of Invisibility: disappearing from clear view, even mid-combat, by distraction and a sudden drop or roll. 85% +1% per level in full darkness with many obstructions; cumulative penalties of -10% in fair light, -20% in strong light, -15% on clear, flat, featureless ground, and -20% when cornered with nowhere to go but forward (or up, or down). The book''s example: a first level character in strong light on flat ground needs 50 or less. Lasts one melee action (two or three seconds), enough to begin the art of evasion or another ability, and the act of vanishing counts as one melee action."
  - name: "Art of Disguise (Hensho-Jutsu)"
    description: "Mystic Art of Invisibility: instantly changing posture, stance, walk and expression to pass as someone else in the same clothes. Automatic in crowds of 100 or more people; in smaller crowds or sparsely peopled areas 50% +3% per level, -40% if stopped and specifically questioned or searched. Combined with the Disguise skill: 96% to conceal true identity and 88% to physically impersonate a specific person or occupation (the latter after hours of study and practice). Useless in an outrageous outfit such as a ninja suit, though a hood or garment can be whipped off in a moment."
  - name: "Art of Mystic Invisibility (Chi Zoshiki)"
    description: "Mystic Art of Invisibility: clouding the minds of observers so the character vanishes even while standing in full view. Costs 1 P.P.E. per melee round (15 seconds) of invisibility, 4 P.P.E. per round to cloud 2-8 people at once, 12 per round for more than eight. He must turn visible to fight or to use any skill other than the arts of invisibility. It also shields his P.P.E. from magic and psionic detection and from being siphoned: detect magic, detect psionics and see the invisible cannot locate him, and those clouded cannot see him with optics or motion detectors either. Save: 19 or higher, rolled once for a whole group; a successful save means he is still seen. May try to turn invisible once per melee round."
restrictions:
  - "Cybernetics: none; they interfere with psionics, the magic transformation and the arts of stealth (-40% penalty with cybernetics or bionics). Only bio-systems may be considered."
  - "Hand to Hand: Ninjitsu is exclusive; no other hand to hand style is possible."
  - "No high-tech weapons, armor or tools to start; they may be acquired later."
extraction_notes: "Rifts World Book 8: Japan printed 51-55 (cache p052-p056, text layer, page_offset +1). The class runs from the Mystic Ninja O.C.C. heading on printed 51 through the Money and Cybernetics lines at the top of printed 54; Traditional Ninja Equipment and Ninja Gimmick Clothing follow on 54-55 (catalog gear rows from add-a-japan-traditional-gear.sql, none granted at start beyond the outfit, shuriken and emergency kits). Class stat block read from renders of printed 53 and 54; the Arts of Invisibility from a render of printed 195 (cache 196, a corrupt page). || GROUP: the book files the class under New Empire & Traditional O.C.C.''s (contents, printed 4), which names no group. Stored as men-of-arms with men_of_arms true because it is a warrior class built on Hand to Hand: Ninjitsu; its psionics are major but secondary. A judgment call. || XP: the Tech-Ninja, Mystic Ninja column of the Experience Point Tables (printed 216, cache p217), read off a render. || SKILLS: Japanese is stored as Language: Native Tongue and Literacy: Native Language at 96%; the catalog has no Japanese row. Pick Locks prints (10%) with no plus sign; read as +10%. Acrobatics prints (+5) with no percent sign; read as +5%. W.P. Archery and Targeting is stored as W.P. Archery (RUE), not the book''s own W.P. Bow. Ninja Horsemanship (54% +4%) is stored as Horsemanship: General at the printed percentage. Technical''s +10% applies to language skills only, and reaches every Language: and Literacy: row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): Technical is listed twice, once plain and once for the Language: and Literacy: rows by prefix at +10, and Communications is listed twice, once plain and once for the Literacy: rows and Language: Dolphin/Whale at +10. Language: All (magical) gets no bonus, because the catalog files it as an innate ability and not a learned language. Secondary skills: none at level one, two at each of levels 2, 5, 9 and 12, the book''s own phrasing elsewhere (printed 53). || HAND TO HAND: the style''s attribute bonuses and level table live on the Hand to Hand: Ninjitsu catalog row and are not repeated here. || PSIONICS: major; Bio-Regeneration (self, via meditation) and Induce Sleep at level one, one Physical power per level from two, and Psi-Sword at level six. I.S.P. 1D4x10 plus M.E., +1D6+2 per level. || MYSTIC MARTIAL ARTS: the book gives one Art of Invisibility (it calls the category the Art of Stealth) at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group over the six arts taken at those six levels (BOOK-INGEST-AUDIT.md F116). || NOT STORED AS NUMBERS: the Mega-Damage Transformation is temporary and paid in P.P.E., so it is an ability, not mdc_from_hp_sdc. The bow''s dodge penalties are conditional and are prose. The save vs illusions is saves.other, not illusionary_magic. || 2026-10-05, MYSTIC ART OF STEALTH: printed 52, ability 2, read off a render: the character selects one power from the category at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group with at_levels [1, 3, 6, 9, 12, 15] over the six arts of invisibility, level 1 being the creation pick; six picks over six arts, so every art is held by level 15 (BOOK-INGEST-AUDIT.md F116). The six definitions were replaced with the readings of printed 195-196 shared by every Japan class that takes these powers; none prints an unconditional number, so none carries bonuses. The Art of Escape (Inton-Jutsu), ability 3 on printed 52, is granted outright, is printed only on this page and is not in that category; its definition was checked against the render (1D4 melee rounds, 3D4 melee rounds, 46% +3% per level) and left as it was."
---

## Lore

The ninja clans of old Japan arose as peasant warrior societies opposed to the samurai who alone could bear arms. Barred from weapons and from work as fighters, they built their own secret martial arts, tools and techniques around stealth, disguise and absolute secrecy, and became the ultimate warriors for hire: spies, saboteurs and sometimes assassins, though never necessarily evil. They worked in small teams, used shuriken and smoke to cover an escape rather than to kill, hid tools in concealed pockets, and learned to dislocate their own joints to slip bonds and pass through narrow openings. Many were also fine swordsmen, archers and horsemen.

In Rifts Japan the ninja is little changed, except that intense training and deep spirituality in a magic-rich world have given the mystic ninja superhuman powers. Many regard these shadow warriors as supernatural agents of death. The mission comes first; killing is done only when it becomes necessary.

A clan keeps its members'' identities secret. The genin, or field ninja, live ordinary lives as merchants, priests or farmers until summoned, often with two or more false identities; the chunin deal with clients; the jonin who leads the clan is seen only by the chunin. A ninja whose capture would do the clan irreparable harm may take his own life rather than talk. The clans have friends among the eta, mercenaries and pirates across Japan.

## Player Notes

A player character may hide his occupation from his own group by posing as another O.C.C. (a monk, priest, ronin, mercenary, wilderness scout, vagabond or peasant), or may appear openly as a ninja, masked and in black, never revealing his true identity. He may come to trust companions enough to reveal one of his false identities.

The clan may call on the character for a mission of sabotage, espionage or assassination that cuts against the group''s plans, even setting him against its members. Defying the clan means another ninja or a team of 3-6 is sent to do the job, and the defiant ninja is marked as a traitor to be hunted down and silenced.

## Mystic Arts of Invisibility

The ninja selects one Mystic Art of Invisibility at level 1 and one more at each of levels 3, 6, 9, 12 and 15 (the ability choice above, offered again at each of those levels), so by level 15 he knows all six: Stealth, Hiding, Evasion, Vanishing, Disguise and Mystic Invisibility. Each art is described in the abilities above.

## Equipment and Money

Equipment is kept to a minimum. Besides the listed gear the ninja carries some personal items and two pairs of rubber-soled tabi boots. Weaponry is usually ancient and concealable. The ninja adapts to his world and may later use some technology, such as vibro-blades, laser scalpels, body armor and vehicles, but starts with none beyond the one vibro-blade. The clan provides or sells the traditional ninja equipment and gimmick clothing, which is not available to the public. Money: 2D6x100 credits in saleable items.
',
       updated_at = datetime('now')
 WHERE class_id = 'mystic-ninja'
   AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 10 }') > 0
   AND length(markdown) = 20670;

-- == ectohunter ==
UPDATE imported_classes
   SET markdown = '---
id: ectohunter
name: Ectohunter
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.61-64
category: occ
tags: [hunter]
occ_group: optional
men_of_arms: false
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_requirements: { IQ: 9, ME: 14 }
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "4d6 plus P.E. attribute number, +1d4 per level of experience"
starting_money: "1d6x1000"
bonuses:
  combat: { pull_punch: 1 }
  saves:
    horror_factor: 1
    possession: 10
    other: [ { label: "vs illusions", bonus: 1 } ]
  at_level:
    - { level: 2, saves: { horror_factor: 1, possession: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1, possession: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1, possession: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1, possession: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1, possession: 1 } }
    - { level: 12, saves: { horror_factor: 1, possession: 1 } }
    - { level: 14, saves: { horror_factor: 1, possession: 1 } }
special_abilities:
  - name: "Sense and See the Ghostly"
    description: "Attuned to ethereal energy beings and spirit-like life essences: Astral beings, Russian ghosts, all entities including possessing ones, ethereal spirits and demons such as the Banshee, and the splintered life essences of alien intelligences, gods and demon lords, including true witches and mortal servants joined to such an essence. Senses them within 100 feet (30.5 m) per level of experience and sees them whenever they are in line of sight. Sees the aura of a possessing entity or essence and gets a strong sense of what type it is and how powerful, but not exactly who. The being knows it has been seen and may choose to identify itself. Innate; no P.P.E. or concentration."
  - name: "Recognized by the Ghostly"
    description: "Ghostly beings recognize the Ectohunter on sight for what he is, just as he sees them. They may talk, threaten, flee or attack. It can make them flee or negotiate, but it makes sneaking up on them difficult and marks the Ectohunter as an enemy at once."
  - name: "Communication with the Ghostly"
    description: "Can speak with and understand ghosts, entities, essences and astral beings mentally, much like telepathy, whether or not the character has psionics. The exchange is silent; to onlookers the Ectohunter seems to daydream, fall into a trance or gesture at someone unseen."
  - name: "Ghost Killing"
    description: "Focuses magic energy to hurt ghosts, spirits, entities, astral beings and the energy form of alien intelligences. A bare punch does 1D6 M.D. to such beings. A hand-held ancient S.D.C. weapon does its usual damage dice as Mega-Damage plus 1D6 M.D. (a 2D6 S.D.C. sword does 3D6 M.D.). Against vampires the weapon does its normal S.D.C. damage plus 1D6 S.D.C. P.P.E. cost: two points per use. Duration: as long as the character concentrates, typically four melee rounds per level of experience; using any skill other than combat and W.P. ones cancels it. Below 5th level it takes one full melee round (15 seconds) of concentration to manifest; at 5th level and higher it is instant. Range: self and hand-held weapons, from a sword to a cudgel or chair. Works only on ethereal energy beings and spirit-like life essences, not on solid flesh-and-blood M.D.C. demons and monsters."
  - name: "Sense Supernatural Evil"
    description: "Feels the presence of supernatural evil within 200 feet (61 m) per level of experience, doubled if the source is an alien intelligence, a group of vampires or a gathering of 20 or more witches or demons. Can tell whether it is one, a few or many beings; the general level of power (low, medium, powerful, incredibly powerful); whether it is demonic or something else (ancient god, spirit, elemental, alien intelligence, witch, necromancy); and whether it is caused by vampires. Cannot be tracked to its source. Constant and automatic; no P.P.E."
  - name: "Resistance to Horror Factor"
    description: "+1 to save vs Horror Factor at levels 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12 and 14, when it comes to supernatural monsters and horrors. The sight of blood, brutality and other things may still be disturbing."
  - name: "Resistance to Possession"
    description: "+10 to save vs possession, and a further +1 at levels 2, 4, 6, 8, 10, 12 and 14."
  - name: "Magic Abilities"
    description: "Can use magic items and read scrolls."
  - name: "Initiative Against the Ghostly"
    description: "+2 on initiative against ghostly beings only."
  - name: "Vulnerability: Insanity"
    description: "Every other level of experience there is a 01-50% chance the character permanently loses one M.E. point. Every third level of experience, starting with level three, there is a 01-66% chance of developing an insanity: on 01-66 roll on the Random Insanity Table (Rifts RPG page 19); 67-00 means none."
side_effects: "Insanity: every other level, 01-50% chance to permanently lose one M.E. point; every third level from level three, 01-66% chance of a random insanity."
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { name: "Language: Euro", base: 70, per_level: 5, note: "Speaks Euro (+20%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Speaks two other languages of choice (+20%)." }
    - { name: "Literacy: Russian", base: 40, per_level: 5, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 25, per_level: 5 }
    - { choose: 1, categories: [{ name: "Technical", only_prefix: ["Lore:"] }, { name: "Cowboy", only_prefix: ["Lore:"] }], note: "Lore: one of choice." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Surveillance", base: 40, per_level: 5, note: "Surveillance Systems (+10%)." }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Read Sensory Equipment (+10%)." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 5, note: "Pilot: one of choice (+5%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, one of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Weapon of choice (any)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of one O.C.C. Related Skill, or two skills for Martial Arts (or Assassin if evil)." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 15 }
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - { name: "Electrical", only_prefix: ["Computer"], bonus: 15 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Airplane", "Helicopter", "Jet Aircraft", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language:", "Literacy:", "Computer"], bonus: 15 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Choose eight other skills at level one. Communications: any (+10%). Domestic: any. Electrical: any (+5%). Espionage: none. Mechanical: Basic and Automotive only. Medical: First Aid only. Military: none. Physical: any, except Gymnastics and Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft. Pilot Related: any (+10%). Rogue: none, other than Streetwise. Science: any (+5%). Technical: any (+10%; +15% to language or computer skills). W.P.: any. Wilderness: any."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Airplane", "Helicopter", "Jet Aircraft", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Four secondary skills from the list at level one and one more at levels 2, 4, 6, 9 and 12, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1, note: "Light suit of M.D.C. body armor." }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "knife-silver-plated", qty: 2, note: "A pair of silver knives." }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The book says a mallet." }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "sack", qty: 2, note: "Medium." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1, note: "Canteen or water skin." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "marker", qty: "2d4" }
  - { item_id: "cord", qty: 1, note: "10 feet (3 m) of thin nylon cord, 600 lb. test strength." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are selfish."
  - "Racial restrictions: none, although the majority (70%) are human."
  - "Attribute requirements: I.Q. 9 and M.E. 14 or higher. A high M.A., P.S. and P.E. are helpful but not required."
  - "Psionics are not a requirement, but approximately one third possess minor or major psionics."
  - "Cybernetics: none to start; varies with the individual. Most avoid bionics, as they are harmful to psionic and magic abilities."
  - "Vehicle: starts with a used, battered-looking hovercycle or other basic transportation, missing 1D4x10 M.D.C. from its main body but in fairly good condition."
extraction_notes: "WB17 Warlords of Russia printed 61-64 (cache p062-p065, cache page = printed folio + 1), read off the text layer. The stat block starts on printed 63 and ends with Money and Cybernetics on printed 64. || HEADING: Ectohunter O.C.C., also known as Ghost Hunters and spiritualists; listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base. || XP: the Ectohunter, Travelling Story Teller and Warlord Cyber-Doc ladder as given in the brief, read off a render of the Experience Tables on printed 6. || SPECIAL ABILITIES: the eleven numbered Special Ectohunter O.C.C. Abilities (printed 62-63) are stored as special_abilities, except 6 (P.P.E.), which is ppe_base, and 10 (O.C.C. Bonuses), which is split: +1 pull punch is in bonuses, +1 to save vs illusions is saves.other because the book says illusions and not illusionary magic, and +2 initiative against ghostly beings only is conditional and stored as an ability. || HORROR FACTOR: +1 at levels 1-10, 12 and 14 stored as horror_factor 1 plus eleven at_level entries; the book qualifies it as applying to supernatural monsters and horrors, which is stated in the ability and is a reading. || POSSESSION: +10 flat plus +1 at levels 2, 4, 6, 8, 10, 12 and 14, as printed. || P.P.E.: 4D6 plus the P.E. attribute number, plus 1D4 per level. The class casts no spells of its own (it reads scrolls and uses magic items), so there is no magic block. || PSIONICS: not a requirement; about one third have minor or major psionics; no block and no roll is printed. || VULNERABILITY: the M.E. loss and insanity rolls are in side_effects and an ability; nothing applies them. ''Every other level'' prints no starting level. || SKILLS: Speaks Euro and two other languages of choice (+20%) is read as Euro at +20% and two Language: Other picks at +20%. Surveillance Systems maps to Surveillance, Read Sensory Equipment to Sensory Equipment. Lore: one of choice is one pick across the Lore: rows of Technical and Cowboy. Pilot: one of choice (+5%) offers all of Pilot; the O.C.C. line prints no exclusion. W.P. Energy Weapon of choice is a W.P. category pick with the restriction in the note. || PILOT EXCEPT: ''except robots, power armor, military vehicles, ships and aircraft'' read literally as all ships and all aircraft, mapped to the Robot rows, the Military: rows, Boat: Ships, Airplane, Helicopter, Jet Aircraft, both Fighter Combat rows, the three Space craft rows and Wingrider Flying Wing. Air Assault Armor, Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored. The +15% to language or computer skills reaches every Language: and Literacy: row and every Computer row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): a second Technical entry holds the Language:, Literacy: and Computer rows by prefix at +15, a second Communications entry the Literacy: rows and Language: Dolphin/Whale at +15, and a second Electrical entry the Computer rows (Computer Repair) at +15. Language: All (magical) is left at Communications'' +10, because the catalog files it as an innate ability and not a learned language. Computer Hacking is a Rogue skill and Rogue is Streetwise only, so it gets no entry and stays unavailable. || MONEY: 1D6x1000 credits stored (the text layer prints !D6xlOOO); the 1D6x100 in tradeable goods is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon of choice; a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row. Clothing, bedroll and note pad rows exist now (clothing, bedroll-rifts, note-pad); the class does not list them. Light suit of M.D.C. body armor maps to light-mdc-body-armor, the pair of silver knives to two knife-silver-plated, the mallet to hammer-and-mallet. || NOT STORED: the fee structure (as little as 100 credits to tens of thousands, a nonrefundable 10% retainer plus expenses), the nationality percentages, and Secret Resources are prose in GM Notes."
---

## Lore

The Ectohunter is a professional ghost hunter: part bounty hunter, part
exterminator, working against spirits, entities and other spectral things
across Russia, Mongolia, China and the rest of Eurasia. Most took up the
trade after a brush with the supernatural that left a mark. Some are grim,
some scholarly, some reckless or jumpy, and a few are as cold as what they
hunt.

Long exposure to the spirit world has changed them. They sense and see
ghostly beings, speak with them mind to mind, and can charge a fist or an
old-fashioned weapon with enough magic energy to hurt something that has no
body. They shrug off fear and possession that would break anyone else. They
can read scrolls and use magic items, but they are not mages.

They work for pay, and they are not shy about it: a retainer up front, room
and board while on the job, and the balance on success. That, and the fact
that a banished ghost leaves no body as proof, means many people think of
them as arrogant and grasping. The work also wears on the mind over time.

## GM Notes

Ghost Killing costs 2 P.P.E. per use, lasts about four melee rounds per level
while the character concentrates, and takes a full melee round to bring up
below 5th level. It affects only ethereal beings and spirit-like essences; it
does nothing against solid M.D.C. demons and monsters, which is why most
Ectohunters will identify such a threat for a small fee but refuse to fight
it, and the half who will fight charge outrageous fees.

The +2 initiative applies only against ghostly beings. The Horror Factor
bonus is printed for supernatural monsters and horrors.

Vulnerability, rolled by hand: every other level, 01-50% to permanently lose
one M.E. point; every third level starting at level three, 01-66% to gain a
random insanity (Random Insanity Table, Rifts RPG page 19).

Fees vary by hunter and danger: as little as 100 credits and a couple of
nights'' hospitality for a minor entity, up to tens of thousands of credits or
more for a great menace. The usual terms are a nonrefundable 10% retainer
plus room and board, with the balance paid only on success; an employer may
keep the hunter in town for days or weeks, at the community''s expense, to see
that the thing is gone.

Starting kit beyond what the sheet lists: one M.D. weapon of choice, a box of
100 large resealable plastic bags for specimens, clothing, bedroll, belt,
boots, a note pad and personal items. Money is 1D6x1000 credits plus 1D6x100
in tradeable goods. The vehicle is a used hovercycle or other basic
transportation missing 1D4x10 M.D.C. from the main body.

No secret resources. Most people dislike Ectohunters as money-grubbing;
Bogatyrs and other humanitarians especially so, and Huntsmen treat them as a
joke. About 30-40% have psionics, by the ability text; the stat block says
about one third have minor or major psionics. Neither prints a roll.
',
       updated_at = datetime('now')
 WHERE class_id = 'ectohunter'
   AND instr(markdown, '{ name: "Technical", only_prefix: ["Language", "Computer"], bonus: 15 }') > 0
   AND length(markdown) = 19011;

-- == huntsman-trapper ==
UPDATE imported_classes
   SET markdown = '---
id: huntsman-trapper
name: Huntsman-Trapper
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.66-69
category: occ
tags: [wilderness, hunter]
occ_group: optional
men_of_arms: false
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { IQ: 9, PE: 12 }
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "4d6 + P.E. attribute number, +1d4 per level of experience"
starting_money: "0"
bonuses:
  combat: { initiative: 2, pull_punch: 3 }
  saves: { spell_magic: 1, possession: 3, toxins_poisons: 2, disease: 2, horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { choose: 3, from: ["Language: Other"], bonus: 10, note: "Speaks Faerie and two other languages of choice (+10%). One of the three picks is Faerie; the other two are free." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: Faeries & Creatures of Magic", base: 45, per_level: 5, note: "Lore: Faeries (+20%)." }
    - { name: "Dowsing", base: 40, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 35, per_level: 5, note: "Identify Plants & Fruits (+10%)." }
    - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 70, per_level: 5, note: "Swim (+20%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Camouflage", base: 40, per_level: 5, note: "+20%" }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
    - { name: "Trap Construction", base: 40, per_level: 4, note: "+20%" }
    - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "+10%" }
    - { name: "Track & Trap Animals", base: 20, per_level: 5, note: "Special O.C.C. ability 1: tracking 20%, trapping 30%, each +5% per level. The stored figure is the tracking number. Tracking humans is at -20%; disarming traps meant for humans is at half." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice (any)." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two modern S.D.C. weapons of choice (typically, a rifle is one)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one M.D. energy weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "No others are available." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Detect Concealment", "Intelligence", "Tracking (people)"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"], bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Cardsharp", "Prowl"], bonus: 10 }
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Choose five other skills at level one and two additional at levels 4, 8 and 12. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: none, except Detect Concealment, Intelligence and Tracking (all +5%). Mechanical: none. Medical: First Aid, Holistic Medicine and Brewing only. Military: none (Falconry is offered here only because the catalog files it under Military; the book prices it under Technical at +15%). Physical: any, except Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft (horsemanship is filed in its own category here). Pilot Related: any, but usually none. Rogue: none, other than Cardsharp and Prowl (+10%). Science: Astronomy, Botany and Advanced Math only (+5%). Technical: any (+10%). The book prints Whittling and Falconry at +15%; Falconry''s is on its Military line, and Whittling takes Technical''s +10%. W.P.: any. Wilderness: any (+10%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Concealment", "Intelligence", "Tracking (people)"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Cardsharp", "Prowl"] }
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the list at level one and one additional at levels 2, 4, 6, 8 and 12, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - { name: "Track & Trap Animals, Otherworldly Creatures & Demons", description: "An expanded Track Animals. Identifies an animal, a creature from the Rifts or an animalistic demon by tracks, scent, spoor and habits; follows its trail; judges how fresh the tracks are, their direction, whether the creature is hurt or sick and roughly how old; and knows the habits and habitats of most Russian woodland creatures, including Faerie Folk, Russian ghosts, lesser demons, vampires, werebeasts and woodland spirits. Base skill 20% tracking / 30% trapping (using, setting and disarming snares, clamp traps, pits and nets), +5% per level. Tracking humans is possible at -20%. Disarming a trap meant for humans is at half the normal skill." }
  - { name: "Recognize Supernatural Shapechangers", description: "Recognizes shapechangers, particularly werebeasts, vampires, Faerie Folk and those of the Russian forests, by an animal acting out of character, and can usually tell the likely race or true identity. Has an innate sense for werebeasts in both human and animal form; a werebeast does not automatically treat the Huntsman as an enemy and will often speak frankly to him. Base skill 30% +5% per level." }
  - { name: "Forest-wise", description: "Streetwise for the forest: recognizes the bands, gangs and tribes of humans, D-Bees, Faerie Folk, werebeasts and lesser demons that inhabit, hunt or hide in the forests, with their philosophies, practices, rituals, haunts and dangerous places; also applies to predatory animals. Base skill 20% +4% per level." }
  - { name: "Unusually High P.P.E.", description: "4D6 + the P.E. attribute number, +1D4 P.P.E. per level, unusually high for someone who does not practice magic. It lets the Huntsman use magic items and draw on ley lines to heal." }
  - { name: "Ley Line Healing/Rejuvenation", description: "Resting at a ley line for several days doubles the rate of natural healing. Once every 48 hours the character can also do an instant healing by meditating while sitting on a ley line: after 15+1D6 minutes, 2D6 Hit Points and 2D6 S.D.C. are restored." }
  - { name: "The Code of the Huntsman-Trapper", description: "Mercy is a virtue. Compassion will be rewarded. Children are the future; be kind and help them. Do not squander what is given: use as much of the meat, fur, bone, teeth and horn of a kill as possible, and understand and appreciate the creatures of the wild. Killing demons (including Gargoyles, Brodkil, vampires, witches and necromancers, but not werebeasts or dragons) is a blessing to man and to Russia. Life is a wonder to be enjoyed." }
equipment_starting:
  - { item_id: "homemade-mdc-armor-light", qty: 1, note: "Light suit of M.D.C. body armor, usually a hodgepodge of homemade armor." }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "hand-axe-utility", qty: 1, note: "The book says a hand axe." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says a language translator." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "The book says a lighter." }
  - { item_id: "small-sack", qty: "1d6" }
  - { item_id: "sack", qty: 6, note: "Six medium-sized sacks." }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "lightweight-cord", qty: 1, note: "10 feet (3 m) of thin nylon cord." }
  - { item_id: "cord", qty: 1, note: "50 feet (15.2 m) of additional cord, 600 lb (270 kg) test strength." }
  - { item_id: "animal-snare", qty: 1, note: "The book says animal snares, with no number." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none, although the majority (63%) are human."
  - "Attribute requirements: I.Q. 9 and P.E. 12 or higher. A high M.E. and P.S. are helpful but not a requirement."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Expert only; no others are available."
  - "Cybernetics: none to start, and avoids them as unnatural. The only cybernetics a Huntsman might consider are bio-system prosthetics and organs to replace severely injured ones."
  - "Vehicle: none to start; most Huntsmen prefer to walk, but may know how to ride a horse or hovercycle in a pinch."
extraction_notes: "WB17 Warlords of Russia printed 66-69 (cache p067-p070, cache page = printed folio + 1), read off the text layer. Heading The Huntsman-Trapper O.C.C. at the top of printed 66; the special abilities are printed 66-68 and the stat block headed The Russian Huntsman-Trapper O.C.C. (also known as Woodsman and Trapper) starts on printed 68. The entry ends on printed 69, where its Note, Money and Cybernetics lines are interleaved in the text layer with the opening of the Travelling Story Teller (cache p070 lines 57-80 are the Huntsman''s). || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Huntsman-Trapper ladder on the Experience Tables, printed 6, read off a render; the book misprints level 5 as 18,501, level 4 ends at 16,500, so 16501 is stored. || BONUSES: +2 initiative, +3 pull punch, +3 vs possession stored flat; +1 to save vs magic is stored as spell_magic only (a reading: the book says magic, not spell or ritual); +2 vs poison and disease is stored as toxins_poisons 2 and disease 2; +1 vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 is stored as horror_factor 1 flat for level 1 plus eight at_level entries. || P.P.E.: 4D6 + P.E. attribute number and +1D4 per level, stored in ppe_base and repeated as a special ability. || SPECIAL ABILITIES: the three percentile abilities (Track and Trap 20%/30% +5%, Recognize Supernatural Shapechangers 30% +5%, Forest-wise 20% +4%) are special_abilities prose. Track & Trap Animals is ALSO stored as an occ skill at 20/5 because the catalog holds a row of that name at the same figures; that is a reading, and the 30% trapping number lives only in its note. Recognize Supernatural Shapechangers and Forest-wise have no catalog skill row. The Code of the Huntsman-Trapper (printed 68) is stored as a special ability, paraphrased. || SKILLS NOT STORED: Lore: Geomancy & Ley Lines (+10%) has no catalog row and is left out. Speaks Faerie has no catalog language row; it is stored as one of three Language: Other picks at +10%. || SKILL READINGS: Lore: Faeries is the catalog''s Lore: Faeries & Creatures of Magic; Identify Plants & Fruits is Identify Plants & Fruit; Tracking is Tracking (people); Advanced Math is Mathematics: Advanced. Falconry is filed under Military in the catalog, so Military appears with only Falconry at the +15% the book prints under Technical, although the book says Military: None; Whittling at +15% is not stored: Whittling & Sculpting takes Technical''s flat +10, and the printed +15% is kept here and in the related-skills note (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14). Prowl is filed under Physical and is reached by name through the Rogue only-list at +10%. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft (the Explorer on printed 65 says military aircraft; this entry does not); Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Huntsman may know how to ride a horse. Hand to Hand: Expert, no others available, is costs: {}. || MONEY: the book prints no coin: 4D4x100 credits WORTH of furs, horns, bone, nuggets of silver or gold and other tradeable goods (the text layer prints 4D4xlOO). starting_money is 0 and the goods are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; flint and tinder box, frying pan, a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, belt, boots, 20 feet of wire and personal items have no catalog row and are in GM Notes. Rows exist now for the skinning knives, cooking utensils, bedroll, fur cloak or long coat and note pad (knife-skinning, utensil-kit-rifts, bedroll-rifts, cape-or-cloak-long, note-pad); the class does not list them and they are still in GM Notes. The text layer prints scalable for sealable. The armor is stored as the light homemade suit; the lore text on printed 67 says such armor is typically 30-60 M.D.C. and rarely environmental. || NOT STORED: Secret Resources and the Note on how Reavers, War Camp soldiers, Bogatyrs, Demon Hunters and Ectohunters regard the class are in GM Notes; only 15% have partial bionics (printed 67)."
---

## Lore

The Huntsman-Trapper is part hunter, part trapper and part forest guide: a
burly, loud, cheerfully crude woodsman who lives by his own code in the deep
Russian forests where even War-Knights hesitate to go. City folk take him for
a dim barbarian. He is nothing of the kind; surviving out there takes
alertness, invention and cunning, and most Huntsmen read people as well as
they read tracks.

Villages hire them to deal with man-killers, livestock thieves and things far
worse, and to find people lost or taken in the woods. A Huntsman does not just
go and kill the problem. He spends a few days studying the creature and the
community, and often ends it by relocating an animal, building a fence, or
striking a bargain with Faerie Folk, werebeasts or woodland spirits, who treat
him as one of their own. Man-eaters and truly evil supernatural beings get no
such bargain.

They wear patchwork armor of hide, bone and scavenged plate, favor
Vibro-Blades and heavy energy weapons, and mostly shun bionics.

## GM Notes

Percentile abilities the sheet does not roll for you: Track and Trap is 20%
tracking / 30% trapping, +5% per level (tracking humans at -20%, disarming
traps meant for humans at half); Recognize Supernatural Shapechangers is 30%
+5% per level; Forest-wise is 20% +4% per level.

The save vs Horror Factor rises by +1 at levels 1, 3, 4, 5, 7, 8, 10, 12
and 14.

One of the three language picks is Faerie. The book also grants Lore:
Geomancy & Ley Lines (+10%), which the catalog does not hold.

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+2
extra clips apiece, skinning knives, flint and tinder box, cooking utensils,
frying pan, a box of 100 plastic sandwich bags, a box of 100 large sealable
bags, 1D4 airtight plastic containers, bedroll, belt, boots, a fur cloak or
long coat, note pad, 20 feet (6 m) of wire and a handful of personal items.

Money: no coin. The Huntsman starts with 4D4x100 credits worth of furs, horns,
bone, nuggets of silver or gold and other tradeable goods (herbs, spices,
birds, small animals).

Secret resources: none as such, but Huntsmen are highly regarded by Gypsies,
Travelling Story Tellers, Mystic Kuznya, Mega-Horses and peasants. Reavers and
War Camp soldiers dislike, envy and somewhat fear them, and often bully and
harass them, yet turn to them for woodland expertise. Bogatyrs and Demon
Hunters usually like them; Ectohunters tend to see them as crude rivals.
',
       updated_at = datetime('now')
 WHERE class_id = 'huntsman-trapper'
   AND instr(markdown, '{ name: "Technical", only: ["Whittling & Sculpting"], bonus: 15 }') > 0
   AND length(markdown) = 19477;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 5 classes carry their new text' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'travelling-story-teller' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '{ name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '{ name: "Electrical", only_prefix: ["Computer"], bonus: 15 }') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, 'Whittling at +15% is not stored') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'travelling-story-teller' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 15 }') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 10 }') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 10 }') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language", "Computer"], bonus: 15 }') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, '{ name: "Technical", only: ["Whittling & Sculpting"], bonus: 15 }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('travelling-story-teller', 'sohei-warrior-monk', 'mystic-ninja', 'ectohunter', 'huntsman-trapper') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~192-book-ingest-audit-f138-32a-readings.sql');
