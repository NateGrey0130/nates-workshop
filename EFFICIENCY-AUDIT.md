# The book-ingestion loop — efficiency audit, 2026-08-25

An audit of the loop itself, not the code it produces. Evidence: the 22
session transcripts under `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\`
(parsed by script, deduplicated — see Methodology), the merge history of PRs
#236–#285, the five skills, the scripts, and the heavy files. Every number
below was measured; where a number is an estimate it is labeled one.

## What contradicts the premises of the prompt

**1. Fresh reading is not where the tokens go. Context re-carry is.**
Across all 22 sessions, deduplicated: 7.56B cache-read tokens, 84.6M
cache-write, 11.7M output, 32K fresh input. Cache reads are **98.7% of every
token spent**. Everything the loop reads — book text, README, test output —
is cheap the moment it is read; the cost is that it is then re-sent as cached
context on every one of the session's remaining API calls. A 12K-token full
README read at the midpoint of a 1,400-call session costs ~12K fresh and
~8.4M in re-carry. So "where does the process waste tokens" has a structural
answer before any per-file answer: **waste ≈ context size × remaining round
trips**, and the two levers that matter are session length and round-trip
count. Findings F1 and F3 are that lever; the per-file findings (F4, F5) matter
mostly through the same multiplier.

**2. The transcripts double-log usage, and any past token claim derived from
them is inflated ~1.9×.** The `.jsonl` files write one record per content
block, and every record of a multi-block message repeats the same `usage`
object under the same message id — in the Pantheons transcript, 2,352 of
3,741 assistant records are duplicates carrying 980M duplicate cache-read
tokens. The prompt's instruction "each assistant message carries a usage
block" produces a ~2× overcount unless you dedupe by `message.id`. All
numbers in this report are deduplicated. Anyone who has quoted per-session
token figures from these files before should assume those figures were high
by about half.

**3. "The book work runs from Downloads" is stated in the prompt as a fact of
life. It is a top-five waste source.** A session launched from Downloads never
registers the repo's five skills, never loads the repo `CLAUDE.md`, and never
gets a repo-level permission allowlist. Measured consequence: across the book
sessions the Skill tool invoked a repo skill **4 times total**, while
`SKILL.md` files were `cat`-ed into context **73 times (283K chars, ~71K
tokens)** — the Pantheons session alone cat-ed them 34 times, including the
whole 21K-char book-survey skill three times. The reason for Downloads is
real (the PDFs land there, and the accumulated auto-memory is keyed to the
Downloads project), so the fix is not "move the session" — it is F5.

**4. None of the stated non-goals is the bottleneck.** Measured: book-text
extraction is 671 calls, ~246K tokens of results, 2.7–3.0s average — the
OCR-cache design is fine. The absence of CI costs nothing the loop feels;
the test *wall time* is a local property of `smoke.mjs` (F2), and CI would run
the same suite slower. One-proposal-one-PR ceremony costs a median of only
~37 API calls per PR — the rhythm is not the problem; the session that hosts
thirty of them in a row is (F1).

## The two axes, measured

**Tokens.** 12 of the 22 sessions are the book loop; they account for 7.43B
of the 7.56B cache reads. Median context per API call in those sessions:
428K–598K tokens (p90 776K–896K, max 997K — the sessions run to the 1M
ceiling). A PR-sized unit of work is a median ~37 API calls / ~20M cache-read
tokens / ~30K output tokens, with a range of 7–200 calls and 2M–100M tokens.
Fresh input entering context per book-session, by category (result chars ÷ 4,
Juicer + PF sessions, which have clean transcripts): shell file reads ~808K
tokens across sessions (avoidable in part), README ~316K (avoidable — F4),
D1 query results ~257K (replaceable — F3), book text ~246K (irreducible),
test output ~169K (fine), skills-by-cat ~71K (avoidable — F5).

**Time and turns.** A single class inside a batch PR takes ~5–10 API round
trips; a batch PR of 3–6 classes takes 20–50 round trips, 1–3 user turns,
and ~14 min/PR when running hot (ten Juicer PRs merged 09:14–11:30 on
08-25). What breaks the hot pace, per the transcripts: test runs averaging
**44–51s each, run ~7 times per PR** (Juicer session: 198 runs, 2.4h of wall
clock; Pantheons: 156 runs, 2.2h), check-scripts at 31–49s each (~50
min/session), 1,768 D1 round trips at ~11s each (~5h across the book
sessions), and mid-PR stalls where a unit of work hung for hours on a human
gate (the Norse-classes PR: 91 API calls spread over 10h29m of wall clock;
"file-size figures" PR: 4h35m; "derive.js audit": 3h27m).

---

## Findings, ranked by expected saving

### F1 — the same PR costs 2–7× more late in a session than early, and the loop runs marathon sessions

Cost today: the book sessions carry a median 430K–600K tokens of context per
API call, p90 ~800K+. Because every call re-carries the whole context, the
identical unit of work gets steadily more expensive: in the Pantheons session
the Godling/Demigod correction cost 16 calls / 5.0M cache-read early, while
the same-shaped "import vehicles, finish the book" cost 80 calls / 49.8M
late; in the Juicer session "file-size figures" cost 116 calls / **99.7M**.
The natural experiment is decisive: mid-Pantheons, a context reset dropped
the per-call carry from ~788K (doc-audit segment) to ~235K (dragon-hatchling
segment, 29 calls / 6.8M) — a 3.4× cut for the same kind of work, with no
loss of correctness, because everything the import actually needed was in the
repo, the skills, and the OCR cache, not in the conversation.

Estimated cost after: PRs executed at the early-session rate (~5–15M each)
instead of the observed blend — roughly **half of the ~0.5–1.5B cache-read
tokens a book currently costs**.

One-time cost: a skills edit, ~1 session-hour. Two changes: (a) book-survey
step 6 writes its inventory + authority table + progress ledger to
`.cache/books/<slug>/SURVEY.md` (local-only, next to the OCR cache it
describes, so no commercial text enters the repo); (b) book-survey and
class-import state the convention: a new session per import batch (every
2–4 PRs), booted from `SURVEY.md` + `git log --oneline -15`, rather than one
session per book or longer.

Breaks even: within the first book.

Verification given up: **none.** Every PR still runs the full gates; the only
thing a fresh session loses is conversational residue, and the two shipped
errors on record were both made *inside* long sessions with full residue.

Proposal: persist the survey to `.cache/books/<slug>/SURVEY.md` and encode
"fresh session every 2–4 PRs, booted from the survey file" in book-survey and
class-import.

- **Taken, 2026-08-25**: as proposed. book-survey gains step 7 — persist the
  survey (inventory, authority pages + verified offset, diff, plan, progress
  ledger) to `.cache/books/<slug>/SURVEY.md`, local beside the OCR cache it
  quotes — and its "what surveyed means" list now includes the file.
  class-import states the batch convention in its own voice: ledger line on
  merge, fresh session every 2–4 PRs, booted from the file plus
  `git log --oneline -15`. No gate changed.

### F2 — smoke.mjs rebuilds the world on every run: ~45s × ~200 runs per book ≈ 2.4 hours

Cost today: `test/smoke.mjs` (5,625 lines, 1,220 checks) always does all four
of its jobs, including migrating the schema into a local D1 instance — there
is no section flag (`grep process.argv` finds nothing). The loop runs it
~7 times per PR at a measured average of 43.7–51.4s: 198 runs / 2.4h wall in
the Juicer session, 156 / 2.2h in Pantheons. Mid-loop, what the model
actually wants ~6 of those 7 times is the parser/compose sections — the
schema hasn't changed since the last run.

Estimated cost after: `--section parser` (the suite already has `section()`
boundaries) skipping the wrangler/migration build runs in seconds; mid-loop
runs drop from ~45s to ~5s, saving **~2h of wall clock per book** and ~30% of
the test-output tokens.

One-time cost: ~1–2 hours — an argv flag gating which sections run.

Breaks even: first book.

Verification given up: **none, on one condition stated in the same PR**:
ship-pr's step "always run smoke" keeps meaning the *full* suite, flagless,
before every merge. The fast path exists only between edits, never at the
gate.

Proposal: add a `--section <name>` flag to smoke.mjs that skips the D1 build,
and a line in ship-pr pinning "the merge gate is the flagless full run."

- **Taken, 2026-08-25**: as proposed, but in the harness rather than
  smoke.mjs — `--section` (case-insensitive substring; repeatable,
  comma-separated) filters at `section()`/`check()`, and the two checks
  modules each declare their section list once and skip their whole `run()`
  when nothing matches, which is what skips wrangler. A partial run labels
  its summary `PARTIAL SMOKE PASSED ... the merge gate is the flagless run`,
  and a filter matching nothing exits 1 — a loud failure that also catches a
  drifted section list. Measured: `--section parser` runs in 1s against 23s
  (warm) flagless. One stowaway fixed en route: the last bare hand-numbered
  `console.log` group became a real `section('Variable spell costs')`, so the
  suite is 86 sections and those checks stop counting against their
  neighbour. ship-pr step 4 pins the gate.

### F3 — 1,768 D1 round trips at ~11s each, one question per trip

Cost today: `q.mjs` is deliberately one-statement-one-line, so every fact
becomes its own wrangler invocation (~11s measured average, remote) *and* its
own API round trip carrying ~450K tokens of cached context. Book sessions ran
130–290 D1 calls each; ~5h of wall clock and roughly 0.7B cache-read tokens
across the book sessions are attributable to D1 round trips.

Estimated cost after: a `--batch file.sql` mode (one statement per line,
numbered JSON results, single wrangler invocation) collapses the common
verify-after-import volley of 5–10 SELECTs into one call: ~60% fewer D1 round
trips ≈ **~100M cache-read tokens and ~30–45 min of wall clock per book**.

One-time cost: ~1 hour in `d1-query-lib.mjs` + `q.mjs`. The one-statement
rule exists because `--command` truncates at newlines — `--file` does not,
so the batch mode goes through a temp file, keeping the footgun fixed.

Breaks even: first book.

Verification given up: none — same queries, same results, fewer trips.
Read-only stays convention, as today.

Proposal: add `--batch <file>` to q.mjs, executing all statements in one
wrangler `--file` invocation and printing numbered results.

- **Taken, 2026-08-25**: as proposed, except the one invocation goes over
  `--command`, not `--file` — over `--remote`, `--file` goes to D1's import
  endpoint, which returns aggregate counts and swallows every result set
  (d1-apply.mjs replays trailing SELECTs for exactly this reason), so a batch
  of verify SELECTs would have come back empty on the target it exists for.
  The footgun stays fixed a different way: `batchStatements()`
  (sql-statements.mjs, smoke-pinned) splits the file and collapses each
  statement to one line before the join, and `d1Batch()` (d1-query-lib.mjs)
  spawns wrangler without a shell — the npx-cli.js form d1-apply uses — so the
  `item_id: "slug"` queries an execSync command line breaks on are legal in a
  batch. One block per statement comes back numbered, in order. Verified
  against --local and --remote in one invocation each; read-only stays
  convention.

### F4 — the README is used as working memory: ~460 reads, 37 of them full

Cost today: `apps/character-creator/README.md` (5,702 lines, ~50K chars per
full read ≈ 12–13K tokens) was read ~460 times across the sessions — 60 via
the Read tool (708K chars) and 401 via `cat`/`sed`/`awk` (1.27M chars in book
sessions). 37 reads were the whole file: the character-creator audit session
alone read it in full 7 times (337K chars), the Juicer session 21 times by
shell. Each redundant full read costs ~12K fresh plus millions in re-carry
(finding 1's multiplier); the full reads alone plausibly account for
**150–250M cache-read tokens** across the run.

Estimated cost after: with a section-read discipline — `grep -n "^## "` for
the index, then read one heading-bounded range — the same information costs
1–3K tokens per visit. Estimated saving ~100–200M tokens per comparable
50-PR run.

One-time cost: ~30 min: a `scripts/readme-section.mjs "<heading>"` that
prints exactly one section, bounded by the *next heading of any depth* (the
rule the 544-line section-eating incident taught), plus one paragraph in
class-import and claim-audit: never read the whole README; the counts you
would skim it for are pinned by the test suite anyway.

Breaks even: first book.

Verification given up: none for reading — the doc-accuracy passes still read
every section they audit; they just stop re-reading the 5,600 lines around it.
Edits still require reading the section being edited, which the script serves.

Proposal: add `scripts/readme-section.mjs` (heading-bounded section printer)
and encode "index first, one section at a time, never the whole file" in the
skills that touch the README.

- **Taken, 2026-08-25**: as proposed. `scripts/readme-section.mjs` prints the
  heading index with no arguments and one section for a heading — matched
  case-insensitively, exact before substring, ambiguity refused with the
  candidates listed — bounded by the next heading of any depth, fence-aware so
  a `# comment` in a bash block is not a boundary. The section goes to stdout
  and its line range to stderr, for the bounded-edit case. class-import gains
  "The README is not working memory" (index first, one section at a time, the
  counts are test-pinned); claim-audit points its README grep at the section
  printer for context reads. The file map names the script, which the smoke
  test enforces.

