-- Rifts World Book 26: Dinosaur Swamp, batch 1: the nine special skills.
-- 9 skills rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~246-dinosaur-swamp-skills.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.
-- THE AUTHORITY is the book's Quick Find (printed 5), the one place its special
-- skills are listed together; each description sits inside the class that owns
-- it. Ten are listed; Sign Language is already held (Palladium Fantasy, 25/5) and
-- the Dinosaur Hunter's specialised form of it (printed 58, 35% +4%) is carried
-- by that class's own grant, not by a second row. Roadwise (printed 54, the
-- Pathfinder's regional form) is held from Rifts Ultimate Edition at the same
-- 26/4. Diffed with scripts/catalog-diff.mjs --remote on 2026-10-20: 9 missing,
-- 0 matched. Every figure was read off the cache (a scan, offset +1 per
-- scripts/books.json) at the page each row cites.
--
-- Cartography stores the GENERAL purchase figure, 34/4, because that is what a
-- class granting Technical: Any offers; the Pathfinder's own 30% +5% is in the
-- note and in that class's grant. Land Navigation: Regional and Stalking print
-- no base percentage and store 0/0, as Hunting does; their bonuses are
-- conditional (on the region, on the prey) and stay in the note.

INSERT OR IGNORE INTO skills (name, category, base, base_formula, per_level, systems, source, source_book, note, bonuses, level_bonuses) VALUES
  ('Cartography', 'Technical', 34, NULL, 4, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.54', 'Map making with pen and paper, computer plotting (needs Computer Operation) or holographic displays; includes the rudiments of mathematics: the equivalent of Math: Basic at a fixed 50% (plus any I.Q. bonus), or +5% to Math: Basic when that skill is also taken. A success gives an accurate, readable map; a failure leaves details wrong or missing and the scale and locations off by 1D10 miles. BASE IS THE GENERAL PURCHASE FIGURE: 34% +4% per level, for any character who takes it as a Technical skill with G.M. approval, where it counts as two O.C.C. Related selections and cannot be a Secondary Skill. The Pathfinder O.C.C., whose special skill it is, has its own Base Skill of 30% +5% per level.', NULL, NULL),
  ('Cross-Country Pacing', 'Wilderness', 25, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.54', 'Exclusive to the Pathfinder O.C.C. Rationing exertion, speed, food and water so that long journeys by foot, horse or mountain bike can be kept up for days. With Land Navigation: Regional, predicts a trip''s length to within 2D6x10 minutes (6D6 hours in unfamiliar country; a party with others in tow takes twice as long). On a bicycle: three times running speed on level ground and twice running speed cross-country, for P.E.x10 minutes without overexertion. On foot: full running speed cross-country for P.E.x5 minutes.', NULL, NULL),
  ('Fashion Weapons & Tools', 'Wilderness', 40, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.64', 'Making weapons and tools by hand from natural materials: wood, bone, teeth, hide, nuts and plant fiber, carved and shaped. A special O.C.C. skill of the Eco-Wizard, and the craft its Eco-Wizardry devices are made with.', NULL, NULL),
  ('Land Navigation: Regional', 'Wilderness', 0, NULL, 0, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.54', 'Exclusive to the Pathfinder O.C.C. No base percentage: specific knowledge of one home region. Within it the character finds hiding places: +30% to Camouflage when concealing himself, a vehicle or objects, but the book then limits camouflaging himself and others to +10% unless they too are a Wilderness Scout, Native American or Psi-Stalker type (the sentence is printed that way), travels at full speed on the run leaving little trail (or an obvious one, by choice), and scouts while covering twice the ground of pursuers. In the region his Land Navigation, Prowl and Tracking of people and animals each gain +10%. Range: centred on one landmark, a radius of 1D6x10+60 miles (112 to 192 km), plus 1D4x10 miles (16 to 64 km) for each level spent mainly in that region; no increase for levels spent travelling beyond it. The bonuses are conditional on the region and are not stored as bonuses.', NULL, NULL),
  ('Lore: Dinosaurs', 'Technical', 20, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.49-50', 'In-depth knowledge of living dinosaurs in general and of the dinosaurs and other exotic creatures of Dinosaur Swamp in particular: habits, species, diet, range, defenses, the value of meat, hide, teeth, claws and bones, strengths and vulnerabilities, and recognising them by tracks and dung. A special O.C.C. skill of the Swamp Stomper, Dinosaur Hunter (p.58) and Wild Knives Warrior (p.63); the Dinosaur Hunter is the most expert.', NULL, NULL),
  ('Lore: Swamp & Everglades', 'Technical', 30, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.50', 'Understanding of swamplands: their ecology, hazards, wildlife and waterways, and the best ways and paths for travelling them. A special O.C.C. skill of the Swamp Stomper, Dinosaur Hunter (p.58) and Wild Knives Warrior (p.63). Named as the Quick Find (p.5), the one list of the special skills, and three of the four class lists spell it; the three skill descriptions head it Lore: Swamps & Everglades.', NULL, NULL),
  ('Stalking', 'Wilderness', 0, NULL, 0, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.58', 'No base percentage. Sneaking up on prey to kill or capture it, a companion skill to Hunting (neither requires the other); takes 1D4+1 melee rounds to get into striking position, close enough to lunge, grab or grapple without startling the animal. Bonuses as applicable: +2 to entangle, leap on and pin, incapacitate or wrestle the animal; +1 to strike on an aimed shot (bows and thrown weapons included); +5% to Prowl, Camouflage, Track Animals/Dinosaurs and Detect Concealment; +10% to Detect Ambush and Detect Traps/Mines; optionally +1D4 to Perception. A special O.C.C. skill of the Dinosaur Hunter. Any character who can take Wilderness skills may buy it, at three O.C.C. Related selections; never as a Secondary Skill. The bonuses are situational and are not stored as bonuses.', NULL, NULL),
  ('Trail Blazing', 'Wilderness', 20, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.50', 'Cutting and marking trails through swamp, forest and wilderness for others to follow. A special O.C.C. skill of the Swamp Stomper and the Pathfinder (p.54); the Pathfinder is the more skilled.', NULL, NULL),
  ('Track Dinosaurs', 'Wilderness', 20, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 26: Dinosaur Swamp p.50', 'Tracking dinosaurs, as part of Track Animals and at the same base, used as much to avoid them as to hunt them. A special O.C.C. skill of the Swamp Stomper (+20%), the Dinosaur Hunter (+30%, p.58) and the Wild Knives Warrior (+15%, p.63).', NULL, NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 9 skills rows are in' AS assertion, count(*) AS got, 9 AS want
  FROM skills WHERE name IN ('Cartography', 'Cross-Country Pacing', 'Fashion Weapons & Tools', 'Land Navigation: Regional', 'Lore: Dinosaurs', 'Lore: Swamp & Everglades', 'Stalking', 'Trail Blazing', 'Track Dinosaurs') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~246-dinosaur-swamp-skills.sql');
