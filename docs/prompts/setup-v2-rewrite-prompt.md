Rewrite `SETUP.md` from v1 to v2 in the nates-workshop monorepo, applying the
eight changes recorded in `SETUP-v2-CHANGES.md`.

## Start here

The repo is at `C:\Users\natha\Projects\nates-apps` (this session probably
started in Downloads — it is not the repo). Read, in this order:

1. `SETUP.md` — the document being rewritten, in full
2. `SETUP-v2-CHANGES.md` — the eight changes, each with its rationale
3. `CLAUDE.md` — repo working rules, D1 auth, the apply routine
4. `docs/pages-to-workers-migration.md` — reference, and change 9 below touches it

Use the `ship-pr` skill for the branch/PR/merge loop. Everything lands in **one
PR** — it is a single document going v1 → v2, and several changes touch the same
sections.

## Apply the changes in this order

They are ordered by weight, and the ordering matters: 1 and 4 state the same
fact in two places, and 3 and 5 both restructure Project Structure.

1. **Add the deploy failure mode** to *How deploys work* — Pages compiles every
   file under `functions/`, routed or not, with the build image's pinned
   wrangler (3.114.17); syntax it cannot parse fails the whole deploy silently.
   Reference the guard that exists:
   `apps/character-creator/test/checks/environment.mjs` §9, *What Pages will
   compile*, and note it is a TEXT check because `npx wrangler` resolves a
   current version that compiles the broken syntax happily.
2. **Add `audit-menu/`** to the `.claude/skills/` listing in the Project
   Structure tree — the tree says five, the block below it loops over six, and
   disk has six.
3. **Add `.claude/agents/` and `docs/`** to the tree. Both exist, both are
   discussed in the body, neither is on the map.
4. **Add a Troubleshooting entry**: "I merged and production did not change."
   Point at the subsection from change 1.
5. **Move the junction block** and its three explanatory paragraphs out of
   Project Structure into a new top-level section, *Setting up a machine*,
   placed next to *Adding a New App*. Structure should describe the repo;
   this is workstation bootstrap.
6. **Qualify "query D1, don't fetch the site"** in *Where it lives* — the
   pick3cut5 bypass paths answer without a session, and deploy verification
   requires fetching production for a string the change added.
7. **Add R2 and the standalone Worker** to the Cost Summary table.
8. **De-duplicate preview gating** — the site-wide mechanism lives in *Access*;
   Pick 3 Cut 5 keeps only the consequence for that app, with a pointer.

## Decisions already made — implement these, do not re-litigate

- **Change 1 splits across two files.** SETUP.md describes the failure mode and
  why it happens. The **`ship-pr` skill** gets the actual verification as a
  required step in its merge loop:
  `gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs`, plus
  asking production for a string the change added. Update
  `.claude/skills/ship-pr/SKILL.md` in this same PR. SETUP.md should point at
  ship-pr for the step rather than restating the command as the rule.
- **9. Add a dated note to `docs/pages-to-workers-migration.md`** — a short
  "Revisited 2026-09-01" section recording that a Pages-specific build failure
  has now actually happened, so the doc's cost/benefit argument is on record as
  predating it. **Keep the existing recommendation.** Do not re-open the
  Pages-vs-Workers decision.

## Constraints

- **Do not edit SETUP.md with `sed -i`** — it strips CRLF and flips the whole
  file to LF, and a grep check afterwards reports clean anyway. Use the Edit
  tool, or rewrite the file whole with Write.
- **Bound every section edit by any heading level**, not just the one you are
  aiming at. A `####`-only search in this repo once consumed 544 README lines.
  Check heading counts before and after.
- **Do not introduce new moving numbers.** The doc currently quotes "35
  endpoints" (verified accurate on 2026-09-01) and the five-destination Access
  limit (a hard cap). Do not add counts that drift — the repo has a standing
  problem with docs quoting numbers nothing pins.
- **Verify before asserting.** This is a document about how the system works; if
  the rewrite states something new, check it against the working tree first.
  The v1 review found the structure tree contradicting a block 40 lines below it.
- **Commit `SETUP-v2-CHANGES.md` as part of this PR and keep it.** It is a
  record, not scratch — it holds the rationale for every change and the list of
  sections verified unchanged, which the rewritten SETUP.md deliberately does
  not carry. Do not delete it, and do not fold its contents into SETUP.md.
  Append a short outcome line at the top once the PR merges, naming the PR
  number and date, the way this repo records a taken finding.

## Out of scope — note, do not fix

`apps/pick3cut5/test/smoke.mjs:85` checks that external assets are "fonts only"
by allowing `https://fonts.googleapis.com/`. Fonts came off the CDN and are
self-hosted in `shared/fonts/`, so that list is now always empty and the check
passes vacuously — it would not catch a regression back to the CDN. Real, but a
test finding rather than a documentation one. Flag it for a separate PR.

## Done when

- All eight changes applied, plus the ship-pr step and the migration-doc note.
- SETUP.md reads as one document, not v1 with patches — change 5 in particular
  should leave Project Structure shorter and cleaner, not just relocated.
- `SETUP-v2-CHANGES.md` committed, with its outcome line added after merge.
- One PR, merged per `ship-pr`, and **the deploy confirmed via check-runs** —
  which is, appropriately, the thing this rewrite is about.
