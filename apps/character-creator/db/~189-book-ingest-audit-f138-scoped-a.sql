-- Scoped skill bonuses move from prose to keys on eight classes of Warlords of Russia, Japan and Underseas (BOOK-INGEST-AUDIT F138, row 32a)
-- 8 classes, each replaced whole: huntsman-trapper, travelling-story-teller, ectohunter, sohei-warrior-monk, mystic-ninja, dolphin, killer-whale, humpback-whale.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~189-book-ingest-audit-f138-scoped-a.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F138, first of five rows (32a, 32b, 33, 34a, 34b):
-- eight classes of Warlords of Russia, Japan and Underseas carried a skill bonus
-- that applies to SOME skills only as prose. Each now holds it as a scoped
-- category entry - a second entry for the same category with `only` or
-- `only_prefix` and its own `bonus` - which categoryAllows and categoryBonus rank
-- most specific first (F109). Every figure was read off a render of the cited page
-- on 2026-10-14:
--   huntsman-trapper         Warlords printed 68: Technical +10%, Whittling +15%
--   travelling-story-teller  Warlords printed 70: Technical +10%, languages +15%
--   ectohunter               Warlords printed 64: Technical +10%, language or
--                            computer +15%
--   sohei-warrior-monk       Japan printed 59-60: Rogue Streetwise +8%,
--                            Concealment +6%; Technical +10% on languages
--   mystic-ninja             Japan printed 53: Technical +10% on languages
--   dolphin                  Underseas printed 77: Radio: Basic only (-10%)
--   killer-whale             Underseas printed 86: Radio: Basic only (-10%)
--   humpback-whale           Underseas printed 91: Radio: Basic only (-10%)
-- Secondary skills are untouched: the books give them no bonus.

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
      - { name: "Technical", only: ["Whittling & Sculpting"], bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Choose five other skills at level one and two additional at levels 4, 8 and 12. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: none, except Detect Concealment, Intelligence and Tracking (all +5%). Mechanical: none. Medical: First Aid, Holistic Medicine and Brewing only. Military: none (Falconry is offered here only because the catalog files it under Military; the book prices it under Technical at +15%). Physical: any, except Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft (horsemanship is filed in its own category here). Pilot Related: any, but usually none. Rogue: none, other than Cardsharp and Prowl (+10%). Science: Astronomy, Botany and Advanced Math only (+5%). Technical: any (+10%; Whittling and Falconry are +15%). W.P.: any. Wilderness: any (+10%)."
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
extraction_notes: "WB17 Warlords of Russia printed 66-69 (cache p067-p070, cache page = printed folio + 1), read off the text layer. Heading The Huntsman-Trapper O.C.C. at the top of printed 66; the special abilities are printed 66-68 and the stat block headed The Russian Huntsman-Trapper O.C.C. (also known as Woodsman and Trapper) starts on printed 68. The entry ends on printed 69, where its Note, Money and Cybernetics lines are interleaved in the text layer with the opening of the Travelling Story Teller (cache p070 lines 57-80 are the Huntsman''s). || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Huntsman-Trapper ladder on the Experience Tables, printed 6, read off a render; the book misprints level 5 as 18,501, level 4 ends at 16,500, so 16501 is stored. || BONUSES: +2 initiative, +3 pull punch, +3 vs possession stored flat; +1 to save vs magic is stored as spell_magic only (a reading: the book says magic, not spell or ritual); +2 vs poison and disease is stored as toxins_poisons 2 and disease 2; +1 vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 is stored as horror_factor 1 flat for level 1 plus eight at_level entries. || P.P.E.: 4D6 + P.E. attribute number and +1D4 per level, stored in ppe_base and repeated as a special ability. || SPECIAL ABILITIES: the three percentile abilities (Track and Trap 20%/30% +5%, Recognize Supernatural Shapechangers 30% +5%, Forest-wise 20% +4%) are special_abilities prose. Track & Trap Animals is ALSO stored as an occ skill at 20/5 because the catalog holds a row of that name at the same figures; that is a reading, and the 30% trapping number lives only in its note. Recognize Supernatural Shapechangers and Forest-wise have no catalog skill row. The Code of the Huntsman-Trapper (printed 68) is stored as a special ability, paraphrased. || SKILLS NOT STORED: Lore: Geomancy & Ley Lines (+10%) has no catalog row and is left out. Speaks Faerie has no catalog language row; it is stored as one of three Language: Other picks at +10%. || SKILL READINGS: Lore: Faeries is the catalog''s Lore: Faeries & Creatures of Magic; Identify Plants & Fruits is Identify Plants & Fruit; Tracking is Tracking (people); Advanced Math is Mathematics: Advanced. Falconry is filed under Military in the catalog, so Military appears with only Falconry at the +15% the book prints under Technical, although the book says Military: None; Whittling at +15% is a second Technical entry naming Whittling & Sculpting alone at +15, beside the flat +10 for the rest of Technical (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Prowl is filed under Physical and is reached by name through the Rogue only-list at +10%. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft (the Explorer on printed 65 says military aircraft; this entry does not); Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Huntsman may know how to ride a horse. Hand to Hand: Expert, no others available, is costs: {}. || MONEY: the book prints no coin: 4D4x100 credits WORTH of furs, horns, bone, nuggets of silver or gold and other tradeable goods (the text layer prints 4D4xlOO). starting_money is 0 and the goods are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; flint and tinder box, frying pan, a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, belt, boots, 20 feet of wire and personal items have no catalog row and are in GM Notes. Rows exist now for the skinning knives, cooking utensils, bedroll, fur cloak or long coat and note pad (knife-skinning, utensil-kit-rifts, bedroll-rifts, cape-or-cloak-long, note-pad); the class does not list them and they are still in GM Notes. The text layer prints scalable for sealable. The armor is stored as the light homemade suit; the lore text on printed 67 says such armor is typically 30-60 M.D.C. and rarely environmental. || NOT STORED: Secret Resources and the Note on how Reavers, War Camp soldiers, Bogatyrs, Demon Hunters and Ectohunters regard the class are in GM Notes; only 15% have partial bionics (printed 67)."
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
   AND instr(markdown, 'Whittling at +15% is not stored (Technical is a flat +10).') > 0
   AND length(markdown) = 19286;

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
      - { name: "Domestic", bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite", "Boat: Ships", "Boat: Submersibles", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15 }
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
extraction_notes: "WB17 Warlords of Russia printed 69-71 (cache p070-p072, cache page = printed folio + 1), read off the text layer. Heading Travelling Story Teller O.C.C. on printed 69, where the text layer interleaves its opening with the end of the Huntsman-Trapper (cache p070 lines 57-80 belong to the Huntsman); the stat block headed The Russian Story Teller O.C.C. starts on printed 69 and the entry ends with its Vehicle, Secret Resources, Money and Cybernetics lines at the top of printed 71, past the page break. || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the ladder naming the Travelling Story Teller on the Experience Tables, printed 6, read off a render. || BONUSES: +1 vs possession, +1 vs poison and disease (stored as toxins_poisons 1 and disease 1) and +2 vs Horror Factor, all flat. || LORE: the book prints Lore: all those applicable to Europe and Asia, including history, animal, demon, monster, magic and faerie lore (+20%). Stored as the five the line names: Lore: History of Russia, Lore: Cattle & Animals (a reading for animal lore; it is the only animal lore row, filed under Cowboy), Lore: Demons & Monsters, Lore: Magic, Lore: Faeries & Creatures of Magic, each at catalog base +20. Other lores a GM may judge applicable (D-Bee, Vampires, Religion, Psychics & Psionics) are NOT stored; the line says including, so the five are not a closed list. || SKILL READINGS: Speaks Euro and two other languages of choice (+20%) is Language: Euro at 70 plus two Language: Other picks at +20; Literacy: one of choice is one Literacy: Other pick at +10; Identify Plants & Fruits is Identify Plants & Fruit. Technical +15% to language skills is a second Technical entry, the Language rows by prefix at +15, beside the flat +10 for the rest of Technical (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Medical: none, other than those above, is stored as no Medical category. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft; Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Story Teller eventually acquires a horse. Hand to Hand: Basic, no others available, is costs: {}. || MONEY: 3D4x20 credits, as printed. || EQUIPMENT not stored as rows: one M.D. weapon of choice; butcher''s knife, meat cleaver, cooking utensils, frying pan, small pot, small kettle, bowl and grinder, a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row and are in GM Notes. The cloak or long coat, bedroll, note pad and dozen pencils have rows now (cape-or-cloak-long, bedroll-rifts, note-pad, pencil); the class does not list them and they stay in GM Notes too. The book attaches the 600 lb test strength to the 10 feet of thin nylon cord here. || NOT STORED: Secret Resources (regard and influence) and the neutrality that lets a Muzhik cross between Warlords'' Spheres of Influence without fees or tribute are in GM Notes. The body text on printed 69 says they are well versed in medicine and practical skills; no numbers beyond the skill list."
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
   AND instr(markdown, 'Technical +15% to language skills is not stored (Technical is a flat +10).') > 0
   AND length(markdown) = 13282;

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
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Airplane", "Helicopter", "Jet Aircraft", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language", "Computer"], bonus: 15 }
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
extraction_notes: "WB17 Warlords of Russia printed 61-64 (cache p062-p065, cache page = printed folio + 1), read off the text layer. The stat block starts on printed 63 and ends with Money and Cybernetics on printed 64. || HEADING: Ectohunter O.C.C., also known as Ghost Hunters and spiritualists; listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base. || XP: the Ectohunter, Travelling Story Teller and Warlord Cyber-Doc ladder as given in the brief, read off a render of the Experience Tables on printed 6. || SPECIAL ABILITIES: the eleven numbered Special Ectohunter O.C.C. Abilities (printed 62-63) are stored as special_abilities, except 6 (P.P.E.), which is ppe_base, and 10 (O.C.C. Bonuses), which is split: +1 pull punch is in bonuses, +1 to save vs illusions is saves.other because the book says illusions and not illusionary magic, and +2 initiative against ghostly beings only is conditional and stored as an ability. || HORROR FACTOR: +1 at levels 1-10, 12 and 14 stored as horror_factor 1 plus eleven at_level entries; the book qualifies it as applying to supernatural monsters and horrors, which is stated in the ability and is a reading. || POSSESSION: +10 flat plus +1 at levels 2, 4, 6, 8, 10, 12 and 14, as printed. || P.P.E.: 4D6 plus the P.E. attribute number, plus 1D4 per level. The class casts no spells of its own (it reads scrolls and uses magic items), so there is no magic block. || PSIONICS: not a requirement; about one third have minor or major psionics; no block and no roll is printed. || VULNERABILITY: the M.E. loss and insanity rolls are in side_effects and an ability; nothing applies them. ''Every other level'' prints no starting level. || SKILLS: Speaks Euro and two other languages of choice (+20%) is read as Euro at +20% and two Language: Other picks at +20%. Surveillance Systems maps to Surveillance, Read Sensory Equipment to Sensory Equipment. Lore: one of choice is one pick across the Lore: rows of Technical and Cowboy. Pilot: one of choice (+5%) offers all of Pilot; the O.C.C. line prints no exclusion. W.P. Energy Weapon of choice is a W.P. category pick with the restriction in the note. || PILOT EXCEPT: ''except robots, power armor, military vehicles, ships and aircraft'' read literally as all ships and all aircraft, mapped to the Robot rows, the Military: rows, Boat: Ships, Airplane, Helicopter, Jet Aircraft, both Fighter Combat rows, the three Space craft rows and Wingrider Flying Wing. Air Assault Armor, Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored, and a second Technical entry holds +15% for the Language and Computer rows by prefix (BOOK-INGEST-AUDIT.md F138, 2026-10-14); the catalog''s Computer Repair and Computer Hacking are filed under Electrical and Rogue, so the Technical line does not reach them. || MONEY: 1D6x1000 credits stored (the text layer prints !D6xlOOO); the 1D6x100 in tradeable goods is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon of choice; a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row. Clothing, bedroll and note pad rows exist now (clothing, bedroll-rifts, note-pad); the class does not list them. Light suit of M.D.C. body armor maps to light-mdc-body-armor, the pair of silver knives to two knife-silver-plated, the mallet to hammer-and-mallet. || NOT STORED: the fee structure (as little as 100 credits to tens of thousands, a nonrefundable 10% retainer plus expenses), the nationality percentages, and Secret Resources are prose in GM Notes."
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
   AND instr(markdown, '+15% to language or computer skills is in the note only.') > 0
   AND length(markdown) = 18792;

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
      - { name: "Technical", only_prefix: ["Language"], bonus: 10 }
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
extraction_notes: "Rifts World Book 8: Japan printed 58-60 (cache p059-p061, text layer, page_offset +1). The entry opens under Sohei / Warrior Monk O.C.C. on printed 58 and the female sohei note ends mid-column on printed 60, where Yamabushi begins. Printed 59 and the top of 60 were rendered to read the digit cipher: parry arrows +1 at levels 4, 6, 9, 12 and 15; horror factor at 2, 4, 7, 9, 11, 13 and 15; money 3D4x10 (the book prints 3D4xlO even on the render). || XP: the Bishamon, Fighting Monk / Sohei, Warrior Monk column on the Experience Point Tables page (cache p217, printed folio 216), read off a render: 0 / 2,201 / 4,401 / 8,801 / 17,601 / 24,001 / 35,001 / 50,501 / 72,501 / 98,501 / 140,501 / 200,501 / 250,501 / 325,501 / 400,501. || GROUP: men-of-arms, men_of_arms: true. The book files it under no Men of Arms heading (the section is the New Empire''s traditional O.C.C.s); the sohei is a martial artist first, as the samurai. No S.D.C. or hit point formula is printed. || VARIANTS: printed 60 says women join as nuns with the same martial arts and a different O.C.C. skill list. A variant cannot remove a parent skill, so the parent holds the skills both lists share and each variant adds its own: the monk adds Land Navigation, Magic Lore and W.P. Spear and restates Mathematics: Basic at +20%; the nun adds Cook, Sew (Sewing), Sing and Holistic Medicine, and keeps Mathematics: Basic at +10%. Related and secondary skills, abilities and equipment are shared, as the book says. || SKILLS: Japanese at 98% is stored as Language: Native Tongue and Literacy: Native Language at 98 (no Japanese rows in the catalog). Begging is printed at 20% +3% for this class; the catalog row holds 30% +3%, and the class states the printed figure. Fasting 40% +3% matches the catalog. Oriental Philosophies is one choice of five at +15%. Feng Shui or Geomancy (15% +5%) has a catalog row now (Lore: Feng Shui/Geomancy, base 15, +5); the class does not grant it and still stores a special ability with the percentage in prose. Sohei Meditation (20% +6%) has no catalog row and is a special ability with its percentage in prose. || RELATED: five, plus one at levels 2, 5, 9 and 12. Technical is any, and its +10% applies to language skills only, so Technical is listed twice: once plain and once for the Language rows by prefix at +10. Rogue: Streetwise (+8%) and Concealment (+6%) only, each stored as its own Rogue entry with its own bonus (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Secondary: three, plus two at levels 4, 8 and 12, same limits without bonuses. || MYSTIC MARTIAL ARTS: one body hardening exercise at levels 1, 5 and 9 plus one zenjoriki power at level 14 (printed 59; powers printed 195-199). 2026-10-05, the picks (BOOK-INGEST-AUDIT.md F116): printed 59, ability 3, reads that one body hardening exercise/power can be selected at levels 1, 5 and 9, plus one zenjoriki power at level 14, and sends the reader to the mystic martial arts section (printed 195-199); it gives the class no art of invisibility. Stored as two pick groups: the seven body hardening exercises at levels 1, 5 and 9, and the six zenjoriki powers at level 14. The seven exercise definitions were replaced by the section''s fuller entries under the same names and with the same unconditional bonuses as before, and the six zenjoriki definitions were added; a picked exercise carries its own bonuses. The three level progression lines the groups replace were removed, which leaves the class with no level progression list. || BONUSES: +3 save vs possession; +1 save vs horror factor at levels 2, 4, 7, 9, 11, 13 and 15. The jodo extra attack and +1 parry (tied to staff or spear use) and the parry-arrows penalties are prose. Jujitsu''s own bonuses come from its skill row. Iron Hand''s +4 damage applies to hand strikes only and is prose. || MONEY: 3D4x10 credits'' worth of gold or tradeable goods. || EQUIPMENT: leaf armor, the Staff of Defense (90% of sohei), naginata as naginata-yari-rifts, knife, four robes, sandals or tabi as sandals, rope, backpack, three small sacks, a large water skin as water-skin-1-gallon, 4D4 days of rations as one food-rations. Towels are prose (no catalog row). The 6th-level bark armor is prose."
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
   AND instr(markdown, 'the per-skill bonuses are in the note, not stored.') > 0
   AND length(markdown) = 29527;

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
      - { name: "Technical", only_prefix: ["Language"], bonus: 10 }
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
extraction_notes: "Rifts World Book 8: Japan printed 51-55 (cache p052-p056, text layer, page_offset +1). The class runs from the Mystic Ninja O.C.C. heading on printed 51 through the Money and Cybernetics lines at the top of printed 54; Traditional Ninja Equipment and Ninja Gimmick Clothing follow on 54-55 (catalog gear rows from add-a-japan-traditional-gear.sql, none granted at start beyond the outfit, shuriken and emergency kits). Class stat block read from renders of printed 53 and 54; the Arts of Invisibility from a render of printed 195 (cache 196, a corrupt page). || GROUP: the book files the class under New Empire & Traditional O.C.C.''s (contents, printed 4), which names no group. Stored as men-of-arms with men_of_arms true because it is a warrior class built on Hand to Hand: Ninjitsu; its psionics are major but secondary. A judgment call. || XP: the Tech-Ninja, Mystic Ninja column of the Experience Point Tables (printed 216, cache p217), read off a render. || SKILLS: Japanese is stored as Language: Native Tongue and Literacy: Native Language at 96%; the catalog has no Japanese row. Pick Locks prints (10%) with no plus sign; read as +10%. Acrobatics prints (+5) with no percent sign; read as +5%. W.P. Archery and Targeting is stored as W.P. Archery (RUE), not the book''s own W.P. Bow. Ninja Horsemanship (54% +4%) is stored as Horsemanship: General at the printed percentage. Technical''s +10% applies to language skills only, so Technical is listed twice: once plain and once for the Language rows by prefix at +10 (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Secondary skills: none at level one, two at each of levels 2, 5, 9 and 12, the book''s own phrasing elsewhere (printed 53). || HAND TO HAND: the style''s attribute bonuses and level table live on the Hand to Hand: Ninjitsu catalog row and are not repeated here. || PSIONICS: major; Bio-Regeneration (self, via meditation) and Induce Sleep at level one, one Physical power per level from two, and Psi-Sword at level six. I.S.P. 1D4x10 plus M.E., +1D6+2 per level. || MYSTIC MARTIAL ARTS: the book gives one Art of Invisibility (it calls the category the Art of Stealth) at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group over the six arts taken at those six levels (BOOK-INGEST-AUDIT.md F116). || NOT STORED AS NUMBERS: the Mega-Damage Transformation is temporary and paid in P.P.E., so it is an ability, not mdc_from_hp_sdc. The bow''s dodge penalties are conditional and are prose. The save vs illusions is saves.other, not illusionary_magic. || 2026-10-05, MYSTIC ART OF STEALTH: printed 52, ability 2, read off a render: the character selects one power from the category at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group with at_levels [1, 3, 6, 9, 12, 15] over the six arts of invisibility, level 1 being the creation pick; six picks over six arts, so every art is held by level 15 (BOOK-INGEST-AUDIT.md F116). The six definitions were replaced with the readings of printed 195-196 shared by every Japan class that takes these powers; none prints an unconditional number, so none carries bonuses. The Art of Escape (Inton-Jutsu), ability 3 on printed 52, is granted outright, is printed only on this page and is not in that category; its definition was checked against the render (1D4 melee rounds, 3D4 melee rounds, 46% +3% per level) and left as it was."
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
   AND instr(markdown, '(add it to a language pick by hand)') > 0
   AND length(markdown) = 20576;

