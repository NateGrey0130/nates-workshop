-- The Shade R.C.C., Rifts Dimension Book 1: Wormwood p.133-134.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-shade-class.sql
--
-- THE PAGE RANGE IS 133-134, NOT THE SURVEY'S 133-135. The shade's stat block
-- ends on printed 134 at Alliances & Allies; the rest of 134 and all of 135 are
-- the SKELTER BAT, which p.157 names among the creatures that are NOT available
-- as player characters. Same shape as the entrancer's range in #356 and for the
-- same reason: an over-wide window points a third of the class at a creature
-- this import deliberately excludes, and source-coverage would score the whole
-- range traceable anyway.
--
-- That is the THIRD page range in this import that the survey's own class table
-- got wide or short - the symbiotic warrior (64-66, really 64-65), the apok
-- (55-58, really 55-59) and the entrancer (126-129, really 126-127) were the
-- others. The survey's table is an index, not a citation.
--
-- The vampire-sense is written as a NATURAL ABILITY rather than a psionic
-- power: the book calls it a special power on top of the six it lists, and the
-- catalog has no row for it.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was written.
--
-- Follows the pattern #356 set for the R.C.C.s, which is worth stating because
-- three of the four rules were learned by a test failing rather than by reading
-- a reference:
--
--   * NO xp_table. regression.mjs pins that no R.C.C. carries one - experience
--     comes from what you do rather than from what you are, and the composition
--     fix in #222 depends on it. p.157 DOES print a ladder for every race in
--     this book, and it is what made them importable at all, so each one's
--     numbers are recorded in extraction_notes rather than dropped.
--   * NO related or secondary skills. They come from the O.C.C. Zero is
--     correct rather than missing, and all four of these grant zero.
--   * attacks are combat.attacks_base, which REPLACES the default of two - a
--     creature states a total where a class states a bonus.
--   * no sdc_base anywhere: all four are mega-damage creatures carrying
--     mdc_base, so none needs a CORE_SDC_BY_CLASS entry. A racial S.D.C. would
--     be a POOL BONUS and never sdc_base.
--
-- Money: no starting_money anywhere. Every class in this book prints
-- "Money: Not applicable" - Wormwood barters.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'shade', 'Shade', 'rifts', '---
id: shade
name: Shade
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.133-134
category: rcc
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6+10"
  PP: "3d6+6"
  PE: "3d6+6"
  PB: "2d4"
  Spd: "3d6+6"
