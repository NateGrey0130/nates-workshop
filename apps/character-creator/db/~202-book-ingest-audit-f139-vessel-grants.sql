-- BOOK-INGEST-AUDIT F139: the Vernulian, the SAMAS Samurai Pilot and the Glitter Force Trooper are granted their machines
-- 3 classes, each replaced whole: vernulian, samas-samurai-pilot, glitter-force-trooper.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~202-book-ingest-audit-f139-vessel-grants.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

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
equipment_starting:
  - { item_id: "vernulian-serpent-power-armor", qty: 1, note: "Military use only (printed 212): a Vernulian Refugee does not have one, so a refugee character drops it." }
restrictions:
  - "Alignment: any. Military Vernulians lean toward Unprincipled (5%), Anarchist (25%), Aberrant (35%), Miscreant (20%) and Diabolic (10%); refugees toward Scrupulous (15%), Unprincipled (35%) and Anarchist (30%)."
  - "Available O.C.C.s: theoretically any. Military Vernulians do not practice magic and may be the equivalent of most Men at Arms O.C.C.s except the Juicer, Crazy, Glitter Boy and Cyber-Knight. Only refugees consider a practitioner of magic O.C.C., and they are rare."
  - "Magic: none, except by O.C.C. (rare)."
  - "Money and standard equipment: as per O.C.C."
side_effects: "The serpentine body and tentacles frighten and alarm humans and most warm-blooded people and make disguise impossible; many take them for demons or monsters on sight. -10% skill penalty when using complicated devices designed for humanoids, such as computers."
extraction_notes: "WB30 D-Bees of North America printed 210-212 (cache p211-p213, cache page = printed + 1); every number read off a 200 dpi render. Heading Vernulian - Optional Player Character and NPC, printed 211. The entry notes it first appeared in Rifts World Book One: Vampire Kingdoms; this book is the source cited. || CATEGORY: a race that takes an O.C.C.; Experience Level (Military 2D4+1, Refugees 1D8, player characters start at first level) names no ladder, so no xp_table. mdc_base is stated, so no men_of_arms line. || ATTRIBUTES: I.Q. 3D6, M.A. 4D6, M.E. 4D6, P.S. 4D6 (Augmented), P.P. 4D6, P.E. 4D6, P.B. 1D6, Spd 4D6; Augmented is ability text. || M.D.C.: main body 1D6x10 + P.E. and 1D4 per level stored as mdc_base; tentacles 2D6+10 each are ability text. Horror Factor 14. P.P.E. 6D6. || VARIANTS: the book prints two bonus lines. Military: +3 attacks per melee, +1 strike, +4 parry, +3 automatic dodge, +4 entangle, +2 disarm, +4 pull punch, +2 vs Horror Factor, +2 vs poison. Refugees: +2 attacks, +1 Perception Rolls, +2 parry, +2 dodge (not automatic), +2 entangle, +2 vs poison. Save vs poison is toxins_poisons. Stored as two variants, military and refugee; the parent states no bonuses. || PSIONICS: Major Psychic with Telepathy (4), Telekinesis (varies) and Mind Block (4) by name, plus four more from Healing, Sensitive and/or Physical; I.S.P. 1D6x10 plus M.E. and 1D6+1 per level. || SKILLS: Climbing 40+30, Swimming 50+25, Prowl 25+20, W.P. Paired Weapons. One new spoken language each level at +25% is stored as one Language: Other at 50+25 at level one; the later languages are level_progression prose, picked by hand (BOOK-INGEST-AUDIT.md F130; Nate''s ruling of 2026-10-12 leaves skill picks at levels where they are) (judgement: every level read as including the first). || COMBAT: attacks per melee as per Hand to Hand; the Pinning Body Flip, Special Entangle and Constriction moves are special abilities with their printed numbers. || EQUIPMENT: as per O.C.C. The force field collar (160 M.D.C. military, 100 M.D.C. commercial; regenerates 10 an hour; 12 hours a day) is a special ability and, since ~116 and ~117, the rows vernulian-force-field-collar-military and vernulian-force-field-collar-commercial; the class grants neither, because the military collar is the soldiers'' only and about 30% of refugees have the commercial one. The Serpent Power Armor (printed 212: head 100, tentacles 100 each, main body 300, six underside hover jets 25 each, two main hover jets 75 each, flies to 300 feet, 400 mph, military use only) is the vessel row vernulian-serpent-power-armor with a gear row of the same slug, and is granted in equipment_starting (BOOK-INGEST-AUDIT F139); the book makes it military only and a variant cannot carry equipment, so the grant is on the race with a note that a refugee drops it. Statted with no catalog row, not stored as gear: the Serpent Borg full conversion (P.S. 30, P.P. 26, Spd 50; optional bionic legs biped Spd 88 or quadruped Spd 220; jet pack Spd 365; retractable Vibro-Sword 3D6 M.D. or Vibro-Claws 3D6 M.D.; two tentacle blasters; tail blaster as laser rod with double range and +2D6 M.D.; Medium Infantry body armor 300 M.D.C.; plus 1D4+3 bionic weapons or implants) are GM Notes. || AVAILABLE O.C.C.s: no occ_restrictions; the book allows any and its limits depend on faction (a variant cannot carry occ_restrictions), so they are a restriction line. || NOT STORED: size 2D6+8 feet long, weight 3D4x100 lbs, life span 3D8+76 years, slave market value 2D4x10,000, allies, enemies and habitat are GM Notes."
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

