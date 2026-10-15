-- BOOK-INGEST-AUDIT F140, Nate's four rulings: Malvoren may take Electricity Generation, Layer of Laws says it grants sixteen Lores, Norse Giant ability 01-05 adds 1D6x1000 M.D.C.
-- 3 classes, each replaced whole: malvoren, layer-of-laws, norse-giant.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~205-book-ingest-audit-f140-four-rulings.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == malvoren ==
UPDATE imported_classes
   SET markdown = '---
id: malvoren
name: Malvoren
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.138-142
category: rcc
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
tags: [combat, tech]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+2"
  MA: "2d6"
  PS: "4d6+10"
  PP: "3d6+4"
  PE: "3d6+4"
  PB: "2d4"
  Spd: "3d6+4"
hit_points_base: "P.E. x3, +2d6 per level"
sdc_base: "3d4x10+20"
ppe_base: "6d6x10 + P.E., +10 per level"
horror_factor: 10
starting_money: "6d6x1000"
psionics:
  type: "major"
  isp_base: "2d4x10 + M.E., +10 per level"
  powers: ["Telemechanics", "Telemechanic Paralysis", "Telemechanic Mental Operation"]
  powers_starting: 3
  powers_per_level: 3
  categories_allowed: ["Physical", "Sensitive"]
bonuses:
  combat: { attacks: 1, initiative: 3, strike: 1, parry: 2, dodge: 2, disarm: 3, entangle: 2, roll: 1 }
  saves: { disease: 2, toxins_poisons: 2, horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native tongue at 98%." }
    - { name: "Language: Trade Four", base: 80, per_level: 5, note: "+30%." }
    - { name: "Language: Techno-Can", base: 80, per_level: 5, note: "+30%." }
    - { name: "Literacy: Native Language", base: 40, per_level: 5, note: "Literacy: Native Tongue; no figure printed." }
    - { name: "Literacy: Techno-Can", base: 50, per_level: 5, note: "+20%." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literacy in Trade Four (+20%); the catalog has no Trade Four literacy row." }
    - { name: "Basic Electronics", base: 35, per_level: 5, note: "+5%." }
    - { name: "Bioware Mechanics", base: 30, per_level: 5 }
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "At 98%." }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "+20%." }
    - { name: "Mechanical Engineer", base: 25, per_level: 5, note: "Mechanical Engineering." }
    - { name: "Sensory Equipment", base: 35, per_level: 5, note: "+5%." }
    - { name: "Vehicle Armorer", base: 50, per_level: 5, note: "+20%." }
    - { name: "Weapon Systems", base: 55, per_level: 5, note: "+15%." }
    - { name: "Weapons Engineer", base: 75, per_level: 5, note: "+50%." }
    - { choose: 2, categories: ["Pilot"], note: "Pilot: two of choice." }
    - { choose: 6, categories: ["Weapon Proficiencies"], note: "W.P.: six of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "Hand to Hand: Martial Arts, or Assassin if evil; player''s choice." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Electrical", only: ["Electricity Generation", "Robot Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", bonus: -5 }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Chemistry", "Astrophysics"] }
      - { name: "Technical", only: ["Language: Other", "Computer Operation", "Computer Programming", "Jury-Rig"] }
      - { name: "Communications", only: ["Literacy: Other"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation"] }
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 9, count: 1 }]
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "field-radio", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "wilk-s-portable-laser-torch-tool", qty: 1, note: "The book says a portable laser-welding torch and names no maker." }
natural_abilities:
  - name: "Body of muscle cords"
    description: "No skin: a body of dark red muscle cords wrapped into humanoid form, with small black eyes that glow red then white in combat and no visible mouth, nose or ears. M.D.C. comes only from armor and machines melded into the body."
  - name: "Regeneration"
    description: "Regenerates 1D6 Hit Points or S.D.C. per minute and a lost limb within 72 hours. While melded with any weapon, armor or device it cannot be physically transformed by any means, even magic. Regains P.P.E. at 10 per hour of sleep or meditation, and cannot draw P.P.E. from any other source such as batteries, ley lines or other beings."
  - name: "Weapon mechanic"
    description: "Repairs, rebuilds and upgrades weapons, even ones not melded, in half the time an Operator needs. Work on non-combat machines takes at least twice as long and is poor quality."
