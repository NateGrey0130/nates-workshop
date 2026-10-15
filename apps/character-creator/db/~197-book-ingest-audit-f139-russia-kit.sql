-- BOOK-INGEST-AUDIT F139: eleven Russia classes are granted the Rifts rows their kit names, and say plainly where none exists
-- 11 classes, each replaced whole: bogatyr-hero-knight, born-mystic, cossack, ectohunter, huntsman-trapper, reaver-mechanized-cavalryman, reaver-soldier, russian-explorer, russian-villager, soldati, travelling-story-teller.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~197-book-ingest-audit-f139-russia-kit.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == bogatyr-hero-knight ==
UPDATE imported_classes
   SET markdown = '---
id: bogatyr-hero-knight
name: Bogatyr (Hero-Knight)
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.58-61
category: occ
tags: [combat]
occ_group: optional
men_of_arms: false
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 52521, 74001, 100001, 135201, 190301, 240401, 290501, 350601]
attribute_requirements: { ME: 13, PE: 13 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d4x100"
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Speaks two other languages of choice (+20%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Lore: Religion", base: 30, per_level: 5 }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Horsemanship: Knight", base: 40, per_level: 5, note: "Piloting: two of choice, including Horsemanship: Knight. Knight is one of the two; the book prints no bonus on the line. The catalog row is 40%/30% +5%." }
    - { choose: 1, categories: ["Pilot"], note: "Piloting: the second of the two of choice." }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two modern of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts for the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Airplane", "Helicopter", "Jet Aircraft", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - "Science"
      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
      - { name: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Choose five other skills at level one. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: any. Mechanical: Basic Mechanics and Automotive only. Medical: none. Military: any (+5%). Physical: any. Pilot: any, except robots, power armor, military vehicles, ships and aircraft. Pilot Related: any. Rogue: Streetwise only. Science: any. Technical: any (+10%; +15% to art and language skills). W.P.: any. Wilderness: any."
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Airplane", "Helicopter", "Jet Aircraft", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the list at level one and one more at levels 2, 4, 6, 8, 12 and 14, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 1 }
equipment_starting:
  - { choose: 1, label: "homemade M.D.C. body armor", qty: 1, from: ["homemade-mdc-armor-light", "homemade-mdc-armor-medium"], note: "The book allows a hodgepodge of homemade armor (30-60 M.D.C.), any modern armor (30-100 M.D.C.), or modern armor made to look like plate or plate and scale (60-100 M.D.C., can be environmental). Only the homemade suits are offered here; see GM Notes." }
  - { item_id: "vibro-sword", qty: 1, note: "2D6 M.D." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1, note: "The book says a silver dagger." }
  - { item_id: "small-silver-cross", qty: 1, note: "The book says a silver cross, no size given." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: 1, note: "The book says gas mask and filter." }
  - { item_id: "goggles", qty: 1, note: "Tinted goggles." }
  - { item_id: "hatchet", qty: 1, note: "For chopping wood." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a lighter." }
  - { item_id: "sack", qty: 1, note: "Medium-sized." }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "hooded-cloak", qty: 1, note: "The book says a cloak or cape." }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "cord", qty: 1, note: "30 feet (9 m), 600 lb. test strength." }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "bandages-6-foot-1-8-m-roll", qty: 1, note: "The book says extra bandages, with no number." }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "note-pad", qty: 1, note: "The book says a notepad." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Principled (35%), Scrupulous (40%) or Aberrant (10%)."
  - "Racial restrictions: none. About 80% are human; the rest are D-Bees."
  - "Attribute requirements: M.E. 13 and P.E. 13 or higher. A high I.Q., M.A. and P.S. or P.P. are helpful but not required."
  - "Psionics are not a requirement."
  - "Cybernetics: none to start, and they are avoided as unnatural. The only cybernetics a knight may consider are prosthetics and organs to replace severely injured ones."
  - "Vehicle: starts with a used, battered-looking hovercycle or motorcycle, or a suitable riding animal. A vehicle is missing 1D4x10 M.D.C. from its main body but is otherwise in excellent condition."
extraction_notes: "WB17 Warlords of Russia printed 58-61 (cache p059, p061, p062; cache p060 is a full-page illustration with no text; cache page = printed folio + 1), read off the text layer. The entry ends with its Money and Cybernetics lines at the top of printed 61, past the page break. || HEADING: the description is headed Adventuring Bogatyr O.C.C., The Hero-Knights of Russia (printed 58); the stat block is headed The Russian Hero-Knight O.C.C., also known as Bogatyr and Holy Knight (printed 60). Listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base of its own. || XP: the War-Knight and Bogatyr ladder as given in the brief, read off a render of the Experience Tables on printed 6. || BONUSES: the entry prints no O.C.C. bonuses and no special abilities; the Code of the Bogatyr (printed 60) is ten maxims and is paraphrased in Lore, not stored as a mechanic. || SKILLS: Speaks Russian at 98% is stored as base 98 on Language: Russian with the catalog per_level. Piloting: two of choice, including Horsemanship: Knight is stored as two picks across Pilot plus Horsemanship narrowed to Horsemanship: Knight. The O.C.C. piloting line prints no exclusions, so the group offers all of Pilot. W.P. two ancient and two modern are two category picks each, with the ancient/modern split in the note only. || PILOT EXCEPT: the book prints ''except robots, power armor, military vehicles, ships and aircraft''; read literally as all ships and all aircraft, and mapped to the Robot rows, the Military: rows, Boat: Ships, Airplane, Helicopter, Jet Aircraft, both Fighter Combat rows, the three Space craft rows and Wingrider Flying Wing. Air Assault Armor, Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored; the +15% to art and language skills is in the note only. || HAND TO HAND: Expert, changeable to Martial Arts for one related skill; no Assassin option is printed. || MONEY: 1D4x100 credits stored (the text layer prints !D4xlOO); the 1D4x100 credits of tradeable goods is in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; antiseptic and personal items have no catalog row; the belt has no Rifts row (its only row is Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The boots (as work-boots-rifts), the first-aid kit, the extra bandages, the bedroll and the notepad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The armor line is three open ranges; only the two homemade suits are offered as rows. The silver dagger maps to knife-silver-plated, the silver cross to small-silver-cross, tinted goggles to goggles, the lighter to cigarette-lighter-refillable, cloak or cape to hooded-cloak. || NOT STORED: the vehicle or riding animal, the Megasteed and Megahorse line, Secret Resources and the note on War Camp hostility are prose in restrictions and GM Notes. The demographic percentages (62% Russian, 6% Ukrainian, 4% Polish, 4% mixed, 4% other) are not stored."
---

## Lore

The Bogatyr is Russia''s wandering hero-knight: an independent champion who
rides out against demons, dragons, tyrants and raiders and asks nothing for
it. There is no order, school or noble title behind the name. Most learn the
calling as an apprentice to an established knight, for anywhere from two to
eight years, and then set out alone.

They do not look alike. One arrives in plate on a warhorse, another on a
battered hovercycle in patched armor under a traveling cloak, and most avoid
announcing what they are. Humans make up the bulk of them, Russians above
all, but foreigners and D-Bees are counted among their number. Nearly all are
religious, and the people call the greatest of them Holy Knights.

Their code is short. Stand for something larger than yourself; do the right
thing because it is right, even alone; hold to truth, trust, love, compassion
and mercy; and let conscience and faith guide the hand. A Bogatyr cannot be
bought, bribed or commanded, which is why the people love them and why the
Warlords and their camps regard them as troublemakers.

## GM Notes

The class prints no combat or save bonuses and no special abilities of its
own; its strength is its skill list and Hand to Hand: Expert.

Armor is the player''s choice of homemade M.D.C. armor (30-60 M.D.C.), any
modern armor (30-100 M.D.C.), or modern armor made to look like plate or
plate and scale (60-100 M.D.C., may be environmental). The sheet offers only
the homemade suits; substitute another suit by hand if the player picks one.

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+2
extra clips apiece, antiseptic, a belt (no Rifts row) and a handful of
personal items. Money is
1D4x100 credits plus 1D4x100 credits of tradeable goods.

Vehicle: a used hovercycle or motorcycle missing 1D4x10 M.D.C. from the main
body, or a suitable riding animal. A Megasteed or a rare Megahorse may be
acquired later if the knight has the skill to ride it. Friendly Mystic Kuznya
often give or trade worthy Bogatyrs magical horseshoes, hammers and the like.

No secret resources as such, but Huntsmen, Travelling Story Tellers, Mystic
Kuznya, Mega-Horses and peasants hold them in high regard, and villagers who
recognize one will usually offer food and shelter. Reavers and War Camp
soldiers dislike them, and self-styled Knights of the Realm tend to challenge
them to contests and duels without going so far as to harass them.
',
       updated_at = datetime('now')
 WHERE class_id = 'bogatyr-hero-knight'
   AND instr(markdown, 'antiseptic, a belt, boots and personal items have no catalog row') > 0
   AND length(markdown) = 13945;

-- == born-mystic ==
UPDATE imported_classes
   SET markdown = '---
