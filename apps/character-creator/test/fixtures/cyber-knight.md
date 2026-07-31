---
id: cyber-knight
name: Cyber-Knight
system: rifts
source_book: rifts-core
category: occ
attribute_requirements:
  ME: 12
  MA: 12
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 30
ppe_base: "1d6x10"
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 40, per_level: 5 }
    - { name: "Pilot: Hovercraft", base: 45, per_level: 5 }
    - { name: "Horsemanship", base: 40, per_level: 4 }
    - { name: "Land Navigation", base: 40, per_level: 4 }
    - { name: "Paramedic", base: 40, per_level: 5 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
  occ_related_skills:
    count: 6
    categories: ["Physical", "Weapon Proficiencies", "Espionage", "Wilderness", "Technical"]
  secondary_skills:
    count: 2
equipment_starting:
  - { item_id: "ns-turbo-cyclone", qty: 1 }
  - { item_id: "cyber-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 2 }
psionics:
  type: "major"
  isp_base: "1d4x10+20"
special_abilities:
  - name: "Psi-Sword"
    description: "Manifest a blade of psychic energy. 1d6 M.D. per level of experience, no I.S.P. cost."
  - name: "Cyber-Armor"
    description: "Concealed M.D.C. body armor grafted to the knight. 60 M.D.C., regenerates with rest."
level_progression:
  - level: 2
    grants: ["+1 attack per melee"]
  - level: 3
    grants: ["Psi-Sword damage +1d6 M.D."]
  - level: 5
    grants: ["+1 attack per melee", "Zen Combat: +1 to strike, parry, dodge vs machines"]
---

## Lore

Wandering champions of the Megaverse, the Cyber-Knights are an order of noble
warriors founded by Lord Coake. Part paladin, part ranger, they roam the wilds
of post-apocalyptic North America defending the weak against monsters, bandits,
and the excesses of the Coalition States alike. Each knight carries the
signature Psi-Sword — a weapon of pure psychic energy that cannot be taken
from them — and lives by a strict code of chivalry.

## GM Notes

A Cyber-Knight who grossly violates the Code of Chivalry should face in-game
consequences (loss of reputation with the order, possible visit from a senior
knight). House rule: no starting cybernetics beyond the Cyber-Armor graft.
