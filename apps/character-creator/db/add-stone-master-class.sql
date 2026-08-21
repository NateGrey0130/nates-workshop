-- The Stone Master O.C.C., Rifts Book of Magic p.223-228.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-stone-master-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-stone-master-class.sql
--
-- Extracted with the app's own class importer from the Book of Magic PDF and
-- validated with scripts/class-check.mjs before this file was generated.
-- Non-ASCII characters are spliced in with char() - see PR #101's pre-flight.
--
-- The Book of Magic is a spell compendium, not a class book: across 300+ pages
-- it defines exactly ONE complete class, and this is it. (Page 200's Death Mage
-- is a variant of the Necromancer, not a class definition.)
--
-- THREE THINGS WORTH KNOWING, all of which read as done and were not:
--
--   1. The book prints two P.P.E. formulas - "the P.E. attribute times three"
--      for Atlanteans, "times two plus 30 points" for everyone else. Two real
--      formulas is what `variants` is for. But `rollPoolBase` parses "dice plus
--      an attribute" and has no room for a constant on top of both, so the +30
--      written into the formula string was silently dropped and a non-Atlantean
--      rolled 36 instead of 66. Flat terms are pool BONUSES, which are added to
--      whatever the formula rolls; they are on the variants for that reason.
--
--   2. A `bonuses` block on a plain special_ability is INERT. applyAbilities
--      folds in bonuses for abilities the player CHOOSES from a choose-group,
--      and the Marks of Heritage are not chosen. Both tattoo bonuses - 12 P.P.E.
--      and 20 S.D.C. - therefore ride the True Atlantean variant, which is also
--      the truthful place for them: "Magic Tattoos: None for non-Atlanteans."
--
--   3. The class prints no S.D.C. formula, so it needs a row in
--      CORE_SDC_BY_CLASS (1D6, practitioner of magic). A class that prints none
--      and is missing from that table fails the smoke test by design, rather
--      than defaulting and quietly under-rolling.
--
-- Six of the printed equipment phrases already exist in the catalog under the
-- catalog's own name and were mapped rather than re-created - tinted goggles,
-- mini tool kit, small mallet, hammer (tool), and rope (sold per 40 ft, so the
-- book's 100 feet is qty 3). "A cross of some kind" is a choice in the book and
-- is modelled as one. Minting a second row per printed phrase is how this repo
-- acquired its merge-*-duplicate.sql scripts.


-- Stub rows for what the catalog lacks. The "STUB" marker is load-bearing: it
-- is how the gear importer later recognises a row as still needing stats.
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('weapons-matching-w-p-skills', 'Weapons Matching W.P. Skills', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-knife', 'Pocket Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sculpting-tools-case', 'Carrying Case of Sculpting Tools', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('large-chisel', 'Large Chisel', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('putty-knife', 'Putty Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('gem-cutters-glass-and-tools', 'Gem Cutter''s Glass and Tools', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('huntsman-armor', 'Huntsman Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('explorer-armor', 'Explorer Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Book of Magic');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'stone-master', 'Stone Master', 'rifts', '---
id: stone-master
name: Stone Master
system: rifts
source_book: Rifts Book of Magic p.223-228
category: occ
attribute_requirements: { IQ: 12, ME: 14, PE: 16 }
starting_money: "6d6x1000"
ppe_base: "P.E. x3 + 2d6 per level"
variants:
  - id: "true-atlantean"
    name: "True Atlantean"
    ppe_base: "P.E. x3 + 2d6 per level"
    # The two Marks of Heritage tattoos: six P.P.E. and ten S.D.C. each.
    bonuses: { pools: { ppe: 12, sdc: 20 } }
  - id: "non-atlantean"
    name: "Non-Atlantean"
    ppe_base: "P.E. x2 + 2d6 per level"
    # "The P.E. attribute times two plus 30 points."
    bonuses: { pools: { ppe: 30 } }
bonuses:
  saves: { spell_magic: 2, ritual_magic: 2, horror_factor: 6 }
skills:
  occ_skills:
    - { name: "Literacy: Dragonese/Elf", base: 0, per_level: 0 }
    - { name: "Language: American", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Communications"], bonus: 15, note: "Speaks three additional languages of choice (+15%)." }
    - { name: "Basic Math", base: 40, per_level: 5 }
    - { name: "Advanced Math", base: 20, per_level: 5 }
    - { name: "Astronomy", base: 15, per_level: 5 }
    - { name: "Lore: Demons & Monsters", base: 10, per_level: 5 }
    - { name: "Land Navigation", base: 10, per_level: 5 }
    - { name: "Swimming", base: 5, per_level: 5 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. of Choice (2)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related skill, or Martial Arts (or Assassin if evil) for the cost of two." }
  occ_related_skills:
    count: 10
    categories: ["Communications", "Domestic", "Electrical", "Espionage", "Mechanical", "Medical", "Military", "Physical", "Pilot", "Pilot Related", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
    note: "Communications Any (+5%). Domestic Any (+10%). Electrical Any. Espionage: Wilderness Survival only (+10%). Mechanical Any (+5%). Medical: First Aid, Paramedic or Holistic only. Military Any (+5%). Physical: Any except Acrobatics, Gymnastics, and Wrestling. Pilot Any (+5%). Pilot Related Any (+5%). Rogue: None. Science Any (+10%). Technical Any (+10%). Weapon Proficiencies: Any. Wilderness Any (+10%)."
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 2 }
  - { item_id: "pocket-knife", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "a cross of some kind", qty: 1, from: ["wooden-cross", "large-wood-cross", "small-silver-cross", "large-silver-cross"] }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "rope", qty: 3, note: "100 feet (30.5 m); the catalog sells rope per 40 ft." }
  - { item_id: "mini-tool-kit", qty: 1 }
  - { item_id: "sculpting-tools-case", qty: 1 }
  - { item_id: "large-chisel", qty: "1d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "hammer-tool", qty: 1 }
  - { item_id: "hand-pick", qty: 1 }
  - { item_id: "shovel", qty: 1 }
  - { item_id: "putty-knife", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "gem-cutters-glass-and-tools", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { choose: 1, label: "light Mega-Damage body armor (usually Huntsman or Explorer style), covered by robe or traveling cloak", qty: 1, from: ["huntsman-armor", "explorer-armor"] }
special_abilities:
  - name: "Magic Tattoos (Marks of Heritage)"
    description: "All True Atlanteans bear a pair of magic tattoos: a heart impaled by a wooden stake (no blood) on the right wrist for protection from vampires, and a flaming sword on the left wrist to create a magic M.D.C. weapon."
  - name: "Increased S.D.C. from Tattoos"
    description: "Typically two tattoos add a total of 20 additional S.D.C. points (True Atlanteans only). Applied by the True Atlantean variant."
  - name: "Increased P.P.E. from Tattoos"
    description: "The two magic tattoos add six P.P.E. points each, 12 total, to the mage''s permanent base amount (True Atlanteans only). Applied by the True Atlantean variant."
  - name: "Increased P.P.E. Recovery"
    description: "True Atlanteans replenish P.P.E. at 10 points per hour of rest or sleep (twice normal human rate), or 15 P.P.E. per hour if meditating. This rate doubles when resting inside a pyramid."
  - name: "Cannot Be Physically Transformed"
    description: "Immune to metamorphosis potions and spells, the transformation ritual, vampire transformation, petrification, turn to mist, growth/reduction spells/potions/pyramids, curses, crystals, wishes, or any other transformation magic."
  - name: "Continued Growth"
    description: "After reaching full maturity at about age 25, True Atlanteans continue to grow about an inch every century, giving older characters an average height of 6''6\" to 7'' (1.95 to 2.1 m)."
  - name: "Sense Vampires"
    description: "Senses the presence of vampires and vampire intelligences within a 1000 foot (305 m) radius, but cannot pinpoint the exact source. Recognizes vampires by appearance: 10% per level of experience."
  - name: "Operate Dimensional Pyramids"
    description: "Can operate every facet of the pyramids, from healing to weather control and dimensional teleportation. Base skill 40%+5% per level of experience. Also knows exactly how Stone Magic works and how to build pyramids."
  - name: "Sense Ley Lines and Nexuses"
    description: "Same as the Line Walker (Rifts, page 83)."
  - name: "Sense Rifts"
    description: "Same as the Line Walker."
  - name: "Ley Line Phasing"
    description: "Same as the Line Walker."
  - name: "Mold Stone"
    description: "Can mold solid granite or any type of stone/rock with bare hands as if it were clay, without transforming it to clay; the substance remains rock hard to the touch. Enables sculpting weapons like stone clubs, fabulous statues without seams or tool marks, creating bricks and blocks, smoothing chips and cracks, adding rock to structures, and remolding statues. Base Sculpting Skill 25%+5% per level of experience (add 15% with an art skill). Cannot create stone from thin air, turn other materials into stone, or cause stone to crumble/rupture. P.P.E. Cost: 20 per hour (double for concrete/plaster; asphalt and metal not affected)."
  - name: "Push Stone"
    description: "Can dig through rock, pushing, scooping and removing stone to create indentations, holes, tunnels, peepholes, doorways, etc., without debris or evidence of construction. Working quickly, can push/dig through 500 lbs (225 kg) of rock per minute. Can pull/push rock up from a wall or floor to form a blocking mound or appendage (appendages broken with 4D6 S.D.C. of force; floor mounds require removing the door). Making a floor mound takes one full melee; an appendage takes two melee actions. P.P.E. Cost: One per minute (double for concrete/plaster; cannot dig asphalt or metal)."
  - name: "Carry Incredible Weights of Stone"
    description: "Can pick up and carry stone, rock, shale, and gems equal to 1000 times P.S. attribute without exhaustion; other materials use normal weight/encumbrance rules. P.P.E. Cost: One per minute."
  - name: "Move Stone Mentally"
    description: "Can pull rocks from the ground or cause them to roll along the ground toward the caster or to a point within 1000 feet (305 m), forming designs, piles, or walls. Earth-bound movement at Speed 11 (~7.5 mph/12 km); up to 500 lbs (225 kg) per level of experience per minute; range/area 1000 feet (305 m). Rolling rock attacks are always -4 to strike due to slow, visible approach, but can trigger landslides or cover a floor with rolling pebbles to hinder movement (victims lose two melee actions, -2 strike/parry/dodge, speed halved). P.P.E. Cost: Two per minute."
  - name: "Levitation and Telekinesis of Stone"
    description: "Can mentally levitate and move rock through the air, including platforms bearing riders (passenger weight counts toward total). Up to 500 lbs (225 kg) per level of experience per minute; range of movement up/down/sideways limited to 30 feet (9 m) per level. Rocks move at Speed 5 (~3.5 mph/5.6 km). Rock drop attacks are always -3 to strike; damage 1D6 S.D.C. (under 15 lbs), 2D6+2 S.D.C. (16-50 lbs), 4D6+6 S.D.C. (51-100 lbs), plus 1D4x10+10 S.D.C. per additional 100 lbs; a 200 lb rock inflicts 1 M.D. point, +1 M.D. per additional 350 lbs. P.P.E. Cost: Four per minute."
  - name: "Sense Water"
    description: "Senses location of water above and below ground, including lakes, ponds, underground streams/rivers, pockets, sewers and pipelines. Accuracy 35%+5% per level. Range one mile (1.6 km) per level; depth 200 feet (61 m) per level. P.P.E. Cost: Four per ten minutes."
  - name: "Sense Supernatural Beings Under the Earth"
    description: "Senses supernatural beings (Ghouls, Nymphs, Elementals, etc.) within the earth, not above ground. Accuracy 30%+5% per level. Range half a mile (0.8 km) per level; depth 200 feet (61 m) per level. P.P.E. Cost: Four per ten minutes."
  - name: "Locate Secret Passages"
    description: "Senses secret compartments built into stone structures or underground, including pyramids; not applicable to wood or other materials. Base skill 20%+5% per level of experience. Range 5 feet (1.5 m) per level of experience."
  - name: "Gem Shaping"
    description: "Can mentally shape a gemstone as if professionally cut and polished, adding facets and accents; requires holding the gem and several minutes of concentration. Can cut rough stones into jewelry quality gems or disguise stolen gems, permanently altering appearance; sells at 50-75% of market value. Base skill 8% per level of experience, plus 1% per P.P.E. point spent up to 10%. A failed roll ruins the stone."
  - name: "Drawing Power from Stones"
    description: "Can draw magic and psionic powers identical to the named spell/power from certain precious and semiprecious stones, particularly crystals. Stones must be flawless and cut/polished to a faceted/crystal appearance; only one power type per gem at a time. Power can be drawn from small gems three times and large gems six times before the gem crumbles to dust; even after first use, the gem becomes flawed/discolored (half value). Range is touch; power stops instantly if the gem is dropped/lost but usage is still expended. Can activate one gem power per melee, combining up to three different powers/gems. Duration: one minute/four melees per level of experience. Attribute bonuses from super abilities do not apply. P.P.E. Cost to Activate: 5 for worthless stones (salt, sulfur), 10 for semiprecious gems/crystals (quartz, agate, amethyst), 20 for precious gemstones (zircon, aquamarine, ruby, emerald). Remaining focused on gem use imposes -2 on initiative and dodging. Only the Stone Master can use magic from the stones; it cannot be transferred."
level_progression:
  - level: 1
    grants: ["+2 to save vs magic of all kinds (in addition to P.E. bonuses)", "+6 to save vs Horror Factor", "+5% to sense ley lines and ley line nexuses"]
restrictions:
  - "Cannot communicate with Elementals nor manipulate Elemental forces (unlike Warlocks)."
  - "Cannot create stone out of thin air, nor turn clay or any other object into stone, nor cause stone to crumble or rupture."
  - "Cybernetics: None; if required later, character will strive for bio-systems, as mechanical limbs/implants weaken their magic."
  - "Magic Tattoos: None beyond Marks of Heritage for non-Atlanteans; Stone Masters avoid additional magic tattoos, fearing distraction from their focus."
extraction_notes: |
  - This entry covers Stone Magic broadly, including gem powers and pyramid
    technology, which are integral to the class''s abilities but do not map
    cleanly onto discrete schema fields; they are recorded as prose under
    special_abilities and in Lore/GM Notes.
  - The "Index of the Powers Available from Stones" and "The Powers of the
    Stones" (pages 225-226) list which named spells/psionic powers come from
    which specific gem types, with associated average credit costs. This is
    a large reference table more suited to GM Notes than to the `magic` or
    `psionics` schema fields, since the Stone Master doesn''t "know" these as
    innate spells but draws them from consumable gems.
  - Pyramid Technology (pages 226-227) describes major setting-level magic
    (slowed aging, healing, stasis sleep, P.P.E. focus/control, ley line storm
    suppression, power amplification, P.P.E. storage) tied to stone pyramids
    rather than to the character directly; recorded in GM Notes as it governs
    location-based effects rather than class stats.
  - Standard equipment listed "two weapons related to W.P. skills" without
    naming specific catalog items. An empty `from` list is not a choice - it
    offers nothing - so this is a named stub, weapons-matching-w-p-skills,
    which says what is owed and can be resolved against the catalog later.
  - Six of the printed equipment phrases already exist in the catalog under
    the catalog''s own name and were mapped rather than re-created: tinted
    goggles, mini tool kit, small mallet (the slug eight other classes cite),
    hammer (tool), and rope - sold per 40 ft, so the book''s 100 feet is qty 3.
    "A cross of some kind" is a choice in the book and is modelled as one.
  - Money is 6d6x1000 in precious gems, per the book; recorded verbatim as
    starting_money even though it''s not straight cash.
  - Insanity: explicitly states Atlanteans and non-Atlanteans alike start
    with no insanities, so no side_effects/insanity field was added per the
    omission rule.
---

## Lore

Stone Masters are practitioners of magic with a special gift: the talent to mend, shape, sculpt, transport, and commune with stone, rock, and gems. It is as if the rock were a living substance psionically linked to the Stone Master. They are said to be so attuned to the earth that they can mentally manipulate stone, causing rocks to move as if by levitation or telekinesis. In addition, they can draw magic from gemstones and detect underground water and supernatural beings (including Earth Elementals).

It was the Stone Masters who created the Atlantean pyramids with incredible precision and without machines, building structurally solid tunnels through mountains and erecting 300-foot pyramids in months. Unlike Warlocks, Stone Masters are linked to the Earth itself rather than to an Elemental entity in another dimension; this link also ties them to ley lines, letting them control ley lines through the creation of stone pyramids.

Stone Masters see the Earth as a vast natural rock garden, and themselves as privileged sculptors permitted to work within it, reshaping its contours and adding to its sculptures. They see beauty in a boulder or the curve of a hill, valuing craftsmanship and love invested in a work over the image itself ' || char(8212) || ' even a sculpture of a Splugorth is as beautiful to them as one of a woman. Buildings are judged by how well they blend into or complement their natural surroundings. In old Atlantis, cities grew up around giant pyramids five times larger than those of Egypt, usually sited on ley line nexuses, serving as the heart of the city and places of healing, science, and power, towering up to a thousand feet high.

Although the origin of this magic is ancient Atlantis, modern characters of any race can become a Stone Master; however, it remains a rediscovered and little-known form of magic outside Atlantis, True Atlanteans, the Chiang-Ku, and the Splugorth.

Alignment: Any, typically good.

## GM Notes

**Gem Powers Index:** Bio-Manipulation (Star Sapphire), Cloud of Smoke (Sulfur Crystals), Cure Illness (Rose Quartz), Detect Concealment (Amber), Detect Psionics (Amethyst), Empathy (Garnet), Empathic Transmission (Most Sapphires), Energy Disruption (Ruby Quartz), Escape (Clear Zircon), Eyes of the Wolf (Alexandrite), Fire Ball (Red Ruby), Fire Bolt (Red Zircon), Float in Air (Clear Zircon), Fool''s Gold (Yellow/Brown Zircon), Fly as the Eagle (Diamond), Globe of Daylight (Clear Quartz), Heal Wounds (Agate), Impervious to Fire (Smoky Quartz), Impervious to Energy (Red Zircon), Invisibility Superior (Emerald), Invulnerability (Diamond), Mask of Deceit (Yellow/Brown Zircon), Mind Block (Black Tourmaline), Negate Poison (Topaz), P.P.E. Battery (Diamond & Emerald), Protection From Faeries (Salt Crystals), Shadow Meld (Black Sapphire), Swim as a Fish (Aquamarine), Wisps of Confusion (Blue Ruby).

Diamonds and emeralds (at least one carat) can also serve as P.P.E. batteries, holding up to 25 P.P.E. Charging requires ~10 minutes of meditation at a ley line nexus or stone pyramid, channeling energy into the gem; a battery gem cannot also be drawn on for magic powers, and can be recharged up to six times before crumbling.

Average gem/crystal costs and rarity notes are extensively tabulated (pages 225-226): e.g., Agate 3D4x10 credits, Diamond 1D6x1000 (small)/15,000 per carat (large, min. 1 carat for Invulnerability), Emerald similar, Ruby 1D6x1000/18-19,000 per carat, Sapphire 1D6-2D4x1000/16-20,000 per carat, Zircon varieties 300-3500 credits per carat, etc. Precious gems (rubies, sapphires, emeralds, diamonds, aquamarine) are geographically restricted in Rifts Earth (Burma/Thailand/Sri Lanka, Colombia/Egypt/South Africa, Brazil/Colombia/Siberia/Urals, South Africa/Brazil/Venezuela respectively), typically 40% cheaper at their source regions; synthetic diamonds/zircon do not work for magic.

**Pyramid Technology:** Stone pyramids (built of stone only ' || char(8212) || ' other materials confer no powers) grant substantial location-based magic: (1) Slow Aging ' || char(8212) || ' sleeping overnight removes stress/fatigue; True Atlanteans gain +1 year of lifespan per 365 days sleeping in a nexus pyramid or 730 days on a ley line pyramid. (2) Healing ' || char(8212) || ' 24 hours inside fully removes stress/fatigue; Stone Masters heal 3x normal rate with P.P.E. restored at 2x; True Atlanteans/humans/Ogres/Dragons heal 2x with 20 P.P.E./half hour; other races heal 1.5x. (3) Stasis Sleep ' || char(8212) || ' voluntary suspended animation lasting days to decades; ages 1 week per 10 years, no food/water needed, fully healed; woken if attacked; builder Stone Masters get a personal secret chamber (-20% to locate). (4) Focus and Control of P.P.E. ' || char(8212) || ' pyramids act as mystic dams; normal ley line/nexus bonuses become unavailable except on/inside the controlling pyramid; must be destroyed to free the ley line (Small pyramid 100-200 ft: 2D4x1000 M.D.C.; Medium 300-500 ft: 1D4x10,000; Large 600-1000 ft: 2D6x10,000; Huge 1100+ ft: 2D4x100,000). (5) Harmonious Effect on Ley Line Storms & Rifts ' || char(8212) || ' a nexus pyramid reduces Ley Line Storms by 70% and cuts random Rift chances to 1% (ley line) or 4% (nexus) annually; Stone Master can redirect a storm and has 5%/level chance to stop it within 1D4 minutes, or close a random Rift within 2D4 melees at a cost of 500 P.P.E. (6) Increases Power of Stone Magic ' || char(8212) || ' at a nexus pyramid, quadruples duration/range/area/weight/damage/power of Stone Magic and triples gem/crystal power; on a ley line (non-nexus) pyramid, triples Stone Magic and doubles gem powers. Other magic practitioners get no such bonus unless actually on/in the pyramid. (7) P.P.E. Storage ' || char(8212) || ' nexus pyramids hold 5D6x100 P.P.E. per six-hour interval (500-3000 points); ley line (non-nexus) pyramids hold 2D4x100; depleted reserves need six hours to renew, with none available until the full period passes.

One minor pyramid may be placed every five miles (8 km) along the same ley line (additional ones have no mystic power); only one pyramid may occupy a given ley line nexus ' || char(8212) || ' the most powerful and coveted sites, around which major Splugorthian and Atlantean cities are built.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'stone-master');


-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'stone-master';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('weapons-matching-w-p-skills', 'pocket-knife', 'sculpting-tools-case', 'large-chisel', 'putty-knife', 'gem-cutters-glass-and-tools', 'huntsman-armor', 'explorer-armor');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-stone-master-class.sql');
