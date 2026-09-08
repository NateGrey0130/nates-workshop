-- The five cyborg classes say a variant cannot add a skill. It can now.
--
-- BOOK-INGEST-AUDIT.md F31, taken in PR #834. That PR adds `skills_additional`
-- and `related_skills_count` to VARIANT_OVERRIDES; this corrects the five class
-- notes that were written when neither existed.
--
-- Each of the five carries the same sentence, verbatim, enumerating the nine
-- keys a variant could override and concluding that neither operation the book
-- states is expressible. The enumeration was already stale before this - PR
-- #824 added `attribute_maximums` earlier the same day - which is the argument
-- `audit-menu` makes for citing a finding rather than restating a mechanism:
-- "Not stored; see F8" never goes stale, a list of nine keys always will.
--
-- WHAT DOES NOT CHANGE, and the note now says so: these five remain five
-- classes. The mechanism existing is not a reason to restructure published
-- data - a character references its class by `class_id`, and collapsing the
-- four chassis into variants would retire four ids that characters point at.
-- That was decided when the finding was taken. The classes still restate the
-- base O.C.C.'s twelve skills and still must be changed together, which is
-- exactly why the note stays rather than being deleted.
--
-- TWELVE, NOT ELEVEN. The finding says eleven basic skills; all five of these
-- notes say twelve and the book agrees - printed 115 lists eleven lines plus
-- "* Hand to Hand: Expert". The notes are right and the finding is the outlier,
-- so nothing here changes that number.

UPDATE imported_classes SET markdown = replace(markdown,
  'Neither operation is expressible as a `variants` entry: VARIANT_OVERRIDES admits attribute_dice, attribute_requirements, the four pool bases, starting_money, bonuses and skill_overrides, and skill_overrides restates the percentage of a skill the class ALREADY grants and cannot add one. See BOOK-INGEST-AUDIT.md F31.',
  'Neither operation was expressible as a `variants` entry when these five were imported. BOTH ARE NOW: BOOK-INGEST-AUDIT.md F31 added `skills_additional`, unioned onto the parent, and `related_skills_count`. THESE FIVE ARE DELIBERATELY NOT RESTRUCTURED - a character references its class by class_id, and collapsing the four chassis into variants would retire four ids that characters point at, so the mechanism existing is not a reason to move published data. The restatement stands and must still be changed together.'),
  updated_at = datetime('now')
 WHERE class_id IN ('fq-cyborg-soldier', 'fq-cyborg-imprimer', 'fq-cyborg-dervish',
                    'fq-cyborg-slasher', 'fq-cyborg-leviathan');

-- fq-cyborg-soldier carries the SAME sentence with a different tail: it runs on
-- into "So `fq-cyborg-imprimer`, ... each restate these twelve" rather than
-- ending at the citation, so the replace above does not match it. Anchored on
-- the shared prefix only. Found by the readback below reporting 4 of 5 - which
-- is the reason a data script ends by checking itself rather than by trusting
-- that a replace() matched.
UPDATE imported_classes SET markdown = replace(markdown,
  'Neither operation is expressible as a `variants` entry: VARIANT_OVERRIDES admits attribute_dice, attribute_requirements, the four pool bases, starting_money, bonuses and skill_overrides, and skill_overrides restates the percentage of a skill the class ALREADY grants and cannot add one.',
  'Neither operation was expressible as a `variants` entry when these five were imported. BOTH ARE NOW: BOOK-INGEST-AUDIT.md F31 added `skills_additional`, unioned onto the parent, and `related_skills_count`. THESE FIVE ARE DELIBERATELY NOT RESTRUCTURED - a character references its class by class_id, and collapsing the four chassis into variants would retire four ids that characters point at, so the mechanism existing is not a reason to move published data. The restatement stands and must still be changed together.'),
  updated_at = datetime('now')
 WHERE class_id = 'fq-cyborg-soldier';

-- All five must have moved, and no stale copy may be left anywhere.
SELECT
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, 'Neither operation is expressible') > 0) AS stale_left,
  (SELECT count(*) FROM imported_classes
    WHERE status = 'published' AND deleted_at IS NULL
      AND instr(markdown, 'BOTH ARE NOW: BOOK-INGEST-AUDIT.md F31') > 0) AS corrected;

INSERT INTO data_script_runs (filename) VALUES ('fix-fq-cyborg-notes-variant-can-now-add.sql');
