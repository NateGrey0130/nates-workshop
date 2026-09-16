# Health audit — process, 2026-09-02

> **Since 2026-09-16 the closed findings live in `HEALTH-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **This menu carries no status header, and that is a decision rather than an
> oversight.** It is the only one here without one — `F8`, filed in this file,
> is what gave every other menu the line it now opens with, and PR #531 left this
> file out on purpose. **Status for any finding lives under its own heading; read
> to the next `###`.**
>
> The reason, from #531's commit message, was two-part and only half of it has
> lasted. *"It is the live menu"* was true on 2026-09-02 and is not now. The
> durable half is the other one: **a count in this header would be the moving
> number `F4`, `F5` and `F10` are about** — the three findings in this file about
> documents quoting figures that cannot stay right.
>
> **The intervening evidence strengthens it.** `BOOK-INGEST-AUDIT`'s status
> header went stale within five minutes of a finding closing, and three sources
> describing `MACHINE-AUDIT`'s status disagree three ways. A status line is a
> claim that has to be re-checked by hand, and the hand is what keeps missing.
> So: do not add one here. `META-AUDIT` `A4`.

Read-only review of how this repo is documented, worked and tooled. Checked
against `main` @ `34a7eea` (the merge of #515), the GitHub merge and check-run
history, and the files themselves. No production data was queried and nothing
was changed except this file.

**This is half an audit.** Tracks A (documentation), B (ways of working) and C
(skills and agent tooling) are below. Track D — the platform: schema, bindings,
Access, secrets, dependencies, cost, backups, tests, observability — is a
separate session and will be **appended to this file** with numbers continuing
from `F11`.

The bar throughout is *could Nate operate and reconstruct this in six months*,
not *could a stranger*. Findings that only trouble an outsider were dropped.

This audit replaces tracks A–D of `REVIEW-BRIEF.md`, which were scoped for the
character creator alone and never ran. Scope here is the whole repo.

## What this audit did not redo

- `DOCS-AUDIT.md` (2026-08-25) inventoried every `.md` and closed five findings.
  Track A below is the **delta since that date**, not a second inventory.
- `EFFICIENCY-AUDIT.md` (2026-08-25) covered the token economics of the
  ingestion loop, F1–F7 all taken. Track B is the *delivery* loop — branches,
  merges, deploys — and does not revisit that ground.

## The pattern worth naming

`DOCS-AUDIT` named its pattern as *a doc quoting a number that moves*. That
pattern is now largely solved, and the mechanism that solved it is worth stating
because it is what the open findings below are missing.

**The claims that survived are the ones a test parses out of the prose.** The
smoke suite reads the README's table count, `SETUP.md`'s endpoint count, the
skill list in `CLAUDE.md` and the junction loop in `SETUP.md` back out of the
sentences that state them, and fails until they match the tree. Every one of
those was checked this session and every one is **correct**.

Every stale claim found below sits in a file nothing parses. The rot did not
stop; it moved to where the checks are not. That is the finding under F5.

## Method, and what it got wrong

The open/closed state of the twelve findings menus was established with a script
that splits each file into blocks and reports blocks carrying **no** outcome
marker — inverted deliberately, because the `audit-menu` skill records that
grepping *for* the notes has been wrong four times. The blocks it flagged were
then read by hand.

**The first version of that script was wrong, and wrong in the documented way.**
Its pattern for the bold-paragraph-lead findings in `pick3cut5/AUDIT.md`
(`**T1. …**`) also matched an *inline* cross-reference — `**F10 excluded this on
a premise that is false.**` — in the middle of `BOOK-INGEST-AUDIT` F14's body.
That split the block and hid F14's own `Taken, 2026-08-31 (PR #434)` note, and
F14 was briefly written up here as open work. It is not; it shipped.

That is the fifth mechanical misread of these notes on record, it happened to
the audit whose subject is that they cannot be read mechanically, and it is the
argument for F8. The corrected script is at
`scratchpad/audit-census.mjs` (session-local; not committed).

Two further flags from the corrected run were also false on reading:
`INGESTION-AUDIT` F12 and F19 are **closed as moot** in a retirement table 1,294
lines from their headings, exactly as that file's own trap paragraph warns.

## Findings

---

- **F1** — Critical — 6,006 production rows have no backup, no restore path and no runbook, and the repo says so in writing — Taken, 2026-09-02 (PR #519), with F12 folded in as F12 proposed. A — full text in `HEALTH-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — High — the deploy check is correct, and it is a thing to remember once per merge, 48 times a day — Taken, 2026-09-02 (PR #517). As proposed, posture included: `scripts/deploy-sweep.mjs` — full text in `HEALTH-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — High — the method that produced this repo is not in this repo — Taken, 2026-09-02 (PR #527). `docs/prompts/`, fifteen briefs plus an index. — full text in `HEALTH-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — Medium — the skill about not trusting a count states three wrong ones about itself — Taken, 2026-09-02 (PR #523), with F11 folded in as F11 proposed. Posture — full text in `HEALTH-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — Medium — `schema-change` quotes a table count that is seven tables stale, because nothing parses a skill — Taken, 2026-09-02 (PR #524). As proposed, posture included: one narrow — full text in `HEALTH-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — Medium — the permission allowlist covers the read-only scripts and not the loop — Taken, 2026-09-02 (PR #518). As proposed, posture included: thirteen — full text in `HEALTH-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — Medium — port 8788 is hardcoded in three places, and three separate audits found it occupied by something else — Taken, 2026-09-02 (PR #526). As proposed: documentation only, no port — full text in `HEALTH-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — Medium — no menu states its own status, so establishing that there is no open work costs an audit — Taken, 2026-09-02 (PR #531). Posture held: one line per file, no automation, — full text in `HEALTH-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — Low — `CLAUDE.md` sends a reader to the wrong file for the migration list — Taken, 2026-09-02 (PR #522). As proposed: one sentence, no restructuring. — full text in `HEALTH-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — Low — the same fact is stated as "four" and as "five" in the same skill — Taken, 2026-09-02 (PR #525), taking the better of the two options offered: — full text in `HEALTH-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — Low — two documents are reachable from nothing — Taken, 2026-09-02 (PR #523), folded into F4 as this finding proposed. Both — full text in `HEALTH-AUDIT.closed.md` under its own `### F11` heading.

## Bus factor

Not a finding — a reading of the ones above, because the question "what is
unrecoverable if Nate is unavailable" cuts across them.

Three things in this half of the review are held in one place:

1. **The data.** F1. Nine tables of hand-built and hand-transcribed content with
   no stated recovery. This is the one that is unrecoverable in the literal
   sense.
2. **The method.** F3. Sixteen prompts in a Downloads folder. The repo's outputs
   are all versioned; the instructions that produced them are not.
3. **The state of the backlog.** F8. Two hundred findings whose closure exists
   only as prose that a reader has to interpret, in files that have already been
   misread five times.

Everything else found here is friction, not loss.

**A fourth belongs to Track D and is only noted here**: `SETUP.md` records that
there is no Access policy-as-code in the repo and that every Access and Pages
change is dashboard work through one person's browser. That is assessed in the
platform half.

## What was checked and found healthy

Recorded so the next audit does not redo it.

- **Every pinned documentation claim checked is correct.** The README's
  *"Thirty-three tables"* matches 33 `CREATE TABLE` in `schema.sql`;
  `SETUP.md`'s endpoint count matches 35 route files exactly; `CLAUDE.md` names
  all six skills and states the right number; `SETUP.md`'s junction loop names
  all six. Each of these is parsed back out of the prose by the smoke suite,
  which is why.
- **The skill and agent junctions are intact on this machine.** All six repo
  skills are present in `~/.claude/skills` alongside eleven plugin skills, and
  `~/.claude/agents/book-reconcile.md` resolves.
- **`SETUP.md` v2 (PR #502, 2026-09-01) is accurate.** Its project-structure
  tree, its deploy-failure section and its Access destination table all match
  the tree and the recorded history. It is the newest large document in the repo
  and it is the one with nothing wrong in it.
- **The deploy is currently landing.** The eight most recent merge commits all
  report `Cloudflare Pages=success`.
- **All 200 findings across all twelve menus are closed.** No open work exists
  anywhere in the audit corpus. `REBUILD-AUDIT` F16 and `REDESIGN-AUDIT` R3 read
  as open to a scan and are not: F16 is *"Posture: blocked, no action"*, a
  deliberately recorded negative result, and R3 is closed unadopted (PR #464).
- **`docs/plans/README.md` is internally consistent.** Its first table has
  sixteen rows against nineteen plan files, which reads as a mismatch and is
  not — the remaining plans are listed in two further tables below it. Nearly
  filed as a finding.
- **Commit and PR discipline is uniform.** 511 merged PRs, one branch each,
  descriptive prose titles, `--delete-branch` throughout. Zero reviews on the
  last forty, which is correct for a single-author repo and is not a finding at
  the stated bar.

Three of the items in this section were nearly filed as findings before being
checked. That ratio is the same one `DOCS-AUDIT` reported, and the same argument
for reading rather than believing a pattern match.

---

# Health audit — platform, 2026-09-02

Track D, appended to the process half above. Checked against `main` @ `34a7eea`,
**production D1 by `--remote` query**, and **production HTTP by unauthenticated
`curl`**. Nothing was written: no D1 writes, no deploys, no dashboard changes,
no commits. Numbers continue from `F11`.

Scope was a hygiene pass — confirm the patterns are applied consistently — not
a threat model. No attacker model was built and nothing was exploited.

## Correction to F1, 2026-09-02

**F1 said the recovery path was unknown and rated that Medium confidence. It is
now known, and F1 understates the situation in one direction and overstates it
in another.**

`wrangler d1 time-travel info nates-workshop-media` answers. The database has
point-in-time restore available right now, the D1-scoped token can read it, and
the retention ceiling was measured rather than quoted: a timestamp 45 days back
is refused with *"Please provide a timestamp within the last 30 days"*, and one
20 days back resolves to a bookmark. **The window is 30 days.**

So recovery is not absent — it is one command, and nobody has written it down.
`time travel`, `time-travel` and `bookmark` appear nowhere in the repo's 77
tracked markdown files.

F1's proposal stands and step (a) is now answered; F12 below carries the
verified detail. F1's severity does not change: an undocumented, never-exercised
mechanism with a rolling 30-day ceiling is not a backup, and the thing F1 is
really about — that nobody has looked — is unaffected.

## Findings

---

- **F12** — High — the only real recovery is a 30-day rolling window nobody has written down, and the rebuild that is documented reproduces names but not values — Taken, 2026-09-02 (PR #519), folded into F1 as this finding proposed. The — full text in `HEALTH-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — Medium — a third production secret exists, and the section that enumerates the secrets says there are two — Taken, 2026-09-02 (PR #520). As proposed, posture included — documentation — full text in `HEALTH-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — Medium — local wrangler is a full major version ahead of the one that compiles the deploy, and one text check guards one syntax — Taken in part, 2026-09-02 (PR #532). The cheap half only, and the pinned-build — full text in `HEALTH-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — Medium — the Access bypass prefix serves the gated landing page to anyone, on any path under it — Taken, 2026-09-02 (PR #528). As proposed, posture included: the hole is — full text in `HEALTH-AUDIT.closed.md` under its own `### F15` heading.

- **F16** — Medium — the component holding the key, the money path and the rate limiters is the one with 2.5% test coverage, no preview and a manual deploy — Taken, 2026-09-02 (PR #529), and fully shipped. The code merged, and the — full text in `HEALTH-AUDIT.closed.md` under its own `### F16` heading.

- **F17** — Low — the spend table is a good instrument that nothing looks at — Closed as NOT CODE, 2026-09-02. Nate set a $25 monthly spending limit with — full text in `HEALTH-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — Low — the Worker has observability enabled and the Pages half has nothing configured — Taken, 2026-09-02 (PR #535), on the second branch. The low-confidence half — full text in `HEALTH-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — Nit — both wrangler configs point `$schema` at a directory this repo does not have — Taken, 2026-09-02 (PR #533). Pointed at the published URL rather than — full text in `HEALTH-AUDIT.closed.md` under its own `### F19` heading.

## What was checked and found healthy — platform

The platform half is in better shape than the documentation half. Recorded so
the next audit does not redo it.

- **`node scripts/drift-check.mjs --remote` prints `NO DRIFT`.** Every migration
  matches `schema_migrations`, every data script matches `data_script_runs`,
  every table and column matches `sqlite_master`, and every published class
  matches one a data script can recreate. Read F12 for what this does *not*
  cover.
- **Schema and live agree exactly.** 33 base tables plus the `journal_fts`
  virtual table in both; **22 indexes in both**. Two apparent discrepancies were
  chased and both were my own grep: `CREATE VIRTUAL TABLE` does not match
  `CREATE TABLE`, and `CREATE UNIQUE INDEX` does not match `CREATE INDEX`.
- **The five-place rule holds on the newest migration.** `043-character-grants`
  is present as the migration, as a `CREATE` in `schema.sql`, as a guarded row
  in the seeding block, in `operations.md`'s migration table, and in the
  README's data model. The seeding block's guards are per-feature
  (`WHERE EXISTS (SELECT 1 FROM pragma_table_info(…))`), which is what lets a
  fresh database skip migrations correctly.
- **Every statement against the per-user tables is scoped.** All fifteen
  `SELECT`/`UPDATE`/`DELETE` statements touching `media_items`, `ff_config`,
  `ff_history`, `ff_presets` and `ff_custom_filaments` carry
  `WHERE user_email = ?` or `WHERE email = ?`. No unscoped read or write exists.
  The column name differs per app (`user_email`, `email`,
  `owner_email`/`player_email`) but is consistent within each.
- **The one piece of dynamic SQL is allowlist-gated.** `bulk-update.js` builds
  `SET` assignments by string, and every field name passes `SETTABLE[f]` first;
  values are bound, ids are type- and length-checked, and the batch is capped.
  No injection path.
- **`/api/claude` is properly bounded** — `ALLOWED_MODELS`, a 16,000
  `MAX_TOKENS_CEILING`, a 400 on a malformed body, and fail-open metering that
  cannot break the call it measures.
- **The Access wall holds.** Thirteen unauthenticated fetches: everything 302s
  except the four intended bypass paths. F15 is the single exception and it
  serves the landing page, not data.
- **The rate limiters are sized in money, not requests**, with the arithmetic in
  the config comment. This is the best-reasoned control in the repo.
- **The two wrangler configs have not drifted.** Same `compatibility_date`
  (2026-04-19), same D1 database id, `workers_dev` correctly off, `script_name`
  present on the Durable Object binding as Pages requires. Neither codebase
  imports a `node:` builtin.
- **The documented rebuild path works today** — `scripts/rebuild-local.mjs`
  applied 360 files and 4,264 statements with 0 failures. What it does *not*
  reproduce is F12.
- **Growth is not a risk.** `media_items` 3,639 and `ff_filaments` 2,051 are
  unchanged since the 2026-08-28 measurement in `operations.md`; the whole
  database is roughly 8,000 rows against a 5M-reads/day free tier.
- **No secret is tracked.** `.gitignore` covers `.dev.vars*`, `.env*`,
  `.wrangler`, `.cache/` and `*.tmp`, with the commit-message trap explained in
  a comment; only `.dev.vars.example` is committed, and it contains
  placeholders.

Two things were nearly filed as findings and killed by checking: the index and
table "drift" above, and the eight endpoints calling `request.json()` bare —
which all wrap it in a `try`/`catch` returning a 400, exactly as
`apps/character-creator/AUDIT.md` C1 recorded when it fixed the four that did
not.

---

# Summary — both halves

## The three that would hurt most

1. **F1 + F12 — the data.** 6,006 rows no script can recreate, 30 rows that
   rebuild with wrong values, and a 30-day rolling restore window that is
   undocumented and has never been exercised. Everything else on this list is
   recoverable work; this one is not.
2. **F2 — the silent deploy.** The check is correct and manual, at ~48 merges a
   day. It has already failed once for 65 consecutive merges over four days.
   Nothing has changed structurally since; only the habit has.
3. **F16 — the Worker.** The key, the money path and the only public endpoint,
   with 51 of 2,072 lines under test, no preview, and a deploy that a merge does
   not perform.

## The three cheapest wins

1. **F12 folded into F1** — write down the two `time-travel` commands and the
   30-day window. The verification is already done and in this file. Effort S,
   and it converts the largest exposure in the repo into a known procedure.
2. **F13** — add `TMDB_API_KEY` to `SETUP.md` and `.dev.vars.example`, and drop
   the word "both". Effort S, and it makes the secret inventory true.
3. **F2's sweep** — one command over the last N merge commits. Effort S, near-zero
   ongoing cost, and F17's spend query rides along in the same command.

## Cannot verify from here

- **Anthropic account spend limits.** Whether a budget cap exists on the API key
  is console work. It is the cheapest possible control for F17 and this audit
  cannot see it.
- **Cloudflare Access policies.** The allow list, the Pick 3 Cut 5 bypass
  application's five destinations, and the separate preview-access policy are
  dashboard-only; `pages project list` exits 1 under the D1-scoped token. The
  *effects* were verified by curl (F15); the policies themselves were not read.
- **Whether Pages observability has become available** (F18). One dashboard
  look, and the proposal turns on the answer.
- **R2.** The `MEDIA` bucket's contents, size and public-access setting are
  unreachable — the token has no R2 scope, re-confirmed in `CLAUDE.md`
  2026-08-25. Nothing in the code serves a public bucket URL, which is the part
  that could be checked.
- **Whether `wrangler@3.114.17` still installs and builds** (F14). Not attempted;
  it is the trial the proposal asks for.
- **Whether the eight deleted characters mattered** (F12). Only Nate knows
  whether those were test rows.
- **The 8788 collision** (F7). Nothing was listening during this session, so
  three audit records are the evidence and it was not reproduced.

## Risk register

Failure modes this setup carries **by design**, with the control that catches
each. Several are correct trades that were made deliberately; the column that
matters is the last one.

| # | Failure mode | Control today | Gap |
|---|---|---|---|
| 1 | Data destroyed or corrupted in D1 | D1 Time Travel, 30 days, rolling | Undocumented, never run, expires. **F1/F12** |
| 2 | A merge compiles locally and not on the build image | Text check §9 for one syntax; check-runs per merge | Guards one form out of a major-version gap; the per-merge read is manual. **F2, F14** |
| 3 | The standalone Worker is not deployed, or deployed after Pages | `SETUP.md` states the order | Nothing enforces it; symptom is a 503 in party mode only |
| 4 | A stranger spends the Anthropic key | Two rate limiters, sized in money; model allowlist; token ceiling | Caps rate, not total; nothing reads the spend table. **F17** |
| 5 | The site's only wall is bypassed | Access on every route; `PUBLIC_PREFIXES` must agree with the dashboard policy; `smoke.mjs --remote` checks both | Two lists in two systems, one dashboard-only; unrouted prefix paths serve the landing page. **F15** |
| 6 | An Access or Pages setting is lost or changed | None — no policy-as-code, dashboard only | Not reconstructible from the repo. One person, one browser |
| 7 | An API route breaks behind the login wall | The smoke and regression suites, pre-merge | No production logs; detection is a human complaining. **F18** |
| 8 | The catalog and the repo diverge | `drift-check --remote`, `repo-vs-live.mjs` | Both are manual; `repo-vs-live` reports without an exit code by design. **F12** |
| 9 | A secret is rotated in one place and not the other | `SETUP.md` documents the two `ANTHROPIC_API_KEY` copies | The inventory omits a third secret. **F13** |
| 10 | Work is lost because a finding was never closed | The audit-menu protocol; 200 findings, all closed | No menu states its own status; five mechanical misreads on record. **F8** |

Rows 3 and 6 have no proposed finding. Row 3 is a documented ordering rule whose
blast radius is one app's party mode, and enforcing it needs a deploy pipeline
this repo has deliberately declined. Row 6 is the largest structural risk in the
system and its fix — Access policy-as-code, or an exported record of the
policies — is a decision about how much infrastructure this project wants, not a
defect to be filed. Both are recorded here so they are chosen rather than
forgotten.

---

# Findings raised while working the menu

Findings that did not exist when the audit was written, added as the menu was
worked. Numbered from `F20` and appended here rather than filed among F1–F19,
because those are a dated record of what two sessions found and renumbering them
would destroy it.

Each carries a **When** line: whether it should be settled before the next wave
of the plan, or after the waves are done.

---

- **F20** — Nit — a new script in `scripts/` has a documentation step that exists only in the test — Closed without being taken, 2026-09-02, as already-solved. Nothing was — full text in `HEALTH-AUDIT.closed.md` under its own `### F20` heading.

- **F21** — Medium — the one-command way to copy this database off Cloudflare does not run, and nothing replaces it — Taken, 2026-09-02 (PR #521). `scripts/d1-backup.mjs`, run against production — full text in `HEALTH-AUDIT.closed.md` under its own `### F21` heading.

- **F22** — Low — the `audit-menu` skill says the finding that created it is still open — Taken, 2026-09-02 (PR #534), in the same session it was raised — the wave had — full text in `HEALTH-AUDIT.closed.md` under its own `### F22` heading.

- **F23** — Medium — nothing watches the one component a merge does not deploy — Taken, 2026-09-02 (PR #539), in the same session it was filed, on Nate's — full text in `HEALTH-AUDIT.closed.md` under its own `### F23` heading.

- **F24** — Medium — a preview build wedged before `clone_repo` and silently held the production deploy behind it for 32 minutes — Taken, 2026-09-02 (PR #566): all three parts. Posture as proposed — — full text in `HEALTH-AUDIT.closed.md` under its own `### F24` heading.
