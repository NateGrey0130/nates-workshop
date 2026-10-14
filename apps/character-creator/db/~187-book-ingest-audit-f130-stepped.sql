-- BOOK-INGEST-AUDIT F130, first half: stepped values become ability progressions on three D-Bees classes, and five classes stop citing F116 for them
-- 5 classes, each replaced whole: amana, squilb, forest-warden, mraghiile-tree-man, vernulian.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~187-book-ingest-audit-f130-stepped.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

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
    progression:
      - { level: 2, text: "Radius +4 feet (1.2 m), 8 feet (2.4 m) in all." }
      - { level: 4, text: "Radius +4 feet (1.2 m), 12 feet (3.6 m) in all." }
      - { level: 8, text: "Radius +4 feet (1.2 m), 16 feet (4.8 m) in all." }
      - { level: 12, text: "Radius +4 feet (1.2 m), 20 feet (6 m) in all." }
      - { level: 16, text: "Radius +4 feet (1.2 m), 24 feet (7.2 m) in all." }
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
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 18-21 (cache p019-p022), a scan; every number read off 200 dpi renders of cache p020, p021 and p022 and checked against the OCR. Heading Amana - Optional Player Character or NPC (printed 19). The entry opens at the foot of printed 18 after the Altara and ends on printed 21, where Amorph begins. || CATEGORY: an R.C.C. that takes no O.C.C.; Available O.C.C.s: None, because they are natural born healers; see R.C.C. Skills. There is no frontmatter key for no occupation at all, so it is a restriction line, as the amorph class does. || XP_TABLE: the Experience Level line says Use the Body Fixer experience table. Per the class-import reference (a class whose book names another class''s table copies that ladder), the stored body-fixer ladder is copied here. This departs from the batch brief''s no-xp_table default, whose premise (use the chosen O.C.C.''s table) this entry does not print. || M.D.C.: P.E. attribute number +3D4, plus 1D4 per level, stored as mdc_base; so no men_of_arms line. || P.P.E.: P.E. attribute number +2D4x10, plus 4D4 per level, stored as ppe_base; ley line draw is ability text. || PSIONICS: Induce Sleep (4), Mind Block (4), Presence Sense (4), Sense Evil (2) granted by name, plus four of choice from the Healer category (catalog category Healing); Major Psychic. I.S.P.: M.E. attribute number plus 2D4 per level, read as 2D4 at every level including the first. || BONUSES: +2 Perception, +4 vs Horror Factor, +2 vs mind control and possession; +2 vs Necromancy or Spoiling Magic and +4 vs Bio-Wizardry, symbiotes and parasites as saves.other. Aura of Life bonuses go to allies and are ability text. || SKILLS: catalog base plus the printed bonus. Language: Native Tongue is 98% in the catalog, so the +15% is in the note. Literacy: Native Tongue +20% is Literacy: Native Language 40+20=60. Biology 30+20=50, Chemistry 30+15=45, Medical Doctor 60+25=85, Pathology 40+20=60. Language: Other and Literacy: Other one each at +15%; Domestic two at +10%. HAND TO HAND: none granted; Basic for one related skill, Expert for four, nothing else: costs basic 1, expert 4. || RELATED: six plus one at 3, 6, 9, 12 and 15. Communications any; Cowboy none; Domestic +5%; Electrical Basic Electronics only; Espionage none; Horsemanship General only; Mechanical Basic Mechanics only; Medical +15%; Military none; Physical none; Pilot any except robots and power armor and military vehicles (the except list is the one other classes use, plus Robot Combat: Basic); Pilot Related any; Rogue none; Science +10%; Technical +5%; W.P. Ancient any and Modern Energy Rifle and Energy Pistol only (the ancient list is the one other classes use); Wilderness any. || SECONDARY: four from the Rifts Ultimate Edition Secondary Skills list, plus one at levels 4, 8 and 12; stored without a category list. || LEVEL-GATED: the Aura of Life radius grows at levels 2, 4, 8, 12 and 16; stored as the Aura of Life ability''s progression, display text by level, all five steps, each with the running total (a sum of the printed steps; the page prints only the steps). The level_progression lines for 2-12 stay (BOOK-INGEST-AUDIT.md F130). || TYPO: the limb-reattachment note prints The P.E. cost is only 1D4x10+8; read as P.P.E., since the passage is about P.P.E. spent. || EQUIPMENT: traveling clothes, first-aid kit, a box of 100 surgical gloves (disposable-surgical-gloves qty 1 since ~116 and ~117: the catalog row is priced per box and the book prints one box of 100), 10 S.D.C. scalpels, dress clothes, backpack or large sack, language translator, and 1D4+1 weeks of water and rations stored as food-rations 1d4+1. The surgical apron is granted as surgical-gown. NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant; in GM Notes. || MONEY: 3D4x1,000 Universal Credits stored as starting_money; 1D4x10,000 credits of tradable items is goods, in GM Notes. || NOT STORED: size 6-7 feet, weight 140-190 pounds, life span 4D4+180 years, NPC level 1D4+4, slave market value, allies, enemies, habitat; in GM Notes."
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
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0
   AND length(markdown) = 15566;

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
    progression:
      - { level: 2, text: "One more use per day, three in all." }
      - { level: 5, text: "One more use per day, four in all." }
      - { level: 8, text: "One more use per day, five in all." }
      - { level: 12, text: "One more use per day, six in all." }
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
extraction_notes: "WB30 D-Bees of North America printed 198-200 (cache p199-p201, cache page = printed + 1); every number read off a 200 dpi render. Heading Squilbs - Optional Player Character or NPC, printed 198. || CATEGORY: a race that takes an O.C.C.; the entry prints no experience ladder and names none (Experience Level 1D6 for NPCs, player characters start at first level), so no xp_table. || POOLS: Hit Points P.E. attribute number x2 plus 1D6 per level stored as hit_points_base. S.D.C. 1D6x10+16 is a racial S.D.C. and is a pool bonus, never sdc_base. men_of_arms false, as for every race. P.P.E. 2D6. Horror Factor: not applicable, so none stored. || BONUSES: +1 attack per melee, +2 initiative, +1 strike and parry, +2 disarm, +3 pull punch, +2 roll with impact, +1 vs Horror Factor stored as printed; +5 to save vs demonic possession stored as possession 5 (judgement: the book qualifies it as demonic). || PSIONICS: select two powers from the Sensitive category, a Minor Psychic, I.S.P. M.E. +2D6 plus 1D6 per level. || HIDDEN STRENGTH: twice per day plus one more use at levels 2, 5, 8 and 12; the level-gated uses are the Hidden Strength ability''s progression, display text by level with the running total, and the level_progression lines stay (BOOK-INGEST-AUDIT.md F130). No trackable_resources is stated, because a fixed max of 2 would be wrong from level 2; the count is in the ability text. || SKILL NOTE: +10% to Domestic skills in addition to any O.C.C. bonuses has no race-level carrier and is a special ability; the sheet does not add it. || AVAILABLE O.C.C.s: stored as occ_restrictions except, naming every Rifts Juicer, Crazy and cyborg O.C.C. in the catalog on 2026-10-03 (the book''s Cyborgs, Juicers and Crazies); an augmentation O.C.C. added later is not on the list. The favorites list is a tendency and is the note. || MONEY: printed as per O.C.C. plus 1D4x1,000 credits in trade goods. Not stored as starting_money, because a race''s starting_money replaces the occupation''s in a pairing rather than adding to it; it is a restriction line. || EQUIPMENT: as per O.C.C., favoring spears and pole arms; nothing stored. || NOT STORED: size 7-9 feet, weight 300-500 pounds, life span 4D6+100 years, slave market value 3D6x1,000, allies, enemies, habitat and the NEMA note are GM Notes."
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
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0
   AND length(markdown) = 7964;

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
    progression:
      - { level: 18, text: "+1 attack per melee, eleven in all." }
      - { level: 22, text: "+1 attack per melee, twelve in all." }
      - { level: 30, text: "+1 attack per melee, thirteen in all." }
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
extraction_notes: "D-Bees of North America printed 90-93 (cache p091-p094, cache page = printed + 1), every number read off 200 dpi renders. Printed 90 is a full-page art plate; the text runs 91-93 and ends at Rivals and Enemies above the Ganka heading. Tag line: Forest Warden R.C.C. - Optional NPC or Player Character, with a Player Character Note that it is not recommended but possible; stored as playable with that note as a restriction. || CATEGORY: an R.C.C. that takes no O.C.C. (Available O.C.C.s: None). || XP_TABLE: the Experience Level line says Use the Psi-Stalker experience table, so the catalog psi-stalker class''s stored ladder is copied, per the class-import reference rule (Nate''s decision 2026-09-26). This departs from the batch brief''s no-xp_table default, which assumed entries defer to the chosen O.C.C.''s table. The Attacks per Melee line also says use Dragon experience table; that conflicts with the Experience Level line, and the Experience Level line was taken as the authority. || ATTRIBUTES as printed; P.S. 4D6+2 is Supernatural, ability text. || M.D.C. P.E. x3 plus 2D6 per level as mdc_base; no men_of_arms line. The S.D.C.-environment Hit Points (P.E. x3 +2D6 per level) and S.D.C. (P.E. x5 +4D6 per level) are natural ability text. || HORROR FACTOR 12. P.P.E. 6D6 stored; +3D6 for every 50 years of life is not stored (age is not modelled) and is in GM Notes. || ATTACKS: five at level one, stored as attacks_base 5, plus one at levels 3, 6, 9, 12 and 15 as at_level attacks; the further attacks at 18, 22 and 30 lie past the 15-level ladder and are the Attacks per melee ability''s progression, display text by level with the running total (BOOK-INGEST-AUDIT.md F130). hand_to_hand costs {} because the race grants no Hand to Hand and its related categories offer none. || BONUSES: +1 initiative, +2 Perception, +1 strike, +3 parry, +1 dodge, +2 pull punch, +3 roll, +10% vs coma/death, +3 vs mind control, +5 vs possession. A successful mind control lasts half as long is GM Notes. || SKILLS: catalog base plus printed bonus. Language: Native Tongue is American at 90% (stored base 90, per_level 0). Mathematics: Basic printed (20%) without a plus sign, read as +20% like every other figure in the list (45+20=65). Detect Concealment and Lore: Demons & Monsters print no bonus. Acrobatics (+5% where applicable) stored as 35. || RELATED: two at levels 2, 4, 8, 12, 16 and 20; the schedule stores 2, 4, 8 and 12, and 16 and 20 lie past the 15-level ladder and are not stored (BOOK-INGEST-AUDIT.md F130; Nate''s ruling of 2026-10-12 leaves skill picks at levels where they are). Categories Communications, Domestic +10, Technical +5, Wilderness +15, W.P. any. Secondary Skills: none. || EQUIPMENT: one weapon per W.P. is weapons-matching-w-p-skills. Granted since ~116 and ~117: the clay bowls as bowl-earthenware (the page prints no count), the grass mat or hammock as hammock, the 2D6+6 throwing stones as forest-warden-throwing-stone (2D6 S.D.C./1D4 M.D./2D4 M.D. power throw), the grass satchel as purse-satchel, the walking stick or club as forest-warden-walking-stick-or-club, and the two E-Clips for each W.P. weapon as e-clip; the stones'' and club''s damage is also a special ability and the list is also a restriction line. Money: none; the NPC stolen-tech figure is a restriction line, not starting_money. || NOT STORED: size, weight, life span, birthing, habitat, slave value, allies and enemies are in GM Notes."
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
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0
   AND length(markdown) = 13302;

