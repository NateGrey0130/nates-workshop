# Prompt — instruction-layer audit for nates-workshop

Audit the skills and other standing instructions we have written during the Nate's
Workshop build, and produce a findings menu. Write **one file** and change nothing
else. Do not edit a skill in this pass, however obvious the fix looks — the whole
point of the menu is that taking a finding is a separate decision.

## Where things are

The monorepo is `C:\Users\natha\Projects\nates-apps`; this session may have started
in `Downloads`, so read the repo's `CLAUDE.md` yourself — it does not auto-load from
outside the repo. Load the `audit-menu` skill before writing anything: it defines
the protocol this file has to follow, and you are about to audit it.

## Scope — everything that gives a future session standing instructions

1. The six repo skills in `.claude/skills/`: `audit-menu`, `book-survey`,
   `claim-audit`, `class-import`, `schema-change`, `ship-pr` — `SKILL.md` and every
   file under their `reference/`.
2. The `book-reconcile` subagent in `.claude/agents/`.
3. `CLAUDE.md` (repo root, and any nested ones — check).
4. The memory layer: `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\memory\`
   and its `MEMORY.md` index.
5. `.claude/settings.json` (permissions, hooks) and `.claude/launch.json`.

Treat 1–5 as **one instruction surface with five layers**, not five lists. Findings
about how the layers interact are the most valuable thing here: the same lesson
written in three places rots in two of them, and a rule in memory that belongs in a
skill only fires when memory happens to be recalled.

Note before you start: `~/.claude/skills/` holds a byte-identical copy of all six
skills, and nothing keeps the two in sync. Establish which copy is authoritative and
whether they have ever diverged; that is a finding in itself if nothing enforces it.

## Evidence — judge each item against what actually happened, not against itself

Use all four. Say which one produced each finding.

- **Git history and the closed audit menus.** `find . -name '*AUDIT*.md'` plus
  `SETUP-v2-CHANGES.md`, which is a menu whose filename does not say AUDIT. Look for
  work a skill should have prevented or guided and didn't: bugs whose fix is a
  sentence some skill already contains, and bugs whose fix is a sentence no skill
  contains yet. Read the outcome notes **under the headings** — never grep for
  `Taken`, in either direction.
- **The memory files as the record of hard-won lessons.** For each one, ask: should
  this be a skill, or a line in an existing skill? Memory is recalled by relevance
  and may not fire; a skill fires on its description. The reverse also counts —
  guidance sitting in a skill that only ever applied to one session.
- **Session transcripts** at `C:\Users\natha\.claude\projects\**\*.jsonl` (~80 files).
  Search for repeated corrections and re-derivations: the same fact worked out from
  scratch in four sessions is a missing skill, and a correction Nate had to give
  twice is a skill that failed to trigger or was wrong. Search targeted strings
  rather than reading files whole — these are large, and cost dominates fast.
- **Live repo state.** Run a `claim-audit` pass on the skills themselves. Every path,
  filename, command, count and "X exists nowhere" in a SKILL.md is a claim with a
  date on it. `schema-change` already shipped a count seven tables stale that nothing
  was reading (F5, 2026-09-02); assume there are more. Verify against production
  (`--remote`) where a number comes from D1 — local is stale in both directions.

## What to ask of each existing skill

- **Does it trigger?** The `description` is the whole trigger surface. Find a real
  session where the skill should have fired and didn't, or fired and wasn't needed.
- **Is it still true?** Check the cheapest claims first — line numbers, counts, file
  names, and any claim about what another file says.
- **Has it absorbed what we learned since it was last edited?** Dates:
  `claim-audit` 2026-08-25, `book-survey` 2026-08-28, `class-import` 2026-09-01,
  `audit-menu` / `schema-change` / `ship-pr` 2026-09-02.
- **Is it the right length?** 585 lines of `book-survey` is read in full every time it
  fires. Ask what earns its place, and what belongs in `reference/` behind a pointer.
- **Does it teach the trap, or just the procedure?** The ones that work here name the
  failure that created them. Flag procedure-only passages that a session would follow
  correctly and still get burned.
- **Does it quote a moving number?** Only counts pinned by the test suite survive.
- **Is it duplicated in CLAUDE.md or memory, and do the copies agree?**

## New skills — brainstorm wide, then rank

Propose anything plausibly useful, including speculative ideas; do not pre-filter to
what is obviously justified. Then rank each by the evidence behind it: how many times
the pain actually recurred, and where you saw it. Say plainly which proposals are
speculation.

Look hard at the uncovered ground: all six skills are character-creator, D1 and
sourcebook shaped, while `apps/` also holds **media-vault**, **filament-forge** and
**pick3cut5** with no skill at all — and there is nothing covering UI/browser
verification, the Windows shell traps, or the deploy-verification sweep that has
bitten us silently before.

## Output

Write `SKILL-AUDIT.md` at the repo root, in the house protocol:

- Open with a **status line naming this menu's own trap** — the way it can be
  misread — as the other menus now do.
- `### F1 — …` for findings about existing instructions; `### N1 — …` for new-skill
  proposals. `###`, em dash, no severity word. Say this shape in the header so the
  next reader does not have to infer it.
- Each finding: a `**Proposal:**` paragraph specific enough to implement from, a
  stated **posture** (rewrite / add a section / delete / split / documentation only /
  no new gate), the **evidence** it came from, and its **cost** if it is a new skill.
- Every number carries its source and its date.
- No outcome notes. Nothing is taken until Nate names one.

Then report in the session: the count of findings by layer, the three you would take
first and why, and anything you found that contradicts the premises of this prompt.

## Non-goals

No edits to skills, memory, CLAUDE.md or settings in this pass. No new checks or
scripts. No PR. Do not add a finding you intend to take yourself, and do not open a
second menu for anything that belongs in an existing one.
