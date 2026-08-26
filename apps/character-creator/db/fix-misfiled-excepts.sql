-- Three fail-open skill restrictions offer skills the book forbids (class
-- audit F10, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-misfiled-excepts.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-misfiled-excepts.sql
--
-- An except naming a skill the catalog files in another category excludes
-- nothing, and each of these classes also grants that other category bare -
-- so the skill the book forbids is offered. Each book line re-read from the
-- OCR cache, the catalog category confirmed over --remote:
--
--   mystic (RUE printed 119) and shifter (printed 126): "Communications: Any
--   ..., except Laser Communications, Optic Systems, Sensory Equipment,
--   Surveillance, and TV/Video." The catalog files Sensory Equipment under
--   Pilot Related, which both classes grant bare.
--
--   long-bowman (PF printed ~84, cache p086): "Rogue: Any, except Locate
--   Secret Compartments and Ventriloquism." The catalog files Ventriloquism
--   under Technical, which the class grants bare.
--
-- The fix moves each name onto the category the catalog actually files it
-- under, per the F10 sketch. Same family as fix-dead-skill-restrictions.sql.
--
-- Filename sort: fix-misfiled-excepts > add-mystic/add-shifter-class (the
-- writers of the Communications lines), > apply-category-restrictions and
-- apply-schedules-and-group-bonuses (the writers of long-bowman's except
-- entries), and > fix-long-bowman ('lo' < 'mi'), which touches other
-- regions. zz-canonicalise-class-skill-names renames only OLD skill
-- spellings, never these.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- Sensory Equipment out of the Communications except (where it excludes
-- nothing) ...
UPDATE imported_classes
SET markdown = replace(markdown,
      'except: ["Laser Communications", "Optic Systems", "Sensory Equipment", "Surveillance", "T.V./Video"]',
      'except: ["Laser Communications", "Optic Systems", "Surveillance", "T.V./Video"]'),
    updated_at = datetime('now')
WHERE class_id IN ('mystic', 'shifter')
  AND instr(markdown, '"Optic Systems", "Sensory Equipment", "Surveillance"') > 0;

-- ... and onto the Pilot Related grant, where it excludes the actual row.
UPDATE imported_classes
SET markdown = replace(markdown,
      '      - "Pilot Related"',
      '      - { name: "Pilot Related", except: ["Sensory Equipment"] }'),
    updated_at = datetime('now')
WHERE class_id IN ('mystic', 'shifter')
  AND instr(markdown, '      - "Pilot Related"' || char(10)) > 0;

-- Ventriloquism out of the Rogue except ...
UPDATE imported_classes
SET markdown = replace(markdown,
      '- { name: "Rogue", except: ["Locate Secret Compartments", "Ventriloquism"] }',
      '- { name: "Rogue", except: ["Locate Secret Compartments"] }'),
    updated_at = datetime('now')
WHERE class_id = 'long-bowman'
  AND instr(markdown, '"Locate Secret Compartments", "Ventriloquism"') > 0;

-- ... and onto the Technical grant.
UPDATE imported_classes
SET markdown = replace(markdown,
      '      - "Technical"',
      '      - { name: "Technical", except: ["Ventriloquism"] }'),
    updated_at = datetime('now')
WHERE class_id = 'long-bowman'
  AND instr(markdown, '      - "Technical"' || char(10)) > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        3 = each class carries its relocated except
--   old_left     0 = no cross-category name left where it excluded nothing
--   cr_free      3 = all three touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('mystic', 'shifter', 'long-bowman')
            AND (instr(markdown, '- { name: "Pilot Related", except: ["Sensory Equipment"] }') > 0
              OR instr(markdown, '- { name: "Technical", except: ["Ventriloquism"] }') > 0)) AS fixed,
       -- Scoped per class: shifter legitimately grants a bare - "Technical"
       -- in its own category list, so the bare-Technical check applies to
       -- long-bowman alone.
       (SELECT count(*) FROM imported_classes
          WHERE (class_id IN ('mystic', 'shifter')
                 AND (instr(markdown, '"Optic Systems", "Sensory Equipment"') > 0
                   OR instr(markdown, '      - "Pilot Related"' || char(10)) > 0))
             OR (class_id = 'long-bowman'
                 AND (instr(markdown, '"Locate Secret Compartments", "Ventriloquism"') > 0
                   OR instr(markdown, '      - "Technical"' || char(10)) > 0))) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('mystic', 'shifter', 'long-bowman')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-misfiled-excepts.sql');
