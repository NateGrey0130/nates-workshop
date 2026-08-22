-- The Body Fixer O.C.C., Rifts Ultimate Edition p.86-87.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-body-fixer-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-body-fixer-class.sql
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
SELECT 'body-fixer', 'Body Fixer', 'rifts', '---
id: body-fixer
name: Body Fixer
system: rifts
source_book: Rifts Ultimate Edition p.86-87
category: occ
attribute_requirements:
  IQ: 10
bonuses:
  attributes: { MA: 1, PS: 1, PP: 1, PE: 1 }
  saves: { toxins_poisons: 3, harmful_drugs: 3, insanity: 3, horror_factor: 2 }
  combat: { dodge: 1, disarm: 1 }
  pools: { sdc: "1d6+4" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 96, per_level: 0 }
    - { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }
    - { name: "Literacy: Native Language", base: 70, per_level: 5, note: "+30%, typically American." }
    - { choose: 1, from: ["Athletics (General)", "Body Building"], base: 0, per_level: 0 }
    - { name: "Mathematics: Basic", base: 60, per_level: 5 }
    - { name: "Biology", base: 60, per_level: 5 }
    - { name: "Brewing: Medicinal", base: 45, per_level: 5 }
    - { name: "Chemistry", base: 50, per_level: 5 }
    - { name: "Lore: D-Bee", base: 50, per_level: 5 }
    - { name: "Medical Doctor", base: 80, per_level: 5 }
    - { name: "Outdoorsmanship", base: 0, per_level: 0 }
    - { name: "Pathology", base: 70, per_level: 5 }
    - { choose: 1, categories: ["Pilot"], bonus: 10 }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20% on medical, only +5% on all others." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Special bonus of +1 to strike." }
    - { name: "Outdoorsmanship", base: 0, per_level: 0, note: "duplicate listing in source" }
    - { name: "Xenology", base: 50, per_level: 5 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "None to start, but can be selected as an O.C.C. Related Skill: Hand to Hand: Basic counts as one skill selection, or Expert as two." }
  occ_related_skills:
    count: 8
    categories:
      - Communications
      - Domestic
      - Electrical
      - Espionage
      - Horsemanship
      - Mechanical
      - Medical
      - Physical
      - Pilot
      - "Pilot Related"
      - Rogue
      - Science
      - Technical
      - "Weapon Proficiencies"
      - Wilderness
    note: "Select three additional skills from the Medical category, and select 8 other skills (may include more from the Medical category) at level one, plus two additional skills at levels 3, 6, 9, and 12. All new skills start at level one proficiency. Communications: Barter, Creative Writing, Language, Literacy, Public Speaking, and Radio: Basic only (+5%). Domestic: Any (+10%). Electrical: Basic only (+5%). Espionage: Wilderness Survival only (+10%). Horsemanship: General only. Mechanical: Basic Mechanics and Automotive only. Medical: Any (+15%). Physical: Any, excluding Acrobatics, Boxing and Wrestling. Pilot: Any (+5%). Rogue: Streetwise only (+4%). Science: Any (+10%). Technical: Any (+10%). W.P.: Any, except Heavy Military Weapons and Heavy Energy Weapons. Wilderness: +5% but the bonus counts only for country/adventuring Body Fixers, not city-docs."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "surgical-gown", qty: 2 }
  - { item_id: "disposable-surgical-gloves", qty: 12 }
  - { item_id: "reusable-surgical-gloves", qty: 1 }
  - { item_id: "surgical-kit", qty: 1 }
  - { item_id: "medical-kit", qty: 1 }
