# HEALTH-AUDIT prompt — systems / sysops review of nates-workshop

Written 2026-09-01. Replaces `REVIEW-BRIEF.md` tracks A–D (docs, schema, setup
health, build loop), which were scoped for the character-creator only and were
never run. Scope here is the whole repo.

**Two sessions, one findings file.** Session 1 covers process (docs, ways of
working, skills). Session 2 covers the platform (data, config, edge, secrets,
recovery, tests, observability). Both write `HEALTH-AUDIT.md` at the repo root;
session 2 appends to it with continuing `F` numbers. Run them separately — one
unit of work per session.

---

## SESSION 1 — process: documentation, ways of working, skills

Act as a **systems engineer and sysops reviewer**. Do a read-only review of the
process half of the Nate's Workshop monorepo at
`C:\Users\natha\Projects\nates-apps` (remote `NateGrey0130/nates-workshop`,
Cloudflare Pages + D1, no build step, no CI).

Read `CLAUDE.md` and `SETUP.md` first — a session started outside the repo does
not auto-load `CLAUDE.md`.

### Ground rules

1. **Verify, don't infer.** Every finding cites a file:line, a command you ran
   and its output, or a merge/PR record. "The README says X" is not evidence
   that X is true — it is the thing under audit.
2. **Read-only.** No commits, merges, deploys, or dashboard changes. Writing
   `HEALTH-AUDIT.md` is the only file change.
3. **Report gaps as gaps.** If something cannot be verified from this machine,
   say so and list what you would need.
4. **Findings only. Stop when the menu is written.** A session reading a long
   brief about improving a process will otherwise start improving it. Do not
   fix anything, including things that look like unambiguous rot.
5. **The bar is "could Nate run this in six months,"** not "could a new hire run
   this." Do not file findings whose only impact is that an outsider would be
   confused. Do file findings where *Nate* would be unable to reconstruct a
   decision, a command, or a piece of state.

### Do not re-derive existing audits

- `DOCS-AUDIT.md` (2026-08-25) already inventoried every `.md`. **Start there.**
  Determine which of its findings closed and which silently went stale, then
  report only what is new or newly wrong since that date. Do not repeat its
  inventory.
- `EFFICIENCY-AUDIT.md` (2026-08-25) already covered the token economics of the
  ingestion loop, F1–F7 all taken. Track B below is the *delivery* loop —
  branches, PRs, deploys — not token cost. Do not revisit its ground.
- `REVIEW-BRIEF.md` in `C:\Users\natha\Downloads` shows what tracks A–D were
  originally scoped to cover; read it for coverage ideas only. Its baseline
  numbers are stale (recorded against `main @ ad6b818`) — do not quote them.

### Track A — documentation

- Classify every `.md` not covered by the DOCS-AUDIT delta as: current reference
  / historical record / stale / orphaned (nothing links to it).
- Find claims that are false today: counts, file paths, command invocations,
  "you cannot do X" notes for things that now work, and setup steps that would
  fail on a fresh clone.
- **Time-box this.** Audit the seven root-level files and `CLAUDE.md`
  exhaustively; sample the ~40 others (every file that live instructions point
  at, plus a random handful). Say what you sampled and what you skipped.
- Coverage gaps that matter at the six-month bar: incident response, rollback,
  secret rotation, restoring D1, and how to tell whether a deploy landed.
- Structure: is the root pile of `*-AUDIT.md` / `*-QUEUE.md` a working system or
  accumulated sediment? Are `apps/character-creator/docs/plans/*` live plans or
  abandoned ones? Name the ones that should be archived or deleted.

### Track B — ways of working

- Reconstruct the actual delivery loop from the last ~50 merged PRs
  (`gh pr list --state merged --limit 50`), not from what the docs claim:
  branch naming, PR size, review, the order of schema/data/code, how deploys
  are confirmed.
- Evaluate "merging is the deploy" and its known silent-failure mode (57 merges
  reached `main` without reaching production, 2026-08-26 to 08-30). Is the
  current post-merge verification a real control, or a habit that depends on
  remembering? What would make it structural?
- Evaluate the audit-menu protocol as a process: where it works, and where it
  produces bookkeeping nothing reads.
- **Bus-factor section, separate from documentation coverage.** What is
  unrecoverable if Nate is unavailable — dashboard-only Access policy with no
  policy-as-code, secrets held in two places, knowledge that lives only in agent
  memory files. Treat this as its own subsection, not scattered findings.
- Identify steps that work only because one person remembers them.

### Track C — skills and agent tooling

- Review `.claude/skills/` (audit-menu, book-survey, claim-audit, class-import,
  schema-change, ship-pr) and `.claude/agents/`: are trigger descriptions
  accurate, do the instructions match current repo reality, do any contradict
  each other or `CLAUDE.md`?
- Check `.claude/settings.json` and `.claude/launch.json` for correctness and
  for permissions broader than needed.
- Identify recurring work that has no skill and should, and skills that exist
  but are never invoked.

### Output

Create `HEALTH-AUDIT.md` at the repo root, following this repo's audit-menu
conventions (see the `audit-menu` skill): numbered findings `F1..Fn`, `###`
headings, one PR per finding when taken, dated outcome note appended under the
finding. Each finding carries:

- **Severity** — Critical / High / Medium / Low / Nit
- **Evidence** — the command, file:line, or PR that proves it
- **Impact** — what actually goes wrong, at the six-month-Nate bar
- **Proposal** — the specific change, scoped to one PR
- **Effort** — S / M / L
- **Ongoing cost** — what this proposal costs *forever* once adopted: a check to
  remember, a file to keep current, a CI minute. A proposal whose ongoing cost
  exceeds its impact should say so and recommend declining itself.
- **Confidence** — high / medium / low, and what would raise it

