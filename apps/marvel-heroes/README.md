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

None yet.

## Layout

| path | what |
|---|---|
| `index.html`, `app.js` | the page and its entry module, the only code that touches the DOM |
| `styles.css` | the whole visual system; contrast is pinned by the smoke test |
| `palette.html` | the palette sample, for review; removed at launch |
| `test/smoke.mjs` | file-wide checks (ASCII, LF, parse), the stylesheet boundary, contrast |

Run the suite from anywhere:

```bash
node apps/marvel-heroes/test/smoke.mjs
```