special_abilities:
  - name: "Meld with Weapons"
    description: "Muscle tendrils fuse with a weapon, which is then used as if with a W.P. six levels above the character''s experience level, plus one extra attack per melee with it and +3 to strike; bonuses from melded telescopic, laser or other targeting systems also apply. Several melded weapons can be fire-linked to shoot together at one target as one melee attack. Takes one melee action; lasts until disconnected. P.P.E.: 5 per item."
  - name: "Meld with Weapon Systems"
    description: "Merges with weapon systems, targeting and combat computers, radar and sensor clusters and turrets in any power armor, robot, combat vehicle, ship, spacecraft or fortification, using it at full bonuses and a skill of 95%, plus +2 to strike. Takes 2 melee actions; lasts indefinitely. P.P.E.: 8."
  - name: "Meld with Armor"
    description: "Melds with body armor, cyborg armor, an exoskeleton or a patchwork of M.D.C. plating (6D6+52 M.D.C. as patchwork armor). Melded armor gains 20% damage capacity, fits like a glove, and halves its prowl, strike, parry, dodge and other penalties. Melded with a complete suit, P.S. becomes the equivalent of Robotic Strength and punches and kicks do Mega-Damage. Takes three melee actions; lasts indefinitely. P.P.E.: 10. Power armor counts as a war machine."
  - name: "Meld with Cybernetics"
    description: "Snaps on cybernetic and bionic parts with no surgery: organs, eyes, ears, limbs, weapons, extra arms or tentacles, even a vehicle or animal frame as a lower body. Each meld or un-meld does 1D6 S.D.C. and 1D4 Hit Points of damage; a full limb or torso frame does triple damage, takes triple the time and costs triple P.P.E., and un-melding one takes a full minute. Takes one melee round; lasts indefinitely. P.P.E.: 10."
  - name: "Power Weapons"
    description: "Charges or powers a melded weapon with P.P.E.: standard E-Clip 10 P.P.E., long E-Clip 15, canister or FSE-type cell 25, large backpack-sized cell 40; directly powering a weapon costs 1 P.P.E. per die of damage per shot or blast. Rail gun ammunition is made from the Malvoren''s own body: 10 P.P.E. and 1D6 S.D.C. or Hit Points per slug, or 20 P.P.E. and 3D6 S.D.C. or Hit Points per flechette or burst. Bullets, grenades and missiles cannot be made. A weapon melded with and powered by a Malvoren does full damage to any creature that can be harmed by magic or psionics, even one normally immune. Instant; a charge lasts until used."
  - name: "Heal and Repair Weapons and Armor"
    description: "Mends a melded weapon, armor or war machine with its own body and P.P.E.; cannot replace missing parts, and armor must have 20% of its capacity left. One melee attack per 10 M.D.C. or S.D.C. healed, permanent. Cost: 1 P.P.E. and 1 S.D.C. or Hit Point per S.D.C. restored, or 5 P.P.E. and 10 S.D.C. or Hit Points per M.D.C. restored. Melded items also heal 1D6 M.D.C. per hour in total between them, cybernetics first, then armor, then weapons."
  - name: "Meld with War Machines"
    description: "Becomes one with a power armor, tank or other combat vehicle, robot vehicle or fighter craft, with the equivalent of Pilot: Robot Combat Elite, Tanks, Fighter, Patrol Boat or the appropriate skill at four levels above the character''s experience level. Takes one full melee round; lasts indefinitely. P.P.E.: 15."
  - name: "Meld with Non-Combat Machines"
    description: "Rare and painful: 2D6 S.D.C. and 1D6 Hit Points of damage to meld and again to un-meld. Gives a basic understanding of how to operate or pilot the machine at level one proficiency. Takes one full melee round; lasts 1D6 minutes per level of experience. P.P.E.: 25."
  - name: "Un-Melding"
    description: "Un-melding from each item takes one melee action, except some cybernetics as above. P.P.E., S.D.C. and Hit Points spent on a meld are not recovered until the item is un-melded."
  - name: "Telemechanic psionics"
    description: "Telemechanics (10 I.S.P.), Telemechanic Paralysis (20) and Telemechanic Mental Operation (12) work only while melded with a weapon, armor or machine. On a weapon, suit of armor, or the sensors and power systems of a weapon or combat computer they cost half the I.S.P. and last twice as long; on a non-combat machine they cost twice the I.S.P. and last half as long."
trackable_resources: []
side_effects: "Poor natural vision that sees only in the ultraviolet and infrared spectrums, and poor hearing. Melding with too many items (more than 50% machine: four or more extra or replacement limbs plus four cybernetics, a cyborg torso plus four cybernetics, 12 or more cybernetic items, or more than 12 weapons plus cybernetics and armor, as the G.M. sees fit) costs the non-Telemechanic psionic powers and 50% of the base I.S.P. Horror Factor 10 applies only when one can tell what they are, none if sealed in environmental armor."
restrictions:
  - "Alignment: any, but typically Aberrant (40%), Scrupulous (30%) or Principled (10%); even the others tend to show some honor."
  - "Available O.C.C.s: none. A Malvoren does not choose an O.C.C. and relies on R.C.C. skills and natural abilities."
  - "Magic: none. No magic potential, cannot use Techno-Wizard items, and never picks up a magic weapon or melds with a TW device."
  - "Cybernetics and bionics: starts with up to 1D4 cybernetic implants and may have one bionic limb (additional or replacement) with up to two weapon systems, all melded rather than implanted."
  - "Equipment choices: any medium or heavy body armor or a light exoskeleton; three energy or heavy energy weapons of choice with three spare clips each, and two melee weapons; a heavy-duty truck, jeep, motorcycle or hovercycle."
  - "Related skill notes: Pilot +10% on combat vehicles. Not enforced."