mdc_base: "2d4x100"
ppe_base: "1d4x100"
bonuses:
  combat: { attacks_base: 3, initiative: 1, strike: 3, parry: 2, dodge: 2, roll: 3, pull_punch: 3 }
  saves: { spell_magic: 1, toxins_poisons: 2, disease: 2, horror_factor: 5 }
  at_level:
    - { level: 4, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%, spoken and read" }
    - { name: "Language: Dragonese", base: 98, per_level: 5, note: "98%, spoken and read" }
    - { name: "Detect Ambush", base: 30, per_level: 5 }
    - { name: "Detect Concealment", base: 30, per_level: 5, note: "+5%" }
    - { name: "Intelligence", base: 38, per_level: 4, note: "+6%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%; the book prints basic math" }
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P.s of choice, including modern weapons." }
    - { choose: 2, categories: ["Pilot"], note: "Two piloting skills." }
    - { choose: 2, categories: ["Rogue"], bonus: 10, note: "Two rogue skills (+10%)." }
    - { choose: 3, categories: ["Science", "Technical"], bonus: 10, note: "Three science or technical skills of choice (+10%)." }
psionics:
  type: "major"
  isp_base: "3d4x10"
  powers: ["Mind Block", "Telepathy", "Death Trance", "Levitation", "Impervious to Fire", "Ectoplasm"]
magic:
  type: "spell"
  spells: ["Shadow Meld", "Energy Disruption", "Escape", "Tongues", "Fly", "Fly as the Eagle"]
natural_abilities:
  - { name: "Turn Invisible in Darkness or Shadow", description: "The shade''s most dangerous power, alongside shadow meld. It also sees the invisible." }
  - { name: "Dimensional Teleport", description: "65%, FOUR tries per 24 hours, back to its homeworld or another familiar place." }
  - { name: "Nightvision", description: "1200 feet (366 m)." }
  - { name: "Resistant to Fire and Cold", description: "Normal fire and cold do half damage; MAGIC fire does full damage." }
  - { name: "Impervious to Poison and Disease", description: "Entirely - and impervious to the bite and the mind control of vampires." }
  - { name: "Sense Vampires", description: "A special psionic power: the shade instantly senses and recognizes a vampire on sight." }
  - { name: "Bio-Regeneration", description: "1D4x10 M.D.C. once a minute." }
  - { name: "Body Armor", description: "Typical shade armor has 75 M.D.C. and a -5% prowl penalty, but they can wear anything a human can. Shades usually wear black armor with grey or red trim." }
restrictions: ["A player character must be a renegade and a traitor, hated and hunted by other demons"]
side_effects: "EYES SENSITIVE TO BRIGHT LIGHT: distracting and painful, they must squint, and ALL COMBAT BONUSES ARE REDUCED BY HALF. LIGHT ENERGY - lasers and lightning - inflicts DOUBLE damage, and a magic sphere of light holds the demon at bay exactly as it does a vampire. Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 1D4x1000. Damage: bite 1D4 M.D.; punches and kicks come off the supernatural P.S."
extraction_notes: "THE PAGE RANGE IS 133-134, NOT THE SURVEY''S 133-135. The shade''s stat block ends on printed 134 at Alliances & Allies, and the rest of 134 and all of 135 are the SKELTER BAT, which p.157 names among the creatures that are NOT available as player characters. Same shape as the entrancer''s range in #356, and for the same reason: an over-wide window points at a creature this import deliberately excludes and source-coverage would still score it traceable. || Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is its OWN, shared with nothing else, which is the only such ladder among these four: 0 / 2,501 / 5,001 / 10,001 / 20,001 / 28,501 / 38,501 / 52,001 / 72,001 / 105,001 / 140,001 / 190,001 / 235,001 / 290,001 / 350,001. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone. || All six spells and all six psionic powers already existed. The vampire-sense is written as a natural ability rather than a psionic power, because the book calls it a special power on top of the listed six and the catalog has no row for it. || Money: no starting_money; Special vehicle is None to start. Body armor is described rather than issued."
---

## Lore

The shade tends to be quiet, calm and confident even in the worst crisis. They
are intelligent predatory demons who use their brains and their natural powers
rather than brute force - cunning, devious, stealthy, good strategists, and they
work well in a group. Those who serve the Unholy act as elite warriors,
commanders, spies and assassins. Their most dangerous powers are turning
invisible in darkness and the shadow meld. Like most true demons they travel the
Megaverse and have visited many planets over the ages, Earth among them.

Physically the shade is frightening. The head is large and round with huge fangs
rimming a wide smiling mouth, the lower jaw usually hidden in shadow, the nose
only a skeletal pair of holes, and large white eyes that give the whole head a
sort of Jack-o-Lantern look. There is no body hair, though a dozen thin feathers
or fins protrude from the top of the head, and the body is covered in large black
oval scales.

## GM Notes

The shade is a foul-hearted demon and an NPC villain by default. A player
character must be a renegade and a traitor, hated and hunted by other demons;
capture leads to torture and death, or to a dismal life chained to a life force
battery. The rare player character starts at first or second level and can be of
any alignment, probably selfish.

NPC levels are equal to a wizard or an espionage agent: 60% fourth level, 20%
sixth, 15% eighth or higher. They live about 4000 years - the longest-lived race
in this slice.

**Run it as the one that plans.** Everything about the shade points at
preparation rather than force: shadow meld, invisibility in darkness, four
dimensional teleports a day, detect ambush and detect concealment, and a bonus
structure that rewards striking first. Its two weaknesses are the same weakness -
light. Bright light halves every combat bonus it has, lasers and lightning do
double damage, and a magic sphere of light pins it like a vampire. A party that
brings light to a shade fight is fighting a different creature.

Allegiances run 80% sworn to the Unholy, 5% to the Champions of Light, and 15%
mercenaries and freebooters.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'shade');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'shade';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-shade-class.sql');
