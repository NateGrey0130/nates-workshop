-- Settle BOOK-INGEST-AUDIT F140's Japan sentences
-- 2 classes, each replaced whole: cyberoid, cyber-samurai.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~214-book-ingest-audit-f140-japan.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F140, row 37d4a: the Japan (WB8) classes, cyberoid and cyber-samurai.
-- Every candidate was tested against Japan's text layer (printed 78-80, 82, 99,
-- 109-113), a render of printed 80, and production's catalog (2026-10-16).
-- Cyberoid, three false and corrected:
-- 1. Its Laws citation spanned printed 99-100; the laws are all on printed 99.
-- 2. Its motorcycle choice offered two rows as the catalog's motorcycles; three
--    Rifts motorcycle rows exist, and road-boss-motorcycle is now offered.
-- 3. Its implant choice omitted Underseas, which printed 109 allows; the
--    catalog's Underseas gills and depth gauge (tagged rifts) are now offered.
--    Underseas' sonar and echo-location are bionics and stay off.
-- Cyber-Samurai, two false and corrected (Nate's ruling of 2026-10-16: a
-- printed page allows it and a rifts or both row exists, so it is granted):
-- 1. Its extraction note said the bionics had no key to grant them. The four
--    bionic features are now a choose-4 over Japan's fifteen bionics rows
--    (printed 111-113), and the five implants a choose-5 over the pool printed
--    109 allows. The Rifts RPG's features and implants have no rows.
-- 2. cyber-samurai-armor, the book's first armor, is now in the armor choice.

-- == cyberoid ==
UPDATE imported_classes
   SET markdown = '---
id: cyberoid
occ_group: optional
men_of_arms: false
name: Cyberoid
system: rifts
source_book: Rifts World Book 8: Japan p.78-79
category: occ
tags: [tech, augmented]
xp_table: [0, 1951, 3901, 8801, 17601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601, 375601]
starting_money: "2d4x1000"
skills:
  hand_to_hand: { costs: { aikido: 2, kendo: 3, karate: 3 } }
  occ_skills:
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints Basic Mathematics." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints Language: Japanese & American (+20%); Japanese is the native tongue at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 70, per_level: 5, note: "American (+20%)." }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "Literacy: Japanese (+20%)." }
    - { choose: 1, from: ["Literacy: Other"], base: 50, per_level: 5, note: "Literacy: American (+20%)." }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Computer Hacking", base: 35, per_level: 5, note: "+20%" }
    - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Computer Repair", base: 35, per_level: 5, note: "+10%" }
    - { name: "Find Contraband", base: 38, per_level: 4, note: "+12%; the book prints Find Contraband, Weapons & Cybernetics." }
    - { name: "Streetwise", base: 32, per_level: 4, note: "+12%" }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "+10%; the book prints Pilot Motorcycle." }
    - { name: "Hand to Hand: Basic Martial Arts/Judo", base: 0, per_level: 0, note: "Can be changed to Aikido for the cost of two other O.C.C. skills, or to Kendo or Karate for the cost of three other skills." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - "Espionage"
      - "Mechanical"
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 8 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Chemistry"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Military: none. Medical: First Aid only. Physical: any except Acrobatics and Boxing. Science: mathematics and chemistry only (+10%). Weapon Proficiencies: any; lean toward modern weapons. A character with an I.Q. under 12 halves every O.C.C. skill bonus."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Chemistry"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 4, count: 2 }
      - { level: 10, count: 2 }
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["at-a11-kuru-street-armor", "ha-4-hiker-body-armor", "ha-5-hiker-body-armor", "concealed-body-armor-mdc"], note: "Only for those involved in crime or adventuring: a suit of light M.D.C. body armor." }
  - { choose: 1, label: "energy weapon", qty: 1, from: ["at-8-laser-pistol", "h-8-laser-pistol-h-brand", "h-10-combat-laser-pistol", "at-30-combat-laser-pistol", "h-13-ion-pulse-pistol", "at-84-sharpshot-laser-rifle", "at-88-combat-laser-rifle", "h-12-defender-ion-pulse-rifle"], note: "Only for those involved in crime or adventuring: an energy weapon." }
  - { item_id: "clothing", qty: 2, note: "A set or two of clothing." }
  - { choose: 1, label: "gas mask or air filter", qty: 1, from: ["gas-mask", "air-filter"] }
  - { item_id: "sunglasses-or-tinted-visor", qty: 1 }
  - { item_id: "hand-held-computer", qty: 2, note: "Two hand-held computers, plus several dozen 4.2 meg disks." }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1, note: "The book prints sleeping pack." }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { choose: 1, label: "motorcycle", qty: 1, from: ["the-highway-man-motorcycle", "the-wastelander-motorcycle", "road-boss-motorcycle"], note: "The book prints only a motorcycle." }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Cybernetics: the book prints a gyro-clock/compass." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Cybernetics: the clock half of the gyro-clock/compass." }
  - { item_id: "universal-headjack-and-ear-implant", qty: 1, note: "Cybernetics: universal headjack and ear implant." }
  - { choose: 5, label: "cybernetic implants of choice (legal or illegal)", qty: 1, from: ["cosmetic-implants", "computer-virus-carrier", "computer-hacker-encoder", "computerized-telephone-jack", "cyberware-networking", "cyber-drone", "data-chip", "depth-gauge-cybernetic", "metal-detector-cybernetic", "power-booster", "radio-chip", "radio-and-scrambler-implant", "signal-booster", "security-clearance-chip", "body-attachments-snaps-hooks-and-velcro", "tracer-chip", "bio-comp-self-monitoring-system", "epidermic-analyzer", "cyber-heat-sensor", "internal-comp-calculator", "macro-eye", "cyber-motion-detector", "multi-system-eye-socket", "pulse-and-pressure-detector", "cyber-radar-sensor", "cyber-radiation-sensor", "stethoscopic-feature", "third-eye-implant", "universal-finger-camera", "universal-finger-jack", "universal-laser-finger-scalpel", "medical-sensor-hand", "ngr-bionic-gills", "ngr-depth-gauge-alarm"], note: "Five cybernetic implants of choice, legal or illegal: cybernetic systems, not military bionics. Printed 109 allows the Rifts RPG, Triax and Underseas implants beside Japan''s; the list is the Japan implants (printed 109-111), the Triax cybernetic implants and the Underseas gills and depth gauge in the catalog. The Rifts RPG implants have no catalog rows, and Underseas'' sonar and echo-location are bionics." }
