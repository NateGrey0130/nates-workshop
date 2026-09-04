<!--
  A PROMPT, NOT A PROCEDURE. `ship-pr` owns the loop and `audit-menu` owns what
  taking a finding means; this file exists so the compose box is not empty for
  someone who has not read them. Do not grow it into a second copy of either -
  REPO-AUDIT.md G7.

  Delete any heading that does not apply. A short honest PR beats a padded one.

  Passing `--body-file` REPLACES this template, which is the normal path here -
  so this text is for a PR opened in the browser, or by `gh pr create` with no
  body.

  THE HEADINGS BELOW ARE `ship-pr` STEP 6's LIST, AND THAT IS THE COPY THAT GETS
  READ. G7 was taken on the premise that the convention already lived in that
  skill. It did not - this file was the only written copy of it, which is the
  reverse of what G7 intended, since the path that replaces this template is the
  path every PR here takes. The skill now carries the list and this file follows
  it. If the two ever disagree, the skill is right. SHIP-PR-AUDIT.md F3.
-->

## The gap

<!-- What was wrong or missing, and why it mattered. Not what files moved. -->

## What was measured

<!--
  Numbers only with their SOURCE and their DATE - the script that printed them,
  and whether against `--remote` or `--local`. `--local` accumulates and has
  reported problems production merged away weeks earlier.

  If a claim here was reasoned to rather than run, say so in those words.
-->

## Posture

<!--
  Half of what is being agreed to, and the cheapest thing to get wrong. Log, do
  not cap. Warn, do not block. Opt-in. Documentation only. No new gate.
-->

## Nothing regresses — checked, not assumed

<!--
  What could have broken, and the check that says it did not. "Nothing else
  uses this" is an absence claim: prove it by reading, not by grepping one of
  the two shapes it might take.
-->

## Decline path

<!-- The honest case for NOT doing this, so declining stays a real option. -->

## Verification

<!--
  Paste the pass lines. The merge gate is the FLAGLESS run - a `--section` run
  labels itself PARTIAL precisely so it cannot stand in for this.

  Touched D1? Say which files are ALREADY APPLIED. Schema and data go to
  production BEFORE the merge, so by review time merging them is a no-op and a
  reviewer looking for the deploy step will not find one.
-->

```
```
