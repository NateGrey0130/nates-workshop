-- The Godling R.C.C., Rifts Conversion Book Two: Pantheons of the Megaverse
-- p.16-17.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-godling-class.sql
--
-- TRANSCRIBED BY HAND from the printed pages, not extracted from a PDF. The
-- book is not in the source collection, so there was nothing to point the
-- importer at. Every number here should be checked against a copy before the
-- class is played; `extraction_notes` in the markdown records the three things
-- the book states that the format cannot yet hold.
--
-- Applied by script rather than through the import tool because the production
-- app sits behind Cloudflare Access and cannot be driven headlessly. The
-- markdown is identical to what Confirm would have stored, and the three gear
-- stubs below are exactly what its cross-reference would have created - shape
-- taken from a local dress rehearsal through the real endpoint, not guessed.
--
-- Every skill and every category restriction this class names was checked
-- against the PRODUCTION catalog first. That matters most for the four `except`
-- entries: an `except` naming a skill the catalog spells differently excludes
-- nothing and silently offers a skill the book forbids, so these use the
-- catalog's exact names (`M.D. in Cybernetics`, `Robots and Power Armor`,
-- `Robot Combat: Basic`, `Robot Combat Elite`).
--
-- The markdown is pure ASCII on purpose. Passing non-ASCII to
-- `wrangler d1 execute` on Windows has mangled an em-dash into mojibake in
-- production before, so the prose uses hyphens. The one em-dash that MUST
-- survive is the gear stub marker, which `import-engine.js` matches with
-- `description.startsWith('STUB ')` plus an em-dash - built with char(8212)
-- rather than embedded, for exactly that reason.
--
-- Idempotent through the UNIQUE keys: re-running inserts nothing, and a class
-- or stub already corrected by hand is left alone.

-- Gear the class references. Stubs with no stats, the same as a class import
-- would create; the gear importer fills them in and recognises them by the
-- STUB marker in the description.
INSERT OR IGNORE INTO gear (slug, name, system, source_book, description)
VALUES ('archaic-mdc-armor-of-the-pantheon', 'Archaic Mdc Armor Of The Pantheon', 'rifts', 'pantheons-of-the-megaverse',
        'STUB ' || char(8212) || ' created by class import, needs stats');
INSERT OR IGNORE INTO gear (slug, name, system, source_book, description)
VALUES ('lesser-rune-weapon', 'Lesser Rune Weapon', 'rifts', 'pantheons-of-the-megaverse',
        'STUB ' || char(8212) || ' created by class import, needs stats');
INSERT OR IGNORE INTO gear (slug, name, system, source_book, description)
VALUES ('basic-provisions', 'Basic Provisions', 'rifts', 'pantheons-of-the-megaverse',
        'STUB ' || char(8212) || ' created by class import, needs stats');