Serpent Power Armor (military only; granted in the starting equipment, and a refugee drops it): head 100 M.D.C., tentacles (4) 100
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
   AND instr(markdown, 'Statted items with no catalog row, not stored as gear: the Serpent Power Armor') > 0
   AND length(markdown) = 11496;

-- == samas-samurai-pilot ==
UPDATE imported_classes
   SET markdown = '---
id: samas-samurai-pilot
occ_group: men-of-arms
men_of_arms: true
name: SAMAS Samurai Pilot
system: rifts
source_book: Rifts World Book 8: Japan p.91
category: occ
tags: [combat, pilot]
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
attribute_requirements: { IQ: 10, PP: 11 }
starting_money: "2500"
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, jujitsu: 2 }, conditions: { assassin: "evil alignment", jujitsu: "at the game master''s discretion" } }
  occ_skills:
    - { name: "Streetwise", base: 24, per_level: 4, note: "+4%" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%; the book prints Basic Mathematics." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Japanese. The book prints Language: Japanese & American (+20%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American, +20%. The book prints Language: Japanese & American (+20%)." }
    - { name: "Literacy: Native Language", base: 55, per_level: 5, note: "Japanese, +15%. The book prints Literacy: Japanese & American (+15%)." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 15, note: "American, +15%." }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Military: Tanks & APCs", base: 46, per_level: 4, note: "+10%; the book prints Pilot Tanks & APCs." }
    - { name: "Robots & Power Armor", base: 66, per_level: 3, note: "+10%; the book prints Pilot Robots & Power Armor." }
    - { name: "Robot Combat Elite: SAMAS", base: 0, per_level: 0, note: "The book prints Power Armor Combat Elite: SAMAS Samurai. The Japanese SAMAS is fundamentally the Coalition design (printed 134)." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Blunt", base: 0, per_level: 0, note: "Nightstick and stun clubs." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts, or Assassin if evil, at the cost of one other (O.C.C. Related) skill selection. To change to Jujitsu, at the game master''s discretion, the cost is two other skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Interrogation", "Sniper", "Tracking (people)", "Wilderness Survival"], bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    minimums:
      - { count: 2, category: "Pilot" }
      - { count: 2, category: "Pilot Related" }
    note: "Select seven, but two must be Pilot and two Pilot Related skills. Plus one at levels 3, 6, 9 and 12. Electrical: Basic Electronics only. Espionage: Detect Ambush, Detect Concealment, Interrogation, Sniper, Tracking and Wilderness (Survival) only. Mechanical: Basic only. Medical: First Aid only. Physical: any except Acrobatics. Rogue: Streetwise only. Science: none."
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
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Interrogation", "Sniper", "Tracking (people)", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Rogue", only: ["Streetwise"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 5, count: 3 }
      - { level: 10, count: 3 }
