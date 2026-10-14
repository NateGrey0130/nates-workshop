-- Scoped skill bonuses move from prose to keys on seven classes of six books (BOOK-INGEST-AUDIT F138, row 32b)
-- 7 classes, each replaced whole: saloon-bum, professional-gambler, titan-juicer, trapper-woodsman, trimadore, psi-druid, gypsy-wizard-thief.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~190-book-ingest-audit-f138-scoped-b.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F138, second of five rows (32a, 32b, 33, 34a, 34b):
-- seven classes of six books carried a skill bonus that applies to SOME skills
-- only as prose, marked "add by hand" or "not applied". Each now holds it as a
-- scoped category entry - a second entry for the same category with `only` and
-- its own `bonus` (F109 ranking), or a name added to an `only` list on another
-- category, whose bonus then pays a cross-category pick (F9). Every figure was
-- read off a render of the cited page on 2026-10-14:
--   saloon-bum            New West printed 122: Rogue +10% to Pick Pockets and
--                         Cardsharp only; Pick Pockets is Espionage here
--   professional-gambler  New West printed 119: Domestic +5%, +15% to sing and
--                         play instruments; Sing is Communications here
--   titan-juicer          Juicer Uprising printed 34: Prowl -5%, printed under
--                         Physical and Rogue, one penalty
--   trapper-woodsman      Canada printed 90: Technical +10%, Whittling and
--                         Breeding Dogs +15%
--   trimadore             D-Bees of North America printed 207: Military +10% to
--                         all Demolitions and Trap skills
--   psi-druid             Psyscape printed 62: Rogue Concealment (+5%), Palming
--                         and Ventriloquism only
--   gypsy-wizard-thief    Triax printed 182: Espionage Disguise, Forgery,
--                         Intelligence and Wilderness Survival only (+10%)
-- Secondary skills are untouched: the books give them no bonus.

-- == saloon-bum ==
UPDATE imported_classes
   SET markdown = '---
id: saloon-bum
men_of_arms: false
name: Saloon Bum/Stoolie
system: rifts
source_book: Rifts World Book 14: New West p.120-123
category: occ
tags: []
xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]
occ_group: optional
hit_points_base: "P.E. + 1d6 per level"
starting_money: "4d4x100 in universal credits and 3d4x100 worth of credits in tradeable goods"
bonuses:
  attributes: { PE: "1d4" }
  combat: { initiative: 1, roll: 2 }
  pools: { sdc: "1d6" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Speak one additional language of choice (+20%)." }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Surveillance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Interrogation", base: 35, per_level: 5, note: "+5% for a good character, +10% for an evil one. Stored at the good figure." }
    - { choose: 1, from: ["Horsemanship: General", "Hover Craft (ground)"], bonus: 5, note: "Horsemanship: General or Pilot Hover Vehicle (+5%). The catalog files hover vehicles as Hover Craft (ground)." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Sing", "Dance"], bonus: 10, note: "Sing or Dance (+10%; pick one). Dance is granted outright above, so picking it here is a second helping of the same row." }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. two of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be traded up to Expert for two O.C.C. Related skills, or to Martial Arts or Assassin for three." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["Brewing", "First Aid"], bonus: 10 }
      - { name: "Military", only: ["Find Contraband", "Recognize Weapon Quality"], bonus: 10 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - "Pilot"
      - { name: "Rogue", except: ["Seduction"], note: "Any Rogue skill except Seduction; the +10% is printed against Pick Pockets and Cardsharp only." }
      - { name: "Rogue", only: ["Cardsharp", "Pick Pockets"], bonus: 10, note: "The +10% is printed against Pick Pockets and Cardsharp only. Pick Pockets is an Espionage skill in this catalog, which this class grants; this entry names it, so it takes the +10% here." }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 10, count: 2 }, { level: 15, count: 2 }]
special_abilities:
  - name: "Drink others under the table"
    description: "An average character notices the drink after three and is fairly drunk after six, especially inside two hours - a typical bottle holds sixteen to twenty shots. The penalties run: three drinks, -6% on all skills; six, -12% on skills, -2 initiative and all combat bonuses, speed down a fifth; nine, -24% on skills and speed, initiative, attacks and all combat bonuses halved; twelve or more, -40% on skills, speed down to a fifth, and initiative, attacks and combat bonuses cut to two. THE SALOON BUM, and a dwarf, can drink two and a half times as much before any of it starts - at the risk of becoming an alcoholic if he does it regularly. For comparison the book gives double for a Saloon Girl, Bounty Hunter, Gunslinger, Wired Slinger, Crazy, Juicer, True Atlantean, Simvan or any heavy drinker; triple for a dragon, Brodkil or lesser demon; quadruple for a greater supernatural being."
  - name: "Knows the room"
    description: "Whether he drinks heavily or simply hangs about, the Saloon Bum knows his way around a saloon, a dance hall and a gambling house, and can spot outsiders, gunslingers, gunfighters, knights, lawmen and professional gamblers on sight - the same as the Streetwise skill."
equipment_starting:
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Cowboy, Pilot Related and Wilderness are closed as related categories, and the Pilot category excludes military vehicles, robots and power armour."
side_effects: "The evil Saloon Bum is a backstabbing coward without the body or the wits to be anything better, who settles for being a lowlife servant of some greater force - a criminal, a politician, a rancher, a supernatural being. He bums drinks and scrapes a living as a stoolie, gofer and henchman, spying on visiting lawmen and adventurers and running off to tell his master. He is bold only against the incapacitated, outnumbered, helpless or weaker, the elderly and children included. The good or unprincipled Saloon Bum is instead someone whose body or spirit has been broken - old, infirm, weak, crippled, dull-witted, homely, or badly traumatised - and who serves the sheriff, the saloon keeper or some other decent figure in the same roles: messenger, spy, gofer and helper."
extraction_notes: "The +1D4 to P.E. is `bonuses.attributes` PE "1d4", rolled once at creation. On import (PR #887) it was an ability, on the belief that a dice expression there was not applied; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved it into the block. `occ_group` is `optional` rather than `men-of-arms`, matching the Professional Gambler: the book files this class among the adventurers of the New West and the five legal values have no closer fit. The Interrogation figure is stored at the GOOD character''s +5%, because a single row cannot carry two percentages keyed on alignment; the evil +10% is in that entry''s note. The ''Sing or Dance (+10%; pick one)'' line follows a Dance already granted at +20%, so picking Dance there is a second helping of the same row - transcribed as printed rather than resolved. The book adds that these same stats make a BARKEEP NPC with two more lores at +10% and all rogue skills available at +2%; that is an NPC variant rather than a player option and is not stored. Standard Equipment stores only the catalog rows that exist; the book also lists a suit of M.D.C. body armour, usually light or a half suit, a set of clothes, boots, a cowboy hat, a saddle bag, a holster, 1D4 bottles of moonshine, one bottle of excellent bourbon, and sunglasses or goggles. The book prints a WAGE as well as a purse: ten to fifteen drinks a night, free room and board at a shabby flat, and 50-75 credits a week."
---

# Saloon Bum/Stoolie

**Alignments.** Any.

The Saloon Bum is typically a spineless coward, a two-bit thug, or an alcoholic.
Unlike the Saddle Tramp there is rarely anything likeable about him, which is
what makes him such a good NPC villain - or, played the other way, a
sympathetic sidekick.

He is one of the weasels who hang about saloons, gambling halls and other seedy
places with an ear open for trouble and opportunity. Most covet power and
wealth and settle for being somebody else''s lackey.

## Saloons

The saloon is the centre of a New West town''s social life: a bar, a lounge and
dining area, and usually a stage for musicians, singers, burlesque, dancing
girls, comedians and acrobats - entertainment that is normally free because it
draws custom, or carries a small cover of a few credits, unless a name
performer is in, when it can be ten to fifty a head.

Most saloons allow friendly games of cards, dice and darts, and those that
cater to gamblers run craps, roulette, blackjack, faro, keno, three-card monte,
shell games, slot machines and arcade games, with a pool room, a poker room and
private rooms for the big money. Out back there may be horseshoes, or a pit for
wrestling, boxing and blood sports. Whether the games are honest depends
entirely on the owner - and even an honest blackjack dealer wins about
two-thirds of the time.

Many saloons rent rooms, typically twenty to sixty credits a night and a fifth
to a third cheaper than the local hotel, and rarely as safe. Those hiding
outlaws keep one to four secret rooms and charge several times the rate per
person - and will feign shock if the guests are found.

## Lore

Also known as the Bar Fly, the Drunk, the Stoolie and the Stool Pigeon.
',
       updated_at = datetime('now')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, 'add its +10% by hand.') > 0
   AND length(markdown) = 8968;

-- == professional-gambler ==
UPDATE imported_classes
   SET markdown = '---
