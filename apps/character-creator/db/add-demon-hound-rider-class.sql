-- The Demon Hound Rider R.C.C., Rifts Dimension Book 1: Wormwood p.125-126.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-demon-hound-rider-class.sql
--
-- THE HOUND ITSELF IS NOT IMPORTED. p.157 names demon hounds among the things
-- that are NOT available as player characters, and p.124 says outright that the
-- animal cannot be one - it may be a pet or a riding animal. Its stats are on
-- p.124-125 and stay there. The RIDER is what p.157 gives a ladder to.
--
-- The psionic union is the whole point of the race and costs NO I.S.P.: the
-- link is constant and immediate and needs no concentration, which is why the
-- book gives this character no I.S.P. at all and why there is no psionics block
-- here. Range is five miles PER LEVEL of the rider.
--
-- Two conditional bonuses are NOT in bonuses:, which are applied
-- unconditionally - the +6 to save vs mind control holds only while the hound
-- is at his side, and the -2 combat / -15% skills penalty fires only when a
-- linked hound dies. Both are in side_effects.
--
-- Horsemanship: the book grants it for demon hound (+16%), feathered serpent
-- (no bonus) and horse (+4%). The catalog has no per-creature rows for the
-- first two and both are exotic mounts, so they collapse onto the one
-- Horsemanship: Exotic Animals row at the demon hound's +16% - the higher, and
-- the mount he actually rides.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was written.
--
-- AN R.C.C. IS A RACE, so related and secondary skills come from the O.C.C. and
-- zero of each is CORRECT rather than missing. The holy terror in this same PR
-- is the exception that proves it: the book prints eight related and four
-- secondary on its own pages, so those ARE transcribed. The rule guards against
-- inventing them, not against reading them.
--
-- No sdc_base anywhere: every one of these is a mega-damage creature and
-- carries mdc_base, so none needs a CORE_SDC_BY_CLASS entry. A racial S.D.C.
-- would be a POOL BONUS and never sdc_base.
--
-- Attacks are stored as combat.attacks_base, which REPLACES the default of two,
-- because these creatures state a total rather than a bonus. The per-level
-- additions are at_level entries.
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
SELECT 'demon-hound-rider', 'Demon Hound Rider', 'rifts', '---
id: demon-hound-rider
name: Demon Hound Rider
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.125-126
category: rcc
attribute_dice:
  IQ: "3d6"
  ME: "3d6+4"
  MA: "3d6"
  PS: "4d6+8"
  PP: "3d6+4"
  PE: "4d6"
  PB: "3d4+3"
  Spd: "6d6"
