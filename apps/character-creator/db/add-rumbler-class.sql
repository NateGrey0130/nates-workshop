-- The Rumbler R.C.C., Rifts Dimension Book 1: Wormwood p.132-133.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-rumbler-class.sql
--
-- THE NAME IS RUMBLER, ON THE SECTION HEADING'S AUTHORITY. The Quick Find
-- Table indexes it as "Rathos (see Rumbler)", p.157 groups its XP ladder with
-- the morphworm and the holy terror, and its own heading on printed 132 reads
-- "Rathos the Rumbler R.C.C.". The race calls itself the Rathos; men call them
-- rumblers, because the earth rumbles when they walk.
--
-- ALL FIFTEEN OF ITS SPELLS ALREADY EXISTED, AND EIGHT OF THEM ONLY LOOKED
-- MISSING. The book splits them into "traditional spell magic" and "earth
-- elemental magic (see warlock O.C.C. in the Rifts Conversion Book)". A query
-- for the book's own spelling - identify minerals, rock to mud, wall of clay,
-- earth rumble - returns NOTHING for all eight, because the catalog files
-- elemental magic under an ELEMENT PREFIX: Earth: Identify Minerals, Earth:
-- Rock to Mud, Earth: Wall of Clay, Earth: Earth Rumble. That is exactly the
-- rule catalog.md states - query the catalog for a spelling rather than
-- assuming one - and taking the first answer would have minted eight duplicate
-- rows for spells the catalog already had.
--
-- "Thunder clap" is the BARE Thunderclap invocation rather than
-- Air: Thunderclap, because the book lists it under traditional magic, not
-- elemental. The catalog holds both, which is what makes the distinction
-- matter.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was written.
--
-- Follows the pattern #356 set for the R.C.C.s, which is worth stating because
-- three of the four rules were learned by a test failing rather than by reading
-- a reference:
--
--   * NO xp_table. regression.mjs pins that no R.C.C. carries one - experience
--     comes from what you do rather than from what you are, and the composition
--     fix in #222 depends on it. p.157 DOES print a ladder for every race in
--     this book, and it is what made them importable at all, so each one's
--     numbers are recorded in extraction_notes rather than dropped.
--   * NO related or secondary skills. They come from the O.C.C. Zero is
--     correct rather than missing, and all four of these grant zero.
--   * attacks are combat.attacks_base, which REPLACES the default of two - a
--     creature states a total where a class states a bonus.
--   * no sdc_base anywhere: all four are mega-damage creatures carrying
--     mdc_base, so none needs a CORE_SDC_BY_CLASS entry. A racial S.D.C. would
--     be a POOL BONUS and never sdc_base.
--
-- Money: no starting_money anywhere. Every class in this book prints
-- "Money: Not applicable" - Wormwood barters.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'rumbler', 'Rumbler', 'rifts', '---
id: rumbler
name: Rumbler
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.132-133
category: rcc
attribute_dice:
  IQ: "3d4+6"
  ME: "3d4+6"
  MA: "3d4"
  PS: "3d6+30"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "1d4"
  Spd: "2d4x10"
