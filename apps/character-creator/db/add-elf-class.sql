-- The Elf R.C.C., Palladium Fantasy RPG Main Book p.290-291.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-elf-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-elf-class.sql
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
SELECT 'elf', 'Elf', 'palladium-fantasy', '---
id: elf
name: Elf
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.290-291
category: rcc
attribute_dice:
  IQ: "3d6+1"
  ME: "3d6"
  MA: "2d6"
  PS: "3d6"
  PP: "4d6"
  PE: "3d6"
  PB: "5d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "5d6"
bonuses:
  pools: { sdc: 10 }
natural_abilities:
  - name: "Nightvision"
    description: "60 feet (18.3 m)."
  - name: "Horror Factor"
    description: "Not applicable."
  - name: "Long-Lived"
    description: "The average elf lives 600 years and some have lived as long as 1200, so vast amounts of knowledge can be gathered and skills honed to perfection in what would be ten lifetimes for a human."
extraction_notes: |
  - S.D.C. reads "10 plus those gained from O.C.C.s and/or physical skills", so the 10 is a POOL BONUS rather than sdc_base. Printed 18: "Some non-human races and O.C.C.s also get special S.D.C. bonuses. All S.D.C. points/bonuses are cumulative." Stating it as sdc_base would replace the occupation''s own roll instead of adding to it.
  - "O.C.C.s Available to Elves: Any" is recorded in the Lore rather than enforced; nothing in the app restricts which occupation a race may take.
  - Average P.P.E. is "5D6 for most adults, unless a mage or clergy O.C.C.; 1D6x10 for elven children till about age 16". The child figure is not a player character.
  - The elf page prints no bonuses beyond nightvision - unusually for a nonhuman race, its whole advantage is in the attribute dice.
---

## Lore

The origin of the elf stretches back into the legendary Age of Chaos. Elves, dragons, titans and some say changelings were among the few to survive the battle with the Old Ones, and were responsible for the incarceration of the Old Ones and the inception of a new era. Elves rose to great power and ruled the Old Kingdom for ten thousand years, until arrogance toward their dwarven allies exploded into a war fuelled by envy and ego that lasted two thousand years and left both kingdoms broken.

Losing everything they built and loved actually did teach the elves humility. Over the last six millenniums most have learned to value all life forms and have worked to make the world a better place. There are no longer any elven kingdoms; hated and hunted by most of the monster races, elves have found sanctuary within human society, where many hold high positions - advisors to kings, heads of churches, scholars, teachers, merchants and masters of the mystic arts. Half of all alchemists are elves. One saying goes, "If an elf cannot walk tall among his own people, then he will walk with man."

**Alignments:** Any; player characters usually lean toward good and selfish.

**O.C.C.s available:** Any.

**Physical Appearance:** Tall, slender humanoids with very handsome, distinguished, youthful features, black or dark brown hair, pointed ears and dark eyes.

**Height:** Six feet to six feet ten inches (1.8 to 2.9 m).

**Weight:** 100 to 250 pounds (45-112 kg).

**Average Life Span:** 600 years.

**Enemies:** Wolfen, goblins, hob-goblins, orcs, kobolds, ogres, trolls, changelings, giants and most monster races, as well as most evil supernatural beings and villainous creatures of magic.

**Allies:** Humans are the elves'' greatest ally. They will also sometimes ally with titans and Rahu-Men, the occasional dwarf, friendly gnomes, and depending on the circumstances members of the monster races who are of a good alignment - including changelings, giants, kobolds, and even creatures of magic like a well-meaning dragon or sphinx, and the gentler faerie folk such as pixies, brownies, sprites and faeries, who love elves.

**Habitat:** The human kingdoms and nations, especially Phi, Lopan, the Eastern Territory, Old Kingdom and Timiro, but elves can be found anywhere in the known world. Only the half dozen cities and towns in the Old Kingdom near the Eastern Territory remain of the Elven Empire.

**Favorite Weapons:** Any, but swords, knives, blunt weapons, the long bow and magic weapons are among their favorites.

## GM Notes

The Wolfen regard elves with a strange reverence they have never shown any other race, and covet their friendship, support and knowledge - especially in the mystic arts. The feeling is not mutual: most elves regard the Wolfen as sub-human barbarians and the enemy of their beloved human allies, and often fight against them at the side of humans. That asymmetry is worth playing; a Wolfen lord will bend over backwards for the slightest kind word from an elven mage, scholar or elder.

Elves still tend to appear impudent, arrogant and elitist as well as noble, honorable, valiant and spirited. Some have devoted their lives to humble pursuits and helping others, some are selfish and conniving, and others are outright evildoers.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'elf');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'elf';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-elf-class.sql');
