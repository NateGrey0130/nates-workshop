-- BOOK-INGEST-AUDIT F105: the repo is brought up to production.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~042-f105-sync-repo-to-production.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~042-f105-sync-repo-to-production.sql
--
-- THE POLICY (Nate, 2026-09-27): when a repo data script and production
-- disagree on a field value, PRODUCTION WINS. The repo is what gets repaired,
-- by one script that sorts after everything, and every statement is guarded on
-- the rebuild's text so that against production it matches no row. Where
-- production is wrong against the book or a stated rule, the sync still takes
-- production's value and the correction goes in its own script or a numbered
-- finding - never in here. The precedent is
-- zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql (#1354); '~' sorts after 'z'.
--
-- Found 2026-09-27 by `repo-vs-live.mjs --offenders` on a clean tree at
-- b62d4727: 23 fields across 23 rows, no row missing or extra. All 23 are
-- below, and no other difference exists.
--
-- PSIONIC POWERS, 18 rows, live 'rifts' / repo NULL. Production is right, and
-- so is the script that wrote them. add-psyscape-psionic-powers.sql (Astral
-- Golem and the fifteen Mind Bleeder powers) and add-africa-psionic-powers.sql
-- (the two racial Empathy powers) insert 'rifts' as a column literal, on
-- purpose: each sits in a category of its own that only a class naming it can
-- reach, the move Phase World's powers made. A rebuild then runs
-- untag-cross-system.sql and zzzz-untag-escaped-psionics.sql after them
-- ('a' < 'u' < 'z'), and both clear EVERY tag. Production added the rows after
-- those had run. zzzzzzzzzzzzzzz-retag-game-psionics.sql fixed this shape for
-- three other books, keyed on source_book; it cannot be keyed that way here,
-- because production holds five more Psyscape rows (category Special) with no
-- tag. So this names the eighteen.
--
-- CLASS MARKDOWN, 5 classes. fix-class-skill-names-to-rue.sql and
-- zz-canonicalise-class-skill-names.sql replace a quoted skill name anywhere in
-- a class's markdown, notes included. These five were imported after both ran
-- live, so production keeps the book's own words where the notes QUOTE them
-- ("Basic Math", "Read Sensory Equipment", "Breaking/Taming Wild Horses"). A
-- rebuild runs the renames after the add scripts ('a' < 'f' < 'z') and turns
-- psi-slayer's note into '"Mathematics: Basic" is Mathematics: Basic'.
-- Production is right.
--
-- psi-tech and zenith-moon-warper: production holds the placeholder
-- `item_id: "light-mdc-body-armor"`, and a rebuild holds the choose block
-- fix-category-gear-rows.sql writes, because that fix sorts after their add
-- scripts and ran live before they were imported. HERE PRODUCTION IS THE SIDE
-- THAT IS WRONG, against that script's own rule (a category is not an item).
-- By the policy the sync still takes production's text. The correction, for
-- both environments at once, is filed as BOOK-INGEST-AUDIT F115.
--
-- The class statements were generated from both sides' markdown and simulated
-- before writing: each search string occurs once in the rebuild text and not at
-- all in production's, no replacement contains its own search string, and
-- applying all six to the rebuild text yields production's exactly.

UPDATE psionic_powers SET system = 'rifts'
 WHERE system IS NULL
   AND name IN ('Astral Golem', 'Bleed P.E. Energy', 'Bleed Aura', 'Bleed Memory', 'Bleed Skills',
                'Bleed Truth', 'Brain Bleed', 'Brain Scan', 'Day Dream', 'Healing Leech',
                'Impervious to Bio-Manipulation', 'Mental Block', 'Mental Block Removal', 'Mind Trip',
                'Neuro-Touch', 'Neural Strike', 'Psionic Empathy with Animals', 'Psionic Empathy with Reptiles')
   AND (source_book LIKE 'Rifts World Book 12: Psyscape%' OR source_book LIKE 'Rifts World Book 4: Africa%');

UPDATE imported_classes
   SET markdown = replace(markdown,
         '"Mathematics: Basic" is Mathematics: Basic;',
         '"Basic Math" is Mathematics: Basic;'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-slayer'
   AND instr(markdown, '"Mathematics: Basic" is Mathematics: Basic;') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '- { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }',
         '- { item_id: "light-mdc-body-armor", qty: 1 }'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-tech'
   AND instr(markdown, '- { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '"Sensory Equipment" -> catalog Sensory Equipment',
         '"Read Sensory Equipment" -> catalog Sensory Equipment'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-tech'
   AND instr(markdown, '"Sensory Equipment" -> catalog Sensory Equipment') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Cowboy''s "Breaking/Taming Wild Horse" is',
         'Cowboy''s "Breaking/Taming Wild Horses" is'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-warrior'
   AND instr(markdown, 'Cowboy''s "Breaking/Taming Wild Horse" is') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '"Sensory Equipment" is the catalog''s Sensory Equipment',
         '"Read Sensory Equipment" is the catalog''s Sensory Equipment'),
       updated_at = datetime('now')
 WHERE class_id = 'zapper'
   AND instr(markdown, '"Sensory Equipment" is the catalog''s Sensory Equipment') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '- { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }',
         '- { item_id: "light-mdc-body-armor", qty: 1 }'),
       updated_at = datetime('now')
 WHERE class_id = 'zenith-moon-warper'
   AND instr(markdown, '- { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }') > 0;

-- Read the result back. Short on purpose (REBUILD-AUDIT F23).

SELECT 'the eighteen carry rifts' AS assertion, count(*) AS got, 18 AS want
  FROM psionic_powers
 WHERE system = 'rifts'
   AND (source_book LIKE 'Rifts World Book 12: Psyscape%' OR source_book LIKE 'Rifts World Book 4: Africa%');

SELECT 'the notes quote the book' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'psi-slayer' AND instr(markdown, '"Basic Math" is Mathematics') > 0)
    OR (class_id IN ('psi-tech', 'zapper') AND instr(markdown, '"Read Sensory Equipment"') > 0)
    OR (class_id = 'psi-warrior' AND instr(markdown, 'Wild Horses" is') > 0);

SELECT 'the two armor lines match production' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('psi-tech', 'zenith-moon-warper')
   AND instr(markdown, 'item_id: "light-mdc-body-armor"') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~042-f105-sync-repo-to-production.sql');