-- == mraghiile-tree-man ==
UPDATE imported_classes
   SET markdown = '---
id: mraghiile-tree-man
name: M''Raghiile Tree Man
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.135-138
category: rcc
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
tags: [wilderness, stealth]
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "2d6+3"
  MA: "3d6+3"
  PS: "1d6+5"
  PP: "3d6+10"
  PE: "3d6"
  PB: "3d6+3"
  Spd: "3d6"
hit_points_base: "P.E., +1d4 per level"
ppe_base: "4d6"
occ_restrictions:
  only: ["healing-shaman", "plant-shaman", "elemental-fusionist-fire-water", "elemental-fusionist-earth-air", "mystic", "group:psychic", "group:magic"]
  note: "Nearly every M''Raghiile met outside the forests is a young wanderer who uses the R.C.C. skills and takes no O.C.C. A tribe''s one or two Shamans are a Healing or Plant Shaman, or an Elemental Fusionist, Mystic or Psychic in that role; any Magic O.C.C. is allowed as well. Such a character uses that O.C.C.''s skills and powers rather than the R.C.C. skills; the picker does not drop them."
bonuses:
  pools: { sdc: "3d6+8" }
  combat: { initiative: 2, strike: 1, automatic_dodge: 4, disarm: 1, entangle: 2, pull_punch: 2, roll: 6, perception: 4 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 60, per_level: 5, note: "+30%." }
    - { name: "Camouflage", base: 50, per_level: 5, note: "+30%." }
    - { name: "Climbing", base: 75, per_level: 5, note: "+35%." }
    - { name: "Escape Artist", base: 55, per_level: 5, note: "Printed (25%), read as +25%." }
    - { name: "Gymnastics", base: 55, per_level: 5, note: "+25%." }
    - { choose: 1, from: ["Hand to Hand: Basic", "Hand to Hand: Expert"], note: "Hand to Hand: Basic for females, Hand to Hand: Expert for males." }
    - { name: "Identify Plants & Fruit", base: 50, per_level: 5, note: "+25%." }
    - { name: "Land Navigation", base: 60, per_level: 4, note: "+24%." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%, and an additional +20% when in trees." }
    - { name: "Swimming", base: 50, per_level: 5 }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Domestic"], note: "Two Domestic skills of choice." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P. Ancient Weapons of choice." }
