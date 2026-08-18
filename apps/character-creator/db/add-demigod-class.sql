-- The Demigod R.C.C., Rifts Conversion Book Two: Pantheons of the Megaverse
-- p.17.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-demigod-class.sql
--
-- TRANSCRIBED BY HAND from the printed page, not extracted from a PDF, for the
-- same reason as the Godling: the book is not in the source collection. Check
-- the numbers against a copy before the class is played.
--
-- REQUIRES THE GODLING. The Demigod's one chosen power comes from the Godling's
-- list - "select any ONE power from those listed under godling" - through
-- `from_class: godling`. Apply add-godling-class.sql first, or the choice group
-- resolves to nothing and the class silently offers no powers. The review step
-- reports it as a dangling ability reference if you forget.
--
-- Creates no gear stubs: the Demigod's equipment and money are "as per O.C.C.",
-- so it references nothing of its own. Confirmed by a local dress rehearsal
-- through the real endpoint, which created nothing.
--
-- It also names no skills, which is correct rather than incomplete. The Demigod
-- takes any O.C.C. and every skill comes from there - the pure race-plus-
-- occupation case. See `extraction_notes` in the markdown for that and the five
-- other modelling decisions behind what this class deliberately omits.
--
-- Pure ASCII on purpose: passing non-ASCII to `wrangler d1 execute` on Windows
-- has mangled an em-dash into mojibake in production before.
--
-- Idempotent through the UNIQUE class_id: re-running inserts nothing, and a
-- class already corrected by hand is left alone.

INSERT OR IGNORE INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('demigod', 'Demigod', 'rifts', '---
id: demigod
name: Demigod
system: rifts
source_book: pantheons-of-the-megaverse
category: rcc
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6+4"
  MA: "3d6+6"
  PS: "4d6+4"
  PP: "3d6"
  PE: "4d6"
  PB: "3d6+6"
  Spd: "4d6+6"
mdc_base: "P.E. x 5 plus 2D6 per level of experience"
sdc_base: "P.E. x 8"
hit_points_base: "P.E. x 2 plus 2D6 per level of experience"
bonuses:
  pools: { ppe: "4d6", isp: "4d6" }
  combat: { initiative: 2 }
  saves: { spell_magic: 2, ritual_magic: 2, psionics: 1, horror_factor: 3, coma_death_pct: 20 }
natural_abilities:
  - { name: "Fire and cold resistant", description: "Does half damage." }
  - { name: "Regeneration", description: "Regenerates 1D6x5 M.D.C. every minute." }
special_abilities:
  - { choose: 1, from_class: godling }
restrictions:
  - "Horror Factor: 6+1D4 when he is recognized as a demigod."
  - "Attributes are considered supernatural."
  - "Combat varies with the O.C.C. and the physical skills learned."
  - "Any S.D.C. bonus the character would get from physical skills is added as M.D.C. points."
  - "Most demigods have ONE extra power beyond the one chosen here, similar to that of the godly father or mother. The G.M. assigns it."
  - "May not take these O.C.C.s. Rifts: full conversion cyborg, robot, juicer or crazy - a demigod who unknowingly tries any of those treatments will find that they do not work, or that they negate his supernatural and magic powers. Heroes Unlimited: full conversion cyborg, robot, alien, magic or mutant animal."
  - "The G.M. may rule that an O.C.C. which would offend the demigod''s pantheon is somehow prevented, or comes with modifications and side effects. In general demigods tend toward man-at-arms, magic practitioners or psionics."
  - "Cybernetics and bionics: none to start; most avoid it. Never agree to a full bionic conversion (partial maybe, unless a spell caster) nor consider M.O.M. implants. Suspicious of and cautious about letting strangers operate on him."
  - "Standard equipment and money are as per the O.C.C."
side_effects: "Average life span 1,000 to 4,000 years; some demigods become true immortals. Size is typically around 5 to 8 feet tall (1.5 to 2.4 m), or roll 1D4+4 feet; weight varies with size, usually equal to a muscular human. Habitat: any. Allies: the character''s parent deity (sometimes) and allies of the parent deity. Enemies: enemies of the parent deity and his pantheon."
extraction_notes: |
  Transcribed by hand from Pantheons of the Megaverse p.17, not extracted from a
  PDF. Note that the top of the left column on that page is the tail of the
  Godling entry, not the Demigod.

  Deliberate modelling decisions, recorded so they are not mistaken for
  omissions:

  1. NO skills block at all. "The Demigod can pick any O.C.C. that fits his
     human/D-bee background." This is the pure R.C.C.-plus-O.C.C. case: the race
     sets the body, the occupation supplies every skill. A racial class granting
     zero related and secondary skills is correct here, not a gap.
  2. NO psionics block. The book says "Standard or as per O.C.C." Declaring a
     tier would stop the character rolling on the Random Psionics Table, and
     taking the O.C.C.''s tier is what composition already does when the race
     stays silent. Silence gets both readings right.
  3. NO magic block, for the same reason: "As per O.C.C."
  4. P.P.E. and I.S.P. are "as per the appropriate O.C.C., plus 4D6". The bases
     are omitted so they fall through to the occupation, and the +4D6 is a pool
     bonus on top. Writing the sentence into ppe_base instead yields no P.P.E.
     at all.
  5. The O.C.C. exclusions are prose only. Nothing in the app restricts which
     O.C.C. a race may take; the list is recorded under restrictions so a G.M.
     can enforce it.
  6. S.D.C. and Hit Points apply only "for non-mega-damage worlds". Both are
     stored alongside M.D.C.; which set applies is a campaign decision.

  The one chosen power comes from the Godling''s list, which is what the book
  says: "select any ONE power from those listed under godling". The extra power
  most demigods have is G.M.-assigned and is recorded as a restriction rather
  than a second choice group.
---

## Lore

Demigods are more human, since they are frequently part human and usually have
been raised within human (or D-bee) society as a normal human. The character may
not know what god fathered him or her, or what pantheon the god was from.

The demigod may not even know that he was sired by a god, and may consider
himself a mutant or a superhero. In that case what the character doesn''t know
might hurt him, because he may have supernatural rivals and enemies he is
unaware of. An attack by monsters or gods, or a quest to discover a demigod''s
origins, could start a whole campaign.

Remember that super powerful and courageous warriors, cyborgs, mutants, D-bees,
practitioners of magic and the occasional priest may be considered, or officially
elevated to, the position of demigod or even godling, without having been born of
a god or possessing the power of that O.C.C.

## GM Notes

The G.M. will have to assign specific abilities depending on who the father was.
Beside the one power chosen from the godling list, most demigods will have one
extra power similar to that of the godly parent.

A demigod''s parentage is a campaign hook as much as a stat block. A character who
does not know what he is gives the G.M. rivals, enemies and a quest that the
player has not been told about yet.
', 'published', 'manual');

-- Read the result back rather than trusting the exit code, and confirm the
-- class this one depends on is actually there and live.
SELECT class_id, name, system, status, created_by, length(markdown) AS markdown_bytes
  FROM imported_classes WHERE class_id IN ('demigod', 'godling') ORDER BY class_id;
