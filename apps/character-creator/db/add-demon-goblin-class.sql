-- The Demon Goblin R.C.C., Rifts Dimension Book 1: Wormwood p.122-124.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-demon-goblin-class.sql
--
-- THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin, thief and spy - and
-- the app cannot grant skills conditionally on a choice made at creation. The
-- eight skills all three share are granted AT THEIR CATALOG BASE, because each
-- profession prints a different bonus on them (prowl +10/+5/+10, climbing
-- +10/+5/+5, land navigation +10/+5/+10, streetwise +4/+6/+8) and there is no
-- honest single number. Each profession's full list and exact percentages live
-- on its own ability. Same compromise the Monk's Areas of Mastery took in #354.
--
-- The one part of the choice that IS modelled: the assassin's fourth attack,
-- as a flat +1 on the Assassin ability against the class's attacks_base of 3.
--
-- p.122 opens with the tail of the BEAST GUARD TYPE ONE and then the whole of
-- TYPE TWO, both of which p.157 names as NPC-only. The demon goblin starts at
-- the foot of p.122. p.124 closes it and then starts the DEMON HOUND animal,
-- also NPC-only. Neither neighbour is imported.
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
SELECT 'demon-goblin', 'Demon Goblin', 'rifts', '---
id: demon-goblin
name: Demon Goblin
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.122-124
category: rcc
attribute_dice:
  IQ: "3d4+4"
  ME: "2d6+8"
  MA: "2d6"
  PS: "3d6+10"
  PP: "2d6+13"
  PE: "2d6+13"
  PB: "2d4"
  Spd: "3d6"
mdc_base: "6d6x2"
ppe_base: "3d6"
bonuses:
  combat: { attacks_base: 3, initiative: 1, strike: 3, parry: 2, dodge: 2, roll: 2, pull_punch: 2 }
  saves: { spell_magic: 1, toxins_poisons: 2, disease: 2, horror_factor: 4 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 94, per_level: 5, note: "94%" }
    - { name: "Language: Gobblely", base: 94, per_level: 5, note: "94%" }
    - { name: "Language: Dragonese", base: 55, per_level: 5, note: "55% for an assassin, 50% for a thief, 70% for a spy - the assassin''s figure is stored and the other two are on their own abilities." }
    - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American, at 55% for an assassin, 50% for a thief and 70% for a spy." }
    - { name: "Land Navigation", base: 36, per_level: 4, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Prowl", base: 25, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Palming", base: 20, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Climbing", base: 40, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Streetwise", base: 20, per_level: 4, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "W.P. Knife" }
natural_abilities:
  - { name: "Nightvision", description: "400 feet (122 m)." }
  - { name: "See the Invisible", description: "At will." }
  - { name: "Resistant to Fire and Cold", description: "Normal fire and cold do half damage; MAGIC fire does full damage." }
  - { name: "Dig Tunnels / Mining", description: "70%." }
  - { name: "Exceptional Balance", description: "70%. Walk tightrope or high wire 60%, back flip 60%, climb rope 60%." }
  - { name: "Leap", description: "6 feet (1.8 m) high or lengthwise, plus four feet (1.2 m) from a running start." }
  - { name: "Bio-Regeneration", description: "6D6 M.D.C., as often as twice an hour." }
special_abilities:
  - choose: 1
    from: ["Assassin", "Thief", "Spy"]
    note: "Every demon goblin is trained as one of the three. It sets the rest of the skill list and, for the assassin, an extra attack."
  - name: "Assassin"
    description: "Four attacks per melee round rather than three. Skills: Wilderness Survival, Land Navigation (+10%), Prowl (+10%), Palming, Streetwise (+4%), Climbing (+10%), Swimming, Tracking (people) (+10%), Sniper (+2 to strike on an aimed shot), W.P. Knife, W.P. Sword, W.P. Targeting (throwing knife, sling, short bow), one modern W.P. of choice and one W.P. from any category. Speaks Demongogian and Gobblely at 94%, Dragonese and American at 55%. Only a small percentage can read and write. Special bonus: +5% on all acrobatic skills. 50% carry a gun or energy weapon and 30% a magic item."
    bonuses: { combat: { attacks: 1 } }
  - name: "Thief"
    description: "Three attacks per melee round. Skills: Dance, Mathematics: Basic (+10%), Wilderness Survival, Land Navigation (+5%), Prowl (+5%), Concealment (+10%), Palming (+10%), Pick Locks (+10%), Pick Pockets (+10%), Climbing (+5%), Streetwise (+6%), Swimming (+5%), W.P. Knife, W.P. Sword and one W.P. of choice including modern weapons. Speaks Demongogian and Gobblely at 94%, Dragonese and American at 50%. Only a small percentage can read and write. 20% carry a gun or energy weapon and another 20% a magic item."
  - name: "Spy"
    description: "Three attacks per melee round. Skills: Escape Artist (+10%), Intelligence (+10%), Art (+5%), Mathematics: Basic (+20%), Land Navigation (+10%), Prowl (+10%), Concealment (+5%), Palming (+5%), Pick Locks (+5%), Climbing (+5%), Streetwise (+8%), W.P. Knife and two W.P.s of choice from any category. Speaks Demongogian and Gobblely at 94%, Dragonese and American at 70%, plus one additional language of choice. Only a small percentage can read and write. 20% carry a gun or energy weapon and another 20% a magic item."
  - name: "Cannibal"
    description: "All demon goblins are cannibals who feed on the flesh of their own kind as well as their enemies."