mdc_base: "1d6x100"
ppe_base: "1d6x100"
bonuses:
  combat: { attacks_base: 4, initiative: 2, strike: 2, parry: 2, dodge: 2, roll: 3, pull_punch: 3 }
  saves: { spell_magic: 1, toxins_poisons: 2, disease: 2, horror_factor: 4 }
  at_level:
    - { level: 6, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Dragonese", base: 65, per_level: 5, note: "65%" }
    - { name: "Language: Native Tongue", base: 65, per_level: 0, note: "The book prints this as American (65%). It also grants the elemental language at 65%, which the catalog has no row for." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 70, per_level: 5, note: "+20%" }
    - { name: "Tracking (people)", base: 30, per_level: 5, note: "+5%; the book prints tracking" }
    - { name: "W.P. Blunt" }
    - { name: "W.P. Chain" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P.s from any category." }
magic:
  type: "spell"
  spells: ["Climb", "Thunderclap", "Breathe Without Air", "Fool''s Gold", "Magic Net", "Repel Animals", "Spoil", "Earth: Identify Minerals", "Earth: Identify Plants", "Earth: Rock to Mud", "Earth: Crumble Stone", "Earth: Rot Wood", "Earth: Wither Plants", "Earth: Wall of Clay", "Earth: Earth Rumble"]
natural_abilities:
  - { name: "Nightvision", description: "400 feet (122 m), and it sees the invisible. DAYLIGHT vision is limited to about 1000 feet (305 m)." }
  - { name: "Impervious to Normal Fire", description: "Magic fire and plasma energy inflict half damage." }
  - { name: "Bio-Regeneration", description: "6D6 M.D.C. once per melee round, and severed limbs regrow within one week." }
  - { name: "Body Armor", description: "Standard rathos mega-damage armor has 100 M.D.C., but many rumblers wear only a loincloth." }
restrictions: ["No psionic powers", "A player character cannot have an alignment better than unprincipled - anarchist or aberrant are more likely"]
side_effects: "EYES SENSITIVE TO BRIGHT LIGHT: distracting and painful, they must squint, and ALL COMBAT BONUSES ARE REDUCED BY HALF. Elementals and warlock elemental magic, including magic fire, do FULL damage - the one thing the impervious-to-fire ability does not cover. Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 1D6x1000. Damage: bite 3D6 M.D.; claws add 1D6 M.D. on top of the supernatural P.S."
extraction_notes: "THE NAME IS RUMBLER, ON THE SECTION HEADING''S AUTHORITY. The book''s Quick Find Table indexes it as Rathos (see Rumbler), p.157 groups its XP ladder with the morphworm and the holy terror, and its own section heading on printed 132 reads Rathos the Rumbler R.C.C. The race calls itself the Rathos; men call them rumblers, because the earth rumbles when they walk. The heading is what the id and the name follow. || Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, shared with the morphworm and the holy terror, and it is what made the race importable at all, so the numbers are recorded here rather than lost: 0 / 2,901 / 4,801 / 9,601 / 19,201 / 29,201 / 49,001 / 79,001 / 119,001 / 169,001 / 230,001 / 300,001 / 380,001 / 470,001 / 600,001. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone. || ALL FIFTEEN SPELLS ALREADY EXISTED, AND EIGHT OF THEM ONLY LOOKED MISSING. The book splits them into traditional spell magic and earth elemental magic and points at the warlock O.C.C. in the Rifts Conversion Book. The catalog files elemental magic under an ELEMENT PREFIX - Earth: Rock to Mud, Earth: Wall of Clay, Earth: Earth Rumble - so a query for the book''s own spelling returned nothing for all eight and the right answer was a query for the prefix. That is catalog.md''s rule about querying the catalog for a spelling rather than assuming one, and it would have cost eight invented duplicate rows. Thunder clap is the bare Thunderclap invocation rather than Air: Thunderclap, because the book lists it under TRADITIONAL magic, not elemental. || The elemental LANGUAGE the book grants at 65% has no catalog row and is recorded on the Language note rather than invented. || Money: no starting_money; Special vehicle is None."
---

## Lore

The supernatural beings known as the rumblers are demons who love war. They are
broad and stout, thickly muscled and covered in ulcerated flesh - brown, grey or
green skin blotched with yellow or white pus and ooze. Their eyes are tiny and
white but for a pupil at the centre, the mouth is large and filled with crooked
pointed teeth, and the hairless head is crowned with small spines.

Their race is called the Rathos, but men know them as the rumblers, because "the
earth rumbles when they walk." That refers to their thunderous roar and
thundering footsteps, especially at a run - and to their chest-thumping and
weapon-pounding. Away from Wormwood they also have limited earth magic that can
make the ground rumble in fact.

Rathos rumblers are incredibly savage in combat, smashing opponents into pulp and
tearing limbs from their sockets. They feed on the remains of the dead and wear
skulls and bones as ornaments.

## GM Notes

**They are new to this corner of the Megaverse and eager about it.** Until the
Unholy found them, rumblers had never entered Earth''s or the Palladium World''s
galaxy. Now that they have found new worlds they are eager to spread their
terror. They love to fight and kill, usually target weaker beings like humans,
and are aggressive enough to attack other monsters, giants and dragons anyway.

If they ever reach Rifts Earth they will see the gargoyles as rivals and fight
them - which will be of little comfort to the humans and D-bees under gargoyle
oppression, because the rathos are crueller masters and will try to take the
lands and people the gargoyles hold.

A player character must be a renegade and a traitor, and can be no better than
unprincipled. Captured by other rathos, he is torn limb from limb and his skull
stuck on a pole; compassion or a desire for peace is extremely rare among them
and is read as weakness or insanity, and those who show it are treated as
dangerous mutants and destroyed.

NPC levels: 60% equal to a fourth level warrior, 30% sixth, and 10% are warlords
of ninth or tenth level. They live about 1000 years. Clubs, hammers, maces and
ball-and-chain are their favorite ancient weapons; they will absolutely fall in
love with rail guns, plasma weapons and particle beam rifles. 30% - warlords
especially - carry a magic weapon or two, and all covet rune weapons.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'rumbler');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'rumbler';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-rumbler-class.sql');
