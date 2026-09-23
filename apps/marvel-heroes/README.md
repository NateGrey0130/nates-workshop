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

## Layout

| path | what |
|---|---|
| `index.html`, `app.js` | the page and its entry module, the only code that touches the DOM |
| `styles.css` | the whole visual system; contrast is pinned by the smoke test |
| `palette.html` | the palette sample, for review; removed at launch |
| `data/ranks.json` | the rank ladder: standard number, range, initial number |
| `data/universal.json` | the Universal Table: d100 bands, a colour per rank, and what each colour means per FEAT |
| `data/random-ranks.json` | the five Random Ranks columns |
| `data/tables.json` | range, area of effect, movement and simultaneous actions, as printed |
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
