-- The Dog Boy O.C.C., Rifts Ultimate Edition p.142-149.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dog-boy-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('animal-snare', 'Animal Snare', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('c-10-laser-rifle', 'C 10 Laser Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('c-12-laser-rifle', 'C 12 Laser Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('c-18-laser-pistol', 'C 18 Laser Pistol', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('dog-pack-dpm-riot-armor', 'Dog Pack Dpm Riot Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('dress-uniform', 'Dress Uniform', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('infrared-distancing-binoculars', 'Infrared Distancing Binoculars', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('portable-language-translator', 'Portable Language Translator', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-hammer', 'Small Hammer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('spike', 'Spike', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'dog-boy', 'Dog Boy', 'rifts', '---
id: dog-boy
name: Dog Boy
system: rifts
source_book: Rifts Ultimate Edition p.142-149
category: occ
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "20"
ppe_base: "3d6"
starting_money: "600"
psionics:
  type: "master"
  isp_base: "1d6x10, +10 per additional level of experience"
  powers: ["Sense Evil", "Sense Magic", "Sixth Sense", "Empathy"]
  powers_starting: 1
  categories_allowed: ["Sensitive"]
bonuses:
  attributes: { PS: "1d4", PE: "1d4", Spd: "2d6" }
  pools: { sdc: "4d6" }
  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2 }
  saves: { psionics: 2, mind_control: 2, illusionary_magic: 2, possession: 2, curses: 2 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 88%." }
    - { choose: 1, categories: ["Communications"], bonus: 5, note: "Language: Other, one of choice (+5%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Intelligence", base: 38, per_level: 4, note: "+6%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Pilot: Hovercraft (+10%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Read Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Knife or Sword (pick one)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes", "Jet Packs", "Truck", "Boat: Motor and Hydrofoils"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+5%). Domestic: Any (+5%). Espionage: Any (+5%). Mechanical: Basic and Automotive only (+5%). Medical: First Aid only (+5%). Military: Any (+10%). Physical: Any except Acrobatics. Pilot: Motorcycle, Hovercycle, Jet Pack, Truck & Motorboat only (+5%). Technical: Any (+5%) except Computer Operation & Programming. Wilderness: Any (+5%). Cowboy, Pilot Related, Rogue and Science: none. NOTE: Dog Boys in CS service are never taught to read, not even officers."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "dog-pack-dpm-riot-armor", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "small-hammer", qty: 1 }
  - { item_id: "spike", qty: 4 }
  - { item_id: "animal-snare", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "close-combat weapon", qty: 1, from: ["vibro-knife", "vibro-claws"] }
  - { item_id: "c-18-laser-pistol", qty: 1 }
  - { choose: 1, label: "laser assault rifle", qty: 1, from: ["c-10-laser-rifle", "c-12-laser-rifle"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
natural_abilities:
  - name: "Sense Psychic and Magic Energy"
    description: "Constant and automatic, like sight and smell. Detects fellow psychics (I.S.P.) and magic energy (P.P.E. in spell casting, magic devices, and the large reserves of practitioners and creatures of magic - 80 or more points). Can trace continually expended energy to its source. Base Skill: 40% +5% per level (roll once every melee round); halved when multiple sources are scattered through the range. Range: sensitivity to powers IN USE is 400 feet (122 m) +50 feet (15 m) per level; to a psychic or mage NOT using powers, 50 feet (15.2 m) +5 feet (1.5 m) per level. I.S.P.: none, automatic."
  - name: "Recognize Psychic Scent"
    description: "A psychic scent is the signature a specific psychic, mage or monster emanates whenever it uses a power - a psychic fingerprint. Less developed than the Psi-Stalker''s. Base Skill: 10% +4% per level to recognize the general psychic scent of a race or species; 8% +2% per level to recognize a specific individual, +10% with a bit of hair, skin, blood or recently worn clothing (4 hours or less) and +10% for somebody encountered often and known well (bonuses accumulate). Range: 50 feet (15.2 m) +5 feet (1.5 m) per level. Duration: automatic and constant."
  - name: "Sense Supernatural Beings"
    description: "As Sense Psychic and Magic Energy, but far more sensitive to the psychic scent of the supernatural. Base Skill: 62% +2% per level to identify the specific type/race of supernatural being (alien intelligences, gods, demigods, demons, vampires) and creatures of magic such as Faeries and dragons; can sense the magic reserve in amulets, talismans and Techno-Wizard items, locate invisible wizards and creatures of magic, tell when approaching a ley line, and detect whether a mortal is possessed. Base Skill at Tracking by Scent: 35% +5% per level when the creature is not using magic or psionics, a whopping 70% +3% per level when a supernatural being IS using powers or is a Demon Lord, Alien Intelligence, god or dragon. Range: 100 feet (30.5 m) per level; 1000 feet (305 m) +100 feet per level when magic is in use."
  - name: "Superior Sense of Smell"
    description: "Roughly one million times better than a human''s. Follows a scent trail up to four days old and recognizes an odor from a few molecules; smells odors up to 12 inches (0.3 m) underground and two feet (0.6 m) under snow. Common and strong scents: 70% +3% per level, range 100 feet (30.5 m) per level. Identify specific odors: 54% +2% per level, range 25 feet (7.6 m) per level. Track by smell alone: 40% +4% per level - can follow a scent through total darkness, suffering only HALF the normal blind penalties (-5 instead of -10 to strike, parry and dodge). Roll once every 1000 feet (305 m) to stay on the trail; cannot track through water or rain, nor smell Astral Beings, ghosts or energy beings."
  - name: "Keen Sense of Hearing"
    description: "Registers sounds of 35,000 vibrations per second against 20,000 in humans. Large ears prick up and swivel to focus on a noise, and the inner ear can be shut off to filter the general din and zero in on one sound."
  - name: "Good Sight"
    description: "Field of vision is 200 degrees in short-nosed canines, 270 in long-nosed breeds, against a human''s 100 degrees. Sees color in a similar range to humans, though a bit dulled. Note: a dog does NOT see better in the dark than a human - keen smell and hearing compensate."
  - name: "Sense of Taste and Biting"
    description: "Only a fair to good sense of taste. The bite varies with breed: a nipping or warning bite inflicts 1D6 S.D.C., a full strength bite 2D6 S.D.C. - more from larger breeds (wolf, coyote, Wolfhound, Rottweiler, Pit Bull). Dog Boys are discouraged from biting: the CS dislikes encouraging such primal action, and it opens the warrior to injury of the mouth, throat and head."
  - name: "Sensitivity to Ley Line Energy"
    description: "Ley lines are a PROBLEM. The steady stream of magic energy completely obliterates the Dog Boy''s ability to sense magic, psionics and the supernatural, so any psychic, demon or creature of magic on a ley line is undetectable; physical senses are unaffected. Dog Boys are leery around places of magic, afraid during Ley Line Storms (headaches, crackling in the ears, static shocks), and are twice as likely as others to be struck by ley line energy and lightning."
  - name: "Psionics and I.S.P."
    description: "Master Psychic with special psionic sensitivity: needs a 10 or higher to save vs psionic attack. Automatically has Sense Evil (2), Sense Magic (3), Sixth Sense (2) and Empathy (4; receiver only, not transmission), plus the choice of ONE additional Sensitive power. I.S.P. Base: 1D6x10 plus the M.E. attribute, +10 per level. Recovery: two I.S.P. per hour of activity or 12 per hour of meditation or sleep."
restrictions:
  - "Racial Requirement: a mutant canine genetically created by the CS. Player characters who are not CS agents must be feral deserters or the freeborn offspring of runaway Dog Boys. About 80% of lab-grown mutant canines are male."
  - "O.C.C. bonuses beyond the modeled ones: +5 on Perception Rolls, +2 to disarm, +2 to save vs disease. Physical endurance is twice a human''s; a P.S. under 17 carries 20 times P.S. in pounds, 17 or higher carries 40 times."
  - "Magic: none. Even feral and freeborn Dog Boys distrust and avoid magic and magic items, including weapons."
  - "Cybernetics: none to start; most mutant canines would prefer to avoid them."
extraction_notes: |
  - RUE p.142-149. Classified as an O.C.C. per the book''s own Designer''s Note
    (an R.C.C. is a character so defined by its genetics that it cannot select
    another occupation; a Dog Boy could learn other jobs, which puts it on par
    with a D-Bee). attribute_dice are carried anyway because the mutant canine
    rolls its own attributes - a race-shaped fact on an occupation-shaped
    class, exactly as the book presents it.
  - Money is the two months'' starting pay of a Dog Pack soldier (200-300
    credits a month); the CS provides quarters, food, clothing, medical care
    and equipment, so 600 is a representative figure rather than a roll.
  - The optional Height and Type/Breed percentile tables (and their per-breed
    bonuses) are player options that no schema field holds; they are
    summarised in GM Notes.
  - +5 Perception, +2 disarm and +2 vs disease have no bonus key and sit in
    restrictions.
---

## Lore

The so-called "Dog Boy" is the Coalition States genetic engineering laboratories'' most successful creation. All Dog Boys have their origin with the CS, although an increasing number (perhaps as many as 5%) are "free born" - the natural born offspring of lab created Dog Boys who have gone AWOL from the Coalition Army.

Coalition Dog Boys have come to play an increasingly important role in CS defenses and military operations because they can literally "sniff out," sense and sometimes see users of magic and the supernatural even when invisible or disguised. One or two Dog Boys are assigned to most every squad operating outside CS held territory. The bond of friendship and camaraderie between the human troops and the mutant Dog Boys is almost akin to that of a boy and his dog, and the feeling is mutual: like real domesticated canines, Dog Boys love the company of humans and instinctively regard them as both part of their "pack" and their superiors.

Since Dog Boys are trained animals specially bred for duty as guard "animals," they are generally looked upon by the military brass as an expendable commodity - an attitude not shared by the Psi-Stalkers or police partnered with them. Most Dog Boys don''t see anything wrong with how they are treated and are happy just to be part of the human pack for however long that may be.

## GM Notes

**Optional Height table:** 01-10% four feet; 11-30% five feet; 31-50% five feet six; 51-65% five feet ten; 66-80% six feet; 81-90% six feet four; 91-00% six feet eight.

**Optional Type/Breed table (a sample):** 01-05% Irish Water Spaniel (good tracker, excellent swimmer 90%, +1 Perception, near-waterproof coat); 06-10% Wolfhound (tracks by sight not scent, -40% to track by smell, +30 S.D.C., +1D4 P.E. and P.S., +3D6 Spd, +1 Perception, +2 initiative, bite +2D6); 11-15% Irish or English Setters (good tracker, +2D6 S.D.C., +1 P.E., +1 Perception, fair swimmer 55%); 16-20% Coonhound (superior sniffer, +5% to track by smell, +3 Perception); 21-25% Golden Retriever (good tracker, hardy, +3D6 S.D.C., +1 P.S. and P.E., +2 Perception, natural swimmer 80%). Add all bonuses together with the standard ones.

A standard CS reconnaissance or patrol squad at Tolkeen or the Magic Zone consists of four human soldiers, a Dog Pack (four Dog Boys) and one Psi-Stalker, plus a squad leader. A pack of four or more Dog Boys is always led by a Civilized Psi-Stalker.

For more breeds and the full range of Coalition mutants, see Rifts World Book 13: Lone Star (pages 22-55).
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dog-boy');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'dog-boy';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('animal-snare', 'c-10-laser-rifle', 'c-12-laser-rifle', 'c-18-laser-pistol', 'dog-pack-dpm-riot-armor', 'dress-uniform', 'infrared-distancing-binoculars', 'portable-language-translator', 'small-hammer', 'spike');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dog-boy-class.sql');
