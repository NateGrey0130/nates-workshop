-- BOOK-INGEST-AUDIT F140 leftovers: the gypsies' scarf, the dolphin's P.E. term, the Anti-Monster's cyborg armour
-- 4 classes, each replaced whole: gypsy-seer, gypsy-gifted, pneuma-biform-dolphin, anti-monster.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~269-book-ingest-audit-f140-leftovers.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == gypsy-seer ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-seer
men_of_arms: false
occ_group: magic
name: Gypsy Seer
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.182-184
category: occ
tags: []
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_requirements: { ME: 14 }
ppe_base: "1d6x10 plus P.E. attribute number, +1d6 per additional level of experience"
starting_money: "2d6x1000"
psionics:
  type: "master"
  isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience"
  powers: ["Clairvoyance", "Object Read (Psychometry)", "Presence Sense", "Sixth Sense", "See Aura", "Mind Block Auto-Defense", "Hypnotic Suggestion"]
  powers_starting: 0
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 2, count: 1 }
    - { level: 4, count: 1 }
    - { level: 7, count: 1 }
    - { level: 10, count: 1 }
    - { level: 13, count: 1 }
magic:
  type: "spell"
  spells: ["Oracle", "Exorcism", "See the Invisible", "Death Trance"]
  spells_starting: 0
  spell_levels_allowed: [1, 2, 3, 4, 5, 6, 7, 8]
  spells_schedule:
    - { level: 2, count: 1, from: ["Tongues"], note: "Learned automatically at second level." }
    - { level: 2, count: 1, spell_levels: [1, 2] }
    - { level: 3, count: 1, from: ["Eyes of Thoth"], note: "Learned automatically at third level." }
    - { level: 3, count: 1, spell_levels: [1, 2] }
    - { level: 4, count: 1, from: ["Commune with Spirits"], note: "Learned automatically at fourth level." }
    - { level: 4, count: 1, spell_levels: [1, 2, 3] }
    - { level: 5, count: 1, from: ["Calling"], note: "Learned automatically at fifth level." }
    - { level: 5, count: 1, spell_levels: [1, 2, 3, 4] }
    - { level: 6, count: 2, from: ["Protection Circle: Simple", "Protection Circle: Superior"], note: "Both learned automatically at sixth level - the book prints them as one phrase, protection circle: simple and superior." }
    - { level: 6, count: 1, spell_levels: [1, 2, 3, 4, 5] }
    - { level: 7, count: 1, from: ["Dispel Magic Barriers"], note: "Learned automatically at seventh level." }
    - { level: 7, count: 1, spell_levels: [1, 2, 3, 4, 5, 6] }
    - { level: 8, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 9, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 10, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 11, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 12, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 13, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 14, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
    - { level: 15, count: 2, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8] }
bonuses:
  saves: { horror_factor: 4, spell_magic: 2, possession: 5, insanity: 5 }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Lore: Demons & Monsters", base: 20, per_level: 5, note: "Printed as a flat (20%) with no plus sign, unlike every other bonus in this list. Read off a 200 dpi render of printed 183; the catalog base is 25." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 15, per_level: 5, note: "Printed as a flat (15%) with no plus sign. Same reading as the Lore above; the catalog base is 25." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Play Musical Instrument", base: 10, per_level: 5, note: "One of choice, printed as a flat (10%) with no plus sign where Sing and Dance on the same list carry one. The catalog base is 35, so this is well below it - the book''s own number." }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { name: "Language: Euro", base: 80, per_level: 5, note: "+30%" }
    - { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: select three of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Streetwise", base: 36, per_level: 4, note: "+16%" }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
    - { name: "Concealment", base: 26, per_level: 4, note: "+6%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts (or Assassin if evil) for the cost of three." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "The book names horsemanship on its Pilot line; this catalog files it as its own category, so it is granted here at the Pilot line''s +10%." }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5 }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", only: ["Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Automobile", "Boat: Motor, Race & Hydrofoil", "Boat: Paddle Types/Canoe/Kayak", "Boat: Sail Type"], bonus: 10 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 4 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical and Military: none."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { choose: 1, label: "hooded cloak or robe", qty: 1, from: ["hooded-cloak", "hooded-robe"] }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor, Millennium Tree leaf armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "millennium-leaf-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
  - { choose: 1, label: "walking stick or staff", qty: 1, from: ["long-staff", "quarterstaff"] }
  - { choose: 1, label: "a knife or sling", qty: 1, from: ["knife", "sling"] }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "sketch-pad", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "pen", qty: "1d4" }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
natural_abilities:
  - name: "Sense Supernatural Evil"
    description: "The seer is keenly aware of the supernatural world and can sense the presence of supernatural evil forces. Range: 300 feet (91.5 m) plus 20 feet (6 m) per level of experience. The seer also senses the APPROACH of great evil - a supernatural or alien intelligence, a god, a demon lord, or an invading army of monsters or humans - as a feeling of dread and as a prophetic dream at least 72 hours before the danger arrives, and frequently weeks in advance."
  - name: "Read Palms"
    description: "A sort of acute clairvoyance and see aura rolled into one. By looking at a person''s palm the seer can estimate alignment (and separately whether the person is good, selfish or evil), tell whether the character is filled with hate or happiness, troubled or afraid, sick or addicted, hunted, in love, or possessed; recognise the sign of evil, meaning vampires, werebeasts and demon shape changers such as the succubus, incubus and dybuk who metamorphose into human form (NOT humans transformed by metamorphosis spell magic, changelings or dragons); estimate age to within 2D4 years, so a creature centuries old is recognised however human it looks; sense the presence of psionic powers; sense high P.P.E. of 20 or more points; and estimate general experience level as low (1-3), medium (4-7) or high (8 and up)."
  - name: "Glimpse the Future"
    description: "By using clairvoyance while holding the person''s palm, the seer may glimpse that person''s possible future. The impression is usually vague - I sense danger, or good fortune, or you will find what you are looking for, or you will be challenged, or you will have to make an important decision - and is usually based on events already in motion that are likely to transpire within the next eight weeks. Occasionally the seer actually sees an image of some future event involving the character, at the Game Master''s discretion."
  - name: "Powers Are a Gift, Not a Study"
    description: "The character is BORN with these powers, so the seer needs no formal education and does not study magic. The psionic powers start to manifest as young as age five; after puberty, around age 14, the gypsy seer suddenly knows some spell magic, including the oracle spell. The seer simply accepts his powers as a gift of nature, and the intuitive nature of those powers gives him a spiritual or metaphysical perspective of life: they trust feelings and dreams, see signs of good luck and bad omens, read palms, see the future and sense danger."
restrictions:
  - "Alignment: none. Can be any alignment."
  - "Only 10% of gypsy seers are literate in any language."
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels three, seven, ten and thirteen. Spell Strength is not a field the sheet holds."
  - "Cybernetics: starts with none and avoids them except for medical reasons. May consider bio-wizardry items."