equipment_starting:
  - { choose: 1, label: "Kuru or Trooper body armor", qty: 1, from: ["at-a11-kuru-street-armor", "at-a14-infantry-trooper-body-armor"] }
  - { item_id: "at-n20-neural-stick", qty: 1 }
  - { item_id: "at-samurai-samas-pa-10a", qty: 1, note: "Issued for field use; military property, not the pilot''s." }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["at-88-combat-laser-rifle", "at-84-sharpshot-laser-rifle", "h-84-sniper-rifle-h-brand", "at-230-particle-beam-rifle", "h-12-defender-ion-pulse-rifle", "at-23-police-stun-rifle"], note: "The book says energy rifle of choice without enumerating; this is the ArmaTech and H-Brand rifle set from this book." }
  - { item_id: "armatech-h-brand-rifle-e-clip", qty: 4, note: "Four extra E-clips for the rifle." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["at-30-combat-laser-pistol", "at-20-sharpshot-police-special-laser-pistol", "at-8-laser-pistol", "at-6-mini-laser-pistol-escape-artist", "at-130-particle-beam-pistol", "h-8-laser-pistol-h-brand", "super-h-8-laser-pistol-h-brand", "h-10-combat-laser-pistol", "h-13-ion-pulse-pistol", "h-20-sniper-pistol-h-brand", "h-30-siege-pistol-h-brand"], note: "The book says energy sidearm of choice without enumerating; this is the ArmaTech and H-Brand pistol set from this book." }
  - { item_id: "armatech-h-brand-pistol-e-clip", qty: 4, note: "Four extra E-clips for the sidearm." }
  - { choose: 1, label: "stun/flash or tear gas grenades", qty: 4, from: ["stun-flash-grenade", "at-d31-tear-gas-grenade"], note: "The book prints four AT-D30 stun/flash grenades or tear gas. The catalog has no AT-D30 row; the stun/flash grenade row stands in for it." }
  - { item_id: "signal-flare", qty: 2 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "uniform", qty: 1, note: "Field uniform." }
  - { item_id: "combat-boots", qty: 1, note: "Part of the field uniform." }
  - { item_id: "canteen", qty: 1, note: "Survival kit." }
  - { item_id: "gas-mask", qty: 1, note: "Survival kit." }
  - { item_id: "walkie-talkie", qty: 1, note: "Survival kit radio." }
  - { item_id: "food-rations", qty: 1, note: "Survival kit: one week''s worth of rations." }
  - { item_id: "fishing-line-and-hooks", qty: 1, note: "Survival kit." }
  - { item_id: "first-aid-kit", qty: 1, note: "Survival kit." }
  - { choose: 2, label: "non-energy weapons of choice", qty: 1, from: ["vibro-katana", "vibro-wakizashi", "vibro-saber-short-sword-ninja-short-sword", "vibro-sword-large-one-handed-sword-straight", "vibro-knife-tanto-jitte-sai", "vibro-naginata-bisento", "vibro-yari-spear", "katana-rifts", "wakizashi-rifts", "tonfa-rifts", "at-600-rail-gun", "h-600-rail-gun"], note: "The book says two non-energy weapons of choice without enumerating; this is a catalog set from this book." }
restrictions:
  - "Cybernetics: none to start; usually restricted to medical implants."
  - "The SAMAS power armor is provided for field use only; it is military property, not the pilot''s."
