-- Mega-Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.36-39.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mega-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs before this file
-- was generated: 0 errors, 0 warnings.
--
-- A minor supernatural creature made from a latent psychic. M.D.C. equal to four times P.E., regenerating - and a cumulative 15% per month after year five that he burns out into a walking explosion.
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
SELECT 'mega-juicer', 'Mega-Juicer', 'rifts', '---
id: mega-juicer
name: Mega-Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.36-39
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "Juicer Uprising p.17 names the Mega-Juicer as one of the three variants a Dwarf may take, along with Titan and Dragon Blood, and the standard conversion. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet."
mdc_base: "P.E. x4, +2d4 per level"
starting_money: "5d6x100"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", PP: "2d4", Spd: "2d4x10" }
  attribute_minimums: { PS: 25, PP: 20 }
  combat: { initiative: 4, roll: 4, attacks: 2 }
  saves: { psionics: 5, mind_control: 6, spell_magic: 3, toxins_poisons: 6, harmful_drugs: 6, horror_factor: 6, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Piloting: two of choice (+10%)." }
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
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Medical is None for a Mega-Juicer and is therefore absent rather than restricted. Rogue is printed with +10% to Prowl only; this catalog files Prowl under Physical and a category bonus is one number, so a Mega-Juicer taking Prowl should read it at +10% on top of the Physical +5%."
  secondary_skills:
    count: 6
special_abilities:
  - name: "Minor Supernatural Creature"
    description: "The triggering process infuses the body with psychic energy, giving skin and muscle the tensile strength of M.D.C. alloys while keeping the elasticity of normal skin. In trials, .45 rounds were fired point-blank without bruising the subject, and laser pistols left painful burns that healed in minutes. It takes enough firepower to destroy a suit of power armour to kill one."
  - name: "Supernatural Strength"
    description: "The Mega-Juicer''s P.S. is SUPERNATURAL: carry 50 times P.S. in pounds and lift 100 times P.S. Damage follows the supernatural strength table."
  - name: "Super Endurance"
    description: "Stays alert and fully efficient for up to SEVEN days without sleep, and normally needs only three hours a night - the longest waking span of any Juicer."
  - name: "Super Speed"
    description: "Leap 30 feet (9.1 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Regeneration"
    description: "Regenerates 2D6 M.D.C. every hour. Virtually impervious to pain, to disease, and to normal ranges of heat and cold. The +20% to save versus coma and death is in the bonuses block."
side_effects: "BURNOUT. A Mega-Juicer lives as long as a normal Juicer, with one difference. After the fifth year of service there is a CUMULATIVE 15% chance per month of psychic overload. First the eyes glow so brightly that neither sunglasses nor a mirrored face plate will hide them; then the whole skin begins to glow. 1D4 weeks after those first symptoms the glow burns anything that touches him for 2D6 S.D.C. and ignites flammables. 1D4 weeks after that the aura reaches 1D6 M.D. and the ground melts to lava under his feet. 1D6 days after the flames turn mega-damage he begins taking 4D6 M.D. per day himself, which cannot be regenerated, until he is consumed. If he is killed or dies at any of these stages he EXPLODES for 4D6x10 M.D. to a 30 foot (9.1 m) radius. There is no known cure. Most Mega-Juicers who start showing symptoms are killed from a safe distance or exiled into the wilderness."
restrictions: ["No cybernetics.", "Requires minor, major or master psionics, or a high P.P.E. of 30 or more - only latent psychics, an estimated 15% of volunteers, benefit from the drug treatments at all."]
extraction_notes: "The psionic-or-high-P.P.E. entry requirement is a restriction rather than an attribute_requirement: the app''s attribute_requirements take numeric minimums on the eight attributes, and P.P.E. is a pool. The book''s Attribute Requirements line is exactly that sentence and nothing numeric. M.D.C. is a formula, P.E.x4 with 2D4 per level, so the class states mdc_base and no sdc_base - a Mega-Juicer IS a mega-damage being rather than a human with a big S.D.C. total, which is what separates him from the Titan. Augmentation cost is 200,000-400,000 credits, two to three times an ordinary Juicer, and is prose rather than starting_money, which is coin only. Standard equipment names Mega-Juicer Combat Armor at 130 M.D.C., which has no gear row yet."
---

## Lore

> "If you wanna be tough, become a Juicer. If you wanna be a GOD, become a
> Mega-Juicer."
> - sign outside an Ishpeming body-chop-shop

The most advanced Juicer ever created, and the most expensive. The conversion is
available only in Ishpeming - Northern Gun - and, recently, in Kingsdale.

A research team there unearthed secret pre-Rifts super-soldier projects that had
combined elements of M.O.M. conversion with the Juicer process. The idea was to
take volunteers who already carried high levels of psychic energy, trigger that
energy with drugs and electrical implants, and channel it through the body until
the subject became something of incredible strength and endurance. Ordinary
Juicer chemistry was layered on top to finish the job.

In the P.P.E.-rich air of Rifts Earth the result is a minor supernatural
creature. It could never replace ordinary augmentation, though: only latent
psychics benefit, perhaps 15% of volunteers; the process costs two to three
times what a Juicer costs; and recovery takes twice as long, since it involves
regular Juicer surgery followed by the implantation of stimulators that channel
psychic energy in a continual bio-feedback loop.

The other problem was not discovered until five years after the first subjects
were released. The bio-feedback energies eventually overload.

## GM Notes

**Demographics.** Mega-Juicers are 2% of all Juicers in North America - joint
rarest of the common variants with the Coalition Juicer, and far rarer than the
Hyperion or Titan.

**Burnout is the campaign clock, and it is a different clock.** Every other
Juicer dies on a schedule. A Mega-Juicer rolls for it: cumulative 15% per month
after year five, and once it starts the party has roughly two months of warning
before he becomes a walking mega-damage hazard, and rather less before someone
decides to shoot him from a safe distance. The 4D6x10 M.D. death explosion means
that killing him is not a solution either.

**He is the only Juicer who is meaningfully hard to hurt.** M.D.C. equal to four
times P.E., regenerating 2D6 an hour, impervious to disease and to ordinary heat
and cold. Against S.D.C. weapons he is untouchable; against a rail gun he is a
lightly armoured human.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'mega-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'mega-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mega-juicer-class.sql');