restrictions:
  - "Cybernetic systems, not military bionics. May consider one bionic limb (with up to three bionic weapons in it), and will readily take cybernetic or bio-system prosthetics, eyes or organs to replace any lost in combat."
side_effects: "A character with an I.Q. under 12 reduces every O.C.C. skill bonus by half (the stored bases carry the full bonus). A full- or part-time job pays a monthly salary of 2500 credits. The character also owns 1D6x1000+10,000 credits'' worth of computer gear, and an inexpensive two-bedroom apartment (one room a computer workshop) with bathroom, kitchen and living room. Successful low-level professional criminals get 1D4x1000 credits more a month plus bonuses or equipment for a job well done. Criminal organizations often lure Cyberoids into implants they cannot afford, then blackmail them over the debt or over illegal cyberware; being caught hardwired to illegal cyberware means a criminal record and removal of the implant (Laws, printed 99)."
extraction_notes: "Rifts World Book 8: Japan printed 78-79 (cache p079-p080; text layer, page_offset +1), both read against renders. The heading opens mid-column on printed 78 under the chapter''s class contents; the stat block runs from printed 78 into the left column of printed 79 and ends at the Cybernetics paragraph at the foot of printed 79''s right column. Printed 80 (cache p081, the page with corrupt glyphs) was rendered: it opens with the Cyber-Samurai O.C.C. and holds nothing of the Cyberoid, so source_book spans 78-79. || XP: the Cyberoid, Republic Infantrymen column, top right of the Experience Point Tables page (cache p217, folio 216), read off a render: 0 / 1,951 / 3,901 / 8,801 / 17,601 / 35,601 / 50,601 / 70,601 / 95,601 / 125,601 / 175,601 / 225,601 / 275,601 / 325,601 / 375,601. The book prints level 8 as 70,600-95,600, the previous band''s upper bound, so 70,601 is stored. || GROUP: optional, men_of_arms false. The book''s heading groups it under Republic of Japan & Mercenaries, and High-Tech O.C.C.s (printed 78) and its contents list names it Cyberoid/Japanese City Rat O.C.C.; it is the Japanese city rat, a hacker and street character rather than a soldier, so it follows city-rat. No S.D.C., hit points or P.P.E. are printed, so the core values apply. || ATTRIBUTES: none required. An I.Q. under 12 halves the O.C.C. skill bonuses: stored at the full bonus and stated in side_effects and the related note. || SKILLS: Basic Electronics 30+10; Basic Mathematics is Mathematics: Basic 45+20; Language: Japanese & American (+20%) is Language: Native Tongue 98 and Language: Other 50+20; Literacy: Japanese & American (+20%) is Literacy: Native Language 40+20 and Literacy: Other 30+20; Radio: Basic 45+20; Computer Hacking 15+20; Computer Operation 40+20; Computer Repair 25+10; Find Contraband, Weapons & Cybernetics is Find Contraband 26+12; Streetwise 20+12; Pilot Motorcycle is Motorcycles & Snowmobiles 60+10. || HAND TO HAND: Basic Martial Arts/Judo; Aikido for two other O.C.C. skills, Kendo or Karate for three. || RELATED: five, plus one at levels 3, 6, 9 and 12. Military: None, so the category is omitted. Science: Mathematics and chemistry only (+10%). W.P.: any, leaning toward modern weapons (advisory, in the note). || SECONDARY: two at each of levels one, four and ten, from the same list without bonuses. || MONEY: savings 2D4x1000 credits. The 2500-credit salary, the 1D6x1000+10,000 in computer gear and the criminal 1D4x1000 a month are not coin on hand, so they are prose. || EQUIPMENT: the armor and energy weapon are printed for those involved in crime or adventuring; offered as choices over light Japanese armor and ArmaTech/H-Brand energy weapons, with the condition in the note. The several dozen 4.2 meg disks have no catalog row and are named in the hand-held computer note. The motorcycle is unspecified; the three Rifts motorcycle rows are offered (BOOK-INGEST-AUDIT F140). || CYBERNETICS: the book prints a gyro-clock/compass, read as the gyro-compass and clock calendar implants, and a universal headjack and ear implant, plus five of choice, legal or illegal. The headjack is the catalog row universal-headjack-and-ear-implant, and equipment_starting lists it. The five are an equipment choice over the catalog''s cybernetic implants from this book, Triax and Underseas, the books printed 109 allows beside the Rifts RPG (Underseas'' gills and depth gauge added under BOOK-INGEST-AUDIT F140); bionic weapons, Underseas'' bionic sonar and echo-location are not offered, and the Rifts RPG implants have no rows. The optional bionic limb is prose in restrictions."
---

