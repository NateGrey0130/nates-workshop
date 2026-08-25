-- The Naga, an optional R.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.141-142.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-naga-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. Text layer, so
-- nothing was OCR'd or inferred from a page image, and the printed-to-PDF
-- offset is zero (read-columns takes 1-based pages, so printed 141 is
-- argument 142). Validated with scripts/class-check.mjs --remote against the
-- PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Indian section, The Asuras. S.D.C. is a POOL BONUS again - "plus that gained from
-- O.C.C.'s and physical skills".
--
-- "PSIONIC POWERS: STANDARD" MEANS NO PSIONICS BLOCK, which is the opposite of
-- how it reads. Declaring a tier fixes the character at it and stops the roll;
-- silence is what lets the roll happen. The sentence about almost no major and
-- fewer master psionics is about the odds on that roll and is recorded as prose.
--
-- NO occ_restrictions, deliberately. The page gives a DISTRIBUTION of what Nagas
-- tend to be - 20% practitioners of magic, 40% warriors - not a list of what they
-- may become. Reading a distribution as a restriction would bar occupations the
-- book never bars.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'naga', 'Naga', 'rifts', '---
id: naga
name: Naga
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6"
  MA: "3d6+2"
  PS: "4d6+6"
  PP: "4d6"
  PE: "3d6+2"
  PB: "3d6"
  Spd: "6d6"
mdc_base: "3d4x10"
ppe_base: "1d6x10"
hit_points_base: "P.E. + 1D6 per level of experience"
bonuses:
  pools: { sdc: "1d4x10+40" }
  combat: { initiative: 2, strike: 1 }
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Tracking (people)", base: 62, per_level: 0, note: "Tracks by smell, at 62%. A keen sense of smell equal to a Dog Boy''s." }
    - { name: "Swimming", base: 80, per_level: 0, note: "A natural ability, fixed at 80%." }
    - { name: "Climbing", base: 90, per_level: 0, note: "A natural ability, fixed at 90%; rappelling is 80%." }
natural_abilities:
  - { name: "Nightvision", description: "90 feet (27.4 m); can see in total darkness." }
  - { name: "Sharp Vision", description: "Keen eyesight." }
  - { name: "Keen Sense of Smell", description: "Equal to a Dog Boy''s, and the basis of the tracking skill above." }
  - { name: "Resistant to Heat and Fire", description: "Takes half damage." }
  - { name: "Bio-regeneration", description: "1D4x10 M.D.C. per hour." }
  - { name: "Poisonous Bite", description: "1D6 M.D. plus a paralysing poison - halve the victim''s speed, combat bonuses and attacks per melee for 1D6 rounds; 14 or higher to save." }
restrictions:
  - "Alignment: any, but those who closely associate with demons and evil gods are usually evil or anarchist."
  - "Horror Factor: 12."
  - "Natural combat is two attacks per melee, plus those gained from combat training."
  - "Psionics are STANDARD. Almost no major psionics are found among this race, and fewer master psionics still."
  - "Magic varies with the O.C.C."
  - "About 20% of all Nagas are practitioners of magic - of those, 40% are ley line walkers, 15% warlocks, 10% diabolists or shifters, 30% mystics, 5% other. Another 40% are warriors, hunters and scouts, and the rest divide evenly among builders, farmers and labourers. ALL Nagas have some basic combat and military training."
  - "Their technology level is typically low, but they are fast learners and can use modern armour and weapons."
side_effects: "Human-snake hybrids: a long serpent body with a humanoid head, upper torso and two arms. The mouth looks human but has a flexible jaw and retractable poisonous fangs, used mainly in self-defence. Green, black or mottled green and black, with a white or yellow underbelly. Ten to twenty feet long (3 to 6 m), 300 to 1000 lbs (135 to 450 kg). Very fast on the ground and masterful climbers, fond of coiling around trees and pillars. Their societies are matriarchal monarchies under a royal Queen or Empress, and intensely clan-oriented: eggs are cared for by the whole clan and no Naga knows who its parents were."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.141-142 with
  scripts/read-columns.py. Text layer, offset zero.

  1. THE S.D.C. IS A POOL BONUS - "1D4x10 + 40 S.D.C. PLUS THAT GAINED FROM
     O.C.C.''s AND PHYSICAL SKILLS", the cumulative wording again.
  2. "PSIONIC POWERS: STANDARD" MEANS NO PSIONICS BLOCK. Declaring a tier would
     fix the character at it and stop the roll; silence is what lets the roll
     happen. The sentence that follows - almost no major and fewer master
     psionics - is about the odds on that roll, not a cap the format can hold,
     so it is recorded as prose.
  3. THREE NATURAL ABILITIES ARE STORED AS SKILLS because the page gives them
     percentages: track by smell 62%, swim 80%, climb 90%/80%. per_level is 0 -
     these are what the body does, not training that improves. Climbing''s
     second number is the rappel percentage and lives in its note, the format
     holding one figure per skill.
  4. NO occ_restrictions, deliberately. The page gives a BREAKDOWN of what
     Nagas tend to be - 20% practitioners of magic, 40% warriors and so on -
     not a list of what they may become. A distribution is not a restriction,
     and reading it as one would bar occupations the book never bars. Recorded
     under restrictions so the flavour survives.
  5. `Tracking (people)` is the catalog''s name for what the book calls tracking
     by smell. Checked against production rather than guessed - the catalog
     also holds `Track & Trap Animals`, which is a different skill.
---

## Lore

The Nagas are human-snake hybrids who prefer wilderness near lakes and rivers,
and can live almost anywhere but desert. They are natives of another dimension
and have served the demon lords and gods of India for eons, worshipping several
pantheons - the Brahmanic gods, though never the older Vedic deities, and in
some cases the Aztec gods, particularly Cihuacoatl.

As a race they are no more and no less evil than any other. They prey on humans
and D-bees, plundering and enslaving, mainly because their demon masters
encourage and demand it.

The ancient Nagas left Earth for a more magic-rich environment when P.P.E. levels
declined. A handful stayed in forgotten jungle temples, attacking explorers and
treasure-hunters who wandered into their domain. With the eruption of the ley
lines they have begun to return, some already to the jungles of India and
Southeast Asia, building new cities and temples.

## GM Notes

The clan is the character. Naga eggs are raised communally and no Naga knows who
its parents were - the stories about mothers who tried to raise their own young
all end in exile, murder or worse. A Naga player character separated from its
clan is missing something a human character would not even have a word for.

Their evil is also worth playing carefully. The book is explicit that the race is
not inherently worse than any other and that the predation is what their demon
masters demand of them. That leaves room for a Naga who has stopped doing it,
and for what the masters do about that.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'naga');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'naga';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-naga-class.sql');
