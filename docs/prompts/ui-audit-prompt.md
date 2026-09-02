# Character Creator UI audit

Audit the Character Creator's user interface — every screen, at real viewports, by looking at it. Repo is `C:\Users\natha\Projects\nates-apps`; the app is `apps/character-creator/`. This is a read-only investigation: produce a findings menu, change nothing until I take findings one by one.

Scope is the interface only. Rules correctness, catalog data, book provenance and D1 contents are **out of scope** — they have their own audits, and a wrong skill percentage is not a UI finding. What *is* a UI finding: I could not see it, could not reach it, could not tell what it meant, or it looked different here than it looks two screens over.

Do not read the old `REVIEW-BRIEF.md` track G. It was never run, its baselines are stale, and I want this scoped from what the app is today.

## Setup

Read the repo `CLAUDE.md`, then `apps/character-creator/README.md` and `docs/wizard-and-sheet.md` — the wizard and sheet have documented intent, and "it does not match its own docs" is a finding worth separating from "I don't like it". Load the `audit-menu` skill for the finding/menu conventions before writing anything down.

Run the app locally on a port that is yours: use the `nates-apps-8791` (or `nates-apps-8793`) launch config from `C:\Users\natha\Downloads\.claude\launch.json`. **Port 8788 belongs to another worktree** — a server already listening there is not this checkout. Seed local D1 first (`npx wrangler d1 execute DB --local --file db/schema.sql` from the repo root); local D1 drifts from production in both directions, so if a screen is empty, confirm that is a seeding problem before calling it an empty-state bug.

You need real content to look at. An audit run entirely against empty states will miss everything that only breaks when full. Build or import at least: one Rifts character with a long skill list and gear, one Palladium Fantasy character, a campaign with several session entries, and leave one wizard draft abandoned mid-way. Then audit both states — full and empty — for every screen.

## Step 1 — inventory the screens

Walk and list every distinct view before judging any of them. Known surfaces:

- `index.html` — the ten-step wizard: System, Race, Attributes, Occupation, Skills, Equipment, Powers, Advancement, Details, Review. Plus the stepper, the resume-draft prompt, blocked/skipped steps, and every picker and modal the steps open.
- `dashboard.html` — the character list and entry point.
- `sheet.html` — six tabs: vitals, skills, powers, gear, bio, notes. Plus play mode (`▶ Play`), the dice/roller surfaces, and the **print stylesheet**, which is a real deliverable here — the sheet is meant to print after the official form.
- `campaign.html` — session log and play-time surfaces.
- `catalog.html` — browsing/filtering catalog rows.

For each, record the viewports you looked at and what state it was in. Screens reachable only from a particular character state (staged classes, psionics, MOS packages, level-up) count as separate views — find them via `docs/leveling.md` and `docs/race-and-occupation.md` rather than by clicking around and hoping.

## Step 2 — look at it, at four viewports

**Screenshot every screen at 390×844 (phone), 820×1180 (tablet), and 1440×900 (desktop), plus print preview for the sheet.** This is the step that gets skipped. A DOM measurement is not evidence: the tabs restructure measured as a clean success — page height 4105px → 1702px, every tab inside three tablet screens — and the first tablet screenshot showed the tab bar sitting *below the fold* with a screenful of blank bio fields above it. If a finding has no screenshot behind it, say so in the finding.

What to look for, in rough priority:

- **Above the fold.** At each viewport, what is visible before any scroll? If the primary control of a screen (tab bar, stepper, next button, search box) is below it, that is a finding regardless of how the page measures.
- **Overflow and clipping.** Long class names, wide skill tables, the gear list, modals taller than the viewport, anything with `position: fixed`. Horizontal scroll on the body is always a finding.
- **Density.** Screens that are mostly empty labels (the identity block precedent) and screens that are an undifferentiated wall of rows.
- **Print.** Page breaks mid-table, elements that should be `noprint` and aren't, ink-heavy dark backgrounds, and whether the printed sheet actually resembles the official form it is imitating.

