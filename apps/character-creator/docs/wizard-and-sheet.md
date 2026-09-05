# The wizard and the sheet

How the ten-step wizard and the character sheet behave: tabs, pickers, drafts,
blocked steps, and what the server refuses to take on trust.

Part of the [character creator](../README.md) documentation.

---

## The sheet is tabbed on screen and whole on paper

The sheet ran 4105px on desktop and 6316px on a tablet - about six screens -
with 104 inputs in one column of scroll. It is now six tabs: **Core, Skills,
Powers, Gear, Bio, Notes**, each 1.1-2.2 tablet screens.

**The first tab's id is `vitals` and its label is Core**, and the two are not
going to be reconciled. It was called Vitals when it held the five pools; the
pools moved to the sticky strip, leaving attributes, combat, saving throws and
experience. The label follows the contents, the id does not:
`localStorage['sheet-tab-<id>']` stores it and `#vitals` links are already in
circulation, so changing the id would strand both.

**Tabs are a screen affordance only.** There is no such thing as a hidden tab on
paper, so the print block dissolves the panels rather than revealing them
one at a time:

```css
@media print {
  .tabbar   { display: none !important; }
  .tabpanel { display: contents !important; }
}
```

`display: contents` removes the section wrappers from layout entirely, so every
grid inside them lays out exactly as it did before tabs existed. Revealing the
panels with `display: block` would have worked too and would have changed every
row's layout; this way the printed sheet is the one that was already tuned.

Two things fell out of measuring rather than guessing:

**The header was the real problem, not the length.** 467px of mostly-blank
background fields - race, true name, occupation, sex, family origin, insanity,
birth order, disposition - was the entire first tablet screen. Tabs alone did
not fix it: the sheet still opened showing no game data, and the tab bar sat
*below the fold*, so the tabs did not even announce themselves. The background
fields moved to their own tab; identity you check constantly stays pinned above
the bar. **This was invisible in the DOM metrics and obvious in the first
screenshot.**

**Powers and Equipment shared a two-column grid** and were the two largest
blocks, 1166px together. They are separate tabs now, so on paper they stack full
width - the one intentional change to printed layout, and it gives the
five-column equipment table room it never had at half width.

Switching tabs toggles classes rather than re-rendering: a re-render rebuilds
every input on the sheet, and the one thing a tab press must never cost a player
is a half-typed note. The active tab persists per character and reads from the
URL hash, so a link ending `#gear` opens on gear; a `hashchange` listener covers
the same-document case, where nothing reloads. `replaceState`, not `pushState` -
Back should leave the sheet for the character list, not walk tab history.

## A power says what it does, in place

Press a power's NAME in the Powers tab and its description opens under the row.
The name is the control rather than a chevron beside it: it is the biggest
target in a dense row and the thing a player is already looking at. A power the
catalog has no text for keeps a plain span, so nothing offers a press that does
nothing.

**The text arrives with the character, not with the catalog.** `characters/[id]`
returns `power_descriptions` for the powers this character holds — 4.4KB
gzipped for the heaviest character on production, against 72.4KB to put the two
catalogs' whole description corpus in the boot payload every wizard and sheet
load already pays for. [Plan 20](plans/20-power-descriptions.md) has the
measurements and the four options it rejected.

Two things about it are load-bearing and easy to undo:

**Which rows are open is state, not DOM.** `C.openPowerDescs` holds the indices.
Plenty of things re-render this sheet — spending P.P.E. with the use button one
row down does — and a description that closed itself when you cast something
reads as a bug. The toggle itself does not re-render, for the same reason
switching tabs does not.

**On paper the name is a name and the description is gone.** Making the name a
`<button>` put it inside the print block's blanket `button { display: none }`,
which deleted every spell name from the printed sheet — a P.P.E. column with
nothing to say what it was for. `.power-toggle` is put back explicitly, exactly
as `.vital .val b` is. The descriptions themselves stay off paper on purpose:
one character's held powers are about 8,000 characters of book prose, roughly
three pages on a sheet that exists to be a control panel at a table.

## Filtering the catalog pickers

