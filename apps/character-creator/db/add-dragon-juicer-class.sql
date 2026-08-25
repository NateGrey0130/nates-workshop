-- Dragon Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.47-50.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dragon-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- A supernatural being made with dragon blood, terminally addicted to it, who must find another dragon every six months or die.
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
SELECT 'dragon-juicer', 'Dragon Juicer', 'rifts', '---
id: dragon-juicer
name: Dragon Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.47-50
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "Juicer Uprising p.17 names the Dragon Blood Juicer as one of the three variants a Dwarf may take, along with Titan and Mega, and the standard conversion. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet. Note the book''s other warning: dragon''s blood causes a lethal allergic reaction in some humans, which is a separate hazard from race."
mdc_base: "P.E. + 3d6x10, +10 per level"
ppe_base: "2d4x10"
starting_money: "6d6x100"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", PP: "1d6", Spd: "1d4x10" }
  attribute_minimums: { PS: 20, PP: 18 }
  combat: { initiative: 2, roll: 2, attacks: 2 }
  saves: { psionics: 2, mind_control: 4, toxins_poisons: 6, harmful_drugs: 6, horror_factor: 5, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Piloting: one of choice (+10%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "Printed as Demon and monster lore (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - "Military"
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical and Medical are all None for a Dragon Juicer and are therefore absent from this list rather than restricted - the widest set of closed categories of any Juicer in the book. Rogue is printed with +5% to Prowl only; this catalog files Prowl under Physical, so a Dragon Juicer taking Prowl reads it at +5% from Physical anyway."
  secondary_skills:
    count: 4
special_abilities:
  - name: "Supernatural Being"
    description: "The dragon''s blood makes the Juicer a supernatural creature outright, with M.D.C. equal to P.E. plus 3D6x10 and another 10 M.D.C. per level. Endurance is supernatural as well as strength."
  - name: "Supernatural Strength"
    description: "Damage follows the supernatural strength table reprinted in the Titan Juicer entry. At the minimum P.S. of 20 that is 3D6 S.D.C. restrained, 1D6 M.D. full strength, 2D6 M.D. on a power punch counting as two attacks."
  - name: "Supernatural Dragon Senses"
    description: "Nightvision to 100 feet (30.5 m), See the Invisible, perfect hawk-like vision, and a keen sense of smell."
  - name: "Dragon P.P.E."
    description: "A base of 2D4x10 P.P.E. - and the Dragon Juicer can do NOTHING with it: he cannot learn magic and cannot use psionic powers. It sits there being large, which some think is why a dragon vampire can survive on untreated blood."
  - name: "Super Speed"
    description: "Leap 40 feet (12.2 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run. The longest leap of any Juicer in the book."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Regeneration"
    description: "Regenerates 4D6 M.D.C. per minute - once every four melee rounds. Impervious to disease and to normal cold and heat. The +20% to save versus coma and death is in the bonuses block."
  - name: "Extending the Clock"
    description: "The blood of an ANCIENT dragon, 5,000 years or older, properly treated by an alchemist, adds 6D6 months to the Dragon Juicer''s life. The alchemist needs at least a gallon, the process takes 1D6 months and costs 3D6x100,000 credits - a quarter of that if the Juicer supplies the blood himself. Which is the problem."
side_effects: "TERMINAL ADDICTION TO DRAGON''S BLOOD. Life span is a normal Juicer''s, 5 years plus 4D6 months, but blood from another dragon must be provided EVERY SIX MONTHS, typically at 10,000-40,000 credits. Miss it and M.D.C. and all combat bonuses drop by half, two melee attacks are lost, and stomach cramps and fever strike 1D4 times a day - each bout lasts 2D6 minutes at -6 on initiative and one further attack lost. Miss it for another six months and the character DIES. Most Dragon Juicers never get the chance to solve this the direct way: as soon as word gets around that somebody is hunting ancient dragons, one or more of those dragons takes action. INSANITY. Nightmares about dragons 1D4 times a week for life. After two years, roll: 01-30 paranoia and phobia of dragons (perhaps for good reason); 31-60 obsessed with fighting and killing dragons and other supernatural beings; 61-90 delusional, believes he IS a dragon, and roll on the Juicer Psychosis table for disposition; 91-00 DRAGON VAMPIRE - drinks the untreated blood of slain dragons, which strangely keeps him alive, spares him the alchemist every six months, and adds another 1D6 months to his life. Dragon vampires are usually quite mad."
restrictions: ["No cybernetics, ever.", "Cannot learn magic and cannot use psionic powers, despite carrying 2D4x10 P.P.E.", "Cannot be transformed into a Murder-Wraith: the magic in the conversion prevents the necromantic ritual from taking effect.", "Very rare. Only one shop in Kingsdale and select members of the Federation of Magic are known to make them, and the conversion runs 600,000 to one million credits and takes three months."]
extraction_notes: "The book prints +1D4 on initiative; the bonuses block stores integers for combat, so the average of 2 is carried and the printed dice are recorded here. Impervious to disease and to normal cold and heat is prose rather than a save, because it is an immunity rather than a bonus. The class is an O.C.C. rather than an R.C.C. even though the character becomes a supernatural being - the book prints O.C.C. Skills, O.C.C. Related Skills and Secondary Skills for it, and the transformation happens to a person who already had an occupation. Standard equipment names Dragon Skin Combat Armor at 100 M.D.C., which has no gear row yet."
---

## Lore

In 78 P.A. a band of adventurers killed an adult dragon that had been plaguing
the outskirts of Kingsdale. Among them was a techno-wizard and amateur alchemist
called Regius, who had heard the stories about the magical properties of
dragon''s blood and drew off several gallons for his experiments.

He tested it for years. He drank some himself, early on, and it nearly killed
him - dragon''s blood turns out to cause a lethal allergic reaction in some
humans. Eventually he presented his findings to a gathering of magicians and
technocrats at Kingsdale: laced with the right Juicer chemicals, dragon blood
grants humans supernatural power.

The price was steep. The mundane chemicals bring all the usual Juicer side
effects, including the short life. Worse, the transformed become terminally
addicted to the blood of dragons - and while the maintenance dose is small,
going without for even a week can kill. And most dragons will not part with
their blood willingly.

They made them anyway. One of the sorcerers involved was a dragon herself, and
she volunteered the blood; highly individualistic and driven, she saw no moral
problem in creating beings who might one day hunt and kill her own kind. The
first full Dragon Juicers, all volunteers, were made in 89 P.A. In 100 P.A. the
Federation of Magic bought exclusive rights to Regius''s secrets for a fortune,
on the condition that his Kingsdale shop could keep making them too. By 101 P.A.
the Federation was making Dragon Juicers beyond Kingsdale''s borders.

There are rumours of an ancient dragon who has made himself a small army of
bodyguards and feeds them from his own veins.

## GM Notes

**Demographics.** Dragon Juicers are 1% of all Juicers in North America.

**The six-month clock is the campaign.** Every other Juicer''s deadline is
measured in years and cannot be moved. This one is measured in months and can be
moved - by finding a dragon, and paying it, or killing it. The book closes that
door as fast as it opens it: hunt ancient dragons openly and ancient dragons
notice.

**Read the insanity table as four different characters.** A Dragon Juicer who
rolls 01-30 spends the campaign afraid of the thing he needs. One who rolls 91-00
has solved his addiction and lost his mind doing it, and is the most stable
Dragon Juicer at the table by the numbers.

**He carries 2D4x10 P.P.E. and cannot spend a point of it.** Which makes him
worth a great deal to anyone who can.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dragon-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dragon-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dragon-juicer-class.sql');
