-- Coalition Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.41-45.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-coalition-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- The one Juicer with cybernetics, and the one who cannot quit: cyber-armor, a laser in the finger, and a bomb in his skull that detonates if he deserts.
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
SELECT 'coalition-juicer', 'Coalition Juicer', 'rifts', '---
id: coalition-juicer
name: Coalition Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.41-45
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none"]
  note: "This book prints no racial line for the Coalition Juicer - its Attribute Requirements entry is None and nothing more. The bar is the Coalition''s own, which RUE states for every other CS O.C.C. (p.230, 233, 237), and which this book confirms is still policy: the Psycho-Stalker section says the augmentation of Psi-Stalkers and mutant animals was strictly forbidden and that CS leaders remain leery of doing it to D-Bees at all. In Rifts a human character takes no R.C.C., so \"none\" is the human case."
hit_points_base: "P.E. + 1d4x10, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "3000"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", PP: "2d4", Spd: "2d4x10" }
  attribute_minimums: { PS: 22, PP: 20 }
  combat: { initiative: 4, roll: 4, attacks: 2 }
  saves: { psionics: 4, mind_control: 4, toxins_poisons: 6, harmful_drugs: 6, horror_factor: 3, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks American at 98%." }
    - { name: "Mathematics: Basic", base: 57, per_level: 5, note: "Printed as Basic Math (+12%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 65, per_level: 5, note: "Printed as Pilot Hovercraft (+15%)." }
    - { name: "Military: Tanks & APCs", base: 51, per_level: 4, note: "Printed as Pilot Tank & APC (+15%)." }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Printed as Read Sensory Equipment (+10%)." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - { name: "Mechanical", only: ["Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["Paramedic"] }
      - { name: "Military", bonus: 15 }
      - "Physical"
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Chemistry"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "The book''s level-three grant is one skill AND a W.P., which is stored as two picks at level three - take one of them from Weapon Proficiencies. Science is printed as math and chemistry only. Espionage at +10% and Military at +15% are the highest category bonuses of any Juicer in the book, which is what CS military training buys."
  secondary_skills:
    count: 5
special_abilities:
  - name: "Cyber-Armor"
    description: "A.R. 16 and 50 M.D.C. of implanted armour - the one Juicer variant that starts with cybernetics rather than refusing them."
  - name: "Bionic Hand"
    description: "12 M.D.C., carrying a laser finger blaster for assassination work - 1D4 M.D. at a range of 300 feet (91 m) - and a 30 foot (9 m) climb cord in the wrist."
  - name: "Skull Charge"
    description: "A small explosive device is secretly implanted in the Coalition Juicer''s skull. If the character goes AWOL it is detonated and he dies. Removing it needs surgical facilities and a roll against Medical Doctor at -20%, or M.D. in Cybernetics at no penalty; a failed roll detonates the charge, killing the patient and inflicting 1D6 M.D. to a 10 foot (3 m) radius. Player characters are not usually told about this."
  - name: "Super Endurance"
    description: "Lifts and carries four times what an equivalent person could, lasts five times longer before exhaustion, stays alert and fully efficient for up to five days without sleep and normally needs only three hours a night."
  - name: "Super Speed"
    description: "Leap 30 feet (9.1 m) across after a short run, half from a standstill, and 20 feet (6 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal and is virtually impervious to pain, as per the normal Juicer. The +20% to save versus coma and death is in the bonuses block."
side_effects: "Low Life Span: standard for a Juicer, 5 years plus 4D6 months, with the usual insomnia, restlessness and impatience. The skull charge is its own kind of side effect: a Coalition Juicer cannot leave."
restrictions: ["Available only to the CS military - there is no price a civilian can pay.", "May take 1-3 further cybernetic or bionic implants beyond the issued ones, though many decline: a good number of Juicers feel that adding cybernetics demeans being a Juicer."]
extraction_notes: "starting_money is one month''s pay at 3,000 credits, which is what the character actually holds; food, clothing and basic services are provided free and are not coin. The CS cost of making one is roughly half a million credits including bionics, armour, weapons and equipment, and is prose because no player pays it. Standard equipment names Coalition Special Trooper Armor with a Forearm Integral Weapon System (115 M.D.C., 25 lbs, -5% Prowl), the C-14 Fire-Breather, the C-27 Heavy Plasma Cannon and the C-18 pistol, none of which has a gear row yet."
---

## Lore

The Coalition States have opposed the Juicer process loudly and for decades. CS
propaganda makes a point of how stupid and dangerous it is to tamper with one''s
body through chemicals, and how counterproductive it is to condemn a healthy man
or woman to an early grave. Most citizens and most officials agree. Quebec was
forced by treaty to abandon its Juicer battalions; the process itself was made
illegal; and for decades creating a Juicer was punishable by death.

And for just as long there have been people inside the CS military arguing the
other way, sitting on pre-Rifts Juicer technology for almost a hundred years.
The analyses are hard to dismiss. A Juicer''s combat performance is more than
double a normal human''s. A front-line unit that might take 80% casualties in the
first weeks of expansion could take 20-30% if it were made of Juicers. A Juicer
shock battalion costs 20% less to field than a human one and is 20-40% more
combat efficient. A suit of power armour runs one to five million credits; a
fully outfitted, fully trained Juicer costs no more than 250,000. Four Juicers
for one basic suit. Twenty for a Super SAMAS.

To Emperor Prosek, Juicers are an abomination, and he will not spend "human"
life foolishly. His son Joseph is more pragmatic: he would balk at condemning
full citizens, but has no such qualms about the ''Burbs and the wastelands. There
is an unsubstantiated rumour that young Prosek has proposed a scheme where a
volunteer earns citizenship for himself and two family members by taking the
augmentation and serving five years.

It took Operation Phoenix, and months of intrigue, before the law changed.
Juicer technology is now legal in the Coalition States - under the exclusive
jurisdiction of the military.

## GM Notes

**Demographics.** Coalition Juicers are 2% of all Juicers in North America, and
the book notes that the figure is increasing.

**This is the only Juicer with cybernetics, and the only one who cannot quit.**
Every other variant in the book refuses implants on principle. This one is
issued cyber-armour, a bionic hand with a laser in the finger, and a bomb in his
head that goes off if he deserts. Whether the player character knows about the
last one is a decision worth making before the campaign starts.

**The politics are playable.** General Cabot has lobbied for a Juicer Division
for a decade and looks the other way at LeNoir''s operation in Free Quebec and
Lyboc''s in Chi-Town. Cabot''s own protege, the war hero Ross Underhill, is
publicly against it and would rather spend the money on power armour. A
Coalition Juicer belongs to one of those factions whether he knows it or not.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'coalition-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'coalition-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-coalition-juicer-class.sql');
