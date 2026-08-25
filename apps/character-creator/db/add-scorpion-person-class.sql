-- The Scorpion Person, an optional R.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.57-58.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-scorpion-person-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. Text layer, so
-- nothing was OCR'd or inferred from a page image, and the printed-to-PDF
-- offset is zero (read-columns takes 1-based pages, so printed 57 is
-- argument 58). Validated with scripts/class-check.mjs --remote against the
-- PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Babylonian section. The S.D.C. is a POOL BONUS - "1D6x10 + 40 S.D.C. IN ADDITION
-- TO skill and level bonuses" - not sdc_base, or the race would override what its
-- occupation earned it. P.P.E. is "as per O.C.C." so none is stated, and swim 60%
-- and prowl 50% are stored as GRANTED SKILLS at per_level 0 because the page
-- gives them as flat percentages: what the body does, not training that improves.
--
-- THE OCCUPATION LIST IS ENUMERATED AND IT IS AN INTERPRETATION. The book allows
-- "any man-at-arms except Coalition related ones, juicers or any that require
-- bionics or cybernetics". A group token cannot carve out exceptions, so the men
-- of arms are listed by id - and the Combat Cyborg, Crazy, Headhunter
-- Techno-Warrior and Cyber-Knight are all left off, each being an O.C.C. that
-- REQUIRES the augmentation that sentence rules out. Said plainly in
-- extraction_notes so the reading can be argued with.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'scorpion-person', 'Scorpion Person', 'rifts', '---
id: scorpion-person
name: Scorpion Person
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6+2"
  PS: "3d6+12"
  PP: "3d6+1"
  PE: "4d6+2"
  PB: "2d6"
  Spd: "5d6+6"
mdc_base: "1D6x10 plus the P.E. attribute number, and 1D6 M.D.C. per level of experience"
hit_points_base: "P.E. number + 1D6 per level of experience"
occ_restrictions:
  only: ["glitter-boy", "merc-soldier", "robot-pilot", "rifts-priest", "ley-line-walker", "shifter", "warlock", "diabolist", "techno-wizard"]
  note: "Any man-at-arms EXCEPT Coalition-related ones, juicers, and any O.C.C. requiring bionics or cybernetics - they never use them. Also priests of any Babylonian god, ley line walkers, shifters, warlocks and diabolists. Techno-wizards are extremely rare."
bonuses:
  pools: { sdc: "1d6x10+40" }
  combat: { attacks: 2, initiative: 2, strike: 2, parry: 3 }
  saves: { horror_factor: 4, toxins_poisons: 3, disease: 3 }
skills:
  occ_skills:
    - { name: "Swimming", base: 60, per_level: 0, note: "A natural ability, fixed at 60%." }
    - { name: "Prowl", base: 50, per_level: 0, note: "A natural ability, fixed at 50%." }
natural_abilities:
  - { name: "Bio-regeneration", description: "4D6 M.D.C. per hour." }
  - { name: "Pincer Attack", description: "Adds 1D6 M.D. to the usual punch damage, and can grapple and hold a victim, who is -2 to parry and dodge until they break free." }
  - { name: "Supernatural Strength and Endurance", description: "P.S. and P.E. are supernatural." }
  - { name: "Wall Crawling", description: "Walks on walls and upside down on ceilings at half normal speed." }
  - { name: "Resistant to Poison and Drugs", description: "Half damage or effect, plus a high bonus to save." }
  - { name: "Stinger Tail", description: "1D6 M.D., or 4D6 S.D.C. on a restrained attack, and injects a paralysing poison - save 15 or be -4 to strike, parry and dodge for 1D4 melees." }
restrictions:
  - "Alignment: any."
  - "Horror Factor: 10."
  - "P.P.E. is as per the O.C.C., so none is stated here."
  - "Kicks do 1D6 LESS damage than punches - the legs are small."
  - "They are born warriors."
  - "The Splugorth enslave them. Very few are on Rifts Earth and most of those are slaves in Atlantis; escapees are mistaken for evil insectoid D-bees and shot on sight, or captured for gladiatorial arenas."
side_effects: "Centauroids whose lower half resembles a scorpion - four arms, two of them pincers, eight segmented legs and a stinger tail. Reddish-golden skin, black eyes, obviously the product of a bio-wizard experiment. Six to eight feet tall (1.8 to 2.4 m) and 10 to 18 feet long (3 to 5.4 m) including the tail, 800 to 1000 lbs (360 to 450 kg). They live in small communities built around massive stone palaces and temples, and worship the Pantheon of Sumer."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.57-58 with
  scripts/read-columns.py. Text layer, offset zero.

  1. THE S.D.C. IS A POOL BONUS. The page says "1D6x10 + 40 S.D.C. IN ADDITION
     TO skill and level bonuses", which is the cumulative wording. As sdc_base
     the race would override what its occupation earned it.
  2. NO ppe_base: "P.P.E.: As per O.C.C." Stating one would stop it falling
     through to the occupation, the same reading the Demigod records.
  3. NO PSIONICS BLOCK. The page says nothing about psionics at all, so the
     character rolls normally.
  4. SWIM 60% AND PROWL 50% ARE GRANTED SKILLS, not prose. The page lists them
     among the natural abilities as flat percentages, so they are stored with
     per_level 0 - they are what the body can do, not a trained skill that
     improves. The remaining natural abilities have no percentage and stay
     abilities.
  5. THE OCCUPATION LIST IS ENUMERATED, and it is an interpretation worth
     stating. The book says "any man-at-arms O.C.C. except Coalition related
     ones, juicers or any that require bionics or cybernetics". A group token
     cannot carve out exceptions, so the men of arms are listed by id - and
     three are deliberately left off beyond the ones the book names: the
     Combat Cyborg is a full conversion, the Crazy requires M.O.M. implants,
     and the Headhunter Techno-Warrior is defined by its cybernetics. Each is
     an O.C.C. that REQUIRES the augmentation the sentence rules out. The
     Cyber-Knight is a closer call - it starts with a single Cyber-Armor graft
     - and is left off on the same reading.

     `diabolist` is a PALLADIUM FANTASY class, named because the book names it.
     A Rifts race will never be offered it, since the wizard filters by system;
     it is listed so the permission is recorded rather than lost.
---

## Lore

The Scorpion People are not evil, whatever those who have seen them believe. In
Babylonian myth they guarded the Eastern Door from which the sun emerged each
morning. In truth they live in another dimension, and were recruited by both
sides in the war of the gods as shock troops and special agents.

They worship the Pantheon of Sumer, and their beliefs are almost identical to
those of the ancient Sumerians and Assyrians. Their technology is limited, but
they have lately started trading with other dimensions for energy weapons,
vehicles and tools - and some of their nations pay for those weapons by selling
their own people into slavery, then use them to conquer neighbours and sell
those too. The Splugorth love it.

## GM Notes

A Scorpion Person on Rifts Earth is almost certainly an escaped slave, and looks
exactly like something to shoot. The book is blunt about it: they will be
confused with evil insectoid D-bees and shot on sight, or more likely captured
and made to fight in gladiatorial arenas. A few serve as bodyguards to Marduk,
Tiamat and Ishtar.

Played straight, that gives a character whose problem is not what he can do but
what everyone assumes he is.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'scorpion-person');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'scorpion-person';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-scorpion-person-class.sql');
