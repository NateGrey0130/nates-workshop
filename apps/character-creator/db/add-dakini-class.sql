-- The Dakini, an optional R.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.142-143.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-dakini-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. Text layer, so
-- nothing was OCR'd or inferred from a page image, and the printed-to-PDF
-- offset is zero (read-columns takes 1-based pages, so printed 142 is
-- argument 143). Validated with scripts/class-check.mjs --remote against the
-- PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Indian section, servants of Kali. `psionics_allowed: false`, because the page says
-- "Psionic Powers: None" outright - different from the Naga two entries earlier,
-- which says "Standard" and therefore gets no block at all. A book that says both
-- in one chapter is telling you the silence elsewhere is deliberate.
--
-- ELEVEN GRANTED SKILLS, ALL AT per_level 0. The page lists flat percentages under
-- "Skills:" - what the creature can do, not training that improves. A per-level
-- step would have them climbing past their own book values by level three.
--
-- The P.B. minimum of 16 is `attribute_minimums`, a floor applied after the roll,
-- which is what "4D6 (minimum 16)" means. Four attacks per melee is the creature's
-- own flat number rather than "two plus those gained from training".
--
-- NO occ_restrictions and NO equipment: the page names no occupations, which is
-- why it grants a full skill list instead, and a Dakini owns her claws.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'dakini', 'Dakini', 'rifts', '---
id: dakini
name: Dakini
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "2d6+2"
  ME: "3d6"
  MA: "2d6+2"
  PS: "4d6+10"
  PP: "4d6"
  PE: "5d6"
  PB: "4d6"
  Spd: "6d6"
mdc_base: "3d6x10+20"
sdc_base: "3d6x10"
hit_points_base: "2d6x10"
ppe_base: "1d6x10"
psionics_allowed: false
bonuses:
  attribute_minimums: { PB: 16 }
  combat: { attacks: 4, initiative: 3, strike: 3, parry: 2, dodge: 4, roll: 3 }
  saves: { horror_factor: 6, spell_magic: 2, ritual_magic: 2 }
skills:
  occ_skills:
    - { name: "Wilderness Survival", base: 80, per_level: 0, note: "A natural ability, fixed at 80%." }
    - { name: "Tracking (people)", base: 75, per_level: 0, note: "Tracks humanoids, at 75%." }
    - { name: "Detect Ambush", base: 50, per_level: 0 }
    - { name: "Swimming", base: 85, per_level: 0 }
    - { name: "Climbing", base: 85, per_level: 0, note: "Rappelling is 75%." }
    - { name: "Prowl", base: 60, per_level: 0 }
    - { name: "Streetwise", base: 60, per_level: 0 }
    - { name: "Palming", base: 50, per_level: 0 }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "The book counts her claws and fingernails as the knife." }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
natural_abilities:
  - { name: "Nightvision", description: "200 feet (61 m); can see in total darkness." }
  - { name: "See the Invisible", description: "Always active." }
  - { name: "Turn Invisible at Will", description: "At will, with no stated limit." }
  - { name: "Bio-regeneration", description: "2D6 M.D.C. per minute, and severed limbs regrow in 24 hours." }
  - { name: "Resistant to Fire", description: "Takes half damage." }
  - { name: "Magically Knows All Languages", description: "Speaks and understands every language." }
  - { name: "Retractable Claws", description: "Magically grow from the fingertips to five inches long. Claw attack 3D6 M.D.; a power claw inflicts 6D6 M.D. but counts as two attacks." }
  - { name: "Bite", description: "4D6 M.D." }
  - { name: "Shape Change", description: "Takes the form of an attractive human woman - but the mind behind it is so savage and alien that the masquerade lasts only a few minutes and will not survive a conversation." }