Order by severity, then effort ascending. State in the header that tracks D
(platform) will be appended by a second session.

Do not implement any finding. Stop when the menu is written.

---

## SESSION 2 — platform: data, config, edge, secrets, recovery, tests

Act as a **systems engineer and sysops reviewer**. Do a hygiene review of the
platform half of `C:\Users\natha\Projects\nates-apps`. Read `CLAUDE.md` and
`SETUP.md` first.

This is the second half of a review whose first half is already in
`HEALTH-AUDIT.md` at the repo root. Read it, then **append** your findings with
continuing numbers — do not restart at F1 and do not restructure what is there.

### Ground rules

1. **Verify, don't infer.** File:line, a command and its output, or a production
   response. Nothing else counts as evidence.
2. **Audit remote, not local.** Local D1 has drifted in *both* directions —
   ahead of production and behind it. Every statement about data comes from
   `npx wrangler d1 execute nates-workshop-media --remote`. Every statement
   about what is deployed comes from production HTTP, not from `origin/main`.
   **Read-only `--remote` queries are pre-approved; run as many as you need.**
3. **Probe production.** Use `curl` for the unauthenticated surface — that is
   the security-relevant part, and Access returns a redirect rather than the
   page for anything protected, which is exactly the signal you want. Use real
   Chrome (`mcp__claude-in-chrome__*`) only for authenticated views and for the
   Cloudflare dashboard; the D1-scoped API token cannot read Pages or Access.
4. **Read-only.** No D1 writes, no `wrangler` mutations, no deploys, no commits,
   no dashboard changes. If a check would mutate state, describe it and stop.
5. **Hygiene pass, not a threat model.** Trace tenancy and authorization to
   confirm the pattern is applied consistently; do not build an attacker model
   or attempt exploitation.
6. **Findings only. Stop when the menu is written.** Fix nothing.
7. The bar is **"could Nate operate and recover this in six months."**

### Track D — repo and platform setup

**Data.** `db/schema.sql`, `db/migrations/`, `db/seed-catalogs.sql` against the
live remote schema. Report: tables with no owner app, missing indexes on columns
that are filtered or joined, missing foreign keys and `NOT NULL`, columns the
code no longer writes, effectively dead tables, row counts and growth rate, and
whether every migration is genuinely idempotent on both a fresh and an existing
database. Confirm the five-place rule from the `schema-change` skill actually
holds for the most recent column added.

**Tenancy and authorization.** One shared D1 across four apps. For each app,
trace how per-user isolation is enforced — schema-level, query-level, or
convention — and report inconsistency between them. Media Vault's library is
another user's; use that as the concrete case.

**Config.** Root `wrangler.jsonc` versus `workers/pick3cut5-room/wrangler.jsonc`:
bindings, compatibility dates and flags, the DO binding's `script_name`, and any
drift between the two.

**Access and edge.** `functions/api/_middleware.js` and its `PUBLIC_PREFIXES`
allowlist versus what production actually serves unauthenticated. Curl every
public prefix, and curl a sample of non-listed API routes to confirm they do
*not* answer. Note that Access bypass and the middleware allowlist are two
separate lists that must agree, and that a path test reading HTML only will miss
CSS-fetched assets.

**Secrets.** Enumerate every secret the system needs and where each lives (Pages,
the standalone Worker, local env). Flag any held in two places
(`ANTHROPIC_API_KEY` is known to be), any with no documented rotation procedure,
and any appearing in tracked files or in shell history.

**Dependencies and supply chain.** The repo claims zero dependencies and no build
step. Verify that for the site itself, then audit what is *not* covered by the
claim: `scripts/*.mjs`, the Python OCR path (`ocr-book.py`, `read-columns.py`),
and anything resolved at runtime by `npx`. The 2026-08-30 outage was exactly this
shape — `npx wrangler` resolved a version locally that compiled syntax the Pages
build image's pinned wrangler could not. Report every floating version that can
change under you, and where a version is pinned in one place and floating in
another.

**Cost.** Nothing in the repo appears to track spend. Enumerate the cost surfaces
— Anthropic API keys in two places with no usage ceiling, D1 row and storage
growth, Pages builds, the standalone Worker — and say what a runaway would look
like and how long it would take to notice.

**Runtime hygiene.** Error handling and input validation in `functions/api/`,
rate limiting (noting that Pages Functions cannot use the `ratelimit` binding,
which is why solo generation is proxied to the Worker), response size limits, and
anything an authenticated user can call in a loop at cost.

**Backups and recovery.** The real recovery story for D1 and for the catalogs.
Test whether the documented rebuild path works — `scripts/rebuild-local.mjs` and
the ~19s rebuild are documented; confirm. State plainly what is unrecoverable if
the remote database is lost tonight.

**Tests.** `apps/*/test/`: what they cover, what they pin, and what fails in a
fresh worktree (empty local D1 and phantom drift are known-expected there).
Separate tests that would catch a regression from tests that only restate the
code. Note which documentation counts are test-pinned and which are free to rot.

**Observability.** What would tell Nate the site is broken, and how long would it
take? Cover the Pages build, the standalone Worker (which prints "No targets
deployed" on every successful deploy), D1 errors, and the Anthropic API
dependency.

### Output

Append to `HEALTH-AUDIT.md` with the same finding format as session 1, numbering
continuing from the last existing `F`. Then add at the end of the file:

- A one-page **executive summary** covering both sessions: the three things that
  would hurt most, and the three cheapest wins.
- A **"cannot verify from here"** list — what needs dashboard access, a second
  machine, or Nate's own answer.
- A short **risk register**: the failure modes this setup carries by design, each
  with the control that currently catches it, or "none."

Do not implement any finding. Stop when the menu is written.
