# Portability audit — what it would take to work from any machine

Produce `PORTABILITY-AUDIT.md` at the root of `C:\Users\natha\Projects\nates-apps`,
as a numbered findings menu in this repo's audit-menu form (read the `audit-menu`
skill first — the header carries the menu's own status and its own trap, findings
are `P1`, `P2`, … , each is taken one at a time as its own PR, and the outcome
note is appended to the finding rather than recorded anywhere greppable).

Read `SETUP.md` and the repo `CLAUDE.md` before anything else. `SETUP.md` already
has a **"Setting up a machine"** section; this audit is largely the question of
why that section has to exist at all, and what would have to change for it to
shrink or disappear.

## The goal, stated plainly

Nate wants to work on these apps from any machine or device, with or without the
remote-control feature. Today a working session needs *this* PC: a specific
directory layout, nine hand-made Windows junctions, a 77 KB local permissions
file, an 82 MB gitignored OCR cache, a pile of PDFs in `Downloads`, two secrets
files, and two environment variables. **None of that is in git.**

The deliverable is not a migration. It is a menu of what would have to move,
where each thing would move to, what it costs, and which items are load-bearing
for correctness rather than merely for convenience.

## Decisions already made — do not re-open these

Nate answered these on 2026-09-02, before the audit was written. They narrow the
scope sharply, and several findings below only make sense in their light.
Reproduce this block at the top of `PORTABILITY-AUDIT.md`.

1. **The target is a cloud session with no local machine, plus a tablet or phone
   with no shell.** *There is no second local PC in scope.* Do not spend a
   finding on making this Windows box reproducible on another Windows box — the
   question is what works when there is no Windows box at all. This makes several
   items below considerably sharper than "portability" usually implies:
   - `windows-shell` is not *potentially* misleading on a portable setup, it is
     **wrong in the primary target environment**. Treat that as a live defect.
   - Chrome-based verification has no local Chrome to run through. This is a
     first-class problem, not a footnote.
   - Anything whose only recovery path is "run this PowerShell block on the new
     machine" has no recovery path at all under this answer.

2. **The PDFs and the OCR cache may move to a private R2 bucket on his own
   account.** Two jobs, and the audit should keep them separate: *backup* (they
   have none today, and `books.json` calls them the only irreplaceable artifact
   in the pipeline) and *access* (a cloud session with no local disk must be able
   to fetch them to ingest a book). Private bucket, his account — say so
   explicitly wherever the licensing question comes up, because that is what
   makes it a different proposition from a public repo.

3. **Moving the book workspace into the repo is open for investigation, not
   decided.** Weigh it honestly and recommend. Note that answer 1 half-decides it
   already: a cloud session has no `C:\Users\natha\Downloads` to start in.

4. **A defined subset per device, not full parity.** Propose the split explicitly
   and get it agreed before any finding is taken. A reasonable starting shape,
   which the audit should confirm or argue against:
   - **Cloud session:** code, PRs, audits, production D1, book ingestion (via R2).
   - **Tablet or phone:** reading, review, merges, production D1 reads. No shell,
     no ingestion, no UI verification.
   - **This PC, while it exists:** everything, and specifically the things that
     genuinely need local hardware.

   Every finding should say which tier it serves. A finding that only improves
   this PC is out of scope unless it is about not losing something.

## Establish the baseline before proposing anything

**Do not trust this list — verify each line and correct it in the audit.** It was
assembled in one pass on 2026-09-02 and the archive convention in
`docs/prompts/README.md` says plainly that a hand-assembled inventory is missing
something the day it lands. Say in the audit which items you confirmed, which you
found stated wrongly here, and what you found that is not here at all.

### Machine-local state, as observed

