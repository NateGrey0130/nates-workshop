-- Eight armours the catalog already held follow Rifts World Book 34:
-- Northern Gun Two, their newest printing.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~298-northern-gun-2-armor-held-compare.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~298-northern-gun-2-armor-held-compare.sql
--
-- Northern Gun Two reprints sixteen armours production already held under
-- older citations (Rifts Ultimate Edition, Rifts World Book 10: Juicer
-- Uprising, Rifts World Book 14: New West, and one estimate citing no book),
-- seventeen rows in all because the Huntsman is held twice. Each was read off
-- a render of Northern Gun Two (PDF offset +1, printed 47-60), every M.D.C.
-- by Location block included, and compared with the held row read whole from
-- production on 2026-11-16. By Nate's rulings of 2026-10-04 (the newest
-- printing that states a figure wins) and 2026-11-16 (the held row takes this
-- book's figure and its citation, and the older figure goes in the
-- description), a row where a figure differs is UPDATED in place, its
-- source_book moves to Northern Gun Two, the description's own statement of
-- the figure is corrected, and one sentence appended to description gives
-- the older figure and the book it came from. Name and slug are unchanged.
--
-- A figure counts as differing when this book prints another value for a
-- column, prints one where the column is empty, or prints another value in
-- the M.D.C. by Location, mobility or price the description states. A figure
-- this book adds where the row stated none (a location block the row never
-- carried, an extra attack listing) is an addition, not a difference.
--
-- Edited (8):
--   juicer-assassin-plate-armor-non-environmental (p.48-49): cost 28,000 to
--     21,000 (heavy 32,000 to 25,000); medium model no movement penalty;
--     heavy model 18-20 lbs.
--   ng-maverick-riding-armor (p.49): cost 14,000 to 14,500.
--   bushman-trooper (p.55): weight 21 lbs where none was held; arms 32 and
--     legs 57 where the row said the Bushman's 30 and 55.
--   explorer-armor (p.56): the estimate takes this book's weight, M.D.C. and
--     price, and its description is rewritten from the page, since the old
--     one only explained the estimate (the approved plan).
--   gladiator-full-environmental-body-armor (p.56): helmet 45-50 for 45.
--   mega-juicer-combat-armor (p.57): non-environmental cost 55,000 to 43,000;
--     augmented and robotic strength thresholds. weight_lbs stays 80, the low
--     end of the 80-100 lbs this book gives the non-environmental suit (10
--     lbs under the 90-110 of the environmental one).
--   titan-plate-armor (p.59): weight_lbs 250 to 190, the low end of the
--     190-240 lbs this book gives the non-environmental suit (10 lbs under the
--     200-250 of the environmental one); supernatural strength thresholds.
--   vibro-spike-armor (p.60): weight 18 to 25, main body 50 to 70 M.D.C., cost
--     55,000 to 65,000, prowl penalty -8% to -5%, one hour per E-Clip.
--
-- Left as they are, citation included, because the render shows no
-- differing figure (9):
--   cavalry-armor-barding (p.47-48; adds fair availability from NG).
--   huntsman-plate-padded-armor-non-environmental (p.48).
--   huntsman-armor (p.48; the same suit, same figures).
--   ng-range-rider-riding-armor (p.50).
--   ng-buffalo-riding-armor (p.54-55).
--   bushman-full-composite-environmental-body-armor (p.55).
--   crusader-full-environmental-body-armor (p.55-56).
--   plastic-man-full-environmental-body-armor (p.58).
--   urban-warrior-padded-environmental-body-armor (p.60).
--
-- Guarded on each row still citing its older source, so a re-run is a no-op.
-- No row is inserted. THIS SCRIPT CHANGES PRODUCTION. The tilde number is
-- claimed at merge.

