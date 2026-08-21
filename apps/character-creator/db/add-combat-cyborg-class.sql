-- The Combat Cyborg O.C.C., Rifts Ultimate Edition p.45-47.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-combat-cyborg-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-combat-cyborg-class.sql
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
SELECT 'combat-cyborg', 'Combat Cyborg', 'rifts', '---
id: combat-cyborg
name: Combat Cyborg
system: rifts
source_book: Rifts Ultimate Edition p.45-47
category: occ
mdc_base: "See M.D.C. by Location table (Main Body 180, max. 280 M.D.C.)"
attribute_requirements:
  ME: 10
bonuses:
  saves: { spell_magic: 5, ritual_magic: 5, psionics: 3 }
extraction_notes: |
  - This page set describes the Combat Cyborg O.C.C. primarily through the
    general "Full Bionic Conversion" rules shared by all full-conversion
    cyborgs, rather than a traditional self-contained O.C.C. write-up with
    skill lists, starting equipment, and level progression. No occ_skills,
    occ_related_skills, secondary_skills, starting_money, or
    equipment_starting list is given anywhere in the excerpt.
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
    devices or practice magic. The class does get save bonuses vs magic and
    psionic possession as noted in bonuses, and is impervious to psionic
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
  - No level_progression table, starting money, or discrete equipment list
    was present in the provided pages; these appear to be covered elsewhere
    in the sourcebook (e.g., a separate stats/equipment section not included
    in this excerpt).
---

## Lore

A cyborg is the synthesis of man and machine. Creating one always begins with a living person undergoing an "extreme makeover": arms and legs surgically removed, leaving only the trunk and head; internal organs replaced with superior bionic ones; the spine often replaced with a sturdy metal one; the brain removed, skin and all, and placed into a reinforced M.D.C. alloy skull. The artificial head may be built to replicate the subject''s original face, changed and improved, or completely different. Most people (80%) elect to keep some type of human face, because they still think of themselves as human and it helps keep the cyborg connected to his humanity; the rest of the discarded organic body is sold as transplant organs.

Full bionic conversion means the character is over 80% machine, often more than 90% ' || char(8212) || ' only the brain, face, and a few original components (upper torso/chest, tongue, throat, head) remain of the original body. Combat Cyborgs are men and women who have been surgically augmented for the purpose of war ' || char(8212) || ' soldiers, law enforcers, or those who desire to be one ' || char(8212) || ' before submitting to full conversion. "''Borg" is the popular slang term for cyborgs, particularly full conversion cyborgs like the Combat ''Borg.

Does the transformation mean the person becomes a machine? On one hand, yes ' || char(8212) || ' once built into a full cyborg body, the character can never go back to flesh and blood. He is a machine with a human brain. On the other hand, a cyborg would say no: mind, memories and emotions are preserved. Unlike a robot, the cyborg can appreciate colors, be moved by a sunset, laugh at a joke, remember love. "We''re just people inside a tin can. We''re still the same inside." The reasons for undergoing conversion vary: power, respect, justice, vengeance, duty, restlessness, a wish to be different, discomfort in one''s own skin, or simply thinking it''s cool.

The bionic body is a hundred times more durable, faster, stronger and deadlier than its flesh and blood predecessor ' || char(8212) || ' like a caterpillar becoming a butterfly. Physical capabilities for Combat Cyborgs are generally taken to the maximum, and the mechanized warrior is outfitted with heavy Mega-Damage body armor. In North America cyborgs have a human, bipedal shape, though they may sport an extra pair of arms or a modular weapon/tool for a hand; they are usually man-sized, though "man-sized" for a Combat Cyborg often runs 8, 9 or 10 feet (2.4 to 3 m) tall and bristling with weapons and moving parts. The head and face are the only thing recognizable as human, and it''s oddly striking to see a fully human face mounted on a robust mechanized body.

While bionic reconstruction is virtually painless physically, the psychological impact can be devastating ' || char(8212) || ' the person is giving up a portion of his humanity forever, permanently and cosmetically, and the augmented limbs can never be replaced with flesh and blood again, only more bionics. Those undergoing reconstruction go through psychiatric evaluation and consultation to prepare them; 89% adjust well to life as a living machine, but there are unscrupulous tyrants, slavers, and high-tech bandits who force unwilling subjects into "Slave-Borg" conversion, of whom only 32% are content with their transformation and 21% attempt suicide repeatedly (see Rifts Bionic Sourcebook, page 79, for the Slave-Borg O.C.C.).

Simulated touch, difficulty with fine motor skills, and being viewed as a "mechanical demon" by technophobic or anti-technology cultures are part of the price paid for this power.

## GM Notes

This entry is built almost entirely from the general "Making a Combat Cyborg ' || char(8212) || ' Full Bionic Conversion" rules that apply to full-conversion cyborgs broadly, with Combat Cyborg-specific numbers (Robot P.S. maximums, typical height range) called out where the text does so explicitly. GMs building or costing a Combat Cyborg PC should use the M.D.C. by Location table, the attribute purchase costs, and the armor options as the actual character-creation toolkit; there is no discrete "starting package" printed on these pages. Watch for consistency with Rifts Bionics Sourcebook, which is referenced repeatedly for alternate leg configurations (treads, wheels, spider/horse legs), the Slave-Borg O.C.C., and additional implant options.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'combat-cyborg');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'combat-cyborg';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-combat-cyborg-class.sql');
