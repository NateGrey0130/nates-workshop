-- BOOK-INGEST-AUDIT F140: settle the unsettled sentences on two Triax gypsies and the Canada Trapper-Woodsman
-- 3 classes, each replaced whole: gypsy-seer, gypsy-gifted, trapper-woodsman.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~210-book-ingest-audit-f140-triax-canada.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Sentences on two Triax classes (Rifts World Book 5, printed 182-185) and one
-- Canada class (Rifts World Book 20, printed 88-90) were false on 2026-10-15,
-- each tested against a 170 dpi render of the page and against production:
-- - gypsy-seer and gypsy-gifted said Millennium Tree leaf armour had no row;
--   the Rifts row millennium-leaf-body-armor (Rifts Japan) holds it, and it is
--   now one more option of each class's light M.D.C. body armor choice, as
--   printed 184 and 185 list it;
-- - both said the catalog has no bandanna; it holds Heroes Unlimited and
--   Nightbane rows and no Rifts row, which is what each now says;
-- - gypsy-gifted said the gift is rolled, not chosen, and that nothing rolls on
--   a table at creation; printed 184 says to randomly roll or select one, and
--   the wizard draws a Roll d100 button for the band-named group;
-- - trapper-woodsman said the cooking utensils and the fur cloak or long coat
--   have no catalog row; the Rifts rows utensil-kit-rifts and cape-or-cloak-long
--   hold them, and both are now granted, as the Huntsman-Trapper's are.
-- No catalog row is added or re-tagged.

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
  - { item_id: "scarf", qty: 2 }
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
    coloured bandanna (two scarves are stored; the catalog has no Rifts
    bandanna row), the energy rifle or pistol, an unresolved choice this
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

Standard issue beyond the stored equipment: an energy rifle or pistol, an unresolved choice; a bright coloured bandanna worn with the scarf; a squirt gun filled with water; and, of the two canteens stored, one filled with holy water and one for drinking. A car is a third vehicle option, but only if the character can drive.

Notable additional equipment a seer may want to acquire: magic jewelry and crystals, staves and wands, magic potions, herbs, demon-slaying weapons and magic, and other exotic jewelry, weapons and objects. Sensory equipment, a hand-held computer, a language translator, cameras and recording equipment may also be of interest.

Of all the gypsies the seer dresses the most demure - but is still likely to wear 2D4 rings, bracelets, necklaces, pins, earrings and other jewelry.

Money: 2D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer'
   AND instr(markdown, 'Millennium Tree leaf armour - a Rifts England') > 0
   AND length(markdown) = 16759;

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
  - { item_id: "scarf", qty: 2 }
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
    coloured bandanna (two scarves are stored; the catalog has no Rifts
    bandanna row), the weapon of choice, an unresolved choice this book''s
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

Standard issue beyond the stored equipment: a weapon of choice; a bright coloured bandanna worn with the scarf; and a car as a third vehicle option, but only if the character can drive.

The medical kit holds soap, disposable towels, bandages, suture tape, antiseptics, protein healing salve, aspirin, painkillers, antibiotics, sedatives, anesthetics, a hypodermic gun, a stethoscope, a pen flashlight and a portable compu-drug dispenser, along with a second bag of holistic herbs, teas, salves and potions. The surgical kit holds a variety of scalpels, one laser scalpel, needles, clamps, sutures, suture tape, a suture gun, several IRMSS units, an RMK, a hand-held computerised blood pressure machine, 3D4 thermometers, six unbreakable specimen containers, a hundred pairs of disposable surgical gloves and two reusable pairs.

Money: 1D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, 'The gift is ROLLED, not chosen.') > 0
   AND length(markdown) = 20859;

-- == trapper-woodsman ==
UPDATE imported_classes
   SET markdown = '---
