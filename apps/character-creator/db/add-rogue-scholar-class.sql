-- The Rogue Scholar O.C.C., Rifts Ultimate Edition p.93-94.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-rogue-scholar-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-rogue-scholar-class.sql
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
SELECT 'rogue-scholar', 'Rogue Scholar', 'rifts', '---
id: rogue-scholar
name: Rogue Scholar
system: rifts
source_book: Rifts Ultimate Edition p.93-94
category: occ
attribute_requirements:
  IQ: 10
  MA: 10
bonuses:
  attributes: { IQ: 1, MA: 2 }
  combat: { perception: 5 }
  pools: { sdc: "2d6" }
skills:
  occ_skills:
    - { name: "Literacy: Native Language", base: 50, per_level: 0 }
    - { choose: 3, categories: ["Communications"], bonus: 30, note: "Literacy: Other, three of choice (+30%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, categories: ["Communications"], bonus: 25, note: "Language: Other, two of choice (+25%)." }
    - { name: "Appraise Goods", base: 20, per_level: 0, note: "+20%" }
    - { name: "Mathematics: Basic", base: 25, per_level: 0, note: "+25%" }
    - { name: "Computer Operation", base: 20, per_level: 0, note: "+20%" }
    - { name: "Computer Programming", base: 15, per_level: 0, note: "+15%" }
    - { name: "Creative Writing", base: 15, per_level: 0, note: "+15%" }
    - { name: "Find Contraband", base: 15, per_level: 0, note: "+15%; also +20% specifically related to books, art, film and pre-Rifts artifacts (see Special O.C.C. Abilities)." }
    - { name: "History: Pre-Rifts", base: 22, per_level: 0, note: "+22%" }
    - { name: "History: Post-Apocalypse", base: 20, per_level: 0, note: "+20%" }
    - { name: "Public Speaking", base: 20, per_level: 0, note: "+20%" }
    - { name: "Research", base: 30, per_level: 0, note: "+30%" }
    - { choose: 1, from: ["Automobile", "Pilot: Hover Vehicle"], bonus: 10, note: "+10%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: one of choice." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"] }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Counts as one O.C.C. Related Skill selection; Expert counts as two, Martial Arts counts as four." }
    - { name: "Recognize Authenticity", base: 58, per_level: 3, note: "Exclusive skill. Tells if an item is a true pre-Rifts artifact, facsimile, new or used, defective, forgery, professionally restored, low or high quality, and a fair price." }
    - { name: "Professional Restoration", base: 58, per_level: 3, note: "Exclusive skill. Patches, repairs and touches up books, binding, paper products and works of art (excluding 3D items) to improve appearance and value by 8% per level, provided the skill roll succeeds. A failed roll means no improvement, wait a week and retry; a second failure means it is beyond repair. Bonuses to Related Skills: +10% to Art, Calligraphy, Forgery, and Photography." }
  occ_related_skills:
    count: 11
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - { name: "Horsemanship: General", only: ["Horsemanship: General"] }
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
    note: "At least four selections must be from Technical. Communications (+10%). Domestic (+10%). Electrical: Basic Electronics and Computer Repair only (+5%). Espionage: Forgery and Intelligence only. Horsemanship: General only. Mechanical: Basic Mechanics and Automotive Mechanics only (+5%). Medical: First Aid only (+10%). Physical: Any, except Acrobatics, Gymnastics, Kick Boxing and Wrestling. Pilot: Any (+5%), excluding military, power armor and ''bots. Pilot Related: Any (+10%). Rogue: Any (+10% to Computer Hacking only). Science: Any (+10%). Technical: Any (+15%). Cowboy: None."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 0
special_abilities:
  - name: "Storyteller & Teacher"
    description: "Rogue Scholars are natural born storytellers and educators with a flair for making dry subjects like history, science and math sound exciting and fun. A passion that enables them to teach others over a period of time (equal to a Secondary Skill after 1D6+8 weeks of lessons; at least 12 hours a week devoted to the teaching and another 10 hours of study by the student)."
  - name: "Find Books and Historical Artifacts"
    description: "+20% to Find Contraband related to books, art, film and pre-Rifts artifacts in general. Gets these items at a discount - 40% off list price as a professional courtesy from most other Rogue Scholars and Scientists and others who value knowledge and history. A 50% discount from the Black Market if he trades at least 24 hours of his time to work for them doing bookkeeping, translating text/books, transcribing passages, authenticating inventory acquired from adventurers and other sources, teaching, and other work applicable to the brainy character. Every 24 hours he puts in, he can get up to 30,000 credits worth of books, supplies (paper, notebook, writing or drawing implements, computer, recorder, camera, etc.) or relics and artifacts from the past for half (that''s 15,000 credits, his cost)."
  - name: "Recognize Authenticity"
    description: "An exclusive skill that enables the Rogue Scholar to tell if an item is a true pre-Rifts artifact, an original edition, a recent facsimile copy (which may be just as good from an information point of view), new or used, defective or incomplete or censored, a forgery, professionally restored, low or high quality, and a fair price. Base Skill: 58% +3% per level of experience."
  - name: "Professional Restoration"
    description: "An exclusive skill that enables the Rogue Scholar to patch, repair and touch up books, binding, all paper products, and works of art (excluding 3D items), to improve their appearance and quality and value by 8% per level of experience, provided he makes his skill roll. A failed skill roll means no improvement, wait a week and try again. A second failure means it is beyond his ability to restore. Base Skill: 58% +3% per level of experience. Bonuses to Related Skills: +10% to Art, Calligraphy, Forgery, and Photography."
restrictions:
  - "Considered a traitor to humanity and an enemy of the Coalition States; rogues are captured and interrogated, may be imprisoned for 1D6x10 years, or executed as terrorists if notorious or defiant."
  - "At least 40% of Rogue Scholars are D-Bees."
extraction_notes: |
  - Skill bases shown already include the printed O.C.C. bonus percentages
    added to an assumed catalog base, per operator hints; the (+N%) notation
    from the book is preserved in each skill''s `note` for traceability.
  - "Hand to Hand combat can be selected as an O.C.C. Related skill" (Basic
    counts as one selection, Expert as two, Martial Arts as four) is recorded
    as a skill entry with an explanatory note rather than forced into
    occ_related_skills'' categories, since it is a special substitution rule
    rather than a plain category.
  - The Black Market discount and 30,000-credit trade mechanic under "Find
    Books and Historical Artifacts" is a conditional/roleplay-driven economic
    benefit, not a flat numeric bonus, so it stays as prose only.
  - No starting_money, equipment_starting, or cybernetics listed on these two
    pages for the Rogue Scholar specifically (that block belongs to the
    preceding Operator O.C.C. entry on the same page and was not carried
    over).
  - Related O.C.C.s and standard equipment sections visible on page 93 belong
    to the Operator O.C.C., not the Rogue Scholar, and were excluded.
---

## Lore

"I will not be silenced. I will not submit. I will find the truth and shout it to the world."

The Rogue Scholar may not be quite what you expect. Like the Body Fixer and Rogue Scientist, he or she is frequently a rugged, physically fit explorer and keeper of knowledge. He too is an enemy of the Coalition States and a "traitor to humanity," but is ranked at the top of the list. Also known as truth seekers, Rogue Scholars dig through facts and information to find and reveal the truth on all subject matters. This makes them outspoken opponents of the Coalition States ("rebels" according to the CS). Far worse, and making them far more dangerous than other men of science, Rogue Scholars teach the illiterate masses and D-Bees the truths they know as well as mathematics, reading and writing. Rogue Scholars love ideas and try to instill in everyone they encounter such virtues as keeping an open mind, being curious, asking questions, freedom of speech and expression, tolerance to new ideas and cultures, and seeking wisdom and truth. These things make the Scholar the most dangerous of the Rogues.

Science is confusing and intimidating to most people, medicine and cybernetics a rare talent and beyond the average person''s grasp, but the Rogue Scholar is just an ordinary person armed with words and ideas anyone can understand. They connect with people on a visceral level and are identified as one of their own. To give their words even greater impact and validity, Rogue Scholars frequently possess forbidden artifacts from the past. Terrible objects such as books, photographs, artwork, recordings, film, and other things that reflect the ideology and goals from the vaunted "Golden Age of Man." And Erin Tarn stands as the figurehead of all that is good about this profession and their quest for truth (making her CS Public Enemy Number One).

Simply instilling uneducated people with curiosity and teaching them how to read for themselves undermines the Coalition''s carefully executed plan to keep its citizens and backwoods people illiterate, uneducated, and complacent. A curious mind will always ask questions and ultimately challenge the authority before it when those questions are not satisfactorily answered. Something the powers-that-be dislike.

Though they would never admit it, the Coalition leaders respect the scholars and scientists who dare to pursue and teach knowledge and truth, knowing full well that it may cost them their lives. The Coalition also recognizes that these men and women may have uncovered knowledge that could be vital to the CS. Remember, while the Coalition States promotes ignorance among its citizens, its political network, military elite, and own scientists are extremely well educated. As a rule, rogues are captured and interrogated. A cooperative individual who comes to sincerely realize that he was "misguided" and his actions potentially detrimental to (the Coalition''s) human civilization may be released or asked to join the CS as one of their operatives (though probably never a full citizen). Those too independent to accept such an offer or too stubborn to share anything with the CS will be imprisoned for 1D6x10 years. The most notorious and defiant rogues will have their knowledge painfully extracted during a period of imprisonment that could be a matter of weeks or years, before being executed as terrorists.

Rogue Scholars tend to be charismatic, socially adept, clever, resourceful, and given to thinking before they act. This can make for the beginnings of a good strategist, tactician, and diplomat as well as motivational speaker and teacher. Notorious collectors, Rogue Scholars adore books, artwork, film, television, and mementos from the past. Consequently, they often accumulate large collections of new, reprinted and pre-Rifts books, video discs, art, statues, nicknacks, and artifacts from bottle caps and silverware to pop culture and technology. True pre-Rifts artifacts may be worth hundreds to thousands of credits on the Black Market, and a death sentence if apprehended by Coalition forces. The problem is that the scholar can seldom bear to sell the precious items and his hideout will be filled with them. Ah, the price of knowledge and art.

## GM Notes

Rogue Scholars work well as the party''s face and lorekeeper ' || char(8212) || ' their bonuses to Find Contraband, Recognize Authenticity and Professional Restoration make them natural hooks for adventures built around recovering, authenticating, or trading in pre-Rifts artifacts. Their notoriety with the Coalition States (capture, imprisonment for 1D6x10 years, or execution as terrorists) makes them useful sources of CS-focused plot tension. Consider letting a Scholar''s teaching ability (1D6+8 weeks per Secondary-Skill-equivalent taught) drive downtime subplots, spreading literacy and pre-Rifts knowledge among NPC populations, with the attendant CS scrutiny that follows.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'rogue-scholar');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'rogue-scholar';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-rogue-scholar-class.sql');