### F5 — the skills are delivered by cat, 73 times, because Downloads sessions cannot see them

Cost today: measured in the lead section — 4 proper Skill invocations vs 73
`cat`s of `SKILL.md` files (283K chars ≈ 71K tokens fresh, times the re-carry
multiplier; the Pantheons session cat-ed book-survey whole three times, 63K
chars). Beyond tokens, a cat is un-triggerable: the skill fires only when the
model remembers it exists, which is exactly when it is least needed.

Estimated cost after: skills load once, on trigger, like the Cloudflare
skills already do from `~/.claude/skills`. Saving ~50–150K fresh tokens per
book plus the multiplier, and the skills start firing at the right moments.

One-time cost: 5 minutes, once per machine:
`mklink /J %USERPROFILE%\.claude\skills\<name> C:\Users\natha\Projects\nates-apps\.claude\skills\<name>`
for the five skills (junction, so repo edits propagate; `~/.claude/skills`
already exists and holds eleven skills). Plus a SETUP.md note.

Breaks even: immediately.

Verification given up: none.

Proposal: junction-link the five repo skills into `~/.claude/skills` and
record the command in SETUP.md.

- **Taken, 2026-08-25**: as proposed. The five junctions are live on this
  machine (`New-Item -ItemType Junction`, the PowerShell spelling of
  `mklink /J`; no admin rights involved) and the skills registered by name in
  the linking session immediately — ship-pr fired for this very PR. SETUP.md
  records the loop beside the structure tree that names the skills, plus the
  one gap the mechanism leaves: a skill added later needs its link added in
  the same PR, because nothing notices its absence. The links are per-machine
  state; nothing in the repo changed behavior.

