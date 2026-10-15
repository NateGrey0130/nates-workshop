-- BOOK-INGEST-AUDIT F139: seven classes are granted the T-40 armour, motorcycles, cloak, rope, rations and spear their kit names
-- 7 classes, each replaced whole: gypsy-thief, gypsy-wizard-thief, gypsy-seer, gypsy-gifted, cyber-samurai, totem-warrior, paradox-shaman.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~199-book-ingest-audit-f139-plain-grants-b.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == gypsy-thief ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-thief
men_of_arms: false
occ_group: optional
name: Gypsy Thief
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.180-181
category: occ
tags: [stealth]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_requirements: { PP: 12 }
starting_money: "1d4x1000"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: select three of choice (+20%). Taken once per language - the picker asks which. All gypsies also speak Euro." }
    - { name: "Streetwise", base: 34, per_level: 4, note: "+14%" }
    - { name: "Streetwise: Drugs", base: 39, per_level: 5, note: "+14%; the entry grants Streetwise and Streetwise: Drugs together, both at +14%." }
    - { name: "Horsemanship: General", base: 60, per_level: 4, note: "Horsemanship (+20%)" }
    - { name: "Play Musical Instrument", base: 45, per_level: 5, note: "One of choice (+10%)" }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Concealment", base: 30, per_level: 4, note: "+10%" }
    - { name: "Palming", base: 40, per_level: 5, note: "+20%" }
    - { name: "Pick Locks", base: 45, per_level: 5, note: "+15%" }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%" }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%" }
    - { name: "Acrobatics", base: 30, per_level: 5, note: "Printed with no percentage beside it, so it stands at the catalog base." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: choice of two." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of one other skill, or Expert/Assassin (if evil) for the cost of two. The book prints Expert twice (Triax printed 180); the second is read as Martial Arts, the style the Gypsy Seer and Gypsy - The Gifted print in that position, so Martial Arts or Assassin (if evil) costs two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems"], bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Wrestling", "Gymnastics"] }
      - { name: "Pilot", bonus: 10, except: ["Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Tanks & APCs", "Jet Aircraft", "Military: Jet Fighters", "Boat: Ships", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 10 }
      - { name: "Technical", bonus: 10, note: "+10%, and +15% on languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "+15% on languages." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10, note: "Wilderness Survival is also named on the book''s Espionage line at +10%; it is a Wilderness skill in this catalog and is taken here at the same +10%." }
    note: "Electrical, Mechanical, Military and Science: none."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "jacket-leather", qty: 1 }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
  - { item_id: "scarf", qty: 2 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "knife", qty: 2 }
  - { item_id: "lock-picking-tools", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "note pad or sketch book", qty: 1, from: ["note-pad", "sketch-pad"] }
  - { item_id: "pen", qty: "1d4" }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
restrictions:
  - "Alignment: Unprincipled, Anarchist or any evil. A thief cannot be of a good alignment."
  - "Cybernetics: starts with none. Most gypsies avoid cybernetics except for medical reasons."
extraction_notes: |
  - Triax and the NGR, printed 180-181. The first of the book''s four Gypsy
    O.C.C.s, and the first entry in this book outside the NGR military, so it
    takes no `ngr-` prefix. The id is `gypsy-thief` rather than `thief`, which
    is already the Palladium Fantasy class - the survey called this collision.
  - LANGUAGE: GYPSY IS A NEW CATALOG ROW, created by this batch and cited to
    printed 179, where the book describes the gypsies'' secret spoken language
    and its dozen symbols. It is not one of the seven new skills printed 155
    lists; it is a language named only inside the O.C.C. entries.
  - The book prints "Streetwise (includes Streetwise: Drugs, both are + 14%)"
    as one line. Stored as two skills, because the catalog holds two rows.
  - THE ESPIONAGE LINE NAMES WILDERNESS SURVIVAL AND THIS CATALOG FILES THAT
    SKILL UNDER WILDERNESS. Unlike the Police O.C.C. two entries earlier, this
    class also grants "Wilderness: Any (+10%)", so the skill is reachable
    without any special handling and is simply left to the Wilderness line -
    which carries the same +10% the Espionage line prints, so nothing is lost.
    It is NOT listed in the Espionage `only`, because a cross-category `only`
    that duplicates a category the class already grants adds nothing.
  - THE PILOT EXCLUSION LIST WILL ROT. The book says "except robot combat:
    elite, tanks & APCs, jets, jet fighters, and ships". `except` matches exact
    catalog names and has no prefix form, so every `Robot Combat Elite:` row is
    named individually - twelve of them today. A thirteenth machine imported
    from this book''s gear chapter, or from Triax 2, will be offered to this
    class unless it is added here. An unmatched or missing `except` fails OPEN.
  - "Ships" is mapped to BOTH `Boat: Ships` and `Military: Warships & Patrol
    Boats`. The catalog splits into two rows what the book names once, and a
    warship is a ship; excluding only the first would leave the larger vessel
    offered to a class the book bars from ships altogether.
  - The +15% the Technical line prints for languages IS stored: Technical is
    listed twice, once at +10% and once limited to the Language rows at +15%
    (the twice-listed category shape of BOOK-INGEST-AUDIT.md F109).
  - Money is 1D4x1000 credits. The entry also grants 2D4x1000 in jewelry,
    artifacts and other stolen goods, which `starting_money` cannot hold - it
    is coin only - so it is recorded in the body and here.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna (the catalog has a scarf and no bandanna; two scarves are
    stored and the bandanna is prose), the energy rifle and energy pistol,
    which are unresolved choices this book''s batches record as prose rather
    than stub, and the robot horse and land buggy, two of the
    four vehicle options, which have no rows - the horse and the hovercycle do
    and are the stored choice.
    T-40 "plain clothes" armour is stored as seven more options of the light
    M.D.C. body armor choice, its `t-40-urban-*` rows (BOOK-INGEST-AUDIT.md
    F139).
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js). The entry
    prints no S.D.C. formula, and the book files it under Gypsy O.C.C.s rather
    than with the Military O.C.C.s of printed 156 - the same reading the City
    Rat already gets on the Rifts side.
---

# Gypsy Thief

