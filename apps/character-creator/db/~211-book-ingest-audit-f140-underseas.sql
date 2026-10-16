-- BOOK-INGEST-AUDIT F140: settle the Underseas amphib and pneuma-biform dolphin sentences
-- 2 classes, each replaced whole: amphib, pneuma-biform-dolphin.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~211-book-ingest-audit-f140-underseas.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT F140, the Underseas classes (row 37d1). Two classes'
-- sentences were tested against renders of Underseas printed 51 to 53, 80 and
-- 98 to 100 and against the app on 2026-10-15. Four sentences are false:
-- - amphib: its skills restriction said the app had no way to pair it with a
--   second O.C.C. and told the player to pick one by hand. The wizard's
--   Occupation step picks it and brings its skills whole; only the reduction by
--   three is by hand. Its extraction note said the same of "use that class's
--   list".
-- - amphib: its underwater-bonus restriction blamed the sheet for having no
--   conditional slot. The sheet has a conditional list, fed by skill rows; it is
--   a class's own bonuses that have no conditional form.
-- - pneuma-biform-dolphin: printed 52's "two via magic or psionics" is the
--   number of attacks when attacking by magic or psionics, not two more.
-- - pneuma-biform-dolphin: an extraction note said psionics_allowed was not set
--   and the question was left to close-out package C5; it was set false on
--   2026-10-05 (F118), as the class's later note says.

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
  - "SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. Printed 100 has the player select either the Sea Wolf or the Tritonian Scientist O.C.C., or any other appropriate O.C.C. at the G.M.''s call including a magic O.C.C., and then REDUCE the number of available O.C.C. skills by three. The O.C.C. is picked at the wizard''s Occupation step, which brings its skills whole; no key takes three away, so drop three of its O.C.C. skills by hand."
  - "Experience: use the Amphib table or the chosen O.C.C.''s table, whichever is HIGHER."
  - "THE STORED COMBAT BONUSES ARE ALL UNDERWATER-ONLY. Printed 100 gives +2 to dodge and +1 to roll with impact and pull punch underwater, and nothing on land. They are stored unconditionally because an amphib is an aquatic character and a class''s own bonuses have no conditional form - but a G.M. running an amphib on dry land should ignore all three."
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
    borrow a list, it borrows one AND REDUCES IT BY THREE. The borrowing is
    the race-and-occupation pairing: the wizard''s Occupation step offers the
    O.C.C., and its skills come whole (composed with both Tritonian O.C.C.s
    through the real parser, 2026-10-15). No key takes three away
    (BOOK-INGEST-AUDIT.md F129''s cut is a factor or a cap). Added to
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
   AND instr(markdown, 'The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a).') > 0
   AND length(markdown) = 13749;

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
mdc_base: "2d6x10"
ppe_base: "3d6x10"
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
  - "M.D.C. gains 2D6 per level of experience and P.P.E. gains 3D6 per level, on top of the bases stored here."
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
    unconditionally.
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
   AND instr(markdown, 'either form gets 2 more via magic or psionics') > 0
   AND length(markdown) = 17134;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'amphib' AND instr(markdown, 'no key takes three away, so drop three of its O.C.C. skills by hand') > 0)
    OR (class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'attacking by magic or psionics either form gets 2 a melee round') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'amphib' AND instr(markdown, 'The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a).') > 0)
    OR (class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'either form gets 2 more via magic or psionics') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('amphib', 'pneuma-biform-dolphin') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~211-book-ingest-audit-f140-underseas.sql');
