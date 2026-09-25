-- Every class that prints no S.D.C. formula says whether it is a man of arms,
-- in its own frontmatter: `men_of_arms: true` rolls the core rule's 3D6 S.D.C.,
-- `false` rolls 1D6 (Rifts Ultimate Edition p.18). Until 2026-09-25 that
-- grouping lived in CORE_SDC_BY_CLASS in apps/character-creator/js/compose.js,
-- a map every class import appended to, so two book sessions in parallel
-- conflicted there. This file moves the map's 207 entries into the classes'
-- markdown, one line after `id:`, and carries every comment the map carried:
-- the book, the printed pages and the reason for each class, in the map's order.
-- Where a comment below says "an entry here", it meant the map; the line
-- this file writes is that entry now.
--
-- A class imported after this writes the line in its own add-*-class.sql and
-- never touches compose.js. It sorts last so that every earlier script that
-- rewrites a class's markdown has already run; a later one that replaces a
-- whole markdown must keep the line, and regression fails a published class
-- that prints no S.D.C. or M.D.C. and does not state it.
--
-- Guarded, so it is safe to re-run: a class that already states men_of_arms is
-- left alone. Two retired classes (elemental-shaman, warlock) are updated too,
-- so a restore brings the line back with them.

-- Rifts World Book 18: Mystic Russia, printed 83-91 - the Necromancer.
-- Not a man of arms, so 1D6 rather than 3D6. It prints no S.D.C. formula and
-- is not a Mega-Damage being either, unlike this book's two Witch O.C.C.s,
-- which carry an mdc_base and so need no entry here. Its +10 S.D.C. is a
-- pool BONUS on top of this, not a replacement for it.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: necromancer-russian' || char(10), char(10) || 'id: necromancer-russian' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'necromancer-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 107-109, the same book - the Born Mystic, which the book heads a
-- P.C.C. rather than an O.C.C. A psychic is not a man of arms, so 1D6. Like
-- the Necromancer it states neither an S.D.C. formula nor an mdc_base, which
-- is what makes an entry here necessary rather than optional.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: born-mystic' || char(10), char(10) || 'id: born-mystic' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'born-mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 109-111, the same book - the Russian Fire Sorcerer. A mage, so 1D6,
-- and it states neither an S.D.C. formula nor an mdc_base like the two above.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: russian-fire-sorcerer' || char(10), char(10) || 'id: russian-fire-sorcerer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'russian-fire-sorcerer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 127-131, the same book - the Old Believer, a shaman-sage-sorcerer
-- and the source of Nature Magic. Not a man of arms, so 1D6. Like the three
-- above it states neither an S.D.C. formula nor an mdc_base.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: old-believer' || char(10), char(10) || 'id: old-believer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'old-believer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 155-157, the same book - the Gypsy Enforcer, and the SECOND of the
-- two men-of-arms in Mystic Russia after the Slayer, so 3D6. A bodyguard with
-- Boxing, Hand to Hand: Expert, four weapon proficiencies and a three-skill
-- Military floor. Its +3D6 S.D.C. is a pool bonus on top of this.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-enforcer' || char(10), char(10) || 'id: gypsy-enforcer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-enforcer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 152-154, the same book - the Layer of Laws, a Gypsy Elder. Not a
-- man of arms, so 1D6 - and the book reduces its P.S., P.P., P.B. and Spd by
-- 20% for old age besides.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: layer-of-laws' || char(10), char(10) || 'id: layer-of-laws' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'layer-of-laws' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 150-153, the same book - The Gifted One (Russian), a psychic healer
-- whose tier is rolled. Not a man of arms, so 1D6. Suffixed because
-- `gypsy-gifted` belongs to Triax.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gifted-one-russian' || char(10), char(10) || 'id: gifted-one-russian' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gifted-one-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 148-152, the same book - the Gypsy Fortune Teller, or Gypsy Medium.
-- A master psionic who also casts; not a man of arms, so 1D6. No suffix: this
-- one is new to the catalog rather than a Triax reprint.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-fortune-teller' || char(10), char(10) || 'id: gypsy-fortune-teller' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-fortune-teller' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 143-144, the same book - the Traditional Gypsy Thief (Russian). A
-- thief is not a man of arms, so 1D6. The id carries a suffix because
-- `gypsy-thief` belongs to Triax and the NGR; the two printings differ.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-thief-russian' || char(10), char(10) || 'id: gypsy-thief-russian' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-thief-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 146-149, the same book - the Traditional Gypsy Seer (Russian), a
-- master psionic who also casts. Not a man of arms, so 1D6. Suffixed because
-- `gypsy-seer` belongs to Triax.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-seer-russian' || char(10), char(10) || 'id: gypsy-seer-russian' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-seer-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 145-147, the same book - the Traditional Gypsy Wizard-Thief
-- (Russian). A burglar who casts; not a man of arms, so 1D6. Suffixed for
-- the same reason as the Thief above: `gypsy-wizard-thief` belongs to Triax.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-wizard-thief-russian' || char(10), char(10) || 'id: gypsy-wizard-thief-russian' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-wizard-thief-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 136-140, the same book - the Slayer, and the ONE class in Mystic
-- Russia that takes 3D6. It is the book's only men-of-arms: a demon hunter
-- with Boxing, Hand to Hand: Expert and six weapon proficiencies who casts
-- sixteen spells on the side. Every other class here is a caster or a
-- psychic and takes 1D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: slayer-russian' || char(10), char(10) || 'id: slayer-russian' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'slayer-russian' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 14: New West, printed 83-92 - the O.C.C.s and NPC
-- villains section. None of the four prints an S.D.C. formula of its own.
-- The Bandit and the Highwayman each print an S.D.C. BONUS instead
-- (+2D6+10 and +2D6+6), which is a pool bonus on top of this, not a
-- replacement for it.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: bandit' || char(10), char(10) || 'id: bandit' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'bandit' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: highwayman' || char(10), char(10) || 'id: highwayman' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'highwayman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: bounty-hunter' || char(10), char(10) || 'id: bounty-hunter' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'bounty-hunter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gunfighter' || char(10), char(10) || 'id: gunfighter' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'gunfighter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 92-102, the same section. The Psi-Slinger is the book's own
-- P.C.C. and sits in the psychic group, but it is armed and fights as a
-- gunslinger does, so it takes the men-of-arms 3D6 the way psi-stalker
-- does below. All four print an S.D.C. BONUS and no formula.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gunslinger' || char(10), char(10) || 'id: gunslinger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'gunslinger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: justice-ranger' || char(10), char(10) || 'id: justice-ranger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'justice-ranger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: psi-slinger' || char(10), char(10) || 'id: psi-slinger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'psi-slinger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: saddle-tramp' || char(10), char(10) || 'id: saddle-tramp' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'saddle-tramp' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 102-113, the same section. Four more that print an S.D.C. bonus
-- and no formula.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: sheriff-lawman' || char(10), char(10) || 'id: sheriff-lawman' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'sheriff-lawman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: sheriffs-deputy' || char(10), char(10) || 'id: sheriffs-deputy' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'sheriffs-deputy' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: wired-gunslinger' || char(10), char(10) || 'id: wired-gunslinger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'wired-gunslinger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: cowboy' || char(10), char(10) || 'id: cowboy' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'cowboy' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 15: Spirit West, printed 36-47 - the four Traditional
-- Warrior O.C.C.s. None prints an S.D.C. formula. The Tribal Warrior's +5D6
-- and the Mystic Warrior's +30 are pool bonuses on top of this, and the
-- Totem and Spirit Warriors convert the total to M.D.C., which is prose.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: tribal-warrior' || char(10), char(10) || 'id: tribal-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'tribal-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mystic-warrior' || char(10), char(10) || 'id: mystic-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'mystic-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: totem-warrior' || char(10), char(10) || 'id: totem-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'totem-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: spirit-warrior' || char(10), char(10) || 'id: spirit-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'spirit-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 15: Spirit West, printed 48-62 - Shaman O.C.C.s, which
-- are practitioners of magic, so 1D6. The Plant Shaman prints its own
-- S.D.C. (P.E. x2) and needs no entry; the Mask and Healing Shamans' +10
-- and +20 are pool bonuses on top of this.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: animal-shaman' || char(10), char(10) || 'id: animal-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'animal-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mask-shaman' || char(10), char(10) || 'id: mask-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'mask-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: healing-shaman' || char(10), char(10) || 'id: healing-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'healing-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Printed 62-69, the rest of the Shaman O.C.C.s, also 1D6. The Fetish
-- Shaman fights as a War Shaman but the book files it among the Shamans;
-- its +5D6 is a pool bonus on top. The Wendigo R.C.C. states M.D.C. and
-- needs no entry.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: paradox-shaman' || char(10), char(10) || 'id: paradox-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'paradox-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-shaman' || char(10), char(10) || 'id: elemental-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- BOOK-INGEST-AUDIT F63 splits the Elemental Shaman by element, as RETRO-AUDIT
-- R3 split the Warlock; each keeps the practitioner-of-magic 1D6. The retired
-- one-class entry above stays, as the generic Warlock's did, because its add
-- script does.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-shaman-air' || char(10), char(10) || 'id: elemental-shaman-air' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-shaman-air' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-shaman-earth' || char(10), char(10) || 'id: elemental-shaman-earth' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-shaman-earth' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-shaman-fire' || char(10), char(10) || 'id: elemental-shaman-fire' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-shaman-fire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-shaman-water' || char(10), char(10) || 'id: elemental-shaman-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-shaman-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fetish-shaman' || char(10), char(10) || 'id: fetish-shaman' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'fetish-shaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Men of arms - 3D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: glitter-boy' || char(10), char(10) || 'id: glitter-boy' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'glitter-boy' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: headhunter-techno-warrior' || char(10), char(10) || 'id: headhunter-techno-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: merc-soldier' || char(10), char(10) || 'id: merc-soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'merc-soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: robot-pilot' || char(10), char(10) || 'id: robot-pilot' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'robot-pilot' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Psychics by the book's grouping, but hunters by trade and armed as such.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: psi-stalker' || char(10), char(10) || 'id: psi-stalker' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'psi-stalker' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: wild-psi-stalker' || char(10), char(10) || 'id: wild-psi-stalker' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'wild-psi-stalker' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts Ultimate Edition, printed 45-85 - the men of arms section.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: crazy' || char(10), char(10) || 'id: crazy' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'crazy' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Coalition Military O.C.C.s, printed 231-237. Soldiers by definition.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: coalition-grunt' || char(10), char(10) || 'id: coalition-grunt' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'coalition-grunt' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: coalition-samas-pilot' || char(10), char(10) || 'id: coalition-samas-pilot' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: coalition-technical-officer' || char(10), char(10) || 'id: coalition-technical-officer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'coalition-technical-officer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Palladium Fantasy main book, the Men of Arms section, printed 78-95 (the
-- contents page puts the heading at 78 and Optional O.C.C.s at 96). Not one
-- of these pages prints an S.D.C. formula, so the core rule applies to every
-- one of them - and the book's own section heading is the whole of what this
-- table records, which is why they are listed together rather than argued for
-- one at a time.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: knight' || char(10), char(10) || 'id: knight' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'knight' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: soldier' || char(10), char(10) || 'id: soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: palladin' || char(10), char(10) || 'id: palladin' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'palladin' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ranger' || char(10), char(10) || 'id: ranger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ranger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mercenary-fighter' || char(10), char(10) || 'id: mercenary-fighter' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'mercenary-fighter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The SQUIRE is the exception to that sentence, and it is worth being honest
-- about rather than leaving it sitting in a list it does not belong to. It is
-- printed at 98, inside Optional O.C.C.s, not in the Men of Arms section -
-- this entry used to claim the range ran to 104, which no part of the book
-- supports. It stays at 3D6 anyway, because printed 18 keys the roll on "a
-- background as men of arms" rather than on where the entry was typeset, and
-- the squire's background is knightly military training: it is "familiar with
-- the rudimentaries of combat, horsemanship and weapons", its page carries
-- the same Squires & Armor rules the knight's does, and the book calls them
-- "lesser knights".
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: squire' || char(10), char(10) || 'id: squire' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'squire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Thief and the Assassin are here on the book's own say-so, not on a
-- reading of what they do: "Thieves (and assassins) are the rogues and
-- cutthroats of the men of arms O.C.C.s" (printed 91). Worth the sentence,
-- because neither looks like a man of arms from its skill list.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: thief' || char(10), char(10) || 'id: thief' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'thief' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: assassin' || char(10), char(10) || 'id: assassin' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'assassin' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Pantheons of the Megaverse, printed 168-169, on the book's first sentence:
-- "The berserkers are FIGHTERS who have devoted themselves to Odin." It also
-- carries P.S. and P.E. minimums, which is a man-of-arms signature. The
-- counter-argument is real and worth recording rather than hiding - its
-- skills are borrowed from the vagabond and the wilderness scout, both 1D6 -
-- but a borrowed skill list is not what this table keys on.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: berserker' || char(10), char(10) || 'id: berserker' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'berserker' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Triax and the NGR, the Military O.C.C.s of printed 156-174. The book's own
-- roster on printed 156 files these under Military O.C.C.s and its divisions
-- - Army, Armored, Intelligence - and no entry prints an S.D.C. formula, so
-- the core rule applies. The MEDICAL OFFICER is the one worth a sentence: it
-- is a doctor rather than a fighter, and it is here because printed 156 puts
-- it in the NGR Army beside the infantry, and printed 159 says every military
-- doctor is trained in self defence and the energy rifle whether they use
-- them or not. Its entry grants Hand to Hand: Basic and two W.P.s, which no
-- 1D6 class in this table does.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-infantry-soldier' || char(10), char(10) || 'id: ngr-infantry-soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-infantry-soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-communications-officer' || char(10), char(10) || 'id: ngr-communications-officer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-communications-officer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-medical-officer' || char(10), char(10) || 'id: ngr-medical-officer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-medical-officer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Armored Division, printed 161-170. Same reading as the Army above.
-- Three of these five have a body the catalog does not store - the Cyborg
-- Soldier's chassis, the Robot Soldier's robot, and the Power Armor
-- Commando's T-31 - so their real durability is M.D.C. that lives in a
-- BOOK-INGEST-AUDIT.md F3 vessel, and the S.D.C. here is what the character
-- has outside it. For the ROBOT SOLDIER that is close to moot: it has no
-- human body left at all. It is listed at 3D6 rather than left out because
-- the table's own rule is that a class printing no S.D.C. formula must
-- appear here or fail the smoke test, and 3D6 is what its division gets.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-cyborg-soldier' || char(10), char(10) || 'id: ngr-cyborg-soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-cyborg-soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-field-mechanic' || char(10), char(10) || 'id: ngr-field-mechanic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-field-mechanic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-power-armor-commando' || char(10), char(10) || 'id: ngr-power-armor-commando' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-power-armor-commando' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-robot-combat-pilot' || char(10), char(10) || 'id: ngr-robot-combat-pilot' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-robot-combat-pilot' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-robot-soldier' || char(10), char(10) || 'id: ngr-robot-soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-robot-soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Intelligence Division and the police, printed 171-174. Same reading
-- again: printed 156 files all three under Military O.C.C.s, and none prints
-- an S.D.C. formula. The POLICE OFFICER is worth the one sentence: it is a
-- law enforcement officer rather than a front-line soldier, and it is 3D6
-- because its own book puts it in the Intelligence Division, gives it the
-- military rank structure, and shares its experience ladder on printed 224
-- with the Infantry Soldier - the table heads the two together as
-- "Combat Soldier & Police/Enforcement".
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-intelligence-officer' || char(10), char(10) || 'id: ngr-intelligence-officer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-intelligence-officer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-intelligence-commando' || char(10), char(10) || 'id: ngr-intelligence-commando' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-intelligence-commando' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ngr-police' || char(10), char(10) || 'id: ngr-police' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'ngr-police' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Practitioners of magic, psychics and scholars - 1D6.
-- Rifts World Book 14: New West, printed 115-123. The Preacher is clergy,
-- and the Gambler and the Saloon Bum are filed under Adventurers of the New
-- West rather than among the gunfighters, so all three take 1D6 off the
-- book's own section headings. The Mining 'Borg from the same batch needs no
-- entry at all: it states an `mdc_base`.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: preacher' || char(10), char(10) || 'id: preacher' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'preacher' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: professional-gambler' || char(10), char(10) || 'id: professional-gambler' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'professional-gambler' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: saloon-bum' || char(10), char(10) || 'id: saloon-bum' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'saloon-bum' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: saloon-girl' || char(10), char(10) || 'id: saloon-girl' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'saloon-girl' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: burster' || char(10), char(10) || 'id: burster' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'burster' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-fusionist-earth-air' || char(10), char(10) || 'id: elemental-fusionist-earth-air' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-fusionist-earth-air' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elemental-fusionist-fire-water' || char(10), char(10) || 'id: elemental-fusionist-fire-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elemental-fusionist-fire-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ley-line-rifter' || char(10), char(10) || 'id: ley-line-rifter' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'ley-line-rifter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ley-line-walker' || char(10), char(10) || 'id: ley-line-walker' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'ley-line-walker' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 18: Mystic Russia printed 126-127, a DECLARED COPY of
-- 'ley-line-walker' whose only difference is its spell selection. It inherits
-- the parent's silence about S.D.C. along with everything else, so it takes
-- the parent's figure - a practitioner of magic, never a man of arms. The
-- entry is needed rather than optional: the class states neither an S.D.C.
-- formula nor an mdc_base, exactly as its parent does.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: russian-ley-line-walker' || char(10), char(10) || 'id: russian-ley-line-walker' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'russian-ley-line-walker' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mind-melter' || char(10), char(10) || 'id: mind-melter' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'mind-melter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mystic' || char(10), char(10) || 'id: mystic' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: priest-of-light' || char(10), char(10) || 'id: priest-of-light' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'priest-of-light' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Pantheons of the Megaverse, printed 12-15. Its four pages state no S.D.C.
-- and no hit point formula at all, so the core rule reaches it - and 1D6
-- rather than 3D6 because a priest is not a man of arms, which is the same
-- reading the Priest of Light directly above already gets.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: rifts-priest' || char(10), char(10) || 'id: rifts-priest' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'rifts-priest' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Pantheons of the Megaverse, printed 170. A RACE, and the entry states
-- neither an S.D.C. nor a hit point formula of its own - it is a bonus
-- package laid over whatever the character already was. 1D6 because a race
-- always takes 1D6 here: the entry only fires for a race played with no
-- occupation at all, and a race is never a man of arms.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warrior-of-valhalla' || char(10), char(10) || 'id: warrior-of-valhalla' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warrior-of-valhalla' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Juicer Uprising, printed 50-53. Also a RACE, and the only class in that
-- book with neither an sdc_base nor an mdc_base - because it has neither.
-- A Murder-Wraith's hit points are the S.D.C. and hit points of the Juicer
-- it used to be, added together and then frozen forever, and its M.D.C. is
-- whatever armour it happens to be wearing. Neither is a formula this app
-- can compute, so both live in prose and the core rule reaches the entry.
-- 1D6 because a race always takes 1D6 here.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: murder-wraith' || char(10), char(10) || 'id: murder-wraith' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'murder-wraith' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Juicer Uprising, printed 58-61. The two classes in that book's
-- Juicer-Related section that are NOT JUICERS - the book says so in as
-- many words - so neither inherits the Juicer's 1D4x100 S.D.C., and
-- neither entry prints an S.D.C. or hit point formula of its own. 1D6
-- because neither is a man of arms: the book files them together as
-- people who hang around Juicers rather than as fighters, which is the
-- same reading their `optional` occ_group records. The Wannabe trains
-- hard and boxes, and that is still not what this table keys on.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gambler' || char(10), char(10) || 'id: gambler' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gambler' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: juicer-wannabe' || char(10), char(10) || 'id: juicer-wannabe' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'juicer-wannabe' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: shifter' || char(10), char(10) || 'id: shifter' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'shifter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: stone-master' || char(10), char(10) || 'id: stone-master' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'stone-master' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: techno-wizard' || char(10), char(10) || 'id: techno-wizard' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'techno-wizard' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The generic `warlock` is retired (retire-warlock-generic.sql) and replaced
-- by ten per-Force classes, RETRO-AUDIT R3. Its entry STAYS: a retired class
-- still composes for a character who already holds one, and dropping the row
-- would give them a NULL S.D.C. All ten inherit its grouping, because a
-- Warlock is a practitioner of magic whichever Element it draws on.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock' || char(10), char(10) || 'id: warlock' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-air' || char(10), char(10) || 'id: warlock-air' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-air' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-earth' || char(10), char(10) || 'id: warlock-earth' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-earth' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-fire' || char(10), char(10) || 'id: warlock-fire' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-fire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-water' || char(10), char(10) || 'id: warlock-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-air-earth' || char(10), char(10) || 'id: warlock-air-earth' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-air-earth' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-air-fire' || char(10), char(10) || 'id: warlock-air-fire' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-air-fire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-air-water' || char(10), char(10) || 'id: warlock-air-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-air-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-earth-fire' || char(10), char(10) || 'id: warlock-earth-fire' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-earth-fire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-earth-water' || char(10), char(10) || 'id: warlock-earth-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-earth-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warlock-fire-water' || char(10), char(10) || 'id: warlock-fire-water' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warlock-fire-water' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts Ultimate Edition, printed 86-99 - the Adventurers & Scholars
-- section, which is where the book itself files all eight of these.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: body-fixer' || char(10), char(10) || 'id: body-fixer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'body-fixer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: city-rat' || char(10), char(10) || 'id: city-rat' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'city-rat' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: operator' || char(10), char(10) || 'id: operator' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'operator' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: cyber-doc' || char(10), char(10) || 'id: cyber-doc' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'cyber-doc' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: rogue-scholar' || char(10), char(10) || 'id: rogue-scholar' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'rogue-scholar' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: rogue-scientist' || char(10), char(10) || 'id: rogue-scientist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'rogue-scientist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: vagabond' || char(10), char(10) || 'id: vagabond' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'vagabond' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: wilderness-scout' || char(10), char(10) || 'id: wilderness-scout' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'wilderness-scout' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Triax and the NGR, the Gypsy O.C.C.s of printed 179-185. The first
-- entries from this book on THIS side of the table: the eleven above are
-- the Military O.C.C.s and every one of them is 3D6. These four are not
-- military at all - printed 156's roster does not list them, and the book
-- gives them their own section, which opens by saying a gypsy will not
-- consider the soldier or the knight because they are too disciplined.
-- None of the four prints an S.D.C. formula, so the core rule reaches them.
--
-- The THIEF is the one worth a sentence, because the Palladium Fantasy
-- thief four screens up is 3D6 and this one is not. That entry is 3D6 on
-- its own book's say-so - "thieves and assassins are the rogues and
-- cutthroats of the men of arms O.C.C.s", printed 91 - and Triax says no
-- such thing about the gypsy thief. Without that sentence the reading falls
-- back to where the book files the class, which is beside the fortune-teller
-- and the healer rather than beside the infantry. It is the same answer the
-- City Rat already gets on the Rifts side.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-thief' || char(10), char(10) || 'id: gypsy-thief' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-thief' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-wizard-thief' || char(10), char(10) || 'id: gypsy-wizard-thief' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-wizard-thief' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-seer' || char(10), char(10) || 'id: gypsy-seer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-seer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gypsy-gifted' || char(10), char(10) || 'id: gypsy-gifted' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gypsy-gifted' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Palladium Fantasy main book, the Optional O.C.C.s, printed 96-98. The
-- first Palladium classes on this side of the table: the previous nine are
-- all men of arms, and these three are the book's own answer to a player who
-- does not want to be one. None of their pages prints an S.D.C. formula
-- either, so the same core rule reaches the other way.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: merchant' || char(10), char(10) || 'id: merchant' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'merchant' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: noble' || char(10), char(10) || 'id: noble' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'noble' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: scholar' || char(10), char(10) || 'id: scholar' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'scholar' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The fifth Optional O.C.C., printed 99, and the last one in that section.
-- It asks for no attributes, grants no bonuses and prints no S.D.C., so the
-- core rule reaches it the same way.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: vagabond-peasant' || char(10), char(10) || 'id: vagabond-peasant' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'vagabond-peasant' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Palladium Fantasy main book, the practitioners of magic, printed 104-137.
-- The book's other half of the same core rule, and the plainest reading of
-- it: these three are what "practitioners of magic" names.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: wizard' || char(10), char(10) || 'id: wizard' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'wizard' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: summoner' || char(10), char(10) || 'id: summoner' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'summoner' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: diabolist' || char(10), char(10) || 'id: diabolist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'diabolist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Palladium Fantasy main book, the clergy, printed 63-78. The Warrior Monk
-- is the awkward one and still belongs here: it fights better than most men
-- of arms, but the book files it with the priests and prints no S.D.C.
-- formula, so the core rule reads 1D6. Its own +20 S.D.C. bonus is a pool
-- bonus in the class and lands on top of this.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: priest-of-darkness' || char(10), char(10) || 'id: priest-of-darkness' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'priest-of-darkness' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: warrior-monk' || char(10), char(10) || 'id: warrior-monk' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'warrior-monk' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: druid' || char(10), char(10) || 'id: druid' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'druid' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Witch is filed with the practitioners of magic and prints no S.D.C.
-- formula. Its Gift of Power and Gift of Union both add large amounts on top
-- - 200 and 3D4x10 - but those are gifts, not the class's own roll.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: witch' || char(10), char(10) || 'id: witch' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'witch' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Palladium Fantasy main book, the psychic P.C.C.s, printed 156-162. None
-- prints an S.D.C. formula and none is a man of arms, so the core rule reads
-- 1D6 for all four - which is the whole of what this table decides.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: psychic-sensitive' || char(10), char(10) || 'id: psychic-sensitive' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'psychic-sensitive' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: psi-healer' || char(10), char(10) || 'id: psi-healer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'psi-healer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: psi-mystic' || char(10), char(10) || 'id: psi-mystic' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'psi-mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: mind-mage' || char(10), char(10) || 'id: mind-mage' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'mind-mage' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The fourteen Palladium Fantasy player races, printed 288-312.
--
-- A RACE IS NEVER A MAN OF ARMS. What makes a character one is the job, and
-- withCorePools looks the OCCUPATION up first, so every one of these entries
-- fires only for a race played with no occupation at all - which the books do
-- not do and the app allows. There, printed 18's own third bucket applies:
-- "practitioners of magic, scholars and all others roll 1D6". A race with no
-- occupation is "all others".
--
-- Ten of the fourteen also state a racial S.D.C. of their own, and NONE of
-- them states it here. Those are pool BONUSES on the class - "10 plus those
-- gained from O.C.C.s and physical skills" - because printed 18 says all
-- S.D.C. bonuses are cumulative. Written as sdc_base they would replace the
-- occupation's roll rather than add to it, so a Troll Knight would have 40
-- S.D.C. instead of 40 + 3D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: human' || char(10), char(10) || 'id: human' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'human' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: elf' || char(10), char(10) || 'id: elf' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'elf' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: dwarf' || char(10), char(10) || 'id: dwarf' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'dwarf' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gnome' || char(10), char(10) || 'id: gnome' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gnome' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: troglodyte' || char(10), char(10) || 'id: troglodyte' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'troglodyte' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: kobold' || char(10), char(10) || 'id: kobold' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'kobold' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: goblin' || char(10), char(10) || 'id: goblin' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'goblin' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hob-goblin' || char(10), char(10) || 'id: hob-goblin' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hob-goblin' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: orc' || char(10), char(10) || 'id: orc' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'orc' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ogre' || char(10), char(10) || 'id: ogre' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'ogre' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: troll' || char(10), char(10) || 'id: troll' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'troll' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: changeling' || char(10), char(10) || 'id: changeling' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'changeling' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: wolfen' || char(10), char(10) || 'id: wolfen' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'wolfen' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: coyle' || char(10), char(10) || 'id: coyle' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'coyle' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts Dimension Book 2: Phase World, the CCW Characters & O.C.C.s
-- section, printed 56-61. NONE of the four prints an S.D.C. or a hit point
-- formula - the book states attributes, skills, equipment and money and
-- nothing else - so the core rule reaches every one of them.
--
-- Phase World has no Men of Arms heading to read this off, which every
-- entry above this one had. The split is by trade instead, and it is the
-- same split the classes' own occ_group records: the trooper and the fleet
-- officer are soldiers, and the inspector and the scientist are not. The
-- scientist is the one worth arguing about - the book calls them scientist
-- soldiers and Warrant Officers with basic military training - and it goes
-- to 1D6 on the same reading the catalog's rogue-scientist already gets:
-- the trade is science, the class grants no combat bonus block, and its
-- Military related skills carry the same +5% as its Medical ones.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: caf-trooper' || char(10), char(10) || 'id: caf-trooper' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'caf-trooper' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: caf-fleet-officer' || char(10), char(10) || 'id: caf-fleet-officer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'caf-fleet-officer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: tvia-inspector' || char(10), char(10) || 'id: tvia-inspector' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'tvia-inspector' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: caf-scientist' || char(10), char(10) || 'id: caf-scientist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'caf-scientist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts Dimension Book 2: Phase World, the noro, printed 61-65. None of the
-- three prints an S.D.C. formula. The RACE states "S.D.C./Hit Points:
-- Standard, P.E. plus 1D6 per level" - the hit points are a formula and the
-- S.D.C. is the word Standard - so the core rule reaches it, at 1D6, which
-- is what a race always takes here.
--
-- The MYSTIC WARRIOR is the one worth arguing about and it goes to 3D6 on
-- the psi-stalker precedent already in this table: psychic by the book's own
-- grouping - printed 62 lists it beside the mind melter and the noro psychic
-- - and a fighter by trade and armed as such, with energy pistol, energy
-- rifle, power armor training and Hand to Hand Expert granted outright. Its
-- Bio-feedback ability gives 3D6x10 S.D.C. for 1 I.S.P., which is BOUGHT and
-- temporary and is not a base; it is a special ability on the class.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: noro' || char(10), char(10) || 'id: noro' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'noro' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: noro-psychic' || char(10), char(10) || 'id: noro-psychic' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'noro-psychic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: noro-mystic-warrior' || char(10), char(10) || 'id: noro-mystic-warrior' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'noro-mystic-warrior' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts Dimension Book 2: Phase World, the Space Wolfen R.C.C., printed
-- 65-66. The ONLY one of the CCW's four remaining entries that needs a line
-- here: the Wolfen Quatoria, the Catyr and the Seljuk are all mega-damage
-- and carry their own mdc_base.
--
-- Its 30 S.D.C. is a POOL BONUS - "30 S.D.C. plus those gained from O.C.C.s
-- and physical skills" - so the race still states no S.D.C. FORMULA and the
-- core rule reaches it, with the 30 landing on top. 1D6 because a race
-- always takes 1D6 here, which is what the catalog's Palladium `wolfen`
-- already gets for the same reason and the same shape.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: space-wolfen' || char(10), char(10) || 'id: space-wolfen' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'space-wolfen' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Transgalactic Empire's three O.C.C.s, printed 82-84. None states an
-- S.D.C. or a hit point formula, and none is a mega-damage being, so all
-- three need an entry here or the smoke test fails them.
--
-- The book files them under a NATION rather than under one of the five O.C.C.
-- groups, so the 3D6-or-1D6 call is read off what the entry describes. The
-- Legionnaire is the Empire's line infantry and the Freedom Fighter is the
-- rebellion's - both soldiers, both 3D6. The Security Agent is secret police:
-- its skill list is cryptography, surveillance, disguise, forgery and prowl,
-- it is `occ_group: optional` on the TVIA Inspector's precedent, and it takes
-- 1D6 like the inspector it mirrors.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: imperial-legionnaire' || char(10), char(10) || 'id: imperial-legionnaire' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'imperial-legionnaire' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: freedom-fighter' || char(10), char(10) || 'id: freedom-fighter' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'freedom-fighter' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: imperial-security-agent' || char(10), char(10) || 'id: imperial-security-agent' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'imperial-security-agent' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The five spacefaring trades of printed 38-43. None states an S.D.C. or a
-- hit point formula and none is a mega-damage being, so all five need an
-- entry here. The book files them under "Other races & O.C.C.s of note"
-- rather than under one of the five O.C.C. groups, so the call is read off
-- what each entry actually is.
--
-- Two are fighters: the Galactic Tracer is the spaceways bounty hunter and
-- the book points at Rifts Mercenaries, where the Bounty Hunter is a man of
-- arms; the Space Pirate has attribute minimums, Hand to Hand: Expert and
-- combat bonuses. The other three are trades - a cargo pilot, a smuggler and
-- a pioneer, all Hand to Hand: Basic, none with a combat bonus.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: galactic-tracer' || char(10), char(10) || 'id: galactic-tracer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'galactic-tracer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: space-pirate' || char(10), char(10) || 'id: space-pirate' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'space-pirate' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: spacer' || char(10), char(10) || 'id: spacer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'spacer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: runner' || char(10), char(10) || 'id: runner' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'runner' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: colonist' || char(10), char(10) || 'id: colonist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'colonist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Pleasurer R.C.C., printed 88-89, and the only class in the Star Hives
-- batch that needs an entry: the Vacuum Wasp and the Termite Engineer are
-- mega-damage beings and carry their own mdc_base.
--
-- Its S.D.C. is a POOL BONUS - "1D6x10 + 40 S.D.C. plus skill and O.C.C.
-- bonuses" - so the race states no S.D.C. FORMULA and the core rule reaches
-- it, with the 1D6x10+40 landing on top. Same shape as the Space Wolfen's 30
-- above. 1D6 because a race always takes 1D6 here.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: pleasurer' || char(10), char(10) || 'id: pleasurer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'pleasurer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Prometheans, printed 25-31. Three of the four need an entry: the First
-- Stage Promethean states "1D6x100 S.D.C. and P.E.x5 hit points" outright, so
-- the core rule never reaches the race. None of its three O.C.C.s states an
-- S.D.C. or a hit point formula and none is a mega-damage being.
--
-- Phase World still has no Men of Arms heading, so the call is read off what
-- each entry is, the same way the CCW's four and the Empire's three were.
-- The PHASE ADEPT is the promethean mystic warrior in all but name - the book
-- says so in those words - with Hand to Hand: Martial Arts, W.P. sword,
-- energy pistol and energy rifle granted outright, an extra attack per melee,
-- +2 on initiative and +3D6x10 S.D.C. from its own training. The PHASE MYSTIC
-- is its pupil and takes "similar training and initiation rituals", with the
-- same three W.P.s, Hand to Hand: Expert granted outright and +2 on
-- initiative; smaller numbers, the same trade. Both go to 3D6 on the
-- noro-mystic-warrior precedent above, which is the same shape: psychic by
-- the book's own grouping, a fighter by trade and armed as such.
--
-- The TIME MASTER is not. It is a spell caster with Hand to Hand: Basic, one
-- W.P., no combat bonus block at all, and its own Military related category
-- printed as None - 1D6, like every other caster in this table.
--
-- Note where these actually fire. withCorePools looks the OCCUPATION up
-- first and stops as soon as the class states an sdc_base, so a phase adept
-- played on its own race - the only way the book allows it - takes the
-- promethean's 1D6x100 and never reaches these lines. They are what a phase
-- mystic on a human, or either promethean O.C.C. played with no race at all,
-- falls through to.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: promethean-phase-adept' || char(10), char(10) || 'id: promethean-phase-adept' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'promethean-phase-adept' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: phase-mystic' || char(10), char(10) || 'id: phase-mystic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'phase-mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: promethean-time-master' || char(10), char(10) || 'id: promethean-time-master' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'promethean-time-master' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 7: Underseas, printed 48-49. The SEA INQUISITOR is a
-- demon hunter and it is tempting to read that as a man of arms; its own
-- page argues otherwise. Underseas does not sort its O.C.C.s into
-- Palladium's men-of-arms and scholar sections at all, so there is no
-- heading to read this off - and the class's whole combat training is Hand
-- to Hand: Basic and two W.P.s of choice. Its power is anti-supernatural,
-- not martial. 1D6, with the +2D6x10 the class grants landing on top of it
-- as a pool bonus.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: sea-inquisitor' || char(10), char(10) || 'id: sea-inquisitor' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'sea-inquisitor' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Underseas' three spell casters, printed 56-63. All three state neither
-- an S.D.C. nor an M.D.C. formula. 1D6 for each, and none of them is a
-- near miss: the Whale Singer has Hand to Hand: Basic and one W.P., the
-- Ocean Wizard has Hand to Hand: Basic and no W.P. granted at all, and the
-- SEA DRUID IS GRANTED NO HAND TO HAND SKILL WHATSOEVER - its O.C.C. skill
-- list runs from Basic Math to one W.P. of choice and stops. Underseas
-- does not sort its O.C.C.s into men-of-arms sections, so there is no
-- heading to read these off; the skill lists are the argument.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: whale-singer' || char(10), char(10) || 'id: whale-singer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'whale-singer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: ocean-wizard' || char(10), char(10) || 'id: ocean-wizard' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'ocean-wizard' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: sea-druid' || char(10), char(10) || 'id: sea-druid' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'sea-druid' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Tritonia, printed 96-98. The SEA WOLF is this book's clearest man of
-- arms and the only Underseas class to reach 3D6: hand to hand expert,
-- three W.P.s granted outright, Military at +10%, and a job description
-- that is commando operations and counter-terrorism. The TRITONIAN
-- SCIENTIST is the opposite end of the same city - Hand to Hand: Basic,
-- one W.P., and Military barred from its related skills entirely. The
-- basic military training every Tritonian citizen gets in their teens is
-- background rather than a grant, and does not move it.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: tritonian-sea-wolf' || char(10), char(10) || 'id: tritonian-sea-wolf' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'tritonian-sea-wolf' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: tritonian-scientist' || char(10), char(10) || 'id: tritonian-scientist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'tritonian-scientist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The New Navy and the human salvage trade, printed 111-134. The NAVY
-- SEAMAN and the MARINE are both men of arms - three W.P.s granted
-- outright, Military open, and printed 111 is explicit that there are no
-- rear echelons on Rifts Earth, so even a shipboard technician fights.
-- The SALVAGE EXPERT is not: Hand to Hand: Basic, two W.P.s, and a skill
-- list of tools, torches and survey work. The SEA TITAN needs no entry -
-- it states its own mdc_base.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: navy-seaman' || char(10), char(10) || 'id: navy-seaman' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'navy-seaman' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: marine' || char(10), char(10) || 'id: marine' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'marine' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: salvage-expert' || char(10), char(10) || 'id: salvage-expert' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'salvage-expert' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 22: Free Quebec, printed 32-42. This book does not sort
-- its O.C.C.s into Palladium's men-of-arms and scholar sections either, so
-- as with Underseas the skill lists are the argument.
--
-- The two GLITTER BOY PILOTS are the clearest men of arms in the batch and
-- reach 3D6 without an argument: Elite Glitter Boy combat training, W.P.
-- Energy Rifle and W.P. Heavy Military Weapons granted outright, Weapon
-- Systems, Military open at +5% and +10% respectively, and a whole class
-- identity that is piloting a two-ton assault power armor into a war.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-descended-glitter-boy-pilot' || char(10), char(10) || 'id: fq-descended-glitter-boy-pilot' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-descended-glitter-boy-pilot' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-glitter-girl-pilot' || char(10), char(10) || 'id: fq-glitter-girl-pilot' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-glitter-girl-pilot' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The DEEP INTEL AGENT is the opposite and is 1D6. It is a spy: its
-- combat grant is Hand to Hand: Basic and two W.P.s of choice, its own
-- book files it under le Surete du Quebec rather than the military, and
-- its related skills bar Military outright - the one category line that
-- reads 'Military: None (other than O.C.C. skills above)'. Its P.B. is
-- capped rather than required because the job is to not be noticed.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-deep-intel-agent' || char(10), char(10) || 'id: fq-deep-intel-agent' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-deep-intel-agent' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The SIDE KICK RPA and the RELOADER are both 3D6, and the Reloader is the
-- one worth arguing. The Side Kick is a power armor pilot with Hand to Hand:
-- Expert and three W.P.s - no argument needed. The Reloader has Hand to
-- Hand: BASIC and two W.P.s, which by the Underseas reasoning would read as
-- 1D6. Two things outweigh it, and both are the book being explicit rather
-- than a judgement about the skill list: printed 41 says outright that
-- "Loaders are also combat trained soldiers who will not hesitate to fight",
-- and printed 34 lists Reload Teams among the O.C.C.s OF THE QUEBEC MILITARY
-- - "EOD Specialists (includes Reload Teams)" - on the army's own roster.
-- Its O.C.C. bonuses are combat-survival ones too: +10 S.D.C., +2 to roll
-- with impact, +1 to dodge, +2 vs Horror Factor. Underseas had no sentence
-- like that to read, which is why its scientists went the other way.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-side-kick-rpa' || char(10), char(10) || 'id: fq-side-kick-rpa' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-side-kick-rpa' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-gb-reloader' || char(10), char(10) || 'id: fq-gb-reloader' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-gb-reloader' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The FREE QUEBEC CYBORG SOLDIER is the only one of this book's five cyborg
-- classes that needs an entry, and the reason is worth stating because the
-- other four look like omissions. `withCorePools` returns early for a class
-- stating an `mdc_base`, and the four CHASSIS - Imprimer, Dervish, Slasher
-- and Leviathan - each state one, being machines with a printed main body.
-- This entry covers the PARTIAL conversion cyborg as well as the full one,
-- and a partial conversion is a living human with bionic limbs who still
-- tracks S.D.C. 3D6, on the army's own roster: printed 34 lists Cyborg
-- Strike Troopers at 10% of the Quebec Military, and the class is granted
-- Hand to Hand: Expert, three W.P.s and Military at +10%.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: fq-cyborg-soldier' || char(10), char(10) || 'id: fq-cyborg-soldier' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'fq-cyborg-soldier' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Heroes Unlimited's eleven EDUCATIONAL LEVELS, printed 27. All 1D6, and the
-- uniformity is the point rather than an oversight: an education is never a
-- man of arms. This book puts schooling in the O.C.C. slot and the Power
-- Category in the R.C.C. slot, so durability is the Power Category's to
-- state - including for the two MILITARY educations, whose soldiering is
-- training rather than a body.
--
-- Which makes these entries very nearly moot, and worth having anyway.
-- `combineClasses` gives the RACIAL class's pool precedence, so a played
-- Heroes Unlimited character takes its S.D.C. from the Power Category every
-- time; this fires only for an education played with no Power Category at
-- all. The smoke test demands the classification rather than defaulting,
-- because a class stating no formula and missing from this table is saved
-- with `sdc_max` NULL.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-high-school' || char(10), char(10) || 'id: hu-edu-high-school' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-high-school' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-military' || char(10), char(10) || 'id: hu-edu-military' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-military' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-trade-school' || char(10), char(10) || 'id: hu-edu-trade-school' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-trade-school' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-one-year-college' || char(10), char(10) || 'id: hu-edu-one-year-college' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-one-year-college' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-two-years-college' || char(10), char(10) || 'id: hu-edu-two-years-college' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-two-years-college' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-three-years-college' || char(10), char(10) || 'id: hu-edu-three-years-college' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-three-years-college' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-four-years-college' || char(10), char(10) || 'id: hu-edu-four-years-college' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-four-years-college' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-military-specialist' || char(10), char(10) || 'id: hu-edu-military-specialist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-military-specialist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-bachelors' || char(10), char(10) || 'id: hu-edu-bachelors' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-bachelors' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-masters' || char(10), char(10) || 'id: hu-edu-masters' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-masters' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-edu-doctorate' || char(10), char(10) || 'id: hu-edu-doctorate' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-doctorate' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Alien R.C.C.'s own five education packages, printed 56. It does not
-- roll on the table above - it prints a five-outcome one that replaces it -
-- so these sit in the same slot and take the same 1D6.
--
-- THE MILITARY AND COMBAT SPECIALISTS WERE CONSIDERED FOR 3D6 and left at
-- 1D6. Each grants a hand to hand skill, several W.P.s and physical skills,
-- which is what a men-of-arms entry usually looks like - but the 3D6/1D6
-- split is read off a Palladium book's own section heading, and Heroes
-- Unlimited has no such heading: it is not organised that way. What it does
-- state is that "all aliens have a base S.D.C. of 20", on the R.C.C., which
-- takes precedence over anything here. Guessing a grouping this book does not
-- use, for a value the R.C.C. overrides, would be inventing a number.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-alien-edu-general-studies' || char(10), char(10) || 'id: hu-alien-edu-general-studies' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-general-studies' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-alien-edu-military-specialist' || char(10), char(10) || 'id: hu-alien-edu-military-specialist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-military-specialist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-alien-edu-science-specialist' || char(10), char(10) || 'id: hu-alien-edu-science-specialist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-science-specialist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-alien-edu-combat-specialist' || char(10), char(10) || 'id: hu-alien-edu-combat-specialist' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-combat-specialist' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: hu-alien-edu-engineer' || char(10), char(10) || 'id: hu-alien-edu-engineer' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-engineer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Nightbane RPG. The book's own rule (printed 36) is not the men-of-arms
-- split this table was built on: a character with a military, police,
-- detective or athletic occupation or background rolls 1D4x10, and ALL
-- others roll 3D6. The Psychic P.C.C. (printed 68-69), Sorcerer (115-117)
-- and Mystic (117-118) print no S.D.C. and are none of those four, so 3D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-psychic' || char(10), char(10) || 'id: nb-psychic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-psychic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-sorcerer' || char(10), char(10) || 'id: nb-sorcerer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-sorcerer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-mystic' || char(10), char(10) || 'id: nb-mystic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Doppleganger R.C.C. (printed 158-160) prints only "add 20 to the total
-- S.D.C." - a pool bonus, stored as one - over a base it never states. A race
-- here is otherwise 1D6, but Nightbane's printed 36 gives every non-military
-- character 3D6 and names no separate figure for a race, so the book's own
-- rule wins. The Hunter, Ashmedai, Namtar and Snake Bird state sdc_base.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-doppleganger' || char(10), char(10) || 'id: nb-doppleganger' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-doppleganger' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Wampyr R.C.C. (printed 188-189) prints "2D6x10+20 plus those gained
-- before the transformation" - a racial pool bonus over an unstated base, as
-- the Doppleganger's is - so the base is printed 36's 3D6. The two vampires
-- state sdc_base 0 (hit points only) and the Guardian states its own.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-wampyr' || char(10), char(10) || 'id: nb-wampyr' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-wampyr' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- The Nightbane's six O.C.C.s (printed 88-90 and 118-120) print no S.D.C.;
-- they are only ever paired with the Nightbane R.C.C., whose Facade states
-- sdc_base 30 and wins, so these fire only for an O.C.C. read alone, which
-- their race_restrictions never allow. Printed 36 would give the ex-military
-- Resistance/Spook Squad package 1D4x10, but that entry can never fire and
-- this table has only ever held 1D6 and 3D6, so all six are 3D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-package-basic' || char(10), char(10) || 'id: nb-package-basic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-basic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-package-resistance' || char(10), char(10) || 'id: nb-package-resistance' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-resistance' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-package-nocturne' || char(10), char(10) || 'id: nb-package-nocturne' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-nocturne' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-package-warlord' || char(10), char(10) || 'id: nb-package-warlord' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-package-warlord' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-nightbane-sorcerer' || char(10), char(10) || 'id: nb-nightbane-sorcerer' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-nightbane-sorcerer' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: nb-nightbane-mystic' || char(10), char(10) || 'id: nb-nightbane-mystic' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'nb-nightbane-mystic' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

