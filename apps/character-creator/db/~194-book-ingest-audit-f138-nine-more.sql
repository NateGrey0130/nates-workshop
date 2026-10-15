-- Take BOOK-INGEST-AUDIT F138 on nine more classes: per-skill bonuses from prose to scoped category entries
-- 7 classes, each replaced whole: grey-seer, pirate, sailor, idie-fisherman, kill-hound, monkey-boy-tech, psi-ghost.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~194-book-ingest-audit-f138-nine-more.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Nine classes BOOK-INGEST-AUDIT F138 did not name, found by a planning sweep on
-- 2026-10-12; seven are converted here, each figure read off a render of its
-- cited page. Each per-skill bonus is a second, scoped entry for its category.
-- - grey-seer: Technical +15 to Art, Language and Lore (FoM printed 91).
-- - pirate, sailor: Technical +10 to lores and languages (South America
--   printed 48 and 47).
-- - idie-fisherman: Communications Language +10 (D-Bees of North America
--   printed 105), carried by a Technical entry for every Language: row.
-- - kill-hound: Streetwise +10 (Lone Star printed 45).
-- - monkey-boy-tech: Cryptography +15, Forgery +10, Computer Hacking +10,
--   language skills +15 (Lone Star printed 85).
-- - psi-ghost: Locksmith +10 (Psyscape printed 65).
-- A language bonus reaches every Language: and Literacy: row in whichever
-- category the catalog files it (Nate's ruling, 2026-10-14, ~192); the Grey
-- Seer's Lore bonus reaches the two Lore rows the catalog files under Cowboy
-- by the same reading. Not changed: felinoid (its +10 is to Climbing and
-- Acrobatics an occupation grants, and no key adds a race's bonus to an
-- occupation's skill) and geofront-assault-geo-borg (no key scopes a bonus to
-- one package). No class's admitted skill set changes.

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
      - { name: "Technical", only: ["Art", "Art: Line Drawing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }
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
   AND instr(markdown, 'add the 15% to those picks by hand') > 0
   AND length(markdown) = 15590;

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
      - { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
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
   AND instr(markdown, 'add it by hand to a Lore or Language pick') > 0
   AND length(markdown) = 8627;

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
      - { name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
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
   AND instr(markdown, 'add it by hand to those picks') > 0
   AND length(markdown) = 8168;

-- == idie-fisherman ==
UPDATE imported_classes
   SET markdown = '---
id: idie-fisherman
men_of_arms: false
occ_group: optional
name: Idie Fisherman
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.105-106
category: occ
tags: [wilderness, aquatic]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
starting_money: "2d6x1000 in universal credits or tradable goods"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Language: Native Tongue (American) at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other: one of choice (+20%)." }
    - { name: "Boat Building", base: 45, per_level: 5, note: "+20%" }
    - { name: "Carpentry", base: 35, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Fishing", base: 65, per_level: 5, note: "+25%; professional quality." }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%; knowledge pertains only to plants found around the area where the character was born." }
    - { name: "Land Navigation", base: 50, per_level: 4, note: "+14%" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Boat: Paddle Types/Canoe/Kayak", base: 65, per_level: 5, note: "+15%; printed as Pilot: Boat: Paddle Type." }
    - { name: "Boat: Sail Type", base: 70, per_level: 5, note: "+10%; printed as Pilot: Boat: Sail Type." }
    - { name: "Boat: Ships", base: 55, per_level: 5, note: "Printed as Pilot: Boat: Ships (+10%/+8%); the catalog row carries one figure, so +10% is added." }
    - { name: "Preserve Food", base: 40, per_level: 5, note: "+15%" }
    - { name: "Skin & Prepare Animal Hides", base: 50, per_level: 5, note: "+20%" }
    - { name: "Track & Hunt Sea Animals", base: 45, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Whittling & Sculpting", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Spear", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if of an evil alignment) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Language: Other", "Literacy: Other"], note: "Radio: Basic, Language and Literacy only. The book''s Language bonus is on Language only; the Technical Language line carries it." }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Detect Ambush", "Intelligence", "Tracking (people)", "Sniper"], bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "General (+10%) or Exotic only; the +10% is on General only, and the next line carries it." }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 10, note: "The +10% is on General only." }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", only: ["Animal Husbandry", "First Aid", "Holistic Medicine"], note: "Holistic Medicine is +10%; the next line carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "Holistic Medicine is +10%." }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Juicer Football", "Murderthon"] }
      - { name: "Pilot", only: ["Bicycling", "Boat: Motor, Race & Hydrofoil", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Water Scooters", "Water Skiing & Surfing"], note: "Boat: Motor & Hydrofoil +5%, Water Scooters +10%, Water Skiing & Surfing +14%; the next three lines carry them." }
      - { name: "Pilot", only: ["Boat: Motor, Race & Hydrofoil"], bonus: 5, note: "Boat: Motor & Hydrofoil +5%." }
      - { name: "Pilot", only: ["Water Scooters"], bonus: 10, note: "Water Scooters +10%." }
      - { name: "Pilot", only: ["Water Skiing & Surfing"], bonus: 14, note: "Water Skiing & Surfing +14%." }
      - "Pilot Related"
      - { name: "Technical", note: "+10% on Lore skills only; the next line carries it." }
      - { name: "Technical", only_prefix: ["Lore"], bonus: 10, note: "+10% on Lore skills only." }
      - { name: "Technical", only_prefix: ["Language:"], bonus: 10, note: "The Communications line''s Language +10%; the catalog files every Language row here." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Cowboy, Electrical, Military, Rogue and Science: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 3, count: 1 }
      - { level: 8, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "wooden-spear", qty: 3, note: "Three high-quality fishing spears (2D6 S.D.C.) for spear fishing." }
  - { item_id: "vibro-spear", qty: 1, note: "Vibro-Spear (2D6+3 M.D.)." }
  - { item_id: "vibro-knife", qty: 1, note: "Vibro-Knife (1D6 M.D.)." }
  - { choose: 1, label: "energy rifle or pistol", qty: 1, from: ["l-20-pulse-rifle", "wilk-s-457-laser-pulse-rifle", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ip-7-ion-pistol"], note: "Energy rifle or pistol of choice, typically an L-20." }
  - { item_id: "e-clip", qty: 4, note: "Four additional E-Clips for the weapon." }
  - { item_id: "survival-knife", qty: 1, note: "1D6 S.D.C." }
  - { item_id: "large-sack", qty: 1, note: "Large travel sack." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "rope", qty: 3, note: "100 feet (30.5 m) of rope." }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "traveling-clothes", qty: 3 }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "tackle-box", qty: 1 }
  - { item_id: "fishing-pole", qty: 1, note: "Collapsible." }
  - { item_id: "fishing-line-and-hooks", qty: 1, note: "2D4x10 fishing hooks and lures." }
  - { item_id: "fishing-net", qty: 1 }
  - { item_id: "tent-one-man", qty: 1, note: "Personal tent." }
  - { item_id: "mosquito-netting-per-sq-yard-meter", qty: 1, note: "Mosquito netting." }
  - { item_id: "hatchet", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "wooden-stake", qty: 4 }
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1, note: "A suit of medium Mega-Damage armor." }
trackable_resources: []
restrictions:
  - "The book presents this occupation as the one 73% of Idie Swamp Men take; it does not bar other races."
extraction_notes: "WB30 D-Bees of North America printed 105-106 (cache p106-p107), every number read off 200 dpi renders. The O.C.C. follows the Idie Swamp Men race block on printed 105 (heading Idie Fishermen O.C.C.) and ends at its Note on printed 106, above the Iktek Diggers heading. || CATEGORY and GROUP: an occupation, occ_group optional (judgement): the book frames it as a working, water-trade occupation of fishing and navigation, neither Men at Arms nor magic nor psychic, the Adventurer and Workman group the Wilderness Scout it borrows its table from is filed under. Prints no S.D.C. or M.D.C., so men_of_arms false. No race_restrictions: the page says 73% of Idie take it but never limits it to the Idie (its Native Tongue is American). || XP: Use the same Experience Table as the Wilderness Scout; copied from the stored wilderness-scout (Rifts Ultimate Edition) ladder. || SKILLS: catalog base plus printed bonus. Language: Native Tongue (American) 98% is Language: Native Tongue 98. Pilot: Boat: Paddle Type, Sail Type and Ships are the catalog''s Boat: Paddle Types/Canoe/Kayak, Boat: Sail Type and Boat: Ships; Ships prints +10%/+8% and the catalog row holds one figure, so 45+10 with a note. Track & Hunt Sea Animals 35+10. || HAND TO HAND: Basic; Expert for one related skill, Martial Arts or Assassin (evil) for two. || RELATED: five, plus one at levels 3, 5, 9 and 12. Communications Radio: Basic, Language and Literacy only, mapped to Language: Other (a Technical row, cross-category; Technical is granted) and Literacy: Other; the +10% is on Language only, stored as a scoped Technical entry for every Language: row, where the catalog files them (BOOK-INGEST-AUDIT.md F138). Horsemanship General (+10%) or Exotic only, mapped to Horsemanship: General and Horsemanship: Exotic Animals, the bonus on General a second, scoped entry. Medical Holistic +10% a scoped entry. Physical except Boxing, Gymnastics and Juicer sports (Juicer Football, Murderthon). Pilot limited to seven rows, printed names mapped: Boat: Motor & Hydrofoil -> Boat: Motor, Race & Hydrofoil; Hover Craft (Ground) -> Hover Craft (ground); Hovercycle -> Hovercycles, Skycycles & Rocket Bikes; Motorcycle -> Motorcycles & Snowmobiles; the per-skill bonuses are scoped entries. Technical +10% on Lore only, a scoped entry. Cowboy, Electrical, Military, Rogue, Science none. SECONDARY: four, plus one at levels 3, 8 and 13. || EQUIPMENT: fishing spears (2D6 S.D.C.) have no catalog row and are mapped to wooden-spear x3 with the printed damage in the note (judgement). Energy rifle or pistol of choice (typically L-20) as a choice led by l-20-pulse-rifle. 100 feet of rope as rope (per 40 ft) x3. Personal tent as tent-one-man; mosquito netting as the per-square-yard row; mallet as small-mallet; medium Mega-Damage armor as personalized-light-or-medium-mdc-body-armor (judgement; no generic medium row). Personal items not stored. || MONEY: 2D6x1,000 in Universal Credits or tradable goods (fishbone carvings, stones, furs)."
---

## Lore

Most Idie Swamp Men, nearly three in four, make their living as
fishermen. It is the people''s oldest trade and their great pride: they
work the swamps, rivers and coasts of the South with spear, net and line,
build and sail their own boats, and know the local waters, plants and sea
life better than anyone. They are skilled navigators and woodworkers, and
many serve their villages and neighboring towns as boatmen and guides as
well as fishermen.

## GM Notes

The book introduces this occupation with the Idie Swamp Men; 73% of the
race take it.

Money is 2D6x1,000 in Universal Credits or in tradable goods such as
jewelry and fishbone carvings, semi-precious and precious stones and furs.
',
       updated_at = datetime('now')
 WHERE class_id = 'idie-fisherman'
   AND instr(markdown, 'the +10% is on Language only - add it by hand') > 0
   AND length(markdown) = 10285;

-- == kill-hound ==
UPDATE imported_classes
   SET markdown = '---
id: kill-hound
men_of_arms: false
name: Kill Hound
system: rifts
source_book: Rifts World Book 13: Lone Star p.43-45
category: rcc
tags: [combat, hunter]
xp_table: [0, 2151, 4301, 9601, 18201, 28401, 38601, 54801, 75201, 100401, 132601, 185801, 240201, 295401, 365601]
attribute_requirements: { IQ: 5, PS: 20 }
attribute_dice:
  IQ: "2d6+3"
  ME: "3d6+6"
  MA: "2d6"
  PS: "4d6+12"
  PP: "3d6+6"
  PE: "4d6+4"
  PB: "3d6"
  Spd: "3d6+12"
hit_points_base: "P.E. x2 + 1d6 per level"
ppe_base: "2d6"
starting_money: "600"
psionics:
  type: "master"
  isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience"
  powers: ["Sense Evil", "Sense Magic", "Sixth Sense", "Empathy"]
  powers_starting: 1
  categories_allowed: ["Sensitive"]
bonuses:
  pools: { sdc: 44 }
  combat: { initiative: 5, strike: 2 }
  saves: { disease: 5, toxins_poisons: 5, harmful_drugs: 3, possession: 2, horror_factor: 10, psionics: 1, mind_control: 1 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 85, per_level: 0, note: "Speaks American at 85% efficiency." }
    - { name: "Language: Spanish", base: 85, per_level: 0, note: "Speaks Spanish at 85% efficiency." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "Track Humanoids, by sight and skill (+15%)." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "Track Animals, by sight and skill (+10%)." }
    - { name: "Escape Artist", base: 35, per_level: 5, note: "+5%" }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes"], bonus: 5, note: "Pilot Motorcycle/Hovercycle (+5%); the book prints the two as one line." }
    - { name: "Climbing", base: 40, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. Knife or Sword (vibro-blades)." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "Hand to Hand: Martial Arts or Assassin (pick one)." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Domestic", bonus: -5 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Automobile", "Bicycling", "Motorcycles & Snowmobiles", "Truck", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Jet Packs"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 5 }
      - { name: "Rogue", only: ["Streetwise"], bonus: 10 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "The book calls these other skills. Domestic: any (-5% penalty). Espionage +5%. Military +10%. Physical: any except Acrobatics. Pilot: any simple ground vehicle and jet pack. Rogue: any except Hacking, +5%, and Streetwise is +10%. Science: Basic Math only (-10% penalty). Technical: any except Computer Operation and Computer Programming. Wilderness +10%. Electrical, Mechanical, Medical and Pilot Related: none. Mutant canines in Coalition service are never taught to read, not even officers."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Automobile", "Bicycling", "Motorcycles & Snowmobiles", "Truck", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Jet Packs"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Mathematics: Basic"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { choose: 1, label: "armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "dpm-d1-heavy-dog-boy-armor", "dpm-d2-light-dog-boy-armor"], note: "Kill Hounds usually get heavy DPM armor or full environmental armor; the helmet is often taken off so the Hound can bite." }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { choose: 1, label: "tinted goggles or non-environmental helmet", qty: 1, from: ["tinted-goggles", "helmet"], note: "The helmet comes with or without a visor." }
  - { item_id: "pocket-digital-disc-recorder", qty: 1, note: "PDD pocket audio recorder." }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1, note: "Cigarette lighter." }
  - { item_id: "lightweight-rope", qty: 5, note: "100 ft (30.5 m) of lightweight rope; the catalog row is a 20 ft length." }
  - { item_id: "small-hammer", qty: 1 }
  - { item_id: "spike", qty: 4 }
  - { item_id: "animal-snare", qty: "1d6" }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "pair of vibro-knives or vibro-claws", qty: 2, from: ["vibro-knife", "vibro-claws"], note: "Many also carry a vibro-saber or neural mace." }
  - { item_id: "c-18-laser-pistol", qty: 1 }
  - { choose: 1, label: "assault rifle", qty: 1, from: ["c-14-fire-breather-rifle", "cp-40-pulse-laser-rifle"], note: "C-14 Fire Breather or CP-40 laser rifle, either with telescopic sight and nightvision scope." }
  - { item_id: "e-clip", qty: 4, note: "Four additional E-clips for the weapon." }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Cybernetic implant every Kill Hound has." }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Cybernetic implant every Kill Hound has." }
