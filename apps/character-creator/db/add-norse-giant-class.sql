-- The Greater Norse Giant, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.163.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-norse-giant-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- A greater giant, not one of the lesser frost/fire/earth giants that Rifts
-- Conversion Book One covers. The book prints NO P.B. attribute - it lists seven
-- and stops, checked against the raw text - so none is invented here.
--
-- THE OCCUPATION LIST IS ENUMERATED ON PURPOSE. The book says "any men of arms
-- OTHER THAN CS or NGR type military", and a group token cannot carve out an
-- exception: only: ["group:men-of-arms"] would have admitted the three Coalition
-- classes, which is exactly what that sentence excludes. The eight non-Coalition
-- men of arms are listed by id and were diffed against production. A Rifts man of
-- arms imported later will need adding here by hand.
--
-- `necromancer` is named and this catalog does not hold it. That is safe in an
-- `only` list - an unmatched name never matches, so the O.C.C. stays unavailable
-- for the honest reason that it does not exist, and the permission activates by
-- itself the day the row arrives.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'norse-giant', 'Greater Norse Giant', 'rifts', '---
id: norse-giant
name: Greater Norse Giant
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "4d4"
  ME: "3d6"
  MA: "3d6"
  PS: "6d6+20"
  PP: "4d6+2"
  PE: "4d6+3"
  Spd: "6d6+10"
mdc_base: "2D6x100 plus 10 per level of experience"
ppe_base: "2d6x10"
occ_restrictions:
  only: ["combat-cyborg", "crazy", "cyber-knight", "glitter-boy", "headhunter-techno-warrior", "merc-soldier", "robot-pilot", "witch", "warlock", "ley-line-walker"]
  note: "80% are warriors - any man of arms EXCEPT Coalition or NGR military. The other 20% study magic, limited to witch, warlock, necromancer or ley line walker; this catalog has no Necromancer O.C.C. yet."
bonuses:
  combat: { initiative: 2 }
  saves: { horror_factor: 4 }
natural_abilities:
  - { name: "Nightvision", description: "60 ft (18.3 m); can see in total darkness." }
  - { name: "Resistant to cold or heat", description: "Half damage - cold for a frost giant, heat for a fire giant." }
  - { name: "Bio-regeneration", description: "1D4x10 M.D.C. per minute." }
special_abilities:
  - name: "Additional M.D.C."
    description: "An additional 1D6x1000 M.D.C., or 2D4x100 S.D.C. in a non-mega-damage world. Rolled 01-05."
  - name: "Great Nightvision"
    description: "Nightvision to 1000 ft (305 m). Rolled 06-10."
  - name: "Turn Invisible at Will"
    description: "Turn invisible at will. Rolled 11-15."
  - name: "Impervious to Heat and Fire"
    description: "Impervious to heat and fire. Rolled 16-20."
  - name: "Fangs and Poisonous Bite"
    description: "3D6 damage per melee for 1D6 rounds. Rolled 21-24."
  - name: "Change Size at Will"
    description: "Change size at will, from 6 to 40 feet (1.8 to 12.2 m). Rolled 25-30."
  - name: "Pair of Tentacles"
    description: "+1 attack per melee and +1 to parry. Rolled 31-33."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Giant''s Strength"
    description: "Add 10 to the P.S. attribute. Rolled 34-40."
    bonuses: { attributes: { PS: 10 } }
  - name: "Thick, Lumpy Skin"
    description: "Add 1D4x100 M.D.C., or S.D.C. in a non-mega-damage world. Rolled 41-45."
    bonuses: { pools: { mdc: "1d4x100" } }
  - name: "Pair of Additional Arms"
    description: "+2 attacks per melee and +2 to parry. Rolled 46-50."
    bonuses: { combat: { attacks: 2, parry: 2 } }
  - name: "Additional Eye"
    description: "Hawk-like vision and see the invisible. Rolled 51-54."
  - name: "Prehensile Tail"
    description: "Adds one attack per melee round. Rolled 55-59."
    bonuses: { combat: { attacks: 1 } }
  - name: "Battle-Hardened"
    description: "+2 on initiative, +2 to roll with impact, +4 to save vs horror factor. Rolled 60-64."
    bonuses: { combat: { initiative: 2, roll: 2 }, saves: { horror_factor: 4 } }
  - name: "Great Speed"
    description: "Add 1D4x10 to the Spd attribute. Rolled 65-69."
    bonuses: { attributes: { Spd: "1d4x10" } }
  - name: "Metamorphosis into Animal"
    description: "Metamorphosis into an animal at will. Rolled 70-75."
  - name: "Retractable Claws"
    description: "Add 2D6 to all hand to hand attacks. Rolled 76-80."
  - name: "Increased Healing"
    description: "Regenerates 1D4x100 M.D.C. per minute. Rolled 81-84."
  - name: "Create Fire Ball"
    description: "Once per melee round at will. Range 1000 feet (305 m), does 1D4x10 M.D. Rolled 85-90."
  - name: "Create Lightning Bolt"
    description: "Once per melee round at will. Range 1000 feet (305 m), does 6D6 M.D. Rolled 91-95."
  - name: "Third Monstrous Eye and Ugly Head"
    description: "Psionic with ALL sensitive powers and six super-psionic powers of choice. Rolled 96-00."
    psionics: { type: "master" }
  - { choose: 3, from: ["Additional M.D.C.", "Great Nightvision", "Turn Invisible at Will", "Impervious to Heat and Fire", "Fangs and Poisonous Bite", "Change Size at Will", "Pair of Tentacles", "Giant''s Strength", "Thick, Lumpy Skin", "Pair of Additional Arms", "Additional Eye", "Prehensile Tail", "Battle-Hardened", "Great Speed", "Metamorphosis into Animal", "Retractable Claws", "Increased Healing", "Create Fire Ball", "Create Lightning Bolt", "Third Monstrous Eye and Ugly Head"] }
