-- The Human R.C.C., Palladium Fantasy RPG Main Book p.288-289.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-human-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-human-class.sql
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
SELECT 'human', 'Human', 'palladium-fantasy', '---
id: human
name: Human
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.288-289
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "2d6"
natural_abilities:
  - name: "Horror Factor"
    description: "Not applicable."
  - name: "Adaptable"
    description: "Good intelligence, creative, resourceful and adaptable. Humans also exhibit a reasonably high percentage of psychic ability - see the Random Psionics Table."
extraction_notes: |
  - S.D.C. reads "Standard; see determining S.D.C. and physical skills", which is the core rule on printed 18 - men of arms roll 3D6, everyone else 1D6 - so this race adds nothing of its own and states no sdc_base. compose.js supplies the core roll from the OCCUPATION, which is where the book puts that decision.
  - "O.C.C.s Available: Any" is recorded in the Lore rather than enforced: nothing in the app restricts which occupation a race may take. Humans are the one race for which that limitation costs nothing.
  - Average P.P.E. is "2D6 for most adults, unless a mage or clergy O.C.C.; 5D6 for human children till about age 18". The child figure is not a player character and is not stored; a mage or clergy O.C.C. states its own P.P.E. and wins, because a pool the race states is replaced by nothing but its own occupation''s.
  - Enemies, Allies, Habitat, Physical Appearance, Height, Weight and Average Life Span have no schema field and are recorded in the Lore section.
---

## Lore

Humans have created the strongest, most advanced civilization of the current Age. They have the strongest armies and fleets, have mastered magic and are expanding at an alarming pace. Humans have established forts, villages and towns in nearly every corner of the world. Human civilization in the Palladium World is roughly equivalent to those on Earth during the Middle Ages - kings and emperors, nobles, knights, crusaders, priests, scholars, serfs, castles, kingdoms and fiefdoms - but the existence of magic, sorcerers, demons and inhuman creatures makes even human cities exotic places of sword and sorcery. Humans may dominate the land, but it is a world where dragons roam, demons interfere in the affairs of men, and human wizards dare to challenge the gods.

**Alignments:** Any; player characters usually lean toward good and selfish.

**O.C.C.s available:** Any.

**Physical Appearance:** Varies widely; tend to be tall, lean and muscular, light skinned with blonde, brown and black hair.

**Height:** 5 feet to 6 feet 6 inches (1.5 to 1.9 m).

**Weight:** 100 to 200 pounds (45-90 kg).

**Average Life Span:** 60 years.

**Enemies:** Wolfen, goblins, hob-goblins, orcs, kobolds, ogres, trolls, changelings, giants and most monster races, as well as most supernatural beings and creatures of magic, often regardless of the creature''s alignment.

**Allies:** Elves, dwarves and gnomes are man''s closest allies. Humans are also occasionally joined by titans and Rahu-Men, and depending on the circumstances will consider a limited allegiance with other races, including creatures of magic such as the sphinx and dragons, and even supernatural beings. Indifferent toward troglodytes and faerie folk.

**Habitat:** Human kingdoms and nations include the Western Empire, Timiro, Bizantium, Land of the South Winds, Phi, Lopan and the Eastern Territory, particularly its southern portion. Small cities, towns, villages and tribes of humans are also found in the Great Northern Wilderness, the Old Kingdom and places worldwide.

**Favorite Weapons:** Any. For better or worse, humans are proficient at warfare and weapon making, and magic weapons are part of both war and human technology.

## GM Notes

Human is the baseline the rest of the chart is measured against: 3D6 in every attribute, the core hit point and S.D.C. rules, no natural abilities, no horror factor and no restriction on occupation. A player who picks an O.C.C. and no race is playing a human, and always was - this entry exists so the choice can be made explicitly and so the Race step has something to show.

The book''s "Other Notes" for humans are attitude rather than mechanics: they worship a variety of deities, wear all types of armor, are highly educated and explore all areas of knowledge, and are aggressive yet also able to show compassion and kindness.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'human');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'human';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-human-class.sql');
