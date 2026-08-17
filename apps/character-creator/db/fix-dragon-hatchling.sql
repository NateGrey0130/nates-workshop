-- Great Horned Dragon Hatchling R.C.C. corrected against Rifts, p.98 and p.100.
--
-- The worst of the five. Hand-written, and invented almost throughout.
--
--   EVERY attribute die was wrong. The book gives plain pools of varying size --
--   I.Q. 5D6, M.E. 5D6, M.A. 4D6, P.S. 6D6, P.P. 4D6, P.E. 5D6, P.B. 6D6,
--   Spd 4D6 -- and the class had 3d6+6, 3d6+2, 3d6+4, 4d6+12, 3d6+4, 3d6+6,
--   4d6 and 3d6+10. Not one matched.
--
--   The hatchling knew four spells of levels 1-2, through a `magic` block. The
--   book says the opposite in as many words: it knows NO spells yet, and can
--   first learn them by the usual means at third level, two per level after.
--   That block is removed.
--
--   M.D.C. was 1d4x100, dropping the +50. P.P.E. was 2d4x10+40 for 2D6x10.
--   I.S.P. was 1d6x10+30 for 3D4x10. Psionics gave six powers where the book
--   gives eight.
--
--   Natural abilities were wrong where they existed and missing where they did
--   not: bio-regeneration read "per hour" for every five minutes, nightvision
--   200 feet for 90, fire breath 100 feet for 60, metamorphosis one hour per
--   level twice a day for two hours per level. Flight, see the invisible,
--   fire/cold resistance, the armour rating, teleport, and the claw and bite
--   damage were all absent.
--
--   Skills: basic math at 60 and dragonese at 96 where the book puts all three
--   known skills at 98, plus a Lore skill the entry never grants. Four related
--   skills from four categories where the book gives six from eight, with four
--   more at levels four and eight.
--
--   The extra melee attack is now a real bonus rather than prose.
--
-- Guarded on the old spell block, so re-running is a no-op.

UPDATE imported_classes
   SET markdown = '---
id: dragon-hatchling
name: Dragon Hatchling (Great Horned)
system: rifts
source_book: rifts-core
category: rcc
attribute_dice:
  IQ: "5d6"
  ME: "5d6"
  MA: "4d6"
  PS: "6d6"
  PP: "4d6"
  PE: "5d6"
  PB: "6d6"
  Spd: "4d6"
mdc_base: "1d4x100+50"
ppe_base: "2d6x10"
bonuses:
  combat: { attacks: 1 }
skills:
  occ_skills:
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "One additional language of choice, usually American" }
    - { name: "Basic Math", base: 98, per_level: 0 }
  occ_related_skills:
    count: 6
    categories: ["Communications", "Domestic", "Military", "Pilot", "Pilot Related", "Rogue", "Technical", "Wilderness"]
    note: "No skill bonuses other than a possible I.Q. bonus. The hatchling is too busy testing its natural abilities to concentrate on mundane human skills."
    schedule:
      - { level: 4, count: 4 }
      - { level: 8, count: 4 }
psionics:
  type: "major"
  isp_base: "3d4x10"
  powers_starting: 8
  categories_allowed: ["Healing", "Physical", "Sensitive"]
natural_abilities:
  - name: "Flight"
    description: "Flies at 70 mph (112 km)."
  - name: "Nightvision"
    description: "90 feet (27.4 m)."
  - name: "See the Invisible"
    description: "Perceives normally invisible creatures and objects."
  - name: "Fire and Cold Resistant"
    description: "Takes half damage from fire and cold."
  - name: "Bio-Regeneration"
    description: "Recovers 1D4x10 M.D. points every five minutes."
  - name: "Armor Rating"
    description: "The skin is a mega-damage substance impervious to normal weapons. Magic, psionics and mega-damage weapons have full effect."
  - name: "Metamorphosis"
    description: "Completely alters its physical shape to look like any living animal, from human being to raven. Cannot become an inanimate object or an insect; minimum size is about that of a cat and the maximum cannot exceed its own. Lasts two hours per level of experience, tripled on or near a ley line or nexus point within two miles (3.2 km). A dragon in another shape keeps all its natural powers and gains none of the animal''s."
  - name: "Teleport"
    description: "28% +2% per level of experience, at will, up to five miles away. At the hatchling stage it can teleport only itself, and may attempt one every other melee round. Only a mature dragon can teleport dimensionally without a ley line nexus."
  - name: "Fire Breath"
    description: "2D6 Mega-Damage, range 60 feet (18 m)."
  - name: "Claws and Bite"
    description: "Claws inflict 2D6 Mega-Damage, bite 2D4 Mega-Damage."
special_abilities:
  - name: "Magic Knowledge"
    description: "A full understanding of magic, but the hatchling knows NO spells yet. It can intuitively use all types of techno-wizardry devices without instruction, read magic, use scrolls, and recognize magic circles and enchantment. It can also sense ley lines, nexus points and other dragons within 20 miles (32 km) - nearness and general direction only, never a pinpoint location."
  - name: "Learning Spells"
    description: "Spells can be learned by the usual means beginning at third level. The hatchling can cast two new spells per level of experience."
  - name: "Combat Abilities"
    description: "Equal to Hand to Hand: Basic, plus one extra melee attack."
level_progression:
  - level: 3
    grants: ["May begin learning spells by the usual means; two new spells per level"]
  - level: 5
    grants: ["+4 psionic powers"]
  - level: 10
    grants: ["+4 psionic powers"]
restrictions:
  - "A dragon is a hatchling until full maturity at roughly 600 years of age."
  - "Without a chosen alignment the hatchling starts anarchist - self serving, greedy and snotty - and must settle on a definitive alignment at level three."
  - "Hatchlings are naive about the modern world; play accordingly."
extraction_notes: |
  - AUDIT (Rifts p.98, p.100). The previous definition was invented almost throughout.
    Every attribute was written as a 3d6/4d6 pool with a flat modifier; the book gives
    plain dice pools of varying size (I.Q. 5D6, P.S. 6D6, P.B. 6D6, Spd 4D6 and so on).
  - The hatchling knows NO spells. The class previously granted four spells of levels
    1-2 through a `magic` block, which the book contradicts directly: spells can first
    be learned at third level, two per level thereafter.
  - Psionics: eight powers, not the six the major-psionic default gives, and I.S.P. is
    3D4x10 rather than the 1d6x10+30 recorded.
  - The extra melee attack is now a real bonus rather than prose.
  - Not expressible: the 28% +2%/level teleport chance, "two new spells per level from
    third", and the alignment defaulting to anarchist until level three. All recorded
    as prose.
---
## Lore

Great Horned Dragons are among the mightiest beings of the Megaverse, and even
a hatchling ' || char(8212) || ' mere decades old ' || char(8212) || ' is a creature of Mega-Damage flesh, innate
magic, and razor intellect. Hatchling player characters are newly hatched
(often orphaned by dimension-hopping circumstance), possessing terrifying raw
power but a child''s understanding of the world. They metamorphose into human
form to walk among mortals, and most are insatiably curious.

## GM Notes

The power gap between a hatchling and human classes is real ' || char(8212) || ' lean on the
naivete and the attention a young dragon attracts (Coalition, dragon hunters,
other dragons) to balance the table. Metamorphosis does not grant the copied
creature''s abilities, only its shape.
',
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling'
   AND markdown LIKE '%spells_starting: 4%';
