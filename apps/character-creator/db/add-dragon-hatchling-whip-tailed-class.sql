-- Dragon Hatchling (Whip-Tailed), one of the six dragon species Rifts Ultimate Edition
-- details, printed p.163.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dragon-hatchling-whip-tailed-class.sql
--
-- Read from the RUE OCR cache at .cache/books/rue; printed page = cache page
-- minus three, folio-checked rather than assumed. Validated with
-- scripts/class-check.mjs --remote against the PRODUCTION catalog before this
-- file was generated: 0 errors, 0 warnings.
--
-- The water dragon: swims at 98% like an eel, breathes air and water, and carries a saber blade on its prehensile tail. The only one of the six whose psionics exclude Healing.
--
-- SIX SPECIES, SIX CLASSES, NOT ONE WITH VARIANTS. RUE prints a single R.C.C. -
-- "Dragon Hatchling", printed 156-158 - whose skills, magic, money and
-- cybernetics rules are common to all of them, and then six species. The shared
-- half would suit `variants` exactly. The species half does not:
-- VARIANT_OVERRIDES cannot override natural_abilities or special_abilities, and
-- that is exactly where these differ. A Snow Lizard's snowstorm form and a
-- Cat's-Eye's charm gaze are not attribute dice. So the common rules are
-- duplicated across six files deliberately, the same way the Demigod writes out
-- the Godling's powers instead of pointing at them.
--
-- THE SKILL SHAPE IS RUE'S, NOT THE ORIGINAL DRAGON'S. RUE gives a dragon no
-- related skills at all: two Secondary Skills at level one and two more at
-- levels 2, 4, 8, 10, 15 and 20, plus one "Special Area of Interest" at levels
-- 1, 3, 6, 9, 12, 15 and 20 at +15%. That special interest is modelled as the
-- related-skill allowance, because it is the only slot carrying both a level
-- schedule and a category bonus, and is restricted by `only` lists to exactly
-- what the book allows - Language: Other, Literacy: Other, Research and every
-- Lore skill. This catalog files Lore under Technical except two Cowboy ones,
-- which is why three categories are named to express one sentence.
--
-- The existing dragon-hatchling class is the GREAT HORNED from the original
-- Rifts core book, a species RUE does not carry at all - the word "Horned"
-- appears nowhere in its 382 pages. These six do not replace it and it does not
-- replace them; both editions are represented, each naming its own book.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'dragon-hatchling-whip-tailed', 'Dragon Hatchling (Whip-Tailed)', 'rifts', '---
id: dragon-hatchling-whip-tailed
name: Dragon Hatchling (Whip-Tailed)
system: rifts
source_book: Rifts Ultimate Edition p.163
category: rcc
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6+4"
  MA: "3d6+11"
  PS: "3d6+6"
  PP: "3d6+8"
  PE: "3d6+6"
  PB: "2d6+12"
  Spd: "3d6+16"
mdc_base: "1D4x100, +1D6+4 M.D.C. per level of experience"
sdc_base: "4d6x10"
hit_points_base: "1d4x100"
ppe_base: "3D4x10+10, +3D6 per level of experience"
magic:
  type: "spell"
  spells_starting: 0
psionics:
  type: "major"
  isp_base: "2D4x10, +1D6+4 per level of experience"
  powers_starting: 10
  categories_allowed: ["Sensitive", "Physical"]
  powers_schedule:
    - { level: 3, count: 1 }
    - { level: 6, count: 1 }
    - { level: 9, count: 1 }
    - { level: 12, count: 1 }
    - { level: 15, count: 1 }
    - { level: 18, count: 1 }
