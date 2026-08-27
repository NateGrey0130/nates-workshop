-- The Holy Terror R.C.C., Rifts Dimension Book 1: Wormwood p.66-68.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-holy-terror-class.sql
--
-- IT IS AN R.C.C., AND THE PAGE IT SITS ON IS NOT THE AUTHORITY FOR THAT. The
-- Contents files the holy terror under Champions of Light and the book prints
-- it between two O.C.C.s, in the middle of the occupation section. But its stat
-- block on printed 67 is headed "R.C.C. Skills" and printed 157 groups its XP
-- ladder with the morphworm and the rumbler. Two structural signals against one
-- editorial one.
--
-- Its nine spells are CORE RIFTS INVOCATIONS, not Wormwood prayers, and all
-- nine already existed. "Invisibility (superior/others)" resolves to
-- Invisibility (Superior) and "Swim as the fish (self or others)" to
-- Swim as a Fish (Superior) - the catalog holds a lesser form of each, and the
-- book's self-or-others wording is what picks the superior.
--
-- It carries NO EQUIPMENT AT ALL. Standard Equipment is the single word
-- "None!" - the book calls it a self contained fighting machine - and Weapons
-- and Armor are None as well, so equipment_starting is absent rather than an
-- empty list.
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
SELECT 'holy-terror', 'Holy Terror', 'rifts', '---
id: holy-terror
name: Holy Terror
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.66-68
category: rcc
attribute_dice:
  IQ: "2d6+8"
  ME: "3d6+6"
  MA: "3d6+6"
  PS: "50"
  PP: "2d6+10"
  PB: "2d6+4"
  Spd: "2d4x10"
