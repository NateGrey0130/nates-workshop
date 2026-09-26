-- The two racial psionic powers of Rifts World Book 4: Africa: Psionic
-- Empathy with Animals (the Ramen R.C.C., printed 62-63) and Psionic Empathy
-- with Reptiles (the Crocodillian R.C.C., printed 69). The book's Buti-fas
-- (printed 130) has the first as well, by reference to the Ramen.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-africa-psionic-powers.sql
--
-- CATEGORY 'Special'. The book tags both "(special)": they are racial abilities
-- of two minion races, not powers a psychic learns. Filed under Sensitive they
-- would be offered by every class whose psionics say "any sensitive", so they
-- take a category of their own, the data-only move Phase World's 'Phase' and
-- Psyscape's 'Mind Bleeder' made. The Ramen and Crocodillian classes grant them
-- by name.
--
-- Each costs 5 I.S.P. to control an animal (or a reptile); the affinity itself
-- is always on and free. isp holds the 5, isp_note says what the 5 buys.
-- catalog-diff --remote on 2026-09-26 found neither name, nor any "Empathy with"
-- row; the catalog's Empathy (Sensitive, 4) is a different power.
-- Descriptions are paraphrases.

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Psionic Empathy with Animals', 'Special', 5, '5 to control an animal; the affinity itself is automatic and free', 'rifts',
  '10 feet (3 m) per level of experience.', '10 minutes per level of experience.', NULL,
  'A racial power of the Ramen, like the Psi-Stalker''s rapport with animals. Domestic animals take to the character at once and try to please him (+20% to ride or work with any domesticated animal); wild animals treat him as a fellow creature of the woods, so birds do not scatter, animals do not bolt and even watchdogs stay quiet, and his approach goes unannounced. For 5 I.S.P. he can touch one animal and evoke fear, which sends it running away rather than attacking, or submission, which makes it regard him as its superior: it will not attack him, lets him touch it and follows his lead, running with him and attacking what he attacks. Ramen never hurt or kill an animal needlessly, hunting only for food.',
  'import', 'Rifts World Book 4: Africa p.62-63'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Psionic Empathy with Animals');

INSERT INTO psionic_powers (name, category, isp, isp_note, system, range, duration, saving_throw, description, source, source_book)
SELECT 'Psionic Empathy with Reptiles', 'Special', 5, '5 to control a reptile; the affinity itself is automatic and free', 'rifts',
  '10 feet (3 m) per level of experience.', '10 minutes per level of experience.', NULL,
  'A racial power of the Crocodillian, virtually the same as the Ramen''s rapport with animals but for reptiles. Crocodiles, caiman, alligators, snakes and other reptiles take to the character at once, accept him among them and protect him (+20% to ride crocodiles or large reptiles, reptilian dinosaurs included), and his presence does not alarm them. For 5 I.S.P. he can touch one reptile and evoke fear, which sends it running away rather than attacking, or submission, which makes it regard him as its superior and obey simple telepathic commands such as attack, flee or hide. Crocodillians never hurt or kill a reptile needlessly.',
  'import', 'Rifts World Book 4: Africa p.69'
WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Psionic Empathy with Reptiles');

-- Read the result back.
SELECT 'the two empathy powers' AS assertion, count(*) AS got, 2 AS want
  FROM psionic_powers WHERE name IN ('Psionic Empathy with Animals', 'Psionic Empathy with Reptiles')
   AND category = 'Special' AND isp = 5 AND source_book LIKE 'Rifts World Book 4: Africa p.%';

SELECT 'no other row is in Special' AS assertion, count(*) AS got, 2 AS want
  FROM psionic_powers WHERE category = 'Special';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-africa-psionic-powers.sql');
