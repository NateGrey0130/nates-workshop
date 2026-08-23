-- The Gnome R.C.C., Palladium Fantasy RPG Main Book p.294-296.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-gnome-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-gnome-class.sql
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
SELECT 'gnome', 'Gnome', 'palladium-fantasy', '---
id: gnome
name: Gnome
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.294-296
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "1d6+6"
  MA: "3d6+4"
  PS: "1d6+4"
  PP: "4d6"
  PE: "3d6+6"
  PB: "4d6"
  Spd: "2d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "4d6"
psionics_allowed: false
bonuses:
  saves: { toxins_poisons: 1, disease: 1 }
natural_abilities:
  - name: "Nightvision"
    description: "90 feet (27.4 m), plus an aptitude for digging and living in tunnels."
  - name: "Underground Tunneling (Special)"
    description: "Like dwarves, gnomes dig and build solid, strong tunnels with no fear of a cave-in, and excavate ruins and cave-in sites with the same prowess. The gnome can usually tell whether an existing tunnel or chamber is a natural formation or was dug by gnomes, dwarves, kobolds, goblins, troglodytes or humans, and whether it is new, old or ancient. Base Skill: 30% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Gnome constructs are not as big or elaborate as dwarven ones, but gnomes are competent underground architects and recognize the styles of gnome, dwarven, kobold, goblin and other construction. A gnome travelling slowly and cautiously can locate underground traps and avoid or deactivate them. Base Skill: 20% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "The same as the dwarf''s: tell direction underground even in total darkness, not applicable on the surface. Base Skill: 30% +5% per level. Judging the approximate proximity of surface structures is a separate roll: 20% +5% per level, -20% in an unfamiliar area."
  - name: "Digging Speed"
    description: "Spd 1D6 while digging, against 2D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "Not applicable."
restrictions:
  - "No psionics. The gnome page states Psionics: None, so a gnome never rolls on the Random Psionics Table."
  - "O.C.C.s available: limited to any magic, clergy or optional O.C.C., as well as ranger, mercenary, soldier, thief or assassin."
  - "Spears, forks, pole arms, battle axes and ball and chains must be made gnome-sized - half the human equivalent, and half the damage. A human-sized weapon of those types is too large and awkward to use with any proficiency: -6 to strike, parry and dodge."
extraction_notes: |
  - S.D.C. reads "only those gained from O.C.C.s and physical skills", so the gnome states no S.D.C. of its own and carries no pool bonus. compose.js supplies the core roll (printed 18) from the occupation.
  - "+1 to save vs poison and disease" needed a `disease` save key, added alongside `faerie_magic` in the same pass; both borrow the P.E. row.
  - NOT MODELLED - the O.C.C. Skill Notes. "Add a bonus of +10% to prowl, and +5% to the following skills (all are in addition to O.C.C. bonuses): surveillance, intelligence, general repair, masonry, carpentry, rope works, locate secret compartments/doors, and land navigation." These modify skills the OCCUPATION grants, and the app has no race-level per-skill modifier. Apply by hand.
  - The gnome-sized weapon rule is a per-weapon penalty the gear model cannot express, so it is a restriction rather than a bonus.
  - "Magic: As practitioner of magic only" is the same statement as the O.C.C. list - a gnome casts if and only if the occupation does.
---

## Lore

Originally a subterranean race inhabiting the Old Kingdom, the gnomes were caught in the cross-fire between elf and dwarf during the Great War and nearly eradicated. The peace-loving gnomes had been friendly toward both and refused to take either side; the fallout of battle ravaged their kingdom anyway, killing an estimated 80-90%. The survivors blamed both, though hate and revenge are not in the gnomes'' nature and the vast majority forgave them. About one in ten still despises elves or dwarves to this day.

Clever and resourceful, gnomes have adapted easily to a life among humans, usually occupying houses on the surface or shallow tunnels built into low hills. Although subterranean creatures, they have always loved the sun, sky and trees. They are a surprisingly hardy people, full of life and adventure - friendly, cheerful, inquisitive and eager to explore. Standing only two to two and a half feet tall, they are frequently mistaken for pixies, brownies or leprechauns. Gnomes are extremely agile and possess a superior physical constitution that makes them excellent rangers, spies, thieves and assassins, and they are also strongly attracted to the study of magic, Wizardry and Diabolism in particular.

**Alignment:** Any, but most tend to be good or selfish; an evil gnome is a rarity.

**O.C.C.s available:** Any magic, clergy or optional O.C.C., plus ranger, mercenary, soldier, thief or assassin.

**Physical Appearance:** Very short, thin, handsome people with white hair, bushy eyebrows and sparkling eyes. Males almost always sport a neatly trimmed beard or mustache; females generally have long, flowing hair and look like beautiful porcelain dolls brought to life.

**Size:** 2 to 2 1/2 feet (0.6 to 0.75 m).

**Weight:** 20 to 50 pounds (9 to 22.6 kg).

**Average Life Span:** 300+ years; some have lived up to 600.

**Enemies:** Kobolds, goblins, hob-goblins, orcs, ogres, trolls and most of the so-called monster races. Some gnomes dislike and even hate elves and dwarves.

**Allies:** Humans, elves and faerie folk. Indifferent toward dwarves, troglodytes, changelings and Wolfen.

**Habitat:** Found throughout the known world, but most common to the Old Kingdom, Eastern Territory and Great Northern Wilderness. The only human kingdom gnomes avoid entirely is the Western Empire, which they regard as an evil place full of callous and self-obsessed people reminiscent of the elves of old.

**Favorite Weapons:** Knives, throwing knives, throwing axes, short swords, short bow, sling and small magic weapons.

## GM Notes

Gnome meat is a delicacy among kobolds and trolls, both of which have slain gnomes with a vengeance, and gnomes are also a favorite target of orcs, ogres and large animal predators. The population has fallen sharply over the last millennium, which is why so many have fled their shallow mountain tunnels for the safety of human cities and secluded forests. A gnome player character out in the world is a small, slow, valuable-looking target, and should feel like one.

Although the gnome and the dwarf are cousins, gnomes tend to avoid them, and some fiercely dislike them.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'gnome');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'gnome';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-gnome-class.sql');
