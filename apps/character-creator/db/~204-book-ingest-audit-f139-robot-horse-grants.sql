-- BOOK-INGEST-AUDIT F139: the Adna Nomad and the Cyber-Samurai are granted a choice of the four Bandito Arms robot horses
-- 2 classes, each replaced whole: adna-nomad, cyber-samurai.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~204-book-ingest-audit-f139-robot-horse-grants.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == adna-nomad ==
UPDATE imported_classes
   SET markdown = '---
id: adna-nomad
name: Adna Nomad
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.11-13
category: rcc
tags: []
attribute_dice:
  IQ: "3d6+5"
  ME: "3d6+5"
  MA: "3d6+7"
  PS: "3d6"
  PP: "2d6+3"
  PE: "2d6+3"
  PB: "2d6+1"
  Spd: "3d6"
mdc_base: "P.E. + 6d6, +2d4 per level"
ppe_base: "2d6"
psionics:
  type: "minor"
  isp_base: "M.E. + 2d6, +1d6 per level"
  powers: ["Resist Thirst", "Resist Fatigue", "Summon Inner Strength", "Presence Sense"]
  powers_starting: 0
occ_restrictions:
  only: ["group:optional"]
  note: "Any Adventurer O.C.C.; Rogue Scholar, Rogue Scientist, Wilderness Scout and an educated Vagabond appeal most. No Men of Arms or Magic occupations."
bonuses:
  combat: { perception: 3 }
  saves: { spell_magic: -2, disease: 2, possession: 2, other: [ { label: "vs heat and cold", bonus: 3 } ] }
equipment_starting:
  - { item_id: "l-20-pulse-rifle", qty: 1 }
  - { item_id: "e-clip", qty: "2d4+4" }
  - { choose: 1, label: "Vibro-Knife or Neural Mace", qty: 1, from: ["vibro-knife", "neural-mace"] }
  - { choose: 1, label: "survival knife or hand axe", qty: 1, from: ["survival-knife", "hand-axe"] }
  - { item_id: "backpack-large", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "utensil-kit-rifts", qty: 1, note: "A set of cookware and eating utensils." }
  - { item_id: "sack", qty: "1d4" }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "flint", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 3 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "geiger-counter", qty: 1 }
  - { choose: 1, label: "gas mask or air purifier", qty: 1, from: ["gas-mask", "air-filter"] }
  - { item_id: "infrared-binoculars-digital-distancing-readout", qty: 1 }
  - { item_id: "goggles", qty: 1 }
  - { item_id: "walkie-talkie-radio", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "pen", qty: "1d4" }
  - { item_id: "traveling-clothes", qty: 4 }
  - { item_id: "hooded-cloak", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "hammer-and-mallet", qty: 1 }
  - { item_id: "wooden-stake", qty: 4 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "walking-stick", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "shovel", qty: 1, note: "Printed as a collapsible shovel." }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as sturdy, comfortable hiking boots." }
  - { choose: 1, label: "living or robot horse", qty: 1, from: ["riding-horse", "rh-1001a-appaloosa-light-robot-horse", "rh-1002b-mustang-medium-robot-horse", "rh-1003c-arabian-robot-horse", "rh-1004d-war-horse-heavy-robot-horse"], note: "Only with a Horsemanship skill: a living or robot horse (the book names no robot model, so any of the four Bandito Arms models), plus saddlebags and gear. The mule, and the light M.D.C. riding animal with Horsemanship: Exotic, are not stored." }
natural_abilities:
  - name: "Mega-Damage being of normal strength"
    description: "M.D.C. equal to the P.E. attribute number plus 6D6, plus 2D4 per level of experience. Despite the M.D.C. body, strength is normal: punches, kicks and other physical attacks inflict S.D.C. damage."
  - name: "Smart and adaptive"
    description: "Smart, resourceful and highly adaptive. Physical maturity at 21; a healthy female can bear one child as often as every four years, after an 18 month gestation. Most mate for life."
  - name: "Minor psychic"
    description: "Every Adna is a Minor Psychic with Resist Thirst (6), Resist Fatigue (4), Summon Inner Strength (4) and Presence Sense (4). I.S.P. is the M.E. attribute number plus 2D6, +1D6 per level of experience."