id: born-mystic
men_of_arms: false
name: Born Mystic
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.107-109
category: occ
tags: []
occ_group: psychic
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
ppe_base: "1d6x10 plus the P.E. attribute number, and 2d6 more per level of experience"
starting_money: "3d6x100"
equipment_starting:
  - { item_id: "riding-horse", qty: 1, note: "Vehicle: starts with a good quality horse." }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%" }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: one of choice (+10%)" }
    - { name: "Horsemanship: General", note: "Horsemanship: General" }
    - { name: "Land Navigation", bonus: 15, note: "Land Navigation (+15%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice" }
    - { name: "Hand to Hand: Basic", note: "Can be improved to Expert for the cost of two other skills, or Martial Arts (or Assassin, if evil) for three." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", only: ["Radio: Basic"], note: "Radio Basic only." }
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - { name: "Espionage", only: ["Escape Artist", "Disguise", "Intelligence"], bonus: 5, note: "Escape Artist, Disguise and Intelligence only (+5%)" }
      - { name: "Medical", only: ["First Aid"], note: "First Aid only." }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking"], note: "Any except Computer." }
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "+5%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10, and 10 more per level of experience"
  powers: ["Mind Block", "Exorcism", "Commune with Spirit", "Sixth Sense", "Meditation"]
  powers_starting: 5
  powers_starting_groups:
    - { count: 3, categories: ["Sensitive"], note: "Three from Sensitive, OR one from Super Psionic instead - the book offers the choice and the schema cannot hold an either/or across two groups, so the Sensitive three are modelled and the Super Psionic alternative is in special_abilities." }
    - { count: 2, categories: ["Physical", "Healing"], note: "Two from either Physical or Healing. THE BOOK NOTES THIS IS THE PSYCHIC''S ONLY CHANCE TO TAKE HEALING." }
  powers_schedule:
    - { level: 3, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 5, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 7, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 9, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 11, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 13, count: 1, categories: ["Sensitive", "Physical"] }
    - { level: 15, count: 1, categories: ["Sensitive", "Physical"] }
magic:
  type: "spell"
  spells_starting: 7
  spells_starting_groups:
    - { count: 3, spell_levels: [1, 2], note: "Three from common Wizard magic, levels one and two." }
    - { count: 4, from_list: "nature-low", note: "Four Nature Magic spells of choice from levels 1-3. A named list rather than a level range, so this group reaches Nature Magic and only Nature Magic." }
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
  spell_traditions_allowed: ["nature"]
  spell_lists:
    nature-low:
      - "Nature: Crunching Egg Shell"
      - "Nature: Melt Bee''s Wax"
      - "Nature: Sacred Oath"
      - "Nature: Glue with Bee''s Wax"
      - "Nature: Make Honey & Syrup Candy"
      - "Nature: Sustained by the Earth"
      - "Nature: The Bee''s Friend"
      - "Nature: Bake Magic Kulich"
      - "Nature: Bless Food"
      - "Nature: Seal a Wound with Bee''s Wax"
bonuses:
  saves: { possession: 5, horror_factor: 2, mind_control: 2 }
special_abilities:
  - name: "Dowsing"
    description: "The psychic ability to locate fresh water, whether with a divining rod or by more scientific and logical means. Base Skill 20% +7% per level of experience. A roll may be made once every melee round to sense water, but TWO consecutive successes are needed to actually locate it. It is a class ability rather than a catalog skill row, so it lives here."
  - name: "Super Psionic alternative"
    description: "At level one the book offers a CHOICE the schema cannot hold as an either/or across two groups: three powers from the Sensitive category, OR one power from the Super Psionic category instead. The Sensitive three are modelled as the starting group; a character taking the Super Psionic option substitutes one Super Psionic power for those three."
  - name: "Magic by meditation, not by study"
    description: "When ready to make his place in the world the character enters a meditative trance lasting six days, and at the end of it intuitively knows how to cast seven specific spells. These are permanent and CANNOT BE CHANGED, and the character cannot learn new spells the way a Ley Line Walker does - his magic must come from meditation and cosmic awareness. The nature of the spells typically reflects his alignment and view of life."
  - name: "Additional Magic at each plateau"
    description: "The Born Mystic intuitively senses each new metaphysical plateau - each experience level - and meditates. He then selects two new spells from any level up to his own level of experience, drawn from common Wizard magic or from Nature Magic."
  - name: "Master Psionic"
    description: "As a master psionic the Born Mystic needs to roll a 10 or higher to save versus psionic attack, plus any M.E. attribute bonuses. That is a save THRESHOLD rather than a bonus, which is what `psionics.type: master` carries; it is stated here so the number is on the page."
restrictions:
  - "THIS IS A P.C.C., NOT AN O.C.C. The book heads the block ''Born Mystic P.C.C.'' - a Psychic Character Class. It is stored as category occ with occ_group psychic, which is how this catalog models every P.C.C.; a roster scan keyed on O.C.C. misses it entirely."
  - "Any alignment. Also known as the Born, Sage, Mystic Wiseman and Russian Mystic."
  - "Attribute requirements: NONE, other than psionic ability. The book strongly suggests a high I.Q. and M.A. (10 or higher) but does not require them, so no attribute_requirements block is stated."
  - "Racial restrictions: none, although the vast majority (70%) are human."
  - "Cybernetics: none, and the character avoids them like the plague - any cybernetics or physical augmentation interferes with psionics and magic. Cybernetic prosthetics and bio-systems for medical reasons will be considered."
  - "The character also starts with 2D4x1000 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only. The book prices the coin in credits OR RUBLES."
  - "The seven spells chosen at level one are PERMANENT and cannot be changed, and the character cannot learn spells by study or purchase the way other casters can."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.107-109. THE BOOK HEADS THIS A P.C.C. - ''Born Mystic P.C.C.'' - which the survey flagged as a trap this book shares with new-west: a roster scan keyed on O.C.C./R.C.C. misses it. Stored as category occ with occ_group psychic, the convention every other P.C.C. here follows. A DELIBERATE TRADE-OFF IN THE MAGIC BLOCK, stated because it is a real over-permission rather than an oversight: `spell_traditions_allowed` is CLASS-WIDE and identical for every group, and this class needs it set to nature so that its per-level picks - two spells per level from Wizard magic OR Nature Magic, explicitly - can reach the tradition. The cost is that the starting group of three common Wizard spells can also see Nature spells of levels one and two. The alternative was to omit the key, which would have left the far larger per-level allowance unable to reach Nature Magic at all; that is the worse error, since it is about twenty-eight spells over a career against three at creation, and a character may take Nature spells at level-up regardless. The four starting Nature spells use a named list, which wins over the tradition gate, so THAT group reaches Nature Magic and nothing else. The level one psionic choice - three Sensitive powers OR one Super Psionic power - is an either/or across two different categories and counts, which no group shape can hold; the Sensitive three are modelled and the alternative is in special_abilities. Dowsing is a class ability with its own percentage rather than a catalog skill row, so it is prose. No attribute_requirements block is stated because the book requires none, only psionic ability. ONE NAME DIFFERS BY A PLURAL AND IT IS A REAL DISTINCTION, NOT A TYPO: the book grants `Commune with Spirits`, and this catalog holds a SPELL of that exact plural name AND a PSIONIC POWER called `Commune with Spirit`, singular, Sensitive, 6 I.S.P. The power is what a psionic grant means, so the singular is stored; class-check reported the plural as a missing psionic row and would have created it at 0 I.S.P. with no category."
---

# Born Mystic

## Lore

The Born Mystic - also called the Born, the Sage, the Mystic Wiseman and the
Russian Mystic - is born with the gift rather than trained into it. He spends
years pondering the mysteries of life, his place in it, and how magic might help
him find that place.

When he is ready to go and make his place in the world, he enters a meditative
trance lasting six days. At the end of it he intuitively knows how to cast seven
specific spells, and those spells are his for good. He cannot study for more,
buy more, or trade them away. Everything he learns after that arrives the same
way it first did: by sensing a new plateau in his own life and sitting down to
think about it.

## Alignment

Any.

## GM Notes

This is a **P.C.C.**, a Psychic Character Class, not an O.C.C. - the book heads
its stat block that way, and a roster scan looking only for O.C.C. and R.C.C.
will miss it.

It is the book''s most unusual caster: a Master Psionic who also casts, whose
magic cannot be extended by any of the ordinary means, and whose spell list is
half common Wizard magic and half the Old Believer''s Nature Magic. The level one
psionic selection is also the character''s only chance to take Healing powers,
which the book calls out explicitly.
',
       updated_at = datetime('now')
 WHERE class_id = 'born-mystic'
   AND instr(markdown, 'The vehicle is not a catalog gear row.') > 0
   AND length(markdown) = 11516;

-- == cossack ==
UPDATE imported_classes
   SET markdown = '---
id: cossack
name: Cossack
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.73-76
category: occ
tags: [combat, ranged, wilderness]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]
attribute_requirements: { PP: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "2d4x100"
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Horsemanship: Cossack", base: 55, per_level: 5, note: "Special skill 1. Base Skill 55%/45% +5% per level; includes riding bareback (-10%)." }
    - { name: "Breaking/Taming Wild Horse", base: 40, per_level: 5, note: "Special skill 2. Base Skill (Cossack): 40% +5% per level. Riding wild bulls, wild broncos and other wild and exotic animals, and bull wrestling, are all at -15%." }
    - { name: "Herding Cattle", base: 30, per_level: 5, note: "Special skill 3. Base Skill 30% +5% per level." }
    - { name: "Trick Riding", base: 0, per_level: 0, note: "Special skill 4. All tricks and stunts without penalty; roll on the first (greater) Horsemanship percentage." }
    - { name: "W.P. Trick Shooting", base: 0, per_level: 0, note: "Special skill 6. The Cossack gets ALL six trick shooting abilities." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%." }
    - { name: "Language: Chinese", base: 65, per_level: 5, note: "Speaks Chinese and Euro (+15%)." }
    - { name: "Language: Euro", base: 65, per_level: 5, note: "Speaks Chinese and Euro (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: Exotic Animals", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 40, per_level: 5, note: "+15%" }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "Wrestling", base: 0, per_level: 0 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Sword plus two ancient of choice." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Rifle plus one modern weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Hand to Hand: Expert can be changed to Martial Arts for the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", only: ["Boat: Sail Type", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Jet Packs"] }
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 5 }
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Choose five other skills at level one. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: Intelligence and Escape Artist only. Mechanical: none. Medical: First Aid only. Military: any (+5%). Physical: any. Pilot: Sailing, Hovercycle, Motorcycle, Snow Mobile/Jet, Jet Pack and similar small, fast vehicles only. Pilot Related: any. Rogue: any (+5%), except Computer Hacking. Science: Math and Astronomy only (+5%). Technical: any (+10%). W.P.: any. Wilderness: any (+5%)."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", only: ["Boat: Sail Type", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Jet Packs"] }
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the list at level one and one more at levels 4, 8, 12 and 14, without the bonuses in parentheses."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 1 }
special_abilities:
  - name: "Cossack Mounted Combat"
    description: "Part of Horsemanship: Cossack; the bonuses go to the rider, not the mount, and stack with other combat skills, W.P.s and attribute bonuses. On horseback: +1 on initiative at levels 1, 4, 8, 12 and 15; +2 to parry or dodge; +2 to roll with fall or impact when knocked from the horse; melee weapons do +6 S.D.C. or +1D4 M.D. (M.D. weapons such as Vibro-Blades; never ranged weapons). Charge attack on a running horse with a lance, pole-arm or spear: +2D6 S.D.C. or +1D4 M.D., counts as two melee attacks, and the rider must roll under the second Horsemanship percentage or be dismounted. Horse attack: roll under the second percentage to stay saddled while the horse rears or kicks at the same time, generally 2D6 from the front legs and 4D6 from the rear legs. Robot horses are never ridden; partial bionic horses are acceptable."
  - name: "Born and Raised Cossack"
    description: "Only for a character born and raised as a Cossack, in addition to skill bonuses: +1D4 to M.A., +1D6 to P.S., +1D4 to P.P., +1D4 to P.E., +1D6 to Spd and +3D6 to physical S.D.C."
  - name: "Trick Shooting (all six)"
    description: "1. Fires a two-handed weapon such as a rifle one-handed without penalty. 2. Shoots over the shoulder using a mirror to aim, without penalty to strike. 3. Shoots accurately from a horse or moving vehicle (normally a wild shot) at half strike bonuses; a called shot is impossible. 4. Shoots accurately standing on the head or hanging upside down at full bonuses. 5. Dodges, rolls or somersaults and comes up shooting on a straight roll of the dice, no bonuses or penalties. 6. Ricochet shot: bounces a bullet, arrow or other fired projectile off one surface to hit a second target, one point of damage to the first surface and full damage to the second, at half strike bonuses; lasers need a mirrored or highly polished surface, and particle beams, ion blasters, rail guns and mini-missiles cannot be ricocheted."
equipment_starting:
  - { choose: 1, label: "homemade M.D.C. body armor", qty: 1, from: ["homemade-mdc-armor-light", "homemade-mdc-armor-medium"], note: "The book says a hodgepodge of homemade armor (35-65 M.D.C.) or any modern armor (30-100 M.D.C.); Warlord Cossacks tend to wear medium modern armor (50-80 M.D.C.), usually environmental." }
  - { item_id: "vibro-sword", qty: 1, note: "2D6 M.D." }
  - { item_id: "e-clip", qty: 2, note: "Two extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1, note: "The book says a silver knife or sword." }
  - { item_id: "small-silver-cross", qty: 1, note: "The book says a silver cross." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "goggles", qty: 1, note: "The book says tinted goggles." }
  - { item_id: "hatchet", qty: 1, note: "For chopping wood." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a lighter." }
  - { item_id: "sack", qty: 1, note: "Medium-sized." }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "cord", qty: 1, note: "30 feet (9 m), 600 lb. (270 kg) test strength." }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a cloak or cape (often fur)." }
  - { item_id: "riding-horse", qty: 1, note: "Vehicle: a good quality riding horse." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most tend to be good, Unprincipled or Aberrant."
  - "Racial restrictions: none. About 80% are humans of mixed Russian heritage, but anybody, D-Bees included, who accepts Cossack law, tradition and people as his own can become Cossack."
  - "Attribute requirements: P.P. 12 or higher."
  - "Robot horses are never ridden; partial bionic horses are acceptable."
  - "Cybernetics: none to start, and avoided as unnatural. The only cybernetics a Cossack will consider are prosthetics and organs replacing those severely injured or lost in combat."
extraction_notes: "WB17 Warlords of Russia printed 73-76 (cache p074-p077, cache page = printed folio + 1), read off the text layer. The entry heading Cossack O.C.C. is at cache p074; the numbered Special Cossack O.C.C. Skills and Bonuses run p075-p076; the stat block starts p076 and ends with Money and Cybernetics on p077. || HEADING: the stat block is headed The Russian Cossack O.C.C. and NPC Villain, also known as The Steppe Horseman; it is a playable O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the Cossack ladder on the Experience Tables, printed 6, read off a render (shared with the Wingrider RPA Pilot). || SPECIAL SKILLS: 1 Horsemanship: Cossack 55%/45% +5% is stored at the first percentage (the catalog row carries 55/5); 2 Breaking/Taming a Wild Horse is printed Base Skill (Cossack) 40% +5% and stored flat at 40; 3 Herding Cattle 30% +5%; 4 Trick Riding; 6 Trick Shooting, all six, stored as the W.P. Trick Shooting row plus a special_abilities entry that lists the six. The mounted combat bullets of skill 1 are all conditional on being on horseback and are prose in special_abilities, never bonuses. || BONUSES (item 5): +1D4 M.A., +1D6 P.S., +1D4 P.P., +1D4 P.E., +1D6 Spd and +3D6 S.D.C. are printed as applying only to those born and raised as Cossacks, so they are a special_abilities entry and GM Notes, not the bonuses block; the text layer prints the dice as +!D4 and +!D6. || SKILLS: Speaks Russian at 98% stored as base 98; Chinese and Euro (+15%) stored as two rows at 65. Pilot Skills are printed as Sailing, Hovercycle, Motorcycle, Snow Mobile/Jet, Jet Pack and similar small, fast vehicles only; the four catalog rows that carry those names are stored and the similar-vehicles clause is in the note. Science Math is read as both Mathematics rows. Electrical and Mechanical are printed None and left out. || MONEY: 2D4x100 credits stored (the text layer prints 2D4xlOO); the 1D4x1000 credits of tradeable goods (printed !D4xlOOO) are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; personal items have no row; the belt has no Rifts row (its only row is Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The boots (as work-boots-rifts), the bedroll, the cloak or cape and the good quality riding horse under Vehicle are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The one unearthly riding animal (probably a Horned Steed) is a creature row (horned-steed, Warlords of Russia p.165-166), not gear, and is not granted. The armor choice offers this book''s two homemade armor rows; the modern armor alternative is in the note. The silver cross, tinted goggles and lighter use the nearest catalog rows and say so in their notes. || NOT STORED: the clan size note (1D6x10 members, tribes of 1D6x1000 up to 18,000) and the Megahorse line (about 5% ever get one) are background."
---

## Lore

Cossacks are the horsemen of the southern steppe: nomadic clans of riders,
warriors, farmers and cattlemen who carry mega-damage rifles and Vibro-Swords
beside the traditional sword and fur cap. Children grow up among horses and
stranger riding animals, and a Cossack rides with the hunts and war parties
from about sixteen.

They think of themselves as Cossack first and Russian second. Under the
rough, loud, brawling surface sits a strict code: loyalty to one''s people,
then strength and courage tempered by wisdom and mercy, and a deep love of
freedom. Anyone willing to live by that law, a foreigner or a D-Bee included,
can be adopted into a clan.

Some bands ride for a Warlord, drawn by a cause they can believe in and by
pay, land and glory. Inside a War Camp they stay a tight troop of their own,
answer to their own chieftain, and will refuse an order they find
dishonorable, which makes the rest of the camp wary of them.

## GM Notes

Born and raised Cossacks only: +1D4 M.A., +1D6 P.S., +1D4 P.P., +1D4 P.E.,
+1D6 Spd and +3D6 physical S.D.C. These are not applied by the sheet; roll and
add them by hand for a character who was not adopted into the clan.

Horsemanship: Cossack is 55%/45% +5% per level; the second number is rolled
for a charge (to stay mounted) and for a horse attack. Riding bareback is
-10%. Mounted: +1 initiative at levels 1, 4, 8, 12 and 15, +2 parry or dodge,
+2 roll when knocked from the horse, +6 S.D.C. or +1D4 M.D. with a melee
weapon; a charge with lance, pole-arm or spear does +2D6 S.D.C. or +1D4 M.D.
and costs two attacks. Wild bulls, broncos and exotic animals, and bull
wrestling, are at -15% on Breaking/Taming.

Starting kit beyond what the sheet lists: one weapon for each W.P. with two
extra clips apiece, a belt (no Rifts row) and some personal items. The armor may instead be any modern suit of 30-100
M.D.C.; Warlord Cossacks tend to wear medium, usually environmental, armor of
50-80 M.D.C.

Mounts: the good quality riding horse is on the sheet; the one unearthly
riding animal, probably a Horned Steed, is not. Other exotic mounts are earned in play; only about 5% of
Cossacks ever get a Megahorse.

Money is 2D4x100 credits plus 1D4x1000 credits of tradeable goods, very
likely one or two riding animals the character does not want.

Cossacks in a War Camp are disciplined by their own chieftain, and may refuse
or leave over an order they find dishonorable: aiding a sworn enemy or
demonic forces, killing innocents without cause, betrayal, or invading
Cossack territory.
',
       updated_at = datetime('now')
 WHERE class_id = 'cossack'
   AND instr(markdown, 'and the class does not grant or list either') > 0
   AND length(markdown) = 14693;

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
extraction_notes: "WB17 Warlords of Russia printed 61-64 (cache p062-p065, cache page = printed folio + 1), read off the text layer. The stat block starts on printed 63 and ends with Money and Cybernetics on printed 64. || HEADING: Ectohunter O.C.C., also known as Ghost Hunters and spiritualists; listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base. || XP: the Ectohunter, Travelling Story Teller and Warlord Cyber-Doc ladder as given in the brief, read off a render of the Experience Tables on printed 6. || SPECIAL ABILITIES: the eleven numbered Special Ectohunter O.C.C. Abilities (printed 62-63) are stored as special_abilities, except 6 (P.P.E.), which is ppe_base, and 10 (O.C.C. Bonuses), which is split: +1 pull punch is in bonuses, +1 to save vs illusions is saves.other because the book says illusions and not illusionary magic, and +2 initiative against ghostly beings only is conditional and stored as an ability. || HORROR FACTOR: +1 at levels 1-10, 12 and 14 stored as horror_factor 1 plus eleven at_level entries; the book qualifies it as applying to supernatural monsters and horrors, which is stated in the ability and is a reading. || POSSESSION: +10 flat plus +1 at levels 2, 4, 6, 8, 10, 12 and 14, as printed. || P.P.E.: 4D6 plus the P.E. attribute number, plus 1D4 per level. The class casts no spells of its own (it reads scrolls and uses magic items), so there is no magic block. || PSIONICS: not a requirement; about one third have minor or major psionics; no block and no roll is printed. || VULNERABILITY: the M.E. loss and insanity rolls are in side_effects and an ability; nothing applies them. ''Every other level'' prints no starting level. || SKILLS: Speaks Euro and two other languages of choice (+20%) is read as Euro at +20% and two Language: Other picks at +20%. Surveillance Systems maps to Surveillance, Read Sensory Equipment to Sensory Equipment. Lore: one of choice is one pick across the Lore: rows of Technical and Cowboy. Pilot: one of choice (+5%) offers all of Pilot; the O.C.C. line prints no exclusion. W.P. Energy Weapon of choice is a W.P. category pick with the restriction in the note. || PILOT EXCEPT: ''except robots, power armor, military vehicles, ships and aircraft'' read literally as all ships and all aircraft, mapped to the Robot rows, the Military: rows, Boat: Ships, Airplane, Helicopter, Jet Aircraft, both Fighter Combat rows, the three Space craft rows and Wingrider Flying Wing. Air Assault Armor, Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored. The +15% to language or computer skills reaches every Language: and Literacy: row and every Computer row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): a second Technical entry holds the Language:, Literacy: and Computer rows by prefix at +15, a second Communications entry the Literacy: rows and Language: Dolphin/Whale at +15, and a second Electrical entry the Computer rows (Computer Repair) at +15. Language: All (magical) is left at Communications'' +10, because the catalog files it as an innate ability and not a learned language. Computer Hacking is a Rogue skill and Rogue is Streetwise only, so it gets no entry and stays unavailable. || MONEY: 1D6x1000 credits stored (the text layer prints !D6xlOOO); the 1D6x100 in tradeable goods is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon of choice; a box of 100 large resealable plastic bags and personal items have no catalog row; the belt has no Rifts row (its only row is Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The clothing, bedroll, boots (as work-boots-rifts) and note pad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). Light suit of M.D.C. body armor maps to light-mdc-body-armor, the pair of silver knives to two knife-silver-plated, the mallet to hammer-and-mallet. || NOT STORED: the fee structure (as little as 100 credits to tens of thousands, a nonrefundable 10% retainer plus expenses), the nationality percentages, and Secret Resources are prose in GM Notes."
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
   AND instr(markdown, 'Clothing, bedroll and note pad rows exist now') > 0
   AND length(markdown) = 19675;

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
extraction_notes: "WB17 Warlords of Russia printed 66-69 (cache p067-p070, cache page = printed folio + 1), read off the text layer. Heading The Huntsman-Trapper O.C.C. at the top of printed 66; the special abilities are printed 66-68 and the stat block headed The Russian Huntsman-Trapper O.C.C. (also known as Woodsman and Trapper) starts on printed 68. The entry ends on printed 69, where its Note, Money and Cybernetics lines are interleaved in the text layer with the opening of the Travelling Story Teller (cache p070 lines 57-80 are the Huntsman''s). || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Huntsman-Trapper ladder on the Experience Tables, printed 6, read off a render; the book misprints level 5 as 18,501, level 4 ends at 16,500, so 16501 is stored. || BONUSES: +2 initiative, +3 pull punch, +3 vs possession stored flat; +1 to save vs magic is stored as spell_magic only (a reading: the book says magic, not spell or ritual); +2 vs poison and disease is stored as toxins_poisons 2 and disease 2; +1 vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 is stored as horror_factor 1 flat for level 1 plus eight at_level entries. || P.P.E.: 4D6 + P.E. attribute number and +1D4 per level, stored in ppe_base and repeated as a special ability. || SPECIAL ABILITIES: the three percentile abilities (Track and Trap 20%/30% +5%, Recognize Supernatural Shapechangers 30% +5%, Forest-wise 20% +4%) are special_abilities prose. Track & Trap Animals is ALSO stored as an occ skill at 20/5 because the catalog holds a row of that name at the same figures; that is a reading, and the 30% trapping number lives only in its note. Recognize Supernatural Shapechangers and Forest-wise have no catalog skill row. The Code of the Huntsman-Trapper (printed 68) is stored as a special ability, paraphrased. || SKILLS NOT STORED: Lore: Geomancy & Ley Lines (+10%) has no catalog row and is left out. Speaks Faerie has no catalog language row; it is stored as one of three Language: Other picks at +10%. || SKILL READINGS: Lore: Faeries is the catalog''s Lore: Faeries & Creatures of Magic; Identify Plants & Fruits is Identify Plants & Fruit; Tracking is Tracking (people); Advanced Math is Mathematics: Advanced. Falconry is filed under Military in the catalog, so Military appears with only Falconry at the +15% the book prints under Technical, although the book says Military: None; Whittling at +15% is not stored: Whittling & Sculpting takes Technical''s flat +10, and the printed +15% is kept here and in the related-skills note (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14). Prowl is filed under Physical and is reached by name through the Rogue only-list at +10%. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft (the Explorer on printed 65 says military aircraft; this entry does not); Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Huntsman may know how to ride a horse. Hand to Hand: Expert, no others available, is costs: {}. || MONEY: the book prints no coin: 4D4x100 credits WORTH of furs, horns, bone, nuggets of silver or gold and other tradeable goods (the text layer prints 4D4xlOO). starting_money is 0 and the goods are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, 20 feet of wire and personal items have no catalog row and are in GM Notes; the tinder box, frying pan and belt have no Rifts row (their only rows are Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The skinning knives, the flint, the cooking utensils (as utensil-kit-rifts), the bedroll, the boots (as work-boots-rifts), the fur cloak or long coat and the note pad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The text layer prints scalable for sealable. The armor is stored as the light homemade suit; the lore text on printed 67 says such armor is typically 30-60 M.D.C. and rarely environmental. || NOT STORED: Secret Resources and the Note on how Reavers, War Camp soldiers, Bogatyrs, Demon Hunters and Ectohunters regard the class are in GM Notes; only 15% have partial bionics (printed 67)."
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
   AND instr(markdown, 'Rows exist now for the skinning knives') > 0
   AND length(markdown) = 19520;

-- == reaver-mechanized-cavalryman ==
UPDATE imported_classes
   SET markdown = '---
id: reaver-mechanized-cavalryman
name: Reaver Mechanized Cavalryman
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.79-82
category: occ
tags: [combat, pilot, ranged]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { ME: 12, PP: 14 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "2d4x100"
bonuses:
  combat: { initiative: 2, roll: 1, pull_punch: 1, disarm: 1 }
  saves: { horror_factor: 2 }
  pools: { sdc: "2d6" }
  at_level:
    - { level: 3, saves: { horror_factor: 2 } }
    - { level: 6, saves: { horror_factor: 2 } }
    - { level: 9, saves: { horror_factor: 2 } }
    - { level: 10, saves: { horror_factor: 2 } }
    - { level: 12, saves: { horror_factor: 2 } }
    - { level: 15, saves: { horror_factor: 2 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Language: Russian", base: 96, per_level: 0, note: "Speaks Russian at 96%." }
    - { choose: 2, from: ["Language: Other"], bonus: 0, note: "Speaks two additional languages of choice. The book prints no bonus on this line." }
    - { name: "Motorcycles & Snowmobiles", base: 80, per_level: 4, note: "Pilot: Motorcycles (+20%) and Pilot: Snow Mobiles (+20%), printed as two lines." }
    - { name: "Hovercycles, Skycycles & Rocket Bikes", base: 90, per_level: 3, note: "Pilot: Hovercycles (+20%)." }
    - { name: "Jet Packs", base: 56, per_level: 4, note: "Pilot: Jet Packs (+14%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 15, note: "Pilot: two of choice (+15%); any except robot vehicles, power armor and ships." }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Read Sensory Equipment (+10%)." }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Camouflage", base: 30, per_level: 5, note: "+10%" }
    - { name: "Gymnastics", base: 30, per_level: 5 }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "The book prints General Athletics." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book prints W.P. Heavy Energy Weapon." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient weapons of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Hand to Hand: Expert may be changed to Martial Arts (or Assassin if evil) for the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Select four other skills at level one, and at levels 3, 6, 9 and 12 one skill of choice PLUS one piloting skill (the second pick at each of those levels must be a Pilot skill). Communications: any (+5%). Domestic: any. Electrical: Basic Electronics only. Espionage: Wilderness Survival only. Mechanical: Basic and Automotive Mechanics only (+10%). Medical: First Aid only. Military: any. Physical: any, except Acrobatics. Pilot: any (+10%). Pilot Related: any (+10%). Rogue: any. Science: Astronomy and Math only (+5%). Technical: any (+5%). W.P.: any. Wilderness: any (+5%)."
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
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Four secondary skills at level one and one more at levels 2, 5, 7, 10 and 14, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 14, count: 1 }
special_abilities:
  - name: "Special Combat Maneuver"
    description: "The RMC flies in overhead or makes a spectacular leap so that a passenger (typically a cyborg or another Cavalryman) can jump off in mid-air into the middle of the enemy. Those involved or nearby must save against a Horror Factor of 16: a roll below 5 means they run and lose 1D4+2 melee attacks or actions other than to flee and take cover; a roll of 5-16 means they are dumbfounded and lose two melee attacks or actions, while the leaper and the pilot keep attacking. Very effective against small groups of 6-12 enemies, especially with a pair of RMC; usually suicidal against larger groups. The RMC is immune to the effect of his own special attack and similar ones."
  - name: "Trick Shooting (three)"
    description: "Limited to three of the trick shooting abilities. Fires a two-handed weapon such as a rifle one-handed without penalty. Shoots accurately from a horse or moving vehicle (normally a wild shot) at half strike bonuses; a called shot is impossible. Dodges, rolls or somersaults and comes up shooting on a straight roll of the dice, no bonuses or penalties to strike."
  - name: "RMC Piloting Modifiers"
    description: "The normal penalties on all evasive, dog-fighting and trick piloting maneuvers with a vehicle are halved. Piloting on instinct when blinded or with vision obscured by smoke, fog and the like reduces the piloting skill by half only, instead of -90%. +1 action or attack per melee round when using a vehicle (an extra turn, leap or shot with a vehicle''s weapon). +1 to dodge when piloting small, fast vehicles such as jet packs, hovercycles, snow mobiles and motorcycles."
equipment_starting:
  - { item_id: "homemade-mdc-armor-medium", qty: 1, note: "The book says typically a hodgepodge of homemade armor (50-60 M.D.C.), but any modern armor (30-100 M.D.C.) can be used; most RMC prefer medium and heavy armor." }
  - { choose: 1, label: "large Vibro-Sword or Vibro-Claws (2D6 M.D.)", qty: 1, from: ["vibro-sword", "vibro-claws"] }
  - { item_id: "e-clip", qty: 4, note: "Four extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1, note: "The book says a silver knife or sword." }
  - { item_id: "small-silver-cross", qty: 1, note: "The book says a silver cross." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "goggles", qty: 1, note: "The book says tinted goggles." }
  - { item_id: "hatchet", qty: 1, note: "For chopping wood." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a lighter." }
  - { item_id: "sack", qty: 1, note: "Medium-sized." }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1, note: "A canteen or water skin." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "cord", qty: 1, note: "30 feet (9 m), 600 lb. (270 kg) test strength." }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a cloak or cape (often fur)." }
  - { item_id: "jet-pack-common", qty: 1, note: "Vehicles: starts with a jet pack." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Cybernetics: starts with a clock-calendar." }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Cybernetics: starts with a gyro-compass." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Unprincipled (25%), Anarchist (33%) and Miscreant (20%)."
  - "Racial restrictions: human; only about one percent are nonhuman."
  - "Attribute requirements: M.E. 12 and P.P. 14 or higher. A high P.S. and a reasonable I.Q. are helpful but not required."
  - "Cybernetics: starts with a clock-calendar and gyro-compass. Additional bionics can be acquired as a result of injury or as rewards from the Warlord, and the Reaver may decline such a reward."
extraction_notes: "WB17 Warlords of Russia printed 79-82 (cache p080-p083, cache page = printed folio + 1), read off the text layer. The heading Reaver Mechanized Cavalry O.C.C. is at cache p080; Special RMC O.C.C. Abilities and Bonuses run p080-p081; the stat block starts p081; Vehicles and a Note are on p082 and the entry ends with Money and Cybernetics at the top of p083, two page breaks past the stat block. || HEADING: the stat block is headed The Reaver Mechanized Cavalryman O.C.C. and NPC Villain, also known as Road Warriors and Reaver Maniacs; it is a playable O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the ladder shared with the Huntsman-Trapper on the Experience Tables, printed 6, read off a render. The book misprints level 5 as 18,501; level 4 ends at 16,500, so 16501 is stored. || RACE: the line reads Human; only about one percent are nonhuman, and the lore says less than one percent are D-Bees. Because the same line admits nonhumans it is not stored as race_restrictions and is in restrictions as printed. || BONUSES: +2 initiative, +1 roll with punch, fall or impact, +1 pull punch, +1 disarm and +2D6 physical S.D.C. stored flat. The line +2 to save vs Horror Factor at levels 1, 3, 6, 9, 10, 12 and 15 is stored as +2 flat and +2 at each of levels 3, 6, 9, 10, 12 and 15, cumulative as printed (a total of +14 at level 15). The RMC Piloting Modifiers (+1 attack per melee when using a vehicle, +1 dodge on small fast vehicles, halved penalties) are conditional and are prose in special_abilities. || TRICK SHOOTING: the RMC is limited to three of the six abilities, so the W.P. Trick Shooting row is NOT granted; the three are a special_abilities entry. || SKILLS: Speaks Russian at 96% stored as base 96. Pilot: Motorcycles (+20%) and Pilot: Snow Mobiles (+20%) are two printed lines that the catalog holds as one row, Motorcycles and Snowmobiles, stored once at 80. Pilot: Jet Packs is printed +14%, where every other bonus in the entry is a multiple of five; stored as printed (42 + 14 = 56). Speaks two additional languages prints no bonus. The two piloting picks of choice print any except robot vehicles, power armor and ships; the exclusion is in the note. W.P. Heavy Energy Weapon is stored as the catalog row W.P. Heavy M.D. Weapons. Gymnastics and General Athletics print no bonus. Related skills: one skill of choice plus one piloting skill at levels 3, 6, 9 and 12 is stored as two picks at each of those levels with the piloting condition in the note. || MONEY: 2D4x100 credits stored (the text layer prints 2D4xlOO); the 2D4x100 credits of tradeable goods and the 750 credit monthly salary are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; personal items have no row; the belt has no Rifts row (its only row is Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)); the boots (as work-boots-rifts), the bedroll and the cloak or cape are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit); the starting vehicle of choice (Tek-12 YY110 Bushbike, Tek-20 YY210 ''Borgbike, Warrior AH-Hoversled, Landflier or any snow mobile or jet sled) is not granted, though vehicle rows exist now (tek-12-yy110-bushbike, tek-20-yy210-borgbike, warrior-assault-hoversled-light, warrior-assault-hoversled-heavy, landflier, heavy-mdc-snowmobile, novyet-snow-jetsled; Warlords of Russia p.145-156). The armor row is this book''s homemade medium armor (50-65 M.D.C.), the nearest to the printed 50-60. The jet pack is this book''s common jet pack row. The silver cross, tinted goggles and lighter use the nearest catalog rows and say so in their notes. || NOT STORED: the proportions of cyborgs among the RMC (the lore says 43% partial and about 12% full conversion; the Cybernetics line says 8% Light Machines, 4% Heavy Machines and another 50% with one to three bionic prosthetics), which the two passages print differently."
---

## Lore

The Reaver Mechanized Cavalry are the daredevils of a War Camp. Where a
Cossack rides a horse, these Reavers go to war on combat motorcycles,
hovercycles, hoversleds and jet packs, threading forests and canyons and
making attack runs at over two hundred miles an hour.

Their signature is the drop: a low pass or a spectacular jump that lets a
passenger, often a cyborg, leap off into the middle of the enemy while the
pilot wheels around to strafe. Holding formation through gunfire, magic and
close combat at that speed takes nerve and focus, and the cavalry prize both.

Other Reavers treat them as hot-shot heroes, the Cossacks admire their skill,
and even the cyborg elite, who ignore most Reavers, let them keep company.
Many are part machine themselves, which is where the jokes about the
"Mechanized" Cavalry come from.

## GM Notes

Level-up skills: at levels 3, 6, 9 and 12 the character takes one related
skill of choice plus one piloting skill. The sheet offers two picks at those
levels; one of them must be a Pilot skill. The two O.C.C. piloting skills of
choice (+15%) may not be robot vehicles, power armor or ships.

Save vs Horror Factor is +2 at levels 1, 3, 6, 9, 10, 12 and 15, stored as
cumulative. The RMC is immune to the effect of his own Special Combat
Maneuver and similar attacks.

On a vehicle: +1 attack per melee, +1 dodge on small fast vehicles, half the
normal penalties on evasive, dog-fighting and trick maneuvers, and only half
skill (not -90%) when piloting blind.

Starting kit beyond what the sheet lists: one weapon for each W.P. with four
extra clips apiece, a belt (no Rifts row) and some personal items. The armor may instead be any modern suit of 30-100
M.D.C.; most RMC prefer medium and heavy armor.

Vehicles: a jet pack, plus one of the Tek-12 YY110 Bushbike, the Tek-20
YY210 ''Borgbike, the Warrior AH-Hoversled, the Landflier, or any type of snow
mobile or jet sled.

Money is 2D4x100 credits plus 2D4x100 credits of tradeable goods. Pay is 750
credits a month with food, basic clothing and equipment, medical attention
and a small cut of the spoils from raids the character takes part in.

About 8% of RMC are Light Machines and 4% Heavy Machines, and another 50%
have one to three bionic prosthetics, a handful of implants and weapons for
a bionic limb; retractable Vibro-Blades are extremely popular. Former RMC and
independent equivalents are met with suspicion and contempt by War Camps.
',
       updated_at = datetime('now')
 WHERE class_id = 'reaver-mechanized-cavalryman'
   AND instr(markdown, 'belt, boots and personal items have no row; the bedroll and the cloak') > 0
   AND length(markdown) = 15612;

-- == reaver-soldier ==
UPDATE imported_classes
   SET markdown = '---
id: reaver-soldier
name: Reaver Soldier
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.78-79
category: occ
tags: [combat]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]
attribute_requirements: { PS: 9, PE: 9 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d6x100"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "anarchist or evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "Speaks native language at 90%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Speaks two other languages of choice (+10%)." }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 5, note: "Piloting: two of choice (+5%)." }
    - { name: "Military Etiquette", base: 40, per_level: 5, note: "+5%" }
    - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "The book prints General Athletics." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two modern of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of one O.C.C. Related Skill, or to Martial Arts (or Assassin, if anarchist or evil) for the cost of two skills." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Jet Aircraft", "Helicopter", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Wingrider Flying Wing", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship", "Air Assault Armor"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Choose six other skills at level one. Communications: any. Domestic: any (+5%). Electrical: Basic Electronics only. Espionage: any (+5%). Mechanical: Basic Mechanics and Automotive only. Medical: First Aid only. Military: any (+5%). Physical: any, except Acrobatics. Pilot: any, except robots, ships and aircraft. Pilot Related: any. Rogue: any (+5%). Science: Math only. Technical: any (+5%). W.P.: any. Wilderness: any."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Boat: Ships", "Military: Warships & Patrol Boats", "Airplane", "Jet Aircraft", "Helicopter", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Wingrider Flying Wing", "Space: Space Fighter", "Space: Small Spacecraft", "Space: Starship", "Air Assault Armor"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Three secondary skills from the list at level one and one more at levels 3, 6, 9, 12 and 15, without the bonuses in parentheses."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
equipment_starting:
  - { choose: 1, label: "homemade M.D.C. body armor", qty: 1, from: ["homemade-mdc-armor-light", "homemade-mdc-armor-medium"], note: "The book says a hodgepodge of homemade armor (30-60 M.D.C.) or any modern armor (30-100 M.D.C.) available to the region." }
  - { item_id: "e-clip", qty: "1d4+1", note: "1D4+1 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "fragmentation-grenade", qty: "1d4" }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6" }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The book says a mallet." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "goggles", qty: 1, note: "The book says tinted goggles." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says a language translator." }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a lighter." }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
trackable_resources: []
restrictions:
  - "Alignment: any, but many lean toward selfish and evil."
  - "Racial restrictions: none, although the majority (80-90%) are human."
  - "Attribute requirements: P.S. 9 and P.E. 9 or higher, and a willingness to serve a Warlord and fight for Mother Russia (or power and glory). High physical attributes are a big plus but are not required."
  - "Cybernetics: none to start. More can be acquired as rewards for outstanding performance and heroics under fire, or bought by the Reaver with proper authorization; about half of the more experienced Reavers have at least one bionic prosthetic (arm or leg) and/or a handful of implants."
  - "Vehicle: starts with none, although one may be assigned for special missions and raiding."
  - "Reavers have no rights under the Warlords'' law but must obey it. Desertion, running away in combat, joining another War Camp and similar betrayals are punished by death; leaving through proper channels with the commander''s approval is allowed."
extraction_notes: "WB17 Warlords of Russia printed 78-79 (cache p079-p080, cache page = printed folio + 1), read off the text layer. The general Reaver O.C.C.s material that applies to all five Reaver classes runs printed 76-77 (cache p077 line 95 to p078); this class''s own heading The Average Reaver Soldier and its stat block start on cache p079 and the entry ends with Money and Cybernetics on p080. || HEADING: the stat block is headed Typical Reaver Grunt/Warrior O.C.C. and NPC Villain, also known as Raiders and Peasent Warriors (the book''s spelling); it is a playable O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the ladder shared with the Russian Explorer and Reaver Military Scout on the Experience Tables, printed 6, read off a render. The book misprints level 7 as 30,501; level 6 ends at 31,500, so 31501 is stored. || SKILLS: Speaks Native Language at 90% stored as base 90. The O.C.C. skill Piloting: two of choice (+5%) prints no exclusion and is stored as any Pilot. Related Pilot Skills are printed Any, except robots, ships and aircraft; that is read as the catalog rows Robots and Power Armor, Robot Combat: Basic, Robot Combat Elite and its eleven per-robot rows, Boat: Ships, Military: Warships and Patrol Boats, Airplane, Jet Aircraft, Helicopter, Military: Combat Helicopter and Military: Jet Fighters. Science Math only is read as both Mathematics rows. Mechanical is printed Basic Mechanics and Automotive only. || MONEY: 1D6x100 credits stored (the text layer prints !D6xlOO); the 5D6x10 credits of tradeable goods (printed 5D6xlO) and the 500 credit monthly salary are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; a handful of personal items have no row; the folding shovel and the belt have no Rifts row (their only rows are other games'', and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The boots (as work-boots-rifts) and the bedroll are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). A bedroll row exists now (bedroll-rifts); the class does not list it. The armor choice offers this book''s two homemade armor rows; the modern armor alternative is in the note. Tinted goggles, the lighter and the language translator use the nearest catalog rows and say so in their notes. || AS PRINTED: the Equipment Available On Assignment line says the Scout may have access to special weapons, explosives, equipment, vehicles and troops, in the soldier''s entry; it is in GM Notes as this class''s. || NOT STORED: the background lines of the general Reaver section (25-35% of a Warlord''s forces, 1-3% D-Bees, 20-33% with a few implants or one or two bionic limbs) and its statement that characters with magic or psionics or other foreign O.C.C.s may be Reavers but use their own O.C.C."
---

## Lore

Reavers are the bottom rung of a Warlord''s army: foreigners, steppe nomads,
peasants, refugees, bandits, mercenaries and the occasional D-Bee who can
never become Knights of the Realm. They swear to one Warlord, take the worst
jobs and the front of the line, and are treated as useful barbarians, valued
for how hard they fight and never fully trusted.

The ordinary Reaver soldier is a grunt with little schooling and a narrow set
of skills. Some are honest warrior-peasants who lean on combat and military
training; others are thieves at heart and drift toward rogue and espionage
work. What they share is loyalty, obedience and a willingness to fight.

People join because the camp is a way up. It pays, feeds and equips them,
gives them a share of the spoils, a purpose, and a measure of respect and
authority that a dirt farmer''s child would never have had otherwise.

## GM Notes

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+1
extra clips apiece, a folding shovel and a belt (no Rifts row for either)
and a handful of personal items. The armor may instead be any modern suit of 30-100 M.D.C.
available in the region.

Money is 1D6x100 credits plus 5D6x10 credits of tradeable goods. Pay is 500
credits a month with food, basic clothing and equipment, medical attention
and a tiny cut of the spoils from raids the Reaver takes part in.

No vehicle to start. Special weapons, explosives, equipment, vehicles and
troops may be issued by assignment, depending on the character, the Warlord
and the mission.

Reavers have no rights under the Warlords'' law and are still bound by it.
Deserting, fleeing a battle, defecting to another War Camp, selling secrets,
defying the Warlord or endangering comrades for gain all carry death. A
Reaver may leave freely with his commander''s approval. Most other soldiers of
the camp treat Reavers reasonably well.
',
       updated_at = datetime('now')
 WHERE class_id = 'reaver-soldier'
   AND instr(markdown, 'folding shovel, belt, boots and a handful of personal items have no row') > 0
   AND length(markdown) = 12390;

-- == russian-explorer ==
UPDATE imported_classes
   SET markdown = '---
id: russian-explorer
name: Explorer
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.64-65
category: occ
tags: [scholar, wilderness]
occ_group: optional
men_of_arms: false
xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]
attribute_requirements: { IQ: 9, MA: 9, PE: 9 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "2d4x100"
bonuses:
  combat: { dodge: 1, roll: 2 }
  saves: { toxins_poisons: 1, disease: 1, horror_factor: 2 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks native language at 98%." }
    - { choose: 3, from: ["Language: Other"], bonus: 15, note: "Three other languages of choice (+15%)." }
    - { name: "Anthropology", base: 40, per_level: 5, note: "+20%" }
    - { name: "Archaeology", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, categories: [{ name: "Technical", only_prefix: ["Lore:"] }, { name: "Cowboy", only_prefix: ["Lore:"] }], bonus: 15, note: "Lore: two of choice (+15%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Pilot: two of choice (+10%)." }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 45, per_level: 5, note: "Climb (+5%)." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Prospecting", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be raised to Hand to Hand: Expert for the cost of one O.C.C. Related Skill, or Martial Arts for the cost of two skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["Brewing", "Holistic Medicine"] }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"], bonus: 5 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Cardsharp", "Computer Hacking", "Streetwise"], bonus: 5 }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10, note: "+15% to art and language skills instead of +10%." }
      - { name: "Technical", only_prefix: ["Art", "Language"], bonus: 15, note: "+15% to art and language skills instead of +10%." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Choose seven other skills at level one. Many have video, photography, writing or art skills to document their explorations. Communications: any (+5%). Domestic: any (+5%). Electrical: Basic only. Espionage: Intelligence and Escape Artist only (+5%). Mechanical: Basic and Automotive only. Medical: Brewing and Holistic Medicine only. Military: none. Physical: any, except Boxing, Gymnastics and Acrobatics. Pilot: any (+5%), except robots, power armor, military vehicles, ships and military aircraft. Pilot Related: any (+10%). Rogue: Cardsharp, Computer Hacking and Streetwise only (+5%). Science: any (+5%). Technical: any (+10%; +15% to art and language skills). W.P.: any. Wilderness: any (+5%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["Brewing", "Holistic Medicine"] }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Boat: Ships", "Fighter Combat: Basic", "Fighter Combat: Elite", "Space: Space Fighter", "Space: Starship", "Wingrider Flying Wing", "Air Assault Armor"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Cardsharp", "Computer Hacking", "Streetwise"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Three secondary skills from the list at level one and one more at levels 2, 4, 6, 8 and 12, without the bonuses in parentheses."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1, note: "Light suit of M.D.C. body armor." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "hand-axe-utility", qty: 1, note: "Hand axe." }
  - { item_id: "pen-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "The book says a lighter." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "Box of matches." }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "small-sack", qty: "1d6" }
  - { item_id: "sack", qty: 6, note: "Medium-sized." }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "mechanical-pencil", qty: 1 }
  - { item_id: "mechanical-pencil-lead-24-in-a-pack", qty: 1, note: "Extra lead." }
  - { item_id: "cord", qty: 1, note: "50 feet (15.2 m), 600 lb. test strength." }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1, note: "The book says a bed roll." }
  - { choose: 1, label: "note or sketch pad", qty: 1, from: ["note-pad", "sketch-pad"] }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Racial restrictions: none; at least 30-40% are nonhuman."
  - "Attribute requirements: I.Q. 9, M.A. 9 and P.E. 9 or higher. High M.E., P.S. and Spd are helpful but not required."
  - "Psionics are not a requirement, although about 15% have minor or major psionics."
  - "Cybernetics: starts with none, but may acquire implants and the occasional bionic limb when they can be afforded; it depends on the individual."
  - "Vehicle: starts with a used, battered-looking hovercycle, motorcycle or similar small vehicle suitable for exploration, missing 1D4x10 M.D.C. from its main body but otherwise in good condition."
extraction_notes: "WB17 Warlords of Russia printed 64-65 (cache p065-p066, cache page = printed folio + 1), read off the text layer. The entry ends with Money and Cybernetics at the foot of printed 65; the next heading (Huntsman-Trapper) opens printed 66. || HEADING: Explorer O.C.C. (printed 64), stat block headed The Explorer O.C.C. (printed 65); listed under Russian Adventurer O.C.C.s on printed 57, so occ_group is optional and men_of_arms is false; the entry states no S.D.C. base. The id is russian-explorer; the book''s name is plain Explorer. || XP: the Explorer, Reaver Military Scout and Reaver Soldier ladder as given in the brief, read off a render of the Experience Tables on printed 6. The book misprints level 7 as 30,501; level 6 ends at 31,500, so 31501 is stored. || BONUSES: the four printed O.C.C. Bonuses are stored flat: +1 dodge, +2 roll with punch, fall or impact, +1 to save vs poison and disease (stored on both toxins_poisons and disease), +2 to save vs Horror Factor. The entry prints no numbered special abilities; its Special Skills and Bonuses are this bonus block and the skill list. || SKILLS: Speaks native language at 98% and three other languages of choice (+15%) is read as the +15% applying to the three other languages. Lore: two of choice (+15%) is two picks across the Lore: rows of Technical and Cowboy. Pilot: two of choice (+10%) offers all of Pilot; the O.C.C. line prints no exclusion. Electrical: Basic only is read as Basic Electronics. Medical: Brewing and Holistic Medicine only maps to the rows Brewing and Holistic Medicine; Brewing: Medicinal and Sea Holistic Medicine are not offered. || PILOT EXCEPT: ''except robots, power armor, military vehicles, ships and military aircraft'' is mapped to the Robot rows, the Military: rows, Boat: Ships, both Fighter Combat rows, Space: Space Fighter, Space: Starship and Wingrider Flying Wing; civilian Airplane, Helicopter and Jet Aircraft stay available. Whether ''ships'' means all ships or military ships is a reading; all ships is stored. Air Assault Armor, Combat Pod, Flight System Combat, Jet Packs and Jump Bike Combat are left available and need a human reading. || TECHNICAL: +10% stored; +15% to art and language skills is in the note only. || HAND TO HAND: Basic, to Expert for one related skill or Martial Arts for two; no Assassin option is printed. || MONEY: 2D4x100 credits stored (the text layer prints 2D4xlOO); the 2D4x100 in tradeable goods, including artifacts, is in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; a box of 100 sealable plastic sandwich bags, a box of 100 large sealable plastic bags (the text layer prints scalable) and personal items have no catalog row; the folding shovel and the belt have no Rifts row (their only rows are other games'', and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The bed roll and the note or sketch pad are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The box of matches maps to disposable-lighter-or-box-of-200-matches, the hand axe to hand-axe-utility, extra lead to mechanical-pencil-lead-24-in-a-pack. || NOT STORED: the vehicle, Secret Resources and the note on War Camp suspicion are prose in restrictions and GM Notes."
---

## Lore

The Explorer is a traveler by temperament rather than by trade: someone who
cannot leave a blank spot on the map alone. Lost cities, old temples, strange
peoples and stranger creatures pull them across Russia and Asia, and
sometimes through a Rift to somewhere else entirely. They carry what they
need on their backs and keep the rest in their heads.

They come from everywhere. Many grew up in comparatively advanced places such
as the New German Republic, and a large share are foreigners or D-Bees. Some
are hard to tell from mercenaries, some are bookish, and some are little more
than vagabonds. Their schooling is a patchwork of formal study, informal
training and time on the road.

What they share is curiosity and nerve. They like alien cultures and new
ideas, which wins them friends in odd places and enemies among those who
distrust outsiders. The things they go looking for do not always want to be
found.

## GM Notes

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+2
extra clips apiece, a folding shovel, a box of 100 sealable sandwich bags and
a box of 100 large sealable bags, a belt (no Rifts row for it or the shovel)
and a handful of personal items. Money is 2D4x100 credits plus 2D4x100 in
tradeable goods, which may include artifacts.

Vehicle: a used hovercycle, motorcycle or similar small vehicle missing
1D4x10 M.D.C. from the main body.

No secret resources as such, but they make friends and acquaintances all over
the world with time and travel. Reavers and War Camp soldiers hold explorers
in low regard as shiftless wanderers. Foreigners and D-Bees in particular are
treated with suspicion and may be searched, interrogated, threatened or
harassed; one believed to be a spy may be beaten, tortured, imprisoned or
executed.

About 15% have minor or major psionics; the book prints no roll for it.
',
       updated_at = datetime('now')
 WHERE class_id = 'russian-explorer'
   AND instr(markdown, 'Bed roll, note pad and sketch pad rows exist now') > 0
   AND length(markdown) = 13493;

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
extraction_notes: "WB17 Warlords of Russia printed 71-72 (cache p072-p073, cache page = printed folio + 1), read off the text layer. Heading Russian Villager O.C.C. on printed 71, with the stat block headed Typical Villager/Farmer/Worker O.C.C. & NPC (also known as peasants, citizens, and the Russian People). OPTIONAL: the book says the data can be used as a guide for creating Non-Player Characters or as an optional player character. The entry ends on printed 72: its related-skill list runs down the left column to Wilderness: Any (+5%), and its Secondary Skills, Standard Equipment, Vehicle, Money and Cybernetics lines top the right column (cache p073 lines 52-72), where the text layer interleaves them with the Warlord Troops & Men at Arms material that follows. || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the Villager ladder on the Experience Tables, printed 6, read off a render. || The entry prints NO O.C.C. bonuses, no Psionics line and no Secret Resources line; none is stored. Attribute requirements: none, so no attribute_requirements key. || SKILL READINGS: Speaks Native Language at 90% is Language: Native Tongue at 90. Lore: one of choice (+15%) is one pick from the catalog''s lore rows that fit the setting (the off-world and other-setting lores are left out of the list; a reading). Piloting: two of choice (+5%); no bonus for Horsemanship is stored as two Pilot picks at +5; the Horsemanship alternative at no bonus is in the note only, because one choice group carries one bonus. Animal Husbandry is stored at +5% (40); the +10% if a farmer or raises livestock is in the note. Sing or Dance is one pick from the two at +15. Hand to Hand: Basic to Expert costs TWO related skills and Martial Arts (or Assassin, if anarchist or evil) THREE, as printed across the page break of printed 71-72. Pilot Skills: any conventional types of vehicles and horsemanship, no robots, ships, aircraft or military vehicles: stored as Pilot minus the robot, ship, aircraft, spacecraft and military rows, with Horsemanship (its own catalog category) offered as General and Exotic Animals only. Ventriloquism is filed under Technical in the catalog and is reached by name through the Rogue only-list. Science: Astronomy and Math only is Astronomy, Mathematics: Basic and Mathematics: Advanced. Technical +10% to any animal related skills is not stored (Technical is a flat +5). Secondary skills: four at level one and one more at levels 3, 6, 9, 12 and 15. || MONEY: 1D6x10 credits stored (the text layer prints !D6xlO); the 2D4x10 credits worth of tradeable goods (2D4xlO) is in GM Notes. || EQUIPMENT not stored as rows: one M.D. weapon and two ancient weapons; pitchfork or blunt weapon and personal items have no catalog row and are in GM Notes; the shovel and the belt have no Rifts row (their only rows are other games'', and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The walking stick/staff or sword is a choice naming no particular sword and stays in GM Notes, though a walking-stick row exists. The tinted goggles, bedroll, water skin and boots (as work-boots-rifts) are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The armor is a choice of the catalog''s light and medium homemade suits for the printed 30-60 M.D.C. The bicycle or donkey is the Vehicle line and is in restrictions and GM Notes, not equipment."
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
   AND instr(markdown, 'Rows exist now for the walking stick, tinted goggles, bedroll and water skin') > 0
   AND length(markdown) = 13466;

-- == soldati ==
UPDATE imported_classes
   SET markdown = '---
id: soldati
name: Soldati (Warlord Soldier)
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.87-89
category: occ
tags: [combat]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
race_restrictions: { only: ["none"], note: "Exclusively human; about 35% are female." }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "2d4x100"
bonuses:
  combat: { initiative: 1, pull_punch: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "anarchist or evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 50, per_level: 5, note: "Math: Basic (+5%)." }
    - { name: "Language: Native Tongue", base: 92, per_level: 0, note: "Speaks native language at 92%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Speaks two other languages of choice (+10%)." }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Truck", base: 50, per_level: 4, note: "Pilot Truck (+10%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 5, note: "Piloting: two of choice (+5%)." }
    - { name: "Military Etiquette", base: 45, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "The book prints General Athletics." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two modern of choice (including energy weapons)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of one O.C.C. Related Skill, or to Martial Arts (or Assassin, if anarchist or evil) for the cost of two." }
  mos:
    choose: 1
    note: "Military Specialty (MOS): select three skills from ONE of these categories; each gets +10% regardless of the bonus listed for the category under O.C.C. Related Skills."
    options:
      - id: "communications"
        name: "Communications MOS"
        skills:
          - { choose: 3, categories: ["Communications"], bonus: 10 }
      - id: "mechanical"
        name: "Mechanical MOS"
        skills:
          - { choose: 3, categories: ["Mechanical"], bonus: 10 }
      - id: "medical"
        name: "Medical MOS"
        skills:
          - { choose: 3, categories: ["Medical"], bonus: 10 }
      - id: "piloting"
        name: "Piloting MOS"
        skills:
          - { choose: 3, categories: ["Pilot"], bonus: 10 }
      - id: "weapon-proficiencies"
        name: "W.P. MOS"
        skills:
          - { choose: 3, categories: ["Weapon Proficiencies"], bonus: 10 }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Sniper", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", bonus: 15 }
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Select four other skills at level one. Communications: any (+10%). Domestic: any. Electrical: Basic Electronics only. Espionage: Sniper and Wilderness Survival only. Mechanical: Basic and Automotive Mechanics only (+5%). Medical: First Aid only (+10%). Military: any (+15%). Physical: any. Pilot: any (+10%). Pilot Related: any (+10%). Rogue: any. Science: Astronomy and Math only. Technical: any (+10%). W.P.: any. Wilderness: any."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Sniper", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the list at levels 1, 4, 6, 9 and 12, without the bonuses in parentheses."
    schedule:
      - { level: 4, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { choose: 1, label: "medium or heavy body armor", qty: 1, from: ["sovietski-red-star-medium-body-armor", "battleforge-body-armor"], note: "The book says medium or heavy body armor, which may include Triax armor; these are the medium and the heavy suit this book prints." }
  - { item_id: "e-clip", qty: "1d4+1", note: "1D4+1 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "fragmentation-grenade", qty: 2, note: "2D6 M.D." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6" }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The book says a mallet." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1, note: "The book says distancing binoculars." }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1, note: "When not in armor." }
  - { item_id: "uniform", qty: 2, note: "Two standard uniforms." }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Cybernetics: Gyro-Compass to start." }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Attribute requirements: none. A high I.Q., P.S. and P.E. are helpful; any human in good health with the spirit to fight can become a soldier."
  - "Cybernetics: a Gyro-Compass to start. More can be acquired with rank, as rewards for outstanding performance and heroics under fire, or bought with proper authorization; about half of the more experienced Soldati have at least one bionic prosthetic (arm or leg) and/or a handful of implants."
  - "Vehicle: starts with none, although one may be assigned for special missions and raiding."
extraction_notes: "WB17 Warlords of Russia printed 87-89 (cache p088-p090, cache page = printed folio + 1), read off the text layer. The entry ends with its Cybernetics line at the top of printed 89, past the page break; class-check --field-sources shows it. || HEADING: Warlord Soldati/Soldier O.C.C., listed under Warlord Troops and Men at Arms O.C.C.s on printed 57, so men_of_arms is true and occ_group is men-of-arms. || XP: the ladder headed Sovietski Police and Soldati/Soldier on the Experience Tables, printed 6, read off a render. || BONUSES: +1 initiative and +1 pull punch stored flat; the +1 to save vs Horror Factor at levels 2, 4, 6, 8, 9, 10, 12 and 14 is stored as eight at_level entries, as printed. || MOS: three skills from one of Communications, Mechanical, Medical, Piloting or W.P., each at +10%; stored as five mos options of one three-pick group each. || MONEY: 2D4x100 credits is stored (the text layer prints 2D4xlOO); the 6D6x10 credits of tradeable goods and the 800 credit monthly salary are in GM Notes. || EQUIPMENT not stored as rows: one weapon for each W.P.; personal items have no catalog row; the folding shovel has no Rifts row (its only rows are other games'', and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)) and is in GM Notes. The bed roll is granted as bedroll-rifts, replacing the Palladium Fantasy bedroll row it held (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The armor choice names this book''s own medium and heavy suits."
---

## Lore

The Soldati are the Warlords'' regular infantry: battle-hardened foot soldiers
who patrol, escort, stand guard, run communications, labor and hold the front
line. Joining a War Camp lifts a soldier into an elite social position, and
most stay for life and bring their children into the same service.

They usually operate in squads of four to six. The life is harsh and the
camps'' idea of an interrogation is brutal, and it marks them in different
ways: some are hardened to suffering, some stay surprisingly compassionate,
some turn stoic or cruel. Many cover their skin in tattoos, worn like badges
for a first kill, an act of bravery or a specialty in killing monsters.

The people respect them, and so do most of their fellow troops, the Light and
Heavy Machines and the War-Knights included. Only envious Reavers tend to
treat them rudely.

## GM Notes

Pick one Military Specialty at creation: three skills from a single category
(Communications, Mechanical, Medical, Piloting or W.P.), each at +10%.

The save vs Horror Factor rises by +1 at levels 2, 4, 6, 8, 9, 10, 12 and 14.

Starting kit beyond what the sheet lists: one weapon for each W.P. with 1D4+1
extra clips apiece, a folding shovel (no Rifts row) and a handful of personal items. Money is 2D4x100 credits plus
6D6x10 credits of tradeable goods; pay is 800 credits a month with food,
basic clothing and equipment, medical attention and a tiny cut of the spoils.

No vehicle to start. Special weapons, explosives, vehicles and troops may be
issued by assignment, depending on the commander and the supply situation;
the combat soldier is typically at the bottom of the priority list.
',
       updated_at = datetime('now')
 WHERE class_id = 'soldati'
   AND instr(markdown, 'item_id: "bedroll", qty') > 0
   AND length(markdown) = 10480;

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
  - { item_id: "utensil-kit-rifts", qty: 1, note: "The book says cooking utensils." }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a cloak or long coat." }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { item_id: "work-boots-rifts", qty: 1, note: "The book says boots." }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "pencil", qty: 12, note: "The book says a dozen pencils." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none, although the majority (80%) are human."
  - "Attribute requirements: I.Q. 8, M.A. 10 and P.E. 10 or higher."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Basic only; no others are available."
  - "Cybernetics: none to start, and usually avoids them. A Story Teller might consider one or two minor implants, and will use cybernetics as prosthetics and organ replacements if needed."
  - "Vehicle: none to start; most Story Tellers like to walk, but eventually acquire a horse or small vehicle."
extraction_notes: "WB17 Warlords of Russia printed 69-71 (cache p070-p072, cache page = printed folio + 1), read off the text layer. Heading Travelling Story Teller O.C.C. on printed 69, where the text layer interleaves its opening with the end of the Huntsman-Trapper (cache p070 lines 57-80 belong to the Huntsman); the stat block headed The Russian Story Teller O.C.C. starts on printed 69 and the entry ends with its Vehicle, Secret Resources, Money and Cybernetics lines at the top of printed 71, past the page break. || GROUP: listed under Russian Adventurer O.C.C.s on printed 57; the entry states no S.D.C. base, so men_of_arms is false and occ_group is optional. || XP: the ladder naming the Travelling Story Teller on the Experience Tables, printed 6, read off a render. || BONUSES: +1 vs possession, +1 vs poison and disease (stored as toxins_poisons 1 and disease 1) and +2 vs Horror Factor, all flat. || LORE: the book prints Lore: all those applicable to Europe and Asia, including history, animal, demon, monster, magic and faerie lore (+20%). Stored as the five the line names: Lore: History of Russia, Lore: Cattle & Animals (a reading for animal lore; it is the only animal lore row, filed under Cowboy), Lore: Demons & Monsters, Lore: Magic, Lore: Faeries & Creatures of Magic, each at catalog base +20. Other lores a GM may judge applicable (D-Bee, Vampires, Religion, Psychics & Psionics) are NOT stored; the line says including, so the five are not a closed list. || SKILL READINGS: Speaks Euro and two other languages of choice (+20%) is Language: Euro at 70 plus two Language: Other picks at +20; Literacy: one of choice is one Literacy: Other pick at +10; Identify Plants & Fruits is Identify Plants & Fruit. Technical +15% to language skills reaches every Language: and Literacy: row wherever the catalog files it, and not Language Dialects (Nate''s ruling, BOOK-INGEST-AUDIT.md F138, 2026-10-14): a second Technical entry holds the Language: and Literacy: rows by prefix at +15 beside the flat +10 for the rest of Technical, and a second Communications entry holds the Literacy: rows and Language: Dolphin/Whale at +15 beside the flat +5. Language: All (magical) is left at Communications'' +5, because the catalog files it as an innate ability and not a learned language. Medical: none, other than those above, is stored as no Medical category. Pilot: any, except robots, power armor, military vehicles, ships and aircraft is read as excluding ALL ships and aircraft; Horsemanship is its own catalog category and is offered as General and Exotic Animals only, on the Vehicle line''s remark that a Story Teller eventually acquires a horse. Hand to Hand: Basic, no others available, is costs: {}. || MONEY: 3D4x20 credits, as printed. || EQUIPMENT not stored as rows: one M.D. weapon of choice; butcher''s knife, grinder, a box of 100 large resealable plastic bags and personal items have no catalog row and are in GM Notes; the meat cleaver, frying pan, small pot, small kettle, bowl and belt have no Rifts row (their only rows are Palladium Fantasy''s, and a row tagged for another game is not granted to a Rifts class (Nate''s ruling, BOOK-INGEST-AUDIT.md F139, 2026-10-12)). The cooking utensils (as utensil-kit-rifts), cloak or long coat, bedroll, boots (as work-boots-rifts), note pad and dozen pencils are granted (BOOK-INGEST-AUDIT.md F139, branch pal/data/book-ingest-audit-f139-russia-kit). The cloak or long coat, bedroll, note pad and dozen pencils have rows now (cape-or-cloak-long, bedroll-rifts, note-pad, pencil); the class does not list them and they stay in GM Notes too. The book attaches the 600 lb test strength to the 10 feet of thin nylon cord here. || NOT STORED: Secret Resources (regard and influence) and the neutrality that lets a Muzhik cross between Warlords'' Spheres of Influence without fees or tribute are in GM Notes. The body text on printed 69 says they are well versed in medicine and practical skills; no numbers beyond the skill list."
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
knife, grinder, a box of 100 large resealable plastic bags, a meat cleaver,
frying pan, small pot, small kettle, bowl and belt (no Rifts row for any of
those six) and a handful of personal items. They start with no magic items,
potions or artifacts, though many acquire a handful over time.

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
   AND instr(markdown, 'small kettle, bowl and grinder, a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row') > 0
   AND length(markdown) = 13982;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 11 classes carry their new text' AS assertion, count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE (class_id = 'bogatyr-hero-knight' AND instr(markdown, 'item_id: "work-boots-rifts"') > 0)
    OR (class_id = 'born-mystic' AND instr(markdown, 'item_id: "riding-horse"') > 0)
    OR (class_id = 'cossack' AND instr(markdown, 'item_id: "riding-horse"') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, 'item_id: "work-boots-rifts"') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, 'item_id: "utensil-kit-rifts"') > 0)
    OR (class_id = 'reaver-mechanized-cavalryman' AND instr(markdown, 'item_id: "work-boots-rifts"') > 0)
    OR (class_id = 'reaver-soldier' AND instr(markdown, 'item_id: "work-boots-rifts"') > 0)
    OR (class_id = 'russian-explorer' AND instr(markdown, 'item_id: "bedroll-rifts"') > 0)
    OR (class_id = 'russian-villager' AND instr(markdown, 'item_id: "work-boots-rifts"') > 0)
    OR (class_id = 'soldati' AND instr(markdown, 'item_id: "bedroll-rifts"') > 0)
    OR (class_id = 'travelling-story-teller' AND instr(markdown, 'item_id: "utensil-kit-rifts"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'bogatyr-hero-knight' AND instr(markdown, 'antiseptic, a belt, boots and personal items have no catalog row') > 0)
    OR (class_id = 'born-mystic' AND instr(markdown, 'The vehicle is not a catalog gear row.') > 0)
    OR (class_id = 'cossack' AND instr(markdown, 'and the class does not grant or list either') > 0)
    OR (class_id = 'ectohunter' AND instr(markdown, 'Clothing, bedroll and note pad rows exist now') > 0)
    OR (class_id = 'huntsman-trapper' AND instr(markdown, 'Rows exist now for the skinning knives') > 0)
    OR (class_id = 'reaver-mechanized-cavalryman' AND instr(markdown, 'belt, boots and personal items have no row; the bedroll and the cloak') > 0)
    OR (class_id = 'reaver-soldier' AND instr(markdown, 'folding shovel, belt, boots and a handful of personal items have no row') > 0)
    OR (class_id = 'russian-explorer' AND instr(markdown, 'Bed roll, note pad and sketch pad rows exist now') > 0)
    OR (class_id = 'russian-villager' AND instr(markdown, 'Rows exist now for the walking stick, tinted goggles, bedroll and water skin') > 0)
    OR (class_id = 'soldati' AND instr(markdown, 'item_id: "bedroll", qty') > 0)
    OR (class_id = 'travelling-story-teller' AND instr(markdown, 'small kettle, bowl and grinder, a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('bogatyr-hero-knight', 'born-mystic', 'cossack', 'ectohunter', 'huntsman-trapper', 'reaver-mechanized-cavalryman', 'reaver-soldier', 'russian-explorer', 'russian-villager', 'soldati', 'travelling-story-teller') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~197-book-ingest-audit-f139-russia-kit.sql');
