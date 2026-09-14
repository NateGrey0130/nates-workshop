-- Heroes Unlimited's oriental, exotic and ninja equipment, printed 195-198.
-- Forty rows, plus one correction to a row imported from the table on 194.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-b-oriental-and-ninja.sql
--
-- A DIFFERENT SHAPE FROM 193-194. Those two pages are a TABLE and the OCR of
-- them is unreliable - it dropped a whole row. These four are PROSE, each entry
-- a heading followed by `Cost:` and `Damage:` markers, and the cache reads them
-- well. All four pages were still rendered and read: `Katar` reads "|D6" in the
-- cache and printed 198 at 210 dpi says 1D6.
--
-- ===================================================================
-- THE BOOK CONTRADICTS ITSELF, AND THE DESCRIPTION WINS
-- ===================================================================
--
-- `Bo Staff` is priced TWICE and differently:
--
--   printed 194, the ANCIENT WEAPONS table   $140
--   printed 195, the description             $120
--
-- Both are this one book. Nate's rule, 2026-09-14: THE DESCRIPTION WINS - it is
-- the more specific text and the table is a summary of it. The row imported
-- from the table in add-hu-gear-a-ancient-weapons.sql is corrected below rather
-- than a second row being added, because it is one weapon.
--
-- The damage notations do NOT conflict, and it is worth saying so explicitly so
-- nobody "fixes" one into the other: the table writes ranges (`1-8`) and the
-- descriptions write dice (`1D8`). Those are the same thing. Each is kept in
-- the notation its own page uses.
--
-- `Nunchaku` is the other row printed in both places, and the two AGREE - $30
-- and 1-8/1D8. No second row is added for it and nothing is corrected. Stated
-- because an absence here would otherwise read as an oversight.
--
-- THE BOWS AND CROSSBOWS ARE NOT A CONTRADICTION, they are a specialisation.
-- The table prices a generic `Short Bow` ($130), `Long Bow` ($270) and
-- `Cross Bow` ($160); the descriptions price a NINJA bow, a SAMURAI long bow, a
-- modern commercial hunting bow, a heavy crossbow and a pistol-style crossbow,
-- each with its own damage. Those are five more weapons, not five corrections,
-- and they are added as rows.
--
-- ===================================================================
-- ONE ENTRY, TWO ITEMS - FIVE TIMES
-- ===================================================================
--
-- The prose runs several weapons under one heading and prices them separately.
-- Each becomes its own row, because a single row cannot hold two prices:
--
--   Bows                          -> Ninja Bow, Samurai Long Bow, Modern
--                                    Commercial Hunting Bow
--   Crossbows                     -> Heavy Crossbow, Pistol-Style Crossbow
--   Kusari-Gama/Kyoketsu-Shogi    -> two rows, $300 and $100
--   Shuriken                      -> Shuriken $5, Throwing Knives $3
--   Tiger Claws or Bagh Nakh      -> claws alone $40, claws and blades $70-150
--
-- ===================================================================
-- TWO PRICES THE COLUMN CANNOT HOLD
-- ===================================================================
--
-- `cost` is an INTEGER of dollars. Rope is $.25 a foot and the ninja rope
-- ladder $.75 a foot - both below its resolution. Those two rows carry a NULL
-- `cost` and the figure in `cost_note`, which the schema explicitly allows
-- ("cost_note WELCOME BESIDE A NULL cost"). They are NOT rounded to a dollar
-- and they are NOT the usual meaning of a NULL cost, which is that the book
-- printed no price; the note says which it is.
--
-- THE BLOW GUN HAS NO DAMAGE ON PURPOSE. Printed 195: "The dart itself does no
-- damage; however, it is usually coated with poison or drugs." NULL rather than
-- 0, because 0 would read as a weapon that hits for nothing.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('aikuchi-tanto', 'Aikuchi/Tanto', 'heroes-unlimited', 'weapon', 20, '$20 to $1,000, varying with quality and beauty', '1D4', 0, 'Curved Japanese daggers. The Tanto has a hilt, the Aikuchi does not. Can also be thrown.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bisento', 'Bisento', 'heroes-unlimited', 'weapon', 600, NULL, '2D6', 0, 'A spear with a broad, curved blade, large enough to count as a kind of pole arm. Must be imported from Japan.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('blow-gun', 'Blow Gun', 'heroes-unlimited', 'weapon', 45, NULL, NULL, 0, 'A ninja favourite. Effective range no more than 50ft. THE DART ITSELF DOES NO DAMAGE - it is usually coated with poison or drugs, which is why the damage column is empty rather than zero.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ninja-bow', 'Ninja Bow', 'heroes-unlimited', 'weapon', 500, NULL, '1D8', 0, 'A short, none too powerful bow that disassembles and hides easily. Effective range 400ft.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('samurai-long-bow', 'Samurai Long Bow', 'heroes-unlimited', 'weapon', 1000, '$1,000 or more for high quality', '2D6', 0, 'Probably the most powerful weapon of its type in the world, and a separate skill from the ninja bow. Effective range 800ft.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('modern-commercial-hunting-bow', 'Modern Commercial Hunting Bow', 'heroes-unlimited', 'weapon', 200, NULL, '1D10', 0, 'Printed 195 prices this beside the ninja and samurai bows as the modern commercial equivalent.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('heavy-crossbow', 'Heavy Crossbow', 'heroes-unlimited', 'weapon', 300, NULL, '2D6', 0, 'Two-handed. Printed 195 notes crossbows are now commonly available by mail order in the U.S.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('pistol-style-crossbow', 'Pistol-Style Crossbow', 'heroes-unlimited', 'weapon', 150, NULL, '1D10', 0, 'A 40lb pistol-style crossbow, printed 195.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('daisho', 'Daisho', 'heroes-unlimited', 'weapon', 150, '$150 for fair quality, $1,200 for an authentic high quality', '1D8+2 (long), 1D6 (short)', 0, 'Literally the long and the short: the traditional Japanese pairing of a Wakizashi and a Katana, used together as paired weapons - which printed 195 notes is a separate skill.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('jitte-or-sai', 'Jitte or Sai', 'heroes-unlimited', 'weapon', 50, '$50 per pair', '1D6', 0, 'Oversized three-pronged forks, designed to be used as a pair, one in each hand. Excellent for countering a samurai sword blade: a skilled user can entangle with one hand and attack with the other.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('katana', 'Katana', 'heroes-unlimited', 'weapon', 300, 'from $300 for a manufactured version to at least $5,000 for top quality', '2D6 regular quality, 3D6 top quality (authentic)', 0, 'The primary weapon of the Samurai warrior; a long sword up to 3ft. Printed 195 stresses the enormous difference in quality between examples.', 'Revised Heroes Unlimited p.195');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('kyoketsu-shogi', 'Kyoketsu-Shogi', 'heroes-unlimited', 'weapon', 100, NULL, '1D8', 0, 'Rope with an iron ring on one end and a double blade on the other. Usually used as a climbing device, but doubles as a somewhat less damaging Kusari-Gama. Cannot be used by anyone not trained in hand to hand martial arts, assassin or ninjitsu.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('kusari-gama', 'Kusari-Gama', 'heroes-unlimited', 'weapon', 300, NULL, '1D10', 0, 'A chain with a weight on one end and a sickle on the other. Cannot be used by anyone not trained in hand to hand martial arts, assassin or ninjitsu.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('kawanga', 'Kawanga', 'heroes-unlimited', 'weapon', 50, NULL, '1D8', 0, 'A ninja combination of rope and grapple used for climbing and fighting. A separate chain weapon.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('manriki-gusari', 'Manriki-Gusari', 'heroes-unlimited', 'weapon', 30, NULL, '1D8', 0, 'A chain weapon with solid blunt weights at each end, used like a Kusari-Gama. Easy to disassemble and conceal, and easy to make from chain and lead weights out of any hardware store.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('naginata-yari', 'Naginata/Yari', 'heroes-unlimited', 'weapon', 150, NULL, '1D8', 0, 'Naginata have curved blades and Yari straight ones; otherwise alike, and used as spears. Very difficult to conceal.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('no-dachi', 'No-Dachi', 'heroes-unlimited', 'weapon', 750, '$750 and up', '3D6', 0, 'A huge two-handed sword, 5 to 6ft long, carried on the back and drawn over the shoulder. Does much more damage than most weapons in its class.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('sa-tjat-koen', 'Sa Tjat Koen', 'heroes-unlimited', 'weapon', 150, NULL, '1D10', 0, 'A Malaysian weapon like Nunchaku with a second chain and third handle. Can entangle like nunchaku but can NOT be used as a paired weapon.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('shikomi-zue', 'Shikomi-Zue', 'heroes-unlimited', 'weapon', 150, NULL, '1D8', 0, 'A hollow bamboo staff with a spring-loaded concealed blade, released by a trigger stud. Ninja commonly disguised themselves as blindmen and carried it. Usable as a somewhat fragile Bo Staff (S.D.C. 50) or as a spear.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('shuriken', 'Shuriken', 'heroes-unlimited', 'weapon', 5, '$5.00 each for high quality', '1D4', 0, 'The famous throwing stars, designed less for deadly effect than for ease of concealment and for discouraging pursuit.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('throwing-knives-japanese', 'Throwing Knives (Japanese)', 'heroes-unlimited', 'weapon', 3, '$3.00 each for high quality', '1D4', 0, 'Printed 196 prices these beside shuriken and notes that throwing knives require a different technique from shuriken.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('wakizashi', 'Wakizashi', 'heroes-unlimited', 'weapon', 300, 'varies with quality; printed 196 refers the reader to the Katana prices', '1D8 regular quality, 2D6 top quality', 0, 'The short sword favoured by the samurai. The ninja short sword has a straighter blade but is otherwise the same weapon.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('tonfa', 'Tonfa', 'heroes-unlimited', 'weapon', 40, NULL, '1D6', 0, 'A short wood weapon ideal for parrying and close combat.', 'Revised Heroes Unlimited p.196');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('climbing-claws-tekagi-or-shuko', 'Climbing Claws (Tekagi or Shuko)', 'heroes-unlimited', 'gear', 85, '$85 per pair', '1', 0, 'A metal or leather band round the palm with two to six spikes on the inside surface, for climbing wood and stone. ADDS +15% TO CLIMBING SKILLS. Printed 197 gives it a damage rating of 1 as a weapon.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('climbing-spikes', 'Climbing Spikes', 'heroes-unlimited', 'gear', 45, '$45 per pair', NULL, 0, 'Spiked claws attached to the soles of the feet. ADDS +15% TO CLIMBING SKILL. Normal walking or running is impossible while wearing them.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('eggshell-bomb', 'Eggshell Bomb', 'heroes-unlimited', 'gear', 5, '$5.00 each', NULL, 0, 'An eggshell filled with pepper, metal shavings and other secret substances; shatters into a small cloud of blinding, irritating smoke. DOES NO DAMAGE, but all victims must save against poison gas. Blinded victims are -6 to strike, parry and dodge.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ippon-sugi-nobori', 'Ippon-Sugi Nobori', 'heroes-unlimited', 'gear', 25, NULL, NULL, 0, 'A short length of spike-studded wood with ropes at each end, used like a lumberjack''s climbing belt. ONLY for climbing trees and telephone poles. ADDS 25% TO CLIMBING SKILL.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ninja-emergency-kit', 'Ninja Emergency Kit', 'heroes-unlimited', 'gear', 120, NULL, NULL, 0, 'A cloth bag holding a Kyoketsu-Shogi, 6 shuriken, 12 caltrops, a 3ft towel, a small cooking pot, paper and pencil, matches, a first-aid kit, lock picks, spare clothing, an eggshell filled with blinding powder, and 7 days of tight rations.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ninja-clothing', 'Ninja Clothing', 'heroes-unlimited', 'gear', 600, NULL, NULL, 0, 'Completely black for darkness or completely white for snow: jacket, hakama, tabi and belt, with leggings, separate sleeves, a groin protector and a quilted body protector. Numerous pockets conceal shuriken, garrote, caltrops and lock picks.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('chain-per-foot', 'Chain (per foot)', 'heroes-unlimited', 'gear', 1, 'about $1.00 per foot; cost varies with thickness and tensile strength', NULL, 0, 'Available in just about any hardware store. Modern chain is usually well tested and reinforced.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('rope-per-foot', 'Rope (per foot)', 'heroes-unlimited', 'gear', NULL, 'about $.25 per foot - BELOW THE RESOLUTION of an integer cost column, so it is recorded here rather than rounded', NULL, 0, 'Available in just about any hardware store. Cost varies with thickness and tensile strength.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ninja-rope-ladder-per-foot', 'Ninja Rope Ladder (per foot)', 'heroes-unlimited', 'gear', NULL, '$.75 per foot - below the resolution of an integer cost column', NULL, 0, 'Loops knotted into it every two feet or so, with a 3 pound weight at the bottom end; the top is often tied to a grappling hook. Easy to use and easy to conceal.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('tetsubishi-ninja-caltrops', 'Tetsubishi (ninja caltrops)', 'heroes-unlimited', 'gear', 2, '$2.00 each', '1', 0, 'Caltrops in a variety of styles, all designed so the barbs point upwards however they land. Damage is rarely more than 1 point, but someone with one in their foot is not likely to keep walking until they pull it out.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('african-throwing-knives', 'African Throwing Knives', 'heroes-unlimited', 'weapon', 80, '$80-$150', '1D8', 0, 'Printed 197, under Other Ancient Exotic Weapons.', 'Revised Heroes Unlimited p.197');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bola', 'Bola', 'heroes-unlimited', 'weapon', 40, NULL, '1D4', 0, 'Two or three heavy balls on a long cord, used primarily in South America to ENTANGLE cattle.', 'Revised Heroes Unlimited p.198');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('boomerang', 'Boomerang', 'heroes-unlimited', 'weapon', 10, '$10-$20 each', '1D6', 0, 'The aborigine throwing stick.', 'Revised Heroes Unlimited p.198');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('chakram', 'Chakram', 'heroes-unlimited', 'weapon', 10, '$10 each', '1D4', 0, 'A flat steel ring with a sharpened outer edge.', 'Revised Heroes Unlimited p.198');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('katar', 'Katar', 'heroes-unlimited', 'weapon', 200, NULL, '1D6', 0, 'A Hindu double blade weapon, about a foot and a half long - a small sword. The OCR cache reads its damage as |D6; printed 198 rendered at 210 dpi says 1D6.', 'Revised Heroes Unlimited p.198');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('tiger-claws-or-bagh-nakh', 'Tiger Claws or Bagh Nakh', 'heroes-unlimited', 'weapon', 40, NULL, '1D4', 0, 'A small set of steel claws that fit in the hand, favoured by assassins in India and the Middle East. This row is the CLAWS ALONE.', 'Revised Heroes Unlimited p.198');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('tiger-claws-with-blades-bich-hwa-bagh-nakh', 'Tiger Claws with Blades (Bich'' Hwa Bagh Nakh)', 'heroes-unlimited', 'weapon', 70, '$70 to $150', '1D6 knife, 1D4 claw', 0, 'Printed 198 notes tiger claws were often combined with knives, and prices that combination separately from the claws alone.', 'Revised Heroes Unlimited p.198');

-- THE CORRECTION. Printed 195's description of the Bo Staff prices it at $120;
-- the table on 194, from which this row was imported, says $140. The
-- description wins.
UPDATE gear
   SET cost = 120,
       description = description || ' PRICE CORRECTED: the table on printed 194 gives $140 and the description on printed 195 gives $120, and the description wins. The damage is unchanged - the table writes 1-8 and the description 1D8, which are the same.',
       source_book = 'Revised Heroes Unlimited p.194-195'
 WHERE slug = 'bo-staff-hu' AND cost = 140;

-- ASSERTIONS.

SELECT 'all forty oriental, exotic and ninja rows landed' AS assertion, count(*) AS got, 40 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.195',
    'Revised Heroes Unlimited p.196', 'Revised Heroes Unlimited p.197',
    'Revised Heroes Unlimited p.198');

SELECT 'thirty are weapons and ten are gear' AS assertion, count(*) AS got, 40 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.195',
    'Revised Heroes Unlimited p.196', 'Revised Heroes Unlimited p.197',
    'Revised Heroes Unlimited p.198')
   AND category IN ('weapon', 'gear') AND system = 'heroes-unlimited';

SELECT 'none is mega-damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book LIKE 'Revised Heroes Unlimited p.19%' AND is_mega_damage = 1;

-- THE CORRECTION, read back. If this reports 0 the UPDATE matched nothing,
-- which on a fresh rebuild would mean batch A had not run first.
SELECT 'the Bo Staff now costs the description price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'bo-staff-hu' AND cost = 120;

SELECT 'and no row is left at the table price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'bo-staff-hu' AND cost = 140;

-- Nunchaku agrees between table and description, so there must be exactly ONE
-- of it and it must still be the batch A row at $30.
SELECT 'Nunchaku is still one row at the agreed price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND name = 'Nunchaku' AND cost = 30;

-- The five headings that became two or three rows each.
SELECT 'the three bows are three rows' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Ninja Bow', 'Samurai Long Bow', 'Modern Commercial Hunting Bow')
   AND cost IN (500, 1000, 200);

SELECT 'the two crossbows are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Heavy Crossbow', 'Pistol-Style Crossbow') AND cost IN (300, 150);

SELECT 'the chain-sickle pair are two rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Kusari-Gama', 'Kyoketsu-Shogi') AND cost IN (300, 100);

SELECT 'the two tiger-claw rows differ' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name LIKE 'Tiger Claws%' AND cost IN (40, 70);

-- The two sub-dollar prices keep a NULL cost and carry the figure in the note.
SELECT 'rope and the rope ladder hold their price in the note' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE system = 'heroes-unlimited'
   AND name IN ('Rope (per foot)', 'Ninja Rope Ladder (per foot)')
   AND cost IS NULL AND cost_note IS NOT NULL;

-- And the blow gun's empty damage is deliberate.
SELECT 'the blow gun dart does no damage' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE system = 'heroes-unlimited' AND name = 'Blow Gun' AND damage IS NULL;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-b-oriental-and-ninja.sql');