side_effects: "Issued an ArmaTech Samurai Class SAMAS (PA-10A) for field duty; see Issued Power Armor. Room and board are provided by the military, plus a salary of 2500 credits a month; the character starts with one month''s pay."
extraction_notes: "Rifts World Book 8: Japan printed 91 (cache p092; text layer, page_offset +1), read against a render. The whole entry, lore through cybernetics, is on printed 91; printed 92 opens with the Infantryman, so source_book is p.91. || GROUP: men-of-arms, men_of_arms: true. The book''s class list (printed 78) files it as Military: SAMAS Samurai Pilot O.C.C. under Republic of Japan & Mercenaries, and High-Tech O.C.C.s. No S.D.C. or hit points are printed, so the core values apply. || XP: the SAMAS Samurai Pilot column, first row second column of the Experience Point Tables page (cache p217, folio 216), read off a render: 0 / 1,926 / 3,851 / 7,451 / 14,901 / 21,001 / 31,001 / 41,601 / 53,001 / 73,001 / 103,501 / 139,001 / 189,001 / 239,001 / 289,001. || ATTRIBUTES: I.Q. 10 and P.P. 11 or higher. || SKILLS: Streetwise 20+4; Basic Mathematics is Mathematics: Basic 45+10; Language: Japanese & American (+20%) is Language: Native Tongue for Japanese at the catalog''s 98% cap and Language: Other for American as a one-pick choice at +20; Literacy: Japanese & American (+15%) is Literacy: Native Language 40+15 and Literacy: Other as a one-pick choice at +15 (the catalog has no Japanese or American rows); Computer Operation 40+10; Radio: Basic 45+10; Pilot Tanks & APCs is Military: Tanks & APCs 36+10; Pilot Robots & Power Armor is Robots & Power Armor 56+10. Power Armor Combat Elite: SAMAS Samurai is stored as the Robot Combat Elite: SAMAS row: the book says the Japanese SAMAS is fundamentally the Coalition suit with cosmetic changes and a particle beam rifle for the rail gun (printed 134), so no separate skill row was made. || HAND TO HAND: Expert; Martial Arts, or Assassin if evil, for one related pick; Jujitsu for two at the GM''s discretion. || RELATED: seven, with floors of two Pilot and two Pilot Related, plus one at levels 3, 6, 9 and 12. Espionage''s Tracking is Tracking (people), Interrogation the Espionage row of that name, and Wilderness is read as Wilderness Survival, filed under Wilderness in the catalog, which the class also grants. Science: none, so it is not offered. || SECONDARY: three at each of levels one, five and ten, from the same list without bonuses; the book says select three at levels one, five and ten, read as three per level as the book''s other classes print it. || MONEY: one month''s salary, 2500 credits; room and board are free. || EQUIPMENT: Kuru or Trooper armor is a choice of the AT-A11 Kuru Street Armor and the AT-A14 Trooper rows. Energy rifle and sidearm of choice are offered from this book''s ArmaTech and H-Brand sets, with four E-clips each. The AT-D30 stun/flash grenade (printed 130) has no catalog row, so the generic stun/flash grenade row stands in, beside the AT-D31 tear gas grenade. The survival kit is stored as its listed contents. Two non-energy weapons of choice are offered from this book''s vibro-blades, swords, tonfa and rail guns. || POWER ARMOR: the SAMAS itself (ArmaTech Samurai Class SAMAS, printed 132-135) is the vehicle row at-samurai-samas-pa-10a (Japan p.134-135) with a gear row of the same slug, and is granted in equipment_starting as issued military property (BOOK-INGEST-AUDIT F139); the Issued Power Armor section and side_effects still describe it. Upon Special Assignment (SNARLS sensor system, AT-ADD grenades, heavy weapons) is situational and is in GM Notes."
---

## Lore

The SAMAS Samurai are the elite Robot Power Armor pilots of the Republic of Japan''s armed forces. Their SAMAS is a refined version of the same pre-Cataclysm design the Coalition States fields, and in the Republic''s hands it is the better suit.

