-- OPTIONAL, and an assertion rather than an observation. Run it only against an
-- environment where you believe every script below has already been applied.
--
-- db/migrations/024-data-script-runs.sql created the log that records data
-- script runs from now on. It starts empty, which on production is a lie by
-- omission: 55 scripts had already been applied there by hand over the weeks
-- before any of this existed, and an empty log reads as "none of them have".
--
-- Nothing can observe those runs after the fact - the scripts are guarded and
-- idempotent, so re-running them to find out would be indistinguishable from
-- having run them, and inferring from the rows they wrote is exactly the
-- guessing game the log exists to end. So they are recorded as ASSERTED, with
-- a note saying so, and the note is the honest part: a row here means someone
-- said it ran, where every later row means it was seen to run.
--
-- Each insert is guarded on the filename, so this cannot double-record a
-- script that has genuinely run since tracking landed, and it is safe to
-- re-run. A script added after this file was generated is simply absent.
--
-- ONE SCRIPT IS DELIBERATELY ABSENT: retire-gear-placeholders.sql. It is the
-- run-early-and-finish-later case, and production is mid-way through it - two
-- of the four placeholder rows are gone, and the Juicer still cites the other
-- two because step 1 is waiting on the Rifts equipment chapter. Asserting a
-- plain run would read as finished. Run the script itself instead: it is
-- guarded, it does whatever is possible now, its closing SELECT reports what
-- is still outstanding, and it records an OBSERVED run rather than an
-- asserted one. That is strictly better evidence than anything this file
-- could claim on its behalf.

INSERT INTO data_script_runs (filename, note)
SELECT 'add-burster-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-burster-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-burster-psionic-powers.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-burster-psionic-powers.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-demigod-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-demigod-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-dog-boy-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-dog-boy-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-elemental-fusionist-earth-air-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-elemental-fusionist-earth-air-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-elemental-fusionist-fire-water-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-elemental-fusionist-fire-water-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-elemental-spells.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-elemental-spells.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-glitter-boy-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-glitter-boy-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-godling-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-godling-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-headhunter-techno-warrior-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-headhunter-techno-warrior-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-ley-line-rifter-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-ley-line-rifter-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-ley-line-walker-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-ley-line-walker-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-merc-soldier-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-merc-soldier-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-mind-melter-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-mind-melter-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-mystic-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-mystic-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-pf-equipment-batch.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-pf-equipment-batch.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-pf-weapons-batch.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-pf-weapons-batch.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-priest-of-light-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-priest-of-light-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-psi-stalker-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-psi-stalker-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-rifts-skill-list-gaps.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-rifts-skill-list-gaps.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-robot-pilot-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-robot-pilot-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-rue-psionics-batch.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-rue-psionics-batch.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-rue-skills-batch.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-rue-skills-batch.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-rue-spells-batch.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-rue-spells-batch.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-shifter-catalog-gaps.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-shifter-catalog-gaps.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-shifter-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-shifter-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-sign-language.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-sign-language.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-techno-wizard-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-techno-wizard-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-warlock-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-warlock-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'add-wild-psi-stalker-class.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'add-wild-psi-stalker-class.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-category-restrictions.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-category-restrictions.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-dice-attribute-bonuses.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-dice-attribute-bonuses.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-godling-magic-powers-occ.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-godling-magic-powers-occ.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-hatchling-skill-overrides.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-hatchling-skill-overrides.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-new-bonus-keys.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-new-bonus-keys.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'apply-schedules-and-group-bonuses.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'apply-schedules-and-group-bonuses.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'backfill-gear-system.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'backfill-gear-system.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'backfill-import-skill-gaps.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'backfill-import-skill-gaps.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'backfill-psionic-isp-notes.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'backfill-psionic-isp-notes.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'backfill-skill-provenance.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'backfill-skill-provenance.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'backfill-spell-ppe-notes.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'backfill-spell-ppe-notes.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-chiang-ku.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-chiang-ku.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-cyber-knight.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-cyber-knight.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-dead-skill-restrictions.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-dead-skill-restrictions.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-dragon-hatchling.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-dragon-hatchling.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-juicer-rue-edition.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-juicer-rue-edition.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-juicer.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-juicer.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-ley-line-walker-rue-bonuses.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-ley-line-walker-rue-bonuses.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-long-bowman.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-long-bowman.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'fix-mind-melter-rue-bonuses.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'fix-mind-melter-rue-bonuses.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'long-bowman-money.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'long-bowman-money.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'merge-scuba-duplicate.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'merge-scuba-duplicate.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'seed-dev.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'seed-dev.sql');

INSERT INTO data_script_runs (filename, note)
SELECT 'untag-cross-system.sql', 'pre-tracking backfill (asserted, not observed)'
WHERE NOT EXISTS (SELECT 1 FROM data_script_runs WHERE filename = 'untag-cross-system.sql');

-- Reports what the log now holds, so the result is read rather than assumed.
SELECT (SELECT count(*) FROM data_script_runs WHERE note IS NULL) AS observed_runs,
       (SELECT count(*) FROM data_script_runs WHERE note IS NOT NULL) AS asserted_runs,
       (SELECT count(DISTINCT filename) FROM data_script_runs) AS distinct_scripts;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-data-script-runs.sql');