## Lore

Nearly half the citizens of the Republic of Japan call themselves Cyberoids: people the Coalition States would call city rats, wired into cyberspace through a host of cybernetic implants. They know computers inside and out, hack networks and communication systems as well as any North American operator, and love video and virtual reality games.

The most extreme spend most of their waking day on-line, gather in self-styled elite clubs and cyber-gangs with shared clothing and painted or tattooed faces, and hold everyone outside the gang at a cool distance. These fringe Cyberoids roam the back alleys and body chop-shops getting "jacked-up" with implants, often illegal or experimental ones.

Their savvy does not keep them out of trouble. The Yakuza, the black market and street gangs goad Cyberoids into cyberware they cannot afford, then pressure or blackmail them into paying it off with crime: hacking, data theft and tampering, industrial espionage, or running and holding contraband, data and money as street soldiers, look-outs, drivers and thieves. A small fraction embrace that life for good and are known on the street as Cyberoid Punks or Cy-Wees.

Many Cyberoids are inquisitive and bright, and some crave adventure, joining mercenaries and adventurers to explore the wilderness, see new things, right injustice or fight demons. Outside a high-tech city, though, they are often fish out of water, and the young ones in particular tend to be overconfident and ill prepared for the magic and war beyond the Republic''s borders.

## GM Notes

