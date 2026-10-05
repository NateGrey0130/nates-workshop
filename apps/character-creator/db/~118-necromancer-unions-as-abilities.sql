-- The Africa Necromancer's Union with the Dead and Augmentation options, one
-- special ability each, with its P.P.E. cost.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~118-necromancer-unions-as-abilities.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~118-necromancer-unions-as-abilities.sql
--
-- Close-out package A11 (Nate's rulings 8 and 11 of 2026-10-04: the unions
-- are in, as class abilities with their cost, not spell rows). Rifts World
-- Book 4: Africa, printed 100-102. The class carried each table as one long
-- paragraph inside one ability. Each of the 26 options is now an ability of
-- its own, named "Union: ..." or "Augmentation: ..." with its cost, so the
-- sheet lists them; the two general abilities keep the rule (range, duration,
-- level gates, the limit on appendages) and lose the option list.
--
-- EVERY FIGURE WAS READ OFF A RENDER (this book's text layer reads 8 as S and
-- 1D8 as IDS) and checked against renders again by book-reconcile: 26 of 26
-- agree, and every figure matches what the old paragraphs held.
--
-- THE PAGE'S OWN LOOSE ENDS, kept as printed: the 35 and 20 P.P.E. claws are
-- paragraphs under the dragon claws entry and are abilities of their own
-- because each prints a cost; Additional Arms or Tentacles prints three costs
-- in one entry and is one ability; the dragon horn's 30 is not marked "each".
--
-- This class has an insanity table and its rewrite is close-out Phase C's.
-- Nothing else in it is touched: three guarded replace() calls.
-- THIS SCRIPT CHANGES PRODUCTION: one class row.

