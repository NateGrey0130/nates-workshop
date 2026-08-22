-- The Thief O.C.C., Palladium Fantasy main book, printed p94.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-thief-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-thief-class.sql
--
-- Read with scripts/read-columns.py. Apply add-pf-rogue-gear.sql first or
-- alongside: it adds soft leather and the lock picking tools, and makes the
-- grappling hook and small hammer visible to a Palladium campaign.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE THIEF IS A MAN OF ARMS, which is the book's own claim and not an
-- inference: "Thieves (and assassins) are the rogues and cutthroats of the men
-- of arms O.C.C.s." That is what puts it in CORE_SDC_BY_CLASS at 3D6 alongside
-- the Knight and the Soldier, and it is worth stating because a thief does not
-- look like one.
--
-- NO O.C.C. BONUSES ARE PRINTED. Six of the other men of arms grant a pull
-- punch or a horror factor bonus in a labelled block; the thief page has no
-- such block at all. So there is no `bonuses` key, rather than a `bonuses` key
-- full of zeroes - absence is the statement.
--
-- FOUR NAMES AND ONE SIZE THAT RESOLVE TO WHAT IS ALREADY THERE.
--
--   Locate Secret
--     Compartments/Doors -> Locate Secret Compartments. Same skill.
--   Track Humanoids      -> Tracking (people), in the Espionage `except` list.
--                           Excluding a name the catalog does not carry
--                           excludes nothing, which is the Shifter's old bug.
--   Advanced Math        -> Mathematics: Advanced.
--   a medium-sized sack  -> Large sack. The equipment chapter prices exactly
--                           three sacks - small, large and knap - and no
--                           medium. Both the large and the medium resolve to
--                           the large row rather than inventing a size the
--                           book does not sell.
--   iron spikes          -> Wooden Spike. The thief may carry "wooden or iron
--                           spikes" and the book prices only the wooden one.
--
-- Rope is catalogued per 40 feet and the thief carries 50, so the grant is two
-- lengths rather than one short one.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'thief', 'Thief', 'palladium-fantasy', '---
id: thief
name: Thief
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { PP: 9 }
starting_money: "250"
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Pick Locks", base: 45, per_level: 5, note: "+15%" }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Two languages of choice (+10% each)" }
    - { name: "Locate Secret Compartments", base: 35, per_level: 5, note: "+15%. The book calls it Locate Secret Compartments/Doors." }
    - { name: "Streetwise", base: 34, per_level: 4, note: "+14%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 8
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", except: ["Sniper", "Tracking (people)"], note: "Any except Sniper and Track Humanoids. Two of the eight must come from here, and those two get +10%." }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid"] }
      - { name: "Physical", except: ["Gymnastics", "Wrestling"] }
      - { name: "Rogue", note: "+10%" }
      - { name: "Science", only: ["Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cape, cloak or jacket", qty: 1, from: ["cape-long", "cape-long-hooded", "jacket-light", "jacket-leather"] }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 3 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "lock-picking-tools", qty: 1 }
  - { item_id: "rope", qty: 2 }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-hammer", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 2 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty at all, which is why a thief wears them; full splint or plate is -15% to prowl and -20% to climb or scale walls, chain or scale mail -10%, studded leather -5%."
  - "Every starting weapon is a basic S.D.C. weapon of very good quality. Thieves favour small weapons that are easy to conceal. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The cape, cloak or jacket has 1D6+1 inside pockets, with or without a hood."
  - "A thief gets about 10% more by trading stolen goods for weapons and equipment than by selling them for cash. These skills can rarely be sold to the military or to any respectable organisation."
  - "A thieves guild takes 50% of a new member''s first big take and 20% of everything after that. In return, members fence through the guild and buy its services at 25% below street price. Working a guild territory without joining invites a demand for 50-75% of the profit, surveillance, and escalating pressure to join or leave town."
extraction_notes: "Track Humanoids in the Espionage exclusion is the catalog Tracking (people) row, which is where that skill lives. The book gives a medium-sized sack and a large one; the Palladium Fantasy price list has only small, large and knap sacks, so both resolve to the large row rather than inventing a size the book does not price. Rope is catalogued per 40 feet and the thief carries 50, so two lengths. Iron spikes are not priced anywhere in the book, so the wooden spike row covers the option the thief is actually given. No O.C.C. bonuses are printed for this class, so there is no bonuses block."
---

# Thief

## Lore

Thieves, and assassins, are the rogues and cutthroats of the men of arms
O.C.C.s. Unlike the rest, they are skilled in stealth, subterfuge, trickery and
robbery.

The worst of them use bushwhacking tactics, poison and torture, and will slit a
victim''s throat or betray a comrade in a heartbeat; those miscreant brigands are
bandits who engage in blackmail, mugging, kidnapping and murder. The typical
thief is neither a murderer nor a bully. Most are skilled at picking pockets,
picking locks and finding secret compartments in order to steal valuables. Some
are simple robbers and fighters, some masters of disguise and stealth, others
cat-burglars skilled in climbing, prowling and acrobatics. Still others have a
diverse range of talents running to forgery, escape artistry and spying. Those
with a high M.A. or P.B. and a good head become conmen who use cunning, charm
and sweet talk to get into position to deceive, swindle and steal, and to talk
their way back out of trouble.

It is said there is no honour among thieves, but that depends on the individual.
Many selfish and cunning thieves recognise that they need friends and
accomplices, and will not betray one unless they see no other recourse. Most
will still hold out on a partner or skim a little off the top: what they do not
know will not hurt them is a common motto.

In combat the thief is a quick, dirty fighter who strikes fast and below the
belt, and is usually more concerned with escaping than with beating an opponent,
although the strongest and most agile may enjoy a fight as much as any warrior.
Many are adept at moving silently to avoid confrontation and to skulk in the
shadows waiting for the right moment. When they do strike, most prefer to attack
from behind or with surprise, and the clever ones will have a diversion ready:
a fire in the pantry, flash powder, a smoke bomb, a brawl, or a partner causing
a commotion somewhere else.

## Alignment

Thieves are usually anarchist or evil. The nature of the work is such that a
thief cannot be a good alignment, and the best available is unprincipled: a
thief with some degree of conscience, who tries to victimise only the evil,
greedy, cruel and selfish, and who will never steal from friends.

## GM Notes

Joining a thieves guild needs a sponsor, which is easy for the family and
friends of thieves and hard for a newcomer nobody knows and nobody trusts.
Unscrupulous rogues make a living claiming to represent the guild, taking a
small sponsor fee, and leaving the stranger to discover he has no membership at
the worst possible moment.

Non-members can still buy guild services: fencing stolen items, purchasing
stolen goods, acquiring poisons or drugs, buying and exchanging information, and
sometimes forged documents. Many guilds are secretive enough to plead ignorance
and send a stranger away. Guild fencing rates start at 25% of market value for
common items and rise for uncommon ones, and a character gets about 10% more
trading for goods or credit than for cash.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'thief');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'thief';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 6 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'lock-picking-tools', 'grappling-hook',
                'small-hammer', 'purse-satchel', 'boots-soft-leather');
SELECT count(*) AS stub_gear FROM gear
 WHERE slug IN ('soft-leather', 'lock-picking-tools') AND description LIKE 'STUB%';
-- The Espionage exclusion has to name a row that exists, or it excludes nothing.
SELECT count(*) AS exclusion_targets FROM skills
 WHERE name IN ('Sniper', 'Tracking (people)');

INSERT INTO data_script_runs (filename) VALUES ('add-thief-class.sql');
