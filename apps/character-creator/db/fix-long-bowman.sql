-- Long Bowman O.C.C. corrected against Palladium Fantasy RPG 2nd Ed. p.83-85.
--
-- The stored definition was largely invented. Six of eight fields were wrong:
-- the attribute requirements (P.P. 10 / P.E. 10 for P.S. 10 / P.P. 12), the
-- O.C.C. skill list (only Wilderness Survival and W.P. Archery survive, and
-- Wilderness Survival was missing its +10%), the related-skill categories
-- (5 of 12) and their level schedule, the S.D.C. formula (a flat 20 where p.18
-- has men of arms roll 3d6), and the level progression (invented "aimed shot"
-- grants where the book gives a rate-of-fire table).
--
-- Two catalog skills the class needs did not exist. Created as stubs first,
-- shaped like every other W.P. and language row.
--
-- NOT fixed: the starting equipment. The book lists some seventeen items and
-- the gear catalog holds four Palladium rows, so most of it has nothing to
-- reference. Recorded in the class's GM Notes rather than faked.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source)
VALUES ('W.P. Targeting', 'Weapon Proficiencies', 0, 0, 'palladium-fantasy-core');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source)
VALUES ('Language: Native Tongue', 'Technical', 98, 0, 'palladium-fantasy-core');

-- Guarded on the wrong content still being present, so re-running is a no-op
-- and a row someone has already corrected by hand is left alone.
UPDATE imported_classes
   SET markdown = '---
id: long-bowman
name: Long Bowman
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements:
  PS: 10
  PP: 12
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "3d6"
ppe_base: "2d6"
starting_money: 170
skills:
  occ_skills:
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], base: 60, per_level: 5 }
    - { name: "Sniper", base: 0, per_level: 0 }
    - { name: "Wilderness Survival", base: 40, per_level: 5 }
    - { name: "W.P. Archery", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"] }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0 }
  occ_related_skills:
    count: 8
    categories: ["Communications", "Domestic", "Espionage", "Horsemanship", "Medical", "Military", "Physical", "Rogue", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
      - { level: 13, count: 2 }
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "long-bow", qty: 1 }
  - { item_id: "arrows-standard", qty: 32 }
  - { item_id: "leather-armor", qty: 1 }
  - { item_id: "short-sword", qty: 1 }
level_progression:
  - level: 2
    grants: ["+1 shot per melee with a long bow"]
  - level: 3
    grants: ["+1 shot per melee with a long bow"]
  - level: 4
    grants: ["+1 shot per melee with a long bow"]
  - level: 5
    grants: ["+1 shot per melee with a long bow"]
  - level: 6
    grants: ["+1 shot per melee with a long bow"]
  - level: 8
    grants: ["+1 shot per melee with a long bow"]
  - level: 10
    grants: ["+1 shot per melee with a long bow"]
  - level: 12
    grants: ["+1 shot per melee with a long bow"]
  - level: 14
    grants: ["+1 shot per melee with a long bow"]
special_abilities:
  - "Superior Bowmanship: uses a long bow without penalty from horseback, a moving vehicle or an awkward position. Archers who are not long bowmen lose all bonuses to strike and halve their rate of fire in those situations."
  - "Rate of Fire: two shots at level one, +1 at levels 2, 3, 4, 5, 6, 8, 10, 12 and 14. Use these in place of the W.P. Archery numbers when using a long bow; do not combine them. W.P. Archery''s rate of fire still applies to all other bows."
  - "Superior Range: 700 feet (213 m) with a long bow, +25 feet (7.6 m) per level of experience."
  - "Special Aimed Shot: +3 to strike, but uses two melee attacks or two shots from a bow. The player must call the shot."
  - "Dodge and Parry Arrows: may try to dodge or parry arrows, crossbow bolts, thrown spears and similar projectiles at only -3, where anyone else is -10. Does not apply to energy blasts, magic fire balls, lightning, eye beams or dragon breath."
restrictions:
  - "W.P. bonuses to strike are halved when using a short bow, a crossbow, or a bow of terrible quality. The long bow is this character''s specialty."
  - "Wearing a full suit of plate, scale, splint or double mail reduces the rate of fire by two and halves the bonus to strike. The usual prowl and movement penalties also apply."
---

## Lore

Masters of the great war bow, Long Bowmen are the backbone of any serious
army in the Palladium world and prized mercenaries besides. The long bow is not
a common weapon and requires special training to master; those who do become
some of the deadliest long-distance fighters in the world, with nearly double
the range of a short bow and twice the damage.

Long bowmen command two to three times the normal mercenary salary when hired
by the military, and can often get twice that again at seventh level or higher.
Exceptional marksmen can dictate the terms of enlistment, special bonuses, or a
percentage of the booty.

## GM Notes

Rate of fire replaces the W.P. Archery numbers for a long bow rather than adding
to them. It still adds up fast at high level, so check ammunition bookkeeping;
arrows are cheap but not infinite in the wilderness.

Starting equipment is incomplete: the book also gives two sets of clothing, a
hooded cape or cloak, boots, gloves, belt, bedroll, backpack, one large and two
small sacks, a quiver, a sharpening stone, a water skin and a tinder box, plus a
knife and one other weapon of choice. Those rows do not exist in the gear
catalog yet, which holds only four Palladium items. Armor should be studded
leather (A.R. 13, 38 S.D.C.); the leather armor listed is a stand-in.
',
       updated_at = datetime('now')
 WHERE class_id = 'long-bowman'
   AND markdown LIKE '%Track & Trap Animals%';
