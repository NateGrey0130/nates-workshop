# Plan 22 — Super abilities and Talents in the codex

Decided with Nate on 2026-09-17. Two PRs: Talents first, super abilities after.
**As built** notes are added by the PR that builds each half.

## Goal

The codex gains two tabs, **Super Abilities** and **Talents**, so any
authenticated friend can read either catalog with its text and stat block
without starting a character or opening a book. Both catalogs were already
imported — Heroes Unlimited and the two Powers Unlimited books in #1040s–#1066,
Nightbane's Talents in #1131 — and neither had a reader outside the wizard's
picker and a held power's row on the sheet.

## What was measured

Production, `--remote`, 2026-09-17.

| catalog | rows | with a description | the full section, gzip level 6 |
|---|---|---|---|
| `talents` (migration 063) | 25 — 21 common, 4 elite | 25 | about 9 KB, **estimated** from 23.6 KB of text and not run |
| `super_abilities` (migration 057) | 364 — 202 minor, 162 major | 364 | **323.4 KB** (1,050.9 KB raw), measured |
| `super_abilities` without `description` | 364 | — | 5.6 KB, measured |

- The 364 come from Powers Unlimited One (170), Powers Unlimited Three (125) and
  Revised Heroes Unlimited (69). None carries a `variant_note`.
- A super ability's description has a median of 2,118 characters, a 90th
  percentile of 6,386 and a maximum of 13,369.
- `range`, `duration`, `damage` and `saving_throw` are filled on 41, 30, 22 and
  7 of the 364. A super ability is usually a permanent trait with nothing to put
  in a stat block.
- 83 of the 364 are named `Family: Name` — Alter Physical Structure 36, Energy
  Expulsion 20, Flight 7, Matter Expulsion 6, Supervision 6, Control Elemental
  Force 4, Super Vision 4.
- Of the 25 Talents, 22 need the Morphus, one the Facade, one works in either
  and one does not say; 22 carry a `ppe_note`; two have an activation minimum of
  0, which the schema defines as "varies, see the note".

