# Repository architecture audit — git, GitHub, layout and the merge path, 2026-09-03

> **Since 2026-09-16 the closed findings live in `REPO-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

**Status, all of it 2026-09-03: nothing is open.**

| | |
|---|---|
| **taken** | `G1`–`G8`, `G11`–`G15`, `G17`, `G18` |
| **closed, not taken** | `G9`, `G10` — each already decided by another menu |
| **closed by decision** | `G16` — declined, and the decline written into `SETUP.md`; and `G5` half (b), 2026-09-03, squash and rebase stay enabled |
| **re-scoped before being taken** | `G5`, `G11`, `G15` — their `Adjusted` notes stand above the re-scopes |
| **taken in part** | `G2` via path B. **`G5` half (a) taken, half (b) closed by decision — the finding is closed entire** |

**Read the lines under a finding's own heading for its state, and its PR
number.** This block is a convenience and it is the kind of thing that goes
stale first — it was a run-on sentence carrying twelve PR numbers until it was
rewritten, which is the failure it warns about, arriving in the status line
itself.

**Every finding taken from this menu so far has turned up an error in its own
premises, and one of them was in a finding nobody had touched.** `G8` claimed
the suite "has never been runnable on a bare clone" — a bare clone passes
everything, and the real blocker was one `existsSync` assertion. `G1`'s
suggested verification command counts 117 squash-merged PRs as direct pushes.
And taking `G1` disproved **`G5`**, which still says merge commits are used
"exclusively"; it now carries an `Adjusted` banner.

So: **treat the reasoning in these findings as a lead, not as established
fact**, and distrust first anything cheap to check — a count, a command, or a
claim that something has never happened.

## Every remaining finding was re-verified on 2026-09-03

Prompted by the error rate above, not by a schedule. Each open finding's central
claim was re-measured against the repo and the GitHub API the same day the menu
was written. **Two were materially wrong and now carry `Adjusted` banners:**

| finding | verdict |
|---|---|
| `G11` | **WRONG** — "eight under `apps/`" is nine, and it miscounted the root with the very glob `G9` says is incomplete |
| `G15` | **WRONG** — "produces no signal at all" is false; `deploy-sweep.mjs` already reports the Worker, and most of the proposal exists |
| `G6` | claim TRUE, but it was **unverified when written** — only "enabled" had been checked, never "empty" |
| `G2` `G3` `G4` `G7` `G9` `G12` `G13` `G14` `G16` `G17` | central claim **holds** |
| `G3` `G9` `G10` `G12` | hold, with counts that have since **drifted** — see each note |

**There are two failure shapes, and naming them is the useful part.**

**One: reasoned to rather than run.** `G8`'s bare clone, `G1`'s counting
command, `G5`'s "exclusively", `G11`'s totals, `G15`'s "no signal". Every claim
that came from a command actually executed has held; the menu wrote both kinds
in the same voice, and nothing on the page told a reader which was which.
`G18` proposes the fix.

**Two: proposing something another menu had already decided.** `G9` asked to
rename `SETUP-v2-CHANGES.md`; `HEALTH-AUDIT.md` F4 had settled that on
2026-09-02 in PR #523 and chosen the opposite, with reasons. `G10` proposed
numbering the data scripts; `SKILL-AUDIT.md` F25(b) had closed that on
2026-09-02 in PR #567, and its note ends *"recorded so it is not re-proposed."*
**Re-measuring would never have caught either** — `G9`'s facts were right — and
the check is a grep for the subject across the other menus, thirty seconds,
done for neither.

**Both shapes can occur in one finding.** `G10` re-proposed a settled decision
*and* never ran the one command that would have shown its mechanism backwards:
a `NNN-` prefix sorts **first**, not last.

**And shape two is not only a finding's failure — this menu committed it in its
own scope statement.** *What this menu does NOT cover* called
`portability-audit-prompt.md` "never run" and deferred to a
`PORTABILITY-AUDIT.md` that had been **dropped on 2026-09-02**, said so in four
files, and was never coming. The header that warns about the shape carried an
instance of it from the day it was written. Corrected 2026-09-03; the original
stands beside the correction.

This section was added on 2026-09-03 when `G9` was closed, and widened when
`G10` was; the paragraph above it used to say the failure had *one* shape.

**`G6` is the subtler case and worth reading twice.** It was right, and it was
right by luck: the check performed confirmed the tabs were *enabled*, and the
finding asserted they were *empty*. Verifying it required excluding pull
requests from the issues endpoint, which returns 100 rows for a repo with zero
issues. **A coincidence is not a check** — the same lesson `audit-menu` records
about `INGESTION-AUDIT` F14.

**This menu's own trap, stated first, as the `audit-menu` skill asks.** Every
number in this file is a **GitHub-side or filesystem-side measurement taken on
2026-09-03**, and most of them are settings a single click changes without
touching git. A finding here can therefore become false without any commit,
which is the opposite of how the rest of this repo's menus rot. **Re-measure
before taking one** — the commands are quoted inside each finding, and every one
is read-only.

## Findings are `### G<n> — <severity> — <title>`

