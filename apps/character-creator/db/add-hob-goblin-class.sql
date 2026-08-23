-- The Hob-Goblin R.C.C., Palladium Fantasy RPG Main Book p.300-301.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-hob-goblin-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-hob-goblin-class.sql
--
-- Transcribed from the PDF's own text layer, read in column order with
-- scripts/read-columns.py, and validated with scripts/class-check.mjs before
-- this file was generated. Pure ASCII, LF endings.
--
-- S.D.C. is a POOL BONUS rather than sdc_base wherever the race states one.
-- Printed 18: "Some non-human races and O.C.C.s also get special S.D.C.
-- bonuses. All S.D.C. points/bonuses are cumulative." Stating it as sdc_base
-- would REPLACE the occupation's own roll instead of adding to it, because
-- combineClasses gives the race's pool precedence.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'hob-goblin', 'Hob-Goblin', 'palladium-fantasy', '---
id: hob-goblin
name: Hob-Goblin
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.300-301
category: rcc
attribute_dice:
  IQ: "2d6"
  ME: "3d6+6"
  MA: "2d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "2d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "4d6"
psionics_allowed: false
bonuses:
  combat: { initiative: 1, dodge: 1 }
  saves: { faerie_magic: 1, psionics: 1, possession: 2, horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m) - far less keen than the goblin''s - with excellent day vision equal to a human''s."
  - name: "Keen Hearing"
    description: "The hob-goblin''s hearing is as keen as a dog''s and has the same range. The character suffers HALF the usual penalties when blinded, and can dodge, attack and so on by listening to sounds. The +1 to initiative and +1 to dodge come from this."
  - name: "Underground Tunneling (Special)"
    description: "Fundamentally the same as for dwarves, only much cruder. Hob-goblins can dig crude, shallow tunnels but are far less adept than goblins, and they hate digging. Base Skill: 20% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Fundamentally the same as for dwarves, only much simpler and cruder. Base Skill: 5% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "Fundamentally the same as for the dwarf, but less acute. Base Skill: 10% +5% per level, and the hob-goblin cannot judge the approximate proximity of surface structures at all."
  - name: "Digging Speed"
    description: "Spd 1D4 while digging, against 3D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "None."
restrictions:
  - "No psionics. The hob-goblin page states Psionics: None - but the race has a natural RESISTANCE to psionic attack, which is the +1 save and the high M.E."
  - "O.C.C.s available: limited to assassin, thief, mercenary, soldier, black priest, witch and vagabond. They tend toward men of arms, especially mercenary or thief."
  - "All weapons except pole arms and long bows."
extraction_notes: |
  - S.D.C. reads "only those gained from O.C.C.s and physical skills", so the hob-goblin states no S.D.C. of its own and carries no pool bonus.
  - psionics_allowed: false alongside a +1 psionics SAVE is not a contradiction and is the clearest case of the two being different things. The race can never have psychic powers and is unusually hard to affect with them.
  - "+1 to save vs faerie magic" needed the `faerie_magic` save key, added in the same pass alongside `disease`.
  - The half-penalty-when-blinded half of Keen Hearing is a conditional modifier, so it is prose. Only the unconditional +1 initiative and +1 dodge are numbers.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

Hob-goblins appear to be genetic mutations of the goblin. These tall, lanky, flop-eared beings are just as mean, petty and treacherous as their shorter goblin kin, and all aspects of their attitudes, morals, disposition, passion for precious metals and gems, society, enemies and allies are identical to the goblin''s. The two are usually seen in each other''s company and are often members of the same tribe; each readily accepts the other as a brother, and the two are astonishingly loyal to one another. Everybody else, including orcs and ogres, is dispensable.

There are real differences beyond appearance. Hob-goblins are not as quick or dexterous as goblins, nor do they have the goblin''s keen nightvision. The hob-goblin''s strength is mental endurance, which gives most of them a healthy resistance to psionic attack as well as to insanity and mental fatigue.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Assassin, thief, mercenary, soldier, black priest, witch and vagabond.

**Physical Appearance:** Short compared to humans, with large ears, a large nose, small beady eyes, a bald head, large teeth, skinny legs and large feet.

**Size:** 4 to 5 feet (1.2 to 1.5 m).

**Weight:** 90 to 140 pounds (40.5 to 63 kg).

**Average Life Span:** 80+ years; some have lived up to 130, but most males rarely make it to 40.

**Enemies:** Humans, kobolds, dwarves, gnomes, changelings, and especially elves - though a hob-goblin will serve a member of these races who proves evil, ruthless and powerful enough. Hob-goblins also hate their fellow faerie folk and take pleasure in plucking the wings from faeries and sprites, knocking down their homes and similar acts of cruelty.

**Allies:** Regularly befriend and work with goblins, orcs, ogres and trolls. Indifferent towards Wolfen, troglodytes, giants and most creatures of magic.

**Habitat:** Found throughout the world but most common in the Old Kingdom, Eastern Territory, Western Empire, Timiro and in the South. The largest known communities are in the Old Kingdom and the Land of the South Winds.

**Favorite Weapons:** All except pole arms and long bows. They love magic.

## GM Notes

Unlike goblins, hob-goblins operate well in groups - especially if they think they are getting their fair share of the spoils. They are still easily intimidated and bluffed by demonstrations of power.

Hob-goblins suffered huge losses in the Elf-Dwarf War and have never prospered since. Stillbirths are frequent and they are so foolishly aggressive and stubborn that fewer than a third reach their full life expectancy; their days in this world seem numbered. A hob-goblin character who has survived to adventuring age is already unusual, and knows it.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'hob-goblin');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'hob-goblin';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-hob-goblin-class.sql');
