---
name: windows-shell
description: The shell traps on this Windows machine that corrupt a file, a command or a commit without failing. Use before any in-place edit of repo source, before writing an inline script with backslashes or Windows paths, when a dev-server port will not free, when a commit message contains backticks, and when a wrangler query returns something that looks wrong. Covers line endings, encoding, the Bash tool's own unescaping, killing wrangler properly, and the PowerShell quoting that has produced wrong data.
---

# Shell traps on this machine

Every one of these **succeeds**. Nothing exits non-zero, nothing warns, and in
three cases the obvious check reports clean. They are collected here because
each cost a session or reached production.

The repo is CRLF everywhere except `*.sql`, which `.gitattributes` pins to LF
*because a CRLF checkout once changed the bytes that reached the database*.

## Editing a file in place

**`sed -i` rewrites the whole file as LF.** One small substitution flips every
line in a CRLF file, and the change lands in the PR as every line modified.

**The natural check for it lies.** `grep -c $'\r$' file` returns a count equal to
the file's total line count for *every* file, CRLF or not — a degenerate match
that reads as "all clean". It reported one file as 272/272 CRLF while the file
was pure LF.

It also produces false test results: a `sed -i` on `app.js` made four unrelated
byte-for-byte comparison checks fail, which looked exactly like the break being
tested for.

Use the **Edit tool**, or node with an explicit encoding. Count endings with
node, never with grep:

```bash
node -e "const s=require('fs').readFileSync(p,'latin1');const lf=(s.match(/\n/g)||[]).length,crlf=(s.match(/\r\n/g)||[]).length;console.log(crlf,lf-crlf)"
```

`git diff --numstat` is the other tell — a line-ending flip shows the whole file
changed. To repair one: `s.replace(/\r\n/g,'\n').replace(/\n/g,'\r\n')`.

**`latin1` preserves CRLF exactly, and silently truncates anything new.** It is
the right round-trip for bytes already in the file. But any string *you supply*
with a character above U+00FF is cut to its low byte: an em-dash (U+2014) lands
as U+0014, a control character that renders as nothing and is invisible in a
diff. This repo's prose is full of em-dashes and curly quotes, so almost any
inserted sentence hits it — it produced a DC4 byte inside an audit header.

**Use `'utf8'` whenever the replacement text contains non-ASCII.** It round-trips
CRLF just as well; reach for `latin1` only when the goal is byte preservation of
content you are not reading. Afterwards, scan for
`/[\x00-\x08\x0B\x0C\x0E-\x1F]/`.

## The Bash tool unescapes before bash sees it