special_abilities:
  - name: "Lore: Traversing the Megaverse"
    description: "Special skill, base 50% +3% per level of experience. Familiar with other key dimension-traveling races (Temporal Raiders, True Atlanteans, the Naruni, the Minions of Splugorth, the peoples of Phase World and the Three Galaxies) and with common and commercial means of dimensional travel such as stone pyramids, ley line nexus points, Temporal Raiders, Line Walkers and Ley Line Rifters. Cannot open a Rift; must hire one or seize an opportunity."
trackable_resources: []
restrictions:
  - "Alignment: any, but tend to be Principled (25%), Scrupulous (30%), Unprincipled (20%) or Anarchist (10%)."
  - "Magic: none. The Adna avoid magic."
  - "Vulnerability: -2 to save vs magic, and no P.E. or O.C.C. bonuses to save vs magic apply."
  - "The Long Death: 98% of all Adna carry this genetic disease, which makes them sterile and eventually kills them. The healthy 2% may carry it and pass it on (50% chance)."
  - "Cybernetics and bionics: none to start; taken only for medical, life-saving reasons."
  - "Equipment replaces the O.C.C.''s standard equipment. Money is in addition to the chosen O.C.C.''s: an extra 1D6x1,000 Universal Credits and 4D6x1,000 credits of exotic tradable goods."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 11-13 (cache p012-p014), a scan; every number read off 200 dpi renders of cache p013 (printed 12, the whole stat block) and checked against the OCR. Heading Adna - Optional Player Character or NPC. The stat block ends on printed 12; Alliances and Allies and Rivals and Enemies continue on printed 13. Entry printed 11 starts mid-page under the Aardan Tek note. || CATEGORY: a race that takes an O.C.C. No xp_table: the book prints none; the Experience Level line gives NPC levels only, and the race uses the chosen O.C.C.''s table. || NAME: the entry is titled Adna Nomads and the stat block Adna; stored as Adna Nomad. Also known as The Quiet Wanderers and End Men. || M.D.C.: Mega-Damage Capacity, P.E. attribute number plus 6D6, plus 2D4 per level, stored as mdc_base; so no men_of_arms line. Physical attacks do S.D.C. damage (ability text). || P.P.E. 2D6. Horror Factor not applicable. || PSIONICS: All Adna are Minor Psychics with Resist Thirst (6), Resist Fatigue (4), Summon Inner Strength (4) and Presence Sense (4), granted by name; I.S.P. M.E. attribute number plus 2D6, +1D6 per level. || BONUSES: +3 Perception (perception 3), +2 vs disease, +2 vs possession, +3 vs heat and cold (saves.other). The Vulnerabilities line -2 to save vs magic is stored as spell_magic -2; that P.E. and O.C.C. bonuses to save vs magic do not apply cannot be expressed and is a restriction line. || SPECIAL SKILL: Lore: Traversing the Megaverse, base 50% +3% per level; the catalog has no such skill, so it is a special ability with the printed figure. || OCCUPATIONS: Any Adventurer O.C.C., no Men of Arms or Magic; stored as only group:optional (the catalog''s Scholars and Adventurers group). || EQUIPMENT: printed to be used instead of the O.C.C.''s; the composition cannot replace an O.C.C.''s gear, so this is said in a restriction line. Stored with catalog slugs: L-20 Pulse Rifle; 1D4+2 E-Clips for each of two weapons stored as 2D4+4; Vibro-Knife or Neural-Mace; survival knife or hand axe; large travel backpack as backpack-large; bedroll or sleeping bag as sleeping-bag; 1D4 medium sacks as sack; 1D4 small sacks; flint; 60 feet of rope as three 20-foot lengths; canteen; Geiger counter; gas mask or air purifier (air-filter); electronic distancing binoculars as infrared-binoculars-digital-distancing-readout; goggles; small hand-held short-range radio as walkie-talkie-radio; language translator; handheld computer; note pad and 1D4 pens (the book says pens or mechanical pencils); four sets of travel clothes; hooded cloak (comfortable coat or hooded cloak); small silver cross; mallet as hammer-and-mallet; four wooden stakes; a suit of light M.D. body armor (35 M.D.C.) as light-mdc-body-armor, whose catalog row carries no M.D.C. figure. Granted since ~116 and ~117: walking stick (1D8 S.D.C.) as walking-stick, tinder box as tinder-box, collapsible shovel as shovel, hiking boots as work-boots-rifts. Granted under BOOK-INGEST-AUDIT F139: the set of cookware and eating utensils as utensil-kit-rifts, and the Horsemanship character''s optional mount as a choice of riding-horse or a robot horse. The book names no robot model, so the choice offers all four Bandito Arms models (Rifts World Book 14: New West p.196-200), each through a gear row pointing at its vehicles row (Nate''s ruling, 2026-10-15). The mule and the M.D.C. riding animal are in GM Notes. NOT STORED, no catalog row: the energy sidearm of choice and 1D6+1 items central to the O.C.C.; in GM Notes. || MONEY: printed as in addition to the O.C.C.''s amount (1D6x1,000 credits and 4D6x1,000 in tradable goods). Not stored as starting_money, which would replace the O.C.C.''s money; a restriction line. || NOT STORED: size 8-9 feet, weight 300-500 pounds, life span 4D6+90 years (ancestors lived to 220), slave market value, allies, enemies and habitat; in GM Notes."
