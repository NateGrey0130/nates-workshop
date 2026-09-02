# Character Creator — UI change plan

Audit of `NateGrey0130/nates-workshop` @ `main`, tree `fa0bf978ec78`, read 2026-09-01.
Decisions from the ten-round brief are treated as settled and are not re-argued here.

---

## 1. What's actually wrong

The brief described a sheet where you "scroll and hunt." The code says something more specific, and mostly more fixable. Three of the four things I designed already exist in some form. The defects are in how they relate to each other.

### 1.1 There are two character sheets, and the good one is behind a toggle

`sheet.js` renders two separate DOM trees from two separate code paths:

| | Static sheet | Play mode |
|---|---|---|
| Container | `.sheet-grid` / `.box` | `.play-view` |
| Pool widget | `.vital` | `.play-pool` |
| Pool value size | **17px** | **26px** |
| Adjust | typed `input` only | `+`/`−` at 44px |
| Prints | yes | `@media print { .play-view { display: none } }` |

The pools you change constantly are rendered twice, at two sizes, in two widgets, and the better one is hidden behind `#play-toggle` — which is itself `style="display:none"` in `sheet.html` until JS reveals it. So the answer to "make live numbers the fastest thing on the page" is partly already built, and partly unreachable.

**This is the single biggest structural problem.** Not missing features — duplicated ones that disagree.

### 1.2 Tabs are unconditional

`.tabpanel { display: none }` carries no viewport condition. A 1440px desktop shows exactly one section at a time, the same as a 390px phone, on a page whose content would fit three columns. `REDESIGN-AUDIT.md:118` already caught this and it hasn't moved.

Tabs are the right answer on a phone and the wrong default on a desktop. Right now there is no desktop answer.

### 1.3 The sheet is trapped in a prose-width container

`.wrap` is `max-width: 900px`, correct for the wizard's forms and the journal, wrong for a 16-box sheet. The evidence is the escape hatch already in the stylesheet:

```css
.tabpanel[data-tab="skills"] {
  width: min(1224px, calc(100vw - 56px));
  margin-left: 50%;
  translate: -50%;
}
```

One tab breaking out of its own container with a centring trick is a container problem, not a skills problem. The comment defends it well — widening `.wrap` would push the journal to 85 characters per line — but the real fix is that the sheet and the journal shouldn't share a width constraint at all.

### 1.4 Numbers have no hierarchy

Every number on the sheet lands within two points of every other number:

- `.vital .val` — 17px — **current H.P.**
- `.pool .val` — 17px
- `.attr-stack .field > .val` — 15px — I.Q., set once at creation
- `.field > .val` — 13px inherited
- `.play-pool .pp-val` — 26px, but only in play mode

Current H.P. is 17px and I.Q. is 15px. The number you touch forty times a session and the number you touch once are the same size. That's the "hunt" in the brief, and it's a typographic problem, not a layout one.

### 1.5 Accent is spent on scenery

`.box > .box-title { color: var(--accent) }` puts the accent colour on **every section label on the sheet** — sixteen boxes, none of them clickable. Meanwhile `.power-row .cost` had accent removed for exactly this reason, and the `.tag.score` comment states the rule outright:

> `--accent` is reserved for what you can act on.

The rule is written down and the sheet's most repeated element breaks it. When every heading is accent-coloured, the `Use` button has no way to stand out.

### 1.6 Three number systems

JetBrains Mono is doing tabular alignment in `.vital`, `.attr-stack`, `.skill-table`, `.pool`, `.tag`, `.cat-key`, `.imp-tab-sub`, `.home-link`, `.play-pool`, `.play-melee`, and `.stepper`. Outfit does the rest. Retiring mono (your call, round 5) means every one of those needs `font-variant-numeric: tabular-nums` instead, or the columns break.

### 1.7 The wizard stepper is the weakest surface