extraction_notes: |
  - Triax and the NGR, printed 182-184. The third of the book''s four Gypsy
    O.C.C.s, and the book calls it a variation on the mystic - it carries both
    psionic and magic powers, as the Mystic does, and its automatic psionics
    and per-level spell ladder are modelled the same way the Mystic''s are.
  - THREE SKILLS ARE FIXED PERCENTAGES, NOT BONUSES. Printed 183 gives "Lore:
    Demons & Monsters (20%)", "Lore: Faeries (15%)" and "Play Musical
    Instrument: One of choice (10%)" with NO plus sign, where Dance, Sing,
    Streetwise, Palming and Concealment on the same list all carry one.
    Verified on a 200 dpi render of the page rather than off the OCR, because
    the OCR is the same engine that would have dropped the sign. All three land
    BELOW the catalog base, which is the tell that they are the book''s own
    numbers: the musical instrument is 10 against a catalog base of 35.
  - THE MASTER PSIONIC SAVE TARGET IS THE TIER, NOT A BONUS. The book says the
    seer "is considered to be a master psionic and saves on a roll of 10 or
    higher"; that is what `psionics.type: master` already means, so it is not
    also written into `bonuses`. The +5 to save vs possession and insanity IS a
    bonus and is stored.
  - THE SPELL LADDER IS TWO ENTRIES PER LEVEL. Printed 183 grants a NAMED spell
    and a free choice at each of levels two through seven - "at second level he
    learns tongues and one spell of choice from level one and two spells". A
    schedule entry carries its own restriction and several may share a level,
    so each level is a `from`-list of one (the named spell, which the picker
    presents as a forced pick) plus a second entry with its own `spell_levels`
    window. Sixth level names TWO spells in one phrase, "protection circle:
    simple and superior", and is stored as a two-count `from` over both rows.
  - "Dispel magic barrier" is stored as "Dispel Magic Barriers", the catalog''s
    name for that row.
  - The eighth-level rule - "at eighth level and each subsequent level of
    experience the character can select a total of two new spells from levels
    1-8" - is written out as one entry per level from 8 to 15, which is what
    `spells_schedule` holds and what the Mystic already does.
  - HORSEMANSHIP IS ON THE BOOK''S PILOT LINE AND IS ITS OWN CATEGORY HERE.
    Printed 184 allows "Pilot: Hover vehicles, automobiles, horsemanship, and
    boats (+10%)". This catalog files horsemanship as a category of its own, so
    it is granted as a Horsemanship line restricted to Horsemanship: General at
    the same +10%, rather than named inside the Pilot `only` where it would
    match nothing.
  - "Boats" is mapped to the three Boat rows that are boats - motor/race/
    hydrofoil, paddle/canoe/kayak and sail - and NOT to Boat: Ships, Boat:
    Submersibles or Military: Warships & Patrol Boats. A seer''s boat is not a
    ship, and this is the same catalog split the Gypsy Thief''s exclusion list
    resolves from the other side.
  - Money is 2D6x1000 credits. The entry also grants 3D4x1000 credits worth of
    gold, jewelry and artifacts, which `starting_money` cannot hold - it is
    coin only - so it is recorded in the body and here.
  - TWO CANTEENS ARE STORED AND ONE OF THEM IS THE HOLY WATER. The entry gives
    "a canteen filled with holy water, canteen for drinking water"; the catalog
    has a canteen and a vial of holy water, and a vial is not a canteen, so the
    count is stored and what fills it is prose.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna and the bright coloured scarf (no Rifts row for
    either: the catalog''s plain `scarf` is tagged Palladium Fantasy and its
    bandannas Heroes Unlimited and Nightbane, and by Nate''s ruling of
    2026-10-12 a row tagged for another game is not granted to a Rifts
    class; the two scarves stored until 2026-11-09 were removed,
    BOOK-INGEST-AUDIT.md F140), the energy rifle or pistol, an unresolved choice this
    book''s batches record as prose rather than stub, the squirt gun
    filled with water, the car as a vehicle option, and the 2D4 pieces of
    jewelry the seer wears.
    Millennium Tree leaf armour, printed 184''s second armour option, is stored
    as one more option of the light M.D.C. body armor choice, the Rifts row
    `millennium-leaf-body-armor` (Rifts Japan; BOOK-INGEST-AUDIT.md F140,
    2026-10-15).
    T-40 "plain clothes" armour is stored as seven more options of the light
    M.D.C. body armor choice, its `t-40-urban-*` rows (BOOK-INGEST-AUDIT.md
    F139).
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js): the entry
    prints no S.D.C. formula and this is a practitioner of magic.
---

# Gypsy Seer

## Lore

The gypsy seer may call himself a fortune-teller, but he or she is much more. They are a variation on the mystic, and exactly why this variant is common only among the gypsies of Europe and the oracles of China remains a mystery. Like the traditional mystic, the seer possesses both psionic and magic powers.

The character is born with these powers, so the seer needs no formal education and does not study magic. As young as age five the psionic powers start to manifest themselves; after puberty, around age 14, the gypsy seer will suddenly know some spell magic, including the oracle spell. The seer just accepts his powers as a gift of nature. The intuitive nature of those powers tends to give him or her a spiritual or metaphysical perspective of life: they trust feelings and dreams, see signs of good luck or bad omens, read palms, see the future and sense danger.

## Equipment and Money

Standard issue beyond the stored equipment: an energy rifle or pistol, an unresolved choice; a bright coloured bandanna and a bright coloured scarf (no Rifts row for either); a squirt gun filled with water; and, of the two canteens stored, one filled with holy water and one for drinking. A car is a third vehicle option, but only if the character can drive.

Notable additional equipment a seer may want to acquire: magic jewelry and crystals, staves and wands, magic potions, herbs, demon-slaying weapons and magic, and other exotic jewelry, weapons and objects. Sensory equipment, a hand-held computer, a language translator, cameras and recording equipment may also be of interest.

Of all the gypsies the seer dresses the most demure - but is still likely to wear 2D4 rings, bracelets, necklaces, pins, earrings and other jewelry.

Money: 2D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer'
   AND instr(markdown, '{ item_id: "scarf", qty: 2 }') > 0
   AND length(markdown) = 16903;