-- The class itself, published so it appears in the creation wizard.
INSERT OR IGNORE INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('godling', 'Godling', 'rifts', '---
id: godling
name: Godling
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "4d6"
  ME: "3d6+6"
  MA: "4d6"
  PS: "4d6+6"
  PP: "4d6"
  PE: "4d6+4"
  PB: "4d6+4"
  Spd: "4d6+10"
mdc_base: "P.E. x 10, plus 1D4x10 per level of experience"
sdc_base: "P.E. x 12"
hit_points_base: "P.E. x 3 plus 2D6 per level of experience"
ppe_base: "2D4x10"
starting_money: "2d6x1000"
skills:
  occ_skills:
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0 }
    - { name: "Language: Dragonese", base: 98, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The pantheon''s native language." }
    - { name: "Language: Other", base: 98, per_level: 0, note: "One language of choice, at 98%." }
    - { name: "Language: Other", choose: 2, bonus: 15, note: "Two additional languages of choice." }
    - { name: "Basic Math", bonus: 20 }
    - { name: "Lore: Demons & Monsters", bonus: 25 }
    - { name: "Land Navigation", bonus: 10 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P.s of choice." }
    - { name: "Hand to Hand: Expert", note: "Hand to hand of choice; any may be taken." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", only: ["Cryptography", "Radio: Basic"] }
      - "Domestic"
      - "Espionage"
      - { name: "Mechanical", only: ["Locksmith"] }
      - { name: "Medical", except: ["M.D. in Cybernetics"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots and Power Armor", "Robot Combat: Basic", "Robot Combat Elite"] }
      - { name: "Pilot Related", only: ["Navigation"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Science"
      - "Technical"
      - "Horsemanship"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 5
psionics:
  type: "minor"
  isp_base: "M.E. number plus 1D6x10"
magic:
  type: "none"
bonuses:
  combat: { attacks: 1, initiative: "1d4", strike: 1, parry: 1, dodge: 1 }
  saves: { spell_magic: 2, ritual_magic: 2, horror_factor: 6 }
natural_abilities:
  - { name: "See the invisible", description: "Always active." }
  - { name: "Resistant to poison, drugs and toxins", description: "Half as effective." }
  - { name: "Nightvision", description: "200 ft (61 m)." }
  - { name: "Fire and cold resistant", description: "Does half damage." }
  - { name: "Regeneration", description: "Regenerates 1D6x5 M.D.C. every minute." }
special_abilities:
  - name: "Turn Invisible at Will"
    description: "Turn invisible at will and see the invisible."
  - name: "Energy Blast"
    description: "A ranged attack doing 1D6 M.D. (or S.D.C.) plus 1D6 every two levels after the first. Range: 2D6x100 ft."
  - name: "Energy Aura"
    description: "A field of magical energy that protects with 20 M.D.C. (or S.D.C.) per level of experience, for one hour. Can be created up to three times per 24 hour period."
  - name: "Super-Strong"
    description: "Add 2D6+10 to P.S."
    bonuses: { attributes: { PS: "2d6+10" } }
  - name: "Super-Tough"
    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
  - name: "Shape Shifter"
    description: "Change at will into one animal, one time a day per level. Gets all the advantages of the shape and retains M.D.C., ability to speak and all attributes. A normal animal, not a monster."
    repeatable: true
    on_repeat: "Can shape shift into ANY type of normal animal."
  - name: "Impervious to One Type of Attack"
    description: "Pick one: cold, fire, lightning, energy, poison and disease, mind control or possession."
  - name: "Super-Swift"
    description: "Add 1D4 to P.P. and 1D6x10 to Spd."
    bonuses: { attributes: { PP: "1d4", Spd: "1d6x10" } }
  - name: "Super-Psionic Powers"
    description: "All the abilities from two of the three lesser power categories, or one lesser category and five super-psionic powers, or can be a Burster (pick one)."
    psionics: { type: "master" }
  - name: "Magic Powers"
    description: "All the abilities of a practitioner of magic. Pick one: Ley Line Walker, Shifter, Mystic or Warlock (or Necromancer if evil). Knows all magic spells of the same level as the character''s experience level."
    magic: { type: "innate" }
    repeatable: true
    on_repeat: "Two different types of magical powers."
  - name: "Fly"
    description: "Fly under one''s own mystic power and without exhaustion. Speed attribute 3D4x10, duration 2 hours per level of experience."
  - { choose: 3, from: ["Turn Invisible at Will", "Energy Blast", "Energy Aura", "Super-Strong", "Super-Tough", "Shape Shifter", "Impervious to One Type of Attack", "Super-Swift", "Super-Psionic Powers", "Magic Powers", "Fly"] }
equipment_starting:
  - { item_id: "archaic-mdc-armor-of-the-pantheon", qty: 1 }
  - { item_id: "lesser-rune-weapon", qty: 1 }
  - { item_id: "basic-provisions", qty: 1 }
level_progression:
  - { level: 1, grants: ["Select THREE powers from the special abilities list."] }
restrictions:
  - "Horror Factor: 7+1D4; none if pretending to be a normal human."
  - "Attributes are considered supernatural."
  - "Cybernetics and bionics: none to start; most avoid it. Never agree to a full bionic conversion or M.O.M. implants."
  - "Combat varies with the hand to hand skill selected."
  - "Any S.D.C. bonus from primary and secondary skills is added on as extra M.D.C."
  - "Money: 2D6x1000 in gold coins, plus 4D6x1000 in gems and artifacts. Only the coin is recorded as starting money."
  - "Vehicle: G.M.''s option."
side_effects: "Average life span 50,000 years, effectively immortal. Size varies, usually between 5 and 20 feet tall (1.5 to 6 m); weight varies accordingly. Most godlings consider themselves superior to mortals and may have been raised by gods or in an alien place, so they may not understand human customs, laws, morality or modern technology."
extraction_notes: |
  Transcribed by hand from Pantheons of the Megaverse p.16-17, not extracted from a PDF.

  Three things the book states that the format cannot yet hold, recorded here so
  they are not mistaken for omissions:

  1. P.P.E. is conditional. "If a practitioner of magic, 3D4x10+20 plus 4D6 per
     level of experience. If not a practitioner of magic, base P.P.E. is 2D4x10."
     The non-magic branch is stored; taking the Magic Powers ability does not
     raise it.
  2. I.S.P. is conditional on psychic tier. "If a master psionic, 4D6x10 plus the
     M.E. number, +10 per level. Otherwise a minor or major psionic gets M.E.
     number plus 1D6x10, and gains 1D6 or 1D6+1 per level." The minor/major
     branch is stored; taking Super-Psionic Powers raises the tier but not the
     I.S.P. formula.
  3. S.D.C. and Hit Points apply only "for non-mega-damage worlds". Both are
     stored alongside M.D.C.; which set applies is a campaign decision.

  Two smaller notes: the book prints "(+15% for Horsemanship)" inside the Pilot
  category line, but Horsemanship is its own skill category here, so it is
  offered as a category without the bonus. And per-category percentage bonuses
  (Domestic +10%, Medical +10%, Technical +10%, Wilderness +5%) have nowhere to
  go in the format and are not applied.
---

## Lore

Godlings are the children of gods - not gods themselves, but born of them, and
carrying enough of the divine to be dangerous. A godling is not merely a
super-powerful creature. He will probably feel arrogant and may be contemptuous
of or condescending toward lesser beings. Others may be paternal and overly
protective towards mortals.

The only beings most godlings will treat like equals include dragons, demigods,
intelligent mega-damage D-bees and powerful practitioners of magic. Next in line
for some degree of their respect are members of reputable ancient and long-lived
races like the Atlanteans and Elves, as well as some mortals with superhuman
abilities. After them will be courageous mortal heroes and magicians, and below
them will be the rest of humankind.

Habitat is virtually anywhere; home is determined by pantheon. Typical allies are
friendly pantheon members and priests of the pantheon. Enemies are hostile
members of the pantheon, rival pantheons, supernatural beings in general, and -
depending on the character''s alignment and deeds - the forces of evil or good.

## GM Notes

Characters with the powers of the gods are going to be perceived as a danger,
rival, threat or impediment not only by other gods but by rival priests, power
hungry wizards, dragons, monsters, warlords and would-be conquerors. Their very
presence may incite conflict. Eventually the characters will run into someone or
some force more powerful than themselves.

Even the most powerful character must play within the guidelines of his
alignment. If the character starts to waver, remind the player that his character
is slipping out of alignment and profile; if he persists, the character should be
warned that it will be subject to a dramatic alignment change. Even anarchist and
evil gods will see consequences for their actions in some form.
', 'published', 'manual');

-- Read the result back rather than trusting the exit code: `wrangler d1 execute`
-- has been observed reporting a non-zero exit on a run that fully applied.
SELECT class_id, name, system, status, created_by, length(markdown) AS markdown_bytes
  FROM imported_classes WHERE class_id = 'godling';

SELECT slug, name, system, substr(description, 1, 5) AS marker
  FROM gear WHERE slug IN ('archaic-mdc-armor-of-the-pantheon', 'lesser-rune-weapon', 'basic-provisions')
 ORDER BY slug;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-godling-class.sql');