## Step 3 — usability and flow

Judge each screen by whether someone could finish the task on it:

- **The wizard**: is it obvious what a step wants, what is required vs optional, why a step is blocked, and what "skipped" meant? Can you go back without losing work? Does the resume-draft path explain what it is resuming? What happens on the last step — is `Review` a review, or a second data-entry screen?
- **States**: every screen needs a loading state, an empty state that says what to do next, and an error state that says what failed. List the ones that have none, or that show `Loading…` forever on failure.
- **Destructive actions**: deleting a character, discarding a draft, resetting a step. Which are confirmed, which are one click, which are unlabeled?
- **Discoverability**: features that exist and cannot be found — play mode, the dice roller, hash-linked tabs, keyboard paths, whatever `docs/wizard-and-sheet.md` describes that the screen never mentions.
- **Feedback**: after a save, a roll, a level-up — does the screen tell you it worked? `shared/js/ui.js` has `copyWithFeedback` and `openModal` and nothing else; if the app is inventing its own toasts per screen, note where.

## Step 4 — visual consistency

The design system is `shared/styles.css` (the `--bg-*`, `--text-*`, `--accent`, `--radius`, `--shadow` token block) and it defines **zero media queries** — every breakpoint decision is per-app. `apps/character-creator/styles.css` is ~850 lines with media queries at six different max-widths plus print. Verify those numbers yourself, then judge:

- **Breakpoint sprawl**: are 620/700/780/820/860/900 six deliberate decisions or six accidents? Propose the smallest set that holds.
- **Token drift**: hardcoded colors, radii, spacing and font sizes that should be `var(--…)`. Group these — one finding per pattern, not per line.
- **Component drift**: the same thing (card, pill, table row, modal, empty state) built differently on the wizard than on the sheet than on the catalog. Note which version should win.
- **Cross-page shell**: the header, the `← workshop` link, the page title treatment. Two of five pages carry extra header buttons; check they line up.

Say explicitly which of these belong in `shared/styles.css` (and would then affect the other three apps) versus the app's own stylesheet. Anything you propose promoting to shared is a bigger finding than it looks — flag it as such.

## Step 5 — accessibility

Establish the current baseline by grep, then verify by keyboard:

- `aria-` / `role=` appear **four times in `sheet.js` and nowhere else** in the app — none in any of the five HTML shells. The tab bar, the stepper, and the modals are the three that most need roles and state.
- `:focus-visible` and `prefers-reduced-motion` do not appear in `apps/character-creator/styles.css`; the app's inputs set `outline: none` and change the border instead. **`apps/pick3cut5/styles.css` has both**, done well — use it as the in-repo precedent rather than inventing a new convention.
- Tab through each screen with the mouse untouched: can you complete the wizard, switch sheet tabs, open and close a modal, and escape out of a picker? Where does focus go when a modal opens and when it closes?
- Contrast: check `--text-muted` (`#5a6178`) and `--text-secondary` (`#8b92a8`) against the card backgrounds they actually sit on. Report ratios, not impressions.
- Hit targets at phone width, and any control that is a `<div>` with an `onclick`.

## Deliverable

Write `apps/character-creator/UI-AUDIT.md` in the same shape as the repo's other audit menus: numbered findings, most severe first, each with the screen, the viewport, what you saw (screenshot evidence, or an explicit note that there is none), why it is a problem, and a proposed fix scoped small enough to be one PR. Group by the five steps above, and keep a **screens inventory** section from Step 1 and a **verified-clean** section — screens you looked at hard and found nothing on are worth recording as such.

Keep screenshots in the session scratchpad and reference them by path; do not commit images to the repo. Do not quote a count you did not verify against the tree in front of you.

Findings only. Change no CSS, no markup and no docs during the audit. Stop when the menu is written.