mdc_base: "2d4x100+200"
ppe_base: "1d4x100, plus 20 per level of experience"
bonuses:
  combat: { attacks_base: 3, initiative: 2, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 5, spell_magic: 4, psionics: 4 }
  at_level:
    - { level: 4, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 11, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 80, per_level: 0, note: "The book prints this as Language: American (80%)." }
    - { name: "Language: Demongogian", base: 80, per_level: 5, note: "80%" }
    - { name: "Language: Gobblely", base: 60, per_level: 5, note: "60%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Basic Math" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Sword" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: Two of choice" }
    - { name: "Hand to Hand: Expert" }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications" }
      - { name: "Espionage" }
      - { name: "Horsemanship", only: ["Horsemanship: General"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", only: ["Boat: Motor, Race & Hydrofoil", "Boat: Paddle Types/Canoe/Kayak", "Boat: Sail Type", "Boat: Ships", "Boat: Submersibles"] }
      - { name: "Rogue" }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
psionics:
  type: "minor"
  isp_base: "3d4x10"
  powers: ["Sense Evil", "Sense Magic", "Telepathy", "Mind Block"]
magic:
  type: "spell"
  spells: ["Call Lightning", "Fire Ball", "Magic Net", "Energy Disruption", "Turn Dead", "Invisibility (Superior)", "Chameleon", "Swim as a Fish (Superior)", "Heal Wounds"]
natural_abilities:
  - { name: "See the Invisible", description: "Without limitation." }
  - { name: "Nightvision", description: "1000 feet (305 m)." }
  - { name: "Double in Size at Will", description: "From 10 feet (3 m) to 20 feet (6 m), in an instant. Weight triples to 21 tons. Speed is the same at both sizes. Useful for fighting giants, evoking fear, leverage or a vantage point." }
  - { name: "Turn Invisible at Will", description: "Without limitation." }
  - { name: "Lightning Bolt", description: "Fired from the palms of both hands. 1D6x10 M.D., range 2000 feet (610 m), +2 to strike. Each bolt counts as one melee action." }
  - { name: "Laser-like Beams", description: "Fired from the eyes. 5D6 M.D., range 4000 feet (1200 m), +3 to strike. Each blast counts as one melee action." }
  - { name: "Fire Silver Spikes", description: "One to four silver spikes fired from the hands and shoulders. 2D6 M.D. to mortal creatures, 4D6 M.D. to supernatural monsters, range 600 feet (183 m), +3 to strike. Full payload is six on each shoulder and one on each finger, sixteen in all, regenerated within 24 hours." }
  - { name: "Breathe Toxic Cloud", description: "Once per melee round, as one ADDITIONAL attack. The cloud is 20 feet (6 m) across and 20 feet tall and affects everybody inside it. Three types. (1) CLOUD OF SLEEP, equal to a fifth level magic sleep spell. (2) BLINDING MIST - a pea-soup mist; those outside cannot see anybody inside and those inside can barely see past their nose. Fighting is impossible, speed and melee actions are halved, and there is a 70% chance of tripping and losing an action for every four feet (1.2 m) travelled. One melee round per level. (3) TOXIC CLOUD - 6D6 M.D. to most life forms, 1D6x10 M.D. to supernatural monsters and creatures of magic, plus choking and stomach pain that costs one melee action and halves combat bonuses. Damage lands twice per melee round while trapped inside; running out stops it instantly with no further damage. One melee round per level." }
  - { name: "Bio-Regeneration", description: "2D4x10 M.D.C. once every other melee round (30 seconds), and lost limbs regrow within 48 hours - the head not included." }
  - { name: "M.D.C. by Location", description: "Main body 2D4x100+200. Head 25% of the main body; arms and legs 25% each; hands 10% each. Depleting the main body destroys the creature." }
  - { name: "Supernatural Strength", description: "P.S. 50, supernatural. Restrained punch 1D6x10 S.D.C.; full strength punch or kick 6D6 M.D., plus 6 from the claws; power punch 2D4x10 M.D., counting as two attacks; judo style body throw 2D6 M.D. When 20 feet tall: stomp 1D6 M.D., crush or squeeze 2D6 M.D. with a 01-45% chance of pinning an opponent 11 feet (3.3 m) or smaller." }
  - { name: "Leap", description: "40 feet (12 m) high or lengthwise, plus 15 feet (4.6 m) from a running start. Holy terrors CANNOT FLY under their own power." }
restrictions: ["Impervious to supernatural possession", "Cannot use any type of symbiotic organism", "Cannot learn to commune with Wormwood magic", "New spells cannot be learned", "Cybernetics and bionics cannot be used"]
side_effects: "Rune weapons and fire inflict DOUBLE damage. The nine magic spells can each be performed twice per 24 hours at a spell strength equal to the character''s level, and no others can ever be learned."
extraction_notes: "IT IS AN R.C.C., NOT AN O.C.C., AND THE PAGE IT SITS ON IS NOT THE AUTHORITY FOR THAT. The Contents files the holy terror under Champions of Light and the book prints it between two O.C.C.s, but its stat block on p.67 is headed R.C.C. Skills and p.157 groups its XP ladder with the morphworm and the rumbler. Two structural signals against one editorial one. || THIS R.C.C. DOES GRANT RELATED AND SECONDARY SKILLS, and that is not a mistake. The rule is that they come from the O.C.C. and that an R.C.C. granting zero is correct, not missing - but this book prints eight related and four secondary on p.67-68, so they are transcribed. The rule guards against inventing them, not against reading them. || Money: Not applicable; no starting_money. Standard Equipment is the word None! - the book calls it a self contained fighting machine - and Weapons and Armor are None as well, so equipment_starting is absent rather than empty. || P.E. is Not applicable in the book and is therefore not in attribute_dice. P.S. is a FIXED 50 and supernatural, which attribute_dice stores as the string 50 rather than as a die; the sheet does not model supernatural P.S. || 3D4x10 I.S.P. and minor psionic, with powers limited to the four named - so powers_starting is absent and the four are granted outright. || The nine spells are CORE RIFTS INVOCATIONS, not Wormwood prayers, and all nine already existed. Invisibility (superior/others) resolves to Invisibility (Superior) and Swim as the fish (self or others) to Swim as a Fish (Superior); the catalog holds a lesser form of each and the book''s self-or-others wording is what picks the superior. || An estimated 4000 arrived on Wormwood and about 30% have died fighting; the survivors carry on. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is what made the race importable at all, so the numbers are recorded here rather than lost: Morphworm, Rumbler & Holy Terror: 0 / 2,901 / 4,801 / 9,601 / 19,201 / 29,201 / 49,001 / 79,001 / 119,001 / 169,001 / 230,001 / 300,001 / 380,001 / 470,001 / 600,001. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone - the same delegation the Norse Giant records."
---

## Lore

Holy terrors are dedicated monster hunters who have always fought on the side of
good, and they still frighten most humans. The fear is partly their inhuman
appearance and their magic, and partly that they are a complete enigma: nobody
knows who or what they really are. They NEVER take off their armor. Many
techno-wizards suspect they are some sort of magic robot and may not even be
alive; another theory is that they are a merging of man, machine and magic, and
were human once.

They first appeared 55 years ago, when a shifter at Demroggan opened a
dimensional rift and made contact with them. The creatures immediately
recognized the minions of darkness and sympathized with the humans, and within
minutes an army was sent to crush the demonic forces. The Unholy and his minions
managed to fight them and close the rift, and the shifter responsible was slain
in combat - but several thousand holy terrors came through before it closed.
They know nothing about dimensional travel, so those on Wormwood have no way
home and those at home have no way of finding Wormwood.

What looks like artificial armor is part of the being; its ornamentation and
color vary from one terror to another, denoting individuality. Many have adopted
American sounding names - often a dangerous-sounding combat name like Brok the
Destroyer, and just as often something common or silly for their human
companions: Bob, Sam, Hank, Ernie, Slim, Chubby. They may look like a giant suit
of walking plate armor, but they are not robots and show the full range of human
emotions. If anything they are more polite, more patient and more respectful of
life than the humans they fight beside.

## GM Notes

Player characters should start at first or second level. The average non-player
holy terror is 1D4+2 level, and only 20% are 7th to 10th.

Money: not applicable, and this one has nothing to spend it on. It carries no
equipment at all - no armor, no weapons to start - and relies on its own
formidable powers, though over the years it may add a few magic or high-tech
weapons. It is on the low end of the social scale among average citizens and
highly regarded by knights, monks, apoks and freelancers.

**Alignment is the tell that this is a good-aligned monster.** 45% principled,
40% scrupulous, 10% unprincipled, and only 5% anarchist - there is no evil holy
terror. Play the enigma: it cannot be corrupted, it cannot use symbiotes, it
cannot learn Wormwood''s magic, and nobody including the terror will tell you
what is under the armor.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'holy-terror');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'holy-terror';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-holy-terror-class.sql');
