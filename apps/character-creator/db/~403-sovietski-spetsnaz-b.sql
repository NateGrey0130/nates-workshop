-- The Spetsnaz Intel O.C.C., second half, from Rifts World Book 36: Sovietski printed 120-124.
-- 1 class, each replaced whole: sovietski-spetsnaz-intel.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~403-sovietski-spetsnaz-b.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The Spetsnaz Intel O.C.C.'s second half, from Rifts World Book 36: Sovietski
-- printed 120-124. The class shipped with its first five M.O.S. bundles
-- (add-sovietski-spetsnaz-intel-class.sql, left as it is; this file sorts after
-- it). This replaces the class whole to add the other eleven M.O.S. bundles and
-- fourteen Trainings: Immersion/Deep Undercover, Insurgency, Liquid Affairs,
-- Mage/Spell Caster, Partial Cyborg, Procurement Specialist, Psychic Assassin,
-- Psychic Interrogator, Psychic Spy and Psychic Special Forces. The magic and
-- psychic Trainings pick from held spells and powers, no new rows (ruling
-- 2026-11-22).

-- == sovietski-spetsnaz-intel ==
UPDATE imported_classes
   SET markdown = '---
id: sovietski-spetsnaz-intel
name: Sovietski Spetsnaz Intel
system: rifts
source_book: Rifts World Book 36: Sovietski p.115-124
category: occ
tags: [stealth, combat]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
attribute_requirements: { IQ: 12, ME: 10, MA: 11 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Russian", base: 70, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Language: Euro", "Language: Chinese"], bonus: 15, note: "Language: Euro or Chinese (+15%), pick one." }
    - { name: "Literacy: Russian", base: 45, per_level: 5, note: "+15%" }
    - { name: "Computer Operation", base: 55, per_level: 5, note: "+15%" }
    - { name: "Contacts - Social Connections", base: 20, per_level: 2, note: "Printed Contacts (+10%); an M.O.S. may add more." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%; an M.O.S. may add more." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Military Etiquette", base: 45, per_level: 5, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 65, per_level: 5, note: "Printed Pilot: Hover Craft (Ground, +15%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 15, note: "Pilot: one of choice (any, +15%)." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%; an M.O.S. may add more." }
    - { name: "Surveillance", base: 40, per_level: 5, note: "+10%; includes Tailing. An M.O.S. may add more." }
    - { choose: 1, from: ["W.P. Handguns", "W.P. Energy Pistol"], note: "W.P. Handguns or W.P. Energy Pistol, pick one." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Commando and Assassin come only with certain M.O.S. bundles." }
  mos:
    choose: 1
    note: "O.C.C. Related Skills: instead of the usual elective skills, ONE Spetsnaz M.O.S. bundle, and the Training ability of the same name, which carries its bonuses. Skill bonuses are cumulative with the O.C.C. Skills. The Partial Cyborg and the Major Psychic Special Forces print no M.O.S. skills: take the Training alone (a Major Psychic Special Forces adds 1D4+3 skills from its own Psyscape O.C.C., with the GM). A psychic M.O.S. has a Training for each tier; the Psychic Assassin has one for each psionic path."
    options:
      - id: airborne-deployment-specialist
        name: "Airborne Deployment Specialist"
        skills:
          - { choose: 1, categories: ["Physical"], note: "Acrobatics (+10%) or one Physical skill of choice; the +10% is Acrobatics'' only." }
          - { name: "Astronomy & Navigation", base: 40, per_level: 5, note: "+10%" }
          - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
          - { name: "Parachuting", base: 60, per_level: 5, note: "+20%" }
          - { name: "Jet Packs", base: 62, per_level: 4, note: "Printed Pilot: Jet Pack (+20%)." }
          - { name: "Military: Combat Helicopter", base: 62, per_level: 3, note: "Printed Pilot: Military Helicopter (+10%)." }
          - { choose: 1, from: [{ name: "Rope Works", bonus: 15 }, "Boxing"], note: "Rope Works (+15%) or Boxing, pick one." }
          - { name: "Running", base: 0, per_level: 0 }
          - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
          - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
          - { choose: 1, from: ["Hand to Hand: Commando", "Hand to Hand: Assassin"], note: "Replaces Hand to Hand: Martial Arts; pick one." }
      - id: commando
        name: "Commando"
        skills:
          - { name: "Boxing", base: 0, per_level: 0 }
          - { choose: 1, categories: ["Physical"], note: "Wrestling or one Physical skill of choice." }
          - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
          - { name: "Demolitions", base: 80, per_level: 3, note: "+20%" }
          - { name: "Interrogation", base: 50, per_level: 5, note: "+20%" }
          - { choose: 1, from: [{ name: "Motorcycles & Snowmobiles", bonus: 20 }, "Military: Tanks & APCs"], note: "Pilot: Motorcycles and Snowmobiles (+20%) or Tanks and APCs, pick one." }
          - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
          - { name: "Running", base: 0, per_level: 0 }
          - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
          - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
          - { choose: 1, categories: ["Weapon Proficiencies", { name: "Espionage", only: ["Sniper"] }], note: "W.P.: one of choice (any) or Sniper, pick one." }
          - { name: "Hand to Hand: Commando", base: 0, per_level: 0, note: "Replaces Hand to Hand: Martial Arts." }
      - id: cyber-humanoid
        name: "Cyber-Humanoid"
        skills:
          - { name: "Disguise", base: 45, per_level: 5, note: "+20%. In place of an M.O.S. skill package the agent gets this and a light, concealed full conversion cyborg body (Training: Cyber-Humanoid)." }
      - id: electronic-intelligence
        name: "Electronic Intelligence"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
          - { name: "Computer Hacking", base: 30, per_level: 5, note: "+15%" }
          - { name: "Electronic Countermeasures", base: 50, per_level: 5, note: "+20%" }
          - { name: "Laser Communications", base: 50, per_level: 5, note: "+20%" }
          - { name: "Optic Systems", base: 45, per_level: 5, note: "+15%" }
          - { name: "Pick Locks", base: 50, per_level: 5, note: "+20%" }
          - { name: "Sensory Equipment", base: 45, per_level: 5, note: "+15%" }
          - { name: "T.V./Video", base: 55, per_level: 4, note: "+30%" }
      - id: guerilla-warfare-saboteur
        name: "Guerilla Warfare/Saboteur"
        skills:
          - { choose: 1, from: ["Camouflage", "Detect Ambush"], bonus: 20, note: "Camouflage or Detect Ambush (+20%), pick one." }
          - { name: "Demolitions", base: 85, per_level: 3, note: "+25%" }
          - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
          - { name: "Prowl", base: 40, per_level: 5, note: "+15%" }
          - { name: "Running", base: 0, per_level: 0 }
          - { choose: 1, from: ["Swimming", "Climbing"], bonus: 10, note: "Swimming or Climbing (+10%), pick one." }
          - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed Tracking (Humanoids; +10%)." }
          - { name: "Trap/Mine Detection", base: 40, per_level: 5, note: "+20%" }
          - { name: "Wilderness Survival", base: 55, per_level: 5, note: "+25%" }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
          - { choose: 1, from: ["Hand to Hand: Commando", "Hand to Hand: Assassin"], note: "Replaces Hand to Hand: Martial Arts; pick one." }
      - id: immersion-deep-undercover
        name: "Immersion/Deep Undercover"
        skills:
          - { name: "Contacts - Social Connections", base: 36, per_level: 2, note: "Printed Contacts (+16% and +1D6 contacts), added to the O.C.C. Skill''s +10%." }
          - { name: "Disguise", base: 55, per_level: 5, note: "+30%" }
          - { name: "I.D. Undercover Agent", base: 54, per_level: 4, note: "+24%" }
          - { name: "Impersonation", base: 60, per_level: 4, note: "+30%" }
          - { name: "Interrogation", base: 50, per_level: 5, note: "+20%" }
          - { name: "Performance", base: 50, per_level: 5, note: "+20%" }
          - { name: "Seduction", base: 50, per_level: 3, note: "+30%" }
          - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
          - { name: "Undercover Ops", base: 54, per_level: 5, note: "+24%" }
          - { name: "Wardrobe & Grooming", base: 70, per_level: 4, note: "+20%" }
      - id: insurgency
        name: "Insurgency"
        skills:
          - { name: "Barter", base: 50, per_level: 4, note: "+20%" }
          - { name: "Concealment", base: 50, per_level: 4, note: "+30%" }
          - { name: "Contacts - Social Connections", base: 30, per_level: 2, note: "Printed Contacts (+10% and +1D6 contacts), added to the O.C.C. Skill''s +10%." }
          - { name: "Demolitions", base: 80, per_level: 3, note: "+20%" }
          - { name: "Find Contraband", base: 56, per_level: 4, note: "+30%" }
          - { name: "Forgery", base: 50, per_level: 5, note: "+30%" }
          - { name: "I.D. Undercover Agent", base: 45, per_level: 4, note: "+15%" }
          - { name: "Public Speaking", base: 50, per_level: 5, note: "+20%" }
          - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
          - { name: "Streetwise", base: 50, per_level: 4, note: "+30%" }
          - { choose: 1, from: ["Hand to Hand: Commando", "Hand to Hand: Assassin"], note: "Replaces Hand to Hand: Martial Arts; pick one." }
      - id: liquid-affairs
        name: "Liquid Affairs (Assassin)"
        skills:
          - { name: "Boxing", base: 0, per_level: 0 }
          - { choose: 1, from: [{ name: "Climbing", bonus: 15 }, { name: "Demolitions", bonus: 20 }], note: "Climbing (+15%) or Demolitions (+20%), pick one." }
          - { name: "Escape Artist", base: 50, per_level: 5, note: "Printed (20%), read as +20%." }
          - { choose: 1, from: [{ name: "I.D. Undercover Agent", bonus: 20 }, { name: "Crime Scene Investigation", bonus: 15 }], note: "I.D. Undercover Agent (+20%) or Crime Scene Investigation (+15%, used to leave no evidence; no prerequisites), pick one." }
          - { choose: 1, categories: [{ name: "Espionage", only: ["Impersonation"], bonus: 20 }, "Weapon Proficiencies"], note: "Impersonation (+20%) or W.P.: one of choice (any), pick one." }
          - { choose: 1, from: [{ name: "Pick Locks", bonus: 15 }, "Kick Boxing"], note: "Pick Locks (+15%) or Kick Boxing, pick one." }
          - { name: "Prowl", base: 45, per_level: 5, note: "+20%" }
          - { choose: 1, from: ["Sniper", "Wrestling"], note: "Sniper or Wrestling, pick one." }
          - { choose: 1, from: ["Seduction", "Streetwise"], bonus: 15, note: "Seduction or Streetwise (+15%), pick one." }
          - { name: "Undercover Ops", base: 45, per_level: 5, note: "+15%" }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: one of choice." }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (any)." }
          - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin", "Hand to Hand: Commando"], note: "Keep Martial Arts or exchange it for Assassin or Commando; player''s choice." }
      - id: mage
        name: "Mage/Spell Caster"
        skills:
          - { name: "Lore: Magic", base: 35, per_level: 5, note: "+10%" }
          - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Replaces Hand to Hand: Martial Arts." }
      - id: procurement-specialist
        name: "Procurement Specialist Covert Ops (Thief)"
        skills:
          - { name: "Basic Electronics", base: 45, per_level: 5, note: "+15%" }
          - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
          - { name: "Computer Hacking", base: 25, per_level: 5, note: "+10%" }
          - { name: "Find Contraband", base: 58, per_level: 4, note: "+32%" }
          - { name: "Locksmith", base: 60, per_level: 5, note: "+35%" }
          - { choose: 1, from: ["Palming", "Streetwise"], bonus: 20, note: "Palming (+20%) or Streetwise (+20%), pick one." }
          - { name: "Pick Pockets", base: 45, per_level: 5, note: "+20%" }
          - { name: "Prowl", base: 45, per_level: 5, note: "+20%" }
          - { name: "Safe-Cracking", base: 40, per_level: 4, note: "Printed Safecracking (+20%)." }
          - { name: "T.V./Video", base: 40, per_level: 4, note: "+15%" }
      - id: psychic-assassin
        name: "Psychic Assassin (Major Psychic)"
        skills:
          - { name: "Disguise", base: 50, per_level: 5, note: "+25%" }
          - { name: "I.D. Undercover Agent", base: 54, per_level: 4, note: "+24%" }
          - { name: "Impersonation", base: 50, per_level: 4, note: "+20%" }
          - { name: "Performance", base: 50, per_level: 5, note: "+20%" }
          - { choose: 1, from: ["Sniper", { name: "Prowl", bonus: 20 }], note: "Sniper or Prowl (+20%), pick one." }
          - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
          - { name: "Undercover Ops", base: 46, per_level: 5, note: "+16%" }
          - { name: "Hand to Hand: Assassin", base: 0, per_level: 0, note: "Replaces Hand to Hand: Martial Arts." }
      - id: psychic-interrogator-major
        name: "Psychic Interrogator (Major Psychic)"
        skills:
          - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
          - { name: "Chemistry", base: 40, per_level: 5, note: "+10%" }
          - { name: "Crime Scene Investigation", base: 45, per_level: 5, note: "+10%" }
          - { name: "Law", base: 50, per_level: 5, note: "Printed Law (General) (+15%)." }
          - { name: "Law: Loopholes", base: 22, per_level: 4, note: "Printed Law - Loopholes (+2%)." }
          - { name: "Lore: D-Bee", base: 45, per_level: 5, note: "Printed Lore: D-Bees (+20%)." }
          - { name: "Lore: Psychics & Psionics", base: 40, per_level: 5, note: "+15%" }
          - { name: "Performance", base: 50, per_level: 5, note: "+20%; for good cop, bad cop and intimidation." }
          - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
      - id: psychic-interrogator-master
        name: "Psychic Interrogator (Master Psychic/Mind Melter)"
        skills:
          - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
          - { name: "Chemistry", base: 40, per_level: 5, note: "+10%" }
          - { name: "Performance", base: 45, per_level: 5, note: "+15%" }
          - { name: "Public Speaking", base: 40, per_level: 5, note: "+10%" }
          - { name: "Streetwise", base: 35, per_level: 4, note: "+15%" }
      - id: psychic-spy-major
        name: "Psychic Spy (Major Psychic)"
        skills:
          - { name: "Disguise", base: 45, per_level: 5, note: "+20%" }
          - { name: "I.D. Undercover Agent", base: 50, per_level: 4, note: "+20%" }
          - { name: "Impersonation", base: 50, per_level: 4, note: "+20%" }
          - { name: "Interrogation", base: 40, per_level: 5, note: "+10%" }
          - { name: "Performance", base: 50, per_level: 5, note: "+20%" }
          - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
          - { name: "Undercover Ops", base: 46, per_level: 5, note: "+16%" }
      - id: psychic-spy-master
        name: "Psychic Spy (Master Psychic/Mind Melter)"
        skills:
          - { name: "I.D. Undercover Agent", base: 50, per_level: 4, note: "+20%" }
          - { name: "Impersonation", base: 45, per_level: 4, note: "+15%" }
          - { name: "Performance", base: 40, per_level: 5, note: "+10%" }
          - { choose: 1, from: ["Streetwise", "Disguise"], bonus: 15, note: "Streetwise or Disguise (+15%), pick one." }
          - { name: "Undercover Ops", base: 42, per_level: 5, note: "+12%" }
      - id: psychic-special-forces-master
        name: "Psychic Special Forces (Master Psychic)"
        skills:
          - { name: "Disguise", base: 35, per_level: 5, note: "+10%" }
          - { name: "I.D. Undercover Agent", base: 45, per_level: 4, note: "+15%" }
          - { name: "Impersonation", base: 50, per_level: 4, note: "+20%" }
          - { choose: 1, from: ["Sniper", { name: "Prowl", bonus: 10 }], note: "Sniper or Prowl (+10%), pick one." }
          - { name: "Undercover Ops", base: 42, per_level: 5, note: "+12%" }
          - { name: "Hand to Hand: Assassin", base: 0, per_level: 0, note: "Replaces Hand to Hand: Martial Arts." }
  occ_related_skills:
    count: 0
    note: "None: the Spetsnaz M.O.S. bundle takes the place of O.C.C. Related Skills."
  secondary_skills:
    count: 0
    note: "None."
