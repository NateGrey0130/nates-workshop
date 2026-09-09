# Plan 21 — Gear and vessels, read and owned

Written 2026-09-09, **after** the work rather than before it. Plans 13–16, 19 and
20 are specifications; this one is a record, and it says so at the top so nobody
reads it as a proposal that is still open.

It exists because the decisions below were made from measurements, and a
measurement nobody wrote down is a decision somebody re-litigates in six months.

Part of the [character creator](../../README.md) documentation.

---

## What was wrong

Two of the largest catalogs in the database could not be read by anybody.

`gear` — 1,253 rows, 1,239 with description text — was served only through
`/items`, a name-and-price projection for pickers. Nothing anywhere showed a
weapon's damage, an armour's A.R. or what a thing actually was.

`vehicles`, `vehicle_locations` and `vehicle_weapons` — 127 / 1,238 / 635 rows —
had **no reader at all**. `BOOK-INGEST-AUDIT.md` F3's closure said so outright
when migration 048 built them: *"Nothing in the app reads the three tables. No
`catalogs.js` SELECT, no `catalog-fields.js` entry, no sheet rendering. This is
the shape; the reader comes when something needs to render one."*

That closure also named the trigger for reopening — *"a sheet that renders a
vessel, a G.M. lookup, a class that grants one beyond the Noro"* — and this is
it.

## What was measured

Production D1, 2026-09-08, re-measured unchanged at `6f865b9`. Each payload
serialised exactly as its endpoint returns it, then gzip level 6 and brotli.

| | raw | gzip | brotli |
|---|---|---|---|
| gear, full codex projection | 740.1 KB | **155.2 KB** | 138.3 KB |
| gear, the existing `/items` projection | 231.6 KB | 32.4 KB | 30.0 KB |
| vehicles alone | 145.8 KB | 37.6 KB | 35.0 KB |
| vehicles + locations + weapons | 564.3 KB | **106.8 KB** | 93.7 KB |
| all of it in one response | 1,304.3 KB | **261.2 KB** | 221.5 KB |
| *the whole boot payload, for scale* | 208.3 KB | *25.1 KB* | *20.4 KB* |

And the number that made the sheet half easy: **116 held `character_items` rows
across every character on production, all 116 catalog-linked.**

## The decisions, and what they were weighed against

### 1. One codex section per request, and `section` is required

The codex made **exactly one** request and got both catalogs. Widening it to
carry everything is a 261 KB fetch before the page paints — ten times the boot
payload — to show somebody one spell. So `?section=` names one catalog and a tab
fetches its own when first opened.

**Required rather than defaulted.** A bare `/codex` serving the old
spells+psionics body would be a second contract to keep working, and this site
has one client. A missing or unknown section is a 400 naming the five.

**Rejected: list-then-detail for vessels.** The 127 alone are 37.6 KB; fetching
each vessel's locations and weapons on expansion saves 69 KB once per page life
at the cost of a round trip per expansion. Plan 20 valued *"no round trip on a
bad connection"* and that argument did not stop being true. **Revisit at ~250 KB
per section**, which is the number, not a feeling.

**Rejected: putting gear in `catalogs`.** That is the boot payload on every
wizard load and every sheet load. It would take 25.1 KB to about 180 KB, on
every load, for a page most sessions never open. This is the exact mistake plan
20 exists to prevent and it will look reasonable in the moment, because the
sheet already fetches `/items` and folding gear in reads as *one less request*.

### 2. The section is in the ETag

Two catalogs that serialise identically would otherwise revalidate into each
other — which is what two **empty** ones do on a fresh database, `{"gear":[]}`
differing from `{"spells":[]}` only by luck of the key name. `regression.mjs`
proves it by making the wrong one fail: a Gear request carrying the Spells tag
must serve a body, not a 304.

### 3. Held-item stat blocks ride on the join that already exists

Powers needed `loadPowerDescriptions` because they live in a JSON column with
nothing to join to. Items already arrive through the character's own
`LEFT JOIN gear`, so the stat block columns just ride on the row. 116 rows.

**Rejected: a `gear_descriptions` map paralleling `power_descriptions`.** It
would have been a second mechanism for a problem this one does not have.

### 4. `character_vehicles` is its own table

Not a column on `character_items`:

- that table's `CHECK` and its `gear(slug)` foreign key are load-bearing, and
  widening them to mean "gear OR vessel" makes both weaker;
- the sheet's inventory table renders every row that endpoint returns, so a
  robot would arrive as a line item with a quantity box;
- a vessel is not a thing you carry three of. A quantity and an equipped tick
  are the wrong questions about a robot; `mdc_current` is the right one.

