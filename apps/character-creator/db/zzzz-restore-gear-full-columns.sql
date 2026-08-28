-- The twelve gear columns restore-gear-missing-from-repo.sql does not carry
-- (REBUILD-AUDIT.md F5, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-gear-full-columns.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-gear-full-columns.sql
--
-- WHAT HAPPENED. restore-gear-missing-from-repo.sql brought back 58 gear rows
-- that existed only in production, with an INSERT carrying
-- (slug, name, system, category, description, source_book) - SIX of the
-- table's EIGHTEEN columns. It restores that a row EXISTS. It does not restore
-- what the row IS.
--
-- So a database built from this repo had 53 of those rows carrying the right
-- name and the right prose and nothing else: no price, no weight, no damage,
-- no range, no payload, no rate of fire, and no mega-damage flag. **Twenty-four
-- weapons that are mega-damage in production came out S.D.C.** - the Boom Gun,
-- the C-40R SAMAS rail gun, the JA-11, the L-20 pulse rifle. A rebuilt database
-- served every one of them as an ordinary firearm.
--
-- WHY NOTHING CAUGHT IT. The export was verified by a name-level diff, and
-- repo-vs-live.mjs compared names until PR #377. Every name matched, every
-- count matched, and drift-check reported NO DRIFT, because none of them was
-- asking what the rows CONTAINED. Measured 2026-08-28: 193 field values across
-- 53 rows, every one of them a column this export drops.
--
-- THE VALUES ARE PRODUCTION'S, exported column for column from --remote rather
-- than transcribed. The slug list was read out of restore-gear-missing-from-
-- repo.sql itself, not retyped: this repo has already put `ng-15-` into a class
-- definition where the real slug was `ng-l5-`. Only the columns that actually
-- DIFFER are set - the finding said "all 18 columns", and emitting 53 UPDATEs
-- that each rewrite an unchanged multi-kilobyte description would make this
-- file unreviewable to change nothing. The effect is identical.
--
-- `leather-armor` is in the restore script's list and in NEITHER database:
-- retire-leather-armor-placeholder.sql removes it in both. Correctly absent
-- here rather than silently skipped.
--
-- FILENAME SORTS LAST ON PURPOSE. This must run after
-- zzz-gear-tidy-2-stub-stats.sql, which rewrites the very columns it sets, and
-- after the zzzz-cite-* files, which rewrite source_book on gear rows. `zzzz-r`
-- sorts after `zzzz-c`, and after zzzz-resolve-* ('o' < 't').
--
-- Every statement targets one slug and sets absolute values, so it is safe to
-- re-run and safe to run early: on production every value below is already the
-- value in the row, which is why applying it there changes nothing.

-- Bio-Comp System
UPDATE gear SET
      cost = 2500
  WHERE slug = 'bio-comp-system';

-- Optic Helmet
UPDATE gear SET
      cost = 2800
  WHERE slug = 'optic-helmet';

-- Portable IRMSS Kit
UPDATE gear SET
      cost = 42000
  WHERE slug = 'portable-irmss-kit';

-- Grey Fatigues
UPDATE gear SET
      cost = 40
  WHERE slug = 'grey-fatigues';

-- Boots with Knife Holster
UPDATE gear SET
      cost = 60
  WHERE slug = 'boots-with-knife-holster';

-- Gloves
UPDATE gear SET
      system = 'both',
      cost = 15
  WHERE slug = 'gloves';

-- Utility Belt
UPDATE gear SET
      weight_lbs = 1.8,
      cost = 3
  WHERE slug = 'utility-belt';

-- Sunglasses
UPDATE gear SET
      weight_lbs = 0.13,
      cost = 15
  WHERE slug = 'sunglasses';

-- Canteen
UPDATE gear SET
      weight_lbs = 0.16,
      cost = 20
  WHERE slug = 'canteen';

-- Compass
UPDATE gear SET
      cost = 50
  WHERE slug = 'compass';

-- E-Clip
UPDATE gear SET
      weight_lbs = 0.16,
      cost = 5000
  WHERE slug = 'e-clip';

-- A.T.V. Speedster Hover Cycle
UPDATE gear SET
      weight_lbs = 700,
      cost = 98000,
      mdc = 75
  WHERE slug = 'a-t-v-speedster-hover-cycle';

-- Binoculars
UPDATE gear SET
      weight_lbs = 2,
      cost = 400
  WHERE slug = 'binoculars';

-- Boom Gun (Glitter Boy Rail Gun)
UPDATE gear SET
      weight_lbs = 867,
      damage = 'One Boom Gun Flechette round holds 200 slugs that inflict 3D6x10 M.D.',
      is_mega_damage = 1,
      range = '11,000 feet (about two miles/3.2 km)',
      payload = '100 rounds; a carrying drum of 40 rounds (30 M.D.C.) can attach to the hip/waist or left forearm',
      rate_of_fire = 'Equal to number of combined hand to hand attacks of the pilot and his power armor (usually 4-6); bursts and sprays are not possible'
  WHERE slug = 'boom-gun-glitter-boy-rail-gun';

-- C-40R Coalition SAMAS Rail Gun
UPDATE gear SET
      weight_lbs = 92,
      cost = 110000,
      damage = 'A burst is 40 rounds and inflicts 1D4x10 M.D., one round does 1D4 M.D.',
      is_mega_damage = 1,
      range = '4000 feet (1200 m)',
      payload = 'As a machinegun: 400 round belt.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'c-40r-coalition-samas-rail-gun';

-- Dog Pack Spiked Gloves
UPDATE gear SET
      damage = '1D6+1 S.D.C. added to punches'
  WHERE slug = 'dog-pack-spiked-gloves';

-- Dog Pack Spiked Kneepads
UPDATE gear SET
      damage = '1D6 S.D.C. added to knee kicks'
  WHERE slug = 'dog-pack-spiked-kneepads';

-- Dog Pack Spikes (collars, arm/wrist bands, other)
UPDATE gear SET
      damage = '1D4 S.D.C.'
  WHERE slug = 'dog-pack-spikes-collars-arm-wrist-bands-other';

-- Hooded Cloak
UPDATE gear SET
      cost = 40
  WHERE slug = 'hooded-cloak';

-- JA-11 Juicer Assassin's Energy Rifle
UPDATE gear SET
      weight_lbs = 6,
      cost = 40000,
      damage = 'Laser has two settings: 2D6 M.D. and 4D6 M.D., both work on different light frequencies too. The ion beam does 3D6 M.D.',
      is_mega_damage = 1,
      range = 'Laser: 4000 feet (1200 m), Ion Beam: 1600 feet (488 m), S.D.C. 7.62mm round: 2000 feet (610 m).',
      payload = 'Short clip 10 shots, Long clip 30 shots. Canister Cell: Adds 30 shots. 7.65mm round: One loaded in weapon, others to be added.',
      rate_of_fire = 'The laser is meant to be a precision sniper/assassin weapon and as such, can only be fired as an aimed shot. Total shots are equal to the total number of hand to hand attacks per melee. It can not fire bursts. Ion beam: Aimed, burst, or wild as standard. The 7.62mm round can be loaded and fired once for every two hand to hand attacks per melee.'
  WHERE slug = 'ja-11-juicer-assassin-s-energy-rifle';

-- JA-9 Juicer Assassin Variable Laser Rifle
UPDATE gear SET
      weight_lbs = 6,
      cost = 20000,
      damage = '2D6 M.D.',
      is_mega_damage = 1,
      range = '4000 feet (1200 m)',
      payload = '10 shot with a short E-Clip or 30 with a long E-Clip.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ja-9-juicer-assassin-variable-laser-rifle';

-- Knapsack
UPDATE gear SET
      weight_lbs = 4,
      cost = 50,
      cost_note = '50-100 cr.'
  WHERE slug = 'knapsack';

-- L-20 Pulse Rifle
UPDATE gear SET
      weight_lbs = 7,
      cost = 25000,
      damage = '2D6 M.D. single shot, or 6D6 multiple pulse burst (three simultaneous shots).',
      is_mega_damage = 1,
      range = '1600 feet (488 m)',
      payload = '40 shots short E-Clip or 50 shots long E-Clip.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'l-20-pulse-rifle';

-- Large Sack
UPDATE gear SET
      weight_lbs = 0.44,
      cost = 2
  WHERE slug = 'large-sack';

-- Modified NG-101 Rail Gun and Mini-Missile Launchers
UPDATE gear SET
      damage = 'Rail Guns: 6D6 M.D. per 30 round burst from one rail gun, or 2D4x10 M.D. per double burst (both rail guns firing at the same target simultaneously); Mini-Missiles: varies with missile type (fragmentation 5D6 M.D., plasma 1D6x10 M.D.)',
      is_mega_damage = 1,
      range = 'About one mile',
      payload = 'Mini-Missiles: twelve (6 in each side); Rail Guns: 600 rounds each, that''s 20 bursts each',
      rate_of_fire = 'Missiles: One at a time or in volleys of two. Rail Gun is standard.'
  WHERE slug = 'modified-ng-101-rail-gun-and-mini-missile-launchers';

-- Neural Mace
UPDATE gear SET
      damage = '1D8 S.D.C. plus P.S. attribute bonus'
  WHERE slug = 'neural-mace';

-- NG-101 Forward Mounted Heavy Laser
UPDATE gear SET
      damage = '4D6 M.D. per blast',
      is_mega_damage = 1,
      range = '4000 feet (1200 m)',
      payload = 'Effectively unlimited',
      rate_of_fire = 'The pilot can operate all weapon systems at a rate equal to the combined number of hand to hand attacks per melee (usually 4 to 6)'
  WHERE slug = 'ng-101-forward-mounted-heavy-laser';

-- NG-101 Rail Gun
UPDATE gear SET
      weight_lbs = 128,
      cost = 55000,
      damage = 'A Burst is 30 rounds and inflicts 6D6 M.D., one round does 1D4 M.D.',
      is_mega_damage = 1,
      range = '4000 feet (1200 m)',
      payload = 'As a machinegun: 300 round belt.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ng-101-rail-gun';

-- NG-202 Rail Gun
UPDATE gear SET
      weight_lbs = 198,
      cost = 70000,
      damage = 'A Burst is 40 rounds and inflicts 1D4x10 M.D. One round does 1D4 M.D.',
      is_mega_damage = 1,
      range = '4000 feet (1200 m)',
      payload = 'As a machine gun: 300 round belt.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ng-202-rail-gun';

-- NG-33 Northern Gun Laser Pistol
UPDATE gear SET
      weight_lbs = 4,
      cost = 6500,
      damage = '1D6 M.D.',
      is_mega_damage = 1,
      range = '800 feet (244 m)',
      payload = '20 shots',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ng-33-northern-gun-laser-pistol';

-- NG-57 Northern Gun Heavy-Duty Ion Blaster
UPDATE gear SET
      weight_lbs = 5,
      cost = 8000,
      damage = 'Two settings, 2D4 or 3D6 M.D.',
      is_mega_damage = 1,
      range = '500 feet (152 m)',
      payload = '10 shots',
      rate_of_fire = 'Standard'
  WHERE slug = 'ng-57-northern-gun-heavy-duty-ion-blaster';

-- NG-L5 Northern Gun Laser Rifle
UPDATE gear SET
      weight_lbs = 14,
      cost = 16000,
      damage = '3D6 M.D.',
      is_mega_damage = 1,
      range = '1600 feet (488 m)',
      payload = '10 shots standard clip or 20 shots long E-Clip.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ng-l5-northern-gun-laser-rifle';

-- NG-P7 Northern Gun Particle Beam Rifle
UPDATE gear SET
      weight_lbs = 21,
      cost = 22000,
      damage = '1D4x10 M.D.',
      is_mega_damage = 1,
      range = '1200 feet (365 m)',
      payload = '8 shots.',
      rate_of_fire = 'Standard, see Modern Weapon Proficiency Section.'
  WHERE slug = 'ng-p7-northern-gun-particle-beam-rifle';

-- NG-Super Laser Pistol and Grenade Launcher
UPDATE gear SET
      weight_lbs = 13,
      damage = 'Laser 2D4 M.D., grenade launcher 2D6 M.D. to a blast area of six feet (1.8 m)',
      is_mega_damage = 1,
      range = 'Laser is 800 feet (224 m); Grenade Launcher is 500 feet (152 m)',
      payload = 'Laser is 20 blasts; Grenade Launcher is a standard six hand loaded into the gun plus an additional eight in a top feeding grenade clip',
      rate_of_fire = 'Laser standard; grenades one aimed, four fired in rapid succession (burst if all at same target, wild if sprayed into an area)'
  WHERE slug = 'ng-super-laser-pistol-and-grenade-launcher';

-- Northern Gun Sky King
UPDATE gear SET
      weight_lbs = 2600,
      cost = 1500000,
      mdc = 130
  WHERE slug = 'northern-gun-sky-king';

-- Small Sack
UPDATE gear SET
      weight_lbs = 0.44,
      cost = 2
  WHERE slug = 'small-sack';

-- Survival Knife
UPDATE gear SET
      weight_lbs = 1.2,
      cost = 120,
      damage = '1D6'
  WHERE slug = 'survival-knife';

-- The Big Boss A.T.V.
UPDATE gear SET
      weight_lbs = 2000,
      cost = 24000,
      mdc = 65
  WHERE slug = 'the-big-boss-a-t-v';

-- The Highway-Man Motorcycle
UPDATE gear SET
      weight_lbs = 240,
      cost = 24000,
      damage = 'Laser: 1D6 M.D.; Machinegun: 1D4 M.D. per burst of 50 rounds',
      is_mega_damage = 1,
      range = 'Laser: 1200 feet (366 m); Machinegun: 2000 feet (610 m)',
      payload = 'Laser: 20 shots; Machinegun: 600 rounds (12 bursts)',
      mdc = 75
  WHERE slug = 'the-highway-man-motorcycle';

-- The Mountaineer A.T.V.
UPDATE gear SET
      weight_lbs = 12000,
      cost = 64000,
      mdc = 140
  WHERE slug = 'the-mountaineer-a-t-v';

-- The Wastelander Motorcycle
UPDATE gear SET
      weight_lbs = 800,
      cost = 18000,
      mdc = 45
  WHERE slug = 'the-wastelander-motorcycle';

-- Traveling Clothes
UPDATE gear SET
      cost = 40
  WHERE slug = 'traveling-clothes';

-- Vibro-Claws
UPDATE gear SET
      damage = '2D6 M.D.',
      is_mega_damage = 1
  WHERE slug = 'vibro-claws';

-- Vibro-Knife
UPDATE gear SET
      damage = '1D6 M.D.',
      is_mega_damage = 1
  WHERE slug = 'vibro-knife';

-- Vibro-Saber
UPDATE gear SET
      damage = '2D4 M.D.',
      is_mega_damage = 1
  WHERE slug = 'vibro-saber';

-- Vibro-Sword
UPDATE gear SET
      damage = '2D6 M.D.',
      is_mega_damage = 1
  WHERE slug = 'vibro-sword';

-- Wilk's 320 Laser Pistol
UPDATE gear SET
      weight_lbs = 2,
      cost = 11000,
      damage = '1D6 M.D.',
      is_mega_damage = 1,
      range = '1000 feet (305 m)',
      payload = '20 shots',
      rate_of_fire = 'Standard'
  WHERE slug = 'wilk-s-320-laser-pistol';

-- Wilk's 447 Laser Rifle
UPDATE gear SET
      weight_lbs = 5,
      cost = 18000,
      damage = '3D6 M.D.',
      is_mega_damage = 1,
      range = '2000 feet (610 m)',
      payload = '20 shots standard clip, can not use a long E-Clip',
      rate_of_fire = 'Standard'
  WHERE slug = 'wilk-s-447-laser-rifle';

-- Wilk's Jet Pack
UPDATE gear SET
      weight_lbs = 45,
      cost = 38000,
      mdc = 20
  WHERE slug = 'wilk-s-jet-pack';

-- Wilk's Laser Scalpel
UPDATE gear SET
      cost = 2500,
      damage = 'Under 1 S.D.C. point on lowest settings, up to 1D6 S.D.C.',
      range = 'six inches'
  WHERE slug = 'wilk-s-laser-scalpel';

-- Wilk's Laser Wand (tool)
UPDATE gear SET
      weight_lbs = 0.125,
      cost = 2000,
      damage = 'One M.D. point; S.D.C. settings: 1D4, 1D6, 2D6, or 3D6 S.D.C.',
      is_mega_damage = 1,
      range = '10 feet (3 m)',
      payload = '50 shots',
      rate_of_fire = 'Standard'
  WHERE slug = 'wilk-s-laser-wand-tool';

-- Wilk's Portable Laser Torch (tool)
UPDATE gear SET
      weight_lbs = 1,
      cost = 7000,
      damage = '1D4, 1D6, 2D4, 3D6, and 4D6 M.D.; S.D.C. settings: 1D6, 3D6, 6D6, 1D6x10 S.D.C.',
      is_mega_damage = 1,
      range = '10 feet (3 m)',
      payload = '100 shots or about two hours of continuous use per pair of E-Clips',
      rate_of_fire = 'Standard'
  WHERE slug = 'wilk-s-portable-laser-torch-tool';

-- Cyber Armor
UPDATE gear SET
      is_mega_damage = 1,
      ar = 16,
      mdc = 50
  WHERE slug = 'cyber-armor';

-- Reads the result back rather than trusting the exit code.
--   boom_gun_is_mdc          1 = the emblematic case. It was 0 in a rebuild.
--   boom_gun_weight        867 = pounds. It was NULL.
--   mega_damage_rows        76 = EQUAL TO PRODUCTION. A rebuild had 52; all
--                          twenty-four of the missing flags were on rows this
--                          script corrects, so this one reaches parity exactly.
--   rows_still_missing_cost
--                          115 = down from 155. Production holds 105: the
--                          remaining TEN are gear rows this script does not
--                          touch, priced through the catalog editor on rows no
--                          restore-* script created. Stated rather than rounded
--                          off, because a number that looks like parity and is
--                          not is worse than an honest gap. Those ten are still
--                          open in REBUILD-AUDIT.md F6.
SELECT (SELECT is_mega_damage FROM gear WHERE slug = 'boom-gun-glitter-boy-rail-gun') AS boom_gun_is_mdc,
       (SELECT weight_lbs FROM gear WHERE slug = 'boom-gun-glitter-boy-rail-gun') AS boom_gun_weight,
       (SELECT count(*) FROM gear WHERE is_mega_damage = 1) AS mega_damage_rows,
       (SELECT count(*) FROM gear WHERE cost IS NULL) AS rows_still_missing_cost;

-- Records this run. One row per run rather than per file: the statements above
-- set absolute values, so this script is safe to re-run, and a run that
-- correctly changed nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-gear-full-columns.sql');
