# REDESIGN-AUDIT.md — what survived the redesign prompt

Written 2026-08-31, against the working tree at `C:\Users\natha\Projects\nates-apps`
on `main` at `918a20e`.

Source: a UI redesign prompt drafted in Claude Design, kept with the other prompts of
its kind in `C:\Users\natha\Downloads`. The prompt proposed a whole-app reskin — new
token names, three palettes, self-hosted display faces, a rebuilt character sheet and a
seven-step wizard rail. Most of it was written against an app that does not exist here.
This file keeps only the parts that describe a real defect in **this** tree, restated as
findings with their premises checked.

**This menu was produced by reading code, not by looking at screens.** No dev server was
started and no screenshot was taken. Every claim below cites a line; none of them cites a
render. Where a finding turns on how something *looks* — R3 especially — the render is
part of taking it, not part of proposing it.

Scope is the **interface only**, same as [UI-AUDIT.md](UI-AUDIT.md), which is closed.
Findings here take the prefix `R` rather than continuing that file's `F1`–`F29`, so a
citation of "F6" stays unambiguous. Numbered most severe first. Nothing here has been
changed. Take findings one at a time.

---

## Premise corrections — read first

The prompt carried nine claims about the app. Per the `audit-menu` rule that taking a
finding means auditing the finding, they were checked against the tree before anything
was written down. **Six were wrong**, and three of them would have produced a finding
for a problem this app solved months ago:

| Claim | Verdict |
|---|---|
| "the three page templates (creation wizard, character sheet, GM dashboard)" | **Wrong — there are five**, all linking the same `styles.css`: `index.html`, `sheet.html`, `dashboard.html`, `campaign.html`, `catalog.html`. A token change verified against three breaks two silently. |
| "Seven steps: System, O.C.C., Attributes, Skills, Powers, Equipment, Review" | **Wrong on count and order.** `app.js:32` is ten: System, Race, Attributes, Occupation, Skills, Equipment, Powers, Advancement, Details, Review. `test/smoke.mjs:1387` pins `ten steps`, `Race comes before Attributes`, `Occupation comes after Attributes`, `Advancement after Powers and before Details`. A draft stores `step` as an **index** into that array under `STEPS_VERSION = 3` with a chained migration, so a seven-item rail also re-points every draft in flight. |
| "Persist to localStorage on change so a refresh resumes" | **Wrong — the draft is server-side**, in D1 `character_drafts`, one row per `owner_email`. Adding a localStorage copy creates a second source of truth for the same data, which the prompt's own "derive, don't duplicate" rule forbids. |
| "the sheet must render and print with JS disabled" | **Wrong — it never has.** `sheet.html:33` ships `<div id="app"><p class="muted">Loading sheet…</p></div>` and `sheet.js` builds the body. Already recorded for `campaign.html` at `UI-AUDIT.md:1656`; this is the second time the claim has been made. |
| "Keep the existing custom-property names wherever they already exist" | **Wrong — one of fourteen exists.** The tree uses `--bg-primary/-secondary/-tertiary/-card/-input`, `--border`, `--text-primary/-secondary/-muted`, `--accent-secondary`, `--success/--warning/--danger`. The prompt's block names `--bg`, `--panel`, `--panel2`, `--line`, `--line2`, `--text`, `--dim`, `--faint`, `--accent2`, `--good`, `--bad`, `--warn`. Only `--accent` overlaps. 222 references inside `apps/character-creator/` alone, and the tokens are defined in `shared/styles.css` for four apps. |
| "A silent no-op is the bug I most want avoided" (of wizard pick lists) | **Wrong — the wizard already does this, to the same number.** Blocked rows render `style="opacity:0.45"` plus `disabled` at `app.js:2104, 2152, 2364, 2577, 2601`, and `app.js:2232` carries the comment "No limit check here: the row's checkbox is disabled at the limit by the caller." The prompt asks for 45% opacity and gets 0.45. What is genuinely missing is narrower — see **R4**. |
| "For read-only viewers, remove the steppers, Use buttons… from the DOM entirely" | **Already done.** `C.canWrite` gates them: `sheet.js:922` renders the Use button only under `w`, and `sheet.js:994` notes "an input for owner/GM, plain text otherwise". A `read-only` tag is rendered at `sheet.js:1089`. No control is offered to a viewer and then refused. |
| "Implement the real rule: 16+ rolls an extra D6" | **Already implemented, and more precisely than stated.** `js/dice.js:111–125` reads the threshold on the **dice**, before racial bonuses — a `3D6+6` race is exceptional when its dice show 16, not when the total does — chains one further die on a six and stops, and uses 12 for a 2D6 pool. Following the looser wording would regress it. |
| "credits left", "Not enough credits", "price above remaining credits" | **No such budget exists.** `S.bio.money` is rolled from `starting_money` at `app.js:335` and stored as bio flavour; equipment is not priced against it anywhere. A credits counter is a rules feature, not a UI fix, and is out of scope here. |

