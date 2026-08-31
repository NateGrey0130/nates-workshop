# UI-AUDIT.md — Character Creator interface

Audited 2026-08-31, against the working tree at `C:\Users\natha\Projects\nates-apps`,
served from `wrangler pages dev --port 8791` (the `nates-apps-8791` launch config —
**not** 8788, which belongs to another worktree).

Scope is the **interface only**. Rules correctness, catalog data and book provenance
are out of scope and have their own menus. A finding here means: I could not see it,
could not reach it, could not tell what it meant, or it looked different here than it
looks two screens over.

Findings are numbered most severe first and each names the audit step it came from.
Nothing here has been changed. Take findings one at a time.

---

## Premise corrections — read first

The brief this audit was run from carried five claims about the app. Checking them
against the tree first, per the `audit-menu` rule that taking a finding means
auditing the finding:

| Claim | Verdict |
|---|---|
| "`dashboard.html` — the character list and entry point" | **Wrong.** `dashboard.html` is a *Campaign Dashboard* (party roster + journal) and 500s to `No campaign_id — open a dashboard from the Character Creator landing page` without a `?campaign_id=`. The character list and entry point is the **wizard's step 1** (`app.js:642,646`), which renders *Your campaigns* and *Existing characters* under the system picker. |
| "media queries at six different max-widths plus print" | **Confirmed for the max-widths, understated otherwise.** 15 `@media` blocks total: 9 max-width queries over exactly 6 distinct values (620 ×4, 700, 780, 820, 860, 900), **plus one `min-width: 700px`** (line 764, so 700 is both a max- and a min- breakpoint), **plus 5 separate `@media print` blocks** (597, 607, 646, 767, 848) — not one. `apps/character-creator/styles.css` is 851 lines; `shared/styles.css` is 160 and has **zero** `@media` of any kind. Verified by counting. |
| "`aria-`/`role=` four times in `sheet.js` and nowhere else, none in any of the five HTML shells" | **Confirmed exactly.** `sheet.js:814, 1095, 1099, 1100`. See F6 for why the four that exist are worse than none. |
| "`shared/js/ui.js` has `copyWithFeedback` and `openModal` and nothing else" | **Wrong.** It defines **four**: `openModal`, `closeModal`, `escHtml`, `copyWithFeedback`. More usefully: character-creator calls **only `escHtml`** and never the other three. |
| "Two of five pages carry extra header buttons" | **Wrong — one does.** Only `sheet.html` has `<button>`s in its header (`▶ Play`, `🖨 Print / Save as PDF`). The other four carry links only. See F27 for what is actually inconsistent. |

One further correction to a claim I made mid-audit and then disproved, recorded so it
is not re-found: the sheet's fixed `#play-roll-bar` looked like an uncompensated
overlay, but `.play-view` carries `padding-bottom: 72px` against a 45px bar. Nothing
is hidden. It is in **Verified clean** below.

---

## Screens inventory (Step 1)

Every distinct view reached, the viewports it was looked at, and the state it was in.
Content was built for this audit (see *Environment*): one saved Palladium Fantasy
character with 15 skills / 23 gear / 12 spells, two campaigns, two journal entries,
two NPCs, and one draft deliberately abandoned mid-build.