Cyberoids use cybernetic systems rather than military bionics, and keep acquiring implants throughout their lives. A character may consider a single bionic limb carrying up to three bionic weapons, and will readily replace lost eyes, limbs or organs with cybernetic or bio-system prosthetics. Illegal cyberware is a standing hook for blackmail and police trouble.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyberoid'
   AND instr(markdown, 'the two catalog motorcycles are offered') > 0
   AND length(markdown) = 12748;

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
  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["cyber-samurai-armor", "ha-5-hiker-body-armor", "ha-7-frontiersman-body-armor", "ha-4-hiker-body-armor", "ha-6-frontiersman-body-armor", "at-a11-kuru-street-armor", "at-a14-infantry-trooper-body-armor", "ia-100-infiltrator-body-armor", "ha-20-juicer-environmental-armor"] }
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
  - { choose: 1, label: "transportation", qty: 1, from: ["riding-horse", "rh-1001a-appaloosa-light-robot-horse", "rh-1002b-mustang-medium-robot-horse", "rh-1003c-arabian-robot-horse", "rh-1004d-war-horse-heavy-robot-horse", "hovercycle", "km-200-jet-pack", "the-highway-man-motorcycle", "the-wastelander-motorcycle", "road-boss-motorcycle"], note: "The book names no robot horse model, so any of the four Bandito Arms models is offered." }
  - { choose: 4, label: "bionic features and accessories", qty: 1, from: ["chest-blaster", "internal-energy-supply", "internal-ammo-drum", "aerial-jet-thrusters", "environmental-upgrade", "h-u-d-visor-bionic", "internal-iv-feed", "palm-energy-generator-ion", "palm-energy-generator-laser", "palm-energy-generator-particle-beam", "palm-energy-generator-plasma-ejector", "palm-energy-generator-stun-blaster", "rebreather-lung", "security-clearance-chip-bionic-top-secret", "underwater-propulsion-bionic"], note: "Four bionic features and accessories of choice from Rifts (pp. 239-243) and/or Rifts Japan. The list is Japan''s bionics (printed 111-113); the Rifts RPG''s have no catalog rows." }
  - { choose: 5, label: "cybernetic implants (no cyber-armor)", qty: 1, from: ["cosmetic-implants", "computer-virus-carrier", "computer-hacker-encoder", "computerized-telephone-jack", "cyberware-networking", "cyber-drone", "data-chip", "depth-gauge-cybernetic", "metal-detector-cybernetic", "power-booster", "radio-chip", "radio-and-scrambler-implant", "signal-booster", "security-clearance-chip", "body-attachments-snaps-hooks-and-velcro", "tracer-chip", "bio-comp-self-monitoring-system", "epidermic-analyzer", "cyber-heat-sensor", "internal-comp-calculator", "macro-eye", "cyber-motion-detector", "multi-system-eye-socket", "pulse-and-pressure-detector", "cyber-radar-sensor", "cyber-radiation-sensor", "stethoscopic-feature", "third-eye-implant", "universal-finger-camera", "universal-finger-jack", "universal-laser-finger-scalpel", "medical-sensor-hand", "cyber-clock-calendar", "cyber-gyro-compass", "universal-headjack-and-ear-implant", "ngr-bionic-gills", "ngr-depth-gauge-alarm"], note: "Up to five cybernetic enhancements of choice, except cyber-armor. Printed 109 allows the Rifts RPG, Triax and Underseas implants beside Japan''s; the list is the Japan implants (printed 79 and 109-111), the Triax cybernetic implants and the Underseas gills and depth gauge in the catalog. The Rifts RPG implants have no catalog rows." }
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
side_effects: "Money: 2D6 x 1000 credits, plus 2D4 x 1000 credits in salable Black Market items. An employed samurai may draw a stipend or salary of 1D4 x 1000 credits a month, which may rise as he gains favor with his daimyo, corporation or government. Transportation may instead be another similar open vehicle. About 10% of cyber-samurai own a true, ancient pre-Rifts samurai sword (a powerful rune weapon) and 15% a true samurai sword of recent make and lesser power (see the True Samurai O.C.C.); the rest rely on vibro-blades, energy weapons and modern gear."
extraction_notes: "Rifts World Book 8: Japan printed 80-82 (cache p081-p083, a text layer, page_offset +1). The entry opens on printed 80 under the section heading Republic of Japan & Mercenaries, and High-Tech O.C.C.s; printed 80 (cache p081) carries corrupt glyphs, so every number on it was read off a 200 dpi render. Printed 81 (cache p082) has no text (an illustration). The stat block (The False Cyber or Tech-Samurai O.C.C.) starts on printed 80 and continues on printed 82 from Electrical: Any through Money and Cybernetics: See above, after which printed 82 opens the Tech-Ninja O.C.C. || XP: the Cyber-Samurai column on printed 216 (cache p217), read off a render: 0 / 2,101 / 4,201 / 8,401 / 17,201 / 25,401 / 35,801 / 51,001 / 71,201 / 96,401 / 131,601 / 181,801 / 232,001 / 282,201 / 342,401. || GROUP: men-of-arms and men_of_arms: true, from the section heading (Mercenaries and High-Tech O.C.C.s) and the warrior text; the class states an M.D.C. main body of 180 as mdc_base. || ATTRIBUTES: requirements M.E. and M.A. 10; the book says the bionics CHANGE P.S. to 22, P.P. to 18 and Spd to 50. Stored as attribute_minimums, a floor: a natural roll above those figures is not lowered, which the book''s ''changed as follows'' would do. || SKILLS: Basic Radio is Radio: Basic 45+10; Basic Math is Mathematics: Basic 45+10; Language and Literacy: Japanese at 98% is Language: Native Tongue 98 and Literacy: Native Language at a flat 98; Language: American is a one-pick Language: Other at +10 (the catalog has no American row; a fixed Language: Other reads as a missing selection); Computer Programming 30+10; Horsemanship is Horsemanship: General 40+20; Wilderness Survival 30+5; Piloting two of choice +10% as a choose-2 over Pilot; W.P. Archery and Targeting as the two catalog rows W.P. Archery and W.P. Targeting. || HAND TO HAND: Karate or Jujitsu, as a choose-1. Zanji Shinjinken-Ryo at the cost of two other skills, priced in the hand_to_hand block. The book also sells Samurai Archery (in place of Archery and Targeting) for two other skills; there is no Samurai Archery catalog row, so that trade is prose in the W.P. Archery note. || RELATED: six, plus one at levels 3, 6, 9 and 12. Science Astronomy and Mathematics only, read as Astronomy and both Mathematics rows. || SECONDARY: the book prints three secondary skills at levels 1, 4, 8 and 12, read as three at each of those levels (the same reading the other Japan drafts give this sentence). || BIONICS: the four bionic features are an equipment choose-4 over Japan''s bionics rows (printed 111-113; the Rifts RPG''s pp. 239-243 have no rows), and the five cybernetic implants a choose-5 over the Japan, Triax and Underseas implant rows, the pool printed 109 allows, with no cyber-armor among them (BOOK-INGEST-AUDIT F140); the abilities keep the prose. || EQUIPMENT: the book''s first armor is a high-tech Samurai mega-damage body armor of 1D6x10+60 M.D.C., the catalog row cyber-samurai-armor (samurai-armor is the True Samurai''s magic armor), offered first in the choice (BOOK-INGEST-AUDIT F140); then come the samurai-styled HA-5 and HA-7 and other Japan armor, per the book''s ''or one of the other types of armor available in Japan''. Ten high-tech arrows of choice are one choice of arrowhead type, quantity 10. The energy weapon of choice is offered from the Japan pistols and rifles. 1D4 E-clips as the generic e-clip row, since the matching pistol or rifle clip depends on the weapon. Two vibro-blades or ancient weapons as a choose-2. The S.D.C. daisho is daisho-rifts. Transportation: horse, robot horse, hovercycle, jet pack or one of three motorcycles as a choice (BOOK-INGEST-AUDIT F139). The book names no robot horse model, so the choice offers all four Bandito Arms models (Rifts World Book 14: New West p.196-200), each through a gear row pointing at its vehicles row (Nate''s ruling, 2026-10-15). The book''s similar open vehicle is prose. Ammo pouches are in the utility belt note. Money: 2D6x1000 credits stored; the Black Market items and the monthly salary are prose."
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
   AND instr(markdown, 'with no key to grant them') > 0
   AND length(markdown) = 14362;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'cyberoid' AND instr(markdown, 'ngr-depth-gauge-alarm') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, 'chest-blaster') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'cyberoid' AND instr(markdown, 'the two catalog motorcycles are offered') > 0)
    OR (class_id = 'cyber-samurai' AND instr(markdown, 'with no key to grant them') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('cyberoid', 'cyber-samurai') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~214-book-ingest-audit-f140-japan.sql');
