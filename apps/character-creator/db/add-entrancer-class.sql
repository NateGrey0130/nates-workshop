-- The Entrancer R.C.C., Rifts Dimension Book 1: Wormwood p.126-127.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-entrancer-class.sql
--
-- THE PAGE RANGE IS 126-127, NOT THE SURVEY'S 126-129. The entrancer's stat
-- block ends on printed 127 at Alliances & Allies. Printed 128 and the top of
-- 129 are the FEATHERED SERPENT, which p.157 names among the creatures that are
-- NOT available as player characters. Citing 126-129 would have pointed a third
-- of this class's window at a creature that is deliberately not imported, and
-- source-coverage would have called it traceable.
--
-- THE SPELLS ARE CORE RIFTS INVOCATIONS, NOT WORMWOOD PRAYERS. All eleven named
-- already existed and not one of the 37 prayers appears among them. This is the
-- only class in the book whose magic comes off the Rifts list rather than the
-- Cathedral's - so this file does NOT depend on #352, and #356 did not depend
-- on #354.
--
-- The 1D4 additional spells from each of levels one through four are stored as
-- spells_starting 10, the average of 4D4, with spell_levels_allowed [1,2,3,4]
-- carrying the gate that actually bounds the selection.
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
SELECT 'entrancer', 'Entrancer', 'rifts', '---
id: entrancer
name: Entrancer
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.126-127
category: rcc
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6+7"
  MA: "3d6"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "1d6"
  Spd: "5d6"
