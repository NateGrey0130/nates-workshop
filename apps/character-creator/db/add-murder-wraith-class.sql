-- Murder-Wraith, one of the ten Juicer variants Rifts World Book Ten:
-- Juicer Uprising defines, printed p.50-53.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-murder-wraith-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- An undead Juicer, and the book labels it an NPC VILLAIN in its own text. Immune to everything that is not silver or magic, regenerating 3D6 hit points per melee round, and frozen at the experience level it died on.
--
-- SECOND OF THREE BATCHES. See add-hyperion-juicer-class.sql for why these are
-- fifteen separate classes rather than one row with `variants` - in short,
-- VARIANT_OVERRIDES cannot reach the skills block or special_abilities, and
-- that is where they differ. Every one of these prints its own O.C.C. Skills,
-- its own Related Skills count and schedule, its own Secondary Skills, its own
-- equipment and money, and its own numbered abilities list.
--
-- WHY --remote MATTERED HERE. class-check against the LOCAL database reported
-- two dead exclusions on the Maxi-Killer's Pilot list, "Robots & Power Armor"
-- and "Robot Combat Elite: Glitter Boy". Both are real rows in PRODUCTION; the
-- local database is stale and holds the pre-rename spelling. An unmatched
-- `except` fails OPEN, so believing the local run would have meant deleting two
-- exclusions the book actually prints. Audit against --remote.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'murder-wraith', 'Murder-Wraith', 'rifts', '---
id: murder-wraith
name: Murder-Wraith
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.50-53
category: rcc
hit_points_base: "the former body''s S.D.C. and hit points COMBINED - most Juicers have hundreds of S.D.C. and 30+ hit points. For a Mega-Juicer, multiply his M.D.C. by two. Neither pool ever rises again: experience level is frozen at the moment of death."
ppe_base: "P.E. x2"
bonuses:
  attributes: { PS: "1d4+2" }
  saves: { spell_magic: 2, psionics: 2, horror_factor: 10 }
natural_abilities:
  - name: "Horror Factor: 14"
    description: "And alignment is diabolic 90% of the time, miscreant the other 10%. There is no good Murder-Wraith."
  - name: "Retains Every Juicer Power"
    description: "All the Juicer powers, bonuses and abilities of the previous life carry over. The bio-comps fuse magically with the body, and the creature never needs another drug or chemical to keep them - the one Juicer in this book with no supply problem, because it is already dead."
  - name: "Supernatural Attributes"
    description: "Strength and endurance become supernatural if they were not already. Use the original Juicer''s attributes, then subtract 1D4 from I.Q., M.E. and M.A., add 1D4+2 to P.S., and reduce Physical Beauty BY TWO-THIRDS. Damage follows the supernatural strength table reprinted in the Titan Juicer entry."
  - name: "Invulnerability"
    description: "Non-magical weapons and attacks do NO damage at all - including M.D. energy weapons and plasma bolts. Powerful explosions and mega-damage attacks may knock a Murder-Wraith down; they do not hurt it. It carries M.D.C. by worn armour only, and many do not bother with armour."
  - name: "Regeneration"
    description: "Regenerates 3D6 hit points at the END OF EVERY MELEE ROUND. The only way to destroy one is to drive it to negative 10 hit points, at which point it crumbles into dust and ceases to exist."
  - name: "Energy Vampirism and Cannibalism"
    description: "Needs both P.P.E. and the flesh of thinking beings to survive - at least 10 P.P.E. and one pound of human or D-Bee flesh a week, and it can store up to ten weeks'' worth by consuming that much in a day. P.P.E. is absorbed ONLY by touching a victim who is in pain, which is why most Murder-Wraiths torture their prey or eat them alive: 1D6 P.P.E. per round of pain, up to the victim''s total. The drain is neither permanent nor lethal in itself, but survivors must save versus insanity or take a permanent derangement (01-33 roll on the random insanity table, 34-67 phobia of Murder-Wraiths or all undead, 68-00 obsession with destroying them). Miss either the flesh or the P.P.E. and its own pool drops by one point per day; exhaust it through starvation and the creature dissolves into a pile of goo."
  - name: "Frozen"
    description: "Experience level, skills and skill percentages are all fixed at the moment of death and never improve. Whatever the Juicer knew is what the Murder-Wraith knows, forever."
  - name: "Life Span"
    description: "Unknown, and presumed eternal - or until something destroys it."
