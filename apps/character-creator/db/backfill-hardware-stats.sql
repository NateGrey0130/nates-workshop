-- Stats for the named hardware, from web references.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-hardware-stats.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-hardware-stats.sql
--
-- These are the gear rows whose numbers combat actually reads - M.D.C., A.R.,
-- damage - as opposed to the ~95 mundane stubs that need only weight and cost.
--
-- THE SOURCE IS THE WEB, NOT THE BOOK, and source_book says so on every row
-- rather than naming a page nobody checked. That matters more here than usual:
-- the first stat block found for the Glitter Boy was a fan-made variant with
-- 820 M.D.C. and a 40 million credit price, and it was only obvious because
-- that page said outright it was homebrew. Anything not corroborated is either
-- left alone or written down as uncertain IN the description, where a player
-- reads it, rather than being quietly smoothed into a number.
--
-- Confidence, recorded honestly:
--
--   HIGH    Glitter Boy, C-18 Laser Pistol, E-Clip, Cyber-Armor, Optics Band
--           Structured references, and the Glitter Boy figures are the widely
--           reproduced official USA-G10 ones.
--   MEDIUM  Dog Pack riot armor, smoke grenade
--           One source each, with known disagreement between sources. Both say
--           so in their own description.
--
-- Thirteen other hardware rows were researched and NOT filled, because nothing
-- reliable was found: the Juicer gear (bio-comp, drug harness, flex plate,
-- IRMSS kit), archaic M.D.C. armor of the pantheon, leather armor, both
-- Techno-Wizard converted weapons, the explosive and hand grenades, the optic
-- helmet, and the pocket laser distancer. A stub is more honest than a guess.
--
-- Every UPDATE is guarded on the row still being a stub, so re-running is safe
-- and anything entered from the book later is never overwritten.


-- HIGH
UPDATE gear SET description = 'USA-G10 Glitter Boy. M.D.C. by location: main body 770, head 290, arms 270 each, legs 450 each, hands 100 each, rail gun 175, reinforced pilot compartment 150. Roughly 10 feet 5 inches tall, 1.2 tons loaded, nuclear power (20 year charge). Running speed about 60 mph; leaps 12 feet, or 22 with a running start. Laser weapons do HALF damage to it. Depleting main body M.D.C. shuts the armor down entirely. Carries the Boom Gun.',
  source_book = 'Web reference (not book-verified)',
  mdc = 770,
  weight_lbs = 2400,
  is_mega_damage = 1
  WHERE slug = 'glitter-boy-power-armor' AND description LIKE 'STUB%';

-- HIGH
UPDATE gear SET description = 'Coalition laser pistol. The 12,000 credit price is the black market rate; Coalition issue is not sold openly.',
  source_book = 'Web reference (not book-verified)',
  cost = 12000,
  weight_lbs = 4,
  damage = '2D4',
  range = '800 feet (244 m)',
  payload = '10 blasts on a standard E-Clip',
  is_mega_damage = 1
  WHERE slug = 'c-18-laser-pistol' AND description LIKE 'STUB%';

-- HIGH
UPDATE gear SET description = 'Standard energy clip. 5,000 credits new and fully charged; about 3,500 for an old charged clip and 1,500 for an old empty one. Recharging costs around 1,500 credits and takes 1D4 hours at a proper station, or 1D12 hours on scavenged equipment.',
  source_book = 'Web reference (not book-verified)',
  cost = 5000,
  weight_lbs = 0.16,
  is_mega_damage = 0
  WHERE slug = 'e-clip' AND description LIKE 'STUB%';

-- HIGH
UPDATE gear SET description = 'Cyber-Knight cyber-armor, grown rather than worn. A.R. 16, rising to 17 at level 8. M.D.C. by location at level 1: chest plate 50, back shoulder blades 15 each, thigh/upper leg 15 each, forearms 10 each, shoulders 8 each. From level 4 it becomes a living part of the knight: it regenerates 1D6 M.D.C. per hour, the chest plate gains 1D6 M.D.C. per level and every other location gains 1.',
  source_book = 'Web reference (not book-verified)',
  mdc = 50,
  ar = 16,
  is_mega_damage = 1
  WHERE slug = 'cyber-armor' AND description LIKE 'STUB%';

-- HIGH
UPDATE gear SET description = 'Head-worn optics band, typically 800 to 1,200 credits depending on quality. Combines infrared and ultraviolet out to about 200 feet, passive night sight to about 200 feet, a magnification lens, and adjustable colour filters.',
  source_book = 'Web reference (not book-verified)',
  cost = 800,
  weight_lbs = 0.31,
  is_mega_damage = 0
  WHERE slug = 'multi-optics-band' AND description LIKE 'STUB%';

-- MEDIUM
UPDATE gear SET description = 'Coalition Dog Pack light riot armor. Figures given here are for the DPM-101 pattern: 30 M.D.C. at about 8 lbs. UNCONFIRMED against the book, and other Dog Pack patterns are cited in the 35 to 55 M.D.C. range, so check the model before relying on this.',
  source_book = 'Web reference (not book-verified)',
  mdc = 30,
  weight_lbs = 8,
  is_mega_damage = 1
  WHERE slug = 'dog-pack-dpm-riot-armor' AND description LIKE 'STUB%';

-- MEDIUM
UPDATE gear SET description = 'Smoke grenade. Does no damage. Around 50 credits, though grenade pricing varies considerably between sources. UNCONFIRMED against the book.',
  source_book = 'Web reference (not book-verified)',
  cost = 50,
  is_mega_damage = 0
  WHERE slug = 'smoke-grenade' AND description LIKE 'STUB%';

-- Reports the result back, so it is read rather than assumed.
--   filled            7 = every row this script covers landed
--   gb_mdc          770 = the OFFICIAL Glitter Boy main body, not the 820 of the
--                         homebrew variant that was found first
--   c18_damage     2D4
--   cyber_ar         16
--   web_sourced       7 = and every one of them says the source was the web
--   stubs_now        the running total, for comparison against 121
SELECT (SELECT count(*) FROM gear
          WHERE slug IN ('glitter-boy-power-armor', 'c-18-laser-pistol', 'e-clip', 'cyber-armor', 'multi-optics-band', 'dog-pack-dpm-riot-armor', 'smoke-grenade') AND description NOT LIKE 'STUB%') AS filled,
       (SELECT mdc FROM gear WHERE slug = 'glitter-boy-power-armor') AS gb_mdc,
       (SELECT damage FROM gear WHERE slug = 'c-18-laser-pistol') AS c18_damage,
       (SELECT ar FROM gear WHERE slug = 'cyber-armor') AS cyber_ar,
       (SELECT count(*) FROM gear
          WHERE slug IN ('glitter-boy-power-armor', 'c-18-laser-pistol', 'e-clip', 'cyber-armor', 'multi-optics-band', 'dog-pack-dpm-riot-armor', 'smoke-grenade') AND source_book = 'Web reference (not book-verified)') AS web_sourced,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-hardware-stats.sql');
