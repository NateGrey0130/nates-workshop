-- The Kobold R.C.C., Palladium Fantasy RPG Main Book p.297-299.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-kobold-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-kobold-class.sql
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
SELECT 'kobold', 'Kobold', 'palladium-fantasy', '---
id: kobold
name: Kobold
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.297-299
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "2d6"
  MA: "3d6"
  PS: "3d6+3"
  PP: "3d6"
  PE: "3d6"
  PB: "1d6+6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "4d6"
skills:
  occ_skills:
    - { name: "Field Armorer & Munitions Expert", base: 50, per_level: 5, note: "Metalworking (Special): a basic understanding of working with metal, particularly weapons and jewelry. Equal to the field armorer skill with a +10% bonus." }
bonuses:
  pools: { sdc: 5 }
  combat: { initiative: 1 }
  saves: { horror_factor: 2 }
natural_abilities:
  - name: "Nightvision"
    description: "400 feet (122 m). Day vision 40 feet (12 m)."
  - name: "Underground Tunneling (Special)"
    description: "Exactly the same as dwarves. Base Skill: 40% +5% per level of experience."
  - name: "Underground Architecture"
    description: "Same as dwarves. Base Skill: 30% +5% per level of experience; detection and deactivation of traps is done at half the architecture skill."
  - name: "Underground Sense of Direction"
    description: "Same as dwarves. Base Skill: 40% +5% per level. Judging the approximate location of surface structures in a familiar area: 30% +5% per level, -25% in an unfamiliar area."
  - name: "Digging Speed"
    description: "Spd 1D6 while digging, against 3D6 running. The stored Spd is the running figure."
  - name: "Horror Factor"
    description: "Not applicable."
restrictions:
  - "O.C.C.s available: any except long bowman, knight or palladin."
extraction_notes: |
  - S.D.C. reads "5 plus those gained from O.C.C.s and physical skills", so the 5 is a POOL BONUS rather than sdc_base.
  - The kobold''s Underground Tunneling, Architecture and Sense of Direction are printed as "exactly the same as dwarves", so the dwarf''s figures are carried across verbatim rather than left as a cross-reference the reader has to chase.
  - NOT MODELLED - the rest of Metalworking. Besides the field armorer grant, the page adds "+10 on recognize weapon quality, art (limited to jewelry) and gemology skills". Those are per-skill modifiers on skills the OCCUPATION grants, and the app has no race-level per-skill modifier. Apply by hand.
  - Art is limited to jewelry, which the catalog''s single Art row cannot express either.
  - O.C.C. Skill Notes: not applicable.
---

## Lore

Kobolds are a subterranean race of miners, smiths and merchants with a passion for gold, silver and precious stones; the treasure vaults of a prosperous kobold merchant, nobleman or king are a sight to behold. They see clearly in near-total darkness and are at home in the deep tunnel complexes of the Old Kingdom Mountains, where the largest known communities are found.

Kobolds find goblins and orcs to be pathetic, ignorant barbarians worthy of contempt, and enjoy using, abusing and tormenting them; the hostility between kobold and goblin has lasted centuries. They consider dwarves foolish for their allegiance to humans but respect them as warriors and for their superior skill as armorers, stone workers and builders. The average kobold absolutely loathes elves.

**Alignment:** Typically anarchist or evil, but most player characters are likely to be unprincipled, anarchist, aberrant or even good.

**O.C.C.s available:** Any except long bowman, knight or palladin.

**Physical Appearance:** Short, thin but muscular creatures with a pale waxen complexion, no facial hair, black, silver or white hair with a high hairline, large ears that come to a rounded point, thick leathery skin, yellow or red eyes, and small pointed teeth.

**Size:** 3 to 4 feet (0.9 to 1.2 m).

**Weight:** 70 to 120 pounds (31.5 to 54 kg).

**Average Life Span:** 160+ years; some have lived up to 250.

**Enemies:** Humans, elves, gnomes and changelings. Kobolds sometimes invade troglodyte communities where valuable mineral resources are discovered.

**Allies:** Trolls, ogres, giants and Wolfen.

**Habitat:** Found throughout the world but most common in the Old Kingdom, Eastern Territory and Great Northern Wilderness. The largest known subterranean communities are in the Old Kingdom, the Old Kingdom Mountains and the Algor Mountains.

**Favorite Weapons:** Can use any, but favorites include axes, picks, hammers, knives and swords. They adore magic weapons.

## GM Notes

Kobolds worship demons and evil gods, and occasionally powerful dragons. They tend to be selfish, cruel, vindictive and arrogant, and they sometimes sell their services as mercenaries to nonhumans. They prefer studded, chain, scale and plate armor.

Kobolds are predators who hunt and feed on animals and fellow humanoids - gnomes, humans and elves are among their favorites - and about 40% are cannibalistic as well. A kobold player character will be viewed by most humans and their allies with the utmost suspicion, racial prejudice and possibly hatred, and the reputation is not entirely undeserved.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'kobold');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'kobold';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-kobold-class.sql');
