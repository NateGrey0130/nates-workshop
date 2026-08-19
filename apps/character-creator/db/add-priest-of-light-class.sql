-- The Priest of Light O.C.C., Palladium Fantasy RPG main book
-- (palladium-fantasy-core).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-priest-of-light-class.sql
--
-- Extracted by Claude from the page images through import/extract and
-- corrected in review (see `extraction_notes` in the markdown). Byte-identical
-- to what the local dress rehearsal published through the real confirm
-- endpoint. First Palladium Fantasy class through the Claude import path -
-- the gear stubs carry system 'palladium-fantasy', matching what confirm
-- creates for a class whose frontmatter says so.
--
-- The Lore: Religion stub skill keeps the Technical category the server's
-- pattern matcher chose; its base stays 0 and needs a real value from the
-- skills chapter.
--
-- The em-dash in the stub description is built with char(8212) because
-- passing one through `wrangler d1 execute` on Windows has produced mojibake
-- before. Pure ASCII on purpose, for the same reason.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('traveling-robe-or-cloak-with-hood', 'Traveling Robe Or Cloak With Hood', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('ceremonial-robe', 'Ceremonial Robe', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('boots', 'Boots', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('belt', 'Belt', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('bedroll', 'Bedroll', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('purse-satchel', 'Purse Satchel', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('water-skin', 'Water Skin', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('holy-symbol', 'Holy Symbol', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('large-silver-cross', 'Large Silver Cross', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('wooden-spike', 'Wooden Spike', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-mallet', 'Small Mallet', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('rope', 'Rope', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('vial-of-holy-water', 'Vial Of Holy Water', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('silver-chalice', 'Silver Chalice', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-mirror', 'Small Mirror', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('tinder-box', 'Tinder Box', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('staff', 'Staff', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('blunt-weapon', 'Blunt Weapon', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('chain-weapon', 'Chain Weapon', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('spear', 'Spear', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sword', 'Sword', 'palladium-fantasy', 'STUB ' || char(8212) || ' created by class import, needs stats', 'palladium-fantasy-core');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES ('Lore: Religion', 'Technical', 0, 0, 'import');
UPDATE skills SET category = 'Technical' WHERE name = 'Lore: Religion' AND category IS NULL;

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('priest-of-light', 'Priest of Light', 'palladium-fantasy', '---
id: priest-of-light
name: Priest of Light
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "6D6 plus P.E. attribute number and 1D6 per level of experience"
skills:
  occ_skills:
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }
    - { name: "Literacy", base: 50, per_level: 5, note: "One language of choice (+20%)" }
    - { name: "Basic Math", base: 65, per_level: 5, note: "+20%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice, may reflect pantheon" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Expert for the cost of two other skills, or to Martial Arts for the cost of four other skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Siege", "W.P. Targeting", "W.P. Large Axes", "W.P. Pole Arms", "W.P. Lance"] }
      - "Wilderness"
    note: "Espionage offers none and is omitted. Category bonuses: Communications +5%, Domestic +10%, Medical +15%, Military +5%, Science +5%, Technical +15%. Heraldry and Interrogation Techniques are book options the catalog does not carry yet, and most of the barred W.P.s are not catalog rows yet either - the except list names them for when they arrive."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
      - { level: 13, count: 2 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "traveling-robe-or-cloak-with-hood", qty: 1 }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "holy-symbol", qty: 2 }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "wooden-spike", qty: 4 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "vial-of-holy-water", qty: "1d6" }
  - { item_id: "silver-chalice", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { choose: 2, label: "starting weapon", qty: 1, from: ["staff", "blunt-weapon", "chain-weapon", "spear", "sword"] }
starting_money: 150
natural_abilities:
  - name: "Healing Touch"
    description: "Restores 2D4 hit points or S.D.C. (1D4 M.D.C. to supernatural beings on a mega-damage world). Can be performed once every other melee round, but cannot be used on the priest himself. May be sold for a fee (5 gold to 1D6x100 gold per touch; average 25-30 gold)."
  - name: "Exorcism"
    description: "A successful exorcism drives out/banishes any entity or demon from a possessed person, animal, dwelling or area. Exorcised creatures cannot return for at least 6 months (86% likelihood of never returning). Performed in a graveyard or tomb, it destroys animated skeletons, corpses and mummies present; ghouls and zombies are banished for 10 months; greater supernatural creatures including lesser devils and demons, vampires, ghosts, wraiths and specters are banished for 6 months. Requires 1D6 hours of prayer and meditation and the priest''s holy symbols. Success ratio: 7% per level of experience. Can be attempted as many times as desired."
  - name: "Remove Curse"
    description: "Removes magic or god-induced curses from a person or animal (new curses can still be placed later). Cannot remove curses placed on/in rune weapons, magic items, or sacred/supernatural places. Takes 1D4x10 minutes to perform. Success Ratio: 7% per level of experience. Can only be attempted ONCE per curse on the same person, though other priests may try after a failure."
  - name: "Resurrection"
    description: "Breathes life into the recently deceased. The body must have all its parts (small parts like fingers/toes may remain missing). The deceased should not have been dead more than 2-4 weeks (refrigeration adds up to 6 months to that limit); -3% penalty per month beyond four weeks. Bodies dead over one year have only a 5% total chance. Can only be attempted by priests of 5th level or higher. Ratio of Success: 10% at 5th level, +3% per additional level. Can only be attempted ONCE on the same character by the same priest; a failed roll means the character remains dead."
  - name: "Turn Dead"
    description: "Similar to exorcism but enacted in only two melee rounds (30 seconds). Affects only animated skeletons, corpses, mummies and ghouls, commanding them to leave. Vampires, ghosts, wraiths and specters may hesitate for one or two melee rounds but are not otherwise affected. Demons, deevils, gods and most other supernatural beings are unaffected. Success Ratio: 20% at first level, +5% per additional level."
  - name: "Penance and Sacrifice"
    description: "Techniques of self-denial including meditation, fasting, vows of abstinence, and vows of silence. Priests can resist thirst for two days per level of experience, and resist hunger for three days per level of experience. The priest can ignore the pain and discomfort and function at close to normal, though the physical body still suffers damage from dehydration, starvation, etc."
  - name: "Spell Casting"
    description: "Priests are endowed with spellcasting directly by their deity(s); it is not a learned or practiced skill, and most clergy know nothing of the ways of magic otherwise. Spells are invoked by chanting the god''s name and the type of spell needed. Begins at third level: automatically gains Tongues plus one additional spell selection from wizard magic levels 1-3. One additional spell (levels 1-3) is gained per subsequent level of experience. Priests cannot be taught nor purchase additional spell knowledge. Spell Strength: starts at 12, +1 at levels six and twelve."
  - name: "Special Prayers"
    description: "Pleas to the god(s) for strength, insight, and minor acts of intervention, including Blessings (of water, of a person, of a home, of food), Prayer of Strength, Prayer of Communion, and Prayer of Intervention (grants the ability to cast any one spell known by the priest''s god at +5 levels of effective power with no P.P.E. cost, temporary knowledge to create a magic scroll (6th level+), or Super Healing restoring 2D4x10 hit points/S.D.C. or 4D6 M.D.C. with two healing touches)."
  - name: "Miracles"
    description: "Direct appeals to the god(s) for incredible acts of intervention such as changing weather, parting bodies of water, or granting temporary superhuman abilities. Absolutely at the deity''s discretion and rarely granted for personal gain; success ratio equals the priest''s M.A. attribute number plus 2% per level of experience, though a deity may grant one regardless of the roll at the GM''s discretion. Does not require the priest to expend P.P.E.; if energy is unavailable the god provides it. Types include Miracle of Luck, Supernatural Strength, Purification, and the Great Miracles of Increased Power, Control Over Nature, Miraculous Healing, and Control over Magic."
level_progression:
  - level: 1
    grants: ["Healing Touch", "Exorcism", "Remove Curse", "Turn Dead", "Penance and Sacrifice", "Special Prayers"]
  - level: 3
    grants: ["Begins acquiring spells: automatic Tongues plus one additional spell selection (levels 1-3); one additional spell per subsequent level"]
  - level: 5
    grants: ["May attempt Resurrection"]
  - level: 6
    grants: ["+1 Spell Strength", "May attempt Temporary Knowledge to Create a Magic Scroll (Prayer of Intervention)"]
  - level: 8
    grants: ["Can bless two people or two items per level of experience without loss of potency"]
  - level: 12
    grants: ["+1 Spell Strength"]
extraction_notes: |
  - REVIEW: the nine priestly abilities are automatic and live under
    natural_abilities - special_abilities is for powers a player chooses, and
    this class chooses none; level_progression records when each arrives.
    Fixed skills fold the O.C.C. bonus into the catalog base (Dance 30+20=50);
    Lore: Religion has a catalog row via backfill-import-skill-gaps.sql; its
    base here folds that catalog base plus the O.C.C. bonus.
  - REVIEW: the book gives 1D6 vials of holy water, and the entry says so -
    the wizard rolls a dice-valued quantity once at creation and stores the
    number, the same discipline as pools and attribute bonuses.
  - REVIEW: the priest''s spells come from the deity at level three onward
    (Tongues plus one selection from wizard levels 1-3, one more per level).
    No magic block is declared: the class starts with no spells at level one,
    and declaring one would have the wizard offer spell picks the book does
    not grant until third level. The schedule lives in Spell Casting and
    level_progression.
restrictions:
  - "Priests are not trained as men of arms or in the use of weapons and armor with rare exception; hand to hand combat is not generally part of priestly teaching (though most travelling priests learn at least basic hand to hand)."
  - "Covering more than 50% of the body in metal armor requires the priest to spend 20% more P.P.E. to cast a spell and roll on a table for additional negative effects (reduced spell damage/effects, duration, or range by 1D4x10%, or lucked out with no problem)."
  - "Encumbrance penalties for armor: -15% to prowl and -20% to climb/scale walls or swim in full splint or plate armor; -10% to prowl, swim or climb in chain or scale mail; -5% in studded leather."
  - "The character must have an obvious and practiced allegiance to a particular god or pantheon; the deity selected should have a compatible alignment with the character."
  - "If a character disobeys, rebukes, or bad-mouths his deity(s), he will be punished, often severely (e.g., loss of experience levels, temporary or permanent restriction of abilities), at the GM''s discretion."
  - "Priests who forsake their god(s) completely are stripped of every clerical ability, skill ability and experience, and must start from scratch with a new O.C.C.; reinstatement as a priest of the same or another god is unlikely, and if granted is likely to start at level one or two."
  - "A blessing will not work if the person receiving it does not respect and acknowledge (not necessarily worship) the deity in whose name the prayer is invoked."
extraction_notes: |
  - Attribute Requirements explicitly "None" per the book, so the field is omitted.
  - Hit point/S.D.C. base formulas are not given on these pages for the Priest of Light; only P.P.E. base and Spell Strength progression are stated, so hit_points_base/sdc_base are omitted rather than invented.
  - Armor and weapon starting choices: the book states armor starts as soft leather (A.R. 10, S.D.C. 20) and weapons start with "two of choice" from a favored list (staves, blunt weapons, chain weapons, spears, swords) - modeled as a choose:2 equipment entry; the specific soft leather armor is not modeled as an equipment_starting item_id since it''s described in armor terms rather than as a distinct catalog item, but is noted here: Armor: soft leather, A.R. 10, S.D.C. 20.
  - Alignment is "Any; typically reflective of the pantheon the priest worships. Priests of the Gods of Light typically start as good or selfish alignments." Not modeled as a schema field (no explicit slot for alignment), recorded here.
  - Race: "Any; although some gods/pantheons may restrict their priests to be members of a particular race or races, and some will be favorites of monsters and humans." Not modeled as a schema field, recorded here.
  - The percentage success ratios for many special abilities (exorcism, remove curse, resurrection, turn dead, special prayers, miracles) are level-scaling formulas embedded in prose; they are not flat numeric bonuses of the type the `bonuses` schema captures (they are percentile success chances, not combat/save bonuses), so they remain in the special_abilities descriptions rather than under `bonuses`.
  - Secondary skills schedule: the book grants 4 secondary skills at level one, then two additional at levels 2, 5, 7, 10, and 13 - encoded as a schedule under secondary_skills for completeness, though the target schema''s example only shows a schedule under occ_related_skills; included here as the most faithful representation available.
  - Money: "The character starts with 150 in gold." Additional notes that a typical priest gives the church at least 50% of money earned - this is roleplaying/GM color, not a mechanical bonus, and is left in Lore/GM Notes rather than a field.
  - The lengthy Maryann Siembieda anecdote about disobeying a deity and being reduced from 7th to 4th level is illustrative fiction/example, not a fixed mechanical rule, and is placed under Lore/GM Notes rather than as a bonus or restriction with fixed numbers.
---

## Lore

In the Palladium world, a priest is a man or woman who has dedicated themselves to the service of a particular god or pantheon of gods. They may belong to the official Church of the Realm, a continent-spanning church like the Church of Light, or a small church, temple, monastery, cult, clan or organization with only a handful of members. The popularity of a religion is not what matters - it is the priest''s dedication to that deity, pantheon or belief.

Most player characters play a travelling priest determined to spread the word of their god(s) through word and deed: preaching, philosophical discussion, saying mass, giving sermons, settling disputes, blessing homes, baptizing children, performing weddings, tending the sick, performing healings, and generally bringing comfort and hope to the poor and downtrodden, to enslaved villages, and to those preyed upon by bandits, monsters, evil priests, witches, necromancers and other agents of darkness. In some societies priests gain great political and financial power and even become rulers; in others they are persecuted for their teachings.

Priests are not, as a rule, trained warriors or wizards - they are theologians, philosophers, healers, and liaisons between mortals and the gods, though most learn at least basic combat and a favored weapon (often staves and blunt weapons). Armor is typically light, since heavy metal armor both encumbers movement and interferes with the channelling of magic energy.

To play a priest, the character must select a god or pantheon of compatible alignment and maintain an obvious, practiced allegiance. A priest who disobeys, rebukes, or bad-mouths his deity risks severe punishment - in one storied campaign example, a priest of Light on a quest for Isis carelessly let a reclaimed relic slip away, then spoke to her goddess with arrogance ("What have you ever done for me?!"), and was instantly stripped from 7th level down to 4th, her experience frozen until the artifact was recovered. Priests who forsake their gods entirely lose all clerical ability, skill, and experience outright.

Each religion has its own laws and moral codes; the travelling priest, often removed from the rigidity of established churches, can be more flexible in interpreting them, especially in service of helping others. Only a handful of religions require celibacy; most allow priests to wed and raise families, and only about half restrict the priesthood by gender.

## GM Notes

The Priest of Light is built around a tiered escalation of divine favor: mundane Knowledge & Abilities (healing touch, exorcism, remove curse, turn dead, penance/sacrifice, spellcasting) available from level one or as noted, layered beneath Special Prayers (blessings, prayer of strength, communion, intervention) which are attempted routinely, and capped by rare, GM-adjudicated Miracles that should almost never be handed out reflexively - the book is explicit that miracles are not granted "at the drop of a hat," are refused even for worthy causes involving hundreds of lives if the deity doesn''t deem the cause important enough, and typically number one to a half-dozen across an entire campaign, or as rare as one every 2D6 years outside of deity-directed involvement.

When adjudicating a priest disobeying or offending their deity, treat it as a serious roleplaying consequence rather than a rules footnote - the example given (instant loss of three experience levels, frozen advancement, forced repentance and quest) is meant as a template for how visceral and narratively-driven such punishments should be, not a fixed penalty table.

Selling the Healing Touch is explicitly sanctioned by the book as a revenue mechanic for both PCs and church economies (5 gold to 1D6x100 gold per touch, 25-30 gold average) - useful for GMs wanting the priest to interact with local economies during downtime.

Armor encumbrance and the metal-interferes-with-magic mechanic apply identically to priests as to wizards, so GMs should apply the same 20% P.P.E. surcharge and negative-effect roll (01-20 reduce damage/effects, 21-40 reduce duration, 41-60 reduce range, 61-80 reduce both range and duration by 20%, 81-00 no additional problem) whenever a priest exceeding 50% metal armor coverage casts a spell.', 'published', 'import')
ON CONFLICT (class_id) DO UPDATE
   SET markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, created_by, length(markdown) AS markdown_bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'priest-of-light';
SELECT count(*) AS stub_gear_rows FROM gear
 WHERE slug IN ('traveling-robe-or-cloak-with-hood', 'ceremonial-robe', 'boots', 'belt', 'bedroll', 'purse-satchel', 'water-skin', 'holy-symbol', 'large-silver-cross', 'wooden-spike', 'small-mallet', 'rope', 'vial-of-holy-water', 'silver-chalice', 'small-mirror', 'tinder-box', 'staff', 'blunt-weapon', 'chain-weapon', 'spear', 'sword');
SELECT name, category FROM skills WHERE name = 'Lore: Religion';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-priest-of-light-class.sql');