special_abilities:
  - name: "Spetsnaz Division Training"
    description: "After the training all agents share (the O.C.C. Skills), each agent is assigned at creation to one of three branches, which cannot be changed later: Foreign Military Intelligence and Infiltration (SVR), the Division for Detection and Suppression of Inhuman Threats (OVPUB), or the Committee for State Security (KGB). The agent knows how the three work together, the inner workings and hierarchy of the own branch, and the threats to the Sovietski it is trained to meet, and builds contacts in every walk of life: military, political, the enclaves, civilians, criminals and foreigners."
  - name: "Branch: SVR (Foreign Military Intelligence)"
    description: "Gathers intelligence on the forces, movements, tactics and weapons of rival and allied states, the Warlords of Russia, the Brodkil Empire, raiders, mercenaries and criminal groups. Starts with two alternate identities, with false papers, clothes and foreign currency, each tied to a Warlord camp, the NGR, the Free Scandinavian Alliance, Poland, the Horune pirates and slavers, or the Black Market or another criminal group; each has 1D6 contacts for information, rumors, warnings and simple help (a safe house, basic medical care, a fake I.D., a little cash, basic weapons). Gains a new identity with no contacts at levels 4, 8 and 12. Also two more Language skills at +10%, each spoken with no Russian accent. The languages are not added to the sheet: take them with the GM."
  - name: "Branch: OVPUB (Detection and Suppression of Inhuman Threats)"
    description: "The front line against monsters, demons, evil mages, psychics and other supernatural or magical threats to the Sovietski; many of its agents are themselves loyal psychics or mages, recruited young and trained to hunt their own kind. Starts with one alternate identity and 1D4 contacts among psychics, gypsies, mages, old faith believers and herbalists, and may join magic guilds or circles under that identity when approved. +5D6 P.P.E. for a mage or +5D6 I.S.P. for a psychic, and Lore: Demons and Monsters, Lore: Magic and Lore: Psychics, each at +15%. None of this is added to the sheet: the pool applies only to a mage or psychic, and the three Lore skills are taken with the GM."
  - name: "Branch: KGB (Committee for State Security)"
    description: "Domestic intelligence, likened to Homeland Security joined with the FBI or NSA: hunts insurgents, organized crime, dissidents, spies and shapeshifters inside the country. Starts with three alternate identities, each with 1D4 contacts in one city or village who know a dissident or rival political group, an enclave, a criminal group, the local Black Market, rogue psychics or magic groups operating in secret. At levels 4, 9 and 14 it adds a new identity and 1D4 contacts to one identity. Also Streetwise at +15%, Cryptography at +10%, and +10% to one other Communications or Technical skill. The skills are not added to the sheet: take them with the GM."
  - { choose: 1, from: ["Branch: SVR (Foreign Military Intelligence)", "Branch: OVPUB (Detection and Suppression of Inhuman Threats)", "Branch: KGB (Committee for State Security)"], note: "Pick the Intelligence branch at creation; it cannot be changed." }
  - name: "Training: Airborne Deployment Specialist"
    description: "Special forces trained for HALO and drop-zone insertion behind enemy lines, for reconnaissance, raids, rescues and black ops. 5D6+12 S.D.C., +1D4 P.S., +1 P.E. or P.P. (pick one; not added to the sheet), +2 on Perception Rolls, +2 initiative, +2 strike, +1 parry and disarm, +2 pull punch, +3 roll with impact, +4 save vs Horror Factor. The book prints an additional +10% to Intelligence and Radio: Basic and, in the same sentence, another +10% to Intelligence and +5% to Surveillance (Tailing included); these are not raised on the sheet. Hand to Hand: Commando or Assassin replaces Martial Arts (in the M.O.S. skills). Automatically gets the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing)."
    bonuses: { attributes: { PS: "1d4" }, combat: { perception: 2, initiative: 2, strike: 2, parry: 1, disarm: 1, pull_punch: 2, roll: 3 }, saves: { horror_factor: 4 }, pools: { sdc: "5d6+12" } }
  - name: "Training: Commando"
    description: "Serves on tactical strike teams that carry out raids, rescues and assaults. 5D6+20 S.D.C., +1D6 P.S., +1 P.E. or P.P. (pick one; not added to the sheet), +2 on Perception Rolls, +2 initiative, +2 strike, +1 parry and disarm, +2 pull punch, +2 roll with impact, +4 save vs Horror Factor. An additional +15% to Intelligence and +5% to Surveillance (Tailing included), not raised on the sheet. Hand to Hand: Commando replaces Martial Arts (in the M.O.S. skills)."
    bonuses: { attributes: { PS: "1d6" }, combat: { perception: 2, initiative: 2, strike: 2, parry: 1, disarm: 1, pull_punch: 2, roll: 2 }, saves: { horror_factor: 4 }, pools: { sdc: "5d6+20" } }
  - name: "Training: Cyber-Humanoid"
    description: "Top secret and experimental for the Sovietski. The volunteer becomes a light full conversion cyborg built to the agent''s own size and shape and covered in Bio-System skin, so as to look wholly human: it bleeds a little when cut, wears ordinary clothes and armor, passes metal detectors and most thermal sensors, and is revealed only by X-rays or flesh torn down to the metal. Psychics and Spetsnaz Mages are barred, since the conversion erases psychic and magic ability. M.D.C. by Location: head 75, hands (2) 20 each, arms (2) 40 each, feet 20 each, legs 55 each, main body 112 (the mdc_base). Weight 290-350 lbs (130-157.5 kg). Attacks per melee as Hand to Hand: Martial Arts. Robot P.S. 20: restrained punch 4D6 S.D.C., full punch 1D4 M.D., power punch 2D4 M.D. (two attacks), kick 1D6 M.D., leap kick 2D6 M.D. (two attacks). +1 on Perception Rolls, +3 strike, +3 parry and dodge, +1 pull punch, +2 roll with impact, +3 save vs Horror Factor; +10% to Computer Operation, Intelligence, Radio: Basic and Surveillance (Tailing included), not raised on the sheet."
    mdc_base: 112
    bonuses: { combat: { perception: 1, strike: 3, parry: 3, dodge: 3, pull_punch: 1, roll: 2 }, saves: { horror_factor: 3 } }
  - name: "Cyber-Humanoid Bionics"
    description: "For the Cyber-Humanoid M.O.S. only. Arms and hands P.S. 20 and P.P. 20. One hand is a Multi-System Hand and the other holds two chosen features; each hand also has two hidden finger weapons or features and one retractable knuckle item; one wrist feature or weapon; a hidden blaster (player''s choice) in each forearm. Legs: Spd 110 (75 mph/120 km), P.S. and P.P. 20; leaps 6 ft (1.8 m) high and long from a standstill, double with a running start; survives a 100 ft (30.5 m) fall for 2D6 M.D. and cosmetic damage; fatigues at 20% the human rate. A chosen feature in each leg, most often a hidden compartment or weapon, can be reached only by cutting the skin open, so it is kept for emergencies. Head: a Cyber-Camera Eye (one) or Bio-System Nightvision Eyes (two), never an eye that looks mechanical; Cyber-Disguise Type AA-1 and Type ASH Supplemental; the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing); Psionic Electromagnetic Dampeners; Universal Headjack (universal-headjack-and-ear-implant); one option of choice. Ears: one feature of choice that is not obvious. Mouth and throat: Modulating Voice Synthesizer. Other: bionic lungs fitted with a gas filter and an Oxygen Storage Cell (sovietski-oxygen-storage-cell), Clock Calendar (cyber-clock-calendar), Cyber-Nano-Robot Repair System (sovietski-cyber-nano-robot-repair-system), Gyro-Compass (cyber-gyro-compass) and a Language Translator. Not issued as gear rows."
  - name: "Training: Electronic Intelligence"
    description: "Bugs a location and works from a listening post nearby (within 1,000 ft/30.5 m, usually in sight of the target), unseen, recording, assessing threats and calling in a strike team; acts openly only in an emergency or on a take-down order. Spies on enemy forces, suspected criminals, dissidents and enclaves. +1 M.E. An additional +20% to Intelligence, Radio: Basic and Surveillance, not raised on the sheet. +3 on Perception Rolls to avoid being seen, recognize fugitives and targets, and find an adversary''s surveillance systems and bugs (conditional, not added to the sheet)."
    bonuses: { attributes: { ME: 1 } }
  - name: "Training: Guerilla Warfare/Saboteur"
    description: "Operates behind enemy lines for long stretches, harassing the enemy with sabotage, raids, ambushes, traps, hit and run and psychological warfare, cutting supply lines and communications and raising bands of irregulars. 5D6+10 S.D.C., +1 M.E., +2 P.S. and P.E., +2 initiative, +1 strike, parry and dodge, +2 disarm, +3 pull punch, +1 roll with impact, +3 save vs Horror Factor. An additional +10% to Intelligence and Radio: Basic, +5% to Surveillance and +20% to Tailing, not raised on the sheet. +3 on Perception Rolls about enemy troop movement, strategic targets, ambushes and traps (conditional, not added to the sheet). Hand to Hand: Commando or Assassin replaces Martial Arts (in the M.O.S. skills)."
    bonuses: { attributes: { ME: 1, PS: 2, PE: 2 }, combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, disarm: 2, pull_punch: 3, roll: 1 }, saves: { horror_factor: 3 }, pools: { sdc: "5d6+10" } }
  - name: "Training: Immersion/Deep Undercover"
    description: "Trained by cultural immersion in eye to eye surveillance: takes on another identity and blends in as a faceless bystander or someone who plainly belongs, for deep infiltration and intelligence work lasting weeks, months or years. Also used against spies: posing as an ordinary clerk or soldier at a base, office or enclave thought compromised, the agent finds and removes the mole, saboteur or traitor, or sweeps a facility for surveillance; a discovered mole may be left in place to be fed false information and followed to his masters. +4 M.A. An additional +10% to Trust/Intimidate and Charm/Impress whatever the M.A., and +20% to Intelligence and Surveillance, not raised on the sheet. +2 on all Perception Rolls, and +4 more to spot suspicious, criminal and traitorous behavior (conditional, not added to the sheet). +1 initiative, +1 parry and dodge, +1 pull punch, +2 roll with impact, +2 save vs Horror Factor."
    bonuses: { attributes: { MA: 4 }, combat: { perception: 2, initiative: 1, parry: 1, dodge: 1, pull_punch: 1, roll: 2 }, saves: { horror_factor: 2 } }
  - name: "Training: Insurgency"
    description: "Stirs the oppressed to rise against whatever holds them down (Brodkil, bandits, an evil mage, monsters, invaders, a Warlord camp, a tyrant, slavers), so that others weaken a foe of the Sovietski before its own troops arrive. Works in secret and at a distance, often posing as a mercenary or smuggler, or openly as a Sovietski advisor when that lifts morale. Where an uprising is not wise, recruits trusted insiders to pass on schedules, codes and troop movements, leave a gate open, plant bugs or false evidence, cause a distraction or lead the enemy into a trap. Advises, trains, organizes and equips rebels outside Sovietski territory: forged papers, smuggled weapons, supplies and people, sabotage. +3 M.A. An additional +15% to Radio: Basic and +10% to Intelligence and Surveillance, not raised on the sheet. +3 on Perception Rolls to recognize insurgents, rebels and the enemies of an enemy, find contraband and spot forged papers (conditional, not added to the sheet). Hand to Hand: Commando or Assassin replaces Martial Arts (in the M.O.S. skills)."
    bonuses: { attributes: { MA: 3 } }
  - name: "Training: Liquid Affairs (Assassin)"
    description: "Mokryye Dela: makes problems and people disappear, by kidnaping and coercion or something final, at home against citizens, dissidents, spies and troublemakers, and abroad. An enforcer and fixer who uses fear, muscle, blackmail, abduction and murder to make people cooperate or fall silent; a sudden death or vanishing of a Sovietski enemy draws suspicion on these agents. 4D6+10 S.D.C., +1D4 P.S. or P.P. (pick one; not added to the sheet). An additional +5% to Contacts and Intelligence and +10% to Surveillance (Tailing included), not raised on the sheet. +2 on Perception Rolls, +2 initiative, +2 strike, +1 parry and disarm, +2 pull punch, +1 roll with impact, +3 save vs Horror Factor. May keep Martial Arts or take Assassin or Commando (in the M.O.S. skills)."
    bonuses: { combat: { perception: 2, initiative: 2, strike: 2, parry: 1, disarm: 1, pull_punch: 2, roll: 1 }, saves: { horror_factor: 3 }, pools: { sdc: "4d6+10" } }
  - name: "Training: Mage/Spell Caster"
    description: "Recruited because many towns and kingdoms such as Tarnow lean on magic, and the Spetsnaz will not be caught unready; most Sovietski, other Spetsnaz included, watch these agents warily. Requires a clean record, a psychological and a loyalty test, government registration and a course in casting and control. No cybernetic implants or bionic limbs; Bio-Systems are allowed. Has only the Ley Line Walker abilities Sense Ley Line and Magic Energy, Read Ley Lines and Ley Line Rejuvenation. Spells: Death Trance and See the Invisible, plus two invocations from each of levels 1-4 (eight chosen). At levels 2, 4, 6, 8, 10, 12 and 14 three more, of spell level up to three above the agent''s own (level 16 too, past the ladder). Further spells must be learned from another practitioner, hard for a soldier at home. P.P.E.: 1D6x10+30 (the pool) plus the P.E. number and 1D6+4 per level, which are not added; recovers 5 per hour of sleep or rest, 10 per hour of meditation. +1 I.Q. An additional +5% to Intelligence and Literacy, not raised on the sheet. +3 on Perception Rolls about magic and the supernatural (conditional). +1 save vs Horror Factor and possession, +1 save vs magic at levels 3, 7 and 12, +1 Spell Strength at levels 4, 8 and 12 (not added). Hand to Hand: Expert replaces Martial Arts (in the M.O.S. skills). Less schooled in magic than a Ley Line Walker, yet still formidable."
    bonuses: { attributes: { IQ: 1 }, saves: { horror_factor: 1, possession: 1 }, pools: { ppe: "1d6x10+30" } }
    magic: { type: "spell", spells: ["Death Trance", "See the Invisible"], spells_starting: 8, spell_levels_allowed: [1, 2, 3, 4], spells_starting_groups: [{ count: 2, spell_levels: [1] }, { count: 2, spell_levels: [2] }, { count: 2, spell_levels: [3] }, { count: 2, spell_levels: [4] }], spells_schedule: [{ level: 2, count: 3, spell_levels: [1, 2, 3, 4, 5] }, { level: 4, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7] }, { level: 6, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9] }, { level: 8, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] }, { level: 10, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] }, { level: 12, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] }, { level: 14, count: 3, spell_levels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] }] }
  - name: "Training: Partial Cyborg"
    description: "55-70% of the body is cybernetic. One Headjack and one Finger Jack; two head or ear cybernetics of choice; the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing); two sensor, communication or throat implants of choice; a reinforced endo-skeleton and frame (20 M.D.C.); two bionic legs, each 70 M.D.C. with 25 M.D.C. feet, Spd 45 (30 mph/48 km), leaping 10 ft (3 m) high or 12 ft (3.7 m) long from a standstill, double with a short run; one bionic arm (40 M.D.C.) and hand (15 M.D.C.), P.S. and P.P. 20, with two forearm and two hand weapons; lung implants with a Gas Filtration System and an Oxygen Storage Cell (sovietski-oxygen-storage-cell); a human-looking head, face and eyes with two Cyber-Disguise features. No M.O.S. skills are printed. Not issued as gear rows, and nothing here is added to the sheet."
  - name: "Training: Procurement Specialist Covert Ops (Thief)"
    description: "Gets past security systems: breaking and entering, burglary, planting evidence, blackmail and kidnaping. +2 P.P. An additional +10% to Intelligence and +20% to Surveillance, not raised on the sheet. +3 on Perception Rolls to find likely hiding places, hidden compartments, safes, rooms, security systems, cameras, motion detectors, bugs and contraband (conditional, not added to the sheet)."
    bonuses: { attributes: { PP: 2 } }
  - name: "Training: Psychic Assassin (Sensitive)"
    description: "A Major Psychic recruit with a clean record, registered and put through hard training to master the gift; fiercely loyal, yet closely watched, since a thought can wound. This Training takes the Sensitive path: Intuitive Combat, Mask I.S.P. and Psionics, Meditation, Mind Block and See the Invisible, plus Object Read or Sense Time, See Aura or Sense Magic, and Telepathy or Sixth Sense. I.S.P.: 4D6 + M.E., +1D6+1 per level; recovers 2 per hour of sleep, 6 per hour of meditation. 3D6 S.D.C., +1 M.E. and P.P. An additional +5% to Intelligence and Radio: Basic and +10% to Surveillance (Tailing included), not raised on the sheet. +2 on all Perception Rolls, +3 more to find and identify the target (conditional), +2 initiative, +1 strike and parry, +2 pull punch, +2 save vs mind control, possession and torture/pain, +3 save vs Horror Factor. Hand to Hand: Assassin replaces Martial Arts (in the M.O.S. skills)."
    bonuses: { attributes: { ME: 1, PP: 1 }, combat: { perception: 2, initiative: 2, strike: 1, parry: 1, pull_punch: 2 }, saves: { mind_control: 2, possession: 2, pain: 2, horror_factor: 3 }, pools: { sdc: "3d6" } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Intuitive Combat", "Mask I.S.P. & Psionics", "Meditation", "Mind Block", "See The Invisible"], powers_starting: 3, powers_starting_groups: [{ count: 1, from: ["Object Read (Psychometry)", "Sense Time"] }, { count: 1, from: ["See Aura", "Sense Magic"] }, { count: 1, from: ["Telepathy", "Sixth Sense"] }] }
  - name: "Training: Psychic Assassin (Physical)"
    description: "The Psychic Assassin''s Physical path, in place of the Sensitive one: Levitation, Meditation, Mind Block, Summon Inner Strength and Telekinesis, plus Deaden Senses or Death Trance, Nightvision or Impervious to Poison, and Resist Fatigue or Ectoplasm. I.S.P.: 4D6 + M.E., +1D6+1 per level; recovers 2 per hour of sleep, 6 per hour of meditation. 3D6 S.D.C., +1 M.E. and P.P. An additional +5% to Intelligence and Radio: Basic and +10% to Surveillance (Tailing included), not raised on the sheet. +2 on all Perception Rolls, +3 more to find and identify the target (conditional), +2 initiative, +1 strike and parry, +2 pull punch, +2 save vs mind control, possession and torture/pain, +3 save vs Horror Factor. Hand to Hand: Assassin replaces Martial Arts (in the M.O.S. skills)."
    bonuses: { attributes: { ME: 1, PP: 1 }, combat: { perception: 2, initiative: 2, strike: 1, parry: 1, pull_punch: 2 }, saves: { mind_control: 2, possession: 2, pain: 2, horror_factor: 3 }, pools: { sdc: "3d6" } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Levitation", "Meditation", "Mind Block", "Summon Inner Strength", "Telekinesis"], powers_starting: 3, powers_starting_groups: [{ count: 1, from: ["Deaden Senses", "Death Trance"] }, { count: 1, from: ["Nightvision", "Impervious to Poison/Toxin"] }, { count: 1, from: ["Resist Fatigue", "Ectoplasm"] }] }
  - name: "Training: Psychic Interrogator (Major)"
    description: "Reads the hearts and minds of prisoners and uses psionics to deduce clues and pull information from the unwilling, by intimidation and worse. Empathy, Meditation, Mind Block, Object Read, See Aura, Sense Magic and Telepathy, plus Total Recall or Sense Evil. I.S.P.: 4D6 + M.E., +1D6+1 per level; recovers 2 per hour of sleep, 6 per hour of meditation. +1 M.A. and M.E. An additional +10% to Trust/Intimidate and Charm/Impress whatever the M.A., +10% to Intelligence and +5% to Surveillance, not raised on the sheet. +2 on all Perception Rolls, +4 more to spot suspicious, criminal or traitorous behavior and to tell truth from lies (conditional). +1 parry and dodge, +2 pull punch, +2 save vs Horror Factor. Saves vs psionic attack on a 12 or higher."
    bonuses: { attributes: { MA: 1, ME: 1 }, combat: { perception: 2, parry: 1, dodge: 1, pull_punch: 2 }, saves: { horror_factor: 2 } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Empathy", "Meditation", "Mind Block", "Object Read (Psychometry)", "See Aura", "Sense Magic", "Telepathy"], powers_starting: 1, powers_starting_groups: [{ count: 1, from: ["Total Recall", "Sense Evil"] }] }
  - name: "Training: Psychic Interrogator (Master)"
    description: "A Master Psychic, usually a Mind Melter (Rifts Ultimate Edition p.150); the stronger the psychic, the better the interrogator or torturer. An NPC is level three or higher (1D4+2). Bio-Manipulation, Detect Psionics, Empathy, Empathic Transmission, Healing Touch, Meditation, Mind Block, Object Read, Psychic Diagnosis, Psychic Surgery, Remote Viewing, See Aura, Sense Evil, Sense Magic, Sixth Sense, Telekinesis, Telekinetic Punch, Telekinetic Push, Telepathy and Total Recall, several used for torture or to heal a subject for more questioning. At level 4 Psi-Sword and one Super power of choice (often Electrokinesis or Pyrokinesis); at level 5 Radiate Horror Factor and one power of choice; from level 6 two powers of choice per level, Super or otherwise. I.S.P.: 3D6x10 + M.E., +10 per level; recovers 4 per hour of activity, 12 per hour of sleep or meditation. Bonuses as the Mind Melter: +3 on Perception Rolls, +3 initiative, +1 strike, +2 disarm, +2 pull punch, +4 save vs possession, +3 save vs illusions, +2 save vs psionic attack and all mind control, +1 save vs Horror Factor at levels 1, 2, 4, 5, 7, 9, 11, 13 and 15. Fewer skills, as these psychics lean on their powers."
    bonuses: { combat: { perception: 3, initiative: 3, strike: 1, disarm: 2, pull_punch: 2 }, saves: { possession: 4, illusionary_magic: 3, psionics: 2, mind_control: 2, horror_factor: 1 } }
    psionics: { type: "master", isp_base: "M.E. + 3d6x10, +10 per level", powers: ["Bio-Manipulation (the evil eye)", "Detect Psionics", "Empathy", "Empathic Transmission", "Healing Touch", "Meditation", "Mind Block", "Object Read (Psychometry)", "Psychic Diagnosis", "Psychic Surgery", "Remote Viewing", "See Aura", "Sense Evil", "Sense Magic", "Sixth Sense", "Telekinesis", "Telekinetic Punch", "Telekinetic Push", "Telepathy", "Total Recall"], powers_schedule: [{ level: 4, count: 1, from: ["Psi-Sword"] }, { level: 4, count: 1, categories: ["Super"], note: "Often Electrokinesis or Pyrokinesis." }, { level: 5, count: 1, from: ["Radiate Horror Factor"] }, { level: 5, count: 1, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 6, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 7, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 8, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 9, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 10, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 11, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 12, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 13, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 14, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 15, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }] }
  - name: "Training: Psychic Spy (Major)"
    description: "A psychic looks wholly ordinary until a power shows, which makes Sensitives, Psi-Ghosts (World Book 12: Psyscape) and Mind Melters fine spies and field agents. Empathy, Meditation, Mind Block, Machine Ghost and Object Read, plus Mask I.S.P. and Psionics or Presence Sense, See Aura or Sense Magic, and Telepathy or Sixth Sense. I.S.P.: 4D6 + M.E., +1D6+1 per level; recovers 2 per hour of sleep, 6 per hour of meditation. 2D6 S.D.C., +1 M.A. and M.E. An additional +20% to Intelligence and Surveillance, not raised on the sheet. +2 on all Perception Rolls, +4 more to spot suspicious, criminal or traitorous behavior (conditional), +1 initiative, +1 parry and dodge, +1 pull punch, +1 roll with impact, +2 save vs mind control, possession and torture/pain, +2 save vs Horror Factor."
    bonuses: { attributes: { MA: 1, ME: 1 }, combat: { perception: 2, initiative: 1, parry: 1, dodge: 1, pull_punch: 1, roll: 1 }, saves: { mind_control: 2, possession: 2, pain: 2, horror_factor: 2 }, pools: { sdc: "2d6" } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Empathy", "Meditation", "Mind Block", "Machine Ghost", "Object Read (Psychometry)"], powers_starting: 3, powers_starting_groups: [{ count: 1, from: ["Mask I.S.P. & Psionics", "Presence Sense"] }, { count: 1, from: ["See Aura", "Sense Magic"] }, { count: 1, from: ["Telepathy", "Sixth Sense"] }] }
  - name: "Training: Psychic Spy (Master)"
    description: "Usually a Mind Melter, sometimes a Psi-Ghost or Psi-Tech (World Book 12: Psyscape); an NPC is level three or higher (1D4+2). Bio-Regeneration (self), Deaden Pain, Detect Psionics, Empathy, Intuitive Combat, Levitation, Machine Ghost, Mask I.S.P. and Psionics, Meditation, Mind Block, Object Read, Psi-Sword, Resist Thirst, See Aura, Sense Magic, Sixth Sense, Telekinesis, Telekinetic Leap and Telepathy, plus Total Recall or Speed Reading and one Super power of choice. At level 4 two Super powers of choice, one usually Group Mind Block; from level 5 two powers of choice per level from any of the four categories. I.S.P.: 3D6x10 + M.E., +10 per level; recovers 2 per hour of activity, 12 per hour of sleep or meditation. Bonuses as the Mind Melter: +3 on Perception Rolls, +3 initiative, +1 strike, +2 disarm, +2 pull punch, +4 save vs possession, +3 save vs illusions, +2 save vs psionic attack and all mind control, +1 save vs Horror Factor at levels 1, 2, 4, 5, 7, 9, 11, 13 and 15."
    bonuses: { combat: { perception: 3, initiative: 3, strike: 1, disarm: 2, pull_punch: 2 }, saves: { possession: 4, illusionary_magic: 3, psionics: 2, mind_control: 2, horror_factor: 1 } }
    psionics: { type: "master", isp_base: "M.E. + 3d6x10, +10 per level", powers: ["Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Empathy", "Intuitive Combat", "Levitation", "Machine Ghost", "Mask I.S.P. & Psionics", "Meditation", "Mind Block", "Object Read (Psychometry)", "Psi-Sword", "Resist Thirst", "See Aura", "Sense Magic", "Sixth Sense", "Telekinesis", "Telekinetic Leap", "Telepathy"], powers_starting: 2, powers_starting_groups: [{ count: 1, from: ["Total Recall", "Speed Reading"] }, { count: 1, categories: ["Super"] }], powers_schedule: [{ level: 4, count: 2, categories: ["Super"], note: "One is usually Group Mind Block." }, { level: 5, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 6, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 7, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 8, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 9, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 10, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 11, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 12, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 13, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 14, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }, { level: 15, count: 2, categories: ["Sensitive", "Physical", "Healing", "Super"] }] }
  - name: "Training: Psychic Special Forces (Major)"
    description: "Other psychics, the Cold Born, Burster, Mind Melter, Zapper, Psi-Slayer, Psi-Tech, Psi-Warrior among them, serve as the muscle of commando and strike teams (World Book 12: Psyscape). Skills are the Spetsnaz O.C.C. Skills plus 1D4+3 skills of choice from the psychic''s own O.C.C. Skills in Psyscape, no others. Psionic abilities, special O.C.C. abilities, bonuses, I.S.P. and its recovery are those of the psychic''s own O.C.C. in Psyscape or the core Rifts book. None of it is added to the sheet: take it with the GM."
  - name: "Training: Psychic Special Forces (Master)"
    description: "A Master Psychic in special forces is among the most brutal Spetsnaz, often sent against psychics, mages, cyborgs, monsters and other superhuman foes; an NPC such as a Mind Melter is level three or higher (1D4+2; Rifts Ultimate Edition p.150). I.S.P.: 3D6x10 + M.E., +10 per level; recovers 2 per hour of activity, 12 per hour of sleep or meditation. Psionic abilities and bonuses vary with the type of Master Psychic and are those of its own O.C.C.; none is added to the sheet. Fewer skills, as these psychics lean on their powers; Hand to Hand: Assassin replaces Martial Arts (in the M.O.S. skills)."
  - { choose: 1, from: ["Training: Airborne Deployment Specialist", "Training: Commando", "Training: Cyber-Humanoid", "Training: Electronic Intelligence", "Training: Guerilla Warfare/Saboteur", "Training: Immersion/Deep Undercover", "Training: Insurgency", "Training: Liquid Affairs (Assassin)", "Training: Mage/Spell Caster", "Training: Partial Cyborg", "Training: Procurement Specialist Covert Ops (Thief)", "Training: Psychic Assassin (Sensitive)", "Training: Psychic Assassin (Physical)", "Training: Psychic Interrogator (Major)", "Training: Psychic Interrogator (Master)", "Training: Psychic Spy (Major)", "Training: Psychic Spy (Master)", "Training: Psychic Special Forces (Major)", "Training: Psychic Special Forces (Master)"], note: "Pick the Training that matches the M.O.S. chosen with the skills." }
equipment_starting:
  - { item_id: "sovietski-ssa-213h-black-star-body-armor", qty: 1, note: "Black Star body armor." }
  - { item_id: "e-clip", qty: 5, note: "Five E-Clips for each weapon; these five are the energy rifle''s." }
  - { item_id: "vibro-knife", qty: 1, note: "The book says a Vibro-Knife and/or Vibro-Sword." }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "sovietski-fragmentation-grenade", qty: 2 }
  - { item_id: "knife-silver-plated", qty: 1, note: "Silver-plated survival knife, 2D4 S.D.C." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1, note: "The book says distancing binoculars." }
  - { item_id: "utility-belt", qty: 1, note: "Printed twice in the list; one is stored." }
  - { item_id: "gun-holster", qty: 1, note: "Holster for the side arm." }
  - { item_id: "air-filter", qty: 1, note: "An additional air filter." }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "uniform", qty: 4, note: "Four standard uniforms." }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1, note: "Printed as a pocket-sized silver cross signal mirror; read as a cross and a mirror." }
  - { item_id: "signal-mirror", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Attribute requirements: I.Q. 12, M.E. 10 and M.A. 11 or higher; high mental and physical attributes help."
  - "Race: human and Gridgitz only. Psychics of every kind are welcome."
  - "Equipment beyond the starting list: Military I.D. and ration card, a second, plain-looking suit of body armor of choice, a weapon per W.P. with five E-Clips each, an S.D.C. firearm of choice with four clips, anti-radiation tablets and water purification tablets."
  - "Money: a private two-bedroom apartment, and a small furnished dwelling for each cover identity, enough to pass a casual look; pay as a Lieutenant, starting at 2,400 credits a month. No savings are stated."
  - "Cybernetics and bionics: an agent who is not a Cyber-Humanoid may take a Gyro-Compass (cyber-gyro-compass), Clock Calendar (cyber-clock-calendar), Universal Headjack (universal-headjack-and-ear-implant) and Amplified Hearing. Officers of level 8 and up are likely to add one or two cybernetic eyes, an extra lung implant, Cyber-Disguise AA-1, a cybernetic finger or two, or an artificial arm. Others are bought, awarded or issued for a mission; many agents avoid them because they can give a cover away. A badly injured agent is likely to become a Cyber-Humanoid or a Light Machine with a human face."
extraction_notes: "Rifts World Book 36: Sovietski printed 115-124 (cache p115-p124, cache page = printed folio + 0 for printed 38-177), a text layer. The manifest lists none of these pages as welded, corrupt or digit-substituted; printed 116 is a full-page illustration with no text. Printed 119 (the Cyber-Humanoid M.D.C. by Location, damage and leg figures) and the ladder on printed 224 were read off renders and agree with the cache. Heading Spetsnaz Intel O.C.C., Intelligence Division/KGB Agent (printed 115); stats Spetsnaz Intelligence Officer Stats (printed 117). A Red Army special forces and intelligence officer beside the other Sovietski military O.C.C.s, so occ_group men-of-arms and men_of_arms true. || XP: the ladder headed Spetsnaz/Special Forces in the Experience Tables (printed 224, cache p220). || BRANCH: SVR, OVPUB or KGB, a pick-one ability group; each branch''s identities, contacts, skills and the OVPUB P.P.E. or I.S.P. are prose, because a chosen ability grants no skills and the pool applies only to a mage or psychic. || SKILLS: Contacts is the catalog''s Contacts - Social Connections. Pilot: Hover Craft (Ground) is Hover Craft (ground). Hand to Hand: Martial Arts is granted and no other style is sold, so costs is empty; Commando or Assassin comes in the M.O.S. bundles that print it, as a grant that replaces it. || M.O.S.: one bundle in place of O.C.C. Related Skills, each with a Training ability carrying its bonuses (the Sovietski Soldier''s shape). The first script held the five whose text ends by printed 120 (Airborne Deployment Specialist, Commando, Cyber-Humanoid, Electronic Intelligence, Guerilla Warfare/Saboteur); the second (printed 120-124, cache p120-p124, read off the text layer) added Immersion/Deep Undercover, Insurgency, Liquid Affairs, Mage/Spell Caster, Partial Cyborg, Procurement Specialist, Psychic Assassin, Psychic Interrogator, Psychic Spy and Psychic Special Forces. A psychic M.O.S. that prints a Major and a Master version is two bundles and two Trainings; the Psychic Assassin''s Sensitive or Physical path is two Trainings over one bundle. Partial Cyborg and Major Psychic Special Forces print no M.O.S. skills, so they are Trainings with no bundle. The Mage and psychic Trainings carry magic or psionics blocks; their spells and powers are held rows, no new spell rows (ruling 2026-11-22). Each X or Y pick of a psychic list is a starting group. The Mage''s P.P.E. is a pool bonus of 1D6x10+30; the P.E. number, the 1D6+4 per level, the saves vs magic at levels 3, 7 and 12 and the Spell Strength are prose, as are the Mind Melter saves vs Horror Factor past level 1. A Master Psychic Special Forces and a Major one take powers and bonuses from their own O.C.C., prose. A bundle''s Contacts adds to the O.C.C. Skill''s +10% (cumulative, as the M.O.S. note says). Liquid Affairs prints Escape Artist (20%), read as +20%. The skill bonuses each prints to the O.C.C. Skills (Intelligence, Radio: Basic, Surveillance, Tailing, Computer Operation) are prose. Airborne prints +10% to Intelligence twice in one sentence; both are recorded in its Training. Pilot: Military Helicopter is Military: Combat Helicopter; Pilot: Jet Pack is Jet Packs; Tracking (Humanoids) is Tracking (people). In Commando, the +20% beside Motorcycles and Snowmobiles is read as that option''s only. A one-of-two attribute pick (P.E. or P.P.) is prose. || CYBER-HUMANOID: no vessel row exists for the body, so the main body (112) is the Training''s mdc_base and the rest of the M.D.C. by Location and its bionics are prose, citing catalog slugs where a row exists. No row was found for the Multi-System Hand, Cyber-Disguise AA-1 or ASH, Psionic Electromagnetic Dampeners, Modulating Voice Synthesizer, Cyber-Camera Eye or Bio-System Nightvision Eyes. || MONEY: no savings stated, so no starting_money; the salary and lodging are in restrictions. || EQUIPMENT: the pocket-sized silver cross signal mirror is stored as a small silver cross and a signal mirror, as the Sovietski Soldier reads the same line. Not stored as rows: listed in restrictions."
---

## Lore

The Spetsnaz is both the Sovietski''s intelligence service and its special
forces. Its commandos have a fearsome name that reaches back centuries, and
in the age of Rifts they fight the nation''s enemies in secret on the
battlefield, while its agents spy and infiltrate, sometimes living for years
under false names in Warlord territory, the New German Republic or Poland to
learn what Russia''s supposed allies are doing.

Since the Sovietski rose, the Spetsnaz has absorbed the old military
intelligence services, the GRU and KGB among them, and gained OVPUB, a
division created to investigate and fight demons and other otherworldly
creatures. Its officers frighten the nation''s citizens as much as its
enemies, for it is known to seize political troublemakers from the street,
and many are never seen again.

Agents are organized into trained divisions that watch the state''s enemies
at home and abroad: commando strikes, espionage, infiltration, impersonation,
guerilla warfare and homeland security. Some are spies and saboteurs, others
special forces soldiers, and their training varies so widely that no two
agents are alike, which lets a team of agents, commandos and psychics meet
almost any situation. The Spetsnaz keeps people in every Sovietski city,
enclave and Warlord camp, and in foreign cities, mercenary companies and
organizations across Europe, from the Free Scandinavian Alliance and Poland to
the NGR, Triax, Mindwerks and even General Goll''s forces. It may be the most capable
spy network on Rifts Earth, and a few agents are thought to have reached
China, Atlantis and North America.

## GM Notes

On assignment: any military transport on a direct Sovietski support mission,
extra weapons, energy clips, body armor, vehicles, a medical kit, cameras,
surveillance gear and explosives, fusion blocks included, with high-level
clearance. The agent has priority for S.C.U.B.A. gear, heavy weapons,
explosives, cybernetic repairs and weapons, though what is available still
depends on the commander, stock, location, casualties and combat conditions.

Cover identities are kept strictly apart: gear, clothes, weapons, vehicles,
pictures and notes from one never turn up at another, and only a cursory look
at a cover will hold up. Extra funds or resources can sometimes be approved to
keep a cover alive. Contacts and cover identities are a ready source of plots
and intelligence for the players; hand it out a little at a time.
',
       updated_at = datetime('now')
 WHERE class_id = 'sovietski-spetsnaz-intel'
   AND instr(markdown, 'This script holds the five whose text ends by printed 120') > 0
   AND length(markdown) = 24586;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-spetsnaz-intel' AND instr(markdown, 'the second (printed 120-124, cache p120-p124, read off the text layer)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-spetsnaz-intel' AND instr(markdown, 'This script holds the five whose text ends by printed 120') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('sovietski-spetsnaz-intel') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~403-sovietski-spetsnaz-b.sql');