**`mdc_current` is JSON keyed by location name.** The maxima are catalog data in
`vehicle_locations`; the damage is per-instance, because two Glitter Boys in a
party take different hits to the same arm. A location absent from the object is
undamaged, so a fresh vessel is `{}` rather than a copy of the catalog — and
**a book correcting a location's M.D.C. does not rewrite every character who
owns one.**

Damage is validated against that vessel's own locations. Stored unchecked, a
typo renders as a damaged part that does not exist, and no reader can tell that
from a book they have not read. A freeform vessel has no catalog row and so
takes damage anywhere — the concession a freeform item already gets for
enchantments. Values may go **negative**: Palladium blows straight through zero
and clamping would quietly disagree with the table.

### 5. Vessels became an editable catalog without joining duplicate review

One entry in `catalog-fields.js`. `resolveCatalog` requires that config **and** a
`MERGE_REFS` entry, so declaring a catalog does not enlist it in duplicate
review — `enchantments` has been in exactly that position since it landed, so
this is a shape the codebase already had.

**Not adding `MERGE_REFS` is a decision, not an omission.** There is nothing for
a vessel merge to repoint: no class cites one, and ownership arrived in the same
sequence rather than before it. Gear alone suggests 591 pairs; enlisting 127
vessels would propose merges against rows nothing references.

The editor edits the vessel's own row and **nothing else** — locations and
weapons are one row each and this editor's shape is one table's columns in one
form. Correcting a location's M.D.C. is still a data script. That is written
into the config, because a form that silently edits two thirds of a thing is
worse than one that edits a third and says so.

### 6. `vehicle_class` is normalised by convention, not by constraint

50 of 127 rows carried a book phrase where the column documents seven values.
The schema stays free text for the reason it always gave — books invent
categories and a `CHECK` would reject a book rather than record it — but the
column is what a vessel list shows in its meta column, and a list reading
`robot` on one row and `Multi-purpose sea vessel.` on the next reads as a
defect.

**Every book phrase was preserved.** All 50 were checked absent from their own
descriptions first, then prepended as a lead label in the same `UPDATE` that
overwrote the column.

## What was found on the way, and is worth keeping

**A live bug nothing had noticed.** `sheet.js` tested `it.item_id` in two
places; migration 046 dropped `character_items.item_id` and the endpoint sends
`item_*` aliases, none of them `item_id`. So every inventory row rendered the
"custom" tag — including all 116 catalog-linked ones — and `isWeapon()` never
returned true, meaning **no held item has ever become a play-mode weapon card.**
Nothing errored. A check now derives the alias list from the endpoint and
asserts the sheet reads only fields it sends.

**`node --check` is not sufficient validation** for the ES modules here. It
passed `catalog-fields.js` with a string literal closed early by an apostrophe;
the module loader rejected it and the smoke test caught it.

**A migration must end by recording itself.** `049` did not, and produced a
permanent false *"MIGRATION NOT APPLIED"* (`BOOK-INGEST-AUDIT` F37).
`d1-apply.mjs` does not write that row.

## What was deliberately not built

- **Backfilling the 24 `category = 'vehicle'` gear rows** that carry a real
  per-location stat block into `vehicles`. It needs a decision first — what
  `equipment_starting` cites when the thing it names is a vessel — because
  `catalog_redirects` is within one catalog by construction (`to_id` is *"row in
  that catalog's table"*) and five query sites resolve a gear slug through it,
  all hard-coding `catalog = 'gear'`.
- **The other 45**, permanently. They are not thin vessels, they are **not
  vessels**: `riding-horse` is *"A trained riding horse."*, `hovercycle` is
  *"the unspecified one a class list names"*. A stub in `gear` reads as a stub;
  a stub in `vehicles` reads as a vessel somebody failed to finish.
- **A vessel picker in the wizard.** Characters acquire vessels at the table.
- **Combat resolution off a vessel's weapon systems.** Play mode's weapon cards
  read `character_items`; extending them to vessels is a later ask.

## What is NOT verified

- Nothing here has been used at a real table yet. Every claim above is a
  measurement or a test, not a session.
- The codex's four sections were verified on one machine at two widths. The
  `verify-ui` skill's note about the in-app browser pane holds: it blanks on
  scroll, so the vessel and gear blocks were confirmed by reading the DOM as
  well as by screenshot.
- **The Gear tab and the Vessels tab both show vessels**, and will keep doing so
  until the backfill above happens: 24 rows with real stat blocks sit in `gear`
  alongside the 127 in `vehicles`. That is what the database holds, and the
  codex says so rather than hiding either half.