---

## Lore

The Adna are among the rarest D-Bees in North America: tall, slender
wanderers with salmon-pink skin, very long and supple arms that reach past
their knees, long heads, slit nostrils and big, soft gray eyes. For all
their height they move gracefully, and their gentle smiles make most people
trust them on sight. An Adna on the road usually carries a bedroll and a
heavily loaded pack, leans on a walking stick, and dresses to blend in with
the countryside.

The race is dying. A hereditary illness the Adna call the Long Death first
leaves its victims sterile and then kills them, and no medicine or magic has
touched it. Nearly all Adna have it, and even the few who do not may pass it
to their children. Most have accepted this with a calm, philosophical
cheer, though a quiet sorrow follows them. Some came to Rifts Earth for one
last adventure, some to find other healthy Adna, and a few to plead with the
Gene-Splicers for help.

They are born explorers who never lose their wanderlust, and they prefer
quiet wilderness to crowded towns, especially the forests and mountains of
the eastern seaboard. Their peaceful ways are so well known that even
barbarian raiders usually leave them alone. They love people, art, music,
books and knowledge, and dislike conquerors and slavers.

## GM Notes

Size 8-9 feet (2.4 to 2.7 m), with a reach of 6-7 feet. Weight 300 to 500
pounds (135 to 225 kg). Life span 4D6+90 years; their ancestors lived to
220.

Experience Level: 1D8+5 for NPCs; player characters start at first or
second level.

Standard equipment the catalog has no row for: one energy sidearm of
choice and 1D6+1 items central to the chosen O.C.C. A character with a
Horsemanship skill may start with a living or robot horse or mule, or a
light M.D.C. riding animal with Horsemanship: Exotic, plus saddlebags and
gear; the living horse and the robot horse are stored as a choice, and
the mule and the riding animal are not.

Slave Market Value: same as psychic human slaves.

Allies: they get along with humans and most D-Bees, and especially enjoy
carefree peoples such as Kraks, Larmac, Fennodi, Bubblemakers, Grackle
Tooth, most Idie Swamp Men and some Bayou Ursines. Enemies: the Splugorth
and their minions above all, then the Naruni and Kreeghor, and anyone who
makes war or enslaves. Horune Pirates believe drinking an Adna''s blood
grants wisdom and prophetic dreams.

Habitat: anywhere a human can live, but they favor quiet wilderness. A
small community has settled in the Appalachian Mountains, and some search
eastern Europe for Gene-Splicers.
',
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, 'the living horse is stored, and the rest of that choice is not.') > 0
   AND length(markdown) = 11117;

-- == cyber-samurai ==
UPDATE imported_classes
   SET markdown = '---
id: cyber-samurai
occ_group: men-of-arms
men_of_arms: true
name: Cyber-Samurai
system: rifts
source_book: Rifts World Book 8: Japan p.80-82
category: occ
tags: [combat, augmented]
attribute_requirements: { ME: 10, MA: 10 }
mdc_base: 180
starting_money: "2d6x1000"
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
bonuses:
  attribute_minimums: { PS: 22, PP: 18, Spd: 50 }
