-- The Goblin R.C.C., Palladium Fantasy RPG Main Book p.299-302.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-goblin-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-goblin-class.sql
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
SELECT 'goblin', 'Goblin', 'palladium-fantasy', '---
id: goblin
name: Goblin
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.299-302
category: rcc
attribute_dice:
  IQ: "2d6"
  ME: "3d6"
  MA: "2d6"
  PS: "3d6"
  PP: "3d6+6"
  PE: "3d6"
  PB: "2d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "6d6"
bonuses:
  pools: { sdc: 5 }
  saves: { faerie_magic: 1, horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "90 feet (27.4 m), plus good day vision and an aptitude for digging and living in tunnels."
  - name: "Underground Tunneling (Special)"
    description: "Fundamentally the same as for dwarves, only much cruder. Base Skill: 30% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Fundamentally the same as for dwarves, only much simpler and cruder. Base Skill: 10% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "Fundamentally the same as for the dwarf, but less acute. Base Skill: 20% +5% per level. Judging the approximate proximity of surface structures is poor: 10% +5% per level, -20% in an unfamiliar area."
  - name: "Digging Speed"
    description: "Spd 1D6 while digging, against 3D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "None."
restrictions:
  - "O.C.C.s available: limited to assassin, thief, mercenary, soldier, black priest, witch, vagabond and the occasional psychic. Most goblins become thieves or mercenaries."
  - "All weapons except pole arms and long bows."
extraction_notes: |
  - S.D.C. reads "5 plus those gained from O.C.C.s and physical skills", so the 5 is a POOL BONUS rather than sdc_base.
  - "+1 to save vs faerie magic" needed a `faerie_magic` save key, added in the same pass alongside `disease`; it borrows the P.E. magic row.
  - Average P.P.E. is "6D6 for the typical goblin, 3D4x10 plus 1D6 per level of experience for the Cobbler". 6D6 is stored; the Cobbler figure belongs to a sub-race the app cannot express - see below.
  - NOT IMPORTED - THE GOBLIN COBBLER, printed 302, an "Optional R.C.C." A goblin is a Cobbler on a percentile roll of 1-15. A Cobbler has metamorphosis at will into a small dark animal, six faerie spells cast twice per 24 hours at third-level strength (mend wood, wither plants, sense magic, tongues, charm, darkness), +1 to save vs all magic, +1 vs possession, +3 vs horror factor, and +10% to carpentry, boat building and sculpting/whittling. All other stats are the average goblin''s, and a character with major or master psionic powers cannot be a Cobbler. It is NOT expressible as a `variants` entry: VARIANT_OVERRIDES admits only attribute_dice, attribute_requirements, the pool bases, bonuses and skill_overrides, and the Cobbler''s whole substance is a magic block and an abilities block. Modelling it needs either a widened variant or a second class, and that is a decision rather than a transcription.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

Goblins, hob-goblins, kobolds and orcs are believed to be malicious, ugly members of the faerie folk, but except for the Cobbler Goblin these races lack any natural magic powers. They are thieves and bushwhackers who lurk in the shadows and attack the unsuspecting - cruel, malevolent creatures attracted to evil and power like moths to a flame, and so eager if unreliable henchmen for thieves'' and assassins'' guilds, bandits, witches, evil sorcerers, black priests, deevils and demons.

Goblins are the descendants of a swarthy mining race, but recent generations have forsaken the pick and shovel for the sword and dagger in pursuit of easy treasure, and many have given up their subterranean habitats to live on the surface. Their society lives by the philosophy that the strong prey upon the weak: a shabby tribal unit under a warrior chieftain, a war chief, and a cleric leader - dark priest, witch, druid or shaman - third in command.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Assassin, thief, mercenary, soldier, black priest, witch, vagabond and the occasional psychic.

**Physical Appearance:** Short and skinny with spindly limbs. Even a robust goblin with a broad chest and thick neck will have comparatively thin arms and legs. Black, brown or red hair, large ears and mouth, and dark eyes.

**Size:** 3 to 4 feet (0.9 to 1.2 m).

**Weight:** 70 to 120 pounds (31.5 to 54 kg).

**Average Life Span:** 80+ years; some have lived up to 150.

**Enemies:** Humans, kobolds, dwarves, gnomes, changelings, and especially elves. A goblin will nevertheless accept and serve a member of any of these races if the character proves to be evil, ruthless and powerful enough to impress and intimidate them. Goblins dislike their fellow faerie folk, except for some of the uglier, meaner kin like toadstools and bogies.

**Allies:** Regularly work with hob-goblins, orcs, ogres and trolls. Indifferent towards troglodytes, giants and most creatures of magic.

**Habitat:** Found throughout the world but most common in the Old Kingdom, Eastern Territory, Western Empire, Timiro and in the South. The largest known communities are in the Old Kingdom.

**Favorite Weapons:** All except pole arms and long bows.

## GM Notes

A goblin player character is likely to be a mercenary, thief, assassin or young adventurer out to find his place in the world. Selfish and evil characters view humans and most good characters with contempt, suspicion, or as suckers to be used - but goblins respect strength, ruthlessness and power, so they tend to be relatively loyal and obedient to such characters. Otherwise the character watches out only for himself and will cheat, lie and betray the party, though blatant acts will get him into trouble.

A good-aligned goblin is loyal, honorable and friendly, and uncommon; evil goblins view such characters as wimps and kiss-ups and treat them accordingly.

Although aggressive, mean and given to acts of terrorism and brutality, goblins and hob-goblins are easily intimidated and bluffed by demonstrations of power, and they operate best in small groups with a charismatic and powerful leader. Desertion among goblin armies typically runs at 60% within weeks.

**The Cobbler.** Roll percentile at creation if the table wants it: 1-15 indicates a Cobbler, a goblin with real faerie magic and a respected place in the community. The app cannot express one yet - see the extraction notes for exactly what it grants and why it is not a variant.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'goblin');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'goblin';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-goblin-class.sql');
