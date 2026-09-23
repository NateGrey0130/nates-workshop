# Instruction-layer audit — the skills, the agent, CLAUDE.md, memory and settings, 2026-09-02

> **Since 2026-09-16 the closed findings live in `SKILL-AUDIT.closed.md`**,
> moved there verbatim with their headings, numbering, notes and `####`
> children; this file keeps a one-line pointer per finding where its heading
> was. Every finding of this menu recorded an outcome, so every one moved. The
> closed file is a record like this one, and the `*AUDIT*.md` glob reaches both.

> **`F44` was taken 2026-09-11 (PR #957)**, filed 2026-09-04 — the three ways
> a worker cannot learn a book's page offset from the two sources both agents
> send it to. **One of its three parts is a cost `F43` created**, so read
> `F43`'s note with it. The live wrong number it named and deliberately
> excluded in `BOOK-INGEST-QUEUE.md` was corrected four minutes after this
> finding was filed, on 2026-09-04 (commit `8309b76`), so nothing is left
> there. **WORK WAS OPENED ON THIS MENU ON 2026-09-22**, by the subagent
> retrospective, under the `##` section of that name; read under a finding's own
> heading for its state. `F41`, `F42` and `F43` were all taken
> 2026-09-04 (PRs #704, #705, #707); `F43` was filed and taken the same day, in
> separate PRs. Three notes carry things a citer needs: `F41`'s posture was
> **widened on Nate's word** from one agent file to four, `F42` corrected a
> paragraph `A13` had shipped hours earlier, and `F43` shipped as the
> **subtractive** variant and records what that cut costs plus two errors in its
> own text. `F43` also **closes `F41`'s tone observation**, so that is not
> re-proposed. Findings sit under
> **`## Opened while closing out 2026-09-04`**. **`F42` partly reverses `F40`**
> and says so — `F40` fixed a false arrangement sentence and recorded that
> *deleting* it was the better fix it was not scoped to make. `F40` taken 2026-09-04 (PR #698) — `audit-menu`'s shape
> table row for this file described an arrangement it no longer has, and now
> carries no count of sections, deliberately. It sits under the existing
> **`## Opened while closing out 2026-09-04`**, not an eighth placement, since
> `F39` was closed on the argument that the existing ones stand.
> `F38` taken 2026-09-04 (PR #695) — every `###` heading in
> this file is now a finding, which is more than `F38` asked for. **`F39` closed
> without being taken** (PR #696), agreeing with its own recommendation and
> recorded so it is not re-proposed. `F37` is **filed WITH its outcome**, all
> 2026-09-04
> under **`## Opened while closing out 2026-09-04`**, a seventh placement. `F37`
> carries its outcome because the file it corrects is **outside this repo** and
> no pull request could take it. **`F39` recommends declining itself** and exists
> so the idea is not re-derived. **`F35` was taken 2026-09-04 (PR #693)** — subtractive, one
> clause, and **four of its own premises were wrong**; read its note before
> citing it. **`F36` was taken 2026-09-04 (PR #692)** — it removed the path
> filter `F32` had added hours earlier, because the number justifying that filter
> was measured on the wrong machine. Both were filed 2026-09-04 under
> **`## Opened while taking F33`** and **`## Opened by F32's own CI run`** — a
> **fifth and sixth** placement on this page, which is past the point where the
> arrangement helps anyone and is worth a finding of its own. **`F33` and `F34` were taken 2026-09-04**
> (PRs #689, #688). `F33`'s note records four other places carrying the same
> falsehood, left unfixed because its posture was one sentence in one skill;
> `F35` is the one that matters, and it is **subtractive** — read its note before
> proposing anything additive there. Filed 2026-09-04 under
> **`## Opened while taking F29 to F32`** — a **fourth** placement on this page,
> after the `N` block, `## Opened while building the verifier agents` and
> `## Opened by taking F28`. **`F29`–`F32` were all taken 2026-09-04** (PRs
> #682, #684, #685, #686). `F30` was scoped **wider than filed** and its own
> proposal was wrong about the mechanism; `F32` added a **path-filtered** CI job, where a
> green pull request outside those paths means the suite was never asked. Read
> both notes rather than this line. Filed
> 2026-09-04 under **`## Opened by taking F28`**,
> which is a third placement on this page — after the `N` block and after
> `## Opened while building the verifier agents`. They are the four things
> `F28`'s runs turned up, which its own posture forbade it from fixing.
> `F26`–`F28` are all taken. `F26` taken (PR #679) after its
> mechanism test ran first and moved it to high confidence; `F27` taken (PR
> #680), scoped to one agent, and **verified 2026-09-04 (PR #683)** — the
> verification was owed a day because a swapped agent cannot be spawned in the
> session that changed it, which is `F26` catching the work that followed it.
> **`F28` was taken 2026-09-04 (PR #678)** — all four
> agents run, all four kept, and its note carries four separate things the runs
> turned up that are **not** fixed there and need their own findings. Filed
> 2026-09-04. Everything from the original pass
> is closed: 25 `F` findings and all 8 `N` proposals, 2026-09-02, PRs
> #540–#569. The three new ones sit under **`## Opened while building the
> verifier agents`**, after the `N` block and before `# Counts` — *not* under
> `## Opened while taking a finding`, because no finding was being taken; they
> came out of PR #676. **Read each finding's own note; this header is a summary
> and summaries here go stale.**
>
> | | |
> |---|---|
> | `F1`–`F8`, `F10`–`F25` | taken |
> | `F9` | **closed without being taken** — measured, and its own instruction said to close rather than weaken |
> | `F12` | documentation taken, the prune **completed** (#571), and the named test **RUN 2026-09-03** (#656) — each directory is governed by its own project settings, which do not compose |
> | `F25` | part (a) taken; part (b) **closed by decision** — the `z`-tiers stay |
> | `N1`–`N3` | written: `verify-ui`, `windows-shell`, `pick3cut5` |
> | `N4`–`N8` | **declined**, each on its own stated condition |
>
> `F22`–`F23` were opened by taking `F1`, `F24` by a stalled deploy while taking
> `F2`, and `F25` by taking `F4`. `F` numbers are findings about instructions
> that exist; `N` numbers are new-skill proposals. `###`, em dash, no severity
> word.
>
> **The one that misreads:** `F22`–`F25` sit under their own
> `## Opened while taking a finding` heading **between `F21` and the `N`
> section**, not in numeric order after `F21`. A reader walking the file top to
> bottom meets them after the cross-layer pair and may take them for proposals.
> `F24` there is a different finding from `HEALTH-AUDIT.md`'s `F24`, filed the
> same hour about the same incident — this one is about what the instruction
> layer says can reach Pages, that one about the stalled build itself.
>
> **The trap this file sets for its own reader:** filing it makes a **fifteenth**
> findings menu, which falsifies `F7` — the finding that corrects `audit-menu`'s
> file table — the moment this file is committed. Take `F7` as written and the
> table is wrong again, about this file, on the day it ships. `F7`'s proposal
> says so and names the row; read it before implementing the correction it asks
> for.
>
> **The second half.** Not one finding here is about code. Every one is about a
> sentence, and sentences are the fastest-moving thing in this repo: four of the
> six skills were edited on **2026-09-02**, the date at the top of this file, and
> `ship-pr` was edited at 08:58 against a brief written at 09:25. The
> `audit-menu` rule *taking a finding is also auditing the finding* is therefore
> not a formality here — it costs one grep and it is never optional. Six of the
> twenty-one below were found by disbelieving a sentence that had been true when
> it was written.

Read-only. Nothing outside this file was changed; no skill, memory file,
`CLAUDE.md`, `settings.json` or `launch.json` was edited, and no PR was opened.

## Scope, and the layer the prompt did not list

The brief named five layers. There are **six**. `docs/prompts/` — fifteen briefs
and a README, added 2026-09-02 as `HEALTH-AUDIT.md` F3 (PR #527) — is a standing
instruction surface by every property except that nobody calls it one: at least
one of its files (`BOOK-INGEST-PROMPT.md`, which is *not* in it, see `F18`) is a
reusable per-book template that a session is meant to run verbatim, and it
overlaps `book-survey` directly. It is treated as a layer throughout.

| # | layer | what it is | measured 2026-09-02 |
|---|---|---|---|
| 1 | `.claude/skills/` | six skills, four reference files | 2,475 lines, 122KB |
| 2 | `.claude/agents/` | `book-reconcile` | 98 lines |
| 3 | `CLAUDE.md` | repo root; **there is no nested one** — `find . -name CLAUDE.md` returns exactly one | 186 lines |
| 4 | memory | 60 files + `MEMORY.md` | 60 index lines, 60 files, no orphans either way |
| 5 | `.claude/settings.json`, `.claude/launch.json` | 39 allow entries; 3 launch configs | — |
| 6 | `docs/prompts/` | 15 briefs + README | not in the brief's scope |

## Evidence, and which finding came from which

Four sources, as the brief asked. Every finding names its own.

- **Live repo state** — a `claim-audit` pass run against the skills themselves:
  every path, filename, command and count in a `SKILL.md` checked against the
  tree at `main` @ `3c4bcc5`. Produced `F1`–`F9`, `F12`, `F13`, `F20`, `F21`.
- **Git history and the closed menus** — all fourteen, including
  `SETUP-v2-CHANGES.md`; outcome notes read under their headings, never grepped.
  Produced `F7`, `F10`, `F11`, `F19`.
- **The memory files** — all 60 read or skimmed, cross-checked against the repo
  and against `MEMORY.md`. Produced `F14`–`F17`, and half of `F1` and `F6`.
- **Session transcripts** — 81 `.jsonl` files, 573MB, parsed by script to the
  **1,041 messages a human actually typed** (`type: "user"`, string content, not
  meta, under 3,000 chars — which excludes compaction summaries, skill
  injections and tool results, all of which are logged as `user` and swamp a
  naive grep 4:1). Produced `F11`, and corroborated `F16`.

## What contradicts the premises of the prompt

**1. `~/.claude/skills/` is not a copy. It cannot diverge.**

The brief says it "holds a byte-identical copy of all six skills, and nothing
keeps the two in sync", and asks whether they have ever diverged. They are not
copies. `dir /AL C:\Users\natha\.claude\skills` reports all six as `<JUNCTION>`
pointing into `C:\Users\natha\Projects\nates-apps\.claude\skills\<name>`, dated
2026-08-25 for five of them and 2026-08-28 for `audit-menu`. `~/.claude/agents`
is a single `<JUNCTION>` on the whole directory. There is one set of bytes on
disk; `diff -rq` across all six reports no differences because there is nothing
to differ. `CLAUDE.md` describes this correctly and the brief's note does not.
**No finding.** The gap the brief expected to find here is real, but it is
`F11` — a *different* file, in the other direction.

**2. "Five layers" is six.** See *Scope* above, and `F18`.

**3. The uncovered ground is not evenly uncovered.** The brief lists
media-vault, filament-forge and pick3cut5 together as three apps with no skill.
The evidence does not treat them alike: pick3cut5 has produced a recurring,
production-visible trap with its own memory and two findings across two menus
(`REDESIGN-AUDIT` N6, `HEALTH-AUDIT` F15), while media-vault and filament-forge
have been quiet since their standardizations closed on 2026-08-26. `N4` ranks
them accordingly rather than proposing three skills.

---

# Findings

## Layer 1 — the six skills and their reference files

- **F1** — `frontmatter.md` says it is exhaustive, it is not, and the correction lives only in memory — where it asserts a disclaimer the file does not carry — Taken, 2026-09-02 (PR #541). Posture as proposed: the reference rewritten, — full text in `SKILL-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — `claim-audit`'s find-them command was written the day before the README split, and now misses 60% of what it hunts — Taken, 2026-09-02 (PR #542). Posture as proposed: one command, one table row, — full text in `SKILL-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — `claim-audit` opens by calling the README 4,600 lines; it is 973 — Taken, 2026-09-02 (PR #545). Posture as proposed, and one premise of the — full text in `SKILL-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — `class-import` quotes two counts that have moved by 5.5× and 2× — Taken, 2026-09-02 (PR #546). Posture as proposed. Both premises held — — full text in `SKILL-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — `book-survey` says `pf` is the only book with a page-offset exception; `underseas` has one too — Adjusted 2026-09-02 (PR #564). The same claim was still standing in — full text in `SKILL-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — the zero-offset worked example names the one book that is not registered at zero, and states its number in a base the registry does not use — Taken, 2026-09-02 (PR #553). Posture as proposed: rewrite the paragraph plus — full text in `SKILL-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — `audit-menu`'s file table is wrong about `DOCS-AUDIT.md`, and filing THIS file makes it wrong again — Taken, 2026-09-02 (PR #548). Posture as proposed: correct one cell, add one — full text in `SKILL-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — `book-survey` is 585 lines read in full on every fire, and about a third of it is worked example — Taken, 2026-09-02 (PR #563). Posture held — no rule moved — and the finding's — full text in `SKILL-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — the machinery to pin a skill's claims exists and pins exactly one sentence pattern — CLOSED WITHOUT BEING TAKEN, 2026-09-02 (PR #564) — on the finding's own — full text in `SKILL-AUDIT.closed.md` under its own `### F9` heading.

## Layer 2 — the subagent

- **F10** — `book-reconcile` is the oldest instruction in the surface, and its one required output is a page number it is never told how to compute — Taken, 2026-09-02 (PR #554). Posture as proposed: add a section, no change — full text in `SKILL-AUDIT.closed.md` under its own `### F10` heading.

## Layers 3 and 5 — reach: which file is loaded where the work happens

The three findings below are one mechanism seen three times. They are filed
separately because they have different fixes and different postures, and taking
one does not take the others.

- **F11** — the skills reach every directory and `CLAUDE.md` does not, and a note shipped this morning says the opposite in writing — Taken, 2026-09-02 (PR #543). Both parts as proposed, posture included: a — full text in `SKILL-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — the deliberate gaps in the repo allowlist are granted by wildcard in the directory the book work runs from — Taken in part, 2026-09-02 (PR #555): the documentation half only, as the — full text in `SKILL-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — `book-survey`'s first command is justified by a permission fact that is not true where the skill runs — Taken, 2026-09-02 (PR #549). Posture as proposed: rewrite the parenthetical, — full text in `SKILL-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — `launch.json`'s 8788 warning shipped into the file a Downloads session does not load — Taken, 2026-09-02 (PR #556). Posture as proposed: add two configurations and — full text in `SKILL-AUDIT.closed.md` under its own `### F14` heading.

## Layer 4 — memory

- **F15** — a memory reports four findings as open that had merged hours before it was written — Taken, 2026-09-02 (PR #550). Posture as proposed: rewrite the status — full text in `SKILL-AUDIT.closed.md` under its own `### F15` heading.

- **F16** — `MEMORY.md` quotes moving counts, in the index that sits beside the memory telling it not to — Taken, 2026-09-02 (PR #551). Posture as proposed: rewrite index lines, delete — full text in `SKILL-AUDIT.closed.md` under its own `### F16` heading.

- **F17** — the book-ingestion batch protocol is a real, repeated workflow that exists in memory, an untracked prompt and a queue file, and in no skill — Taken, 2026-09-02 (PR #557). Posture as proposed: a section in an existing — full text in `SKILL-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — a memory-only trap contradicts a step `class-import` prints as a command — Taken, 2026-09-02 (PR #558). Posture as proposed: two commands, three lines — full text in `SKILL-AUDIT.closed.md` under its own `### F18` heading.

## Layer 6 — the prompts

- **F19** — the archive that fixed "the method is not in the repo" was already two briefs short on the day it merged, and one of them is a reusable template — Taken, 2026-09-02 (PR #559). Posture as proposed: copy three files, add one — full text in `SKILL-AUDIT.closed.md` under its own `### F19` heading.

## Cross-layer

- **F20** — a menu header says a skill is wrong; the skill was fixed eleven minutes later and nothing corrected the header — Taken, 2026-09-02 (PR #552). Posture as proposed: append the banner — full text in `SKILL-AUDIT.closed.md` under its own `### F20` heading.

- **F21** — three skills state the "do not quote a moving number" rule and three skills break it — Taken, 2026-09-02 (PR #560). Posture as proposed: add a section and one table — full text in `SKILL-AUDIT.closed.md` under its own `### F21` heading.

## Opened while taking a finding

- **F22** — the sheet-list drift check guards the list that never drifted, and not the one that did — Taken, 2026-09-02 (PR #561). Posture as proposed: a check beside the combat — full text in `SKILL-AUDIT.closed.md` under its own `### F22` heading.

- **F23** — no check asks whether the keys published CLASSES write can be rendered at all — Taken, 2026-09-02 (PR #562). Posture as proposed: a check over the repo's own — full text in `SKILL-AUDIT.closed.md` under its own `### F23` heading.

- **F24** — `CLAUDE.md` says Pages is dashboard-or-Chrome work; the Cloudflare MCP plugin reads and writes it directly — Taken, 2026-09-02 (PR #565). Posture as proposed: rewrite the coupled — full text in `SKILL-AUDIT.closed.md` under its own `### F24` heading.

- **F25** — `zz-` no longer sorts after everything, and the sentence saying it does sits in the section about exactly that failure — Taken in part, 2026-09-02 (PR #567): part (a) only. Part (b) CLOSED by — full text in `SKILL-AUDIT.closed.md` under its own `### F25` heading.

# New skills

Ranked by evidence, most-supported first. `N1`–`N3` are backed by recurring,
documented pain. `N4`–`N8` are speculative and labelled so; two of them I would
argue against.

- **N1** — a `verify-ui` skill: how to prove a change in the browser on this machine — WRITTEN, 2026-09-02 (PR #568). `.claude/skills/verify-ui/`, junctioned, — full text in `SKILL-AUDIT.closed.md` under its own `### N1` heading.

- **N2** — a `windows-shell` skill: the traps that have corrupted commands and commits here — WRITTEN, 2026-09-02 (PR #568), with the move the proposal insisted on. — full text in `SKILL-AUDIT.closed.md` under its own `### N2` heading.

- **N3** — `pick3cut5`: the Access wall, the Worker, and the deploy a merge does not do — WRITTEN, 2026-09-02 (PR #568). One skill, not three — `media-vault` and — full text in `SKILL-AUDIT.closed.md` under its own `### N3` heading.

- **N4** — `deploy-verify`: the sweep, the check-runs, and the two deploy paths — DECLINED, 2026-09-02. Nate's call, and it matches the recommendation. The — full text in `SKILL-AUDIT.closed.md` under its own `### N4` heading.

- **N5** — `catalog-import`: skills, spells, psionics and gear, as distinct from classes — DECLINED, 2026-09-02, on its own condition: no catalog-only import has gone — full text in `SKILL-AUDIT.closed.md` under its own `### N5` heading.

- **N6** — `write-a-memory`: what belongs in memory rather than a skill — DECLINED as a skill, 2026-09-02 — and its substance already shipped. `F21` — full text in `SKILL-AUDIT.closed.md` under its own `### N6` heading.

- **N7** — `new-app`: standing up a fourth app in this monorepo — DECLINED, 2026-09-02, on its own condition: there is no third app planned. — full text in `SKILL-AUDIT.closed.md` under its own `### N7` heading.

- **N8** — `cloudflare-access`: the wall, the bypasses, and what the token cannot reach — DECLINED, 2026-09-02, and the fold happened. `N3`'s `pick3cut5` skill — full text in `SKILL-AUDIT.closed.md` under its own `### N8` heading.

# What was checked and found healthy

Recorded so it is not re-derived. Every item below was verified on 2026-09-02.

- **`schema-change` is clean.** All nine "places", both file paths and all six
  named smoke-check strings exist verbatim in
  `apps/character-creator/test/checks/`. The one count it used to quote was
  removed by `HEALTH-AUDIT` F5 and the replacement sentence is correct.
- **`ship-pr` is clean on mechanics.** `git config remote.origin.prune` is
  `true`; `--section` and `PARTIAL SMOKE PASSED` both exist
  (`test/harness.mjs:84`); every test path it names exists; the
  `gh api …/commits/*` command matches the allowlist entry.
- **Every path any skill names exists.** 34 checked — every script, every `js/`
  and `functions/` file, every test, every reference.
- **`CLAUDE.md`'s Cloudflare section holds, re-tested rather than reasoned
  about.** `npx wrangler whoami` exits **0**, prints the account name and ID and
  states *"The API Token is read from the CLOUDFLARE_API_TOKEN environment
  variable"*. `npx wrangler r2 bucket list` and `npx wrangler pages project list`
  both exit **1** with the membership-roles fallback the file describes. All
  three claims were last verified 2026-08-25 and all three still stand.
- **The junctions are intact.** Six skill junctions plus one agents junction, all
  resolving into the repo; no divergence is possible. See *What contradicts the
  premises*.
- **`MEMORY.md` is structurally sound** — 60 lines, 60 files, no orphan file and
  no dangling link. Only its *content* is stale (`F15`, `F16`).
- **`audit-menu`'s file table is right about thirteen of fourteen rows**,
  including both not-a-heading families (`CLASS-AUDIT`'s nine `S` bullets and
  `pick3cut5/AUDIT`'s eleven `T` bold leads), verified against each file's own
  headings. Only the `DOCS-AUDIT.md` cell is wrong (`F7`).
- **The survey template is followed.** `reference/SURVEY.md`'s heading structure
  matches the ten surveys in `docs/surveys/`; the six cached books with no survey
  are cache-only **by design**, as `BOOK-INGEST-QUEUE.md` states.
- **All fourteen existing menus are closed.** Read under the headings, not
  grepped. `HEALTH-AUDIT.md` gained and closed `F23` on 2026-09-02.

---

## Opened while building the verifier agents

Filed 2026-09-04, out of PR #676, which added four read-only subagents and wired
them into three skills. Not opened by taking a finding — nothing on this menu was
being taken — so they sit here rather than in the section above.

**No new subagent is proposed by any of these.** Nate declined a `ship-verify`
subagent on 2026-09-03 (`SHIP-PR-AUDIT.md` header, *"do not re-propose without a
new failure"*), agreeing with `N4` below, and that decision stands untouched:
these three are about agents that already exist and about two sentences
describing them.

- **F26** — `SETUP.md` and `CLAUDE.md` say a new agent works "the moment its file lands"; the junction is instant and the harness is not — Taken, 2026-09-04 (PR #679). Posture held: documentation only — two sentences, — full text in `SKILL-AUDIT.closed.md` under its own `### F26` heading.

- **F27** — a subagent CAN load a project skill by name, and all five agent files are written as though it cannot — Taken, 2026-09-04 (PR #680). Posture held: opt-in and per agent — frontmatter — full text in `SKILL-AUDIT.closed.md` under its own `### F27` heading.

- **F28** — all four agents added in #676 shipped without ever being invoked — Taken, 2026-09-04 (PR #678). Posture held: verification only — all four were — full text in `SKILL-AUDIT.closed.md` under its own `### F28` heading.

## Opened by taking F28

Filed 2026-09-04. `F28`'s posture was verification only, so the four things its
runs turned up were recorded in its note and repaired nowhere. They are findings
here so each gets its own word. **Every premise below was re-verified by hand
after the agent that found it reported it** — an agent's finding is still a claim
about another file.

- **F29** — four live-instruction files say `main` has no ruleset, and one of them contradicts itself — Taken, 2026-09-04 (PR #682). Posture held: documentation only — four passages — full text in `SKILL-AUDIT.closed.md` under its own `### F29` heading.

- **F30** — `audit-citations.mjs` silently ignores a finding number that is not an `F` — Taken, 2026-09-04 (PR #684). Posture held: no gate, no exit code, read-only. — full text in `SKILL-AUDIT.closed.md` under its own `### F30` heading.

- **F31** — the README says `extraction-prompt.mjs` has "Two system prompts"; there is one — Taken, 2026-09-04 (PR #685). Posture held: documentation only — — full text in `SKILL-AUDIT.closed.md` under its own `### F31` heading.

- **F32** — `REPO-AUDIT` `G8` deferred a follow-up to "its own finding" and none was ever filed — Taken, 2026-09-04 (PR #686). Posture held: reporting only, matching `G8` — not — full text in `SKILL-AUDIT.closed.md` under its own `### F32` heading.

## Opened while taking F29 to F32

Filed 2026-09-04, a **fourth** placement on this page — the header says so
because out-of-order sections are this file's own named trap. Both came out of
doing the work rather than out of auditing a finding: one from an error the
instruction layer led me into, one from an agent reading its own file against
the skill it had just loaded.

- **F33** — `windows-shell` states the line-ending rule as one exception; `.gitattributes` has four — Taken, 2026-09-04 (PR #689). Posture held: documentation only — one skill, one — full text in `SKILL-AUDIT.closed.md` under its own `### F33` heading.

- **F34** — `audit-premise-auditor` tells itself every finding has had a bad premise; its own authority says otherwise — Taken, 2026-09-04 (PR #688). Posture held: documentation only — one agent — full text in `SKILL-AUDIT.closed.md` under its own `### F34` heading.

## Opened while taking F33

Filed 2026-09-04. A **fifth** placement on this page; the header says so. `F33`'s
note listed four other copies of the line-ending falsehood and left them, its
posture being one sentence in one skill. This is the one that matters.

- **F35** — `ship-pr` carries the same false line-ending clause, and the clause was never part of what it was told to say — Taken, 2026-09-04 (PR #693). Posture held: documentation only and subtractive — full text in `SKILL-AUDIT.closed.md` under its own `### F35` heading.

## Opened by F32's own CI run

Filed 2026-09-04. A **sixth** placement on this page. Six is past the point where
the arrangement helps anybody; consolidating them is worth its own finding and is
not attempted here.

- **F36** — `F32`'s path filter was justified with a number measured on the wrong machine — Taken, 2026-09-04 (PR #692). Posture held: reporting only, unchanged from — full text in `SKILL-AUDIT.closed.md` under its own `### F36` heading.

## Opened while closing out 2026-09-04

Filed 2026-09-04. A **seventh** placement, and `F39` below is about exactly that.

- **F37** — the memory copy of the line-ending rule, corrected outside the repo — Corrected 2026-09-04, and this finding is filed *with* its outcome because — full text in `SKILL-AUDIT.closed.md` under its own `### F37` heading.

- **F38** — a commentary heading is indistinguishable from a finding, and a scan of this file now counts 37 findings where there are 36 — Taken, 2026-09-04 (PR #695). Posture held: formatting only — three heading — full text in `SKILL-AUDIT.closed.md` under its own `### F38` heading.

- **F39** — the seven section placements on this page, and the case for leaving them — Closed without being taken, 2026-09-04 (PR #696), on Nate's word — and — full text in `SKILL-AUDIT.closed.md` under its own `### F39` heading.

- **F40** — `audit-menu`'s shape table describes this file's arrangement, and that cell is now wrong — Taken, 2026-09-04 (PR #698). Posture held: documentation only — one table cell — full text in `SKILL-AUDIT.closed.md` under its own `### F40` heading.

- **F41** — `book-extract-worker` conflates a page break with a slice boundary, and worked it out unaided — Taken, 2026-09-04 (PR #704). POSTURE WIDENED ON NATE'S EXPLICIT WORD, from — full text in `SKILL-AUDIT.closed.md` under its own `### F41` heading.

- **F42** — the shape table narrates arrangement in two rows, and arrangement is not what it is for — Taken, 2026-09-04 (PR #705). Posture held: documentation only and SUBTRACTIVE — full text in `SKILL-AUDIT.closed.md` under its own `### F42` heading.

- **F43** — both book agents say assuming `+1` is "wrong more often than right"; it is right for ten of sixteen books — Taken, 2026-09-04 (PR #707), as the SUBTRACTIVE variant on Nate's word. The — full text in `SKILL-AUDIT.closed.md` under its own `### F43` heading.

- **F44** — what a worker can learn about page offsets from the two sources it is told to read, and the three places that fails — Taken, 2026-09-11 (PR #957). Documentation only, three files, as the — full text in `SKILL-AUDIT.closed.md` under its own `### F44` heading.

# Counts

**Filed 21 findings and 8 proposals.** By layer, counting the layer a finding's
*fix* lands in — the count as filed, before `F22` and `F23`:

| layer | findings |
|---|---|
| 1 — the six skills and their references | 9 (`F1`–`F9`) |
| 2 — the `book-reconcile` subagent | 1 (`F10`) |
| 3 — `CLAUDE.md` | 1 (`F11`) |
| 4 — memory | 4 (`F15`–`F18`) |
| 5 — `settings.json` / `launch.json` | 3 (`F12`, `F13`, `F14`) |
| 6 — `docs/prompts/` | 1 (`F19`) |
| cross-layer | 2 (`F20`, `F21`) |

Eight findings are single-file edits of under ten lines (`F3`, `F4`, `F5`, `F7`,
`F13`, `F15`, `F16`, `F20`). Two propose no edit to any instruction file at all
(`F12` documents, `F9` may close). One is a new file (`F11`), one a new section
in a skill (`F17`), one a split (`F8`).

**Added 2026-09-02:** `F22` and `F23`, both in the test suite rather than in any
instruction layer, both opened by taking `F1`. The table above is the census as
filed and is left standing as one; it does not include them.

**Added 2026-09-04:** `F26`–`F28`, out of PR #676 rather than out of taking
anything on this menu. By the same rule they are not in the table either: `F26`
would land in layers 3 and 5, `F27` in layer 2, `F28` in neither — it proposes
running things rather than editing a file.

**Added later the same day:** `F29`–`F32`, opened by taking `F28`. Also not in
the table. Three of the four land outside this audit's six layers entirely —
`F29` reaches a GitHub setting and a workflow file, `F30` and `F31` are scripts
and a README. That is a fact about where the agents looked, not a defect in the
census.

**And `F33`–`F34`, opened while taking `F29` to `F32`.** These two land back
inside the original layers — `F33` in layer 1 (a skill) and `F34` in layer 2 (the
agents) — which is the first time since `F25` that a finding here is about the
surface this audit was scoped to. Still not added to the table above; it is the
census as filed.

Nothing else is taken until Nate names it.

---

## Opened by the subagent retrospective, 2026-09-22

A retrospective on the agent files in `.claude/agents/`, run 2026-09-22 from a
session started in `C:\Users\natha\Downloads`. Usage was measured from the
session transcripts under `C:\Users\natha\.claude\projects`, parsed as JSON and
**deduped by `tool_use` id** because a transcript logs the same call about
twice: 520 `.jsonl` files, 366 distinct `Task` calls, 2026-08-31 to 2026-09-20.
`book-extract-worker` 140, `audit-premise-auditor` 113, `book-reconcile` 56,
`claim-capability-verifier` 4, `claim-count-verifier` 3, `general-purpose` 38.
No call in that corpus returned `Agent type '<name>' not found`, and none came
back an error, so the junction and `F26`'s turn rule are both holding.

**Two of these are filed WITH their outcome, declined** — `F46` and `F48`.
Nate named the decision on 2026-09-22, when the plan they came from was agreed,
and they are written down rather than dropped so neither is re-derived.
`F39` is the precedent for a finding that exists to stop an idea coming back.

### F45 — neither book agent is told about the substituted-digit fault class, and both already open the key that measures it

`.claude/agents/book-extract-worker.md:56` and `.claude/agents/book-reconcile.md:107`
each open a section on what OCR does to this corpus — `I.S.P.` read as `LS.P.`,
`S.D.C.` as `$.D.C.`, `feet` as `fect`. Neither carries a line about the fault
class that swaps a digit for a letter shaped like it:
`grep -rni "cipher\|digit\|dpi\|render" .claude/agents/` returned no line at all,
2026-09-22, across all five agent files.

That fault class is documented — `.claude/skills/book-survey/SKILL.md:135-160`,
under `## 0. Does it have a text layer? Ask before you OCR` at `:39`. `:135`
records that the `corrupt_pages` detector cannot see it, because the wrong
glyphs are ordinary characters; `:140` records that it is therefore measured
into a separate manifest key, `substituted_digits`; `:157` records that on the
pages clipped at 600 dpi the damage was in the ink.

**Both agents are already sent to the file that carries that key.**
`book-extract-worker.md:34-37` and `book-reconcile.md:44-47` send the agent to
`scripts/books.json` or the cache's own `manifest.json` for `page_offset`.
`substituted_digits` is a sibling key in the same object: a `node -e` reading
`Object.keys` of `.cache/books/{bom,cb1,dag}/manifest.json` on 2026-09-22
printed `slug,source_pdf,pages,text_layer,cached_pages,cached_range,printed_pages,page_offset,welded_pages,corrupt_pages,substituted_digits`
for all three. It is a per-page map, not a flag — `new-west`'s holds 74 printed
pages, the largest ten hits on printed 151, read from
`.cache/books/new-west/manifest.json` the same day.

**The remedy is hand-carried into the prompt today, and the data scripts are
where it ended up.** `grep -rl "200 dpi render" apps/character-creator/db/`
returns 53 files, 2026-09-22 — a sentence about how the numbers were read,
written into the output because it was not in the agent that read them.

**Hand-carrying has already been missed once.**
`apps/character-creator/test/regression.mjs:1929-1936` carries a `CIPHER`
regular expression over stored rows, and its own comment at `:1932` says why
`LIKE` was not used. A check at the data layer fires after rows are written and
only on the shapes its pattern matches.

Neither book agent can load the skill that holds §0: `book-extract-worker.md:4`
and `book-reconcile.md:4` both read `tools: Read, Grep, Glob, Bash`. `F27` made
the `Skill` grant opt-in and per agent, and `.claude/agents/audit-premise-auditor.md:4`
is the one file that took it.

**Proposal:** grant `Skill` to both book agents, and add a short section to each
— read `substituted_digits` for the slug beside `page_offset`; where the slice
intersects a listed page, treat every number read off that page as suspect and
say so in the return; `book-survey` §0 owns which remedy applies, because a
render cures the text-layer encoding fault and does not cure ink damage.
**Posture: additive, two agent files, and bounded by `F43`'s subtractive
precedent** — not a second OCR-noise paragraph, but the one fault class the
first one does not name.

**Evidence:** the greps, the `node -e` over three manifests, and the
`regression.mjs` read, all 2026-09-22. Not measured: whether an edit to an
*existing* agent file takes effect inside the session that makes it. `F26`
measured that for a file that did not exist before, and the two are not the
same question.

**Confidence:** high that the gap is real — the grep is exhaustive over the five
files. Medium on the shape of the fix until one slice is run over a book whose
`substituted_digits` is populated, `new-west` being the largest, and the worker
is watched to see whether it flags a listed page without being told to.

**Ongoing cost:** two more paragraphs to keep true, in files that are edited
whenever the cache learns something anyway. No CI minute and no new script.

**Taken, 2026-09-22 (PR #1235). Posture held: additive, two agent files, bounded
by `F43`'s subtractive precedent.** `Skill` granted to both, one section added to
each, and the load of `book-survey` §0 made **conditional on a listed page**
rather than per call.

**Four things above are wrong or short, and `audit-premise-auditor` found all
four before a line was written.** The first would have shipped the defect:

- <!-- claim-ok: quoting the premise this note corrects --> *"the largest ten
  hits on printed 151"* — the keys of `substituted_digits` are **cache** pages.
  `scripts/ocr-book.py:483` says so in the function's own docstring, and
  `new-west`'s keys run to 224 against a `printed_pages` of 222, which is how a
  reader can tell. Cache 151 is printed 150. Both agents are briefed to cite the
  printed folio, so the section as filed would have put every warning one page
  off — the error the offset section above it exists to prevent. The shipped
  text says convert, and says how to tell.
- <!-- claim-ok: quoting the premise this note corrects --> *"74 printed
  pages"* — it is **75**, counted from `.cache/books/new-west/manifest.json` on
  2026-09-22. Two files already said 75: `.claude/skills/book-survey/SKILL.md:150`
  and `BOOK-INGEST-AUDIT.closed.md:6291`, the second under a heading whose whole
  subject is an earlier undercount of that same number.
- **`F27`'s decision was not named, and `audit-menu` requires that it be.** Its
  note at `SKILL-AUDIT.closed.md:2365-2372` scopes the `Skill` grant to
  `audit-premise-auditor` alone, on the argument that an agent firing once per
  finding can pay for a long skill and one running per slice at volume cannot.
  `book-survey` is 884 lines (`wc -l`, 2026-09-22) and `book-extract-worker` is
  the highest-volume agent on this machine. Argued past rather than ignored: the
  load is conditional, so the cost is paid on the slices that need a remedy and
  on none of the others.
- <!-- claim-ok: quoting the premise this note corrects --> *"Not measured:
  whether an edit to an existing agent file takes effect inside the session that
  makes it"* — there is a recorded answer, in the file this finding already
  quotes. `SKILL-AUDIT.closed.md:2384-2393`: a tools change is a change to an
  agent file, an agent file is not re-read until a turn boundary, and the swap
  was verified the next turn in PR #683. **So this change cannot be exercised by
  the session that wrote it**, which is why the verification below is the suites
  rather than a live slice.

**One thing the subject grep added to the work.** `BOOK-INGEST-AUDIT.closed.md`
→ *Read from the ink, 2026-09-10* records `+104x10+10` read off a page
`substituted_digits` does not list, and the memory note on the cipher records
that it can insert a glyph as well as swap one — `4O0ft` is printed 40ft. Both
agents are now told that an unlisted page is not a clean page, which the finding
as filed did not say and its wording invited.

**Opened while taking this: `F53`**, below — `book-survey` §0's closing
paragraph attributes the other detector's numbers to this one, in the section
this finding makes authoritative. Filed, not taken here.

**Owed: the first live slice.** For the turn-boundary reason above, nothing here
has been run through a worker. `new-west` carries the largest
`substituted_digits` on disk and is the book to run it on.

### F46 — `book-extract-worker`'s contract assumes a slice holds stat blocks, and a slice of prose falls outside it

**Filed with its outcome. Declined 2026-09-22 on Nate's word**, recorded so it
is not re-derived.

`grep -c "prose" .claude/agents/book-extract-worker.md` returns `0`, 2026-09-22.
Its return contract at `:89-103` asks for a row's name, its fields and its
printed folio, and closes at `:101` with **Do not pad** — a slice that holds
four rows returns four rows. A slice holding narrative rather than rows is not
described anywhere between `:89` and `:105`.

`SKILL-AUDIT.closed.md:2462` records the run that met this: `book-extract-worker`
on `ww` printed 44-45 returned **0 rows, and refused to invent any**. That is
the behaviour the contract exists to produce, reached without the contract
saying so.

**Proposal, as declined:** one clause in the return section saying that a slice
of prose returns zero rows and a sentence naming what the pages hold.
**Posture: documentation only, one agent file, one clause.**

**Why it is declined rather than taken:** the observed failure was a correct
answer. The cost of a clause is small and the cost of being wrong about it is
smaller still, but `F43` cut text from these same files on the argument that a
line that does not change an outcome is a line to lose. Nothing here changes an
outcome. **A proposal whose ongoing cost exceeds its impact should say so**, and
this one does.

**Evidence:** the `grep -c` and the read of `:89-105`, both 2026-09-22;
`SKILL-AUDIT.closed.md:2462` read the same day.

**Confidence:** high, and nothing would raise it — the question is a judgement
about value, not a fact that is unsettled.

**Ongoing cost:** none, declined.

### F47 — the two claim verifiers have no trigger, and seven calls in eighteen days is what that looks like

`claim-count-verifier` and `claim-capability-verifier` were added 2026-09-04
(`git log --date=short -- .claude/agents/`, read 2026-09-22, commit `bd49881a`).
Between them they have been spawned **seven times**: four on 2026-09-04, two on
2026-09-05, one on 2026-09-15, and none since — deduped `tool_use` ids from the
transcript corpus described at the head of this section.

`audit-premise-auditor` was added in the same batch and has 113 calls over the
same window. The difference is not quality. `take` names the premise auditor as
step 3 of a numbered procedure (`.claude/skills/take/SKILL.md:87`), so it fires
whenever a finding is taken. `.claude/skills/claim-audit/SKILL.md:203-204` routes
the two claim shapes to the two agents by name, and nothing in the repo says
**when** that routing runs.

The claims themselves have not stopped drifting. The shapes `claim-audit`
documents at `:195-199` — a count in prose, and *the app cannot do X* — are the
two the same file records as having cost a player seven skills on the Merc
Soldier and eight on the Robot Pilot.

**Proposal:** name both agents at the step of `ship-pr` where a change touches
documentation, class prose, or a `note` — the moment the drift is introduced —
so that lifting a limitation and sweeping for the sentence that described it are
one action rather than two. **Posture: one paragraph in one skill. No new gate,
no exit code, no check.** Do not merge the two agents: the sonnet/opus split is
the design, `claim-audit:203-204` states it, and `SKILL-AUDIT.closed.md:2459-2460`
holds the run that picked it.

**Evidence:** the transcript counts and the two skill reads, 2026-09-22; the
commit date from `git log`, same day.

**Confidence:** high that nothing fires them — seven calls is the measurement.
Medium that `ship-pr` is the right host; it would be raised by naming the last
three PRs that lifted a limitation and asking whether a sweep at that step would
have caught the sentence describing it.

**Ongoing cost:** one paragraph in a skill that is read on every PR, and the
sweep itself whenever it fires. The sweep is the cost being proposed, and it is
the point.

**Taken, 2026-09-22 (PR #1238). Posture held: one paragraph in one skill. No
new gate, no exit code, no check.** A bullet in `ship-pr` step 4, beside the one
that already makes a documentation obligation part of the same commit.

**Nate's word was asked for before this was built, and given.** The subject grep
found the ship-pr/ingestion retrospective of 2026-09-10, at which every proposal
was cancelled — among them *a limitation-claim warning* — with *do not
re-propose unprompted* recorded against it. This is not that. A warning is a
mechanical reader with an output; what shipped is a bullet in a procedure, with
no check, no exit code and nothing that can go red. The decision was put to him
on 2026-09-22 with its own words quoted, and he took this as filed.

**Three things `audit-premise-auditor` corrected before the branch existed:**

- <!-- claim-ok: quoting the premise this note corrects --> *"nothing in the
  repo says **when** that routing runs"* — overstated. `claim-audit`'s own
  section *The rule that makes it cheap* at `:221-224` says exactly when: when
  you lift a limitation, grep for the sentence that described it, in the same
  change. That skill's frontmatter and `claim-capability-verifier`'s own
  `description:` name the same moment. What was genuinely absent is narrower and
  still real: **no procedure invoked the agents**, and before this change
  `grep -n "claim-audit\|limitation" .claude/skills/ship-pr/SKILL.md` returned
  nothing (2026-09-22). So the work was naming the agents and the moment inside
  the procedure, not inventing a trigger — and the shipped bullet says the rule
  is not new.
- <!-- claim-ok: quoting the premise this note corrects --> *"`SKILL-AUDIT.closed.md:2459-2460`
  holds the run that picked it"* — **false, and the correction reaches past this
  finding.** Those two lines are `F28`'s table recording the first *exercise* of
  each agent; the models were already pinned when it ran. The only measured
  model comparison on disk is
  `.claude/skills/claim-audit/reference/negatives.md:113-137`, and it concludes
  **"The pin stays `sonnet`", on measurement rather than argument: `opus` cost
  roughly 2.5× for the same verdicts** — while
  `.claude/agents/claim-capability-verifier.md:5` reads `model: opus`,
  unchanged since it was written. **So the sonnet/opus split is an argument**
  (`claim-audit:204-205`, *low volume, high cost of error*) **and not a
  measurement**, and this note does not restate it as one. `F52` proposes
  re-running that eval; whether `negatives.md:136` pins this agent or a default
  is the unsettled question it should open with, rather than the citation this
  finding used.
- **`ship-pr` had no step keyed to documentation or class prose.** Step 4's
  bullets are keyed to layers, not to what a change says. The new bullet sits
  beside *"added a class or catalog rows: update the README's pinned counts in
  the same commit"*, which is the closest shape in the file — an obligation
  discharged inside the change rather than after it.

**Two smaller corrections, recorded and not repaired above:** the finding cites
`claim-audit:195-199` for the two claim shapes and they are at `:194-198`; and
both costs it names — seven skills on the Merc Soldier, eight on the Robot
Pilot — belong to the capability shape, not one to each.

**And the window.** The heading says *seven calls in eighteen days*, from a
corpus ending 2026-09-20 in a finding filed 2026-09-22. *None since 2026-09-15*
is a statement about that corpus, not about the two days after it.

### F48 — moving `take`'s subject grep inside the premise auditor would collapse the gate it is

**Filed with its outcome. Declined 2026-09-22 on Nate's word**, recorded so it
is not re-derived.

The idea: `.claude/skills/take/SKILL.md:62-85` has the caller grep every menu and
the memory directory for the finding's **subject**, and `:87` then spawns
`audit-premise-auditor`. Both steps are read-only, the agent already loads
`audit-menu`, and this file's own argument for the agent having no write tools is
that a rule enforced by the harness beats a rule someone drifts from. On that
argument the grep belongs inside the agent.

**It does not, and the skill says why at `:32`:** *the steps run in order, and
each one gates the next.* Step 2's output is meant to be judged before step 3
starts — `:79` requires every hit printed with its file and line, or the words
`no hits`, and the next lines ask which hits matter and why. The failure that
produced that sentence was the skill's own first live run on 2026-09-16, where
steps 2 and 3 fired alongside step 1 and step 1 then found the finding already
taken. Folding the grep into the agent makes the two one call again and removes
the point at which a person reads the hits.

**Proposal, as declined:** move the subject grep out of `take` step 2 and into
`audit-premise-auditor`, which would return the hits with its disagreements.
**Posture: one step moved between two files, nothing added.**

**Why it is declined:** the gate is the value, not the grep.

**Evidence:** `.claude/skills/take/SKILL.md:32`, `:62-85`, `:87`, read 2026-09-22.

**Confidence:** high. What would change it is a measured case where the grep was
run, its hits were printed, and nobody read them — which would make the gate
theatre rather than a gate.

**Ongoing cost:** none, declined.

### F49 — nothing lists what is open across the menus, and the compilation has been hand-built four times

Four `general-purpose` calls have asked one session to work out what is still
open across several menus at once — three on 2026-08-31 and one on 2026-09-12,
from the deduped transcript corpus described at the head of this section. Each
one re-wrote the method in its own words in the prompt, and the method is this
file's own: read each menu's status header, never grep an outcome note, take the
list of menus from the tree.

**Two scripts are adjacent to this and neither answers it.**
`scripts/menu-check.mjs:29` states outright that it cannot tell whether a claim
is true — it checks that a claim about another file carries a citation.
`scripts/audit-citations.mjs:8` states that it answers for `BOOK-INGEST-AUDIT`
and nothing else, and it is about which classes cite a finding. Read both
2026-09-22.

The half that cannot be mechanised is the half `audit-menu` insists on: a
status is prose under a heading, the wordings vary on purpose, and a mechanical
reader of them has been wrong in both directions. That is the shape an agent is
for — judgement over a bounded corpus, with no write tools and nothing to
decide.

**Proposal:** a new read-only agent, `open-findings-scout` —
`tools: Read, Grep, Glob, Bash, Skill`, loading `audit-menu` first. It takes the
list of menus from the tree, reads each one's status header and then the lines
under each finding's heading, and returns one line per finding it believes open,
each carrying the sentence it read the status from, plus the menus it could not
settle. It proposes nothing, edits nothing, and does not say what should be
taken. **Posture: a new agent file, read-only, no script, no check, and no index
file** — an index of the menus has been declined twice, `REPO-AUDIT` `G9` and
`META-AUDIT` `A1`, and this does not add one: it reads the tree each time and
writes nothing down.

**Evidence:** the four transcript calls, and the two script headers read
2026-09-22.

**Confidence:** high that the gap is real. Medium on the agent being the right
answer until it is run against a menu whose state is independently known — of
which this retrospective produced three.

**Ongoing cost:** one more agent file to keep true, which `F45` and `F51` both
touch anyway. It cannot be exercised in the session that writes it (`F26`).

**Taken, 2026-09-22 (PR #1237). Posture held: a new agent file, read-only, no
script, no check, and no index file.** `.claude/agents/open-findings-scout.md`,
`tools: Read, Grep, Glob, Bash, Skill`, loading `audit-menu` first — the same
tool set the three read-only agents already carry, so "read-only" means what it
means here: `Bash` present, no `Write` or `Edit`.

**Five things `audit-premise-auditor` corrected or added before the file was
written.** Four are in the shipped text:

- **`META-AUDIT` `A18` is a fifth instance of this compilation and the finding
  did not cite it.** Filed 2026-09-06, it read under every heading in all 21
  menus at `c54a794` — the only one of the five whose method was written down,
  and the only ground truth on disk. Two things in it are now in the agent file:
  that its own extractor **missed the wordings `WRITTEN` and `DECLINED`** and
  reported seven findings as having no outcome until a person read them, and
  that `A18` counts the index decline as **three**, not two.
- <!-- claim-ok: quoting the premise this note corrects --> *"Each one re-wrote
  the method in its own words … and the method is this file's own"* is true of
  **one** of the four calls. The three from 2026-08-31 were handed an explicit
  file list by the caller and say nothing about status headers. And the one that
  did derive the list told itself to read each header and **"trust it over your
  own scan"** — which `audit-menu` contradicts at `SKILL.md:511`, *a header MAY
  NOT carry a per-finding state*. The agent file reverses that instruction
  outright: a header is trusted for how to READ the file and never for whether a
  particular finding is open.
- <!-- claim-ok: quoting the premise this note corrects --> *"declined twice,
  `REPO-AUDIT` `G9` and `META-AUDIT` `A1`"* is loose. `G9` is a one-line aside
  inside a **rename** proposal that was itself closed without being taken, and
  `A1` says so: *"The deciding evidence is not in `G9`."* `A1` is the decline
  that carries reasoning, and its reasoning reaches a **stored** file — its own
  remedy is derivation, which is what this agent does. The agent file quotes
  `A1`'s remedy rather than the bare count.
- **The corpus is larger and stranger than "the menus".** The glob returned 41
  paths on 2026-09-22: 18 of them are `<MENU>.closed.md` records, the live menus
  have been mostly one-line pointers since 2026-09-16, the glob misses
  `SETUP-v2-CHANGES.md` and returns a brief that is not a menu, and two menus
  keep twenty items in shapes a heading scan cannot see. All of it is in the
  file, because an agent that does not know it inherits the twenty invisible
  items.

**One thing left unsettled, and it is this finding's own Confidence line.**
<!-- claim-ok: quoting the premise this note corrects --> It says the agent
should be run against *"a menu whose state is independently known — of which
this retrospective produced three"*, and the retrospective section names no
three. `META-AUDIT` `A18` is the better-specified ground truth and is what the
first run should be checked against.

**What fires it: somebody asking, and nothing else.** `F47`, two headings above,
measures what an agent with no trigger gets — seven calls in eighteen days. That
is accepted here rather than fixed: a state reading that runs on a schedule and
is written down is an index with extra steps, which is the artefact `A1`
declined.

**Verified by the check that landed an hour earlier.** `F51`'s `Agents stay
true` section reads this file and passes on it — frontmatter parsed, `name`
matching the filename, `tools` well formed. **The agent itself cannot be spawned
by the session that wrote it** (`F26`), so the first real run is owed, and
`A18`'s list is what it should be scored against.

### F50 — parallel worktree work has no checked-in contract, and the briefs it ran on are gone

On 2026-09-17 a single session spawned **23** `general-purpose` calls, of which
**16** told the agent to follow `class-brief.md` or `gear-brief.md` and **6**
named a git worktree to implement in — deduped `tool_use` ids from the corpus
at the head of this section. Both briefs were written into that session's
scratchpad under
`C:\Users\natha\AppData\Local\Temp\claude\C--Users-natha-Downloads\`, which is
per-session. The rules they carried — spell every path out, do not merge, the
environment a worktree needs — were re-derived for that session and did not
survive it.

The known failure of that pattern is recorded outside this repo: an agent given
an unbounded search ran a whole-disk `find` that outlived it. A standing
contract is what an agent file is, and a per-task slice is what a prompt is; on
2026-09-17 both were in the prompt.

**Proposal:** write the standing half down as a section of the `worktree` skill
— every path absolute, no whole-tree search, the two environment variables a
worktree needs, and an explicit refusal to merge, push to `main` or write to D1
— so the next parallel campaign supplies only the slice. **Posture: a section in
an existing skill. NOT a new agent, and deliberately.** A write-capable agent is
the first crack in the property every other agent here leans on, which is that
it has no write tools and therefore cannot drift into implementing; one campaign
is one data point; and an agent file can no more refuse a whole-disk `find` than
a skill section can. **Promote it to an agent when a second parallel campaign
needs it**, and note then that `instruction-paths.mjs:51` pins every absolute
path an agent file names.

**Evidence:** the transcript counts, 2026-09-22; the scratchpad path from the
prompts themselves, same day.

**Confidence:** high on the measurement. Medium on the posture — a second
campaign is what would settle whether the skill section is read when it matters,
and that is exactly the evidence the promotion would wait for.

**Ongoing cost:** a section in a skill that is already read before any worktree
work.

**Taken, 2026-09-22 (PR #1239). Posture held: a section in an existing skill,
NOT a new agent.** `.claude/skills/worktree/SKILL.md` → *Briefing a worker you
spawn into one*. The promotion to an agent waits for a second campaign, as the
proposal says.

**Opened in the same PR and not taken: `F54`**, the sixth `guard-bash.sh` rule.
Nate's word, 2026-09-22, on the evidence below — the instruction half ships here
and the control that does not depend on being read is filed separately.

**Three premises do not hold, and `audit-premise-auditor` settled all three
before the branch existed:**

- <!-- claim-ok: quoting the premise this note corrects --> **"the briefs it ran
  on are gone" is false.** `class-brief.md`, `gear-brief.md` and
  `morphus-extract-brief.md` are still in that session's scratchpad, which still
  holds 305 files, verified 2026-09-22. The body's narrower claim holds exactly
  — they are per-session, checked in nowhere, and were re-derived rather than
  inherited — but the heading overstates it. **That widens the work in the
  useful direction:** the standing rules did not have to be reconstructed from
  transcripts, and two of them came straight out of those files, including
  *never delete a file you did not create*, which the finding never names.
- <!-- claim-ok: quoting the premise this note corrects --> **"6 named a git
  worktree" is 5.** Five distinct worktrees were named — `nates-apps-morphus`
  twice, `nates-apps-generator`, `nates-apps-ladders`, `nates-apps-formplay`.
  The other two figures reproduce exactly: 23 calls on 2026-09-17, 16 following
  one of the two briefs. No counting rule reproduces 6.
- **`instruction-paths.mjs` pins skills as well as agents** — its `ROOTS` array
  names `.claude/skills` beside `.claude/agents`, so the deferral in the
  proposal (*"note then that it pins every absolute path an agent file names"*)
  was already due here. Every absolute path in the new section had to exist or
  be templated; the section names none, which is why.

**And two things about the target file the finding did not know:**

- **The `worktree` skill already carries both environment variables**, with what
  broke without them, at *Making one*. The new section points at it rather than
  repeating the values, because a second copy is a second thing to keep true.
- **It also carries *Merging from a worktree*, which is written for the session
  that owns the tree.** A spawned worker needs the opposite instruction, so the
  new section says the refusals are the worker's and names the contrast
  explicitly. Without that the file would say both merge-from-here and
  never-merge.

**One clause in the finding's list was never in the prompts.** All five worktree
prompts carried the environment variables, *do not push*, *do not open a PR*,
*do not apply anything to the remote database*, and a note that `git add -A` is
refused by a hook. **None said *do not merge*, and none bounded searching.** So
the no-whole-tree-search rule is not something the campaign had and lost — it is
new, and `F54` is why it is here as a reminder rather than as a control.

**A correction to this section's own method line, recorded rather than edited**
— audit files are records. The lead at the head of
`## Opened by the subagent retrospective, 2026-09-22` says *366 distinct `Task`
calls*. The tool-use blocks in the transcripts are named **`Agent`**, not
`Task`; a re-runner matching on `Task` gets **zero**. The per-agent figures were
derived by matching `input.subagent_type` rather than the block name and are
unaffected — `general-purpose` 38 reproduces exactly — but the name in that
sentence would cost the next reader a round trip.

### F51 — no check reads the agent files, so a malformed one fails at spawn time

`apps/character-creator/test/checks/instruction-paths.mjs:51` lists
`.claude/agents` among its roots, so the absolute paths inside an agent file are
pinned. `apps/character-creator/test/checks/machine-instructions.mjs:89` reads
the directory to enforce the rule that the machine's own `CLAUDE.md` names no
agent. Neither opens an agent file to ask whether it is well formed, and a
`grep -rn "agents" apps/character-creator/test/checks/*.mjs` on 2026-09-22
returned those two files and no third.

So a `tools:` line naming a tool that does not exist, a `name:` that disagrees
with the filename, or frontmatter that does not parse, all reach the harness
rather than the suite — and the harness reports them mid-task, in the session
that needed the agent.

**Proposal:** add a block to `apps/character-creator/test/checks/environment.mjs`
asserting, for every file in `.claude/agents/`: that the frontmatter parses,
that `name` and `description` are present, that `name` matches the filename, and
that every entry in `tools:` is a known tool name. **Derive the list from the
directory and assert no count** — the same shape the same file already uses for
the checks modules at `:501-514`, which was written precisely so a list cannot
go stale. **Posture: fail, not warn** — a malformed agent file fails at spawn
anyway, so this is the same failure moved earlier, and the check is
deterministic.

**Evidence:** the two reads and the `grep -rn`, all 2026-09-22.

**Confidence:** high on the gap. Medium on the tool-name list, which has to come
from somewhere and is the one part of this check that could go stale; that would
be settled by deciding whether it reads a fixed list or only asserts the field's
shape.

**Ongoing cost:** one check block in a suite that already runs on every PR, and
whatever the tool-name list costs to keep — which is the argument for keeping
that part shallow.

**Taken, 2026-09-22 (PR #1236). Posture held: fail, not warn; derived from the
directory and asserting no count.** Four checks in a new `Agents stay true`
section of `environment.mjs`, taking `smoke.mjs` from 2759 checks in 165
sections to 2764 in 166.

**Each check was proved by making it fail first**, with a probe file carrying
one fault at a time and removed afterwards: no frontmatter, a `name` that
disagrees with the filename, `tools: Read, Grep,,`, and frontmatter without a
`description`. Each failed the one check it should and no other. A check that
has only ever passed proves nothing.

**Three corrections from `audit-premise-auditor` before the branch existed:**

- **This module already does it for skills**, at `:592-594` and `:615-616` — a
  regex over the raw text, directory-derived, no count asserted — and this
  finding did not say so. `audit-menu` requires that an existing decision be
  named. What shipped delivers more than copying that block: it parses the
  frontmatter rather than pattern-matching it, and it checks `name` against the
  filename, which the skills version does not do. The skills block is untouched.
- **The `tools:` roster had nothing to rest on.** No list of valid tool names
  exists anywhere in this repo; the only tool names on disk are the ones these
  five files already use. Shipped as **shape only**, which is the fallback this
  finding's own Confidence line named. A hardcoded roster of another system's
  vocabulary is the staleness this module refuses two blocks above.
- <!-- claim-ok: quoting the premise this note corrects --> The finding says its
  grep *"returned those two files and no third"*. Re-run 2026-09-22 it returns
  **three**: the third is `environment.mjs:504`, a comment naming the directory
  rather than a read of it. The absence claim it supports holds — nothing in the
  repo opened an agent file.

**One premise left unsettled, and it is this finding's stated reason for
`fail`.** <!-- claim-ok: quoting the premise this note corrects --> *"A
malformed agent file fails at spawn anyway, so this is the same failure moved
earlier"* quotes no command, and nothing in the repo can confirm or refute it —
it is **inferred, not measured**. The posture is unchanged because the second
argument stands alone: the check is deterministic and text-only, so there is no
flake for a gate to cost anyone.

**Routing, recorded because the rule points the other way.** `test-suite` →
*Where a new check goes* sends a fact about a file to `smoke.mjs` or a module
under `checks/`, and reserves `environment.mjs` for facts about the environment,
which is where the wrangler calls and nearly all the wall clock live. This went
to `environment.mjs` as the finding asks, on the ground that its sibling check
sits forty lines above it and splitting one instruction surface across two
modules costs more than the tidiness. Taken as written; the tension is real and
is written here rather than resolved quietly.

### F52 — the model choices and the scoring fixture have not been re-run since the day they were written

`.claude/skills/claim-audit/reference/negatives.md:113` records the run that
scored both claim agents on 2026-09-04. `SKILL-AUDIT.closed.md:2459-2462` records
the runs that picked the models the same day. Nothing has re-run either since,
and the transcripts show **313** invocations of the five agents between
2026-09-04 and 2026-09-20 — the evidence the original choice did not have.

The specific question worth asking: `book-reconcile` is a second reader whose
misses are silent, and `.claude/agents/book-reconcile.md:5` reads `model: sonnet`.

**Proposal:** re-run the eval that picked the models and re-score the two claim
agents against `reference/negatives.md`, and append the result beside the
2026-09-04 run rather than editing it — the fixture is a record. **Do not hand
the fixture to the agent being scored**, which `claim-audit:215` already
requires. **Posture: verification only. Change nothing unless a run shows
something**, which is the posture `F28` took for the same reason.

And check in the measurement: `scripts/agent-usage.mjs`, reading the transcripts
under `C:\Users\natha\.claude\projects` and deduping by `tool_use` id. That
measurement has now been hand-built twice — once on 2026-09-11 by a
`general-purpose` call, once on 2026-09-22 by this retrospective — and the
dedupe rule is the part that is re-derived wrong, because a transcript logs the
same call about twice. **Posture for that half: a script, no check, no exit
code, no CI.**

**Evidence:** the two records read 2026-09-22, and the transcript counts from the
corpus at the head of this section.

**Confidence:** high that neither has been re-run — both files carry their run
date. Low on what a re-run would find, which is the reason to run it.

**Ongoing cost:** a script that reads machine-local files and is run by hand.
Nothing in CI, and nothing that can go red.

**Taken, 2026-09-22 (PR #1240). Posture held: verification only — nothing was
re-run and no agent's behaviour changed.** Two things shipped:
`scripts/agent-usage.mjs`, and a dated note beside the 2026-09-04 run.

**The finding asked for a re-run; the premise audit found what a re-run was not
needed for.** `bd49881a`, the commit that shipped the claim verifiers, says in
its own body that the `opus` pin *"was provisional pending a run"*, reports 9/9
on both models, and concludes *"So `sonnet`."* `negatives.md:136` says the same.
**`.claude/agents/claim-capability-verifier.md:5` has read `model: opus` since
that commit and its `model:` line has never been edited** — eighteen days of a
shipped file contradicting the run recorded beside it, and no re-run was needed
to see it.

**Nate's word, 2026-09-22: leave it at `opus` and resolve it in the record.**
The run found no difference in verdicts, so what it settles is cost, on an agent
spawned four times in those eighteen days; the same section lists four things
`opus` did better, and the shape this agent exists for is the one that shipped a
class seven skills short. The note is beside the run, the run is not edited, and
the pin is now a decision rather than an oversight.

**Five corrections from `audit-premise-auditor`:**

- <!-- claim-ok: quoting the premise this note corrects --> *"records the run
  that scored both claim agents"* — it scored **one method at two models**,
  through throwaway `zz-eval-blind` agent types, because a model comes from
  frontmatter and a shipped agent file cannot be run at two of them. `F28`
  already said the 9/9 describes *"the method, not the agent file"*.
  **`claim-count-verifier` has never been scored by anything.**
- <!-- claim-ok: quoting the premise this note corrects --> The
  `SKILL-AUDIT.closed.md:2459-2462` citation is `F28`'s first-**exercise**
  table. **`F47`'s outcome note on this menu had corrected that exact citation
  hours before this finding was filed**, and handed this finding the right
  question; this finding used a two-line-wider version of the same wrong
  citation anyway. That is worth more than the correction: a citation naming a
  file and a line reads as verified, and `menu-check` — which exists for claims
  about other files — passes it, because it checks that a citation is *present*.
- <!-- claim-ok: quoting the premise this note corrects --> *"a transcript logs
  the same call about twice"* — **false for tool-use blocks**: 383 raw against
  358 distinct in this window, **1.07×**. The ~1.9× belongs to assistant `usage`
  records keyed by `message.id`, and that key here would drop every second call
  in a turn that spawned two. Both rules are in the script's header.
- **Hand-built three times, not twice** — `EFFICIENCY-AUDIT` parsed the same
  corpus by script on 2026-08-25, using the key that does not work for counting
  agent calls.
- **313 is exact, and two of its parts are not what this section's lead says.**
  `book-reconcile` is **53** in the window; the 56 in the lead is the whole
  corpus from 2026-08-31. And `book-reconcile` was written **2026-08-22**, a
  month before the eval, so *"the day they were written"* is not one day for the
  agent this finding singles out.

**One of six model assignments has a measurement behind it**, and it is the one
that disagrees with its file. The other five are argument, and
`open-findings-scout` — added earlier today by `F49` — is a sixth agent this
finding's *five agents* framing does not reach.

**One fixture figure has moved and is recorded rather than edited:**
`negatives.md:85` says `Weapon Proficiencies` holds 34 rows; production returned
**38** on 2026-09-22. No verdict in the fixture changes, and the answer key was
re-verified against production while checking this.

**What the script does not do**, so nobody assumes otherwise: no exit code, no
check, no workflow. It reads a machine-local transcript directory that is absent
on a runner, where it says so and exits 0. It counts spawns, not cost.

### F53 — `book-survey` §0 gives the visible-glyph detector's numbers to the digit detector, in the passage explaining that the two need opposite remedies

**Opened 2026-09-22 while taking `F45`**, by `audit-premise-auditor`, in the
section `F45` makes authoritative for both book agents.

`.claude/skills/book-survey/SKILL.md:167-170` closes the `substituted_digits`
subsection this way, read 2026-09-22: `bom` printed 84 is 30 hits, a wholly
scrambled page *"which this detector rediscovers on its own"*, and `bom` printed
116 and 310 turn a `1` into a backslash inside spell durations and damage dice.

**Those are the other detector's numbers.** Read from
`.cache/books/bom/manifest.json` with node on 2026-09-22, at `page_offset` 1:

| printed | cache | `corrupt_pages` | `substituted_digits` |
|---|---|---|---|
| 84 | 85 | **30** | no key |
| 116 | 117 | **3** | no key |
| 310 | 311 | **4** | 2 |

`bom`'s largest single `substituted_digits` entry anywhere in the book is **9**,
at cache 80. A `1` set as a backslash is the visible kind by definition — a
character a clean text layer never makes, which is precisely what
`corrupt_pages` looks for — and the passage cites `BOOK-INGEST-AUDIT.md` `F36`,
which is the visible-glyph finding, four lines after the subsection's own
citation of `F53` there.

The cost is not the arithmetic. `:139-141` of that file says the two faults are
a separate key **on purpose**, because they need opposite remedies and folding
them together would tell a reader to render a page a render cannot fix. The
closing paragraph then hands one detector's evidence to the other, in the
subsection a worker is now sent to for the remedy.

**Proposal:** move the three-book paragraph into the `corrupt_pages` material it
describes, or delete it; and where it names pages, say whether they are printed
or cache — it states folios while the maps beside it are keyed by cache page,
which is `F45`'s first correction one level up. **Posture: documentation only,
one skill file, one paragraph. Which of move-or-delete is the decision**, and
`F43`'s precedent in these files is that deleting beats relocating when the
sentence changes no outcome.

**Evidence:** the node read of the `bom` manifest and the read of `:167-170`,
both 2026-09-22.

**Confidence:** high that the numbers belong to `corrupt_pages` — the other map
has no key for two of the three pages and nothing near 30 anywhere. Medium on
the repair, which is Nate's to pick.

**Ongoing cost:** none beyond the edit. One paragraph either moves or goes.

**Taken, 2026-09-22 (PR #1243). Posture held: documentation only, one skill
file, one paragraph** — but **not** either of the two repairs this finding
offered. Nate's word, 2026-09-22: **keep the instruction, replace the evidence,
and say which numbering the maps use.** Move-and-delete were the two options
filed; this is a third inside the same posture.

**Why the instruction stayed.** `audit-premise-auditor` settled the point the
choice turns on: *worth running on a book you did not cache today* is true of
**this** detector, not only of the visible-glyph one.
`scripts/ocr-book.py:565-599` computes `welded_pages`, `corrupt_pages` and
`substituted_digits` in the manifest-write path, **outside** the page loop that
skips anything already cached, with a comment saying why. So a re-run on a
complete cache costs seconds and rewrites only the manifest — and since the key
did not exist before 2026-09-10, that re-run is the only way any older cache
came to carry it. Every text-layer cache on disk now does. Deleting the
paragraph would have removed a true instruction along with the wrong evidence.

**The evidence that replaced it, and the number that was deliberately not
used.** `bom`'s `substituted_digits` holds **116 pages**, which is the largest of
the three books — and the paragraph being rewritten already contains
*"printed 116"* as a folio. Using 116 there would have given one number three
meanings in one paragraph. The replacement uses the largest single entry
instead: **nine hits at cache 80, which is printed 79**, re-derived from
`.cache/books/bom/manifest.json` on 2026-09-22.

**The finding's clause 2 was half-satisfied, and the real gap was next to it.**
The paragraph already labelled its pages *printed*. What §0 never said anywhere
in `:39-171` is that the manifest maps are keyed by **cache** page — that
arithmetic lives 200 lines below, under *Read the offset from the registry*. A
worker arrives at §0 from an agent file that told it the keys are cache pages
(`book-extract-worker.md`, shipped this morning by `F45`) and met a passage
quoting folios with no statement of which numbering §0's own maps use. The
replacement says it outright.

**Three premises confirmed rather than assumed**, each re-derived from the
manifests rather than taken from this finding: `bom` `page_offset` 1, cache 85 =
30 hits, cache 117 = 3, cache 311 = 4 in `corrupt_pages`, with
`substituted_digits` holding **no key** at 85 or 117 and 2 at 311; and nothing in
that map within three times of 30.

**Where the sentence came from, and what was deliberately left alone.** It is a
near-verbatim lift from `BOOK-INGEST-AUDIT.closed.md:4525-4528`, inside `F36` —
the visible-glyph finding — which is why its trailing citation was `F36` while
the subsection it sits in cites `BOOK-INGEST-AUDIT` `F53`. **That origin is a
measurement inside a record and is not edited**, per `audit-menu` → *Audit files
are RECORDS*. The only copy that was wrong is the one that had been moved under
the wrong detector, and it is the one that changed.

**Two citation corrections, recorded and not repaired:** the *separate key on
purpose* sentence runs `:140-142`, not the `:139-141` this finding gives; and
`:165` to `:170` is five lines, not the four it says. `:167-170` for the
paragraph itself was exact.

### F54 — the control for a whole-disk search is a sixth `guard-bash.sh` rule, and the instruction half has already been measured as insufficient

**Opened 2026-09-22 while taking `F50`, on Nate's word**, and filed rather than
taken so the decision to build it stays separate.

`.claude/hooks/guard-bash.sh` carries five rules — `git add -A`, `sed -i` inside
the repo, a flagless `q.mjs`/`d1-apply.mjs`, `gh pr merge` sharing a line with a
pipe or a chain, and a backtick in `git commit -m`. **None is about a search
root.** Read 2026-09-22.

**The shape recurs and it is not one incident.** Measured across the session
transcripts on 2026-09-22, deduped by tool-use id: **21 distinct Bash calls
searching from a filesystem root, on 2026-09-16, 2026-09-18 and 2026-09-19, and
every one of them from a spawned worker rather than from a main session.**

**The hook already reaches those workers**, which is the premise a rule aimed at
them depends on: the same corpus carries 42 `guard-bash:` refusals, **19 of them
in subagent transcripts**, five within seconds of the 2026-09-17 worktree spawns.
A sixth rule would have fired on the workers `F50` is about.

**The instruction half has been tried and measured.** The memory note on this
records that a brief saying *"NEVER search from / or C:\\"*, with the full path
given, did not stop two workers from searching the root for fifty minutes, and
names the remedy in its own words: *"a PreToolUse hook refusing `find /` would
be the shape that cannot go wrong - not built yet."* `F50` ships the instruction
half today and says so; this is the half that does not depend on being read.

**Proposal:** a sixth rule in `guard-bash.sh` refusing a search whose root is a
filesystem or drive root — `find /`, `find C:\\`, `find /c/` and the same shapes
with `-name`/`-iname` — with a refusal message that names the incident and tells
the caller to search the path it was given. **Posture: refuse, like the other
five.** The hook's posture is refusal with exit 2 and it fails closed; a
whole-disk search has no legitimate use in this repo, and the caller that wants
one can say which directory it means.

**One thing to settle while taking it, because two sources disagree.**
`windows-shell` records the hook as project-scoped — registered in this repo's
`.claude/settings.json`, and absent from the directory the book work runs in.
The measurement above puts 41 of the 42 refusals in sessions whose recorded
working directory is `Downloads`. Both cannot be the whole story, and which one
is true decides whether this rule protects the sessions that produced the 21
calls. **Establish that before writing the rule**, by provoking a refusal from a
session started outside the repo rather than by reasoning from either file.

**Evidence:** the read of `.claude/hooks/guard-bash.sh` and the transcript scan,
both 2026-09-22, the scan reported by `audit-premise-auditor` and its method —
dedupe by tool-use id — stated with it.

**Confidence:** high that the shape recurs and that the hook reaches spawned
workers; both are counted rather than inferred. **Medium on the matcher**, which
is where this can fail quietly: a search root has more spellings on this machine
than any of the five existing rules have to handle, and a rule that misses `C:\\`
or `/c/` is a rule that does not fire. What would raise it: write the matcher
against the 21 recorded calls and check it refuses every one.

**Ongoing cost:** one more rule in a file that fails closed, and whatever a false
refusal costs someone who meant the search. No CI minute, no new file.

**Taken, 2026-09-22 (PR #1247). Posture held: refuse, like the other five** —
exit 2, fails closed, no exception path. Rule 6 in `guard-bash.sh`.

**The count is 18, not 21.** Twenty-one is exactly what a naive `find /` matcher
returns over the corpus; the three extras are two scans of the transcripts and
**the memory-note write that accidentally ran one**. Re-derived over all 47,455
distinct Bash calls: a command-position matcher returns **18, with zero extras**.
`.claude/skills/worktree/SKILL.md`, which shipped the figure as 21 this morning
in PR #1239, is corrected in this PR — it cites this finding two lines below.

**The premise this finding leans on was dead, and is now true for a different
reason.** <!-- claim-ok: quoting the premise this note corrects --> It argued
*"the hook already reaches those workers"* from *"42 `guard-bash:` refusals, 19
of them in subagent transcripts"*. `F55` retracted that count — those were
results *containing* the string, and only **one** real refusal existed before
today. The conclusion holds now because `F55` registered the hook at user level,
and it was demonstrated live: the premise auditor's own `echo git add -A` was
refused mid-audit. **But *"a sixth rule would have fired on the workers `F50` is
about"* is false as written** — all 18 ran on 09-16/18/19, when the hook was
registered only in the repo and no worker session started there.

**A nineteenth search really ran, from a MAIN session, and it changed the
matcher.** On 2026-09-19 somebody wrote the memory note about the first
eighteen through `node -e "…"` with backticks in the text; the shell substituted
them and started a stray. The note records it first-hand. It is the **only**
command in the corpus that distinguishes the two candidate matchers, so **a
backtick counts as a command position** — and that decision is here rather than
inherited.

**The spelling worry in this finding's Confidence line was not borne out.**
<!-- claim-ok: quoting the premise this note corrects --> It warned that *"a
rule that misses `C:\` or `/c/` is a rule that does not fire"*. All **20 root
occurrences across the 18 commands are the bare unquoted `/`** — zero `C:\`,
zero `/c/`, zero `/cygdrive/c/`, checked against the whole corpus. The drive
spellings are in the rule as defence in depth and are not what makes it fire.

**Scope stays at `find`, on measurement.** No `grep -r /`, `ls -R /`, `dir /s`
or `Get-ChildItem -Recurse` from a drive root has **ever** run in this corpus.
Widening would have been speculative.

**Why this rule is narrower than the other five, deliberately.** It fires at a
**command position** only. `F57` established that the rules read prose, and this
rule's trigger words are its own subject: its documentation, the memory note it
came from, and this very paragraph are full of the phrase. A permissive matcher
here would refuse the act of writing about it — which is exactly how the
nineteenth search happened.

**Proved against the eighteen commands as they were actually issued**, plus nine
negatives: **18 refused, 9 allowed, nothing else touched**, and the backtick
form refused. The first attempt scored 13/18 — **against a fixture that had been
flattened to single lines**, which destroyed the newlines that make a `find` a
command position. The fixture was re-extracted with the text intact before the
rule was trusted; a matcher scored against a mangled fixture would have been
tuned to the mangling.

**Two things found while taking this, and neither is filed here.**
`.claude/skills/windows-shell/SKILL.md:39-46` still says the hook *"is
project-scoped, which means the session that needs it most does not have it"* —
false since `F55`, and `F56` as filed covers only the refusal-prefix sentence
above it. And **both registrations are live**, the repo's and the user-level
one, so a repo-rooted session runs the hook twice. Same verdict either way, but
a double refusal is not a bug when it appears.

### F55 — the `guard-bash` hook has never refused a command, because it is registered where sessions do not start

**Opened 2026-09-22 on Nate's word**, while establishing the one thing `F54`
says to settle before its rule is written.

`.claude/settings.json` registers `.claude/hooks/guard-bash.sh` as a `PreToolUse`
hook on `Bash`, and `windows-shell` opens *"Five of these are a hook now, and it
fires in one directory"*. Measured 2026-09-22: **it has fired in none.**

- **Zero refusals across every transcript on this machine.** A refusal is a tool
  result whose text begins `guard-bash:` — `refuse()` at
  `.claude/hooks/guard-bash.sh:40-43` prints exactly that to stderr and exits 2.
  Scanning every `.jsonl` file under `C:\Users\natha\.claude\projects` for a
  tool result of that shape returns **0**. The string itself appears **343**
  times in the same scan, every one prose: the skill describing the hook, the script being read,
  an agent quoting one of them.
- **Two live probes from a session rooted in `Downloads`**, which is where the
  work runs. `sed -i` on a relative path inside the repo: **not refused** — and
  rule 2's matcher counts a relative path as in-repo explicitly
  (`guard-bash.sh:112`, `*) in_repo=1 ;;   # relative: resolves against the
  repo`). `git add -A`: **not refused**.

**The cause is where it is registered.** Project settings are read from the
directory a session starts in. Sessions here start in `Downloads`, whose
`.claude\settings.local.json` declares permissions and no hooks;
`C:\Users\natha\.claude\settings.json` declares no hooks either. The transcript
keys measure the split: **150** sessions directly under the `Downloads` key -
520 counting subagents - against **6** under the repo's.

**`windows-shell` half-says this and names the wrong directory.** Its own
paragraph — *"It is project-scoped, which means the session that needs it most
does not have it"* — points at `C:\Users\natha\Projects\workshop`. The directory
without the hook is the one almost every session starts in.

**This also corrects a measurement this menu carries.** `F50`'s premise audit
reported *"42 tool results in the corpus carry a `guard-bash:` refusal; 19 are
sidechains"*, and `F54` was filed on it. Those 42 are tool results **containing**
the string — file reads of `CLAUDE.md` and of memory notes. None is a refusal.

**Proposal:** make the hook reachable from where sessions start, in two parts,
the second being the trap. **One:** register it in the settings a
`Downloads`-rooted session reads. **Two:** make `guard-bash.sh` resolve the repo
**independently of `CLAUDE_PROJECT_DIR`**, which is what it uses today to decide
what *under the repo* means — registered from `Downloads`, rules 1 and 2 would
treat `Downloads` as the repo while rules 4 and 5 would work unchanged.
**Posture: the hook keeps its refusal posture — exit 2, fails closed — and gains
no new rule here.** `F54`'s sixth rule is a separate decision that depends on
this one and is worth nothing before it.

**Prove it by making it fail.** The `sed -i` probe above is the test: from a
session started outside the repo it must be refused afterwards, and today it is
not.

**Evidence:** the transcript scan and both probes, 2026-09-22; reads of
`.claude/settings.json`, `C:\Users\natha\Downloads\.claude\settings.local.json`,
`C:\Users\natha\.claude\settings.json` and `guard-bash.sh:40-43`, `:100-118`.

**Confidence:** high that it has never fired — a corpus scan and two live probes
agree, by different methods. Medium on the fix: which directories deserve the
hook is a judgement, and the repo-path resolution has to be written and proved
rather than reasoned about.

**Ongoing cost:** a hook that really runs on every `Bash` call in the directory
the work happens in. That is the point and it is also the cost — five rules that
have never fired will start firing, and a false refusal will be felt at once.

**Taken, 2026-09-22 (PR #1245). Posture held: the hook keeps its refusal
posture — exit 2, fails closed — and gains no new rule.** Registered at user
level with an absolute path, and `guard-bash.sh` now derives the repo from its
own location and resolves a relative target against the envelope's `cwd`.

**This finding's headline is false and `audit-premise-auditor` caught it.**
<!-- claim-ok: quoting the premise this note corrects --> *"the `guard-bash`
hook has never refused a command"*, and *"Zero refusals across every
transcript"*. **It refused once** — `2026-09-16T16:15:51Z`, in the `nates-apps`
project key, `is_error: true`, `git add -A`. Re-derived independently on
2026-09-22 by matching the wrapper prefix instead: exactly one genuine refusal,
plus one session quoting it four seconds later and four hits that are this
session's own scan output.

**The cause of the miss is this finding's own definition of a refusal**, and it
is the part worth keeping. It said a refusal is a tool result **beginning**
`guard-bash:`. It never does: Claude Code wraps the hook's stderr, so the result
begins `PreToolUse:Bash hook error: [<the configured command>]: ` and the
reason sits in the middle. **A scan anchored on `^guard-bash:` returns zero by
construction, whatever the truth is** — which is how a finding built on a
corpus-wide count came to assert the one thing that was not true.

**What survives, and it is the whole mechanism.** The single refusal was the
hook's own self-test on the day it shipped, from the 6-session repo key, four
seconds before a `Downloads`-rooted session verified it by hand. **No real work
has ever been guarded**, because the work runs where the hook was not
registered. That is the finding, and it stands.

**Three more corrections, all of which narrowed the work:**

- **Only rule 2 depended on the repo path**, not rules 1 and 2 as filed. The
  derivation lived *inside* rule 2's `if` block; rules 1, 3, 4 and 5 are pure
  regex matches on the command text. Rule 3 was in neither group of the
  finding's sentence. So part two was a one-rule change.
- **Rule 2 misfired in BOTH directions** from a foreign root, which the finding
  only half-said: it **missed** real absolute repo paths, and it refused every
  relative `sed -i` anywhere on the machine.
- **The envelope carries `cwd`, as a required field** — read out of the CLI's
  own schema rather than guessed. That turned the fix from conservative to
  correct: `$0` says where the repo is, `cwd` says where a relative path lands,
  and rule 2 needs both. The finding proposed only the first.

**And two corrections to what I believed when scoping it.** The ~258-entry
`settings.local.json` that `M11` tells you to leave alone is at
`C:\Users\natha\Projects\workshop\.claude\`, not `Downloads\.claude\`, which
holds **three** entries — the whole directory moved under `M7` on 2026-09-02.
And `Projects\workshop` is a third project key with sessions of its own, which a
`Downloads`-only registration would have left unguarded. **Registering at user
level covers all four keys and anything future**, which is why it went there.

**Proved, in seven directions, by piping envelopes at the script** (2 = refused):

| case | want | got |
|---|---|---|
| relative target, cwd **in** the repo | 2 | 2 |
| relative target, cwd **outside** the repo | 0 | 0 |
| absolute target **in** the repo, cwd outside | 2 | 2 |
| absolute target **outside** the repo | 0 | 0 |
| relative target, **no `cwd` in the envelope** | 2 | 2 |
| `git add -A`, anywhere | 2 | 2 |
| `q.mjs` **with** `--remote` | 0 | 0 |

**The failure mode to know about, because the posture does not survive it.** A
wrong path in the registration makes `sh` exit **127**, and this script's own
header records that exit 2 is the only code treated as a block — so a typo
produces a guard that reads as installed and stops nothing. The registration was
therefore read back and its path resolved after writing, and the exact
registered command was run and returned 2.

**Owed: the first live refusal.** Hook settings are read when a session starts,
so this session cannot exercise its own registration — the same shape as `F26`
for an agent file. **The next session started outside the repo is the test**, and
the string to grep for is `PreToolUse:Bash hook error`, **not** `guard-bash:`.

> **Adjusted 2026-09-22 — the owed item is DISCHARGED**, while taking `F60`.
> All 161 transcripts under `C:\Users\natha\.claude\projects\` were scanned for
> that wrapper at the start of an `is_error` result. **Four genuine refusals
> from a session started outside the repo**, project key
> `C--Users-natha-Downloads`, `cwd=C:\Users\natha\Downloads`, all 2026-09-22 and
> all naming the user-level registration: rule 2 at `14:47:41Z`, rule 4 twice at
> `15:00:31Z` and `15:00:38Z`, rule 1 at `15:54:40Z`. None has ever been recorded
> under a `Projects-workshop` key.
>
> **A fifth hit in the same session is the more useful one.** At `15:53:30Z` the
> result was not a verdict at all — `guard-bash.sh: line 67: syntax error near
> unexpected token '('`, the script momentarily unparseable mid-`F57`. That is
> `F56`'s *"reads as installed and stops nothing"* shape caught in the wild, and
> it is why the failure mode is worth knowing rather than just the refusals.

**Opened while taking this: `F56`** — three instruction files state the refusal
prefix wrongly, which is what this scan inherited, and nothing pins the hook's
path or its registration. Filed below, not taken.

### F56 — three files say a refusal starts `guard-bash:`, and nothing pins where the hook lives or that it is registered

**Opened 2026-09-22 while taking `F55`**, by `audit-premise-auditor`. Both parts
are things `F55` walked into rather than things it foresaw.

**One: the refusal prefix is wrong in three places, and it produced a false
finding.** `.claude/skills/windows-shell/SKILL.md:33` says *"A refusal starts
`guard-bash:`"*; `CLAUDE.md:310` says the same; and the memory note on the hook
says *"a tool result starting `guard-bash:` is the hook"*. All three are true of
what the **script** prints — `refuse()` writes exactly that to stderr — and
false of what a **transcript** holds. Claude Code wraps it: the tool result
begins `PreToolUse:Bash hook error: [<the configured command>]: ` and the
`guard-bash:` reason is in the middle. Read 2026-09-22.

**The cost is not theoretical.** `F55` defined a refusal as a result *beginning*
`guard-bash:`, scanned every transcript on the machine, got **0**, and filed
*"the hook has never refused a command"* as its heading. One refusal existed the
whole time. A count anchored on a prefix that never appears returns zero by
construction, and nothing about the result looks wrong.

**Two: nothing pins the hook's path or its registration.**
`apps/character-creator/test/checks/instruction-paths.mjs:50-51` has
`ROOTS = ['CLAUDE.md', 'SETUP.md', '.claude/skills', '.claude/agents']` and
`READABLE = /\.(md|json|ps1|mjs|js)$/i`. `.claude/hooks` is not a root and `.sh`
is not readable, so an absolute path written into `guard-bash.sh` is pinned by
nothing; `.claude/settings.json` is outside `ROOTS` too. Since `F55` the live
registration is in `C:\Users\natha\.claude\settings.json`, **outside the repo
entirely**, where a wrong path makes `sh` exit 127 — not a block — and the guard
reads as installed while stopping nothing.

**Proposal, two parts, each independently declinable.** Correct the prefix
sentence in all three files to the string a transcript actually carries, and say
plainly that the script's own output and the transcript's differ. And pin the
registration the way the machine instruction file is pinned: a **local-only**
check, in the shape of
`apps/character-creator/test/checks/machine-instructions.mjs`, asserting that
the user-level settings register a hook whose script path resolves. **Posture:
documentation for part one; for part two, a check that reports rather than
gates, and that states a non-assertion in CI where the file is absent** — the
same posture `machine-instructions.mjs` already takes for the same reason.

**Evidence:** the three reads, the `instruction-paths.mjs` read, and the
re-derived refusal count, all 2026-09-22 and all recorded under `F55`'s outcome
note.

**Confidence:** high on part one — the wrapper prefix was read out of a real
transcript line. Medium on part two's shape: whether a check that cannot run in
CI earns its place here is the same argument `machine-instructions.mjs` already
had and won, but it won it for a file that rots on its own, and a registration
rots only when somebody edits it.

**Ongoing cost:** part one, none — a sentence that becomes true. Part two, one
more local-only check, which is one more thing that passes silently on a runner
and therefore one more thing a reader can mistake for coverage.

**Taken, 2026-09-22 (PR #1250), both parts.** Part one shipped as documentation,
as proposed. Part two shipped as
`apps/character-creator/test/checks/hook-registration.mjs`.

**The posture sentence asks for two different things, and Nate picked between
them.** <!-- claim-ok: quoting the premise this note corrects --> It says *"a
check that reports rather than gates"* **and** *"the same posture
`machine-instructions.mjs` already takes for the same reason"*. That module
calls `check()` at `machine-instructions.mjs:94` and `:99`, and `harness.mjs`
counts a false condition as a failure, so a violation fails `smoke` — a required
status check. **It gates locally; it asserts nothing in CI and says so in a
passing check's own label, then returns.** Asked which was meant, Nate chose the
module over the literal clause, so **the shipped posture is: gates locally,
asserts nothing in CI and says so.** Recorded because a taker reading only the
first clause would build something weaker than the model the second clause
names.

**Two more premises were wrong, and both narrowed the work:**

- **Part one is a two-file edit, not three.** The memory note this finding names
  had already been corrected — its frontmatter reads
  `modified: 2026-09-22T16:01:39.609Z`, later on the same day this finding was
  filed — and it now states the wrapper correctly. Only
  `.claude/skills/windows-shell/SKILL.md:33` and `CLAUDE.md:310` still carried
  the claim. Read 2026-09-22.
- **The line numbers are off by one.** `ROOTS` is at
  `apps/character-creator/test/checks/instruction-paths.mjs:51` and `READABLE`
  at `:52`; `:50` is a comment. The values and all three conclusions hold
  exactly. Read 2026-09-22.

**What the audit added that this finding did not have:**
`apps/character-creator/test/checks/environment.mjs:602` matches repo paths
beginning `db|scripts|apps|functions|shared` only, so it does not reach
`.claude/hooks/guard-bash.sh` either. The finding established that
`instruction-paths.mjs` misses the hook; the second reader misses it too, and
before this PR the only in-repo reference to the script outside prose was
`.claude/settings.json:54`.

**The prefix error damaged a third finding, in the opposite direction, which is
the sharpest argument for part one.** `F55` anchored on a **leading**
`guard-bash:` and got zero, concluding the hook had never fired. `F54` matched
the **bare string** anywhere and reported 42 refusals; its own note has since
retracted that as results *containing* the string. One wrong sentence about a
prefix produced both a false zero and a false 42, and neither looked wrong.

**Folded in on Nate's word, and neither is a new number.** Both are
documentation, in the two files and the two sections this PR already edits:

- **The project-scoped claim.** `windows-shell/SKILL.md:19` headed its section
  *"and it fires in one directory"*, `:39-46` said the hook is project-scoped
  and that `C:\Users\natha\Projects\workshop` has no hook at all, and
  `CLAUDE.md:311-312` said it governs a session started in the repo *"and
  nothing else"*. All false since `F55`. **`F54`'s outcome note had already
  found this and filed nothing** — `SKILL-AUDIT.md:1336-1342`, *"Two things
  found while taking this, and neither is filed here"* — which is the deferral
  shape `audit-menu` warns about, and it is why the sentence was reachable only
  by reading the interior of a closed finding.
- **Five rules are now six.** `F54` shipped the drive-root `find` rule on
  2026-09-22 and no instruction file followed it; `windows-shell/SKILL.md:19`
  and `:25-31`, `CLAUDE.md:306`, and the memory note all still said five. This
  finding does not mention it, and it sits inside the lines being edited.

**The second thing `F54` deferred is NOT folded in and is not filed here
either.** Both registrations are live — the repo's and the user-level one — so a
repo-rooted session runs the hook twice. That was demonstrated while taking
this, by two refusals in one session naming different configured commands, one
the absolute user-level path and one `$CLAUDE_PROJECT_DIR`. Removing a
registration is a change of posture rather than a correction, so it is left for
Nate to name. The new check deliberately does not assert that the user-level
registration is the only one.

**Every check in the new section was seen to fail before it was believed.**
Eight fixtures driven at the real module through `USERPROFILE`, so the fault
enters through the module's own path derivation rather than past it: six red —
no Bash hook, no `guard-bash.sh`, a `$CLAUDE_PROJECT_DIR` path, an absolute path
with a typo, malformed JSON, and a resolving path whose contents differ — and
two green, the real registration and the absent-file case CI takes. **The
fixtures caught a defect in the first draft**: a path that did not resolve also
failed the contents check, reporting that the script *"resolves, but its
contents differ"*, which would have sent a reader looking for a diff that does
not exist.

**One half of one premise is documented rather than measured**, and is recorded
so nobody reads it as run: that `sh` returns 127 on a missing script was
measured 2026-09-22; that Claude Code treats 127 as non-blocking is taken from
`guard-bash.sh:7-8`'s own header. An end-to-end 127 registration was not
exercised, because doing so means pointing this machine's live guard at a broken
path.

**And a trap for anyone sweeping this finding's number: `F56` names three
different findings.** `BOOK-INGEST-AUDIT` `F56` is about totem animals and
`apps/character-creator/UI-AUDIT.md:473` carries a third. A bare tree grep for
`F56` returns 40+ hits, none of them this one, and
`node scripts/audit-citations.mjs --remote F56` silently resolves the bare
number to `BOOK-INGEST-AUDIT`. Sweep for `SKILL-AUDIT F56`.

### F57 — the rules match prose, and registering the hook turned that from invisible into a daily cost

**Opened 2026-09-22 while taking `F55`**, by the hook refusing this session's own
commit — the first command it ever blocked in real work.

Every rule matches against the **whole command text**. That is correct for a
command and wrong for a heredoc body, and this repo writes commit messages and
pull-request bodies as heredocs full of prose about commands. The refusal:

```
PreToolUse:Bash hook error: [sh ".../guard-bash.sh"]: guard-bash: sed -i
rewrites a CRLF file as LF and the diff shows every line; use the Edit tool or
node with an explicit encoding
```

The command was `cat > commit-msg.tmp <<'MSG' … MSG` and the matched text was a
**sentence inside the message** describing what rule 2 used to do. Rule 2 then
tokenised the surrounding prose as targets, resolved one against the cwd — which
was the repo — and refused.

**It is not a new defect.** The matcher has always read the whole text; it was
invisible for six days because the hook was registered where no session started
(`F55`). Registering it machine-wide made it visible in about ninety seconds,
which is the honest summary of what `F55` bought: the rules now fire, including
where they are wrong.

**Proposal:** strip heredoc bodies from the text the rules match against,
in the same `node` call that already parses the envelope — find
`<<` or `<<-` followed by an optionally quoted word, drop lines until the
terminator, keep the terminator. Match on the stripped text; leave the
`sed`/`git`/`gh` patterns themselves alone. **Posture: one function in the
extractor, no rule changed, refusal posture unchanged.**

**What it deliberately does not do**, and this is the trade: a command written
*into* a heredoc — a script file that is then run — stops being matched. That is
accepted, because the hook cannot guard the eventual `sh script.sh` either, and
the alternative that keeps it (requiring `sed` at a command position) **misses
`find -exec sed -i` and `xargs sed -i`**, which are real command positions this
repo could use.

**Evidence:** the refusal above, 2026-09-22, from this session's own transcript,
with the command that produced it.

**Confidence:** high that the defect is real and costs a session daily — it cost
this one, twice, within the hour. Medium on the stripping being complete: a
heredoc terminator can be quoted, indented with `<<-`, or shadowed by a word
appearing alone on a line inside the body, and only the first two are handled by
the proposal as written.

**Ongoing cost:** one more function in the part of the hook that must never
throw, in a script whose failure mode when it cannot parse its input is to
refuse everything.

**Taken, 2026-09-22 (PR #1246). Posture held: one function in the extractor, no
rule changed, refusal posture unchanged.** Filed and taken the same day on
Nate's word, after the hook blocked this session twice.

**Not the fix this finding proposed, and the premise audit is why.** It asked
for heredoc bodies to be stripped. Stripping *every* body **disarms the guard on
bodies that execute** — `sh <<EOF`, `python - <<PY`, `node - <<NODEEOF` — and
`PY` and `PYEOF` are the **two commonest terminators in this corpus**, 1,758 and
1,542 against `EOF`'s 1,876. Those bodies run in place; there is no later
`sh script.sh` for the hook to catch instead, which is the case this finding's
own *what it deliberately does not do* paragraph described and underrated.
**So a body is kept when its opener names an interpreter, and stripped
otherwise.**

**Three ways the version as specified would have failed OPEN — silently, in a
script whose whole posture is to fail closed:**

- **`<<<` here-strings.** `<<` + optional quote + word matches at offset **1**
  of `<<<`, taking the here-string's own text as a terminator and dropping
  everything after it. 51 commands in the corpus contain `<<<`.
- **An opener with no terminator** — a heredoc built inside a JS or Python
  string, or `<<` inside an `awk` program. 18 corpus commands. The shipped
  function **returns the text untouched** in that case rather than losing the
  rest.
- **`maxBuffer: 1 << 28`** parses as a heredoc with terminator `28` if the word
  class allows a leading digit. The shipped class does not.

The function also returns the original text on any throw, because section 0
exits 3 when it cannot parse its input and `refuse()` then blocks **every** Bash
call on the machine.

**Two claims in this finding were wrong, and both are corrected here:**

- <!-- claim-ok: quoting the premise this note corrects --> *"it cost this one,
  twice, within the hour"*. The heredoc defect fired **once** (14:47:41Z). The
  other two refusals that hour were **rule 4**, on `gh pr merge` — and rule 4 is
  right: its own comment requires the merge to be the whole tool call, and the
  command it refused was chained to a `cd`. Stripping does not touch it.
- <!-- claim-ok: quoting the premise this note corrects --> *"misses
  `find -exec sed -i` and `xargs sed -i`"* as the cost of the rejected
  alternative. `find -exec` holds; **`xargs sed -i` is not matched today
  either**, because rule 2 needs a target token and `xargs` supplies filenames
  on stdin. Half the stated cost of anchoring did not exist — **and
  `xargs sed -i` is a live hole in rule 2, independent of this finding.**

**Also corrected:** this finding says *"every rule matches against the whole
command text"*. Rule 3 does not — it runs through `lines()` and matches per
line. The fix is unaffected, since a body line is still a line.

**Proved by a harness of nineteen cases**, driven at the real script with real
envelopes, which failed **three** before the change and passes all nineteen
after. It covers the four opener spellings this corpus uses — `<<'W'`, `<<W`,
`<<\W`, `<< 'W'` — the three fail-open shapes above, both interpreter forms, and
the unchanged behaviour of every other rule.

**One harness case was expecting the wrong thing and is recorded rather than
quietly fixed.** A body of `os.system("git add -A")` is **not** matched by rule
1 with or without a heredoc — rule 1 requires whitespace or end-of-line after
`-A` and finds a quote. The case now uses a bare line.

**The heading is wider than the fix, deliberately.** *The rules match prose*
also covers trigger text inside a **quoted argument** — this session was refused
twice more for exactly that while testing, once for `git add -A` inside a
`node -e` string. That is not closed here and should not be read as closed.
**Filed as `F59`, 2026-09-22.** The `xargs sed -i` hole this note names two
paragraphs above is filed as `F58`, with a second rule-2 defect found beside it.

### F58 — medium — rule 2's token walk is unbounded in one direction and blind in the other, so it refuses `sed -n … && grep -i …` and allows `xargs sed -i`

**Opened 2026-09-22**, from two refusals this session actually hit plus the hole
`F57`'s outcome note names and does not file.

`.claude/hooks/guard-bash.sh:148` gates rule 2 on

```
sed[[:space:]]+([^[:space:]]+[[:space:]]+)*(-[a-zA-Z]*i[a-zA-Z.]*|--in-place[^[:space:]]*)
```

The `([^[:space:]]+[[:space:]]+)*` span is unbounded and crosses `&&`, `;` and
`|`, because rule 2 — unlike rules 3 and 4 — matches the whole command rather
than per line. So **any later command's `-i` satisfies rule 2's in-place flag.**
Measured 2026-09-22, refused by the live hook:

```
sed -n '520,540p' META-AUDIT.closed.md && echo "" && grep -rn -i 'DOCS-AUDIT-2' <path>
```

`sed -n` is not an in-place edit; the `-i` belongs to `grep`. The token walk then
finds `META-AUDIT.closed.md`, resolves it against the cwd, and refuses. **Any
read-then-search pair in one call is refused today**, and this session hit it
twice.

**The same walk is blind in the other direction.** `xargs sed -i` is not matched,
because the walk needs a *target token* and `xargs` supplies filenames on stdin.
Driven at the real script with real envelopes, 2026-09-22:

| command | verdict |
|---|---|
| `sed -i 's/a/b/' README.md` | REFUSED |
| `find . -name '*.md' -exec sed -i 's/a/b/' {} +` | REFUSED |
| `grep -rl foo . \| xargs sed -i 's/foo/bar/'` | **allowed** |
| `grep -rlZ foo . \| xargs -0 sed -i 's/foo/bar/'` | **allowed** |

**`F57`'s outcome note already records the second half** — *"`xargs sed -i` is a
live hole in rule 2, independent of this finding"* — and files nothing. It does
not know about the first half.

**Proposal:** one change addressing both — anchor rule 2's `sed` at a command
position, the way rule 6 already anchors `find` at `guard-bash.sh:241`, and
treat `xargs` and `-exec` as command-position introducers so the two real
multi-file shapes stay caught. **Posture: rule 2 only. No new rule, no change to
what it refuses when it is right, and the refusal posture is unchanged — exit 2,
fails closed.**

**`F57` considered anchoring and rejected it on a cost that turns out to be
half imaginary.** <!-- claim-ok: quoting the premise this finding corrects -->
It says anchoring *"misses `find -exec sed -i` and `xargs sed -i`"*; its own
outcome note then establishes that `xargs sed -i` **is already missed**. So
anchoring costs `find -exec` alone, and the introducer list recovers that.

**Evidence:** the live refusal above and the four-row table, both 2026-09-22,
driven at `.claude/hooks/guard-bash.sh` with crafted envelopes. The envelope must
be built in node rather than a shell string — the Bash tool collapses `\\` to
`\` and a Windows path stops being valid JSON, which invalidated this session's
first harness and made rule 2 look dead when it was not.

**Confidence:** high on both defects — each reproduces from a command. Medium on
the fix: a command-position matcher for `sed` has not been written or scored,
and `F54` records that its own anchored matcher took two attempts and a
re-extracted fixture.

**Ongoing cost:** none new. It is a narrower regex in a rule that already exists.

**Taken, 2026-09-22 (PR #1253). Posture held: rule 2 only, no new rule, refusal
posture unchanged — exit 2, fails closed.** Widened from *one* change to four on
Nate's word, for the reason directly below.

**This finding's proposed mechanism fixes neither defect, and that is the
headline.** `audit-premise-auditor` caught it before a line was written.

- <!-- claim-ok: quoting the premise this note corrects --> **"anchor rule 2's
  `sed` at a command position"** does not bound the span. `sed -n '520,540p' …`
  **is** at a command position; what reaches `grep`'s `-i` is the unbounded
  token span, which a left anchor does not touch. Rule 6's anchor transplanted
  onto `sed` still matches the refused command.
- <!-- claim-ok: quoting the premise this note corrects --> **"treat `xargs` and
  `-exec` as command-position introducers"** cannot change the `xargs` verdict,
  because **the regex already matches `xargs sed -i`**. It is allowed because
  the token walk finds no target. Demonstrated: the same command with one stray
  token — `… xargs sed -i 's/foo/bar/' extra.md` — **is** refused today. The
  regex was never the gate.

**The introducer list survives, but for a different job than the finding gives
it**: anchored *without* an `-exec` introducer, `find -exec sed -i` stops
matching. It recovers a cost rather than fixing a defect.

**What shipped instead, four changes:** the in-place flag is found among **sed's
own options inside the walk** (options precede the script, so a later command's
`-i` cannot be mistaken for sed's — the defect cannot recur rather than being
patched); `sed` must sit at a command position or behind `xargs`/`find -exec`;
**no target token fails closed**, which is what actually closes `xargs sed -i`;
and `{}` resolves against find's own root.

**Two more premises did not hold:**

- <!-- claim-ok: quoting the premise this note corrects --> **"rule 2 — unlike
  rules 3 and 4 — matches the whole command"**. Only **rule 3** is per-line.
  Rule 4 is whole-command plus a non-blank *line count*. `F57`'s own note states
  this correctly about rule 3 alone at `SKILL-AUDIT.md:1737-1739`; this finding
  widened the correction to a rule it does not cover.
- <!-- claim-ok: quoting the premise this note corrects --> **"Any read-then-search
  pair in one call is refused today"** is overbroad. It is cwd-dependent, and
  four near-variants were allowed: `grep -rn` without `-i`, the same command
  from outside the repo, the pair split across a newline, and `grep -i` first.

**A fourth defect was found inside the rule and fixed here on Nate's word.**
`find /c/Users/natha/Downloads -name '*.md' -exec sed -i 's/a/b/' {} +` run from
the repo was **refused**, although it touches nothing in the repo — every bare
word took the relative branch and `dirname` of `{}` or `+` is `.`. A bare `+`
alone was enough. The finding's posture said *"no change to what it refuses when
it is right"* and was silent on what it refuses when it is wrong.

**Proved against 36 cases, fixture newlines intact** — `F54` records its own
matcher scoring 13/18 against a fixture flattened to single lines, which
destroyed the newlines that make a command position, and that lesson was
inherited rather than re-learned. **Pre-F58: 27 pass, 9 fail. After: 36 pass.**
The nine are three false negatives (all `xargs`) and six false positives; the
other 27 are unchanged, six of them pinning rules 1, 3, 4, 5 and 6.

**It was seen to fail first, and the failure is worth recording because it would
recur.** The first draft ported the old ERE `-[a-zA-Z]*i[a-zA-Z.]*` into a
`case` statement. In a shell glob `*` is "any sequence", not a quantifier, so
that pattern cannot match a bare `-i` — **the whole rule was silently
disarmed**, and 17 of 36 cases were red until the fixture said so. A comment now
sits at the patch site.

**`F59`'s rule-2 row closes as a side effect**, which was not planned: with
`sed` anchored, `echo "do not use sed -i on README.md here"` and its unquoted
twin are both allowed. `F59` still stands for rules 1 and 4, which this does not
touch.

**Not proposed, and deliberately dropped rather than left named:** committing a
harness for the hook's rules. Two have now been written and thrown away —
`F57`'s nineteen cases and this finding's thirty-six, both scratchpad-only — and
nothing in the repo exercises the rules. That is real, and it is **new machinery
rather than a narrower rule 2**, so it is outside this finding's posture. It is
dropped here, not deferred; anyone who wants it should file it.

**A sweeping note:** `F58` is a three-way collision — `BOOK-INGEST-AUDIT` `F58`
and `apps/character-creator/UI-AUDIT.md:801` are the others, and
`scripts/audit-citations.mjs --remote F58` silently resolves the bare number to
`BOOK-INGEST-AUDIT`. Sweep for `SKILL-AUDIT F58`.

### F59 — medium — the rules still match trigger text inside a QUOTED ARGUMENT, which `F57` fixed for heredocs and explicitly left open

**Opened 2026-09-22.** `F57`'s outcome note ends *"That is not closed here and
should not be read as closed"*, and files nothing. This is that half.

`F57` shipped `stripData` at `.claude/hooks/guard-bash.sh:68-92`, which drops the
body of a data heredoc before the rules read the command. **A quoted argument is
not a heredoc and is not stripped.** Driven at the real script, 2026-09-22 —
every one REFUSED, and none of them is the command the rule is about:

| command | rule that fired |
|---|---|
| `gh pr comment 99 --body "…a merge chained onto a check, gh pr merge && something, is refused"` | 4 |
| `echo "the rule is: never run git add . in a shared checkout"` | 1 |
| `echo "do not use sed -i on README.md here"` | 2 |
| `echo do not run sed -i on README.md` | 2 |

**It spans three rules, which is why it is not folded into `F58`.** `F57`'s two
specimens were both `git add -A` inside a `node -e` string; the `sed` and
`gh pr merge` shapes above are new, and the last row is not quoted at all — it is
prose in an unquoted `echo`, which no amount of quote-awareness reaches.

**This is the rule that bites a session writing about the rules**, which is this
repo's normal work: `CLAUDE.md`, `windows-shell`, this menu and the memory note
are all full of the trigger strings.

**Proposal:** none specific, deliberately — this is a suspicion with a
measurement attached rather than a design. The obvious move, stripping quoted
arguments, is **not** proposed: `F57` records three ways its heredoc stripper
would have failed open, and a quote-stripper is strictly harder because a
command's real arguments are quoted too. **Posture, whatever the mechanism: it
may not reduce what the hook refuses when the trigger IS a command.** A
false-positive fix that buys itself a false negative is worse than the problem.

**Rule 6 is the one precedent that works**, and it is narrow on purpose:
`guard-bash.sh:233-237` says `find` is matched at a command position *"so that
prose naming the shape does not trip it"*, calling that "a narrower guard than
the other five and it is deliberate". `F58` proposes extending exactly that to
rule 2. **Whether rules 1 and 4 should follow is this finding's question**, and
it is a question rather than a proposal because `gh pr merge` inside a PR body is
a real thing to write and a real thing to refuse.

**Evidence:** the four-row table above, 2026-09-22, driven at the real script.
**Not measured:** how often this fires in ordinary work. Three instances are
known — two in `F57`, one here — all in sessions whose subject was the hook
itself, which is the worst possible sample.

**Confidence:** high that it reproduces. **Low that it is worth a mechanism**,
and that is the finding: it may be right to write the workaround down and stop.

**Ongoing cost:** a quote- or position-aware matcher is one more thing that must
never throw inside a script whose failure mode is refusing every Bash call on the
machine.

**This proposal may well cost more than it returns, and if so it should be
declined** — the workaround is one sentence (`write prose to a file and `-F` it`,
which the memory note already gives) and it is already written down in three
places.

**Taken, 2026-09-22 (PR #1254). THE MECHANISM IS DECLINED, on this finding's own
recommendation and with the number it says nobody had.** Posture held:
documentation only, no rule changed, no exit code moved. The `F58` fixture still
passes 36 of 36, which is what says the six rules are untouched.

**The measurement this finding calls for.** Rule 2's segmentation ported onto
rules 1 and 4 and scored over **46,788 distinct commands** from this machine's
transcripts, 2026-09-22:

| rule | shape occurrences | at a command position | reachable only with `;` / `\|` | at no position |
|---|---|---|---|---|
| 1 — `git add -A` / `.` | 623 | 595 | **15** | 13 |
| 4 — `gh pr merge` | 1,187 | 1,065 | **94** | 28 |

Among the 94 is `cd … && gh pr checks 792 … ; gh pr merge 792 --squash …` —
**the PR #668 incident shape with `;` in place of `&&`**, which is the thing
rule 4 exists for. And `for n in 736 737; do gh pr merge $n …; done` sits at no
command position under any segmentation, so no anchor reaches it. **Rule 4
cannot reuse rule 2's segmentation**, because `guard-bash.sh` deliberately does
not split on `;` — SQL strings are full of it — and rule 4 compensates by
checking `;` directly.

So anchoring would un-refuse ~109 real commands, which is exactly what this
finding's posture forbids: <!-- claim-ok: quoting this finding's own posture,
cited at the Proposal paragraph above --> *"it may not reduce what the hook
refuses when the trigger IS a command."*

**Run twice, by two implementations** — a JS port and `grep -E` with the hook's
own matcher — agreeing exactly on the at-position counts, 595 and 1,065.

**And the return side, measured the same day.** All 541 transcripts scanned for
the wrapper `PreToolUse:Bash hook error` at the start of an `is_error` result:
**11 genuine refusals ever** — six trigger text, three real matching commands,
one real non-matching, one the hook crashing — against 1,290 Bash calls on
2026-09-22 alone. **Not** a grep for a leading `guard-bash:`, which returns zero
by construction and is the mistake `F55` shipped; a bare grep for the string
over-counts to 104, which is the same error mirrored.

**Two caveats, both against the measurement's own authority.** The window is
**one day** — the hook only went machine-wide with `F55` — and nearly every
session in it had the hook as its subject. The corpus also **self-contaminates
at about +1 per shape per such session**: the probe commands run while auditing
this land in the transcripts the scan reads, which is the sampling problem this
finding names about its own three instances, one level up.

**Four premises did not hold, and one changes what a future taker should look
at:**

- **Two of the four table rows no longer reproduce.** `F58` closed both rule-2
  rows on 2026-09-22 without disarming rule 2 — controls in the same run refused
  a real `sed -i` and a real `git add -A`. So <!-- claim-ok: quoting the premise
  this note corrects --> *"every one REFUSED"* is half true today.
- <!-- claim-ok: quoting the premise this note corrects --> **"It spans three
  rules"** is wrong in both directions. Rule 2 is out; **rules 3 and 5 are in and
  this finding names neither.** Rule 3 is not hypothetical — a real refusal at
  `15:03:41Z` on 2026-09-22 was rule 3 firing on the words *"never call node
  scripts/q.mjs without a flag"* inside a `node -e` argument. **Recorded here
  rather than filed**, on Nate's word: the same measurement argues against
  anchoring those two as well, so recording it closes the question instead of
  opening one.
- **Rule 2 is not fully closed for prose.** A multi-line `gh pr comment --body`
  still trips it, because `lines()` splits on newline and puts `sed` at a command
  position on the second line. `F58`'s note says *"row"*, singular, and is right;
  it should not be read as "rule 2 is done".
- **The rule-6 citation moved.** `guard-bash.sh:233-237` was correct when filed
  and is now `:314-318`. The quoted sentences are verbatim there — but
  <!-- claim-ok: quoting the script's own comment, corrected in this PR -->
  *"a narrower guard than the other five"* had itself gone stale when `F58`
  anchored rule 2, and **that sentence is what this PR rewrites**, since it is
  where the next person will propose this again.

**Could not be settled:** <!-- claim-ok: quoting the premise this note corrects -->
*"it is already written down in three places"* carries no citation and only one
place was found giving `-F` as the **prose** remedy. **And `-F` does not reach
the cases measured**: it exists for a commit message and `gh pr comment`, while
five of the six prose refusals were `node -e` or `echo`, which have none. The
memory note now says so.

**Sweeping trap, the third in a row:** `F59` is a three-way collision —
`BOOK-INGEST-AUDIT` `F59` and `apps/character-creator/UI-AUDIT.md:698` are the
others — and `scripts/audit-citations.mjs --remote F59` silently resolves the
bare number to `BOOK-INGEST-AUDIT` and reports three unrelated classes. Sweep
for `SKILL-AUDIT F59`.

### F60 — low — the hook is registered twice, and a session started in this repo runs it twice

**Opened 2026-09-22.** `F54`'s outcome note names this at `SKILL-AUDIT.md:1340-1342`
and files nothing.

Both registrations are live. `C:\Users\natha\.claude\settings.json` registers
`sh "C:/Users/natha/Projects/nates-apps/.claude/hooks/guard-bash.sh"` and the
repo's `.claude/settings.json:54` registers
`sh "$CLAUDE_PROJECT_DIR/.claude/hooks/guard-bash.sh"`. Both match `Bash`. Read
2026-09-22.

**Demonstrated rather than inferred**, which is new since `F54` recorded it: two
refusals in one session named *different* configured commands in the wrapper's
bracket — one the absolute path, one `$CLAUDE_PROJECT_DIR`. Neither registration
is deduped away.

**The cost is real and small:** every `Bash` call in a repo-rooted session spawns
`sh` and a `node` JSON parse twice instead of once. **The verdict is never
different**, because both run the same script from the same path.

**Proposal:** remove the hook block from the repo's `.claude/settings.json`,
leaving the user-level registration — which covers every directory on this
machine, including the two the repo's never reached. **Posture: subtractive, one
JSON block, no rule changed and no behaviour changed except that the hook runs
once.** The permission `allow` list in that file is untouched.

**Read the argument against before taking it.** The repo registration is the one
that is *checked in*, so it is the only half that survives a fresh clone or a
second machine; the user-level one exists on this machine and nowhere else.
Removing it makes the guard depend entirely on a file this repo cannot see,
which is the shape `F55` was filed about in the other direction. **The counter is
`apps/character-creator/test/checks/hook-registration.mjs`**, shipped with `F56`
on 2026-09-22, which fails `smoke` locally when the user-level registration is
missing or broken — so the machine notices. Whether that is enough is Nate's
call, and this finding does not assume it is.

**Evidence:** both settings files read 2026-09-22, and the two live refusals in
this session's own transcript.

**Confidence:** high that both fire — it was observed, not reasoned. **Medium on
the proposal**, entirely because of the fresh-clone argument above.

**Ongoing cost:** none either way. This is a one-time decision about which
registration is authoritative.

**Taken, 2026-09-22 (PR #1255). THE PROPOSAL IS DECLINED — both registrations
are kept.** The finding's posture, <!-- claim-ok: quoting this finding's own
posture, in the Proposal paragraph above --> *"subtractive, one JSON block, no
rule changed and no behaviour changed except that the hook runs once"*, is the
thing declined, and its last clause is false.

**The two registrations are NOT interchangeable, which this finding assumes they
are.** <!-- claim-ok: quoting the premise this note corrects --> *"The verdict is
never different, because both run the same script from the same path."*
`repo_posix` is derived from `$0`'s grandparent at `guard-bash.sh:124-126`, so
**each copy of the script guards only the tree it lives in.** Measured
2026-09-22 by running each copy against each tree with real envelopes:

| script | cwd | verdict |
|---|---|---|
| main checkout's | main checkout | **REFUSED** |
| main checkout's | another tree | allowed |
| another tree's | its own tree | **REFUSED** |
| another tree's | main checkout | allowed |

In a **git worktree** the repo's registration runs the worktree's own copy and
guards it; the user-level one runs the main checkout's copy and does not. Drop
the repo block and **rule 2 stops refusing `sed -i` on a worktree's own files** —
the workflow the `worktree` skill exists for, and the one this repo has a memory
about because a removal there once emptied the main checkout's book caches.

**Two further arguments, both understating in this finding's own
counter-paragraph:**

- **The repo block is the PORTABLE half.** `$CLAUDE_PROJECT_DIR` resolves to
  wherever a clone sits; the user-level registration exists on this machine and
  nowhere else. The finding has this backwards when it calls the repo block
  merely *"the only half that is checked in"* — being checked in is what makes it
  portable. And `SETUP.md` carries **no** occurrence of `hook`, `PreToolUse` or
  `guard-bash`, so nothing tracked tells a second machine the user-level
  registration must exist.
- **`hook-registration.mjs` does not mean what the finding says.**
  <!-- claim-ok: quoting the premise this note corrects --> *"so the machine
  notices"* — it notices a missing or broken hook **block**. If
  `~/.claude/settings.json` is absent **entirely** the check reports a PASS and
  returns, which is right for CI and wrong for a second machine. That is exactly
  the scenario the argument-against is about, so the counter is weaker than
  offered.

**One claim reads as measured and is not.** <!-- claim-ok: quoting the premise
this note corrects --> *"The cost is real and small: every `Bash` call … spawns
`sh` and a `node` JSON parse twice"* is inferred. The wrapper surfaces **one**
bracketed command per refusal, never two; two brackets across one session prove
both registrations are live, not that both run per call. The `Evidence` and
`Confidence` lines are honest about this and the cost paragraph is not.

**What the derivation actually does, since the script's own comment was wrong
about it.** The comment called the `$CLAUDE_PROJECT_DIR` spelling hypothetical
and circular. It is neither hypothetical — it fired at `2026-09-22T17:18:40Z` —
nor wrong: project settings load only when the session's project root *is* that
checkout, so `$0`'s grandparent is that checkout's real root. The derivation is
circular and lands on the right answer. Corrected in this PR.

**Shipped instead of the removal:** the corrections above, in the four places
someone would next propose this — `guard-bash.sh`'s comment,
`.claude/skills/windows-shell/SKILL.md:69`, `CLAUDE.md`, and
`hook-registration.mjs`'s header, which now records both that *"exactly one"*
would be wrong to assert and the hole it still has.

**`F55`'s owed item is discharged in the same PR**, as an `Adjusted` note under
`F55` with the original left standing: four genuine refusals from a session
started outside the repo, `C--Users-natha-Downloads`, 2026-09-22.

**Nothing cites `SKILL-AUDIT` `F60`**, and `F60` is a two-menu collision —
`BOOK-INGEST-AUDIT` `F60` is cited in four repo files, and
`scripts/audit-citations.mjs --remote F60` silently resolves the bare number to
it. Sweep for `SKILL-AUDIT F60`. The four files that cite *this* finding's
subject rather than its number are the four corrected above, and no script finds
those.

## A closing observation, about this audit rather than its findings

**Instructions this session wrote were violated by their author, the same day,
four times.** Not the old ones — the new ones.

| what I did | the rule, written hours earlier |
|---|---|
| an inline PowerShell command whose backslashes collapsed | `windows-shell` → *the Bash tool unescapes before bash sees it* |
| committed a 4,603-line phantom CRLF flip in this file | `windows-shell` → *editing a file in place* |
| handed over a bare `claude` | `windows-shell` → *call binaries by absolute path in anything you hand him to run* |
| then handed over the `npm\claude.cmd` shim | `interactive-shell-lacks-npm-path`, which records **that exact path as already having failed** and names the one that works |

> **Adjusted 2026-09-02 — `MACHINE-AUDIT` `M2`.** The rule in row three no
> longer exists. `windows-shell` was measured against the machine rather than
> read, the diagnosis beneath that prescription did not survive it, and the
> prescription was retired with it. So row three now records a violation of an
> instruction that should never have been written — which leaves the observation
> below untouched and sharpens the closing paragraph: the defence named there,
> *measure the thing rather than trusting the sentence about it*, is also what
> retired the rule. The table is left standing as filed.

I caught the first two. Nate caught the third. **The fourth is the one worth
keeping:** the memory holding the right answer also named my wrong answer as
wrong, it was in this session's context throughout, and I reached for a
directory listing instead of reading it.

So the audit's subject was demonstrated on the audit. `F1` is a lesson written
to memory that asserted a fix had already landed in a skill. `F20` is citations
nothing revisits. `F16` is a status a memory cannot hold. This is the same
thing again: **writing an instruction down is not the same as it firing.**

The instruction layer is not a guarantee — it is a prompt to a reader who may
not read it. The only defence observed working here was *measure the thing
rather than trusting the sentence about it*, which is what caught `F1`'s
inverted premise, `F4`'s two false replacements, `F8`'s impossible arithmetic
and `F9`'s 74 false positives.

Recorded here rather than filed as a finding, because there is nothing to
implement. It is the result.

## Filed from `META-AUDIT` A22's dropped-deferral list, 2026-09-22

Three deferrals named on this menu and never filed. `A22` listed them as a
deliberate drop with locations; Nate named them, and they are numbered here.
None is taken in this PR.

### F61 — low — `book-extract-worker`'s return contract covers stat blocks only, measured 2026-09-22

**Opened 2026-09-22.** Named at `SKILL-AUDIT.closed.md:2515-2525`, inside
`F28`'s note: <!-- claim-ok: quoting that note, located in the sentence before
this one --> *"the prose case is covered nowhere in it … the file should carry
it, and that is a change to an agent rather than verification, so it is not made
here."* Deferred 2026-09-04, 18 days ago.

Re-checked 2026-09-22 and still true: `grep -c -i prose
.claude/agents/book-extract-worker.md` returns **0**. Its return contract at
`:81` opens *"For each row: the name as printed, the fields the book gives…"*,
and `:57` and `:66` both reason about stat blocks.

**The agent handled a prose slice correctly anyway and reported the gap itself**,
which is the argument for this being `low` — the behaviour is right and the
contract is silent, rather than the contract being wrong.

**Proposal:** add the prose case to the agent's return contract, in whatever
words the file already uses for a stat-block row. **Posture: one agent file,
documentation only. No change to what the agent does, and no new step.** The
observed behaviour is the specification; this is writing it down.

**Read `CLAUDE.md`'s agent-timing rule before planning around this.** An agent
file written mid-session cannot be spawned in that session — the junction shows
it instantly and a spawn still answers `Agent type '<name>' not found` until the
next turn (`SKILL-AUDIT` `F26`). So a PR that edits this agent cannot also
exercise it.

**Evidence:** the `grep -c` above and the three line reads, 2026-09-22; the
deferral read at `SKILL-AUDIT.closed.md:2515-2525`. **Not measured:** how the
agent actually behaved on the prose slice — that run is described in `F28`'s
note and was not re-run here.

**Confidence:** high that the contract is silent. **Medium that writing it down
changes anything**, since the agent already did the right thing unprompted.

**Ongoing cost:** one more paragraph in an agent file that has to stay true.

### F62 — low — this menu's findings sit under six-plus dated `##` placements, and consolidating them was deferred

**Opened 2026-09-22.** Named at `SKILL-AUDIT.md:367-369`: <!-- claim-ok:
quoting this file's own section lead, located in the sentence before this one -->
*"A **sixth** placement on this page. Six is past the point where the arrangement
helps anybody; consolidating them is worth its own finding and is not attempted
here."* Written 2026-09-04, 18 days ago — **and there are more than six now**,
including two added on 2026-09-22.

**Read `SKILL-AUDIT` `F42` and `META-AUDIT` `A13` before scoping this.** `F42`
cut the arrangement prose out of `audit-menu`'s shape table on the ground that
arrangement belongs in *"a menu's own dated header, which is where `audit-menu`
already puts status for the same reason"*. So the question is not whether to
document the arrangement — that is settled — but whether the placements
themselves should be merged.

**Proposal:** decide whether to consolidate, and if the answer is no, record it
here so it is not re-derived a third time. **Posture: if anything moves, it is
headings only — no finding text is altered and nothing is renumbered.**
`audit-menu` → *Audit files are RECORDS* governs the rest, and the placements
are dated records of when work was opened.

**The counter-argument is strong and should be read first:** each `##` heading
carries a date and a reason, which is exactly what `audit-menu` says a header
*may* hold — *how to read the file*. Merging them would delete that. The cost of
many placements is that a reader must scroll; the cost of merging is losing when
and why each batch was opened.

**Evidence:** the section lead read 2026-09-22, and `grep -c '^## ' SKILL-AUDIT.md`.
**Not measured:** whether anyone has actually been misled by the arrangement.
The deferral asserts *"past the point where the arrangement helps anybody"* with
no instance behind it.

**Confidence:** high that the deferral exists and that the count has grown.
**Low that consolidation is right**, for the counter-argument above.

**Ongoing cost:** none if declined. If merged, one more thing to keep true as
placements accumulate — which is the problem restated.

### F63 — low — `F54`'s note still reads as an unfiled deferral, and half of it now asserts something that was deleted

**Opened 2026-09-22.** `SKILL-AUDIT.md:1336-1342` reads
<!-- claim-ok: quoting F54's note, located in the sentence before this one -->
*"**Two things found while taking this, and neither is filed here.**
`.claude/skills/windows-shell/SKILL.md:39-46` **still says** the hook *is
project-scoped*…"*.

**Both halves have since been closed, and the note says neither.** The
project-scoped sentences were deleted by PR #1250 while taking `F56` —
`grep -c 'project-scoped' .claude/skills/windows-shell/SKILL.md` returns **0**,
checked 2026-09-22 — and the double registration was filed as `F60` and declined
in PR #1255.

**So this is not merely an unfiled deferral: it is a live false claim.** A reader
following it opens `windows-shell` looking for a sentence that is not there.

**Proposal:** append a dated line to `F54`'s note recording that both items are
closed and where. **Posture: additive only — `audit-menu` → *Audit files are
RECORDS*, so the original sentences stay and nothing is rewritten.** Do not
delete the deferral; it is the evidence `A22` measured.

**Evidence:** the `grep -c` above and the read of `:1336-1342`, both 2026-09-22;
PRs #1250 and #1255. **Nothing here is unmeasured** — this is the one deferral
on the list whose work is already done.

**Confidence:** high on both halves.

**Ongoing cost:** none. It is one dated line on a closed finding.