skills:
  hand_to_hand: { costs: { zanji_shinjinken_ryo: 2 } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%; the book prints Basic Radio." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%; the book prints Basic Math." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Japanese at 98%." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The book prints Language and Literacy: Japanese at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "American, +10%." }
    - { name: "Computer Programming", base: 40, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 60, per_level: 4, note: "+20%; the book prints Horsemanship." }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Piloting: two of choice (+10%)." }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book prints W.P. Archery and Targeting. It can be changed to Samurai Archery (the True Samurai''s) at the cost of two other skills; see Special Training in the class text." }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "The Targeting half of the book''s W.P. Archery and Targeting." }
    - { choose: 1, from: ["Hand to Hand: Karate", "Hand to Hand: Jujitsu"], note: "Hand to Hand: Karate or Jujitsu. Either may be changed to Zanji Shinjinken-Ryo (described in the True Samurai O.C.C.) at the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - "Electrical"
      - { name: "Espionage", bonus: 5 }
      - "Mechanical"
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications, Domestic and Espionage +5%, Pilot +5%, Pilot Related and Technical +10%. Medical: First Aid and Paramedic only. Science: Astronomy and Mathematics only. Physical: any except Acrobatics. All new skills start at level one proficiency."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 4, count: 3 }
      - { level: 8, count: 3 }
      - { level: 12, count: 3 }
equipment_starting:
  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["ha-5-hiker-body-armor", "ha-7-frontiersman-body-armor", "ha-4-hiker-body-armor", "ha-6-frontiersman-body-armor", "at-a11-kuru-street-armor", "at-a14-infantry-trooper-body-armor", "ia-100-infiltrator-body-armor", "ha-20-juicer-environmental-armor"] }
  - { item_id: "clothing", qty: 1, note: "Several changes of clothes (kimonos)." }
  - { item_id: "utility-belt", qty: 1, note: "With ammo pouches." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "food-rations", qty: "2d4", note: "2D4 days of rations." }
  - { item_id: "samurai-bow", qty: 1, note: "Samurai longbow." }
  - { item_id: "arrows-standard", qty: 2, note: "20 regular arrows; the row is sold by the dozen." }
  - { choose: 1, label: "high-tech arrows", qty: 10, from: ["arrowhead-light-explosive", "arrowhead-medium-explosive", "arrowhead-heavy-explosive", "arrowhead-high-explosive", "arrowhead-gas", "arrowhead-smoke", "arrowhead-flare", "arrowhead-tranquilizer-gas", "arrowhead-paralysis-gas"] }
  - { choose: 1, label: "energy weapon", qty: 1, from: ["at-8-laser-pistol", "h-8-laser-pistol-h-brand", "super-h-8-laser-pistol-h-brand", "at-20-sharpshot-police-special-laser-pistol", "h-20-sniper-pistol-h-brand", "at-30-combat-laser-pistol", "h-30-siege-pistol-h-brand", "at-130-particle-beam-pistol", "h-10-combat-laser-pistol", "h-13-ion-pulse-pistol", "at-84-sharpshot-laser-rifle", "h-84-sniper-rifle-h-brand", "at-88-combat-laser-rifle", "at-230-particle-beam-rifle", "h-12-defender-ion-pulse-rifle", "h-25-super-rifle-h-brand"] }
  - { item_id: "e-clip", qty: "1d4", note: "1D4 extra E-clips for the energy weapon: the ArmaTech/H-Brand pistol or rifle E-clip to match it." }
  - { choose: 2, label: "vibro-blade or ancient weapon", qty: 1, from: ["vibro-katana", "vibro-wakizashi", "vibro-saber-short-sword-ninja-short-sword", "vibro-sword-large-one-handed-sword-straight", "vibro-knife-tanto-jitte-sai", "vibro-no-dachi-large-two-handed-swords-h-brand", "vibro-yari-spear", "vibro-naginata-bisento", "vibro-kusari-gama", "katana-rifts", "wakizashi-rifts", "traditional-crossbow"] }
  - { item_id: "daisho-rifts", qty: 1, note: "An S.D.C. daisho (katana and wakizashi)." }
  - { choose: 1, label: "transportation", qty: 1, from: ["riding-horse", "rh-1001a-appaloosa-light-robot-horse", "rh-1002b-mustang-medium-robot-horse", "rh-1003c-arabian-robot-horse", "rh-1004d-war-horse-heavy-robot-horse", "hovercycle", "km-200-jet-pack", "the-highway-man-motorcycle", "the-wastelander-motorcycle", "road-boss-motorcycle"], note: "The book names no robot horse model, so any of the four Bandito Arms models is offered." }