UPDATE gear
   SET cost = 21000,
       cost_note = 'JBA33 medium 21,000 credits and JBA35 heavy 25,000 credits in today''s market; used Juicer armor fetches 80-90% of full retail even when short some M.D.C.',
       description = replace(replace(description,
           'Weight: 14 lbs (6.3 kg or 18 lbs/8 kg for heavy); good mobility (for Juicer), -5% movement penalty (-10% for anyone NOT a Juicer or Crazy).',
           'Weight: 14 lbs (6.3 kg), or 18-20 lbs (8 to 9 kg) for the heavy model; good mobility for a Juicer: no movement penalty for the medium model and -5% for the heavy one (-10% for anyone NOT a Juicer, Crazy or similar).'),
           'Black Market Cost: 28,000 credits for the medium-weight and 32,000 credits for the heavier model.',
           'Cost: 21,000 credits for the medium-weight and 25,000 credits for the heavier model.')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, sold the two models for 28,000 and 32,000 credits, put the heavy one at a flat 18 lbs and gave the medium one a -5% movement penalty.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.48-49'
 WHERE slug = 'juicer-assassin-plate-armor-non-environmental'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET cost = 14500,
       cost_note = '14,500 credits; good to excellent availability',
       description = description || ' Rifts World Book 14: New West, which this row followed before Northern Gun Two, priced it at 14,000 credits.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.49'
 WHERE slug = 'ng-maverick-riding-armor'
   AND source_book = 'Rifts World Book 14: New West p.179';

UPDATE gear
   SET weight_lbs = 21,
       description = replace(description,
           '(All other armor location are same as above)',
           '(M.D.C. by Location: Main body: 90, Helmet: 50, Arms: 32 each, and Legs: 57 each; weight 21 lbs/9.5 kg)')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, printed no weight for it and left its arms and legs at the Bushman''s 30 and 55 M.D.C.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.55'
 WHERE slug = 'bushman-trooper'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET weight_lbs = 20,
       mdc = 70,
       cost = 28000,
       cost_note = '28,000-34,000 credits new; it sold for 45,000 when first released in 99 P.A.; used suits, short 1D4x10% of their M.D.C., sell for 16,000-20,000 credits',
       description = 'Environmental body armour of heavy padding, Kevlar and ceramic plate composite, popular for more than a decade with explorers, mercenaries, adventurers, bandits and pirates. One of the first suits built to take a jet pack or other backpack directly; the Falcon 300 is the ideal fit and the Wilk''s jet pack is also popular. Comes in green, gray, tan, brown, white, black and camouflage. M.D.C. by Location: Main body: 70, Helmet: 50, Arms: 20 each, and Legs: 25 each. Good to fair mobility: -5% to climb and swim, -12% to prowl, acrobatics, gymnastics and other physical skills. Before Northern Gun Two this row carried no M.D.C. and an estimated 26,000 credits, because the Book of Magic names Explorer armour only in passing, as what a Stone Master typically wears.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.56'
 WHERE slug = 'explorer-armor'
   AND source_book = 'Estimate - no published price found';

UPDATE gear
   SET description = replace(replace(description,
           'Helmet: 45, Arms: 25 each',
           'Helmet: 45-50, Arms: 25 each'),
           'Fair mobility, -10% movement penalty.',
           'Good to fair mobility, -10% movement penalty.')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, gave its helmet a flat 45 M.D.C.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.56'
 WHERE slug = 'gladiator-full-environmental-body-armor'
   AND source_book = 'Rifts Ultimate Edition p.261-270';

UPDATE gear
   SET cost = 43000,
       cost_note = 'Standard non-environmental version 43,000 credits and 10 lbs (4.5 kg) lighter than the full environmental suit, which costs 65,000 credits and weighs 90-110 lbs (40.5 to 49.5 kg) depending on the wearer',
       description = replace(description,
           'or a normal P.S. of 30 or higher, wears it',
           'a normal P.S. of 30 or higher, an augmented P.S. of 25+ or a robotic P.S. of 21+ wears it')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, priced the non-environmental version at 55,000 credits, put it at a flat 80 lbs and named no augmented or robotic strength.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.57'
 WHERE slug = 'mega-juicer-combat-armor'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.61-71';

UPDATE gear
   SET weight_lbs = 190,
       cost_note = 'Non-environmental version 85,000 credits and 10 lbs (4.5 kg) lighter than the full environmental suit, which costs 110,000 credits and weighs 200-250 lbs (90 to 112.5 kg) depending on the wearer''s size. With Ultra-Tech Incorporated defunct only Northern Gun makes it; the Black Market sells a look-alike non-environmental version with 20% less M.D.C. across the board.',
       description = replace(description,
           'Variable mobility: at a normal P.S. of 40+ or a supernatural P.S. of 25+, -15% prowl, -5% climb, swim, acrobatics and gymnastics, speed reduced 10%. Weaker wearers, down to P.S. 25 normal or 20 supernatural, are -30% prowl, -15% to the rest, speed reduced 40%.',
           'Variable mobility: a supernatural P.S. of 30+ is only -5% to prowl. A normal P.S. of 40+, augmented 30+, robotic 25+ or supernatural 21-29 is -15% prowl, -5% climb, swim, acrobatics and gymnastics, speed reduced 10%. Weaker wearers, down to P.S. 25 normal, 22 augmented, 19 robotic or 15 supernatural, are -30% prowl, -15% to the rest, speed reduced 40%.')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, put the non-environmental suit at 250 lbs, gave the lighter penalties only from a supernatural P.S. of 25 and let supernatural wearers down to P.S. 20 move at all.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.59'
 WHERE slug = 'titan-plate-armor'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.61-71';

