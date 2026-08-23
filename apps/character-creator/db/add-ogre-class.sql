-- The Ogre R.C.C., Palladium Fantasy RPG Main Book p.304-306.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-ogre-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-ogre-class.sql
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
SELECT 'ogre', 'Ogre', 'palladium-fantasy', '---
id: ogre
name: Ogre
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.304-306
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+4"
  PP: "3d6"
  PE: "3d6+6"
  PB: "2d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
psionics_allowed: false
skills:
  occ_skills:
    - { name: "Recognize Weapon Quality", base: 40, per_level: 5, note: "Automatic to every ogre, in addition to O.C.C. and related skills; +15% racial bonus." }
    - { name: "Falconry", base: 40, per_level: 5, note: "Automatic to every ogre, in addition to O.C.C. and related skills; +10% racial bonus." }
    - { name: "Animal Husbandry", base: 45, per_level: 5, note: "Automatic to every ogre, in addition to O.C.C. and related skills; +10% racial bonus." }
bonuses:
  pools: { sdc: 20 }
  saves: { horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m), with excellent day vision equal to a human''s."
  - name: "Clawed Hands"
    description: "2D4 damage plus P.S. damage bonus."
  - name: "Kick"
    description: "3D6 damage plus P.S. damage bonus."
  - name: "Bite"
    description: "2D4 damage. The P.S. damage bonus does not apply."
  - name: "Horror Factor"
    description: "10."
extraction_notes: |
  - S.D.C. reads "20 plus those gained from O.C.C.s and physical skills", so the 20 is a POOL BONUS rather than sdc_base.
  - The ogre is the ONE race whose O.C.C. Skill Notes are a grant rather than a modifier: "In addition to other O.C.C. and related skills, the character automatically gets the following skills: recognize weapon quality (+15%), falconry (+10%) and animal husbandry (+10%)." So they are occ_skills at the catalog base plus the printed bonus, and combineClasses holds each once at the higher base if the occupation grants it too.
  - Horror Factor 10 is a number the ogre PROJECTS, and the app has no field for it - saves.horror_factor is the bonus for resisting one. Recorded in natural_abilities.
  - Size is 6 feet plus 1D6 additional feet, so an ogre character rolls its own height. There is no schema field for it; it is in the Lore.
  - "O.C.C.s available: any, without restriction" is the least constrained race in the book alongside the changeling and the Wolfen.
---

## Lore

Ogres are huge, hairy, muscular humanoids sporting wicked canine teeth and sharp claws, with a warm grey to tan complexion and a thick hide that is sometimes scaling or flaking. As giants with a reputation for being ferocious, powerful warriors, an ogre is likely to be targeted by attackers as the first one to bring down. Ogres who associate with humans stand head and shoulders above them, and as the saying goes, he who sticks his head above the crowd is likely to get a brick thrown at it.

Although terrible craftsmen, ogres recognize and appreciate well-crafted weapons and armor, and items made from precious metals, gem-encrusted or endowed with magic properties are coveted. They can learn and master any skill a human can, but most prefer to fight and conquer rather than learn a trade.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Any, without restriction.

**Physical Appearance:** Huge, hairy and muscular, with small round ears, dark eyes and dark hair.

**Size:** 7-12 feet tall (2.1 to 3.6 m); 6 feet plus 1D6 additional feet.

**Weight:** 250 to 500 pounds (112.5 to 226 kg).

**Average Life Span:** 90+ years; some have lived up to 130.

**Enemies:** Hate humans, elves, dwarves, gnomes, changelings and faerie folk - though an ogre will occasionally serve a powerful warlord or mage of those races.

**Allies:** Regularly befriends, works and lives with orcs. Dislikes goblins, hob-goblins, kobolds, Wolfen, trolls, giants and most other races, but will consider working with them if the ogre is the leader or the reward is great enough. Indifferent towards troglodytes.

**Habitat:** Found in small clans and clusters throughout the world, except the Western Empire unless a slave or gladiator. The largest known communities are in the Old Kingdom and the southwestern Yin-Sloth Jungles.

**Favorite Weapons:** Any. Favorites include large swords, axes and blunt weapons - mace, morning star, cudgel - and many ogres are adept with the sling and the ball and chain.

## GM Notes

Ogres are awkwardly sized: considerably larger than humans but smaller than most true giants, so clothing and equipment cost more than the normal human price and may require custom-made items. That is a running expense worth charging, and a running inconvenience worth playing.

They do not work well in large groups and are very competitive. They tend to view all races other than the orc with suspicion and contempt, worship evil gods, devils and demons, and often sell their services as mercenaries, thugs and assassins. Armor is usually one extreme or the other - splint, scale and plate, or nothing more than a loincloth.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'ogre');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'ogre';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-ogre-class.sql');