`G` for git. It collides with nothing: `F` is in use by **eleven** menus, and
`D`, `M`, `R`, `S`, `B`, `C`, `T`, `N` and `P` are each taken. Severity is
lowercase — `high`, `medium`, `low` — in the `UI-AUDIT.md` and
`apps/character-creator/AUDIT.md` shape rather than `HEALTH-AUDIT.md`'s
capitalised one.

## What this menu does NOT cover

**CORRECTED 2026-09-03. `PORTABILITY-AUDIT.md` will never exist, and that was
settled the day before this menu was written.** Everything in the two paragraphs
below defers to a menu that was never coming.

`docs/prompts/portability-audit-prompt.md` was *"written and dropped on the same
day — 2026-09-02 — before any of it was investigated"*
(`docs/prompts/README.md`, under *One of them produced nothing, and that is why
it is kept*). The question underneath it turned out to be about where things sit
on **this** machine, and became `workstation-consolidation-prompt.md` and
`MACHINE-AUDIT.md` instead — which opens by stating that portability was
investigated and dropped. `MACHINE-AUDIT` M13 archived the brief **deliberately
un-annotated**: a dropped direction is a record worth keeping, and the drop
belongs in the index rather than inside the record. That still holds — the brief
is not to be edited.

**So this menu called a dropped direction "never run" and handed it territory it
could never take up.** That is failure shape two from the section above —
asserting what another document had already settled — committed by the menu that
closed `G9` and `G10` for precisely it. **Four files said so and none was read:**
`docs/prompts/README.md` twice, `workstation-consolidation-prompt.md`, and
`MACHINE-AUDIT.md`.

**Nothing is handed back, because there is nobody to hand it to.** Portability
is not deferred to another menu's ownership; it is **not being pursued**, by a
decision predating this file. `G8`'s single point of contact needed no successor
and has none. Anything portability-shaped that matters later belongs in
`MACHINE-AUDIT.md`, which is where that ground actually went.

**The original two paragraphs stand below as the record of what was believed.**

**Portability is not here.** `docs/prompts/portability-audit-prompt.md` — added
2026-09-02 in `c7fe004`, and **never run** — asks for `PORTABILITY-AUDIT.md`
with findings `P1, P2, …` covering the nine junctions, the untracked permissions
file, the OCR cache, the PDFs, the two secrets files and the two environment
variables. That brief owns the question *"what would it take to work from
another machine."*

This menu touches that boundary at exactly one point — **G8**, where the test
suite's inability to run on a bare clone is what forecloses continuous
integration — and hands the general problem back. **Do not file portability
findings here.** If `PORTABILITY-AUDIT.md` is ever produced, G8's outcome note
should cite its number rather than restate it.

Also out of scope by prior ownership: the instruction layer (`SKILL-AUDIT.md`),
documentation content (`DOCS-AUDIT-2.md`, D1–D3 open), the machine itself
(`MACHINE-AUDIT.md`), and the book-ingestion loop (`BOOK-INGEST-AUDIT.md`).

## The scope Nate set, 2026-09-03

Reproduced because four findings only make sense in its light:

1. **All four layers are in scope** — git/GitHub, repo layout on disk, the
   authoring workflow, and release/deploy mechanics.
2. **Non-blocking checks only.** A check may report; it may not gate the merge
   button. G1 is written to respect this and says so explicitly, and G14 records
   the blocking alternative as *declined in advance* rather than pretending it
   does not exist.
3. **Visibility is genuinely undecided.** G2 is written with both paths costed
   and no recommendation.

---

## Found healthy — do not file against these

Checked and correct on 2026-09-03. Listed so a later pass does not spend a
finding on them.

- **Branch pruning works.** `git ls-remote --heads origin` returns **one** ref,
  `main`, against **616 pull requests**. The hand step in `ship-pr` is being
  done. G4 is about the guarantee, not about a mess.
- **`.gitattributes` is doing real work and its comments say why.** `*.sql text
  eol=lf` exists because three classes reached production with literal `\r`
  inside stored markdown in PR #92. The vendored-library and `woff2` rules are
  both justified in-file.
- **`.gitignore` is ahead of its failures.** It excludes `.cache/`, `.dev.vars*`
  with a re-included `.example`, `.claude/settings.local.json`, and `*.tmp` —
  the last carrying the story of `commit-msg.tmp` shipping inside PR #404.
- **No secret has ever been committed.** `git log --all --diff-filter=A` over
  `*.pdf`, `.cache/*` and `*.epub` returns nothing: the OCR cache and the
  sourcebook PDFs have never entered history, so no rewrite is needed for them.
  The values that *are* public — `ACCESS_AUD`, the D1 `database_id`, the team
  domain — are addressed in G2 and are not secrets in the credential sense.
- **The PR body convention is exceptional and consistent.** PR #615 carries a
  gap statement, a before/after table measured against production, an explicit
  "nothing regresses — checked, not assumed" section, a posture line, an
  acceptance test, a recorded decline path, the five suites' pass lines, and the
  diff stat. G7 is about that convention being invisible to GitHub, not about
  its quality.