bonuses:
  combat: { attacks: 2, initiative: 3, strike: 2, parry: 2, dodge: 2, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0, note: "Instinctive." }
  occ_related_skills:
    count: 1
    categories:
      - { name: "Technical", only: ["Language: Other", "Research", "Lore: Astral", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15 }
      - { name: "Communications", only: ["Literacy: Other"], bonus: 15 }
      - { name: "Cowboy", only: ["Lore: American Indians", "Lore: Cattle & Animals"], bonus: 15 }
    note: "The book''s Special Areas of Interest and Expertise - one at levels 1, 3, 6, 9, 12, 15 and 20, each at +15%. Language: Other (any), Literacy: Other (any), Lore (all) and Research; dragons love language."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
      - { level: 20, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 15, count: 2 }
      - { level: 20, count: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "To 500 feet (152 m)."
  - name: "Hawk-Like Vision"
    description: "Sees a rabbit clearly at up to two miles (3.2 km), and sees in murky or dark water."
  - name: "See the Invisible"
    description: "Always active."
  - name: "Turn Invisible Underwater or in Rain"
    description: "At will, but only underwater or in the rain."
  - name: "Resistant to Fire and Cold"
    description: "Half damage, including mega-damage magic fire and plasma energy."
  - name: "Bio-Regeneration"
    description: "1D10 M.D.C. per melee round, or 1D4x10 per minute, and severed limbs - tail, fins, arms - regrow in 1D4 hours."
  - name: "Amphibious"
    description: "A natural swimmer at 98%, swimming like an eel, breathing both air and water and living indefinitely in either. Maximum depth two miles (3.2 km)."
  - name: "Navigator"
    description: "Knows the time of day and direction by scanning the heavens and tides at 50% +3% per level, and senses the direction and speed of currents and tides, changes in them, weather patterns and dramatic underwater disturbances within 10 miles (16 km) at 50% +3% per level."
  - name: "Metamorphosis"
    description: "Completely alters its physical shape to look like any living animal, from a human being to a house cat, for two hours per level of experience - tripled on or near a ley line or nexus point within two miles (3.2 km). Never an inanimate object or an insect; minimum size about that of a cat, maximum its own. A dragon in another shape keeps every one of its own powers and gains none of the animal''s."
  - name: "Teleport"
    description: "24% +2% per level of experience, at will, up to five miles (8 km). A hatchling can teleport only itself and may attempt one every other melee round; a failed roll means it did not happen. Only a mature dragon teleports dimensionally without a ley line nexus - a hatchling may try at a nexus at half the usual percentage."
  - name: "Saber Tail"
    description: "The prehensile tail is armed with a huge slashing saber blade. It strikes for punch damage +2D6 M.D., and the dragon is +4 to strike with it specifically."
  - name: "Fire Breath"
    description: "2D6 M.D. to a three foot wide (0.9 m) area, hitting only one opponent at a time. It works underwater at half range, coming out as a jet of boiling water. Range 100 feet (30.5 m); each blast counts as one attack."
  - name: "Claws and Bite"
    description: "Claws inflict +6 M.D. on top of supernatural P.S. damage; the bite does 2D4 M.D. with no P.S. bonus."
restrictions:
  - "Alignment: any. Most hatchlings begin as Unprincipled or Anarchist and behave like a child of four to seven - self-serving, self-obsessed, a little snotty, liable to wander off. At level three the player must settle on a definitive alignment."
  - "Horror Factor: 11."
  - "Speed: 3D6+16 running, 2D6x10 swimming, 1D4x10+40 flying."
  - "MAGIC: knows NO spells at first level. Spells are learned by the usual means from second level - by third level the hatchling has 2D4+2 spells from levels 1-3, another 2D4+2 by fifth level from levels 3-8, and 3 new spells per level thereafter up to its own level. Two spells may be cast per melee round, and it gains +1 to spell strength at level nine. Those counts are dice-valued, which a spell schedule cannot hold, so they are recorded here."
  - "It understands magic fully without knowing spells: it uses any techno-wizard device without instruction, recognises and uses magic weapons, reads magic, uses scrolls, and recognises magic circles and enchantment at 40% +3% per level. It senses ley lines and nexus points within 20 miles (32 km) and other dragons - even metamorphosed ones - on sight to 4000 feet (1219 m). Sensing gives nearness and direction, never a pinpoint."
  - "PSIONICS: Ten powers from Sensitive or Physical only - NOT Healing, unlike four of the other five. Super Psionics are not available."
  - "Size: about 30 feet (9.1 m) snout to tail and 4-8 tons; metamorphosis adjusts that by up to 50% either way. A hatchling reaches 80% of full size within 3D4 weeks of hatching and is not mature until 600 years old."
  - "Dragons do not need to eat or drink - as creatures of magic they absorb magic energy - and do so only for the pleasure of it."
  - "Cybernetics and bionics: NONE, ever. The bio-regenerative powers reject implants and push them back out as the body heals."
  - "Money: a hatchling under 100 years old is not much interested in wealth or power, though always drawn to magic items. It wants to see the world."
  - "Weapons and equipment: it can use any weapon and may wear little or nothing, mega-damage armour included, except as part of a disguise."
  - "Only the dragon''s I.Q. bonus applies to secondary skills. The level 18-22 grants recorded above come from the book; this app caps a character at level 15, so they will not fire."
  - "+1 on Perception Rolls and +1 on all saving throws not listed above."
  - "One of the two attacks per melee is ALWAYS with the prehensile tail."
  - "+4 to strike applies to the saber tail specifically, not to every attack, so it is recorded on the ability rather than in the bonuses block."
  - "It has no wings, but can still fly by magical means."
side_effects: "One of the dragon species Rifts Ultimate Edition details, printed p.163. All dragons are creatures of magic sustained by magic energy rather than food, reaching 80% of full size within 3D4 weeks of hatching and full maturity only at 600 years old. The average life span is 6,000 to 8,000 years, and some live 12,000."
extraction_notes: |
  Read from Rifts Ultimate Edition p.163 via the OCR cache at
  .cache/books/rue (printed page = cache page minus 3, folio-checked).

  SIX SPECIES, SIX CLASSES, NOT ONE WITH VARIANTS. RUE prints one R.C.C. -
  "Dragon Hatchling", printed 156-158 - whose skills, magic, money and
  cybernetics rules are common to all of them, then six species. The shared half
  would suit `variants` exactly. The species half does not: VARIANT_OVERRIDES
  cannot override natural_abilities or special_abilities, and that is precisely
  where these differ. A Snow Lizard''s snowstorm form and a Cat''s-Eye''s charm
  gaze are not attribute dice. So the common rules are duplicated across six
  files, deliberately, the same way the Demigod writes out the Godling''s powers
  rather than pointing at them.

  1. THE SKILL SHAPE IS RUE''S, NOT THE ORIGINAL DRAGON''S. RUE gives a dragon no
     related skills at all: two Secondary Skills at level one and two more at
     levels 2, 4, 8, 10, 15 and 20, plus one "Special Area of Interest" at
     levels 1, 3, 6, 9, 12, 15 and 20 at +15%. The special interest is modelled
     as the related-skill allowance because that is the only slot with a level
     schedule and a category bonus - restricted by `only` lists to exactly what
     the book allows: Language: Other, Literacy: Other, Research and every Lore
     skill. Lore is filed under Technical here except two Cowboy ones, which is
     why three categories are named to express one sentence.
  2. NO SPELL SCHEDULE. The progression is dice-valued - 2D4+2 by level three,
     another 2D4+2 by five - and `spells_schedule` counts are numbers. Recorded
     as prose rather than rounded into a number that would be wrong every time.
  3. The three instinctive skills are granted at 98% with no per-level gain: the
     book calls them instinctive, not trained.
  4. Perception Roll bonuses are recorded as prose throughout. The sheet has no
     Perception key, and inventing one for six classes would be the wrong place
     to start.
  5. Level 18, 20 and 22 grants are transcribed from the book and will never
     fire, the app capping a character at 15. Kept because the book prints them
     and a truncated ladder reads as a transcription error later.
---

## Lore

The Whip-Tailed Dragon is the water dragon of the six: a natural swimmer at 98%,
moving like an eel, breathing air and water alike and living indefinitely in
either to a depth of two miles. It has no wings and flies only by magic.

Its tail is the point. Where the other prehensile-tailed species whip with
theirs, the Whip-Tailed carries a huge slashing saber blade on the end of it,
and one of its two attacks each round is always the tail.

## GM Notes

An underwater campaign character, and the only one of the six built for it. The
navigation senses are worth remembering - direction and time of day from the
heavens and tides, plus currents, weather and "dramatic underwater disturbances"
within ten miles. That last phrase is an adventure hook wearing a percentage.

Note its psionics are Sensitive or Physical only. It is the one hatchling that
cannot take Healing powers.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dragon-hatchling-whip-tailed');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dragon-hatchling-whip-tailed';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dragon-hatchling-whip-tailed-class.sql');
