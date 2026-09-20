# UI-AUDIT.md — Character Creator interface

> **Since 2026-09-16 the closed findings live in `UI-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

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

- **F1** — high — Sheet › Gear: the inventory remove button is clipped off-screen at phone width — Taken, 2026-08-31 (PR #439). Implemented as written: `overflow-x: auto` on — full text in `UI-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — high — One attribute-minimum rule, three different behaviours, and the middle one's copy is false — Taken, 2026-08-31 (PR #441). Posture as written: copy and documentation only. — full text in `UI-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — high — Race step: 120 unfiltered class cards, and the primary button 12 screens down — Taken, 2026-08-31 (PR #442). Implemented as written: `Picker.inputHtml` above — full text in `UI-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — high — "Help me choose" returns all 120 classes, 38 of which match nothing, on a longer page — Taken, 2026-08-31 (PR #443). Implemented as written. The three questions and — full text in `UI-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — high — The wizard cannot be completed with a keyboard: every choice is a non-focusable `<div>` — Closed, 2026-08-31 (PR #446) — the remaining three sites. F5 is now fully — full text in `UI-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — high — `--text-muted` fails contrast on every background in the system, at 9–13px — Taken, 2026-08-31 (PR #451), with a scope Nate chose over the one proposed — full text in `UI-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — medium — Half the sheet's tabs are outside the visible tab strip at phone width — Taken, 2026-08-31 (PR #440). Implemented as written, at the breakpoint written, — full text in `UI-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — medium — Required-looking skill picks can be skipped in silence, and only an admin screen ever says so — Taken, 2026-09-01 (PR #455). Warn, do not block — posture said back — full text in `UI-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — medium — A refused save leaves an orphan campaign, and the landing page cannot tell the two apart — Taken, 2026-09-01 (PR #457). Display only, as the finding scopes it. Each — full text in `UI-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — medium — `.panel-inset` is used 16 times and defined nowhere — Taken, 2026-08-31 (PR #452). Both numbers hold: 16 uses (12 in `app.js`, 4 in — full text in `UI-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — medium — Three different tab bars do the same job in one app — Taken, 2026-09-01 (PR #454). The table is accurate — three components, — full text in `UI-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — medium — The Details step's ~20 fields have no programmatic label — Taken, 2026-08-31 (PR #448). Scope as written: the Details step only. The — full text in `UI-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — medium — Discarding an unfinished build is one unconfirmed click — Taken, 2026-09-01 (PR #455). All of it holds — `app.js` had zero — full text in `UI-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — medium — `@mentions` render as plain text, contradicting the instruction directly above them — Taken, 2026-09-01 (PR #454), after F5 and F11 as the finding instructs. — full text in `UI-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — medium — The catalog tab grid is hardcoded to 4 columns for 5 catalogs, and its tablet rule targets a class nothing uses — Taken, 2026-08-31 (PR #452), and it had a trap the finding did not see. — full text in `UI-AUDIT.closed.md` under its own `### F15` heading.

- **F16** — medium — No `:focus-visible` and no `prefers-reduced-motion`, while a sibling app has both done well — Taken, 2026-08-31 (PR #444). Copied verbatim from `apps/pick3cut5/styles.css`, — full text in `UI-AUDIT.closed.md` under its own `### F16` heading.

- **F17** — medium — Print: a long table splits across pages with no repeated header, and I could not render a preview — Closed as moot, 2026-09-01 (PR #459) — which is what this finding asks for. — full text in `UI-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — low — Catalog rows print raw JSON at the reader — Taken, 2026-09-01 (PR #456). Confirmed on the live page — the first skills — full text in `UI-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — low — Why a step is skipped is available only on hover — Taken, 2026-08-31 (PR #450). Both halves, in one edit, with the proposal's own — full text in `UI-AUDIT.closed.md` under its own `### F19` heading.

- **F20** — low — `var(--warn, …)` names a token that does not exist, so the fallback is permanent — Taken, 2026-09-01 (PR #453), with the foreground moved as Nate chose. — full text in `UI-AUDIT.closed.md` under its own `### F20` heading.

- **F21** — low — The catalog is 345 rows of ragged inline text with no pagination — Taken, 2026-09-01 (PR #456), and the proposal is half of the fix. The other — full text in `UI-AUDIT.closed.md` under its own `### F21` heading.

- **F22** — low — 21 bare `✕` buttons with no accessible name — Taken, 2026-08-31 (PR #447). Both renderers, `aria-label` and `title`, and the — full text in `UI-AUDIT.closed.md` under its own `### F22` heading.

- **F23** — low — Filtering one skill column to nothing leaves a 5,606px empty column beside the other — Taken, 2026-08-31 (PR #452). `align-items: start` added to `.cols`. — full text in `UI-AUDIT.closed.md` under its own `### F23` heading.

- **F24** — low — No `<h1>` on any page, and heading order skips levels — Taken, 2026-08-31 (PR #449). Five one-line edits, and the visual claim holds: — full text in `UI-AUDIT.closed.md` under its own `### F24` heading.

- **F25** — low — The app stylesheet's header comment describes three pages; there are five — Taken, 2026-08-31 (PR #452). The comment now names all five pages and says — full text in `UI-AUDIT.closed.md` under its own `### F25` heading.

- **F26** — low — One draft per person means you cannot park a build and start another — Taken, 2026-09-01 (PR #455). Documentation only, as proposed. One line — full text in `UI-AUDIT.closed.md` under its own `### F26` heading.

- **F27** — low — Back-link depth differs on all five pages — Taken, 2026-09-01 (PR #458) — the first half. The second half is moot, and — full text in `UI-AUDIT.closed.md` under its own `### F27` heading.

- **F28** — medium — White on `--accent` is 3.11:1, and it is every primary button — Taken, 2026-09-01 (PR #453), app-local, exactly as proposed. — full text in `UI-AUDIT.closed.md` under its own `### F28` heading.

- **F29** — low — The skills list is a div wearing a table's clothes, and its header cannot repeat in print — Taken, 2026-09-01 (PR #460), as written. All three skills lists are real — full text in `UI-AUDIT.closed.md` under its own `### F29` heading.

- **F30** — medium — The banked-picks picker offers every skill for every slot when one banked pick is secondary, and the server permits only one — Taken, 2026-09-03 (PR #657), as proposed. Posture held exactly: UI only — no — full text in `UI-AUDIT.closed.md` under its own `### F30` heading.

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

- **F31** — low — two of the six pages still skip a heading level, and `app.js` skips inside a page — Taken, 2026-09-06, with the posture WIDENED on Nate's word — markup plus the — full text in `UI-AUDIT.closed.md` under its own `### F31` heading.

- **F32** — low — `prefers-reduced-motion` is absent from the character creator, and present in the sibling app — Taken, 2026-09-06 (`UI-AUDIT` `F32`). Posture held: one media block in one app — full text in `UI-AUDIT.closed.md` under its own `### F32` heading.

## Filed while taking BOOK-INGEST-AUDIT F32, 2026-09-08

- **F33** — medium — an unmet class minimum has never rendered red, because `.err` loses to `.attr-note` — Taken, 2026-09-08 (PR #827). Presentation only, as proposed - nothing about — full text in `UI-AUDIT.closed.md` under its own `### F33` heading.

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

- **F34** — high — Every primary button drops to 1.17:1 on hover, and this file recorded the mechanism while it was still harmless — Taken, 2026-09-10 (PR #893). Posture held: shared stylesheet, all four apps, no — full text in `UI-AUDIT.closed.md` under its own `### F34` heading.

- **F35** — high — One `font` shorthand takes the wizard stepper out of its own typography, and deletes six of ten steps at phone width — Taken, 2026-09-10 (PR #894). Posture held: one declaration removed from one app — full text in `UI-AUDIT.closed.md` under its own `### F35` heading.

- **F36** — medium — The focus ring and the reduced-motion block were each scoped to one app on purpose, and the promotion neither of them made was never given a number — Taken, 2026-09-10 (PR #911). Posture held: shared stylesheet, no component change, — full text in `UI-AUDIT.closed.md` under its own `### F36` heading.

- **F37** — medium — The shared focus ring cannot reach a text control in any app, because `:where()` makes it the weakest selector in the cascade — Taken, 2026-09-10 (PR #913). Posture held: shared stylesheet only, no app edits, no — full text in `UI-AUDIT.closed.md` under its own `### F37` heading.

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

- **F38** — high — Typed sheet edits are discarded by any action that redraws the sheet — Taken, 2026-09-10 (PR #920). Posture held: no schema, no new route, the same — full text in `UI-AUDIT.closed.md` under its own `### F38` heading.

- **F39** — high — The character creator has no home: the roster lives on wizard step 1, and a draft hides it — Taken, 2026-09-10 (PR #921). Posture held: no schema; one query parameter on an — full text in `UI-AUDIT.closed.md` under its own `### F39` heading.

- **F40** — medium — Play mode cannot put a hit on armour or a vessel location — Taken, 2026-09-10 (PR #927). Posture held: extends one route; no schema — confirmed — full text in `UI-AUDIT.closed.md` under its own `### F40` heading.

- **F41** — medium — A weapon card's Strike ignores the weapon's own bonuses — Taken, 2026-09-10 (PR #926). Posture held: opt-in on every roll, never automatic. — full text in `UI-AUDIT.closed.md` under its own `### F41` heading.

- **F42** — medium — A pending level-up is invisible until someone logs XP — Taken, 2026-09-10 (PR #922). Posture held: extends one GET; no schema. The premise — full text in `UI-AUDIT.closed.md` under its own `### F42` heading.

- **F43** — medium — The Skills step is 13,978px of checkboxes — Taken, 2026-09-10 (PR #923), and WIDENED — the finding blamed the wrong part of the — full text in `UI-AUDIT.closed.md` under its own `### F43` heading.

- **F44** — medium — Play mode has no fast path: fixed amounts, no keys, one visible roll — Taken, 2026-09-10 (PR #924), in one PR with `F45` and `F50` — all three change — full text in `UI-AUDIT.closed.md` under its own `### F44` heading.

- **F45** — low — Drawing a carried weapon means leaving play mode — Taken, 2026-09-10 (PR #924, with `F44` and `F50`). Posture held: the Gear tab's own — full text in `UI-AUDIT.closed.md` under its own `### F45` heading.

- **F46** — medium — The campaign dashboard is read-only, so running a session means a tab per character — Taken, 2026-09-10 (PR #930). Posture held: GM-only controls, existing routes only. — full text in `UI-AUDIT.closed.md` under its own `### F46` heading.

- **F47** — low — The party stash takes free text only, so claimed loot can never be a weapon card — Taken, 2026-09-10 (PR #928). Posture held: UI only; the endpoint already takes the id. — full text in `UI-AUDIT.closed.md` under its own `### F47` heading.

- **F48** — low — The codex has no Skills or Classes — Taken, 2026-09-10 (PR #929). Posture held: read-only; no schema. Two sections on each — full text in `UI-AUDIT.closed.md` under its own `### F48` heading.

- **F49** — low — The related-skills allowance sentence contradicts itself — Taken, 2026-09-10 (PR #925, with `F51`). Posture held: copy only. One correction to — full text in `UI-AUDIT.closed.md` under its own `### F49` heading.

- **F50** — low — On a phone, play mode's controls push every tab down, and Rest is a small target below the fold — Taken, 2026-09-10 (PR #924, with `F44` and `F45`). Posture held: CSS and one — full text in `UI-AUDIT.closed.md` under its own `### F50` heading.

- **F51** — low — Three small accessibility and legibility gaps — Taken, 2026-09-10 (PR #925, with `F49`). Posture held: markup, CSS and a comment — — full text in `UI-AUDIT.closed.md` under its own `### F51` heading.

- **F52** — low — Rest rates are remembered per device, so a new phone starts blank — Taken, 2026-09-10 (PR #931). Posture held: a schema change — one nullable column, — full text in `UI-AUDIT.closed.md` under its own `### F52` heading.

## Opened by the F2 remainder, 2026-09-12

`F2`'s outcome note ends *"Neither gate moved, and reconciling (1) and (2)
remains open and unstarted."* Checking what that remainder is worth today turned
up something else: a live false sentence in a doc `F2` never touched.

- **F53** — medium - `race-and-occupation.md` says a missed attribute minimum is never a refusal, and it has blocked the save since before that sentence was written — Taken, 2026-09-12 (PR #969). Option A, as written. — full text in `UI-AUDIT.closed.md` under its own `### F53` heading.

- **F54** — low - the two attribute-minimum gates disagree by design, and reconciling them reverses a written decision whichever way it goes — Taken as option A, 2026-09-12 (PR #981), on Nate's word. Both steps block. — full text in `UI-AUDIT.closed.md` under its own `### F54` heading.

- **F55** — medium - `--border` never cleared 3:1, and since N4 it carries a STATE as well as decorating a panel — Taken, 2026-09-12 (PR #972). Option A. — full text in `UI-AUDIT.closed.md` under its own `### F55` heading.

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

**Adjusted 2026-09-20, while taking `F58`.** The sentence above about
`--print-to-pdf` is **wrong on this Chrome, and the record stands as written
above because that is what an audit file is.** Measured by extracting the
colour operators from the PDF's own content streams rather than by looking at a
render: `--print-to-pdf` emits `0.933 0.933 0.933` for `.box > .box-title`'s
`#eee` and, before `F58` was taken, `0.039 0.059 0.055` for `.sheet-sticky`'s
`--bg-primary`. **Backgrounds print.** No `print-color-adjust` exists anywhere
in this repo, so nothing else explains it.
<!-- claim-ok: naming the sentence this correction is about -->

What that does to **this** finding: its *"not settled"* half is now settleable
with the recipe it said could not see it, and the two backgrounds it asks about
- `.lvl-row` and `.cat-row.open` - would print. **It changes nothing about
`F56`'s outcome**, which turned on reachability: the wizard and the catalog
still have no print affordance, so the ink is still unreachable and the finding
is still correctly closed.

**Ongoing cost:** none.

**Subject grep, 2026-09-12:** every `*AUDIT*.md` (root and under `apps/`) plus
`SETUP-v2-CHANGES.md` for `@media print`, `printBackground` and `snippet`:
`F17` itself and `REDESIGN-AUDIT` `R6`, which is about accent colour on screen.
The memory store has `print-render-headless-chrome.md`, cited above, which
records that the headless method **falsified `F17` outright** and says nothing
about the ink remainder. Nothing to argue past.

## Filed while shipping P4b, 2026-09-20

Present mode (PR #1193) puts a campaign picture on a whole screen for the first
time, which is where the byte question stops being an abstraction. Filed rather
than fixed on sight, and filed rather than left as a remark, per `META-AUDIT`
`A16`.

### F57 - low - every campaign picture and NPC portrait is served at the size it was uploaded, two of the three views that show one want a fraction of it, and this platform cannot resize an image

**What the code does.** `functions/api/character-creator/campaigns/[id]/images/[imageId].js`
returns `object.body` straight out of R2 with the stored content type and no
transform; `campaigns/[id]/npcs/[npcId]/portrait.js` does the same. Read on
`main` @ `f61c537`, 2026-09-20. The caps are **5MB per picture and 20 pictures
per page** (`campaigns/[id]/entries/[entryId]/images.js`, `MAX_BYTES` /
`MAX_PER_ENTRY`), so one page of maps is allowed to be 100MB of bytes that
every member fetching the Handouts tab pulls in full.

**Three views show a picture and only one of them wants the pixels.** The GM's
editor strip caps a picture at 160px tall (`.setting-pic img`,
`apps/character-creator/styles.css`), the players' Handouts tab at 70vh
(`.handout img`), and present mode fills the screen (`.present-frame img`). The
first two download the whole file to paint a fraction of it. `loading="lazy"`
on both list views defers that fetch; it does not shrink it.

**A server-side resize is not available here, and the repo already says so in
the place where it matters.** `docs/pages-to-workers-migration.md:40` is a
gains-table row reading **Image Resizing binding — Workers yes, Pages no**,
whose "why it matters here" column is *"NPC portraits are served out of R2 at
full size"* (read 2026-09-20). So this is a reason on the migration's side of
the ledger rather than something a Function here can be taught to do.
<!-- claim-ok: quoting the row this finding rests on -->

**Nobody has paid this cost yet, which is the whole reason to file it now.**
Measured against production, 2026-09-20, `scripts/q.mjs --remote`:
`campaign_images` **0 rows**, `campaign_entries` **0 rows**, `npcs` **0 rows**.
There is no picture in production to migrate, so every option below is
cheaper today than it will ever be again.

**Proposal — three options, and they are not equivalent.**

- **A (recommended): downscale in the browser before the POST.** `uploadPicture`
  in `apps/gm-tools/dashboard.js` already has the `File`; draw it through a
  canvas with the longest edge capped (2048px is more than any table screen
  resolves, and present mode is the only view that wants more than 1000),
  re-encode, and send that. **Posture: a cap at upload, nothing stored changes,
  no existing row is touched, and no server code moves.** The trade is
  information loss that cannot be undone — a GM who wants to zoom into a map has
  no zoom in present mode today, so the loss is theoretical until one exists.
- **B: store a second, smaller object per picture** and serve it to the two list
  views behind a `?size=` parameter, falling back to the full object when the
  small one is absent. **Posture: additive.** It is the only option that keeps
  the original bytes. It costs a second R2 object per picture, a key convention
  or a column, and a fallback branch that stays forever.
- **C: documentation only.** Record the cost beside the 5MB cap in
  `apps/character-creator/README.md` so the next person does not find it on a
  phone at a table. **Posture: no code.**

**Evidence:** the four source files above, read 2026-09-20 on `f61c537`; the
three production counts by `scripts/q.mjs --remote`, same day; the migration
doc's row, same day. Nothing here is inferred.

**Confidence: high on the mechanism, and deliberately low on whether it
matters.** No picture has ever been stored in production, so the impact is a
prediction about how Nate will use the feature — one 5MB scan of a two-page map
spread is the case that hurts, and a handful of 300KB portraits is not. **What
would raise it: a month of real use, then the same three counts and
`sum(byte_size)` again.** That is also the argument for A over B: A is a
20-line change that stops the bad case without needing to know whether it will
happen.

**Ongoing cost.** A: one browser-side function, and a cap someone will
eventually want to raise. B: a second object per picture forever, plus the
fallback branch. C: a sentence that has to stay true.

**Subject grep, 2026-09-20:** every `*AUDIT*.md` at the root and under `apps/`,
plus `SETUP-v2-CHANGES.md` and the memory store, for `thumbnail`, `resize`,
`downscal`, `srcset`, `byte_size` and `portrait_key`. Two hits worth naming, and
**neither settles this**. `apps/character-creator/docs/campaign-and-play.md:253-254`
rejects base64 data URIs in D1 partly because *"thumbnails only is a rule nobody
remembers in six months"* — that is an argument about storing images in the
database, not about what size leaves the bucket, and option B above is the
version of it that would inherit the objection.
`apps/character-creator/UI-AUDIT.closed.md:1334` is about not resizing equipment
row buttons. Nothing on any menu has weighed this.

**Taken as option A, 2026-09-20 (PR #1201), on Nate's word.** Posture as
written: *"a cap at upload, nothing stored changes, no existing row is touched,
and no server code moves."* All four hold — the change is one new browser-side
file, two lines of `uploadPicture` and a line of copy.

**The production counts were re-run before building** and still read zero:
`campaign_images` 0, `campaign_entries` 0, `npcs` 0, and `npcs` with a
`portrait_key` 0 (`scripts/q.mjs --remote`, 2026-09-20). Nothing to migrate,
which is what made "now" the cheap moment.

**What shipped.** `apps/character-creator/js/downscale.js`, a classic script
with one global, loaded before `dashboard.js`. `downscale.toUpload(file)`
decodes with `createImageBitmap`, and when the longest edge is over 2048 draws
it to a canvas at that cap and re-encodes **in the same type it arrived in**.
Everything else hands the original `File` straight back.

**FIVE CORRECTIONS FROM THE TAKE-TIME PREMISE AUDIT, four of which changed the
code that was written:**

1. **The header must come from the BLOB, not the File**, and option A's text
   never said so. The server reads that one header to pick the R2 key's
   extension, the stored `content_type` and the `Content-Type` it serves back
   later, so sending a re-encoded blob described by `file.type` would have been
   wrong in three places at once. `uploadPicture` now sends `body.type`.
2. **`canvas.toBlob` cannot produce `image/gif`** — browsers fall back to PNG —
   so re-encoding an animated gif silently flattens it to one frame. The upload
   allowlist accepts gif, so gif is excluded from re-encoding outright. The
   finding's stated trade was only the loss of zoom detail; losing animation was
   a second, unnamed loss.
3. **A small PNG can come out LARGER from a re-encode**, which would have pushed
   a picture towards the 5MB cap rather than away from it. A blob bigger than
   its original is discarded and the original sent.
4. **The type is preserved rather than chosen.** A PNG re-encoded to JPEG loses
   its transparency, and these are maps and portraits rather than photographs to
   optimise — the point is the pixel count, not the codec.
5. **The posture sentence undersold one behaviour change.** A photo over 5MB
   used to be refused by the server outright; it now usually downscales under
   the cap and succeeds. That is an improvement, but it falsified the UI copy
   *"Up to 5MB each"*, which has been rewritten to say what actually happens.

**And the finding's own title overreached.** It says *"every campaign picture
**and NPC portrait**"*, but option A names only `uploadPicture` in
`apps/gm-tools/dashboard.js`. NPC portraits are uploaded by a different
function in a different app — `uploadPortrait`, `apps/campaign/campaign.js` —
which this PR does not touch. **That half is filed as `F59` below rather than
quietly widened into this one or quietly dropped**, per `audit-menu` → *A
deferral is work*.

<!-- claim-ok: quoting the premises and the title this note corrects -->

**Not done, and deliberately:** options B and C are untouched. B remains the
only option that keeps the original bytes, and this one throws them away at the
door — which is the trade the finding named and Nate chose.

## Filed while taking UI-AUDIT F57, 2026-09-20

### F59 - low - NPC portraits upload from a different app and were left at full size when F57 was taken

**Why this exists.** `F57`'s title claims campaign pictures *and* NPC
portraits; its option A names one function, in one app, and that function has
nothing to do with portraits. Taking `F57` fixed half of what it said it
covered, and this is the other half with a number on it rather than a sentence
inside a closed finding.

**What is true.** `uploadPortrait` in `apps/campaign/campaign.js` POSTs the raw
`File` to `campaigns/:id/npcs/:npcId/portrait` with `Content-Type: file.type` —
the same shape `uploadPicture` had before `F57`. Read 2026-09-20 while taking
`F57`; the premise audit for that finding located it.

**And the ratio is worse than anything in `F57`'s table.** A portrait is painted
at **34px** in the roster row and **120px** in the dossier
(`apps/campaign/campaign.js`, both inline styles, same read). `F57` counted
three views and missed these two; they are the smallest consumers in the app.

**Proposal.** Call the helper `F57` already shipped:
`downscale.toUpload(file)` in `uploadPortrait`, take the `Content-Type` from
what it returns, and load `js/downscale.js` in `apps/campaign/index.html`.
**Posture: identical to `F57` option A** — a cap at upload, nothing stored
changes, no existing row is touched, no server code moves. A portrait wants a
smaller cap than a map does, and picking one is the only decision here.

**Evidence:** the two files above, read 2026-09-20. `npcs` holds **0 rows** in
production with **0** portraits (`scripts/q.mjs --remote`, same day), so as with
`F57` there is nothing to migrate and the cheap moment is now.

**Confidence: high** — the mechanism is the one just shipped and tested one app
over. **What would raise it further:** nothing worth waiting for.

**Ongoing cost:** one line in `uploadPortrait`, one script tag. The helper and
its cap already exist.

**Subject grep, 2026-09-20:** the same sweep `F57` records, plus `uploadPortrait`
and `portrait_key` across every `*AUDIT*.md` and the memory store. The only hits
are `F57` itself and `README.md`'s schema table describing `portrait_key` as an
R2 object key. Nothing has weighed it.

## Filed while shipping P5c, 2026-09-20

Found by rendering the print stylesheet rather than reading it, which is the
thing `verify-ui` §4 exists to insist on. Filed, not fixed: P5c is about
hierarchy on screen and this is a paper defect with its own cause.

### F58 - medium - the pool strip prints as a black band with its labels invisible, and takes a quarter-page of ink with it

**What the render shows.** `--print-to-pdf` on the sheet, rasterised at 100dpi,
`main` @ `5ac8c0d`, 2026-09-20. Page 1 of 4: the three pool cards sit in a
**solid black band** running the full text width. The numbers survive - `14 /
14`, `11 / 11`, `1 / 13` are legible - but **the labels H.P., S.D.C. and P.P.E.
are dark grey on black and cannot be read**, and the band continues as an empty
black rectangle across the ~45% of the width the three cards do not fill.

**It is not P5c's, and that was checked rather than assumed.** The same page
was rendered twice, once with the P5c working tree stashed and once with it
applied: the band is byte-identical in both and the only difference on the page
is the character's name. Both PNGs are in that session's scratch directory;
the method is the A/B, not the artefacts.

**The likely cause, and it is a guess flagged as one.** The print block resets
`.panel, .box` to a white background and `.box > .box-title` to `#eee`, and
`.vital` is neither - it keeps `--bg-card` and its `--tone` top rule, so it
prints whatever the screen palette says. `.vitals-strip` IS named in the print
block, for `padding-top` and `break-inside`, so the strip was considered and
the cards inside it were not. **Not verified by editing the rule** - that is
the taker's first step.

**Proposal.** Give `.vital` the same paper treatment the boxes already get: a
white ground, `#000` label and value, and the `--tone` rule kept as a thin rule
rather than a fill, since which pool is which is the one thing the tone
carries. Then decide what the empty remainder of the band should be - the grid
is `auto-fit` at a 84px minimum, and on paper five columns of three cards
leaves two columns of nothing. **Posture: print-only, no screen change**, which
is the part to hold: the strip on screen is the sheet's strongest element and
this finding is not an argument to touch it.

**Evidence:** two headless renders, stashed and applied, 2026-09-20; the print
block read at `apps/character-creator/styles.css` in the same pass. The cause
is **inferred from reading the print block**, not measured.

**Confidence: high that it prints this way** - it was looked at twice, in two
tree states. **Low on the cause**, and what raises it is one edit: give
`.vital` a white background in the print block and re-render.

**Ongoing cost:** a handful of print rules, in a block that already carries
~40. No new mechanism.

**Subject grep, 2026-09-20:** every `*AUDIT*.md` at the root and under `apps/`
plus the memory store for `vital`, `vitals-strip`, `print` and `@media print`.
The print block's own history is in `UI-AUDIT.closed.md` `F17` (ink on four
selectors, closed as unreachable) and `F56` (its remainder, closed on a
re-measurement). **Neither is about the pool strip**, and `F56`'s note records
that the headless method falsified `F17` outright - which is the same method
that found this. Nothing has weighed it.

**Taken, 2026-09-20 (PR #1200). Posture as written: print-only, no screen
change.** Two CSS rules in the later print block, no screen rule touched.

**FIVE OF THIS FINDING'S OWN PREMISES WERE WRONG**, and the take-time premise
audit caught all five before anything was built. Recorded here because the
finding was filed the same day by the same session, which is the case
`audit-menu` says the auditor exists for.

1. **The band is not the cards.** It is `.sheet-sticky`, whose
   `background: var(--bg-primary)` no print rule reset; the two empty tracks
   that three pools leave in a five-column strip are what show it. Implementing
   the proposal as written - whitening `.vital` alone - would have left a black
   band with three white holes punched in it.
2. **`.vital` does not use `--bg-card`.** It is `--bg-tertiary`
   (`styles.css:927-934`). `--bg-card` is the token the print block already
   neutralises, so a taker checking the finding's claim would have found it
   handled and called the finding stale.
3. **"The cards were not considered" is false.** `.vital` is named in five
   print rules across two print blocks.
4. **The labels needed nothing.** They read as invisible because the ground was
   black; `.vital .lbl` is already `#333` from the print block, which is 12.6:1
   on white. The proposal's `#000` would have edited a rule that also governs
   `.field > .lbl` and `.skill-head th`, moving two other things.
5. **`--tone` was never a fill.** It is a 2px top border, and
   `.vital { border-color: #999 }` in the print block already destroyed it on
   paper - so "keep the tone as a thin rule" described something that was
   already gone. Re-asserting `border-top-color` is the one thing here that
   ADDS to the page rather than removing from it.

**Measured from the PDF's own content streams, not from a screenshot**
(`--print-to-pdf`, colour operators extracted, 2026-09-20):

| | before | after |
|---|---|---|
| the 720x51pt band | `0.039 0.059 0.055` (#0A0F0E, `--bg-primary`) | `1 1 1` |
| the three cards | `0.118 0.153 0.141` (#1E2724, `--bg-tertiary`) | absent |
| per-pool tone on paper | absent | `--danger`, `--warning`, `--success` all present |

**The empty remainder needed no work.** The finding asked what should be done
about the two blank grid tracks; once the parent is white they are white, and
the `repeat(5, 1fr)` was never the problem.

<!-- claim-ok: quoting the premises this note corrects -->

**And it falsified a claim on this menu.** `F56`'s note says *"`--print-to-pdf`
defaults [printBackground] off, so the recipe in `print-render-headless-chrome.md`
cannot see it."* **That is false on this Chrome** - see the dated correction
under `F56`, measured in the same pass.