The three claims that held: no build step, no framework, no dependencies; dark theme
only; and desktop-first with a phone story at the table. The phone story is `body.play-mode`
(`styles.css:901` onward), which the prompt did not know about.

---

## Findings

### R1 — high — The sheet offers a **Use** button the pool cannot pay for, then refuses the click

`sheet.js:922` renders the button on `w && cost != null && c[pool + '_current'] != null`.
There is no affordability test. Click it with 4 P.P.E. against a 10-P.P.E. spell and
`sheet.js:1701` answers with `alert('Not enough P.P.E. (4 left, Fire Bolt costs 10).')`
and returns.

This is the one thing the prompt was right about that the app has not already fixed, and
the fix is already written twice over on the other side of the app: the wizard's blocked
rows are `opacity:0.45` plus `disabled`. The sheet's power rows are the only place a
control is offered, looks live, and then argues.

**Proposal:** compute affordability where `useBtn` is built and carry it into the button —
`disabled` plus the wizard's `opacity:0.45` on the row's cost, so the row still reads and
still prints. Keep the `alert` as the backstop for the hand-driven call, exactly as
`app.js:1293` keeps one behind a disabled `<option>`. Variable-cost powers (`cost_note`,
where `cost` is a minimum) stay enabled at the minimum — the G.M. adjusts by hand and the
row already says so.

**Posture: dim and disable, do not hide.** A spell you cannot currently afford is one you
still need to see; removing the row would hide a power the player forgot they had.

