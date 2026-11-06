---
paths:
  - ".github/workflows/*.yml"
---

# Workflow job ids

> **What pins this file:** every absolute path it names, by
> `apps/character-creator/test/checks/instruction-paths.mjs`. Nothing pins
> its frontmatter or the repo paths it names: it is a path-scoped rule, not a
> skill, so `environment.mjs` does not read it.
>
> **The prose is pinned by nothing** - read an undated claim here as true on
> the day it was written.

These bind anyone editing `.github/workflows/`. They were moved unchanged out
of the `test-suite` skill (2026-11-06), which still owns which suite a check
belongs in and which of them stop a merge.

`smoke`, `menus` and `regression` are required status checks on `main`, set by
the ruleset `22209348` (ask it: `gh api repos/NateGrey0130/nates-workshop/rulesets/22209348`),
and "the first three" below are the smoke suites of the character creator,
FilamentForge and MediaVault, which report as the one check `smoke`.

**`.github/workflows/tests.yml` runs
the first three under one job, so a job id is a check-run name: renaming a job
leaves a required check that never reports and nothing can merge.** Do not rename
one without editing the ruleset.
