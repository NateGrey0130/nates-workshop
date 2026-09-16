# RETRO-AUDIT.md — does the catalog benefit from the schema it grew?

> **Since 2026-09-16 the closed findings live in `RETRO-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **Nothing is open on this menu, as of 2026-09-06.** This line will not say
> which findings, and it did not when there was work open either.
> **Read under the heading for what actually happened to each** — some turned
> out to be wrong about their own premises, some correct defects this menu's own
> work shipped hours earlier the same day, and some needed app changes their
> finding framed as data-only. The outcome notes are where that is recorded, and
> **no tally of them belongs in this paragraph**: the version written on
> 2026-09-05 said *two* of the third kind and *two* of the second, and the
> second was three (`R10`, `R12` and `R13`) before the day it was written ended.
>
> *(Until 2026-09-05 this paragraph named the one finding then open, and said
> everything before it had been taken. That was true when written and false
> within the day, twice over. `audit-menu` → What a status header may carry
> forbids a per-finding state here for exactly this reason, and the line that
> broke the rule is the line that rotted.)*
>
> <!-- claim-ok: quoting the header claim this note corrects -->
> *(**And the durable shape rots too, which is the newer lesson.** From
> 2026-09-05 until 2026-09-06 this paragraph opened "Work is open on this menu,
> and this line will not say which findings." It named none, exactly as `A13`
> asks — and it was still wrong from 05:47 on 2026-09-06, when `#750` closed
> `R21`, until it was corrected. Refusing to name a finding removes the roll-call
> that rots fastest; it does not remove the claim. **Whether anything is open is
> itself a sentence with a lifetime**, and this is the file that demonstrates it.
> `META-AUDIT` `A18`.)*
>
> **One thing this menu found and did NOT act on**, because it is not a sweep's
> to decide: `CLASS-AUDIT`'s *"Checked and still true"* entry saying
> `occ_related_skills` cannot span two categories is stale in all three of its
> examples. `R11`'s outcome note has the detail.
>
> <!-- claim-ok: quoting the header claim this note corrects -->
> **Adjusted 2026-09-05, and both halves of that paragraph are now false.** Nate
> released the entry on 2026-09-04 and `R13` took it, so the menu DID act on it.
> And the release audit found only **one** of the three examples stale, not
> three: the merc-soldier's *"two W.P.s of choice, OR two Demolition skills"*
> spans `Weapon Proficiencies` and `Military` — checked with
> `node scripts/q.mjs --remote "SELECT name, category FROM skills WHERE lower(name) LIKE '%demolition%'"`,
> three rows, all `Military` — and is still not expressible, being an exclusive
> or inside a `mos` option. The juicer-wannabe was never an instance. The
> paragraph above is left standing because this file is a record; `R11` and
> `R13` carry the detail.
>
> **Everything from `R9` on breaks the severity order and that is deliberate.**
> Each was filed after `R8` had already shipped, so they run in FILING order at
> the foot of the file rather than sitting among the highs and mediums. That is
> shape rather than status: it stays true as findings close, and as more are
> filed at the foot. `R9` also began life in *Not established* below.
>
> **This menu's own trap: its headline precision figure rests on n=2.** The
> "detector 1 alone is 11%, detector 1 AND 3 is 100%" result in *Method* below
> was measured against the only capability with a known ground truth
> (`skills.mos`, two true positives). It is a **calibration, not a rate**, and
> it did not transfer: the same conjunction produced false positives on
> `magic.spells_from` because that capability has no crisp prose keyword the way
> "MOS" does. Do not quote the 100% as this audit's accuracy.
>
> **The second thing that misreads:** some findings below are **note rot** (the
> data is already correct and only the prose lies) and others are **missing
> mechanics** (the data is wrong or absent). They read alike in a heading and
> cost completely different amounts to take. **Each heading says which**, and
> `R6` is deliberately mixed — one of its three may collapse to note rot.
>
> **Findings are `###` headings with a severity word** — `### R1 — high — …`.
> Every one carries the command it was established by.

Read-only audit, **2026-09-04**, against `main` @ `b681974`. Every count was
re-measured against **production** (`--remote`) on the day; none is carried from
the brief or from `docs/operations.md`.

**Baseline, re-measured:** 160 published classes, 345 skills, 607 spells, 116
psionic powers, 1,025 gear rows, 45 redirects.

```bash
node scripts/q.mjs --remote "SELECT (SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL) AS classes, (SELECT count(*) FROM skills) AS skills, (SELECT count(*) FROM spells) AS spells, (SELECT count(*) FROM psionic_powers) AS psionics, (SELECT count(*) FROM gear) AS gear"
```

The prior art is `CLASS-AUDIT.md` § *Schema-can-now-express* (`S1`–`S9`,
2026-08-25), which ran at a **109-class** baseline. The corpus has grown 47%
since, and this pass used detectors that one did not have.

**Nothing here was changed by the audit.** No data script, no migration, no fix.

---

## Method, and what each detector was worth

Four detectors, run over classes, skills, spells, psionic powers and gear.

**Detector 1 — capability-vs-date diff.** For each row, capabilities that
post-date its import and are unset. **Proved before use**, per the brief: the
capability timeline was rolled back to 2026-08-22 *and* the class state rolled
back to as-imported (read out of the original `add-<id>-class.sql`, which
`CLASS-AUDIT` `S4` records still shows pre-fix state). It re-found both known
true positives — Merc Soldier and Robot Pilot, imported 2026-08-18, `skills.mos`
available 2026-08-21, fixed 2026-08-23 — and stopped flagging them against
today's markdown.

| | candidates | true | precision | recall |
|---|---|---|---|---|
| detector 1 alone | 19 | 2 | **11%** | 100% |
| detector 1 **and** 3 | 2 | 2 | **100%** | 100% |

**Detector 1 alone cannot be made to work, and the reason is structural: every
capability in this schema has a meaningful unset default.** An absent
`race_restrictions` means unrestricted (`raceAllowedForOcc`,
`apps/character-creator/js/parser.js:1873`) and an absent `xp_table` means the
house default (`xpTableFor`, `apps/character-creator/js/leveling.js:24`). A bare
unset check flagged 50 and 20 of those respectively, every one a correct value.

