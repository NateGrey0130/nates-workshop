-- Heroes Unlimited's ancient weapons, printed 193-194. Seventy-four rows, the
-- first gear this book has had in the catalog.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-a-ancient-weapons.sql
--
-- READ OFF RENDERS OF PRINTED 193 AND 194 AT 230 dpi, and that is not a
-- formality. The OCR cache of these two pages is wrong in three ways that a
-- transcription from it would have inherited:
--
--   * IT DROPS A WHOLE ROW. `Javelin` (2.1m/7.0ft, 4.0lb, 1-6, $180) sits
--     between Long Spear and Beaked Axe on printed 193 and does not appear in
--     the cache at all. A count would not have caught it; nothing states how
--     many rows the table has.
--   * IT MOVES A NUMBER BETWEEN COLUMNS. `Guisarme` reads "$550" in the cache
--     where the Damage column belongs - and the render shows the BOOK does
--     this, not the OCR: the Damage cell is empty and the price is sitting in
--     it. Stored with the price and a NULL damage rather than a guess.
--   * IT LOSES DIGITS. `Trident` and `Lance` read "-8" in the cache; the page
--     says 1-8 for both.
--
-- The illustrations run through the middle columns of both tables, which is
-- where the noise comes from - `Axe, Throwing <= no .4m/1.25ft` and the like.
-- The numeric columns survive well, which is exactly what makes a
-- transcription from the cache feel safe.
--
-- ===================================================================
-- SIXTY-NINE OF THESE SEVENTY-FOUR NAMES ARE ALREADY IN THE CATALOG
-- ===================================================================
--
-- Under `palladium-fantasy`, from the Palladium RPG main book, which prints the
-- same generic medieval weapon table. They are NOT the same rows and must not
-- be merged into them:
--
--   Short Sword   palladium-fantasy   40 gold   2D4
--   Short Sword   heroes-unlimited   $240       1-6
--
-- A different price in a different currency and a different damage notation.
-- `js/rules.js` prices Heroes Unlimited in DOLLARS and Palladium Fantasy in
-- GOLD, and every picker filters by `system` - so a Palladium row is invisible
-- to a Heroes Unlimited character, and without these rows such a character
-- cannot buy a sword at all.
--
-- ONE ROW PER BOOK IS THIS REPO'S EXISTING PRACTICE, not a departure this file
-- invents. The catalog already holds `Back pack` (palladium-fantasy) beside
-- `Backpack` (rifts), and `Sleeping bag` beside `Sleeping Bag` - the same item,
-- one row per system, differing only in how somebody capitalised it. And
-- `_lib/catalog-merge.js` says so outright: a same-name pair across two systems
-- is reported with the message "one row per book, probably deliberate".
--
-- WHAT THIS COSTS, stated rather than discovered: the duplicates tool will
-- surface roughly sixty-nine new pairs at its `certain` tier, each carrying
-- that system-clash message. They are deliberate and none is pre-dismissed
-- here - a dismissal is a judgement with a name against it, and the tool exists
-- to take it.
--
-- SLUGS: the plain kebab name where it is free, `-hu` appended where it is
-- taken, computed against production rather than assumed. Sixty-seven needed
-- the suffix.
--
-- ===================================================================
-- WHAT THE COLUMNS HOLD
-- ===================================================================
--
-- `damage` is the book's own notation - "1-6", "2-12", "1-8+2" - and is NOT
-- converted to dice. This game writes its ranges that way throughout and a
-- reader comparing a row to the page should see the page's own string.
-- `is_mega_damage` is 0 on every row: this book has no M.D.C. system at all,
-- which the survey establishes from a marker scan over all 240 pages.
--
-- `weight_lbs` is the POUND figure. The book prints both units and its metric
-- half is unreliable - `Axe, Stone` reads "1.8kg/4.0kg", with kg twice.
--
-- Two-handedness and the average length go in `description` because the schema
-- has no column for either, and both are things a player at a table asks about.
--
-- TWO NAMES THE BOOK USES TWICE, and one it abbreviates:
--   * `Beaked Axe` is a POLE ARM (2.3m, 2-12, $540) and also a SPEAR
--     (1.4m, 1-8, $430). Two weapons, one printed name. The spear carries a
--     qualifier here so the two are separable; the pole arm keeps the bare name.
--   * `Arrows` appears twice, indented under Short Bow at $20 a dozen and under
--     Long Bow at $40. Qualified the same way.
--   * The STAVES rows are headed simply `Short` and `Long`, which is legible in
--     the table and meaningless out of it. Stored as `Short Staff` and
--     `Long Staff`, with the printed form in the description.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('axe-battle-hu', 'Axe, Battle', 'heroes-unlimited', 'weapon', 4.6, 240, NULL, '2-12', 0, 'Axes, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('axe-throwing-hu', 'Axe, Throwing', 'heroes-unlimited', 'weapon', 3, 100, NULL, '1-6', 0, 'Axes, printed 193-194. One-handed. Average length .4m/1.25ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('axe-stone-hu', 'Axe, Stone', 'heroes-unlimited', 'weapon', 4, 100, NULL, '1-8', 0, 'Axes, printed 193-194. One-handed. Average length .6m/2.0ft. Printed 193 gives the weight as 1.8kg/4.0kg - the second unit is the book''s own slip for lb.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('axe-bipennis-2-head', 'Axe, Bipennis (2-head)', 'heroes-unlimited', 'weapon', 6, 120, NULL, '2-12', 0, 'Axes, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('oncin-pick-hu', 'Oncin Pick', 'heroes-unlimited', 'weapon', 4, 220, NULL, '1-8', 0, 'Axes, printed 193-194. Two-handed. Average length 1.0m/3.75ft. Spelled Oncin Pick on printed 193 and transcribed as printed.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('awl-pike-hu', 'Awl Pike', 'heroes-unlimited', 'weapon', 6, 445, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 3.2m/10ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('beaked-axe-hu', 'Beaked Axe', 'heroes-unlimited', 'weapon', 5, 540, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.3m/7.5ft. Printed 193 lists a SECOND, different Beaked Axe under Spears - 1.4m/4.5ft, 1-8, $430. Two weapons, one name; this is the pole arm.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('berdiche-hu', 'Berdiche', 'heroes-unlimited', 'weapon', 7, 550, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.1m/7.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('glaive-hu', 'Glaive', 'heroes-unlimited', 'weapon', 6, 540, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.3m/7.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('guisarme-hu', 'Guisarme', 'heroes-unlimited', 'weapon', 6, 550, NULL, NULL, 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.5m/7.25ft. NO DAMAGE IS PRINTED. On printed 193 this row''s $550 sits in the Damage column and the Cost column is empty - a typesetting slip in the book, confirmed on a 230 dpi render rather than inferred from the OCR. The price is stored and the damage left NULL rather than guessed.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('halberd-hu', 'Halberd', 'heroes-unlimited', 'weapon', 5, 660, NULL, '3-18', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.2m/7.25ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('sabre-halberd-hu', 'Sabre Halberd', 'heroes-unlimited', 'weapon', 7, 650, NULL, '3-18', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.4m/8.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('hippe-hu', 'Hippe', 'heroes-unlimited', 'weapon', 6, 750, NULL, '3-18', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.3m/7.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('lucerne-hammer-hu', 'Lucerne Hammer', 'heroes-unlimited', 'weapon', 6.5, 540, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.9m/9.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('military-fork-hu', 'Military Fork', 'heroes-unlimited', 'weapon', 5, 330, NULL, '1-8', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.1m/7.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('pike-hu', 'Pike', 'heroes-unlimited', 'weapon', 8, 445, NULL, '1-8', 0, 'Pole arms, printed 193-194. Two-handed. Average length 5.0m/16ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('runka-hu', 'Runka', 'heroes-unlimited', 'weapon', 6, 445, NULL, '2-12', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.3m/7.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('scythe-hu', 'Scythe', 'heroes-unlimited', 'weapon', 5, 445, NULL, '1-8', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.4m/8.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('voulge-hu', 'Voulge', 'heroes-unlimited', 'weapon', 5, 550, NULL, '3-18', 0, 'Pole arms, printed 193-194. Two-handed. Average length 2.1m/7.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('short-spear-hu', 'Short Spear', 'heroes-unlimited', 'weapon', 4, 130, NULL, '1-6', 0, 'Spears, printed 193-194. One-handed. Average length 1.2-1.8m/4-6ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('long-spear-hu', 'Long Spear', 'heroes-unlimited', 'weapon', 6.5, 180, NULL, '1-8', 0, 'Spears, printed 193-194. Two-handed. Average length 2.1-3.0m/7-10ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('javelin-hu', 'Javelin', 'heroes-unlimited', 'weapon', 4, 180, NULL, '1-6', 0, 'Spears, printed 193-194. One-handed. Average length 2.1m/7.0ft. THE OCR CACHE DROPS THIS ROW ENTIRELY. It is on printed 193 between Long Spear and Beaked Axe, read off a 230 dpi render.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('beaked-axe-spear', 'Beaked Axe (spear)', 'heroes-unlimited', 'weapon', 5, 430, NULL, '1-8', 0, 'Spears, printed 193-194. One-handed. Average length 1.4m/4.5ft. Printed 193 heads this row Beaked Axe, the same name it gives a POLE ARM four rows earlier at 2.3m/7.5ft, 2-12, $540. The qualifier is added here so the two are separable; the book prints the bare name.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('trident-hu', 'Trident', 'heroes-unlimited', 'weapon', 4, 240, NULL, '1-8', 0, 'Spears, printed 193-194. Two-handed. Average length 1.5m/5.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('lance-hu', 'Lance', 'heroes-unlimited', 'weapon', 8, 460, NULL, '1-8', 0, 'Spears, printed 193-194. One-handed. Average length 4.0m/13ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('daggers-and-knives-hu', 'Daggers and Knives', 'heroes-unlimited', 'weapon', 1, 30, '$30-100', '1-6', 0, 'Knives, printed 193-194. One-handed. Average length .2-.5m/10-20in..', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('short-sword-hu', 'Short Sword', 'heroes-unlimited', 'weapon', 3, 240, NULL, '1-6', 0, 'Short swords, printed 193-194. One-handed. Average length .7m/2.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('sabre-hu', 'Sabre', 'heroes-unlimited', 'weapon', 3, 230, NULL, '1-6', 0, 'Short swords, printed 193-194. One-handed. Average length .6m/2.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('scimitar-hu', 'Scimitar', 'heroes-unlimited', 'weapon', 3.5, 235, NULL, '1-6', 0, 'Short swords, printed 193-194. One-handed. Average length .7m/2.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('falchion-hu', 'Falchion', 'heroes-unlimited', 'weapon', 4, 350, NULL, '1-8', 0, 'Short swords, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('cutlass-hu', 'Cutlass', 'heroes-unlimited', 'weapon', 3, 235, NULL, '1-6', 0, 'Short swords, printed 193-194. One-handed. Average length .6m/2.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bastard', 'Bastard', 'heroes-unlimited', 'weapon', 4.5, 450, NULL, '1-8+2', 0, 'Large swords, printed 193-194. Two-handed. Average length 1.0m/3.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('broadsword-hu', 'Broadsword', 'heroes-unlimited', 'weapon', 3.5, 340, NULL, '1-8', 0, 'Large swords, printed 193-194. One-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('claymore-hu', 'Claymore', 'heroes-unlimited', 'weapon', 6.5, 560, NULL, '2-12', 0, 'Large swords, printed 193-194. Two-handed. Average length 1.2m/4.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('flamberge-hu', 'Flamberge', 'heroes-unlimited', 'weapon', 7.5, 670, NULL, '3-18', 0, 'Large swords, printed 193-194. Two-handed. Average length 1.3m/4.25ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('long-sword-hu', 'Long Sword', 'heroes-unlimited', 'weapon', 3.5, 455, NULL, '1-8+2', 0, 'Large swords, printed 193-194. One-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('2-handed-espandon', '2-handed Espandon', 'heroes-unlimited', 'weapon', 4.5, 460, NULL, '2-12', 0, 'Large swords, printed 193-194. Two-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('ball-and-chain-hu', 'Ball and Chain', 'heroes-unlimited', 'weapon', 4.5, 250, NULL, '1-8', 0, 'Ball and chain, printed 193-194. One-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('flail-hu', 'Flail', 'heroes-unlimited', 'weapon', 5.5, 355, NULL, '2-12', 0, 'Ball and chain, printed 193-194. Two-handed. Average length 1.6m/5.25ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('goupillon-flail-hu', 'Goupillon Flail', 'heroes-unlimited', 'weapon', 4.5, 460, NULL, '3-18', 0, 'Ball and chain, printed 193-194. Two-handed. Average length .5m/2.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('mace-and-chain-hu', 'Mace and Chain', 'heroes-unlimited', 'weapon', 4.5, 280, NULL, '2-12', 0, 'Ball and chain, printed 193-194. One-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('nunchaku-hu', 'Nunchaku', 'heroes-unlimited', 'weapon', 2.5, 30, NULL, '1-8', 0, 'Ball and chain, printed 193-194. Two-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('arab-mace-hu', 'Arab Mace', 'heroes-unlimited', 'weapon', 3, 240, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .6m/2.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('mace-hu', 'Mace', 'heroes-unlimited', 'weapon', 4.5, 240, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .7m/2.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('cudgel-hu', 'Cudgel', 'heroes-unlimited', 'weapon', 2.5, 240, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('club-stick-pipe-hu', 'Club/Stick/Pipe', 'heroes-unlimited', 'weapon', 3, 10, NULL, '1-6', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('hercules-club-hu', 'Hercules Club', 'heroes-unlimited', 'weapon', 5.5, 260, NULL, '2-12', 0, 'Blunt weapons, printed 193-194. Two-handed. Average length 1.2m/4.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('horseman-hammer-hu', 'Horseman Hammer', 'heroes-unlimited', 'weapon', 3.5, 145, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('maul-hu', 'Maul', 'heroes-unlimited', 'weapon', 4, 100, NULL, '1-6', 0, 'Blunt weapons, printed 193-194. One-handed. Average length 1.2m/4.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('morning-star-hu', 'Morning Star', 'heroes-unlimited', 'weapon', 2.5, 240, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .8m/2.75ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('war-club-wood', 'War Club (wood)', 'heroes-unlimited', 'weapon', 3, 75, NULL, '1-6', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .9m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('war-hammer-hu', 'War Hammer', 'heroes-unlimited', 'weapon', 4.5, 190, NULL, '1-8', 0, 'Blunt weapons, printed 193-194. One-handed. Average length .7m/2.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('short-staff-hu', 'Short Staff', 'heroes-unlimited', 'weapon', 3, 120, NULL, '1-6', 0, 'Staves, printed 193-194. One-handed. Average length 1.2-1.8m/4-6ft. Printed 194 heads this row simply Short, under STAVES. Named in full here so it is legible out of the table.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('long-staff-hu', 'Long Staff', 'heroes-unlimited', 'weapon', 5, 125, NULL, '1-8', 0, 'Staves, printed 193-194. Two-handed. Average length 1.9-2.7m/7-9ft. Printed 194 heads this row simply Long, under STAVES.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bo-staff-hu', 'Bo Staff', 'heroes-unlimited', 'weapon', 3, 140, NULL, '1-8', 0, 'Staves, printed 193-194. Two-handed. Average length 2.8m/9.5ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('quarterstaff-hu', 'Quarterstaff', 'heroes-unlimited', 'weapon', 3.5, 130, NULL, '1-8', 0, 'Staves, printed 193-194. Two-handed. Average length 1.8m/6.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('iron-staff-hu', 'Iron Staff', 'heroes-unlimited', 'weapon', 7, 245, NULL, '1-8+2', 0, 'Staves, printed 193-194. Two-handed. Average length 1.8-2.1m/6-7ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('short-bow-hu', 'Short Bow', 'heroes-unlimited', 'weapon', 1, 130, NULL, '1-6', 0, 'Missile weapons, printed 193-194. Two-handed.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('arrows-short-bow-hu', 'Arrows (short bow)', 'heroes-unlimited', 'weapon', NULL, 20, '$20 per dozen', NULL, 0, 'Missile weapons, printed 193-194. One-handed. Printed 194 indents this under Short Bow as simply Arrows; a second Arrows row sits under Long Bow at $40 a dozen.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('long-bow-hu', 'Long Bow', 'heroes-unlimited', 'weapon', 2, 270, NULL, '2-12', 0, 'Missile weapons, printed 193-194. Two-handed.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('arrows-long-bow', 'Arrows (long bow)', 'heroes-unlimited', 'weapon', NULL, 40, '$40 per dozen', NULL, 0, 'Missile weapons, printed 193-194. One-handed. Printed 194 indents this under Long Bow as simply Arrows.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('cross-bow-hu', 'Cross Bow', 'heroes-unlimited', 'weapon', 7, 160, NULL, '1-8', 0, 'Missile weapons, printed 193-194. Two-handed. Average length Range: 500-700ft. The book prints a RANGE where the other rows print a length: 500-700ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bolts', 'Bolts', 'heroes-unlimited', 'weapon', NULL, 35, '$35 per dozen', NULL, 0, 'Missile weapons, printed 193-194. One-handed.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('sling-hu', 'Sling', 'heroes-unlimited', 'weapon', 0.125, 40, NULL, '1-6', 0, 'Missile weapons, printed 193-194. One-handed. Printed weight is 2.0oz.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('black-jack-hu', 'Black Jack', 'heroes-unlimited', 'weapon', 3, 10, NULL, '1-4', 0, 'Miscellaneous, printed 193-194. One-handed. Average length 10in.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('dart-hu', 'Dart', 'heroes-unlimited', 'weapon', 0.375, 2, NULL, '1-4', 0, 'Miscellaneous, printed 193-194. One-handed. Average length 6.0in. Printed weight is 6oz.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('bull-whip-hu', 'Bull Whip', 'heroes-unlimited', 'weapon', 3, 60, NULL, '1-8', 0, 'Miscellaneous, printed 193-194. One-handed. Average length 2.4m/8.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('cat-o-nine-tails-hu', 'Cat-o-Nine Tails', 'heroes-unlimited', 'weapon', 1, 100, NULL, '1-6', 0, 'Miscellaneous, printed 193-194. One-handed. Average length .8m/3.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('meat-cleaver-hu', 'Meat Cleaver', 'heroes-unlimited', 'weapon', 1, 10, NULL, '1-6', 0, 'Miscellaneous, printed 193-194. One-handed. Average length .3m/1.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('frying-pan-hu', 'Frying Pan', 'heroes-unlimited', 'weapon', 1, 10, NULL, '1-6', 0, 'Miscellaneous, printed 193-194. One-handed. Average length .3m/1.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('hand-pick-hu', 'Hand Pick', 'heroes-unlimited', 'weapon', 0.5, 5, NULL, '1-4', 0, 'Miscellaneous, printed 193-194. One-handed. Average length 7.0in. Printed weight is 8.0oz.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('large-pick-mattock-hu', 'Large Pick/Mattock', 'heroes-unlimited', 'weapon', 5, 50, NULL, '1-8', 0, 'Miscellaneous, printed 193-194. Two-handed. Average length 1.2m/4.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('shovel-hu', 'Shovel', 'heroes-unlimited', 'weapon', 5, 40, NULL, '1-6', 0, 'Miscellaneous, printed 193-194. Two-handed. Average length 1.2m/4.0ft.', 'Revised Heroes Unlimited p.193-194');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, description, source_book)
VALUES ('hammer-tool-hu', 'Hammer (tool)', 'heroes-unlimited', 'weapon', 3, 10, NULL, '1-4', 0, 'Miscellaneous, printed 193-194. One-handed. Average length 10in.', 'Revised Heroes Unlimited p.193-194');

-- ASSERTIONS.

SELECT 'all seventy-four ancient weapons landed' AS assertion, count(*) AS got, 74 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194';

SELECT 'every one is a Heroes Unlimited weapon' AS assertion, count(*) AS got, 74 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194'
   AND system = 'heroes-unlimited' AND category = 'weapon';

-- This book has no M.D.C. system at all, so a mega-damage flag here would be a
-- transcription error rather than a judgement call.
SELECT 'none is mega-damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194' AND is_mega_damage = 1;

-- Every row carries a price. This book prints one for all seventy-four, so a
-- NULL here means a row lost its cost rather than that the book withheld it -
-- which is the opposite of the usual reading of a NULL cost.
SELECT 'every row carries its printed price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194' AND cost IS NULL;

-- The three rows the OCR got wrong, spelled out, because they are the reason
-- this file was read off renders.
SELECT 'the Javelin the OCR drops is here' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'javelin-hu' AND cost = 180 AND damage = '1-6' AND weight_lbs = 4.0;

SELECT 'Guisarme has its price and NO damage' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'guisarme-hu' AND cost = 550 AND damage IS NULL;

SELECT 'Trident and Lance kept their leading digit' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('trident-hu', 'lance-hu') AND damage = '1-8';

-- The two names the book uses twice must be two rows, not one.
--
-- MATCHED BY NAME, NOT BY SLUG, and the first draft of these two used slugs and
-- reported 1 against a want of 2. The -hu suffix is applied only where the plain
-- slug is already TAKEN, so it lands on beaked-axe-hu and not on
-- beaked-axe-spear, and on arrows-short-bow-hu and not on arrows-long-bow -
-- which is correct behaviour and an unguessable assertion. The rows were checked
-- against production by hand afterwards and only these two assertions changed;
-- every INSERT above is byte-identical to what was applied.
SELECT 'both Beaked Axes exist and differ' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194'
   AND name IN ('Beaked Axe', 'Beaked Axe (spear)') AND cost IN (540, 430);

SELECT 'both Arrows rows exist and differ' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.193-194'
   AND name IN ('Arrows (short bow)', 'Arrows (long bow)') AND cost IN (20, 40);

-- AND THE PALLADIUM ROWS ARE UNTOUCHED. This is the assertion that says the
-- import added rows rather than editing the ones whose names it shares.
SELECT 'the Palladium Short Sword still costs 40 gold' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'short-sword' AND system = 'palladium-fantasy'
   AND cost = 40 AND damage = '2D4';

SELECT 'and the Heroes Unlimited one costs 240 dollars' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'short-sword-hu' AND system = 'heroes-unlimited'
   AND cost = 240 AND damage = '1-6';

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-a-ancient-weapons.sql');
