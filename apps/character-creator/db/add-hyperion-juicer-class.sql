-- Hyperion Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.30-32.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hyperion-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs before this file
-- was generated: 0 errors, 0 warnings.
--
-- The speed demon. Born of an accidental overdose at Northern Gun, and the shortest-lived variant in the book at five years and 3D6 months.
--
-- FIFTEEN CLASSES, NOT ONE WITH VARIANTS. The obvious reading of a book called
-- "New Juicer Variants" is that `variants` is the mechanism. It is not. Each of
-- these prints its OWN O.C.C. Skills, its own O.C.C. Related Skills - the
-- Hyperion gets six where the standard Juicer gets eight, the Mega five, the
-- Titan and Phaeton and Delphi seven - its own Secondary Skills, its own
-- Standard Equipment, its own Money line, and its own numbered list of O.C.C.
-- Abilities and Bonuses. VARIANT_OVERRIDES reaches attribute dice, attribute
-- requirements, the pool bases and `bonuses`, and nothing else. It cannot touch
-- the skills block or special_abilities, and that is where these differ. Same
-- call as the RUE dragons, for the same reason.
--
-- RACE RESTRICTIONS DIFFER BETWEEN THEM, which is the other reason they cannot
-- be variants. Juicer Uprising p.17 lets a Dwarf take the standard, Titan, Mega
-- and Dragon Blood conversions and bars him from the Phaeton and the Hyperion
-- by name - their reflex enhancements burn out the Dwarven nervous system. The
-- Delphi is not on the permitted list, so Dwarves are left off it too: an
-- `only` list fails CLOSED, which is the conservative reading where the book is
-- silent. See zz-race-juicer-non-human.sql for the standard Juicer's own
-- widening and why RUE does not overrule this book.
--
-- CONDITIONAL BONUSES ARE PROSE. `bonuses:` is applied unconditionally, so the
-- Phaeton's in-vehicle figures and the Delphi's without-the-helmet halving are
-- described rather than stored. The stored numbers are the ordinary case.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'hyperion-juicer', 'Hyperion Juicer', 'rifts', '---
id: hyperion-juicer
name: Hyperion Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.30-32
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "elf", "ogre"]
  note: "The Juicer process is 95% human (RUE p.81). Juicer Uprising p.16-17 opens it to a few peoples, but this variant is the narrower case: the Hyperion''s reflex enhancements literally burn out the Dwarven nervous system, so Dwarves are barred where they may take the standard, Titan, Mega and Dragon Blood conversions. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify too but have no R.C.C. row in this catalog yet. Juicer Uprising p.17."
hit_points_base: "P.E. + 3d6, +1d6 per level"
sdc_base: "4d6x10"
starting_money: "4d6x100"
bonuses:
  attributes: { PS: "1d4+2", PE: "2d4", PP: "2d4", Spd: "2d4x10+40" }
  attribute_minimums: { PS: 18, PP: 20, Spd: 77 }
  combat: { initiative: 6, strike: 1, parry: 1, dodge: 1, roll: 4, attacks: 2 }
  saves: { psionics: 4, mind_control: 4, disease: 9, toxins_poisons: 9, harmful_drugs: 9, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "The book prints Physical as +5% where applicable, and Rogue as +5% with +15% on Prowl. This catalog files Prowl under Physical, and a category bonus is one number, so the flat +5% is carried and the Prowl figure is recorded here: a Hyperion taking Prowl should read it at +15%, not +5%. Electrical is Basic Electronics only, Mechanical is Automotive Mechanics only, Medical is First Aid only, Science is Basic Math only."
  secondary_skills:
    count: 5
special_abilities:
  - name: "Super Endurance"
    description: "Can lift and carry four times more than a normal person of equivalent strength, and lasts five times longer before feeling the effects of exhaustion. Can remain alert and operate at full efficiency for up to four days without sleep, and normally needs only four hours of sleep a day - but must consume at least 4,000 calories a day to function normally."
  - name: "Super Speed"
    description: "Where the Hyperion excels. Can leap 50 feet (15.2 m) lengthwise after a short run, half that from a dead stop, and 25 feet (7.6 m) high (half without a run). Kick attacks inflict 3D6 S.D.C. plus P.S. bonuses; a power kick counts as two attacks and inflicts 1D6 M.D."
  - name: "Super Reflexes and Reaction Time"
    description: "Faster than a normal Juicer. Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise. The combat numbers are in the bonuses block."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal and is virtually impervious to pain, as per the normal Juicer. The +20% to save versus coma and death is in the bonuses block."
  - name: "Burns Off Chemicals"
    description: "The high metabolism burns drugs and disease off quickly: symptoms and side effects last HALF their normal duration. The +9 to save versus disease, toxic gases, poisons and other drugs is in the bonuses block."
side_effects: "Low Life Span. Hyperions burn out even faster than common Juicers - the average life span of a Hyperion is 5 years and 3D6 months. Over-reaction: on top of the normal Juicer problems (insomnia, impatience), there is a 01-30% chance the Hyperion answers a startle or a sneak from behind with an instinctive punch or kick, and a loud noise within 20 feet (6.1 m) will send him spinning, back-flipping, diving, rolling or somersaulting to land facing the noise with weapons drawn. Voracity: the Hyperion must eat twice as much as a normal person or suffer low blood sugar, halving all combat bonuses after one day. 01-30% of all Hyperions suffer Metabolic Induced Voracity (MIV), also known as Juicer Gluttony."
restrictions: ["No cybernetics."]
extraction_notes: "Hit points are the base human progression plus the book''s +3D6, because a Hyperion is its own O.C.C. rather than an add-on to the standard Juicer - the book restates every number rather than referring back. Augmentation cost is 80,000-120,000 credits, sometimes more, and is prose rather than starting_money, which is coin only."
---

## Lore

Juicers are known for speed; the Hyperion takes it to the ludicrous. The fastest
Hyperions can keep pace with some land vehicles, and their reaction times are
blindingly fast. The price is that they are always restless and uncomfortable
when not moving, have a short attention span, are bored easily, and - worst of
all - require enormous amounts of food simply to stay alive.

The variant was born at Northern Gun in Ishpeming, by accident. A Juicer
tampered with his own bio-comp dispenser chasing a bigger rush, became
incredibly fast, broke every standing Juicer record, and collapsed from a heart
attack three hours later. The researchers who performed the autopsy wrote down
what they found, good and bad, and went looking for a faster Juicer on purpose.
A number of test subjects died before the Hyperion process worked.

It is not as widely available as the standard conversion, but most large
kingdoms that specialise in Juicer work can supply it.

## GM Notes

**Demographics.** Hyperions are 6% of all Juicers in North America, second only
to the 74% who are standard. In the New German Republic all variants combined
are about 10% of Juicers, and they are unheard of in Japan and most of the rest
of the world.

**The Hyperion is the shortest-lived of the variants** - five years and 3D6
months against the standard Juicer''s five to seven. A Hyperion character is
always closer to Last Call than the party thinks.

**Playing the over-reaction.** The 01-30% startle response is worth rolling
rather than hand-waving: an instinctive punch thrown at a friend who came up
quietly is a scene, and a Hyperion who dives and comes up armed at a dropped
plate is how the rest of the world learns to give Juicers space.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'hyperion-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'hyperion-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-hyperion-juicer-class.sql');
