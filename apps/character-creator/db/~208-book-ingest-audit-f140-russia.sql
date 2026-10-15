-- BOOK-INGEST-AUDIT F140: settle the unsettled sentences on four Warlords of Russia classes
-- 4 classes, each replaced whole: ectohunter, huntsman-trapper, russian-villager, war-knight.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~208-book-ingest-audit-f140-russia.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

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
  - { item_id: "clothing", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "note-pad", qty: 1 }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are selfish."
  - "Racial restrictions: none, although the majority (70%) are human."
  - "Attribute requirements: I.Q. 9 and M.E. 14 or higher. A high M.A., P.S. and P.E. are helpful but not required."
  - "Psionics are not a requirement, but approximately one third possess minor or major psionics."
  - "Cybernetics: none to start; varies with the individual. Most avoid bionics, as they are harmful to psionic and magic abilities."
  - "Vehicle: starts with a used, battered-looking hovercycle or other basic transportation, missing 1D4x10 M.D.C. from its main body but in fairly good condition."
extraction_notes: "WB17 Warlords of Russia printed 61-64 (cache p062-p065, cache page = printed folio + 1), read off the text layer. The stat block starts on printed 63 and ends with Money and Cybernetics on printed 64. || HEADING: Ectohunter O.C.C., also known as Ghost Hunters and spiritualists; listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base. || XP: the Ectohunter, Travelling Story Teller and Warlord Cyber-Doc ladder as given in the brief, read off a render of the Experience Tables on printed 6. || SPECIAL ABILITIES: the eleven numbered Special Ectohunter O.C.C. Abilities (printed 62-63) are stored as special_abilities, except 6 (P.P.E.), which is ppe_base, and 10 (O.C.C. Bonuses), which is split: +1 pull punch is in bonuses, +1 to save vs illusions is saves.other because the book says illusions and not illusionary magic, and +2 initiative against ghostly beings only is conditional and stored as an ability. || HORROR FACTOR: +1 at levels 1-10, 12 and 14 stored as horror_factor 1 plus eleven at_level entries; the book qualifies it as applying to supernatural monsters and horrors, which is stated in the ability and is a reading. || POSSESSION: +10 flat plus +1 at levels 2, 4, 6, 8, 10, 12 and 14, as printed. || P.P.E.: 4D6 plus the P.E. attribute number, plus 1D4 per level. The class casts no spells of its own (it reads scrolls and uses magic items), so there is no magic block. || PSIONICS: not a requirement; about one third have minor or major psionics; no block and no roll is printed. || VULNERABILITY: the M.E. loss and insanity rolls are in side_effects and an ability; nothing applies them. ''Every other level'' prints no starting level. || SKILLS: Speaks Euro and two other languages of choice (+20%) is read as Euro at +20% and two Language: Other picks at +20%. Surveillance Systems maps to Surveillance, Read Sensory Equipment to Sensory Equipment. Lore: one of choice is one pick across the Lore: rows of Technical and Cowboy. Pilot: one of choice (+5%) offers all of Pilot; the O.C.C. line prints no exclusion. W.P. Energy Weapon of choice is a W.P. category pick with the restriction in the note. || PILOT EXCEPT: ''except robots, power armor, military vehicles, ships and aircraft'' read literally as all ships and all aircraft, mapped to the Robot rows, the Military: rows, Boat: Ships, Airplane, Helicopter, Jet Aircraft, both Fighter Combat rows, the three Space craft rows, Wingrider Flying Wing and Air Assault Armor. Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored. The +15% to language or computer skills reaches every Language: and Literacy: row and every Computer row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): a second Technical entry holds the Language:, Literacy: and Computer rows by prefix at +15, a second Communications entry the Literacy: rows and Language: Dolphin/Whale at +15, and a second Electrical entry the Computer rows (Computer Repair) at +15. Language: All (magical) gets no +15, because the catalog files it as an innate ability and not a learned language; it is tagged for Palladium Fantasy and Nightbane only, so a Rifts build is not offered it at all. Computer Hacking is a Rogue skill and Rogue is Streetwise only, so it gets no entry and stays unavailable. || MONEY: 1D6x1000 credits stored (the text layer prints !D6xlOOO); the 1D6x100 in tradeable goods is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon of choice; a box of 100 large resealable plastic bags and personal items have no catalog row; the belt has no Rifts row (its only row is Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The clothing, bedroll, boots (as work-boots-rifts) and note pad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). Light suit of M.D.C. body armor maps to light-mdc-body-armor, the pair of silver knives to two knife-silver-plated, the mallet to hammer-and-mallet. || NOT STORED: the fee structure (as little as 100 credits to tens of thousands, a nonrefundable 10% retainer plus expenses), the nationality percentages, and Secret Resources are prose in GM Notes."
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
100 large resealable plastic bags for specimens, a belt (no Rifts row) and
personal items. Money is 1D6x1000 credits plus 1D6x100
in tradeable goods. The vehicle is a used hovercycle or other basic
transportation missing 1D4x10 M.D.C. from the main body.