equipment_starting:
  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1 }
  - { item_id: "mraghiile-patchwork-armor", qty: 1, note: "M.D.C. is rolled: 2D6+17." }
natural_abilities:
  - name: "An S.D.C. being"
    description: "Hit Points are the P.E. attribute number plus 1D4 per level of experience. S.D.C. is 3D6+8. M.D.C. only from armor (typically patchwork with 2D6+17 M.D.C.) or magic."
  - name: "Multi-Hand Dexterity"
    description: "Ambidextrous with both hands and feet, which are really a second pair of hands. Has the equivalent of Paired Weapons with all four hands and can strike or parry in any combination, though at least one hand usually supports the body from a hanging or standing position."
  - name: "Natural Contortionist"
    description: "Bends in half, curls into a ball, walks backwards on hands and feet, fights with any of its four hands from almost any angle, and squeezes through a hole as small as 5 inches (13 cm) across."
  - name: "Natural Camouflage"
    description: "Striped hide, a pelt whose hairs can stand or flatten to make or break patterns, and small size let it hide in the wild very well; see the R.C.C. skill bonuses."
  - name: "Prehensile Tail"
    description: "Used for balance, to swing and hang from branches and to grab and carry small items. It can hold a knife or club, or even fire a handgun at -6 to strike (no penalty with small melee weapons)."
  - name: "Natural Acrobat and Gymnast"
    description: "Runs and jumps through trees as easily as a human walks, with the equivalent of the Gymnastics and Acrobatics skills; do not add their attribute, combat or S.D.C. bonuses, which are already factored in. Leap distances and heights from those skills are doubled, and falls do half damage. No penalty to shoot, throw or strike while moving, leaping, swinging, balanced on one hand or foot, or hanging by the tail."
  - name: "Superior Senses and Perception"
    description: "The equivalent of 20-05 vision, Nightvision 200 feet (61 m), Advanced Hearing, and Advanced Smell: track by scent at 57% +3% per level of experience. +4 to visual, olfactory and auditory Perception Rolls."
  - name: "Natural attacks"
    description: "Punch 1D4 S.D.C., bite 1D4 S.D.C., kick 1D6 S.D.C., and a swing or leap kick 2D6 S.D.C. +2 to strike on leap attacks and kicks."
