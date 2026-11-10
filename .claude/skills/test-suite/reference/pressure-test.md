# Pressure-testing a skill

Moved out of `SKILL.md`'s *A skill is a check too, so pressure-test it before
it ships* on 2026-11-10, unchanged, so that the method is loaded only by a
session writing or changing a skill. "This file" below means `SKILL.md`.

A skill in `.claude/skills/` is a check on behaviour, and until 2026-09-23 none
had been seen to fail. Each was written after an incident and tested by the
next one. `take` is what that costs: it exists because `audit-menu` already
required the subject grep and the premise audit, and sessions skipped both
anyway (`take` → the paragraph opening *This skill adds no rule*). A skill that reads as correct
and changes nothing is a green tick that retired a real rule, which is the
same failure this file opens with.

**So a new or changed skill is run against a scenario before it merges.** The
method comes from obra/superpowers' `writing-skills`, reviewed 2026-09-22 and
adopted without the plugin (`SKILL-AUDIT` `F64`):

1. **Write the scenario with the pressure that caused the incident.** Use a
   real failing line, a request to "just fix it tonight", or a branch that's
   already open. A calm scenario tests reading comprehension, not behaviour.
2. **RED: run it BEFORE editing the skill.** Use two fresh subagents with the
   same prompt. Make it planning only: they may read anything and run nothing
   that writes, and they reply with their steps and the first change they would
   make. **Do this before the edit, because every session loads the skills
   from the main checkout:** once a skill file there is edited, that edit is
   what every subagent loads, including ones spawned in the same turn. It is
   also what every other session of the repo loads.
   **In a worktree no session loads what you edit**, so GREEN would
   load the old skill and match RED. Step 4 would then read that as "the
   skill adds nothing", and the verdict would be false. Run this from the
   main checkout.
   **Keep the prompt blind.** It describes the situation and never the
   behaviour you hope for. `claim-audit`'s fixture rule is the precedent: an
   agent that has read the answer key cannot be scored (`SKILL-AUDIT` `F28`,
   `.claude/skills/claim-audit/reference/negatives.md`).
   **The prompt is not the only place the answer can be.** Subagents grep
   the tree and read files from disk, and the harness hands every one of them
   a git snapshot. So keep the answer out of all three places below while any
   run is live:
   - **The branch name and commit subjects.** The snapshot carries the
     current branch, the uncommitted file list and recent commit subjects,
     whatever the tree holds. A branch called `…-sweep-past-the-check` states
     the answer. Run from a neutrally named branch, and don't commit anything
     that describes the test until the runs are done.
   - **The working tree.** An uncommitted finding, a PR-body draft or a
     notes file that describes the test is an answer key. Keep drafts in the
     scratchpad, and write the finding after the runs.
   - **The skill under test.** It must not name the scenario, quote the
     failing row, or record its own RED and GREEN results. Evidence belongs
     in the finding, not in the skill.

   A run that read any of these does not count. Say so in the record, and run
   it again. `SKILL-AUDIT` `F65` had all three leaks in its second GREEN
   round, and its one hit there was discarded. The branch name was still live
   in its third round too (`SKILL-AUDIT` `F66`).
3. **GREEN: edit, WAIT, then run the identical prompt again**, two more runs.
   The edit reaches subagents after a delay, not on save. Measured 2026-09-23:
   a probe spawned two tool calls after an edit loaded the old headings. The
   session then showed a skill-listing refresh carrying the new description,
   and the next probe loaded the new headings. **Wait for that refresh**, or
   have one probe list the skill's `## ` headings, before believing a GREEN
   run saw the new text.
4. **Read the difference, and trust a failure more than a pass.**
   - If RED already does what the skill asks, the skill adds nothing on that
     scenario. **Say so, then ship it smaller or not at all.**
   - If GREEN still misses, either the wording is wrong or the skill never
     loaded. The description is what makes it load.
   - A pass in a clean scenario is weak evidence. A miss is strong evidence.
5. **Put the prompt and what each run did in the PR body.** The next person to
   change the skill can then re-run the same scenario, not invent a new one.

**An agent file is different.** One written mid-session answers
`Agent type '<name>' not found` until the next turn (`CLAUDE.md`,
`SKILL-AUDIT` `F26`), so an agent's GREEN half waits for the next turn. A
skill's waits only for the refresh in step 3.

**Cost: four subagent runs per skill change.** Skip it for a typo, a moved
path, or a dated fact. Run it whenever the change is meant to make a session
**do** something differently.
