# A batch: where each book's state lives, and running two at once

Moved verbatim from `SKILL.md` §8, which keeps a stub. A `§` number here is a
section of `SKILL.md`, and "`book-survey` §8" written anywhere means this file.
The three tiers below are the copy that governs.

**`BOOK-INGEST-QUEUE.md`** holds a batch's roster and batch-wide decisions:
**read it first**, every session. **A book session's record goes in its own
survey, not the queue**: the `## Ledger` table (one row per PR: date, branch,
what went in) and, at session end, the status line and a short *where it stands
/ what is next*.

**A book's status is the `**Status:**` line at the top of its survey**, with its
row count under it:

```
**Status:** `importing` — gear and spells shipped; classes next. (2026-09-25)

**Rows citing this book:** classes 8, gear 31, spells 24
```

The vocabulary is in `apps/character-creator/docs/surveys/README.md` (`cached`,
`surveyed`, `importing`, `imported`, `excluded`, `backfilled`). **Set both lines
in the PR that changes them**: smoke fails an invalid status, and `regression`
fails a rows line that disagrees with a clean build and prints the line to
paste. `cached` is what a kickoff does for every book at once (§0b plus a
`books.json` entry). **One session per book.**

### Two books at once: one worktree each, and look before you start

**Each session in its own tree.** Two in one checkout put one session's commits
on another's branch with `git status` looking clean.

1. **Look at the board first**: `node scripts/book-board.mjs` (`--remote` adds
   production's rows). A book with someone else's branch or PR on it is taken.
2. **Make the book its own tree**: `node scripts/book-worktree.mjs <slug>`, and
   start the session **in that tree**. It builds its own local D1 (or
   `--copy-d1`), points at the shared OCR cache and links memory; `--remove`
   takes it down (`worktree` skill). Treat `--local` as scratch.
3. **Name branches `pal/data/<slug>-...`** (`CLAUDE.md` → *Naming*). The board
   and `book-worktree.mjs` find a book's work by the `<slug>-` prefix after the
   `<group>/<type>/` part.
4. **Re-diff against production right before each extraction batch** (§4).
5. **Expect a small rebase**: status and counts live in your survey. What can
   collide is a `BOOK-INGEST-AUDIT.md` finding number or a `~NNN` script number;
   smoke fails the duplicate, so renumber the one your branch added.
6. **Before merging more than one PR**, run
   `node scripts/book-board.mjs --merge-check --tests --remote`: merge order, a
   combined test-merge, and what production has that `main` does not. **Never
   rename a data script after applying it `--remote`**; if you must, the new
   file deletes the old name's `data_script_runs` row and is applied again.

**The rule that keeps a batch moving:**

> Import what the schema supports, record what was dropped in the row's
> `extraction_notes`, file the gap in `BOOK-INGEST-AUDIT.md`, and keep going.
> **Do not stop to implement.**

**Data ships with its book; UNASKED-FOR code waits** (next section). Classes,
skills, spells, psionics, gear and `books.json` entries go in with the book,
applied before the merge (`ship-pr` → *The ordering rule*).

### What "no code from a book" forbids: three tiers, and this is the copy that governs

**The rule binds the SESSION, not Nate.**

- **Tier 1: part of an import. Do it, and file nothing.** A class's
  `men_of_arms` line, a `scripts/books.json` entry: catalog vocabulary outside
  a data script.
- **Tier 2: Nate asks, and then it is in scope.** Say so in the outcome note;
  it is a decision, not a rule broken.
- **Tier 3: everything else waits.** A mechanic the app cannot express, a bug
  noticed in passing, a nicer shape: **file the finding, keep going, do not stop
  to ask and do not implement.**

### What the deferral was actually buying, which is not what the ban claimed

Not time: deferred findings were routinely taken within the day. What it bought
was that **the session which read the book was not the session that wrote code
off its own reading.** Keep that directly:

> **A proposal written and implemented in the same session goes through
> `audit-premise-auditor` before it is scoped.**
