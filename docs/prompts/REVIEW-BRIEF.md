# Review brief — character creator: health, ingestion, and UI audit

You are running a **read-only audit** of the **character creator app**, written
2026-08-26. Read this whole file first, then do your assigned track.

Start the session **at the repo root** (`C:\Users\natha\Projects\nates-apps`) so
`.claude/skills/` loads. Do not run this from Downloads.

## Scope: the character creator only

In scope: `apps/character-creator/**`,
`functions/api/character-creator/**`, the character-creator tables in
`db/schema.sql`, the ingestion tooling that serves it (`scripts/`,
`.claude/skills/`, `.cache/books/`), and the parts of `shared/`,
`functions/api/_lib/`, `CLAUDE.md` and `SETUP.md` that **govern character-
creator work**.

Out of scope: Filament Forge, Media Vault, Pick 3 Cut 5, the standalone
`workers/pick3cut5-room/` deploy, the landing page and `apps/manifest.json`, and
monorepo-wide concerns that do not change how the character creator is built or
run. If a finding starts in the character creator and its fix necessarily lands
in shared code, that is in scope — say so in the finding. Do not go looking for
cross-app cleanups on their own merit.

---

## What this is and is not

This produces **a findings menu, not a fix**. The repo's established rhythm is:
findings carry `F<n>` numbers with a one-paragraph `Proposal:` line; Nathan says
"take F6"; that becomes one PR, with a `Taken, <date>:` note appended under the
finding in the same PR; he says "merge it" separately. Precedents:
`apps/character-creator/AUDIT.md`, `CLASS-AUDIT.md`, `DOCS-AUDIT.md`,
`EFFICIENCY-AUDIT.md`.

**Change nothing except the audit file you are writing.** The one exception the
prior audits used: unambiguous rot in *live instructions* (a skill or CLAUDE.md
telling a future session to do something impossible) may be fixed in the same
PR, and must be listed at the top under "fixed in this PR".

Do not open a PR for the audit file until Nathan has read the findings.

## Ground rules, each of which has cost a prior session real time

