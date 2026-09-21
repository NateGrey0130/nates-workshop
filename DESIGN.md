# DESIGN.md — the visual system

Written 2026-09-20 by reading the shipped stylesheets, not by deciding
anything. Product truth is in `PRODUCT.md`.

**THERE ARE TWO VISUAL SYSTEMS NOW, and which one you get is decided by which
stylesheet your page links.** Board & Tissue retoned the five RPG apps and the
hub on 2026-09-20; FilamentForge, MediaVault and Pick 3 Cut 5 stay on Ley
Verdigris. Every section below says which system it describes when the two
differ, and most of them do.

**Where the truth actually lives:** `shared/styles.css` holds the Ley Verdigris
tokens and is loaded by every app; `apps/character-creator/styles.css` holds
everything the RPG suite's five apps draw **and overrides every token in a
`:root` of its own**. This file is a reader's map of those two. When they
disagree with this file, **they are right** — and several claims below are
pinned by named checks in `apps/character-creator/test/checks/rendered-ui.mjs`
and in the F55 section of `test/smoke.mjs`, which are the only things here that
cannot rot quietly.

## Two palettes, and the load order that separates them

| | ground | accent | faces |
|---|---|---|---|
| Character Creator, Character Sheet, Codex, Campaign, GM Tools | `#EFE9E2` | `#A8401A` | Archivo + Martian Mono |
| FilamentForge, MediaVault, Pick 3 Cut 5 | `#0A0F0E` | `#35A0AE` | Saira + IBM Plex Sans |

The mechanism is nothing but load order. The five RPG pages link
`/shared/styles.css` first and `/apps/character-creator/styles.css` second, so
that file's `:root` wins. The other three link their own stylesheet, which
declares no palette, so shared's survives. **Retoning `shared/styles.css` would
retone all eight** — that is the trap this arrangement exists to avoid, and the
first draft of Board & Tissue fell into it.

`index.html` is the third case: it links **neither** and carries its own copy of
the palette under its own token names. It follows the RPG suite, because it is
the door those rooms are behind. A smoke check compares the two by role, and it
exists because that copy once stayed blue and violet for months after every app
behind it had been retoned.

**`--accent` is reserved for what you can act on**, in both systems. Sixteen
section labels on the sheet are not clickable, so they are weight and tracking
rather than colour — spending the accent on every heading left the Use button
with nothing to stand out with. `.tag.score` and `.box-title` both state this.

**Board & Tissue's accent is warm, and that costs hue separation** — 32° from
`--danger` and 29° from `--warning`, where Ley Verdigris had 156 and 126. The
`:root` block in `apps/character-creator/styles.css` carries the table and the
argument: it is affordable only because that system spends no hue on state. If
state ever becomes a colour swap there, the number stops being affordable.

## Depth

**No `box-shadow` anywhere, in either system.** `--shadow` is `none`, and the
smoke suite asserts `index.html` contains none at all. A shadow added to one
card would be the only shadow in the product and would read as a mistake.

**Ley Verdigris: depth is a lit edge.** `border-top-color: var(--border-strong)`
over `var(--border)` on the other three sides, so a surface reads as catching
light from above.

**Board & Tissue: depth is the chip column**, and the lit edge is the one idiom
that did not survive the move intact. The rules still exist — four in the RPG
stylesheet still set `border-top-color: var(--border-strong)` — but under a
white panel `--border-strong` is *darker* than what it sits on, so the same
declaration now reads as a seam rather than as light. It is a heavier rule
weight there, not an elevation cue, and that is worth knowing before anyone
"restores" it somewhere new.

What separates a block from its neighbour instead is a **13px chip column** down
its left edge, drawn as a `::before` rather than a `border-left` — a
border-left replaces one of the box's four sides and turns a block into a
callout. Its colour is `data-col` (below). It carries no state, and it does not
print.

## State is a mark, not a hue (Board & Tissue)

The system that lets the palette run a warm accent. A power the pool cannot pay
for takes a **struck hollow square** and has its name ruled through; one it can
afford takes a **filled square**. Colour only ever confirms a shape that
already reads without it, so the distinction survives a greyscale print, a
phone in sunlight, and a player who cannot separate two warm hues.

It replaced an opacity. `:disabled` dims to `0.45` in `shared/styles.css`, which
is the mechanism `.st.na` and `index.html`'s `.card-soon` both refuse by name,
for the measured reason that a composited `0.45` takes text under the contrast
floor. No new data was needed: `usePower` already guarded on `left < cost`.

**The chip does not print and the mark does**, and both halves are asserted.
Furniture is a screen convenience; state is the thing paper still has to carry.

## Type

`--font-display` with `font-stretch: 75%` for labels, headings and controls in
**both** systems — the declaration is identical, only the family differs.
Archivo's width axis is `62%–125%` and Saira's was `75%–100%`, so 75% resolves
to a condensed instance in either, which is why the swap moved none of the 99
rules that set it. **A rule that names the family without the stretch silently
gets the 100% width**, in either system.

Section labels are 10px, uppercase, `letter-spacing: 0.18em`, weight 800 —
small, wide and quiet, so the numbers beside them are what the eye lands on.

**Figures are a third face in Board & Tissue.** `--font-mono` was a device
stack under Ley Verdigris and still is for the other three apps; in the RPG
suite it is Martian Mono, and every rule that declares tabular figures takes
it. `font-stretch: 75%` is kept on those rules too, because Martian Mono's
width axis starts at 75% and its narrowest instance is what keeps a 44px pool
value inside its card.

**That face has a size bill.** The `.vitals` grid minimum went from 84px to
92px: at 84 a three-digit pool value ran 5px past the input that clips it in
Martian Mono, and 0px in the condensed face. Four digits still clip and did
before — 32px now, 17px then, needing a 120px card — which a P.P.E. pool passes
on a high-level caster standing on a ley line. Recorded rather than fixed; the
fix is the value shrinking on length.

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

**`data-col` now pays for three things**, and this is the ranking's whole
career: which stack a box lands in, how much contrast its title gets, and —
since Board & Tissue — its chip colour. Ink for `a`, the green secondary for
`b`, a board tan for `c`, and the accent for the identity block, which is the
document's subject rather than a rank.

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

## What a grant shows, and where

Worth stating because a redesign nearly moved it. `character_grants.reason` is
**already on screen**: every granted skill renders its reason, who entered it
and at what level, as a `↳` note directly under its row, inside a full-width
GRANTED box. That box is full-width rather than a fourth column beside Class,
Related and Secondary *because a sentence does not fit in the three-column
grid* — so a marginal-note treatment is a step backwards, not forwards.

`kind: 'skill'` is the only grant kind live. The other seven in the schema's
CHECK are unwritten, so there is nothing else with a reason to show.

## Touch targets

44px minimum, stated at `.tabbar .tab` and followed by the steppers, the roll
buttons and the tab entries. The sheet is used on a tablet with a finger.