special_abilities:
  - name: "Familiarity with D-Bees"
    description: "No skill penalty when working on common/known D-Bees; only a -20% penalty when dealing with extremely alien physiology, rare or previously unknown D-Bees. The Body Fixer is -20% whenever working on bionic modifications, and -30% when working on alien cybernetics, -50% on alien bionics."
  - name: "Disease Diagnostic Specialist"
    description: "Diagnose disease with extreme clarity and accuracy. Skill Bonuses: +20% to that percentile number of the Medical Doctor skill, and +10% to Brewing and Holistic Medicine skills to whip up a cure. He is so good that he can reduce the symptoms (i.e., the penalties and duration) by half. Can also recognize possession and magical illnesses and curses."
  - name: "O.C.C. Bonuses"
    description: "+1D6+4 to S.D.C., +1 to M.A., P.S., P.P., and P.E. attributes, +1 to dodge and disarm, +2 to save vs poison and drugs, +3 to save vs disease and insanity, +2 to save vs Horror Factor, +2 on most Perception Rolls, but +4 when the Perception Roll involves making an observation about a medical condition, diagnosis/health or medical procedure, as well as when dealing with drugs/chemicals, and poison."
restrictions:
  - "No Racial Requirement; half of all Body Fixers are D-Bees themselves."
