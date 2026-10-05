-- Correct sentences the close-out's claim sweep found false, part 2 of 2
-- 13 classes, each replaced whole: russian-mystic-kuznya, merchant, psi-x-alien, amana, arac, chasseur-vert, forest-warden, squilb, vernulian, oni-of-the-one-hundred, amphib, gene-splicer-mutant, phase-world-alien.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~171-closeout-claim-sweep-part-2.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The close-out's final claim sweep, part 2 of 2; ~170 carries the account.

-- == russian-mystic-kuznya ==
UPDATE imported_classes
   SET markdown = '---
id: russian-mystic-kuznya
name: Russian Mystic Kuznya
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.118-125
category: occ
tags: [combat]
occ_group: magic
xp_table: [0, 2081, 4161, 8801, 18001, 33001, 48001, 65001, 90001, 120001, 150001, 200001, 250001, 300001, 400001]
attribute_requirements: { IQ: 9, ME: 12, PE: 14 }
mdc_base: "P.E. x3 as the base M.D.C., plus 2d6 M.D.C. per level of experience"
ppe_base: "1d4x10+25, and 1d6+15 more per level of experience"
starting_money: "3d6x1000"
skills:
  hand_to_hand: { costs: { martial_arts: 2 } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 30, note: "The book prints ''Basic Math (+30%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%" }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: one of choice (+10%)" }
    - { name: "Field Armorer & Munitions Expert", bonus: 30, note: "The book prints ''Armorer (Field Armorer; +30%)''." }
    - { name: "Recognize Weapon Quality", bonus: 30, note: "Recognize Weapon Quality (+30%)" }
    - { name: "General Repair & Maintenance", bonus: 15, note: "The book prints ''General Repair/Maintenance (+15%)''." }
    - { name: "Find Contraband", bonus: 10, note: "Find Contraband (+10%)" }
    - { name: "Cook", bonus: 10, note: "Cook (+10%)" }
    - { name: "Art", bonus: 10, note: "Art (+10%)" }
    - { name: "Prospecting", bonus: 10, note: "Prospecting (+10%)" }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { name: "Gemology", base: 50, per_level: 5, note: "A SPECIAL O.C.C. SKILL. The book gives the Mystic Kuznya its own base - 50% +5% per level - where the catalog row is 25%. `base` fixes the percentage for this class without disturbing the catalog, which is what that field is for. Identifying fakes is at -10%." }
    - { name: "Metalwork and Forge", base: 60, per_level: 3, note: "A SPECIAL O.C.C. SKILL this book defines, 60% +3% per level. A success means a superior item: an S.D.C. weapon gains +1 strike, +1 parry and +1D6 damage; metal S.D.C. armour gains +1 A.R. and 40% more S.D.C. at no extra weight; craft goods command 50-100% more, 5-10x if exquisite." }
    - { name: "Shape, Engrave, Etch & Emboss Metal", base: 70, per_level: 3, note: "A SPECIAL O.C.C. SKILL this book defines, 70% +3% per level. Decorative metalwork - inlay, etching, embossing, gem-setting, high polish - in any metal from iron to gold." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot Skill: one of choice (+10%); may select Horsemanship." }
    - { name: "W.P. Blunt", note: "W.P. Ancient: Blunt" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. three Ancient of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapon, one of choice (any)." }
    - { name: "Hand to Hand: Expert", note: "Expert to start, and can be changed to Martial Arts - NEVER Assassin - for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive Mechanics only (+5%)" }
      - { name: "Medical", only: ["First Aid"], note: "First Aid only." }
      - "Military"
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft - Horsemanship is most likely." }
      - "Pilot Related"
      - { name: "Science", note: "+10% on chemistry skills" }
      - { name: "Science", only_prefix: ["Chemistry"], bonus: 10, note: "+10% on chemistry skills." }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "+5%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
magic:
  type: "spell"
  spells:
    - "Ignite Fire"
    - "Fuel Flame"
    - "Extinguish Fire"
    - "Superhuman Strength"
    - "Manipulate Objects"
    - "Deflect"
    - "Ricochet Strike"
    - "Implosion Neutralizer"
    - "Create Steel"
    - "Power Weapon"
    - "Speed Weapon"
    - "Enchant Weapon (Minor)"
bonuses:
  attributes: { PE: 2, ME: "1d4", MA: "1d4" }
  combat: { initiative: 1, strike: 1, parry: 1, disarm: 1, pull_punch: 6 }
  saves: { horror_factor: 2, possession: 2 }
special_abilities:
  - name: "The Mettle of Kuznya Sorcery"
    description: "The magic of the Mystic Smith transforms them into creatures not unlike metal - lesser M.D.C. beings with P.E. x3 as base M.D.C. plus 2D6 M.D.C. per level. The cost is that their skin is as hard and cold as steel."
  - name: "Limited Invulnerability"
    description: "Impervious to S.D.C. weapons and to natural cold, heat and fire. MAGICAL FIRE DOES FULL DAMAGE and magical cold does half. All M.D. weapons, explosives and energy blasts inflict full damage."
  - name: "Supernatural P.S."
    description: "Roll the P.S. attribute as usual, then ADD 1D6+12 and make it supernatural. Punches and kicks inflict M.D. and the smith can carry 100x his P.S. in pounds. A rolled attribute bonus, which no bonuses field can hold, so it is recorded here."
  - name: "Rolled O.C.C. bonuses"
    description: "+1D4 to M.E. and +1D4 to M.A., on top of the fixed +2 to P.E. carried in bonuses. Both are rolled by the sheet, from bonuses."
  - name: "A closed spell list"
    description: "The Mystic Kuznya does not know spell magic or cast spells in the ordinary sense, other than a handful of weapon-related ones; the true power is creating magic weapons and items from metal. The twelve spells granted above are the whole of it - THE BOOK STATES OUTRIGHT THAT NO OTHER SPELLS CAN BE LEARNED, which is why this class has no spell gate, no per-level growth and no tradition."
  - name: "P.P.E. from ley lines only"
    description: "Additional P.P.E. can be drawn from ley lines and from P.P.E. willingly offered, but NO KUZNYA CAN DRAW P.P.E. FROM BLOOD SACRIFICES - the magic will not work with death energy. That is a restriction the other casters in this book do not share."
  - name: "Magical Equipment"
    description: "Every Mystic Kuznya carries an indestructible giant sledgehammer, three indestructible hammers of gold, three indestructible tongs of gold, and a full suit of M.D.C. chain mail. They are both weapons and the tools for making magic metal items."
restrictions:
  - "Any alignment EXCEPT miscreant or diabolic, and even anarchist is rare (5%). Most are principled (32%), scrupulous (31%), unprincipled (23%) or aberrant (9%)."
  - "RACIAL RESTRICTION: HUMANS ONLY, 35% of them female. Also known as the Hands of Svarog."
  - "PSIONICS: NONE. The book is emphatic - any psychic abilities that might have developed are consumed fuelling Kuznya magic and the superhuman abilities."
  - "No other spells can be learned, ever. The twelve granted are the entire repertoire."
  - "No Kuznya can draw P.P.E. from blood sacrifices; the magic will not work with death energy."
  - "Hand to Hand: Expert to start, and it can be raised to Martial Arts but NEVER to Assassin."
  - "Cybernetics: none, and the character avoids them like the plague because they interfere with magic."
  - "The character also starts with 3D6x1000 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only. The book prices the coin in credits OR RUBLES."
  - "Do not roll Hit Points or S.D.C. for this class - it is an M.D.C. being from creation."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.118-125. THIS CLASS FALSIFIES THE SURVEY''S ''ZERO NEW SKILLS'' READING, and it is the caveat that survey carried from spirit-west firing exactly as written: the book has no new-skills SECTION, which is what the zero was measured from, but it defines skills inside a class. Three are Special O.C.C. Skills with their own percentages. Gemology already exists in the catalog at 25%; the book gives this class 50% +5%, so `base` fixes it here without disturbing the row. Metalwork and Forge (60% +3%) and Shape, Engrave, Etch & Emboss Metal (70% +3%) do not exist and are created, filed Technical beside Gemology, Art and Prospecting. Their percentages come from the page, not from a convention. THE SPELL LIST IS CLOSED - twelve named spells and the book says no others can ever be learned - so there is no gate, no per-level growth and no tradition on this class; it is the only caster in the book shaped that way. The book''s ''Enchant Weapon'' is stored as the catalog''s Enchant Weapon (Minor), the only row of that name here. Three attribute bonuses are ROLLED (+1D6+12 supernatural P.S., +1D4 M.E., +1D4 M.A.): the M.E. and M.A. dice are stored in bonuses and rolled by the sheet, and the P.S. is still only on its ability; the fixed +2 to P.E. is in bonuses. Four skill names needed the catalog''s spelling: Armorer (Field Armorer) is Field Armorer & Munitions Expert, General Repair/Maintenance is General Repair & Maintenance, W.P. Ancient: Blunt is W.P. Blunt, and Basic Math is Mathematics: Basic."
---

# Russian Mystic Kuznya

## Lore

"Kuznya" is Russian for smith. The Mystic Kuznya are men and women with
supernatural powers and the ability to forge superior metal weapons - and a
number of magic ones. These are not Techno-Wizard devices but melee weapons of
metal and magic, said to be empowered by Svarog the Divine, Highest of the Gods
and the first Mystic Kuznya.

The magic transforms the smith into something not unlike metal: a lesser
Mega-Damage being, invulnerable to ordinary weapons and to natural fire and
cold, with skin as hard and cold as steel. They can forge any metal object, from
nails and horseshoes to swords and chalices, in a tenth the time an ordinary
smith would take on a worse item.

## Alignment

Any except miscreant or diabolic, and even anarchist is rare. Most are
principled or scrupulous.

## GM Notes

This is the book''s odd caster. It has twelve spells and will never have
thirteen - the book says so outright - because its power is not casting but
making. Its P.P.E. is large and grows fast, and it exists to be spent on metal.

It is also the one caster here that cannot draw P.P.E. from blood sacrifice at
all: the magic will not work with death energy, which places it squarely
opposite the Necromancer and the Night Witch.
',
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, 'and are prose; the fixed +2 to P.E. is in bonuses') > 0
   AND length(markdown) = 10930;

-- == merchant ==
UPDATE imported_classes
   SET markdown = '---
id: merchant
men_of_arms: false
occ_group: optional
xp_table: [0, 1851, 3701, 7401, 13001, 22001, 33001, 47001, 66001, 91401, 131501, 171601, 221701, 272801, 326901]
name: Merchant
system: palladium-fantasy
source_book: palladium-fantasy-core p.96-96
category: occ
tags: [leader]
attribute_requirements: { IQ: 10 }
starting_money: "200"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Two languages of choice (+10% each)" }
    - { name: "Literacy", base: 40, per_level: 5, note: "One language of choice, usually native or elf (+10%)" }
    - { name: "Public Speaking", base: 40, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of two other skills, or to Martial Arts for the cost of three." }
  occ_related_skills:
    count: 10
    categories:
      - { name: "Communications", bonus: 10, note: "+10%" }
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Carpentry", "Preserve Food", "Land Navigation"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4+2" }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "wine-good", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 2 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "oil-lantern-6-hours-1-pint", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "hard-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is hard leather (A.R. 11, 30 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "Starting weapons are basic S.D.C. weapons of fair to good quality, a grade below what the men of arms carry. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "Multiple O.C.C.s are possible for this character, so long as the attribute requirements of each are met."
extraction_notes: "The Merchant''s Armor, Weapons and Money lines print in the third column of the page, directly below the Assassin''s three, with no heading between them; they are attributed by the notebook and quill-pen kit and the fair-to-good weapon grade, against the Assassin''s studded leather and wide weapon familiarity. The book says a bare hat, blanket, notebook and small lantern where the catalog prices several of each, so the plainest row is granted in every case. Food rations are catalogued by the week and the book gives 1D4 weeks, so the quantity is the roll. Two weapons of choice enumerate the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category. Multiple O.C.C.s are prose only: the character model stores one occupation. (A race beside an occupation is held, as a second class id; a second OCCUPATION is not.)"
---

# Merchant

## Lore

A character with a background in trade, typically a small-time businessman or
from a family involved in business. Most became adventurers to make a fortune in
the world or to find a new profitable venture; others simply gave up a
sedentary and restrictive life behind a counter for the road.

The merchant is the Palladium world''s other kind of competence: numerate,
literate, persuasive, and able to hold a room. What he does not have is
training. His hand to hand is the basic grade, his weapons are fair to good
rather than very good, and upgrading either costs him two or three of the
skills that make him a merchant in the first place.

## Alignment

Any.

## GM Notes

This is one of the book''s Optional O.C.C.s, offered for players who want a
character whose competence is not martial. It is also the only class in the
chapter that explicitly permits stacking: "Multiple O.C.C.s are possible as long
as the character has the required attributes."
',
       updated_at = datetime('now')
 WHERE class_id = 'merchant'
   AND instr(markdown, 'which is the same limitation an R.C.C. plus O.C.C. runs into') > 0
   AND length(markdown) = 6174;

-- == psi-x-alien ==
UPDATE imported_classes
   SET markdown = '---
id: psi-x-alien
name: Psi-X Alien
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.166-168
category: rcc
tags: []
xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6"
  MA: "2d6"
  PS: "2d4+4"
  PP: "2d4+4"
  PE: "2d4+1"
  PB: "2d4+2"
  Spd: "2d6+4"
hit_points_base: "P.E. x2 + 1d6 per level"
sdc_base: "2d6+2"
ppe_base: "P.E. x10"
starting_money: "3d6x100"
psionics:
  type: "master"
  powers: ["See Aura", "Sense Magic", "Detect Psionics", "Bio-Regeneration"]
bonuses:
  combat: { attacks_base: 1 }
  saves: { horror_factor: 5, illusionary_magic: 5 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { choose: 2, from: ["Language: Other"], bonus: 48, note: "Speaks two languages of choice at 98%: stored as +48% on the catalog base of 50%, which is 98% at level one. Taken once per language - the picker asks which." }
  secondary_skills:
    count: 4
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
equipment_starting:
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "energy-weapon-of-choice", qty: 1, note: "One energy weapon of choice; the Psi-X prefer light, rapid-fire energy weapons or magic items." }
  - { item_id: "e-clip", qty: "1d4", note: "1D4 additional E-clips for the weapon." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "protective-goggles", qty: 1, note: "Protective eye goggles; the Psi-X must keep tinted coverings over the eyes in daylight." }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says universal translator." }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "Cigarette lighter." }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "clothing", qty: 2, note: "A couple sets of clothing, and some personal items." }
natural_abilities:
  - { name: "Size and Life Span", description: "Weight 90 to 130 lbs (40.5 to 58.5 kg). Height 4 to 5.6 feet (1.2 to 1.7 m). Average life span 1D6x10+170 years; physical maturity comes around age 20. Completely hairless, with a huge head, large dark eyes and a small, slight frame. P.B. is by human standards." }
  - { name: "Psi-X Vision", description: "Nightvision 3000 ft (914 m), hawk-like color vision, sees the infrared and ultraviolet spectrums of light, sees electromagnetic energy, and sees the invisible as an automatic ability (including Astral beings, entities and energy beings)." }
  - { name: "Psi-Powers of Every Psi-X", description: "See Aura, Sense Magic, Detect Psionics and Bio-Regeneration (healing), on top of the powers rolled on the random psi-power table." }
  - { name: "Telekinetic Hover", description: "A unique, telekinesis related ability to hover and move 1-4 feet (0.3 to 1.2 m) above the ground instead of walking. It is the natural mode of travel, at the same speed as the Spd attribute; the Psi-X has to concentrate to negate it and walk on its own two legs. It costs no I.S.P." }
  - { name: "Attacks Per Melee Round", description: "One physical attack at levels 1, 2, 4, 8 and 12, OR two attacks via psionics at levels 1, 3, 6, 10 and 15. The physical ladder is the one counted on the sheet; the psionic ladder (2 at level 1, 4 at level 3, 6 at level 6, 8 at level 10, 10 at level 15) is tracked by hand." }
  - { name: "M.A. and Alignment", description: "M.A. is 2D6, +2 if the character is of a good alignment (added by hand)." }
special_abilities:
  - { choose: 1, from: ["Psi-Powers (01-12): Kineticist", "Psi-Powers (13-24): Psychic Sensitive", "Psi-Powers (25-37): Psychic Energy Conduit", "Psi-Powers (38-49): Psychic Intuitive", "Psi-Powers (50-61): Psychic Spiritualist", "Psi-Powers (62-73): Psychic Manipulator", "Psi-Powers (74-85): Healer", "Psi-Powers (86-97): Closed Mind", "Psi-Powers (98-00): Mind Melter"], note: "Random Psi-Powers: roll percentile dice and take the entry rolled." }
  - name: "Psi-Powers (01-12): Kineticist"
    description: "Roll 01-12. Has all kinesis abilities, including Telekinesis (Super), Telekinetic Acceleration Attack, Telekinetic Force Field, Telekinetic Leap, Telekinetic Lift, Telekinetic Punch, Telekinetic Push, Levitation, Electrokinesis, Hydrokinesis and Pyrokinesis. The eleven named powers and ordinary Telekinesis are granted; any other kinesis power is the G.M.''s call."
    psionics:
      type: "master"
      powers: ["Telekinesis", "Telekinesis (Super)", "Telekinetic Acceleration Attack", "Telekinetic Force Field", "Telekinetic Leap", "Telekinetic Lift", "Telekinetic Punch", "Telekinetic Push", "Levitation", "Electrokinesis", "Hydrokinesis", "Pyrokinesis"]
  - name: "Psi-Powers (13-24): Psychic Sensitive"
    description: "Roll 13-24. All Sensitive abilities, including Empathic Transmission, all at double the normal range and duration (the doubling is applied by hand)."
    psionics:
      type: "master"
      powers: ["Astral Projection", "Clairvoyance", "Commune with Spirit", "Empathy", "Intuitive Combat", "Machine Ghost", "Mask I.S.P. & Psionics", "Mask P.P.E.", "Meditation", "Object Read (Psychometry)", "Presence Sense", "Read Dimensional Portal", "Remote Viewing", "See Aura", "See The Invisible", "Sense Dimensional Anomaly", "Sense Evil", "Sense Magic", "Sense Time", "Sixth Sense", "Speed Reading", "Telepathy", "Total Recall", "Empathic Transmission"]
  - name: "Psi-Powers (25-37): Psychic Energy Conduit"
    description: "Roll 25-37. Psi-Sword, Psi-Shield, Electrokinesis, Pyrokinesis, Mind Bolt, Summon Inner Strength and Impervious to Fire (even mega-damage fire)."
    psionics:
      type: "master"
      powers: ["Psi-Sword", "Psi-Shield", "Electrokinesis", "Pyrokinesis", "Mind Bolt", "Summon Inner Strength", "Impervious to Fire"]
  - name: "Psi-Powers (38-49): Psychic Intuitive"
    description: "Roll 38-49. Clairvoyance, Intuitive Combat, Object Read, Presence Sense, Psychic Diagnosis, Read Dimensional Portal, Sense Dimensional Anomaly, Sense Evil, Sense Magic, Sense Time, Sixth Sense and Telemechanics."
    psionics:
      type: "master"
      powers: ["Telemechanics", "Clairvoyance", "Object Read (Psychometry)", "Presence Sense", "Sense Evil", "Sense Magic", "Sixth Sense", "Psychic Diagnosis", "Intuitive Combat", "Read Dimensional Portal", "Sense Dimensional Anomaly", "Sense Time"]
  - name: "Psi-Powers (50-61): Psychic Spiritualist"
    description: "Roll 50-61. Astral Projection (+20% to find the way home), Clairvoyance, Commune with Spirits, Ectoplasm, Object Read, Psychic Omni-Sight, See Aura and Telepathy."
    psionics:
      type: "master"
      powers: ["See Aura", "Clairvoyance", "Object Read (Psychometry)", "Telepathy", "Astral Projection", "Ectoplasm", "Commune with Spirit", "Psychic Omni-Sight"]
  - name: "Psi-Powers (62-73): Psychic Manipulator"
    description: "Roll 62-73. Bio-Manipulation, Deaden Pain, Empathic Transmission, Empathy, Hypnotic Suggestion, Increased Healing, Induce Sleep, Mentally Possess Others, Mind Wipe, Psychic Purification, Psychosomatic Disease, Radiate Horror Factor, Stop Bleeding, Telemechanic Mental Operation and Telepathy."
    psionics:
      type: "master"
      powers: ["Empathic Transmission", "Empathy", "Telepathy", "Hypnotic Suggestion", "Mentally Possess Others", "Mind Wipe", "Induce Sleep", "Bio-Manipulation (the evil eye)", "Deaden Pain", "Increased Healing", "Psychic Purification", "Psychosomatic Disease", "Radiate Horror Factor", "Stop Bleeding", "Telemechanic Mental Operation"]
  - name: "Psi-Powers (74-85): Healer"
    description: "Roll 74-85. All Healing powers. Healing Touch does double the usual level of healing, and the character is +30% to perform an exorcism (both applied by hand)."
    psionics:
      type: "master"
      powers: ["Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear"]
  - name: "Psi-Powers (86-97): Closed Mind"
    description: "Roll 86-97. Group Mind Block, Mind Block, Mind Block Auto-Defense, P.P.E. Shield, Psionic Invisibility and Suppress Fear, and the character is impervious to empathy, empathic transmission, mind bond, mind wipe, possession, see aura, presence sense, remote viewing (cannot be found or seen) and all vampire powers."
    psionics:
      type: "master"
      powers: ["Mind Block", "Group Mind Block", "P.P.E. Shield", "Mind Block Auto-Defense", "Psionic Invisibility", "Suppress Fear"]
  - name: "Psi-Powers (98-00): Mind Melter"
    description: "Roll 98-00. Powers as per the Mind Melter psychic O.C.C. No powers are granted here: the G.M. gives the character that O.C.C.''s powers."
    psionics:
      type: "master"
  - { choose: 1, from: ["I.S.P. (01-20): M.E. x10", "I.S.P. (21-40): M.E. x5", "I.S.P. (41-60): M.E. x2", "I.S.P. (61-80): M.E. x3", "I.S.P. (81-00): M.E. number"], note: "I.S.P.: roll percentile dice to determine the random level of power." }
  - name: "I.S.P. (01-20): M.E. x10"
    description: "Roll 01-20. I.S.P. is the M.E. attribute number x10, +8 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x10, +8 per level"
  - name: "I.S.P. (21-40): M.E. x5"
    description: "Roll 21-40. I.S.P. is the M.E. attribute number x5, +2D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x5, +2d6 per level"
  - name: "I.S.P. (41-60): M.E. x2"
    description: "Roll 41-60. I.S.P. is the M.E. attribute number x2, +12 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x2, +12 per level"
  - name: "I.S.P. (61-80): M.E. x3"
    description: "Roll 61-80. I.S.P. is the M.E. attribute number x3, +1D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E. x3, +1d6 per level"
  - name: "I.S.P. (81-00): M.E. number"
    description: "Roll 81-00. I.S.P. is the M.E. attribute number, +4D6 per level of experience."
    psionics:
      type: "master"
      isp_base: "M.E., +4d6 per level"
side_effects: "Terrible day vision (40 ft / 12 m), and eyes so sensitive to light that some sort of tinted protective covering must be worn over them; blinded by bright sunlight, flashbulbs and other bright lights. Ley lines increase the psychic''s powers as usual, but also heighten confidence, aggression and other base and evil emotions. Insanity: randomly roll or determine three phobias and one obsession. Tires easily (one third the endurance of a normal human), and is prone to substance abuse and easily addicted to alcohol and drugs."
restrictions:
  - "Optional player character and NPC."
  - "Alignment: any, but they tend to vary in extremes: principled (30%), diabolic (30%), aberrant (17%) and anarchist (17%)."
  - "Magic: none."
  - "Skills: two languages plus ONE skill category of choice, chosen with the class - every skill in that category is known at +20%. Outside it the Psi-X learns only its secondary skills. R.C.C. Related Skills: none."
  - "Secondary skills come from the Secondary Skill List of Rifts Ultimate Edition page 300, and all start at the base skill level."
  - "Available O.C.C.s: none, although depending on its skill category a Psi-X can get employment as a doctor, mechanic, electrician, researcher and so on."
  - "M.D.C.: via body armor, force fields or psionics."
  - "May use light armor; prefers light, rapid-fire energy weapons or magic items."
variants:
  - id: communications
    name: "Psi-X Alien (Communications)"
    skills_additional:
      occ_skills:
        - { name: "Barter", base: 50, per_level: 4, note: "+20%" }
        - { name: "Cryptography", base: 45, per_level: 5, note: "+20%" }
        - { name: "Electronic Countermeasures", base: 50, per_level: 5, note: "+20%" }
        - { name: "Language: Dolphin/Whale", base: 70, per_level: 5, note: "+20%" }
        - { name: "Laser Communications", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Euro", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Gypsy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%" }
        - { name: "Literacy: Russian", base: 50, per_level: 5, note: "+20%" }
        - { name: "Optic Systems", base: 50, per_level: 5, note: "+20%" }
        - { name: "Performance", base: 50, per_level: 5, note: "+20%" }
        - { name: "Public Speaking", base: 50, per_level: 5, note: "+20%" }
        - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
        - { name: "Radio: Scramblers", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sign Language", base: 45, per_level: 5, note: "+20%" }
        - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
        - { name: "Space: Radio: Deep Space", base: 65, per_level: 5, note: "+20%" }
        - { name: "Surveillance", base: 50, per_level: 5, note: "+20%" }
        - { name: "T.V./Video", base: 45, per_level: 4, note: "+20%" }
  - id: electrical
    name: "Psi-X Alien (Electrical)"
    skills_additional:
      occ_skills:
        - { name: "Basic Electronics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Computer Repair", base: 45, per_level: 5, note: "+20%" }
        - { name: "Electrical Engineer", base: 50, per_level: 5, note: "+20%" }
        - { name: "Electricity Generation", base: 70, per_level: 5, note: "+20%" }
        - { name: "Robot Electronics", base: 50, per_level: 5, note: "+20%" }
  - id: mechanical
    name: "Psi-X Alien (Mechanical)"
    skills_additional:
      occ_skills:
        - { name: "Aircraft Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Automotive Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Basic Mechanics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Bioware Mechanics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Locksmith", base: 45, per_level: 5, note: "+20%" }
        - { name: "Mechanical Engineer", base: 45, per_level: 5, note: "+20%" }
        - { name: "Robot Mechanics", base: 40, per_level: 5, note: "+20%" }
        - { name: "Ship Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Space: Satellite Systems", base: 50, per_level: 5, note: "+20%" }
        - { name: "Space: Spacecraft Mechanics", base: 40, per_level: 5, note: "+20%" }
        - { name: "Submersible Vehicle Mechanics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Vehicle Armorer", base: 50, per_level: 5, note: "+20%" }
        - { name: "Weapons Engineer", base: 45, per_level: 5, note: "+20%" }
  - id: medical
    name: "Psi-X Alien (Medical)"
    skills_additional:
      occ_skills:
        - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
        - { name: "Brewing", base: 45, per_level: 5, note: "+20%" }
        - { name: "Brewing: Medicinal", base: 45, per_level: 5, note: "+20%" }
        - { name: "Crime Scene Investigation", base: 55, per_level: 5, note: "+20%" }
        - { name: "Cybernetic Medicine", base: 60, per_level: 5, note: "+20%" }
        - { name: "Doctor of Veterinary Medicine", base: 80, per_level: 5, note: "+20%" }
        - { name: "Entomological Medicine", base: 60, per_level: 5, note: "+20%" }
        - { name: "Field Surgery", base: 36, per_level: 4, note: "+20%" }
        - { name: "First Aid", base: 65, per_level: 5, note: "+20%" }
        - { name: "Forensics", base: 55, per_level: 5, note: "+20%" }
        - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
        - { name: "Juicer Technology", base: 60, per_level: 5, note: "+20%" }
        - { name: "M.D. in Cybernetics", base: 60, per_level: 5, note: "+20%" }
        - { name: "Medical Doctor", base: 80, per_level: 5, note: "+20%" }
        - { name: "Paramedic", base: 60, per_level: 5, note: "+20%" }
        - { name: "Pathology", base: 60, per_level: 5, note: "+20%" }
        - { name: "Psychology", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sea Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
        - { name: "Veterinary Science", base: 70, per_level: 4, note: "+20%" }
  - id: pilot-related
    name: "Psi-X Alien (Pilot Related)"
    skills_additional:
      occ_skills:
        - { name: "Navigation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Stellar", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Terrestrial", base: 60, per_level: 5, note: "+20%" }
        - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "+20%" }
        - { name: "Radar/Sonar Operations", base: 50, per_level: 5, note: "+20%" }
        - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20%" }
        - { name: "Weapon Systems", base: 60, per_level: 5, note: "+20%" }
  - id: rogue
    name: "Psi-X Alien (Rogue)"
    skills_additional:
      occ_skills:
        - { name: "Cardsharp", base: 44, per_level: 4, note: "+20%" }
        - { name: "Computer Hacking", base: 35, per_level: 5, note: "+20%" }
        - { name: "Concealment", base: 40, per_level: 4, note: "+20%" }
        - { name: "Gambling (Dirty Tricks)", base: 40, per_level: 4, note: "+20%" }
        - { name: "Gambling (Standard)", base: 50, per_level: 5, note: "+20%" }
        - { name: "I.D. Undercover Agent", base: 50, per_level: 4, note: "+20%" }
        - { name: "Imitate Voices & Sounds", base: 62, per_level: 4, note: "+20%" }
        - { name: "Locate Secret Compartments", base: 40, per_level: 5, note: "+20%" }
        - { name: "Palming", base: 40, per_level: 5, note: "+20%" }
        - { name: "Roadwise", base: 46, per_level: 4, note: "+20%" }
        - { name: "Safe-Cracking", base: 40, per_level: 4, note: "+20%" }
        - { name: "Seduction", base: 40, per_level: 3, note: "+20%" }
        - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
        - { name: "Streetwise: Drugs", base: 45, per_level: 5, note: "+20%" }
        - { name: "Tailing", base: 50, per_level: 5, note: "+20%" }
  - id: science
    name: "Psi-X Alien (Science)"
    skills_additional:
      occ_skills:
        - { name: "Anthropology", base: 40, per_level: 5, note: "+20%" }
        - { name: "Antiquarian", base: 60, per_level: 5, note: "+20%" }
        - { name: "Archaeology", base: 40, per_level: 5, note: "+20%" }
        - { name: "Artificial Intelligence", base: 50, per_level: 3, note: "+20%" }
        - { name: "Astronomy", base: 45, per_level: 5, note: "+20%" }
        - { name: "Astronomy & Navigation", base: 50, per_level: 5, note: "+20%" }
        - { name: "Astrophysics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Botany", base: 45, per_level: 5, note: "+20%" }
        - { name: "Chemistry", base: 50, per_level: 5, note: "+20%" }
        - { name: "Chemistry: Pharmaceutical", base: 50, per_level: 5, note: "+20%" }
        - { name: "Geology", base: 45, per_level: 5, note: "+20%" }
        - { name: "Marine Biology", base: 55, per_level: 5, note: "+20%" }
        - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "+20%" }
        - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
        - { name: "Ocean Geographic Surveying", base: 35, per_level: 5, note: "+20%" }
        - { name: "Physics", base: 50, per_level: 5, note: "+20%" }
        - { name: "Undersea Farming", base: 55, per_level: 5, note: "+20%" }
        - { name: "Xenology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Zoology", base: 50, per_level: 5, note: "+20%" }
  - id: technical-languages-lores
    name: "Psi-X Alien (Technical Studies)"
    skills_additional:
      occ_skills:
        - { name: "Computer Hacking", base: 35, per_level: 5, note: "+20%; from Rogue" }
        - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Computer Programming", base: 50, per_level: 5, note: "+20%" }
        - { name: "History", base: 50, per_level: 5, note: "+20%" }
        - { name: "History of the West", base: 50, per_level: 5, note: "+20%" }
        - { name: "History: Post-Apocalypse", base: 55, per_level: 5, note: "+20%" }
        - { name: "History: Pre-Rifts", base: 52, per_level: 4, note: "+20%" }
        - { name: "Japanese Mythology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Law", base: 55, per_level: 5, note: "+20%" }
        - { name: "Law: CCW", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Astral", base: 46, per_level: 4, note: "+20%" }
        - { name: "Lore: D-Bee", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Dimensions", base: 35, per_level: 5, note: "+20%" }
        - { name: "Lore: Faeries & Creatures of Magic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Galactic/Alien", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Juicers", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Magic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Nightbane", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Nightlands", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Psychics & Psionics", base: 45, per_level: 5, note: "+20%" }
        - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Vampires", base: 50, per_level: 5, note: "+20%" }
        - { name: "Lore: Wormwood", base: 40, per_level: 5, note: "+20%" }
        - { name: "Mythology", base: 50, per_level: 5, note: "+20%" }
        - { name: "Research", base: 60, per_level: 5, note: "+20%" }
  - id: technical-others
    name: "Psi-X Alien (Technical Applications)"
    skills_additional:
      occ_skills:
        - { name: "Advanced Fishing", base: 50, per_level: 5, note: "+20%" }
        - { name: "Appraise Goods", base: 50, per_level: 5, note: "+20%" }
        - { name: "Art", base: 55, per_level: 5, note: "+20%" }
        - { name: "Art: Line Drawing", base: 55, per_level: 5, note: "+20%" }
        - { name: "Begging", base: 50, per_level: 3, note: "+20%" }
        - { name: "Breed Dogs", base: 60, per_level: 5, note: "+20%" }
        - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%" }
        - { name: "Creative Writing", base: 45, per_level: 5, note: "+20%" }
        - { name: "Cyberjacking", base: 70, per_level: 3, note: "+20%" }
        - { name: "Cybernetics: Basic", base: 45, per_level: 5, note: "+20%" }
        - { name: "Excavation", base: 60, per_level: 5, note: "+20%" }
        - { name: "Firefighting", base: 50, per_level: 5, note: "+20%" }
        - { name: "Gemology", base: 45, per_level: 5, note: "+20%" }
        - { name: "General Repair & Maintenance", base: 55, per_level: 5, note: "+20%" }
        - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
        - { name: "Language Dialects", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Amaki", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Ancient Greek", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Arkhon", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Aymara", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Brodkil", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Chinese", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Creole", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Dragonese", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Dwarven", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Euro", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gargoyle", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gobblely", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Gypsy", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Larhold", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Mongolian", base: 60, per_level: 5, note: "+20%" }
        - { name: "Language: Old Norse", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Quechua", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Russian", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Spanish", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Five/Reptile", base: 60, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Four", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade One", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Six", base: 65, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Three", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Trade Two", base: 70, per_level: 5, note: "+20%" }
        - { name: "Language: Troll/Giant", base: 70, per_level: 5, note: "+20%" }
        - { name: "Leather Working", base: 60, per_level: 5, note: "+20%" }
        - { name: "Literacy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Literacy: Dragonese/Elven", base: 50, per_level: 5, note: "+20%" }
        - { name: "Masonry", base: 60, per_level: 5, note: "+20%" }
        - { name: "Metalwork and Forge", base: 80, per_level: 3, note: "+20%" }
        - { name: "Mining", base: 55, per_level: 5, note: "+20%" }
        - { name: "Philosophy", base: 50, per_level: 5, note: "+20%" }
        - { name: "Photography", base: 55, per_level: 5, note: "+20%" }
        - { name: "Prospecting", base: 40, per_level: 5, note: "+20%" }
        - { name: "Recognize Enchantment", base: 30, per_level: 5, note: "+20%" }
        - { name: "Recognize Wards, Runes & Circles", base: 35, per_level: 5, note: "+20%" }
        - { name: "Recycling", base: 50, per_level: 5, note: "+20%" }
        - { name: "Rope Works", base: 50, per_level: 5, note: "+20%" }
        - { name: "Salvage", base: 55, per_level: 5, note: "+20%" }
        - { name: "Sculpt, Carve & Whittle Wood", base: 90, per_level: 3, note: "+20%" }
        - { name: "Shape, Engrave, Etch & Emboss Metal", base: 90, per_level: 3, note: "+20%" }
        - { name: "Undersea Salvage", base: 50, per_level: 5, note: "+20%" }
        - { name: "Ventriloquism", base: 36, per_level: 4, note: "+20%" }
        - { name: "Whittling & Sculpting", base: 50, per_level: 5, note: "+20%" }
extraction_notes: "This class followed Rifts World Book 13: Lone Star printed 98-100 until the update of 2026-10-04 (ruling of that date: the newest printing that states a figure wins, and the older figure is kept here); it now follows Rifts World Book 30: D-Bees of North America printed 166-168, whose own Note says the entry originally appeared in Lone Star. D-Bees printed 166-168 (cache p167-p169, cache page = printed folio + 1): the heading and the first paragraph of the introduction are on 166, the rest of the introduction and the stat block down to Vulnerabilities on 167, Insanity, Psionics, the psi-power table, I.S.P., equipment, money and the closing lines on 168, where Quick-Flex Alien begins. Lone Star printed 98-100 (cache p099-p101, same offset): the introduction and the R.C.C. heading are on 98, natural abilities, bonuses, attacks, penalties and the psi-power table on 99, the last table entry, I.S.P., disposition, skills and equipment on 100, where Notable CS Characters begins. All numbers of both books read off 170 dpi renders; the D-Bees psi-power table was read again at 300 dpi. || HEADING: D-Bees heads the block Psi-X Alien - Optional Player Character and NPC, Race: Genetically Altered Humans believed to be D-Bees. Lone Star printed 98 gave Psi-X Alien R.C.C., Optional Player Character - and a great NPC Villain, Race: Genetically Altered Human. D-Bees prints Available O.C.C.s: None (a restrictions line); Lone Star did not name O.C.C.s at all. Neither entry calls for a roll on the Human Special Abilities table of Lone Star printed 97. || ALIGNMENT: D-Bees prints Principled (30%), Diabolic (30%), Aberrant (17%), Anarchist (17%), which adds up to 94. Lone Star printed 98 gave 30% principled, 30% diabolic, 30% anarchist and 10% other. || XP: D-Bees printed 167 says to use the same experience table as the Mind Melter, so the ladder stored is a copy of the production mind-melter class''s xp_table (Rifts Ultimate Edition). Lone Star gave the ladder headed Psi-X Alien, Xiticix Killer on the unnumbered Experience Tables page after its printed 174 (cache p176): 0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001. || ATTRIBUTES, the same in both books: I.Q. 3D6+6 (but special, see skills), M.E. 3D6, M.A. 2D6 (+2 if a good alignment: text), P.S. 2D4+4, P.P. 2D4+4, P.E. 2D4+1, P.B. 2D4+2, Spd 2D6+4. Lone Star adds by human standards after P.B.; D-Bees does not restate those words and they are kept. || SIZE: the same weight and height in both books (D-Bees rounds 1.21 m to 1.2 m). Average life span is 1D6x10+170 years in D-Bees, with physical maturity around age 20; Lone Star printed 98 gave 60-90. || POOLS, the same in both books: hit points P.E. x2 plus 1D6 per level. S.D.C. is printed as 2D6+2 and nothing else - no P.E. term and no plus-those-gained-from-skills wording - so it is the whole figure and is stored as sdc_base with no men_of_arms line (judgement; the entry takes no O.C.C. whose pool it could override). P.P.E. is printed P.E. x10. D-Bees adds M.D.C.: via body armor, force fields or psionics (a restrictions line). || PSIONICS: every Psi-X has See Aura, Sense Magic, Detect Psionics and Bio-Regeneration (stored as the Healing power, not the Super one; Lone Star says healing after it, D-Bees prints its I.S.P. as 6); see the invisible is printed among the vision abilities as automatic and is natural-ability text. D-Bees moves the hover from Natural Abilities to Psionics and adds that it costs no I.S.P. Neither book states a psychic tier or a save target; master is stored because the power packages include Super powers, which only a master holds. || PSI-POWER TABLE: a percentile table (Additional Random Psionic Powers in D-Bees, Random Psi-Powers in Lone Star) stored as a choice of one of nine abilities, each carrying its named powers. The nine bands are the same in both books and skip nothing. D-Bees renames six rows and lengthens seven; the option names follow D-Bees and the Lone Star names and lists are recorded here. 01-12 Kineticist (Lone Star: Kinetesis, listing telekinesis (super), telekinetic force field, levitation, electrokinesis, hydrokinesis, pyrokinesis): D-Bees adds Telekinetic Acceleration Attack, Telekinetic Leap, Telekinetic Lift, Telekinetic Punch and Telekinetic Push. Both books say all kinesis abilities, including the named ones; ordinary Telekinesis is stored on that wording. 13-24 Psychic Sensitive (Lone Star: Psi-Sensitive, all sensitive abilities at double the normal range): D-Bees says all Sensitive abilities, including Empathic Transmission, all at double the normal range and duration. Stored as the 23 Sensitive catalog rows whose source is the Rifts core book, plus Empathic Transmission; the doubling is text. 25-37 Psychic Energy Conduit (Lone Star: Energy Conduit): the same six powers, and D-Bees prints the last item as Impervious to Fire (40; even M.D. fire), in the form it gives a power and its I.S.P. cost, where Lone Star said and impervious to fire (even mega-damage fire). Stored as the catalog power Impervious to Fire, which the catalog holds at 4 I.S.P.; the printed 40 is recorded here and not stored. 38-49 Psychic Intuitive (Lone Star: Intuitive, listing telemechanics, clairvoyance, object read, presence sense evil with no comma, sense magic, sixth sense, psychic diagnosis): D-Bees prints Presence Sense and Sense Evil apart and adds Intuitive Combat, Read Dimensional Portal, Sense Dimensional Anomaly and Sense Time. 50-61 Psychic Spiritualist (Lone Star: Spiritualist, listing see aura, clairvoyance, object read, telepathy, astral projection, ectoplasm): D-Bees adds Commune with Spirits (the catalog row is Commune with Spirit) and Psychic Omni-Sight. The +20% to find the way home on Astral Projection is text in both. 62-73 Psychic Manipulator (Lone Star: Manipulator, listing empathic transmission, empathy, telepathy, hypnotic suggestion, mentally possess others, mind wipe, induce sleep): D-Bees adds Bio-Manipulation (the catalog row carries the words the evil eye), Deaden Pain, Increase Healing (the catalog row is Increased Healing), Psychic Purification, Psychosomatic Disease, Radiate Horror Factor, Stop Bleeding and Telemechanic Mental Operation. 74-85 Healer, the same in both books: all Healing powers, stored as the 15 Healing catalog rows whose source is the Rifts core book; doubled Healing Touch and +30% to perform Exorcism are text. 86-97 Closed Mind (Lone Star: mind block, group mind block, P.P.E. shield, impervious to empathy, empathic transmission, mind bond, mind wipe and possession): D-Bees adds Mind Block Auto-Defense, Psionic Invisibility and Suppress Fear, and adds See Aura, Presence Sense, Remote Viewing (cannot be found or seen) and all vampire powers to the imperviousness, which is text. 98-00 Mind Melter: D-Bees prints Powers as per that Psychic O.C.C.; Lone Star printed only the two words and an exclamation mark. No powers are stored on the row in either case; the G.M. assigns them. The I.S.P. costs D-Bees prints beside the powers are not stored on the class; they match the catalog except Impervious to Fire (printed 40, catalog 4), Stop Bleeding (printed 4, catalog 2) and Mind Block Auto-Defense (printed special, catalog 14). || I.S.P. (Roll to determine random level of Inner Strength in D-Bees) is a second percentile table stored as a choice of one of five abilities, each carrying its isp_base, the same in both books: M.E. x10 +8 per level, M.E. x5 +2D6, M.E. x2 +12, M.E. x3 +1D6, M.E. +4D6 per level. || BONUSES, the same in both books: +5 save vs horror factor, +5 save vs magic illusions (illusionary_magic). || ATTACKS, the same in both books: one physical at levels 1, 2, 4, 8 and 12, or two via psionics at levels 1, 3, 6, 10 and 15. Stored as attacks_base 1 and +1 at levels 2, 4, 8 and 12; the psionic ladder is text. No hand to hand is printed. || SKILLS (R.C.C. Skills of Psi-X Aliens in D-Bees, O.C.C. Skills of Psi-X Aliens in Lone Star): two languages of choice at 98%, stored as two picks of Language: Other at base 98. Then select ONE skill category, all the skills in it known at +20%: stored as nine variants, one per printed category, each adding the catalog''s Rifts skills of that category at catalog base + 20 as the catalog stood on the day of the first import (Communications 19, Electrical 5, Mechanical 13, Medical 19, Pilot Related 7, Rogue 15, Science 20). D-Bees revises the two Technical choices. It prints Technical Studies (all Computer, History, Law, Lore, Myth and Research skills, including Computer Hacking from Rogue) and Technical Applications (all the Technical skills not covered in the previous category; no Computer, Lore, etc. skills, but everything else). Lone Star printed 100 gave technical: languages and lores (all) and technical: others (all, except language and lore). The two variants keep their ids (technical-languages-lores, technical-others) and take the D-Bees names; the 87 Technical rows already held were re-sorted between them - the Computer, History, Law, Lore, Mythology and Research rows to Technical Studies (25, plus Computer Hacking at 35% = 15 + 20), every language row and every other Technical row to Technical Applications (62). Technical rows the catalog gained after the first import were not added in this update. Left out as before: the generic rows Language: Other, Language: Native Tongue and Literacy: Other (a tongue with no row of its own is taken at +20% by hand), and three skills the catalog marks exclusive to another O.C.C. (Professional Restoration, Recognize Authenticity, Recognize Machine Quality). Also left out of Science: the analytical chemistry skill, whose catalog name carries an em-dash. Four other classes do name it (class-check''s emitter splices the character into the SQL); this one does not, so it is known at 45% (25 + 20) and is added by hand. R.C.C. Related Skills: None in both books, so no related block. Secondary: four at level one and one more at levels 3, 5, 9 and 11 in both books. D-Bees takes them from the Secondary Skill List in Rifts Ultimate Edition, page 300, all at the base skill level, and the category limit is removed; Lone Star printed 100 limited them to the categories of domestic, pilot and W.P. (no bonuses). || EQUIPMENT: survival knife, one energy weapon of choice (the catalog''s energy-weapon-of-choice row), 1D4 additional E-clips, backpack, knapsack, utility belt, air filter, protective eye goggles, universal translator (portable language translator row), cigarette lighter, note pad and canteen in both books. D-Bees adds a portable tool kit, a flashlight, a couple sets of clothing (two of the clothing row) and some personal items (no row; a note on the clothing line). Lone Star printed 100 had none of those four. No armor is listed; may use light armor is a restriction line. || MONEY: D-Bees prints start with 3D6x100 credits. Lone Star printed none and none was stored. || VULNERABILITIES (Penalties of Note in Lone Star): day vision of 40 ft, light-sensitive eyes, the ley line effect, and insanity (three phobias and one obsession) are in both books and are side_effects. D-Bees says ley lines increase confidence, aggression and other base and evil emotions; Lone Star said other base emotions. Lone Star printed 99 also gave: psionic attacks that use bio-manipulation or empathic transmission do double damage and last twice as long. D-Bees restates the block without that sentence, and it was removed. One-third endurance and addiction are in the introduction of both books and stay in side_effects. Disposition is lore. || NPC FIGURES, D-Bees only, no field: experience level 1D10 or as set by the Game Master for NPCs (player characters start at level one); slave market value 1D4x10,000 credits; females give birth to one young after a nine month pregnancy, till the age of 90; habitat mostly the Coalition States of Lone Star, El Dorado and Chi-Town, some in the Pecos Empire and Arzno; alliances none per se; rivals other psychics, and a dislike of slavers, shape-changers, Cyber-Docs, Gene-Splicers and scientists who dabble in genetics."
---

## Lore

The Psi-X are what came of Desmond Bradford''s private, illegal attempt to
find the genetic root of psychic power and switch it on. His subjects were
human, many of them teenagers taken against their will, and he spliced
Psi-Stalker and D-Bee material into them on little more than a hunch. The
psionics arrived. So did a body that never fills out, a hairless oversized
head and a pair of huge dark eyes; one of the first victims said he had been
made into a saucer alien, and the name stuck.

Bradford counts them his worst personal failure, but could not bring himself
to put down people the way the labs put down animals. More than 150 were
quietly turned loose in the Pecos Badlands, where most survived and have
started families.

A Psi-X drifts a few feet off the ground rather than walking, sees almost
everything except a bright afternoon, and leans on its mind for nearly all it
does. Each is brilliant inside one narrow field and hopeless outside it. Good
ones tend to be sunny and guileless, selfish ones sly and boastful, and the
evil ones brooding, cruel and trusting of nobody.

## GM Notes

Two percentile rolls define the character: the psi-power package and the
I.S.P. level. Both are stored as choices, so roll and then pick the entry
rolled. A result of 98-00 on the power table gives the powers of the Mind Melter
O.C.C.; assign that O.C.C.''s powers yourself.

Pick the one skill category with the class. Every skill in it is known at
+20%; outside it the character has two languages and a few secondary skills
and can learn nothing else.

The sheet counts the physical attack ladder. A Psi-X fighting with its mind
uses the other one: two psionic attacks at level 1, with two more at levels
3, 6, 10 and 15. Add +2 M.A. for a good alignment by hand.

Play the drawbacks: day vision of 40 feet, eyes that must stay covered, three
phobias and an obsession, a third of human stamina, and a weakness for drink
and drugs.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-x-alien'
   AND instr(markdown, 'that a pure-ASCII class file cannot spell') > 0
   AND length(markdown) = 41206;

-- == amana ==
UPDATE imported_classes
   SET markdown = '---
id: amana
name: Amana
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.18-21
category: rcc
tags: [healer]
attribute_dice:
  IQ: "3d4+4"
  ME: "3d4+4"
  MA: "3d4+2"
  PS: "3d4+2"
  PP: "3d4+6"
  PE: "3d4+6"
  PB: "3d4+8"
  Spd: "3d4+4"
mdc_base: "P.E. + 3d4, +1d4 per level"
ppe_base: "P.E. + 2d4x10, +4d4 per level"
starting_money: "3d4x1000"
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
psionics:
  type: "major"
  isp_base: "M.E. + 2d4 per level"
  powers: ["Induce Sleep", "Mind Block", "Presence Sense", "Sense Evil"]
  powers_starting: 4
  categories_allowed: ["Healing"]
bonuses:
  combat: { perception: 2 }
  saves: { horror_factor: 4, mind_control: 2, possession: 2, other: [ { label: "vs Necromancy or Spoiling Magic", bonus: 2 }, { label: "vs Bio-Wizardry, symbiotes and parasites", bonus: 4 } ] }
skills:
  hand_to_hand: { costs: { basic: 1, expert: 4 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native tongue, typically American or Spanish (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: Other, one of choice (+15%)." }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "Literacy: Native Tongue, American or Spanish (+20%)." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 15, note: "Literacy: Other, one of choice (+15%)." }
    - { name: "Biology", base: 50, per_level: 5, note: "+20%." }
    - { name: "Chemistry", base: 45, per_level: 5, note: "+15%." }
    - { name: "Medical Doctor", base: 85, per_level: 5, note: "+25%." }
    - { name: "Pathology", base: 60, per_level: 5, note: "+20%." }
    - { choose: 2, categories: ["Domestic"], bonus: 10, note: "Domestic: two of choice (+10%)." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", bonus: 15 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - "Pilot Related"
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Cross Bow", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Whip", "W.P. Energy Pistol", "W.P. Energy Rifle"] }
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
    note: "R.C.C. Related Skills: six, plus one more at levels 3, 6, 9, 12 and 15. Cowboy, Espionage, Military, Physical and Rogue: none. Pilot: any except robots, power armor and military vehicles. W.P.: any Ancient, and Energy Rifle and Energy Pistol only."
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 1, note: "One box of 100 surgical gloves; the row is priced per box." }
  - { item_id: "scalpel", qty: 10 }
  - { item_id: "dress-clothing", qty: 1 }
  - { choose: 1, label: "backpack or large sack", qty: 1, from: ["backpack", "large-sack"] }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "surgical-gown", qty: 1, note: "Printed as a surgical apron." }
natural_abilities:
  - name: "Minor Mega-Damage being"
    description: "M.D.C. equal to the P.E. attribute number +3D4, plus 1D4 per level of experience."
  - name: "Natural Empathy"
    description: "Reads the emotions of those nearby, equal to the psionic Sensitive power of Empathy, at no I.S.P. cost and always active."
  - name: "Living P.P.E. battery"
    description: "P.P.E. is the P.E. attribute number +2D4x10, plus 4D4 per level. Can draw extra P.P.E. from ley lines and nexus points like a Ley Line Walker, but never from living creatures."
  - name: "Untouchable by the undead"
    description: "Impervious to a vampire''s bite (physical damage only) and cannot be turned into one of the undead."
  - name: "Physiology"
    description: "Physical maturity at 17; females bear one child after a 12 month term. Most mate for life."
special_abilities:
  - name: "Super-Healing"
    description: "By laying hands on bare flesh, with total concentration and a calm patient not in combat, the Amana channels P.P.E. into healing: every 6 P.P.E. restores 4D4+6 Hit Points or S.D.C. (Hit Points first), or 1D4 M.D.C. to a Mega-Damage being. Wounds close in 1D4 seconds without scars, and bullets and shrapnel rise out painlessly. Mending broken bone costs 10 P.P.E. and also restores 4D4+6 Hit Points. Alternatively, 32 P.P.E. cures most diseases and physical afflictions (not curses, insanity, birth defects or magical ailments); a genetic disease has only a 01-33% chance, and once an Amana fails against one it can never cure that disease. Each healing counts as two melee actions; two wounds can be healed at once, one per hand, each at full cost. Works on the Amana itself at half the P.P.E. cost."
  - name: "Regrow Lost Limbs"
    description: "Touch and 2D4 minutes of silent concentration channel 1D6x10+40 P.P.E. into the patient, who must rest for four weeks; the limb regrows from the stump over 4D4 days. Combat or heavy labor during that time has a 01-80% chance of ruining it, leaving a dead stump. The P.P.E. is unavailable to the Amana until the 4-16 day healing is done, and the Amana is weakened (all attributes and bonuses -25%) until four weeks have passed. A recent injury (within 96 hours) with the limb still partly attached costs only 1D4x10+8 P.P.E.: the limb is reattached instantly, with no lingering penalty or P.P.E. loss to the Amana; the patient must not use it for 24 hours or there is a 01-40% chance it stays without movement or feeling."
  - name: "Resurrection"
    description: "Brings back the dead if the body has been dead no more than six weeks and 70% of it remains. Lost limbs do not regrow; other wounds heal, and the revived returns with full S.D.C. but only 2D4 Hit Points (or M.D.C.), tired and withdrawn for 3D4 days before recovering fully (normal Hit Points and S.D.C., or half M.D.C. for a Mega-Damage being). It costs the healer 80% of his total P.P.E. and 4D4+4 of his own M.D.C., unrecoverable until the patient''s recovery 3D4 days later, and he must save vs Coma/Death or fall into a coma; a failed save is rolled again every 12 hours for two days until he wakes or dies."
  - name: "Aura of Life"
    description: "10 P.P.E. per melee round raises a white aura that keeps demons and the undead at bay like a holy symbol (Horror Factor 15, no damage), holds off evil Entities and ghosts and draws good ones. Allies who stay inside it get +4 to save vs Horror Factor and +2 to save vs disease, possession and mind control, and heal 1D4 S.D.C. per melee round. Radius 4 feet (1.2 m), +4 feet (1.2 m) at levels 2, 4, 8, 12 and 16."
  - name: "Touch of Life"
    description: "Life energy that harms the undead: a touch does 1D4 Hit Point damage and a punch or laying on of hands 3D4 Hit Point damage; against animated dead and other dead or undead M.D.C. beings, a touch does 1D4 M.D. and a punch 3D4 M.D."
level_progression:
  - { level: 2, grants: ["Aura of Life radius +4 feet (1.2 m)"] }
  - { level: 4, grants: ["Aura of Life radius +4 feet (1.2 m)"] }
  - { level: 8, grants: ["Aura of Life radius +4 feet (1.2 m)"] }
  - { level: 12, grants: ["Aura of Life radius +4 feet (1.2 m)"] }
trackable_resources: []
restrictions:
  - "Takes no O.C.C.: the Amana are natural born healers, and the book gives them their own R.C.C. skills, equipment and money."
  - "Alignment: typically good, Principled (55%) or Scrupulous (35%); 10% other, typically Unprincipled."
  - "Magic: none; they are born healers."
  - "None of the healing powers affect the undead or the non-living (vampires, zombies, robots)."
  - "Hand to Hand: none, but Basic may be taken at the cost of one R.C.C. Related Skill, or Expert at the cost of four. No other style is available."
  - "Cybernetics and bionics: none to start; avoided, except perhaps tool implants for surgery."
  - "Pacifists: hurting others and causing pain or death physically sickens them."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 18-21 (cache p019-p022), a scan; every number read off 200 dpi renders of cache p020, p021 and p022 and checked against the OCR. Heading Amana - Optional Player Character or NPC (printed 19). The entry opens at the foot of printed 18 after the Altara and ends on printed 21, where Amorph begins. || CATEGORY: an R.C.C. that takes no O.C.C.; Available O.C.C.s: None, because they are natural born healers; see R.C.C. Skills. There is no frontmatter key for no occupation at all, so it is a restriction line, as the amorph class does. || XP_TABLE: the Experience Level line says Use the Body Fixer experience table. Per the class-import reference (a class whose book names another class''s table copies that ladder), the stored body-fixer ladder is copied here. This departs from the batch brief''s no-xp_table default, whose premise (use the chosen O.C.C.''s table) this entry does not print. || M.D.C.: P.E. attribute number +3D4, plus 1D4 per level, stored as mdc_base; so no men_of_arms line. || P.P.E.: P.E. attribute number +2D4x10, plus 4D4 per level, stored as ppe_base; ley line draw is ability text. || PSIONICS: Induce Sleep (4), Mind Block (4), Presence Sense (4), Sense Evil (2) granted by name, plus four of choice from the Healer category (catalog category Healing); Major Psychic. I.S.P.: M.E. attribute number plus 2D4 per level, read as 2D4 at every level including the first. || BONUSES: +2 Perception, +4 vs Horror Factor, +2 vs mind control and possession; +2 vs Necromancy or Spoiling Magic and +4 vs Bio-Wizardry, symbiotes and parasites as saves.other. Aura of Life bonuses go to allies and are ability text. || SKILLS: catalog base plus the printed bonus. Language: Native Tongue is 98% in the catalog, so the +15% is in the note. Literacy: Native Tongue +20% is Literacy: Native Language 40+20=60. Biology 30+20=50, Chemistry 30+15=45, Medical Doctor 60+25=85, Pathology 40+20=60. Language: Other and Literacy: Other one each at +15%; Domestic two at +10%. HAND TO HAND: none granted; Basic for one related skill, Expert for four, nothing else: costs basic 1, expert 4. || RELATED: six plus one at 3, 6, 9, 12 and 15. Communications any; Cowboy none; Domestic +5%; Electrical Basic Electronics only; Espionage none; Horsemanship General only; Mechanical Basic Mechanics only; Medical +15%; Military none; Physical none; Pilot any except robots and power armor and military vehicles (the except list is the one other classes use, plus Robot Combat: Basic); Pilot Related any; Rogue none; Science +10%; Technical +5%; W.P. Ancient any and Modern Energy Rifle and Energy Pistol only (the ancient list is the one other classes use); Wilderness any. || SECONDARY: four from the Rifts Ultimate Edition Secondary Skills list, plus one at levels 4, 8 and 12; stored without a category list. || LEVEL-GATED: the Aura of Life radius grows at levels 2, 4, 8, 12 and 16; stored as level_progression prose for 2-12 (16 is past the 15-level ladder); not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). || TYPO: the limb-reattachment note prints The P.E. cost is only 1D4x10+8; read as P.P.E., since the passage is about P.P.E. spent. || EQUIPMENT: traveling clothes, first-aid kit, a box of 100 surgical gloves (disposable-surgical-gloves qty 1 since ~116 and ~117: the catalog row is priced per box and the book prints one box of 100), 10 S.D.C. scalpels, dress clothes, backpack or large sack, language translator, and 1D4+1 weeks of water and rations stored as food-rations 1d4+1. The surgical apron is granted as surgical-gown. NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant; in GM Notes. || MONEY: 3D4x1,000 Universal Credits stored as starting_money; 1D4x10,000 credits of tradable items is goods, in GM Notes. || NOT STORED: size 6-7 feet, weight 140-190 pounds, life span 4D4+180 years, NPC level 1D4+4, slave market value, allies, enemies, habitat; in GM Notes."
---

## Lore

The Amana are a gentle race of healers devoted to protecting every kind of
life. They are tall and very slender, with smooth white skin that gleams
like marble, long fingers, calm and delicate faces and no hair at all;
people often compare them to living porcelain dolls. Most wear loose robes.

Their healing is the stuff of legend. By channeling their own mystic
energy, an Amana can close wounds in seconds, cure diseases thought
incurable, regrow a lost limb, and even bring the recently dead back to
life, though that last gift can cost the healer his own life. They make
poor fighters, because harming anyone sickens them.

That gift made them prizes. The Splugorth conquered their home world a
thousand years ago and have kept them as slaves ever since, renting and
selling them to keep tyrants alive and armies on their feet. A few
centuries ago a raid on the Splugorth slave pens went wrong and several
thousand Amana fled through a Rift into North America. They hid their
powers for generations, but when the Coalition purged D-Bee communities
during its war on Free Quebec, the Amana stepped forward to heal the
victims, and some even joined Tolkeen''s defense. Now tales of the
Resurrection D-Bees are spreading, and slavers are hunting them again.

## GM Notes

Size 6-7 feet (1.8 to 2.1 m). Weight 140-190 pounds (63 to 85.5 kg). Life
span 4D4+180 years, though most give their lives for others first.
Experience Level for NPCs: 1D4+4.

Standard equipment the catalog has no row for: 50 surgical masks and a
small bottle of disinfectant. They also start with 1D4x10,000
credits'' worth of tradable items, usually spent on medicine and medical
gear.

Habitat: a few dozen live at Lazlo and New Lazlo, a couple hundred in the
Magic Zone, and two or three thousand are scattered east of the
Mississippi in the old Canadian and American Empires; some have been seen
as far as the Vampire Kingdoms.

Slave Market Value: the Splugorth pay 2D6 million credits for a healthy
Amana and sell them for three times that, and would pay as much for an
accurate lead on a group of them.

Allies: almost anyone not violent, warlike or evil. They suspect the
Shemarrians are machines but keep the secret, since the Shemarrians fight
the Splugorth. Enemies: the Minions of Splugorth, demons, slavers,
Shifters, Necromancers, Witches, Cyber-Snatchers and unscrupulous doctors.
They fear the Coalition Army and the Federation of Magic.
',
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, 'ladder); see BOOK-INGEST-AUDIT.md F116.') > 0
   AND length(markdown) = 15466;

-- == arac ==
UPDATE imported_classes
   SET markdown = '---
id: arac
name: A''rac
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.25-27
category: rcc
tags: [scholar]
men_of_arms: false
attribute_dice:
  IQ: "3d6+8"
  ME: "3d6"
  MA: "3d6+6"
  PS: "3d6+2"
  PP: "3d6+4"
  PE: "4d6+2"
  PB: "2d4+1"
  Spd: "4d6"
hit_points_base: "P.E. + 3d6, +1d8 per level"
ppe_base: "2d6"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  saves: { horror_factor: 2, toxins_poisons: 1, disease: 1 }
  pools: { sdc: "1d4x10" }
  at_level:
    - { level: 2, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 3, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 4, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 5, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 6, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 7, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 8, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 9, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 10, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 11, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 12, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 13, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 14, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 15, saves: { toxins_poisons: 1, disease: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 81, per_level: 1, note: "Natural climbing ability, 81% +1% per level; applies equally to climbing and rappelling." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One additional Language: Other at +20%, whatever the O.C.C." }
    - { choose: 1, categories: ["Science"], bonus: 10, note: "One extra Science skill at +10%, whether or not the O.C.C. offers Science skills." }
natural_abilities:
  - name: "Superior vision"
    description: "Can read a small sign or recognize a face from 1200 feet (366 m) away, and sees the infrared and ultraviolet spectrums of light."
  - name: "Natural climber"
    description: "Thousands of microscopic hairs on each finger: Climb 81% +1% per level of experience, applying equally to climbing and rappelling."
  - name: "Excellent balance"
    description: "Base skill of 50%, or +15% to the Acrobatics and Gymnastics skills."
  - name: "Armored exoskeleton"
    description: "Skin of tiny segmented plates: a natural A.R. of 13. Physical S.D.C. is 1D4x10, +5 per level of experience starting at level two."
  - name: "Bionic-equivalent strength"
    description: "P.S. is equal to Bionic Strength, despite thin-looking limbs."
  - name: "Resistant to poison, disease and toxins"
    description: "+1 to save vs poison, toxins and disease per level of experience."
  - name: "Venomous bite"
    description: "Bite does 1D4 S.D.C. and a successful strike injects a toxin; the victim saves vs poison at 14 or higher. A successful save means 1D6 S.D.C. more damage; a failure means 4D6 S.D.C. more, and for 2D4 hours the victim is dizzy and drowsy: -3 to strike, parry and dodge, skills at -15%, and speed halved."
  - name: "Six-fingered hands and feet"
    description: "Four fingers and two opposable thumbs on each hand, and six toes suited both to walking and to climbing."
special_abilities:
  - name: "Perception"
    description: "+1D4 to Perception Rolls, rolled once."
  - name: "Scientific aptitude"
    description: "+5% to all Science and Technical skills, in addition to any O.C.C. or I.Q. bonuses."
level_progression:
  - { level: 2, grants: ["+5 S.D.C. at each level of experience from level two on"] }
trackable_resources: []
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (30%), Unprincipled (20%) or Anarchist (20%)."
  - "Gains no S.D.C., P.S. or P.E. bonuses from Physical skills; P.P. and Spd bonuses from Physical skills do apply."
  - "Psionics: standard, as a human. Magic: only by O.C.C., as a human; P.P.E. is 2D6 or per a magic O.C.C."
  - "Cybernetics and bionics: tend to avoid them."
  - "Standard equipment and money: as per the chosen O.C.C."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 25-27 (cache p026-p028), a scan; every number read off 200 dpi renders of cache p027 (stat block, printed 26) and p028 (printed 27) and checked against the OCR. Heading A''rac - Optional Player Character or NPC (printed 26). The entry opens on printed 25 below the Amorph experience table and ends on printed 27 above Auto-G; first printed in Rifts World Book 27: Adventures in Dinosaur Swamp, not held, so it is imported from here. || ID: arac (the apostrophe dropped); name A''rac. || CATEGORY: a race that takes an O.C.C. No xp_table: the Experience Level note says to use the chosen O.C.C.''s table. men_of_arms false. || ATTRIBUTES as printed; P.B. 2D4+1 is by human standards (2D6+10 by A''rac standards), stored as 2d4+1. P.S. equals Bionic Strength: ability text. || HIT POINTS: 3D6 + P.E. attribute, plus 1D8 per level starting at level one, stored as hit_points_base P.E. + 3d6, +1d8 per level, the shape earlier imports used for starting at level one. || S.D.C.: 1D4x10 stored as a pool bonus; +5 S.D.C. per level from level two cannot be a pool bonus (pools in at_level are not applied), so it is level_progression prose; not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). No S.D.C. from Physical skills: a restriction line. Natural A.R. 13: ability text. || P.P.E.: 2D6 or per magic O.C.C., stored as ppe_base 2d6 with yields_to_occupation ppe_base [magic], as aardan-tek carries for the same wording. Regression pins that flag''s carriers by name (test/regression.mjs, the list holding aardan-tek), so this class must be added to it. || BONUSES: +2 vs Horror Factor; +1 per level vs poison, toxins and disease stored as toxins_poisons and disease 1 at level 1 and at_level +1 at levels 2-15. +1D4 to Perception Rolls is a dice bonus, a special ability. || SKILLS: Climb 81% +1% per level stored as Climbing 81/1. R.C.C. Skills Bonuses: one extra Language: Other at +20%, one extra Science skill at +10%, granted as choices; +5% to all Science and Technical skills cannot be expressed and is a special ability. Balance base 50% or +15% to Acrobatics and Gymnastics: ability text (the catalog has no balance skill). || BITE: 1D4 S.D.C., save vs poison 14+, 1D6 on a save or 4D6 and -3 strike/parry/dodge, -15% skills, half speed for 2D4 hours. || OCCUPATIONS: no restriction; most choose Scholar and Adventurer O.C.C.s, especially explorers (Wilderness Scout, Saddle Tramp, Vagabond, Pathfinder, Dinosaur Swamp O.C.C.s), and magic users tend to Shifter and Temporal Wizard. In GM Notes. || NOT STORED: size 6-7 feet, weight 130-210 lbs, life span 6D6+260 years, NPC level 2D4, slave market value, allies, enemies, habitat; in GM Notes."
---

## Lore

The A''rac are tall, lean D-Bees descended from spider-like ancestors. They
walk upright on two thin legs and have two thin arms, yet they are as strong
as a bionic human. Each hand has four fingers and two thumbs covered in
microscopic hairs that let them climb almost anything. Their heads are a
spider''s, with two large black eyes, two small ones below them and a false
pair above, and four toothed mandibles for a mouth; they live on liquefied
meat and blood. The skin is a fine, glossy shell of tiny plates.

They are curious, studious and gentle, and their calm manner does much to
win over people who flinch at their faces. A''rac wander the Megaverse for
the sake of learning, keep careful journals of everything they see, and
often settle down after an adventure to write about it. Most pass through
Earth''s Rifts on the way to somewhere else, so only a few stay.

Those who do stay despise willful ignorance. They gather at Lazlo and New
Lazlo, speak out against the Coalition States and the Federation of Magic,
teach reading in the ''Burbs, and some smuggle banned books through the
Black Market.

## GM Notes

Size 6-7 feet (1.8 to 2.1 m), tall and lean. Weight 130 to 210 lbs (58.5 to
94.5 kg). Life span 6D6+260 years; mature by 18; females lay 1D4 eggs after
an 8 month gestation and can bear young until 200; the eggs hatch three
months later. Experience Level for NPCs: 2D4.

Available O.C.C.s: drawn to Scholar and Adventurer occupations, especially
explorers such as the Wilderness Scout, Saddle Tramp, Vagabond, Pathfinder
and most Dinosaur Swamp O.C.C.s; they avoid combat O.C.C.s but often know a
few Weapon Proficiencies. Those who learn magic lean toward Shifter and
Temporal Wizard. They love sensors, computers, electronics, books and data.

Habitat: cool, dry climates preferred, but found anywhere. Fewer than two
thousand in the US and Canada, mostly in the East and the Magic Zone: about
thirty at New Lazlo, four times that at Lazlo, and isolated communities of
4D6x10. The vampires of Mexico drive them off, since A''rac blood cannot be
drunk.

Slave Market Value: 1D6x10,000 credits as an intelligent slave, half that
for the arena or labor.

Allies: lovers of knowledge and exploration - Aardan Tek, Adna Nomads,
Dewtani, N''reta, dragons, Mystics, Rogue Scholars and Scientists. Enemies:
the Coalition States, the Federation of Magic, and the Splugorth and their
minions; they are wary of Spinne and never trust the Chasseur Vert. Many
humans take them for monsters.
',
       updated_at = datetime('now')
 WHERE class_id = 'arac'
   AND instr(markdown, 'prose; see BOOK-INGEST-AUDIT.md F116.') > 0
   AND length(markdown) = 9275;

-- == chasseur-vert ==
UPDATE imported_classes
   SET markdown = '---
id: chasseur-vert
name: Chasseur Vert
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.46-48
category: rcc
tags: [stealth, wilderness]
men_of_arms: false
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6+6"
  MA: "3d6+6"
  PS: "3d6+6"
  PP: "2d6+6"
  PE: "2d6+6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 2d6 per level"
ppe_base: "1d6"
occ_restrictions:
  except: ["combat-cyborg", "cs-cyborg-strike-trooper", "destroyer-borg", "fq-cyborg-soldier", "fq-cyborg-dervish", "fq-cyborg-imprimer", "fq-cyborg-leviathan", "fq-cyborg-slasher", "mining-borg", "ngr-cyborg-soldier", "ojahee-borg", "plains-borg", "republic-cyborg-soldier", "cyborg-shocktrooper", "ninja-borg", "warlord-heavy-machine", "warlord-light-machine"]
  note: "Military-minded Green Hunters lean toward Wilderness Scout, Special Forces, Military Specialist, Merc Soldier, Bandit and similar O.C.C.s. Artists, philosophers and scholars fall under Rogue Scholar or Vagabond. Mystics and Ley Line Walkers are most common among the magically inclined. Cybernetics and bionics are incompatible with their physiology."
bonuses:
  pools: { sdc: "2d6x10" }
  combat: { strike: 2, roll: 1 }
  saves: { other: [ { label: "vs toxic chemicals, pollutants and defoliants", bonus: -2 } ] }
natural_abilities:
  - name: "Plant Physiology"
    description: "A carnivorous, intelligent plant with a root-like skeleton and sap in place of blood. Thick fibrous skin gives a natural A.R. of 12. Impervious to human diseases."
  - name: "Forearm Thorns"
    description: "Two retractable thorns in the forearms deal 2D6 S.D.C. plus the toxin (see Venin) and attribute bonus damage."
special_abilities:
  - name: "Chameau (Water Absorption)"
    description: "Absorbs water by drinking, from pools or tanks, or from the air in a humid enough environment. Soaks up enough water in 1D4 hours to survive two days per level of experience."
  - name: "Camouflage"
    description: "Changes skin color to blend with natural surroundings. In vegetation, from scrub desert to rainforest, 90% undetectable if completely still, 70% if moving two feet (0.6 m) per melee round or slower, 20% if moving 6 feet (1.8 m) per melee round; useless at any faster pace. Reduced by -60% in a purely artificial environment; city parks, gardens and preserves impose no penalty."
  - name: "Croissance (Regeneration)"
    description: "Heals twice as fast as a human and regrows lost limbs and extremities in 1D4+1 months, starting as small sprouts."
  - name: "Discretion (Stealth)"
    description: "Prowl 76% +3% per level when moving through vegetation and natural landscapes; halved in an urban or artificial environment. +2 on Perception Rolls in a natural setting."
  - name: "Parfum (Chemical Lure)"
    description: "Exudes an intoxicating pheromone that lures animal prey, range about 2,500 feet (762 m) depending on the wind. Requires a save vs non-lethal poison; on a failure the prey blindly seeks the source, becomes euphoric, loses half its melee attacks and is -5 on initiative and -3 to strike, parry and dodge. Penalties are half against intelligent life forms (round down)."
  - name: "Seve (Sap)"
    description: "Secretes a powerful sticky sap from the hands, used to repair broken items and to entrap foes. A good layer can stick a grown human or an item of up to 300 pounds (135 kg); a combined P.S. of 25 is needed to pull free. Solvents such as gasoline, mineral spirits and bestine neutralize it. One melee round (15 seconds) to secrete enough to glue a person to a tree."
  - name: "Tetu (Root to Ground)"
    description: "Takes one melee to root to the ground and then cannot be budged; uprooting takes a Supernatural P.S. greater than the Green Hunter''s P.E. +1 point per level. Works only on natural surfaces (stone, soil, sand), never concrete, asphalt, metal or other man-made surfaces."
  - name: "Venin (Poison)"
    description: "The forearm thorns inject a toxin: within 1D4 melee rounds the victim falls ill and suffers -2 on all combat bonuses and -10% on all skills and speed. The victim must then save vs lethal poison every ten minutes for two hours or take 2D6 damage directly to Hit Points, and is nauseated, cramped and racked with sweats and chills throughout."
trackable_resources: []
restrictions:
  - "Alignment: any, but good and selfish alignments predominate."
  - "Cybernetics and bionics: none; incompatible with Chasseur Vert physiology. Cyborg O.C.C.s are excluded by name."
side_effects: "Ennui: after more than two weeks living in a city a Chasseur Vert grows agitated and surly and sinks into a depression: -2 to Perception Rolls, -4 on initiative, -2 to all combat rolls and -25% on all skills. Solaire Actionne (Solar Powered): needs four hours of natural sunlight a day (double under a grow lamp); after 48 hours without light it loses 25% of its Hit Points, then 10% every 48 hours until it dies. Defeuillez (Poison Vulnerability): -2 to save against toxic chemicals, pollutants and especially defoliants; a defoliant spray or gas does 3D6 S.D.C. per blast and immersion 1D6x10 damage per minute. Faim (Dietary Needs): must eat five pounds of meat a week or suffer starvation (Rifts World Book 27: Adventures in Dinosaur Swamp, pages 13-14). Faiblesse (Fear of Blades): takes double damage from edged and slashing weapons, and facing a foe wielding one must save vs Horror Factor 10 (14 against Vibro-Blades) or be panic-stricken, losing initiative and suffering -2 to all combat rolls."
extraction_notes: "WB30 D-Bees of North America printed 46-48 (cache p047-p049), numbers read off 200 dpi renders. The brief listed 46-47; Experience Level through Rivals and Enemies are on printed 48, so source_book cites 46-48. Tag line: Chasseur Vert - Optional Player Character or NPC. || CATEGORY: a race that takes an occupation; no R.C.C. skills printed. men_of_arms false. No xp_table: the book prints no ladder for the race, which uses its O.C.C.''s. || POOLS: Hit Points P.E. plus 2D6 per level. S.D.C. 2D6x10, stored as a pool bonus (never sdc_base). M.D.C. by armor only. A.R. 12 is ability text. Horror Factor not applicable. P.P.E. 1D6. || BONUSES: +2 strike and +1 roll with impact stored. +2 Perception in a natural setting is conditional and is in the Discretion ability. Impervious to human diseases is ability text. The -2 to save vs toxic chemicals and defoliants is saves.other. || SKILLS: the Prowl 76% +3% per level in natural surroundings is conditional (halved in cities) and is a special ability, not the catalog Prowl. || LEVEL-GATED: water absorption lasting two days per level, and the uprooting threshold of P.E. +1 per level, are prose; not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). || OCCUPATIONS: printed as favorites, not limits; Cybernetics and Bionics None, incompatible with the physiology, so the catalog''s cyborg O.C.C.s are excluded by name. || EQUIPMENT and MONEY: as per O.C.C. || NOT STORED: size 5 ft to 6 ft 6 in, weight 150-190 lbs, life span 2D6+50 years, NPC experience level 1D4, Also known as (Green Hunters, Plant Men, Libertines), psionics standard, magic only by O.C.C., habitat (forests of southern and eastern Canada and east of the Mississippi; first sighted 105 P.A.; fewer than 2,000 in North America), slave market value 3D6x1,000 credits, allies and enemies (the Spinne, tyrants and slavers). The ability names carry French accents in the book; they are written without them."
---

## Lore

The Chasseur Vert, or Green Hunters, are intelligent carnivorous plants
from the same world as the Spinne Spider People, their ancient rivals.
The old wars between the two have cooled into scorn on both sides: the
Green Hunters pity the Spinne as prisoners of tradition, which the
Spinne find maddening. For ages the Chasseur Vert hunted the Spinne for
sport and food, though that ended generations ago.

They stand around six feet, broad and strong, with cool, smooth, light
green skin like an aloe, tangled green-brown tendrils for hair, glittering
stone-like eyes and a jack-o''-lantern grin of sharp teeth. They live on
sunlight but still need meat, and can change color and release a
pheromone to bring prey to them, which makes them superb trappers,
scouts and rangers. They despise cities, build open, sunny homes of
natural materials, and live in large, close families. Passionate
hedonists and thinkers, they love food, drink, art and argument,
produce many poets, artists and philosophers, and are tireless foes of
tyranny and slavery. They first appeared on Rifts Earth in 105 P.A., and
fewer than two thousand live in North America.
',
       updated_at = datetime('now')
 WHERE class_id = 'chasseur-vert'
   AND instr(markdown, 'are prose; see BOOK-INGEST-AUDIT.md F116.') > 0
   AND length(markdown) = 8578;

-- == forest-warden ==
UPDATE imported_classes
   SET markdown = '---
id: forest-warden
name: Forest Warden
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.90-93
category: rcc
tags: [wilderness, stealth]
attribute_dice:
  IQ: "2d6+1"
  ME: "2d6"
  MA: "2d6"
  PS: "4d6+2"
  PP: "2d6+6"
  PE: "3d6+12"
  PB: "2d4+1"
  Spd: "2d6+6"
mdc_base: "P.E. x3, +2d6 per level"
ppe_base: "6d6"
horror_factor: 12
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
bonuses:
  combat: { attacks_base: 5, initiative: 1, perception: 2, strike: 1, parry: 3, dodge: 1, pull_punch: 2, roll: 3 }
  saves: { coma_death_pct: 10, mind_control: 3, possession: 5 }
  at_level:
    - { level: 3, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
    - { level: 15, combat: { attacks: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "Native tongue is American at 90%; if Forest Wardens ever had a language of their own, it is forgotten." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: Other, two of choice (+10%); a language skill cannot exceed 90%. Taken once per language." }
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5% where applicable." }
    - { name: "Astronomy & Navigation", base: 50, per_level: 5, note: "+20%." }
    - { name: "Botany", base: 55, per_level: 5, note: "+30%." }
    - { name: "Brewing", base: 35, per_level: 5, note: "+10%." }
    - { name: "Camouflage", base: 50, per_level: 5, note: "+30%." }
    - { name: "Climbing", base: 65, per_level: 5, note: "+25%." }
    - { name: "Detect Ambush", base: 50, per_level: 5, note: "+20%." }
    - { name: "Detect Concealment", base: 25, per_level: 5 }
    - { name: "Firefighting", base: 45, per_level: 5, note: "+15%." }
    - { name: "Holistic Medicine", base: 35, per_level: 5, note: "+15%." }
    - { name: "Identify Plants & Fruit", base: 35, per_level: 5, note: "+10%." }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%." }
    - { name: "Lore: Demons & Monsters", base: 25, per_level: 5 }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Mathematics: Basic (20%), read as +20%." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%." }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%." }
    - { name: "Tracking (people)", base: 30, per_level: 5, note: "+5%." }
    - { name: "Trap/Mine Detection", base: 35, per_level: 5, note: "+15%." }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%." }
    - { name: "Zoology", base: 40, per_level: 5, note: "+10%." }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. Energy Pistol or Energy Rifle, pick one." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice, any, Ancient or Modern." }
  occ_related_skills:
    count: 0
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - { name: "Wilderness", bonus: 15 }
      - "Weapon Proficiencies"
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
  - { item_id: "bowl-earthenware", qty: 1, note: "A set of clay bowls; the page prints no count." }
  - { item_id: "hammock", qty: 1, note: "A woven grass mat and/or hammock." }
  - { item_id: "forest-warden-throwing-stone", qty: "2d6+6" }
  - { item_id: "purse-satchel", qty: 1, note: "A woven grass satchel, or one stolen from a traveler." }
  - { item_id: "forest-warden-walking-stick-or-club", qty: 1 }
  - { item_id: "e-clip", qty: 2, note: "Two E-Clips for each W.P. weapon." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "M.D.C. equal to the P.E. attribute number x3, plus 2D6 M.D. per level of experience. In S.D.C. environments: Hit Points equal to P.E. x3 plus 2D6 per level, and S.D.C. equal to P.E. x5 plus 4D6 per level."
  - name: "Supernatural strength"
    description: "P.S. is Supernatural. Damage as per Supernatural Strength or weapon."
  - name: "Plant physiology"
    description: "Needs no oxygen, only a small steady supply of trace carbon dioxide. Lives on sunlight, wild berries, fruit, grasses, roots, tubers and water; needs four hours of sun a day or its bonuses are halved (round down) until it spends another six hours in the sun. Bio-regenerates 2D6 M.D.C. an hour."
  - name: "Senses"
    description: "Sees by thermal-imaging to about 4,000 feet (1,220 m); hearing equal to a human''s."
  - name: "Impervious"
    description: "Impervious to human disease (but may be affected by plant diseases), carcinogens, poisons, toxins, normal heat and cold (extreme conditions affect it as they would a human), and symbiotic union or control."
  - name: "Brachiation and camouflage"
    description: "Prehensile hands and feet with four to eight long fingers and one or two thumbs let it swing from limb to limb through the forest, and when it stands still it blends in with the native plants; it can stand motionless for hours waiting in ambush."
special_abilities:
  - name: "Attacks per melee"
    description: "Five attacks at level one, plus one additional attack at levels 3, 6, 9, 12, 15, 18, 22 and 30."
  - name: "Throwing stones and clubs"
    description: "Baseball-sized throwing stones: 2D6 S.D.C. from a restrained throw, 1D4 M.D. from a full strength throw, 2D4 M.D. from a power throw that counts as two melee attacks. A walking stick or club does the same damage as a thrown stone."
level_progression:
  - { level: 3, grants: ["+1 attack per melee"] }
  - { level: 6, grants: ["+1 attack per melee"] }
  - { level: 9, grants: ["+1 attack per melee"] }
  - { level: 12, grants: ["+1 attack per melee"] }
  - { level: 15, grants: ["+1 attack per melee; further attacks at levels 18, 22 and 30 lie past the 15-level ladder."] }
trackable_resources: []
restrictions:
  - "Player Character Note: not recommended as a player character; its alien thinking is hard to play, and one outside the Dark Woods of Alabama is secretive, paranoid and naive, and flies into a rage at anyone who wilfully harms plant life."
  - "Alignment: any, but the vast majority are Anarchist (40%) or Aberrant (50%)."
  - "Available O.C.C.s: none. A Forest Warden relies on its limited R.C.C. skills and abilities."
  - "Secondary Skills: none."
  - "Psionics: none. Magic: none, despite a high P.P.E."
  - "Vulnerability: all Mega-Damage fire, plasma included, does double damage, with a 70% chance the character combusts and takes half the initial damage each melee round until the fire is put out. S.D.C. fire does damage as M.D., with only a 10% chance of combustion."
  - "Begins to slow down around age 300: reduce all physical attributes and bonuses by half."
  - "Never wears armor or uses force fields. Cybernetics and Bionics: none; incompatible with its physiology."
  - "Standard equipment: a set of clay bowls, a woven grass mat and/or hammock, 2D6+6 baseball-sized throwing stones, a woven grass satchel or one stolen from a traveler, a walking stick or club; one in 40 has a magic weapon or Techno-Wizard device. Also one weapon with two E-Clips for each W.P."
  - "Money: none as such. The average NPC Forest Warden holds 1D6x10,000+50,000 credits worth of stolen technology (tech weapons, E-Clips, armor, tool kits)."
extraction_notes: "D-Bees of North America printed 90-93 (cache p091-p094, cache page = printed + 1), every number read off 200 dpi renders. Printed 90 is a full-page art plate; the text runs 91-93 and ends at Rivals and Enemies above the Ganka heading. Tag line: Forest Warden R.C.C. - Optional NPC or Player Character, with a Player Character Note that it is not recommended but possible; stored as playable with that note as a restriction. || CATEGORY: an R.C.C. that takes no O.C.C. (Available O.C.C.s: None). || XP_TABLE: the Experience Level line says Use the Psi-Stalker experience table, so the catalog psi-stalker class''s stored ladder is copied, per the class-import reference rule (Nate''s decision 2026-09-26). This departs from the batch brief''s no-xp_table default, which assumed entries defer to the chosen O.C.C.''s table. The Attacks per Melee line also says use Dragon experience table; that conflicts with the Experience Level line, and the Experience Level line was taken as the authority. || ATTRIBUTES as printed; P.S. 4D6+2 is Supernatural, ability text. || M.D.C. P.E. x3 plus 2D6 per level as mdc_base; no men_of_arms line. The S.D.C.-environment Hit Points (P.E. x3 +2D6 per level) and S.D.C. (P.E. x5 +4D6 per level) are natural ability text. || HORROR FACTOR 12. P.P.E. 6D6 stored; +3D6 for every 50 years of life is not stored (age is not modelled) and is in GM Notes. || ATTACKS: five at level one, stored as attacks_base 5, plus one at levels 3, 6, 9, 12 and 15 as at_level attacks; the further attacks at 18, 22 and 30 lie past the 15-level ladder and are in level_progression and an ability (not modelled; BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). hand_to_hand costs {} because the race grants no Hand to Hand and its related categories offer none. || BONUSES: +1 initiative, +2 Perception, +1 strike, +3 parry, +1 dodge, +2 pull punch, +3 roll, +10% vs coma/death, +3 vs mind control, +5 vs possession. A successful mind control lasts half as long is GM Notes. || SKILLS: catalog base plus printed bonus. Language: Native Tongue is American at 90% (stored base 90, per_level 0). Mathematics: Basic printed (20%) without a plus sign, read as +20% like every other figure in the list (45+20=65). Detect Concealment and Lore: Demons & Monsters print no bonus. Acrobatics (+5% where applicable) stored as 35. || RELATED: two at levels 2, 4, 8, 12, 16 and 20; the schedule stores 2, 4, 8 and 12, and 16 and 20 lie past the 15-level ladder (not modelled; BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). Categories Communications, Domestic +10, Technical +5, Wilderness +15, W.P. any. Secondary Skills: none. || EQUIPMENT: one weapon per W.P. is weapons-matching-w-p-skills. Granted since ~116 and ~117: the clay bowls as bowl-earthenware (the page prints no count), the grass mat or hammock as hammock, the 2D6+6 throwing stones as forest-warden-throwing-stone (2D6 S.D.C./1D4 M.D./2D4 M.D. power throw), the grass satchel as purse-satchel, the walking stick or club as forest-warden-walking-stick-or-club, and the two E-Clips for each W.P. weapon as e-clip; the stones'' and club''s damage is also a special ability and the list is also a restriction line. Money: none; the NPC stolen-tech figure is a restriction line, not starting_money. || NOT STORED: size, weight, life span, birthing, habitat, slave value, allies and enemies are in GM Notes."
---

## Lore

Forest Wardens are plant-like D-Bees who make the Dark Woods of Alabama a
deadly place for anyone on two legs. They look like sickly or withered trees
brought to life as old men or hags: thin, long-limbed and long-nosed, with
two to five dark amber eyes, beards and manes of leaves, needles or willow
wands, and trunk-like legs. There are several breeds, each resembling a
different Earth tree, such as willow, pine, oak or elm. They swing through
the canopy from limb to limb and vanish among the trees when they stand
still.

They were torn from their own world by the Great Cataclysm and have spent
close to three centuries holding the Dark Woods against a world they do not
understand. Experience has taught them to trust nothing that walks on two
legs, and they ambush intruders, above all large groups, without warning.
Anyone who harms the forest, by logging, clearing land, starting a fire or
blasting the trees with Mega-Damage weapons, is marked for death.

They are not evil by nature. They accept folk born in the woods, sometimes
befriend outsiders, and can be kind and loyal to those they trust. Though
they live a Stone Age life, they are cunning enough to use the guns,
Vibro-Blades and explosives they take from those they kill.

## GM Notes

Also known as Tree Men, Bark Hags and Forest Lords; Voodooists of the Deep
South call them Gran Bwa''s Children. Size 7-11 feet (2.1 to 3.3 m). Weight
300 to 1,000 pounds (135 to 450 kg). P.P.E. rises by 3D6 for every 50 years
of life. Life span 2D4x10+420 years; mature at 30; slows at around 300.
Once a century a female bears 2D6x10 seedlings, each rooted in place for
1D4+10 years with only 5D6 M.D.C., guarded by at least 20 Wardens.

A successful mind control on a Forest Warden lasts half as long as usual.

Habitat: almost exclusively the Dark Woods and parts of Mississippi; only a
few thousand exist, in communal groups of 10-40. Believed to have come
through a Rift near the old town of Selma, Alabama. Slave market value
2D4x1,000 credits.

Allies: none but their own kind. Enemies: they fear and loathe humans and
other destroyers of nature.
',
       updated_at = datetime('now')
 WHERE class_id = 'forest-warden'
   AND instr(markdown, 'an ability (BOOK-INGEST-AUDIT.md F116).') > 0
   AND length(markdown) = 13096;

-- == squilb ==
UPDATE imported_classes
   SET markdown = '---
id: squilb
name: Squilb
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.198-200
category: rcc
tags: []
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6+6"
  PS: "3d6+9"
  PP: "2d6+6"
  PE: "3d6+4"
  PB: "2d6+2"
  Spd: "3d6+6"
hit_points_base: "P.E. x2, +1d6 per level"
ppe_base: "2d6"
occ_restrictions:
  except: ["juicer", "coalition-juicer", "hyperion-juicer", "titan-juicer", "phaeton-juicer", "mega-juicer", "delphi-juicer", "dragon-juicer", "juicer-gladiator", "juicer-assassin", "juicer-scout", "juicer-wannabe", "euro-juicer", "ninja-juicer", "songjuicer", "crazy", "ultra-crazy", "ninja-crazy", "combat-cyborg", "ngr-cyborg-soldier", "fq-cyborg-soldier", "fq-cyborg-imprimer", "fq-cyborg-dervish", "fq-cyborg-slasher", "fq-cyborg-leviathan", "cs-cyborg-strike-trooper", "republic-cyborg-soldier", "cyborg-shocktrooper", "mining-borg", "destroyer-borg", "ojahee-borg", "plains-borg", "ninja-borg", "dragon-borg-wing-blade", "dragon-borg-tsunami", "dragon-borg-imperial-combat", "dragon-borg-flame-cloud", "warlord-light-machine", "warlord-heavy-machine", "geofront-demon-eater-geo-borg", "geofront-assault-geo-borg", "geofront-lion-geo-borg"]
  note: "Pretty much any O.C.C. that does not involve human augmentation, such as Cyborgs, Juicers and Crazies. Favorites are combat O.C.C.s: all Soldiers (CS equivalents), Commando, Cyber-Knight, Merc Soldier, Body Fixer, Operator, Vagabond, Wilderness Scout and Squire of the White Rose, and now and then a Mystic or Elemental Fusionist."
bonuses:
  pools: { sdc: "1d6x10+16" }
  combat: { attacks: 1, initiative: 2, strike: 1, parry: 1, disarm: 2, pull_punch: 3, roll: 2 }
  saves: { horror_factor: 1, possession: 5 }
psionics:
  type: "minor"
  isp_base: "M.E. + 2d6, +1d6 per level"
  powers_starting: 2
  categories_allowed: ["Sensitive"]
natural_abilities:
  - name: "Keen senses"
    description: "Nightvision 200 feet (61 m), exceptional hearing and fast reflexes."
special_abilities:
  - name: "Hidden Strength"
    description: "In times of stress such as combat or an emergency, the Squilb''s strength rises to the equivalent of Robot Strength and it can inflict limited Mega-Damage (Rifts Ultimate Edition p.285). Lasts 2 minutes +1 minute per level of experience. Usable twice per day, plus one more time at levels 2, 5, 8 and 12. Afterwards the Squilb is exhausted and fights at half its normal combat bonuses for the next three hours."
  - name: "Empathic Link"
    description: "A Squilb that serves the same person for more than six months forms an empathic link with that master or leader: it knows if the master is in danger, worried, happy, upset or sick, and roughly where he is, and can gauge how satisfied the master is with its service."
  - name: "Aptitude for service"
    description: "+10% to Domestic skills, in addition to any O.C.C. bonuses."
level_progression:
  - { level: 2, grants: ["Hidden Strength: one more use per day (three)"] }
  - { level: 5, grants: ["Hidden Strength: one more use per day (four)"] }
  - { level: 8, grants: ["Hidden Strength: one more use per day (five)"] }
  - { level: 12, grants: ["Hidden Strength: one more use per day (six)"] }
restrictions:
  - "Alignment: any, but they lean toward Principled (30%), Scrupulous (40%) and Unprincipled (20%)."
  - "Magic: none, unless a Magic O.C.C. is selected (rare)."
  - "Cybernetics and bionics are possible, but Squilbs shy away from them in favor of Bio-Systems."
  - "Money: as per O.C.C., plus 1D4x1,000 credits in trade goods or black market items."
side_effects: "No vulnerabilities as such, though the obsession with duty and the instinctive need to serve and protect has its drawbacks. After Hidden Strength ends: half normal combat bonuses for three hours."
extraction_notes: "WB30 D-Bees of North America printed 198-200 (cache p199-p201, cache page = printed + 1); every number read off a 200 dpi render. Heading Squilbs - Optional Player Character or NPC, printed 198. || CATEGORY: a race that takes an O.C.C.; the entry prints no experience ladder and names none (Experience Level 1D6 for NPCs, player characters start at first level), so no xp_table. || POOLS: Hit Points P.E. attribute number x2 plus 1D6 per level stored as hit_points_base. S.D.C. 1D6x10+16 is a racial S.D.C. and is a pool bonus, never sdc_base. men_of_arms false, as for every race. P.P.E. 2D6. Horror Factor: not applicable, so none stored. || BONUSES: +1 attack per melee, +2 initiative, +1 strike and parry, +2 disarm, +3 pull punch, +2 roll with impact, +1 vs Horror Factor stored as printed; +5 to save vs demonic possession stored as possession 5 (judgement: the book qualifies it as demonic). || PSIONICS: select two powers from the Sensitive category, a Minor Psychic, I.S.P. M.E. +2D6 plus 1D6 per level. || HIDDEN STRENGTH: twice per day plus one more use at levels 2, 5, 8 and 12; level-gated uses are level_progression prose, not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this). No trackable_resources is stated, because a fixed max of 2 would be wrong from level 2; the count is in the ability text. || SKILL NOTE: +10% to Domestic skills in addition to any O.C.C. bonuses has no race-level carrier and is a special ability; the sheet does not add it. || AVAILABLE O.C.C.s: stored as occ_restrictions except, naming every Rifts Juicer, Crazy and cyborg O.C.C. in the catalog on 2026-10-03 (the book''s Cyborgs, Juicers and Crazies); an augmentation O.C.C. added later is not on the list. The favorites list is a tendency and is the note. || MONEY: printed as per O.C.C. plus 1D4x1,000 credits in trade goods. Not stored as starting_money, because a race''s starting_money replaces the occupation''s in a pairing rather than adding to it; it is a restriction line. || EQUIPMENT: as per O.C.C., favoring spears and pole arms; nothing stored. || NOT STORED: size 7-9 feet, weight 300-500 pounds, life span 4D6+100 years, slave market value 3D6x1,000, allies, enemies, habitat and the NEMA note are GM Notes."
---

## Lore

Squilbs are wrinkle-skinned humanoids, golden to reddish or dark brown, with
small dark eyes, a button nose and black, brown or gray hair grown only from
the base of the skull and usually braided with the emblem of the clan or
master they serve. Their history survives only as stories acted out from
parent to child. They turn up on other worlds as well as Earth, and are a
common sight on the Atlantean slave block, so some scholars suspect they
were once bred as a servant race.

Called the Bronze Squires (and, less kindly, Raisin Heads), Squilbs are
drawn to service under a worthy cause or leader, as lawmen, knights, squires
to Cyber-Knights or rangers. They are without vanity, will do any work that
needs doing, and will give their lives for a just cause, but a master who
deceives or misuses them is soon left for a more honorable one. Thousands
died defending Tolkeen and helping its people escape.

## GM Notes

Size 7-9 feet (2.1 to 2.7 m); weight 300-500 pounds (135 to 225 kg), all
muscle. Life span 4D6+100 years; mature at 16. Slave market value 3D6x1,000
credits.

Allies: most races get along with them; they are drawn to Glitter Boys,
Cyber-Knights, Justice Rangers, Reid''s Rangers, Blucies, Malvoren and
charismatic heroes. Enemies: demons, tyrants, slavers and evildoers, above
all the Brodkil, Thornhead Demons and Neuron Beasts; they also dislike
Loaks, Ganka, Lanotaur Hunters, Witchlings, Witch Wolves, Black Faeries,
Simvan, Worm Wraiths, the undead and the Minions of Splugorth. They oppose
the Coalition leadership rather than every citizen.

Habitat: across the continent, most numerous in the New West, the American
Southwest, southern Canada and northern Mexico. An estimated 1D4x10,000
along the Mexican border stand ready to march on the Vampire Kingdoms. Old
tales link the first Squilbs to the NEMA forces of the Great Cataclysm.
',
       updated_at = datetime('now')
 WHERE class_id = 'squilb'
   AND instr(markdown, 'prose, see BOOK-INGEST-AUDIT.md F116.') > 0
   AND length(markdown) = 7864;

-- == vernulian ==
UPDATE imported_classes
   SET markdown = '---
id: vernulian
name: Vernulian
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.210-212
category: rcc
tags: []
attribute_dice:
  IQ: "3d6"
  ME: "4d6"
  MA: "4d6"
  PS: "4d6"
  PP: "4d6"
  PE: "4d6"
  PB: "1d6"
  Spd: "4d6"
mdc_base: "P.E. + 1d6x10, +1d4 per level"
ppe_base: "6d6"
horror_factor: 14
psionics:
  type: "major"
  isp_base: "M.E. + 1d6x10, +1d6+1 per level"
  powers: ["Telepathy", "Telekinesis", "Mind Block"]
  powers_starting: 4
  categories_allowed: ["Healing", "Sensitive", "Physical"]
skills:
  occ_skills:
    - { name: "Climbing", base: 70, per_level: 5, note: "+30%" }
    - { name: "Swimming", base: 75, per_level: 5, note: "+25%" }
    - { name: "Prowl", base: 45, per_level: 5, note: "+20%" }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { choose: 1, from: ["Language: Other"], bonus: 25, note: "Telepathic aptitude: one new spoken language every level of experience, each with a +25% bonus. One is granted at level one; the rest are level_progression text." }
variants:
  - id: military
    name: "Vernulian Soldier (Military Special Forces)"
    bonuses:
      combat: { attacks: 3, strike: 1, parry: 4, automatic_dodge: 3, entangle: 4, disarm: 2, pull_punch: 4 }
      saves: { horror_factor: 2, toxins_poisons: 2 }
  - id: refugee
    name: "Vernulian Refugee"
    bonuses:
      combat: { attacks: 2, perception: 1, parry: 2, dodge: 2, entangle: 2 }
      saves: { toxins_poisons: 2 }
natural_abilities:
  - name: "Mega-Damage serpent body"
    description: "Main body: 1D6x10 + P.E. attribute number, +1D4 M.D.C. per level of experience. Each of the four tentacles has 2D6+10 M.D.C. Damaged tentacles or tail section heal at 2D6 M.D. per 24 hours and completely regenerate within 1D4+3 weeks if destroyed or chopped off. P.S. is Augmented."
  - name: "Senses and swimming"
    description: "Perfect color vision that does not deteriorate with age. Swims across the surface or through the water, holds its breath for two minutes per P.E. attribute point, and tolerates depths to 600 feet (183 m)."
  - name: "Tentacle arms"
    description: "Four sensitive, strong prehensile tentacles suited to delicate work and machines (though not as well as fingers). Suction cups let the Vernulian climb sheer walls and smooth surfaces such as glass, marble and ice, and swing through trees that can bear its weight. Each tentacle reaches half the length of the body."
  - name: "Serpentine movement"
    description: "Moves with the upper body held erect to imitate a humanoid''s walk (half normal Spd), or slithers at full Spd. Low profile ideal for prowling, hiding and surprise attacks; squeezes through openings as narrow as 9 inches (23 cm)."
special_abilities:
  - name: "Pinning Body Flip"
    description: "Counts as one attack. The opponent loses one attack and initiative and takes 2D6 + P.S. damage bonus, and there is a 01-70% chance the serpent entangles/pins the off-balance victim, who then cannot move or attack until released."
  - name: "Special Entangle"
    description: "Entangles/pins one opponent with two arms while attacking him with the other pair. The pinned victim cannot strike back and takes damage until he breaks the hold. The Vernulian can keep the hold while parrying or parrying and striking someone else with the other two arms, but at half its usual bonuses; if it dodges, the victim is let loose. Each escape attempt (wiggle, roll or power free with P.S.) costs the victim two melee attacks and the Vernulian one; both roll a D20, bonuses apply only for the Vernulian, high roll wins."
  - name: "Constriction Attack/Bear Hug"
    description: "Wraps the body or two tentacles around an opponent, pinned or not, for punch damage + P.S. damage bonus per crush. The victim breaks free only by pulling the tentacles off with a combined P.S. 10 points higher than the Vernulian''s, or by chopping them off."
  - name: "Force field collar"
    description: "Soldiers wear an energy field generator collar with an invisible force field of 160 M.D.C.; only 30% of refugees have a similar device with 100 M.D.C. Both regenerate 10 M.D.C. an hour. Limited to 12 hours a day or it overloads and shuts down for 24 hours. It also keeps the body warm during cool periods. Not a starting item: the military collar is the soldiers'' only, and not every refugee has one."
  - name: "Telekinetic triggers"
    description: "Vernulian-made weapons have concealed triggers worked by Telekinesis; the shooter must still point and aim. Telekinesis can also operate human equipment, including guns and computers."
level_progression:
  - { level: 2, grants: ["One new spoken language at +25% (Telepathic aptitude), and one more at each level after"] }
restrictions:
  - "Alignment: any. Military Vernulians lean toward Unprincipled (5%), Anarchist (25%), Aberrant (35%), Miscreant (20%) and Diabolic (10%); refugees toward Scrupulous (15%), Unprincipled (35%) and Anarchist (30%)."
  - "Available O.C.C.s: theoretically any. Military Vernulians do not practice magic and may be the equivalent of most Men at Arms O.C.C.s except the Juicer, Crazy, Glitter Boy and Cyber-Knight. Only refugees consider a practitioner of magic O.C.C., and they are rare."
  - "Magic: none, except by O.C.C. (rare)."
  - "Money and standard equipment: as per O.C.C."
side_effects: "The serpentine body and tentacles frighten and alarm humans and most warm-blooded people and make disguise impossible; many take them for demons or monsters on sight. -10% skill penalty when using complicated devices designed for humanoids, such as computers."
extraction_notes: "WB30 D-Bees of North America printed 210-212 (cache p211-p213, cache page = printed + 1); every number read off a 200 dpi render. Heading Vernulian - Optional Player Character and NPC, printed 211. The entry notes it first appeared in Rifts World Book One: Vampire Kingdoms; this book is the source cited. || CATEGORY: a race that takes an O.C.C.; Experience Level (Military 2D4+1, Refugees 1D8, player characters start at first level) names no ladder, so no xp_table. mdc_base is stated, so no men_of_arms line. || ATTRIBUTES: I.Q. 3D6, M.A. 4D6, M.E. 4D6, P.S. 4D6 (Augmented), P.P. 4D6, P.E. 4D6, P.B. 1D6, Spd 4D6; Augmented is ability text. || M.D.C.: main body 1D6x10 + P.E. and 1D4 per level stored as mdc_base; tentacles 2D6+10 each are ability text. Horror Factor 14. P.P.E. 6D6. || VARIANTS: the book prints two bonus lines. Military: +3 attacks per melee, +1 strike, +4 parry, +3 automatic dodge, +4 entangle, +2 disarm, +4 pull punch, +2 vs Horror Factor, +2 vs poison. Refugees: +2 attacks, +1 Perception Rolls, +2 parry, +2 dodge (not automatic), +2 entangle, +2 vs poison. Save vs poison is toxins_poisons. Stored as two variants, military and refugee; the parent states no bonuses. || PSIONICS: Major Psychic with Telepathy (4), Telekinesis (varies) and Mind Block (4) by name, plus four more from Healing, Sensitive and/or Physical; I.S.P. 1D6x10 plus M.E. and 1D6+1 per level. || SKILLS: Climbing 40+30, Swimming 50+25, Prowl 25+20, W.P. Paired Weapons. One new spoken language each level at +25% is stored as one Language: Other at 50+25 at level one; the later languages are level_progression prose, not modelled - BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this - (judgement: every level read as including the first). || COMBAT: attacks per melee as per Hand to Hand; the Pinning Body Flip, Special Entangle and Constriction moves are special abilities with their printed numbers. || EQUIPMENT: as per O.C.C. The force field collar (160 M.D.C. military, 100 M.D.C. commercial; regenerates 10 an hour; 12 hours a day) is a special ability and, since ~116 and ~117, the rows vernulian-force-field-collar-military and vernulian-force-field-collar-commercial; the class grants neither, because the military collar is the soldiers'' only and about 30% of refugees have the commercial one. Statted items with no catalog row, not stored as gear: the Serpent Power Armor (head 100, tentacles 100 each, main body 300, six underside hover jets 25 each, two main hover jets 75 each, flies to 300 feet, 400 mph, military only) and the Serpent Borg full conversion (P.S. 30, P.P. 26, Spd 50; optional bionic legs biped Spd 88 or quadruped Spd 220; jet pack Spd 365; retractable Vibro-Sword 3D6 M.D. or Vibro-Claws 3D6 M.D.; two tentacle blasters; tail blaster as laser rod with double range and +2D6 M.D.; Medium Infantry body armor 300 M.D.C.; plus 1D4+3 bionic weapons or implants) are GM Notes. || AVAILABLE O.C.C.s: no occ_restrictions; the book allows any and its limits depend on faction (a variant cannot carry occ_restrictions), so they are a restriction line. || NOT STORED: size 2D6+8 feet long, weight 3D4x100 lbs, life span 3D8+76 years, slave market value 2D4x10,000, allies, enemies and habitat are GM Notes."
---

## Lore

Vernulians are giant serpents with four octopus-like tentacle arms, a
salamander''s head, unsettlingly human eyes and a mouth full of human-looking
teeth. In northern Mexico, where they are most common, they are called the
Children of Cihuacoatl after the Aztec Serpent Woman.

Two kinds have come to Rifts Earth. Military Special Forces scouts, sent on
secret Black Ops missions, judge the planet unfit to colonize but ideal as a
launch point for raids and a source of alien technology; they are ruthless,
look down on mammals as prey and food, and disguise their attacks as the work
of vampires or bandits. Political refugees fled a despotic home world
through stolen portals, several thousand of them since 101 P.A.; most are
gentle idealists who want only peace, though persecution has made them wary
of strangers, and about a quarter have become as cruel as the soldiers who
hunt them.

## GM Notes

Also known as Serpent People, Demon Serpents, V-Snakes, Cihuacoatls and
Children of Cihuacoatl. Size 2D6+8 feet (3 to 6.1 m) long; can rear up to
three quarters of its length. Weight 3D4x100 lbs (135 to 540 kg). Life span
3D8+76 years; mature at 10. Slave market value 2D4x10,000 credits.

Serpent Power Armor (military only): head 100 M.D.C., tentacles (4) 100
each, main body 300, hover jets (6 underside) 25 each, main hover jets (2 on
back) 75 each; flies to 300 feet (91 m) at up to 400 mph (640 km).

Serpent Borgs (20% of soldiers are full conversion cyborgs): P.S. 30, P.P.
26, Spd 50; optional bionic legs (biped Spd 88, quadruped Spd 220) or a
detachable jet pack (Spd 365); one retractable giant Vibro-Sword (3D6 M.D.)
or a set of Vibro-Claws (3D6 M.D.); two tentacle blasters as forearm
blasters; a tail blaster as a laser rod with double range and +2D6 M.D.;
Medium Infantry body armor 300 M.D.C.; plus 1D4+3 bionic or cybernetic
weapons or implants.

Most refugees have given up eating humanoids for small mammals and birds.
Military characters are often the equivalent of a Coalition Grunt, Military
Specialist, Technical Officer, Elite RPA Pilot, Ranger, Commando, Special
Forces, RCSG Scientist, Bounty Hunter, Gunfighter, Gunslinger, Bandit,
Headhunter, Combat Cyborg, Pirate, Sailor or Wilderness Scout; refugees are
most often Adventurer and Scholar O.C.C.s.

Allies: none as such; refugees accept others and despise slavers and
tyrants. Enemies: soldiers treat all Earthlings and intelligent mammals as
prey; other reptilian peoples are rivals. Habitat: as of 109 P.A., mostly
northern Mexico and the American Southwest, but anywhere in the Americas.
',
       updated_at = datetime('now')
 WHERE class_id = 'vernulian'
   AND instr(markdown, 'prose, see BOOK-INGEST-AUDIT.md F116 (judg') > 0
   AND length(markdown) = 11410;

-- == oni-of-the-one-hundred ==
UPDATE imported_classes
   SET markdown = '---
id: oni-of-the-one-hundred
name: Oni of the One Hundred
system: rifts
source_book: Rifts World Book 8: Japan p.199-203
category: rcc
tags: [supernatural]
men_of_arms: false
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "2d6"
  PS: "2d6+22"
  PP: "2d6+12"
  PE: "2d6+16"
  PB: "1d6"
  Spd: "6d6"
mdc_base: "2d6x10+40"
ppe_base: "5d6"
horror_factor: 11
bonuses:
  combat: { attacks_base: 4, initiative: 1, strike: 2, parry: 2, dodge: 2, pull_punch: 2, roll: 1 }
  saves: { horror_factor: 6 }
  at_level:
    - { level: 6, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
magic:
  type: "spell"
  spells: ["Tongues"]
skills:
  occ_skills:
    - { name: "Intelligence", base: 36, per_level: 4, note: "+4%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the book prints track humanoids." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: W.P. blunt, W.P. sword and two of choice (any)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks Japanese at 98%." }
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "Faerie at 98%. The catalog has no Faerie language row; take Language: Other and name it Faerie." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Can learn two other languages (+10%). Taken once per language - the picker asks which." }
  secondary_skills:
    count: 4
    categories: ["Espionage", "Physical", "Technical", "Rogue", "Wilderness"]
trackable_resources:
  - { key: spell-casts, label: "Natural spell casts", max: 8, reset_on: day, note: "As many as 8 spells from the oni''s power group (and Tongues) per 24 hours. Natural abilities, not learned spell magic." }
special_abilities:
  - choose: 1
    from: ["Oni Powers (01-25): Curses", "Oni Powers (26-50): Blight", "Oni Powers (51-75): Fire", "Oni Powers (76-00): Wind and Storm"]
    note: "Every Oni of the One Hundred has one of four sets of natural magic powers (printed 202). Select one, or roll percentile dice. All four include Tongues."
  - name: "Oni Powers (01-25): Curses"
    description: "Percentile 01-25. Natural spell-like powers: Fear, Compulsion, Luck Curse, Minor Curse, Repel Animals and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Fear", "Compulsion", "Luck Curse", "Minor Curse", "Repel Animals"] }
  - name: "Oni Powers (26-50): Blight"
    description: "Percentile 26-50. Natural spell-like powers: Befuddle, Blind, Sickness, Spoil (food and water), Animate and Control Dead, and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Befuddle", "Blind", "Sickness", "Spoil", "Animate and Control Dead"] }
  - name: "Oni Powers (51-75): Fire"
    description: "Percentile 51-75. Natural spell-like powers: Globe of Daylight, Ignite Fire, Cloud of Smoke, Fire Ball, Fool''s Gold and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Globe of Daylight", "Ignite Fire", "Cloud of Smoke", "Fire Ball", "Fool''s Gold"] }
  - name: "Oni Powers (76-00): Wind and Storm"
    description: "Percentile 76-00. Natural spell-like powers: Breathe Without Air, Fly as the Eagle, Wind Rush, Summon Fog, Summon Storm and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Breathe Without Air", "Fly as the Eagle", "Wind Rush", "Summon Fog", "Summon Storm"] }
  - { choose: 1, from: ["Body (01-20): Perfectly Human", "Body (21-50): Broad, Muscular Human", "Body (51-60): Skeletal Human", "Body (61-65): Snail-like Blob", "Body (66-70): Buddha", "Body (71-80): Toad", "Body (81-90): Bird", "Body (91-95): Giant", "Body (96-00): Fish"], note: "General Body Shape (printed 201), rolled once. Appearance only: no result carries a number the sheet adds. The giant (91-95) changes the oni''s size." }
  - name: "Body (01-20): Perfectly Human"
    description: "Roll 01-20 or choose. A perfectly human body."
  - name: "Body (21-50): Broad, Muscular Human"
    description: "Roll 21-50 or choose. A broad, muscular human body."
  - name: "Body (51-60): Skeletal Human"
    description: "Roll 51-60 or choose. A skeletal human body."
  - name: "Body (61-65): Snail-like Blob"
    description: "Roll 61-65 or choose. A lumpy blob, like a snail."
  - name: "Body (66-70): Buddha"
    description: "Roll 66-70 or choose. Looks like a buddha: fat and bald."
  - name: "Body (71-80): Toad"
    description: "Roll 71-80 or choose. Toad-like: large, round, fat and flabby, with no neck."
  - name: "Body (81-90): Bird"
    description: "Roll 81-90 or choose. Bird-like: barrel chested, a broad upper body, a narrow lower abdomen and a short, thick neck."
  - name: "Body (91-95): Giant"
    description: "Roll 91-95 or choose. Humanoid but giant: 8 feet (2.4 m) plus 1D4 additional feet (0.3 to 1.2 m), so 9 to 12 feet tall in place of the usual 4 to 5 feet. The height is a figure to read and roll; the pick changes no number on the sheet."
  - name: "Body (96-00): Fish"
    description: "Roll 96-00 or choose. Fish-like: a long body complete with scales, fins and tail."
  - { choose: 1, from: ["Head (01-05): Wild Boar", "Head (06-15): Lion or Cat", "Head (16-30): Human", "Head (31-40): Skeletal Human", "Head (41-45): Monkey", "Head (46-55): Melon", "Head (56-60): Fish", "Head (61-65): Snake", "Head (66-70): Bird", "Head (71-80): Rotting Skeleton", "Head (81-90): Neanderthal", "Head (91-95): Fox or Canine", "Head (96-00): Rat"], note: "Oni Head Shape (printed 201), rolled once. The result adds to the Horror Factor of 11, and the pick adds it." }
  - name: "Head (01-05): Wild Boar"
    description: "Roll 01-05 or choose. The head of a wild boar. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (06-15): Lion or Cat"
    description: "Roll 06-15 or choose. The head of a lion or cat. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (16-30): Human"
    description: "Roll 16-30 or choose. A human head. No Horror Factor bonus (11)."
  - name: "Head (31-40): Skeletal Human"
    description: "Roll 31-40 or choose. A skeletal human head with sunken features. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (41-45): Monkey"
    description: "Roll 41-45 or choose. The head of a monkey. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (46-55): Melon"
    description: "Roll 46-55 or choose. A large head, round like a melon. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (56-60): Fish"
    description: "Roll 56-60 or choose. A fish-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (61-65): Snake"
    description: "Roll 61-65 or choose. A snake-like head. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (66-70): Bird"
    description: "Roll 66-70 or choose. A bird-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (71-80): Rotting Skeleton"
    description: "Roll 71-80 or choose. A human head that looks like a rotting skeleton. Applied: +4 Horror Factor (15)."
    horror_factor_bonus: 4
  - name: "Head (81-90): Neanderthal"
    description: "Roll 81-90 or choose. A larger, thicker human skull with heavy brow ridges and a square chin. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (91-95): Fox or Canine"
    description: "Roll 91-95 or choose. The head of a fox or other canine. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (96-00): Rat"
    description: "Roll 96-00 or choose. A rat-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - { choose: 1, from: ["Nose (01-10): Normal Human", "Nose (11-20): Bulbous", "Nose (21-30): Pointed", "Nose (31-50): Ape-like", "Nose (51-60): Bird", "Nose (61-70): Animal Snout", "Nose (71-80): Tiny", "Nose (81-85): Snake", "Nose (86-90): Rat", "Nose (91-00): None"], note: "Oni Nose (printed 201), rolled once. Appearance only. A roll of 71-80 is a tiny nose of one of the types above it: choose the type or roll again on this table for it." }
  - name: "Nose (01-10): Normal Human"
    description: "Roll 01-10 or choose. A normal human nose."
  - name: "Nose (11-20): Bulbous"
    description: "Roll 11-20 or choose. A bulbous nose three times larger than a normal human''s."
  - name: "Nose (21-30): Pointed"
    description: "Roll 21-30 or choose. A pointed nose three times larger than a normal human''s."
  - name: "Nose (31-50): Ape-like"
    description: "Roll 31-50 or choose. A large, wide, flat nose like an ape''s, two times larger than a normal human''s."
  - name: "Nose (51-60): Bird"
    description: "Roll 51-60 or choose. A bird nose; it can be shaped like a hawk''s or a sparrow''s."
  - name: "Nose (61-70): Animal Snout"
    description: "Roll 61-70 or choose. An animal snout, like that of a boar, hog or fox."
  - name: "Nose (71-80): Tiny"
    description: "Roll 71-80 or choose. A tiny nose: any of the types above it on this table (choose one, or roll again on the table for the type), but two times smaller than normal. Note the type beside the pick."
  - name: "Nose (81-85): Snake"
    description: "Roll 81-85 or choose. A snake nose: two small holes or slits above the mouth."
  - name: "Nose (86-90): Rat"
    description: "Roll 86-90 or choose. A rat nose."
  - name: "Nose (91-00): None"
    description: "Roll 91-00 or choose. No nose, not even an opening for one."
  - { choose: 1, from: ["Eyes (01-10): Wild Human", "Eyes (11-20): Glowing Almond", "Eyes (21-40): Large Round", "Eyes (41-50): Small, Unnatural", "Eyes (51-60): Snake", "Eyes (61-70): Bird", "Eyes (71-80): Normal Human", "Eyes (81-90): Four Eyes", "Eyes (91-00): One Large Eye"], note: "Oni Eyes (printed 201), rolled once. Appearance only. A roll of 81-90 is four eyes: roll again on this table (or pick) for their shape." }
  - name: "Eyes (01-10): Wild Human"
    description: "Roll 01-10 or choose. Large human eyes with a wild or crazed look to them."
  - name: "Eyes (11-20): Glowing Almond"
    description: "Roll 11-20 or choose. Huge almond-shaped eyes that glow red like a fire, or sparkling gold, yellow, amber or orange."
  - name: "Eyes (21-40): Large Round"
    description: "Roll 21-40 or choose. Large round eyes that are white, pink, pale blue, green, or clear like a crystal ball."
  - name: "Eyes (41-50): Small, Unnatural"
    description: "Roll 41-50 or choose. Small eyes of an unnatural red, yellow or black."
  - name: "Eyes (51-60): Snake"
    description: "Roll 51-60 or choose. Snake eyes that sparkle gold or silver."
  - name: "Eyes (61-70): Bird"
    description: "Roll 61-70 or choose. Bird eyes that look like jade."
  - name: "Eyes (71-80): Normal Human"
    description: "Roll 71-80 or choose. Normal human eyes."
  - name: "Eyes (81-90): Four Eyes"
    description: "Roll 81-90 or choose. Four eyes. Roll again on this table for the eye shape, or pick one, and note the shape beside the pick."
  - name: "Eyes (91-00): One Large Eye"
    description: "Roll 91-00 or choose. One large round eye that is a pale blue or violet."
  - { choose: 1, from: ["Mouth (01-10): Toad Mouth, Flat Teeth", "Mouth (11-20): Human, Crooked Teeth", "Mouth (21-30): Human, Fangs", "Mouth (31-40): Oversized Human", "Mouth (41-50): Monkey", "Mouth (51-60): Lipless Toad Slit", "Mouth (61-70): Canine Muzzle", "Mouth (71-80): Flabby, Flat Teeth", "Mouth (81-90): Flabby, Toothless", "Mouth (91-00): Tiny Slit"], note: "Oni Mouth (printed 201), rolled once. The result sets the bite damage, which is a figure to read rather than a number the sheet adds." }
  - name: "Mouth (01-10): Toad Mouth, Flat Teeth"
    description: "Roll 01-10 or choose. A large toad-like mouth with flabby lips and an even row of large, flat teeth. Bite: 2D4 M.D."
  - name: "Mouth (11-20): Human, Crooked Teeth"
    description: "Roll 11-20 or choose. A human mouth with crooked teeth. Bite: 1D4 M.D."
  - name: "Mouth (21-30): Human, Fangs"
    description: "Roll 21-30 or choose. A human mouth with fangs and sharp teeth. Bite: 2D4 M.D."
  - name: "Mouth (31-40): Oversized Human"
    description: "Roll 31-40 or choose. A human mouth twice the normal size, with large, pointed, crooked teeth. Bite: 3D4 M.D."
  - name: "Mouth (41-50): Monkey"
    description: "Roll 41-50 or choose. A large monkey-like mouth of sharp teeth and big fangs. Bite: 3D6 M.D."
  - name: "Mouth (51-60): Lipless Toad Slit"
    description: "Roll 51-60 or choose. A large toad mouth with no lips, a long slit full of tiny, sharp teeth. Bite: 2D6 M.D."
  - name: "Mouth (61-70): Canine Muzzle"
    description: "Roll 61-70 or choose. A canine mouth and short muzzle with a dog''s teeth and fangs. Bite: 3D6 M.D."
  - name: "Mouth (71-80): Flabby, Flat Teeth"
    description: "Roll 71-80 or choose. A large mouth with flabby, quivering lips and large, flat, crooked teeth. Bite: 2D4 M.D."
  - name: "Mouth (81-90): Flabby, Toothless"
    description: "Roll 81-90 or choose. A large mouth with flabby, quivering lips and no teeth at all. Bite: one point of mega-damage."
  - name: "Mouth (91-00): Tiny Slit"
    description: "Roll 91-00 or choose. A tiny slit half the size of a human mouth, lipless, with tiny teeth and a thin snake''s tongue. Bite: 1D4 M.D."
  - { choose: 1, from: ["Arms (01-20): Human", "Arms (21-30): Oversized Pair and a Third Arm", "Arms (31-45): Two-Fingered Claws", "Arms (46-56): Gnarled, Skeletal Hands", "Arms (57-67): Monkey-like Claws", "Arms (68-75): Squirrel or Rat-like", "Arms (76-85): Five Arms", "Arms (86-95): Bird Claws", "Arms (96-00): Tentacles"], note: "Oni Arms & Hands (printed 201), rolled once. The M.D. figure is the hand attack for that kind of arm; an extra attack per melee is added by the pick." }
  - name: "Arms (01-20): Human"
    description: "Roll 01-20 or choose. Perfectly human arms and hands, no claws. 1D6 M.D."
  - name: "Arms (21-30): Oversized Pair and a Third Arm"
    description: "Roll 21-30 or choose. A pair of large, oversized, muscular arms (3D6 M.D.) and a third, smaller arm with two clawed fingers and a thumb (2D6 M.D.). Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (31-45): Two-Fingered Claws"
    description: "Roll 31-45 or choose. Muscular human arms ending in clawed hands of two fingers and a thumb. 3D6 M.D."
  - name: "Arms (46-56): Gnarled, Skeletal Hands"
    description: "Roll 46-56 or choose. Thin, gnarled arms, muscular but misshapen, with skeletal hands and long clawed fingers. 2D6 M.D."
  - name: "Arms (57-67): Monkey-like Claws"
    description: "Roll 57-67 or choose. Muscular arms, monkey-like in shape and length, with three-fingered claws and a thumb. 2D4 M.D."
  - name: "Arms (68-75): Squirrel or Rat-like"
    description: "Roll 68-75 or choose. Short, spindly arms like a squirrel''s or rat''s, with small articulated hands and fingers. 1D4 M.D."
  - name: "Arms (76-85): Five Arms"
    description: "Roll 76-85 or choose. Five arms of equal size and proportion. 3D6 M.D. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (86-95): Bird Claws"
    description: "Roll 86-95 or choose. Powerful arms with bird-like clawed hands. 3D6 M.D."
  - name: "Arms (96-00): Tentacles"
    description: "Roll 96-00 or choose. Octopus-like tentacles in place of arms, twice the length of human arms. 2D6 M.D. from a whip attack. Applied: +4 to entangle, which the book prints as +4 to entangle, grab or hold."
    bonuses: { combat: { entangle: 4 } }
  - { choose: 1, from: ["Legs (01-15): Human", "Legs (16-25): Monkey-like", "Legs (26-50): Classic Oni", "Legs (51-60): Skeletal, Two-Toed", "Legs (61-70): Bird-like", "Legs (71-80): Human, Clawed Toes", "Legs (81-90): Animal-like", "Legs (91-00): Snail Trunk"], note: "Oni Legs (printed 201), rolled once. The result sets the Spd attribute: every row prints its own Spd dice and the pick sets them, so Spd is rolled on the picked row''s dice (from 3D6 to 6D6+10)." }
  - name: "Legs (01-15): Human"
    description: "Roll 01-15 or choose. Perfectly human legs, no claws. Applied: Spd is rolled on 5D6."
    attribute_dice: { Spd: "5d6" }
  - name: "Legs (16-25): Monkey-like"
    description: "Roll 16-25 or choose. Short, stubby monkey-like legs; waddles when walking and lopes on all fours to run. Prehensile feet add +10% to balance and climbing, by hand. Applied: Spd is rolled on 4D6."
    attribute_dice: { Spd: "4d6" }
  - name: "Legs (26-50): Classic Oni"
    description: "Roll 26-50 or choose. Powerfully built upper legs, rather thin lower legs, and feet with two large clawed toes. Applied: Spd is rolled on 6D6+10."
    attribute_dice: { Spd: "6d6+10" }
  - name: "Legs (51-60): Skeletal, Two-Toed"
    description: "Roll 51-60 or choose. Skeletal legs with the classic two-toed, clawed feet. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (61-70): Bird-like"
    description: "Roll 61-70 or choose. Spindly stick legs and clawed bird feet. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (71-80): Human, Clawed Toes"
    description: "Roll 71-80 or choose. Human feet with clawed toes. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (81-90): Animal-like"
    description: "Roll 81-90 or choose. Animal legs, hooved or like a bear''s (the book prints ''hover''). Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (91-00): Snail Trunk"
    description: "Roll 91-00 or choose. No feet or legs: a snail-like trunk that slithers. +4 to maintain balance, by hand. Applied: Spd is rolled on 3D6."
    attribute_dice: { Spd: "3d6" }
  - { choose: 1, from: ["Feature (01-07): Rat Tail", "Feature (08-14): Tiny Scales", "Feature (15-21): Small Horns", "Feature (22-28): Large Horns", "Feature (29-35): Large Mane", "Feature (36-42): Bushy Eyebrows and Beard", "Feature (43-49): Lumpy Flesh", "Feature (50-56): Hairy Body", "Feature (57-64): Hairless, Pale Skin", "Feature (65-72): Boils or Scabs", "Feature (73-80): Pot Belly", "Feature (81-87): Hunchback", "Feature (88-94): Lizard Tail", "Feature (95-00): Fur"], note: "Other Features (printed 201-202), rolled once. Seven of the results add to M.D.C. and the pick adds them." }
  - name: "Feature (01-07): Rat Tail"
    description: "Roll 01-07 or choose. The tail of a rat."
  - name: "Feature (08-14): Tiny Scales"
    description: "Roll 08-14 or choose. Skin covered in tiny scales. Applied: +35 M.D.C."
    bonuses: { pools: { mdc: 35 } }
  - name: "Feature (15-21): Small Horns"
    description: "Roll 15-21 or choose. A pair of small horns. Head butt: 1D4 M.D."
  - name: "Feature (22-28): Large Horns"
    description: "Roll 22-28 or choose. A pair of large horns. Head butt: 2D6 M.D."
  - name: "Feature (29-35): Large Mane"
    description: "Roll 29-35 or choose. A large mane of black, red, gold or green hair."
  - name: "Feature (36-42): Bushy Eyebrows and Beard"
    description: "Roll 36-42 or choose. Bushy eyebrows and a scraggly beard."
  - name: "Feature (43-49): Lumpy Flesh"
    description: "Roll 43-49 or choose. Lumpy pink or white flesh. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (50-56): Hairy Body"
    description: "Roll 50-56 or choose. A hairy body with tan or red skin. Applied: +20 M.D.C."
    bonuses: { pools: { mdc: 20 } }
  - name: "Feature (57-64): Hairless, Pale Skin"
    description: "Roll 57-64 or choose. No hair anywhere on the body, and pale skin."
  - name: "Feature (65-72): Boils or Scabs"
    description: "Roll 65-72 or choose. Boils or scabs cover the body. Applied: +25 M.D.C."
    bonuses: { pools: { mdc: 25 } }
  - name: "Feature (73-80): Pot Belly"
    description: "Roll 73-80 or choose. A pot belly on an otherwise muscular body. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (81-87): Hunchback"
    description: "Roll 81-87 or choose. A hunchback. Applied: +5 M.D.C."
    bonuses: { pools: { mdc: 5 } }
  - name: "Feature (88-94): Lizard Tail"
    description: "Roll 88-94 or choose. The tail of a lizard."
  - name: "Feature (95-00): Fur"
    description: "Roll 95-00 or choose. Covered in fur. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - { choose: 1, from: ["Skin (01-10): Brown or Tan", "Skin (11-20): Reddish Brown", "Skin (21-30): Light or Dark Red", "Skin (31-40): Fiery Red", "Skin (41-50): Light Green", "Skin (51-60): Jade Green", "Skin (61-70): Light Blue", "Skin (71-80): Pale Grey", "Skin (81-90): Stark White or Ivory", "Skin (91-00): Mustard or Yellow Brown"], note: "Skin Color (printed 202), rolled once. Appearance only." }
  - name: "Skin (01-10): Brown or Tan"
    description: "Roll 01-10 or choose. Brown or tan skin."
  - name: "Skin (11-20): Reddish Brown"
    description: "Roll 11-20 or choose. Reddish brown skin."
  - name: "Skin (21-30): Light or Dark Red"
    description: "Roll 21-30 or choose. Light or dark red skin."
  - name: "Skin (31-40): Fiery Red"
    description: "Roll 31-40 or choose. Fiery red skin."
  - name: "Skin (41-50): Light Green"
    description: "Roll 41-50 or choose. Light green skin."
  - name: "Skin (51-60): Jade Green"
    description: "Roll 51-60 or choose. Jade green skin."
  - name: "Skin (61-70): Light Blue"
    description: "Roll 61-70 or choose. Light blue skin."
  - name: "Skin (71-80): Pale Grey"
    description: "Roll 71-80 or choose. Pale grey skin."
  - name: "Skin (81-90): Stark White or Ivory"
    description: "Roll 81-90 or choose. Stark white or ivory skin."
  - name: "Skin (91-00): Mustard or Yellow Brown"
    description: "Roll 91-00 or choose. Mustard or yellow brown skin."
natural_abilities:
  - { name: "Nightvision", description: "500 feet (152 m); can see even in total darkness." }
  - { name: "Fire and Cold Resistant", description: "Fire and cold do half damage." }
  - { name: "Impervious to Disease", description: "Cannot catch or suffer from disease." }
  - { name: "Bio-Regeneration", description: "2D6 M.D. per hour." }
  - { name: "Supernatural Attributes", description: "All attributes are considered supernatural, including P.S. and P.E." }
  - { name: "Mega-Damage Creature", description: "A supernatural being from another dimension. M.D.C. 2D6x10+40, plus any M.D.C. from the Other Features appearance table; no hit points or S.D.C." }
  - { name: "Natural Attacks", description: "Restrained claw 5D6 S.D.C. plus P.S. damage bonus; full strength claw, punch or kick 3D6 M.D.; gore with horns 2D6+6 M.D.; power punch 6D6 M.D. (counts as two attacks); leap kick 1D4x10 M.D. (counts as two attacks); body flip/throw 2D6 M.D. The appearance tables give bite, arm and head butt damage that varies by oni." }
restrictions:
  - "Primarily an N.P.C. villain. A player character is entirely at the G.M.''s discretion, and is likely an outcast among its kind - possibly because of an anarchist, unprincipled or scrupulous alignment."
  - "Alignment: 45% miscreant, 30% diabolic, 5% aberrant, 15% anarchist and 5% other."
  - "Psionics: none."
  - "Magic: the four power sets are natural abilities; the oni knows no spell magic and cannot learn it as a spell caster does."
  - "Technology: too ignorant and impatient to learn to operate power armor, computers and vehicles. Fewer than 15% use energy weapons, rail guns or human body armor, and those only at a rudimentary level."
  - "Size: 4 to 5 feet (1.2 to 1.5 m), unless the body shape table makes it a giant. Weight: 100 to 250 pounds (45 to 112.5 kg)."
  - "Average life span: 250+ years."
  - "Average experience level for N.P.C.s: third level for a typical warrior, 1D4+2 for elite warriors, 1D4+4 for a war chief or clan leader."
  - "Horror Factor 11 is the factor the oni projects, plus the bonus from its head shape; its +6 to save vs Horror Factor is in bonuses."
side_effects: "Weakness for alcohol, which can be used as a bribe or to gather information. Carnivores who prefer human flesh. Money and equipment: none printed. Oni favor clubs, swords and axes, prize captured vibro-blades, rune weapons and magic arms and armor, and increasingly steal M.D. body armor and energy weapons; oni masters know a secret ritual that makes melee weapons inflict mega-damage and armor gain M.D.C. Appearance is rolled on the nine oni creation tables (see Appearance below), and all nine - body shape, head, nose, eyes, mouth, arms and hands, legs, other features and skin color - are picks under special abilities, in the book''s order."
extraction_notes: "Rifts World Book 8: Japan printed 199-203 (text layer, page_offset +1: cache p200-p204). General oni rules on printed 199-200 (cache p200 is WELDED and was checked against a render; the text layer reads cleanly in column order). The appearance tables run printed 201-202 (cache p202-p203). The stat block is Oni of the One Hundred (Lesser Oni) on printed 202, right column, continued to the top of printed 203 (habitat, war band, clan, village, enemies, allies), read off a render of printed 202. || NPC: the book''s note makes these primarily N.P.C. villains, a player character at the G.M.''s discretion; stated in restrictions and GM Notes. || XP: the ''Sura-Kappa, Oni of the One Hundred'' column on the Experience Point Tables page (cache p217, printed 216, read off a render; third column, middle): lower bounds 0 / 2,001 / 4,001 / 8,201 / 16,401 / 24,501 / 34,601 / 49,701 / 69,801 / 94,901 / 129,001 / 179,101 / 229,201 / 279,301 / 329,401. || GROUP: a race, so men_of_arms: false (heading Oni of the One Hundred (Lesser Oni), an R.C.C.). No supersedes_race: this is a race, not a transformation. || ATTRIBUTES: I.Q., M.E., M.A. 2D6; P.S. 22+2D6; P.P. 12+2D6; P.E. 16+2D6; P.B. 1D6; all supernatural (prose). Spd is not a fixed roll: it comes from the Oni Legs table (5D6 human legs 01-15, 4D6 monkey 16-25, 6D6+10 classic oni 26-50, 6D6 for 51-90, 3D6 snail trunk 91-00). The class states 6D6, the figure of four of the eight rows, and since 2026-10-05 every Legs option states its own row''s dice as attribute_dice, so the pick sets Spd. || POOLS: M.D.C. 2D6x10+40, plus Other Features additions (prose). P.P.E. 5D6 for a typical warrior. No hit points or S.D.C. (mega-damage creature). No starting money or equipment is printed. || HORROR FACTOR 11 plus the head shape bonus (+0 to +4), carried since 2026-10-05 as horror_factor_bonus on each Head option (BOOK-INGEST-AUDIT.md F119) and read off a render of printed 201: +2 boar, lion/cat, skeletal, fish, bird, fox/canine and rat; +1 monkey and neanderthal; +3 melon and snake; +4 rotting skeleton; none for the human head. || COMBAT: four attacks per melee as attacks_base 4, plus one at levels 6 and 12 as at_level. No hand to hand skill is printed and no price for one, so no hand_to_hand block. Bonuses as printed: +1 initiative, +2 strike, parry and dodge, +2 pull punch, +1 roll with punch/fall/impact, +6 vs horror factor. Damage figures are a natural ability (prose). || MAGIC: four sets of natural powers, one chosen or rolled, up to 8 casts per 24 hours. Each set is a chosen special ability carrying its spells; Tongues, common to all four, is granted by the class. The 8 casts are a trackable resource. Spoil (food & water) is the catalog''s Spoil; animate/control dead is Animate and Control Dead; fly as the eagle and fire ball as catalogued. || SKILLS: catalog base + printed bonus: Intelligence 32+4, track humanoids as Tracking (people) 25+10, Land Navigation 36+15, Climbing 40+10, Swimming 50+10; W.P. Blunt, W.P. Sword and two W.P.s of choice (any). Japanese as Language: Native Tongue at 98%, Gobblely at 98%, Faerie as a Language: Other pick at 98% (no Faerie row), and two other languages (+10%) as Language: Other picks. Four secondary skills from espionage, physical, technical, rogue and wilderness, as printed on the race. || APPEARANCE: the oni creation tables (body shape, head, nose, eyes, mouth, arms and hands, legs, other features, skin color) are random appearance tables, nine of them on printed 201-202 under ''Roll once on each unless indicated otherwise'', paraphrased in the body. Since 2026-10-03 the five single-roll tables whose results carry a number have been banded choose-1 groups in special_abilities: Head Shape (Horror Factor +0 to +4, as horror_factor_bonus), Mouth (bite damage, prose), Arms & Hands (hand damage as prose; +1 attack at 21-30 and 76-85 and +4 entangle at 96-00 as bonuses), Legs (Spd dice; see 2026-10-05 below) and Other Features (M.D.C. +35, +10, +20, +25, +10, +5, +10 as pool bonuses; head butt damage prose). The four power-set options were renamed with their bands the same day so the wizard can roll them. || 2026-10-05, LEGS (printed 201, read off a render): the eight rows print 5D6 (01-15), 4D6 (16-25), 6D6+10 (26-50), 6D6 (51-60, 61-70, 71-80, 81-90) and 3D6 (91-00) speed attribute. Each option now carries that as attribute_dice for Spd (BOOK-INGEST-AUDIT.md F120), and the classic oni''s +10 Spd bonus was removed because its row''s dice state 6D6+10. The monkey legs'' +10% to balance and climbing and the snail trunk''s +4 to maintain balance stay prose. || 2026-10-05, THE OTHER FOUR TABLES: General Body Shape (nine rows), Oni Nose (ten) and Oni Eyes (nine) on printed 201 and Skin Color (ten) on printed 202, all read off renders, are now banded choose-1 groups too, one definition per row, so all nine tables can be rolled. None of their rows carries a number the sheet adds. Kept as the row''s prose: Nose 71-80 (a tiny nose of any type above, choose or roll again), Eyes 81-90 (four eyes, roll again or pick for the shape) and Body 91-95 (a giant, 8 feet +1D4 feet). The groups are ordered as the book prints them, after the power sets: body, head, nose, eyes, mouth, arms and hands, legs, other features, skin color. No existing option was renamed."
---

## Lore

Oni is the Japanese word for demon, and Japanese legend knows hundreds of kinds, most without a proper name: an oni is called by its look ("the three-armed oni"), its temper, its deeds or its master. They stand for the nameless terrors of the night and are always ugly or frightening: animal heads, misshapen faces with huge noses and crooked teeth, manes of wild black or red hair, big clawed two-toed feet, horns on at least half of them, hunched and oddly shaped bodies. Most are small and goblin-like, four or five feet tall, though the occasional giant turns up.

The Oni of the One Hundred are the commonest oni: dull-witted, cruel beings who delight in murder, torture, kidnapping, robbery and vandalism against anything weaker. Tens of thousands of them roam the wilderness of the islands and dominate The Zone. They come from a dimension long linked to Japan; only a few hundred lived there in ancient times, where they became the demons, ghosts and goblins of old tales, but when the Rifts opened they flooded in by the thousands.

They travel in small tribal war bands that raid villages, waylay travelers and even slip into the reborn cities of the Republic. They enslave humans, sometimes rule whole villages, and carry off women and children as slaves, sacrifices or food. Power is the only authority they respect: the strongest warrior or mightiest magic-wielder leads, and every leader is challenged the moment he looks weak. Outsiders - wizards, warlords, pirates, greater demons - gain oni minions by beating the chief and his rivals, and keep them only by terror. Clans war on each other constantly, and nearly every oni boasts that he will one day rule Japan.

Oni are bold in numbers but easily cowed: feats of magic, great strength or courage can scatter a band, and defeating its one to five ringleaders usually sends the rest fleeing. Not all of them frighten, though, and some fight to the death. All are liars and backstabbers. They fear and covet "man''s technology" - power armor, cyborgs, robots and energy weapons - and steal M.D. body armor, vibro-blades and guns, but are too impatient to learn machines. Most still fight with tooth and claw, sheer strength and natural magic. They eat any humanoid or animal they kill and have a notorious weakness for alcohol.

## Appearance

Oni are rolled on the book''s creation tables, one roll per table. Each of the nine is a pick under special abilities that can be rolled or chosen. In summary:

- **Body shape:** from perfectly human, broad and muscular, or skeletal, through a lumpy snail-like blob, a fat bald buddha, a neckless toad, a barrel-chested bird-body, a giant of 9 to 12 feet, to a scaled fish with fins and tail.
- **Head:** boar, lion or cat, human, sunken skeletal, monkey, huge melon-round, fish, snake, bird, rotting skull, neanderthal, fox or rat. Each non-human head adds +1 to +4 to Horror Factor (the rotting skull +4, melon and snake +3).
- **Nose:** normal, huge bulbous or pointed, broad and ape-like, a bird''s beak, an animal snout, a tiny version of any of these, snake slits, a rat''s nose, or none at all.
- **Eyes:** wild and crazed, huge glowing almond eyes, large pale or crystal-clear orbs, small red, yellow or black eyes, sparkling snake eyes, jade bird eyes, ordinary human eyes, four eyes, or a single large pale blue or violet eye.
- **Mouth:** from toad-like mouths of flat teeth to fanged monkey and canine muzzles, a toothless flabby mouth or a lipless slit with a snake''s tongue; the bite does from 1 M.D. up to 3D6 M.D. depending on the mouth.
- **Arms and hands:** human hands, a third small clawed arm (an extra attack), two-fingered claws, skeletal talons, monkey or rat-like limbs, five arms (an extra attack), bird claws, or tentacles that whip and grab. Claw damage runs from 1D4 to 3D6 M.D. by type.
- **Legs:** human legs, stubby monkey legs, the classic oni legs with two clawed toes, skeletal or bird legs, clawed human feet, bear-like animal legs, or a slithering snail trunk. The leg type sets Spd, from 3D6 to 6D6+10.
- **Other features:** rat or lizard tail, fine scales, small or large horns (head butts), a great mane, bushy brows and beard, lumpy pink flesh, a hairy red or tan hide, hairlessness, boils and scabs, a pot belly, a hunchback, or fur. Several of these add 5 to 35 M.D.C.
- **Skin color:** brown or tan, reddish brown, red, fiery red, light or jade green, light blue, pale grey, stark white or ivory, or mustard yellow-brown.

## Society

A small war band is 1D6+4 oni, a medium one 3D6+12, and the largest seldom pass 80. Clans run from 20 to 40 members up to 300 to 500. An oni village holds several hundred oni from more than one clan, some goblins, imps and other supernatural hangers-on, a few human or D-bee allies, and hundreds of human and D-bee slaves. They live in wilderness, mountains, slums, sewers and ruins across Japan, Taiwan, Korea, China, and parts of India and Southeast Asia, mostly in The Zone and the Freelands, with a few tribes in the New Empire''s backwaters and the Republic''s alleys.

Their ancient enemies are tengu, yamabushi, bishamon, demon quellers, samurai, psi-stalkers, Atlantean Undead Slayers and a handful of gods. They avoid faerie folk, elementals, dragons and the kilin as threats rather than foes. Their allies are other oni and demons, vampires, goblins and goblin spiders, ogres, trolls, gargoyles, evil dragons, priests and sorcerers; the Horune pirates have traded with them for decades.

## GM Notes

The book makes the Oni of the One Hundred primarily an N.P.C. villain and leaves a player character entirely to the G.M.''s discretion. Such a character is probably an outcast from its tribe, often for an anarchist, unprincipled or scrupulous alignment. The average N.P.C. warrior is third level; elite warriors 1D4+2, war chiefs and clan leaders 1D4+4. One oni in ten is an oni master and one in fifty an oni mystic (separate entries).
',
       updated_at = datetime('now')
 WHERE class_id = 'oni-of-the-one-hundred'
   AND instr(markdown, 'attribute_dice for Spd (BOOK-INGEST-AUDIT.md F119)') > 0
   AND length(markdown) = 36318;

-- == amphib ==
UPDATE imported_classes
   SET markdown = '---
id: amphib
name: Amphib
system: rifts
source_book: Rifts World Book 7: Underseas p.98-100
category: rcc
tags: [aquatic]
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "4d6"
  PS: "3d6+12"
  PP: "4d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. x2, +1d6 per level"
sdc_base: "3d6x10"
ppe_base: "3d6"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  combat: { dodge: 2, roll: 1, pull_punch: 1 }
restrictions:
  - "Alignment: any, but most tend to good or selfish alignments."
  - "SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. Printed 100 has the player select either the Sea Wolf or the Tritonian Scientist O.C.C., or any other appropriate O.C.C. at the G.M.''s call including a magic O.C.C., and then REDUCE the number of available O.C.C. skills by three. The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a). Pick a second class by hand and drop three of its O.C.C. skills."
  - "Experience: use the Amphib table or the chosen O.C.C.''s table, whichever is HIGHER."
  - "THE STORED COMBAT BONUSES ARE ALL UNDERWATER-ONLY. Printed 100 gives +2 to dodge and +1 to roll with impact and pull punch underwater, and nothing on land. They are stored unconditionally because an amphib is an aquatic character and the sheet has no conditional slot - but a G.M. running an amphib on dry land should ignore all three."
  - "P.B. AND SWIMMING SPEED ARE ROLLED ON AN APPEARANCE TABLE: roll or pick the Appearance ability, whose seven options are the seven rows. Each row carries its own P.B. dice (3D6, 3D4, 2D6, 2D4, 2D6, 1D6, 1D6) and P.B. is rolled on the picked row''s dice; the class''s own 3D6 is the first row''s and is what shows before a row is picked. Spd 3D6 is the LAND speed; underwater it is 6D6 plus the row''s swimming bonus, which stays prose on the option because there is no swimming-speed field."
  - "S.D.C. is 3D6x10 plus skill, O.C.C. and appearance bonuses. The appearance bonus alone runs from nothing to 2D4x10."
  - "M.D.C.: by armour or magic only. The amphib is an S.D.C. creature."
  - "Horror Factor: 8, and only for those not used to the more unusual specimens."
  - "P.P.E. is 3D6 unless the character takes a magic O.C.C., whose own P.P.E. then applies (printed 99; yields_to_occupation, BOOK-INGEST-AUDIT F111)."
  - "Average life span: 90 years."
  - "Psionics: normal, the same as a human''s. No psionic block is granted."
  - "Magic: only if a magic O.C.C. is selected."
  - "There are over 100,000 amphibs living in the floating city of Tritonia."
special_abilities:
  - { choose: 1, from: ["Appearance (01-20): Perfect Human", "Appearance (21-40): Webbed Hands and Feet", "Appearance (41-60): Frog Skin", "Appearance (61-70): Fish Face", "Appearance (71-80): Scaly Skin", "Appearance (81-90): Scaly Skin and Fish Face", "Appearance (91-00): Oversized, Fish or Frog-Like"], note: "Appearance table (printed 99): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Appearance (01-20): Perfect Human"
    description: "Printed 99, roll 01-20. Looks entirely human, with no visible aquatic feature. No underwater speed bonus and no S.D.C. bonus. Holds its breath rather than breathing water. Applied: P.B. is rolled on 3D6."
    attribute_dice: { PB: "3d6" }
  - name: "Appearance (21-40): Webbed Hands and Feet"
    description: "Printed 99, roll 21-40. Flat webbed feet and webbing between the fingers; shoes and armoured footwear must be custom-made. Underwater speed +3D6, and +10 more when swimming with little or no clothing (prose: there is no swimming-speed field). No S.D.C. bonus. About 40% have gills as well as lungs; the other 60% hold their breath for inhumanly long periods. Applied: P.B. is rolled on 3D4."
    attribute_dice: { PB: "3d4" }
  - name: "Appearance (41-60): Frog Skin"
    description: "Printed 99, roll 41-60. Hairless, with unnaturally smooth, slick skin that is usually greenish-grey. Swimming speed +2D6, and +6 more with little or no clothing (prose: there is no swimming-speed field). Holds its breath. Applied: P.B. is rolled on 2D6, and +4D6 S.D.C."
    attribute_dice: { PB: "2d6" }
    bonuses: { pools: { sdc: "4d6" } }
  - name: "Appearance (61-70): Fish Face"
    description: "Printed 99, roll 61-70. A fish-shaped head with large, round, dark eyes and a wide mouth; the head may be finely scaled while the body keeps ordinary skin. Helmets and headgear must be custom-made. Swimming speed +2D6, and +8 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 2D4, and +3D6 S.D.C."
    attribute_dice: { PB: "2d4" }
    bonuses: { pools: { sdc: "3d6" } }
  - name: "Appearance (71-80): Scaly Skin"
    description: "Printed 99, roll 71-80. Hairless and covered in scales. Swimming speed +2D6, and +8 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 2D6, and +5D6 S.D.C."
    attribute_dice: { PB: "2d6" }
    bonuses: { pools: { sdc: "5d6" } }
  - name: "Appearance (81-90): Scaly Skin and Fish Face"
    description: "Printed 99, roll 81-90. Hairless, fish-scaled, with webbed hands and feet and the head of a fish on an otherwise humanoid body. Swimming speed +4D6, and +10 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 1D6, and +6D6 S.D.C."
    attribute_dice: { PB: "1d6" }
    bonuses: { pools: { sdc: "6d6" } }
  - name: "Appearance (91-00): Oversized, Fish or Frog-Like"
    description: "Printed 99, roll 91-00. More frog or fish than human, and big: 8 feet (2.4 m) plus 4D6 inches tall, and 300 lbs (136 kg) plus 2D6x10 lbs. Swimming speed +4D6, and +20 more with little or no clothing (prose: there is no swimming-speed field). The row prints no breathing line. Applied: P.B. is rolled on 1D6, and +2D4x10 S.D.C."
    attribute_dice: { PB: "1d6" }
    bonuses: { pools: { sdc: "2d4x10" } }
natural_abilities:
  - name: "Appearance"
    description: "Rolled on a percentile table at creation (printed 99), from 01-20 Perfect Human to 91-00 Oversized. Each of the seven rows sets the P.B. dice, an underwater speed bonus, an S.D.C. bonus and whether the amphib has gills. Roll or pick the row under the Appearance choice; each row''s figures are on its own entry there. Shoes, headgear and armour need custom fitting for most of these, and Tritonia has facilities for exactly that."
  - name: "Breathe Underwater"
    description: "A human-looking or frog-like amphib holds its breath for 5D6x3 minutes and must eventually surface, like a dolphin; using any artificial breathing apparatus it consumes less oxygen, effectively doubling the air and the time. A scaly, fish-like amphib has both lungs and gills and stays under indefinitely."
  - name: "Nightvision"
    description: "Excellent vision, seeing clearly in the near-total absence of light to 200 feet (61 m)."
  - name: "Resistant to Cold"
    description: "Survives indefinitely at freezing or near-freezing temperatures and takes half damage from cold-based attacks."
  - name: "Depth Tolerance"
    description: "Endures pressure at one mile (1.6 km) plus 300 feet (91.5 m) per level of experience without ill effect, and never gets the bends."
  - name: "Acute Underwater Senses"
    description: "Taste, hearing and smell are about four times as acute as a human''s underwater, letting the amphib taste or smell blood, death and decay, and foreign chemicals in the water at roughly 1000 yards/metres plus 100 per level of experience."
  - name: "Natural Combat"
    description: "As a human''s, depending on training. A restrained punch does 1D6 S.D.C. plus P.S. bonus, a full strength punch 3D6 S.D.C. plus P.S. bonus, and a power punch 1D4 M.D. counting as two attacks - the one mega-damage attack an otherwise S.D.C. race has."
extraction_notes: |
  - Underseas, printed 98-100. A race rather than an occupation: the product
    of pre-Rifts genetic experiments crossing humans with frogs and fish, of
    which 90% of the strains were crippling or lethal and the surviving 10%
    bred true.
  - ITS SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. This is the SECOND
    Underseas class to hit BOOK-INGEST-AUDIT.md F23(a), after the Sea
    Inquisitor, and it is the harder of the two: printed 100 does not merely
    borrow a list, it borrows one AND REDUCES IT BY THREE. There is no key for
    "use that class''s list" and none for "minus three from it". Added to
    F23(a)''s affected rows rather than filed as a new finding, per the batch
    rule. A character built from this row alone has no skills at all, which is
    the book''s shape rather than a dropped count.
  - THE STORED COMBAT BONUSES ARE UNDERWATER-ONLY AND ARE STORED ANYWAY. This
    is a deliberate exception to the rule that a conditional bonus is prose.
    Every other conditional in this book - a speed burst, a combat form, a
    bonus against supernatural beings - is a temporary state. Being underwater
    is this race''s normal condition, and a character sheet showing an amphib
    with no bonuses at all would be wrong more often than it was right. The
    condition is stated plainly in the restrictions.
  - THE APPEARANCE TABLE IS A CHOOSE-1 SPECIAL ABILITY WITH SEVEN BANDED
    OPTIONS, one per row of printed 99, each named for its band so the wizard
    can roll it. A row''s S.D.C. bonus is the option''s `bonuses.pools.sdc` and is
    applied. Its P.B. dice are the option''s own `attribute_dice` (see the
    2026-10-05 note below). Its swimming-speed bonus stays prose in the
    option''s description, because swimming speed has no attribute of its own.
    NOT modelled as `variants`: a variant replaces a block, and this is a roll
    rather than a choice.
  - 2026-10-05: EACH APPEARANCE ROW NOW CARRIES ITS P.B. DICE
    (BOOK-INGEST-AUDIT.md F120). All seven rows were re-read off a render of
    printed 99: 01-20 "P.B. is rolled on 3D6", 21-40 "P.B. is 3D4", 41-60
    "The P.B. is 2D6", 61-70 "P.B. is 2D4", 71-80 "P.B. is 2D6", 81-90 "P.B.
    is 1D6", 91-00 "P.B. is 1D6". Stored as `attribute_dice: { PB: ... }` on
    each option, the first row''s 3D6 included so that every row states its
    own. The class-level P.B. 3D6 is kept as the first row''s figure; the
    Attributes line itself prints only "P.B. varies with appearance". The
    sentences telling the player to roll P.B. again on the row''s dice
    themselves are gone. The S.D.C. bonuses (none, none, 4D6, 3D6, 5D6, 6D6,
    2D4x10) and the swimming bonuses (none, 3D6 +10, 2D6 +6, 2D6 +8, 2D6 +8,
    4D6 +10, 4D6 +20) were checked against the same render and all agree with
    what was already stored. The swimming bonuses remain prose: there is no
    swimming-speed field.
  - ALL SEVEN APPEARANCE ROWS ARE PRESENT AND ARE TRANSCRIBED. A first draft of
    this class claimed the table skipped 41-70 and called it OCR loss. THAT WAS
    WRONG, and it was wrong because the page was read through too short a
    window rather than because the cache was damaged: rows 41-60 (Frog Skin)
    and 61-70 (Fish Face) sit exactly where they should on printed 99. The same
    short read also conflated row 21-40 with row 61-70, giving the webbed-feet
    result the fish-face numbers. Both were caught by going back to the page
    before shipping. The table covers 01-00 with no gap.
  - SPD IS THE LAND SPEED of 3D6. Underwater it is 6D6 plus the appearance
    bonus, which can be another 4D6+20.
  - IT HAS ONE MEGA-DAMAGE ATTACK AND IS OTHERWISE AN S.D.C. RACE: the power
    punch does 1D4 M.D. `mdc_base` is absent and `sdc_base` is used, per
    printed 99, which says M.D.C. is by armour or magic only.
---

# Amphib

## Lore

The amphib race is the product of illegal genetic experiments dating from before the Coming of the Rifts - humans crossed with frogs and fish by scientists who wanted beings that looked entirely human and could breathe and swim underwater without equipment.

The mutations were unstable. Ninety percent of the strains were crippling or lethal, and hundreds of volunteers died horribly. When the atrocities became public the project was shut down and those responsible were punished for crimes against humanity.

That left the surviving ten percent: highly capable undersea creatures with superior strength, resistance to pressure and the ability to breathe both air and water. Most were humanoid, many were not human-looking, and most could reproduce - which meant mankind had accidentally created a new race. Under public scrutiny the government made them heroes rather than an embarrassment, and assigned them to the Tritonia project to explore and harness the last great wilderness on Earth.

## GM Notes

Over the centuries the amphibs have prospered on Tritonia, where more than a hundred thousand of them live. They get on with most intelligent creatures, have strong ties to Tritonia''s naut''yll community, and have a special relationship with dolphins - who regard them as friends and playmates closer than humans, able to swim alongside them while keeping the best human traits. Some dolphins and amphibs insist they are kindred spirits and children of the sea, and the two are often sent out together on exploration and rescue.

Because most amphibs need no breathing equipment and endure great depths, they take the jobs that require it: deep sea diving, underwater construction and exploration. Many join the Sea Wolves as scouts, others become scientists, marine biologists and researchers, and a few learn water magic from dolphins, whale singers and other aquatic races.
',
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, '(BOOK-INGEST-AUDIT.md F119). All seven rows were re-read') > 0
   AND length(markdown) = 13749;

-- == gene-splicer-mutant ==
UPDATE imported_classes
   SET markdown = '---
id: gene-splicer-mutant
name: Gene-Splicer Mutant
system: rifts
source_book: Rifts World Book 7: Underseas p.38-40
category: rcc
tags: [aquatic]
men_of_arms: false
mdc_base: "0"
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
restrictions:
  - "THIS CREATURE IS ROLLED, NOT READ OFF A STAT BLOCK. Printed 39-40 give eight percentile tables and the instruction to roll once on each; they are the eight pick groups below, in the book''s order. The page says only to roll once on each and prints nothing about choosing; being able to pick a row is the wizard''s allowance, not the book''s."
  - "THE BOOK PRINTS NO ATTRIBUTE DICE EXCEPT I.Q. The Intelligence & Aggression table sets I.Q.; M.E., M.A., P.S., P.P., P.E., P.B. and Spd are printed nowhere on printed 38-40. The G.M. sets them, from the animal the body is built on or as he sees fit. Until he does, the sheet''s default dice stand for those seven and they are NOT the book''s."
  - "M.D.C. comes from the Body table alone (and the Too Big! defect adds to it). Printed 39 says every one of these creatures is a mega-damage creature. The class states an M.D.C. base of zero, which no page prints: it is there only so that the Body row''s M.D.C., stored as a pool bonus, has a base to add to (without one the pick added nothing; found and corrected 2026-10-05)."
  - "ATTACKS PER MELEE come from the Body row. A row printing two attacks stores nothing, a row printing three stores one extra and the Manta Ray''s single attack stores one fewer, so the sheet''s total is the row''s number before appendages. The book prints no hand to hand skill for the creature."
  - "Type of Head is rolled once FOR EACH HEAD when the Number of Heads table gives more than one (printed 39). The group holds one pick; note the other heads by hand."
  - "No alignment, no skills, no O.C.C. rule, no P.P.E., no Horror Factor, no equipment, no money and no life span are printed for the gene-splicer mutant. None is stored. Printed 214 gives it an experience ladder and so makes it playable; everything else is the G.M.''s to rule."
  - "Size, where a Body row prints one, is in that row''s description. Most are far larger than a human."
special_abilities:
  - { choose: 1, from: ["Body (01-10): Sea Snake, Oarfish or Eel", "Body (11-20): Large Fish", "Body (21-30): Humanoid/Bipedal", "Body (31-40): Tiger or Great White Shark", "Body (41-50): Dolphin or Porpoise", "Body (51-55): Giant Squid or Octopus", "Body (56-60): Manta Ray", "Body (61-65): Lobster or Crab", "Body (66-70): Crocodile", "Body (71-75): Sea Lion or Walrus", "Body (76-84): Sea Turtle", "Body (85-90): Aquatic Bird", "Body (91-95): Sea Horse", "Body (96-00): Other"], note: "Random Body Type/Appearance (printed 39), rolled once. Every body breathes underwater and has the senses of its kind, is a mega-damage creature, and is full-size to giant-size." }
  - name: "Body (01-10): Sea Snake, Oarfish or Eel"
    description: "Roll 01-10 or choose. M.D.C. 1D6x10. Size: 15-20 feet (4.6-6.1 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 }, pools: { mdc: "1d6x10" } }
  - name: "Body (11-20): Large Fish"
    description: "Roll 11-20 or choose. A fish like a tuna, mackerel, sailfish or swordfish. M.D.C. 2D4x10. Size: 4+1D4 feet (1.2 to 2.4 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 }, pools: { mdc: "2d4x10" } }
  - name: "Body (21-30): Humanoid/Bipedal"
    description: "Roll 21-30 or choose. Two legs, feet, arms and hands. M.D.C. 3D4x10. Size: 6 feet (1.8 m) tall. Three attacks per melee round, +1 to strike and +2 to parry."
    bonuses: { combat: { attacks: 1, strike: 1, parry: 2 }, pools: { mdc: "3d4x10" } }
  - name: "Body (31-40): Tiger or Great White Shark"
    description: "Roll 31-40 or choose. M.D.C. 5D6x10. Size: 20-30 feet (6-9 m). Two attacks per melee round and +2 to strike and dodge."
    bonuses: { combat: { strike: 2, dodge: 2 }, pools: { mdc: "5d6x10" } }
  - name: "Body (41-50): Dolphin or Porpoise"
    description: "Roll 41-50 or choose. M.D.C. 3D4x10. Size: 7-11 feet (2.1-3.3 m) long. Two attacks per melee round and +2 to parry and dodge."
    bonuses: { combat: { parry: 2, dodge: 2 }, pools: { mdc: "3d4x10" } }
  - name: "Body (51-55): Giant Squid or Octopus"
    description: "Roll 51-55 or choose. M.D.C. 4D4x10. Size: 40-50 feet (12.2-15.5 m). Three attacks per melee round and +8 to parry."
    bonuses: { combat: { attacks: 1, parry: 8 }, pools: { mdc: "4d4x10" } }
  - name: "Body (56-60): Manta Ray"
    description: "Roll 56-60 or choose. M.D.C. 2D4x10. Size: 10-15 feet (3-4.6 m). One attack per melee round."
    bonuses: { combat: { attacks: -1 }, pools: { mdc: "2d4x10" } }
  - name: "Body (61-65): Lobster or Crab"
    description: "Roll 61-65 or choose. M.D.C. 4D6x10. Size: 3-5 feet (0.9-1.5 m) long. Three attacks per melee round and +4 to strike, parry and dodge."
    bonuses: { combat: { attacks: 1, strike: 4, parry: 4, dodge: 4 }, pools: { mdc: "4d6x10" } }
  - name: "Body (66-70): Crocodile"
    description: "Roll 66-70 or choose. M.D.C. 4D6x10. Size: 20 feet (6.1 m). Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 }, pools: { mdc: "4d6x10" } }
  - name: "Body (71-75): Sea Lion or Walrus"
    description: "Roll 71-75 or choose. M.D.C. 2D4x100 - the one row printed in hundreds. Size: 12-15 feet (3.6 to 4.6 m). Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 }, pools: { mdc: "2d4x100" } }
  - name: "Body (76-84): Sea Turtle"
    description: "Roll 76-84 or choose. M.D.C. 3D6x10. Size: 6 feet (1.8 m). Two attacks per melee round."
    bonuses: { pools: { mdc: "3d6x10" } }
  - name: "Body (85-90): Aquatic Bird"
    description: "Roll 85-90 or choose. M.D.C. 1D6x10. Size: 5 feet (1.5 m) long. Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 }, pools: { mdc: "1d6x10" } }
  - name: "Body (91-95): Sea Horse"
    description: "Roll 91-95 or choose. M.D.C. 1D6x10. Size: 6 feet (1.8 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 }, pools: { mdc: "1d6x10" } }
  - name: "Body (96-00): Other"
    description: "Roll 96-00 or choose. The G.M.''s choice of any kind of strange critter: polar bear, sea lamprey, whale, deep-sea fish, alien animal, or an aquatic or surface D-bee. The row prints NO M.D.C., size, attacks or bonuses - the G.M. sets them all, and nothing is stored."
  - { choose: 1, from: ["Heads (01-60): One", "Heads (61-80): Two", "Heads (81-90): Three", "Heads (91-00): Four"], note: "Number of heads (printed 39), rolled once." }
  - name: "Heads (01-60): One"
    description: "Roll 01-60 or choose. One head."
  - name: "Heads (61-80): Two"
    description: "Roll 61-80 or choose. Two heads. Roll Type of Head once for each."
  - name: "Heads (81-90): Three"
    description: "Roll 81-90 or choose. Three heads. Roll Type of Head once for each."
  - name: "Heads (91-00): Four"
    description: "Roll 91-00 or choose. Four heads. Roll Type of Head once for each."
  - { choose: 1, from: ["Head Type (01-35): Same as the Natural Animal", "Head Type (36-40): Fish", "Head Type (41-45): Tiger or Great White Shark", "Head Type (46-50): Squid or Octopus", "Head Type (51-55): Lobster or Shrimp", "Head Type (56-60): Turtle", "Head Type (61-65): Sea Horse", "Head Type (66-70): Crocodile", "Head Type (71-75): Eel or Lamprey", "Head Type (76-80): Sea Lion or Walrus", "Head Type (81-85): Hammerhead Shark", "Head Type (86-90): Dolphin or Beaked Whale", "Head Type (91-95): Human", "Head Type (96-00): Other"], note: "Type of Head (printed 39). The book rolls it once FOR EACH HEAD; this group holds the first head, and a creature with two, three or four heads rolls the rest by hand. No row prints a number." }
  - name: "Head Type (01-35): Same as the Natural Animal"
    description: "Roll 01-35 or choose. The head is that of the animal the body came from."
  - name: "Head Type (36-40): Fish"
    description: "Roll 36-40 or choose. A fish''s head."
  - name: "Head Type (41-45): Tiger or Great White Shark"
    description: "Roll 41-45 or choose. The head of a tiger shark or great white shark."
  - name: "Head Type (46-50): Squid or Octopus"
    description: "Roll 46-50 or choose. The head of a squid or octopus."
  - name: "Head Type (51-55): Lobster or Shrimp"
    description: "Roll 51-55 or choose. The head of a lobster or shrimp."
  - name: "Head Type (56-60): Turtle"
    description: "Roll 56-60 or choose. A turtle''s head."
  - name: "Head Type (61-65): Sea Horse"
    description: "Roll 61-65 or choose. A sea horse''s head."
  - name: "Head Type (66-70): Crocodile"
    description: "Roll 66-70 or choose. A crocodile''s head."
  - name: "Head Type (71-75): Eel or Lamprey"
    description: "Roll 71-75 or choose. The head of an eel or lamprey."
  - name: "Head Type (76-80): Sea Lion or Walrus"
    description: "Roll 76-80 or choose. The head of a sea lion or walrus."
  - name: "Head Type (81-85): Hammerhead Shark"
    description: "Roll 81-85 or choose. A hammerhead shark''s head."
  - name: "Head Type (86-90): Dolphin or Beaked Whale"
    description: "Roll 86-90 or choose. The head of a dolphin or beaked whale."
  - name: "Head Type (91-95): Human"
    description: "Roll 91-95 or choose. A human head: a 50% chance it looks normal and a 50% chance it looks monstrous."
  - name: "Head Type (96-00): Other"
    description: "Roll 96-00 or choose. The G.M.''s choice of any kind of strange critter: polar bear, penguin, whale, deep-sea fish, alien animal, or an aquatic or surface D-bee."
  - { choose: 1, from: ["Intelligence (01-20): Human, Curious", "Intelligence (21-40): Human, Cruel Predator", "Intelligence (41-60): Human, Opportunist Predator", "Intelligence (61-80): High Animal", "Intelligence (81-00): Low Animal"], note: "Intelligence & Aggression (printed 39), rolled once. Each row sets the I.Q. dice - the only attribute dice the book prints for this creature." }
  - name: "Intelligence (01-20): Human, Curious"
    description: "Roll 01-20 or choose. I.Q. 1D6+10, human intelligence. Curious and resourceful and not particularly aggressive, much like a dolphin. Eats fish, crustaceans and invertebrates."
    attribute_dice: { IQ: "1d6+10" }
  - name: "Intelligence (21-40): Human, Cruel Predator"
    description: "Roll 21-40 or choose. I.Q. 1D4+10, human intelligence. A very aggressive and cruel predator that kills humanoids, mammals and fish for pleasure as well as for food."
    attribute_dice: { IQ: "1d4+10" }
  - name: "Intelligence (41-60): Human, Opportunist Predator"
    description: "Roll 41-60 or choose. I.Q. 2D4, which the book still calls human intelligence. A predator always looking for easy prey, humanoids and sick or weak animals included."
    attribute_dice: { IQ: "2d4" }
  - name: "Intelligence (61-80): High Animal"
    description: "Roll 61-80 or choose. I.Q. 1D6+8, high animal intelligence. A ruthless predator."
    attribute_dice: { IQ: "1d6+8" }
  - name: "Intelligence (81-00): Low Animal"
    description: "Roll 81-00 or choose. I.Q. 1D4, low animal intelligence. Works on instinct and brute strength; otherwise dull witted. May try to eat just about anything, but gives up on prey that is too big or fights too hard."
    attribute_dice: { IQ: "1d4" }
  - { choose: 1, from: ["Depth (01-10): 500 Feet", "Depth (11-20): 1000 Feet", "Depth (21-30): 2000 Feet", "Depth (31-50): 4000 Feet", "Depth (51-70): 1 Mile", "Depth (71-80): 2 Miles", "Depth (81-90): 3 Miles", "Depth (91-00): Unlimited"], note: "Depth Tolerance (printed 39), rolled once. It may be greater or less than the original creature''s." }
  - name: "Depth (01-10): 500 Feet"
    description: "Roll 01-10 or choose. Depth tolerance 500 feet (152 m)."
  - name: "Depth (11-20): 1000 Feet"
    description: "Roll 11-20 or choose. Depth tolerance 1000 feet (305 m)."
  - name: "Depth (21-30): 2000 Feet"
    description: "Roll 21-30 or choose. Depth tolerance 2000 feet (610 m)."
  - name: "Depth (31-50): 4000 Feet"
    description: "Roll 31-50 or choose. Depth tolerance 4000 feet (1220 m)."
  - name: "Depth (51-70): 1 Mile"
    description: "Roll 51-70 or choose. Depth tolerance 1 mile (1.6 km)."
  - name: "Depth (71-80): 2 Miles"
    description: "Roll 71-80 or choose. Depth tolerance 2 miles (3.2 km)."
  - name: "Depth (81-90): 3 Miles"
    description: "Roll 81-90 or choose. Depth tolerance 3 miles (4.8 km)."
  - name: "Depth (91-00): Unlimited"
    description: "Roll 91-00 or choose. No depth limit at all."
  - { choose: 1, from: ["Appendage (01-20): Tentacles", "Appendage (21-40): Clawed Arms", "Appendage (41-50): Spiked Prehensile Tail", "Appendage (51-60): Rhino-Like Horns", "Appendage (61-71): Crab Claws", "Appendage (72-80): Fish Tail or Extra Fins", "Appendage (81-90): Chemoreceptor Antennae", "Appendage (91-00): Giant Maw with Tentacle Tongues"], note: "Additional appendages (printed 39-40), rolled once. All are proportional to the size of the creature. The bands 61-71 and 72-80 are as printed." }
  - name: "Appendage (01-20): Tentacles"
    description: "Roll 01-20 or choose. 1D6 tentacles. Each PAIR adds one attack per melee round, +1 on initiative and +1 to parry. The numbers depend on the count rolled, so they are added by hand and nothing is stored."
  - name: "Appendage (21-40): Clawed Arms"
    description: "Roll 21-40 or choose. Two arms with clawed hands and webbed fingers - an extra pair on a humanoid. The row prints no damage and no bonus."
  - name: "Appendage (41-50): Spiked Prehensile Tail"
    description: "Roll 41-50 or choose. A spiked, prehensile tail at least half the length of the body. It does 2D6 M.D. and gives +1 to parry."
    bonuses: { combat: { parry: 1 } }
  - name: "Appendage (51-60): Rhino-Like Horns"
    description: "Roll 51-60 or choose. 1D4 rhino-like horns for stabbing and impaling, each doing 1D6 M.D."
  - name: "Appendage (61-71): Crab Claws"
    description: "Roll 61-71 or choose. A pair of crab claws doing 3D6 M.D. per strike. Adds one attack per melee round and +2 to parry."
    bonuses: { combat: { attacks: 1, parry: 2 } }
  - name: "Appendage (72-80): Fish Tail or Extra Fins"
    description: "Roll 72-80 or choose. A fish tail or extra fins that add to manoeuvrability underwater; +1 to dodge and +12 to the creature''s normal Spd attribute. The page sets both numbers beside ''underwater''; they are stored unconditionally because this is an aquatic creature, and a G.M. may limit them to the water."
    bonuses: { attributes: { Spd: 12 }, combat: { dodge: 1 } }
  - name: "Appendage (81-90): Chemoreceptor Antennae"
    description: "Roll 81-90 or choose. 1D4 antennae that sense minute changes in the salinity and chemistry of the water, so the creature can taste oil, fuel, sulfur and nitrates from explosions, pollution, and blood. Identify chemicals by taste 68%; track by taste 64%. Range: one mile (1.6 km)."
  - name: "Appendage (91-00): Giant Maw with Tentacle Tongues"
    description: "Roll 91-00 or choose. A giant maw with 1D6 tentacle-like tongues, used to swallow prey whole. Each PAIR of tongues adds one attack per melee and +1 to strike. The numbers depend on the count rolled, so they are added by hand and nothing is stored."
  - { choose: 1, from: ["Feature (01-10): Ley Line Power", "Feature (11-20): Silent", "Feature (21-30): Teeth", "Feature (31-40): Sonic Blast", "Feature (41-50): Incredible Underwater Speed", "Feature (51-60): Regeneration", "Feature (61-70): Turn Invisible and See the Invisible", "Feature (71-80): Echo-Location", "Feature (81-90): Psionic Empathy", "Feature (91-00): Super Regeneration"], note: "Additional Features & Abilities (printed 40), rolled once." }
  - name: "Feature (01-10): Ley Line Power"
    description: "Roll 01-10 or choose. Has the ley line charging ability, the same as the dolphin''s (Dolphin R.C.C., printed 77-80)."
  - name: "Feature (11-20): Silent"
    description: "Roll 11-20 or choose. Prowl at 80% and +2 on initiative. A sneak attack is a critical strike, doing double damage."
    bonuses: { combat: { initiative: 2 } }
  - name: "Feature (21-30): Teeth"
    description: "Roll 21-30 or choose. Every head''s mouth is filled with razor sharp, shark-like teeth and the bite does 2D4 M.D. If the creature has naturally sharp teeth already, they are extra large and do 3D6 M.D."
  - name: "Feature (31-40): Sonic Blast"
    description: "Roll 31-40 or choose. A sonic attack doing 4D6 M.D. underwater or 1D6 M.D. above water. Range is printed as 120 feet (366 m). Usable only once per melee, but it counts as an extra melee attack - an attack that can only be the blast, so it is not added to the attack count."
  - name: "Feature (41-50): Incredible Underwater Speed"
    description: "Roll 41-50 or choose. Up to 120 mph (192 kmph; 103 knots) underwater and on the surface of the water."
  - name: "Feature (51-60): Regeneration"
    description: "Roll 51-60 or choose. Regenerates 3D6 M.D.C. per melee round."
  - name: "Feature (61-70): Turn Invisible and See the Invisible"
    description: "Roll 61-70 or choose. Turns itself invisible and sees the invisible at will - basically the same as the spells, but with no limit on duration or on how often the powers can be used."
  - name: "Feature (71-80): Echo-Location"
    description: "Roll 71-80 or choose. Echo-location, the same as the dolphin''s (Dolphin R.C.C., printed 77-80)."
  - name: "Feature (81-90): Psionic Empathy"
    description: "Roll 81-90 or choose. Telepathy, empathy and empathic transmission. I.S.P. 3D4x10 points; the creature is equal to a third level psychic, with double the normal range. The stored type of minor is the catalog''s choice, because the page names no class of psychic."
    psionics: { type: "minor", isp_base: "3d4x10", powers: ["Telepathy", "Empathy", "Empathic Transmission"] }
  - name: "Feature (91-00): Super Regeneration"
    description: "Roll 91-00 or choose. Regenerates 1D4x10 M.D.C. per melee round, and grows back severed limbs and appendages within 3D4 days."
  - { choose: 1, from: ["Defect (01-10): Insatiable Hunger", "Defect (11-20): Magic", "Defect (21-30): Garbage Eater", "Defect (31-40): Bad Luck Aura", "Defect (41-50): Obsessive Imprint", "Defect (51-60): Energy Sponge", "Defect (61-70): Too Big! And Growing", "Defect (71-80): Spasmatic Shape-Changer", "Defect (81-90): Stinks!!", "Defect (91-00): Psychopathic Killer"], note: "Genetic Defect Table (printed 40), rolled once. The defect is likely to be at least one of the reasons the creature was dumped." }
  - name: "Defect (01-10): Insatiable Hunger"
    description: "Roll 01-10 or choose. Must eat ten times its normal body weight in food to survive. Very aggressive; +1 on initiative."
    bonuses: { combat: { initiative: 1 } }
  - name: "Defect (11-20): Magic"
    description: "Roll 11-20 or choose. Select 1D6 Ocean magic spells. The creature casts them at random moments - usually when hunting, fighting or cornered, but at almost any time the G.M. fairly chooses - and each casting is at a strength of 1D6 levels, rolled when it goes off. The creature tends to be jumpy and unstable. The spells are a rolled count and are not stored; choose them by hand from the book''s Ocean Magic list (printed 63)."
  - name: "Defect (21-30): Garbage Eater"
    description: "Roll 21-30 or choose. Can metabolize almost anything as food - organic matter fresh or spoiled, bone, teeth, plants, leather, rubber, plastic, cloth and paper - but not gems, stone, clay, metal, ceramic compounds or electronics. It has a knack for finding and eating the most valuable item first, and must eat the equivalent of its own body weight every day."
  - name: "Defect (31-40): Bad Luck Aura"
    description: "Roll 31-40 or choose. Anyone within twenty feet is -2 on all die rolls, and stays so for 2D4 hours after the creature leaves the area; twice as long for anyone who actually touched it. Anyone who eats part of the creature is -2 on all die rolls for the next 1D6 days."
  - name: "Defect (41-50): Obsessive Imprint"
    description: "Roll 41-50 or choose. The creature imprints on one person and follows and watches him or her for 3D6 months, then chooses again - possibly the same person, more likely a new one. It neither attacks nor defends the object of its attention, though it may leave small, worthless and smelly gifts. Being noisy, big and in the way, it makes the person followed -30% to prowl and -2 on initiative. Attacked or threatened, it defends itself fiercely, even against the one it follows."
  - name: "Defect (51-60): Energy Sponge"
    description: "Roll 51-60 or choose. Fairly harmless in the wild, but its body soaks up energy and disrupts electrical devices. Clinging to a submarine or boat it makes the lights flicker, garbles radio, cuts the range of radios and sensors by 50%, and drops the vessel''s overall power by 20% and then by a further 1% an hour until it is chased off. It is impervious to electrical energy and takes half damage from most other energy, plasma and magic included; explosives and projectiles do full damage."
  - name: "Defect (61-70): Too Big! And Growing"
    description: "Roll 61-70 or choose. 2D4x10% bigger and heavier than normal. Adds 2D4x10 to M.D.C. but halves normal speed, and it eats twice as much as normal. It grows a further 10% for 2D6 months. The halved speed is applied by hand."
    bonuses: { pools: { mdc: "2d4x10" } }
  - name: "Defect (71-80): Spasmatic Shape-Changer"
    description: "Roll 71-80 or choose. Every four hours the creature metamorphoses into a variation of itself: it shrinks or grows 1D4x10%, breaks out in blotches or boils, changes colour, gains or loses spines, its teeth grow or shrink 100%, and mucus or slime runs from nose, eyes or mouth. The change takes one minute and is ugly enough that those watching must save versus Horror Factor 16. Each transformation is unique."
  - name: "Defect (81-90): Stinks!!"
    description: "Roll 81-90 or choose. Body oils give off a repugnant odour that cannot be stopped, covered or disguised, smelled within 500 feet (152 m) in air and 4000 feet (1220 m) underwater. Companions find people avoid them, enemies and predators notice the group unless it is downwind or downstream, and sneak attacks are impossible."
  - name: "Defect (91-00): Psychopathic Killer"
    description: "Roll 91-00 or choose. A killing machine that cannot be reasoned with: it spends its time hunting, killing, torturing, eating or waiting for the next victim. It knows no fear and attacks anything, fleeing only when its M.D.C. is down by 85%. Reduce intelligence by 25% - a fraction of a rolled number, applied by hand."
extraction_notes: "NEW 2026-10-05, Rifts World Book 7: Underseas printed 38-40 (cache p038-p040; this book''s cache page equals the printed folio through printed 130, and folios 38, 39 and 40 were read on the renders) and the experience ladder on printed 214 (cache p213, folio read). Every figure was read off a page render. THE SURVEY DECLINED THIS CLASS on 2026-09-07 because printed 39-40 is a random-creature generator with no stat block; Nate ruled on 2026-10-04 that it is imported on the band-named pick-group mechanic (BOOK-INGEST-AUDIT.md F119, F120). WHAT THE PAGES PRINT: an introduction to the gene-splicers (printed 38), the heading Random Creation of Gene-Splicer Monsters, the instruction ''Roll once on each of the following tables'', and EIGHT tables - Random Body Type/Appearance (14 rows), Number of heads (4), Type of Head (14), Intelligence & Aggression (5), Depth Tolerance (8), Additional appendages (8), Additional Features & Abilities (10) and the Genetic Defect Table (10). The survey counted six; Intelligence & Aggression and Depth Tolerance are the two it missed. All eight are stored as choose-1 groups in the book''s order, every row its own band-named option; all eight cover 01-00 with no gap or overlap as printed. STORED AS NUMBERS: each Body row''s M.D.C. as a pool bonus (no class mdc_base, because fourteen rows print thirteen different formulas and the Other row prints none); each Body row''s strike, parry and dodge; the I.Q. dice of all five Intelligence rows as attribute_dice; the tail''s +1 parry, the crab claws'' one attack and +2 parry, and the fish tail''s +1 dodge and +12 Spd; Silent''s +2 initiative; Insatiable Hunger''s +1 initiative; Too Big''s 2D4x10 M.D.C.; and Psionic Empathy as a psionics block with its three named powers and I.S.P. 3D4x10. ATTACKS PER MELEE: the Body rows print a total (one, two or three), not a bonus. Stored as the difference from the two attacks every character starts with - nothing for two, attacks 1 for three, attacks -1 for the Manta Ray''s one - because no option anywhere in the catalog states an attack total and the class has no hand to hand skill to collide with. NOT STORED, PROSE IN THE ROW: per-pair bonuses that depend on a rolled count (tentacles, tentacle tongues); the Sonic Blast''s extra attack, which can only be the blast; the 1D6 Ocean spells of the Magic defect; halved speed (Too Big); ''reduce intelligence by 25%'' (Psychopathic Killer); the save versus Horror Factor 16 that onlookers make during a Shape-Changer''s metamorphosis, which is conditional and is not the creature''s Horror Factor; all sizes, damages, ranges and percentages. Type of Head is rolled once per head; the group holds one. PSIONIC EMPATHY''s type is stored as minor: the row prints three powers, an I.S.P. formula and ''equal to a third level psychic'', and no class of psychic. THE BOOK PRINTS NONE OF THESE AND NONE IS STORED: attribute dice other than I.Q., hit points, S.D.C., P.P.E., Horror Factor, alignment, any skill, any O.C.C. rule, equipment, money, life span. men_of_arms is false because this is a race stating no sdc_base and no mdc_base; the section heading is ''Gene-Splicers & Sea Monsters'' (printed 38). XP: the printed 214 column headed ''Dolphin, Humpback Whale, Gene-Splicer Mutants'', fifteen lower bounds, identical to the dolphin''s stored ladder. ONE ODDITY AS PRINTED: the Sonic Blast''s range reads ''120 feet (366 m)'', and 120 feet is 36.6 m; both figures are kept in the row. Ley Line Mutations, which begins lower on printed 40, is a different table for natural sea creatures and is not part of this class."
---

## Lore

The Gene-Splicers are a race of malevolent aliens. The New German Republic
believes they keep to outposts in Germany and Poland; in fact they are just as
well established in the seas, with two long-standing bases older than the
European one - one in the Black Sea and a mobile one in the North Pacific.

They capture animals and abduct intelligent beings for genetic experiments, and
when an experiment fails or stops being interesting the living result is simply
flushed into the ocean. Others are made and released on purpose, to be watched.
Either way the seas of Rifts Earth now hold mutants that prey on the native
life, humans included, and about 45% of them can breed.

The New Navy under Captain Nemo-2, Tritonia and Lemuria hunt the gene-splicers
and their creations; a large undersea base near Kure in the Hawaiian islands
was destroyed by the USS Ticonderoga and the 2nd Fleet with Lemurian help.
Dolphins, Whale Singers, aquatic D-bees and sailors kill the mutants where they
find them.

A gene-splicer mutant is whatever the tables make it: the body of one sea
animal, perhaps the head of another, perhaps several heads, an extra limb, one
strange ability, and one defect that may be why it was thrown away.

## GM Notes

**This class is a generator.** Printed 39-40 have the creature rolled once on
each of eight tables, and those tables are the class''s eight pick groups. The
book gives the mutant an experience ladder (printed 214) and nothing else a
character normally has.

**What the G.M. must supply, because the book does not:** seven of the eight
attributes (only I.Q. is printed, by the Intelligence & Aggression table),
alignment, skills, whether an O.C.C. may be taken at all, P.P.E., Horror
Factor, equipment and money. The natural animal the body is built on is the
obvious guide. The sheet''s default attribute dice, hit points and S.D.C. are
placeholders, not the book''s figures; the creature is a mega-damage being and
its M.D.C. is the Body row''s.

**Rolled by hand:**

- Type of Head for the second, third and fourth head.
- The attack, initiative, parry or strike bonus for each PAIR of tentacles or
  tentacle tongues.
- The 1D6 Ocean magic spells of the Magic defect, and the 1D6 level strength
  of each casting.
- Halved speed for a creature that is Too Big, and the 25% intelligence
  reduction of the Psychopathic Killer.

**The two Other rows** (Body 96-00, Head Type 96-00) are the G.M.''s choice of
creature and print no numbers. A Body of Other has no stored M.D.C. at all.

**Attacks per melee.** The Body row prints the total: one for the Manta Ray,
three for the Humanoid, the Squid or Octopus and the Lobster or Crab, and two
for the rest. Crab claws add one more; tentacles and tentacle tongues add one
per pair.

Ley Line Mutations, on the same page, is a separate table for ordinary sharks,
rays, fish, octopus, squid, eels and crustaceans born near ley lines. It is not
part of the gene-splicer mutant.
',
       updated_at = datetime('now')
 WHERE class_id = 'gene-splicer-mutant'
   AND instr(markdown, 'so the hit points and S.D.C. the sheet shows are not the book''s and are not used') > 0
   AND length(markdown) = 29195;

-- == phase-world-alien ==
UPDATE imported_classes
   SET markdown = '---
id: phase-world-alien
name: Alien (Phase World race builder)
system: rifts
category: rcc
tags: []
source_book: Rifts Dimension Book 2: Phase World p.104-108
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
special_abilities:
  - { choose: 1, from: ["Attributes (01-20): Below Galactic Average, Mental", "Attributes (01-20): Below Galactic Average, Physical", "Attributes (21-50): Galactic Average", "Attributes (51-60): Superior", "Attributes (61-70): Excellent", "Attributes (71-80): Superhuman", "Attributes (81-90): Supernatural", "Attributes (91-00): Incredible Supernatural"], note: "Step One: Attributes (printed 104), rolled once or picked. Every race starts from 3D6 in all eight attributes and the row''s bonuses are added to that. 01-20 prints two results, mental or physical; choose one. The G.M. may instead simply decide the race''s attributes." }
  - name: "Attributes (01-20): Below Galactic Average, Mental"
    description: "Roll 01-20 or choose, and take the mental half of the row: three mental attributes are rolled on 2D4 and the remaining five on 3D6. The page says three mental attributes without naming them; I.Q., M.E. and M.A. is the reading stored."
    attribute_dice: { IQ: "2d4", ME: "2d4", MA: "2d4" }
  - name: "Attributes (01-20): Below Galactic Average, Physical"
    description: "Roll 01-20 or choose, and take the physical half of the row: three physical attributes are rolled on 2D4 and the remaining five on 3D6. The page does not say which three of the five physical attributes (P.S., P.P., P.E., P.B., Spd), so the dice here are left at 3D6: pick the three with the G.M. and re-roll them on 2D4 by hand."
  - name: "Attributes (21-50): Galactic Average"
    description: "Roll 21-50 or choose. All attributes are rolled on 3D6."
  - name: "Attributes (51-60): Superior"
    description: "Roll 51-60 or choose. Add 1D4 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (61-70): Excellent"
    description: "Roll 61-70 or choose. Add 1D6+1 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (71-80): Superhuman"
    description: "Roll 71-80 or choose. Add 1D6+6 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (81-90): Supernatural"
    description: "Roll 81-90 or choose. Add 1D6+6 to any four attributes, by hand. P.S. and P.E. are considered supernatural."
  - name: "Attributes (91-00): Incredible Supernatural"
    description: "Roll 91-00 or choose. Add 1D6+6 to any four attributes, by hand. The page then prints 2D6+10 to P.S. and Spd or P.B., once: the P.S. bonus is stored here, and whether Spd or P.B. takes the same roll or a second one is not printed, so that part is added by hand. P.S. and P.E. are considered supernatural."
    bonuses: { attributes: { PS: "2d6+10" } }
  - { choose: 1, from: ["Damage Capacity (01-40): Galactic Average", "Damage Capacity (41-50): Above Average", "Damage Capacity (51-60): Almost Superhuman", "Damage Capacity (61-70): Minor M.D.C. Being", "Damage Capacity (71-80): M.D.C. Being", "Damage Capacity (81-90): Major M.D.C. Being", "Damage Capacity (91-00): Supernatural M.D.C. Being"], note: "Step Two: Damage Capacity (printed 104-105), rolled once or picked. The page prints 41-60 as plain S.D.C. figures and 61-00 as the race''s BASE M.D.C.; each is stored as a pool bonus because the class itself states no base. The two S.D.C. rows land on the S.D.C. every character has; the three M.D.C. rows add nothing without an M.D.C. base and are entered on the sheet by hand. Each row also says whether the appearance and physiological bonuses (Steps Three and Four) are S.D.C. or M.D.C. points; those are stored as S.D.C., so a race given an M.D.C. row moves them to M.D.C. by hand." }
  - name: "Damage Capacity (01-40): Galactic Average"
    description: "Roll 01-40 or choose. S.D.C. and hit points are determined normally. Appearance and physiological bonuses are S.D.C. points."
  - name: "Damage Capacity (41-50): Above Average"
    description: "Roll 41-50 or choose. 1D6x10 S.D.C. The page prints the figure plainly and does not say whether it replaces or adds to S.D.C. determined normally; it is stored as a pool bonus because the class itself states no base. Appearance and physiological bonuses are S.D.C. points."
    bonuses: { pools: { sdc: "1d6x10" } }
  - name: "Damage Capacity (51-60): Almost Superhuman"
    description: "Roll 51-60 or choose. 1D4x100 S.D.C. The page prints the figure plainly and does not say whether it replaces or adds to S.D.C. determined normally; it is stored as a pool bonus because the class itself states no base. Appearance and physiological bonuses are S.D.C. points."
    bonuses: { pools: { sdc: "1d4x100" } }
  - name: "Damage Capacity (61-70): Minor M.D.C. Being"
    description: "Roll 61-70 or choose. Base M.D.C. equal to the P.E. attribute, plus 1D6 per level of experience; work it out by hand. Appearance and physiological bonuses are mega-damage points but every one of them is HALVED. Strength and endurance are not supernatural: a punch does normal S.D.C. damage and a power punch 1D4 M.D."
  - name: "Damage Capacity (71-80): M.D.C. Being"
    description: "Roll 71-80 or choose. Base M.D.C. of 1D6x10, plus 2D4 per level of experience (the per-level gain is added by hand). The page prints this as the race''s base. It is stored as a pool bonus, and a pool bonus only adds to a base the class states: this class states no M.D.C. base (most of its races are S.D.C. beings), so this pick adds NOTHING by itself - enter the M.D.C. on the sheet by hand. Appearance and physiological bonuses are M.D.C. points. Strength and endurance are supernatural."
    bonuses: { pools: { mdc: "1d6x10" } }
  - name: "Damage Capacity (81-90): Major M.D.C. Being"
    description: "Roll 81-90 or choose. As the M.D.C. Being, but base M.D.C. is 3D6x10, plus 2D6 per level of experience (the per-level gain is added by hand). The page prints this as the race''s base. It is stored as a pool bonus, and a pool bonus only adds to a base the class states: this class states no M.D.C. base (most of its races are S.D.C. beings), so this pick adds NOTHING by itself - enter the M.D.C. on the sheet by hand."
    bonuses: { pools: { mdc: "3d6x10" } }
  - name: "Damage Capacity (91-00): Supernatural M.D.C. Being"
    description: "Roll 91-00 or choose. As the M.D.C. Being, but base M.D.C. is 2D6x100, plus 1D4x10 per level of experience (the per-level gain is added by hand). The page prints this as the race''s base. It is stored as a pool bonus, and a pool bonus only adds to a base the class states: this class states no M.D.C. base (most of its races are S.D.C. beings), so this pick adds NOTHING by itself - enter the M.D.C. on the sheet by hand."
    bonuses: { pools: { mdc: "2d6x100" } }
  - { choose: 1, from: ["Appearance (01-30): Human-like", "Appearance (31-50): Humanoid", "Appearance (51-55): Insectoid", "Appearance (56-60): Humanoid Amphibian", "Appearance (61-65): Vegetation", "Appearance (66-70): Humanoid Reptilian", "Appearance (71-75): Humanoid Canine", "Appearance (76-80): Humanoid Avian", "Appearance (81-85): Humanoid Mineral", "Appearance (86-90): Humanoid Feline", "Appearance (91-95): Humanoid Ape", "Appearance (96-00): Humanoid Aquatic"], note: "Step Three: Alien Appearance (printed 105), rolled once or picked. Each S.D.C./M.D.C. bonus is stored as S.D.C.; the Step Two row says whether appearance bonuses are S.D.C. or M.D.C. points." }
  - name: "Appearance (01-30): Human-like"
    description: "Roll 01-30 or choose. A humanoid alien that cannot be told apart from a human."
  - name: "Appearance (31-50): Humanoid"
    description: "Roll 31-50 or choose. A biped with human-like features and a distinguishing physical characteristic of its own: roll on the Unusual Characteristics table (Step Five)."
  - name: "Appearance (51-55): Insectoid"
    description: "Roll 51-55 or choose. Large eyes, antennae, claw-like hands and feet and an exo-skeleton are common. Add 100 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 100 } }
  - name: "Appearance (56-60): Humanoid Amphibian"
    description: "Roll 56-60 or choose. Soft, smooth skin and webbed hands and feet. Semi-aquatic: can hold its breath up to 20 minutes, swims automatically at 90% proficiency, and swims at six times the race''s running speed. Skin is typically green, tan or yellow-blotchy, but varies."
  - name: "Appearance (61-65): Vegetation"
    description: "Roll 61-65 or choose. Made of the same essence as terrestrial plant life, usually green or yellow in various shades. A cold life form that does not register on normal heat sensors or infrared, and it heals twice as fast as normal. +40 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 40 } }
  - name: "Appearance (66-70): Humanoid Reptilian"
    description: "Roll 66-70 or choose. Lizard-like features, leathery or scaly skin, no body hair, dark eyes. +2 to P.P. and +40 S.D.C./M.D.C."
    bonuses: { attributes: { PP: 2 }, pools: { sdc: 40 } }
  - name: "Appearance (71-75): Humanoid Canine"
    description: "Roll 71-75 or choose. Dog-like features, body fur or extreme body hair, dark eyes. +4 to P.S., +2D6 to Speed and +15 S.D.C./M.D.C."
    bonuses: { attributes: { PS: 4, Spd: "2d6" }, pools: { sdc: 15 } }
  - name: "Appearance (76-80): Humanoid Avian"
    description: "Roll 76-80 or choose. Bird-like features, large round eyes, clawed feet and hands, feathers for hair. Whether the race has wings and can fly depends on the special abilities selected (Step Six)."
  - name: "Appearance (81-85): Humanoid Mineral"
    description: "Roll 81-85 or choose. Rocky or crystalline appearance, in any colour. Natural body armor of 3D6x10 S.D.C./M.D.C."
    bonuses: { pools: { sdc: "3d6x10" } }
  - name: "Appearance (86-90): Humanoid Feline"
    description: "Roll 86-90 or choose. Cat-like features, bright oval eyes, a fur-covered body, pointy ears. +2 to P.P. and to Speed, and +10 S.D.C./M.D.C."
    bonuses: { attributes: { PP: 2, Spd: 2 }, pools: { sdc: 10 } }
  - name: "Appearance (91-95): Humanoid Ape"
    description: "Roll 91-95 or choose. Resembles a gorilla or ape: long arms, a fur-covered or extremely hairy body. +1D6 to P.S. and +5D6 S.D.C./M.D.C."
    bonuses: { attributes: { PS: "1d6" }, pools: { sdc: "5d6" } }
  - name: "Appearance (96-00): Humanoid Aquatic"
    description: "Roll 96-00 or choose. Fish or sea-mammal like (dolphin or whale), with webbed feet and hands, smooth or scaly skin, a blowhole or gills, no body hair, brightly coloured. Swims naturally at 90% and at 10 times normal running speed. +20 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 20 } }
  - { choose: 1, from: ["Environment: Earth-like World", "Environment (01-15): High Gravity", "Environment (16-29): Low Gravity", "Environment (30-44): High Radiation", "Environment (45-58): Frozen Planet", "Environment (59-73): Thermo World", "Environment (74-88): Twilight World", "Environment (89-00): Abrasive Atmosphere"], note: "Step Four: Physiological Modifications (printed 105-106). FIRST roll percentile dice: 01-65 the homeworld is Earth-like and there is no modification - take Earth-like World and do not roll here; 66-00 roll once on this table. Each S.D.C./M.D.C. bonus is stored as S.D.C.; the Step Two row says whether physiological bonuses are S.D.C. or M.D.C. points." }
  - name: "Environment: Earth-like World"
    description: "First roll 01-65. Over 60% of the alien species of the Three Galaxies evolved on Earth-like worlds: no modifications."
  - name: "Environment (01-15): High Gravity"
    description: "Roll 01-15 or choose. A homeworld with gravity above the galactic average (0.9 to 1.2 G covers 80% of inhabited planets) gave the race greater mass and endurance, and on normal planets it is much faster and lighter than at home. Average height 4 to 5 feet. S.D.C./M.D.C. bonus 3D4x10. Add 2D4 to P.S., -2 to P.P. Normal speed is increased three times, by hand."
    bonuses: { attributes: { PS: "2d4", PP: -2 }, pools: { sdc: "3d4x10" } }
  - name: "Environment (16-29): Low Gravity"
    description: "Roll 16-29 or choose. Below-average gravity made the race taller than typical humans; the stronger pull of normal planets slows it but gives it somewhat greater mass. Average height 6 to 10 feet, weight 1D4x100 lbs. S.D.C./M.D.C. bonus 1D4x10. Reduce P.S. by 1D6, add 1D4 to P.P. Normal speed is reduced by half, by hand."
    bonuses: { attributes: { PS: "-1d6", PP: "1d4" }, pools: { sdc: "1d4x10" } }
  - name: "Environment (30-44): High Radiation"
    description: "Roll 30-44 or choose. Impervious to radiation levels that would kill most humanoids. There is a 01-50% chance that every member of the race radiates low-level radioactivity that harms humanoids exposed for long periods (a few weeks), in which case its members must wear radiation proof suits to protect other races. Average height 5 to 7 feet, weight 180 to 200 lbs. S.D.C./M.D.C. bonus 1D4x10, and invulnerable to radiation. Can see into the ultraviolet range of light."
    bonuses: { pools: { sdc: "1d4x10" } }
  - name: "Environment (45-58): Frozen Planet"
    description: "Roll 45-58 or choose. Evolved on a far colder planet, or one in an Ice Age; withstands cold, ice and harsh frozen environments, and is impervious to cold. There is a 01-70% chance the race cannot tolerate warmth (35 degrees Fahrenheit / 2 C or higher): at those temperatures its members are -2 P.S. and P.P., speed is reduced by one third and S.D.C./M.D.C. is at -8, cumulative for every 10 hours of exposure above freezing, and when all S.D.C./M.D.C. and hit points are gone the alien dies. A life support suit keeps it alive, and any environmental armor can be reconfigured to keep it cold indefinitely. Average height 5 to 6 feet, weight 100 to 300 lbs. S.D.C./M.D.C. bonus 40."
    bonuses: { pools: { sdc: 40 } }
  - name: "Environment (59-73): Thermo World"
    description: "Roll 59-73 or choose. A steaming-hot homeworld, from a greenhouse atmosphere or closeness to its star. Impervious to heat and fire; lasers and energy blasts do half damage. There is a 01-80% chance the race cannot survive below 98 degrees Fahrenheit / 37 C (200 F / 93 C is comfortable): exposed to lower temperatures it sickens and dies with the same effects as the Frozen Planet''s. Environmental suits can be reconfigured to keep it warm. Average height 5 to 7 feet, weight 100 to 200 lbs. S.D.C./M.D.C. bonus 30."
    bonuses: { pools: { sdc: 30 } }
  - name: "Environment (74-88): Twilight World"
    description: "Roll 74-88 or choose. An extremely dark, night-like world. Nightvision 600 feet (183 m) and sensitive hearing, about 20 percent beyond the human range; but the race is sensitive to average light and is blinded by 100 watts of light (normal sunlight). While blinded it is -8 to strike, parry and dodge; helmets with polarized lenses relieve the problem. Average height 4 to 5 feet, weight 100 to 200 lbs. S.D.C./M.D.C. bonus 10."
    bonuses: { pools: { sdc: 10 } }
  - name: "Environment (89-00): Abrasive Atmosphere"
    description: "Roll 89-00 or choose. High scathing winds or a corrosive atmosphere gave the race a tough, thick skin or leather plating, like an Earth rhinoceros. Average height 5 to 10 feet, weight 200 to 400 lbs. S.D.C./M.D.C. bonus 3D6x10. No other bonuses or penalties."
    bonuses: { pools: { sdc: "3d6x10" } }
  - { choose: 1, from: ["Characteristic: None", "Characteristic (01-16): Pointy or Large Facial Feature", "Characteristic (17-39): Odd Skin Color", "Characteristic (40-48): Odd Hair Color", "Characteristic (49-53): Double-Jointed", "Characteristic (54-58): Unusual Eyes", "Characteristic (59-64): Fur-Covered", "Characteristic (65-68): Prehensile Feet", "Characteristic (69-72): Scaly Skin", "Characteristic (73-76): No Body Hair", "Characteristic (77-79): Small Horns", "Characteristic (80-84): Tough, Lumpy Skin", "Characteristic (85-89): Prehensile Tail", "Characteristic (90-94): Retractable Claws", "Characteristic (95-00): Stocky"], note: "Step Five: Unusual Characteristics (printed 106). Humanoid races that are not human-like can roll here; the Humanoid appearance (31-50) is sent to it. A race that does not use the table takes None. Each S.D.C./M.D.C. figure is stored as S.D.C.; printed 104 leaves the choice between the two to the G.M., and the page does not tie this step to Step Two." }
  - name: "Characteristic: None"
    description: "The table is not used: a human-like race, or one the G.M. gives no unusual characteristic."
  - name: "Characteristic (01-16): Pointy or Large Facial Feature"
    description: "Roll 01-16 or choose. Pointy or large ears, nose or other facial feature."
  - name: "Characteristic (17-39): Odd Skin Color"
    description: "Roll 17-39 or choose. Roll percentile dice again for the colour: 01-10 yellow, 11-20 green, 21-30 red, 31-40 gray, 41-50 light blue, 51-60 stark white, 61-70 dark blue, 71-80 coal black, 81-90 purple, 91-00 orange."
  - name: "Characteristic (40-48): Odd Hair Color"
    description: "Roll 40-48 or choose. Roll percentile dice again for the colour: 01-10 green, 11-20 light blue, 21-30 white streaked, 31-40 bright flame red, 41-50 stark white, 51-60 bright yellow, 61-70 metallic silver, 71-80 dark blue, 81-90 purple, 91-00 orange."
  - name: "Characteristic (49-53): Double-Jointed"
    description: "Roll 49-53 or choose. Extremely flexible bones. Slips handcuffs, manacles and other bonds: 79% when hands and/or feet are tied with rope, handcuffed or chained, 46% when the whole body is bound with rope, chains, straps or a straitjacket. Can narrow the body to half its width shoulder to shoulder, or curl into a ball 20% of normal height and half normal width. +2 to roll with fall or impact."
    bonuses: { combat: { roll: 2 } }
  - name: "Characteristic (54-58): Unusual Eyes"
    description: "Roll 54-58 or choose. Roll percentile dice again: 01-17 very small (at least twice as small as average), 18-34 round, 35-55 very large (at least twice as large as average), 56-75 odd colour (red, yellow, white and so on), 76-89 very elliptical, 90-00 glowing eyes."
  - name: "Characteristic (59-64): Fur-Covered"
    description: "Roll 59-64 or choose. The race is covered in fur."
  - name: "Characteristic (65-68): Prehensile Feet"
    description: "Roll 65-68 or choose. Prehensile feet and toes like a monkey''s, able to grasp objects and climb. Not developed enough to throw an object or fire a gun (-6 to strike), but they pick up and carry small items, push buttons, pull levers, untie ropes and even work a console, poorly. When barefoot: +30% on climbing rolls, +10% on acrobatic skills and +1 to dodge. Skills such as computer operation or pick pockets done with the feet are at -25%; complicated skills such as mechanics, demolitions and piloting cannot be done with any accuracy (10% is the best possible base proficiency with feet)."
  - name: "Characteristic (69-72): Scaly Skin"
    description: "Roll 69-72 or choose. A tough, smooth, reptilian skin with small scales. Adds 30 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (73-76): No Body Hair"
    description: "Roll 73-76 or choose. The race has no body hair."
  - name: "Characteristic (77-79): Small Horns"
    description: "Roll 77-79 or choose. Vestigial horns 1D4 inches (1D10 cm) long protruding from the forehead."
  - name: "Characteristic (80-84): Tough, Lumpy Skin"
    description: "Roll 80-84 or choose. Adds 30 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (85-89): Prehensile Tail"
    description: "Roll 85-89 or choose. An extra appendage, more limited than prehensile feet: it can grasp and carry things or help climb, but cannot untie rope or fire a weapon. +1 to strike and parry with the tail; the tail itself is +5 to dodge; +20% on climbing rolls when the tail is used. Length 3D4 feet (0.9 to 3.7 m); its look follows the race''s overall appearance."
  - name: "Characteristic (90-94): Retractable Claws"
    description: "Roll 90-94 or choose. Claws like a cat''s that add 2D4 S.D.C. to hand to hand damage, or 2D4 M.D. if the race has supernatural P.S."
  - name: "Characteristic (95-00): Stocky"
    description: "Roll 95-00 or choose. Exceptionally broad or husky, about twice as broad as the average humanoid of the same height. Add 50 lbs (23 kg) to weight, +1D4 to P.S. and 4D4 to S.D.C./M.D.C."
    bonuses: { attributes: { PS: "1d4" }, pools: { sdc: "4d4" } }
  - { choose: 1, from: ["Power: None", "Power (01-10): Lesser Psionics", "Power (11-20): Greater Psionics", "Power (21-30): Superhuman Attributes", "Power (31-40): Winged Flight", "Power (41-50): Psionic Flight", "Power (51-60): Energy Attack", "Power (61-70): Giant Size, M.D.C.", "Power (61-70): Giant Size, S.D.C.", "Power (71-90): Resistance to Damage", "Power (91-00): Special"], note: "Step Six: Unusual Powers (printed 106-107), an optional step. Only about 20% of races have unusual powers: the G.M. decides, or roll percentile dice first - 01-20 the race has one, roll or pick here; 21-00 it has none, take None. 61-70 prints an M.D.C. figure and an S.D.C. figure; the choice between them is the G.M.''s. 91-00 (roll twice more) is worked out with the G.M.; this group holds one result." }
  - name: "Power: None"
    description: "First roll 21-00, or the G.M.''s decision: the race has no unusual powers."
  - name: "Power (01-10): Lesser Psionics"
    description: "Roll 01-10 or choose. Six psionic powers, all from ONE of the healing, sensitive or physical categories - keep to a single category. The powers are the same for every member of the race, and no new ones are gained unless a psychic O.C.C. is chosen for the race. I.S.P. is the M.E. attribute number plus 5D6 at first level, plus 1D6 per additional level. Every member of the race is treated as a major psionic for saving throws vs psionic attack."
    psionics: { type: "major", isp_base: "M.E. attribute number plus 5d6, +1d6 per additional level of experience", powers_starting: 6, categories_allowed: ["Healing", "Sensitive", "Physical"] }
  - name: "Power (11-20): Greater Psionics"
    description: "Roll 11-20 or choose. Nine psionic powers from any of the healing, sensitive or physical categories plus two super-psionic powers. They are the same for every member of the race and should follow a pattern (for example all related to telepathy: the sense powers, mind block, hypnotic suggestion and the like). No new powers are gained at higher levels unless a psychic O.C.C. is chosen for the race. I.S.P. is 1D4x10 plus the M.E. attribute number, plus 10 per level. The page names no psionic tier for this row, so the powers and I.S.P. are recorded by hand; see extraction_notes."
  - name: "Power (21-30): Superhuman Attributes"
    description: "Roll 21-30 or choose. Add +12 to any one racial attribute, or +6 to any two, by hand. P.S. excepted, no combination of bonuses that would take an attribute above 30 should be allowed."
  - name: "Power (31-40): Winged Flight"
    description: "Roll 31-40 or choose. The race has wings and can fly. Flying speed is normal running speed plus 2D4x10. The race''s average weight should not exceed 120 lbs (54 kg)."
  - name: "Power (41-50): Psionic Flight"
    description: "Roll 41-50 or choose. The race flies without wings, levitating at high speed by psionic power. Flying speed is 1D6x10 plus the race''s Spd attribute."
  - name: "Power (51-60): Energy Attack"
    description: "Roll 51-60 or choose. The race fires energy blasts, bolts of flame, electrical arcs or some other energy attack. Damage is 1D6 M.D., plus 1D6 M.D. at levels three, six, seven and ten."
  - name: "Power (61-70): Giant Size, M.D.C."
    description: "Roll 61-70 or choose, for an M.D.C. race. At least twice the galactic average of 5 to 7 feet: add 4D6 feet to height (minimum average height 12 feet / 3.7 m) and 2D4x100+100 lbs to weight. A bonus of 100+2D6x10 M.D.C. (it lands only on a character who already has an M.D.C. pool; otherwise enter it by hand), and P.S. is increased by 1D6."
    bonuses: { attributes: { PS: "1d6" }, pools: { mdc: "2d6x10+100" } }
  - name: "Power (61-70): Giant Size, S.D.C."
    description: "Roll 61-70 or choose, for an S.D.C. race. At least twice the galactic average of 5 to 7 feet: add 4D6 feet to height (minimum average height 12 feet / 3.7 m) and 2D4x100+100 lbs to weight. A bonus of 1D4x100+400 S.D.C., and P.S. is increased by 1D6."
    bonuses: { attributes: { PS: "1d6" }, pools: { sdc: "1d4x100+400" } }
  - name: "Power (71-90): Resistance to Damage"
    description: "Roll 71-90 or choose. Resistant to one particular form of damage (energy, physical attacks, fire/heat, magic and so on): one quarter damage from those attacks and half damage from related ones - a race impervious or resistant to normal fire and heat takes half damage from magic fires."
  - name: "Power (91-00): Special"
    description: "Roll 91-00 or choose. Roll twice on the table, re-rolling repeats, or pick two different powers. This entry holds neither: settle the two with the G.M. and note them on the sheet."
  - { choose: 1, from: ["Technology (01-20): Stone Age Primitives", "Technology (21-30): Metal Users, Pre-Industrial Age", "Technology (31-40): Industrial Age, Pre-Space Age", "Technology (41-60): Atomic Age, Early Space Age", "Technology (61-75): Mature Space Age", "Technology (76-90): Advanced Space Age", "Technology (91-98): Highly Advanced Civilization", "Technology (99-00): Amazing Civilization"], note: "Step Seven: Technological Level (printed 107), rolled once or picked. It is the level of the most advanced nation or culture on the homeworld. Coming from a primitive race does not bar a character from tech skills, provided the training is explained in the character''s story." }
  - name: "Technology (01-20): Stone Age Primitives"
    description: "Roll 01-20 or choose. Only very simple tools (sticks, stone axes); the wheel may or may not have been discovered. Mostly nomadic hunter-gatherers or, at best, early farming settlements."
  - name: "Technology (21-30): Metal Users, Pre-Industrial Age"
    description: "Roll 21-30 or choose. Anything between Earth''s Bronze Age and its Renaissance: metal working, stone buildings and, at the highest levels, crude firearms."
  - name: "Technology (31-40): Industrial Age, Pre-Space Age"
    description: "Roll 31-40 or choose. Gunpowder weapons and explosives, sophisticated metallurgy, machinery - the equivalent of Earth''s 19th century to the first half of the 20th. Railroads, steam ships, early combustion engines and even airships and early prop airplanes, but no way to travel beyond the planet''s atmosphere."
  - name: "Technology (41-60): Atomic Age, Early Space Age"
    description: "Roll 41-60 or choose. The equivalent of late 20th and probably early 21st century Earth: atomic power and weapons, crude spaceships and satellites able to reach other planets of the home system. No faster-than-light ships."
  - name: "Technology (61-75): Mature Space Age"
    description: "Roll 61-75 or choose. Sophisticated robots and computers, self-sustaining space stations, relatively easy sublight travel and true starships. Rifts Earth fits here. Past this level advancement levels off: this culture''s combat robot or vehicle is second rate beside a higher-tech one, but not completely outmatched."
  - name: "Technology (76-90): Advanced Space Age"
    description: "Roll 76-90 or choose. Faster-than-light travel, usually by gravitonic drives, and the exploration of other stars. The largest civilizations of the Three Galaxies are all at this level."
  - name: "Technology (91-98): Highly Advanced Civilization"
    description: "Roll 91-98 or choose. Beyond the average technological limits in one field of knowledge, the G.M.''s choice (space drive, weapons technology, robotics, bionics and so on). The race''s culture should explain why it is not yet an important player in galactic politics."
  - name: "Technology (99-00): Amazing Civilization"
    description: "Roll 99-00 or choose. An ultra-tech race clearly superior to every known galactic culture, perhaps from a far-off galaxy or another dimension. The G.M. designs its technology; the book''s weapons and equipment can be modified by raising M.D.C., damage, overall performance and/or range by 20 to 60%."
  - { choose: 1, from: ["Magic (01-60): No Magic", "Magic (61-70): Limited Magic", "Magic (71-94): Magic-Using Culture", "Magic (95-00): Superhuman Magical Capabilities"], note: "Step Eight: Magical Level (printed 107-108), rolled once or picked. It describes the race''s magical knowledge and potential; the page prints no spells or P.P.E. for any row." }
  - name: "Magic (01-60): No Magic"
    description: "Roll 01-60 or choose. The race does not practice magic, either because it has no magical potential whatsoever (printed as 1-30) or because it does not know of or believe in magic (31-00), in which case a member could learn it from a teacher. The page prints the two as sub-cases and gives no instruction to roll again."
  - name: "Magic (61-70): Limited Magic"
    description: "Roll 61-70 or choose. Magic-capable, but only a small percentage of the population, or a few nations or subcultures, know how to use it. Wizards, magic items and techno-wizardry are very rare, expensive and out of reach of the population at large."
  - name: "Magic (71-94): Magic-Using Culture"
    description: "Roll 71-94 or choose. Magic is an important part of life for the whole race: every village, tribe or clan has at least one or two powerful shamans or mages, and magic items and techno-wizardry are common and widely applied. The race may achieve things far beyond its mundane technology."
  - name: "Magic (95-00): Superhuman Magical Capabilities"
    description: "Roll 95-00 or choose. The entire race is mage-capable, with the abilities of a mystic or ley line walker, or of a magical O.C.C. of the G.M.''s choice; take that O.C.C. for the character with the G.M.''s agreement. Conventional science and technology are likely to be at low levels."
  - { choose: 1, from: ["Culture (01-10): Genocidal Xenophobes", "Culture (11-25): Aggressive Racial Supremacists", "Culture (26-40): Warrior Race", "Culture (41-55): Enlightened Imperialists", "Culture (56-70): Peaceful Expansionists", "Culture (71-85): Non-Interventionists", "Culture (86-00): Pacifists"], note: "Step Nine: General Attitude/Culture (printed 108), rolled once or picked. It is the outlook of the race''s dominant culture, not the alignment of any one member." }
  - name: "Culture (01-10): Genocidal Xenophobes"
    description: "Roll 01-10 or choose. Roughly equivalent to diabolic. Every other species is a mortal enemy to be destroyed, or deceived and manipulated into harming itself. Few such races last long: their neighbours unite to destroy or conquer them."
  - name: "Culture (11-25): Aggressive Racial Supremacists"
    description: "Roll 11-25 or choose. Roughly equivalent to miscreant or aberrant. The race holds itself superior to all others and means to dominate them, usually by enslaving or subjugating them, turning to diplomacy only when it is too weak to use force. It keeps an agreement while watched or while the agreement serves it."
  - name: "Culture (26-40): Warrior Race"
    description: "Roll 26-40 or choose. Typically anarchist or aberrant, but can be any alignment. Values combat prowess and is very aggressive, but has a sense of honour: it keeps treaties even against its interests and gives its word rarely, and it goes to war readily at any sign of treachery."
  - name: "Culture (41-55): Enlightened Imperialists"
    description: "Roll 41-55 or choose. The race wishes to expand and grow and may use violence to do it, but prefers diplomacy and economic and cultural dominance to outright conquest."
  - name: "Culture (56-70): Peaceful Expansionists"
    description: "Roll 56-70 or choose. The race wishes to expand and grow but will never attack or settle on an inhabited planet; it goes only to uninhabited worlds and fights only in self-defense."
  - name: "Culture (71-85): Non-Interventionists"
    description: "Roll 71-85 or choose. As the Peaceful Expansionists, but the race prefers not to get involved in the affairs of other peoples."
  - name: "Culture (86-00): Pacifists"
    description: "Roll 86-00 or choose. The race as a whole, though perhaps not every individual, holds violence wrong under any circumstances. When diplomacy fails it tries to escape its enemies or resists passively rather than defend itself actively."
extraction_notes: "NEW CLASS, written 2026-10-05 from 200 dpi renders of Phase World printed 104-108 (cache p104-p108, page_offset 0); every figure was read off the renders. The book prints this as Creating More Alien Races, a nine-step generator for a whole RACE that a G.M. uses or lets a player use; the survey listed it as a generator, not a class, and Nate ruled it is imported as a class whose steps are pick groups, after the Heroes Unlimited alien (hu-aliens). men_of_arms is false because this is a race. ATTRIBUTES: printed 104 says the character starts with base attributes of 3D6 and all bonuses are added to that base, so attribute_dice holds 3D6 for all eight; that is also the 21-50 Galactic Average row. Step One 01-20 prints 2D4 on EITHER three mental OR three physical attributes: stored as two options sharing the band; the mental one sets I.Q., M.E. and M.A. to 2D4, which is a reading, since the page says three mental attributes without naming them, and the physical one stays prose because the page does not say which three of the five physical attributes. Rows 51-60 to 91-00 add dice to ANY three or four attributes and stay prose; the one figure stored is 91-00''s 2D6+10 to P.S.; the page prints 2D6+10 to P.S. and Spd or P.B. once, and whether Spd or P.B. takes the same roll or a second one is not printed. DAMAGE CAPACITY: the page prints 41-50 and 51-60 as plain S.D.C. figures, without saying whether they replace or add to S.D.C. determined normally, and 71-80, 81-90 and 91-00 as a Base M.D.C. (1D6x10, 3D6x10, 2D6x100); all five are stored as pool bonuses because an option has no other place for them and the class states no base (found 2026-10-05, after the import: a pool bonus adds only to a base, so the two S.D.C. rows apply and the three M.D.C. rows, and Giant Size''s M.D.C. option, add nothing and are entered by hand); the per-level gains (2D4, 2D6, 1D4x10) and the whole of 61-70 (base M.D.C. equal to P.E. plus 1D6 per level, with every later bonus halved) are prose. No mdc_base is stated on the class because the page gives M.D.C. to four rows of seven. S.D.C./M.D.C.: printed 104 says most bonuses carry an S.D.C./M.D.C. option, leaving the G.M. a choice between the two; only Step Two''s own rows tie the appearance and physiological bonuses (Steps Three and Four) to its result, and Steps Five and Six are never tied to it. Every such figure in Steps Three, Four and Five is stored as an S.D.C. pool bonus and the group notes say so. Step Six 61-70 Giant Size prints two different figures (100+2D6x10 M.D.C. or 1D4x100+400 S.D.C.) and is stored as two options sharing the band. STEPS FOUR, FIVE AND SIX each sit behind a condition: Four behind a first roll (01-65 Earth-like, no modifications), Five is for humanoid but not human-like races, Six is optional with a first roll (01-20 has powers). Each group carries one option with no band for the result where the table is not used. SUB-TABLES (odd skin colour, odd hair colour, unusual eyes, and the two sub-cases of No Magic) are in the row descriptions. PSIONICS: the Lesser Psionics row carries a psionics block: six powers, Healing, Sensitive and Physical allowed, tier major because the page says its members are considered major psionics for saving throws. psionics_allowed is not stated, because the pages never mention the standard psionics roll. The page limits the six to ONE of the three categories, which is stated in the description. The Greater Psionics row (nine from the three categories plus two super, I.S.P. 1D4x10 plus M.E. plus 10 per level) prints no tier and carries no block. CONDITIONAL NUMBERS left in prose: Double-Jointed''s +2 to roll is stored; Prehensile Feet''s +1 dodge (barefoot), the Prehensile Tail''s strike, parry and dodge (with the tail), Retractable Claws'' damage, the Twilight World''s -8 while blinded and the Frozen Planet''s exposure penalties are not. Speed multipliers (High Gravity x3, Low Gravity half) are prose. NO SKILLS, NO EXPERIENCE TABLE AND NO MONEY are stored: the pages print none and name none, and refer to an O.C.C. chosen for the race. Steps Seven, Eight and Nine print no numbers and are stored as pick groups so the race''s technology, magic and culture are on the sheet."
---

## Lore

The Three Galaxies hold thousands of alien peoples, far more than any book
could list. This entry is for one of the unlisted ones: a race built step by
step with the G.M., who has the last word on what exists in the campaign.

Nine steps describe the whole race rather than one person: how gifted its
people are, how much punishment their bodies take, what they look like, what
their homeworld did to them, any odd feature or power they share, and how far
their technology, magic and culture have come. Each step is a table that can
be rolled or simply chosen.

## GM Notes

The tables are guidelines, not rules. The G.M. may pick results, roll them,
invent others, or set the race''s attributes outright by comparison with other
non-human races. Most races in the book itself were not made with these
tables.

**Added by hand.** Step One''s bonuses to "any three" or "any four" attributes,
and the Spd or P.B. part of the 91-00 row, are for the builder to place. Per-level
M.D.C. (Step Two), the Minor M.D.C. Being''s base of P.E. and its halved
bonuses, speed multipliers and flying speeds are worked out at the table.

**S.D.C. or M.D.C.** Printed 104 says most bonuses carry an S.D.C./M.D.C.
option and leaves the choice to the G.M. Step Two''s own rows say which the
appearance and physiological bonuses (Steps Three and Four) are; the page does
not tie Steps Five and Six to it. Every "S.D.C./M.D.C." figure is stored as
S.D.C.: where it is M.D.C., move those points by hand (appearance and
physiological bonuses are halved for the Minor M.D.C. Being). The M.D.C. rows
also make P.S. and P.E. supernatural, except the Minor one.

**Steps that may not apply.** Step Four is rolled only on a first roll of
66-00, Step Five only for humanoid races that are not human-like, and Step Six
only on a first roll of 01-20 or the G.M.''s say-so. Each has a "none" choice.

**Step Six, 91-00** gives two powers, and **Greater Psionics** gives nine
powers plus two super-psionic powers with I.S.P. of 1D4x10 plus M.E. and 10
per level; neither is applied automatically.

**Percentage chances inside a row** - the radiating High Radiation race
(01-50%), the Frozen Planet race that cannot bear warmth (01-70%), the Thermo
World race that cannot bear cold (01-80%) - are in the row descriptions and
are not applied.

**Step Eight** prints no spells or P.P.E. for any row. A race of Superhuman Magical
Capabilities is mage-capable with the abilities of a mystic or ley line
walker, or another magical O.C.C. of the G.M.''s choice.
',
       updated_at = datetime('now')
 WHERE class_id = 'phase-world-alien'
   AND instr(markdown, 'all five are stored as pool bonuses because an option has no other place for them and the class states no base;') > 0
   AND length(markdown) = 38629;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 13 classes carry their new text' AS assertion, count(*) AS got, 13 AS want
  FROM imported_classes
 WHERE (class_id = 'russian-mystic-kuznya' AND instr(markdown, 'the M.E. and M.A. dice are stored in bonuses and rolled by the sheet') > 0)
    OR (class_id = 'merchant' AND instr(markdown, 'a second OCCUPATION is not') > 0)
    OR (class_id = 'psi-x-alien' AND instr(markdown, 'Four other classes do name it') > 0)
    OR (class_id = 'amana' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'arac' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'chasseur-vert' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'forest-warden' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'squilb' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'vernulian' AND instr(markdown, 'does not cover this') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, 'attribute_dice for Spd (BOOK-INGEST-AUDIT.md F120)') > 0)
    OR (class_id = 'amphib' AND instr(markdown, '(BOOK-INGEST-AUDIT.md F120). All seven rows were re-read') > 0)
    OR (class_id = 'gene-splicer-mutant' AND instr(markdown, 'The class states an M.D.C. base of zero, which no page prints') > 0)
    OR (class_id = 'phase-world-alien' AND instr(markdown, 'so this pick adds NOTHING by itself') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'russian-mystic-kuznya' AND instr(markdown, 'and are prose; the fixed +2 to P.E. is in bonuses') > 0)
    OR (class_id = 'merchant' AND instr(markdown, 'which is the same limitation an R.C.C. plus O.C.C. runs into') > 0)
    OR (class_id = 'psi-x-alien' AND instr(markdown, 'that a pure-ASCII class file cannot spell') > 0)
    OR (class_id = 'amana' AND instr(markdown, 'ladder); see BOOK-INGEST-AUDIT.md F116.') > 0)
    OR (class_id = 'arac' AND instr(markdown, 'prose; see BOOK-INGEST-AUDIT.md F116.') > 0)
    OR (class_id = 'chasseur-vert' AND instr(markdown, 'are prose; see BOOK-INGEST-AUDIT.md F116.') > 0)
    OR (class_id = 'forest-warden' AND instr(markdown, 'an ability (BOOK-INGEST-AUDIT.md F116).') > 0)
    OR (class_id = 'squilb' AND instr(markdown, 'prose, see BOOK-INGEST-AUDIT.md F116.') > 0)
    OR (class_id = 'vernulian' AND instr(markdown, 'prose, see BOOK-INGEST-AUDIT.md F116 (judg') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, 'attribute_dice for Spd (BOOK-INGEST-AUDIT.md F119)') > 0)
    OR (class_id = 'amphib' AND instr(markdown, '(BOOK-INGEST-AUDIT.md F119). All seven rows were re-read') > 0)
    OR (class_id = 'gene-splicer-mutant' AND instr(markdown, 'so the hit points and S.D.C. the sheet shows are not the book''s and are not used') > 0)
    OR (class_id = 'phase-world-alien' AND instr(markdown, 'all five are stored as pool bonuses because an option has no other place for them and the class states no base;') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('russian-mystic-kuznya', 'merchant', 'psi-x-alien', 'amana', 'arac', 'chasseur-vert', 'forest-warden', 'squilb', 'vernulian', 'oni-of-the-one-hundred', 'amphib', 'gene-splicer-mutant', 'phase-world-alien') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~171-closeout-claim-sweep-part-2.sql');
