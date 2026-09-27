# Why each book-survey rule exists

`SKILL.md` states the rules; this holds the incident or measurement behind
each, for when a rule looks wrong. `WORKED-EXAMPLES.md` holds the longer worked
cases. Read an undated claim as true on the day it was written.

## Scale

The Book of Magic has ~1038 stat blocks; the invocation import needed 108.

## §0, the probe and the caches

- **`ocr-book.py`, not `python -c`.** Seven of the first eight caches were built
  by throwaway code in no commit, and they do not agree with each other; `ju`'s
  is raw `page.get_text()` with columns welded across the gutter. An argument
  here about whether `python -c` prompts was wrong twice, in opposite
  directions, as the working directory and its allowlist moved; the reason
  that stands does not depend on the allowlist.
- **Text-layer sizes.** Every text layer measured here medians 4,000–6,100
  characters a page and every scan medians zero. The Palladium Fantasy main
  book (median ~5,700) supplied twenty-five classes, fifty-seven spells and two
  authority tables through `read-columns.py` alone; Rifts Ultimate Edition has
  none. An earlier version of this skill led with "OCR it once, properly".
- **`welded_pages`.** Across the twelve text-layer caches: 42 welded pages in
  ten of them; `cb1` the only clean book; `pf`, the most-cited book, carrying
  six (`BOOK-INGEST-AUDIT.md` F30).
- **`corrupt_pages`.** Real damage shows at 3 and 4 hits as often as at 30.
  Free Quebec printed 95 reads `vsv&sis. \Vs. %\%vausttft`, and on the same
  page an M.D.C. table reads `- 115` where the ink says 175. Printed 95 is an
  encoding fault (a render fixes it; re-caching cannot); printed 118 shows `a\\`
  in the ink itself.
- **`substituted_digits`.** Measured 2026-09-10:

  | cache | `corrupt_pages` | `substituted_digits` |
  |---|---|---|
  | `new-west` | 3 | 75 |
  | `cb1` | 0 | 69 |
  | `bom` | 9 | 116 |

  A 600 dpi clip of New West printed 223 shows the page printing `!D4xlO` two
  words after a correct `4D6`. Almost every New West O.C.C. prints
  `Money: Starts with 3D4xlOO credits` (`BOOK-INGEST-AUDIT.md` F53). The key did
  not exist before 2026-09-10. `bom`'s largest entry is nine hits at cache 80,
  printed 79.

## §0b, caching

- **`WORKSHOP_OCR_CACHE`** since 2026-09-16: `git worktree` re-roots the repo, so
  root-derived paths pointed at an empty directory and two smoke sections
  failed.
- **The resume bug.** Keyed on both `txt` and `tsv` regardless of kind, a plain
  re-run against a text-layer cache resumed nothing and overwrote every page
  with Tesseract output. `bom` has a text layer, was OCR'd anyway, and now
  refuses a switch without `--force`.
- **DPI.** 300 → 600 dpi took one error class from 7 to 5; `--oem 1` changed
  nothing. `Ibs` scores 91–94 and `18.000` scores 93–97; 1.3% of words score
  under 70 and none of the known misreads among them.
- **Layout analysis.** `triax` p110 sets a fifteen-item bionics list beside a
  full-page plate; `--psm 3` lost items 11, 12 and 14 to the hatching, and a
  160 dpi render read all of 6–15 (`BOOK-INGEST-AUDIT.md` F39). Triax reprints
  the list elsewhere, which is a property of that book, not a method.
- `I.S.P.` reads as `LS.P.` on most pages of one scan, which is why the whole
  book is cached.

## §0c, rendering

| table | cache kind | what the cache gave |
|---|---|---|
| Attribute Bonus Chart (PF 16) | text layer | nothing findable |
| Types of Armor (PF 270) | text layer | column fragments on the next page, headers detached |
| Coalition SAMAS Pilot's skills (RUE 233) | scan | merged with the Grunt's column, six wrong numbers |

The third row sat under a column headed "what the text layer gave" for a long
time, filing the one scan case under the other kind.

## §0d, offsets

- `pf`: an extra page at cache `p018`/`p019`, so +1 for printed 1–16 and +2 for
  18–336. The vote over the whole cache is 287 to 11 for +2, and hunting the
  Attribute Bonus Chart with +2 finds nothing.
- This skill said `pf` was the only book with an exception for five days while
  `BOOK-INGEST-QUEUE.md` recorded `underseas` as the second; both written
  2026-08-28.
- A zero offset cost a wrong page read on the first attempt at the Godling. That
  book (Pantheons) is registered at `page_offset: 1`, and this skill once called
  it zero-offset, true in 0-based `pymupdf`, so a reader checking `books.json`
  saw a contradiction. The conversion table once labelled its first row
  "zero-offset book" with the `potm` values.

## §0e, priced prose

`20,000-\n30,000` became 2,000,030,000 under word de-hyphenation. The Cape of
Dimensions' 700,000 gold was filed under an item called *"Use Limits"*, and it
mentions 25,000 gold for a repair before its own cost line. `Contact poison:
Numbstrike:` prints four items under one name; the faerie foods price by band.
All 225 experience-table checks (low = previous high + 1) passed.

