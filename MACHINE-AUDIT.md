# MACHINE-AUDIT — where things sit on this PC, and why commands fail

**Run 2026-09-02** against `C:\Users\natha` on Windows 11 Pro 26200, from the
brief at `Downloads\workstation-consolidation-prompt.md`. Findings are `M1`,
`M2`, … as `### M1 — <severity> — <title>`, severity being `high` / `medium` /
`low`. Nothing here is taken until Nate names it; one PR per finding, outcome
note appended under the finding in the same PR.

**Status, 2026-09-02: `M1`–`M18` are all taken and closed. `M19` and `M20` are
OPEN** — filed later the same day by the documentation audit
(`DOCS-AUDIT-2.md`), which found them on this menu's surface rather than its own.
Both are `low` and neither touches anything `M1`–`M18` established.
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

### M1 — high — `pdftotext` ships inside Git for Windows and nothing said so

**The reported symptom, and the concrete instance of it.** `pdftotext.exe` lives
at `C:\Program Files\Git\mingw64\bin\pdftotext.exe`. The persisted PATH carried
`C:\Program Files\Git\cmd` and not `mingw64\bin`, so an agent session — which
runs under Git Bash and inherits `/mingw64/bin` — found the command and Nate's
own PowerShell did not. `.claude/settings.json` allows `Bash(pdftotext *)`, so
this was invisible from the agent side for as long as it existed.

Proved before fixing, in a shell whose PATH was rebuilt from the persisted
Machine + User values only:

```
before:  pdftotext NOT FOUND
after:   C:\Program Files\Git\mingw64\bin\pdftotext.exe   (pdftotext version 4.00)
```

**Two things that make the fix less obvious than it looks**, both of which will
apply to the next person who edits this PATH:

- `HKCU\Environment\PATH` is **`REG_EXPAND_SZ`** and begins with
  `%USERPROFILE%`. `[Environment]::SetEnvironmentVariable(…,'User')` rewrites it
  as `REG_SZ`, which turns `%USERPROFILE%\AppData\Local\Microsoft\WindowsApps`
  into a literal path that resolves to nothing — and that is where `python`,
  `python3` and `py` come from. The write has to go through
  `Microsoft.Win32.Registry` with `RegistryValueKind::ExpandString`.
- `mingw64\bin` contains **51 executables**, exactly one of which — `curl.exe` —
  collides with a Windows one. Appending to the **end** of the *User* PATH keeps
  Machine PATH ahead of it, so `C:\WINDOWS\system32\curl.exe` still wins. Checked
  in both PowerShell and `cmd`; it does.

**Proposal:** the machine half is done. The repo half is open — `SETUP.md`
§"Setting up a machine" describes what a fresh machine needs and never mentions
`pdftotext`, though `book-survey` depends on it and the book work is the reason
that section exists. Add the requirement, the fact that it comes from Git for
Windows rather than a separate install, the `REG_EXPAND_SZ` warning above, and
one line stating that **a PATH change does not reach an already-open terminal**,
because that makes a correct fix look broken.

**Posture:** documentation, plus the one-line machine step. No script, no check,
nothing that runs. `SETUP.md` is a reference; this is a sentence in it.

**Taken, 2026-09-02 — machine half only, out of band.** Nate said "just fix the
pdftotext path now", overriding decision 2 for this item specifically.
`C:\Program Files\Git\mingw64\bin` was appended to the User PATH via the registry
API with the value kind preserved, `WM_SETTINGCHANGE` was broadcast, and the
prior value was backed up to the session scratchpad. `node`, `npm`, `git`, `gh`,
`python` and `wrangler` were re-checked afterwards and all resolve where they did
before. **The `SETUP.md` half was not done and is what remains of this finding.**