-- Rifts World Book 29: Madhaven, printed 26-38 - the Order of the White Rose.
-- None prints an S.D.C. formula; each prints only a pool bonus (+20, +10,
-- +15, +20). Printed 28 and 37 file the Mystic Knight and the Keeper among
-- the magic O.C.C.s, and the Gateway Knight is a Mystic Knight, so those three
-- are 1D6. The Squire is the Order's non-Mystic fighter and is 3D6.
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: knight-of-the-white-rose' || char(10), char(10) || 'id: knight-of-the-white-rose' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'knight-of-the-white-rose' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: gateway-knight' || char(10), char(10) || 'id: gateway-knight' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'gateway-knight' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: keeper-of-the-garden' || char(10), char(10) || 'id: keeper-of-the-garden' || char(10) || 'men_of_arms: false' || char(10)), updated_at = datetime('now') WHERE class_id = 'keeper-of-the-garden' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'id: squire-of-the-white-rose' || char(10), char(10) || 'id: squire-of-the-white-rose' || char(10) || 'men_of_arms: true' || char(10)), updated_at = datetime('now') WHERE class_id = 'squire-of-the-white-rose' AND instr(markdown, char(10) || 'men_of_arms:') = 0;

SELECT 'every class the map named now states men_of_arms' AS assertion, count(*) AS got, 207 AS want
  FROM imported_classes WHERE class_id IN ('necromancer-russian', 'born-mystic', 'russian-fire-sorcerer', 'old-believer', 'gypsy-enforcer', 'layer-of-laws', 'gifted-one-russian', 'gypsy-fortune-teller', 'gypsy-thief-russian', 'gypsy-seer-russian', 'gypsy-wizard-thief-russian', 'slayer-russian', 'bandit', 'highwayman', 'bounty-hunter', 'gunfighter', 'gunslinger', 'justice-ranger', 'psi-slinger', 'saddle-tramp', 'sheriff-lawman', 'sheriffs-deputy', 'wired-gunslinger', 'cowboy', 'tribal-warrior', 'mystic-warrior', 'totem-warrior', 'spirit-warrior', 'animal-shaman', 'mask-shaman', 'healing-shaman', 'paradox-shaman', 'elemental-shaman', 'elemental-shaman-air', 'elemental-shaman-earth', 'elemental-shaman-fire', 'elemental-shaman-water', 'fetish-shaman', 'glitter-boy', 'headhunter-techno-warrior', 'merc-soldier', 'robot-pilot', 'psi-stalker', 'wild-psi-stalker', 'crazy', 'coalition-grunt', 'coalition-samas-pilot', 'coalition-technical-officer', 'knight', 'soldier', 'palladin', 'ranger', 'mercenary-fighter', 'squire', 'thief', 'assassin', 'berserker', 'ngr-infantry-soldier', 'ngr-communications-officer', 'ngr-medical-officer', 'ngr-cyborg-soldier', 'ngr-field-mechanic', 'ngr-power-armor-commando', 'ngr-robot-combat-pilot', 'ngr-robot-soldier', 'ngr-intelligence-officer', 'ngr-intelligence-commando', 'ngr-police', 'preacher', 'professional-gambler', 'saloon-bum', 'saloon-girl', 'burster', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water', 'ley-line-rifter', 'ley-line-walker', 'russian-ley-line-walker', 'mind-melter', 'mystic', 'priest-of-light', 'rifts-priest', 'warrior-of-valhalla', 'murder-wraith', 'gambler', 'juicer-wannabe', 'shifter', 'stone-master', 'techno-wizard', 'warlock', 'warlock-air', 'warlock-earth', 'warlock-fire', 'warlock-water', 'warlock-air-earth', 'warlock-air-fire', 'warlock-air-water', 'warlock-earth-fire', 'warlock-earth-water', 'warlock-fire-water', 'body-fixer', 'city-rat', 'operator', 'cyber-doc', 'rogue-scholar', 'rogue-scientist', 'vagabond', 'wilderness-scout', 'gypsy-thief', 'gypsy-wizard-thief', 'gypsy-seer', 'gypsy-gifted', 'merchant', 'noble', 'scholar', 'vagabond-peasant', 'wizard', 'summoner', 'diabolist', 'priest-of-darkness', 'warrior-monk', 'druid', 'witch', 'psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage', 'human', 'elf', 'dwarf', 'gnome', 'troglodyte', 'kobold', 'goblin', 'hob-goblin', 'orc', 'ogre', 'troll', 'changeling', 'wolfen', 'coyle', 'caf-trooper', 'caf-fleet-officer', 'tvia-inspector', 'caf-scientist', 'noro', 'noro-psychic', 'noro-mystic-warrior', 'space-wolfen', 'imperial-legionnaire', 'freedom-fighter', 'imperial-security-agent', 'galactic-tracer', 'space-pirate', 'spacer', 'runner', 'colonist', 'pleasurer', 'promethean-phase-adept', 'phase-mystic', 'promethean-time-master', 'sea-inquisitor', 'whale-singer', 'ocean-wizard', 'sea-druid', 'tritonian-sea-wolf', 'tritonian-scientist', 'navy-seaman', 'marine', 'salvage-expert', 'fq-descended-glitter-boy-pilot', 'fq-glitter-girl-pilot', 'fq-deep-intel-agent', 'fq-side-kick-rpa', 'fq-gb-reloader', 'fq-cyborg-soldier', 'hu-edu-high-school', 'hu-edu-military', 'hu-edu-trade-school', 'hu-edu-one-year-college', 'hu-edu-two-years-college', 'hu-edu-three-years-college', 'hu-edu-four-years-college', 'hu-edu-military-specialist', 'hu-edu-bachelors', 'hu-edu-masters', 'hu-edu-doctorate', 'hu-alien-edu-general-studies', 'hu-alien-edu-military-specialist', 'hu-alien-edu-science-specialist', 'hu-alien-edu-combat-specialist', 'hu-alien-edu-engineer', 'nb-psychic', 'nb-sorcerer', 'nb-mystic', 'nb-doppleganger', 'nb-wampyr', 'nb-package-basic', 'nb-package-resistance', 'nb-package-nocturne', 'nb-package-warlord', 'nb-nightbane-sorcerer', 'nb-nightbane-mystic', 'knight-of-the-white-rose', 'gateway-knight', 'keeper-of-the-garden', 'squire-of-the-white-rose')
  AND instr(markdown, char(10) || 'men_of_arms: ') > 0;
SELECT 'men of arms (3D6)' AS assertion, count(*) AS got, 77 AS want
  FROM imported_classes WHERE instr(markdown, char(10) || 'men_of_arms: true' || char(10)) > 0;
SELECT 'everyone else (1D6)' AS assertion, count(*) AS got, 130 AS want
  FROM imported_classes WHERE instr(markdown, char(10) || 'men_of_arms: false' || char(10)) > 0;
SELECT 'no class states it twice' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE instr(substr(markdown, instr(markdown, char(10) || 'men_of_arms:') + 13), char(10) || 'men_of_arms:') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~001-men-of-arms-frontmatter.sql');