## §1–§2, inventory and authority

- The Book of Magic names a dozen R.C.C.s in a cross-reference list and defines
  one class, on page 224.
- Descriptions alone: 69 of 84 spells came back level 0.
- Read linearly, the Book of Magic's index put level-one `Blinding Flash` under
  level three and returned levels one and two empty.
- This skill once shipped its own copy of `read-columns.py` under `reference/`;
  the copy had forked (line-based, with a `probe()` helper the repo lacks) while
  every PF extraction ran the block-based script. It was removed.
- Too-strict patterns dropped every `Summon & Control ...`,
  `Doppleganger (Superior) (1,000)`, `(l)`, `(400 to 1000+)` and
  `(1,600 or Special)`.
- Leaving `Level:` out of the stop list broke The Finger of Lictalon and
  Metamorphosis: Dragon. The book prints *Invulnerability (limited)* where its
  index says *Invulnerability: Limited*.

## §3, the diff

| import | hand-rolled answer | truth |
|---|---|---|
| psionics missing | 21 | 16 |
| psionics wrong category | 23 | 0 |
| spells missing | 5 | 0 |

29 of 30 category "errors" were "Super-Psionics" vs "Super". `Telekinetic Push`
/ `Telekinetic Punch` are 2 apart and different; `Animate/Control Dead` /
`Animate and Control Dead` are 4 apart and the same. Roughly one in twenty
"missing" names was a false gap (`Tum Dead`, `Barrier ofThoth`). `WHERE system =
'rifts'` missed 129 spells stored with `system IS NULL` and reported 225 missing
where 106 were. Local once held 327 skills where production had 324, another
336 against 333.

## §4–§5, extraction and reconcile

- Supplying the level per batch still produced 13 rows one level too high,
  because headings sit partway down a page.
- Four RUE spells contradicted expectations; the book agreed with itself, and
  the expectations came from another edition.
- 108 of 108 costs agreed between stat block and index on one import.
- `Rift Teleportation` starts on p143 with its `P.P.E.:` on p144, which was a
  batch edge: the next batch produced a conflated, wrong-level, cost-0 row. This
  skill said "page break" until 2026-09-04 (`SKILL-AUDIT` `F41`), which was the
  wrong lesson; "slice edge" is the right briefing word.
- The Finger of Lictalon field appeared six times in 180 entries, five of them a
  category of their own.

## §6, shipping

Re-applying from scratch caught rows written by a failed confirm that the
script then skipped with `INSERT OR IGNORE`, leaving eight rows with a stale
note and a NULL `system`.

## §7, the survey

The 2026-08-25 efficiency audit first put the survey in `.cache/` beside the OCR
text, so no commercial text entered the repo; it moved once it proved not to
need quotes. Wormwood's survey was 251 lines with three quoted prose lines, all
paraphrased with the fact intact; it also carried two italic inline quotes the
smoke check cannot see. The same audit measured a PR costing 2–7× more late in a
session than early, and a mid-book reset dropped the carry from ~790K to ~235K
tokens per call with nothing lost.

## §8, batches

- Until 2026-09-25 each session appended to the queue, and parallel sessions
  always conflicted there. The queue carried a status column until 2026-09-24,
  and it disagreed with the surveys for eight days.
- Two sessions in one checkout put one session's commit on another's branch four
  times.
- Branches were named `<slug>-...` until 2026-09-27; `book-board.mjs` and
  `book-worktree.mjs` now strip a `<group>/<type>/` prefix first (#1476).

## The three tiers

Until 2026-09-07 the rule was an absolute ban, in `BOOK-INGEST-QUEUE.md` and
`docs/prompts/BOOK-INGEST-PROMPT.md`, and it was false on the day written and
for ten days after (measured with `git log` and `gh pr view --json files`).

- **Tier 1:** eleven book-session PRs edited `CORE_SDC_BY_CLASS` in
  `js/compose.js` (seven in `phase-world`, #406–#417; four in `triax`,
  #776–#779), before that map moved into class frontmatter on 2026-09-25.
- **Tier 2:** on 2026-09-07 one book produced a migration and three tables
  (#787), 55 vessel rows (#791), a parser/validator change (#789), and #794
  touching `app.js`, `sheet.js`, `js/parser.js`, `db/schema.sql`,
  `_lib/catalog.js` and `class-check-lib.mjs`, every piece asked for.

## What the deferral bought

Across 25 `BOOK-INGEST-AUDIT.md` findings the lag from filing to taking was
under a day, six the same day (read 2026-09-07). `phase-world`'s last book PR
merged at 09:05 on 2026-08-31 and the first deferred-code PR at 10:09: sixty-four
minutes, then 17 findings across 18 PRs that afternoon. `F23(b)` was proposed
and implemented by one session; the premise auditor broke seven of its claims,
including an inverted failure direction, and PR #795 fixed three more defects a
browser found.
