-- Take BOOK-INGEST-AUDIT F138: nine classes' scoped language and literacy bonus reaches the bare Literacy row
-- 9 classes, each replaced whole: travelling-story-teller, sohei-warrior-monk, mystic-ninja, ectohunter, grey-seer, pirate, sailor, monkey-boy-tech, necromancer.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~196-book-ingest-audit-f138-bare-literacy.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Nine classes' scoped Technical entry for their printed language/literacy bonus
-- (~192, ~194, ~195) named the prefix "Literacy:", which never admits the
-- catalog's bare Literacy row (Technical), so that row fell to the plain
-- Technical entry and lost the bonus. Each entry gains the exact name "Literacy"
-- in its only list, by Nate's 2026-10-14 ruling that the bare row counts as
-- literacy; Calligraphy does not. No prefix moves, so nothing else is reached.
-- - ectohunter, monkey-boy-tech, travelling-story-teller: Literacy 10 to 15.
-- - grey-seer: Literacy 0 to 15.
-- - mystic-ninja, necromancer, pirate, sailor, sohei-warrior-monk: 0 to 10.

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
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 15 }
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
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0
   AND length(markdown) = 13962;

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
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
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
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0
   AND length(markdown) = 30038;

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
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }
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
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0
   AND length(markdown) = 21156;

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
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Computer"], bonus: 15 }
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
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Computer"], bonus: 15 }') > 0
   AND length(markdown) = 19655;

-- == grey-seer ==
UPDATE imported_classes
   SET markdown = '---
id: grey-seer
men_of_arms: false
occ_group: magic
name: Grey Seer
system: rifts
source_book: Rifts World Book 16: Federation of Magic p.88-91
category: occ
tags: []
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
attribute_requirements: { IQ: 8, MA: 10, ME: 10 }
ppe_base: "1d6x10 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "2d4x100"
psionics:
  type: "major"
  isp_base: "6d6+6 plus M.E. attribute number, +1d6+1 per additional level of experience"
  powers: ["Clairvoyance", "Sixth Sense", "Empathy", "Mind Block"]
  powers_starting: 0
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 3, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 4, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 4, count: 1, categories: ["Super"], note: "One Super psionic power at fourth level." }
    - { level: 5, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 6, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 7, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 8, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 9, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 10, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 11, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 12, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 13, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 14, count: 1, categories: ["Sensitive", "Healing"] }
    - { level: 15, count: 1, categories: ["Sensitive", "Healing"] }
magic:
  type: "spell"
  spells: ["Oracle", "Sustain", "Life Source", "Magic Shield", "Armor of Ithan", "Tongues"]
  spells_starting: 2
  spell_levels_allowed: [1, 2]
  spells_schedule:
    - { level: 2, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 3, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 4, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 5, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 6, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 7, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 8, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 9, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 10, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 11, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 12, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 13, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 14, count: 2, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 15, count: 2, spell_levels: [1, 2, 3, 4, 5] }
