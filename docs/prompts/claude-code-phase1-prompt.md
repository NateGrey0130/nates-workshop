# Claude Code Prompt — Phase 1: Core Data Model

Paste this as your first message to Claude Code, run from the root of the
monorepo. Drop `rifts-character-creator-spec.md` into `docs/` in the repo
first so it can read it directly instead of you pasting it inline.

---

I'm adding a new app to this monorepo alongside MediaVault, FilamentForge,
and Spool Scout: a Palladium/Rifts character creator (working name
`character-creator` — rename if there's a naming convention I'm missing).
Full spec is in `docs/rifts-character-creator-spec.md` — read that first.

**Before writing any code:**
- Look at how one existing app (pick the simplest one) is structured:
  folder layout, wrangler.toml, D1 binding setup, Zero Trust config, and
  how the frontend is wired up (plain HTML/JS/CSS, no framework). Match
  those conventions instead of introducing new patterns or dependencies.
- Don't read every file in the repo — just enough to see the pattern once.

**Scope for this session — Phase 1 ONLY, from the spec's build order:**
1. RCC/OCC markdown schema + parser (frontmatter → structured data, per
   section 2 of the spec). Build 2-3 example RCC/OCC files (one Rifts OCC,
   one Palladium Fantasy OCC, one Rifts RCC) to validate the parser against
   real variety, not the full catalog yet.
2. D1 schema for `campaigns`, `characters`, `journal_entries`,
   `level_history`, `items`, `character_items` (section 9). Migration file,
   not seed data beyond a couple of test rows.
3. Wire up auth using the existing Zero Trust setup — don't build new auth.
4. A minimal smoke test proving: a markdown RCC/OCC file parses correctly,
   and the D1 schema migrates cleanly.

**Explicitly out of scope for this session:** creation flow UI, skill
picker logic, equipment/magic systems, GM dashboard, PDF export. Those are
later phases — don't start on them even if it seems efficient to combine.

**Working style — token budget matters, be economical:**
- Batch clarifying questions into one message rather than asking one at a
  time. If something's ambiguous and the spec doesn't answer it, make the
  reasonable call yourself and note the assumption rather than stopping to
  ask, unless it's a decision that's expensive to reverse.
- Edit files with targeted diffs, not full rewrites, when changing part of
  a file you already created.
- Don't re-read files you just wrote in this session unless you need to
  verify something specific.
- Don't run the full build/test loop after every small change — batch
  related changes, then verify once.
- Keep commentary in your responses short — I want to see what changed and
  why in a few lines, not a narrated walkthrough.

**Stop condition:** when Phase 1 is done and the smoke test passes, stop.
Give me a short summary of what was built and any assumptions you made.
Don't start Phase 2 (creation flow) — I'll review, commit, and kick off
the next phase as a separate session.
