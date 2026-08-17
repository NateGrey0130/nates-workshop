-- Juicer O.C.C. corrected against Rifts, p.69-71.
--
-- Model-imported, and its LISTS were right: the O.C.C. skill list, the
-- related-skill categories and their schedule, the six secondary skills and the
-- whole equipment list all match the book. So does every word of the prose
-- describing the Juicer's powers.
--
-- What was missing is everything that makes those words do something.
--
--   The class had NO pool formulas at all. No hit_points_base, no sdc_base, no
--   ppe_base -- so a Juicer was created with no hit points and no S.D.C.
--   whatsoever. Juicer Power #1 adds 1D4x10 hit points and 1D4x100 S.D.C. on
--   top of the normal P.E. + 1d6 per level, and neither was recorded.
--
--   The signature bonuses were prose only. +4 initiative, two extra attacks per
--   melee, +4 to roll with punch, +4 vs psionics, +8 vs toxic gases and drugs,
--   +20% vs coma and death -- all described, none applied. A Juicer had the
--   combat profile of an ordinary human.
--
--   Starting money (4D6x100 credits) was absent.
--
--   Three skill bonuses sat in notes with no base: Radio: Basic (+10%),
--   Wilderness Survival (+5%), Land Navigation (+5%).
--
-- Also repaired: mojibake. Two dashes had been stored as the raw UTF-8 bytes
-- decoded as latin-1 (0xE2 0x80 0x93/0x94), so the sheet showed a stray "a"
-- with control characters mid-sentence. The file is pure ASCII now.
--
-- Still not expressible, documented rather than faked:
--   +2D6 P.S., +2D6 P.E., +2D4x10 Spd, +2D4 P.P. -- bonuses.attributes takes
--     flat numbers, not dice; and the P.S. 22 / P.P. 20 minimums adjust an
--     attribute upward rather than gate the class.
--   +6 to save vs mind control -- no derive key.
--   Percentage bonuses on choice groups (piloting +10%, languages +10%) -- a
--     group carries one base and its members have different ones.
--
-- Guarded on the old prose-only Radio entry, so re-running is a no-op.

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
  saves: { psionics: 4, toxins_poisons: 8, harmful_drugs: 8, coma_death_pct: 20 }
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
    coma/death. The +6 vs mind control has no derive key and is still prose.
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
   AND markdown LIKE '%{ name: "Radio: Basic", note: "+10%" }%';