extraction_notes: "WB30 D-Bees of North America printed 138-142 (cache p139-p143), read off 200 dpi renders; the P.P.E. line was re-read at 300 dpi. The heading Malvoren is on printed 138; lore runs to printed 139, where the stat block headed Malvoren R.C.C. - Optional Player Character or NPC starts, and it ends on printed 142. || CATEGORY: a race that is its own class; Available O.C.C.s: None is a restriction line with no occ_restrictions block (the armored-slayer precedent). || XP: the book says to use the Robot Pilot table. It was left out at import, per that import''s brief, and an xp_table is stored now. || POOLS: Hit Points P.E. attribute number x3 plus 2D6 per level. S.D.C. 3D4x10+20 is the class''s whole S.D.C., stated with no O.C.C. to add to, so it is sdc_base and no men_of_arms line is written. M.D.C. by armor and melded machines only. P.P.E. is printed 3D6x10 +P.E. attribute number +3D6x10, plus 10 per level; the two 3D6x10 terms sum exactly to 6D6x10, stored as 6d6x10 + P.E., because the pool roller reads only one dice term. Horror Factor 10, only when one can tell what they are. || PSIONICS: Considered a Major Psychic. I.S.P. 2D4x10 +M.E. attribute number, plus 10 per level. Telemechanics, Telemechanic Paralysis and Telemechanic Mental Operation granted by name (catalog Super rows); their melded-only use and cost changes are ability text. Three powers from Physical or Sensitive at each level of experience starting at level one is powers_starting 3 and powers_per_level 3 with categories_allowed Physical and Sensitive. || BONUSES: +1 attack, +3 initiative, +1 strike, +2 parry and dodge, +3 disarm, +2 entangle, +1 roll, +2 vs disease and poison (disease, toxins_poisons), +4 vs Horror Factor. Meld bonuses are conditional and ability text. || SKILLS: catalog base plus the printed bonus. Language: Native Tongue (Trade Four and Techno-Can at +30%) is read as the native tongue at 98 plus Trade Four and Techno-Can at 80. Literacy: Native Tongue (Trade Four and Techno-Can at +20%) is Literacy: Native Language at the catalog 40 (no figure printed), Literacy: Techno-Can 50, and a Literacy: Other pick at +20 for Trade Four (no such row). Mathematics: Basic at 98% is a flat 98. Mechanical Engineering is the catalog Mechanical Engineer. Pilot two and W.P. six of choice are choice groups. Hand to Hand: Martial Arts or Assassin if evil is a one-of-two choice; no upgrade price, so no hand_to_hand block. || RELATED: four at level one, plus one at levels 4, 8 and 12. Cowboy, Domestic and Medical: None are omitted. Electrical: Electrical Generation and Robot Electronics only; the book''s Electrical Generation is the catalog''s Electricity Generation, and both are stored (Nate''s ruling, 2026-10-12; BOOK-INGEST-AUDIT.md F140). Mechanical: Any (-5%) is bonus -5 as printed. Physical except Acrobatics. Science: Chemistry and Astrophysics only. Technical: Language, Literacy, Computer Operation, Computer Programming and Jury-Rig only: Language is Language: Other (Technical) and Literacy is Literacy: Other, filed under Communications, so it is a second Communications entry. Rouge: Any is read as Rogue. Pilot +10% on combat vehicles is a restriction line. || SECONDARY: four, plus two additional at levels 3 and 9, read as one at each of those levels. || EQUIPMENT: traveling clothes, binoculars, gas mask, sunglasses, canteen, tent, sleeping bag, utility belt, flashlight, radio (field-radio), backpack, survival knife, food rations and a quality tool kit (tool-kit). The portable laser-welding torch is granted since ~116 and ~117 as wilk-s-portable-laser-torch-tool (the book names no maker). NOT STORED, no catalog row: basic electrical tools and personal items. The vehicle, armor and weapons are choices with no named item, and the starting cybernetics are prose. || MONEY: 6D6x1,000 credits. || NOT STORED: size 7 feet 4 inches to 8 feet 8 inches, weight 270-330 pounds, life span 4D6+135 years, the Splugorth bounty of one million credits, slave market value, habitat, allies and enemies; in GM Notes."
---

## Lore

The Malvoren are a warrior race from somewhere in the Megaverse, so long on the
move that even they no longer remember a home world. They sell their services
to almost any war as bounty hunters, bodyguards, mercenaries and assassins, yet
most live by a strict code of honor: a worthy foe is met with equal weapons and
never cheated, while a foe without honor may be put down by any means at all.

A Malvoren has no skin. Its tall, powerful body is a bundle of dark red muscle
cords wrapped into human shape, with small black eyes that burn red and then
white in battle. Those cords can unwind and fuse with technology: guns, armor,
cybernetics, power armor and the weapon systems of vehicles all become part of
its living body, run at the speed of thought. Most go about sealed inside heavy
armor bristling with melded weapons, and are often taken for cyborgs or living
robots.

They love weapons, tinker with them constantly, and can repair and upgrade them
faster than any Operator, though non-combat machinery bores them. They cannot
use magic at all and scorn it as a kind of cheating, refusing even
Techno-Wizard devices. The Splugorth prize them as living weapon controllers
and pay a fortune for captives, so Malvoren hate the Splugorth and their
minions above all others and will gladly fight them, sometimes for less than
their usual fee.

## GM Notes

Experience: the entry names the Robot Pilot experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: honorable and trustworthy; they respect those who respect them.
Allies without honor are pitied and used; Malvoren without honor are a
disgrace.

Size 7 feet 4 inches to 8 feet 8 inches (2.2 to 2.6 m). Weight 270 to 330
pounds (122 to 149 kg). Life span 4D6+135 years.

Starting equipment the catalog has no row for: basic electrical tools and
personal items.

Slave market value: the Splugorth pay one million credits or the equivalent
in trade for a live Malvoren; other slavers pay 1D4x100,000 credits. Habitat:
anywhere, preferring high-tech war zones; on Rifts Earth mostly North America,
working for one mercenary company or another. Allies: anyone with courage,
honesty and honor, such as Cyber-Knights, Blucies, Kraks and Lyn-Srial, and
they know many dimension travelers. Enemies: the Splugorth, Sunaj and other
Minions of Splugorth above all; they also dislike Dirari Ecto-Men, Ganka,
Lanotaur Hunters, Loaks and anyone without honor.
',
       updated_at = datetime('now')
 WHERE class_id = 'malvoren'
   AND instr(markdown, 'Electrical Generation is also allowed but has no catalog row') > 0
   AND length(markdown) = 17366;

