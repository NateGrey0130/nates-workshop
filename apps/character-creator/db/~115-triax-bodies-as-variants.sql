-- The nine Triax cyborg bodies and twelve robot bodies as variants on the NGR
-- Cyborg Soldier and the NGR Robot Soldier.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~115-triax-bodies-as-variants.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~115-triax-bodies-as-variants.sql
--
-- Close-out package A9 (Nate's ruling 7 of 2026-10-04): both classes let the
-- player choose a body from machines the catalog already holds as vessel rows
-- (#791), and both left the choice to the G.M., so a character built from
-- either had no M.D.C. and no robot strength. Each body is now a variant, the
-- shape Warlords of Russia gave its Cyborg Shocktrooper (#1617). No vessel row
-- is added or changed.
--
-- EVERY FIGURE WAS READ OFF A RENDER of Rifts World Book 5: Triax and the NGR
-- (printed 60-117, 161, 169-170) and checked against renders again by a
-- reader that did not write it.
--
-- THE CYBORG SOLDIER'S NINE (printed 97-117). A variant holds:
--   mdc_base        the main body WITHOUT its removable armor, which is what
--                   the vessel row's mdc_main_body holds too. The armor is in
--                   the new Armor and Conditional Bonuses by Body ability.
--   attribute_dice  the printed bionic P.S., P.P. and Spd, fixed.
--   bonuses         the body's own unconditional line. Strike, parry and
--                   dodge need care: five bodies print them as "P.P. nn
--                   bonus", the attribute's own, which the sheet derives from
--                   the fixed P.P., so storing them would count them twice.
--                   The Prowler, Marauder and Monster print totals that
--                   "include" the P.P. bonus; the stored figure is the total
--                   less the chart figure for that P.P. (24: +5, 21: +3).
--                   attacks is the body's extra attack from heightened
--                   reflexes: 1, or 2 for the EIC-100 (its tail) and the
--                   Prowler (its attacks line; its bonus line prints one more
--                   and the page does not say they stack).
--   No body prints a Horror Factor.
--
-- THE ROBOT SOLDIER'S TWELVE (printed 60-97). A variant holds the main body
-- M.D.C. and the robot P.S., and the EIR-50's printed Spd of 33. No page
-- prints a P.P. A variant carries NO bonuses, so the class's own stand:
-- printed 169 gives the O.C.C. its own bonuses from the human mind, a drone's
-- printed bonuses are its program's, and the four X-series print theirs as
-- pilot combat training. The DV-13 the O.C.C. names is statted nowhere.
--
-- Every replace() is guarded on the text it replaces and on the new text
-- being absent, so a second run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: two class rows.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'restrictions:
  - "THE BODY IS ONE OF NINE CHASSIS, printed 99-117:',
         'special_abilities:
  - name: "Armor and Conditional Bonuses by Body"
    description: "Each body''s removable armor adds to its main body and is not in the variant''s M.D.C. EIC-100: 135 M.D.C. of armor; +1 to strike with the eye beams and the laser finger guns. VX-300 Striker: 100 M.D.C. of armor; +1 to strike with the rail gun arm and with the laser finger gun. VX-320 Cyclops: 100 M.D.C. of armor. VX-340 Slasher: 270 M.D.C. of light infantry armor, at -1 to parry, dodge and roll with impact and -20% to prowl while it is worn; +1 to strike with the TX-500 rail gun. VX-370 Stopper: 280 M.D.C. of light infantry armor at the same penalties; each of its two weapon arms is -1 to strike and parry. VX-500 Manhunter: 420 M.D.C. of heavy armor, in which prowl is impossible and the character is -2 to strike, parry, dodge and roll with impact; Spd is 100 in it and 154 in light espionage armor; +1 to strike with the TX-500 rail gun. VX-635 Prowler: 135 M.D.C. of armor; cannot be surprised from behind; the page prints one more attack on its bonus line beside the two on its attacks line, and two are stored. VX-2010 Marauder and VX-2020 Monster: no removable armor, the main body is the whole figure; prowling is impossible and jet pack flight is at half speed. The Monster cannot be surprised from behind and is +1 to strike with the TX-50 rail gun."
variants:
  - id: eic-100-gurgoyle-cyborg
    name: "EIC-100 Gurgoyle Cyborg"
    mdc_base: 250
    attribute_dice: { PS: "30", PP: "24", Spd: "132" }
    bonuses:
      combat: { attacks: 2, initiative: 1, roll: 1, pull_punch: 1 }
      saves: { horror_factor: 2, psionics: 1 }
  - id: vx-300-striker
    name: "VX-300 Striker"
    mdc_base: 180
    attribute_dice: { PS: "24", PP: "21", Spd: "170" }
    bonuses:
      combat: { attacks: 1, initiative: 2, roll: 2, pull_punch: 2 }
      saves: { horror_factor: 1 }
  - id: vx-320-cyclops
    name: "VX-320 Cyclops"
    mdc_base: 180
    attribute_dice: { PS: "24", PP: "21", Spd: "154" }
    bonuses:
      combat: { attacks: 1, initiative: 2, roll: 2, pull_punch: 2 }
      saves: { horror_factor: 1 }
  - id: vx-340-slasher
    name: "VX-340 Slasher (Gold Type)"
    mdc_base: 180
    attribute_dice: { PS: "27", PP: "24", Spd: "154" }
    bonuses:
      combat: { attacks: 1, initiative: 2, roll: 1, pull_punch: 3 }
      saves: { horror_factor: 1 }
  - id: vx-370-stopper
    name: "VX-370 Stopper (Blue Type)"
    mdc_base: 200
    attribute_dice: { PS: "27", PP: "22", Spd: "154" }
    bonuses:
      combat: { attacks: 1, initiative: 1, pull_punch: 1 }
      saves: { horror_factor: 1 }
  - id: vx-500-manhunter
    name: "VX-500 Manhunter (Red Type)"
    mdc_base: 280
    attribute_dice: { PS: "30", PP: "22", Spd: "100" }
    bonuses:
      combat: { attacks: 1, initiative: 1, pull_punch: 2 }
      saves: { horror_factor: 1 }
  - id: vx-635-prowler
    name: "VX-635 Prowler"
    mdc_base: 180
    attribute_dice: { PS: "24", PP: "24", Spd: "170" }
    bonuses:
      combat: { attacks: 2, initiative: 5, strike: 2, parry: 2, dodge: 2, roll: 4, pull_punch: 3 }
      saves: { horror_factor: 1, psionics: 1 }
  - id: vx-2010-marauder
    name: "VX-2010 Marauder"
    mdc_base: 660
    attribute_dice: { PS: "40", PP: "21", Spd: "96" }
    bonuses:
      combat: { attacks: 1, initiative: 1, strike: 1, parry: 1, roll: 2, pull_punch: 2 }
      saves: { horror_factor: 1, psionics: 1 }
  - id: vx-2020-monster
    name: "VX-2020 Monster"
    mdc_base: 680
    attribute_dice: { PS: "40", PP: "21", Spd: "96" }
    bonuses:
      combat: { attacks: 1, initiative: 3, strike: 2, parry: 1, dodge: 1, roll: 2, pull_punch: 2 }
      saves: { horror_factor: 1, psionics: 1 }
restrictions:
  - "THE BODY IS ONE OF NINE CHASSIS, CHOSEN AS THE VARIANT, printed 99-117:'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier'
   AND instr(markdown, 'restrictions:
  - "THE BODY IS ONE OF NINE CHASSIS, printed 99-117:') > 0
   AND instr(markdown, 'rror_factor: 1, psionics: 1 }
restrictions:
  - "THE BODY IS ONE OF NINE CHASSIS, CHOSEN AS THE VARIANT, printed 99-117:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The class still states NO mdc_base: its M.D.C.,
    P.S. and speed are the chosen chassis''s, which the class cannot pick for the
    player, so a character built from it gets the core S.D.C. rule and the GM
    applies the chassis row. Until then',
         'Since ~115 each chassis is a VARIANT of the
    class, by Nate''s ruling of 2026-10-04 (the Warlords of Russia shape): the
    variant sets the main body M.D.C., the bionic P.S., P.P. and Spd, and the
    body''s own bonuses, all read off renders of printed 97-117. Removable
    armor is not in mdc_base; it and every conditional bonus are in the Armor
    and Conditional Bonuses by Body ability. Strike, parry and dodge: five
    bodies print them as the P.P. bonus, which the sheet derives from the
    fixed P.P., so none is stored; the Prowler, Marauder and Monster print
    totals that include the P.P. bonus, so what is stored is the total less
    the chart figure for that P.P. The extra attack from heightened reflexes
    is stored (two for the EIC-100, which adds its tail, and for the Prowler).
    Until ~029'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier'
   AND instr(markdown, 'The class still states NO mdc_base: its M.D.C.,
    P.S. and speed are the chosen chassis''s, which the class cannot pick') > 0
   AND instr(markdown, 'k from heightened reflexes
    is stored (two for the EIC-100, which adds its tail, and for the Prowler).
    Until ~029') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The class does not carry its own M.D.C. Printed 161 says',
         'The body is chosen as the variant. Printed 161 says'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier'
   AND instr(markdown, 'The class does not carry its own M.D.C. Printed 161 says') > 0
   AND instr(markdown, 'The body is chosen as the variant. Printed 161 says') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The GM picks the design and applies its M.D.C., P.S., speed and weapon systems.',
         'The variant sets the main body M.D.C., the bionic P.S., P.P. and Spd and the body''s own bonuses; armor, M.D.C. by location and weapon systems are read from the vessel row.'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier'
   AND instr(markdown, 'The GM picks the design and applies its M.D.C., P.S., speed and weapon systems.') > 0
   AND instr(markdown, '.S., P.P. and Spd and the body''s own bonuses; armor, M.D.C. by location and weapon systems are read from the vessel row.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'restrictions:
  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, each a vessel row:',
         'variants:
  - id: x-545-super-hunter
    name: "X-545 Super Hunter"
    mdc_base: 500
    attribute_dice: { PS: "50" }
  - id: x-2000-dyna-max
    name: "X-2000 Dyna-Max"
    mdc_base: 550
    attribute_dice: { PS: "50" }
  - id: x-2500-black-knight
    name: "X-2500 Black Knight"
    mdc_base: 750
    attribute_dice: { PS: "50" }
  - id: x-2700-dragonwing
    name: "X-2700 Dragonwing"
    mdc_base: 525
    attribute_dice: { PS: "50" }
  - id: dv-12-dyna-bot
    name: "DV-12 Dyna-Bot"
    mdc_base: 130
    attribute_dice: { PS: "40" }
  - id: dv-15-sentry-bot
    name: "DV-15 Sentry-Bot"
    mdc_base: 160
    attribute_dice: { PS: "40" }
  - id: dv-40-hunter-killer-drone
    name: "DV-40 Hunter/Killer Drone"
    mdc_base: 300
    attribute_dice: { PS: "40" }
  - id: eir-10-gargoyle-drone
    name: "EIR-10 Gargoyle Drone"
    mdc_base: 250
    attribute_dice: { PS: "40" }
  - id: eir-15-gargoyle-manned-robot
    name: "EIR-15 Gargoyle Manned Robot"
    mdc_base: 280
    attribute_dice: { PS: "40" }
  - id: eir-20-gurgoyle-drone
    name: "EIR-20 Gurgoyle Drone"
    mdc_base: 200
    attribute_dice: { PS: "30" }
  - id: eir-30-gargoylite-drone
    name: "EIR-30 Gargoylite Drone"
    mdc_base: 50
    attribute_dice: { PS: "20" }
  - id: eir-50-gurgoyle-android
    name: "EIR-50 Gurgoyle Android"
    mdc_base: "1d4x100"
    attribute_dice: { PS: "30", Spd: "33" }
restrictions:
  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, CHOSEN AS THE VARIANT, each a vessel row:'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, 'restrictions:
  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, each a vessel row:') > 0
   AND instr(markdown, 'pd: "33" }
restrictions:
  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, CHOSEN AS THE VARIANT, each a vessel row:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The class still states no mdc_base, no attribute_dice and no
    speed: printed 169 says strength, speed, leaping, flight and weapon systems
    are exactly the robot''s own, so the GM applies the chosen row. Until then',
         'Since ~115 each of the twelve is a VARIANT of the class,
    by Nate''s ruling of 2026-10-04: the variant sets the main body M.D.C. and
    the robot P.S. its page prints, read off renders. No page prints a P.P.,
    and only the EIR-50 prints a Spd, so nothing else is set: printed 169
    says strength, speed, leaping, flight and weapon systems are exactly the
    robot''s own, and those are read from the vessel row. A variant carries
    no bonuses: a drone''s printed bonuses are its program''s, the four
    X-series print theirs as pilot combat training, and the class''s own
    bonuses are what the human mind adds. The EIR-50''s main body is rolled,
    1D4x100. Until ~029'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, 'The class still states no mdc_base, no attribute_dice and no
    speed: printed 169 says strength, speed, leaping, fligh') > 0
   AND instr(markdown, ' and the class''s own
    bonuses are what the human mind adds. The EIR-50''s main body is rolled,
    1D4x100. Until ~029') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Strength, speed, leaping, flight and weapon systems are the robot''s own, from that row; the GM applies them.',
         'The body is chosen as the variant, which sets the main body M.D.C. and the robot P.S.; speed, leaping, flight and weapon systems are the robot''s own, from that row.'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, 'Strength, speed, leaping, flight and weapon systems are the robot''s own, from that row; the GM applies them.') > 0
   AND instr(markdown, 's the main body M.D.C. and the robot P.S.; speed, leaping, flight and weapon systems are the robot''s own, from that row.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the cyborg soldier carries nine variants and the robot soldier twelve' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'ngr-cyborg-soldier'
        AND (length(markdown) - length(replace(markdown, char(10) || '  - id: ', ''))) / length(char(10) || '  - id: ') = 9)
    OR (class_id = 'ngr-robot-soldier'
        AND (length(markdown) - length(replace(markdown, char(10) || '  - id: ', ''))) / length(char(10) || '  - id: ') = 12);

SELECT 'every variant id is a vessel row' AS assertion, count(*) AS got, 21 AS want
  FROM vehicles v
 WHERE instr((SELECT markdown FROM imported_classes WHERE class_id = 'ngr-cyborg-soldier')
          || (SELECT markdown FROM imported_classes WHERE class_id = 'ngr-robot-soldier'),
             char(10) || '  - id: ' || v.slug || char(10)) > 0;

SELECT 'each fixed main body equals its vessel row' AS assertion, count(*) AS got, 20 AS want
  FROM vehicles v
 WHERE instr((SELECT markdown FROM imported_classes WHERE class_id = 'ngr-cyborg-soldier')
          || (SELECT markdown FROM imported_classes WHERE class_id = 'ngr-robot-soldier'),
             char(10) || '  - id: ' || v.slug || char(10) || '    name: "' || v.name || '"' || char(10) || '    mdc_base: ' || v.mdc_main_body || char(10)) > 0;

SELECT 'neither class still leaves the body to the G.M.' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('ngr-cyborg-soldier', 'ngr-robot-soldier')
   AND instr(markdown, 'The class still states') + instr(markdown, 'the GM applies the') + instr(markdown, 'The GM picks the design') > 0;

SELECT 'both classes are exactly the length this script leaves them' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'ngr-cyborg-soldier' AND length(markdown) = 11700)
    OR (class_id = 'ngr-robot-soldier' AND length(markdown) = 13618);

INSERT INTO data_script_runs (filename) VALUES ('~115-triax-bodies-as-variants.sql');