id: professional-gambler
men_of_arms: false
name: Professional Gambler
system: rifts
source_book: Rifts World Book 14: New West p.117-120
category: occ
tags: [stealth]
xp_table: [0, 2111, 4221, 8201, 16401, 23201, 32401, 48201, 68401, 92201, 127401, 178201, 228201, 278201, 328401]
occ_group: optional
attribute_requirements: { IQ: 10, MA: 10, ME: 12, PP: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "3d4x100 credits worth of tradeable goods and 3d6x1000 in universal credits"
bonuses:
  combat: { initiative: 2, pull_punch: 2, disarm: 1 }
  pools: { sdc: "2d6+6" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American, at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Speaks one language of choice (+20%)." }
    - { name: "Literacy: Native Language", base: 97, per_level: 0, note: "Literacy: American, at a flat 97%." }
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "Math: Basic, at a flat 98%." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Cardsharp", base: 44, per_level: 4, note: "+20%" }
    - { name: "Palming", base: 40, per_level: 5, note: "+20%" }
    - { name: "Concealment", base: 35, per_level: 4, note: "+15%" }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%" }
    - { name: "Disguise", base: 45, per_level: 5, note: "+20%" }
    - { name: "Escape Artist", base: 45, per_level: 5, note: "+15%" }
    - { name: "Seduction", base: 32, per_level: 3, note: "+12%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "One piloting skill of choice (+10%)." }
    - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
    - { name: "W.P. Revolver", base: 0, per_level: 0, note: "Includes the Derringer." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. one MODERN weapon of choice. The catalog does not divide W.P.s into modern and ancient, so the restriction is a note." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be traded up to Martial Arts or Assassin for two O.C.C. Related skills." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 10, count: 2 }, { level: 14, count: 2 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 5, note: "+5%, and +15% to Sing and Play Musical Instrument." }
      - { name: "Domestic", only: ["Play Musical Instrument", "Sing"], bonus: 15, note: "+15% to Sing and Play Musical Instrument. Sing is filed under Communications in this catalog, which this class grants at +10%; this entry names it, so it takes the Domestic line''s +15% in place of that +10%." }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Locksmith", "Automotive Mechanics"], bonus: 10 }
      - { name: "Medical", only: ["Brewing", "Paramedic"], bonus: 5 }
      - { name: "Military", only: ["Find Contraband", "Trap Construction", "Trap/Mine Detection"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 10 }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 5, count: 2 }, { level: 7, count: 2 }, { level: 9, count: 2 }, { level: 11, count: 2 }]
special_abilities:
  - name: "Mastery of Card Sharking"
    description: "The Cardsharp''s skill, extended. The hands are soft and sensitive enough to read variations and marks on the cards by touch - the equivalent of reading Braille - and fast enough to stack a deck, palm key cards, and deal from the top, middle or bottom at speed, putting whatever cards he wants wherever he wants them. Recognising cheating and marked cards is the Cardsharp skill at -10%. It also grants two extra melee actions per round for palming, concealing, stacking and dealing cards, and those are conditional on card work, so they are not added to the sheet''s attacks."
  - name: "Quick-Draw Initiative: Handguns OR Throwing Knives (pick one)"
    description: "A P.P.-scaled initiative bonus exclusive to this class: +1 to initiative for every two P.P. points above 16, to a maximum of +7 at P.P. 30. A Gambler with a P.P. of 24 is +4. The player picks handguns or throwing knives - Vibro-Knives included - at creation, and the bonus applies to that type alone. With knives the Gambler can choose normal damage or double damage on a called shot to a vital spot. Scaled on an attribute rather than on level, so it is not applied automatically."
  - name: "Tolerance to Alcohol"
    description: "Can drink twice as much as an average person before the penalties start - see the Saloon Bum''s drinking rules, printed 121-122. Most Gamblers nurse their drinks after the first two anyway, or substitute tea or apple juice for bourbon while buying rounds for everybody else."
  - name: "Reputation"
    description: "Going up against a notorious professional is unnerving while the professional stays cavalier. Average characters playing cards against him are -10% on their card-playing skills, and anyone trying to pick his pocket or palm or conceal something from him is -10% to do it."
  - name: "Stacking the odds"
    description: "Gamblers research their opponents'' personalities, quirks and tempers, which tells them how far they can push. Flattery, cheerful conversation and staying cheerful while losing are all distractions worth a cumulative -5% to an opponent''s cardsharp and playing skills. Professional Gamblers are immune to the same tactics."
  - name: "Paired Weapons: Revolvers and Pistols (optional)"
    description: "The same ability the Gunslinger and Gunfighter have, but not automatic: it may be bought at the cost of two O.C.C. Related skills, and is not available as a secondary skill. Sharpshooting specialties likewise count as two skill selections each."
equipment_starting:
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Cowboy skills are closed as a related category."
  - "No vehicle to start - probably gambled away."
  - "No cybernetics to start; the choice is left to the player."
side_effects: "Gamblers are generally taken for scalawags and troublemakers, though their money and their daring are welcome at most gambling halls and saloons. About one in five is a minor or major psionic."
extraction_notes: "The O.C.C. Skills list on printed 119 is set in TWO COLUMNS and the text layer interleaves it - the third such list in this book, after the Highwayman on printed 86 and the Wired Gunslinger on 109. Read off a 320 dpi render before transcribing. `occ_group` is `optional` rather than `men-of-arms`: the book files this class under Adventurers of the New West alongside the Cowboy and the Saloon Girl rather than among the gunfighters, and the five legal values have no closer fit. The +4 initiative bonus the book gives for palming, picking pockets or cheating at cards is CONDITIONAL and is described in the Mastery ability; only the flat +2 combat initiative is in `bonuses`. Literacy and Math are printed as flat 97% and 98% with no per-level gain and are stored that way. Standard Equipment stores only the catalog rows that exist; the book also lists light to medium M.D.C. body armour, mirrored sunglasses, a quality cowboy hat, travelling clothes, fancy business clothes, a pen flashlight, a notepad and pens, a used deck of cards, a sealed deck, a marked deck, a pair of loaded dice, a magnifying glass, a laser distancer, a pocket translator, a portable tool kit for palming and escaping, a dozen quality cigars, a bottle of fine bourbon, a second bourbon bottle filled with tea, a cigarette lighter, a pocket mirror, a pair of handcuffs, 50 ft of rope, saddlebags, a laser scalpel, a straight razor at 2D4 S.D.C., one or two folding pocket knives, a Derringer, a six-shooter with 60 silver bullets, an energy pistol of choice, one more weapon of choice, 1D4+1 spare clips each, five smoke grenades and six flares."
---

# Professional Gambler

**Alignments.** Any, but often unprincipled and anarchist. Some are honourable
and live by the Code of the New West.

The stereotype is a slick dresser with an air of sophistication, and often that
is exactly right - but the Professional Gambler can look and act rich or poor,
suave or rough, sophisticated or bawdy. What is true of all of them is that they
are risk takers, daring and bold and willing to stake everything, their own
lives included, if the reward is large enough. For some the reward is money or
fame; for others it is cheating death, their own or somebody else''s.

In many ways the Gambler is part con artist, part trickster and part secret
agent, working with concealed weapons, derringers and magic, disguises,
forgeries, misdirection, secret accomplices and their wits.

## Playing the odds

For all the reputation for risk, most professionals prefer to play the odds -
and to stack them quietly in their own favour, which makes the results look more
impressive than they are. That extends to people: a Gambler will research an
opponent''s personality, quirks, likes and dislikes, so he can read a response,
judge the chance of violence, and know how far he can push.

The old tricks are all distractions. Polite, cheerful conversation and flattery.
Staying cheerful while losing, which drives the competition to distraction. And
alcohol - most people, particularly men with something to prove, insist they
play better with a drink in them, and nothing could be less true.

## Lore

Also known as the Cardsharp, the Card Shark, the Maverick, the Rook and the
Hustler.

A professional hustler often works with a sidekick: a cheat who plays the
affable fellow or the innocent half-wit, stands near the table, and signals the
opponents'' hands by cigarette smoke, folded arms, a scratched nose, a hummed
tune or a few bars on an instrument. The sidekick may also sit in for a few
hands and be dealt a run of winners before leaving with the takings, which draws
suspicion off the Gambler, who has been losing to him. Typical partners are the
Saloon Girl, the Saloon Bum, the Saddle Tramp, vagabonds, low-level gamblers,
and occasionally gunslingers - or a psychic, who is worth a great deal if he has
telepathy or empathic transmission.
',
       updated_at = datetime('now')
 WHERE class_id = 'professional-gambler'
   AND instr(markdown, 'is filed under Communications in this catalog; add it by hand.') > 0
   AND length(markdown) = 11264;

-- == titan-juicer ==
UPDATE imported_classes
   SET markdown = '---
id: titan-juicer
name: Titan Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.32-35
category: occ
tags: [combat, augmented]
xp_table: [0, 2251, 4501, 9001, 18001, 25501, 36001, 52001, 75001, 100001, 140001, 200001, 260001, 320001, 400001]
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "Juicer Uprising p.17 names the Titan as one of the three variants a Dwarf may take, along with Mega and Dragon Blood, and the standard conversion - though a Dwarven Titan stands only six to seven feet. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet."
hit_points_base: "P.E. + 1d4x100, +1d6 per level"
sdc_base: "3d6x100"
starting_money: "4d6x100"
bonuses:
  attributes: { PS: "2d6+8", PE: "3d4", PP: "1d4", Spd: "2d6" }
  attribute_minimums: { PS: 30, PP: 17 }
  combat: { initiative: 1, roll: 1, attacks: 1 }
  saves: { psionics: 5, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, horror_factor: 4, coma_death_pct: 25 }
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "titan-plate-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: "4d4" }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws"] }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Piloting: two of choice (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"], note: "The book prints this as W.P. Heavy OR W.P. Heavy Energy Weapons; this catalog files those as Heavy Military Weapons and Heavy M.D. Weapons." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Physical", only: ["Prowl"], bonus: -5 }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Medical is None for a Titan and is therefore absent from this list rather than restricted. Physical is any EXCEPT Acrobatics - a Titan is too big for it. Prowl carries a printed -5% penalty, listed by the book under both Physical and Rogue. It is one penalty, not two: Prowl is a Physical skill in this catalog, and the second Physical entry carries the -5%. Pilot Related is open, but the book warns the Titan may simply be too large for most conventional vehicles."
  secondary_skills:
    count: 6