Every picker used to render its whole catalog: 74 gear rows in two places, 128
skills in a native `<select>`. Spells and psionics looked fine only because
those chapters have not been imported — they are pre-filtered by level and tier,
which hides the problem right up until a spell chapter lands.

All six now carry a filter box with a live count (`12 of 128`), backed by
[`js/picker.js`](../js/picker.js):

| Surface | Control underneath |
|---|---|
| Wizard — add from item catalog | `<select>`, narrowed |
| Wizard — related / secondary skills | checkbox list |
| Wizard — spells, psionics | checkbox list |
| Sheet — add inventory | `<select>`, narrowed |
| Sheet — spend level-up skill picks | N `<select>`s over one shared pool |

The control varies because the task does — "add one item" and "pick 6 of these"
want different things. What is shared is the matching and the input.

- **Matching is name, category and source book**, all terms required, order
  irrelevant: `wilderness rifts` narrows, it does not widen. Fields the row does
  **not** display are deliberately not searched — a hit whose reason is
  invisible reads as a bug.
- **Enter takes a lone match.** Type until one row remains and press Enter; with
  several matches it does nothing rather than guessing.
- **An already-chosen row stays visible** even when the filter excludes it,
  or narrowing the list would look like it had un-picked something.
- **`picker.js` is a classic script**, like `js/derive.js`, because the wizard is
  a module and the sheet is a plain script and both need it.

`Picker.wire()` restores the caret after re-render. Both pages rebuild by
replacing `innerHTML`, so an input loses focus and drops the caret to the end
mid-keystroke; the catalog editor had already hand-rolled the fix, and this puts
it in one place.

**Level-up picks are now held in state, not read off the DOM at submit time.**
They were collected from the `<select>`s only when you pressed the button, so
any re-render in between discarded them — the "show all skills" checkbox already
did that. A filter that re-renders on every keystroke would have done it
constantly.

---

## Two tabs cannot overwrite each other

There is one draft per person, so every `PUT /draft` is a replace. That is fine
until something else is building at the same time — a second tab, or a script
driving the wizard — at which point the last write silently won and the other
build was gone with no error anywhere.

So a PUT says which version it believes it is replacing:

```json
{ "expect_updated_at": "2026-08-20 09:55:43", "step": 3, "state": {} }
```

| The caller claims | The row is | Result |
|---|---|---|
| `null` ("I expect no draft") | absent | created |
| `null` | present | **409** |
| a timestamp | that timestamp | replaced |
| a timestamp | anything else | **409** |

Each branch is a **single guarded statement** — `INSERT … ON CONFLICT DO NOTHING`
or `UPDATE … WHERE updated_at = ?`. Reading the row and then writing it would
leave exactly the gap this exists to close.

The 409 body carries `current`, so a client can say what took the draft over
rather than only that something failed. The wizard tracks the version it holds,
carries it forward from each save's response, and on a conflict **stops
autosaving** and says so in the stepper. Stopping matters: retrying would either
fail forever or, once it re-read, clobber the other build after all. Work already
on screen is untouched — you can finish and save it, or reload to take theirs.

Deleting a draft clears the tracked version, so the next build creates rather
than claiming a row that no longer exists.

---

## Unfinished builds are saved

The wizard is ten steps and step 3 **rolls**. A refresh, a stray back-gesture
or a closed tab used to lose all of it — and a roll is the one thing you cannot
honestly redo: you either accept different numbers or re-roll until you like
them.

The build now autosaves to `character_drafts`, debounced ~1.5s off `render()`,
which already runs after every mutation. Returning to the wizard offers
**resume or discard** rather than dropping you into step 4 of a half-finished
character with no explanation.

Four things worth knowing:

- **Its own table, not a `draft` status on `characters`.** A half-built
  character has no name, no campaign and possibly no attributes. Putting one in
  `characters` would mean every list, the dashboard, the audit and the validator
  filtering out rows they must never treat as real — forever, to serve a state
  that lasts minutes. The wizard's state is not a character shape either: it
  carries which roll method was used per attribute, which choice-group options
  are ticked, and how far through the steps you are.
- **An allowlist, not a copy of the state.** `DRAFT_KEYS` in `app.js` names the
  build itself. The wizard's state also holds the class, skill, spell and gear
  catalogs, which are large, shared, and stale the moment they are written down.
  A real draft is ~1.5 KB.
