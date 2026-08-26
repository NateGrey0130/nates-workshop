-- Combat Cyborg restored to the full O.C.C. stat block, RUE p.45-48.
--
-- The original import (add-combat-cyborg-class.sql) was built from an
-- excerpt that ended at printed p.47 and recorded, in its own notes, that
-- no skill list, equipment or money "is given anywhere in the excerpt".
-- True of the excerpt, false of the book: printed p.48 carries the whole
-- package, and a character built from this class got ZERO occupational
-- skills. Restored from the book (rue OCR cache, file p51 = printed p.48):
--
--   O.C.C. Skills: language, electronics/mechanics pick, repair, land
--     navigation, tanks & APCs, a pilot pick, radio, sensory equipment,
--     weapon systems, climbing, four W.P.s and Hand to Hand: Expert,
--     each at catalog base + printed bonus.
--   O.C.C. Related Skills: five at level one, +1 at 3, 7, 10 and 13,
--     with the printed category limits and bonuses.
--   Secondary Skills: four at level one, +1 at 4, 8 and 12.
--   Standard Equipment: the printed list, as catalog rows; the Starting
--     Extras bionic package and per-W.P. weapons stay prose (notes).
--   Money: starting_money 1D4x1,000 credits; the 4D4x100 in saleable
--     Black Market items stays prose per the coin-only rule.
--
-- Also corrected while here, against printed p.47: the save bonuses are
-- "+5 to save vs possession, +3 to save vs magic" - production had the +5
-- on magic and a +3 on psionics that the book does not print. Now
-- possession: 5, spell_magic: 3, ritual_magic: 3. source_book widened to
-- p.45-48, and the two stale "not in the excerpt" notes rewritten.
--
-- Guarded on the old saves line, so re-running is a no-op.

UPDATE imported_classes
   SET markdown = '---
id: combat-cyborg
occ_group: men-of-arms
name: Combat Cyborg
system: rifts
source_book: Rifts Ultimate Edition p.45-48
category: occ
mdc_base: "See M.D.C. by Location table (Main Body 180, max. 280 M.D.C.)"
attribute_requirements:
  ME: 10
starting_money: "1d4x1000"
bonuses:
  saves: { possession: 5, spell_magic: 3, ritual_magic: 3 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%)." }
    - { choose: 1, from: ["Basic Electronics", "Basic Mechanics"], bonus: 10, note: "Basic Electronics or Basic Mechanics (+10%; pick one)." }
    - { name: "General Repair & Maintenance", base: 50, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Military: Tanks & APCs", base: 41, per_level: 4, note: "Pilot: Tanks & APCs (+5%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%), excluding Robot and Power Armor skills." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Read Sensory Equipment (+10%)." }
    - { name: "Weapon Systems", base: 45, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient Weapons: one of choice." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapons: two of choice (may include W.P. Heavy Energy Weapons)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be upgraded to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of two O.C.C. Related Skills, but only when the character is being initially created." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", only: ["Intelligence", "Tracking (people)"] }
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS"], bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", only: ["Gambling (Standard)", "Gambling (Dirty Tricks)", "Find Contraband"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
    note: "Cowboy and Wilderness: none. Physical: any, but only those still appropriate for a full conversion cyborg. Rogue: Gambling and Find Contraband only."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { choose: 1, label: "poncho or hooded cloak", qty: 1, from: ["poncho", "hooded-cloak"] }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "cord", qty: 1, label: "100 feet (30.5 m) of heavy cord or cable" }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1, label: "language translator (unless built-in)" }
  - { item_id: "utility-belt", qty: 2 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "flare", qty: 4 }
  - { item_id: "walkie-talkie", qty: 2 }
  - { choose: 1, label: "hovercycle or motorcycle", qty: 1, from: ["hovercycle", "road-boss-motorcycle", "the-wastelander-motorcycle", "the-highway-man-motorcycle"] }
