-- The Troglodyte R.C.C., Palladium Fantasy RPG Main Book p.295-297.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-troglodyte-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-troglodyte-class.sql
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
SELECT 'troglodyte', 'Troglodyte', 'palladium-fantasy', '---
id: troglodyte
name: Troglodyte
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.295-297
category: rcc
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "3d6"
  PS: "4d6+4"
  PP: "3d6+6"
  PE: "3d6"
  PB: "2d6"
  Spd: "6d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "3d6"
psionics_allowed: false
bonuses:
  pools: { sdc: 10 }
  combat: { attacks: 1, initiative: 1 }
  saves: { toxins_poisons: 2, disease: 2, horror_factor: 1 }
natural_abilities:
  - name: "Nightvision"
    description: "The keenest of any player race: 600 feet (183 m). Day vision is weak by contrast - 30 feet (9 m) - even after the eyes have adjusted to the light."
  - name: "Underground Tunneling (Special)"
    description: "Broad, powerful creatures, a troglodyte can carve through solid rock with primitive tools faster than any other subterranean race. Their tunnels are crude and they pay no attention to design features or the techniques of other tunnel makers. Base Skill: 30% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Troglodytes do not create pretty dwellings with smooth walls or works of art; theirs are rough and unfinished, often resembling natural formations, but sturdy and safe. A trog travelling slowly and cautiously can locate underground traps and avoid or deactivate them, but can never make any. Base Skill: 20% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "An incredible ability to tell direction underground even in total darkness, not applicable on the surface; basically the same as the dwarf''s. Base Skill: 40% +5% per level. Judging the approximate proximity of surface structures is poor: 15% +5% per level, -20% in an unfamiliar area."
  - name: "Retractable Claws"
    description: "1D6 damage plus P.S. damage bonus, if any."
  - name: "Bite"
    description: "2D4 damage. The P.S. damage bonus does not apply to bites."
  - name: "Digging Speed"
    description: "Spd 3D6 while digging, against 6D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "None when friendly and peaceful; 13 when angry and transformed to fight."
restrictions:
  - "No magic and no psionics. The troglodyte page states both as None."
  - "O.C.C.s available: limited to mercenary, soldier, thief, assassin, monk or vagabond."
extraction_notes: |
  - S.D.C. reads "10 plus those gained from O.C.C.s and physical skills", so the 10 is a POOL BONUS rather than sdc_base - printed 18 says all S.D.C. bonuses are cumulative.
  - The extra melee attack is a flat combat bonus and stacks on top of whatever the Hand to Hand skill sets, which is right: the page grants it "in addition" to everything else.
  - "+2 to save vs poison and disease" needed the `disease` save key, added in the same pass alongside `faerie_magic`.
  - Horror Factor is conditional - none until the trog transforms - so it is prose in natural_abilities rather than a number the app could apply. The app has no field for a horror factor a creature PROJECTS; saves.horror_factor is the bonus for resisting one.
  - O.C.C. Skill Notes: not applicable. This is one of the six races with nothing there.
---

## Lore

Troglodytes are a gentle race of subterranean humanoids similar in habit to dwarves and kobolds, though not as intelligent as either, leading a sheltered, reclusive life deep beneath the surface. Their communities have little social structure, no rules or laws, no leader or chieftain, no god or religious doctrine, no social class and no functioning economy. They live side by side, sharing and caring for each other as circumstances demand, surviving by animal-like instincts and uncommon cooperation and compassion.

Peaceful and passive in the extreme, troglodytes will not attack unless scared, threatened or attacked first, and if their tunnels are invaded they usually run away and hide. But when a trog child, female or loved one is threatened, hurt or killed, heaven help the person who did it. Troglodyte males are instinctively the protectors of their people and fight with a speed and fury that is nearly unbelievable; the transformation of the bashful little creature into a roaring fighting machine is enough to startle the most seasoned warriors, and sometimes enough on its own to drive away an invader. Entire armies have fallen to a few hundred trogs defending their people.

**Alignment:** Any, but most tend to be good or unprincipled; a selfish or evil troglodyte is a rarity.

**O.C.C.s available:** Mercenary, soldier, thief, assassin, monk or vagabond.

**Physical Appearance:** Broad shouldered, pale skin tone, large dark eyes, fat flabby-looking bodies with heads that seem to resemble lizards or amphibians rather than humans.

**Size:** 4 to 5 feet tall.

**Weight:** 130 to 250 lbs.

**Average Life Span:** 90+ years; some have lived up to 140.

**Enemies:** Goblins and hob-goblins are ancient enemy invaders and bandits who sometimes hunt trogs for food or fun. Kobolds are known to force troglodytes out of their tunnels when they discover the trogs have inadvertently tapped into valuable mineral resources. Most troglodytes fear and dislike all surface dwellers, including humans and elves.

**Allies:** None per se; tends to be indifferent toward dwarves and gnomes.

**Habitat:** Found periodically throughout the known world, but most common to the mountainous regions of the Western Empire, Old Kingdom, Timiro Kingdom and Baalgor Wastelands. The largest subterranean communities are in the Old Kingdom Mountains.

**Favorite Weapons:** Thrown rocks, stone axe, stone hammer, stone knife and similar crude stone tools and weapons.

## GM Notes

A troglodyte player character is likely to be a young, single male or female curious about the world, and the very fact that the character is exploring the surface and associating with surface dwellers is a huge departure from the norm. Such a character will be innocent and naive, at least at first. General fears and suspicions about surface dwellers are likely to keep them cautious, but a trog who first meets a group of good people may become too trusting until they learn otherwise - and the complete lack of knowledge about the surface world, its people, customs, laws and traditions, like paying for things, is likely to get the poor fellow and his companions into all kinds of trouble.

The other direction is equally playable: troglodytes can become hardened and cynical from the hard knocks they suffer at the hands of cruel or dispassionate surface dwellers. Pick a direction and go with it.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'troglodyte');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'troglodyte';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-troglodyte-class.sql');
