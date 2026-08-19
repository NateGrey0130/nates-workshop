-- Cyber-Knight O.C.C. corrected against Rifts, p.63-64.
--
-- Hand-written like the Long Bowman, and wrong in the same way: most of it was
-- invented. Of seven O.C.C. skills, three were not Cyber-Knight skills at all
-- (Radio: Basic, Hover Craft, W.P. Sword) and the four that were had lost their
-- bonuses. Eleven the book grants were missing entirely, including Literacy,
-- the two languages at 96, Lore: Demon, Anthropology, Swimming, Climbing,
-- Body Building, Gymnastics and the four weapon proficiencies.
--
--   related skills      6, five categories  ->  12, fourteen, with a schedule
--   secondary skills    2                   ->  6
--   attribute reqs      M.E. 12, M.A. 12    ->  M.E. 11 (the only requirement;
--                                               the rest are suggested)
--   P.P.E.              1d6x10              ->  6d6
--   S.D.C.              flat 30             ->  1d4x10, the stated bonus
--   I.S.P.              1d4x10+20           ->  6d6+10, +1d6 per level
--   psi-powers          six (the default)   ->  three
--   starting money      absent              ->  2d6x100 credits
--   cyber-armor         60 M.D.C.           ->  A.R. 16, 50 M.D.C.
--   psi-sword           "+1d6 per level"    ->  +1d6 at levels 3, 6, 9, 12, 15
--
-- The +1 initiative and +1 attack per melee the class grants were absent and
-- are now real bonuses rather than prose.
--
-- Guarded on the old Hover Craft entry, so re-running is a no-op.

UPDATE imported_classes
   SET markdown = '---
id: cyber-knight
name: Cyber-Knight
system: rifts
source_book: rifts-core
category: occ
attribute_requirements:
  ME: 11
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "1d4x10"
ppe_base: "6d6"
starting_money: "2d6x100"
bonuses:
  combat: { initiative: 1, attacks: 1 }
skills:
  occ_skills:
    - { name: "Literacy", base: 50, per_level: 5 }
    - { name: "Language: Native Tongue", base: 96, per_level: 0 }
    - { name: "Language: Dragonese", base: 96, per_level: 0 }
    - { choose: 2, categories: ["Technical"], base: 80, per_level: 5, note: "Two additional languages of choice (+30%). The catalog has no individual language rows." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon (+20%)" }
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 48, per_level: 4, note: "+12%" }
    - { name: "Horsemanship: General", base: 55, per_level: 4, note: "+15%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, two of choice" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern, two of choice" }
  occ_related_skills:
    count: 12
    categories: ["Communications", "Domestic", "Electrical", "Espionage", "Mechanical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 3 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
equipment_starting:
  - { item_id: "cyber-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 2 }
  - { item_id: "ns-turbo-cyclone", qty: 1 }
psionics:
  type: "major"
  isp_base: "6d6+10, +1d6 per level"
  powers_starting: 3
special_abilities:
  - name: "Psi-Sword"
    description: "A mega-damage blade of psychic energy willed into existence. 1D6 M.D. at first level, plus an additional 1D6 M.D. at levels three, six, nine, twelve and fifteen. Costs no I.S.P., has no time limit, and can be created any number of times a day. A true knight will never use it against a foe who is unarmed, not equipped with an equivalent weapon, and not a supernatural creature or dragon."
  - name: "Cyber-Armor"
    description: "The one cybernetic implant a cyber-knight starts with: concealed body armor, A.R. 16 and 50 M.D.C."
  - name: "Psionics"
    description: "Eighty percent of cyber-knights are psychic (roll 01-80). A psychic cyber-knight is a major psionic, saves against psionic attack at 12 or higher, and picks three permanent powers from a fixed list: empathy, mind block, object read, see the invisible, sense evil, sense magic, sixth sense, speed reading, summon inner strength."
  - name: "Techno-Wizardry"
    description: "Open-mindedness toward magic makes the cyber-knight one of the few O.C.C.s able to intuitively understand and use items created through techno-wizardry."
level_progression:
  - level: 3
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 6
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 9
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 12
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 15
    grants: ["Psi-Sword damage +1D6 M.D."]
restrictions:
  - "Good alignments as a rule; aberrant and anarchist are acceptable. A knight may be corrupted and turn evil like anybody else."
  - "Bound by the Code of Chivalry: to live, fair play, nobility, valor, honor, courtesy and loyalty."
  - "Rarely uses power armor or robot vehicles."
extraction_notes: |
  - The +1D4 bonus to M.A., M.E., P.S., P.E. and Spd is not recorded: `bonuses.attributes` takes flat numbers, and a dice bonus cannot be expressed. Roll it by hand at creation.
  - The 80% chance of having psionics at all is a per-character roll the class schema cannot state; the class is written as psychic, which is the common case.
  - The three starting psi-powers come from a named list of nine, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered.
  - Related-skill restrictions per category are not expressible: "Electrical: Basic only", "Mechanical: Automotive only" and "Physical: Any (+5% when applicable)" become plain categories. Medical is excluded entirely, per "none other than O.C.C. skill".
  - The level-five related-skill grant is specifically three W.P.s; the schedule records the count but not the category.
  - The black market item worth 1D6x1000 credits is not modelled; only the 2D6x100 starting credits are.
---
## Lore

Wandering champions of the Megaverse, the Cyber-Knights are an order of noble
warriors founded by Lord Coake. Part paladin, part ranger, they roam the wilds
of post-apocalyptic North America defending the weak against monsters, bandits,
and the excesses of the Coalition States alike. Each knight carries the
signature Psi-Sword ' || char(8212) || ' a weapon of pure psychic energy that cannot be taken
from them ' || char(8212) || ' and lives by a strict code of chivalry.

## GM Notes

A Cyber-Knight who grossly violates the Code of Chivalry should face in-game
consequences (loss of reputation with the order, possible visit from a senior
knight). House rule: no starting cybernetics beyond the Cyber-Armor graft.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND markdown LIKE '%Hover Craft (ground)%';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-cyber-knight.sql');
