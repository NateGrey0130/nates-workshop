-- The Rifts Priest, an optional O.C.C. from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.12-15.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-rifts-priest-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book HAS a text
-- layer, so nothing here was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero - printed 12 is pymupdf index 12, which is
-- read-columns page 13. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- Applied by script rather than through the import tool because the production
-- app sits behind Cloudflare Access and cannot be driven headlessly.
--
-- THE BOOK LEAVES TWO HOLES AND THEY ARE NOT EXTRACTION GAPS. It states no
-- P.P.E. base for the priest anywhere across four pages - while its Miracles
-- cost 40 to 500 P.P.E. each - and no S.D.C. or hit point formula. Neither is
-- invented here. The first is recorded in extraction_notes and in the class's
-- own G.M. Notes, because a G.M. has to answer it before Miracles can be
-- played at all; the second is answered by the core rule, through a
-- CORE_SDC_BY_CLASS entry of 1D6 in js/compose.js, a priest not being a man of
-- arms. The Priest of Light already sits at 1D6 for the same reason.
--
-- Every skill percentage is the catalog base PLUS the bonus the page prints,
-- added here rather than at runtime: Dance 30+20, Basic Math 45+20 (stored
-- under the catalog's name, Mathematics: Basic), Lore: Demons & Monsters 25+20,
-- Land Navigation 36+10, Wilderness Survival 30+10.
--
-- The seven unconditional related-skill category bonuses use the `bonus` key
-- added in PR #260. The EIGHTH percentage on that list, Rogue's +4%, is
-- conditional - "if worship an evil or selfish god" - so it is prose under
-- restrictions instead, per the rule that a conditional bonus is never applied
-- unconditionally.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- The one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, and it is built with char(8212) rather than
-- embedded for exactly that reason.
--
-- Idempotent: the gear INSERT is OR IGNORE and the class INSERT is guarded by
-- WHERE NOT EXISTS, so re-running writes nothing.

-- Gear the class references that the catalog does not hold. Just the one: the
-- "symbol of the priest's god or pantheon" resolves to the catalog's existing
-- holy-symbol row rather than a new one, because a second row for something
-- the catalog already has is how a duplicate gets made. The energy weapon
-- follows weapons-matching-w-p-skills, which is the shape this catalog already
-- uses for a class granting a CATEGORY of weapon rather than a named model.
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('energy-weapon-of-choice', 'Energy Weapon Of Choice', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats', 'pantheons-of-the-megaverse');

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'rifts-priest', 'Rifts Priest', 'rifts', '---
id: rifts-priest
name: Rifts Priest
system: rifts
source_book: pantheons-of-the-megaverse
category: occ
starting_money: "4d4x100"
magic:
  type: "spell"
  spells_starting: 8
  spell_levels_allowed: [1, 2]
  spells_per_level_levels: up_to_character_level
  spells_schedule:
    - { level: 2, count: 4, spell_levels: [1, 2, 3] }
    - { level: 3, count: 3, spell_levels: [1, 2, 3, 4] }
    - { level: 4, count: 2 }
    - { level: 5, count: 2 }
    - { level: 6, count: 2 }
    - { level: 7, count: 2 }
    - { level: 8, count: 2 }
    - { level: 9, count: 2 }
    - { level: 10, count: 2 }
    - { level: 11, count: 2 }
    - { level: 12, count: 2 }
    - { level: 13, count: 2 }
    - { level: 14, count: 2 }
    - { level: 15, count: 2 }
skills:
  occ_skills:
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { choose: 2, from: ["Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two languages of choice (+20%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints it as Basic Math." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice, which may reflect the pantheon." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "The book grants Basic and states no substitution." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Medical", except: ["M.D. in Cybernetics"], bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Horsemanship", bonus: 5 }
      - { name: "Pilot Related", only: ["Navigation"] }
      - "Rogue"
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 20 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 5
special_abilities:
  - name: "Exorcism"
    description: "Drives out or banishes any entity or demon from a possessed person, animal, dwelling or area. The exorcised creature cannot return for at least 6 months, and 86% of the time never returns. Performed in a graveyard or tomb it destroys every animated skeleton, corpse and mummy in the area. Ghouls and zombies are banished for 10 months; lesser devils and demons, vampires, ghosts, wraiths and specters for 6 months. The rite takes 1D6 hours of prayer and meditation and needs the holy symbols of the priest''s religion. Success ratio: 7% per level of experience, and it may be attempted as many times as the priest wants."
  - name: "Healing Touch"
    description: "Restores 1D8 Hit Points or S.D.C., or 1D4 M.D.C. to a supernatural being. Usable once every other melee round, and never on the priest himself."
  - name: "Remove Curse"
    description: "As exorcism, but for magic curses: all effects of a magic or god-induced curse are removed, though new ones can be placed. It cannot lift a curse on a rune weapon, a magic item, or a sacred or supernatural place. Takes 1D4x10 minutes. Success ratio: 7% per level of experience. Only ONE attempt per curse per person by the same priest, but other priests may try where one has failed."
  - name: "Resurrection"
    description: "Breathes life back into the recently deceased. Fifth level and up only. The body must have all its parts - small ones such as fingers and toes may be missing, and stay missing. The person should not have been dead more than 4 weeks, and refrigeration adds up to 6 months to that limit without penalty; beyond it, -3% per month, and a body over a year old has a 5% chance at best. Success ratio: 10% at fifth level, plus 3% per level beyond fifth. One attempt per character by the same priest; a failed roll means the dead stay dead."
  - name: "Turn Dead"
    description: "As exorcism, but enacted in 2 melee rounds. Commands animated skeletons and corpses, mummies and ghouls to leave in the deity''s name; they stop what they are doing and go. Vampires, ghosts, wraiths and specters may be held at bay a few feet for one or two melee rounds but are not otherwise affected. Demons and gods are not affected at all. Success ratio: 20% at first level, plus 5% per additional level."
  - name: "Prayer of Strength"
    description: "Endows the priest with spiritual strength: +6 to save vs horror factor, +1 on ALL other saving throws, +10% to turn dead, +20% to exorcism, +2 spell strength, and +1 to strike, parry and dodge. Duration: 3 melee rounds per level of experience. Attemptable twice per 24 hour period. Success ratio: 20% at first level, plus 7% per additional level."
  - name: "Prayer of Communion"
    description: "Contacts the priest''s deity or another god of the pantheon, who answers with an inspirational vision or dream. 60% chance of a divination or omen warning of impending danger, treachery or good fortune, which the priest always interprets correctly. Visions are symbolic and cryptic and always concern people and matters close to him. Attemptable twice per 24 hour period. Success ratio: 21% at level one, plus 7% per additional level."
  - name: "Prayer of Intervention"
    description: "A successful prayer grants ONE temporary boon, the player''s choice. Cast any one spell of any level that the god knows, at the effects, spell strength and duration of five levels above the priest''s own, with no P.P.E. cost - the gods provide it (21% at level one, +7% per level). Or temporary knowledge to create a magic scroll, limited to 6th level and up and once per 24 hours, the spell limited to the god''s knowledge and typically equal to the priest''s level (9% per level of experience). Or Super Healing, where the healing touch instantly restores 2D4x10 Hit Points/S.D.C. or 4D6 M.D.C. for two touches (21% at level one, +7% per level)."
  - name: "Miracles"
    description: "Direct appeals to the god, used for supernatural effects such as changing the weather, parting water or granting temporary superhuman abilities. Only available when the priest is engaged in a cause the deity considers important - asking for a miracle to beat the guardian of some treasure will NOT work - and impossible if the deity judges the priest or the reason undeserving. Alone among these powers it COSTS P.P.E., and will not work if the energy is not available. Success ratio: the priest''s M.A. attribute number plus 2% per level of experience. The types are: Miracle of Luck, 40 P.P.E., giving the priest and one further follower per level +4 initiative, +10 roll with impact, +10 vs horror factor, +8 dodge, +8 vs poison, +4 vs magic potions and immunity to magic curses and charms for one minute per level. Supernatural Strength, 60 P.P.E., turning all Hit Points and S.D.C. into M.D.C., adding 2D4 to P.S. and making it supernatural, +1 initiative, +1 strike, parry and dodge, +1 on all saving throws and a horror factor of 12, for one minute per level. Then the Great Miracles: any of the eight abilities above at double duration and/or power for 100 P.P.E.; Control Over Nature for 160; Miraculous Healing for 250; and Control Over Magic for 500. Duration varies, and some effects are permanent."
  - { choose: 3, from: ["Exorcism", "Healing Touch", "Remove Curse", "Resurrection", "Turn Dead", "Prayer of Strength", "Prayer of Communion", "Prayer of Intervention", "Miracles"] }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "holy-symbol", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "food-rations", qty: "2d4" }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { item_id: "energy-weapon-of-choice", qty: 1 }
restrictions:
  - "Attribute requirements: none. The priest needs only faith and dedication to his gods; a high M.E. and M.A. are helpful but not necessary."
  - "Alignment: any, typically reflecting the pantheon the priest worships."
  - "Race: any, although some gods or pantheons restrict their priests to a particular race, and some favour monsters, D-bees or humans."
  - "Rogue skills carry +4% ONLY if the priest worships an evil or selfish god. The bonus is conditional, so it is not applied automatically."
  - "Spells are not learned. They are endowed by the deity and invoked by chanting the god''s name and the type of spell needed; a priest cannot be taught nor purchase additional spell knowledge, and most clergy know nothing about the ways of magic."
  - "Select THREE priest abilities. Where a deity''s own description grants ultra-powerful priest abilities, the character selects three ADDITIONAL powers from this list; where the god provides no magic powers and no special abilities at all, the G.M. may rule that the priest has all of them."
  - "Money: 4D4x100 in credits plus 2D4x100 in gold or gems. Only the credits are recorded as starting money. A priest may instead start with nothing, or with the fortune of a king - it varies with how he lives."
  - "Standard equipment also allows one or two symbols of the god or pantheon, and the G.M. may permit basic personal items and other odds and ends."
  - "Cybernetics and bionics: none to start. Most priests avoid even cybernetic implants other than for medical reasons, preferring to rely on their god."
side_effects: "Priests act as the link between the gods and mortals, spreading a god''s teachings, championing the deities'' cause and leading their followers spiritually. Each religion has its own moral code, and priests are expected to know and follow it wherever they go. On Rifts Earth no organised religion has officially appeared beyond the cult of Dragonwright and a few evil cults, so a priest''s powers and his alliance with a supernatural being are usually mistaken for magic, witchcraft or summoning - and societies that persecute practitioners of magic, the Coalition States above all, will persecute priests too."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.12-15 with
  scripts/read-columns.py. The book has a text layer and its printed-to-PDF
  offset is zero.

  Six things the book leaves open or states in a shape the format cannot hold,
  recorded so they are not mistaken for extraction gaps:

  1. NO P.P.E. BASE IS STATED, ANYWHERE. The class never gives the priest a
     P.P.E. pool, on any of its four pages - and its Miracles cost between 40
     and 500 P.P.E. each, so the most expensive ability in the class has
     nothing to spend. This is the book''s own gap, not a missed line: every
     P.P.E. mention in the whole section is a Miracle''s price. No base is
     invented here. A G.M. wanting one will have to pick it.
  2. NO S.D.C. OR HIT POINT FORMULA either, so the core rule applies and the
     class takes its 1D6 from CORE_SDC_BY_CLASS in js/compose.js - 1D6 rather
     than 3D6 because a priest is not a man of arms, the same reading the
     Priest of Light already gets.
  3. SPELL PROGRESSION IS DELEGATED: "Spells are gained at the same rate as
     the mystic player character (see the Rifts RPG, page 86), with the same
     restrictions." The schedule here is copied from THIS CATALOG''S Mystic,
     which is Rifts Ultimate Edition p.118-120 - a later edition than the one
     the Priest cites. The two may differ, and the original has not been
     checked because that book is not in the collection. Written out rather
     than referencing the Mystic class, so retiring or editing that class
     cannot silently change this one.
  4. Attribute requirements are NONE, which is stated outright rather than
     omitted, so no attribute_requirements block is correct here.
  5. The Rogue +4% is CONDITIONAL - "if worship an evil or selfish god" - so
     it is prose under restrictions rather than a category bonus. Every other
     percentage on the related-skill list is unconditional and is stored.
  6. HORSEMANSHIP IS GRANTED AT THE PILOT BONUS. The book says "Pilot: Any
     (+5%)" and says nothing about riding, because in 1994 Horsemanship WAS a
     Pilot skill. This catalog files those skills under their own Horsemanship
     category, so listing Pilot alone would have quietly withheld them. The
     category is granted at the same +5% the book gives Pilot.

  Two gear notes. The "symbol of the priest''s god or pantheon" resolves to the
  catalog''s existing `holy-symbol` rather than a new row - a second row for a
  thing the catalog already holds is how a duplicate gets made. The "energy
  weapon of choice" is a STUB, following `weapons-matching-w-p-skills`, which
  is the shape this catalog already uses for a class granting a category of
  weapon rather than a named one.

  The nine priest abilities are a choose-three group, and the Miracles entry
  carries all six miracle types inside its own description rather than as
  separate abilities. That is deliberate: a special ability outside a choice
  group is GRANTED, so six loose Miracle entries would have handed every
  priest the 500-P.P.E. Control Over Magic whether or not he took ability 9.
---

## Lore

Priests, priestesses and shamans act as the links between the gods and mortals.
They spread the teachings of a god or pantheon, champion the cause of the
deities, and act as the spiritual leaders of their followers. A priest knows his
pantheon''s friends, allies, enemies, rivals and cults, and the moral code of his
religion, which he is expected to follow wherever he goes.

Their abilities come directly from the deity and from faith. The spells are
identical to the spell magic of wizardry - the difference is in how they are
attained, not how they work. A priest is endowed with the ability to cast, not
taught it, and invokes a spell by chanting his god''s name and the kind of spell
he needs.

So far no organised religion has officially appeared on Rifts Earth, beyond the
cult of Dragonwright and a few evil cults. The technologically advanced
societies tend to believe in a distant, benevolent god who takes no direct hand
in human affairs, and the Coalition States recognise most so-called gods as
super powerful beings from alien worlds - enemies of humankind, to be attacked
and destroyed if they threaten. The poor and uneducated of the burbs and the
wilderness swing the other way, and can be compelled by fear and desperation to
believe any powerful being who claims to be a god.

That leaves a priest converting the hard way. His powers will be confused with
magic, witchcraft or summoning, and societies that persecute practitioners of
magic will persecute him too. To convince a community, he has to set an example
and let his deeds argue for him. Most good priests are valuable allies against
the forces of darkness, and small communities under siege by dark forces are the
likeliest to accept a priest''s protection and his religion with it.

## GM Notes

The priest is an OPTIONAL O.C.C. and it is deliberately open-ended: the book
hands the G.M. the two decisions that matter. The first is which deity, because
a god''s own description may grant ultra-powerful priest abilities of its own -
and where it does, the three powers chosen here are three ADDITIONAL ones. Where
the god grants nothing at all, the book says the G.M. may simply give the priest
every ability on the list.

The second is Miracles, which are not a resource the player spends freely. They
work only when the priest is engaged in a cause the deity considers important,
and they fail outright if the god judges the priest or the reason undeserving.
The book is explicit that a miracle asked for to defeat the guardian of some
treasure will not work. It also allows the reverse: where the gods are actively
watching a priest who is acting on their behalf, the G.M. may grant a miracle
regardless of the roll.

Note that the class states no P.P.E. of its own while its Miracles cost 40 to
500 points. That is the book''s gap, and it needs an answer before Miracles can
be played at all.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'rifts-priest');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr,
       instr(markdown, 'bonus: 20') > 0 AS has_technical_bonus
  FROM imported_classes WHERE class_id = 'rifts-priest';
SELECT count(*) AS stub_gear FROM gear WHERE slug = 'energy-weapon-of-choice';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-rifts-priest-class.sql');
