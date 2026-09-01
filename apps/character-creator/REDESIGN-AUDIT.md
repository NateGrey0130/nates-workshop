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

**Taken, 2026-08-31 (PR #463).** Posture held: one strip, no new grid, no new tab scheme,
no change to which tabs exist, and no number rendered twice.

**The second trap was understated — the tab bar's sticky had never worked at all.** This
finding predicted a conflict between two elements claiming `top: 0`. Measured at 1440×900
while scrolled, the tab bar was **61px tall with 0px visible**: `.header` sticks at the
same `0` with `z-index: 100` and simply covered it. The rule was dead, not contested.
Both now stick as one block at `top: var(--header-h)`, and the tab bar is visible while
scrolling for the first time — 61 of 61 pixels, measured the same way. `--header-h` is
written from the rendered header by `sizeSticky()` on every render and on resize, because
`.header` wraps to a second row on a narrow screen (77px at 1440, 166px at 390) and any
constant would be wrong at one of them.

**The first trap was exactly right**, and cost nothing: the markup moved intact, so the
`.print-only` `<b>` beside each input came with it. The rendered PDF carries H.P. 14 / 14,
S.D.C. 11 / 11 and P.P.E. 13 / 13 on page one, with no Save button and no tab labels, at
five pages. `[data-sticky]` is pinned to `position: static` for paper.

**Two things the finding did not mention.** The Save button had to move with the inputs —
the pool inputs are only committed by `saveStats()`, so leaving it behind would have made
the strip readable and uncommittable from everywhere else. And the "current / max" hint
now renders for read-only viewers, having previously sat inside the owner-only row where
a viewer never saw it.

Verified at `localhost:8793`: the H.P. input is present, visible and editable from all
five previously blind tabs; the strip holds three cells and the panels hold zero; a value
typed on the Skills tab and saved reached the server as `hp_current: 12`.

**One thing this opened, recorded as N1** in the `N` section below: the tab named *Vitals*
no longer contains any.

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

**Closed unadopted, 2026-08-31 (PR #464).** The posture decided it: the numbers came back
and one of them was worse. Nothing shipped.

**The premise was wrong.** The skills tab is not "one column of rows". It has been
`sheet-grid cols-3` for some time — three boxes side by side, Class / Related / Secondary,
at **273px each** inside the 900px container. The finding described a single full-width
strip and there is none. What *is* true is the 540px of empty screen beside the container.

**Measured at 1440×900, with 60 skills on the character** (15 real plus 45 probe rows
loaded into local D1 and removed afterwards, the technique from
[[print-render-headless-chrome]]):

| | `wrap` 900px | `wrap-wide` 1280px |
|---|---|---|
| skills panel height | 565px | **550px** (−15, −2.7%) |
| skill box width | 273px | 400px |
| wrapped name cells | 4 | 3 |
| journal body width | 363px | 553px |
| **journal characters per line** | **56** | **85** |
| bio box width | 416px | 606px |
| gear panel height | 1500px | 1500px |
| document height | 1015px | 1000px |

The skills gain is real and trivial: 2.7%, because the panel's height is set by the
*number of rows* in the tallest group, and widening cannot remove a row. The cost is not
trivial. `.wrap` is shared by every tab, so widening the sheet takes the journal from 56
characters per line to 85 — out of the range prose is comfortable in and into the range it
is not. Fifteen pixels of skills is not worth that.

**The trap the `catalog.html` comment warned about was real, and landed somewhere else.**
There, gridding inside a fixed container made the list *taller*. Here the height barely
moved and the damage went to the prose measure instead — the same lesson, that `.wrap`'s
900px is load-bearing for something, arriving through a different door.

**The narrower version was NOT substituted for the finding as written**, per the
audit-menu rule against quietly changing scope. It is recorded as **N2** in the `N`
section below, for a separate decision.

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

**Taken, 2026-08-31 (PR #465).** Posture held: a muted span appended to the label, the same
mechanism the repeatable-language rows already use. No new component, no tooltip, nothing
hover-only.

**The premises held exactly** — the first finding in this menu of which that is true.
`app.js:2147` was the two-reason expression the finding quoted, the repeatable hint at
`app.js:2148` was the mechanism to copy, and the cap branch did have its counter.

Wording is *"already on this character"* rather than the finding's *"already taken"*: a row
ticked **here** is `on` rather than blocked, so "taken" reads like the state it is not. The
reason it earns a row-level explanation at all is that `takenNames()` spans the O.C.C.
skills, the group picks *and* both pick lists — the skill blocking you can be three
sections up the page, which no counter above this list can explain.

The blocked expression is unchanged in meaning: `held || (!on && chosen.length >= limit)`
distributes to exactly the `!on && (taken || full)` it replaces.

Verified on an Elf Mercenary Fighter walked from step 1. Before any pick, 14 blocked rows
and all 14 carry the reason. At the related cap of 10, 203 blocked rows: 7 carry the reason
and **196 carry nothing** — the cap branch, untouched, which is the half of this finding
that was about restraint.

**Checked and not filed:** ticking a checkbox felt slow while driving the step, but a
single click measures 3ms synchronously — the delay was the test's own sleeps. There is no
performance finding here.

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

**Taken, 2026-08-31 (PR #466).** Posture held: the existing `.pick-filter`, skills only,
nothing added to gear or powers and no new CSS component.

**"Print needs no new hook" was half right.** The filter box itself needs none — the rule
at `styles.css:818` already hides it. But hiding rows leaves them hidden, so the print
block gained one rule putting `.filtered-out` rows back at `display: table-row`. What
someone typed to find a percentage is not a statement about which skills the character
has, and a filtered sheet must still print complete.

**A skill with a note owns two rows** since PR #460 — the note is its own
`<tr colspan="3">` — so the note follows its skill into and out of hiding. Filtering
without that leaves a footnote pointing at a row that is no longer there. The finding did
not mention it; the change would have shipped that bug.

**The first version read the query back from the DOM, and this file had already ruled
against that.** `C` carries `invFilter` and `pickFilter` under the comment *"state rather
than DOM so a re-render cannot discard them"*, and reading the input meant any re-render —
after a save, a power use, a level-up — silently dropped what had been typed.
`C.skillFilter` joins them. Caught by testing the re-render rather than by reading the
code, which is the argument for driving the thing.

Verified on a character with 15 skills: empty box reads `15 known` with nothing hidden;
`lang` reads `4 of 15` with 11 hidden and comes through a `render()` unchanged, input
value included. With a note attached to *Lore: Magic*, a filter excluding it hides skill
and note together and one matching it returns both. The print render is five pages with no
filter box, no count, and every sampled skill name present.

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

**Taken in part, 2026-08-31 (PR #467): two of the four lines. Posture held** — no palette
change, no new tokens, only the `color` on the rules named.

**Two of the four were not accent-on-something-static, and changing them would have broken
the rule this finding exists to enforce.** Its own test is *"if a rule uses `--accent` on
something the user can't act on, it's wrong"*, and these two fail that test for inclusion
rather than passing it:

- **`.play-roll .pr-num` is on a button.** The finding called it "the roll result, after
  the fact". It is not: `.pr-num` occurs exactly four times in `sheet.js` — 731, 739, 749
  and 757 — and **all four sit inside `<button class="play-roll" onclick="rollD20(…)">` or
  `rollSkill(…)`**. It is the modifier or percentage printed *on the control you press to
  roll it*. Accent is correct there.
- **`.mini-in.derived::placeholder` is inside an editable input** (`sheet.js:1051, 1073`).
  It marks a value as derived rather than typed, on a field you act on by typing over it —
  a state marker on a control, not decoration on a static number.

**The two that were right, measured before and after:**

| rule | was | now | ratio |
|---|---|---|---|
| `.tag.score` | `--accent` | `--text-primary` | **4.50 → 11.81** |
| `.power-row .cost` | `--accent` | `--text-secondary` | 5.60 → **5.61** |

`.tag.score` had been sitting exactly *on* the 4.5 line at 10px, so this is a legibility
gain as well as a semantic one. The power cost is unchanged in contrast and de-emphasised
by hue alone, which is what "the weight each warrants" wanted: it is metadata beside the
name, and the ⚡ button next to it is the thing that acts.

**The contrast scanner is not committed anywhere** — it was a one-off in the UI-audit
session — so it was rewritten for this: a text-node walk compositing every translucent
layer down to opaque, with the 3:1 large-text allowance applied by computed size and
weight. **Zero failures across all six sheet tabs.** It found one on the wizard, which is
pre-existing and not from this change; recorded as **N4**.

If the two rejected lines should change anyway they are a two-line follow-up. They were
left because applying them contradicts the finding's own rule, not because they were
awkward.

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

**Implemented and HELD, 2026-09-01 (PR #468) — deliberately not merged.** Posture held:
same two typefaces, same weights, transport only. It is complete and verified, and merging
it would degrade a live app until a Cloudflare dashboard change is made that cannot be
made from this repo. See **N5**.

**It is two files, not ten, because both faces are variable.** The finding inherited the
prompt's "one `@font-face` per weight". Google Fonts answers
`wght@300;400;500;600;700;800` with a single file and lets `font-weight` interpolate it:
the six Outfit downloads came back **byte-identical** (md5 `fdf9c509…`) and the four
JetBrains Mono ones likewise (`b636a65d…`). So this is two `@font-face` rules covering
every weight the four apps ask for, and **63KB rather than the 312KB** ten files would
have been.

**The weight list was also short by one.** The finding said JetBrains Mono 400/500/600,
reading nine of the ten pages; `apps/filament-forge/index.html` asks for **700** as well.
Moot in the end — a variable face covers the axis — but it would have silently synthesised
filament-forge's bold mono under the ten-file plan.

**The landing page is not like the other nine.** `index.html` at the repo root is the only
one of the ten that does **not** load `/shared/styles.css` — it is a self-contained file
with its own token vocabulary — so stripping its `<link>` left it with no font source at
all. Caught by measuring rendered text width rather than by `document.fonts.check()`, which
returns true for a system fallback and said everything was fine. It carries its own copy of
the two rules now, with a comment on both sides.

Verified on all ten pages: two faces `loaded`, the weight axis registering as `300 800` and
`400 700`, exactly two local font requests and none to `fonts.googleapis.com` or
`fonts.gstatic.com` anywhere in the tree. All four smoke suites pass. Both OFL licences
ship beside the files, as the licence requires.

---

## N — opened while taking R1–R7

Defects found *during* the work rather than during the audit, kept out of the PR that
found them because the numbering exists so the decision to take one can be separate.
**To be addressed after R7 is merged.** Same rules: take one at a time, on a word.

### N1 — low — The Vitals tab no longer holds the vitals

Opened by R2 (PR #463). The five pools now live in the sticky strip, so the tab still
called **Vitals** contains Attributes, Combat, Saving Throws and Experience, and not one
vital. R2's posture explicitly forbade changing which tabs exist, so the label was left
alone rather than quietly renamed inside another finding's PR.

**Proposal:** rename the tab — *Core* is the closest honest word for attributes, combat,
saves and XP. `TAB_IDS` is the id list and the label is separate (`sheet.js`, the tabbar
map), so the id `vitals` can stay and only the visible string changes. Keeping the id
matters: it is what `localStorage['sheet-tab-'+id]` and the `#vitals` hash both store, and
changing it would strand every saved tab and every pasted link.

**Posture: rename the label only.** No new tab, no reordering, no id change.

### N2 — low — The skill columns are cramped at 273px, but the sheet's width is the wrong lever

Opened by R3 (PR #464), which closed unadopted. Widening the whole sheet fixes the cramp
and costs the journal its reading measure — 56 characters per line to 85, measured. But
the cramp itself is real: three skill boxes at **273px** each, of which a fixed `46px` and
`40px` go to the two numeric columns, leaving roughly 160px for a name like *Language:
Native Tongue*. Four of 60 name cells wrapped to two lines at that width; none of the
other tabs asked for the extra room that fixing it would hand them.

**Proposal:** widen the container for the **skills tab only**, not the sheet — a modifier
on the skills `.tabpanel` (or its grid) rather than on `.wrap`, so the journal, bio and
gear tabs keep the 900px measure that `styles.css:77` argues for. Measure the same four
numbers before and after; the skills panel should shrink and the journal figure must not
move at all.

**Posture: one tab's width, not the sheet's.** If it cannot be scoped to the skills panel
without restructuring the grid, close it — R3 already showed the whole-sheet version is
not worth it.

### N3 — low — A finding heading cannot be linked to, and the smoke test and GitHub disagree about why

Opened by R2 and R3 (PRs #463, #464), which each tried to link one finding to another and
put a broken link on `main` for a few minutes.

The link checker in `test/checks/environment.mjs:336` slugs a heading by collapsing every
run of whitespace to **one** hyphen: `.replace(/\s+/g, '-')`. GitHub, rendering the same
file, strips the em-dashes and keeps the **two** spaces they leave behind, producing two
hyphens. For an ordinary prose heading the two rules agree, which is why every existing
anchor link in the repo works and why this went unnoticed. For this file's headings —
`### R4 — medium — Two different reasons…` — they disagree, so an anchor that satisfies
the test is broken on GitHub and an anchor that works on GitHub fails the test.

Both links were removed rather than resolved in either direction, since either choice is
wrong somewhere. Findings now refer to each other by bare number.

**Proposal:** make the checker's slug match GitHub's — strip the punctuation first and
*then* collapse, rather than collapsing what the strip left behind — so that
`R4 — medium — Title` yields the double hyphen GitHub yields. Verify by adding one link
to a dashed heading and confirming it resolves both in the test and on the rendered page.

**Posture: fix the checker, not the headings.** The heading format is shared with eight
other audit files and is not the thing that is wrong. No heading gets reworded to make a
link work.

### N4 — low — The not-applicable wizard step is 1.85:1 and says something worth reading

Found by R6's contrast sweep (PR #467), pre-existing and unrelated to that change.

`.stepper .st.na` (`styles.css:243`) is `opacity: 0.4` over `--text-muted` at 11px, which
composites to **1.85:1** — the only contrast failure the sweep found anywhere, against zero
across all six sheet tabs. It is not exempt as an inactive control: it is a `<span>`, not a
disabled button, and it carries information the player wants — *"8. Advancement — does not
apply to this character"*, with the explanation only in a `title` attribute a phone cannot
show.

This is also a correction to the UI audit's claim of zero failures across all five pages.
That sweep almost certainly exempted anything reading as disabled; this element reads as
disabled and is not.

**Proposal:** raise `.st.na` to roughly `opacity: 0.75` and confirm it clears 4.5:1 at
11px, or drop the opacity entirely and mark the state with the dashed border it already
carries. Either way, move the "does not apply to this character" explanation out of
`title=` into text, since a `title` tooltip has no phone equivalent.

**Posture: legibility only.** The step stays non-clickable and keeps its dashed border; it
is not being promoted to a control.

### N5 — high — `/shared/fonts/` needs an Access destination before R7 can merge

Opened by R7 (PR #468), which is held open because of this.

Pick 3 Cut 5 is played by people with a room code and no login, so its assets sit outside
the Access wall by explicit bypass. Measured against production with no session:

| path | status |
|---|---|
| `/shared/styles.css` | 200 |
| `/shared/js/ui.js` | 200 |
| `/shared/fonts/outfit-variable.woff2` | **302 → `fatmans.cloudflareaccess.com`** |

Merging R7 without the destination gives every unauthenticated player a page whose fonts
bounce off the login and fall back to system faces — the same failure the pick3cut5 smoke
test was written for after the app shipped in Times New Roman, arriving through the one
door that test cannot see (**N6**).

**Proposal:** add `shared/fonts` as a fifth destination on the *Pick 3 Cut 5 (public)*
Access application, then merge PR #468 and confirm with
`node apps/pick3cut5/test/smoke.mjs --remote`. `SETUP.md` already documents the row.

**This consumes the last destination slot.** The limit is five and four were in use; a
sixth public dependency now needs a second Access application rather than an edit.

**Posture: dashboard change, by Nate.** Access policy is a security setting and there is no
policy-as-code here; the repo's `CLOUDFLARE_API_TOKEN` is scoped to D1 and cannot write it.

### N6 — medium — The pick3cut5 public-path derivation cannot see assets referenced from CSS

Opened by R7 (PR #468).

`apps/pick3cut5/test/smoke.mjs` derives the set of paths needing an Access bypass by
matching `<script src>` and `<link href>` in `index.html`, and its own comment makes the
promise: *"Add a script tag for /shared/js/api.js and this notices."* It does. What it
cannot notice is an asset the browser fetches because a **stylesheet** asked for it —
`url()` inside `/shared/styles.css` is invisible to an HTML scan.

R7 is exactly that case, and the derived list stayed at two while the real dependency count
went to three. Nothing failed; the check simply had nothing to say.

**Proposal:** extend the derivation to follow the CSS it already found — for each absolute
stylesheet in the HTML, read it and collect absolute `url(...)` targets, folding each
asset's directory into `requiredPublic`. Keep the destination-count assertion pointed at
the widened list so the five-slot ceiling stays honest.

**Posture: widen the derivation, not the bypass.** The test should discover the
dependency; deciding it deserves a bypass stays a human step.

**Taken, 2026-09-01 (PR #469).** Posture held: the derivation widened, no bypass widened,
no Access policy touched. The test now discovers `/shared/fonts`; a human still decided it
deserved a destination, in the dashboard, before this ran.

**Three things this finding says are no longer or were never true.**

- **It says R7 is held open by N5. R7 merged** as `e40b6e1` on 2026-09-01, so the Access
  destination N5 asked for exists. Measured here with no session: both font files answer
  **200 `font/woff2`**, where N5 measured a 302 to `fatmans.cloudflareaccess.com`. This
  finding was written while that was still the open question and reads as though it still
  is.
- **"The real dependency count went to three" counts destinations, not files.** There are
  **two** `.woff2` files, and they fold into **one** destination — which is the whole
  reason the fold is by directory. A destination per font file would have spent slots four
  and five on one typeface and left the next weight nowhere to go.
- **The file's own comment said four destinations were in use.** Five are, and have been
  since R7. Corrected in the same commit; the ceiling assertion now computes 5 of 5 and
  fails at 6, which was checked rather than assumed.

**What the proposal did not account for, and what it cost.** `requiredPublic` was doing
three jobs — the SETUP.md lookup, the destination count, and the list of paths fetched
from production. Folding a directory into it is right for the first two and **wrong for
the third**: Pages answers a path it does not have with the workshop landing page, at
**200** and `text/html`, so probing `/shared/fonts` would have reported a font reachable
whether or not it was ever deployed. Measured directly:
`GET /shared/fonts/nope.woff2` → `200 text/html; charset=utf-8`, 4554 bytes, the same
bytes as `/shared/fonts/`. So the list was split: `requiredPublic` holds the three
**destinations** and drives the SETUP check and the count, and a second list holds the
four **files** the browser actually asks for and drives the live fetch. Each of those four
is now asserted to be 200 *and* not HTML.

The `gated` filter had to become a prefix match at the same time. It excluded the app's own
dependencies from the "still behind the wall" list with `requiredPublic.includes(p)`, which
stops working the moment an entry is a directory: an equality test would have demanded
`/shared/fonts/outfit-variable.woff2` be gated while the loop above insisted it be public,
and the contradiction reads as a broken test.

**Driven, not read.** Four deliberate breakages, each reverted:

| what was broken | what fired |
|---|---|
| a `url()` pointed at a font that is not on production | `reachable` **passed**, `served as an asset` failed — the case the content-type check exists for |
| a `url()` added for `/shared/img/paper.png` | SETUP.md check failed, and the ceiling failed at **6 of 5** |
| the stylesheet made relative, so the CSS half sees nothing | `read 0 of 0 — the CSS half of the derivation is blind` |
| a `?v=2` on the stylesheet href | derivation survived it and read the file; the pre-existing SETUP lookup fails loudly on the query string, which is the safe direction |

Counts: the derived destination list goes **2 → 3**, the computed total **4 → 5**, and the
suite **17 → 19** checks flagless, **23 → 31** with `--remote`. Both runs pass.

**Two sentences in `SETUP.md` are falsified by this and are corrected in the same commit** —
that the derivation "reads the HTML, so it cannot see them" and that the `shared/fonts` row
is "maintained by hand". A third sentence in that section is wrong for a reason this PR did
not cause, and is **N7** rather than a quiet fix here.

---

### N7 — low — `SETUP.md` says one more Access destination fits, and none does

Opened while taking N6. Pre-existing, and not caused by that change.

The Access section of `SETUP.md` says, at the end of the paragraph under the destination
table: *"Note Access allows five destinations per application, so one more dependency fits
and the one after that needs a second application."* Four were in use when that was
written. Five are in use now — `shared/fonts` was added by N5 — so **none** fits, and the
next dependency needs the second application today.

It contradicts a bolded sentence eight lines above it in the same section, which says
`shared/fonts` is "the fifth and last destination that fits". A reader who stops at the
first of the two gets the right answer and a reader who reads to the end of the paragraph
gets the wrong one, which is worse than either alone.

Nothing pins it. The smoke test asserts the ceiling against the derived list and asserts
that SETUP.md *names* each destination, but it has no opinion about the prose around the
table, and prose is what a person follows when they are standing in the dashboard.

**Proposal:** correct the sentence to say the five are spent, or delete it — the bolded
sentence above already carries the rule and carries it correctly. Do not add a check: the
count is already asserted where it can be asserted, and pinning a sentence would pin the
wording rather than the fact.

**Posture: documentation only.** No test change, no code change, no Access change.

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
