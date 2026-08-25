-- Maxi-Killer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.53-55.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-maxi-killer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- The Splugorth bio-wizard Juicer: a symbiote grafted to the back that cannot be removed without killing the host, and living armour that eats him if it is destroyed. The widest racial list in the book, and always a slave.
--
-- SECOND OF THREE BATCHES. See add-hyperion-juicer-class.sql for why these are
-- fifteen separate classes rather than one row with `variants` - in short,
-- VARIANT_OVERRIDES cannot reach the skills block or special_abilities, and
-- that is where they differ. Every one of these prints its own O.C.C. Skills,
-- its own Related Skills count and schedule, its own Secondary Skills, its own
-- equipment and money, and its own numbered abilities list.
--
-- WHY --remote MATTERED HERE. class-check against the LOCAL database reported
-- two dead exclusions on the Maxi-Killer's Pilot list, "Robots & Power Armor"
-- and "Robot Combat Elite: Glitter Boy". Both are real rows in PRODUCTION; the
-- local database is stale and holds the pre-rename spelling. An unmatched
-- `except` fails OPEN, so believing the local run would have meant deleting two
-- exclusions the book actually prints. Audit against --remote.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'maxi-killer', 'Maxi-Killer', 'rifts', '---
id: maxi-killer
name: Maxi-Killer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.53-55
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre", "wolfen"]
  note: "This is the one Juicer conversion with its own printed racial list, and it is the widest in the book - Juicer Uprising p.54 names humans, True Atlanteans (but not Tattooed Men, and fewer than six magic tattoos), Kittani, Kydians, Wolfen, Elves, Dwarves, Simvan, Hawrk-duhk, Hawrk-ka, Hawrk-ofil, a variety of human-like D-Bees, and Splugorth High Lords who rarely bother. Most Maxi-Killers are humans, ogres or elves raised in slavery. Only the races this catalog actually holds can be named here; the rest are recorded in the prose and will start working by themselves if they are ever imported. Barred outright: shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings."