-- == layer-of-laws ==
UPDATE imported_classes
   SET markdown = '---
id: layer-of-laws
men_of_arms: false
name: Layer of Laws
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.152-154
category: occ
tags: [scholar, leader]
occ_group: optional
xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]
attribute_requirements: { IQ: 9, ME: 13 }
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 30, note: "The book grants ''Basic & Advanced Math (+30%)'' as one line; both rows are granted." }
    - { name: "Mathematics: Advanced", bonus: 30, note: "The other half of that line." }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "Speaks the secret Gypsy language at 98% - a FIFTH pricing of this language in the book, and the only one at native fluency. The Thief and Fortune Teller start at 63%, the Wizard-Thief takes +10%, the Seer +6% and The Gifted One +9%." }
    - { name: "Literacy: Gypsy", base: 91, per_level: 0, note: "Literate in the COMPLETE Gypsy language at 91%. This class is the reason that row exists: every other Gypsy O.C.C. in the book is largely illiterate, and the Elder is the keeper of records." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 15, note: "Literate in one language of choice (+15%)" }
    - { name: "Language: Euro", bonus: 20, note: "Part of ''Speaks Euro, Russian and two others of choice (+20%)''." }
    - { name: "Language: Russian", bonus: 20, note: "The second named language of that line." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "The ''two others of choice (+20%)'' half." }
    - { name: "Cook", bonus: 20, note: "Cook (+20%)" }
    - { name: "Horsemanship: General", note: "Horsemanship: General" }
    - { name: "Animal Husbandry", bonus: 10, note: "Animal Husbandry (+10%)" }
    - { name: "Holistic Medicine", bonus: 10, note: "Holistic Medicine (+10%). The book repeats its note here: with the Game Master''s approval this skill can include the Herbalist/Herbology skill from Rifts World Book Three: England." }
    - { name: "Land Navigation", bonus: 15, note: "Land Navigation (+15%)" }
    - { name: "Astronomy", bonus: 5, note: "Astronomy (+5%)" }
    - { name: "Botany", bonus: 5, note: "Botany (+5%)" }
    - { name: "Law", bonus: 20, note: "Law (+20%)" }
    - { name: "Interrogation", bonus: 10, note: "Interrogation (+10%)" }
    - { name: "Palming", bonus: 10, note: "Palming (+10%)" }
    - { name: "Pick Locks", bonus: 5, note: "Pick Locks (+5%)" }
    - { name: "Cardsharp", bonus: 10, note: "The book prints ''Card Sharp (+10%)''; the catalog row is Cardsharp." }
    - { name: "Lore: American Indians", note: "The book grants ''Knows all Lores''. These sixteen Lore rows are granted, not every Lore row in the catalog, by Nate''s ruling of 2026-10-12 (BOOK-INGEST-AUDIT.md F140); see restrictions for the three-favourites bonus and for why the list spans game lines." }
    - { name: "Lore: Astral" }
    - { name: "Lore: Cattle & Animals" }
    - { name: "Lore: D-Bee" }
    - { name: "Lore: Demons & Monsters" }
    - { name: "Lore: Dimensions" }
    - { name: "Lore: Faeries & Creatures of Magic" }
    - { name: "Lore: Galactic/Alien" }
    - { name: "Lore: Juicers" }
    - { name: "Lore: Magic" }
    - { name: "Lore: Nightbane" }
    - { name: "Lore: Nightlands" }
    - { name: "Lore: Psychics & Psionics" }
    - { name: "Lore: Religion" }
    - { name: "Lore: Vampires" }
    - { name: "Lore: Wormwood" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, one of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapon, one of choice (any)." }
    - { name: "Hand to Hand: Basic", note: "Basic, and NO OTHER IS AVAILABLE - the book says so outright. This class cannot buy up to Expert, Martial Arts or Assassin, which no other class in the book is denied." }
  occ_related_skills:
    count: 3
    categories:
      - { name: "Communications", only: ["Radio: Basic"], note: "Radio: Basic only." }
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence only (+10%)" }
      - "Medical"
      - { name: "Physical", except: ["Boxing", "Wrestling", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "+5%" }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 0
    schedule: []
special_abilities:
  - name: "Starts at fourth level"
    description: "PLAYER CHARACTERS START AT 4TH LEVEL and are at least 50 years of age. The book states it outright, and no other class in this book does. Nothing in the class schema sets a starting level, so it is recorded here: a Layer of Laws character should be created at level four, not one."
  - name: "Old age"
    description: "Reduce P.S., P.P., P.B. and Spd by 20% for old age. A PERCENTAGE penalty on four attributes, which the bonuses block cannot express - it takes whole numbers, and 20% of a rolled attribute is not known until the attribute is rolled."
  - name: "Keeper of secrets, knowledge and lore"
    description: "An Elder who leads a band, or one of the wise men and counsellors of a clan - male or female, about evenly split. Settles disputes, passes judgement, metes out justice, enforces Gypsy law and tradition, advises the band and keeps its records, often in his or her own head. Also excellent story-tellers and terrible gossips with their noses in everybody''s business."
restrictions:
  - "Also known as the Wise Elder, and Good Mother or Good Father. Any alignment, but most are unprincipled, anarchist or aberrant."
  - "RACIAL RESTRICTION: 100% HUMAN, with a Gypsy lineage traceable back at least four generations and often much further. The strictest racial requirement in the book."
  - "PLAYER CHARACTERS START AT 4TH LEVEL and are at least 50 years old."
  - "Reduce P.S., P.P., P.B. and Spd by 20% for old age."
  - "HAND TO HAND: BASIC AND NO OTHER IS AVAILABLE. This class cannot train up to Expert, Martial Arts or Assassin at any price, which is unique in this book."
  - "SECONDARY SKILLS: NONE. Not none at level one - none at all, at any level. The only class in the book with no secondary skills whatsoever."
  - "The book grants ''Knows all Lores (three favorites are +10%)''. Sixteen Lore rows are granted at base; THE THREE FAVOURITES CANNOT BE EXPRESSED, because nothing lets a class say ''choose three of the skills you were just granted and add 10% to those''. A player should pick three and add the bonus by hand."
  - "The book says all Lores. The class grants sixteen of the catalog''s Lore rows, Nightbane, Nightlands and Wormwood among them, and not the rest: the sixteen were kept rather than widened to every Lore row or trimmed to the plausible ones (Nate''s ruling, 2026-10-12; BOOK-INGEST-AUDIT.md F140). A Game Master may allow another Lore, or trim these."
  - "The character also starts with 3D6x1000 credits'' worth of trade goods, over and above the coin in starting_money. That field is coin only, and the book prices the coin in credits OR RUBLES."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.152-154. THREE THINGS THIS CLASS DOES THAT NO OTHER IN THE BOOK DOES, and none of the three has a field. It STARTS AT FOURTH LEVEL - ''Player Characters start out at 4th level and are at least 50 years of age'' - and nothing in the class schema sets a starting level. It takes a PERCENTAGE penalty for age, -20% to P.S., P.P., P.B. and Spd, which a bonuses block cannot hold because it takes whole numbers and 20% of a rolled attribute is unknown until the roll. And it gets NO SECONDARY SKILLS AT ALL, at any level, where every other class gets some. All three are restrictions. `Literacy: Gypsy` is CREATED at 91/+0, the figure the book prints - this class is the reason it exists, since every other Gypsy O.C.C. here is largely illiterate and the Elder is the keeper of records. `Language: Gypsy` appears at 98%, a FIFTH pricing of that language in one book. ''Knows all Lores'': sixteen Lore rows are granted, some from game lines this book has nothing to do with. The catalog holds more Lore rows than that, and the sixteen were kept rather than widened to all of them, by Nate''s ruling of 2026-10-12 (BOOK-INGEST-AUDIT.md F140). The three-favourites +10% cannot be expressed - nothing lets a class say ''choose three of the skills you were just granted and raise those''."
---

# Layer of Laws

## Lore

The Layer of Laws is an Elder: the leader of a band, or one of the wise men and
counsellors of a clan. They settle disputes, pass judgement, mete out justice,
enforce Gypsy law and tradition, advise their people and keep the records -
often in their own heads. They are also excellent story-tellers and terrible
gossips, with their noses in everybody''s business.

They know a little about a great many things and are seldom arrogant about it,
except to gadje. Many look like kindly old grandparents. Most are still sharp as
a whip: quick thinking, astonishingly fast talkers, convincing liars and master
thieves, slowed by age but worldly, confident and entirely capable.

## Alignment

Any, but most are unprincipled, anarchist or aberrant.

## GM Notes

Three things make this class unlike anything else in the book, and all three are
easy to miss because none of them is a number the sheet can hold:

**It starts at fourth level.** The book says so outright, and the character is
at least fifty years old.

**Age costs it 20% of P.S., P.P., P.B. and Spd.**

**It has no secondary skills at all** ' || char(8212) || ' not none at first level, none ever ' || char(8212) || ' and
its Hand to Hand is Basic with no option to improve, at any price. What it has
instead is sixteen Lore skills, literacy in a language almost no other
Gypsy can read, and the Law.
',
       updated_at = datetime('now')
 WHERE class_id = 'layer-of-laws'
   AND instr(markdown, 'every Lore skill in existence') > 0
   AND length(markdown) = 10028;

-- == norse-giant ==
UPDATE imported_classes
   SET markdown = '---
id: norse-giant
name: Greater Norse Giant
system: rifts
source_book: pantheons-of-the-megaverse p.163-166
category: rcc
tags: [supernatural]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
attribute_dice:
  IQ: "4d4"
  ME: "3d6"
  MA: "3d6"
  PS: "6d6+20"
  PP: "4d6+2"
  PE: "4d6+3"
  Spd: "6d6+10"
mdc_base: "2D6x100 plus 10 per level of experience"
ppe_base: "2d6x10"
occ_restrictions:
  only: ["combat-cyborg", "crazy", "cyber-knight", "glitter-boy", "headhunter-techno-warrior", "merc-soldier", "robot-pilot", "witch", "warlock-air", "warlock-earth", "warlock-fire", "warlock-water", "warlock-air-earth", "warlock-air-fire", "warlock-air-water", "warlock-earth-fire", "warlock-earth-water", "warlock-fire-water", "ley-line-walker"]
  note: "80% are warriors - any man of arms EXCEPT Coalition or NGR military. The other 20% study magic, limited to witch, warlock, necromancer or ley line walker; the catalog holds two Necromancer O.C.C.s now (necromancer and necromancer-russian) and this list names neither. The Warlock is ten classes here, one per Elemental Force and one per pair (RETRO-AUDIT R3, 2026-09-04), and all ten are open to a norse giant because the book restricts being a Warlock rather than which Force."
bonuses:
  combat: { initiative: 2 }
  saves: { horror_factor: 4 }
natural_abilities:
  - { name: "Nightvision", description: "60 ft (18.3 m); can see in total darkness." }
  - { name: "Resistant to cold or heat", description: "Half damage - cold for a frost giant, heat for a fire giant." }
  - { name: "Bio-regeneration", description: "1D4x10 M.D.C. per minute." }
special_abilities:
  - name: "Ability (01-05): Additional M.D.C."
    description: "Roll 01-05 or choose. An additional 1D6x1000 M.D.C., or 2D4x100 S.D.C. in a non-mega-damage world."
    bonuses: { pools: { mdc: "1d6x1000" } }
  - name: "Ability (06-10): Great Nightvision"
    description: "Roll 06-10 or choose. Nightvision to 1000 ft (305 m)."
  - name: "Ability (11-15): Turn Invisible at Will"
    description: "Roll 11-15 or choose. Turn invisible at will."
  - name: "Ability (16-20): Impervious to Heat and Fire"
    description: "Roll 16-20 or choose. Impervious to heat and fire."
  - name: "Ability (21-24): Fangs and Poisonous Bite"
    description: "Roll 21-24 or choose. 3D6 damage per melee for 1D6 rounds."
  - name: "Ability (25-30): Change Size at Will"
    description: "Roll 25-30 or choose. Change size at will, from 6 to 40 feet (1.8 to 12.2 m)."
  - name: "Ability (31-33): Pair of Tentacles"
    description: "Roll 31-33 or choose. +1 attack per melee and +1 to parry."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Ability (34-40): Giant''s Strength"
    description: "Roll 34-40 or choose. Add 10 to the P.S. attribute."
    bonuses: { attributes: { PS: 10 } }
  - name: "Ability (41-45): Thick, Lumpy Skin"
    description: "Roll 41-45 or choose. Add 1D4x100 M.D.C., or S.D.C. in a non-mega-damage world."
    bonuses: { pools: { mdc: "1d4x100" } }
  - name: "Ability (46-50): Pair of Additional Arms"
    description: "Roll 46-50 or choose. +2 attacks per melee and +2 to parry."
    bonuses: { combat: { attacks: 2, parry: 2 } }
  - name: "Ability (51-54): Additional Eye"
    description: "Roll 51-54 or choose. Hawk-like vision and see the invisible."
  - name: "Ability (55-59): Prehensile Tail"
    description: "Roll 55-59 or choose. Adds one attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Ability (60-64): Battle-Hardened"
    description: "Roll 60-64 or choose. +2 on initiative, +2 to roll (the page prints only "roll"; stored as roll with punch, fall or impact), +4 to save vs horror factor."
    bonuses: { combat: { initiative: 2, roll: 2 }, saves: { horror_factor: 4 } }
  - name: "Ability (65-69): Great Speed"
    description: "Roll 65-69 or choose. Add 1D4x10 to the Spd attribute."
    bonuses: { attributes: { Spd: "1d4x10" } }
  - name: "Ability (70-75): Metamorphosis into Animal"
    description: "Roll 70-75 or choose. Metamorphosis into an animal at will."
  - name: "Ability (76-80): Retractable Claws"
    description: "Roll 76-80 or choose. Add 2D6 to all hand to hand attacks."
  - name: "Ability (81-84): Increased Healing"
    description: "Roll 81-84 or choose. Regenerates 1D4x100 M.D.C. per minute."
  - name: "Ability (85-90): Create Fire Ball"
    description: "Roll 85-90 or choose. Once per melee round at will. Range 1000 feet (305 m), does 1D4x10 M.D."
  - name: "Ability (91-95): Create Lightning Bolt"
    description: "Roll 91-95 or choose. Once per melee round at will. Range 1000 feet (305 m), does 6D6 M.D."
  - name: "Ability (96-00): Third Monstrous Eye and Ugly Head"
    description: "Roll 96-00 or choose. Psionic with ALL sensitive powers and six super-psionic powers of choice."
    psionics: { type: "master" }
  - { rolls: 3, from: ["Ability (01-05): Additional M.D.C.", "Ability (06-10): Great Nightvision", "Ability (11-15): Turn Invisible at Will", "Ability (16-20): Impervious to Heat and Fire", "Ability (21-24): Fangs and Poisonous Bite", "Ability (25-30): Change Size at Will", "Ability (31-33): Pair of Tentacles", "Ability (34-40): Giant''s Strength", "Ability (41-45): Thick, Lumpy Skin", "Ability (46-50): Pair of Additional Arms", "Ability (51-54): Additional Eye", "Ability (55-59): Prehensile Tail", "Ability (60-64): Battle-Hardened", "Ability (65-69): Great Speed", "Ability (70-75): Metamorphosis into Animal", "Ability (76-80): Retractable Claws", "Ability (81-84): Increased Healing", "Ability (85-90): Create Fire Ball", "Ability (91-95): Create Lightning Bolt", "Ability (96-00): Third Monstrous Eye and Ugly Head"], note: "Special/Natural abilities (printed 163): the page says to roll for (or the G.M. picks) three random abilities, or pick three. It does not say what a repeated result means." }
  - { choose: 1, from: ["Insanity (01-15): No Insanity", "Insanity (16-40): Phobia", "Insanity (41-70): Obsession", "Insanity (71-80): Neurosis", "Insanity (81-90): Psychosis", "Insanity (91-00): Affective Disorder"], note: "Insanity (printed 163): the page says to roll one time." }
  - name: "Insanity (01-15): No Insanity"
    description: "Roll 01-15. No insanity."
  - name: "Insanity (16-40): Phobia"
    description: "Roll 16-40. A phobia. The page prints only the category; which phobia is rolled by hand on the phobia table of the Rifts RPG insanity rules."
  - name: "Insanity (41-70): Obsession"
    description: "Roll 41-70. An obsession. The page prints only the category; which obsession is rolled by hand on the obsession table of the Rifts RPG insanity rules."
  - name: "Insanity (71-80): Neurosis"
    description: "Roll 71-80. A neurosis. The page prints only the category; which neurosis is rolled by hand on the neurosis table of the Rifts RPG insanity rules."
  - name: "Insanity (81-90): Psychosis"
    description: "Roll 81-90. A psychosis. The page prints only the category; which psychosis is rolled by hand on the psychosis table of the Rifts RPG insanity rules."
  - name: "Insanity (91-00): Affective Disorder"
    description: "Roll 91-00. An affective disorder. The page prints only the category; which one is rolled by hand on the affective disorder table of the Rifts RPG insanity rules."
restrictions:
  - "Alignment: any, but leans towards anarchist and evil. A Norse giant of a scrupulous or principled alignment is likely to be thought untrustworthy and a freak, and probably tormented as well."
  - "Horror Factor: 10+1D6."
  - "Attacks per melee: two without any combat training, or two plus those gained from hand to hand combat and/or boxing."
  - "The +4 to save vs horror factor does NOT apply when dealing with Thor. No bonus then."
  - "Some greater giants are the equivalent of gods, at 3D6x1000 M.D.C., but they are rare - perhaps one in ten thousand - and serve as the warrior lords and leaders of the other giants. Not a player character."
  - "Insanity: roll one time on the giant''s insanity table (printed 163), which is the pick-one Insanity group under special_abilities."
  - "Size is 1D4x10 feet (3 to 12.2 m). Changing size is one of the special powers rather than something every giant can do."
  - "Occupations: 80% are warriors - any men of arms other than Coalition or NGR type military - and 20% study magic, limited to witch, warlock, necromancer or ley line walker. The CS and NGR exclusion is prose because the format cannot express an exception inside an `only` list."
side_effects: "The giants of Norse myth were more than overly large humanoids. The Old Norse word for them was iotnar, which means demon or monster: supernatural creatures whose powers were almost the match of the gods, many with shape shifting and magical powers. Average life span 2000+ years. The LESSER Norse giants are the Algor frost giants, Nimro fire giants, Jotan earth giants and Gigantes described in Rifts Conversion Book One; this entry is the greater giants, who are far more powerful."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.163 with
  scripts/read-columns.py. Text layer; printed 163 is cache p164 (page_offset 1).

  Five things worth recording:

  1. THE BOOK PRINTS NO P.B. It lists I.Q., M.E., M.A., P.S., P.P., P.E. and
     Spd and simply stops. That is the page, not a dropped line - checked
     against the raw text. No P.B. die is invented here, so the attribute is
     left for the G.M. to set.
  2. NO SKILLS OF ANY KIND, and that is correct rather than missing. The giant
     takes an O.C.C. and every skill comes from there - the pure
     race-plus-occupation case, the same as the Demigod.
  3. "Experience: Use same table as the Dragon R.C.C." The dragon ladder is stored,
     copied 2026-09-26 from dragon-hatchling, which has carried RUE''s since #1415.
     The import stored none, because that row then stored none and both fell
     through to DEFAULT_XP_TABLE in js/leveling.js; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.
     A correction to the dragon ladder has to be copied here by hand.
  4. The twenty special abilities are the book''s random table, kept in its
     printed order. The book says "Roll for (or GM pick) three random
     abilities or pick three", so it is a `rolls: 3` group of twenty
     band-named options, `Ability (NN-NN): ...`, which can be rolled or
     picked (2026-10-05, BOOK-INGEST-AUDIT.md F120; before that a choose-three
     whose names carried no band). All twenty bands were read off the render
     of printed 163: 01-05, 06-10, 11-15, 16-20, 21-24, 25-30, 31-33, 34-40,
     41-45, 46-50, 51-54, 55-59, 60-64, 65-69, 70-75, 76-80, 81-84, 85-90,
     91-95, 96-00 - 01-00 with no gap or overlap. The page says nothing about
     a repeated result, and the group''s note says so.
  5. "Psionics: Standard" means NO psionics block at all, which is the opposite
     of what it looks like. Declaring a tier would fix the giant at that tier
     and stop him rolling on the Random Psionics Table; staying silent is what
     lets the roll happen, and "standard" is the roll. Same reading the Demigod
     already records. Ability 96-00 is the exception and carries `psionics:
     master` on itself, where it belongs, rather than on the class.

  TWO ABILITY ROWS WERE RULED ON (Nate, 2026-10-12; BOOK-INGEST-AUDIT.md
  F140). Row 96-00 prints "Psionic with all sensitive powers and six super
  psionic powers of choice" and names no tier; `master` stays. Row 01-05
  prints "An additional 1D6x1000 M.D.C. (or 2D4x100 S.D.C.)", read off the
  render of printed 163; it carries an M.D.C. pool bonus of 1d6x1000, in the
  shape row 41-45 uses, and the S.D.C. alternative for a non-mega-damage
  world stays in its description, as 41-45''s does.

  THE OCCUPATION LIST IS ENUMERATED, AND IT IS THE ONE PLACE THIS CLASS COULD
  GO STALE. The book says "any men of arms OTHER THAN CS or NGR type military",
  and a `group:` token cannot carve out an exception - `only:
  ["group:men-of-arms"]` would have admitted coalition-grunt,
  coalition-samas-pilot and coalition-technical-officer, which is the exact
  thing the sentence excludes. So the seven non-Coalition men of arms are
  listed by id, checked against production, and a Rifts man of arms imported
  later will need adding here by hand. That is a real cost and it is the
  cheaper of the two errors.

  JUICER IS LEFT OUT although it is a man of arms, because the other direction
  already refuses it. `race_restrictions` closes the Juicer - along with the
  Dog Boy, both Psi-Stalkers and the three Coalition classes - to every Rifts
  race, human only, and that rule reaches this class the moment it exists.
  Listing it here would have been a permission that silently does nothing: the
  wizard would offer it and the pairing would be refused. Same smell as a
  restriction that silently does nothing, pointed the other way.

  combat-cyborg and crazy ARE left available. The book does not repeat the
  Demigod''s rule that those treatments fail on a supernatural being, and
  nothing in the catalog closes them, so both directions agree. Odd for a
  2D6x100 M.D.C. creature, and deliberate: this entry says men of arms and
  stops.

  NECROMANCER IS OMITTED FROM THE LIST, and the omission is the interesting
  part. The book allows witch, warlock, necromancer or ley line walker; this
  catalog held no Necromancer O.C.C. when the list was drafted. Two exist now,
  `necromancer` (Rifts World Book 4: Africa) and `necromancer-russian` (Mystic
  Russia), and the list still names neither. A dangling name in an `only` list is
  harmless on its own - it never matches, so the occupation stays unavailable
  for the honest reason that it does not exist - but `occ_restrictions` is held
  to a stricter rule than skill restrictions are: regression asserts that every
  occupation a race names is a real O.C.C., because in an `except` list the
  same dangling name silently ALLOWS what it meant to forbid. One rule for both
  list kinds is the right trade, so the name comes out and the note records
  what to add when a Necromancer O.C.C. exists. The other three were checked
  against production.

  THE INSANITY TABLE IS A PICK-ONE GROUP (2026-10-05, BOOK-INGEST-AUDIT.md
  F120). Printed 163 (file p164, folio checked on the render) prints, after
  the twenty abilities, "Insanity (roll one time)" and six rows: 01-15 no
  insanity, 16-40 phobia, 41-70 obsession, 71-80 neurosis, 81-90 psychosis,
  91-00 affective disorder - 01-00 with no gap or overlap. Stored as one
  `choose: 1` group of six band-named Insanity options, one definition per
  row, beside the three-ability group. The restrictions
  line that carried the bands is now a pointer. Each row names a category
  only, so which phobia, obsession, neurosis, psychosis or affective disorder
  it is stays a hand roll on the Rifts RPG''s tables, said in each row. No row
  prints a number, so no option carries bonuses.
---

## Lore

The giants of Norse myth were more than overly large humanoids. The Old Norse
word used to name them was *iotnar* - demon, or monster. These were
supernatural creatures whose powers were almost the match of the gods, and many
of them had shape shifting and magical powers of their own.

Their abilities are quite varied, which is why no two greater giants are alike.
The lesser Norse giants - the Algor frost giants, Nimro fire giants, Jotan earth
giants and the Gigantes - are described in Rifts Conversion Book One. These are
the greater giants, and they are far more powerful.

A giant of a scrupulous or principled alignment is a freak among his own kind:
untrustworthy in their eyes, and likely tormented for it.

## GM Notes

Two things to hold onto. The first is that a greater giant is a walking
exception - the twenty-entry ability table means the giant the players meet may
be able to do something no other giant they have met could, and the book means
that. Roll, or pick to fit the story.

The second is Thor. The giant''s +4 to save vs horror factor is void when he is
dealing with Thor, and that single line is the whole relationship between this
race and the Aesir: they are frightened of him specifically. It is worth playing.

The rare god-equivalent giants at 3D6x1000 M.D.C. are warrior lords, roughly one
in ten thousand, and are not player characters.
',
       updated_at = datetime('now')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, 'So the eight non-Coalition men of arms') > 0
   AND length(markdown) = 15897;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 3 classes carry their new text' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'malvoren' AND instr(markdown, 'only: ["Electricity Generation", "Robot Electronics"]') > 0)
    OR (class_id = 'layer-of-laws' AND instr(markdown, 'These sixteen Lore rows are granted, not every Lore row in the catalog') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'bonuses: { pools: { mdc: "1d6x1000" } }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'malvoren' AND instr(markdown, 'Electrical Generation is also allowed but has no catalog row') > 0)
    OR (class_id = 'layer-of-laws' AND instr(markdown, 'every Lore skill in existence') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'So the eight non-Coalition men of arms') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('malvoren', 'layer-of-laws', 'norse-giant') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~205-book-ingest-audit-f140-four-rulings.sql');
