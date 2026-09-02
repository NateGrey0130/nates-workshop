# Take the N findings, one at a time

Take **N6, N1, N2, N4, N3** — in that order — from
`apps/character-creator/REDESIGN-AUDIT.md` in the monorepo at
`C:\Users\natha\Projects\nates-apps`. (Sessions start in `Downloads`; the repo is
elsewhere, and its `CLAUDE.md` does not auto-load from there — read it before touching
D1 or wrangler.)

N6 is first because it is the only medium, and because it is the reason a live app came
within one merge of breaking for every logged-out player.

Load the **`audit-menu`** skill before the first one and the **`ship-pr`** skill before
the first merge. They are the protocol; this prompt is only what those files do not say.

## The loop, per finding

1. **Audit the finding before scoping it.** Every finding taken in the previous batch had
   at least one wrong premise, and two would have shipped a regression if implemented as
   written. Distrust line numbers, counts, and any claim of the form "X is the only place".
   Lead the outcome note with the corrections.
2. Implement it **as written — scope and posture both**. If it is wrong, say so in the
   note and implement anyway, or stop and ask. Never quietly substitute your own scope.
   Taking part of a finding is allowed only if you say loudly which part and why.
3. **Verify by driving it**, not by reading it. See below.
4. Commit, open a PR, append the dated outcome note **under the finding, in the same PR**,
   including the posture said back and whatever contradicted the finding.
5. **Merge it, then confirm the deploy**, then start the next one. You have standing
   approval to merge each one.
6. **Do not merge anything site-breaking.** If a finding cannot be finished safely, leave
   its PR open, say why, and move to the next.

Anything you find along the way that is out of scope becomes a new numbered finding in the
same file — do not fix it inside another finding's PR.

## Verification that actually counts

- **The merge gate is the flagless `node apps/character-creator/test/smoke.mjs`.** A
  `--section` run prints `PARTIAL` on purpose and does not count.
- **Run the full smoke AFTER writing the outcome note, not before.** The note is prose in
  a checked file: last time a note's anchor link went red on `main` because the gate ran
  before the note existed.
- **Do not link findings to each other by anchor.** That is N3 — the checker and GitHub
  disagree about the slug for a `— severity —` heading. Refer to findings by bare number
  until N3 is fixed.
- **Drive the UI for anything visible.** Dev server: add/use the `nates-apps-8793` entry in
  `C:\Users\natha\Downloads\.claude\launch.json`. Port **8788 belongs to another worktree**
  and serves stale data.
- **Print changes need a real print render**, not a reading of the stylesheet:
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=20000 --print-to-pdf="<ABSOLUTE Windows path>" "<url>"`.
  `pymupdf` is installed; use it to extract the text rather than eyeballing.
- **Anything that adds a file fetched from CSS** (font, image, `@import`) must be curled
  against production before merge — see N6. A `200` is not proof: Pages answers a missing
  path with its landing page at 200 and `text/html`. Check the **content type**.

## Traps that cost time last session

- **Never `sed -i` a repo file.** It flips the whole file to LF and the obvious grep check
  still reports clean. Use the Edit tool. `.js`, `.css`, `.html`, `.md` are all CRLF here.
- **The Browser pane lies in three specific ways.** Screenshots come back blank while
  *scrolled* (shoot at `scrollY: 0`); `key`/`Enter` focuses but does not activate, so use
  `element.click()`; `read_page` prints a control's value, not its accessible name.
- **`document.fonts.check()` returns true for a system fallback.** To prove a webfont is
  really applied, measure rendered text width against a generic and confirm they differ.
- **The contrast scanner is not committed anywhere.** Write one: walk text nodes,
  composite every translucent layer down to opaque, apply the 3:1 large-text allowance by
  computed size and weight. The app currently measures **zero** failures on all six sheet
  tabs and exactly one on the wizard, which is N4.
- **Probe data goes in local D1 and comes back out.** Snapshot before, restore after, and
  check `character_drafts` at the end — walking the wizard creates one.
- **Merging immediately after pushing** gets `mergeable=UNKNOWN`. Wait a few seconds.
- **A merge commit on `origin/main` proves nothing about what is live.** Confirm with
  `gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs`, then ask production
  for something the change added.

## The five

- **N6 — medium — the pick3cut5 path derivation cannot see CSS-referenced assets.**
  Follow the CSS the test already found. Note the Access destination ceiling is **five and
  all five are now in use**, so the count assertion has to stay honest.
- **N1 — low — the Vitals tab holds no vitals.** Rename the label only. The id `vitals` is
  stored in `localStorage['sheet-tab-…']` and the `#vitals` hash — changing it strands
  saved tabs and pasted links.
- **N2 — low — the skill columns are cramped, but the sheet's width is the wrong lever.**
  Widen the skills `.tabpanel` alone. Measure the journal's characters-per-line before and
  after; it must not move. R3 already proved the whole-sheet version is a bad trade.
- **N4 — low — the not-applicable wizard step is 1.85:1.** Legibility only; it stays
  non-clickable. Also move its explanation out of the `title` attribute, which a phone
  cannot show.
- **N3 — low — the link checker and GitHub slug `— severity —` headings differently.** Fix
  the checker, not the headings. Verify by adding one link to a dashed heading and
  confirming it resolves **both** in the test and on the rendered GitHub page.

Start by reading the five findings in full, tell me what you find wrong in their premises,
and then take N6.
