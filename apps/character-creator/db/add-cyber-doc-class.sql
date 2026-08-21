-- The Cyber-Doc O.C.C., Rifts Ultimate Edition p.89-90.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-cyber-doc-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-cyber-doc-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'cyber-doc', 'Cyber-Doc', 'rifts', '---
id: cyber-doc
name: Cyber-Doc
system: rifts
source_book: Rifts Ultimate Edition p.89-90
category: occ
attribute_requirements:
  IQ: 11
  PP: 12
bonuses:
  attributes: { ME: 1, PP: 2 }
  saves: { horror_factor: 4, pain: 2 }
skills:
  occ_skills:
    - { name: "Literacy: Native Language", base: 40, per_level: 0, note: "(+40%)" }
    - { name: "Language: Native Tongue", base: 96, per_level: 0 }
    - { choose: 1, categories: ["Communications"], base: 20, per_level: 0, note: "Language: Other, one of choice (+20%)." }
    - { name: "Mathematics: Advanced", base: 10, per_level: 0, note: "(+10%)" }
    - { name: "Mathematics: Basic", base: 30, per_level: 0, note: "(+30%)" }
    - { name: "Basic Mechanics", base: 20, per_level: 0, note: "(+20%)" }
    - { name: "Basic Electronics", base: 15, per_level: 0, note: "(+15%)" }
    - { name: "Biology", base: 20, per_level: 0, note: "(+20%)" }
    - { name: "Chemistry", base: 10, per_level: 0, note: "(+10%)" }
    - { name: "Computer Operation", base: 5, per_level: 0, note: "(+5%)" }
    - { name: "Find Contraband", base: 10, per_level: 0, note: "(+10%)" }
    - { name: "Medical Doctor", base: 60, per_level: 5 }
    - { name: "M.D. in Cybernetics", base: 10, per_level: 0, note: "(+10%)" }
    - { name: "Pathology", base: 10, per_level: 0, note: "(+10%)" }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Special bonus of +1 to strike." }
    - { choose: 1, from: ["Hand to Hand: Basic", "Hand to Hand: Expert"], base: 0, per_level: 0, note: "Can be selected as an O.C.C. Related skill: Basic counts as one skill selection or Expert as two." }
  occ_related_skills:
    count: 9
    categories: ["Technical", "Communications", "Domestic", "Electrical", "Espionage", "Medical", "Mechanical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Weapon Proficiencies", "Wilderness"]
    note: "At least two must be selected from Technical. Communications: any except Cryptography and Performance. Cowboy: none. Domestic: any. Electrical: any (+5%). Espionage: none. All new skills start at level one proficiency."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 1 }
special_abilities:
  - name: "Install Bionics"
    description: "A Cyber-Doc can install and remove cybernetic implants and bionics, but requires at least a makeshift operating room. Cybernetic implants are fast and easy (no skill penalty), but bionics are very complicated and demanding on the character''s time and skill. Penalties: -5% to Cyber-Doc skill to remove bionics or any prosthetic, -5% if working in poor conditions, another -5% if working with inadequate tools, -10% if the bionics are more advanced or a different but comparable technology than what he is familiar with, -20% when dealing with extremely alien physiology and/or alien cybernetics. All penalties are accumulative. A consummate pro, if there is any penalty for working under pressure or on a time limit, it should be reduced by half. Taking the M.D. in Cybernetics skill twice eliminates (or reduces by half) most penalties."
  - name: "Find Bionics and Cybernetics Contraband"
    description: "+20% to Find Contraband related to medicine, cybernetics and bionics. This bonus is added to his normal Find Contraband skill whenever cybernetics or bionics are involved. Gets bionics, cybernetics and Bio-Systems at wholesale - 35% discount as professional courtesy at most Body-Chop-Shops and clinics, 50% discount if he trades at least 12 hours of his time to work at the Shop or clinic for free. Every 12 hours he puts in, he can get up to 100,000 credits worth of cyber-gear for half-off (that''s 50,000 credits, his cost). 60% discount if the character is the owner or a partner in a Body-Chop-Shop or medical clinic in the Cyber-Doc''s own home town/place of residence."
  - name: "Recognize Quality of Bionics & Cybernetics"
    description: "An exclusive skill that enables the Cyber-Doc to tell if an item is new or used, defective, low or high quality, and a fair price. He will automatically know the capability (damage, range, payload, etc.) of bionic weapons and prosthetics (M.D.C., P.S., Speed, etc.) and whether it''s exactly what he needs or not. Base Skill: 60% +3% per level of experience."
  - name: "Repair and Soup-Up Bionics: Repairs for Cheap"
    description: "Can completely repair bionics and cybernetics at a cost of 25% of its original list price (plus his time if he''s charging for it; typically another 25%). Requires the right parts and 1D6+2 hours to work on each item (hand, arm, shoulder, one forearm weapon, then another, etc.)."
  - name: "Replace M.D.C."
    description: "On a bionic appendage, main body, and cyber-armor at a cost of 1000 credits per every one M.D.C. point restored. Cannot exceed the original M.D.C. amount."
  - name: "Maximize Bionics (not cybernetics)"
    description: "Can tweak bionic systems to get a little more out of them. Can increase Spd 20%, P.S. 10%, increase range 10% (of weapons, transmissions, sensors, etc.), reduce size and weight of a specific item by 10%, and add ONE extra weapon or feature per each body area (head, hand, forearm, shoulder, foot, leg, chest, back)."