-- == gypsy-gifted ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-gifted
men_of_arms: false
occ_group: psychic
name: Gypsy - The Gifted
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.184-185
category: occ
tags: [healer, psionics]
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { ME: 14 }
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)" }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { name: "Language: Euro", base: 80, per_level: 5, note: "+30%" }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Languages: select two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
    - { name: "Streetwise: Drugs", base: 45, per_level: 5, note: "+20%; the entry grants Streetwise and Streetwise: Drugs together, both at +20%." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Cook", base: 55, per_level: 5, note: "+20%" }
    - { name: "Preserve Food", base: 45, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 20, per_level: 5, note: "Printed as a flat (20%) with no plus sign, where Biology, Pathology, Cook and Preserve Food on the same list all carry one. Read off a 200 dpi render of printed 185; the catalog base is 25." }
    - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
    - { name: "Pathology", base: 60, per_level: 5, note: "+20%" }
    - { name: "Medical Doctor", base: 75, per_level: 5, note: "+15%" }
    - { name: "Holistic Medicine", base: 50, per_level: 5, note: "+30%. With the Game Master''s approval this skill can include the skills and powers of the herbalist/herbology skill from Rifts World Book Three: England, including making curative teas and potions." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "Typically throwing knives and sling." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts (or Assassin if evil) for the cost of three." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "The book names horsemanship on its Pilot line; this catalog files it as its own category, so it is granted here at the Pilot line''s +10%." }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", only: ["Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Automobile", "Boat: Motor, Race & Hydrofoil", "Boat: Paddle Types/Canoe/Kayak", "Boat: Sail Type"], bonus: 10 }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Electrical, Mechanical and Military: none. Medical reads see O.C.C. skills - the entry grants five medical skills outright and offers no further medical picks. THE COUNT OF FOUR IS THE MAJOR PSIONIC''S, and the app applies that by itself: each master band carries related_skills_count: 0, so picking a master gift under Abilities drops this count to zero. The four scheduled picks at levels three, six, nine and twelve are NOT dropped - printed 185 puts that sentence after both branches rather than inside the major-psionic clause. BOOK-INGEST-AUDIT.md F24."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { choose: 1, label: "hooded cloak or robe", qty: 1, from: ["hooded-cloak", "hooded-robe"] }
  - { item_id: "surgical-gown", qty: 1 }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor, Millennium Tree leaf armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "millennium-leaf-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
  - { item_id: "sling", qty: 1 }
  - { item_id: "knife-throwing", qty: 2 }
  - { item_id: "knife-large", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "scalpel", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "pen", qty: "1d4" }
  - { item_id: "medical-kit", qty: 1 }
  - { item_id: "surgical-kit", qty: 1 }
  - { item_id: "laser-scalpel", qty: 1 }
  - { item_id: "irmss-internal-robot-medical-surgeon-system", qty: 1 }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1 }
  - { item_id: "stethoscope", qty: 1 }
  - { item_id: "compu-drug-dispenser", qty: 1 }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
