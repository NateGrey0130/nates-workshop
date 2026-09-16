#!/bin/sh
# guard-bash.sh - PreToolUse hook on the Bash tool.
#
# Claude Code hands this script the pending tool call as JSON on stdin. It
# exits 2 with a one-line reason on stderr when the command contains a shape
# that has corrupted a commit, a file, a merge or production here before, and
# exits 0 otherwise. Exit 2 is the only code Claude Code treats as a block;
# any other non-zero is reported and the command runs anyway.
#
# Every rule below used to be a "never" sentence in prose. Prose does not fire
# by itself; this does. The shapes:
#
#   1. git add -A / git add --all / git add .   - in a shared checkout it has
#      committed another session's work under this session's message (#1000-era,
#      2026-09-13) and once swept a commit-message scratch file into PR #404.
#   2. sed -i on a path under the repo          - Git Bash sed rewrites the whole
#      file as LF, so one substitution lands as every line changed, and the
#      obvious grep check reports the file clean anyway.
#   3. node .../q.mjs or .../d1-apply.mjs with neither --local nor --remote
#      - the flagless call used to read (q.mjs) or refuse (d1-apply.mjs)
#      PRODUCTION, and a "local readback" that silently read production hid an
#      unapplied change on 2026-09-11.
#   4. gh pr merge on a line with && ; || or |  - a merge chained onto a check
#      read merged PR #1094 while regression was still running, 2026-09-16, and
#      PR #668 merged on a red build through `gh pr checks | tail && gh pr merge`.
#   5. git commit -m with a backtick in the command - the shell evaluates the
#      backticks; one commit message here ran `wrangler d1 execute` and pasted
#      its help text into the commit. Write the message to a .tmp file and -F it.
#
# POSIX sh throughout. The one non-sh dependency is node, used only to parse
# the JSON envelope, because this machine has no jq and every tool in this repo
# already needs node. If the envelope cannot be parsed the hook FAILS CLOSED
# (exit 2) so the gap is noticed on the first command rather than never.
#
# Windows: the file must be LF. `.gitattributes` pins `.claude/hooks/*.sh` to
# eol=lf; a CR on the shebang line fails as `/bin/sh^M: bad interpreter`.

set -u

refuse() {
  printf 'guard-bash: %s\n' "$1" >&2
  exit 2
}

