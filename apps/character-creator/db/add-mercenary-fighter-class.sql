-- The Mercenary Fighter O.C.C., Palladium Fantasy main book, printed p80.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-mercenary-fighter-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-mercenary-fighter-class.sql
--
-- Read with scripts/read-columns.py. Needs no new catalog rows at all: every
-- skill and item it grants already exists, studded leather included, because
-- fix-pf-armor-and-cross-system-gear.sql added it for the Soldier.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE BOOK CALLS THIS CLASS THREE THINGS. The write-up is headed "Mercenary
-- Warrior O.C.C.", the contents page lists "Mercenary O.C.C.", and the stat
-- block itself says "Mercenary Fighter". The stat block wins, because that is
-- the heading over the numbers being transcribed - and it is also the name the
-- Soldier's own page uses when it talks about hiring them.
--
-- WHY THE PAGE IS AWKWARD TO READ, and where the reader does not save you. The
-- mercenary write-up begins mid-spread under the "Men of Arms" section heading,
-- while the tail of the Druid O.C.C. is still finishing in the neighbouring
-- columns. Reading by geometry does NOT separate them, because both genuinely
-- run down the same columns: a column-order read interleaves the druid's
-- starting equipment, "Armor: soft leather (A.R. 10, S.D.C. 20)" and "Money:
-- 100 in gold" into the middle of the mercenary's prose.
--
-- What settles it is the content, not the layout. Those lines sit beside "most
-- druids will use holy or rune weapons made of iron, although a magic wood,
-- stone or flaming weapon would be preferred", and the mercenary's own stat
-- block on the next page prints a choice of chain or studded leather and 200
-- gold. The stat block itself is contiguous and unambiguous; only the
-- surrounding lore needs reading with an eye on whose it is.
--
-- The single weapon of choice enumerates the whole Palladium Fantasy weapon
-- catalog minus the lance. Equipment choices take item slugs and there is
-- deliberately no `categories` flavour, so a free pick has to be spelled out;
-- the lance comes off because the book restricts it to the Knight and Palladin.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'mercenary-fighter', 'Mercenary Fighter', 'palladium-fantasy', '---
id: mercenary-fighter
name: Mercenary Fighter
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { PS: 7 }
starting_money: "200"
bonuses:
  combat: { pull_punch: 2 }
  saves: { horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb/Scale Walls (+10%); rappelling is a second percentile, 35% +5%." }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Two languages of choice (+10% each)" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Shield", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts, or Assassin if evil, for the cost of one other skill." }
  occ_related_skills:
    count: 10
    categories:
      - { name: "Communications", only: ["Sign Language"], note: "+5%" }
      - "Domestic"
      - { name: "Espionage", note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", note: "+5%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - { name: "Rogue", note: "+4%, on Streetwise only" }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", note: "+10% on language, literacy and lore only" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 5, count: 2 }, { level: 10, count: 2 }, { level: 15, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { choose: 1, label: "armour", qty: 1, from: ["chain-mail", "studded-leather"] }
  - { item_id: "small-shield", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 1, label: "sword of choice", qty: 1, from: ["bastard-sword", "broadsword", "claymore", "cutlass", "espandon", "falchion", "flamberge", "long-sword", "sabre", "scimitar", "short-sword"] }
  - { choose: 1, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.) or studded leather (A.R. 13, 38 S.D.C.), player choice."
  - "Every starting weapon is a basic S.D.C. weapon of good quality. Any one of them may be of exceptional quality (kobold or dwarven): +1 to strike and parry, or +3 to damage."
  - "Most mercenaries own more than one suit: studded leather when stealth and manoeuvrability matter, double mail, scale, splint or plate for heavy combat. Penalties are -15% to prowl and -20% to climb or scale walls in full splint or plate, and -10% in chain, scale, or a half suit."
  - "Pay varies with the employer and the danger, from a handful of gold to 1D6x100 or 1D6x1000 per person for a single mission. Many employers pay little or nothing but let the group keep a percentage of the booty, or all they can carry, provided the job is done. Room and board is often included."
  - "The lance is not on the weapon list: the book limits it to the Knight and Palladin."
extraction_notes: "The write-up heads this class Mercenary Warrior O.C.C. and the contents page calls it Mercenary O.C.C.; the stat block itself says Mercenary Fighter, which is the name used here. The weapon of choice enumerates the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category."
---

# Mercenary Fighter

## Lore

The mercenary warrior is a soldier of fortune and a world adventurer. Most are
rough and tumble fighters without the benefit of noble birth or the expert
training available to a knight or palladin, yet they are often natural born
fighters with an innate talent for combat, great strength and the heart of a
lion. They may not be knights, but many are as noble, honourable and courageous.

All mercenaries make their living by their sword, their fighting ability and
their cunning, and most are independent operators with their own agenda:
destroying evil monsters, avenging the innocent, completing a quest, defending a
homeland, amassing wealth, becoming famous. They travel into uncharted
wilderness, war zones and the domains of monsters, rummage through ancient ruins
for forgotten secrets and treasure, and associate with all manner of beings,
from elf to goblin, fellow warrior to wizard.

The life is not an easy one. Fortune blesses them at one point and abandons them
at another, and when times are tough a mercenary scavenges what booty he can
from the defeated and sells it for whatever he can get. A hungry fighter will
consider jobs he would normally refuse, and may take a hot meal and a warm bed
as payment, especially from the poor who have nothing else to offer. Anarchist
and evil mercenaries turn to crime in those stretches. Even in good times there
are battles whose only reward is knowing they helped somebody.

Traditional mercenaries are soldiers for hire with no roots and no allegiance to
any king, country or cause. When the job is done they are paid and they move on,
so they are constantly in search of conflict and adventure that will pay. Their
employers are typically a king, queen, baron or ruling council, but might be a
knight, a priest, a wealthy merchant, a wizard, or anyone with a cause: rescue a
hostage, retrieve a holy artefact, take revenge, steal, assassinate a rival.

A mercenary sees far more combat than the average soldier, because the character
needs a constant state of war to make a living, which makes him more experienced
and deadlier than a soldier whose time goes on patrols, guard duty and drill.
The cost is that he has few places to call home and few friends beyond his
comrades in arms, and most face countless opponents and terrible danger without
ever finding the fame or fortune they were after. Those who become disillusioned
or bitter turn bandit or smuggler, form their own gang, or hire on as the
henchmen of tyrants, crime lords and evil sorcerers.

Their skills run to combat and self-preservation, and they are jacks of all
trades at the fundamentals of adventuring, often handy at tracking, trapping,
picking pockets and prowling. They seldom deal in subtleties: a locked door gets
kicked in, a man who will not talk gets slapped around, and reading and writing
are considered unimportant on a battlefield.

## GM Notes

Assignments suited to a party of adventurers include a quest, investigating the
ruins of an ancient city or temple, retrieving a valuable or stolen item, a
rescue, searching for a lost person, bodyguard work, defending a caravan,
soldiering in an army, militia and law enforcement, and spy work. Revenge
contracts run from a duel to an all-out war. Robbery, kidnapping and
assassination are on the list too, but only anarchist and evil characters are
likely to take them.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'mercenary-fighter');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'mercenary-fighter';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('chain-mail', 'studded-leather', 'small-shield', 'clothing', 'gloves');

INSERT INTO data_script_runs (filename) VALUES ('add-mercenary-fighter-class.sql');