**Taken, 2026-09-02 (PR #575) — the `SETUP.md` half, closing the finding.**
Posture kept: documentation, no script, no check. It went in as a new
*The command-line tools* subsection, because §"Setting up a machine" described
junctions and the user-level pointer and said nothing about tooling at all.

**The justification above is wrong, and the correction is more interesting than
the finding.** This finding says `book-survey` depends on `pdftotext`. **Nothing
in this repo calls `pdftotext`** — `ocr-book.py` and `read-columns.py` both use
PyMuPDF, `book-survey` does not mention it, and every other appearance in the
tree is historical prose saying its column handling is *not* what this cache
does. It is an ad-hoc tool for reading a text layer, granted in
`.claude/settings.json`. The symptom was real and the fix was right; the reason
was not, and `SETUP.md` carries the true one. **A tool nothing calls is exactly
the tool whose absence nobody notices** — the grant meant the only side that
could see it never had to look.

**Checking that premise opened `M16`**, which is the dependency that is real:
`ocr-book.py` hard-exits without `tesseract`, `tesseract` is not on PATH here,
and a hardcoded fallback inside `find_tesseract()` is the only reason sixteen
book caches ever built. Same shape as this finding, one script over, and still
undocumented.

### M2 — high — the skill's explanation of this whole class of failure is wrong

`.claude/skills/windows-shell/SKILL.md` ends with a section titled *"Nate's shell
is not your shell"*. It states that his interactive PowerShell does not see
`%APPDATA%\npm` **although the persisted user PATH contains it**, attributes this
to *"a stale environment block inherited from a long-lived `explorer.exe`"*,
concludes *"the config is fine, the inheritance is not"*, and prescribes: **"Call
binaries by absolute path in anything you hand him to run."** Dated 2026-09-01,
one day old, and left unresolved at his call.

**It does not hold.** The claim is checkable, and the check is not a
reconstruction of his shell — `explorer.exe` can be asked to launch a process,
and that process inherits explorer's actual environment block, which is the thing
under dispute. Run 2026-09-02 at 13:47:

```
explorer.exe has been running since 2026-08-26 19:20  (6d 18h, never restarted)
HKCU\Environment last written  2026-09-02 13:39       (eight minutes earlier)

PATH as inherited from explorer.exe:
  …;C:\Program Files\nodejs\;C:\Program Files\GitHub CLI\;
  C:\Users\natha\AppData\Local\Microsoft\WindowsApps;…;
  C:\Users\natha\AppData\Roaming\npm;C:\Program Files\Git\mingw64\bin

contains AppData\Roaming\npm?   YES
contains mingw64\bin?           YES
where pdftotext                 C:\Program Files\Git\mingw64\bin\pdftotext.exe
where wrangler                  C:\Users\natha\AppData\Roaming\npm\wrangler.cmd
```

An explorer seven days old is handing out a directory added to the registry eight
minutes ago. **The block is not stale; it tracks `WM_SETTINGCHANGE`.** And the
specific variable the skill says is missing is present.

So the skill is wrong twice over: `%APPDATA%\npm` is visible to his shell, and
the mechanism it blames is not a mechanism that is failing. The prescription that
follows — write absolute paths into everything you hand him — is a permanent tax
paid to avoid a problem that is not there, and it is the kind of advice that
makes the real cause harder to find next time, because every command that
would have exposed it has been pre-worked-around.

**What was actually true**, and what is worth keeping: the two shells did differ,
and `M1` is what the difference was. An agent's Bash runs under Git Bash, which
prepends `/mingw64/bin`, `/usr/bin` and its own vendored tools; Nate's PowerShell
gets Machine PATH + User PATH and nothing else. That is a real and permanent
asymmetry — `git` resolves to `/mingw64/bin/git` for an agent and
`C:\Program Files\Git\cmd\git.exe` for him, and `sed`, `diff`, `file` and `tr`
exist for one and not the other — but it is a *difference in which shell*, not a
stale inheritance, and it is diagnosable in one command rather than worked
around.

**Proposal:** replace the *"Nate's shell is not your shell"* section with what is
measured above. Keep the heading and the lesson; replace the mechanism, the
prescription, and the "config is fine, inheritance is not" conclusion. State the
real asymmetry (Git Bash's prepended toolchain vs Machine+User PATH), give the
one-line way to see his PATH rather than guess at it, and drop the
absolute-path rule. Per the audit-menu convention, **correct the claim without
quoting the phrase being replaced.**

**Posture:** documentation only, in one skill. No new rule, no check, and
explicitly **no replacement workaround** — the point of the finding is that the
workaround was the cost.

> **This is also a `SKILL-AUDIT.md` shaped problem**, and deliberately filed
> here anyway: it was found by measuring the machine, it is about the machine,
> and `SKILL-AUDIT.md` audits the instruction layers as layers rather than
> fact-checking their claims against hardware. If Nate would rather it lived
> there, moving it costs nothing.

**Taken, 2026-09-02 (PR #573).** As written — documentation only, one skill, no
replacement workaround, the absolute-path rule removed rather than softened.

**Its own evidence did not survive being taken.** The 13:47 explorer probe this
finding argues from ran **eight minutes after `M1`'s fix broadcast
`WM_SETTINGCHANGE`**, so it cannot separate *explorer was never stale* from *that
broadcast is what refreshed it*. Both predict the result quoted above. Retested
by making it fail: a throwaway value written to `HKCU\Environment` with **no**
broadcast at all was visible immediately to a process launched by an
`explorer.exe` six days old. The conclusion holds — on better evidence than the
evidence filed for it.

**And the decisive fact had been in the 2026-09-01 record the whole time.** That
session recorded an *absolute* path to the npm shim failing as well, and PATH
cannot make an absolute path fail. No inheritance theory was ever consistent with
the note that proposed it. A cheaper falsification than any measurement, sitting
inside the file the finding is about.

**Two additions to the asymmetry, found while building the table** — same class
as `M5`, and worse than a missing command because nothing fails and a different
program answers: `diff` is a PowerShell alias for `Compare-Object`, and `find`
resolves to `C:\WINDOWS\system32\find.exe` rather than GNU `find`. `M5` names
only `curl`, `wget` and `ls`; these belong beside them.

**Left here rather than moved to `SKILL-AUDIT.md`**, per the offer above. What
went there instead is a dated adjustment under its closing table, which cites the
retired sentence.

### M3 — medium — a memory file records the same false claim

`~/.claude/projects/C--Users-natha-Downloads/memory/interactive-shell-lacks-npm-path.md`
carries the `M2` claim in its own words — that agent tools see `%APPDATA%\npm`
and his PowerShell does not, and that binaries should be called by absolute path.
The measurement in `M2` falsifies it.

This is the failure mode the `audit-menu` skill already names: *"when a finding
is taken, grep the whole tree for its number — and check the memory store too,
which no grep of the repo reaches."* Here the memory and the skill were written
from the same investigation on the same day, so correcting one and not the other
leaves the wrong version in the surface that loads **first** and in **every**
session, including sessions that never open the repo.

**Proposal:** rewrite that memory file to record what `M2` measured — that
explorer's block is current, that the real asymmetry is Git Bash's prepended
toolchain, and that the absolute-path rule was a workaround for a
misdiagnosis. Delete nothing else; the file's *existence* is right, its content
is not.

**Posture:** memory maintenance, not a repo change — this finding has no PR of
its own and should be taken **in the same PR as `M2`**, as the memory half of it.
Flagged separately only so that taking `M2` cannot silently leave it behind,
which is exactly what happened to the two files it is about.

**Taken, 2026-09-02 (PR #573)**, inside `M2`'s PR as its memory half — the
posture this finding asked for. The file keeps the one thing in it that was
operationally right, that the `claude` `.exe` works where the `.cmd` and `.ps1`
shims do not, with the path re-verified as present; it loses the causal claim.
Nothing else was deleted.

**The claim reached two surfaces this finding does not name**, which is the
failure mode it was filed to prevent, one level up:

- **`MEMORY.md`'s index line** carried the same claim in its own words.
  Corrected. That line is the surface that loads *first*, in every session,
  including sessions that never open a memory file at all.
- **`instructions-do-not-fire-by-themselves`** cites the retired rule in a table
  of instructions its author broke. That is a record, so it stands as filed and
  gained a dated adjustment: I was faulted there for not following a rule that
  was itself wrong, which is not a defence — **a rule being wrong and a rule not
  firing are different problems, and that table is only about the second.**

### M4 — medium — there is no PowerShell profile, and the default location is the wrong one

None of the four profile paths exist:

```
False  C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
False  C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
False  C:\Users\natha\OneDrive\Documents\WindowsPowerShell\profile.ps1
False  C:\Users\natha\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

There is nowhere for an alias, a `cd` shortcut or a helper function to live, which
is why every convenience so far has been re-typed. And the per-user paths resolve
into **OneDrive**, because `Documents` is redirected there
(`HKCU\…\User Shell Folders\Personal` = `C:\Users\natha\OneDrive\Documents`).
`$PROFILE` is computed from that redirection and cannot be pointed elsewhere
without an environment variable that would then have to be maintained.

**Decision 4 asked this audit to choose. The trade, named:**

*OneDrive* gives sync and version history for free, and costs a conflict-copy
risk on a file that every shell executes — `profile-DESKTOP-x.ps1` beside
`profile.ps1` is silent, and a half-synced profile is a shell that behaves
differently in a way nothing reports. *Outside OneDrive* has no backup at all,
which is the same regime `Downloads` is in and the one this whole audit is trying
to leave.

**Proposal — take the trade apart rather than pick a side.** Put a two-line stub
at `$PROFILE.CurrentUserAllHosts` (the OneDrive path, unavoidable) that
dot-sources the real profile from the new working directory:

```powershell
# C:\Users\natha\OneDrive\Documents\WindowsPowerShell\profile.ps1
$local = 'C:\Users\natha\Projects\workshop\profile.ps1'
if (Test-Path $local) { . $local }
```

The stub never changes, so it never generates a conflict copy; the content lives
where the work lives and moves with it; and a conflict copy of the stub, if one
ever appears, is inert because PowerShell only loads the exact filename. `AllHosts`
rather than `CurrentHost` so the VS Code integrated terminal gets it too.

What goes **in** the real profile is deliberately small, and deliberately **not**
a PATH edit — PATH belongs in the registry, where `M1` put it, and a profile that
edits PATH creates a second source of truth that only some shells see:

- a `cd` function for the repo and for the new working directory
- the `workerd` + `wrangler` kill block from `windows-shell` §"Killing a dev
  server", which is currently pasted by hand every time
- nothing else until something is typed twice

**Posture:** opt-in and minimal. Creating a profile changes the startup of every
PowerShell on the machine, so this finding is the stub plus at most those two
helpers, and additions are their own decision later. **Write it for 5.1** —
`pwsh` is not installed, so no `??`, no ternary, no `&&`.

**Taken, 2026-09-02 (PR #584)**, last of the menu because it is easier once the
destination exists. Every premise re-checked: all four profile paths still
absent, `$PROFILE.CurrentUserAllHosts` still resolving into OneDrive, `pwsh`
still not installed, PowerShell 5.1.26100.9168.

Two files, exactly as proposed. The stub at the OneDrive path dot-sources
`C:\Users\natha\Projects\workshop\profile.ps1`, which holds two `Set-Location`
helpers and the `workerd` + `wrangler` kill block, and **no PATH edit** — PATH
belongs in the registry where `M1` put it, and a profile that edits it creates a
second source of truth that only interactive shells see, which is a harder
version of the problem `M1` and `M2` were about.

**One thing written differently from the letter of the proposal, on purpose.**
This finding asks for "a `cd` function". The helpers are named `repo` and
`workshop` rather than overriding `cd` — **overriding a built-in alias is exactly
the trap `M5` is about**, where the command still runs and quietly does something
else, and shadowing `cd` on a machine whose owner already fights shell surprises
would be the worst possible place to demonstrate it. `cd` is untouched and still
resolves to `Set-Location`.

**Proved by making it fail, both ways:**

```
fresh shell WITH the profile   repo / workshop / Stop-DevServer  all defined
                               cd still resolves to Set-Location
                               startup errors: 0
                               repo -> ...\nates-apps   workshop -> ...\workshop

real profile renamed away      startup errors: 0    repo defined? False
```

The second is the load-bearing one: the stub has to be **inert**, not merely
correct, because it lives in a syncing directory and a half-synced profile is a
shell that misbehaves with nothing reporting it.

**`Stop-DevServer` is the one part not exercised**, because running it would kill
whatever is serving. Its body is verbatim from `windows-shell`; both files parse
with zero errors, and its two queries were run read-only — 0 `workerd` processes
and 0 `wrangler pages dev` parents alive right now.

### M5 — low — `curl` in PowerShell is not curl

`curl` is a PowerShell alias for `Invoke-WebRequest`, so `(Get-Command curl).Source`
is empty and a `curl -s -o /dev/null -w '%{http_code}'` written for the real
binary silently does something else. `curl.exe` reaches the real one, and
resolution order after `M1` is:

```
C:\WINDOWS\system32\curl.exe                 <- wins, in both PowerShell and cmd
C:\Program Files\Git\mingw64\bin\curl.exe
```

This cost time during this audit, and it is the same *class* as `M1`: a command
that resolves to different things in the agent's shell and his, without failing.
`windows-shell` §"Killing a dev server" already tells the reader to use a curl
returning `HTTP 000` as a diagnostic, without saying which curl.

**Proposal:** one line in `windows-shell`, in the section `M2` is already
rewriting — in PowerShell, write `curl.exe`. Same for `wget` and `ls`, which are
also aliases, if that is free to state.

**Posture:** documentation only. **Do not** propose removing the alias; it is a
default that other things rely on.

**Taken, 2026-09-02 (PR #574).** Posture kept — documentation only, no alias
removed.

**The count was wrong and the example was not the worst case.** This finding
names three aliases; a fresh PowerShell has **sixteen**, and `ls`, one of the
three, is at the *harmless* end of the range. Two the finding never mentions are
worse than `curl`:

- **`diff a b` on two identical files reports both as differing** — it is
  `Compare-Object` comparing the two path *strings* — and `$?` is `True`.
- **`sort f` prints nothing at all** and also succeeds.

One inverts its answer, the other erases it, and neither fails. `curl` and `wget`
are the *loud* case by comparison: `Invoke-WebRequest` refuses the flags rather
than lying about them. A check built on `diff` or `sort` is worse than no check,
which is a sharper statement of this finding's own class than the finding makes.

**The `HTTP 000` line this finding pointed at is fixed** in the same section.
Every other `curl` in the instruction layer was read: all but one are prose about
what a fetch returned, and the one runnable command sits in a ` ```bash ` fence
where `curl` and `grep` both exist. Correct for the shell that runs it; left
alone.

### M6 — low — `python` is fine, and the failure mode is worth one sentence

Verified rather than assumed, because a working `python --version` says nothing
about what the scripts import:

```
python           3.14.3   via C:\Users\natha\AppData\Local\Microsoft\WindowsApps\python.exe
                          (Store App Execution Alias -> AppData\Local\Python)
pip                       C:\Users\natha\AppData\Local\Python\bin\pip.exe
import pymupdf   OK       PyMuPDF 1.28.2
```

`scripts/ocr-book.py` imports `argparse, importlib.util, io, json, os, re,
shutil, statistics, subprocess, sys` — all stdlib — plus `pymupdf`, and
`scripts/read-columns.py` imports `sys` and `pymupdf`. Those are the only two
Python files in the tree. Nothing is missing. `pdfminer.six`, `pdfplumber`,
`pypdf` and `pypdfium2` are also installed and nothing here uses them.

**The failure mode worth recording:** the Store alias is a stub that Windows can
turn off — Settings → Apps → Advanced → App execution aliases — and when it is
off, `python` does not fail, it opens the Microsoft Store. It is also ahead of
`AppData\Local\Python\bin` on PATH, so a real install would be shadowed by the
stub rather than replacing it.

**Proposal:** one sentence in `SETUP.md` §"Setting up a machine", beside `M1`'s.
Do **not** pin the interpreter, do not add a `requirements.txt`, do not reorder
PATH. This is a working configuration with a documented way to break; the finding
is the documentation.

**Posture:** documentation only. **This is a "leave it alone" finding** and
should stay one — the temptation on reading it is to "fix" the alias ordering,
which would change a working toolchain to prevent a setting nobody has touched.

**Taken, 2026-09-02 (PR #576)**, and left alone, which is the posture. No
interpreter pinned, no `requirements.txt`, no PATH reordering.

Every premise re-checked and confirmed, including the absence claim — the one
this menu's own protocol says is most likely to be wrong. Proved by reading
rather than grepping: `scripts/` holds exactly two `.py` files and `pymupdf` is
the only third-party import between them.

**One refinement.** The alias target is given here as `AppData\Local\Python`; the
interpreter is at `AppData\Local\Python\pythoncore-3.14-64\python.exe`.
`SETUP.md` records the measured path.

---

# Layout — `M7`–`M15`

The move itself. `Downloads` and `Projects` are on the same volume (`C:`, 398 GB
free), so every move below is a rename: instant, and reversible by renaming back.

### M7 — high — what moves to `C:\Users\natha\Projects\workshop\`, named file by file

**The inclusion rule has to be a list, not a pattern**, and this is the finding
the trap at the top of this file is about. `Downloads` holds 543 entries of which
roughly 40 are work; the rest includes tax documents, medical records, lab
results, a mortgage statement and a custody agreement. **No filename outside the
work set appears anywhere in this document**, and none should appear in the PR
that takes this finding either — a list of what to move is safe to review, a list
of what to leave is not.

**Moves — 50 PDFs, 1,787.9 MB:**

- the **18 registry books**, exactly the `source_pdf` values in
  `scripts/books.json`. All 18 were stat-ed on 2026-09-02 and all 18 are present.
  This list must be read from `books.json` at take-time rather than copied here,
  so the two cannot disagree.
- the **17 sourcebooks not in the registry**, 1,243.4 MB — Baalgor Wastelands,
  Old Ones, Heroes Unlimited 2e, Africa (two copies), World Books 23–32, and the
  duplicate copies of Ultimate Edition and Dragons and Gods that `M8` covers.
- the **10 page-range extracts** cut from books already in the list —
  `juicer-pp69-72.pdf`, four `Rifts - Ultimate Edition-<pages>.pdf`, four
  `Rifts Main-<pages>.pdf`, and `PFRPG - Dragons and Gods-23-24.pdf`. 9.5 MB.
- **5 other game PDFs**: `Rifts-Character-Sheet-fillable.pdf`,
  `Weapon PRoficiencies.pdf`, `mech-boxer-GM-packet.pdf`,
  `occ-rcc-import-tool-spec.md.pdf`, `rifts-character-creator-spec.md.pdf`.

**Moves — 24 of the 25 `.md` files.** All except the personal interview
preparation file, which is not work and stays. `M13` covers what happens to the
briefs after they move.

**Moves — `Downloads\.claude\`, whole directory.** `launch.json`,
`settings.local.json` and its `.bak`. `M11` covers why moving it wholesale is
the right shape.

**Does NOT move — `Downloads\.wrangler\`.** 21 entries, 0.07 MB, residue from
`wrangler` having been run in `Downloads` at some point. It holds
`cache/wrangler-account.json`, `cache/cf.json` and a miniflare cache. It is
regenerable, it is not referenced by anything, and it should be deleted rather
than carried — **but deletion is not in scope**, so this proposes only that it is
not moved, and flags it for the same call as `M8`.

**Does NOT move — everything else**, which is 49 non-game PDFs (51.3 MB), 208
`.3mf`, 38 `.stl`, 40 `.png`, 25 `.jpeg`, 20 `.zip`, 18 `.exe` and the remaining
directories.

**Proposal:** move the named set. Nothing is renamed, nothing is deleted, nothing
outside the list is touched. Take this finding **after** `M9` and `M10` — see
*Order* below.

**Posture:** move only. No deletion in this finding, no reorganisation of what
stays behind, and no cleanup of `Downloads` as a directory — that is a separate
decision Nate takes separately, and this finding is careful not to pre-empt it.

**Taken, 2026-09-02 (PR #581)**, with `M9` and `M12` per *Order*.

```
workshop/books      47 PDFs      (50 moved, then M8's 3 deleted)
workshop/briefs     26 .md
workshop/.claude    moved whole

Downloads: 49 non-game PDFs, the 1 personal .md, .wrangler/ — untouched
```

**Adjusted 2026-09-02, later the same day: `.wrangler/` is gone.** The block
above is left as it was measured. On Nate's word it was inspected and deleted —
10 files, 94 KB: three API caches, a miniflare `CacheObject` and two build temp
directories. **Checked first that `state/v3/` held no `d1` directory**, so no
local database was in it and nothing was lost. `Downloads` is now 467 entries
with no work artefact left in it. This finding proposed only that `.wrangler/`
not be *moved*; deleting it was the separate call it flagged for `M8`.

**Taken against the list, not a fresh scan**, which is what the header asks for.
The 18 registry books were read from `books.json` at run time so the two could
not disagree; the other 32 came from the literal names above. The script refused
to proceed unless every named file was present and no name appeared twice.

**Two numbers moved, both upward and both harmless.** 26 `.md` files rather than
24 — `M13`'s note explains the two that arrived after the 13:20 measurement. The
PDF count and total held exactly at 50 and 1,787.9 MB.

**The internal layout was not specified by this finding and had to be decided.**
The brief asked for it — *"Books, briefs, and config are three different things;
say whether they get subdirectories and why"* — and `M7` lists what moves without
saying where it lands. Nate chose `books\` + `briefs\` + `.claude\`, which is what
`M9` then wrote into `source_pdf_dir`.

### M8 — medium — five identical duplicate pairs, 122.4 MB of it in three PDFs

SHA-256 compared, 2026-09-02. All five pairs are **byte-identical**:

| kept | duplicate | wasted |
|---|---|---|
| `Rifts - Ultimate Edition.pdf` | `442806688-Palladium-Books-Rifts-Ultimate-Edition-pdf.pdf` | 58.7 MB |
| `PFRPG - Dragons and Gods (1).pdf` | `PFRPG - Dragons and Gods.pdf` | 53.3 MB |
| `604225358-Rifts-World-Book-04-Africa.pdf` | `604225358-Rifts-World-Book-04-Africa (1).pdf` | 10.4 MB |
| `REVIEW-BRIEF.md` | `REVIEWBRIEF.md` | — |
| `setup-v2-rewrite-prompt.md` | `setupv2rewriteprompt.md` | — |

The two `.md` pairs are the ones the brief knew about, and `docs/prompts/README.md`
already resolved the second of them in favour of the hyphenated name and calls the
pattern *"what an unmanaged directory does over time."* **The three PDF pairs are
new to this audit** and are 122.4 MB between them.

The *kept* column is not arbitrary: for the first two, the name in the left column
is the one `scripts/books.json` records as `source_pdf`, so deleting the other
side is the only choice that leaves the registry true. For Africa, neither is in
the registry and the `(1)` suffix marks the later download.

**Proposal:** move only the left column under `M7`; leave the right column in
`Downloads` for Nate to delete, together with `.wrangler\`. **Deletion is not in
scope for this menu** — the finding is the identification and the hashes, and the
call is his.

**Posture:** identify, do not delete. If he would rather they were carried across
too, that is a smaller change than deleting them and this finding does not
object.

**Taken, 2026-09-02 (PR #581), AND THE POSTURE WAS OVERRIDDEN.** Nate was asked
which of two conflicting instructions to follow and answered *move everything,
then delete the duplicates now*. So the three PDFs were carried across with
everything else and then deleted — 122.4 MB. **This finding says do not delete;
it was deleted on his explicit word, and that is recorded here rather than
quietly done.** The two `.md` duplicates were carried across and left alone.

**This finding and `M7` contradicted each other and could not both be taken as
written.** `M7`'s file list includes the three duplicates in its 17 unregistered
sourcebooks; this finding says move only the kept side. Surfaced before the move
rather than resolved by picking one.

**Re-hashed immediately before deleting**, not trusted from the morning:

```
IDENTICAL  58.7 MB  442806688-Palladium-Books-Rifts-Ultimate-Edition-pdf.pdf
IDENTICAL  53.3 MB  PFRPG - Dragons and Gods.pdf
IDENTICAL  10.4 MB  604225358-Rifts-World-Book-04-Africa (1).pdf
```

And checked first that **each kept side was itself in a move list**, so deleting a
twin could not lose a book — two are named in `books.json`, the third in `M7`'s
unregistered list. A hash proves two files are the same; it does not prove the
survivor is going anywhere.

### M9 — high — `books.json`'s 18 `source_pdf_dir` values, and the test that will not catch them

Every one of the 18 registry entries records
`"source_pdf_dir": "C:\\Users\\natha\\Downloads"`. The field is the recovery
record: `.cache/books/` is gitignored, holds the full text of books Palladium
still sells, and is rebuilt by one `ocr-book.py` run from `source_pdf` +
`source_pdf_dir`. Nothing rebuilds a PDF that was not kept.

**The trap is what pins it.** `apps/character-creator/test/smoke.mjs` checks that
every book naming a `source_pdf` also names a `source_pdf_dir`, and that no book
names a directory without a PDF. **Both checks are on presence, not on value.**
A registry whose 18 entries all point at a directory that no longer holds the
PDFs passes the suite cleanly, and the failure surfaces the next time somebody
needs to rebuild a cache — which is exactly the moment there is no fallback.

Two registry books have no cache today, `rifts-core` and `rifts-skill-list`; the
second is a known non-book. Neither changes this finding, and neither is in scope.

**Proposal:** update all 18 values to the new directory **in the same PR that
takes `M7`, and after the files have moved** — see *Order*. Do not add a check
that the directory exists: it would fail on any machine that is not this one, and
`.cache/` is rebuildable by design.

**Posture:** data change, no new gate, no change to `smoke.mjs`. The presence
checks stay exactly as they are; this finding does not propose making them
value-aware, because a path check in a test suite is a machine assumption in the
one place the repo has been careful not to put one.

**Taken, 2026-09-02 (PR #581)**, in `M7`'s PR and after the files had physically
moved, which is the ordering this finding asks for. Posture kept: **no new gate,
`smoke.mjs` untouched, the presence checks left exactly as they are.** All 18
values now read `C:\Users\natha\Projects\workshop\books`.

**One mistake worth recording, because the obvious method is wrong.**
`JSON.stringify` was the natural way to rewrite 18 values and it **reformatted
the whole file** — the blank lines separating this registry's sections are not
recoverable from the parsed object, so an 18-value change landed as a 46/45 diff.
Reverted, and redone as a literal substitution on the value string. That version
**proves itself by round-tripping**: undoing the replacement has to reproduce the
original byte for byte or it refuses to write. Result `18/18`.

**And it checks what the suite will not.** Before writing, it confirms all 18
`source_pdf` files resolve *under the new directory*. Afterwards,
`ocr-book.py` was run end to end against a PDF resolved **from this file** — one
page OCR'd into a scratch cache. That is the only evidence that the recovery
record is right rather than merely present, and it is exactly the gap this
finding names.

### M10 — high — the memory store is keyed to the working directory and does not follow

`~/.claude/projects/C--Users-natha-Downloads/memory/` holds **64 files** — 63
memories plus `MEMORY.md`, which is the index loaded into every session. The key
is derived from the working directory, so a session started in
`C:\Users\natha\Projects\workshop` reads
`~/.claude/projects/C--Users-natha-Projects-workshop/memory/`, which does not
exist. The memories do not follow, and nothing reports their absence — the next
session simply starts with no history and re-learns.

Three project keys exist today: `C--Users-natha-Downloads` (64 memory files, 74
session transcripts), `C--Users-natha-Projects-nates-apps` (0 memory files, 1
transcript) and `C--WINDOWS-system32` (0, 1).

**Proposal:** create the new key's directory and **copy** `memory/` into it —
all 64 files, `MEMORY.md` included. Copy rather than move, and leave the 74
session transcripts under the old key: the transcripts are a record of sessions
that genuinely ran in `Downloads`, several memory files cite them, and renaming
the whole project directory to carry them would rewrite that history for no gain.
The old `memory/` copy becomes dead weight and can be removed later once the new
one is confirmed — that is a second decision, not part of this one.

**Verify by name, not by count.** A count of 64 on both sides proves the copy
ran; it does not prove the *right* store was copied. Start one session in the new
directory and confirm a specific memory recalls — `nates-apps-monorepo` and
`book-ingest-batch-protocol` are the two the book work depends on first.

**Posture:** copy, do not move; delete nothing in this finding.

**Taken, 2026-09-02 (PR #580).** Posture kept: copied, nothing moved, nothing
deleted. The 74 transcripts stay under the old key.

Every count re-measured and every one holds — 64 memory files, 74 transcripts,
three project keys. The new key is
`~/.claude/projects/C--Users-natha-Projects-workshop/memory/`, derived the same
way the existing two are.

**Verified by hash rather than by count**, which is a stronger version of what
this finding asks for: 64 of 64 present, **zero name mismatches and zero SHA-256
mismatches**, `MEMORY.md` included. A matching count proves the copy ran; matching
hashes prove it copied *this* store. `nates-apps-monorepo` and
`book-ingest-batch-protocol` were both opened and read intact.

**The recall check is still Nate's**, and is the one thing that cannot be done
from here: start a session in the new directory and ask for a memory by name. A
file being present is not the same as it being recalled.

**Adjusted 2026-09-02, later the same day — the recall check passed, and the old
store is deleted.** A session started in `C:\Users\natha\Projects\workshop`
returned the specifics that exist only in memory: `one-session-at-a-time`'s date
of 2026-08-26 and its reasoning about what was merged versus pushed versus
uncommitted, and `run-commands-dont-hand-them-over`'s exact exception list.

**The strongest evidence was accidental.** Asked to list its index, the session
returned a line written *minutes earlier in this menu's own take* — the machine
audit entry reading `M1–M18 all shipped 2026-09-02`. A stale or wrongly-keyed
store could not have produced it. That is a recall proof no count or hash could
give, and it arrived from the confirming question rather than the primary one.

**A first draft of that check would have proved nothing**, and it is worth
recording why: the question originally proposed was *"what do you know about the
nates-apps monorepo?"* — which a session in the new directory can answer from the
repo's own `CLAUDE.md` and `SETUP.md` without any memory at all. The test had to
ask for something with **no repo counterpart**, which is what the `feedback`
memories about working style are. Same failure shape as every false confirmation
in this file.

So the second decision this finding deferred is taken: the 65 files under
`C--Users-natha-Downloads/memory/` were re-hashed against the new store, found
identical, and deleted. **The 74 transcripts stay**, as this finding requires.
The reason for deleting rather than keeping a spare is the argument `SETUP.md`
already makes about `CLAUDE.md`: a second synced copy is a second surface to keep
in sync, and it had to be hand-synced four times in one day — once per finding
that touched a memory.

**Two `[[links]]` in the store point at nothing** — `[[audit-menu]]` and
`[[claim-audit]]`. They name *skills*, not memories. Pre-existing and identical
in the source, so not introduced by the copy and deliberately not fixed here.

**And the finding's scope stops short of a real problem, now filed as `M17`.**
This finding moves the memory *store*. Eleven of the 64 files name
`C:\Users\natha\Downloads` inside their own *content*, and `M7` makes some of
those false.

### M11 — medium — the permission file follows for free, and should not be promoted into the repo

The brief treated `Downloads\.claude\settings.local.json` as 77 KB of value at
risk. Measured, it mostly is not at risk and mostly is not value:

```
258 allow entries
  206  path-independent command strings  -> survive a move of .claude/ verbatim
   47  literal session-scratchpad paths keyed to C--Users-natha-Downloads
        (the session directories are gone; these are already dead)
    5  one-off reads of specific Downloads files
```

Because `settings.local.json` lives at `<working directory>\.claude\`, **moving
the `.claude/` directory with everything else carries the 206 useful entries
unchanged.** There is no migration to design. The 47 dead entries were already
identified in `CLAUDE.md` as *"dead rather than dangerous"* and left alone; that
judgement still holds and this finding does not revisit it.

**On the brief's suggestion that some entries be promoted into the repo's tracked
`.claude/settings.json`: no, and it is worth saying why in the finding.** The
`.gitignore` rule — *"launch.json is shared, local permissions are not"* — and
`CLAUDE.md` §"The permission allowlist is read-only, and its gaps are the point"
are the same decision written twice. That file was pruned on 2026-09-02 precisely
to make the two lists agree in posture: writes and arbitrary execution ask,
wherever the session started. Promoting accumulated approvals into the tracked
file would move grants from a list that is per-machine and disposable into one
that is version-controlled, reviewed and shared — the opposite direction from the
prune, and it would re-open a question the prune closed.

**Proposal:** move `.claude/` as part of `M7` and change nothing inside it. State
in `SETUP.md` that the working directory's `.claude/` moves with the working
directory, since that is the non-obvious part.

**Posture:** **leave it alone.** No promotion, no pruning, no restructuring — the
finding is the measurement and the explicit "no" to promotion, so that the
question is closed with a reason rather than left to be re-asked.

**Taken, 2026-09-02 (PR #583), and left alone.** Not one byte of
`settings.local.json` changed. It rode across inside `.claude/` under `M7` and
still holds 258 entries at 75.4 KB. `SETUP.md` now carries the measurement and
the explicit "no".

**Re-measured after the move, and this finding's numbers are exactly right** —
47 dead scratchpad entries, 5 naming the old working directory, **206
surviving**. Reaching that took three attempts and the two failures are the
useful part:

- A drive-letter regex counted `https://` as an absolute path, because `s:/`
  matches `[A-Za-z]:[\\/]`. It inflated the path-dependent count by 31.
- The entries store Windows paths with **doubled** backslashes — they are command
  strings that were themselves escaped — so a search for
  `C:\Users\natha\Projects\nates-apps` matches none of the 77 entries that
  contain it.

Either error alone would have produced a confident wrong number and a false
correction to a finding that was right.

**The breakdown is sharper than "path-independent" suggests.** Of the 206, **77
name the repo by absolute path** and survive for a specific reason — the repo did
not move — and 126 name no path at all. Only 3 name anywhere else; two of those
reach a `palladium` checkout under OneDrive that nothing else here mentions.

### M12 — medium — the junctions survive; the pointer and a count do not

The brief called the junction apparatus the highest-leverage item in the menu. It
is the lowest — verified, not assumed:

```
~/.claude/skills/    9 junctions, all -> C:\Users\natha\Projects\nates-apps\.claude\skills\<name>
                     (audit-menu, book-survey, claim-audit, class-import,
                      pick3cut5, schema-change, ship-pr, verify-ui, windows-shell)
                     10 plugin skills sit beside them as real directories
~/.claude/agents     1 junction  -> C:\Users\natha\Projects\nates-apps\.claude\agents
```

None of these is keyed to the working directory. They live in `~/.claude`, they
target the repo by absolute path, and the repo is not moving. **A session started
in `Projects\workshop` finds all nine skills and the subagent by name for exactly
the same reason one started in `Downloads` does.** The move changes nothing here
and the finding is mostly a "confirmed, no work" — except for two things it
turned up.

**First, `SETUP.md` contradicts itself by three.** The PowerShell block at line
464 loops over nine skills; the prose at line 479 says *"plugin-installed skills
sit beside the six repo junctions."* Disk has nine. A reader copying the block
gets the right answer and a reader reading the sentence does not — which is the
identical failure `SETUP-v2-CHANGES.md` §2 recorded about the structure tree, one
section away, on a different count.

**Second, `~/.claude/CLAUDE.md` needs one word changed and one count.** It is the
user-level pointer, it loads in every session on this machine, it is *checked in
nowhere*, and it says the book work runs from `Downloads` and that **six** skills
are junction-linked. After the move both halves are wrong. Nothing in the repo
can catch this: it is the one file in the instruction surface that no test, no
grep of the tree and no other document reaches.

**Proposal:** correct the count in `SETUP.md` §"Setting up a machine" to nine and
say the loop is the authority. Rewrite `~/.claude/CLAUDE.md`'s directory
reference and count in the same PR that takes `M7`, and add a line to `SETUP.md`
recording that this file exists, is not checked in, and has to be edited by hand
when the working directory changes — that being the entire reason it is capable
of going stale.

**Posture:** documentation. **Do not** propose checking `~/.claude/CLAUDE.md`
into the repo or generating it — `SETUP.md` already argues that a copy would be a
second surface to keep in sync, and that argument has not changed.

**Taken, 2026-09-02 (PR #581)**, in `M7`'s PR because the pointer is the file
that tells every session where the work is. Posture kept: **documentation only,
nothing generated, and `~/.claude/CLAUDE.md` is not checked into the repo.**

**The junctions survived untouched, as predicted** — nine, all resolving into the
repo, plus the agents directory. Confirmed rather than assumed. Nothing about
them was keyed to the working directory.

**The count was wrong in three places, not the two this finding names.**

| where | said | is |
|---|---|---|
| `SETUP.md`, junction prose | six repo junctions | **nine** |
| `SETUP.md`, the `CLAUDE.md` paragraph | six skills | **nine** |
| `SETUP.md`, the `notepad` block | the pointer runs to six short paragraphs | **four** |
| `~/.claude/CLAUDE.md` | the count, **twice**, and the previous working directory | corrected |

The third is new to this pass. All four are fixed, and the `notepad` block no
longer states a count at all — a number describing a file nothing measures is the
same class of claim as the two that had already rotted.

**Why only these rotted, in one line:** the suite pins the skill count in
`CLAUDE.md` **as a word**, and pins the junction loop's *completeness*. It pins
no prose count in `SETUP.md`. The pinned numbers held; every unpinned one drifted.

`SETUP.md` now also records that the pointer is maintained by nothing but a hand,
and names the two things it carries that have moved before.

**Also on disk:** eleven plugin directories sit beside the nine junctions, where
this finding counts ten.

### M13 — low — the loose briefs are already archived, byte for byte

The brief asked what happens to the loose copies in `Downloads` if the working
directory moves, treating their relationship to `docs/prompts/` as open. It is
not open. Every one of the 18 archived briefs was compared to its loose copy on
2026-09-02:

```
18 of 18  content-identical
 0 of 18  any real difference
```

The files differ on disk only in line endings — the loose originals are LF, the
checked-out copies are CRLF, because `core.autocrlf=true` and `.gitattributes`
pins LF for `*.sql` only. So `docs/prompts/` is a complete and faithful archive,
and the loose copies are redundant rather than authoritative.

Five loose `.md` files are **not** archived: `juicer.md`,
`mech-boxer-statblocks.md`, `portability-audit-prompt.md`,
`workstation-consolidation-prompt.md` (this menu's own brief), and the personal
interview file that `M7` leaves behind.

**Proposal:** move the 24 work `.md` files under `M7` and stop there for the
archived 18 — they are working copies, they are safe to keep, and they are safe
to lose. Archive `workstation-consolidation-prompt.md` into `docs/prompts/` when
this menu is opened, matching what every other brief in there did.
`portability-audit-prompt.md` describes an investigation that was **dropped on
2026-09-02**; archive it too, since the archive's own README argues that a brief
is a record of what was asked, and a dropped direction is a record worth having.
`juicer.md` and `mech-boxer-statblocks.md` are game content rather than briefs
and belong in the new directory, not in `docs/prompts/`.

**Posture:** move and archive. **Do not edit any archived brief to match what
happened** — `docs/prompts/README.md` is explicit that a brief is a record, not a
document, and `portability-audit-prompt.md` in particular must go in describing
the investigation that was dropped, not annotated with the fact that it was.

**Taken, 2026-09-02 (PR #578) — the archive half.** The file *moves* belong to
`M7` and are not in that PR. Posture kept: nothing already archived was edited,
and `portability-audit-prompt.md` went in un-annotated.

**18 of 18 re-verified** content-identical to their loose copies. The claim holds.

**The count moved between the measurement and the take, and this menu's own
header predicted it.** 25 loose `.md` files at 13:20; **27** now, so the
unarchived list is **seven**, not five. The two additions are
`SPELL-DESCRIPTIONS-RESEARCH-PROMPT.md` (written 13:51) and
`RETRO-CHECK-PROMPT.md` (13:58) — **both after this audit measured the
directory**. Not a miscount; the trap firing on the one finding that is about
files in that directory, inside four hours.

**Neither was archived, by the archive's own rule.** Both are briefs that have
not been run, and `docs/prompts/README.md` says to copy a brief in when it
produces something worth keeping and only then. They are work, so they move to
`workshop\briefs\` under `M7`.

**One tension in this finding, resolved rather than stepped around.** Archiving
`portability-audit-prompt.md` breaks that same rule — it produced no artefact.
The README now carries a short section saying so and why it is kept: a decision
*not* to do something is the hardest thing to reconstruct afterwards, and this
menu's own opening claim that portability was dropped needs a file to point at.

### M14 — medium — two `launch.json` files, and they have already drifted

`.claude/launch.json` is tracked. `Downloads\.claude\launch.json` is not, and it
is not a copy — the two have diverged in four ways:

| | tracked `.claude/launch.json` | `Downloads\.claude\launch.json` |
|---|---|---|
| commands | `npx wrangler …` | `cmd /c cd /d C:\Users\natha\Projects\nates-apps && npx wrangler …` |
| comments | 20 `//` lines: the 8788 collision trap, why the `-879x` hatches exist | **none** |
| entries | 5 | 6 — has an extra `workshop-attach` that attaches to port 8788 without starting anything |
| naming | `nates-apps+pick3cut5` | `nates-apps-pick3cut5` |

**The untracked one has to exist**, and the reason is the same reason the
junctions exist: a session started outside the repo has the wrong working
directory, so every command needs the `cd /d` wrapper. That does not change after
the move — `Projects\workshop` is outside the repo too — so the file moves with
`.claude/` under `M7` and keeps working, since it hardcodes the *repo* path
rather than the *working directory* path.

**What is wrong is the drift, and specifically which half is missing.** The 20
comment lines are the only written record of the 8788 trap — a `pages dev` on a
port already serving another worktree's code, where the page loads, looks like
your app, and is not. The file a session *outside the repo* actually loads is the
one with none of that. There is exactly one worktree on disk today
(`C:\Users\natha\Projects\nates-apps`, on `main`), so the trap has no live
instance right now; it had three.

**Proposal:** make the untracked file a stated derivative of the tracked one —
same entries, same names, same comments, plus the `cd /d` wrapper and the
`workshop-attach` entry. Record in `SETUP.md` that it is derived, that it is
untracked on purpose, and that a change to the tracked one has to be mirrored.
Consider promoting `workshop-attach` **into** the tracked file, since attaching
to a running server is not a Downloads-specific idea and its absence there is
probably an accident.

**Posture:** synchronise and document; no script. A generator for a five-entry
JSON file is more machinery than the problem justifies, and the mirror rule is
one sentence. **Do not** delete the untracked file — it is load-bearing.

**Taken, 2026-09-02 (PR #579).** All four drift points confirmed. Posture kept:
no generator, nothing deleted, `SETUP.md` carries the mirror rule.

The untracked file now matches entry for entry, name for name, port for port and
comment for comment, plus the wrapper. **Checked mechanically rather than by
eye** — no tracked entry missing, no port mismatch, and no command difference
once the `cd /d` prefix is stripped.

**`workshop-attach` promoted, carrying a warning it had nowhere.** This finding
invited the promotion; taking it turned up *why that entry is the interesting
one.* It is **attach-only**, which makes it the entry **most** exposed to the
same 8788 trap the rest of the file documents: every other entry at least tries
to bind the port and reports failure, while this one silently attaches to
whatever is already listening — including another worktree's server. It carried
no comment at all in the single copy that had it, which is this finding's own
drift one level down.

**Found while taking this, and carried to `M10`:** eleven files in the memory
store name the `Downloads` path *inside their own content*. `M10` describes the
store not following the move and does not mention that.

### M15 — low — the two things to leave exactly as they are

Filed as a finding because both look like defects on sight and neither is, and
because an unrecorded "we looked at this" gets re-opened.

**`~/.claude.json` holds four project keys, two of which are the same
directory.** `C:/Users/natha/Projects/nates-apps` and
`C:\Users\natha\Projects\nates-apps` are separate entries with separate state, as
are `C:/WINDOWS/system32` and the `Downloads` key. The obvious worry is that
permissions and trust are split across spellings and that this is why things
re-prompt. Checked: `allowedTools` is **empty in all four** and
`hasTrustDialogAccepted` is **true in all four**. The real grants live in
`settings.local.json`, which is keyed to the directory rather than to the string.
The duplicate is cosmetic. **Leave it** — hand-editing `~/.claude.json` to merge
keys risks a 52 KB file that Claude Code rewrites on every exit, for no
behavioural gain.

**The OneDrive redirection of `Documents`, `Desktop` and `Pictures`.** It is the
reason `$PROFILE` lands where it does (`M4`) and the reason an abandoned git
repository is syncing (decision 3). Un-redirecting is a large, disruptive,
whole-machine change that would move files the audit has no business moving.
`M4`'s stub is the targeted answer to the one consequence that matters. **Leave
the redirection alone**, and note that `Downloads` staying un-redirected is
*correct* rather than an inconsistency — it is the one folder where a browser
writes unpredictably, and syncing it is worse than not.

**Posture:** no change to either. This finding is taken by appending a note that
says it was considered and declined, and closing it.

**Taken, 2026-09-02 (PR #577), and declined — which is the finding.** Nothing was
changed. Both claims re-measured rather than re-read, and both hold exactly:

```
~/.claude.json           allowedTools  trust
  C:\Users\natha\Downloads                    0   True
  C:/WINDOWS/system32                         0   True
  C:/Users/natha/Projects/nates-apps          0   True
  C:\Users\natha\Projects\nates-apps          0   True

HKCU User Shell Folders
  Personal        C:\Users\natha\OneDrive\Documents
  Desktop         C:\Users\natha\OneDrive\Desktop
  My Pictures     C:\Users\natha\OneDrive\Pictures
  {374DE290-…}    C:\Users\natha\Downloads      <- Downloads, NOT redirected
```

`allowedTools` is empty and trust is accepted in **all four** keys, so the
duplicate spelling splits nothing that matters. Declined as stated: hand-editing
a file Claude Code rewrites on every exit, for no behavioural gain.

**One consequence this finding could not have known, recorded so it is not later
mistaken for a defect.** `M7` gives a session a new working directory, which
creates a **fifth** project key — `C:\Users\natha\Projects\workshop`. It starts
with `allowedTools` empty and no accepted trust, so **the first session started
there will ask the trust question once.** That is normal and is not the `M10`
memory problem or the `M11` permission problem; both of those are solved by the
directory move itself, and neither produces a prompt.

---

# Opened while taking a finding

### M16 — high — `ocr-book.py` requires `tesseract`, it is not on PATH, and a hardcoded fallback is the only reason that does not show

Found while taking `M1`, by checking its premise. `scripts/ocr-book.py` — the
script `M9`'s entire recovery story rests on — **does not call `pdftotext`.** It
shells out to **`tesseract`**, and exits with *"tesseract not found - install it
or put it on PATH"* when it cannot find one. `scripts/read-columns.py` uses
PyMuPDF and shells out to nothing. Every other mention of `pdftotext` in the tree
is historical prose about how its column handling is *not* what this cache does.

Measured 2026-09-02, in a shell carrying only the persisted PATH:

```
tesseract                                       NOT FOUND on PATH
C:\Program Files\Tesseract-OCR\tesseract.exe    present
```

It runs today only because `find_tesseract()` carries that absolute path as a
fallback after `shutil.which`. Sixteen book caches under `.cache/books/` were
built through it, so the path is exercised rather than theoretical.

**Two things follow.** A fresh machine that installs Tesseract anywhere else gets
the hard exit, and `SETUP.md` does not mention Tesseract at all. And the fallback
is doing load-bearing work while reading as a nicety — which makes the missing
PATH entry invisible in **exactly** the way `M1`'s was, one script over, at a
moment when nobody was looking for a second instance of it.

**Proposal:** one paragraph in `SETUP.md` §"Setting up a machine" → *The
command-line tools*, beside `pdftotext`'s: Tesseract is required by
`ocr-book.py`, it is not on PATH here, the script reaches it through a hardcoded
fallback, and a machine that installs it elsewhere has to put it on PATH. Do
**not** add a check, and do **not** touch `find_tesseract()` — the fallback is
what makes this machine work, and removing it would break the working case in
order to expose a theoretical one.

**Posture:** documentation only. **Filed, not taken** — opened while taking `M1`
and left for a separate word, because the numbering exists so that the decision
to take it can be separate from the decision to write it down.

**Taken, 2026-09-02 (PR #586)**, on Nate's word. Posture kept exactly:
documentation only, **no check added, and `find_tesseract()` untouched.**

Every premise re-measured and every one holds — `tesseract` still absent from a
shell carrying only the persisted PATH, still present at
`C:\Program Files\Tesseract-OCR\tesseract.exe`, the `(x86)` alternative still
absent, and `find_tesseract()` unchanged.

**Two details this finding did not have**, both worth a fresh machine knowing:
it is **v5.4.0** (leptonica 1.84.1), and it carries **only the `eng` and `osd`
language data**. A machine that installs Tesseract without the English
traineddata fails differently from one that lacks the binary, and neither failure
names PATH.

**One claim was softened rather than repeated.** This finding says sixteen book
caches were built through the fallback. Sixteen caches exist, but not all of them
went through Tesseract — `bom` was re-cached from its *text layer*, and
`ocr-book.py` skips OCR for a PDF that has one. What is provable is smaller and
enough: an `ocr-book.py` run on 2026-09-02 OCR'd a page through that fallback,
during `M7`'s verification. `SETUP.md` says that instead.

### M18 — OBSERVATION, NOT A DIAGNOSIS — `CommandNotFoundException` on a bare command name that resolves minutes later

**This finding proposes nothing and explains nothing. It exists so that a
recurrence has something to attach to, and so that four dead hypotheses are not
re-run.**

Observed 2026-09-02 in Nate's own interactive PowerShell, immediately after `M7`
and `M4` shipped, while verifying them:

```
PS C:\Users\natha\Projects\workshop> claude
claude : The term 'claude' is not recognized as the name of a cmdlet, function,
script file, or operable program.
```

Minutes later, **same window, same PATH, nothing reconfigured**:

```
bare claude found:   True
bare wrangler found: True
  ExternalScript  C:\Users\natha\AppData\Roaming\npm\claude.ps1
  Application     C:\Users\natha\AppData\Roaming\npm\claude.cmd
  Application     C:\Users\natha\AppData\Roaming\npm\claude
```

**Every static precondition was measured while it was failing, and all of them
hold:**

| checked in his window, at failure time | result |
|---|---|
| `C:\Users\natha\AppData\Roaming\npm` on `$env:PATH` | present |
| `claude.cmd` on disk | present |
| `Get-Command claude.cmd` (exact name) | **resolves** |
| elevated? | no |
| `$env:PATHEXT` | `.COM;.EXE;.BAT;.CMD;…` — `.CMD` present, byte-identical to a working shell |

**Four hypotheses, all falsified by measurement rather than by argument:**

1. **The extensionless npm shim shadows bare-name lookup.** Built it: a scratch
   directory on PATH with a `.cmd` alone, then the extensionless twin added
   beside it. The bare name resolved to the `.cmd` in both cases. Dead.
2. **Elevation.** His window reported `IsInRole('Administrators')` = `False`. Dead.
3. **`PATHEXT` missing `.CMD`.** It is not missing; his value is identical to a
   shell where the same command resolves. Dead.
4. **Running the `.exe` repaired the shims.** Contradicted by the timeline —
   `claude.cmd` already resolved by exact name *before* the `.exe` was run. Dead.

**Why this is filed as an observation and nothing more.** The one thing known
about it is that it is **intermittent**: it recovered with no configuration
change, in the same process. A plausible-sounding mechanism written down here
would be indistinguishable from the 2026-09-01 diagnosis that `M2` had to
retire — and that one cost a day and bought a permanent absolute-path tax on
every command handed over. **The fault is real, and unexplained is the honest
state.**

It also makes one older observation less mysterious and more interesting.
`M2`'s source session recorded that an **absolute path to the npm shim failed
too** — the fact that killed every PATH theory. An intermittent discovery fault
fits that shape where no configuration explanation ever did, though this is a
resemblance and explicitly not a finding.

**Nothing in `windows-shell` needs correcting.** The sentence shipped there on
2026-09-02 says `%APPDATA%\npm` is on his PATH and `wrangler` resolves there for
him; `bare wrangler found: True` measured in his own shell. It is right as
written.

**Proposal:** none, beyond this record. **If it recurs, capture it before running
anything else** — in the failing window, `Get-Command <name> -All`,
`$env:PATH -split ';'`, and `$env:PATHEXT`. Those three at the moment of failure
are the only data that would advance this; everything gathered afterwards has
described a machine that had already recovered.

**Posture:** observation only. **No change, no check, and explicitly NO
WORKAROUND.** Reaching for absolute paths again is exactly the reflex `M2`
retired, and against an intermittent fault it would once more hide the only
symptom capable of exposing it.

**Taken, 2026-09-02 (PR #588).** This finding proposes nothing to implement, so
taking it meant doing the two things it actually asks for: **try to reproduce
it**, and **make a recurrence catchable**.

**Reproduction attempted, and failed — which is itself a result.**

```
in-process bare lookups          1,592     failures: 0
shim existence checks            4,776     missing:  0
claude.exe --version launches       10     shims never blinked
fresh PowerShell processes          60     failures: 0
```

So it is **not** a startup-path fault, **not** a routine flake at anything like
1-in-1,600, and **not** triggered by launching the binary. It also kills a fifth
hypothesis raised while taking this: the `@anthropic-ai/claude-code` package
*was* rewritten at 15:37:48 that day by Claude Code's own self-update — but the
npm shims were untouched (still dated 2026-08-17), no `npm install` appears in
the day's npm logs, and the update ran **after** the failure, not during it.

**The consequence is the finding's real conclusion:** if 1,592 automated lookups
cannot catch it, a person will not catch it by hand mid-frustration, and this
finding's own instruction — *capture it before running anything else* — is not
executable by a human.

**So the capture was automated.** `workshop\profile.ps1` now sets
`$ExecutionContext.InvokeCommand.CommandNotFoundAction`, scoped to a watchlist of
names that should always resolve. On a failure it appends the timestamp, PID and
process start, `PATH`, `PATHEXT`, what matches on disk, and what
`Get-Command -All` saw, to `workshop\command-not-found.log`.

**This is a recorder, not a workaround, and the distinction is the whole finding.**
The command still fails identically; nothing is routed around; a typo not on the
list costs nothing. Proved by making it fire — a watched name in a shell with a
stripped PATH captured this:

```
=== 2026-09-02 16:19:03.268  claude NOT FOUND ===
npm dir on PATH: False
files matching : claude, claude.cmd, claude.ps1
Get-Command -All:
    (nothing)
```

Which is exactly the discrimination that was impossible after the fact: it
separates *PATH lost the entry* from *the shims vanished* from *discovery failed
with both intact*.

**Two bugs in the recorder, both caught before shipping and both worth naming.**
The first build shattered its own header across five lines, because the hook does
not hand back a plain string and concatenating it produced an array — a capture
nothing can `grep` is not a capture. The fix then introduced a second: `-f` binds
to the first expression alone, so `'{0} {1}' -f (expr), $name` throws *"index
must be less than the size of the argument list"* — **and the `try/catch` that
keeps the recorder from breaking the shell swallowed it silently**, so the hook
simply stopped firing with no sign why. Found by running the body with the catch
removed. A recorder that fails silently is worse than none, which is the same
lesson as `M9`'s `smoke.mjs` trap one file over.

**Two more hypotheses tested the same day, after the recorder shipped.**

**Six: PowerShell's `CommandAnalysis` cache.** A corrupted command-discovery
cache is a documented cause of exactly this symptom — a name on PATH reported
not found. **Dead: the cache directory does not exist on this machine**, so
there is nothing to corrupt.

**Seven: on-access antivirus.** Defender real-time protection is **on with zero
exclusion paths**, so every open of those shims is scanned — which makes a
transient scan-hold the only mechanism still standing. Attacked directly: three
background readers hammering `claude`, `claude.cmd` and `claude.ps1` while the
name was resolved in a loop.

```
bare lookups under contention   6,100     failures: 0
file opens forced               18,300    open failures: 0
```

**Not reproduced.** Combined with the quiet run, that is **~7,700 bare lookups
and 60 fresh processes with no failure**, which is where the cheap experiments
end. It does not clear Defender — an on-access hold under a definition update or
a scheduled scan is a different condition than contention — but it does mean the
hypothesis cannot be provoked on demand either.

**No exclusion was added and none should be.** Excluding the npm directory would
weaken real coverage on a hypothesis nothing has evidenced, and it would be a
workaround rather than a diagnosis — the reflex `M2` retired. The recorder
already discriminates this: a capture showing the files **present** while
`Get-Command -All` is **empty** is the signature of a transient access denial,
and a capture showing them **absent** points at something rewriting them instead.

**And one pattern worth watching.** Both known occurrences were `claude`
specifically — never `wrangler`, `node`, `git` or `npm`, which have the identical
three-shim shape in the same directory. With the 2026-09-01 record that an
*absolute* path to the shim failed too, which only happens if the file is
genuinely gone, the leading unproven hypothesis is that Claude Code's own updater
briefly replaces its shims. The counter-evidence is that those shims still carry
their 2026-08-17 timestamps through an update that ran at 15:37:48. The watchlist
covers the other commands precisely so a recurrence says which it is.

**Adjusted, 2026-09-02 (PR #594).** The recorder had two blind spots. **One of
them would have thrown away the fault in exactly the shape the paragraph above
calls the leading hypothesis.**

**One — a path-shaped invocation was never recorded.** The hook *does* fire for
one; `C:\…\npm\claude.cmd` and `.\claude.cmd` both reach it, measured. But the
watchlist test compared the **whole invoked string** against bare names, so
anything carrying a directory or an extension returned early. `M2`'s session
recorded an **absolute path** to the shim failing, and that is the one piece of
evidence this finding leans on hardest. The recorder built to catch this fault
could not have caught it in its only documented form. It now matches on the leaf
with a known extension stripped, and each capture carries `invoked as` and, for
a path, `literal exists` — which is the difference between *the file was gone*
and *the file was there and discovery refused it*.

**Two — nothing Claude Code launches loads this profile at all.** Its PowerShell
tool runs `powershell.exe -NoProfile -NonInteractive`, one fresh process per
call, parented to `claude`; the hook is `NULL` in every agent shell and the
profile's functions are undefined. Measured, by reading the launching command
line, not inferred from the symptom.

**That one is not fixed, and is not fixable from here.** No userland mechanism
hooks a `-NoProfile` shell — the ones that exist are machine-wide and far more
invasive than an intermittent fault with no established cost justifies. It is
recorded so that no future instrumentation is placed in this profile expecting
to see agent traffic, and because it re-labels a number above: the *60 fresh
PowerShell processes* of the reproduction run were **agent** shells. That is a
fair test of the fault. It was never a test of the recorder.

**Three — the Defender timeline is now carried by each capture** rather than
reconstructed afterwards, which is what had to be done today. It is written in
its own `try/catch` **after** the primary record is already on disk: the
timeline is context, and a slow or failing event-log query must never be able to
cost the capture. That ordering is the silent-catch lesson above, applied
forward rather than learned again.

**Two more hypotheses died, both by measurement and both cheap.**

**Eight: Controlled Folder Access or an ASR rule.** Never checked — only
`ExclusionPath` had been, and it is the wrong knob for a blocked file open.
`EnableControlledFolderAccess` is `0` and there are no ASR rules. Neither
mechanism is armed on this machine.

**Nine: the failure coincided with a Defender event.** It did not. Local time is
UTC−4, so the failure sits between **15:08** (`M4`, PR #584) and **15:46** (this
finding filed, PR #585). The Defender operational log across that window holds
one hourly health report and nothing else; the nearest real events are a
signature update at **09:29**, an aborted scan at **08:07**, and an engine update
at **16:43** — an hour *after* the fact.

**This does not clear Defender**, and the distinction matters: an on-access hold
on a single file logs nothing at all, so absence of events is not absence of
scanning. What died is the specific *"a definition update or a scheduled scan
was running"* version, which was the only form of the hypothesis that could be
tested without new tooling.

**Verification — four cases, against the real file after editing:**

| case | invoked | result |
|---|---|---|
| A | bare `claude`, PATH stripped | captured; `Get-Command -All` empty |
| B | `C:\nope\claude.cmd` | captured; `literal exists: False` **while all three shims list as present** |
| C | `.\pdftotext.exe` | captured; leaf matched through a relative path |
| D | `nates-apps-monorepo`, `C:\nope\definitelynotwatched.cmd` | **not** logged — an ordinary typo still costs nothing |

`B` is the case that did not exist before, and its two lines disagreeing with
each other is the whole point of it.

**Process Monitor was considered and deliberately not installed.** It is the only
instrument that would *explain* this rather than describe it — it would give the
`NTSTATUS` of the failing open — but it is a boot-persistent ring buffer someone
has to maintain, and the filter to write depends on which of three cases this
is: PATH lost the entry, the shims were absent, or discovery failed with both
intact. The recorder answers that in one line. **Buying a daily cost now, for a
filter that cannot yet be written, is the wrong order.**

**Posture unchanged: observation only, records-only, still no workaround.** The
command fails identically, nothing is routed around, and the watchlist is the
same nine names.

**Adjusted, 2026-09-02 (PR #595) — Process Monitor staged, on Nate's
instruction, against the recommendation recorded above.** The note above argued
for holding it until the recorder fires, on the grounds that the filter to write
depends on which of three cases the fault is. **He called it, and one part of
that argument was mine and wrong.**

**The cost estimate was wrong.** "A boot-persistent ring buffer someone has to
maintain" assumed a broad filter. The filter is one rule —
`Path begins with C:\Users\natha\AppData\Roaming\npm` — which captures every
access to the shims by any process, drops everything else, and fits in a plain
backing file at a few MB a day. No ring, no eviction, and **nothing that can
discard the event being waited for**, which a ring buffer can. The remaining
half of the argument still stands: the recorder's one line is what makes the
capture readable, so the two instruments are complements and this is not a
substitute for it.

**Staged at `workshop\tools\procmon\`**, downloaded from
`download.sysinternals.com` and Authenticode-verified — three binaries, all
signed by Microsoft. **Not running, and it starts only by hand from an elevated
shell.** No PATH entry, no service, no scheduled task, no registry outside
Procmon's own key; deleting the directory removes it entirely. It does not
survive a reboot, deliberately — a driver-loading capture that resumes forever is
a larger standing change than this fault has earned, and the posture here is
still observation only.

**The filter is not generated, and that is the considered choice.** Procmon keeps
filters in an undocumented binary blob, in the registry and inside a `.pmc`. It
could be fabricated; a wrong one loads as nothing or as garbage, and **a capture
that quietly filters nothing is indistinguishable from a working one until the
day someone goes to read it.** That is precisely the failure this finding has
already paid for twice — a recorder whose header shattered, and a recorder whose
`try/catch` swallowed its own crash. The one step that cannot be verified
without running the program is therefore done in the program: six clicks, once,
written out in `README.md` beside the scripts.

**The scripts refuse rather than degrade.** `m18-capture-start.ps1` will not run
unelevated and **will not run without the filter file**, so an unfiltered capture
is not reachable by accident. Both refusals were exercised; the parse of all
three scripts was checked against the PowerShell parser rather than assumed.

**The one check that matters is manual**, and it is in the README and in
`SETUP.md`: the backing file's size after a day. A few MB means the filter
loaded; GB means it did not. Nothing can assert that from here, which is why it
is written down in two places rather than automated in neither.

**What it will say when it fires.** `NAME NOT FOUND` means the shims genuinely
were absent and something removes and restores them. `ACCESS DENIED` means they
were present and something refused the open. **`SUCCESS` means the open was fine
and the fault is above the filesystem entirely** — a real answer, and the one no
hypothesis in this finding has proposed.

**Adjusted, 2026-09-02 (PR #596) — the check this note prescribed does not
work, and the setup it described was incomplete.** Both were corrected the same
evening, in `SETUP.md` and the tool's own `README.md`. The text above stands as
written; what follows replaces its verification advice.

**The filter is two settings, not one.** The path rule needs
**Filter → Drop Filtered Events** beside it. Procmon's filter is a *display*
filter: without that second setting every event on the machine still reaches the
backing file and is only hidden from the window — **which looks identical to a
working capture.** The instruction as written would have produced a filtered
window over an unfiltered capture, and nothing in it would have said so.

**And the size check cannot detect that, or anything else.** Procmon
**preallocates**: the backing file is 128 MB within seconds and stays there. *A
few MB* is not a state this file ever occupies, so the threshold reads as
alarming while the capture is healthy and stays silent while it is broken —
wrong in both directions. `m18-capture-health.ps1` reports the **written extent**
instead, which is the number that actually moves.

**What verified it was not a number read off the file.** It was making the
machine produce events the filter was supposed to reject: 1,499 unrelated opens
under `System32` and 150 forced opens of the shims. Twelve of the 1,499 were
sampled and **none reached the capture**; the shim paths did; the written extent
was **71.8 KB**.

**That is three wrong checks on this finding in one day** — a recorder blind to
path-shaped names (#594), a filter priced as needing a ring buffer it does not
need (#595), and now a size threshold that could not see the failure it was
watching for. **All three failed in the same direction: reporting fine while
measuring nothing.** At this point the recurrence is the finding. A check earns
its place by being shown to fail on the condition it claims to detect, and none
of these three ever was.


### M17 — medium — eleven memories name `Downloads` in their own text, and `M7` makes some of them wrong

Noticed while taking `M14`, confirmed while taking `M10`. **`M10` moves the
memory *store*; it says nothing about the *content*.** Eleven of the 64 files
name `C:\Users\natha\Downloads` in their body:

| file | what it says |
|---|---|
| `nates-apps-monorepo` | sessions "are often launched from" it — **and its `description` says so too**, which is the field recall matches on |
| `book-ingest-batch-protocol` | points at `Downloads\BOOK-INGEST-PROMPT.md` as where the prompts live |
| `two-allowlists-downloads-and-repo` | is *named* for `Downloads\.claude\settings.local.json` |
| `ui-audit-menu`, `redesign-audit-menu`, `review-brief-tracks-never-run`, `rust-ash-cleanup-residue` | each says its brief sits in `Downloads` "with the other prompts of its kind" |
| `filament-forge-standardization` | "the full prompt lives at `Downloads\…`" |
| `pantheons-of-the-megaverse-survey` | records which PDF a measurement was read from |
| `media-vault-standardization`, `dev-server-8788-is-another-worktree` | incidental mentions |

**They are not one kind of claim and must not be edited as one.** Some are
**records** — which PDF a number came from is permanently true and rewriting it
destroys the only account of where the number came from. Others are **pointers**
that go false the moment `M7` lands, inside a surface that loads in *every*
session. That second group is the `M2`/`M3` failure exactly: a wrong instruction
in a loading surface, with nothing to contradict it.

**Several of the pointers are redundant rather than merely relocating.**
`docs/prompts/` archives those briefs and `M13` verified all 18 as identical, so
the correct target is the archive — the copy that is version-controlled and
cannot move again — not the new directory.

**Proposal:** after `M7`, read all eleven and correct **only the pointers**,
leaving the records standing. Point brief references at `docs/prompts/` rather
than at any directory on this disk. Fix `nates-apps-monorepo`'s `description` as
well as its body, since the description is what recall reads. Leave the
`[[audit-menu]]` and `[[claim-audit]]` links alone — they name skills, not
memories, and were already like that.

**Posture:** memory maintenance, no repo change beyond this note. **Its own PR,
immediately after `M7`** — the window in which these are wrong should be short,
but folding it into the move would put two decisions in one PR.

**Taken, 2026-09-02 (PR #582)**, in its own PR immediately after `M7`, which is
the posture. Nineteen substitutions across ten files, **each asserted to match
exactly once** before anything was written; the script refused to write until all
nineteen did.

**Two files were deliberately not touched**, which is the half of this finding
that matters:

- `pantheons-of-the-megaverse-survey` records which PDF a measurement came back
  from, on a date. Permanently true.
- `review-brief-tracks-never-run` records a dated rescue-copy of a brief out of a
  temp directory that would have deleted it. An event, not a location.

Rewriting either would destroy the only account of where something came from, to
fix a path nobody will follow. A third file, `nates-apps-monorepo`, still names
the old directory **on purpose** — the correction says which directory it was
until 2026-09-02, because a reader who remembers the old one needs to be told it
changed rather than left to notice.

**Seven pointers now aim at `docs/prompts/` rather than at any directory on this
disk.** That is the version-controlled copy, `M13` verified all 18 identical, and
it cannot move again — so the correction is durable in a way that pointing at the
new working directory would not have been.

`nates-apps-monorepo`'s **`description`** was fixed as well as its body. That
field is what recall matches on, so a body correction alone would have left the
wrong claim in the part that decides whether the file is read at all.

**The old project key was synced to match**, so a session started in `Downloads`
out of habit is not handed a different answer. Whether that store is deleted
stays the separate decision `M10` left it as.

**Found while doing it:** the memory store has **mixed line endings** — some
files CRLF, some LF, and `rust-ash-cleanup-residue` is both at once. It broke two
substitutions that had assumed LF, which is how it was noticed. Not a defect
worth a finding; worth knowing before writing a multi-line match against these
files.

---

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

### M19 — low — the global `CLAUDE.md` lists what the working directory holds, and the list went short the same day

`~/.claude/CLAUDE.md` names the new working directory and then says what it
holds. Two entries created later on 2026-09-02 are not in that list:
`profile.ps1`, which `M4` created, and `tools\`, which holds the Process Monitor
capture staged for `M18`.

**The file predicts this in its own text** — it says that nothing but a hand
updates it, that no test and no grep of the repo reaches it, and that it must be
edited when the directory changes. It was right, and the prediction came true
within hours, in the direction nobody watches: not the *location* changing, which
is what the sentence anticipates, but the *contents* growing underneath a list
that reads as complete.

The machine-audit memory has the fuller list, including `profile.ps1`, so the two
records of the same directory already disagree.

**Proposal:** stop enumerating. Replace the contents list with what the directory
is *for* — the working directory the book work runs from, holding the sourcebook
PDFs, the loose briefs and its own `.claude\`. A reader who needs the current
contents can list the directory; a list in prose that nothing checks will go short
again the next time anything is added, and this is the second record of it to
disagree already.

**Posture:** documentation only, in a file outside the repo. One sentence
rewritten, no behaviour, no move, and **no check** — the file's whole argument is
that nothing mechanical reaches it, and adding a check that reads it from inside
the repo would contradict `SKILL-AUDIT.md` F11, which is why this file exists.

**Decline it** if you would rather the list stay literal and be corrected by hand;
that is a real position, and the file already tells its reader that a hand is the
only thing maintaining it.

### M20 — low — the old memory store's `memory\` directory survives as an empty husk

`M10` moved the memory store and recorded the old one as removed. What is on disk
under the old key is a `memory\` directory containing **nothing** — sixty-five
files live under the new key, zero under the old, and the empty directory remains
alongside the session transcripts, which were correctly left in place.

The consequence is quiet rather than harmful: a session started in the old
directory finds the store, finds it empty, and loads no memories at all. There is
no error, because an empty memory store is indistinguishable from a new one. **A
session in this state was the one that ran this audit**, which is how the husk was
noticed — the working directory has moved, so nothing routine will start there
again.

**Proposal:** delete the empty `memory\` directory under the old key, leaving the
transcripts untouched, so that a session opened there in future reports no store
rather than an empty one.

**Posture:** delete one empty directory. **Do not touch the `.jsonl` transcripts
beside it** — they are the record this machine's audits have been reconstructed
from, `M10` deliberately left them, and they are not what this finding is about.

**Decline it** if an empty directory is not worth a PR; the practical effect is
limited to sessions started in a directory nothing starts in any more. `M15`
declined a comparable cosmetic duplicate — the old `Downloads` key in
`~/.claude.json`, which it checked and found harmless — and the same reasoning
covers this one.