natural_abilities:
  - { name: "Size and Life Span", description: "6 to 7 feet (1.8 to 2.1 m) tall, around 200 lbs (90 kg). 90% are male. Bipedal with full human legs and a long tail; partial to full human speech. Estimated life span 6-15 years; 97% are slain in combat. Digging speed 2D4 (the Spd stored is the 3D6+12 running speed)." }
  - { name: "Bite, Punch and Kick", description: "Bite 3D6+6 S.D.C./hit points. Punch and kick 2D6 S.D.C./H.P. plus P.S. bonuses." }
  - { name: "Leap", description: "15 feet (3.6 m) high or lengthwise from a standing start; 30 feet (9 m) high or long with a running start." }
  - { name: "Natural Hunter and Killer", description: "An instinctive, relentless and savage hunter that loves to give chase, intimidate, fight and kill, and does not rest until the quarry is caught." }
  - { name: "Limited Olfactory Sense", description: "All scent and scent tracking abilities are HALF those of the Dog Boy; Kill Hounds lean on sight and tracking skills as much as scent. The Dog Boy''s figures, before halving: common and strong scents 70% +3% per level, range 100 feet (30.5 m) per level; identify specific odors 54% +2% per level, range 25 feet (7.6 m) per level; track by smell alone 40% +4% per level, rolled every 1000 feet (305 m), with half the usual penalties to strike, parry and dodge when blinded or in darkness. A scent trail can be up to four days old; cannot track through water, nor smell astral beings, ghosts or energy beings." }
  - { name: "Sense Psychic and Magic Energy", description: "Constant and automatic. Detects psychics (I.S.P.) and magic energy (P.P.E. used as a spell, in magic devices, or 80 or more points in a person), and can trace energy expended for longer than a melee round to its source. Base skill 40% +5% per level, rolled once every melee round; halved when several sources are scattered through the range. Range: 50 feet (15.2 m) +5 feet (1.5 m) per additional level to a psychic or mage NOT using powers; 400 feet (121 m) +50 feet (15 m) per level to powers in use. Roll every 1000 feet (305 m) to stay on the trail. No I.S.P. cost." }
  - { name: "Recognize Psychic Scent", description: "Recognizes the psychic signature of a kind of creature, or of an individual known well. Base skill 10% +4% per additional level for the scent of general races; 8% +2% per additional level for a specific individual, +10% with a bit of hair, skin, blood or clothing worn in the last 4 hours, and +10% to follow the trail of somebody known well. Range 50 feet (15 m) +5 feet (1.5 m) per level. Automatic and constant; no I.S.P. cost." }
  - { name: "Sense Supernatural Beings", description: "As Sense Psychic and Magic Energy but far more sensitive. Base skill 62% +2% per level to identify the specific type of paranormal creature (alien intelligences, gods, demigods, demons, vampires, dragons) and to tell whether a person is possessed. Tracking by this scent: 35% +5% per level, or 70% +3% per level if the being is also using psionics or magic. Range 100 feet (30.5 m) per level to a being not using its powers; 1000 feet (305 m) +100 feet (30.5 m) per additional level when powers or magic are in use. Automatic and constant; no I.S.P. cost." }
  - { name: "Keen Hearing and Good Sight", description: "Hears sounds up to 35,000 vibrations per second (humans 20,000) and can swivel the ears and filter out background noise to focus on one sound. Field of vision 200 degrees in short-nosed breeds, 270 in long-nosed ones (humans 100); colors are a little dulled. No better than a human in the dark. Only a fair to good sense of taste." }
  - { name: "Sensitivity to Ley Line Energy", description: "On a ley line or near a nexus the psychic and supernatural sensing abilities are impaired or blotted out; physical senses are unaffected and the other Sensitive powers are enhanced as usual. Ley line storms cause headaches, crackling in the ears and static shocks, and the Hound is twice as likely to be struck by ley line energy and lightning." }
  - { name: "Psionics and I.S.P.", description: "Considered a master psionic: saves vs psionic attack on a 10 or higher, with +1 to save vs psionic attack and all forms of mind control. Automatically has Sense Evil, Sense Magic, Sixth Sense and Empathy (receiver only, not transmission), plus one more Sensitive power of choice. I.S.P.: M.E. plus 1D6x10, +10 per additional level. Recovers 2 I.S.P. per hour of activity or 12 per hour of meditation or sleep." }