restrictions: ["NPC VILLAIN. The book says outright that this is not recommended as a player character.", "Must have been an evil Juicer in life.", "Dragon Juicers, all other techno-wizard and bio-wizard variants, and Psycho-Stalkers CANNOT become Murder-Wraiths - their magical or psychic abilities prevent the necromantic ritual from taking effect.", "No psionic powers. Any the Juicer had in life are lost.", "No magic powers.", "Vulnerable to silver, to magic weapons and mega-damage magic (full damage), to supernatural hand to hand attacks (one M.D. point inflicts one hit point), to S.D.C. magic at half damage, and to holy and rune weapons that punish undead at double damage or their usual vampire bonus, whichever is higher."]
extraction_notes: "MODELLED AS AN R.C.C. AND NOT AN O.C.C., which is what the book prints: it has R.C.C. Skills, a Horror Factor, Natural Abilities and a Vulnerabilities section, and its skills are the former life''s rather than a training programme. An R.C.C. granting no related and no secondary skills is correct rather than missing data, and here it is the point - the skills are frozen. The book''s I.Q., M.E. and M.A. penalties (-1D4 each) and the two-thirds cut to P.B. are prose rather than bonuses, because the bonuses block takes additions; only the +1D4+2 to P.S. is stored. Hit points are a formula in words for the same reason: the pool is read off the character the Murder-Wraith used to be, which nothing in the app can compute. This class is published so it can be built and put on a sheet, which is how a GM uses an NPC - the NPC warning is in restrictions and in the prose, where a player will see it."
---

## Lore

Rifts Earth has produced two kinds of techno-wizard Juicer. One is alchemical -
the Dragon Juicer, made with dragon''s blood in Kingsdale. The other is
necromantic.

Murder-Wraiths are men and women who worshipped the embodiment of Death itself
and let themselves be made into undead monsters with no shred of humanity left.
They are the work of the most vile and extreme members of the Federation of
Magic and other foul sorcerers, and most are in the service of a Necromancer or
a death cult like the Grim Reapers - working alongside zombies, skeletons and
other undead, and the occasional vampire, demon or supernatural predator.

They are not made against their will. Every Murder-Wraith volunteered, and
committed horrible crimes to qualify. For the most part they are beyond
redemption, as bad as a master vampire and every bit as willing.

What they get for it is a body that most weapons simply cannot hurt, that heals
3D6 hit points every fifteen seconds, that keeps every Juicer power it ever had
without needing another dose of anything, and that will never grow old.

What they pay is everything else. A Murder-Wraith cannot learn. Its experience
level froze at the moment it died, and it will know exactly what it knew that
day for however long eternity turns out to be. And it must eat: ten P.P.E. and a
pound of human flesh a week, and the P.P.E. only comes out of someone who is in
pain.

## GM Notes

**The book calls this an NPC villain and means it.** It is here so a GM can
build one, roll it, and put it on a sheet - not as an option for the table.

**Invulnerability is not a difficulty setting, it is a puzzle.** Energy weapons,
plasma, rail guns and explosives do nothing. Silver does full damage. Magic does
full damage. A supernatural fist does one hit point per M.D. point. Holy and
rune weapons that punish undead do double. A party that has none of those cannot
hurt a Murder-Wraith at all, and 3D6 regeneration per round means it does not
matter how long they try.

**It has to be driven to -10 hit points**, not zero, against 3D6 healing every
round. That is the whole fight.

**The starvation clock is the humane way out.** Cut a Murder-Wraith off from
P.P.E. and flesh and it loses a point a day until it dissolves. Trapping one is
a legitimate victory, and a much more achievable one than killing it.

**Note who cannot become one.** Dragon Juicers, Psycho-Stalkers and every
bio-wizard variant are immune to the ritual - their magic or psionics get in the
way. Murder-Wraiths are made from the mundane Juicers: the standard, the
Hyperion, the Titan, the Phaeton, the Mega, the Delphi, the Coalition.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'murder-wraith');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'murder-wraith';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-murder-wraith-class.sql');
