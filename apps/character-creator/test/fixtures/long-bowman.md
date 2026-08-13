---
id: long-bowman
name: Long Bowman
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements:
  PP: 10
  PE: 10
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 20
ppe_base: "2d6"
skills:
  occ_skills:
    - { name: "W.P. Archery", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "Wilderness Survival", base: 35, per_level: 5 }
    - { name: "Track Animals", base: 30, per_level: 5 }
    - { name: "Carpentry (fletching)", base: 35, per_level: 5 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0 }
  occ_related_skills:
    count: 8
    categories: ["Physical", "Weapon Proficiencies", "Wilderness", "Military", "Horsemanship"]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "long-bow", qty: 1 }
  - { item_id: "arrows-standard", qty: 24 }
  - { item_id: "short-sword", qty: 1 }
  - { item_id: "leather-armor", qty: 1 }
level_progression:
  - level: 2
    grants: ["+1 aimed shot per melee with long bow"]
  - level: 4
    grants: ["+1 to strike with long bow"]
  - level: 6
    grants: ["+1 aimed shot per melee with long bow"]
---

## Lore

Masters of the great war bow, Long Bowmen are the backbone of any serious
army in the Palladium world and prized mercenaries besides. Years of training
give them a rate of fire and accuracy no ordinary soldier can match. Most are
commoners who earned their place through skill rather than birth, and many
supplement soldiering with hunting, fletching, and woodcraft.

## GM Notes

Remember the long bow's rate of fire stacks with Hand to Hand attacks per the
core rules — it adds up fast at high level. Check ammunition bookkeeping;
arrows are cheap but not infinite in the wilderness.
