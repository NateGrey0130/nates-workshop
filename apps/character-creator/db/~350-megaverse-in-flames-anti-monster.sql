-- Bring the Anti-Monster to its Megaverse in Flames reprint
-- 1 class, each replaced whole: anti-monster.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~350-megaverse-in-flames-anti-monster.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Rifts World Book 35: Megaverse in Flames reprints the Anti-Monster O.C.C.
-- (printed 185-188) as the South America class, updated. This brings the held
-- class (Rifts World Book 6: South America p.34-37) to the reprint where it
-- differs, and re-cites it: spells four times a day at a 5th level Ley Line
-- Walker (was three, at a 5th level wizard), weight 400-800 lbs, alignment
-- percentages, the ley line range on Sense Psychic and Magic Energy, the
-- identify list on Sense Supernatural Beings, the Rifts Ultimate Edition page
-- references, Cowboy and Horsemanship among the related skills, the H2H upgrade
-- paid with an O.C.C. Related skill, and the cross, stakes, mallet and
-- flashlight in the equipment. Each South America figure is kept in the
-- class's extraction_notes. Nothing else changes: id, experience ladder,
-- M.D.C., P.P.E., attributes, bonuses, money and cybernetics read the same.

-- == anti-monster ==
UPDATE imported_classes
   SET markdown = '---
id: anti-monster
occ_group: men-of-arms
name: Anti-Monster
system: rifts
source_book: Rifts World Book 35: Megaverse in Flames p.185-188
category: occ
tags: [combat, hunter, augmented]
xp_table: [0, 2601, 5001, 9001, 18001, 25001, 35001, 60001, 85001, 100001, 150001, 200001, 270001, 370001, 470001]
attribute_dice:
  MA: "1d6+19"
  PS: "2d6+28"
  PP: "1d6+19"
  PE: "2d6+18"
  PB: "2d4"
  Spd: "3d4x10"
mdc_base: "1d6x10+400"
ppe_base: "1d4"
horror_factor: "2D4+6"
starting_money: "1d6x1000"
bonuses:
  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 4, roll: 2 }
  saves: { spell_magic: 3, psionics: 3, horror_factor: 5 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: [{ name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }], bonus: 10, note: "Piloting: any one, except robots and power armor (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: two of choice (+20%). Taken once per language." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints Demon and Monster Lore." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts, or Assassin if an evil alignment, for the cost of one O.C.C. Related skill." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Cowboy"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"], bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Cowboy: any. Horsemanship: any (+5%). Military: none. Medical: First Aid and Paramedic only, and Paramedic counts as two skills. Physical: any except Acrobatics. Pilot: any except robot and power armor."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Cowboy"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "suit of medium or heavy M.D.C. armor", qty: 1, from: ["personalized-light-or-medium-mdc-body-armor", "gladiator-body-armor", "crusader-body-armor", "ca-1-heavy-dead-boy-armor", "cyborg-body-armor-light-undercover", "cyborg-body-armor-light-infiltration", "cyborg-body-armor-light-infantry", "cyborg-body-armor-heavy-infantry", "cyborg-battle-armor-light", "cyborg-battle-armor-medium", "cyborg-battle-armor-heavy", "ca-6c-cyborg-armor", "ca-6ex-exoskeleton-armor"], note: "Printed 188 (WB6 37) says medium or heavy M.D.C. armor, or any suit of cyborg armor, including Heavy Infantry Armor (420 M.D.C.). The first four are the catalog''s medium and heavy armour set; every Rifts cyborg armour row follows. The catalog''s Heavy Infantry row is Japan''s at 240 M.D.C.; no row holds the 420 M.D.C. suit the page names." }
  - { choose: 2, label: "energy weapons of choice", qty: 1, from: ["rc-10-laser-pistol", "rc-15-laser-rifle", "dragon-1-plasma-projector", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"], note: "The book says two energy weapons of choice without enumerating; the Colombian RC-10, RC-15 and Dragon-1 from South America lead the catalog set." }
  - { choose: 3, label: "hand to hand or archaic weapons of choice", qty: 1, from: ["broadsword", "axe-battle", "axe-throwing", "bo-staff", "club-stick-pipe", "arab-mace", "cross-bow", "beaked-axe", "vibro-knife"], note: "The book says three other hand to hand or archaic weapons of choice without enumerating; this is the catalog set." }
  - { item_id: "small-silver-cross", qty: 1, note: "A silver cross; the page gives no size." }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: 20, note: "20 wooden stakes and a mallet." }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "flashlight", qty: 1, note: "Plus a few personal items." }
