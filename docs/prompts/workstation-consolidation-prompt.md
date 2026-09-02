# Workstation consolidation — this machine, this layout

Produce `MACHINE-AUDIT.md` at the root of `C:\Users\natha\Projects\nates-apps`,
as a numbered findings menu in this repo's audit-menu form (read the `audit-menu`
skill first — findings are `M1`, `M2`, …, the header carries the menu's own
status and its own trap, each finding is taken one at a time as its own PR, and
the outcome note is appended to the finding rather than recorded anywhere
greppable).

The stack does not change. Cloudflare Pages, D1, Workers, node, wrangler, `gh`,
python — all stay exactly as they are. **This is about where things sit on one
Windows PC and why commands fail in the terminal.** Nothing here is about
portability; that idea was investigated on 2026-09-02 and dropped.

Read `SETUP.md` and the repo `CLAUDE.md` first. `SETUP.md` §"Setting up a
machine" is the closest thing to a current description of this layout, and it is
the file most likely to need editing at the end.

## Decisions already made — do not re-open these

Answered by Nate on 2026-09-02, before the audit was written. Reproduce this
block at the top of `MACHINE-AUDIT.md`.

1. **The working directory moves to a dedicated directory beside the repo** —
   `C:\Users\natha\Projects\workshop\` unless you can argue for a better name,
   holding the sourcebook PDFs, the loose briefs, and anything else that is work
   rather than a download. **Design the move; do not re-litigate it.** Not inside
   the repo (1.8 GB of PDFs in a git working tree), and not staying in
   `Downloads`. Everything in "What the restructure has to answer" applies to
   this move specifically.
2. **The environment fixes go through the menu like everything else** — numbered
   findings, one PR each, taken on his word. Do not apply a PATH change or create
   a profile as part of this pass. They should still be numbered **first**,
   because they fix the reported symptom independently of the move and can be
   taken before it.
3. **`DiceRoller` is abandoned.** Record it as a known hazard in one sentence —
   a `.git` directory inside a syncing OneDrive folder — and propose no work on
   it. Do not spend a finding.
4. **Where the PowerShell profile should live is still open** and the audit
   decides it, alongside the broader question of what else `Documents`-in-
   OneDrive affects. Recommend, with the sync-conflict and no-backup trade named.

## Two problems that feel like one — do not conflate them

The stated symptom is *"constantly having path issues and commands not working in
terminal"*, and the stated suspicion is that things are not in a unified area.
**A first pass on 2026-09-02 found those are two different problems, and only one
of them is about directory layout.** Verify both before proposing anything.

### Problem 1 — environment, not layout

Reorganizing directories will not fix any of this. Confirm each, then fix it.

- **`pdftotext` is genuinely missing from his terminal.** It lives at
  `C:\Program Files\Git\mingw64\bin\pdftotext.exe` — shipped inside Git for
  Windows. `C:\Program Files\Git\cmd` is on the persisted PATH; **`mingw64\bin`
  is not.** An agent session inherits it and the command works; his own
  PowerShell does not and the command fails. The repo's `.claude/settings.json`
  allows `Bash(pdftotext *)`, so this has been invisible from the agent side the
  whole time. This is the single most concrete instance of the reported symptom —
  **verify it by opening a fresh PowerShell and running `pdftotext -v`**, and
  lead the menu with it.
- **There is no PowerShell profile at all.** None of the four profile paths
  exist. There is nowhere for a PATH fix, an alias, or a `cd` shortcut to live,
  which is why every fix so far has been re-typed rather than kept.
- **The profile would land in OneDrive.** `CurrentUserAllHosts` resolves to
  `C:\Users\natha\OneDrive\Documents\WindowsPowerShell\profile.ps1`, because
  `Documents` is redirected to OneDrive. Decide deliberately whether that is
  where it should live before creating one.
- **`python` resolves through the Microsoft Store alias**
  (`AppData\Local\Microsoft\WindowsApps\python.exe` → `AppData\Local\Python`,
  currently 3.14.3). It works today. Note the failure mode — App Execution
  Aliases can be toggled off in Settings and the Store stub can shadow a real
  install — and say whether it is worth pinning. **Check what `scripts/ocr-book.py`
  actually imports and whether those packages are installed**, because a working
  `python --version` says nothing about that.
- **PATH changes do not reach already-open terminals.** Worth stating once in
  `SETUP.md`, because it makes a correct fix look broken.

Establish the general form of this, not just the instances: **the agent's shell
and Nate's shell do not have the same PATH.** Diff them (`$env:PATH` against
`[Environment]::GetEnvironmentVariable('PATH','Machine'/'User')`) and record the
difference in the audit. Anything that works for an agent and fails for him is
this, and it will keep producing symptoms until it is written down.

### Problem 2 — layout

This one is real too, and it is mostly about `Downloads`.

- **`Downloads` is the work directory and also the dumping ground.** 539 entries.
  It holds ~45 sourcebook PDFs, 24 working `.md` briefs, `.claude/` (with a 77 KB
  `settings.local.json`), and a stray `.wrangler/` from wrangler having been run
  there — mixed in with tax returns, medical receipts, 3MF printer files and
  browser downloads. Total ~13 GB, of which ~1.8 GB is PDFs.
- **It is the one user folder NOT redirected to OneDrive.** `Documents`,
  `Desktop` and `Pictures` are; `Downloads` is not. So the machine currently has
  two different storage regimes and the work lives in the un-synced one — which
  is also the one with no backup.
- **Duplicates have already accumulated there.** `REVIEW-BRIEF.md` and
  `REVIEWBRIEF.md`; `setup-v2-rewrite-prompt.md` and `setupv2rewriteprompt.md`.
  `docs/prompts/README.md` already documents the second pair as byte-identical
  and calls it "what an unmanaged directory does over time."
- **A git repo lives inside OneDrive:** `C:\Users\natha\OneDrive\Documents\
  DiceRoller\.git`. **Abandoned per decision 3** — one sentence recording the
  hazard, no finding, no work.
- **`C:\Users\natha\Projects` contains only `nates-apps`**, and `git worktree
  list` shows exactly one worktree on `main`. There is **no** project sprawl
  under `Projects`. Say so — an earlier note about port 8788 belonging to
  "another worktree" does not match what is on disk now, and the audit should
  re-check rather than repeat it.

## What the restructure has to answer

For each proposal: **what moves, what breaks, and what has to be updated the same
day.** The following are the things that break when a directory moves, and every
one of them has already caused a problem here at least once.

1. **The agent memory store is keyed to the path.**
   `~\.claude\projects\C--Users-natha-Downloads\memory\` — 61 files. Move the
   working directory and that key changes; the memories do not follow on their
   own. There is a second store keyed to `C--Users-natha-Projects-nates-apps`.
   Say exactly what the migration is, or say that the memories stay behind and
   why that is acceptable.
2. **`Downloads\.claude\settings.local.json` does not follow either.** ~77 KB of
   permission grants accumulated over months. A new working directory starts at
   zero and prompts for everything. Propose how much of it is worth promoting
   into the repo's tracked `.claude/settings.json` — note the existing rule in
   `.gitignore`: *"launch.json is shared, local permissions are not"* — and say
   what changes about that rule if the recommendation is to track some.
3. **The nine skill junctions and the agents junction** point at the repo and are
   consumed from whatever directory a session starts in. If the session's
   starting directory changes, re-derive whether they are still needed at all: a
   session started **inside** the repo registers `.claude/skills/` and
   `.claude/agents/` natively, and the entire junction apparatus plus the
   `~/.claude/CLAUDE.md` pointer exists only because sessions start in
   `Downloads`. This is the highest-leverage item in the menu.
4. **`scripts/books.json` records `source_pdf_dir` per book** — currently
   `Downloads` — as the recovery record for a rebuildable cache. Moving the PDFs
   makes 18 entries wrong. The file's own `_doc` block explains what the field is
   for; check what reads it before editing.
5. **`Downloads\.claude\launch.json` is untracked** and hardcodes
   `cmd /c cd /d C:\Users\natha\Projects\nates-apps`. The repo has its own
   tracked `.claude/launch.json`. Two files, one tracked, that must not drift —
   decide whether the untracked one should exist at all.
6. **`docs/prompts/`** already archives the briefs that live loose in
   `Downloads`. The originals were deliberately left in place. If the working
   directory moves, say what happens to those loose copies.
7. **~40 tracked markdown files contain `C:\Users\natha\...`.** Most are
   historical records that must **not** be edited — `docs/prompts/README.md` is
   explicit that a brief is a record, not a document. Separate instructions from
   records and only propose changing instructions.

## Designing the move

The destination is decided (decision 1). What the audit owes is the *shape* of
it, in enough detail that taking the findings is mechanical:

- **What goes and what stays.** `Downloads` has 539 entries and most are not
  work. Give the actual inclusion rule — the ~45 sourcebook PDFs, the working
  `.md` briefs, `.claude/`, the stray `.wrangler/` — and be explicit that
  everything else stays put. **Name the files individually in the finding**, or
  give a rule precise enough that running it twice moves the same set.
- **The internal layout of the new directory.** Books, briefs, and config are
  three different things; say whether they get subdirectories and why.
- **Duplicate resolution.** `REVIEW-BRIEF.md`/`REVIEWBRIEF.md` and
  `setup-v2-rewrite-prompt.md`/`setupv2rewriteprompt.md`. Compare them before
  recommending; `docs/prompts/README.md` already resolved the second pair as
  byte-identical and kept only the hyphenated name.
- **The order the findings have to be taken in**, so there is never a window
  where `books.json` points at a directory that no longer holds the PDFs, or a
  session starts somewhere its permissions and memories do not exist.
- **Whether the junctions survive it.** The move changes the session's starting
  directory but keeps it outside the repo, so the junction apparatus probably
  still applies. Confirm rather than assume — and if the new directory could
  reasonably hold a `.claude/` of its own, say what that changes.
- **The verification.** What is checked after each move to prove nothing broke:
  at minimum a book resolving to its cache, `ocr-book.py` running end to end, and
  the six skills still loading by name from the new directory.

**The environment findings are independent of all of this and should be numbered
first.** They are cheap, reversible, and fix the reported symptom whether or not
the move ever happens.

## Ground rules

- **Verify before asserting.** Every observation in this brief was gathered in a
  single pass and should be re-checked; say which ones you confirmed, which were
  stated wrongly here, and what you found that is not here.
- **Prove a fix by making it fail.** A PATH fix that has only ever been observed
  working proves nothing. Open a genuinely fresh shell and confirm the *before*
  state as well as the after.
- **Do not touch anything under `Downloads` that is not work.** Tax returns,
  medical receipts and printer files are in there. Nothing in this menu should
  move, rename or delete a file it has not identified. Deletion is not in scope
  at all — findings may propose it, and Nate takes that call separately.
- **A finding that says "leave it alone" is a real finding.**
- **Do not implement anything in this pass.** Produce the menu; items are taken
  one at a time afterwards.
- The durable half of the outcome belongs in `SETUP.md` §"Setting up a machine",
  which currently describes a layout the findings may change. Remember that
  several counts and sentences in this repo's docs are pinned by the test suite —
  a doc edit that moves a number breaks `smoke.mjs`, and that is intended.
