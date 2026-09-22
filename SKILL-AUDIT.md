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
