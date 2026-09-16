# The book-ingestion loop — efficiency audit, 2026-08-25

> **Since 2026-09-16 the closed findings live in `EFFICIENCY-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **All 7 findings (`F1`–`F7`) are closed**, re-verified on 2026-09-02. Every outcome
> note sits under its own finding, in the ordinary shape. **No trap in this
> file** — it is the one menu a scan reads correctly.

An audit of the loop itself, not the code it produces. Evidence: the 22
session transcripts under `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\`
(parsed by script, deduplicated — see Methodology), the merge history of PRs
#236–#285, the five skills, the scripts, and the heavy files. Every number
below was measured; where a number is an estimate it is labeled one.

> **The character-creator README was split on 2026-08-26** (PR #309) into an
> 827-line spine plus eleven topic files under `apps/character-creator/docs/`.
> That is the second half of F4 below, which is annotated accordingly. The
> README measurements in this document — the 5,702 lines, the ~50K chars per
> full read — are as of the audit date above and describe the file that was
> split.

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

- **F1** — the same PR costs 2–7× more late in a session than early, and the loop runs marathon sessions — - Taken, 2026-08-25: as proposed. book-survey gains step 7 — persist the — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — smoke.mjs rebuilds the world on every run: ~45s × ~200 runs per book ≈ 2.4 hours — - Taken, 2026-08-25: as proposed, but in the harness rather than — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — 1,768 D1 round trips at ~11s each, one question per trip — - Taken, 2026-08-25: as proposed, except the one invocation goes over — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — the README is used as working memory: ~460 reads, 37 of them full — - Taken, 2026-08-25: as proposed. `scripts/readme-section.mjs` prints the — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — the skills are delivered by cat, 73 times, because Downloads sessions cannot see them — - Taken, 2026-08-25: as proposed. The five junctions are live on this — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — mid-PR human gates turn 30-minute PRs into 10-hour PRs — - Taken, 2026-08-25: as proposed. The scan covered the 50 most recent — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — the starting_money class of error still has no check; buy the guardrail, not just the savings — - Taken, 2026-08-25: as proposed, with one addition the caches forced. The — full text in `EFFICIENCY-AUDIT.closed.md` under its own `### F7` heading.

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
