-- The Sovietski Police Officer, reconciled with Rifts World Book 36: Sovietski printed 98-101.
-- 1 class, each replaced whole: sovietski-police-officer.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-sovietski-police-officer-wb36.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The Sovietski Police Officer, reconciled with its revised block in Rifts World
-- Book 36: Sovietski printed 98-101 (Police Officer O.C.C., Revised and
-- Expanded). The class shipped from Rifts World Book 17: Warlords of Russia
-- printed 210-212 (add-sovietski-police-officer-class.sql, left as it is; this
-- file sorts after it). Ruling 2026-10-04: the newest printing that states a
-- figure wins, so WB36's block replaces WB17's wherever they differ: race none,
-- +2 I.Q. and M.A., +1 initiative, +1 dodge, +2 save vs psionics and insanity,
-- Literacy +20%, Crime Scene Investigation and Law, Hovercycles +9%, the OVB and
-- KSSI branches in place of the seven WB17 MOS options, one secondary skill at
-- levels 2, 4, 8 and 12, and the WB36 kit. The XP ladder is the same in both
-- books. The class keeps its id and its WB17 citation; the extraction notes
-- record the reconciliation item by item.

-- == sovietski-police-officer ==
UPDATE imported_classes
   SET markdown = '---
id: sovietski-police-officer
name: Sovietski Police Officer
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.210-212
category: occ
tags: [combat]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
attribute_requirements: { IQ: 9, PS: 9, PE: 10 }
hit_points_base: "P.E. + 1d6 per level"
bonuses:
  attributes: { IQ: 2, MA: 2 }
  combat: { initiative: 1, strike: 1, parry: 1, dodge: 1, pull_punch: 2 }
  saves: { horror_factor: 1, psionics: 2, insanity: 2 }
  pools: { sdc: "2d6+10" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Language: Russian at 98%." }
    - { choose: 1, from: [{ name: "Language: Euro", bonus: 20 }, { name: "Language: Other", bonus: 15 }], note: "Language: Euro (+20%) or Language: one of choice (+15%), pick one." }
    - { name: "Literacy: Russian", base: 50, per_level: 5, note: "+20%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Crime Scene Investigation", base: 50, per_level: 5, note: "+15%; only Literacy is required." }
    - { name: "Law", base: 60, per_level: 5, note: "Printed Law (General), +25%." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Military Etiquette", base: 45, per_level: 5, note: "+10%" }
    - { name: "Hovercycles, Skycycles & Rocket Bikes", base: 79, per_level: 3, note: "+9%, as printed." }
    - { name: "Motorcycles & Snowmobiles", base: 72, per_level: 4, note: "+12%" }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { choose: 1, from: ["Swimming", "Roadwise"], bonus: 10, note: "Swimming or Roadwise (+10%), pick one." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Trick Shooting (choice of only one Trick Shooting skill) or one W.P. of choice (any)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for one O.C.C. Related Skill, or to Martial Arts (or Assassin if evil) for two. Hand to Hand: Commando is not available." }
  mos:
    choose: 1
    note: "Police branch, chosen at creation and never changed: the Division of Domestic Security (OVB), which most officers belong to, or the Party''s Committee for the Preservation of Soviet Ideals (KSSI). Each grants its notable skills."
    options:
      - id: "ovb"
        name: "Division of Domestic Security (OVB)"
        skills:
          - { name: "Find Contraband", base: 36, per_level: 4, note: "+10%" }
          - { name: "I.D. Undercover Agent", base: 40, per_level: 4, note: "+10%" }
          - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
          - { name: "Tailing", base: 45, per_level: 5, note: "+15%" }
      - id: "kssi"
        name: "Committee for the Preservation of Soviet Ideals (KSSI)"
        skills:
          - { name: "Impersonation", base: 45, per_level: 4, note: "+15%" }
          - { name: "Intelligence", base: 47, per_level: 4, note: "+15%" }
          - { name: "Interrogation", base: 45, per_level: 5, note: "+15%" }
          - { name: "Surveillance", base: 40, per_level: 5, note: "+10%" }
          - { name: "Undercover Ops", base: 50, per_level: 5, note: "+20%" }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"], bonus: 5 }
      - { name: "Military", only: ["Demolitions", "Forced March"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Flight System Combat"], bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", only: ["Computer Hacking", "Cardsharp", "Seduction"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies", except: ["W.P. Trick Shooting"] }
    note: "Pick four other skills at level one. Communications: any (+10%). Cowboy: none. Domestic: any. Electrical: none. Espionage: any. Horsemanship: none. Mechanical: Automotive and Basic only. Medical: First Aid and Paramedic only (+5%). Military: Demolitions and Forced March only (+5%). Physical: any, except Acrobatics. Pilot: any except Robots or Power Armor (+5%). Pilot Related: any (+5%). Rogue: Computer Hacking, Cardsharp and Seduction only. Science: any (+5%). Technical: any (+10%). W.P.: any, except an additional Trick Shooting skill. Wilderness: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 0
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Military", only: ["Demolitions", "Forced March"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Rogue", only: ["Computer Hacking", "Cardsharp", "Seduction"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Trick Shooting"] }
    note: "One Secondary Skill (Rifts Ultimate Edition list, printed 300) at each of levels 2, 4, 8 and 12, at base percentage only. None at level one."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - name: "Contacts"
    description: "An OVB officer starts with 2D4 contacts in his city (New Moscow, New Leningrad, Kaliningrad, Kurlensk or the Volga Fortress) and 1D4 in the towns and village districts around it, reaching into rival political groups, dissidents, Warlord camps, the Black Market, the wider underworld and business. Add 1D4 more at levels 3, 6 and 9. A KSSI officer''s contacts are instead in the Communist Party, other political circles, business and one or two religious enclaves."
  - name: "Police Instincts"
    description: "+2 on Perception Rolls involving crime, criminal activity and contraband, and +2 to save vs torture. Neither is added to the sheet."
  - name: "Cybernetic and Bionic Augmentation"
    description: "Roll percentile or pick. 01-20: human, no bionics, 1D4+1 cybernetic implants. 21-50: partial cyborg package, 55-65% of the body: one headjack and one finger jack, Cyberlink Vehicle Interface, two sensor or communication implants of choice, reinforced endo-skeleton (15 M.D.C.), full leg conversion (Spd 45, 30 mph; leaps 10 ft high or 12 ft long from a standstill, double with a short run; 60 M.D.C. per leg, 15 per foot), one bionic arm (40 M.D.C.) and hand (12 M.D.C.) with two weapons each, P.S. and P.P. 18 in that arm, and a gas filter and oxygen storage cell. 51-75: cyborg package, 66-80% of the body: a headjack and ear implant or a handjack, Cyberlink Vehicle Interface, four sensor or communication implants of choice, bionic body frame and full torso (65 M.D.C.), full leg conversion (Spd 50, 35 mph; leaps 10 ft high or 15 ft long from a standstill, double with a short run; 80 M.D.C. per leg, 25 per foot), two bionic arms (40 M.D.C. each) and hands (18 M.D.C.) with three weapon systems each, P.S. and P.P. 20, a gas filter and oxygen storage cell, and a bionic or reinforced skull with a language translator and radio. 76-98: full conversion cyborg, the Proletariat Light Machine (sovietski-proletariat-light-machine) or the Heavy Machine (sovietski-heavy-machine-combat-cyborg); most police are Light Machines with a human face. 99-00: a Cyber-Humanoid, a light full conversion cyborg under Bio-System skin, top secret even from fellow officers, used for undercover, S.W.A.T. and V.I.P. protection work, with the Cyberlink Vehicle Interface."
equipment_starting:
  - { item_id: "sovietski-sa-107h-red-star-infantry-armor", qty: 1, note: "Standard Red Star body armor with police markings." }
  - { item_id: "e-clip", qty: 4, note: "Four E-Clips for each weapon; these four are one weapon''s." }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1, note: "Small silver-plated knife, 1D6 S.D.C." }
  - { item_id: "stun-flash-grenade", qty: "1d4", note: "1D4 stun/flash grenades." }
  - { item_id: "flare", qty: 2 }
  - { item_id: "small-silver-cross", qty: 1, note: "Pocket-sized silver cross." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1, note: "The book says distancing binoculars." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "gun-holster", qty: 1, note: "Holster for the side arm." }
  - { choose: 1, label: "backpack or duffle bag", qty: 1, from: ["backpack", "duffle-bag"] }
trackable_resources: []
restrictions:
  - "Alignment: any, though very few police are evil."
  - "Attribute requirements: I.Q. 9, P.S. 9, P.E. 10 or higher. A high M.A. and M.E. are helpful, but not a requirement."
  - "Race: none."
  - "Equipment beyond the starting list: Military I.D. and ration card, one weapon per W.P. with four E-Clips each; detectives and KSSI officers also get a tailored black suit, long coat, scarf, fine leather gloves and dress boots. A cyborg officer also gets the ammunition, equipment and armor for its body and weapon systems, with regular maintenance and repairs."
  - "Money: starts as a Private on 1,100 credits a month, plus a 1,000 credit monthly stipend for housing, transport and meals; no starting sum is printed."
extraction_notes: "WB17 Warlords of Russia printed 210-212 (cache p211-p213, cache page = printed folio + 1), read off the text layer; RECONCILED against the revised block in Rifts World Book 36: Sovietski printed 98-101 (Police Officer O.C.C., Revised and Expanded; cache p098-p101, cache page = printed folio + 0), whose figures replace WB17''s wherever they differ (ruling 2026-10-04: the newest printing that states a figure wins). The class keeps its id and its WB17 citation; the WB36 block is read as superseding the WB17 stat block whole, so what WB36 drops is dropped. || HEADING: WB36 heads it Police Officer O.C.C. and the stats Sovietski Police Officer O.C.C. Stats (printed 100); occ_group men-of-arms and men_of_arms true kept. || XP: WB36''s Experience Tables (printed 224, cache p220) print one ladder for Sovietski Police Officer, Gridgitz and Infantry Soldier, identical to the WB17 ladder stored. || CHANGED FROM WB17: race none (was exclusively human); bonuses now +2 I.Q. and M.A., +1 initiative (was +3), +1 strike, parry and dodge (dodge new; the +1 disarm is gone), +2 pull punch, +2 save vs psionics and insanity; +2D6+10 S.D.C. and the Horror Factor ladder (+1 at 1, 3, 6, 9 and 12) unchanged. Skills: Literacy: Russian +20% (was a flat 90%); Euro OR another language (was both); Crime Scene Investigation and Law (General), the catalog''s Law, added; Hovercycles at +9% as printed (render checked, was +10%); Swimming or Roadwise (was Swimming); Trick Shooting or one W.P. (was both); W.P. Paired Weapons and the free Pilot pick gone. The seven WB17 MOS options are replaced by the WB36 police branch (OVB or KSSI), each granting its Notable Skills, stored as two mos options. Related: Medical is First Aid and Paramedic, Military is Demolitions and Forced March, Pilot excludes robots and power armor. Secondary: one at levels 2, 4, 8 and 12 (was two at 2, 4, 8 and 13). Assassin needs an evil alignment (was anarchist or evil); Commando is not offered. Equipment: Red Star armor is the WB36 SA-107H row (was the WB17 medium row); flashlight and gun holster added; the signal mirror and the WB17 motorcycle are gone. Money: WB36 prints a salary and stipend, stored as prose; no starting_money. || NOT ON THE SHEET: +2 Perception on crime matters and +2 save vs torture are prose (Police Instincts). Contacts and the bionics table are special_abilities prose; the full conversion bodies are the vessel rows named there. || EQUIPMENT not stored as rows: weapons per W.P., the I.D. and ration card, detective clothing."
---

## Lore

The Sovietski police are a branch of the Red Army itself. Like the military
they may search homes and businesses, make arrests and investigate crime; the
difference is jurisdiction. Police guard the cities, towns and settlements,
each city''s force answering to a regional headquarters in the nearest fortress
city, while the army handles national defense. Police carry much the same
weapons, vehicles and cyborg bodies as the army, short of Superheavy cyborgs,
tanks and heavy weapons, and call on the Red Star Reserve or hand the whole
case to the military when a job is too big.

Most officers serve in the Division of Domestic Security (OVB): street cops,
desk officers, detectives and SWAT teams who know the police and army
hierarchy and the many dangers facing Sovietski citizens. A small branch, the
Party''s Committee for the Preservation of Soviet Ideals (KSSI), under 5% of
the force, watches votes, permits, contacts and foreign influence, and acts as
internal affairs. It answers to the Party, not the police chain of command,
which makes it unpopular and dangerous to question.

## GM Notes

The branch is picked at creation and cannot change. OVB notable skills: Find
Contraband, I.D. Undercover Agent, Recognize Weapon Quality, Tailing. KSSI
notable skills: Impersonation, Intelligence, Interrogation, Surveillance,
Undercover Ops.

Contacts are a source of leads and plots: feed the player intelligence a piece
at a time.

On assignment: any vehicle the officer is trained for, aircraft, hover
vehicles, more weapons and E-Clips, a medical kit, a portable computer and
language translator, cameras, surveillance gear, explosives (fusion blocks
included), an air filter and gas mask, and access to police facilities,
computers and back-up. Availability depends on the commander, stock, location,
casualties and combat conditions.

Many officers choose sensory and weapon implants; the Gromeko Friend or Foe
Identification Computer (gromeko-friend-or-foe-identification-computer) is a
favourite for spotting undercover operatives and picking targets near
civilians.

The save vs Horror Factor rises by +1 at levels 3, 6, 9 and 12.
',
       updated_at = datetime('now')
 WHERE class_id = 'sovietski-police-officer'
   AND instr(markdown, 'race_restrictions: { only: ["none"], note: "Exclusively human." }') > 0
   AND length(markdown) = 14012;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-police-officer' AND instr(markdown, 'Committee for the Preservation of Soviet Ideals (KSSI)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-police-officer' AND instr(markdown, 'race_restrictions: { only: ["none"], note: "Exclusively human." }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('sovietski-police-officer') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-sovietski-police-officer-wb36.sql');