extraction_notes: |
  - Alignment is recorded as prose rather than as a key. The book says
    "Any, but tends to be Principled, Scrupulous, Unprincipled or Aberrant." - a tendency, not a
    restriction, and the app has no alignment-restriction mechanic to
    enforce one against.
  - The "O.C.C. Bonuses" perception bonus (+2 most Perception Rolls, +4 for
    medical/drug/poison-related Perception Rolls) is conditional and recorded
    only in prose per the schema''s rule against unconditional Perception bonuses
    (no Perception key exists in the bonuses schema in any case).
  - Standard Equipment list is cut off at the bottom of page 87 ("...surgical
    kit (includes scalpels, clamps, sutures, needles, etc.), medical kit
    (first-aid kit, bandages, antiseptics,") ' || char(8212) || ' the remainder of the equipment
    list and Money/Cybernetics sections are not present on the supplied pages
    and could not be extracted.
  - Outdoorsmanship appears twice in the printed O.C.C. Skills list; both
    instances preserved as this may reflect an actual duplication in the
    source rather than a misread.
  - Hand to Hand Combat note: starts with none, but may be taken as an O.C.C.
    Related Skill (Basic = 1 selection, Expert = 2 selections) ' || char(8212) || ' recorded as
    an occ_skills entry with note since it doesn''t cleanly fit the related-skill
    schema shape.
---

## Lore

Alignment: Any, but tends to be Principled, Scrupulous, Unprincipled or Aberrant.

"I''m a healer. I fix people. I don''t judge them or decide who should live and die based on their genetic makeup. That''s for God... or maybe Emperor Prosek and his goon squads. If that makes me a criminal, so be it."

Saying that a Body Fixer is just a doctor does a disservice to these brave men and women of this noble profession, and only tells part of their story. "Body Fixer" is the slang term for a medical doctor (M.D.) in North America who performs medicine on anybody ' || char(8212) || ' human and nonhuman. That distinction makes the Body Fixers criminals, rogues and dissidents in the eyes of the Coalition States. Anybody caught "harboring, aiding and abetting a criminal of the State" ' || char(8212) || ' a distinction given to all D-Bees for not having been born human ' || char(8212) || ' is punishable by death! And that includes providing them with medical aid. Better to let a D-Bee die in the gutter than give "it" comfort or aid.

Body Fixers are doctors who cannot turn their backs on the sick and injured based on their race. A choice that has branded them as "traitors to humanity" by the CS.

Conservative estimates suggest the D-Bee population among sentient (intelligent) life forms in North America is 34%. Less conservative numbers place the number at closer to 42%. Most Rogue Scholars and Scientists believe a more accurate number is probably 50-55%. Perhaps all the more reason for human supremacists like the leaders of the Coalition States to want D-Bees dead. Even in the Chi-Town ''Burbs, being caught by CS Police, soldiers and undercover agents is death for D-Bees, they make up an estimated 16% to 22% of the population! In the New West, D-Bees make up at least 60% to 80% of the population, and in the east and north into Canada that number is probably 40%-50%, possibly higher, and that does not include Psi-Stalkers, whom the CS considers to be mutant humans.

It is difficult to determine exact numbers because most D-Bees live in poverty or low-tech communities in thousands of tiny villages, towns and tribes. Gathering in a large community, especially within view of the CS, is to invite a Coalition extermination squad to come knocking. Likewise, because humans are the dominant power in North America and D-Bees second class citizens at most places that accept them, predominantly D-Bee communities are raided and attacked with impunity by other D-Bees and human mercs, raiders, bandits and adventurers. D-Bees only have rights if they have the firepower to fight back, which many do not. And because the Coalition States have been so tenacious at breaking down and wiping out large gatherings of D-Bees before they can turn into full-fledged cities or kingdoms, most D-Bees have adopted the practice of trying to integrate (and lose) themselves into an established, predominantly human community where the CS is much less likely to attack.

However one cuts the numbers, they are far too many people for a dedicated healer to ignore. Furthermore, because D-Bees are, generally, forced to live in substandard conditions, abused, and refused conventional medical treatment, they need someone like the Body Fixer more than anyone.

As a result, Body Fixers are tough adventurers who often make house calls up to 300 miles (480 km) away from their base of operation. Around half are traveling doctors who follow a regular circuit of towns, farms, homesteads and stops, or hook up with a group of adventurers, helping them and those in need encountered along the way. Consequently, most Body Fixers are rather like super-country doctors and are no strangers to traveling the wilderness. Although Body Fixers are idealistic healers, they aren''t fools. They understand better than most people the dangers of Rifts Earth, and know sometimes one must kill or be killed. Less than 12% are dedicated pacifists who refuse to use a gun or fight back to protect themselves. On the contrary, many Body Fixers will not hesitate to use a weapon and threats to protect themselves and/or their patients. Considering the prejudice leveled at their nonhuman clients, Body Fixers are by nature rather stubborn, tenacious and militant, risking their lives every day for what they believe in.

Why do it? Why especially risk the retribution of the Coalition? Because Body Fixers are compassionate people who don''t see much of a choice. Walk away and let someone they can save die, or do what they believe is right and save that life. Besides, half of all Body Fixers are D-Bees themselves devoted to helping all people. Personal profit and power mean nothing to a dedicated Body Fixer. Most of them will offer their expert services to anybody who needs them for a hot meal, a dry place to sleep, and whatever seems like a fair and reasonable trade, all things considered. This has earned them the reputation for being kind and compassionate humanitarians and champions of the downtrodden. Some are practically living folk heroes.

Of course, not all Body Fixers are the soul of compassion. Some are quacks and brigands who charge an arm and a leg (sometimes, quite literally) for their services, and gouge those in need, especially D-Bees and fugitives wanted by the authorities. Burn outs, hacks and greedy, cold-hearted Fixers seem to be the embodiment of those employed at most Black Market Body-Chop-Shops. Some are downright evil. These callous and insensitive doctors are in it for the money. Only 1 in 10 Fixers at a Chop-Shop seem to genuinely care about their patients. If the money''s right, they''ll work on anybody. No questions asked.

Perhaps because they know and cherish the pure physical body so much, many Body Fixers refuse to use cybernetics on themselves, unless it is a lifesaving organ or prosthetic. They may also try to dissuade their patients from getting augmentation of any kind. On the other hand, about a third will get a handful of cybernetic enhancements, mainly optics and sensors. However, a solid 10% will get plenty of them, although again, limited mainly to optics, sensors and things that help them to be better doctors.

## GM Notes

Body Fixers make excellent additions to adventuring parties needing dedicated medical support, but their compassion and stubbornness about treating D-Bees can drag the whole group into direct conflict with the Coalition States ' || char(8212) || ' harboring or aiding a D-Bee is a capital offense in CS territory. GMs should use this tension as a strong roleplaying hook: will the party protect their medic''s principles, or pressure them to look the other way? The wide gulf in quality between idealistic field doctors and mercenary Black Market Chop-Shop hacks (only 1 in 10 of whom truly care about patients) offers a useful spectrum of NPC Body Fixers, from folk-hero healers to morally bankrupt profiteers.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'body-fixer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'body-fixer';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-body-fixer-class.sql');
