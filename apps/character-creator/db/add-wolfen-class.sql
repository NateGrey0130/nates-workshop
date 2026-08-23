-- The Wolfen R.C.C., Palladium Fantasy RPG Main Book p.310-312.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-wolfen-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-wolfen-class.sql
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
SELECT 'wolfen', 'Wolfen', 'palladium-fantasy', '---
id: wolfen
name: Wolfen
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.310-312
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+1"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "4d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
bonuses:
  pools: { sdc: 20 }
  combat: { initiative: 1 }
  saves: { horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m), with excellent day vision equal to a human''s."
  - name: "Track Blood Scent"
    description: "A Wolfen can follow the scent of blood up to 500 feet (152 m) away. Base Skill: 20% +4% per level of experience."
  - name: "Recognize Scent of Others"
    description: "Recognize and follow a familiar scent up to 50 feet (15 m) away. Base Skill: 16% +4% per level of experience; +10% to recognize and follow the scent of a mate or offspring. Roll once for every 100 feet (30.5 m) when following a scent trail; a failed roll means the trail is lost."
  - name: "Keen Hearing"
    description: "The character''s hearing is as keen as a dog''s and has the same range of hearing."
  - name: "Punch or Claw Strike"
    description: "2D4 damage plus P.S. damage bonus."
  - name: "Kick"
    description: "2D6 damage plus P.S. damage bonus."
  - name: "Bite"
    description: "2D4 damage. The P.S. damage bonus does not apply."
  - name: "Horror Factor"
    description: "12."
extraction_notes: |
  - S.D.C. reads "20 plus those gained from O.C.C.s and physical skills", so the 20 is a POOL BONUS rather than sdc_base.
  - Horror Factor 12 is a number the Wolfen PROJECTS; the app has no field for it. Recorded in natural_abilities.
  - Size is 6 feet plus 1D4 additional feet, so a Wolfen character rolls its own height. No schema field; it is in the Lore.
  - Psionics: "Standard; same as humans", so no psionics block - the character rolls on the Random Psionics Table.
  - "O.C.C.s available: any, without restriction, although most lean toward the men at arms."
  - O.C.C. Skill Notes: not applicable.
---

## Lore

The greatest threat to human dominance of the Palladium world is the emerging Wolfen Empire. Once lost to bickering and warring among themselves, the Wolfen were considered witless buffoons much like orcs and goblins; since the unification of the twelve Wolfen tribes they have proven themselves clever, inventive, adaptive and valiant warriors with a keen mind for strategy and tactics. They are incredibly well organized, disciplined and just, and much like the early days of the Roman Empire they are building a reputation for strength, justice, loyalty and military might. Also like the Romans, they are masters of diplomacy and subterfuge, offering aid and assistance to any kingdom or people - even humans - who request it. Treaties, pacts and alliances complete the transaction, which the Wolfen fulfill to the letter; a party who breaks such an agreement is crushed or bullied into submission.

The Wolfen goal is to conquer the known world and unite all races under one global government, organized, led and enforced by Wolfenkind. Word has spread that these canine humanoids do not destroy or enslave their conquered people but rebuild their cities, protect and provide for them, and allow them to keep and openly practice their religious faiths so long as they are not subversive to Wolfen rule. This fair play is unprecedented even in human society, and so the Wolfen Empire slowly grows and prospers.

**Alignment:** Any, but tends toward principled and aberrant - both alignments with a strong personal code of honor.

**O.C.C.s available:** Any, without restriction.

**Physical Appearance:** Just as the name suggests, giant humanoid wolves. The body is covered in dark or light grey fur, with a canine muzzle and teeth, powerful jaws, and hazel, brown or green eyes. The legs are very animal-like, reminiscent of a trained dog walking on its hind legs.

**Size:** 7-10 feet tall (2.1 to 3 m); 6 feet plus 1D4 additional feet.

**Weight:** 250 to 500 pounds (112.5 to 226 kg).

**Average Life Span:** 50+ years; some have lived up to 80.

**Enemies:** Humans, dwarves and changelings, and they dislike faerie folk - though a Wolfen may associate with any of them. Elves are allied to humans and therefore regarded as an enemy, even while the Wolfen covet elven knowledge and friendship and are constantly soliciting their favor.

**Allies:** Kobolds, Coyles, Kankoran, Bearmen, Algor giants, orcs, goblins and other monster races. Indifferent toward most giants, troglodytes and faerie folk.

**Habitat:** Found throughout most of the world, although seldom farther south than the Old Kingdom. The Wolfen Empire and the largest communities of canines are in the Great Northern Wilderness, and to a much lesser degree the Eastern Territory and Lopan.

**Favorite Weapons:** Pole arms, ball and chain, swords and axes. They love rune weapons and magic items.

## GM Notes

Magic is new to the Wolfen, so there are not as many sorcerers among the canines as there are among humans and elves. They generally see supernatural forces as evil and dangerous and seldom ally themselves to the supernatural, but they worship a variety of Northern Gods and Gods of Light and have no qualms about commanding supernatural forces the way humans and elves do.

Wolfen are competent builders, craftsmen, smiths and artisans, highly disciplined men of arms - many are professional soldiers, knights, rangers, long bowmen and palladins - and they provide aid and protection to all who request it. When a human visits a Wolfen community the prejudice runs the other way for once, and Wolfen tend to be a bit more tolerant and less judgmental about it than humans are.

See Adventures in the Northern Wilderness, Monsters & Animals and the Wolfen Wars books for more on the canine races of the North.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wolfen');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'wolfen';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-wolfen-class.sql');
