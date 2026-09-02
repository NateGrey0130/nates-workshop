# <Book title> — survey

<!--
TEMPLATE. Copy to apps/character-creator/docs/surveys/<slug>.md and fill in.
Delete this comment and every angle-bracket placeholder as you go.

THE ONE RULE: this file states FACTS ABOUT a book and quotes NO PROSE FROM it.

Page numbers, offsets, counts, class names, table locations, section ranges and
catalog diffs are facts, and facts are what the next session needs. The book's
sentences are not. `EFFICIENCY-AUDIT` F1 originally put this file in `.cache/`
beside the OCR text for exactly that reason — "so no commercial text enters the
repo" — and the file is tracked now because it carries the facts and leaves the
text behind. Where a rule matters, PARAGRAPH IT AND CITE THE PAGE: "p.157 lists
eleven creature types as not available as player characters" carries everything
the import needs, and the book's wording carries nothing extra.

The smoke test enforces the crude half of this — no markdown blockquote in
docs/surveys/*.md — because verbatim excerpts are written as blockquotes by
convention here. It cannot see an inline quotation. You can.
-->

Slug `<slug>`. Cached <date> from `<source_pdf>`, <N> PDF pages,
**<text layer | scan (no text layer)>**<, OCR at 300 dpi, psm 3 — scans only>.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read it from `scripts/books.json`. Do not re-derive it.** That registry is the
authority: `page_offset`, `printed_pages` and any `page_offset_exceptions` were
measured once, and `class-check` and the extractor both read them. Copy the
value and its `note` here, and say what it means for this book:

`page_offset: <N>` — cache file page = printed folio + <N>, so printed folio F
is `p<F+N>.txt` and `read-columns.py <F+N>`.

<If the registry carries `page_offset_exceptions`, say which printed range takes
which offset and why the majority vote cannot see it. `pf` and `underseas` both
carry one; ask `scripts/books.json` for who else does, not this template.>

<A line on OCR quality if it is a scan: median chars/page, whether stat-block
labels survived, whether any page needed a re-render. Note curly quotes and
em-dashes — they must be stripped before any SQL.>

## The book's authority tables

| page | table | states |
|---|---|---|
| **<N>** | *<title as printed>* | <what it settles, in your words> |

<Which one is more valuable, and why. An authority table settles questions the
class and item pages do not — which entries are playable, which are NPC-only,
what the canonical spelling of a name is. Where the book's own index and its
description headings disagree, record both readings and say which wins.>

<Whether a second index exists (Contents, Quick Find) and whether it is clean.>

<Whether costs/levels are printed once or twice. Printed once means transcribed;
printed twice means reconciled.>

## Inventory

Counted by structure over all <N> cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| <section> | <first-last> | <count and kind> |

<A subsection for each category the book defines ZERO of, when "zero" reads like
a gap. A book adding no psionics is a fact about the book, not a hole in the
extraction — state how you checked (the stat-block scan and its hit count), so
the next session does not re-run it.>

## Classes

### Playable <O.C.C.s | R.C.C.s> (<N>) — pages <range>

| class | pages | XP table on p.<N> |
|---|---|---|
| <name> | <first-last> | <ladder name> |

<Any id that COLLIDES with a published class, and the id it must use instead.>

<Any class the book names but does not define — the pages are lore and the
mechanics are in another book. Say which book, and leave it out.>

### NPC-only, excluded by the book's own rule (p.<N>)

<Names with page numbers. These are not "missing classes": the book's authority
table says they are not player characters, and importing them would contradict
it. Paraphrase the rule; do not quote it.>

## Catalog diff

Run against **production** (`--remote`): <counts from the run>.

### <table>: <N> missing, <N> false gaps

`node scripts/catalog-diff.mjs --remote --table <t> --entries <parsed>.json`
returns **matched <N>, missing <N>**.

<Every near-match hand-checked, and the verdict on each. Roughly one in twenty
is a false gap — a row the catalog already holds under a different name. List
the renames as a table: what the book prints, what the catalog holds, and
whether the action is rename or new row.>

<Any convention this import would ESTABLISH rather than follow — a first level-0
spell, a first NULL cost — and why it is safe.>

## Extraction plan

Phase 4 costs money; everything above was free. What gets extracted:

1. <count and kind> from pp.<range> — <fields>. <batching>.

What is deliberately left, with the reason for each:

- <thing> — <reason>

## Ledger

One line per shipped PR, appended when it merges. `class-import` §"A batch
outlives the session on purpose" is what asks for it, and this is the file a
fresh session boots from every 2–4 PRs.

| date | PR | what went in |
|---|---|---|
| 2026-08-27 | — | cache built (161 pp), survey written, offset 0 verified |
| 2026-08-27 | [#352](https://github.com/NateGrey0130/nates-workshop/pull/352) | `ww` registered in `books.json`; 3 skills (336 total); 37 prayers at level 0 (607 spells). Applied `--remote` before the PR. MERGED. |

<The two lines above are `ww`'s real first two, kept as the worked example.
Replace them. A ledger line says what went in, the running catalog total it
moved, and that the data was applied `--remote` before the PR — that ordering is
the `ship-pr` rule, and recording it is how a later session knows production and
the repo agree.>

### What remains

**Paste `node scripts/source-coverage.mjs --remote`, do not count.** It reports
per book, so this section is a copy rather than an arithmetic exercise that goes
stale the next time anything ships:

```
  <slug>             <traceable> / <other>
```

<What `other` is made of for this book — rows with no page range, rows citing
pages the cache does not hold, rows the resolver cannot attribute. A number with
no explanation is not an answer.>