## Lore

The gypsy thief is a thug, cat-burglar and con-man all rolled into one. Some are slimy little weasels or mean looking punks; others are suave, bold, James Bond types. Regardless of how the thief may look or act, timid or bold, crude or debonair, male or female, all are master thieves.

The gypsies of Rifts Earth are not the gypsies of the world before it. About half are human, forty percent D-bees and one in ten a supernatural monster or alien. They are wanderers with no one place they call home, most common in Central Europe and found as far east as Mongolia and northern China. Most clans are several related families plus whoever has been accepted in, and they seldom squabble among themselves or steal from each other - the hundreds of clans behave like one enormous fraternity whose members treat each other as brothers. Like any fraternity they wear their colours: bright bandannas and scarves in yellow, orange, red, pink and purple. They love gold and jewelry, and they have a secret spoken language that is never used in front of outsiders, let alone taught to them.

Being a gypsy is a lifestyle and not a racial factor. A gypsy may also be a headhunter, juicer, vagabond, wilderness scout, witch, traditional mystic, mind melter or any of the psychic R.C.C.s, but will not consider the soldier, knight, techno-wizard, druid or scholar - they are too disciplined and fit poorly into gypsy society. Most gypsies avoid cybernetics, power armour, robots and formal training in magic.

## Equipment and Money

Standard issue beyond the stored equipment: an energy rifle and an energy pistol, both unresolved choices; and a bright coloured bandanna worn with the scarf. Thieves dress in black and dark blue with splashes of gold and red, and they love leather.

Notable additional equipment a thief may want to acquire: special clothing with concealed pockets, weapons and items with false or hollow handles and bottoms, disguises, a better vehicle, a jet pack, magic items, a vibro-blade, a laser scalpel, signal flares, smoke, tear gas grenades, a mini-tool kit, multi-optic bands, handcuffs, surveillance items, a pocket mirror, a pocket laser distancer, a pocket digital disc recorder for his observations, and a hand-held computer.

Money: 1D4x1000 credits, plus 2D4x1000 in jewelry, artifacts and other stolen goods. The gypsy enjoys the good life and spends his money quickly and freely on life''s many pleasures and extravagances.

## GM Notes

The rules for travelling shows and carnivals in Rifts World Book One: Vampire Kingdoms are a useful aid when a gypsy clan arrives to make trouble. Vampires plague parts of Europe, Romania in particular, and may work with unscrupulous gypsies or prey upon the clans themselves.

A gypsy caravan, or even one gypsy, means trouble. When valuables disappear the gypsy is the first suspect and is probably guilty. Beyond commonplace robbery and mugging they favour elaborate schemes and charades: disguises, forgery, distractions, magic illusions, mirrors, smoke, and every con-game in the book. Many clans arrive with the fanfare of a carnival, pitch camp outside town, and sell fortune-telling, healing, magic shows, minstrels, dancing girls and alleged magic potions - and use every transaction to size up the buyer, his friends and his town for plundering later.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'and the armour stays prose.') > 0
   AND length(markdown) = 12805;

-- == gypsy-wizard-thief ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-wizard-thief
men_of_arms: false
occ_group: magic
name: Gypsy Wizard Thief
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.181-182
category: occ
tags: [stealth]
xp_table: [0, 2701, 5401, 10801, 21601, 31601, 42801, 62001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]
attribute_requirements: { IQ: 10, ME: 12 }
ppe_base: "2d4x10 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "1d6x1000"
magic:
  type: "spell"
  spells: ["Blinding Flash", "Globe of Daylight", "See the Invisible", "Chameleon", "Concealment", "Detect Concealment", "Charismatic Aura", "Mask of Deceit", "Fool''s Gold", "Escape", "Energy Disruption", "Levitation", "Armor of Ithan", "Repel Animals", "Reduce Self (6 inches)", "Teleport: Lesser"]
  spells_starting: 4
  spell_levels_allowed: [1, 2, 3, 4]