restrictions: ["No psionic powers", "No magic knowledge", "A player character must be an unprincipled or anarchist alignment", "Wears no body armor - a mega-damage creature - but may use a small shield"]
side_effects: "Their eyes are sensitive to bright light: distracting and painful, they must squint, and ALL COMBAT BONUSES ARE REDUCED BY HALF. Damage: bite 1D4 M.D.; punches and kicks come off the supernatural P.S. Both P.S. and P.E. are supernatural, which the sheet does not model."
extraction_notes: "THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin, thief and spy - AND THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE. The eight skills all three share are granted outright AT THEIR CATALOG BASE, because each profession prints a different bonus on them (prowl +10/+5/+10, climbing +10/+5/+5, land navigation +10/+5/+10, streetwise +4/+6/+8) and there is no honest single number. Each profession''s full list and exact percentages are on its own ability, to be applied by hand. Same compromise as the Monk''s Areas of Mastery in #354, and it is a decision rather than an omission. || The one part of the choice that IS modelled: the assassin''s fourth attack, as a flat combat bonus on the Assassin ability against the class''s attacks_base of 3. || Related and secondary skills: NONE, and that is correct rather than missing. This is an R.C.C.; they come from the O.C.C. The holy terror in this same PR does print them, which is why this is worth saying out loud - the book does both. || Money: no starting_money. p.124 gives weapons by preference and probability rather than as a list, and body armor is None. || A PLAYER CHARACTER IS A RENEGADE. The book is explicit that demon goblins are NPC villains and that a player character must be considered a traitor, hated by other demon goblins, with capture leading to torture and death or a life chained to a life force battery. p.157 gives them an XP ladder, which is what makes them importable at all. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is what made the race importable at all, so the numbers are recorded here rather than lost: Demon Goblin, Demon Hound Rider, Ram-Rat & Sky Rider: 0 / 1,971 / 3,941 / 7,881 / 14,881 / 21,881 / 31,881 / 41,221 / 54,441 / 74,661 / 104,881 / 139,221 / 189,441 / 239,661 / 289,881. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone - the same delegation the Norse Giant records."
---

## Lore

Demon goblins may be a distant cousin of the goblin faerie folk known on the
Palladium World and Rifts Earth, but they are supernatural beings and far more
powerful, organized and cruel than their Earthbound relatives. These tiny
war-like people delight in torture and murder. Most are trained assassins or
thieves. All are cannibals who feed on the flesh of their own kind as well as
their enemies. They are vicious killers who love their work.

The typical demon goblin stands three feet tall, with white skin and no body
hair except on the top of the head - jet black, worn as a long mane in a pony
tail or shaped into a mohawk. The mouth is large and filled with pointed teeth,
the eyes pale yellow and ringed with dark shadows, and there is no obvious nose.
They tattoo themselves heavily and seldom wear more than a loincloth. For their
size they are very strong and quick, many are skilled acrobats, and all move
with amazing stealth.

## GM Notes

**They serve Salome, not the Unholy.** Demon goblins may work with the Forces of
Darkness, but they are the loyal minions of Salome, who is adored as a goddess
and their queen. Most are so loyal that they will defy the Unholy without
hesitation if she commands it, most will die to protect her, and 3D4 are always
in the shadows nearby. She won their eternal gratitude by freeing them from the
rule of a cruel alien intelligence. About half a billion are under her command,
though most remain on their homeworld in another dimension; roughly three million
have been brought to Wormwood and 80% of those are completely hers.

A player character starts at first or second level and must be a renegade: an
unprincipled or anarchist alignment, hated by his own kind, especially if he is
no longer loyal to Salome. Capture leads to torture and death, or to a dismal
life chained to a life force battery. Some renegades who keep good company can
raise their alignment to scrupulous or principled.

Experience levels among NPCs run 45% second, 20% fourth, 20% sixth and 15% eighth
or higher.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'demon-goblin');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'demon-goblin';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-demon-goblin-class.sql');