extraction_notes: |
  - RUE p.45-48. The original import was built from an excerpt ending at
    p.47 and recorded that no skill, equipment or money block existed; the
    full O.C.C. stat block on p.48 (O.C.C. Skills, Related, Secondary,
    Standard Equipment, Money) was restored from the book in a later fix.
  - Attribute Requirements: "M.E. 10 or higher is suggested, but not
    required" ' || char(8212) || ' recorded as a soft requirement since the book explicitly
    says it isn''t mandatory.
  - Attribute Note: mental attributes (I.Q., M.E., M.A.) are rolled normally;
    physical attributes (P.S., P.P., Spd, etc.) are "bought and acquired" via
    credits spent on bionic upgrades rather than rolled ' || char(8212) || ' see the M.D.C./
    attribute purchase tables below. This doesn''t map cleanly to
    attribute_dice since it''s a build-point/credit system, not a roll.
  - Robot P.S. (Combat Cyborgs): starts at 24, maximum 36, at a cost of 2,000
    credits per point above 24. Robot Strength enables Mega-Damage even with
    an ordinary punch. Non-combat full-conversion ''Borgs and partial ''Borgs
    instead get Bionic/Augmented P.S.
  - P.P. starts at 18, maximum 26, cost 2,000 credits per point above 18.
  - Leg attributes (Speed, P.S., P.P. for legs) also purchasable: Speed
    starts 132 (max 176 for human-type legs, cost 1,500 credits/point above
    132); leg P.S. & P.P. start at 18, max 24, cost 2,000 credits/point
    above 18.
  - Cosmetics (general body): 10 points possible, but most Combat Cyborgs
    avoid spending on this.
  - M.D.C. by Location for a Full Conversion Cyborg (table, not a formula):
    Hands (2) 33 M.D.C. each (max 50); Forearms (2) 33 each (max 50); Upper
    Arms (2) 47 each (max 70); Feet (2) 13 each (max 20); Legs (2) 60 each
    (max 90); Head 60 (max 90); Main Body 180 (max 280). Additional M.D.C.
    purchasable at 2,000 credits per point, up to the listed maximums.
  - Cyborg armor: external M.D.C. armor added on top of the body, available
    as LE-B1 Light Espionage Armor (+135 main body/+15 arm/+25 leg/+12 head,
    20,000 credits), LI-B1 Light Infantry Armor (+150/+20/+35/+15, 28,000
    credits), MI-B2 Medium Infantry Armor (+230/+38/+60/+30, 52,000 credits,
    -15% to Physical skills, bulky), and HI-B3 Heavy Infantry Armor
    (+360/+50/+100/+40, 74,000 credits, only wearable by full conversion
    cyborgs, reduces running/swimming speed by 20%, -25% to noted Physical
    skills, Prowl impossible, -2 to strike/parry/dodge). Espionage/Light
    armor imposes -5% to Physical skills (Acrobatics, Climbing, Gymnastics,
    Pick Pockets, Prowl, Swimming). These are equipment options rather than
    fixed starting gear, so not encoded as equipment_starting.
  - Weapons & Features Possible list (number of implants, not named items):
    Hand: two (three if small features) or a multi-system sensor hand;
    Wrist: one; Knuckles: one each; Fingers: one sensor/camera/etc. per
    digit; Forearm: two or three; Shoulder & Upper Arm: one each (rare,
    considered distracting); Cosmetic Features: 8 (usually none); Head: six
    maximum, four if cybernetic features are large; Eyes: multi-optics or up
    to three enhanced optic features (HUD not standard, not possible in
    Bio-System eyes); Ears: four; Mouth/Jaw: five; Neck/Throat: three;
    Chest: four. Leg: three weapon systems plus one small/medium
    compartment, or 3-6 compartments of varying size/features. These are
    slot/feature counts governing customization, not discrete equipment_starting
    entries, and no specific weapons are assigned by default.
  - Sense of touch is reduced to 35-55% of normal for full conversion combat
    cyborgs. Prowl suffers a -20% penalty (impossible in Heavy armor).
    Skills requiring sensitive/nimble fingers (Art, Forgery, Locksmith,
    Palming, Pick Locks, Play Musical Instrument, similar) suffer -40%.
    These are stated as general penalties to any skills the character might
    take, not applied to a specific listed skill, so they are recorded here
    rather than as per-skill notes.
  - Fear: some people/cultures (anti-technology or barbarian tribes) view
    cyborgs as mechanical demons to be avoided or destroyed ' || char(8212) || ' a
    roleplaying/GM consideration, not a Horror Factor number.
  - Psionics & Magic: full bionic conversion (which Combat Cyborgs undergo)
    destroys all psionic abilities and I.S.P. entirely, so no psionics block
    is included per the omission rule. Cannot operate Techno-Wizardry
    devices or practice magic. The class does get save bonuses vs possession (+5)
    and magic (+3) as noted in bonuses, and is impervious to psionic
    Bio-Manipulation, Telemechanics (all), See Aura, and any attacks/weapons
    that do damage direct to Hit Points (treated as Mega-Damage). However,
    it remains vulnerable to psionic and magic mind attacks, mind control,
    Empathic Transmission, Telepathy (mind reading), Hypnotic Suggestion,
    illusions, and any psionic power or magic spell affecting the mind ' || char(8212) || '
    recorded as prose since it''s a vulnerability, not a bonus.
  - Race Limitation: Humans, D-Bees, and any mortals, plus certain
    sub-demons (Brodkil, Daemonix, Gargoyles). Does not work on supernatural
    beings, demons, creatures of magic, or shape-changing/bio-regenerating
    beings ' || char(8212) || ' their bodies reject cyber-implants and bionics.
  - Alignment: Any.
  - Starting Extras (RUE p.48), the bionic body package, stays prose: MI-B2
    Medium Infantry Cyborg-Armor (230 M.D.C. main body); Mechanical Eyes
    with Polarized Filters, Clock Calendar and two sensory systems of
    choice; two bionic weapons (or tools) for each hand and one for each
    arm; four bionic features and accessories; and a Bionics Upgrade Fund
    of 3D6x1,000+15,000 credits for boosting bionic attributes or buying
    additional features (can be saved for repairs and upgrades).
  - Weapons: one for each W.P. skill with four E-Clips/ammo clips each,
    which is W.P.-dependent and stays prose. Money: 1D4x1,000 in
    credits/cash (starting_money) plus 4D4x100 in saleable Black Market
    items, which stays prose per the coin-only rule.
