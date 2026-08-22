-- The Crazy O.C.C., Rifts Ultimate Edition p.53-57.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-crazy-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-crazy-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'crazy', 'Crazy', 'rifts', '---
id: crazy
name: Crazy
system: rifts
source_book: Rifts Ultimate Edition p.53-57
category: occ
ppe_base: "6d6"
starting_money: "2d6x100"
bonuses:
  attributes: { PS: "2d4", Spd: "4d6", PP: "1d6" }
  attribute_minimums: { PS: 19, PP: 17 }
  pools: { sdc: "3d6x10", hp: "1d6" }
  combat: { initiative: 2, attacks: 1, roll: 4 }
  saves: { psionics: 2, possession: 2, mind_control: 6, toxins_poisons: 4, harmful_drugs: 4 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 1 }
    - { choose: 1, categories: ["Communications"], bonus: 15, note: "Language: Other, one of choice (+15%)." }
    - { name: "Climbing", base: 60, per_level: 5 }
    - { name: "Dance", base: 45, per_level: 5 }
    - { name: "Detect Ambush", base: 40, per_level: 5 }
    - { name: "Detect Concealment", base: 40, per_level: 5 }
    - { name: "Electronic Countermeasures", base: 40, per_level: 5 }
    - { name: "Escape Artist", base: 40, per_level: 5 }
    - { name: "Gymnastics", base: 50, per_level: 5 }
    - { name: "Land Navigation", base: 46, per_level: 4 }
    - { name: "Prowl", base: 45, per_level: 5 }
    - { name: "Radio: Basic", base: 55, per_level: 5 }
    - { name: "Streetwise", base: 30, per_level: 4 }
    - { name: "Tailing", base: 45, per_level: 5 }
    - { name: "Swimming", base: 70, per_level: 5 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient Weapons: two of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapons: two of choice." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Assassin if an evil alignment; may be changed to Hand to Hand: Commando at the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 7
    categories: ["Communications", "Domestic", "Espionage", "Horsemanship", "Medical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
    note: "Communications: Any (+5%). Espionage: Any (+10%). Horsemanship: General and Exotic Animals only (+5%). Mechanical: Automotive and Locksmith only, no bonus. Medical: First Aid, Paramedic or Holistic Medicine only (+10%). Military: Any (+5%). Physical: Any (+10% where applicable). Pilot: Any (+5%). Pilot Related: Any, no bonus. Rogue: Any (+5%). Science: Math and Astronomy skills only, no bonus. Technical: Any, no bonus. W.P.: Any, no bonus. Wilderness: Any, no bonus. Cowboy: None. Electrical: None."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1, note: "Including Coalition armor." }
  - { item_id: "dress-clothing", qty: 1 }
  - { item_id: "black-clothing-covert", qty: 1 }
  - { item_id: "gas-mask-and-air-filter", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "hatchet", qty: 1 }
  - { item_id: "knife", qty: 4 }
  - { choose: 2, label: "ancient weapons of choice", qty: 2, from: ["broadsword", "axe-battle", "axe-throwing", "bo-staff", "club-stick-pipe", "arab-mace", "cross-bow", "beaked-axe"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { item_id: "vibro-knife", qty: 1 }
  - { choose: 1, label: "energy handgun", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-super-laser-pistol-and-grenade-launcher", "wilk-s-320-laser-pistol"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "energy rifle", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "emergency-food-rations", qty: 1, note: "Two week supply." }
  - { item_id: "geiger-counter", qty: 1 }
psionics:
  type: "minor"
  isp_base: "6d6"
  powers_starting: 3
  categories_allowed: ["Psychic Sensitive", "Physical Psychic"]
special_abilities:
  - name: "Super Endurance"
    description: "Add 3D6x10 to S.D.C., add 5D6 to Hit Points, and +1D6 to P.E. attribute. The Crazy can lift and carry twice as much as a normal person of equivalent strength and endurance, and can last 10 times longer before feeling the effects of exhaustion. Can remain alert and operate at full efficiency for up to three days (72 hours) without sleep. Needs only four hours of sleep per day to function at full capacity."
  - name: "Increased Strength"
    description: "P.S. falls under the ''Augmented'' category same as Headhunters/partial cyborgs and Juicers."
  - name: "Increased Speed"
    description: "The Crazy can leap 20 feet (6 m) across and 15 feet (4.6 m) high after a short run (half that distance from a dead stop)."
  - name: "Heightened Reflexes and Agility"
    description: "The combination of training and enhanced physical capabilities of the M.O.M. brain implants also provides exceptional balance and grace (reflected in Physical skill bonuses and +20% to maintain balance as applied from skills like Acrobatics and Gymnastics)."
  - name: "Enhanced Senses"
    description: "+3 on Perception Rolls even when acting silly and bouncing around, or seemingly bored. Very alert. Enhanced vision provides perfect 20/20 vision and exceptional long-range, hawk-like vision; can read a small sign or recognize a face from up to two miles (3.2 km) away when he concentrates, must have line of sight. Enhanced hearing lets the Crazy hear a whisper or a twig snap under someone''s boot up to 300 feet (91.5 m) away; gives an automatic dodge on all attacks, even from behind and surprise attacks (does NOT use up a melee attack; normal dodge bonuses do not apply, but P.P. bonuses do). Enhanced sense of smell enables the character to instantly recognize odors (01-65%), recognize a person by scent like a dog (01-25%), and even track by smell (01-30%), provided the scent is not more than two hours old. Enhanced sense of taste is so acute the character can taste for a specific flavor, discern specific ingredients, and tell if a drink or food has been poisoned, drugged or spoiled; chance for detection is 01-55%, +20% if the chemical has a telltale taste or odor to begin with. Enhanced sense of touch enables the character to recognize very slight differences in textures by touch; adds a +10% bonus to all skills that require a delicate touch, such as Art, Demolitions, Palming, Pick Pockets, Pick Locks, Electronics, etc."
  - name: "Enhanced Healing"
    description: "Heals two times faster than normal; +15% to save vs coma and death. Virtually impervious to pain, no amount of physical pain will impair the Crazy until he is down to 10 Hit Points or less. At that point the warrior will suddenly realize his condition and start to feel the effects of his injuries. However, the Crazy can go into an intense meditative trance that will induce Bio-Regeneration, healing damage in moments."
  - name: "Crazies'' Bio-Regeneration"
    description: "The Crazy must stop to slip into a meditative trance. While in the trance, he is completely helpless and cannot move or take any action. All of his concentration is being focused into an accelerated bio-feedback program that will restore 2D6 Hit Points and 3D6 S.D.C., stop bleeding, and close wounds in 2D4 minutes. An extended period of Crazies'' Bio-Regeneration, over a period of six hours, will restore all S.D.C. and an additional 4D6 Hit Points."
  - name: "Suffers from Delusions and Insanity"
    description: "Everything is fine initially, but as time goes on, the character gets increasingly more disturbed. See Insanities in the rules section for details. At second level roll once on the Phobia Table. At third level roll once on the Affective Disorder Table. At fourth level roll on the Random Crazy Insanities Tables; it can lead to multiple personalities and delusions. At sixth level roll on the Obsession Table. At eighth level roll on the Phobia Table again. At tenth level roll on the Neurosis Table. At twelfth level roll on the Psychosis Table. At fourteenth level roll for a Random Insanity."
level_progression:
  - level: 2
    grants: ["Roll once on the Phobia Table"]
  - level: 3
    grants: ["Roll once on the Affective Disorder Table"]
  - level: 4
    grants: ["Roll on the Random Crazy Insanities Tables; can lead to multiple personalities and delusions"]
  - level: 6
    grants: ["Roll on the Obsession Table"]
  - level: 8
    grants: ["Roll on the Phobia Table again"]
  - level: 10
    grants: ["Roll on the Neurosis Table"]
  - level: 12
    grants: ["Roll on the Psychosis Table"]
  - level: 14
    grants: ["Roll for a Random Insanity"]
restrictions:
  - "Race Limitation: The M.O.M. process is designed for humans, but will also work on Ogres. D-Bees and other races attempting M.O.M. implants have a 01-80% likelihood of the character being accidentally lobotomized (roll up a new character); rare nonhuman successes do NOT induce psionic abilities and instead cause one extra insanity immediately and another at levels 4, 8 and 10, all rolled on the Random Insanity Table in the Rules Section."
  - "M.O.M. implants do not work on supernatural beings or creatures of magic."
  - "Will avoid bionics: only optical, lung and weapon implants are acceptable cybernetics; takes great pleasure in supposedly ''natural'' abilities."
  - "Never uses power armor or robot vehicles."
side_effects: "The M.O.M. conversion has a tendency to wear out the human body and has a number of unpleasant and unavoidable side effects, the worst of which is mental illness; over time, every recipient of M.O.M. suffers from increasing mental instability (hence ''Crazies''). This manifests as an escalating series of insanity rolls at set experience levels (see level_progression) that can lead to multiple personalities and delusions."
extraction_notes: |
  - Attribute Requirements: None, just a willingness to subject oneself to M.O.M. conversion ' || char(8212) || ' field omitted per schema rule.
  - Hand to Hand type starts as Martial Arts (or Assassin if evil alignment) per O.C.C. Skills list, distinct from the default Basic; recorded as a skill entry with note.
  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category (excluding Astral Projection, Ectoplasm, Object Read and Telekinesis); I.S.P. base 6D6 plus M.E. attribute number, +1D6 I.S.P. per level of experience starting at level two. The per-level ISP growth and category exclusions are prose-only, not expressible as a clean bonus.
  - Bonuses to specific skills (Physical skill bonuses, +20% balance from Acrobatics/Gymnastics, sense-based skill bonuses) are conditional/skill-specific and kept as prose per instructions, not encoded as flat bonuses.
  - Equipment: two ancient weapons of choice, one energy handgun, one energy rifle - book does not enumerate specific weapon options, so equipment_starting choice entries have empty "from" lists; GM/catalog must supply valid slugs.
  - Money: starts with 2D6x100 credits, plus a black market item worth 1D6x1000 credits (not encoded ' || char(8212) || ' starting_money records only the credit figure per schema, the black-market item is a separate windfall not a straightforward equipment entry).
  - Cybernetics note: "None, other than M.O.M., but may consider optical, lung, and weapon implants."
  - Related O.C.C.s referenced: Rifts Sourcebook 3: Mindwerks (variants on the Crazy) and Rifts World Book 9: South America Two (TW Ultra-Crazy O.C.C.) ' || char(8212) || ' not extracted as they are different books/classes.
  - Random Crazy Insanity Table, Frenzy, and Power by Association mechanics (pages 57) are extensive GM-facing subsystems tied to the O.C.C.; summarized in GM Notes rather than forced into schema fields.
---

## Lore

The warriors known as "Crazies" are a cross between ninja masters and raving lunatics. They are trained warriors schooled in the arts of combat and athletics. Then, they are augmented through the implantation of tiny electromagnetic devices placed in the brain.

The original project was developed in South America, where scientists were experimenting with new methods of curing mental disorders caused by physical damage, such as brain tumors and scar tissue. In the process of mapping and understanding the brain, they discovered a way to artificially stimulate it to counteract certain mental disorders and brain damage. Nano-technology made it possible to implant tiny devices directly into the brain to control its electrical impulses. Soon they found other applications that augmented the subject''s physical abilities. The right implant placed in the right spot could enhance speed, reaction time, reflexes and stimulate muscle growth for strength. Another placed elsewhere could block pain, accelerate healing and raise the body''s performance to incredible levels of efficiency. The brain implants and neurological stimulation also provided the surprising bonus of instilling or bringing out *minor psionic abilities* in all test subjects.

Suddenly, the priority of finding medical cures was thrown out the door in favor of the more lucrative and spectacular developments in human augmentation. The project was renamed M.O.M. Works (Mind Over Matter). The goal: to create a superhuman by rewiring the brain. Surprisingly, this augmentation works better on humans than on animals or even mutant animals. Unfortunately, the M.O.M. conversion has a tendency to wear out the human body and causes mental illness, hence the name "Crazies" (sometimes called "Momma''s Boys," a slang term derived from the M.O.M. acronym).

Most M.O.M. implants are tiny, about the size of a pea to the head of a pin. The famous metallic rods protruding from the skull, which have become the trademark of Crazies, are absolutely unnecessary; they''re worn for style, panache and character ' || char(8212) || ' for shock value, since without them there''s nothing obvious or special about the Crazies. The big skull rods trace back to the first generation of Crazies that appeared mid-way through the Two Hundred Years Dark Age, using an archaic prototype technology; they became legendary despite deranged and unpredictable antics. When the later, perfected M.O.M. conversion made small implants possible, Crazies insisted on large studs anyway, refusing to lose their unique, feared identity.

A person can become a Crazy by enlisting in the army of a feudal state that offers brain augmentation technology. A common arrangement is mental conversion and good pay (3D4x10,000 credits a year) for two years of loyal service in the army. After the two years of service, the Crazy can re-up or go off on his own. Some cities like Northern Gun, Kingsdale, and MercTown, as well as certain Black Market Body-Chop-Shops and high-tech bandits, also offer the conversion in exchange for services rendered, or at the price of 500,000 credits.

The Coalition has outlawed this technology and will rarely hire Crazies as mercenaries; anyone convicted of creating Crazies in the Coalition ''Burbs is executed. Still, an occasional Body-Chop-Shop will offer M.O.M. conversion at a price of about 350,000 credits or an agreement to work for the chop-shop proprietor or a sponsor for a period of time.

**Being a Crazy Man:** The crazy-man character is wild, flamboyant, and jocular ' || char(8212) || ' a cross between Daffy Duck, a dramatic actor, swashbuckler and a stand-up comic on speed. Zany, dynamic, caustic and hyper, the Crazy is a wisecracking daredevil who seems to be as cocky and carefree leaping into the jaws of death as at a tea party. He batters opponents with sarcastic quips, bad jokes and silly observations while socking it out with him or facing the barrel of a gun. Crazies fidget constantly and laugh, giggle or snicker at the most unusual times, often during combat, under high pressure or triumph ' || char(8212) || ' sometimes effective at rattling foes, other times downright annoying or scary. They tend to be fearless, reactionary, believe themselves indestructible, take needless risks, and disregard personal safety, especially when an innocent life is at stake. Being physically and action oriented, they tend to be impatient with skills requiring sitting still or intense contemplation ' || char(8212) || ' hence the low O.C.C. Related Skill bonuses. As a reactionary, the Crazy tends to be naive and a sucker for a sad tale, good cause, sad child, puppies or a pretty face.

**Game Designer''s Secret:** Crazies and Juicers were two of the author''s early concepts, seen as equal parts deadly assassin, daredevil warrior, acrobat and clown ' || char(8212) || ' a contrast to the more somber, serious Juicer. Both are tragic figures with a limited amount of time before they burn out (Juicers physically, Crazies mentally), and Crazies see themselves as rivals to Juicers, teasing and competing to prove they''re better ' || char(8212) || ' though Juicers are usually just a tad superior.

## GM Notes

**Random Crazy Insanity Table** ' || char(8212) || ' select one wild, crazy characteristic or roll percentile: 01-40% Frenzy, 41-80% Power by Association, 81-00% Multiple Personalities.

**Frenzy:** The Crazy appears normal most of the time but flies into a wild, uncontrolled rage under high pressure conditions. Triggers (roll percentile): 01-20% Intense Frustration, 21-40% Intense Anger, 41-60% Intense Pain, 61-80% Intense Sorrow, 81-00% Extreme Tension or Anxiety. During a frenzy the character gains +1 attack per melee round, +30 to S.D.C. (temporary ' || char(8212) || ' fades after, does not carry over to permanent S.D.C.), +1 to strike, parry, dodge and roll with impact, Spd increased by 30%, and +1D6 to damage (applies to all physical attacks including melee weapons, but not guns). Duration: one melee (15 seconds) per point of P.E. The frenzy will not stop until all opponents are defeated or the Crazy is subdued; the character cannot distinguish friend from foe once frenzied.

**Power by Association:** The Crazy believes he gains strength, skills, luck and psionic powers from a particular object or otherworldly source. Not true, but the character is totally psychologically dependent on the object/belief; without it (or when threatened) he may become a coward or catatonic. Roll percentile to determine the source: 01-16% Daytime Complex, 17-30% Nighttime Complex, 31-50% Popeye Syndrome, 51-70% Magic Object, 71-85% Power Words, 86-00% Solar Syndrome.

Related O.C.C.s: Rifts Sourcebook 3: Mindwerks has variants on the Crazy, as does Rifts World Book 9: South America Two with its TW Ultra-Crazy O.C.C. ' || char(8212) || ' these are separate stat blocks in other books and not reproduced here.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'crazy');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'crazy';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-crazy-class.sql');
