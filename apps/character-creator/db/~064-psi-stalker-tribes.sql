-- The Psi-Stalker race takes the three tribe blocks of Rifts World Book 23: Xiticix Invasion
-- (printed 103-105): Spider Tribe, Pony-Tail Tribe and the Deathbringer cult.
-- Nate said yes to the tribe blocks on 2026-10-01; see
-- apps/character-creator/docs/surveys/xiticix-invasion.md, "The Psi-Stalker
-- tribes".
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~064-psi-stalker-tribes.sql
--
-- Runs AFTER ~039-f110-psi-stalker-and-dog-races.sql, which creates the
-- mutant-psi-stalker row this edits; it sorts before this file.
--
-- WHAT. One pick-one special_abilities group on mutant-psi-stalker: the three
-- tribes plus "other or none". No code change: an R.C.C. already carries
-- pick-one groups (~055 did the same to mutant-dog).
--
-- WHY THE RACE AND NOT wild-psi-stalker. The plan named the occupation. The
-- premise audit found the wizard offers an ability pick from the race slot
-- only (app.js abilityPicker reads S.rcc; BOOK-INGEST-AUDIT F52's closure
-- records it), so a group on the occupation would be offered to nobody. On
-- the race it is offered to every Psi-Stalker, and the fourth option is the
-- one a Coalition or civilized Psi-Stalker takes.
--
-- APPLIED AS NUMBERS: attributes, S.D.C., hit points, initiative, strike and
-- the saves vs possession, Horror Factor, poisons and drugs. IN THE ABILITY'S
-- TEXT: the +5% to sense and track, the level, alignment and weapon
-- breakdowns, the Deathbringer hand to hand split and its exoskeleton armor
-- (3D6+50 M.D.C., rolled per suit, no price or weight printed, so no gear row).
--
-- The race's own bonuses stay as they are and the picked tribe's add to them.
--
-- MECHANICS. Each statement is guarded on its own new text being absent, so a
-- second run changes nothing.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'restrictions:' || char(10), char(10) || 'special_abilities:
  - { choose: 1, from: ["Tribe: Spider Tribe", "Tribe: Pony-Tail Tribe", "Tribe: Deathbringer Cult", "Tribe: other or none"] }
  - name: "Tribe: Spider Tribe"
    description: "A Canadian Psi-Stalker tribe of about 120,000 to 140,000 (Rifts World Book 23: Xiticix Invasion p.101-104). Its bonuses are added to those from attributes, skills and the R.C.C. Also +5% to sense and track the supernatural and the Xiticix. Alignments run 45% good, 20% Unprincipled, 20% Anarchist and 15% other. Weapons: 25% carry magic weapons (mostly Techno-Wizard), 25% Xiticix resin weapons, the rest modern weapons. Rivals of the Pony-Tail Tribe and frequent enemies of the Simvan. Applied: +2 M.A., +2 M.E., +2 P.S., +3 on initiative, +1 to strike, +2 to save vs possession, +2 to save vs Horror Factor."
    bonuses: { attributes: { MA: 2, ME: 2, PS: 2 }, combat: { initiative: 3, strike: 1 }, saves: { possession: 2, horror_factor: 2 } }
  - name: "Tribe: Pony-Tail Tribe"
    description: "One of the largest Psi-Stalker tribes, an estimated 160,000 to 200,000 in over six dozen clans (Rifts World Book 23: Xiticix Invasion p.103-104); its members fix long strands of hair to their scalps. Its bonuses are added to those from attributes, skills and the R.C.C. Typical level 4-7 (20% are 1-3, 25% are 8-10, 3% are 11 or higher). Alignments run 30% good, 15% Unprincipled, 35% Anarchist and 20% other. Weapons: 30% carry magic weapons (mostly Techno-Wizard melee weapons), 35% Xiticix resin weapons, the rest modern weapons, Vibro-Blades above all. Friendly with the Simvan; distrusts technology, D-Bees and the Coalition. Applied: +3 P.S., +3 Spd, +1 P.B., +14 S.D.C., +2 on initiative."
    bonuses: { attributes: { PS: 3, Spd: 3, PB: 1 }, pools: { sdc: 14 }, combat: { initiative: 2 } }
  - name: "Tribe: Deathbringer Cult"
    description: "A tribe of 860 Wild Psi-Stalkers around Thunder Bay led by a cult of 31 Necromancers (Rifts World Book 23: Xiticix Invasion p.104-105). Its bonuses are added to those from attributes, skills and the R.C.C. Hand to Hand is Expert (01-50%) or Martial Arts (51-00%), with 5-6 attacks per melee round on average. Typical level 3-6 (15% are 1-2, 15% are 7-9); all are practicing cannibals. Alignments run 15% Unprincipled, 40% Anarchist, 25% Aberrant, 10% Miscreant and 10% other. Weapons: 85% carry Xiticix resin weapons, 10% magic weapons, 5% Vibro-Blades and other modern weapons beside a resin weapon or two. Wears non-environmental armor cut from the exoskeletons of Xiticix Warriors or Leapers, typically 3D6+50 M.D.C., with a Xiticix skull helmet, and can pass for a Xiticix at a distance. Applied: +20 S.D.C., +1D6 Hit Points, +1 on initiative, +1 to save vs Horror Factor, +1 to save vs possession, +3 to save vs poisons and drugs."
    bonuses: { pools: { sdc: 20, hp: "1d6" }, combat: { initiative: 1 }, saves: { horror_factor: 1, possession: 1, toxins_poisons: 3, harmful_drugs: 3 } }
  - name: "Tribe: other or none"
    description: "Choose this for a Coalition or civilized Psi-Stalker, or for a Wild Psi-Stalker of any other tribe or of none (the northern tribes of Rifts World Book 23: Xiticix Invasion p.112 print no bonuses): no tribe bonus."' || char(10) || 'restrictions:' || char(10) || '  - "Tribes (Rifts World Book 23: Xiticix Invasion p.101-105): the Spider Tribe, the Pony-Tail Tribe and the Deathbringer cult are Psi-Stalker tribes of the northern wilds (only the Deathbringer block says Wild outright), offered as one pick-one ability group with an other-or-none option. The group sits on the race because that is where the wizard offers an ability pick; a Coalition or civilized Psi-Stalker takes the other-or-none option."' || char(10))
 WHERE class_id = 'mutant-psi-stalker' AND instr(markdown, 'special_abilities:') = 0
   AND instr(markdown, char(10) || 'restrictions:' || char(10)) > 0;

-- Read the result back.
SELECT 'mutant-psi-stalker carries the tribe group' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-psi-stalker'
   AND instr(markdown, 'Tribe: Spider Tribe') > 0 AND instr(markdown, 'Tribe: Pony-Tail Tribe') > 0
   AND instr(markdown, 'Tribe: Deathbringer Cult') > 0 AND instr(markdown, 'Tribe: other or none') > 0;
SELECT 'the block sits before restrictions, once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-psi-stalker'
   AND instr(markdown, 'special_abilities:') > 0
   AND instr(markdown, 'special_abilities:') < instr(markdown, char(10) || 'restrictions:' || char(10))
   AND length(markdown) - length(replace(markdown, 'special_abilities:', '')) = length('special_abilities:');
SELECT 'the tribes line is on the race' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-psi-stalker' AND instr(markdown, '  - "Tribes (Rifts World Book 23') > 0;
SELECT 'the natural abilities are still there' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-psi-stalker' AND instr(markdown, 'Nourishment - the P.P.E. Vampire') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~064-psi-stalker-tribes.sql');
