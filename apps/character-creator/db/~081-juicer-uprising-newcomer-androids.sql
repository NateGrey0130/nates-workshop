-- Rifts World Book 10: Juicer Uprising - its bestiary and its notable NPCs.
-- 1 creatures (migration 074) and 0 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~081-juicer-uprising-newcomer-androids.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO creatures (slug, name, category, system, playable, alignment, attributes, hp, sdc, mdc, ppe, isp, pools_note, ar, horror_factor, combat, bonuses_note, skills_note, natural_abilities, magic, psionics, size, weight, life_span, habitat, allies, enemies, occ_note, description, source_book) VALUES
('newcomer-androids', 'Newcomer Androids', 'construct', 'rifts', 0, 'Aberrant; will serve their Vallax masters at any cost.', '{"IQ":"20","ME":"18","MA":"18","PS":"30","PP":"21","PE":"N/A","Spd":"40"}', NULL, NULL, '150', '0', NULL, 'M.D.C. by location, adult model (child model in parentheses): Head 40 (20), Limbs 35 each (15 each), Main Body 150 (75), Flesh Sheath 30 S.D.C. (same). The stored M.D.C. is the adult main body. Attributes are fixed numbers, the same for every android; child models use P.S. 20, P.P. 16 and Spd 20. P.E. is printed n/a. P.B. is printed as the range 5-20, which is not a rollable formula, so it is not stored. Runs at full efficiency until the main body is destroyed; losing the head costs one attack per melee and 2 points from all combat bonuses.', NULL, 8, '{"initiative":1,"strike":1,"parry":1,"dodge":1}', 'Bonuses exclude attribute bonuses: +1 initiative, +1 strike, parry and dodge; immune to horror factor, most mental attacks and bio-manipulation. Horror Factor is none until the android''s true nature is revealed, then 8, or 10 for the child-shaped models. Combat is Hand to Hand: Expert (security models) or Basic (all others); attacks per melee are not printed. Damage is ''as per robot strength'', which the entry refers to Rifts Conversion Book One for. No vulnerabilities: affected by all mega-damage weapons and most magic.', 'R.C.C. Skills: five skills at +20%, five at +10% and 10 at +5%; physical skills can be known but give no bonuses. Experience level 1D4+4, reflecting the complexity of the programming. Gear: 95% pose as civilians with no weapons or armor; UTI security guards have Bushman body armor (M.D.C. 60), a Wilk''s 447 laser rifle and a Wilk''s 320 laser pistol; the roughly 100 guards in the underground complex wear body armor and a 150 M.D.C. personal force field and carry a Vallax Force Rifle.', 'A machine in a skin of synthetic muscle, skin and hair that passes nearly any inspection until more than 30 S.D.C. of damage tears it open. Feels no pain or shock, cannot be poisoned, sickened or psionically bio-manipulated, ignores mental attacks, and fights on until its M.D.C. reaches zero. Built-in psionic spoofers make mind readers and aura readers think it is simply mind blocked or naturally resistant.', 'None.', 'None.', 'Human-shaped, in every form from adults of both sexes down to children and infants', NULL, 'Energy capacitors power the android for 300 continuous years before needing replacement', 'Newtown: a total of 4000 androids, 500 of them in the secret subterranean complex', 'The Vallax, whose machine slaves they are; they serve no one else', NULL, NULL, 'The ''newcomers'' of Newtown: costly Vallax-built androids, each given a randomized human personality but putting Vallax orders above everything, its own survival included. Without the Vallax to lead them they all self-destruct. NPC villains only.', 'Rifts World Book 10: Juicer Uprising p.152-153');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 creatures are in' AS assertion, count(*) AS got, 1 AS want
  FROM creatures WHERE slug IN ('newcomer-androids');
SELECT 'and 0 of them are playable' AS assertion, count(*) AS got, 0 AS want
  FROM creatures WHERE playable = 1 AND slug IN ('newcomer-androids');
SELECT 'the creatures carry 0 attacks' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks WHERE owner_kind = 'creature' AND owner_slug IN ('newcomer-androids');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~081-juicer-uprising-newcomer-androids.sql');
