-- Dragon Hatchling (Cat's-Eye), one of the six dragon species Rifts Ultimate Edition
-- details, printed p.159-160.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dragon-hatchling-cats-eye-class.sql
--
-- Read from the RUE OCR cache at .cache/books/rue; printed page = cache page
-- minus three, folio-checked rather than assumed. Validated with
-- scripts/class-check.mjs --remote against the PRODUCTION catalog before this
-- file was generated: 0 errors, 0 warnings.
--
-- The charmer. Its Cat Eye Gaze is a mind-control power that needs eye contact and is nearly useless mid-combat, which makes it a subterfuge dragon rather than a fighting one.
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
SELECT 'dragon-hatchling-cats-eye', 'Dragon Hatchling (Cat''s-Eye)', 'rifts', '---
id: dragon-hatchling-cats-eye
name: Dragon Hatchling (Cat''s-Eye)
system: rifts
source_book: Rifts Ultimate Edition p.159-160
category: rcc
attribute_dice:
  IQ: "3d6+5"
  ME: "3d6+4"
  MA: "3d6+6"
  PS: "3d6+12"
  PP: "3d6+5"
  PE: "3d6+9"
  PB: "3d6+6"
  Spd: "3d6+12"
mdc_base: "1D4x100+50, +10 M.D.C. per level of experience"
sdc_base: "5d6x10"
hit_points_base: "1d4x100+50"
ppe_base: "2D6x10, +2D6 per level of experience"
magic:
  type: "spell"
  spells_starting: 0
psionics:
  type: "minor"
  isp_base: "2D4x10, +2D4 per level of experience"
  powers_starting: 6
  categories_allowed: ["Sensitive", "Physical", "Healing"]
  powers_schedule:
    - { level: 5, count: 2 }
    - { level: 10, count: 2 }
bonuses:
  combat: { attacks: 1, initiative: 3, strike: 2, parry: 1, dodge: 1, pull_punch: 2, roll: 1 }
  saves: { horror_factor: 4, psionics: 2, mind_control: 2, possession: 2 }
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
  - name: "Cat-Like Nightvision"
    description: "To 6,000 feet (1830 m); the eyes glow in reflected light."
  - name: "See the Invisible"
    description: "Always active."
  - name: "Turn Invisible at Will"
    description: "At will."
  - name: "Resistant to Fire and Cold"
    description: "Half damage, including mega-damage fire and magic cold."
  - name: "Prehensile Tail"
    description: "Strikes like a whip for punch damage +1D6 M.D."
  - name: "Bio-Regeneration"
    description: "1D10 M.D.C. per melee round, or 1D4x10 M.D.C. per minute."
  - name: "Metamorphosis"
    description: "Completely alters its physical shape to look like any living animal, from a human being to a house cat, for two hours per level of experience - tripled on or near a ley line or nexus point within two miles (3.2 km). Never an inanimate object or an insect; minimum size about that of a cat, maximum its own. A dragon in another shape keeps every one of its own powers and gains none of the animal''s."
  - name: "Teleport"
    description: "28% +2% per level of experience, at will, up to five miles (8 km). A hatchling can teleport only itself and may attempt one every other melee round; a failed roll means it did not happen. Only a mature dragon teleports dimensionally without a ley line nexus - a hatchling may try at a nexus at half the usual percentage."
  - name: "Cat Eye Gaze"
    description: "A transfixing gaze that charms and controls. The victim must look directly into the dragon''s eyes - power armour and body armour give no protection at all, but a pilot seeing through a video monitor is immune. Save vs mind control at 14 or higher. Commands work only where they are not morally repugnant to the victim; ordering someone to kill a friend breaks the charm instantly. Controls three people per level of experience, lasts two minutes (8 melee rounds) per level, needs eye contact within 50 feet (15.2 m) to begin, and holds to 1000 feet (305 m) after. Nearly impossible mid-combat, when nobody is looking the dragon in the eye."
  - name: "Fire Breath"
    description: "3D6 M.D. to a six foot wide (1.8 m) area, catching 2-6 opponents huddled together. Range 60 feet (18 m). Up to three times per melee round, each blast counting as one attack."
  - name: "Claws and Bite"
    description: "Retractable claws inflict +2D6 M.D. on top of supernatural P.S. damage; the bite does 2D6 M.D. with no P.S. bonus."
restrictions:
  - "Alignment: any. Most hatchlings begin as Unprincipled or Anarchist and behave like a child of four to seven - self-serving, self-obsessed, a little snotty, liable to wander off. At level three the player must settle on a definitive alignment."
  - "Horror Factor: 12."
  - "Speed: 3D6+12 running, but 1D6x10+55 flying."
  - "MAGIC: knows NO spells at first level. Spells are learned by the usual means from second level - by third level the hatchling has 2D4+2 spells from levels 1-3, another 2D4+2 by fifth level from levels 3-8, and 3 new spells per level thereafter up to its own level. Two spells may be cast per melee round, and it gains +1 to spell strength at level nine. Those counts are dice-valued, which a spell schedule cannot hold, so they are recorded here."
  - "It understands magic fully without knowing spells: it uses any techno-wizard device without instruction, recognises and uses magic weapons, reads magic, uses scrolls, and recognises magic circles and enchantment at 40% +3% per level. It senses ley lines and nexus points within 20 miles (32 km) and other dragons - even metamorphosed ones - on sight to 4000 feet (1219 m). Sensing gives nearness and direction, never a pinpoint."
  - "PSIONICS: Six powers from ONE of Sensitive, Physical or Healing. Super Psionics are not available."
  - "Size: about 30 feet (9.1 m) snout to tail and 4-8 tons; metamorphosis adjusts that by up to 50% either way. A hatchling reaches 80% of full size within 3D4 weeks of hatching and is not mature until 600 years old."
  - "Dragons do not need to eat or drink - as creatures of magic they absorb magic energy - and do so only for the pleasure of it."
  - "Cybernetics and bionics: NONE, ever. The bio-regenerative powers reject implants and push them back out as the body heals."
  - "Money: a hatchling under 100 years old is not much interested in wealth or power, though always drawn to magic items. It wants to see the world."
  - "Weapons and equipment: it can use any weapon and may wear little or nothing, mega-damage armour included, except as part of a disguise."
  - "Only the dragon''s I.Q. bonus applies to secondary skills. The level 18-22 grants recorded above come from the book; this app caps a character at level 15, so they will not fire."
  - "+2 on Perception Rolls and +1 on all saving throws not listed above. Perception is not a key the sheet adds up."
side_effects: "One of the dragon species Rifts Ultimate Edition details, printed p.159-160. All dragons are creatures of magic sustained by magic energy rather than food, reaching 80% of full size within 3D4 weeks of hatching and full maturity only at 600 years old. The average life span is 6,000 to 8,000 years, and some live 12,000."
extraction_notes: |
  Read from Rifts Ultimate Edition p.159-160 via the OCR cache at
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

The Cat''s-Eye Dragon has definite feline overtones while remaining a dragon in
every way - massive wings, powerful limbs, retractable claws, and golden,
almond-shaped eyes like a cat''s. Even the muzzle is blunter and more feline than
the traditional reptilian jaw, set with enormous canine teeth. Its scales run
from tan, gold and tawny yellow through muted orange flecked with red to deep
crimson and blood red. Tufts of darker fur crown its prehensile tail, and a
matching mane often surrounds head and neck.

It behaves much like an enormous house cat: napping through the day, full of vim
and vigour at night, and famous for playing cat and mouse with opponents -
humans included. Independent, and snobbish about other life forms.

## GM Notes

The gaze is the character, and it is a subterfuge power rather than a combat
one. The book is explicit that charming someone mid-fight is difficult if not
impossible, because nobody in a fight is looking the dragon in the eye.

The commands that work are the ones that are not morally repugnant, which makes
"great danger lies beyond this room, don''t let anybody enter" far more effective
than any order to harm. Three victims per level, two minutes per level, and it
breaks the instant the dragon asks for something the victim would never do.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dragon-hatchling-cats-eye');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dragon-hatchling-cats-eye';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dragon-hatchling-cats-eye-class.sql');