As instruments, the skills themselves earn their cost: book-survey (~5.3K
tokens) and class-import (~3.5K) encode precisely the two shipped-error
classes the guardrail section protects, book-survey has already shed its one
stale fork (the `reference/` copy of read-columns.py, removed), and nothing
that happens every book is skill-less — the gap is delivery, not content.

### F6 — mid-PR human gates turn 30-minute PRs into 10-hour PRs

Cost today: the repo has no `.claude/settings.json` — no permission
allowlist — and sessions launched from Downloads would not inherit one
anyway (same root cause as F5). The transcripts show 73–88 tool results per
book session arriving more than 60s after they were requested, and the
sharpest cases are PRs whose API-call count says half an hour but whose wall
clock says most of a day: Norse classes, 91 calls over 10h29m; file-size
figures, 116 calls over 4h35m. Some of that is the user being away — but a
unit of work that hangs on a permission prompt while the user is away is
exactly an approval boundary interrupting work mid-flight; the work was
ready to continue and could not.

Estimated cost after: read-only commands (node scripts/*.mjs SELECTs,
read-columns.py, pdftotext, the test suites, git/gh reads) proceed without a
prompt; a PR mid-flight only stops for writes, pushes, and D1 `--remote`
mutations. Hours of latency per book removed; token cost unchanged.

One-time cost: ~30 min — run the existing `/fewer-permission-prompts` scan
and commit the resulting allowlist as repo `.claude/settings.json` (it takes
effect for sessions once F5's junction/start-dir story is settled, and
immediately for any session started in the repo).

Breaks even: first book.

Verification given up: none — the allowlist is read-only commands; every
write still prompts, and the human "merge it" gate is untouched.

Proposal: generate and commit a read-only-command allowlist in
`.claude/settings.json` via the fewer-permission-prompts scan.

- **Taken, 2026-08-25**: as proposed. The scan covered the 50 most recent
  transcripts (27 existed, ~14.9K tool calls deduplicated by message id) and
  the committed allowlist is the five test suites, the five read-only
  scripts (q.mjs, drift-check, class-check, repo-vs-live, readme-section),
  read-columns.py, pdftotext, and `node --check`. Deliberately excluded:
  `npx wrangler d1 execute` — at 1,132 hits the single biggest prompt
  source, but the mutation lives in its *argument*, so no prefix pattern
  admits only the SELECTs and q.mjs `--batch` (F3) is the sanctioned path —
  d1-apply.mjs, the bare interpreters (`python -c`, `node -e`), `curl`, and
  every git/gh mutation, which are the human gate this finding preserves.
  q.mjs read-only stays convention, the trade F3 already accepted. One
  wrinkle worth recording: the permission classifier refused to let the
  session write `.claude/settings.json` itself — an agent granting itself
  permissions is exactly what that gate is for — so the file landed via an
  explicitly user-approved copy.

### F7 — the starting_money class of error still has no check; buy the guardrail, not just the savings

Cost today: this is the finding that spends a little to keep the rest
honest. The two on-record errors were cheap-reading errors: two
`starting_money` figures wrong because reading stopped at a page break
(fixed in PR #280 — the fix cost 17 API calls / 8.6M tokens plus a human
catching it), and audit finding D5 withdrawn (c464b65) because a grep was
reported as a reading. The same season also shipped #262 ("correct the
Godling and Demigod against the book they were guessed from") and #285
(blank gear rows) — the measured price of rework PRs is 7–49 API calls and
2M–33M tokens each, plus a review cycle. Free-text fields (`starting_money`,
equipment prose) are exactly the fields no test pins.

Estimated cost after: class-check.mjs gains a `--field-sources` mode: for
each free-text field of a draft, print the OCR-cache lines it was drawn from
*plus the first lines of the following page* whenever the source span ends
within N lines of a page boundary. Deterministic, offline, free. The
page-break error class becomes visible at import time instead of at PR #280
time. It removes no reading — it makes the reading's completeness checkable,
which is what F1's fresh sessions and F4's section reads lean on.

One-time cost: ~1–2 hours in class-check-lib.mjs (the OCR cache is already
page-addressed text).

Breaks even: the first prevented rework PR (~1 per book at the observed
rate).

Verification given up: negative — this adds a check.

Proposal: add a `--field-sources` mode to class-check.mjs that prints each
free-text field beside its page-break-aware OCR source lines.

---

## Methodology

Numbers were produced by three throwaway Python scripts run against the
transcript directory (never read into context): a per-session usage/tool
aggregator, a Bash-command categorizer with tool_use→tool_result wall-clock
pairing, and a per-PR segmenter keyed on `gh pr create`. All token totals
deduplicate assistant records by `message.id` (see lead finding 2; the
Pantheons transcript also duplicates 742 tool_result records, so its
result-char figures are quoted from the clean Juicer/PF transcripts where
precision matters). Wall-clock per category measures request-to-result and
therefore includes any permission-prompt latency; the test-duration averages
were cross-checked against sessions with zero >60s gaps. Git evidence is the
merge history of #236–#285 on `main` (note: #274 merged without a merge
commit; #261 — the Godling correction — was closed unmerged and rebuilt as
#262, and the transcript shows the price of that known stacked-PR failure
mode: the segment that created it cost 16 calls / 5.0M tokens and the
segment that recreated it cost 23 calls / 7.6M). PR cadence is taken from
merge timestamps, not transcripts.