bonuses:
  combat: { initiative: 3, parry: 2, dodge: 3, automatic_dodge: 1, disarm: 4, entangle: 2, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 3, possession: 2 }
  at_level:
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 4, saves: { psionics: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 8, saves: { psionics: 1 } }
    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1, psionics: 1 } }
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Printed as Speaks American (+20%); the native tongue is held at 98%." }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%. Printed as literate in American." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Speaks one language of choice (+15%); no literacy in it is printed." }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Advanced", base: 60, per_level: 5, note: "+15%" }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - { name: "Cowboy", except: ["Branding", "Horsemanship: Cowboy", "Trick Riding"] }
      - { name: "Cowboy", only_prefix: ["Lore:"], bonus: 15 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Medical", only: ["Holistic Medicine", "Animal Husbandry", "Brewing"], bonus: 5 }
      - { name: "Military", only: ["Camouflage"] }
      - { name: "Physical", except: ["Boxing", "Acrobatics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Pilot", only: ["Boat: Sail Type"] }
      - { name: "Rogue", except: ["Computer Hacking", "Cardsharp", "Seduction"] }
      - { name: "Science", bonus: 5 }
      - "Technical"
      - { name: "Technical", only: ["Art", "Art: Line Drawing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
    note: "Six at first level, plus one at levels 3, 6, 9, 12 and 15. Hand to Hand must be taken HERE: Basic costs one selection, Expert two, Martial Arts three. Technical: any, +15% to Art, Language and Lore skills only. Piloting: Horsemanship (General) and sailing only. Electrical, Mechanical and Pilot Related: none. Weapon Proficiencies include tech weapons."
  secondary_skills:
    count: 3
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "ca-2-light-dead-boy-armor", "plastic-man-full-environmental-body-armor", "urban-warrior-padded-environmental-body-armor"], note: "The book prints light M.D.C. body armor without naming a suit." }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["tinted-goggles", "sunglasses"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "flint", qty: 1 }
  - { item_id: "cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "staff, cane or club", qty: 1, from: ["quarterstaff", "cudgel", "club-stick-pipe"] }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
natural_abilities:
  - name: "Sense Supernatural Evil"
    description: "Automatic, no I.S.P. cost: feels supernatural evil like an icy chill, knowing whether it is near or far and a horrible or lesser evil, but not where. Range 300 feet (91 m) +10 feet per additional level. Also senses possession and recognizes magic enchantment. Base Ability: 50% +5% per additional level."
  - name: "Opening Oneself to the Supernatural"
    description: "Becomes a medium through which entities and spirits can speak; receptive to all telepathic and empathic communication, +10% to receive a Ley Line Transmission while open. The open-state trance leaves him motionless and unable to speak or act, invisible to psionic probes and hard to see: 50% +5% per additional level to go unseen. Even if detected he is +8 to save vs psionic attack and +4 vs magic while in the trance."
  - name: "Sense Death"
    description: "No I.S.P. cost. Senses whether a person has ever killed, roughly how many (one, a few, dozens, hundreds or more), whether he enjoys it and whether he feels remorse, and can usually guess the profession of one stained by death (hero, lawman, hunter, assassin, murderer, soldier, commander). Senses someone heading to or returning from a war. With close contact (touch, face to face talk) or line of sight within 20 feet (6 m) for three minutes, tells whether someone is a vampire or other undead. Senses zombies, mummies, ghouls, banshees and animated dead within 100 feet (30.5 m) +25 feet (7.6 m) per level, without location or numbers."
  - name: "Sense Life"
    description: "No I.S.P. cost. Senses a pregnancy within 72 hours of conception and the child''s sex (or a litter''s size), whether a person is a healer or defender of life, and great good in an individual through close contact. Senses supernatural good within 100 feet (30.5 m) +25 feet (7.6 m) per level, without location or numbers."
  - name: "See Future Possibilities"
    description: "No I.S.P. cost. Looking at a person often (not always) gives vague hints of what is coming - that someone will overcome adversity, miss something important, or is rushing into defeat - and senses a coming confrontation without seeing its outcome."
  - name: "Psionics of the Grey Seer"
    description: "Major psychic (needs 12 or higher to save vs psionics; +1 at levels 4, 8 and 12). Starts with Clairvoyance, Sixth Sense, Empathy and Mind Block. One more Sensitive or Healer power per level from level two, and one Super power at fourth level. I.S.P.: 6D6+6 plus M.E., +1D6+1 per additional level."
  - name: "Intuitive Magic"
    description: "After years of reflection and eight days of fasting and meditation he knows Oracle, Sustain, Life Source, Magic Shield, Armor of Ithan and Tongues, plus two spells of choice from levels 1-2; once chosen they never change. At each later level he gains two spells from levels 1-5. He cannot be taught spells nor buy them and never tries. May use Techno-Wizard devices and the occasional rare scroll."
  - name: "P.P.E."
    description: "1D6x10 plus P.E., +2D6 per additional level. Draws P.P.E. from ley lines, nexus points and other people, as the Line Walker does."
restrictions:
  - "Spell strength: +1 at levels four, eight and twelve (not a sheet bonus)."
  - "Automatic dodge: rolled as normal, but the dodge does not use up a melee action."
  - "Cannot be taught spells nor buy spell knowledge."
  - "Cybernetics: starts with none and avoids augmentation because it interferes with magic; prosthetics are considered if necessary."
extraction_notes: |
  - Rifts World Book 16: Federation of Magic printed 88-91 (cache p089-p092,
    page_offset 1, text layer). The Grey Seers as a people are printed 88-89,
    the O.C.C. powers printed 89-91 and the O.C.C. block printed 91. Cache
    p090 (printed 89) is a welded page, but its prose reads cleanly in order.
  - XP: the Grey Seer ladder on printed 160, read off a render; it chains at
    every level.
  - GROUP: magic, as the Mystic it is a variation of, and the book''s single
    O.C.C.s of the Federation of Magic heading. No S.D.C. formula is printed,
    so men_of_arms: false.
  - PSIONICS: the four automatic powers are the catalog rows by name. The
    book''s Healer category is the catalog''s Healing. The first-level character
    picks no extra power; one Sensitive or Healing pick at every level from
    two, plus one Super pick at four. Sense Supernatural Evil, Opening
    Oneself, Sense Death, Sense Life and See Future Possibilities are class
    abilities with no catalog row (the Mystic''s convention) and are in
    natural_abilities. The +1 save vs psionics at 4, 8 and 12 is stored.
  - MAGIC: the six initial spells are granted by name; two more from levels 1-2
    at creation; two from levels 1-5 at every later level, as a schedule.
  - BONUSES: save vs magic is spell_magic and ritual_magic, the Mystic''s
    convention. The Special Combat Bonuses are stored; automatic dodge is
    stored as automatic_dodge 1, the sheet''s flag row.
  - SKILLS: American as Language: Native Tongue 98 and Literacy: Native
    Language 40+20. One language of choice +15% (no literacy printed). Basic
    & Advanced Math at 45+15. The Lore of choice is a named list of the
    catalog''s Rifts Lore rows, less Lore: Demons & Monsters, which is already
    granted. W.P. Blunt granted.
  - RELATED: Technical''s +15% applies to Art, Language and Lore picks only
    (printed 91, read off a render). Stored as a second, scoped Technical
    entry: Art, Art: Line Drawing and every Language:, Literacy: and Lore: row,
    and a scoped Cowboy entry for the two Lore rows the catalog files there
    (BOOK-INGEST-AUDIT.md F138).
    Horsemanship (General) is filed under Horsemanship in the catalog, sailing
    under Pilot as Boat: Sail Type.
  - MONEY: 2D4x100 credits. The 2D4x100 in tradeable goods is not coin and
    stays in the body.
  - EQUIPMENT: staff, cane or club is a choice of the quarterstaff, cudgel and
    club rows. 50 feet of lightweight cord is one cord entry.
---

## Lore

The Grey Seers are Mystics who broke with Dweomer City and the Federation of
Magic. Their recurring clairvoyant visions say the Federation is doomed to a
bloody repeat of history, drawn into madness by Lord Alistair Dunscon, whom
some Seers believe is one of the prophesied Seven Demons. They want no part of
it.

The Seers keep half a dozen tiny settlements of 20-60 people across the Magic
Zone; the largest, with 120, lies east of Dweomer. They declare themselves
neutral, accept no lord, fight only in self-defense and tend toward pacifism.
Most wander North America, especially the Midwest and Southeast, helping
people in small ways. In return for food, water, supplies and kindness they
serve as oracles, healers, counsellors and advisors. The Councils at Lazlo and
Dweomer value their visions, and they often mediate between Lord Dunscon, the
Lords of Magic and other factions. Because 95% are human psychics, even the
Coalition States tolerate them.

Their famous prophecies include the return of Atlantis, the teacher Erin Tarn,
the Four Horsemen, the Mechanoids, the Federation of Magic''s return, the rise
of the Prosek family, the division of the CS, the return of Psyscape and
"Armageddon in Minnesota."

The Grey Seer O.C.C. is a variation of the Mystic with greater emphasis on
spirituality, healing and psionics. To them the future is fluid, and a small
group or one person can change it. They avoid cybernetics, bionics and most
technology, prefer walking or riding to vehicles and magic or psionics to
energy weapons, and love art, literature, language and philosophy.

## Alignment and Race

Alignment: no restriction, but most lean toward good, unprincipled or aberrant.
Race: none, though most (90%) are human; men and women alike.

## Equipment and Money

Vehicle: none to start; Grey Seers like to walk, and may later acquire a riding
animal or Techno-Wizard vehicle.

Money: little need or desire for it except to help others, and gives away half
of whatever comes in. Starts with 2D4x100 in universal credits and 2D4x100 in
tradeable goods.

## GM Notes

Grey Seers are humble, self-effacing, well-meaning do-gooders with a lust for
life and freedom. Lord Dunscon finds them annoying but tolerates them as
useful, harmless neutrals.
',
       updated_at = datetime('now')
 WHERE class_id = 'grey-seer'
   AND instr(markdown, '- { name: "Technical", only: ["Art", "Art: Line Drawing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }') > 0
   AND length(markdown) = 15852;

-- == pirate ==
UPDATE imported_classes
   SET markdown = '---
id: pirate
men_of_arms: true
occ_group: men-of-arms
name: Pirate
system: rifts
category: occ
tags: [combat]
source_book: Rifts World Book 6: South America p.47-48
attribute_requirements: { PS: 7, PP: 8 }
starting_money: "1d4x1000"
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 31001, 41001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
bonuses:
  attributes: { PE: "1d4" }
  pools: { sdc: "2d6+6" }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Two Languages (+10%). Taken once per language - the picker asks which." }
    - { choose: 2, from: ["Boat: Paddle Types/Canoe/Kayak", "Boat: Sail Type", "Boat: Motor, Race & Hydrofoil", "Boat: Ships", "Boat: Submersibles"], bonus: 15, note: "Boat: two types (+15%). The five Boat rows the catalog holds." }
    - { name: "Fishing", base: 45, per_level: 5, note: "+5%." }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%." }
    - { name: "Ship Mechanics", base: 30, per_level: 5, note: "Printed as Ship Mechanics (treat like Aircraft Mechanics; +5%): Aircraft Mechanics'' 25% +5%/level, plus the class''s 5%." }
    - { name: "Swimming", base: 70, per_level: 5, note: "+20%." }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts (or Assassin if an evil alignment) for the cost of one O.C.C. Related skill." }
  occ_related_skills:
    count: 7
    minimums:
      - { count: 1, categories: ["Pilot", "Pilot Related"] }
      - { count: 1, category: "Physical" }
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 15 }
      - "Mechanical"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", bonus: 12 }
      - { name: "Science", only: ["Mathematics: Basic", "Anthropology", "Astronomy"], bonus: 5 }
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Select seven; at least one must be Pilot or Pilot Related and one Physical. Military: none. Technical: Any, +10% to lores and languages only. Physical +5% where applicable."
  secondary_skills:
    count: 3
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 9, count: 2 }
      - { level: 13, count: 2 }
    note: "Three at level one, plus two more at levels three, five, nine and thirteen, from the same list without the bonuses in parentheses. The only-limits above still apply."
equipment_starting:
  - { choose: 2, label: "energy weapon of choice", qty: 1, from: ["rc-10-laser-pistol", "rc-15-laser-rifle", "dragon-1-plasma-projector", "c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "l-20-pulse-rifle"], note: "The book says of choice without enumerating; South America''s own energy weapons plus common Rifts ones." }
  - { choose: 2, label: "archaic weapon", qty: 1, from: ["cutlass", "sabre", "short-sword", "broadsword", "knife", "survival-knife", "axe-battle"], note: "The book says two archaic weapons without enumerating." }
  - { choose: 1, label: "suit of M.D.C. body armor", qty: 1, from: ["huntsman-armor", "urban-warrior-padded-environmental-body-armor", "bushman-full-composite-environmental-body-armor", "plastic-man-full-environmental-body-armor", "gladiator-full-environmental-body-armor"] }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "handcuffs-regular", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "grappling-hook-and-line-100-feet-30-m", qty: 1, note: "100 feet (30.5 m) of rope and a grappling hook." }
restrictions: []
extraction_notes: |
  - Read from the South America text layer (cache p048-p049) and checked against
    renders of printed 47 and 48; every percentage and die code agreed with the ink.
    The lore and the first three O.C.C. skills are at the foot of printed 47, the
    rest of the block on printed 48.
  - NO GROUP HEADING. The book files the Pirate and the Sailor under a bare "New
    O.C.C.s" heading in the pirates chapter and names no Men of Arms / Adventurers
    split. men_of_arms: true is a judgement: Hand to Hand: Expert as issued, four
    W.P.s, P.S./P.P. minimums and a raiding trade - the same call the Phase World
    Space Pirate carries. occ_group men-of-arms for the same reason.
  - S.D.C. is printed as "Add 2D6+6 to S.D.C.", an addition to the core roll, so
    it is a pool bonus and not sdc_base. "+1D4 to P.E." is an attribute bonus.
  - SHIP MECHANICS had no catalog row. The book says to treat it like Aircraft
    Mechanics (printed 48), so add-ship-mechanics-skill.sql adds a Mechanical
    row copying Aircraft Mechanics'' 25% +5%/level, shared with the Sailor.
    Granted by its own name at 30% (25 + the printed 5%).
  - "Boat: Two types (+15%)" is a choice of two from the five Boat rows in the
    catalog. Military: Warships & Patrol Boats is not offered - the book says Boat.
  - "Science: Math: basic, anthropology and astronomy only" - stored against
    Mathematics: Basic, Anthropology and Astronomy (not Astronomy & Navigation,
    which is a separate row).
  - "Technical: Any (+10% to lores and languages)" (printed 48, read off a
    render) - stored as a second, scoped Technical entry for every Language:,
    Literacy: and Lore: row, and a second Communications entry at +10 for the
    Literacy: rows and Language: Dolphin/Whale the catalog files there
    (BOOK-INGEST-AUDIT.md F138).
  - Hand to Hand: Expert is issued; Martial Arts, or Assassin if evil, costs one
    other skill each. Stored as the hand_to_hand block with the alignment as a
    condition.
  - MONEY: 1D4x1000 credits is stored. The 3D4x1000 in saleable black market
    items is not coin and has no rows to point at; in the GM Notes.
  - EQUIPMENT: the two energy weapons, two archaic weapons and the armor are
    "of choice" in the book; the lists offered are drawn from the catalog. The
    MESS KIT is not imported - the catalog has no row for it, the same decision
    the Imperial Legionnaire recorded. Handcuffs use the generic
    handcuffs-regular row.
  - CYBERNETICS: 1D4 implants, and later bio-wizardry for wealthy pirates, are
    not stored; in the GM Notes.
  - Alignment is advisory (usually selfish or evil) and not stored as a
    restriction.
  - Experience: the "Pirate & Lizard Man" ladder on printed 168 (the text layer
    reads "Lizard Map"), transcribed from a render; lower bounds stored.
---

## Lore

Piracy is as old as sea travel. On Rifts Earth pirates hunt other ships, raid
coastal towns and merchant caravans, and some bands push armed parties as far as
a hundred miles inland after a rich target. Pay is usually a share of the booty:
large operations pay the crew a fraction of a percent while the captain and first
mate take the lion''s share, and smaller crews split the plunder into shares, with
food and a berth aboard provided free.

Some pirates become privateers, licensed by a coastal kingdom to prey on its
rivals in return for a cut of the plunder and a safe harbour for repairs. A few
bands pick only rich or tyrannical targets, Robin Hoods of the sea, but most are
brigands with little regard for life. Around half of all pirate profit comes from
the slave trade, selling captives to the Splugorth, and only the most evil will
run slaves.

A pirate crew is a mixed company: at least a fifth are Sailors, and juicers,
headhunters, city rats, operators and smugglers are common among them.

## GM Notes

**Alignment.** Usually selfish or evil; good pirates are almost unheard of and
are typically privateers or Robin Hood types.

**The money line has two halves.** 1D4x1000 credits is on the sheet. The pirate
also starts with 3D4x1000 credits'' worth of saleable black market items; roll and
decide what they are at the table.

**Mess kit** is part of the standard issue and has no catalog row.

**Cybernetics.** A pirate may have 1D4 cybernetic implants; contact with the
Splugorth makes them easier to come by than elsewhere in South America. Wealthy
pirates past first level can afford bio-wizardry treatments (see Rifts Atlantis).
None of this is on the sheet.
',
       updated_at = datetime('now')
 WHERE class_id = 'pirate'
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0
   AND length(markdown) = 8923;

-- == sailor ==
UPDATE imported_classes
   SET markdown = '---
id: sailor
men_of_arms: true
occ_group: men-of-arms
name: Sailor
system: rifts
source_book: Rifts World Book 6: South America p.46-47
category: occ
tags: [pilot, beginner]
attribute_requirements:
  PS: 7
starting_money: "1d6x100"
xp_table: [0, 1881, 3781, 7261, 14201, 21001, 31001, 41001, 52001, 72001, 102001, 137001, 187001, 237001, 287001]
bonuses:
  attributes: { PE: "1d4" }
  pools: { sdc: 10 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Two languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Boat: Sail Type", base: 75, per_level: 5, note: "+15%" }
    - { name: "Boat: Motor, Race & Hydrofoil", base: 65, per_level: 5, note: "Printed as Boat: Motor and Hydrofoils (+10% each); the catalog holds one row for both." }
    - { name: "Boat: Ships", base: 65, per_level: 5, note: "+20%" }
    - { name: "Fishing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Ship Mechanics", base: 30, per_level: 5, note: "+5%. Works the same as Aircraft Mechanics, applied to boats and ships (printed 48)." }
    - { name: "Swimming", base: 70, per_level: 5, note: "+20%" }
    - { name: "Boat Building", base: 30, per_level: 5, note: "+5%" }
    - { name: "Carpentry", base: 30, per_level: 5, note: "+5%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: One of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if an evil alignment) for the cost of two." }
  occ_related_skills:
    count: 8
    minimums:
      - { count: 1, category: "Pilot Related" }
      - { count: 1, category: "Physical" }
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Mechanical"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", bonus: 8 }
      - { name: "Science", only: ["Mathematics: Basic", "Anthropology", "Astronomy"], bonus: 10 }
      - "Technical"
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "At least one must be Pilot Related and one Physical. Communications: Any (+5%). Domestic: Any (+5%). Electrical: Basic Electronics only. Espionage: Any. Mechanical: Any. Medical: First Aid and Holistic Medicine only. Military: None. Physical: Any (+5% where applicable). Pilot: Any (+5%). Pilot Related: Any (+10%). Rogue: Any (+8%). Science: Basic Math, Anthropology and Astronomy only (+10%). Technical: Any (+10% to Lore and Language skills only). W.P.: Any. Wilderness: Any (+5%)."
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 2 }
      - { level: 6, count: 2 }
      - { level: 8, count: 2 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1, label: "Light M.D.C. body armor with built-in floaters" }
  - { item_id: "fishing-line-and-hooks", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
restrictions: ["Military skills: none"]
extraction_notes: |
  - Printed 46-47 (cache p047-p048), rendered at 130 dpi and read against the
    ink; the text layer matched on every number. Ladder "Sailor & Felinoid
    Mutant", printed 168, rendered: lower bounds 0, 1,881 ... 287,001.
  - Grouping: men_of_arms true / occ_group men-of-arms. The book gives no
    heading grouping for its two new O.C.C.s ("New O.C.C.s", printed 46); the
    survey classes the Sailor as plain men of arms, and the class is a
    physical, W.P.-and-Hand-to-Hand occupation with no powers. It states only
    "+10 to S.D.C.", stored as pools.sdc 10 on top of the men-of-arms 3D6 core.
  - "1D4 to P.E. attribute" is stored as bonuses.attributes PE "1d4".
  - Attribute Requirements: P.S. 7 stored. "A good P.P. and P.E. is ideal" is
    advice, not a requirement, and is not stored.
  - Ship Mechanics: the book prints "Ship Mechanics (treat like Aircraft
    Mechanics; +5%)" and defines no Ship Mechanics skill anywhere (survey:
    no new skills in this book). Production has no Ship Mechanics row and no
    redirect for the name (checked --remote 2026-09-25). Decision (shared
    with the Pirate): add-ship-mechanics-skill.sql adds a Ship Mechanics row
    copying Aircraft Mechanics'' Mechanical 25% +5%/level and citing printed 48;
    granted here at 25+5 = 30%.
  - "Boat: Motor and Hydrofoils (+10% each)" maps to the catalog''s single row
    Boat: Motor, Race & Hydrofoil (a redirect from the printed name already
    exists), 55+10 = 65%. "each" is read as the book naming two craft that
    the catalog holds as one skill; one grant, not two.
  - Pilot: the book prints "Pilot: Any (5%)" with no plus sign (ink checked);
    stored as a +5% category bonus, the same form as every other line.
  - Technical: "Any (+10% to lores and languages)" (printed 47, read off a
    render) - the bonus applies only to Lore and Language picks. Stored as a
    second, scoped Technical entry for every Language:, Literacy: and Lore:
    row, and a second Communications entry at +10 for the Literacy: rows and
    Language: Dolphin/Whale the catalog files there (BOOK-INGEST-AUDIT.md F138).
  - "at least one has to be pilot related and one physical" stored as two
    minimums; "pilot related" read literally as the Pilot Related category
    (the Pirate''s page says "pilot or pilot related", the Sailor''s does not).
  - Military: None - the category is omitted; also in restrictions.
  - Secondary skills: four at level one, plus two more at levels 4, 6 and 8.
  - Money: "1D6X100 credits and 2D6X1000 in black market saleable items."
    starting_money holds the credits; the saleable items stay prose (coin only).
  - Equipment: the light M.D.C. body armor is light-mdc-body-armor; its
    built-in floaters (+10% to cost, -5% prowl, can swim in armor) are prose.
    "Two weapons of choice (usually nothing larger than an energy rifle and
    an archaic weapon like a knife)" is too open for a choice list and stays
    prose. The mess kit has no catalog row and
    is not imported, as with the Pirate; it is named in the equipment prose.
  - Cybernetics: starts with none; may or may not oppose them. Prose.
  - Alignment: Any.
