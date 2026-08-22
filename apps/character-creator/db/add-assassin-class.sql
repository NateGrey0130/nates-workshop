-- The Assassin O.C.C., Palladium Fantasy main book, printed pp.95-96.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-assassin-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-assassin-class.sql
--
-- Read with scripts/read-columns.py. Apply add-pf-rogue-gear.sql first or
-- alongside: it adds the lock picking tools and makes the grappling hook and
-- small hammer visible to a Palladium campaign.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE LAST THREE LINES OF THIS CLASS PRINT NEXT TO A DIFFERENT ONE. The
-- assassin's stat block ends with Starting Equipment at the foot of a column,
-- and its Armor, Weapons and Money lines carry over into the third column of
-- the following page - beside the Merchant O.C.C., whose own Armor, Weapons and
-- Money lines print immediately below them. Two classes, six lines, one column,
-- no headings between them.
--
-- Geometry gets them into the right reading order but cannot say whose they
-- are. The text does:
--
--   "Armor: studded leather (A.R. 13, S.D.C. 38). Weapons: A pair of daggers
--    and three additional weapons of choice ... Assassins are often familiar
--    with a wide range of weapons. Money: 200 gold ... from assassination and
--    combat jobs, criminal activity, and stolen goods."
--
-- against the Merchant's hard leather, a knife, a notebook and quill pens.
-- Both classes start with 200 gold, so the money line alone would not have
-- separated them.
--
-- THE ASSASSIN IS A MAN OF ARMS - "thieves (and assassins) are the rogues and
-- cutthroats of the men of arms O.C.C.s", printed p91 - which is what puts it
-- in CORE_SDC_BY_CLASS at 3D6.
--
-- THE RELATED-SKILL RULE SPANS TWO CATEGORIES TWICE OVER: "two espionage
-- skills, two rogue or physical skills and five other skills of choice". One
-- count and per-category limits cannot express either half, so the count is 9
-- and both constraints are stated in the category notes - the same shape the
-- Soldier uses for its Military-or-Espionage pair.
--
-- Detect Concealment & Traps resolves to Detect Concealment, and Track
-- Humanoids to Tracking (people): the same skills under the catalog's names.
-- Rope is catalogued per 40 feet and the assassin carries 50, so two lengths.
-- Iron spikes are priced nowhere in the book, so the wooden spike row stands in.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'assassin', 'Assassin', 'palladium-fantasy', '---
id: assassin
name: Assassin
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 9, PP: 14 }
starting_money: "200"
bonuses:
  combat: { initiative: 1, pull_punch: 2 }
  saves: { horror_factor: 4 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb/Scale Walls (+10%); rappelling is a second percentile, 35% +5%." }
    - { name: "Concealment", base: 34, per_level: 4, note: "+14%" }
    - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%. The book calls it Detect Concealment & Traps." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Pick Locks", base: 45, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book calls this Track Humanoids and files it under Wilderness; the catalog row is the Espionage one, same 25% +5% base." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { choose: 4, categories: ["Weapon Proficiencies"], note: "Four of choice" }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0, note: "Cannot be changed." }
  occ_related_skills:
    count: 9
    categories:
      - { name: "Communications", note: "+10%" }
      - "Domestic"
      - { name: "Espionage", note: "+10%, and +15% on Disguise. Two of the nine must come from here." }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", note: "+10%" }
      - { name: "Physical", note: "Two of the nine must come from Physical or Rogue." }
      - { name: "Rogue", note: "+10%. Two of the nine must come from Rogue or Physical." }
      - { name: "Science", only: ["Mathematics: Advanced"] }
      - { name: "Technical", note: "+15% on language and literacy skills only" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cape, cloak or jacket", qty: 1, from: ["cape-long", "cape-long-hooded", "jacket-light", "jacket-leather"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 3 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "lock-picking-tools", qty: 1 }
  - { item_id: "rope", qty: 2 }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-hammer", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 2 }
  - { choose: 3, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). An assassin can use any type from padded to full plate and most own two or three, chosen per assignment: light armour for stealth, heavy for an expected confrontation. Penalties are -15% to prowl and -20% to climb or scale walls in full splint or plate, -10% in chain or scale mail, -5% in studded leather; hard leather, soft leather and padded carry none."
  - "Every starting weapon is a basic S.D.C. weapon of very good quality, and assassins are often familiar with a wide range of them. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The cape, cloak or jacket has 1D6+1 inside pockets, with or without a hood."
  - "The +1 attack at levels two and eight is in addition to hand to hand and any other combat skill, not instead of it."
  - "Beyond killing for hire, most assassins also sell the services of a thieves guild: spying and intelligence gathering, strong-arm work, kidnapping, breaking and entering, theft and smuggling. They charge 25-50% more than a thief for these, and the best can command double or triple."
extraction_notes: "The related-skill rule is two espionage, two rogue or physical, and five free. occ_related_skills has one count and per-category limits and cannot express a constraint spanning two categories, so the count is 9 and both halves are stated in the category notes. Detect Concealment & Traps resolves to the Detect Concealment row, and Track Humanoids to Tracking (people); both are the same skill under the catalog name. Rope is catalogued per 40 feet and the assassin carries 50, so two lengths. Iron spikes are not priced anywhere in the book, so the wooden spike row stands in. The Armor, Weapons and Money lines print in a third column beside the Merchant O.C.C. and are attributed by their own text."
---

# Assassin

## Lore

The assassin, like the mercenary fighter, is a sword for hire, and the specialty
is death. Unlike the mercenary and the other warrior classes, the assassin is
usually a disreputable character who rarely faces an opponent in a fair fight.
The goal is to kill the target quickly, cleanly and ideally without ever being
seen, so the assassin strikes from behind or from a distance, and like the thief
uses distraction and confusion to cover both the attack and the escape. Many men
at arms consider them cowards; in fact they are typically bold and experienced
warriors skilled in combat and espionage, and some show expertise that rivals or
exceeds a palladin.

Some assassins are self-styled patriots who kill only enemies of their king and
country. Others are freebooters who happen to be good at killing, and try to
limit themselves to those they regard as enemies or as evil. Most, though, enjoy
the challenge of hunting and slaying humanoid prey, and the worst enjoy torture
and killing for its own sake. Those become the bounty hunters and killers who
care nothing for politics, justice, or good and evil, and ply the death trade
for money and pleasure: merciless, calculating and cold-blooded.

Despite the trade, or perhaps because of it, most assassins will not
double-cross an employer even for a king''s ransom. It is bad for business, and
one with a reputation for betrayal will not find work. They also show some
measure of loyalty and compassion toward friends, allies and travelling
companions. Only the most boorish and miscreant trust nobody at all.

## Alignment

No good alignment, not even unprincipled: an assassin is restricted to anarchist
and evil. Most have little regard for the lives, freedoms or rights of others
and rarely question the moral or political consequences of a job. Not all are
without honour or conscience, though. Aberrant assassins in particular hold a
code of ethics and twisted principles that makes even a paid killer seem worthy
of some respect, rarely endangering innocent bystanders and capable of mercy,
sincerity and kindness. Non-player characters are likely to be evil through and
through.

## GM Notes

Assassins guilds turn up occasionally in the larger civilised kingdoms, several
in the Western Empire and a few in the Eastern territory, but they are
comparatively uncommon. They work like a thieves or magic guild, providing
information, services and standardised fees, with a headquarters, a library and
somewhere for members to stay or hide. They are less territorial than a thieves
guild and far more secretive, and membership is by invitation. They seldom care
about freelance assassins working their territory unless the activity
incriminates or endangers the guild or an important member. Some assassins are
members or creations of death cults that worship vampires and dark gods.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'assassin');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'assassin';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('studded-leather', 'lock-picking-tools', 'grappling-hook',
                'small-hammer', 'purse-satchel');
SELECT count(*) AS stub_gear FROM gear
 WHERE slug = 'lock-picking-tools' AND description LIKE 'STUB%';
-- Hand to Hand: Assassin cannot be swapped, so the row had better be there.
SELECT name, level_bonuses IS NOT NULL AS has_level_table FROM skills
 WHERE name = 'Hand to Hand: Assassin';

INSERT INTO data_script_runs (filename) VALUES ('add-assassin-class.sql');