special_abilities:
  - name: "Supernatural Endurance"
    description: "Lifts and carries 100 times the P.S. attribute number, rarely fatigues (active for six hours without tiring), and is +3 to save vs poison, drugs and disease (already counted in the save bonuses)."
  - name: "Berserker Rage"
    description: "A blind rage that comes only when the Hound faces a hated enemy, is provoked beyond reason, or as an intense fear response. It is oblivious to friend, foe, orders and danger, attacks anyone who tries to pull it away, and stops only when its opponent is slain or it is slain or knocked unconscious. While enraged: one additional melee attack per round and +6 to damage."
  - name: "Cybernetics"
    description: "Every Kill Hound has a clock calendar, gyro-compass and toxic filter. Pick ONE more from: razor fingernails (each nail adds one point of S.D.C. damage), a finger gun or explosive finger segments (one artificial finger, three explosive joints, typically the left pinky), bionic lung, built-in language translator, or built-in radio receiver and transmitter (jaw and ear implant). Prosthetic limbs (usually mechanical) and medical implants are also available; artificial arms and hands carry 1-3 built-in weapons. Experimental personality modifier brain implants may be used on some test subjects."
side_effects: "Ignore Pain: fights on through pain, injury and blood loss with no noticeable penalties until it collapses at one hit point. Sloth: uninterested in anything that is not intimidation, rough-housing, sport, a challenge, fighting, hunting or killing; mundane work is skipped or done sloppily, and the details of an assignment (rations, water, spare ammunition, complex instructions) are forgotten. Extreme Aggression: fights, not necessarily to kill, over the slightest insult unless the offender backs down and apologizes, and finds it hard to resist any challenge however dangerous. Bloodlust: in a fighting frenzy (anger, frustration, fear, or success in battle) the Hound forgets all orders and wants only to kill; it may take a gunshot, explosion, psionic message or bolt of magic to get its attention and one or more people to pull it off its target, though it still tells friend from foe and reacts to things close by. Rage Syndrome (roll percentile at creation; 01-20 has it): sudden irrational bouts of rage, forewarned by glazed eyes and a dull expression, with the attack 1D4 minutes later lasting 2D4 minutes in a peaceful setting or 4D4 minutes in combat; one additional melee attack and +6 to damage during it, then all combat bonuses halved and attacks per melee reduced by one for 1D6x10 minutes; the character is also more easily inclined to Berserker Rage and often does not remember the fight. Jekyll and Hyde Syndrome (roll percentile at creation; 01-33 has it): dramatic mood swings from pleasant and fun to surly, mean, bossy and looking for a fight, set off by a comment, joke, bump, insult or challenge, and the usual disposition when tired, sick, injured or imprisoned."
restrictions:
  - "R.C.C. Requirements: I.Q. 5 or higher, P.S. 20 or higher, plus an enjoyment of fighting, hunting and killing. Common breeds: Mastiff, Rottweiler, Wolfhound, Elkhound, Rhodesian Ridgeback, Akita, Bouvier des Flandres, wolves and mixes of these, sometimes with terriers."
  - "A player character who is not a CS agent must be a feral renegade (runaway or deserter) or the Free Born offspring of runaway mutants."
  - "Alignment: any. Most lean unprincipled (20%), anarchist (22%) or aberrant (20%); miscreant 20%, diabolic 13%, other 5%."
  - "Magic: none."
  - "Mutant canines in Coalition service are never taught to read, not even officers."
  - "Never assigned to ISS duty, except for special seek and destroy missions in the Burbs."
