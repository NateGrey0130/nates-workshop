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
> there. **THIS MENU HAS NO OPEN WORK.** `F41`, `F42` and `F43` were all taken
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