1. **Verify every premise against the current tree before scoping a finding.**
   The four existing audit files describe the repo several refactors ago. The
   character-creator README was split on 2026-08-26 (PR #309) into an 827-line
   spine plus eleven files under `apps/character-creator/docs/`; anything citing
   `README.md:NNN` predates that.
2. **Absence claims must be verified against a fresh read, not a grep.** A prior
   audit reported seven classes missing attribute requirements; five were
   present in a multi-line form the grep did not match. If you claim something
   is missing, open the file and show it is missing.
3. **Local D1 is stale and is not a mirror.** Query production:
   `node scripts/q.mjs --remote "SELECT ..."` — the SQL is **positional**, one
   statement on one line; `--command` is wrangler's flag, not q.mjs's, and
   passing it silently mangles the query. Use `--batch <file.sql>` for a volley,
   and `char(34)` rather than `\"` for a quote. Health check for wrangler auth
   is `npx wrangler d1 info nates-workshop-media`, not `wrangler whoami`, which
   exits non-zero by design under the D1-scoped token.
4. **Numbers rot unless the test suite pins them.** Any count you put in the
   audit is a dated measurement — say when you measured it and against what.
   Never restate a number from an older audit as current.
5. **The existing audit files are records.** Do not rewrite their measurements
   or `README.md:NNN` citations. If one is now misleading, add a dated banner,
   as PR #310 did.
6. **Do not re-find closed work.** `AUDIT.md` F1–F14 are closed. `CLASS-AUDIT.md`
   F1–F20 and S1–S9 are all taken. `EFFICIENCY-AUDIT.md` F1–F6 are taken; **F7
   (class-check `--field-sources` page-break guard) is still open** — if it is
   still the right idea, reference it rather than restating it. Check
   `DOCS-AUDIT.md` for which of its findings were taken before writing a docs
   finding.
7. **Use the repo's own tools rather than reading whole files.**
   `node scripts/readme-section.mjs <query>` indexes README.md and every
   `docs/*.md` and names the file in each hit. `scripts/q.mjs`,
   `scripts/drift-check.mjs`, `scripts/repo-vs-live.mjs`,
   `scripts/class-check.mjs`, `scripts/catalog-diff.mjs` already answer many
   questions you would otherwise answer by hand.
8. **Read the relevant skill before the code it governs** — `book-survey`,
   `class-import`, `schema-change`, `ship-pr`, `claim-audit`. Several name the
   exact wrong turn that is about to look reasonable.
9. Record what you did **not** cover. A silent gap reads as a clean bill of
   health.

## Baseline to establish first (all tracks)

Before any finding, capture and record: current branch and whether the tree is
clean, the last merged PR number, a clean `smoke` and `regression` run (counts
and pass/fail), `node scripts/drift-check.mjs`, and the production class/skill/
spell/psionic/gear counts from `--remote`. If a suite is red before you start,
that is finding number one and everything else is measured against it.

---

# Track A — Documentation

Scope: the `apps/character-creator/README.md` spine, its eleven `docs/` topic
files, `docs/plans/01`–`18`, the five `.claude/skills/*/SKILL.md`, the prose
inside class markdown, and `CLAUDE.md`/`SETUP.md` **only where they instruct
character-creator work**. Other apps' docs are out of scope.

Load the `claim-audit` skill. Then ask:

- **Do the six test pins still each name exactly ONE file?** The pins are
  deliberately single-file — a corpus read keeps passing after the section it
  guards is deleted. Confirm each still anchors to a body sentence, not a
  table-of-contents entry.
- **Does any skill quote a check name that no longer exists?** The smoke run is
  supposed to fail when it does; verify that guard actually fires.
- **`docs/plans/` — which of the eighteen are shipped?** Several describe work
  that is now live (soft delete, the importers, experience tables, start-at-
  level). A plan file that reads as future work but describes shipped behaviour
  is the most expensive kind of doc rot, because the next session implements it
  twice. Propose a disposition, not just a flag.
- **Counts quoted in prose** that the suite does not pin — find them, and for
  each either propose a pin or propose deleting the number.
- **Notes that describe a fixed bug as still-broken**, and "cannot be done"
  comments whose limitation has since been lifted.
- **Are the eleven topic files still the right eleven?** Nothing is over 540
  lines now; say whether any is now a grab-bag, and whether the spine's map
  table still matches what is under it.

# Track B — Schema and data model

Scope: **the character-creator tables in** `db/schema.sql` (the file is 860
lines and 34 tables across four apps — audit only the character creator's
share), `apps/character-creator/db/*.sql` (267 scripts and growing), and those
tables in production D1.

Load the `schema-change` skill first — a column lands in five places, a table in
nine. Then ask:

- **Dead weight**: columns nothing reads, tables nothing writes, indexes nothing
  uses, and — the reverse — queries doing a full scan where an index belongs.
  Verify reads/writes against `functions/api/` and the app JS, not intuition.
- **JSON blobs doing a column's job**, and columns doing a JSON blob's job.
  Where has the schema been bent to avoid a migration?
- **The 267-script rebuild.** It is applied as one sorted glob, so filename
  order is execution order and a `fix-` that sorts before its target is silently
  undone. That has bitten repeatedly (`fix-cyber-knight-rue-bonuses`,
  `fix-pre-rue-class-audit`). Ask whether the linear script pile still scales at
  400 files, what a periodic snapshot/compaction would cost and break, and
  whether a lint could catch the sort hazard mechanically before a PR merges.
- **Orphans and drift in production** — rows referencing deleted parents,
  `deleted_at` semantics honoured inconsistently between the wizard and the
  sheet, stub rows created by importers that were never filled in.
- **Does the migration list in `docs/operations.md` match the actual schema?**
- **Shared-database blast radius**, from the character creator's side only: it
  lives in one D1 with three other apps. Can any character-creator query read or
  write a row that is not its own, and does any character-creator table lack the
  prefix convention that keeps that from happening? Do not audit the other apps'
  tables — only the character creator's exposure to them.

# Track C — Setup health, as it affects character-creator work

- `CLAUDE.md` and `SETUP.md` versus what actually happens on a cold clone **for
  someone about to work on the character creator**. Specifically: the five
  skills are directory-scoped and junctioned into `~/.claude/skills`; a **new**
  repo skill needs its junction added in the same PR and nothing notices the
  gap. Is that written down where the next session will hit it?
- `.claude/settings.json` read-only allowlist (from EFFICIENCY F6) — what still
  prompts during character-creator work that safely should not, one audit
  session later.
- What the character creator takes from `shared/` and `functions/api/_lib/`
  versus what it duplicates in `apps/character-creator/js/` and
  `functions/api/character-creator/_lib/`. Duplication that only affects this
  app is a finding; refactoring shared code for the other apps' benefit is not.
- Dead files and orphaned scripts **in the character creator's tree and its
  tooling**, `__pycache__` in `scripts/`, anything that should be gitignored and
  is not.
- Auth on character-creator routes: `getAccessEmail` is read in exactly one
  place and each app layers its own authorization on top. Check the character
  creator's layer — admin-only endpoints, the `PUBLIC_PREFIXES` entries that
  cover its routes, and whether any endpoint trusts a client-supplied identity.
- Error handling and observability: when a character-creator Pages Function
  throws in production, what does the user see and what can we find afterward?

# Track D — Efficiency of the build loop

`EFFICIENCY-AUDIT.md` (2026-08-25) measured this once and F1–F6 shipped. This
track asks **what is expensive now**, after those landed.

- Where does a typical class-import PR actually spend tokens and wall-clock
  today? Measure against recent session transcripts under
  `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\` — **deduplicate by
  `message.id`** or the numbers inflate roughly 1.9x.
- The full smoke run is the merge gate (1300+ checks, ~45s). What is the current
  cost per PR of the verify loop, and is `--section` being used where it should?
- Dev-server hygiene: `taskkill` on a port PID kills workerd children that
  respawn, and fifteen dev servers have accumulated before. Propose the fix.
- Anything in the loop that is still copy-paste between sessions.

# Track E — The PDF import process  ← the priority track

Nathan expects to add **many more books**. Audit the whole path from "here is a
PDF" to "the class is live", both halves:

**Offline half** — `.claude/skills/book-survey/SKILL.md` (444 lines),
`scripts/ocr-book.py`, `scripts/read-columns.py`, `scripts/ocr-fields-lib.mjs`,
`scripts/parse-pf-spell-*.mjs`, and the seven-to-eight caches under
`.cache/books/<slug>/` (`manifest.json`, `png/`, `tsv/`, `txt/`). Note: this
cache is **local-only by design** — book text is never committed.

**In-app half** — `import.html` and `import.js` (964 lines), the five tabs, the
shared `_lib/import-engine.js` pipeline plus `IMPORT_SPECS`, and the separate
class-importer path. PDFs go to Claude as **document attachments, never as
extracted text** — do not propose a text pre-pass; layout-preserving extraction
splices columns mid-line.

Ask specifically:

- **What does book #9 cost, end to end, today?** Walk the actual steps for a
  book that is not yet cached and count the manual ones. Every manual step is a
  candidate finding.
- **The page-offset trap.** Reader page versus printed folio differs per book
  (rue/pf/bom/potm/dag/cb1/fom are not uniform — several are printed+1, PF is
  printed+2, one stamp was a full page high and shipped wrong). Is the offset
  recorded per book in a place tooling reads, or re-derived by hand every time?
  Propose a mechanical check.
- **Page-break damage.** A page break put two different `starting_money` figures
  into live data. `EFFICIENCY-AUDIT` F7 proposed a `class-check --field-sources`
  guard and is still open. Say whether it is still the right shape.
- **Truncated and partial caches** (`fom` stops at printed 72 of 176). Does
  anything warn a future session that a cache is incomplete, or does it just
  return nothing and look like an absence?
- **Is there a per-book `SURVEY.md` standard?** F1 boots fresh sessions from
  `.cache/books/<slug>/SURVEY.md`. Confirm it exists for every cached book and
  that its shape is consistent enough to boot from cold.
- **Could the offline half emit a draft `add-*.sql` directly**, skipping the
  in-app round trip for text-layer books? What would that break?
- **Batching**: extraction is the only step that costs money. Is it batched as
  well as it could be across classes/spells within one book?
- **Reconciliation**: the phase-5 pass catches rows that look fine and are
  wrong. Is it scripted or remembered?
- **Cache the book once, import many times** — is re-importing from an
  already-cached book meaningfully cheaper than the first import? It should be.

Deliver, alongside the findings, a **one-page "adding book N" runbook** as it
would look after your proposals are taken — Nathan should be able to see the
target state, not just the defects.

# Track F — Skills and tooling gaps

Five skills exist: `book-survey`, `class-import`, `schema-change`, `ship-pr`,
`claim-audit`. Ask what the sixth should be, if anything. Candidates worth
evaluating rather than assuming:

- A skill for the **audit-menu protocol itself** (F-numbers, `Proposal:` lines,
  `Taken,` notes, one PR each) — it is currently carried only in memory.
- A skill or script for the **book-cache/page-offset** conventions, which
  `book-survey` covers only partly.
- A skill for **UI work in this app** — where the pages are, how to run and
  screenshot them, the conventions in `styles.css`.
- Conversely: is any existing skill now too long, overlapping another, or
  describing a workflow that tooling has since automated?

For each proposal, say what failure it prevents — the existing five are each
written from a failure that reached production, and a skill without one is
documentation. Any new skill needs its `~/.claude/skills` junction in the same
PR.

Also evaluate: which of the `scripts/*.mjs` should be a skill, which skill
content should be a script, and what is still done by hand often enough to
deserve either.

# Track G — UI layout

Six pages: `index.html` (the creation wizard, `app.js` at 3,243 lines),
`sheet.html` (`sheet.js`, 2,025), `catalog.html` (703), `campaign.html` (643),
`dashboard.html` (138), `import.html` (964). Styling is
`shared/styles.css` (160) plus `apps/character-creator/styles.css` (847).

**Run the app and screenshot it. Do not audit the UI by reading CSS** — a prior
session declared tabs working on the strength of metrics, and the screenshot
showed them below the fold.

Use the `nates-apps-8791` config in `C:\Users\natha\Downloads\.claude\
launch.json` (port 8791 — **8788 belongs to another worktree**, do not take it).
Seed local D1 first; it is stale and possibly empty. If the wizard has a
server-side draft, snapshot it before walking through, because walking it
mutates the draft.

For each page capture desktop **and** mobile (375px), and look for:

- Anything important below the fold on first paint.
- The wizard's step flow: how many steps, how much scrolling per step, whether
  the user can tell where they are and what is left.
- The sheet's information density — 2,000 lines of render is a lot of surface;
  is it scannable at a table?
- Controls that behave differently on different pages for the same action.
- The catalog at real production size (900+ gear rows, 300+ skills): does
  pagination/filtering hold up?
- `import.html`'s five tabs — the admin path Nathan will use most as books
  arrive; friction here compounds with Track E.
- Empty, loading, and error states.

Attach the screenshots or their paths to each finding. A UI finding without an
image is a guess.

---

## Output

**Do not write all seven tracks in one session.** Run three, each from this same
brief, each starting cold:

| session | tracks | writes |
|---|---|---|
| 1 | E, F | `apps/character-creator/INGESTION-AUDIT.md` |
| 2 | A, B, C, D | `apps/character-creator/HEALTH-AUDIT.md` |
| 3 | G | `apps/character-creator/UI-AUDIT.md` |

All three live beside `AUDIT.md` and `CLASS-AUDIT.md`, next to the app they are
about — even though Track E's findings will often land in root-level `scripts/`
and `.claude/skills/`, which exist to serve this app.

Session 1 first — it is the priority and it shapes what Track F proposes.

Each file:

1. **Title with the date**, and a methodology paragraph: what you read, what you
   ran, what you verified against production, and the baseline numbers.
2. **"Fixed in this PR"** — only unambiguous rot in live instructions, if any.
3. **Findings, `F1..Fn`, ranked by value**, each with: what is true today (with
   file:line or a query result), why it matters, and a `Proposal:` paragraph
   specific enough to implement from without re-deriving. State the posture
   explicitly — log-not-cap, warn-not-block, opt-in — because "take F6" means
   implement the proposal *as written*, scope and posture both.
4. **Not covered** — what you did not look at, and why.
5. For Track E, the "adding book N" runbook described above.

Then stop and report the menu. Nathan takes them one at a time.