extraction_notes: "WB13 Lone Star printed 43-45 (cache p044-p046, cache page = printed folio + 1); the introduction starts at the foot of 43, the stat block is on 44, skills, equipment and cybernetics on 45, and the entry ends where Dog Boy Equipment begins on 46. Numbers read off renders. The entry points to the Dog Boy R.C.C. (printed 32-36) for special powers, psionics, equipment and money; those are restated here so the class stands alone and pairs with no race. || HEADING: the entry is a mutant-animal R.C.C. under the Dog Pack / Canine Special Forces section, a race, so men_of_arms: false. || XP: the ladder headed Dog Boy: Kill Hound, Feline: Kill Cat on the unnumbered Experience Tables page after printed 174 (cache p176). || ATTRIBUTES as printed: I.Q. 2D6+3, M.E. 3D6+6, M.A. 2D6, P.S. 4D6+12, P.P. 3D6+6, P.E. 4D6+4, P.B. 3D6, Spd 3D6+12 running, 2D4 digging (text). The book says to use these attributes, special bonuses and stats in place of the Dog Boy''s, so the Dog Boy''s +1D4 P.E., +1D4 P.S. and +2D6 Spd are NOT added. Requirements I.Q. 5 and P.S. 20 stored as attribute_requirements and as a restriction line. || POOLS: hit points P.E. x2 plus 1D6 per level. S.D.C. 44 plus those gained from physical skills: the wording of a racial pool that adds, so bonuses.pools.sdc 44 and no sdc_base. P.P.E. 2D6. || BONUSES: Kill Hound Bonuses replace the Dog Boy Physical Bonuses (#6): +5 initiative, +2 strike, +2 save vs disease and poison (2 each toward disease and toxins_poisons), +2 vs possession, +10 vs horror factor. The Dog Boy Psi-Bonuses (#5) are not replaced: +1 vs psionic attack and all forms of mind control (psionics 1, mind_control 1). Supernatural endurance prints a further +3 vs poison, drugs and disease as its own line; added to the same save rows, so disease 5, toxins_poisons 5 and harmful_drugs 3 (judgement: the book prints both lines and does not say one includes the other). Berserker Rage and Rage Syndrome +1 attack and +6 damage are conditional and prose. || PSIONICS (Dog Boy printed 33, #4 and #5): master psionic, I.S.P. M.E. plus 1D6x10 and +10 per additional level; Sense Evil, Sense Magic, Sixth Sense and Empathy (receiver only) plus one Sensitive power of choice. || NATURAL ABILITIES: fundamentally the Dog Boy''s, restated from printed 33-35, with the Kill Hound''s exceptions: scent abilities halved (the Dog Boy figures are stored with the halving stated; the book does not say whether the psychic-scent abilities #1-#3 are also halved, and they are stored unhalved - judgement, the line speaks of olfactory senses), bite 3D6+6, punch and kick 2D6 plus P.S. bonuses, leap, supernatural endurance (replaces the Dog Boy''s 20x/40x carry and two-hour stamina). The leap prints 15 feet as 3.6 m; stored as printed. Recognize Psychic Scent prints ''10% 44%'' in the text layer and on the page; read as 10% +4%. || SKILLS: American and Spanish at 85%: Language: Native Tongue 85 and Language: Spanish 85, per_level 0. Radio: Basic 45+10 = 55. Track Humanoids is Tracking (people) 25+15 = 40. Track Animals is Track & Trap Animals 20+10 = 30. Escape Artist 30+5 = 35. Pilot Motorcycle/Hovercycle (+5%) is one printed line; stored as a choice of one of the two catalog skills at +5 (judgement). Climbing 40, no bonus printed. Running, Boxing. Land Navigation 36+10 = 46. Wilderness Survival 30+20 = 50. W.P. Energy Pistol, W.P. Energy Rifle, W.P. Knife or Sword as a choice of one, two W.P. of choice. Hand to Hand: Martial Arts or Assassin, pick one, as a choice; the Kill Hound entry prints no price for any other style, so no hand_to_hand block. || RELATED: four, plus one at levels 4, 8 and 12. Domestic -5% and Science (Basic Math only) -10% stored as negative bonuses; Espionage +5, Military +10, Wilderness +10, Rogue +5 with Hacking excluded - Streetwise is +10% in the book (printed 45, read off a render), stored as a second, scoped Rogue entry (BOOK-INGEST-AUDIT.md F138). Pilot ''any simple ground vehicle and jet pack'' stored as Automobile, Bicycling, Motorcycles & Snowmobiles, Truck, Hover Craft (ground), Hovercycles and Jet Packs (judgement; tanks, tracked and construction vehicles, robots, boats and aircraft left out). Electrical, Mechanical, Medical, Pilot Related: none. Secondary: four, plus one at levels 3, 6, 9 and 12, same list without bonuses or penalties. The never-taught-to-read note is a restriction line; literacy skills are not excluded from Technical. || EQUIPMENT: basically the Dog Boy''s (printed 36). Armor: Kill Hounds usually get heavy DPM armor or full environmental armor, stored as a choice of the Dog Pack riot armor or the D1 heavy or D2 light environmental suits. 100 ft of lightweight rope as five 20 ft lengths. A pair of vibro-knives or vibro-claws as a choice at qty 2. C-14 Fire Breather or CP-40 with telescopic sight and nightvision scope. Of the three implants every Kill Hound has, the clock calendar and gyro-compass are equipment rows and the toxic filter, which no catalog row describes, is named in the Cybernetics ability; the pick-one implant list is in the Cybernetics ability text. Equipment Available Upon Assignment (grenades, flares, explosives, heavy weapons, optics, cameras, light vehicle, rations, non-regulation gear) is not starting equipment and is not stored. || MONEY: same as the Dog Boy: a monthly salary of 200-300 credits (700 for officers) and player characters start with two months pay, so 400-600 credits; stored as 600, the figure the dog-boy class in production carries for the same sentence. || Identification coding (bar-code tattoo and I.C. chip with a one mile tracking range), typical missions and the pack pecking order are lore."
---