---

## Lore

A cyborg is the synthesis of man and machine. Creating one always begins with a living person undergoing an "extreme makeover": arms and legs surgically removed, leaving only the trunk and head; internal organs replaced with superior bionic ones; the spine often replaced with a sturdy metal one; the brain removed, skin and all, and placed into a reinforced M.D.C. alloy skull. The artificial head may be built to replicate the subject''s original face, changed and improved, or completely different. Most people (80%) elect to keep some type of human face, because they still think of themselves as human and it helps keep the cyborg connected to his humanity; the rest of the discarded organic body is sold as transplant organs.

Full bionic conversion means the character is over 80% machine, often more than 90% ' || char(8212) || ' only the brain, face, and a few original components (upper torso/chest, tongue, throat, head) remain of the original body. Combat Cyborgs are men and women who have been surgically augmented for the purpose of war ' || char(8212) || ' soldiers, law enforcers, or those who desire to be one ' || char(8212) || ' before submitting to full conversion. "''Borg" is the popular slang term for cyborgs, particularly full conversion cyborgs like the Combat ''Borg.

Does the transformation mean the person becomes a machine? On one hand, yes ' || char(8212) || ' once built into a full cyborg body, the character can never go back to flesh and blood. He is a machine with a human brain. On the other hand, a cyborg would say no: mind, memories and emotions are preserved. Unlike a robot, the cyborg can appreciate colors, be moved by a sunset, laugh at a joke, remember love. "We''re just people inside a tin can. We''re still the same inside." The reasons for undergoing conversion vary: power, respect, justice, vengeance, duty, restlessness, a wish to be different, discomfort in one''s own skin, or simply thinking it''s cool.

The bionic body is a hundred times more durable, faster, stronger and deadlier than its flesh and blood predecessor ' || char(8212) || ' like a caterpillar becoming a butterfly. Physical capabilities for Combat Cyborgs are generally taken to the maximum, and the mechanized warrior is outfitted with heavy Mega-Damage body armor. In North America cyborgs have a human, bipedal shape, though they may sport an extra pair of arms or a modular weapon/tool for a hand; they are usually man-sized, though "man-sized" for a Combat Cyborg often runs 8, 9 or 10 feet (2.4 to 3 m) tall and bristling with weapons and moving parts. The head and face are the only thing recognizable as human, and it''s oddly striking to see a fully human face mounted on a robust mechanized body.

While bionic reconstruction is virtually painless physically, the psychological impact can be devastating ' || char(8212) || ' the person is giving up a portion of his humanity forever, permanently and cosmetically, and the augmented limbs can never be replaced with flesh and blood again, only more bionics. Those undergoing reconstruction go through psychiatric evaluation and consultation to prepare them; 89% adjust well to life as a living machine, but there are unscrupulous tyrants, slavers, and high-tech bandits who force unwilling subjects into "Slave-Borg" conversion, of whom only 32% are content with their transformation and 21% attempt suicide repeatedly (see Rifts Bionic Sourcebook, page 79, for the Slave-Borg O.C.C.).

Simulated touch, difficulty with fine motor skills, and being viewed as a "mechanical demon" by technophobic or anti-technology cultures are part of the price paid for this power.

## GM Notes

This entry combines the O.C.C. stat block on RUE p.48 (skills, equipment, Starting Extras, money) with the general "Making a Combat Cyborg ' || char(8212) || ' Full Bionic Conversion" rules that apply to full-conversion cyborgs broadly, with Combat Cyborg-specific numbers (Robot P.S. maximums, typical height range) called out where the text does so explicitly. GMs building or costing a Combat Cyborg PC should use the M.D.C. by Location table, the attribute purchase costs, and the armor options as the actual character-creation toolkit; the starting package itself is on p.48. Watch for consistency with Rifts Bionics Sourcebook, which is referenced repeatedly for alternate leg configurations (treads, wheels, spider/horse legs), the Slave-Borg O.C.C., and additional implant options.',
       updated_at = datetime('now')
 WHERE class_id = 'combat-cyborg'
   AND instr(markdown, 'saves: { spell_magic: 5, ritual_magic: 5, psionics: 3 }') > 0;

-- Readback: every restored block is present, and the old saves line is gone.
SELECT class_id,
       instr(markdown, 'occ_skills:') > 0            AS has_skills,
       instr(markdown, 'starting_money: "1d4x1000"') > 0 AS has_money,
       instr(markdown, 'equipment_starting:') > 0    AS has_equipment,
       instr(markdown, 'saves: { possession: 5, spell_magic: 3, ritual_magic: 3 }') > 0 AS saves_fixed,
       instr(markdown, 'spell_magic: 5') = 0         AS old_saves_gone,
       instr(markdown, 'p.45-48') > 0                AS pages_widened
  FROM imported_classes
 WHERE class_id = 'combat-cyborg';

-- Records this run. One row per run rather than per file: the statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-combat-cyborg-full-block.sql');
