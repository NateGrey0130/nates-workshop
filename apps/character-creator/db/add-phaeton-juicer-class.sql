-- Phaeton Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.35-36.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-phaeton-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs before this file
-- was generated: 0 errors, 0 warnings.
--
-- The master pilot. Ultra-Tech Industries built it to take G-forces that black out a normal human, and it is the only Juicer whose stat block understates him - most of his bonuses only exist in a cockpit.
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
SELECT 'phaeton-juicer', 'Phaeton Juicer', 'rifts', '---
id: phaeton-juicer
name: Phaeton Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.35-36
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "elf", "ogre"]
  note: "Juicer Uprising p.17 bars Dwarves from this variant by name: the Phaeton''s reflex enhancements literally burn out the Dwarven nervous system, as they do the Hyperion''s. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet."
hit_points_base: "P.E. + 4d6, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "4d6x100"
bonuses:
  attributes: { PS: "2d4", PE: "2d6", PP: "2d6", Spd: "2d4x10" }
  attribute_minimums: { PS: 20, PP: 22 }
  combat: { initiative: 3, roll: 4, attacks: 1 }
  saves: { psionics: 4, mind_control: 4, toxins_poisons: 6, harmful_drugs: 6, horror_factor: 4, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Basic Math (+20%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Navigation", base: 55, per_level: 5, note: "+15%" }
    - { choose: 6, categories: ["Pilot"], bonus: 15, note: "Piloting: SIX of choice at +15%, and TWO favourites of those six at +25% instead. The picker applies the flat +15%; add the further +10% by hand to the two the character favours, usually aircraft." }
    - { name: "Weapon Systems", base: 55, per_level: 5, note: "+15%" }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: one of choice (+10%)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Wilderness Survival"], bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", bonus: 15 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Advanced", "Astronomy"], bonus: 5 }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "The book says these seven should tend to reflect an affinity for machines or piloting. Medical is None for a Phaeton and is therefore absent rather than restricted. Two bonuses the category key cannot carry because they name single skills: Rogue is +10% on Computer Hacking ONLY, and Technical is +10% on Computer Operation and Computer Programming only. Espionage lists Wilderness Survival, which this catalog files under Wilderness - the class grants that category too, so the pick works."
  secondary_skills:
    count: 3
special_abilities:
  - name: "Pushing the Envelope"
    description: "Phaetons are conditioned to be naturals at piloting almost anything, and can pull manoeuvres that would crush a normal pilot under the stresses of inertia. +15% to fly or pilot any vehicle they are trained with, and +25% on two favourite vehicle types of choice."
  - name: "Unfamiliar Vehicles"
    description: "Faced with a vehicle he has no training in, the Phaeton pilots it anyway at a base 40% plus 1% per level, plus I.Q. bonus. A very alien and difficult vehicle - some Splugorth models - is 25% plus 1% per level plus I.Q. bonus. This gets him into the seat only: it does NOT let him use alien weapon or sensor systems, and the G.M. may rule that psionic or magical controls will not answer to him at all."
  - name: "One With the Machine"
    description: "In a vehicle the Phaeton is a different character: +4 on initiative rather than +3 while piloting a light land or air vehicle, TWO extra attacks per melee instead of one, +1 to strike and dodge while piloting anything, and +2 to dodge in the air. He can dodge even in a vehicle that has no dodge at all, such as a tank, provided it is making at least 60 mph (96 kmph)."
  - name: "Super Endurance"
    description: "Lifts and carries four times what an equivalent person could, lasts five times longer before exhaustion, stays alert and fully efficient for up to four days without sleep and normally needs only four hours a night."
  - name: "Super Speed"
    description: "Leap 30 feet (9.1 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal and is virtually impervious to pain, as per the normal Juicer. The +20% to save versus coma and death is in the bonuses block."
side_effects: "Low Life Span: the same as a normal Juicer, 5 years plus 4D6 months. The normal Juicer penalties apply - insomnia, restlessness, impatience - and the book singles out two triggers for a Phaeton: being kept waiting, and not being behind the wheel of something."
restrictions: ["No cybernetics."]
extraction_notes: "The vehicle-only combat bonuses are prose, not bonuses: the bonuses block is applied unconditionally, so the on-the-ground figures (+3 initiative, one extra attack) are the ones stored and the in-vehicle figures are described. Augmentation cost is 90,000-140,000 credits and is prose rather than starting_money, which is coin only. Standard equipment names a PAS Helmet and Juicer Assassin flex-plate armour, neither of which has a gear row yet."
---

## Lore

Phaetons were developed by Ultra-Tech Industries. The first prototypes were made
in the kingdom of Newtown, but the treatment did not go on sale until Newtown
joined the Coalition States, and it later reached the free city of Fort El
Dorado, a CS ally. The stated purpose was to create the ultimate combat pilot:
someone who could take G-forces that would black out a normal human, and push
any vehicle to the edge of what it could physically do.

It worked. Phaetons - named for the mythological figure who talked his way into
driving the sun chariot of the gods, and could not hold it - are less developed
in strength and endurance than other Juicers, and resemble the Hyperion in being
smaller and faster than the hulking standard. Put one in a cockpit, though, and
the Phaeton becomes one with the machine.

They have been popular ever since, and conversions are now offered in several
North American cities and kingdoms, pirated from Newtown or Fort El Dorado -
something that has made the Coalition very unhappy indeed.

## GM Notes

**Demographics.** Phaetons are 5% of all Juicers in North America.

**This is the only Juicer whose sheet understates him.** The stored bonuses are
the on-foot ones. In a vehicle he gains an extra attack again, another point of
initiative, +1 to strike and dodge, +2 to dodge in the air, and the ability to
dodge in something that cannot dodge. A Phaeton fought on the ground and a
Phaeton fought in the air are close to different characters.

**The unfamiliar-vehicle roll is a plot device.** 40% plus 1% per level to fly
something he has never seen is the answer to a locked hangar, a crashed
Splugorth skiff, or a stolen SAMAS - and the 25% version, plus the G.M.''s
standing veto on psionic and magical controls, is where it stops being one.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'phaeton-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'phaeton-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-phaeton-juicer-class.sql');