mdc_base: "1d4x100"
ppe_base: "3d6x10"
bonuses:
  combat: { attacks_base: 3, initiative: 2, strike: 1, parry: 1, dodge: 1, roll: 2, pull_punch: 2 }
  saves: { horror_factor: 7, psionics: 2, mind_control: 4, illusionary_magic: 4 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Dragonese", base: 98, per_level: 5, note: "98%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints basic and advanced math" }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 50, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: Faeries & Creatures of Magic", base: 35, per_level: 5, note: "+10%; the book prints lore: faerie" }
    - { name: "Anthropology", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Science", "Technical"], bonus: 10, note: "Two science or technical skills of choice (+10%)." }
    - { choose: 2, categories: ["Pilot"], note: "Two piloting skills of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice, including modern weapons." }
    - { choose: 2, categories: ["Rogue"], note: "Two rogue skills of choice." }
psionics:
  type: "master"
  isp_base: "1d4x100"
  powers: ["Mind Block Auto-Defense", "Bio-Manipulation (the evil eye)", "Empathic Transmission", "Hypnotic Suggestion", "Mind Bond", "Mind Wipe"]
  powers_starting: 2
  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
magic:
  type: "spell"
  spells: ["Befuddle", "Fear", "Calling", "Compulsion", "Domination", "Trance", "Memory Bank", "Horrific Illusion", "Multiple Image", "Mask of Deceit", "Tongues"]
  spells_starting: 10
  spell_levels_allowed: [1, 2, 3, 4]
natural_abilities:
  - { name: "Exceptional Vision", description: "Sees into the infrared and ultraviolet spectrum of light, sees the invisible, and has nightvision to 90 feet (27.4 m). The single eye is about the size of a softball and sits in the middle of the forehead." }
  - { name: "Bio-Regeneration", description: "4D6 M.D.C. per minute." }
  - { name: "Dimensional Teleport", description: "64%." }
  - { name: "Body Armor", description: "Standard armor - chain or a half suit - adds 40 M.D.C.; full plate adds 100, which the entrancer seldom wears. It can wear any human armor." }
special_abilities:
  - name: "Psychic Vampire"
    description: "The entrancer FEEDS ON THE EMOTIONS OF OTHERS, and the stronger the emotion the more delectable. Feeding on strong emotion sometimes backfires (01-50%), and so do moments of great stress (01-60%): the character comes to believe the powerful emotions of others are his own and reacts on pure emotion against his better judgement. Roll percentile, and note that only one or two of the responses may fit the situation - G.M.''s discretion. 01-20 INTENSE ANGER: strikes more savagely, +1 to strike and +3 M.D., but far more likely to be careless, hurt a bystander, fight when he should retreat or start a brawl; 2D4 melee rounds. 21-30 DESPAIR: so laden with sorrow he can barely move, tears from his eye and whimpering from his mouth; half the melee actions, -2 initiative, -25% skills; 3D4 melee rounds. 31-50 FEAR: nervous, confused, on edge; +4 initiative when dodging or running away, +2 to dodge, +1 to roll with punch or impact, but -1 melee attack, -1 to strike and parry and -10% on all skills; 3D4 melee rounds. 51-65 FRUSTRATION: +1 to strike and +2 M.D., given to fits of rage - screaming, swearing, spitting, smashing things - at -1 initiative and -15% skills; 3D4 melee rounds. 66-80 HATE: a berserker rage, no mercy to enemies, and he will push or fight any friend who tries to stop him, or turn to torture and cruelty; made strong by hate at +1 on ALL saving throws, +1 to strike and parry and +6 M.D.; 2D4 melee rounds. 81-00 LOVE AND HAPPINESS: swept with joy, compassion, mercy and kindness and responds in kind; +10% on healing skills and +5% on all others; 3D4 melee rounds."
  - name: "Illusion and Mind Control"
    description: "The entrancer''s two defining powers, and the reason humans fear even the noble ones. Three attacks per melee round by hand to hand or psionics, or TWO by magic."
restrictions: ["No I.S.P. is granted for the psychic vampirism - it is a natural function, not a power", "Communicates with others by magic or telepathy rather than by speech"]
side_effects: "-2 to save vs empathy and empathic transmission, which is the other edge of feeding on emotion. Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 1D4x1000."
extraction_notes: "THE PAGE RANGE IS 126-127, NOT THE SURVEY''S 126-129. The entrancer''s stat block ends on printed 127 with Alliances & Allies; printed 128 and the top of 129 are the FEATHERED SERPENT, which p.157 names among the creatures that are NOT available as player characters. Citing 126-129 would have pointed a third of this class''s window at a different creature that is deliberately not imported. || THE SPELLS ARE CORE RIFTS INVOCATIONS, NOT WORMWOOD PRAYERS. All eleven named already existed in the catalog and none of the 37 Wormwood prayers is among them - this is the one class in the whole book whose magic comes from the Rifts list. The 1D4 additional spells from each of levels one through four are stored as spells_starting 10, which is the average of 4D4, with the level gate at 1-4. || Psionics: the book calls it a mind melter with all healing and sensitive abilities plus six named ones and two of choice. Master tier with 1D4x100 I.S.P.; the six named are granted and powers_starting 2 covers the choice. The whole healing and sensitive lists are NOT enumerated here - categories_allowed carries them, which is the mechanism that exists for it. Bio-manipulation resolves to Bio-Manipulation (the evil eye). || Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || The +4 to save vs mind control AND illusions is stored as two saves, mind_control and illusionary_magic, which are both keys the catalog already uses. || Money: no starting_money, and Special vehicle is None to start. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is what made the race importable at all, so the numbers are recorded here rather than lost: Monk & Entrancer: 0 / 2,201 / 4,401 / 8,801 / 17,601 / 24,001 / 35,001 / 50,501 / 72,501 / 98,501 / 140,501 / 200,501 / 250,501 / 300,501 / 400,501. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone - the same delegation the Norse Giant records."
---

## Lore

The entrancer is a supernatural humanoid with the powers of illusion and mind
control. The vast majority are evil, but a small faction - about 10% - have
turned to the ways of good, and many of those have come to Wormwood to champion
the cause of the humans. These renegades are typically unprincipled or scrupulous.
They are despised by their evil brothers and slain whenever encountered.

Humans are afraid of even the most noble and courageous entrancer, largely
because of how it looks. It is human sized, with pale blue skin, yellow
fingernails and teeth, skeletal facial features, a slobbering mouth, a long slimy
tongue, no nose, and one large eye the size of a softball in the middle of its
forehead. The powers of illusion and mind control only add to the fear and the
distrust.

## GM Notes

**One of the few races the Unholy allows to wander.** Entrancers may be played as
enemies of the Forces of Darkness or as unallied mercenaries, moving the planet as
comparatively free agents. Unallied ones are viewed with great suspicion by other
demons, and good entrancers are feared and disliked by most humans - the Knights
of the Cathedral included. Anyone recognized as a Champion of Light or an ally is
hunted down and slain.

Allegiances run about 65% sworn to the Unholy, 10% to the Champions of Light and
25% independent mercenaries or unallied adventurers. NPC villains are mind melters
and wizards: 50% third level, 25% sixth, 20% eighth and 5% tenth or higher. They
live about 500 years.

**Play the emotional backfire.** The psychic vampirism is not a resource the
player spends, it is a liability that fires on a percentile roll at exactly the
wrong moment - and two of its six results, Hate and Intense Anger, make the
entrancer more dangerous to his own party than to the enemy. A good-aligned
entrancer who has just fed is a character actively fighting his own reflexes.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'entrancer');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'entrancer';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-entrancer-class.sql');