restrictions:
  - "No O.C.C. bonus to Medical Doctor skill for treating mundane disease, illnesses and minor injury; the Cyber-Doc''s expertise lies in surgery and cybernetics, not general practice."
  - "Cyber-Docs who treat D-Bees are black-listed and marked for death as ''traitors to humanity'' by the Coalition States."
extraction_notes: |
  - Racial Requirements state "None; about 30% are D-Bees" ' || char(8212) || ' recorded as prose
    under Lore/GM Notes context rather than a schema field, since there is no
    numeric racial restriction to encode.
  - "-10% penalty on the Doc when interrogation involves torture" from the
    O.C.C. Bonuses line is conditional/narrative and not a flat combat/save
    bonus, so it is left as prose rather than forced into bonuses.saves.
  - Equipment, money, and cybernetic implant starting details are described in
    prose on page 89 (S.D.C. knife, energy pistol/rifle choices, E-Clips,
    tools, vehicle) but are not itemized with specific catalog choices in the
    text, so equipment_starting was omitted rather than guessed.
  - Money: starts with 6D6x100 credits and a Black Market item worth 3D4x1000
    credits ' || char(8212) || ' this appears on the City Rat entry on the same page spread, not
    the Cyber-Doc; the Cyber-Doc entry itself does not state a starting money
    formula, so starting_money is omitted.
---

## Lore

The Cyber-Doc is a cybernetics specialist who offers his illegal services on the Black Market, not unlike the old abortion clinics of 1950s and 60s America. The Doc can be well-trained, well-meaning, and professional, or he can be an opportunist and/or a butcher. Since the operations are illegal, the patient has little say about the success or failure of the surgery. Medical treatment and authorized bionics is generally reserved for the military, political leaders, and the wealthy. Comparable cybernetics and bionics for the underprivileged are available at Black Market clinics and are always seem to be in unbelievably high demand. This demand is what has spawned the cut-rate, Black Market clinics known as "Body-Chop-Shops." Filthy, crude facilities operated by the most nefarious underworld malefactors one can find.

The proprietors of these "Chop-Shops" pay fair prices (20% to 40% of list) for cybernetics and bionic "parts" and components ' || char(8211) || ' no questions asked. This has led to the creation of gruesome underworld criminals known as Cyber-Snatchers. Fiends who attack, and steal bionics and cybernetics, pulling and chopping the artificial limbs or implants out of their victim for resale at a Body-Chop-Shop. Perhaps needless to say, the victim is usually maimed or killed in the process.

On the flip side, not all Cyber-Docs are evil or butchers. True professionals are experts in cybernetics and surgical wizards able to blend flesh and machine into something amazing. The Cyber-Doc player character is, presumably, one of the good guys. A healer who uses his unique gifts and knowledge to help the less fortunate and to empower freedom fighters, mercenaries or adventurers with muscles of steel. The Cyber-Doc is versed in all aspects of cybernetics, skin grafting, organ transplant, artificial organ replacement, robot prosthetics, cybernetic implants, and bionics, as well as internal medicine, neurology, and cybernetic theory and mechanics. The focus on cybernetics is surgery and grafting, so the Cyber-Doc is an expert surgeon, but not so good as a general practitioner or in recognizing and treating more mundane disease, illnesses and minor injury (no O.C.C. bonus to Medical Doctor skill). But ask him to replace a lost limb with a bionic one, or a heart or eye, and he can do it in record time with no complications. His expertise in cybernetics means he can also remove and install all forms of cybernetic and bionic devices, as well as work on the machine parts, to service, clean, repair and even build them from scratch, provided he has the right parts and access to the proper facility and equipment; even a Body-Chop-Shop or mechanic''s garage will do.

A Cyber-Doc is part mechanic, part surgeon and part medical doctor. Someone who can help the crippled to walk, the blind to see and maimed to feel whole again. Cyber-Docs who treat D-Bees are black-listed and marked for death as "traitors to humanity" by the Coalition States, just like the Body Fixer. Since he''s already a wanted man, many Cyber-Docs deal in stolen Coalition bionics and encourage raids on CS facilities. However, more often than not, the bionics are secondhand (don''t ask), acquired from a merc, bandit or adventurer, or as a deal at a Black Market Body-Chop-Shop. Reputable Cyber-Docs often offer their services to the Black Market in exchange for bionics and cybernetics at wholesale prices (50% below list price).

A Cyber-Doc may be an independent operative or hooked up with a medical team, mercenary outfit, adventure group, or freelance for a town or army. Like the Body-Fixer, the Cyber-Doc is usually considered a rogue, malcontent and outlaw by the CS. However, to those in the wastelands, the Cyber-Doc (or any man of medicine) is a miracle worker and a godsend. Note: In the aftermath of Tolkeen''s fall, Cyber-Docs are in high demand to give the maimed and injured a new lease on life via cybernetic medicine. The Coalition Army knows this, and has made a point to track down rebel field hospitals and gun down all "criminals and rebels consorting with the enemy" along with the D-Bee enemy.

## GM Notes

Use the Install Bionics penalty stack to make field surgery tense ' || char(8212) || ' poor conditions, inadequate tools, and unfamiliar tech all stack, and a time-pressured job halves the total penalty rather than removing it. The 60%/50%/35% wholesale discounts and the free-labor-for-credit exchange give the Cyber-Doc real economic leverage in a campaign, particularly for outfitting a mercenary company or resistance cell with black-market cyber-gear. Torture-based interrogation of a captured Cyber-Doc carries a narrative -10% penalty on the character rather than a hard save modifier ' || char(8212) || ' handle it as a roleplaying/skill circumstance rather than an automatic combat bonus.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'cyber-doc');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'cyber-doc';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-cyber-doc-class.sql');
