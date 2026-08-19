-- Bonuses the books grant that had nowhere to go until derive.js gained the
-- keys for them. Both were recorded as prose during the class audit precisely
-- because writing them would have done nothing.
--
--   Chiang-Ku (Dragons and Gods p.23): adult +2 to pull punch and +3 to save vs
--   illusionary magic; hatchling +1 to save vs illusionary magic.
--
--   Juicer (Rifts p.69, Power #5): +6 to save vs mind control, psionic and
--   chemical.
--
-- Guarded with instr() rather than LIKE, deliberately. `_` is a single-character
-- WILDCARD in a LIKE pattern, so '%mind_control%' also matches the plain words
-- "mind control" -- which the Juicer's own notes contain. The first version of
-- this script used LIKE and silently updated nothing at all.

UPDATE imported_classes
   SET markdown = '---
id: chiang-ku-dragon
name: Chiang-Ku Dragon
system: palladium-fantasy
source_book: dragons-and-gods
category: rcc
variants:
  - id: hatchling
    name: "Chiang-Ku Hatchling"
    attribute_dice:
      IQ: "3d6+4"
      ME: "3d6+4"
      MA: "3d6+4"
      PS: "3d6+4"
      PP: "2d6+3"
      PE: "2d6+3"
      PB: "2d6+3"
      Spd: "3d6+4"
    hit_points_base: "1D4x100 in human form, plus 100 when in serpent form"
    sdc_base: "2D6x10 plus 3D6 per level of experience"
    ppe_base: "2D4x10+20"
    bonuses:
      combat: { parry: 1 }
      saves: { spell_magic: 1, ritual_magic: 1, illusionary_magic: 1, horror_factor: 2 }
  - id: adult
    name: "Adult Chiang-Ku"
    attribute_dice:
      IQ: "3d6+12"
      ME: "3d6+12"
      MA: "3d6+12"
      PS: "3d6+12"
      PP: "2d6+10"
      PE: "2d6+10"
      PB: "2d6+10"
      Spd: "3d6+12"
    hit_points_base: "3D4x100+1000 when in natural serpent form (only 3D4x100 when in humanoid form)"
    sdc_base: "4D6x100"
    ppe_base: "2D4x100+200 plus P.E. attribute number"
    bonuses:
      combat: { initiative: 1, strike: 1, parry: 2, dodge: 2, roll: 2, pull_punch: 2 }
      saves: { psionics: 1, spell_magic: 2, ritual_magic: 2, illusionary_magic: 3, horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Basic Math", base: 96 }
    - { name: "Advanced Math", base: 96 }
    - { name: "Cook", base: 80, per_level: 5 }
    - { name: "Dance", base: 80, per_level: 5 }
    - { name: "Fishing", base: 80, per_level: 5 }
    - { name: "Play Musical Instrument", base: 80, per_level: 5 }
    - { name: "Sewing", base: 80, per_level: 5 }
    - { name: "Language: All (magical)", base: 98, note: "Magically understands and speaks all languages." }
    - { name: "Literacy: Dragonese/Elven", base: 98 }
    - { choose: 3, categories: ["Technical"], base: 80, per_level: 5, note: "Three other languages of choice, at least one human (+30%). The catalog has no individual language rows, so this offers the Technical category; pick languages." }
    - { name: "Art", base: 45, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Writing", base: 35, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Disguise", base: 30, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Lore ' || char(8212) || ' Faerie", base: 40, per_level: 5, note: "+15% O.C.C. bonus" }
    - { name: "Lore: Demons & Monsters", base: 30, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Land Navigation", base: 36, per_level: 4 }
    - { name: "Wilderness Survival", base: 30, per_level: 5 }
    - { name: "Streetwise", base: 20, per_level: 4 }
    - { choose: 3, categories: ["Science"] }
    - { choose: 3, categories: ["Technical"], note: "Scholar/Technical" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three ancient weapon proficiencies of choice" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three modern weapon proficiencies of choice" }
psionics:
  type: "major"
  isp_base: "3D4x10 + M.E. attribute number"
  powers_starting: 7
  categories_allowed: ["Healing", "Physical", "Sensitive"]
natural_abilities:
  - name: "Impervious to Poison, Toxins, Drugs, and Gases"
    description: "The Chiang-Ku is unaffected by these substances."
  - name: "Nightvision"
    description: "90 ft (27.4 m)."
  - name: "See the Invisible"
    description: "Can perceive normally invisible creatures and objects."
  - name: "Fire and Cold Resistant"
    description: "Takes half damage from fire and cold based attacks."
  - name: "Dimensional Teleport"
    description: "90% chance of success. Note: ordinary (non-dimensional) teleportation and breath weapons are NOT among the powers of the Chiang-Ku."
  - name: "Instinctive Dimensional Magic"
    description: "An innate understanding and use of dimensional magic."
  - name: "Bio-Regeneration"
    description: "Recovers 1D4x10 S.D.C./hit points every five minutes."
  - name: "Natural Armor Rating"
    description: "Natural A.R. is 14 for an adult and 11 for a hatchling."
  - name: "Horror Factor"
    description: "13 for an adult, 9 for a hatchling."
special_abilities:
  - name: "Exceptional Metamorphosis"
    description: "A power of metamorphosis common to most dragons, but no other dragon possesses the degree of control and duration as the Chiang-Ku. Even as a hatchling, the dragon is a shapechanger supreme, able to completely alter its physical shape to look like any living animal, from human being to raven, and can even turn into mist (same as the spell). The transformation lasts indefinitely (mist has the same limits as the spell) ' || char(8212) || ' weeks, months, or years! Even when rendered unconscious or sleeping, the Chiang-Ku retains its false shape. Only coma or death will transform the dragon into its true serpentine body. The dragon''s shape-changing prowess is so great that it can try to copy/imitate a particular person or specific animal at a skill proficiency of 10% +5% per level of experience."
  - name: "Attacks Per Melee (Adult)"
    description: "Equal to basic hand to hand combat and varies with the level of experience. The magic tattoos automatically provide one additional attack per melee round."
  - name: "Damage"
    description: "Varies with supernatural P.S. or by magic or weapon. The tail has no extra abilities and cannot be used in combat."
  - name: "Magic Knowledge"
    description: "The Chiang-Ku are born with a full understanding of magic and some say, a secret, lost mystic art that they never share with others and seldom use (tattoo magic and the creation of the Elixir of Power and Deceit; see Rifts Atlantis and England). The Chiang-Ku never uses these powers on the Palladium World because their secrets were lost during the Time of a Thousand Magicks and even hints of them were destroyed during the Millennium of Purification. Even using the magic tattoos may entice somebody to attempt to figure out/develop the magic, so most Chiang-Ku never use them even in a life and death situation; only miscreant and diabolic dragons may consider their use. While most Chiang-Ku won''t use tattoo magic, all have at least a half dozen tattoos on their bodies, including the Marks of Heritage mystic symbol of the Eye of Knowledge."
  - name: "Study of Mystic Arts"
    description: "The hatchling knows no spell magic unless they study the arts of wizardry, but can intuitively use all types of magic devices without instruction, can read magic, use scrolls, and recognize magic circles, rune weapons and enchantment. Most study one form of mystic art: 50% Wizardry, 20% Diabolism, 20% Summoning, 5% other (an alien magic, or Necromancy, or Warlock, or is a nonmagical scholar). Adult Chiang-Ku Wizards of 8th level or higher experience are likely to know all spells from levels 1-9 plus 2D4 higher spells. Wizards higher than 15th level will also know all spells from levels 1-15 and many Spells of Legend (G.M.''s discretion)."
restrictions:
  - "Weaker with less hit points when in humanoid form, and generally has less hit points and S.D.C. than many of its brethren."
  - "The Chiang-Ku''s curiosity and compassion for others frequently gets the creature into trouble."
extraction_notes: |
  - This entry covers only the Palladium Fantasy (Dragons and Gods) statistics. The page also includes a separate "Chiang-Ku Rifts Stats" conversion block (M.D.C., Rifts R.C.C. Skills) which was intentionally omitted per import instructions.
  - "Average level of experience of an adult is 1D4+7" and hatchling starting skill proficiencies (language and basic math at 96%, all other skills starting at first level) are NPC-generation notes not captured by a schema field.
  - "Skill proficiency depends on the level of experience, plus I.Q. bonus (if any)" applies to the skill list as a general modifier not encodable per-skill.
  - Magic Knowledge/Study of Mystic Arts describes a percentile chance of studying one of several magic schools (50% Wizardry, 20% Diabolism, 20% Summoning, 5% other) rather than a fixed spells_starting/spell_levels_allowed value, so it was not forced into the `magic` schema field and is instead recorded under special_abilities.
  - Enemies, Allies, Habitat, and Average Life Span fields from the sourcebook have no corresponding schema field and are recorded in the Lore/GM Notes sections instead.
---

## Lore

The Chiang-Ku dragon is extremely rare on the Palladium World. Earthlings will recognize it as a Chinese dragon with a long serpentine body with triangular shaped, emerald green scales, two short forearms and one to two pairs of short legs; the feet have three toes. The head is slender and angular, and can look reptilian/dragon-like or a bit more lion-like; all have whiskers on their chin and a mouth filled with sharp teeth. The tail has no special feature or abilities.

The Chiang-Ku are said to be the wisest of all dragons and masters of magic. They are also said to be the most experienced dimensional travelers and are constantly exploring other worlds and investigating (and often helping) alien people. All Chiang-Ku have a high regard for life and have always been fond of human beings. In many respects, the Chiang-Ku can be considered the Paladin or missionary of Dragonkind. They are famous for protecting people of all races against supernatural evil and helping people to learn and stand on their own. To this end, the dragon is usually happy to teach people scholarly skills (languages, literacy, lore, etc.), as well as offer hints and suggestions on how to do things more efficiently. Occasionally, a Chiang-Ku will teach Wizards a helpful spell, but usually nothing beyond 5th level unless the creature knows the Wizard well and believes he will use his knowledge for good (even then it rarely shares knowledge above 10th level).

The Chiang-Ku''s helpful nature and affections for lesser beings, particularly humans, makes them the most knowledgeable of and comfortable among human civilization. A Chiang-Ku metamorphed into human guise can easily pass as the genuine article. Their favorite disguises when impersonating humans is that of a scholar, monk or priest. This disguise enables them to help humans in subtle ways from behind the scenes and without revealing their inhuman nature. They like to aid others by helping them help themselves. According to legend, a great purge conducted by the forces of darkness slew tens of thousands of these noble creatures. Exactly how many survived is unknown even to the dragons themselves. They speculate that there are probably as many as one hundred to one thousand scattered throughout the Megaverse. A Chiang-Ku is rumored to have started (and still helps operate) the monastic order that trains Undead Hunters (see Book 7: Yin-Sloth Jungles). Another is rumored to live in the Great Northern Wilderness and a third is rumored to be enslaved by an evil lord of the Western Empire.

**Alignment:** Any, but typically good or selfish.

**Size (adult):** 12 to 20 feet (3.6 to 6.1 m) long, including the tail which is typically one-quarter of the overall length. Stands about four feet (1.2 m) at the shoulders. In human form the dragon can range from about five to six feet (1.5 to 1.8 m) tall. Hatchlings are typically 10% smaller.

**Weight (adult):** 200 lbs (90 kg) in human form, 1000 lbs (450 kg) in serpent form. Hatchlings are about 20% lighter.

**Habitat:** Can be found anywhere.

**Average Life Span:** 6000 years; some are said to reach 10,000!

**Enemies:** None per se. Champions of Light will regard all creatures of darkness as their enemy. Demons, Deevils and gods of darkness like to torture and torment these dragons and occasionally engage in campaigns to destroy them.

**Allies:** Chiang-Ku get along famously with Kukulcans and other dragons of good alignment and intentions. They also regard humans and most Champions of Light as potential friends and allies. They are also said to associate with the Gods of Light.

## GM Notes

A Chiang-Ku PC is an unusually powerful and knowledgeable ally, but the honor code of restraint around tattoo magic and the Elixir of Power and Deceit should be respected in play ' || char(8212) || ' most Chiang-Ku, even evil-tempted ones, refuse to use or reveal these secrets on the Palladium World out of respect for the Elves'' and Dwarves'' choice to eradicate that magic. Reserve tattoo magic use for miscreant or diabolic Chiang-Ku antagonists.

Because the dragon''s helpfulness and curiosity are core to its concept, GMs can use these traits as complications: a Chiang-Ku PC or NPC is likely to intervene to teach, protect or advise even at personal risk, and its desire to see mortals solve their own problems ("helping people help themselves") can create friction with parties wanting more direct intervention.

The percentile chance of a young Chiang-Ku''s chosen field of study (50% Wizardry, 20% Diabolism, 20% Summoning, 5% other) can be used to quickly generate NPC dragons'' capabilities and outlook.',
       updated_at = datetime('now')
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, 'pull_punch') = 0;

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
    categories: ["Communications", "Domestic", "Electrical", "Espionage", "Mechanical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
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
  - Attribute additions (+2D6 P.S., +2D6 P.E., +2D4x10 Spd, +2D4 P.P.) cannot be
    expressed: bonuses.attributes takes flat numbers, not dice. Nor can the P.S. 22 /
    P.P. 20 minimums, which adjust an attribute up rather than gate the class.
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
   AND instr(markdown, 'mind_control') = 0;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('apply-new-bonus-keys.sql');
