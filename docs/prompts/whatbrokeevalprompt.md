# Task: evaluate what a fresh build of this database actually breaks

Repo: `C:\Users\natha\Projects\nates-apps` (sessions start in `Downloads`; read
the repo-root `CLAUDE.md` before touching D1 or wrangler). Production is
**correct** — nothing here is a live outage. This is about whether the repo can
still rebuild what production holds.

This is an **audit-first** job: find and measure, do not repair anything until
the findings are agreed. Load the `audit-menu` skill. If it becomes a menu,
`apps/character-creator/DATA-SCRIPT-AUDIT.md` (or a name you argue for) with
`F<n>` findings is the shape.

## What is already known, and how it was found

On 2026-08-28 three citation data scripts were written as `fix-*.sql`, applied
to production **by hand, last**, and were correct there. Before merging, a test
built a database from `db/schema.sql` plus every data script in filename order
and compared it to production:

```
rows carrying a bare book title (no page range)
  production    26
  fresh build  172
```

**148 citations were lost in the rebuild.** The cause is filename ordering:
`restore-skills-missing-from-repo.sql` and its gear and psionics twins CREATE
rows the citation scripts cite, `rename-skills-to-rue.sql` renames rows they
match by name, and `zzz-gear-tidy-2-stub-stats.sql` rewrites the column they
set — all of them sort AFTER `fix-*`. The three were renamed to `zzzz-cite-*.sql`
(PRs #374, #375, #376) and `operations.md` gained a `zzzz-*.sql` row documenting
the tier. **That fix was never verified by a completed rebuild** — see below.

`operations.md` already records this failure mode twice before, for `zz-` and
`zzz-`, both times found by accident. That is three occurrences of one bug.

## Three concrete things to establish

**1. Can a fresh build complete at all? It currently cannot.**
`seed-dev.sql` fails a from-scratch apply with
`UNIQUE constraint failed: gear.slug` — and because `d1-apply` stops at the
first failure, **everything sorting after it never runs**: `untag-cross-system`,
all thirteen `zz-*`, all nine `zzz-*` and the three new `zzzz-*`. So the last
tier of corrections is unreachable in a rebuild today. Find out whether
`seed-dev.sql` is supposed to be in a rebuild at all (it carries `-- local-only`
and the README says it is never applied to production), and if not, whether
anything documents that a rebuild must skip it. **Nothing found so far does.**

**2. Does the `zzzz-` rename actually work?** It was reasoned, applied to
production, and merged — but never proved by a completed rebuild, because the
rebuild is slow and `seed-dev.sql` blocks it. Run one properly: schema, then
every data script in filename order excluding `seed-dev.sql`, then diff the
result against `--remote`. The 148 should go to zero. **If it does not, say so
plainly** — the merged PRs claim it does.

**3. What ELSE diverges?** The 148 were only the rows the three citation scripts
touch, because that is all the comparison looked at. The same comparison across
`classes`, `gear`, `skills`, `spells`, `psionic_powers` — names, categories,
prices, restrictions, not just `source_book` — is the real question. Compare
row counts and full row contents, not one column.

## How to run the rebuild, and what it costs

`node scripts/d1-apply.mjs --local <files>` spawns one `wrangler` per file and
there are 287 of them; a full pass took well over an hour. **Do not run it in
the foreground.** Consider concatenating the scripts into one file for a
throwaway comparison database — but if you do, say in the report that the
per-file failure isolation was given up, because a concatenated run hides which
file broke.

**Back up `.wrangler/state/v3/d1/miniflare-D1DatabaseObject/` before you start,
and restore it with the `-wal` and `-shm` files, not just the `.sqlite`.** A
16 MB WAL survived a `.sqlite`-only restore in the session that found this and
silently reapplied the test's writes over the backup — the local dev database
had to be rebuilt from scratch afterwards. That is the single easiest mistake to
repeat here.

## Rules that apply

- **Do not repair production.** It is right. Any repair is a data script, and it
  sorts in the `zzzz-` tier or later for exactly the reason above.
- **An applied script is never edited.** The three renames were legitimate only
  because those filenames had never reached `main`.
- Numbers carry their date and the command that produced them.
- Read `apps/character-creator/docs/operations.md` §Data scripts first — the
  `zz-`, `zzz-` and `zzzz-` rows are the written history of this bug.
- See also `apps/character-creator/INGESTION-AUDIT.md` (closed, F1-F24) and the
  three book surveys in `apps/character-creator/docs/surveys/`.

## The question the report should answer

**Is "rebuild from the repo" a capability this project actually has, or a
belief?** If it is a belief, say what it would cost to make it true — and
whether it is worth it, given production is backed by Cloudflare and no rebuild
has ever been needed. A recommendation of "do not fix, document the limitation"
is a legitimate answer if the evidence supports it.