UPDATE imported_classes
   SET markdown = replace(markdown,
         ' Options (printed 100-101): Tentacle 10 P.P.E. (+1 strike, +20% climb, +3 damage, can pin or entangle); Rodent claws/feet 10 (+1 strike and parry, +2 S.D.C. damage, +10% climb, usable as hands); Feline claws 20 (+2 strike and parry, +8 S.D.C. damage, +20% climb, +10% prowl, cannot grasp); Canine claws 10 (+1 parry, +4 S.D.C. damage, cannot grasp); Bear, badger, wolverine or similar 15 (+1 strike and parry, +10 S.D.C. damage, +5% climb, digs well, cannot grasp); Bird claws/talons 15 (+1 strike and parry, +8 S.D.C. damage, can use weapons at -1 strike/parry and devices at -20%); Dragon claws 50 (+1 strike and parry, 4D6 M.D., impervious to fire, physical M.D.C. of 12 from a hatchling or 30 from an adult); Claws of other creatures of magic and supernatural monsters (manticore, sphinx, za, sowki, mindolar, ghouls, gargoyles and the like) 35 (2D6 M.D., 8 M.D.C., no strike or parry bonus); Claws of a non-supernatural mega-damage creature (melech, peryton, loogaroo) 20 (1D6 M.D., no M.D.C. or bonuses). Feet and legs: Hooves of any kind 15 (+20 Spd, leap 10 ft/3 m); Rhinoceros or elephant feet 20 (+10 Spd, or +40 for 30 seconds, kick or stomp 4D6 S.D.C.); Kilin hooves 25 (+30 Spd, leap 10 ft, kick 1D6 M.D.); Unicorn hooves 30 (+40 Spd, leap 20 ft/6 m, kick 2D6 M.D.); Dragon feet/claws 30 (+20 Spd, leap 20 ft, kick 4D6 M.D.); Monkey, ape or humanoid hands 15 (+20% climb, +5% acrobatics, feet grasp and use weapons and tools, but normal speed is halved)."
  - name: "Augmentation and Additional Appendages"
',
         ' The options are the fifteen abilities that follow, each with its own P.P.E. cost (printed 100-101)."
  - name: "Union: Tentacle (10 P.P.E.)"
    description: "10 P.P.E.. Covers octopus, squid and a variety of monsters. +1 to strike, +20% to climb using suction cups, +3 to damage, and can pin or entangle an opponent. (Printed 100.)"
  - name: "Union: Rodent''s Claws/Feet (10 P.P.E.)"
    description: "10 P.P.E.. Covers rats, mice, squirrels, rabbits and similar small animals. +1 to strike and parry, +2 to damage (S.D.C.), +10% to climb. The claws have an opposable thumb and fingers, so tools and weapons can be used, roughly equal to human hands. (Printed 100.)"
  - name: "Union: Cat and Other Feline Claws (20 P.P.E.)"
    description: "20 P.P.E.. +2 to strike and parry, +8 to damage (S.D.C.), +20% to climb and +10% to prowl. The claws retract but have no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Canine Claws (10 P.P.E.)"
    description: "10 P.P.E.. +1 to parry and +4 to damage (S.D.C.). No opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bear, Badger, Wolverine and Similar Large Claws (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and +1 to parry, +10 to damage (S.D.C.), and +5% to climb. Excellent for digging, but no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bird Claws/Talons (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and parry, +8 to damage (S.D.C.). The claws can grasp tools and use weapons at -1 to strike or parry; using modern or complicated devices carries a skill penalty of -20%. (Printed 101.)"
  - name: "Union: Dragon Claws (50 P.P.E.)"
    description: "50 P.P.E.. Dragon claws of any kind: +1 to strike, +1 to parry, inflict 4D6 M.D., make the necromancer impervious to fire, and give a physical M.D.C. of 12 from hatchlings and 30 from adult dragons. (Printed 101.)"
  - name: "Union: Claws of Other Creatures of Magic and Supernatural Monsters (35 P.P.E.)"
    description: "35 P.P.E.. Claws of other creatures of magic and supernatural monsters, including manticore, sphinx, za, sowki, mindolar, ghouls, gargoyles and other so-called demons and others: inflict 2D6 M.D. and give the necromancer 8 M.D.C.; no strike or parry bonuses. (Printed 101.)"
  - name: "Union: Claws of a Non-Supernatural Mega-Damage Creature (20 P.P.E.)"
    description: "20 P.P.E.. Claws of a non-supernatural mega-damage creature such as the melech, peryton and loogaroo: inflict 1D6 mega-damage points; no M.D.C. or bonuses. (Printed 101.)"
  - name: "Union: Hooves (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option. Hooves of any kind (horse, ox, cow, deer, etc.) add +20 to the speed attribute and allow a leap of 10 feet (3 m) high or lengthwise. (Printed 101.)"
  - name: "Union: Rhinoceros or Elephant Feet (20 P.P.E.)"
    description: "20 P.P.E.. Feet/legs option. +10 to the normal speed attribute, but can also run for a short period of 30 seconds (two melee rounds) at +40. A kick or stomp inflicts 4D6 S.D.C. damage. (Printed 101.)"
  - name: "Union: Kilin Hooves (25 P.P.E.)"
    description: "25 P.P.E.. Feet/legs option. +30 to the speed attribute, can leap 10 feet (3 m) high or lengthwise, and kick attacks inflict 1D6 M.D. (Printed 101.)"
  - name: "Union: Unicorn Hooves (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +40 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 2D6 M.D. (Printed 101.)"
  - name: "Union: Dragon Feet/Claws (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +20 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 4D6 M.D. (Printed 101.)"
  - name: "Union: Monkey, Ape or Humanoid Hands (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option: hands in place of feet. +20% to climb, +5% to acrobatics, and the feet are equivalent to hands and can grasp and use weapons, tools and devices. The character''s normal speed is reduced by half. (Printed 101.)"
  - name: "Augmentation and Additional Appendages"
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, ' Options (printed 100-101): Tentacle 10 P.P.E. (+1 strike, +20% climb, +3 damage, can pin or entangle); Rodent claws/fee') > 0
   AND instr(markdown, 'es. The character''s normal speed is reduced by half. (Printed 101.)"
  - name: "Augmentation and Additional Appendages"
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         ' Options (printed 101-102): Additional arms or tentacles 10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs - each added pair gives +1 attack per melee and +1 strike and parry, and an M.D. creature''s limb strikes with that creature''s mega-damage; Horn(s) 4 each (butt 1D4 S.D.C. for one, 2D4 for a pair, +6 physical S.D.C.); Rhinoceros horn 8 (3D6 S.D.C., keen hearing +1 initiative, track by smell 55%, +20 S.D.C.); Unicorn horn 10 (1D6 M.D., see the invisible, nightvision 90 ft/27.4 m, keen color vision, prowl 50%, +1 initiative, never tires); Kilin horn 10 (1D4 M.D., see the invisible, nightvision 90 ft, healing touch four times for 1D8 H.P. and 2D8 S.D.C., sense evil); Dragon horn 30 (2D4 M.D. and 25 M.D.C.; two or more do 2D6 M.D., each additional horn +10 M.D.C.); Dragon tail 20 (+1 attack per melee, 2D6 M.D.); Dragon skull 50 (the ''dragon helm'': 20 M.D.C., understand and speak all languages, read and write dragonese/elf, impervious to fire, resistant to cold, the dragon''s breath weapon if any, and the dragon''s known spells cast at 5th level); Skull of a god, godling, greater demon/being or demon lord 120 (not elementals, vampires, alien intelligences or energy beings: 40 M.D.C., that creature''s language, and all its magic powers and spells at half the level it had in life); Wings of a bird or bat 30 (flight at 20 mph/32 km for songbirds, bats, game and large birds, 35 mph/56 km for birds of prey, 45 mph/72 km for large monstrous wings such as pegasus, peryton, harpy, gargoyle, gryphon, gromek, loogaroo or waternix); Wings of a dragon or powerful supernatural creature such as a baal-rog, gargoyle lord or night owl 90 (60 mph/96 km, +10 M.D.C. to the flyer, the wings have 2D4x10 M.D.C.)."
  - name: "Animate and Control the Dead"
',
         ' The options are the eleven abilities that follow, each with its own P.P.E. cost (printed 101-102)."
  - name: "Augmentation: Additional Arms or Tentacles (10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs)"
    description: "10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs. Each additional pair of arms or tentacles adds one physical attack or action per melee round and a bonus of +1 to strike and parry. Three additional pairs can be added, for a possible total of eight arms (two natural and six skeleton limbs); limbs can be human, D-bee, ape or animal, and one giant limb counts as two normal sized limbs. Limbs of a mega-damage creature carry that creature''s strength and inflict its usual mega-damage. (Printed 101.)"
  - name: "Augmentation: Horn(s) (4 P.P.E. each)"
    description: "4 P.P.E. each. Horns are a weapon for head-butting and ramming. A single horn inflicts 1D4 S.D.C. and a pair does 2D4 damage; both add six points to the character''s physical S.D.C. (Printed 102.)"
  - name: "Augmentation: Rhinoceros Horn (8 P.P.E.)"
    description: "8 P.P.E.. The horn inflicts 3D6 S.D.C. and gives keen hearing (+1 on initiative) and a keen sense of smell (55% to track by smell), plus an extra 20 S.D.C. to the wearer. (Printed 102.)"
  - name: "Augmentation: Unicorn Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D6 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), keen color vision, prowl 50%, +1 on initiative, and never tiring. (Printed 102.)"
  - name: "Augmentation: Kilin Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D4 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), healing touch (four times, restoring 1D8 HP and 2D8 S.D.C.), and sense evil as an automatic sensation. (Printed 102.)"
  - name: "Augmentation: Dragon Horn (30 P.P.E.)"
    description: "30 P.P.E.. One horn inflicts 2D4 M.D. and gives 25 M.D.C. to the character wearing it. Two or more horns do 2D6 M.D. and each additional horn adds another 10 M.D.C. points. (Printed 102.)"
  - name: "Augmentation: Dragon Tail (20 P.P.E.)"
    description: "20 P.P.E.. Provides one additional attack per melee and inflicts 2D6 M.D. per strike. (Printed 102.)"
  - name: "Augmentation: Dragon Skull (50 P.P.E.)"
    description: "50 P.P.E.. Often worn as a helmet or ceremonial headdress called the dragon helm. Gives 20 M.D.C., understanding and speech of all languages, reading and writing dragonese/elf, imperviousness to fire, resistance to cold, and whatever breath weapon (if any) the dragon had (fire, cold, acid, etc.). The mage can also cast any spell the dragon once knew, as a 5th level spell caster. (Printed 102.)"
  - name: "Augmentation: Skull of a Powerful Supernatural Monster (120 P.P.E.)"
    description: "120 P.P.E.. Skull of a god, godling, greater demon/being or demon lord (elementals, vampires, alien intelligences and energy beings do not qualify). Gives 40 M.D.C., the ability to speak that creature''s language, and all its magic powers and spell knowledge, only while the skull is activated, at half the level of ability it had alive: 10th level in life gives fifth level power, sixth gives third. (Printed 102.)"
  - name: "Augmentation: Wings of a Bird or Bat (30 P.P.E.)"
    description: "30 P.P.E.. Wings are strapped to the mage''s back and may be undersized or over-sized; when the magic engages they grow or shrink to fit the user. Flying speed is limited to 20 mph (32 km) for most songbirds and bats, game and large birds, and 35 mph (56 km) from the wings of birds of prey. Large monstrous wings (pegasus, peryton, harpy, gargoyle, gryphon, gromek, loogaroo, waternix and similar) give 45 mph (72 km). (Printed 102.)"
  - name: "Augmentation: Wings of a Dragon or Powerful Supernatural Creature (90 P.P.E.)"
    description: "90 P.P.E.. Flight at a speed of 60 mph (96 km) and a bonus of 10 M.D.C. to the flyer; the wings themselves have 2D4x10 M.D.C. (Printed 102.)"
  - name: "Animate and Control the Dead"
'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, ' Options (printed 101-102): Additional arms or tentacles 10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs - each added') > 0
   AND instr(markdown, '0 M.D.C. to the flyer; the wings themselves have 2D4x10 M.D.C. (Printed 102.)"
  - name: "Animate and Control the Dead"
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Union with the Dead and Augmentation are each ONE special ability carrying its full option table as prose; none of their bonuses go in bonuses because each applies only while a limb is attached.',
         'Union with the Dead and Augmentation each keep one special ability for the general rule, and since ~118 every option of their tables is its own special ability named with its P.P.E. cost (fifteen unions, eleven augmentations), by the ruling of 2026-10-04 that they are class abilities and not spell rows. The 35 and 20 P.P.E. claws are paragraphs of the dragon claws entry on the page and are separate abilities here because each prints its own cost; Additional Arms or Tentacles is one ability with its three printed costs. None of their bonuses go in bonuses because each applies only while a limb is attached.'),
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, 'Union with the Dead and Augmentation are each ONE special ability carrying its full option table as prose; none of their') > 0
   AND instr(markdown, 'ty with its three printed costs. None of their bonuses go in bonuses because each applies only while a limb is attached.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'fifteen union abilities and eleven augmentation abilities' AS assertion,
       (length(markdown) - length(replace(markdown, '  - name: "Union: ', ''))) / length('  - name: "Union: ') * 100
       + (length(markdown) - length(replace(markdown, '  - name: "Augmentation: ', ''))) / length('  - name: "Augmentation: ') AS got,
       1511 AS want
  FROM imported_classes WHERE class_id = 'necromancer';

SELECT 'the two general abilities no longer carry the option lists' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'necromancer'
   AND instr(markdown, 'Options (printed 100-101):') + instr(markdown, 'Options (printed 101-102):') + instr(markdown, 'each ONE special ability') > 0;

SELECT 'the class is exactly the length this script leaves it' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'necromancer' AND length(markdown) = 25907);

INSERT INTO data_script_runs (filename) VALUES ('~118-necromancer-unions-as-abilities.sql');