**Detector 2 — limitation claims, re-judged.** 101 claims swept from 64 classes
and handed to the `claim-capability-verifier` subagent (claims, not a corpus).
**47 judged, 54 unsettled, 16 stale across 8 capabilities** — a 34% hit rate on
what it judged. Five of the sixteen were re-checked independently against
production and all five held. **This is the detector that earns its keep**, and
every one of its 8 capabilities is read by something the player sees.

**A defect in this pass's own sweep, stated so the next one does not repeat it:**
claims were split on sentence boundaries, which truncated roughly 21 of the 101
mid-clause and made them unjudgeable. Bound on the YAML block instead.

**Detector 3 — prose holding a mechanic.** Only useful as a *gate* on detector 1,
not alone. Where the mechanic has a crisp keyword it is exact; where it does not
it is guesswork.

**Detector 4 — newest imports as the reference shape. It does not work here, and
the reason is worth recording.** Its largest signals are composition artifacts:
the oldest 30 classes are 26 `occ` / 4 `rcc` and the newest 30 are 18 `occ` /
12 `rcc`, so occupation-only fields fall away (`restrictions` −63 points,
`starting_money` −33, `equipment_starting` −33) purely because more races were
imported later. It measures what *kind* of thing was imported when.

**Overlap between detectors is almost nil.** Detector 1∩3 raised 7 classes,
detector 2 raised about 10, and they share **exactly one**
(`dragon-hatchling-royal-frilled`). They find different things and neither
replaces the other.

### Provenance — better for classes than expected, absent for catalog rows

**158 of 160 classes** were dated from their own `add-<id>-class.sql` git
add-date; 2 fell back to `imported_classes.created_at`; **none is unknown.**

**For catalog rows there is no per-row provenance at all**, and that is a finding
about the ledger rather than a gap to guess at. `data_script_runs` holds 367 runs
over 359 distinct filenames against 360 scripts in the tree, and its earliest
`run_at` is 2026-08-19 while data scripts exist from 2026-08-13 — so it dates
*files*, later than some of them actually ran, and never rows.

```bash
node scripts/q.mjs --remote "SELECT count(*) AS runs, count(DISTINCT filename) AS files, min(run_at) AS first FROM data_script_runs"
```

### Hit rate per subject, never averaged

| subject | candidates | real gain | classification of the rest |
|---|---|---|---|
| skills (catalog) | 7 | 7 | — |
| classes | 12 (1∩3) + 16 (detector 2) | 1 confirmed + 16 stale | rest correctly gated by `spell_levels_allowed` |
| gear — `damage` | 13 | 8 class-referenced | 5 unreferenced |
| gear — `cost_note` | 25 | 0 | **cosmetic** — no runtime projection selects it |
| gear — `sdc`/`ar`/`mdc` | 45 raw → 7 | 0 | correctly empty; placeholder rows with no printed stat |
| spells | 1 | 0 | false positive |
| psionic powers | 4 | 2–3 | 1 is an I.S.P. *recovery* rate, not a cost |

**No book was opened to confirm any of this.** The class and catalog records
transcribe their own printed values, so the ~100x cost line the brief warns
about was never crossed. That is a fact about this audit's subject matter, not a
general result.

---

## Findings

