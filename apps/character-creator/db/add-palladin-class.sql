-- The Palladin O.C.C., Palladium Fantasy main book, printed pp.88-89.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-palladin-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-palladin-class.sql
--
-- "Palladin" is the book's own spelling, not a typo for paladin, so it is the
-- id and the display name. Read with scripts/read-columns.py.
--
-- Apply fix-pf-armor-and-cross-system-gear.sql first or alongside: the palladin
-- grants clothing, gloves and a riding horse, three rows tagged rifts-only
-- until that script reclassifies them.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE ONE NEW CATALOG ROW IS NOT A STUB. class-check offered the usual
-- placeholder for Horsemanship: Palladin at base 0. The book prints it:
--
--   Horsemanship: Palladin  "Base Skill: 45%/40% +5% per level"  (printed p53)
--
-- Third of the three horsemanship ranges the book names, above General
-- (35%/20%) and Knight (40%/30%). The second percentile is combat riding,
-- which is what the charge, horse-attack and stay-saddled rolls are made
-- against.
--
-- THREE JUDGEMENT CALLS WORTH THE READING TIME.
--
-- 1. P.P.E. The page grants "+2D6 P.P.E." under O.C.C. bonuses and the main
--    book prints no P.P.E. base for any man of arms. A pool bonus cannot
--    conjure a pool the class does not have - a null base stays null - so
--    written as `bonuses.pools.ppe` the 2D6 would have reached nothing. It is
--    recorded as `ppe_base` instead: the only printed number becomes the base,
--    which is also what the Long Bowman already does.
--
-- 2. Hand to Hand. The book says "Hand to Hand: Martial Arts/Palladin". The
--    catalog has five fighting styles, all with Rifts Ultimate Edition level
--    tables, and no Palladin one. Mapped to Martial Arts with the book's name
--    in the note rather than inventing a sixth table.
--
-- 3. The Way of the Horse, the Way of the Lance and the Demon Death Blow are
--    special_abilities - prose the sheet displays. Their flat numbers (+2 on
--    initiative, +1 to pull punch, the horror factor ladder) are in `bonuses`
--    where they can be added. The mounted bonuses deliberately are NOT: "+2 to
--    parry or dodge while on horseback" applied unconditionally would follow
--    the character on foot.

