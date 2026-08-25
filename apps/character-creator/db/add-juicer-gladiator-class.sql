-- Juicer Gladiator, one of the five Juicer-Related O.C.C.s Rifts World
-- Book Ten: Juicer Uprising defines, printed p.55-56.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-juicer-gladiator-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- A Juicer who fights in the arena for money. Starts at Martial Arts, picks one sport to be +1/+10% in, and cannot go anywhere unrecognised afterwards.
--
-- THIRD AND LAST BATCH. See add-hyperion-juicer-class.sql for why this book's
-- fifteen classes are fifteen rows rather than one with `variants`.
--
-- THIS SECTION HAS A SHAPE OF ITS OWN. The book introduces it by saying Juicers
-- can pursue other areas of training "but always as a Man of Arms", that each
-- entry "requires the character to be a Juicer", and that "all Juicer bonuses
-- and penalties remain the same, only the training/skill programs and some
-- bonuses vary". So the Gladiator, the Assassin and the Scout print SKILLS AND
-- NOTHING ELSE - no attribute dice, no pools, no saving throws.
--
-- The app models ONE OCCUPATION PER CHARACTER and cannot compose a Juicer with
-- a training programme laid over it. Rather than ship three classes that
-- produce an incomplete sheet, each carries the STANDARD Juicer's numbers,
-- which is the default the book itself names two sentences later: "Use the
-- experience table for the 'standard' Juicer O.C.C. unless one of the new
-- Juicer variants." A Gladiator who is a Hyperion substitutes the Hyperion's
-- numbers and keeps the skill programme, and every one of the three says so in
-- its special_abilities and its extraction_notes.
--
-- AND TWO OF THE FIVE ARE NOT JUICERS AT ALL. The book is explicit: "The
-- Gambler and Juicer Wannabe are not Juicers, but characters who are often
-- associated with them." Those two get no Juicer bonuses, no pools of their
-- own, occ_group `optional` rather than men-of-arms, and a CORE_SDC_BY_CLASS
-- entry at 1D6 - because a class stating neither an sdc_base nor an mdc_base
-- needs one, and neither of them is a man of arms.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'juicer-gladiator', 'Juicer Gladiator', 'rifts', '---
id: juicer-gladiator
name: Juicer Gladiator
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.55-56
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "A Juicer Gladiator is a Juicer first, so it carries the standard Juicer''s racial line as widened by Juicer Uprising p.16-17: Dwarves, Elves and Ogres alongside the human case. Any Juicer variant may take this training programme, and the narrower variants keep their own bars - a Hyperion or Phaeton Gladiator still cannot be a Dwarf."
hit_points_base: "P.E. + 1d4x10, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "1d4x1000"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", Spd: "2d4x10" }
  attribute_minimums: { PS: 22 }
  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }
  saves: { psionics: 4, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Gymnastics", base: 30, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Two languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Performance", base: 40, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "The book says W.P. Ancient, two of choice. This catalog files every W.P. under one Weapon Proficiencies category rather than the book''s Ancient/Modern split, so the ancient ones are listed out." }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "The Gladiator starts at Martial Arts, not Expert - and has nothing to trade for a further upgrade." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 11, count: 1 }, { level: 13, count: 1 }]
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Military: Jet Fighters", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats"], bonus: 5 }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Electrical, Espionage and Military are all None for a Gladiator and are therefore absent from this list rather than restricted - he is an athlete, not a soldier. Pilot is any except robots and military vehicles, spelled out as the catalog rows it excludes because an unmatched except excludes nothing and does so silently."
  secondary_skills:
    count: 5
special_abilities:
  - name: "Sport Specialty"
    description: "The Gladiator picks ONE sport to specialise in. Practising that sport he is +1 to strike, parry and dodge and +10% on skill rolls specifically related to it, on top of every other O.C.C. and skill bonus. The bonuses apply to that sport ONLY - not to another sport, and not to the real world. The common Juicer sports are Deadball, Juicer Football and Murderthon, and also boxing, wrestling, swimming, fencing and archery."
  - name: "Standard Juicer Abilities"
    description: "Everything the Juicer O.C.C. has: super endurance, strength, speed and reflexes, the automatic parry or dodge against attacks from behind and by surprise, enhanced healing, and virtual imperviousness to pain. The numbers in the bonuses block are the STANDARD Juicer''s, per the book''s own instruction; a Gladiator who is a Hyperion, Titan, Phaeton, Mega or Delphi substitutes that variant''s numbers and keeps this skill programme."
side_effects: "Standard Juicer, 5 years plus 4D6 months, with the usual insomnia, restlessness and impatience - or the variant''s, if the character is one. FAME IS ITS OWN PROBLEM. A Gladiator who leaves the arena for other Juicer work finds his former celebrity cuts both ways: some people are intimidated by the notoriety, others take it as a challenge, and it is very hard to stay anonymous when your face has been broadcast on televisions and passed around on video-tapes across the country."
restrictions: ["Requires the character to be a Juicer of some variety - this is a training programme, not a conversion.", "Superbly trained athletes, but LESS experienced in real combat than a regular Juicer, and often ignorant about wilderness living, modern weapons and the Coalition States. The book says the inexperience gets them killed through overconfidence and foolish mistakes."]
extraction_notes: "THE NUMBERS IN bonuses ARE THE STANDARD JUICER''S, deliberately. The book prints only \"Same bonuses as their Juicer type, with skills described below\" for this class and gives no figures of its own, and it says elsewhere to use the standard Juicer''s experience table unless the character is one of the new variants. So the standard is the default the book itself names, carried here so a Gladiator produces a complete sheet; the substitution for a variant is stated in the ability text. The app models one occupation per character, so the Juicer-plus-training-programme shape cannot be composed. Money Bonus of 1D4x1000 credits is stored as starting_money."
---

## Lore

Not all Juicers use what they are as warriors or assassins. In places where
combat sports are popular a few become sports stars: professionals who fight,
and die, in hidden arenas for other people''s entertainment, much like the
gladiators of old.

Juicer Gladiators are superbly trained athletes and are less experienced in
actual combat than regular Juicers. They tend not to know much about living in
the wilderness, about modern weapons, or about the Coalition States, and that
inexperience gets a lot of them killed - overconfidence, and foolish mistakes.

Sports Juicers do not always stay in the sport. Some leave the crowds and the
blood and the glory behind and try their hand at other Juicer work, and there
they find that the fame follows them.

## GM Notes

**The sport specialty is worth choosing carefully.** +1 to strike, parry and
dodge and +10% on related skill rolls is a large bonus that is deliberately
useless everywhere except inside one game. A Deadball specialist in a firefight
is just a Juicer.

**Three skills in this book exist mostly for this class.** Deadball, Juicer
Football and Murderthon were imported alongside these classes, and a Gladiator
is the character they were written for.

**Fame is a hook and a liability.** The book is explicit that a retired
Gladiator cannot go unnoticed. Anyone who watched the broadcasts knows the face,
and some of them will want to find out whether the arena record was real.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'juicer-gladiator');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'juicer-gladiator';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-juicer-gladiator-class.sql');
