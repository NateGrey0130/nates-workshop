-- Dragon Hatchling (Flame Wind), one of the six dragon species Rifts Ultimate Edition
-- details, printed p.160-161.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dragon-hatchling-flame-wind-class.sql
--
-- Read from the RUE OCR cache at .cache/books/rue; printed page = cache page
-- minus three, folio-checked rather than assumed. Validated with
-- scripts/class-check.mjs --remote against the PRODUCTION catalog before this
-- file was generated: 0 errors, 0 warnings.
--
-- Sets its own scales alight without harming itself, damaging everything it carries and igniting whatever it touches. The flames run one minute per level, then need ten minutes to regenerate.
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
SELECT 'dragon-hatchling-flame-wind', 'Dragon Hatchling (Flame Wind)', 'rifts', '---
id: dragon-hatchling-flame-wind
name: Dragon Hatchling (Flame Wind)
system: rifts
source_book: Rifts Ultimate Edition p.160-161
category: rcc
attribute_dice:
  IQ: "3d6+5"
  ME: "3d6+5"
  MA: "3d6+5"
  PS: "3d6+5"
  PP: "3d6+10"
  PE: "3d6+10"
  PB: "3d6+5"
  Spd: "3d6+10"
mdc_base: "1D4x100, +10 M.D.C. per level of experience"
sdc_base: "3d6x10"
hit_points_base: "1d4x100"
ppe_base: "2D4x10+10, +3D6 per level of experience"
magic:
  type: "spell"
  spells_starting: 0
psionics:
  type: "minor"
  isp_base: "1D6x10, +1D8 per level of experience"
  powers_starting: 6
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 5, count: 1 }
    - { level: 10, count: 1 }
    - { level: 15, count: 1 }
    - { level: 20, count: 1 }
bonuses:
  combat: { attacks: 1, initiative: 2, strike: 2, parry: 2, dodge: 2, pull_punch: 4, roll: 2 }
  saves: { horror_factor: 4, spell_magic: 2, ritual_magic: 2, illusionary_magic: 2 }
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
    description: "To 100 feet (30.5 m)."
  - name: "Thermal Vision"
    description: "Sees the heat within an object and gauges its temperature at 45% +5% per level, to 300 feet (91.5 m)."
  - name: "Turn Invisible at Will"
    description: "At will."
  - name: "Impervious to Fire"
    description: "Not even mega-damage fire hurts it."
  - name: "Prehensile Tail"
    description: "Strikes like a whip for punch damage +1D6 M.D."
  - name: "Bio-Regeneration"
    description: "1D10 M.D.C. per melee round, or 1D4x10 M.D.C. per minute."
  - name: "Metamorphosis"
    description: "Completely alters its physical shape to look like any living animal, from a human being to a house cat, for one hour per level of experience - tripled on or near a ley line or nexus point within two miles (3.2 km). Never an inanimate object or an insect; minimum size about that of a cat, maximum its own. A dragon in another shape keeps every one of its own powers and gains none of the animal''s."
  - name: "Teleport"
    description: "22% +2% per level of experience, at will, up to five miles (8 km). A hatchling can teleport only itself and may attempt one every other melee round; a failed roll means it did not happen. Only a mature dragon teleports dimensionally without a ley line nexus - a hatchling may try at a nexus at half the usual percentage."
  - name: "Flaming Scales"
    description: "The dragon bursts into flame, its own scales burning without harming it - a natural part of its metabolism. Everything it carries is damaged by its own flames and it ignites whatever it touches: carpet, drapes, paper, wood, dry grass. A fiery punch or tail swipe does an extra 2D6 M.D. on top of P.S. damage, and leaping on its back or trying to wrestle or entangle it inflicts 4D6 M.D. every four seconds, or 2D4x10+10 M.D. per melee round. Maintained for one minute (4 melee rounds) per level of experience, after which it must rest ten minutes to regenerate the scales."
  - name: "Fire Breath"
    description: "4D6 M.D. to a six foot wide (1.8 m) area, catching 2-6 opponents huddled together, range 100 feet (30.5 m). It may instead fire small gouts like a flamethrower for 2D6 M.D. to 300 feet (91.5 m). Usable as often as desired, each blast counting as one attack."
  - name: "Claws and Bite"
    description: "Claws inflict +8 M.D. on top of supernatural P.S. damage; the bite does 2D4 M.D. with no P.S. bonus."
