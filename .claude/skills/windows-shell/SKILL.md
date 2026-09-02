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
`HTTP 000` and a test run failed for reasons unrelated to the code. **A curl
returning `HTTP 000` against a port that IS listening is the tell.**

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

His interactive PowerShell does not see `%APPDATA%\npm`, though the persisted
user PATH contains it and the directory exists — his sessions inherit a stale
environment block from a long-lived `explorer.exe`. **Call binaries by absolute
path in anything you hand him to run.** Investigated 2026-09-01 and left
unresolved at his call; the config is fine, the inheritance is not.
