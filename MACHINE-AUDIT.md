# MACHINE-AUDIT — where things sit on this PC, and why commands fail

> **Since 2026-09-16 the closed findings live in `MACHINE-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

**Run 2026-09-02** against `C:\Users\natha` on Windows 11 Pro 26200, from the
brief at `Downloads\workstation-consolidation-prompt.md`. Findings are `M1`,
`M2`, … as `### M1 — <severity> — <title>`, severity being `high` / `medium` /
`low`. Nothing here is taken until Nate names it; one PR per finding, outcome
note appended under the finding in the same PR.

**Status: work was opened on this menu on 2026-09-22.** Status for any finding lives under its
own heading, and this line deliberately does not count them. `M20` is **closed
without being taken**, superseded by `M22`; `M22` was filed and taken the same
day and is the one finding here that changed the machine rather than the repo.
`M19` and `M21` were taken 2026-09-03.
`M18` is an OBSERVATION rather than a finding — the fault it records is still
unexplained, every hypothesis raised against it is dead or cannot be provoked, and its
recorder was repaired the same day it shipped. Taking it meant attempting a
reproduction (1,592 lookups, not reproduced) and automating the capture its own
text asks for, since a person cannot catch it by hand. **If
`workshop\command-not-found.log` ever appears, read it before anything else.**
**`M8` was taken with its posture overridden** — deletion, on explicit
instruction — which its own note records. Read the lines under a finding for its
status — the notes here vary in wording like every other menu in this repo, and
grepping for one has been wrong in both directions.

> **This menu's own trap: nothing in it is pinned by anything.** Every other
> audit file here describes the repo, so the test suite, a rebuild or a `--remote`
> query can contradict it. This one describes a machine that no file in the tree
> observes, so a stale claim here fails silently and forever. Two consequences.
> **First, every number below carries the timestamp it was measured at and
> nothing keeps it current** — `Downloads` held 539 entries when the brief was
> written this morning and 543 when this was measured at 13:20, four files
> arriving from a browser in between. **Second, `M7` names its files
> individually on purpose.** A rule re-run at take-time selects a different set
> than the one reviewed here, and the directory it selects from also holds tax
> returns, medical records and a custody document. Take `M7` against the list,
> not against a fresh scan.

---

## Decisions already made — do not re-open these

Answered by Nate on 2026-09-02, before the audit was written.

