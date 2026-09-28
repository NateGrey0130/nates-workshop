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
vehicles). Three more links on the tab bar open pages of their own: the
**Codex**, **Campaigns** (`campaign/`) and **GM tools** (`gm/`).

## Codex

`/apps/marvel-heroes/codex/` is every list the app ships, one section at a
time: **Powers** (with the full text when `msh_power_text` has it), **Talents**,
**Contacts**, **Weaknesses**, **Gear and vehicles** and **Notable NPCs**. Each
section searches by word, filters by its own grouping (a Power's class, a
Talent's category, a gear table, an NPC's team), and opens a card for the
detail. The address carries the view -
`?section=`, `q=`, `group=` and `entry=` for one open card - so a filtered
list or one entry is a link; a value the page does not offer is dropped.

It is separate from the Palladium codex (`apps/codex/`), which belongs to
another group and reads another database. It borrows that page's idea, one
descriptor per section, and none of its code: `SECTIONS` in `js/codex.js` is
the whole list. It is a page of this app, reached from the hub through its own
`apps/manifest.json` entry (`marvel-heroes/codex`).

### Notable NPCs

The characters of the Marvel sourcebooks, MA1 *Children of the Atom* first
(`docs/surveys/ma1.md`): 172 names from the book's printed pp.4-81.
- **One card per printed name.** Its **versions** are the book's entries under
  that name: Phoenix original and current, Thunderbird original and current.
  Each version's **blocks** are its stat grids, so forms and tiers are
  labelled blocks: Ursa Major's Human Form and Bear Form, the Brood's three.
- **A cross-reference** (Magneto on p.30, Rogue on p.34) is an *appearance*
  on the character, with its text. No block is derived from an early-version
  modifier.
- **A team member the book gives no block of its own** (the Savage Land
  Mutates, the Imperial Guard) is listed by name and page under its team.
- A Power whose name is an Ultimate Powers Book power, or is in
  `data/npc-power-aliases.json`, links to that Power's card.

`data/npcs.json` is **facts only**: names, the identity lines under a header,
every grid's numbers and rank codes, Health, Karma, Resources and Popularity as
printed, power and member names, and pages. Each misprint the book's own
arithmetic exposes keeps both values, the printed one and the corrected one
(`override`). A rank code the OCR could not read, and so derived from its
number, is listed under `derived`. The book's sentences are in
`msh_book_text` only, and each card fetches its entries' text when it opens.
Without that table the card shows the statistics and says the text is not
loaded.

**In a campaign.** The GM tools' **Add an NPC from the book** puts any of them
in a campaign as an NPC sheet, hidden until shown, like a rolled NPC. The
sheet is the hero shape with `mode: 'book'` (`js/npc-book.js`), under the same
`SNAPSHOT_VERSION`, as Point Buy's `mode: 'pointbuy'` is, so saved heroes are
untouched. What makes it different:
- **Its abilities are the printed numbers**, placed on the ladder by the
  number's range, not by the printed code.
- **Each misprint is played corrected** (Northstar's Health is 90, not the
  printed 70).
- **Forms** (Ursa Major's Human and Bear) are forms; a **tier** (the Brood
  Queen) is one choice among its version's blocks.
- **It has no body type, origin or weakness, and its Powers no rank**,
  because the book gives a Power's rank in prose. The sheet links to the
  Codex card for that, and for its Talents and Contacts.

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
- **Not in Palladium's database.** Since 2026-09-25 this app's tables live in
  a D1 of their own, `nates-workshop-marvel`, bound as `DB_MARVEL` and built
  from `db/schema-marvel.sql`; its migrations are in `db/migrations/marvel/`.
  Its endpoints use no other binding, and `groups.mjs --check` fails if one
  reaches another group's binding or names another group's table. The Marvel group is this app alone
  (`groups.json`).

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

Migration `081`, in `DB_MARVEL`. The `msh_` prefix dates from when it
shared a database with the Palladium apps. **Its rows are never in the repo**, so a database built from the repo
has it empty; `/api/marvel-heroes/power-text` then answers 404 `missing: true`
and the app shows the committed summary.

**Loading it.** On the machine with the PDF:

```bash
python scripts/msh-extract.py "<path to the Ultimate Powers Book PDF>"
node scripts/d1-apply.mjs --remote --db marvel .cache/msh/power-text.sql
```

The extractor finds each listing by walking the roll tables' codes in order,
because nine headers print a code other than the table's (`D20/True Sight` is
DT20, a bare `MC/Machine Animation` is MC9, `T17/Telereformation` is T18) and
many lines open with a code that is only a cross-reference. It refuses to
write anything unless the book's index names the same 263 codes as the roll
tables. In a worktree, set `WORKSHOP_MSH_CACHE` to the main checkout's
`.cache/msh` so both the extractor and the suite's leak check find it.

