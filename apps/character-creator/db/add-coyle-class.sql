-- The Coyle R.C.C., Palladium Fantasy RPG Main Book p.312.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-coyle-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-coyle-class.sql
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
SELECT 'coyle', 'Coyle', 'palladium-fantasy', '---
id: coyle
name: Coyle
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.312
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6"
  PS: "3d6+1"
  PP: "4d6+1"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
bonuses:
  pools: { sdc: 10 }
  combat: { initiative: 1 }
  saves: { horror_factor: 1 }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m), with excellent day vision equal to a human''s."
  - name: "Track Blood Scent"
    description: "A Coyle can follow the scent of blood up to 500 feet (152 m) away. Base Skill: 24% +4% per level of experience."
  - name: "Recognize Scent of Others"
    description: "Recognize and follow a familiar scent up to 50 feet (15 m) away. Base Skill: 12% +4% per level of experience; +10% to recognize and follow the scent of a mate or offspring. Roll once for every 100 feet (30.5 m) when following a scent trail; a failed roll means the trail is lost."
  - name: "Keen Hearing"
    description: "The character''s hearing is as keen as a dog''s and has the same range of hearing."
  - name: "Punch or Claw Strike"
    description: "1D6 damage plus P.S. damage bonus."
  - name: "Kick"
    description: "2D6 damage plus P.S. damage bonus."
  - name: "Bite"
    description: "1D6 damage. The P.S. damage bonus does not apply."
  - name: "Horror Factor"
    description: "11."
extraction_notes: |
  - S.D.C. reads "10 plus those gained from O.C.C.s and physical skills", so the 10 is a POOL BONUS rather than sdc_base.
  - The Coyle is the Wolfen''s opposite number and the two entries invite comparison: the Coyle tracks blood scent BETTER (24% against 20%) and recognizes a familiar scent WORSE (12% against 16%), is quicker (P.P. 4D6+1 against 3D6) and weaker (P.S. 3D6+1 against 4D6+1), has half the racial S.D.C., one less point of horror factor bonus, and does one die less damage with claws and bite.
  - Horror Factor 11 is a number the Coyle PROJECTS; the app has no field for it.
  - Size is 6 feet plus 4D6 inches, so a Coyle character rolls its own height. No schema field; it is in the Lore.
  - Psionics: "Standard; same as humans", so no psionics block.
  - The page runs the Magic and Psionics lines together - "Magic: By O.C.C. only. Psionics: Standard; same as humans." - on one printed line; both are read as their own statement.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

The Coyle represent a serious problem to the Wolfen Empire. They are shiftless, mean-spirited and lazy riffraff who might be considered the canine humanoid equivalent of goblins - chaotic, vicious warriors who raid communities and groups of Wolfen, other Coyles and non-canine races for both fun and profit. They love to frighten and intimidate others as well as engage in acts of murder, terrorism and wanton destruction. It is the smaller, more wiry Coyles who have been responsible for most of the highly publicized "Wolfen" attacks and atrocities in the Eastern Territory, and most humans do not make the distinction despite the sharp differences.

**Alignment:** Any, but tends toward anarchist and miscreant - the antithesis of the noble Wolfen.

**O.C.C.s available:** Any, but Coyles lean toward the men at arms - particularly thieves, assassins and rangers - and vagabonds. Most are too aggressive and lazy to study magic or scholarly pursuits.

**Physical Appearance:** Giant humanoid coyotes. The body is covered in dark or light grey fur, with a canine muzzle and teeth, powerful jaws, and hazel, brown or green eyes. The legs are very animal-like, reminiscent of a trained dog walking on its hind legs.

**Size:** 6-8 feet tall (1.8 to 2.4 m); 6 feet plus 4D6 inches.

**Weight:** 200 to 300 pounds (91 to 136 kg) of muscle and sinew.

**Average Life Span:** 45+ years; some have lived up to 65.

**Enemies:** The same as the Wolfen, only much more irreverent toward all people. Coyles dislike Kankoran because they are too tough, driven and good, and Bearmen and Algor giants because they are too serious.

**Allies:** Kobolds, orcs, goblins, bug bears and other wild and vicious monster races. Indifferent toward most giants, troglodytes and faerie folk. Coyles generally find their Wolfen cousins up-tight, bossy and too serious; although they often cooperate with Wolfen, they are unreliable and given to desertion and betrayal.

**Habitat:** Found living with or near their Wolfen cousins throughout the world, although seldom farther south than the Old Kingdom. Humans consider them part of the Wolfen Empire, although they have independent tribes ranging from thousands to hundreds of thousands. The Great Northern Wilderness and the Eastern Territory are their main homelands.

**Favorite Weapons:** Spears, swords, and long and short bows, as well as magic weapons and items.

## GM Notes

Playing a Coyle is basically the same as playing a Wolfen, except that Coyles tend to be scoundrels, thieves and barbarians. They are lazy and hate physical labor but absolutely love to hunt, kill, torture and fight, though rarely to the death. Sloppy, unreliable, prone to foolish risks, wild, unorganized and undisciplined, as well as cocky and impudent.

They worship a variety of deities and wear all types of armor, favoring scale mail, splint, half plate, and plate and chain - the same tastes as the Wolfen, worn with none of the discipline.

See Adventures in the Northern Wilderness, Monsters & Animals and the Wolfen Wars books for more on the canine races of the North.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'coyle');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'coyle';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-coyle-class.sql');