special_abilities:
  - name: "Partial Bionic Reconstruction"
    description: "Both arms and both legs are bionic; the pelvis and hips, shoulders, collarbone and spine are reinforced with metal rods, an exoskeleton and cybernetic implants to carry them, and some internal organs are cybernetic. The character is an M.D.C. cyborg with 180 M.D.C. for the main body. The bionics set P.S. 22, P.P. 18 and Spd 50 (35 mph/56 km/h)."
  - name: "Additional Bionic Features"
    description: "Four bionic features and accessories of choice from Rifts (pp. 239-243) and/or Rifts Japan. More may be bought later at the character''s own expense, or be provided by an employer or liege once the character has proved himself."
  - name: "Cybernetic Implants"
    description: "In addition to the partial bionics, up to five cybernetic enhancements of choice, except cyber-armor. More may be bought later at the character''s own expense, or provided by an employer or liege."
restrictions:
  - "No mystic training: the cyber-samurai gets none of the special powers or skills of the True Samurai O.C.C."
  - "Cybernetics: no cyber-armor among the five starting implants."
side_effects: "Money: 2D6 x 1000 credits, plus 2D4 x 1000 credits in salable Black Market items. An employed samurai may draw a stipend or salary of 1D4 x 1000 credits a month, which may rise as he gains favor with his daimyo, corporation or government. Transportation may instead be another similar open vehicle. About 10% of cyber-samurai own a true, ancient pre-Rifts samurai sword (a powerful rune weapon) and 15% a true samurai sword of recent make and lesser power (see the True Samurai O.C.C.); the rest rely on vibro-blades, energy weapons and modern gear."
extraction_notes: "Rifts World Book 8: Japan printed 80-82 (cache p081-p083, a text layer, page_offset +1). The entry opens on printed 80 under the section heading Republic of Japan & Mercenaries, and High-Tech O.C.C.s; printed 80 (cache p081) carries corrupt glyphs, so every number on it was read off a 200 dpi render. Printed 81 (cache p082) has no text (an illustration). The stat block (The False Cyber or Tech-Samurai O.C.C.) starts on printed 80 and continues on printed 82 from Electrical: Any through Money and Cybernetics: See above, after which printed 82 opens the Tech-Ninja O.C.C. || XP: the Cyber-Samurai column on printed 216 (cache p217), read off a render: 0 / 2,101 / 4,201 / 8,401 / 17,201 / 25,401 / 35,801 / 51,001 / 71,201 / 96,401 / 131,601 / 181,801 / 232,001 / 282,201 / 342,401. || GROUP: men-of-arms and men_of_arms: true, from the section heading (Mercenaries and High-Tech O.C.C.s) and the warrior text; the class states an M.D.C. main body of 180 as mdc_base. || ATTRIBUTES: requirements M.E. and M.A. 10; the book says the bionics CHANGE P.S. to 22, P.P. to 18 and Spd to 50. Stored as attribute_minimums, a floor: a natural roll above those figures is not lowered, which the book''s ''changed as follows'' would do. || SKILLS: Basic Radio is Radio: Basic 45+10; Basic Math is Mathematics: Basic 45+10; Language and Literacy: Japanese at 98% is Language: Native Tongue 98 and Literacy: Native Language at a flat 98; Language: American is a one-pick Language: Other at +10 (the catalog has no American row; a fixed Language: Other reads as a missing selection); Computer Programming 30+10; Horsemanship is Horsemanship: General 40+20; Wilderness Survival 30+5; Piloting two of choice +10% as a choose-2 over Pilot; W.P. Archery and Targeting as the two catalog rows W.P. Archery and W.P. Targeting. || HAND TO HAND: Karate or Jujitsu, as a choose-1. Zanji Shinjinken-Ryo at the cost of two other skills, priced in the hand_to_hand block. The book also sells Samurai Archery (in place of Archery and Targeting) for two other skills; there is no Samurai Archery catalog row, so that trade is prose in the W.P. Archery note. || RELATED: six, plus one at levels 3, 6, 9 and 12. Science Astronomy and Mathematics only, read as Astronomy and both Mathematics rows. || SECONDARY: the book prints three secondary skills at levels 1, 4, 8 and 12, read as three at each of those levels (the same reading the other Japan drafts give this sentence). || BIONICS: the four bionic features and up to five cybernetic implants are a player''s choice from two books, with no key to grant them; they are prose abilities. || EQUIPMENT: the book''s first armor is a high-tech Samurai mega-damage body armor of 1D6x10+60 M.D.C., which has a catalog row now (cyber-samurai-armor; samurai-armor is the True Samurai''s magic armor) that the choice does not list; the choice still offers the samurai-styled HA-5 and HA-7 first and then other Japan armor, per the book''s ''or one of the other types of armor available in Japan''. Ten high-tech arrows of choice are one choice of arrowhead type, quantity 10. The energy weapon of choice is offered from the Japan pistols and rifles. 1D4 E-clips as the generic e-clip row, since the matching pistol or rifle clip depends on the weapon. Two vibro-blades or ancient weapons as a choose-2. The S.D.C. daisho is daisho-rifts. Transportation: horse, robot horse, hovercycle, jet pack or one of three motorcycles as a choice (BOOK-INGEST-AUDIT F139). The book names no robot horse model, so the choice offers all four Bandito Arms models (Rifts World Book 14: New West p.196-200), each through a gear row pointing at its vehicles row (Nate''s ruling, 2026-10-15). The book''s similar open vehicle is prose. Ammo pouches are in the utility belt note. Money: 2D6x1000 credits stored; the Black Market items and the monthly salary are prose."
---

