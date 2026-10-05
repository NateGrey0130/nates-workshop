-- Language: Inuit as a row, the Pneuma-Biform dolphin's and killer whale's
-- psionics roll as a pick-one group, and two false sentences on the Koral
-- Shaper.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~114-inuit-language-and-two-psionics-groups.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~114-inuit-language-and-two-psionics-groups.sql
--
-- Close-out package A8 (Nate's ruling 7 of 2026-10-04: class extras).
--
-- LANGUAGE: INUIT. Rifts World Book 20: Canada has the Tundra Ranger Scout
-- (printed 85) and the Trapper-Woodsman (printed 89) speak Inuit at +15%.
-- Both classes stored it as a Language: Other pick the player had to name.
-- It is now a row, at the 50% +5% every spoken language row carries, and
-- both classes grant it at 65%. The Scout's "one additional Native American
-- tongue" stays a Language: Other pick: the book names no tribe, and the
-- catalog holds no row per tribal language (Spirit West's classes store a
-- tribal language the same way). systems is ["rifts"], as Language: Techno-Can
-- from the same book is: regression counts the untagged language family.
--
-- THE TWO PNEUMA-BIFORMS (Underseas printed 51-55) say their psionics
-- are the normal dolphin's and the normal killer whale's, which printed 80
-- and 88 give as a percentile roll. ~090 turned that roll into a pick-one
-- group of banded options on the dolphin and killer-whale classes; these two
-- classes still said no block was stored. Each now carries the same group,
-- copied from its animal, under a new special_abilities block.
--
-- THE KORAL SHAPER carried a restriction and a note saying no psionics block
-- is stored, copied from the Naut'Yll Soldier and Devastator. It has one: it
-- is a major psionic with six powers and one per level. Both sentences are
-- rewritten; nothing mechanical changes on that class.
--
-- NOT HERE: the Noli Cowboy and Noli Scout packages. ~097 already made them
-- enforceable when it moved noli-bushman to the D-Bees printing: a pick-one
-- psionics group keyed to the occupation taken.
--
-- Every replace() is guarded on the text it replaces and on the new text
-- being absent, so a second run is a no-op. MUST SORT AFTER ~090 and ~097.
-- THIS SCRIPT CHANGES PRODUCTION: one new skill row and five class rows.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Language: Inuit', 'Technical', 50, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.89',
        'The language of the Inuit of the Tundra and the Arctic. Canada prints no percentage for it; it takes the 50% +5% per level every spoken language carries.');

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    - { choose: 3, from: ["Language: Other"], bonus: 15, note: "Speaks Inuit, plus one additional Native American tongue and one of choice (typically Euro or Old Canadian French); all are +15%. One of the three picks is Inuit and one is a Native American language; the picker asks which." }
',
         '    - { name: "Language: Inuit", base: 65, per_level: 5, note: "Speaks Inuit (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One additional Native American tongue (+15%). The catalog holds no row per tribal language; the picker asks which." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One language of choice, typically Euro or Old Canadian French (+15%)." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'tundra-ranger-scout'
   AND instr(markdown, '    - { choose: 3, from: ["Language: Other"], bonus: 15, note: "Speaks Inuit, plus one additional Native American tongue') > 0
   AND instr(markdown, ', from: ["Language: Other"], bonus: 15, note: "One language of choice, typically Euro or Old Canadian French (+15%)." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The catalog has no Language: Inuit row and no Native American language row, so the line is stored as three Language: Other picks at +15%.',
         'Inuit is the Language: Inuit row (added by ~114) at the catalog 50% plus 15. The Native American tongue and the language of choice are one Language: Other pick each at +15%: the book names no tribe, and the catalog holds no row per tribal language.'),
       updated_at = datetime('now')
 WHERE class_id = 'tundra-ranger-scout'
   AND instr(markdown, 'The catalog has no Language: Inuit row and no Native American language row, so the line is stored as three Language: Oth') > 0
   AND instr(markdown, 'ce are one Language: Other pick each at +15%: the book names no tribe, and the catalog holds no row per tribal language.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'language of choice, each at +15%. The sheet stores these as three free
language picks.
',
         'language of choice, each at +15%. Inuit is granted; the other two are free
language picks.
'),
       updated_at = datetime('now')
 WHERE class_id = 'tundra-ranger-scout'
   AND instr(markdown, 'language of choice, each at +15%. The sheet stores these as three free
language picks.
') > 0
   AND instr(markdown, 'language of choice, each at +15%. Inuit is granted; the other two are free
language picks.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Speaks Inuit and one other language of choice (+15%). One of the two picks is Inuit; the picker asks which." }
',
         '    - { name: "Language: Inuit", base: 65, per_level: 5, note: "Speaks Inuit (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language of choice (+15%)." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'trapper-woodsman'
   AND instr(markdown, '    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Speaks Inuit and one other language of choice (+15%). On') > 0
   AND instr(markdown, 'nuit (+15%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language of choice (+15%)." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Speaks Inuit and one other language of choice (+15%): the catalog has no Language: Inuit row, so the line is stored as two Language: Other picks at +15%.',
         'Speaks Inuit and one other language of choice (+15%): Inuit is the Language: Inuit row (added by ~114) at the catalog 50% plus 15, and the other is one Language: Other pick at +15%.'),
       updated_at = datetime('now')
 WHERE class_id = 'trapper-woodsman'
   AND instr(markdown, 'Speaks Inuit and one other language of choice (+15%): the catalog has no Language: Inuit row, so the line is stored as t') > 0
   AND instr(markdown, 's the Language: Inuit row (added by ~114) at the catalog 50% plus 15, and the other is one Language: Other pick at +15%.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Languages: Inuit and one language of choice, each at +15%, stored as two
free language picks.
',
         'Languages: Inuit and one language of choice, each at +15%. Inuit is
granted; the other is a free language pick.
'),
       updated_at = datetime('now')
 WHERE class_id = 'trapper-woodsman'
   AND instr(markdown, 'Languages: Inuit and one language of choice, each at +15%, stored as two
free language picks.
') > 0
   AND instr(markdown, 'Languages: Inuit and one language of choice, each at +15%. Inuit is
granted; the other is a free language pick.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
natural_abilities:
  - name: "Metamorphosis: Human"',
         '
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Dolphin Psionics (printed 80): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Healing or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Healing", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, '
natural_abilities:
  - name: "Metamorphosis: Human"') > 0
   AND instr(markdown, 'es: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No psionics block is stored, because most PB-dolphins have none."',
         'The roll is the pick-one Psionics group under special abilities, the normal dolphin''s own."'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, 'No psionics block is stored, because most PB-dolphins have none."') > 0
   AND instr(markdown, 'The roll is the pick-one Psionics group under special abilities, the normal dolphin''s own."') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - NO PSIONICS BLOCK. The entry says psionic powers are the normal
    dolphin''s, and printed 80 makes those a percentile roll where 77% have
    none. Granting a block would give every PB-dolphin powers most lack.
',
         '  - NO CLASS-LEVEL PSIONICS BLOCK. The entry says psionic powers are the
    normal dolphin''s, and printed 80 makes those a percentile roll where 77%
    have none. Since ~114 the roll is a pick-one group of four banded
    options, copied from the dolphin class as ~090 gave it; each psychic
    option carries its own block, and the None option carries nothing.
    psionics_allowed is not set, as it is not on the dolphin class: whether
    the table replaces the standard roll is a page read left to close-out
    package C5, which takes both classes together.
'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, '  - NO PSIONICS BLOCK. The entry says psionic powers are the normal
    dolphin''s, and printed 80 makes those a percenti') > 0
   AND instr(markdown, 'he table replaces the standard roll is a page read left to close-out
    package C5, which takes both classes together.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
natural_abilities:
  - name: "Metamorphosis: Human"',
         '
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Killer Whale Psionics (printed 88): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale'
   AND instr(markdown, '
natural_abilities:
  - name: "Metamorphosis: Human"') > 0
   AND instr(markdown, 'es: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'which printed 88 gives as a percentile roll rather than a grant. No psionics block is stored."',
         'which printed 88 gives as a percentile roll rather than a grant. The roll is the pick-one Psionics group under special abilities, the normal killer whale''s own."'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale'
   AND instr(markdown, 'which printed 88 gives as a percentile roll rather than a grant. No psionics block is stored."') > 0
   AND instr(markdown, 'll rather than a grant. The roll is the pick-one Psionics group under special abilities, the normal killer whale''s own."') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - NO PSIONICS BLOCK, for the same reason as the PB-dolphin: the entry
    defers to the normal killer whale, whose powers are a percentile roll.
',
         '  - NO CLASS-LEVEL PSIONICS BLOCK, for the same reason as the PB-dolphin:
    the entry defers to the normal killer whale, whose powers are a
    percentile roll. Since ~114 the roll is a pick-one group of four banded
    options, copied from the killer-whale class as ~090 gave it.
    psionics_allowed is not set, as it is not on the killer-whale class;
    close-out package C5 reads the page for both.
'),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale'
   AND instr(markdown, '  - NO PSIONICS BLOCK, for the same reason as the PB-dolphin: the entry
    defers to the normal killer whale, whose pow') > 0
   AND instr(markdown, ' psionics_allowed is not set, as it is not on the killer-whale class;
    close-out package C5 reads the page for both.
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No psionics block is stored, because half of all naut''yll have none."',
         'That roll is the other naut''yll''s. The Koral Shaper does not make it: the class is a major psionic and carries its own psionics block."'),
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-koral-shaper'
   AND instr(markdown, 'No psionics block is stored, because half of all naut''yll have none."') > 0
   AND instr(markdown, 'e other naut''yll''s. The Koral Shaper does not make it: the class is a major psionic and carries its own psionics block."') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - NO PSIONICS BLOCK. Printed 148 rolls the tier and leaves half of all
    naut''yll with nothing, so granting one would give powers to characters who
    have none - the same call made on the dolphin, the orca and the Sea Titan.
',
         '  - THE RACIAL PSIONICS ROLL OF PRINTED 148 IS NOT STORED HERE, because this
    class replaces it with a grant of its own; see the major psionic note
    below. The Soldier and the Devastator, which do roll, carry no block.
'),
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-koral-shaper'
   AND instr(markdown, '  - NO PSIONICS BLOCK. Printed 148 rolls the tier and leaves half of all
    naut''yll with nothing, so granting one woul') > 0
   AND instr(markdown, ' grant of its own; see the major psionic note
    below. The Soldier and the Devastator, which do roll, carry no block.
') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'Language: Inuit is a row' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Language: Inuit' AND base = 50 AND per_level = 5 AND systems = '["rifts"]';

SELECT 'both Canada classes grant it' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('tundra-ranger-scout', 'trapper-woodsman')
   AND instr(markdown, '{ name: "Language: Inuit", base: 65, per_level: 5') > 0;

SELECT 'both Pneuma-Biforms carry the four banded options and the group' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('pneuma-biform-dolphin', 'pneuma-biform-killer-whale')
   AND instr(markdown, '- { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"]') > 0
   AND instr(markdown, '- name: "Psionics (98-00): Master Psionic"') > 0;

SELECT 'no class still says no psionics block is stored' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('pneuma-biform-dolphin', 'pneuma-biform-killer-whale', 'nautyll-koral-shaper')
   AND instr(markdown, 'No psionics block is stored') + instr(markdown, '- NO PSIONICS BLOCK') > 0;

SELECT 'all five classes are exactly the length this script leaves them' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'tundra-ranger-scout' AND length(markdown) = 19407)
    OR (class_id = 'trapper-woodsman' AND length(markdown) = 18140)
    OR (class_id = 'pneuma-biform-dolphin' AND length(markdown) = 16780)
    OR (class_id = 'pneuma-biform-killer-whale' AND length(markdown) = 15339)
    OR (class_id = 'nautyll-koral-shaper' AND length(markdown) = 15056);

INSERT INTO data_script_runs (filename) VALUES ('~114-inuit-language-and-two-psionics-groups.sql');