- **The permission allowlist's gaps are deliberate and documented.**
  `.claude/settings.json` withholds `d1-apply.mjs`, `gh pr merge`, `git push`
  and every `wrangler d1 execute`, and `CLAUDE.md` explains why in a section
  that exists because `settings.json` rejects comments. G1's posture was chosen
  to agree with this.
- **`git config remote.origin.prune=true`** is set locally, so stale
  remote-tracking refs clean themselves.

---

- **G1** — high — `main` has no protection of any kind, and a merge here IS a deploy — Taken, 2026-09-03 (PR #621). Posture held: the bypass is gone and nothing is — full text in `REPO-AUDIT.closed.md` under its own `### G1` heading.

- **G2** — high — the repo is public, and no file in it records that as a decision — Taken via path B, 2026-09-03 (PR #633). The repo stays public, deliberately, — full text in `REPO-AUDIT.closed.md` under its own `### G2` heading.

- **G3** — medium — a public repo with 693 files and no root `README.md` — Taken, 2026-09-03 (PR #623). Posture held: documentation only, one screen, and — full text in `REPO-AUDIT.closed.md` under its own `### G3` heading.

- **G4** — low — branch deletion on merge is discipline, not a setting — Taken, 2026-09-03 (PR #628). `delete_branch_on_merge` is now `true`. — full text in `REPO-AUDIT.closed.md` under its own `### G4` heading.

- **G5** — low — three merge methods are enabled and only one is used — Adjusted 2026-09-03, while taking G1 — this finding's premise is wrong. — full text in `REPO-AUDIT.closed.md` under its own `### G5` heading.

- **G6** — medium — Issues, Projects and Wiki are all enabled and all empty — Taken, 2026-09-03 (PR #629). All three disabled — `has_issues`, — full text in `REPO-AUDIT.closed.md` under its own `### G6` heading.

- **G7** — medium — the PR convention is excellent, and invisible to GitHub — Taken, 2026-09-03 (PR #624). Posture held: a prompt, no gate, nothing checks — full text in `REPO-AUDIT.closed.md` under its own `### G7` heading.

- **G8** — high — nothing but a person ever runs the tests, and CI is foreclosed by something upstream of CI — Taken, 2026-09-03 (PR #620). Posture held: reporting only, no required — full text in `REPO-AUDIT.closed.md` under its own `### G8` heading.

- **G9** — medium — eleven markdown files at the root, and the canonical way to list them misses one — Closed without being taken, 2026-09-03 (PR #625). This had already been — full text in `REPO-AUDIT.closed.md` under its own `### G9` heading.

- **G10** — medium — 359 run-once scripts in one flat directory, ordered by filename, escalated five `z` deep — Closed without being taken, 2026-09-03 (PR #626). Two independent reasons, — full text in `REPO-AUDIT.closed.md` under its own `### G10` heading.

- **G11** — low — audit menus sit at the root or in an app directory by no stated rule — Adjusted 2026-09-03 — both counts in the first sentence are wrong, and the — full text in `REPO-AUDIT.closed.md` under its own `### G11` heading.

- **G12** — medium — `F18` names eleven different things, and the branch names inherit the ambiguity — Taken with `G13`, 2026-09-03 (PR #627). Posture held: convention, — full text in `REPO-AUDIT.closed.md` under its own `### G12` heading.

- **G13** — low — branch names come in at least three shapes — Taken with `G12`, 2026-09-03 (PR #627), exactly as this finding asked — folded — full text in `REPO-AUDIT.closed.md` under its own `### G13` heading.

- **G14** — high — the Pages check went red for 65 consecutive merges and nobody saw it — Taken, 2026-09-03 (PR #630). `.github/workflows/deploy-alarm.yml` — a daily — full text in `REPO-AUDIT.closed.md` under its own `### G14` heading.

- **G15** — medium — one of the two deploy paths produces no signal at all — Adjusted 2026-09-03 — the heading is false, and this finding predicted its own — full text in `REPO-AUDIT.closed.md` under its own `### G15` heading.

- **G16** — low — 1,267 commits, 616 PRs, zero tags — Closed by decision, 2026-09-03 (PR #632) — declined, and recorded. The — full text in `REPO-AUDIT.closed.md` under its own `### G16` heading.

- **G17** — low — a public repo with no `LICENSE` — Taken, 2026-09-03 (PR #634), unblocked by `G2` choosing to stay public. — full text in `REPO-AUDIT.closed.md` under its own `### G17` heading.

- **G18** — medium — a finding does not say whether its central claim was measured or reasoned to — Taken, 2026-09-03 (PR #640), in the narrower form this finding recommended to — full text in `REPO-AUDIT.closed.md` under its own `### G18` heading.

## How to take one

Per the `audit-menu` skill: Nate names one — *"take G6"* — it becomes one PR on
its own branch, the outcome note is appended **under that finding's heading in
the same PR**, and the merge waits for a separate word. Taking a finding means
auditing it first: **every measurement above is a 2026-09-03 GitHub-side or
filesystem reading, and several are one click from being false.** Re-run the
command in the finding and lead the report with whatever it contradicts.