- **The class is stored as an id and re-resolved on restore**, so an edited
  class definition takes effect instead of being shadowed by the draft. A draft
  naming a class that no longer resolves is discarded rather than half-applied.
  Gear choice *options* are re-derived for the same reason — only which options
  you **ticked** is persisted.
- **The unload warning waits for the rolls.** Before that, "losing" the draft
  costs two clicks; a browser dialog on every exit would be noise. It also stops
  once the character is saved.

One draft per person, enforced by `UNIQUE (owner_email)` — saving is an upsert.
Discarding is idempotent, and a draft that cannot be parsed is reported as
absent rather than partially restored.

---

## Starting gear the class leaves open

Books routinely say *"one energy pistol of choice"*. `equipment_starting` only
held fixed `item_id`s, so the importer wrote the **category** as if it were an
item — `energy-pistol`, `vibro-blade` — and the class importer dutifully created
a stub catalog row for each. Those rows are not items. No book entry will ever
match them, so they sat in the catalog with no stats and the character held a
weapon that does not exist.

An entry may now be a **choice**, the same idea `occ_skills` already used:

```yaml
equipment_starting:
  - { item_id: "back-pack", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1,
      from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
```

- `from` enumerates **item slugs**. There is no `categories` flavour, unlike
  skills: gear's `category` is weapon/armor/vehicle/gear, far too coarse to mean
  "any energy pistol". The cost is that a new book's pistols must be added to
  the classes that offer the choice.
- `label` is what the player is choosing, shown above the options.
- **Every option must exist in the catalog** — cross-reference collects them all
  and stubs any that are missing, on the same reasoning skill groups use: any
  one of them could be the option actually picked.
- The wizard **will not advance** until every choice is resolved. Starting gear
  is finite and the book intends the character to have it, so an unresolved
  choice is an oversight, not a deliberate omission. (Unspent *skill* picks are
  banked instead — they are earned over time and often deliberately deferred.)
- Extraction emits these from the book's own wording (`of choice`,
  `one of the following`), and is told explicitly not to invent a placeholder
  item to stand for a category.

Retiring the placeholders that already existed is a one-off per environment:
[`db/retire-gear-placeholders.sql`](../db/retire-gear-placeholders.sql). It
converts affected inventory rows to freeform lines — the placeholder was never
a real item, so naming it as text is the truthful representation — rewrites the
Juicer's two placeholders into choices, and drops the rows.

**Every statement guards itself**, which matters because a choice is only an
improvement if its options exist. An environment whose catalog is still
seed-only would otherwise have two bad references replaced by nine, and the next
class import would stub every one of them. So each rewrite requires its own
options to be present, and a placeholder is only dropped once no live class
still cites it. That makes the script safe to run **early** as well as twice: in
an environment that has not imported the equipment chapter it does nothing at
all, and the closing `SELECT` reports what it did and what it is still waiting
for (`options_available_of_8`). Re-run it after that import and it completes.

---

## A blocked step says why

Four wizard steps gate their primary button: **Race** (a variant or a power
still to choose), **Attributes** (a value missing, a class minimum unmet, or
point-buy overspent), **Occupation** (an ability that names practitioners with
none chosen) and **Equipment** (an unresolved gear choice).

Each renders the reason as a `.nav-why` span **between Back and the primary
button**, and the race step also scrolls the outstanding picker into view. The
reason and the disabled state come from ONE function per step — `classBlock()`
and its equivalents — so they cannot disagree.

