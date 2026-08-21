-- skills rows that existed only in production.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/restore-skills-missing-from-repo.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/restore-skills-missing-from-repo.sql
--
-- WHY THESE WERE MISSING. The catalog editor and the importer's confirm step
-- both write straight to D1. Nothing in git creates what they add, so a
-- database built from schema.sql plus the data scripts came up 75 skills
-- rows short, and every class citing one had a dead reference.
--
-- Found by a regression test, not by inspection: an audit of every only/except
-- restriction failed against a fresh build because it named skills that build
-- did not have. The same gap had already been found once for classes
-- (chiang-ku-dragon and juicer) and closed the same way.
--
-- NAMED restore-* DELIBERATELY. Data scripts are applied in filename order, and
-- an add-* file would sort BEFORE rename-skills-to-rue.sql: the restore would
-- insert Mathematics: Basic, the rename would then find its target name already
-- taken and skip, and a fresh build would end up holding BOTH that and the
-- Basic Math the seed created. restore-* sorts after rename-* and before
-- retire-*, so the renames happen first and this fills whatever is still short.
--
-- Exported from the live rows as they stand. Guarded on the key, so on
-- production this finds everything already present and does nothing - it is a
-- fresh environment that needs it.

INSERT OR IGNORE INTO skills
  (name, category, base, per_level, systems, source, source_book, bonuses, level_bonuses, note)