level_progression:
  - { level: 2, grants: ["Select two Language: Other skills (+20%). Picked by hand: a pick limited to a category at a set level is not modelled."] }
  - { level: 3, grants: ["Select two Wilderness skills (+15%)."] }
  - { level: 4, grants: ["Select two Communications skills (+10%)."] }
  - { level: 5, grants: ["Select two Rogue skills (+5%), excluding all tech skills, Seduction and Streetwise."] }
  - { level: 7, grants: ["Select two Technical skills."] }
  - { level: 9, grants: ["Select two Modern W.P. or two Piloting skills (basic vehicles only, no robots, power armor or military)."] }
  - { level: 11, grants: ["Select two more Domestic or Technical skills."] }
trackable_resources: []
side_effects: "Their small size, ordinary strength and gentle nature can all work against them."
restrictions:
  - "Alignment: any, but most are Principled (25%), Scrupulous (35%) or Unprincipled (20%)."
  - "Psionics: same probability as a human, tending toward Sensitive and Physical powers. Magic: none, unless a Magic O.C.C. is selected."
  - "Cybernetics and bionics: none; the whole idea seems crazy to them."
  - "A Shaman (Healing or Plant Shaman, or an Elemental Fusionist, Mystic or Psychic in that role) uses the skills and powers of that O.C.C. rather than the R.C.C. skills. Not applied by the picker."
  - "Standard equipment: one weapon for each W.P., a waterskin, a belt or bandoleer with pockets and belt loops, and makeshift patchwork M.D.C. armor (not environmental) with 2D6+17 M.D.C. Player characters start with no TW, magic or M.D.C. melee weapons."