restrictions:
  - "Alignment: anarchist or evil. As a player character the typical alignments are unprincipled or anarchist, or any evil; a scrupulous Dakini is SUPER RARE."
  - "Horror Factor: 14, when their true nature is revealed."
  - "P.B. has a minimum of 16 - roll 4D6 and treat anything lower as 16."
  - "NO PSIONICS AT ALL. The page says so outright rather than leaving it silent."
  - "Whether this supernatural monster can be a player character is left entirely to the Game Master."
  - "The character will struggle to contain her desire to drink the blood of humans and humanoids, especially vanquished opponents. She can drink animal blood, but it tastes awful."
  - "Any Dakini who befriends humans or fights on the side of good is considered a traitor, to be captured, tortured, torn to pieces and eaten. They are also the natural enemies of psi-stalkers."
  - "Normal anti-undead measures do NOT work on them - they are not vampires, whatever an investigator assumes."
side_effects: "Vampire-like servants of Kali, goddess of destruction, sent on murderous errands by their mistress and wandering off to wreak havoc of their own. Outwardly beautiful women with huge sharp teeth and five-inch nails, the body covered in a tough hide like natural plate armour; in combat bloodlust the eyes become red irisless orbs and the demon hisses and growls. Average six feet (1.8 m) and 140 lbs (63 kg). On Rifts Earth they have become ultra-powerful mega-damage creatures, sometimes roaming openly in bands of no more than 3D4."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.142-143 with
  scripts/read-columns.py. Text layer, offset zero.

  1. `psionics_allowed: false`, because the page says "Psionic Powers: None"
     outright. That is different from the Naga two entries earlier, which says
     "Standard" and therefore gets no block at all so the character can roll.
     A book that says both in the same chapter is telling you the silence
     elsewhere is deliberate.
  2. ELEVEN GRANTED SKILLS, ALL AT per_level 0. The page lists them as flat
     percentages under "Skills:" - what the creature can do, not training that
     improves with experience. Storing a per-level step would have them
     climbing past their own book values by level three.
  3. THE P.B. MINIMUM IS A FLOOR, NOT A BONUS. "P.B. 4D6 (minimum 16)" is
     `attribute_minimums`, which effective() applies after the roll - exactly
     what the parenthetical means.
  4. FOUR ATTACKS PER MELEE IS THE CREATURE''S OWN, stored in `bonuses.combat`.
     Unlike most races here the page gives a flat number rather than "two plus
     those gained from training".
  5. NO occ_restrictions. The page names no occupations at all - it does not
     expect a Dakini to take one, which is why it grants a full skill list
     instead. This is the rare R.C.C. that stands alone.
  6. NO EQUIPMENT AND NO MONEY, which is the page again: a Dakini owns her
     claws. Nothing is invented to fill the gap.
---

## Lore

The Dakini are the vampire-like servants of Kali, goddess of destruction. They
are sent on murderous errands by their mistress, and just as often wander the
land wreaking havoc of their own. What they enjoy is terror and misery - to
enslave, brutalise and feed on humans and other mortal fare.

A Dakini can assume the form of a beautiful woman, but the mind behind it is so
savage and alien that the masquerade holds for only a few minutes and will not
survive a conversation. Her favourite ploy is to appear to travellers by the
roadside, gesturing for help or beckoning suggestively; once the victim is within
striking distance she pounces, murders him and drinks his blood. In modern times
she might take the appearance of a prostitute and murder would-be customers.

Investigators who think they are dealing with a vampire get the surprise of their
lives when the normal anti-undead measures do nothing at all.

## GM Notes

Whether this is a player character is explicitly the G.M.''s call, and the book
means it - this is a monster with a hunger, not a misunderstood outsider.

If one is played, two things drive her. The first is the blood: she will struggle
to contain the desire to drink from humans and humanoids, especially the ones she
has just beaten, and animal blood works but tastes awful. The second is her own
kind. **Any Dakini who befriends humans or fights on the side of good is a
traitor to be captured, tortured, torn to pieces and eaten.** A Dakini in a party
of heroes is being hunted by her sisters from the moment she joins it.

They are also the natural enemies of psi-stalkers, which is worth knowing before
one walks into a Coalition town.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'dakini');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'dakini';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-dakini-class.sql');