---

## Lore

South America is cut into hundreds of islands and laced with rivers, so its people depend on water travel, and a whole class of sailors has grown up around it. Depending on where they learned their trade, a sailor may know simple square-rigged sailing boats, nuclear-powered submersibles, or anything in between.

A Rifts Earth sailor has to be traveller, warrior and explorer at once. Ships face sea serpents, harpies, pirates and magic, as well as storms, fog, reefs, ice, heat, hunger and loneliness. The lure is adventure, strange ports and far-off lands; many sailors signed on to escape poverty, an enemy or the law.

Many hope to save enough to retire or to captain a ship of their own; others live for the day. Pay depends on skill, experience and the length of the voyage, and captains often hold back wages until the trip ends to discourage desertion. Aboard ship, the captain and officers are the law.

## Starting Equipment

Light M.D.C. body armor with built-in floaters (adds 10% to the armor''s cost and reduces Prowl by 5%, but lets the wearer swim in it), two weapons of choice (usually nothing bigger than an energy rifle, plus an archaic weapon such as a knife), fishing line and hooks, compass, flashlight, backpack, knapsack and mess kit.

Money: 1D6x100 credits plus 2D6x1000 credits'' worth of black market saleable items.

Cybernetics: starts with none. May or may not be opposed to cybernetics and bionics.
',
       updated_at = datetime('now')
 WHERE class_id = 'sailor'
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0
   AND length(markdown) = 8430;

