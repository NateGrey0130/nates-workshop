-- Delphi Juicer, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.39-41.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-delphi-juicer-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs before this file
-- was generated: 0 errors, 0 warnings.
--
-- The psychic. A master psionic wearing a surgically attached Psynetic helmet that carries half his power, made by a doctor who may have stolen the technology and kidnapped his test subjects.
--
-- FIFTEEN CLASSES, NOT ONE WITH VARIANTS. The obvious reading of a book called
-- "New Juicer Variants" is that `variants` is the mechanism. It is not. Each of
-- these prints its OWN O.C.C. Skills, its own O.C.C. Related Skills - the
-- Hyperion gets six where the standard Juicer gets eight, the Mega five, the
-- Titan and Phaeton and Delphi seven - its own Secondary Skills, its own
-- Standard Equipment, its own Money line, and its own numbered list of O.C.C.
-- Abilities and Bonuses. VARIANT_OVERRIDES reaches attribute dice, attribute
-- requirements, the pool bases and `bonuses`, and nothing else. It cannot touch
-- the skills block or special_abilities, and that is where these differ. Same
-- call as the RUE dragons, for the same reason.
--
-- RACE RESTRICTIONS DIFFER BETWEEN THEM, which is the other reason they cannot
-- be variants. Juicer Uprising p.17 lets a Dwarf take the standard, Titan, Mega
-- and Dragon Blood conversions and bars him from the Phaeton and the Hyperion
-- by name - their reflex enhancements burn out the Dwarven nervous system. The
-- Delphi is not on the permitted list, so Dwarves are left off it too: an
-- `only` list fails CLOSED, which is the conservative reading where the book is
-- silent. See zz-race-juicer-non-human.sql for the standard Juicer's own
-- widening and why RUE does not overrule this book.
--
-- CONDITIONAL BONUSES ARE PROSE. `bonuses:` is applied unconditionally, so the
-- Phaeton's in-vehicle figures and the Delphi's without-the-helmet halving are
-- described rather than stored. The stored numbers are the ordinary case.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'delphi-juicer', 'Delphi Juicer', 'rifts', '---
id: delphi-juicer
name: Delphi Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.39-41
category: occ
occ_group: men-of-arms
race_restrictions:
  only: ["none", "elf", "ogre"]
  note: "Juicer Uprising p.17 lets Elves take any Juicer type and Ogres any conversion, and names exactly three variants a Dwarf may take - Titan, Mega and Dragon Blood. The Delphi is not among them, so Dwarves are left off: an `only` list fails closed, which is the conservative reading where the book is silent. True Atlanteans qualify but have no R.C.C. row in this catalog yet."
attribute_requirements: { ME: 12 }
hit_points_base: "P.E. + 5d6, +1d6 per level"
sdc_base: "4d6x10"
starting_money: "5d6x100"
bonuses:
  attributes: { PS: "2d4", PE: "2d4", PP: "2d4", Spd: "1d4x10+10" }
  attribute_minimums: { PS: 20, PP: 19 }
  combat: { initiative: 3, roll: 3, attacks: 2 }
  saves: { psionics: 4, mind_control: 5, toxins_poisons: 7, harmful_drugs: 7, coma_death_pct: 20 }