| what | where | in git? | notes |
|---|---|---|---|
| user-level pointer | `~/.claude/CLAUDE.md` | **no** | `SETUP.md` says outright it is "checked in nowhere". Loads in every session on this machine, in every directory, including work unrelated to this repo. |
| nine skill junctions | `~/.claude/skills/<name>` → repo | n/a | Windows junctions. `SETUP.md` explains why the per-file symlink alternative fails (Developer Mode off, needs elevation). |
| agents junction | `~/.claude/agents` → repo `.claude/agents` | n/a | Links the *whole directory*, so nothing non-repo can live there. |
| plugin/marketplace config | `~/.claude/settings.json` | **no** | Contains an absolute local marketplace path: `C:\Users\natha\.claude\plugins\mcpmarket-me`. |
| accumulated permissions | `Downloads\.claude\settings.local.json` | **no** | ~77 KB of allow-rules, keyed to `Downloads`, built up over months of approvals. |
| auto-memory | `~\.claude\projects\C--Users-natha-Downloads\memory\` | **no** | 61 files, ~340 KB, plus a second store keyed to `C--Users-natha-Projects-nates-apps`. The directory name **is** the machine path — it does not survive a different path, let alone a different OS. |
| OCR cache | repo `.cache/books/` | **no, by design** | 82 MB. Gitignored deliberately: it is the full text of books Palladium still sells. |
| the PDFs | `C:\Users\natha\Downloads\*.pdf` | **no** | `scripts/books.json` calls these "the only irreplaceable artifact in this pipeline" and records `source_pdf_dir` precisely so a lost cache can be rebuilt. No backup of them was identified. |
| local secrets | repo `.dev.vars` | **no** | Anthropic key, `ADMIN_EMAIL`, TMDB key. `.dev.vars.example` documents the shape. |
| shell env | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | **no** | Set in the environment, not in a file the repo can see. |
| dev-server config | `Downloads\.claude\launch.json` **and** repo `.claude/launch.json` | one of two | The `Downloads` copy is untracked and hardcodes `cmd /c cd /d C:\Users\natha\Projects\nates-apps`. Two files, one tracked, that must not drift. |
| toolchain | node 24.18.0, npm 12.0.1, python, `pdftotext`, `gh`, `wrangler`, real Chrome | **no** | Nothing pins these. npm 12's postinstall block and the interactive-shell PATH gap are both recorded traps. |

### Machine-shaped assumptions baked into the repo

These are the interesting half. The state above is a copy problem; these are
design problems.

1. **The junctions exist only because sessions start in `Downloads`.** A session
   started inside the repo registers `.claude/skills/` and `.claude/agents/`
   natively. The whole junction apparatus — nine links, the one-directory-for-
   agents compromise, "a new skill needs its own link in the same PR" — is the
   price of running the book work from outside the repo. **Cost the alternative:
   a gitignored `books/` (or similar) inside the repo.** Say what breaks: the
   memory store key changes, `Downloads\.claude\settings.local.json` does not
   follow, `books.json`'s `source_pdf_dir` records point at `Downloads`, and the
   `~/.claude/CLAUDE.md` pointer's entire reason for existing goes away. This is
   the single largest finding available and it should be numbered first.

2. **`windows-shell` is wrong in the target environment.** CRLF handling,
   `latin1` truncation, `sed -i`, killing wrangler's parent rather than the port
   listener — every trap in it is a Windows trap, and the target is a Linux cloud
   session. A skill that loads by name and confidently describes the wrong
   platform is worse than no skill: this repo's own history is full of findings
   about instructions that were confidently wrong rather than merely stale.
   Decide whether it gets gated by platform, renamed, or grown a second half.
   Check the same question against the other eight skills — `ship-pr` and
   `verify-ui` both encode local assumptions too.

3. **`--local` is not a mirror of production, and a fresh checkout fails two
   checks.** Local D1 has been both ahead and behind production. A new machine
   starts with an *empty* local D1, and `class-check --local` then emits stubs
   that shadow real rows. Whatever "work from any machine" means, it has to
   answer what a first session does about D1 — and the honest answer may be
   "audit against `--remote`, and treat local D1 as disposable."

4. **Forty-odd tracked markdown files contain `C:\Users\natha\...`.** `SETUP.md`,
   `CLAUDE.md`, the audit menus and most of `docs/prompts/`. Most are historical
   records that must **not** be edited (`docs/prompts/README.md` is explicit).
   Separate the ones that are instructions from the ones that are records, and
   only propose changing the instructions.

5. **Verification runs through this machine's Chrome, and the target has none.**
   The dashboard and Access go through real Chrome; the print render uses
   headless Chrome locally; `verify-ui` exists because the in-app Browser pane
   lies in three specific ways. Under the cloud-session answer there is no local
   Chrome at all. Say concretely what still works (headless Chrome inside the
   cloud environment, curl against production, reading rather than clicking) and
   what genuinely does not. Carry over the two standing rules: a play-mode click
   writes a row to production, so verify production by **reading**, not clicking;
   and the Access bypass path test reads HTML only, so a CSS-fetched file needs
   a curl against production before merge.

6. **Ports.** `8788` is shared with another worktree, and dev servers have
   accumulated 15-deep. A second machine working the same repo concurrently is a
   new failure mode — note that `one-session-at-a-time` is already a standing
   rule here.

## First, argue the null case — seriously, and in writing

**This brief is biased toward change, because it was written to investigate
moving.** An audit asked to find portability work will find portability work.
This repo already has a documented instance of that failure mode: seven of the UI
audit's proposals turned out to be wrong rather than merely stale. Correct for it
deliberately.

Before section A, write **`P0` — the case for changing nothing**, as a real
finding with real arguments, not a formality. It should be possible for a reader
to finish P0 and decide to close the menu. At minimum it must weigh:

- **Verification gets worse, and this repo has the receipts.** Screenshots have
  repeatedly falsified conclusions that metrics called fine; a headless print
  render falsified `UI-AUDIT` F17 outright; the in-app Browser pane lies in three
  known ways; a control clipped by a `table-layout: fixed` cell was only
  catchable by measuring the rendered cell. Every one of those catches came from
  a real render on real local hardware. **Quantify what a cloud session loses
  here rather than assuming a workaround exists**, and if the answer is "UI work
  stays on this PC," that is a legitimate outcome to recommend.
- **The junction apparatus looks fragile and has not been.** Nine documented
  `New-Item` lines, one added per new skill, and skills are added rarely. The
  recurring cost is close to zero. A one-time cost already paid is not a reason
  to migrate.
- **The Cloudflare dashboard and Access go through real Chrome.** Some
  operations may become impossible rather than merely inconvenient. Establish
  which, concretely, before proposing anything that depends on them.
- **Moving increases a known failure mode.** `one-session-at-a-time` is a
  standing rule here because three parallel sessions on one checkout confused the
  board. Cloud sessions make parallelism trivially easy and therefore make that
  rule easier to break.
- **New exposure.** Today the book text's risk is a dead drive. In a bucket it
  becomes a token, a bucket policy, and an account. The existing Cloudflare token
  deliberately cannot reach Pages; anything that mints a broader credential for
  convenience is a security regression, and R2 write access is broader.
- **Recurring cost against $0 today**, in both money and feedback-loop latency.
- **Portability solves a collaboration problem that does not exist here.** This
  is solo, single-threaded work. Name what it actually buys.

Then split the goal, because it bundles two things with very different
economics, and the audit should price them separately rather than as one project:

- **Durability** — nothing is irreplaceable if this PC dies. Cheap, no downside,
  worth doing whether or not anything else here is ever taken.
- **Mobility** — real work from a machine that is not this one. Expensive, and it
  costs verification quality.

**If durability alone captures most of the value, say so and recommend stopping
there.** A menu whose honest recommendation is "take P1 and P3, leave the rest"
is a successful audit.

## What to investigate, and what an answer looks like

For each of the following, the audit should say **what it would cost**, **what it
would break**, and **whether it is needed for correctness or only for comfort**.
An option you reject is worth a paragraph saying why.

### A. Configuration into git

What of `~/.claude` can legitimately live in the repo and be adopted by a fresh
machine with one command? Cover at minimum: the user-level `CLAUDE.md` pointer,
`settings.json`'s plugin/marketplace block, and the permissions allow-list.
Distinguish what Claude Code reads from a *project* `.claude/` (already works
today, no junction needed) from what it only reads at the user level. **Check
this against current Claude Code behaviour rather than asserting it** — the
`claude-code-guide` agent exists for exactly this question.

Note that `.claude/settings.local.json` is gitignored on purpose ("launch.json is
shared, local permissions are not"). If the recommendation is to track some of
it, say what changes about that decision and why it is safe.

### B. Secrets and credentials

`.dev.vars`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, the `gh` login, the
Anthropic key. Compare at least: a secrets manager with a CLI, per-environment
provisioning from the Cloudflare dashboard, and short-lived tokens minted per
machine. **Record what the existing Cloudflare token can and cannot reach** —
`CLAUDE.md` already documents that it cannot touch Pages — because a portable
setup that mints a broader token is a security regression dressed as
convenience.

Nothing in this audit should propose committing a secret, and no finding should
require Nate to paste a credential into a file an agent will read.

### C. The irreplaceable data

The PDFs and the 82 MB OCR cache, to a **private R2 bucket on his own account**
(decision 2). Design it, do not re-litigate it. Cover:

- **Backup first, access second.** The PDFs have no backup today. That finding
  stands on its own and should be takeable before anything else here.
- **What the cloud session actually pulls.** Ingesting one book needs that book's
  PDF or its cached pages, not the whole 82 MB. Say whether the cache or the PDF
  is the thing to fetch, and what `ocr-book.py` costs if the answer is "rebuild
  on demand" — "rebuildable in twenty minutes" and "gone" are very different
  answers, and the audit should state which one it is with a measured number.
- **`books.json` becomes partly wrong.** `source_pdf_dir` records a `Downloads`
  path as the recovery record for each cache. If the PDFs move, that field's
  meaning changes and the file's own `_doc` block says what it is for. Propose
  the edit, and check whether anything reads it.
- **The licensing sentence stays.** This is the full text of books Palladium
  still sells. A private bucket on his own account is why this is acceptable —
  write that reasoning down in the audit rather than leaving the next reader to
  reconstruct it, because the next reader may be looking at a proposal to make
  the bucket public or shared.
- **Credentials for the bucket** are part of §B, not a separate token pasted
  somewhere.

### D. The memory store

61 files keyed to a path that exists on one machine. Investigate whether it can
be relocated, whether the useful half belongs in the repo as documentation
instead, and what the failure mode is when a memory that names a file or a flag
outlives that file. Several of the existing memories are already status notes
about completed work.

### E. Execution environment

Decision 1 removes the "second local PC" option. What remains is **the cloud
session**, and the real question is what the repo has to define so that a cloud
session is a working environment on first boot rather than after an hour of
setup. Investigate at least:

- **A devcontainer the repo defines** — node pinned (24.x today), python,
  poppler for `pdftotext`, `wrangler`, `gh`, and a headless Chrome. Verify how
  the target actually consumes a devcontainer definition before recommending one;
  do not assume. `npm 12` blocks postinstall scripts, so anything with a native
  binary needs `--allow-scripts` in the image build or it installs "fine" and
  fails to execute.
- **First-session bootstrap** — what a brand-new session must run before it can
  do anything: fetch secrets, hydrate or skip local D1, pull a book from R2.
  Ideally one command the repo owns, not a documented list.
- **What a tablet or phone can do with no shell at all.** Probably: read the
  audits, review and merge PRs, read production D1 through a deployed surface.
  Say what the actual mechanism is for each — "use the GitHub app" is a real
  answer, "somehow" is not.
- **Concurrency.** `one-session-at-a-time` is already a standing rule here
  because three parallel sessions on one checkout confused the board. Cloud
  sessions make parallelism easy and therefore make that rule easier to break.

For each: what happens to `wrangler pages dev`, to local D1, to UI verification,
and to the book PDFs.

**Cover the with- and without-remote-control cases separately.** The point of
"with or without" is that nothing in the design may *depend* on remote control
being on — if a finding only works when it is, say so and offer the fallback.

### F. Documentation that would have to change

At minimum `SETUP.md` §"Setting up a machine", the repo `CLAUDE.md`, the
`windows-shell` skill, `docs/prompts/BOOK-INGEST-PROMPT.md` (already flagged as
the one template that can be *wrong*), and `book-survey` §8. Remember that this
repo's counts and several doc sentences are pinned by the test suite — a doc edit
that moves a number breaks `smoke.mjs`, and that is the intended behaviour.

## Ground rules

- **Verify before asserting.** This repo has a documented history of confident
  wrong claims about its own setup — seven of one audit's proposals were wrong
  rather than merely stale. Where you cannot verify something, number it as an
  open question rather than a finding.
- **A finding that says "leave it alone" is a real finding.** Some of this is
  local for good reason.
- **Do not implement anything.** This pass produces the menu. Items get taken one
  at a time afterwards, each as its own PR, per the `audit-menu` skill.
- **Order the menu by leverage, not by size**, and say in the header which single
  finding unblocks the most others.
- When this brief produces something committed, copy it into `docs/prompts/` per
  the convention in that directory's README — and do not edit it afterwards to
  match what actually happened.

## Still open — surface these, do not guess at them

The four scoping decisions are answered above. These are the ones the audit is
expected to *raise*, with a recommendation, for Nate to settle:

1. **The device tier split** — decision 4 sketches a shape and asks you to
   confirm or argue against it. Get it agreed before findings are taken, because
   every finding is scoped by it.
2. **Whether the book workspace moves into the repo** (decision 3) — recommend,
   with the costs named.
3. **What happens to this PC.** It stays the only machine that has the PDFs and a
   real Chrome until §C lands. Say what the interim looks like and in what order
   the findings have to be taken so there is never a window where the only copy
   of something is somewhere that just stopped being the working environment.
4. **Anything you find that these four decisions did not anticipate.** Number it
   as an open question in the header rather than assuming an answer — the header
   is where this repo's menus carry their own status.
