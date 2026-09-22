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

# --- 0. pull the command AND the cwd out of the hook envelope ----------------
# The envelope carries `cwd` as a required field - it is in the CLI's own schema
# for every hook input - and rule 2 needs it: a relative path resolves against
# the Bash tool's working directory, which is not necessarily this repo and, as
# of SKILL-AUDIT F55, not necessarily even the directory the session started in.
# The cwd comes back first because the command may itself contain newlines.
envelope=$(node -e '
// stripData: drop the BODY of a data heredoc before the rules read the text.
// SKILL-AUDIT F57 - the first command this hook ever blocked in real work was
// a commit message whose prose quoted an in-place edit. The rules match the
// whole command, which is right for a command and wrong for a message.
//
// A body fed to an INTERPRETER is kept, because it executes: `python - <<PY`
// and `sh <<EOF` are the commonest heredoc shapes in this corpus and there is
// no later `sh script.sh` for the hook to catch instead.
//
// It fails CLOSED in every direction it cannot read: an opener with no
// terminator returns the text untouched, a `<<<` here-string is not an opener,
// and anything thrown here returns the text untouched rather than blinding the
// rules. No single quotes anywhere below - this whole program is inside a
// single-quoted shell string.
const EXECUTES = /\b(?:sh|bash|zsh|ksh|dash|python[0-9.]*|node|deno|perl|ruby|php)\b[^<]*<</;
const OPENER = /<<(?:-?)[ \t]*(?:([\x22\x27])([A-Za-z_][A-Za-z0-9_]*)\1|\\([A-Za-z_][A-Za-z0-9_]*)|([A-Za-z_][A-Za-z0-9_]*))/g;
function stripData(src) {
  try {
    const out = [];
    let term = null, keep = false;
    for (const line of src.split("\n")) {
      if (term === null) {
        out.push(line);
        OPENER.lastIndex = 0;
        let m, first = null;
        while ((m = OPENER.exec(line)) !== null) {
          if (m.index > 0 && line[m.index - 1] === "<") continue;  // <<< here-string
          first = m[2] || m[3] || m[4];
          break;                                                   // shell reads bodies in order
        }
        if (first) { term = first; keep = EXECUTES.test(line); }
      } else if (line.trim() === term) {
        term = null; out.push(line);
      } else if (keep) {
        out.push(line);
      }
    }
    if (term !== null) return src;   // no terminator: keep everything
    return out.join("\n");
  } catch (e) { return src; }
}

let s = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", d => { s += d; });
process.stdin.on("end", () => {
  let j;
  try { j = JSON.parse(s); } catch (e) { process.exit(3); }
  const ti = j && j.tool_input;
  const c = ti && typeof ti.command === "string" ? ti.command : "";
  const w = j && typeof j.cwd === "string" ? j.cwd : "";
  process.stdout.write(w + "\n---guard-bash-envelope---\n" + stripData(c));
});
' 2>/dev/null)
rc=$?
[ "$rc" -eq 0 ] || refuse "could not parse the hook input (node exit $rc); refusing rather than running unguarded"
env_cwd=$(printf '%s' "$envelope" | sed -n '1p' | sed 's#\\#/#g')
cmd=$(printf '%s' "$envelope" | sed '1,2d')
[ -n "$cmd" ] || exit 0

# --- helpers -----------------------------------------------------------------
# has PATTERN  : extended-regex match against the whole command
has() { printf '%s\n' "$cmd" | grep -Eq -- "$1"; }

# repo_posix / repo_win : where the repo IS, derived from this script's own
# location rather than from CLAUDE_PROJECT_DIR. Since SKILL-AUDIT F55 this hook
# is registered from settings that are not the repo's, so CLAUDE_PROJECT_DIR is
# the directory the SESSION started in - Downloads, usually - and rule 2 used it
# as "the repo". $0 is the path sh was invoked with, and that registration
# spells it absolutely, so this is not circular. It WOULD be circular against a
# registration written as "$CLAUDE_PROJECT_DIR/.claude/hooks/guard-bash.sh",
# because the shell expands that before sh ever sees it.
hook_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
repo_posix=$(cd "$hook_dir/../.." 2>/dev/null && pwd)
repo_win=$(cd "$hook_dir/../.." 2>/dev/null && pwd -W 2>/dev/null || printf '%s' "$repo_posix")

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
# script. A relative target resolves against the Bash tool's own cwd, which the
# envelope gives us, and is in the repo only if that resolves into it. Absolute
# targets are checked against the repo in both path spellings. Until F55 both
# used CLAUDE_PROJECT_DIR, which was right only while the hook was registered
# from the repo - it missed real absolute repo paths from anywhere else, and it
# refused EVERY relative `sed -i` on the machine.
#
# FOUR things changed here when SKILL-AUDIT F58 was taken, 2026-09-22. The
# finding named two defects; measuring it turned up two more.
#
#   a. The in-place flag is found among SED'S OWN OPTIONS, inside the walk,
#      instead of by a regex over the whole command. The old regex let any later
#      token's `-i` stand in for sed's, because `([^[:space:]]+[[:space:]]+)*`
#      was unbounded and walked from `sed` to whatever came next:
#      `sed -n '1,5p' F.md && grep -i x y` was REFUSED, and `sed -n` is not an
#      in-place edit. Options precede the script, so a flag found before the
#      script cannot belong to another command. This is why the bug cannot
#      come back rather than merely being patched.
#   b. `sed` must sit at a COMMAND POSITION in its segment, or behind one of the
#      two introducers this corpus uses - `xargs` and `find -exec`. Prose naming
#      the shape no longer trips it, which is the guard F54 gave rule 6 and the
#      reason it gave. A BACKTICK counts as a command position: F54 decided that
#      against a real stray, and this inherits the decision rather than retaking
#      it.
#   c. An in-place edit with NO target token now FAILS CLOSED. That is what
#      closes `xargs sed -i`, where the filenames arrive on stdin and the walk
#      can never see them - F57's outcome note records it as a live hole. It
#      costs nothing real: `sed -i` with no file is an error in sed anyway.
#   d. `{}` resolves against FIND'S OWN ROOT rather than the cwd. Before this,
#      `find /elsewhere ... -exec sed -i ... {} +` run from the repo was refused
#      although it touches nothing here, because every bare word took the
#      relative branch and `dirname` of `{}` or `+` is `.`.
#
# Segments come from lines(): newline, && and ||. `|` is deliberately NOT a
# splitter - `sed -i 's/a|b/c/' f.md` is a real script, and splitting there
# would cut the target off and fail OPEN. A standalone `|`, `;` or `&` TOKEN
# stops the walk instead, which a quoted script cannot produce.

# in_repo_path TOKEN BASE : true when TOKEN resolves into the repo. BASE is the
# cwd for an ordinary relative target, or find's own root for `{}`. An empty
# BASE fails closed, which is what this whole file does when it cannot tell.
in_repo_path() {
  _t=$1; _base=$2
  case "$_t" in
    /*|[A-Za-z]:*|\\*)
      case "$_t" in "$repo_posix"*|"$repo_win"*) return 0 ;; esac
      _pw=$(printf '%s' "$repo_win" | sed 's#\\#/#g')
      case "$_t" in "$_pw"*) return 0 ;; esac
      return 1 ;;
  esac
  [ -n "$_base" ] || return 0
  _d=$(cd "$_base" 2>/dev/null && cd "$(dirname "$_t")" 2>/dev/null && pwd)
  case "$_d" in "$repo_posix"*) return 0 ;; esac
  return 1
}

lines | while IFS= read -r seg; do
  printf '%s\n' "$seg" | grep -Eq '(^|[`(])[[:space:]]*sed[[:space:]]|[[:space:]]xargs([[:space:]]+-[^[:space:]]+)*[[:space:]]+sed[[:space:]]|[[:space:]]-exec[[:space:]]+sed[[:space:]]' || continue

  # find's root, for `{}`. Empty when this segment has no find, which then
  # fails closed below rather than silently resolving to the cwd.
  fr=''
  if printf '%s\n' "$seg" | grep -Eq '(^|[[:space:]`(])find[[:space:]]'; then
    set -f
    for ft in $(printf '%s\n' "$seg" | sed 's/.*[^[:alnum:]_./-]find[[:space:]]//; s/^[[:space:]]*find[[:space:]]//'); do
      case "$ft" in -*) break ;; esac
      fr=$ft; break
    done
    set +f
  fi

  toks=$(printf '%s\n' "$seg" | sed 's/.*[^[:alnum:]_./-]sed[[:space:]]//; s/^[[:space:]]*sed[[:space:]]//')
  inplace=0; in_repo=0; ntarget=0; saw_script=0; expect_script=0
  set -f
  for t in $toks; do
    case "$t" in '|'|';'|'&') break ;; esac
    if [ "$expect_script" -eq 1 ]; then expect_script=0; saw_script=1; continue; fi
    if [ "$saw_script" -eq 0 ]; then
      # NOTE: these are shell GLOBS, not the ERE the old regex used. `*` here is
      # "any sequence", so the ERE `-[a-zA-Z]*i[a-zA-Z.]*` does NOT port over -
      # as a glob it requires a letter before the `i` and so never matches a
      # bare `-i`, which silently disarms the whole rule. Long options are
      # listed exactly; a short cluster is any `-...i...`.
      case "$t" in
        -e|--expression|-f|--file) expect_script=1; continue ;;
        --expression=*|--file=*) saw_script=1; continue ;;
        --in-place|--in-place=*) inplace=1; continue ;;
        --*) continue ;;
        -*i*) inplace=1; continue ;;
        -*) continue ;;
      esac
      saw_script=1; continue
    fi
    case "$t" in
      # An option may follow the operands: `sed -e 's/a/b/' -i f.md` is legal
      # and must still be caught. Safe here in a way it was not before, because
      # the walk is bounded to one segment and breaks at | ; and & - so the
      # `grep -i` that used to be mistaken for sed's flag is never reached.
      --in-place|--in-place=*) inplace=1; continue ;;
      --*) continue ;;
      -*i*) inplace=1; continue ;;
      -*) continue ;;
      '{}')
        ntarget=$((ntarget+1))
        if [ -n "$fr" ]; then
          in_repo_path "$fr" "$env_cwd" && in_repo=1
        else
          in_repo=1
        fi
        continue ;;
      \$*|\"*|\'*) continue ;;   # a variable or a quoted script: cannot tell
    esac
    # `+`, `;` and `\;` are find -exec terminators, not paths. Anything with no
    # alphanumeric in it cannot be one either.
    case "$t" in *[A-Za-z0-9]*) ;; *) continue ;; esac
    ntarget=$((ntarget+1))
    in_repo_path "$t" "$env_cwd" && in_repo=1
  done
  set +f

  if [ "$inplace" -eq 1 ] && [ "$ntarget" -eq 0 ]; then
    printf 'guard-bash: %s\n' "sed -i with no filename takes them from stdin, which this hook cannot read - xargs sed -i is the shape; name the paths, or use the Edit tool" >&2
    exit 2
  fi
  if [ "$inplace" -eq 1 ] && [ "$in_repo" -eq 1 ]; then
    printf 'guard-bash: %s\n' "sed -i rewrites a CRLF file as LF and the diff shows every line; use the Edit tool or node with an explicit encoding" >&2
    exit 2
  fi
done
rc=$?
[ "$rc" -eq 0 ] || exit "$rc"

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

# --- 6. find rooted at a filesystem or drive root ----------------------------
# Eighteen of these were run on 2026-09-16/18/19, every one by a spawned worker
# hunting for a file it had not been given the path to. On Windows Git Bash the
# search never finishes: `find.exe` outlived its agent by four hours, and
# Stop-Process reported success while leaving it alive. A nineteenth ran from a
# main session because backticks inside a `node -e "..."` string were
# substituted by the shell - which is why a backtick counts as a command
# position below.
#
# `find` at a COMMAND position only, so that prose naming the shape does not
# trip it: this rule's own documentation, and the memory note it came from, are
# full of the phrase. That is a narrower guard than the other five and it is
# deliberate - SKILL-AUDIT F57 records that the rules read prose, and a rule
# whose trigger words are its own subject is the worst case of it.
#
# Every one of the eighteen used the bare unquoted `/`. The drive spellings are
# defence in depth, not the thing that makes it fire.
if has '(^|[;&|(`]|&&|\|\|)[[:space:]]*find[[:space:]]+(-[a-zA-Z-]+[[:space:]]+)*(/|[A-Za-z]:[\\/]?|/[a-z]/)([[:space:]]|$)'; then
  refuse "a search rooted at the drive never finishes here and outlives the agent; name the directory - the path you were given, or the repo"
fi

exit 0
