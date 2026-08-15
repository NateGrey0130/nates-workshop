# PR 11 — Sheet targeted re-render

> **Delivered** in [#27](https://github.com/NateGrey0130/nates-workshop/pull/27). This file is the record of why, not a to-do.

## Problem

`sheet.js` re-renders the whole sheet on every edit. It works, but unsaved edits
were being discarded on re-render until `keepEdits()` was added to collect and
restore them — a patch around the architecture rather than a fix. Every new
interactive block added to the sheet has to remember to participate in it.

## Decision

**Targeted updates for the hot paths only.** The full render stays the default;
the edits that happen constantly update in place. That retires `keepEdits()`
without rewriting the sheet.

Rejected: section-level re-rendering, a full reactive rewrite with a state-and-
diff layer — the app has deliberately avoided frameworks and this is not the
place to introduce one — and dropping the PR entirely.

## Hot paths

The three that motivated `keepEdits()`:

1. **Field edits** — `editField()` writes into a value; only that field's display
   and anything derived from it should update.
2. **Armour add and remove** — `addArmor()` and `removeArmor()` currently
   re-render everything, which is what discarded unsaved edits in the first
   place. These should append or remove a single armour row.
3. **Inventory add and remove** — same pattern against the gear list.

Everything else — initial load, save, level-up, switching characters — keeps the
full render. Correctness over cleverness.

## Work

- Give each independently updatable block a stable identifier at render time, so
  a targeted update can find its node without a broad query.
- `addArmor()` appends a row; `removeArmor()` removes one. Neither touches the
  rest of the DOM, so unsaved edits elsewhere survive without being collected and
  restored.
- Same for inventory rows.
- Field edits update in place and recompute only their dependents. Note
  `derive.js` semantics: stored values win over the tables, and a blank field
  means "use the table". A targeted update must preserve that — clearing a field
  has to fall back to the derived value, not leave the stale number on screen.
- **Delete `keepEdits()` once nothing calls it.** If any caller remains, the
  refactor is incomplete; do not leave it half-applied, because a partial state
  is worse than either end.
- The delegated-listener pattern already used on `#app` matters more here, not
  less: nodes now appear and disappear without a full re-render, so handlers must
  be delegated rather than bound per node.

## Acceptance

- Typing into a field, then adding armour, preserves the typed value with no
  `keepEdits()` involved.
- Removing an armour row leaves other rows and their unsaved edits untouched.
- Adding and removing inventory items behaves the same way.
- Clearing a hand-entered combat or save value falls back to the derived value
  immediately and correctly.
- Print layout still renders correctly — the print stylesheet targets the sheet's
  structure, so verify identifiers added for targeting did not disturb it.
- `keepEdits()` is gone and nothing references it.
- The sheet still renders fully and correctly on load and after save.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Any state management or diffing library, section-level render boundaries, and
re-rendering behaviour outside the three hot paths.