1. **The working directory moves to a dedicated directory beside the repo** —
   `C:\Users\natha\Projects\workshop\` unless a better name can be argued,
   holding the sourcebook PDFs, the loose briefs, and anything else that is work
   rather than a download. **Design the move; do not re-litigate it.** Not inside
   the repo (1.8 GB of PDFs in a git working tree), and not staying in
   `Downloads`.
2. **The environment fixes go through the menu like everything else** — numbered
   findings, one PR each, taken on his word. They are numbered **first**, because
   they fix the reported symptom independently of the move.
3. **`DiceRoller` is abandoned.** Recorded as a hazard, no finding, no work:
   `C:\Users\natha\OneDrive\Documents\DiceRoller\.git` is a git repository inside
   a syncing OneDrive folder, which is a corruption risk if it is ever used again.
   It is not being used.
4. **Where the PowerShell profile should live is still open** and this audit
   decides it — `M4`.

---

## Corrections to the brief, first

The brief asked to be re-checked rather than believed. It held up on the shape of
the problem and was wrong or imprecise on nine measurements. Leading with those,
because two of them change what the findings should be.

**Confirmed as written:** `pdftotext` genuinely absent from the persisted PATH;
no PowerShell profile at any of the four paths; the profile path resolves into
OneDrive; `python` resolves through the Microsoft Store alias; `Downloads` is the
one user folder not redirected to OneDrive while `Documents`, `Desktop` and
`Pictures` are; both suspected `.md` duplicate pairs are byte-identical;
`Projects\` contains only `nates-apps` with exactly one worktree, on `main`;
`scripts/books.json` records `C:\Users\natha\Downloads` on all 18 entries;
`Downloads\.claude\launch.json` is untracked and hardcodes `cd /d` into the repo.

**Wrong or imprecise:**

| # | the brief said | measured 2026-09-02 |
|---|---|---|
| 1 | `Downloads` has 539 entries | **543** at 13:20 — 535 files, 8 directories, 13.29 GB over 644 files recursively |
| 2 | ~45 sourcebook PDFs, ~1.8 GB | **50 game PDFs, 1,787.9 MB.** Of 99 PDFs in the directory, **49 are not game material** |
| 3 | 24 working `.md` briefs | **25**, and **one of them is not work at all** — personal interview preparation |
| 4 | ~40 tracked md files contain `C:\Users\natha\…` | **25 tracked files**, of which only **three** are instructions rather than records; the grep shape used also misses `scripts/books.json`, whose 18 values are the ones that actually have to change |
| 5 | the memory store holds 61 files | **64** — 63 memories plus `MEMORY.md` |
| 6 | there is a second memory store | there are **three** project keys; the third is `C--WINDOWS-system32` |
| 7 | the loose briefs vs `docs/prompts/` is an open question | **it is not.** All 18 archived briefs are **content-identical** to their loose copies; the only difference is CRLF, introduced at checkout by `core.autocrlf=true`. See `M13` |
| 8 | 77 KB of permission grants do not follow the move | **206 of the 258 entries are path-independent** and survive a move of the `.claude/` directory verbatim. The move costs almost nothing. See `M11` |
| 9 | the junction apparatus is "the highest-leverage item" | it is the **lowest**. The junctions live in `~/.claude`, are keyed to nothing about the working directory, and survive the move untouched. Verified: nine junctions, all resolving into the repo. See `M12` |

**Found, and not in the brief:**

- **The `windows-shell` skill carries a diagnosis of this exact symptom, and it
  is false.** This is the largest thing in the audit — `M2`.
- **Three more identical duplicate pairs, all large PDFs, 122.4 MB** between
  them, on top of the two `.md` pairs the brief knew about — `M8`.
- **17 sourcebooks sit in `Downloads` that are not in the registry, totalling
  1,243.4 MB** — more un-ingested book weight than ingested (534.0 MB across the
  18 registry books). Three of those 17 are the duplicate copies above. **No
  finding**: what to ingest belongs to `BOOK-INGEST-AUDIT.md`, not here. Noted
  only because it is most of what the move is carrying.
- **`~/.claude.json` holds four project keys and two of them are the same
  directory** spelled with forward and back slashes — `M15`.
- **`curl` in PowerShell is an alias for `Invoke-WebRequest`** — `M5`.
- **`.gitattributes` exists** and explains the CRLF asymmetry in correction 7.
- **Nothing outside `books.json` reads `Downloads` at runtime.** A grep of every
  `.mjs`, `.js`, `.py`, `.json` and `.jsonc` in the tree returns one hit, and it
  is a `//` comment inside `.claude/launch.json`. The move's blast radius on code
  is zero.
- **PowerShell 7 is not installed** (`pwsh` NOT FOUND). Everything is Windows
  PowerShell 5.1 — no `&&`, no ternary, no `Start-Process -Environment`. That is
  permanent, not a gap to fill, and `M4` has to be written for 5.1.
- **`SETUP.md` says "the six repo junctions" one line after a block that loops
  over nine** — `M12`.

---

# Environment — `M1`–`M6`

Reorganising directories fixes none of this. These are cheap, reversible, and
independent of the move.

- **M1** — high — `pdftotext` ships inside Git for Windows and nothing said so — Taken, 2026-09-02 — machine half only, out of band. Nate said "just fix the — full text in `MACHINE-AUDIT.closed.md` under its own `### M1` heading.

- **M2** — high — the skill's explanation of this whole class of failure is wrong — Taken, 2026-09-02 (PR #573). As written — documentation only, one skill, no — full text in `MACHINE-AUDIT.closed.md` under its own `### M2` heading.