No secret resources. Most people dislike Ectohunters as money-grubbing;
Bogatyrs and other humanitarians especially so, and Huntsmen treat them as a
joke. About 30-40% have psionics, by the ability text; the stat block says
about one third have minor or major psionics. Neither prints a roll.
',
       updated_at = datetime('now')
 WHERE class_id = 'ectohunter'
   AND instr(markdown, 'and Wingrider Flying Wing. Air Assault Armor, Combat Pod') > 0
   AND length(markdown) = 20058;

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
  - { item_id: "knife-skinning", qty: 1, note: "The book says skinning knives, with no number." }
  - { item_id: "flint", qty: 1, note: "The book says flint and tinder box; the tinder box has no Rifts row." }
  - { item_id: "utensil-kit-rifts", qty: 1, note: "The book says cooking utensils." }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a fur cloak or long coat." }
  - { item_id: "note-pad", qty: 1 }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none, although the majority (63%) are human."
  - "Attribute requirements: I.Q. 9 and P.E. 12 or higher. A high M.E. and P.S. are helpful but not a requirement."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Expert only; no others are available."
  - "Cybernetics: none to start, and avoids them as unnatural. The only cybernetics a Huntsman might consider are bio-system prosthetics and organs to replace severely injured ones."
  - "Vehicle: none to start; most Huntsmen prefer to walk, but may know how to ride a horse or hovercycle in a pinch."
extraction_notes: "WB17 Warlords of Russia printed 66-69 (cache p067-p070, cache page = printed folio + 1), read off the text layer. Heading The Huntsman-Trapper O.C.C. at the top of printed 66; the special abilities are printed 66-68 and the stat block headed The Russian Huntsman-Trapper O.C.C. (also known as Woodsman and Trapper) starts on printed 68. The entry ends on printed 69, where its Note, Money and Cybernetics lines are interleaved in the text layer with the opening of the Travelling Story Teller (cache p070 lines 57-80 are the Huntsman''s). || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Huntsman-Trapper ladder on the Experience Tables, printed 6, read off a render; the book misprints level 5 as 18,501, level 4 ends at 16,500, so 16501 is stored. || BONUSES: +2 initiative, +3 pull punch, +3 vs possession stored flat; +1 to save vs magic is stored as spell_magic only (a reading: the book says magic, not spell or ritual); +2 vs poison and disease is stored as toxins_poisons 2 and disease 2; +1 vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 is stored as horror_factor 1 flat for level 1 plus eight at_level entries. || P.P.E.: 4D6 + P.E. attribute number and +1D4 per level, stored in ppe_base and repeated as a special ability. || SPECIAL ABILITIES: the three percentile abilities (Track and Trap 20%/30% +5%, Recognize Supernatural Shapechangers 30% +5%, Forest-wise 20% +4%) are special_abilities prose. Track & Trap Animals is ALSO stored as an occ skill at 20/5 because the catalog holds a row of that name at the same figures; that is a reading, and the 30% trapping number lives only in its note. Recognize Supernatural Shapechangers and Forest-wise have no catalog skill row. The Code of the Huntsman-Trapper (printed 68) is stored as a special ability, paraphrased. || SKILLS NOT STORED: Lore: Geomancy & Ley Lines (+10%) has no catalog row and is left out. Speaks Faerie has no catalog language row; it is stored as one of three Language: Other picks at +10%. || SKILL READINGS: Lore: Faeries is the catalog''s Lore: Faeries & Creatures of Magic; Identify Plants & Fruits is Identify Plants & Fruit; Tracking is Tracking (people); Advanced Math is Mathematics: Advanced. Falconry is filed under Military in the catalog, so Military appears with only Falconry at the +15% the book prints under Technical, although the book says Military: None; Whittling at +15% is not stored: Whittling & Sculpting takes Technical''s flat +10, and the printed +15% is kept here and in the related-skills note (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14). Prowl is filed under Physical and is reached by name through the Rogue only-list at +10%. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft (the Explorer on printed 65 says military aircraft; this entry does not); Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Huntsman may know how to ride a horse. Hand to Hand: Expert, no others available, is costs: {}. || MONEY: the book prints no coin: 4D4x100 credits WORTH of furs, horns, bone, nuggets of silver or gold and other tradeable goods (the text layer prints 4D4xlOO). starting_money is 0 and the goods are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, 20 feet of wire and personal items have no catalog row and are in GM Notes; the tinder box, frying pan and belt have no Rifts row (their only rows are other games'': Palladium Fantasy''s for all three, and Heroes Unlimited''s and Nightbane''s as well for the frying pan; and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The skinning knives, the flint, the cooking utensils (as utensil-kit-rifts), the bedroll, the boots (as work-boots-rifts), the fur cloak or long coat and the note pad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The text layer prints scalable for sealable. The armor is stored as the light homemade suit; the lore text on printed 67 says such armor is typically 30-60 M.D.C. and rarely environmental. || NOT STORED: Secret Resources and the Note on how Reavers, War Camp soldiers, Bogatyrs, Demon Hunters and Ectohunters regard the class are in GM Notes; only 15% have partial bionics (printed 67)."
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

