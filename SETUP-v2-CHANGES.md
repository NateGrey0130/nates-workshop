# SETUP.md v2: Changes

**All eight taken, 2026-09-02 (PR #502), in one commit.** SETUP.md is v2 on
`main`, and the deploy was confirmed at `success` on the merge commit's
check-runs — which is, appropriately, the step change 1 is about.

Three decisions made alongside them, recorded here because they are not visible
in SETUP.md:

- **Change 1 split across two files.** SETUP.md describes the failure mode;
  `.claude/skills/ship-pr/SKILL.md` carries the verification as a required step
  in the merge loop. That answers **open question 2** the second way.
- **`docs/pages-to-workers-migration.md` gained a dated *Revisited 2026-09-01*
  section** keeping its recommendation and putting the cost/benefit on record
  as predating the outage. **Open question 3** closed without reopening the
  Pages-vs-Workers decision.
- **Open question 1 answered, not acted on.** The `fonts.googleapis.com`
  allowance in `apps/pick3cut5/test/smoke.mjs` is dead — the fonts are
  self-hosted, the list is always empty, and the check passes vacuously. A test
  finding rather than a documentation one; filed for a separate PR.

**This file stays.** It holds the rationale for each change and the sections
read and confirmed unchanged, neither of which the rewritten SETUP.md carries.
One correction to it: change 3's rationale says `docs/` is cited twice in the
body. It is cited once, in the second-Worker section. Everything else below was
re-checked against the working tree during the rewrite and held.

> After full review, create a fresh v2 incorporating all changes.
> Do NOT edit SETUP.md inline from this document — start a fresh session with
> SETUP.md, this file, and `CLAUDE.md` + `docs/pages-to-workers-migration.md`
> as reference.

Reviewed 2026-09-01 against the repo at `main` (`cf86961`). Every claim below
was checked against the working tree, not against memory of it.

## Changes

### 1. "Merging is the deploy" omits the failure mode that broke it

**Section:** How deploys work

**Change:** Add a subsection — *When the merge does not deploy* — covering: Pages
compiles **every** file under `functions/`, routed or not, with the build
image's pinned wrangler (3.114.17); syntax that image cannot parse fails the
whole deploy; and the failure is silent, because `gh pr checks` has shown a red
"Cloudflare Pages fail" on PRs that deployed fine for months, so the mark reads
as noise. State the verification explicitly:

```bash
gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs
```

plus asking production for a string the change added. Name the guard that
exists: `apps/character-creator/test/checks/environment.mjs` §9, *What Pages
will compile* — and note it is a TEXT check, because `npx wrangler` resolves a
current version that compiles the broken syntax happily.

**Rationale:** This is the doc's central claim, and it was false for four days
and 57 merges (2026-08-26 → 2026-08-30, `d5280fe`, fixed by PR #399). Grepping
SETUP.md for `check-runs|compile|silent|deploy.*verif` returns nothing — the
one document whose job is "how deploys work" never mentions the way deploys
stop working. The section currently names exactly one exception to the rule
(the standalone Worker) and presents it as the only one.

---

### 2. The structure tree contradicts the junction block 40 lines below it

**Section:** Project Structure

**Change:** Add `audit-menu/` to the `.claude/skills/` listing in the tree.

**Rationale:** The tree lists five skills; the PowerShell block below it loops
over six, and the prose after that says "the six repo junctions." Disk has six
(`audit-menu`, `book-survey`, `claim-audit`, `class-import`, `schema-change`,
`ship-pr`). The tree is the stale one. A reader copying the block gets the
right answer and a reader reading the tree does not.

---

### 3. The tree omits two directories the document itself depends on

**Section:** Project Structure

**Change:** Add `.claude/agents/` (holding `book-reconcile.md`) and `docs/`
(holding `pages-to-workers-migration.md`) to the tree.

**Rationale:** Both exist. The paragraph immediately below the tree explains at
length why `agents/` is junction-linked as a whole directory rather than
per-file — about a directory the tree does not show. `docs/` is cited twice in
the body (How deploys work, and the second-Worker section) as the written-up
alternative, and never appears in the map of the repo.

---

### 4. Troubleshooting has no entry for the most expensive failure to date

**Section:** Troubleshooting

**Change:** Add: **"I merged and production did not change"** → the deploy
failed to compile; check `check-runs` for the merge commit, then look for a
file under `functions/` using syntax the pinned build wrangler rejects. Point
at change 1's subsection.

**Rationale:** Every other entry here answers a failure someone hit. This one
cost four days of invisible outage and is the only failure in the list that
produces *no* symptom at all on the request path — the site keeps serving, just
the old code. It belongs in the list precisely because nothing else surfaces it.

---

### 5. Workstation bootstrap is mixed into the repo's structural map

**Section:** Project Structure

**Change:** Move the junction block and its three explanatory paragraphs (the
directory-vs-file forcing, the "nothing else can live in `~/.claude/agents`"
consequence, the "add the link in the same PR" rule) out of Project Structure
into their own top-level section — *Setting up a machine* — placed before or
after *Adding a New App*.

**Rationale:** Structural principle, no mixed content. Project Structure answers
"what is in this repo"; the junction block answers "what you must do once per
workstation before the skills resolve." It is ~40 of the section's ~130 lines
and is the only part of that section that is an instruction rather than a map.
Splitting it also makes the block findable by someone setting up a machine, who
has no reason to look under a directory tree.

---

### 6. "Query D1, don't fetch the site" is now only mostly true

**Section:** Where it lives

**Change:** Qualify the table and the advice. Keep 302-to-Access as the default,
but note the two standing exceptions: the Pick 3 Cut 5 bypass paths answer
without a session (that is what `apps/pick3cut5/test/smoke.mjs --remote`
depends on), and verifying a deploy *requires* fetching production for a string
the change added.

**Rationale:** The section states flatly that the URL "is not reachable from
anything without a session" and directs tool-based checks to D1 instead. Since
the bypass application shipped, that is no longer true of five paths, and
change 1 introduces a verification step that cannot be done through D1 at all.
As written it steers a reader away from the check they now need.

---

### 7. Cost Summary omits two bound services

**Section:** Cost Summary

**Change:** Add rows for R2 (`nates-workshop-media`, bound as `MEDIA`) and
Workers (the standalone `pick3cut5-room`, which is a separate script from the
Pages Functions row).

**Rationale:** Both are provisioned and load-bearing — R2 holds NPC portraits
and is described two sections earlier; the Worker has its own deploy, its own
secret, and its own free-tier request budget. The table reads as a complete
inventory of what the project consumes and is missing two entries.

---

### 8. Preview gating is explained in two places

**Section:** Pick 3 Cut 5 → *Previews are gated, deliberately* / Access

**Change:** Pick one home. Recommend: the mechanism (second, auto-created
Access policy; a friend must be added to it) stays in **Access**, since it is
site-wide; the *consequence for this app* (cannot be played on a preview, so it
is verified on production immediately after merge) stays under Pick 3 Cut 5,
with a pointer rather than a re-explanation.

**Rationale:** Feature sections own their own data. Right now both sections
explain the preview wall from scratch, which is where the two copies will drift
apart — and the site-wide half is not Pick 3 Cut 5's to own.

---

## Confirmed unchanged

Reviewed and correct as written — no change:

- **Environment configuration** — verified: `ACCESS_TEAM_DOMAIN` + `ACCESS_AUD`
  are `vars` in `wrangler.jsonc`, the middleware passes through when either is
  missing, and the dashboard holds only the two encrypted secrets.
- **Who is spending the Anthropic key** — the endpoint list matches, and the
  "spend visibility, not a cap" posture matches `recordUsage`.
- **Pick 3 Cut 5 → the login wall (both halves)** — verified:
  `PUBLIC_PREFIXES = ['/api/pick3cut5/']` in `functions/api/_middleware.js`,
  and `smoke.mjs` does follow stylesheets to derive `/shared/fonts` rather than
  keeping it by hand. The five-destination limit and the "no slot left" warning
  are stated in the test source too.
- **Adding a New App** — the template, the manifest-driven dashboard, and the
  `IF NOT EXISTS` rule all match; `manifest.json` has four live apps plus one
  `"status": "soon"` teaser with a null slug, exactly as described.
- **Access (the login wall)** — identity read in one place, `dev@localhost`
  fallback, dashboard-only policy: all accurate. (Only the preview paragraph is
  affected, by change 8.)
- **Custom Domain** — three steps, still correct.
- **"35 endpoints"** for the character creator — counted 35 non-`_lib` handlers.
  Accurate today; it is the one moving number the doc quotes.

## Open questions

1. **Fonts.** SETUP.md says fonts are self-hosted "since the fonts came off the
   CDN," but `apps/pick3cut5/test/smoke.mjs:85` checks that external assets are
   *fonts only*, allowing `https://fonts.googleapis.com/`. That check passes
   vacuously on an empty list, so it is not evidence of a contradiction — but is
   the allowance dead code to remove, or does something still reach the CDN?
2. **Scope of change 1.** Should the deploy-verification step be stated in
   SETUP.md as the rule, or does it belong in `ship-pr` (the skill that owns the
   merge loop) with SETUP.md only describing the failure? Written above as the
   former.
3. **`docs/`.** Is `pages-to-workers-migration.md` still the accepted answer
   after the 2026-08-30 outage? Its cost/benefit argument predates a real,
   Pages-specific failure that a Worker would not have had. Not a SETUP.md
   change — but if that recommendation flips, SETUP.md's whole deploy model
   changes with it.