restrictions:
  - "Alignment: any, but leans towards anarchist and evil. A Norse giant of a scrupulous or principled alignment is likely to be thought untrustworthy and a freak, and probably tormented as well."
  - "Horror Factor: 10+1D6."
  - "Attacks per melee: two without any combat training, or two plus those gained from hand to hand combat and/or boxing."
  - "The +4 to save vs horror factor does NOT apply when dealing with Thor. No bonus then."
  - "Some greater giants are the equivalent of gods, at 3D6x1000 M.D.C., but they are rare - perhaps one in ten thousand - and serve as the warrior lords and leaders of the other giants. Not a player character."
  - "Roll once on the insanity table, or have the G.M. pick: 01-15 none, 16-40 phobia, 41-70 obsession, 71-80 neurosis, 81-90 psychosis, 91-00 affective disorder."
  - "Size is 1D4x10 feet (3 to 12.2 m). Changing size is one of the special powers rather than something every giant can do."
  - "Occupations: 80% are warriors - any men of arms other than Coalition or NGR type military - and 20% study magic, limited to witch, warlock, necromancer or ley line walker. The CS and NGR exclusion is prose because the format cannot express an exception inside an `only` list."
side_effects: "The giants of Norse myth were more than overly large humanoids. The Old Norse word for them was iotnar, which means demon or monster: supernatural creatures whose powers were almost the match of the gods, many with shape shifting and magical powers. Average life span 2000+ years. The LESSER Norse giants are the Algor frost giants, Nimro fire giants, Jotan earth giants and Gigantes described in Rifts Conversion Book One; this entry is the greater giants, who are far more powerful."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.163 with
  scripts/read-columns.py. Text layer, offset zero.

  Five things worth recording:

  1. THE BOOK PRINTS NO P.B. It lists I.Q., M.E., M.A., P.S., P.P., P.E. and
     Spd and simply stops. That is the page, not a dropped line - checked
     against the raw text. No P.B. die is invented here, so the attribute is
     left for the G.M. to set.
  2. NO SKILLS OF ANY KIND, and that is correct rather than missing. The giant
     takes an O.C.C. and every skill comes from there - the pure
     race-plus-occupation case, the same as the Demigod.
  3. "Experience: Use same table as the Dragon R.C.C." No xp_table is stored,
     and that IS the delegation rather than a gap: this catalog''s
     dragon-hatchling stores no xp_table either, so both fall through to
     DEFAULT_XP_TABLE in js/leveling.js and the two genuinely share one table.
     Writing a table out here would be the thing that broke the promise.
  4. The twenty special abilities are the book''s random table, kept in its
     printed order with each entry''s roll range in its description. The book
     says "Roll for (or GM pick) three random abilities or pick three", so a
     choose-three group covers both readings; the percentiles are recorded so
     a G.M. who wants to roll still can.
  5. "Psionics: Standard" means NO psionics block at all, which is the opposite
     of what it looks like. Declaring a tier would fix the giant at that tier
     and stop him rolling on the Random Psionics Table; staying silent is what
     lets the roll happen, and "standard" is the roll. Same reading the Demigod
     already records. Ability 96-00 is the exception and carries `psionics:
     master` on itself, where it belongs, rather than on the class.

  THE OCCUPATION LIST IS ENUMERATED, AND IT IS THE ONE PLACE THIS CLASS COULD
  GO STALE. The book says "any men of arms OTHER THAN CS or NGR type military",
  and a `group:` token cannot carve out an exception - `only:
  ["group:men-of-arms"]` would have admitted coalition-grunt,
  coalition-samas-pilot and coalition-technical-officer, which is the exact
  thing the sentence excludes. So the eight non-Coalition men of arms are
  listed by id, checked against production, and a Rifts man of arms imported
  later will need adding here by hand. That is a real cost and it is the
  cheaper of the two errors.

  JUICER IS LEFT OUT although it is a man of arms, because the other direction
  already refuses it. `race_restrictions` closes the Juicer - along with the
  Dog Boy, both Psi-Stalkers and the three Coalition classes - to every Rifts
  race, human only, and that rule reaches this class the moment it exists.
  Listing it here would have been a permission that silently does nothing: the
  wizard would offer it and the pairing would be refused. Same smell as a
  restriction that silently does nothing, pointed the other way.

  combat-cyborg and crazy ARE left available. The book does not repeat the
  Demigod''s rule that those treatments fail on a supernatural being, and
  nothing in the catalog closes them, so both directions agree. Odd for a
  2D6x100 M.D.C. creature, and deliberate: this entry says men of arms and
  stops.

  NECROMANCER IS OMITTED FROM THE LIST, and the omission is the interesting
  part. The book allows witch, warlock, necromancer or ley line walker; this
  catalog holds no Necromancer O.C.C. A dangling name in an `only` list is
  harmless on its own - it never matches, so the occupation stays unavailable
  for the honest reason that it does not exist - but `occ_restrictions` is held
  to a stricter rule than skill restrictions are: regression asserts that every
  occupation a race names is a real O.C.C., because in an `except` list the
  same dangling name silently ALLOWS what it meant to forbid. One rule for both
  list kinds is the right trade, so the name comes out and the note records
  what to add when a Necromancer O.C.C. exists. The other three were checked
  against production.

  The insanity table is prose under restrictions rather than a mechanic. The
  app has no insanity model, and inventing one for a single class would be the
  wrong place to start.
---

## Lore

The giants of Norse myth were more than overly large humanoids. The Old Norse
word used to name them was *iotnar* - demon, or monster. These were
supernatural creatures whose powers were almost the match of the gods, and many
of them had shape shifting and magical powers of their own.

Their abilities are quite varied, which is why no two greater giants are alike.
The lesser Norse giants - the Algor frost giants, Nimro fire giants, Jotan earth
giants and the Gigantes - are described in Rifts Conversion Book One. These are
the greater giants, and they are far more powerful.

A giant of a scrupulous or principled alignment is a freak among his own kind:
untrustworthy in their eyes, and likely tormented for it.

## GM Notes

Two things to hold onto. The first is that a greater giant is a walking
exception - the twenty-entry ability table means the giant the players meet may
be able to do something no other giant they have met could, and the book means
that. Roll, or pick to fit the story.

The second is Thor. The giant''s +4 to save vs horror factor is void when he is
dealing with Thor, and that single line is the whole relationship between this
race and the Aesir: they are frightened of him specifically. It is worth playing.

The rare god-equivalent giants at 3D6x1000 M.D.C. are warrior lords, roughly one
in ten thousand, and are not player characters.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'norse-giant');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'norse-giant';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-norse-giant-class.sql');