- **M3** — medium — a memory file records the same false claim — Taken, 2026-09-02 (PR #573), inside `M2`'s PR as its memory half — the — full text in `MACHINE-AUDIT.closed.md` under its own `### M3` heading.

- **M4** — medium — there is no PowerShell profile, and the default location is the wrong one — Taken, 2026-09-02 (PR #584), last of the menu because it is easier once the — full text in `MACHINE-AUDIT.closed.md` under its own `### M4` heading.

- **M5** — low — `curl` in PowerShell is not curl — Taken, 2026-09-02 (PR #574). Posture kept — documentation only, no alias — full text in `MACHINE-AUDIT.closed.md` under its own `### M5` heading.

- **M6** — low — `python` is fine, and the failure mode is worth one sentence — Taken, 2026-09-02 (PR #576), and left alone, which is the posture. No — full text in `MACHINE-AUDIT.closed.md` under its own `### M6` heading.

# Layout — `M7`–`M15`

The move itself. `Downloads` and `Projects` are on the same volume (`C:`, 398 GB
free), so every move below is a rename: instant, and reversible by renaming back.

- **M7** — high — what moves to `C:\Users\natha\Projects\workshop\`, named file by file — Taken, 2026-09-02 (PR #581), with `M9` and `M12` per *Order*. — full text in `MACHINE-AUDIT.closed.md` under its own `### M7` heading.

- **M8** — medium — five identical duplicate pairs, 122.4 MB of it in three PDFs — Taken, 2026-09-02 (PR #581), AND THE POSTURE WAS OVERRIDDEN. Nate was asked — full text in `MACHINE-AUDIT.closed.md` under its own `### M8` heading.

- **M9** — high — `books.json`'s 18 `source_pdf_dir` values, and the test that will not catch them — Taken, 2026-09-02 (PR #581), in `M7`'s PR and after the files had physically — full text in `MACHINE-AUDIT.closed.md` under its own `### M9` heading.

- **M10** — high — the memory store is keyed to the working directory and does not follow — Taken, 2026-09-02 (PR #580). Posture kept: copied, nothing moved, nothing — full text in `MACHINE-AUDIT.closed.md` under its own `### M10` heading.

- **M11** — medium — the permission file follows for free, and should not be promoted into the repo — Taken, 2026-09-02 (PR #583), and left alone. Not one byte of — full text in `MACHINE-AUDIT.closed.md` under its own `### M11` heading.

- **M12** — medium — the junctions survive; the pointer and a count do not — Taken, 2026-09-02 (PR #581), in `M7`'s PR because the pointer is the file — full text in `MACHINE-AUDIT.closed.md` under its own `### M12` heading.

- **M13** — low — the loose briefs are already archived, byte for byte — Taken, 2026-09-02 (PR #578) — the archive half. The file *moves* belong to — full text in `MACHINE-AUDIT.closed.md` under its own `### M13` heading.

- **M14** — medium — two `launch.json` files, and they have already drifted — Taken, 2026-09-02 (PR #579). All four drift points confirmed. Posture kept: — full text in `MACHINE-AUDIT.closed.md` under its own `### M14` heading.

- **M15** — low — the two things to leave exactly as they are — Taken, 2026-09-02 (PR #577), and declined — which is the finding. Nothing was — full text in `MACHINE-AUDIT.closed.md` under its own `### M15` heading.

# Opened while taking a finding

- **M16** — high — `ocr-book.py` requires `tesseract`, it is not on PATH, and a hardcoded fallback is the only reason that does not show — Taken, 2026-09-02 (PR #586), on Nate's word. Posture kept exactly: — full text in `MACHINE-AUDIT.closed.md` under its own `### M16` heading.

- **M18** — OBSERVATION, NOT A DIAGNOSIS — `CommandNotFoundException` on a bare command name that resolves minutes later — Taken, 2026-09-02 (PR #588). This finding proposes nothing to implement, so — full text in `MACHINE-AUDIT.closed.md` under its own `### M18` heading.

- **M17** — medium — eleven memories name `Downloads` in their own text, and `M7` makes some of them wrong — Taken, 2026-09-02 (PR #582), in its own PR immediately after `M7`, which is — full text in `MACHINE-AUDIT.closed.md` under its own `### M17` heading.

## Order

Six of these have a real dependency. The rest can be taken in any order.

1. **`M1`** (`SETUP.md` half), **`M2`+`M3`**, **`M5`**, **`M6`** — environment
   and documentation. No dependency on anything. Cheap, reversible, and they fix
   the reported symptom whether or not the move ever happens.
2. **`M4`** — the profile. Independent, but written for the new directory, so it
   is easier after the destination exists.
3. **`M10`** — copy the memory store to the new key **before** any session is
   started there. A session that runs first writes a fresh empty store and the
   copy then has to merge rather than land.
4. **`M7`** — the move itself, with `M8`'s duplicates resolved as part of
   deciding what carries.
5. **`M9`** — `books.json`, in the same PR as `M7` and **after** the files have
   physically moved. The window to avoid is a registry pointing at a directory
   that no longer holds the PDFs; because `smoke.mjs` checks presence and not
   value, nothing in the suite would report that window while it was open.
6. **`M12`**'s `~/.claude/CLAUDE.md` edit, in the same PR as `M7`. It is the
   file that tells every session where the work is.

`M11`, `M13`, `M14` and `M15` have no ordering constraint.

## Verification

After `M7` and `M9`, before the PR merges:

- **A book resolves to its cache.** Pick one of the 16 registry books that has a
  cache and confirm the text still reads. This exercises `books.json` and the
  cache path together.
- **`ocr-book.py` runs end to end** against one moved PDF, into a scratch cache
  directory. This is the check that `source_pdf_dir` is actually right rather
  than merely present, which is the one thing `smoke.mjs` cannot tell you.
- **The nine skills load by name from the new directory**, and `book-reconcile`
  can be spawned there. Ask for one by name; do not infer it from the junction
  existing.
- **`npx wrangler d1 info nates-workshop-media`** from the new directory, which
  is the repo's own health check.
- **The full suite**, because `M9` edits a file the suite reads.

And for `M1`–`M6`, the rule the brief set and this audit followed: **prove it by
making it fail first.** A PATH claim checked only in a shell you constructed is a
claim about your reconstruction — `M2` is in this menu because a plausible
diagnosis went a day without anyone asking `explorer.exe` what it actually held.

- **M19** — low — the global `CLAUDE.md` lists what the working directory holds, and the list went short the same day — Taken, 2026-09-03 (PR #612), as proposed. `~/.claude/CLAUDE.md` no longer — full text in `MACHINE-AUDIT.closed.md` under its own `### M19` heading.

- **M20** — low — the old memory store's `memory\` directory survives as an empty husk — Closed without being taken, 2026-09-03 (PR #607) — superseded by `M22`. The — full text in `MACHINE-AUDIT.closed.md` under its own `### M20` heading.

- **M21** — low — the "`--remote` hangs from the agent's shell" caution is in no repo file, and all three of its commands ran clean — Taken, 2026-09-03 (PR #613), as proposed. A subsection in — full text in `MACHINE-AUDIT.closed.md` under its own `### M21` heading.

- **M22** — medium — memory is keyed to the working directory, three keys exist, and only one of them had the store — Taken, 2026-09-03 (PR #607), and filed in the same PR at Nate's instruction. — full text in `MACHINE-AUDIT.closed.md` under its own `### M22` heading.

### M23 — low — the machine `CLAUDE.md` says the book work runs from a directory no session has started in since 2026-09-03

`C:\Users\natha\.claude\CLAUDE.md` states that the working directory moved on
2026-09-02, from `Downloads` to `C:\Users\natha\Projects\workshop`, and that the
second is where the book work runs from. The first half is a dated historical
statement and stands. The second is a claim about today.

Claude Code keys a session's transcript directory to the directory the session
was started in — this session demonstrates it for its own, being started in
`C:\Users\natha\Downloads` and writing to `C--Users-natha-Downloads`. Listed on
2026-09-22, `C:\Users\natha\.claude\projects` held four keys:
`C--Users-natha-Downloads` with 510 `.jsonl` files,
`C--Users-natha-Projects-nates-apps` with 6,
`C--Users-natha-Projects-workshop` with 3, and one worktree key with 1. **The
workshop key's newest file is dated 2026-09-03.** The Downloads key holds files
dated through 2026-09-22, and among them every one of the 140
`book-extract-worker` calls made between 2026-09-04 and 2026-09-19.

**Nothing is broken by this.** The skills and the agents are junctioned into
`~/.claude`, so they resolve by name from either directory, and `M22` records
that the memory store is keyed to the working directory — the store in use is
the `Downloads` one, which is where the sessions are. What it costs is a reader
sent to a directory the work left, in a file that is checked in nowhere and that
nothing but a hand updates.

**Proposal:** correct the sentence by hand on the machine, as a dated statement
of where sessions actually start, leaving the pointer to the repo's own
`CLAUDE.md` intact and leaving the 2026-09-02 history standing. **Posture: one
paragraph, by hand, outside the repo, with the PR carrying the record.** `M19` is
the precedent — the same file, taken 2026-09-03 in PR #612.

Two constraints on the replacement wording, both read 2026-09-22:
`apps/character-creator/test/checks/machine-instructions.mjs:72` holds that file
to stating no count of skills or agents and `:89-93` to naming none of them; and
that module reads a path outside the repo, so it answers only when the suite is
run on this machine. Run it here before the outcome note says it passed. Neither
constraint binds the replacement, which needs no name and no number.

**Evidence:** the directory listing and the file dates above, 2026-09-22, and the
transcript scan described in `SKILL-AUDIT.md` under
`## Opened by the subagent retrospective, 2026-09-22`.

**Confidence:** high that no session has started in the workshop directory since
2026-09-03, resting on the key-to-directory mapping this session demonstrates for
its own. What would raise it is starting a session there and watching the key
take a new file.

**Ongoing cost:** none. One sentence that already exists, made true, in a file
that has no check reaching it from outside this machine.
