-- The Summoner O.C.C., Palladium Fantasy main book, printed pp.135-137.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-summoner-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-summoner-class.sql
--
-- Read with scripts/read-columns.py. Apply add-arcane-catalog-rows.sql first or
-- alongside; it sorts ahead of this file so a rebuild does it for you.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- A PRACTITIONER OF MAGIC WITH NO `magic` BLOCK, ON PURPOSE. The summoner casts
-- no spells at all. The whole of the class's magic is CIRCLES - drawn with
-- specific components in a specific sequence, activated by power words and
-- P.P.E. - in three families:
--
--   Circles of Protection   Simple, Superior, and against Angels, Deevils,
--                           Demons, Elementals, Elemental Forces, Evil, Faerie
--                           Folk, Good, Ghosts and Spirits, Jinn, Magic (simple
--                           and superior), Old Ones, Undead, Witches and
--                           Were-beasts
--   Circles of Summoning    Angels, Animals, lesser and greater Demons and
--                           Deevils, Elementals, Elemental Forces, Faerie Folk
--   Circles of Power        the summoner's own working circles
--
-- There is no circle catalog and no schema for one. The options were to invent
-- rows in `spells` that are not spells, or to record the mechanics as prose and
-- say so. Prose wins, on the same reasoning fix-long-bowman.sql used for its
-- unreferenceable equipment: recorded rather than faked. A circle catalog is a
-- schema-level piece of work and would sit UNDER this class, not change it.
--
-- So the class carries no `magic` key rather than an empty one, and the sheet
-- shows no spell list for a summoner - which is correct, because the character
-- has none.
--
-- P.P.E. IS THE LARGEST OF THE THREE. 3D6x10 plus P.E. against the wizard's
-- 3D4x10+20 and the diabolist's 2D4x10. A summoner spends it on circles rather
-- than casting, and the book gives them the deepest reserve to do it with.
--
-- HISTORY IS A NEW CATALOG ROW, added by add-arcane-catalog-rows.sql at the
-- printed 30% +5%. It is deliberately not History: Pre-Rifts or History:
-- Post-Apocalypse, which are about a different world.
--
-- ONE HARMLESS CROSS-CATEGORY NOTE that class-check reports and which is
-- correct as written: the book's "Military: Interrogation Techniques and
-- Surveillance only" names Surveillance, which the catalog files under
-- Communications. The class lists Communications as well, so the pick is
-- admitted either way - which is what the book means.
--
-- The silver-coated dagger or short sword, 1D4 cloves of garlic and two iron
-- spikes are priced nowhere in the book. Recorded in restrictions rather than
-- stubbed; the wooden stakes and mallet the kit also lists do have rows and
-- stand in for the hammer.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'summoner', 'Summoner', 'palladium-fantasy', '---
id: summoner
name: Summoner
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 10, ME: 14 }
ppe_base: "3d6x10 plus the P.E. attribute number, +2d6 per level of experience starting at level one"
starting_money: "140"
bonuses:
  saves: { possession: 3, mind_control: 3 }
  at_level:
    - { level: 2, saves: { horror_factor: 2 } }
    - { level: 4, saves: { horror_factor: 2, spell_magic: 1, ritual_magic: 1 } }
    - { level: 7, saves: { horror_factor: 2 } }
    - { level: 8, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 10, saves: { horror_factor: 2 } }
    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  occ_skills:
    - { name: "Gemology", base: 40, per_level: 5, note: "+15%" }
    - { name: "History", base: 45, per_level: 5, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%)" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15, note: "One further lore of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Preserve Food", base: 40, per_level: 5, note: "+15%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", note: "+10%" }
      - { name: "Domestic", note: "+5%" }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Interrogation Techniques", "Surveillance"], note: "Interrogation Techniques +5%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two. Martial Arts and Assassin are not available to this O.C.C. at any price." }
      - "Rogue"
      - { name: "Science", note: "+10%" }
      - { name: "Technical", note: "+15%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance"], note: "Any except Large Axes and the Lance; the catalog has no Large Axes row." }
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
special_abilities:
  - { name: "Circle Magic", description: "The summoner works entirely in magic circles, not spells. Circles are drawn with specific components, in a specific sequence, and activated by power words and P.P.E. They fall into three families. Circles of Protection: Simple, Superior, and from Angels, Deevils, Demons, Elementals, Elemental Forces, Evil, Faerie Folk, Good, Ghosts and Spirits, Jinn, Magic (simple), Magic (superior), Old Ones, Undead, Witches and Were-beasts. Circles of Summoning: Angels, Animals, lesser and greater Demons and Deevils, Elementals, Elemental Forces, Faerie Folk and others. Circles of Power for the summoner''s own work. Circles are not in the spell catalog and are not modelled as spells; the character sheet has no circle list." }
  - { name: "Summon and Control", description: "A summoning circle calls a being, and a battle of wills decides who is in charge of it. With the GM''s permission a player of anarchist or evil alignment may attempt to summon and bind one lesser demon or deevil as a slave and servant." }
  - { name: "Magic Bonuses", description: "+1 to save vs magic at levels four, eight and twelve; +2 to save vs horror factor at levels two, four, seven and ten; +3 to save vs possession and against mind control of all kinds." }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "hooded robe or cloak", qty: 1, from: ["robe-hooded", "cape-long-hooded", "robe-heavy", "robe-light"] }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "large-sack-pf", qty: 3 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 3 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "ink-color-6-ounces", qty: 1 }
  - { item_id: "charcoal-dozen-sticks", qty: 1 }
  - { item_id: "chalk-dozen-sticks", qty: 1 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "The summoner starts with NO hand to hand skill. Basic costs one related skill and Expert two; Martial Arts and Assassin are not available to this O.C.C. at any price."
  - "Weapon proficiencies exclude Large Axes and the Lance. The starting dagger or short sword is silver coated; the catalog has no silver-coated Palladium row, so it is the ordinary daggers and knives row plus this note."
  - "The kit includes 1D4 cloves of garlic and two iron spikes, neither of which the book prices anywhere; the wooden stakes and mallet stand in for the spikes and hammer."
  - "Summoners are generally feared and avoided, but their services are sought by royalty, the military, merchants and the wealthy."
extraction_notes: "Circles are the whole of this class''s magic and there is no circle catalog, so the three families are recorded as a special ability rather than faked into the spell list; the class carries no magic block at all. History is added to the catalog by this batch at the printed 30% +5%. The two medium sacks join the large ones, because the equipment chapter prices only small, large and knap. Silver-coated weapons, garlic and iron spikes have no catalog rows and no printed prices, and are recorded in restrictions instead of stubbed."
---

# Summoner

## Lore

The summoner works no spells. His magic is the circle: drawn with the right
components in the right sequence, activated by power words and P.P.E., and
capable of protecting a place, calling a being out of somewhere else, or holding
one where it stands. Where a wizard studies invocations and a diabolist studies
symbols, a summoner studies what answers when you call it.

That makes him the most feared of the practitioners of magic and the most
avoided. A summoner who can call a demon is a summoner who might, and the
battle of wills that follows a summoning decides which of the two is in charge
of the other.

## Alignment

Any, but often unprincipled, anarchist or evil.

## GM Notes

If the GM allows it, a player of anarchist or evil alignment may try to summon
and bind one lesser demon or deevil as a slave and servant. That is a battle of
wills, not a purchase, and it is worth playing out.

Summoner services are sought by royalty, the military, merchants and the
wealthy, usually quietly.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'summoner');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'summoner';
-- Expect 0. History and Gemology both have to exist for the O.C.C. skill list.
SELECT 2 - count(*) AS missing_skills FROM skills
 WHERE name IN ('History', 'Gemology');
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'large-silver-cross', 'wooden-spike',
                'small-mallet', 'chalk-dozen-sticks');

INSERT INTO data_script_runs (filename) VALUES ('add-summoner-class.sql');
