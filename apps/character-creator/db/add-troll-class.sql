-- The Troll R.C.C., Palladium Fantasy RPG Main Book p.306-308.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-troll-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-troll-class.sql
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
SELECT 'troll', 'Troll', 'palladium-fantasy', '---
id: troll
name: Troll
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.306-308
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "2d6"
  MA: "2d6"
  PS: "4d6+10"
  PP: "4d6"
  PE: "3d6+6"
  PB: "1d6+4"
  Spd: "2d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
psionics_allowed: false
skills:
  occ_skills:
    - { name: "Climbing", base: 75, per_level: 5, note: "Instinctive climbers. The book prints 75%/65 - the second figure is rappelling, which the catalog does not hold separately." }
    - { name: "Swimming", base: 60, per_level: 5, note: "Instinctive swimmers." }
bonuses:
  pools: { sdc: 40 }
  combat: { attacks: 1 }
  saves: { horror_factor: 3 }
natural_abilities:
  - name: "Nightvision"
    description: "60 feet (18.3 m), with excellent day vision equal to a human''s."
  - name: "Clawed Hands"
    description: "2D6 damage plus P.S. damage bonus."
  - name: "Kick"
    description: "3D6 damage plus P.S. damage bonus."
  - name: "Bite"
    description: "2D4 damage. The P.S. damage bonus does not apply."
  - name: "Troll-Sized Weapons"
    description: "Troll and giant weapons weigh three to five times more than the standard human-sized equivalent and do ONE EXTRA DIE of damage, in addition to any P.S. bonus. The gear catalog holds the human-sized figures; add the die at the table."
  - name: "Horror Factor"
    description: "12."
restrictions:
  - "No psionics. The troll page states Psionics: None."
  - "O.C.C.s available: any except psychic P.C.C.s and illusionist. Trolls tend toward mercenary fighter, thief, assassin, witch, monk or clergy; most seldom dabble in magic."
extraction_notes: |
  - S.D.C. reads "40 plus those gained from O.C.C.s and physical skills" - the largest racial S.D.C. in the book - so the 40 is a POOL BONUS rather than sdc_base.
  - The extra melee attack is a flat combat bonus and stacks on top of whatever the Hand to Hand skill sets.
  - Climbing and Swimming ARE grants: the page says trolls are instinctive climbers and swimmers with those base skills, so they are occ_skills at the printed percentage. The book''s own skill list (printed 49) spells it "Climb/Scale Walls"; the catalog holds "Climbing", which is one of the documented Rifts renames. `base` fixes the percentage rather than adding to the catalog''s 40 and 50.
  - Horror Factor 12 is a number the troll PROJECTS; the app has no field for it. Recorded in natural_abilities.
  - Size is 8 feet plus 1D6 additional feet, so a troll character rolls its own height. No schema field; it is in the Lore.
  - The extra damage die on troll-sized weapons is a per-weapon modifier the gear model cannot express, so it is prose.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

Trolls are a race of vindictive, sadistic monsters who enjoy tormenting their victims before they kill them, particularly humans and their humanoid allies. They engage in acts of intimidation, degradation and terrorism, and have a reputation as extortionists who demand a stiff payment or a humiliating deed before a traveler may pass - at bridges, mountain passes, city gates or the entry to a building. In other cases the creature insists on combat, winner takes all possessions and is allowed to pass. These challenges are not usually to the death unless the troll is angered; it is more fun to degrade somebody than to kill him.

The legendary might and ferocity of trolls lets them deal amiably with all other monster races, but they enjoy the company of kobolds above any other. A troll will often be accompanied by two to eight kobolds and will share his spoils and residence with them; orcs, goblins and hob-goblins are customarily employed as underlings if friendly kobolds cannot be found. They are ferocious fighters who love boxing and hand to hand combat, so they seldom use spears or missile weapons except for the occasional thrown boulder.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Any except psychic P.C.C.s and illusionist.

**Physical Appearance:** Large monstrosities slightly smaller than giants but equally strong, if not stronger. The mere sight of them can be terrifying: they resemble giant, hairy corpses with pale, almost white, blotchy skin, stringy hair, red-rimmed eyes and huge fangs.

**Size:** 9-14 feet tall (2.7 to 4.3 m); 8 feet plus 1D6 additional feet.

**Weight:** 300 to 700 pounds (136 to 317 kg).

**Average Life Span:** 120+ years; some have lived up to 200.

**Enemies:** Hate humans, elves and changelings. Has little respect for any other people, including the monster races and fellow giants.

**Allies:** Most trolls have an affinity toward kobolds and vice versa, and a troll is often found in the company of small kobold bands or living near a kobold community. Ogres, orcs, ratlings, goblins and hob-goblins are second choice for minions, but a troll may associate with any race.

**Habitat:** Found throughout the world as solitary predators, in pairs, or in small groups of 3D4. They predominantly dwell in rocky areas - mountains, ravines, caverns, gorges, and the bases of cliffs and large hills - usually inhabiting caves or building large stone huts or towers. Even the rare large community seldom exceeds 30 members. The largest known communities are in the Old Kingdom and Baalgor Wastelands.

**Favorite Weapons:** Large blade weapons such as sickles, scythes, axes, picks and large swords.

## GM Notes

Most people who are not giant-sized fear trolls and will avoid even those who are allegedly heroes, and a troll is the first to fall under suspicion for anything that goes wrong in a community. Many human, elven and dwarven towns will not serve them; goblins, orcs and other nonhumans will cater to their needs but fear them as much as humans do, for trolls are known to be fiendishly sneaky, ruthless, bloodthirsty and given to sudden acts of violence. Only kobolds are spared their wrath.

A troll character has the same size problems the ogre does - custom clothing and equipment - and additionally needs to consume five times the food required by the average human adult. Clever, cunning, treacherous and cruel, mixed with a wickedly cheerful temperament and deceptively friendly demeanor: a troll''s wealth is judged by the size of his treasure hoard and the skulls that line his lair, and they increase their menacing appearance by wearing the skulls and bones of their victims as belts, bracelets, necklaces and accents on armor.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'troll');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'troll';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-troll-class.sql');
