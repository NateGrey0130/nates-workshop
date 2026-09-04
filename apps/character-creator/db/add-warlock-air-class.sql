-- RETRO-AUDIT R3, taken as an import: the Warlock (Air).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-warlock-air-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-warlock-air-class.sql
--
-- WHY THIS CLASS EXISTS. The generic `warlock` offered a first-level character
-- every level-1 spell in the catalog - 50 of them - including wizard magic its
-- own summary forbids outright ("A warlock cannot learn spell magic of any other
-- kind"). RETRO-AUDIT R3 established that magic.spells_from CANNOT fix that: the
-- Elemental Force is chosen PER CHARACTER and no field records which one, so a
-- class-level list could only be the union of all four spheres. The route that
-- works is per-Force classes, the way the Elemental Fusionists are split into
-- fire-water and earth-air. That is an import decision and it was taken on
-- 2026-09-04.
--
-- THE RULE, from Conversion Book One printed 67 (cb1 cache p068, offset 1 read
-- from scripts/books.json) and restated in this class's own Elemental Spell
-- Magic ability:
--   Three spells at first level from the sphere's FIRST level list, and three
--   more at every level of experience, chosen from any spell level up to the
--   character's own (a third level Warlock picks from levels 1-3).
--
-- "Elemental Magic goes up to eighth level only", and every one of the 231
-- elemental spells in the catalog sits at spell level 1-8, which corroborates it.
--
-- A named `from` list REPLACES the spell-level cap rather than combining with it
-- (js/leveling.js startingGroups), so the cap lives INSIDE the lists: one
-- cumulative list per spell level, and the schedule points each experience level
-- at the right one. Levels 9-15 all point at L8, because the magic stops there.
--
-- The generic `warlock` is retired by retire-warlock-generic.sql, which sorts
-- after every add-warlock-*.sql file.

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'warlock-air', 'Warlock (Air)', 'rifts', '---
id: warlock-air
occ_group: magic
name: Warlock
system: rifts
source_book: Rifts Conversion Book One p.66-71
category: occ
attribute_requirements: { IQ: 6, ME: 10 }
ppe_base: "2d4x10+20 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "2d6x1000"
magic:
  type: "elemental"
  # Three at first level from the sphere''s FIRST level list, three more at
  # every level after, choosing from any spell level up to the character''s own.
  # Conversion Book One printed 67. RETRO-AUDIT R3.
  spells_starting: 3
  spells_from: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap"]
  # One cumulative list per spell level. A named `from` list REPLACES the
  # spell-level cap rather than combining with it (js/leveling.js), so the
  # cap has to be inside the list - which is why there are eight of them.
  spell_lists:
    L1: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap"]
    L2: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence"]
    L3: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush"]
    L4: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush", "Air: Ball Lightning", "Air: Calm Storms", "Air: Dissipate Gases", "Air: Freeze Water", "Air: Invisibility", "Air: Leaf Rustler", "Air: Lightblade", "Air: Lightning Arc", "Air: Phantom Footman", "Air: Protection from Lightning"]
    L5: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush", "Air: Ball Lightning", "Air: Calm Storms", "Air: Dissipate Gases", "Air: Freeze Water", "Air: Invisibility", "Air: Leaf Rustler", "Air: Lightblade", "Air: Lightning Arc", "Air: Phantom Footman", "Air: Protection from Lightning", "Air: Breath of Life", "Air: Circle of Rain", "Air: Darken the Sky", "Air: Detect the Invisible", "Air: Invisible Wall", "Air: Phantom", "Air: Phantom Mount", "Air: Sonic Blast", "Air: Whirlwind"]
    L6: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush", "Air: Ball Lightning", "Air: Calm Storms", "Air: Dissipate Gases", "Air: Freeze Water", "Air: Invisibility", "Air: Leaf Rustler", "Air: Lightblade", "Air: Lightning Arc", "Air: Phantom Footman", "Air: Protection from Lightning", "Air: Breath of Life", "Air: Circle of Rain", "Air: Darken the Sky", "Air: Detect the Invisible", "Air: Invisible Wall", "Air: Phantom", "Air: Phantom Mount", "Air: Sonic Blast", "Air: Whirlwind", "Air: Electrical Field", "Air: Electro-Magnetism", "Air: Mist of Death", "Air: Snow Storm", "Air: Vacuum", "Air: Whisper of the Wind"]
    L7: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush", "Air: Ball Lightning", "Air: Calm Storms", "Air: Dissipate Gases", "Air: Freeze Water", "Air: Invisibility", "Air: Leaf Rustler", "Air: Lightblade", "Air: Lightning Arc", "Air: Phantom Footman", "Air: Protection from Lightning", "Air: Breath of Life", "Air: Circle of Rain", "Air: Darken the Sky", "Air: Detect the Invisible", "Air: Invisible Wall", "Air: Phantom", "Air: Phantom Mount", "Air: Sonic Blast", "Air: Whirlwind", "Air: Electrical Field", "Air: Electro-Magnetism", "Air: Mist of Death", "Air: Snow Storm", "Air: Vacuum", "Air: Whisper of the Wind", "Air: Atmospheric Manipulation", "Air: Hurricane", "Air: Rainbow", "Air: Tornado"]
    L8: ["Air: Breathe Without Air", "Air: Cloud of Slumber", "Air: Cloud of Steam", "Air: Create Light", "Air: Create Mild Wind", "Air: Stop Wind", "Air: Thunderclap", "Air: Change Wind Direction", "Air: Cloak of Darkness", "Air: Create Air", "Air: Distant Voice", "Air: Electric Arc", "Air: Heavy Breathing", "Air: Howling Wind", "Air: Levitate", "Air: Mesmerism", "Air: Miasma", "Air: Northwind", "Air: Orb of Cold", "Air: Silence", "Air: Air Bubble", "Air: Call Lightning", "Air: Darkness", "Air: Fingers of the Wind", "Air: Float in Air", "Air: Frequency Jamming", "Air: Frostblade", "Air: Northern Lights", "Air: Resist Cold", "Air: Sheltering Force", "Air: Walk the Wind", "Air: Wave of Frost", "Air: Wind Rush", "Air: Ball Lightning", "Air: Calm Storms", "Air: Dissipate Gases", "Air: Freeze Water", "Air: Invisibility", "Air: Leaf Rustler", "Air: Lightblade", "Air: Lightning Arc", "Air: Phantom Footman", "Air: Protection from Lightning", "Air: Breath of Life", "Air: Circle of Rain", "Air: Darken the Sky", "Air: Detect the Invisible", "Air: Invisible Wall", "Air: Phantom", "Air: Phantom Mount", "Air: Sonic Blast", "Air: Whirlwind", "Air: Electrical Field", "Air: Electro-Magnetism", "Air: Mist of Death", "Air: Snow Storm", "Air: Vacuum", "Air: Whisper of the Wind", "Air: Atmospheric Manipulation", "Air: Hurricane", "Air: Rainbow", "Air: Tornado", "Air: Creature of the Wind", "Air: Wind Blast", "Air: Wind Cushion"]
  spells_schedule:
    - { level: 2, count: 3, from_list: "L2" }
    - { level: 3, count: 3, from_list: "L3" }
    - { level: 4, count: 3, from_list: "L4" }
    - { level: 5, count: 3, from_list: "L5" }
    - { level: 6, count: 3, from_list: "L6" }
    - { level: 7, count: 3, from_list: "L7" }
    - { level: 8, count: 3, from_list: "L8" }
    - { level: 9, count: 3, from_list: "L8" }
    - { level: 10, count: 3, from_list: "L8" }
    - { level: 11, count: 3, from_list: "L8" }
    - { level: 12, count: 3, from_list: "L8" }
    - { level: 13, count: 3, from_list: "L8" }
    - { level: 14, count: 3, from_list: "L8" }
    - { level: 15, count: 3, from_list: "L8" }
bonuses:
  saves: { horror_factor: 2, spell_magic: 1, ritual_magic: 1, possession: 1 }
skills:
  occ_skills:
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Speaks two additional Languages (+10%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 10, note: "Literate in a Language of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "Lore: Demon & Monster (+10%)." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 30, per_level: 5, note: "Lore: Faerie Folk (+5%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 55, per_level: 5, note: "Pilot Hover Craft (+5%)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient of choice (select one)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern of choice (select one)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of two O.C.C. Related Skills, or Martial Arts for the cost of three." }
  occ_related_skills:
    count: 8
    categories:
      - "Communications"
      - { name: "Cowboy", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Domestic"
      - "Electrical"
      - { name: "Espionage", only: ["Tracking (people)", "Wilderness Survival"] }
      - "Horsemanship"
      - "Mechanical"
      - "Medical"
      - { name: "Physical", except: ["Boxing", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "TWO of the eight must be from Wilderness or Domestic - a composition constraint the count field cannot express. Domestic +10%, Espionage: Tracking and Wilderness Survival only (+5%), Medical: Any (+10% on Holistic Medicine), Pilot: Any (+5%) except robots and military vehicles, Science +10%, Technical +10%, Wilderness +10%. Military: none."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "hooded-robe", qty: 2 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "flint", qty: 1 }
  - { item_id: "charcoal", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "elemental-symbol", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "sidearm", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "triax-pump-weapon"] }
natural_abilities:
  - name: "Elemental Spell Magic"
    description: "The Warlock does not LEARN magic - he draws it intuitively from a supernatural Elemental Intelligence. At first level a Warlock of ONE Elemental Force selects three spells from his sphere''s first level list; at every new level of experience he selects three more, and may choose from any level up to his own experience level (so a third level Warlock picks from levels 1-3). A Warlock of TWO Elemental Forces gains spells the same way but takes only ONE spell from EACH of his two spheres per level. Elemental Magic goes up to eighth level only. Under no condition can a Warlock learn any spell other than those his Elemental deity provides - no invocations, no rituals, no scrolls."
  - name: "Speak Elemental"
    description: "All Elementals communicate in a strange language combining telepathy and the spoken word. Every Warlock speaks and understands it at 98%; to everyone else it is incomprehensible. Elementals have no written language."
  - name: "Sense Elementals"
    description: "Senses the presence of an Elemental within a 120 foot (36.6 m) radius. Base Skill: 25% +5% per level. Deliberately searching when Elemental Forces appear to be at work gives +20% and doubles the range to 240 feet (73.2 m). A Warlock also intuitively recognises a fellow Warlock and instantly knows which Elemental Force or Forces he is allied to (but not level or alignment), and has a 01-75% chance of seeing an invisible Elemental - Air Elementals, Spirits of Light and the Demonic Jinn included."
  - name: "P.P.E. and its limits"
    description: "A disciple of ONE Elemental Force has 2D4x10+20 P.P.E. in addition to the P.E. attribute; of TWO Forces, 2D4x10+40. Add 2D6 P.P.E. per additional level. Unlike most practitioners of magic the Warlock CANNOT draw P.P.E. from other living creatures, but can draw it from Elemental beings of his own life sign, from ley lines and nexus points, and from magic storage cells such as certain talismans."
  - name: "Power Words and Symbols"
    description: "The Warlock knows the power words for the four Elemental Powers - Cherubot-kyn, Ariel-Rapere-kyn, Seraph-mytyn, and Tharsis-mycn and Yin - and the mystic symbols of the four Elementals plus the six stone symbols for Elemental Forces."
restrictions:
  - "Choose ONE or TWO Elemental Forces at creation (Air, Earth, Fire or Water) - the variant records HOW MANY, not which, and the choice is permanent. There is no field for the Force itself: the variants are one-force and two-forces, so a Fire Warlock and an Air Warlock are the same class and variant here, and the element lives on the player''s own record. RETRO-AUDIT R3, 2026-09-04. One Force needs I.Q. 6 and M.E. 10; two need I.Q. 12 and M.E. 14. A one-Force Warlock has greater mastery (three spells a level from one sphere); a two-Force Warlock has greater diversity (one from each sphere a level)."
  - "O.C.C. bonuses beyond the modeled saves: +6 (rather than +2) to save vs Horror Factor when the source is an Elemental being, and +1 to Spell Strength at levels 3, 6, 10 and 14."
  - "Cybernetics: starts with none and will avoid them."
extraction_notes: |
  - Rifts Conversion Book One (Revised) printed pp.66-71, adapted from
    the Palladium Fantasy RPG. The stamp said Book of Magic with these
    same page numbers for years, but BOM printed 66-70 holds Earth spell
    descriptions (levels 1-5), not the O.C.C. - BOM''s own O.C.C. index
    (printed 24) sends the Warlock to Conversion Book One Revised p.66,
    and Federation of Magic (printed 7) says the same. The elemental
    spell descriptions the class casts from are BOM''s (printed 57
    onward).
  - The one-Force / two-Force split is carried as VARIANTS because the only
    differences the schema can hold are attribute_requirements and ppe_base,
    both of which VARIANT_OVERRIDES allows. The spells-per-level difference
    (three from one sphere versus one from each of two) is NOT a variant key,
    so magic.spells_starting is the one-Force figure and the two-Force rule
    is stated in the Elemental Spell Magic ability.
  - The ELEMENT choice itself is per-character and has no schema shape: a
    class is static, and the wizard''s spell picker filters by level, not by
    sphere. Because the catalog names elemental spells with their sphere
    ("Fire: Fire Bolt"), typing the sphere into the picker''s filter box
    narrows it correctly - that is the intended workflow and it is stated
    here rather than left to be discovered.
  - WHAT THE PICKER DOES NOT STOP, recorded by RETRO-AUDIT R3 (2026-09-04):
    the summary says "A warlock cannot learn spell magic of any other kind",
    and nothing enforces it. spell_levels_allowed [1] gates by LEVEL only, so
    a first-level Warlock is offered all 50 level-1 spells in the catalog,
    including wizard magic the class may never learn. magic.spells_from could
    narrow that to the 37 level-1 ELEMENTAL spells, but not to the 9 a Fire
    Warlock should see, because no field records which Force was chosen. The
    route that works is per-Force classes, the way the Elemental Fusionists
    are split into two - an import decision, not a transcription.
  - spell_levels_allowed is [1] because a first level Warlock may only take
    first level spells; the level cap rising with experience is the class''s
    own rule and is described in the ability.
  - magic.type is "elemental", a new value alongside innate/spell - nothing
    branches on it today, but it is the honest label.
  - Equipment: two weapons matching the two W.P. selections are prose, as is
    the mount (a horse or other live animal, or a small fast hover vehicle).
    Money: 2D6x1000 credits + 3D4x1000 in Black Market items.
---

## Lore

A Warlock is a man or woman who draws magic powers from a supernatural, Elemental Intelligence. Like the Mystic and the Witch, there is no true knowledge of the mystic arts; instead the Warlock, through his link with the Supernatural Intelligence, intuitively knows certain Elemental spells. A Warlock is **not** a male witch, but an order of practitioners devoted to the Elemental Forces and Elemental-based magic: Air, Earth, Fire and Water.

One might assume Warlocks are closely attuned to nature, and in some ways they are, but not in the way one might think. They are not spiritualists like the Druids of England or Native American Shamans who try to live in harmony with their environment; the Warlock functions on a more primeval level, concerned with power, change and anarchy, for that is their vision of nature. Their world view is a picture of seething, unrestrained force, freedom and change.

As such, a Warlock binds himself to no man nor god - he is a free spirit who wanders the universe to observe and instigate change. They may become heads of state or even Emperor of a kingdom, or restrict their efforts to a life as a wandering philosopher or mercenary sorcerer, or all of the above during one lifetime. Life, adventure, power and freedom are all important. They appreciate the forces of nature but use magic to bend them to their will. Personal freedom is revered above all else.

## GM Notes

**Picking spells by sphere.** The catalog names every elemental spell with its sphere - `Air: Cloud of Steam`, `Fire: Fire Bolt`, `Earth: Wall of Stone`, `Water: Tidal Wave` - because the same spell name recurs across spheres at different levels and P.P.E. costs, and several also exist as Invocations. In the wizard''s spell picker, type the sphere name into the filter box to narrow to that Warlock''s own element.

**One Force or two.** A Fire Warlock at third level has nine Fire spells; a Fire-and-Air Warlock at third level has three Fire and three Air (six total). Both are Elemental Magic, but the single-Force Warlock has greater control and mastery while the two-Force Warlock has greater diversity and less depth.

**Summoning Elementals.** Warlocks make it a point never to kill an Elemental they have summoned. When one is left to guard something, the Warlock will usually include the condition that the moment the Elemental senses its own destruction it is free to return home.

## Palladium Fantasy

The Palladium Fantasy main book (printed pp.108-111) has this class first, and
the numbers above are the later Rifts printing (Conversion Book One). They agree on
nearly everything mechanical: the same attribute requirements for one and two
elemental forces, the same 2D4x10+20 and 2D4x10+40 P.P.E. with +2D6 per level,
the same three spells per level of experience, and the same saving throw
bonuses. Where the older book differs:

- **Money is 150 gold**, not 2D6x1000 credits.
- **Experience** is the Psi-Mystic & Warlock table (printed 336): 2,101 for level 2, 350,401 for level 15. Recorded here rather than as `xp_table` because the class above is the Rifts printing.
- **Armour is soft leather** (A.R. 10, 20 S.D.C.), not a light M.D.C. suit.
- **Weapons** are a knife and one more of choice, basic S.D.C. and good
  quality. Favourites are iron or wood staves, morning stars, maces, swords
  and cross bows.
- **W.P.: two of choice**, both ancient. The Rifts entry splits them into one
  ancient and one modern.
- **No Pilot Hover Craft.** The Palladium O.C.C. skill list has no pilot skill
  at all.
- **Related skills** are the same count of eight, but from a shorter list: no
  Electrical, Mechanical, Pilot or Pilot Related. Communications any, Domestic
  +10%, Espionage limited to Disguise, Escape Artist and Intelligence (+5%),
  Horsemanship General or Exotic only, Medical any, Military none, Physical any
  except Acrobatics, Gymnastics, Boxing and Wrestling, Rogue any, Science +10%,
  Scholar/Technical +10%, W.P. any except the Lance and Long Bow, Wilderness
  any (+5%). One extra skill at levels three, six, nine and twelve.
- **Secondary skills** are three at level one, plus two at levels two, five,
  seven, ten and thirteen.
- **Standard equipment** is two sets of clothing, an appropriately coloured
  hooded robe, bedroll, backpack, 1D4 small sacks, one large sack, a water
  skin, flint and tinder box, 1D4 candles, a wooden cross, a small mirror, 1D4
  sticks of charcoal, and 1D4 items representing the warlock''s elemental
  symbol.
- **Spell strength** rises +1 at levels three, six, ten and fourteen, and the
  horror factor bonus is **+6 against elemental beings** specifically.
- **Speak Elemental** at 92%: every warlock speaks and understands the
  elementals'' language, a combination of telepathy and speech that is
  incomprehensible to anyone else. Elementals have no written language.
- The warlock also knows the four elemental power words - Cherubot-kyn (air),
  Ariel-Rapere-kyn (earth), Seraph-mytyn (fire), Tharsis-mycn (water) - and
  yin, the linking word, plus the mystic symbols of the four elements and the
  six stone symbols. See the Diabolist.
- **A warlock cannot learn spell magic of any other kind.** The power is given
  by a supernatural force rather than learned, and the elemental force, once
  chosen, cannot be changed.
', 'published', 'retro-audit-r3'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'warlock-air');

SELECT 'warlock-air is published' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'warlock-air' AND status = 'published' AND deleted_at IS NULL;

INSERT INTO data_script_runs (filename) VALUES ('add-warlock-air-class.sql');