extraction_notes: "WB30 D-Bees of North America printed 135-138 (cache p136-p139), read off 200 dpi renders. The heading M''Raghiile Tree Men, Mammalian Forest Dwellers of the Sequoia Forest, is at the foot of printed 135; the stat block headed M''Raghiile Tree Men - Optional Player Character or NPC starts at the foot of printed 136 and ends at the top of printed 138 (Money to Rivals and Enemies), before Malvoren. || CATEGORY: a race whose R.C.C. skills are the kit of a young wanderer; Shamans take an O.C.C. instead. || XP: the book says to use the Wilderness Scout experience table. It was left out at import, per that import''s brief, and an xp_table is stored now. || POOLS: Hit Points P.E. attribute number plus 1D4 per level, as hit_points_base. S.D.C. 3D6+8 is a racial S.D.C. stored as a pool bonus with men_of_arms false. M.D.C. by armor or magic only. P.P.E. 4D6. Horror Factor not applicable. || ATTRIBUTES as printed; Spd 3D6 is running on two legs, doubled on all fours, x10 leaping and swinging through trees (ability text). || BONUSES: +2 initiative, +1 strike, +4 automatic dodge, +1 disarm, +2 entangle, +2 pull punch, +6 roll stored. +2 to strike on leap attacks and kicks is conditional and ability text. +4 to visual, olfactory and auditory Perception Rolls is stored as perception 4. || SKILLS: catalog base plus the printed bonus. Escape Artist is printed (25%) with no plus sign; read as +25%, 55, like its neighbours. Identify Plants and Fruits is the catalog Identify Plants & Fruit. Hand to Hand: Basic for females and Expert for males is a one-of-two choice; no upgrade price is printed, so no hand_to_hand block. Two Domestic skills and three W.P. Ancient Weapons of choice are choice groups; Ancient is in the note, not enforced. || ADDITIONAL SKILLS at levels 2, 3, 4, 5, 7, 9 and 11 are level-gated picks restricted by category, which the related-skill schedule cannot narrow per level: prose in level_progression, picked by hand (BOOK-INGEST-AUDIT.md F130; Nate''s ruling of 2026-10-12 leaves skill picks at levels where they are). No R.C.C. Related or Secondary skills are printed. || OCCUPATIONS: the Shaman Note names Healing or Plant Shaman (Spirit West), Elemental Fusionist, Mystic or Psychic; stored as healing-shaman, plant-shaman, both Elemental Fusionist classes, mystic and group:psychic, with group:magic for Magic: None, unless a Magic O.C.C. is selected. The skill swap is a restriction line, not pairing_skills (regression pins its carriers). || EQUIPMENT: belt or bandoleer is bandoleer-with-pouches-and-or-belt-loops. Granted since ~116 and ~117: the waterskin as water-skin-half-gallon and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.) as mraghiile-patchwork-armor; one weapon per W.P. names no item. No money is printed. || NOT STORED: size 3-4 feet plus a tail as long as the body, weight 45-80 pounds, life span 2D4+34 years, slave market value 3D4x1,000 credits, the names Raghiile Climbers, Sequoia Men, Tiger-Squirrel Men and Roggies, habitat, allies and enemies; in GM Notes."
---