# --- 0. pull the command out of the hook envelope ---------------------------
cmd=$(node -e '
let s = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", d => { s += d; });
process.stdin.on("end", () => {
  let j;
  try { j = JSON.parse(s); } catch (e) { process.exit(3); }
  const ti = j && j.tool_input;
  const c = ti && typeof ti.command === "string" ? ti.command : "";
  process.stdout.write(c);
});
' 2>/dev/null)
rc=$?
[ "$rc" -eq 0 ] || refuse "could not parse the hook input (node exit $rc); refusing rather than running unguarded"
[ -n "$cmd" ] || exit 0

# --- helpers -----------------------------------------------------------------
# has PATTERN  : extended-regex match against the whole command
has() { printf '%s\n' "$cmd" | grep -Eq -- "$1"; }

# lines : the command split into shell "lines" - newlines, && and || all start
# a new one, so a chained merge is caught whether it is joined with a newline
# or an operator. `;` is deliberately NOT a splitter here because it is common
# inside SQL strings; rule 4 checks for it directly on the merge line.
lines() { printf '%s\n' "$cmd" | sed 's/&&/\n/g; s/||/\n/g'; }

# --- 1. git add -A / --all / . ----------------------------------------------
if has '(^|[^[:alnum:]_./-])git[[:space:]]+add([[:space:]]+[^[:space:]]+)*[[:space:]]+(-A|--all|-[a-zA-Z]*A[a-zA-Z]*|\.)([[:space:]]|$)'; then
  refuse "git add -A / git add . stages another session's edits and scratch files; name the paths: git add <paths>"
fi

# --- 2. sed -i on a path under the repo ---------------------------------------
# Any in-place form: -i, -i.bak, --in-place[=SUF], and combined short flags that
# contain i (-ni, -Ei, -ie). A target is a non-option token that is not the sed
# script. Relative targets resolve against the cwd, which is this repo. Absolute
# targets are checked against the project directory in both path spellings.
if has '(^|[^[:alnum:]_./-])sed[[:space:]]+([^[:space:]]+[[:space:]]+)*(-[a-zA-Z]*i[a-zA-Z.]*|--in-place[^[:space:]]*)([[:space:]]|$)'; then
  proj_posix=$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && pwd)
  proj_win=$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && pwd -W 2>/dev/null || printf '%s' "$proj_posix")
  in_repo=0
  # Walk the tokens after the first `sed`. Crude tokenisation on whitespace is
  # enough: a quoted sed script with spaces produces extra "targets" that are
  # not paths, and a non-path relative token counts as in-repo, which errs on
  # the side of refusing.
  toks=$(printf '%s\n' "$cmd" | sed 's/.*[^[:alnum:]_./-]sed[[:space:]]//; s/^sed[[:space:]]//')
  saw_script=0; expect_script=0
  for t in $toks; do
    if [ "$expect_script" -eq 1 ]; then expect_script=0; saw_script=1; continue; fi
    case "$t" in
      -e|--expression|-f|--file) expect_script=1; continue ;;
      --expression=*|--file=*) saw_script=1; continue ;;
      -*) continue ;;
    esac
    if [ "$saw_script" -eq 0 ]; then saw_script=1; continue; fi
    case "$t" in
      /*|[A-Za-z]:*|\\*)
        # absolute: in repo only if it starts with the project dir
        case "$t" in
          "$proj_posix"*|"$proj_win"*) in_repo=1 ;;
          "${proj_win}"*) in_repo=1 ;;
        esac
        # also the forward-slash spelling of the Windows path
        pw=$(printf '%s' "$proj_win" | sed 's#\\#/#g')
        case "$t" in "$pw"*) in_repo=1 ;; esac
        ;;
      \$*|\"*|\'*) ;;   # a variable or a quoted script: cannot tell, do not count
      *) in_repo=1 ;;   # relative: resolves against the repo
    esac
  done
  if [ "$in_repo" -eq 1 ]; then
    refuse "sed -i rewrites a CRLF file as LF and the diff shows every line; use the Edit tool or node with an explicit encoding"
  fi
fi

# --- 3. q.mjs / d1-apply.mjs with no target flag ------------------------------
lines | while IFS= read -r line; do
  if printf '%s\n' "$line" | grep -Eq 'node[[:space:]]+([^[:space:]]*/)?(q|d1-apply)\.mjs([[:space:]]|$)'; then
    if ! printf '%s\n' "$line" | grep -Eq -- '--(local|remote)([[:space:]]|$|=)'; then
      printf 'guard-bash: %s\n' "q.mjs / d1-apply.mjs need --local or --remote on the same line; a flagless call used to mean PRODUCTION" >&2
      exit 2
    fi
  fi
done
rc=$?
[ "$rc" -eq 0 ] || exit "$rc"

# --- 4. gh pr merge chained onto anything -------------------------------------
# The merge must be the whole tool call: nothing else on its line (&& ; || |)
# and no other line in the same call. A newline is a chain too - the check read
# and the merge in one Bash call cannot gate on the read's output either way.
if has 'gh[[:space:]]+pr[[:space:]]+merge'; then
  if has 'gh[[:space:]]+pr[[:space:]]+merge.*(&&|;|\|)|(&&|;|\|).*gh[[:space:]]+pr[[:space:]]+merge'; then
    refuse "gh pr merge must be its own command: a merge chained onto a check read merged #1094 before regression finished"
  fi
  nonblank=$(printf '%s\n' "$cmd" | grep -Ec '[^[:space:]]')
  if [ "$nonblank" -gt 1 ]; then
    refuse "gh pr merge must be the only line in the call: read the checks in one command, merge in the next"
  fi
fi

# --- 5. git commit -m with a backtick ----------------------------------------
if has '(^|[^[:alnum:]_./-])git[[:space:]]+commit([[:space:]]+[^[:space:]]+)*[[:space:]]+(-[a-zA-Z]*m|--message)' && has '`'; then
  refuse "a backtick in git commit -m is evaluated by the shell; write the message to commit-msg.tmp and use -F"
fi

exit 0