Track and Trap''s 20% tracking is the Track & Trap Animals skill, which the
sheet rolls. Percentile abilities the sheet does not roll for you: Track and
Trap''s 30% trapping, +5% per level (tracking humans at -20%, disarming traps
meant for humans at half); Recognize Supernatural Shapechangers is 30% +5% per
level; Forest-wise is 20% +4% per level.

The save vs Horror Factor rises by +1 at levels 1, 3, 4, 5, 7, 8, 10, 12
and 14.

One of the three language picks is Faerie. The book also grants Lore:
Geomancy & Ley Lines (+10%), which the catalog does not hold.

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+2
extra clips apiece, a tinder box, frying pan and belt (no Rifts row for any
of the three), a box of 100 plastic sandwich bags, a box of 100 large sealable
bags, 1D4 airtight plastic containers, 20 feet (6 m) of wire and a handful of
personal items.

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
   AND instr(markdown, 'the sheet does not roll for you: Track and Trap is 20%') > 0
   AND length(markdown) = 20190;

-- == russian-villager ==
UPDATE imported_classes
   SET markdown = '---
id: russian-villager
name: Russian Villager
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.71-72
category: occ
tags: []
occ_group: optional
men_of_arms: false
xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d6x10"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "anarchist or evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "Speaks native language at 90%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Speaks two other languages of choice (+10%)." }
    - { choose: 1, from: ["Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: General Law", "Lore: History of Russia", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Cattle & Animals"], bonus: 15, note: "Lore: one of choice (+15%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 5, note: "Piloting: two of choice (+5%); no bonus for Horsemanship. A Horsemanship skill may be taken as one of the two, at its base." }
    - { name: "Animal Husbandry", base: 40, per_level: 5, note: "+5%; +10% if a farmer or raises livestock." }
    - { name: "Masonry", base: 50, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Sing", "Dance"], bonus: 15, note: "Sing or Dance (pick one; +15%)." }
    - { name: "Cook", base: 50, per_level: 5, note: "+15%" }
    - { name: "Preserve Food", base: 35, per_level: 5, note: "+10%" }
    - { name: "Rope Works", base: 40, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "The book prints General Athletics." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient weapons of choice; blunt is very common." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one modern energy weapon of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two O.C.C. Related Skills, or to Martial Arts (or Assassin, if anarchist or evil) for the cost of three." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Wilderness Survival"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Ventriloquism"] }
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Choose six other skills at level one and two additional at levels 4, 8 and 12. Communications: any. Domestic: any (+10%). Electrical: Basic Electronics only. Espionage: Wilderness Survival only (+5%). Mechanical: Basic Mechanics and Automotive only. Medical: Brewing, First Aid and Holistic Medicine only (+5%). Military: none. Physical: any, except Acrobatics, Gymnastics and Boxing. Pilot: any conventional types of vehicles and horsemanship; no robots, ships, aircraft or military vehicles (horsemanship is filed in its own category here). Pilot Related: any. Rogue: Ventriloquism only. Science: Astronomy and Math only (+5%). Technical: any (+5%; +10% to any animal related skills). W.P.: any. Wilderness: any (+5%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Wilderness Survival"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Ventriloquism"] }
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Four secondary skills from the list at level one and one additional at levels 3, 6, 9, 12 and 15, without the bonuses in parentheses."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
equipment_starting:
  - { choose: 1, label: "homemade M.D.C. armor (30-60 M.D.C.)", qty: 1, from: ["homemade-mdc-armor-light", "homemade-mdc-armor-medium"], note: "A suit of hodgepodge, homemade M.D.C. armor (30-60 M.D.C.)." }
  - { item_id: "e-clip", qty: 2, note: "Two extra ammo-clips for the one M.D. weapon." }
  - { item_id: "knife", qty: 1 }
  - { item_id: "hatchet", qty: 1, note: "For cutting wood." }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6" }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The book says a mallet." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "gas-mask", qty: 1, note: "Gas mask and filter." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a cigarette lighter." }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1, note: "The book says a water skin." }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
trackable_resources: []
restrictions:
  - "Optional: the book gives these as the basic stats for the average villager, farmer and low-tech citizen, usable as a guide for creating Non-Player Characters or as an optional player character."
  - "Alignment: any."
  - "Racial restrictions: none, although the majority (70%) are human."
  - "Attribute requirements: none. High physical attributes are ideal for those who labor in the fields or factories, and high mental attributes for business people, advisors and elders."
  - "Cybernetics: none to start, and tends to avoid them."
  - "Vehicle: starts with a bicycle or donkey."
extraction_notes: "WB17 Warlords of Russia printed 71-72 (cache p072-p073, cache page = printed folio + 1), read off the text layer. Heading Russian Villager O.C.C. on printed 71, with the stat block headed Typical Villager/Farmer/Worker O.C.C. & NPC (also known as peasants, citizens, and the Russian People). OPTIONAL: the book says the data can be used as a guide for creating Non-Player Characters or as an optional player character. The entry ends on printed 72: its related-skill list runs down the left column to Wilderness: Any (+5%), and its Secondary Skills, Standard Equipment, Vehicle, Money and Cybernetics lines top the right column (cache p073 lines 52-72), where the text layer interleaves them with the Warlord Troops & Men at Arms material that follows. || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Villager ladder on the Experience Tables, printed 6, read off a render. || The entry prints NO O.C.C. bonuses, no Psionics line and no Secret Resources line; none is stored. Attribute requirements: none, so no attribute_requirements key. || SKILL READINGS: Speaks Native Language at 90% is Language: Native Tongue at 90. Lore: one of choice (+15%) is one pick from the catalog''s lore rows that fit the setting (the off-world and other-setting lores are left out of the list; a reading). Piloting: two of choice (+5%); no bonus for Horsemanship is stored as two Pilot picks at +5; the Horsemanship alternative at no bonus is in the note only: a category choice group carries one bonus, and an option''s own bonus (BOOK-INGEST-AUDIT.md F135) needs a from list naming every Pilot row. Animal Husbandry is stored at +5% (40); the +10% if a farmer or raises livestock is in the note. Sing or Dance is one pick from the two at +15. Hand to Hand: Basic to Expert costs TWO related skills and Martial Arts (or Assassin, if anarchist or evil) THREE, as printed across the page break of printed 71-72. Pilot Skills: any conventional types of vehicles and horsemanship, no robots, ships, aircraft or military vehicles: stored as Pilot minus the robot, ship, aircraft, spacecraft and military rows, with Horsemanship (its own catalog category) offered as General and Exotic Animals only. Ventriloquism is filed under Technical in the catalog and is reached by name through the Rogue only-list. Science: Astronomy and Math only is Astronomy, Mathematics: Basic and Mathematics: Advanced. Technical +10% to any animal related skills is not stored (Technical is a flat +5). Secondary skills: four at level one and one more at levels 3, 6, 9, 12 and 15. || MONEY: 1D6x10 credits stored (the text layer prints !D6xlO); the 2D4x10 credits worth of tradeable goods (2D4xlO) is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon and two ancient weapons; pitchfork or blunt weapon and personal items have no catalog row and are in GM Notes; the shovel and the belt have no Rifts row (their only rows are other games'', and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The walking stick/staff or sword is a choice naming no particular sword and stays in GM Notes, though a walking-stick row exists. The tinted goggles, bedroll, water skin and boots (as work-boots-rifts) are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The armor is a choice of the catalog''s light and medium homemade suits for the printed 30-60 M.D.C. The bicycle or donkey is the Vehicle line and is in restrictions and GM Notes, not equipment."
---

## Lore

This is the ordinary Russian: the peasant, farmer, laborer or townsman who
makes up nearly everyone living under the Warlords. They work the fields and
the workshops, raise stock, build in stone, sing or dance at the festivals,
and know enough of the old lore to be afraid of the right things.

Life in the shadow of the deep forests means even a farmer keeps a cross, a
few stakes and a mallet by the door, owns a patched-together suit of armor
and can use a weapon when something comes out of the trees.

The book offers the villager mainly as a template for the people a party
meets, and as an optional, deliberately modest player character.

## GM Notes

Optional class: intended first as a guide for Non-Player Characters, and
allowed as a player character at the GM''s discretion.

Animal Husbandry is +10% rather than +5% for a farmer or anyone who raises
livestock. One or both of the two piloting picks may be a Horsemanship skill
instead, but it gets no bonus. Technical skills that are animal related get
+10% rather than +5%.

Starting kit beyond what the sheet lists: one M.D. weapon (with the two extra
clips), two ancient weapons, a pitchfork or blunt weapon, a walking
stick/staff or sword, a shovel and a belt (no Rifts row for either) and a
handful of personal items.

Vehicle: a bicycle or a donkey. Money: 1D6x10 credits plus 2D4x10 credits
worth of tradeable goods.
',
       updated_at = datetime('now')
 WHERE class_id = 'russian-villager'
   AND instr(markdown, 'because one choice group carries one bonus') > 0
   AND length(markdown) = 13944;

-- == war-knight ==
UPDATE imported_classes
   SET markdown = '---
id: war-knight
name: War-Knight
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.91-94
category: occ
tags: [combat, leader]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 52521, 74001, 100001, 135201, 190301, 240401, 290501, 350601]
attribute_requirements: { IQ: 9, PS: 12, PP: 12 }
race_restrictions: { only: ["none"], note: "Exclusively human." }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d4x1000"
bonuses:
  combat: { initiative: 1, roll: 1, pull_punch: 1 }
  saves: { horror_factor: 1, possession: 2 }
  at_level:
    - { level: 2, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 3, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 4, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 5, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 6, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 7, combat: { pull_punch: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 9, combat: { pull_punch: 1 } }
    - { level: 10, combat: { disarm: 1 }, saves: { horror_factor: 1 } }
    - { level: 11, combat: { initiative: 1, pull_punch: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, combat: { initiative: 1, disarm: 1 }, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { assassin: 0 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, categories: [{ name: "Technical", only_prefix: ["Lore:"] }, { name: "Cowboy", only_prefix: ["Lore:"] }], note: "Lore: one of choice." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: Knight", base: 40, per_level: 5 }
    - { name: "Horsemanship: Exotic Animals", base: 45, per_level: 5, note: "+15%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking (+10%)." }
    - { name: "Military Etiquette", base: 55, per_level: 5, note: "+20%" }
    - { name: "Military Fortification", base: 40, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Streetwise", base: 26, per_level: 4, note: "+6%, as printed." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Including Vibro-Swords." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book prints W.P. Energy Heavy." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P. of choice (any)." }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Hand to Hand: Martial Arts (or Assassin if evil)." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", except: ["Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Helicopter", "Jet Aircraft", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing", "Robot Combat: Basic", "Robot Combat Elite", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Choose four other skills at level one. Communications: any (+5%). Domestic: any. Electrical: Basic only. Espionage: any. Mechanical: none. Medical: First Aid only (+10%). Military: any (+10%). Physical: any. Pilot: any, except robots, ships and aircraft (+10% to all horsemanship/riding skills). Pilot Related: any. Rogue: none, other than Streetwise above. Science: Astronomy and Math only. Technical: any (+10%). W.P.: any. Wilderness: any."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Helicopter", "Jet Aircraft", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing", "Robot Combat: Basic", "Robot Combat Elite", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Three secondary skills from the list at level one and one more at levels 3, 5, 7, 10 and 13, without the bonuses in parentheses."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { choose: 1, label: "large Vibro-Sword or Vibro-Axe (3D6 M.D.)", qty: 1, from: ["vibro-sword", "vibro-axe"] }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "knife-silver-plated", qty: 1, note: "The book says a silver survival knife." }
  - { item_id: "wooden-cross", qty: 1, note: "Hand-held." }
  - { item_id: "war-knight-combat-shield", qty: 1, note: "Small to medium Mega-Damage shield, 30 M.D.C., for parrying and blocking, particularly when charging." }
  - { item_id: "light-mdc-body-armor", qty: 1, note: "A suit of light body armor for quiet moments in a large War Camp." }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 2, note: "Two saddlebags." }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "canteen", qty: 3, note: "Three canteens or water skins." }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "marker", qty: "2d4", note: "2D4 markers and pens." }
  - { item_id: "winter-survival-kit", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1, note: "50 feet (15.2 m) of thin nylon cord, 600 lb./270 kg test strength." }
special_abilities:
  - name: "Custom War-Knight Power Armor"
    description: "Starts with a suit of full environmental light power armor with strength and speed augmentation but no flight. Typical M.D.C. by location: retractable Vibro-Blades (1-2) 80 each, forearm weapon 50, head/helmet 60-80, arms 80-120 each, legs 100-150 each, main body 2D6x10+110. The blades, forearm weapon, helmet and arms are small targets, hit only by an aimed shot at -3 to strike; destroying the main body destroys the armor and its augmentation. Only while the armor is worn: Robot P.S. 26-30; running speed is the wearer''s Spd x10 at 10% of the normal fatigue rate; leaps 10 feet high and 15 feet across, double with a running start; +1 attack per melee at levels 2, 6 and 12; +1 on initiative; +1 to strike and parry. Damage: restrained punch 1D4 M.D., punch 1D6 M.D., power punch 2D6 M.D. (counts as two attacks), kick 2D4 M.D., leap kick 2D6 M.D., body flip/throw or tackle 1D4 M.D. Most suits are provided by the Warlord; on the Black Market they run 1.6 to 2.5 million credits."
  - name: "Mega-Steed"
    description: "Starts with a mount, rolled on percentile: 01-15 a robot horse or other vehicle; 16-20 a partial bionic horse with M.D.C. barding; 21-45 a full bionic horse; 46-85 a Mega-Steed, a large and powerful mega-damage riding animal from another world; 86-95 a True Megahorse; 96-00 some other powerful alien or magical creature (Centaur, Pegasus, Kilin, Seeker, Eurotorpid, Tri-Wolf and the like)."
  - name: "Bearer of Magic Weapons"
    description: "Apart from the Warlord and his most trusted generals and advisors, the War-Knight is the only member of a War Camp permitted to wield magic weapons and enchanted items. They are given as rewards for distinguished service and heroism, and the Warlord lets a knight keep any won in combat or given by the people."
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Scrupulous (25%), Unprincipled (20%) or Aberrant (17%)."
  - "Attribute requirements also call for a high sense of responsibility and dedication to serve and protect; a high M.A., M.E. and P.E. are helpful but not required."
  - "Psionics are not a requirement: 12% possess Minor psionics, 4% Major and 2% Master. A Master psionic War-Knight has all the psionic abilities of the Mind Melter, minus 10% of the usual I.S.P. and with half the super-psionic abilities, keeps the War-Knight O.C.C. Skills and gets none of the O.C.C. Related Skills."
  - "Cybernetics: about 3% are full cyborgs, 6% partial cyborgs, 21% have one bionic limb with two weapon features plus 1D4 implants, and 20% have 1D4+2 implants and/or internal organs but no artificial limbs. More may be acquired over time, but most War-Knights try to avoid becoming even partial ''Borgs."
extraction_notes: "WB17 Warlords of Russia printed 91-94 (cache p092-p095, cache page = printed folio + 1), read off the text layer; printed 92 was also read off a render for the bonus lines and the Streetwise figure. The entry starts at the heading on cache p092 line 59; the stat block The War-Knight O.C.C. starts on cache p093 line 16; the Typical War-Knight Power Armor block runs from cache p094 line 100 to cache p095 line 20. || HEADING: War-Knight O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the War-Knight ladder on the Experience Tables, printed 6, read off a render and taken from the brief. || BONUSES: +1 roll and +2 save vs possession stored flat; +1 initiative at levels 1, 3, 5, 8, 11 and 14, +1 pull punch at 1, 3, 5, 7, 9 and 11, +1 disarm at 2, 4, 6, 10 and 14, +1 save vs Horror Factor at 1, 2, 4, 6, 8, 10, 12 and 14; the level-1 steps are in bonuses and the rest in at_level. || SKILLS: Streetwise prints (+6%), confirmed on the render, stored as 20+6. Speaks Russian at 98% is stored as Language: Russian base 98 with per_level 0, a flat printed percentage. Tracking is the catalog''s Tracking (people). W.P. Energy Heavy is read as W.P. Heavy M.D. Weapons; the other candidate is W.P. Heavy Military Weapons. Body Building is Body Building & Weight Lifting. Lore: One of choice is one pick across the Lore: rows of Technical and Cowboy, the Ectohunter''s shape (BOOK-INGEST-AUDIT.md F140, 2026-10-15; until then a list naming seventeen rows). Hand to Hand: Martial Arts (or Assassin if evil) prints no price, stored as assassin at cost 0 with the alignment condition. || RELATED: the Pilot line reads Any, except robots, ships and aircraft (+10% to all horsemanship/riding skills). The catalog files riding under its own Horsemanship category, so that category is granted at +10 and Pilot carries no bonus. Ships are Boat: Ships and Military: Warships & Patrol Boats; aircraft are Airplane, Helicopter, Jet Aircraft, Military: Combat Helicopter, Military: Jet Fighters and Wingrider Flying Wing; spacecraft are Space: Space Fighter, Space: Small Spacecraft and Space: Starship; robots are Robot Combat: Basic and Robot Combat Elite. NOT excepted, for a reviewer to decide: Robots & Power Armor and the model-specific Robot Combat Elite rows (the knight wears power armor and each row covers power armor as well as robots), Jet Packs, Air Assault Armor, Combat Pod, Space: Antigrav Suit, Space: Contragravity Pak and the submersible rows. Mechanical: None and Rogue: None are left out. Science Math only is the two Mathematics rows. || PSIONICS: the entry grants none; the 2% Master psionic variant (Mind Melter abilities, 10% less I.S.P., half the super-psionics, no related skills) is in restrictions and GM Notes and is not modelled. || POWER ARMOR: Custom War-Knight Power Armor is the first line of Standard Equipment. It is a vehicle row now (war-knight-power-armor, Warlords of Russia p.93-94) and still has no gear pointer row, so it is NOT in equipment_starting; its M.D.C. by Location, augmentation, bonuses, damage and cost are in a special_abilities entry and GM Notes. Its own bonuses (+1 attack at levels 2, 6 and 12, +1 initiative, +1 strike and parry) apply only when worn and are not in bonuses. Main body prints 2D6xlO +110 in the text layer, read as 2D6x10+110. || MOUNT: the percentile Mega-Steed table is a special_abilities entry and GM Notes; the steeds are described elsewhere in the book and are not rows here. || MONEY: 1D4x1000 credits stored (the text layer prints !D4xlOOO); the 2000 credit monthly salary (double for officers above lieutenant, triple for Field Marshalls) is in GM Notes. || EQUIPMENT readings: large Vibro-Sword or Axe is a choice of the generic vibro-sword and vibro-axe rows; silver survival knife is knife-silver-plated; three canteens or water skins is three canteens; notepad is note-pad; markers and pens are the marker row; 50 feet of thin nylon cord is lightweight-cord (a 50 foot bundle); two saddlebags is qty 2 of a row described as paired bags, which may double it. || EQUIPMENT not stored as rows: the power armor; an energy rifle or heavy M.D. weapon of choice; one other weapon of choice; casual clothing; cape or cloak; pair of gloves; belt and scabbard and other belts; a handful of personal items; the steed."
---

## Lore

War-Knights are the Warlords'' knights of the realm: the most honored
fighters in a War Camp and the nearest thing Russia has to a chivalric
order. Most serve as officers and elite troops, leading anything from a
strike team to a whole division, and more than half of all Field Marshalls
come from their ranks. The rest ride in all-knight cavalry companies, lead
mixed elite units, or travel the land alone or in small groups as the
Warlord''s representatives.

On the road a War-Knight is lawman, judge, tax collector and protector at
once, and the people turn to one with little hesitation. Some are savage or
outright evil, but most answer that trust by living up to it, and are
gracious and patient with ordinary Russians.

They look the part. The typical knight wears ornate, old-fashioned plate
that is in fact a suit of light power armor with hidden blades and a
forearm gun, carries a Vibro-Sword or a magic weapon at the belt, and rides
a bionic horse or one of the huge alien mounts called Mega-Steeds.

## GM Notes

Power armor. Every War-Knight starts with a custom suit of light,
full-environmental power armor (no flight). It is not on the equipment list;
it is listed among the vehicles. Typical figures: retractable Vibro-Blades
(1-2) 80 M.D.C. each, forearm weapon 50, head/helmet 60-80, arms 80-120
each, legs 100-150 each, main body 2D6x10+110. Everything but the legs and
main body needs an aimed shot at -3 to hit. Worn, it gives Robot P.S.
26-30, running speed of Spd x10 at one tenth the fatigue, 10 foot high and
15 foot long leaps (double with a run), +1 attack per melee at levels 2, 6
and 12, +1 initiative and +1 to strike and parry. Punch 1D6 M.D.
(restrained 1D4, power punch 2D6 for two attacks), kick 2D4, leap kick 2D6,
body flip or tackle 1D4. Black Market price 1.6 to 2.5 million credits.
None of the armor''s bonuses are in the class''s own numbers.

Mount, roll percentile: 01-15 robot horse or other vehicle; 16-20 partial
bionic horse with M.D.C. barding; 21-45 full bionic horse; 46-85 a
Mega-Steed (alien mega-damage riding animal); 86-95 a True Megahorse; 96-00
another powerful alien or magical creature such as a Centaur, Pegasus,
Kilin, Seeker, Eurotorpid or Tri-Wolf.

Starting kit beyond what the sheet lists: an energy rifle or heavy M.D.
weapon of choice, one other weapon of choice, casual clothing, a cape or
cloak, gloves, belt and scabbard, other belts and a handful of personal
items. The Vibro-Sword or Axe does 3D6 M.D.

Money is 1D4x1000 credits. Salary is 2000 credits a month, double for
officers above lieutenant and triple for Field Marshalls, with all needs,
military equipment and steeds provided. Magic weapons and special items
come as rewards, and gifts from grateful villagers may be kept. Knights
under 4th level, and those known for cruelty, get a cooler welcome.

On assignment the Warlord may furnish almost anything, magic items
included. No secret resources as such.

Psionics: 12% Minor, 4% Major, 2% Master. A Master psionic War-Knight has
the Mind Melter''s psionic abilities with 10% less I.S.P. and half the
super-psionics, keeps the War-Knight O.C.C. Skills and gets no O.C.C.
Related Skills. The class file grants no psionics; build this by hand.
',
       updated_at = datetime('now')
 WHERE class_id = 'war-knight'
   AND instr(markdown, 'a pick from every other Lore row the catalog holds') > 0
   AND length(markdown) = 17905;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 4 classes carry their new text' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'ectohunter' AND instr(markdown, 'so a Rifts build is not offered it at all') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, 'as well for the frying pan') > 0)
    OR (class_id = 'russian-villager' AND instr(markdown, 'needs a from list naming every Pilot row') > 0)
    OR (class_id = 'war-knight' AND instr(markdown, 'until then a list naming seventeen rows') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'ectohunter' AND instr(markdown, 'and Wingrider Flying Wing. Air Assault Armor, Combat Pod') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, 'the sheet does not roll for you: Track and Trap is 20%') > 0)
    OR (class_id = 'russian-villager' AND instr(markdown, 'because one choice group carries one bonus') > 0)
    OR (class_id = 'war-knight' AND instr(markdown, 'a pick from every other Lore row the catalog holds') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('ectohunter', 'huntsman-trapper', 'russian-villager', 'war-knight') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~208-book-ingest-audit-f140-russia.sql');