## Lore

The M''Raghiile (said "em - rog - HEEL") are small, wiry forest people who live
high in the Sequoia and Giant Redwood forests of the Pacific Coast, with a band
of escaped Horune slaves settled in Dinosaur Swamp. They look part cat and part
monkey: tan fur striped with black, big yellow eyes, tufted lynx ears, a long
snout and a whip-like tail ending in a tuft. All four limbs end in real hands,
each with three fingers and two thumbs, and they swing and leap through the
branches like the most gifted acrobats.

Tribes are small and egalitarian, guided by elders, warriors and shamans, and
live in woven-stick shelters in the treetops on nuts, fruit, eggs, honey and
insects. They distrust outsiders, magic and technology alike, which to them are
the same loud, dangerous thing, and they flee into the canopy rather than
fight, though they fight savagely when cornered.

Most outsiders only ever meet a young M''Raghiile on its "wandering time", a
rite of passage in which youths leave the forest to find themselves before
coming home to a feast and a lifetime with the clan. Their own language of
clicks, purrs and chirps is hard for others to speak, so wanderers often pick
up American, Spanish or Nunnehi. Of their origin they keep only legends of the
"original forests" and the "great lightning" that brought them here.

## GM Notes

Experience: the entry names the Wilderness Scout experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: cheerful, friendly, compassionate and playful, but reserved and
skittish around strangers; fierce once provoked and very loyal to clan, kin
and friends. Many youngsters have wanderlust.

Size 3-4 feet (0.9 to 1.2 m) long, plus a tail as long as the body. Weight
45-80 pounds (20 to 36 kg). Life span 2D4+34 years; mature by 12. Also known
as Raghiile Climbers, Sequoia Men, Tiger-Squirrel Men and Roggies.

Money: little need for it; only young warriors on an adventure tend to carry
credits or trade goods, and they may bring magic or tech weapons home.

