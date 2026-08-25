-- The Juicer stops being human-only.
--
-- Rifts World Book Ten: Juicer Uprising, printed 16-17, has a section called
-- Non-Human Juicers that directly contradicts the racial line this class was
-- imported with. RUE p.81 says "Racial Requirement: 95% human" and stops there;
-- this book names four peoples who can take the process and several who cannot,
-- with different life spans and detox odds for each.
--
-- One-off data script, run once per environment. NOT a migration - it edits a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zz-race-juicer-non-human.sql
--
-- WHY THE LATER BOOK DOES NOT WIN HERE, AND YET THIS STILL APPLIES. The usual
-- rule is that the later book wins, and RUE (2005) is nine years later than
-- Juicer Uprising (1996). But RUE p.84 ends the Juicer entry with a Related
-- O.C.C.s line naming all seven variants and pointing AT THIS BOOK by name.
-- That is a cross-reference, not a restatement: RUE endorses Juicer Uprising as
-- current rather than superseding it. RUE's "95% human" is the summary line of
-- an entry that then tells you to go and read the book that qualifies it.
--
-- WHY THE NAME SORTS WHERE IT DOES. The race_restrictions block on this class
-- is written by zz-occ-race-restrictions.sql, which is a zz- file. A correction
-- must sort AFTER the file it corrects or a clean rebuild silently undoes it,
-- and fix-juicer-non-human-races.sql would have sorted BEFORE zz-. Checked
-- with the sorted-glob recipe in the class-import skill before naming this
-- file: zz-race- lands after zz-occ- and before zz-reconcile-.
--
-- WHAT THE FRONTMATTER CAN CARRY. race_restrictions entries must resolve to a
-- race id or the reserved word "none", and the parser makes an unresolvable one
-- a hard error. This catalog holds dwarf, elf and ogre as PALLADIUM FANTASY
-- rows. Naming them is the right reading rather than a stretch - the book calls
-- these races Palladium-World D-Bees in the same breath - and the wizard filters
-- both lists by system, so a Rifts game will not offer them today regardless.
-- There is no True Atlantean row at all, so that allowance lives in the note and
-- the prose and will start working by itself the day one is imported. That is the
-- Priest of Light mechanism: a restriction written ahead of its row.
--
-- The list stays an `only`, which fails CLOSED. This is a strict widening -
-- everything the Juicer permitted before, it still permits.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: every statement is guarded on the text it replaces.

-- 1. Widen the allowed list. Scoped to the juicer row, and guarded so a re-run
--    finds nothing to replace.
UPDATE imported_classes
   SET markdown = replace(markdown, 'only: ["none"]
  note: "Racial Requirement: 95% human.', 'only: ["none", "dwarf", "elf", "ogre"]
  note: "Racial Requirement: 95% human.')
 WHERE class_id = 'juicer' AND instr(markdown, 'only: ["none"]
  note: "Racial Requirement: 95% human.') > 0;

-- 2. Record the book's rule in the note, which is what the wizard shows when it
--    refuses a pairing. One line: the YAML reader here is line-based.
UPDATE imported_classes
   SET markdown = replace(markdown, 'RUE p.81."', 'RUE p.81. Rifts World Book 10: Juicer Uprising p.16-17 widens this: Dwarves take the standard process unpenalised (but never Phaeton or Hyperion), Elves need tailored drugs, Ogres are close enough to human for any conversion, and True Atlanteans qualify but have no R.C.C. row in this catalog yet. Trolls, Orcs, Goblins and Giants cannot be Juicers at all, nor can dragons, shapeshifters or supernatural beings."')
 WHERE class_id = 'juicer' AND instr(markdown, 'RUE p.81."') > 0;

-- 3. Append the prose. The body already ends by pointing at this book for the
--    variants, which is the anchor. One string literal rather than a chain of
--    || char(10) || - SQLite caps an expression tree at depth 100 and a long
--    chain is one node per term.
UPDATE imported_classes
   SET markdown = replace(markdown, 'This is the "Classic" Juicer - see Rifts World Book 10: Juicer Uprising for variants.', 'This is the "Classic" Juicer - see Rifts World Book 10: Juicer Uprising for variants.

## Non-Human Juicers

Rifts World Book Ten: Juicer Uprising, printed 16-17, revisits the "95% human"
line and names who else can survive the process.

**True Atlanteans** can undergo it and gain the physical bonuses in full, and
their metabolisms carry them 10 +1D6 years rather than the usual span - fifteen
or sixteen is not uncommon. They also detox better: +25% to the Detox Success
Ratios (to a maximum of 98%), and they still have a 25% chance in the seventh
year, 12% in the eighth, 5% in the ninth and 1% in the tenth. Past ten years as
a Juicer, no chance at all. Given a normal life span of 500 years or more, an
Atlantean has a great deal more to lose.

**Dwarves** use the standard human process with no penalty, and can be Titan,
Mega or Dragon Blood Juicers - but NOT Phaeton or Hyperion, whose reflex
enhancements burn out the dwarven nervous system outright. **Elves** need
specially tailored drugs, developed in Kingsdale and in New Lazlo (illegally
there, by underground body-chop-shops), and can be any Juicer type. Neither race
gains much for it: dwarves add 4D6 months to their life expectancy and elves
1D4x10 months, against natural spans two to six times a human''s. That is why few
elves consent short of revenge or obsession, and why some dwarven warriors form
"berserk societies" and take the change to defend their people.

**Ogres** are Neanderthal-like enough to take any of the conversions.

**Trolls, Orcs, Goblins and Giants** cannot: no variant of Juicer augmentation
works on them. Neither can dragons, changelings, pleasurers, nightbanes,
werebeasts or any other shapeshifter, nor demons, vampires or other supernatural
beings - all are too alien for a bio-comp to read. **Mutant animals** are
usually allergic, and roughly 80% of those exposed suffer lethal or near-lethal
reactions. Only the Splugorth bio-wizards of Atlantis have made anything
comparable work on Gargoyles and Brodkil, using magic and symbiotes rather than
drugs.

**What the frontmatter can and cannot say.** `race_restrictions` names race ids.
This catalog holds `dwarf`, `elf` and `ogre` as Palladium Fantasy rows, and
naming them is the right reading rather than a stretch: the book itself calls
these races Palladium-World D-Bees. There is no True Atlantean row at all, so
that allowance is recorded here and cannot appear in the picker until one
exists. The list stays an `only`, which fails CLOSED, so this widens what the
Juicer permits without loosening anything that was already refused.')
 WHERE class_id = 'juicer' AND instr(markdown, 'Non-Human Juicers') = 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'only: [' || char(34) || 'none' || char(34) || ', ' || char(34) || 'dwarf' || char(34)) > 0 AS widened,
       instr(markdown, 'Juicer Uprising p.16-17 widens this') > 0 AS note_updated,
       instr(markdown, 'Non-Human Juicers') > 0 AS prose_added,
       instr(markdown, char(13)) > 0 AS has_cr,
       length(markdown) AS bytes
  FROM imported_classes WHERE class_id = 'juicer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zz-race-juicer-non-human.sql');
