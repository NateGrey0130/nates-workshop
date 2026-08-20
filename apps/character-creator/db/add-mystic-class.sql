-- The Mystic O.C.C., Rifts Ultimate Edition p.118-120.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-silver-cross', 'Small Silver Cross', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'mystic', 'Mystic', 'rifts', '---
id: mystic
name: Mystic
system: rifts
source_book: Rifts Ultimate Edition p.118-120
category: occ
attribute_requirements: { IQ: 9, ME: 9, MA: 9 }
ppe_base: "1d6x10+20, +2d6 per additional level starting at level two"
starting_money: "2d4x1000"
psionics:
  type: "major"
  isp_base: "1d4x10+10"
  powers: ["Clairvoyance", "Commune with Spirit", "Exorcism", "Sixth Sense", "Suppress Fear"]
  powers_starting: 5
  categories_allowed: ["Sensitive", "Healing"]
magic:
  type: "spell"
  spells_starting: 8
  spell_levels_allowed: [1, 2]
bonuses:
  saves: { horror_factor: 4, possession: 2, spell_magic: 1, ritual_magic: 1 }
  at_level:
    - { level: 2, saves: { psionics: 1, mind_control: 1, possession: 1 } }
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 4, saves: { psionics: 1, mind_control: 1, possession: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 8, saves: { psionics: 1, mind_control: 1, possession: 1 } }
    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1, psionics: 1, mind_control: 1, possession: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 97, per_level: 1, note: "At 97%." }
    - { choose: 3, categories: ["Communications"], bonus: 15, note: "Language: Other, three of choice (+15%)." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%; 50%/30% ride/care." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+15%" }
    - { choose: 3, categories: ["Technical"], bonus: 15, note: "Lore: three of choice (+15%); the catalog files lore skills under Technical." }
    - { name: "Philosophy", base: 50, per_level: 5, note: "+20%" }
    - { choose: 2, categories: ["Domestic"], bonus: 10, note: "Play Musical Instrument: two of choice (+10%); the catalog holds one Play Musical Instrument row - pick it plus Sing or another Domestic performance skill." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", except: ["Laser Communications", "Optic Systems", "Read Sensory Equipment", "Surveillance Systems", "T.V./Video"] }
      - "Domestic"
      - { name: "Espionage", only: ["Escape Artist", "Disguise"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Wrestling"] }
      - { name: "Pilot", except: ["Airplane", "Jet Aircraft", "Helicopter", "Jet Fighters", "Tanks and APCs", "Warships", "Robots and Power Armor", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Jet Fighters"] }
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking", "Gambling (Dirty Tricks)", "Safe-Cracking"] }
      - "Science"
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Cybernetics: Basic", "Jury-Rig", "Mining"] }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy", "W.P. Heavy Energy Weapons", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"] }
      - "Wilderness"
    note: "Communications +5%, Domestic +10%, Espionage +5%, Medical: Brewing +10%/First Aid +15%/Holistic Medicine +10% (Holistic counts as two choices), Rogue +5%, Technical +5%, Wilderness +5%. Cowboy, Electrical, Mechanical and Military: none. Hand to Hand combat is taken HERE, not automatically: Basic costs one selection, Expert two, Martial Arts three, Assassin (if Anarchist or evil) four."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "wooden-stake-and-mallet", qty: 6 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "musical-instrument", qty: 1 }
  - { item_id: "hooded-cloak", qty: 2 }
natural_abilities:
  - name: "Sense Supernatural Evil"
    description: "Automatic, no I.S.P. cost: feels supernatural evil like an icy chill within a 300 foot (91.5 m) radius, +20 feet per level starting at level two. General sensation only; pinpointing needs the Sense Evil psi-power. Also senses possession and recognizes magic enchantment. Base Ability: 50% +5% per level."
  - name: "Opening Oneself to the Supernatural"
    description: "Can become a medium (1D6+1 minutes, cannot think or speak on his own); receptive to telepathic and empathic communication, +10% to receive a Ley Line Transmission when open. An open state trance renders him motionless and invisible to psionic probes and even physically hard to see: 50% +5% per level to go unseen; +8 to save vs psionic attack and possession, +4 vs magic, +3 Perception involving the supernatural while in trance, but loses initiative and one attack per melee while sensing. In the open state can identify the type and approximate location of supernatural evil in a 600 foot radius +100 feet per level."
  - name: "Psionics of the Mystic"
    description: "Major psychic (needs 12+ to save vs psionics). Starts with Clairvoyance, Commune with Spirits, Exorcism, Sixth Sense and Suppress Fear, PLUS three additional Sensitive and two Healer powers of choice. At levels four and eight, select one additional power from the SUPER category. I.S.P.: 1D4x10+10 plus M.E., +1D6+1 per level."
  - name: "Intuitive Magic"
    description: "Spell knowledge comes from within: at first level, eight spells from levels 1-2 (selected once, during six days of meditation). At second level, four new spells from levels 1-3; at third, three from levels 1-4; at fourth and each level after, two spells from any level up to his experience level. The Mystic CANNOT be taught spells nor purchase spell knowledge - he never even tries. May use Techno-Wizard devices and, if literate, the occasional magic scroll."
  - name: "P.P.E. and Recovery"
    description: "Permanent Base P.P.E.: 1D6x10+20 plus P.E.; +2D6 per level. Draws from ley lines (10 per melee round) and nexus points (20 per melee round). Recovery: 5 per hour of rest, 10 per hour of meditation."
restrictions:
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels 2, 4, 8 and 12; +1 on Perception Rolls at levels 1, 3, 6, 8, 10, 12 and 14, double when on a ley line."
  - "Cybernetics: starts with none and avoids all augmentation like the plague - Mystics believe technology deadens the gift."
extraction_notes: |
  - RUE p.118-120. Alignment any, tends toward good.
  - Hand to Hand is NOT an O.C.C. skill: it is bought as a Related Skill
    (Basic 1, Expert 2, Martial Arts 3, Assassin 4 selections) - the note on
    the related block carries it; the validator cannot price a skill at
    multiple selections.
  - The psionic split (three Sensitive + two Healer, Super at 4 and 8) is
    finer than powers_starting/categories_allowed can express; the picker
    allows 5 from Sensitive+Healing and the split is prose.
  - The magic learning schedule (4/3/2 new spells by level, never taught)
    has no schema; spells_starting 8 at levels 1-2 models level one.
  - Horsemanship: General prints 50%/30% +4%; the paired percentage sits in
    the note, the Medical Doctor precedent.
  - Money: 2D4x1000 credits + 2D6x1000 in Black Market items. Prefers a
    living animal mount; no vehicle to start.
---

## Lore

A Mystic wields both magic and psionics, powers that seem to be handed over by fate rather than serious study. They sense different aspects and happenings on the physical and metaphysical levels of life, often making them acclaimed advisors and prophets who can glimpse the future and the supernatural. The intuitive nature of the Mystic''s power means he simply accepts sudden flashes of insight and knowledge, trusting his feelings and hunches, never completely dismissing any possibility.

Most disregard formal education in favor of following their cosmic path - too much education, they believe, creates walls that block the psychic emanations. Most also believe too much reliance on technology deadens one to the true world, so a Mystic avoids cybernetics, bionics and all other augmentation, though he will use modern tools, energy weapons and body armor to some degree. Many Mystics are renowned philosophers.

Most Mystics claim a person is never really taught to be a Mystic, but is born with the gift - those who come seeking tutelage are already chosen by fate and just need to figure out how to tap and unleash their inner power. A Mystic''s abilities are a combination psychic and magic: psychic powers limited to the Sensitive and Healing categories, magic limited to the more simple and sensory oriented spells.

## GM Notes

Related O.C.C.s: Rifts World Book 16: Federation of Magic has the Mystic Knight and Grey Seers, both specialized variations of the Mystic O.C.C.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'mystic');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'mystic';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('small-silver-cross');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-class.sql');
