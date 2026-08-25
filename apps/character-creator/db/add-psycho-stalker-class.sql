-- Psycho-Stalker, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.45-47.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-psycho-stalker-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- A Juicer Psi-Stalker, made by accident out of a clerical error and a doctor who would not report it. Spends I.S.P. to become a mega-damage being, and loses every psionic power he has in his last two years.
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
SELECT 'psycho-stalker', 'Psycho-Stalker', 'rifts', '---
id: psycho-stalker
name: Psycho-Stalker
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.45-47
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none"]
  note: "A Psycho-Stalker is a Juicer Psi-Stalker, and Psi-Stalkers are mutant humans only (RUE p.152). In Rifts a human character takes no R.C.C., so \"none\" is the human case - the same reading the psi-stalker and wild-psi-stalker O.C.C.s already carry. Juicer Uprising p.16-17''s widening does not reach this one: the process here is specifically the Psi-Stalker metabolism, and the book says every earlier attempt on a Psi-Stalker or mutant animal had killed the patient."
hit_points_base: "P.E. + 40, +1d6 per level"
sdc_base: "2d6x10+100"
starting_money: "2500"
bonuses:
  attributes: { PS: "2d6", PE: "3d4", PP: "2d6", ME: "1d6", Spd: "3d4x10" }
  attribute_minimums: { PS: 22, PP: 20 }
  combat: { initiative: 5, roll: 4, attacks: 2 }
  saves: { psionics: 4, mind_control: 5, spell_magic: 1, horror_factor: 6, toxins_poisons: 6, harmful_drugs: 6, coma_death_pct: 20 }
