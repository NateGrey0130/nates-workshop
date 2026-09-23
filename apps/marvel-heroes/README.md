# Marvel Heroes

A hero generator, a power browser and a FEAT roller for TSR's MARVEL SUPER
HEROES Advanced Set, built from the *Ultimate Powers Book*. It is a standalone
app: a different game system from the Palladium apps, and deliberately
separate from them.

**Status: under construction, and not on the hub.** The manifest entry lands in
the PR that makes the generator work (Nate's decision, 2026-09-23), so until then
the page exists at `/apps/marvel-heroes/` behind Access and nothing links to it.
`test/smoke.mjs` pins that.

## Sources

| short | book | used for |
|---|---|---|
| UPB | *Ultimate Powers Book* (TSR 6876, 1987), with the *Dragon* #122 addenda printed in red | the generator's tables and the 263 powers |
| PB | MARVEL SUPER HEROES Advanced Set, *Players' Book* | rank ladder, Universal Table, Talents, Contacts |
| JB | MARVEL SUPER HEROES Advanced Set, *Judge's Book* | example heroes and the sheet layout (later) |

Citations are to the page number printed on the page.

## What this app does not touch

- **No shared stylesheet.** Its palette, "Newsprint", is declared entirely in
  `styles.css`. The only shared things it uses are the self-hosted font files
  and the favicon.
- **Not in the RPG suite.** It loads no `shared/js/appnav.js` and carries no
  `data-appnav`.
- **Not in the Palladium catalog.** No catalog table, no `scripts/books.json`
  entry, no OCR cache, no README count.

## Book text stays out of git

This repository is public. The data files here hold **mechanics** - codes,
ranks, ranges, dice bands, page numbers - and **short summaries written for this
app**, never the books' prose. Where the full text of a power is wanted it lives
only in D1, loaded from an extraction that is written to the gitignored
`.cache/msh/` and never committed.

### The one table: `msh_power_text`

| column | what |
|---|---|
| `code` | the roll tables' code (`D1`, `MCo3`), or a bare class code (`MG`) for a section's introduction |
| `name` | the table's name for the Power, or the section heading |
| `page` | the printed page the listing starts on |
| `body` | the listing's text, folded to ASCII |

Migration `081`. The `msh_` prefix marks it as this app's in the shared
database. **Its rows are never in the repo**, so a database built from the repo
has it empty; `/api/marvel-heroes/power-text` then answers 404 `missing: true`
and the app shows the committed summary.

**Loading it.** On the machine with the PDF:

```bash
python scripts/msh-extract.py "<path to the Ultimate Powers Book PDF>"
node scripts/d1-apply.mjs --remote .cache/msh/power-text.sql
```

The extractor finds each listing by walking the roll tables' codes in order,
because nine headers print a code other than the table's (`D20/True Sight` is
DT20, a bare `MC/Machine Animation` is MC9, `T17/Telereformation` is T18) and
many lines open with a code that is only a cross-reference. It refuses to
write anything unless the book's index names the same 263 codes as the roll
tables. In a worktree, set `WORKSHOP_MSH_CACHE` to the main checkout's
`.cache/msh` so both the extractor and the suite's leak check find it.

**The leak check.** When the extraction is present, the smoke suite compares
every tracked and untracked file under this app, its endpoint, the extractor
and the migration against every run of ten words in the book's power text, and
fails on any match. CI has no extraction and says the section skipped.

## Rulings

**Where the books disagree, the Ultimate Powers Book wins**, because it was
published later (Nate, 2026-09-23). Within the UPB, the addenda outrank the main
text, and where one of its tables contradicts itself the index on pp.101-104
decides. Every ruling is listed here with both page numbers, and every data
entry that needed one carries a `ruling` field pointing back to this list.

- **R1** Random Ranks Table, column 2: **Good is 76-95**. Both UPB p.12 and
  PB p.6 print Typical 26-75 and Good 78-95, so no roll gives 76 or 77. Neither
  book says which rank owns them; the band after the gap takes them, the
  smallest change that makes the column cover every roll.
- **R2** **Remarkable is 26-35 and Incredible is 36-45.** The Universal Table on
  the PB back cover prints 26-36 and 37-45. UPB p.12 starts Incredible at 36,
  and so do PB p.2's rank table and PB p.6's Random Ranks Table. The UPB wins,
  and the PB agrees with it everywhere except its back cover.
- **R3** **Monstrous is 63-87.** PB p.2 prints 63-67, which would leave 68-87
  belonging to no rank; the PB back cover prints 63-87, and Unearthly starts at
  88 in both.

The Physical Form table (UPB p.3) prints five bands that cannot all be true;
each has exactly one reading that makes the table cover every roll once:

- **R4** Induced Mutant is **27-30**. Printed 26-30, overlapping Normal
  Human's 01-26; the band printed first keeps the shared number.
- **R5** Modified Human (Organic) is **48-49**. Printed "48-19".
- **R6** Modified Human (Muscular) is **50-51**. Printed "60-61", which would
  overlap Faun and Felinoid and leave 50-51 to nobody.