psionics:
  type: "master"
  isp_base: "M.E. + 6d6, +8 per level"
  powers: ["Clairvoyance", "Presence Sense", "See Aura", "See The Invisible"]
  powers_starting: 4
  categories_allowed: ["Physical", "Super"]
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Piloting: two of choice (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - "Military"
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Medical is None for a Delphi and is therefore absent rather than restricted. Rogue is printed with +15% to Prowl only; this catalog files Prowl under Physical and a category bonus is one number, so a Delphi taking Prowl should read it at +15% on top of the Physical +5%."
  secondary_skills:
    count: 4
special_abilities:
  - name: "Psychic Amplification System (PAS) Helmet"
    description: "Surgically attached, synchronised to the wearer''s brain waves and unusable by anyone else. It increases the RANGE of all psionic powers by 10% and DOUBLES their duration, carries its own pool of 80 I.S.P. recovering at 8 per hour, armours the head with 30 M.D.C., and adds low-light, infrared and thermal optics. It can only be removed surgically, torn off by force, or blasted apart - attackers are -5 to strike on the called shot. However it comes off, the Delphi instantly loses every feature above and is so psychologically dependent on it that he loses ALL combat bonuses, one melee attack, and takes -20% on all skill performance until a replacement is fitted and calibrated, at 100,000+ credits."
  - name: "Master Psionic"
    description: "The conversion makes the Delphi a master psionic. He begins with Clairvoyance, Presence Sense, See Aura and See the Invisible, plus three powers from the Physical category and one from the Super category, taken under the same restrictions as a Mind Melter. From level two onward he selects one power per level from the Physical, Sensitive or Super categories."
  - name: "Super Endurance"
    description: "Lifts and carries four times what an equivalent person could, lasts five times longer before exhaustion, stays alert and fully efficient for up to four days without sleep and normally needs only four hours a night."
  - name: "Super Speed"
    description: "Leap 20 feet (6.1 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal and is virtually impervious to pain, as per the normal Juicer. The +20% to save versus coma and death is in the bonuses block."
side_effects: "Life span is a normal Juicer''s, but the ending is not. During LAST CALL - the final year - the Delphi''s powers start going off by themselves: every two hours one of his powers activates for no reason, chosen or rolled by the G.M., spending I.S.P. normally and simply doing its thing. That may be harmless (See Aura), merely awful (telepathic flashes from everyone nearby), or lethal (spontaneous Pyrokinesis). Short of Last Call, Delphi Juicers react badly to psychic flashes: on a disturbing or frightening involuntary vision, the Juicer may lash out blindly, physically or psionically, at the nearest target before he knows he is doing it. DETOX IS ITS OWN PENALTY. Survive it and most of the psionics are gone forever: the character drops to MINOR psionic, keeps a total of four powers from any category except Super - every super-psionic is lost - and I.S.P. falls to 4D6 plus two per level, with every other psionic bonus gone including the now-unusable helmet. Fail the detox, which involves removing the Psynetic brain implants and the PAS helmet, and the Juicer dies or is left a vegetable: I.Q. 1D4, M.E. 1D4, M.A. 1D6, and no memory of any skill, of the past, or of who he was."
restrictions: ["No cybernetics.", "Requires minor or major psionic powers before the conversion."]
extraction_notes: "The book grants three Physical powers and one Super power, and the app''s powers_starting is a single count against a list of allowed categories - so it is recorded as four picks across Physical and Super, and the 3/1 split is stated in the special ability and here. The per-level pick (one from Physical, Sensitive or Super each level after the first) is prose for the same reason. The pre-conversion psionic requirement is a restriction rather than an attribute_requirement, which takes numeric minimums on the eight attributes; the M.E. 12 half of that line IS numeric and is stored. Saving throws are HALVED without the PAS helmet, which the unconditional bonuses block cannot express - the figures stored are the with-helmet ones, which is the normal case. Augmentation cost is 150,000-200,000 credits and available only at Ishpeming; it is prose rather than starting_money, which is coin only. Standard equipment names the PAS Helmet and Juicer Assassin flex-plate armour, neither of which has a gear row yet."
---

## Lore

The Delphi Juicer is the creation of Dr. Heinrich Rommel, an immigrant from the
New German Republic who set up a body-chop-shop in Ishpeming sometime in the
early 90s P.A. Rommel sometimes speaks of having worked with a woman called
*Engel der Vernichtung*, who had managed to marry psionics to machines in the
strange science of Psynetics. Rumour says he escaped her after stealing some
psynetic prototypes, and did not stop running until he and a small guard of
Euro-Juicers had reached North America.

In Ishpeming he partnered with the Hyper-Science Corporation, a Juicer outfit
competing with Ultra-Tech Industries that could so far offer nothing but
standard conversions; its attempts at variants had killed their test subjects.
Rommel offered his expertise and began work on a Juicer with tremendous psionic
powers. The project took a long time, mostly for want of latent psychics willing
to try it - and there are rumours that Rommel and his people began taking them.
As many as a hundred Delphi Juicers may have been converted against their will,
and thereby condemned to an early death.

What came out was a psionically adept Juicer: a lethal combination of physical
and mental power, provided the character wears the Psychic Amplification Helmet
that is surgically attached to his skull. Delphi Juicers make ideal bodyguards,
assassins and scouts, and some kingdoms are building a real demand for them.

## GM Notes

**Demographics.** Delphi Juicers are 1% of all Juicers in North America.

**The helmet is the character.** Range, duration, 80 extra I.S.P., 30 M.D.C. of
head armour and the optics all live in it, and losing it costs every combat
bonus, an attack, and 20% off every skill until a 100,000-credit replacement can
be calibrated. A -5 called shot is a hard shot; an enemy who knows what a Delphi
is will still take it.

**Rommel is a hook, not a footnote.** A hundred involuntary conversions, stolen
Mindwerks prototypes, and an angel of death who may still be looking for him.
Any Delphi in a campaign has a maker, and the maker has a creditor.

**Last Call is loud for this one.** Every other Juicer spends his final year
getting weaker. A Delphi spends it setting things on fire by accident.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'delphi-juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'delphi-juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-delphi-juicer-class.sql');
