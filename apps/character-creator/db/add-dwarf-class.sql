-- The Dwarf R.C.C., Palladium Fantasy RPG Main Book p.292-294.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-dwarf-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-dwarf-class.sql
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
SELECT 'dwarf', 'Dwarf', 'palladium-fantasy', '---
id: dwarf
name: Dwarf
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.292-294
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+6"
  PP: "3d6"
  PE: "4d6"
  PB: "2d6+2"
  Spd: "2d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
skills:
  occ_skills:
    - { name: "Field Armorer & Munitions Expert", base: 50, per_level: 5, note: "Metal working (Special): a basic understanding of blacksmith facilities, smith techniques and working with metal, particularly weapons and jewelry. Equal to the field armorer skill with a +10% bonus." }
    - { name: "Gemology", base: 35, per_level: 5, note: "Recognize Precious Metals & Stones: same as the gemology skill with a +10% bonus." }
bonuses:
  pools: { sdc: 15 }
  saves: { spell_magic: 1, ritual_magic: 1, illusionary_magic: 1, curses: 1, faerie_magic: 1, possession: 2, horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "90 feet (27.4 m). Dwarves also have very good day vision and function well on the surface."
  - name: "Underground Tunneling (Special)"
    description: "Dig and build solid, strong tunnels with no fear of a cave-in, and excavate ruins and cave-in sites with the same prowess. The dwarf can usually tell whether an existing tunnel or chamber is a natural formation or was dug by dwarves, kobolds, goblins, gnomes, troglodytes or humans, and whether it is new, old or ancient. Base Skill: 40% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Build small and large rooms, ornate archways, staircases, cathedral-ceilinged chambers, and a labyrinth of tunnels, passageways, mazes and underground traps; and recognize the styles of dwarven, kobold, goblin and other construction. A dwarf travelling slowly and cautiously can locate underground traps and avoid or deactivate them. Base Skill: 30% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "Tell direction underground even in total darkness (not applicable on the surface): whether travelling up, down or level, the approximate angle, roughly how far below the surface, and the approximate compass direction. Base Skill: 40% +5% per level. Judging the approximate location of surface structures in a familiar area is a separate roll: 30% +5% per level, -25% in an unfamiliar area."
  - name: "Digging Speed"
    description: "Spd 1D6 while digging, against 2D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "Not applicable."
restrictions:
  - "No magic O.C.C.s. All dwarves have forsaken the study and practice of magic in all its forms; not a single dwarf has practiced magic in over 7,000 years."
  - "O.C.C.s available: any except magic. Most dwarves lean toward the men of arms, merchants and clergy."
extraction_notes: |
  - S.D.C. reads "15 plus bonuses from physical skills", so the 15 is a POOL BONUS rather than sdc_base. Printed 18 states the rule plainly: "Some non-human races and O.C.C.s also get special S.D.C. bonuses. All S.D.C. points/bonuses are cumulative."
  - "+1 to save vs magic" is one printed line and the app splits magic into five save keys, so it lands on all five - spell, ritual, illusionary, curses and faerie magic. The split is the app''s, not the book''s.
  - NOT MODELLED - the O.C.C. Skill Notes. "Add a bonus of +5% to the following skills (this is in addition to O.C.C. bonuses): any Military skills, general repair, recognize weapon quality, masonry, carpentry, rope works, sculpting, locate secret compartments/doors, detect concealment, basic math, and land navigation." These modify skills the OCCUPATION grants, and the app has no race-level per-skill modifier: occ_skills GRANTS a skill, skill_overrides only restates one the class already grants, and skills.bonuses is a catalog-row property shared by every class. Apply by hand.
  - Metal working and Recognize Precious Metals & Stones ARE grants - the page says every dwarf has them - so they are occ_skills at the catalog base plus the printed +10%. The catalog spells them "Field Armorer & Munitions Expert" and "Gemology"; the book''s own skill list (printed 49) says "Field Armorer", which is one of the documented Rifts renames the catalog already holds.
  - The restriction on magic is prose. Nothing in the app enforces which O.C.C. a race may take.
---

## Lore

Once the greatest of the subterranean races, the dwarven kingdoms have been destroyed and their people slain. Today dwarves are comparatively small in number and frequently live with their human allies, holding respected places as masterful weaponsmiths, supreme armorers, merchants, talented builders and excavators, stone workers and courageous warriors.

Dwarves are a bit slower than many of the taller races, but they are incredibly strong, resistant to magic, tough, clever and resourceful. When facing larger opponents these magnificent warriors frequently use tactics to bring them down to size - knocking them off their feet, hamstringing the legs, tripping, entangling, and striking at the knees, groin and throat. Although smaller than humans, they are skilled combatants who have spent many millenniums fighting taller foes such as elves, orcs and ogres, and underground their small size becomes a decisive advantage: they run and manoeuvre freely through corridors where a surface dweller must walk hunched over.

**Alignment:** Any; player characters usually lean toward good and selfish.

**O.C.C.s available:** Any except magic.

**Physical Appearance:** A short, husky people with powerful muscles, broad shoulders, ruddy complexions, weathered looks, white hair and an aged appearance. Even young dwarves look older than they are, in part because their hair turns white at about 40.

**Size:** 3-4 feet (0.9-1.2 m) tall.

**Weight:** 100 to 200 pounds (45-90 kg), mostly muscle.

**Average Life Span:** 250+ years; some have lived up to 500.

**Enemies:** Goblins, hob-goblins, orcs, ogres, trolls and Wolfen, along with most of the so-called monster races. The vast majority of dwarves and elves still dislike each other and regard the other with suspicion and prejudice - racial hatred that has spanned 7,000 years. Changelings, giants and creatures of magic are generally disliked.

**Allies:** Dwarves are especially fond and tolerant of humans and are frequently active and valued members of the community. Most also consider kobolds, troglodytes and gnomes as allies. They are indifferent toward faerie folk and titans.

**Habitat:** Found throughout the known world, but most common to the Western Empire, Old Kingdom, Timiro Kingdom and Eastern Territory. The largest subterranean dwarven communities are in the Old Kingdom Mountains.

**Favorite Weapons:** Battle axes, throwing axes, throwing knives, picks, large swords often worn on the back, and long-handled war hammers, maces, hercules clubs, morning stars and magic weapons.

## GM Notes

The ban on magic is a vow, not an incapacity. Dwarves were once the unrivalled masters of the mystic arts and alone held the secrets of rune magic; during the Elf-Dwarf wars they unleashed forces they could not control and which nearly destroyed both races. When it was over they vowed their people would never again practice the mystic arts, destroyed all mystic tomes and instructions, and those who held the knowledge in their minds never spoke of it again. The Tristine Chronicles: "Dwarf has forever forsaken the ways of magic. As so it should be."

Most dwarves love to USE magic items, weapons and armor. The vow is about study and practice, which is the distinction to hold at the table.

The +5% skill notes are not applied by the app - see the extraction notes. Eleven skills are affected, plus any Military skill, and they are worth writing onto the sheet by hand if the campaign cares.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dwarf');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dwarf';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-dwarf-class.sql');