**The leak check.** When the extraction is present, the smoke suite compares
every tracked and untracked file under this app, its endpoints, `scripts/msh/`,
the extractor and the Marvel migrations against every run of ten words in the
book's power text and in each parsed sourcebook's prose (`msh_book_text`'s
source), and fails on any match. CI has no extraction and says the section
skipped. It caught its first leak the day the sourcebooks were added: the MA1
survey had quoted the book.

### `msh_book_text`

The prose of the sourcebooks' character entries, for the codex's Notable NPCs
and the GM tools: MA1 *Children of the Atom* first
(`apps/marvel-heroes/docs/surveys/ma1.md`). One row per piece of an entry, so
a card fetches one entry's rows by `(book, entry)` in one query.

| column | what |
|---|---|
| `key` | `<book>:<entry>:<part>[:<n>]`, unique - `ma1:nightcrawler:power:1` |
| `book` | the registry slug, `scripts/msh/books.json` |
| `entry` | the entry's slug, as the committed data names it |
| `part` | `power`, `powers-intro`, `talents`, `contacts`, `running`, `background`, `notes`, `member`, `appearance` (a cross-reference's text) or `prose` |
| `name` | the power's or member's printed name, when the part has one |
| `page` | the printed page the piece starts on |
| `body` | the text, folded to ASCII |

Migration `087`, in `DB_MARVEL`. The same rule as `msh_power_text`: **its rows
are never in the repo**, and a database built from the repo has it empty. The
numbers, rank codes, power names and page citations of each entry are committed;
the sentences are not. `scripts/msh/roster.py` parses the local OCR cache
(`$WORKSHOP_MSH_CACHE/books/<slug>/`), and `scripts/msh/npcs.py` writes both
halves: `data/npcs.json` here, and this table's data script beside the cache.
`/api/marvel-heroes/book-text?book=ma1&entry=<id>` serves one entry's rows in
the book's order, and answers 404 `missing: true` when there are none.

**Loading it.** On the machine with the cache:

```bash
python scripts/msh/roster.py ma1
python scripts/msh/npcs.py ma1
node scripts/d1-apply.mjs --remote --db marvel .cache/msh/books/ma1/book-text.sql
```

The script deletes the book's rows first, so re-running it replaces them.

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

## Campaigns: the `msh_campaign` tables

A GM runs a campaign; players link their saved heroes to it. Migration `086`,
nine tables in `DB_MARVEL`. They are Marvel's own copies of the Palladium
suite's campaign shapes, not a share of them: each group's server code reaches
only its own database (`groups.json`).

| table | what |
|---|---|
| `msh_campaigns` | one per campaign: `name`, `gm_email`, `description`, `gm_notes` (the GM's alone, never sent to a player), and `open` - 1 while the campaign is running, 0 once the GM closes it |
| `msh_campaign_heroes` | the link, and only the link: `campaign_id`, `hero_id`, who added it. **A hero is never copied into a campaign**, so the sheet a player opens and the roster the GM adjusts are one row (Nate, 2026-09-28). `campaign_open` is a copy of the campaign's `open`, kept true by a trigger, because the unique index that allows a hero into **one open campaign at a time** cannot look at another table |
| `msh_hero_events` | every change the GM makes to a hero's `health`, `karma`, `karma_pool` or `advancement`: who, the `before` and `after`, the `delta`. Written in the same batch as the change. Undo is a new row whose `undoes` names the one it reverses; unique, so a change is undone once |
| `msh_journal_entries`, `msh_journal_fts` | the campaign's notes, optionally about one hero, and their full-text index (external-content FTS5 kept current by triggers) |
| `msh_npc_sheets` | a statted NPC in **the hero shape** - `build`, `snapshot` (`js/sheet.js`, `SNAPSHOT_VERSION`), `sheet` - so the sheet renderer draws it as it draws a hero. `hidden` is 1 until the GM shows it; the NPC roller writes these, and so does **Add an NPC from the book**, whose snapshot has `mode: 'book'` (below) |
| `msh_npcs`, `msh_npc_mentions` | People: one dossier per name per campaign, optionally backed by an `msh_npc_sheets` row, and which notes mention whom |
| `msh_campaign_entries`, `msh_campaign_images` | the GM's own pages, never revealed, and the pictures that can be. **An R2 key must start `msh/`**, a `CHECK` rather than a convention, so nothing Marvel stores can land in another app's part of the bucket |

The heroes endpoint stays owner-only. A GM reads the sheets of heroes linked to
their campaign through the campaign's own endpoint, and changes only the four
play numbers, through `PATCH /api/marvel-heroes/campaigns/:id/heroes/:heroId`.

### Notes, People and handouts

The Campaigns page's **Notes**, **People** and **Handouts** tabs, and the GM
page's **Setting** panel and present mode, are the campaign views every game
shares (`shared/js/campaign/`, PR #1507). They write markup and no styles:
every class they emit starts `mc-`, `styles.css` styles each one in this
app's look, and the suite fails on one it does not. The page hands them
`/api/marvel-heroes` as their base, so they reach only this group's
database, and the endpoints behind them are Marvel's own copies of the
Palladium ones, written against the `msh_` tables:

- **Members only.** A member is the GM or anyone with a hero in the
  campaign. Anyone else signed in can see a campaign exists and join it, and
  reads none of its notes, People or handouts.
- **Notes**: anyone at the table writes one; only its author or the GM
  changes or deletes it. `@Name` links the note to that person's dossier and
  makes one on first mention. A possessive is the same person
  (`@Kingpin's men` is the Kingpin), and an apostrophe inside a name stays.
  Search is FTS5 and free.
- **Ask** is the paid button beside the search box: Claude answers from the
  notes and People and cites the notes it used, through the shared Claude
  client, which logs the call. A hidden NPC sheet never goes into the
  question.
- **No People sweep** (Nate, 2026-09-28): it would need two more tables and a
  second paid call. The shared view always draws the panel, so `styles.css`
  hides it, and `npcs/sweep.js` answers 501.
- **Handouts** are the pictures on the GM's pages that the GM has revealed:
  each one's caption and nothing of the page behind it. A picture that is not
  revealed answers a player exactly like one that does not exist. Every
  stored picture and portrait is in R2 under `msh/`.

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
- **R25** **Initiative is a house rule** (Nate, 2026-09-28): everyone rolls
  d100 each round and the highest goes first. A tie goes, in order, to (1) an
  initiative Talent **that applies this round**, (2) the higher Agility
  **number**, not the rank's name, and (3) if still tied, **only the tied
  combatants** roll d100 again, as often as it takes. The two Talents that give
  "+1 initiative" - Weapons Specialist with its one chosen weapon (PB,
  `talents.json` `weapons-specialist`) and Martial Arts E unarmed
  (`martial-arts-e`) - are **read as a tie-breaker, not +1 on the roll**. Both
  are conditional, so the GM ticks "Talent applies" per combatant per round,
  an unticked box breaks nothing, and every tick clears when the round ends.
  The GM page tags each row with what broke its tie. The rules are in
  `js/initiative.js`.

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
| `campaign/index.html`, `campaign/campaign.js` | Campaigns: create one, add or take out your own heroes, and - for its GM - read every linked hero's sheet, read-only. `?c=<id>` opens one |
| `gm/index.html`, `gm/gm.js` | GM tools for one campaign you run: the roster (Health, Karma and Karma pool, each - and + by a chosen step, every press logged and undoable), initiative by R25, a FEAT roller, and the GM's notes. `?c=<id>` opens one |
| `gm/room.html`, `gm/room.js` | the room view: the initiative order and whose turn it is, large, for the screen turned to the table. It makes no request - it reads the list the GM page keeps in the same browser and redraws on each change |
| `js/initiative.js` | R25 as a pure function: a round's d100s, the order, and which tie-breaker - Talent, Agility or re-roll - placed each row; which Talents count is derived from `talents.json` |
| `js/npc.js` | the NPC roller: the generator run with a GM's body type, origin, exact number of Powers (rolled until one has it, extras bought as UPB p.14 allows, refused rather than padded) and highest rank, ending in a hero-shaped snapshot |
| `js/npc-book.js` | a Notable NPC as a campaign NPC: one version and stat block of `data/npcs.json` to a hero-shaped snapshot with `mode: 'book'` - the printed numbers placed on the ladder by their range, each misprint the book's arithmetic exposes corrected, forms as forms and tiers as a choice; and the list of choices the GM picks from |
| `js/api.js` | the fetch wrapper the Campaign and GM pages share; answers the server's own refusal rather than throwing |
| `js/campaign-ui.js`, `js/undo.js` | the ui adapter the shared campaign views take - `esc`, an `escJs` that carries O'Brien through an inline handler, a yes/no question, the page's status line - and "Removed. Undo" in place of "Are you sure?", with the Palladium pages' contract |
| `gm/present.html`, `gm/present.js` | present mode: one of the GM's pictures on black, for the screen turned to the table. The behaviour is `shared/js/campaign/present.js`; this is the skeleton of ids it fills, and where Escape goes. Showing is not revealing |
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
| `data/npcs.json` | the Notable NPCs, built by `scripts/msh/npcs.py`: every character, version, stat block, power and member name, and page, with each misprint's printed and corrected value; facts only, never the book's prose |
| `data/npc-power-aliases.json` | sourcebook power names that are a UPB Power under another name, for the Notable NPCs' links; clear equivalents only |
| `codex/index.html`, `codex/app.js` | the Codex page and its entry module; it links `../styles.css`, this app's one stylesheet |
| `js/codex.js` | the Codex's sections as descriptors, its search, and reading and writing its address; pure |
| `js/power-text.js` | fetching a Power's full text, shared by the Powers tab and the Codex; a missing row or a failed fetch is an answer, never a throw |
| `js/book-text.js` | fetching a sourcebook entry's text for a Notable NPC's card, on the same terms, and laying its parts out |
| `js/gear.js` | the Gear tab's search, and reading a printed rank abbreviation back onto the ladder |
| `js/sheet.js` | a built hero to its saved snapshot, and the snapshot to the sheet's HTML; pure, so the suite runs it |
| `js/pointbuy.js` | Point Buy (R24): the ledger of what each line costs, the cap, the rank steps, the most a line can afford, a build to its snapshot, and what a rolled hero would cost |
| `/functions/api/marvel-heroes/power-text.js` | GET one Power's full text from `msh_power_text`; signed-in users only |
| `/functions/api/marvel-heroes/book-text.js` | GET one sourcebook entry's text from `msh_book_text`, in the book's order; signed-in users only |
| `/functions/api/marvel-heroes/heroes.js`, `_lib/heroes.js` | save, list, open and delete the caller's own heroes, and the checks every write goes through |
| `/functions/api/marvel-heroes/campaigns.js`, `campaigns/[id].js`, `_lib/campaigns.js` | list and create campaigns; read, edit (GM) and delete (GM) one; who may do what, and the checks every write goes through |
| `/functions/api/marvel-heroes/campaigns/[id]/heroes.js` | link one of your own heroes to an open campaign, or take one out (its owner or the GM) |
| `/functions/api/marvel-heroes/campaigns/[id]/heroes/[heroId].js` | GET a linked hero's sheet (its GM or owner); PATCH `{ field: delta }` for the four play numbers, GM only, written with its `msh_hero_events` row in one batch |
| `/functions/api/marvel-heroes/campaigns/[id]/events.js` | the GM's last 50 changes, and `{ undo: id }`, which writes the reverse as a new event |
| `/functions/api/marvel-heroes/campaigns/[id]/npcs/generate.js` | POST, GM only: roll an NPC on the server with `js/npc.js`, reading the data files through `env.ASSETS`; writes a hidden `msh_npc_sheets` row, and an `msh_npcs` dossier when asked |
| `/functions/api/marvel-heroes/campaigns/[id]/npcs/from-book.js` | POST, GM only: add a Notable NPC with `js/npc-book.js`, on the same terms as the roller - a hidden sheet, a dossier when asked, a 400 that says which version or block to choose |
| `/functions/api/marvel-heroes/campaigns/[id]/npc-sheets.js` | the campaign's NPC sheets: all of them to the GM, only the shown ones to anyone else; show, hide, rename, delete (GM) |
| `/functions/api/marvel-heroes/journal.js`, `journal/[entryId].js`, `_lib/notes.js` | a campaign's notes: list and write (members), change and delete (author or GM); @mentions, and the full-text query |
| `/functions/api/marvel-heroes/campaigns/[id]/search.js`, `ask.js` | full-text search over the notes, and Ask, the paid answer from them |
| `/functions/api/marvel-heroes/campaigns/[id]/npcs.js`, `npcs/[npcId].js`, `npcs/[npcId]/portrait.js`, `npcs/sweep.js` | People: the roster, one dossier and every note mentioning them, its portrait in R2; the sweep answers 501 |
| `/functions/api/marvel-heroes/campaigns/[id]/entries.js`, `entries/[entryId].js`, `entries/[entryId]/images.js`, `images/[imageId].js`, `handouts.js` | the GM's pages and their pictures (GM only), revealing one, and the revealed ones as handouts |
| `/scripts/msh-extract.py` | builds the full-text data script into `.cache/msh/` from the PDF |
| `test/smoke.mjs` | file-wide checks (ASCII, LF, parse), the stylesheet boundary, contrast, and the data: every d100 table covers 01-00 once, the ladder is unbroken, every ruling is logged; the endpoints against a real database - the campaign ones included: the GM's PATCH refuses every field but the four play numbers and every hero outside its campaign, a second open campaign for a hero is refused by the index itself, the NPC roller's ceiling and hiding, and R25's four tie cases; and for the shared views, members only, @mentions, who may change a note, the GM's pages and reveals, every picture under `msh/`, script order and API base, every `mc-` class styled, and escJs |

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