-- == dolphin ==
UPDATE imported_classes
   SET markdown = '---
id: dolphin
name: Dolphin
system: rifts
source_book: Rifts World Book 7: Underseas p.77-80
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+45"
hit_points_base: "P.E. + 6d6, +1d6 per level"
sdc_base: "2d4x10"
ppe_base: "P.E. + 2d4x10, +1d6 per level"
bonuses:
  combat: { attacks_base: 2, initiative: 3, strike: 2, dodge: 2, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 4, disease: 1, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    dolphin:
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
  spells_starting_groups:
    - { count: 2, from_list: "dolphin" }
  spells_schedule:
    - { level: 2, count: 1, from_list: "dolphin" }
    - { level: 4, count: 1, from_list: "dolphin" }
    - { level: 6, count: 1, from_list: "dolphin" }
    - { level: 8, count: 1, from_list: "dolphin" }
    - { level: 10, count: 1, from_list: "dolphin" }
    - { level: 12, count: 1, from_list: "dolphin" }
    - { level: 14, count: 1, from_list: "dolphin" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 25, per_level: 5, note: "Printed as Undersea Survival, with no bonus - the one cetacean entry that prints none." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One human language of choice (+20%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 11, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Communications", only: ["Sing"] }
      - { name: "Communications", only: ["Radio: Basic"], bonus: -10 }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence", "Pick Pockets"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only, so Radio: Basic has a Communications entry of its own carrying it and Sing''s entry carries none. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant dolphins are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one - unlike almost everything else imported from this book. It becomes mega-damage only while ley line charged."
  - "Horror Factor: NONE. The dolphin is the one cetacean in this chapter with no horror factor at all."
  - "Size: 5 to 7 feet (1.5 to 2.1 m) for most; 6 to 8 feet (1.8 to 2.4 m) for the bottle-nosed dolphin and pygmy killer whale; 8 to 20 feet (2.4 to 6.1 m) for most other toothed whales in the dolphin family. Weight 150 to 300 lbs (67.5 to 135 kg), plus 100 lbs for the bottle-nose and pygmy killer whale, which also gets +10 S.D.C."
  - "Average life span: 50 to 100 years. Dolphins are found world wide."
  - "Speed 2D6+45 is the SPRINT, roughly 32 to 38 mph. A cruising dolphin holds 25 to 30 mph for an hour or two, covering 150 to 250 miles a day - up to 350 if pushed to exhaustion, which then halves speed and range for following days until it rests a day or two."
  - "Spell strength - the number others must save against - is +1 at levels three, seven and eleven. The dolphin is also +2 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "A DOLPHIN THAT DECLINES FURTHER MAGIC IS PAID FOR IT. Printed 80 lets a dolphin learn two ocean magic spells or one whale spellsong at levels three, six, nine and eleven; one that chooses not to - and many do not - instead gains +1D4x10 S.D.C., +1 on initiative, +1 to strike and dodge, +1 to pull punch and roll with impact, and +1D6 to Spd. Neither branch is stored; the dolphin-magic ladder is."
  - "Porpoises are not dolphins here: they start with two attacks, get half the sonic-stun range, and cannot cast dolphin magic at all."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none, though some humans and D-bees experiment on dolphins with implants and bionics."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Dolphin Psionics (printed 80): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Healing or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Healing", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Automatic Dodge"
    description: "Dodges without using up a melee action - the only cetacean in this chapter that can."
  - name: "Sonic Stun"
    description: "An S.D.C. sonic attack doing 2D6 S.D.C. underwater or 1D4 in air, with a 1-60% chance of knocking the victim out for 1D4 melee rounds. A victim who stays conscious but fails to save has a splitting headache and is disoriented: -6 on initiative, -6 to strike, parry and dodge, speed, attacks and skill performance halved, and no sense of direction, depth or which way is up, for 1D4 melee rounds. The saving throw scales with the target: small fish need 19 or better, man-sized fish and sharks 10, humans and most intelligent life 3. Other cetaceans are impervious, as are dragons, giants, creatures of magic, supernatural beings and most mega-damage creatures. It does not damage or penetrate mega-damage armour, vehicles or structures. Only dolphins and porpoises have it."
  - name: "Dolphin Combat"
    description: "Two attacks per melee round at level one, and one more at levels two, four, six, ten and fourteen. A warning nip does 1 S.D.C. and a full bite 1D4; a nose jab 1D4; a head or nose strike 1D4 restrained or 2D4 at full strength; a power strike 3D6 with a 70% chance of costing the victim initiative and one action, counting as two attacks; a tail slap 1D6. Parries with nose or tail."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 500 feet (152 m) plus 100 feet (30.5 m) per level."
  - name: "Mid-Air Leap and Precision Leaping"
    description: "Leaps six feet (1.8 m) plus one foot (0.3 m) per level out of the water, to show off or to grab or knock an item from a hand at +2 to strike. The precision leap counts as three melee actions. Also somersaults, breaches, swims backwards and does backward flips."
  - name: "Quick Turns & Stops"
    description: "Rolled as an automatic dodge or parry; 14 or higher succeeds. A failed roll means it could not stop in time and takes 2D6 impact damage."
  - name: "Speed Burst"
    description: "Double speed for one minute, six times an hour. Used for a quick dodge at +2, a quick strike at +1, or to close or break away. Conditional, so not in the stored bonuses."
  - name: "Tight Circle & Turn"
    description: "Turns within an area as small as 12 feet (3.65 m) across."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 77-80. The first of four cetacean R.C.C.s in this
    chapter, and the only one of the four that is not a whale.
  - IT IS AN S.D.C. CREATURE. Every other class imported from this book so far
    is mega-damage; this one has hit points and S.D.C. and becomes
    mega-damage only while ley line charged. `hit_points_base` and `sdc_base`
    are both used, and `mdc_base` is deliberately absent.
  - THE BOOK SPELLS ONE OF ITS OWN SPELLS THREE WAYS. Printed 70''s
    alphabetical list says Electromagnetic Pulse, the description heading on
    the same page says Electro-Magnetic Pulse, and this class''s own list on
    printed 80 says Electromagnetic BLAST. The spell chapter''s alphabetical
    list is the authority for membership, so the catalog row is
    `Dolphin: Electromagnetic Pulse` and all three readings are recorded -
    here and on the spell row''s `variant_note`.
  - THREE RELATED-SKILL LINES REACH ACROSS THE CATALOG''S FILING, and each
    needed checking rather than transcribing:
      * The book grants SING under Domestic; the catalog files Sing under
        Communications. It is named in the Communications entry so it is
        actually takeable - an `only` naming a skill whose real category the
        class does not grant is unreachable.
      * The Technical line is language, lores and underwater skills only,
        which is a PREFIX restriction rather than a name list.
        `only_prefix: [Language, Lore]` covers 21 language rows and the lore
        family without enumerating either, and `only` adds the two underwater
        Technical rows this book itself created.
      * The -10% the book prints on the Communications line applies to Radio:
        Basic alone. Communications is listed twice, once for Sing with no
        bonus and once for Radio: Basic at -10, so the penalty reaches Radio
        alone (BOOK-INGEST-AUDIT.md F138, 2026-10-14).
  - THE ROGUE `except` DROPS ONE OF THE BOOK''S TWO NAMES. Printed 77 bars
    computer hacking and pick locks; the catalog files Pick Locks under
    Espionage, whose `only` list here does not include it, so it is already
    unreachable and an `except` naming it would exclude nothing. Only
    Computer Hacking is stored.
  - THE ''DECLINE MAGIC FOR BONUSES'' BRANCH IS NOT MODELLED. Printed 80 offers
    a dolphin extra S.D.C., speed and five combat bonuses in exchange for
    never learning ocean magic or spellsongs. That is a character-creation
    either/or across two unrelated blocks, and nothing here can express it.
    The magic ladder is stored and the alternative is a restriction line.
  - PSIONICS ARE A PERCENTILE ROLL, printed 80, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 80 heads its own section Dolphin Psionics (Special), says to roll on that table and prints its own no-psionic-powers result at 01-77; nothing sends the reader to the standard rule.
---

# Dolphin

## Lore

Playing a dolphin can be a blast. There is something magical about a creature so alien and so familiar at once, and the character is at its best when the player plays it in character - a different view of life, thinking in pictures rather than words, high morals, innocence, and broken speech.

Dolphins are natural ley line walkers with some abilities a ley line walker does not have. They can charge themselves on a line until they glow blue and turn temporarily mega-damage, fire mystic bolts, and hop between neighbouring lines through a Rift of their own making.

They are also the only cetaceans besides porpoises with the sonic stun - a blast that scales its effect to the size of what it hits, and that other cetaceans are entirely immune to.

## GM Notes

Do not forget that through advanced technology and magic, dolphins and other sea creatures can travel and survive on dry land for short periods, and for long ones where water and the right magic are constantly available.

A dolphin out of water is helpless - it can only flop and squirm - and it is on a clock: about fifteen minutes before the skin dries and it weakens, dead in half an hour or so unless it is sprinkled or immersed.

Many dolphins decline to learn any magic beyond their own. The book pays them for it in raw physical bonuses, which is worth knowing before a player picks.
',
       updated_at = datetime('now')
 WHERE class_id = 'dolphin'
   AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0
   AND length(markdown) = 20320;

-- == killer-whale ==
UPDATE imported_classes
   SET markdown = '---
id: killer-whale
name: Killer Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.85-88
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+14"
hit_points_base: "P.E. + 1d4x10, +10 per level"
sdc_base: "2d6x10"
ppe_base: "P.E. + 1d6x10, +2d6 per level"
bonuses:
  combat: { attacks_base: 3, initiative: 2, strike: 3, dodge: 1, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 6, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    any_magic:
      - "Ocean: Abilities of a Snail"
      - "Ocean: Air Swim"
      - "Ocean: Armor of Neptune"
      - "Ocean: Black Water"
      - "Ocean: Breathe Air"
      - "Ocean: Calm Waters"
      - "Ocean: Change Current"
      - "Ocean: Communicate with Sea Creature"
      - "Ocean: Coral Armor"
      - "Ocean: Float Underwater"
      - "Ocean: Float on Water"
      - "Ocean: Flying Fish"
      - "Ocean: Grow Tentacles"
      - "Ocean: Healing Waters"
      - "Ocean: Impervious to Cold"
      - "Ocean: Impervious to Electricity"
      - "Ocean: Impervious to Ocean Depths"
      - "Ocean: Metamorphosis Crustacean"
      - "Ocean: Metamorphosis Fish"
      - "Ocean: Metamorphosis Shark"
      - "Ocean: Mystic Sea Horse"
      - "Ocean: Ride the Waves"
      - "Ocean: Sense Direction Underwater"
      - "Ocean: Senses of the Shark"
      - "Ocean: Sonar Hearing"
      - "Ocean: Sound Sponge"
      - "Ocean: Speak Underwater"
      - "Ocean: Strength of the Whale"
      - "Ocean: Summon Sea Friend"
      - "Ocean: Transmute Water"
      - "Ocean: Travel Above Water"
      - "Ocean: Walk Like a Humanoid"
      - "Ocean: Water Envelope"
      - "Ocean: Water Nourishment"
      - "Ocean: Water Pulse"
      - "Ocean: Water Rush"
      - "Ocean: Water Seal"
      - "Ocean: Water Spout"
      - "Ocean: Water Wall"
      - "Ocean: Weed Snare"
      - "Ocean: Whirlpool"
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 2, from_list: "any_magic", note: "Ocean magic, dolphin magic or whale spellsongs in any combination - the book offers all three from one pool." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "any_magic" }
    - { level: 4, count: 1, from_list: "any_magic" }
    - { level: 6, count: 1, from_list: "any_magic" }
    - { level: 8, count: 1, from_list: "any_magic" }
    - { level: 10, count: 1, from_list: "any_magic" }
    - { level: 12, count: 1, from_list: "any_magic" }
    - { level: 14, count: 1, from_list: "any_magic" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One human language of choice (+15%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Sing"] }
      - { name: "Communications", only: ["Radio: Basic"], bonus: -10 }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only, so Radio: Basic has a Communications entry of its own carrying it and Sing''s entry carries none. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 7, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant orca are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D4+3."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. plus 1D4x10 for females and young, and P.E. plus 4D4x10 for a full-grown male, +10 per level either way. S.D.C. is 2D6x10 for females and young, 4D6x10 for a full-grown male. A full-grown male character should use the larger of each."
  - "Horror Factor: 14 when angry or attacking. The stored save bonus is +6; the horror factor itself is a number others save against."
  - "Size: males average 25 to 33 feet (7.6 to 10 m), females 14 to 21 feet (4.2 to 6.4 m). The upright angular fin is 5 to 7 feet (1.5 to 2.1 m) tall, larger than any other whale''s. Weight 2 to 5 tons; the male is about twice the size of the female."
  - "Average life span: 60 to 100 years, maturity at 8 to 12. There are an estimated 11 million on Rifts Earth."
  - "Spell strength is +1 at levels four, eight and twelve. The orca is +3 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE, unlike the dolphin."
  - "The killer whale is the ONLY cetacean that preys on warm-blooded animals. It hunts dolphins, porpoises, seals, sea lions, penguins and sea birds as well as fish and squid, and a hunting pair or pod occasionally takes baleen, beluga, narwhal and grey whales. It never feeds on other orca."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Killer Whale Psionics (printed 88): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Orca Combat"
    description: "Three attacks per melee round at level one, and one more at levels two, five, seven, ten and thirteen. Parries with nose or tail. NO automatic dodge."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 800 feet (182 m) plus 100 feet (30.5 m) per level, at +2 to strike on a diving attack."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 85-88. An S.D.C. creature like the dolphin, and the
    largest species in the dolphin family - the book files it as its own
    R.C.C. rather than as a dolphin variant.
  - ITS MAGIC IS THE WIDEST OF THE FOUR CETACEANS and is stored as a single
    merged pool. Printed 88 lets the orca learn ocean magic, dolphin magic or
    whale spellsongs IN ANY COMBINATION, which is one pool of 72 rather than
    three lists with separate counts - so `any_magic` is the union, and that
    is the honest reading of the sentence rather than a convenience.
  - HIT POINTS AND S.D.C. EACH HAVE A FEMALE/YOUNG FIGURE AND A FULL-GROWN
    MALE FIGURE, and the smaller is stored, consistently across all three
    whales in this batch. Both are in the restrictions. A single column
    cannot hold a sex-and-age branch, and storing the larger would over-roll
    every young or female character.
  - SEE THE DOLPHIN''S NOTES for the three related-skill lines that reach
    across the catalog''s filing - Sing, the Technical prefix restriction, and
    the -10% stored on Radio: Basic alone. All four cetaceans share them.
  - ITS ESPIONAGE LIST IS SHORTER THAN THE DOLPHIN''S: no escape artist and no
    pick pockets. Transcribed as printed.
  - PSIONICS ARE A PERCENTILE ROLL, printed 88, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 88 heads its own section Killer Whale Psionics (Special), says to roll on that table and prints its own no-psionic-powers result at 01-77; nothing sends the reader to the standard rule.
---

# Killer Whale

## Lore

With hundreds of years and no commercial whaling behind it, the killer whale has regained its place as a power in the oceans of Rifts Earth. It does not prey on humans, but it is aloof and suspicious of them - until it befriends one, at which point it gives that person the same loyalty, playfulness and affection it gives its own kind, and its pod is likely to follow suit.

It extends the same friendship to D-bees and mutants that are very human-like: sea titans, True Atlanteans, psi-stalkers, kittani, changelings, ogres, elves, dwarves, dog boys, wolfen, simvan and Lemurians.

Aquatic humanoids are another matter. Orcas view amphibs and most aquatic D-bees with suspicion and animosity, and while no killer whale has ever slain a human, they regularly bite and kill aquatic humanoids, D-bees, aliens and mutants. Naut''yll, horune, gene-splicers and their mutants, sea monsters, minions of the Lord of the Deep and demons are treated as natural prey and attacked without provocation.

## GM Notes

Among their own kind orcas are intelligent, compassionate and gentle, much like their smaller dolphin cousins - protecting the young and sick, working in groups, showing affection, and seldom fighting each other.

A typical pod runs 50 to 300 members and usually stays together for life. A pod that outgrows that splits into two or three groups of 8 to 50, which grow into pods themselves. Family ties survive the split and pass down the generations: an orca can recognise immediate family, its own pod, other pods, rogues and even relatives it has never met, from the accent of a pod''s language and from physical marks.

The killer whale is the only cetacean that preys on warm-blooded animals. A settled orca''s hunting range spans 200 to 600 miles.
',
       updated_at = datetime('now')
 WHERE class_id = 'killer-whale'
   AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0
   AND length(markdown) = 19474;

-- == humpback-whale ==
UPDATE imported_classes
   SET markdown = '---
id: humpback-whale
name: Humpback Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.90-92
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6+10"
  MA: "2d6+10"
  PS: "3d6+30"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "2d6"
  Spd: "2d6+14"
hit_points_base: "P.E. x8, +10 per level"
sdc_base: "3d6x10"
ppe_base: "P.E. + 4d4x10, +20 per level"
bonuses:
  combat: { attacks_base: 1, strike: 1, dodge: 1, pull_punch: 1, roll: 2 }
  saves: { horror_factor: 5, toxins_poisons: 2, disease: 2, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 11, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 4, from_list: "spellsongs" }
  spells_schedule:
    - { level: 2, count: 2, from_list: "spellsongs" }
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 4, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 9, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 11, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 13, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
    - { level: 15, count: 1, from_list: "spellsongs" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 40, per_level: 5, note: "+5%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "One human language of choice (+5%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Sing"] }
      - { name: "Communications", only: ["Radio: Basic"], bonus: -10 }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only, so Radio: Basic has a Communications entry of its own carrying it and Sing''s entry carries none. Pilot is barred except specially designed power armour. Medical is barred entirely here, unlike the dolphin, orca and sperm whale, which all get Sea Holistic Medicine."
  secondary_skills:
    count: 0
    schedule: [{ level: 3, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 50% scrupulous, 15% principled, 15% unprincipled, 10% anarchist and 10% other. The most reliably good-aligned of the four."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D6+5."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. x8 for females and young and P.E. x10 for a full-grown male, +10 per level either way. S.D.C. is 3D6x10 for females and young, 5D6x10 for a full-grown male."
  - "Horror Factor: 10 when angry or attacking."
  - "Size: males average 60 to 70 feet (18.3 to 21.3 m), females 40 to 48 feet (12.2 to 14.6 m). Weight 60 to 70 tons for a full-sized adult, 30 to 40 for a female."
  - "Average life span: 70 to 100 years, maturity at 11 to 13."
  - "ALL HUMPBACKS HAVE SOME PSIONIC POWER. Printed 92 rolls the degree on a table rather than granting one set: 01-90 minor, 91-00 major. Roll or pick the Psionics ability, which carries the tier, I.S.P. and powers - unlike the dolphin and the orca, where most have none, here every character has something."
  - "Spellsong strength is +1 at levels two, five, eight and twelve. It is +6 to save against whale spellsongs specifically - the highest in the book - on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE. It parries with nose or tail at +1."
  - "It is a filter feeder, straining krill and shrimp through baleen plates."
  - "The humpback gets +20% to Sing where other classes get +10%, and DOUBLE range on any spellsong that lists a doubled range for humpbacks."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-90): Minor Psionic", "Psionics (91-00): Major Psionic"], note: "Humpback Whale Psionics (printed 92): every humpback has some psionic power. Roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-90): Minor Psionic"
    description: "Roll 01-90. A minor psionic limited to See Aura, Sense Magic and Mind Block, plus one power of choice from the Sensitive category. Base I.S.P. is M.E. x2, plus 1D6 per level."
    psionics:
      type: "minor"
      isp_base: "M.E. x2, +1d6 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 1
      categories_allowed: ["Sensitive"]
  - name: "Psionics (91-00): Major Psionic"
    description: "Roll 91-00. A major psionic limited to See Aura, Sense Magic and Mind Block, plus two powers of choice from the Healing or Sensitive categories. Base I.S.P. is M.E. x3, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x3, +1d6+2 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 2
      categories_allowed: ["Healing", "Sensitive"]
natural_abilities:
  - name: "Master of Spellsongs"
    description: "Other than the pneuma-biforms, the humpback is the most powerful of the Whale Singers. It selects four spellsongs at level one, two at level two, and one more every level after."
  - name: "True Song"
    description: "No other whale has the same variety or complexity of sound. A humpback''s songs are true songs - an ordered sequence of themes, motifs and phrases like a bird''s - which can be repeated exactly and taught to others. Clicks, chirps, yups, cries, moans and roars, mostly between 40Hz and 5kHz. One song lasts 6 to 40 minutes and can carry up to 116 miles (185 km), though most sounds reach 50 to 60 miles."
  - name: "Humpback Combat"
    description: "ONE attack per melee round at level one, and one more at levels two, five, eight, eleven and fourteen. Parries with nose or tail at +1. No automatic dodge."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 90-92. The master of spellsongs: other than the
    pneuma-biforms, the most powerful of the Whale Singers, and the only
    cetacean here whose magic is spellsongs alone.
  - ITS SPELLSONG LADDER IS THE FULLEST IN THE BOOK - four at level one, two
    at level two, and one every level after - which is the same shape the
    Whale Singer O.C.C. uses. That is not a coincidence and it is why this
    class is worth having.
  - EVERY HUMPBACK IS PSIONIC TO SOME DEGREE, which is different from the
    dolphin and orca, where printed 80 and 88 leave 77% with nothing. No
    class-level psionics block is stored either way, because printed 92 still
    rolls the degree rather than granting one set: the roll is a choose-1
    special ability with two options named for their bands, 01-90 minor and
    91-00 major, each carrying its own tier, I.S.P. formula and powers.
  - MEDICAL IS BARRED ENTIRELY, where the other three cetaceans all get Sea
    Holistic Medicine. Transcribed as printed 91 gives it.
  - ITS SING BONUS AND ITS SPELLSONG RANGES ARE BOTH DOUBLED relative to the
    other cetaceans, and several spellsong rows name the humpback explicitly
    in their range lines. Neither is stored on this class: the Sing bonus
    belongs to whichever class grants the skill, and the doubled range lives
    on the spell rows.
  - HIT POINTS AND S.D.C. STORE THE FEMALE/YOUNG FIGURE, as on the other two
    whales.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 92 says all humpbacks have some degree of psionic power and gives the race''s own two-row table, so that table is the whole rule.
---

# Humpback Whale

## Lore

There has always been something magical about the humpback whale and its haunting songs. No other whale has the same variety or complexity of sound, and the humpback''s are true songs - an ordered sequence of themes, motifs and phrases like a bird''s, which can be repeated exactly and taught to others.

A single song lasts between six and forty minutes and can be heard up to a hundred and sixteen miles away.

Since the development of Whale Singer spellsongs, the humpback has become one of their masters. Other than the pneuma-biforms, it is the most powerful of the Whale Singers.

## GM Notes

Humpbacks, like all baleen whales, are filter feeders. The whale opens its mouth wide to engulf water full of krill and shrimp, and the baleen plates growing down from the roof of its mouth strain them out as the water passes through.

Every humpback has some degree of psionic power - which is not true of dolphins or killer whales, where most have none at all.

Several spellsongs name the humpback explicitly in their range lines, doubling or in one case multiplying by ten what any other singer gets. A humpback in a party changes what the spellsong list is worth.
',
       updated_at = datetime('now')
 WHERE class_id = 'humpback-whale'
   AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0
   AND length(markdown) = 16211;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 8 classes carry their new text' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes
 WHERE (class_id = 'huntsman-trapper' AND instr(markdown, '{ name: "Technical", only: ["Whittling & Sculpting"], bonus: 15 }') > 0)
    OR (class_id = 'travelling-story-teller' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 15 }') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language", "Computer"], bonus: 15 }') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, '{ name: "Rogue", only: ["Concealment"], bonus: 6 }') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language"], bonus: 10 }') > 0)
    OR (class_id = 'dolphin' AND instr(markdown, '{ name: "Communications", only: ["Radio: Basic"], bonus: -10 }') > 0)
    OR (class_id = 'killer-whale' AND instr(markdown, '{ name: "Communications", only: ["Radio: Basic"], bonus: -10 }') > 0)
    OR (class_id = 'humpback-whale' AND instr(markdown, '{ name: "Communications", only: ["Radio: Basic"], bonus: -10 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'huntsman-trapper' AND instr(markdown, 'Whittling at +15% is not stored (Technical is a flat +10).') > 0)
    OR (class_id = 'travelling-story-teller' AND instr(markdown, 'Technical +15% to language skills is not stored (Technical is a flat +10).') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, '+15% to language or computer skills is in the note only.') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, 'the per-skill bonuses are in the note, not stored.') > 0)
    OR (class_id = 'mystic-ninja' AND instr(markdown, '(add it to a language pick by hand)') > 0)
    OR (class_id = 'dolphin' AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0)
    OR (class_id = 'killer-whale' AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0)
    OR (class_id = 'humpback-whale' AND instr(markdown, 'is NOT stored as a category bonus, because that would apply it to Sing as well.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('huntsman-trapper', 'travelling-story-teller', 'ectohunter', 'sohei-warrior-monk', 'mystic-ninja', 'dolphin', 'killer-whale', 'humpback-whale') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~189-book-ingest-audit-f138-scoped-a.sql');
