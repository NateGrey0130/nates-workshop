---
name: windows-shell
description: The shell traps on this Windows machine that corrupt a file, a command or a commit without failing. Use before any in-place edit of repo source, before writing an inline script with backslashes or Windows paths, when a dev-server port will not free, when a commit message contains backticks, when chaining a command on another command's success, and when a wrangler query returns something that looks wrong. Covers line endings, encoding, the Bash tool's own unescaping, killing wrangler properly, the pipe that discards the exit code you were testing, and the PowerShell quoting that has produced wrong data.
---

# Shell traps on this machine

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`). The incident behind each rule
> is in `reference/why.md`.

Every one of these **succeeds**: nothing exits non-zero, nothing warns, and in
three cases the obvious check reports clean.

## Six of these are a hook now, and it fires everywhere on this machine

`.claude/hooks/guard-bash.sh` runs before every `Bash` call and exits 2 (a
block) on six shapes:

- `git add -A`, `git add --all`, `git add .` (see *Commit messages*)
- `sed -i` on a path under the repo (see *Editing a file in place*)
- `scripts/q.mjs` or `scripts/d1-apply.mjs` with neither `--local` nor `--remote`
- `gh pr merge` on a line with a chaining operator or a pipe
- `git commit -m` with a backtick in it
- `find` rooted at a drive or filesystem root, at a command position

- **A refusal reads** `PreToolUse:Bash hook error: [<registered command>]: guard-bash: <reason>`.
  To count refusals, grep for `PreToolUse:Bash hook error`, never a leading
  `guard-bash:` (zero by construction) or the bare string (matches quotes of it).
- **A refusal is not a permission denial.** A denial waits for Nate to approve
  your command; a refusal tells you to write a different one.
- **It is registered twice, on purpose:** in the repo's `.claude/settings.json`
  and at user level in `C:\Users\natha\.claude\settings.json`, so it guards
  every directory. Each copy guards only the tree it lives in, so in a git
  worktree only the repo's registration guards the worktree. A doubled refusal
  is expected. **Do not remove either** (`SKILL-AUDIT` `F60`).
- **It fails closed** on an envelope it cannot parse. A wrong path in a
  registration fails as `sh` exit 127, which is reported, not blocking;
  `hook-registration.mjs` is the local check for that.
- **The hook covers six shapes, not the traps.** Everything below still applies.

**Line endings: read `.gitattributes`; do not summarise it.** The repo is CRLF
except what it pins: `*.sql`, `.github/workflows/*.yml` and `.claude/hooks/*.sh`
are LF, and the vendored FilamentForge libraries and woff2 fonts are `-text`.

## Editing a file in place

- **`sed -i` rewrites the whole file as LF**, so one substitution turns a CRLF
  file into every line modified, and can fail unrelated byte-compare tests.
  Use the **Edit tool**, or node with an explicit encoding.
- **`grep -c $'\r$' file` lies**: it returns the total line count for every
  file, CRLF or not. Count endings with node:

  ```bash
  node -e "const s=require('fs').readFileSync(p,'latin1');const lf=(s.match(/\n/g)||[]).length,crlf=(s.match(/\r\n/g)||[]).length;console.log(crlf,lf-crlf)"
  ```

  `git diff --numstat` showing the whole file changed is the other tell. To
  repair: `s.replace(/\r\n/g,'\n').replace(/\n/g,'\r\n')`.
- **`latin1` preserves CRLF and silently truncates anything you add above
  U+00FF**: an em-dash becomes the invisible control byte U+0014. **Use
  `'utf8'` whenever the replacement contains non-ASCII**; it round-trips CRLF
  too. Afterwards scan for `/[\x00-\x08\x0B\x0C\x0E-\x1F]/`.

## The Bash tool unescapes before bash sees it

**`\\` becomes `\` one round before execution**, and a quoted heredoc
(`<<'EOF'`) does not protect against it. `\n`, `\t` and a lone `\` pass through.

| you wrote | bash received | result |
|---|---|---|
| `f.replace('\\','/')` | `f.replace('\','/')` | unterminated string |
| `"console.log('\\n')"` | `'\n'` | a REAL newline written into generated `.js` |
| `'C:\\Users\\natha'` | `'C:\Users\natha'` | Python reads `\U` as a truncated escape |

`\U` and `\N` hard-error; everything else corrupts silently, and the traceback
shows the collapsed text. **Write the script to the scratchpad with the Write
tool and run it by path.** In Python build a backslash with `chr(92)`. Keep
Windows paths out of inline heredocs.

## A pipe throws away the exit code you were testing

A pipeline exits with its **last** command's status, and `pipefail` is off:

```bash
false | tail -1 ; echo $?              # 0
( set -o pipefail; false | tail -1 ) ; echo $?   # 1
```

So `gh pr checks <n> | tail -2 && gh pr merge <n>` **merges on a red build**
(it has). The hook refuses that exact line, but `gh pr checks | tail` alone is
still a pipeline with its exit code gone. `| head`, `| tail`, `| grep`, `| jq`
are all the trap; `grep` is worst, having an exit code of its own. Fixes, in
order of preference:

```bash
OUT=$(gh pr checks 670 2>&1); RC=$?; echo "$OUT" | tail -3   # capture first, display after
set -o pipefail                                              # per-command-block, not persisted
gh run watch <id> --exit-status                              # let the tool carry the status
```

Run `gh pr merge` as a command on its own.

## Killing a dev server

**`taskkill` on the LISTENING process kills a `workerd` child, not the server.**
The node parent respawns it, the port never frees, and each new
`wrangler pages dev` stacks another instance. **`curl.exe` returning `HTTP 000`
against a port that IS listening is the tell.**

**Other wranglers may be running, and a blanket kill takes them too.**
`regression.mjs` and `play-flow.mjs` boot their own on OS-assigned ports, and
8788 may be another worktree's server. So list first, from PowerShell:

```powershell
Get-CimInstance Win32_Process -Filter "Name='node.exe' OR Name='workerd.exe'" |
  Select-Object ProcessId, ParentProcessId, Name, CommandLine
```

Stop **only** the `node` whose command line runs `wrangler pages dev` on your
port, and the `workerd` processes under it (follow `ParentProcessId`). Then
confirm the port is empty. The blanket form, when you are sure nothing else is
running:

```powershell
Get-Process workerd -ErrorAction SilentlyContinue | Stop-Process -Force
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -like '*wrangler*pages*dev*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

Kill headless Chrome by its `--user-data-dir` in the command line, never
`taskkill /IM chrome.exe`, which takes Nate's real browser.

**A running server holds the secrets it booted with.** `wrangler pages dev`
reads `.dev.vars` at boot, so after a key rotation or a top-up the live server
still sends the old key. **The tell is speed: a failure returning in 0s is
local.** Restart the server and retry one small request. Production reads its
own copy as a Pages secret (`ship-pr`).

## PowerShell, and queries that return wrong data

- **`\"` escapes nothing in PowerShell.** The string ends early and the rest
  word-splits. Build a double quote in SQL with `char(34)`, as `char(8212)` for
  an em-dash.
- **`--file` over `--remote` returns a summary, not rows.** Use `--command`
  for anything whose rows you need.
- **Read results from a file, not the terminal**: `--json | Out-File -Encoding
  utf8 out.json`, then read the file. Transcribing a slug off the screen has put
  a wrong one (`ng-15-` for `ng-l5-`) a keystroke from a class definition.

## Commit messages

**Backticks in a `-m` string are evaluated by the shell** (one ran `wrangler`
and pasted its help into a commit). Write the message to a file named `.tmp`
and commit with `-F`:

```bash
git commit -F commit-msg.tmp
```

`*.tmp` is gitignored, so it cannot be swept into the commit. A scratch file
under any other extension is not covered; `git ls-tree -r HEAD --name-only`
shows what landed.

## Nate's shell is not your shell

**Your Bash is Git Bash; his is Windows PowerShell 5.1.** Git Bash prepends
`/mingw64/bin`, `/usr/local/bin` and `/usr/bin`; his new window gets the
Machine and User PATH only. So a command can exist for you and not for him, or
be a **different program**:

| you type | you get | he gets |
|---|---|---|
| `git` | `/mingw64/bin/git` | `C:\Program Files\Git\cmd\git.exe` |
| `sed` `awk` `file` `tr` `grep` | `/usr/bin/…` | **nothing** |
| `find` | GNU `find` | `C:\WINDOWS\system32\find.exe`, not GNU |
| `diff` `curl` | the Unix tools | PowerShell aliases for `Compare-Object` and `Invoke-WebRequest` |

**In PowerShell write `curl.exe`**, and leave the aliases alone. The aliases to
fear succeed with a wrong answer:

| you write | you get | what it does |
|---|---|---|
| `diff a b` | `Compare-Object` | compares the path *strings*; two identical files "differ", `$?` is `True` |
| `sort f` | `Sort-Object` | reads no file, prints nothing, succeeds |
| `curl` `wget` | `Invoke-WebRequest` | not Unix curl's syntax |
| `ls` `cat` `rm` `cp` `mv` `ps` `kill` `echo` `pwd` `tee` `sleep` `man` | the cmdlet | fine bare; error on Unix flags |

**Ask what his PATH is; do not model it:**

```powershell
([Environment]::GetEnvironmentVariable('PATH','Machine') + ';' +
 [Environment]::GetEnvironmentVariable('PATH','User')) -split ';'
```

- A PATH change reaches only a **new** window. An already-open one is frozen;
  that is the only stale environment here.
- **No workaround by absolute paths.** Handing him full paths hides a real
  PATH gap; the repair is a PATH entry or a different command name.
- To observe his environment rather than model it, have `explorer.exe` launch
  the probe.

### `--remote` from your shell

`drift-check --remote`, `deploy-sweep` and `q.mjs --remote` run fine from the
agent's Bash (re-measured). **Run them; do not hand them to Nate by default.**
If one hangs, **capture before retrying**: the command, how long it ran,
whether output appeared, and `Get-Process node,workerd` while it is stuck
(`MACHINE-AUDIT.md` `M21`).