-- ---- catalog rows this class needs ----------------------------------------
-- No `systems` column: skills are cross-system on purpose (see
-- untag-cross-system.sql), and this row is the third horsemanship range in a
-- family that is already untagged.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Horsemanship: Palladin', 'Horsemanship', 45, 5, 'import',
        'palladium-fantasy-core', '45%/40% - riding/combat riding');

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'palladin', 'Palladin', 'palladium-fantasy', '---
id: palladin
name: Palladin
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 10, PS: 12, PP: 12, PE: 10 }
ppe_base: "2D6"
starting_money: "100"
bonuses:
  combat: { initiative: 2, pull_punch: 1 }
  saves: { horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Dance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Heraldry", base: 45, per_level: 5, note: "+20%" }
    - { name: "Horsemanship: Palladin", base: 45, per_level: 5, note: "45%/40% riding/combat riding" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Literacy", base: 50, per_level: 5, note: "One language of choice, usually native or elf (+20%)" }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "W.P. Lance", base: 0, per_level: 0, note: "The Way of the Lance: the equivalent of W.P. Lance, plus the unseat, disarm and triple-damage rules below." }
    - { name: "W.P. Shield", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three of choice" }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "The book calls it Hand to Hand: Martial Arts/Palladin. Can be changed to Hand to Hand: Assassin (if evil) at no cost." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", note: "+10%; two of the seven must come from here" }
      - { name: "Espionage", note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], note: "+5%" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", note: "+10%" }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Rogue", note: "Evil alignments only." }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], note: "+10%" }
      - { name: "Technical", note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Wilderness Survival", "Track & Trap Animals"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 5, count: 2 }, { level: 10, count: 2 }, { level: 15, count: 2 }]
special_abilities:
  - { name: "The Way of the Horse", description: "Horsemanship: Palladin. The palladin can make jumps, perform tricks and pull off special manoeuvres on horseback even in full plate armour. +1 on initiative mounted, +2 to roll with fall or impact when knocked from a horse, +2 to parry or dodge mounted, +6 to damage mounted. A charge with lance, pole-arm or spear adds 3D6 damage and counts as two melee actions; the rider must roll under the second percentile to stay saddled." }
  - { name: "The Way of the Lance", description: "A natural 19 or 20 with the lance inflicts triple damage instead of double, or unseats the opponent; the player declares which before rolling. An unseated rider takes 1D6 from the lance, is knocked off, and takes another 1D6 unless he rolls with impact, and loses initiative and one action. A grounded opponent is knocked onto his back with no fall damage. The palladin may instead disarm with a called shot, knocking away a weapon, shield, hat or helmet. A modified strike roll of 19 or better also unseats or disarms." }
  - { name: "Demon Death Blow", description: "The palladin focuses his inner spirit against demons, dragons, elementals and other supernatural beings and creatures of magic. The attack ignores the natural A.R. and inflicts full damage plus P.S. bonus, even against creatures normally impervious to ordinary weapons, which take half damage (full with a magic or holy weapon). Vampires and other silver-only creatures also take half, full with silver. The victim cannot bio-regenerate the injury for 1D4 hours. Limits: the character must be pure of spirit and intent, so it cannot be used in anger, fear or for revenge; it counts as two melee attacks; it works only on supernatural beings and creatures of magic, never on armour, structures or mortal S.D.C./hit point creatures; and it cannot be delivered by bow or any projectile weapon. It draws 3D6 P.P.E. and counts as a magical attack." }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cape or cloak", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
  - { choose: 1, label: "armour", qty: 1, from: ["chain-mail", "scale-mail"] }
  - { item_id: "small-shield", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { item_id: "lance", qty: 1 }
  - { choose: 1, label: "sword of choice", qty: 1, from: ["bastard-sword", "broadsword", "claymore", "cutlass", "espandon", "falchion", "flamberge", "long-sword", "sabre", "scimitar", "short-sword"] }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.) or scale mail (A.R. 15, 75 S.D.C.), player choice. Palladins prefer heavy armour, chain through plate, though some favour the lighter types."
  - "Every starting weapon is a basic S.D.C. weapon of very good quality. Any one of them may be of exceptional quality (kobold or dwarven): +1 to strike and parry, or +3 to damage."
  - "The riding horse is of good to excellent quality, probably raised by the palladin, with 30+2D6 S.D.C., 6D6 hit points, running speed 33, and a value of 1D4x1000 gold."
  - "Family background is rolled on the Knight tables."
  - "Like the knight, the palladin has family and holdings in his homeland: 1D4 relatives who will house and feed the character indefinitely, and may provide a new set of clothing, studded leather armour, a sword and 4D6x10 gold."
  - "The Demon Death Blow is shared only with the Monk O.C.C. and requires purity of spirit and intent; a palladin who has fallen to anger, fear or revenge cannot use it."
extraction_notes: "The printed +2D6 P.P.E. is recorded as ppe_base rather than a pool bonus. The Palladium Fantasy main book states no P.P.E. base for men of arms, and a pool bonus cannot conjure a pool the class does not have, so the only printed number becomes the base. Hand to Hand: Martial Arts/Palladin is mapped to the Martial Arts row; no Palladin-specific level table exists in the catalog. The two additional weapons of choice are enumerated as the whole Palladium Fantasy weapon catalog minus the lance, which the class already carries."
---

# Palladin

## Lore

Most palladins are the embodiment of knighthood, meant to represent the highest
values of honour, nobility and chivalric behaviour: the ultimate knight. They
are the greatest fighting men alive, trained to be the quickest and deadliest of
warriors, skilled in several weapons and in martial arts combat, and exquisite
equestrians. Like knights they are often of noble birth and usually highly
educated, though some come from humbler beginnings.

The typical palladin is a knight-errant who scours the world for truly terrible
evil, the most frightful monsters and the most despicable villains. He is
dedicated to destroying evil, protecting the innocent and righting injustice
wherever he finds it, and he leads by example, upholding the Code of Chivalry
above all else. Most hold a high regard for life and great respect for those who
nurture and protect it. Many accept the monster races, wolfen, ogre, changeling
and the rest, as having a right to live free provided they stay out of criminal
and murderous campaigns, and racists have been left dumbfounded to find a human
or elven palladin defending innocent non-humans.

That acceptance of others earns the palladin the respect of titans, dragons,
godlings and gods of light, and the animosity of the gods of darkness, demons,
deevils, tyrant kings and evildoers.

## Alignment

Any: good, selfish or evil. Most are principled, scrupulous or aberrant, the
last being evil but with a code of honour, and these usually live by the letter
of the Code of Chivalry. Even a good palladin can be self-righteous, arrogant,
snobbish or condescending. Diabolic, miscreant and anarchist palladins are
comparatively uncommon but do exist; treacherous and cruel, with little regard
for life, they disregard the Code and engage in deceit, betrayal, revenge,
torture and murder. They are sometimes called anti-palladins, and even aberrant
palladins view them with contempt and revulsion.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'palladin');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'palladin';
SELECT name, category, base, per_level, systems FROM skills
 WHERE name = 'Horsemanship: Palladin';
-- The new skill row must not be a stub, and must not be tagged to one system.
SELECT count(*) AS new_skill_stubs FROM skills
 WHERE name = 'Horsemanship: Palladin' AND (base = 0 OR systems IS NOT NULL);

INSERT INTO data_script_runs (filename) VALUES ('add-palladin-class.sql');