**No schema, no migration, no data script, no `d1-apply`.** The posture is the
one `UI-AUDIT` F48 (PR #929) took when it added Skills and Classes: read-only.

## Decisions

### D1. A super ability's text is fetched when its row is opened

The full section is 323.4 KB gzipped — more than the 261 KB the original four
sections cost **together**, and past the line `functions/.../codex.js` drew for
itself: *"Revisit if any one section passes ~250 KB gzipped."* So the section
sends the list without `description` (5.6 KB) and one entry's text is fetched
the first time it is expanded — about 1 KB for a typical entry, about 4 KB for
the longest — and kept for the life of the page.

- **Rejected: send all 323 KB when the tab opens.** Simpler, and no round trip
  per expansion. It breaks the budget this page was built on, which is a phone
  at a table looking up one power.
- **Rejected: a 400-character excerpt in the list (55.5 KB), full text on
  demand.** A second mechanism on top of the first, to save one tap.
- **Rejected: split the section by tier.** Each half is about 160 KB — still
  several times any other section.

Plan 20 valued *"no round trip on a bad connection"*, and that still holds for
every other section, all of which are under the line. This is an exception for
the one catalog that crosses it, and not a new default.

### D2. The tabs are "Super Abilities" (`#super-abilities`) and "Talents" (`#talents`)

**Rejected: "Powers".** Psionics are already *powers* everywhere else in this
app — the table is `psionic_powers` — and both the book and the table say
*super abilities*. Both tabs are appended after Classes, so the default tab and
every `#spells` or `#gear` link already sent keep opening where they did.

### D3. Two PRs, Talents first

Talents is the existing pattern and proves a seven-tab bar cheaply. Super
abilities carries the one new mechanism. **Rejected: one PR** — it saves a
merge and reviews a layout question and a new fetch path together.

## Talents (PR 1)

- `functions/api/character-creator/codex.js` — a `talents` section with every
  column a reader needs, including the description, and a `talents` count in
  `index`.
- `codex.js` — one descriptor. The right-hand column carries **both** costs
  (`10 to acquire · 2+ P.P.E.`), because a Talent is paid for once to have and
  again at every use, and that is the whole reason it has a table of its own. An
  activation minimum of 0 reads as *varies*. The stat block adds minimum level,
  form, prerequisite, range, duration and saving throw; `ppe_note` and
  `variant_note` are notes.
- `test/regression.mjs` — the index counts Talents; the section serves every row
  it counts; the names equal the ones `catalogs` sends the picker; every row has
  both costs and its text; a player who is no admin can read it.
- The seventh tab is checked at 375px and on a desktop. If the bar needs a fix it
  lands here, so PR 2 only adds a tab to a bar already proven to hold.

**As built (PR 1), and the plan was wrong about where the bar would break.** It
named the phone. The phone was fine — seven tabs wrap 2+3+2 at 375px, nothing
hidden. The break was at **tablet width**: seven tabs need 759px, `.tabbar` only
wraps under 620px, and at 768px the strip is 706px wide, so Talents sat 53px off
the edge behind a horizontal scrollbar. Six tabs need 651px against a strip 62px narrower than
the viewport, so the same defect was already live from 621px to 712px and nobody
had looked there. `.tabbar.codex-tabs` now
wraps at every width, which is inert wherever the tabs fit on one row (1024px
and 1280px hold eight).

**And PR 2 adds one CSS rule as well as a tab**, measured here with a stand-in
eighth tab so it is not a surprise there: at 375px eight tabs at the shared
`18px` padding take **four** rows (2+3+2+1, 211px of bar); at `12px` they take
three (3+3+2, 161px — what six tabs take today). That rule is deliberately NOT
in PR 1, because at `12px` seven tabs sit 3+3+1 with a stranded last tab, and
2+3+2 is the better bar for as long as there are seven.

## Super abilities (PR 2)

- `?section=super-abilities` — everything except `description`, plus `has_text`
  so the *"N with text"* counter still works.
- `?section=super-ability&name=<name>` — one row's text. 400 without a name, 404
  for an unknown one, the same body-hash `ETag` with the section and the name in
  it. Looked up by `name`, which is `UNIQUE`, and never by `id`: an id is
  insertion order and means nothing in another database.
- `codex.js` — the descriptor gains an optional `detail` hook, and the other
  seven sections do not define it. Opening a row shows *Loading…* in its body,
  then the text; a failure is an inline message in that entry, never a
  page-level error panel. Names go through `encodeURIComponent` — they carry
  colons and apostrophes.
- The 83 family rows get **no grouping UI**. The existing all-terms filter
  already narrows to them: typing *alter physical* is the group.
- `test/regression.mjs` — the list carries no `description` key; the detail
  route returns text, including for a name with a colon in it; 400, 404, the
  validator, and a non-admin read. `test/checks/rendered-ui.mjs` pins that the
  page never asks for super ability descriptions in bulk.

**As built (PR 2).** Four places it differs from the list above, none of them a
change of decision:

- **The name is not in the `ETag`; it is in the body the tag is a hash of.** The
  plan said *"with the section and the name in it"*. A name is free text — 16 of
  the 364 carry an ampersand, and nothing stops one carrying a quote — and a
  quote inside an `ETag` is a malformed header. The body is `{name,
  description}`, so two entries cannot hash alike unless they are the same
  entry, which is the property the plan was after.
- **An error response carries no validator at all.** A section may now answer
  with a `Response` of its own, which the route passes through; the 400 and the
  404 are those. Nothing should be able to revalidate its way back to an error.
- **The page gained two helpers and not just a hook.** `detail` names the
  request; `textOf()` and `hasText()` are what keep every reader of a
  description — the entry, the *"N with text"* counter — from having to know
  which kind of section it is in. A row the list says has no text is never
  asked for.
- **The retry is closing the row and opening it again**, as planned — but the
  plan called it *clicking the row again*, which is one click short: the first
  click closes it.

Measured in a browser against a database built from the branch: *Loading…* and
then 7,275 characters for `Alter Physical Structure: Fire`; `Generate Fog &
Smoke` opens (the ampersand case); a simulated outage shows inside the entry
with no page-level panel, and the next open recovers; reopening an entry makes
no second request. At 375px the eight tabs sit 3+3+2 in 161px with the 12px
rule, and the list starts at the same 387px it did with seven.

## Out of scope

- The Morphus tables (173 rows, migration 068) have no codex tab either. A
  natural follow-up, and not this plan.
- Links from a held power on the sheet to its codex entry.
- Any change to the `catalogs` boot payload or to a picker.

## Risks

- **A round trip per expansion on a bad connection** is the cost D1 accepts. It
  is bounded by the per-page cache and the 304, and a failed fetch is retried by
  clicking the row again.
- **Seven and then eight tabs on a phone** — checked in PR 1, before PR 2
  depends on it.
