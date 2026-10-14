-- Take BOOK-INGEST-AUDIT F138 for the sperm whale: Radio: Basic carries its printed -10%
-- 1 class, each replaced whole: sperm-whale.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~191-book-ingest-audit-f138-sperm-whale.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == sperm-whale ==
UPDATE imported_classes
   SET markdown = '---
id: sperm-whale
name: Sperm Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.88-90
category: rcc
tags: [aquatic]
xp_table: [0, 2051, 4101, 8251, 18501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+10"
  MA: "2d6+6"
  PS: "4d6+34"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "2d6"
  Spd: "2d6+16"
hit_points_base: "P.E. x10, +20 per level"
sdc_base: "3d6x10"
ppe_base: "P.E. + 4d4x10, +10 per level"
bonuses:
  combat: { attacks_base: 1, initiative: 1, strike: 3, dodge: 1, pull_punch: 1, roll: 3 }
  saves: { horror_factor: 8, toxins_poisons: 4, disease: 4, mind_control: 1 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
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
    - { count: 3, from_list: "spellsongs" }
  spells_schedule:
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 45, per_level: 5, note: "+10%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Undersea & Sea Survival", base: 45, per_level: 5, note: "Printed as Undersea Survival (+20%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "One human language of choice (+5%), probably American/English." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Sing"] }
      - { name: "Communications", only: ["Radio: Basic"], bonus: -10 }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Physical", only: ["Prowl"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", only: ["Streetwise"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only, so Communications is two entries: Sing with no bonus, and Radio: Basic at -10%. Pilot is barred except specially designed power armour. Its Rogue line is Streetwise and Prowl only; Prowl is a Physical row in this catalog and is granted through a Physical entry so it is actually takeable."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 7, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 35% scrupulous, 10% principled, 20% unprincipled, 25% anarchist and 10% other. This is the most anarchist of the four cetaceans by some way."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 2D4+6 - the toughest hide of the four."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. x10 for females and young and P.E. x20 for a full-grown male, +20 per level either way. S.D.C. is 3D6x10 for females and young, 6D6x10 for a full-grown male."
  - "Horror Factor: 13 when angry or attacking."
  - "Size: males average 60 to 70 feet (18.3 to 21.3 m), females 38 to 45 feet (11.5 to 13.7 m). Weight 50 to 70 tons for a full-sized adult, 15 to 30 for a female. The head is a third of the body and is always scarred from fighting squid."
  - "Average life span: 50 to 80 years, maturity at 11 to 16. There are an estimated 650,000 on Rifts Earth, not counting the pygmy and dwarf sperm whales."
  - "IT DIVES DEEPER THAN ANY OTHER CETACEAN - two miles (3.2 km) and deeper still on a dive, at five times its normal speed going down."
  - "Spell strength is +1 at levels four, eight and twelve. It is +4 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "IMPERVIOUS TO COLD - it takes no damage at all, where the dolphin, orca and humpback take half."
  - "NO AUTOMATIC DODGE. It parries with nose or tail at +1."
  - "Its diet is 80% squid, including giant squid, the rest octopus, fish, shrimp and crab."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-60): Minor Psionic", "Psionics (61-80): Major Psionic, Physical or Sensitive", "Psionics (81-90): Major Psionic, Healing, Physical or Sensitive", "Psionics (91-00): Master Psionic"], note: "Sperm Whale Psionics (printed 90): every Sperm whale has some psionic power. Roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-60): Minor Psionic"
    description: "Roll 01-60. A minor psionic limited to four powers: See Aura, See the Invisible, Sense Magic and Mind Block. Base I.S.P. is M.E. x2, plus 1D6 per level."
    psionics:
      type: "minor"
      isp_base: "M.E. x2, +1d6 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
  - name: "Psionics (61-80): Major Psionic, Physical or Sensitive"
    description: "Roll 61-80. A major psionic with See Aura, See the Invisible, Sense Magic and Mind Block, plus 1D4+1 powers of choice from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. Base I.S.P. is M.E. x3, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x3, +1d6+2 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (81-90): Major Psionic, Healing, Physical or Sensitive"
    description: "Roll 81-90. A major psionic with See Aura, See the Invisible, Sense Magic and Mind Block, plus 1D4+2 powers of choice from the Healing, Physical or Sensitive categories: roll the die and take that many of the six picks offered. Base I.S.P. is M.E. x4, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x4, +1d6+2 per level"
      powers: ["See Aura", "See The Invisible", "Sense Magic", "Mind Block"]
      powers_starting: 6
      powers_starting_groups:
        - { count: 6, categories: ["Healing", "Physical", "Sensitive"], note: "Roll 1D4+2 and take that many (up to six)." }
  - name: "Psionics (91-00): Master Psionic"
    description: "Roll 91-00. A master psionic: twelve powers from any of the three lesser categories at level one, and one more from any category, Super included, at each level after. Base I.S.P. is M.E. x8, plus 2D6 per level."
    psionics:
      type: "master"
      isp_base: "M.E. x8, +2d6 per level"
      powers_starting: 12
      powers_starting_groups:
        - { count: 12, categories: ["Healing", "Physical", "Sensitive"] }
      powers_schedule:
        - { level: 2, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 3, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 4, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 5, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 6, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 7, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 8, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 9, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 10, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 11, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 12, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 13, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 14, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
        - { level: 15, count: 1, categories: ["Healing", "Physical", "Sensitive", "Super"] }
natural_abilities:
  - name: "Sperm Whale Combat"
    description: "ONE attack per melee round at level one - the fewest of any class in this book - and one more at levels two, four, seven, ten and thirteen. Parries with nose or tail at +1. No automatic dodge."
  - name: "Deep Diving"
    description: "Swims two miles (3.2 km) deep and dives deeper, at five times normal speed on the way down. Of all the cetaceans only the sperm whale reaches the ocean floor."
  - name: "Impervious to Cold"
    description: "Cold does NO damage."
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
  - Underseas, printed 88-90. The deepest diver of the four and the only one
    that is impervious to cold rather than merely resistant.
  - ITS ROGUE LINE NAMES A SKILL THIS CATALOG FILES ELSEWHERE, and unlike the
    dolphin''s Pick Locks this one had to be rescued rather than dropped.
    Printed 89 gives Rogue: streetwise and prowl only. Streetwise is a Rogue
    row here; PROWL IS A PHYSICAL ROW, and this class''s Physical line is
    None - so naming Prowl in the Rogue `only` would leave it granted and
    unreachable. A Physical entry with `only: [Prowl]` is added so the book''s
    grant actually works. That is a deliberate departure from the printed
    Physical: None, and it is the smaller error: the alternative silently
    drops a skill the book gives.
  - ONE ATTACK PER MELEE AT LEVEL ONE is correct and is the lowest in this
    book. Checked against printed 89 rather than assumed to be an OCR drop.
  - HIT POINTS AND S.D.C. STORE THE FEMALE/YOUNG FIGURE, as on the other two
    whales. Both are in the restrictions.
  - ITS SPELLSONG LADDER IS IRREGULAR: three at level one, then one each at
    levels three, five, SIX, seven, eight, ten, twelve and fourteen. Note the
    five-six-seven-eight run in the middle, which is not a pattern - it is
    transcribed exactly as printed 90 gives it.
  - EVERY SPERM WHALE IS PSIONIC, AND THE DEGREE IS A PERCENTILE ROLL, printed
    90; it was not stored at all until 2026-10. The roll is a choose-1 special
    ability with four options named for their bands, each carrying the tier,
    I.S.P. formula and powers its row prints, so there is no class-level block.
    TWO ROWS ARE MAJOR PSIONICS and differ in I.S.P. (M.E. x3 against M.E. x4),
    in the count of chosen powers (1D4+1 against 1D4+2) and in whether Healing
    is open. Counts printed as dice are stored at the maximum with the roll in
    the pick''s note, the Demon and Dead Slaver precedent.
---

# Sperm Whale

## Lore

The king of mammals in the deep ocean. Over sixty feet long, able to swim two miles down and dive deeper, and feeding on giant squid - this is the nightmarish monstrosity of Moby Dick and Pinocchio. Its head accounts for a third of its body and is permanently scarred from battles with squid, octopus and other denizens of the deep.

Aggressive and powerful as it is, a sperm whale has never attacked a human or humanoid unprovoked - unless it is a Whale Singer on a mission of destruction. Attacked by whalers, or by pirates like the horune who hunt them for sport and profit, it rams ships and power armour, shatters lifeboats, bites its attackers, and drags surface attackers underwater to hold them until they drown or carry them to depths they cannot survive.

Sperm whales speak in clicking patterns called codas. Their other sounds are low roars and the creaking of rusty hinges.

## GM Notes

Adult males, particularly those over fifty, are often solitary hunters who meet others only in mating season or by chance. A school is either a harem - one older bull and 4D4 females - or a family clan of 1D4x10. Even sperm whale Whale Singers keep to themselves and prefer small groups or solo missions.

Like their smaller cousins they show teamwork, resourcefulness and compassion, especially toward each other. Females are fiercely protective of their young, and a bull defends every member of his group with equal vigour. When one is injured the whole group surrounds it in a tight circle, heads inward and tails out - whalers call it the marguerite flower formation, and anyone who comes within range is battered by their tails.
',
       updated_at = datetime('now')
 WHERE class_id = 'sperm-whale'
   AND instr(markdown, 'only: ["Radio: Basic", "Sing"]') > 0
   AND length(markdown) = 18996;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'sperm-whale' AND instr(markdown, 'only: ["Radio: Basic"], bonus: -10') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'sperm-whale' AND instr(markdown, 'only: ["Radio: Basic", "Sing"]') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('sperm-whale') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~191-book-ingest-audit-f138-sperm-whale.sql');
