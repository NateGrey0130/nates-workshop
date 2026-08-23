-- The Orc R.C.C., Palladium Fantasy RPG Main Book p.302-304.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-orc-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-orc-class.sql
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
SELECT 'orc', 'Orc', 'palladium-fantasy', '---
id: orc
name: Orc
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.302-304
category: rcc
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "3d6"
  PS: "3d6+8"
  PP: "3d6"
  PE: "3d6+2"
  PB: "2d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "2d6"
psionics_allowed: false
bonuses:
  pools: { sdc: 10 }
  combat: { roll: 1 }
  saves: { horror_factor: 3 }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m), with excellent day vision equal to a human''s."
  - name: "Track Blood Scent"
    description: "An orc can follow the scent of blood up to 1000 feet (305 m) away. Base Skill: 15% +5% per level of experience."
  - name: "Recognize Scent of Others"
    description: "Recognize and follow a familiar scent up to 50 feet (15 m) away. Base Skill: 10% +3% per level of experience; +13% to recognize and follow the scent of a mate or offspring. Roll once for every 100 feet (30.5 m) when following a scent trail; a failed roll means the trail is lost."
  - name: "Clawed Hands"
    description: "1D6 damage plus P.S. damage bonus."
  - name: "Bite"
    description: "1D6 damage. The P.S. damage bonus does not apply."
  - name: "Horror Factor"
    description: "None."
restrictions:
  - "No psionics. The orc page states Psionics: None."
  - "Magic by witchcraft and priest O.C.C.s only."
  - "O.C.C.s available: limited to mercenary, soldier, assassin, thief, black priest, witch and vagabond. They tend toward men of arms, especially mercenary and thief."
extraction_notes: |
  - S.D.C. reads "10 plus those gained from O.C.C.s and physical skills", so the 10 is a POOL BONUS rather than sdc_base.
  - "+1 to roll with impact" is the `roll` combat key, which exists because Rifts classes needed it; this is the first Palladium Fantasy race to use it.
  - The scent abilities are percentile skills that rise per level, but they belong to no catalog category and are granted by the race rather than chosen, so they are natural_abilities prose with the numbers stated. The app does not track them as skills.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

Orcs are the most common of the sub-human races, goblins being second. They have a reputation for being dull-witted, muscle-bound brutes with a wicked disposition, and most people regard them as stupid, greedy creatures with delicate egos that make them vulnerable to all manner of deception and trickery. Whether or not that is fair, it is what an orc character will meet everywhere - and it cuts both ways, because most people greatly underestimate them and some will talk right in front of one as if it were not present.

Orcs revel in destruction and mayhem, often selling their services as mercenaries, spies, thugs and thieves. They are poor craftsmen but hard workers who do not flinch from heavy, difficult or repugnant labor, which is why virtually every race imaginable has at one time used them as migrant farmers, low-wage workers, slaves or pawns. The Western Empire has a huge orc slave population.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Mercenary, soldier, assassin, thief, black priest, witch and vagabond.

**Physical Appearance:** Husky, muscular humanoids who stand about the same height as humans but are much broader and more heavily muscled - even the females look like heavyweight boxers. The nose is large and flat with large nostrils, the ears pointed like an elf''s, eyebrows thick and bushy, and the mouth large and filled with sharp teeth and canine fangs. The hair is black and usually grown into a long, wild mane or worn back in a ponytail.

**Size:** 5 feet to 6 feet 8 inches (1.5 to 1.9 m).

**Weight:** 160 to 250 pounds (72 to 112.5 kg).

**Average Life Span:** 50+ years; some have lived up to 80.

**Enemies:** Hate humans, elves, dwarves, gnomes and changelings - though an orc will serve them as a slave, or if impressed by uncommon physical strength, combat skill or magic powers.

**Allies:** Regularly befriends, works and lives with goblins, hob-goblins and ogres. Respects and often follows Wolfen, trolls and giants. Indifferent towards kobolds, troglodytes and most creatures of magic.

**Habitat:** Common to all climes and terrain, but orcs seem to prefer woodlands and hilly, rocky or mountainous regions, partly because of their close relationship with goblins. They also have a habit of living amidst the ruins of abandoned structures of every kind. Most common in the Old Kingdom, Eastern Territory, Western Empire (50% of them slaves), Timiro and in the South.

**Favorite Weapons:** Any, but most lean toward large, heavy weapons like battle axes, pole arms and large swords. They love magic weapons.

## GM Notes

To an orc, true power is the freedom to do whatever one wants to whomever one wants, so they will obey and follow any being who possesses great physical strength or incredible magic power, or who promises great treasure and glory. They worship evil gods, devils, demons and even powerful dragons, sphinx, giants and sorcerers.

The counterweight worth playing: male and female orcs are surprisingly caring, nurturing parents, very protective of their young, and will fight to the death to defend mate and children. Raiders who slay or kidnap an orc child will be hunted down by the parents - and sometimes other family members and friends - and brutally slain, however many years it takes.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'orc');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'orc';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-orc-class.sql');