**Taken, 2026-08-31 (PR #462).** Posture held: dim and disable, never hide. The finding
was wrong twice, and one of the errors was the half that matters most.

**There are two use buttons, not one.** This finding cited only the sheet's and asserted
its power rows were "the only place" a control is offered and then argues. `renderPlay`
has its own — `sheet.js:766` after this change — gated on the identical condition and
routed to the same `usePower`. Play mode is the phone-at-the-table view, so taking the
finding as scoped would have fixed the lesser of the two.

**And play mode never re-renders.** A pool there moves by targeted DOM update:
`adjustPool`, `takeDamage`, `rest` and `usePower` each write `C.data` and set the
`play-cur-<pool>` span by hand. Gating at render alone would have moved the false promise
one action later instead of removing it. `syncPowerBtns()` re-reads every button from the
pool it declares — the buttons now carry `data-pool` and `data-cost` — and is called
wherever a pool moves, on both the optimistic path and the rollback. `takeDamage` is
deliberately not among them: it reaches H.P., S.D.C. and M.D.C. and can never change what
a power spends from.

**Nothing needed styling.** `shared/styles.css` already dims `:disabled` to 0.45 with
`cursor: not-allowed`, and its comment describes this same bug in the wizard — "press a
button that looked ready and have nothing happen". The finding asked for the wizard's 0.45
without knowing it was already inheritable.

**The cost-dimming half was NOT applied**, on Nate's call. The cost is 11px and sits at
6.3:1 on `--bg-primary`; at `opacity:0.45` it composites to `#4c3e7c` and **2.13:1**,
which fails 4.5 and would put the first contrast failure back on a page measuring zero.
It is also the text that says *why* the button is dead, so dimming it works against this
finding's own "the row still reads". Two alternatives were measured and not chosen:
`--text-secondary` at 6.31:1, and leaving it as is. The finding's mechanism was right and
its treatment was not — the same shape as F20 and F6 in [UI-AUDIT.md](UI-AUDIT.md).

Verified at `localhost:8793` against a wizard holding 12 spells costing 1 to 12, pool set
to 6: nine buttons live, the three at 10, 10 and 12 disabled; cost 6 with 6 left stays
live, because `usePower`'s own guard is `cur < cost` and the two now agree exactly.
Casting at 6 took the pool to 0 and all twelve went dead. In play mode, spending 4 killed
the cost-4 and cost-6 buttons and `adjustPool(+4)` brought them back — both times with the
button nodes identity-equal across the change, which is the proof that the sync ran and no
re-render did.

---

### R2 — high — Current H.P. is unreachable from five of the six tabs

`sheet.js:1123` puts the five pools inside `data-tab="vitals"`, and `styles.css:1072` is
`.tabpanel { display: none }` with no viewport condition — tabs are on at 1440 as much as
at 390. A player on **Skills**, **Gear**, **Powers**, **Bio** or **Notes** can neither read
nor edit H.P. without leaving what they were looking at, which is the one number that
changes most during play. `TAB_IDS` defaults to `vitals` precisely because it is the thing
you need first; the layout then makes it the thing you must leave.

**Proposal:** lift the five pool cells (`hp`, `sdc`, `mdc`, `ppe`, `isp` — `sheet.js:7`)
out of the vitals panel into a single strip rendered *above* `.tabbar`, outside every
`.tabpanel`, and drop them from the vitals tab so no number is rendered twice. Current
value stays a real input; max stays text.

**Two traps, both already written down in this tree:**

- **The print block hides every input with `!important`** (`styles.css:862`:
  `header, .header, button, input, textarea, select, #msg, .noprint`). Lifting the
  current values into inputs without a `.print-only` mirror deletes all five numbers from
  the printed sheet. The mirror convention is documented in the comment immediately above
  that rule and is what `.vital .val input` already relies on.
- **`.tabbar` is already `position: sticky; top: 0; z-index: 20`** (`styles.css:1035`),
  beneath a shared `.header` that is sticky at `z-index: 100`. A second element claiming
  `top: 0` will overlap one of them. Decide which of the strip and the tab bar sticks, or
  stick them as one block — do not give both `top: 0`.

**Posture: one strip, not a redesign.** No new grid on the sheet body, no new tab scheme,
no change to which tabs exist. If the strip cannot be added without restructuring the
sheet, that is a reason to stop and say so, not a reason to widen the finding.

---

### R3 — medium — The sheet is 900px wide and spends none of a 1440 screen on its longest list

`sheet.html:32` is `<main class="wrap">`, and `.wrap` is `max-width: 900px`
(`styles.css:71`). The skills tab renders `.skill-table` at `table-layout: fixed;
width: 100%` (`styles.css:431`) — one column of rows, however many skills the character
has, with roughly 540px of a 1440 screen empty beside it.

This is the same argument this repo already made, and **measured**, for `catalog.html` —
the comment at `styles.css:77–81` states it: five columns sharing 798px while 540 sit
empty. It also records the trap, which is why this finding is worth more than the idea it
came from: laying that list out on a grid **inside** the 900px container made it *17%
taller*, and widening the container was half the fix, not a separate wish.

**Proposal:** put `wrap-wide` on `sheet.html`'s `<main>` and give the skills table
auto-fill columns at a minimum measured to fit the longest O.C.C. skill name, O.C.C. and
Secondary staying separate groups. `fitColumns()` in `catalog.js` measures column widths
at render time and is the mechanism that already solved the sizing half of this.

**Measure the rendered height before and after and put both numbers in the outcome note.**
If it gets taller, that is the answer and the finding closes unadopted. Check the print
render too (`--headless=new --print-to-pdf`, absolute Windows output path): the print block
sets `.wrap { max-width: none }` at `styles.css:860`, so paper should be unaffected — that
is a prediction to verify, not a given.

**Posture: measure, and revert on a worse number.** Widening the container touches only
`sheet.html`; `wrap-wide` already exists and is used by `catalog.html`.

---

### R4 — medium — Two different reasons a skill row is blocked render identically

`app.js:2147` is `const blocked = !on && (taken.has(s.name.toLowerCase()) || chosen.length >= limit)`.
Both branches produce the same row: `opacity:0.45` and `disabled`, with nothing saying
which applies. The cap case has a nearby explanation — the group head prints
`${picked.length}/${s.choose} chosen` (`app.js:2110`). The already-taken case has none, so
a skill the character *already has* looks exactly like a skill they ran out of picks for,
and the remedy differs: one is "drop a pick to swap", the other is "there is nothing to do
here".

**Proposal:** on the already-taken branch only, append a `<span class="muted small">`
reason to the row's label — the same treatment the repeatable-language rows already get at
`app.js:2101` (`— once per language; you will be asked which`). Leave the cap branch alone;
its counter is the explanation and duplicating it on every row is noise.

**Posture: a word on the row, not a tooltip and not a new component.** No hover-only
affordance — this has to be readable on a phone.

---

### R5 — medium — The sheet's skills list has no filter and no count

`.pick-filter` exists (`styles.css:812`) with a search input and a live count, and its
comment argues its own case: "The count is half the point — it says whether to keep typing,
and whether an empty list means 'no match' or 'empty catalog'." It is wired into the
wizard's pickers. The **sheet** — where the lookup actually happens, mid-session, with
someone waiting — has neither. `grep -n filter sheet.js` returns array `.filter()` calls
and nothing else.

**Proposal:** reuse `.pick-filter` above the skills table on the sheet: one `input[type=search]`,
one count reading `N known` and narrowing to `N of M` while filtering. Filter on the
rendered rows without re-rendering, for the same reason `pickTab` toggles classes rather
than re-rendering (`sheet.js:803`) — a rebuild costs a half-typed note.

**Posture: reuse the existing component.** It already carries `@media print { .pick-filter
{ display: none } }` at `styles.css:818`, so print needs no new hook. Skills only — not
gear, not powers — until this one is seen working.

---

### R6 — low — Four of the twenty-two `--accent` uses sit on things you cannot act on

The prompt's rule — accent means *you can do something here* — is a good rule and this app
mostly follows it. Eighteen of twenty-two uses in `styles.css` are links, focus, selected
cards, current step, active tab, toggles. The exceptions:

| line | rule | what it colours |
|---|---|---|
| 121 | `.tag.score` | a static badge |
| 499 | `.power-row .cost` | a static number, beside the ⚡ button that *is* the action |
| 510 | `.mini-in.derived::placeholder` | a derived value shown as placeholder text |
| 962 | `.play-roll .pr-num` | the roll result, after the fact |

`499` is the sharpest: the cost and the button sit in the same row, and only one of them
does anything.

**Proposal:** move these four to `--text-primary` or `--text-secondary` as the weight of
each warrants. Nothing else changes.

**Posture: no palette change and no new tokens.** This is a four-line finding. It is
explicitly *not* the prompt's Phase 1 — see *Not carried forward*. Re-run the contrast
scanner after, since three of the four are moving to a different foreground.

---

### R7 — low — Every page in the repo fetches its fonts from a third-party CDN

Ten HTML files repo-wide carry `<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono…&family=Outfit…">`,
five of them in character-creator. It is a render-blocking stylesheet plus a second
connection to `fonts.gstatic.com`, on every page of a site that otherwise ships zero
external requests and sits behind Cloudflare Access.

**Proposal:** self-host the two faces already in use under `shared/fonts/`, replace the
ten `<link>`s with `@font-face` blocks in `shared/styles.css`, `font-display: swap`.
There is no build step and no subsetting tool here, so ship the full latin files rather
than inventing a pipeline; weights are what the current query asks for — Outfit 300–800,
JetBrains Mono 400/500/600.

**Posture: same two typefaces, same weights, transport only.** This is emphatically *not*
the prompt's Phase 2, which proposed replacing Outfit and JetBrains Mono with Saira
Condensed and IBM Plex Sans across the app. Changing which faces the app uses is a
separate decision and is not proposed here. The change lands in `shared/`, so it touches
filament-forge, media-vault and pick3cut5 as well — all four apps get checked, or the
finding is not done.

---

## Not carried forward, and why

Recorded so the same material does not get re-proposed from the same prompt.

- **Phase 1, the token rename and the three palettes.** Fourteen new names against a
  fourteen-name system that already exists in `shared/`, for four apps. Beyond that, the
  proposed hexes do not clear the bar this app now meets. Measured against `--panel`:
  Rust `--bad` is **2.73:1** and `--faint` **2.98:1**; Graphite `--accent` is **2.65:1**
  and is the *same hex* as `--bad` (`#A8342F`), which collapses the prompt's own
  action-versus-alert distinction; Ley's `--bad` is 3.56:1. Phase 3A then puts `--bad` on
  the H.P. number precisely when H.P. is critical, so the sheet's most urgent number
  becomes its least legible — at 2.73 it fails even the 3.0 large-text threshold. The app
  currently measures **zero** contrast failures across all five pages, down from 152
  (UI-AUDIT, 2026-08-31). This is the F20/F6 pattern a third time: a proposed hex that
  does not hit the ratio claimed for it.
- **Phase 3B, the three-column body assigned by lookup frequency.** Not evaluated on its
  merits — it presumes the six tabs are not there. Any argument for it has to start from
  `.tabbar`, `TAB_IDS` and `body.play-mode`, and none of that was in the prompt's view.
  R2 and R3 take the two parts that stand on their own.
- **Phase 3A's Juicer panel** (bio-comp harness, uppers remaining, Last Call countdown).
  `grep -rn 'uppers\|bio-comp\|harness\|Last Call'` over `js/` and `sheet.js` returns
  nothing: no field, no frontmatter key, no column. That is a `class-import` and
  `schema-change` job, not a UI finding.
- **Phase 4's rail, and the wizard restructure generally.** See the premise corrections:
  wrong step count, wrong order, pinned by the smoke suite, and drafts index into the
  list.
- **The `data-palette` switcher and localStorage persistence.** A preference, not a
  defect. Nothing in the audit produced a reason to want it.
- **`data-noprint`.** `noprint` already exists as a class, 20 uses in `sheet.js`, live in
  `styles.css:862`. A second attribute-shaped mechanism for the same job is worse than
  either alone.
- **Token inversion in the print block.** The print block does not consume tokens; it
  hardcodes `#fff`, `#000`, `#999`, `#bbb`, `#ccc`, `#ddd`, `#eee`. Inverting tokens it
  never reads changes nothing.