special_abilities:
  - { choose: 1, from: ["The Gift (01-25): Major Psionic, two categories", "The Gift (26-50): Major Psionic, all healing", "The Gift (51-75): Master Psionic, mixed", "The Gift (76-00): Master Psionic, every healing power"] }
  - name: "The Gift (01-25): Major Psionic, two categories"
    description: "Roll 01-25. A MAJOR psychic with a total of SIX powers selected from any TWO psionic power categories, limited to Healing, Sensitive and Physical. THE CHOICE OF TWO IS NOT ENFORCED - the picker offers all three categories, so keep the picks inside two of them. I.S.P.: 1D4x10 plus M.E. number, +1D6+1 per level of experience. This gift leaves the character with the four O.C.C. Related Skills the class lists."
    psionics:
      type: "major"
      isp_base: "1d4x10 plus M.E. attribute number, +1d6+1 per additional level of experience"
      powers_starting: 6
      categories_allowed: ["Healing", "Sensitive", "Physical"]
    bonuses:
      saves: { disease: 2, toxins_poisons: 2, spell_magic: 1, curses: 1, horror_factor: 2, other: [{ label: "vs magic sickness", bonus: 1 }] }
  - name: "The Gift (26-50): Major Psionic, all healing"
    description: "Roll 26-50. A MAJOR psychic with EIGHT powers, all of them from the Healing category. I.S.P.: 1D4x10 plus M.E. number, +1D6+1 per level of experience. This gift leaves the character with the four O.C.C. Related Skills the class lists."
    psionics:
      type: "major"
      isp_base: "1d4x10 plus M.E. attribute number, +1d6+1 per additional level of experience"
      powers_starting: 8
      categories_allowed: ["Healing"]
    bonuses:
      saves: { disease: 3, toxins_poisons: 3, spell_magic: 1, curses: 2, horror_factor: 3, other: [{ label: "vs magic sickness", bonus: 2 }] }
  - name: "The Gift (51-75): Master Psionic, mixed"
    related_skills_count: 0
    description: "Roll 51-75. A MASTER psychic with Bio-Regeneration (Super) granted outright, plus five Healing powers, two Sensitive, two Physical and one further Super power of choice. At levels four, seven, ten and thirteen the character selects one additional Super psionic power OR two lesser psi-powers from any of the three categories; only the Super power is stored, so take two lesser powers by hand instead if that is the choice. I.S.P.: 2D6x10 plus M.E. number, +10 per level of experience. A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS, and picking this gift sets the count to zero by itself."
    psionics:
      type: "master"
      isp_base: "2d6x10 plus M.E. attribute number, +10 per additional level of experience"
      powers: ["Bio-Regeneration (Super)"]
      powers_starting: 10
      powers_starting_groups:
        - { count: 5, categories: ["Healing"] }
        - { count: 2, categories: ["Sensitive"] }
        - { count: 2, categories: ["Physical"] }
        - { count: 1, categories: ["Super"], note: "One Super psionic power of choice, beside the Bio-Regeneration (Super) granted outright." }
      powers_schedule:
        - { level: 4, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 7, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 10, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 13, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
    bonuses:
      saves: { disease: 2, toxins_poisons: 2, spell_magic: 1, curses: 1, horror_factor: 3, other: [{ label: "vs magic sickness", bonus: 1 }] }
  - name: "The Gift (76-00): Master Psionic, every healing power"
    related_skills_count: 0
    description: "Roll 76-00. A MASTER psychic with ALL of the healing powers and four Super psionic powers of choice. At levels two, four, six, nine and twelve the character selects one additional Super psionic power OR two lesser psi-powers from any of the three categories; only the Super power is stored, so take two lesser powers by hand instead if that is the choice. I.S.P.: 2D6x10 plus M.E. number, +10 per level of experience. A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS, and picking this gift sets the count to zero by itself."
    psionics:
      type: "master"
      isp_base: "2d6x10 plus M.E. attribute number, +10 per additional level of experience"
      powers: ["Attack Disease", "Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear", "Transfer I.S.P."]
      powers_starting: 4
      categories_allowed: ["Super"]
      powers_schedule:
        - { level: 2, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 4, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 6, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 9, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
        - { level: 12, count: 1, categories: ["Super"], note: "One Super power, OR two lesser psi-powers from Healing, Sensitive or Physical. Only the Super slot is stored." }
    bonuses:
      saves: { disease: 4, toxins_poisons: 4, spell_magic: 1, curses: 2, horror_factor: 4, other: [{ label: "vs magic sickness", bonus: 2 }] }
restrictions:
  - "Alignment: none. Can be any alignment."
  - "Less than 5% of The Gifted are literate in any language."
  - "The gift is rolled or selected: printed 184 says to randomly roll or select one of the four. Take it under Abilities; the app offers all four as a choice, with a Roll d100 button that picks by band."
  - "Cybernetics: starts with none and avoids them except for medical reasons. This character will NEVER consider bio-wizardry items - the one gypsy O.C.C. of the four that rules them out."
extraction_notes: |
  - Triax and the NGR, printed 184-185. The last of the book''s four Gypsy
    O.C.C.s. The book prints the name with an em-dash, "Gypsy - The Gifted
    O.C.C."; it is stored with a hyphen.
  - THE PSIONIC PROFILE COMES FROM A FOUR-BAND TABLE, AND THE FOUR BANDS
    ARE STORED AS FOUR CHOOSABLE ABILITIES RATHER THAN AS VARIANTS. Printed
    184-185 says to randomly roll or select one of 01-25, 26-50, 51-75 or
    76-00, and the bands differ in psionic
    TIER (two major, two master), in I.S.P. formula, in how many powers are
    picked and from which categories, in whether there is a per-level ladder,
    in the save bonuses, and in whether the character gets any O.C.C. Related
    Skills at all.
    `variants` was the obvious home and is the WRONG one: VARIANT_OVERRIDES in
    js/parser.js:57-65 lists `attribute_dice`, `attribute_requirements`, the
    four pool bases, `starting_money`, `bonuses` and `skill_overrides`, so a
    variant could have carried the saves and NOTHING about the psionics. An
    ability can carry `bonuses`, `psionics` and `magic` together
    (ABILITY_GRANTS, js/parser.js:1443), `applyAbilities` folds the chosen
    ability''s psionics through `mergePsionics`, and `mergePsionics` returns the
    ability''s block unchanged when the class states none (js/parser.js:368). So
    the class carries NO class-level psionics block and each band carries a
    complete one. Picking a band gives exactly that band and nothing else.
  - WHAT THAT MODELS, and it is most of the table: the tier, the I.S.P.
    formula, the starting count, the categories each band may pick from, the
    51-75 band''s five/two/two/one split as `powers_starting_groups` with
    Bio-Regeneration (Super) granted outright, and both master bands'' per-level
    Super ladders.
  - THE RELATED-SKILL COUNT IS CARRIED BY THE ABILITY. It is four for a major
    psionic and ZERO for a master. On the day of the import neither an ability
    nor a variant could carry it, so the picker offered four related skills to
    the half of the table the book gives none; BOOK-INGEST-AUDIT.md F24 was
    filed for that, and has been taken. An ability may now set
    related_skills_count, and each of the two master bands sets it to zero.
    The four scheduled picks at levels three, six, nine and twelve are NOT
    dropped: printed 185 puts that sentence after both branches rather than
    inside the major-psionic clause.
  - WHAT IS STILL NOT MODELLED, and stays filed under BOOK-INGEST-AUDIT.md F24:
    (b) the "one Super power OR two lesser psi-powers" either/or in both master
    bands'' level ladders - each entry stores the Super slot and says so;
    (c) the 01-25 band''s "any TWO categories, limited to healing, sensitive and
    physical" - `categories_allowed` names all three and the choice of two is
    in the ability''s own description.
  - THE 76-00 BAND''S "ALL HEALING POWERS" IS ENUMERATED, AND THE LIST WILL ROT.
    All seventeen Healing rows in the catalog on 2026-09-06 are granted by name
    rather than as a count, because a count would let the player pick seventeen
    of a larger set instead of taking every one. A Healing power imported later
    is NOT granted to this class until it is added to that list, which
    under-grants silently. Naming them is still the better of the two: the
    alternative over-grants a choice the book does not offer.
  - The book lets the player roll the gift or select it, and the app offers
    both: the four bands are a choice, and their names carry the percentile
    ranges, so the wizard draws a Roll d100 button that picks by band. Recorded
    in `restrictions` so the player sees it at the pick rather than only here.
  - IDENTIFY PLANTS & FRUITS IS A FIXED PERCENTAGE, NOT A BONUS, and the
    catalog spells it singular. Printed 185 gives "Identify Plants & Fruits
    (20%)" with no plus sign where Biology, Pathology, Cook and Preserve Food
    on the same list all carry one; verified on a 200 dpi render rather than
    off the OCR. Stored against the catalog row "Identify Plants & Fruit",
    which is the singular spelling that caught the NGR Medical Officer in batch
    one of this book.
  - "Medical: See O.C.C. skills" is not a category grant and is not listed. The
    entry hands over five medical skills outright - biology, pathology, medical
    doctor, holistic medicine and, at a stretch, preserve food - and offers no
    further medical picks, so a Medical line here would grant more than the
    book does.
  - HORSEMANSHIP IS ON THE BOOK''S PILOT LINE AND IS ITS OWN CATEGORY HERE, and
    "boats" is mapped to the three Boat rows that are boats rather than to
    ships, submersibles or warships. Both readings are the Gypsy Seer''s, one
    page earlier, and are recorded there in full.
  - "Magic sickness" is not one of the sixteen saves the sheet draws, so each
    band''s +1 or +2 against it rides in `saves.other` - the F7 shape. Curses IS
    one of the sixteen and takes the same number, because the book prints the
    two together as one bonus.
  - Money is 1D6x1000 credits. The entry also grants 3D4x1000 credits worth of
    gold, jewelry and artifacts, which `starting_money` cannot hold - it is
    coin only - so it is recorded in the body and here.
  - THE ENTRY PRINTS NO NUMBER FOR THE POUCHES. It says "small pouches or
    sacks" where the other three Gypsy O.C.C.s all say 1D4; one is stored
    rather than a number the book does not give.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna and the bright coloured scarf (no Rifts row for
    either: the catalog''s plain `scarf` is tagged Palladium Fantasy and its
    bandannas Heroes Unlimited and Nightbane, and by Nate''s ruling of
    2026-10-12 a row tagged for another game is not granted to a Rifts
    class; the two scarves stored until 2026-11-09 were removed,
    BOOK-INGEST-AUDIT.md F140), the weapon of choice, an unresolved choice this book''s
    batches record as prose rather than stub, the car as a vehicle
    option, and the contents of the two kits -
    soap, towels, bandages, suture tape and gun, antiseptics, protein healing
    salve, aspirin, painkillers, antibiotics, sedatives, anesthetics, a
    hypodermic gun, a pen flashlight, a bag of holistic herbs and teas,
    needles, clamps, sutures, a hand-held computerised blood pressure machine,
    3D4 thermometers, six specimen containers and a hundred pairs of
    disposable surgical gloves. The kits themselves are stored; their listed
    contents are prose, which is how the NGR Medical Officer''s kits went in.
    Millennium Tree leaf armour, printed 185''s second armour option, is stored
    as one more option of the light M.D.C. body armor choice, the Rifts row
    `millennium-leaf-body-armor` (Rifts Japan; BOOK-INGEST-AUDIT.md F140,
    2026-10-15).
    T-40 "plain clothes" armour is stored as seven more options of the light
    M.D.C. body armor choice, its `t-40-urban-*` rows (BOOK-INGEST-AUDIT.md
    F139).
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js): the entry
    prints no S.D.C. formula, and a psionic healer is not a man of arms.
---

# Gypsy - The Gifted

## Lore

"The Gifted", or "The Gifted Ones", are gypsy healers. The character has both psionic healing abilities and knowledge in the ways of medicine and herbology. They are among the most revered of the gypsies and often hold a high place among the clans. The Gifted tend to be the least violent of the gypsies and have few thief or rogue skills.

The gift itself is rolled or selected from a four-band table: half of the table is major psychics and half is masters, and what the character can do - how many powers, from which categories, how much I.S.P., and whether there is any spare training for other skills at all - follows from that gift. Roll percentile or pick one at creation, under Abilities.

## Equipment and Money

Standard issue beyond the stored equipment: a weapon of choice; a bright coloured bandanna and a bright coloured scarf (no Rifts row for either); and a car as a third vehicle option, but only if the character can drive.

The medical kit holds soap, disposable towels, bandages, suture tape, antiseptics, protein healing salve, aspirin, painkillers, antibiotics, sedatives, anesthetics, a hypodermic gun, a stethoscope, a pen flashlight and a portable compu-drug dispenser, along with a second bag of holistic herbs, teas, salves and potions. The surgical kit holds a variety of scalpels, one laser scalpel, needles, clamps, sutures, suture tape, a suture gun, several IRMSS units, an RMK, a hand-held computerised blood pressure machine, 3D4 thermometers, six unbreakable specimen containers, a hundred pairs of disposable surgical gloves and two reusable pairs.

Money: 1D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '{ item_id: "scarf", qty: 2 }') > 0
   AND length(markdown) = 21200;