Habitat: the Sequoia forests of central and northern California, with scattered
communities in the rainforests of Oregon, Washington, British Columbia and
Dinosaur Swamp. Slave market value 3D4x1,000 credits. Allies: tribal peoples
such as traditional Native Americans, Psi-Stalkers, Druids and Wilderness
Scouts, and anyone who respects them. Enemies: they hate Horune Pirates and
other slavers, and dislike militant peoples such as the Coalition Army and the
Simvan.
',
       updated_at = datetime('now')
 WHERE class_id = 'mraghiile-tree-man'
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0
   AND length(markdown) = 12065;

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
extraction_notes: "WB30 D-Bees of North America printed 210-212 (cache p211-p213, cache page = printed + 1); every number read off a 200 dpi render. Heading Vernulian - Optional Player Character and NPC, printed 211. The entry notes it first appeared in Rifts World Book One: Vampire Kingdoms; this book is the source cited. || CATEGORY: a race that takes an O.C.C.; Experience Level (Military 2D4+1, Refugees 1D8, player characters start at first level) names no ladder, so no xp_table. mdc_base is stated, so no men_of_arms line. || ATTRIBUTES: I.Q. 3D6, M.A. 4D6, M.E. 4D6, P.S. 4D6 (Augmented), P.P. 4D6, P.E. 4D6, P.B. 1D6, Spd 4D6; Augmented is ability text. || M.D.C.: main body 1D6x10 + P.E. and 1D4 per level stored as mdc_base; tentacles 2D6+10 each are ability text. Horror Factor 14. P.P.E. 6D6. || VARIANTS: the book prints two bonus lines. Military: +3 attacks per melee, +1 strike, +4 parry, +3 automatic dodge, +4 entangle, +2 disarm, +4 pull punch, +2 vs Horror Factor, +2 vs poison. Refugees: +2 attacks, +1 Perception Rolls, +2 parry, +2 dodge (not automatic), +2 entangle, +2 vs poison. Save vs poison is toxins_poisons. Stored as two variants, military and refugee; the parent states no bonuses. || PSIONICS: Major Psychic with Telepathy (4), Telekinesis (varies) and Mind Block (4) by name, plus four more from Healing, Sensitive and/or Physical; I.S.P. 1D6x10 plus M.E. and 1D6+1 per level. || SKILLS: Climbing 40+30, Swimming 50+25, Prowl 25+20, W.P. Paired Weapons. One new spoken language each level at +25% is stored as one Language: Other at 50+25 at level one; the later languages are level_progression prose, picked by hand (BOOK-INGEST-AUDIT.md F130; Nate''s ruling of 2026-10-12 leaves skill picks at levels where they are) (judgement: every level read as including the first). || COMBAT: attacks per melee as per Hand to Hand; the Pinning Body Flip, Special Entangle and Constriction moves are special abilities with their printed numbers. || EQUIPMENT: as per O.C.C. The force field collar (160 M.D.C. military, 100 M.D.C. commercial; regenerates 10 an hour; 12 hours a day) is a special ability and, since ~116 and ~117, the rows vernulian-force-field-collar-military and vernulian-force-field-collar-commercial; the class grants neither, because the military collar is the soldiers'' only and about 30% of refugees have the commercial one. Statted items with no catalog row, not stored as gear: the Serpent Power Armor (head 100, tentacles 100 each, main body 300, six underside hover jets 25 each, two main hover jets 75 each, flies to 300 feet, 400 mph, military only) and the Serpent Borg full conversion (P.S. 30, P.P. 26, Spd 50; optional bionic legs biped Spd 88 or quadruped Spd 220; jet pack Spd 365; retractable Vibro-Sword 3D6 M.D. or Vibro-Claws 3D6 M.D.; two tentacle blasters; tail blaster as laser rod with double range and +2D6 M.D.; Medium Infantry body armor 300 M.D.C.; plus 1D4+3 bionic weapons or implants) are GM Notes. || AVAILABLE O.C.C.s: no occ_restrictions; the book allows any and its limits depend on faction (a variant cannot carry occ_restrictions), so they are a restriction line. || NOT STORED: size 2D6+8 feet long, weight 3D4x100 lbs, life span 3D8+76 years, slave market value 2D4x10,000, allies, enemies and habitat are GM Notes."
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
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0
   AND length(markdown) = 11512;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 5 classes carry their new text' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'amana' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F130') > 0)
    OR (class_id = 'squilb' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F130') > 0)
    OR (class_id = 'forest-warden' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F130') > 0)
    OR (class_id = 'mraghiile-tree-man' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F130') > 0)
    OR (class_id = 'vernulian' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F130') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'amana' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0)
    OR (class_id = 'squilb' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0)
    OR (class_id = 'forest-warden' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0)
    OR (class_id = 'mraghiile-tree-man' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0)
    OR (class_id = 'vernulian' AND instr(markdown, 'BOOK-INGEST-AUDIT.md F116, since built') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('amana', 'squilb', 'forest-warden', 'mraghiile-tree-man', 'vernulian') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~187-book-ingest-audit-f130-stepped.sql');