**`\\` becomes `\` one round before execution**, and a quoted heredoc
(`<<'EOF'`) cannot protect against it, because the substitution happens
upstream. `\n`, `\t` and a lone `\` pass through unchanged.

| you wrote | bash received | result |
|---|---|---|
| `f.replace('\\','/')` | `f.replace('\','/')` | unterminated string |
| `"console.log('\\n')"` | `'\n'` | Python wrote a REAL newline into the generated `.js` |
| `'C:\\Users\\natha'` | `'C:\Users\natha'` | Python read `\U` as a truncated escape |

`\U` and `\N` hard-error. **Everything else corrupts silently.** And the
traceback shows the already-collapsed text, so it reads as a mistake in the
source rather than a transport problem — which invites re-escaping, which
collapses again.

**Write the script to the scratchpad with the Write tool and run it by path.**
Write content is not unescaped. Inside Python, build a backslash with `chr(92)`.
Keep Windows paths out of inline heredocs.

## Killing a dev server

**`taskkill` on whatever is LISTENING kills a `workerd` child, not the server.**
The parent node process respawns it, the port never frees, and each new
`wrangler pages dev` stacks another instance. It looks like it worked: the kill
reports success and the PID is gone.

Fifteen dev servers accumulated in one session before the port began returning
`HTTP 000` and a test run failed for reasons unrelated to the code. **A
`curl.exe` returning `HTTP 000` against a port that IS listening is the tell** —
`.exe`, because in PowerShell a bare `curl` is `Invoke-WebRequest` and never
prints a bare status code at all.

Stop both halves, from PowerShell:

```powershell
Get-Process workerd -ErrorAction SilentlyContinue | Stop-Process -Force
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -like '*wrangler*pages*dev*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

Then confirm the port is empty before starting a new one. The same
kill-by-command-line rule applies to headless Chrome: match its
`--user-data-dir`, never the image name, or a blanket `taskkill /IM chrome.exe`
takes Nate's real browser with it.

## PowerShell, and queries that return wrong data

- **`\"` does not escape anything.** The string ends early and the rest
  word-splits into arguments wrangler rejects. Class markdown cites gear as
  `item_id: "slug"`, so the queries most worth running are the ones that break.
  Build the quote in SQL instead: `char(34)`. Same trick as `char(8212)` for an
  em-dash.
- **`--file` returns a summary over `--remote`, not results.** A `SELECT` sent
  with `--file` comes back as *Total queries executed / Rows read*, so every
  count reads as 1 and a drift check built on it reports everything missing. Use
  `--command` for anything whose rows you need.
- **Read results from a file, not the terminal.** `--json | Out-File -Encoding
  utf8 out.json`, then read `out.json`. Transcribing from terminal output put
  `ng-15-northern-gun-laser-rifle` a keystroke away from being written into a
  class definition; the real slug is `ng-l5-`.

## Commit messages

**Backticks in a `-m` string are evaluated by the shell.** A commit message here
once ran `wrangler d1 execute` and pasted its help output into the commit.
Backticks are natural in this repo's prose, so this is not hypothetical.

```bash
git commit -F commit-msg.tmp
```

**Do not `git add -A` immediately before `--amend`** — it sweeps the message file
into the commit. If it happens: delete the file, then
`git add -A && git commit --amend --no-edit`, and confirm with
`git ls-tree -r HEAD --name-only`.

## Nate's shell is not your shell

**Your Bash is Git Bash. His is Windows PowerShell 5.1.** That is the whole
difference, and it is permanent rather than broken. Git Bash prepends its own
toolchain — `/mingw64/bin`, `/usr/local/bin`, `/usr/bin` — ahead of everything
Windows persists. A freshly-opened PowerShell gets the Machine PATH and the User
PATH concatenated, and nothing else.

So a command can exist for you and not for him, or exist for both and **be a
different program**. Measured 2026-09-02, in a shell whose PATH was rebuilt from
the persisted values alone:

| you type | you get | he gets |
|---|---|---|
| `git` | `/mingw64/bin/git` | `C:\Program Files\Git\cmd\git.exe` |
| `sed` `awk` `file` `tr` `grep` | `/usr/bin/…` | **nothing** |
| `find` | `/usr/bin/find`, GNU | `C:\WINDOWS\system32\find.exe`, not GNU |
| `diff` `curl` | `/usr/bin/diff`, `/mingw64/bin/curl` | PowerShell **aliases** for `Compare-Object` and `Invoke-WebRequest` |

The bottom two rows are the dangerous ones: nothing fails, and the wrong program
answers.

### In PowerShell, write `curl.exe`

**Sixteen Unix names are aliases there** — measured 2026-09-02, not a
representative sample. Appending `.exe` reaches the real binary, and
`C:\WINDOWS\system32\curl.exe` wins over the Git one in both PowerShell and
`cmd`. **Leave the aliases alone**; they are defaults other things rely on. What
matters is which ones take a Unix argument and quietly do something else with it:

| you write | you get | what it does |
|---|---|---|
| `diff a b` | `Compare-Object` | compares the two *path strings*. On two **identical** files it reports both as differing, and `$?` is `True` |
| `sort f` | `Sort-Object` | reads no file. Prints **nothing**, succeeds |
| `curl` `wget` | `Invoke-WebRequest` | `-s -o -w '%{http_code}'` is not its syntax |
| `ls` `cat` `rm` `cp` `mv` `ps` `kill` `echo` `pwd` `tee` `sleep` `man` | the obvious cmdlet | fine bare; error on `-la`, `-n`, `-rf` |

The first two are the ones to fear. Everything else either works or fails
loudly; `diff` **inverts** its answer and `sort` **erases** its answer, and both
report success. A check built on either is worse than no check.

**Ask what his PATH is; do not model it.** One line prints what a new window of
his will resolve against:

```powershell
([Environment]::GetEnvironmentVariable('PATH','Machine') + ';' +
 [Environment]::GetEnvironmentVariable('PATH','User')) -split ';'
```

**Two things that are not the mechanism**, both believed here on 2026-09-01 and
neither surviving a check a day later:

- **An inherited environment block is not going stale.** Tested by trying to
  make it: a fresh value was written to `HKCU\Environment` with **no**
  `WM_SETTINGCHANGE` broadcast at all, and a process launched by an
  `explorer.exe` that had been running six days saw it immediately. Explorer
  picks up registry changes here on its own. The one environment that really is
  frozen is **a window that is already open** — a process's block is fixed when
  it starts and nothing updates it afterwards. That is a reason to open a new
  window, never a reason to work around anything.
- **PATH was not what failed.** That session's own record shows an *absolute*
  path to the npm shim failing as well. PATH cannot make an absolute path fail,
  so resolution was never the fault — and `%APPDATA%\npm` is on his PATH, where
  `wrangler` resolves for him today.

To observe his environment rather than model it, have `explorer.exe` launch the
probe so the probe inherits the block in question. A shell you rebuild yourself
answers a question about your reconstruction.

**There is no workaround here, and absolute paths are not one.** Writing full
paths into everything you hand him hides the asymmetry rather than showing it,
and then every command that would have exposed a real gap has been
pre-worked-around. That is how `pdftotext` stayed off his PATH for as long as it
did while every agent session ran it without noticing. When something you hand
him fails, the table above says why at a glance, and the repair is a PATH entry
or a different command name — never a longer string.

**A PATH change does not reach an already-open terminal.** New window, or a
correct fix reads as broken.

### `--remote` from your shell: measured, not assumed

Hand-off briefs have carried a caution that `drift-check --remote`,
`deploy-sweep` and a one-row `q.mjs --remote` all **hang past 500s** from the
agent's Bash tool, and to hand them to Nate instead. Re-measured **2026-09-03**
from that shell, all three ran clean — `drift-check` five times at ~4 min each,
`deploy-sweep` in **17s**, `q.mjs` in **8s**, plus six other `--remote` D1 calls.
The `deploy-sweep` output was byte-identical to the same command in his shell
minutes earlier.

**That is not a promise, and one clean day does not disprove an intermittent
fault.** What it does mean is that **deferring these commands is a cost, not a
default** — a session that hands all three over is paying for a fault nobody has
reproduced. Run them; if one hangs, that is new information.

**If it hangs, capture it before retrying** — the same instruction `M18` gives,
for the same reason. The command, how long it ran, whether any output appeared,
and `Get-Process node,workerd` while it is still stuck. Anything gathered after a
retry describes a machine that already recovered. `MACHINE-AUDIT.md` `M21` holds
the measurements and the two citations that sent readers to the wrong findings.