-- == pneuma-biform-dolphin ==
UPDATE imported_classes
   SET markdown = '---
id: pneuma-biform-dolphin
name: Pneuma-Biform Dolphin
system: rifts
source_book: Rifts World Book 7: Underseas p.51-53
category: rcc
psionics_allowed: false
tags: [supernatural, shapeshifter, aquatic]
xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]
attribute_dice:
  IQ: "3d6+3"
  ME: "3d6+10"
  MA: "3d6+6"
  PS: "4d6+6"
  PP: "3d6+6"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "3d6+6"
mdc_base: "P.E. + 2d6x10, +2d6 per level"
ppe_base: "P.E. + 3d6x10, +3d6 per level"
ignores_style_attacks: true
bonuses:
  combat: { attacks_base: 3, initiative: 2, dodge: 1 }
  saves: { horror_factor: 6, disease: 4, illusionary_magic: 4, mind_control: 4 }
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
    ocean:
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
    - { count: 1, from_list: "ocean" }
    - { count: 10, from_list: "dolphin", note: "The PB-dolphin has ALL dolphin magic, not a choice from it - printed 52 item 3. Listed as a group of ten so the ten rows land on the sheet." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "ocean" }
    - { level: 3, count: 1, from_list: "ocean" }
    - { level: 4, count: 1, from_list: "ocean" }
    - { level: 5, count: 1, from_list: "ocean" }
    - { level: 6, count: 1, from_list: "ocean" }
    - { level: 7, count: 1, from_list: "ocean" }
    - { level: 8, count: 1, from_list: "ocean" }
    - { level: 9, count: 1, from_list: "ocean" }
    - { level: 10, count: 1, from_list: "ocean" }
    - { level: 11, count: 1, from_list: "ocean" }
    - { level: 12, count: 1, from_list: "ocean" }
    - { level: 13, count: 1, from_list: "ocean" }
    - { level: 14, count: 1, from_list: "ocean" }
    - { level: 15, count: 1, from_list: "ocean" }
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
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Language: Dolphin/Whale", base: 98, per_level: 0, note: "Printed as Dolphin/Whale Language 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "One human language at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two other languages (+15%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Printed as Demon and Monster Lore (+15%)." }
    - { name: "Track & Hunt Sea Animals", base: 45, per_level: 5, note: "+10%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Sing", base: 50, per_level: 5, note: "+15%" }
    - { name: "Acrobatics", base: 30, per_level: 5 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One W.P. of choice, applicable when human." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Applicable when human. Can be raised to expert for one other skill selection, or to martial arts for two." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", except: ["Forgery", "Sniper"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5 }
      - "Physical"
      - "Pilot Related"
      - "Rogue"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical, Military, Pilot and Science are barred entirely. All new skills start at level one proficiency."
  secondary_skills:
    count: 5
    note: "Chosen from the same categories as the related skills, excluding those the book marks None, and without the bonuses in parentheses."
restrictions:
  - "Alignment: 70% are scrupulous or unprincipled; the rest tend to principled, anarchist or aberrant. Diabolic or miscreant PB-dolphins are almost unknown."
  - "Size: 6 to 7.5 feet (1.8 to 2.25 m) in combat form. In swimming form it is about 20% larger than an average dolphin."
  - "Average life span: at least 400 years. No pneuma-biform has yet died of old age."
  - "STRENGTH AND ENDURANCE ARE SUPERNATURAL, so punches do mega-damage in either form."
  - "Horror Factor: 10, and ONLY in combat form."
  - "Speed is the HUMAN form speed of 3D6+6. Underwater it is 1D4x10+60 in dolphin form and 1D4x10+20 in dolphin combat form."
  - "Spell strength - the number others must save against - is +1 at levels three, seven and eleven."
  - "DO NOT ADD THE HAND TO HAND SKILL''S ATTACKS PER MELEE. The stored 3 is the dolphin form''s; human form gets 4, and attacking by magic or psionics either form gets 2 a melee round (printed 52). Hand to hand supplies bonuses and techniques only."
  - "Psionics are the normal dolphin''s, which printed 80 gives as a percentile roll rather than a grant: 77% have none, 11% are minor, 9% major and 3% master. The roll is the pick-one Psionics group under special abilities, the normal dolphin''s own."
  - "Cybernetics: never."
  - "In its cetacean form the character dehydrates quickly out of water. Every hour on dry land without soaking, it loses 4D6 M.D.C. and cannot heal or regenerate until it has soaked for six hours; after five hours without water it becomes weak, halving attacks per melee round and all combat bonuses. In human form it is uncomfortable away from water, because it needs to immerse itself to change back."
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
  - name: "Metamorphosis: Human"
    description: "The normal form is a dolphin; it can become an attractive light-skinned human of its own gender twice per 24 hours, for one hour per level of experience. The appearance is always the same - it cannot assume another guise, age or gender. As a human it gains articulated hands, survives on land without dehydrating, walks, runs, climbs and speaks in a deep clear voice - and LOSES the dolphin''s physical and natural abilities, including its sonic abilities, electromagnetic sensitivity, dolphin magic and ley line abilities. Swimming speed equals running speed, breath holds only 1D4+2 minutes, and depth tolerance drops to 300 feet. Spellsongs are retained at half range; ocean magic works normally."
  - name: "Metamorphosis: Combat Form"
    description: "Size increases by one foot and the skin turns hard, grey and metallic like polished chrome. +10 M.D.C. per level of experience, +6 M.D. on every physical attack, +1 attack per melee round, +1 on initiative, +1 to strike, +1 to roll with impact, +2 to pull punch, and a horror factor of 10. Usable from dolphin or human form, for 30 minutes per level, three times per 24 hours. These bonuses are conditional and are NOT in the stored block."
  - name: "Mystic Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per minute."
  - name: "Deep Endurance"
    description: "Maximum depth endurance is four miles (6.4 km), against one mile for a normal dolphin."
  - name: "Human Intelligence"
    description: "Human intelligence, resourcefulness and communication. The voice is high-pitched and guttural as a dolphin, deep and clear in human form."
  - name: "Impervious to Cold"
    description: "Takes no damage from cold."
  - name: "Permanent Fusion"
    description: "The character stays a pneuma-biform even if the Lord of the Deep is slain, and 88% want to. A character who chooses to become a normal human or dolphin again can never have the fusion restored."
extraction_notes: |
  - Underseas, printed 51-53. The first of the three Pneuma-Biform R.C.C.s -
    humans and cetaceans magically fused by the Lord of the Deep, who then
    rebelled against it. All three share a stat-block shape and differ in
    numbers; each is imported separately because the book prints three
    entries.
  - ALL TEN DOLPHIN SPELLS ARE GRANTED, NOT CHOSEN. Printed 52 item 3 says
    the character possesses dolphin magic outright. It is written as a
    starting group of ten drawn from a ten-name list, which is a grant
    expressed through the picker, because `spells` grants by name and a
    starting group is what puts them on the sheet as picks the player sees.
  - THE MAGIC LADDER IS TWO LADDERS AT ONCE and the schedule carries both.
    Printed 52 gives one ocean spell per level of experience and one whale
    spellsong per level STARTING AT THIRD. Entries are matched by level and
    slot, so levels three and up carry one of each. The level-1 ocean pick is
    a `spells_starting_groups` entry rather than a schedule entry, because a
    level-1 schedule entry does not fire at creation.
  - ATTACKS ARE THE DOLPHIN FORM''S. The book gives four in human form and
    three in dolphin form, and the dolphin is the normal form, so 3 is
    stored. Both figures and the two magic/psionic attacks are in the
    restrictions.
  - NO CLASS-LEVEL PSIONICS BLOCK. The entry says psionic powers are the
    normal dolphin''s, and printed 80 makes those a percentile roll where 77%
    have none. Since ~114 the roll is a pick-one group of four banded
    options, copied from the dolphin class as ~090 gave it; each psychic
    option carries its own block, and the None option carries nothing.
    Whether the table replaces the standard roll is settled in the
    2026-10-05 note below.
  - SPEED IS THE HUMAN FORM''S, which is the only one `Spd` can hold. The two
    swimming speeds are in the restrictions.
  - THE COMBAT-FORM BONUSES ARE NOT STORED. They are conditional on a
    transformation with a duration and a daily limit, and `bonuses` applies
    unconditionally. The combat form stays prose and is not a `second_form`
    (decided 2026-11-09, BOOK-INGEST-AUDIT.md F140).
  - M.D.C. AND P.P.E. ARE P.E. PLUS THE DICE. Printed 52 gives "P.E. plus
    2D6x10" M.D.C. and "P.E. plus 3D6x10" P.P.E., adding 2D6 and 3D6 per
    level of experience. Until 2026-11-09 the bases held the dice alone and
    the per-level gains sat in the restrictions; both bases now carry the
    P.E. term and the gain, in the shape `horune-pirate` writes its M.D.C.
    (BOOK-INGEST-AUDIT.md F140).
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 52 gives psionic powers as the same as the normal dolphin, whose own table (printed 80, with its no-psionic-powers result at 01-77) is the whole rule.
---

# Pneuma-Biform Dolphin

## Lore

Pneuma-biforms are creatures of magic - humans and cetaceans fused by the Lord of the Deep, who then rebelled against their maker and joined the Whale Singers. The dolphin biforms carry attributes and abilities of both halves, plus a good deal that belongs to neither.

They are the quickest and most playful of the three, and the most inclined to walk among humans. Their normal shape is a dolphin about a fifth larger than the ordinary kind; twice a day they can take the shape of an attractive, light-skinned human, always the same one.

Most of them - 88% - like being what they are, and will stay pneuma-biforms whether or not the Lord of the Deep is ever destroyed.

## GM Notes

Besides the Whale Singers, PB-dolphins often team up with normal dolphins and whales, humans, sea titans, amphibs, sea inquisitors and anyone of good alignment or good intentions.

They rely on their natural powers, especially in dolphin form, and may carry one or two weapons and a few personal items for use when they take human shape. A few own magical, techno-wizard or rune weapons. Body armour is usually none, though some wear magically woven kelp armour of 90 M.D.C. made with the Song of Weaving.

Most keep a small cache for walking among men - a weapon or four, a water scooter or surfboard, a set of clothes, some precious metals and gems, and assorted trinkets.
',
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, 'mdc_base: "2d6x10"') > 0
   AND length(markdown) = 17058;

