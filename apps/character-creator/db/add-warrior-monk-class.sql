-- The Warrior Monk O.C.C., Palladium Fantasy main book, printed pp.71-72.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-warrior-monk-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-warrior-monk-class.sql
--
-- Read with scripts/read-columns.py. Needs no new catalog rows.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE PRINTED HEADING IS "The Warrior Monk O.C.C." where the contents page says
-- "Monk O.C.C." The stat block wins, as it did for the Mercenary Fighter.
--
-- THE ONLY CLASS IN THE BOOK WHOSE FIGHTING STYLE CANNOT BE TRADED. Every other
-- O.C.C. either grants a style and prices an upgrade, or grants none and prices
-- the entry. This one grants Hand to Hand: Martial Arts and says "no
-- substitution allowed" - not up, not down, at no price. Stated in restrictions
-- and on the skill note, because a reader who only sees the granted style has
-- no way to tell it apart from every other class that grants one.
--
-- A MONK IS NOT A PRIEST, and the page is explicit: no spells, no prayers of
-- intervention, none of the priest's healing powers. The P.P.E. is the
-- character's inner spirit rather than magic, and it has exactly one use - the
-- Spirit Strike, 2D6 P.P.E. for TRIPLE damage against dragons, elementals,
-- demons and creatures of magic, and nothing at all against anyone else. So no
-- `magic` block, and the abilities are natural_abilities.
--
-- THE WEAPON LISTS ARE NARROWED BY HAND, which every other class in this book
-- avoided. Elsewhere "one weapon of choice" enumerates the whole Palladium
-- catalog minus the lance, because the book restricts the PROFICIENCY and not
-- the weapon. Here it restricts the weapon: "warrior monks are strictly limited
-- to staves, spears, forks/tridents, blunt weapons, and the bow." Enumerating
-- everything would hand a monk a claymore the page forbids.
--
-- BEGGING IS GRANTED AT THE TEMPLE'S NUMBER, not the catalog's - 20% +3% where
-- the shared row carries 30% +3%. Same call the Noble's Horsemanship: General
-- needed, and for the same reason: the class entry is what the character reads.
--
-- +20 S.D.C. IS A POOL BONUS added to the core 1D6, since the page prints no
-- S.D.C. formula of its own. The +1 to save vs disease has no key in derive.js
-- and stays in prose; illusions, mind control and possession all have keys and
-- are in `bonuses`. Deep Meditation has no catalog row and is an ability.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'warrior-monk', 'Warrior Monk', 'palladium-fantasy', '---
id: warrior-monk
name: Warrior Monk
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { PP: 11, PE: 11 }
ppe_base: "P.E. x3, +1D4 per level of experience"
starting_money: "110"
bonuses:
  pools: { sdc: 20 }
  saves: { possession: 4, illusionary_magic: 1, mind_control: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { name: "Literacy", base: 45, per_level: 5, note: "One language of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Play Musical Instrument", base: 55, per_level: 5, note: "+20%; one instrument of choice" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Begging", base: 20, per_level: 3, note: "A temple skill, granted at the monastery''s 20% +3% rather than the catalog base. Useful as a disguise, or for emergency money." }
    - { name: "Fasting", base: 40, per_level: 3, note: "A temple skill. Two weeks without food given water, and three days without water." }
    - { name: "W.P. Staff", base: 0, per_level: 0 }
    - { name: "W.P. Spear", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "Martial Arts ONLY. No substitution is allowed, up or down." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", note: "+5%" }
      - { name: "Domestic", note: "+15%" }
      - "Espionage"
      - { name: "Medical", note: "+5%" }
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - "Rogue"
      - "Science"
      - { name: "Technical", note: "+10%" }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Blunt", "W.P. Forked", "W.P. Shield", "W.P. Targeting"], note: "Only these five, plus the Staff and Spear the class already grants." }
      - "Wilderness"
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }]
natural_abilities:
  - name: "Stick Fighting"
    description: "The staff is the monk''s stick, carried as a reminder of a humble station; a spear, but never a pole arm, is an acceptable modest enhancement. In addition to the W.P. Staff and W.P. Spear bonuses the monk is +1 to parry at levels four, eight and twelve, and gets ONE EXTRA ATTACK per melee round when using a staff or spear of any kind."
  - name: "Stick Power Strike"
    description: "A thrust with the point of the staff or the blunt end of a spear, aimed at the temple. Inflicts an extra 1D6 damage; the victim loses initiative, loses one melee action, and has a 01-50% chance of dropping a weapon (one weapon only if using a pair, victim''s choice). The player must announce the intention before rolling, and a modified roll of 18 or higher is needed for full effect - anything that hits under 18 misses the mark and does normal damage."
  - name: "Parry Arrows with Staff or Spear"
    description: "The monk may parry arrows, darts and thrown objects at -2, and gunfire at -6. Only one opponent''s projectiles at a time, and the attack must be seen coming."
  - name: "Spirit Strike"
    description: "An attack drawing on the character''s inner spirit, usable ONLY against dragons, elementals, demons and other supernatural beings and creatures of magic. Delivered by punch, kick, staff or spear, it does TRIPLE the character''s normal damage and costs 2D6 P.P.E."
  - name: "Deep Meditation"
    description: "Body motionless without fatigue or pain, mind clear and rested. Recovers I.S.P., P.P.E. and other internal resources three times as fast as normal. Not a substitute for sleep, but the character feels alert and refreshed afterwards, remains subconsciously aware of the surroundings, and can leave the position instantly with no combat penalties."
  - name: "Allegiance to a God"
    description: "The same as the priest of light: the monk serves a god or pantheon and the relationship carries the same obligations."
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { choose: 1, label: "dark hooded travelling robe", qty: 1, from: ["robe-hooded", "robe-heavy", "cape-long-hooded"] }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "sandals", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "holy-symbol", qty: 1 }
  - { item_id: "wooden-spike", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "vial-of-holy-water", qty: "1d6" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "food-rations", qty: "2d4" }
  - { item_id: "soft-leather", qty: 1 }
  - { choose: 1, label: "staff or spear", qty: 1, from: ["long-staff", "short-staff", "quarterstaff", "bo-staff", "iron-staff", "long-spear", "short-spear"] }
  - { choose: 1, label: "dagger or hatchet", qty: 1, from: ["daggers-and-knives", "hand-axe", "axe-throwing"] }
  - { choose: 1, label: "weapon of choice", qty: 1, from: ["long-staff", "short-staff", "quarterstaff", "bo-staff", "iron-staff", "long-spear", "short-spear", "trident", "military-fork", "mace", "war-hammer", "morning-star", "club-stick-pipe", "war-club", "cudgel", "maul", "long-bow", "short-bow", "cross-bow"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.), worn under the robe."
  - "Hand to Hand: Martial Arts ONLY, with no substitution allowed in either direction. This is the only class in the book whose fighting style cannot be traded at any price."
  - "Weapons are strictly limited to staves, spears, forks and tridents, blunt weapons and the bow. The weapon of choice list is narrowed to those, which is why it is shorter than every other class in this book."
  - "The dagger or hatchet is for utility rather than combat, and the monk is not proficient with it."
  - "Horsemanship is not available: a monk walks everywhere, or rides in a wagon."
  - "A monk''s founding monastery supplies clothing, food and a staff. Travelling monks find shelter, food, water, a new robe or sandals and basic facilities at any monastery worshipping the same gods, and often at rival ones; farmers and villagers usually offer the same. Payment is a small donation or general help. Most monks give 40-50% of what they earn to the less fortunate and 25% to their order."
extraction_notes: "The printed heading is The Warrior Monk O.C.C. and the contents page calls it Monk; the stat block wins, as it did for the Mercenary Fighter. Begging is granted at the temple''s printed 20% +3% rather than the catalog''s 30% +3%, the same call the Noble''s Horsemanship: General needed. Deep Meditation has no catalog row and is a natural ability. The +1 to save vs disease is printed and has no save key in derive.js, so it stays in prose; the illusions, mind control and possession bonuses do have keys and are in `bonuses`. The +20 S.D.C. is a pool bonus added to the core 1D6. The weapon lists are narrowed by hand to the five permitted families rather than enumerating the whole catalog, because here the book really is restricting the weapon and not just the proficiency."
---

# Warrior Monk

## Lore

The warrior monk belongs to a monastic order and fights with a stick. That
undersells it: the staff is carried as a reminder of a humble station, and the
monk is better with it than most men of arms are with a sword - an extra attack
every melee round, a temple strike that blacks out an opponent, and the ability
to bat arrows out of the air.

Monks are not priests. The warrior monk cannot cast spells, cannot perform
prayers of intervention, and has none of the priest''s healing powers. The
P.P.E. is not magic; it is the character''s inner spirit, and it goes into one
thing: the Spirit Strike, which does triple damage to dragons, elementals,
demons and creatures of magic and nothing at all to anyone else.

Most monastic orders accept any willing spirit, which is why some temples are
associated with dragons, with giants like the Rahu-Men, and with other
non-humans.

## Alignment

Any, though the book gives a spread: about 25% principled, 25% scrupulous, 15%
anarchist, 15% aberrant and 20% other.

## GM Notes

A monk travels light and cheap, and the order is a standing safety net: any
monastery of the same faith will feed and house one, and so will most rival
ones and most villages. Payment is a donation or an afternoon of work. That
makes a monk the easiest character in the book to keep alive between adventures
and the hardest to make rich - most give away 40-50% of what they earn and
another 25% to the order.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'warrior-monk');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'warrior-monk';
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'ceremonial-robe', 'sandals', 'vial-of-holy-water', 'holy-symbol');
-- Expect 0. The five permitted proficiencies all have to exist, or the `only`
-- list narrows the category to less than the book allows.
SELECT 5 - count(*) AS missing_wp FROM skills
 WHERE name IN ('W.P. Archery', 'W.P. Blunt', 'W.P. Forked', 'W.P. Shield', 'W.P. Targeting');
-- Expect 2. Both temple skills, granted at the monastery's own numbers.
SELECT count(*) AS temple_skills FROM skills WHERE name IN ('Begging', 'Fasting');

INSERT INTO data_script_runs (filename) VALUES ('add-warrior-monk-class.sql');
