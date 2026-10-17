-- The Amorph's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 1 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~225-book-ingest-audit-f143-psy-amorph.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~225-book-ingest-audit-f143-psy-amorph.sql
--
-- The class amorph follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 21-25 (~096), but its creatures row still cited Rifts World
-- Book 12: Psyscape printed 117-120 and carried its figures. By Nate's ruling
-- of 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays. A complete line D-Bees restates without an item
-- drops that item: the R.C.C. skill line (two languages of choice, Hand to
-- Hand: Basic), the related skills (Domestic and Pilot Related any), the
-- equipment line (fishing tackle, sleeping roll, a conventional and an energy
-- weapon of choice, 1D4 E-clips) and the natural abilities (floating and
-- flying above water), as the class did in ~096. creatures has no notes
-- column, so each Psyscape figure that changed is kept in description with
-- its printed page.
--
-- Body: D-Bees splits Psyscape's one S.D.C./Hit Points pool (P.E. plus
-- 3D6x10, +2D6 per level) into Hit Points 2D6x10 plus the P.E. number (+1D6
-- per level) and S.D.C. 1D6x10+8; it is not an M.D.C. being, so mdc stays
-- NULL. combat goes from NULL to the two figures D-Bees states at level one,
-- four attacks per melee and +2 to automatic dodge (the N'mbyr precedent,
-- ~222); the per-level steps are in bonuses_note. D-Bees prints the save vs
-- Horror Factor as a range, +1 to +6, where Psyscape printed a flat +6: it
-- is prose in bonuses_note, as the class carries it. Both books print the
-- Amorph as an R.C.C. with its own skills, so the row's shape is the same in
-- both (F141 does not arise). The Amorph has no stat_attacks rows, and this
-- script writes none.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the
-- row still citing Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES
-- PRODUCTION: one creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET hp = 'PE+2D6x10',
       sdc = '1D6x10+8',
       ppe = '2D6+6',
       combat = '{"attacks":4,"automatic_dodge":2}',
       pools_note = 'Hit Points: 2D6x10 plus the P.E. number, +1D6 per level of experience. S.D.C.: 1D6x10+8. Not an M.D.C. being and never wears body armor: its M.D.C. defenses are its limited invulnerability and the psionic powers Psychic Body Field and Telekinetic Force Field. I.S.P. +10 per level. P.B. 1D4 is the natural form; shape changing gives any P.B. from 2 to 24. Spd is walking and flying. Bio-regenerates 2D6 Hit Points or S.D.C. per melee round. Feeds on roughly 1D6+20 P.P.E. a week, ideally three points a day, from ley lines, from living creatures at the moment of death, or from the living who willingly share it.',
       bonuses_note = 'No Horror Factor in its natural form; when shape-changed it has that of the creature mimicked. +1 to +6 to save vs Horror Factor, printed as a range (mainly too naive to recognize trouble and danger), +6 to save vs possession, +10% to charm/impress on top of attribute bonuses; needs a 12 or higher to save vs psionic attacks. Four attacks per melee, +1 at levels 5, 9 and 13. Automatic dodge that costs no attack, +2 at level one and +1 more at levels 3, 6, 9 and 12; choosing not to use it to keep a disguise costs one attack and -1 on all combat rolls for the rest of that melee round. Damage as per P.S., weapon or psionics; it must take a suitable body form to use weapons made for humanoids. Vulnerabilities: weight (about 50 lbs/22.5 kg whatever its size), heat signature, missing sounds, speed and capabilities, and interiors of ectoplasmic fuzz give a disguise away, and See Aura, Presence Sense, Detect Psionics, Telepathy, Empathy and Object Read can expose it, so disguises work best from a distance. Wearing no armor, it can be hurt by energy blasts, fire, extreme cold, psionic and magical attacks, and is likely to scream, flee and change shape when threatened or hurt; most are squeamish. Sitting still as an object bores it within minutes. It cannot copy a form from memory, and cannot fly or flatten in a copied form. It cannot go home without a dimensional portal to the Astral Plane, and slain in the physical world it is dead.',
       skills_note = 'Languages: all, via Telepathy, at 85%. Dance (+20%), Climb (+10%), Impersonation (+20% to look like another person, no bonus to act like one), Land Navigation (+25%), Lore: Astral Plane (+15%), Lore: Psychics and Psionics (+15%), one lore of choice (+10%), Prowl (+15% in any form, +25% in its natural form), Tailing. Hand to Hand: None. Four related skills plus one at levels 4, 8 and 12: Communications, Espionage and Science any; Domestic any except Singing; Pilot (+5%); Rogue (+10%) except Computer Hacking; Technical (+5%) except Computer Programming; Medical First Aid and Holistic Medicine only; W.P. Blunt, Knife and Energy Pistol only; no Electrical, Mechanical, Military, Physical, Pilot Related or Wilderness. One secondary skill at levels 1, 3, 6, 9, 12 and 15, from the Secondary Skills List of Rifts Ultimate Edition.',
       natural_abilities = 'Ectoplasmic metamorphosis: copies the look and texture of any living creature, plant or object it can see in three dimensions, from cat-sized to dragon-sized, clothes, armor and gear included, but not its voice, abilities, powers, M.D.C. or weight, so copied weapons and armor are powerless props; never from memory. Asexual, so it can take either gender. Its natural form is a grey glob of ectoplasm that floats and flies slowly at will, no higher than 50 ft above ground and at no I.S.P. cost, with Prowl at 80% while hovering as a blob; it flattens to paper thickness or narrows to a pencil''s width to slip through cracks. Sees through psychic vision, understands all languages and communicates through telepathy at no I.S.P. cost, and cannot speak aloud. Needs no air or solid food. Automatic dodge by globbing the threatened part out of the way. Limited invulnerability: impervious to disease, poison, drugs, gases, pollution and radiation, resistant to heat and cold (only below zero or above 110 degrees Fahrenheit affects it); punches, swords, bullets and rail gun rounds pass through it; an explosion of 80 M.D. or more scatters it into 1D4x100 globules that take 3D6 minutes to reform. Energy weapons, magic weapons, psionics and M.D. fire or plasma do full damage, normal fire half. Sees the invisible (Astral Beings, spirits, Entities, the magically or technologically invisible) at no I.S.P. cost, has perfect human vision and hearing, and senses ley lines and Dragon Roads at 1 mile. On the Astral Plane its flying speed triples, Astral Navigation is 80% +1% per level, it senses ley lines at 10 miles and only psionics and magic can hurt it. Reaches Earth only through dimensional portals, never by Astral Projection. Cybernetics are not applicable.',
       weight = '45 to 60 lbs (20.2 to 27 kg), whatever its size',
       life_span = 'Unknown: many believe it immortal unless slain in the physical world, others that it lives 2D4x100 years',
       habitat = 'The Astral Plane is its home, but it can be found anywhere in the Megaverse. More on Rifts Earth are in North America than elsewhere, since Psyscape is a port of entry, yet fewer than a few thousand are on the planet, half of them in North America; hundreds visit Psyscape''s City of the Mind''s Eye each week and some settle there. They usually travel alone or with a group of mortal, flesh and blood beings',
       allies = 'Typically travels alone; deals fairly with everyone and goes to extreme lengths for friends and kindred spirits. Flocks to the City of the Mind''s Eye, but is found in the ''Burbs and wherever there is excitement and action',
       enemies = 'Dislikes its own kind as rivals, much as one might an elder sibling. Hates and fears demons and other supernatural beings, is leery of creatures of magic and flees and hides from them, and evil Astral Beings and Predators too',
       occ_note = 'R.C.C. with its own skills; optional player character or NPC, not advised (G.M. discretion). Experience level 1D6 for NPCs, or as the G.M. sets; player characters start at first or second level, on the Amorph''s own experience table. Carries little: a backpack and a satchel or utility belt, a folding Swiss Army-type knife, a lighter, a compass, 50 feet (15.2 m) of rope, a portable language translator, a PDD player/recorder, a digital camera and a weapon for each W.P. it has (if any); may keep small souvenirs and likes magic items. 1D6x100 credits to start; wealth is a low priority.',
       description = 'Sentient blobs of living ectoplasm from the Astral Plane who can mimic almost any creature or object. Friendly, nosy and endlessly curious, they can die of boredom, and many now wander Psyscape''s City of the Mind''s Eye and Rifts Earth as naive tourists snapping pictures. Psyscape printed 117-120, which this row followed until ~225, gave one combined S.D.C./Hit Points pool of the P.E. number plus 3D6x10, +2D6 per level, with no separate S.D.C.; P.P.E. 2D6; a weight of 20.4 to 27.2 kg; a life span of immortal unless slain; a flat +6 to save vs Horror Factor; combat as per skill and training, with Hand to Hand: Basic that cannot be upgraded, no set attacks per melee, and an automatic dodge with no level-one bonus to which all normal dodge bonuses from hand to hand training apply; bio-regeneration of 1D6 S.D.C. per melee round outside the Astral Plane; imperviousness to disease, poison and pollution only, with extreme cold, heat and fire doing full damage and physical attacks able to hurt it; about 21 P.P.E. a week; floating and flying above water; two languages of choice (+15%) in place of telepathy at 85%, and no Impersonation, Lore: Psychics and Psionics, Prowl or Tailing; Domestic and Pilot Related any among the related skills; five secondary skills from the related list; gear including fishing tackle, a sleeping roll, a conventional weapon and an energy weapon of choice (usually a vibro-blade or pistol) and 1D4 extra E-clips, and no digital camera; cybernetics impossible because of its amorphous physiology; no enemies, vulnerabilities or experience level; and a habitat of the Outer Layer of the Astral Plane.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.21-25'
 WHERE slug = 'amorph'
   AND source_book = 'Rifts World Book 12: Psyscape p.117-120';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Amorph cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'amorph'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.21-25';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'amorph'
   AND hp = 'PE+2D6x10'
   AND sdc = '1D6x10+8'
   AND mdc IS NULL
   AND ppe = '2D6+6'
   AND horror_factor IS NULL
   AND combat = '{"attacks":4,"automatic_dodge":2}'
   AND instr(bonuses_note, '+1 to +6 to save vs Horror Factor') > 0
   AND life_span LIKE 'Unknown:%';

SELECT 'the attributes and I.S.P. are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'amorph'
   AND isp = 'ME+1D4x10'
   AND attributes = '{"IQ":"2D4+4","ME":"2D6+6","MA":"2D6+12","PS":"1D6+4","PP":"1D6+6","PE":"2D6+6","PB":"1D4","Spd":"2D4+4"}';

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'amorph'
   AND instr(description, 'which this row followed until ~225') > 0;

SELECT 'and it still has no stat_attacks rows' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'amorph';

INSERT INTO data_script_runs (filename) VALUES ('~225-book-ingest-audit-f143-psy-amorph.sql');
