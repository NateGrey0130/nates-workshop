# RETRO-AUDIT.md — does the catalog benefit from the schema it grew?

> **Work is open on this menu, and this line will not say which findings.**
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

### R1 — high — five classes deny a key they already carry (note rot; no data is wrong)

Each of these five records states that the app cannot express something, **while
the same record carries the key that expresses it.** The data is right and the
only prose about it is wrong, which is worse than either alone — it tells the
next reader not to try, and `CLASS-AUDIT` `S4` records the identical shape on the
Godling.

| class | the claim it carries | what the same record holds |
|---|---|---|
| `gambler` | *"cannot be expressed in the picker"* | `occ_related_skills.minimums` |
| `juicer-wannabe` | *"cannot be expressed in the picker either"* | `occ_related_skills.minimums` |
| `spacer` | *"Apply it by hand"*, *"the saves list is a fixed sixteen"* | `bonuses.saves.other` |
| `wilderness-scout` | *"Perception has no bonus key, left as prose"* | `combat: { … perception: 3 }` |
| `crazy` | *"category exclusions are prose-only"* | `categories_allowed[].except` |

Established by reading each record back from production:

```bash
node scripts/q.mjs --remote "SELECT class_id, markdown LIKE '%minimums%' AS has_key, markdown LIKE '%cannot be expressed in the picker%' AS has_claim FROM imported_classes WHERE class_id IN ('gambler','juicer-wannabe') AND deleted_at IS NULL"
```

**The wilderness-scout one hides from a naive match**, and this is the trap worth
carrying forward: the stored note wraps as `(Perception\n    has no bonus key`,
so a search for the phrase returns nothing. `CLASS-AUDIT` `S4` recorded the same
wrap on the Godling. **Normalise whitespace before matching a stored note.**

**Proposal:** one `fix-` data script rewriting the five notes to say what is
true, naming the key each class already carries. **Posture: prose only. No
mechanic, no column, no bonus value changes** — and the script's readbacks must
assert every affected key is still present, so "no data change" is proved rather
than claimed, the way `fix-godling-skill-category-bonuses-note.sql` did.

**Evidence:** production `--remote`, 2026-09-04, command above.
**Confidence: very high** — each class was read back individually and the key and
the claim were both confirmed present in the same record.
**Ongoing cost:** none. `R8` is what would stop it recurring.

