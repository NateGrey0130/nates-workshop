-- The Warlock O.C.C., Rifts Book of Magic p.66-70 (adapted from the
-- Palladium Fantasy RPG). The fourth of the five practitioners the Godling's
-- Magic Powers ability names - only the Necromancer is still absent.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-warlock-class.sql
--
-- Depends on add-elemental-spells.sql: the Warlock's whole spell list is the
-- four elemental spheres, and its GM Notes tell the player to filter the
-- picker by sphere name. Apply the spells first.
--
-- Hand-transcribed from the PDF's text layer, re-ordered by block coordinate
-- because the page is two-column, and cross-read against the 300dpi render.
-- Validated through parseClassMarkdown (both variants) before generation.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('elemental-symbol', 'Elemental Symbol', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('flint-and-charcoal', 'Flint And Charcoal', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hooded-robe', 'Hooded Robe', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('triax-pump-weapon', 'Triax Pump Weapon', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'warlock', 'Warlock', 'rifts', '---
id: warlock
name: Warlock
system: rifts
source_book: Rifts Book of Magic p.66-70
category: occ
attribute_requirements: { IQ: 6, ME: 10 }
ppe_base: "2d4x10+20, +2d6 per additional level of experience"
starting_money: "2d6x1000"
magic:
  type: "elemental"
  spells_starting: 3
  spell_levels_allowed: [1]
bonuses:
  saves: { horror_factor: 2, spell_magic: 1, ritual_magic: 1, possession: 1 }
variants:
  - id: one-force
    name: "Warlock (One Elemental Force)"
    attribute_requirements: { IQ: 6, ME: 10 }
    ppe_base: "2d4x10+20, +2d6 per additional level of experience"
  - id: two-forces
    name: "Warlock (Two Elemental Forces)"
    attribute_requirements: { IQ: 12, ME: 14 }
    ppe_base: "2d4x10+40, +2d6 per additional level of experience"
skills:
  occ_skills:
    - { choose: 2, categories: ["Communications"], bonus: 10, note: "Speaks two additional Languages (+10%)." }
    - { name: "Literacy: Other", base: 40, per_level: 5, note: "Literate in a Language of choice (+10%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "Lore: Demon & Monster (+10%)." }
    - { name: "Lore ' || char(8212) || ' Faerie", base: 30, per_level: 5, note: "Lore: Faerie Folk (+5%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 55, per_level: 5, note: "Pilot Hover Craft (+5%)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient of choice (select one)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern of choice (select one)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of two O.C.C. Related Skills, or Martial Arts for the cost of three." }
  occ_related_skills:
    count: 8
    categories:
      - "Communications"
      - { name: "Cowboy", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Domestic"
      - "Electrical"
      - { name: "Espionage", only: ["Tracking (people)", "Wilderness Survival"] }
      - "Horsemanship"
      - "Mechanical"
      - "Medical"
      - { name: "Physical", except: ["Boxing", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots and Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Tanks and APCs"] }
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "TWO of the eight must be from Wilderness or Domestic - a composition constraint the count field cannot express. Domestic +10%, Espionage: Tracking and Wilderness Survival only (+5%), Medical: Any (+10% on Holistic Medicine), Pilot: Any (+5%) except robots and military vehicles, Science +10%, Technical +10%, Wilderness +10%. Military: none."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "hooded-robe", qty: 2 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "flint-and-charcoal", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "elemental-symbol", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "sidearm", qty: 1, from: ["automatic-pistol", "triax-pump-weapon"] }
natural_abilities:
  - name: "Elemental Spell Magic"
    description: "The Warlock does not LEARN magic - he draws it intuitively from a supernatural Elemental Intelligence. At first level a Warlock of ONE Elemental Force selects three spells from his sphere''s first level list; at every new level of experience he selects three more, and may choose from any level up to his own experience level (so a third level Warlock picks from levels 1-3). A Warlock of TWO Elemental Forces gains spells the same way but takes only ONE spell from EACH of his two spheres per level. Elemental Magic goes up to eighth level only. Under no condition can a Warlock learn any spell other than those his Elemental deity provides - no invocations, no rituals, no scrolls."
  - name: "Speak Elemental"
    description: "All Elementals communicate in a strange language combining telepathy and the spoken word. Every Warlock speaks and understands it at 98%; to everyone else it is incomprehensible. Elementals have no written language."
  - name: "Sense Elementals"
    description: "Senses the presence of an Elemental within a 120 foot (36.6 m) radius. Base Skill: 25% +5% per level. Deliberately searching when Elemental Forces appear to be at work gives +20% and doubles the range to 240 feet (73.2 m). A Warlock also intuitively recognises a fellow Warlock and instantly knows which Elemental Force or Forces he is allied to (but not level or alignment), and has a 01-75% chance of seeing an invisible Elemental - Air Elementals, Spirits of Light and the Demonic Jinn included."
  - name: "P.P.E. and its limits"
    description: "A disciple of ONE Elemental Force has 2D4x10+20 P.P.E. in addition to the P.E. attribute; of TWO Forces, 2D4x10+40. Add 2D6 P.P.E. per additional level. Unlike most practitioners of magic the Warlock CANNOT draw P.P.E. from other living creatures, but can draw it from Elemental beings of his own life sign, from ley lines and nexus points, and from magic storage cells such as certain talismans."
  - name: "Power Words and Symbols"
    description: "The Warlock knows the power words for the four Elemental Powers - Cherubot-kyn, Ariel-Rapere-kyn, Seraph-mytyn, and Tharsis-mycn and Yin - and the mystic symbols of the four Elementals plus the six stone symbols for Elemental Forces."
restrictions:
  - "Choose ONE or TWO Elemental Forces at creation (Air, Earth, Fire or Water) - the variant records which, and the choice is permanent. One Force needs I.Q. 6 and M.E. 10; two need I.Q. 12 and M.E. 14. A one-Force Warlock has greater mastery (three spells a level from one sphere); a two-Force Warlock has greater diversity (one from each sphere a level)."
  - "O.C.C. bonuses beyond the modeled saves: +6 (rather than +2) to save vs Horror Factor when the source is an Elemental being, and +1 to Spell Strength at levels 3, 6, 10 and 14."
  - "Cybernetics: starts with none and will avoid them."
extraction_notes: |
  - Rifts Book of Magic p.66-70, adapted from the Palladium Fantasy RPG.
  - The one-Force / two-Force split is carried as VARIANTS because the only
    differences the schema can hold are attribute_requirements and ppe_base,
    both of which VARIANT_OVERRIDES allows. The spells-per-level difference
    (three from one sphere versus one from each of two) is NOT a variant key,
    so magic.spells_starting is the one-Force figure and the two-Force rule
    is stated in the Elemental Spell Magic ability.
  - The ELEMENT choice itself is per-character and has no schema shape: a
    class is static, and the wizard''s spell picker filters by level, not by
    sphere. Because the catalog names elemental spells with their sphere
    ("Fire: Fire Bolt"), typing the sphere into the picker''s filter box
    narrows it correctly - that is the intended workflow and it is stated
    here rather than left to be discovered.
  - spell_levels_allowed is [1] because a first level Warlock may only take
    first level spells; the level cap rising with experience is the class''s
    own rule and is described in the ability.
  - magic.type is "elemental", a new value alongside innate/spell - nothing
    branches on it today, but it is the honest label.
  - Equipment: two weapons matching the two W.P. selections are prose, as is
    the mount (a horse or other live animal, or a small fast hover vehicle).
    Money: 2D6x1000 credits + 3D4x1000 in Black Market items.
---

## Lore

A Warlock is a man or woman who draws magic powers from a supernatural, Elemental Intelligence. Like the Mystic and the Witch, there is no true knowledge of the mystic arts; instead the Warlock, through his link with the Supernatural Intelligence, intuitively knows certain Elemental spells. A Warlock is **not** a male witch, but an order of practitioners devoted to the Elemental Forces and Elemental-based magic: Air, Earth, Fire and Water.

One might assume Warlocks are closely attuned to nature, and in some ways they are, but not in the way one might think. They are not spiritualists like the Druids of England or Native American Shamans who try to live in harmony with their environment; the Warlock functions on a more primeval level, concerned with power, change and anarchy, for that is their vision of nature. Their world view is a picture of seething, unrestrained force, freedom and change.

As such, a Warlock binds himself to no man nor god - he is a free spirit who wanders the universe to observe and instigate change. They may become heads of state or even Emperor of a kingdom, or restrict their efforts to a life as a wandering philosopher or mercenary sorcerer, or all of the above during one lifetime. Life, adventure, power and freedom are all important. They appreciate the forces of nature but use magic to bend them to their will. Personal freedom is revered above all else.

## GM Notes

**Picking spells by sphere.** The catalog names every elemental spell with its sphere - `Air: Cloud of Steam`, `Fire: Fire Bolt`, `Earth: Wall of Stone`, `Water: Tidal Wave` - because the same spell name recurs across spheres at different levels and P.P.E. costs, and several also exist as Invocations. In the wizard''s spell picker, type the sphere name into the filter box to narrow to that Warlock''s own element.

**One Force or two.** A Fire Warlock at third level has nine Fire spells; a Fire-and-Air Warlock at third level has three Fire and three Air (six total). Both are Elemental Magic, but the single-Force Warlock has greater control and mastery while the two-Force Warlock has greater diversity and less depth.

**Summoning Elementals.** Warlocks make it a point never to kill an Elemental they have summoned. When one is left to guard something, the Warlock will usually include the condition that the moment the Elemental senses its own destruction it is free to return home.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'warlock');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'warlock';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('elemental-symbol', 'flint-and-charcoal', 'hooded-robe', 'triax-pump-weapon');
