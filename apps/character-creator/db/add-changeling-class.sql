-- The Changeling R.C.C., Palladium Fantasy RPG Main Book p.308-310.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-changeling-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-changeling-class.sql
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
SELECT 'changeling', 'Changeling', 'palladium-fantasy', '---
id: changeling
name: Changeling
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.308-310
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "4d6+6"
  MA: "4d6"
  PS: "3d6"
  PP: "3d6"
  PE: "2d6"
  PB: "2d6"
  Spd: "2d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "5d6"
bonuses:
  saves: { psionics: 2, mind_control: 2, horror_factor: 2 }
natural_abilities:
  - name: "Shape Changing"
    description: "A changeling can alter shape and size to assume the appearance of any humanoid creature - not animals, insects or objects, and it cannot grow or remove limbs or appendages. It can instantly grow hair or fur of any type and color and otherwise change its appearance completely. Size runs from three feet (0.9 m) to ten feet (3 m); mass varies only thirty pounds or so, so when small they are fat and when tall they are thin. One full melee round (15 seconds) is required to complete a transformation. When assuming the guise of a particular living person the changeling can adjust its diet to gain or lose weight and make the impersonation perfect. Only the physical appearance, size and shape change - attributes are always the same regardless, and clothes do not change to fit the new body. Changelings are asexual and can physically become male, female or both."
  - name: "Superior Mental Endurance and Affinity"
    description: "A changeling aura is not much different from an elf''s or a human''s, and even a high level mind mage may not be able to discern an appreciable difference. Their extremely high mental endurance makes mental probes or examinations an equally difficult task."
  - name: "Natural Armor Rating"
    description: "None."
  - name: "Horror Factor"
    description: "10."
extraction_notes: |
  - S.D.C. reads "those gained from O.C.C.s and physical skills only", so the changeling states no S.D.C. of its own and carries no pool bonus.
  - "+2 to save vs telepathic probes, mind control and horror factor" lands on `psionics` (a telepathic probe is a psionic attack), `mind_control` and `horror_factor`. The page adds "in addition to bonuses gained from attributes, O.C.C., and skill bonuses", which is how the app already sums them.
  - NOT MODELLED - "+5% to disguise skill". A per-skill modifier on a skill the OCCUPATION grants, and the app has no race-level per-skill modifier. It is not a grant: the page does not give the changeling the Disguise skill, only a bonus if it has one. Apply by hand.
  - The page prints a Natural Armor Rating line - the only player race that does - and its value is None. Recorded because the absence is stated rather than omitted.
  - Horror Factor 10 is a number the changeling PROJECTS; the app has no field for it.
  - Psionics: "Standard, same as humans", so no psionics block and no psionics_allowed - the character rolls on the Random Psionics Table like anyone else.
  - "O.C.C.s available to the Changeling: Any O.C.C. without limitation."
---

## Lore

Changelings are an ancient race of shape changers universally feared and hunted by all other races except elves - and even elves do not trust them completely. Naturally they are seven-foot, thin, pale yellow skinned humanoids with large sad eyes and rather homely features, and all of them can shape change into any humanoid creature. They are creatures of magic with a history as old as the elves'', and nobody knows their origin; most believe they are the evil creation of the Old Ones or a similar dark supernatural force. Even the changelings do not know their own ancestry.

Countless legends warn of their treachery - infamous villains accused of plotting the destruction of the other races by assuming their shapes and slaying them while they slept, implicated in scores of disasters, assassinations and mysterious disappearances. Much of it is superstition, but enough changelings have captured or killed a person to assume his identity for spying that the fear has fuel.

Changeling hysteria is a constant, recurring phenomenon: massive witchhunt-style purges launched on the mere suggestion of a conspiracy, sweeping the entire civilized world for decades at a time, with the accused killed where they stand before they can shape-shift and escape. Of the millions slaughtered over the millenniums, an estimated 40% were innocent people falsely accused. No other creature in the Palladium World has been more persecuted, and that is the primary reason changelings hide their true identity: to do otherwise means death.

Today it is believed that changelings are extinct or nearly so, but how does a person identify a creature who can assume any humanoid shape at will? Trouble erupts when one dies of old age, disease or accident and the true form is revealed. Inevitably the worst is assumed and slaughter, fuelled by panic, follows.

**Alignments:** Any.

**O.C.C.s available:** Any, without limitation.

**Physical Appearance:** With shape changers, who knows?

**Height:** Seven feet (2.1 m) as a changeling; 3-10 feet (0.9-3 m) otherwise.

**Weight:** 180 to 250 pounds (81 to 112.5 kg) is average.

**Average Life Span:** 250+ years.

**Enemies:** All races are feared.

**Allies:** Traditionally elves come closest to being an ally. Changelings also like to keep secret company among humans, elves, Wolfen and other humanoid canines, orcs and trolls.

**Favorite Weapons:** None in particular.

**Habitat:** Can be found anywhere. Rumors that a changeling colony may exist in the Yin-Sloth Jungles or the Floenry Islands are starting to circulate.

## GM Notes

Although changelings do have a bloody history, they are not necessarily evil. Many are benevolent toward the other races and capable of great feats of courage, friendship and loyalty; many grow to identify so closely with the race they are impersonating that they develop a genuine sense of kinship with it. Some have secretly become great kings, priests, wizards and heroes.

Playing a changeling is not much different from playing a human or an elf. The only real difference is that changelings are very careful in choosing their friends and usually keep their true identity secret for a long time - which makes the reveal, whenever it comes, the most dangerous moment in the character''s life.

See Palladium RPG Book VI: Island at the Edge of the World for more history and adventures regarding changelings.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'changeling');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'changeling';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-changeling-class.sql');