-- == monkey-boy-tech ==
UPDATE imported_classes
   SET markdown = '---
id: monkey-boy-tech
name: Monkey Boy Tech
system: rifts
source_book: Rifts World Book 13: Lone Star p.85
category: rcc
tags: [tech, scholar]
xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]
attribute_dice:
  IQ: "2d6+7"
  ME: "3d6"
  MA: "2d6+8"
  PS: "4d6+10"
  PP: "2d6+6"
  PE: "2d6+8"
  PB: "2d6+2"
  Spd: "2d6+6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "P.E. x2"
ppe_base: "6d6"
bonuses:
  attributes: { IQ: "1d6+1", MA: "1d4", ME: "1d4" }
  combat: { attacks: 1, initiative: 2, dodge: 2, roll: 3 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Climbing", base: 75, per_level: 0, note: "Natural ability: Climb 75%/65%. Not a trained skill; the book prints no per level gain." }
    - { name: "Gymnastics", base: 60, per_level: 0, note: "Natural ability: Gymnastics 60%. Not a trained skill; the book prints no per level gain." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks American at 98% efficiency." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Is literate in American at 98% efficiency." }
    - { choose: 1, from: ["Language: Spanish", "Language: Euro", "Language: Chinese", "Language: Dragonese", "Language: Gobblely", "Language: Demongogian", "Language: Other"], bonus: 20, note: "Language: speaks one of choice (+20%). Language: Other covers any tongue not listed." }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "Basic Math (+30%)." }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "Advanced Math (+20%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Electrical"], note: "Two Electrical skills of choice." }
    - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
    - { name: "Chemistry", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to Hand: Basic; no others are available." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Communications", only: ["Cryptography", "Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 15 }
      - "Domestic"
      - { name: "Electrical", bonus: 15 }
      - { name: "Espionage", only: ["Forgery"], bonus: 10 }
      - { name: "Espionage", only: ["Intelligence"], bonus: 5 }
      - { name: "Mechanical", bonus: 15 }
      - { name: "Medical", bonus: 10 }
      - { name: "Military", only: ["Military Etiquette"] }
      - { name: "Physical", except: ["Boxing", "Acrobatics", "Hand to Hand: Basic", "Hand to Hand: Expert", "Hand to Hand: Martial Arts", "Hand to Hand: Assassin", "Hand to Hand: Commando"] }
      - { name: "Rogue", except: ["Streetwise"] }
      - { name: "Rogue", only: ["Computer Hacking"], bonus: 10 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 15 }
      - "Weapon Proficiencies"
    note: "The book calls these other skills. Communications: any (+10%; Cryptography is +15%). Domestic: any. Electrical: any (+15%). Espionage: Forgery (+10%) and Intelligence (+5%) only. Mechanical: any (+15%). Medical: any (+10%). Military: Etiquette only. Physical: any except Boxing, Acrobatics and Hand to Hand. Rogue: any except Streetwise (Computer Hacking is +10%). Science: any (+10%). Technical: any (+10%; language skills are +15%). W.P.: any. Pilot, Pilot Related and Wilderness: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - { name: "Espionage", only: ["Forgery", "Intelligence"] }
      - "Mechanical"
      - "Medical"
      - { name: "Military", only: ["Military Etiquette"] }
      - { name: "Physical", except: ["Boxing", "Acrobatics", "Hand to Hand: Basic", "Hand to Hand: Expert", "Hand to Hand: Martial Arts", "Hand to Hand: Assassin", "Hand to Hand: Commando"] }
      - { name: "Rogue", except: ["Streetwise"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 12, count: 2 }
      - { level: 14, count: 2 }
natural_abilities:
  - { name: "Size and Build", description: "A genetically enhanced chimpanzee. Looks like a typical chimpanzee; those with special genetic modifications may be taller, stand straighter and have somewhat more human proportions. Weight 70-90 pounds (31.7 to 40.8 kg), typically doubled for genetically altered, larger, more human-like apes. Height 3-4 feet (0.9 to 1.2 m) without genetic alteration, 5-6 feet (1.5 to 1.8 m) with. Prehensile feet, no tail, double jointed." }
  - { name: "Human Speech and Life Span", description: "Speech is very good to excellent, better than most Dog Boys and often almost human, though they may still chatter and howl when angry or excited. Average life span an estimated 40-55 years." }
  - { name: "Climbing and Gymnastics", description: "Natural, skill-like abilities held in addition to R.C.C. skill training: Climb 75%/65% and Gymnastics 60%." }
  - { name: "Leap and Brachiation", description: "Can leap 4 feet (1.2 m) up and 8 feet (2.4 m) across; lengthwise leaps increase by 20% with a running or swing start. Can run, leap and swing through trees at about their running speed (the page''s wording on printed 84 is garbled and may mean double, as the Mini Monkey Spy''s entry on printed 82 says outright); about half speed for gorillas." }
  - { name: "Sense of Smell", description: "50% better than a human''s." }
  - { name: "Identify Edible Plants", description: "Identify edible plants, fruits, nuts, leaves and roots 70%; edible for apes, that is." }
  - { name: "Natural Combat Bonuses", description: "+1 attack per melee round, +2 on initiative, +2 to dodge on the ground or in trees, +3 to roll with fall or impact." }
  - { name: "Psionics", description: "30% are minor psionics and 10% are major; roughly the same as humans." }
  - { name: "Facility Access", description: "In place of a kit of gear, a Tech has complete access to Doctor Bradford''s secret GED facility." }
variants:
  - id: medical
    name: "Medical training"
    skills_additional:
      occ_skills:
        - { choose: 3, categories: ["Medical"], note: "Three Medical skills of choice (taken in place of four Mechanical skills)." }
  - id: mechanical
    name: "Mechanical training"
    skills_additional:
      occ_skills:
        - { choose: 4, categories: ["Mechanical"], note: "Four Mechanical skills of choice (taken in place of three Medical skills)." }
trackable_resources: []
restrictions:
  - "Race: genetically enhanced chimpanzees only. An illegal, unauthorized and secret cadre of mutants; there is no record of them existing."
  - "R.C.C. requirements: none, other than being a relatively intelligent, loyal and obedient mutant animal."
  - "A player character who is not in service must be a feral renegade or the free-born offspring of runaway mutants, hunted and destroyed by the Coalition. Thus far no Monkey Boy Tech has ever escaped; 95% do not want to leave."
  - "Alignment: any."
  - "Magic: none. Feral and free born chimpanzees are fascinated by magic and may study the mystic arts (any); a free born mage forsakes this R.C.C. and instead selects the skills of the appropriate magic O.C.C., keeping the natural abilities."
  - "Hand to Hand: Basic only; no other style is available."
  - "No Pilot, Pilot Related or Wilderness skills. A runaway or free born can learn to pilot any vehicle a human can, and learn any Wilderness or Rogue skills, as secondary skills."
  - "Cybernetics: generally none to start."
extraction_notes: "WB13 Lone Star printed 85 (cache p086, cache page = printed folio + 1), read off a 170 dpi render. The entry says Monkey Boy Techs are fundamentally the same as the Monkey Boy Grunts (the Monkey Boy Soldier R.C.C., printed 83-85) with listed modifications; this class restates the Soldier so it stands alone and pairs with no race. || FROM THE SOLDIER (printed 83-84), unchanged: the attribute dice (I.Q. 2D6+7, M.E. 3D6, M.A. 2D6+8, P.S. 4D6+10, P.P. 2D6+6, P.E. 2D6+8, P.B. 2D6+2, Spd 2D6+6), hit points P.E. plus 1D6 per level and S.D.C. P.E. x2 (the chimpanzee figures, since the Tech is a chimpanzee; the Soldier''s gorilla figures and gorilla notes are left out), P.P.E. 6D6, the Natural Abilities and Bonuses (Climb 75%/65%, Gymnastics 60%, smell, leap, tree travel, edible plants 70%, prehensile feet, double jointed, +1 attack, +2 initiative, +2 dodge, +3 roll), size, speech, life span, alignment any, the R.C.C. requirement, the player character note, the magic paragraph and the cybernetics line (first clause only; the percentages of bionic extras, ''Borgs and Crazies describe the military test animals). || CHANGED BY THE TECH ENTRY: Race (genetically enhanced chimpanzees). Attribute Bonuses I.Q. +1D6+1, M.A. +1D4, M.E. +1D4, stored as bonuses.attributes dice on top of the Soldier''s dice. Psionics (30% minor, 10% major, roughly the same as humans; no powers or I.S.P. printed, so text only). R.C.C. Skills (the Tech''s own list replaces the Soldier''s). R.C.C. Related Skills and Secondary Skills (own counts and lists). Equipment (complete access to the secret GED facility; no item list, so no equipment_starting, and the sentence is a natural ability line). Experience ladder. || NOT CARRIED: the Soldier''s Penalties and Other Considerations (about life in the CS military), Equipment Available Upon Assignment, the 60-100 credit monthly salary, identification coding, typical missions and maximum rank all describe the military grunt; the Tech entry does not restate them and the general text says no record of the Techs exists. No starting_money stored; the book prints no sum for the Tech. || HEADING: Monkey Boy Tech R.C.C. under Monkey Boys, an engineered mutant animal and a race. sdc_base is stated (a formula on P.E., printed without ''plus those gained from skills''), so there is no men_of_arms line. || XP: the ladder headed Monkey Boy Tech, Simvan Monster Rider on the unnumbered Experience Tables page after printed 174 (cache p176). || NATURAL SKILLS: Climbing 75 and Gymnastics 60 at per_level 0, as on the Soldier (judgement: printed as flat natural abilities). || SKILLS: Speaks and is literate in American at 98%: Language: Native Tongue 98 and Literacy: Native Language 98, per_level 0. Language: speaks one of choice (+20%) as a choice of one from the catalog''s Rifts tongues plus Language: Other, bonus 20. Basic Math 45+30 = 75. Advanced Math 45+20 = 65. Radio: Basic 45+10 = 55. Biology 30+20 = 50. Chemistry 30+20 = 50. Two Electrical skills of choice, one W.P. of choice. ''Three Medical or four Mechanical skills of choice'' is an either/or; stored as two variants, Medical training (three Medical picks) and Mechanical training (four Mechanical picks), each adding its choice group to the common list. Hand to Hand: Basic, no others available: hand_to_hand costs is empty. || RELATED: five, plus one at levels 3, 6, 9 and 12. Communications +10 with Cryptography printed at +15; Espionage is Forgery (+10%) and Intelligence (+5%) only; Rogue any except Streetwise with +10% to Computer Hacking only and no category bonus; Technical +10 with language skills printed at +15. Each per-skill figure is a second, scoped entry for its category (BOOK-INGEST-AUDIT.md F138); the language one reaches every Language: and Literacy: row, and the Literacy: rows and Language: Dolphin/Whale the catalog files under Communications. Physical ''except boxing, acrobatics and hand to hand'' stored as an except list naming those rows. Pilot, Pilot Related and Wilderness: none. Secondary: five at level one, plus two at levels 2, 4, 8, 10, 12 and 14, same list without bonuses. The runaway and free born allowance is a restriction line. || OPTIONAL DOG BOY TABLES: neither the general Monkey Boys text, the Soldier entry nor this entry mentions the Optional Dog Boy tables, so no restriction line is written for them."
---

## Lore

The Coalition trains its mutant chimpanzees as foot soldiers and forbids them
books, machines and science. The head of the Lone Star genetics program thinks
that is a waste, because chimpanzees turn out to have a real gift for numbers,
tools, repair and engineering, and they enjoy hard problems and company while
they solve them.

So he keeps his own. About forty enhanced chimpanzees work on the hidden level
of the complex as researchers, engineers and medics, off every official roster.
Unlike nearly everything else made there, nothing artificial binds them to him:
they are literate, educated, free-thinking, and almost all of them like the
work too much to want out.

## GM Notes

Choose the variant for the Tech''s schooling: Medical training gives three
Medical skills of choice, Mechanical training gives four Mechanical skills.
The book offers one or the other.

The book prints 30% of Techs as minor psionics and 10% as major, with no
powers or I.S.P. listed; use the main rule book''s rules for psychic humans if
the roll comes up. A Tech has no personal kit and no pay on record: its gear is
whatever the secret facility holds. Climb and Gymnastics are flat natural
percentages and do not rise with level.
',
       updated_at = datetime('now')
 WHERE class_id = 'monkey-boy-tech'
   AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0
   AND length(markdown) = 13665;

-- == necromancer ==
UPDATE imported_classes
   SET markdown = '---
id: necromancer
name: Necromancer
system: rifts
source_book: Rifts World Book 4: Africa p.99-104
category: occ
tags: []
occ_group: magic
men_of_arms: false
xp_table: [0, 2201, 4401, 8801, 17601, 27701, 37801, 53901, 75101, 100201, 140301, 200401, 250501, 300601, 350921]
attribute_requirements: { IQ: 10, ME: 10, PE: 12 }
ppe_base: "2d4x10 plus the P.E. attribute number, and 2d6 more per additional level of experience"
starting_money: "2d6x1000"
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { name: "Literacy: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "One additional language spoken and read, plus one more language spoken only (+20% each)" }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literacy in the first of the two additional languages (+20%)" }
    - { name: "Lore: Demons & Monsters", bonus: 20, note: "The book prints ''Lore: Monsters & Demons (+20%)''; the catalog row is Lore: Demons & Monsters." }
    - { name: "Mathematics: Basic", bonus: 20, note: "The book prints ''Basic Math (+20%)''." }
    - { name: "Wilderness Survival", bonus: 5, note: "Wilderness Survival (+5%)" }
    - { name: "Skin & Prepare Animal Hides", bonus: 5, note: "The book prints ''Skin and Prepare Animal Hides & Bones (+5%)''; the catalog row is Skin & Prepare Animal Hides." }
    - { choose: 1, from: ["Hover Craft (ground)", "Horsemanship: General"], bonus: 10, note: "Pilot Hover Craft or Horsemanship (+10%)" }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. Knife or Sword" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Weapon of choice" }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], note: "Disguise, forgery and intelligence only." }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", bonus: 2 }
      - { name: "Pilot Related", bonus: 2 }
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - "Technical"
      - { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 6
    schedule: []
magic:
  type: "spell"
  spells_starting: 12
  spells_starting_groups:
    - { count: 6, from_list: "necromancy", note: "Six necromancy spells, regardless of level." }
    - { count: 6, from_list: "necro_common", note: "Six common spells associated with necromancy, from the book''s Available Common Spell Magic list (levels 1-15). The book states no level cap on these picks." }
  spell_lists:
    necromancy:
      - "Necromancy: Stench of the Dead"
      - "Necromancy: Object Read the Dead"
      - "Necromancy: Recognize the Undead"
      - "Necromancy: Command Ghouls"
      - "Necromancy: Kill Plants"
      - "Necromancy: Consuming Power & Knowledge"
      - "Necromancy: Death Mask"
      - "Necromancy: Divining: Tombs & Graves"
      - "Necromancy: Maggots"
      - "Necromancy: Death Strike"
      - "Necromancy: Shadows of Death"
      - "Necromancy: Shadows of Doom"
      - "Necromancy: Strength of the Dead"
      - "Necromancy: Summon Insect Swarm"
      - "Necromancy: Summon Vampires"
      - "Necromancy: Transfer Life Force"
      - "Necromancy: Summon Worms of Taut"
      - "Necromancy: Summon Magot"
    necro_common:
      - "Death Trance"
      - "Globe of Daylight"
      - "Sense Evil"
      - "Sense Magic"
      - "Concealment"
      - "Detect Concealment"
      - "Fear"
      - "Turn Dead"
      - "Breathe Without Air"
      - "Fuel Flame"
      - "Ignite Fire"
      - "Ley Line Transmission"
      - "Magic Net"
      - "Repel Animals"
      - "Shadow Meld"
      - "Trance"
      - "Circle of Flame"
      - "Horrific Illusion"
      - "Fire Ball"
      - "Mask of Deceit"
      - "Tongues"
      - "Animate and Control Dead"
      - "Constrain Being"
      - "Life Drain"
      - "Commune with Spirits"
      - "Exorcism"
      - "Luck Curse"
      - "Minor Curse"
      - "Sickness"
      - "Spoil"
      - "Protection Circle: Simple"
      - "Banishment"
      - "Control & Enslave Entity"
      - "Create Mummy"
      - "Create Zombie"
      - "Sanctum"
      - "Restoration"
      - "Transformation"
bonuses:
  attributes: { ME: 1, PE: 1, PS: 1, Spd: 4 }
  pools: { sdc: 10 }
  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1 }