psionics:
  type: "master"
  isp_base: "M.E. + 1d6x10, +10 per level"
  powers_starting: 6
  categories_allowed: ["Sensitive"]
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot Hovercraft (+10%)." }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "Printed as Pilot Motorcycle (+10%)." }
    - { name: "Sensory Equipment", base: 35, per_level: 5, note: "Printed as Read Sensory Equipment (+5%)." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 28, per_level: 4, note: "+8%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "Printed as Climb (+10%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Detect Ambush", "Escape Artist", "Intelligence"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Electrical and Mechanical are both None for a Psycho-Stalker and are therefore absent from this list rather than restricted. Four related skills is the smallest allowance of any class in this book, and the schedule is the slowest - one more at level four and one at level eight, and nothing after that."
  secondary_skills:
    count: 6
special_abilities:
  - name: "Bio-Feedback: Become a Mega-Damage Creature"
    description: "By refocusing psychic energy the Psycho-Stalker turns ALL his S.D.C. and hit points into M.D.C. for one minute (four melee rounds) per level of experience. It costs 25 I.S.P., and while it lasts he can use NO other psychic ability. His already-supernatural Speed and Strength become supernatural in the damage sense too. The transformation also burns Potential Psychic Energy and leaves him hungering for at least 20 P.P.E.: the craving is intense enough that he is irritable and distracted, at -3 on initiative, until he feeds."
  - name: "Psi-Stalker Powers"
    description: "Every power of the Psi-Stalker R.C.C. carries over, except its physical and saving throw bonuses, which are already counted in the numbers above. That means sensing psychic and magic energy, sensing supernatural beings, nourishment - he lives on P.P.E., usually 50 to 100 a week, and needs neither food nor water - and psionic empathy with animals. RANGE ON ALL OF THEM IS HALVED: for reasons researchers do not understand, the Juicer process interferes with psionics and sometimes destroys them outright."
  - name: "Sensitive Psionics"
    description: "Six powers from the Sensitive category, and master psionic for the purpose of saving throws. Range is halved here too."
  - name: "Super Endurance"
    description: "Lifts and carries four times what an equivalent person could, lasts five times longer before exhaustion, stays alert and fully efficient for up to five days without sleep and normally needs only three hours a night."
  - name: "Super Speed"
    description: "The fastest of the Coalition''s Juicers - leap 30 feet (9.1 m) across after a short run, half from a standstill, and 20 feet (6 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal and is virtually impervious to pain, as per the normal Juicer. The +20% to save versus coma and death is in the bonuses block."
side_effects: "Life span is a normal Juicer''s, 5 years plus 4D6 months, with the usual insomnia, restlessness and impatience - and then the last two years are their own thing. The Psycho-Stalker becomes ravenously hungry for P.P.E., needing 150 to 250 points a week just to subsist, and LOSES ALL PSIONIC POWERS, including the natural ability to sense the supernatural and magic and the empathy with animals. The book compares it to a human losing sight or hearing. Many go berserk and hunt supernatural beings or practitioners of magic for the P.P.E.; the worst become psychotic murderers consumed with hunting, killing and feeding, which is where the name comes from. The save versus psionics above does NOT add M.E. bonuses."
restrictions: ["No cybernetics, ever, except bio-systems if absolutely necessary.", "Available only from the CS military - there is no conversion cost because there is no way to buy it.", "Cannot be transformed into a Murder-Wraith: the psychic abilities prevent the necromantic rituals from taking effect."]
extraction_notes: "starting_money is one month''s pay at 2,500 credits plus room and board. The six Sensitive powers are stored as powers_starting with categories_allowed, and the halved range on every psionic power - natural and learned - is prose, because the app has no range modifier. The Bio-Feedback transformation converts S.D.C. and hit points into M.D.C. temporarily and so is an ability rather than an mdc_base: a Psycho-Stalker is an S.D.C. being who can spend I.S.P. to stop being one."
---

## Lore

The Psycho-Stalker was an accident, made of bureaucracy and a doctor who should
have known better.

During the formation of the Chi-Town 1st Special Forces Battalion, Colonel Lyboc
wanted a mixed force - secret Juicers, ''Borgs and a number of Psi-Stalkers - for
the best combination of firepower, mobility and anti-supernatural capability.
Volunteers were transferred in from other units to be augmented at one of
Lyboc''s body-chop-shops. Then somebody mixed up two transfer orders. A
Psi-Stalker named John Dow was sent for Juicer augmentation on the paperwork of a
John Doe who was eligible for it.

This was against regulations twice over: augmenting Psi-Stalkers and mutant
animals was strictly forbidden, and every previous attempt had killed the
patient. Standard procedure would have been to report the mistake and send him
back. But the cyber-doc running that shop was a brilliant madman named Shane
"Miracle Worker" Charleston, who saw a challenge. Years earlier he had studied
the strange metabolism of Psi-Stalkers, who need little food or water and live
off the P.P.E. of other beings. With that knowledge and some specially prepared
drugs, he made a Juicer Psi-Stalker.

The result exceeded everyone''s expectations. The creature could channel his
I.S.P. into his own body and temporarily become a mega-damage being. To Shane''s
chagrin, Dow used that power to punch through a wall of the shop and leave. The
first Psycho-Stalker has not been heard of since - the explosives and other
implants had not been installed yet.

Lyboc decided to make more anyway. There are about a hundred under his command
now. The augmentation is top secret and carefully guarded, and it will not fall
into anyone else''s hands.

## GM Notes

**Demographics.** Psycho-Stalkers are 1% of all Juicers in North America.

**The CS made something it does not want.** The leadership is leery of running
this augmentation on "D-Bees" even with a bomb implant as reassurance. A
Psycho-Stalker is simultaneously an elite CS asset and a thing his own command
finds distasteful, which is most of the character right there.

**Four related skills and the slowest schedule in the book.** The trade is
explicit: he is the only Juicer who is also a psychic and a supernatural hunter,
and he knows less about everything else than any other Juicer in these pages.

**The last two years are the story.** Every Juicer''s Last Call is grim. This one
goes blind and deaf in the senses that defined him, and gets hungrier at the same
time. A Psycho-Stalker approaching the end is a problem the party will have to
solve one way or the other.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'psycho-stalker');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'psycho-stalker';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-psycho-stalker-class.sql');