mdc_base: "2d4x10+60, +10 per level"
starting_money: "0"
bonuses:
  attributes: { PS: 8, PE: "1d4", PP: "1d4+1", Spd: "1d6x10" }
  attribute_minimums: { PS: 21 }
  combat: { initiative: 3, roll: 3, attacks: 1 }
  saves: { spell_magic: 4, psionics: 2, possession: 2, toxins_poisons: 4, disease: 4, horror_factor: 4, coma_death_pct: 30 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elf at 98%." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American at 98%." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed as Tracking (+10%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 55, per_level: 5, note: "+5%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two weapons of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "The Maxi-Killer starts at Martial Arts or Assassin - the only class in this book that does not begin at Expert, and the only one with nothing to trade for the upgrade." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod"], bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "The book prints Pilot as any EXCEPT robot and power armor skills, and Technical as any EXCEPT computer; both are spelled out as the catalog rows they exclude, because an unmatched name in an except list excludes nothing and does so silently. Computer Repair is filed under Electrical here, which the Maxi-Killer restricts to Basic Electronics anyway."
  secondary_skills:
    count: 6
special_abilities:
  - name: "The Maxi-Inducer Symbiote"
    description: "Not a bio-comp and harness but a living thing, attached to the recipient''s back and resembling a chest amalgamate without a mouth or sensory organs. Its roots grow inside the body as well as outside, wrapping tendrils around the limbs and invading the internal organs. It both enhances and regulates the host''s metabolism, raising his attributes to supernatural levels. REMOVING IT IS IMPOSSIBLE WITHOUT INSTANTLY KILLING THE PATIENT."
  - name: "Grafted Armor"
    description: "A second symbiote linked to the Maxi-Inducer grows over the character like a living shell: 120 M.D.C. that regenerates 1D4x10 M.D.C. per hour, covered in a dozen or so small protective spines. It grows one forearm blade per level of experience up to three per arm, each an M.D.C. structure inflicting 2D6 M.D. If its M.D.C. is driven to zero it disappears, its roots retreating into the body - and until it has regenerated 50 M.D.C. the Juicer cannot regenerate at all and takes 3D6 M.D. per hour as the symbiote feeds on him to rebuild itself. Every point he loses goes into the symbiote. Past 50 M.D.C. both recover normally, and the armour regrows completely ten hours after that mark. If the Maxi-Killer dies before the creature reaches 50, THEY BOTH DIE."
  - name: "Supernatural Strength and Endurance"
    description: "A flat +8 to P.S., minimum 21, and it is supernatural. Damage follows the supernatural strength table reprinted in the Titan Juicer entry."
  - name: "Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per hour and can REGROW SEVERED LIMBS AND LOST ORGANS - which no other Juicer in this book can do. Virtually impervious to pain. The +30% to save versus coma and death is in the bonuses block, and is the highest in the book."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Further Bio-Wizard Implants"
    description: "A Maxi-Killer who shows great loyalty and combat prowess, or who was made for the arena, may be granted one or two additional Bio-Wizard implants or appendages - rarely before third level. Kittani and Kydian volunteers get three automatically. A player character who escaped Atlantis will never be given any."
side_effects: "The human body is not meant to hold this state for long. Life span is the recipient''s own average divided by TWENTY, plus 4D6 months - so an average human or ogre lasts four years plus 4D6 months, a True Atlantean 25 years plus 4D6 months, and a Splugorth High Lord with a 1,200-year span would get 60 years plus 4D6 months, a long time for a human and a fraction of a lifetime for him. On top of the usual Juicer anxieties, insomnia, restlessness and impatience: roll once on the Maxi-Killer insanity table, and again every time a new bio-wizard enhancement is acquired. 01-60 no insanity; 61-75 obsessed with fighting and competition and loves it; 76-78 obsession with fighting, hates it and avoids it; 79-84 obsession with danger, takes needless risks; 85-90 a slight fear and paranoia about tattoos and those who have them, cannot stand to get any and distrusts anyone who has even one, very suspicious of Tattooed Men; 91-95 phobia of Splugorth; 96-00 phobia of High Lords."
restrictions: ["No cybernetics, ever.", "Available only to slaves and minions of the Splugorth.", "Cannot be transformed into a Murder-Wraith: the bio-wizardry prevents the necromantic ritual from taking effect.", "Shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings cannot take this conversion at all.", "True Atlanteans may take it only if they are not Tattooed Men and carry fewer than six magic tattoos."]
extraction_notes: "starting_money is 0 because the book prints Money: None - a Maxi-Killer is a slave and is issued what he needs, with a monthly allowance only at his master''s discretion. The life span is a FORMULA against the recipient''s own species rather than a fixed span, which is unique in this book and is stated in side_effects rather than computed. The +8 to P.S. is a flat integer, not dice, which is also unique here. The racial list is the widest in the book and most of it names races this catalog does not hold - Kittani, Kydians, Simvan, the three Hawrk peoples, True Atlanteans and Splugorth High Lords - so those are prose, and race_restrictions names only wolfen, dwarf, elf, ogre and the human case. An `only` fails closed, so this is a conservative reading that will widen by itself if any of those races is ever imported."
---

## Lore

The Splugorth of Atlantis have their own Juicer, and they built it to work on
people the human process kills.

The Atlantean conversion combines high technology - much of it copied directly
from human systems - with bio-wizardry. Officially it is the Bio-Wizard Juicer.
Everyone calls it the Maxi-Killer. Instead of a bio-comp and a drug harness
there is a Juicer Symbiote, the Maxi-Inducer, which attaches to the recipient''s
back, monitors his biology, and manipulates it.

Most Maxi-Killers are humans, ogres or elves raised in slavery, born to it or
taken young, and trained in combat since early childhood. Only the toughest and
most ruthless are chosen for the enhancement, or for similar "elite" gifts like
the Tattooed Maxi-Man. At sixteen or seventeen the loyal slave is united with the
symbiote and becomes a warrior in the service of the Splugorth.

They are teamed with Tattooed Men, Maxi-Men, Power Lords and other slave
warriors, and they are a popular attraction in the arenas of Atlantis. Trusted
servants are rewarded with as many as two more bio-wizard implants or limbs.
Some have been exported across the Megaverse, reaching Phase World and other
transdimensional markets as the property of a High Lord or as gladiators.

A few have escaped. None of them can ever live a normal life, covered as they
are by the symbiote - and there is no taking it off.

## GM Notes

**Demographics.** The Maxi-Killer does not appear in the book''s North American
Juicer breakdown at all; it is Splugorth technology, and its numbers belong to
Atlantis.

**This is the widest-open Juicer in the book and the most owned.** Fourteen
named peoples can take it, against the human-plus-three of everything else - and
the price is that you are a slave. An escaped Maxi-Killer is a strong character
concept with a symbiote on his back that everyone can see.

**The armour is a second creature with its own hit points and its own agenda.**
Drive it to zero and it does not just stop protecting him: it starts eating him,
3D6 M.D. an hour, until it has rebuilt 50 M.D.C. And if he dies first, it dies.
That is a fight with a third party in it.

**The life span formula is the cruellest thing here.** Divide by twenty. A human
gets four years. A True Atlantean gets twenty-five - and loses four hundred and
seventy-five.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'maxi-killer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'maxi-killer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-maxi-killer-class.sql');
