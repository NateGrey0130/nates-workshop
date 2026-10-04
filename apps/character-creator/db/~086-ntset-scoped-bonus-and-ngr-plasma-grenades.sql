-- Three classes stop describing in prose what the catalog can already hold.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~086-ntset-scoped-bonus-and-ngr-plasma-grenades.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~086-ntset-scoped-bonus-and-ngr-plasma-grenades.sql
--
-- == A. THE NTSET PROTECTOR'S MEDICAL BONUS ==
--
-- Coalition War Campaign printed 188 gives the class Medical at +5%, "but
-- +10% to Crime Sciences and Pathology". BOOK-INGEST-AUDIT F109 (taken
-- 2026-09-27) made that expressible - the category listed twice, the scoped
-- entry second - and its outcome note named this class as the first one to
-- take. It was not taken. The second entry is the shape cs-special-forces
-- carries for Technical. Both skills are Medical rows in the catalog (queried
-- --remote 2026-10-03: Crime Scene Investigation, Pathology).
--
-- == B. TWO NGR CLASSES' PLASMA GRENADES ==
--
-- Triax printed 164-165 issues the NGR Intelligence Officer and the
-- Intelligence Commando two plasma grenades. Both classes say "the catalog has
-- no plasma grenade row". It has: `triax-plasma-grenade`, Triax p.149, which
-- the Free Quebec Reloader and three later classes already issue. The notes
-- also record that this equipment list prints 4D6 M.D. where printed 149 and
-- the Power Armor Commando's list print 5D6; the row holds printed 149's
-- 5D6, and the note now says so instead of saying there is no row.
--
-- Every UPDATE is guarded on the exact text it replaces. THIS SCRIPT CHANGES
-- PRODUCTION: three class rows. The tilde number is claimed at merge.

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         '      - { name: "Medical", bonus: 5 }' || char(10) || '      - { name: "Military", only: ["Recognize Weapon Quality"',
         '      - { name: "Medical", bonus: 5 }' || char(10) || '      - { name: "Medical", only: ["Crime Scene Investigation", "Pathology"], bonus: 10 }' || char(10) || '      - { name: "Military", only: ["Recognize Weapon Quality"'),
         'Medical is printed +5%, but +10% to Crime Sciences and Pathology - take Crime Scene Investigation and Pathology at the higher figure by hand.',
         'Medical is printed +5%, but +10% to Crime Sciences and Pathology - Crime Scene Investigation and Pathology carry the +10% as a second Medical entry.'),
       updated_at = datetime('now')
 WHERE class_id = 'ntset-protector'
   AND instr(markdown, 'at the higher figure by hand.') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }',
         '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "triax-plasma-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }'),
         '  - The 2 plasma grenades (4D6 M.D.) are not stored: the catalog has no plasma' || char(10)
           || '    grenade row and the book stats the grenade only inside this equipment list.' || char(10)
           || '    In the body. Note the damage disagrees with the Power Armor Commando''s own' || char(10)
           || '    list on printed 164, which prints 5D6 M.D. for the same item; both readings' || char(10)
           || '    are recorded and neither is stored, since there is no row to store them on.',
         '  - The 2 plasma grenades are the catalog''s triax-plasma-grenade (printed 149,' || char(10)
           || '    5D6 M.D.), in equipment_starting since ~086. This equipment list prints' || char(10)
           || '    4D6 M.D. for them, where printed 149 and the Power Armor Commando''s list' || char(10)
           || '    on printed 164 print 5D6; the row holds printed 149''s figure.'),
         'two plasma grenades, which the catalog has no row for. The T-11',
         'The two plasma grenades are in the starting equipment. The T-11'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-officer'
   AND instr(markdown, 'item_id: "triax-plasma-grenade"') = 0
   AND instr(markdown, '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }') > 0
   AND (SELECT count(*) FROM gear WHERE slug = 'triax-plasma-grenade') = 1;

UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }',
         '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "triax-plasma-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }'),
         '  - The 2 plasma grenades (4D6 M.D.) are not stored, for the same reason as on' || char(10)
           || '    the NGR Intelligence Officer: no catalog row exists, and the Power Armor' || char(10)
           || '    Commando''s list prints 5D6 M.D. for the same item.',
         '  - The 2 plasma grenades are the catalog''s triax-plasma-grenade (printed 149,' || char(10)
           || '    5D6 M.D.), in equipment_starting since ~086, as on the NGR Intelligence' || char(10)
           || '    Officer; this list prints 4D6 M.D. for them.'),
         'two plasma grenades, which the catalog has no row for. The T-11',
         'The two plasma grenades are in the starting equipment. The T-11'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-commando'
   AND instr(markdown, 'item_id: "triax-plasma-grenade"') = 0
   AND instr(markdown, '  - { item_id: "fragmentation-grenade", qty: 2 }' || char(10) || '  - { item_id: "hand-held-computer", qty: 1 }') > 0
   AND (SELECT count(*) FROM gear WHERE slug = 'triax-plasma-grenade') = 1;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the NTSET Protector lists Medical twice, the scoped entry second' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'ntset-protector'
   AND instr(markdown, '      - { name: "Medical", bonus: 5 }' || char(10) || '      - { name: "Medical", only: ["Crime Scene Investigation", "Pathology"], bonus: 10 }') > 0
   AND instr(markdown, 'by hand.') = 0;

SELECT 'both NGR intelligence classes issue two plasma grenades' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('ngr-intelligence-officer', 'ngr-intelligence-commando')
   AND instr(markdown, '  - { item_id: "triax-plasma-grenade", qty: 2 }') > 0;

SELECT 'neither still says the catalog has no plasma grenade row' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('ngr-intelligence-officer', 'ngr-intelligence-commando')
   AND instr(markdown, 'has no plasma') + instr(markdown, 'no catalog row exists') + instr(markdown, 'has no row for') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~086-ntset-scoped-bonus-and-ngr-plasma-grenades.sql');