special_abilities:
  - name: "Reinforced Skeleton"
    description: "Eight weeks of treatment mix metal particles into bone tissue, leaving bones as strong as tempered steel. Titans end up 60% to 80% larger and three to four times heavier than they were - 600 to 700 lbs (270 to 315 kg) is average. The smallest Titan dead-lifts 3,000 lbs (1,350 kg); over two tons is the common limit."
  - name: "Minor Mega-Damage Being"
    description: "The S.D.C. and hit point totals together run 400 to 2,200, which the book counts as 4 to 22 M.D.C. Ordinary S.D.C. attacks still hurt and can still kill, but it takes a great deal of S.D.C. damage - and at only 22 M.D.C. a few well-placed blasts will do it, which is why most Titans wear armour anyway."
  - name: "Supernatural Strength"
    description: "The Titan''s P.S. is SUPERNATURAL: carry 50 times P.S. in pounds and lift 100 times P.S. Damage follows the supernatural strength table reprinted from Rifts Conversion Book One - at P.S. 30 that is 5D6 S.D.C. restrained, 3D6 M.D. full strength, 6D6 M.D. on a power punch counting as two attacks. Punching a mega-damage structure bare-handed costs the Titan one S.D.C. point per M.D. point inflicted; with M.D. gloves or gauntlets he punches with impunity."
  - name: "Super Speed"
    description: "Titans are the SLOWEST of the Juicers, but supernatural strength still carries them: leap 20 feet (6.1 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Barely better than normal for a Juicer, but gets an automatic parry or dodge against ALL attacks, including from behind and from surprise. The combat numbers are in the bonuses block."
  - name: "Enhanced Healing"
    description: "Heals one hit point or S.D.C. per point of P.E. EVERY HOUR - a Titan with P.E. 24 heals 24 an hour. Virtually impervious to pain, as per the normal Juicer. The +25% to save versus coma and death is in the bonuses block."
side_effects: "Low Life Span. Titans burn out faster than common Juicers: the average life span is 5 years and 2D6 months. All the normal Juicer penalties apply on top - insomnia, restlessness, impatience."
restrictions: ["Starts with no cybernetics and rarely acquires any."]
extraction_notes: "The 4-22 M.D.C. is a reading of the S.D.C./hit point total, not a separate pool, so it is prose rather than mdc_base - setting mdc_base would replace the S.D.C. the book actually grants. Augmentation cost is 100,000-150,000 credits, sometimes more, and is prose rather than starting_money, which is coin only. Standard equipment names Titan Plate Armor at 180 M.D.C.; its gear row exists (titan-plate-armor, which carries 195 M.D.C.) and equipment_starting lists it."
---

## Lore

The Titan conversion was developed in the kingdom of Los Alamo, near the ruins
of pre-Rifts Austin, Texas, by researchers trying to build a Juicer who could
fight a supernatural monster or a robot vehicle and win.

Hormone treatments got the strength there and then killed the subjects: past a
certain point they carried so much muscle that their own bones were crushed
under it. What the project needed was a way to make bone stronger than anything
an Earth animal grows. The answer was a chemical solution laced with metal
particles - in quantities that would be poisonous under most circumstances -
dissolved in a binding agent that sought out bone tissue and fused with it,
mixing metal and bone into a single whole.

Then growth hormones triggered a spurt like a human''s first sixteen years,
compressed into a matter of weeks. Eight weeks of Titan treatment leave a Juicer
60% to 80% larger and three to four times heavier, strong enough to punch
through power armour plating.

## GM Notes

**Demographics.** Titans are 5% of all Juicers in North America.

**The trade is speed for mass.** A Titan is the slowest Juicer and the only one
who is genuinely hard to kill - and the only one who has to think about whether
he fits. Pilot Related is open to him and the book still warns that most
conventional vehicles are not built for a seven-foot, 650-pound passenger.

**The supernatural strength table is the reason to look up P.S.** Everything
about a Titan''s damage output moves when P.S. crosses 30, 35 and 40, so the
rolled number matters more here than in any other Juicer variant.
',
       updated_at = datetime('now')
 WHERE class_id = 'titan-juicer'
   AND instr(markdown, 'cannot be negative for one skill') > 0
   AND length(markdown) = 8862;

-- == trapper-woodsman ==
UPDATE imported_classes
   SET markdown = '---