Unlike Coalition pilots, the samurai pilots are known as dedicated and compassionate warriors who respect life and are not corrupted by the power their armor gives them. As the name suggests, they follow a code modelled on Bushido, the way of the warrior. It is more modern and less formal than the code the traditional samurai of the New Empire keep, but their courage against monsters and supernatural threats has earned them respect even among the mystic warriors of magic Japan.

Together with the Glitter Boy Force, the SAMAS pilots make up half of the Republic''s defenders. They also serve with the police, where the armor''s speed and maneuverability suit quick response in the city streets, and they are qualified to drive and pilot a range of other vehicles, so they take part in many kinds of missions.

## Issued Power Armor

The pilot is issued an ArmaTech Samurai Class SAMAS (model PA-10A) for field use. It is the Coalition design dressed to resemble ancient samurai armor, with minor improvements, searchlights in the belly and helmet, a pair of mini-missile launchers in each forearm, and an AT-P1000 particle beam rifle, cabled to the armor''s nuclear power supply, in place of the rail gun. Main body 290 M.D.C.; it flies at up to 320 mph (cruising 150 mph), leaps, hovers, and has the full optics and sensor suite of Japanese power armor. The suit is military property and is not the pilot''s to keep. The full statistics are printed 132-135.

## GM Notes

Upon special assignment, elite troops may be given access to the SNARLS sensor system, AT-ADD anti-armor dissolving grenades, other grenades, rifles and heavy weapons, and other equipment, particularly in emergencies.

Cybernetics: none to start, and usually restricted to medical implants. Note that the book''s power armor chapter says most Republic power armor and robot pilots carry two to six implants including a head-jack; this class starts with none.
',
       updated_at = datetime('now')
 WHERE class_id = 'samas-samurai-pilot'
   AND instr(markdown, 'the class does not grant it and still describes it in the Issued Power Armor section') > 0
   AND length(markdown) = 13114;

-- == glitter-force-trooper ==
UPDATE imported_classes
   SET markdown = '---