bonuses:
  saves: { horror_factor: 2, spell_magic: 1 }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Lore: Demons & Monsters", base: 20, per_level: 5, note: "Printed as a flat (20%) with no plus sign, unlike every other bonus in this list. Read off a 200 dpi render of printed 182: it is the skill''s percentage, not a bonus, and it is five points BELOW the catalog base of 25." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 15, per_level: 5, note: "Printed as a flat (15%) with no plus sign. Same reading as the Lore above; the catalog base is 25." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Play Musical Instrument", base: 40, per_level: 5, note: "One of choice (+5%)" }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { name: "Language: Euro", base: 80, per_level: 5, note: "+30%" }
    - { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: select three of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
    - { name: "Pick Pockets", base: 30, per_level: 5, note: "+5%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts (or Assassin if evil) for the cost of three." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Acrobatics"] }
      - { name: "Pilot", bonus: 10, except: ["Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Tanks & APCs", "Jet Aircraft", "Military: Jet Fighters", "Boat: Ships", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10, note: "+10%, and +15% on literacy and languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on literacy and languages." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "Wilderness Survival is also named on the book''s Espionage line at +10%. It is a Wilderness skill in this catalog; the Espionage entry names it, so it takes that line''s +10% in place of this line''s +5%. BOOK-INGEST-AUDIT.md F9." }
    note: "Electrical, Mechanical and Military: none."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { choose: 1, label: "cloak or cape", qty: 1, from: ["hooded-cloak", "cloak-of-armor"] }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
  - { item_id: "scarf", qty: 2 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "knife", qty: 2 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { choose: 1, label: "wood or silver cross", qty: 1, from: ["wooden-cross", "small-silver-cross"] }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "note pad or sketch book", qty: 1, from: ["note-pad", "sketch-pad"] }
  - { item_id: "pen", qty: "1d4" }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
natural_abilities:
  - name: "Sense Ley Lines and Magic Energy"
    description: "Senses whether a ley line or nexus is nearby. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Read Ley Lines"
    description: "Instantly knows the direction, length, nexus locations and similar things about a ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Ley Line Transmission"
    description: "Sends a verbal and/or visual message along a ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Ley Line Phasing"
    description: "Instantly teleports from one place to another on the same ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Not a Full Line Walker"
    description: "The wizard thief does NOT have the Ley Line Walker''s powers of line drifting, ley line rejuvenation or ley line observation ball. The book states the absence outright."
  - name: "Learning New Spells"
    description: "Additional spells and rituals of ANY magic level can be learned or purchased at any time, regardless of the character''s experience level - see the Pursuit of Magic, Rifts RPG printed 164. The wizard thief selects magic that aids him as a thief rather than mystic power: illusion, deception, confusion and concealment. He seldom even considers other areas of magic, because the art was passed down from father to son or daughter and is limited to what poppa could teach."
restrictions:
  - "Alignment: Unprincipled, Anarchist or evil. A thief cannot be of a good alignment."
  - "Only 50% of wizard thieves are literate in any language."
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels three, seven, ten and thirteen. Spell Strength is not a field the sheet holds."
  - "Cybernetics: starts with none and avoids them except for medical reasons. May consider bio-wizardry items."
extraction_notes: |
  - Triax and the NGR, printed 181-182. The second of the book''s four Gypsy
    O.C.C.s. A split-class - a thief first and a wizard second - which is why
    its experience ladder on printed 224 is its own rather than the Ley Line
    Walker''s.
  - THE TWO LORE SKILLS ARE FIXED PERCENTAGES, NOT BONUSES. Printed 182 gives
    "Lore: Demons & Monsters (20%)" and "Lore: Faeries (15%)" with NO plus
    sign, where every other entry in the same list carries one. Verified on a
    200 dpi render of the page rather than off the OCR, because the OCR is the
    same engine that would have dropped the sign. Both land BELOW the catalog
    base of 25, which is the tell that they are the book''s own numbers.
  - Lore: Faeries is stored as "Lore: Faeries & Creatures of Magic", the
    catalog''s name for that row.
  - THE ESPIONAGE LINE NAMES WILDERNESS SURVIVAL AT +10% AND THE WILDERNESS
    LINE PRINTS +5%. This catalog files Wilderness Survival under Wilderness,
    which this class grants, so the skill is reachable, and the Espionage entry
    names it, so it takes that line''s +10% rather than the Wilderness line''s
    +5%. BOOK-INGEST-AUDIT.md F9; stored this way 2026-10-14 under F138. The Gypsy Thief one entry
    earlier has the same two lines at the SAME percentage and loses nothing.
  - THE PILOT EXCLUSION LIST WILL ROT, for the reason recorded on the Gypsy
    Thief: `except` matches exact catalog names with no prefix form, so all
    twelve `Robot Combat Elite` rows are named individually and a thirteenth
    will be offered to this class unless it is added here.
  - SECONDARY SKILLS START AT ZERO AND THAT IS THE BOOK. Printed 182 says the
    character selects two secondary skills "at levels two, five, eight, and
    twelve" and names no level-one grant, where the Gypsy Thief two pages
    earlier says "at level one and one additional skill at levels four, seven,
    ten and thirteen". Three of this book''s four Gypsy O.C.C.s are written the
    later way. Read from the render, not inferred from the sibling class.
  - Initial spell knowledge is the sixteen named spells, granted outright, plus
    four more of the player''s choice from spell levels 1-4. All sixteen resolve
    in the catalog; "Reduce Self" is stored under its catalog name,
    "Reduce Self (6 inches)".
  - Money is 1D6x1000 credits. The entry also grants 3D4x1000 credits worth of
    jewelry, artifacts and other stolen goods, which `starting_money` cannot
    hold - it is coin only - so it is recorded in the body and here.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna (two scarves are stored; the catalog has no bandanna),
    the energy rifle or pistol, an unresolved choice this book''s batches record
    as prose rather than stub, and the robot horse and land
    buggy, two of the four vehicle options.
    T-40 "plain clothes" armour is stored as seven more options of the light
    M.D.C. body armor choice, its `t-40-urban-*` rows (BOOK-INGEST-AUDIT.md
    F139).
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js): the entry
    prints no S.D.C. formula and this is a practitioner of magic.
---

# Gypsy Wizard Thief

## Lore

The wizard thief is fundamentally a ley line walker with an emphasis on magic that is useful in thievery. Unlike the traditional line walker, the wizard thief usually has much less understanding of magic and a narrower band of spell knowledge, because the character is a thief first and a wizard second.

The art of mystic thievery is traditionally passed down from father to son or daughter. Since the main interest is stealing, the focus of the magic is almost entirely aimed in that direction, and their spell knowledge reflects it: illusion, deception, confusion and concealment, limited to what poppa could teach. The wizard thief seldom even considers learning other areas of magic. The character progresses in experience at a slower pace than a line walker, because he is fundamentally a split-class and spends much of his training and attention on thievery and streetsmarts rather than magic.

## Equipment and Money

Standard issue beyond the stored equipment: an energy rifle or pistol, an unresolved choice; and a bright coloured bandanna worn with the scarf.

Notable additional equipment a wizard thief may want to acquire: magic weapons, magic potions, magic equipment, scrolls, a vibro-blade, a laser scalpel, signal flares, smoke and tear gas grenades, a mini-tool kit, a multi-optics band, handcuffs, surveillance items, a pocket mirror, a pocket laser distancer, a pocket digital disc recorder for his observations, and a hand-held computer.

Money: 1D6x1000 credits, plus 3D4x1000 credits worth of jewelry, artifacts and other stolen goods. The gypsy enjoys the good life and spends his money quickly and freely.

All gypsies are snappy and stylish dressers, and their choice of garments reflects their boldness and bright personalities.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief'
   AND instr(markdown, 'and the armour stays prose.') > 0
   AND length(markdown) = 13139;

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
  - { choose: 1, label: "light M.D.C. body armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
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
    coloured bandanna (two scarves are stored; the catalog has no bandanna),
    the energy rifle or pistol, an unresolved choice this book''s batches record
    as prose rather than stub, Millennium Tree leaf armour - a Rifts England
    row this catalog does not hold - the squirt gun
    filled with water, the car as a vehicle option, and the 2D4 pieces of
    jewelry the seer wears.
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

Standard issue beyond the stored equipment: an energy rifle or pistol, an unresolved choice; a bright coloured bandanna worn with the scarf; Millennium Tree leaf armour as a further alternative to the stored body armour choice; a squirt gun filled with water; and, of the two canteens stored, one filled with holy water and one for drinking. A car is a third vehicle option, but only if the character can drive.

Notable additional equipment a seer may want to acquire: magic jewelry and crystals, staves and wands, magic potions, herbs, demon-slaying weapons and magic, and other exotic jewelry, weapons and objects. Sensory equipment, a hand-held computer, a language translator, cameras and recording equipment may also be of interest.

Of all the gypsies the seer dresses the most demure - but is still likely to wear 2D4 rings, bracelets, necklaces, pins, earrings and other jewelry.

Money: 2D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer'
   AND instr(markdown, 'and the armour stays prose.') > 0
   AND length(markdown) = 16728;

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
  - { choose: 1, label: "light M.D.C. body armor or T-40 plain clothes armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "t-40-urban-businessman-suit", "t-40-urban-ultra-businessman-suit", "t-40-urban-jump-suit", "t-40-urban-outdoorsman", "t-40-urban-long-coat", "t-40-urban-standard-jacket", "t-40-urban-standard-vest"] }
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
  - "The gift is ROLLED, not chosen. Roll percentile once at creation and take the matching ability under Abilities; the app offers all four as a choice, with a Roll d100 button that picks by band."
  - "Cybernetics: starts with none and avoids them except for medical reasons. This character will NEVER consider bio-wizardry items - the one gypsy O.C.C. of the four that rules them out."
extraction_notes: |
  - Triax and the NGR, printed 184-185. The last of the book''s four Gypsy
    O.C.C.s. The book prints the name with an em-dash, "Gypsy - The Gifted
    O.C.C."; it is stored with a hyphen.
  - THE PSIONIC PROFILE IS ROLLED FROM A FOUR-BAND TABLE, AND THE FOUR BANDS
    ARE STORED AS FOUR CHOOSABLE ABILITIES RATHER THAN AS VARIANTS. Printed
    184-185 rolls 01-25, 26-50, 51-75 or 76-00, and the bands differ in psionic
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
  - The roll is a ROLL and the app offers it as a choice, because nothing here
    rolls on a table at creation. Recorded in `restrictions` so the player sees
    it at the pick rather than only here.
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
    coloured bandanna (two scarves are stored; the catalog has no bandanna),
    the weapon of choice, an unresolved choice this book''s batches record as
    prose rather than stub, Millennium Tree leaf armour, the car as a vehicle
    option, and the contents of the two kits -
    soap, towels, bandages, suture tape and gun, antiseptics, protein healing
    salve, aspirin, painkillers, antibiotics, sedatives, anesthetics, a
    hypodermic gun, a pen flashlight, a bag of holistic herbs and teas,
    needles, clamps, sutures, a hand-held computerised blood pressure machine,
    3D4 thermometers, six specimen containers and a hundred pairs of
    disposable surgical gloves. The kits themselves are stored; their listed
    contents are prose, which is how the NGR Medical Officer''s kits went in.
    T-40 "plain clothes" armour is stored as seven more options of the light
    M.D.C. body armor choice, its `t-40-urban-*` rows (BOOK-INGEST-AUDIT.md
    F139).
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js): the entry
    prints no S.D.C. formula, and a psionic healer is not a man of arms.
---

# Gypsy - The Gifted

## Lore

"The Gifted", or "The Gifted Ones", are gypsy healers. The character has both psionic healing abilities and knowledge in the ways of medicine and herbology. They are among the most revered of the gypsies and often hold a high place among the clans. The Gifted tend to be the least violent of the gypsies and have few thief or rogue skills.

The gift itself is rolled rather than chosen: half of The Gifted are major psychics and half are masters, and what the character can do - how many powers, from which categories, how much I.S.P., and whether there is any spare training for other skills at all - follows from that roll. Roll percentile once at creation and take the matching gift under Abilities.

## Equipment and Money

Standard issue beyond the stored equipment: a weapon of choice; a bright coloured bandanna worn with the scarf; Millennium Tree leaf armour as a further alternative to the stored body armour choice; and a car as a third vehicle option, but only if the character can drive.

The medical kit holds soap, disposable towels, bandages, suture tape, antiseptics, protein healing salve, aspirin, painkillers, antibiotics, sedatives, anesthetics, a hypodermic gun, a stethoscope, a pen flashlight and a portable compu-drug dispenser, along with a second bag of holistic herbs, teas, salves and potions. The surgical kit holds a variety of scalpels, one laser scalpel, needles, clamps, sutures, suture tape, a suture gun, several IRMSS units, an RMK, a hand-held computerised blood pressure machine, 3D4 thermometers, six unbreakable specimen containers, a hundred pairs of disposable surgical gloves and two reusable pairs.

Money: 1D6x1000 credits, plus 3D4x1000 credits worth of gold, jewelry and artifacts. The gypsy enjoys the good life and spends his money quickly and freely.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, 'and the armour stays prose.') > 0
   AND length(markdown) = 20828;

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
  - { choose: 1, label: "transportation", qty: 1, from: ["riding-horse", "hovercycle", "km-200-jet-pack", "the-highway-man-motorcycle", "the-wastelander-motorcycle", "road-boss-motorcycle"] }
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
side_effects: "Money: 2D6 x 1000 credits, plus 2D4 x 1000 credits in salable Black Market items. An employed samurai may draw a stipend or salary of 1D4 x 1000 credits a month, which may rise as he gains favor with his daimyo, corporation or government. Transportation may instead be a robot horse or a similar open vehicle. About 10% of cyber-samurai own a true, ancient pre-Rifts samurai sword (a powerful rune weapon) and 15% a true samurai sword of recent make and lesser power (see the True Samurai O.C.C.); the rest rely on vibro-blades, energy weapons and modern gear."
extraction_notes: "Rifts World Book 8: Japan printed 80-82 (cache p081-p083, a text layer, page_offset +1). The entry opens on printed 80 under the section heading Republic of Japan & Mercenaries, and High-Tech O.C.C.s; printed 80 (cache p081) carries corrupt glyphs, so every number on it was read off a 200 dpi render. Printed 81 (cache p082) has no text (an illustration). The stat block (The False Cyber or Tech-Samurai O.C.C.) starts on printed 80 and continues on printed 82 from Electrical: Any through Money and Cybernetics: See above, after which printed 82 opens the Tech-Ninja O.C.C. || XP: the Cyber-Samurai column on printed 216 (cache p217), read off a render: 0 / 2,101 / 4,201 / 8,401 / 17,201 / 25,401 / 35,801 / 51,001 / 71,201 / 96,401 / 131,601 / 181,801 / 232,001 / 282,201 / 342,401. || GROUP: men-of-arms and men_of_arms: true, from the section heading (Mercenaries and High-Tech O.C.C.s) and the warrior text; the class states an M.D.C. main body of 180 as mdc_base. || ATTRIBUTES: requirements M.E. and M.A. 10; the book says the bionics CHANGE P.S. to 22, P.P. to 18 and Spd to 50. Stored as attribute_minimums, a floor: a natural roll above those figures is not lowered, which the book''s ''changed as follows'' would do. || SKILLS: Basic Radio is Radio: Basic 45+10; Basic Math is Mathematics: Basic 45+10; Language and Literacy: Japanese at 98% is Language: Native Tongue 98 and Literacy: Native Language at a flat 98; Language: American is a one-pick Language: Other at +10 (the catalog has no American row; a fixed Language: Other reads as a missing selection); Computer Programming 30+10; Horsemanship is Horsemanship: General 40+20; Wilderness Survival 30+5; Piloting two of choice +10% as a choose-2 over Pilot; W.P. Archery and Targeting as the two catalog rows W.P. Archery and W.P. Targeting. || HAND TO HAND: Karate or Jujitsu, as a choose-1. Zanji Shinjinken-Ryo at the cost of two other skills, priced in the hand_to_hand block. The book also sells Samurai Archery (in place of Archery and Targeting) for two other skills; there is no Samurai Archery catalog row, so that trade is prose in the W.P. Archery note. || RELATED: six, plus one at levels 3, 6, 9 and 12. Science Astronomy and Mathematics only, read as Astronomy and both Mathematics rows. || SECONDARY: the book prints three secondary skills at levels 1, 4, 8 and 12, read as three at each of those levels (the same reading the other Japan drafts give this sentence). || BIONICS: the four bionic features and up to five cybernetic implants are a player''s choice from two books, with no key to grant them; they are prose abilities. || EQUIPMENT: the book''s first armor is a high-tech Samurai mega-damage body armor of 1D6x10+60 M.D.C., which has a catalog row now (cyber-samurai-armor; samurai-armor is the True Samurai''s magic armor) that the choice does not list; the choice still offers the samurai-styled HA-5 and HA-7 first and then other Japan armor, per the book''s ''or one of the other types of armor available in Japan''. Ten high-tech arrows of choice are one choice of arrowhead type, quantity 10. The energy weapon of choice is offered from the Japan pistols and rifles. 1D4 E-clips as the generic e-clip row, since the matching pistol or rifle clip depends on the weapon. Two vibro-blades or ancient weapons as a choose-2. The S.D.C. daisho is daisho-rifts. Transportation: horse, hovercycle, jet pack or one of three motorcycles as a choice (BOOK-INGEST-AUDIT F139); the robot horse is a vehicles row with no gear row and is prose. Ammo pouches are in the utility belt note. Money: 2D6x1000 credits stored; the Black Market items and the monthly salary are prose."
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
   AND instr(markdown, 'the robot horse and motorcycle have no catalog rows') > 0
   AND length(markdown) = 13804;

-- == totem-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: totem-warrior
men_of_arms: true
name: Totem Warrior
system: rifts
source_book: Rifts World Book 15: Spirit West p.42-44
category: occ
tags: [combat, wilderness, shapeshifter]
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
occ_group: men-of-arms
attribute_requirements: { IQ: 9, ME: 9 }
starting_money: "3d6x100 in trade goods"
psionics:
  type: "minor"
  isp_base: "M.E. attribute + 1d6 per level of experience"
  powers_starting: 1
  categories_allowed:
    - { name: "Sensitive", except: ["Astral Projection", "Clairvoyance"] }
  powers_schedule:
    - { level: 3, count: 1 }
    - { level: 6, count: 1 }
    - { level: 9, count: 1 }
    - { level: 12, count: 1 }
    - { level: 15, count: 1 }
mdc_from_hp_sdc: true
ppe_base: "1d4x10 + P.E. attribute, +10 per level of experience"
bonuses:
  combat: { initiative: 2, strike: 1, disarm: 1, dodge: 1, roll: 1 }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The character''s native tribal language, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "English (American), at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One additional language of choice (+10%)." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book''s Tracking." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: Cowboy", base: 66, per_level: 3 }
    - { name: "Trick Riding", base: 0, per_level: 0 }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Cattle & Animals", base: 45, per_level: 5, note: "+15%. The book''s Lore: Animals/Cattle." }
    - { name: "Animal Husbandry", base: 45, per_level: 5, note: "+10%" }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book''s W.P. Archery and Targeting." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be upgraded to Martial Arts for one O.C.C. Related skill." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Cowboy", bonus: 5 }
      - { name: "Domestic", note: "The book prints +10% to Sing only; this catalog files Sing under Communications, which the class does not grant, so no Domestic skill takes a bonus." }
      - { name: "Espionage", except: ["Forgery", "Sniper"], bonus: 10 }
      - { name: "Horsemanship", note: "The book''s Pilot line allows horsemanship; this catalog files it as a category of its own." }
      - { name: "Medical", only: ["Holistic Medicine", "Brewing"], note: "The book prints +10% against Holistic Medicine only; the next line carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "+10% against Holistic Medicine only." }
      - { name: "Military", except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater", "Parachuting", "NBC Warfare"], bonus: 10 }
      - { name: "Physical", bonus: 10, note: "+10% where the skill carries a percentage." }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 5 }
      - { name: "Science", only: ["Astronomy", "Astronomy & Navigation", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10, note: "Art, language and lore skills only." }
      - { name: "Weapon Proficiencies", note: "Ancient weapons. A revolver or bolt-action rifle only with the G.M.''s leave, and never for a Pure One." }
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
totem: { from: "animal", powers: true }
special_abilities:
  - name: "Supernatural Attributes"
    description: "From the moment of infusion the Totem Warrior''s P.S. and P.E. are supernatural even in human form: the P.S. does supernatural damage, and the supernatural P.E. makes him a mega-damage creature - his combined S.D.C. and hit points become an M.D.C. total. He bio-regenerates 5D6 of it per 24 hours."
  - name: "Animal Totem"
    description: "Must pick one animal totem, whose skills and bonuses he has in human form; in giant animal form he also gains that totem''s Totem Warrior powers, which only this class can draw on. Most pick a predator or a medium to large animal. The totems, with their skills, bonuses and powers, are printed 96-105. Chosen in the wizard from the shared totems catalog; see BOOK-INGEST-AUDIT.md F56."
  - name: "Animal Totem Form"
    description: "Transforms into his totem species in two versions. Normal size: an ordinary-looking animal with its natural abilities, keeping his mind and his mega-damage body but none of the totem powers - for spying, sneaking and escape. Giant: two or three times normal size for medium and large animals, ten times for small ones such as birds and mice, with every totem power. Either form costs 10 P.P.E. to assume, going from small to giant another 10, returning to human form 5; the animal form lasts indefinitely, and he can speak any language he knows."
  - name: "Animal Psionic Senses"
    description: "In animal form he has the predator''s innate ability to sense psychic and magic energy and supernatural beings, as a Dog Boy does, constantly and at no I.S.P. cost."
  - name: "Limited Magic"
    description: "Kinship with his Totem Spirit gives him the equivalent of Fear (5 P.P.E.), Repel Animals (7 P.P.E.), and summoning and controlling animals of his own totem species, 1D4 per level (50 P.P.E.)."
equipment_starting:
  - { choose: 1, label: "minor fetish", qty: 1, from: ["armor-fetish", "body-fetish", "climbing-fetish", "damage-fetish", "ear-fetish", "healing-fetish", "heritage-and-self-fetish", "luck-fetish", "porcupine-quill-fetish", "prowl-fetish", "song-fetish", "speed-fetish", "strength-fetish", "sure-footedness-fetish", "swimming-fetish", "tooth-and-claw-fetish-minor", "tracking-fetish", "wind-wing-fetish"] }
  - { choose: 1, label: "major hunting or combat fetish", qty: 1, from: ["supernatural-damage-fetish", "great-armor-fetish", "great-body-fetish", "great-ear-fetish", "great-speed-fetish", "great-tracking-fetish", "superhuman-strength-fetish", "great-tooth-and-claw-fetish", "weapon-fetish", "wing-flight-fetish", "tattoo-war-fetish", "tattoo-steady-hand-fetish"] }
  - { choose: 1, label: "extra set of clothes", qty: 1, from: ["buckskin-clothing", "traveling-clothes", "dress-clothing"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "canteen or waterskin", qty: 1, from: ["canteen", "water-skin"] }
  - { item_id: "animal-snare", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "knife", qty: 2 }
  - { item_id: "hooded-cloak", qty: 1, note: "The book prints a hat or hooded cloak." }
  - { item_id: "rope-per-20-feet-6-m", qty: 3, note: "50 feet (15 m); the row is sold per 20 feet." }
  - { item_id: "food-rations", qty: 1, note: "One week of dried meat and fruit." }
  - { item_id: "wooden-spear", qty: 1, note: "The book prints a spear or bow and arrows; the bow is not stored." }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Must be of Native American descent: printed 43 says other races lack the spirit potential for totems or fetishes."
  - "Characters who are not devoted Traditionalists or Pure Ones receive none of the starting fetishes."
  - "Technical related skills are limited to art, language and lore skills."
  - "Cybernetics: none, and will never consider any, with the possible exception of bio-systems to repair grievous injury."
extraction_notes: "Rifts World Book 15: Spirit West printed 42-44, read from the text layer. No hit point or S.D.C. formula is printed, so compose.js supplies both (3D6 S.D.C. as a man of arms); the book then converts the combined S.D.C. and hit points into M.D.C., which mdc_from_hp_sdc: true does: both are rolled as usual and stored as one M.D.C. maximum (BOOK-INGEST-AUDIT F62). P.P.E. prints as !D4xlO+P.E., the digit substitution of BOOK-INGEST-AUDIT F53, read as 1D4x10; the trade goods read as 3D6x100. Psionics: the book states no tier; minor is stored because the class gains one Sensitive power at levels 1, 3, 6, 9, 12 and 15 and no more, never Astral Projection or Clairvoyance. The major starting fetish is any hunting or combat one, typically a damage fetish; the list offered is that reading of the book''s phrase, with the Supernatural Damage Fetish first. The Medical line carries the +10% the book prints against Holistic Medicine, on a second Medical entry limited to that skill. The Domestic line loses its +10%, printed against Sing, because this catalog files Sing under Communications, which the class does not grant; that is under-granted and said so on the line rather than over-granted. The totem pick is the class''s totem key with powers: true, so the sheet shows the chosen animal''s Totem Warrior powers (BOOK-INGEST-AUDIT.md F56). Equipment not stored stays in the body; the hooded cloak, rope, rations and spear were granted under BOOK-INGEST-AUDIT F139."
---

# Totem Warrior

**Alignments.** Any, but selfish alignments are the rarest.

Unlike a Shaman, who shares his spirit potential with the spirits, the Totem
Warrior permanently trades a small part of his own for a part of a Greater Totem
Spirit''s life essence - always the spirit of his chosen totem animal. It makes
him more than human: a supernatural being in human form who can take the shape
of his totem, without losing his own mind or will. Some non-Indians call the
class Indian Knights.

The most free-roaming of the Native American O.C.C.s, Totem Warriors range from
Mexico to Alaska, fighting vampires, Xiticix, dragons, demons and evil sorcerers,
and are the most likely of all to be guided by visions from their Totem Spirits.

## Fetishes

Totem Warriors start with one minor fetish of choice and one major hunting or
combat fetish, typically a damage fetish. Further minor fetishes are typically
awarded at levels 3, 6 and 10, a second major one at level 6, and another for
great heroism no sooner than level 9.

## Lore

Totem Warriors remain mostly male (printed 37). Printed 84 sets the limit on
what they trade: no more than three-quarters of a person''s spirit potential can
ever be replaced by another spirit''s, and the Totem and Spirit Warriors stand
close to that line. Past it, the book says, a person becomes a mindless and evil
fusion of man and spirit - which is where some of its monsters come from.

## Equipment not stored

A pair of tomahawks (two knives are stored as that choice), the bow and
arrows offered instead of the spear, a war club, soft moccasins, a hat instead
of the hooded cloak, and war and camouflage paint. The cloak, 50 feet of rope,
a week of dried meat and fruit and the spear are stored. Weapons are few, since the warrior can
become a supernatural animal.
',
       updated_at = datetime('now')
 WHERE class_id = 'totem-warrior'
   AND instr(markdown, 'Equipment the catalog cannot hold yet') > 0
   AND length(markdown) = 11208;

-- == paradox-shaman ==
UPDATE imported_classes
   SET markdown = '---
id: paradox-shaman
men_of_arms: false
name: Paradox Shaman
system: rifts
source_book: Rifts World Book 15: Spirit West p.62-65
category: occ
tags: [divine, hunter]
xp_table: [0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001]
occ_group: magic
starting_money: "2d6x100 in trade goods"
magic:
  type: "spell"
  spells: ["Absolute Darkness", "Little Force", "Will of the Earth", "Sphere of Negation", "Universal Balance"]
  spells_starting: 5
  spells_from: ["Anti-Magic Cloud", "Armor of Ithan", "Astral Projection", "Banishment", "Close Rift", "Commune with Spirits", "Constrain Being", "Control & Enslave Entity", "Dimensional Portal", "Dispel Magic Barriers", "Energy Bolt", "Energy Disruption", "Energy Field", "Escape", "Exorcism", "Fly", "Ley Line Transmission", "Life Drain", "Locate", "Magic Pigeon", "Mystic Portal", "Negate Magic", "Protection Circle: Simple", "Protection Circle: Superior", "Sanctum", "See Aura", "See the Invisible", "Sense Magic", "Shadow Meld", "Teleport: Lesser", "Teleport: Superior", "Time Hole", "Time Slip", "Tongues", "Trance"]
  spell_lists:
    P: ["Anti-Magic Cloud", "Armor of Ithan", "Astral Projection", "Banishment", "Close Rift", "Commune with Spirits", "Constrain Being", "Control & Enslave Entity", "Dimensional Portal", "Dispel Magic Barriers", "Energy Bolt", "Energy Disruption", "Energy Field", "Escape", "Exorcism", "Fly", "Ley Line Transmission", "Life Drain", "Locate", "Magic Pigeon", "Mystic Portal", "Negate Magic", "Protection Circle: Simple", "Protection Circle: Superior", "Sanctum", "See Aura", "See the Invisible", "Sense Magic", "Shadow Meld", "Teleport: Lesser", "Teleport: Superior", "Time Hole", "Time Slip", "Tongues", "Trance"]
  spells_schedule:
    - { level: 2, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
ppe_base: "2d4x10+40 + P.E. attribute, +2d6 per level of experience"
bonuses:
  combat: { initiative: 2 }
  saves: { illusionary_magic: 2, psionics: 2, harmful_drugs: 2, horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The character''s native tribal language, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "English (American), at 98%." }
    - { choose: 4, from: ["Language: Other"], bonus: 20, note: "Four additional languages of choice (+20%). Taken once per language - the picker asks which." }
    - { choose: 4, from: ["Literacy: Other"], bonus: 10, note: "Literate in four languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: American Indians", base: 55, per_level: 5, note: "+30%. The book''s Lore: Indians." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 50, per_level: 5, note: "+15%. One instrument of choice." }
    - { name: "Disguise", base: 35, per_level: 5, note: "+10%" }
    - { name: "Escape Artist", base: 45, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 40, per_level: 4 }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book''s Track Humanoids." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book''s W.P. Archery and Targeting." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be upgraded to Expert for one O.C.C. Related skill, or to Martial Arts for two." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", note: "Sniper, if taken, is with bow and arrow or spear." }
      - { name: "Horsemanship", note: "The book''s Pilot line allows horsemanship; this catalog files it as a category of its own." }
      - { name: "Military", except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater", "Parachuting", "NBC Warfare"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak"] }
      - { name: "Rogue", only: ["Streetwise", "Palming", "Seduction"], bonus: 6 }
      - { name: "Science", only: ["Astronomy", "Astronomy & Navigation", "Anthropology", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 15 }
      - { name: "Technical", bonus: 15, note: "Art, language and lore skills only." }
      - { name: "Weapon Proficiencies", note: "Ancient weapons. A revolver or bolt-action rifle only with the G.M.''s leave, and never for a Pure One." }
      - "Wilderness"
  secondary_skills:
    count: 1
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
totem: { from: "animal" }
special_abilities:
  - name: "Memories of Earth"
    description: "Knows the true memories of the Earth''s past; a relevant snippet surfaces on a d20 roll of 16 or higher. Seen broadly - key people and events, never passwords or bank accounts - never written down, and never used for gain, to hurt others or to fuel hatred."
  - name: "Sense Rifts"
    description: "Automatically senses the opening, closing and location of dimensional Rifts within 50 miles (80 km)."
  - name: "Sense Dimensional Disturbances"
    description: "Automatically senses Rifts opening or closing, dimensional envelopes, mystic portals, dimensional teleportation and time holes within one mile (1.6 km)."
  - name: "See Dimensional Effects"
    description: "Sees dimensional envelopes and pockets, fourth- and two-dimensional beings, astral travellers, and the invisible energy essence of alien intelligences and entities."
  - name: "Ley Line Phasing"
    description: "Identical to the Ley Line Walker''s ability of the same name."
  - name: "Impervious to Possession"
    description: "Cannot be possessed."
  - name: "Temporal Magic (not held)"
    description: "Printed 64 lets the Paradox Shaman take Rifts England''s temporal spells (England p.74-83) in place of any pick from the list. Only the listed spells are offered here."
  - name: "Fetish Gifts"
    description: "Cannot make fetishes. Instead is given them: at level one the Heritage & Self and Great Body Fetishes, at level two a legendary Spirit Bow, at five a great fetish of choice, at ten a great fetish or a second legendary spirit weapon (typically a tomahawk or large battle axe), and at fifteen the legendary Cosmic Awareness Fetish."
  - name: "Animal Totem"
    description: "Every Shaman picks one totem animal and gains its skills and bonuses, though never its Totem Warrior powers. The totems are printed 96-105. Chosen in the wizard from the shared totems catalog; see BOOK-INGEST-AUDIT.md F56."
  - name: "Shaman''s Secret Tongue"
    description: "Speaks the secret tongue by which Shamans recognize one another and talk unheard (printed 49)."
equipment_starting:
  - { item_id: "heritage-and-self-fetish", qty: 1 }
  - { item_id: "great-body-fetish", qty: 1 }
  - { item_id: "spirit-weapon-fetish", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "canteen or waterskin", qty: 1, from: ["canteen", "water-skin"] }
  - { item_id: "knife", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { choose: 1, label: "hooded cloak or robe", qty: 1, from: ["hooded-cloak", "hooded-robe"] }
  - { item_id: "rope-per-20-feet-6-m", qty: 3, note: "50 feet (15 m); the row is sold per 20 feet." }
  - { item_id: "food-rations", qty: 1, note: "One week: dried meat, fruits and nuts." }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Must be of Native American descent and a Traditionalist or Pure One (printed 64)."
  - "Cannot make fetishes."
  - "Technical related skills are limited to art, language and lore skills."
  - "Cybernetics: none, and will never consider any, with the possible exception of bio-systems to repair grievous injury."
extraction_notes: "Rifts World Book 15: Spirit West printed 62-65, read from the text layer. No hit point or S.D.C. formula is printed, so compose.js supplies both (1D6 S.D.C. as a practitioner of magic). P.P.E. prints as 2D4xlO+40 and trade goods as 2D6xlOO, read as 2D4x10+40 and 2D6x100 (BOOK-INGEST-AUDIT F53). Spells: all five Shamanistic Paradox spells are granted outright; five more at level one and three per level after come from the printed 64 list of 35, of any level. The book also allows Rifts England''s temporal magic for any of those picks. The catalog holds 25 temporal spells now (tradition temporal, names prefixed Temporal: , Rifts Book of Magic p.244-251); the class does not grant or list them and still offers the printed 64 list only, on the Time Master precedent from phase-world batch 9. Two list names use the catalog''s spelling: Control & Enslave Entity and Dispel Magic Barriers. THE BOOK CONTRADICTS ITSELF ON THE SPIRIT BOW: printed 64''s fetish list gives it at level two, and printed 65''s standard equipment lists a Spirit Bow among the starting weapons; the stat block is followed and it is starting equipment. The +1 to save vs horror factor at levels 1, 3, 4, 5, 7, 8, 9, 11, 13 and 15 is stored as +1 base and one step at each later level. Impervious to possession has no save field and is an ability. The totem pick is the class''s totem key, chosen from the shared totems catalog (BOOK-INGEST-AUDIT.md F56)."
---

# Paradox Shaman

**Alignments.** Any, but the spirits tend to avoid selfish people.

Originally called androgyne shamans: they embody the primal forces of the
universe before creation divided them into light and dark, man and woman, earth
and sky, and many live as symbolically sexless. Considered the most powerful of
Shamans, mediums between Earth, Sky and the Middle World, they tap primal forces
that at high levels can even touch time - nearly the equal of the Temporal
Raiders of Rifts England, whose abuses they oppose.

## Lore

Every Paradox Shaman carries a legendary Spirit Bow, the sign of a duty to
protect the Native American people and every other people from dimensional
horrors. Most wander the continent closing Rifts and fighting supernatural evil,
Temporal Raiders, the Splugorth and the Naruni, and they will help any sentient
being afflicted by a dimensional anomaly, whatever its race.

## Equipment not stored

Ceremonial garments and a headdress or animal skin, moccasins, a musical
instrument of choice, a hand axe and flint. The hooded cloak or robe, 50 feet
of rope and a week of dried food are stored. Two S.D.C. weapons of choice, a silver-plated tomahawk, a
mallet, 3D4 wooden stakes and a silver cross.
',
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, 'Equipment the catalog cannot hold yet') > 0
   AND length(markdown) = 15549;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-thief' AND instr(markdown, '"t-40-urban-standard-vest"') > 0)
    OR (class_id = 'gypsy-wizard-thief' AND instr(markdown, '"t-40-urban-standard-vest"') > 0)
    OR (class_id = 'gypsy-seer' AND instr(markdown, '"t-40-urban-standard-vest"') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, '"t-40-urban-standard-vest"') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, '"road-boss-motorcycle"') > 0)
    OR (class_id = 'totem-warrior' AND instr(markdown, 'item_id: "wooden-spear"') > 0)
    OR (class_id = 'paradox-shaman' AND instr(markdown, 'label: "hooded cloak or robe"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-thief' AND instr(markdown, 'and the armour stays prose.') > 0)
    OR (class_id = 'gypsy-wizard-thief' AND instr(markdown, 'and the armour stays prose.') > 0)
    OR (class_id = 'gypsy-seer' AND instr(markdown, 'and the armour stays prose.') > 0)
    OR (class_id = 'gypsy-gifted' AND instr(markdown, 'and the armour stays prose.') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, 'the robot horse and motorcycle have no catalog rows') > 0)
    OR (class_id = 'totem-warrior' AND instr(markdown, 'Equipment the catalog cannot hold yet') > 0)
    OR (class_id = 'paradox-shaman' AND instr(markdown, 'Equipment the catalog cannot hold yet') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gypsy-thief', 'gypsy-wizard-thief', 'gypsy-seer', 'gypsy-gifted', 'cyber-samurai', 'totem-warrior', 'paradox-shaman') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~199-book-ingest-audit-f139-plain-grants-b.sql');
