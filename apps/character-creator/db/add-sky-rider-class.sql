-- The Sky Rider R.C.C., Rifts Dimension Book 1: Wormwood p.135-136.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-sky-rider-class.sql
--
-- THE LAST OF THE SEVENTEEN. Printed 136 continues into the TEMPORAL RAIDER,
-- which is deliberately excluded: it has an XP ladder on p.157 and a section on
-- pp.136-137, and both point at Rifts World Book Three: England for the actual
-- character data. The pages here are lore. 17 classes, not 18.
--
-- Its horror factor is CONDITIONAL - 8 on foot, 15 on a skelter bat or a
-- feathered serpent - so neither number is in bonuses:, which are applied
-- unconditionally. Both are on the "Brave Only in the Air" ability, which is
-- also the character's whole personality.
--
-- Horsemanship comes at three rates: skelter bat and feathered serpent +16%,
-- any other large flying creature +8%, and horse at no bonus. The catalog has
-- no per-creature rows, and the first two are both exotic mounts, so they
-- collapse onto Horsemanship: Exotic Animals at the HIGHER +16% - the mounts he
-- actually owns. Same collapse the demon hound rider records in #356.
--
-- The two flying mounts are a NATURAL ABILITY rather than equipment. The
-- skelter bat and the feathered serpent are both NPC-only creatures p.157
-- excludes from play, so there is no class and no gear row to point an
-- item_id at.
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
SELECT 'sky-rider', 'Sky Rider', 'rifts', '---
id: sky-rider
name: Sky Rider
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.135-136
category: rcc
attribute_dice:
  IQ: "3d4+1"
  ME: "3d4+3"
  MA: "3d4+1"
  PS: "3d6+14"
  PP: "2d6+10"
  PE: "2d6+10"
  PB: "3d4"
  Spd: "4d6"
mdc_base: "2d4x10"
ppe_base: "2d6"
bonuses:
  combat: { attacks_base: 4, initiative: 1, strike: 3, parry: 1, dodge: 1, pull_punch: 1, roll: 5 }
  saves: { spell_magic: 1, psionics: 2, toxins_poisons: 2, disease: 2, horror_factor: 4 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Other", base: 98, per_level: 0, note: "His native tongue of Skr''lyr, a dialect of Br''talb, at 98%." }
    - { name: "Language: Demongogian", base: 80, per_level: 5, note: "80%" }
    - { name: "Language: Gobblely", base: 80, per_level: 5, note: "80%" }
    - { name: "Language: Native Tongue", base: 80, per_level: 0, note: "The book prints this as American (80%)." }
    - { name: "Mathematics: Basic", base: 50, per_level: 5, note: "+5%; the book prints basic math" }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: Exotic Animals", base: 46, per_level: 4, note: "+16% for the skelter bat and the feathered serpent; +8% for any other large flying creature. The higher figure is stored." }
    - { name: "Horsemanship: General", base: 40, per_level: 4, note: "The book prints horsemanship: horse, with no bonus." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Preserve Food", base: 30, per_level: 5, note: "+5%" }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%" }
    - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "+15%; the book prints track animals" }
    - { name: "W.P. Sword" }
    - { name: "W.P. Chain" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice, including modern weapons." }
    - { choose: 4, categories: ["Physical", "Rogue", "Technical", "Wilderness", "Domestic"], note: "Four skills of choice from the physical, rogue, technical, wilderness or domestic categories." }
natural_abilities:
  - { name: "Aerial Acrobat", description: "Keen hawk-like vision, double-jointed, ambidextrous, exceptional balance 92%, walk tightrope or high wire 84%, back flip 86%, climb rope 88%, and a leap of 10 feet (3 m) high or lengthwise plus six feet (1.8 m) from a running start." }
  - { name: "Two Flying Mounts", description: "Two skelter bats or feathered serpents, or one of each. Sky riders can also ride most winged creatures - gryphons, dragondactyls, peryton, harpies and dragons." }
  - { name: "Body Armor", description: "Some wear armor and some do not; all are lesser mega-damage creatures in a magic rich environment. Mega-damage chain mail and half suits add 40 M.D.C. and full plate adds 100, though only 15% wear full plate and 50% wear half suits. Earth style sunglasses and aviator goggles are favorite apparel." }
special_abilities:
  - name: "Combat Stunts"
    description: "The whole point of the race. Flying at great speed, threading narrow places, backflips and somersaults, riding side-saddle, hanging upside down, forming a human chain and dangling in the wind, leaping from one flying creature to another, and hanging from the saddle, arm, foot or mouth of the animal to grab or swing at an opponent. In combat: snare an opponent, carry him high and drop him; snare and drag him across the ground into obstacles at speed; knock people off their mounts; spook animals and troops by flying an inch over their heads; snatch helmets, weapons and valuables out of hands. BOWLING FOR SOLDIERS is a favorite - the victim is snared and swung, hurled or rolled into a group of warriors, taking 3D6 damage himself and knocking 2D4 people off their feet, who lose initiative and one melee action and take 1D6 damage from the impact; the G.M. may roll to see whether the bowled-over dropped a weapon or a valuable. The most popular tactic is to snare someone off the ground and fling or drag him into a mountain, a building or a pillar, usually with a grappling hook on a line and reel like a giant fishing pole. When feeling confident they will swing a victim into the jaws or claws of another monster, or play catch and monkey in the middle with him. They also BOMB - seldom with explosives, usually with boulders, carcasses and snared victims dropped on enemies and enemy structures." }
  - name: "Brave Only in the Air"
    description: "On foot, caught alone or badly outnumbered, a sky rider can be a sniveling coward afraid of his own shadow. The second he is on a skelter bat or a feathered serpent he becomes an insane daredevil frightened of nobody: buzzing battle saints, flying through walls of fire, attacking a small army. HORROR FACTOR IS 8 ON FOOT AND 15 ON A FLYING MOUNT."
