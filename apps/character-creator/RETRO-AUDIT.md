# RETRO-AUDIT.md — does the catalog benefit from the schema it grew?

> **Read under the heading for a finding's state.** Outcome notes are appended
> where each finding sits.
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

---

## Not established

Recorded rather than resolved by inference.

- **54 of the 101 limitation claims were left unsettled**, roughly 21 of them
  because this pass's own sweep truncated them mid-clause. The rest are book
  prose asserting no app limitation, or provenance notes about how a class was
  transcribed. **A re-sweep bounded on the YAML block would judge them**; this
  one could not.
- **The Robot Pilot's *"the gear catalog carries no open-market power armour
  rows"*.** There are four power-armour rows and three carry a price
  (`samas-power-armor`, `ng-jk1-juicer-killer-power-armor`,
  `psionic-power-armor`; `glitter-boy-power-armor` has none). Whether the claim
  is false depends on whether *open-market* means civilian-purchasable — the
  SAMAS is Coalition military issue and the NG-JK1 is a Northern Gun commercial
  product. **That is a wording judgement, not a measurement**, and no amount of
  re-querying settles it.
- **Whether `magic.spells_from` is needed per-variant on the Warlock** — see
  `R3`. The one-Force/two-Force rule may not fit a single class-level list.
- **The five unreferenced gear rows in `R5`** (`knife-large`, `roman-candle`,
  `acid-organic`, `acid-cleanser`, `acid-metal-dissolver`) — no class cites them,
  so nothing turns on whether they are filled.
- **Per-row provenance for catalog rows does not exist** and was not
  reconstructed. Every catalog finding here rests on the row's *content*, not on
  a date.