-- == anti-monster ==
UPDATE imported_classes
   SET markdown = '---
id: anti-monster
occ_group: men-of-arms
name: Anti-Monster
system: rifts
source_book: Rifts World Book 6: South America p.34-37
category: occ
tags: [combat, hunter, augmented]
xp_table: [0, 2601, 5001, 9001, 18001, 25001, 35001, 60001, 85001, 100001, 150001, 200001, 270001, 370001, 470001]
attribute_dice:
  MA: "1d6+19"
  PS: "2d6+28"
  PP: "1d6+19"
  PE: "2d6+18"
  PB: "2d4"
  Spd: "3d4x10"
mdc_base: "1d6x10+400"
ppe_base: "1d4"
horror_factor: "2D4+6"
starting_money: "1d6x1000"
bonuses:
  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 4, roll: 2 }
  saves: { spell_magic: 3, psionics: 3, horror_factor: 5 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: [{ name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }], bonus: 10, note: "Piloting: any one, except robots and power armor (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: two of choice (+20%). Taken once per language." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints Demon and Monster Lore." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts, or Assassin if an evil alignment, for the cost of one other skill." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"], bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Military: none. Medical: First Aid and Paramedic only, and Paramedic counts as two skills. Physical: any except Acrobatics. Pilot: any except robot and power armor."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "suit of medium or heavy M.D.C. armor", qty: 1, from: ["personalized-light-or-medium-mdc-body-armor", "gladiator-body-armor", "crusader-body-armor", "ca-1-heavy-dead-boy-armor", "cyborg-body-armor-light-undercover", "cyborg-body-armor-light-infiltration", "cyborg-body-armor-light-infantry", "cyborg-body-armor-heavy-infantry", "cyborg-battle-armor-light", "cyborg-battle-armor-medium", "cyborg-battle-armor-heavy", "ca-6c-cyborg-armor", "ca-6ex-exoskeleton-armor"], note: "Printed 37 says medium or heavy M.D.C. armor, or any suit of cyborg armor, including Heavy Infantry Armor (420 M.D.C.). The first four are the catalog''s medium and heavy armour set; every Rifts cyborg armour row follows. The catalog''s Heavy Infantry row is Japan''s at 240 M.D.C.; no row holds the 420 M.D.C. suit the page names." }
  - { choose: 2, label: "energy weapons of choice", qty: 1, from: ["rc-10-laser-pistol", "rc-15-laser-rifle", "dragon-1-plasma-projector", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"], note: "The book says two energy weapons of choice without enumerating; the Colombian RC-10, RC-15 and Dragon-1 from this book lead the catalog set." }
  - { choose: 3, label: "hand to hand or archaic weapons of choice", qty: 1, from: ["broadsword", "axe-battle", "axe-throwing", "bo-staff", "club-stick-pipe", "arab-mace", "cross-bow", "beaked-axe", "vibro-knife"], note: "The book says three other hand to hand or archaic weapons of choice without enumerating; this is the catalog set." }
psionics:
  type: "major"
magic:
  type: "spell"
  spells: ["Blinding Flash", "Globe of Daylight", "Chameleon", "Armor of Ithan", "Magic Net", "Shadow Meld"]
trackable_resources:
  - { key: blinding-flash, label: "Blinding Flash", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: globe-of-daylight, label: "Globe of Daylight", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: chameleon, label: "Chameleon", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: armor-of-ithan, label: "Armor of Ithan", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: magic-net, label: "Magic Net", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: shadow-meld, label: "Shadow Meld", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
special_abilities:
  - name: "M.D.C. Transformation"
    description: "A magical flesh-and-metal creature of 1D6x10+400 M.D.C. Regenerates 4D6 M.D.C. per minute (1D6 per melee). The metal parts are alive and heal on their own."
  - name: "Burned-Out P.P.E. and I.S.P."
    description: "The inner energies are spent in the transformation: P.P.E. and I.S.P. drop to 1D4 each, and neither can be tapped in any way - not by the Anti-Monster, by magic practitioners, or by Mind Bleeders."
  - name: "Supernatural Attributes"
    description: "M.A. 19+1D6, P.S. 28+2D6 (supernatural), P.P. 19+1D6, P.E. 18+2D6, P.B. 2D4 and Spd 3D4x10. The other attributes are rolled normally for the race of origin. Hand to hand Mega-Damage follows the supernatural P.S. table (Rifts Conversion Book One p.22). Against vampires the blows inflict Hit Point damage: 1D4 restrained, 2D6 full strength, 4D6 power punch (counts as two attacks), plus the P.S. damage bonus."
  - name: "Supernatural Powers"
    description: "Unaffected by normal (non-M.D.C.) heat, cold and weapons. Does not eat or breathe, and can survive indefinitely in space, underwater or buried alive. Mega-Damage heat, fire, plasma and cold do half damage; lasers, particle beams, ion blasts, electricity, M.D. explosions, psionics and magic do full damage. Impervious to poisons, drugs and magic potions. Immune to the vampire''s mind control bite (but not its killing bite) and cannot be turned into a vampire."
  - name: "Built-in Spells"
    description: "Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net and Shadow Meld, each castable up to three times per 24 hours at the strength of a 5th level wizard. No further spells are ever gained and these never increase in level. Can use rune weapons, scrolls, and techno-wizard or enchanted items, but not magic potions or ointments."
  - name: "Sense Psychic and Magic Energy"
    description: "Works like the Psi-Stalker''s ability but less developed: constantly and automatically senses psionic energy and P.P.E. directed at spells, circles, wards, techno-wizardry and magic devices. Range 50 feet (15.2 m)."
  - name: "Sense Supernatural Beings"
    description: "Senses the distinctive psychic scent of the supernatural at 60% +2% per level. Identifying the specific type of creature - demons, vampires and dragons included - is 58% +2% per level."
  - name: "No Psionic Powers"
    description: "All psychic potential is burned out, but the character saves vs psionics as a major psionic (12 or higher)."
  - name: "Initiative Against Undead"
    description: "+4 to initiative against ghouls, vampires and all forms of undead, in place of the usual +2."
  - name: "Cybernetics"
    description: "Mystical bionic lungs, retractable claws or retractable forearm vibro-blades, and 1D4+1 cybernetic implants of the player''s choice, all built in during the transformation. None can be added afterwards. Each implant adds 3% to the chance of rejection."
  - { choose: 1, from: ["Obsession (01-20): Destroying the Undead", "Obsession (21-40): Destroying Evil Supernatural Beings", "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods", "Obsession (61-80): Random Obsession", "Obsession (81-00): One of the Above and a Random Obsession", "Obsession: None"], note: "Insanities (printed 36): the page says 80% of all Anti-Monsters develop an Obsession, and to roll or pick one. It prints no roll for the 80% itself; an Anti-Monster the G.M. rules is among the rest takes Obsession: None, which the Roll button never lands on." }
  - name: "Obsession: None"
    description: "For an Anti-Monster outside the 80% the page says develop an Obsession. Nothing is rolled."
  - name: "Obsession (01-20): Destroying the Undead"
    description: "Roll 01-20 or pick. Obsessed with destroying vampires, ghouls, necromancers and every form of undead."
  - name: "Obsession (21-40): Destroying Evil Supernatural Beings"
    description: "Roll 21-40 or pick. Obsessed with destroying all evil supernatural beings. Dislikes and distrusts any supernatural being, even one of good alignment, and has little liking for creatures of magic or for men of magic who summon or control the supernatural."
  - name: "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods"
    description: "Roll 41-60 or pick. Obsessed with protecting humans and innocent D-bees against evil and manipulative gods and their minions - priests, acolytes, shamans, warlocks and witches included."
  - name: "Obsession (61-80): Random Obsession"
    description: "Roll 61-80. The book sends the player to the random obsession table in the Rifts RPG, page 20; roll there by hand and record the result. That table is not stored here."
  - name: "Obsession (81-00): One of the Above and a Random Obsession"
    description: "Roll 81-00. Pick one of the obsessions above (the book''s wording; record which in the character''s notes) AND roll one additional random obsession on the Rifts RPG table, page 20, by hand."
restrictions:
  - "Can never gain further spells, and the built-in spells never increase in level."
  - "Cannot use magic potions or ointments."
  - "Cannot receive cybernetics or bionics after the transformation."
side_effects: "Inhuman appearance: a towering metallic brute, 7 feet (2.1 m) tall and 400 lbs (180 kg), Horror Factor 2D4+6. Takes DOUBLE damage from rune weapons, Wormwood crystal magic, and Millennium Tree wands, staves and weapons, good or evil. -20% to all Prowl rolls. REJECTION: after 1D4 years there is a 5% chance (+3% per cybernetic implant) that the body rejects the magical grafts, calling for an immediate save vs Coma/Death at -15%. Even on a success the character is crippled for 1D6 months (-7 to strike, parry and dodge, attacks and speed halved), then recovers to -2 on all combat bonuses with speed and attacks reduced by 25%. The rejection chance recurs 1D6 years later and again 2D4 years after the second crisis; after the third the character is safe and returns to full strength. Few survive more than 15 years of active duty. LOSS OF HUMANITY: forgets human needs such as rest, sleep and food; about 50% grow impatient with human frailty and 90% seem cold, brutal and merciless, especially against monsters. INSANITY: 80% develop an Obsession, rolled or picked once from the Obsession group in the special abilities - 01-20 destroying vampires, ghouls, necromancers and all undead; 21-40 destroying all evil supernatural beings, distrusting even good ones; 41-60 protecting humans and innocent D-bees from evil gods and their minions (priests, acolytes, shamans, warlocks and witches); 61-80 roll on the random obsession table in the Rifts RPG p.20; 81-00 pick one of the above and roll one additional random obsession."
extraction_notes: "WB6 printed 34-37 (cache p035-p038). || XP: the Anti-Monster and Amazon ladder, printed 168, lower bounds 0 / 2,601 / 5,001 / 9,001 / 18,001 / 25,001 / 35,001 / 60,001 / 85,001 / 100,001 / 150,001 / 200,001 / 270,001 / 370,001 / 470,001, stored as printed. || GROUP: the book files no O.C.C. under a group heading - it sits in the Republic of Colombia chapter after the vehicles. Stored as men-of-arms: a combat cyborg built to hunt monsters, whose built-in spells are fixed and never grow; it is not a spell caster by training. mdc_base is stated, so no men_of_arms line. || NOT supersedes_race. The book says the other attributes are rolled normally for the race of origin, so the character keeps its race; the six supernatural attributes, the M.D.C. body and the burned-out P.P.E./I.S.P. are stored as attribute_dice, mdc_base and ppe_base, which a race stating its own will override in a pairing. For a human (no R.C.C.) they apply as printed. This is a judgement call and the one to revisit if a D-bee Anti-Monster comes out with the wrong body. || P.S. is supernatural; attribute_dice holds 2d6+28 and the supernatural damage table is prose. P.B. 2D4 is stored as printed (the book lowers it). || SPELL USES: the introduction says the spells can be used up to four times per 24 hours; the O.C.C. ability 5 says up to three times each. The ability entry is the rule and is what trackable_resources stores (max 3, reset daily, one per spell); the four is recorded here. All six are existing general invocations (Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net, Shadow Meld); granted by name, no spells_starting. Casting level fixed at 5th is prose. || PSIONICS: no powers; stored as type major with no picks, because the book makes the character a major psionic for save purposes (12 or higher). Printed 36 drops P.P.E. and I.S.P. to 1D4 each and says neither can be tapped; ppe_base carries the 1D4 and isp_base is left unstated, so the I.S.P. figure is recorded here only (regression also refuses a class whose two pool formulas are the same string, the shape of a copying error). || BONUSES: +2 initiative, +1 strike/parry/dodge, +4 pull punch, +2 roll, +3 save vs magic, +3 vs psionics, +5 vs horror factor stored unconditionally. The +4 initiative vs undead is conditional and is prose. Imperviousness to poison, drugs and potions is total immunity, left in prose rather than a save bonus. || horror_factor stored as the printed phrase 2D4+6. || SKILLS: Radio: Basic 45+10; Wilderness Survival 30+10; Demon and Monster Lore is the catalog Lore: Demons & Monsters 25+15; Language two of choice +20 as two Language: Other picks. The book prints no Native Tongue line and none was added. Hand to Hand: Expert changes to Martial Arts or Assassin (evil) for one other skill each. Paramedic counting as two skills is a note, not enforced. Military: none, so the category is omitted. Secondary skills carry the same limits without the bonuses, as the book directs. || EQUIPMENT: armor, two energy weapons and three hand to hand or archaic weapons are all of choice; each is a choice from a catalog set. The book''s Heavy Infantry Armor (420 M.D.C.) cyborg armor has no catalog row and is not stubbed; the catalog''s nine Rifts cyborg armour rows joined the armour choice on 2026-11-09 (BOOK-INGEST-AUDIT.md F140). Cybernetics (bionic lungs, claws or forearm vibro-blades, 1D4+1 implants) are prose. || Rejection, loss of humanity and the vulnerabilities are side_effects. || OBSESSION TABLE (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 36, item 4 Insanities, prints a percentile table of its own - 80% of all Anti-Monsters develop an Obsession, roll or pick one - in five bands, 01-20, 21-40, 41-60, 61-80 and 81-00, which cover 01-00 with no gap or overlap. It is rolled once, at creation, and the page gives no later roll, so it is stored as one pick-one group of five band-named options (Obsession (NN-NN): ...), one definition each. No row prints a number, so no option carries bonuses. The 80% gate is in the group note: the one-in-five character with no obsession takes the group''s unbanded Obsession: None option, which the roll never lands on. 61-80 sends the player to the random table on Rifts RPG p.20 and 81-00 asks for one of the rows above plus one random obsession; both stay as the row prose and are rolled by hand. side_effects keeps its summary of the five bands and now points at the group."
---

## Lore

The Anti-Monster is a mystic cyborg, the product of an advanced and secret
trans-dimensional techno-wizardry found on Earth only in the Republic of
Colombia. Captured Anti-Monsters have been studied by others, Atlantis
included, and nobody has managed to reproduce the process; some suspect a god
or supernatural intelligence is behind it, others a link to the Holy Terrors of
Wormwood or to Doctor Articulus''s home dimension.

A candidate must have some magic or psionic ability. Most of the bone and
organs are replaced with techno-wizard bionics during a long ritual that
consumes nearly all of the candidate''s P.P.E. and I.S.P. to bind flesh and
machine; afterwards the metal parts are alive and heal themselves. The result
is a supernatural warrior able to devastate vampires, demons and creatures of
magic, with a handful of spells built into the body.

Vampires and monsters see Anti-Monsters as their deadliest enemies, while many
humans and D-bees fear the cold, inhuman giants. They are tragic heroes who
defend a world that does not fully accept them, and an evil Anti-Monster
serving the supernatural is extremely rare.

## GM Notes

Alignment: any, but usually scrupulous, selfish or aberrant. There are no
attribute requirements beyond a willingness to become inhuman and some prior
magic or minor psionic ability. Few survive more than fifteen years of active
duty, and the rejection crises (see side effects) are the GM''s to roll.
',
       updated_at = datetime('now')
 WHERE class_id = 'anti-monster'
   AND instr(markdown, 'which has no catalog row; this is the catalog set.') > 0
   AND length(markdown) = 19329;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 4 classes carry their new text' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-seer' AND instr(markdown, 'the two scarves stored until 2026-11-09 were removed') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, 'the two scarves stored until 2026-11-09 were removed') > 0)
    OR (class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'ppe_base: "P.E. + 3d6x10, +3d6 per level"') > 0)
    OR (class_id = 'anti-monster' AND instr(markdown, '"ca-6ex-exoskeleton-armor"], note: "Printed 37 says') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-seer' AND instr(markdown, '{ item_id: "scarf", qty: 2 }') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, '{ item_id: "scarf", qty: 2 }') > 0)
    OR (class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'mdc_base: "2d6x10"') > 0)
    OR (class_id = 'anti-monster' AND instr(markdown, 'which has no catalog row; this is the catalog set.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gypsy-seer', 'gypsy-gifted', 'pneuma-biform-dolphin', 'anti-monster') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~269-book-ingest-audit-f140-leftovers.sql');