id: trapper-woodsman
name: Trapper-Woodsman
system: rifts
source_book: Rifts World Book 20: Canada p.88-90
category: occ
tags: [wilderness, hunter]
occ_group: optional
men_of_arms: false
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { IQ: 8, PE: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "0"
bonuses:
  pools: { sdc: "4d6+10" }
  combat: { initiative: 2, pull_punch: 3 }
  saves: { possession: 1, toxins_poisons: 2, disease: 2, pain: 2, horror_factor: 1, other: [ { label: "vs cold", bonus: 2 } ] }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Language: Native Tongue", base: 92, per_level: 0, note: "Speaks American (English) at 92%." }
    - { name: "Language: Inuit", base: 65, per_level: 5, note: "Speaks Inuit (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language of choice (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Cattle & Animals", base: 50, per_level: 5, note: "Lore: Cattle/Animals (+20%)." }
    - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Printed as Track Animals (+20%). The special ability for monstrous animals has its own percentages." }
    - { name: "Skin & Prepare Animal Hides", base: 55, per_level: 5, note: "+25%" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "Identify Plants & Fruits (+15%)." }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Fishing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "Swim (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "Climb (+10%)." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
    - { name: "Trap Construction", base: 35, per_level: 4, note: "+15%" }
    - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two ancient of choice (any)." }
    - { name: "W.P. Bolt Action Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one M.D. energy weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "No others are available." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Tracking (people)"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"], bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Tanks & APCs", "Military: Submersibles", "Military: Warships & Patrol Boats", "Boat: Ships", "Boat: Submersibles", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only: ["Whittling & Sculpting", "Breed Dogs"], bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Choose four other skills at level one and two additional at levels 4, 8 and 12. Communications: any. Domestic: any (+5%). Electrical: none. Espionage: none, except Detect Ambush, Detect Concealment, Intelligence and Tracking (all +5%). Mechanical: none. Medical: First Aid, Holistic Medicine and Brewing only. Military: none (Falconry is offered here only because the catalog files it under Military; the book prices it under Technical at +15%). Physical: any, except Acrobatics. Pilot: any, except robots, power armor, military vehicles, ships and aircraft; most opt for Horsemanship and/or Ride Exotic Animals, offered here in their own category. Pilot Related: any, but usually none. Rogue: any. Science: Astronomy, Botany and Advanced Math only (+5%). Technical: any (+10%; Whittling, Breeding Dogs and Falconry are +15%: Whittling & Sculpting and Breed Dogs take it from the second Technical entry, Falconry from Military). W.P.: any. Wilderness: any (+10%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Tracking (people)"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Brewing"] }
      - { name: "Military", only: ["Falconry"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Tanks & APCs", "Military: Submersibles", "Military: Warships & Patrol Boats", "Boat: Ships", "Boat: Submersibles", "Military: Combat Helicopter", "Military: Jet Fighters", "Fighter Combat: Basic", "Fighter Combat: Elite", "Airplane", "Jet Aircraft", "Helicopter", "Wingrider Flying Wing", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Astronomy", "Botany", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two secondary skills from the same list at level one and one additional at levels 2, 4, 6, 8 and 12, without the bonuses in parentheses and limited as the list indicates."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - { name: "Track & Trap Monstrous Animals, Otherworldly Creatures & Demons", description: "A wider, specialized form of Track Animals aimed at alien and monstrous prey: dinosaurs, Demon-Bears, the Windigo, Rhino-Buffalo, Fury Beetles and the like. Identifies an animal, a creature from the Rifts or an animalistic demon by tracks, scent, spoor and habits; follows its trail; judges how fresh the tracks are, their direction, whether the creature is hurt or sick and roughly how old; and knows how and where most woodland creatures of Canada and the northern U.S. live, among them woodland spirits, lesser demons, werebeasts, the Loup-Garou, the Windigo and Faerie Folk. Base skill 20% tracking / 30% trapping (using, setting and disarming snares, clamp traps, pits, nets and the like), +5% per level. Tracking humans is possible at -20%. Disarming a trap meant for humans is at half the normal skill." }
  - { name: "Forest-wise", description: "Streetwise for the forest: recognizes the human, D-Bee, Faerie Folk, werebeast and lesser demon tribes, gangs and bands that live, hunt or hide in the woods, and knows what they believe, how they behave, their rituals, where they gather and which places are dangerous. Predatory animals are covered too. Base skill 26%, +4% per level." }
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["homemade-mdc-armor-light", "fury-beetle-armor-partial"], note: "Light suit of M.D.C. body armor, usually a hodgepodge of homemade armor or Fury Beetle armor." }
  - { item_id: "vibro-knife", qty: 1, note: "1D6 M.D." }
  - { item_id: "e-clip", qty: "1d4+2", note: "1D4+2 extra ammo-clips for each weapon, beyond one weapon for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "knife-skinning", qty: 2, note: "The book says skinning knives, with no number." }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "hand-axe-utility", qty: 1, note: "The book says a hand axe." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, note: "The book says a language translator." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "The book says a lighter." }
  - { item_id: "flint", qty: 1, note: "Flint and tinder box." }
  - { item_id: "frying-pan", qty: 1 }
  - { item_id: "small-sack", qty: "1d6" }
  - { item_id: "sack", qty: 6, note: "Six medium-sized sacks." }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "duffle bag or saddlebag", qty: 1, from: ["duffle-bag", "saddlebags"] }
  - { item_id: "canteen", qty: 2, note: "Two canteens or water skins." }
  - { item_id: "belt", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "lightweight-cord", qty: 1, note: "10 feet (3 m) of thin nylon cord." }
  - { item_id: "cord", qty: 1, note: "50 feet (15.2 m) of additional cord, 600 lb (270 kg) test strength." }
  - { item_id: "animal-snare", qty: 1, note: "The book says animal snares, with no number." }
trackable_resources: []
restrictions:
  - "Alignment: any, but most are good or selfish."
  - "Racial restrictions: none."
  - "Attribute requirements: I.Q. 8 and P.E. 12 or higher. A high M.E. and P.S. are helpful but not a requirement."
  - "Psionics: psionic abilities are not a requirement."
  - "Hand to Hand: Expert only; no others are available."
  - "Cybernetics: none to start, and avoids them as unnatural. The only cybernetics a Trapper might consider are bio-system prosthetics and organs to replace severely injured ones."
  - "Vehicle: none to start; most Trappers prefer to walk, but may know how to ride a horse or hovercycle."
extraction_notes: "WB20 Canada printed 88-90 (cache p089-p091, cache page = printed folio + 1), read off the text layer; all three pages were rendered and read beside it. Heading Trapper-Woodsman OCC on printed 88, after the pointer list Other Common O.C.C.s available to Tundra Rangers; Special Skills & O.C.C. Abilities and the stat block headed The North American Trapper-Woodsman O.C.C. (also known as Woodsman, Trapper and Furrier) on printed 89; the entry ends on printed 90 with a note that this is a different class from the Huntsman-Trapper of Warlords of Russia. Southwestern Canada starts on printed 91. || GROUP: the book has no O.C.C. group headings. The entry says the Trapper-Woodsman is not a Tundra Ranger and calls the character a rogue, mercenary or independent entrepreneur, so occ_group is optional and men_of_arms is false, as for the Huntsman-Trapper. The entry prints no S.D.C. base; +4D6+10 S.D.C. is listed under O.C.C. Bonuses and is stored as a pool bonus. || XP: the Tundra Ranger, Headhunter Techno-Hound and Trapper-Woodsman ladder on printed 192, as supplied from a render. || BONUSES: +2 initiative, +3 pull punch, +1 vs possession stored; +2 vs poison and disease is toxins_poisons 2 and disease 2; +2 vs cold and pain is pain 2 and a saves.other vs cold 2; +1 vs Horror Factor at levels 1, 3, 5, 7, 9, 11, 13 and 15 is horror_factor 1 flat for level 1 plus seven at_level entries. || SPECIAL ABILITIES: Track and trap monstrous animals (20%/30% +5% per level) and Forest-wise (26% +4% per level) are special_abilities prose; neither has a catalog skill row. The O.C.C. skill list separately prints Track Animals (+20%), stored as Track & Trap Animals at 40. || LANGUAGES: Speaks American (English) at 92% is Language: Native Tongue at 92. Speaks Inuit and one other language of choice (+15%): Inuit is the Language: Inuit row (added by ~114) at the catalog 50% plus 15, and the other is one Language: Other pick at +15%. The entry prints no literacy. || SKILL READINGS: Basic Math is Mathematics: Basic; Lore: Cattle/Animals is Lore: Cattle & Animals; Identify Plants & Fruits is Identify Plants & Fruit; Swim and Climb are Swimming and Climbing. W.P. two ancient of choice and W.P. one M.D. energy weapon of choice are free Weapon Proficiencies picks with the limit in the note. Hand to Hand: Expert, no others available. || RELATED: four at level one and two more at levels 4, 8 and 12. Espionage none except Detect Ambush, Detect Concealment, Intelligence and Tracking (+5%), Tracking being Tracking (people). Science is Astronomy, Botany and Mathematics: Advanced (+5%). Technical any +10% with Whittling, Breeding Dogs and Falconry at +15%: Technical is stored at +10%, with a second Technical entry naming Whittling & Sculpting and Breed Dogs at +15% (BOOK-INGEST-AUDIT.md F138, 2026-10-14); Falconry is filed under Military in the catalog, so Military appears with only Falconry at +15% although the book says Military: None. Pilot except robots, power armor, military vehicles, ships and aircraft excludes the robot and power armor rows, every Military: pilot row, Boat: Ships and Boat: Submersibles, and every aircraft and spacecraft row. Most opt for Horsemanship and/or Ride Exotic Animals is the catalog Horsemanship category limited to General and Exotic Animals. || MONEY: the book prints 4D4x100 credits worth of furs, horns, bone, nuggets of silver or gold and other tradeable goods (text layer 4D4xlOO); that is goods, not coin, so starting_money is 0 and the goods are in GM Notes. || EQUIPMENT: the light M.D.C. armor is a pick between the homemade light armor row and partial Fury Beetle armor; two canteens or water skins on the canteen row; duffle bag or saddlebag as a pick; skinning knives print no number and two are stored; animal snares print no number and one is stored. NOT stored: one weapon for each W.P. (unnamed), cooking utensils, the two boxes of 100 sealable plastic bags, 1D4 airtight plastic containers, fur cloak or long coat, 20 feet of wire and a handful of personal items have no catalog row. Secret Resources: none per se."
---

## Lore

The Trapper-Woodsman is no Tundra Ranger, but the Rangers meet them all the
time. They are the hunters, trappers and furriers of the Canadian wilds, the
New West and the forests of the eastern United States: rough, loud,
self-reliant people who are far more comfortable under trees than on a city
street. Hunting, fishing, snaring and skinning are how they earn a living,
trading pelts, horn, claws, teeth and meat with Native Americans, trading
posts, farms and anyone they meet on the trail.

Most like the woods because nobody there tells them how to behave. They
belch, swear and say what they think, and they enjoy it when city people
take them for ignorant savages; plenty of them play the bumpkin on purpose
around Coalition soldiers and strangers they distrust. Under the act they
are sharp, observant and quick, and they like a surprise and a challenge.

They also like adventure and a good fight, and they have a soft spot they
will not admit to. A Trapper who takes a liking to someone is fiercely
loyal, and most will stop to help women, children and lawmen, pass news and
warnings to the Rangers, and now and then ride with them against something
evil. Few accept bionics. They wear Mega-Damage armor, often homemade or cut
from Fury Beetle shell, and carry both M.D. weapons and ordinary hunting
rifles or bows.

## GM Notes

Starting kit the sheet does not list: one weapon for each W.P. (1D4+2 extra
ammo-clips for each are on the sheet as E-Clips), cooking utensils, a box of
100 sealable plastic sandwich bags, a box of 100 large sealable bags, 1D4
airtight resealable plastic containers, a fur cloak or long coat, wire (20
feet) and a few personal items. More weapons, special items and magic
items come with time and role-playing.

Money: no cash. The character starts with 4D4x100 credits worth of furs,
horns, bone, silver or gold nuggets and other trade goods (herbs, spices,
birds, small animals). Most spend quickly and live off the land.

Languages: Inuit and one language of choice, each at +15%. Inuit is
granted; the other is a free language pick.

Technical skills: Whittling & Sculpting and Breed Dogs get +15% rather than
the +10% the rest of Technical gets, when taken as a related skill.

Secret resources: none as such, though most Trappers are on good terms with
the trading posts, a favorite town and the Tundra Rangers.

This is a different class from the Huntsman-Trapper of Warlords of Russia.
',
       updated_at = datetime('now')
 WHERE class_id = 'trapper-woodsman'
   AND instr(markdown, 'add 5% by hand if either is taken') > 0
   AND length(markdown) = 18140;

-- == trimadore ==
UPDATE imported_classes
   SET markdown = '---
id: trimadore
name: Trimadore
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.206-208
category: rcc
tags: [tech]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "2d4"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "2d6"
ppe_base: "1d6"
horror_factor: 9
starting_money: "2d6x1000"
occ_restrictions:
  only: ["headhunter-techno-warrior", "headhunter-assassin", "headhunter-anti-robot-specialist", "headhunter-techno-hound", "merc-soldier", "city-rat", "cyber-doc", "operator", "preacher", "rogue-scholar", "techno-wizard", "vagabond"]
  note: "Optional: instead of the Trimadore Mechanic R.C.C. one of these O.C.C.s may be selected: Headhunter, Merc Soldier, City Rat, Cyber-Doc, Operator, Preacher, Rogue Scholar, Techno-Wizard, Vagabond (any) or similar O.C.C.s (the similar ones are the G.M.''s call)."
psionics:
  type: "major"
  isp_base: "2d4x10 + M.E., +2d4 per level"
  powers: ["Mind Block", "Object Read (Psychometry)", "Speed Reading", "Telemechanics"]
bonuses:
  combat: { initiative: 2, attacks: 1, roll: 2, pull_punch: 2 }
  saves: { disease: 1, toxins_poisons: 1, possession: 1, horror_factor: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American (adopted language)." }
    - { name: "Literacy: Native Language", base: 55, per_level: 5, note: "+15%; printed Literacy: Native Tongue: American." }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Mathematics: Advanced", base: 75, per_level: 5, note: "+30%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed Pilot Hover Vehicle (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot of choice (+10%)." }
    - { name: "Military Fortification", base: 40, per_level: 5, note: "+10%; printed Military Fortifications." }
    - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Computer Programming", base: 40, per_level: 5, note: "+10%" }
    - { name: "Electrical Engineer", base: 40, per_level: 5, note: "+10%" }
    - { name: "Mechanical Engineer", base: 40, per_level: 5, note: "+15%" }
    - { name: "Field Armorer & Munitions Expert", base: 60, per_level: 5, note: "Printed Field Armorer (+20%)." }
    - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
    - { name: "Salvage", base: 55, per_level: 5, note: "+20%" }
    - { name: "Sensory Equipment", base: 45, per_level: 5, note: "+15%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for one R.C.C. Related skill, or to Martial Arts (or Assassin if evil) for two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", bonus: 10 }
      - { name: "Mechanical", bonus: 15 }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Military", only: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater", "Trap Construction", "Trap/Mine Detection"], bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Computer Hacking"], bonus: 6 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    note: "Military: any, with +10% to all Demolitions and Trap skills only, which the second Military entry carries. Espionage and Wilderness are printed None and omitted."
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    note: "From the Secondary Skills List on page 300 of Rifts Ultimate Edition, at the base skill level; no bonuses other than a high I.Q."
equipment_starting:
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "multi-optics-band", qty: 1 }
  - { item_id: "sunglasses-or-tinted-visor", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-l5-northern-gun-laser-rifle", "ng-57-northern-gun-heavy-duty-ion-blaster"] }
natural_abilities:
  - { name: "Keen Senses", description: "Perfect 20/20 vision, good hearing and a keen sense of touch." }
  - { name: "Mechanical Aptitude", description: "An innate, near-savant knack for mechanics, electronics, building and jury-rigging." }
  - { name: "Long Reach", description: "The long arms give an extended reach (5-6 feet/1.5 to 1.8 m)." }
restrictions:
  - "The Mechanic R.C.C. skill list and the optional O.C.C. are alternatives: an O.C.C. taken instead replaces the R.C.C. skills; see extraction_notes."
  - "Clearly inhuman appearance can be a liability."
  - "Starting money: besides the 2D6x1,000 credits, the Mechanic starts with 2D6x1,000 credits worth of spare parts. With an O.C.C. taken instead, money and equipment are by that O.C.C."
  - "M.D.C.: by armor or other external means only."
  - "Magic: Techno-Wizardry only; other magic is not pursued."
  - "Bionics: avoids major reconstruction, but may take numerous implants and augmentation."
  - "Body armor is home-built from scrap, 50-100 M.D.C."
extraction_notes: "Followed Rifts World Book 11: Coalition War Campaign printed 208-209 until this update; moved to its 2007 reprint in Rifts World Book 30: D-Bees of North America printed 206-208 under the ruling of 2026-10-04 (the newest printing that states a figure wins, the older figure kept here). Both entries were read off page renders (D-Bees cache p207-p209, Coalition War Campaign cache p209-p210 and p225). || Unchanged between the two printings: attribute dice, hit points P.E. plus 1D6 per level, S.D.C. 2D6 plus physical-skill S.D.C. (no plus-O.C.C. clause; stored as sdc_base, so no men_of_arms line), P.P.E. 1D6, Horror Factor 9, the four powers and the I.S.P. line, the bonus line, the equipment list, the 50-100 M.D.C. home-built armor, and the Magic and Bionics lines. || Bonuses: the bonus and horror-factor lines are word for word the Vanguard Brawler''s in both books (+2 initiative, +1 attack, +2 roll, +2 pull punch, +1 vs disease and poison, +1 vs possession, horror factor +1 at 1, 2, 3, 4, 5, 6, 8, 10, 12, 14). Transcribed as printed; D-Bees printed 208 repeats them unchanged. || Psionics: D-Bees adds Considered a Major Psychic; Coalition War Campaign printed 208 gave only Limited with no tier, and the class was stored minor. Mind Block, Object Read, Speed Reading and Telemechanics granted; Telemechanics is a Super power in the catalog, granted by name. D-Bees prints I.S.P. costs beside them, Speed Reading as 92), a misprint for (2). || R.C.C. skills: catalog base plus printed bonus. D-Bees adds Jury-Rig (+20%), Salvage (+20%) and Sensory Equipment (+15%), which Coalition War Campaign printed 209 does not list. Languages: D-Bees prints Language: Native Tongue: American (adopted language) and Literacy: Native Tongue: American (+15%), stored as Language: Native Tongue and Literacy: Native Language; Coalition War Campaign printed 209 gave Speaks American and one language of choice (+20%) and Literate in Earth language of choice (+15%), which were stored as a Trimadore native tongue, two Language: Other picks and one Literacy: Other pick. D-Bees does not restate the language of choice or a Trimadore tongue. Field Armorer (Coalition War Campaign: Armorer) is Field Armorer & Munitions Expert, Pilot: Hover Vehicle is Hover Craft (ground), Military Fortifications is Military Fortification. || Related skills: D-Bees gives five plus two at 3, 6, 9, 12; Coalition War Campaign printed 209 gave six. Mechanical is +15% (Coalition War Campaign +10%). Military is Any (+10% to all Demolitions and Trap skills) where Coalition War Campaign gave Military: Any (+10%); stored as the plain category plus a second Military entry naming the three Demolitions rows and the two Trap rows at +10% (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Secondary: D-Bees gives four plus one at 4, 8, 12 from the Rifts Ultimate Edition list; Coalition War Campaign gave five, limited by the related any/only/none list. || Available O.C.C.s (optional): D-Bees names Headhunter, Merc Soldier, City Rat, Cyber-Doc, Operator, Preacher, Rogue Scholar, Techno-Wizard, Vagabond (any) or similar O.C.C.s; Coalition War Campaign printed 209 named Scholar, Cyber-Doc, Operator or Techno-Wizard. Stored as only; Headhunter is stored as the four Headhunter O.C.C.s; or similar O.C.C.s is left to the note. In both books the O.C.C. is taken instead of the Mechanic R.C.C. and its skill list; see the first restriction. || XP: D-Bees printed 207 says the Trimadore Mechanic uses the same Experience Table as the Operator, and the O.C.C.''s table when one is taken; xp_table is a copy of the stored operator ladder. Coalition War Campaign printed 224 printed a Trimadore Mechanic R.C.C. ladder shared with the Quick Flex Rogue: 0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 74801, 100901, 140001, 193101, 235201, 290401, 350601. || Money: D-Bees gives 2D6x1,000 credits and 2D6x1,000 credits worth of spare parts, otherwise by chosen O.C.C.; Coalition War Campaign printed 209 gave 2D4x1,000 credits or equivalent in stolen valuables as well as some basic supplies. The spare parts are a restrictions line, not coin. || Vulnerabilities: D-Bees prints Clearly inhuman appearance can be a liability; Coalition War Campaign printed 208 gave R.C.C. Penalties: clearly inhuman in appearance, making disguise impossible. D-Bees adds the 5-6 foot reach, and M.D.C. by armor or other external means (Coalition War Campaign: by armor only). || Equipment: home-built armor is the Personalized Light or Medium M.D.C. Body Armor row, the nearest in the catalog; the visor is the Sunglasses or Tinted Visor row; backpack or satchel is the backpack. The energy weapon of choice is stored as four catalog options. || Not carried into the body, which is kept as written from Coalition War Campaign: D-Bees gives alignments as Scrupulous (25%), Unprincipled (30%) or Anarchist (25%), says half of the under quarter million are in America and Canada, and adds a life span of 3D6+56 years and a slave market value of 5D6x1,000 credits."
---

## Lore

The Trimadore are tall, lanky D-bees with a long thick neck, a small head,
long thin limbs, two-fingered hands and wide feet. They are quiet, peaceful
tinkerers with an uncanny gift for electronics, mechanics and building:
always taking something apart to see how it works and putting it back
together, and wonderful at jury-rigging. Most build their own armor from
scrap. They make natural Operators and Techno-Wizards, and are also known as
Fixers. Fewer than a quarter million exist, perhaps under 100,000 on Earth.

## GM Notes

Any alignment, mostly anarchist or unprincipled. Seven to eight feet, 180
to 220 lbs. Most avoid combat. Their skill earns good money as Operators and
mechanical engineers. All are literate in at least one language besides
their own. Favorite weapons are lasers and multi-weapon systems.
',
       updated_at = datetime('now')
 WHERE class_id = 'trimadore'
   AND instr(markdown, 'Trap skills only; add that by hand.') > 0
   AND length(markdown) = 12069;

-- == psi-druid ==
UPDATE imported_classes
   SET markdown = '---
id: psi-druid
name: Psi-Druid
system: rifts
category: occ
tags: [healer, wilderness]
occ_group: psychic
men_of_arms: false
source_book: Rifts World Book 12: Psyscape p.59-62
xp_table: [0, 2061, 4161, 8521, 16901, 25601, 35901, 50501, 70901, 95501, 130901, 190501, 240901, 290501, 350901]
bonuses:
  combat: { roll: 2 }
  saves:
    harmful_drugs: 2
    toxins_poisons: 2
    disease: 2
    horror_factor: 3
    other: [ { label: "vs magic potions", bonus: 2 }, { label: "vs magic illnesses", bonus: 2 } ]
psionics:
  type: "master"
  isp_base: "1d6x10+15 + M.E. attribute number, +2D4+2 I.S.P. for each additional level of experience"
  powers:
    - "Psychic Diagnosis"
    - "Healing Touch"
    - "Psychic Surgery"
    - "Clairvoyance"
    - "Empathy"
    - "Mind Block"
    - "Psychic Omni-Sight"
  powers_starting: 4
  powers_starting_groups:
    - { count: 2, categories: ["Healing"], note: "Two of choice from Healing." }
    - { count: 2, categories: ["Sensitive"], note: "Two of choice from Sensitive." }
  categories_allowed: ["Healing", "Sensitive"]
  powers_schedule:
    - { level: 2, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 3, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 3, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 4, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 5, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 5, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 6, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 7, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 7, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 8, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 9, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 9, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 10, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 11, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 12, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 13, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 13, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 14, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 15, count: 2, categories: ["Healing", "Sensitive"] }
special_abilities:
  - name: "1. Weather Sense"
    description: "Opening himself to nature, the Psi-Druid senses temperature and barometric changes, humidity, frost, wind speed and direction, fog, and the likelihood of rain and dangerous storms (tornados, hurricanes, ley line storms, flash floods, snow storms), and predicts to within 10 minutes when they will arrive and roughly how severe they will be. He can also tell when weather is unnatural (magically induced). Predictions reach no more than 24 hours ahead, except an exceptionally powerful storm front, which he may sense 6D6+24 hours in advance. Base Skill: 70% +2% per level of experience. I.S.P. Cost: 3, plus 1D4 minutes of meditation."
  - name: "2. Dowsing"
    description: "A natural psychic divining rod. Fresh water within range is sensed instantly and automatically (no roll, no I.S.P.); pinpointing its exact location takes two consecutive successful skill rolls, and a successful roll also tells whether plants and ground are dry and roughly how long since the last rain. Base Skill: 60% +3% per level of experience. Range: 1000 feet (305 m) +200 feet (61 m) per level, doubled near ley lines and nexus points. Divining for other things: ley lines at half the dowsing skill; magnetic and/or dimensional disturbances, mineral deposits and powerful supernatural presences (one powerful being such as a godling or alien intelligence, or a gathering of many lesser ones) at a base skill of 18% +1% per level of experience."
  - name: "3. See Plant & Animal Auras"
    description: "Sees the aura of a plant or animal only (not humans, D-bees or objects, unless the character also has See Aura). The aura reveals: Earth-native or extraterrestrial (not which dimension); predator or not; healthy or sickly, young or old; growth/life cycle and whether an animal is pregnant; whether it is edible or poisonous to humans; intelligence band (plant, low animal I.Q. 1-4, high animal I.Q. 4-8, human-like 8-10); general experience level for D-bee plants and animals such as the Emirin and Kisent (low 1-3, medium 4-7, high 8+); the presence of magic (including magical or healing properties of plants, and magic-casting ability, without specifics); psychic abilities; high or low base P.P.E.; a possessing entity. Range: 60 feet (18.3 m) +10 feet (3 m) per level, and the subject must be visible. Duration: two melee rounds. I.S.P. Cost: 1. Saving Throw: none for plants or lower animals, standard for most animals; a mind block hides psychic abilities, P.P.E. level and supernatural possession."
  - name: "4. Heal Plant & Animal Life"
    description: "A healing touch for plants and animals only - never humans, D-bees or supernatural creatures. On a sentient creature such as the Emirin, or an animal wolf/mountain lion-sized or larger, it restores 2D6 hit points or S.D.C. and closes open wounds. On most small animals and plants it restores 20% of hit points and S.D.C. and cures cuts, bruises, pulled muscles, damaged feathers, skin conditions, blighted leaves, damaged bark and dried or damaged roots. Range: touch. Duration: instant, lasting effects. I.S.P. Cost varies by size: 2 small flower, plant or mouse-size animal; 5 shrub/bush or squirrel-size; 10 sapling, cat- to dog-sized animal or sentient plant; 20 young adult tree or deer- to bear-sized animal; 40 old tree (100+ years) or hippo-sized animal; 70 ancient tree (500+ years) or elephant-sized animal."
  - name: "5. Empathic Animal Friendship"
    description: "An automatic affinity with animals, similar to the Psi-Stalker''s. Domestic animals take to the character at once and try to please him. He can ride any horse or exotic mount, wild or tame (wild ones only bareback - they refuse saddle, leash or rope), at +10% to Horsemanship: Exotic, and gets +10% to applicable skills for working with domesticated animals. Wild animals, even predators and mutant or alien ones, treat him as a fellow woodland creature: they do not flee, birds do not take flight, and watchdogs and CS mutant animals do not raise an alarm, so animals give no warning of his approach. The Psi-Druid never uses this affinity to hunt, and hunts only out of necessity."
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { choose: 2, from: ["Language: Other"], bonus: 15, per_level: 5, note: "Languages: two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math +10%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { name: "Brewing", base: 35, per_level: 5, note: "+10% (the book points to Rifts New West)" }
    - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
    - { name: "Botany", base: 40, per_level: 5, note: "+15%" }
    - { name: "Sewing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 40, per_level: 4 }
    - { name: "Horsemanship: Exotic Animals", base: 40, per_level: 5, note: "+10% (the book points to Rifts New West)" }
    - { name: "Lore: Cattle & Animals", base: 40, per_level: 5, note: "Lore: Cattle/Animals +10% (the book points to Rifts New West)" }
    - { name: "Identify Plants & Fruit", base: 50, per_level: 5, note: "+25%" }
    - { name: "Preserve Food", base: 45, per_level: 5, note: "+20%" }
    - { name: "Cook", base: 55, per_level: 5, note: "+20%; professional quality" }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 50, per_level: 4, note: "+14%" }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. choice of Energy Pistol or Energy Rifle." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P. Archery or one ancient W.P. of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to Hand: Basic can be changed to Expert at a cost of one R.C.C. Related skill selection, or Martial Arts at a cost of two." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Cowboy"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Tracking (people)"] }
      - { name: "Horsemanship", bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", bonus: 5 }
      - { name: "Military", only: ["Camouflage", "Trap/Mine Detection"] }
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - { name: "Pilot", except: ["Military: Jet Fighters", "Military: Tanks & APCs", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Concealment"], bonus: 5 }
      - { name: "Rogue", only: ["Palming", "Ventriloquism"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Electrical: None. Rogue: Concealment (+5%), Palming and Ventriloquism only - the +5% is on Concealment alone, so Rogue is two entries. Pilot: any except military-type combat vehicles. Horsemanship is granted with the Wilderness bonus because the catalog files riding under its own category; the book has no Horsemanship line."
    schedule:
      - { level: 4, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
      - { level: 13, count: 2 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "From the R.C.C. Related list, limited the same way (any, only, none), without the bonuses."
equipment_starting:
  - { choose: 1, label: "light, usually non-environmental M.D.C. body armor", qty: 1, from: ["plastic-man-body-armor", "urban-warrior-body-armor", "huntsman-armor", "dog-pack-dpm-riot-armor"] }
  - { choose: 1, label: "extra wilderness-type clothing (buckskin, camouflage, etc.)", qty: 1, from: ["buckskin-clothing", "camouflage-fatigues"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-large-brim", qty: 1 }
  - { item_id: "hooded-cloak", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "cord", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 5 }
  - { item_id: "wooden-spike", qty: 6 }
  - { item_id: "hatchet", qty: 1 }
  - { item_id: "knife-small", qty: 1 }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "fishing-line-and-hooks", qty: 1 }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1 }
  - { item_id: "flint-steel", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { choose: 1, label: "sling or bow & arrows", qty: 1, from: ["sling", "short-bow", "long-bow"] }
  - { item_id: "wilk-s-winchester-40-82-rifle", qty: 1 }
  - { choose: 2, label: "ancient weapons of choice", qty: 1, from: ["short-sword", "long-sword", "broadsword", "short-spear", "long-spear", "hand-axe", "mace", "war-hammer", "flail", "morning-star", "quarterstaff"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle", "wr-15-wilderness-laser-rifle"] }
  - { item_id: "e-clip", qty: 4 }
starting_money: "6d6x100"
restrictions: ["No cybernetics"]
extraction_notes: |
  - Pages: heading and lore printed 59, Special R.C.C. Abilities printed 60-62, stat block printed 62 (cache p060-p063). Text checked against renders of printed 60-62; the cache matched.
  - XP: the Psi-Druid/Psi-Ghost/Darkhound ladder on printed 157, lower bounds as given in the batch brief.
  - GROUPING: men_of_arms false - the stat block is headed "The Psi-Druid Psychic R.C.C.", a psychic, not a man of arms. The book states no hit point, S.D.C. or P.P.E. formula, so none is stored.
  - ABILITY NUMBERING: the book numbers its Special R.C.C. Abilities 1-9; #1-5 are stored as special_abilities with the number kept in the name because the book refers to them by number. #6 (psionic powers) is the psionics block, #7 (I.S.P.) is isp_base, #8 (master psychic save 10+) is in GM Notes, #9 (R.C.C. bonuses) is bonuses.
  - BASE SKILLS: Weather Sense 70% +2%/level, Dowsing 60% +3%/level, divining for other resources 18% +1%/level, ley lines at half the dowsing skill (printed 61). They are stored in the ability descriptions; the schema has no percentage field for a class ability.
  - JUDGEMENT (printed 62): "A total of two additional abilities can be selected at subsequent levels of experience" is read as two more Healing or Sensitive powers at EACH level from 2 to 15, not two across the whole career. The alternative reading would give a Master Psychic two powers over fourteen levels. REVIEW if Nate reads it the other way.
  - PSIONICS: the seven named powers are granted outright. Mind Block is a Physical power and Psychic Omni-Sight a Super one; both are granted by name, which the category gate does not restrict. powers_starting counts only the four chosen (two Healing, two Sensitive). Super at 3, 5, 7, 9 and 13 is a second schedule entry at those levels.
  - BONUSES: +2 vs drugs, poisons and disease stored as harmful_drugs, toxins_poisons and disease. +2 vs magic potions and +2 vs magic illnesses are saves.other. +3 vs Horror Factor and +2 roll with impact stored unconditionally.
  - SKILLS: bases are catalog base plus the printed bonus. Basic Math is Mathematics: Basic 45+10. Horsemanship: Exotic is Horsemanship: Exotic Animals 30+10; ability #5 also names +10% to exotic horsemanship - read as the same bonus the skill list prints, and NOT added twice (REVIEW). Lore: Cattle/Animals is Lore: Cattle & Animals 30+10. Identify Plants & Fruits is Identify Plants & Fruit 25+25. Skin and Prepare Animal Hides is Skin & Prepare Animal Hides. Land Navigation 36+14 (the book prints +14%). Brewing is the plain Brewing row (Medical), not Brewing: Medicinal. No native language or literacy is printed and none was added.
  - RELATED: four, plus two at levels 4, 7, 10 and 13. Espionage Tracking is Tracking (people). Rogue Ventriloquism is a Technical row in the catalog; it resolves cross-category because the class grants Technical. The +5% on Concealment alone is a Rogue entry of its own naming Concealment only (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Pilot "any, except Military type combat vehicles" excludes the five Military:-prefixed Pilot rows; robot and power armor rows were left open because the book names only military vehicles. Horsemanship granted as a category (with the +10% Wilderness bonus) since the catalog files riding skills under their own category. Electrical none.
  - SECONDARY: five, plus one at levels 4, 8 and 12.
  - EQUIPMENT: not stored or approximated - snowshoes or skis (no row for snowshoes; ski rows exist now, skis-downhill and skis-cross-country, and the class does not list them), sewing kit with needles and thread (only row is the magic Needle of Sewing, not used), 2D4 magic herbs (see Rifts England; about thirty herb rows exist now, slugs starting herb-, and the class does not list them), the arrows that come with a bow (the choice holds the bow only), and "a couple pouches or sacks" as two small sacks. "Several tie cords" is one cord. 100 feet of rope is five 20-foot lengths. Waterproof matches is the lighter-or-matches row; flint and tinder are flint/steel plus a tinder box. The utility knife is Knife, Small. The conventional hunting rifle is Wilk''s Winchester 40-82. "Hat and/or hooded cloak" gives both. The book adds that Psi-Druids are not tech-savvy but may use Techno-Wizard devices and magic items.
  - VEHICLE: none to start.
  - MONEY: 6D6x100 credits stored. The 1D4x1000 credits in Black Market or trade items is goods, not coin, and is not stored.
  - CYBERNETICS: none; they interfere with psionics and are seen as unnatural. Stored as a restriction line.
  - Alignment any; attributes none required (high M.E. and P.E. suggested); race: humans 82%, Elves 8%, Ogres 3%, others 7%, either sex. No schema field for these; recorded here.
---

## Lore

Psi-Druids are Master Psychics whose bond with nature is psionic rather than magical, filling the role that mystic druids play elsewhere. They use empathy, aura sight, psychic diagnosis and a handful of unique nature powers to tend animals, crops and people. Most are peaceful healers, veterinarians, farmers and wilderness hermits who prefer animals to crowds. Rural communities prize them as healers and advisors and often court them with housing, pay and a seat on the town council. Many wander a regular circuit as traveling healers, and player characters are usually of that restless, road-loving kind.

## GM Notes

As a Master Psychic, the Psi-Druid needs a 10 or higher to save vs psionic attacks.

Level 2 onward: two more powers from Healing or Sensitive at each level, plus one Super-Psionic power at levels 3, 5, 7, 9 and 13.

Weather Sense needs 1D4 minutes of meditation before the roll. Dowsing''s range doubles near ley lines and nexus points. Empathic Animal Friendship''s +10% to skills for working with domesticated animals is situational and is not applied to any skill.

About a third of Psi-Druids are vegetarians, and all are distressed by an animal in trouble and will usually try to help it.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-druid'
   AND instr(markdown, 'the +5% is on Concealment alone and is not applied.') > 0
   AND length(markdown) = 18548;

-- == gypsy-wizard-thief ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-wizard-thief
men_of_arms: false
occ_group: magic
name: Gypsy Wizard Thief
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.181-182
category: occ
tags: [stealth]
xp_table: [0, 2701, 5401, 10801, 21601, 31601, 42801, 62001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]
attribute_requirements: { IQ: 10, ME: 12 }
ppe_base: "2d4x10 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "1d6x1000"
magic:
  type: "spell"
  spells: ["Blinding Flash", "Globe of Daylight", "See the Invisible", "Chameleon", "Concealment", "Detect Concealment", "Charismatic Aura", "Mask of Deceit", "Fool''s Gold", "Escape", "Energy Disruption", "Levitation", "Armor of Ithan", "Repel Animals", "Reduce Self (6 inches)", "Teleport: Lesser"]
  spells_starting: 4
  spell_levels_allowed: [1, 2, 3, 4]
bonuses:
  saves: { horror_factor: 2, spell_magic: 1 }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Lore: Demons & Monsters", base: 20, per_level: 5, note: "Printed as a flat (20%) with no plus sign, unlike every other bonus in this list. Read off a 200 dpi render of printed 182: it is the skill''s percentage, not a bonus, and it is five points BELOW the catalog base of 25." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 15, per_level: 5, note: "Printed as a flat (15%) with no plus sign. Same reading as the Lore above; the catalog base is 25." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Play Musical Instrument", base: 40, per_level: 5, note: "One of choice (+5%)" }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { name: "Language: Euro", base: 80, per_level: 5, note: "+30%" }
    - { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: select three of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
    - { name: "Pick Pockets", base: 30, per_level: 5, note: "+5%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts (or Assassin if evil) for the cost of three." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Acrobatics"] }
      - { name: "Pilot", bonus: 10, except: ["Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Tanks & APCs", "Jet Aircraft", "Military: Jet Fighters", "Boat: Ships", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10, note: "+10%, and +15% on literacy and languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15, note: "+15% on literacy and languages." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "Wilderness Survival is also named on the book''s Espionage line at +10%. It is a Wilderness skill in this catalog; the Espionage entry names it, so it takes that line''s +10% in place of this line''s +5%. BOOK-INGEST-AUDIT.md F9." }
    note: "Electrical, Mechanical and Military: none."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { choose: 1, label: "cloak or cape", qty: 1, from: ["hooded-cloak", "cloak-of-armor"] }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "scarf", qty: 2 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "knife", qty: 2 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { choose: 1, label: "wood or silver cross", qty: 1, from: ["wooden-cross", "small-silver-cross"] }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "note pad or sketch book", qty: 1, from: ["note-pad", "sketch-pad"] }
  - { item_id: "pen", qty: "1d4" }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
natural_abilities:
  - name: "Sense Ley Lines and Magic Energy"
    description: "Senses whether a ley line or nexus is nearby. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Read Ley Lines"
    description: "Instantly knows the direction, length, nexus locations and similar things about a ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Ley Line Transmission"
    description: "Sends a verbal and/or visual message along a ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Ley Line Phasing"
    description: "Instantly teleports from one place to another on the same ley line. Identical to the Ley Line Walker O.C.C.; see Rifts RPG printed 83."
  - name: "Not a Full Line Walker"
    description: "The wizard thief does NOT have the Ley Line Walker''s powers of line drifting, ley line rejuvenation or ley line observation ball. The book states the absence outright."
  - name: "Learning New Spells"
    description: "Additional spells and rituals of ANY magic level can be learned or purchased at any time, regardless of the character''s experience level - see the Pursuit of Magic, Rifts RPG printed 164. The wizard thief selects magic that aids him as a thief rather than mystic power: illusion, deception, confusion and concealment. He seldom even considers other areas of magic, because the art was passed down from father to son or daughter and is limited to what poppa could teach."
restrictions:
  - "Alignment: Unprincipled, Anarchist or evil. A thief cannot be of a good alignment."
  - "Only 50% of wizard thieves are literate in any language."
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels three, seven, ten and thirteen. Spell Strength is not a field the sheet holds."
  - "Cybernetics: starts with none and avoids them except for medical reasons. May consider bio-wizardry items."
extraction_notes: |
  - Triax and the NGR, printed 181-182. The second of the book''s four Gypsy
    O.C.C.s. A split-class - a thief first and a wizard second - which is why
    its experience ladder on printed 224 is its own rather than the Ley Line
    Walker''s.
  - THE TWO LORE SKILLS ARE FIXED PERCENTAGES, NOT BONUSES. Printed 182 gives
    "Lore: Demons & Monsters (20%)" and "Lore: Faeries (15%)" with NO plus
    sign, where every other entry in the same list carries one. Verified on a
    200 dpi render of the page rather than off the OCR, because the OCR is the
    same engine that would have dropped the sign. Both land BELOW the catalog
    base of 25, which is the tell that they are the book''s own numbers.
  - Lore: Faeries is stored as "Lore: Faeries & Creatures of Magic", the
    catalog''s name for that row.
  - THE ESPIONAGE LINE NAMES WILDERNESS SURVIVAL AT +10% AND THE WILDERNESS
    LINE PRINTS +5%. This catalog files Wilderness Survival under Wilderness,
    which this class grants, so the skill is reachable, and the Espionage entry
    names it, so it takes that line''s +10% rather than the Wilderness line''s
    +5%. BOOK-INGEST-AUDIT.md F9; stored this way 2026-10-14 under F138. The Gypsy Thief one entry
    earlier has the same two lines at the SAME percentage and loses nothing.
  - THE PILOT EXCLUSION LIST WILL ROT, for the reason recorded on the Gypsy
    Thief: `except` matches exact catalog names with no prefix form, so all
    twelve `Robot Combat Elite` rows are named individually and a thirteenth
    will be offered to this class unless it is added here.
  - SECONDARY SKILLS START AT ZERO AND THAT IS THE BOOK. Printed 182 says the
    character selects two secondary skills "at levels two, five, eight, and
    twelve" and names no level-one grant, where the Gypsy Thief two pages
    earlier says "at level one and one additional skill at levels four, seven,
    ten and thirteen". Three of this book''s four Gypsy O.C.C.s are written the
    later way. Read from the render, not inferred from the sibling class.
  - Initial spell knowledge is the sixteen named spells, granted outright, plus
    four more of the player''s choice from spell levels 1-4. All sixteen resolve
    in the catalog; "Reduce Self" is stored under its catalog name,
    "Reduce Self (6 inches)".
  - Money is 1D6x1000 credits. The entry also grants 3D4x1000 credits worth of
    jewelry, artifacts and other stolen goods, which `starting_money` cannot
    hold - it is coin only - so it is recorded in the body and here.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna (two scarves are stored; the catalog has no bandanna),
    the energy rifle or pistol, an unresolved choice this book''s batches record
    as prose rather than stub, and the robot horse and land
    buggy, two of the four vehicle options.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js): the entry
    prints no S.D.C. formula and this is a practitioner of magic.
---

# Gypsy Wizard Thief

## Lore

The wizard thief is fundamentally a ley line walker with an emphasis on magic that is useful in thievery. Unlike the traditional line walker, the wizard thief usually has much less understanding of magic and a narrower band of spell knowledge, because the character is a thief first and a wizard second.

The art of mystic thievery is traditionally passed down from father to son or daughter. Since the main interest is stealing, the focus of the magic is almost entirely aimed in that direction, and their spell knowledge reflects it: illusion, deception, confusion and concealment, limited to what poppa could teach. The wizard thief seldom even considers learning other areas of magic. The character progresses in experience at a slower pace than a line walker, because he is fundamentally a split-class and spends much of his training and attention on thievery and streetsmarts rather than magic.

## Equipment and Money

Standard issue beyond the stored equipment: an energy rifle or pistol, an unresolved choice; a bright coloured bandanna worn with the scarf; and T-40 "plain clothes" armour as the alternative to light mega-damage body armour.

Notable additional equipment a wizard thief may want to acquire: magic weapons, magic potions, magic equipment, scrolls, a vibro-blade, a laser scalpel, signal flares, smoke and tear gas grenades, a mini-tool kit, a multi-optics band, handcuffs, surveillance items, a pocket mirror, a pocket laser distancer, a pocket digital disc recorder for his observations, and a hand-held computer.

Money: 1D6x1000 credits, plus 3D4x1000 credits worth of jewelry, artifacts and other stolen goods. The gypsy enjoys the good life and spends his money quickly and freely.

All gypsies are snappy and stylish dressers, and their choice of garments reflects their boldness and bright personalities.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief'
   AND instr(markdown, 'the extra 5% the Espionage line prints for it cannot be stored.') > 0
   AND length(markdown) = 13108;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'saloon-bum' AND instr(markdown, 'only: ["Cardsharp", "Pick Pockets"], bonus: 10') > 0)
    OR (class_id = 'professional-gambler' AND instr(markdown, 'only: ["Play Musical Instrument", "Sing"], bonus: 15') > 0)
    OR (class_id = 'titan-juicer' AND instr(markdown, 'only: ["Prowl"], bonus: -5') > 0)
    OR (class_id = 'trapper-woodsman' AND instr(markdown, 'only: ["Whittling & Sculpting", "Breed Dogs"], bonus: 15') > 0)
    OR (class_id = 'trimadore' AND instr(markdown, '"Trap/Mine Detection"], bonus: 10') > 0)
    OR (class_id = 'psi-druid' AND instr(markdown, 'only: ["Concealment"], bonus: 5') > 0)
    OR (class_id = 'gypsy-wizard-thief' AND instr(markdown, '"Intelligence", "Wilderness Survival"], bonus: 10') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'saloon-bum' AND instr(markdown, 'add its +10% by hand.') > 0)
    OR (class_id = 'professional-gambler' AND instr(markdown, 'is filed under Communications in this catalog; add it by hand.') > 0)
    OR (class_id = 'titan-juicer' AND instr(markdown, 'cannot be negative for one skill') > 0)
    OR (class_id = 'trapper-woodsman' AND instr(markdown, 'add 5% by hand if either is taken') > 0)
    OR (class_id = 'trimadore' AND instr(markdown, 'Trap skills only; add that by hand.') > 0)
    OR (class_id = 'psi-druid' AND instr(markdown, 'the +5% is on Concealment alone and is not applied.') > 0)
    OR (class_id = 'gypsy-wizard-thief' AND instr(markdown, 'the extra 5% the Espionage line prints for it cannot be stored.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('saloon-bum', 'professional-gambler', 'titan-juicer', 'trapper-woodsman', 'trimadore', 'psi-druid', 'gypsy-wizard-thief') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~190-book-ingest-audit-f138-scoped-b.sql');
