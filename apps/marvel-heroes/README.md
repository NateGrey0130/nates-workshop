# Marvel Heroes

A hero generator, a power browser and a FEAT roller for TSR's MARVEL SUPER
HEROES Advanced Set, built from the *Ultimate Powers Book*. It is a standalone
app: a different game system from the Palladium apps, and deliberately
separate from them.

**On the hub since the launch PR.** Until the generator worked the page existed
at `/apps/marvel-heroes/` behind Access with nothing linking to it (Nate's
decision, 2026-09-23); `test/smoke.mjs` now requires its live tile. Six tabs,
each linkable: `#feat`, `#powers`, `#gen`, `#pb` (Point Buy, below), `#heroes`
(the heroes a person has saved) and `#gear` (the Players' Book weapons and
vehicles).

## Point Buy

A second way to make a hero, and **a house rule, not from any book** (R24). The
GM gives a point limit and the highest rank allowed; the player buys the seven
abilities and any Powers, and a total stays at the top of the screen while
they do. It goes amber with less than a tenth of the limit left, and red once
it is over.

- **An ability costs its exact rank number.** Excellent 24 costs 24. Any
  number can be typed, or the up and down buttons step to the next rank's
  standard number (24 up is Remarkable 30, down is Excellent 20).
- **Choosing a Power costs nothing; its rank costs its number**, and a Power
  the UPB marks `*` (two slots) pays double. There is no limit on how many.
- **Nothing else costs points.** Resources and Popularity are picked freely.
  A Point Buy hero has no body type, origin, weakness, Talents or Contacts.
- **The GM's grants** - Powers, ability bonuses (a flat amount added to the
  number), and anything else written down - each carry an "Exclude from
  points" tick, on by default. They also ignore the cap.
- **Going over the limit, a rank above the cap, or a blank ability warns
  and still saves.** The GM decides.

Each line offers the most it can afford, and a new Power starts at the most
the budget allows, up to Good. For scale, the tab prices 400 rolled heroes
the same way (fixed seed, so the figure does not move) and says what a
typical one costs. The last limit and cap are remembered in the browser.

## Sources

| short | book | used for |
|---|---|---|
| UPB | *Ultimate Powers Book* (TSR 6876, 1987), with the *Dragon* #122 addenda printed in red | the generator's tables and the 263 powers |
| PB | MARVEL SUPER HEROES Advanced Set, *Players' Book* | rank ladder, Universal Table and its Effects columns, Talents, Contacts, weapons and vehicles |
| JB | MARVEL SUPER HEROES Advanced Set, *Judge's Book* | the character sheet's layout. Its Marvel characters are deliberately not in the app (Nate, 2026-09-23) |

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

### `msh_power_text`

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

## Saved heroes: `msh_heroes`

The generator's **Save hero** writes the hero to D1, and **My heroes** lists
them, opens each on a sheet laid out after the Judge's Book character sheet, and
prints it. Migration `082`.

| column | what |
|---|---|
| `id` | a UUID the endpoint makes; the page never chooses one |
| `owner_email` | the Access email that saved it. **Every query is scoped to it**, as MediaVault's are, so a hero someone else owns answers exactly like one that does not exist |
| `name` | the hero's name, 80 characters at most |
| `build` | JSON: the generator's seeds and picks, so the hero reopens in the generator exactly as it was made - or, for a Point Buy hero, `{ mode: 'pointbuy', pb }` with what was bought, which reopens it on that tab |
| `snapshot` | JSON: what that built, resolved to names and numbers at save time. **The sheet draws only from this**, so a later correction to a table here cannot quietly change a saved hero |
| `sheet` | JSON: what the player writes on the sheet - identity lines, background, notes - and the numbers tracked in play (Health and Karma now, Karma pool, Advancement fund) |

`/api/marvel-heroes/heroes` is GET (a list, or one hero by `?id=`), POST (no
id saves a new hero; an id updates one the caller owns, and anything else is a
404) and DELETE. A save from the generator sends no `sheet`, which keeps the
one already written. The checks every write passes through - known sheet fields
only, lengths, 48 KB per JSON column, 200 heroes each - are in
`functions/api/marvel-heroes/_lib/heroes.js`, and the suite runs the endpoint
against migration 082 itself in `node:sqlite`.

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

Two the generator needed, where the books say nothing (`js/generator.js`):

- **R17** **Powers a body type grants come with the body and take no Power
  slot** - a Chiropteran's Sonar, a Vegetable's Absorption, a Deity's Travel
  Power. The UPB's Bonus Powers (a Power's listing naming another) are a
  different thing, and those do fill a slot, as the addenda on p.13 says.
- **R18** **A body type's column shifts stop at Feeble and Monstrous** for
  Primary Abilities, the Players' Book's rule for ability modifiers (PB p.6). A
  Deity who rolls Amazing Strength is Monstrous, not Unearthly. Resources and
  Popularity may still fall to Shift 0, the "zero" several body types set.
- **R19** **A Changeling has at least as many Power slots as it has forms.**
  UPB p.10 requires each form to have a Power no other form has, and a hero
  can roll fewer Powers than forms; the slots rise to make the rule
  satisfiable. The first Power in each slot belongs to one form, the rest to
  all of them.

Four more come from the Players' Book equipment tables (PB pp.42-49), which were
transcribed twice, blind, and agreed cell for cell - so each of these is the
book, not a slip:

