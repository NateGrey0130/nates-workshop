-- BOOK-INGEST-AUDIT F140: settle the unsettled sentences on six D-Bees of North America classes
-- 6 classes, each replaced whole: fingertooth-carpetbagger, lyvorrk, flooper, shaper, vintex-warrior, worldly-sasquatch.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~206-book-ingest-audit-f140-dbees.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == fingertooth-carpetbagger ==
UPDATE imported_classes
   SET markdown = '---
id: fingertooth-carpetbagger
name: Fingertooth Carpetbagger
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.85-87
category: rcc
tags: []
attribute_dice:
  IQ: "2d4+7"
  ME: "2d4+7"
  MA: "3d4+9"
  PS: "3d4+11"
  PP: "2d4+5"
  PE: "3d4+9"
  PB: "2d4"
  Spd: "2d4+5"
mdc_base: "P.E. + 11, +2d4 per level"
ppe_base: "3d4"
horror_factor: 9
occ_restrictions:
  only: ["rogue-scholar", "vagabond", "city-rat", "saddle-tramp", "saloon-bum", "professional-gambler", "saloon-girl"]
  note: "Limited to Rogue Scholar, Vagabond (any, but especially Merchant/Salesman), City Rat, Smuggler, Con Artist, Saddle Tramp, Saloon Bum/Stoolie, Professional Gambler and Saloon Girl/Barmaid. Never takes a Magic O.C.C."
bonuses:
  combat: { perception: 1, initiative: 1, dodge: 2, roll: 1, pull_punch: 1 }
  saves: { toxins_poisons: 2, harmful_drugs: 2, disease: 7, psionics: 4, possession: 6, mind_control: 6 }
skills:
  occ_skills:
    - { name: "Appraise Goods", base: 50, per_level: 5, note: "R.C.C. skill, +20%." }
    - { name: "Barter", base: 50, per_level: 4, note: "R.C.C. skill, +20%." }
    - { name: "Cardsharp", base: 29, per_level: 4, note: "R.C.C. skill, +5%." }
    - { name: "Find Contraband", base: 40, per_level: 4, note: "R.C.C. skill, +14%." }
    - { name: "Gambling (Standard)", base: 40, per_level: 5, note: "Printed as Gambling (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two Language: Other of choice (+20%). Taken once per language." }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "R.C.C. skill, +25%." }
    - { name: "Public Speaking", base: 45, per_level: 5, note: "R.C.C. skill, +15%." }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "R.C.C. skill, +20%." }
equipment_starting:
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "mechanical-pencil", qty: "1d4" }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "sack", qty: "1d4+1" }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "marker", qty: "1d4", note: "Printed as 1D4 mechanical pencils and markers; the count is read as applying to each." }
  - { item_id: "carpetbag-large", qty: 1 }
  - { item_id: "mechanical-pencil-lead-24-in-a-pack", qty: 1, note: "Printed as 1D4x10 refills for the pencils; the row is a pack of 24 leads, so one pack is stored." }
natural_abilities:
  - name: "Minor Mega-Damage being"
    description: "M.D.C. equal to the P.E. attribute number +11, plus 2D4 M.D.C. per level of experience. Seldom wears armor."
  - name: "Augmented strength"
    description: "P.S. equal to Augmented/Bionic strength, like a Juicer or cyborg. A Power Punch may inflict M.D. but counts as two melee attacks."
  - name: "Senses and constitution"
    description: "Nightvision 90 feet (27.2 m) and a strong constitution; a high tolerance for alcohol."
  - name: "Superior Vision and Eye Filters"
    description: "Superior color vision and polarized vision: bright lights and glare do not affect it, and Blinding Flash has half the penalties and half the duration. A transparent protective eye-filter slides over the eyes in harsh environments against grit, dust, sand and pollution."
  - name: "Psionic resistance"
    description: "Not psychic, but resistant: +4 to save vs psionic attack (and vs helpful and healing psionics). Psionic communication (Telepathy, Empathy and the like) has half the range on it, and healing and other helpful psionic powers, Healing Touch included, have half the usual effect."
trackable_resources: []
restrictions:
  - "Alignment: any, but leans toward Scrupulous, Unprincipled and Anarchist."
  - "Psionics: none, but exhibits psionic resistance. Magic: none; never takes a Magic O.C.C."
  - "R.C.C. skills take the place of ALL the Secondary Skills the chosen O.C.C. would normally give; take no O.C.C. Secondary Skills. Not applied by the picker."
  - "Vulnerability: gullible and a bit greedy at the promise of a big score."
  - "Cybernetics and Bionics: avoids them when possible, but may get bionic reconstruction for medical reasons."
  - "Standard equipment: as per O.C.C., plus 1D4 decks of unopened playing cards, a pocket watch, small note pad, 1D4 mechanical pencils and markers with 1D4x10 refills, language translator, audio recorder, 1D4 bottles of alcohol (good for trade), 1D6x10 hard sweet candies, portable tool kit, canteen, a large carpetbag, a large duffle bag, 1D4+1 medium sacks, a bedroll, a backpack and some personal items."
  - "Money: as per O.C.C., plus an additional 2D4x1,000 in tradeable goods or information."
extraction_notes: "D-Bees of North America printed 85-87 (cache p086-p088, cache page = printed + 1), every number read off 200 dpi renders. The entry runs onto printed 87, ending at its closing Note above the Floopers heading. Tag line: Fingertooth Carpetbagger - Optional Player Character or NPC. || CATEGORY: a race that takes an O.C.C.; the book prints no experience table for it, so no xp_table (use the chosen O.C.C.''s). || M.D.C.: P.E. attribute number +11 plus 2D4 per level, stored as mdc_base; no men_of_arms line. || HORROR FACTOR 9 at first encounter, none once someone knows the race; stored as 9. P.P.E. 3D4. || BONUSES: +1 Perception, +1 initiative, +2 dodge, +1 roll, +1 pull punch; +2 to save vs poison, spoiled food, drugs and alcohol stored as toxins_poisons 2 and harmful_drugs 2; +7 vs disease; +4 vs psionic attack stored as psionics 4 (the book adds that the bonus also resists helpful and healing psionics, which is ability text); +6 vs possession and mind control. || SKILLS: catalog base plus printed bonus: Appraise Goods 30+20, Barter 30+20, Cardsharp 24+5, Find Contraband 26+14, Gambling stored as Gambling (Standard) 30+10, two Language: Other at +20 as a choice group, Mathematics: Basic 45+25, Public Speaking 30+15, Recognize Weapon Quality 25+20. The book says these replace all of the O.C.C.''s Secondary Skills; that is a restriction line and is not applied (Nate''s ruling of 2026-10-15; BOOK-INGEST-AUDIT.md F140). || OCCUPATIONS: Rogue Scholar, Vagabond, City Rat, Saddle Tramp, Saloon Bum, Professional Gambler and Saloon Girl are stored. Smuggler and Con Artist have no class in the catalog and are not stored. || EQUIPMENT: stored by catalog slug: note pad, 1D4 mechanical pencils, language translator (portable-language-translator), audio recorder (pocket-digital-disc-recorder), portable tool kit, canteen, duffle bag, 1D4+1 sacks for the medium sacks, sleeping-bag for the bedroll, backpack. No catalog row exists for playing cards or a pocket watch, and the bottles of alcohol and the hard candies have no Rifts row (BOOK-INGEST-AUDIT.md F140); they are in the equipment restriction line. The 1D4x10 pencil refills are granted as one mechanical-pencil-lead-24-in-a-pack, the printed count in its note. Granted since ~116 and ~117: the large carpetbag as carpetbag-large, and 1D4 markers as marker (the printed 1D4 is read as applying to pencils and markers each). Money: as per O.C.C.; the extra 2D4x1,000 is trade goods or information, not coin, so no starting_money. || NOT STORED: size, weight, life span, habitat, slave value, allies, enemies and the Phoo-Too pet''s stats are in GM Notes."
---

## Lore

The Fingertooth take their name from the pair of pincer-like appendages
that jut from the upper lip like two little fingers. They are short,
pear-shaped and pot-bellied, pale green or yellow with dark speckles on
head and belly, with big bulbous brown eyes and patches of fine fuzz. A wide
mouth full of pointed teeth sits in a permanent grin that strangers tend to
find more alarming than friendly.

Every Fingertooth is a born salesman with a knack for languages and a gift
for talk, and dreams of becoming a dimension-spanning arms dealer like the
Naruni. In practice they are closer to a cheerful used-goods huckster,
always pitching a deal, a tip or the chance of a lifetime in return for a
cut. They look rumpled whatever they wear, prefer flannel and jeans to
finery, often go barefoot, and travel with a bag or two of whatever they are
selling slung over a shoulder.

For all the hustle they are honest, fair and good-natured, and many will
give their last credit to someone down on their luck. Though they look
comical, they are minor Mega-Damage beings and surprisingly strong for
their size.

## GM Notes

Also known as the Two-Finger D-Bee. Size 4-5 feet (1.2 to 1.5 m). Weight
130-200 pounds (58.5 to 90 kg). Life span 3D4+57 years; mature at 15.
Females bear 1D4 young after eight months, with a 01-60% chance of becoming
infertile after one birth, and seldom give birth more than four times.

Disposition: friendly, social, cheerful, honest and trusting; love to talk,
sell, gamble and drink, and have a strong sense of justice and fair play.