id: trapper-woodsman
name: Trapper-Woodsman
system: rifts
source_book: Rifts World Book 20: Canada p.88-90
category: occ
tags: [wilderness, hunter]
occ_group: optional
men_of_arms: false
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { IQ: 8, PE: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "0"
bonuses:
  pools: { sdc: "4d6+10" }
  combat: { initiative: 2, pull_punch: 3 }
  saves: { possession: 1, toxins_poisons: 2, disease: 2, pain: 2, horror_factor: 1, other: [ { label: "vs cold", bonus: 2 } ] }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Language: Native Tongue", base: 92, per_level: 0, note: "Speaks American (English) at 92%." }
    - { name: "Language: Inuit", base: 65, per_level: 5, note: "Speaks Inuit (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language of choice (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Cattle & Animals", base: 50, per_level: 5, note: "Lore: Cattle/Animals (+20%)." }
    - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Printed as Track Animals (+20%). The special ability for monstrous animals has its own percentages." }
    - { name: "Skin & Prepare Animal Hides", base: 55, per_level: 5, note: "+25%" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "Identify Plants & Fruits (+15%)." }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Fishing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
    - { name: "Trap Construction", base: 35, per_level: 4, note: "+15%" }
    - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice (any)." }
    - { name: "W.P. Bolt Action Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one M.D. energy weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "No others are available." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Tracking (people)"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"], bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Tanks & APCs", "Military: Submersibles", "Military: Warships & Patrol Boats", "Boat: Ships", "Boat: Submersibles", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only: ["Whittling & Sculpting", "Breed Dogs"], bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Choose four other skills at level one and two additional at levels 4, 8 and 12. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: none, except Detect Ambush, Detect Concealment, Intelligence and Tracking (all +5%). Mechanical: none. Medical: First Aid, Holistic Medicine and Brewing only. Military: none (Falconry is offered here only because the catalog files it under Military; the book prices it under Technical at +15%). Physical: any, except Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft; most opt for Horsemanship and/or Ride Exotic Animals, offered here in their own category. Pilot Related: any, but usually none. Rogue: any. Science: Astronomy, Botany and Advanced Math only (+5%). Technical: any (+10%; Whittling, Breeding Dogs and Falconry are +15%: Whittling & Sculpting and Breed Dogs take it from the second Technical entry, Falconry from Military). W.P.: any. Wilderness: any (+10%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Tracking (people)"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Tanks & APCs", "Military: Submersibles", "Military: Warships & Patrol Boats", "Boat: Ships", "Boat: Submersibles", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the same list at level one and one additional at levels 2, 4, 6, 8 and 12, without the bonuses in parentheses and limited as the list indicates."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - { name: "Track & Trap Monstrous Animals, Otherworldly Creatures & Demons", description: "A wider, specialized form of Track Animals aimed at alien and monstrous prey: dinosaurs, Demon-Bears, the Windigo, Rhino-Buffalo, Fury Beetles and the like. Identifies an animal, a creature from the Rifts or an animalistic demon by tracks, scent, spoor and habits; follows its trail; judges how fresh the tracks are, their direction, whether the creature is hurt or sick and roughly how old; and knows how and where most woodland creatures of Canada and the northern U.S. live, among them woodland spirits, lesser demons, werebeasts, the Loup-Garou, the Windigo and Faerie Folk. Base skill 20% tracking / 30% trapping (using, setting and disarming snares, clamp traps, pits, nets and the like), +5% per level. Tracking humans is possible at -20%. Disarming a trap meant for humans is at half the normal skill." }
  - { name: "Forest-wise", description: "Streetwise for the forest: recognizes the human, D-Bee, Faerie Folk, werebeast and lesser demon tribes, gangs and bands that live, hunt or hide in the woods, and knows what they believe, how they behave, their rituals, where they gather and which places are dangerous. Predatory animals are covered too. Base skill 26%, +4% per level." }
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["homemade-mdc-armor-light", "fury-beetle-armor-partial"], note: "Light suit of M.D.C. body armor, usually a hodgepodge of homemade armor or Fury Beetle armor." }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "knife-skinning", qty: 2, note: "The book says skinning knives, with no number." }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "hand-axe-utility", qty: 1, note: "The book says a hand axe." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says a language translator." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "The book says a lighter." }
  - { item_id: "flint", qty: 1, note: "Flint and tinder box." }
  - { item_id: "utensil-kit-rifts", qty: 1, note: "The book says cooking utensils." }
  - { item_id: "frying-pan", qty: 1 }
  - { item_id: "small-sack", qty: "1d6" }
  - { item_id: "sack", qty: 6, note: "Six medium-sized sacks." }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "duffle bag or saddlebag", qty: 1, from: ["duffle-bag", "saddlebags"] }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "belt", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "cape-or-cloak-long", qty: 1, note: "The book says a fur cloak or long coat." }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "lightweight-cord", qty: 1, note: "10 feet (3 m) of thin nylon cord." }
  - { item_id: "cord", qty: 1, note: "50 feet (15.2 m) of additional cord, 600 lb (270 kg) test strength." }
  - { item_id: "animal-snare", qty: 1, note: "The book says animal snares, with no number." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none."
  - "Attribute requirements: I.Q. 8 and P.E. 12 or higher. A high M.E. and P.S. are helpful but not a requirement."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Expert only; no others are available."
  - "Cybernetics: none to start, and avoids them as unnatural. The only cybernetics a Trapper might consider are bio-system prosthetics and organs to replace severely injured ones."
  - "Vehicle: none to start; most Trappers prefer to walk, but may know how to ride a horse or hovercycle."
extraction_notes: "WB20 Canada printed 88-90 (cache p089-p091, cache page = printed folio + 1), read off the text layer; all three pages were rendered and read beside it. Heading Trapper-Woodsman OCC on printed 88, after the pointer list Other Common O.C.C.s available to Tundra Rangers; Special Skills & O.C.C. Abilities and the stat block headed The North American Trapper-Woodsman O.C.C. (also known as Woodsman, Trapper and Furrier) on printed 89; the entry ends on printed 90 with a note that this is a different class from the Huntsman-Trapper of Warlords of Russia. Southwestern Canada starts on printed 91. || GROUP: the book has no O.C.C. group headings. The entry says the Trapper-Woodsman is not a Tundra Ranger and calls the character a rogue, mercenary or independent entrepreneur, so occ_group is optional and men_of_arms is false, as for the Huntsman-Trapper. The entry prints no S.D.C. base; +4D6+10 S.D.C. is listed under O.C.C. Bonuses and is stored as a pool bonus. || XP: the Tundra Ranger, Headhunter Techno-Hound and Trapper-Woodsman ladder on printed 192, as supplied from a render. || BONUSES: +2 initiative, +3 pull punch, +1 vs possession stored; +2 vs poison and disease is toxins_poisons 2 and disease 2; +2 vs cold and pain is pain 2 and a saves.other vs cold 2; +1 vs Horror Factor at levels 1, 3, 5, 7, 9, 11, 13 and 15 is horror_factor 1 flat for level 1 plus seven at_level entries. || SPECIAL ABILITIES: Track and trap monstrous animals (20%/30% +5% per level) and Forest-wise (26% +4% per level) are special_abilities prose; neither has a catalog skill row. The O.C.C. skill list separately prints Track Animals (+20%), stored as Track & Trap Animals at 40. || LANGUAGES: Speaks American (English) at 92% is Language: Native Tongue at 92. Speaks Inuit and one other language of choice (+15%): Inuit is the Language: Inuit row (added by ~114) at the catalog 50% plus 15, and the other is one Language: Other pick at +15%. The entry prints no literacy. || SKILL READINGS: Basic Math is Mathematics: Basic; Lore: Cattle/Animals is Lore: Cattle & Animals; Identify Plants & Fruits is Identify Plants & Fruit; Swim and Climb are Swimming and Climbing. W.P. two ancient of choice and W.P. one M.D. energy weapon of choice are free Weapon Proficiencies picks with the limit in the note. Hand to Hand: Expert, no others available. || RELATED: four at level one and two more at levels 4, 8 and 12. Espionage none except Detect Ambush, Detect Concealment, Intelligence and Tracking (+5%), Tracking being Tracking (people). Science is Astronomy, Botany and Mathematics: Advanced (+5%). Technical any +10% with Whittling, Breeding Dogs and Falconry at +15%: Technical is stored at +10%, with a second Technical entry naming Whittling & Sculpting and Breed Dogs at +15% (BOOK-INGEST-AUDIT.md F138, 2026-10-14); Falconry is filed under Military in the catalog, so Military appears with only Falconry at +15% although the book says Military: None. Pilot except robots, power armor, military vehicles, ships and aircraft excludes the robot and power armor rows, every Military: pilot row, Boat: Ships and Boat: Submersibles, and every aircraft and spacecraft row. Most opt for Horsemanship and/or Ride Exotic Animals is the catalog Horsemanship category limited to General and Exotic Animals. || MONEY: the book prints 4D4x100 credits worth of furs, horns, bone, nuggets of silver or gold and other tradeable goods (text layer 4D4xlOO); that is goods, not coin, so starting_money is 0 and the goods are in GM Notes. || EQUIPMENT: the light M.D.C. armor is a pick between the homemade light armor row and partial Fury Beetle armor; two canteens or water skins on the canteen row; duffle bag or saddlebag as a pick; skinning knives print no number and two are stored; animal snares print no number and one is stored. Cooking utensils are the Rifts utensil-kit-rifts row and the fur cloak or long coat the Rifts cape-or-cloak-long row, both granted 2026-10-15 (BOOK-INGEST-AUDIT.md F140), as the Huntsman-Trapper''s are. NOT stored: one weapon for each W.P. (unnamed), the two boxes of 100 sealable plastic bags, 1D4 airtight plastic containers, 20 feet of wire and a handful of personal items have no catalog row. Secret Resources: none per se."
---

## Lore

The Trapper-Woodsman is no Tundra Ranger, but the Rangers meet them all the
time. They are the hunters, trappers and furriers of the Canadian wilds, the
New West and the forests of the eastern United States: rough, loud,
self-reliant people who are far more comfortable under trees than on a city
street. Hunting, fishing, snaring and skinning are how they earn a living,
trading pelts, horn, claws, teeth and meat with Native Americans, trading
posts, farms and anyone they meet on the trail.

Most like the woods because nobody there tells them how to behave. They
belch, swear and say what they think, and they enjoy it when city people
take them for ignorant savages; plenty of them play the bumpkin on purpose
around Coalition soldiers and strangers they distrust. Under the act they
are sharp, observant and quick, and they like a surprise and a challenge.

They also like adventure and a good fight, and they have a soft spot they
will not admit to. A Trapper who takes a liking to someone is fiercely
loyal, and most will stop to help women, children and lawmen, pass news and
warnings to the Rangers, and now and then ride with them against something
evil. Few accept bionics. They wear Mega-Damage armor, often homemade or cut
from Fury Beetle shell, and carry both M.D. weapons and ordinary hunting
rifles or bows.

## GM Notes

Starting kit the sheet does not list: one weapon for each W.P. (1D4+2 extra
ammo-clips for each are on the sheet as E-Clips), a box of 100 sealable
plastic sandwich bags, a box of 100 large sealable bags, 1D4 airtight
resealable plastic containers, wire (20 feet) and a few personal items. The
cooking utensils are on the sheet as a Utensil Kit, and the fur cloak or long
coat as a long cape or cloak. More weapons, special items and magic
items come with time and role-playing.

Money: no cash. The character starts with 4D4x100 credits worth of furs,
horns, bone, silver or gold nuggets and other trade goods (herbs, spices,
birds, small animals). Most spend quickly and live off the land.

Languages: Inuit and one language of choice, each at +15%. Inuit is
granted; the other is a free language pick.

Technical skills: Whittling & Sculpting and Breed Dogs get +15% rather than
the +10% the rest of Technical gets, when taken as a related skill.

Secret resources: none as such, though most Trappers are on good terms with
the trading posts, a favorite town and the Tundra Rangers.

This is a different class from the Huntsman-Trapper of Warlords of Russia.
',
       updated_at = datetime('now')
 WHERE class_id = 'trapper-woodsman'
   AND instr(markdown, 'cooking utensils, the two boxes of 100 sealable plastic bags') > 0
   AND length(markdown) = 18285;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 3 classes carry their new text' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-seer' AND instr(markdown, 'Millennium Tree leaf armor or T-40 plain clothes armor') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, 'randomly roll or select one of the four') > 0)
    OR (class_id = 'trapper-woodsman' AND instr(markdown, '"utensil-kit-rifts", qty: 1, note: "The book says cooking utensils."') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-seer' AND instr(markdown, 'Millennium Tree leaf armour - a Rifts England') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, 'The gift is ROLLED, not chosen.') > 0)
    OR (class_id = 'trapper-woodsman' AND instr(markdown, 'cooking utensils, the two boxes of 100 sealable plastic bags') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gypsy-seer', 'gypsy-gifted', 'trapper-woodsman') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~210-book-ingest-audit-f140-triax-canada.sql');
