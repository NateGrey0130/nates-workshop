-- Per-category related-skill restrictions, now that a category may be an object
-- rather than only a name.
--
-- Every book states these per category and we were offering each one wholesale,
-- so a Long Bowman could take Pick Pockets as an "Espionage" skill when the
-- entry allows Escape Artist and nothing else.
--
--   Long Bowman (PF p.84): 8 of 12 categories restricted.
--   Cyber-Knight (Rifts p.64): Electrical basic only, Mechanical automotive only.
--   Juicer (Rifts p.71): Electrical, Espionage, Mechanical and Science limited.
--
-- Some named skills do not exist in the catalog yet (Sign Language, Falconry,
-- Ventriloquism, Locate Secret Compartments). Naming them is harmless -- an
-- `except` entry for a missing skill excludes nothing, and an `only` entry for
-- one narrows the category to what does exist -- and the restriction is already
-- correct for the day they are imported.
--
-- Guarded with instr() on the old flat list, so re-running is a no-op.

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
    categories:
      - { name: "Communications", only: ["Sign Language"] }
      - "Domestic"
      - { name: "Espionage", only: ["Escape Artist"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", except: ["Camouflage", "Falconry", "Interrogation"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Rogue", except: ["Locate Secret Compartments", "Ventriloquism"] }
      - { name: "Science", only: ["Basic Math", "Advanced Math"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
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
   AND instr(markdown, 'categories: ["Communications", "Domestic", "Espionage", "Horsemanship"') > 0;

UPDATE imported_classes
   SET markdown = '---
id: cyber-knight
name: Cyber-Knight
system: rifts
source_book: rifts-core
category: occ
attribute_requirements:
  ME: 11
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "1d4x10"
ppe_base: "6d6"
starting_money: "2d6x100"
bonuses:
  combat: { initiative: 1, attacks: 1 }
  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }
skills:
  occ_skills:
    - { name: "Literacy", base: 50, per_level: 5 }
    - { name: "Language: Native Tongue", base: 96, per_level: 0 }
    - { name: "Language: Dragonese", base: 96, per_level: 0 }
    - { choose: 2, categories: ["Technical"], base: 80, per_level: 5, note: "Two additional languages of choice (+30%). The catalog has no individual language rows." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon (+20%)" }
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 48, per_level: 4, note: "+12%" }
    - { name: "Horsemanship: General", base: 55, per_level: 4, note: "+15%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, two of choice" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern, two of choice" }
  occ_related_skills:
    count: 12
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 3 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
equipment_starting:
  - { item_id: "cyber-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 2 }
  - { item_id: "ns-turbo-cyclone", qty: 1 }
psionics:
  type: "major"
  isp_base: "6d6+10, +1d6 per level"
  powers_starting: 3
special_abilities:
  - name: "Psi-Sword"
    description: "A mega-damage blade of psychic energy willed into existence. 1D6 M.D. at first level, plus an additional 1D6 M.D. at levels three, six, nine, twelve and fifteen. Costs no I.S.P., has no time limit, and can be created any number of times a day. A true knight will never use it against a foe who is unarmed, not equipped with an equivalent weapon, and not a supernatural creature or dragon."
  - name: "Cyber-Armor"
    description: "The one cybernetic implant a cyber-knight starts with: concealed body armor, A.R. 16 and 50 M.D.C."
  - name: "Psionics"
    description: "Eighty percent of cyber-knights are psychic (roll 01-80). A psychic cyber-knight is a major psionic, saves against psionic attack at 12 or higher, and picks three permanent powers from a fixed list: empathy, mind block, object read, see the invisible, sense evil, sense magic, sixth sense, speed reading, summon inner strength."
  - name: "Techno-Wizardry"
    description: "Open-mindedness toward magic makes the cyber-knight one of the few O.C.C.s able to intuitively understand and use items created through techno-wizardry."
level_progression:
  - level: 3
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 6
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 9
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 12
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 15
    grants: ["Psi-Sword damage +1D6 M.D."]
restrictions:
  - "Good alignments as a rule; aberrant and anarchist are acceptable. A knight may be corrupted and turn evil like anybody else."
  - "Bound by the Code of Chivalry: to live, fair play, nobility, valor, honor, courtesy and loyalty."
  - "Rarely uses power armor or robot vehicles."
extraction_notes: |
  - The 80% chance of having psionics at all is a per-character roll the class schema cannot state; the class is written as psychic, which is the common case.
  - The three starting psi-powers come from a named list of nine, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered.
  - Related-skill restrictions per category are not expressible: "Electrical: Basic only", "Mechanical: Automotive only" and "Physical: Any (+5% when applicable)" become plain categories. Medical is excluded entirely, per "none other than O.C.C. skill".
  - The level-five related-skill grant is specifically three W.P.s; the schedule records the count but not the category.
  - The black market item worth 1D6x1000 credits is not modelled; only the 2D6x100 starting credits are.
---
## Lore

Wandering champions of the Megaverse, the Cyber-Knights are an order of noble
warriors founded by Lord Coake. Part paladin, part ranger, they roam the wilds
of post-apocalyptic North America defending the weak against monsters, bandits,
and the excesses of the Coalition States alike. Each knight carries the
signature Psi-Sword ' || char(8212) || ' a weapon of pure psychic energy that cannot be taken
from them ' || char(8212) || ' and lives by a strict code of chivalry.

## GM Notes

A Cyber-Knight who grossly violates the Code of Chivalry should face in-game
consequences (loss of reputation with the order, possible visit from a senior
knight). House rule: no starting cybernetics beyond the Cyber-Armor graft.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, 'categories: ["Communications", "Domestic", "Electrical", "Espionage", "Mechanical"') > 0;

UPDATE imported_classes
   SET markdown = '---
id: juicer
name: Juicer
system: rifts
source_book: rifts-core
category: occ
hit_points_base: "P.E. + 1d4x10, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "4d6x100"
bonuses:
  combat: { initiative: 4, attacks: 2, roll: 4 }
  attributes: { PS: "2d6", PE: "2d6", PP: "2d4", Spd: "2d4x10" }
  attribute_minimums: { PS: 22, PP: 20 }
  saves: { psionics: 4, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5% O.C.C. bonus" }
    - { choose: 2, categories: ["Pilot"], note: "Piloting, two of choice, +10%" }
    - { choose: 3, categories: ["Communications"], note: "Language, three of choice, +10%" }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Expert", note: "Can be changed to Martial Arts or Assassin (if evil alignment) for the cost of one ''other'' skill." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Basic Math"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Electrical: Basic only. Espionage: Intelligence, Escape Artist, Detect Ambush, and Detect Concealment only (+5%). Mechanical: Automotive only. Medical: None (excluded). Military: Any (+10%). Physical: Any (+10% where applicable). Pilot: Any (+5% on all military types). Pilot Related: Any (+5%). Rogue: Any (+15% to Prowl). Science: Basic Math only."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "juicer-flex-plate-armor", qty: 1 }
  - { item_id: "optic-helmet", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "camouflage-fatigues-and-armor", qty: 1 }
  - { item_id: "grey-fatigues", qty: 1 }
  - { item_id: "boots-with-knife-holster", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "back-pack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "ja-11-juicer-assassin-s-energy-rifle", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-super-laser-pistol-and-grenade-launcher"] }
  - { item_id: "e-clip", qty: 1 }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-saber", "vibro-sword", "vibro-claws"] }
special_abilities:
  - name: "Super Endurance"
    description: "Add 1D4x100 S.D.C., add 1D4x10 hit points, and 2D6 to P.E. attribute. Can lift and carry four times more than a normal person of equivalent strength and endurance, and can last 10 times longer before feeling the effects of exhaustion. Can remain alert and operate at full efficiency for up to five days (120 hours) without sleep. Normally needs only three hours of sleep per day."
  - name: "Super Strength"
    description: "Add 2D6 to P.S. attribute. Minimum P.S. is 22; if lower, adjust up to P.S. 22."
  - name: "Super Speed"
    description: "Add 2D4x10 to Spd attribute. Can leap 30 feet (9.1 m) across after a short run (half from a dead stop), and 20 feet (6 m) high (half without a short run)."
  - name: "Super Reflexes and Reaction Time"
    description: "Bonuses: +4 to roll with punch, fall, or impact; +4 on initiative; automatic parry or dodge on all attacks, even from behind/surprise; two extra attacks per melee; add 2D4 to P.P. attribute (minimum P.P. 20, adjust up if lower). Penalties: cannot sleep without sedative or tranquilizers; tends to be jumpy and anxious; boredom is a constant enemy (bio-comp counters with tranquilizers/euphoria drugs, but can make the Juicer alert and ready for action in 15 seconds/one melee)."
  - name: "Saving Throw Bonuses"
    description: "+4 to save versus psionics, +6 to save versus mind control (psionic and chemical), +8 to save versus toxic gases, poisons, and other drugs. Bio-comp can slow blood flow or increase oxygen levels to slow the effects of drugs, or inject natural/synthetic chemicals to counteract immediately; the Juicer can also slip into a trance-like state to conserve oxygen."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal. +20% to save vs coma and death. Virtually impervious to pain - no amount of physical pain impairs the Juicer until reduced to 5 hit points or less, at which point he collapses into a bio-comp induced trance/coma of accelerated healing."
  - name: "IRMSS (Internal Robot Medical Surgeon System)"
    description: "Microscopic robots housed in an external chest-plate unit and an internal neck unit (controlled by the bio-comp). Injected into the bloodstream to stop bleeding, suture veins/arteries, and aid internal repair. Chest-unit robots reach any wound within 60 seconds but are eventually flushed from the body; the internal neck-housed robots recharge via the body''s electro-magnetic energy and can be reused indefinitely."
side_effects:
  - "The Juicer character WILL die after five (5) years and 4D6 months of being a chemically induced super man. No exceptions, no saving throws, no hope - the body is destroyed and used up. Not even psionic healing, magic restoration, or resurrection (-50%) can help."
  - "Average life expectancy is six years; without detox, a Juicer over five years old will die of stroke or heart failure before his eighth year of service."
  - "Detoxification (attempted only within the first three years for a real chance of success) permanently strips all Juicer bonuses/powers, forces selection of a new O.C.C. (Headhunter/Mercenary, Borg, City Punk, or Vagabond), reduces all physical attributes to 8 (+1D4 each), reduces P.B. by 1D4, ages the character 10 years for every year served, reduces S.D.C. to 5D6, removes all combat/initiative bonuses (-2 to initiative), and requires a roll on a permanent side-effect table (see GM Notes)."
extraction_notes: |
  - AUDIT (Rifts p.69-71): the class had NO pool formulas, so a Juicer was created
    with no hit points, no S.D.C. and no P.P.E. Hit points and S.D.C. now carry the
    Juicer Power #1 additions. P.P.E. is left absent because the entry never states one.
  - The signature bonuses were prose only and are now real: +4 initiative, two extra
    attacks, +4 roll with punch, +4 vs psionics, +8 vs toxins and drugs, +20% vs
    coma/death, and +6 vs mind control.
  - Percentage bonuses on choice groups (piloting +10%, languages +10%) cannot be
    applied: the members of a category have different bases, and a group carries one.
  - The "Add 1D4x100 S.D.C." and "add 1D4x10 hit points" (Juicer Power #1) and the P.S./Spd/P.P. bonuses are described as additions to an already-existing character''s rolled attributes/S.D.C./H.P., not as a standalone base formula, so they were not placed in sdc_base/hit_points_base and are instead recorded under special_abilities.
  - O.C.C. skill list gives percentage bonuses (e.g. +10%, +5%) but no explicit base/per-level percentages for the listed skills, so base/per_level fields were omitted for those entries.
  - Equipment list includes dice-based/choice-based quantities not captured by a single qty number: "2D4 E-clips for each" (energy rifle and pistol), "choice of two non-energy weapons," and "choice of three ancient weapon types (knife, mace, sword, etc.)." These are noted here rather than forced into equipment_starting quantities.
  - Detoxification is a full mini-subsystem: percentile success ratios by year of service (Year 1: 1-89%, Year 2: 1-76%, Year 3: 1-59%, Year 4: 1-27%, Year 5: 1-9%, Year 6: 1%, Year 7: 0%), a permanent side-effect roll table (01-100), and a separate "failed detox roll" table (01-100) with consequences up to suicide. These percentile tables don''t map cleanly to any schema field and are summarized in prose under GM Notes rather than encoded structurally.
  - "IMPORTANT NOTE" bonus for detox attempted in year one or two (+6D6 S.D.C., +2 to P.S./P.P./P.B., +2D6 Spd, and skip the side-effect table) is a conditional variant of the detox side-effects mechanic, noted here rather than forced into a field.
  - Money and cybernetics notes: Juicers start with 4D6x100 credits plus 4D6x100 credits in black market items, and start with NO cybernetics by choice/pride. Not modeled as a schema field.
---

## Lore

In man''s search to create the ultimate human, it was inevitable that someone would turn to chemical enhancement. The Juicer traces its origin to Eastern Europe''s rise of the super athlete/warrior, where steroids and EPO first pushed the body''s limits before a new technology emerged: the bio-comp system. Two tiny mega-computers, implanted in the head and/or chest and linked to hundreds of microscopic sensors threaded through the body, monitor blood flow, oxygen levels, adrenaline, hormones, and neurological responses, triggering precise doses of designer drugs through an injection collar and harness system worn under clothing and armor.

The bio-comp also drives the IRMSS (Internal Robot Medical Surgeon System) - microscopic robots that perform emergency internal surgery, injected via a chest plate over the heart (reaching any wound in the body within 60 seconds) or maintained permanently by an internal neck-housed unit recharged by the body''s own bioelectric energy.

The result is a superhuman: ten times faster, stronger, and more alert than an ordinary person, perceiving combat in what feels like slow motion. But the price is a terrible one. The chemical and physical strain literally burns the body out, inside and out - thickened blood, imbalanced blood cell counts, muscle spasms, crumbling bones, deteriorating organs, a ravaged immune system, and total drug dependency. A Juicer over five years old will, without exception, die of stroke or heart failure before his eighth year of service; average life expectancy is a mere six years. "Live fast. Die young."

In the world of Rifts, Juicers are typically psychopathic killers who don''t care if they die young, fools who don''t believe the horror stories, or desperate souls who become Juicers to support a family or seek revenge. Slaves and captives are sometimes forcibly converted by unscrupulous warlords. Most become Juicers by enlisting in a feudal state''s army in exchange for the conversion, big money (4D4x10,000 credits a year), and two years of loyal service - after which they''re free to go, and Juicer mercenaries are among the best-paid and most feared fighters in the Americas. The Coalition States have outlawed Juicer technology entirely and execute anyone convicted of creating one, though black-market Body-Chop-Shops still offer conversion for 300,000-400,000 credits to those chasing a brief taste of perfection.

Juicers tend to be bold, outspoken, cocky, and self-reliant warriors who live for action, always looking for something to do, and prone to taking unnecessary risks or accepting challenges of strength and skill to prove themselves the ultimate warriors.

## GM Notes

**Detoxification** is a Juicer''s only chance at a longer life, but it must be attempted within the first three years of service for real hope of success; after that the odds collapse toward zero. The process requires: (1) surgical removal of the bio-comp system (the data implants themselves can safely remain) and destruction of the drug harness, ideally by a cyber-doc; (2) selection of a new O.C.C. - only Headhunter/Mercenary, Borg, City Punk, or Vagabond are available, and most ex-Juicers shun further augmentation; the character keeps his old combat skills (frozen until his new O.C.C. catches up in level) and picks 7 new skills from the new class/other skills list; and (3) accepting steep permanent penalties - all Juicer bonuses gone forever, physical attributes reset to 8+1D4, P.B. reduced by 1D4, apparent age increased by 10 years per year of service, S.D.C. dropped to 5D6, hit points back to normal (P.E. + 1D6/level), initiative at -2, and a roll on a permanent side-effect table (stiffness/-1 to strike-parry-dodge-roll; weakened immune system; poor memory/-5% skills; new drug/alcohol dependency; or a rolled phobia and neurosis).

Mechanically, the detox attempt itself requires 2 of 3 successes on a percentile roll, re-attemptable weekly, with success chance dropping sharply by year of service (89% in year one down to 0% by year seven). A failed attempt triggers its own table, ranging from a new addiction, to permanently halved skills/combat bonuses/speed from depression, to a renewed desire to become a Juicer again, to suicide. If detox succeeds in year one or two, the character avoids the side-effect table and instead gets consolation bonuses (+6D6 S.D.C., +2 P.S./P.P./P.B., +2D6 Spd).

GMs running a Juicer PC should treat the five-year-and-4D6-months death clock as absolute and dramatic - it''s the class''s defining hook, not a mere suggestion. Consider tracking service time openly with the player so the looming mortality shapes roleplay and decision-making rather than arriving as a surprise ambush.',
       updated_at = datetime('now')
 WHERE class_id = 'juicer'
   AND instr(markdown, 'categories: ["Communications", "Domestic", "Electrical", "Espionage", "Mechanical"') > 0;
