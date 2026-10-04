-- What comparing the uncompared reprints turned up: 15 gear rows, 14 skills,
-- 4 creatures and 3 classes.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~094-reprints-compared-with-their-held-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~094-reprints-compared-with-their-held-rows.sql
--
-- Lone Star, Xiticix Invasion, Australia, Warlords of Russia, Japan, Canada
-- and Triax 2 each reprint things the catalog already held, and each import
-- matched them by name and compared nothing. This is the comparison, with
-- Nate's rule of 2026-10-04 applied: the newest printing THAT STATES THE
-- FIGURE wins (scripts/books.json `published`).
--
-- Almost every held row cites the newer book and stands. What changes is of
-- three kinds, and each row's text says which:
--
--   1. The reprint states something the held row's book does not state at
--      all (two arrowheads, the C-14 bayonet,
--      the Centaur's swim and bow, the Xiticix Killer's numbers).
--   2. The held row DROPPED something its own book prints, found because
--      the reprint prints it too (vibro-blade and Dog Pack spike prices,
--      flare and gas figures, nine skills' bonuses and second percentages,
--      the Centaur's kick, the Ostrosaurus's percentages, three Psi-Stalker
--      abilities, the Psi-Stalkers' weapon issue).
--   3. The held row carried an older printing's text under a newer book's
--      citation, or misread its page (the Boom Gun's payload, the stun/flash
--      grenade against armor).
--
-- The crossbow pistol is the rule working against the reprint: Warlords of
-- Russia prints 1D4 S.D.C. for it, and Rifts Ultimate Edition's archery
-- table, the newer printing, prints 1D6 and a range, so RUE's go in.
--
-- Every figure was read off a page render by one reader and checked against
-- the render by another that did not write it. No slug or name changes.
-- Production held no saved character on the three classes (2026-10-04).
--
-- Each UPDATE is guarded on the value it replaces, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

-- ---------------------------------------------------------------- gear ----

UPDATE gear
   SET damage = 'Works like a neural mace; inflicts no other damage',
       payload = 'Rechargeable and reusable 1D6 times before breaking (Warlords of Russia printed 186)',
       description = 'A high-tech arrowhead that stuns like a neural mace: in effect a one-shot neural mace. Fits bows ancient and modern and crossbows; special arrowheads weigh 1 to 2 lbs. The price is Spirit West printed 203; the reuse figure is Warlords of Russia printed 186, the newer printing.'
 WHERE slug = 'arrowhead-neural-disrupter' AND payload IS NULL;

UPDATE gear
   SET damage = 'Normal S.D.C. arrow damage; transmits a tracking signal',
       description = 'A high-tech arrowhead carrying a tracking transmitter, good for 72 hours of constant transmission. There is a 1-32% chance of it falling off, rolled once every half hour. Fits bows ancient and modern and crossbows; special arrowheads weigh 1 to 2 lbs. The battery life, the chance of falling off and the arrow damage are Warlords of Russia printed 186, the newer printing; the price and range are Spirit West printed 203.'
 WHERE slug = 'arrowhead-tracer-bug' AND damage = 'None; transmits a tracking signal';

UPDATE gear
   SET damage = '1D6 S.D.C.',
       range = '120 feet (36.5 m)',
       description = 'A pistol crossbow. Damage and range are the W.P. Archery table of Rifts Ultimate Edition printed 326, the newest printing. Warlords of Russia printed 186 (1998) gives a typical crossbow pistol 1D4 S.D.C.; the price is Spirit West printed 203.'
 WHERE slug = 'crossbow-pistol' AND damage IS NULL;

UPDATE gear
   SET damage = 'Laser 3D6 M.D.; grenade 2D6 M.D. to a 12 foot (3.6 m) area; with the detachable bayonet Dog Boys add, vibro-knife 1D6 M.D. or vibro-sabre 2D4 M.D. (Lone Star printed 46)'
 WHERE slug = 'c-14-fire-breather-rifle'
   AND damage = 'Laser 3D6 M.D.; grenade 2D6 M.D. to a 12 foot (3.6 m) area';

UPDATE gear
   SET description = description || ' It burns for 60 seconds and lights an area roughly 150 feet (45.7 m) in diameter (Triax and the NGR printed 150).'
 WHERE slug = 'parachute-flare' AND instr(description, '60 seconds') = 0;

UPDATE gear
   SET description = description || ' The effects last 3D4 minutes; the cloud dissipates in about five minutes, or 1D4 minutes if windy.'
 WHERE slug = 'triax-tear-gas-grenade' AND instr(description, '3D4 minutes') = 0;

UPDATE gear
   SET description = 'A non-damaging grenade that blinds and disorients. Even those in armor are distracted for 1D4 seconds and lose initiative. This row said until ~094 that armour with light filters or goggles defeats it; Triax and the NGR printed 149, Coalition War Campaign printed 98 and Lone Star printed 47 all print the loss of initiative.'
 WHERE slug = 'stun-flash-grenade' AND instr(description, 'defeats it') > 0;

UPDATE gear SET cost = 7000, cost_note = '7,000 credits.'
 WHERE slug = 'vibro-knife' AND cost IS NULL;

UPDATE gear SET cost = 9000, cost_note = '9,000 credits.'
 WHERE slug = 'vibro-saber' AND cost IS NULL;

UPDATE gear SET cost = 11000, cost_note = '11,000 credits.'
 WHERE slug = 'vibro-sword' AND cost IS NULL;

UPDATE gear
   SET cost = 11000, cost_note = '11,000 credits.',
       description = 'Usually three hooked blades attached to a forearm gauntlet or protective plate. Great for parrying (+1 bonus) and slashing. Falls into the W.P. Knife category.',
       source_book = 'Rifts Ultimate Edition p.259'
 WHERE slug = 'vibro-claws' AND cost IS NULL AND source_book = 'Rifts Ultimate Edition';

UPDATE gear SET cost = 50, cost_note = 'Varies; 50 to 200 credits.'
 WHERE slug IN ('dog-pack-spikes-collars-arm-wrist-bands-other', 'dog-pack-spiked-gloves', 'dog-pack-spiked-kneepads')
   AND cost IS NULL;

UPDATE gear
   SET payload = '1000 round auto-feed canister; an extra ammo-drum of 400 rounds (30 M.D.C.) can hook to the hip',
       rate_of_fire = 'Each booming blast counts as one melee attack/action; bursts and sprays are not possible',
       description = description || ' Payload and rate of fire are Rifts Ultimate Edition printed 72. Until ~094 this row carried the original core book''s 100 rounds and 40-round drum under an RUE citation.',
       source_book = 'Rifts Ultimate Edition p.72'
 WHERE slug = 'boom-gun-glitter-boy-rail-gun'
   AND instr(payload, '100 rounds; a carrying drum of 40 rounds') = 1;

-- -------------------------------------------------------------- skills ----
-- Conditional bonuses and second percentages go in `note`; `bonuses` applies
-- unconditionally and none of these is unconditional.

UPDATE skills
   SET note = '40%/20%+4%. On horseback: +1 to parry or dodge, +1D4 S.D.C. damage, and a charge with a pole-arm or spear does +1D6 (Rifts Ultimate Edition printed 311).'
 WHERE name = 'Horsemanship: General' AND note IS NULL;

UPDATE skills
   SET note = '66%/50%+3%. +1 on initiative at levels 2, 5, 10 and 15; +2 to roll with fall or impact when knocked from a horse; +2 to parry, dodge and rope/ensnare/entangle on horseback; +1D4 damage; a charge attack does +2D6 S.D.C., or +1D6 M.D. with a Mega-Damage weapon (Rifts Ultimate Edition printed 311).'
 WHERE name = 'Horsemanship: Cowboy' AND note = '66%/50%+3%';

UPDATE skills
   SET note = '+1 to entangle at levels 1, 3, 5, 7, 9, 11 and 14. Cowboys and Saddle Tramps get +10% to the skill (Rifts Ultimate Edition printed 306).'
 WHERE name = 'Roping' AND note IS NULL;

UPDATE skills
   SET note = '-10% when breaking exotic and alien animals; wild bulls, broncos and other wild animals, and steer wrestling, all at -15% (Rifts Ultimate Edition printed 306).'
 WHERE name = 'Breaking/Taming Wild Horse' AND note IS NULL;

UPDATE skills
   SET note = 'Automatically gets Basic Mechanics at +20%; taken with Automotive Mechanics it gives +10% to that skill (Rifts Ultimate Edition printed 313).'
 WHERE name = 'Vehicle Armorer' AND note IS NULL;

UPDATE skills
   SET note = '+5% if the character also has Climbing (Rifts Ultimate Edition printed 330).'
 WHERE name = 'Spelunking' AND note IS NULL;

UPDATE skills
   SET note = 'Taking the skill twice gives +10% (Rifts Ultimate Edition printed 326).'
 WHERE name = 'Whittling & Sculpting' AND note IS NULL;

UPDATE skills
   SET note = '25%/30%+5% (Rifts Ultimate Edition printed 302). Palladium Fantasy: 25%, no per-level gain.',
       source_book = 'Rifts Ultimate Edition p.302'
 WHERE name = 'Brewing' AND source_book IS NULL AND instr(note, 'transcribed from memory') > 0;

UPDATE skills
   SET note = 'Automatically gets Basic Mechanics at 30% +5% per level (Rifts Ultimate Edition printed 315). Warlords of Russia printed 192, an older printing, gives Basic Mechanics at +20% instead.',
       source_book = 'Rifts Ultimate Edition p.315'
 WHERE name = 'Field Armorer & Munitions Expert' AND note IS NULL AND source_book IS NULL;

UPDATE skills
   SET note = 'General knowledge 25% +5% per level; recognize magic wards, runes and circles 15% +5%; recognize enchantment 10% +5%; identify a magic artifact at -15% for an unknown or alien item (Rifts Ultimate Edition printed 325, the newest printing).'
 WHERE name = 'Lore: Magic' AND note IS NULL;

UPDATE skills
   SET note = '+10% to I.D. Undercover Agents (Rifts Ultimate Edition printed 320).'
 WHERE name = 'Find Contraband' AND note IS NULL;

UPDATE skills
   SET note = '42%/36%+4%. +5% to Impersonation; imitating a specific person is at -20% (Rifts Ultimate Edition printed 321).'
 WHERE name = 'Imitate Voices & Sounds' AND note = '42%/36%+4%';

UPDATE skills
   SET note = '30%/16%+4%: a general type of personnel, or a specific individual. +10% to Undercover Ops (Rifts Ultimate Edition printed 309).'
 WHERE name = 'Impersonation' AND note = '30%/16%+4%';

UPDATE skills
   SET note = 'Includes light tanks. Tanks and APCs can be piloted, but at -15% and -1 attack per melee round (Rifts Ultimate Edition printed 319).'
 WHERE name = 'Tracked & Construction Vehicles' AND note IS NULL;

-- ----------------------------------------------------------- creatures ----

UPDATE creatures
   SET size = 'Approximately 9-10 feet (2.7 to 3 m)',
       skills_note = replace(skills_note, 'Skills of Note: all usually about 4th level - ', 'Skills of Note: all usually about 4th level (Lone Star printed 164, the newer printing: average 3rd to 5th level) - '),
       description = description || ' Size and average level follow Lone Star printed 164 (1997); Triax and the NGR printed 220-221 (1994) gives approximately 9 feet and about fourth level, and prints the rest of this row.'
 WHERE slug = 'brodkil' AND size = 'Approximately 9 feet (2.7 m)';

UPDATE creatures
   SET natural_abilities = 'Terrible swimmer (20%) but excellent climber (80%); tracks by scent 35%, and recognizes the scent of human blood at 60%; spots prey a mile off; runs 60 mph without tiring for six hours; leaps 15 ft high and 40 ft long, and a running leap above 40 mph (64 km) adds 30 feet (9 m).',
       description = description || ' Lone Star printed 163-164 prints quick stats for the same animal in the same year (1997) with different figures: M.D.C. 1D6x10+40, fixed attributes, +6 parry, +8 dodge, 80-100 F. The year rule cannot rank the two, and this row follows New West, which prints the full entry.'
 WHERE slug = 'ostrosaurus' AND instr(natural_abilities, 'farther with a running start') > 0;

UPDATE creatures
   SET natural_abilities = 'Fast runner with great stamina; leaps 5 ft high or 9 ft across, farther at a run. A kick with the front legs does 2D6 S.D.C. and a kick from the rear legs 4D6 S.D.C., or damage by weapon. Swims at 50% (Canada printed 102-103).',
       skills_note = skills_note || ' Canada printed 102-103 adds W.P. Bow and Arrow as an R.C.C. skill.',
       occ_note = occ_note || '. Standard equipment (Canada printed 103): as per O.C.C. plus one bow and arrows, a Vibro-Blade (often built into a spear), hunting knife, two water skins or canteens, saddlebag, backpack, bandoleer, utility belt, headband, one large sack and two small, and/or as per O.C.C.',
       description = description || ' Rifts Conversion Book One (revised 2002) is the newer printing and this row follows it. Canada (1999) printed 102-103 prints different attribute, S.D.C., skill and combat figures and calls itself an update of the original Conversion Book; only what Conversion Book One does not state at all is taken from it (the swim percentage, the bow proficiency and the equipment).'
 WHERE slug = 'centaurs' AND instr(natural_abilities, 'Kick') = 0 AND instr(natural_abilities, 'kick') = 0;

UPDATE creatures
   SET habitat = 'Xiticix territory in the northern woodlands, in the trees and on the hives. Of the 29,820 lab-made and released over seven years only about 7,200 are believed alive in the woodlands of Manitoba, with another 5,000-6,000 in Minnesota and a few hundred scattered elsewhere, plus an estimated 4,500 free born (Xiticix Invasion printed 88-92, the newer printing; Lone Star printed 92 gave the 7,200 alone).',
       enemies = 'The Xiticix, the only thing it hunts and the only thing it can feed on; it fights other creatures only in self-defense. Xiticix Invasion printed 110 adds that Psi-Stalkers are the only other beings a Killer will attack at the slightest provocation'
 WHERE slug = 'xiticix-killer' AND instr(habitat, 'Manitoba') = 0;

-- ------------------------------------------------------------- classes ----

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'a nexus point (4 miles) obliterates it entirely."',
         'a nexus point (4 miles) obliterates it entirely. He can sense ley lines or a nexus point from up to 10 miles (16 km) away, plus one mile (1.6 km) per level. When tracking a psychic scent, roll percentile dice every 1000 feet (305 m)."'),
         'but tastes foul (-1 on all combat bonuses for 1D6x10 minutes)."',
         'but tastes foul (-1 on all combat bonuses for 1D6x10 minutes). When he kills his prey, ALL the victim''s P.P.E. is doubled at the moment of death and expelled, and other Psi-Stalkers can absorb the extra from as far as 300 yards/meters away."'),
       updated_at = datetime('now')
 WHERE class_id = 'mutant-psi-stalker'
   AND instr(markdown, 'from up to 10 miles (16 km) away') = 0
   AND instr(markdown, 'a nexus point (4 miles) obliterates it entirely."') > 0
   AND instr(markdown, 'but tastes foul (-1 on all combat bonuses for 1D6x10 minutes)."') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         '  - { item_id: "bone-knife", qty: 1 }' || char(10) || 'restrictions:' || char(10),
         '  - { item_id: "bone-knife", qty: 1 }' || char(10) || '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "Weapons: one weapon for every W.P., plus 1D6+1 E-Clips (RUE p.155)."' || char(10)),
         'they can never achieve the same rank as true humans',
         'they can never achieve the same rank as true humans (Xiticix Invasion p.109: the best rank achievable is Command Sergeant Major, and few rise above Master Sergeant)'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-stalker'
   AND instr(markdown, 'weapons-matching-w-p-skills') = 0
   AND instr(markdown, '  - { item_id: "bone-knife", qty: 1 }' || char(10) || 'restrictions:' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "riding-horse", qty: 1 }' || char(10) || 'restrictions:' || char(10),
         '  - { item_id: "riding-horse", qty: 1 }' || char(10) || '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }' || char(10) || 'restrictions:' || char(10) || '  - "Weapons: one weapon for each W.P., plus 1D4+1 clips and a couple of knives and/or Vibro-Blades (RUE p.156)."' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker'
   AND instr(markdown, 'weapons-matching-w-p-skills') = 0
   AND instr(markdown, '  - { item_id: "riding-horse", qty: 1 }' || char(10) || 'restrictions:' || char(10)) > 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'fifteen gear rows carry what the reprints showed' AS assertion, count(*) AS got, 15 AS want
  FROM gear
 WHERE (slug = 'arrowhead-neural-disrupter' AND instr(payload, '1D6 times') > 0)
    OR (slug = 'arrowhead-tracer-bug' AND instr(damage, 'Normal S.D.C. arrow damage') = 1)
    OR (slug = 'crossbow-pistol' AND damage = '1D6 S.D.C.' AND range = '120 feet (36.5 m)')
    OR (slug = 'c-14-fire-breather-rifle' AND instr(damage, 'bayonet') > 0)
    OR (slug = 'parachute-flare' AND instr(description, '60 seconds') > 0)
    OR (slug = 'triax-tear-gas-grenade' AND instr(description, '3D4 minutes') > 0)
    OR (slug = 'stun-flash-grenade' AND instr(description, 'lose initiative') > 0)
    OR (slug = 'vibro-knife' AND cost = 7000)
    OR (slug = 'vibro-saber' AND cost = 9000)
    OR (slug = 'vibro-sword' AND cost = 11000)
    OR (slug = 'vibro-claws' AND cost = 11000 AND instr(description, '(+1 bonus)') > 0)
    OR (slug IN ('dog-pack-spikes-collars-arm-wrist-bands-other', 'dog-pack-spiked-gloves', 'dog-pack-spiked-kneepads') AND cost = 50)
    OR (slug = 'boom-gun-glitter-boy-rail-gun' AND instr(payload, '1000 round') = 1);

