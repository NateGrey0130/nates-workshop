# UI-AUDIT.md — Character Creator interface

> **No numbered finding on this menu is open, as of 2026-09-10.** A finding's
> state is its outcome note, directly under its proposal; the headings carry only
> severity. Checked 2026-09-10, after PR #931, by matching every `### F` heading
> in this file to the `**Taken` or `**Closed` note beneath it. **The findings
> filed after the original run sit under their own dated `##` headings at the end
> of the file**, after `F30`, and they run in filing order rather than in severity
> order. This line deliberately neither names nor counts those headings — it
> named exactly one until 2026-09-09, by which time there were three, which is
> the same trap the paragraph below describes one level down.
>
> **Three remarks were left open inside closed findings, and none was ever given
> a number**, which is why this line does not say "nothing is open": `F2`'s note
> leaves reconciling its behaviours (1) and (2) unstarted, `F6`'s leaves
> `--border` untouched, and `F17`'s leaves its print-ink observation standing.
> Each needs filing as a finding of its own before it can be taken.
>
> *(Until 2026-09-06 this paragraph read "Nothing is open" and named a closed
> range plus `F30`. That was true from 2026-09-03 until two findings were filed
> beneath it, and the PR that filed them did not update this line — which is the
> failure `META-AUDIT` `A16` and `A17` are both about, occurring in the menu they
> were filed on. `F30` was taken 2026-09-03, PR #657, filed 2026-09-02 from
> outside the audit run while verifying `BOOK-INGEST-AUDIT` `F18` on
> production. It then read *"There is open work on this menu"* until
> 2026-09-10, when PR #931 took the last open finding and did not update it
> either; this line was corrected in a separate PR the same day.)*
>
> **The one that misreads:** `F17` closes as **moot** rather than taken — it was
> checked against a real print render (PR #459) and the defect was not there.
> Seven of this file's proposals turned out to be wrong rather than merely
> stale, which is worth knowing before implementing one from its text alone.

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

**Taken, 2026-08-31 (PR #443).** Implemented as written. The three questions and
`quizScore()` are untouched; the ranking and the `match N/6` badges render exactly
as before. Classes scoring zero move into a closed `<details>` — *"Show the N that
match nothing"* — rather than being dropped, because the guided mode is a
suggestion and hiding a class outright would make it a filter.

**The 0/6 count is answer-dependent, so the finding's 38 is one reading of many.**
Measured on Rifts with *occupation / mystic / high-tech*: 98 score above zero and
**22** score zero. On Palladium Fantasy with *race / melee / grit*: 20 and 20.
The shape of the complaint holds at every combination tried; only the number moves.

Same answers, before and after (Rifts, 1440×900):

| | before | after |
|---|---|---|
| cards on the page | 120 | 98 + 22 collapsed |
| page height | 12,276px | **10,194px** |
| vs *Browse all* (11,027px) | longer | **shorter** |

**An asymmetry this opens, recorded and NOT taken:** F3 gave *Browse all* a filter
box; the guided shortlist has none, so its 98 remaining cards are still an
unfiltered scroll. Whether the filter belongs over a ranked list is a question
about what guided mode is for, and it is a finding of its own rather than
something to fold in here.

Evidence is DOM-measured. **Correction to this file's own blockage note:** the
pane's blank frames are not about page height — a 2,506px page came back blank
too. They happen whenever the page is **scrolled**; every screenshot taken at
`scrollY: 0` in this session rendered, at page heights up to 11,052px.

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

**Partly taken, 2026-08-31 (PR #445) — the `.pick` cards only.** Split into two PRs
by the finding's own instruction to ship those first and alone. **F5 stays open**
for the stepper (`app.js:543`), the NPC row (`campaign.js:321`) and the 345
catalog rows (`catalog.js:301`).

All six sites were re-checked and all six are real. One thing the finding did not
mention: **`.pick` is already rendered as a `<button>`** by the MOS picker
(`app.js:1987`), inside `.pickgrid`. That is why the new layout rules are scoped
`.grid > button.pick` — the MOS cards are not part of this change and must not
move under it. (`.pickgrid` itself is used in `app.js` and defined in no
stylesheet in the repo — a second instance of F10's pattern, recorded here, not
taken.)

Verified: all 40 Palladium Fantasy class cards and both system cards report
`tagName BUTTON` and `tabIndex 0`; text stays left-aligned at 16px in
`--text-primary` with the 15px `h4`, so the card is visually unchanged.

**The focus ring appears to be white for its first 200ms**, and that is `.pick`'s
own `transition: all var(--transition)` animating `outline-color` from
`currentColor`. Settled state measured repeatedly at
`rgb(240, 160, 75) @ 2px` — F16's ring. A screenshot taken during the transition
shows a white ring and is not evidence of a broken rule.

**Enter activation could not be demonstrated in the pane, and the pane is the
reason.** Control experiment on a button this PR never touched — the
*Help me choose* toggle: `Tab` focuses it, the pane's `Enter` does nothing, and
`.click()` on a converted card does advance the wizard from step 1 to step 2. The
pane's `key` action moves focus but does not synthesize activation. Enter and
Space on a real `<button>` are a platform guarantee, not app code.

**Recorded, not taken — the accessible name is now the whole card.** A converted
class card announces as *"Changeling rccPalladium Fantasy RPG Main Book
p.308-310pairs with an O.C.C. …"*, because a `<button>` flattens its contents
into its name. That is more than the nothing a `<div onclick>` offered, but a
button named after its own lore blurb wants either an `aria-label` or the
card-link pattern (a focusable title inside a plain card). Related: `<p>` inside
`<button>` is outside the HTML content model — browsers nest it without
complaint, and it is what makes the name long. Both belong to one follow-up
finding rather than to this PR.

**Closed, 2026-08-31 (PR #446) — the remaining three sites.** F5 is now fully
taken.

- **The stepper** (`app.js:543`). A *completed* step is a `<button>`; the current
  one, the future ones and the `.na` ones stay spans. Only completed steps go
  anywhere, and a focusable control that does nothing when pressed is worse than
  plain text. Measured: every pill is 24px tall and buttons share their row's
  `top` with the spans beside them, which is what `.stepper button.st {
  line-height: inherit }` is for — a button's own line-height sat the pill off
  the line.
- **The NPC row** (`campaign.js:321`). Now a `<button>`; `button.chkrow` strips
  the chrome a button arrives with. Deliberately **not** `font: inherit`, which
  would also overwrite `.chkrow`'s own 13px. Everything else wearing `.chkrow` is
  a `<label>` around a checkbox and is already focusable, so nothing else moves.
  Measured: both rows `BUTTON`, `tabIndex 0`, full width, left-aligned, 13px,
  `--text-primary`, transparent.
- **The catalog rows** (`catalog.js:301`). These got `role="button"` +
  `tabindex="0"` + a keydown handler rather than a `<button>`, exactly as the
  finding proposed — the row opens into a **form in place**, and a form inside a
  button is not a thing. All **345** rows carry the role and the tab stop;
  `Enter` and `Space` both open the row's form, and Space is
  `preventDefault()`ed so it does not scroll the list out from under the row it
  just opened.

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

**Taken, 2026-08-31 (PR #451), with a scope Nate chose over the one proposed
here.** `--text-muted: #81889e` overrides the token in
`apps/character-creator/styles.css`'s own `:root`. `shared/styles.css` is
**untouched**, so `filament-forge`, `media-vault` and `pick3cut5` are unchanged
and needed no screenshot pass. `--border` was not touched and stays open.

**The ratios in this finding are right — I recomputed all twenty from the token
values and they match to the second decimal.** Two things around them are not:

- **The suggested value does not do what it says.** `#7b8296` reaches **4.13**
  on `--bg-input`, not 4.5. Nothing clears `--bg-input` short of `#8b92a8` —
  which *is* `--text-secondary`. Written as proposed, this finding ends with the
  muted tier deleted rather than fixed.
- **`--bg-input` carries no muted text, and neither does `--bg-tertiary`.**
  Every element whose computed colour is the muted token, across all five pages,
  sits on one of three opaque backgrounds — `--bg-primary`, `--bg-secondary`,
  `--bg-card` — plus **one** translucent case. So the background the proposal
  optimised for is the one the app never uses.

`#81889e` clears 4.5:1 on all three real backgrounds (5.45 / 5.08 / 4.93) and on
`--bg-tertiary` (4.64) so a future muted label on a tag still passes. It leaves
`--bg-input` at 4.40 — no muted text is there, and closing that last 0.1 costs
the tier its identity: muted and secondary are already only 1.14:1 apart at this
value, and 1.07:1 at the value `--bg-input` would demand.

**The one translucent case got its own line rather than the token.**
`.imp-tab.on .imp-tab-sub` — the selected catalog tab's sub-label — sits on
`--accent-glow` blended with `--bg-secondary`, which is `#27243e`, lighter than
any opaque background in the system. Muted reaches only 4.22 there, so that one
sub-label uses `--text-secondary` (4.81).

Measured live, per page, by walking every text node and computing its ratio
against its effective background — sheet **97 → 1**, dashboard **7 → 1**,
catalog **7 → 2**, campaign **2 → 1**, wizard step 1 **11 → 0**, step 2
**13 → 1**, step 3 **15 → 1**. **152 failures → 7**, and none of the seven is
`--text-muted`: five are white on `--accent` in `.btn-primary` (3.11, see
**F28**, two of them on a disabled button and therefore exempt) and two are the
`.dupe-badge` (3.25, see the note under **F20**).

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

**Taken, 2026-09-01 (PR #455). Warn, do not block — posture said back
deliberately.** The Review step now carries an `.advisory` line naming every
choice group still short; the primary button stays live and the Skills step's
own gating is untouched. The save still succeeds.

Premises verified on a Body Fixer draft: three groups at *Pick 2 — 0/2*,
*Pick 1 — 0/1* and *Pick 1 Pilot — 0/1*, the primary button reading
`Equipment →` and **enabled**, and no `.nav-why` anywhere.

**One correction, and it is about the wording the finding asks for.** The
proposal says to reuse the audit endpoint's own phrasing. That phrasing ends
`— approximate`, and the hedge is real *there*: `validate-character.js` works
backwards from a saved skill list, where a group pick is indistinguishable
from a skill the class granted by name. **On the Review step nothing has been
flattened yet.** `S.groupPicks` is what the Skills step's pickers write, keyed
by group, so the count is exact and the same one the player watched count up.
Copying the hedge would have shipped a sentence that is false in this context.
What renders instead:

> **Still to pick on the Skills step:** 0/2 from Language: Other; 0/1 from
> Athletics (general) / Body Building & Weight Lifting; 0/1 from Pilot. You can
> save without them — the class simply grants fewer skills than it offers.

Both halves confirmed live: with the three groups unfinished the advisory
renders under the alignment line and `💾 Save character` is live; with all
three filled it disappears entirely.

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

**Taken, 2026-09-01 (PR #457). Display only, as the finding scopes it.** Each
campaign on step 1 now sits on its own line and says how many characters it
holds and when it was made:

> 🗺 **The Northern Wilds** (palladium-fantasy) · 0 characters · 31 Aug
> 🗺 **The Northern Wilds** (palladium-fantasy) · 1 character · 31 Aug

Which is the finding's own two rows, reproduced live from the same pair of
campaigns it was written against — and now telling you which one holds the
character. No delete control was added and the create-before-validate ordering
is untouched.

**It needed the endpoint, which the finding does not mention.**
`GET /campaigns` returned `id, name, system, gm_email, open` and nothing else,
so neither half of the proposal was available on the client. It now also selects
`created_at` and a correlated `count(*)` of that campaign's characters. Both are
read-only and neither is new information — the campaign list is already visible
to any signed-in user, and the Review step's picker already shows GM emails.

**The date is parsed by hand rather than through `Date`.** `created_at` is
stored as UTC with a space and no `Z`, which `Date` reads as local time and can
shift by a day. `shortDate()` also keeps the year once it has turned — a bare
day-and-month is unambiguous only inside one year, and a campaign list is
exactly where old rows accumulate. Checked against `2026-08-31 21:17:28` → *31
Aug*, `2025-01-05` → *5 Jan 2025*, and empty / malformed / month 13 → dropped
rather than rendered.

**One entry per line rather than the old inline run.** Separated by `·` on one
line, as it was, two campaigns of the same name are a single string — which is
how the finding's screenshot came to look like one campaign listed twice.

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

**Taken, 2026-08-31 (PR #452).** Both numbers hold: 16 uses (12 in `app.js`, 4 in
`campaign.js`), 0 definitions anywhere in the repo. One rule added to
`apps/character-creator/styles.css` exactly as proposed — `--bg-secondary`, a 1px
`--border`, `--radius-sm`, `10px 12px`, `10px 0`.

Screenshotted before and after on the Race step at 1200×2200 (the pane cannot
screenshot a scrolled page, so the viewport was made tall enough to hold the
whole step). The difference is the one the finding predicted: *What Body Fixer
grants* and *Starting level* previously ran flush into six paragraphs of class
description with nothing marking where the class blurb ended and the mechanics
began. `#starting-level` nests inside `#race-briefing`, so that pair renders as
an inset within an inset — checked deliberately, and it reads as intended
rather than as an accident.

Not screenshotted individually: the ten uses reached only through the level-up
flow and the shortfall panel. They are the same single rule on the same kind of
nested block, and the computed values were confirmed on the two that were seen
(`rgb(18, 21, 28)`, `1px rgb(42, 47, 62)`, `10px 12px`, `6px`).

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

**Taken, 2026-09-01 (PR #454).** The table is accurate — three components,
three visual languages, three counting conventions. `campaign.js`'s
four-panel `.toggle` is now the sheet's `.tabbar`, reused rather than
re-styled: 44px targets, the `.tab-n` count pill, and `role="tablist"` /
`role="tab"` / `aria-selected` it never had.

**It had to move out of the `.panel`.** `.tabbar` is `position: sticky` and
paints itself in `--bg-primary`; inside a card it smears the wrong colour
down the page on scroll. The sheet's is a top-level `<nav>` beside its
panels, and the campaign's is now too — so the panel holds the campaign name
alone.

**One convention borrowed with the component:** the sheet suppresses a zero
count rather than showing `0`, so *Party stash* and *Currency* carry no pill
on an empty campaign where the old toggle read `Party stash (0)`.

Measured after, `campaign.html`: four `role="tab"` buttons at 44px inside a
`role="tablist"`, `aria-selected` tracking the panel, and at 390px the bar
wraps to two rows with no horizontal overflow — inheriting F7's rule, which
was written for the sheet.

`catalog.js`'s `.imp-tabs` left alone as instructed, and the wizard's genuine
two-state `.toggle` untouched. `.toggle`'s CSS stays: the wizard still uses it.

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

**Taken, 2026-08-31 (PR #448).** Scope as written: the Details step only. The
attribute-method selects and the Review step's *Character name* and *Campaign*
fields are untouched and stay open.

**`kvRow()` does not exist, and the fix lands in ONE place.** Every row on this
step comes from a single function, `bioInput()`. The `.kv-row` class the name
suggests belongs to the **admin catalog editor** (`catalog.js:137`, a local
`row(k, val)` arrow) — a different page, not this step. Nothing was skipped by
there being one function instead of two.

The id is derived from the field key, which is a fixed slug in `BIO_FIELDS`
(`bio-race`, `bio-true_name`, …), so two rows cannot collide and no id has to be
tracked by hand. Measured on the live step: **17 controls, 17 unique ids, 17
associated labels**, and the accessibility tree now reads back
`textbox "Race"`, `textbox "True Name"`, `textbox "Native Language(s)"`,
`textbox "Gold"` and the rest by name, where every one of them was anonymous
before.

**One claim in this finding was a misreading of the tool, not a defect.** The
`checkbox "on"` cited above is the *long-lived race (×2)* option, and it was
already correctly labelled — it is **wrapped** in its `<label>`, the pattern this
same finding praises two paragraphs earlier, and reports `labels.length === 1`
with the name *"long-lived race (×2)"*. `read_page` prints a checkbox's **value**
and a select's **selected option** rather than its accessible name, which is why
it looked nameless and why the alignment select still prints as
`combobox "— choose —"` after this change. Both are named.

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

**Taken, 2026-09-01 (PR #455).** All of it holds — `app.js` had **zero**
`confirm()` calls against `sheet.js` 3, `campaign.js` 2 and `catalog.js` 2, and
the discard sat in the same `.nav` row as *Resume this build*.

`dismissDraft()` now confirms, in the `sheet.js` pattern: no new component, no
modal.

**The rolled attributes are named only when there are some.** A draft abandoned
on the Class step has nothing rolled, and warning about losing rolls that do
not exist is the kind of sentence that teaches people to click through. Both
branches exercised:

> Discard the Body Fixer build, including its rolled attributes? This cannot be undone.
> Discard the Body Fixer build? This cannot be undone.

Cancelling was confirmed to leave the draft standing. The two other
`discardDraft()` callers — the post-save cleanups at `app.js:3258` and `:3370` —
are untouched and stay silent, which is correct: discarding after a successful
save is not a decision.

**`discardDraft()`'s `catch { }` is unchanged.** The finding mentions it; the
proposal does not ask for it, and error handling is a separate call.

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

**Taken, 2026-09-01 (PR #454), after F5 and F11 as the finding instructs.**

Verified: the note body renders through `esc()` into
`<p class="small" style="white-space:pre-wrap">` with no links at all, while
the form directly above it promises `@Name` links someone to their dossier.
The dossier half was always true; the half on screen was not.

**Linked against `D.npcs` rather than by re-running the server's pattern.**
The client already holds every dossier in the campaign, id and name. A second
copy of `_lib/mentions.js`'s `MENTION` regex here would drift from the
original, and the failure mode of drift is a link to a dossier that does not
exist. **No dossier, no link, by construction.**

**One pass over an alternation sorted longest-first, never one pass per
name.** With an *Osric* and a *Brother Osric* on the roster, a second pass
would match inside the anchor the first pass had just written and nest a link
in a link. Names are HTML-escaped before they are regex-escaped, because the
body they are matched against has already been through `esc()`.

Behaviour checked case by case against a stubbed roster:

| body | roster | result |
|---|---|---|
| `@Brother Osric … @Osric` | both | two separate links, correct ids, no nesting |
| `@Osric` | *Brother Osric* only | **no link** — there is no dossier |
| `@Kevik,` `@Kevik.` `@Kevikson` | *Kevik* | first two link, `@Kevikson` does not |
| `@A.B` and `@AxB` | *A.B* | only the literal `A.B` links |
| `@D"Ante <b>` | that name | linked, and `<b>` still escaped |
| `@Tom & Jerry` | that name | linked, `&` still escaped |

**`openNpc()` needed one line the finding does not mention.** It set `D.npc`
and re-rendered, but `render()` picks the view from `D.tab` — reached from a
note, the dossier loaded and nothing on screen changed. It now sets
`D.tab = 'people'`. Confirmed live: clicking `@Halgi` inside a note moved
`aria-selected` to People and opened Halgi's dossier, with `location.hash`
still empty.

`.mention` is underlined as well as accent-coloured — a run of accent text
inside a paragraph of body text is not, on its own, an affordance. Measured
at 4.5:1+ on every page; `campaign.html` reports zero contrast failures at
390px.

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

**Taken, 2026-08-31 (PR #452), and it had a trap the finding did not see.**

Premises verified: `cols-4` is hardcoded at `catalog.js:179`, `CATALOG_KEYS` is
5 (`skills, spells, psionics, enchantments, gear`), and `cols-5` appears in zero
JS or HTML. **The line numbers have drifted** — the CSS block is 479–488, not
409–413, and `.cols` is 131, not 102.

Both proposed edits made: `cols-${CATALOG_KEYS.length}` in `catalog.js`, and the
900px rule extended to `.cols-4`.

**A third edit was needed and it is the reason this had to be screenshotted.**
Changing the class from `cols-4` to `cols-5` silently changed the *phone*
layout, because the 620px rule reads `.imp-tabs, .imp-tabs.cols-4` — and
`.imp-tabs.cols-5` (0,2,0) outranks the bare `.imp-tabs` (0,1,0) that was
supposed to catch it. At 390px the catalog went from one column to two. Taking
this finding exactly as written would have shipped that. `.cols-5` is now named
in the 620px rule as well.

Measured after, on `catalog.html`:

| viewport | columns | rows |
|---|---|---|
| 1440 | 5 | 1 — gear no longer orphaned |
| 820 | 3 | 2 — the tablet rule fires for the first time |
| 760 | 2 | 3 |
| 390 | 1 | 5 — unchanged from before |

The comment above the block claimed the two variants existed because the
catalog editor had four importers and the import page five. There is no import
page. It now says where the count comes from and that every breakpoint has to
name every variant.

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

**Taken, 2026-08-31 (PR #444).** Copied verbatim from `apps/pick3cut5/styles.css`,
into the app stylesheet only. `shared/styles.css` is untouched, so the other three
apps are unchanged. Line 84's `outline: none` + border change stays as the
pointer-and-typing affordance. `prefers-reduced-motion` was **not** taken — it is
a separate item and stays open. The `.sr-only` helper was not brought across
either: nothing in this app uses one yet, and copying an unused rule is how
`.cols-5` (F15) happened.

Verified with a real `Tab` keypress rather than a scripted `.focus()`, which
never sets `:focus-visible`: the Vitals tab reports `focus-visible: true` and
`outline: 3px solid rgb(240, 160, 75)` at `outline-offset: 2px`. That colour is
this app's `--accent-secondary` (`#f0a04b`), which its `:root` overrides — so the
ring reads orange here against the purple accent, where the same rule in
pick3cut5 renders in that app's colour. Screenshot at 1440×900.

This lands **before F5** deliberately: converting the wizard's `<div onclick>`
cards to real buttons puts focus somewhere that had no visible indicator until
this rule existed.

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

**Closed as moot, 2026-09-01 (PR #459) — which is what this finding asks for.**
It says: *"Verify against a real print preview first — if the preview shows
tables already behaving, close this as moot and record that."* They do.

**The blockage is broken.** Headless Chrome renders print media directly:

```
chrome --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=20000 --print-to-pdf=out.pdf <url>
```

No dialog, real `@media print`, real pagination. The sheet for character 1 came
out at 5 pages, and with 60 probe inventory rows and 70 probe skills added to
the local database it came out at 9 — long enough for both a table and a skills
list to cross a page boundary. Probe rows removed afterwards; the character is
back to its 23 items and 15 skills.

**What the render shows, against what this finding predicted:**

| | predicted | actual |
|---|---|---|
| equipment table splits | yes | yes — pages 6, 7, 8 |
| its header on the continuation pages | **absent** | **present** — pages 7 and 8 both open `ITEM QTY EQ NOTES` |
| skills list splits | yes | yes — pages 3, 4 |
| its header on the continuation page | absent | absent |

**So both proposed edits are no-ops.**

- `thead { display: table-header-group }` — `table-header-group` is already the
  browser default for `<thead>`, which is why the equipment header repeats with
  no rule at all. There is exactly **one** `<thead>` in `sheet.js` (line 1219),
  and it is that table.
- `table { break-inside: auto }` — `auto` is already the initial value, and the
  table demonstrably splits despite `.panel, .box { break-inside: avoid }`
  sitting above it.

**The real defect is a different one, and the render proved it.** It is
recorded below as **F29** rather than fixed here: the skills list is not a
`<table>` at all, so no `thead` rule can ever reach it.

**The ink observation stands and was not taken.** `.stepper .st`, `.lvl-row`,
`pre.snippet` and `.cat-row.open` still get no light background in the print
block. It was never part of the proposal, it only bites a reader who ticks
*Background graphics*, and three of those four selectors belong to the wizard
and catalog, which nobody prints.

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

**Taken, 2026-09-01 (PR #456).** Confirmed on the live page — the first skills
row read `Bonuses: {"attributes":{"PS":1,"PP":1,"PE":1},"combat":{…`, serialized
and truncated mid-object.

`summaryValue()` gained a `bonuses` case, so it now reads

> `Bonuses: PS +1 · PP +1 · PE +1 · roll +2`

**One premise correction.** The finding says to reuse the summary *the sheet*
already produces. The sheet does not produce one — nothing in `sheet.js`
formats a bonuses block for reading. The renderer that does is the wizard's
`raceBriefing()` (`app.js:808`), whose grouping and `+` handling this follows.
Not shared with it: that one emits `<span class="tag">` chrome for a panel and
this is plain text for a cell `summaryValue()` then truncates.

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

**Taken, 2026-08-31 (PR #450).** Both halves, in one edit, with the proposal's own
sentence: a Palladium Fantasy R.C.C. build at step 9 renders
*"Step 8 (Advancement) does not apply to this character."* under the pills, and
`aria-current="step"` lands on *9. Details*. The `title` stays for the pointer.

**More than one step can be skipped at once, which the finding's single-sentence
wording did not cover.** An O.C.C.-first build skips Occupation *and*
Advancement, so the line is built rather than hard-coded and agrees with itself:
Rifts → Body Fixer renders *"Steps 4 (Occupation) and 8 (Advancement) do not
apply to this character."* — plural noun, list, plural verb.

Verified at 1440×900 and at 390×844, which is the width the finding was about:
the line sits at y=227, 334px wide, centred under the stepper and fully legible
where the `title` could never be reached at all.

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

**Still open — but read this before taking it, added 2026-08-31 while measuring
F6.** The badge is `color: #fff` on that background, and the proposal as written
would make its contrast **worse, not better**:

| badge background | ratio against `#fff` |
|---|---|
| `#b8860b` — today's dead fallback | **3.25** (already under 4.5) |
| `--warning` `#fbbf24` — what this finding proposes | **1.67** |

Taking F20 as written ships white text on bright amber. The token swap is still
right; it needs the foreground to move with it — `#0a0c10` on `--warning` is
**11.72**. Both remaining contrast failures on `catalog.html` after F6 are this
badge.

---

**Taken, 2026-09-01 (PR #453), with the foreground moved as Nate chose.**

Every premise holds. `--warn` is defined in no stylesheet in the repo — the only
token is `--warning: #fbbf24` (`shared/styles.css:23`) — so `#b8860b` fired 100%
of the time. Both `#2e7d32` fallbacks are likewise unreachable, `--success`
being `#34d399`. **Line numbers have drifted**: the badge is 622, not 538, and
the two `--success` fallbacks are 603 and 608, not 519 and 524.

The regression warned about above is why this was not taken as written. Given
the four options, Nate took **swap the token and darken the text**:

| | background | text | ratio |
|---|---|---|---|
| before | `#b8860b` (dead fallback) | `#fff` | 3.25 |
| as the finding proposed | `--warning` `#fbbf24` | `#fff` | **1.67** |
| **shipped** | `--warning` `#fbbf24` | `#0a0c10` | **11.72** |

Rejected on the way: white with a border (1.67 at any border treatment), and
keeping the goldenrod under a new `--warn-deep` token (nothing moves visually,
but 3.25 survives).

Both dead `#2e7d32` fallbacks dropped. Measured live on `catalog.html`: both
badges — *Audit characters ①* and *Find duplicates ②* — read
`rgb(251, 191, 36)` on `rgb(10, 12, 16)` at **11.72**.

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

**Taken, 2026-09-01 (PR #456), and the proposal is half of the fix. The other
half is the container.**

The ragged alignment is real and was measured rather than eyeballed: **341
distinct column-x patterns across 345 skill rows**, 590 across 607 spells, 997
across 1,025 gear.

**Laying those columns out on a grid inside the existing container makes the
list TALLER.** `main.wrap` is `max-width: 900px` — right for four pages of
prose, forms and panels, and wrong for the fifth, which is a 345-row table. It
gives five columns 798px to share while 540 sit empty on a 1440 screen. Gridded
at 798px, skills went from 96% single-line rows to 45% and from 12,321px to
15,134. So `catalog.html` gets `wrap-wide` (1280px); the width is not a separate
wish, it is what makes the grid a fix rather than a trade.

**`.kv-row`'s grid vocabulary was not reused, and a fixed field list is not
possible.** `summaryFor()` picks the first four fields each ROW fills,
deliberately — measured 2026-09-01, skills has **3** distinct column shapes
across 345 rows but gear has **22** across 1,025. The finding's suggested
columns (name / category / base % / per level / source) serve skills and gut
gear. The labels therefore stay, and a slot aligns with the slot above it while
saying what it holds.

**The widths are measured at render time, not written into the stylesheet.** A
template hand-fitted to skills put 99% of its rows on one line and only 69% of
spells' — `System: palladium-fantasy` landing in a track sized for `Base %: 30`.
`fitColumns()` takes the 99th percentile of each column's rendered text across
the rows currently on screen and writes `--cat-cols`; the CSS carries the
skills-shaped guess only as the fallback before it lands. It re-fits on filter
and clears itself on the empty state — both confirmed.

**Gear and enchantments are excluded, on the measurements.** They key on a slug
rather than a name, and that extra column leaves too little for the rest:
fitted, gear goes from 98% single-line to **0%** and from 36,490px to 51,529.
They keep the flex row and take the width alone, which is most of the win there
anyway — gear was 45,336px at 900 and is 36,490 at 1280.

Where the grid does apply:

| catalog | x-patterns before → after | single-line | total height, flex → grid |
|---|---|---|---|
| skills | 341 → **2** | 99% | 12,074 → 12,134 |
| spells | 590 → **3** | 97% | 21,244 → 21,544 |
| psionic powers | 115 → **2** | 97% | 4,059 → 4,109 |

Alignment for a third of a percent of height. Below 900px the flex row is
unchanged and no horizontal overflow appears at 390.

**Pagination remains out of scope**, as the finding says.

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

**Taken, 2026-08-31 (PR #447).** Both renderers, `aria-label` and `title`, and the
buttons are **not** resized — still 32×24, as the finding required.

**One correction: not every `✕` was bare.** The enchantment remove button
(`sheet.js:1757`) already carried `title="Remove this enchantment"`, and a
`title` is an accessible name, so that one always had one. It is left alone. The
two that were genuinely nameless were the wizard's equipment table and the
sheet's inventory rows, and both are fixed.

**The label needed a second escape.** `escHtml()` builds its output through
`textContent`, which escapes `&`, `<` and `>` but leaves `"` alone — fine for
text, wrong inside an attribute, where a custom item name carrying a double quote
would have ended it early. The labels take one more pass, and the live proof is a
catalog row that happens to be named `"Rolling Thunder" All-Purpose Vehicle`: its
button's `aria-label` reads `Remove "Rolling Thunder" All-Purpose Vehicle`
intact, where without the pass the name would have been cut at `Remove `.

Measured on the audit character's Gear tab: 23 remove buttons, 23 distinct
labels, no duplicates. (The finding's 21 was the Equipment step's count for a
different build — both figures are content-dependent.)

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

**Taken, 2026-08-31 (PR #452).** `align-items: start` added to `.cols`.

The mechanism is confirmed rather than assumed — measured with the declaration
on and forced back off, on the Skills step at 1200 wide:

| state | Related column | Secondary column |
|---|---|---|
| unfiltered, `stretch` (before) | 8486px | 8486px |
| unfiltered, `start` (after) | 7816px | 8486px |
| Secondary filtered to nothing, `stretch` | 7816px | **7816px** |
| Secondary filtered to nothing, `start` | 7816px | **104px** |

The 5,606px in the finding was a different character's skill list; the defect
and the fix are the same. **One premise correction:** the finding says to check
the Review step, which also uses `.cols`. It does not — the second and only
other `.cols` is the **Details** step's two columns of bio fields
(`app.js:2830`), which has no stretch dependency either.

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

**Taken, 2026-08-31 (PR #449).** Five one-line edits, and the visual claim holds:
`shared/styles.css` opens with `* { margin: 0; padding: 0 }` and `.logo` sets its
own `font-size: 22px` and `font-weight: 800`, so an `<h1>` inherits neither the
UA margin nor the UA size. Measured on the sheet before and after: 22px, weight
800, `margin: 0px`, 161×28 at y=16 — identical.

Every one of the five pages now reports exactly **one** `h1`.

**The level skips are NOT fixed, as scoped.** Three pages are now clean from the
top (`wizard H1→H2`, `campaign H1→H2→H3`, `dashboard H1→H2→H3`); **two still
skip** — the sheet runs `H1→H3` because `sheet.js` contains no `h2`, and the
catalog runs `H1→H4` because `catalog.js` has only `h4`. That is the separate
finding this one names, and it is still open.

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

**Taken, 2026-08-31 (PR #452).** The comment now names all five pages and says
the thing the finding was actually about — that the catalog's `.imp-*` and
`.cat-*` blocks are a large part of this file, so a class that looks
wizard-only probably is not. Which is exactly how F15's phone-width trap was
built.

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

**Taken, 2026-09-01 (PR #455). Documentation only, as proposed.** One line
under the two buttons:

> There is one draft at a time, so there is no third option here: starting fresh
> discards this build.

The `UNIQUE (owner_email)` constraint and the argument in
`docs/wizard-and-sheet.md` are untouched. Shipped alongside F13, so the two
halves of this prompt's problem — that it does not say what it will destroy, and
that it does not say why there is no third button — are fixed in one place.

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

**Taken, 2026-09-01 (PR #458) — the first half. The second half is moot, and
that is recorded rather than worked around.**

The table is accurate and the 132px is exact: measured again at 390×844,
`sheet.html`'s header was **132px, 16% of the viewport**.

**But it was not wrapping.** `shared/styles.css:67` sets `.header-right` to
`display: flex` with no `flex-wrap`, so the four controls stayed on one row and
the *text inside them* broke instead. Measured tops and heights:

| control | top | height |
|---|---|---|
| ▶ Play | 46 | 39 |
| 🖨 Print / Save as PDF | 16 | **99** — one word per line |
| ← character creator | 40 | 51 — two lines |
| ← workshop | 49 | 34 |

Four controls, four different heights, four different starting offsets. The
finding calls it interleaving, which is what it looks like; the mechanism is
that nothing wrapped at all.

So: `white-space: nowrap` on the controls and `flex-wrap` on the row, which
swaps the behaviour round — a control that does not fit moves to the next line
*whole*. `.header-group` wraps each of `sheet.html`'s two pairs so the buttons
cannot interleave with the links, which is the divider the finding asks for.
`.header` wraps too, or `.header-right` has nowhere to go: `space-between` on a
nowrap parent squeezes it against the logo instead of moving it down.

**Wrapping alone fixed the raggedness and not the height** — three tidy rows
came to 134px, where four squeezed ones had been 132. The 28px/16px padding is
sized for a one-row desktop header, so it drops to 16px/10px below 620px.
Measured at 390×844, after:

| page | before | after |
|---|---|---|
| sheet | 132px, 16% | **122px, 14%** |
| campaign | ragged, 3 links across 2 lines | **88px, 10%**, all three on one line |
| dashboard, catalog | — | 88px |
| wizard | — | 65px |

Nothing moves at 820 or 1440: the header measures **77px on both, before and
after**, checked by stashing the change and re-measuring. The sheet's tab bar
stays above the fold at 390 (y=342, was 352), which *Verified clean* pins.

**The `campaign.html` half is closed as moot.** The finding says a static
`href` is needed because "if the script does not run, the link lands on the *No
campaign_id* error page". Two things:

- **Without JS there is no campaign page at all.** `campaign.html`'s entire
  body is `<div id="app"><p class="muted">Loading campaign…</p></div>`;
  `campaign.js` renders everything into it. A visitor with JS off sees
  *Loading campaign…* forever, and the back link's `href` is not the problem
  they have.
- **The destination is not an error page.** `dashboard.js:135` without an id
  renders *"No campaign_id — open a dashboard from the Character Creator
  landing page."* — a written empty state that says what to do, which this
  audit's own *Verified clean* section already credits.

A static `href` that actually reaches the right dashboard needs the
`campaign_id`, which exists only in the URL at runtime — so the only available
change is pointing it somewhere worse. Left alone.

**Normalising the back-link ladder across the five pages remains a separate
decision**, as the finding says.

---

### F28 — medium — White on `--accent` is 3.11:1, and it is every primary button

**Added 2026-08-31**, not by the original pass — it is what was left standing when
F6 cleared the muted text out of the way, and it is now the most common contrast
failure in the app.

`.btn-primary` is `color: #fff` on `--accent` `#9d7cff`. Measured **3.11:1** at
13px, against a 4.5 requirement. It is the *Save*, *Post note*, *Save GM notes*,
*Confirm and roll →*, *Skills →*, *Review →* button — the primary action of every
screen that has one. Two of the seven instances found were on a **disabled**
button (`opacity: 0.45`), which WCAG exempts; the rest are live controls.

This is `--accent`, which the character creator overrides in its own `:root`
(`#9d7cff`, where shared ships `#4f8eff`) — so like F6 it can be fixed app-local,
and unlike F6 it cannot be fixed by moving the text colour alone: white is
already the lightest end.

**Proposal:** darken the button only — an `--accent-strong` behind
`.btn-primary`, leaving `--accent` itself alone so every border, link and focus
ring keeps its current tone. Values computed against white: `#7c5cfc` (shared's
`--accent-secondary`) is **4.38** and still short; `#6b4bd8` is **5.80** and
clears. **Do not** darken `--accent` globally — it is the link colour and the
focus-ring colour and both want the brighter tone. Screenshot every page with a
primary button.

Out of scope here and worth someone's attention: shared's own `--accent`
`#4f8eff` is **3.16** against white, so the other three apps have this too.

---

**Taken, 2026-09-01 (PR #453), app-local, exactly as proposed.**

Unusually for this menu, **every number in this finding is right**, recomputed
from the token values: `#9d7cff` 3.11, `#7c5cfc` 4.38, `#6b4bd8` 5.80, and
shared's `#4f8eff` 3.16.

`--accent-strong: #6b4bd8` added to the app's own `:root` and used by
`.btn-primary` alone. `--accent` is untouched, so every link, border and focus
ring keeps the brighter tone, exactly as the proposal insisted.

**The disabled-hover pair had to be repeated.** `shared/styles.css:125` pins
`.btn-primary:disabled:hover` back to `--accent` **by name** at (0,3,0)
specificity; without repeating it here, hovering a *dead* primary button would
have lit it brighter than the live one. That rule is not mentioned in the
finding and is the only thing in it that needed more than the token.

Measured live, all five pages, walking every text node and compositing every
translucent layer down to opaque before computing the ratio:

| page | failures after F6 | after this |
|---|---|---|
| wizard | 1 | **0** |
| sheet | 1 | **0** |
| dashboard | 1 | **0** |
| catalog | 2 | **0** |
| campaign | 1 | **0** |

**The app now measures zero contrast failures on every page**, from 152 before
F6. Screenshotted at 1440×900; the primary button is visibly deeper and still
reads as the primary.

**Recorded, not fixed — one thing found while measuring.** `shared/styles.css:101`
is `.btn:hover { background: var(--bg-input) }` at (0,2,0), which outranks
`.btn-primary` at (0,1,0). So hovering a live primary button turns it grey
rather than darkening it, in all four apps. No contrast failure results — white
on `--bg-input` is comfortable — but it is not what either rule intends, and it
is outside this finding's scope.

Shared's own `--accent` `#4f8eff` at 3.16 remains out of scope and unfixed, as
the finding says.

---

### F29 — low — The skills list is a div wearing a table's clothes, and its header cannot repeat in print

**Added 2026-09-01**, not by the original pass — it is what the print render
done for F17 turned up once a real preview could finally be produced.

`sheet.js:856` renders the skills list as

```html
<div class="skill-head"><span>Skill</span><span>+%/Lvl</span><span>%</span></div>
```

followed by `.skill-row` divs. It reads as a table with a header row and is
not one, so `display: table-header-group` — the mechanism that makes a header
repeat across printed pages — has nothing to attach to.

Proved rather than reasoned: with 70 probe skills added locally, the printed
Class Skills list ran from page 3 onto page 4, and page 4 begins at
*Print probe skill 36* with no `SKILL +%/LVL %` above it. The equipment table
on pages 7 and 8 of the same document repeats its header correctly, because it
is a real `<table>` with a real `<thead>`.

**How often this bites is the open question, and it is not "never".** Aelric's
15 skills fit comfortably; a high-level character with a full related and
secondary list plus a Military Occupational Specialty would not. The probe was
70 skills, which is more than any real character has today.

**Proposal:** make the three skills lists real tables — `<table>` with a
`<thead>` carrying the same three cells — so the header repeats for free, as
the equipment table's already does. `.skill-head` and `.skill-row` keep their
class names and most of their CSS; the grid becomes `table-layout: fixed`.
Screenshot all three skill boxes at 390, 820 and 1440 because the layout
primitive changes underneath them, and re-render the print PDF to confirm the
header repeats. **Alternatively close it**: the counter-argument is that a
character long enough to trigger this may not exist yet, and the div layout is
doing its job on screen.

---

**Taken, 2026-09-01 (PR #460), as written.** All three skills lists are real
`<table>`s with real `<thead>`s. Every premise checked out — one renderer
(`sheet.js:855`) called three times at 1203–1205, line 856 exact, and exactly
one pre-existing `<thead>` in the file.

**Proved the same way the finding was**: the same character, the same 70 probe
skills, the same headless render, before and after.

| page 4 opens with | |
|---|---|
| before | `Print probe skill 36…` — no header |
| after | **`SKILL +%/LVL %`** then `Print probe skill 39…` |

**The note row is the part the proposal understates.** `.skill-row .note` was
`grid-column: 1 / -1` — a second line spanning the full width *inside the same
grid item's container*. A table row cannot hold a cell that wraps underneath its
siblings, so a noted skill now emits **two** `<tr>`s, the second with
`colspan="3"`. That moves the dotted rule: it has to sit under whichever of the
pair is last, or it cuts between a skill and its own footnote.
`.skill-row:has(+ .skill-note) > td { border-bottom: 0 }` handles it, and
`break-after: avoid` on the same selector keeps the pair together across a page
break. Exercised deliberately — no skill on any character carries a `note`
today, so three were given one locally and removed afterwards.

**The global `td, th` rule had to be undone rather than inherited.** It is 13px
with `7px 10px` of padding and a solid border on every cell, written for the
equipment and level tables; a skills list at those numbers is half again as
tall. `.skill-table`'s own rules are more specific and win, but the values are
restated, not inherited.

**Nothing moved on screen.** Measured at 1440 before and after: name column
starts at x=309 in both, the `%` column ends at x=560 in both, the header
baseline is 353 in both, rows are 22px in both. The three boxes got **13px
shorter** — `table-layout: fixed` gives the name column the 12px the grid was
spending on `gap`, which is enough for *Electronic Countermeasures* to stop
wrapping. Checked at 390 and 820 as well: no overflow, no clipping, notes wrap
to their own full-width line.

**The open question in this finding is now answered differently.** It asked how
often this bites, and guessed "not never". It is still not never — but the fix
cost 13px of height and nothing else, so the question stopped mattering.

---

### F30 — medium — The banked-picks picker offers every skill for every slot when one banked pick is secondary, and the server permits only one

**Filed 2026-09-02, after the audit run.** Found while verifying
`BOOK-INGEST-AUDIT` `F18` on production, not by an audit step — Nate read the
sheet's unspent-picks panel and concluded there was *no way to spend a secondary
pick at all*.

**The client and the server compute the same allowance differently.**

```js
// sheet.js  pickerBlock()  — over ALL grants, secondary included
const allowed = grants.some((g) => !g.categories) ? null : [...];

// picks.js  — over RELATED grants only, secondary tracked separately
const related = pending.filter((g) => g.kind !== 'secondary');
const secondaryAllowance = pending.filter((g) => g.kind === 'secondary')...;
const categories = related.some((g) => !g.categories) ? null : dedupe(...);
```

A secondary grant carries `categories: null`. The client's `some()` therefore
sees a null and sets `allowed = null`, which unrestricts **every** slot. The
server keeps the related grants' categories and allows exactly
`secondaryAllowance` picks outside them.

**So with one banked secondary pick, the picker offers the whole catalog for all
three slots and the server will accept one.** Choosing two out-of-category skills
returns 422 — *"X is Physical, which this grant does not cover"* — after the
choice is made, not while it is being made.

**Measured on production, 2026-09-02.** Character `1212`, level 6, three banked
picks: related at 3, **secondary at 4**, related at 6. Its related grants carry
thirteen categories including
`{"name":"Physical","except":["Acrobatics","Boxing","Wrestling"]}`.

**Two smaller things fall out of the same code.**

- Because `allowed` is null, `hiddenCount` is 0, so the *"show all skills"*
  checkbox **never renders** when a secondary pick is banked. The list silently
  widens and nothing says why.
- The panel reads *"🎓 3 unspent skill picks — earned at level 3, 4, 6"* and the
  block beneath it *"1 from level 3, 1 from level 4, 1 from level 6"* — **neither
  names the kind.** `app.js`'s level-up picker already does, one screen over:
  `${g.count} ${g.kind === 'secondary' ? 'secondary' : 'related'} picks`. The two
  UIs for one concept disagree about whether the kind is worth showing, and the
  one that hides it is the one where it changes what you may choose.

**Proposal.** Make the client agree with the server: build the restricted list
from the **related** grants only, and offer `secondaryAllowance` additional slots
that are explicitly unrestricted — labelled, the way the level-up picker labels
them. **Do not change the server**; it is already right, and `F18` is a fresh
reminder of what happens when two places compute one number.

**Posture: UI only.** No server change, no schema change, no change to what is
legal — only to what the picker offers and what it says. A player should not be
able to choose something the next request will refuse.

> **A first reading of this was wrong and is recorded so it is not re-derived.**
> The initial diagnosis was that the list stays filtered to the related grants'
> categories and the escape hatch is the checkbox worded *"picking one is flagged
> as an override"*. That is what happens with **no** secondary grant banked. With
> one, `allowed` is null and neither the filtering nor the checkbox occurs at
> all. Read `pickerBlock` before implementing from the paragraph above — this
> file's own header warns that seven of its proposals were wrong rather than
> stale, and this one nearly made eight.

**Taken, 2026-09-03 (PR #657), as proposed. Posture held exactly: UI only — no
server change, no schema change, and nothing about what is legal moved.** Smoke
1665 unchanged, regression 237 unchanged.

`pickerBlock` now splits the grants the way the server does. The restricted rows
draw from the **related** grants' categories; the last `secondaryAllowance` rows
draw from the whole catalog and say so — *"secondary — any category"*. The
`kind` the caller was dropping is passed through, `hiddenCount` is non-zero
again so the *show all skills* checkbox reappears, and both the panel heading and
the sub-line name the kind.

**One thing beyond the letter, and the finding is wrong without it.** The
proposal says to build the restricted list from the related grants — it does not
say *how to match a category*, and `pickerBlock` used `allowed.includes(s.category)`.
**A category entry may be an object.** Read from production 2026-09-03, one live
banked grant carries **thirteen categories of which ten are objects**:

```
{"name":"Physical","except":["Acrobatics","Boxing","Wrestling"]}, "Domestic", …
```

`includes` matches only the three plain strings. Implementing the split alone
would have taken a picker that offers **too much** and made it offer **far too
little** — three categories where the class grants thirteen — which is the same
client/server disagreement inverted, and visibly worse for the player. So the
sheet now uses `categoryAllows`, the matcher the server, the wizard and the
validator already share, reached through a small module bridge in `sheet.html`.
**A fourth copy of that rule was the alternative, and `BOOK-INGEST-AUDIT` `F20`
is what two copies of a matcher costs.**

**A second detail that would have shipped a bug.** The server tests
`kind !== 'secondary'`, not `kind === 'related'`, because **a grant banked before
that column existed carries `kind` NULL**. Production confirms it: the live grant
above has `kind: null`. Testing for `'related'` would have reclassified every
older grant as unrestricted — F30's own bug, arriving from the other side. The
client uses the server's test.

**Verified in the running app on port 8791**, against a local character seeded
with that exact production shape — a related grant carrying `Domestic` plus
`Physical except Acrobatics/Boxing/Wrestling`, and one secondary grant:

| | |
|---|---|
| restricted rows (2) | **38 options, Domestic and Physical only** — the object entry matched, which `includes` could not do |
| `except` honoured | Acrobatics, Boxing, Wrestling **absent** from the restricted rows and **present** in the unrestricted one |
| unrestricted row (1) | **330 options, all 18 categories**, labelled *secondary — any category* |
| *show all skills* checkbox | **renders** — *"292 outside this grant's categories"*, and 38 + 292 = 330 |
| heading | *"🎓 3 unspent skill picks — 2 related at level 3, 1 secondary at level 4"* |
| sub-line | *"2 related from level 3, 1 secondary from level 4"* |

**And the client/server agreement was proved against the endpoint, not asserted.**
One out-of-category pick is **accepted** (`ok: true`, `override: false` — the
secondary allowance spent); two in one submission are **refused**, *"Astronomy is
Science, which this grant does not cover"* — F30's own quoted error. **The picker
now offers exactly one unrestricted row, so the refused submission is no longer
reachable through the UI**, which is this finding's posture in one line.

**It fixes the level-up picker too, which F30 does not mention.** `pickerBlock`
is shared, and `skillGrantsFor` has always passed `kind` — so that path had the
same latent defect and one change covers both. `level-confirm.js` computes the
identical related/secondary split, so the client now agrees with both endpoints.

**Screenshotted at desktop and 820×1180**, judged above the fold: the whole
picker sits above it at both, horizontal overflow is zero, and the *secondary*
label does not wrap. Local test rows were removed afterwards and the character
restored — 0 pending, 15 skills, no leftovers.

**Production was read, never written.** The category shapes came from a
`SELECT` against `--remote`; every write in this verification was local.

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

**Blockage 1 was lifted on 2026-09-01 (PR #459)** — see F17. Headless Chrome's
`--print-to-pdf` renders print media with no dialog, so any future print finding
can be checked against a real page rather than read off the stylesheet. The
entry below stands as written; it was true on the day.

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

**`F30` was filed later and its numbers are dated separately — 2026-09-02, and
they are production, not local.** Character `1212`'s three banked picks, their
kinds and their thirteen categories were read with
`wrangler d1 execute --remote` against `pending_skill_picks`; the client and
server allowance expressions were read from `sheet.js` and `picks.js` in the
working tree. Nothing else in this table is affected.

---

## Filed by META-AUDIT A16, 2026-09-06

Two findings that already existed as measured work, deferred by `F24` and `F16`
to *"a separate finding"* that was never filed. `META-AUDIT` `A16` is the
finding about the deferral; these are the work. Both were re-measured on
2026-09-06 at `main` @ the merge of #755 before being numbered.

**Neither is taken by the PR that filed it**, per `audit-menu`.

### F31 — low — two of the six pages still skip a heading level, and `app.js` skips inside a page

**Deferred by `F24`**, whose proposal reads *"Fixing the `h2`→`h4` jumps inside
`app.js`/`catalog.js` is a **separate** finding"*, and whose outcome note adds
*"That is the separate finding this one names, and it is still open."* No such
finding was filed. `F24` itself is closed and its own half — one `<h1>` per page
— shipped in PR #449 and still holds.

**What is true today.** Measured 2026-09-06 with `grep -co '<hN'` over each page
script, and `grep -co '<h1'` over each shell:

| page | first heading after the shell's `h1` | skips |
|---|---|---|
| `sheet.js` | `h3` (11 of them, **no `h2`**) | **`H1→H3`** |
| `catalog.js` | `h4` (4 of them, no `h2`, no `h3`) | **`H1→H4`** |
| `app.js` | `h2` — but see below | **inside the page** |
| `campaign.js`, `dashboard.js` | `h2` | no |
| `codex.js` | none of its own | n/a |

**`app.js` is the part `F24`'s note dropped.** Its own deferral names `app.js`
first, and the note then measures only the two pages that skip *from the top*.
Read 2026-09-06: `<h2>Choose a game system</h2>` at `:771` sits above `<h4>` at
`:774` and `:777`, and `<h2>Pick your class` at `:899` sits above `<h4>` at
`:1096`. `F24` cited the first pair as `app.js:631,634`; the line numbers moved,
the structure did not.

**There are six pages now, not five.** `codex.html` did not exist when `F24` was
written. It carries an `h1` and `codex.js` emits no headings at all, so it is
correct by default and is listed only so the next reader is not surprised by the
count.

**Proposal:** promote the first heading on each page to the level below its
`h1` — `sheet.js`'s `h3` block to `h2`, `catalog.js`'s `h4` block to `h2` — and
in `app.js`, take the two `h4` runs that sit directly under an `h2` to `h3`.
Class and style hooks travel with the tag; no CSS rule in
`apps/character-creator/styles.css` selects any of these by element name, which
is what makes it a tag swap rather than a restyle.

**Posture: markup only, no visual change, no new component, no CSS rule added.**
If a level change moves a single rendered pixel it has been done wrong — `F24`
established the pattern when it promoted `.logo` to `<h1>` and measured 22px /
weight 800 / `margin: 0` identical before and after.

**Decline it** if the judgement is that heading order below the first level is
not worth a markup sweep on an app used by one household. The counter is that
this is the second half of a finding already taken, and it is the half that
makes the first half useful: an `h1` with an `h3` under it announces a missing
section to a screen reader.

**Evidence:** `grep -n "<h[1-6]" apps/character-creator/app.js` and `grep -co`
over the six page scripts and six shells, all 2026-09-06 at the merge of #755.
`F24`'s text and note read the same day. **Not driven in a browser** — the claim
is structural, and `verify-ui` is where the taker proves the render is unchanged.

**Confidence: high** on the structure, which is a grep anyone can repeat.
**Medium** on the tag swap being visually free; what would raise it is the
before/after measurement `F24` already demonstrated on `.logo`.

**Ongoing cost:** none.

**Taken, 2026-09-06, with the posture WIDENED on Nate's word — markup plus the
CSS needed to hold the render.** The finding's own posture said *"no CSS rule
added"*, and that was not achievable: it rested on a claim that is false.

**The false claim, and how it was caught.** This finding says *"no CSS rule in
`apps/character-creator/styles.css` selects any of these by element name, which
is what makes it a tag swap rather than a restyle."* **Eight rules do** —
`.panel h2` `:96`, `.panel h3` `:97`, `.pick h4` `:385`, `.notes-banner h3`
`:1041`, `.stat-col h4` `:1356`, `.block-editors h4` `:1392`, and two print rules
at `:1497-1498`. `audit-premise-auditor` found them and **measured what the swap
would do** rather than reasoning about it.

**Measured before and after, on a fixture linking both stylesheets in the
shells' own load order, rendered headless over CDP:**

| | before | promoted, unpinned | as shipped |
|---|---|---|---|
| catalog `.dupe-head` | 13px / 700 / normal / `0 0 2px` | **21px, letter-spacing −0.3px, margin 4px** | **13px / 700 / normal / `0 0 2px`** |
| wizard `.pick` card title | 15px / 600 / `0 0 8px` | **14px, and a 16px TOP margin appears** | **15px / 600 / `0 0 8px`** |
| sheet section heading | 18.72px / 700 / `0` | **24px** | **18.72px / 700 / `0`** |
| sheet modal title | 18.72px / 700 / `0` | **24px** | **18.72px / 700 / `0`** |

**So the finding's *"if a level change moves a single rendered pixel it has been
done wrong"* is kept — by adding three rules, which is what the finding said it
would not do.** The half that mattered survived; the half that was a guess about
the stylesheet did not.

**Scope, smaller than the finding in one place and larger in another.**

- **`app.js`: three `h4` promoted to `h3`** — `:774` and `:777` under the `h2` at
  `:771`, and `:1096` under the `h2` at `:899`. **`:3407` and `:3411` were left
  alone**: they sit under the `h3` at `:3371`, so `h3`→`h4` there is already legal
  and promoting them would have *created* a skip rather than closed one. This
  finding did not distinguish them.
- **`catalog.js`: all four `.dupe-head` promoted `h4` → `h2`.** That page had no
  `h2` and no `h3` at all.
- **`sheet.js`: ten of eleven `h3` promoted to `h2.sub-h`. `:1761` was left as an
  `h3` on purpose** — *"New abilities"* is a sub-heading inside the level-up modal
  whose title is `:1758`, so promoting both would have flattened two levels into
  one. This finding called the eleven a block; they are not.

**Why a class rather than a container selector**, which is the one design
decision here. The promoted sheet headings sit in `.box`, in modals and in
composed fragments, and nothing in either stylesheet sized them — they were UA
defaults, `1.17em` for `h3` against `1.5em` for `h2`. A bare `h2` rule would also
have caught `campaign.js` and `dashboard.js`, whose `h2`s render at 24px today and
must keep doing so. `.sub-h` cannot collide, and the fixture proves both: a plain
`h2` still measures **24px** and `.panel h2` still **21px** after the change.

**Verified on the live pages as far as they can be reached without touching
state.** The catalog page reports one `h1` and no skip; the wizard reports
`H1 → H2`. The wizard's system cards and the sheet could **not** be rendered live
because a real draft sits in local `character_drafts`, and `verify-ui` is explicit
that *Discard and start fresh* destroys it — so it was left alone and the draft
count was confirmed unchanged at **1** afterwards. **Those two contexts are
fixture-measured rather than app-measured, and that is stated rather than
implied.**


### F32 — low — `prefers-reduced-motion` is absent from the character creator, and present in the sibling app

**Deferred by `F16`**, whose outcome note reads *"`prefers-reduced-motion` was
**not** taken — it is a separate item and stays open."* No such item was ever
filed. `F16`'s other half — `:focus-visible`, copied from `apps/pick3cut5` —
shipped in PR #444 and holds.

**What is true today.** The app has exactly two stylesheets and **neither
contains the rule**:
`grep -rn "prefers-reduced-motion" --include=*.css apps/character-creator shared`
returns nothing, 2026-09-06. `apps/pick3cut5/styles.css:557` has it, which is the
comparison `F16`'s own heading draws — *"while a sibling app has both done
well."*

**There is motion to reduce, which is why this is not vacuous.** Six
`transition:` declarations in `apps/character-creator/styles.css` and four in
`shared/styles.css`, plus two keyframe animations in `shared/styles.css:302-303`
— `spin` (a continuous rotation) and `pulse` (an opacity oscillation). A
continuous spinner is the case the media query exists for.

**Proposal:** copy the block from `apps/pick3cut5/styles.css:557-563` into
`apps/character-creator/styles.css` — `animation-duration`,
`animation-iteration-count` and `transition-duration` clamped under
`@media (prefers-reduced-motion: reduce)`. **App-local, not `shared/`**, which is
the same scoping decision `F16` made when it copied `:focus-visible`: `shared/`
is loaded by four apps and two of them have made no such decision.

**Posture: one media block in one app stylesheet. No shared file touched, no
component changed, no JS.**

**Decline it** if the judgement is that a household app with two keyframe
animations does not need the query. The counter is `F16`'s own framing: the
sibling app has it, the difference is unexplained, and the two animations that
exist are in `shared/` where every app sees them.

**Evidence:** the two `grep -rn --include=*.css` runs above and
`grep -coE "transition:|animation:|@keyframes"` over both stylesheets, all
2026-09-06. `apps/pick3cut5/styles.css:557-563` read the same day.

**Confidence: high.** It is an absence proved by reading both files that could
hold it, rather than by one grep shape — which is the failure `CLASS-AUDIT`
`F17` recorded.

**Ongoing cost:** none. Seven lines that need no maintenance.

**Taken, 2026-09-06 (`UI-AUDIT` `F32`). Posture held: one media block in one app
stylesheet — `shared/` untouched, no component changed, no JS.** It sits directly
beneath the `:focus-visible` rule `F16` shipped, which is the other half of the
same finding, with a comment saying why it is app-local.

**Four things in the text above are wrong. `audit-premise-auditor` found all
four before the block was written.**

**1. `shared/styles.css` has ONE `transition:` declaration, not four** — `:237`.
The other line a grep finds is `:146`, the `--transition: 0.2s ease` token
definition, which is not a declaration. The character-creator half holds exactly:
six, at `:49`, `:157`, `:381`, `:989`, `:1089`, `:1716`.

**2. This app applies NEITHER keyframe animation, so the claim that a continuous
spinner is the case for the query is false HERE.** `spin` and `pulse` are defined
in `shared/styles.css:302-303` under a comment saying the app sizes its own
`.spinner` — and this app has none. `grep -rn "animation:" --include=*.css apps
shared` finds them used in filament-forge, media-vault and pick3cut5, and **zero
times in `apps/character-creator/styles.css` or `shared/styles.css`**. So of the
three properties shipped, only `transition-duration` does anything today. The
other two are a forward guard and the comment in the CSS says so rather than
implying otherwise.

**3. `F16` had already judged this, and `F32` failed to say so.** `F16`'s
*Proposal* — not the outcome note `F32` quotes — reads
*"`prefers-reduced-motion` is a **separate** item and genuinely low value here:
the app's only transitions are `color`/`border-color` at 0.2s."* `audit-menu` is
explicit that a finding may re-propose a settled judgement but **may not fail to
say the judgement exists.** `F32` did exactly that, in the same session as
`META-AUDIT` `A16`, whose subject is work going missing between findings.

**4. The cited copy range would have shipped broken CSS.** `F32` says
`apps/pick3cut5/styles.css:557-563`. Line `563` is `.flip-row { opacity: 1; }`,
a pick3cut5-only selector, and the media query's closing brace is at `565` — so
the range is **unbalanced** and drags in a class this app does not have. What
shipped is `557-562` plus a closing brace, and the balance was checked by
counting braces across the whole file afterwards: **0, never negative.**

**So this is a smaller change than the finding claimed, and it is worth having
anyway** — six real transitions get damped, the app stops being the only one of
the four without the query, and the guard is in place if anything ever uses
`shared/`'s spinner.

## Filed while taking BOOK-INGEST-AUDIT F32, 2026-09-08

### F33 — medium — an unmet class minimum has never rendered red, because `.err` loses to `.attr-note`

**Not taken here.** Found while adding a sibling note to the same column in PR
#824 and filed rather than folded in, because that PR takes one finding.

The Attributes step marks an unmet minimum by switching a class:

```js
// apps/character-creator/app.js:1914
const req = reqs[a] ? `<span class="attr-note ${v != null && v < reqs[a] ? 'err' : 'ok'}">need ${reqs[a]}+</span>` : '';
```

**Both modifiers are inert.** `.err` and `.ok` are colour-only rules at
`apps/character-creator/styles.css:110-111`; `.attr-note` at `:475` also sets
`color`, and the two tie on specificity (one class each), so **source order
decides and `.attr-note` is 364 lines later.**

**Measured in the browser, not reasoned from the file** — localhost, the Deep
Intel Agent, I.Q. set to 4 against a printed minimum of 10:

```
class "attr-note err"   computed color rgb(132, 147, 142)   = --text-muted #84938E
                        --danger is #DE6E58, and is not on the element
```

So the one visual cue that an attribute is blocking the step renders the same
grey as the dice expression beside it. The step *is* still blocked — `canNext`
at `app.js:1947` is unaffected, and the reason is repeated in text beside the
button — so this is a missing signal rather than a wrong one.

**Proposal:** add `.attr-note.err` and `.attr-note.ok` beside `.attr-note`,
matching `.attr-note.caution` which PR #824 added two lines above them for
exactly this reason. Two lines, no JS change, no new class names. **Posture:
presentation only** — nothing about what blocks or passes moves.

**Evidence:** computed styles read in the pane, 2026-09-08, on the walk
described in `BOOK-INGEST-AUDIT.md` F32's outcome note. **Confidence: high** for
the diagnosis and the fix; the only open question is whether `.ok` should paint
green at all, or whether a met requirement is better left muted — which is a
design call and is why this is not a one-line certainty.

**Ongoing cost:** none. Two static rules in the file that already owns the
column.

**Taken, 2026-09-08 (PR #827).** Presentation only, as proposed - nothing about
what blocks or passes moved.

**ONE rule, not two.** The proposal offered `.attr-note.err` and
`.attr-note.ok`, and named the open question itself: *"whether `.ok` should
paint green at all, or whether a met requirement is better left muted."*
<!-- claim-ok: quoting this finding's own proposal, above -->
**Nate settled it: only `.err`.** A requirement that is met needs no colour -
painting every satisfied row green is colour carrying no information, and it
would compete with the amber cap `BOOK-INGEST-AUDIT` `F32` added two lines
above. Three states, three meanings: **muted satisfied, red blocking, amber
advisory.** `.ok` keeps its class and keeps rendering muted, which is what it
already did.

**The premise held exactly.** `.err` is at `styles.css:110` and `.attr-note` at
`:474` - one class each, so the tie goes to source order and `.attr-note` wins
by 364 lines.

**Verified by looking, which is the only thing that can confirm a colour.** On a
local server confirmed to be serving this branch, the Deep Intel Agent with
I.Q. 4 against a printed minimum of 10 and P.B. 18 against a cap of 12, at
768x1024 with the whole step above the fold:

| row | class | computed | token |
|---|---|---|---|
| I.Q. `need 10+`, unmet | `attr-note err` | `rgb(222, 110, 88)` | `--danger` `#DE6E58` |
| M.A. `need 10+`, met | `attr-note ok` | `rgb(132, 147, 142)` | `--text-muted` `#84938E` |
| P.B. `12 or less`, over | `attr-note caution` | `rgb(201, 154, 62)` | `--warning` `#C99A3E` |

The `Skills` button is disabled for the unmet minimum and enabled for the
exceeded cap, unchanged by this - which is the half that had to not move.

## Filed by an Impeccable design critique, 2026-09-09

Run 2026-09-09 against the working tree at `C:\Users\natha\Projects\nates-apps`,
served from `wrangler pages dev --port 8791` (the `nates-apps-8791` launch config —
**not** 8788, which belongs to another worktree). Two independent assessments: an
unanchored design review, and a mechanical detector plus browser measurement, kept
isolated from each other until synthesis. Nothing here has been changed. Take
findings one at a time.

**Both `F34` and `F35` are cascade collisions rather than design choices, and this
file recorded half of each before today.** `F28`'s outcome note describes `F34`'s
exact mechanism and judged it harmless — correctly, for the palette of the day.
`F5`'s outcome note describes the rule `F35` is about, and names only half of what
that rule shipped.

**Two further findings from the same run are deliberately NOT filed here**, because
this menu's scope is the character creator and neither is scoped to it: an
emoji-to-SVG icon layer spanning all four apps and the landing page, and MediaVault's
`.bulk-bar` at phone width. The second is already named at
`apps/media-vault/SHARE-AUDIT.md:446-453`, which records it as
<!-- claim-ok: quoting SHARE-AUDIT's own deferral wording, cited by line above -->
*"named rather than filed"* and hands it to whoever next opens a UI menu for that
app. Both are awaiting a placement decision from Nate rather than dropped — per
`audit-menu` → *A deferral is work*, they are named here so neither goes missing.

**Both were placed and both were TAKEN, on 2026-09-10, two days after the
paragraph above was written — which is now the stale half of it.** They went to
`WORKSHOP-UI-AUDIT.md`, the cross-app menu created for exactly this:

| deferred here as | landed as | outcome |
|---|---|---|
| the emoji-to-SVG icon layer across four apps and the landing page | `WORKSHOP-UI-AUDIT` `W2` (`:224`) | **Taken, PR #917**, as re-scoped |
| MediaVault's `.bulk-bar` at phone width | `WORKSHOP-UI-AUDIT` `W3` (`:479`) | **Taken, PR #918**, the disclosure shape Nate chose |

**And `W3` covers the specific defect `SHARE-AUDIT` named**, which is worth
saying because the two describe it differently: `SHARE-AUDIT` recorded the bar
*peeking above the bottom edge* when parked, and `W3` is headed *"takes 42% of a
phone viewport while select mode is on"* — different symptoms of one bar.
`WORKSHOP-UI-AUDIT.md:91` calls `bottom: -80px` *"a magic number that stopped
being true"* and `:136` names the peek explicitly as pointing the same way, both
read 2026-09-12. Nothing of either deferral is left.

**The sentence above is left standing rather than edited**, because this file is
a record and the deferral was correct when it was made. What it teaches is the
cost: **a deferral to "a placement decision" is invisible to every sweep once the
decision is made somewhere else.** Neither `W2` nor `W3` cites this paragraph,
`scripts/audit-citations.mjs` reads only class notes, and `menu-check.mjs`
checks phrasing rather than truth — so this stayed open-looking for two days and
was found by a census rather than by anything that runs. **A deferral naming the
menu it expects to land on would have closed itself.**

---

### F34 — high — Every primary button drops to 1.17:1 on hover, and this file recorded the mechanism while it was still harmless

**Step: contrast sweep of interactive states.**

`shared/styles.css:240` is `.btn:hover { border-color: var(--text-muted); background:
var(--bg-input); }` at specificity (0,2,0). `shared/styles.css:274` is `.btn-primary`
at (0,1,0), setting `background: var(--accent)` and `color: var(--bg-primary)`. The
hover rule therefore replaces the primary button's fill while its foreground stays the
dark tone. Grepping `btn-primary:hover` across `shared/styles.css` and all four
`apps/*/styles.css` on 2026-09-09 returns exactly two hits —
`apps/media-vault/styles.css:41` and `apps/filament-forge/styles.css:34` — so those
two apps override it and the character creator and pick3cut5 do not. The nearest
thing in the shared file is `.btn-primary:disabled:hover` at `:264-265`, which pins a
*dead* button back to `--accent` and leaves the live one alone.

Measured live in the page on 2026-09-09, hovering a real pointer over an injected
`.btn.btn-primary` probe and reading `getComputedStyle` after the 0.2s transition
settles: `color rgb(15,20,18)` on `background rgb(27,35,32)` — `--bg-primary` on
`--bg-input`, **1.17:1**. Both character-creator and pick3cut5 return the same pair.
Reading the value before the transition settles returns the accent and looks fine,
which is worth knowing for anyone re-measuring.

**This file already contains the mechanism.** `F28`'s outcome note (2026-09-01) closes
with a paragraph headed *"Recorded, not fixed — one thing found while measuring"*,
which names the same specificity collision and then says:
<!-- claim-ok: quoting the F28 premise this finding supersedes -->

> No contrast failure results — white on `--bg-input` is comfortable — but it is not
> what either rule intends, and it is outside this finding's scope.

That was true and is now false, and **nothing was careless in between.** `F28` shipped
white-on-accent for the palette of the day. When the scheme moved to Ley Verdigris the
primary button's foreground was changed to `--bg-primary` — `shared/styles.css:268-273`
carries the reasoning, that white on the new `--accent` measures 4.09:1 at 13px/600 and
the dark tone measures 4.60. That change is independently correct and it silently
invalidated the "no contrast failure results" half of `F28`'s note, because the
comfortable pairing it relied on was white.

**So the interesting part of this finding is not the bug.** It is that a defect was
observed, correctly judged harmless, written down, and then armed by a later change
that had no reason to look at it. Neither PR was wrong.

**Proposal:** add `.btn-primary:hover` to `shared/styles.css`, beside the
`.btn-primary:disabled:hover` pair at `shared/styles.css:264-265` (read 2026-09-09),
restating `background: var(--accent)` and `color: var(--bg-primary)` by name so the
primary variant survives `.btn:hover` at every specificity. **Posture: shared stylesheet, all four apps, no component and no JS
change.** This is the one place in this menu where touching `shared/` is the *narrow*
option rather than the broad one — the two apps that already carry their own override
are unaffected by it, and the two that do not are the two that are broken.

Whether hovering a primary button should also darken it is a separate question and
this finding does not propose an answer; restating the resting colours is enough to
close the contrast failure.

**Evidence:** live pointer hover plus `getComputedStyle` on both affected apps,
2026-09-09; `grep -n "btn-primary:hover" shared/styles.css apps/*/styles.css`,
2026-09-09; line numbers in `shared/styles.css` read the same day at 303 lines.

**Confidence:** high on the measurement and on the cascade. Medium on the claim that
no other `:hover`, `:active` or `:disabled` pair in the repo fails the same way — the
2026-09-09 sweep enumerated **resting** states across five surfaces and found zero AA
failures, and did not enumerate interactive states. Running that sweep over hover and
active states across all four apps is what would raise it, and would probably be worth
more than this finding.

**Ongoing cost:** one rule in a file already carrying an adjacent rule of the same
shape. No check to remember, nothing to keep current.

---

**Taken, 2026-09-10 (PR #893). Posture held: shared stylesheet, all four apps, no
component change and no JS.** `.btn-primary:hover` added to `shared/styles.css`
beside the disabled pair, as proposed.

**Three things in the text above are wrong. `audit-premise-auditor` found all
three before the rule was written.**

**1. The ratio was never 1.17.** The pair `#0F1412` on `#1B2320` measures **1.16**,
so the finding was 0.01 high the day it was filed. It is now **1.26** — PR #891
(Bench) moved `--bg-primary` to `#0A0F0E` and `--bg-input` to `#1E2724` on
2026-09-10, between the filing and the taking. Both numbers are far under 4.5 and
the substance is untouched; the heading is left as filed, because an audit file is
a record and this note is where the correction belongs.

**2. The proposal was insufficient, and `color` was never the declaration at**
**risk.** `.btn:hover` sets `border-color: var(--text-muted)` as well as
`background`, and sets no `color` at all. Implemented literally — restating
`background` and `color` — a hovered primary button would have kept a grey
`#84938E` hairline around an accent plate, which falsifies the finding's own
stated goal of surviving `.btn:hover` "at every specificity". The rule as shipped
restates `border-color`, `background` and `color`, which is the shape the adjacent
disabled pair already uses and which the finding itself points at as its model.

**3. The explanatory paragraph misattributed the comment it cited.** It said
`shared/styles.css` carries the reasoning that white on the new `--accent`
measures 4.09:1 and the dark tone 4.60. Those are **Rust & Ash's** figures against
`#C4622D` — correct when written at `75a0205`, never re-measured through the
retone. Against `#35A0AE` the real values are **3.09** and **6.24**, and the same
file already recorded 6.24 for that pair two hundred lines up in the `::selection`
note, so it disagreed with itself. **Corrected in this PR**, because the stale
sentence sits in the four lines directly above where the new rule goes and leaving
it would have meant shipping a rule beside two numbers that describe nothing.

**The tie-break was the risk and it is settled.** The new rule is (0,2,0) and
`.btn:hover` is (0,2,0), so specificity does not separate them and **source order
does**. Anywhere after `.btn:hover` wins; anywhere before it loses silently. The
position the finding proposed is a winning one.

**Verified on production after the merge**, not just locally: `--bg-primary` on
`--accent` at 6.24 under the pointer, on both affected apps.

`media-vault` and `filament-forge` were unaffected and are unchanged. One thing
seen and NOT fixed here: `apps/media-vault/styles.css:41` pins its own
`.btn-primary:hover` to a hardcoded `#c86a2e`, a rust literal surviving a
verdigris scheme. It clears AA at 5.11 against `--bg-primary` so it is not this
defect, and it is out of scope for this finding.

---

**Adjusted 2026-09-10 (PR #912). The Confidence line above is settled, and the
answer is that this defect was the only one of its kind.**

This finding shipped at medium confidence on one point: whether any other `:hover`,
`:active` or `:disabled` pair in the repo failed the same way. It named the work that
would settle it — sweeping interactive states across all four apps, which the
2026-09-09 critique had not done, having enumerated **resting** states only.

That sweep has now run. Every `button`, `a`, `.btn`, `[role=button]` and `summary`
with visible text was forced into `:hover` through CDP `CSS.forcePseudoState`, and its
text measured against the nearest opaque ancestor background at the WCAG floor for its
own size and weight:

| surface | hovered elements | failing |
|---|---|---|
| character creator (wizard) | 4 | 0 |
| character sheet, `?id=1` | 108 | 0 |
| codex | 745 | 0 |
| catalog | 2 | 0 |
| campaign dashboard | 5 | 0 |
| media-vault | 27 | 0 |
| filament-forge | 14 | 0 |
| pick3cut5 | 4 | 0 |
| **total** | **909** | **0** |

**The zero is only worth reading because the instrument was made to fail first.** Each
run injects a canary button whose `:hover` is this finding's exact failure —
`--bg-primary` on `--bg-input` — and the run is reported as broken unless the sweep
flags it. The canary was caught at **1.26** on all eight surfaces, which is this
finding's own measured ratio.

**Two bugs in the sweep were caught that way, and both would have produced a
confident wrong answer:**

- **A false positive.** `color-mix()` computes to `color(srgb 0.18 0.55 0.60)`, whose
  components are 0-1. Parsed as 0-255 they read as near-black, and the sweep reported
  filament-forge's `.btn-primary` hover at 1.08:1. That button is fine.
- **A false negative, and the reason the canary exists.** `offsetParent` is `null` for
  `position: fixed`, so the first visibility test silently skipped every fixed control
  in every app — including the canary. The first clean run came from a partly blind
  instrument and looked identical to a healthy one.

**What this does NOT cover**, so the silence is not read as coverage: `:active` and
`:disabled` were not swept, only `:hover`. Only the first rendered state of each
surface was measured — no modal, no play mode, no later wizard step, and not
media-vault's bulk bar, which needs select mode on. Form controls were out of scope
because they carry no text of their own. A surface reached only by clicking through
is unmeasured.

**Nothing is filed from this.** The sweep found no defect, and a finding with no
defect behind it is not worth a number.

---

### F35 — high — One `font` shorthand takes the wizard stepper out of its own typography, and deletes six of ten steps at phone width

**Step: responsive sweep at 390×844.**

`apps/character-creator/styles.css:311` is:

```css
.stepper .step-rail button.st { line-height: inherit; font: inherit; }
```

The `font` **shorthand** resets family, size, stretch, weight, line-height and
variant together. At (0,3,1) that selector outranks both rules that style the step
pills — the desktop `.stepper .step-rail .st` at `:290` and the
`@media (max-width: 900px)` one at `:387`, each (0,3,0). Completed steps render as
`<button>`; the current, future and `.na` steps render as `<span>`.

Verified on 2026-09-09 by a method independent of the review that raised it: with the
wizard loaded, a `button` carrying `class="st done"` was appended to the live
`.step-rail` in the DOM only — no server write — and both computed styles read side by
side.

| element | family | size | stretch | weight |
|---|---|---|---|---|
| `span.st` sibling | `Saira` | **0px** | 75% | 900 |
| injected `button.st.done` | `IBM Plex Sans` | **16px** | 100% | 600 |

At desktop the same probe returns `Saira / 15px / 75%` for the span against
`IBM Plex Sans / 16px / 100%` for the button, so completed steps render in the body
face, one size up and roughly a quarter wider than the rail was set for.

The phone consequence is the severe one. `:378` carries a comment explaining that
`font-size: 0` at `:388` *"hides the text without display:none, so the `<button>` keeps"*
its hit area — the rule that turns the rail into ten anonymous progress bars. Buttons
never receive it, so their tracks get sized by min-content instead. The review measured
`grid-template-columns` at 390px as `64px 43px 103px 107px 0 0 0 0 0 0` on a
mid-wizard page: **steps five through ten are zero pixels wide**, and the four
survivors overprint their own bars. A fresh draft with no completed steps has no
`<button>` in the rail at all and computes ten equal 30.7px tracks, which is why this
does not reproduce on a first load — it needs at least one completed step, which is
every state after step one.

**This file describes the rule and names only half of it.** `F5`'s outcome note
(the keyboard-access finding) lists the stepper among the elements it touched and
writes the rule as `.stepper button.st { line-height: inherit }`, explaining that a
button's own line-height sat the pill off the line. Its **very next bullet**, on the
NPC row, says the conversion there was *"deliberately **not** `font: inherit`, which
would also overwrite `.chkrow`'s own 13px."*
<!-- claim-ok: quoting F5's own outcome note, which is in this file above -->
So the trap is understood in this repo, was avoided by name one bullet later, and the
stepper rule carries the shorthand anyway. Whether it arrived in that PR or a later
one, `F5`'s note is the record of what that rule was for, and line-height is all of it.

**Proposal:** delete `font: inherit` from `:311` and keep `line-height: inherit`.
`.st` at `:290` already declares family, stretch, size, weight and letter-spacing at
author origin, which beats the user-agent button shorthand unaided — no `!important`
and no extra specificity needed. **Posture: one declaration removed from one app
stylesheet. No markup change, no new rule, no token touched.**

**Verification for whoever takes it:** re-read `getComputedStyle` on a `.done` step —
it must report `Saira`, `75%`, and `15px` at desktop, `0px` under 900px — and confirm
`grid-template-columns` at 390px computes ten equal tracks on a page with completed
steps. A screenshot at 390px is the honest check; the DOM number alone is what let
this stand.

**Evidence:** DOM-injected computed-style probe at 390px and 1440px, 2026-09-09;
`grid-template-columns` read from the live rail the same day; line numbers read from
a 2072-line `apps/character-creator/styles.css` the same day.

**Confidence:** high. The cascade is arithmetic and the computed styles were read
twice at two widths. What is **not** established is the rendered appearance after the
fix — nothing has been changed, so the ten-equal-tracks claim is a prediction from the
cascade rather than a measurement. Taking it and screenshotting at 390px raises that
half.

**Ongoing cost:** none. One declaration fewer.

---

**Taken, 2026-09-10 (PR #894). Posture held: one declaration removed from one app
stylesheet — no markup change, no new rule, no token touched.** `font: inherit` is
gone from `apps/character-creator/styles.css`; `line-height: inherit` stays, as
proposed.

**Four things in the text above are wrong or imprecise. `audit-premise-auditor`
found all four before the edit was made.**

**1. `line-height: inherit` is INERT, so "line-height is all of it" is false.**
Chrome drops the longhand at parse time — the rule as parsed today is
`{ font: inherit; }` alone, so the declaration this finding says to keep has been
dead text. Nothing declares `line-height` on any ancestor either, so `inherit`
resolves to `normal`, which is what a `<button>` gets anyway. Measured three ways
at 1440 and again at 390 — as shipped, with the shorthand removed, and with the
rule emptied entirely: the last two are byte-identical. **The 0.5px pill offset
the old comment blamed on line-height was font mismatch**, and it closes because
family and size now match. The declaration is kept anyway, because the finding
scoped this to one declaration and because the comment above it now says what is
true instead of what was assumed.

**2. `font: inherit` was NOT added by `F5`.** The finding says "whether it arrived
in that PR or a later one" and leaves it open; `git log -S 'stepper button.st' --
`apps/character-creator/styles.css` closes it in one command. `911da22`
(2026-08-31, `F5`) added `.stepper button.st { line-height: inherit; }` — the
line-height alone, exactly as `F5`'s note describes. `cabcdc3` (2026-09-01, Rust &
Ash phase 5, the wizard rail) replaced it with the two-declaration form and
introduced the shorthand. **`F5` is exonerated on the point this finding
half-implies**, and the trap was walked into by a redesign the day after, not by
the keyboard work.

**3. The `64px 43px 103px 107px 0 0 0 0 0 0` figure is state-dependent.** It
describes a page with FOUR completed steps. Measured on the local draft resumed at
step 7 (six completed): `64.05 43.41 102.64 106.95 57.69 98.27 0 0 0 0` — four zero
tracks, not six, with the first four matching to rounding. The general statement is
**the number of zero-width tracks equals ten minus the completed-step count**, so
the heading's "deletes six of ten" is one state rather than the rule.

**4. The symptom was worse than described, in the direction that helps.** The six
surviving tracks totalled 473px plus 27px of gaps — **500px inside a 334px rail**,
166px of overflow, clipped by `body { overflow-x: hidden }` so `scrollWidth` still
read 390. And completed steps kept `font-size: 16px` at phone width, so their
labels rendered: the rail read `SYSTEM RACE ATTRIBUTES OCCUPATION SKI…` at full
size, running off the right edge, **with no bars visible at all**. The finding says
the survivors "overprint their own bars"; the ten-bar design was absent rather than
degraded.

**Two smaller corrections.** The finding's probe table labels its comparison
element `span.st` and gives it weight 900 — that is `.st.cur`; base `.st` is weight
300, so the weight column was not comparing like with like. And its evidence line
says a 2072-line stylesheet; `wc -l` gives **2071**.

**One thing the finding did not know, which makes the fix safer than it argued.**
`apps/character-creator/styles.css:139` is `button { font-family:
var(--font-display); font-stretch: 75%; cursor: pointer; }`. The finding cites only
`.st` as the author-origin source that beats the user-agent shorthand. Both are
author origin and both set the same values, so family and stretch are declared
twice over — confirmed by emptying the rule entirely and still reading Saira 75%.

**Verified after the fix, at 390px on a six-completed-step state:**
`grid-template-columns` computes **ten equal tracks** (`30.69px`, then `30.70px`
×9), and a completed step reads `Saira / 0px / 75%` like its neighbours. At 1440 a
completed step reads `Saira / 15px / 75%`. Desktop distinctness survives: `.st.done`
keeps `font-weight: 600` against `.st`'s 300 and `.st.cur`'s 900, plus
`--text-primary` and `border-bottom-color: var(--border-strong)`.

**A comment elsewhere became true.** `apps/character-creator/test/checks/rendered-ui.mjs`
explains its `font-size: 0` assertion as "rather than `display: none`, so the button
keeps its accessible name". That was false while the buttons never received
`font-size: 0`. It is true now, and needed no edit.

---

### F36 — medium — The focus ring and the reduced-motion block were each scoped to one app on purpose, and the promotion neither of them made was never given a number

**Step: cross-app consistency sweep.**

`F16` shipped `:where(button, input, a, summary, [tabindex]):focus-visible` into
`apps/character-creator/styles.css` on 2026-08-31 (PR #444), and its *Proposal* says
why it went no further:
<!-- claim-ok: quoting F16's own proposal, which is in this file above -->

> **App stylesheet only** — promoting it to `shared/styles.css` would give three other
> apps a focus ring overnight and is a bigger finding than it looks.

`F32` shipped `prefers-reduced-motion` into the same file on 2026-09-06 and held the
same posture — its note opens *"one media block in one app stylesheet — `shared/`
untouched"*.
<!-- claim-ok: quoting F32's own outcome note, which is in this file above -->

**Both were right, and neither filed the bigger finding.** That is the gap this one
closes: `audit-menu` → *A deferral is work. Give it a number or say you are dropping
it.* The promotion has been named twice, ten days apart, and has never been open,
because open is a property of findings and it had no number.

What the deferral costs today, measured 2026-09-09 across the four apps:

| | focus ring | `prefers-reduced-motion` |
|---|---|---|
| character-creator | yes | yes |
| pick3cut5 | yes | yes |
| media-vault | **no** | **no** |
| filament-forge | **no** | **no** |

The two without are not merely un-styled. Both set `outline: none` and supply no
replacement on named controls: MediaVault's `#searchInput` (via `.search-box input`)
and FilamentForge's `#printerModel` (via `.field select, .field input`) were each
blurred, then focused after a real `Tab` keypress to put Chrome in keyboard modality,
then compared on all four of `outline`, `box-shadow`, `border-color` and `background` —
all four identical before and after. A programmatic `.focus()` never matches
`:focus-visible` and produces a false negative here, which is the same trap `F16`'s own
note records.

The motion half lands the same way round. Both bounce-easing transitions
(`cubic-bezier(0.34, 1.56, 0.64, 1)` at `apps/media-vault/styles.css:838` and `:875`)
and the `transition: width 0.4s ease` at `:1182` are in MediaVault, which is one of the
two apps with no reduced-motion guard. `grep -rn "prefers-color-scheme"` across the
repo on 2026-09-09 returns nothing at all, so dark is hard-coded rather than a scheme —
noted as context, not proposed as work.

**Proposal:** move the `:focus-visible` block and the `prefers-reduced-motion` block
from `apps/character-creator/styles.css` into `shared/styles.css`, deleting the app-local
copies, and screenshot all four apps afterwards at 1440×900. **Posture: shared
stylesheet, no component change, no JS, no new token.** The ring's colour resolves
through `--accent-secondary`, which each app's `:root` already sets, so the four apps
each get the ring in their own colour without any of them naming it — which is the
mechanism that made `F16` cautious and is also what makes this safe to do in one PR.

**The caution in `F16` is the thing to honour, not to argue past.** *"A focus ring
overnight"* is a real change to three apps' appearance, and the reason it is worth
taking now rather than then is that two of those three have since been measured to have
no keyboard focus indicator at all. If the screenshots show the ring landing badly
anywhere, the right outcome is to say so in the note and stop, not to widen the PR.

**Evidence:** focus-state comparison on both named controls after a real `Tab`,
2026-09-09; `grep -rn "focus-visible\|prefers-reduced-motion\|prefers-color-scheme"`
across `apps/` and `shared/` the same day; `F16` and `F32` read under their headings in
this file the same day.

**Confidence:** high that the two apps have no focus indicator on those two controls,
and that the promotion was deferred twice without a number. **Medium on the claim that
one shared block is sufficient for all four apps** — the receiving apps' controls were
not enumerated, only the two named ones, and MediaVault sets `outline: none` in six
rules by the same sweep. Enumerating every `outline: none` in the two receiving apps is
what would raise it, and may turn this into a larger PR than the proposal implies.

**Ongoing cost:** one block in `shared/` instead of one in an app, so slightly less to
keep in step. The real ongoing cost is the one `F16` named: a shared rule means a
change to it is a change to four apps, and the four are not screenshotted together by
anything today.

---

**Taken, 2026-09-10 (PR #911). Posture held: shared stylesheet, no component change,
no JS, no new token.** Both blocks moved to `shared/styles.css`; both app-local copies
deleted from `apps/character-creator/styles.css`.

**The central claim of this finding is FALSE, and it was taken anyway because the
move is still worth making.** `audit-premise-auditor` built the post-promotion cascade
and drove real `Tab` keypresses through CDP before anything was edited.

**1. The promoted ring reaches NONE of the controls this finding was filed about.**
The ring is `:where(button, input, a, summary, [tabindex]):focus-visible`, and
`:where()` contributes zero specificity — the whole selector is **(0,1,0)**. Every
`outline: none` in a receiving app is (0,1,0) or (0,1,1) and its stylesheet loads
after `shared/`, so all ten of them win. Measured after the promotion:
`#searchInput` and `#printerModel` — the two controls this finding names — still
compute `outline: none`. What the move DOES buy is a ring on bare `button`, `a`,
`summary` and `[tabindex]` in media-vault and filament-forge, which is real and is
not what the proposal says it delivers.

**2. `select` and `textarea` are not in the selector at all**, so FilamentForge's
`#printerModel` — a `<select>` — is unreachable by this rule before specificity even
enters.

**3. "which each app's `:root` already sets" is false for all four apps.** No shipping
app overrides `--accent-secondary`; only `apps/_template/styles.css` does. All four
resolve to `#D9A05B` and always did. The per-app-colour mechanism this finding calls
"what makes this safe to do in one PR" does not exist. The error came from `F16`'s own
outcome note, which recorded a per-app colour that was true on 2026-08-31 and was
falsified by the retone; this finding read it as present tense.

**4. The ring has been inert on every text control in the character creator since the
day `F16` shipped it, and nothing recorded that.** `styles.css:167`
`input:focus, select:focus, textarea:focus { outline: none }` is (0,1,1) and beats the
ring at (0,1,0) from 20 lines above it. `F16` verified its ring on a tab control — a
`[tabindex]`, one of the cases that does work. **The character creator is byte-for-byte
unchanged by this PR**, so nothing regressed; but the block being promoted is one that
never worked on the control class the finding cares about.

**5. pick3cut5 was left alone.** The proposal says "deleting the app-local copies" and
names only the character creator's. pick3cut5's ring is byte-identical to the shared
one (`diff` clean) and its motion block is a superset carrying two page-specific lines,
so deleting it would lose them. Verified no conflict and no visual change: identical
declarations, and its own `.panel input:focus { outline-offset: 0 }` at (0,2,1) already
overrode the offset before this PR. Redundant rather than wrong, and left for a
decision rather than swept up here.

**6. The receiving surface is ten pages, not four apps.** `shared/styles.css` is linked
by the five character-creator shells, the three other apps, and `apps/_template`. The
root `index.html` deliberately does not load it, so the landing page gets neither block
— a fifth surface the proposal's screenshot instruction does not cover.

**What was verified.** Ring colour clears the 3.0 floor on every ground —
`#D9A05B` measures 8.39 on `--bg-primary`, 7.60 on `--bg-secondary`, 6.66 on
`--bg-tertiary`. No test in the repo asserts on `outline`, `:focus-visible` or
`prefers-reduced-motion`. Four smoke suites pass. All four apps screenshotted at
1440×900 and keyboard-focused through CDP.

**The motion half is the stronger half and it works everywhere.** `*, *::before,
*::after` with `!important` is untouchable by app rules, and it now damps 24
transitions and three animations in media-vault and 12 transitions and two animations
in filament-forge — against six transitions and zero animations in the app it came
from.

**The selector rewrite that would actually deliver what this finding claimed is filed
as `F37` below**, with the measured recipe and the regression it carries. It is not
taken here: it is a different change with a decision in it, and `F36`'s own text says
that if the ring lands badly the right outcome is to say so and stop rather than widen
the PR.

---

### F37 — medium — The shared focus ring cannot reach a text control in any app, because `:where()` makes it the weakest selector in the cascade

**Filed 2026-09-10 while taking `F36`, from measurements made before that change.**

`shared/styles.css` now carries
`:where(button, input, a, summary, [tabindex]):focus-visible`. `:where()` contributes
zero specificity, so the rule is **(0,1,0)**. Ten `outline: none` declarations across
two app stylesheets defeat it — six in `apps/media-vault/styles.css` (`:73`, `:87`,
`:193`, `:448`, `:559`, `:924`) and four in `apps/filament-forge/styles.css` (`:126`,
`:153`, `:562`, `:984`). Four of the ten are (0,1,0) and win on load order alone;
the rest are (0,1,1) and win on specificity. `apps/character-creator/styles.css:167`
does the same thing inside the app the ring was written for.

So today a keyboard user gets a visible ring on buttons and links, and **nothing at
all on any input, select or textarea, in any of the four apps.**

**Proposal:** raise the shared rule to (0,2,0) with a doubled pseudo-class —
`:where(button, input, select, textarea, a, summary, [tabindex]):focus-visible:focus-visible`
— which beats (0,1,1) without `!important` and without touching an app stylesheet.
**Posture: shared stylesheet only, no app edits, no new token.** Measured to land the
ring on all eleven MediaVault controls and all seven FilamentForge controls.

**It carries one regression that has to be handled in the same change.** The ring
block's third declaration is `border-radius: var(--radius-sm)`. At (0,1,0) it loses
harmlessly; at (0,2,0) it wins, and MediaVault's joined search box splits visibly on
keyboard focus — `#searchInput` goes from `3px 0 0 3px` to `3px`, and
`.search-field-select` animates the change because `apps/media-vault/styles.css:89` is
`transition: all var(--transition)`. **Drop the `border-radius` line when raising the
specificity, or keep it app-local.** Deleting the ten `outline: none` rules instead is
NOT an alternative: with no app rule, `select` and `textarea` fall to the UA default,
measured as `outline: auto 1px rgb(16,16,16)` — a near-black hairline on a near-black
ground, which is the exact failure `F16` and pick3cut5 both exist to fix.

**Evidence:** post-promotion cascade built from the real stylesheets in load order and
driven with `Input.dispatchKeyEvent` Tab through CDP so `:focus-visible` genuinely
matched, 2026-09-10; `getComputedStyle` read for every control; line numbers read the
same day at `fbfed8d`.

**Confidence:** high on the cascade, the ten line numbers and the measured fix — all
three were rendered rather than reasoned. Medium on completeness: the probe drove the
real stylesheets against synthetic markup, so every selector was exercised but not
every one was confirmed to have a live element behind it on a production page.
Screenshotting the two apps under keyboard focus is what would raise it.

**Ongoing cost:** none beyond the rule itself. A doubled pseudo-class is ugly and wants
the comment to say why, which is cheaper than the `!important` it replaces.

---

**Taken, 2026-09-10 (PR #913). Posture held: shared stylesheet only, no app edits, no
new token.** The selector is now
`:where(button, input, select, textarea, a, summary, [tabindex]):focus-visible:focus-visible`
and `border-radius` is gone from the block — the first of the two remedies this finding
offered, chosen on the measurements below.

**Six corrections. `audit-premise-auditor` found all six before the edit.**

**1. The headline sentence is false for one of the four apps.** It says a keyboard user
gets *"nothing at all on any input, select or textarea, in any of the four apps"*.
<!-- claim-ok: quoting the premise this note corrects -->
pick3cut5 sets no `outline: none` anywhere, so its thirteen `.panel input` controls have
carried the ring since `F16`. Measured before any change, all thirteen read
`solid 3px rgb(217,160,91)`. The correct scope is **three of four apps**.

**2. `apps/character-creator/styles.css:167` is off by one — the rule is at `:168`.**
`:167` is the closing brace of the block above it. Wrong at `fbfed8d` too, so it is not
drift, and **`F36`'s outcome note carries the same wrong number**. Corrected here rather
than by editing that note, because an audit file is a record.

**3. The control counts undercount by roughly half.** This finding says eleven MediaVault
controls and seven FilamentForge ones. Measured against the real pages, with modals
force-unhidden so their controls are focusable: **23** and **12**. The finding's own
Evidence line explains why — the probe drove the real stylesheets against synthetic
markup — but the number is used without that caveat attached.

**4. "Four of the ten are (0,1,0)" conflates declarations and selectors.** Three
*declarations* are (0,1,0); one of them carries two selectors, making four *selectors*.
More usefully: of the fourteen selectors in those ten declarations, only **seven target
`input`** and were being defeated on specificity. The other seven target `select` or
`textarea`, which the old ring never matched at all — they were not defeating anything.
Two different mechanisms, and this finding merged them.

**5. The stated regression is real and it is NOT the only one.** The search box splits
exactly as described. Six further controls also change, and this finding names none of
them: `button.list-action-btn` ×2 in media-vault, `#btnGenerate` in filament-forge, five
`.tile`/`.choice` buttons in pick3cut5, and `.pick` and `.imp-tab` in the character
creator all shift 4px to 3px — invisible. **The one that is visible is the wizard's
`.toggle button` pair**, the *Browse all / Help me choose* control: deliberately square
at `apps/character-creator/styles.css:451-453` inside an `overflow: hidden` wrapper, it
gains 3px corners on focus. **So the change as proposed alters all four apps, not the
two the Proposal names.** The posture holds as a statement about files edited; it was
not a statement about apps affected.

**6. Dropping `border-radius` has a cost of its own, which this finding does not**
**mention.** Roughly eighteen controls across three apps have no radius of their own and
were borrowing that line for their focus corner — seven in media-vault, eight in
filament-forge, three in the character creator. They are square when focused now.

**Why dropping it is still the right remedy of the two offered.** Measured both ways:
raising the specificity *and* dropping `border-radius` cures the search-box split,
removes the `.toggle button` shape change and every 4px→3px shift, and leaves
**pick3cut5 byte-identical** — zero of fourteen focus signatures differ. Keeping the
declaration app-local would have meant an app edit, which the posture forbids.

**Verified after the change, with real `Input.dispatchKeyEvent` Tab through CDP and a
450ms settle before every read** (`.btn` carries `transition: all`, so `outline-color`
animates and an early read returns each element's own `currentColor`):

| app | controls that gained the ring |
|---|---|
| media-vault | 23, every previously ringless input, select and textarea |
| filament-forge | 12 |
| character creator | `#codex-filter`, `#codex-system` — confirming `styles.css:168` was the blocker |
| pick3cut5 | 0 — it already had them |

Every `select` and `textarea` also moved from `outline-offset: 0px` to `2px`, having been
outside the old selector entirely.

**The selector is exactly (0,2,0), confirmed rather than assumed.**
`CSS.supports('selector(...)')` returns true in Chrome 153; the rule beats
`input:focus-visible` at (0,1,1) declared later, ties `.probe:focus-visible` at (0,2,0)
and loses to it on order, and loses to `.a.b:focus-visible` at (0,3,0).

**pick3cut5's duplicate ring is now superseded but every declaration is identical, so
nothing moves.** Its `.panel input:focus { outline-offset: 0 }` at (0,2,1) still wins;
all thirteen `.panel input` measured byte-identical before and after.

**A near-miss worth recording, because nothing in this repo could have caught it.** The
first version of this change shipped a **second `*/`** into the comment above the rule —
one edit rewrote a paragraph and closed the comment, another kept the original
terminator. The comment then ended early, every line after it parsed as garbage, and
**the browser silently discarded the ring rule**: `::selection` was followed straight by
the `@media` block in `document.styleSheets`. All four smoke suites passed, the file was
served correctly by `curl`, and `grep` found the selector exactly where it belonged. Only
reading the rendered CSSOM showed the rule was gone. A balance check —
`(/\\*/g).length === (\\*\\//g).length` over the file — is one line and would have caught
it; there is no such check today and this note is not proposing one.

**One thing left, deliberately.** `apps/character-creator/styles.css:182` refers to this
finding as a bare `F37` in a cross-file comment, which `audit-menu` says should name its
menu — three other menus carry an `F37`. Fixing it would be an app edit and the posture
forbids one, so it is named here rather than done.
---

## Filed by an Impeccable design critique, 2026-09-10

**Method.** A dual-assessment critique (a code-trace design review and the Impeccable
detector, run as isolated sub-agents) plus a live walk on a server of my own —
`wrangler pages dev --port 8801`, main checkout at `35afcbd`, local D1 — on
2026-09-10. Scope was **functionality and ease of use**, not the visual standards
`F34`–`F37` just closed. Every premise below that cites a line was opened on that day;
the ones that were not are marked *to verify when taken*. A separate sweep of every
character-creator menu checked that none of these repeats a finding already taken,
declined or recorded as deliberately unbuilt.

**Nate took all fifteen the same day**, with four decisions that are part of the
proposals below rather than open questions: the sheet **autosaves** (`F38`), the
landing roster shows **only the signed-in player's** characters (`F39`), damage that
overflows armour is **offered, not applied** (`F40`), and campaign rest rates are
**in scope** despite needing a column (`F52`).

The detector's own result is recorded here so it is not re-run for the same answer:
the six page shells are clean, one real finding (`F51`, 10.5px group headings), four
false positives — and markup built in JS is invisible to it, which is nearly all of
this app, so "clean" describes the shells and not the rendered UI.

### F38 — high — Typed sheet edits are discarded by any action that redraws the sheet

The sheet's section inputs are read back out of the DOM only when Save is pressed —
`collectSections()` (`sheet.js:2865`), called from `saveStats()` (`sheet.js:2882`).
Several actions reload or re-render first: `addItem` → `load()` (`sheet.js:2974`),
`addJournal` → `load()` (`sheet.js:2990`), and — per the code-trace review, *to verify
when taken* — `logXp` → `render()` (`:2351`), `claimPicks` → `load()` (`:2392`) and a
sheet-mode power use → `load()` (`:2450`). A half-typed bio, armour M.D.C. or combat
override is overwritten by the stored copy with nothing said. The app's one
`beforeunload` is the wizard's (`app.js:3796`, grep of `apps/character-creator/*.js`,
2026-09-10), so closing the tab loses them too.

**Proposal:** autosave. Each section input saves about 1.5 seconds after the last
keystroke, through the PATCH `saveStats` sends today and carrying its
`expect_updated_at` (`sheet.js:2892`), so two people on one sheet still get the
server's refusal rather than a silent overwrite. Pending edits flush before any redraw
and on `pagehide`. A small status reads saving / saved / refused; a refusal keeps the
typed values on screen and offers to reload the other side's version. The Save button
goes. **Posture: no schema, no new route, the same conflict check; no new gate.**
Nate chose this over "keep edits and warn" on 2026-09-10.

**Evidence:** code read 2026-09-10 at `35afcbd`. **Reasoned from the handlers, not
reproduced in a browser.**

**Confidence:** high on the mechanism — both halves were read. Medium on the list of
redrawing actions being complete; a read of every `load()` and `render()` caller in
`sheet.js` is what raises it, and autosave makes the list matter less.

**Ongoing cost:** more PATCH writes per session, and simultaneous edits now surface as
visible refusals — which is the point, but it is new friction someone will see.

---

**Taken, 2026-09-10 (PR #920). Posture held: no schema, no new route, the same
conflict check, no new gate.** The Save button is gone; the section inputs, the notes
and the pool numbers save themselves — text 1.5 seconds after the last keystroke, a pool
when its field is left, so a pause half-way through typing `14` cannot write `1`.

**Two corrections, both from `audit-premise-auditor` before the edit.**

**1. The list of redrawing actions was about half of them.** Besides the five named, the
inventory filter calls `render()` on every keystroke (`sheet.js:1962`), and *Not now*,
the claim toggles, `proposeVariant`, `flushQueue`, `claimPowers`, `confirmLevelUp` and
`confirmVariant` all redraw. **None of them needed touching**: `render()` now puts
whatever is typed and unsaved into `C.data` before rebuilding, and `load()` saves first
and carries anything it could not save across the reload — one place each, rather than
the per-caller participation `keepEdits()` asked for and why it was retired.

**2. Autosave would have been refused by its own tab.** The finding said the PATCH's
version check meant only two *people* get refused. Seven routes move
`characters.updated_at` — `events.js:80`, `xp.js:25`, `picks.js:88`,
`power-picks.js:87`, `grants.js:61`, `level-confirm.js:148`, `variant.js:137` — and the
sheet learned the new value only from its own PATCH. **So the Save button was already
being refused after any damage, stepper or rest in play mode.** Rather than widen seven
responses, a refusal re-reads the character and compares only the fields being saved
with what they held when editing began: untouched by anyone else, it retries against the
new version; changed, the status offers **Keep mine** or **Use theirs** with the typed
values still on screen. Only edited fields are sent now — Save sent every pool with
every bio edit.

**Measured on `wrangler pages dev --port 8801`, local D1, local character 1,
2026-09-10**, driving the real handlers from the page and reading the result back from
the API:

| check | result |
|---|---|
| type into Height | status *Unsaved changes…* → *All changes saved*; stored |
| type into Weight, then `render()` at once | the rebuilt input still held it; stored |
| type into Money, then `load()` at once | saved before the refetch; stored |
| S.D.C. −1 through the events route, then type into Age | network log: `POST events 200`, `PATCH 409`, `GET 200`, `PATCH 200` — the retry, not a lucky second |
| type into Environment while another writer changes the bio | *Not saved: Bio changed somewhere else* with both buttons; the typed text stayed; *Keep mine* stored it |

Character 1 was restored to its snapshot afterwards. One `pool` event from the S.D.C.
check remains in its local session log.

**Two smoke checks pinned the Save button's source text** —
`rendered-ui.mjs`'s *"the sheet sends the version it loaded"* and *"and asks before
throwing away what is on screen"* matched `body.expect_updated_at = C.data?.updated_at`
and `confirm(msg)`, and both failed when that code went on purpose. They pin the intent
now: version sent, conflict answered with Keep mine / Use theirs rather than a reload
over the typing. A third pins the per-field retry. All three were proven by running
their patterns against `HEAD:sheet.js` (fail) and this branch (pass).

**Adding an item had regressed.** `docs/wizard-and-sheet.md` has said since PR #27 that
it refreshes only the inventory rows; `addItem` called `load()`. It refreshes the rows
again, and reloads only when it also wrote a journal entry. The doc's section now
describes autosave.

**Not covered, deliberately:** text typed into the journal, add-item and level-up forms
is still rebuilt by a `render()`. Those are actions, not fields, and keeping their text
across a render would re-fill a form its own submit had just consumed unless every
submit opted out — the per-caller shape this finding's fix avoids. **Dropped rather than
deferred.**

**Found while taking this, and carried by `F51`:** `styles.css:408-409` hold a raw
`0x15` byte where the `\25B8` / `\25BE` escapes belong — something read `\25` as an
octal escape in `14b5ab4` — so the level-row disclosure marks draw a control character
and the letters `B8` / `BE`.

### F39 — high — The character creator has no home: the roster lives on wizard step 1, and a draft hides it

The characters and campaigns list is drawn by `renderSystem()` (`app.js:780-828`), the
wizard's first step. When a draft exists, `renderDraftOffer()` (`app.js:545-561`)
replaces that step with a Resume/Discard choice — seen live on 2026-09-10, where the
landing page carried those two buttons and nothing else. And selecting a class card is
enough to create a draft: `pickClass` sets `S.rcc` (`app.js:1174`), which is all
`draftWorthSaving()` asks for (`app.js:441-443`), so reading one class brings the gate
back on the next visit.

Three more gaps around it, each read on the same day:

- `GET /characters` filters by `campaign_id` and nothing else
  (`functions/api/character-creator/characters.js:31`), so *Existing characters* is
  every character on the site.
- The campaign list is `gmCampaigns()` (`app.js:795`), so a player is never shown the
  campaigns their characters are in. The sheet's header links codex, creator and
  workshop (`sheet.html`, *to verify the line when taken*), and `sheet.js` contains no
  `campaign.html` link (grep, 2026-09-10) — while the campaign page admits members
  (`campaign.js:40`).
- `dashboard.html` and `campaign.html` opened without a `campaign_id` end on an error
  (`dashboard.js:141`; the campaign page read "No campaign_id in the URL." live).

**Proposal:** (a) a home view ahead of the wizard — **Your characters**, the signed-in
player's only (Nate's choice, over folding the others away), each with Sheet and
▶ Play; **Your campaigns**, for a GM and a player alike; the draft as a card with
Resume and Discard; and *New character* to start the wizard. (b) the filter server-side,
`GET /characters?mine=1`, so the 200-row page cannot push someone's own character off
it. (c) no draft until the player leaves the class step, rather than on selecting a
card. (d) a Campaign link in the sheet header when the character has one. (e) the two
campaign pages list your campaigns instead of erroring when no id is given.
**Posture: no schema; one query parameter on an existing route.**

**Evidence:** live walk on 8801 and code read, 2026-09-10.

**Confidence:** high.

**Ongoing cost:** one more view; the step-1 lists move rather than duplicate.

---

**Taken, 2026-09-10 (PR #921). Posture held: no schema; one query parameter on an
existing route.** All five parts, as written:

- **(a)** The page opens on a home view. The draft is a card on it — *Resume this build*
  / *Discard it*, with `F26`'s one-draft sentence kept — not a gate in front of it.
  **Your characters** lists the caller's own, each with its sheet and ▶ Play; **Your
  campaigns** lists every campaign the caller runs *or has a character in*, each to its
  dashboard with its notes beside it; **+ New character** starts the wizard and asks
  before discarding a draft. Going home mid-build shows the build as *Build in
  progress* with *Continue*; the saved-character screen and the wizard's header both
  gain a way back. Step 1 no longer carries the lists.
- **(b)** `GET /characters?mine=1`, filtered in the query, and combinable with
  `campaign_id`.
- **(c)** `draftWorthSaving()` also requires `S.step > ST.RACE`, so selecting a class card
  no longer creates a draft; `confirmRace()` is the step's only exit, as the premise
  audit confirmed.
- **(d)** The sheet header gains *campaign*, to the character's dashboard, added once the
  character has loaded; *← character creator* reads *← your characters*.
- **(e)** `dashboard.html` and `campaign.html` opened without a `campaign_id` list the
  caller's campaigns instead of an error. The list is one shared classic script,
  `js/campaign-list.js`, because `app.js` is a module and the other two are not.

**Membership is derived from the caller's own characters**, not asked of the server:
`GET /campaigns` returns every campaign with a `can_join` flag that also counts open
ones, so it cannot answer "which am I in".

**Measured on 8801, local D1, 2026-09-10.** `?mine=1` as `dev@localhost`: 1 of 1, all
theirs. As `nobody-f39@example.com`, sent in the Access header: 0 with the filter, 1
without it — the exclusion, which the regression suite cannot see on its own because
every call there is one caller, so it gains the same second-identity check. The home
view, Resume → *your characters* → *Build in progress* → *Continue* back to step 5, both
id-less pages and the sheet's new link were all driven in the browser.

**The first screenshot caught what no check had.** Emptying the rail left the sticky
bar's padding and border standing, a blank band about 100px tall under the header at
both widths; the home view now hides the bar. `screenshot-before-declaring-done` again.

**By decision, not omission:** a G.M.'s *Your characters* holds only their own
characters; their players' are one click away on the campaign dashboard.

### F40 — medium — Play mode cannot put a hit on armour or a vessel location

`quickDamage()` leaves armour out on purpose — *"which armour absorbed a hit is a
table decision, and its M.D.C. is edited on its own card"* (`sheet.js:717-720`). That
card is a sheet-lens input read by `collectSections()` (`sheet.js:2873-2878`), so an
armour hit means leaving play mode, typing, and saving: no event, no undo, no offline
queue. The events route accepts pool fields and item notes only (`events.js:20`,
`:53`, `:108-117`).

**Proposal:** a *Hit to* choice beside Damage — Body (the cascade as it is), each
armour entry, each vessel location — so the table decision is one tap and not a mode
switch. Armour stops at 0; any excess is shown as *N not absorbed* with an **Apply to
body** button and is **never applied automatically** (Nate's choice: an S.D.C. wearer
hit by M.D. is a conversion this app should not guess). The events route gains an
armour change carrying `from`/`to`, recorded as a `damage` event so it is undoable and
queueable. **Posture: extends one route; no schema if armour and vessel locations live
in stored JSON on existing rows — to be confirmed when taken.**

**Evidence:** code read 2026-09-10.

**Confidence:** medium — where armour and vessel locations are stored was not read, and
that decides the route's shape.

**Ongoing cost:** a third change type in the events route and in undo.

---

**Taken, 2026-09-10 (PR #927). Posture held: extends one route; no schema** — confirmed
before the edit: armour is the `characters.armor` JSON array (`db/schema.sql`), vessel
damage is `character_vehicles.mdc_current` keyed by location, and `play_events.payload`
is JSON, so neither change type needed a column.

**Two corrections, both from `audit-premise-auditor`.**

**1. "A third change type" is two, in two routes.** Armour and a vessel location are
different rows — one a JSON array on the character, the other a JSON object on a second
table — so the events route gained **two** change types, and `events/undo.js` gained both,
since it reversed only pools and item notes. The *Ongoing cost* line above understates
it by one of each.

**2. "Its M.D.C. is edited on its own card" was true of armour and not of vessels.**
<!-- claim-ok: quoting the premise this note corrects -->
Armour went through the sheet's PATCH on Save; a vessel location already had its own
route (`vehicles/[vehicleId].js`). Both now go through the events route from play mode,
and the vessel route stays for the card's own inputs.

**What shipped.** A *Hit to* picker beside Damage — the body, each armour piece, each
vessel location with a printed maximum — drawn only when there is somewhere other than the
body. Body is unchanged: `quickDamage` became a switch, and the cascade moved to
`bodyDamage`, so `play-flow.mjs`'s calls still land where they did. **Armour stops at 0
and offers the rest** — *Apply N to body* on the roll bar, retired by the next result —
never applies it (Nate's call). A vessel location goes below zero, as its route always
allowed; its excess is nobody's H.P. Each change carries the value it replaced —
`raw_from` for armour, which is stored as typed text and may have been blank, `absent`
for a location with no damage yet — so undo restores **exactly**, and both queue on a
drop, replayed unguarded like ammo.

**Measured on 8801, local character 1, 2026-09-10**, with a test plate (blank of 50)
added and removed again: the picker offered *Test Plate (50/50)*; 20 took it to 30 and
repainted both the input and the picker; 40 stopped it at 0 with *absorbed 30; 10 not
absorbed* and **Apply 10 to body**; applying took S.D.C. 11 → 1. Three undos walked it
back — S.D.C. 11, armour 30, armour **blank** — and the server agreed. The character was
restored to no armour, S.D.C. 11, H.P. 14.

`regression.mjs` now drives both halves through the real routes: armour hit, undo back to
blank rather than to the 50 the hit started from, a refused index; and a catalog vessel
added, a location hit, undo back to *absent* rather than to its maximum, a refused
location. **The vessel half was not walked in the browser** — no local character carries
one — so the regression run is its only exercise.

`docs/campaign-and-play.md` says so, and two of its sentences that `F44` and `F45` had
made false are corrected in the same edit: *"equipping is the sheet lens's job"* and a
roll bar with no history.

### F41 — medium — A weapon card's Strike ignores the weapon's own bonuses

`weaponCardsHtml(w, combat.strike)` (`sheet.js:1137`) hands one bonus to every card,
and each card's Strike rolls with it (`sheet.js:1060`). The conditional bonuses are
listed on the same sheet under *Conditional bonuses — these apply only in the
situation named* — seen live on local character 1, e.g. *Sword with a sword +5 strike,
+4 parry* — and never reach a roll.

**Proposal:** on each weapon card, a chip per conditional strike bonus, off by
default, remembered per item on the device; the roll bar shows the breakdown.
**Posture: opt-in on every roll, never automatic** — which keeps *"only in the
situation named"* true.

**Evidence:** code and live DOM, 2026-09-10.

**Confidence:** high for chips built from the conditionals the sheet already lists.
Matching a gear item to its W.P. automatically is **not** proposed; nothing maps one to
the other today, and a guess would put a wrong bonus on a roll.

**Ongoing cost:** one localStorage key per character.

---

**Taken, 2026-09-10 (PR #926). Posture held: opt-in on every roll, never automatic.**
Each equipped weapon card carries a chip for every conditional bonus that has a strike
value — the rows the sheet already prints under *Conditional bonuses* — off until the
player lights one. The state is remembered per weapon on the device, keyed by skill and
condition rather than by position, so a reordered list cannot light the wrong chip.
Strike reads it when pressed: the base bonus plus whatever is lit, with the lit chips
named in the roll's label, so the bar says what the total was made of.

**One thing the first walk turned up and this PR fixes.** W.P. Sword carries two strike
bonuses — +3 throwing a sword, +5 with one — and both chips read *Sword*; only the tooltip
told them apart, and a phone shows none. Where two strike bonuses share a skill, the chip
now names its condition as well.

**Measured on 8801, local character 1, 2026-09-10**, with *Daggers and Knives* drawn:
five chips, none lit, each carrying its condition as a title. On a forced 10, Strike
rolled *Daggers and Knives — strike*, 10 + 0 = 10. With *+1 Fencing* lit — `aria-pressed`
true, stored under that weapon — it rolled *Daggers and Knives — strike (+1 Fencing)*,
10 + 1 = 11, and the bar printed the breakdown. Lit across a reload. With the labels
fixed, the two Sword chips read *+3 Sword (throwing a sword)* and *+5 Sword (with a
sword)*, and the +5 lit rolled *… (+5 Sword (with a sword))*, 10 + 5 = 15. The dagger was
put back and the stored state cleared afterwards.

**What the chips do not do, by the finding's own terms:** nothing lights one for you.
Fighter Combat and Robot Combat chips appear on a dagger too, because nothing maps a gear
row to a W.P. or a situation, and a guess would put a wrong bonus on a roll.

### F42 — medium — A pending level-up is invisible until someone logs XP

`C.nextThreshold` and `C.proposal` start null (`sheet.js:62`) and are set only inside
`logXp` (`sheet.js:2349-2350`); *Next level at* renders only when the first is set
(`sheet.js:1690`). *Not now* nulls the proposal (`sheet.js:1988`) and nothing brings it
back until XP is logged again. So a character with enough XP opens with no sign of it.

**Proposal:** the character GET returns the next threshold and whether the XP already
qualifies; the sheet shows *N XP to level L+1* on load and, when it qualifies, a banner
that opens the level-up panel. *Not now* hides it for the visit, not for good.
**Posture: extends one GET; no schema.**

**Evidence:** sheet code read 2026-09-10. That the GET returns neither field is the
code-trace review's search of `characters/[id].js`, **not repeated — to verify when
taken.**

**Confidence:** medium until that GET is read.

**Ongoing cost:** one more field in a response.

---

**Taken, 2026-09-10 (PR #922). Posture held: extends one GET; no schema.** The premise
the finding marked *to verify* held: `characters/[id].js` returned no threshold and no
readiness, and the `audit-premise-auditor` found none by grep before the edit.

- The character GET returns `next_threshold` and `level_up_ready`, from `xpTableFor`,
  `levelForXp` and `thresholdFor` on the composed class the GET already builds — the
  three helpers `xp.js` uses, so the two routes cannot disagree about a threshold.
- The sheet sets both on load. *Next level at* now appears on every sheet, with how
  far there is to go.
- When the XP already pays for a level, a banner reads *Level up ready* with **Review the
  level-up**, which asks the XP route for the proposal with `{delta: 0}` — the re-check
  Log XP always offered, without the player having to know to type 0.
- **Both** *Not now* buttons — the banner's and the level-up panel's — put the offer
  away for the visit only; a reload brings it back, because the level is still owed.

**Measured on 8801, local character 1, 2026-09-10.** Before any change the GET had
neither field. At 0 XP it returned `level_up_ready: false`, `next_threshold: 225921`;
with XP set to 225921 through the real route, `true`. On the sheet the banner read
*225921 XP pays for level 13*; Review opened the proposal to level 13; *Not now* cleared
both; a reload brought the banner back. XP was restored to 0 afterwards.

`regression.mjs` gains the pair: owed after crossing a threshold, and **not** owed once
the level is confirmed. The first was shown to fail against the pre-F42 server, whose
GET carried no such field.

**One interaction worth knowing:** `{delta: 0}` still moves `updated_at`, like every XP
write. Under `F38` that costs a sheet with pending edits one per-field retry, not a
refusal.

### F43 — medium — The Skills step is 13,978px of checkboxes

Measured live on local draft 19 (a Gunfighter, step 5) at 1280px, 2026-09-10: the
document is **13,978px** tall and carries **811 checkboxes** in **32 groups**. The
34-item W.P. list is drawn in full **twice**, once for the *pick 2* group and again for
*pick 1*, and the Pilot pick draws every pilot skill.

**Proposal:** a satisfied pick group collapses to its chosen skills and a *Change*
button; an unsatisfied one gets the filter box the related-skills list already has
(`Picker.inputHtml`, `app.js:2409`) and shows a short list until filtered or expanded.
The automatic class skills fold to a one-line summary. **Posture: presentation only —
nothing about what may be picked, or the rules behind it, changes.**

**Evidence:** live DOM measurement, 2026-09-10, one class.

**Confidence:** high on the numbers for that class; other classes differ in size, not
in shape.

**Ongoing cost:** a collapsed/expanded state per group, held in memory and not in the
draft.

---

**Taken, 2026-09-10 (PR #923), and WIDENED — the finding blamed the wrong part of the
step. Posture held: presentation only — nothing about what may be picked, or the rules
behind it, changes.**

**As written.** A satisfied "Pick N" group folds to its choices and **Change**; reopened,
it offers **Done**. An unsatisfied one gets the filter box the related list has
(`Picker.inputHtml` / `Picker.wire`) and a short list of eight until filtered or **Show
all N**. The automatic class skills fold to one line — *16 skills granted by the class ·
12 with a note* — so a note is never out of sight without saying so.

**That moved the number very little, and the measurement is the correction.** The three
pick groups held **117** of the step's 811 checkboxes. Taken as written, on the same draft
at the same width: **13,978px / 811 → 11,357px / 718.** The rest were in the related and
secondary lists, which drew every skill of every category at once — 323 related, and the
whole catalog for secondary. The finding's *Evidence* line measured the whole step and its
proposal named only the groups; the gap between the two is where the wall was.

**So every category in those two lists folds too** — 32 headings, each a button with its
count. A category opens by itself when the filter has text, so typing still reaches
everything, or when it holds a skill already chosen, so a tick is never hidden. The fold
state lives in `S.groupUi` beside the groups', not in the draft, and resets when the class
changes.

**Measured on local draft 19 (a Gunfighter, step 5) at 1280px, 2026-09-10:**

| | height | checkboxes |
|---|---|---|
| before | 13,978px | 811 |
| the finding as written | 11,357px | 718 |
| widened | **2,439px** | **24** |

Opening *Communications* draws its 19; *radio* in the related filter shows *3 of 323*
with their categories open by themselves; a group given two picks folds to *✔ W.P.
Rifles, W.P. Shotgun · Change*, and Change reopens it with Done. The draft was restored
byte for byte by a guarded PUT after each walk.

### F44 — medium — Play mode has no fast path: fixed amounts, no keys, one visible roll

The amount chips are 1, 5, 10 and 20 (`sheet.js:1118`); a 37-point hit is several
presses and several events, and ↶ reverses one. The app's keyboard handling is Enter in
the picker (`js/picker.js:92`) and the catalog's rows (`catalog.js:648`) — a grep for
`keydown` on 2026-09-10 found those two. The roll bar shows `C.lastRoll` (`sheet.js:416-434`)
while `C.rollLog` keeps fifty (`sheet.js:405-411`), and a natural 20 or 1 is not marked.

**Proposal:** (a) a number field beside the chips, where Enter applies Damage; (b)
play-mode keys when no field has focus — `D` damage, `U` undo, `P` percentile, `N` next
attack, `R` new round, `?` for the list; (c) tap the roll bar to open the last ten
rolls; (d) mark a natural 20 and a natural 1 on any d20. **Posture: client only; no new
event kind, no rule change — a natural 20 is labelled, not given an effect.**

**Evidence:** code read and grep, 2026-09-10.

**Confidence:** high.

**Ongoing cost:** a key map to keep clear of browser and screen-reader shortcuts.

---

**Taken, 2026-09-10 (PR #924), in one PR with `F45` and `F50`** — all three change
`playControlsHtml` and the play CSS, and Nate left the grouping to judgement. **Posture
held: client only; no new event kind, no rule change — a natural 20 is labelled, not given
an effect.**

- **(a)** A number field beside the chips. Any whole number above zero becomes the amount,
  for Damage and the steppers alike; a chip clears it; Enter in it applies Damage.
- **(b)** `D` damage, `U` undo, `P` percentile, `N` next attack, `R` new round, `?` the list
  — in play mode only, never while a field has the focus, and never with a modifier. The
  line naming them shows where there is a fine pointer to press them with, and anywhere
  after `?`.
- **(c)** The roll bar carries **Last N**, opening the last ten rolls newest first.
- **(d)** A natural 20 or 1 is labelled on the bar, in the two tones this file already
  measured against the bar's ground, and in the logged note *after* the verdict — so
  `endSession`'s count of `— pass` / `— fail` reads the notes it always did.

**Measured on 8801, local character 1, 2026-09-10.** Typing 7 turned every chip off, and
Enter took S.D.C. 11 → 4 as ONE event, not two presses of 5 and 2; `U` put it back to 11.
`N` and `R` moved the melee counter; `P` rolled; `P` typed into the notes field rolled
nothing. A forced natural 20 read *d20 20 + 2 = 22 natural 20* and logged
*· natural 20*. The history opened with three rolls. At 375px the key line is
`display: none`. The walk left one damage event, its undo and a few roll events in that
local character's log.

**Two smoke checks tripped, and neither was the change being wrong.** A local variable
named `box` matched the guard that keeps `js/sheet-layout.js`'s helpers out of `sheet.js`
— renamed. And *"the roll bar reads the null target"* read `rollBarHtml`'s body alone,
where the per-roll rendering no longer lives: it now reads `rollLineHtml`, which the bar
calls for every roll, and the guard that each body the checks read can be found now names
five, so a moved signature still fails loudly instead of passing on nothing.

### F45 — low — Drawing a carried weapon means leaving play mode

An unequipped weapon gets a line reading *"equip on the sheet lens for cards"*
(`sheet.js:1067-1068`): out of play mode, find it in Gear, tick it, come back.

**Proposal:** a *Draw* button beside each carried weapon that sets it equipped through
the item PATCH the Gear tab uses, and the card appears. **Posture: same route as the
Gear tab's equip control; no schema.**

**Evidence:** code read and live DOM, 2026-09-10.

**Confidence:** high; the PATCH helper's line is *to verify when taken*.

**Ongoing cost:** none.

---

**Taken, 2026-09-10 (PR #924, with `F44` and `F50`). Posture held: the Gear tab's own
equip PATCH; no schema.** Each carried weapon gets a **Draw** button beside its name.

**One correction, from `audit-premise-auditor` before the edit:** *"and the card appears"*
was not true of the helper alone. `patchItem` (`sheet.js`) repaints the inventory rows and
nothing else, so the weapon cards now sit in their own `#play-weapons` block and are
repainted after it. <!-- claim-ok: quoting the premise this note corrects -->

**Measured on 8801, local character 1, 2026-09-10:** two carried weapons, two Draw
buttons; Draw on *Daggers and Knives* took the section from 0 cards to 1. It was put back
in the bag afterwards.

### F46 — medium — The campaign dashboard is read-only, so running a session means a tab per character

`dashboard.js` loads once (`:12-33`) and draws the roster as text (`:46-53`): no
refresh, no controls. A GM tracking five characters opens five sheets.

**Proposal:** for the GM only — each roster row gets its pool bars with −, + and Damage,
posting through the events route so every change lands in that character's own log and
undo; the roster refreshes when the tab regains focus; **Award XP to party** applies one
amount to each character through the XP route. **No initiative tracker** — party-wide
initiative is recorded as deliberately unbuilt in `docs/campaign-and-play.md`, and this
does not reopen it. **Posture: GM-only controls, existing routes only.**

**Evidence:** code read 2026-09-10.

**Confidence:** medium — the XP route's shape was not read.

**Ongoing cost:** a second place that writes play events, which must stay in step with
the sheet's.

---

**Taken, 2026-09-10 (PR #930). Posture held: GM-only controls, existing routes only.**
For the G.M. — and only for them, on `D.isGm` — each roster row carries its pools with −
and + at a chosen amount, a **Damage**, and ↶ for that character's last change; a toolbar
sets the amount and **awards XP to the party**. Every press goes through the character's
own events or XP route, so it lands in *their* session log and undo exactly as a press on
their sheet would, with the note saying the G.M. made it. The roster refreshes when the
tab comes back into view, repainting only its rows. No initiative tracker —
`docs/campaign-and-play.md` records it as deliberately unbuilt and this does not reopen it.

**The *Ongoing cost* above is paid down rather than accepted.** The sheet's damage rule —
M.D.C. beings on M.D.C., everyone else S.D.C. first and the rest to H.P. — moved into
`js/derive.js` as `damageCascade`, and both the sheet's `bodyDamage` and the dashboard's
Damage call it. Two copies of a rule are two rules; there is now one, and
`play-flow.mjs`, which loads `derive.js` among its fixed script list, still drives the
sheet's Damage through it.

**Premises that held** (`audit-premise-auditor`): the XP route takes `{delta}` or `{total}`
and proposes rather than applies a level-up; a G.M. may write any character in their
campaign; party initiative is on the deliberately-unbuilt list.

**Measured on 8801, local campaign 2, 2026-09-10**, character 1 snapshotted and restored
(H.P. 14, S.D.C. 11, P.P.E. 1, XP 0):

| press | result |
|---|---|
| H.P. − at 5 | 14 → 9, logged on that character as *G.M.: HP −5*, actor the G.M.; ↶ back to 14 |
| Damage at 5 | S.D.C. 11 → 6 through `derive.damageCascade`; ↶ back to 11 |
| Award XP to party, 100 | *Awarded 100 XP to 1 of 1*; reversed with −100 |
| a pool moved behind the page's back, then refresh | the row repainted P.P.E. 1 → 3 and a half-typed G.M. note survived |

**The refresh needed a second measurement, and the first was the pane's fault.**
`refreshRoster` returns early while the page reports itself hidden, and the Browser pane
reports hidden; with `visibilityState` forced visible it repainted as above.

**Two layout defects the first screenshot found, both fixed here.** At 375px the page
scrolled **160px** sideways: five columns and the new controls do not fit a phone. A
scrolling wrapper alone changed nothing — measured, it came out exactly as wide as the
table — because a grid item's minimum width is its content's, so the roster panel
stretched and took the page with it. `.dash-grid > * { min-width: 0 }` let the panel be
narrower than its table: **page overflow 0**, the table scrolling inside a 273px box. At
desktop width the controls fit their cell with 133px to spare.

`docs/known-limitations.md`'s file-size table had `dashboard.js` at ~140 lines; it is
~300 now, and the smoke check that holds those figures to 25% said so.

### F47 — low — The party stash takes free text only, so claimed loot can never be a weapon card

The stash endpoint accepts a gear-catalog `item_id` or a `custom_name`
(`functions/api/character-creator/campaigns/[id]/items.js:58-61`), and the stash's add
form sends free text (`campaign.js`, *line to verify when taken*). A weapon card needs
a catalog match, so looted weapons stay text forever.

**Proposal:** the gear picker in the stash's add form, with free text kept as the
fallback. **Posture: UI only; the endpoint already takes the id.**

**Evidence:** endpoint read 2026-09-10; the form's shape is the code-trace review's.

**Confidence:** medium until the form is read.

**Ongoing cost:** none.

---

**Taken, 2026-09-10 (PR #928). Posture held: UI only; the endpoint already takes the id.**
The stash's add form offers the gear catalog first — a filter box and a select, loaded
for the campaign's own system the first time the tab is drawn — and keeps free text as
the fallback for loot no book lists. It sends `item_id` when a catalog row is chosen,
which `campaigns/[id]/items.js` has always accepted. `D.gear`, declared on this page
since it was written and never filled, finally holds something.

**One correction, from `audit-premise-auditor`:** *"claimed loot can never be a weapon
card"* overstated it. <!-- claim-ok: quoting the premise this note corrects --> A catalog
row in the stash already copies its `gear_slug` onto the character when claimed
(`campaigns/[id]/items/[itemId].js`). What was true is that the form could only send
free text, so no stash row ever WAS catalog-linked — the endpoint's half had simply never
been reachable.

**Measured on 8801, local campaign 2 (Palladium Fantasy), 2026-09-10:** the tab loaded
544 gear rows and the select showed *300 of 544* until filtered — a stated cap, so a
phone is not handed a 544-option list; *dagger* narrowed it to *1 of 1* with the caret
still in the filter. Added from the catalog, the row came back as *Daggers and Knives*,
slug `daggers-and-knives`; a typed *F47 test crate* came back as a custom item exactly as
before. Both were removed afterwards and the stash is empty again.

**Not taken, and recorded so it is not mistaken for done:** the auditor also found that an
unknown `item_id` sent with no name fails the table's CHECK as a 500 rather than a 400.
This form only ever sends an id it was handed by `/items`, so it cannot reach that path,
and fixing a server response no client produces is dropped rather than deferred.

### F48 — low — The codex has no Skills or Classes

The codex's tabs are Spells, Psionics, Gear and Vessels (live, 2026-09-10). A class can
be read only inside the wizard, where selecting it saves a draft (`F39`).

**Proposal:** a Skills tab (category, base %, per level, source) and a Classes tab
showing each class's summary read-only, from the catalog data the wizard already
fetches. **Skill descriptions are out of scope** — the catalog carries none, and adding
them is a column and an import, which is its own decision. **Posture: read-only; no
schema.**

**Evidence:** live page, 2026-09-10.

**Confidence:** high.

**Ongoing cost:** two more tabs that must follow the catalog's fields as they change.

---

**Taken, 2026-09-10 (PR #929). Posture held: read-only; no schema.** Two sections on each
side of the codex, appended after Vessels so the default tab and every `#spells` link
already sent keep opening where they did.

**One correction, from `audit-premise-auditor`:** *"from the catalog data the wizard
already fetches"* was wrong about delivery. <!-- claim-ok: quoting the premise this note corrects -->
The codex loads each section through its own `codex?section=` route, not the wizard's
boot calls, and the wizard's class list is the ~750KB parsed markdown — so both tabs
needed a **server section of their own**, which is what shipped. The data itself was
enough.

- **Skills** — the catalogs route's projection less the bonuses a picker needs and a
  reader does not. `systems` is a JSON list; one listed system becomes the codex's
  `system`, anything else reads as unrestricted, the way a NULL system reads everywhere
  else in that route. The catalog has never held skill descriptions, so a section flag
  drops the *"No description imported yet"* line and the *"with text"* count, which would
  both have read as an import still to do.
- **Classes** — every published class as a **summary**: name, O.C.C. or R.C.C., system,
  book, and a lore excerpt of at most ~700 characters, parsed through the same cache the
  classes route uses. The markdown never travels.

**Measured on 8801, local D1, 2026-09-10.** The index counted 371 skills and 250 classes
and each section returned exactly that many — the check the tab labels rely on. Classes:
**174.2 KB raw, 57.5 KB gzipped**; skills **55.6 KB raw, 5.2 KB gzipped** — both well
inside the ~250 KB gzipped line the route's own comment sets for revisiting. In the page,
`#skills` opened the Skills tab, *radio* filtered to 3 of 371, and an opened skill showed
its base and per-level with no import line; the Classes tab marked each row O.C.C. or
R.C.C., the Rifts filter took it to 210 of 250, and *Amphib* opened to its type, system
and lore. `regression.mjs` checks both counts against the index and that no class row
carries markdown.

**The README's codex row was already wrong before this change**: an unknown section was
*"a 400 naming the five"* while the route knew six, `vehicles-index` included. It now
says *"naming every section"* rather than trading one stale count for another.

### F49 — low — The related-skills allowance sentence contradicts itself

`app.js:2407-2408` reads *"a character at level three is measured against
${relatedAllowance(effective, S.level)} picks rather than ${relatedCfg.count}"* — the
example names level three and computes at the character's current level. A level-1
Gunfighter reads *"measured against 4 picks rather than 4"* (live, 2026-09-10).

**Proposal:** compute the example at level three. **Posture: copy only.**

**Evidence:** code and live page, 2026-09-10. **Confidence:** high. **Ongoing cost:** none.

---

**Taken, 2026-09-10 (PR #925, with `F51`). Posture held: copy only.** One correction to
its own proposal: *"compute the example at level three"* would still read *"4 picks
rather than 4"* for any class whose first related-skill grant comes after level three.
The sentence now names the **lowest level the class's schedule grants at**, and computes
the allowance there — so the two numbers it compares always differ.

**Measured on 8801, local draft 19 (a Gunfighter), 2026-09-10:** *"…so a character at
level 2 is measured against 5 picks rather than 4."* The draft was restored byte for byte
afterwards.

### F50 — low — On a phone, play mode's controls push every tab down, and Rest is a small target below the fold

Measured at 375×812 on local character 1, 2026-09-10: Damage, ↶ and End session at
y=680; Percentile at y=829; **Rest at y=1271 and 27px tall**; the first save roll at
y=1471. The controls sit outside the tab panels, with Weapons open by default
(`sheet.js:1070`), so every tab starts below them.

**Proposal:** each play section remembers open or closed per device, and the Rest
summary gets a 44px minimum height. **Posture: CSS and one localStorage key.**

**Evidence:** live DOM measurement, 2026-09-10. **Confidence:** high. **Ongoing cost:** none.

---

**Taken, 2026-09-10 (PR #924, with `F44` and `F45`). Posture held: CSS and one
localStorage key.** Weapons and Rest remember whether they were open, per device
(`cc-play-secs`); Weapons still opens by default the first time. The section summaries
went from 8px to 12px of padding, and the Rest button gained a 44px floor.

**Measured on 8801, 2026-09-10:** Weapons closed, reloaded, still closed; the Rest button
**44px** tall where it was 27; a section summary **45px**. The stored key was cleared after
the walk.

### F51 — low — Three small accessibility and legibility gaps

- ↶ has no accessible name (`sheet.js:1123`) — a screen reader announces a glyph.
- `.power-group` headings are 10.5px (`styles.css:992`), the detector's one real
  finding on 2026-09-10; they head every spell and psionic group.
- `styles.css:182` names a bare `F37` in a cross-file comment, recorded in `F37`'s own
  note as named rather than done.

**Proposal:** an `aria-label` on ↶, the group headings to 12px, and the comment to
`UI-AUDIT F37`. **Posture: markup, CSS and a comment.**

**Evidence:** code read and detector run, 2026-09-10. **Confidence:** high. **Ongoing cost:** none.

---

**Taken, 2026-09-10 (PR #925, with `F49`). Posture held: markup, CSS and a comment** —
all three, plus the fourth item `F38`'s note handed here.

- ↶ carries `aria-label` and `title` *"Undo the last change"* — measured on the live sheet.
- `.power-group` is 12px, measured computing to 12px on *Spells — Level 1*.
- `styles.css`'s cross-file comment now reads *"UI-AUDIT F37"*.
- **The two raw `0x15` bytes are gone.** `14b5ab4` had turned the `\25B8` / `\25BE` escapes
  into a control character plus the letters `B8` / `BE`, so the level-row disclosure marks
  on the wizard's Advancement step (`app.js`, the `lvl-row` rows) drew garbage. Restored by
  a script that matched each byte exactly once; `styles.css` now carries **no** control
  characters at all. Checked by rendering a probe row against the live stylesheet: closed
  draws `▸` (U+25B8), open draws `▾` (U+25BE). **Not seen on a real Advancement row** —
  neither local character nor draft reaches that step — which is why the probe was used.

### F52 — low — Rest rates are remembered per device, so a new phone starts blank

Rates are stored under `cc-play-rest-<id>` in localStorage (`sheet.js:1168-1176`), and
the app ships no default on purpose — the books' recovery pages are not audited
(`sheet.js:1079-1085`).

**Proposal:** a nullable rest-rates column on `campaigns`, set by the GM on the
dashboard; the sheet prefers the campaign's rates and falls back to the device's.
**Still no default numbers.** **Posture: a schema change — one nullable column,
applied to production before the merge, per `ship-pr`.** In scope by Nate's decision,
2026-09-10.

**Evidence:** code read 2026-09-10. **Confidence:** high. **Ongoing cost:** one column,
through the five places `schema-change` names.

---

**Taken, 2026-09-10 (PR #931). Posture held: a schema change — one nullable column,
applied to production before the merge, per `ship-pr`.** Still **no default numbers**:
NULL means the table has not said, and the sheet falls back to the device's own rates
exactly as it always did.

**Migration `054-campaign-rest-rates.sql`** adds `campaigns.rest_rates`, JSON of per-hour
recovery by pool, through all five places `schema-change` names — the migration, the
`CREATE` in `db/schema.sql`, a guarded seed line testing for the column, a row in
`docs/operations.md`, and the `campaigns` row of the README's data model. Pure ASCII and
LF, which is what `d1-apply.mjs` pre-flights.

**The premise auditor's one note held and was acted on:** the campaign PATCH accepted
only `gm_notes` and `open`, so it was extended. It takes only the five pool names and
numbers of zero or more, drops a zero rather than storing it, and clears the column on
`null` or an object with nothing left. The character GET carries the campaign's rates,
decoded, beside the campaign's name and system, so the rest panel needs no second
request.

**Measured on 8801, local campaign 2, 2026-09-10** (its rates were NULL before and are
NULL again): the G.M.'s dashboard offered five fields; H.P. 2 and P.P.E. 5 saved and came
back stored as `{"hp":2,"ppe":5}`; a rate for *stamina* was refused **400**, *Not a pool:
stamina*; the character GET carried `{hp: 2, ppe: 5}`. On the sheet the rest panel said
*"Your G.M. set this campaign's rates, so they are filled in here"*, filled H.P. 2 and
P.P.E. 5, and previewed eight hours as *P.P.E. +12* — 40 clamped to the 12 missing, with
H.P. already full. Cleared from the dashboard, the column went back to NULL and the sheet
fell back to the device's rates and its original wording. Rest itself was not pressed:
it writes an event, and the preview is the arithmetic.

`regression.mjs` sets, reads back, refuses a non-pool, and clears — and, since it builds
its database from `schema.sql`, exercises the guarded seed line on a fresh environment.

**Applied to production before the merge, 2026-09-10 18:04:11**, by
`node scripts/d1-apply.mjs --remote db/migrations/054-campaign-rest-rates.sql`, after
every suite had passed on the branch: `changed_db: true`, 3 rows written. **Read back
from production rather than from the script's own report:** `schema_migrations` records
`054-campaign-rest-rates.sql`; `sqlite_master`'s `CREATE` for `campaigns` carries
`rest_rates TEXT`; all 3 live campaigns hold NULL, which is the normal state until a G.M.
saves rates. `drift-check.mjs --remote` read **NO DRIFT** immediately before the apply,
53 migrations recorded of 53, so anything it reports afterwards belongs to this change.

## Opened by the F2 remainder, 2026-09-12

`F2`'s outcome note ends *"Neither gate moved, and reconciling (1) and (2)
remains open and unstarted."* Checking what that remainder is worth today turned
up something else: a live false sentence in a doc `F2` never touched.

### F53 - medium - `race-and-occupation.md` says a missed attribute minimum is never a refusal, and it has blocked the save since before that sentence was written

**Found 2026-09-12** while scoping `F2`'s remainder.

**The sentence.** `apps/character-creator/docs/race-and-occupation.md:72-75`
reads *"**It is never a refusal.** A player may decline and continue with the
minimum unmet; `validate-character.js` warns on save and the admin audit lists
it under *worth a look*..."*
<!-- claim-ok: quoting the sentence this finding is about, cited by line above -->

**Both clauses are false, and the code says so in its own comment.**

- `functions/api/character-creator/_lib/validate-character.js:193` pushes
  `attribute_minimum` into **`violations`**, not warnings, and
  `functions/api/character-creator/characters.js:209` turns any violation into
  `422 "This character breaks its class rules"`.
- `apps/character-creator/catalog.js:257` renders violations under
  **"Would be refused on save"**; *"Worth a look"* is `catalog.js:262`, the
  warnings bucket. The doc names the wrong one of the two.
- `validate-character.js:635` already records the fact, in a comment about a
  different rule: *"A WARNING and never a violation, matching the ceiling check
  above rather than `attribute_minimum`, **which blocks**. That is the posture
  Nate fixed when the finding was taken."*

**This is not rot — the sentence was wrong when it was written.**
`git log -L72,77:apps/character-creator/docs/race-and-occupation.md` puts it in
`0ac2a9f`, 2026-08-26, five days before `F2`. `F2` (PR #441) corrected
`wizard-and-sheet.md` and the step-4 panel copy and left this file alone, so
one of the two docs has been right and the other wrong ever since.

**Reach:** a reader of the race/occupation doc, which is the file
`wizard-and-sheet.md` sends people to for this exact subject
(`wizard-and-sheet.md:278-280`). Not a player-facing string: the wizard's own
copy was fixed by `F2`.

**Options:**

| | what | for | against |
|---|---|---|---|
| **A (recommended)** | replace the paragraph with the true one, and POINT at `wizard-and-sheet.md` for the detail rather than restating it | one account of the rule, in one file; `wizard-and-sheet.md:280-292` already carries it (read 2026-09-12) and `:278-280` already links here | the doc gets shorter and a reader has one more hop |
| B | restate the full account here too | no hop | two copies of a rule that has already diverged once, which is how this finding happened |
| C | delete the paragraph | shortest | the question "can I decline?" is a real one and deserves an answer where it is asked |

**Proposal:** A. **Posture:** documentation only. No gate moves, no code, no
data. This is explicitly **not** the `F2` remainder — that is a decision about
the two gates and is filed separately as `F54`.

**Confidence: high.** Every line above was read on `origin/main` at `0d13dbf`
on 2026-09-12, and the two buckets were read in `catalog.js` rather than
inferred from the rule name.

**Ongoing cost:** none. The paragraph stops making a claim that can go stale.

**Subject grep, 2026-09-12:** every `*AUDIT*.md` (root and under `apps/`) plus
`SETUP-v2-CHANGES.md` for `attribute_minimum`, `race-and-occupation` and
"worth a look". **No menu in the tree mentions `attribute_minimum` at all** —
the only hits are this finding's own text. `RETRO-AUDIT` `R15` carries
`attribute_minimums`, which is the class frontmatter KEY and a different thing.
`F2` above is what sent me here and does not say the doc is wrong. The memory
store has one hit, `character-creator-docs-split.md:26`, which names
`docs/race-and-occupation.md` as the pin for the MOS sentence — a pointer, not
a decision about this subject. Nothing to argue past.

*(This paragraph first claimed `BOOK-INGEST-AUDIT` F32 cites `attribute_minimum`
as a blocking counter-example. It does not — that sentence is in
`validate-character.js:635`, quoted above, and the menu carries no such line.
Corrected before this PR was opened, by running the grep instead of trusting the
note that had just quoted the comment.)*

**Taken, 2026-09-12 (PR #969). Option A, as written.**

**One thing the finding did not say, found while writing the replacement.** The
link it hands to already exists in the other direction:
`wizard-and-sheet.md:278-280` sends a reader here for the re-roll, and this file
sent them nowhere back. The replacement closes the loop, which is why A is a
smaller change than it looks.

**Posture said back:** documentation only; no gate moved, no code, no data. It
held.

### F54 - low - the two attribute-minimum gates disagree by design, and reconciling them reverses a written decision whichever way it goes

**Filed 2026-09-12, NOT taken.** This is `F2`'s actual remainder — its note
ends *"Neither gate moved, and reconciling (1) and (2) remains open and
unstarted."* <!-- claim-ok: quoting the premise this finding inherits -->
`F53` above took the one part of it that was a measurement. What is left is a
decision, and it is filed as one.

**The two behaviours, both read on `origin/main` at `b6ee6cc`, 2026-09-12.**

1. **The Attributes step HARD-BLOCKS.** `const canNext = missing.length === 0 &&
   unmet.length === 0 && !over;` (`apps/character-creator/app.js:2227`), with
   the reason rendered in a `.nav-why` span beside the disabled button.
2. **The Occupation step WARNS and offers a re-roll.** `occBlocker()`
   (`app.js:2078-2084`) returns a blocking reason only for an unchosen
   practitioner occupation; the minimum shortfall is not in it.

Which one a player meets depends only on **class order**: O.C.C.-first knows the
class by step 2 and blocks; race-first does not learn the occupation until step
4 and warns. Same character, same shortfall, two different experiences.

**Both are deliberate, and each direction reverses something written down with
reasons. That is why this is a decision and not a defect.**

- **Making (2) block** reverses `app.js:2075-2077`, which says in code: *"The
  ONLY thing that blocks this step. A missed minimum deliberately does not: the
  app's standing rule for occupations is that a mismatch warns and never
  refuses"* — and `docs/race-and-occupation.md:63-69`, which records three
  alternatives rejected on purpose (re-roll the whole block, auto-raise to the
  minimum, offer a choice between them).
- **Making (1) warn** reverses `docs/wizard-and-sheet.md:267-283`, which names
  Attributes as one of four deliberately gated steps and adds *"A greyed button
  with no reason, or a reason beside a live button, are each worse than either
  alone."*

**What is NOT in question.** The save refuses either way, read 2026-09-12 at
`_lib/validate-character.js:193`, which returns `attribute_minimum` as a
blocking violation, and `characters.js:209`, which answers 422. `F53` fixed the doc that said
otherwise. So this is about **where a player is told**, never about what is
allowed.

**Options:**

| | what | for | against |
|---|---|---|---|
| **A** | both steps BLOCK | the wizard never lets a player build something the server will refuse; matches what the save actually does | reverses the occupation doctrine and the three rejected alternatives, and a blocked step-4 with no re-roll left is a dead end |
| **B** | both steps WARN | the player keeps agency, and the 422 is the single point of truth | reverses `wizard-and-sheet.md`'s gating rule, and lets a player finish a wizard that cannot save |
| **C** | leave them disagreeing, and say so in the docs | costs a paragraph; both behaviours are individually defended | the inconsistency is still reachable and still undocumented as intentional |
| **D** | leave it entirely | nothing to do | `F2`'s remainder stays open forever, which is what this finding exists to stop |

**No recommendation, deliberately.** Each of A and B reverses a decision the
other half of the app is built on, and neither is a reading of the code — it is
a call about how much the wizard should protect a player from the save. **C is
the cheapest honest outcome** if the answer is "not now".

**One thing to fix whichever way it goes.** The comment at `app.js:2075-2077`
says the standing rule *"warns and never refuses"*. That is true of the STEP and
false of the SAVE, which is the exact shape `F53` just corrected in
`race-and-occupation.md`. One clause, whoever takes this.

**Posture:** the option chosen decides it. A and B are code; C is documentation
only.

**Confidence: high on both behaviours and on the two decisions they reverse** —
every line above was read rather than recalled, and `F33`'s own note
independently re-confirmed behaviour (1) on 2026-09-08
(`UI-AUDIT.md`, *"The `Skills` button is disabled for the unmet minimum"*).
**Not measured: how often a real player meets either**, which would need the
class-order split across real builds and production holds three characters.

**Ongoing cost:** none for C. A or B costs one source pin on the gate that moved.

**Subject grep, 2026-09-12:** every `*AUDIT*.md` (root and under `apps/`) plus
`SETUP-v2-CHANGES.md` for `occBlocker`, `canNext` and `.nav-why`: nothing
outside this menu. Inside it, `F2` is the parent and `F33` re-confirms
behaviour (1) in passing. The memory store has no hit for any of the three.
**The two decisions this finding would reverse are not on any menu** — they are
in a code comment and two doc files, which is why the grep that matters here was
the tree one and not the menu one.

**Taken as option A, 2026-09-12 (PR #F54APR), on Nate's word. Both steps block.**

**This finding offered no recommendation and that was fence-sitting.** The
tie-breaker is something it establishes itself and then does not use: **the save
refuses either way.** That makes option B - both steps warn - actively wrong. It
would let a player spend six more steps and meet a 422 at the end, which is the
worst place to learn. Option A is the only one where what the wizard says and
what the server does are the same sentence.

**And it does NOT reverse the occupation doctrine**, which is what made this look
like a dilemma rather than a decision. `app.js`'s comment said *"the app's
standing rule for occupations is that a mismatch warns and never refuses, and
this is the same class of problem."*
<!-- claim-ok: quoting the comment this note corrects, cited by path above -->
**It is not the same class of problem.** That doctrine is about pairings the
SERVER ALLOWS - a race and an occupation a book discourages. An
`attribute_minimum` is a blocking violation and a 422. Hard rule, soft rule; the
wizard now draws the line where the server draws it, and the comment says so.

**What shipped.** `occBlocker()` returns the shortfall as a blocking reason,
**guarded on `S.occ`** - without an occupation there is no `shortfallPanel` and
no re-roll button, so blocking there would be a disabled button with nowhere to
go, which is the exact failure `docs/wizard-and-sheet.md` warns about. With one
chosen, the re-roll sits directly beneath the block; it has since the panel was
written, which is why the block can land on this step at all. The reason text
says the save would be refused, so the player is told *why*.

**Both docs that described the old rule are corrected in the same PR** -
`wizard-and-sheet.md`'s gating list and the paragraph `F53` rewrote in
`race-and-occupation.md` five hours earlier, which had just been made true and
is now true in a different way. That is the cost of a doc that states a rule
rather than pointing at one, and it is the second time today.

**Tests: three pins asserted the OPPOSITE and are inverted rather than
deleted** - `'a missed minimum does not'` was a check that the Occupation step
did not gate on it. Inverting was the right move because the durable thing to
pin is that the **two gates agree**, which is exactly what a later tidy would
undo. Six checks now, including one that the Attributes step still gates on the
same shortfall.

**Not walked in a browser, deliberately, and here is the argument rather than an
apology:** this changes what `occBlocker()` RETURNS, not how it is rendered. The
`.nav-why` span and the `disabled` attribute are the same machinery that has
rendered the ability blocker since the step was written, unchanged by this PR
and pinned. Reaching the new state by hand needs a character that rolls under a
class minimum, which is dice.

**The remaining clause this finding flagged is fixed here too:** the comment no
longer says the rule *"warns and never refuses"*.

Smoke 1986 -> **1989**.

### F55 - medium - `--border` never cleared 3:1, and since N4 it carries a STATE as well as decorating a panel

**Filed and taken 2026-09-12.** This is `F6`'s remainder — its note ends
*"`--border` was not touched and stays open."*
<!-- claim-ok: quoting the premise this finding inherits -->

**Every number in `F6`'s remark is stale and the substance is intact, which is
the worst combination to read.** `F6` says *"`--border` `#2a2f3e` sits at
**1.19-1.47**"*. `#2a2f3e` exists nowhere in the tree - three redesigns have
been through since. Recomputed 2026-09-12 from the declared values in
`shared/styles.css:140-146`:

| | `--bg-primary` `#0A0F0E` | `--bg-secondary`/`card` `#141B19` | `--bg-tertiary`/`input` `#1E2724` |
|---|---|---|---|
| `--border` `#2C3733` | 1.56 | 1.42 | 1.24 |
| `--border-strong` `#46554F` | 2.46 | 2.23 | 1.95 |

Still below 3:1 everywhere, and `--border-strong` - which did not exist when
`F6` was written and which the remark therefore has no view on - does not reach
it either.

**What changed since the remark is the KIND of thing `--border` does.**
`REDESIGN-AUDIT` `N4` deleted the opacity on the not-applicable wizard step and
left the dashed edge as the only marker, saying so in its own text. So
`apps/character-creator/styles.css:339` is **state information carried by a
border at 1.56:1**, which is the half of WCAG 1.4.11 with no large-text escape.
The same is true of control boundaries: every text input and `select`
(`styles.css:164`) and every `.btn` (`shared/styles.css:337`) draws
`--border` on `--bg-tertiary` - **1.24:1 against the control's own fill**, and
that fill is only 1.42:1 from the panel behind it, so neither the border nor the
fill identified the control. **That raises the severity and not the size.**

**A blanket raise is not available, and this is the measurement that decided the
shape.** Walking the hue up, the first value clearing 3:1 on all three grounds
is `#66716d`, and `#5C736B` clears it at 3.79 / 3.43 / 3.01. **Both are lighter
than `--border-strong` `#46554F`** - so raising `--border` collapses the
`--border`/`--border-strong` pair, and `shared/styles.css:134-138` makes that
pair the whole depth mechanism (*"DEPTH IS A LIT EDGE, NOT A SHADOW"*, with
`--shadow: none` and a smoke check forbidding the alternative). Same shape as
`F6`'s own conclusion about `--text-muted`: closing the gap costs the tier its
identity.

**Options:**

| | what | for | against |
|---|---|---|---|
| **A (taken)** | a THIRD token, `--border-control`, on the edges that identify a control or carry a state; plate edges keep `--border` | the only version that fixes the accessibility failure without collapsing the depth pair | one more token, and a reader has to know which of three to reach for |
| B | raise `--border` itself | one token | collapses the pair and takes the lit edge with it, per the measurement above |
| C | raise only the stepper state | smallest | leaves every input and button at 1.24:1, which is the larger half |
| D | leave it | nothing to build | a control the user cannot find the edge of |

**Proposal:** A. **Posture:** tokens and call sites only. No palette re-tone, no
new convention, no change to `--border` or `--border-strong`.

**Taken, 2026-09-12 (PR #972). Option A.**

**`--border-control: #5C736B`**, and three call sites: `.btn` in
`shared/styles.css`, the text-entry controls in the app's own stylesheet, and
the `.st.na` dashed edge N4 left carrying itself.

**It lands in `shared/`, which is the "bigger than it looks" flag `F6` raised,
and the escape hatch Nate used in PR #451 is gone.**
`apps/character-creator/styles.css:7-13` records that this app's `:root` was
deleted - *"the overrides are gone rather than retoned"* - so there is no
app-local scope left to make this change in. `.btn` is used by the character
creator and filament-forge among others, and all of them had the same 1.24:1
edge, so the reach is correct rather than incidental.

**`index.html` is deliberately untouched and the front-door pin still passes.**
It carries its own `--border: #2C3733`, and `rendered-ui.mjs` compares that
against shared's by ROLE - unchanged either side. The landing page has **zero**
`<button>`, `<input>` or `<select>` elements (grepped 2026-09-12); its one
`var(--border)` is a card edge, which is decoration.

**Tests, and this is the suite's first contrast arithmetic.** Nine checks, and
**seven fail against the stylesheets as they were**. It recomputes the ratios
from the declared token values rather than trusting the comment beside them -
which is the direct lesson of this finding, since `F6` recorded its measured
ratios in prose and every one of them was stale within days. `ratio()` returns
0 for anything that is not a six-digit hex, so **deleting a token fails these
checks rather than throwing** - the first version crashed the whole suite on a
missing token, which was found by running the fail-first proof.

**Verified in a browser**, not only in arithmetic: served from this branch on
port 8791 (confirmed by grepping the SERVED `shared/styles.css` for the new
token, per the `launch.json` warning about another worktree answering on 8788),
and the Race step read correctly - the filter input and both `.btn`s have
findable edges, the dashed ADVANCEMENT step still reads as not-applicable, and
the panel edge stays quiet, so controls now sit ABOVE decoration in the
hierarchy rather than below it.

**Posture said back:** tokens and call sites only; no palette re-tone, no
convention, `--border` and `--border-strong` unchanged. It held.

**Subject grep, 2026-09-12:** every `*AUDIT*.md` (root and under `apps/`) plus
`SETUP-v2-CHANGES.md` for `--border`, `border-strong` and "contrast":
`REDESIGN-AUDIT` `N4` (which created the state case and is cited above),
`WORKSHOP-UI-AUDIT` `W1`-`W3` (phone layout, not colour) and `F6` itself.
The memory store's `bench-redesign-and-landing-page-constraints.md` carries the
lit-edge rule this finding is shaped around and no decision about `--border`'s
ratio. Nothing to argue past.

### F56 - low - F17's print-ink remainder, re-measured: half of it is moot and the rest has no way to be printed

**Filed and CLOSED 2026-09-12, on the re-measurement.** This is `F17`'s
remainder — its note ends *"**The ink observation stands and was not taken.**
`.stepper .st`, `.lvl-row`, `pre.snippet` and `.cat-row.open` still get no
light background in the print block."*
<!-- claim-ok: quoting the premise this finding inherits -->

**Filed rather than left as a remark**, per `META-AUDIT` `A16`: work handed to
the future gets a number or is dropped. This is the second half of that — it
gets a number **and** is dropped, with the reason on the record so the four
selectors are not re-derived a third time.

**Two of the four are gone.** Read on `origin/main` at `91839bc`, 2026-09-12:

| selector | state |
|---|---|
| `.stepper .st` | **moot.** `F35`'s stepper rewrite removed the fill — `apps/character-creator/styles.css:273-276` now reads `background: transparent; border: 0;`. There is nothing to reset |
| `pre.snippet` | **dead CSS.** The rule is at `styles.css:1157` and **nothing renders it**: no `class="snippet"` and no `<pre class=` anywhere under `apps/character-creator/`. The `snippet` hits in `campaign.js` are a search-result STRING, a different thing |
| `.lvl-row` | still `background: var(--bg-secondary)` (`styles.css:407-410`), unreset |
| `.cat-row.open` | still `background: var(--bg-secondary)` (`styles.css:1307-1311`), unreset |

**The two that remain cannot be reached by anything that prints.** `.lvl-row`
renders on the wizard's Advancement step and `.cat-row.open` in the catalog, and
**the only `window.print()` in the app is `sheet.html:34`** — the character
sheet, which is a different page. Reaching dark ink on paper needs Ctrl+P on a
page the app never offers to print **and** *Background graphics* ticked, which
is off by default.

**Two of `F17`'s surrounding counts are also stale**, recorded so neither is
quoted forward: it says *"five `@media print` blocks"* and there are now
**seven** (`grep -c '@media print' apps/character-creator/styles.css`,
2026-09-12); and its *"exactly one `<thead>` in `sheet.js`"* is now four, since
`F29` made the skills list a real table. Neither bears on the ink.

**Why this closes instead of shipping two lines.** The fix is ~2 lines in the
print block at `styles.css`, and this app has a written rule against exactly
that: `F16`'s note declines to copy an unused `.sr-only` helper because
*"copying an unused rule is how `.cols-5` (F15) happened"*. Adding print resets
for two selectors that no print path renders is the same trade — a rule nothing
exercises, which the next reader has to work out the purpose of. **Reopen it the
moment the wizard or the catalog gains a print affordance**, which is a real
trigger and not a hypothetical: the sheet has one.

**Not folded in, and named so it is not lost:** `pre.snippet` is dead CSS and
should be deleted. That is a cleanup rather than a print fix and goes with the
other dead code found in this sweep.

**Posture:** none — nothing is built. **Confidence: high on all four selectors
and on the print entry point**, every one read rather than recalled.
**Not settled: whether those two backgrounds actually paint on paper**, which
was established from source — no print rule resets them and the print blocks
consume no tokens — rather than from a render. A CDP render with
`printBackground: true` would settle it; `--print-to-pdf` defaults that off, so
the recipe in `print-render-headless-chrome.md` cannot see it. That gap does not
change the outcome, because the trigger above is about reachability rather than
about the ink.

**Ongoing cost:** none.

**Subject grep, 2026-09-12:** every `*AUDIT*.md` (root and under `apps/`) plus
`SETUP-v2-CHANGES.md` for `@media print`, `printBackground` and `snippet`:
`F17` itself and `REDESIGN-AUDIT` `R6`, which is about accent colour on screen.
The memory store has `print-render-headless-chrome.md`, cited above, which
records that the headless method **falsified `F17` outright** and says nothing
about the ink remainder. Nothing to argue past.