id: glitter-force-trooper
occ_group: men-of-arms
men_of_arms: true
name: Glitter Force Trooper
system: rifts
source_book: Rifts World Book 8: Japan p.93-94
category: occ
tags: [combat, pilot]
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
attribute_requirements: { PP: 11 }
starting_money: "3000"
skills:
  hand_to_hand: { costs: { basic_martial_arts_judo: 1, assassin: 1, kendo: 2, karate: 2, jujitsu: 2 }, conditions: { assassin: "evil alignment", kendo: "at the game master''s discretion", karate: "at the game master''s discretion", jujitsu: "at the game master''s discretion" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%; the book prints Basic Mathematics." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Japanese. The book prints Language: Japanese & American (+20%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American, +20%. The book prints Language: Japanese & American (+20%)." }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "Japanese, +20%. The book prints Literacy: Japanese & American (+20%)." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "American, +20%." }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Robots & Power Armor", base: 66, per_level: 3, note: "+10%; the book prints Pilot Robots & Power Armor." }
    - { name: "Robot Combat Elite: Glitter Boy", base: 0, per_level: 0, note: "The book prints Robot Combat Elite: Glitter Boy." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "Sensory Equipment", base: 45, per_level: 5, note: "+15%; the book prints Read Sensory Equipment." }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts/Judo (Basic Martial Arts), or Assassin if evil, at the cost of one other (O.C.C. Related) skill selection. To change to Kendo, Karate or Jujitsu, at the game master''s discretion, the cost is two other skill selections." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Interrogation", "Sniper", "Tracking (people)", "Wilderness Survival"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Select six, plus one at levels 3, 6, 9 and 12. Electrical, Mechanical, Rogue and Science: none. Espionage: Detect Ambush, Detect Concealment, Interrogation, Sniper, Tracking and Wilderness (Survival) only. Medical: First Aid only. Physical: any except Acrobatics."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Interrogation", "Sniper", "Tracking (people)", "Wilderness Survival"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "Kuru or Trooper body armor", qty: 1, from: ["at-a11-kuru-street-armor", "at-a14-infantry-trooper-body-armor"] }
  - { choose: 1, label: "issued Glitter Boy", qty: 1, from: ["glitter-boy-power-armor", "usa-g10a1-point-glitter-boy", "usa-g10a2-hawkeye-glitter-boy"], note: "The book issues a Glitter Boy for field use and names no model; these are the three the Republic fields. Military property, not the pilot''s." }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["at-88-combat-laser-rifle", "at-84-sharpshot-laser-rifle", "h-84-sniper-rifle-h-brand", "at-230-particle-beam-rifle", "h-12-defender-ion-pulse-rifle", "at-23-police-stun-rifle"], note: "The book says energy rifle of choice without enumerating; this is the ArmaTech and H-Brand rifle set from this book." }
  - { item_id: "armatech-h-brand-rifle-e-clip", qty: 4, note: "Four extra E-clips for the rifle." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["at-30-combat-laser-pistol", "at-20-sharpshot-police-special-laser-pistol", "at-8-laser-pistol", "at-6-mini-laser-pistol-escape-artist", "at-130-particle-beam-pistol", "h-8-laser-pistol-h-brand", "super-h-8-laser-pistol-h-brand", "h-10-combat-laser-pistol", "h-13-ion-pulse-pistol", "h-20-sniper-pistol-h-brand", "h-30-siege-pistol-h-brand"], note: "The book says energy sidearm of choice without enumerating; this is the ArmaTech and H-Brand pistol set from this book." }
  - { item_id: "armatech-h-brand-pistol-e-clip", qty: 4, note: "Four extra E-clips for the sidearm." }
  - { choose: 1, label: "grenades", qty: 4, from: ["at-d25-light-fragmentation-grenade", "at-d26-heavy-fragmentation-grenade", "at-d28-high-explosive-grenade", "at-d29-plasma-grenade", "at-d31-tear-gas-grenade", "at-d32-concussion-grenade", "at-d40-smoke-grenade"], note: "The book prints four grenades without naming a type; this is the ArmaTech grenade set from this book. A mix is at the GM''s discretion." }
  - { item_id: "signal-flare", qty: 2 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "uniform", qty: 1, note: "Field uniform." }
  - { item_id: "combat-boots", qty: 1, note: "Part of the field uniform." }
  - { item_id: "canteen", qty: 1, note: "Survival kit." }
  - { item_id: "gas-mask", qty: 1, note: "Survival kit." }
  - { item_id: "walkie-talkie", qty: 1, note: "Survival kit radio." }
  - { item_id: "food-rations", qty: 1, note: "Survival kit: one week''s worth of rations." }
  - { item_id: "fishing-line-and-hooks", qty: 1, note: "Survival kit." }
  - { item_id: "first-aid-kit", qty: 1, note: "Survival kit." }
  - { choose: 2, label: "non-energy weapons of choice", qty: 1, from: ["vibro-katana", "vibro-wakizashi", "vibro-saber-short-sword-ninja-short-sword", "vibro-sword-large-one-handed-sword-straight", "vibro-knife-tanto-jitte-sai", "vibro-naginata-bisento", "vibro-yari-spear", "katana-rifts", "wakizashi-rifts", "tonfa-rifts", "at-600-rail-gun", "h-600-rail-gun"], note: "The book says two non-energy weapons of choice without enumerating; this is a catalog set from this book." }
restrictions:
  - "Cybernetics: 1D4 implants to start; additional cyberware is usually restricted to medical implants."
  - "Glitter Boy power armor is provided for field use only; it is military property, not the pilot''s."