mdc_base: "2d4x10"
ppe_base: "1d6"
bonuses:
  combat: { attacks_base: 3, initiative: 2, strike: 2, parry: 2, dodge: 1, roll: 2, pull_punch: 3 }
  saves: { horror_factor: 4, psionics: 1 }
  at_level:
    - { level: 4, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Other", base: 98, per_level: 0, note: "His native tongue of Br''talb, at 98%." }
    - { name: "Language: Demongogian", base: 85, per_level: 5, note: "85%" }
    - { name: "Language: Gobblely", base: 85, per_level: 5, note: "85%" }
    - { name: "Language: Native Tongue", base: 85, per_level: 0, note: "The book prints this as American (85%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints basic math" }
    - { name: "Dance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Sing", base: 35, per_level: 5 }
    - { name: "Sewing", base: 45, per_level: 5, note: "+5%" }
    - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
    - { name: "Horsemanship: Exotic Animals", base: 46, per_level: 4, note: "+16%; the book prints horsemanship: demon hound. It also grants horsemanship: feathered serpent at no bonus, which is the same catalog row." }
    - { name: "Horsemanship: General", base: 44, per_level: 4, note: "+4%; the book prints horsemanship: horse" }
    - { name: "Boat: Sail Type", base: 60, per_level: 5, note: "The book prints pilot: sailboat." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Preserve Food", base: 35, per_level: 5, note: "+10%" }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%" }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "+20%; the book prints track animals" }
    - { name: "W.P. Sword" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. spear/pole-arm is one of them; the catalog has no spear or pole-arm W.P., so both slots are of choice. The book also allows modern weapons." }
    - { choose: 4, categories: ["Physical", "Rogue", "Technical", "Wilderness"], note: "Four skills of choice from the physical, rogue, technical and wilderness categories." }
natural_abilities:
  - { name: "Psionic Union with the Demon Hound", description: "A limited empathy and sixth sense shared between man and beast, at a range of roughly five miles (8 km) PER LEVEL of the rider''s experience. The rider is instantly aware of any danger, smell, sound or strong emotion his animal notices, and the hound of his. It is virtually impossible to surprise either one while the other is on guard. NO I.S.P. IS SPENT AND NO CONCENTRATION IS NEEDED - the link is constant and immediate, which is why this character has no I.S.P. at all." }
  - { name: "Nightvision", description: "90 feet (27.4 m)." }
  - { name: "Keen Senses", description: "Keen eyesight, excellent hearing and a heightened sense of smell: track by scent 25%, track by blood scent 45%, recognize a person by scent 20%, recognize poison by scent 55%." }
  - { name: "Demon Hounds", description: "A player character has 1D4 demon hounds; an NPC villain owns 1D4+2. Most riders own a mated pair and three to eight young, usually the pair''s own offspring, and the whole family - the rider''s wife and children included - shares the same psionic link. In the wild the hounds gather in packs of 4D6, mate for life, and bear 1D4 pups every eight months." }
  - { name: "Standard Armor", description: "Plate body armor of 75 M.D.C., weighing 30 pounds, with a -10% prowl penalty. Horror factor is none normally, and 9 in the demon mask and armor." }
restrictions: ["No magic knowledge", "No psionic powers beyond the union with the hound, and no I.S.P."]
side_effects: "WHEN THE RIDER''S HOUND DIES he instantly knows it, and the distraction costs -2 on all combat bonuses and -15% on skill proficiencies for 1D6 hours. The same applies to any of the hound''s offspring he is linked to. He also empathically senses when the animal is in pain, which gives him a pounding headache and nausea. The +4 to save vs mind control listed in the book applies ONLY while the hound is at his side, so it is not stored as an unconditional bonus."
extraction_notes: "Related and secondary skills: NONE, and that is correct rather than missing. This is an R.C.C. and they come from the O.C.C. The holy terror in this same PR does print them; this one does not. || Horsemanship: the book grants horsemanship for demon hound (+16%), feathered serpent (no bonus) and horse (+4%). The catalog has no per-creature horsemanship rows for the first two, and both are exotic mounts, so they resolve to the one Horsemanship: Exotic Animals row at the demon hound''s +16% - the higher and the one he actually rides. Horsemanship: horse is Horsemanship: General. Recorded so the collapse reads as deliberate. || W.P. spear/pole-arm has no catalog row. Rather than invent one, both non-sword W.P. slots are of choice and the book''s wording is in the note. || The +6 to save vs mind control (rider) is conditional on the hound being present, so it is in side_effects rather than in bonuses, which are applied unconditionally. || Money: no starting_money. Body armor is the standard 75 M.D.C. plate, which is described rather than issued because the catalog has no Wormwood plate row and the book gives it no price. || The DEMON HOUND ITSELF is not imported. p.157 names demon hounds among the things that are NOT available as player characters, and the book says outright that the animal cannot be a player character - it may be a pet or riding animal. Its stats are on p.124-125. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is what made the race importable at all, so the numbers are recorded here rather than lost: Demon Goblin, Demon Hound Rider, Ram-Rat & Sky Rider: 0 / 1,971 / 3,941 / 7,881 / 14,881 / 21,881 / 31,881 / 41,221 / 54,441 / 74,661 / 104,881 / 139,221 / 189,441 / 239,661 / 289,881. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone - the same delegation the Norse Giant records."
---

## Lore

The demon hound riders call themselves br''talb. They are carnivorous predators
who hunt other animals for food and clothing, and the kr''talpa demon hounds are
meat-eaters preying on the same animals and hunted by the same predators - the
skelter bat, the feathered serpent and the sky riders. Together, hound and
humanoid are better able to protect and feed themselves, and out of that grew a
powerful psychic bond.

Except for hounds left at home with the family, a rider and his animals are
seldom separated. They live, sleep, hunt, eat and play together, often sharing
the meat from the same kill, and are rarely more than a hundred yards apart. The
relationship is more like lifelong companions than master and pet. If a rider is
slain there is an 80% chance one or more of his hounds will hunt down the killer;
if his animal is murdered or tortured, the rider - or his son, daughter or wife -
is almost certain to seek revenge.

Under the frightful insect-like mask of their traditional armor, the br''talb
resemble humans with canine teeth, pale grey skin and long silver or white hair.
They stand seven to eight feet tall, with two large thick fingers and an
opposable thumb, and three large toes. They are gentle and compassionate among
their own kind and tend to view every other life form as a potential enemy or
prey - which makes them an unforgiving and brutal enemy. Many on Wormwood have
grown more accepting of other life, with the permanent exception of the sky
riders, the skelter bats and the feathered serpents.

## GM Notes

**They are one of the few races the Unholy lets wander.** Hound riders may be
played as characters unallied with the Forces of Darkness - comparatively free
agents, adventurers and mercenaries. Unallied ones are viewed with great
suspicion by other riders and with extreme prejudice by sky riders. Anyone
suspected of acting against the Forces of Darkness will be captured and given the
chance to join the Unholy or die; anyone recognized as a Champion of Light or a
sympathizer is hunted down and slain, usually by sky riders on their winged
animals.

Allegiances run about 35% sworn to the Unholy, 15% to the Champions of Light, and
50% independent mercenaries working for whoever pays best, or unallied
adventurers. NPC villains average 1D4+2 level as warrior-scouts.

The br''talb like large blades, spears and lances. Magic weapons, vibro-blades,
energy swords, lances and the bow were all new to them on Wormwood and they like
them very much; the few who have met energy rifles are fond of laser pulse
rifles.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'demon-hound-rider');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'demon-hound-rider';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-demon-hound-rider-class.sql');