## Lore

The cyber-samurai, also called the techno-samurai or tech-samurai, is a modern warrior of the Republic of Japan who emulates the old samurai in part. Many know martial arts and the sword, carry themselves with the swagger of nobility and dress the part down to vibro-daisho and samurai-styled armor; some even try to live by Bushido. They are not "true" samurai, whatever their ancestry, and some are little different from North America''s Headhunters or any other high-tech mercenary.

To match the power of high-tech weapons, most become partial conversion ''borgs, giving up part of their humanity to become powerful warriors. They still follow the Way of the Sword and the Bow, but the sword is often a vibro-blade and the arrows may carry explosive warheads, and many ride motorcycles, hover vehicles or power armor instead of horses.

The most dedicated act the part fully: men and women of honor who live to serve a family clan, nation, military or corporate master such as Ichto or the Otomo Shogunate and H-Brand. Some corporations in the New Republic and Ichto value them as loyal bodyguards, agents and soldiers, and a cyber-samurai may pledge himself to a corporation as to a daimyo. The New Republic''s Army keeps a few elite units of them.

## Cyber-Ronin

Some wander masterless as mercenaries, bounty hunters, adventurers, bandits or champions of the helpless. Unlike traditional ronin, cyber-ronin see themselves as romantic figures, often turn down employment to keep their independence, and are frequently irreverent toward the traditional samurai, though many are as true to the samurai ideals as any traditionalist.

## The "False" Samurai

Traditional samurai call these machine warriors "false samurai", mimics of Bushido, and most hold them in contempt; many refuse to work with them and some seek duels to humiliate them. Traditional ronin tend to be more accepting. Even so, the most ardent traditionalists have come to respect cyber-samurai who have proven their courage and dedication.

## GM Notes

The cyber-samurai has none of the true samurai''s mystic training and gets none of that O.C.C.''s special powers or skills. The bionic body''s four additional features and five cybernetic implants are chosen by the player from Rifts (pp. 239-243) and this book, cyber-armor excepted.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyber-samurai'
   AND instr(markdown, 'the robot horse is a vehicles row with no gear row and is prose.') > 0
   AND length(markdown) = 13923;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'adna-nomad' AND instr(markdown, 'living or robot horse", qty: 1, from: ["riding-horse", "rh-1001a-appaloosa-light-robot-horse"') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, '"riding-horse", "rh-1001a-appaloosa-light-robot-horse", "rh-1002b-mustang-medium-robot-horse"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'adna-nomad' AND instr(markdown, 'the living horse is stored, and the rest of that choice is not.') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, 'the robot horse is a vehicles row with no gear row and is prose.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('adna-nomad', 'cyber-samurai') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~204-book-ingest-audit-f139-robot-horse-grants.sql');
