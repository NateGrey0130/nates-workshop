# Why each audit-menu rule exists

`SKILL.md` states the rules; this holds the incident or measurement behind
each, for when a rule looks wrong. Read an undated claim as true on the day it
was written.

## Counts of menus

The opening paragraph said "Eight files" while its table listed ten and the
tree held twelve; by the correction the tree held fourteen, wrong within the
week. Every ordinal there was wrong every time anyone read it, including the
one that replaced the last wrong one. The protocol was reconstructed from the
files nine times before the skill existed.

## The shape of a finding

- Until 2026-09-03 every brief in `docs/prompts/` re-derived the research
  discipline in its own words (*"Verify, don't infer"*, *"Do not quote a count
  you did not verify"*, and three more), and this file owned none of it.
- `REPO-AUDIT.md` had no brief on this machine and carries the largest share of
  wrong claims: a correlation, not a demonstrated cause (different subjects,
  small numbers).
- *Effort* was dropped because `REPO-AUDIT` `G8` shipped far smaller than
  proposed and `G5` grew a second defect while being taken.
- The fields come from `health-audit-prompt.md`'s template, minus the two that
  rot. `HEALTH-AUDIT` carries `Evidence` on every finding and `Confidence` on
  all but one; `HEALTH-AUDIT` `F18`'s low-confidence half was the half that
  moved when it was taken. Cost: roughly a quarter of an hour on a menu of any
  size. `META-AUDIT` `A9`.

## Taking is auditing

- `REPO-AUDIT` `G8` said the suite had never run on a bare clone; a bare clone
  passes everything (all 1662 checks). One such error would have shipped a
  silent bug if implemented as written.
- `SKILL-AUDIT` `F4` confirmed both premises, then caught two of its own
  replacement sentences being false by measuring the fix.
- Premises that held exactly: `HEALTH-AUDIT` `F5`, `F7`, `F9`, `F23`;
  `MACHINE-AUDIT` `M4`, `M6`, `M15`, `M16`; `SKILL-AUDIT` `F2`, `F4`, `F11`,
  `F15`.

## The subject grep

- `REPO-AUDIT` `G9` proposed renaming `SETUP-v2-CHANGES.md` to fit the glob;
  `HEALTH-AUDIT` `F4` had chosen the opposite the day before, in PR #523, with
  reasons. `G9` had verified its own facts twice.
- `REPO-AUDIT` `G10` proposed numbering the data scripts; `SKILL-AUDIT`
  `F25(b)` had closed that in PR #567, ending *"recorded so it is not
  re-proposed"*. `G10`'s note is the model: it names `F25(b)`, quotes it, and
  argues past it.
- `REPO-AUDIT`'s scope statement handed territory to a `PORTABILITY-AUDIT.md`
  dropped the day before.
- `REPO-AUDIT` `G18` proposed the evidence line as new; two menus had written one
  on every finding since the day before.
- `BOOK-INGEST-AUDIT` `F33` proposed building a gear duplicate detector;
  `findDuplicates` was live, rewritten for gear by `INGESTION-AUDIT` `F29` two
  days earlier. Run against production, it found three of `F33`'s four pairs and
  missed the fourth by 0.033, which re-scoped the work from *build a detector*
  to *add somewhere to record the answer*. `F33` was filed by a session that had
  not run the grep; the three findings taken on 2026-09-08 were its first real
  use, which is why it runs at take time.

## The hand-over pass

Of the thirteen findings open when `REPO-AUDIT` ran its pass, it found `G11` and
`G15` materially wrong and flagged `G6` as right by luck (verified *enabled*
while asserting *empty*). That menu's other three wrong claims were already
taken; the pass never saw them. `META-AUDIT` `A10`.

## Claims about another file

Of the four false premises on `SHIP-PR-AUDIT`, every one was a claim about what
a different file said:

| the sentence | what was true |
|---|---|
| `REPO-AUDIT` `G7`: the PR body convention *"exists only inside the `ship-pr` skill"* | it was in no file at all |
| `F12`: asked this skill to say its table is not a list of menus | it already said so, in the paragraph above the table |
| `F14`: a paragraph *"beside the existing exit-code material"* in `windows-shell` | there was none |
| the menu's own header | stated the wrong cost for filing a new menu |

`CLASS-AUDIT` `F17` reported missing attribute requirements in seven classes;
five were false, because the classes held them in multi-line blocks and the
audit grepped the inline `{ }` form. `SHIP-PR-AUDIT` was filed at 20:48 on
2026-09-03, three and a half hours after the hand-over pass landed and five days
after *"an absence claim needs a fresh read"* was written here: five rules, four
false premises. Rules that are read do not fire; a job that runs does. The table
above trips `menu-check` itself, which is why the claim-ok marker exists.

## Stale citations

- A false class-note claim reached production and stayed for three PRs, then
  recurred three times in one day (two Prometheans and the Fallen Cosmo-Knight).
- `INGESTION-AUDIT`'s header said this skill still called F14 open; the skill
  was corrected eleven minutes later and nothing revisited the header
  (`SKILL-AUDIT` F20).
- `MEMORY.md` said the health audit's findings were all closed; a new one merged
  seventeen minutes later (`SKILL-AUDIT` F16).
- This skill said F14 was open for five days after it shipped (`HEALTH-AUDIT`
  F22).

## Prefixes

Established 2026-09-03 by walking every menu's headings. The table carried
counts until 2026-09-04 (`META-AUDIT` `A14`): the `F` row said eleven at 13:50
and was false by 20:48, and `META-AUDIT`'s `A` was missing the same day.
Removing an ordinal beats incrementing it (`SKILL-AUDIT` `F7`). `S`, `T` and
`P` are absent from the census because they are not headings.
`REPO-AUDIT.md` G12/G13.

## Outcome notes

- `INGESTION-AUDIT` F14 describes the note format and quotes it, so every grep
  reported it taken from 2026-08-26, when filed, until 2026-08-28, when it
  shipped in PR #364: two days confidently right about a question it had not
  looked at. A coincidence is not a check.
- `INGESTION-AUDIT`'s F12, F16 and F19 close as moot in a retirement section
  ~1,300 lines from their headings; on one page the two errors cancelled into a
  plausible total and a PR shipped the wrong count.
- On 2026-09-02 an audit's census split a finding's block on an inline `**F10 …**`
  cross-reference, and `apps/character-creator/AUDIT.md`'s header caught its
  third scan misreading D1–D6.
- Closed files were split out on 2026-09-16.

## Status headers

The widest header ran to 98 lines naming 33 findings, and the menu that audited
every header carried a stale one within a day (`META-AUDIT` `A13`).
`SHIP-PR-AUDIT`'s *"None of these is taken. Nothing below has been decided"*
sits above four decided findings and contains no finding number, so no sweep
sees it (`META-AUDIT` `A17`). `SKILL-AUDIT` `F42` moved arrangement prose from
the shape table into headers on 2026-09-04.

## The heading table

Read on 2026-08-31 it was missing two files and wrong about three cells;
2026-09-02, missing four; audited the same day, right on thirteen rows of
fourteen and wrong on one cell (`DOCS-AUDIT` `D5`'s `WITHDRAWN`); 2026-09-03,
missing four, one of them the menu doing the reading; 2026-09-04, missing one,
again the reader's own (`SHIP-PR-AUDIT` `F12`). The cells have been reliable
and the roll-call has not. The over-return from `docs/prompts/` went unstated
until `META-AUDIT` `A7`, and `REPO-AUDIT` `G11` miscounted the root with the
command and was re-scoped for it. On 2026-09-03 three sources described one
menu's status and all three disagreed.

## Records

PR #310 established the banner rule: three audit files cited a README layout
that no longer existed and each gained a banner plus
`scripts/readme-section.mjs`, rather than having paths edited.

## Reasoned-to claims

`REPO-AUDIT` `G8` (never runnable on a bare clone), `G5` (merge commits used
"exclusively", against 117 squash merges) and `G15` (a deploy path with "no
signal", while the tool reported it). Every claim in that menu that came from a
command someone ran survived re-measurement. `G1` shipped a verification command
that counted 117 squash-merged PRs as direct pushes; nobody had run it.
`REPO-AUDIT.md` G18; `META-AUDIT` `A8`, `A9`.

| menu | findings | `**Evidence**` | `**Confidence**` |
|---|---|---|---|
| `HEALTH-AUDIT.md` (2026-09-02) | 24 | 24 | 23 |
| `SKILL-AUDIT.md` (2026-09-02) | 25 `F` | 25 | 0 |
| `REPO-AUDIT.md` (2026-09-03) | 18 | 0 | 0 |

## Placement

`REPO-AUDIT.md` G11 stated the placement question by counting menus per
location and got both numbers wrong, counting with the glob that misses
`SETUP-v2-CHANGES.md`.

## Deferrals

Measured 2026-09-06 at `c54a794`: four deferrals standing with no number. Two
were caught later as one-offs (`META-AUDIT` `A5`, `SKILL-AUDIT` `F32`); one
resolved itself and left its record asserting a false condition; the rest were
true and invisible, the oldest ten days old. PR #644 filed `pick3cut5/AUDIT`
`F11` and `F12` while taking `A5` and took neither. `META-AUDIT` `A16`.

## The apparatus pause

Seven menus were filed on 2026-09-02 and 2026-09-03 and none was about an app
or the data (`SKILL-AUDIT`, `META-AUDIT`, `SHIP-PR-AUDIT`, `REPO-AUDIT`,
`HEALTH-AUDIT`, `MACHINE-AUDIT`, `DOCS-AUDIT-2`). The last product menus were
`UI-AUDIT` and `REDESIGN-AUDIT`, 2026-08-31.