- **R20** Motor Trike and Jeep are **Off-Road**. Printed "Oft-Road" (PB p.48).
- **R21** The **Security Limo**, with **Remarkable** Body and Protection.
  Printed "Security Lime" with "Re" in both, which is no rank; the prose calls
  it a limo, and Rm is the one rank abbreviation it can be.
- **R22** The eight unnamed rows under "(also explosives)" in Other Weapons Cost
  are **more Knock-Out Gas, or explosive, filling one area**, at rising
  intensities. They carry on that entry's list with no name of their own (PB
  p.46).
- **R23** The **Fantasticar takes the table's figures** (Control Ex, Speed In,
  Body Gd). Its description on PB p.52 gives Control In, Speed Ex, Body Ty; the
  table is the book's statistics and the description is colour.

And one that is not from any book at all:

- **R24** **Point Buy is a house rule** (Nate, 2026-09-24): abilities cost their
  exact rank number, a Power's rank costs its number and double for a `*`
  Power, choosing a Power is free, the GM's grants are excluded by a tick and
  ignore the cap, and going over warns rather than refuses. See *Point Buy*
  above; the rules are in `js/pointbuy.js`.

How a Compound and a Changeling are built (UPB pp.9-10): a Compound rolls how
many body types it combines and the chance of keeping each trait (50%, 33%,
25%, 20%), then rolls each type - never Compound or Changeling again, never the
same type twice - and keeps each of that type's traits (a column shift, a set
rank, a body Power, a Power more or fewer, a free +1CS, a Health multiplier, a
Contact rule) on a d100 at or under the chance. Its own -1CS Popularity comes
on top, and any artificial type makes it a Cyborg. A Changeling rolls its forms
the same way, rolls its abilities once on column 5, and applies each form's
whole set of traits to its own copy; it rolls past Alter Ego.

And three the generator applies from the Players' Book because the UPB is
silent, none of them in conflict with it: every hero's Power ranks roll on
column 4 (PB p.9); a Power rolled twice, or a two-slot Power with one slot
left, is rolled again (PB p.9, UPB p.14); buying extras never takes Resources
below Feeble (PB p.7).

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
| `js/generator.js` | the seven steps as one pure function: a hero is `build({ seeds, picks })`, one seed per step, so rerolling a step is a new seed for it, locking a step keeps it, and changing the body type re-reads the SAME ability dice on the new column. The suite pins seeds 1-7 and runs 2,000 random heroes against the rules |
| `js/feat.js` | a FEAT on the Universal Table: rank from a rank number, column shifts that stop at the ladder's ends, the colour a roll gives, and what that colour means for each kind of FEAT |
| `styles.css` | the whole visual system; contrast is pinned by the smoke test |
| `data/ranks.json` | the rank ladder: standard number, range, initial number |
| `data/universal.json` | the Universal Table: d100 bands, a colour per rank, and what each colour means per FEAT |
| `data/random-ranks.json` | the five Random Ranks columns |
| `data/tables.json` | range, area of effect, movement and simultaneous actions, as printed |
| `data/body-types.json` | the Physical Form table, what each body type does to a hero, and the Compound and Changeling aspect tables |
| `data/origins.json`, `data/weakness.json` | Origin of Power, and the three Weakness rolls |
| `data/counts.json` | how many Powers, Talents and Contacts, and what extra ones cost in Resources |
| `data/power-tables.json` | the sixteen power classes and their roll tables, 263 codes; `double` is the book's asterisk, `addenda` its red rows |
| `data/talents.json`, `data/contacts.json` | the PB's Talent categories and Appendix B; its Contact types and Appendix C |
| `data/equipment.json` | the PB weapon, ammunition, missile, grenade and vehicle tables and the vehicle damage list, as printed apart from R20-R23, with column keys written for the app |
| `data/powers.json` | the 263 Powers: page, range column, one-line summary, and the bonus, optional and nemesis Powers each names - by code where the name is a Power, by name where it is a category or a description |
| `js/gear.js` | the Gear tab's search, and reading a printed rank abbreviation back onto the ladder |
| `js/sheet.js` | a built hero to its saved snapshot, and the snapshot to the sheet's HTML; pure, so the suite runs it |
| `js/pointbuy.js` | Point Buy (R24): the ledger of what each line costs, the cap, the rank steps, the most a line can afford, a build to its snapshot, and what a rolled hero would cost |
| `/functions/api/marvel-heroes/power-text.js` | GET one Power's full text from `msh_power_text`; signed-in users only |
| `/functions/api/marvel-heroes/heroes.js`, `_lib/heroes.js` | save, list, open and delete the caller's own heroes, and the checks every write goes through |
| `/scripts/msh-extract.py` | builds the full-text data script into `.cache/msh/` from the PDF |
| `test/smoke.mjs` | file-wide checks (ASCII, LF, parse), the stylesheet boundary, contrast, and the data: every d100 table covers 01-00 once, the ladder is unbroken, every ruling is logged; the endpoints against a real database |

The summaries in `powers.json` were written for the app by four subagents
working from the extraction, each told to reuse no five-word run of the book's
text, then checked together: none shares a six-word run with any Power's text.

**The Universal Table's colours were read from the page, not by eye.** Its
cells are vector fills on the PB back cover, and each cell's colour was taken
from the fill under the centre of that row and column. The printed table stripes
every third row in a darker shade; that carries no meaning and is folded into
its colour.

Run the suite from anywhere:

```bash
node apps/marvel-heroes/test/smoke.mjs
```
