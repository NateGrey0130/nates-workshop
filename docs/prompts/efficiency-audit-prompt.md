# Prompt: audit the book-ingestion loop for token and time efficiency

Run this from a fresh session started in `C:\Users\natha\Projects\nates-apps`.

---

We have run the same loop through roughly fifty PRs now: ingest a sourcebook
PDF, import the parts that are character data, adjust the schema and the
parser for whatever the book does that the app cannot yet express, then smoke
test, regression test, and audit the docs the change falsified.

I want you to audit **the loop itself**, not the code it produces. The question
is where the process wastes tokens or wall-clock time, and what skill, script,
doc, or convention would take that waste out.

## Measure first. Do not speculate.

Every claim in your report must cite evidence you actually looked at. The
sources:

- **Session transcripts**: `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\*.jsonl`
  (22 files; the book work runs from Downloads, not from the repo dir). Each
  assistant message carries a `usage` block. Parse them with a script — do not
  read them into context. Get real numbers: tokens per session, tokens per
  PR-sized unit of work, which tool calls returned the largest results, how
  many turns a typical class import took, how often a file was read more than
  once in a session, how much of the budget went to cache reads vs fresh input.
- **Git history**: PRs #236–#285 are the recent run — the character-creator
  audit block, Pantheons of the Megaverse, and Juicer Uprising. Commit
  messages and diff sizes tell you which steps produced rework.
- **The existing skills**: `.claude/skills/{book-survey,claim-audit,class-import,schema-change,ship-pr}/SKILL.md`.
  These already encode most of the loop. Judge them as instruments: is each one
  earning its context cost, is any of them stale, and is there a step that
  happens every book with no skill covering it?
- **The scripts** in `scripts/` — `read-columns.py`, `ocr-book.py`,
  `class-check.mjs`, `catalog-diff.mjs`, `drift-check.mjs`, `d1-apply.mjs`,
  `repo-vs-live.mjs`, `q.mjs`. Work out which model-side reasoning each one
  replaced, and what reasoning is still being done in-context that a script
  could do offline for free.
- **The heavy files**: `apps/character-creator/README.md` (5,700 lines),
  `test/smoke.mjs` (5,625), `test/regression.mjs` (1,707), `js/parser.js`.
  Find out how often each gets pulled into context and how much of it is
  actually needed when it does.

## The two axes

**Token cost.** Where do the tokens actually go? Rank the consumers. For each
one, say whether it is irreducible (the book text has to be read), avoidable
(the same file read three times in one session), or replaceable (a model doing
arithmetic or comparison that a script could do). Distinguish fresh input from
cache reads — a large file read once and reused cheaply is not the same problem
as a large tool result returned repeatedly.

**Elapsed time and turn count.** Separately from tokens: where does the loop
stall? Count the round-trips a single class import takes end to end. Look for
steps that are serial but need not be, checks that run late and send work
backwards, and approval boundaries that interrupt a unit of work mid-flight.

## Guardrail: efficiency must not buy back the errors

Most of the current ceremony exists because a cheaper method already produced a
confident wrong answer. Two on the record:

- Two `starting_money` figures shipped wrong because the reading stopped at a
  page break (fixed in PR #280). `starting_money` is free text and no test
  checks it.
- Audit finding D5 was withdrawn in c464b65 because a grep had been reported as
  a reading.

So for every proposal, state explicitly what verification it removes and why
that is safe — or that it removes none. A proposal that saves tokens by reading
less of the book is a proposal to be wrong more often, unless it comes with a
check that catches the difference. Prefer proposals that move work from the
model to a deterministic script over proposals that just do less.

## Non-goals — do not propose these

- Committing the OCR cache or the book text. `.cache/books/` is local-only by
  design; the books are commercial and the repo has no build step.
- CI, GitHub Actions, or any automated test runner. Merging to `main` is the
  deploy; there is deliberately no CI.
- Adding dependencies or a build step to the site itself.
- Batching multiple audit proposals into one PR. One proposal, one PR, is the
  established rhythm and it works.
- Anything that removes the human "merge it" gate.

## Output

Write `EFFICIENCY-AUDIT.md` at the repo root, in the same idiom as
`apps/character-creator/AUDIT.md`: numbered findings, each with the evidence
that produced it and a single `Proposal:` line stating the change concretely
enough that "take the F3 proposal" is an unambiguous instruction.

Rank the findings by expected saving, and for each give:

- the measured cost today (tokens, turns, or minutes — with the number, not an
  adjective),
- the estimated cost after,
- the one-time cost to build it,
- how many books it has to pay back over before it breaks even,
- and what verification, if any, it gives up.

Lead the report with anything you found that contradicts the premises of this
prompt — including any of my non-goals that turn out to be the actual
bottleneck. Say so plainly rather than working around it.

Do not implement anything. This pass produces the menu; I will pick from it.
