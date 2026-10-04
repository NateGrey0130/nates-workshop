-- Nine held gear rows take the newest printing that states each figure.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~093-newest-printing-wins-nine-gear-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~093-newest-printing-wins-nine-gear-rows.sql
--
-- Nate's ruling of 2026-10-04: when a later book revises a row the catalog
-- already holds, the newest printing THAT STATES THE FIGURE wins, and the
-- older figure is kept in the row's note. scripts/books.json carries each
-- book's `published` year so the rule is applied from a recorded date.
--
--   tx-j50-juicer-eba    Free Quebec (2000) -> Triax 2 (2010), printed 108-109
--   triax-electro-mace   Triax and the NGR (1994) keeps the stats; Triax 2
--                        printed 104 states the price it never had. The held
--                        charged-damage figure was a misreading of printed 150
--                        and is corrected against that page.
--   neural-mace          cited Rifts Ultimate Edition printed 259 but carried
--                        the damage of Triax and the NGR printed 150 (1994).
--                        RUE (2005) prints the damage and the cost; it prints
--                        no M.D.C. figure, payload or size, so Lone Star
--                        (1997) printed 49 fills those three.
--   large-sack, small-sack, saddlebags, hooded-robe, poncho,
--   fishing-net-small    web-reference, estimate or stub rows that take the
--                        price lists of Warlords of Russia (1998) printed
--                        187-189, the only book that prints one for them.
--
-- NOT changed: knife-throwing. Warlords of Russia printed 187 prices a
-- throwing knife at 100 credits; the held row is Rifts Ultimate Edition's
-- 200-600, and RUE is the newer printing.
--
-- Every figure was read off a page render and checked against a render again
-- by a reader that did not write it. No slug or name changes, so no class's
-- equipment pointer and no saved character's pick moves.
--
-- Each UPDATE is guarded on the citation it replaces, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: nine gear rows. The tilde number is claimed
-- at merge.

UPDATE gear
   SET weight_lbs = 30,
       cost = 225000,
       cost_note = '225,000 credits; often twice that on the Black Market (Triax 2). Free Quebec printed 51 gave 50,000 credits in Free Quebec and 80,000 or more on the black market.',
       mdc = 100,
       description = 'JEBA-TX-J50 heavy (Juicer) Environmental Battle Armor. A Triax suit, sold abroad in limited quantities by Northern Gun and the black market and hugely popular with Juicers across Canada and the northeastern United States. Surprisingly flexible for its protection, thanks to advanced M.D.C. alloys and a simple exoskeleton augmentation that enhances balance and supports the joints. The face plate can be swapped, and the helmet crown carries a modular clamp for a ponytail or Mohawk. M.D.C. by location: Head/Helmet 70, Arms 40 each, Legs 55 each, Main Body 100. Weight 30 lbs (13.5 kg). Mobility very good to excellent for Juicers and Crazies: -5% to Climb, Prowl, Swim, Acrobatics and similar Physical skills, -15% for non-augmented people. Figures are Triax 2 printed 108-109, the newer printing. Free Quebec printed 51 gave Main Body 90 and 20 lbs, and records that Triax agreed to suspend import after Coalition pressure, but not before perhaps 15,000 suits reached the country and Free Quebec bought enough to equip a third of its Juicers.',
       source_book = 'Rifts World Book 31: Triax 2 p.108-109'
 WHERE slug = 'tx-j50-juicer-eba'
   AND source_book = 'Rifts World Book 22: Free Quebec p.51';

UPDATE gear
   SET cost = 70000,
       cost_note = '70,000 credits, from Triax 2 printed 104, which prices the older, giant-sized Electro-Mace for robots 27 feet and larger. Triax and the NGR printed 150 prints no price.',
       damage = 'Blunt 4D6 M.D. per strike, plus 10 M.D. when electrically charged; the electrical blast does 1D4x10 M.D., up to three times per melee round',
       description = 'A giant-size mace carrying an electrical charge, and able to throw a blast at range. Designed for the X-2500 Black Knight and usable by giant robots, typically 20 feet or taller; it carries its own power supply, so the payload is effectively unlimited. Stats are Triax and the NGR printed 150, which prints no price; the price is Triax 2 printed 104. This row read the charged damage as 5D6 M.D. until ~093; the page prints 4D6 plus 10.'
 WHERE slug = 'triax-electro-mace'
   AND cost IS NULL
   AND source_book = 'Rifts World Book 5: Triax and the NGR p.150';