side_effects: "Issued a Glitter Boy (the traditional USA-G10, the G10A1 Point or the G10A2 Hawkeye) for field duty; see Issued Power Armor. Other bots, armor or weapons may be provided for special assignments. Room and board are provided by the military at no cost, plus a salary of 3000 credits a month; the character starts with one month''s pay. Starts with 1D4 cybernetic implants."
extraction_notes: "Rifts World Book 8: Japan printed 93-94 (cache p094-p095; text layer, page_offset +1), read against renders. The text layer runs the Robot Pilot''s stat block (P.P. 10, I.Q. 9, eight related skills, Rogue: Any) straight into this class''s lore at the top of cache p094; the render shows the Glitter Force Trooper block is the right-hand column under the title (P.P. 11), continuing onto printed 94 through Cybernetics, where the Police Officer begins. The Glitter Force itself is described on printed 76 and the Republic''s Glitter Boy models on printed 136-141. || GROUP: men-of-arms, men_of_arms: true. The book''s class list (printed 78) files it under Republic of Japan & Mercenaries, and High-Tech O.C.C.s. No S.D.C. or hit points are printed, so the core values apply. || XP: the Glitter Force Trooper column, third column bottom of the Experience Point Tables page (cache p217, folio 216), read off a render: 0 / 2,201 / 4,401 / 8,801 / 17,601 / 27,801 / 37,901 / 55,101 / 75,201 / 100,301 / 145,501 / 190,601 / 245,701 / 295,801 / 345,901. || ATTRIBUTES: P.P. 11 or better, nothing else. || SKILLS: Basic Mathematics is Mathematics: Basic 45+10; Language: Japanese & American (+20%) is Language: Native Tongue for Japanese at the catalog''s 98% cap and Language: Other for American as a one-pick choice at +20; Literacy: Japanese & American (+20%) is Literacy: Native Language 40+20 and Literacy: Other as a one-pick choice at +20 (the catalog has no Japanese or American rows); Computer Operation 40+10; Radio: Basic 45+10; Pilot Robots & Power Armor is Robots & Power Armor 56+10; Read Sensory Equipment is the Sensory Equipment row 30+15; Weapon Systems 40+10; Running has no percentage. Robot Combat Elite: Glitter Boy is the existing catalog row of that name. || HAND TO HAND: Expert; Martial Arts/Judo, or Assassin if evil, for one related pick; Kendo, Karate or Jujitsu for two at the GM''s discretion. Martial arts/judo is read as this book''s Basic Martial Arts (Equivalent to Judo, printed 193), which the book calls the basic style of the Republic''s armed forces and police; the core Martial Arts style is not offered. || RELATED: six, plus one at levels 3, 6, 9 and 12. Espionage''s Tracking is Tracking (people); Wilderness is read as Wilderness Survival, filed under Wilderness in the catalog, which the class also grants. Electrical, Mechanical, Rogue and Science: none, so they are not offered. || SECONDARY: six from the same list without bonuses; the book states no later secondary picks. || MONEY: one month''s salary, 3000 credits; room and board are free. || EQUIPMENT: Kuru or Trooper armor is a choice of the AT-A11 Kuru Street Armor and the AT-A14 Trooper rows. Energy rifle and sidearm of choice are offered from this book''s ArmaTech and H-Brand sets, with four E-clips each. Four grenades of unstated type are offered from this book''s ArmaTech grenade set. The survival kit is stored as its listed contents. Two non-energy weapons of choice are offered from this book''s vibro-blades, swords, tonfa and rail guns. || POWER ARMOR: the book issues Glitter Boy vehicles for field use only and names no model. The Republic fields the traditional USA-G10 (reprinted from the core book on printed 136-137, the catalog''s glitter-boy-power-armor row) alongside the G10A1 Point and G10A2 Hawkeye (printed 138-141), which are vehicle rows (usa-g10a1-point-glitter-boy, usa-g10a2-hawkeye-glitter-boy; Japan p.137-142). All three have gear rows of the same slug and are a choose-one in equipment_starting as issued military property (BOOK-INGEST-AUDIT F139); all three are still described in the Issued Power Armor section. || CYBERNETICS: 1D4 implants to start, types unstated; prose only."
---