- **R1** — high — five classes deny a key they already carry (note rot; no data is wrong) — Taken, 2026-09-04 (PR #712) — posture held exactly: prose only, no mechanic, — full text in `RETRO-AUDIT.closed.md` under its own `### R1` heading.

- **R2** — high — `demon-goblin` and `monk` keep whole skill packages in prose, and `skills.mos` grants them — Taken, 2026-09-04 (PR #714) — as written, both classes in one `fix-` script, — full text in `RETRO-AUDIT.closed.md` under its own `### R2` heading.

- **R3** — high — the Warlock permits spell picks its own record forbids — Taken, 2026-09-04 (PR #713) — and the finding was largely WRONG. Taken — full text in `RETRO-AUDIT.closed.md` under its own `### R3` heading.

- **R4** — high — seven catalog skills say their conditional bonuses cannot be stored, and 29 sibling rows store exactly that — Taken, 2026-09-04 (PR #711) — as written, and the posture held: no flat — full text in `RETRO-AUDIT.closed.md` under its own `### R4` heading.

- **R5** — medium — eight class-referenced weapons carry their damage in prose while `gear.damage` is null — Taken, 2026-09-04 (PR #715) — all thirteen, not the eight. The finding — full text in `RETRO-AUDIT.closed.md` under its own `### R5` heading.

- **R6** — medium — three classes carry a mechanic the schema gained after they were imported — Taken, 2026-09-04 (PR #716) — and the medium confidence earned its keep: — full text in `RETRO-AUDIT.closed.md` under its own `### R6` heading.

- **R7** — medium — two capabilities were built, populated, and wired to nothing — Taken, 2026-09-04 (PR #718) — option (b), the finding's own recommendation. — full text in `RETRO-AUDIT.closed.md` under its own `### R7` heading.

- **R8** — low — a standing check, and it is not the capability-vs-date diff — Taken, 2026-09-04 (PR #717) — `scripts/retro-check.mjs`, ten capability — full text in `RETRO-AUDIT.closed.md` under its own `### R8` heading.

- **R9** — medium — the Crazy is missing the +3 Perception its own ability describes — Filed and taken the same day, 2026-09-04, which is why it sits after `R8` — full text in `RETRO-AUDIT.closed.md` under its own `### R9` heading.

- **R10** — high — `R2` shipped a false "not expressible" note, and both classes were left short — Taken, 2026-09-04 (PR #722) — as written. Composed once per option through — full text in `RETRO-AUDIT.closed.md` under its own `### R10` heading.

- **R11** — medium — six more classes carry a capability claim that is false today — The remaining six rows taken, 2026-09-04 (PR #726). R11 is closed. Twelve — full text in `RETRO-AUDIT.closed.md` under its own `### R11` heading.

- **R12** — high — the ten per-Force Warlocks described the class they replaced — Taken, 2026-09-04 (PR #727) — as written. All ten re-parse at 0 errors, — full text in `RETRO-AUDIT.closed.md` under its own `### R12` heading.

- **R13** — high — releasing the cross-category control-set claim, and what the release audit corrected — Filed and taken 2026-09-04 (PR #728), on Nate's word. `CLASS-AUDIT`'s — full text in `RETRO-AUDIT.closed.md` under its own `### R13` heading.

- **R14** — medium — five more classes carry a related-skill floor only in prose — Taken, 2026-09-05 (PR #729) — as written: five classes, seven notes, and — full text in `RETRO-AUDIT.closed.md` under its own `### R14` heading.

### The scope was wrong by two, and the finding's own query is why

**There are seven classes with this shape, not five.** `ley-line-walker` and
`ley-line-rifter` carry *"two of the seven must be from Science and one from
Technical"* and hold no `minimums`. R14's detection query missed them for
**exactly one reason**: they say *"must be from"* where it matched *"must come
from"*. It is an `instr()` over the whole record and reads no note at all, so
where in the record the sentence sits could not have hidden anything from it —
that blind spot belongs to `regression.mjs` and is `R16`. Keeping the two apart
matters, because whoever takes `R15` or `R16` will write a detection query of
their own. **Filed as `R15` below rather than folded in** — and not only for scope
discipline. Draft 285 has all seven related picks spent with **zero Science**,
so unlike these five, `R15` breaks something live the day it ships.

The lesson is the one `R8` already paid for once: **a detector built from the
phrasings you have found so far finds the phrasings you have already found.**
This is the second time in two days a hand-maintained phrase list has come up
short — `R12` was the first.

### Two claims in the finding were overstated, and one was exactly right

- **"The two unions are the shape `R13` just released"** — no. `categories:` and
  the one-element `category:` sugar landed together in PR #428
  (`BOOK-INGEST-AUDIT` `F6`, 2026-08-31), and `city-rat` has held a union in
  production since that day. `R13` released a **documentation claim**, not a
  capability. All five floors were expressible before either finding existed.
- **The union stated itself twice.** The soldier and the witch each carry that
  sentence in **both** named category notes, which reads like two floors of two
  and is one floor of two across a pair. That is why the proposal's *"rewrite
  each category note"* came to **seven** notes rather than five, and why the
  rewrites say `ONE union floor across the pair` in words.
- **`add-soldier-class.sql` really does carry the claim** — lines 18–23,
  *"no way to say 'two of the nine from this pair'"*, false from today. It is a
  `--` comment rather than data, so no rebuild repeats it into D1 and there is
  nothing to replace there; a one-shot script is not edited, so the data script
  for this finding is the correction of record and sorts after it. The knight,
  palladin, thief and witch scripts carry no such comment — checked, 2026-09-05.

### The proof, run with the right signature this time

`R11`'s outcome note claimed enforcement was proved by running
`relatedFloorStatus`, and `R13` recorded that the call had been malformed. This
one was run as `(cls, categoryNames, allowance)` and, before the script was
applied to production, **against production** — where it FAILED, `owed 0`, no
floor parsed. That is the check failing first; the same harness passes on all
five afterwards, 44 assertions:

| case | result |
|---|---|
| fresh build, nothing picked | **reachable** — creation is never blocked |
| every pick spent off the floor | **unreachable** → HTTP 422 |
| floor met, remainder anywhere | reachable |
| union met entirely from either side | reachable |
| union met one from each | reachable |
| one of the pair and the rest spent | **unreachable** — it is one floor, not two |
| exactly two picks left, none on the floor | reachable — a floor is not a ceiling |

The 422 comes from `_lib/validate-character.js` pushing `related_minimum` only
when `unreachable`, and it is wider than the finding said: `characters.js`
answers it on create, and `characters/[id]/picks.js`, `level-confirm.js` and
`variant.js` answer it on an **existing** character.

**`regression.mjs`'s floor invariant cannot see any of this**, which the
finding's *"ongoing cost: none"* did not anticipate — filed as `R16`. Not to be
confused with this menu's own *standing* check: `retro-check.mjs` (`R8`) is
blind to it too, for a third reason. It looks for a record that carries a key
while its prose denies it, and none of these five denied anything — they were
simply silent.

- **R15** — medium — the two Ley Line classes carry the same floor, and one live draft breaks — Taken, 2026-09-05 (PR #740) — as written: both classes, both floors, the — full text in `RETRO-AUDIT.closed.md` under its own `### R15` heading.

### The finding was wrong about the one thing that made it separate from R14

`R15` said draft 285 would be *"owed 2, remaining 0"* and refused — *"a real
person's half-built character refused by a rule the app did not have when they
started it."* **`owed 2` is right. `remaining 0` is not, and it inverts the
conclusion.**

**The draft is at level 3, and the allowance grows with the schedule.**
`relatedAllowance(cls, 3)` is `count: 7` plus the `{ level: 3, count: 2 }` grant
= **9**. So `owed 2, remaining 2`, and `unreachable` is `owed > remaining` —
false. **The server accepts the save.**

Better still, one of the two floors is already met:

| pick | catalog category |
|---|---|
| Swimming | Physical |
| Navigation | Pilot Related |
| **Language: Dragonese** | **Technical** |
| **Lore: Magic** | **Technical** |
| W.P. Revolver | Weapon Proficiencies |
| Identify Plants & Fruit | Wilderness |
| Radio: Basic | Communications |

**Technical is 2 of 1, with one to spare. Only Science is short**, by two, and
the two banked level-3 picks cover it. **The player loses nothing** — which is
not what this finding was taken on, and Nate should have it: the answer to *"they
re-pick"* turned out to be *"they spend two picks they had not spent yet."*

### Which leaves a real defect, and it is not this one

**The wizard will tell that player the opposite.** `app.js:2044-2046` passes
`cls.skills.occ_related_skills.count` as the allowance where the server passes
`relatedAllowance(cls, level)`:

```js
return relatedFloorStatus(cls, S.related.map((n) => index.get(n)?.category),
  cls?.skills?.occ_related_skills?.count);
```

So the review step renders *"the picks left cannot reach it — go back to Skills,
or the save will be refused"* on a character the server would accept. **That is
wrong today for every one of the thirty classes holding a floor, at any level
above one** — `R15` did not create it and does not carry it. **Filed as `R18`.**

The deferred half is real, though: if that player later spends the two banked
picks off-Science, `characters/[id]/picks.js` **will** answer 422.

### The proof, and the harness's own first attempt was wrong

Run against **production before the script applied**, where it failed — no floor
parsed, `owed 0`. Then, after applying:

| case | result |
|---|---|
| fresh level-1 build | reachable |
| 7 picks, none on either floor, level 1 | **unreachable** |
| the same 7 at level 3 | **still unreachable** — owed 3, remaining 2 |
| Technical met, Science short, level 3 | reachable — owed 2, remaining 2 |
| the same picks at level 1 | **unreachable** — the allowance is the difference |
| 3 Science, 0 Technical | **unreachable** — two floors, not one of three |

**My first version of row three asserted the opposite** and failed. Seven wholly
off-floor picks owe three, and level 3 banks only two, so they stay refused;
draft 285 is reachable because its Technical floor is already met. Getting that
backwards in a harness written to check exactly this is the same shape as the
finding's own error, caught the same way — by running it.

### Three things the release audit corrected in passing

- **The Rifter's note is not a bare cross-reference.** `R15`'s table quotes only
  *"Stats are the Ley Line Walker's"*; the note goes on to spell the floor out in
  full, which is why the detection query found it at all.
- **`add-ley-line-walker-class.sql` no longer owns the Walker's note** —
  `fix-pre-rue-class-audit.sql:387` wrote the live text. A replacement guarded on
  the `add-` script's wording would have silently done nothing. Both replacements
  here are matched against the live text.
- **Neither `add-` script carries a limitation claim** about the floor, checked.
  So unlike `R14`'s soldier there is no stale assertion to correct.

**And a readback in `R14`'s own applied script expires with this PR** —
*"the two ley line classes are untouched … want 0"* now reads `got 2`. A one-shot
script is not edited, so the inverse is asserted here, which sorts after it.

- **R18** — medium — the wizard counts related picks against the wrong allowance — Taken, 2026-09-05 (PR #745) — WIDENED, on Nate's word, and the widening is — full text in `RETRO-AUDIT.closed.md` under its own `### R18` heading.

### The finding was right about the bug and wrong about the fix

> *"It cannot fail the other way — the wizard's allowance is never larger than
> the server's — so this is a false alarm rather than a hole."*

**True of the code as it stood. False the moment you change only the allowance**,
because the allowance is only half of what the two sides disagree about. The
**held list** is the other half, and `R18` never mentions it:

- the server counts **every** row of `type: 'related'`, which includes the picks
  made on the Advancement step (`app.js` writes them that way);
- the wizard passed `S.related` alone — the level-one picks.

So the wizard was narrow on **both** numbers and the errors cancelled in the
safe direction. Raise one and it goes wide on that one and stays narrow on the
other:

| a Ley Line Walker at level 3, both banked picks spent off-Science | verdict |
|---|---|
| server | **422** — nine held, nine allowed, two owed, none left |
| wizard as it was | warns — by luck, but it warns |
| wizard with the allowance alone fixed | **silent** |
| wizard with both fixed | warns, agreeing with the server |

**That third row is the direction `R18`'s own text calls the one that matters.**
It is reachable through the wizard's own UI, not only a crafted request.

So both arguments now mirror the server: `relatedAllowance(cls, S.level)` and
`S.related` plus the related-kind rows of `levelPickRows()`.

### "The arithmetic already exists" understated it

`relatedAllowance` lived in `functions/`, and **the wizard cannot import from
there** — no build step, and nothing under `apps/` reaches into `functions/`.
Taking this meant **moving** the function, or writing the second copy the
finding says it is removing. It now lives in `apps/character-creator/js/leveling.js`
beside `skillGrantsFor`, the only thing it needs, and `validate-character.js`
re-exports it so every server import and `test/smoke.mjs` are unchanged. That is
the precedent `functions/.../_lib/leveling.js` already sets in its own header.

### Nothing in the suite touched this, so something does now

`app.js` is only ever read as **source text** by the smoke suite, never
executed, so this fix would neither break a test nor be verified by one. Six
checks were added against the lifted helper, and they pin the two boundary cases
rather than the happy path: **the false alarm** the old code produced, and **the
silent failure** a half-fix would have. `SMOKE TEST PASSED (1684 checks)`, up
from 1678.

### Verified in the browser, on the second attempt

**The first attempt failed and the outcome note said so.** The class picker
would not register a selection, leaving *"Choose 1 more power to continue"* and
a disabled Confirm — because the Ley Line Walker's own **Powers — choose 1**
block sits below the class list on that step and had not been answered. Named
here because that is the step, not a pane limitation.

Walked properly on 8793, served from this branch (the new comment, the new
import and the moved function all fetched off it), a **level 3** Ley Line Walker
with seven related picks spent — six Domestic/Communications and one Technical,
which is **draft 285's exact shape**:

> The book sets a floor per category: **0/2 Science**, 1/1 Technical.

Rendered, at tablet and at desktop, above the fold, with `0/2 Science` in the
warning colour and `1/1 Technical` muted — `f.met ? 'muted' : 'warn'` doing its
job on a real character rather than in a harness.

**And the numbers themselves, computed in the page from the modules the page
loaded**, against that draft's real picks:

| | allowance | owed | remaining | `unreachable` |
|---|---|---|---|---|
| the old wizard (`count`) | 7 | 2 | 0 | **true** — cries wolf |
| this fix (`relatedAllowance`) | **9** | 2 | 2 | **false** |
| the server | 9 | 2 | 2 | false — accepts the save |

**That is the whole finding, seen rather than argued**: the same character, the
same picks, one number apart, and the old wizard telling a player their save
would be refused when it would not.

*(A pane limitation did bite and is worth recording: a screenshot taken while
scrolled comes back blank, as `verify-ui` says. Proved against a control this
change never touched — the same page shot at `scrollY: 0` rendered fine — and
worked around by collapsing what sat above the block so it rendered at the top.)*

### A stale sentence, found by looking at the page

The block being edited told the player the scheduled picks were *"recorded on
the class, **not yet prompted at level-up**"*. They are prompted —
`level-confirm.js` banks and resolves them, `picks.js` spends them, and the
wizard's own Advancement step asks at creation. The release audit flagged it;
seeing it rendered is what made it worth fixing in the same PR. It now reads:

> Also grants +2 at level 3, +1 at level 6, +1 at level 9, +1 at level 12 —
> asked for on the Advancement step, and banked until spent if you skip them.
> They count toward the floors above, so a character at level three is measured
> against **9** picks rather than 7.

That last clause is the fix, stated to the player in the place the confusion
happens, and the 9 is computed rather than written down.

**The local wizard draft was snapshotted before the walk and restored after**,
byte-for-byte including its `updated_at`; the dev server's whole process tree
was killed by command line, leaving the other wrangler instance alone.

- **R16** — medium — the check that is supposed to catch the next floor cannot see any of the seven — Taken, 2026-09-05 (PR #741) — as written, and the posture held: test and — full text in `RETRO-AUDIT.closed.md` under its own `### R16` heading.

### Proved by making it fail, which is the only reason to believe it

A check that has only ever passed proves nothing. Re-run against the corpus with
the floors stripped back to where they were:

| corpus | widened check | old check |
|---|---|---|
| today | green, 29 flagged | green |
| before `R15` | **RED on 2** — the two Ley Line classes | green |
| before `R14` and `R15` | **RED on 7** | **green** |

**The last cell is the finding in one line.** With all seven floors removed the
old matcher stays green, because it flags eleven other classes and none of these
— exactly the blindness `R16` was filed for, now demonstrated rather than
argued.

### Two things written into the comment rather than the pattern

- **`naruni-repo-bot` is a live false-positive specimen, one word away.** Its
  note reads *"this book does it in at least a dozen entries and five is the
  most any of them bars"* — not a floor, and it holds none. It misses **only**
  because *"a dozen"* is not a numeral. Loosen that branch, or match a number
  anywhere in the same sentence rather than adjacent to the phrase, and that
  class goes red. The pattern keeps the numeral adjacent for this reason and the
  comment says so.
- **`techno-wizard` prints a sixth phrasing this still does not catch** — *"TWO
  of the seven must be Electrical or Mechanical skills"*, with no *"from"*. It
  holds its floor, so the check is silent rather than wrong. Left uncaught on
  purpose and named in the comment, as the standing example of what a
  hand-maintained phrase list costs. `R16`'s own *Ongoing cost* paragraph
  predicted this arriving with the next book; it was already in the corpus.

### A `TypeError` waiting on nearly half the entries

A `categories` entry is a bare **string** or an **object**: **716 and 900** of
them respectively across the live corpus, 126 of the objects carrying a note.
Reading `e.note` without a `typeof` guard throws on the strings, and the two
`R15` classes are the clean illustration — the Walker's `Science` is
`{ name: "Science", bonus: 10 }`, the Rifter's is the bare string `"Science"`.

### What this makes stale, corrected below

`R17` told its taker that `regression.mjs`'s *"eleven"* comments were correct and
must not be changed. **This PR removed them**, so that instruction is retired
where it stands rather than left to mislead.

- **R17** — low — six places say eight classes hold a floor, and twenty-eight do — Taken, 2026-09-05 (PR #742) — the count is dropped, not corrected, which — full text in `RETRO-AUDIT.closed.md` under its own `### R17` heading.

### It was six sites and a seventh, and two stale numbers rather than one

**`across four books` is wrong as well.** Every one of the six said *"eight
classes across four books"*, and **both halves** were stale — **thirty classes
across five books**, derived by parsing every published class on 2026-09-05
rather than by matching `minimums:`, which also matches `attribute_minimums:` on
fifteen of them:

| classes | book |
|---|---|
| 10 | Rifts Conversion Book One |
| 8 | Rifts Ultimate Edition |
| 6 | `palladium-fantasy-core` |
| 4 | Rifts Dimension Book 2: Phase World |
| 2 | Rifts World Book 10: Juicer Uprising |

`R17` did not say this. A taker dropping only *"eight classes"* would have left
the surviving half wrong, so both figures come out of all six.

**The seventh site is live data, and `R17`'s sweep could not have found it.**
`galactic-tracer`'s `extraction_notes`, in production, said the floor was
*"taken across all eleven classes in three books that print a floor like this"*
— a **different** wrong number, so a grep for the six never reached it. This is
exactly the surface `audit-menu` step 5 exists for, and it is the only one of
the seven that needed a data script
(`zzzzz-retro-r17-galactic-tracer-count.sql`, four readbacks, `--remote`).

The half of that note that records **what the book prints** is untouched — a
class note's book half is permanent and only the app-of-the-day half rots. The
floor itself is untouched too, and a readback asserts it.

### Two things went wrong while writing it, both caught by running it

- **The stored note is line-WRAPPED**, inside a YAML bullet with four-space
  continuation indents. The first version of the script matched it as one line,
  found nothing, and **silently did nothing** — a `replace()` that matches
  nothing is indistinguishable from one with nothing to do, which is the trap
  `docs/operations.md` records under the `zz-` escalation. The readback is what
  said so.
- **`instr()` is case-sensitive**, and the readback asserted a phrase whose
  casing I had changed in the replacement. It reported `got 0` on an edit that
  had actually landed.

### And one correction that could not be made here

`R17` told its taker that `regression.mjs`'s *"eleven"* comments were correct and
must not be touched. **`R16` removed them the same day**, so that instruction is
struck through above rather than left standing — retired in `R16`'s PR, which is
where the change was made.

**`fix-related-skill-minimums.sql` wrote the `galactic-tracer` sentence** and
its line 1 carries the same tally in a `--` comment. A one-shot script is not
edited and a comment is not data, so the data script above is the correction of
record and sorts after it.

- **R19** — low — four psionic powers are cited to a list page and carry no stat block — Taken, 2026-09-05 (PR #744) — folded into the spell backfill, as the finding — full text in `RETRO-AUDIT.closed.md` under its own `### R19` heading.

### An OCR trap that a careful reader would have stored wrong

`Deaden Senses` reads **`Duration: 216 minutes`** in the text layer. The same
line says *"roll for random determination of duration"* — which no fixed number
needs. Rendering the page shows it prints **`2D6`**; the D was read as a 1, the
same scanno family as the `ID6` and `IDS` forms elsewhere in these books. A
readback now asserts the dice form so a rebuild cannot quietly put `216` back.

**This is the second time on this job that rendering a page beat reading its
text layer**, the first being bom printed 84.

### One spell corrected on the way

`Realm of Chaos` stored **`ppe: 0`**; the Book of Magic printed 130 gives
*"P.P.E.: Seventy"*. A free 9th-level spell is the kind of wrong number noticed
at a table rather than in a query.

**Three spells legitimately cost nothing and were left alone** — `Death Curse`
prints *"P.P.E.: None/Special."*, and the two Wormwood level-0 entries are
abilities rather than costed invocations. The readback asserts **three**, not
zero, so a later sweep does not "fix" them.

- **R20** — low — the catalog and the book disagree about a dozen spell names — Taken, 2026-09-06 (PR #748) - EIGHT of the twelve, on Nate's word: the rows — full text in `RETRO-AUDIT.closed.md` under its own `### R20` heading.

### The mechanism this finding proposed does not work for spells

`R20` says a rename *"needs a `catalog_redirects` row so class markdown citing
the old key keeps resolving"*. **It does not.** A spell citation is resolved in
three places and none of them ever sees a redirect:

| where | what it does |
|---|---|
| `catalogs.js` | the wizard boot payload - selects `name, level, ppe, ...` from `spells` and sends no redirect table at all |
| `app.js:1626` and `app.js:2848`, read 2026-09-06 | filters a class's named list by **exact lowercased name** against that payload, and tells the player *"N named spells are not in the catalog yet"*. Two sites, not three - `grep -n "named.has(String"` returns five, and the other three (`1705`, `2908`, `2966`) filter `psiCatalog`, not spells |
| `_lib/power-picks.js` `loadPowerCatalog` | backs level-up confirm and `validate-character.js`. Only `loadPowerDescriptions` resolves redirects; the catalog loader does not |

So a bare rename **422s a level-up confirm in both directions**: the old name is
not in the catalog, and the new name is not on the list the grant draws from.

**And the repo had already answered this, twice, in writing.**
`fix-rue-spell-levels.sql` refuses five RUE spellings on exactly these grounds -
*"a citation is matched in the browser where catalog_redirects are not sent"* -
and `docs/spell-and-psionic-imports.md` restates it. `audit-menu` says a finding
may not fail to say a decision exists, and `R20` did not. The decision is not
binding here (these are Book-of-Magic Warlock rows, not RUE invocations) but a
taker needed to know it.

**The citations therefore move WITH the rename**, in the same script, and the
eight redirects are belt and braces for the importer's `crossReference()` rather
than the plan. They are the first spell redirects this database has ever held.

### The blast radius was understated by an order of magnitude

`R20` reads as one citation per class. Measured against production:
**134 occurrences across 11 classes** - the ten per-Force Warlocks and the
Fire/Water Elemental Fusionist - because each name repeats in every
**cumulative** level list. `Water: Breathe Underwater` alone appears in `L2`
through `L8` of five classes.

The precedent's warning that markdown is *"frontmatter mixed with lore prose"*
was answered by measurement rather than waved at: **all 134 sit in the YAML
frontmatter, zero in the prose body, and all 134 are double-quoted**. So the
replace matches the name *with its quotes* - which also makes it idempotent for
free on the one row whose old name is a prefix of its replacement, where an
unquoted replace would have compounded to `Essence & Intellect & Intellect` on
the second run.

### The four left alone, each for a reason that is not taste

- **`Fire: Fire Ball` and `Air: Wind Rush`.** RUE already supplies an unprefixed
  `Fire Ball` and `Wind Rush`, and `spells.name` is `UNIQUE`. The elemental
  prefix is doing precisely the job the book's own *"(Warlock)"* parenthetical
  does; adopting the book's wording trades a working disambiguator for a broken
  one and drops both rows out of the picker's `Fire:` / `Air:` filter.
- **`Water: Swim as a Fish: Superior`.** `stem()` drops a parenthetical, so the
  book's `(Superior)` would give the row the bare alias `swim as a fish`,
  already held by two others - the importer's refuse-to-match case. No test
  would have gone red, because the fixture pinning it is hardcoded.
- **`Water: Calm Waters (greater)`.** Verified on the pages: printed 84 at level
  3 / 15 PPE and printed 88 at level 8 / 100 PPE, matching the catalog's two
  rows exactly. The book disambiguates by position and the catalog cannot.

**The prefix is load-bearing and perfectly consistent**: 231 spells carry one,
231 spells cite the four elemental blocks on printed 57-90, and they are the
same 231 rows. All eight renames keep theirs, so that count did not move.

### The check that should have caught this walked two classes

`regression.mjs`'s *"every named spell list resolves against the catalog"*
iterated `['shifter', 'ley-line-rifter']`. **Eleven Warlock classes and 134
citations were outside it**, so renaming a Warlock spell could have broken every
Warlock in the catalog without turning the suite red. It now walks every
published class - 18 carry a draw-from list, 5,103 names between them - and the
per-class fetch went with it, since `GET /classes` already returns parsed
classes.

**Its normaliser was also looser than the app.** `norm()` strips punctuation,
while every path that resolves a citation for real compares the plain name. A
second check now asserts the exact match.

**Both were proved by making them fail, and the first attempt to do so was
wrong** - which is the part worth keeping. Reverting one citation to
`Fire: Heat Object/Boil Water` turned the *normalised* check red, not the exact
one, because `norm()` maps `&` to the word *"and"* rather than deleting it, so
that pair never collided. What only the exact check sees is punctuation `norm()`
strips outright: dropping the colon from `Water: Swim as a Fish: Superior` left
the first check green and the second red, across all seven of that class's
level lists. **The floor check went red on its own first run too** - it asserted
25 classes, reasoned from the 40 that carry a magic block, where 18 carry a
draw-from list.

### Two things the pages settled that the cache could not

- **Printed 84 is corrupt in the source PDF**, and it is where
  `Impervious to Ocean Depths` lives. Rendered with PyMuPDF and read by eye:
  folio, heading and *"P.P.E.: Twelve"* all legible, matching the row's level 3
  / 12 PPE.
- **`drift-check --remote` now carries one advisory**, and it is expected:
  `Water: Summon Sharks/Whales` reads as *"name absent from its text"* because
  the OCR renders the slash as an `l` (`Summon SharkslWhales`). The printed page
  was rendered too - **Summon Sharks/Whales**, a real forward slash, P.P.E.
  Fifty against the row's 50. The catalog is right and the checker cannot see
  it.

**One more disagreement worth recording:** printed 74's *summary list* spells
the fire spell `Heat Object/Boil Water` while its entry on printed 76 prints
`Heat Object & Boil Water`. **The book disagrees with itself**, and the entry
wins - the same rule that governed the citation repair, where every wrong
citation pointed at a summary list rather than an entry.

- **R21** — medium — `character_items.item_id` stores a number that means nothing outside one database — Taken, 2026-09-05 (PR #747) — ADDITIVE, on Nate's word: the column lands, — full text in `RETRO-AUDIT.closed.md` under its own `### R21` heading.

### The release audit found a defect the plan would have shipped

**The column could not be called `item_slug`.** `characters/[id].js` and
`campaigns/[id]/items.js` both alias `gear.slug AS item_slug` beside a
`SELECT <table>.*`, so a stored column of that name returns **two columns called
`item_slug`** and the row object silently keeps one — engine-dependent, and
`test/regression.mjs` matches on that alias to find the armour and weapon rows.
It is `gear_slug`.

### A decision this finding should have named

`docs/plans/03-items-to-gear.md` → *Scope of the change* says *"`character_items`
keeps its name and its `item_id` column"*, and `known-limitations.md:377` says
the same. **Those settled a different question** — *renaming* for naming purity
in PR #17, not *re-keying* for portability — so this is not a re-proposal. But
`audit-menu` says a finding may not fail to say a decision exists, and `R21`
did not.

### Why the drop is not here

- **SQLite refuses it while the `CHECK` names the column** — tested, not
  assumed: `no such column: item_id`. It needs a full table rebuild, and both
  tables carry indexes and outgoing foreign keys that `036`'s precedent
  explicitly did **not** have.
- **Ten committed data scripts join on `item_id`**, and `rebuild-local.mjs`
  replays every one — the repo's own portability check would start failing.
- **The smoke check that polices `schema-change` step 2 only understands
  `ALTER TABLE ADD COLUMN`**, so a rebuild-style migration is invisible to it.

The portability hazard closes the moment reads prefer the slug, which is now.

### What the audit found that R21's evidence method could not

`R21` cited *"both `REFERENCES gear(id)` lines read individually"*, and that
method only finds declared foreign keys. **`character_drafts.state` holds raw
gear ids in its JSON** — one live draft, two of them. So the wizard still POSTs
integers, and a draft saved before this deploy and resumed after it still will.
That is why every write **derives the slug from the id inside the same
statement** rather than expecting one from the client: there is no window and no
caller that can supply one key without the other.

### The cost of the slug, paid rather than discovered later

Held by id, inventory was insulated from a gear **rename**. Held by slug it is
not — and renaming a catalog row is a live admin path that has already been used
**twenty times** on skills. So the read falls through `catalog_redirects`, and a
smoke check proves the arm does real work by asserting the failing direction
too: *a plain slug join LOSES the row after a rename*, while the redirect arm
still resolves it. A third arm keeps a pre-`044` row resolving on its id alone.

The audit also noted an argument for `R21` that `R21` never made: a slug-keyed
row that missed a merge repoint becomes **recoverable** through
`catalog_redirects`, where an id-keyed one is simply wrong.

### Two things left standing, deliberately

- **`gear.slug` is `UNIQUE` but nullable.** Production is clean — 0 null or
  empty, 1025 distinct of 1025 — so the backfill was safe. Making it `NOT NULL`
  is a second table rebuild and belongs with the drop.
- **`R21`'s "ongoing cost: none" is now "one invariant"** until the drop: two
  columns that could disagree. `regression.mjs` asserts they do not, on a real
  round trip through the API.

**Also corrected in passing:** my own first version of that regression check
looked for the items under `character.items` and reported a join failure that
was its own — the payload returns `items` at the top level.

---

**The drop taken, 2026-09-06 (PR #749).** Migrations `045-inventory-check-on-slug.sql`
and `046-drop-inventory-item-id.sql`. `item_id` is gone from both tables and
`gear_slug` is the only key. **The first of the two things left standing above is
now done.** *(The second, `gear.slug NOT NULL`, was taken later the same day -
see the note below this one. This sentence said "still is not" when it was
written, which was true for about an hour.)*

### It took two migrations, and the second one is why

**The ordering rule is written for additive changes.** `ship-pr` says schema goes
to production *before* the merge, and gives the reason: *"code that expects a
column merged first is code running against a database that does not have it"*.
**A drop is the mirror image**, and following the rule literally would have
broken the live app:

| order | what breaks, for about one Pages deploy |
|---|---|
| migration first, then merge | the **character sheet 500s** — the deployed read still joins `gear.id = character_items.item_id` |
| merge first, then migration | **adding gear and finishing a character fail** — new code writes no `item_id`, the old `CHECK` still demands one |

So the change was split. `045` moves both `CHECK` constraints onto `gear_slug`
and touches nothing else; `046` drops the column. `045` goes before the merge as
the rule says, `046` after the deploy is live, and **at no moment is any
deployed code running against a schema it does not expect**.

**What makes that work is a decision `R21`'s first half already made.** Migration
`044` had every write derive the slug *inside its own statement*, so the
currently-deployed code populates `gear_slug` on every row — which is exactly
what lets it satisfy a `CHECK` on `gear_slug` without being redeployed first.

**The window was demonstrated rather than argued.** Against a scratch database at
each stage, running the two insert shapes verbatim:

| | deployed insert | merged insert |
|---|---|---|
| production today | accepted | **refused** — `CHECK constraint failed: item_id IS NOT NULL OR custom_name IS NOT NULL` |
| after `045` | accepted | accepted |
| after `046` | refused — `no column named item_id` | accepted |

The bottom-left cell is the only refusal that matters and it is by then
unreachable: that code is no longer deployed.

**One honest cost:** between the two applies, `drift-check --remote` reports
`MIGRATION NOT APPLIED: 046`. That is the tool being right.

### The rule this knowingly breaks

`docs/operations.md` says outright that **an applied data script is never
edited** — and the repo has already chosen the `zz-` sort-order workaround once
rather than edit three. **Ten scripts joined on `item_id` and all ten were
rewritten onto the slug.** Every alternative costs a rule too: leaving the column
in `schema.sql` while production loses it is schema drift `drift-check.mjs`
reports by design, and `no such column` is a prepare-time error no guard can
duck.

What makes it defensible rather than merely necessary is that the rewrite is
**provably equivalent** — `NOT EXISTS (… ci.item_id = gear.id)` and
`NOT EXISTS (… ci.gear_slug = gear.slug)` return the same rows, checked on a
fixture — so a rebuild produces what it always did. `rebuild-local.mjs`:
**392 files, 4,994 statements, 0 failures.**

### The defect the drop would have shipped silently

**`_lib/catalog-merge.js` repoints inventory when two gear rows are merged**, and
it bound `keepId` / `removeId` — integers, against what is now a text column.
A mechanical rename of the column alone would have left it matching **nothing**:
the merge would report success, delete the losing row, and leave every inventory
line pointing at a slug that no longer exists. It now binds `keep.slug` /
`remove.slug`, and `MERGE_REFS` carries a `key` field saying which catalog column
the reference stores.

Nothing would have caught it. Gear merges are a live admin path — twelve `merge`
redirects exist — and no test exercises one end to end.

### A read `R21`'s own PR missed

`campaigns/[id]/ask.js` still joined `g.id = ci.item_id`. **PR #747's outcome
note said the reads had moved to the slug and this one had not** — it feeds the
campaign "ask" prompt, which is not on the path any inventory test walks. It now
uses the same slug-plus-redirect join as the sheet.

### Noted, not fixed

**A gear merge repoints `character_items` and not `campaign_items`** —
`MERGE_REFS` names one table. That predates all of this and is left alone rather
than folded in. Worth recording that the drop *improves* it: a stash row left on
a merged-away slug now resolves through `catalog_redirects`, where an id-keyed
one was simply wrong.

---

**`gear.slug NOT NULL` taken, 2026-09-06 (PR #750).** Migration
`047-gear-slug-not-null.sql`, applied to production before the merge.
**`R21` now has nothing left standing.**

Re-measured for this rather than carried from the note above: **1,025 gear rows,
0 null, 0 empty, 1,025 distinct**. Afterwards: 1,025 rows, **max id 11199
preserved**, 12 gear redirects resolving, 78 inventory rows joining, both
indexes back, no leftover tables.

**No code change, and therefore no deploy window** — unlike `045`/`046`, which
needed two steps because a drop breaks deployed code. The database simply starts
refusing what the app already refused: `catalog-fields.js` marks gear's slug
`required: true` and `coerceField` counts `''` as blank, so no write path has
ever been able to produce one, and all **477** committed `INSERT INTO gear`
statements name the column.

### `036`'s precedent does not cover this, and its own header says so

`gear` is the first table here that anything **references** — `character_items`
and `campaign_items` both declare `gear_slug TEXT REFERENCES gear(slug)`.
`036`'s comment notes in passing that *"nothing references it by foreign key"*,
which is exactly the case this is not. Two ways of borrowing its pattern were
tried against local D1 and **both failed**:

| attempt | result |
|---|---|
| `PRAGMA foreign_keys = OFF` | **ignored.** D1 enforces anyway: *"FOREIGN KEY constraint failed"* |
| `PRAGMA defer_foreign_keys = ON` | **honoured, and still fails.** Enforcement moves to commit — *"the application left the database in a state where constraints were violated"* — because dropping the parent records one violation per orphaned child and recreating it afterwards does not clear them |

Both left the database untouched: D1 rolled the Durable Object back to its last
good state, which is the right failure.

**So the ORDER does the work and no `PRAGMA` is used.** Build `gear_new` with
the constraint; rebuild each child to reference `gear_new`; drop `gear`, now
unreferenced; rename `gear_new` to `gear`. Every step is legal with foreign keys
fully enforced throughout — three tables rebuilt to change one column.

The last step rests on SQLite rewriting the children's `REFERENCES` clauses to
follow a rename, **so that was probed rather than trusted**: a throwaway parent
and child on local D1, renamed, and the child read back out of `sqlite_master`
as `REFERENCES "zz_parent_new"(slug)`. Production's children now read
`REFERENCES "gear"(slug)` — quoted, which is cosmetic, and `drift-check
--remote` is clean.

### What it deliberately does not do

**It does not refuse an empty string.** `NOT NULL` is what this finding asked
for, and `''` would satisfy it while joining to nothing — the same hazard in a
different disguise. Unreachable through the API today, and closing it in the
database needs a `CHECK (slug <> '')`, which is a further decision and a fourth
rebuild. Recorded here rather than left to be discovered.

---

## Not established

Recorded rather than resolved by inference.

- **54 of the 101 limitation claims were left unsettled**, roughly 21 of them
  because this pass's own sweep truncated them mid-clause. The rest are book
  prose asserting no app limitation, or provenance notes about how a class was
  transcribed. **A re-sweep bounded on the YAML block would judge them**; this
  one could not.
  **Settled 2026-09-05: `R11` ran exactly that re-sweep, the same day this was
  written.** Bounding on YAML structure rather than sentence boundaries gave
  **198 whole units across 103 classes - 185 hold, 9 carry a false assertion, 4
  could not be settled** - against 47 judged and 54 unsettled here. The nine are
  `R11`'s table and all were taken (PRs #725, #726). **The four that remain
  unsettled are the only survivors of this bullet**, and they are named under
  `R11` rather than repeated here.
- **The Robot Pilot's *"the gear catalog carries no open-market power armour
  rows"*.** There are four power-armour rows and three carry a price
  (`samas-power-armor`, `ng-jk1-juicer-killer-power-armor`,
  `psionic-power-armor`; `glitter-boy-power-armor` has none). Whether the claim
  is false depends on whether *open-market* means civilian-purchasable — the
  SAMAS is Coalition military issue and the NG-JK1 is a Northern Gun commercial
  product. **That is a wording judgement, not a measurement**, and no amount of
  re-querying settles it.
- ~~Whether `magic.spells_from` is needed per-variant on the Warlock~~ —
  **settled 2026-09-04 by `R3`, and the question dissolved rather than being
  answered.** There is no variant to need one: the generic Warlock was retired
  (soft-deleted 2026-09-04 22:03:59) and replaced by ten classes, one per
  Elemental Force and one per pair. All ten carry `spell_lists` and
  `magic.spells_from` and **none carries a `variants:` block** - checked
  `--remote`, 2026-09-05. `R12` then had to rewrite the notes on all ten,
  because they had been generated from the class this bullet was written about
  and still described it.
- **The five unreferenced gear rows in `R5`** (`knife-large`, `roman-candle`,
  `acid-organic`, `acid-cleanser`, `acid-metal-dissolver`) — no class cites them,
  so nothing turns on whether they are filled.
- **Per-row provenance for catalog rows does not exist** and was not
  reconstructed. Every catalog finding here rests on the row's *content*, not on
  a date.
- ~~Whether `crazy` is missing a `combat.perception` grant.~~ **Settled
  2026-09-04 by reading the page. It was real — see `R9` below.**