equipment_starting:
  - { item_id: "robe", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 100 }
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "large-sack", qty: "2d4" }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "shovel", qty: 2 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "wilk-s-laser-scalpel", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "short-sword", qty: 1 }
  - { item_id: "wooden-stake", qty: "2d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "hand-held-flares", qty: 12 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
  - { item_id: "e-clip", qty: "1d6" }
special_abilities:
  - name: "Union with the Dead"
    description: "By tying an animal''s claw, hoof or tentacle (skeletal, or freshly slain and severed) to his own hand, forearm or foot and speaking an incantation known only to this O.C.C., the necromancer transforms that limb into the creature''s appendage, gaining its combat bonuses and abilities. P.P.E. cost varies by type (see the options below); self only by touch, and from 5th level he can do it to others at half duration. Duration 10 minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round (15 seconds). Works only on the living. The limb is always proportional to the mage; any combination of limbs may be transformed. The options are the fifteen abilities that follow, each with its own P.P.E. cost (printed 100-101)."
  - name: "Union: Tentacle (10 P.P.E.)"
    description: "10 P.P.E.. Covers octopus, squid and a variety of monsters. +1 to strike, +20% to climb using suction cups, +3 to damage, and can pin or entangle an opponent. (Printed 100.)"
  - name: "Union: Rodent''s Claws/Feet (10 P.P.E.)"
    description: "10 P.P.E.. Covers rats, mice, squirrels, rabbits and similar small animals. +1 to strike and parry, +2 to damage (S.D.C.), +10% to climb. The claws have an opposable thumb and fingers, so tools and weapons can be used, roughly equal to human hands. (Printed 100.)"
  - name: "Union: Cat and Other Feline Claws (20 P.P.E.)"
    description: "20 P.P.E.. +2 to strike and parry, +8 to damage (S.D.C.), +20% to climb and +10% to prowl. The claws retract but have no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Canine Claws (10 P.P.E.)"
    description: "10 P.P.E.. +1 to parry and +4 to damage (S.D.C.). No opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bear, Badger, Wolverine and Similar Large Claws (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and +1 to parry, +10 to damage (S.D.C.), and +5% to climb. Excellent for digging, but no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bird Claws/Talons (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and parry, +8 to damage (S.D.C.). The claws can grasp tools and use weapons at -1 to strike or parry; using modern or complicated devices carries a skill penalty of -20%. (Printed 101.)"
  - name: "Union: Dragon Claws (50 P.P.E.)"
    description: "50 P.P.E.. Dragon claws of any kind: +1 to strike, +1 to parry, inflict 4D6 M.D., make the necromancer impervious to fire, and give a physical M.D.C. of 12 from hatchlings and 30 from adult dragons. (Printed 101.)"
  - name: "Union: Claws of Other Creatures of Magic and Supernatural Monsters (35 P.P.E.)"
    description: "35 P.P.E.. Claws of other creatures of magic and supernatural monsters, including manticore, sphinx, za, sowki, mindolar, ghouls, gargoyles and other so-called demons and others: inflict 2D6 M.D. and give the necromancer 8 M.D.C.; no strike or parry bonuses. (Printed 101.)"
  - name: "Union: Claws of a Non-Supernatural Mega-Damage Creature (20 P.P.E.)"
    description: "20 P.P.E.. Claws of a non-supernatural mega-damage creature such as the melech, peryton and loogaroo: inflict 1D6 mega-damage points; no M.D.C. or bonuses. (Printed 101.)"
  - name: "Union: Hooves (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option. Hooves of any kind (horse, ox, cow, deer, etc.) add +20 to the speed attribute and allow a leap of 10 feet (3 m) high or lengthwise. (Printed 101.)"
  - name: "Union: Rhinoceros or Elephant Feet (20 P.P.E.)"
    description: "20 P.P.E.. Feet/legs option. +10 to the normal speed attribute, but can also run for a short period of 30 seconds (two melee rounds) at +40. A kick or stomp inflicts 4D6 S.D.C. damage. (Printed 101.)"
  - name: "Union: Kilin Hooves (25 P.P.E.)"
    description: "25 P.P.E.. Feet/legs option. +30 to the speed attribute, can leap 10 feet (3 m) high or lengthwise, and kick attacks inflict 1D6 M.D. (Printed 101.)"
  - name: "Union: Unicorn Hooves (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +40 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 2D6 M.D. (Printed 101.)"
  - name: "Union: Dragon Feet/Claws (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +20 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 4D6 M.D. (Printed 101.)"
  - name: "Union: Monkey, Ape or Humanoid Hands (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option: hands in place of feet. +20% to climb, +5% to acrobatics, and the feet are equivalent to hands and can grasp and use weapons, tools and devices. The character''s normal speed is reduced by half. (Printed 101.)"
  - name: "Augmentation and Additional Appendages"
    description: "The necromancer can temporarily strap limbs of dead creatures, people and animals to his body and animate them as his own: up to three additional pairs of arms and two additional pairs of legs, or wings, a tail and horns in any combination, to a total of six additional appendages (a tail or a single horn counts as one, a pair of wings as two, one giant limb as two normal ones). The sight adds +2 to his Horror Factor. P.P.E. cost varies (options below); self only by touch, and from 8th level he can do it to others at half duration. Duration five minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round. The added dead limbs keep their dead appearance and cannot themselves be transformed by Union with the Dead, though his own limbs can. The options are the eleven abilities that follow, each with its own P.P.E. cost (printed 101-102)."
  - name: "Augmentation: Additional Arms or Tentacles (10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs)"
    description: "10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs. Each additional pair of arms or tentacles adds one physical attack or action per melee round and a bonus of +1 to strike and parry. Three additional pairs can be added, for a possible total of eight arms (two natural and six skeleton limbs); limbs can be human, D-bee, ape or animal, and one giant limb counts as two normal sized limbs. Limbs of a mega-damage creature carry that creature''s strength and inflict its usual mega-damage. (Printed 101.)"
  - name: "Augmentation: Horn(s) (4 P.P.E. each)"
    description: "4 P.P.E. each. Horns are a weapon for head-butting and ramming. A single horn inflicts 1D4 S.D.C. and a pair does 2D4 damage; both add six points to the character''s physical S.D.C. (Printed 102.)"
  - name: "Augmentation: Rhinoceros Horn (8 P.P.E.)"
    description: "8 P.P.E.. The horn inflicts 3D6 S.D.C. and gives keen hearing (+1 on initiative) and a keen sense of smell (55% to track by smell), plus an extra 20 S.D.C. to the wearer. (Printed 102.)"
  - name: "Augmentation: Unicorn Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D6 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), keen color vision, prowl 50%, +1 on initiative, and never tiring. (Printed 102.)"
  - name: "Augmentation: Kilin Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D4 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), healing touch (four times, restoring 1D8 HP and 2D8 S.D.C.), and sense evil as an automatic sensation. (Printed 102.)"
  - name: "Augmentation: Dragon Horn (30 P.P.E.)"
    description: "30 P.P.E.. One horn inflicts 2D4 M.D. and gives 25 M.D.C. to the character wearing it. Two or more horns do 2D6 M.D. and each additional horn adds another 10 M.D.C. points. (Printed 102.)"
  - name: "Augmentation: Dragon Tail (20 P.P.E.)"
    description: "20 P.P.E.. Provides one additional attack per melee and inflicts 2D6 M.D. per strike. (Printed 102.)"
  - name: "Augmentation: Dragon Skull (50 P.P.E.)"
    description: "50 P.P.E.. Often worn as a helmet or ceremonial headdress called the dragon helm. Gives 20 M.D.C., understanding and speech of all languages, reading and writing dragonese/elf, imperviousness to fire, resistance to cold, and whatever breath weapon (if any) the dragon had (fire, cold, acid, etc.). The mage can also cast any spell the dragon once knew, as a 5th level spell caster. (Printed 102.)"
  - name: "Augmentation: Skull of a Powerful Supernatural Monster (120 P.P.E.)"
    description: "120 P.P.E.. Skull of a god, godling, greater demon/being or demon lord (elementals, vampires, alien intelligences and energy beings do not qualify). Gives 40 M.D.C., the ability to speak that creature''s language, and all its magic powers and spell knowledge, only while the skull is activated, at half the level of ability it had alive: 10th level in life gives fifth level power, sixth gives third. (Printed 102.)"
  - name: "Augmentation: Wings of a Bird or Bat (30 P.P.E.)"
    description: "30 P.P.E.. Wings are strapped to the mage''s back and may be undersized or over-sized; when the magic engages they grow or shrink to fit the user. Flying speed is limited to 20 mph (32 km) for most songbirds and bats, game and large birds, and 35 mph (56 km) from the wings of birds of prey. Large monstrous wings (pegasus, peryton, harpy, gargoyle, gryphon, gromek, loogaroo, waternix and similar) give 45 mph (72 km). (Printed 102.)"
  - name: "Augmentation: Wings of a Dragon or Powerful Supernatural Creature (90 P.P.E.)"
    description: "90 P.P.E.. Flight at a speed of 60 mph (96 km) and a bonus of 10 M.D.C. to the flyer; the wings themselves have 2D4x10 M.D.C. (Printed 102.)"
  - name: "Animate and Control the Dead"
    description: "Like the common spell but considerably more powerful. 10 P.P.E. Range 300 ft (91.5 m) plus 20 ft (6 m) per level; duration 10 minutes per level. Controls four corpses or skeletons (humanoid, animal or monster) per level of experience; each must be in line of sight to animate, and more can be added as they are found. They can be sent out of sight on simple missions such as ''destroy'' or ''kill'' and follow the command until destroyed or the duration ends. Each has Spd 7, two attacks per melee, 1D6 S.D.C. damage from punches, kicks, claws and bites, and can use only the simplest mega-damage weapons (flaming sword, vibro-blade), never guns; giant ones have double speed and damage and one more attack. They feel no pain, fear or emotion. Only total destruction stops them, or slaying or knocking out their creator. S.D.C.: small 50, human-sized 80, giant 140. Bullets and stabbing weapons do 1/3 damage, blunt and smashing attacks full damage, fire double damage. (Printed 102.)"
  - name: "Impervious to Vampires"
    description: "Impervious to a vampire''s mind-controlling bite and cannot be turned into a vampire, though vampires can still slay him. Knows all the legends about vampires and other undead and how to combat them. (Printed 102.)"
  - name: "Horror Factor"
    description: "The necromancer is frightening. Horror Factor 6 at first level, +1 at levels 3, 5, 7, 9, 11, 13 and 15 (and +2 more while Augmentation appendages are attached). A Horror Factor the character PROJECTS is not a save the character makes, so it is recorded here; the +6 to save vs Horror Factor in bonuses is a separate thing."
  - name: "Learning New Spells"
    description: "Additional spells and rituals related to necromancy (see the necromancy and common lists) can be learned or purchased at any time, regardless of the character''s experience level. See The Pursuit of Magic, Rifts Ultimate Edition page 190."
  - name: "Common Spells Cost Double"
    description: "The necromancer can learn any spell, but any common spell NOT on the book''s Available Common Spell Magic list (printed 108) costs him twice its normal P.P.E. to cast - Armor of Ithan costs 20 rather than 10, Befuddle 6 rather than 3. The spells on that list, which are the necro_common list of this class, are cast at their normal cost. Other spell casters (a line walker, a shifter) can learn necromancy spells but pay double to cast them; techno-wizards and mystics never learn necro-magic."
  - name: "Insanity"
    description: "The necromancer often becomes deranged with the passage of time: one roll on the Necromancer Insanity Table at each of levels 4, 8, 10, 12 and 15. The table is the Insanity pick group that follows, one banked roll or pick per listed level. The book also lets a player who wants the character crazy simply pick one or two results. (Printed 104.)"
  - { choose: 1, at_levels: [4, 8, 10, 12, 15], from: ["Insanity (01-30): No Insanity", "Insanity (31-40): Obsession - Torture and Killing", "Insanity (41-45): Obsession - Hates the Light of Day", "Insanity (46-50): Obsession - Danger", "Insanity (51-55): Phobia - Gods of Light", "Insanity (56-60): Obsession - Hates Good Druids", "Insanity (61-65): Obsession - Dead Things", "Insanity (66-70): Phobia - Ancient Dragons", "Insanity (71-75): Phobia - High Level Shamans and Priests of Light", "Insanity (76-80): Phobia - Spirits of Light", "Insanity (81-85): Random Affective Disorder", "Insanity (86-90): Random Phobia", "Insanity (91-95): Random Obsession", "Insanity (96-00): Random Insanity"], note: "Necromancer Insanity Table (printed 104): roll once, or pick, at each of levels 4, 8, 10, 12 and 15. Rows 81-00 send the player to another table." }
  - name: "Insanity (01-30): No Insanity"
    description: "Roll 01-30 or choose. No insanity this time; the necromancer''s mind holds. (Printed 104.)"
  - name: "Insanity (31-40): Obsession - Torture and Killing"
    description: "Roll 31-40 or choose. Obsession: he likes to torture, hurt and kill others. (Printed 104.)"
  - name: "Insanity (41-45): Obsession - Hates the Light of Day"
    description: "Roll 41-45 or choose. Obsession: he hates the light of day and tries to avoid it. (Printed 104.)"
  - name: "Insanity (46-50): Obsession - Danger"
    description: "Roll 46-50 or choose. Obsession: he loves danger and takes needless risks. (Printed 104.)"
  - name: "Insanity (51-55): Phobia - Gods of Light"
    description: "Roll 51-55 or choose. Phobia: Gods of Light. (Printed 104.)"
  - name: "Insanity (56-60): Obsession - Hates Good Druids"
    description: "Roll 56-60 or choose. Obsession: he hates good druids, especially Millennium druids. (Printed 104.)"
  - name: "Insanity (61-65): Obsession - Dead Things"
    description: "Roll 61-65 or choose. Obsession: he loves dead things and surrounds himself with skeletons, mummies, zombies and the like. (Printed 104.)"
  - name: "Insanity (66-70): Phobia - Ancient Dragons"
    description: "Roll 66-70 or choose. Phobia: ancient dragons. (Printed 104.)"
  - name: "Insanity (71-75): Phobia - High Level Shamans and Priests of Light"
    description: "Roll 71-75 or choose. Phobia: high level shamans and priests of light. (Printed 104.)"
  - name: "Insanity (76-80): Phobia - Spirits of Light"
    description: "Roll 76-80 or choose. Phobia: spirits of light/angels. (Printed 104.)"
  - name: "Insanity (81-85): Random Affective Disorder"
    description: "Roll 81-85 or choose. The row sends the player to roll for a random affective disorder; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (86-90): Random Phobia"
    description: "Roll 86-90 or choose. The row sends the player to roll for a random phobia; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (91-95): Random Obsession"
    description: "Roll 91-95 or choose. The row sends the player to roll for a random obsession; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (96-00): Random Insanity"
    description: "Roll 96-00 or choose. The row sends the player to roll for a random insanity; that second roll is made by hand and its result is not stored here. (Printed 104.)"
restrictions:
  - "Optional O.C.C.: the book calls the necromancer a better NPC villain than player character and leaves its use as a player character to the Game Master''s discretion."
  - "Selfish or evil alignment only (unprincipled, anarchist, or any evil); a good necromancer is not possible. Most are anarchist or evil. Attribute requirements are I.Q. 10, M.E. 10 and P.E. 12 or higher."
  - "Race: any that may master death magic - humans, D-Bees, ogres and many monster races. Faerie folk, spirits of light, elementals and kilin are never necromancers, and dragons generally avoid it."
  - "Cybernetics: starts with none and avoids them because they interfere with magic. Only cybernetic bio-systems for health reasons will be considered."
  - "Vehicle is limited to NON-MILITARY transportation - a hover vehicle, a motorcycle or a riding animal."
  - "Hand to Hand is NOT free: Basic costs one O.C.C. Related Skill, Expert two, and Martial Arts or Assassin (if evil) three."
  - "The character also starts with 3D6x1000 credits'' worth of sellable black-market items, over and above the coin in starting_money. That field is coin only, so the goods are recorded here."
  - "Secondary skills are chosen from the O.C.C. Related list EXCLUDING the categories marked None - Electrical, Mechanical and Military - and take no category bonus."
  - "Starting gear the catalog has no row for: a box of 50 large zip-lock plastic bags, a large satchel or suitcase, a wooden knife, and one or two other weapons of choice. The sacrificial short sword is usually ornate and plated in a precious metal; the necromancer prefers magic weapons and devices over technological ones."
extraction_notes: "Rifts World Book 4: Africa pp.99-104, with the necromancy spell list and the Available Common Spell Magic rule on printed 108 and the ladder on printed 160. This is the original Necromancer; necromancer-russian (Mystic Russia) is a separate later class and its Bone Magic is not part of this one. XP: the Necromancer & Phoenixi column, stored as lower bounds; level 15 is printed as 350,921-425,800 although level 14 ends at 350,700, so 350,921 is stored as printed rather than 350,701 - a book anomaly. men_of_arms is false: the class sits in the book''s magic section beside the African Witch and Priest and prints no S.D.C. formula of its own, only the +10 S.D.C. bonus. STARTING SPELLS: the six necromancy picks come from a named list of the 18 Necromancy rows (the book says regardless of level, and a named list replaces the level gate). The six common picks come from a named list of the book''s Available Common Spell Magic list, the spells the book treats as associated with necromancy and casts at normal cost; no level cap is applied to that group because the book states none (necromancer-russian capped its common six at 1-5; a spell_levels key beside a named list in a starting group is not applied by startingGroups in js/leveling.js, so a cap would need a second list). The book''s list names Animate & Control Dead, Control/Enslave Entity and Protection: Simple; the catalog rows are Animate and Control Dead, Control & Enslave Entity and Protection Circle: Simple. The double P.P.E. cost of every other common spell has no key and is prose in special_abilities. Union with the Dead and Augmentation each keep one special ability for the general rule, and since ~118 every option of their tables is its own special ability named with its P.P.E. cost (fifteen unions, eleven augmentations), by the ruling of 2026-10-04 that they are class abilities and not spell rows. The 35 and 20 P.P.E. claws are paragraphs of the dragon claws entry on the page and are separate abilities here because each prints its own cost; Additional Arms or Tentacles is one ability with its three printed costs. None of their bonuses go in bonuses because each applies only while a limb is attached. The projected Horror Factor is prose; the +1 save vs magic of all kinds is carried as spell_magic and ritual_magic. Two additional languages: the book''s first additional language is spoken and literate, so the class takes two Language: Other picks and one Literacy: Other pick. Skill names needing the catalog''s spelling: Lore: Monsters & Demons is Lore: Demons & Monsters; Basic Math is Mathematics: Basic; Skin and Prepare Animal Hides & Bones is Skin & Prepare Animal Hides; Pilot Hover Craft is Hover Craft (ground). Gear judgement calls: leather gloves are gloves, the robe-or-cloak is robe, the two hand shovels are shovel, the palm size mirror is pocket-mirror, the sacrificial short sword is short-sword, the dozen flares are hand-held-flares, and a week''s food rations are one food-rations entry. The text layer prints the human-sized animated corpse S.D.C. as SO; the rendered page reads 80. 2026-10-05: the Necromancer Insanity Table (printed 104, read off the rendered page) is a pick-one group at levels 4, 8, 10, 12 and 15, the levels the page prints (four, eight, ten, twelve and fifteen), by BOOK-INGEST-AUDIT.md F116. Its fourteen rows are band-named options, 01-30 through 96-00, covering 01-00 with no gap or overlap as printed, each its own special ability. No row prints a number, so none carries bonuses. The four rows that send the player to another table (81-85 random affective disorder, 86-90 random phobia, 91-95 random obsession, 96-00 random insanity) stay as that row''s prose. The Insanity ability is kept as a pointer and holds the book''s allowance to pick one or two results outright."
---

# Necromancer

## Lore

The necromancer practises the magic of death, the dead and the monstrous. It is
an obscure art in most of the world, but by far most common in Africa and
southern Europe, spread by the influence of Egypt and its insane Pharaoh
Rama-Set, the Gods of Darkness, many death cults and the monster races and evil
supernatural beings that dominate those lands.

The heart of the necromancer''s power is the ability to animate, control and draw
power from the remains of the dead. So these mages carry bones, claws, hooves,
wings and preserved limbs in satchels, trunks and sacks, and keep the rarest -
a dragon''s claw - on their person at all times. Some travel with an entourage of
skeletons and zombies, a common sight in the Phoenix Empire, and a necromancer''s
lair is guarded by the animated dead.

Much of the magic calls for enslavement, torture, blood sacrifice and murder as
a source of P.P.E.; to the evil necromancer, death is simply a resource.

## Alignment

Selfish or evil only. An unprincipled or anarchist necromancer shows restraint:
avoids torture and wanton killing, prefers scavenging and grave-robbing to blood
sacrifice, and shuns pacts with supernatural beings and dealings with other
necromancers - which limits both P.P.E. and the spells he will use. An aberrant
one keeps his own code and kills quickly and with discretion. The rest suffer no
such scruples.

## GM Notes

The book presents the necromancer as a better NPC villain than player character
and leaves it to the Game Master whether one may be played. Roughly a quarter of
known necromancers are human; ogres and other monster races make up over half.
The five special powers - Union with the Dead, Augmentation, Animate and Control
the Dead, immunity to vampires and a Horror Factor - come in addition to the
starting spells.
',
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, '- { name: "Technical", only: ["Creative Writing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0
   AND length(markdown) = 29676;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 9 classes carry their new text' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE (class_id = 'travelling-story-teller' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Computer"], bonus: 15 }') > 0)
    OR (class_id = 'grey-seer' AND instr(markdown, '- { name: "Technical", only: ["Art", "Art: Line Drawing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }') > 0)
    OR (class_id = 'pirate' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'sailor' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'monkey-boy-tech' AND instr(markdown, '- { name: "Technical", only: ["Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, '- { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'travelling-story-teller' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 10 }') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Computer"], bonus: 15 }') > 0)
    OR (class_id = 'grey-seer' AND instr(markdown, '- { name: "Technical", only: ["Art", "Art: Line Drawing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }') > 0)
    OR (class_id = 'pirate' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'sailor' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'monkey-boy-tech' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, '- { name: "Technical", only: ["Creative Writing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('travelling-story-teller', 'sohei-warrior-monk', 'mystic-ninja', 'ectohunter', 'grey-seer', 'pirate', 'sailor', 'monkey-boy-tech', 'necromancer') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~196-book-ingest-audit-f138-bare-literacy.sql');