VALUES
  ('Optic Systems', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Adds a one time bonus of +5% to T.V./Video skill if both are selected'),
  ('Radio: Scramblers', 'Communications', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Surveillance', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Electronics: Basic or Electrical Engineering, and Computer Operation and Literacy (latter two needed only for complex, high-tech systems)'),
  ('T.V./Video', 'Communications', 25, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'RUE p.302 lists 25%+5%'),
  ('Cook', 'Domestic', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Dance', 'Domestic', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Fishing', 'Domestic', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Play Musical Instrument', 'Domestic', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Each specific instrument requires separate selection of this skill'),
  ('Sewing', 'Domestic', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Not a tailoring ability, but can become tailoring if selected twice'),
  ('Basic Electronics', 'Electrical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Computer Repair', 'Electrical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'RUE p.302 lists 30%+5%'),
  ('Electrical Engineer', 'Electrical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Advanced Mathematics and Literacy; -30% penalty when working on alien or techno-wizard devices; RUE p.302 lists 35%+5%'),
  ('Robot Electronics', 'Electrical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Electrical Engineering and Computer Sciences; -40% penalty on alien or unfamiliar robot electronics'),
  ('Forgery', 'Espionage', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Skilled forgers can recognize other counterfeits at -10%'),
  ('Pick Locks', 'Espionage', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Pick Pockets', 'Espionage', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Sniper', 'Espionage', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Adds +2 to strike on an aimed shot; only single-shot rifles usable'),
  ('Aircraft Mechanics', 'Mechanical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Automotive Mechanics', 'Mechanical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, '-20% penalty on hover jet ground vehicle systems, -40% on reactor engines'),
  ('Locksmith', 'Mechanical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires basic electronics (-5% on complex/high-tech locks) or electrical engineer (+5% bonus); -20% penalty on super high-tech systems'),
  ('Mechanical Engineer', 'Mechanical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Grants one-time +5% to locksmith and surveillance systems if known; -30% penalty on alien/technowizard mechanics; Requires basic or advanced mathematics, basic electronics, literacy'),
  ('Robot Mechanics', 'Mechanical', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, '-30% penalty with alien or extremely unfamiliar mechanics; Requires Mechanical Engineer skill'),
  ('Weapons Engineer', 'Mechanical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires Mechanical Engineering and basic electronics'),
  ('Forensics', 'Medical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires biology, chemistry, chemistry: analytical, advanced mathematics, and literacy'),
  ('First Aid', 'Medical', 45, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Holistic Medicine', 'Medical', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'A failed roll means the treatment or concoction did not work; RUE p.302 lists 30%/20%+5%'),
  ('M.D. in Cybernetics', 'Medical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, '40%/60% - first number is diagnosis/treatment of non-surgical problems, second is surgical/cybernetic installation ability; -15% penalty working on bionics'),
  ('Medical Doctor', 'Medical', 60, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, '60%/50% - first number is diagnostic ability, second is treatment ability; -10% penalty on cybernetics work, -40% on bionics; Requires biology, pathology, chemistry, basic or advanced mathematics, literacy'),
  ('Paramedic', 'Medical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Pathology', 'Medical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires biology, chemistry, and literacy skills'),
  ('Demolitions Disposal', 'Military', 60, 3, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Athletics (general)', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', '{"attributes":{"PS":1},"combat":{"parry":1,"dodge":1,"roll":1}}', NULL, 'Provides bonuses: +1 parry/dodge, +1 roll with punch/fall, +1 P.S., +1D6 Spd, +1D8 S.D.C.'),
  ('Airplane', 'Pilot', 50, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Automobile', 'Pilot', 60, 2, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Boat: Motor, Race & Hydrofoil', 'Pilot', 55, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Boat: Sail Type', 'Pilot', 60, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Boat: Ships', 'Pilot', 45, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Sailing ships: 45%+5%/lvl; Motor driven ships: 44%+4%/lvl'),
  ('Helicopter', 'Pilot', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires weapons systems skill to operate weapons on combat helicopter'),
  ('Hover Craft (ground)', 'Pilot', 50, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Jet Aircraft', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Military: Jet Fighters', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Jet Packs', 'Pilot', 42, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Motorcycles & Snowmobiles', 'Pilot', 60, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Robot Combat Elite', 'Pilot', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'No base skill; pilot has specific skills/bonuses that progress by level, like hand to hand combat'),
  ('Military: Tanks & APCs', 'Pilot', 36, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Truck', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Navigation', 'Pilot Related', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Basic math, read sensory equipment, and at least minimal literacy'),
  ('Sensory Equipment', 'Pilot Related', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Weapon Systems', 'Pilot Related', 40, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Adds +1 to strike with vehicle/robot weapon systems'),
  ('Computer Hacking', 'Rogue', 15, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: read/write, computer operation, computer programming, basic mathematics; +5% one-time bonus to cryptography, surveillance, and locksmith skills; RUE p.302 lists 20%+5%'),
  ('Concealment', 'Rogue', 20, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Smaller/lighter objects add +5%'),
  ('Palming', 'Rogue', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Adds +5% to pick pockets skill'),
  ('Streetwise', 'Rogue', 20, 4, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Anthropology', 'Science', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'RUE p.302 lists 30%+5%'),
  ('Archaeology', 'Science', 20, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'RUE p.302 lists 30%/20%+5%'),
  ('Chemistry ' || char(8212) || ' Analytical', 'Science', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Chemistry, advanced mathematics, and literacy; computer operation suggested'),
  ('Computer Programming', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires: Computer operation and literacy; hacking possible at -40% without hacking skill'),
  ('Lore: Faeries & Creatures of Magic', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Photography', 'Technical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Creative Writing', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Requires Literacy'),
  ('W.P. Automatic Pistol', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"All modern military automatic pistols. The trigger must be pulled for each shot, but the pistol automatically ejects the cartridge and loads a new one from the magazine into the chamber. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":7,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":10,"applies_when":"with an automatic pistol","combat":{"strike":1}},{"level":13,"applies_when":"with an automatic pistol","combat":{"strike":1}}]', NULL),
  ('W.P. Automatic and Semi-automatic Rifles', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"All assault rifles, such as the M-16 and AK-47. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":7,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":10,"applies_when":"with an assault rifle","combat":{"strike":1}},{"level":13,"applies_when":"with an assault rifle","combat":{"strike":1}}]', NULL),
  ('W.P. Bolt Action Rifle', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"Hunting and sniping rifles. NO burst bonus - a bolt-action rifle is worked by hand between shots and cannot fire a burst, which is what separates it from the automatic rifle proficiency. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":7,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":10,"applies_when":"with a bolt action rifle","combat":{"strike":1}},{"level":13,"applies_when":"with a bolt action rifle","combat":{"strike":1}}]', 'Hunting and sniping rifles'),
  ('W.P. Chain', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":1,"note":"Parrying is only possible while the weapon is wielded in two hands. This weapon cannot be used to entangle and cannot be thrown with any accuracy: -3 to strike when thrown."},{"level":3,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":4,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":7,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":8,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":10,"applies_when":"with a chain weapon","combat":{"strike":1}},{"level":12,"applies_when":"with a chain weapon","combat":{"parry":1}},{"level":13,"applies_when":"with a chain weapon","combat":{"strike":1}}]', NULL),
  ('W.P. Heavy Military Weapons', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"Machineguns, bazookas, LAWS and mortars. The burst bonus applies only to the weapons that can actually fire a burst. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":7,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a heavy weapon","combat":{"strike":1}},{"level":13,"applies_when":"with a heavy weapon","combat":{"strike":1}}]', 'Machineguns, bazookas, LAWS, and mortars'),
  ('W.P. Heavy M.D. Weapons', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":3}},{"level":1,"note":"Plasma ejectors, rail guns and similar Mega-Damage weapons, including those built into giant robots, tanks and combat vehicles; a common skill of designated gunners. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a heavy energy weapon","combat":{"strike":1}},{"level":7,"applies_when":"with a heavy energy weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a heavy energy weapon","combat":{"strike":1}},{"level":13,"applies_when":"with a heavy energy weapon","combat":{"strike":1}}]', NULL),
  ('W.P. Revolver', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"firing a burst","combat":{"strike":1}},{"level":1,"applies_when":"taking an aimed shot","combat":{"strike":4}},{"level":1,"note":"All cylinder-style handguns; not automatic, and does not jam. The aimed-shot bonus is +4 rather than the +3 the other modern handgun proficiencies give. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":4,"applies_when":"with a revolver","combat":{"strike":1}},{"level":7,"applies_when":"with a revolver","combat":{"strike":1}},{"level":10,"applies_when":"with a revolver","combat":{"strike":1}},{"level":13,"applies_when":"with a revolver","combat":{"strike":1}}]', NULL),
  ('W.P. Submachine-Gun', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, '[{"level":1,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":1,"note":"Small arms automatic weapons like the Uzi; can only fire in bursts. P.P. attribute bonuses and Hand to Hand combat bonuses do NOT apply to modern weapons."},{"level":3,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":6,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":9,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":12,"applies_when":"with a sub-machinegun","combat":{"strike":1}},{"level":15,"applies_when":"with a sub-machinegun","combat":{"strike":1}}]', NULL),
  ('Boat Building', 'Wilderness', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, NULL),
  ('Carpentry', 'Wilderness', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'Adds +5% bonus to Boat Building skill if taken'),
  ('Hunting', 'Wilderness', 0, 0, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'No base skill; adds +2% prowl, +5% track animals, +5% skin animals, +5% wilderness survival, +5% to cook the catch only'),
  ('Preserve Food', 'Wilderness', 25, 5, NULL, 'import', 'Rifts Ultimate Edition', NULL, NULL, 'RUE p.302 lists 30%+5%'),
  ('Language: Dragonese', 'Technical', 50, 5, NULL, 'seed', NULL, NULL, NULL, NULL),
  ('Language: All (magical)', 'Communications', 98, 0, NULL, 'import', NULL, NULL, NULL, 'NOT a purchasable skill: a class or racial ability line granting comprehension and speech of any language through innate magic, conventionally written at 98%. It does not confer literacy. base 0 and per_level 0 read as an unfilled row, so the conventional 98% is recorded here instead.'),
  ('Literacy: Dragonese/Elven', 'Technical', 30, 5, NULL, 'import', NULL, NULL, NULL, 'Read and write Dragonese/Elven, the tongue of dragons and elves - common in Tolkeen, Lazlo and the Federation of Magic, and outlawed in Coalition territory. Each language counts as a separate skill selection, and Literacy in a language does NOT grant the spoken Language skill (or the reverse). RUE splits generic literacy into Literacy: Native at 40% +5% and Literacy: Other at 30% +5%.');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS skills_total FROM skills;

INSERT INTO data_script_runs (filename) VALUES ('restore-skills-missing-from-repo.sql');
