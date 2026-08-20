-- The Godling's Magic Powers grants "all the abilities of a practitioner of
-- magic. Pick one: Ley Line Walker, Shifter, Mystic or Warlock (or
-- Necromancer if evil)" (Rifts Conversion Book, Godling R.C.C.). Encode the
-- named practitioners as occ_options on the ability, so choosing Magic
-- Powers makes the wizard require picking one - composed in as the
-- character's occupation through the existing race+occupation machinery.
--
-- Only Ley Line Walker is in the catalog today; the other ids resolve the
-- day those classes are imported, and the wizard lists them as
-- "not in the catalog yet" until then.
--
-- One-off data script. Guarded on the text it edits: re-running, or running
-- where the option list already exists, does nothing.
UPDATE imported_classes SET
  markdown = replace(markdown,
    'magic: { type: "innate" }',
    'magic: { type: "innate" }' || char(10) ||
    '    occ_options: ["ley-line-walker", "shifter", "mystic", "warlock", "necromancer"]'),
  updated_at = datetime('now')
WHERE class_id = 'godling'
  AND markdown LIKE '%Magic Powers%'
  AND instr(markdown, 'occ_options') = 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'occ_options: ["ley-line-walker"') > 0 AS has_options
FROM imported_classes WHERE class_id = 'godling';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('apply-godling-magic-powers-occ.sql');