## Lore

Kill Hounds are the Lone Star labs'' answer to a blunt question: what if a Dog
Boy were built only to fight? Introduced in 104 P.A. with the coming siege of
Tolkeen in mind, they are bred from the largest and hardest breeds - mastiffs,
Rottweilers, wolfhounds, wolves - into towering, barrel-chested soldiers who
keep the predatory edge that the Coalition trains out of its other canines.

Where an ordinary Dog Boy is courteous and eager to please, a Kill Hound is
cocky, pushy and happiest when turned loose on a hunt. They work as shock
troops, wilderness hunter-killers, raiders and occasionally guards, and they
proved themselves against Juicers during the Juicer Uprising. In a pack they
sort themselves into a pecking order under an alpha, and the bigger the pack
the bolder and crueler it gets.

They still honor their human officers, though with stares, growls and slow
feet when an order bores them. Their noses are duller than a Dog Boy''s, so
they track by eye and by craft as much as by scent, and they keep the psychic
senses that make every mutant canine a hunter of magic and the supernatural.

## GM Notes

A Kill Hound is a strong combatant with real costs: it ignores wounds until it
drops, forgets the dull parts of a mission, rises to any challenge, and can
lose itself in bloodlust or a berserker rage. Roll percentile at creation for
Rage Syndrome (01-20) and for Jekyll and Hyde Syndrome (01-33).