- **R7** Avian is **65-66**. Printed "66-66", leaving 65 to nobody.
- **R8** Cyborg (Mechanical Body) is **75-76**. Printed "76-76", leaving 75 to
  nobody.
- **R9** Counts table, 67-75: **6/8 Powers**. Printed 2/8, the only break in
  a column that otherwise climbs 1, 2, 3, 4, 5, then 7, 8 and on (UPB p.14).
- **R10** Self-Alteration: Body Adaptation is **22-27**. Printed 21-27,
  overlapping Blending's 20-21 (UPB p.16).
- **R11** Travel: Rocket is **53-56**. Printed 52-56, overlapping
  Levitation's 47-52 (UPB p.17).

Four body types the book never gives a Random Ranks column:

- **R12** Cyborg (Limbs and Organs) and Cyborg (Exoskeleton) roll on
  **column 3**, the column the book gives the one other Cyborg built around an
  intact human body (Mechanically Augmented), and the Players' Book's column
  for heroes whose power is equipment.
- **R13** Other Demihuman rolls on **column 2**, the column the named
  Demihumans use most (Faun, Harpy, Chiropteran and Merhuman).
- **R14** Compound: the book says the column is "determined by the A/D
  percentage" and gives no mapping. The column is **the number of aspects**:
  two aspects roll on column 2, five on column 5.
- **R15** Avian, Angel/Demon and Animal each come in two kinds the book tells
  apart without saying how to choose. **The player picks; a random hero gets
  either with even odds.**
- **R16** Modified Human (Extra Parts) **takes the Modified Human rules**: one
  Power fewer, and a Contact who did the modifying. The book states both for
  "all Modified Humans" and gives Extra Parts its own paragraph without
  repeating them; the Physical Form table files it under Modified Human.

**The book's own worked examples cite rolls its table does not give** - its
Compound example calls 69 Chiropteran (the table's Merhuman) and its Changeling
example calls 83 a Humanshape Robot (the table's Usuform). They read as written
against an earlier draft of the table, so the tests use them by body type, not
by roll, and they decide nothing here.

## Layout

| path | what |
|---|---|
| `index.html`, `app.js` | the page and its entry module, the only code that touches the DOM; one tab per tool |
| `js/dice.js` | one seedable generator (Mulberry32) and the dice built on it, so any roll can be replayed; the suite pins seed 12345's opening rolls |
| `js/browser.js` | the power browser's search: an exact code, else every word in the name or summary (name hits first), narrowed by class and by two-slot Powers; related Powers resolved to names |
| `js/feat.js` | a FEAT on the Universal Table: rank from a rank number, column shifts that stop at the ladder's ends, the colour a roll gives, and what that colour means for each kind of FEAT |
| `styles.css` | the whole visual system; contrast is pinned by the smoke test |
| `palette.html` | the palette sample, for review; removed at launch |
| `data/ranks.json` | the rank ladder: standard number, range, initial number |
| `data/universal.json` | the Universal Table: d100 bands, a colour per rank, and what each colour means per FEAT |
| `data/random-ranks.json` | the five Random Ranks columns |
| `data/tables.json` | range, area of effect, movement and simultaneous actions, as printed |
| `data/body-types.json` | the Physical Form table, what each body type does to a hero, and the Compound and Changeling aspect tables |
| `data/origins.json`, `data/weakness.json` | Origin of Power, and the three Weakness rolls |
| `data/counts.json` | how many Powers, Talents and Contacts, and what extra ones cost in Resources |
| `data/power-tables.json` | the sixteen power classes and their roll tables, 263 codes; `double` is the book's asterisk, `addenda` its red rows |
| `data/talents.json`, `data/contacts.json` | the PB's Talent categories and Appendix B; its Contact types and Appendix C |
| `data/powers.json` | the 263 Powers: page, range column, one-line summary, and the bonus, optional and nemesis Powers each names - by code where the name is a Power, by name where it is a category or a description |
| `/functions/api/marvel-heroes/power-text.js` | GET one Power's full text from `msh_power_text`; signed-in users only |
| `/scripts/msh-extract.py` | builds the full-text data script into `.cache/msh/` from the PDF |

The summaries in `powers.json` were written for the app by four subagents
working from the extraction, each told to reuse no five-word run of the book's
text, then checked together: none shares a six-word run with any Power's text.
| `test/smoke.mjs` | file-wide checks (ASCII, LF, parse), the stylesheet boundary, contrast, and the data: every d100 table covers 01-00 once, the ladder is unbroken, every ruling is logged |

**The Universal Table's colours were read from the page, not by eye.** Its
cells are vector fills on the PB back cover, and each cell's colour was taken
from the fill under the centre of that row and column. The printed table stripes
every third row in a darker shade; that carries no meaning and is folded into
its colour.

Run the suite from anywhere:

```bash
node apps/marvel-heroes/test/smoke.mjs
```