## Lore

Where the Glitter Boys of the Americas are heirs to a scarce relic and often wander as independent heroes and mercenaries, the Glitter Force Troopers of the Republic of Japan are trained professional soldiers. They live, fight and die for the protection of the New Republic, an elite force adored by the public and feared by the nation''s enemies, and they take the responsibility of that reputation seriously. They tend to be more serious and driven than their American counterparts.

The Glitter Force is the elite corps that operates the Republic''s many Glitter Boys. The Republic uses the armor on a scale no other power in the world approaches: it guards the city perimeters and the national borders, deploys in urban fighting, and marches against encroaching oni, often beside SAMAS and support robots, leading the charge with bionic soldiers, other power armor and ground troops behind it.

Troopers are trained to fight in Glitter Boy teams and in coordination with other robots, power armor and vehicles, with tactics that cover the armor''s classic weakness, its low mobility. A favourite is to let faster flyers such as the SAMAS Samurai herd an enemy into a narrow killing ground in front of the Glitter Boys'' guns; more than one oni horde has died that way.

They also train widely in other robots and power armor and can handle nearly any ArmaTech weapon system, and many from Ichto and H-Brand. That breadth sometimes sends them on unconventional missions as advisors, instructors and even secret agents. Off duty they carry a quiet, understated sense of superiority: they rarely boast, since being known as a Glitter Force Trooper is enough.

## Issued Power Armor

Glitter Boy armor is provided for field use only and remains military property. The Republic fields three models, all built on the pre-Rifts American design that was turned over to ArmaTech:

- **USA-G10 Glitter Boy** (printed 136-137, reprinted from the core book): the traditional laser-resistant assault armor with the RG-14 Boom Gun rail gun, main body 770 M.D.C. It is kept by the frontline troops who defend the Republic''s outskirts and wilderness. This is the catalog''s Glitter Boy Power Armor row.
- **USA-G10A1 Point** (printed 138-140): a smaller, faster reconnaissance Glitter Boy in S.D.C. camouflage paint, trading the Boom Gun for a multi-barrel laser rifle and a forearm rail gun, with greater thruster-assisted leaps and a closed circuit camera that relays what it sees to command. Main body 480 M.D.C.
- **USA-G10A2 Hawkeye** (printed 140-141): an anti-aircraft Glitter Boy carrying medium-range smart missiles in place of the Boom Gun and needing no stabilizing pylons. Republic Glitter Boy squads include at least one, and up to three on missions expecting heavy air contact.

The full statistics are on the printed pages given above.

## GM Notes

Other robots, armor or weapons may be issued for special assignments.

Cybernetics: 1D4 implants to start; additional cyberware is usually restricted to medical implants.
',
       updated_at = datetime('now')
 WHERE class_id = 'glitter-force-trooper'
   AND instr(markdown, 'and the class does not grant any of them.') > 0
   AND length(markdown) = 14121;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 3 classes carry their new text' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'vernulian' AND instr(markdown, 'item_id: "vernulian-serpent-power-armor"') > 0)
    OR (class_id = 'samas-samurai-pilot' AND instr(markdown, 'item_id: "at-samurai-samas-pa-10a"') > 0)
    OR (class_id = 'glitter-force-trooper' AND instr(markdown, 'label: "issued Glitter Boy"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'vernulian' AND instr(markdown, 'Statted items with no catalog row, not stored as gear: the Serpent Power Armor') > 0)
    OR (class_id = 'samas-samurai-pilot' AND instr(markdown, 'the class does not grant it and still describes it in the Issued Power Armor section') > 0)
    OR (class_id = 'glitter-force-trooper' AND instr(markdown, 'and the class does not grant any of them.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('vernulian', 'samas-samurai-pilot', 'glitter-force-trooper') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~202-book-ingest-audit-f139-vessel-grants.sql');