Typical assignments are seek and destroy, commando raids and rescues, tracking,
assassination and sabotage, anti-magic and anti-supernatural sweeps, and purges
of D-Bee settlements; escort, guard and infantry duty are occasional. They are
kept off city police duty apart from the odd violent sweep of the Burbs.
',
       updated_at = datetime('now')
 WHERE class_id = 'kill-hound'
   AND instr(markdown, 'add 5 more by hand') > 0
   AND length(markdown) = 22523;

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
      - { name: "Technical", only_prefix: ["Language:", "Literacy:"], bonus: 15 }
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
   AND instr(markdown, 'Computer Hacking is +10%, add it by hand') > 0
   AND length(markdown) = 13585;

-- == psi-ghost ==
UPDATE imported_classes
   SET markdown = '---
id: psi-ghost
men_of_arms: false
occ_group: psychic
name: Psi-Ghost
system: rifts
source_book: Rifts World Book 12: Psyscape p.63-66
category: occ
tags: [stealth, tech]
xp_table: [0, 2061, 4161, 8521, 16901, 25601, 35901, 50501, 70901, 95501, 130901, 190501, 240901, 290501, 350901]
attribute_requirements: { PP: 12 }
ppe_base: "3d4+4"
starting_money: "2d6x1000"
bonuses:
  attributes: { MA: "1d4", PP: "1d4" }
  pools: { sdc: "1d6" }
  combat: { initiative: 2, pull_punch: 1, roll: 2 }
  saves: { mind_control: "1d4", possession: 4, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "1d6x10 + M.E. attribute number, +2d6 I.S.P. for each additional level of experience"
  powers:
    - "Psionic Invisibility"
    - "Deaden Senses"
    - "Mind Block"
    - "Nightvision"
    - "Object Read (Psychometry)"
    - "Machine Ghost"
    - "Telemechanics"
  powers_starting: 5
  categories_allowed: ["Physical", "Sensitive", "Super"]
  powers_starting_groups:
    - { count: 5, categories: ["Physical", "Sensitive"] }
  powers_schedule:
    - { level: 2, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 3, count: 1, categories: ["Super"] }
    - { level: 4, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 5, count: 1, categories: ["Super"] }
    - { level: 6, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 7, count: 1, categories: ["Super"] }
    - { level: 8, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 9, count: 1, categories: ["Super"] }
    - { level: 10, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 12, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 12, count: 1, categories: ["Super"] }
    - { level: 14, count: 1, categories: ["Physical", "Sensitive"] }
    - { level: 15, count: 1, categories: ["Super"] }
special_abilities:
  - name: "Heightened Presence Sense"
    description: "Constant, automatic sixth sense (no I.S.P., no save) that makes the Psi-Ghost aware of every intelligent presence within 25 ft (7.6 m) +5 ft (1.5 m) per level. No roll is needed to sense presences; pinpointing their number and exact location needs 1D4 melee rounds of full concentration and a skill roll of 60% +2% per level. Also gives a warning ''jitters'' when a surveillance camera or system manned by a sentient operator is watching him, and the operator can be located the same way if within range."
  - name: "Intangibility (Mutant Power)"
    description: "Not a psionic power; costs no I.S.P. The Psi-Ghost and up to 20 lbs (9 kg) of carried material turn intangible or back nearly at the speed of thought, at most four times per melee. While intangible: conventional attacks, falls and explosions pass through harmlessly; electricity does half damage; psionic attacks and gases do full damage/effect. He cannot touch, carry, fight or operate machines, can speak and hear, walks through solid matter (and on smoke or water, or sunk into the ground up to the nose) but cannot fly, float or walk on air. No partial materialization - becoming solid while inside an object means instant death. Appears semi-transparent: Horror Factor 14, and +20% to Prowl while intangible."
restrictions:
  - "No cybernetics at start; tends to avoid implants in favour of natural powers."
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { choose: 1, from: ["Literacy: Native Language", "Literacy: Other"], bonus: 10, note: "Literacy: one of choice (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Languages: two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)" }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Surveillance", base: 45, per_level: 5, note: "Printed as Surveillance Systems (+15%)" }
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
    - { name: "Basic Mechanics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Computer Operation", base: 55, per_level: 5, note: "Printed as Computer Operations (+15%)" }
    - { name: "Computer Hacking", base: 25, per_level: 5, note: "+10%" }
    - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%" }
    - { name: "Pick Locks", base: 45, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 32, per_level: 4, note: "+12%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%; a further +20% while intangible (not added here)" }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one R.C.C. Related Skill, or Martial Arts for two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - { name: "Espionage", bonus: 10 }
      - "Mechanical"
      - { name: "Mechanical", only: ["Locksmith"], bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Brewing"] }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", except: ["Boxing"] }
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 6 }
      - { name: "Science", only: ["Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
    note: "Cowboy: None. Wilderness: None. Mechanical: Any, +10% to Locksmith only."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "clothing", qty: "3d4" }
  - { item_id: "knife", qty: 1 }
  - { item_id: "vibro-knife", qty: 1 }
  - { choose: 1, label: "energy handgun of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "35mm-camera", qty: 1 }
  - { item_id: "video-camera-digital-mini", qty: 1 }
  - { item_id: "blank-disc", qty: 24 }
  - { item_id: "pen-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "spike", qty: "1d4+1" }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "lock-picking-tools", qty: 1 }
  - { item_id: "laser-scalpel", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
extraction_notes: |
  - The book names this an R.C.C. (a hereditary human mutation); per the Psyscape batch convention it is stored as category occ, occ_group psychic, modelled on mind-melter. men_of_arms false: it sits in the book''s psychic R.C.C. section (printed 63), not a Men of Arms heading.
  - xp_table taken from the batch brief (read off the printed 157 table).
  - Psionics (printed 65, item 3): seven automatic powers; the book''s "Object Read" is the catalog row Object Read (Psychometry). Five picks from Sensitive and/or Physical at level one; one Physical/Sensitive pick at levels 2, 4, 6, 8, 10, 12, 14 and one Super pick at 3, 5, 7, 9, 12, 15 - transcribed as printed, including the Super ladder skipping 11 and 13 and landing on 12 and 15. Master Psychic: saves vs psionics on 10 or higher (implied by type master, not stored as a bonus).
  - I.S.P. (printed 65, item 4): cache reads "!D6xlO" and "2D61.S.P."; the render shows 1D6x10 + M.E. and 2D6 I.S.P. per level. "Per level of experience" is stored as each additional level, as the mind-melter does.
  - R.C.C. bonuses (printed 65-66, item 6) stored as dice: +1D6 S.D.C. (pools.sdc), +1D4 M.A., +1D4 P.P., +1D4 save vs mind control; the rest flat.
  - Heightened Presence Sense and Intangibility (printed 64-65) stored as special_abilities; the +20% Prowl and Horror Factor 14 apply only while intangible, so they are not in bonuses. Intangibility is a mutant (non-psionic) power: the book says only born Psi-Ghosts have it, together with the enhanced presence sense and the Psi-Ghost I.S.P.; an adopted Major/Master Psychic trained as a Psi-Ghost lacks all three. Not modelled; see GM Notes.
  - Skills: the book lists no native language; two "Languages" of choice are stored as Language: Other (+20%) as mind-melter does, and "Literacy: one of choice" as a choice of the two catalog literacy rows (+10%). Surveillance Systems is catalog Surveillance; Computer Operations is Computer Operation; Basic Math is Mathematics: Basic. Bases are catalog base + printed bonus.
  - Related skills: Mechanical "+10% to Locksmith skill only" (printed 65, read off a render) is a second, scoped Mechanical entry (BOOK-INGEST-AUDIT.md F138). Cowboy and Wilderness are None.
  - Hand to Hand: Expert for one related skill, Martial Arts for two; no Assassin option is printed.
  - Attribute requirement P.P. 12; a high M.E. is suggested only. Alignment: any, most anarchist or unprincipled. Gender split roughly 43% male / 57% female; fewer than 5,000 in the Americas (90% North America, 3% Mexico, 3% South America, 4% elsewhere).
  - Equipment (printed 66): body armor is the catalog''s personalized light-or-medium row (book says usually light). "Black fatigues or jump suit" -> fatigues. 3D4 outfits -> clothing. Vibro-blade -> vibro-knife. Energy handgun choice uses the generic pistol rows mind-melter offers, plus 4 E-clips. FDD/Portable Digital Disk player with headphones -> PDD pocket recorder/player. 35 mm still camera and disc (moving picture) camera each "with a dozen discs of film" -> 35mm-camera, video-camera-digital-mini and 24 blank discs. 100 ft super-strong lightweight cord -> lightweight-cord. Standard tool kit -> tool-kit.
  - Equipment NOT stored (no catalog row found): full-size computer and printer at home, microfilm camera, roll of wire, pry bar, glass cutter, carrying case or satchel (knapsack and backpack are stored), personal items, 1D4+1 alias photo I.D. cards, fake birth certificate, fake citizen I.D. to one CS or other major kingdom. No vehicle to start.
  - NPC-only extras (printed 66): 1D4 safe-house apartments rented six months ahead under an alias, and underworld connections. Not stored.
  - Money (printed 66): 2D6x1000 credits stored; the additional 2D4x1000 credits in Black Market items cannot be held by starting_money and is recorded here. Young Psi-Ghosts charge 800-1,500 credits a week or per job; veterans charge double a typical spy''s rate.
  - Cybernetics: starts with none, avoids implants (stored as a restriction line).
---

## Lore

Psi-Ghosts are Master Psychics who make their living as elite thieves, spies and infiltrators, prized because few security systems can keep them out. Nearly all are human mutants descended from a single Magic Zone village where, generations before the Post-Apocalyptic calendar began, residents began to show both strong psionics and the hereditary ability to turn intangible. Their early attempt at a criminal cartel was crushed by rivals, so today they live scattered in clans and as loners, bound by an unwritten code never to betray a fellow Ghost to outsiders even while feuding among themselves. They favour big cities and high-tech ''Burbs, sell their talents to criminals, corporations and governments alike, and are known for keeping their word to an employer and taking secrets to the grave.

## GM Notes

**Born, not trained.** Intangibility, the Heightened Presence Sense and the Psi-Ghost''s own I.S.P. formula belong only to the mutant bloodline. The book allows the Ghosts to occasionally adopt another Major or Master Psychic and train him as a Psi-Ghost; such a character gets the skills and chosen psionics but none of those three traits. The creator does not model the adopted variant.

**Heredity.** The trait passes to every child of two Psi-Ghost parents and to half the children of a mixed couple; a child with a Psi-Stalker is always a Psi-Stalker with no intangibility.

**Intangibility in play.** Switching state is nearly instant but limited to four changes per melee. An intangible Ghost cannot attack - he must become solid first - and anything he carries (up to 20 lbs) stays intangible until he does. Gas attacks are especially dangerous to him while intangible.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-ghost'
   AND instr(markdown, 'add it by hand if Locksmith is taken') > 0
   AND length(markdown) = 13053;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'grey-seer' AND instr(markdown, 'only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 15 }') > 0)
    OR (class_id = 'pirate' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'sailor' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'idie-fisherman' AND instr(markdown, '{ name: "Technical", only_prefix: ["Language:"], bonus: 10') > 0)
    OR (class_id = 'kill-hound' AND instr(markdown, '{ name: "Rogue", only: ["Streetwise"], bonus: 10 }') > 0)
    OR (class_id = 'monkey-boy-tech' AND instr(markdown, '{ name: "Rogue", only: ["Computer Hacking"], bonus: 10 }') > 0)
    OR (class_id = 'psi-ghost' AND instr(markdown, '{ name: "Mechanical", only: ["Locksmith"], bonus: 10 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'grey-seer' AND instr(markdown, 'add the 15% to those picks by hand') > 0)
    OR (class_id = 'pirate' AND instr(markdown, 'add it by hand to a Lore or Language pick') > 0)
    OR (class_id = 'sailor' AND instr(markdown, 'add it by hand to those picks') > 0)
    OR (class_id = 'idie-fisherman' AND instr(markdown, 'the +10% is on Language only - add it by hand') > 0)
    OR (class_id = 'kill-hound' AND instr(markdown, 'add 5 more by hand') > 0)
    OR (class_id = 'monkey-boy-tech' AND instr(markdown, 'Computer Hacking is +10%, add it by hand') > 0)
    OR (class_id = 'psi-ghost' AND instr(markdown, 'add it by hand if Locksmith is taken') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('grey-seer', 'pirate', 'sailor', 'idie-fisherman', 'kill-hound', 'monkey-boy-tech', 'psi-ghost') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~194-book-ingest-audit-f138-nine-more.sql');