restrictions: ["No psionic powers", "No magic knowledge", "The best alignment possible is anarchist, and even then the character is a wild idiot without regard for others"]
side_effects: "Stupid, fearless even when they should be frightened, reckless. They take crazy risks, endanger others, and will often fight against impossible odds or fly into the jaws of death laughing all the way. They are lousy strategists - but they work well in the air in groups, and their unpredictable antics often give them the edge. Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 6D6, plus 1D6x10 S.D.C."
extraction_notes: "Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, shared with the demon goblin, the demon hound rider and the ram-rat, and it is what made the race importable at all, so the numbers are recorded here rather than lost: 0 / 1,971 / 3,941 / 7,881 / 14,881 / 21,881 / 31,881 / 41,221 / 54,441 / 74,661 / 104,881 / 139,221 / 189,441 / 239,661 / 289,881. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone. || Horsemanship: the book grants it at three different rates - skelter bat and feathered serpent +16%, any other large flying creature +8%, and horse at no bonus. The catalog has no per-creature rows, and the first two are both exotic mounts, so they collapse onto Horsemanship: Exotic Animals at the HIGHER +16% - the mounts he actually owns. Horsemanship: horse is Horsemanship: General at its catalog base. Same collapse the demon hound rider records in #356. || The horror factor is CONDITIONAL - 8 on foot, 15 on a mount - so neither number is in bonuses, which are applied unconditionally. It is on the Brave Only in the Air ability. || Money: no starting_money. The two flying mounts are a natural ability rather than equipment: the skelter bat and the feathered serpent are both NPC-only creatures that p.157 excludes from play, so neither has a class or a gear row to point at. || Attacks are stored as combat.attacks_base, which REPLACES the default of two."
---

## Lore

Even the wildest canine demon guard will tell you that sky riders are all crazy.
They are infamous for taking ridiculous risks and performing outrageous stunts
and aerial acrobatics. Most people insist they are too stupid to be afraid - not
entirely true. On foot and alone or badly outnumbered, a sky rider can be a
sniveling coward. The second he is on the back of a skelter bat or a feathered
serpent he becomes an insane daredevil, frightened of nobody, and takes glee in
every kind of aerial daring-do.

They are always grinning, snickering, laughing or gleefully shouting cat-calls
and obscenities. Physically they loosely resemble humans: bipeds with sunken,
widely spread eyes that give them a skeletal look, a large mouth full of sharp
pointed teeth and canine fangs, lips almost always curled into a grotesque
smile, and grey skin - some more blue-grey with hints of violet - with black or
grey hair over the arms, legs, head and back.

They wear whatever they want, favor Earth-style sunglasses and aviator goggles,
and love grappling hooks, nets and chain weapons.

## GM Notes

**A sky rider player character is a liability, and the book says so plainly.**
The best possible alignment is anarchist, and even then he is a wild idiot with
no regard for others. He could change sides or betray the party for any reason
at any time, and even a loyal one will get everybody into trouble by bragging,
lying, name-calling, spitting, brawling, cheating, stealing and starting or
joining fights. He seldom knows when enough is enough.

The twist is that his own kind will not punish him for it: other sky riders see
his involvement with humans as some kind of stupid joke, and he gets no worse
than a reprimand. Annoy a demon lord, though, and he may be killed on the spot.
Start at first or second level.

Allegiances run 80% sworn to the Unholy and 20% unallied bandits and adventurers,
most of whom prey on humans and on br''talb demon hound riders. Not more than a
tiny handful associate with the Champions of Light, and even their motives are
suspect. They live about 90 years, and NPC levels run 45% second, 20% fourth, 20%
sixth and 15% eighth or higher.

The br''talb demon hound riders of #356 are their natural enemies, on both
homeworlds and on this one.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'sky-rider');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'sky-rider';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-sky-rider-class.sql');
