# Catalog conventions

The four catalogs — skills, spells, psionic powers, gear — are what class files
cite. **Characters reference skills and spells by NAME and gear by SLUG**, and
nothing rewrites those citations, so a name is close to permanent. Everything
below follows from that.

## Naming

- **A sub-skill printed under a parent takes the parent's name as a prefix.**
  `Lore: Astral`, `Navigation: Stellar`, `Language: Mongolian`,
  `Streetwise: Drugs`. This matches the catalog's existing `Lore: Magic`,
  `Language: Other`, `Horsemanship: General`.
- **Pilot skills store without a `Pilot:` prefix** — `Robots & Power Armor`,
  `Automobile`, `Truck`, `Hover Craft (ground)`. Note the ampersand: this
  reference said `Robots and Power Armor` for months after the catalog renamed
  the row, the Godling's `except` list was written from it, and an unmatched
  `except` excludes NOTHING — so the class went on offering the one Pilot skill
  its book forbids. **Query the catalog for the spelling; do not copy it from
  here.** The `Military:` prefix is a
  different matter and this reference used to get it wrong: it said
  `Military: Warships & Patrol Boats` was "the exception the catalog already
  holds", and the catalog holds **five** — Warships & Patrol Boats, Combat
  Helicopter, Jet Fighters, Submersibles and Tanks & APCs, all from RUE
  pp.302-303, which is how the book itself sets them. **Query before assuming
  either way**; the rule is the catalog's spelling, not a pattern.
- **Lore skills are filed under `Technical`**, not a Lore category of their own
  (the Cowboy lore skills are the exception, filed under `Cowboy`).
- Use the book's printed name otherwise. Fix only obvious typos, and say so in
  the script's header comment.

## A rename is not a new row

When a book prints a skill the catalog already holds under an older spelling,
**do not insert the new spelling**. A second row manufactures a duplicate, and
characters citing the old name keep pointing at the empty one.
`add-rue-skills-batch.sql` records the decision and lists 21 such renames —
`Safe-Cracking`, `Basic Math`, `Tanks and APCs`, the two heavy W.P.s,
`Motorcycle`, and the rest.

**The class file moves to the catalog's spelling, not the reverse.** If a class
names a skill the catalog spells differently, fix the class.

Name convergence, when it is genuinely wanted, belongs to the catalog editor's
merge/rename tools — they write `catalog_redirects` and repoint characters.

## Where a book and the catalog disagree

**The catalog wins.** A disagreement is not a gap. Record the book's figure in
`note` if it is worth keeping; do not overwrite curated numbers.

This came up 12 times against one Rifts skill sheet, and once for Athletics
where the sheet and the catalog disagreed on both the size of a bonus and which
attribute it applied to — the catalog was right.

## Stubs

A row created by a class import carries the exact marker
`STUB — created by class import, needs stats`, which is how the gear importer
later recognises it as unfilled. `class-check` generates the SQL, including the
`char(8212)` splice. Filling a stub is an `UPDATE` in place, so the id never
changes and inventory rows keep resolving.

Non-percentile rows are **not** stubs. W.P.s, Hand to Hand, Boxing, Wrestling
and Robot Combat legitimately carry `base 0, per_level 0`.

**A spell or psionic power with no `description` is a stub too, and it is the
one with no marker.** The row carries its name, its cost and its level or
category, so it reads as finished in every report here — and the codex, the
page that exists to render that column, draws it blank.

The test is **the text alone**: not the level, not the cost, and not who
created the row. `psionic_powers` has no `level` column at all, and a blank
description is wrong however the row arrived — the last 23 this catalog had
came in overwhelmingly with the seed rather than through an importer.
`source-coverage.mjs` counts them as `spell text missing` and
`psionic text missing`. BOOK-INGEST-AUDIT F22.

## A skill can grant bonuses

`skills.bonuses` holds what a skill grants beyond its percentage, in **the same
JSON shape a class's `bonuses:` block uses**, validated through the same
`validateBonuses()`:

```json
{ "attributes": { "PS": 2 }, "combat": { "attacks": 1, "parry": 2, "dodge": 2, "roll": 1 } }
```

That is Boxing. Wrestling, Body Building, Running, Athletics, Acrobatics,
Gymnastics and Ice Skating all print bonuses of the same kind.

**Flat numbers only.** Dice values and `pools` are refused for a skill: a class
rolls its dice once at creation and stores the result, and a skill can be taken
at any level, so there is no equivalent moment. Keep those in `note` — Boxing's
`+3D6 S.D.C.` lives there.

`combat` and `saves` are open sets, so `roll` needed no schema change. The keys
`derive.js` actually produces are `attacks`, `initiative`, `strike`, `parry`,
`dodge`, `roll`.

## Category restrictions across categories

The catalog files each skill under exactly one category. The books file a skill
under whichever category a class spends its pick from, so *"Espionage:
Wilderness Survival only"* is an ordinary line about a Wilderness skill.

- An **`only`** entry matches **by name**, whatever category the catalog uses —
  but only when the class **also lists** the skill's real category. Both halves
  matter: without the name match the restriction does nothing, and without the
  bound it would reach a skill from a category the class never granted.
- An **`except`** entry does not work that way. Naming a skill from another
  category excludes nothing, because nothing was offered there to exclude.

`class-check` reports all three outcomes — `cross-category`, `unreachable`,
`no-op except`. `unreachable` is the defect: the class grants a skill nobody
can take.

## Extracting a skill list from a PDF

A multi-column skill sheet defeats text extraction, and the failure is quiet.

- **`pdftotext -layout` snaps baselines onto a character grid.** On a six-column
  sheet whose columns do not share baselines, it merges and splits rows — it
  reported `COMPUTER REPAIR` at 30+5% where the page said 25.
- **pypdf's visitor returns the text-matrix translation, not page
  coordinates.** With every font reporting size 1.0 the scale lives in the
  matrix, so pairing on those numbers silently drops whole rows.
- **PyMuPDF (`page.get_text("words")`) gives true page coordinates**, and the
  sheet is then regular: a percentage sits 1.0–1.2pt below its name's line top,
  in the same column. Group by `(block, line)`, band by x, pair on that offset.

**Validate against the catalog, not against another extraction.** Overlapping
entries that already exist are ground truth; a parse agreeing with ~90% of them
is trustworthy, and the disagreements are then worth reading one by one.

Classify before inserting: existing, rename, genuinely new, and ambiguous.
Leave the ambiguous ones alone and say so — guessing which of two similar names
the book means is how a duplicate gets created.
