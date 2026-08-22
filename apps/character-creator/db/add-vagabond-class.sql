-- The Vagabond O.C.C., Rifts Ultimate Edition p.97-97.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-vagabond-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-vagabond-class.sql
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
SELECT 'vagabond', 'Vagabond', 'rifts', '---
id: vagabond
name: Vagabond
system: rifts
source_book: Rifts Ultimate Edition p.97-97
category: occ
bonuses:
  attributes: { MA: "1d4", PS: 1, PE: 2 }
  combat: { perception: 4 }
  saves: { possession: 1, horror_factor: 2 }
  pools: { sdc: "2d6+10" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 88, per_level: 0 }
    - { choose: 2, categories: ["Communications"], note: "Language: Other, two of choice (+15%)." }
    - { name: "Barter", base: 16, per_level: 0 }
    - { name: "Begging", base: 10, per_level: 0 }
    - { name: "Cook", base: 15, per_level: 0 }
    - { choose: 2, categories: ["Domestic"], note: "Domestic: two skills of choice (+15%) on a professional level." }
    - { name: "I.D. Undercover Agent", base: 10, per_level: 0 }
    - { choose: 1, from: ["Automobile", "Motorcycles & Snowmobiles"], note: "Pilot: Automobile (+10%) or Motorcycle (+12%)." }
    - { choose: 1, from: ["General Repair", "Horsemanship: General"], note: "General Repair (+10%) or Horsemanship: General (+5%)." }
    - { name: "Radio: Basic", base: 5, per_level: 0 }
    - { name: "Streetwise", base: 10, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: One of choice." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"] }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if an evil alignment) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - Communications
      - Domestic
      - Electrical
      - Horsemanship
      - Mechanical
      - Medical
      - Physical
      - Pilot
      - Pilot Related
    note: "Communications: Any, except Cryptography, Laser Communication, Optic Systems, and Surveillance. Cowboy: Branding, Breaking Horses, or Herding Cattle only. Domestic: Any (+10%). Electrical: Basic Electronics (+5%) only. Espionage: None. Horsemanship: General only. Mechanical: Basic Mechanics and Automotive only (+5%). Medical: First Aid only (+5%). Military: None. Physical: Any, except Acrobatics, Gymnastics and Wrestling. Pilot: Any (+5%), except Jets, Ships, Power Armor, Robots and Military vehicles. Pilot Related: Any."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - name: "Eyeball a Fella"
    description: "The character knows people so well that he can usually size up a person just by observing him or her for a few minutes. Can discern the following about the person: Educated or not, rich or poor, works hard or works at a desk for a living, from what part of the country the person originates, artist or skilled laborer or management, currently flush with money or operating on a budget, if the person is being honest and genuine or lying or putting on airs, happy or discontented, being genuinely friendly or looking to get something outta the exchange (e.g. looking for information, a good deal, a particular person, food, etc.). Base Skill: 56% +3% per level of experience. Bonuses: Adds a bonus of +10% to the skills Barter, Cardsharp, Gambling, I.D. Undercover Agent, Research (by talking to people), and Seduction."
extraction_notes: |
  - "O.C.C. Bonuses" section lists +1D4 to M.A., +1 to P.S., +2 to P.E., +4 on
    Perception Rolls, +2D6+10 to S.D.C., +1 to save vs possession and psionic
    attacks, and +2 to save vs Horror Factor. The "+1 to save vs psionic attacks"
    portion was not filed under saves.psionics because it is ambiguous whether
    it''s meant as a separate save category from possession; recorded here for
    visibility - consider it +1 to saves.psionics if the app needs a value.
  - Occ_skills list is cut off mid-page at "Pilot Related: Any." in the
    occ_related_skills categories section; the full related skills list beyond
    what''s shown (e.g. Rogue, Science, Technical, W.P., Wilderness categories)
    is not visible on this page and may continue onto a following page not
    provided.
  - "All new [related] skills start at level one proficiency" is noted in the
    book but not a numeric bonus; recorded here as prose.
  - Alignment note: "Any, but 70% seem to be Unprincipled or Anarchist" ' || char(8212) || '
    descriptive, not a hard restriction.
---

## Lore

"Unskilled? Are you kidding? I''m a student of the world. I know a little bit about everything. Well . . . at least the things that interest me most."

Not everybody who gets involved in adventure is a specialist in combat or some other area of training. Some are just ordinary people who get swept up in the flow of events or decide that it is time they make a change in their lives. Others are individuals who possess some natural power (psionics or racial ability), but do not have great training or education other than in the use of their powers. These folks tend to take low-end jobs or drift from place to place, and job to job. Vagabonds are the ultimate Bohemians of this group. They actually like the freedom of not being tied down and drifting along from one adventure to the next. They put their trust in fate and make the best of every situation. Vagabonds are laid-back, easygoing and friendly. They like to travel, like meeting new people, like trying new things (even if it''s balling hay or chopping wood), and like not having to worry about supporting a family or answering to anybody but themselves. For a Vagabond, each new face is a welcomed encounter, each new place an opportunity for adventure, even if it''s on a small, personal scale. "See, I didn''t know that," and "oh, how interesting," are words anyone traveling with a Vagabond is likely to hear over and over again.

Those who choose the life of a Vagabond are usually spirited individuals full of life and curiosity, but rarely very educated in any formal sense, nor literate, and seldom seek higher education. They tend to live by the seat of their pants and rely on their wits, luck, and the kindness of strangers. Many nomads, wilderness folk, peasants, farmers, Major psychics and mutants are Vagabonds.

## GM Notes

Attribute Requirements: None. Racial Requirements: None. Alignment: Any, but the entry notes a tendency toward Unprincipled or Anarchist alignments ' || char(8212) || ' a useful hook for roleplaying rather than a hard restriction. The class is a strong fit for characters built around psionics or racial/natural abilities layered on top of a "jack of all trades" skill base, since the O.C.C. skill list intentionally covers a broad, low-intensity spread rather than a narrow specialty.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'vagabond');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'vagabond';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-vagabond-class.sql');