UPDATE gear
   SET weight_lbs = 25,
       mdc = 70,
       cost = 65000,
       cost_note = '65,000 credits for the full environmental suit; E-Clips not included. The non-environmental version, with a 50 M.D.C. main body, has been discontinued since autumn 105 P.A.',
       payload = 'E-Clip; the Vibro-Field on the spikes lasts one hour per E-Clip',
       description = replace(description,
           'Good mobility: -8% prowl.',
           'Full environmental body armour. M.D.C. by Location: Main body: 70, Helmet: 50, Arms: 25 each, and Legs: 40 each. Good mobility: -5% to prowl, climb, swim, acrobatics, gymnastics and similar skills, doubled and with speed reduced 20% in woodland or brush, where the spikes snag.')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, gave it 50 M.D.C., a weight of 18 lbs, a price of 55,000 credits, -8% to prowl and up to twelve hours on one E-Clip.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.60'
 WHERE slug = 'vibro-spike-armor'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.61-71';

-- Read the result back. A guard or a replace() that matched nothing must
-- fail here, not pass. No assertion quotes a phrase an appended sentence holds.

SELECT 'the eight differing rows cite Northern Gun Two' AS assertion, count(*) AS got, 8 AS want
  FROM gear
 WHERE slug IN ('juicer-assassin-plate-armor-non-environmental', 'ng-maverick-riding-armor',
                'bushman-trooper', 'explorer-armor', 'gladiator-full-environmental-body-armor',
                'mega-juicer-combat-armor', 'titan-plate-armor', 'vibro-spike-armor')
   AND source_book LIKE 'Rifts World Book 34: Northern Gun Two p.%';

SELECT 'five of the eight rows carry this book''s figures' AS assertion, count(*) AS got, 5 AS want
  FROM gear
 WHERE (slug = 'juicer-assassin-plate-armor-non-environmental' AND cost = 21000
        AND instr(description, '25,000 credits for the heavier model') > 0
        AND instr(description, 'no movement penalty for the medium model') > 0)
    OR (slug = 'ng-maverick-riding-armor' AND cost = 14500)
    OR (slug = 'bushman-trooper' AND weight_lbs = 21 AND instr(description, 'Arms: 32 each, and Legs: 57 each') > 0)
    OR (slug = 'explorer-armor' AND weight_lbs = 20 AND mdc = 70 AND cost = 28000)
    OR (slug = 'gladiator-full-environmental-body-armor' AND instr(description, 'Helmet: 45-50, Arms') > 0);

SELECT 'and the other three carry them too' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'mega-juicer-combat-armor' AND cost = 43000 AND instr(description, 'robotic P.S. of 21+') > 0)
    OR (slug = 'titan-plate-armor' AND weight_lbs = 190 AND instr(description, 'supernatural 21-29') > 0)
    OR (slug = 'vibro-spike-armor' AND weight_lbs = 25 AND mdc = 70 AND cost = 65000
        AND instr(description, 'Arms: 25 each, and Legs: 40 each') > 0);

SELECT 'the nine matching rows keep their older citation' AS assertion, count(*) AS got, 9 AS want
  FROM gear
 WHERE slug IN ('cavalry-armor-barding', 'huntsman-plate-padded-armor-non-environmental',
                'huntsman-armor', 'ng-range-rider-riding-armor', 'ng-buffalo-riding-armor',
                'bushman-full-composite-environmental-body-armor',
                'crusader-full-environmental-body-armor',
                'plastic-man-full-environmental-body-armor',
                'urban-warrior-padded-environmental-body-armor')
   AND source_book NOT LIKE 'Rifts World Book 34:%';

INSERT INTO data_script_runs (filename) VALUES ('~298-northern-gun-2-armor-held-compare.sql');