**Taken, 2026-09-04 (PR #712)** — posture held exactly: **prose only, no mechanic,
no column, no bonus value changed**, and eight readbacks assert it rather than
claiming it. Five of the eight check that the key each note denied is *still
present* after the rewrite.

**`audit-premise-auditor` changed the scope in three ways before anything was
written, and every one of them mattered.** The finding as filed would have
shipped two errors:

- **Two of the sentences R1 quoted are TRUE and are untouched.** `spacer`'s *"The
  saves list is a fixed sixteen and none of them is a vacuum"* is correct —
  `SAVE_FIELDS` in `apps/character-creator/sheet.js` is exactly sixteen entries
  and none is a vacuum, confirmed by reading it. What was false was the
  *conclusion* drawn from it, that the bonus is therefore not on the sheet;
  `otherSaves()` renders `bonuses.saves.other` **after** those sixteen. And
  `crazy`'s sentence is compound — *"The per-level ISP growth and category
  exclusions are prose-only"* — of which only the second half is false. The
  per-level I.S.P. half is right in the sense meant: `parser.js` warns outright
  that `bonuses.at_level.pools` is not applied, so the growth belongs in the
  `isp_base` formula, where the class already puts it. **A sweep that replaced
  either sentence whole would have turned a true claim into a false one**, which
  is the failure `reference/negatives.md` exists to score.
- **R1 quoted the weaker of `spacer`'s two false sentences.** Its
  `extraction_notes` carry a flatly false one the finding never named — *"THE
  ONLY BONUS THIS CLASS HAS IS NOT STORED, and `bonuses` is empty because of
  it"* — which is the sentence most likely to stop the next reader. Both are
  rewritten here; a PR taking R1 as written would have left it standing.
- **`juicer-wannabe`'s mid-campaign conversion sentence is on `CLASS-AUDIT`'s
  *"Checked and still true"* list** and sits in the same paragraph. Untouched,
  and the rewritten sentence beside it now says so explicitly.

**The wrap trap fired exactly as the finding predicted.** `wilderness-scout`'s
note is stored as `(Perception` + newline + `    has no bonus key`, so the
replacement had to be built with `char(10)` and the original indentation — the
convention `add-noro-psionic-power-armor.sql` already uses. All five classes
re-parse through the real parser at **0 errors** after the edit, which is the
check that the YAML block scalars survived.

**Found while doing the work, and NOT folded in:** `crazy` carries
`bonuses.combat: { initiative: 2, attacks: 1, roll: 4 }` with **no `perception`**,
while its own Heightened Senses ability opens *"+3 on Perception Rolls even when
acting silly and bouncing around"*, which reads unconditional. `CLASS-AUDIT` `F8`
granted `combat.perception` to twelve classes and named its deliberate
exclusions; `crazy` is in neither list. That is a possible **missing mechanic**,
not note rot, and settling it needs RUE printed 53-57. Recorded under *Not
established* rather than fixed here, because a prose-only PR is exactly the PR
that would have walked past it.

### R2 — high — `demon-goblin` and `monk` keep whole skill packages in prose, and `skills.mos` grants them

This is the **Merc Soldier defect, still live in two more classes.** Both records
assert in capitals that the app cannot grant skills conditionally on a choice:

- `demon-goblin`: *"THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin,
  thief and spy - AND THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE"*,
  and *"Each profession's full list and exact percentages are on its own ability,
  to be applied by hand."*
- `monk`: *"THE AREA OF MASTERY GRANTS SKILLS, AND THE APP CANNOT GRANT THEM
  CONDITIONALLY"*, and *"the skills are recorded in prose and have to be added by
  hand."*

`skills.mos` is exactly "N complete skill packages, pick one" — `choose` plus
`options: [{ id, name, skills: [...] }]`, validated by `validateMos` at
`apps/character-creator/js/parser.js:184`. It is neither `variants` (which
cannot override `skills` — `CLASS-AUDIT`'s *"Checked and still true"* list) nor
`special_abilities` (whose `ABILITY_GRANTS` is three keys and excludes skills).
It is a third, separate mechanism, available since **2026-08-21** (migration
`031-character-mos.sql`, and the code that reads it).

Three classes use it and neither of these is among them:

```bash
node scripts/q.mjs --remote "SELECT group_concat(class_id, ', ') AS using_mos FROM imported_classes WHERE markdown LIKE '%  mos:%' AND status='published' AND deleted_at IS NULL"
```
→ `merc-soldier, robot-pilot, coalition-technical-officer`

**It is fully wired and user-visible**, which is why this is a player-facing gap
and not a documentation one: the wizard renders the option picker
(`apps/character-creator/app.js:2141`), the choice is stored on `characters.mos`
(migration `031`), and `apps/character-creator/js/compose.js:380` folds the
chosen option's skills into the composed class so they land on the sheet with
their percentages.

**Proposal:** transcribe both classes' packages from the book into `skills.mos`
blocks, in one `fix-` script covering both — the shape
`fix-merc-soldier-and-robot-pilot-mos.sql` already established, which is
precedent for a `fix-` touching two classes. Rewrite both notes in the same
script per the `claim-audit` rule. **Posture: data change, and it grants skills
a character does not have today** — so bases must be catalog base plus the
printed bonus, and any book name resolving to a different catalog spelling
carries a note saying so.

**Evidence:** production `--remote`, 2026-09-04; claim text from the
`claim-capability-verifier` pass, re-confirmed by the command above.
**Confidence: high** that the capability fits and both classes lack it.
**Medium** on scope until the pages are read — neither package has been counted
against the book yet, and `CLASS-AUDIT` `F17` is the standing warning that a
finding's size is the part most likely to be wrong.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #714)** — as written, both classes in one `fix-` script,
the shape `fix-merc-soldier-and-robot-pilot-mos.sql` established. **The premises
held and the medium-confidence scope resolved upward**: it is six packages, not
two classes' worth of hand-waving.

Read from the `ww` OCR cache — **printed 123-124** for the demon-goblin,
**printed 60-61** for the monk. `scripts/books.json` gives Wormwood a **zero**
page offset, so printed N is cache `pNNN`; reading the registry rather than
assuming `+1` is what put the pass on the right pages.

| class | options | skills granted |
|---|---|---|
| `demon-goblin` | Assassin / Thief / Spy | 13 / 15 / 13 |
| `monk` | Defense / Offense / Meditation | 3 / 3 / 6 |

**Both classes independently confirmed the transcription**, which is the check
worth having. The demon-goblin's own note already recorded the per-profession
bonuses — *"prowl +10/+5/+10, climbing +10/+5/+5, land navigation +10/+5/+10,
streetwise +4/+6/+8"* — and all twelve match what was read off the page. The
monk's note listed all three masteries' skills, and they match too.

**The demon-goblin was worse off than the finding said.** Land Navigation, Prowl,
Palming, Climbing, Streetwise and its two languages sat in `occ_skills` at their
**catalog base with no bonus applied at all**, under a note saying the bonus
"differs and is recorded on each" — so every demon-goblin was short every one of
those bonuses regardless of profession. They now sit on their own option with
their own number. Leaving them in `occ_skills` as well would have **doubled**
them: `applyMos()` appends to `occ_skills` rather than merging, which was checked
in `apps/character-creator/js/compose.js` before the script was written.

**Moving them is safe because the pick is server-enforced.**
`functions/api/character-creator/_lib/validate-character.js` refuses to save a
character with an unchosen MOS (`rule: 'mos_unchosen'`), and production holds
**zero** demon-goblin and monk characters.

**The regression suite caught the pin, as designed.** `MOS_PACKAGES` in
`apps/character-creator/test/regression.mjs` names the exact set of classes with
an MOS and asserts *"no other class has one"*; adding two made it red until the
list was updated in the same commit. 237 checks → **243**.

**A shell trap bit on the way through and is worth recording:** `node
test/regression.mjs | tail -3` exits with `tail`'s status, so a chained
`&& d1-apply --remote` ran while the suite was red. The failure was the pin
above and nothing was wrong with the data, but the apply should not have
started. **Redirect to a file and read `$?`** — the `windows-shell` skill's
pipe-discards-the-exit-code rule, met in the wild.

**What still will not fit** is on each option's `mos` note rather than dropped:
the open weapon-proficiency picks (*"one W.P. of choice"*, *"two W.P.s of choice
from any category"*, and the monk's two/four/two), the spy's one additional
language of choice, and the assassin's *"+5% on all acrobatic skills"* — which
needs the per-skill modifier `CLASS-AUDIT`'s *"Checked and still true"* list
records as absent.

> **The paragraph above was WRONG about the weapon-proficiency picks and the
> language, and it shipped.** They are expressible, they were expressible the day
> `R2` was taken, and both classes were left short of them until `R10` (below,
> PR #722). **The assassin's acrobatic modifier is the only part of that sentence
> that survived.** Left standing above rather than edited, because an outcome note
> is a record of what was believed at the time — but do not read it as current.

### R3 — high — the Warlock permits spell picks its own record forbids

`warlock` carries `spells_starting: 3` and `spell_levels_allowed: [1]` and **no
`spells_from`**, so the picker offers every first-level spell in the catalog. The
class record says both halves of why that is wrong:

> *"A warlock cannot learn spell magic of any other kind."*
> *"the wizard's spell picker filters by level, not by sphere."*

`magic.spells_from` arrived **2026-08-26** as code rather than a column
(`spells_from` in `apps/character-creator/js/leveling.js:295`, read by
`startingGroups`), which is the source the brief warns is missed because it has
no migration. The Warlock was imported **2026-08-19**.

**Both Elemental Fusionists received exactly this fix on the day the capability
landed** — `CLASS-AUDIT` `S1`, `fix-rue-elemental-fusionist-spells.sql` — and
they draw from the same sphere-tagged catalog rows (`Air: …`, `Fire: …`). The
Warlock is the archetypal elemental caster and was not revisited.

```bash
node scripts/q.mjs --remote "SELECT class_id, markdown LIKE '%spells_from%' AS has_spells_from FROM imported_classes WHERE class_id IN ('warlock','elemental-fusionist-fire-water','elemental-fusionist-earth-air') AND deleted_at IS NULL"
```

**Proposal:** a `fix-` script giving the Warlock `spells_from` bounded to its
chosen Force's sphere list, following the Fusionist shape, and rewriting the note.
**Posture: data change that NARROWS what a player may pick.** That is the right
direction here — the current state permits loadouts the book forbids — but it is
the direction that can break an existing character, so check for saved Warlocks
before applying.

**Evidence:** production `--remote`, 2026-09-04; class markdown read directly.
**Confidence: high** on the defect. **Medium** on the fix's shape until the
one-Force/two-Force rule is settled: the class's own note says
`spells_starting` is the one-Force figure and the two-Force rule lives in an
ability, so a naive `spells_from` may need to be per-variant.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #713) — and the finding was largely WRONG.** Taken
note-only on Nate's word, and the note records the error rather than
implementing the proposal.

**The defect is real; the diagnosis was not.** R3 read this as the Elemental
Fusionist case (`CLASS-AUDIT` `S1`) left undone. It is not the same case. The
Fusionists' orientation is fixed **by the class** — there are two of them,
`elemental-fusionist-fire-water` and `elemental-fusionist-earth-air` — so a
class-level `spells_from` names exactly the right spells. The Warlock's Force is
chosen **per character**, and its variants are `one-force` and `two-forces`:
they record *how many* Forces, not *which*. There is no field anywhere for "this
Warlock chose Fire".

**So `magic.spells_from` cannot fix it.** The union of all four spheres is 37
level-1 spells where a Fire Warlock should see 9, against 50 level-1 spells in
the catalog — a quarter of the way, and it would look complete. That is `S7`'s
Dog Boy objection, and the reason this was not shipped.

```bash
node scripts/q.mjs --remote "SELECT substr(name,1,instr(name,':')-1) AS sphere, count(*) AS n, sum(level=1) AS lvl1 FROM spells WHERE name LIKE 'Air:%' OR name LIKE 'Earth:%' OR name LIKE 'Fire:%' OR name LIKE 'Water:%' GROUP BY sphere"
```
→ 231 elemental spells, 37 at level 1 (Air 7, Earth 11, Fire 9, Water 10).

**R3 called a TRUE note stale, which is the failure a claim sweep cannot score
itself on.** The class's `extraction_notes` already say, accurately: *"The
ELEMENT choice itself is per-character and has no schema shape … the wizard's
spell picker filters by level, not by sphere"*, and they name the filter-box
workaround. R3 quoted half that sentence as evidence of a gap. **It is left
exactly as it stands, and a readback asserts it survived.**

**Two things were genuinely wrong and both are fixed.** A restriction said the
variant *"records which"* Force — it records how many. And **nothing anywhere
recorded that the picker lets a Warlock take non-elemental magic**, which the
class's own summary forbids outright; that is the real, undocumented defect
underneath R3, and it is now written where the next reader will find it.

**The route that works is per-Force classes**, the way the Fusionists are split
— an import decision rather than a transcription, and Nate's. Same conclusion
`CLASS-AUDIT` `S8` reached for the Goblin Cobbler. **No mechanic moved:** a
readback asserts no `spells_from:` key was added.

**One readback had to be rewritten because it quoted its own replacement text.**
The new note mentions `magic.spells_from` in prose, so `instr(markdown,
'spells_from') = 0` could never pass. It matches the YAML key with its colon
instead. Zero saved Warlock characters exist, so nothing could have broken
either way.

**Taken a second time, 2026-09-04 (PR #723) — the import decision, on Nate's
word.** The note-only pass above closed the false sentences; this one builds
what the note said was the route that works.

**Ten classes**, one per Elemental Force and one per pair, generated from the
generic one so everything but `magic`, `ppe_base` and
`attribute_requirements` is byte-identical to what it replaces:
`warlock-air`, `-earth`, `-fire`, `-water`, and `-air-earth`, `-air-fire`,
`-air-water`, `-earth-fire`, `-earth-water`, `-fire-water`.

**The generic `warlock` is retired**, soft-deleted per migration 003.
`retire-warlock-generic.sql` sorts after every `add-warlock-*` file, so a clean
rebuild adds the ten and then retires the one. Narrowing it instead would have
left a row offering a Fire Warlock the Air spells — `CLASS-AUDIT` `S7`'s
half-modelled objection — under a name a player would reasonably pick.

**The rule, from Conversion Book One printed 67** (`cb1` cache `p068`, offset 1):
three spells at first level from the sphere's own first-level list and three more
each level for one Force; **two** per level, one from *each* sphere, for two —
*"the character only gets two spell selections per level of experience, instead
of three"* — with I.Q. 12 / M.E. 14 required. *"Elemental Magic goes up to eighth
level only"*, and all 231 elemental spells in the catalog sit at spell level 1-8,
which corroborates it.

**A named `from` list REPLACES the spell-level cap rather than combining with
it**, so the cap lives inside the lists: one cumulative list per spell level,
with the schedule pointing each experience level at the right one and levels
9-15 all pointing at `L8`.

**Verified through the real machinery at every level of all ten**, not spot
checked: starting picks 3 (or 1+1), per-level grants 3 (or 1 from each sphere),
no off-sphere spell in any list, and no list offering a spell above the
character's cap. A two-Force class's two grants are asserted to draw from
*different* spheres.

**Three things the suites caught that the finding did not mention**, each a real
defect rather than a pin:

- **`CORE_SDC_BY_CLASS` had no entry for any of the ten**, so every new Warlock
  would have saved with `sdc_max` NULL. All ten inherit the generic one's `1D6`,
  and its row **stays** so an existing character holding the retired class is not
  left with a NULL either.
- **Two races pointed `occ_restrictions.only` at the retired id.** `norse-giant`
  and `scorpion-person` both name `warlock`, and that reference fails **open** —
  the pairing would simply vanish from the picker with no error. Both now name
  all ten, because neither book restricts *which* Force.
- **The regression check for the Warlock's XP table looked up `id === 'warlock'`**
  and would have passed vacuously on `undefined` once the class was gone. It now
  checks all ten and asserts there are ten.

Pinned counts moved with it: classes 160 → **169**, and *"Seventy-seven of
one-hundred-and-sixty"* → *"Eighty-six of one-hundred-and-sixty-nine"*.
`drift-check --remote` reads **169 published live, 170 creatable from the repo** —
the extra being the retired generic class, which the repo can still recreate.

### R4 — high — seven catalog skills say their conditional bonuses cannot be stored, and 29 sibling rows store exactly that

Seven `skills` rows carry a note explaining that what they grant is conditional
*and therefore not stored*:

`Fencing`, `Robot Combat: Basic`, `Robot Combat Elite: Glitter Boy`,
`Fighter Combat: Basic`, `Fighter Combat: Elite`, `Sniper`, `Weapon Systems`.

Five of them say it in nearly the same words — *"ALL of them apply only while
piloting … so none is stored (they would otherwise follow the pilot on foot)"* —
and `Fencing` cites migration 023 by number.

**The reason is false.** A `level_bonuses` entry may carry `applies_when`:
`skillConditionalBonuses()` at `apps/character-creator/js/parser.js:650` totals
them per condition, `bonusesFromSkills` at `:698` deliberately holds them **out**
of the unconditional combat block, and `apps/character-creator/sheet.js:1523`
renders each as a labelled conditional row. The comment beside that hold-back
names Fencing as the case it was built for.

It is not theoretical — it is the dominant shape in that column:

```bash
node scripts/q.mjs --remote "SELECT count(*) AS with_level_bonuses, sum(level_bonuses LIKE '%applies_when%') AS with_applies_when FROM skills WHERE level_bonuses IS NOT NULL"
```
→ 36 with a schedule, **29 of them using `applies_when`** (W.P. Sword, W.P.
Knife, W.P. Blunt, W.P. Shield and the rest).

**Proposal:** move each skill's conditional bonuses into `level_bonuses` entries
with an `applies_when` string, and rewrite the seven notes. **Posture: data
change, additive** — these bonuses do not reach the unconditional combat block
either before or after, so no derived total moves; what changes is that the
sheet gains a conditional row it should always have had.

**What must NOT move with it**, and each is on `CLASS-AUDIT`'s *"Checked and
still true"* list or follows from it: Fencing's **+1D6 damage** is dice-valued
and stays prose; `Robot Combat Elite: Glitter Boy`'s level-gated extra attacks
belong in the schedule's own `level` field rather than a note, but its
`attacks_base` semantics differ from an additive bonus (migration
`025-skill-level-bonuses.sql` says `attacks_base` SETS rather than adds).

**Evidence:** production `--remote`, 2026-09-04, command above; code paths read
at the lines cited.
**Confidence: very high** on the capability. **High** on the seven rows.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #711)** — as written, and the posture held: **no flat
`bonuses` value was added to any of the seven**, which is asserted by a readback
rather than claimed. All seven now carry a `level_bonuses` schedule with
`applies_when`; the count of skills using that shape went 29 → 36, which is the
arithmetic the script's last readback checks.

**The finding was right and incomplete, and the missing half was a rendering
one.** Storing the data was necessary and not sufficient: the sheet listed these
under a heading reading *"Weapon proficiencies — these apply only with that
weapon"*, which is wrong for *"while piloting the Glitter Boy"*, and `WP_LABELS`
in `apps/character-creator/sheet.js` had no short form for `attacks`, `roll` or
`pull_punch`, so the fallback would have printed the raw column name —
`+4 pull_punch`. Both were fixed in this PR: the heading is now *"Conditional
bonuses — these apply only in the situation named"*. **`skillRows` was never
filtered to W.P.s**, which is why the data renders at all; that was checked
before the script was written, because a filter there would have made the whole
finding a no-op.

**Two prose surfaces cited the old state and were corrected in the same PR**, per
the `claim-audit` rule. `apps/character-creator/docs/leveling.md` said *"A
conditional bonus in `combat` would apply unconditionally, which is the same
reason Fencing carries its bonuses as a note"* — Fencing is now the example of
the `applies_when` shape rather than of prose — and its heading *"A W.P. bonus
applies only with that weapon"* is now *"A conditional bonus applies only in the
situation named"*. No link pointed at the old anchor; checked by grep before
renaming.

**The local apply caught two conventions the finding did not mention**, both
worth the next taker's time: `check` is a reserved word in SQLite, so
`SELECT … AS check` is a syntax error; and the smoke suite refuses a data script
that guards an underscored key with `LIKE`, because `_` is a single-character
**wildcard** — `LIKE '%applies_when%'` also matches `applies?when`. The readbacks
use `instr()` instead. Re-running the production count under `instr` returned the
same 29, so this menu's figure was not affected.

**Verified in the running sheet, not only in the tests.** A level-12 character
carrying Fencing, W.P. Sword, Fighter Combat: Elite and Robot Combat Elite:
Glitter Boy renders five conditional rows with the right per-level accumulation
(Glitter Boy +5 attacks at level 12: 2 at level 1, +1 each at 3, 7 and 11) —
**and the Combat block above still reads 0 for strike, parry, dodge, initiative
and pull punch**, which is the "nothing regressed" claim shown rather than
asserted. Measured against the box that clips it: 274×220 inside a 294px
`.box-body`, no row overflowing, no horizontal body scroll.

### R5 — medium — eight class-referenced weapons carry their damage in prose while `gear.damage` is null

Thirteen `gear` rows print a damage figure in `description` and hold `damage`
NULL. Eight of the thirteen are referenced by at least one published class's
starting equipment, so a character created in those classes gets a weapon whose
play-mode weapon card shows no damage.

```bash
node scripts/q.mjs --remote "SELECT slug, damage, substr(description,1,60) AS d FROM gear WHERE damage IS NULL AND description GLOB '*Does [0-9]D[0-9]*'"
```

`hunting-knife` (2 classes), `large-axe` (2), `bone-knife` (2),
`iron-javelin-rod` (1), `wooden-spear` (1), `pocket-knife` (1),
`hand-axe-utility` (1), `knife-small` (1) — plus `knife-large`, `roman-candle`
and three `acid-*` rows referenced by none.

**This one is read downstream, and most of the gear stat block is not** — which
is the whole reason it is a finding and `cost_note` below is not.
`functions/api/character-creator/characters/[id].js:33` joins
`gear.category`, `gear.damage` and `gear.payload` for play mode's weapon cards.

**The `sdc` help text in `apps/character-creator/js/catalog-fields.js` already
says where these belong**: *"Not the '1D6 S.D.C.' a knife deals, which is
Damage."* So the destination column is not in doubt.

**Proposal:** a `backfill-` script setting `damage` on the eight class-referenced
rows from the figure already in their own `description`. **Posture: data only,
no schema, and the description text stays** — it is the row's provenance and
removing it would trade one gap for another.
**Scope deliberately excludes the five unreferenced rows**; they can ride along
if that is cheaper, and nothing turns on them.

**Evidence:** production `--remote`, 2026-09-04, command above; class references
counted by searching all 160 published class markdowns for each slug.
**Confidence: high.** The pattern `Does NDN` returned 13 rows and every one is a
real damage figure — no false positive in the set.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #715)** — **all thirteen**, not the eight. The finding
said the five unreferenced rows could ride along if cheaper; they are four
`UPDATE`s in the same script, so they did.

**The confidence held exactly: 13 candidates, 13 real, no false positive.** That
makes the `Does NDN` pattern the highest-precision detector in this whole pass —
higher than detector 1∩3, and it needed no capability timeline.

**Posture held: the value was COPIED, not moved.** A readback asserts all
thirteen descriptions still carry the figure. Removing it would have traded one
gap for another, since `description` is the row's provenance and the sentence the
catalog editor shows.

**`sdc` was deliberately left NULL on all thirteen**, and a readback asserts it.
What these rows print is what the item **deals**, and `sdc` is what an object
**takes** — the exact confusion the `sdc` help text in
`apps/character-creator/js/catalog-fields.js` warns about by name: *"Not the '1D6
S.D.C.' a knife deals, which is Damage."*

**The four magic rows are written as printed** rather than flattened to a die,
per the `damage` help text's own example: `acid-metal-dissolver` carries *"3D6
per melee round for three minutes to metal; 2D4 per melee round for four melees
to organic materials, leather and skin"*. A single die would have lost the rule.

**This is the only part of the gear stat block that reaches a player**, which is
why R5 stopped at `damage` and `R7` records the rest:
`functions/api/character-creator/characters/[id].js` joins `gear.category`,
`gear.damage` and `gear.payload` for play mode's weapon cards, and selects no
other stat.

### R6 — medium — three classes carry a mechanic the schema gained after they were imported

Three separate capabilities, one class each, all found by detector 2 and all
read by something the player sees:

- **`freelancer`** — *"the dice halves (+1D4 P.E., +1D4 P.P., +4D6 Spd, 1D4x10
  M.D.C.) are rolled by hand and stay in the description."* `bonuses.attributes`
  takes a dice string (`DICE_BONUS`, `apps/character-creator/js/parser.js:1213`)
  and `bonuses.pools` takes a dice expression (`POOL_BONUS_KEYS` at `:1199`).
  Rolled once at creation and persisted as `attribute_bonuses` (migration
  `016-character-attribute-bonuses.sql`).
- **`dragon-hatchling-royal-frilled`** — *"the format having no way to say so per
  entry"*, about which psionic schedule entries are Super. `powers_schedule[]`
  carries `categories` per entry (migration `029-power-pick-categories.sql`,
  2026-08-21), and several entries may share a level, told apart by `slot`
  (migration `030-power-pick-slots.sql`).
- **`seljuk`** — *"a rule about which class pairs with this race, which
  `occ_restrictions` cannot express by name."* `occ_restrictions` takes
  `only:`/`except:` lists of class ids (`occAllowedForRace`,
  `apps/character-creator/js/parser.js:1829`), and `psi-stalker` is an **O.C.C.**
  in this catalog, not an R.C.C., so it can be named.

**One of the three may already be enforced from the other side.** `psi-stalker`
carries `race_restrictions: only: ["none"]` (human-only), so `raceAllowedForOcc`
already refuses the seljuk pairing. If that holds, `seljuk` is note rot (`R1`'s
kind) rather than a missing mechanic — **check before scoping it.**

**Proposal:** one `fix-` script per class, or one covering all three; the note
rewrite rides with each. **Posture: data change. The `seljuk` half may collapse
to prose-only** — do not assume it is a mechanic until the pairing is tested.

**Evidence:** `claim-capability-verifier` pass, 2026-09-04, against production;
code paths at the lines cited. **The three were not individually re-confirmed
against production the way `R1`'s five were.**
**Confidence: medium**, and that last sentence is why. Raise it by reading each
class back before scoping.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #716)** — and the medium confidence earned its keep:
**checking each part before scoping changed two of the three.**

**`dragon-hatchling-royal-frilled` — real, and much worse than filed.** R6 said
the class could not mark which psionic schedule entries are Super. True — and the
schedule was also **wrong**. Re-read from the book (Rifts Ultimate Edition
**printed 162**, `rue` cache `p165`, the registry's `+3` offset):

> *"a total of 12 psychic powers from … Sensitive, Physical, and/or Healing. Also
> select two Super Psionic Powers at level one. Select an additional Super
> Psi-Power at levels 5, 9, 14, 18 and 22. Select an additional two psychic
> powers from any of the three previous categories … at levels 3, 6, 9, 12, 15,
> 18 and 21."*

Production held `powers_starting: 12`, so **every royal frilled hatchling was two
Super powers short at creation**; the Super grants at levels **9 and 18 were
missing entirely**, level 18's ordinary pair had been collapsed to a single
entry, and levels **21 and 22 were absent**. Now `powers_starting_groups` splits
the level-one pick (12 + 2) and every entry states its own `categories`. Two
entries share levels 9 and 18 — `slot` is derived by position in
`apps/character-creator/js/leveling.js`, so nothing states it by hand.

Verified through the real `startingGroups` and `psionicGrantsFor`: Super at
**5, 9, 14, 18, 22** and two ordinary at **3, 6, 9, 12, 15, 18, 21**, matching
the page.

**`freelancer` — real, as filed.** Both attribute entries on the Special
Freelancer's chart now carry their dice halves: `{ PS: 6, PE: "1d4" }` with
`pools: { mdc: "1d4x10" }`, and `{ PP: "1d4", Spd: "4d6" }`. The Godling's
abilities were already this exact shape.

**`seljuk` — NOT a mechanic. Note rot, exactly as R6 predicted.** The claim that
`occ_restrictions` "cannot express by name" which class pairs with a race is
false as a statement about the schema. But the rule is **already enforced from
the other side**: `psi-stalker` and `wild-psi-stalker` both carry
`race_restrictions: only: ["none"]`, so `raceAllowedForOcc` refuses the pairing
for every race. **No `occ_restrictions` block was added**, and a readback asserts
it — a second copy of a working rule is a second place to get it wrong.

**The readback-quotes-its-own-phrase trap fired again**, for the second time in
this menu after `R3`. Each correction quotes the sentence it replaces, so an
assertion greping the limitation wording matches its own replacement text. The
assertions match phrases unique to the **old** text instead.

### R7 — medium — two capabilities were built, populated, and wired to nothing

Found by accident, by asking *who reads this* rather than *who sets this* — which
is the question none of the four detectors asks, and the reason this is the
finding most likely to generalise.

- **`variant_note` is read by no JavaScript in the repo.** Migration
  `033-variant-note.sql` (2026-08-22) added it to `spells` and
  `psionic_powers`; 18 spells and 2 psionic powers carry one. It appears in no
  API projection, and not in `apps/character-creator/js/catalog-fields.js`, so it
  is not even editable in the catalog admin UI. Written by data scripts, rendered
  nowhere.
- **Most of the gear stat block reaches no runtime surface.** `gear.sdc`, `ar`,
  `mdc`, `range` and `rate_of_fire` are selected by no endpoint.
  `functions/api/character-creator/items.js:12` projects eight columns and none
  is a stat; the character join at
  `functions/api/character-creator/characters/[id].js:33` takes `category`,
  `damage` and `payload` and nothing else. **Migration `034-gear-sdc.sql`
  justified itself on the grounds that S.D.C. in free text is somewhere "no sheet
  and no arithmetic can reach"** — and no sheet reaches the column either.

```bash
grep -rn "variant_note" --include=*.js apps/ functions/ scripts/
```
→ no matches.

**Proposal — and this one may well decline itself.** Two honest options, and the
choice is Nate's: (a) wire the columns to a surface, which is real UI work for
data nobody has asked to see; or (b) write down, in
`apps/character-creator/docs/operations.md` beside the migration table, that
these columns are stored-but-unrendered, so the next audit does not rediscover
it as a defect. **Posture: documentation only under (b), which is the
recommendation** — the ongoing cost of (a) is a rendering surface to maintain
for a field with 20 rows.

**What this finding does NOT claim:** that the columns are useless. `variant_note`
is provenance and `gear.sdc` is arithmetic waiting for a sheet that does armour.
The defect is that nothing says so.

**Evidence:** grep above and the two projections read at the lines cited,
2026-09-04.
**Confidence: high** on the facts; **the proposal is a decision, not a
measurement**, and re-measuring cannot settle it.
**Ongoing cost:** (b) is one paragraph. (a) is a permanent surface.

**Taken, 2026-09-04 (PR #718) — option (b), the finding's own recommendation.**
Documentation only. No column was wired to a surface, and none was removed.

A new section, *"Some of those columns are stored but not rendered"*, sits
directly beneath the migration table in
`apps/character-creator/docs/operations.md`, immediately before its
*"One database, and the case for keeping it that way"* heading. That table is
where a migration states what it adds — the repo's own `CLAUDE.md` calls it
*"the one place each migration says what it adds"* — so the caveat now sits
where a reader meets the promise.

**The facts were re-measured on the day rather than carried from the finding**,
and one number moved: it is **18 spells + 2 psionic powers** with a
`variant_note`, **34** gear rows with an `sdc` and **243** with a `cost_note` —
277 stored values across columns nothing renders. The `variant_note` grep still
returns nothing, and the only `gear.sdc`-shaped hit anywhere in `functions/` is
a **character's own pools** in `characters.js`, not a gear projection.

**The section says what IS served**, because that is the half a reader needs:
three columns, and only on a character's own items — `gear.category`,
`gear.damage` and `gear.payload`, for play mode's weapon cards. The picker
projects eight columns and not one is a stat.

**It does not propose wiring anything up**, and says so. `034-gear-sdc.sql` was
not wrong to move S.D.C. out of prose — a column can be queried, corrected and
counted where a sentence cannot — but the payoff its own text named, *"no sheet
and no arithmetic can reach"*, has not arrived, and building a surface for a
field nobody has asked to see is a worse trade than saying so once.

**This is the finding this pass is least sure was worth filing and most sure was
worth writing down.** It was found by accident, by asking *who reads this* rather
than *who sets this* — the question none of the four detectors asks, and the one
that would have caught it years earlier.

### R8 — low — a standing check, and it is not the capability-vs-date diff

The brief asked whether this becomes `scripts/retro-check.mjs` run after every
migration. **On the evidence above, not in that shape** — a capability-vs-date
check is 11% precision and cannot improve, and `scripts/class-check.mjs`'s own
header already names what that does: *"a script that exited non-zero on them
would train you to stop reading the output."*

The check that does work needs **no capability timeline, no import dates and no
book**: a record that carries a key while its own prose denies that key. It is a
self-contradiction inside one record, so there is no false-positive class — a
record cannot both carry a key and truthfully say the key does not exist.

Prototyped during this audit against all 160 published classes: **5 hits in
0.1 seconds, offline** — exactly `R1`'s five, which the subagent took thirteen
minutes to reach.

**It must normalise whitespace before matching.** The prototype found four of the
five until it did; `wilderness-scout`'s note wraps mid-phrase, the same trap
`CLASS-AUDIT` `S4` recorded on the Godling.

**What it cannot see, stated so its silence is not read as coverage:** the other
half of this menu. `demon-goblin` and `monk` have no `mos` key to contradict, so
`R2` is invisible to it, as are `R3` and `R5`. **That half stays a periodic claim
sweep and cannot be mechanised** — which is the honest answer to the brief's
standing-check question: a check for one half, a sweep for the other.

**Proposal:** add `scripts/retro-check.mjs` carrying the key/denial pairs, run
by hand and after a migration lands. **Posture: advisory, reports only, NO exit
code and no CI gate** — the `UNMODELLED` posture `class-check` already
established, and for the same reason.

**Evidence:** prototype run against a production snapshot of all 160 published
classes, 2026-09-04; the five hits match `R1` exactly.
**Confidence: high** that it finds `R1`'s shape. **Low** that the pair list stays
current on its own — it is a hand-maintained list, the same honest shape
`KNOWN_KEYS` in `scripts/class-check-lib.mjs` takes, and it will need an entry
each time a capability is added.
**Ongoing cost: real, and the reason this is `low` rather than higher.** One more
list to update when a capability lands, and nothing makes it fire.

**Taken, 2026-09-04 (PR #717)** — `scripts/retro-check.mjs`, ten capability
pairs, posture exactly as proposed: **reports only, no exit code, no CI gate.**

**It found its own design flaw on the first run, which is the best thing about
it.** It reported `spacer` and `dragon-hatchling-royal-frilled` — both corrected
hours earlier by `R1` and `R6`. Their corrected notes **quote the sentence they
corrected**, because that is what a correction does and what `audit-menu` asks
for, so the denial phrase survives in the record forever and a naive matcher
reports every fix as the defect. This is the hole `scripts/menu-check.mjs`
documents about quoted specimens, reached independently. A denial sitting within
260 characters of a finding citation is now reported as a **quotation, not a
claim** — printed under its own heading rather than dropped, because the check
cannot tell a quotation from a claim that merely happens to cite something.

**It proves itself before it reports, and that was not in the proposal.** A check
whose healthy answer is *"nothing to report"* is indistinguishable from a regex
that silently stopped matching, and this menu's own `R1` was found by a detector
that had only ever produced plausible output. So every pair is fired at a
specimen of the defect it looks for — verbatim pre-fix text from the classes
`R1` and `R6` corrected — before any real class is read, and it prints
`7/7 pairs matched their own specimen, 3 unproven (no specimen)`. **The
unproven three say so rather than passing quietly**, which is the honest state
for a hand-maintained list.

**Proved by making it fail**, not by watching it pass: breaking one `deny` regex
produces `*** retro-check SELF-TEST FAILED - do not trust the report below ***`
and names the pair.

**Against production today it reports NOTHING**, which is the right answer — `R1`'s
five are fixed. The `wilderness-scout` whitespace trap is carried in the code as
the reason for normalising, since that hit was invisible until it did.

**The smoke suite caught the documentation step**, as it did for
`deploy-sweep.mjs` in `HEALTH-AUDIT` `F20`: *"every script in `scripts/` is named
in the file map"*. The README entry landed in the same commit.

### R9 — medium — the Crazy is missing the +3 Perception its own ability describes

**Filed and taken the same day, 2026-09-04**, which is why it sits after `R8`
rather than in severity order. It began under *Not established* and moved here
when the page was read.

`crazy` carried `bonuses.combat: { initiative: 2, attacks: 1, roll: 4 }` and **no
`perception`**, while its M.O.M. Induced Abilities prose describes a +3.

**The book settles it, and it is unconditional.** Rifts Ultimate Edition
**printed 55** (`rue` cache `p058`, the registry's `+3` offset), item 5:

> *"Enhanced Senses: +3 on Perception Rolls even when acting silly and bouncing
> around, or seemingly bored. Very alert."*

The clause *"even when acting silly and bouncing around"* is the book saying the
bonus never lapses — so it belongs in `bonuses`, not in an `applies_when` entry.

**The rest of the class was already right**, which is what makes this a single
dropped value rather than a bad import: items 1-4 on the same page give +2
initiative, +1 attack, +4 roll with impact and 1D6 to P.P. with a minimum of 17,
and the class carries all of them, plus its `2d4`/`4d6`/`1d6`/`1d6` attribute
dice and the P.S. 19 minimum. Only item 5's number was left in prose.

**Nothing recorded whether it had been considered.** `CLASS-AUDIT` `F8` granted
`combat.perception` to twelve classes in
`apps/character-creator/db/fix-perception-bonuses.sql` and named three deliberate
exclusions; `crazy` was on **neither** list.

```bash
node scripts/q.mjs --remote "SELECT class_id, instr(markdown,'perception: 3')>0 AS has_it FROM imported_classes WHERE class_id='crazy'"
```

**Proposal:** add `perception: 3` to the existing combat block and say in the
ability's prose where it now lives. **Posture: one bonus value, nothing else
moved** — readbacks assert the other three combat bonuses, the attribute dice and
both minimums are unchanged.

**Evidence:** the page above, read 2026-09-04; production `--remote` for the
stored state.
**Confidence: high.** The book text is unambiguous and the surrounding values all
match, so a transcription error in the other direction is ruled out.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #719)** — as written. `crazy` re-parses at **0 errors and
0 warnings**, and its combat block reads
`{"initiative":2,"attacks":1,"roll":4,"perception":3}`.

**How it was found is the part worth keeping.** **None of this menu's four
detectors saw it.** It has no key to contradict, so `R8`'s check is blind to it;
it post-dates nothing, so the capability diff is blind to it; and its note is not
a limitation claim, so the sweep was blind to it. It surfaced only because
`audit-premise-auditor` was checking `R1`'s premises and looked at the class
beside them — **a prose-only PR is exactly the PR that walks past a missing
mechanic.** That is an argument for running the premise check on every finding,
not for a fifth detector.

### R10 — high — `R2` shipped a false "not expressible" note, and both classes were left short

**This menu's own work was the defect.** `R2` (PR #714) gave the demon-goblin and
the monk their MOS packages and wrote on both `mos` blocks: *"NOT EXPRESSIBLE
HERE … the open weapon-proficiency picks"*. That was false when it was written.

**An MOS option takes the same skill entries `occ_skills` does, choice groups
included**, and `validateSkillEntries` says so in its own header:

> *"occ_skills uses it and so does every MOS option, because a book that says
> 'gain all skills under that MOS' is describing the same list in a smaller box."*

`isChoiceGroup` (`apps/character-creator/js/parser.js:41`) admits `categories`,
and the parser documents that form as *"when the book says 'any N skills from
&lt;category&gt;'"*. `Weapon Proficiencies` is a real catalog category, and
eleven-plus published classes already use that literal group in `occ_skills`.

**So the classes were short of exactly what `R2` claimed to have rescued.** A
monk taking the Arts of Offense was **four** weapon proficiencies short; Defense
and Meditation two each; the demon-goblin's assassin two, its thief one, its spy
two plus a language.

```bash
node scripts/q.mjs --remote "SELECT class_id, instr(markdown,'categories: [\"Weapon Proficiencies\"]')>0 AS has_group FROM imported_classes WHERE class_id IN ('monk','demon-goblin')"
```

**Proposal:** add the choice groups to all six options and rewrite both notes.
**Posture: additive. Nothing `R2` granted moves** — a readback asserts its named
skills are still present.

**Evidence:** the claim re-sweep of 2026-09-04, which re-read `R2`'s own note as
a claim and disagreed with it; parser paths read at the lines cited.
**Confidence: very high.** The parser's own comment states the rule.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #722)** — as written. Composed once per option through
the real `composeClass`: assassin 14, thief 16, spy 15, defense 4, offense 4,
meditation 7 granted entries, no duplicates, every name in the live catalog, and
`class-check --remote` reads `ready — 0 errors` for both.

**What survived of `R2`'s sentence is one clause, checked rather than assumed:**
the assassin's *"+5% on all acrobatic skills"*. The assassin package grants **no
acrobatic skill at all**, so it modifies skills obtained elsewhere — the
race-level per-skill modifier `CLASS-AUDIT`'s *"Checked and still true"* list
records as absent. Newly stated and not in `R2`: the catalog does not divide
Weapon Proficiencies into ancient and modern, so the assassin's and thief's
groups are **broader than the book** by that much. That is on the option, rather
than used as a reason to grant nothing — which is the mistake this finding
exists to undo.

**Why the first sweep could not have caught it:** `R2`'s note did not exist yet.
The re-sweep read it because it re-read the whole corpus after the day's changes,
which is an argument for re-sweeping **after** a batch of fixes rather than only
before one.

### R11 — medium — six more classes carry a capability claim that is false today

**FILED, NOT TAKEN.** Everything above was taken on 2026-09-04; this is what the
claim re-sweep turned up beyond `R10`, recorded so it is not lost.

The re-sweep bounded claims on **YAML structure** rather than sentence
boundaries, which is what the first sweep got wrong: 198 whole units across 103
classes, of which **185 hold, 9 carry a false assertion and 4 could not be
settled** — against 47 judged and 54 unsettled the first time.

| class | the claim | what expresses it |
|---|---|---|
| `ley-line-rifter` | *"the picker cannot restrict to a named list"*, and *"several List A spells are not yet in the spell catalog"* | **both false.** `spells_starting_groups` with a per-group `from`; and all 17 List A names are in the catalog |
| `psi-mystic` | *"the block cannot say three from one and two from the other two"* | `psionics.powers_starting_groups` — the same key `R6` gave the royal-frilled |
| `techno-wizard` | *"a composition constraint the count field cannot express"* | `occ_related_skills.minimums`, in its **union** spelling — live on `city-rat` |
| the ten Warlocks | the same sentence, inherited from the generic class by `R3` | the same key |
| `apok` | *"bonuses.attributes takes flat numbers only"* | a **positive** dice string is fine; the supernatural-P.S. half of that note still holds |
| `wormspeaker` | *"dice or percentages that bonuses.attributes cannot take"* | `+1D6 M.E.` and `+1D4 M.A.` are storable; `-1D4 Spd` and "halved" still are not |
| `merc-soldier` | *"The MOS system … has no schema shape"* | the class **carries a live `mos` block**; this paragraph was simply never rewritten when the block landed |

**`ley-line-rifter` is the one to take first**, and it is the largest: six
starting spell picks sit in prose, the machinery is already in that class's own
row (`spell_lists: A` and `B`, used by its `spells_schedule`), and both the
wizard and the server read it.

```bash
node scripts/q.mjs --remote "SELECT class_id, instr(markdown,'a composition constraint the count field cannot express')>0 AS has_claim FROM imported_classes WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL"
```
→ all ten.

**A control-set tension this menu will not resolve on its own.** `CLASS-AUDIT`'s
*"Checked and still true"* list says `occ_related_skills` **cannot** span a
constraint across two categories, naming the assassin, the juicer-wannabe and the
merc-soldier. But `minimums` takes a `categories` union — `city-rat` carries
`{ count: 3, categories: ["Physical", "Rogue"] }` in production — and the
juicer-wannabe half of that line was closed by `R1` today. **That sentence needs
re-verifying by a person**; the sweep deliberately did not touch the assassin
claim, which is a control-set member.

**Four units are unsettled**, all the same shape: whether a verbose-but-working
spelling counts as *expressible* — a 13-entry schedule for "two per level from
third", and duplicate same-name entries in a category list, which are untested.
Those are rulings, not measurements.

**Evidence:** the `claim-capability-verifier` re-sweep of 2026-09-04, over a
corpus rebuilt from production after that day's twelve merges; the command above
re-run against `--remote`.
**Confidence: medium-high** on the seven stale claims — each names a code path
the pass cited, but **none was independently re-confirmed the way `R1`'s five
were**, and that is the gap to close before scoping any of them.
**Ongoing cost:** none.

**`ley-line-rifter` taken, 2026-09-04 (PR #725). The other six rows stay open.**

Both halves of the sentence were false, as filed. But `audit-premise-auditor`
found the finding's *guidance* wrong in a way that would have shipped a silent
defect, and that is the part worth keeping.

**`from_list` was silently ignored in a starting group.** R11 said *"the
machinery is already in that class's own row … and both the wizard and the server
read it"*. True of the **schedule** path, false of the **starting** path:
`startingGroups` read only an inline `from`, so `{ count: 4, from_list: "A" }`
dropped the list **and kept `spell_levels_allowed: [1, 2]`** — rendering a picker
of level-1 and level-2 spells containing **none** of List A, whose lowest entry
is spell level 4. No error, no violation, nothing logged, and `class-check`
cannot see it either: `KNOWN_KEYS` validates top-level frontmatter and never
looks inside `magic`. Confirmed by running it both ways before writing anything.

**It had already cost something.** `add-warlock-*-class.sql` — shipped by `R3`
hours earlier — writes its starting groups with inline `from`, duplicating lists
that `spell_lists` declares four lines below. That was this limit, worked around
without knowing why.

So the fix is an **app change plus the data**: `startingGroups` now resolves
`from_list` against the block's `spell_lists`, mirroring `spellNamesForGrant`.
Additive — of the **14** classes carrying a starting-groups block in production,
**zero** use `from_list`, so none of them moves.

**The book gives four groups, not two, and R11 undercounted.** RUE **printed
117** (`rue` cache `p120`, offset 3): *"Select three spells from (Invocation)
spell level one and three from level two. Then select four from List A and two
from List B."* R11 called it *"six starting spell picks in prose"*; the other six
were **also wrong**, granted as one pool of six over levels 1-2 so a Rifter could
take six level-two spells. Fixed in the same edit — it is the same six lines of
YAML, and `ley-line-rifter-spells-per-level.sql` had already flagged *"four
separate starting groups"* and deferred it. `spells_starting` is the total, so 6
became 12.

**The premise audit's own "nothing breaks" was wrong, and a readback caught it.**
It reported zero characters on this class, having queried `class_id` only — a
Ley Line Rifter is an **O.C.C.**, so it lives in `occ_class_id`. There is **one**
live character. The change cannot refuse them, and that was **proved rather than
reasoned**: the real `validateCharacter` was run against that character's actual
`powers` with the class before and after — **zero spell violations both times**.
It is structurally safe (allowance rises, the level gate is unchanged at {1,2},
and 38 list names are *added* to what passes), and the readback now asserts that
safety property instead of a headcount.

**Left alone deliberately:** that character now holds 6 of the 12 spells the book
gives, a shortfall this finding *revealed* rather than caused. Topping up someone
else's character is not a data fix.

**The remaining six rows taken, 2026-09-04 (PR #726). R11 is closed.** Twelve
classes moved; the claim sentences and the code paths held for all six, and what
did **not** hold was R11's guidance.

**The posture R11 never stated, and it is half the change.** `psi-mystic`, `apok`
and `wormspeaker` only change what a picker offers. But `minimums` on
`techno-wizard` and the ten Warlocks is **enforcement**: `relatedFloorStatus`
feeds `validate-character.js`, which raises a `related_minimum` violation, and
`functions/api/character-creator/characters.js` answers **HTTP 422**. Eleven
classes moved from prose a player may ignore to a save that is refused. Proved by
running `relatedFloorStatus` against the techno-wizard's own block with seven
off-category picks: `unreachable: true`.

**Row 1 needed an app change, and R11 implied data-only.** Giving an *occupation*
`powers_starting_groups` **defeated the max-of-two composition rule**:
`parser.js` takes the higher of the race's and the occupation's
`powers_starting`, but the groups are a plain spread so the occupation's win, and
`startingGroups` read only the groups. Measured before the fix — a
`chiang-ku-dragon` (7) taking the Psi-Mystic (5) silently dropped to **5**.
`startingGroups` now returns the surplus as one more pick under the block's own
gate; after the fix the same pairing composes to 7 again. **None of the fourteen
classes carrying a starting-groups block moves**, because their groups already
sum to their count.

**The book was re-read for row 1**, because both R11 rows resolved before it had
moved on one. This time the class's note was exactly right — Palladium Fantasy,
*"three powers from the sensitive category and two from either the physical or
healing category"* (`pf` cache `p161`; the entry runs printed 159-160 and the
class cites 160).

**Signed dice are a hard parse error, which is a better answer than the finding
had.** `DICE_BONUS` is anchored on a digit, so `"+1d6"` is rejected **loudly**.
Rows 4 and 5 are written unsigned, and the wormspeaker's `-1D4 Spd` and *"P.B.
halved"* therefore genuinely cannot be stored — the half of its claim that
survives, now with a reason that runs rather than an inference.

**`merc-soldier` was false in a second place.** Its note also said *"the
restriction above says to apply one by hand"*; the restriction says the
opposite, and has since `fix-merc-soldier-and-robot-pilot-mos.sql`. Both
corrected. Its **GM Notes still transcribe all seven packages** beside the live
block — left alone, being an import decision rather than a note fix.

**Two things deliberately untouched, each asserted by a readback.**
`wolfen-quatoria` also mentions `bonuses.attributes` and its claim is **true**
(the block *adds* to a rolled value, wrong for a fixed conversion attribute). And
**the `assassin`** — see below.

**`CLASS-AUDIT`'s control-set sentence is stale, and this pass did not touch it.**
*"`occ_related_skills` cannot span a constraint across two categories (assassin,
juicer-wannabe, merc-soldier's either/or groups)"* fails on all three examples:
the assassin's rule is expressible today as one single-category floor plus one
union floor; the juicer-wannabe was closed by `R1`; and the merc-soldier's
either/or is entirely *within* one category, so it was misattributed from the
start. **That last clause is WRONG, and `R13` corrected it on 2026-09-04:** the
Demolition skills are `category = Military` and the W.P.s are
`Weapon Proficiencies`, so it *does* span two categories and is *still* not
expressible — an **exclusive** or, in a `mos` option where `minimums` does not
exist. Left standing because an outcome note is a record of what was believed. **Releasing a control-set claim is Nate's, not a sweep's** — recorded
here, and the assassin's sentence is asserted unchanged.

**A third instance of the quotation trap, in a new place.** The readback for
"no class still denies these" failed until it was scoped: `promethean-phase-adept`
contains *"bonuses.attributes takes flat numbers only"* because its note
**quotes the apok's claim in order to refute it** — the repo held the refutation
before R11 filed the finding. The trap has now appeared in a replacement text
(`R3`), in a checker (`R8`), and in a third class's note.

### R12 — high — the ten per-Force Warlocks described the class they replaced

**This menu's own doing, for the second time.** `R3` (PR #723) generated the ten
per-Force Warlocks from the generic one and copied its `extraction_notes` and
`restrictions` verbatim. Three passages were true of the class being replaced and
**false of all ten replacing it, from the moment they shipped**:

| the note said | what is true of these ten |
|---|---|
| *"The ELEMENT choice itself is per-character and has no schema shape: a class is static"* | the element **is** the class; there are ten of them |
| *"a first-level Warlock is offered all 50 level-1 spells … `magic.spells_from` could narrow that to the 37 … but not to the 9 a Fire Warlock should see"* | each carries exactly its own sphere's list — the whole point of them |
| *"the variant records HOW MANY, not which … a Fire Warlock and an Air Warlock are the same class"* | the `variants` block was **removed** when these were generated |

```bash
node scripts/q.mjs --remote "SELECT count(*) AS n FROM imported_classes WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL AND instr(markdown,'The ELEMENT choice itself is per-character')>0"
```

**`scripts/retro-check.mjs` did not catch it**, and that is the finding inside
the finding. Its `magic.spells_from` pair looks for *"record picks by hand"* and
*"not yet in the spell catalog"*; none of the three passages uses that wording.
**`R8` named this exact cost** — a hand-maintained pair list needing an entry
each time a capability is added — and it arrived within the day.

**Proposal:** rewrite the three passages on all ten. **Posture: prose only.** The
mechanics are untouched and readbacks assert it — the four one-Force classes
still start with three spells at I.Q. 6 / M.E. 10, the six two-Force with two at
I.Q. 12 / M.E. 14, and all ten keep their sphere lists and their related-skill
floor.

**Evidence:** production `--remote`, 2026-09-04, command above.
**Confidence: very high.** All ten carry the passages byte-identically — they
came from one generator — which was checked before a single statement was
written.
**Ongoing cost:** none.

**Taken, 2026-09-04 (PR #727)** — as written. All ten re-parse at **0 errors**,
and the spell machinery re-verifies unchanged: starting picks and every level
2-15 still correct, no off-sphere spell, no list above the cap.

**The lesson is not "check generated classes".** It is that **generating a class
from another one copies its notes, and a note is about the class it was written
for.** `R3` verified the mechanics of all ten exhaustively and never re-read the
prose it had carried across. Every mechanical check passed; what was wrong was
the only part no check reads.

**Caught by asking what was outstanding**, not by any detector — the same way
`R9` surfaced. That is twice now that the honest inventory found more than the
tooling did.

### R13 — high — releasing the cross-category control-set claim, and what the release audit corrected

**Filed and taken 2026-09-04 (PR #728), on Nate's word.** `CLASS-AUDIT`'s
*"Checked and still true (do not fix these)"* list is the one thing a sweep may
not edit; releasing an entry is his call, and he made it.

**The release audit stopped a bad edit.** `R11`'s outcome note said the entry was
stale *"in all three of its examples"*, giving as the reason that the
merc-soldier's either/or is *"entirely within one category"*. **That is wrong.**
Its rule is *"two W.P.s of choice, OR two Demolition skills"* — and all three
Demolition rows are `category = Military` while W.P.s are
`Weapon Proficiencies`:

```bash
node scripts/q.mjs --remote "SELECT name, category FROM skills WHERE lower(name) LIKE '%demolition%'"
```
→ three rows, all `Military`.

So it **does** span two categories, and it is **still not expressible**: it is an
**exclusive** or, where a union floor would permit one of each and the book
forbids that, and it sits in a `mos` option, where `minimums` does not exist at
all. Deleting the sentence would have thrown away a true instance.

**The juicer-wannabe was never an instance either**, in the opposite direction:
it carries two *independent single-category* floors, which is an AND of two
simple floors rather than a span.

**So only the assassin demonstrates that a span became expressible**, and only
the assassin is fixed:

```yaml
minimums:
  - { count: 2, category: "Espionage" }
  - { count: 2, categories: ["Physical", "Rogue"] }
```

Read off the page rather than the class's note — Palladium Fantasy printed 95
(`pf` cache `p097`, offset 2): *"Select two espionage skills, two rogue or
physical skills and five other skills of choice (including additional skills
from espionage, rogue or physical)."* The parenthetical is why floors are the
right model: a floor is a **minimum**, not a cap, so the five free may also come
from those categories.

**Posture: this ENFORCES.** `relatedFloorStatus` → `validate-character.js` →
**HTTP 422**. Production holds zero assassin characters and zero drafts, checked
on **both** `class_id` and `occ_class_id`.

**A correction to my own earlier evidence.** `R11`'s outcome note says the
enforcement was *"Proved by running `relatedFloorStatus` against the
techno-wizard's own block"*. **That call was malformed** — the signature is
`(cls, categoryNames, allowance)` and it was passed skill objects and a level, so
it returned `unreachable: true` for every input including an empty one. The
conclusion was right and the demonstration was not. Re-run correctly here:

| picks | result |
|---|---|
| nothing picked, 9 to spend | reachable — a fresh build is not blocked |
| 9 all Science | **unreachable** |
| 2 Espionage + 1 Rogue + 1 Physical + 5 free | reachable |
| 2 Espionage + 2 Physical + 5 free | reachable — the union accepts either |
| 8 Science, 1 slot left | **unreachable** |

**A stale readback is retired rather than edited.**
`zzzzz-retro-r11-remaining.sql` asserts the assassin's claim is still present
(`want 1`), which was true when it ran and is false from here. A one-shot script
is not edited, so `R13`'s script asserts the inverse and sorts after it
(`r11` < `r13`). `d1-apply` prints trailing SELECTs rather than enforcing them,
so the stale line costs a confusing rebuild message and nothing more — but it
should not go unexplained.

**The other seven list entries were re-checked and all hold**, so this is not a
third pass over that list. One carries a caveat: *"conditional bonuses correctly
live in prose throughout"* holds **at class level** but not for catalog **skill**
rows, where `R4` moved seven into `level_bonuses.applies_when` today. Annotated
in `CLASS-AUDIT.md` rather than changed, because whether *"throughout"* covered
skill rows is a wording judgement.

**Five classes with the same unexpressed floor are NOT touched**, and a readback
asserts it: `knight`, `palladin` and `thief` (single-category) and `soldier` and
`witch` (union). `add-soldier-class.sql` carries the same claim in its own words.
Each would gain the same HTTP 422 enforcement, which is more than releasing one
sentence authorised — **filed as `R14` below rather than folded in.**

### R14 — medium — five more classes carry a related-skill floor only in prose

**FILED, NOT TAKEN.** Turned up by `R13`'s release audit.

| class | the floor, from its own category note | spelling |
|---|---|---|
| `knight` | 2 of 8 from Communications | single |
| `palladin` | 2 of 7 from Communications | single |
| `thief` | 2 of 8 from Espionage | single |
| `soldier` | 2 of 9 from **Military or Espionage** | union |
| `witch` | 2 of 10 from **Wilderness or Domestic** | union |

```bash
node scripts/q.mjs --remote "SELECT class_id FROM imported_classes WHERE deleted_at IS NULL AND instr(markdown,'minimums:') = 0 AND (instr(lower(markdown),'must come from') > 0 OR instr(lower(markdown),'at least two must') > 0)"
```

The three single-category floors were expressible long before today — `minimums`
took a `category` from the start — so those are simply unfixed rather than
stale. The two unions are the shape `R13` just released.

**Proposal:** add `minimums` to all five and rewrite each category note.
**Posture: ENFORCEMENT — five more classes answer HTTP 422 on a save that
misses a floor.** That is the whole of what is being agreed to, and it is why
this is filed rather than taken alongside `R13`.

**`apps/character-creator/db/add-soldier-class.sql` states the limit in its own
words** — an applied script asserting something no longer true, which is the
`claim-audit` shape and cannot be edited in place.

**Evidence:** the query above, `--remote`, 2026-09-04; each class's note read
individually.
**Confidence: high** on the floors existing. **Medium** on the exact numbers
until each page is re-read — every floor fix in this menu so far has moved on a
book re-read.
**Ongoing cost:** none.

**Taken, 2026-09-05 (PR #729) — as written: five classes, seven notes, and
the enforcement posture the proposal spelled out.** All five now hold a floor in
`occ_related_skills.minimums`, applied to production before the merge
(`zzzzz-retro-r14-related-floors.sql`, eight readbacks, `--remote`).

| class | floor | spelling | printed |
|---|---|---|---|
| `knight` | 2 of 8 Communications | single | 87 (`pf` `p089`) |
| `palladin` | 2 of 7 Communications | single | 89 (`p091`) |
| `thief` | 2 of 8 Espionage | single | 94 (`p096`) |
| `soldier` | 2 of 9 Military **or** Espionage | union | 83 (`p085`) |
| `witch` | 2 of 10 Wilderness **or** Domestic | union | 116 (`p118`) |

**The numbers were the half this finding was least sure of, and they all held.**
Its own confidence line said *"medium on the exact numbers until each page is
re-read"*, so each page was re-read off the `pf` cache rather than off the
class's own note — the arithmetic on every one matches the count already stored,
so **no count moved**. Raise that to high.

**Nothing live was at risk.** Zero characters and zero drafts on all five, on
both `class_id` and `occ_class_id`, `--remote`, 2026-09-05.

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

### R15 — medium — the two Ley Line classes carry the same floor, and one live draft breaks

**FILED, NOT TAKEN.** Turned up by `R14`'s release audit, which found the scope
of `R14` short by two.

| class | the floor, from its block note | spelling |
|---|---|---|
| `ley-line-walker` | 2 of 7 Science **and** 1 of 7 Technical | two singles |
| `ley-line-rifter` | the same, stated as *"Stats are the Ley Line Walker's"* | two singles |

Rifts Ultimate Edition printed 116 (`rue` cache `p119`): *"Select seven other
skills, but two must be selected from the science category and one from
technical."* Two independent single-category floors, both expressible since
PR #428.

```bash
node scripts/q.mjs --remote "SELECT class_id FROM imported_classes WHERE deleted_at IS NULL AND instr(markdown,'minimums:') = 0 AND instr(lower(markdown),'must be from') > 0"
```

**This one is NOT free, and that is the whole reason it is separate from `R14`.**
Draft `285` sits at step 4 on `ley-line-walker` with all seven related picks
spent — Swimming, Navigation, Language: Dragonese, Lore: Magic, W.P. Revolver,
Identify Plants & Fruit, Radio: Basic — and **not one of them is Science**. The
floor would be `owed 2, remaining 0` the moment that draft is finished: a real
person's half-built character refused by a rule the app did not have when they
started it. Character `9917` holds `occ_class_id: ley-line-rifter` and no
related-typed skills, so it stays reachable.

**Proposal:** add `minimums` to both, rewrite both block notes — **and decide
what happens to draft 285 first.** The options are to leave it (the player loses
two picks' worth of choices and must re-pick), or to widen the draft so a
pre-existing draft is graded against the rules it was started under, which is a
larger change than this finding.
**Posture: ENFORCEMENT, and unlike `R14` it reaches live data.** That is what is
being agreed to.

**Do not reuse `R14`'s guard as written.** Its script guards each insert with
`instr(markdown, 'minimums') = 0`, and both findings' detection queries filter
on `instr(markdown,'minimums:') = 0` — **every one of those substrings is inside
`attribute_minimums:`**, which 15 published classes carry
(`node scripts/q.mjs --remote "SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL AND instr(markdown,'attribute_minimums') > 0"`,
2026-09-05). Such a class would have its floor **silently skipped** and still
satisfy the readback. It did not bite `R14` — none of its five carries attribute
minimums, and the readbacks assert the floor literals as well — and the corpus
re-derived by *parsing* rather than string-matching is clean today, which is how
this was established rather than assumed. Guard on the literal being inserted.

**Evidence:** the query above and the draft read individually,
`--remote`, 2026-09-05; the page re-read from the `rue` cache.
**Confidence: high** on the floors and on the draft.
**Ongoing cost:** none, beyond whatever is decided about the draft.

**Taken, 2026-09-05 (PR #740) — as written: both classes, both floors, the
enforcement posture.** Applied to production before the merge
(`zzzzz-retro-r15-ley-line-floors.sql`, six readbacks, `--remote`). Thirty
published classes now hold a related-skill floor.

```yaml
minimums:
  - { count: 2, category: "Science" }
  - { count: 1, category: "Technical" }
```

Two **independent single-category** floors, not a union and not one floor of
three — asserted by a readback that fails on a `categories: ["Science",
"Technical"]` spelling, because that would satisfy the obvious check while
meaning something the book does not say. Rifts Ultimate Edition printed 116,
re-read off the `rue` cache with the folio verified inside the page.

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

### R18 — medium — the wizard counts related picks against the wrong allowance

**FILED, NOT TAKEN.** Turned up by `R15`'s release audit.

`functions/api/character-creator/_lib/validate-character.js:67-76` computes the
related-skill allowance as `count` **plus every related grant scheduled through
the character's level**. `apps/character-creator/app.js:2044-2046` passes plain
`count`. The two disagree for any character above the level at which its class
first grants more related picks.

**What that costs.** The wizard's floor readout and its review-step blocker both
run off the wrong number, so a character can be told *"the picks left cannot
reach it, or the save will be refused"* when the server would accept the save.
It cannot fail the other way — the wizard's allowance is never larger than the
server's — so this is a false alarm rather than a hole. Draft 285 is a live
instance: allowance 9 on the server, 7 in the wizard.

**Thirty classes hold a floor and every one of them has a related-skill
schedule**, so the disagreement is not confined to the Ley Line pair.

**Proposal:** give the wizard the same allowance the server uses. The arithmetic
already exists in `relatedAllowance`, and the two are supposed to agree by
design — `relatedFloorStatus`' own header says the wizard and the validator
*"must not disagree about whether a character is legal"*, and here they do.
**Posture: APP FIX, no data and no new gate.** It makes a warning stop firing;
it does not make any save succeed that would have failed, nor the reverse.

**Watch the level the wizard is building at.** The server validates at the level
being created; the wizard's `S.level` must be the same number, and a mismatch
here would replace a false alarm with a missed one — which is the direction that
matters.

**Evidence:** the two functions read side by side, 2026-09-05; draft 285 run
through both (`relatedAllowance` 9 vs `count` 7).
**Confidence: high** on the disagreement. **Medium** on nothing else depending
on the wizard's narrower number until the change is run against the suite.
**Ongoing cost:** none — it removes a second copy of an arithmetic rule.

**Taken, 2026-09-05 (PR #745) — WIDENED, on Nate's word, and the widening is
the whole finding.** Taken as written it would have shipped the exact failure it
says is impossible.

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

### What is NOT verified, stated rather than glossed

**The rendered readout was not seen.** The dev server was started on 8791 and
confirmed to be serving this branch — the new comment, the new import and the
moved function were all fetched off it — but the wizard walk did not reach the
Skills step: the class picker would not register a selection through the pane,
leaving *"Choose 1 more power to continue"* and a disabled Confirm. **So this is
verified at the unit level and unverified at the page level**, which
`verify-ui` says to declare rather than let a DOM-based check read as
confirmation.

The residual risk is small and worth naming precisely: **no markup and no CSS
changed**, and `floorsHtml` is untouched — only the two numbers handed to it
move. What a render would catch that the unit checks cannot is a wiring mistake
in `relatedFloors` itself, and the six checks exercise that function's exact
arithmetic on both sides of the boundary.

**The local wizard draft was snapshotted before the walk and restored after**,
byte-for-byte including its `updated_at`; the dev server's whole process tree
was killed by command line, leaving the other wrangler instance alone.

### R16 — medium — the check that is supposed to catch the next floor cannot see any of the seven

**FILED, NOT TAKEN.** `regression.mjs`'s per-category floor invariant came from
`BOOK-INGEST-AUDIT` `F6`, and its comment argues — correctly — that an invariant
beats a count of eleven because *"a count would pass forever while the next book
imported the twelfth as prose"*. It then says the invariant *"catches the next
one"*. `R14` was the next one, and it did not.

```js
// apps/character-creator/test/regression.mjs, at :1610 when this was filed
const FLOOR_PHRASE = /\b(?:at least|no fewer than)\s+(?:one|two|three|four|five|six|\d+)\b/i;
const statesFloor = classes.filter((c) => FLOOR_PHRASE.test(c.skills?.occ_related_skills?.note || ''));
```

Two limits, and each alone hides a different half:

- **it reads the block-level `note` only**, so all five of `R14`'s classes are
  invisible — every one of them states its floor in a **category** note;
- **it matches only *at least* / *no fewer than***, so both `R15` classes are
  invisible even though their floor IS in the block note: they say *"must be
  from"*.

The check passes today, and passed throughout, at `11 of 11` — verified by
re-running it against the live corpus on 2026-09-05. It is not broken; it is
narrower than its own comment claims.

**Proposal:** widen it to read the category notes as well as the block note, and
to match the verbs the corpus actually uses (`must be from`, `must come from`,
`must be selected from`). Correct the comment's *"catches the next one"* to say
what it does catch. **Posture: TEST AND COMMENT ONLY — no data changes, no new
gate, and the check stays inside the existing suite rather than becoming its own
script.**

**A widened matcher will find prose it should not.** A category note reading
*"two of the eight must come from here"* on a class that HOLDS the floor must
not fail, and after `R14` five classes carry exactly that. The rewritten notes
were written to make this possible — each says `occ_related_skills.minimums` in
so many words — but the widened check has to be run against the live corpus and
tuned before it can be trusted, which is work rather than a one-line edit.

**Evidence:** the source above at `regression.mjs:1610-1615`, read 2026-09-05;
the corpus re-run the same day; and `R14`, which is the demonstration.
**Confidence: high** on the blind spots. **Medium** on the widened matcher
holding at zero without exceptions, until it is run.
**Ongoing cost:** a regex that needs an entry when a book prints a new phrasing
— the same hand-maintained-list cost `R8` named and `R12` collected on. That
cost is the argument for reading the shape (a floor sentence beside no
`minimums`) rather than the words, which is a bigger change than this proposes.

**Taken, 2026-09-05 (PR #741) — as written, and the posture held: test and
comment only.** No data moved, no new gate, no new script; the check stays a
`check()` inside the existing suite. `REGRESSION PASSED (263 checks)`.

The matcher now reads the block note **and** every category note, and matches
five verbs. Derived over the live corpus before a line was written:

| | classes matched | stating a floor they do not hold |
|---|---|---|
| the old matcher | 11 | 0 |
| the widened one | **29** | **0** |

The eighteen it newly sees are `R14`'s five, `R15`'s two, the ten Warlocks and
the assassin.

**Its "medium" confidence resolves to high, and the tuning it budgeted for was
not needed.** The finding said *"a widened matcher will find prose it should
not"* and expected exceptions. There are none: every one of the 29 holds a
floor. That is only true **in this order** — taken before `R15`, the same check
is red on two.

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

### R17 — low — six places say eight classes hold a floor, and twenty-eight do

**FILED, NOT TAKEN.** Turned up by `R14`'s release audit, and **it predates
`R14`** — `zzzzz-retro-r11-remaining.sql` gave the Techno-Wizard and the ten
Warlocks floors on 2026-09-04 and `R13` the assassin, so the number was already
wrong by twenty before this finding moved it by five.

| file | the sentence |
|---|---|
| `apps/character-creator/README.md:402` | *"it exists because eight classes across four books print a rule like…"* |
| `.claude/skills/class-import/reference/frontmatter.md:173` | *"eight classes across four books print one"* |
| `apps/character-creator/js/parser.js:1044` | *"so eight classes across four books carried the rule as prose"* |
| `apps/character-creator/js/parser.js:1072` | *"Empty when the class has none, which is all but eight of them"* (wrapped across 1072-1073) |
| `functions/api/character-creator/_lib/validate-character.js:234` | *"Eight classes across four books state a floor like this"* |
| `apps/character-creator/app.js:2031` | *"eight classes say…"* |

Twenty-eight published classes hold `occ_related_skills.minimums` — derived by
**parsing** every class rather than string-matching, `--remote`, 2026-09-05, for
the `attribute_minimums` reason `R15` records above.

~~`regression.mjs:1595` and `:1607` say **eleven** and are **correct**: eleven
block-level notes match the floor phrase and all eleven hold a floor. Do not
"fix" those to match.~~ **Retired 2026-09-05 by `R16` (PR #741), which
rewrote that comment block.** It was true when filed: eleven block notes matched
and all eleven held a floor. `R16` widened the matcher to read category notes
and five verbs, so the number is **29**, and the comment now states it that way
along with what it deliberately does not catch. **There is no longer an
"eleven" in that file to leave alone** — the two that remain (`:694`, `:2023`)
are a numeral map and an armour-feature count, unrelated to floors. The line
numbers above were also stale when written; the block had moved twice the same
day.

**Proposal:** this is a decision rather than an edit, which is why it is filed
rather than swept. The number moves every time a class gains a floor and
**nothing pins any of these six** — the smoke suite pins the README's catalog
counts and not this sentence. So either drop the count from all six (*"classes
across several books print a rule like this"*) or replace it with something
derivable. Dropping it is the recommendation, on `SKILL-AUDIT` `F7`'s grounds:
correcting an ordinal leaves the same trap armed, and every one of these six has
now been wrong for a day without anything noticing.
**Posture: PROSE AND COMMENTS ONLY.** No behaviour, no test, no data.

**Evidence:** the six sites read individually, 2026-09-05; the count derived by
parsing the live corpus the same day.
**Confidence: high.**
**Ongoing cost:** none if the count is dropped; the same rot again if it is
merely updated.

**Taken, 2026-09-05 (PR #742) — the count is dropped, not corrected**, which
is what Nate chose and what `SKILL-AUDIT` `F7` argues for: correcting an ordinal
leaves the same trap armed. **Posture held: prose and comments only** for the
six repo sites; the seventh needed a data script, below.

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

### R19 — low — four psionic powers are cited to a list page and carry no stat block

**FILED, NOT TAKEN.** Turned up while filling the one psionic power that had no
description at all - `Machine Ghost`, shipped separately.

| id | power | category | cited |
|---|---|---|---|
| 106 | Deaden Senses | Physical | Rifts Ultimate Edition p.141 |
| 107 | Sense Time | Sensitive | p.141 |
| 108 | Psychic Body Field | Super | p.141 |
| 109 | Radiate Horror Factor | Super | p.141 |

All four have `range`, `duration` and `saving_throw` **NULL**, and all four are
cited to the same page. **Printed 141 is a list page** — it carries these as
names with an I.S.P. cost in brackets (`Deaden Senses (4)`,
`Psychic Body Field (Super - 30; counts as two selections)`), not as entries.
Read off `rue` cache `p144` directly, 2026-09-05.

```bash
node scripts/q.mjs --remote "SELECT id, name, source_book FROM psionic_powers WHERE range IS NULL OR range = ''"
```

**This is the same defect the spell backfill is full of** — a row cited to the
book's own summary list rather than to its entry — and it is why the stat block
is empty: whoever imported these read the list. All four carry a real
description, so nothing about them looks wrong in a listing.

**Proposal:** find each entry, correct the citation, fill the stat block.
**Posture: DATA ONLY**; the prose is already there.
**Recommendation: fold this into the spell backfill's PR rather than take it
alone** — that PR is already correcting a run of citations of exactly this
shape, and four rows do not earn their own release.

**The psionic catalog is otherwise healthy**, which is worth recording because
the spell catalog was not: 116 powers, and after `Machine Ghost` every one has a
real description with **no stub problem** — not one carries a category label
where a description belongs, unlike the 230 spells that did.

**Evidence:** the query above and `rue` `p144` read individually, `--remote`,
2026-09-05.
**Confidence: high.**
**Ongoing cost:** none.

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
