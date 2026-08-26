-- The Dragon Hatchling parent is missing its power schedule and its combat
-- framework (class audit F13, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rifts-core-dragon-hatchling.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rifts-core-dragon-hatchling.sql
--
-- The book (original Rifts core p.100, per the audit's verified quote - the
-- core-book PDF is not in the OCR cache on this machine today): "player can
-- select a total of eight psychic powers from any of the psychic categories
-- except super. Select an additional four at fifth level and another four at
-- tenth level." And: "Combat abilities: Equal to hand to hand: basic, +1
-- melee attack."
--
-- Production had powers_starting: 8 with no powers_schedule, and no Hand to
-- Hand skill anywhere in occ_skills - the +1 attack is carried
-- (combat: { attacks: 1 }) and the special_abilities prose quotes the combat
-- line, but the training itself reached no sheet. The schedule shape is the
-- RUE hatchling variants' (add-dragon-hatchling-cats-eye-class.sql:
-- { level: 5, count: 2 }), with the core book's counts; categories_allowed
-- already carries the no-Super constraint.
--
-- Filename sort: fix-rifts-core-dragon-hatchling > fix-pre-rue-class-audit,
-- the last script that rewrites this class's whole markdown (the audit's
-- sketch name, fix-dragon-hatchling-core, sorts BEFORE it and also collides
-- with the existing fix-dragon-hatchling.sql prefix - hence this name). The
-- later zz- scripts rename old skill spellings and edit restrictions, never
-- these regions.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

UPDATE imported_classes
SET markdown = replace(markdown,
      '  powers_starting: 8' || char(10) || '  categories_allowed: ["Healing", "Physical", "Sensitive"]',
      '  powers_starting: 8' || char(10)
        || '  powers_schedule:' || char(10)
        || '    - { level: 5, count: 4 }' || char(10)
        || '    - { level: 10, count: 4 }' || char(10)
        || '  categories_allowed: ["Healing", "Physical", "Sensitive"]'),
    updated_at = datetime('now')
WHERE class_id = 'dragon-hatchling'
  AND instr(markdown, '  powers_starting: 8' || char(10) || '  categories_allowed:') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { name: "Mathematics: Basic", base: 98, per_level: 0 }' || char(10) || '  occ_related_skills:',
      '    - { name: "Mathematics: Basic", base: 98, per_level: 0 }' || char(10)
        || '    - { name: "Hand to Hand: Basic", base: 0, per_level: 0 }' || char(10)
        || '  occ_related_skills:'),
    updated_at = datetime('now')
WHERE class_id = 'dragon-hatchling'
  AND instr(markdown, '    - { name: "Mathematics: Basic", base: 98, per_level: 0 }' || char(10) || '  occ_related_skills:') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the schedule and the Hand to Hand skill are present
--   old_left     0 = powers_starting no longer abuts categories_allowed
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'dragon-hatchling'
          AND instr(markdown, '  powers_schedule:' || char(10) || '    - { level: 5, count: 4 }') > 0
          AND instr(markdown, '    - { level: 10, count: 4 }') > 0
          AND instr(markdown, '    - { name: "Hand to Hand: Basic", base: 0, per_level: 0 }') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'dragon-hatchling'
          AND instr(markdown, '  powers_starting: 8' || char(10) || '  categories_allowed:') > 0) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'dragon-hatchling'
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rifts-core-dragon-hatchling.sql');