SELECT 'fourteen skills carry a note' AS assertion, count(*) AS got, 14 AS want
  FROM skills
 WHERE name IN ('Horsemanship: General', 'Horsemanship: Cowboy', 'Roping', 'Breaking/Taming Wild Horse', 'Vehicle Armorer', 'Spelunking', 'Whittling & Sculpting', 'Brewing', 'Field Armorer & Munitions Expert', 'Lore: Magic', 'Find Contraband', 'Imitate Voices & Sounds', 'Impersonation', 'Tracked & Construction Vehicles')
   AND instr(note, 'Rifts Ultimate Edition printed') > 0;

SELECT 'four creatures carry the reprint''s additions' AS assertion, count(*) AS got, 4 AS want
  FROM creatures
 WHERE (slug = 'brodkil' AND size = 'Approximately 9-10 feet (2.7 to 3 m)' AND instr(skills_note, '3rd to 5th level') > 0)
    OR (slug = 'ostrosaurus' AND instr(natural_abilities, 'climber (80%)') > 0)
    OR (slug = 'centaurs' AND instr(natural_abilities, '4D6 S.D.C.') > 0)
    OR (slug = 'xiticix-killer' AND instr(habitat, 'Manitoba') > 0);

SELECT 'three Psi-Stalker classes carry what RUE prints' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'mutant-psi-stalker' AND instr(markdown, 'from up to 10 miles (16 km) away') > 0 AND instr(markdown, 'doubled at the moment of death') > 0)
    OR (class_id = 'psi-stalker' AND instr(markdown, 'weapons-matching-w-p-skills') > 0 AND instr(markdown, 'Command Sergeant Major') > 0)
    OR (class_id = 'wild-psi-stalker' AND instr(markdown, 'weapons-matching-w-p-skills') > 0);

INSERT INTO data_script_runs (filename) VALUES ('~094-reprints-compared-with-their-held-rows.sql');