**A missed attribute minimum is deliberately NOT one of them.** It warns and
offers a re-roll on the Occupation step; see
[The race is chosen first](race-and-occupation.md#the-race-is-chosen-first). A greyed button with no reason,
or a reason beside a live button, are each worse than either alone.

**Not gated is not the same as allowed, and the two paths surface it at
different steps.** Where the class is already known by the Attributes step — the
O.C.C.-first path — that step *does* gate on it, which is the "class minimum
unmet" reason listed above. Where the race came first and the occupation is
chosen at step 4, only the warning fires. **Either way the save refuses the
character**: `_lib/validate-character.js` returns `attribute_minimum` as a
blocking violation and the create endpoint answers 422. There is no GM
exemption — `enforcePools` is the only rule that yields to a GM's ruling, and it
governs pool maxima, not attributes. The warning on the Occupation step used to
say continuing was *"allowed and is flagged on the character"*, which was untrue
in both halves; see `UI-AUDIT.md` F2.

This exists because a disabled button was the entire explanation. Picking a Ley
Line Walker greyed the primary action with no visible cause, and the requirement
(choose a power) rendered below the fold. Reported as "nothing happens".

**Adding a fourth gated step means adding its reason too.** The pattern is one
function returning the sentence, the button deriving `disabled` from it, and
`.nav-why` in the nav row — which is also the only ordering that wraps onto its
own line under 620px.

Separately, `shared/styles.css` dims any `:disabled` button to 0.45 and sets
`cursor: not-allowed`. Nothing styled that before, so a button you could not
press was pixel-identical to one you could, in all three workshop apps.

---

## How the sheet updates

Most of the sheet re-renders wholly — on load, on save, on a level-up, on
switching character. That is deliberate: correctness over cleverness.

Three paths update in place instead, because they used to destroy work:

| Path | What it does |
|---|---|
| Add armour | appends one slot to `#armor-list` |
| Remove armour | removes that slot, then renumbers the rest |
| Inventory add / remove / qty / equipped | refreshes `#inv-rows` only |

**Why it matters.** The section inputs (bio, combat, saves, armour) are only
read back at Save, by `collectSections()`. A full re-render rebuilt them from
stored state, so anything typed and not yet saved vanished. Armour add/remove
used to work around that with a `keepEdits()` call that copied the DOM into
state first — a patch every new interactive block had to remember to join in on.

The inventory paths were worse: they called `load()`, which **refetches the
character and replaces state wholesale**, so `keepEdits()` could not have helped
even if they had used it. Adding an item silently discarded your typing.

Now nothing else is touched, so unsaved edits simply survive — the DOM is the
source of truth for them until Save reads it back. `keepEdits()` is gone.

**If you add another in-place path**, remember `collectSections()` reads
`data-armor` as an array index. Removing a slot has to renumber the ones after
it, or the saved array acquires a hole.

---

## Server-side rule enforcement

The wizard has always enforced skill counts, categories and attribute minimums.
`_lib/validate-character.js` now re-checks them on every write that can change
skills — character create, level-confirm, and spending banked picks. The wizard's
checks are a convenience that avoids a round trip; this is the boundary.

**Deliberately narrow.** It checks what a player *chooses*, and returns a
structured `violations` list with a 422 rather than a flat message.

Four things that are not obvious and were each learned the hard way:

- **The fixed `occ_skills` list is not checked.** It is not a choice, so a
  mismatch means the class was edited or re-imported since the character was
  built — not the player's fault, and not something that should block their save.
- **The related-skill allowance grows with level**, by the grants in
  `occ_related_skills.schedule`. Without that, anyone who levelled up and spent a
  pick reads as over their limit.
- **A stored skill row is not a reliable source of category.** The wizard writes
  `category: "Class"` on every O.C.C. skill, so the validator resolves categories
  from the skills catalog and only falls back to the stored value.
- **Choice groups warn, they never block.** A character does not record *which*
  group a skill was taken for, so a skill the class also grants by name in the
  same category is indistinguishable from a chosen one. Counting by category both
  over- and under-counts, and refusing a save on an approximation would be worse
  than the gap it closes.

A skill marked `override: true` by the level-up picker is legal by definition —
that flag means a human decided it.

**Chosen abilities get the same boundary.** The pick count (`ability_count`) and
repeatability (`ability_repeat`) are violations — a five-power Godling or a
doubled non-repeatable power has no legitimate path — while a power the class
no longer offers only warns (`ability_unknown`), because a class edit is not the
player's fault. A `{ name, gm: true }` entry is the abilities' `override: true`:
a power the G.M. assigned by hand (the Demigod's *"most have ONE extra power,
similar to that of the godly father or mother"*), exempt from the count and the
offered list, counted only for repeats — holding a power twice is holding it
twice, whoever granted the second. It still grants its bonuses through
`applyAbilities`, which tags it `gm` for the sheet.

**Creation-time powers get the same boundary.** The spells and psionic powers
a character is *created* holding used to be stored unvalidated — the one write
path `resolvePowerPicks` did not cover, so a crafted request could know every
spell in the book at level 1. The create endpoint now checks them: counts
against the starting allowance plus every grant the climbed levels earn, spell
levels against the caps, psionic categories and named lists, catalog existence
and the campaign's system — all violations, because the wizard cannot produce
any of them. Two carve-outs keep it honest: the powers a class grants
**outright** (`magic.spells`, `psionics.powers`) are exempt, since they are
granted rather than chosen and may legitimately name catalog gaps; and a pick
does not record which grant it spent (only level-up picks carry
`gained_at_level`), so a pick passes the cap checks if **any** applicable pool
admits it — the same no-guessing rule that keeps skill choice-groups advisory,
under-enforcing at the seams rather than ever refusing a legal build.

**The starting pick is a LIST of groups, not one.** For a long time creation
could hold exactly one count and one gate, while a level-up grant could hold
several — and the two are built in different places, so nothing said so out
loud. Three books need more: the Elemental Fusionist picks its first spell from
an eighteen-name list, the Delphi Juicer starts with *3 Physical + 1 Super*
psionic powers, and the Mind Mage with *three from each of four categories*.
The Juicer and the Mind Mage were stored as one open count over every category
they touch, which let a player take four Super where the book grants one, and
the Fusionist's list could not be named at all (CLASS-AUDIT.md S1 and S9).

`startingGroups(cls, kind)` in `js/leveling.js` now returns the starting picks
as an array shaped exactly like `powerGrantsFor`'s level-up grants, and both
builders read it — the wizard's Powers step and the server's validator, which
are separate paths and are the pair that drifts. Everything downstream already
handled several groups with different gates, because that is what the level-up
grants are; only the two builders had to move.

- `spells_starting` / `powers_starting` still mean the **total**, so a class
  stating only a number is untouched.
- `*_starting_groups` splits that total. A group naming its own categories,
  spell levels or `from` list **replaces** the block's rather than narrowing
  them — the rule level-up grants already follow, because a book naming Super
  for one slot is granting an exception, and intersecting would throw it away.
- A group's `note` is for a restriction the catalog **cannot** enforce - the
  Mind Mage's *"Mind Wipe, Psi-Sword and Mentally Possess Others cannot be
  selected until third level"*. It renders as *"<note> — the catalog cannot
  check this one, so it is yours to honour"*, so a note that merely restates
  the group's own gate tells the player the opposite of the truth about the
  picker beneath it, which already captions itself *"2 spells from levels 1"*.
  The Wizard shipped four of those and they came off in
  `zzz-wizard-the-seventh-spell-pick.sql`.
- `magic.spells_from` is the twin of `psionics.powers_from`, which spells never
  had: a named list bounds the starting spell pick and replaces the spell-level
  cap outright.
- The wizard keeps writing a single group into the flat `S.spells` / `S.psi` it
  always used, so no saved draft changes shape; only a class that splits its
  pick writes into the per-group `S.spellGroups` / `S.psiGroups`, keyed by group
  index exactly as the Advancement step keys its per-grant pickers.

**An empty starting pick has four different meanings, and the step used to
render one thing for all of them:** the heading *Spells — 0/0*, a filter box,
and 543 checkbox rows, every one disabled because the allowance was zero. That
is the same conflation the per-level side already avoids — *not recorded* is a
different answer from *none*, see
[starting-above-level-1.md](starting-above-level-1.md), "Per-level spells are
not in the data" — so `startingPicksFor(cls, kind)` draws the distinction here
too and the Powers step says which nothing it is:

| The class's magic block | The step says |
| --- | --- |
| absent, or `type: "none"` — the Godling, whose magic comes from the O.C.C. picked beside it | nothing at all; the step falls through to "no spellcasting or psionics" |
| states no starting count — the Druid | *does not record how many spells it starts with*, in the words the Advancement step already uses one level up |
| `spells_starting: 0` — five dragon hatchlings, whose books say a hatchling *"knows NO spells at first level"* | *none at level 1*, an answer rather than a gap |
| names its spells outright in `magic.spells` — the Shifter's twenty, the Techno-Wizard's twenty-five | *N known*, listed with level and P.P.E. |

That last row is a second bug the same size. Granted spells have reached the
character since `powersPayload` started folding them in — before that they were
listed by the class and held by nobody — and the step where a player looks for
their spells showed none of them.

**A starting pick stated as a level-1 schedule entry fires nowhere**, and is
reported rather than honoured. Creation asks `perLevelGrants` from level 1 and
it skips every entry at or below `fromLevel` **by design**; creation's own
reader is `startingGroups`, which reads the `*_starting` keys. The step counts
such picks and says so rather than honouring them: honouring them would make a
schedule a second way to state a starting pick, and one way is the whole reason
the `*_starting` keys exist. The fix is always to re-state the class with
`spells_starting_groups`.

The Wizard was the class this was found on — six picks, two from spell level
one, two from two, one each from three and four, every one of them written as a
`spells_schedule` entry at `level: 1`, reaching no character.
`zzz-wizard-starting-spells.sql` re-stated them as groups and
`zzz-wizard-the-seventh-spell-pick.sql` added the seventh, so it now starts
with **seven** picks and no schedule at all. The seventh is the level-one
instance of *"one new spell at each new level of experience, starting at level
one"* — `perLevelGrants` begins at level two, so creation has to state that one
itself.

**What a roll *could* come up is checked; what it *did* come up is not.** The
dice are rolled client-side by design, so the server bounds each stored pool
maximum against the range its class formula can actually produce
(`poolFormulaBounds` — the same parse walk `rollPoolFormula` takes, with every
die pinned to its floor or ceiling), per-level growth included. At **creation**
an out-of-range maximum is a **violation for anyone but the campaign's GM** —
the wizard offers no way to type a pool, so a non-GM value outside the range is
a crafted request with no honest roll behind it, and the class the wizard
rolled from is the same current class the server checks seconds later. The
**GM keeps a warning instead of a refusal**: a GM ruling beats a computed
number everywhere else in the app, and transcribing a long-running character
faithfully is exactly that case. The audit never enforces (existing characters
are not retro-validated), and the level-up flow's sanctioned "tweak if your GM
says so" is deliberately a different door. Attributes get the same treatment
against the highest their dice can roll, exceptional chain included
(`attributeCeiling`) — advisory because Manual entry exists precisely for
numbers a table decided. Both surface in the admin audit, which now receives
pools, powers and each campaign's system.

**Existing characters are not retro-validated.** They keep loading and saving
whatever state they are in; `admin/audit` reports which ones break a rule so you
can decide case by case. It is read-only and modifies nothing.

It is the **Audit characters** button on the catalog page, above the catalog
tabs rather than in the per-catalog toolbar — it reports characters against the
classes they were built from, so nothing about it changes when you switch tabs.
This is the feedback loop for the class corrections in
[Data scripts](operations.md#data-scripts): every `fix-*.sql` that rewrites a class against
the book can retroactively put an existing character out of step with it, and
this is the only thing that says which. It splits **would be refused on save**
from **worth a look**, because only violations block — a character carrying
warnings alone is legal, and listing the two together would send you to fix
something that is already correct.

The endpoint existed with no caller for some time, which is why a smoke check
now asserts a page script calls it. Routed and documented is not the same as
reachable, and an endpoint nobody can run is exercised by nothing.

A character whose class cannot be resolved — retired, deleted, or no longer
parsing — **skips validation and saves normally**. Refusing would strand a
character whose class an admin retired, which is exactly what class soft-delete
was built to avoid. The audit lists those separately as unvalidatable.

**A rejected save says which rule broke.** The endpoints return a `violations`
array where every entry carries a readable `message`, and both pages now print
them — the wizard as a list under the failure, the sheet inline. They used to be
thrown away, so a failed save read *"This character breaks its class rules"* and
nothing else: true, and useless for working out what to change.

```
Save failed: This character breaks its class rules
  • ME is 3, below the class minimum of 12
  • MA is 3, below the class minimum of 12
  • 7 related skills, but this class allows 6 at level 1
```

A smoke check asserts every violation the validator can emit carries a message,
so a new rule cannot ship as an unexplained refusal.

---