Habitat: anywhere there is money to be made; seldom stay anywhere more than
1D4+3 years. Common in boomtowns, trading posts, the ''Burbs, the New West,
MercTown, Arzno, Kingsdale, Upper Michigan and the CS ''Burbs. Slave market
value 1D4x1,000 credits.

Allies: anyone who might lead to a big score; they travel alone or in small
family units, and favor City Rats, drunks, Barmaids, Professional Gamblers,
Saddle Tramps and Vagabonds. Enemies: they idolize and envy the Naruni and
the Splugorth, who think them a joke. They dislike slavers and never work in
any trade that harms or cages people.

Pet: the Phoo-Too, a loyal dog-like creature from their home world that
hunts small animals. I.Q. 1D4+4, M.E. 1D6+4, M.A. 1D6+10, P.S. 1D6+8, P.P.
1D6+8, P.E. 1D6+12, P.B. 1D6, Spd 2D6+16; M.D.C. 2D6+10.
',
       updated_at = datetime('now')
 WHERE class_id = 'fingertooth-carpetbagger'
   AND instr(markdown, 'the format has no way for a race to cancel an occupation''s secondary picks') > 0
   AND length(markdown) = 9483;

-- == lyvorrk ==
UPDATE imported_classes
   SET markdown = '---
id: lyvorrk
name: Lyvorrk
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.130-133
category: rcc
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
tags: [wilderness, stealth]
attribute_dice:
  IQ: "3d6+2"
  ME: "4d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6+2"
  PE: "5d6"
  PB: "2d6"
  Spd: "4d6"
mdc_base: "P.E. + 2d6, +2d4 per level"
ppe_base: "2d6+12"
horror_factor: 12
starting_money: "2d6x1000"
occ_restrictions:
  only: ["group:magic", "body-fixer"]
  note: "A Lyvorrk who follows the R.C.C. takes no O.C.C. One who forsakes the R.C.C. skills may take the Body Doc (stored as the Body Fixer) or any Magic O.C.C.; Shifter, Necromancer, Mystic, Ley Line Walker, Temporal Wizard and Elemental Fusionist appeal most, roughly in that order. Such a character uses only the O.C.C.''s skills and ignores the R.C.C., R.C.C. Related and Secondary Skills; the picker takes the O.C.C.''s Related and Secondary Skills in place of the R.C.C.''s but still carries the R.C.C. skills, so drop those by hand."
psionics:
  type: "major"
  isp_base: "M.E. x3, +10 per level"
  powers: ["Death Trance", "Mind Block", "Nightvision", "Resist Fatigue", "Resist Hunger", "Resist Thirst"]
bonuses:
  combat: { initiative: 2, strike: 3, parry: 4, dodge: 5, damage_bonus: 4, roll: 5, pull_punch: 3 }
  saves: { psionics: 3, spell_magic: 5, toxins_poisons: 7, harmful_drugs: 7, disease: 7, coma_death_pct: 18 }