restrictions:
  - "Alignment: any. Most hatchlings begin as Unprincipled or Anarchist and behave like a child of four to seven - self-serving, self-obsessed, a little snotty, liable to wander off. At level three the player must settle on a definitive alignment."
  - "Horror Factor: 12, and 14 when it bursts into flame."
  - "Speed: 3D6+10 running, but 3D6x10 flying."
  - "MAGIC: knows NO spells at first level. Spells are learned by the usual means from second level - by third level the hatchling has 2D4+2 spells from levels 1-3, another 2D4+2 by fifth level from levels 3-8, and 3 new spells per level thereafter up to its own level. Two spells may be cast per melee round, and it gains +1 to spell strength at level nine. Those counts are dice-valued, which a spell schedule cannot hold, so they are recorded here."
  - "It understands magic fully without knowing spells: it uses any techno-wizard device without instruction, recognises and uses magic weapons, reads magic, uses scrolls, and recognises magic circles and enchantment at 40% +3% per level. It senses ley lines and nexus points within 20 miles (32 km) and other dragons - even metamorphosed ones - on sight to 4000 feet (1219 m). Sensing gives nearness and direction, never a pinpoint."
  - "PSIONICS: Six powers from ONE of Sensitive or Healing. Super Psionics are not available."
  - "Size: about 30 feet (9.1 m) snout to tail and 4-8 tons; metamorphosis adjusts that by up to 50% either way. A hatchling reaches 80% of full size within 3D4 weeks of hatching and is not mature until 600 years old."
  - "Dragons do not need to eat or drink - as creatures of magic they absorb magic energy - and do so only for the pleasure of it."
  - "Cybernetics and bionics: NONE, ever. The bio-regenerative powers reject implants and push them back out as the body heals."
  - "Money: a hatchling under 100 years old is not much interested in wealth or power, though always drawn to magic items. It wants to see the world."
  - "Weapons and equipment: it can use any weapon and may wear little or nothing, mega-damage armour included, except as part of a disguise."
  - "Only the dragon''s I.Q. bonus applies to secondary skills. The level 18-22 grants recorded above come from the book; this app caps a character at level 15, so they will not fire."
  - "+1 on all saving throws not listed above."
side_effects: "One of the dragon species Rifts Ultimate Edition details, printed p.160-161. All dragons are creatures of magic sustained by magic energy rather than food, reaching 80% of full size within 3D4 weeks of hatching and full maturity only at 600 years old. The average life span is 6,000 to 8,000 years, and some live 12,000."
extraction_notes: |
  Read from Rifts Ultimate Edition p.160-161 via the OCR cache at
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

The Flame Wind Dragon can seemingly set itself alight, in a manner similar to a
psychic Burster or an Elemental Fusionist - except that the Flame Wind''s own
scales are genuinely burning, and it costs the dragon nothing. It is simply part
of how the creature works.

What that means in practice is that a Flame Wind on fire is dangerous to be near
and dangerous to be carried by. It ignites what it touches and damages what it
carries.

## GM Notes

The flames are a resource with a clock: one minute per level, then ten minutes
of rest before the scales can burn again. A hatchling gets four melee rounds of
it, which is not long, and the ten minute recovery is the interesting half - a
Flame Wind that has just spent its flames is an ordinary dragon for the rest of
the fight.

Also worth playing: it ignites anything it touches while lit, which makes it a
liability indoors and around its own party''s gear.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dragon-hatchling-flame-wind');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dragon-hatchling-flame-wind';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dragon-hatchling-flame-wind-class.sql');