`.stepper .st` is an 11px mono pill. Current, done, and N/A are distinguished by border colour and a background tint — three states carried entirely by colour on an 11px target. Nothing communicates position in a sequence: no numbers, no progression, no sense of seven. It also sits inside `.wrap` and scrolls away, so mid-wizard you can't see where you are.

The state model underneath is sound — completed steps are real `<button>`s, jumping back works — so this is presentation only.

### 1.8 Contrast: your "by eye" answer will fight the existing code

You chose no formal floor. Worth knowing what that collides with: `styles.css` contains four separate overrides that exist *only* because of measured contrast failures, each with the ratio in the comment — `--text-muted` (#5a6178 → #81889e), `--accent-strong` for `.btn-primary` (3.11 → 5.80), `.imp-tab.on .imp-tab-sub`, and `.dupe-badge`. `.stepper .st.na` has a comment explaining why it can't use opacity.

Two tokens in Rust & Ash land in the same trap:

| Token | On `--bg` #14110F | Verdict |
|---|---|---|
| `--text` #E9E3DA | ~14:1 | fine |
| `--dim` #9C9287 | ~6.0:1 | fine |
| **`--faint` #6B6259** | **~3.1:1** | fails small text — same failure as #5a6178 |
| **`--accent` #C4622D** | **~3.8:1** | fine for large/UI, fails as link text |
| `--accent2` #D9A05B | ~8.3:1 | fine |
| white on `--accent` | ~4.9:1 | **better than today's 3.11** |

Recommendation, not a re-ask: ship `--faint: #8A8076` (~4.8:1) and add `--accent-link: #D9733A` for inline links, keeping `#C4622D` for fills and borders. Costs nothing, preserves work already paid for. Say the word if you'd rather have the darker tones as designed.

---

## 2. What already exists and should be kept

Worth naming, because a redesign that discards these is a downgrade:

- **Print block** — thorough and correct. Filtered skills forced back with `display: table-row`, `break-after: avoid` between a skill and its footnote, `.tabpanel { display: contents }` to dissolve tabs on paper, `<thead>` repeating per page. Recolour it; do not rewrite it.
- **Focus rings** — `:where(button, input, a, summary, [tabindex]):focus-visible` with a 3px outline. Keep, retoned.
- **Disabled states** — `shared/styles.css` neutralises `:hover` on disabled buttons with a comment explaining why. Exactly the principle I asked for in the earlier prompt; already done.
- **`.nav-why`** — the sentence explaining why the wizard's primary action is unavailable. Better than most commercial wizards. Keep.
- **Play mode's 44px targets, `env(safe-area-inset-bottom)`, roll bar.** The phone thinking is done.
- **`fitColumns()`** in the catalog. Leave it entirely alone.

---

## 3. The plan

Nine phases, one PR each, via the `ship-pr` skill. Branch `redesign/rust-ash`.

### Phase 1 — Shared tokens

**`shared/styles.css`**

Replace the `:root` block. Keep every existing name; add the new ones. Nothing downstream renames.

```css
:root {
  --bg-primary:   #14110F;
  --bg-secondary: #1B1714;
  --bg-tertiary:  #221D19;
  --bg-card:      #1B1714;
  --bg-input:     #221D19;
  --border:       #302A24;
  --border-strong:#3D352C;   /* new — was hardcoded per-app */
  --border-focus: var(--accent);
  --text-primary: #E9E3DA;
  --text-secondary:#9C9287;
  --text-muted:   #8A8076;   /* contrast-adjusted, see 1.8 */
  --accent:       #C4622D;
  --accent-link:  #D9733A;   /* new — inline links only */
  --accent-glow:  rgba(196, 98, 45, 0.15);
  --accent-secondary: #D9A05B;
  --success:      #7E9A5E;
  --warning:      #C99A3E;
  --danger:       #A33B2A;
  --radius:       4px;       /* was 10px */
  --radius-sm:    3px;       /* was 6px */
  --radius-lg:    4px;       /* was 14px */
  --shadow:       none;      /* was 0 4px 24px */
  --transition:   0.2s ease;
}
```

`--radius-lg` collapsing to 4px keeps the token alive for the eleven rules that reference it rather than forcing a find-and-replace.

Also in this file:
- `.logo` — delete the `linear-gradient` / `-webkit-background-clip` / `-webkit-text-fill-color` trio, replace with `color: var(--accent)`.
- `.modal` — `box-shadow` removal follows `--shadow: none` automatically; verify no local shadow.
- Grep for `--shadow` across all four apps and confirm nothing hardcodes a blur.

**`apps/_template/styles.css`** — same tokens, so new apps don't scaffold the old violet back in. Also drop its `'JetBrains Mono'` reference.

**`apps/character-creator/styles.css`** `:root` — delete the local `--accent`, `--accent-glow`, `--accent-secondary`, `--text-muted` overrides now that shared carries the right values. **Keep `--accent-strong`** but retone it: white on `#C4622D` is already 4.9:1, so `.btn-primary` no longer needs a darker variant — set `--accent-strong: var(--accent)` and mark the override for deletion in a later cleanup, or delete it and the two `.btn-primary` rules now. Prefer deleting; it's twelve lines and two comments that no longer describe reality.

Rewrite the four contrast comments to describe the new values. They're load-bearing documentation and stale comments are worse than none.

*Verify:* all four apps render, nothing violet or blue remains. `grep -rn '#7c5cfc\|#4f8eff\|#9d7cff\|#6b4bd8\|#f0a04b' apps/ shared/` returns nothing.

---

### Phase 2 — Type

**`shared/fonts/`** — add `saira-condensed-variable.woff2` (100–900) and `ibm-plex-sans-variable.woff2` (400–600 + italic), both latin-subset. Ship `OFL-Saira.txt` and `OFL-IBMPlexSans.txt` beside them; both are OFL and the licence has to travel. Delete `outfit-variable.woff2`, `jetbrains-mono-variable.woff2`, and their two OFL files.

**`shared/styles.css`** — two `@font-face` rules replacing the existing two. The comment block explaining the variable-file consolidation stays; update the family names and byte counts. Then:

```css
body { font-family: 'IBM Plex Sans', system-ui, sans-serif; }
h1, h2, h3, h4, .logo, .btn, th { font-family: 'Saira Condensed', sans-serif; }
```

Body prose defaults to Plex; the condensed face is opt-in per element. That's the inverse of the current arrangement and it's what keeps journal entries readable.

**`apps/character-creator/styles.css`** — every `font-family: 'JetBrains Mono', monospace` becomes either:
- `font-family: 'Saira Condensed'; font-variant-numeric: tabular-nums` for numeric contexts — `.vital .val`, `.attr-stack .field > .val`, `.skill-table .num`, `.pool .val`, `.stat-row b`, `.play-pool .pp-val`, `.play-melee`, `.play-roll .pr-num`
- `font-family: 'Saira Condensed'` alone for label contexts — `.tag`, `.field > .lbl`, `.vital .lbl`, `.pool .lbl`, `.skill-head th`, `.imp-tab-sub`, `.home-link`, `.cat-key`, `.redirect-row .slug`, `.miss-row .slug`, `.stepper .st`
- **stays monospace** for genuine code: `.mono`, `textarea.mono`, `pre.snippet`. These need character-cell alignment, not number alignment. Use `ui-monospace, SFMono-Regular, Menlo, monospace` — a system stack, no download.

`button { font-family: 'Outfit' }` → `'Saira Condensed'`. `input/select/textarea` → `'IBM Plex Sans'` (typed text is prose, not display).

**Repo-wide** — grep `'Outfit'` and `'JetBrains Mono'` across all four apps' stylesheets and any inline styles in JS. `filament-forge`, `media-vault`, and `pick3cut5` all inherit `body` from shared, but each may set families locally.

*Verify:* Saira Condensed is 15–20% narrower than Outfit. Screenshot all four apps before and after at 1440 and 390. Expect reflow in `media-vault`'s dense lists; fix by letting lines run rather than by shrinking type.

---

### Phase 3 — Sheet: unify the two pool widgets

The dependency for everything after it. No visual redesign in this phase — one widget replacing two, same places, same behaviour.

**New in `styles.css`:** a single `.vital` that absorbs `.play-pool`'s affordances.

```css
.vital {
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-top: 2px solid var(--tone, var(--border-strong));
  border-radius: var(--radius-sm);
  padding: 7px 10px 8px;
  text-align: left;
}
.vital .lbl { font-size: 11px; font-weight: 800; letter-spacing: .16em; }
.vital .val { font-size: 44px; font-weight: 900; line-height: .95; letter-spacing: -.02em; }
.vital .val input { width: 100%; font: inherit; background: transparent; border: 0; text-align: left; }
.vital .max { font-size: 11px; font-weight: 600; color: var(--text-muted); }
.vital .bar { height: 3px; background: var(--border); margin-top: 6px; border-radius: 2px; }
.vital .bar > i { display: block; height: 100%; background: var(--tone); }
.vital .steppers { display: none; }           /* play mode reveals */
body.play-mode .vital .steppers { display: flex; flex-direction: column; gap: 2px; }
```

Per-pool tone set inline as `--tone` from `sheet.js`: H.P. `--danger`, S.D.C. `--warning`, M.D.C. `--accent-secondary`, P.P.E. `--success`, I.S.P. `--accent`. At ≤34% the value takes `--tone`; nothing else changes.

**`sheet.js`** — delete `.play-pool` rendering from `renderPlay()`, call the same pool component both paths use. Delete `.play-pool`, `.pp-label`, `.pp-val`, `.pp-max`, `.pp-btns` from the stylesheet.

Per your round-4 answer: the bar is always visible, steppers and `Use` buttons only in play mode. `body.play-mode` already exists as the hook.

*Verify:* pools render identically in both modes bar the steppers; print still shows values.

---

### Phase 4 — Sheet: layout

**Recommendation you asked me to make (round 4):** extract the sheet layout into `js/sheet-layout.js`, leave data logic in `sheet.js`.

Reasoning: `sheet.js` is 106KB and this phase touches the container, the grid, the tab logic, and the pool strip — the parts that are pure presentation. Extracting them makes the diff reviewable and gives the print block a single place to reason about. Extracting *all three screens* (the option I'm rejecting) means touching `app.js` at 188KB in the same breath as a visual redesign, and those are two different kinds of risk. One module, one screen, one PR.

Changes:

1. **`sheet.html`** — the sheet gets its own container. Add `<main class="wrap wrap-sheet">`, and:
   ```css
   .wrap.wrap-sheet { max-width: 1640px; }
   ```
   Then **delete** the `.tabpanel[data-tab="skills"]` viewport-escape block entirely. It exists only because `.wrap` was 900px. The journal keeps its measure by being constrained where it lives, not by constraining the sheet: `.box[data-box="journal"] .box-body { max-width: 66ch; }`.

2. **Three-column grid.** Replace `.sheet-grid.rail` usage with:
   ```css
   .sheet-grid.sheet-3 {
     grid-template-columns: 296px minmax(0, 1fr) 400px;
     gap: 14px; align-items: start;
   }
   @media (max-width: 1180px) {
     .sheet-grid.sheet-3 { grid-template-columns: 1fr 1fr; }
     .sheet-grid.sheet-3 > [data-col="c"] { grid-column: 1 / -1; }
   }
   ```
   Column assignment by lookup frequency, not topic — a: attributes, combat, saves, class panel. b: skills, W.P., equipment. c: powers, abilities, journal, session log.

3. **Tabs become a phone affordance.** This is the fix for 1.2:
   ```css
   .tabbar { display: none; }
   .tabpanel { display: contents; }
   @media (max-width: 820px) {
     .tabbar { display: flex; }
     .tabpanel { display: block; }
     .tabpanel[hidden] { display: none; }
     .sheet-grid.sheet-3 { grid-template-columns: 1fr; }
   }
   ```
   `display: contents` above 820px is the same mechanism the print block already uses, so the panels dissolve and the grid sees the boxes directly. The tab state in `sheet.js` can stay exactly as it is — it just stops having a visual effect on desktop.

4. **Sticky vitals.** The pool strip currently sticks together with the tab bar. Split them: pools stick always, the tab bar sticks only where it's visible.
   ```css
   .vitals-strip {
     position: sticky; top: 0; z-index: 20;
     background: var(--bg-secondary);
     border-bottom: 1px solid var(--border-strong);
     padding: 12px 20px;
   }
   .vitals { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; }
   @media (max-width: 820px) { .vitals { grid-template-columns: repeat(2, 1fr); } }
   ```
   Drop `minmax(84px, 1fr)` auto-fit — five named pools want five explicit columns.

5. **`.box > .box-title`** — `color: var(--accent)` → `color: var(--text-secondary)`, weight 800, `letter-spacing: .18em`. This is fix 1.5 and it's a one-line change with an outsized effect.

6. **Number scale** — `.field > .val` 13px unchanged; `.attr-stack .field > .val` 15px → 22px/800; `.vital .val` → 44px/900 (phase 3). Attacks-per-melee gets `.field.hero > .val { font-size: 30px; color: var(--accent); }`.

*Verify:* print unchanged — `.tabpanel { display: contents }` in the print block now matches the desktop default, so paper output should be byte-identical. Diff a print render before and after.

---

### Phase 5 — Wizard

**`index.html`** — move `<div class="stepper">` out of `.wrap` into its own sticky container so it survives scrolling.

**`styles.css`** — replace `.stepper` and its four state rules:

```css
.stepper {
  display: grid; grid-template-columns: repeat(7, 1fr);
  gap: 2px; margin: 0;
}
.stepper .st {
  display: block; text-align: left; padding: 0 0 9px;
  background: transparent; border: 0; border-bottom: 3px solid transparent;
  border-radius: 0; font-size: 15px; letter-spacing: .04em; text-transform: uppercase;
}
.stepper .st .n { font-size: 11px; font-weight: 800; color: var(--text-muted); }
.stepper .st        { font-weight: 300; color: var(--text-muted); }
.stepper .st.done   { font-weight: 600; color: var(--text-primary); border-bottom-color: var(--border-strong); }
.stepper .st.cur    { font-weight: 900; color: var(--text-primary); border-bottom-color: var(--accent); }
.stepper .st.cur .n { color: var(--accent); }
.stepper .st.na     { font-weight: 300; border-bottom-style: dashed; border-bottom-color: var(--border); }
```

Hierarchy from weight — 300 / 600 / 900 — which is what the nine-weight face was chosen for. `.na` keeps its dashed border and its full opacity; the existing comment about why opacity is forbidden still applies and should be preserved verbatim.

`sheet.js`/`app.js` must emit a `<span class="n">03</span>` inside each step. That's the only markup change.

**Summary strip** — new, under the stepper: system, class, attribute total, skill counts, credits, each a link back to its step. Derived from the existing wizard state object, stored nowhere new.

Mobile, below 900px: replace the 7-across grid with the step counter + title + seven progress bars pattern.

```css
@media (max-width: 900px) {
  .stepper { display: flex; gap: 3px; }
  .stepper .st { flex: 1; height: 20px; padding: 0; font-size: 0; }
  .stepper .st.cur  { height: 20px; }   /* bar heights via border-bottom-width */
}
```

**`.nav`** — sticky bottom, 44px minimum on both buttons. Keep `.nav-why` exactly as is.

---

### Phase 6 — Dashboard

Retheme only, per your round-6 answer, plus one structural change: **surface the notes panel.** It currently renders in document order below the roster. Move it to a right-hand rail beside the roster at ≥1100px, above the journal:

```css
.dash-grid { display: grid; grid-template-columns: minmax(0,1fr) 380px; gap: 14px; align-items: start; }
@media (max-width: 1100px) { .dash-grid { grid-template-columns: 1fr; } }
```

`.pools-cell` picks up tabular-nums from phase 2 and needs nothing else.

---

### Phase 7 — Print

Recolour, don't rewrite. In the existing `@media print` block:

- `.box > .box-title { background: #eee }` — keep; it reads correctly in the new scheme.
- Confirm `.vital .val` at 44px doesn't blow the paper layout — likely needs `@media print { .vital .val { font-size: 14pt } .vital .bar, .vital .steppers { display: none } }`.
- Add `.vitals-strip { position: static; }` and `.vitals { grid-template-columns: repeat(5, 1fr); }`.
- Add `.tabbar { display: none }` — currently covered by the blanket `button` rule, but the bar is a `div`, so make it explicit.
- Add `.sheet-grid.sheet-3 { grid-template-columns: 1fr 1fr; }`.
- `.session-log { display: none }` — a machine-generated event log has no place on a printed character sheet.

Target per your round-6 answer: a clean two-page sheet in the new design language. Verify at Letter and A4.

---

### Phase 8 — Trackable resources (schema)

Migration `043-class-trackable-resources.sql`, following the `schema-change` skill:

```sql
ALTER TABLE classes ADD COLUMN trackable_resources TEXT;  -- JSON array, NULL = not yet examined
```

Shape per entry: `{ key, label, max, maxFormula, resetOn, note }` — e.g. Juicer uppers as `{ key: "uppers", label: "Juicer Uppers", max: 3, resetOn: "day", note: "+1 attack, +2 initiative, 4 minutes" }`.

Populate on demand: on first play of a class with `trackable_resources IS NULL`, `functions/api/claude.js` reads the class text and writes the array. Non-blocking — the sheet renders without the panel and the panel appears when the call returns (your round-9 answer). `NULL` and `[]` are different: unexamined versus examined-and-none.

Renders into column A as a generic `.box` titled from the class name. No Juicer-specific CSS.

---

### Phase 9 — Play events, offline queue, conflicts

- Every pool change writes a play event (round 7).
- Optimistic local update; events queue in IndexedDB and flush on reconnect (round 8). IndexedDB over localStorage because the queue is unbounded during a long offline fight and localStorage is synchronous.
- Session log lives in a collapsible `.box` below the journal in column C (round 9), separate from the hand-written journal feed.
- **Conflict UI** (round 10): on sync, if the server value diverges from the queued base, the `.vital` value splits into two tappable halves — yours and theirs — with a hairline between and 10px labels. Cell keeps its size; nothing else on the sheet is blocked. Picking either resolves and flushes.

```css
.vital.conflict { border-top-color: var(--warning); }
.vital.conflict .val { display: grid; grid-template-columns: 1fr 1px 1fr; }
.vital.conflict .val button { font: inherit; background: transparent; border: 0; min-height: 44px; }
.vital.conflict .val .who { display: block; font-size: 10px; font-weight: 800; letter-spacing: .14em; color: var(--text-muted); }
```

---

## 4. Sequencing

Phases 1–2 are workshop-wide and safe. Phase 3 unblocks 4. Phases 5–7 are independent of each other. Phases 8–9 are feature work and can wait.

If you want value fastest: **1, 2, 3, 4** gets you the entire visual and structural redesign. Ship those four and reassess before committing to 8 and 9, which are the only phases that touch the database and the API.

## 5. Open risk

Retiring Outfit workshop-wide is the riskiest item and it's buried in phase 2. `media-vault` is 31KB of stylesheet I haven't read and its dense lists will reflow under a condensed face. If phase 2 screenshots look bad there, the cheap retreat is keeping IBM Plex Sans as the body face everywhere and scoping Saira Condensed to headers only — which costs nothing in character-creator, since that's already how I've specified it.