skills:
  occ_skills:
    - { name: "Animal Husbandry", base: 50, per_level: 5, note: "+15%, but limited to rodents and reptiles." }
    - { name: "Barter", base: 40, per_level: 4, note: "+10%." }
    - { name: "Camouflage", base: 40, per_level: 5, note: "+20%." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%. Natural climbers." }
    - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%." }
    - { name: "Gemology", base: 40, per_level: 5, note: "+15%." }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%." }
    - { name: "Language: Spanish", base: 98, per_level: 0, note: "Native (adopted) tongue." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other of choice (+10%)." }
    - { name: "Lore: D-Bee", base: 35, per_level: 5, note: "Lore: D-Bees (+10%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed Math: Basic (20%), read as +20%." }
    - { name: "Mining", base: 45, per_level: 5, note: "+10%." }
    - { name: "Prowl", base: 40, per_level: 5, note: "+15%." }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%." }
    - { name: "Tracking (people)", base: 30, per_level: 5, note: "+5%." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%; +20% more to catch small animals such as rabbits, squirrels and other rodents." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "Targeting (Sling)." }
  occ_related_skills:
    count: 3
    categories:
      - "Communications"
      - { name: "Espionage", bonus: 5 }
      - "Medical"
      - "Physical"
      - "Pilot"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 5, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }, { level: 15, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6+6" }
  - { item_id: "hammer-and-mallet", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "explosive-grenade", qty: "1d4+1" }
  - { item_id: "triax-plasma-grenade", qty: "1d4" }
  - { item_id: "smoke-grenade", qty: "1d4+1" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: "1d4+1" }
  - { item_id: "sack", qty: "1d4+1" }
  - { item_id: "sling", qty: 1, note: "With normal and silver bullets (1D6 S.D.C., double damage to vampires); grenades can also be thrown with it." }
  - { item_id: "purse-satchel", qty: 1, note: "Satchel." }
  - { item_id: "water-skin", qty: 2, note: "A waterskin, and a second kept as a blood bottle: a waterskin holding blood for drinking." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "M.D.C. is 2D6 plus the P.E. attribute number, plus 2D4 M.D. per level of experience. Recovers lost M.D.C. at 1D6+6 points every four hours (twice as long in cold weather)."
  - name: "Regeneration"
    description: "Regrows a lost finger, toe, hand, foot or tail in 3D4+6 weeks, and lost teeth or a tongue in 1D4+4 weeks. Cannot regenerate an eye."
  - name: "Desert body"
    description: "Needs very little water and survives on as little as one pint a month, taking moisture from the fluids of raw food. A remarkable stomach handles raw meat, blood and spoiled meat. Not adversely affected by heat up to 140 degrees Fahrenheit. Good burrowers, keeping warm on cold desert nights by burrowing under rocks or dirt."
  - name: "Senses and body"
    description: "Natural climbers with keen hearing, polarized vision that is not affected by glare, and quick reflexes. A semi-prehensile tail is used for balance and for swatting opponents attacking from behind or the sides. Long hooked fingernails slice human flesh like knives. Impervious to all snake venoms."
special_abilities:
  - name: "Heat bonuses"
    description: "In temperatures of 90-140 degrees Fahrenheit the Lyvorrk adds +1 attack per melee round, +2 on initiative, +1 to strike and parry, and +2 to dodge to its other bonuses. Not applied by the sheet."
  - name: "Psionic Empathy with Reptiles"
    description: "Reptiles, snakes and reptilian dinosaurs take an immediate liking to a Lyvorrk and never stalk, hunt, bite or kill one. They are friendly and docile toward it, try to please it, and poisonous snakes and dinosaurs make loyal watchdogs and pets that fight to the death for their master."
  - name: "Telepathy with Reptiles"
    description: "Like normal Telepathy, but works only on cold-blooded animals of a reptilian nature, up to 1000 feet (305 m) away."
  - name: "Control Reptiles"
    description: "A blend of Empathy and Telepathy that controls the minds of cold-blooded reptiles: lizards, snakes, turtles and the few cold-blooded reptilian dinosaurs. They understand and obey every verbal or mental command. Range: 100 feet (30.5 m) per level of experience. Duration: as long as desired. Number controlled: 40 plus 10 per level of experience, regardless of size. Bonus: +10% to ride untamed dinosaur reptiles. I.S.P.: 3."
  - name: "Control Intelligent Reptilian Life Forms"
    description: "As Control Reptiles, but against intelligent reptilian D-Bees, who save vs psionic mind control at -2 (-5 if the Lyvorrk only asks harmless questions that betray no secret or confidence). A controlled victim does anything commanded except kill himself, kill a friend or loved one, or destroy or sell favorite possessions, and cannot be forced to do something completely abhorrent. Range: 50 feet (15.2 m). Duration: one minute (4 melee rounds) per level of experience. Number controlled: one per level of experience, regardless of size. Does not work on warm-blooded beings. I.S.P.: 5."
  - { choose: 1, at_levels: [2, 4, 6, 8, 10, 12, 14], from: ["Insanity (01-10): Obsession - Being Mysterious and Scary", "Insanity (11-20): Phobia - Scientists", "Insanity (21-30): Obsession - Craves Power and Wealth", "Insanity (31-40): Phobia - Cages and Being Locked Up", "Insanity (41-50): Obsession - Secrets", "Insanity (51-60): Phobia - Large Mammals", "Insanity (61-70): Obsession - Superiority", "Insanity (71-80): Phobia - Undead", "Insanity (81-90): Obsession - Magic", "Insanity (91-00): Phobia - Demons of Hades"], note: "Lyvorrk insanity table (printed 132): the page says to roll for one additional insanity at each of levels 2, 4, 6, 8, 10, 12 and 14. None is rolled at creation. The page does not say what a repeated result gives." }
  - name: "Insanity (01-10): Obsession - Being Mysterious and Scary"
    description: "Roll 01-10. Obsession. Likes to frighten and gross people out with his reptiles and behavior (drinks spilled blood, fondles snakes and so on). Cryptic in what he says, smiles menacingly, makes threatening remarks, mostly to enemies and strangers, and acts cool, calm and mysterious."
  - name: "Insanity (11-20): Phobia - Scientists"
    description: "Roll 11-20. Phobia. Dislikes and distrusts scientists no matter what, and will never let one examine him."
  - name: "Insanity (21-30): Obsession - Craves Power and Wealth"
    description: "Roll 21-30. Obsession. Willing to wait and work for power and wealth, but turns greedy, reckless and short-sighted when large amounts of money are at stake."
  - name: "Insanity (31-40): Phobia - Cages and Being Locked Up"
    description: "Roll 31-40. Phobia of cages and being locked up behind bars. Cannot stand the idea of imprisonment and hates zoos, slavers and slavery. May free slaves and even penned animals, starting with reptilians."
  - name: "Insanity (41-50): Obsession - Secrets"
    description: "Roll 41-50. Obsession. Collects secrets like rare gems and uses them to his advantage whenever possible. Keeps his own well guarded."
  - name: "Insanity (51-60): Phobia - Large Mammals"
    description: "Roll 51-60. Phobia. Finds large mammals, other D-Bees such as the Mastadonoid included, unnerving and creepy. Never trusts them and dislikes having to be around them."
  - name: "Insanity (61-70): Obsession - Superiority"
    description: "Roll 61-70. Obsession. Feels he must prove the superiority of intelligent reptiles over humans and mammals. Tends to be an arrogant show-off."
  - name: "Insanity (71-80): Phobia - Undead"
    description: "Roll 71-80. Phobia. Hates the undead and wants them destroyed, but hates doing it himself: tries to get others to kill vampires while he works to avoid them."
  - name: "Insanity (81-90): Obsession - Magic"
    description: "Roll 81-90. Obsession with magic. Roll percentile again: 01-70 covets magic weapons, artifacts, potions and items of all kinds, appreciates and trusts mages and finds creatures of magic fascinating; 71-00 hates magic, likes to steal and hide or destroy magic weapons, artifacts, potions and items of all kinds, and trusts neither mages nor creatures of magic. The second roll is made by hand."
  - name: "Insanity (91-00): Phobia - Demons of Hades"
    description: "Roll 91-00. Phobia. Finds the demons of Hades troubling and dangerous, the Gargoyle sub-demons and Lesser Demons included."
trackable_resources: []
side_effects: "Cold: in climates colder than 50 degrees Fahrenheit for more than four hours, or below freezing for more than one hour, bonuses, the number of attacks and the Spd attribute are reduced by half; they return to full after two hours of warmth (70 degrees or hotter). Cold-based attacks do double damage. Hates water, cannot swim and refuses to learn. Insanity: all Lyvorrk are insane to some degree, with an obsessive fondness for poisonous snakes and lizards, and most have a fear of drowning and bodies of water; they roll on the Lyvorrk insanity table (the Insanity group among the special abilities) for one more at each of levels 2, 4, 6, 8, 10, 12 and 14."
restrictions:
  - "Alignment: any, but Anarchist (30%), Aberrant (10%), Diabolic (20%) and Miscreant (20%) are most common."
  - "Magic: none, unless a Magic O.C.C. is selected; P.P.E. 2D6+12 is added to the base of one who becomes a practitioner of magic."
  - "Cybernetics: none, though Lyvorrk are not opposed to bionics as such."
  - "A Lyvorrk that takes the Body Doc or a Magic O.C.C. uses only that O.C.C.''s skills and ignores the R.C.C., R.C.C. Related and Secondary Skills. Partly applied: the picker uses the O.C.C.''s Related and Secondary Skills, not the R.C.C.''s, but still carries the R.C.C. skills; drop those by hand."
  - "Pilot related picks: basic vehicles only, like car, truck and hovercycle; avoids water vessels. Rogue picks: +10% to Seduction only, in place of +5%. Not enforced."
extraction_notes: "WB30 D-Bees of North America printed 130-133 (cache p131-p134), read off 200 dpi renders. Lore starts on printed 130 under the heading Lyvorrk; the stat block is headed Lyvorrk - Optional Player Character and NPC (printed 130) and ends on printed 133 with a note that the race first appeared in World Book One: Vampire Kingdoms. Printed 131 is an art plate. || CATEGORY: a race whose R.C.C. is a full skill package, or which may instead take the Body Doc or any Magic O.C.C. || XP: the book says a Lyvorrk who pursues R.C.C. skills uses the Psi-Stalker table, and a mage uses the magic O.C.C.''s table. It was left out at import, per that import''s brief, and an xp_table is stored now. || M.D.C.: 2D6 +P.E. attribute number, plus 2D4 M.D. per level, stored as mdc_base, so no men_of_arms line. P.P.E. 2D6+12, added to a mage''s P.P.E. base: stored as ppe_base, no yields_to_occupation. Horror Factor 12. || PSIONICS: I.S.P. printed M.E. attribute number x3, +10 I.S.P. per melee round; per melee round is read as a slip for per level of experience. Considered a Major Psychic. The six conventional powers are granted by name (printed levels Death Trance 1, Mind Block 4, Nightvision 4, Resist Fatigue 4, Resist Hunger 2, Resist Thirst 6 are the powers'' own I.S.P. costs). The four reptile powers are special abilities with their printed numbers. Psionic Empathy with Reptiles has a catalog row (Rifts World Book 4: Africa p.69, with an I.S.P. cost this entry does not print), so it is not granted (Nate, 2026-10-15; BOOK-INGEST-AUDIT.md F140); Telepathy with Reptiles, Control Reptiles and Control Intelligent Reptilian Life Forms have no catalog rows. || BONUSES: +2 initiative, +3 strike, +4 parry, +5 dodge, +4 S.D.C. damage (damage_bonus), +5 roll, +3 pull punch, +3 vs psionics, +5 vs magic (spell_magic), +7 vs poison, drugs and disease (toxins_poisons, harmful_drugs, disease), +18% vs coma. Impervious to snake venoms is ability text. Heat bonuses are conditional and a special ability. || SKILLS: catalog base plus the printed bonus. Language: Native (adopted) Tongue: Spanish is Language: Spanish at 98, the native-tongue convention. Math: Basic is printed (20%) with no plus sign; read as +20%, 65. W.P. Targeting (Sling) is the catalog W.P. Targeting. Hand to Hand: Assassin is granted with no upgrade price, so no hand_to_hand block. || RELATED: three at level one and one more at levels 3, 5, 8, 10, 13 and 15. Espionage +5% and Rogue +5% stored as bonuses; Rogue +10% to Seduction only and Pilot basic vehicles only are a restriction line. || SECONDARY: two from the Secondary Skill List at levels 1, 3, 8 and 12, read as two at each of those levels. || OCCUPATIONS: Body Doc is stored as body-fixer, the catalog''s Rifts medical O.C.C.; there is no Body Doc class. Any Magic O.C.C. is group:magic. The skill swap such a character makes is a restriction line, not pairing_skills (regression pins its carriers). || EQUIPMENT: the list is for a Lyvorrk R.C.C. (By O.C.C. otherwise). Silver cross is small-silver-cross; 1D6+6 wooden stakes; mallet is hammer-and-mallet; silver dagger (1D6 S.D.C.) is knife-silver-plated; skinning knife; 1D4+1 high explosive grenades as explosive-grenade; 1D4 plasma grenades as triax-plasma-grenade (Plasma Grenade); 1D4+1 smoke grenades; backpack; 1D4+1 large sacks; 1D4+1 medium sacks as sack. Granted since ~116 and ~117, to every Lyvorrk although the book gives them to one taking the R.C.C. and not to one who takes the Body Doc or a Magic O.C.C., who has that O.C.C.''s equipment instead (the condition is the player''s to honour): the sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw grenades) as sling, the satchel as purse-satchel, and the waterskin and the blood bottle as two water-skin. NOT STORED, no catalog row: one M.D. weapon (probably a Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes, a Gila Monster and 1D6+2 lizards; they are in GM Notes. || MONEY: R.C.C. starts with 2D6x1000 credits and 1D6x100 in tradeable goods, or by O.C.C.; the credits are starting_money, the goods are GM Notes. || INSANITY (printed 132, cache p133, re-read off 200 and 300 dpi renders 2026-10-05): the entry prints Roll on the following table at levels 2, 4, 6, 8, 10, 12 and 14 for additional insanities, and no roll at creation; the two insanities every Lyvorrk has (the fondness for poisonous snakes and lizards, the fear of drowning and bodies of water) stay in side_effects. The table has ten rows of ten points each, 01-10 to 91-00, alternating obsession and phobia. Stored as one pick-one group at levels 2, 4, 6, 8, 10, 12 and 14 with band-named options Insanity (NN-NN), replacing the level 2 level_progression line that only said to roll (BOOK-INGEST-AUDIT.md F116). No row prints a number, so no option carries bonuses. Row 81-90 Obsession: Magic sends the player to a second percentile roll (01-70 covets magic, 71-00 hates it): that sub-roll is the row''s prose. GM Notes keeps its one-paragraph summary of the table. || NOT STORED: size 5-6 feet with a 6-7 foot tail, weight 140-170 pounds, life span 6D6+100 years, breeding, habitat, slave market value 1D4x10,000 credits, allies and enemies; in GM Notes."
---

## Lore

The Lyvorrk (said "lie vork") look like a velociraptor that learned to walk
upright and dress itself. Under the ponchos, hooded cloaks and robes they
favor there is a long serpentine tail, clawed four-toed feet, a finned saurian
head and a wide mouth full of sharp teeth. The eyes are clever, though, and
the arms and hands are close to human, apart from long hooked nails that cut
like knives. They like jewelry and belts, and many wear live snakes the way
others wear necklaces.

Only a few hundred live in North America. Invasions, plagues and other
disasters over the last couple of centuries have pushed them to the edge of
extinction, most of the survivors are young by their own measure, and none
remember where they came from. They are cold-blooded, hate cold and water,
and keep to the hot dry Southwest, drifting into Lone Star, Mexico or the
Deep South in winter.

Most live as hunter-scavengers on small game, though a nasty few hunt people.
Their psionic hold over snakes and reptiles makes them good at finding prey,
and also makes them dangerous snake charmers, show performers, bandits,
interrogators and, above all, assassins who can send venomous creatures to
do the killing. Magic is a recent passion: about a third have become mages,
and they quietly hope to rebuild their numbers and one day become a power on
the continent.

## GM Notes

Experience: the entry names the Psi-Stalker experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: arrogant toward mammals, whom they tolerate as the dominant life
on Earth. Even good ones like to frighten people; evil ones are cruel and
vindictive. Excellent liars with fine poker faces, sluggish and grumpy in the
cold.

Insanity table, rolled at levels 2, 4, 6, 8, 10, 12 and 14 (d100):
01-10 obsession with being mysterious and scary; 11-20 phobia of scientists;
21-30 obsession with power and wealth; 31-40 phobia of cages and being locked
up; 41-50 obsession with secrets; 51-60 phobia of large mammals; 61-70
obsession with reptilian superiority; 71-80 phobia of undead; 81-90 obsession
with magic (01-70 covets magic items, 71-00 hates magic and steals or destroys
it); 91-00 phobia of the demons of Hades.

R.C.C. equipment the catalog has no row for: one M.D. weapon (probably a
Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes (probably
rattlers), a Gila Monster and 1D6+2 lizards. Also 1D6x100 credits in
tradeable goods.

The sling, satchel, waterskin and blood bottle (a waterskin of blood for
drinking) are the kit of a Lyvorrk taking the R.C.C.; one who takes the Body
Doc or a Magic O.C.C. has that O.C.C.''s equipment instead. The sling''s normal
and silver bullets do 1D6 S.D.C. (double damage to vampires), and it can also
throw grenades.

Size 5-6 feet (1.5 to 1.8 m) tall with a 6-7 foot (1.8 to 2.1 m) tail.
Weight 140-170 pounds (63 to 76.5 kg). Life span 6D6+100 years; mature at 12.
Females lay 1D4 eggs after a three month pregnancy, which hatch three months
later; the male raises the young.

Habitat: the American Southwest and the Mexican border. Slave market value
1D4x10,000 credits. Allies: their own kind and those subservient to them.
Enemies: dislike humans, mutants and most warm-blooded D-Bees, especially
bird, rodent, feline and canine ones, and regard other reptilian races as
rivals.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyvorrk'
   AND instr(markdown, 'The four reptile powers have no catalog rows') > 0
   AND length(markdown) = 20558;

-- == flooper ==
UPDATE imported_classes
   SET markdown = '---
id: flooper
name: Flooper
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.87-89
category: rcc
tags: [stealth]
attribute_dice:
  IQ: "2d6+3"
  ME: "2d6+6"
  MA: "3d6+12"
  PS: "2d6+3"
  PP: "2d4+14"
  PE: "3d6+2"
  PB: "2d6+2"
  Spd: "4d6"
mdc_base: "2d6x10, +1d6 per level"
ppe_base: "1d6x10"
starting_money: "2d6x100"
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
psionics:
  type: "minor"
  isp_base: "M.E. + 4d6, +1d6 per level"
  powers: ["Empathy", "Mind Block", "Sixth Sense"]
  powers_starting: 0
bonuses:
  combat: { initiative: 1, dodge: 2, roll: 3 }
  saves: { spell_magic: 2, horror_factor: 2 }
skills:
  hand_to_hand: { costs: { basic: 1 } }
  occ_skills:
    - { name: "Acrobatics", base: 30, per_level: 5, note: "R.C.C. skill." }
    - { name: "Appraise Goods", base: 45, per_level: 5, note: "R.C.C. skill, +15%." }
    - { name: "Barter", base: 54, per_level: 4, note: "R.C.C. skill, +24%." }
    - { name: "Climbing", base: 50, per_level: 5, note: "R.C.C. skill, +10%." }
    - { name: "Dance", base: 45, per_level: 5, note: "R.C.C. skill, +15%, professional quality." }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "R.C.C. skill, +20%." }
    - { name: "Gymnastics", base: 30, per_level: 5, note: "R.C.C. skill." }
    - { name: "Juggling", base: 55, per_level: 5, note: "R.C.C. skill, +20%. Ambidexterity adds a further +5%; see Double Jointed, Ambidextrous and High Physical Prowess." }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Printed as Math: Basic (+15%)." }
    - { name: "Performance", base: 40, per_level: 5, note: "R.C.C. skill, +10%." }
    - { name: "Prowl", base: 30, per_level: 5, note: "R.C.C. skill, +5%." }
    - { name: "Public Speaking", base: 50, per_level: 5, note: "R.C.C. skill, +20%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: Other, two of choice (+10%), typically American and Spanish. Taken once per language." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0 }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Boxing"] }
      - { name: "Pilot", except: ["Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Robots & Power Armor", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", bonus: 10 }
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Pole Arm"] }
    schedule:
      - { level: 4, count: 2 }
      - { level: 7, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 0
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "sack", qty: "1d4" }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
  - { item_id: "wooden-throwing-knife", qty: "1d6+1" }
  - { item_id: "silver-plated-throwing-knife", qty: "1d6+2" }
  - { item_id: "water-skin", qty: 1, note: "Wine skin." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "M.D.C. 2D6x10 plus 1D6 per level of experience. Human-equivalent senses; heals three times faster than a human."
special_abilities:
  - name: "Double Jointed, Ambidextrous and High Physical Prowess"
    description: "Natural gymnasts, acrobats, escape artists and thieves: can roll, tumble, cartwheel, back flip, juggle and endure falls from great heights. Ambidexterity adds +5% to Cardsharp, Forgery, Juggling, Palming, Pick Locks and Pick Pockets."
  - name: "Flooping (Limbo Teleport)"
    description: "With a thought the Flooper vanishes into a limbo-like dimension, usually for 2-5 seconds, with a ''floop'' sound, and can stay gone up to one melee round (15 seconds) per level of experience, returning at any time before that. While gone it can take no action. It reappears at the exact spot it left, or up to three feet (0.9 m) per level of experience away in any direction, up or down included, within line of sight. Costs 3 I.S.P. per round trip. +1 to dodge via Flooping at levels 1, 2, 4, 6, 7, 8, 9, 11, 13 and 15."
  - name: "Extra melee actions"
    description: "+2 melee ACTIONS per melee round, not attacks: usable for anything but an attack."
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Unprincipled (15%) or Anarchist (65%)."
  - "Available O.C.C.s: none. Floopers make a living as performers, thieves, pickpockets, spies and informers."
  - "No Hand to Hand Combat skill: attacks per melee as per Characters with NO Hand to Hand Combat Skill (Rifts Ultimate Edition p.347), or as per Hand to Hand if one is chosen as a related skill, never better than Basic."
  - "Secondary Skills: two from the Secondary Skill List (Rifts Ultimate Edition p.300) at levels 3, 6, 9 and 12; none at first level. They start at base skill level with no bonuses other than a high I.Q. bonus."
  - "Magic: none. Psionics: Minor Psychic, powers limited to Empathy, Mind Block and Sixth Sense."
  - "Cybernetics and Bionics: not possible."
  - "Vulnerability: laziness and slovenly behavior work against a Flooper, and they tend to push their luck."
  - "Standard equipment also includes 1D4+1 colorful costumes, a jacket, 10 juggling pins, a makeup kit, a pocket calculator, 1D4 ammo clips/E-Clips for each W.P., and some personal items. The 1D6+1 wooden throwing knives (1D4 S.D.C., double damage to vampires), 1D6+2 silver-plated throwing knives (1D6 S.D.C.) and the wine skin are in the equipment list."
  - "Money: 2D6x100 credits plus 1D4x1,000 in trade goods."
extraction_notes: "D-Bees of North America printed 87-89 (cache p088-p090, cache page = printed + 1), every number read off 200 dpi renders. A reprint not held in the catalog (originally Rifts World Book One: Vampire Kingdoms), imported from this book. Tag line: Flooper - Optional Player Character or NPC. The entry ends at its closing Note on printed 89. || CATEGORY: an R.C.C. that takes no O.C.C. (Available O.C.C.s: None), with its own skills, related and secondary skills. || XP_TABLE: the Experience Level line says Use the Psi-Stalker Experience Table, so the ladder is copied from the catalog psi-stalker class''s stored xp_table, per the class-import reference rule that a class whose book names another class''s table copies that ladder (Nate''s decision 2026-09-26). This departs from the batch brief''s no-xp_table default, which assumed every entry defers to the chosen O.C.C.''s table; this one does not. || M.D.C. 2D6x10 plus 1D6 per level as mdc_base; no men_of_arms line. Horror Factor none. P.P.E. 1D6x10. || PSIONICS: Minor Psychic, I.S.P. 4D6 + M.E. plus 1D6 per level, powers limited to Empathy (6), Mind Block (4) and Sixth Sense (2), all granted; powers_starting 0. || BONUSES: +1 initiative, +2 dodge, +3 roll, +2 vs magic (spell_magic), +2 vs Horror Factor stored. +2 melee actions (not attacks) is a special ability, because combat.attacks would let them be spent on attacks. +1 dodge via Flooping at levels 1, 2, 4, 6, 7, 8, 9, 11, 13 and 15 is conditional and is Flooping text. || SKILLS: catalog base plus printed bonus: Acrobatics 30, Appraise Goods 30+15, Barter 30+24, Climbing 40+10, Dance 30+15, Escape Artist 30+20, Gymnastics 30, Juggling 35+20, Math: Basic stored as Mathematics: Basic 45+15, Performance 30+10, Prowl 25+5, Public Speaking 30+20, two Language: Other at +10, W.P. Paired Weapons, W.P. Targeting. The ambidexterity +5% to Cardsharp, Forgery, Juggling, Palming, Pick Locks and Pick Pockets is not folded into any base (it is a conditional add to skills mostly not granted, and would double-read on Juggling); it is ability text. || RELATED: four at level one, two more at levels 4, 7, 11 and 15. Communications +5, Domestic, Espionage +5, Horsemanship General and Exotic Animals only, Physical except Boxing, Pilot except robot and military vehicles (the Robot Combat, Robots & Power Armor and Military: rows), Rogue +10, Technical, W.P. except Heavy Weapons (both heavy W.P. rows) and Pole Arm. || SECONDARY: two at levels 3, 6, 9 and 12, none at level one: count 0 with a schedule. || HAND TO HAND: none granted; one may be chosen, never better than Basic, so hand_to_hand costs basic 1 and nothing else. || EQUIPMENT: stored by catalog slug: clothing x2 (a couple sets), Vibro-Knife, small-silver-cross, pocket-mirror, backpack, duffle bag, 1D4 sacks, sleeping-bag for the bedroll, canteen, portable language translator, sunglasses, and weapons-matching-w-p-skills for one weapon per W.P. No catalog row for costumes, juggling pins, a makeup kit or a pocket calculator. The jacket names no kind and the catalog''s Rifts jackets are specific ones (field, flight, thermal and the like), so none is granted (Nate, 2026-10-15; BOOK-INGEST-AUDIT.md F140). The E-Clips are per W.P. and left in prose. They are a restriction line. Granted since ~116 and ~117: the throwing knives as wooden-throwing-knife 1d6+1 and silver-plated-throwing-knife 1d6+2 (rows that carry their own damage; knife-throwing is not the same item), and the wine skin as water-skin. || MONEY: 2D6x100 credits stored; 1D4x1,000 in trade goods is not coin. || NOT STORED: size, weight, life span, breeding, habitat, allies and enemies are in GM Notes."
---

## Lore

Floopers are short, round, pot-bellied D-Bees with floppy ears and a
permanently silly look, and they make their living as clowns, tumblers,
jugglers and handymen for circuses, carnivals and traveling shows. Less
honest shows use them as thieves, pickpockets, con artists and spies.
Despite their bulk they are remarkably quick and nimble, double-jointed
and ambidextrous, and can tumble, flip and survive long falls unhurt, helped
by being Mega-Damage beings and by their talent for Flooping: blinking into
a limbo dimension for a moment and popping back out.

They will do anything for a laugh and love company of every kind, but they
are also famously lazy freeloaders who would rather beg, perform or pick a
pocket than work. A Flooper''s home is always a near-ruin, and they would
sooner move than clean up. Only their curiosity and love of socializing
beat their laziness.

They are inveterate gossips and eavesdroppers, so a Flooper is a good
source of news and secrets, and always knows what that information is worth.
A pleased Flooper shouts "floop floop" and does a back flip instead of a
handshake.

## GM Notes

Size 4-5 feet (1.2 to 1.5 m), very round and flabby. Weight 1D4x100 pounds
(45 to 180 kg). Life span 1D6x10+122 years; mature at 20. Females bear one
young after a 12 month pregnancy and can give birth until 100, but seldom
have more than five. Males outnumber females two to one.

Disposition: friendly, playful, goofy pranksters and entertainers who love
a bargain; lazy about physical labor.

Habitat: most common in the American Southwest, the Deep South and Mexico
along the border, but found anywhere, often with traveling shows. Only about
10% are hardworking professional thieves or spies.

Allies: other Floopers (they travel in pairs, trios or quartets); they like
humans and love Larmac. Rivals: Phlebus, Roane Pipers, Fingertooth
Carpetbaggers, Kraks, Shapers and most shape changers. No real enemies
beyond those they cheated or robbed.
',
       updated_at = datetime('now')
 WHERE class_id = 'flooper'
   AND instr(markdown, 'No catalog row for costumes, jacket, juggling pins') > 0
   AND length(markdown) = 12338;

-- == shaper ==
UPDATE imported_classes
   SET markdown = '---
id: shaper
name: Shaper
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.182-185
category: rcc
tags: [shapeshifter]
xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]
attribute_dice:
  IQ: "1d4+4"
  ME: "1d6+1"
  MA: "4d6"
  PS: "2d6+3"
  PP: "3d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "1d6x10"
mdc_base: "1d6x10, +1d6 per level of experience"
ppe_base: "2d4x10"
starting_money: "3d4x100"
bonuses:
  combat: { initiative: 2, strike: 1, parry: 1, dodge: 3, pull_punch: 2, roll: 3 }
  saves: { toxins_poisons: 5, harmful_drugs: 3, spell_magic: 2, psionics: 2 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Begging", base: 50, per_level: 3, note: "+20%" }
    - { name: "Brewing", base: 40, per_level: 5, note: "+15%, professional quality." }
    - { name: "Brewing: Medicinal", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 70, per_level: 5, note: "+30%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%, professional quality." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%, professional quality." }
    - { name: "Gardening", base: 46, per_level: 4, note: "+10%" }
    - { name: "Holistic Medicine", base: 25, per_level: 5, note: "+5%" }
    - { name: "Juggling", base: 50, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American is the adopted native tongue." }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "Printed as Identify Fruits & Plants (+20%)." }
    - { name: "Performance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%, professional quality." }
    - { name: "Tailing", base: 35, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Cannot be changed." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Rogue"
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"] }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 6, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "sunglasses-or-goggles-cheap", qty: 1 }
  - { item_id: "gloves", qty: "1d4" }
  - { item_id: "boots", qty: 1, note: "Oversized." }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "shaper-light-partial-armor", qty: 1 }
natural_abilities:
  - { name: "Keen vision", description: "Sees the same color spectrum as a human, but clearly at twice the distance. Nightvision 120 feet (36.5 m)." }
  - { name: "M.D.C. recovery", description: "Recovers lost M.D.C. at 1D6 points per hour." }
  - { name: "Scavenger''s stomach", description: "Eats almost anything edible, loves sweets of every kind, and has great resistance to poisons and toxins." }
  - { name: "Prehensile Tail", description: "Strong enough to turn a doorknob, press buttons, operate simple machines and use weapons and tools (-2 to fire a gun with the tail, -1 to strike with melee weapons), and to climb, hang and swing like a monkey." }
  - { name: "Natural Performers and Acrobats", description: "Hams who love to perform and show off; see the R.C.C. Skills." }
special_abilities:
  - name: "Selective Metamorphosis"
    description: "Shape changes a specific body part or area without altering the rest, mixing the features of up to twelve different animals into one body; one to a dozen changes can be made in an instant, each counting as one melee action. Can add up to four extra appendages (wings, horns, antennae, extra arms or legs). All changes must be animal features, never human, and the Shaper cannot take the whole shape of any one animal. Size can grow to three times normal, 12 feet (3.6 m). Can metamorphose once per melee action with no limit on how long a shape is held. The Shaper keeps only its own attacks, skills and abilities, never those of the animals it mimics: a crab''s shell gives no M.D.C. and wings give no flight. Horror Factor 2D4+7 when disguised as a ferocious beast or a scary amalgamation of creatures; none in its natural ape-like form."
  - name: "Silliness overload"
    description: "A Shaper changing shape once per melee action can make itself dizzy and collapse laughing, helpless for 3D4 minutes: it cannot attack, run, hide, dodge, talk or do anything else."
  - name: "Enhanced Sense of Smell"
    description: "Recognizes and accurately identifies specific smells and scents from up to 100 feet (30.5 m), +20 feet (6.1 m) per level of experience. Base skill at scent recognition: 50% +2% per level of experience; +10% if the smell is very common or very well known to the D-Bee."
trackable_resources: []
restrictions:
  - "Alignment: any, but typically Scrupulous (32%), Unprincipled (25%) or Anarchist (25%)."
  - "Available O.C.C.s: none. Shapers are creatures of instinct and habit and get R.C.C. skills only."
  - "Psionics: none."
  - "Magic: none."
  - "Cybernetics and bionics: none, ever."
extraction_notes: "WB30 D-Bees of North America printed 182-185 (cache p183-p186, cache page = printed + 1). Read off 200 dpi renders; the entry runs from the Shapers heading on 182 to the Alliances line at the foot of 184, and its last line (Rivals) on 185 above the Shemarrian Warriors heading. A reprint; the catalog held no shaper class on 2026-10-03 (nautyll-koral-shaper is a different race). Tag line: Shaper - Optional Player Character or NPC (playable). || CATEGORY: a full R.C.C. that takes no O.C.C. Its M.D.C. is the race''s own, stored as mdc_base (no men_of_arms line). No occ_restrictions block is stored for Available O.C.C.s: None, following the other no-O.C.C. races; it is a restriction line. || XP: the book says use the same Experience Table as the Elemental Fusionist. By the 2026-09-26 copy rule (class-import reference, xp_table), copied from the stored elemental-fusionist-earth-air / elemental-fusionist-fire-water ladder (identical), Rifts Ultimate Edition. || ATTRIBUTES as printed. M.D.C. 1D6x10 +1D6 per level; P.P.E. 2D4x10. Horror Factor: none in natural form, 2D4+7 when disguised as a beast, so no horror_factor key; it is in Selective Metamorphosis. || BONUSES as printed: +2 initiative, +1 strike and parry, +3 dodge, +2 pull punch, +3 roll with impact, +5 save vs poison (toxins_poisons), +3 vs drugs (harmful_drugs), +2 vs magic (spell_magic), +2 vs psionic attack (psionics). || SKILLS: each base is the catalog base plus the printed bonus. Cook is the catalog''s Cook row; Identify Fruits & Plants is Identify Plants & Fruit; Language: Native (American is the adopted native tongue) is Language: Native Tongue at 98. Hand to Hand: Basic (cannot be changed) is costs: {}. Enhanced Sense of Smell (50% +2%) has no catalog row and is a special ability. || RELATED: four at first level, +1 at 3, 6, 9 and 12: Communications (+5%), Domestic (+10%), Horsemanship (General and Exotic only, stored as Horsemanship: General and Horsemanship: Exotic Animals), Rogue, Technical (+5%), W.P. (any except heavy weapons, stored as except W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons) and Wilderness (+5%). The book prints Rogue, Technical (+5%); the +5% is read as Technical''s only. SECONDARY: printed select two at levels 2, 6, 8 and 12, read as none at level one and two at each of those levels (count 0 with a schedule). || EQUIPMENT (printed 184): stored where a catalog row exists: pocket knife, Vibro-Knife, a couple of small sacks (2), backpack (the book says backpack or satchel), canteen (or waterskin), pocket mirror, silver cross (Small Silver Cross) and tinted goggles (Sunglasses or Goggles, cheap). Granted since ~116 and ~117: 1D4 sets of gloves (gloves), oversized boots (boots), clothing and the set of light partial armor (shaper-light-partial-armor, 2D6+20 M.D.C.). One weapon and an extra ammo clip per W.P. is not given as items. Not stored and not stubbed: 1D4 tubes of lipstick, an inflatable beach ball, 1D4+4 juggling balls, a spoon, a teapot and a comb have no catalog row; colorful scarves, a shoulder bag of 2D4+2 lbs of candy, a jar of honey, a box of 100 tea bags and 1D4+2 plastic teacups have no Rifts row; the bag of hats names no kind and the catalog''s Rifts hats are specific ones, so none is granted (Nate, 2026-10-15; BOOK-INGEST-AUDIT.md F140); personal items name nothing. These are in GM Notes. || MONEY: 3D4x100 Universal Credits. || NOT STORED: size 4 feet (up to 12 by shape change), weight 60-100 lbs, life span 2D6+40 (+20 urban), slave market value 6D6x100, habitat, allies and enemies are in GM Notes."
---

## Lore

Shapers are chimpanzee-sized D-Bees with a hyena-like head, a huge toothy
grin, oversized ears, a monkey''s tail and hand-like feet, and the power to
reshape any part of their bodies in an instant. For a long time people took
them for clever shape-shifting monkeys; they are in fact intelligent
humanoids who simply never minded the mistake.

They take everything in stride. Cheerful, playful and silly, they love
children, sweets, cooking, dancing, singing, juggling and roughhousing, and
work only as much as it takes to get by. Many drift into circuses, carnivals,
traveling shows, street corners and taverns as performers, or care for other
people''s children. Shape-changing would seem to make them ideal thieves and
spies, but such work is far too serious for them.

Their talent is not to become one animal but to mix and match the parts of
many into absurd and sometimes frightening chimeras, mostly for laughs, and in
the wild to scare off predators. One or two Shapers make cheerful companions;
three or more feed off each other''s jokes until the fun turns into chaos, and
they will happily tease soldiers, criminals and monsters who have no sense of
humor at all. They fight only when cornered or when someone they love is
threatened.

## GM Notes

Also known as Monkey Morph. Size four feet (1.2 m), up to three times that by
shape change. Weight 60-100 pounds (27 to 45 kg). Life span 2D6+40 years in the
wild, 20 more in an urban setting; mature at 10, 1D4 young after a seven month
pregnancy. A Shaper usually has only 30 to 90 M.D.C., which its monstrous looks
can belie.

The full possessions list: a pocket knife (1D4 S.D.C.), a Vibro-Knife (1D6
M.D.), one weapon and an extra ammo clip for each W.P., a couple of small sacks,
a bag of hats, colorful scarves, 1D4 sets of gloves, oversized boots, a few
articles of clothing, a set of light partial armor (2D6+20 M.D.C.), 1D4 tubes
of lipstick, a beach ball, 1D4+4 juggling balls, a backpack or satchel, a
shoulder bag with 2D4+2 lbs of candy, a jar of honey, a box of 100 tea bags, a
spoon, a teapot, 1D4+2 plastic teacups, a canteen or waterskin, a pocket
mirror, a silver cross, tinted goggles, a comb and a few personal items.

Habitat: anywhere, most common in the American Southwest and Mexico, also at
Arzno, Kingsdale, MercTown, Ciudad Juarez, the Chi-Town ''Burbs, Old Bones and
the Pirate Kingdom of Montreal. Slave market value 6D6x100 credits as clowns,
jesters, entertainers and pets. Allies: most people, especially humans,
Phlebus, Fennodi, Fingertooth, Floopers, Kraks, Larmac and Grackle Tooth.
Enemies: none as such, but they dislike anyone cruel, violent or a slaver.
The entry notes it first appeared in Rifts World Book One: Vampire Kingdoms.
',
       updated_at = datetime('now')
 WHERE class_id = 'shaper'
   AND instr(markdown, 'Not stored, no catalog rows and not stubbed: a bag of hats') > 0
   AND length(markdown) = 12149;

-- == vintex-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: vintex-warrior
name: Vintex Warrior
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.213-215
category: rcc
tags: [combat]
attribute_dice:
  IQ: "2d6+3"
  ME: "2d6+3"
  MA: "2d6+3"
  PS: "3d6+11"
  PP: "2d6+9"
  PE: "2d6+7"
  PB: "2d6"
  Spd: "3d6+13"
mdc_base: "P.E. + 6d6, +2d6 per level"
ppe_base: "2d6+5"
starting_money: "1d6x1000"
bonuses:
  combat: { attacks: 1, initiative: 1, strike: 3, parry: 1, dodge: 1, disarm: 3, entangle: 1, pull_punch: 4, roll: 1 }
  saves: { horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 30, per_level: 5 }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "Combat Driving", base: 0, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native (+4%); American is the adopted native tongue." }
    - { name: "Literacy: Native Language", base: 50, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Mathematics: Basic", base: 57, per_level: 5, note: "Math: Basic (+12%)" }
    - { name: "Military Etiquette", base: 55, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Pilot"], bonus: 12, note: "Pilot: Vehicle of choice (+12%); hovercycles, rocket bikes, motorcycles and fast cars are favorites." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Rope Works", base: 45, per_level: 5, note: "Printed (15%), read as +15%." }
    - { name: "Sign Language", base: 35, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
    - { choose: 3, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Tomahawk", "W.P. Trident", "W.P. Whip"], note: "W.P. Ancient: three of choice." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Automatic and Semi-automatic Rifles", "W.P. Bolt Action Rifle", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Grenade Launcher", "W.P. Handguns", "W.P. Harpoon & Spear Gun", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", "W.P. Military Flamethrowers", "W.P. Revolver", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun"], note: "W.P. Modern: two of choice." }
    - { name: "W.P. Rope", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0 }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Commando"], note: "Hand to Hand: Martial Arts or Commando, pick one." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 15 }
      - { name: "Cowboy", bonus: 15 }
      - { name: "Domestic", bonus: 15 }
      - { name: "Electrical", bonus: 15 }
      - { name: "Espionage", bonus: 15 }
      - { name: "Horsemanship", bonus: 15 }
      - { name: "Mechanical", bonus: 15 }
      - { name: "Medical", bonus: 15 }
      - { name: "Military", bonus: 15 }
      - { name: "Pilot", bonus: 15, except: ["Boat: Submersibles", "Military: Submersibles", "Military: Tanks & APCs", "Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor"] }
      - { name: "Rogue", bonus: 15 }
      - { name: "Science", bonus: 15 }
      - { name: "Technical", bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 15 }
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 5, count: 2 }, { level: 7, count: 2 }, { level: 9, count: 2 }, { level: 11, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "e-clip", qty: "1d6+3" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "vintex-medium-armor", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
natural_abilities:
  - name: "Mega-Damage body"
    description: "M.D.C. 6D6 + P.E. attribute number, +2D6 per level of experience starting at level one. Augmented P.S., quick reflexes, excellent vision and other senses. Bio-regenerates 2D6 M.D.C. every 24 hours and regrows a lost tail in six months. Impervious to most diseases."
special_abilities:
  - name: "Prehensile tail"
    description: "Flexible enough to carry young, packages and weapons, but not to fire a gun or wield a weapon in combat (-3 to strike even with a blunt weapon). Used for balance, hanging upside down, swimming and striking an opponent behind or to the side: +10% to balance, +2 to strike and +1 to parry with the tail. Tail strike does 2D6 S.D.C. for a female, 3D6 for a male''s spiked tail; only a male can deliver an M.D. power tail strike as per Augmented P.S. (typically 1D4 M.D., sometimes 1D6 M.D.; counts as two melee attacks)."
  - name: "Superior Aim"
    description: "Fires a gun from a moving vehicle, while running, hanging upside down or in mid-leap without penalty (roll as normal with the usual bonuses), and automatically has the Targeting skill."
trackable_resources: []
restrictions:
  - "O.C.C.s: none. A Vintex may call himself an assassin, bounty hunter, gunslinger, lawman, mercenary, soldier or spy, but does not select an O.C.C.; all have the R.C.C. skills and Area of Specialty."
  - "Area of Specialty: all five skills must come from ONE category; Physical and Pilot Related are excluded. Electrical includes Computer Operation from Technical."
  - "Alignment: any, but they lean toward Scrupulous (25%), Unprincipled (30%), Anarchist (15%) and Aberrant (15%)."
  - "Psionics: none. Magic: none."
  - "Cybernetics and bionics: starts with none, but not opposed to them, especially to replace a lost limb."
side_effects: "No vulnerabilities as such, though their obsession with war and physical combat has its drawbacks."
extraction_notes: "WB30 D-Bees of North America printed 213-215 (cache p214-p216, cache page = printed + 1); every number read off a 200 dpi render. Heading Vintex Warriors - Optional Player Character or NPC, printed 214. || CATEGORY: a race with its own skills that takes no O.C.C. (printed O.C.C.s: they do NOT select an O.C.C.). mdc_base is stated, so no men_of_arms line. || XP: the Note says use the same Experience Table as the Military Specialist. The catalog holds a Rifts Military Specialist ladder now, on coalition-military-specialist (Rifts Ultimate Edition p.235-236; geofront-military-specialist is the Japan class of that name, a different book and table; the hu- rows are Heroes Unlimited). This class does not copy it and still stores no xp_table. || M.D.C.: 6D6 + P.E., plus 2D6 per level starting at level one, stored as mdc_base. P.S. 3D6+11 is Augmented; Spd 3D6+13 (average 22). Horror Factor not applicable. P.P.E. 2D6+5. || BONUSES: +1 attack per melee, +1 initiative, +3 strike, +1 parry and dodge, +3 disarm, +1 entangle, +4 pull punch, +1 roll with impact, +3 vs Horror Factor as printed. Impervious to most diseases is a total immunity, left in prose rather than a save bonus. The tail''s +2 strike and +1 parry are conditional and are ability text. || SKILLS: catalog base plus printed bonus: Literacy: Native Language 40+10, Climbing 40+15, Land Navigation 36+10, Math: Basic (catalog Mathematics: Basic) 45+12, Military Etiquette 35+20, Radio: Basic 45+15, Rope Works 30+15 (printed (15%), read as a bonus), Sign Language 25+10, Swimming 50+15. Acrobatics, Boxing and Combat Driving carry no bonus. Language: Native (+4%, American adopted) is Language: Native Tongue at 98; the +4% would exceed 98 and is a note. Pilot: Vehicle of choice (+12%) is a choice from Pilot with bonus 12. W.P. Ancient three and W.P. Modern two are choices from the ancient and modern W.P. rows (W.P. Rope is granted by name, so it is left out of the ancient list). Superior Aim''s automatic Targeting is the printed W.P. Targeting. Hand to Hand: Martial Arts or Commando, pick one, is a choice; no upgrade price is printed, so no hand_to_hand block. || AREA OF SPECIALTY: takes the place of related skills; five skills from any ONE of the listed categories at +15%. Stored as occ_related_skills count 5 with every listed category at bonus 15; the one-category rule is a restriction line and is not enforced; a skills.mos with one option per category could hold it, and the class is left as it is (Nate, 2026-10-15; BOOK-INGEST-AUDIT.md F140). Physical: None and Pilot Related: None are omitted. Pilot excludes Submersible, Tanks, Robot and Power Armor skills, stored as an except list of the matching Pilot rows. W.P. carries no bonus (a W.P. has no percentage). || SECONDARY: two at each of levels 1, 3, 5, 7, 9 and 11. || EQUIPMENT: set of clothing, leather boots (boots), leather gloves (gloves), backpack, bedroll, two canteens, 1D4 pens or markers (marker x1D4), pocket mirror, wooden cross, language translator (portable-language-translator), satchel (purse-satchel, the row an earlier import used for a satchel). E-Clips 1D6+3 for each W.P. weapon are stored as one e-clip x1D6+3 (the per-weapon count is in GM Notes). Granted since ~116 and ~117: the suit of medium or non-environmental armor (vintex-medium-armor, 4D6+40 M.D.C.) and the notebook (note-pad). One weapon for each W.P. is not given as items. Not stored: 1D4 pieces of white chalk (no Rifts row; BOOK-INGEST-AUDIT.md F140), a can of spray paint (no catalog row) and personal items (no named item). || MONEY: 1D6x1,000 credits in trade goods or Black Market items. || NOT STORED: size 6-7 feet, weight 200-250 pounds, life span 6D6+99 years, slave market value 1D4x10,000, allies, enemies and habitat are GM Notes."
---

## Lore

The Vintex were designer soldiers, bred and tuned by their own leaders for
war. Part of a million-strong invasion force that reached Earth early in
the Dark Age, they were ground down by the First Zombie Plague and by demons
from the Rifts until fewer than a hundred thousand remained and their
command was gone. They held out in Manitoba for nearly twenty years waiting
for orders that never came, then learned, slowly and fearfully, to choose
for themselves. Their Vintex Imperium lasted 120 years before it fell.

Today several hundred thousand are scattered across North America. They
look humanoid, with yellow or light orange skin splotched black or dark
red, wiry black and silver hair, no lips or visible nose, and a thick
dinosaur-like tail, spiked on the males. Born to fight and proud of it, they
live as mercenaries, lawmen, raiders and monster slayers, yet secretly
admire artists, scholars and dreamers above all: warriors with the hearts
of poets.

## GM Notes

Pronounced vin TEX. Also known as Dark Age Hunters and Iron Skin Soldiers.
Size 6-7 feet (1.8 to 2.1 m); weight 200-250 pounds (90 to 112.5 kg), all
muscle. Life span 6D6+99 years; mature at 15. Clans number 5D6+30. Slave
market value 1D4x10,000 credits.

Standard armor is medium or non-environmental M.D.C. armor of 4D6+40 M.D.C.
with the tail usually unarmored; full or environmental armor must be
customized for the tail. They start with one weapon for each W.P. and 1D6+3
E-Clips for each.

Allies: other warriors, especially Psi-Stalkers, Malvoren, Squilbs, Blucies
and Rogue Dog Boys; they respect Cyber-Knights and Lyn-Srial, and revere
Rogue Scholars, historians and artists (Erin Tarn above all). Enemies: they
hate demons and supernatural beings, Worm Wraiths and vampires most, and
distrust creatures of magic and psychics; they regard the Coalition and
Free Quebec as great military powers without undue hatred.

Habitat: throughout North America, wherever there is a battle to be fought.
',
       updated_at = datetime('now')
 WHERE class_id = 'vintex-warrior'
   AND instr(markdown, 'the one-category rule cannot be enforced') > 0
   AND length(markdown) = 12196;

-- == worldly-sasquatch ==
UPDATE imported_classes
   SET markdown = '---
id: worldly-sasquatch
name: Worldly Sasquatch
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.176-177
category: occ
tags: [wilderness]
occ_group: optional
men_of_arms: false
race_restrictions: { only: ["true-sasquatch"], note: "An occupation for a True Sasquatch who has entered the world of humans." }
xp_table: [0, 1931, 3861, 7721, 15201, 21301, 31301, 41601, 53301, 73601, 103301, 140001, 190001, 240001, 290001]
skills:
  occ_skills:
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: Other: American at +15%. This pick is the American one." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One more Language: Other of choice, at +10%." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P. skills, any." }
    - { choose: 2, categories: [{ name: "Communications", bonus: 5 }, { name: "Domestic", bonus: 5 }, "Medical", "Technical", { name: "Wilderness", bonus: 10 }], note: "1D4+1 skills from Communications (+5%), Domestic (+5%), Medical, Technical and Wilderness (+10%). Two are offered here, the lowest roll; roll 1D4+1 and add the rest by hand." }
    - { choose: 2, categories: [{ name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }, "Pilot"], note: "Horsemanship: General and Horsemanship: Exotic Animals, or two Piloting skills of choice. Take the two Horsemanship skills or two Pilot skills, not one of each." }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P." }
  - { item_id: "e-clip", qty: "1d4+1", note: "1D4+1 extra E-Clips." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { choose: 1, label: "waterskin or canteen", qty: 1, from: ["waterskin-half-gallon", "canteen"] }
  - { item_id: "utility-belt", qty: 1, note: "With many pouches; may have a bandoleer too." }
  - { item_id: "small-sack", qty: 1, note: "A few small sacks; the book gives no number." }
  - { item_id: "large-sack", qty: 1 }
trackable_resources: []
side_effects: "Even a Worldly Sasquatch is a woodland creature. Towns are confining; a city is noisy, ugly and dangerous, and an hour there is plenty. Forced to stay in a city or large town, the character grows tense and irritable and is likely to fall into deep depression (all attacks, bonuses and skills halved unless escaping the place) or to become obsessed with getting out, deserting friends and allies to do it. The breaking point comes after 26 hours +1 hour per M.E. point, doubled in a quiet town or a tranquil part of a city such as a park."
restrictions:
  - "True Sasquatch only. Usually an unattached youngster of 15-25 or an elder whose mate has died and whose children are grown; about 75% are male, and all are single."
  - "Skills: all the usual skills of the standard Sasquatch, but at -5%. The sheet does not take the 5% off; subtract it by hand."
  - "Will only keep company with groups of predominantly good alignment, and will not put up with Anarchist or evil associates for long."
  - "Armor: about two-thirds wear partial M.D.C. armor, with no helmet or shoes. Never full environmental armor."
  - "No vehicle or riding animal to start. Never keeps a beast of burden or a pet. Will ride in, or better on top of, a vehicle for short periods."
  - "About half learn to use a gun, most preferring a laser rifle. Seldom kills, for sport or in anger, and avoids taking even a villain''s life."
  - "Cybernetics: none. A few might accept a bio-system to stay alive or avoid being crippled; never implants, M.O.M. conversion, Juicer augmentation or any other unnatural procedure."
  - "Money: no figure is printed. Has little need for money and tends to spend it helping others, children above all."
extraction_notes: "This class followed Rifts World Book 20: Canada printed 166 (experience ladder printed 192) until this update; under the ruling of 2026-10-04 it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 176-177 (cache p177-p178, cache page = printed folio + 1). Every figure was read off page renders of both books. || D-BEES ENTRY: headed The Worldly Sasquatch O.C.C., it follows the Sasquatch entry (printed 173-176) and opens its stat block with Note: All stats are the same as above, except for the following - then R.C.C. Skills of the Worldly Sasquatch, Other Skills, Equipment, Money, Cybernetics, Allies, Enemies, and a closing note that it originally appeared in World Book 20: Canada. It prints no attribute requirements, no bonuses, no O.C.C. Related or Secondary skills, no skills gained by level and no Hand to Hand. || RACE: race_restrictions only true-sasquatch; the entry is an occupation for a Sasquatch who has left the wild, and the D-Bees Sasquatch entry (printed 175) says Available O.C.C.s: None, unless a Worldly Sasquatch. || GROUP: occ_group optional - the entry sits under no O.C.C. group heading in either book (in Canada it is in the Monsters of the North chapter under the True Sasquatch; in D-Bees it is inside the alphabetical Sasquatch entry); it states no sdc_base or mdc_base, so men_of_arms false, read off that same placement. The race supplies the M.D.C. || XP: D-Bees prints no ladder under the Worldly Sasquatch''s own name. Its Sasquatch entry (printed 175) says Use the same Experience Table as the Merc Soldier, and the Worldly entry takes all stats from that entry except the ones it lists, so xp_table is copied from the merc-soldier class as stored on 2026-10-04. Canada printed 192 gave a ladder of its own under the heading Worldly Sasquatch & Tundra Ranger Scout: 0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001. || SKILLS: both books print All the usual skills of the Sasquatch but at -5%; the race''s skills carry into the pairing at the race''s own figures and the -5% is NOT stored; it is a restriction line. D-Bees Other Skills line: Language: Other: American (+15%), +1 Language: Other of choice (+10%), Horsemanship: General and Exotic or two Piloting skills of choice, three W.P. skills (any), and 1D4+1 skills from Communications (+5%), Domestic (+5%), Medical, Technical and Wilderness (+10%). Stored as: two single picks of Language: Other at +15 and +10; a pick of three from Weapon Proficiencies; a pick of two (the minimum of 1D4+1; the note tells the player to roll) across the five categories with the three printed bonuses on their category entries; and a pick of two across Horsemanship (General and Exotic Animals only) and Pilot, whose note carries the either-or. Canada printed 166 gave: Two languages of choice (one is English at +15%) with no bonus on the second; three W.P. skills (any, but blunt or knife is typically one of them); 1D4+2 additional skills from Domestic, Communications, Medical, Technical and Wilderness with no category bonuses; and no Horsemanship or Piloting skills at all - its lore said the Sasquatch never ride an animal, a phrase D-Bees leaves out. || EQUIPMENT: the D-Bees list is the same as Canada''s item for item. One weapon for each W.P. is the catalog''s weapons-matching-w-p-skills row; 1D4+1 extra E-Clips; survival knife; pocket mirror; waterskin or canteen is a pick of two; utility belt; a few small sacks stored as one small-sack with the wording in its note (no number is printed); one large sack. NOT stored: a comb and/or brush and a loincloth (no catalog row), shorts (no Rifts row; BOOK-INGEST-AUDIT.md F140), and partial body armor with no helmet or shoes (neither book names a make of armor). The other-possible-items list (wristwatch or pocket watch, hand-held communicator, language translator, backpack or satchel, candy, jelly and jams) is optional and is in GM Notes. D-Bees closes the list with No vehicle or riding animal to start; Canada printed 166 gave No vehicle or riding animal, nor any large equipment. || MONEY: neither book prints dice, so no starting_money is stored and the race''s is none. D-Bees says only that the Worldly Sasquatch has little need for money and tends to use it to help others, especially children. Canada printed 166 added that a Big Foot adventurer will rarely have more than 1-2 thousand credits; D-Bees restates the Money line without that figure, so it is no longer in the restrictions. || Cybernetics and the city breaking point (26 hours +1 hour per M.E. point, doubled in a quiet place; the numeral 26 is printed in both books) are restriction and side-effect text, the same in both books. || D-Bees adds Allies and Enemies lines that Canada does not print for this occupation; they are in GM Notes."
---

## Lore

Now and then a Sasquatch walks out of the forest and into the world of
humans. Such a one is curious and adventuresome, and always unattached: a
youngster who has not yet found a mate, or an elder whose mate has died
and whose children have families of their own. Three in four are male.

A Worldly Sasquatch is most at ease among Native Americans, Shamans,
Druids, Cyber-Knights and anyone else who lives close to the land, but
will travel with any company so long as most of it is good at heart.
Selfish and evil companions are not tolerated for long.

The adventurer picks up a little of the modern world. Simple tools and
melee weapons come first, Vibro-Blades and Neuro-Maces especially. Most
put on partial armor, and about half learn to shoot, favoring the laser
rifle for being quiet, accurate and long-ranged. None of it changes the
gentle nature underneath: a Worldly Sasquatch still will not kill in
anger or for sport, keeps no pets or beasts of burden (though dogs tend
to adopt one anyway), and cannot bear a city for more than a day or so.

## GM Notes

Otherwise the same as the True Sasquatch R.C.C.: its attributes, M.D.C.,
natural abilities, psionics and combat bonuses all apply.

Skills: the usual Sasquatch skills are at -5% for a Worldly Sasquatch;
the sheet shows the race''s figures, so subtract 5% by hand. Roll 1D4+1
for the additional skills from Communications (+5%), Domestic (+5%),
Medical, Technical and Wilderness (+10%); the sheet offers two. The last
pick is Horsemanship: General and Horsemanship: Exotic Animals together,
or two Piloting skills, never one of each.

Starting kit beyond what the sheet lists: a comb and/or brush, probably a
loincloth or shorts, and partial body armor with no helmet or shoes
(two-thirds wear it; never full environmental armor). Other possible
items: a wristwatch or pocket watch, a hand-held communicator, a language
translator, a backpack or satchel, and candy, jelly and jams of every
kind, since the Sasquatch has a sweet tooth. No vehicle or riding animal
to start.

Money: no dice are printed. These adventurers learn what money and trade
goods are for but have little need of either, and tend to spend what they
have on helping others, children above all, human and D-Bee alike.

City breaking point: 26 hours +1 hour per M.E. point, doubled somewhere
quiet. Past it the character is depressed (attacks, bonuses and skills
halved) or fixed on escape. An ordinary woodland Sasquatch reaches it in
half the time.

Allies: like-minded people, heroes, and anyone who shows compassion.
Enemies: hates demons and anyone who uses, mistreats or enslaves others;
dislikes soldiers and does not trust practitioners or creatures of magic.
',
       updated_at = datetime('now')
 WHERE class_id = 'worldly-sasquatch'
   AND instr(markdown, 'NOT stored, no catalog row: comb and/or brush, loincloth or shorts') > 0
   AND length(markdown) = 11308;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 6 classes carry their new text' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE (class_id = 'fingertooth-carpetbagger' AND instr(markdown, 'mechanical-pencil-lead-24-in-a-pack') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'Psionic Empathy with Reptiles has a catalog row') > 0)
    OR (class_id = 'flooper' AND instr(markdown, 'The jacket names no kind and the catalog''s Rifts jackets are specific ones') > 0)
    OR (class_id = 'shaper' AND instr(markdown, 'the bag of hats names no kind and the catalog''s Rifts hats are specific ones') > 0)
    OR (class_id = 'vintex-warrior' AND instr(markdown, 'a skills.mos with one option per category could hold it') > 0)
    OR (class_id = 'worldly-sasquatch' AND instr(markdown, 'shorts (no Rifts row; BOOK-INGEST-AUDIT.md F140)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'fingertooth-carpetbagger' AND instr(markdown, 'the format has no way for a race to cancel an occupation''s secondary picks') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'The four reptile powers have no catalog rows') > 0)
    OR (class_id = 'flooper' AND instr(markdown, 'No catalog row for costumes, jacket, juggling pins') > 0)
    OR (class_id = 'shaper' AND instr(markdown, 'Not stored, no catalog rows and not stubbed: a bag of hats') > 0)
    OR (class_id = 'vintex-warrior' AND instr(markdown, 'the one-category rule cannot be enforced') > 0)
    OR (class_id = 'worldly-sasquatch' AND instr(markdown, 'NOT stored, no catalog row: comb and/or brush, loincloth or shorts') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('fingertooth-carpetbagger', 'lyvorrk', 'flooper', 'shaper', 'vintex-warrior', 'worldly-sasquatch') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~206-book-ingest-audit-f140-dbees.sql');