UPDATE gear
   SET cost = 8000,
       cost_note = 'Black Market cost 8,000 credits (Rifts Ultimate Edition printed 259; Lone Star printed 49 prints the same price).',
       damage = '2D6 S.D.C. plus P.S. bonus used as a club, or 1D6 S.D.C. jabbing',
       mdc = 100,
       payload = '100 stun attacks, rechargeable (Lone Star printed 49)',
       description = 'A hand-held stun weapon used by the Dog Pack, 3-4 feet long; it releases an energy charge that temporarily short-circuits the nervous system. A stunned victim is -8 to strike, parry and dodge, and speed and attacks per melee are halved, for 2D4 melee rounds; each further failed save adds 2D4 melee rounds. A victim struck more than four times has a 01-42% chance of being knocked unconscious for 2D4 melee rounds, then suffers the stun penalties for 1D4 minutes. Save vs Neural Mace is 16 or higher, as against non-lethal poison. Ineffective against environmental M.D.C. body and power armor, but effective against Dog Pack armor and half suits, or body armor without a helmet. The mace is an M.D.C. structure and can be used to parry M.D. attacks. Damage, stun and cost are Rifts Ultimate Edition printed 259, the newest printing. RUE prints no M.D.C. figure, payload or size, so the 100 M.D.C., the 100 stun attacks and the length are Lone Star printed 49. Triax and the NGR printed 150, the oldest of the three, gave 1D8 S.D.C. plus P.S. bonus, which this row carried until ~093.'
 WHERE slug = 'neural-mace'
   AND cost IS NULL
   AND damage = '1D8 S.D.C. plus P.S. attribute bonus';

UPDATE gear
   SET cost = 15,
       cost_note = '15-30 credits.',
       weight_lbs = NULL,
       description = 'A large sack. Warlords of Russia printed 188, the Containers price list, which prints no weight or capacity. Until ~093 this row was a web reference (2 credits, 0.44 lbs, not book-verified).',
       source_book = 'Rifts World Book 17: Warlords of Russia p.188'
 WHERE slug = 'large-sack'
   AND source_book = 'Web reference (not book-verified)';

UPDATE gear
   SET cost = 6,
       cost_note = '6-10 credits.',
       weight_lbs = NULL,
       description = 'A small sack. Warlords of Russia printed 188, the Containers price list, which prints no weight or capacity. Until ~093 this row was a web reference (2 credits, 0.44 lbs, not book-verified).',
       source_book = 'Rifts World Book 17: Warlords of Russia p.188'
 WHERE slug = 'small-sack'
   AND source_book = 'Web reference (not book-verified)';

UPDATE gear
   SET cost = 100,
       cost_note = '100-200 credits.',
       description = 'Saddlebags for a horse. Warlords of Russia printed 188, the Containers price list. Until ~093 this row was an estimate of 60 credits.',
       source_book = 'Rifts World Book 17: Warlords of Russia p.188'
 WHERE slug = 'saddlebags'
   AND source_book = 'Estimate - no published price found';

UPDATE gear
   SET cost = 150,
       cost_note = '150-300 credits.',
       description = 'A robe with a hood. Warlords of Russia printed 189, the Clothes: General Purpose price list. Until ~093 this row was an estimate of 40 credits.',
       source_book = 'Rifts World Book 17: Warlords of Russia p.189'
 WHERE slug = 'hooded-robe'
   AND source_book = 'Estimate - no published price found';

UPDATE gear
   SET cost = 50,
       cost_note = '50-100 credits.',
       description = 'Waterproof nylon, 5 feet by 5 feet square (1.5 x 1.5 m); available in camouflage. Warlords of Russia printed 189, Clothing of Note. The Rain Poncho on the same page is a different item (rain-poncho-rifts). Until ~093 this row was an unpriced stub citing Rifts Ultimate Edition printed 88, where a class lists a poncho as equipment and no price is printed.',
       source_book = 'Rifts World Book 17: Warlords of Russia p.189'
 WHERE slug = 'poncho'
   AND cost IS NULL
   AND source_book = 'Rifts Ultimate Edition p.88';

UPDATE gear
   SET cost = 20,
       cost_note = '20 credits.',
       description = 'A hand net for taking fish, as distinct from the trawler nets the boat entries carry. Warlords of Russia printed 187 lists a Fishing Net at 20 credits under Hunting, Trapping, Hiking & Camping. Until ~093 this row was an estimate, also of 20 credits.',
       source_book = 'Rifts World Book 17: Warlords of Russia p.187'
 WHERE slug = 'fishing-net-small'
   AND source_book = 'Estimate - no published price found';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the nine rows carry the new prices' AS assertion, count(*) AS got, 9 AS want
  FROM gear
 WHERE (slug = 'tx-j50-juicer-eba' AND cost = 225000 AND mdc = 100 AND weight_lbs = 30)
    OR (slug = 'triax-electro-mace' AND cost = 70000 AND instr(damage, 'plus 10 M.D.') > 0)
    OR (slug = 'neural-mace' AND cost = 8000 AND mdc = 100 AND instr(damage, '2D6 S.D.C.') = 1)
    OR (slug = 'large-sack' AND cost = 15)
    OR (slug = 'small-sack' AND cost = 6)
    OR (slug = 'saddlebags' AND cost = 100)
    OR (slug = 'hooded-robe' AND cost = 150)
    OR (slug = 'poncho' AND cost = 50)
    OR (slug = 'fishing-net-small' AND cost = 20);

SELECT 'none of the six is a web reference, estimate or stub any more' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE slug IN ('large-sack', 'small-sack', 'saddlebags', 'hooded-robe', 'poncho', 'fishing-net-small')
   AND source_book NOT LIKE 'Rifts World Book 17: Warlords of Russia p.%';

SELECT 'the throwing knife keeps the newer printing' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'knife-throwing' AND source_book LIKE 'Rifts Ultimate Edition%';

INSERT INTO data_script_runs (filename) VALUES ('~093-newest-printing-wins-nine-gear-rows.sql');