psionics:
  type: "major"
magic:
  type: "spell"
  spells: ["Blinding Flash", "Globe of Daylight", "Chameleon", "Armor of Ithan", "Magic Net", "Shadow Meld"]
trackable_resources:
  - { key: blinding-flash, label: "Blinding Flash", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
  - { key: globe-of-daylight, label: "Globe of Daylight", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
  - { key: chameleon, label: "Chameleon", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
  - { key: armor-of-ithan, label: "Armor of Ithan", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
  - { key: magic-net, label: "Magic Net", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
  - { key: shadow-meld, label: "Shadow Meld", max: 4, reset_on: day, note: "Built-in spell, cast at the strength of a 5th level Ley Line Walker; no P.P.E. spent." }
special_abilities:
  - name: "M.D.C. Transformation"
    description: "A magical flesh-and-metal creature of 1D6x10+400 M.D.C. Regenerates 4D6 M.D.C. per minute (1D6 per melee). The metal parts are alive and heal on their own."
  - name: "Burned-Out P.P.E. and I.S.P."
    description: "The inner energies are spent in the transformation: P.P.E. and I.S.P. drop to 1D4 each, and neither can be tapped in any way - not by the Anti-Monster, by magic practitioners, or by Mind Bleeders."
  - name: "Supernatural Attributes"
    description: "M.A. 19+1D6, P.S. 28+2D6 (supernatural), P.P. 19+1D6, P.E. 18+2D6 (supernatural), P.B. 2D4 and Spd 3D4x10. The other attributes are rolled normally for the race of origin. Hand to hand Mega-Damage follows the supernatural P.S. table (Rifts Ultimate Edition p.285). Against vampires the blows inflict Hit Point damage: 1D4 restrained, 2D6 full strength, 4D6 power punch (counts as two attacks), plus the P.S. damage bonus (+13 or greater)."
  - name: "Supernatural Powers"
    description: "Unaffected by normal (non-M.D.C.) heat, cold and weapons. Does not eat or breathe, and can survive indefinitely in space, underwater or buried alive. Mega-Damage heat, fire, plasma and cold do half damage; lasers, particle beams, ion blasts, electricity, M.D. explosions, psionics and magic do full damage. Impervious to poisons, drugs and magic potions. Immune to the vampire''s mind control bite (but not its killing bite) and cannot be turned into a vampire."
  - name: "Built-in Spells"
    description: "Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net and Shadow Meld, each castable up to four times per 24 hours at the spell strength of a 5th level Ley Line Walker, needing no P.P.E. No further spells are ever gained and these never increase in level. Can use Rune weapons, scrolls, and Techno-Wizard devices or magic, but not magic potions, salves or ointments."
  - name: "Sense Psychic and Magic Energy"
    description: "Works like the Psi-Stalker''s ability but less developed: constantly and automatically senses psionic energy and P.P.E. directed at spells, circles, Techno-Wizardry and magic items, and things like Blood Pillars, Blood Pools, Soulmancy devices and Hell Pits. Range 50 feet (15.2 m), tripled along ley lines."
  - name: "Sense Supernatural Beings"
    description: "Senses the distinctive psychic scent of the supernatural at 60% +2% per level. Identifying the specific type of creature - demons, Deevils, vampires, Soulmancers and Blood Warriors included - is 58% +2% per level."
  - name: "No Psionic Powers"
    description: "All psychic potential is burned out, but the character saves vs psionics as a major psionic (12 or higher)."
  - name: "Initiative Against Undead"
    description: "+4 to initiative against ghouls, vampires and all forms of undead, in place of the usual +2."
  - name: "Cybernetics"
    description: "Mystical bionic lungs, retractable claws or retractable forearm vibro-blades, and 1D4+1 cybernetic implants of the player''s choice, all built in during the transformation. None can be added afterwards. Each implant adds 3% to the chance of rejection."
  - { choose: 1, from: ["Obsession (01-20): Destroying the Undead", "Obsession (21-40): Destroying Evil Supernatural Beings", "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods", "Obsession (61-80): Random Obsession", "Obsession (81-00): One of the Above and a Random Obsession", "Obsession: None"], note: "Insanities (printed 36): the page says 80% of all Anti-Monsters develop an Obsession, and to roll or pick one. It prints no roll for the 80% itself; an Anti-Monster the G.M. rules is among the rest takes Obsession: None, which the Roll button never lands on." }
  - name: "Obsession: None"
    description: "For an Anti-Monster outside the 80% the page says develop an Obsession. Nothing is rolled."
  - name: "Obsession (01-20): Destroying the Undead"
    description: "Roll 01-20 or pick. Obsessed with destroying vampires, ghouls, necromancers and every form of undead."
  - name: "Obsession (21-40): Destroying Evil Supernatural Beings"
    description: "Roll 21-40 or pick. Obsessed with destroying all evil supernatural beings, demons and Deevils included. Dislikes and distrusts any supernatural being, even one of good alignment, and has little liking for creatures of magic or for men of magic who summon or control the supernatural."
  - name: "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods"
    description: "Roll 41-60 or pick. Obsessed with protecting humans and innocent D-bees against evil and manipulative gods and their minions - Soulmancers, Blood Warriors, dark priests, acolytes, shamans, warlocks and witches included."
  - name: "Obsession (61-80): Random Obsession"
    description: "Roll 61-80. The book sends the player to the random Insanity table in Rifts Ultimate Edition, page 332; roll there by hand and record the result. That table is not stored here."
  - name: "Obsession (81-00): One of the Above and a Random Obsession"
    description: "Roll 81-00. Pick one of the obsessions above (the book''s wording; record which in the character''s notes) AND roll one additional random obsession on the Rifts Ultimate Edition table, page 332, by hand."
restrictions:
  - "Can never gain further spells, and the built-in spells never increase in level."
  - "Cannot use magic potions, salves or ointments."
  - "Cannot receive cybernetics or bionics after the transformation."
side_effects: "Inhuman appearance: a towering metallic brute, 7 feet (2.1 m) tall and 400-800 lbs (180 to 360 kg), Horror Factor 2D4+6. Takes DOUBLE damage from rune weapons, Wormwood crystal magic, and Millennium Tree wands, staves and weapons, good or evil. -20% to all Prowl rolls. REJECTION: after 1D4 years there is a 5% chance (+3% per cybernetic implant) that the body rejects the magical grafts, calling for an immediate save vs Coma/Death at -15%. Even on a success the character is crippled for 1D6 months (-7 to strike, parry and dodge, attacks and speed halved), then recovers to -2 on all combat bonuses with speed and attacks reduced by 25%. The rejection chance recurs 1D6 years later and again 2D4 years after the second crisis; after the third the character is safe and returns to full strength. Few survive more than 15 years of active duty. LOSS OF HUMANITY: forgets human needs such as rest, sleep and food; about 50% grow impatient with human frailty and 90% seem cold, brutal and merciless, especially against monsters. INSANITY: 80% develop an Obsession, rolled or picked once from the Obsession group in the special abilities - 01-20 destroying vampires, ghouls, necromancers and all undead; 21-40 destroying all evil supernatural beings, demons and Deevils included, distrusting even good ones; 41-60 protecting humans and innocent D-bees from evil gods and their minions (Soulmancers, Blood Warriors, dark priests, acolytes, shamans, warlocks and witches); 61-80 roll on the random Insanity table in Rifts Ultimate Edition p.332; 81-00 pick one of the above and roll one additional random obsession."
extraction_notes: "Megaverse in Flames printed 185-188 (cache p186-p189; printed 187 is art), headed as the South America class reprinted and updated; re-cited 2026-11-18 from WB6 printed 34-37 (cache p035-p038), and the notes below that cite a WB6 page are the original import. || SOUTH AMERICA READING (WB6), where this printing differs: spells three times a day at a 5th level wizard (now four, at a 5th level Ley Line Walker); weight 400 lbs (180 kg) (now 400-800 lbs, 180 to 360 kg); alignment usually scrupulous, selfish or aberrant (now Scrupulous 30%, Unprincipled 30%, Anarchist 15%, Aberrant 15%); sense psychic range 50 feet with no ley line multiple (now tripled along ley lines); identify supernatural covers demons, vampires and dragons (now demons, Deevils, vampires, Soulmancers and Blood Warriors); obsession 61-80 rolls on the Rifts RPG p.20 table (now the Rifts Ultimate Edition p.332 Insanity table); supernatural P.S. damage per Conversion Book One p.22 (now Rifts Ultimate Edition p.285); no Cowboy or Horsemanship related skills (now Cowboy any, Horsemanship any +5%); H2H upgrade for one other skill (now one O.C.C. Related skill); equipment without the crosses, stakes, mallet and flashlight; no salves in the potion restriction. Every other figure reads the same in both printings. || SECONDARY SKILLS: WB6 limits secondary picks to the related list; this printing states no list, so the WB6 limit stands over this printing''s list, Cowboy and Horsemanship included, without the bonuses. || EQUIPMENT ADDED: the silver cross is the catalog Small Silver Cross (the page gives no size); the few personal items are prose. || XP: the reprint prints no table; the Anti-Monster and Amazon ladder, WB6 printed 168, lower bounds 0 / 2,601 / 5,001 / 9,001 / 18,001 / 25,001 / 35,001 / 60,001 / 85,001 / 100,001 / 150,001 / 200,001 / 270,001 / 370,001 / 470,001, stored as printed. || GROUP: the book files no O.C.C. under a group heading - it sits in the Republic of Colombia chapter after the vehicles. Stored as men-of-arms: a combat cyborg built to hunt monsters, whose built-in spells are fixed and never grow; it is not a spell caster by training. mdc_base is stated, so no men_of_arms line. || NOT supersedes_race. The book says the other attributes are rolled normally for the race of origin, so the character keeps its race; the six supernatural attributes, the M.D.C. body and the burned-out P.P.E./I.S.P. are stored as attribute_dice, mdc_base and ppe_base, which a race stating its own will override in a pairing. For a human (no R.C.C.) they apply as printed. This is a judgement call and the one to revisit if a D-bee Anti-Monster comes out with the wrong body. || P.S. is supernatural; attribute_dice holds 2d6+28 and the supernatural damage table is prose. P.B. 2D4 is stored as printed (the book lowers it). || SPELL USES: WB6''s introduction said four times per 24 hours and its ability 5 said three, and the three was stored; this printing says FOUR in both places, so trackable_resources stores max 4, reset daily, one per spell. All six are existing general invocations (Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net, Shadow Meld); granted by name, no spells_starting. Casting level fixed at 5th is prose. || PSIONICS: no powers; stored as type major with no picks, because the book makes the character a major psionic for save purposes (12 or higher). Printed 36 drops P.P.E. and I.S.P. to 1D4 each and says neither can be tapped; ppe_base carries the 1D4 and isp_base is left unstated, so the I.S.P. figure is recorded here only (regression also refuses a class whose two pool formulas are the same string, the shape of a copying error). || BONUSES: +2 initiative, +1 strike/parry/dodge, +4 pull punch, +2 roll, +3 save vs magic, +3 vs psionics, +5 vs horror factor stored unconditionally. The +4 initiative vs undead is conditional and is prose. Imperviousness to poison, drugs and potions is total immunity, left in prose rather than a save bonus. || horror_factor stored as the printed phrase 2D4+6. || SKILLS: Radio: Basic 45+10; Wilderness Survival 30+10; Demon and Monster Lore is the catalog Lore: Demons & Monsters 25+15; Language two of choice +20 as two Language: Other picks. The book prints no Native Tongue line and none was added. Hand to Hand: Expert changes to Martial Arts or Assassin (evil) for one other skill each. Paramedic counting as two skills is a note, not enforced. Military: none, so the category is omitted. Secondary skills carry the same limits without the bonuses, as the book directs. || EQUIPMENT: armor, two energy weapons and three hand to hand or archaic weapons are all of choice; each is a choice from a catalog set. The book''s Heavy Infantry Armor (420 M.D.C.) cyborg armor has no catalog row and is not stubbed; the catalog''s nine Rifts cyborg armour rows joined the armour choice on 2026-11-09 (BOOK-INGEST-AUDIT.md F140). Cybernetics (bionic lungs, claws or forearm vibro-blades, 1D4+1 implants) are prose. || Rejection, loss of humanity and the vulnerabilities are side_effects. || OBSESSION TABLE (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 36, item 4 Insanities, prints a percentile table of its own - 80% of all Anti-Monsters develop an Obsession, roll or pick one - in five bands, 01-20, 21-40, 41-60, 61-80 and 81-00, which cover 01-00 with no gap or overlap. It is rolled once, at creation, and the page gives no later roll, so it is stored as one pick-one group of five band-named options (Obsession (NN-NN): ...), one definition each. No row prints a number, so no option carries bonuses. The 80% gate is in the group note: the one-in-five character with no obsession takes the group''s unbanded Obsession: None option, which the roll never lands on. 61-80 sends the player to the random table on Rifts RPG p.20 and 81-00 asks for one of the rows above plus one random obsession; both stay as the row prose and are rolled by hand. side_effects keeps its summary of the five bands and now points at the group."
---

## Lore

The Anti-Monster is a mystic cyborg, the product of an advanced and secret
trans-dimensional techno-wizardry found on Earth only in the Republic of
Colombia. Captured Anti-Monsters have been studied by others, Atlantis
included, and nobody has managed to reproduce the process; some suspect a god
or supernatural intelligence is behind it, others a link to the Holy Terrors of
Wormwood or to Doctor Articulus''s home dimension.

A candidate must have some magic or psionic ability. Most of the bone and
organs are replaced with techno-wizard bionics during a long ritual that
consumes nearly all of the candidate''s P.P.E. and I.S.P. to bind flesh and
machine; afterwards the metal parts are alive and heal themselves. The result
is a supernatural warrior able to devastate vampires, demons and creatures of
magic, with a handful of spells built into the body.

Vampires and monsters see Anti-Monsters as their deadliest enemies, while many
humans and D-bees fear the cold, inhuman giants. They are tragic heroes who
defend a world that does not fully accept them, and an evil Anti-Monster
serving the supernatural is extremely rare.

## GM Notes

Alignment: any, but usually Scrupulous (30%), Unprincipled (30%), Anarchist (15%) or
Aberrant (15%). There are no
attribute requirements beyond a willingness to become inhuman and some prior
magic or minor psionic ability. Few survive more than fifteen years of active
duty, and the rejection crises (see side effects) are the GM''s to roll.
',
       updated_at = datetime('now')
 WHERE class_id = 'anti-monster'
   AND instr(markdown, 'each castable up to three times per 24 hours at the strength of a 5th level wizard') > 0
   AND length(markdown) = 19884;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'anti-monster' AND instr(markdown, 'each castable up to four times per 24 hours at the spell strength of a 5th level Ley Line Walker') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'anti-monster' AND instr(markdown, 'each castable up to three times per 24 hours at the strength of a 5th level wizard') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('anti-monster') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~350-megaverse-in-flames-anti-monster.sql');
