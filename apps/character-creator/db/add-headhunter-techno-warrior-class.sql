-- The Headhunter Techno-Warrior O.C.C., Rifts Ultimate Edition p.74-77.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-headhunter-techno-warrior-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('backpack', 'Backpack', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('combat-boots', 'Combat Boots', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hatchet', 'Hatchet', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'headhunter-techno-warrior', 'Headhunter Techno-Warrior', 'rifts', '---
id: headhunter-techno-warrior
name: Headhunter Techno-Warrior
system: rifts
source_book: Rifts Ultimate Edition p.74-77
category: occ
attribute_requirements: { PE: 12, PP: 12 }
starting_money: "1d6x100"
bonuses:
  pools: { sdc: "3d6" }
  attributes: { PS: "1d4", PE: "1d4" }
  combat: { initiative: 1, pull_punch: 3, roll: 3 }
  saves: { coma_death_pct: 10 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 9, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 13, combat: { initiative: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 94%." }
    - { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%)." }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Detect Concealment", base: 40, per_level: 5, note: "+15%" }
    - { name: "Electronic Countermeasures", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Tanks and APCs", base: 46, per_level: 4, note: "Pilot: Tanks & APCs (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 12, note: "Pilot: Jet Pack (+12%) or Hovercycle (+10%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Pilot: two of choice (+10%)." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Read Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 40, per_level: 5, note: "+15%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking (+10%)." }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Find Contraband", base: 53, per_level: 3, note: "The Headhunter variant: narrowly focused on technological contraband - bionics and weapons - to the exclusion of drugs and magic. 53% +3% per level; separate from Streetwise and the broader Find Contraband skill." }
    - { choose: 5, categories: ["Weapon Proficiencies"], note: "W.P.: five of choice, but at least three modern energy weapons." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of one O.C.C. Related Skill, or Commando for the cost of two." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["Paramedic"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Basic Math", "Advanced Math"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+5%). Espionage: Any (+5%). Mechanical: Automotive only (+5%). Military: Any (+15%). Wilderness: Any (+5%). Cowboy: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { choose: 1, label: "energy rifle", qty: 1, from: ["energy-rifle"] }
  - { choose: 1, label: "side arm", qty: 1, from: ["automatic-pistol", "energy-pistol"] }
  - { item_id: "e-clip", qty: 6 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "hatchet", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "combat-boots", qty: 1 }
restrictions:
  - "+2 on Perception Rolls, and +1 to disarm on a Called Shot with any Weapon Proficiency - applied by hand."
  - "Cybernetics: 1D4+1 cybernetic implants of choice, plus one bionic limb (hand and arm, or leg and foot) with two bionic weapons or components - or the Partial ''Borg alternative (see GM Notes). Psionics: a partial-reconstruction character retains psi-powers at HALF I.S.P.; a practitioner of magic with more than two or three implants loses 90% of P.P.E."
extraction_notes: |
  - RUE p.74-77. Alignment any, though most are Anarchist, Miscreant, Diabolic
    or Aberrant. High P.S. and I.Q. suggested but not required.
  - Bonuses modeled: +3D6 S.D.C. (pool bonus), +1D4 P.S. and P.E., +1
    initiative at levels 1/4/9/13 (level 1 in the base block), +3 pull punch
    and roll, +1 save vs Horror Factor at 2/4/6/9/12/15, +10% coma/death.
    Perception and called-shot disarm have no key and sit in restrictions.
  - The Headhunter''s Find Contraband is a variant skill with its own numbers
    (53%+3%), entered as a fixed skill with those numbers rather than the
    catalog row (26%+4%).
  - Equipment: six E-Clips per weapon, three additional weapons of choice with
    three reloads, 1D4 small knives, 1D6 grenades, tent, saddlebags,
    freeze-dried rations (1D4 weeks) - dice quantities stay prose. Money
    1D6x100 credits + 1D6x1000 Black Market. Armor: one light suit for
    espionage and one heavy for combat.
---

## Lore

"The way I see it, we have the best of both worlds."

The Headhunter is a soldier of fortune who combines military knowhow, combat experience and bionics to make his living in the trenches. The term "Headhunter" has come to be the designation for most human mercenaries: warriors-for-hire with some bionics. They are the die-hard men-at-arms who love the challenge of combat and the chance to cheat death - down and dirty cybernetic warriors whose expertise lies in weapons and combat. The Headhunter''s credo is "Fight the good fight and die with the enemy''s heart in your hand."

Unlike the Combat Cyborg, Headhunters love their humanness and can''t bear to submit to complete bionic conversion; a typical partial ''Borg sees only 40-55% of his body replaced. Roughly 60% get both legs replaced, one or both arms, both eyes, and 12-24 implants - but they remain human-looking. Most see themselves as freewheeling "ronin" samurai: nomadic warriors without any one master.

## GM Notes

**Partial Conversion Cyborg statistics** (for Headhunters who take the Partial ''Borg package): retains natural size and shape; M.D.C. by location (hands 25 each, forearms 25 each, upper arms 35 each, feet 15 each, legs 45 each - head and main body are flesh and blood and need armor); bionic arm P.S./P.P. start at 10 (max 20, 22 with bionic bones); leg speed starts 35 (max 58); simulated touch is 35-52%; Prowl and fine-hand skills suffer -15%; psionics retained at half I.S.P.; more than two or three implants destroys a mage''s magic (10% of P.P.E. remains). Partial cyborgs are +2 to save vs possession, +1 vs magic, and impervious to psionic Telemechanics.

**Partial ''Borg package alternative:** Cyborg-Armor: Light Espionage armor. Sensory systems: Multi-Optics Eyes with polarized filters, Clock Calendar and one sensor of choice. One bionic hand and arm with one weapon for the hand or wrist and one forearm weapon or tool of choice. Bionic features & accessories: three to start. Bionics Upgrade Fund: 2D6x1000+10,000 credits.

**Find Contraband (Headhunter variant)** covers arms dealers, weapons and bionics smugglers, body-chop-shops, Cyber-Snatchers and underground Cyber-Docs - not drugs, magic or other contraband. Black Market pays about 20% of retail for contraband items.

**Contacts:** starts with none, but develops a network of arms dealers, smugglers, Operators, Cyber-Docs and chop-shop operators over time; regular clients get offers, discounts of 10-20%, and first right of refusal on rare or stolen items.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'headhunter-techno-warrior');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'headhunter-techno-warrior';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('backpack', 'combat-boots', 'hatchet');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-headhunter-techno-warrior-class.sql');
