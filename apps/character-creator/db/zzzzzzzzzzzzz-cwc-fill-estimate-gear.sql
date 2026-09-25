-- Rifts World Book 11: Coalition War Campaign prices five rows the catalog
-- held only as estimates or web references. This fills them from the book.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzz-cwc-fill-estimate-gear.sql
--
--   c-14-fire-breather-rifle   Juicer Uprising named it without stats; stub
--   c-27-heavy-plasma-cannon   rows, turned into empty estimates by
--                              zzz-gear-tidy-2-stub-stats.sql. CWC prints both
--                              (printed 91-93). The C-27 keeps its catalog
--                              name; CWC heads it "Light" Plasma Cannon, and
--                              the description says so.
--   explosive-grenade          estimate rows with no damage; CWC prints the
--   fragmentation-grenade      CS hand grenades on printed 98. The explosive
--                              row takes the light high explosive grenade and
--                              names the heavy one in its description.
--   smoke-grenade              a web-reference row; CWC prints it on 98.
--
-- THE NAME SORTS LAST ON PURPOSE. zzz-gear-tidy-2-stub-stats.sql,
-- zzz-gear-tidy-3-categories.sql, backfill-hardware-stats.sql and
-- zzzzzzzzzzzz-dupes-pass-cross-system-gear.sql all write these slugs, and a
-- clean rebuild applies the directory as one sorted glob. This file sorts
-- after all four (checked 2026-09-25 with the sort in class-import).
--
-- Each UPDATE is guarded on the row still carrying its old provenance, so a
-- re-run is a no-op. Numbers were read off 200 dpi renders; the text layer
-- carries this book's digit cipher (`6Q.6` for 6D6).

UPDATE gear SET
  name = 'C-14 Fire Breather Assault Rifle',
  category = 'weapon',
  weight_lbs = 10,
  cost = 30000,
  cost_note = 'Black Market cost 30,000 credits; a hot commodity, not commonly available. Grenades 550 credits each or 4,500 a dozen.',
  damage = 'Laser 3D6 M.D.; grenade 2D6 M.D. to a 12 foot (3.6 m) area',
  is_mega_damage = 1,
  range = 'Laser 2000 feet (610 m); grenade launcher 1200 feet (365 m)',
  payload = 'Laser 20 blasts; grenade launcher 12. An E-Clip canister cannot be fitted',
  rate_of_fire = 'Laser equal to the user''s hand to hand attacks (usually 3-6); grenades one aimed per attack or four in rapid succession',
  description = 'The older Coalition over-and-under assault weapon: a laser rifle with a pump-action grenade launcher under the barrel, being replaced by the CP-50 "Dragonfire". Reloading the launcher takes a full melee round (15 seconds); an E-Clip about 5 seconds.',
  source_book = 'Rifts World Book 11: Coalition War Campaign p.91-92'
 WHERE slug = 'c-14-fire-breather-rifle' AND source_book = 'Estimate - no published price found';

UPDATE gear SET
  category = 'weapon',
  weight_lbs = 12,
  cost = 32000,
  cost_note = 'Black Market cost 32,000 credits for the rifle; it takes only an E-Clip Canister, 10,000 credits new and loaded, 2,000 to recharge.',
  damage = '6D6 M.D.',
  is_mega_damage = 1,
  range = '1600 feet (the book prints 488 km)',
  payload = '10 blasts per energy canister, hooked under the weapon',
  rate_of_fire = 'Equal to the user''s attacks per melee; each blast is one attack',
  description = 'The older Coalition plasma cannon, headed "Light" Plasma Cannon in Coalition War Campaign because the C-29 now outclasses it; still effective against armored infantry and light vehicles. Targeting scope: +1 to strike on an aimed shot.',
  source_book = 'Rifts World Book 11: Coalition War Campaign p.93'
 WHERE slug = 'c-27-heavy-plasma-cannon' AND source_book = 'Estimate - no published price found';

UPDATE gear SET
  cost = 200,
  cost_note = 'Black Market cost 200 credits (light high explosive); the heavy high explosive grenade is 275.',
  damage = '3D6 M.D. to a 6 foot (1.8 m) area',
  is_mega_damage = 1,
  range = 'About 40 yards (36.6 m) thrown',
  description = 'The Coalition light high explosive hand grenade. The heavy version does 4D6 M.D. to the same 6 foot (1.8 m) area and costs 275 credits.',
  source_book = 'Rifts World Book 11: Coalition War Campaign p.98'
 WHERE slug = 'explosive-grenade' AND source_book = 'Estimate - no published price found';

UPDATE gear SET
  cost = 250,
  cost_note = 'Black Market cost 250 credits.',
  damage = '2D6 M.D. to a 20 foot (6 m) area',
  is_mega_damage = 1,
  range = 'About 40 yards (36.6 m) thrown',
  description = 'The Coalition fragmentation hand grenade, thrown for area effect against soft targets.',
  source_book = 'Rifts World Book 11: Coalition War Campaign p.98'
 WHERE slug = 'fragmentation-grenade' AND source_book = 'Estimate - no published price found';

UPDATE gear SET
  cost = 50,
  cost_note = 'Black Market cost 50 credits.',
  damage = 'None',
  is_mega_damage = 0,
  range = 'About 40 yards (36.6 m) thrown; the cloud fills a 20-40 foot (6-12 m) radius',
  description = 'A smoke grenade whose cloud blocks sight and infrared. Anyone inside without protection is -5 to strike, parry and dodge and -1 on initiative, and shots fired through it are wild. Passive nightvision still works inside the cloud.',
  source_book = 'Rifts World Book 11: Coalition War Campaign p.98'
 WHERE slug = 'smoke-grenade' AND source_book = 'Web reference (not book-verified)';

-- Read the result back.
SELECT 'all five rows now cite Coalition War Campaign' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE slug IN ('c-14-fire-breather-rifle', 'c-27-heavy-plasma-cannon', 'explosive-grenade', 'fragmentation-grenade', 'smoke-grenade')
   AND source_book LIKE 'Rifts World Book 11: Coalition War Campaign p.%';
SELECT 'and every one has a damage line' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE slug IN ('c-14-fire-breather-rifle', 'c-27-heavy-plasma-cannon', 'explosive-grenade', 'fragmentation-grenade', 'smoke-grenade')
   AND damage IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-cwc-fill-estimate-gear.sql');