| # | Screen | Reached by | Viewports | State |
|---|---|---|---|---|
| 1 | Wizard step 1 — System / landing | `/apps/character-creator/` | 1440×900 | **empty** and **full** (both captured — campaigns + characters appear only once content exists) |
| 2 | Resume-draft prompt | reload with a live draft | 1440×900 | full |
| 3 | Wizard step 2 — Race, *Browse all*, Rifts | step 1 → Rifts | 1440×900, 390×844 | full (120 cards) |
| 4 | Wizard step 2 — Race, *Browse all*, Palladium Fantasy | step 1 → PF | 1440×900 | full (15 R.C.C.; O.C.C. count not read — the step's own heading was the only figure captured) |
| 5 | Wizard step 2 — Race, *Help me choose* | toggle on step 2 | 1440×900 | unanswered **and** all-three-answered |
| 6 | Wizard step 3 — Attributes, unrolled | step 2 → Confirm | 1440×900 | empty (nothing rolled) |
| 7 | Wizard step 3 — Attributes, rolled, minimum met | Roll all random | 1440×900 | full |
| 8 | Wizard step 3 — Attributes, **blocked** on class minimum | O.C.C.-first path (CAF Fleet Officer) | 1440×900 | full, primary disabled |
| 9 | Wizard step 4 — Occupation, no occupation chosen | step 3 → | 1440×900 | empty |
| 10 | Wizard step 4 — Occupation, minimum-unmet warning | choose Wizard with IQ 6 | 1440×900 | full |
| 11 | Wizard step 5 — Skills | step 4 → | 1440×900 | full (610 checkboxes) |
| 12 | Wizard step 5 — picker filtered to a lone match / to nothing | typing in `#secondary-filter` | 1440×900 | both |
| 13 | Wizard step 6 — Equipment, choices unresolved | step 5 → | 1440×900 | full, primary disabled |
| 14 | Wizard step 6 — Equipment, choices resolved | pick robe + weapon | 1440×900 | full |
| 15 | Wizard step 7 — Powers (spells + psionics roll) | step 6 → | 1440×900 | full (7 picks over 5 groups) |
| 16 | Wizard step 8 — Advancement | **not applicable to this build** — rendered `.st na` in the stepper only | 1440×900 | skipped (see F19) |
| 17 | Wizard step 9 — Details, unrolled and rolled | step 7 → | 1440×900 | both |
| 18 | Wizard step 10 — Review & save | step 9 → | 1440×900 | full |
| 19 | Wizard — save refused (server violations) | Save with IQ below minimum | 1440×900 | error |
| 20 | Wizard — save refused (missing name) | Save with no name | 1440×900 | error |
| 21 | Wizard — saved confirmation | successful save | 1440×900 | full |
| 22 | `sheet.html` — Vitals tab | `?id=1` | **1440×900, 820×1180, 390×844** | full |
| 23 | `sheet.html` — Skills tab | `#skills` | 1440×900, 390×844 | full |
| 24 | `sheet.html` — Powers tab | `#powers` | 1440×900 | full |
| 25 | `sheet.html` — Gear tab | `#gear` | 1440×900, 390×844 | full |
| 26 | `sheet.html` — Bio / Notes tabs | tab bar | 1440×900 | full |
| 27 | `sheet.html` — Play mode | `▶ Play` | 1440×900, 390×844 | full |
| 28 | `dashboard.html` — no `campaign_id` | direct URL | 1440×900 | error state |
| 29 | `dashboard.html` — campaign dashboard | `?campaign_id=2` | 1440×900 | full |
| 30 | `campaign.html` — Notes tab | `?campaign_id=2` | 1440×900 | **empty** and **full** (0 then 2 entries) |
| 31 | `campaign.html` — People tab | tab | 1440×900 | full (2 NPCs) |
| 32 | `catalog.html` — Skills catalog | direct URL | 1440×900, 820×1180 | full (345 rows) |
| 33 | `catalog.html` — character audit panel | `Audit characters` | 820×1180 | full (1 character, 3 warnings) |

**Not reached** — recorded rather than guessed at: `campaign.html` *Party stash* and
*Currency* tabs (both empty, no content built for them); the level-up / staged-class /
MOS surfaces in `docs/leveling.md` (need a character with XP past a threshold, which
this audit did not build); the spell/psionic *level-up* pickers; `import.html` (not
present in this tree). The print preview could not be rendered — see *Blockages*.

---

## Findings

### F1 — high — Sheet › Gear: the inventory remove button is clipped off-screen at phone width

**Step 2 (overflow).** Screenshot evidence: yes, `sheet.html?id=1#gear` at 390×844.

At 390px the equipment table is 367px wide inside a `.box-body` of 332px, and `.box`
carries `overflow: hidden` (`styles.css:227`). The fifth column — the per-row `✕`
remove button — lays out at x=364–396, past the `.box` right edge at 334. Because the
clip is `hidden` rather than `auto`, **there is no scroll to reach it**:
`document.documentElement.scrollWidth` stays 390, so the body never offers to scroll
either. Measured on the first inventory row: `removeBtn { left: 364, right: 396,
offScreen: true }`.

The result is that on a phone you cannot remove an item from a character's inventory,
and nothing on screen indicates a column has been cut off. The Notes column is
squeezed in the same movement.

This is Gear-specific: the Skills tab at the same width reports `clips: false` on all
three of its boxes, because it renders `.skill-row` divs rather than a `<table>`.

**Proposal:** put `overflow-x: auto` on `.box > .box-body` (not on `.box`, which needs
`hidden` for its rounded corners and title bar), so a table wider than its box scrolls
inside the box instead of being cut. One line, plus a check that the sticky `.tabbar`
above it is unaffected. Do **not** restack the equipment table into cards at phone
width in the same PR — that is a bigger design decision and would make this fix
unreviewable.

**Taken, 2026-08-31 (PR #439).** Implemented as written: `overflow-x: auto` on
`.box > .box-body`, not on `.box`. Posture as written — one declaration, and the
equipment table was **not** restacked into cards.

Every premise was re-measured at 390×844 before the change and all of them held:
23 remove buttons at left 364 / right 396 against a `.box-body` right edge of
361, `.box` computing `overflow: hidden`, `.box-body` computing
`overflow-x: visible`, and `document.documentElement.scrollWidth` sitting at 390,
so the page offered no scroll of its own to recover them. After: the body scrolls
55px, the button lands at right 341 inside a right edge of 361, and the page
still does not scroll horizontally.

The sticky `.tabbar` is unaffected. It is a sibling of the tab panels rather than
a descendant of any `.box-body` (`sheet.js:1095`), and still computes
`position: sticky` after the change. At 1440×900 none of the sheet's 16 box
bodies overflows at all, so the rule is inert everywhere it is not needed.

One consequence the finding did not raise, recorded rather than acted on: paper
cannot scroll, so a table wider than its printed box is still clipped. That is
not a regression — `.box`'s `overflow: hidden` clipped it identically before —
but it belongs with **F17** whenever print is actually verified.

---

### F2 — high — One attribute-minimum rule, three different behaviours, and the middle one's copy is false

**Step 3 (flow).** Screenshot evidence: yes — three screenshots, one per behaviour.

The same rule ("your attribute is below the class minimum") is enforced three
different ways depending on which path you took through the wizard:

1. **Hard block, step 3.** Picking an O.C.C. at step 2 (CAF Fleet Officer) makes the
   minimum knowable at Attributes. Rolling IQ 9 / ME 5 gives per-row hints
   (`need 12+`), a panel warning, `.nav-why` = *"Class minimum not met: IQ 12+, ME
   12+."*, and the primary button `disabled: true, opacity 0.45, cursor: not-allowed`.
   You cannot proceed.
2. **Soft warning that says continuing is fine, step 4.** Picking an R.C.C. at step 2
   (Elf) defers the occupation to step 4. Choosing Wizard with IQ 6 renders *"Below
   Wizard's minimum"*, a re-roll offer, and this sentence verbatim:
   **"Continuing with a minimum unmet is allowed and is flagged on the character."**
   The button stays live.
3. **Hard refusal, step 10.** Following that instruction and building the whole
   character out — skills, equipment, spells, background rolls, name, campaign — the
   save is refused: *"Save failed: This character breaks its class rules — IQ is 6,
   below the class minimum of 10."*

So the app tells you continuing is allowed, lets you spend seven more steps on it, and
then refuses. `docs/wizard-and-sheet.md` describes (2) as deliberate — *"A missed
attribute minimum is deliberately NOT one of them"* — but it does not mention that
`_lib/validate-character.js` treats the same condition as a blocking violation at
create, nor that path (1) blocks outright.

The cheapest honest fix is the copy, not the enforcement. Whatever the rule is, the
sentence on step 4 currently states the opposite of what happens.

**Proposal:** documentation-and-copy only, no change to either gate. Replace the step-4
sentence with one that is true of the save — e.g. *"This build will be refused on save
unless a GM overrides it; re-roll, or go back and pick a class this character meets."* —
and add a line to `docs/wizard-and-sheet.md` recording that the minimum is a blocking
violation server-side and that the two wizard paths surface it at different steps.
Reconciling (1) and (2) into one behaviour is a **separate, larger** finding and should
not be folded into this PR.

**Taken, 2026-08-31 (PR #441).** Posture as written: copy and documentation only.
Neither gate moved, and reconciling (1) and (2) remains open and unstarted.

**The proposal's own suggested sentence was false, and was not shipped.** It
offered *"…will be refused on save unless a GM overrides it"*. There is no GM
override for an attribute minimum. `characters.js:191` returns 422 the moment
`violations` is non-empty, and the only rule in the file that yields to a GM is
`enforcePools: email !== campaign.gm_email` (`characters.js:184`) — which governs
pool maxima, not attributes. The audit's own step-10 refusal was in fact a GM
being refused; the character it built carries the `GM` tag. Writing the sentence
as proposed would have replaced one false statement with another.

What shipped instead, both lines of the panel, because both were untrue:

- *"…or continue as you are — nothing here stops the build"* → *"…or go back and
  choose an occupation this character meets."*
- *"Continuing with a minimum unmet is allowed and is flagged on the character"*
  → *"This step will let you carry on, but the save at the end will not: a
  character below its class minimum is refused, the GM's own included."*

The second half of the old sentence — *"and is flagged on the character"* — was
false in its own right and is simply gone: a character that cannot be saved
cannot carry a flag.

`docs/wizard-and-sheet.md` gains a paragraph under *A blocked step says why*
recording that not-gated is not the same as allowed, that the O.C.C.-first path
gates at Attributes while the R.C.C.-first path only warns at Occupation, and
that the save refuses either way with no GM exemption.

Verified by driving the wizard: Palladium Fantasy → Elf → manual attributes with
IQ 6 → Occupation → Wizard renders the new panel, `IQ 6 — needs 10+, short by 4`,
with the primary button still live. Screenshot at 1440×900.

---

### F3 — high — Race step: 120 unfiltered class cards, and the primary button 12 screens down

**Step 2 (above the fold).** Screenshot evidence: yes, at 1440×900 and 390×844.

The Rifts race step renders **42 R.C.C. + 78 O.C.C. = 120 cards** in one page with
**zero inputs of any kind** on the step (`#app input, #app select, #app textarea`
returns 0). Measured:

| Viewport | Page height | Screens | Primary button (`Confirm and roll →`) |
|---|---|---|---|
| 1440×900 | 11,027px | 12.3 | 12.1 screens down |
| 390×844 | 26,714px | 31.7 | 31.5 screens down |

Neither the stepper nor the nav is sticky (`position: static`, nav at y=10932 on
desktop). So after clicking a class near the top of the list there is nothing on
screen indicating the next action exists, and no way to reach it but a 12- to
31-screen scroll. Palladium Fantasy is smaller and still puts the primary 5.5 screens
down.

This is also the app's one **inconsistent picker**: `docs/wizard-and-sheet.md` records
that all six other pickers gained a filter box with a live count, and the two on the
Skills step do have one (`221 of 221`, `345 of 345`). The longest list in the
application is the one without.

There is no horizontal overflow at any viewport (`docScrollW` 390 at phone) — the
problem is purely vertical.

**Proposal:** add the existing `Picker.wire()` filter box to the class grid on step 2,
matching the Skills step exactly (same markup, same `N of M` count, same
name/category/source-book matching). This reuses `js/picker.js` and introduces no new
component. Making the nav sticky is a **separate** finding and should not ride along —
it would change every step, not this one.

**Taken, 2026-08-31 (PR #442).** Implemented as written: `Picker.inputHtml` above
the grid, `class-filter` added to the `wirePickers()` loop beside the other four,
and `Picker.filter` over the same `name` / `category` / `source_book` fields the
Skills step uses. No new component, and the nav is still `position: static` —
that stays a separate finding.

Measured on the Rifts race step at 1440×900:

| | before | typing `ley` |
|---|---|---|
| cards | 120 | 2 |
| count | *(none)* | `2 of 120` |
| page height | 11,052px | **900px** |
| screens | 12.3 | **1.0** |
| primary button | 12.1 screens down | on screen, y=533 |

`occ` narrows to 78 of 120 through the category field and a book name narrows
through `source_book`, so the matching genuinely is the Skills step's. The caret
survives a keystroke — `Picker.wire`'s reason for existing — verified by reading
`selectionStart` back after an input event.

Two behaviours worth recording because they are deliberate. **A selected class
can be filtered out of the grid**: `classDetail()` renders below the grid rather
than inside it, so the choice, its variant picker and its ability picker all stay
on screen and the Confirm button keeps working. And **the filter input renders
even when nothing matches** (`Nothing matches that filter.`, `0 of 120`), so the
box that emptied the page is still there to clear.

`S.classFilter` sits with the other four filters and is **not** in `DRAFT_KEYS` —
transient view state, so resuming a build does not resume half a search. No
draft-shape change and no `STEPS_VERSION` bump.

---

### F4 — high — "Help me choose" returns all 120 classes, 38 of which match nothing, on a longer page

**Step 3 (flow).** Screenshot evidence: yes, at 1440×900, before and after answering.

The Race step has a second mode that looks like the answer to F3: three questions
("What are you playing?", "How do you want to solve problems?", "What flavor of gear
and setting?"), and unanswered it is a clean single-screen form. Answering all three
produces a heading **"Your shortlist"** — and then renders every class in the game:

```
totalPicks: 120
matchTally: { "6/6": 29, "4/6": 22, "2/6": 31, "0/6": 38 }
page height: 12,206px (13.6 screens) — LONGER than Browse all's 11,027px
primary button: 13.5 screens down
```

The list is sorted by match score and badged (`MATCH 6/6`), which is genuinely useful,
but 38 of the entries match **none** of the three answers and are still printed in
full. A "shortlist" that contains the entire catalogue, a third of it scoring zero, is
worse than the browse list it was meant to replace: same content, more scrolling, and
a label that says otherwise.

**Proposal:** cut the rendered shortlist to the classes that score above zero, and put
the remainder behind a `Show the N that match nothing` disclosure. Keep the ranking and
the badges exactly as they are. Do not change the three questions or the scoring in
this PR.

---

### F5 — high — The wizard cannot be completed with a keyboard: every choice is a non-focusable `<div>`

**Step 5 (accessibility).** Screenshot evidence: none needed — this is a DOM/source
fact, verified by reading both the live DOM and the source.

Six sites render a click target on a non-interactive element with no `role`, no
`tabindex` and no key handler. Live DOM confirmation for a class card:

```html
<div class="pick" onclick="pickClass('ley-line-walker')"> …   <!-- tabIndex: -1 -->
```

| Site | Element | What it does |
|---|---|---|
| `app.js:543` | `<span class="st done" onclick="goStep(i)">` | jump back to a completed wizard step |
| `app.js:630` | `<div class="pick" onclick="pickSystem('palladium-fantasy')">` | step 1 choice |
| `app.js:633` | `<div class="pick" onclick="pickSystem('rifts')">` | step 1 choice |
| `app.js:899` | `<div class="pick" onclick="pickClass(id)">` | the class grid — **120 instances** on the Rifts race step |
| `campaign.js:321` | `<div class="chkrow" onclick="openNpc(id)">` | open an NPC dossier |
| `catalog.js:301` | `<div class="cat-row" data-edit>` (bound at `catalog.js:534`) | open a catalog row's edit form — **345 instances** |

Steps 1 and 2 of the wizard are *only* reachable by mouse, so a keyboard user cannot
begin a character at all — everything downstream (checkboxes, selects, buttons) is
properly focusable and would otherwise work.

Note a grep for `<div … onclick=` finds only four of these: `app.js:543` builds its
handler in a separate `go` variable and `catalog.js:301` binds via `addEventListener`.
Counting these by pattern under-reports.

**Proposal:** convert the five `onclick` sites to `<button type="button">` and give
`catalog.js`'s `.cat-row` `role="button"` + `tabindex="0"` + a keydown handler, then
add the `:focus-visible` rule from F16 so the focus lands somewhere visible. Ship the
`.pick` cards (steps 1 and 2) **first and alone** — that is the pair that blocks
starting a character, and `.pick` is styled as a block so the `<button>` swap needs
`display: block; width: 100%; text-align: left` and will want its own screenshot pass.

---

### F6 — high — `--text-muted` fails contrast on every background in the system, at 9–13px

**Step 5 (accessibility).** Screenshot evidence: none — computed, not eyeballed.

Ratios computed from the token values in `shared/styles.css:8–30` with the WCAG
relative-luminance formula (script kept in the session scratchpad; recomputed
independently of the first pass and identical):

| text | `--bg-primary` | `--bg-secondary` | `--bg-tertiary` | `--bg-card` | `--bg-input` |
|---|---|---|---|---|---|
| `--text-primary` `#e8ecf4` | 16.53 | 15.43 | 14.07 | 14.69 | 13.37 |
| `--text-secondary` `#8b92a8` | 6.31 | 5.89 | 5.38 | 5.61 | 5.11 |
| **`--text-muted` `#5a6178`** | **3.18** | **2.97** | **2.71** | **2.83** | **2.57** |

`--text-muted` fails 4.5:1 on all five, and fails even the 3:1 large-text allowance on
four of the five. It is genuinely used on `--bg-card` (2.83:1) — `.panel` and `.box`
both set `background: var(--bg-card)` — for `th`, `.vital .lbl` (9px), `.skill-head`
(9px), `.field > .lbl` (10px), `.nav-why` (13px), `.attr-note` (11px) and a dozen more.
All are 9–13px, so the large-text allowance does not apply to any of them.

Separately, `--border` `#2a2f3e` sits at **1.19–1.47** against these backgrounds, below
the 3:1 minimum for non-text UI components — that is every panel edge, table rule and
dotted leader in the app.

`--text-secondary` passes everywhere (5.11–6.31) and is the obvious landing place.

**Proposal:** darken-proof the token rather than patching call sites — lighten
`--text-muted` in `shared/styles.css` until it clears 4.5:1 on `--bg-input`, the
darkest pairing (roughly `#7b8296`). **Flag as bigger than it looks:** this is the
shared stylesheet, so it moves `filament-forge`, `media-vault` and `pick3cut5` too, and
each needs a screenshot pass before merge. `--border` is a **separate** finding — it
has a different threshold and a different visual risk.

---

### F7 — medium — Half the sheet's tabs are outside the visible tab strip at phone width

**Step 2 (overflow).** Screenshot evidence: yes, `sheet.html?id=1` at 390×844.

`.tabbar` is `overflow-x: auto` (`styles.css:821`), which is the right mechanism, but
at 390px the strip is 334px wide against 544px of tabs:

| tab | right edge | fully visible |
|---|---|---|
| Vitals | 101 | yes |
| Skills 15 | 203 | yes |
| Powers 12 | 321 | yes |
| **Gear 23** | 428 | **no** |
| **Bio** | 492 | **no** |
| **Notes** | 572 | **no** |

Gear is cut mid-word and Bio and Notes are entirely off-strip. The only affordance is
the scrollbar. Gear is the tab a player uses most in session, and F1 means it is also
the one that is broken when you get there.

Credit where due: the bar is `position: sticky; top: 0; z-index: 20` and each `.tab`
has `min-height: 44px` with the comment *"sized for a finger, not a mouse pointer"* —
the touch sizing and the stickiness are right. And the tab bar is **above the fold at
all three viewports** (y=352 of 844 at phone, y=321 of 1180 at tablet), so the
regression `docs/wizard-and-sheet.md` describes has not come back.

**Proposal:** at `max-width: 620px` let `.tabbar` wrap to two rows (`flex-wrap: wrap`
and drop `flex: 1 0 auto` to `flex: 1 1 auto`) instead of scrolling, so all six tabs
are visible at once. Adds nothing new; uses a breakpoint that already exists.

**Taken, 2026-08-31 (PR #440).** Implemented as written, at the breakpoint written,
with both declarations. All six tabs are now fully visible at 390×844 in two rows
of three, `overflowing: false`, and the `44px` touch height survives the wrap.

**Two corrections to the measurements above.** The strip needs **569px**, not
544 — the Notes tab gained a `2` count pill once the audit's journal entries
existed, and the right edges shift with it (Notes ends at 597, not 572). The
conclusion is unchanged: three of six visible before, six of six after.

**And the breakpoint does not quite reach the overflow.** 620px was chosen
because it already exists, but the strip stops overflowing at **632px**, so
between 621 and 631 the old scrolling behaviour survives and the Notes tab is
cut by about 4px. Left as written rather than widened to 700: the band is 11px
across, no common device sits in it, and moving the breakpoint is a decision
about the whole stylesheet rather than about this bar. Recorded here so the next
reader does not rediscover it as a bug.

The sticky bar grows from **76px to 111px** at phone width — 13% of an 844px
viewport, permanently. It stays above the fold (top 352). Tab text does not clip:
`1 1 auto` lets flex wrap before it shrinks, and every tab's `scrollWidth` still
equals its `clientWidth` at 390px. `.tabbar` is used only by `sheet.js`, so
nothing else in the app moves.

---

### F8 — medium — Required-looking skill picks can be skipped in silence, and only an admin screen ever says so

**Step 3 (flow).** Screenshot evidence: yes — Skills step, Review step, and the
catalog audit panel.

The Skills step renders choice groups headed **"Pick 2 — 0/2 chosen"**, **"Pick 1 —
0/1 chosen"** (languages, literacy, lore, weapon proficiencies) among its 610
checkboxes. Leaving them unmade:

- the primary button stays enabled and there is no `.nav-why` (`why: null`);
- the **Review** step lists `Skills (15)` and says nothing about them;
- the save succeeds.

The only surface in the entire app that mentions it is the **admin-only** character
audit on `catalog.html`, which afterwards reported, on exactly the groups I skipped:

```
Aelric Dawnthistle   elf · L1   3 WARNINGS
  • Looks short of 2 from Literacy: Other (counted 1) — approximate
  • Looks short of 1 from Lore: Astral / … / Lore: Vampires (counted 0) — approximate
  • Looks short of 1 from Weapon Proficiencies skills (counted 0) — approximate
```

So the app knows. The player never finds out. `docs/wizard-and-sheet.md` justifies
*not blocking* on these (choice groups are approximate and would over- and
under-count), and that reasoning is sound — but "do not block" was implemented as "do
not mention", which is a different decision.

**Proposal:** warn, do not block — no new gate. Render an advisory line on the Review
step listing any choice group still short, using the same wording the audit endpoint
already produces, with the primary button left live. Reuse the existing
`.advisory` style. The Skills step's own gating is untouched.

---

### F9 — medium — A refused save leaves an orphan campaign, and the landing page cannot tell the two apart

**Step 3 (states/errors).** Screenshot evidence: yes, wizard step 1 in the full state.

Typing one new campaign name and pressing Save twice — once refused for F2's IQ
violation, once successful — produced two campaigns:

```
id 1  The Northern Wilds  palladium-fantasy  2026-08-31 21:17:28   (0 characters)
id 2  The Northern Wilds  palladium-fantasy  2026-08-31 21:20:27   (1 character)
```

The campaign is created before the character is validated, so a refusal keeps it. The
wizard's step 1 then lists both, rendered as bare links with nothing but the name and
system:

> **Your campaigns (GM)**
> 🗺 The Northern Wilds (palladium-fantasy) · 🗺 The Northern Wilds (palladium-fantasy)

Two identical entries, no id, no date, no character count, no way to tell which one
holds your character short of opening both. The underlying create-before-validate
ordering is a server concern and out of scope here; the part that is a UI finding is
that the list is unable to distinguish its own rows.

**Proposal:** give each campaign row on step 1 its character count and creation date —
`The Northern Wilds (palladium-fantasy) · 1 character · 31 Aug` — so duplicates and
empties are visible at a glance. Display only; do not add a delete control and do not
touch the create ordering in this PR.

---

### F10 — medium — `.panel-inset` is used 16 times and defined nowhere

**Step 4 (visual consistency).** Screenshot evidence: none needed — verified by
reading every stylesheet in the repo.

```
apps/character-creator/app.js       12 uses
apps/character-creator/campaign.js   4 uses
                                    16 total
CSS definitions, whole repo:         0
```

The class appears on the race briefing, the starting-level block, the variant picker,
the O.C.C. picker, the ability picker, the level-up skill picks (`app.js:766, 842,
1025, 1057, 1100, 1169, 1300, 1365, 1390, 1449, …`) and the campaign notes list
(`campaign.js:186, 321, …`). Every one of those is a *nested* block that was clearly
meant to be visually inset from its parent panel, and none of them is — they render
flush, so a picker inside a panel reads as part of the panel.

**Proposal:** add one `.panel-inset` rule to `apps/character-creator/styles.css` —
`background: var(--bg-secondary); border: 1px solid var(--border); border-radius:
var(--radius-sm); padding: 10px 12px; margin: 10px 0` — and screenshot the six wizard
surfaces that use it, because sixteen blocks gaining a background at once is a visible
change even though no markup moves. App stylesheet only; this does not belong in
`shared/`.

---

### F11 — medium — Three different tab bars do the same job in one app

**Step 4 (component drift).** Screenshot evidence: yes — sheet, campaign and catalog.

| Where | Markup | Height / type | ARIA |
|---|---|---|---|
| `sheet.js:1095` | `<nav class="tabbar" role="tablist">` + `<button class="tab" role="tab" aria-selected>` | 44px min, bordered boxes, count in a `.tab-n` pill | `role="tablist"`, `role="tab"`, `aria-selected` |
| `campaign.js` | `<div class="toggle">` + `<button class="on">` | 30px, 13px font, count inline as `(2)` | none |
| `catalog.js:179` | `<div class="imp-tabs cols-4">` | large cards in a grid, count as `345 rows` | none |

Three components, three visual languages, three counting conventions, for one
interaction. The wizard's step 2 also uses `.toggle` for *Browse all / Help me
choose*, which is a legitimate two-state control — that use is fine. The one that is
wrong is `campaign.js`, which uses a two-state toggle to switch **four** panels.

The sheet's `.tabbar` should win: it is the only one sized for touch and the only one
with any ARIA.

**Proposal:** move `campaign.js`'s four-panel switcher from `.toggle` to `.tabbar`,
reusing the existing class and its `.tab-n` count pill. Leave `catalog.js`'s
`.imp-tabs` alone (see F15) and leave the wizard's genuine two-state `.toggle` alone.
One page, one component swap.

---

### F12 — medium — The Details step's ~20 fields have no programmatic label

**Step 5 (accessibility).** Screenshot evidence: none — read from source and confirmed
in the accessibility tree.

The accessibility tree for wizard step 9 returns twenty entries of the form
`textbox [ref_N] type="text"` with **no name at all**, plus an unnamed
`checkbox "on"`. Reading the source explains why (`app.js:2808–2811`):

```js
return `<div class="rowline">
  <label class="small" style="min-width:132px">${esc(bioLabel([key, label]))}…</label>
  ${control}${die}${ageOpt}
</div>`;
```

The `<label>` is a **sibling** of the control and carries no `for=`. There are zero
`for=` attributes in `app.js`. The same pattern renders the Review step's *Character
name* and *Campaign* fields (`app.js:3082, 3084`) and the attribute-method selects on
step 3.

Notably the app already does this correctly elsewhere: every checkbox row **wraps** its
input inside the `<label class="chkrow">` (`app.js:1036, 2012, 2060, 2265, 2478, 2502`),
which associates them properly. So the fix is a known-good pattern already in the file,
applied inconsistently.

**Proposal:** give each control an `id` and its label a matching `for=` in
`bioRow()`/`kvRow()` — the two functions that render these rows — so the fix lands in
two places rather than twenty. Attribute-method selects and the Review fields are a
**separate** PR.

---

### F13 — medium — Discarding an unfinished build is one unconfirmed click

**Step 3 (destructive actions).** Screenshot evidence: yes, the resume-draft prompt.

`Discard and start fresh` calls `dismissDraft()` → `discardDraft()` → `DELETE /draft`
with no confirmation anywhere in the chain (`app.js:484–513`; `app.js` contains three
`alert()` calls and **zero** `confirm()` calls). The draft it destroys includes the
rolled attributes, which `docs/wizard-and-sheet.md` names as the exact thing the draft
feature exists to protect: *"a roll is the one thing you cannot honestly redo"*.

The button sits directly beside `Resume this build` in the same `.nav` row, styled
`btn-ghost` against the primary — a mis-click distance of a few hundred pixels from
the action you actually wanted.

`discardDraft()` also swallows its own failure (`catch { }`), so a delete that does not
land is silent, and the offer will reappear on the next load with no explanation.

Elsewhere in the app destructive actions **are** confirmed — `sheet.js` has 3
`confirm()` calls, `campaign.js` 2, `catalog.js` 2. Draft discard is the outlier.

**Proposal:** wrap `dismissDraft()` in a `confirm()` naming what is lost — *"Discard
the unfinished Elf build, including its rolled attributes?"* — matching the existing
confirm pattern in `sheet.js`. No new component, no modal.

---

### F14 — medium — `@mentions` render as plain text, contradicting the instruction directly above them

**Step 3 (discoverability).** Screenshot evidence: yes, `campaign.html` Notes tab.

The note form says, in the app's own words:

> Everyone in the campaign can read and add notes. Type **@Name** to link someone to
> their dossier — a new name gets one.

Posting a note containing `@Brother Osric` and `@Halgi` does create the dossiers —
*People* went from (0) to (2). But the rendered note body contains **zero links**
(`linksInBody: []`); the mentions are plain text inside
`<p class="small" style="white-space:pre-wrap">`. The half of the promise that is
visible on screen is the half that does not happen.

The dossiers *are* reachable, from the People tab — but via
`<div class="chkrow" onclick="openNpc(2)">`, which is F5's problem (mouse-only, no
link affordance beyond `cursor: pointer`).

**Proposal:** linkify `@Name` in the note body at render time to the same
`openNpc(id)` the People tab uses, styled as a link. Do this **after** F5 converts
those targets to real controls, so the new links inherit a focusable one rather than
adding a sixth `div onclick`.

---

### F15 — medium — The catalog tab grid is hardcoded to 4 columns for 5 catalogs, and its tablet rule targets a class nothing uses

**Step 4 (breakpoints).** Screenshot evidence: yes, `catalog.html` at 1440×900 and
820×1180.

`catalog.js:179` hardcodes the column count:

```js
return `<div class="imp-tabs cols-4">${CATALOG_KEYS.map(…)}`
```

while `CATALOG_KEYS = Object.keys(CATALOGS)` (`js/catalog-fields.js:198`) is dynamic and
currently **5** (skills, spells, psionic powers, enchantments, gear). So Gear drops onto
a second row by itself at every width above 780px — visible at both 1440 and 820.

The CSS compounds it. `cols-5` is defined three times and applied to nothing:

```
409  .imp-tabs.cols-4 { grid-template-columns: repeat(4, 1fr); }
410  .imp-tabs.cols-5 { grid-template-columns: repeat(5, 1fr); }
411  @media (max-width: 900px) { .imp-tabs.cols-5 { … repeat(3, 1fr); } }   ← cols-5 only
412  @media (max-width: 780px) { .imp-tabs.cols-4, .imp-tabs.cols-5 { … 1fr 1fr; } }
413  @media (max-width: 620px) { .imp-tabs, .imp-tabs.cols-4 { … 1fr; } }
```

`cols-5` appears in **zero** JS or HTML files. Line 411 — the only rule that would help
at tablet — therefore fires on nothing, and at 820×1180 the catalog renders four
cramped tabs plus an orphan in a ~760px column.

**Proposal:** derive the class from the data — `cols-${CATALOG_KEYS.length}` — so the
grid tracks the catalogue count, and extend line 411 to cover `.cols-4` as well as
`.cols-5`. Two small edits, one in `catalog.js` and one in `styles.css`. Deleting the
now-reachable-again `cols-5` rules is **not** part of this; they become correct.

---

### F16 — medium — No `:focus-visible` and no `prefers-reduced-motion`, while a sibling app has both done well

**Step 5 (accessibility).** Screenshot evidence: none — counted across three
stylesheets.

```
                                    :focus-visible   prefers-reduced-motion
apps/character-creator/styles.css         0                   0
shared/styles.css                         0                   0
apps/pick3cut5/styles.css                 1                   1
```

The app's only focus rule is `styles.css:84`:

```css
input:focus, select:focus, textarea:focus { outline: none; border-color: var(--border-focus); }
```

— which removes the outline from every text control and replaces it with a 1px border
colour change. Buttons, links and `<summary>` keep the UA default outline, which
`pick3cut5`'s own comment calls unreadable on this palette: *"the default is a hairline
against a near-black background"*. Combined with F5's non-focusable divs, a keyboard
user gets no usable focus indication anywhere in the wizard.

The in-repo precedent is `apps/pick3cut5/styles.css:44–50` and `545–557` and should be
copied rather than re-invented; it also ships an `.sr-only` helper the character
creator has no equivalent of.

**Proposal:** copy pick3cut5's `:where(button, input, a, summary, [tabindex]):focus-visible`
block into `apps/character-creator/styles.css`, keeping line 84's border change as the
non-keyboard affordance. **App stylesheet only** — promoting it to `shared/styles.css`
would give three other apps a focus ring overnight and is a bigger finding than it
looks. `prefers-reduced-motion` is a **separate** item and genuinely low value here:
the app's only transitions are `color`/`border-color` at 0.2s.

---

### F17 — medium — Print: a long table splits across pages with no repeated header, and I could not render a preview

**Step 2 (print).** **Screenshot evidence: none — see Blockages.** This finding is from
reading the five `@media print` blocks and the live DOM, not from a rendered page, and
should be re-checked against an actual print preview before it is taken.

What reading establishes:

- The tab mechanism dissolves correctly. `styles.css:848–851` hides `.tabbar` and sets
  `.tabpanel { display: contents !important }`, so all six tabs print in document
  order, exactly as `docs/wizard-and-sheet.md` describes. `.tabbar` is caught twice
  over — it also carries `noprint`, which line 651 hides.
- The sheet header does not print. Line 651 hides `header, .header, button, input,
  textarea, select, #msg, .noprint` with `!important`, so the `▶ Play` button — which,
  unusually, has no `noprint` class of its own while the print button does — is still
  caught three ways (ancestor `header`, ancestor `.header`, bare `button`).
- Ink is handled for the main containers: `body`, `.panel`/`.box`, `.box > .box-title`
  and `.tag` all get explicit light backgrounds with `!important`.

What looks wrong:

- **`break-inside: avoid` is set on `tr`, `.pool`, `.entry`, `.rowline` and on
  `.panel, .box` — but not on `table`, and `<thead>` is not set to repeat.** A skills
  or equipment table longer than a page therefore splits with each row intact but no
  column headers on the continuation page. This is the "page breaks mid-table" risk,
  and it is the one the official form it imitates would not have.
- Several dark backgrounds are never reset for ink — `.stepper .st`, `.lvl-row`,
  `pre.snippet`, `.cat-row.open`. Most browsers drop backgrounds by default, so this
  only bites a user who ticks *Background graphics*, but the wizard and catalog pages
  inherit the sheet's print block without being tuned for it at all.

**Proposal:** add `thead { display: table-header-group }` and `table { break-inside:
auto }` to the print block at `styles.css:646`, so a long table repeats its header
rather than orphaning rows. **Verify against a real print preview first** — if the
preview shows tables already behaving, close this as moot and record that.

---

### F18 — low — Catalog rows print raw JSON at the reader

**Step 2 (density).** Screenshot evidence: yes, `catalog.html` at both viewports.

The first row of the skills catalogue reads:

> **Acrobatics**  Category: Physical  Base %: 30  +% / level: 5  Bonuses: `{"attributes":{"PS":1,"PP":1,"PE":1},"combat":{…`

The `Bonuses` field is rendered as serialized JSON and truncated mid-object, so it is
simultaneously unreadable and incomplete. It is the widest thing in the row and pushes
the useful fields left.

**Proposal:** render `bonuses` as the same `+1 PS · +1 PP · +1 PE` summary the sheet
already produces, or omit it from the row and keep it in the edit form. Display only.

---

### F19 — low — Why a step is skipped is available only on hover

**Step 3 (flow).** Screenshot evidence: yes, stepper at 1440×900 and 390×844.

A step that does not apply renders as `.st na` and explains itself with a `title`
attribute (`app.js:540`):

```html
<span class="st na" title="Does not apply to this character">8. Advancement</span>
```

`title` is a mouse-only affordance. At 390×844 and 820×1180 — two of the three
viewports this audit covers — there is no way to discover why step 8 is greyed and
dashed, and no legend anywhere on the page. The stepper is also missing `aria-current`
on `.st cur` and any disabled semantics on `.st na`.

**Proposal:** render the reason as visible text under the stepper when a step is
skipped — one line, *"Step 8 (Advancement) does not apply to this character."* — and
keep the `title` for the mouse. Add `aria-current="step"` to `.st cur` in the same
edit.

---

### F20 — low — `var(--warn, …)` names a token that does not exist, so the fallback is permanent

**Step 4 (token drift).** Screenshot evidence: none needed.

`styles.css:538`:

```css
border-radius: 999px; background: var(--warn, #b8860b); color: #fff;
```

`--warn` is **defined in no stylesheet in the repo** — the token is `--warning:
#fbbf24` (`shared/styles.css:23`). The fallback fires 100% of the time, so `.dupe-badge`
is permanently dark goldenrod instead of the warning colour, and the badge silently
sits outside the palette.

Two related dead fallbacks in the same file: `var(--success, #2e7d32)` at lines 519 and
524 — `--success` exists (`#34d399`), so `#2e7d32`, a completely different green, is
unreachable and would take over if the token were ever renamed.

**Proposal:** `var(--warn, #b8860b)` → `var(--warning)`, and drop the two dead
`#2e7d32` fallbacks. Three characters of real change; screenshot the duplicates panel
because the badge colour visibly moves.

---

### F21 — low — The catalog is 345 rows of ragged inline text with no pagination

**Step 2 (density).** Screenshot evidence: yes, at 1440×900 and 820×1180.

345 rows, 12,915px, 14.3 desktop screens, all rendered at once. Each row is a bold name
followed by four to five `<span class="muted small">` fields laid out inline, so
nothing aligns column-to-column: `Base %: 30` sits at a different x on every row
depending on how long the name was, and a long source book (`Astronomy & Navigation`)
wraps its fields onto a second line and breaks the rhythm entirely.

The filter and category select above work well (`345 of 345` updates live), which is
what makes this liveable — but the default state is a wall.

**Proposal:** lay the row fields out as a fixed grid (name / category / base % / per
level / source) so the columns line up, reusing `.kv-row`'s existing grid vocabulary.
Pagination is a **separate**, larger question — the filter mostly covers it.

---

### F22 — low — 21 bare `✕` buttons with no accessible name

**Step 5 (accessibility).** Screenshot evidence: yes, wizard step 6.

Every equipment row's remove control is:

```html
<button class="btn btn-sm btn-ghost" onclick="rmEquip(0)">✕</button>
```

Its accessible name is the glyph `✕`. On the Equipment step there are **21** of them,
so a screen reader offers twenty-one identically-named buttons with no indication of
which item each removes. Measured hit target 32×24 — over the 24×24 WCAG 2.2 AA
minimum, under the 44×44 the app's own `.tabbar .tab` sets for itself.

**Proposal:** add `aria-label="Remove ${item name}"` and `title` to the remove buttons
in the equipment row renderer and on the sheet's inventory rows. Do not resize them in
this PR — that changes row height everywhere.

---

### F23 — low — Filtering one skill column to nothing leaves a 5,606px empty column beside the other

**Step 2 (overflow).** Screenshot evidence: none — measured in the DOM at 1440×900.

Related and Secondary skills sit in `.cols`, a two-column stretch grid
(`styles.css:102`, `grid-template-columns: 1fr 1fr`, `align-items: normal`). Filtering
Secondary to zero matches leaves its column with four children totalling ~69px of
content, stretched to **5,606px** to match the still-full Related column beside it.

The empty state itself is correct and well-worded — *"Nothing matches that filter."* —
it is just marooned at the top of six screens of nothing.

**Proposal:** `align-items: start` on `.cols` so a short column stops stretching. One
declaration; check the Review step, which also uses `.cols`.

---

### F24 — low — No `<h1>` on any page, and heading order skips levels

**Step 5 (accessibility).** Screenshot evidence: none — read from the five shells and
the rendered DOM.

All five shells render their title as `<div class="logo">`, so there is **no `<h1>`
anywhere in the app**. The first heading rendered differs per page:

| page | first heading | skips |
|---|---|---|
| `index.html` (wizard) | `h2` | yes — `h2` → `h4` twice (system cards `app.js:631,634`; class cards `app.js:900`). The `.pick-group` labels that would be `h3` are `<div>`s. |
| `dashboard.html` | `h2` | no |
| `sheet.html` | **`h3`** — `sheet.js` contains zero `h2` | yes |
| `campaign.html` | `h2` | no |
| `catalog.html` | **`h4`** — `catalog.js` has only `h4` | yes |

Confirmed on the live Race step: `h1count: 0`, one `h2`, zero `h3`, 120 `h4`.

**Proposal:** promote each page's `.logo` to `<h1 class="logo">` in the five shells —
five one-line edits, no visual change, since `.logo` carries its own type. Fixing the
`h2`→`h4` jumps inside `app.js`/`catalog.js` is a **separate** finding.

---

### F25 — low — The app stylesheet's header comment describes three pages; there are five

**Step 4.** Screenshot evidence: none needed.

`apps/character-creator/styles.css:1–3`:

> Character Creator — app styles on top of /shared/styles.css.
> One stylesheet for all three pages (wizard, sheet, dashboard); they share
> most of their vocabulary (panels, tags, tables, pools).

The file also styles `campaign.html` and `catalog.html` — five pages, and the catalog's
`.imp-*` and `.cat-*` blocks are a substantial fraction of its 851 lines. A reader
trusting the comment will not think to check the catalog when changing a shared class,
which is how F15's `cols-5` came to be dead.

**Proposal:** correct the comment to name all five pages. Documentation only.

---

### F26 — low — One draft per person means you cannot park a build and start another

**Step 3 (flow).** Screenshot evidence: yes, the resume-draft prompt.

`character_drafts` is `UNIQUE (owner_email)` — one draft per person by design, and
`docs/wizard-and-sheet.md` argues that case well. The interface consequence is not
stated anywhere: starting a second character while one is unfinished offers only
**Resume this build** or **Discard and start fresh**. There is no "keep this one and
start another". Combined with F13's unconfirmed discard, the path from "I want to try a
different class" to "my rolled attributes are gone" is two clicks with no warning.

This surfaced as a real constraint during this audit: holding an abandoned draft made
it impossible to also build a second character without destroying it.

**Proposal:** documentation only — say so on the prompt itself, one line under the two
buttons: *"There is one draft at a time; starting fresh discards this build."* Making
drafts multiple is a schema change and a much larger decision.

---

### F27 — low — Back-link depth differs on all five pages

**Step 4 (cross-page shell).** Screenshot evidence: yes, all five headers.

| page | `header-right` contents |
|---|---|
| `index.html` | `← workshop` |
| `dashboard.html` | `← character creator`, `← workshop` |
| `catalog.html` | `← character creator`, `← workshop` |
| `campaign.html` | `← dashboard`, `← character creator`, `← workshop` |
| `sheet.html` | `▶ Play` (btn), `🖨 Print / Save as PDF` (btn), `← character creator`, `← workshop` |

Four different shapes across five pages. `sheet.html` is the only one mixing `<button>`
and `<a class="home-link">` in one row, and at 390×844 that row wraps into an
interleaved stack where "Print / Save as PDF" breaks one word per line — measured 132px
tall, 16% of the viewport (nothing is clipped; it is ugly rather than broken).

Also: `campaign.html:21` ships `href="/apps/character-creator/dashboard.html"` with no
`campaign_id` and patches it at runtime (`campaign.js:37`). If the script does not run,
the link lands on the *No campaign_id* error page.

**Proposal:** separate the buttons from the links in `sheet.html`'s header with a
divider or a gap so the two groups do not interleave when they wrap, and give
`campaign.html`'s dashboard link a static `href` that does not depend on JS. Normalising
the back-link ladder across all five pages is a **separate** decision — the current
depths are arguably each correct for their page.

---

## Verified clean

Screens and behaviours looked at hard, at the viewports named, where nothing was found.
Recorded so they are not re-audited from scratch.

- **The sheet's tab bar is above the fold at all three viewports.** The regression
  `docs/wizard-and-sheet.md` describes — tab bar below the fold behind a screenful of
  blank bio fields — has **not** returned: y=352 of 844 (phone), y=321 of 1180
  (tablet), visible without scrolling at 1440×900. The identity block above it is six
  compact rows, not the 467px of blank fields the doc describes fixing.
- **`.tabbar` is `position: sticky; top: 0; z-index: 20`** and each `.tab` sets
  `min-height: 44px`. Touch sizing and stickiness are right; only the horizontal
  overflow (F7) is not.
- **The fixed play-mode roll bar does not cover content.** `#play-roll-bar` is
  `position: fixed`, 45px; `.play-view` carries `padding-bottom: 72px` and `.wrap` 60px.
  Checked at maximum scroll at 390×844. I expected this to be a bug and it is not.
- **Play mode at 390×844** is the best-realised surface in the app: large pool steppers,
  a 1/5/10/20 damage amount selector, round/attack tracker, collapsible sections, undo,
  and no horizontal overflow.
- **The four documented gated steps gate correctly, with a reason.** Attributes,
  Occupation and Equipment each render `.nav-why` between Back and a disabled primary,
  and the reason updates live — resolving the robe choice on step 6 moved the text from
  *"Still to choose: robe or hooded cloak, weapon of choice."* to *"Still to choose:
  weapon of choice."* `shared/styles.css` dims `:disabled` to opacity 0.45 with
  `cursor: not-allowed`, confirmed computed.
- **The skill pickers match their documentation.** Live counts (`221 of 221`,
  `345 of 345`, `2 of 345` for "astronomy"), focus and caret retained across the
  re-render, and a genuine zero state — *"Nothing matches that filter."*
- **Hash-linked sheet tabs work.** `sheet.html?id=1#gear` and `#skills` and `#powers`
  each open on the named tab, and the tab bar auto-scrolls the active tab into view.
- **Going back through the wizard loses nothing.** Name, campaign and alignment
  survived a round trip from step 10 back to step 3 and forward through six steps.
- **The Skills tab on the sheet does not clip at 390px** — all three boxes report
  `clips: false`. F1 is specific to Gear's `<table>`.
- **Body horizontal overflow is zero at every viewport on every screen tested**
  (`documentElement.scrollWidth === innerWidth` at 390, 820 and 1440). The only
  overflow in the app is contained (F1's clip, F7's scrolling tab strip).
- **The Powers tab** groups spells by level with P.P.E. cost and a per-spell `⚡ use`
  action; clean at 1440×900.
- **The campaign audit panel on `catalog.html`** is well-written and correctly placed
  above the catalog tabs, as `docs/wizard-and-sheet.md` specifies — read-only, splits
  *would be refused* from *worth a look*, and states its own approximation honestly.
- **Empty states exist and say what to do** on the campaign journal (*"No journal
  entries yet."*), the People tab, the Occupation step (*"Elf grants no related or
  secondary skills of its own…"*), and `dashboard.html` without a `campaign_id`.
- **The resume-draft prompt explains what it is resuming** — character name, class,
  step number and name, and last-saved time — which is exactly what the doc argues for.
  Its only problem is F13.
- **The saved-character confirmation** summarises attributes, pools, skills, powers and
  inventory and offers both *Open full sheet* and *Create another character*.

---

## Blockages

Recorded rather than worked around or guessed at.

1. **No print preview could be rendered.** The Browser pane exposes no print-media
   emulation, and `window.print()` opens a blocking dialog. **F17 is therefore derived
   from reading the five `@media print` blocks and the live DOM, not from a rendered
   page**, and says so in the finding. Everything else in this menu that touches print
   is a CSS fact rather than an observation. Re-run F17 against a real preview before
   taking it.

2. **Screenshots were taken but could not be persisted to the scratchpad.** Every
   screenshot referenced above was taken live in-session through the Browser pane at
   the viewport stated, and the findings were written from them — but the tool returns
   images inline and offers no path to write them to disk, so there are no file paths
   to cite. Findings are marked *screenshot evidence: yes* where a rendered view backed
   the claim and *none* where the evidence is DOM measurement or source reading, which
   is the distinction that matters for re-checking them.

3. **The Browser pane's compositor returned blank frames after scrolling on tall
   pages** (the 11k–26k px Race and Skills steps), recovering only on navigation. This
   is a tooling fault, not an app defect, and **no finding in this menu rests on a blank
   screenshot**. Where it interfered, measurements were taken from the DOM and the
   screen was re-reached by direct URL.

4. **No Rifts character was saved.** The Rifts path was audited through system, race
   (120 cards, both modes), and attributes-with-class-minimums — but F26's one-draft-
   per-person constraint means holding the required abandoned draft and building a
   second character are mutually exclusive. The saved character is Palladium Fantasy.
   Consequence: the sheet was not audited with M.D.C. pools or psionics, and the
   level-up, staged-class and MOS surfaces in `docs/leveling.md` were not reached at all.

5. **Local D1 was stale and was replaced.** The `.wrangler/state` database held 157
   classes / 298 skills / 96 psionic powers against the repo's 160 / 345 / 116, so a
   fresh build from `scripts/rebuild-local.mjs` (360 files, 0 failures) was swapped in
   to avoid manufacturing findings out of missing catalog rows. The original was copied
   to the session scratchpad first, but **its WAL was not preserved**, so any uncommitted
   dev state in it is gone. It held 0 characters, 0 campaigns and 1 draft, so the loss is
   nil in practice — recorded because it was a write to the user's environment.

---

## Numbers in this document

Per the repo's audit convention, each is dated and sourced. All were counted against
the working tree or measured in the running app on **2026-08-31**, and independently
re-derived rather than quoted from the brief.

| Number | Source |
|---|---|
| 851 / 160 lines | `wc -l` on the two stylesheets |
| 15 `@media` blocks, 6 distinct max-widths, 1 min-width, 5 print blocks | `grep -n "@media" apps/character-creator/styles.css` |
| 120 class cards (42 R.C.C. + 78 O.C.C.) | live DOM, Rifts race step |
| 11,027 / 26,714 / 12,206 px | `document.documentElement.scrollHeight` at the stated viewport |
| 610 checkboxes, 345 / 221 picker rows | live DOM, wizard step 5 |
| 345 catalog rows, 12,915px | live DOM, `catalog.html` |
| 16 `.panel-inset` uses, 0 definitions | `grep -roh` across `*.js`, `grep` across all `*.css` |
| 6 non-focusable click targets | multiline `grep` **plus** a read of `app.js:535–543`, which the grep misses |
| contrast ratios | computed from `shared/styles.css:8–30` with the WCAG relative-luminance formula |
| 157→160 classes, 298→345 skills, 96→116 psionic powers | `node:sqlite` against the old and rebuilt local D1 |

Catalog counts here describe the **local** database rebuilt from the repo on this date.
They are not production numbers and nothing in this menu depends on them.
