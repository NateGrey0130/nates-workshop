# REDESIGN-AUDIT.md — what survived the redesign prompt

> **Since 2026-09-16 the closed findings live in `REDESIGN-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **All 15 items are closed**, re-verified on 2026-09-02: `R1`–`R7` and `N1`–`N8`.
>
> **Two that misread:** `R3` is **closed unadopted** (PR #464) — decided against,
> not outstanding. And `R7`'s note first recorded a **hold**; the rest of the
> story was appended later (PR #477), so reading only the first paragraph of it
> reports work that has since shipped.

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

- **R1** — high — The sheet offers a **Use** button the pool cannot pay for, then refuses the click — Taken, 2026-08-31 (PR #462). Posture held: dim and disable, never hide. The finding — full text in `REDESIGN-AUDIT.closed.md` under its own `### R1` heading.

- **R2** — high — Current H.P. is unreachable from five of the six tabs — Taken, 2026-08-31 (PR #463). Posture held: one strip, no new grid, no new tab scheme, — full text in `REDESIGN-AUDIT.closed.md` under its own `### R2` heading.

- **R3** — medium — The sheet is 900px wide and spends none of a 1440 screen on its longest list — Closed unadopted, 2026-08-31 (PR #464). The posture decided it: the numbers came back — full text in `REDESIGN-AUDIT.closed.md` under its own `### R3` heading.

- **R4** — medium — Two different reasons a skill row is blocked render identically — Taken, 2026-08-31 (PR #465). Posture held: a muted span appended to the label, the same — full text in `REDESIGN-AUDIT.closed.md` under its own `### R4` heading.

- **R5** — medium — The sheet's skills list has no filter and no count — Taken, 2026-08-31 (PR #466). Posture held: the existing `.pick-filter`, skills only, — full text in `REDESIGN-AUDIT.closed.md` under its own `### R5` heading.

- **R6** — low — Four of the twenty-two `--accent` uses sit on things you cannot act on — Taken in part, 2026-08-31 (PR #467): two of the four lines. Posture held — no palette — full text in `REDESIGN-AUDIT.closed.md` under its own `### R6` heading.

- **R7** — low — Every page in the repo fetches its fonts from a third-party CDN — Merged 2026-09-01 as `e40b6e1`, 07:00 — the note above was written while the hold was — full text in `REDESIGN-AUDIT.closed.md` under its own `### R7` heading.

## N — opened while taking R1–R7

Defects found *during* the work rather than during the audit, kept out of the PR that
found them because the numbering exists so the decision to take one can be separate.
**To be addressed after R7 is merged.** Same rules: take one at a time, on a word.

- **N1** — low — The Vitals tab no longer holds the vitals — Taken, 2026-09-01 (PR #470). Posture held: one string changed, `sheet.js:1152`, — full text in `REDESIGN-AUDIT.closed.md` under its own `### N1` heading.

- **N2** — low — The skill columns are cramped at 273px, but the sheet's width is the wrong lever — Taken, 2026-09-01 (PR #471). Posture held: one tab's width. `.wrap` is untouched at — full text in `REDESIGN-AUDIT.closed.md` under its own `### N2` heading.

- **N3** — low — A finding heading cannot be linked to, and the smoke test and GitHub disagree about why — Taken, 2026-09-01 (PR #473). Posture held: `test/checks/environment.mjs` changed, not one — full text in `REDESIGN-AUDIT.closed.md` under its own `### N3` heading.

- **N4** — low — The not-applicable wizard step is 1.85:1 and says something worth reading — Taken, 2026-09-01 (PR #472). Posture held: legibility only. The step is still a — full text in `REDESIGN-AUDIT.closed.md` under its own `### N4` heading.

- **N5** — high — `/shared/fonts/` needs an Access destination before R7 can merge — Done, 2026-09-01 — note written late, PR #476. Posture held exactly: the destination was — full text in `REDESIGN-AUDIT.closed.md` under its own `### N5` heading.

- **N6** — medium — The pick3cut5 public-path derivation cannot see assets referenced from CSS — Taken, 2026-09-01 (PR #469). Posture held: the derivation widened, no bypass widened, — full text in `REDESIGN-AUDIT.closed.md` under its own `### N6` heading.

- **N7** — low — `SETUP.md` says one more Access destination fits, and none does — Taken, 2026-09-01 (PR #474). Posture held: one sentence deleted from `SETUP.md`. No test — full text in `REDESIGN-AUDIT.closed.md` under its own `### N7` heading.

- **N8** — low — The forgotten-two sentence in `SETUP.md` now points at the wrong two — Taken, 2026-09-01 (PR #475). Posture held: the bolded sentence and the pronoun that — full text in `REDESIGN-AUDIT.closed.md` under its own `### N8` heading.

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
