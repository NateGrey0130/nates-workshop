---
id: dragon-hatchling
name: Dragon Hatchling (Great Horned)
system: rifts
source_book: rifts-core
category: rcc
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6+2"
  MA: "3d6+4"
  PS: "4d6+12"
  PP: "3d6+4"
  PE: "3d6+6"
  PB: "4d6"
  Spd: "3d6+10"
mdc_base: "1d4x100"
ppe_base: "2d4x10+40"
skills:
  occ_skills:
    - { name: "Basic Math", base: 60, per_level: 5 }
    - { name: "Language: Dragonese", base: 96, per_level: 0 }
    - { name: "Lore: Demons and Monsters", base: 40, per_level: 5 }
  occ_related_skills:
    count: 4
    categories: ["Communications", "Science", "Technical", "Wilderness"]
  secondary_skills:
    count: 2
psionics:
  type: "major"
  isp_base: "1d6x10+30"
magic:
  type: "innate"
  spells_starting: 4
  spell_levels_allowed: [1, 2]
natural_abilities:
  - name: "Metamorphosis"
    description: "Assume the shape of any living creature for 1 hour per level of experience, twice per day."
  - name: "Fire Breath"
    description: "Breathe fire up to 100 feet, 2d6 M.D. per blast."
  - name: "Nightvision"
    description: "See in total darkness up to 200 feet."
  - name: "Bio-Regeneration"
    description: "Recover 1d4x10 M.D.C. per hour."
level_progression:
  - level: 2
    grants: ["+1 spell from levels 1-3"]
  - level: 3
    grants: ["Metamorphosis duration doubles"]
  - level: 5
    grants: ["+2 spells from levels 1-4", "+1 attack per melee"]
restrictions:
  - "Cannot take an O.C.C. until reaching adulthood (centuries from now)."
  - "Hatchlings are naive about the modern world; play accordingly."
---

## Lore

Great Horned Dragons are among the mightiest beings of the Megaverse, and even
a hatchling — mere decades old — is a creature of Mega-Damage flesh, innate
magic, and razor intellect. Hatchling player characters are newly hatched
(often orphaned by dimension-hopping circumstance), possessing terrifying raw
power but a child's understanding of the world. They metamorphose into human
form to walk among mortals, and most are insatiably curious.

## GM Notes

The power gap between a hatchling and human classes is real — lean on the
naivete and the attention a young dragon attracts (Coalition, dragon hunters,
other dragons) to balance the table. Metamorphosis does not grant the copied
creature's abilities, only its shape.
