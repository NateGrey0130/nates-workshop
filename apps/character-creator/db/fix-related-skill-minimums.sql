-- Give the eleven classes that print a per-category FLOOR a way to state it.
--
-- BOOK-INGEST-AUDIT.md F6. Beside the related-skill allowance, three books
-- print the same shape of rule:
--
--   Cyber-Knight             Rifts Ultimate printed 67   12 picks, 2 Physical + 3 W.P.s
--   City Rat                 Rifts Ultimate printed 88   10 picks, 3 Physical OR Rogue
--   Cyber-Doc                Rifts Ultimate printed 90    9 picks, 2 Technical
--   Operator                 Rifts Ultimate printed 92    8 picks, 2 Mechanical
--   Rogue Scholar            Rifts Ultimate printed 94   11 picks, 4 Technical
--   Gambler                  Juicer Uprising printed 59  10 picks, 2 Rogue
--   Juicer Wannabe           Juicer Uprising printed 61   8 picks, 2 Rogue + 2 Physical
--   Galactic Tracer          Phase World printed 40       7 picks, 2 Espionage
--   CAF Scientist            Phase World printed 60      12 picks, 4 Science
--   Imperial Security Agent  Phase World printed 83       8 picks, 2 Espionage + 2 Rogue
--   Freedom Fighter          Phase World printed 84       8 picks, 2 Espionage + 2 Rogue
--
-- EVERY LINE ABOVE WAS READ OFF ITS OWN PRINTED PAGE, IN THE BLOCK BELONGING TO
-- THAT CLASS - not grepped for. Four of these pages carry two class blocks, and
-- a page-wide search returns the neighbour: the first match on Phase World
-- printed 82 is the Imperial Legionnaire, which has no floor at all.
--
-- `occ_related_skills` could say how many picks and which categories were
-- legal, and could narrow a category with only/except. All three are CEILINGS.
-- A floor is the opposite shape, so each of these classes shipped offering
-- every pick freely - including the one thing its own book forbids - with the
-- rule left in a note for a human to honour. Migration-free: `minimums` is a
-- new key inside the class markdown, not a new column.
--
-- THE CYBER-KNIGHT HAD NO NOTE AT ALL. Ten of these classes recorded the rule
-- in prose; the Cyber-Knight dropped it at import - not in the related-skills
-- note, not in the GM Notes, not in extraction_notes - so its floor existed
-- nowhere in this repo. It is written here for the first time. The finding was
-- filed over two classes and the corpus was swept afterwards, page by page,
-- through every cached book; that sweep is what found this one, because a class
-- that never mentions its own rule cannot be found by searching for the rule.
--
-- CITY RAT IS THE REASON AN ENTRY HOLDS A LIST. Its floor is a union - "at
-- least three must be selected from Physical or Rogue skills" - satisfied by
-- three Physical, three Rogue, or any mix of three. Written as two separate
-- floors it would demand six picks the book never asks for.
--
-- Notes are rewritten where they claimed the app could not hold the rule. That
-- sentence was in six of the eleven, and three said it again in their GM Notes
-- and extraction_notes. The replacements state what is true now rather than
-- quoting what they replace, so a search for the old wording finds nothing
-- rather than finding the correction.
--
-- Each statement is guarded on its own result being absent, not only on its
-- anchor being present: the minimums anchor SURVIVES its own edit - the count
-- line is still there with the new block under it - so an anchor-only guard
-- would insert a second copy on every re-run.
--
-- FOUR MORE BOOKS PRINT A FLOOR FOR A CLASS THIS CATALOG DOES NOT HOLD:
-- Underseas printed 98, Spirit West printed 39, Free Quebec printed 40, and
-- Triax printed 160 - the last being the next book in the queue. Nothing to fix
-- here; recorded so the next import knows the key exists.

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10),
       'occ_related_skills:' || char(10) || '    count: 10' || char(10) || '    minimums:' || char(10) || '      - { count: 3, categories: ["Physical", "Rogue"] }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'city-rat'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10) || '    minimums:' || char(10) || '      - { count: 3, categories: ["Physical", "Rogue"] }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 9' || char(10),
       'occ_related_skills:' || char(10) || '    count: 9' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Technical" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-doc'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 9' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 9' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Technical" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10),
       'occ_related_skills:' || char(10) || '    count: 12' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Physical" }' || char(10) || '      - { count: 3, category: "Weapon Proficiencies" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Physical" }' || char(10) || '      - { count: 3, category: "Weapon Proficiencies" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10),
       'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Mechanical" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'operator'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Mechanical" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 11' || char(10),
       'occ_related_skills:' || char(10) || '    count: 11' || char(10) || '    minimums:' || char(10) || '      - { count: 4, category: "Technical" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rogue-scholar'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 11' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 11' || char(10) || '    minimums:' || char(10) || '      - { count: 4, category: "Technical" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10),
       'occ_related_skills:' || char(10) || '    count: 10' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gambler'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 10' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10),
       'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10) || '      - { count: 2, category: "Physical" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-wannabe'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10) || '      - { count: 2, category: "Physical" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 7' || char(10),
       'occ_related_skills:' || char(10) || '    count: 7' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 7' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 7' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10),
       'occ_related_skills:' || char(10) || '    count: 12' || char(10) || '    minimums:' || char(10) || '      - { count: 4, category: "Science" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'caf-scientist'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 12' || char(10) || '    minimums:' || char(10) || '      - { count: 4, category: "Science" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10),
       'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'imperial-security-agent'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10),
       'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'freedom-fighter'
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10)) > 0
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8' || char(10) || '    minimums:' || char(10) || '      - { count: 2, category: "Espionage" }' || char(10) || '      - { count: 2, category: "Rogue" }' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE - a floor per category, which `occ_related_skills` cannot express with a single open count, so the player honours it.',
       'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE - a floor per category, held in `minimums` and enforced on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'freedom-fighter'
   AND instr(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE - a floor per category, which `occ_related_skills` cannot express with a single open count, so the player honours it.') > 0
   AND instr(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE - a floor per category, held in `minimums` and enforced on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The app offers all eight freely; hold the player to it.',
       '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The picker shows both floors as running totals, and a build that' || char(10) || 'cannot reach them is refused on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'freedom-fighter'
   AND instr(markdown, '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The app offers all eight freely; hold the player to it.') > 0
   AND instr(markdown, '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The picker shows both floors as running totals, and a build that' || char(10) || 'cannot reach them is refused on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS NOT ENFORCED, for the same' || char(10) || '    reason it is not on the Imperial Security Agent: `occ_related_skills` has a' || char(10) || '    single open count over all its categories, and moving four picks into' || char(10) || '    `occ_skills` as choice groups would take them out of the eight the book' || char(10) || '    calls free. It is in the note and in the GM Notes.',
       '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS ENFORCED, in `minimums`.' || char(10) || '    The floors are spent out of the same eight picks rather than moved into' || char(10) || '    `occ_skills` as choice groups, which would have taken four of them out of' || char(10) || '    the eight the book calls free. BOOK-INGEST-AUDIT.md F6.'),
       updated_at = datetime('now')
 WHERE class_id = 'freedom-fighter'
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS NOT ENFORCED, for the same' || char(10) || '    reason it is not on the Imperial Security Agent: `occ_related_skills` has a' || char(10) || '    single open count over all its categories, and moving four picks into' || char(10) || '    `occ_skills` as choice groups would take them out of the eight the book' || char(10) || '    calls free. It is in the note and in the GM Notes.') > 0
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS ENFORCED, in `minimums`.' || char(10) || '    The floors are spent out of the same eight picks rather than moved into' || char(10) || '    `occ_skills` as choice groups, which would have taken four of them out of' || char(10) || '    the eight the book calls free. BOOK-INGEST-AUDIT.md F6.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE, which is a floor per category and not a limit - `occ_related_skills` has one open count over all the categories it lists, so the requirement is stated here and the player honours it.',
       'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE, which is a floor per category and not a limit - held in `minimums` and enforced on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'imperial-security-agent'
   AND instr(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE, which is a floor per category and not a limit - `occ_related_skills` has one open count over all the categories it lists, so the requirement is stated here and the player honours it.') > 0
   AND instr(markdown, 'AT LEAST TWO OF THE EIGHT MUST COME FROM ESPIONAGE AND TWO FROM ROGUE, which is a floor per category and not a limit - held in `minimums` and enforced on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Two rules the sheet cannot hold. **At least two of the eight related skill picks' || char(10) || 'must come from Espionage and two from Rogue** - the app offers all eight freely,' || char(10) || 'so hold the player to it. And the class **may start with 1D4 cybernetic' || char(10) || 'implants**, which there is no field for.',
       '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The picker shows both floors as running totals, and a build that' || char(10) || 'cannot reach them is refused on save. One rule the sheet still cannot hold: the' || char(10) || 'class **may start with 1D4 cybernetic implants**, and there is no field for it.'),
       updated_at = datetime('now')
 WHERE class_id = 'imperial-security-agent'
   AND instr(markdown, 'Two rules the sheet cannot hold. **At least two of the eight related skill picks' || char(10) || 'must come from Espionage and two from Rogue** - the app offers all eight freely,' || char(10) || 'so hold the player to it. And the class **may start with 1D4 cybernetic' || char(10) || 'implants**, which there is no field for.') > 0
   AND instr(markdown, '**At least two of the eight related skill picks must come from Espionage and two' || char(10) || 'from Rogue.** The picker shows both floors as running totals, and a build that' || char(10) || 'cannot reach them is refused on save. One rule the sheet still cannot hold: the' || char(10) || 'class **may start with 1D4 cybernetic implants**, and there is no field for it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS NOT ENFORCED. The book' || char(10) || '    requires at least two of the eight related picks from Espionage and two from' || char(10) || '    Rogue. `occ_related_skills` carries a single `count` over every category it' || char(10) || '    lists; `occ_skills` can express a per-category floor as a choice group, but' || char(10) || '    moving four picks there would take them out of the eight the book says are' || char(10) || '    free and shrink the choice. Stated in the related-skills note and in the GM' || char(10) || '    Notes instead. The Freedom Fighter carries the same rule and the same note.',
       '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS ENFORCED, in `minimums`.' || char(10) || '    The floors are spent out of the same eight picks rather than moved into' || char(10) || '    `occ_skills` as choice groups, which would have taken four of them out of' || char(10) || '    the eight the book says are free and shrunk the choice. The Freedom Fighter' || char(10) || '    carries the same rule. BOOK-INGEST-AUDIT.md F6.'),
       updated_at = datetime('now')
 WHERE class_id = 'imperial-security-agent'
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS NOT ENFORCED. The book' || char(10) || '    requires at least two of the eight related picks from Espionage and two from' || char(10) || '    Rogue. `occ_related_skills` carries a single `count` over every category it' || char(10) || '    lists; `occ_skills` can express a per-category floor as a choice group, but' || char(10) || '    moving four picks there would take them out of the eight the book says are' || char(10) || '    free and shrink the choice. Stated in the related-skills note and in the GM' || char(10) || '    Notes instead. The Freedom Fighter carries the same rule and the same note.') > 0
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE, TWO-FROM-ROGUE FLOOR IS ENFORCED, in `minimums`.' || char(10) || '    The floors are spent out of the same eight picks rather than moved into' || char(10) || '    `occ_skills` as choice groups, which would have taken four of them out of' || char(10) || '    the eight the book says are free and shrunk the choice. The Freedom Fighter' || char(10) || '    carries the same rule. BOOK-INGEST-AUDIT.md F6.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AT LEAST TWO OF THE SEVEN MUST COME FROM ESPIONAGE - a per-category floor `occ_related_skills` cannot express with one open count; see BOOK-INGEST-AUDIT.md F6.',
       'AT LEAST TWO OF THE SEVEN MUST COME FROM ESPIONAGE - a per-category floor, held in `minimums` and enforced on save; see BOOK-INGEST-AUDIT.md F6.'),
       updated_at = datetime('now')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, 'AT LEAST TWO OF THE SEVEN MUST COME FROM ESPIONAGE - a per-category floor `occ_related_skills` cannot express with one open count; see BOOK-INGEST-AUDIT.md F6.') > 0
   AND instr(markdown, 'AT LEAST TWO OF THE SEVEN MUST COME FROM ESPIONAGE - a per-category floor, held in `minimums` and enforced on save; see BOOK-INGEST-AUDIT.md F6.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '**At least two of the seven related skill picks must come from Espionage.** The' || char(10) || 'app offers all seven freely; hold the player to it.',
       '**At least two of the seven related skill picks must come from Espionage.** The' || char(10) || 'picker shows the floor as a running total, and a build that cannot reach it is' || char(10) || 'refused on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, '**At least two of the seven related skill picks must come from Espionage.** The' || char(10) || 'app offers all seven freely; hold the player to it.') > 0
   AND instr(markdown, '**At least two of the seven related skill picks must come from Espionage.** The' || char(10) || 'picker shows the floor as a running total, and a build that cannot reach it is' || char(10) || 'refused on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE TWO-FROM-ESPIONAGE FLOOR IS NOT ENFORCED. The book requires at least' || char(10) || '    two of the seven related picks from Espionage. `occ_related_skills` carries' || char(10) || '    one open count over every category it lists; the floor is stated in the note' || char(10) || '    and in the GM Notes. Filed as F6 in the Empire batch, where two more classes' || char(10) || '    print the same shape of rule.',
       '  - THE TWO-FROM-ESPIONAGE FLOOR IS ENFORCED, in `minimums`. The book requires' || char(10) || '    at least two of the seven related picks from Espionage. Filed as F6 in the' || char(10) || '    Empire batch; taken across all eleven classes in three books that print a' || char(10) || '    floor like this.'),
       updated_at = datetime('now')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE FLOOR IS NOT ENFORCED. The book requires at least' || char(10) || '    two of the seven related picks from Espionage. `occ_related_skills` carries' || char(10) || '    one open count over every category it lists; the floor is stated in the note' || char(10) || '    and in the GM Notes. Filed as F6 in the Empire batch, where two more classes' || char(10) || '    print the same shape of rule.') > 0
   AND instr(markdown, '  - THE TWO-FROM-ESPIONAGE FLOOR IS ENFORCED, in `minimums`. The book requires' || char(10) || '    at least two of the seven related picks from Espionage. Filed as F6 in the' || char(10) || '    Empire batch; taken across all eleven classes in three books that print a' || char(10) || '    floor like this.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AT LEAST TWO of them come from the Rogue category - a condition the picker cannot enforce, so it is stated here.',
       'AT LEAST TWO of them come from the Rogue category - a floor, held in `minimums` and enforced on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'gambler'
   AND instr(markdown, 'AT LEAST TWO of them come from the Rogue category - a condition the picker cannot enforce, so it is stated here.') > 0
   AND instr(markdown, 'AT LEAST TWO of them come from the Rogue category - a floor, held in `minimums` and enforced on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'AT LEAST TWO must come from Rogue and TWO from Physical - a condition the picker cannot enforce, so it is stated here.',
       'AT LEAST TWO must come from Rogue and TWO from Physical - floors, held in `minimums` and enforced on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-wannabe'
   AND instr(markdown, 'AT LEAST TWO must come from Rogue and TWO from Physical - a condition the picker cannot enforce, so it is stated here.') > 0
   AND instr(markdown, 'AT LEAST TWO must come from Rogue and TWO from Physical - floors, held in `minimums` and enforced on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The four-science floor is a rule on the picks, which the app has no way to enforce; it is stated here and in extraction_notes.',
       'The four-science floor is a rule on the picks, held in `minimums` and enforced on save.'),
       updated_at = datetime('now')
 WHERE class_id = 'caf-scientist'
   AND instr(markdown, 'The four-science floor is a rule on the picks, which the app has no way to enforce; it is stated here and in extraction_notes.') > 0
   AND instr(markdown, 'The four-science floor is a rule on the picks, held in `minimums` and enforced on save.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - AT LEAST FOUR OF THE TWELVE RELATED SKILLS MUST BE SCIENCES. That is a' || char(10) || '    constraint on the player''s picks, not on what the class offers, and nothing' || char(10) || '    in the frontmatter can express it: `count` is a total and a category has no' || char(10) || '    minimum. It is stated in the related-skills note so a player and a GM both' || char(10) || '    see it, and enforcing it is a house rule until the app grows a per-category' || char(10) || '    floor.',
       '  - AT LEAST FOUR OF THE TWELVE RELATED SKILLS MUST BE SCIENCES. That is a' || char(10) || '    constraint on the player''s picks rather than on what the class offers, and' || char(10) || '    it is held in `minimums`: the four come out of the twelve, leaving eight' || char(10) || '    free. BOOK-INGEST-AUDIT.md F6.'),
       updated_at = datetime('now')
 WHERE class_id = 'caf-scientist'
   AND instr(markdown, '  - AT LEAST FOUR OF THE TWELVE RELATED SKILLS MUST BE SCIENCES. That is a' || char(10) || '    constraint on the player''s picks, not on what the class offers, and nothing' || char(10) || '    in the frontmatter can express it: `count` is a total and a category has no' || char(10) || '    minimum. It is stated in the related-skills note so a player and a GM both' || char(10) || '    see it, and enforcing it is a house rule until the app grows a per-category' || char(10) || '    floor.') > 0
   AND instr(markdown, '  - AT LEAST FOUR OF THE TWELVE RELATED SKILLS MUST BE SCIENCES. That is a' || char(10) || '    constraint on the player''s picks rather than on what the class offers, and' || char(10) || '    it is held in `minimums`: the four come out of the twelve, leaving eight' || char(10) || '    free. BOOK-INGEST-AUDIT.md F6.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    schedule:' || char(10) || '      - { level: 3, count: 2 }' || char(10) || '      - { level: 5, count: 3 }',
       '    note: "Select 12 other skills, but AT LEAST TWO must be selected from the Physical category and another THREE must be W.P.s. Both floors are held in minimums and come out of the twelve, leaving seven free. The level-five grant is specifically three more W.P.s, which the schedule counts but cannot narrow."' || char(10) || '    schedule:' || char(10) || '      - { level: 3, count: 2 }' || char(10) || '      - { level: 5, count: 3 }'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, '    schedule:' || char(10) || '      - { level: 3, count: 2 }' || char(10) || '      - { level: 5, count: 3 }') > 0
   AND instr(markdown, '    note: "Select 12 other skills, but AT LEAST TWO must be selected from the Physical category and another THREE must be W.P.s. Both floors are held in minimums and come out of the twelve, leaving seven free. The level-five grant is specifically three more W.P.s, which the schedule counts but cannot narrow."' || char(10) || '    schedule:' || char(10) || '      - { level: 3, count: 2 }' || char(10) || '      - { level: 5, count: 3 }') = 0;

-- Readback: every one of the eleven carries its floors, and none still claims
-- the app cannot enforce them. One SELECT rather than a UNION of eleven - D1
-- rejects a compound SELECT past five terms and rolls the whole file back.
SELECT class_id,
       instr(markdown, 'minimums:') > 0 AS has_floors,
       (length(markdown) - length(replace(markdown, '- { count: ', ''))) / 11 AS floors,
       instr(markdown, 'cannot enforce')
         + instr(markdown, 'cannot express')
         + instr(markdown, 'no way to enforce')
         + instr(markdown, 'FLOOR IS NOT ENFORCED')
         + instr(markdown, 'hold the player to it') AS stale_claims
  FROM imported_classes
 WHERE class_id IN ('city-rat', 'cyber-doc', 'cyber-knight', 'operator',
                    'rogue-scholar', 'gambler', 'juicer-wannabe',
                    'galactic-tracer', 'caf-scientist',
                    'imperial-security-agent', 'freedom-fighter')
 ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-related-skill-minimums.sql');
