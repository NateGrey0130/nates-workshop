# DESIGN.md — the visual system

Written 2026-09-20 by reading the shipped stylesheets, not by deciding
anything. This documents the **incumbent** system; P5 refines it and does not
replace it. Product truth is in `PRODUCT.md`.

**Where the truth actually lives:** `shared/styles.css` holds the tokens and is
loaded by every app; `apps/character-creator/styles.css` holds everything the
RPG suite's five apps draw. This file is a reader's map of those two. When they
disagree with this file, **they are right** — and several claims below are
pinned by named checks in `apps/character-creator/test/checks/rendered-ui.mjs`,
which is the only thing here that cannot rot quietly.

## The palette: Ley Verdigris

Defined once on `:root` in `shared/styles.css`. Oxidised copper for `--accent`,
raw copper kept at `--accent-secondary` — the two states of one metal.

`--accent` is **188deg** rather than the 166 a verdigris is first drafted at,
and that is a measured decision rather than taste: the stylesheet's own header
records the hue separation from `--danger`, `--warning` and
`--accent-secondary`, because the accent has to survive sitting next to all
three as a control signal.

**`--accent` is reserved for what you can act on.** Sixteen section labels on
the sheet are not clickable, so they are weight and tracking rather than
colour — spending the accent on every heading left the Use button with nothing
to stand out with. `.tag.score` and `.box-title` both state this.

`index.html` carries **its own copy of the palette**, deliberately: it is the
one page that does not load `shared/styles.css`.

## Depth is a lit edge. Nothing casts a shadow

There is no elevation system and no `box-shadow` anywhere in the RPG suite.
Depth is a **lighter top border** — `border-top-color: var(--border-strong)`
over `var(--border)` on the other three sides — so a surface reads as catching
light from above rather than as floating over something.

This is not a stylistic tic to preserve politely. A shadow added to one card
would be the only shadow in the product, and would read as a mistake.

## Type

`--font-display` with `font-stretch: 75%` for labels, headings and controls;
the body face for prose. Section labels are 10px, uppercase, `letter-spacing:
0.18em`, weight 800 — small, wide and quiet, so the numbers beside them are
what the eye lands on.

**Since P5a the box title is a real `<h2>`**, styled with `font: inherit` so
nothing moved on screen. Before that the whole character sheet rendered three
headings, and a four-screen document had no outline for anyone — screen reader
or not.

## The layout model

- **`.panel`** — a titled region of a page.
- **`.box`** — the unit of the character sheet: a `.box-title` (the heading and
  its buttons) over a `.box-body`. `data-box` is its own name; `data-col` is
  which column stack it belongs to.
- **Three column stacks, not a grid** (`js/sheet-layout.js`). A grid row is as
  tall as its tallest box, which left 500px of dead track under Attributes.
  Masonry does not ship in any browser, so boxes are moved into three real
  stacks. **The split is by how often you look a thing up**, not by topic:
  `a` numbers read constantly, `b` lists you scan, `c` what you read a
  paragraph of.

## Three modes, and the strip means something different in each

The character sheet's `.tabbar` is one strip of six entries with three states.
The condition is one string — `(max-width: 820px), (pointer: coarse)` — copied
in `styles.css` and as `TAB_MODE` in `sheet.js`, and the smoke suite pins that
every copy is identical.

| where | the strip | the panels |
|---|---|---|
| phone, or **any touch screen at any width** | tabs: `role="tablist"`, one panel on screen | `display: none` but the chosen one |
| mouse on a wide screen | **navigation**: pressing scrolls, roles removed | all visible, `display: contents` |
| print | gone | all visible |

**Tabs are a phone affordance, not the desktop default** — one section at a
time on a 1440px screen was treated as a bug and fixed, and P5a did not undo
it. What P5a added is the third state: the strip shown *over* already-visible
panels, as a way to reach a section on a page four screens tall.

Two traps that cost real time, recorded so they are not rediscovered:

- **`display: contents` generates no box.** A panel in navigation mode has a
  0,0,0,0 rect: `scrollIntoView` does nothing, `scroll-margin-top` applies to
  nothing, and an IntersectionObserver never fires. Scroll to a **box**.
- **An element with no `data-col` is a stray.** `stackColumns` files it under
  column b with a console warning. A heading added to a panel lands in the
  wrong column and grows the page; the heading belongs on the box.

## Touch targets

44px minimum, stated at `.tabbar .tab` and followed by the steppers, the roll
buttons and the tab entries. The sheet is used on a tablet with a finger.
